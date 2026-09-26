/* CAPS03 one-invocation HLS vector-add frontend; preserve all predecessors.
 * Numerical/order validation is separate from physical and VFIO lifecycle acceptance.
 * Do not run on hardware before the exact image/runtime/teardown operation is admitted.
 */
#define _POSIX_C_SOURCE 200809L
#include "ahls_qualification_core.h"
#include "ia840f_dma_capabilities.h"
#include "ia840f_dma_lifetime.h"
#include "ia840f_dma_segments.h"
#include <opae/buffer.h>
#include <stdatomic.h>
#include <unistd.h>
#include <opae/access.h>
#include <opae/enum.h>
#include <opae/properties.h>
#include <opae/mmio.h>
#include <opae/utils.h>
#include <inttypes.h>
#include <stdio.h>
#include <string.h>

static int memory_api_ok(fpga_result rc, const char *operation)
{
    if (rc == FPGA_OK) return 1;
    fprintf(stderr, "FAIL %s: %s (%d). No retry/reset.\n",
            operation, fpgaErrStr(rc), (int)rc);
    return 0;
}

static int dma_read64(void *h,uint64_t off,uint64_t *value)
{
    return fpgaReadMMIO64(h,0,off,value)!=FPGA_OK;
}
static int dma_write64(void *h,uint64_t off,uint64_t value)
{
    atomic_thread_fence(memory_order_seq_cst);
    int rc=fpgaWriteMMIO64(h,0,off,value)!=FPGA_OK;
    atomic_thread_fence(memory_order_seq_cst);
    return rc;
}
static int bytes_match(const volatile unsigned char *actual,const unsigned char *expected,size_t n)
{
    for(size_t i=0;i<n;++i)if(actual[i]!=expected[i])return 0;
    return 1;
}

static int hls_status_matches(uint64_t status,uint64_t low)
{
    return (status>>16)==5 && (status&UINT64_C(0xb007))==low;
}
static int hls_wait_status(fpga_handle handle,uint64_t low,uint64_t *status)
{
    for(unsigned i=0;i<1000;++i){
        if(!memory_api_ok(fpgaReadMMIO64(handle,0,0x10000,status),"HLS status"))return 0;
        if((*status>>16)!=5)return 0;
        if(hls_status_matches(*status,low))return 1;
        if(i==999 || ia840f_dma_wait_step(NULL))break;
    }
    return 0;
}
static int hls_wait_completion(fpga_handle handle,uint64_t *status)
{
    for(unsigned i=0;i<1000;++i){
        if(!memory_api_ok(fpgaReadMMIO64(handle,0,0x20028,status),"HLS completion"))return 0;
        /* Exact supported/error/reserved-bit checks; reset-to-idle is not success. */
        if(*status==UINT64_C(0x10002))return 1;
        if(*status!=UINT64_C(0x10001))return 0;
        if(i==999 || ia840f_dma_wait_step(NULL))break;
    }
    return 0;
}
static void store_int32(unsigned char *p,int32_t value)
{
    uint32_t u=(uint32_t)value;
    for(unsigned i=0;i<4;++i)p[i]=(unsigned char)(u>>(8*i));
}
static int caps03_dma(const struct ia840f_dma_io *io,unsigned mode,unsigned bank,
    uint64_t ddr,uint64_t iova,unsigned host,unsigned bytes,
    void **buffers,unsigned char *expected_tx,unsigned char *expected_rx,
    const unsigned char *incoming,struct ia840f_dma_report *report,unsigned sequence)
{
    if(ia840f_dma_segment_bytes(ddr,host,bytes)!=bytes)return 0;
    struct ia840f_dma_request request={.mode=mode,.bank=bank,.ddr_offset=ddr,
        .iova_base=iova,.mapped_bytes=4096,.host_offset=host,.bytes=bytes,.max_polls=1000};
    printf("FPGA Test DMA submit sequence=%u mode=%u bank=%u bytes=%u ddr=0x%" PRIx64 "\n",
           sequence,mode,bank,bytes,ddr);fflush(stdout);
    atomic_thread_fence(memory_order_seq_cst);
    enum ia840f_dma_result rc=ia840f_dma_transfer(io,&request,report);
    if(rc!=IA840F_DMA_OK){
        fprintf(stderr,"FAIL DMA rc=%d phase=%d polls=%u\n",(int)rc,(int)report->phase,report->polls);
        if(report->go_may_have_been_issued && !report->quiescent)
            ia840f_dma_hold("descriptor outcome uncertain",report);
        return 0;
    }
    if(mode==2){
        int visible=0;
        for(unsigned i=0;i<1000;++i){
            atomic_thread_fence(memory_order_seq_cst);
            if(bytes_match((volatile unsigned char*)buffers[1]+host,incoming,bytes)){visible=1;break;}
            if(i==999 || ia840f_dma_wait_step(NULL))break;
        }
        if(!visible)ia840f_dma_hold("HLS result/guard host visibility or data mismatch",report);
        memcpy(expected_rx+host,incoming,bytes);
    }
    if(!bytes_match(buffers[0],expected_tx,4096) || !bytes_match(buffers[1],expected_rx,4096))
        ia840f_dma_hold("source or host-page guard corruption",report);
    printf("FPGA Test DMA retired and host pages verified sequence=%u\n",sequence);fflush(stdout);
    return 1;
}

int main(int argc, char **argv)
{
    fpga_properties props = NULL;
    fpga_token token = NULL;
    fpga_handle handle = NULL;
    fpga_guid guid = {0xd4,0x8d,0xde,0x9f,0xf5,0x51,0x57,0x8d,
                      0x8b,0xb0,0x69,0x48,0x3a,0xc9,0x5e,0xc6};
    const uint64_t identity_offsets[] = {0,8,16};
    const uint64_t identity_words[] = {UINT64_C(0x1000010000000000),
        UINT64_C(0x8bb069483ac95ec6), UINT64_C(0xd48dde9ff551578d)};
    const uint64_t capability_offsets[] = {IA840F_DMA_CAP_ID_OFFSET,
        IA840F_DMA_CAP_GEOMETRY_OFFSET, IA840F_DMA_CAP_ADDRESS_OFFSET,
        IA840F_DMA_CAP_LIMITS_OFFSET};
    uint16_t segment;
    uint8_t bus, device, function;
    uint32_t matches = 0;
    uint64_t words[4] = {0};
    struct ia840f_dma_capabilities capabilities = {0};
    int mapped = 0, exit_code = 1, kernel_uncertain = 0;
    uint64_t status=0,ticket=0,completion=0;
    void *buffers[2]={NULL,NULL};
    uint64_t wsids[2]={0,0},iovas[2]={0,0};
    unsigned prepared=0;
    unsigned char expected_tx[4096],expected_rx[4096];
    struct ia840f_dma_report report={0};
    if (argc != 3 || strcmp(argv[1], "--run-qualified-caps03-hls") ||
        ahls_parse_bdf(argv[2], &segment, &bus, &device, &function)) {
        fprintf(stderr, "Usage (separately authorized hardware only): %s "
                "--run-qualified-caps03-hls dddd:bb:dd.f\n", argv[0]);
        return 2;
    }
    if(sysconf(_SC_PAGESIZE)!=4096 || ia840f_dma_signals_block()) {
        fprintf(stderr,"FAIL page-size/signal precondition; no OPAE operation.\n");return 2;
    }
#define REQUIRE(call) do { if (!memory_api_ok((call), #call)) goto cleanup; } while (0)
    REQUIRE(fpgaGetProperties(NULL, &props));
    REQUIRE(fpgaPropertiesSetObjectType(props, FPGA_ACCELERATOR));
    REQUIRE(fpgaPropertiesSetGUID(props, guid));
    REQUIRE(fpgaPropertiesSetSegment(props, segment));
    REQUIRE(fpgaPropertiesSetBus(props, bus));
    REQUIRE(fpgaPropertiesSetDevice(props, device));
    REQUIRE(fpgaPropertiesSetFunction(props, function));
    REQUIRE(fpgaPropertiesSetVendorID(props, 0x8086));
    REQUIRE(fpgaPropertiesSetDeviceID(props, 0xbccf));
    REQUIRE(fpgaPropertiesSetSubsystemVendorID(props, 0x8086));
    REQUIRE(fpgaPropertiesSetSubsystemDeviceID(props, 0x1771));
    fpga_result enum_rc = fpgaEnumerate(&props, 1, &token, 1, &matches);
    if (!memory_api_ok(enum_rc, "fpgaEnumerate") ||
        !ahls_unique_match(enum_rc == FPGA_OK, matches)) {
        fprintf(stderr, "FAIL enumeration: expected one current memory AFU "
                "at %s, found %u. No fallback.\n", argv[2], matches);
        goto cleanup;
    }
    REQUIRE(fpgaOpen(token, &handle, 0));
    REQUIRE(fpgaMapMMIO(handle, 0, NULL));
    mapped = 1;
    for (size_t i = 0; i < 3; i++) {
        uint64_t value = 0;
        printf("FPGA Test identity read 0x%" PRIx64 "\n", identity_offsets[i]);
        fflush(stdout);
        REQUIRE(fpgaReadMMIO64(handle, 0, identity_offsets[i], &value));
        if (value != identity_words[i]) {
            fprintf(stderr, "FAIL identity at 0x%" PRIx64 ": 0x%016" PRIx64 "\n",
                    identity_offsets[i], value);
            goto cleanup;
        }
    }
    for (size_t i = 0; i < 4; i++) {
        printf("FPGA Test capability read 0x%" PRIx64 "\n", capability_offsets[i]);
        fflush(stdout);
        REQUIRE(fpgaReadMMIO64(handle, 0, capability_offsets[i], &words[i]));
    }
    if (!ia840f_dma_capabilities_decode(words, &capabilities)) {
        fprintf(stderr, "FAIL unsupported raw-capability ABI/geometry.\n");
        goto cleanup;
    }
    const uint64_t extra_offsets[]={0x20000,0x20008,0x20020,0x20028};
    const uint64_t extra_expected[]={UINT64_C(0x4d4d494f47524431),0,
        UINT64_C(0x484c53434f4d5031),UINT64_C(0x10000)};
    for(unsigned i=0;i<4;++i){
        uint64_t value=0;
        REQUIRE(fpgaReadMMIO64(handle,0,extra_offsets[i],&value));
        if(value!=extra_expected[i]){
            if(i==3 && (value&UINT64_C(0xff01)))kernel_uncertain=1;
            fprintf(stderr,"FAIL CAPS03 identity/clean baseline offset=0x%" PRIx64 " value=0x%" PRIx64 "\n",extra_offsets[i],value);
            goto cleanup;
        }
    }
    REQUIRE(fpgaReadMMIO64(handle,0,0x10000,&status));
    if((status>>16)!=5 || (status&UINT64_C(0xb005))!=0){
        kernel_uncertain=1;goto cleanup;
    }
    REQUIRE(fpgaReadMMIO64(handle,0,0x10030,&ticket));
    printf("FPGA Test discarded quiescent finish history=%" PRIu64 "\n",ticket);
    if(ticket>3 || !hls_wait_status(handle,0,&status))goto cleanup;
    REQUIRE(fpgaReadMMIO64(handle,0,0x10030,&ticket));
    REQUIRE(fpgaReadMMIO64(handle,0,0x10000,&status));
    if(ticket!=0 || !hls_status_matches(status,0))goto cleanup;
    for(unsigned i=0;i<2;++i){
        REQUIRE(fpgaPrepareBuffer(handle,4096,&buffers[i],&wsids[i],0));
        prepared++;
        /* Malformed successful ownership cannot be safely released twice.
         * No GO has occurred, but preserve both claimed resources for review. */
        if(i && (wsids[i]==wsids[0] || buffers[i]==buffers[0]))
            ia840f_dma_hold("duplicate allocation ownership before GO",&report);
        REQUIRE(fpgaGetIOAddress(handle,wsids[i],&iovas[i]));
        if(!buffers[i] || ((uintptr_t)buffers[i]&4095) ||
           (iovas[i]&4095) || iovas[i]>(UINT64_C(1)<<57)-4096){
            fprintf(stderr,"FAIL invalid mapped buffer/IOVA; no GO issued.\n");goto cleanup;
        }
    }
    if(buffers[0]==buffers[1] || wsids[0]==wsids[1] ||
       (iovas[0]<iovas[1]?iovas[1]-iovas[0]:iovas[0]-iovas[1])<4096){
        fprintf(stderr,"FAIL overlapping allocations; no GO issued.\n");goto cleanup;
    }
    const int32_t x[9]={-4,7,-9,0,11,-13,17,-19,23};
    const int32_t y[9]={1,-7,4,-5,-6,20,-8,3,-30};
    const int32_t expected[9]={-3,0,-5,-5,5,7,9,-16,-7};
    unsigned char result_span[192];
    for(unsigned i=0;i<4096;++i){
        expected_tx[i]=(unsigned char)(0xc3^(i*17));
        expected_rx[i]=(unsigned char)(0x5a^(i*29));
    }
    memset(expected_tx+64,0,128);
    for(unsigned i=0;i<9;++i){
        store_int32(expected_tx+64+4*i,x[i]);
        store_int32(expected_tx+128+4*i,y[i]);
    }
    memcpy(result_span,expected_tx+192,192);
    for(unsigned i=0;i<9;++i)store_int32(result_span+64+4*i,expected[i]);
    for(unsigned i=0;i<192;++i)expected_rx[64+i]=(unsigned char)~result_span[i];
    memcpy(buffers[0],expected_tx,4096);
    memcpy(buffers[1],expected_rx,4096);
    struct ia840f_dma_io io={handle,dma_read64,dma_write64,ia840f_dma_wait_step};
    const unsigned banks[]={0,0,1,1};
    const uint64_t offsets[]={0x10000,0x10040,0xffc0,0x10000};
    const unsigned host_offsets[]={64,128,192,256};
    const unsigned sizes[]={64,64,64,128};
    for(unsigned i=0;i<4;++i){
        if(!caps03_dma(&io,1,banks[i],offsets[i],iovas[0],host_offsets[i],sizes[i],
                      buffers,expected_tx,expected_rx,NULL,&report,i))goto cleanup;
    }
    const uint64_t args[]={0x10000,0x10040,0x10000,9};
    for(unsigned i=0;i<4;++i)REQUIRE(fpgaWriteMMIO64(handle,0,0x10080+8*i,args[i]));
    REQUIRE(fpgaReadMMIO64(handle,0,0x20008,&status));
    if(status)goto cleanup;
    /* Mark uncertainty before the possibly effective posted start write. */
    kernel_uncertain=1;
    REQUIRE(fpgaWriteMMIO64(handle,0,0x10008,1));
    /* This status read is also the monitor's producer_done observation. */
    if(!hls_wait_status(handle,2,&status))goto cleanup;
    REQUIRE(fpgaReadMMIO64(handle,0,0x10030,&ticket));
    if(ticket!=1)goto cleanup;
    if(!hls_wait_completion(handle,&completion))goto cleanup;
    printf("FPGA Test HLS ticket=%" PRIu64 " completion=0x%" PRIx64 "\n",ticket,completion);fflush(stdout);
    for(unsigned done=0,sequence=4;done<192;++sequence){
        unsigned chunk=ia840f_dma_segment_bytes(UINT64_C(0xffc0)+done,64+done,192-done);
        if(!chunk || !caps03_dma(&io,2,1,UINT64_C(0xffc0)+done,iovas[1],64+done,chunk,
            buffers,expected_tx,expected_rx,result_span+done,&report,sequence))goto cleanup;
        done+=chunk;
    }
    /* Full span comparison covers all nine exact signed results, 28 tail bytes,
     * leading/trailing DDR guards; each descriptor also checked both host pages. */
    if(!bytes_match((unsigned char*)buffers[1]+64,result_span,192))goto cleanup;
    REQUIRE(fpgaReadMMIO64(handle,0,0x20008,&status));
    REQUIRE(fpgaReadMMIO64(handle,0,0x20028,&completion));
    if(status || completion!=UINT64_C(0x10002) || !report.quiescent)goto cleanup;
    printf("FPGA Test HLS DATA PASS: integers=9 result_bytes=36 guard_bytes=156 descriptors=6\n");fflush(stdout);
    /* This clears application uncertainty, not a system/FLR drain certificate.
     * The inherited normal cleanup is eligible only under a separately admitted
     * runtime/teardown operation. Inert tests cannot qualify live VFIO teardown. */
    kernel_uncertain=0;
    exit_code=0;
cleanup:
    if(kernel_uncertain)ia840f_dma_hold("kernel outcome uncertain or post-start verification failed",&report);
    /* Reached only before GO, or after all issued descriptors were accounted for.
     * HOLD_UNKNOWN_DMA never returns here or into entry finalization. */
    while(prepared){--prepared;
        if(!memory_api_ok(fpgaReleaseBuffer(handle,wsids[prepared]),"fpgaReleaseBuffer"))exit_code=1;
    }
    if (mapped && !memory_api_ok(fpgaUnmapMMIO(handle, 0), "fpgaUnmapMMIO")) exit_code = 1;
    if (handle && !memory_api_ok(fpgaClose(handle), "fpgaClose")) exit_code = 1;
    if (token && !memory_api_ok(fpgaDestroyToken(&token), "fpgaDestroyToken")) exit_code = 1;
    if (props && !memory_api_ok(fpgaDestroyProperties(&props), "fpgaDestroyProperties")) exit_code = 1;
    if(exit_code==0){
        printf("FPGA Test CAPS03 frontend PASSED: integers=9 copied_span_bytes=192 descriptors=6 verified_payload_and_guards=1\n");
        printf("No simultaneous-bank, sustained or full-DDR qualification. Live VFIO lifecycle acceptance is separate.\n");
    }else fprintf(stderr,"FPGA Test CAPS03 frontend FAILED. No retry/reset/fallback.\n");
    return exit_code;
}

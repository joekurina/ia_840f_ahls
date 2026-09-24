/* CAPS01 one-bank, 64-byte host/DDR roundtrip. Preserve the inspection frontend.
 * Source/ownership contract: qualification/caps01-dma-host01/.
 * Separate strict startup protects signals before OPAE library initialization.
 * This is not authorization, a cancellation API, or full DDR qualification. */
#define _POSIX_C_SOURCE 200809L
#include "ahls_qualification_core.h"
#include "ia840f_dma_capabilities.h"
#include "ia840f_dma_lifetime.h"
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
static uint64_t address_pattern(unsigned bank,unsigned word)
{
    uint64_t x=(((uint64_t)bank<<34)+UINT64_C(0x10000)+8*word)^UINT64_C(0xd1b54a32d192ed03);
    x^=x>>30;x*=UINT64_C(0xbf58476d1ce4e5b9);
    x^=x>>27;x*=UINT64_C(0x94d049bb133111eb);
    return x^(x>>31);
}
static int bytes_match(const volatile unsigned char *actual,const unsigned char *expected,size_t n)
{
    for(size_t i=0;i<n;++i)if(actual[i]!=expected[i])return 0;
    return 1;
}

int main(int argc, char **argv)
{
    fpga_properties props = NULL;
    fpga_token token = NULL;
    fpga_handle handle = NULL;
    fpga_guid guid = {0x67,0x3c,0x03,0xa1,0xce,0xf3,0x4c,0x82,
                      0xbf,0x10,0xb1,0x2c,0x24,0x7d,0x97,0x18};
    const uint64_t identity_offsets[] = {0,8,16};
    const uint64_t identity_words[] = {UINT64_C(0x1000010000000000),
        UINT64_C(0xbf10b12c247d9718), UINT64_C(0x673c03a1cef34c82)};
    const uint64_t capability_offsets[] = {IA840F_DMA_CAP_ID_OFFSET,
        IA840F_DMA_CAP_GEOMETRY_OFFSET, IA840F_DMA_CAP_ADDRESS_OFFSET,
        IA840F_DMA_CAP_LIMITS_OFFSET};
    uint16_t segment;
    uint8_t bus, device, function;
    uint32_t matches = 0;
    uint64_t words[4] = {0};
    struct ia840f_dma_capabilities capabilities = {0};
    int mapped = 0, exit_code = 1;
    void *buffers[2]={NULL,NULL};
    uint64_t wsids[2]={0,0},iovas[2]={0,0};
    unsigned prepared=0;
    unsigned char expected_tx[4096],expected_rx[4096];
    struct ia840f_dma_report report={0};
    if (argc != 4 || strcmp(argv[1], "--roundtrip-qualified-memory-afu") ||
        (strcmp(argv[3],"0") && strcmp(argv[3],"1")) ||
        ahls_parse_bdf(argv[2], &segment, &bus, &device, &function)) {
        fprintf(stderr, "Usage (separately authorized hardware only): %s "
                "--roundtrip-qualified-memory-afu dddd:bb:dd.f 0|1\n", argv[0]);
        return 2;
    }
    unsigned bank=(unsigned)(argv[3][0]-'0');
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
    for(unsigned i=0;i<2;++i){
        REQUIRE(fpgaPrepareBuffer(handle,4096,&buffers[i],&wsids[i],0));
        prepared++;
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
    for(unsigned i=0;i<4096;++i){
        expected_tx[i]=(unsigned char)(0xc3^(i*17+bank*31));
        expected_rx[i]=(unsigned char)(0x5a^(i*29+bank*61));
    }
    for(unsigned word=0;word<8;++word){
        uint64_t value=address_pattern(bank,word);
        for(unsigned byte=0;byte<8;++byte)expected_tx[64+8*word+byte]=(unsigned char)(value>>(8*byte));
    }
    memcpy(buffers[0],expected_tx,4096);
    memcpy(buffers[1],expected_rx,4096);
    for(unsigned i=0;i<64;++i){
        ((unsigned char*)buffers[1])[64+i]=(unsigned char)~expected_tx[64+i];
        expected_rx[64+i]=expected_tx[64+i];
    }
    atomic_thread_fence(memory_order_seq_cst);
    struct ia840f_dma_io io={handle,dma_read64,dma_write64,ia840f_dma_wait_step};
    for(unsigned direction=0;direction<2;++direction){
        struct ia840f_dma_request q={.mode=direction+1,.bank=bank,.ddr_offset=0x10000,
            .iova_base=iovas[direction],.mapped_bytes=4096,.host_offset=64,.bytes=64,.max_polls=1000};
        printf("FPGA Test DMA submit bank=%u mode=%u bytes=64 ddr_offset=0x10000 iova=0x%016" PRIx64 "\n",
               bank,q.mode,q.iova_base+q.host_offset);fflush(stdout);
        enum ia840f_dma_result rc=ia840f_dma_transfer(&io,&q,&report);
        if(rc!=IA840F_DMA_OK){
            fprintf(stderr,"FAIL DMA rc=%d phase=%d status=0x%016" PRIx64 " polls=%u\n",
                    (int)rc,(int)report.phase,report.status_last,report.polls);
            if(report.go_may_have_been_issued && !report.quiescent)
                ia840f_dma_hold("descriptor outcome uncertain",&report);
            goto cleanup;
        }
        printf("FPGA Test DMA locally retired mode=%u status=0x%016" PRIx64 " polls=%u\n",
               q.mode,report.status_last,report.polls);fflush(stdout);
    }
    /* Local AXI retirement is not independently a PCIe physical-visibility fence.
     * Inspect only host RAM here. Poison differs in EVERY payload byte. */
    int visible=0;
    for(unsigned i=0;i<1000;++i){
        atomic_thread_fence(memory_order_seq_cst);
        if(bytes_match((volatile unsigned char*)buffers[1]+64,expected_rx+64,64)){visible=1;break;}
        if(i==999 || ia840f_dma_wait_step(NULL))break;
    }
    if(!visible)ia840f_dma_hold("host payload visibility/data mismatch",&report);
    if(!bytes_match(buffers[0],expected_tx,4096) || !bytes_match(buffers[1],expected_rx,4096))
        ia840f_dma_hold("source or guard corruption",&report);
    printf("FPGA Test data verified bank=%u bytes=64 source_page=4096 destination_page=4096\n",bank);
    exit_code=0;
cleanup:
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
        printf("FPGA Test DMA roundtrip PASSED: bank=%u bytes=64 transfers=2 verified_payload_and_guards=1\n",bank);
        printf("No kernel launch, simultaneous-bank, sustained or full-DDR qualification. Implicit VFIO resets apply.\n");
    }else fprintf(stderr,"FPGA Test DMA roundtrip FAILED. No retry/reset/fallback.\n");
    return exit_code;
}

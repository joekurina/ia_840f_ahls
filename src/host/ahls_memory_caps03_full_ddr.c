/* CAPS03 contiguous full-capacity DDR sweep, 128-byte page-contained descriptors.
 * Preserve the successful single-bank frontend. Sixteen GiB contiguous per logical bank; all writes before reads in one session.
 * Source/ownership contract: qualification/caps01-dma-burst01/; reuse caps01-dma-host01 contracts.
 * Separate strict startup protects signals before OPAE library initialization.
 * This is not authorization, a cancellation API, or full DDR qualification. */
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
#include <time.h>
#include <string.h>

/* The unchanged strict launcher's flag selects its module ABI. This module
 * performs only serial DDR DMA; it never writes an HLS start/reset register.
 * The native build uses the default corpus. Only inert tests reduce it. */
#ifndef CAPS03_FULL_LOCATIONS
#define CAPS03_FULL_LOCATIONS 134217728U
#endif
_Static_assert(CAPS03_FULL_LOCATIONS > 0 && CAPS03_FULL_LOCATIONS <= 134217728U,
               "bounded CAPS03 full-capacity corpus");
_Static_assert(sizeof(unsigned)>=4, "full sweep requires at least32-bit counters");
static uint64_t sweep_offset(unsigned index)
{
    return (uint64_t)index<<7;
}

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
/* First64 retry waits avoid the1ms sleep; then retain the existing sleep.
 * The caller resets this per descriptor. MMIO accesses remain in the core. */
static unsigned quick_waits;
static int dma_quick_wait(void *unused)
{
    if(quick_waits++<64)return 0;
    return ia840f_dma_wait_step(unused);
}
static uint64_t address_pattern(unsigned bank,uint64_t offset,unsigned word)
{
    uint64_t x=(((uint64_t)bank<<34)+offset+8*word)^UINT64_C(0xa54ff53a5f1d36f1);
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
    const unsigned locations=CAPS03_FULL_LOCATIONS;
    unsigned descriptors=0;
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
    int mapped = 0, exit_code = 1;
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
    for(unsigned i=0;i<4096;++i){
        expected_tx[i]=(unsigned char)(0xc3^(i*17));
        expected_rx[i]=(unsigned char)(0x5a^(i*29));
    }
    memcpy(buffers[0],expected_tx,4096);
    memcpy(buffers[1],expected_rx,4096);
    struct ia840f_dma_io io={handle,dma_read64,dma_write64,dma_quick_wait};
    /* W0 then W1 then R0 then R1. Every128-byte line in each full
     * bank-local16GiB aperture. No sparse physical-row mapping assumption. */
    struct timespec began,finished;
    if(clock_gettime(CLOCK_MONOTONIC,&began))goto cleanup;
    for(unsigned sequence=0;sequence<4*locations;++sequence){
        unsigned index=sequence%locations;
        unsigned bank=(sequence/locations)%2;
        unsigned direction=sequence/(2*locations);
        unsigned bytes=128;
        uint64_t offset=sweep_offset(index);
        unsigned char payload[3968];
        for(unsigned word=0;word<bytes/8;++word){
            uint64_t value=address_pattern(bank,offset,word);
            for(unsigned byte=0;byte<8;++byte)
                payload[8*word+byte]=(unsigned char)(value>>(8*byte));
        }
        if(direction==0){
            memcpy(expected_tx+64,payload,bytes);
            memcpy((unsigned char*)buffers[0]+64,payload,bytes);
        }else{
            for(unsigned i=0;i<bytes;++i){
                expected_rx[64+i]=(unsigned char)~payload[i];
                ((unsigned char*)buffers[1])[64+i]=expected_rx[64+i];
            }
        }
        atomic_thread_fence(memory_order_seq_cst);
        for(unsigned done=0;done<bytes;){
            unsigned chunk=ia840f_dma_segment_bytes(offset+done,64+done,bytes-done);
            if(!chunk)ia840f_dma_hold("invalid segment after allocation",&report);
            struct ia840f_dma_request q={.mode=direction+1,.bank=bank,
                .ddr_offset=offset+done,.iova_base=iovas[direction],.mapped_bytes=4096,
                .host_offset=64+done,.bytes=chunk,.max_polls=1064};
            if((descriptors%1048576)==0){
                printf("FPGA Test DDR progress descriptor=%u bank=%u mode=%u ddr_offset=0x%" PRIx64 "\n",
                       descriptors,bank,q.mode,q.ddr_offset);fflush(stdout);
            }
            quick_waits=0;
            enum ia840f_dma_result rc=ia840f_dma_transfer(&io,&q,&report);
            if(rc!=IA840F_DMA_OK){
                fprintf(stderr,"FAIL DMA descriptor=%u bank=%u mode=%u ddr=0x%" PRIx64 " rc=%d phase=%d status=0x%016" PRIx64 " polls=%u\n",
                        descriptors,bank,q.mode,q.ddr_offset,(int)rc,(int)report.phase,report.status_last,report.polls);
                if(report.go_may_have_been_issued && !report.quiescent)
                    ia840f_dma_hold("descriptor outcome uncertain",&report);
                goto cleanup;
            }
            if(direction==1){
                int visible=0;
                for(unsigned i=0;i<1000;++i){
                    atomic_thread_fence(memory_order_seq_cst);
                    if(bytes_match((volatile unsigned char*)buffers[1]+64+done,payload+done,chunk)){
                        visible=1;break;
                    }
                    if(i==999 || ia840f_dma_wait_step(NULL))break;
                }
                if(!visible){
                    for(unsigned j=0;j<chunk;++j)if(((volatile unsigned char*)buffers[1])[64+done+j]!=payload[done+j]){
                        fprintf(stderr,"FAIL data descriptor=%u bank=%u ddr=0x%" PRIx64 " byte=%u actual=%u expected=%u\n",
                                descriptors,bank,q.ddr_offset,j,((volatile unsigned char*)buffers[1])[64+done+j],payload[done+j]);break;
                    }
                    ia840f_dma_hold("dense host payload mismatch",&report);
                }
                /* Unreceived bytes remain poison in both RAM and expectation. */
                memcpy(expected_rx+64+done,payload+done,chunk);
            }
            if(!bytes_match(buffers[0],expected_tx,4096) || !bytes_match(buffers[1],expected_rx,4096))
                ia840f_dma_hold("source or guard corruption",&report);

            ++descriptors;done+=chunk;
        }
        if((sequence+1)%locations==0){
            printf("FPGA Test DDR phase verified mode=%u bank=%u bytes=%" PRIu64 " descriptors=%u source_page=4096 destination_page=4096\n",
                   direction+1,bank,(uint64_t)locations*128U,descriptors);fflush(stdout);
        }
    }
    if(descriptors!=4*locations)ia840f_dma_hold("dense descriptor count mismatch",&report);
    if(clock_gettime(CLOCK_MONOTONIC,&finished))goto cleanup;
    printf("FPGA Test DDR elapsed_seconds=%.9f\n",
           (double)(finished.tv_sec-began.tv_sec)+(double)(finished.tv_nsec-began.tv_nsec)/1e9);
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
        printf("FPGA Test CAPS03 FULL DDR PASSED: banks=2 locations_per_bank=%u bytes_per_bank=%" PRIu64 " descriptors=%u verified_payload_and_guards=1\n",locations,(uint64_t)locations*128U,descriptors);
        printf("No kernel launch or simultaneous-bank qualification; full DDR gate still requires concurrent channels. Implicit VFIO resets apply.\n");
    }else fprintf(stderr,"FPGA Test DMA bursts FAILED. No retry/reset/fallback.\n");
    return exit_code;
}

/* Additive fixed-size streaming HLS test on the unchanged CAPS03 image.
 * Reuse the original helpers and initialization/cleanup. The copied DMA helper
 * changes progress logging only to remain below the existing supervisor cap. */
#pragma push_macro("main")
#undef main
#define main caps03_original_main
#include "ahls_memory_caps03.c"
#undef main
#pragma pop_macro("main")

static int caps03_bulk_dma(const struct ia840f_dma_io *io,unsigned mode,unsigned bank,
    uint64_t ddr,uint64_t iova,unsigned host,unsigned bytes,
    void **buffers,unsigned char *expected_tx,unsigned char *expected_rx,
    const unsigned char *incoming,struct ia840f_dma_report *report,unsigned sequence)
{
    if(ia840f_dma_segment_bytes(ddr,host,bytes)!=bytes)return 0;
    struct ia840f_dma_request request={.mode=mode,.bank=bank,.ddr_offset=ddr,
        .iova_base=iova,.mapped_bytes=4096,.host_offset=host,.bytes=bytes,.max_polls=1000};
    if(sequence%128==0){
        printf("FPGA Test DMA submit sequence=%u mode=%u bank=%u bytes=%u ddr=0x%" PRIx64 "\n",
               sequence,mode,bank,bytes,ddr);fflush(stdout);
    }
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
    if(sequence%128==0){
        printf("FPGA Test DMA retired and host pages verified sequence=%u\n",sequence);fflush(stdout);
    }
    return 1;
}

enum { CAPS03_BULK_N=65536, CAPS03_BULK_BYTES=4*CAPS03_BULK_N,
       CAPS03_BULK_SPAN=CAPS03_BULK_BYTES+128, CAPS03_BULK_TILE=3968 };

/* Byte-exact little-endian reference. Regions0/1 are X/Y. Region2 initializes
 * Z to the complement of every expected output byte; region3 is copyback.
 * The first/last64 bytes of regions2/3 are identical DDR guard patterns. */
static unsigned char caps03_bulk_byte(unsigned region,unsigned offset)
{
    unsigned word;
    if(region<2){
        unsigned i=offset/4;
        word=region ? 2*i+1 : i;
    }else{
        if(offset<64 || offset>=64+CAPS03_BULK_BYTES)
            return (unsigned char)(0xc3^(offset*17));
        word=3*((offset-64)/4)+1;
    }
    unsigned char b=(unsigned char)(word>>(8*(offset%4)));
    return region==2 ? (unsigned char)~b : b;
}

static int caps03_bulk_region(const struct ia840f_dma_io *io,
    void **buffers,const uint64_t *iovas,unsigned char *tx,unsigned char *rx,
    struct ia840f_dma_report *report,unsigned region,unsigned *sequence)
{
    if(region>3)return 0;
    const uint64_t bases[]={0x10000,0x60000,0xffc0,0xffc0};
    const unsigned sizes[]={CAPS03_BULK_BYTES,CAPS03_BULK_BYTES,
                            CAPS03_BULK_SPAN,CAPS03_BULK_SPAN};
    unsigned mode=region==3 ? 2 : 1,bank=region<2 ? 0 : 1;
    unsigned char expected[4096];
    for(unsigned offset=0;offset<sizes[region];){
        unsigned tile=sizes[region]-offset;
        if(tile>CAPS03_BULK_TILE)tile=CAPS03_BULK_TILE;
        for(unsigned j=0;j<4096;++j){
            tx[j]=(unsigned char)(0xa5^(j*19)^region);
            rx[j]=(unsigned char)(0x5a^(j*29)^region);
        }
        for(unsigned j=0;j<tile;++j){
            unsigned char b=caps03_bulk_byte(region,offset+j);
            if(mode==1)tx[64+j]=b;
            else{expected[64+j]=b;rx[64+j]=(unsigned char)~b;}
        }
        /* Reuse only after the preceding descriptor and both host pages passed. */
        memcpy(buffers[0],tx,4096);memcpy(buffers[1],rx,4096);
        for(unsigned done=0;done<tile;){
            unsigned bytes=ia840f_dma_segment_bytes(bases[region]+offset+done,64+done,tile-done);
            if(!bytes || !caps03_bulk_dma(io,mode,bank,bases[region]+offset+done,
                iovas[mode-1],64+done,bytes,buffers,tx,rx,
                mode==2 ? expected+64+done : NULL,report,*sequence))return 0;
            ++*sequence;done+=bytes;
        }
        if(mode==2 && !bytes_match((unsigned char*)buffers[1]+64,expected+64,tile))return 0;
        offset+=tile;
        printf("FPGA Test BULK tile verified region=%u bytes=%u descriptors=%u\n",region,offset,*sequence);
        fflush(stdout);
    }
    return 1;
}

static int caps03_bulk_run(fpga_handle handle,const struct ia840f_dma_io *io,
    void **buffers,const uint64_t *iovas,unsigned char *tx,unsigned char *rx,
    struct ia840f_dma_report *report,int *kernel_uncertain,unsigned *sequence)
{
    uint64_t status=0,ticket=0,completion=0;
    for(unsigned region=0;region<3;++region)
        if(!caps03_bulk_region(io,buffers,iovas,tx,rx,report,region,sequence))return 0;
    if(!hls_wait_status(handle,0,&status) ||
       !memory_api_ok(fpgaReadMMIO64(handle,0,0x10030,&ticket),"quiescent finish") || ticket)return 0;
    const uint64_t args[]={0x10000,0x60000,0x10000,CAPS03_BULK_N};
    for(unsigned i=0;i<4;++i)
        if(!memory_api_ok(fpgaWriteMMIO64(handle,0,0x10080+8*i,args[i]),"HLS argument"))return 0;
    if(!memory_api_ok(fpgaReadMMIO64(handle,0,0x20008,&status),"guard before start") || status)return 0;
    *kernel_uncertain=1;
    if(!memory_api_ok(fpgaWriteMMIO64(handle,0,0x10008,1),"HLS start") ||
       !hls_wait_status(handle,2,&status) ||
       !memory_api_ok(fpgaReadMMIO64(handle,0,0x10030,&ticket),"HLS finish") || ticket!=1 ||
       !hls_wait_completion(handle,&completion))return 0;
    printf("FPGA Test HLS ticket=%" PRIu64 " completion=0x%" PRIx64 "\n",ticket,completion);fflush(stdout);
    if(!caps03_bulk_region(io,buffers,iovas,tx,rx,report,3,sequence))return 0;
    if(!memory_api_ok(fpgaReadMMIO64(handle,0,0x20008,&status),"guard after copyback") ||
       !memory_api_ok(fpgaReadMMIO64(handle,0,0x20028,&completion),"completion after copyback") ||
       status || completion!=UINT64_C(0x10002) || !report->quiescent || *sequence!=8324)return 0;
    *kernel_uncertain=0;
    return 1;
}

int main(int argc,char **argv)
{
    unsigned sequence=0;
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
    uint64_t status=0,ticket=0;
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
    struct ia840f_dma_io io={handle,dma_read64,dma_write64,ia840f_dma_wait_step};
    if(!caps03_bulk_run(handle,&io,buffers,iovas,expected_tx,expected_rx,&report,
        &kernel_uncertain,&sequence))goto cleanup;
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
        printf("FPGA Test CAPS03 BULK PASSED: integers=%u result_bytes=%u guard_bytes=128 descriptors=%u verified_payload_and_guards=1\n",CAPS03_BULK_N,CAPS03_BULK_BYTES,sequence);
        printf("Source-supported concurrent streaming workload; no measured wire overlap or full-DDR/minutes claim. Lifecycle acceptance is separate.\n");
    }else fprintf(stderr,"FPGA Test CAPS03 BULK FAILED. No retry/reset/fallback.\n");
    return exit_code;
}

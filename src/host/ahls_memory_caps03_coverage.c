/* Additive finite repeated/tail/page-boundary coverage on the unchanged CAPS03 image.
 * Preserve the original frontend and reuse its actual DMA/completion/ownership helpers.
 */
#pragma push_macro("main")
#undef main
#define main caps03_original_main
#include "ahls_memory_caps03.c"
#undef main
#pragma pop_macro("main")

static int caps03_coverage_case(fpga_handle handle, const struct ia840f_dma_io *io,
    void **buffers, const uint64_t *iovas, unsigned char *tx, unsigned char *rx,
    struct ia840f_dma_report *report, int *kernel_uncertain,
    unsigned index, unsigned n, unsigned layout, unsigned *sequence)
{
    unsigned padded=((n*4+63)/64)*64, span=padded+128;
    unsigned hx=64, hy=hx+padded, hz=hy+padded;
    uint64_t x=layout ? UINT64_C(0x1ffc0) : UINT64_C(0x10000);
    uint64_t y=layout ? UINT64_C(0x23fc0) : UINT64_C(0x14000);
    uint64_t z=layout ? UINT64_C(0x2ffc0) : UINT64_C(0x18000);
    unsigned char expected[4096];
    uint64_t status=0,ticket=0,completion=0;
    if(!n || n>257 || layout>1 || hz+span>4096 || 64+span>4096)return 0;
    if(!hls_wait_status(handle,0,&status) ||
       !memory_api_ok(fpgaReadMMIO64(handle,0,0x10030,&ticket),"quiescent finish") || ticket)
        return 0;
    for(unsigned i=0;i<4096;++i){
        tx[i]=(unsigned char)(0xc3^(i*17)^(index*43));
        rx[i]=(unsigned char)(0x5a^(i*29)^(index*61));
    }
    memcpy(expected,tx+hz,span);
    for(unsigned i=0;i<n;++i){
        int32_t a=(int32_t)((i*37+index*131)%200003)-100001;
        int32_t b=(i%4==0) ? -a : (int32_t)((i*53+index*97)%100003)-50001;
        store_int32(tx+hx+4*i,a);
        store_int32(tx+hy+4*i,b);
        store_int32(expected+64+4*i,a+b);
    }
    for(unsigned i=0;i<span;++i)rx[64+i]=(unsigned char)~expected[i];
    memcpy(buffers[0],tx,4096);memcpy(buffers[1],rx,4096);
    const uint64_t addresses[]={x,y,z-64};
    const unsigned banks[]={0,0,1},hosts[]={hx,hy,hz},lengths[]={padded,padded,span};
    for(unsigned region=0;region<3;++region){
        for(unsigned done=0;done<lengths[region];){
            unsigned chunk=ia840f_dma_segment_bytes(addresses[region]+done,hosts[region]+done,lengths[region]-done);
            if(!chunk || !caps03_dma(io,1,banks[region],addresses[region]+done,iovas[0],
                hosts[region]+done,chunk,buffers,tx,rx,NULL,report,(*sequence)++))return 0;
            done+=chunk;
        }
    }
    const uint64_t args[]={x,y,z,n};
    for(unsigned i=0;i<4;++i)
        if(!memory_api_ok(fpgaWriteMMIO64(handle,0,0x10080+8*i,args[i]),"HLS argument"))return 0;
    if(!memory_api_ok(fpgaReadMMIO64(handle,0,0x20008,&status),"guard before start") || status)return 0;
    *kernel_uncertain=1;
    if(!memory_api_ok(fpgaWriteMMIO64(handle,0,0x10008,1),"HLS start") ||
       !hls_wait_status(handle,2,&status) ||
       !memory_api_ok(fpgaReadMMIO64(handle,0,0x10030,&ticket),"HLS finish") || ticket!=1 ||
       !hls_wait_completion(handle,&completion))return 0;
    for(unsigned done=0;done<span;){
        unsigned chunk=ia840f_dma_segment_bytes(z-64+done,64+done,span-done);
        if(!chunk || !caps03_dma(io,2,1,z-64+done,iovas[1],64+done,chunk,
            buffers,tx,rx,expected+done,report,(*sequence)++))return 0;
        done+=chunk;
    }
    if(!bytes_match((unsigned char*)buffers[1]+64,expected,span) ||
       !memory_api_ok(fpgaReadMMIO64(handle,0,0x20008,&status),"guard after copyback") ||
       !memory_api_ok(fpgaReadMMIO64(handle,0,0x20028,&completion),"completion after copyback") ||
       status || completion!=UINT64_C(0x10002) || !report->quiescent)return 0;
    printf("FPGA Test HLS CASE PASS: case=%u n=%u layout=%u result_bytes=%u guard_bytes=%u descriptors=%u\n",
        index,n,layout,4*n,span-4*n,*sequence);fflush(stdout);
    *kernel_uncertain=0;
    return 1;
}

int main(int argc,char **argv)
{
    unsigned cases_passed=0,integers_passed=0,sequence=0;
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
    const unsigned lengths[]={1,8,9,16,17,31,32,33,63,64,65,127,128,129,255,256,257};
    struct ia840f_dma_io io={handle,dma_read64,dma_write64,ia840f_dma_wait_step};
    for(unsigned layout=0;layout<2;++layout){
        for(unsigned j=0;j<sizeof(lengths)/sizeof(lengths[0]);++j){
            if(!caps03_coverage_case(handle,&io,buffers,iovas,expected_tx,expected_rx,&report,
                &kernel_uncertain,cases_passed,lengths[j],layout,&sequence))goto cleanup;
            ++cases_passed;integers_passed+=lengths[j];
        }
    }
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
        printf("FPGA Test CAPS03 COVERAGE PASSED: cases=%u integers=%u descriptors=%u verified_payload_and_guards=1\n", cases_passed, integers_passed, sequence);
        printf("No simultaneous-bank, sustained or full-DDR qualification. Live VFIO lifecycle acceptance is separate.\n");
    }else fprintf(stderr,"FPGA Test CAPS03 COVERAGE FAILED. No retry/reset/fallback.\n");
    return exit_code;
}

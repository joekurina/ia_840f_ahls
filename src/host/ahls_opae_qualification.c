/* Explicit OPAE-only frontend. Building is not authorization to run.
 * Even library initialization/enumeration may access hardware. No raw BAR mode.
 * Review qualification/ahls-host-offline-01/REPORT.md before any live invocation.
 */
#define _POSIX_C_SOURCE 200809L
#include "ahls_qualification_core.h"
#include <opae/access.h>
#include <opae/enum.h>
#include <opae/properties.h>
#include <opae/mmio.h>
#include <opae/utils.h>
#include <stdio.h>
#include <string.h>
#include <time.h>
#include <inttypes.h>
#include <errno.h>

static int api_ok(fpga_result rc,const char *op)
{
    if (rc==FPGA_OK) return 1;
    fprintf(stderr,"FAIL %s: %s (%d)\n",op,fpgaErrStr(rc),(int)rc);
    return 0;
}
static int opae_read(void *ctx,uint64_t off,uint64_t *v)
{
    return api_ok(fpgaReadMMIO64((fpga_handle)ctx,0,off,v),"fpgaReadMMIO64")?0:-1;
}
static int opae_write(void *ctx,uint64_t off,uint64_t v)
{
    return api_ok(fpgaWriteMMIO64((fpga_handle)ctx,0,off,v),"fpgaWriteMMIO64")?0:-1;
}
static int clock_ms(void *ctx,uint64_t *v)
{
    struct timespec t;(void)ctx;
    if(clock_gettime(CLOCK_MONOTONIC,&t))return -1;
    *v=(uint64_t)t.tv_sec*1000+(uint64_t)t.tv_nsec/1000000;
    return 0;
}
static int pause_ms(void *ctx,unsigned ms)
{
    struct timespec t={ms/1000,(long)(ms%1000)*1000000};(void)ctx;
    return nanosleep(&t,NULL)==0?0:-1;
}

int main(int argc,char **argv)
{
    fpga_properties props=NULL;
    fpga_token token=NULL;
    fpga_handle handle=NULL;
    fpga_guid guid={0x67,0xbc,0x26,0x6a,0x56,0xf7,0x44,0x0a,
                    0xbb,0x75,0x12,0xb5,0xf4,0x46,0xd8,0x42};
    uint16_t segment;uint8_t bus,dev,func;
    uint32_t matches=0;int mapped=0,exit_code=1;
    if(argc!=3 || strcmp(argv[1],"--run-qualified-csr-test") ||
       ahls_parse_bdf(argv[2],&segment,&bus,&dev,&func)) {
        fprintf(stderr,"Usage (separately authorized hardware only): %s --run-qualified-csr-test dddd:bb:dd.f\n",argv[0]);
        return 2;
    }
#define REQUIRE(call) do { if(!api_ok((call),#call))goto cleanup; } while(0)
    REQUIRE(fpgaGetProperties(NULL,&props));
    REQUIRE(fpgaPropertiesSetObjectType(props,FPGA_ACCELERATOR));
    REQUIRE(fpgaPropertiesSetGUID(props,guid));
    REQUIRE(fpgaPropertiesSetSegment(props,segment));
    REQUIRE(fpgaPropertiesSetBus(props,bus));
    REQUIRE(fpgaPropertiesSetDevice(props,dev));
    REQUIRE(fpgaPropertiesSetFunction(props,func));
    REQUIRE(fpgaPropertiesSetVendorID(props,0x8086));
    REQUIRE(fpgaPropertiesSetDeviceID(props,0xbccf));
    fpga_result enum_rc=fpgaEnumerate(&props,1,&token,1,&matches);
    if(!api_ok(enum_rc,"fpgaEnumerate") || !ahls_unique_match(enum_rc==FPGA_OK,matches)) {
        fprintf(stderr,"FAIL enumeration: exactly one AHLS VF required at %s; matches=%u. No fallback.\n",argv[2],matches);
        goto cleanup;
    }
    REQUIRE(fpgaOpen(token,&handle,0));
    REQUIRE(fpgaMapMMIO(handle,0,NULL));mapped=1;
    struct ahls_io io={handle,opae_read,opae_write,clock_ms,pause_ms};
    int rc=ahls_verify_identity(&io);
    if(rc) {fprintf(stderr,"FAIL AFU identity: %d\n",rc);goto cleanup;}
    for(size_t i=0;i<ahls_case_count;i++) {
        uint32_t value=0,expected=0;
        if(ahls_reference(ahls_cases[i],&expected))goto cleanup;
        printf("FPGA Test case %zu: a=%"PRId32" b=%"PRId32" mode=%"PRId32"\n",
               i,ahls_cases[i].a,ahls_cases[i].b,ahls_cases[i].mode);fflush(stdout);
        rc=ahls_run_case(&io,ahls_cases[i],3000,&value);
        if(rc) {
            fprintf(stderr,"FAIL case %zu rc=%d observed=0x%08"PRIx32" expected=0x%08"PRIx32". Stop; no retry/reset.\n",i,rc,value,expected);
            goto cleanup;
        }
        printf("PASS checksum=0x%08"PRIx32"; fresh completion\n",value);fflush(stdout);
    }
    exit_code=0;
cleanup:
    /* This CSR-only AFU issues no DMA. Backend close behavior still belongs in
     * the live-operation review; cleanup is not a reset/recovery procedure. */
    if(mapped && !api_ok(fpgaUnmapMMIO(handle,0),"fpgaUnmapMMIO"))exit_code=1;
    if(handle && !api_ok(fpgaClose(handle),"fpgaClose"))exit_code=1;
    if(token && !api_ok(fpgaDestroyToken(&token),"fpgaDestroyToken"))exit_code=1;
    if(props && !api_ok(fpgaDestroyProperties(&props),"fpgaDestroyProperties"))exit_code=1;
    printf("FPGA Test %s (CSR/numerical only; DDR and transfers not covered)\n",exit_code?"FAILED":"PASSED");
    return exit_code;
}

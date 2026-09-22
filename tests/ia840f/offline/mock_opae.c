/* API-link fixture: compiled against captured installed OPAE headers.
 * Implements every referenced API locally. NEVER links libopae-c. */
#include "ahls_qualification_core.h"
#include <opae/access.h>
#include <opae/enum.h>
#include <opae/properties.h>
#include <opae/mmio.h>
#include <opae/utils.h>
#include <assert.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
static int object,props_live,token_live,handle_live,mapped,started;
static unsigned calls,failed,starts,result_reads,polls,filters;
static uint64_t finish_count=1;
static unsigned fail_at(void){const char *s=getenv("MOCK_FAIL_AT");return s?(unsigned)strtoul(s,NULL,10):0;}
static const char *scenario(void){const char *s=getenv("MOCK_SCENARIO");return s?s:"pass";}
static fpga_result step(const char *s,int cleanup)
{
    calls++;
    assert(!failed || cleanup);
    if(calls==fail_at()) {failed=1;printf("INJECT %u %s\n",calls,s);return FPGA_EXCEPTION;}
    return FPGA_OK;
}
static void verify_exit(void)
{
    if(!failed)assert(!props_live && !token_live && !handle_live && !mapped);
    if(!strcmp(scenario(),"zero") || !strcmp(scenario(),"multiple"))assert(!starts && !result_reads);
    if(!strcmp(scenario(),"pass") && !failed)assert(starts==12 && result_reads==12);
    printf("MOCK_SUMMARY calls=%u starts=%u result_reads=%u failure_injected=%u\n",calls,starts,result_reads,failed);
}
#define STEP(cleanup) do{fpga_result rc=step(__func__,cleanup);if(rc!=FPGA_OK)return rc;}while(0)
fpga_result fpgaGetProperties(fpga_token token,fpga_properties *p)
{
    assert(!token);atexit(verify_exit);STEP(0);*p=&object;props_live=1;return FPGA_OK;
}
fpga_result fpgaDestroyProperties(fpga_properties *p){STEP(1);props_live=0;*p=NULL;return FPGA_OK;}
#define SETTER(name,type,test) fpga_result name(fpga_properties p,type v){assert(p && props_live);STEP(0);assert(test);filters++;return FPGA_OK;}
SETTER(fpgaPropertiesSetObjectType,fpga_objtype,v==FPGA_ACCELERATOR)
SETTER(fpgaPropertiesSetSegment,uint16_t,v==0)
SETTER(fpgaPropertiesSetBus,uint8_t,v==0xab)
SETTER(fpgaPropertiesSetDevice,uint8_t,v==0x1f)
SETTER(fpgaPropertiesSetFunction,uint8_t,v==7)
SETTER(fpgaPropertiesSetVendorID,uint16_t,v==0x8086)
SETTER(fpgaPropertiesSetDeviceID,uint16_t,v==0xbccf)
fpga_result fpgaPropertiesSetGUID(fpga_properties p,fpga_guid v)
{
    static const unsigned char uuid[]={0x67,0xbc,0x26,0x6a,0x56,0xf7,0x44,0x0a,0xbb,0x75,0x12,0xb5,0xf4,0x46,0xd8,0x42};
    assert(p && props_live);STEP(0);assert(!memcmp(v,uuid,16));filters++;return FPGA_OK;
}
fpga_result fpgaEnumerate(const fpga_properties *f,uint32_t nf,fpga_token *t,uint32_t max,uint32_t *n)
{
    STEP(0);assert(f && nf==1 && max==1 && filters==8);
    if(!strcmp(scenario(),"zero")){*n=0;return FPGA_OK;}
    *n=!strcmp(scenario(),"multiple")?2:1;*t=&object;token_live=1;return FPGA_OK;
}
fpga_result fpgaDestroyToken(fpga_token *t){STEP(1);token_live=0;*t=NULL;return FPGA_OK;}
fpga_result fpgaOpen(fpga_token t,fpga_handle *h,int flags){STEP(0);assert(t && token_live && !flags);*h=&object;handle_live=1;return FPGA_OK;}
fpga_result fpgaClose(fpga_handle h){STEP(1);assert(h && handle_live);handle_live=0;return FPGA_OK;}
fpga_result fpgaMapMMIO(fpga_handle h,uint32_t n,uint64_t **p){STEP(0);assert(h && !n && !p);mapped=1;return FPGA_OK;}
fpga_result fpgaUnmapMMIO(fpga_handle h,uint32_t n){STEP(1);assert(h && !n && mapped);mapped=0;return FPGA_OK;}
fpga_result fpgaWriteMMIO64(fpga_handle h,uint32_t n,uint64_t off,uint64_t v)
{
    STEP(0);assert(h && mapped && !n && !(off&7));
    assert(starts<ahls_case_count);
    struct ahls_case c=ahls_cases[starts];
    if(off==AHLS_ARGS)assert(v==(((uint64_t)(uint32_t)c.b<<32)|(uint32_t)c.a));
    else if(off==AHLS_MODE)assert(v==(uint32_t)c.mode);
    else {assert(off==AHLS_START && v==1 && !started);started=1;starts++;polls=0;}
    return FPGA_OK;
}
fpga_result fpgaReadMMIO64(fpga_handle h,uint32_t n,uint64_t off,uint64_t *v)
{
    static const uint32_t results[]={8,16,48,48,0,0xfffffff0,0x700,0xff00,0,0,16,8};
    STEP(0);assert(h && mapped && !n && !(off&7));
    switch(off) {
        case 0:*v=UINT64_C(0x1000010000000000);break;
        case 8:*v=UINT64_C(0xbb7512b5f446d842);break;
        case 16:*v=UINT64_C(0x67bc266a56f7440a);break;
        case AHLS_STATUS:*v=5<<16;break;
        case AHLS_FINISH:
            if(started && ++polls==3){finish_count=1;started=0;}
            *v=finish_count;finish_count=0;break;
        case AHLS_RESULT:
            assert(starts && !started);*v=results[starts-1];result_reads++;
            if(!strcmp(scenario(),"wrong_result"))*v^=1;
            break;
        default:assert(!"unsupported offset");
    }
    if(!strcmp(scenario(),"wrong_uuid") && off==8)*v=0;
    return FPGA_OK;
}
const char *fpgaErrStr(fpga_result rc){(void)rc;return "inert injected API error";}

/* Local API symbols only, using captured installed headers. No libopae link. */
#include "ahls_qualification_core.h"
#include <opae/access.h>
#include <opae/enum.h>
#include <opae/properties.h>
#include <opae/mmio.h>
#include <opae/utils.h>
#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
static int prop,token,handle;
static unsigned live,failed_cleanup,calls,filters,reads,opens,maps,failed;
static const uint64_t offsets[]={0,8,16,0x98,0xa0,0xa8,0xb0};
static const uint64_t words[]={UINT64_C(0x1000010000000000),
    UINT64_C(0xbf10b12c247d9718),UINT64_C(0x673c03a1cef34c82),
    UINT64_C(0x49413834444d0001),UINT64_C(0x0002001000200200),
    UINT64_C(0x0008004014393922),UINT64_C(0x000000060001ff00)};
static int number(const char *key,int fallback){const char *s=getenv(key);return s?atoi(s):fallback;}
static const char *scenario(void){const char *s=getenv("MEMORY_CASE");return s?s:"pass";}
static fpga_result step(const char *name,unsigned cleanup)
{
    assert(!failed || cleanup);calls++;
    printf("API %u %s\n",calls,name);
    if(calls==(unsigned)number("MEMORY_FAIL_AT",0)){
        failed=1;failed_cleanup|=cleanup;return FPGA_EXCEPTION;
    }
    return FPGA_OK;
}
#define STEP(cleanup) do{fpga_result rc=step(__func__,cleanup);if(rc!=FPGA_OK)return rc;}while(0)
static void verify_exit(void)
{
    /* Each acquired resource must be cleaned up, except its injected destructor. */
    assert(live==failed_cleanup);
    assert(reads<=7 && opens<=1 && maps<=1);
    printf("INERT_MEMORY_SUMMARY calls=%u filters=%u reads=%u opens=%u maps=%u failed=%u remaining=%u allowed_remaining=%u\n",
           calls,filters,reads,opens,maps,failed,live,failed_cleanup);
}
fpga_result fpgaGetProperties(fpga_token t,fpga_properties *p)
{
    assert(!t && p);assert(atexit(verify_exit)==0);STEP(0);*p=&prop;live|=1;return FPGA_OK;
}
#define SETTER(name,type,test) fpga_result name(fpga_properties p,type v){assert(p==&prop && (live&1));STEP(0);assert(test);filters++;return FPGA_OK;}
SETTER(fpgaPropertiesSetObjectType,fpga_objtype,v==FPGA_ACCELERATOR)
SETTER(fpgaPropertiesSetSegment,uint16_t,v==0)
SETTER(fpgaPropertiesSetBus,uint8_t,v==0xab)
SETTER(fpgaPropertiesSetDevice,uint8_t,v==0x1f)
SETTER(fpgaPropertiesSetFunction,uint8_t,v==7)
SETTER(fpgaPropertiesSetVendorID,uint16_t,v==0x8086)
SETTER(fpgaPropertiesSetDeviceID,uint16_t,v==0xbccf)
SETTER(fpgaPropertiesSetSubsystemVendorID,uint16_t,v==0x8086)
SETTER(fpgaPropertiesSetSubsystemDeviceID,uint16_t,v==0x1771)
fpga_result fpgaPropertiesSetGUID(fpga_properties p,fpga_guid v)
{
    static const unsigned char uuid[]={0x67,0x3c,0x03,0xa1,0xce,0xf3,0x4c,0x82,0xbf,0x10,0xb1,0x2c,0x24,0x7d,0x97,0x18};
    assert(p==&prop && (live&1));STEP(0);assert(!memcmp(v,uuid,16));filters++;return FPGA_OK;
}
fpga_result fpgaEnumerate(const fpga_properties *f,uint32_t nf,fpga_token *t,uint32_t max,uint32_t *n)
{
    assert(f && *f==&prop && nf==1 && max==1 && filters==10 && t && n);
    if(!strcmp(scenario(),"enum_partial_error")){
        *t=&token;live|=2;failed=1;calls++;printf("API %u %s\n",calls,__func__);return FPGA_EXCEPTION;
    }
    STEP(0);
    if(!strcmp(scenario(),"zero")){*n=0;return FPGA_OK;}
    *n=!strcmp(scenario(),"multiple")?2U:1U;*t=&token;live|=2;return FPGA_OK;
}
fpga_result fpgaOpen(fpga_token t,fpga_handle *h,int flags)
{assert(t==&token && (live&2) && !flags && h);STEP(0);*h=&handle;live|=4;opens++;return FPGA_OK;}
fpga_result fpgaMapMMIO(fpga_handle h,uint32_t i,uint64_t **p)
{assert(h==&handle && (live&4) && !i && !p);STEP(0);live|=8;maps++;return FPGA_OK;}
fpga_result fpgaReadMMIO64(fpga_handle h,uint32_t i,uint64_t offset,uint64_t *value)
{
    assert(h==&handle && (live&8) && i==0 && value && reads<7);
    assert(offset==offsets[reads] && (offset&7)==0);STEP(0);
    *value=words[reads];
    if((int)reads==number("MEMORY_MUTATE_WORD",-1)){
        unsigned bit=(unsigned)number("MEMORY_MUTATE_BIT",0);assert(bit<64);*value^=UINT64_C(1)<<bit;
    }
    reads++;return FPGA_OK;
}
fpga_result fpgaWriteMMIO64(fpga_handle h,uint32_t i,uint64_t o,uint64_t v)
{(void)h;(void)i;(void)o;(void)v;assert(!"FORBIDDEN MMIO WRITE");return FPGA_EXCEPTION;}
fpga_result fpgaUnmapMMIO(fpga_handle h,uint32_t i)
{assert(h==&handle && (live&8) && !i);STEP(8);live&=~8U;return FPGA_OK;}
fpga_result fpgaClose(fpga_handle h)
{assert(h==&handle && (live&4));STEP(4);live&=~4U;return FPGA_OK;}
fpga_result fpgaDestroyToken(fpga_token *t)
{assert(t && *t==&token && (live&2));STEP(2);live&=~2U;*t=NULL;return FPGA_OK;}
fpga_result fpgaDestroyProperties(fpga_properties *p)
{assert(p && *p==&prop && (live&1));STEP(1);live&=~1U;*p=NULL;return FPGA_OK;}
const char *fpgaErrStr(fpga_result rc){(void)rc;return "inert injected API error";}

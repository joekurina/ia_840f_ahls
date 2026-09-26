/* Local API symbols only, using captured installed headers. No libopae link. */
#include "ahls_qualification_core.h"
#include "ia840f_dma_lifetime.h"
#include <opae/buffer.h>
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
static unsigned allocations, releases, go_count, held, protected_signals, post_reads;
static uint64_t desc[3], count=7;
static _Alignas(4096) unsigned char buf[2][4096];
static unsigned char ddr[2][65536];
static const uint64_t iova[2]={UINT64_C(0x123450000000),UINT64_C(0x123450001000)};
static uint64_t idle(void){return (count<<28)|(UINT64_C(1)<<22)|(UINT64_C(1)<<16)|10;}
int ia840f_dma_signals_block(void){protected_signals=1;return 0;}
int ia840f_dma_wait_step(void *v){(void)v;return 0;}
_Noreturn void ia840f_dma_hold(const char *why,const struct ia840f_dma_report *r)
{
    assert(live==63 && allocations==2 && releases==0);
    assert(r->go_may_have_been_issued || (go_count==0 && strstr(why,"allocation ownership")));held=1;
    printf("INERT_HOLD reason=%s go=%u polls=%u\n",why,go_count,r->polls);
    exit(77); /* inert fixture only: no device, mapped DMA, or real hold */
}
static const uint64_t offsets[]={0,8,16,0x98,0xa0,0xa8,0xb0};
static const uint64_t words[]={UINT64_C(0x1000010000000000),
    UINT64_C(0x8bb069483ac95ec6),UINT64_C(0xd48dde9ff551578d),
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
    assert(held ? live==63 : live==failed_cleanup);
    assert(opens<=1 && maps<=1 && go_count<=256);
    printf("INERT_DMA buffers=%u releases=%u go=%u held=%u post_reads=%u\n",allocations,releases,go_count,held,post_reads);
    printf("INERT_MEMORY_SUMMARY calls=%u filters=%u reads=%u opens=%u maps=%u failed=%u remaining=%u allowed_remaining=%u\n",
           calls,filters,reads,opens,maps,failed,live,failed_cleanup);
}
fpga_result fpgaGetProperties(fpga_token t,fpga_properties *p)
{
    assert(protected_signals && !t && p);assert(atexit(verify_exit)==0);STEP(0);*p=&prop;live|=1;return FPGA_OK;
}
#define SETTER(name,type,test) fpga_result name(fpga_properties p,type v){assert(p==&prop && (live&1));STEP(0);assert(test);filters++;return FPGA_OK;}
SETTER(fpgaPropertiesSetObjectType,fpga_objtype,v==FPGA_ACCELERATOR)
SETTER(fpgaPropertiesSetSegment,uint16_t,v==0)
SETTER(fpgaPropertiesSetBus,uint8_t,v==0x4f)
SETTER(fpgaPropertiesSetDevice,uint8_t,v==0)
SETTER(fpgaPropertiesSetFunction,uint8_t,v==2)
SETTER(fpgaPropertiesSetVendorID,uint16_t,v==0x8086)
SETTER(fpgaPropertiesSetDeviceID,uint16_t,v==0xbccf)
SETTER(fpgaPropertiesSetSubsystemVendorID,uint16_t,v==0x8086)
SETTER(fpgaPropertiesSetSubsystemDeviceID,uint16_t,v==0x1771)
fpga_result fpgaPropertiesSetGUID(fpga_properties p,fpga_guid v)
{
    static const unsigned char uuid[]={0xd4,0x8d,0xde,0x9f,0xf5,0x51,0x57,0x8d,0x8b,0xb0,0x69,0x48,0x3a,0xc9,0x5e,0xc6};
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
    assert(h==&handle && (live&8) && i==0 && value && (offset&7)==0);STEP(0);
    if(reads<7){assert(offset==offsets[reads]);*value=words[reads];
      if((int)reads==number("MEMORY_MUTATE_WORD",-1))*value^=1;
      reads++;return FPGA_OK;}
    reads++;
    if(offset==0x48){
      *value=idle();if(go_count)post_reads++;
      if(go_count==(unsigned)number("MEMORY_AT_GO",1) && !strcmp(scenario(),"sticky_error"))*value|=UINT64_C(1)<<13;
      if(go_count==(unsigned)number("MEMORY_AT_GO",1) && !strcmp(scenario(),"stale_count"))*value=(((count-1)&15)<<28)|(idle()&UINT64_C(0xfffffff));
      return FPGA_OK;
    }
    if(offset==0x50){*value=0;return FPGA_OK;}
    assert(offset==0x28||offset==0x30||offset==0x38);
    *value=desc[(offset-0x28)/8];
    if(go_count+1==(unsigned)number("MEMORY_AT_GO",1) && !strcmp(scenario(),"readback_mismatch"))*value^=1;
    return FPGA_OK;
}
fpga_result fpgaWriteMMIO64(fpga_handle h,uint32_t i,uint64_t off,uint64_t value)
{
    assert(h==&handle && (live&8) && i==0);
    /* Simulate ambiguous GO even if the API returns an injected failure. */
    if(off==0x40){go_count++;printf("INERT_SUBMIT api_next=%u sequence=%u\n",calls+1,go_count);}
    STEP(0);
    if(off==0x28||off==0x30||off==0x38){desc[(off-0x28)/8]=value;return FPGA_OK;}
    assert(off==0x40 && allocations==2 && desc[2]==2);
    assert(go_count>=1 && go_count<=256);
    unsigned index=(go_count-1)%64, phase=(go_count-1)/64;
    unsigned bank=phase%2;
    unsigned selected=!strcmp(scenario(),"banks_alias")?0:bank;
    uint64_t offset=(uint64_t)index*128;
    uint64_t ddr_addr=((uint64_t)bank<<34)|offset;
    assert(offset+128<=sizeof(ddr[0]) && offset/4096==(offset+127)/4096);
    if(phase<2){
      assert(value==UINT64_C(0x84000000)&&desc[0]==iova[0]+64&&desc[1]==ddr_addr);
      memcpy(ddr[selected]+offset,buf[0]+64,128);
    }else{
      assert(value==UINT64_C(0x88000000)&&desc[0]==ddr_addr&&desc[1]==iova[1]+64);
      memcpy(buf[1]+64,ddr[selected]+offset,128);
      if(!strcmp(scenario(),"payload_corrupt"))buf[1][75]^=1;
      if(!strcmp(scenario(),"guard_corrupt"))buf[1][1]^=1;
    }
    count=(count+1)&15;return FPGA_OK;
}
fpga_result fpgaPrepareBuffer(fpga_handle h,uint64_t len,void **p,uint64_t *wsid,int flags)
{
    assert(h==&handle&&len==4096&&p&&wsid&&!flags&&allocations<2);STEP(0);
    *p=buf[allocations];*wsid=100+allocations;live|=16U<<allocations;allocations++;
    if(!strcmp(scenario(),"duplicate_wsid"))*wsid=100;
    if(!strcmp(scenario(),"duplicate_cpu"))*p=buf[0];
    return FPGA_OK;
}
fpga_result fpgaGetIOAddress(fpga_handle h,uint64_t wsid,uint64_t *addr)
{
    assert(h==&handle&&wsid>=100&&wsid<=101&&addr);STEP(0);*addr=iova[wsid-100];
    if(!strcmp(scenario(),"bad_iova"))*addr=UINT64_C(1)<<57;
    if(!strcmp(scenario(),"alias_iova"))*addr=iova[0];
    return FPGA_OK;
}
fpga_result fpgaReleaseBuffer(fpga_handle h,uint64_t wsid)
{
    assert(h==&handle&&wsid>=100&&wsid<=101);unsigned bit=16U<<(unsigned)(wsid-100);
    assert(live&bit);releases++;STEP(bit);live&=~bit;return FPGA_OK;
}
fpga_result fpgaUnmapMMIO(fpga_handle h,uint32_t i)
{assert(h==&handle && (live&8) && !i);STEP(8);live&=~8U;return FPGA_OK;}
fpga_result fpgaClose(fpga_handle h)
{assert(h==&handle && (live&4));STEP(4);live&=~4U;return FPGA_OK;}
fpga_result fpgaDestroyToken(fpga_token *t)
{assert(t && *t==&token && (live&2));STEP(2);live&=~2U;*t=NULL;return FPGA_OK;}
fpga_result fpgaDestroyProperties(fpga_properties *p)
{assert(p && *p==&prop && (live&1));STEP(1);live&=~1U;*p=NULL;return FPGA_OK;}
const char *fpgaErrStr(fpga_result rc){(void)rc;return "inert injected API error";}

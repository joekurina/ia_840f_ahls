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
#include <inttypes.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
static int prop,token,handle;
static unsigned live,failed_cleanup,calls,filters,reads,opens,maps,failed;
static unsigned allocations, releases, go_count, held, protected_signals, post_reads;
static uint64_t desc[3], count=7;
static _Alignas(4096) unsigned char buf[2][4096];
static unsigned char ddr[2][0xa0040]; /* Inert byte-addressed RAM only. */
static uint64_t kernel_args[4];
static unsigned kernel_count, producer_seen, ticket_seen, completion_ready;
static unsigned status_polls, completion_polls, finish_count=2, argument_count;
static int32_t load32(const unsigned char *p){int32_t v;memcpy(&v,p,4);return v;}
static void produce(void)
{
    assert(kernel_args[3]==65536);
    assert(kernel_args[0]+4*kernel_args[3]<=sizeof(ddr[0]));
    assert(kernel_args[1]+4*kernel_args[3]<=sizeof(ddr[0]));
    assert(kernel_args[2]+4*kernel_args[3]<=sizeof(ddr[1]));
    assert(kernel_args[0]==0x10000 && kernel_args[1]==0x60000 && kernel_args[2]==0x10000);
    for(unsigned j=0;j<kernel_args[3];++j){
        assert(load32(ddr[0]+kernel_args[0]+4*j)==(int32_t)j);
        assert(load32(ddr[0]+kernel_args[1]+4*j)==(int32_t)(2*j+1));
        int64_t v=(int64_t)load32(ddr[0]+kernel_args[0]+4*j)+load32(ddr[0]+kernel_args[1]+4*j);
        assert(v>=INT32_MIN && v<=INT32_MAX);int32_t result=(int32_t)v;
        memcpy(ddr[1]+kernel_args[2]+4*j,&result,4);
    }
}
static const uint64_t iova[2]={UINT64_C(0x123450000000),UINT64_C(0x123450001000)};
static uint64_t idle(void){return (count<<28)|(UINT64_C(1)<<22)|(UINT64_C(1)<<16)|10;}
int ia840f_dma_signals_block(void){protected_signals=1;return 0;}
int ia840f_dma_wait_step(void *v){(void)v;return 0;}
_Noreturn void ia840f_dma_hold(const char *why,const struct ia840f_dma_report *r)
{
    assert((live&15)==15 && releases==0);
    assert(kernel_count || r->go_may_have_been_issued || strstr(why,"allocation ownership") || strstr(why,"baseline"));held=1;
    printf("INERT_HOLD reason=%s go=%u kernel=%u polls=%u\n",why,go_count,kernel_count,r->polls);
    exit(77); /* inert fixture only: no device, mapped DMA, or real hold */
}
static const uint64_t offsets[]={0,8,16,0x98,0xa0,0xa8,0xb0};
static const uint64_t words[]={UINT64_C(0x1000010000000000),
    UINT64_C(0x8bb069483ac95ec6),UINT64_C(0xd48dde9ff551578d),
    UINT64_C(0x49413834444d0001),UINT64_C(0x0002001000200200),
    UINT64_C(0x0008004014393922),UINT64_C(0x000000060001ff00)};
static int number(const char *key,int fallback){const char *s=getenv(key);return s?atoi(s):fallback;}
static const char *scenario(void){const char *s=getenv("MEMORY_CASE");return s && kernel_count>=(unsigned)number("MEMORY_FAULT_KERNEL",1)?s:"pass";}
static fpga_result step(const char *name,unsigned cleanup)
{
    assert(!failed || cleanup);calls++;
    if(calls<25 || cleanup || calls%8192==0)printf("API %u %s\n",calls,name);
    if(calls==(unsigned)number("MEMORY_FAIL_AT",0)){
        failed=1;failed_cleanup|=cleanup;return FPGA_EXCEPTION;
    }
    return FPGA_OK;
}
#define STEP(cleanup) do{fpga_result rc=step(__func__,cleanup);if(rc!=FPGA_OK)return rc;}while(0)
static void verify_exit(void)
{
    /* Each acquired resource must be cleaned up, except its injected destructor. */
    assert(held ? live==(15U|(allocations>0?16U:0U)|(allocations>1?32U:0U)) : live==failed_cleanup);
    assert(opens<=1 && maps<=1 && go_count<65536 && kernel_count<=1);
    printf("INERT_DMA buffers=%u releases=%u go=%u held=%u kernel=%u producer=%u ticket=%u completed=%u\n",allocations,releases,go_count,held,kernel_count,producer_seen,ticket_seen,completion_ready);
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
    if(offset==0x20000){*value=UINT64_C(0x4d4d494f47524431);return FPGA_OK;}
    if(offset==0x20008){*value=0;return FPGA_OK;}
    if(offset==0x20020){*value=UINT64_C(0x484c53434f4d5031);return FPGA_OK;}
    if(offset==0x20028){
        if(!kernel_count){*value=UINT64_C(0x10000);return FPGA_OK;}
        assert(producer_seen && ticket_seen);
        ++completion_polls;
        *value=UINT64_C(0x10001);
        if(!strcmp(scenario(),"completion_error")){*value|=UINT64_C(0x100);return FPGA_OK;}
        if(!strcmp(scenario(),"completion_unsupported")){*value=1;return FPGA_OK;}
        if(!strcmp(scenario(),"completion_reset")){*value=UINT64_C(0x10000);return FPGA_OK;}
        if(completion_polls>=3 && strcmp(scenario(),"completion_timeout")){
            if(!completion_ready)produce();
            completion_ready=1;*value=UINT64_C(0x10002);
        }
        return FPGA_OK;
    }
    if(offset==0x10000){
        if(kernel_count){
            if(!strcmp(scenario(),"status_error")){failed=1;return FPGA_EXCEPTION;}
            ++status_polls;
            if(status_polls==1 || !strcmp(scenario(),"status_timeout")){*value=UINT64_C(0x58000);return FPGA_OK;}
            producer_seen=1;
        }
        *value=UINT64_C(0x50000)|(finish_count?2:0);return FPGA_OK;
    }
    if(offset==0x10030){
        if(kernel_count && finish_count){assert(producer_seen && !ticket_seen);ticket_seen=1;}
        *value=finish_count;finish_count=0;
        if(kernel_count && !strcmp(scenario(),"bad_ticket"))*value=2;
        return FPGA_OK;
    }
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
    assert(h==&handle && (live&8) && i==0 && !(off&7));
    if(off==0x40){go_count++;if(go_count%1024==0)printf("INERT_SUBMIT api_next=%u sequence=%u\n",calls+1,go_count);}
    if(off==0x10008){kernel_count++;printf("INERT_KERNEL_SUBMIT api_next=%u\n",calls+1);}
    STEP(0);
    if(off>=0x10080 && off<=0x10098){
        assert(argument_count<4 && (!kernel_count || completion_ready));
        assert(off==UINT64_C(0x10080)+8*argument_count);
        kernel_args[argument_count++]=value;return FPGA_OK;
    }
    if(off==0x10008){
        assert(kernel_count>=1 && kernel_count<=1 && argument_count==4 && value==1);
        if(!strcmp(scenario(),"start_error")){failed=1;return FPGA_EXCEPTION;}
        argument_count=0;status_polls=0;completion_polls=0;
        producer_seen=0;ticket_seen=0;completion_ready=0;finish_count=1;return FPGA_OK;
    }
    if(off==0x28||off==0x30||off==0x38){desc[(off-0x28)/8]=value;return FPGA_OK;}
    assert(off==0x40 && allocations==2 && go_count>=1 && desc[2]>0 && desc[2]<=2);
    unsigned bytes=(unsigned)desc[2]*64,bank,host;
    uint64_t da;
    if(value==UINT64_C(0x84000000)){
        da=desc[1];bank=(unsigned)(da>>34);da&=(UINT64_C(1)<<34)-1;
        assert(bank<2 && da+bytes<=sizeof(ddr[0]));
        assert(desc[0]>=iova[0] && desc[0]+bytes<=iova[0]+4096);
        host=(unsigned)(desc[0]-iova[0]);assert(!(host%64));
        assert(da/4096==(da+bytes-1)/4096);
        memcpy(ddr[bank]+da,buf[0]+host,bytes);
    }else{
        assert(value==UINT64_C(0x88000000) && completion_ready && producer_seen && ticket_seen);
        da=desc[0];bank=(unsigned)(da>>34);da&=(UINT64_C(1)<<34)-1;
        assert(bank==1 && da+bytes<=sizeof(ddr[1]));
        assert(desc[1]>=iova[1] && desc[1]+bytes<=iova[1]+4096);
        host=(unsigned)(desc[1]-iova[1]);assert(!(host%64));
        assert(da/4096==(da+bytes-1)/4096);
        if(strcmp(scenario(),"missing_visibility"))memcpy(buf[1]+host,ddr[bank]+da,bytes);
        if(!strcmp(scenario(),"payload_corrupt") && da<=kernel_args[2] && kernel_args[2]<da+bytes)
            buf[1][host+(unsigned)(kernel_args[2]-da)]^=1;
        uint64_t last=kernel_args[2]+kernel_args[3]*4-4;
        if(!strcmp(scenario(),"late_payload_corrupt") && da<=last && last<da+bytes)buf[1][host+(unsigned)(last-da)]^=1;
        if(!strcmp(scenario(),"guard_corrupt"))buf[1][1]^=1;
    }
    printf("INERT_BULK_DMA sequence=%u mode=%u bank=%u bytes=%u ddr=0x%" PRIx64 "\n",go_count-1,value==UINT64_C(0x84000000)?1U:2U,bank,bytes,da);
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

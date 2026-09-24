#include "ia840f_dma_transfer_core.h"
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#define IDLE(n) ((UINT64_C(n)<<28)|(UINT64_C(1)<<22)|(UINT64_C(1)<<16)|10)
#define REQUIRE(c) do { if (!(c)) { fprintf(stderr,"FAIL %s:%d: %s\n",name,__LINE__,#c); return 1; } } while (0)
struct mock {
    uint64_t status[5], regs[3], offsets[4], values[4], control;
    unsigned nstatus, istatus, reads, writes, waits;
    unsigned fail_read, fail_write;
    int bad_readback, wait_fails;
};
static int rd(void *v,uint64_t off,uint64_t *val)
{
    struct mock *m=v; ++m->reads;
    if (m->reads==m->fail_read) return -1;
    if (off==0x48) {
        unsigned i=m->istatus<m->nstatus?m->istatus++:m->nstatus-1;
        *val=m->status[i]; return 0;
    }
    if (off==0x50) {*val=m->control;return 0;}
    if (off==0x28||off==0x30||off==0x38) {
        *val=m->regs[(off-0x28)/8]^(m->bad_readback?1:0);return 0;
    }
    return -1;
}
static int wr(void *v,uint64_t off,uint64_t val)
{
    struct mock *m=v; unsigned i=m->writes++;
    if (i>=4) return -1;
    m->offsets[i]=off;m->values[i]=val;
    if (off==0x28||off==0x30||off==0x38)m->regs[(off-0x28)/8]=val;
    else if (off!=0x40)return -1;
    return m->writes==m->fail_write?-1:0;
}
static int wait_step(void *v){struct mock*m=v;++m->waits;return m->wait_fails;}
static struct ia840f_dma_request request(void)
{
    return (struct ia840f_dma_request){.mode=1,.bank=0,.ddr_offset=0x10000,
      .iova_base=UINT64_C(0x123450000000),.mapped_bytes=4096,.host_offset=64,
      .bytes=64,.max_polls=3};
}
static struct mock mock(void){return (struct mock){.status={IDLE(7),IDLE(8)},.nstatus=2};}
static int run_case(unsigned k,const char *name)
{
    struct mock m=mock();struct ia840f_dma_request q=request();struct ia840f_dma_report r;
    struct ia840f_dma_io io={&m,rd,wr,wait_step};enum ia840f_dma_result want=IA840F_DMA_OK;
    unsigned expected_writes=4;int expected_hazard=1,expected_quiet=1;
    if(k==1){q.mode=2;q.bank=1;}
    if(k==2){m.status[0]=IDLE(15);m.status[1]=IDLE(0);}
    if(k==3){m.status[1]=IDLE(7)|1;m.status[2]=IDLE(8);m.nstatus=3;}
    if(k==4){m.status[0]|=1;want=IA840F_DMA_BAD_STATE;expected_writes=0;expected_hazard=0;expected_quiet=0;}
    if(k==5){m.control=1;want=IA840F_DMA_BAD_STATE;expected_writes=0;expected_hazard=0;}
    if(k==6){m.bad_readback=1;want=IA840F_DMA_READBACK_ERROR;expected_writes=1;expected_hazard=0;}
    if(k==7){m.fail_write=1;want=IA840F_DMA_IO_ERROR;expected_writes=1;expected_hazard=0;}
    if(k==8){m.fail_write=4;want=IA840F_DMA_IO_ERROR;expected_quiet=0;}
    if(k==9){m.fail_read=6;want=IA840F_DMA_IO_ERROR;expected_quiet=0;}
    if(k==10){m.status[1]=IDLE(8)|(UINT64_C(1)<<13);want=IA840F_DMA_DEVICE_ERROR;expected_quiet=0;}
    if(k==11){m.status[1]=IDLE(8)|(UINT64_C(1)<<10);want=IA840F_DMA_DEVICE_ERROR;expected_quiet=0;}
    if(k==12){m.status[1]=IDLE(9);want=IA840F_DMA_BAD_STATE;expected_quiet=0;}
    if(k==13){m.status[1]=IDLE(7);want=IA840F_DMA_POLL_EXHAUSTED;expected_quiet=0;}
    if(k==14){m.status[1]=IDLE(8)&~UINT64_C(8);want=IA840F_DMA_POLL_EXHAUSTED;expected_quiet=0;}
    if(k==15){m.status[1]=IDLE(7)|1;m.wait_fails=1;want=IA840F_DMA_POLL_EXHAUSTED;expected_quiet=0;}
    if(k==16){m.status[0]&=~(UINT64_C(1)<<16);want=IA840F_DMA_BAD_STATE;expected_writes=0;expected_hazard=0;expected_quiet=0;}
    enum ia840f_dma_result got=ia840f_dma_transfer(&io,&q,&r);
    REQUIRE(got==want);REQUIRE(m.writes==expected_writes);
    REQUIRE(r.go_may_have_been_issued==expected_hazard);REQUIRE(r.quiescent==expected_quiet);
    if(got==IA840F_DMA_OK){
        uint64_t host=q.iova_base+q.host_offset,ddr=((uint64_t)q.bank<<34)|q.ddr_offset;
        REQUIRE(m.offsets[0]==0x28&&m.offsets[1]==0x30&&m.offsets[2]==0x38&&m.offsets[3]==0x40);
        REQUIRE(m.values[0]==(q.mode==1?host:ddr));REQUIRE(m.values[1]==(q.mode==1?ddr:host));
        REQUIRE(m.values[2]==1);REQUIRE(m.values[3]==(q.mode==1?UINT64_C(0x84000000):UINT64_C(0x88000000)));
        REQUIRE(r.phase==IA840F_DMA_COMPLETE);
    }
    if(k==8)REQUIRE(m.reads==5);
    if(k==10||k==11||k==12)REQUIRE(r.polls==1&&m.waits==0);
    if(k==13||k==14)REQUIRE(r.polls==q.max_polls&&m.waits==q.max_polls-1);
    printf("PASS %s\n",name);return 0;
}
static int invalid_case(unsigned k,const char *name)
{
    struct mock m=mock();struct ia840f_dma_request q=request();struct ia840f_dma_report r;
    struct ia840f_dma_io io={&m,rd,wr,wait_step};
    switch(k){
    case 0:q.mode=0;break;case 1:q.mode=3;break;case 2:q.bank=2;break;
    case 3:q.bytes=0;break;case 4:q.bytes=65;break;case 5:q.bytes=4160;break;
    case 6:q.host_offset=1;break;case 7:q.host_offset=4096;break;
    case 8:q.ddr_offset=1;break;case 9:q.ddr_offset=(UINT64_C(1)<<34)-64;q.bytes=128;break;
    case 10:q.ddr_offset=UINT64_C(1)<<34;break;case 11:q.iova_base=UINT64_C(1)<<57;break;
    case 12:q.iova_base=UINT64_MAX-31;break;case 13:q.mapped_bytes=0;break;
    case 14:q.max_polls=0;break;case 15:q.iova_base+=1;break;
    }
    REQUIRE(ia840f_dma_transfer(&io,&q,&r)==IA840F_DMA_INVALID);
    REQUIRE(m.reads==0&&m.writes==0&&m.waits==0);REQUIRE(!r.go_may_have_been_issued);
    printf("PASS %s\n",name);return 0;
}
int main(void)
{
    const char *names[]={"h2d-high-iova","d2h-bank1","counter-wrap","busy-then-done",
      "busy-baseline","nonzero-control","bad-argument-readback","argument-write-error",
      "ambiguous-go-error","post-go-read-error","read-response-error","write-response-error",
      "extra-retirement","stale-idle-is-not-completion","data-fifo-not-empty","host-wait-stop",
      "writer-not-idle"};
    unsigned count=0;
    for(unsigned k=0;k<sizeof(names)/sizeof(names[0]);++k){if(run_case(k,names[k]))return 1;++count;}
    for(unsigned k=0;k<16;++k){char name[40];snprintf(name,sizeof(name),"invalid-request-%u",k);if(invalid_case(k,name))return 1;++count;}
    printf("DMA protocol inert cases PASSED: %u; no OPAE/device access\n",count);return 0;
}

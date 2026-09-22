/* Inert register fixture. No OPAE library, files, devices, or sysfs. */
#include "ahls_qualification_core.h"
#include <assert.h>
#include <inttypes.h>
#include <stdio.h>
#include <string.h>
#include <limits.h>

struct fixture {
    uint64_t time,finish,result,args,mode,status;
    unsigned calls,fail_at,writes,starts,polls,result_reads;
    int launched,never_finish,stall_clock,backward,bad_clear,multi_finish;
    uint64_t wrong_identity_offset;
};
static int fault(struct fixture *f) {return ++f->calls==f->fail_at;}
static int rd(void *p,uint64_t off,uint64_t *v)
{
    struct fixture *f=p;if(fault(f))return -1;
    assert(!(off&7));
    if(off==0)*v=UINT64_C(0x1000010000000000);
    else if(off==8)*v=UINT64_C(0xbb7512b5f446d842);
    else if(off==16)*v=UINT64_C(0x67bc266a56f7440a);
    else if(off==AHLS_STATUS)*v=f->status;
    else if(off==AHLS_FINISH) {
        if(f->launched && ++f->polls==3 && !f->never_finish) {
            f->finish=f->multi_finish?2:1;f->launched=0;
        }
        *v=f->finish;
        if(!f->bad_clear)f->finish=0;
    } else if(off==AHLS_RESULT) {
        assert(f->starts && !f->launched && f->polls>=3);
        f->result_reads++;*v=f->result;
    } else assert(!"unexpected offset");
    if(off==f->wrong_identity_offset)*v^=1;
    return 0;
}
static int wr(void *p,uint64_t off,uint64_t v)
{
    struct fixture *f=p;if(fault(f))return -1;
    assert(!(off&7));f->writes++;
    if(off==AHLS_ARGS)f->args=v;
    else if(off==AHLS_MODE)f->mode=v;
    else if(off==AHLS_START) {
        assert(v==1);assert(!f->launched);f->starts++;f->launched=1;f->polls=0;
    } else assert(!"unexpected write");
    return 0;
}
static int now(void *p,uint64_t *t)
{
    struct fixture *f=p;if(fault(f))return -1;
    *t=(f->backward && f->launched)?0:f->time;return 0;
}
static int pause_tick(void *p,unsigned ms)
{
    struct fixture *f=p;if(fault(f))return -1;
    if(!f->stall_clock)f->time+=ms;
    return 0;
}
static struct fixture fresh(void)
{
    struct fixture f={0};f.status=5<<16;f.finish=1;
    f.wrong_identity_offset=UINT64_MAX;return f;
}
static int run(struct fixture *f,struct ahls_case c)
{
    struct ahls_io io={f,rd,wr,now,pause_tick};uint32_t result;
    return ahls_run_case(&io,c,10,&result);
}
int main(void)
{
    /* Independent Python integer-oracle answers, fixed before the C run. */
    static const uint32_t expected[]={0x8,0x10,0x30,0x30,0,0xfffffff0,
        0x700,0xff00,0,0,0x10,0x8};
    assert(ahls_case_count==sizeof(expected)/sizeof(expected[0]));
    struct fixture f=fresh();struct ahls_io io={&f,rd,wr,now,pause_tick};
    assert(ahls_verify_identity(&io)==AHLS_OK);
    for(size_t i=0;i<ahls_case_count;i++) {
        uint32_t ref;
        assert(ahls_reference(ahls_cases[i],&ref)==AHLS_OK && ref==expected[i]);
        f.result=expected[i];
        assert(run(&f,ahls_cases[i])==AHLS_OK);
        assert(f.args==(((uint64_t)(uint32_t)ahls_cases[i].b<<32)|(uint32_t)ahls_cases[i].a));
        assert(f.mode==(uint32_t)ahls_cases[i].mode);
    }
    printf("PASS 12 numeric cases including repeated, signed, zero and defined boundaries\n");
    f=fresh();f.result=8;assert(run(&f,ahls_cases[0])==AHLS_OK);
    unsigned calls=f.calls;
    for(unsigned i=1;i<=calls;i++) {
        f=fresh();f.result=8;f.fail_at=i;
        assert(run(&f,ahls_cases[0])==AHLS_IO);assert(f.calls==i);
    }
    printf("PASS %u injected callback failures stop immediately\n",calls);
    for(unsigned i=1;i<=3;i++) {
        f=fresh();f.fail_at=i;assert(ahls_verify_identity(&io)==AHLS_IO);
    }
    for(uint64_t off=0;off<=16;off+=8) {
        f=fresh();f.wrong_identity_offset=off;assert(ahls_verify_identity(&io)==AHLS_IDENTITY);assert(f.writes==0);
    }
    f=fresh();f.never_finish=1;assert(run(&f,ahls_cases[0])==AHLS_TIMEOUT);assert(f.result_reads==0 && f.starts==1);
    f=fresh();f.never_finish=1;f.stall_clock=1;assert(run(&f,ahls_cases[0])==AHLS_TIMEOUT);assert(f.starts==1);
    f=fresh();f.bad_clear=1;assert(run(&f,ahls_cases[0])==AHLS_STATE);assert(!f.starts);
    f=fresh();f.status|=0x8000;assert(run(&f,ahls_cases[0])==AHLS_STATE);assert(!f.writes);
    f=fresh();f.status=4<<16;assert(run(&f,ahls_cases[0])==AHLS_STATE);assert(!f.writes);
    f=fresh();f.multi_finish=1;assert(run(&f,ahls_cases[0])==AHLS_STATE);
    f=fresh();f.time=100;f.backward=1;assert(run(&f,ahls_cases[0])==AHLS_STATE);
    f=fresh();f.result=9;assert(run(&f,ahls_cases[0])==AHLS_NUMERIC);
    f=fresh();f.result=UINT64_C(0x100000008);assert(run(&f,ahls_cases[0])==AHLS_NUMERIC);
    f=fresh();assert(run(&f,(struct ahls_case){INT32_MAX,1,0})==AHLS_INPUT);assert(!f.calls);
    f=fresh();assert(run(&f,(struct ahls_case){INT32_MIN,1,1})==AHLS_INPUT);assert(!f.calls);
    f=fresh();assert(run(&f,(struct ahls_case){1000000,1000000,0})==AHLS_INPUT);assert(!f.calls);
    assert(ahls_unique_match(1,1));assert(!ahls_unique_match(0,1));
    assert(!ahls_unique_match(1,0));assert(!ahls_unique_match(1,2));
    uint16_t seg;uint8_t bus,dev,func;
    assert(!ahls_parse_bdf("0000:ab:1f.7",&seg,&bus,&dev,&func));
    assert(seg==0 && bus==0xab && dev==31 && func==7);
    const char *bad[]={"0:ab:1f.7","0000:ab:20.0","0000:ab:1f.8","0000:ab:1f.7x","0000:ag:1f.7","0000:ab:1f:7"};
    for(size_t i=0;i<sizeof(bad)/sizeof(bad[0]);i++)assert(ahls_parse_bdf(bad[i],&seg,&bus,&dev,&func)==AHLS_INPUT);
    puts("PASS identity, timeout/stale completion, error, enumeration and strict BDF rejection fixtures");
    puts("OFFLINE ONLY: no FPGA or OPAE runtime accessed");return 0;
}

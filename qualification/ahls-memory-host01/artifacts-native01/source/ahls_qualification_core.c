/* Additive replacement test core; original ahls_mmio_test.c is preserved.
 * No device access except through explicitly supplied callbacks.
 */
#include "ahls_qualification_core.h"
#include <limits.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>

const struct ahls_case ahls_cases[] = {
    {3,5,0}, {3,5,1}, {-9,7,0}, {9,-7,1}, {0,0,0},
    {0,3,1}, {1000,2000,0}, {1064,2000,0},
    {INT32_MAX-7,1,0}, {INT32_MIN+7,1,1}, {3,5,-1}, {3,5,0}
};
const size_t ahls_case_count=sizeof(ahls_cases)/sizeof(ahls_cases[0]);

int ahls_unique_match(int api_success, uint32_t matches)
{
    return api_success && matches==1;
}

int ahls_parse_bdf(const char *s,uint16_t *segment,uint8_t *bus,
                   uint8_t *device,uint8_t *function)
{
    unsigned seg,b,d,f;
    if (!s || !segment || !bus || !device || !function || strlen(s)!=12)
        return AHLS_INPUT;
    for (size_t i=0;i<12;i++) {
        if (i==4 || i==7) { if (s[i]!=':') return AHLS_INPUT; }
        else if (i==10) { if (s[i]!='.') return AHLS_INPUT; }
        else if (!isxdigit((unsigned char)s[i])) return AHLS_INPUT;
    }
    if (sscanf(s,"%4x:%2x:%2x.%1x",&seg,&b,&d,&f)!=4 || d>31 || f>7)
        return AHLS_INPUT;
    *segment=(uint16_t)seg;*bus=(uint8_t)b;*device=(uint8_t)d;*function=(uint8_t)f;
    return AHLS_OK;
}

int ahls_reference(struct ahls_case in,uint32_t *expected)
{
    uint32_t checksum=0;
    if (!expected) return AHLS_INPUT;
    for (int i=0;i<8;i++) {
        int64_t term=(int64_t)in.a+(in.mode==0?i:-i);
        if (term<INT32_MIN || term>INT32_MAX) return AHLS_INPUT;
        int64_t product=term*(int64_t)in.b;
        if (product<INT32_MIN || product>INT32_MAX) return AHLS_INPUT;
        checksum^=(uint32_t)(int32_t)product;
    }
    *expected=checksum;
    return AHLS_OK;
}

static int read_reg(const struct ahls_io *io,uint64_t offset,uint64_t *value)
{
    if ((offset&7) || !io || !io->read64) return AHLS_INPUT;
    return io->read64(io->ctx,offset,value)==0 ? AHLS_OK : AHLS_IO;
}

int ahls_verify_identity(const struct ahls_io *io)
{
    static const uint64_t offsets[]={0,8,16};
    static const uint64_t expected[]={UINT64_C(0x1000010000000000),
        UINT64_C(0xbb7512b5f446d842),UINT64_C(0x67bc266a56f7440a)};
    for (size_t i=0;i<3;i++) {
        uint64_t value;
        if (read_reg(io,offsets[i],&value)!=AHLS_OK) return AHLS_IO;
        if (value!=expected[i]) return AHLS_IDENTITY;
    }
    return AHLS_OK;
}

static int idle(const struct ahls_io *io)
{
    uint64_t status;
    if (read_reg(io,AHLS_STATUS,&status)!=AHLS_OK) return AHLS_IO;
    if ((status>>16)!=5 || (status & (UINT64_C(0x8000)|4))) return AHLS_STATE;
    return AHLS_OK;
}

int ahls_run_case(const struct ahls_io *io,struct ahls_case in,
                  uint64_t timeout_ms,uint32_t *observed)
{
    uint32_t expected;
    uint64_t count,start,now,last,result;
    int rc=ahls_reference(in,&expected);
    if (rc || !io || !io->write64 || !io->now_ms || !io->pause_ms ||
        !observed || !timeout_ms || timeout_ms>60000) return AHLS_INPUT;
    rc=idle(io);if(rc) return rc;
    /* Generated RTL is a two-bit count, padded to 64 bits, CLEAR ON READ.
     * Drain any idle residual, verify zero, then require exactly one NEW finish.
     * Do not read 0x74, combine halves, or compare monotonic counter values.
     */
    if (read_reg(io,AHLS_FINISH,&count)) return AHLS_IO;
    if (count>3) return AHLS_STATE;
    if (read_reg(io,AHLS_FINISH,&count)) return AHLS_IO;
    if (count!=0) return AHLS_STATE;
    if (io->write64(io->ctx,AHLS_ARGS,((uint64_t)(uint32_t)in.b<<32)|(uint32_t)in.a) ||
        io->write64(io->ctx,AHLS_MODE,(uint32_t)in.mode)) return AHLS_IO;
    if (io->now_ms(io->ctx,&start)) return AHLS_IO;
    last=start;
    if (io->write64(io->ctx,AHLS_START,1)) return AHLS_IO;
    /* Fixed operation ceiling also fails closed if the supplied clock stalls. */
    for (uint64_t poll=0;poll<=timeout_ms;poll++) {
        if (io->now_ms(io->ctx,&now)) return AHLS_IO;
        if (now<last) return AHLS_STATE;
        if (now-start>=timeout_ms) return AHLS_TIMEOUT;
        last=now;
        if (read_reg(io,AHLS_FINISH,&count)) return AHLS_IO;
        if (count>1) return AHLS_STATE;
        if (count==1) {
            rc=idle(io);if(rc) return rc;
            if (read_reg(io,AHLS_RESULT,&result)) return AHLS_IO;
            *observed=(uint32_t)result;
            /* ResultPipe is zero-padded 32-bit data; check the WHOLE read. */
            return result==(uint64_t)expected ? AHLS_OK : AHLS_NUMERIC;
        }
        if (io->pause_ms(io->ctx,1)) return AHLS_IO;
    }
    return AHLS_TIMEOUT;
}

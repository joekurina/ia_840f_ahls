#include "ia840f_dma_transfer_core.h"
#include <string.h>

#define CSR_SOURCE UINT64_C(0x28)
#define CSR_DESTINATION UINT64_C(0x30)
#define CSR_LENGTH UINT64_C(0x38)
#define CSR_GO UINT64_C(0x40)
#define CSR_STATUS UINT64_C(0x48)
#define CSR_CONTROL UINT64_C(0x50)
#define STATUS_ERROR ((UINT64_C(1)<<13)|(UINT64_C(1)<<10)| \
                      (UINT64_C(1)<<7)|(UINT64_C(1)<<6)|(UINT64_C(1)<<5))
#define BANK_BYTES (UINT64_C(1)<<34)
#define HOST_LIMIT (UINT64_C(1)<<57)
#define PAGE_BYTES UINT64_C(4096)
#define BEAT_BYTES UINT64_C(64)

int ia840f_dma_status_quiescent(uint64_t status)
{
    const uint64_t empty=(UINT64_C(1)<<3)|(UINT64_C(1)<<1);
    const uint64_t not_idle=STATUS_ERROR|(UINT64_C(1)<<4)|
                            (UINT64_C(1)<<2)|UINT64_C(1);
    return !(status&not_idle) && (status&empty)==empty &&
           ((status>>22)&63)==1 && ((status>>16)&63)==1;
}

static int request_valid(const struct ia840f_dma_request *q)
{
    /* Validate raw values before additions, narrowing, or hardware access. */
    return q && (q->mode==1 || q->mode==2) && q->bank<2 &&
        q->bytes && q->bytes<=PAGE_BYTES && !(q->bytes%BEAT_BYTES) &&
        q->mapped_bytes==PAGE_BYTES && !(q->iova_base%PAGE_BYTES) &&
        q->iova_base<=HOST_LIMIT-PAGE_BYTES &&
        !(q->host_offset%BEAT_BYTES) &&
        q->host_offset<=PAGE_BYTES-q->bytes &&
        !(q->ddr_offset%BEAT_BYTES) && q->ddr_offset<BANK_BYTES &&
        q->bytes<=BANK_BYTES-q->ddr_offset && q->max_polls;
}

enum ia840f_dma_result ia840f_dma_transfer(
    const struct ia840f_dma_io *io, const struct ia840f_dma_request *q,
    struct ia840f_dma_report *r)
{
    if (!r) return IA840F_DMA_INVALID;
    memset(r,0,sizeof(*r));
    r->phase=IA840F_DMA_VALIDATE;
    if (!io || !io->read64 || !io->write64 || !request_valid(q))
        return IA840F_DMA_INVALID;

    r->phase=IA840F_DMA_BASELINE;
    if (io->read64(io->context,CSR_STATUS,&r->status_before))
        return IA840F_DMA_IO_ERROR;
    r->status_last=r->status_before;
    if (!ia840f_dma_status_quiescent(r->status_before))
        return IA840F_DMA_BAD_STATE;
    r->quiescent=1;
    uint64_t control;
    if (io->read64(io->context,CSR_CONTROL,&control))
        return IA840F_DMA_IO_ERROR;
    if (control) return IA840F_DMA_BAD_STATE;
    unsigned before=(unsigned)((r->status_before>>28)&15);
    unsigned after=(before+1)&15;
    uint64_t host=q->iova_base+q->host_offset;
    uint64_t ddr=((uint64_t)q->bank<<34)|q->ddr_offset;
    const uint64_t offsets[]={CSR_SOURCE,CSR_DESTINATION,CSR_LENGTH};
    const uint64_t values[]={q->mode==1?host:ddr,q->mode==1?ddr:host,
                             q->bytes/BEAT_BYTES};
    r->phase=IA840F_DMA_ARGUMENTS;
    for (size_t i=0;i<3;++i) {
        uint64_t readback;
        if (io->write64(io->context,offsets[i],values[i]))
            return IA840F_DMA_IO_ERROR;
        if (io->read64(io->context,offsets[i],&readback))
            return IA840F_DMA_IO_ERROR;
        if (readback!=values[i]) return IA840F_DMA_READBACK_ERROR;
    }

    r->phase=IA840F_DMA_GO;
    /* The write API can report failure after the store. Retain ownership. */
    r->go_may_have_been_issued=1;
    r->quiescent=0;
    if (io->write64(io->context,CSR_GO,
                   (UINT64_C(1)<<31)|((uint64_t)q->mode<<26)))
        return IA840F_DMA_IO_ERROR;

    r->phase=IA840F_DMA_POLL;
    for (unsigned i=0;i<q->max_polls;++i) {
        ++r->polls;
        if (io->read64(io->context,CSR_STATUS,&r->status_last))
            return IA840F_DMA_IO_ERROR;
        if (r->status_last&STATUS_ERROR) return IA840F_DMA_DEVICE_ERROR;
        unsigned count=(unsigned)((r->status_last>>28)&15);
        if (count!=before && count!=after) return IA840F_DMA_BAD_STATE;
        if (count==after && ia840f_dma_status_quiescent(r->status_last)) {
            r->quiescent=1;
            r->phase=IA840F_DMA_COMPLETE;
            return IA840F_DMA_OK;
        }
        if (i+1<q->max_polls && io->wait_step && io->wait_step(io->context))
            return IA840F_DMA_POLL_EXHAUSTED;
    }
    return IA840F_DMA_POLL_EXHAUSTED;
}

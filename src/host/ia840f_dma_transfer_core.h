#ifndef IA840F_DMA_TRANSFER_CORE_H
#define IA840F_DMA_TRANSFER_CORE_H
#include <stddef.h>
#include <stdint.h>

/* CAPS01-specific, one descriptor at a time. No allocation/reset/cleanup API.
 * Source contract: qualification/caps01-dma-host01/REGISTER-CONTRACT01.md. */
enum ia840f_dma_result {
    IA840F_DMA_OK = 0, IA840F_DMA_INVALID, IA840F_DMA_IO_ERROR,
    IA840F_DMA_BAD_STATE, IA840F_DMA_READBACK_ERROR,
    IA840F_DMA_DEVICE_ERROR, IA840F_DMA_POLL_EXHAUSTED
};
enum ia840f_dma_phase {
    IA840F_DMA_VALIDATE, IA840F_DMA_BASELINE, IA840F_DMA_ARGUMENTS,
    IA840F_DMA_GO, IA840F_DMA_POLL, IA840F_DMA_COMPLETE
};
struct ia840f_dma_request {
    unsigned mode; /* enum values: 1 host->DDR, 2 DDR->host */
    unsigned bank;
    uint64_t ddr_offset;
    uint64_t iova_base;
    uint64_t mapped_bytes;
    uint64_t host_offset;
    uint64_t bytes;
    unsigned max_polls;
};
struct ia840f_dma_io {
    void *context;
    int (*read64)(void *, uint64_t offset, uint64_t *value);
    int (*write64)(void *, uint64_t offset, uint64_t value);
    int (*wait_step)(void *); /* ordinary host wait; nonzero stops polling */
};
struct ia840f_dma_report {
    enum ia840f_dma_phase phase;
    int go_may_have_been_issued;
    int quiescent;
    uint64_t status_before;
    uint64_t status_last;
    unsigned polls;
};
int ia840f_dma_status_quiescent(uint64_t status);
enum ia840f_dma_result ia840f_dma_transfer(
    const struct ia840f_dma_io *, const struct ia840f_dma_request *,
    struct ia840f_dma_report *);
#endif

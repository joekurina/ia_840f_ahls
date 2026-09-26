#ifndef IA840F_DMA_SEGMENTS_H
#define IA840F_DMA_SEGMENTS_H
#include <stdint.h>
/* Host-only bounded segmentation; no device operation. Units are bytes. */
static inline unsigned ia840f_dma_segment_bytes(uint64_t ddr, uint64_t host,
                                                uint64_t remaining)
{
    const uint64_t bank_bytes=UINT64_C(1)<<34;
    if (!remaining || remaining>4096 || ((ddr|host|remaining)&63) ||
        host>4096-remaining || ddr>=bank_bytes || remaining>bank_bytes-ddr)
        return 0;
    uint64_t n=remaining<128?remaining:128;
    uint64_t room=4096-(ddr&4095);
    if (n>room) n=room;
    room=4096-(host&4095);
    if (n>room) n=room;
    return (unsigned)n;
}
#endif

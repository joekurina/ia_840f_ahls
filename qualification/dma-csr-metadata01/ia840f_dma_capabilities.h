#ifndef IA840F_DMA_CAPABILITIES_H
#define IA840F_DMA_CAPABILITIES_H
#include <stdint.h>
#include <stdbool.h>

/* AFU-relative byte offsets. No MMIO operation is performed by this header. */
#define IA840F_DMA_CAP_ID_OFFSET UINT32_C(0x98)
#define IA840F_DMA_CAP_GEOMETRY_OFFSET UINT32_C(0xa0)
#define IA840F_DMA_CAP_ADDRESS_OFFSET UINT32_C(0xa8)
#define IA840F_DMA_CAP_LIMITS_OFFSET UINT32_C(0xb0)
#define IA840F_DMA_CAP_V1 UINT64_C(0x49413834444d0001)

struct ia840f_dma_capabilities {
    uint16_t data_bits, data_fifo_beats, descriptor_fifo_entries, banks;
    uint8_t bank_address_bits, host_address_bits, descriptor_address_bits;
    uint8_t length_bits, axi_len_bits;
    uint16_t beat_bytes;
    uint32_t max_descriptor_beats, mode_mask;
};

/* Fail closed for unknown ABI or geometry. Output is unchanged on rejection.
 * This decoder accepts this qualification target, not arbitrary future boards.
 * A matching record is not image identity, permission to access hardware, or
 * proof of physical DDR completion, quiescence, reset or host-buffer lifetime.
 */
static inline bool ia840f_dma_capabilities_decode(
    const uint64_t words[4], struct ia840f_dma_capabilities *out)
{
    struct ia840f_dma_capabilities c;
    if (!words || !out || words[0] != IA840F_DMA_CAP_V1 || words[2] >> 56)
        return false;
    c.data_bits = (uint16_t)words[1];
    c.data_fifo_beats = (uint16_t)(words[1] >> 16);
    c.descriptor_fifo_entries = (uint16_t)(words[1] >> 32);
    c.banks = (uint16_t)(words[1] >> 48);
    c.bank_address_bits = (uint8_t)words[2];
    c.host_address_bits = (uint8_t)(words[2] >> 8);
    c.descriptor_address_bits = (uint8_t)(words[2] >> 16);
    c.length_bits = (uint8_t)(words[2] >> 24);
    c.beat_bytes = (uint16_t)(words[2] >> 32);
    c.axi_len_bits = (uint8_t)(words[2] >> 48);
    c.max_descriptor_beats = (uint32_t)words[3];
    c.mode_mask = (uint32_t)(words[3] >> 32);
    if (c.data_bits != 512 || c.data_fifo_beats != 32 ||
        c.descriptor_fifo_entries != 16 || c.banks != 2 ||
        c.bank_address_bits != 34 || c.host_address_bits != 57 ||
        c.descriptor_address_bits != 57 || c.length_bits != 20 ||
        c.beat_bytes != 64 || c.axi_len_bits != 8 ||
        c.max_descriptor_beats != 130816 || c.mode_mask != 6)
        return false;
    *out = c;
    return true;
}
#endif

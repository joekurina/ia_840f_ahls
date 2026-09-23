#include "ia840f_dma_capabilities.h"
#include <assert.h>
#include <stdio.h>
#include <string.h>

int main(void)
{
    const uint64_t good[4] = {
        UINT64_C(0x49413834444d0001), UINT64_C(0x0002001000200200),
        UINT64_C(0x0008004014393922), UINT64_C(0x000000060001ff00)
    };
    struct ia840f_dma_capabilities out, sentinel;
    unsigned rejected = 0;
    memset(&sentinel, 0xa5, sizeof(sentinel));
    memcpy(&out, &sentinel, sizeof(out));
    assert(ia840f_dma_capabilities_decode(good, &out));
    assert(out.data_bits == 512 && out.beat_bytes == 64 && out.banks == 2);
    assert(out.data_fifo_beats == 32 && out.descriptor_fifo_entries == 16);
    assert(out.bank_address_bits == 34 && out.host_address_bits == 57);
    assert(out.max_descriptor_beats == 130816 && out.mode_mask == 6);
    for (unsigned w = 0; w < 4; ++w) {
        for (unsigned bit = 0; bit < 64; ++bit) {
            uint64_t bad[4];
            memcpy(bad, good, sizeof(bad));
            bad[w] ^= UINT64_C(1) << bit;
            memcpy(&out, &sentinel, sizeof(out));
            assert(!ia840f_dma_capabilities_decode(bad, &out));
            assert(memcmp(&out, &sentinel, sizeof(out)) == 0);
            ++rejected;
        }
    }
    memcpy(&out, &sentinel, sizeof(out));
    assert(!ia840f_dma_capabilities_decode(NULL, &out));
    assert(memcmp(&out, &sentinel, sizeof(out)) == 0);
    assert(!ia840f_dma_capabilities_decode(good, NULL));
    printf("DMA_CAPABILITY_HOST_PASS valid=1 bit_mutations_rejected=%u null_checks=2\n", rejected);
    return 0;
}

# IA840F DMA raw-capability ABI v1 — candidate

This additive candidate gives future host code explicit geometry and admission limits without guessing the legacy donor's compact encodings. **Not deployed; not a live access procedure.** All offsets below are relative to the accepted DMA/identity aperture inside the AFU, not a PF/BAR discovery map. Hardware source-to-host and recovery gates remain mandatory.

## Source basis and compatibility

The exact CSR02 baseline is SHA256 `42d09ffffb91152b9f688014bcff9ffc13e5382cddd7f478e5f9b992da232a77`. Its `config1.data_width` assigns raw512 into3bits and `data_fifo_depth` assigns raw32 into4bits; both produce zero. Its clock metadata is hardcoded400 and its150-bit aggregate status narrows to64bits. These old words are preserved, **not repaired or newly validated**. Do not use them as this candidate's capability contract. Native synthesis warnings on them remain expected findings, not waivers. [Prior synthesis review Q4](../ahls-persona-work21-csr02/synth-independent-review01.md).

Pinned AI Suite donor [e0e07f7b1878a477dc4d1191918db8430193e148](https://github.com/altera-fpga/agilex-ed-ai-suite/tree/e0e07f7b1878a477dc4d1191918db8430193e148) has no runtime C/C++ DMA decoder in its complete public tree (`donor-tree01.json`, not truncated). The retained OFS `examples-afu/tutorial/afu_types/01_pim_ifc/dma/sw/dma.c` prints configuration words without decoding the disputed fields; the older oneAPI `mmd_dma.cpp` uses a different register contract. No logarithmic encoding was inferred from those sources. The candidate deliberately does not adopt the AI runtime or oneAPI runtime.

Existing words0x00–0x90 and all write predicates/state/AXI transaction scheduling stay unchanged. Only aligned64-bit reads at four formerly invalid words become valid. Writes to every new word remain DECERR, as do wrong-sized/unaligned reads and high-address aliases. The existing outer guard allows the DMA aperture up to0xffff, the generated fabric routes that aperture to DMA, and the exact raw CSR address is checked before narrowing to the5-bit word index. This is source routing evidence, not live reachability.

## Registers

| Byte offset | Name | Layout, most significant to least significant |
|---|---|---|
|0x98|ID/version|64'h49413834444d0001; exact-match tag and ABI1|
|0xa0|Geometry|[63:48]bank count;[47:32]descriptor-FIFO entries;[31:16]configured data-FIFO beats;[15:0]data bits|
|0xa8|Address/beat widths|[63:56]reserved0;[55:48]AXI LEN bits;[47:32]beat bytes;[31:24]length bits;[23:16]common descriptor-address bits;[15:8]host byte-address bits;[7:0]bank-local byte-address bits|
|0xb0|Admission limits|[63:32]mode mask, bitN denotes accepted descriptor modeN;[31:0]maximum admitted full beats|

Expected words for the bound target:

```text
49413834444d0001
0002001000200200
0008004014393922
000000060001ff00
```

These encode512data bits/64bytes,32configured FIFO beats,16descriptor entries,two banks,34bank-local byte-address bits,57host/common descriptor-address bits,20length bits,8AXI LEN bits,modes1/2,maximum130816beats. All are derived from existing DMA/PIM geometry except the explicit version tag/offsets. The new RTL fails elaboration if a field is not representable or source/destination descriptor widths disagree.

**Limits:** configured FIFO depth is not total pipeline capacity; admitted maximum is not an exercised maximum transfer. Bank count/offset width does not prove physical DDR wiring. Address width does not authorize arbitrary IOVAs. There is no frequency, drain/reset, fence, cancellation, physical visibility, error recovery, or buffer-unpin guarantee in this block. No lifecycle bit was added.

The pure [host decoder](ia840f_dma_capabilities.h) rejects unknown versions, nonzero reserved bits, or geometry outside this exact qualified target. It performs no MMIO/OPAE call and preserves its output object on rejection. The host must separately check every supported API return before passing words to it; no read-error retry is authorized here.

## Verification boundary

The exact new fixture first failed on the unchanged baseline for absent capabilities; candidate changes were then applied and the same fixture passed. Directed cycle-exact legacy comparisons, valid/error metadata states, held R/B, reset phases, split writes and readonly rejection remain in the fixture. Native result review is pending. No mapped fit/timing or hardware acceptance follows from the unit result. [Results](RESULTS01.md).

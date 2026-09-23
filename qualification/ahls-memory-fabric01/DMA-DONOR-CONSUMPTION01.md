# Parent consumption — AI Suite donor DMA source review

**ACCEPT_SOURCE_RISK_ASSESSMENT; HOLD_UNMODIFIED_DMA_FUNCTIONAL_USE.** The FINAL [review](DMA-DONOR-REVIEW01.md), SHA256 `dc08b4fc4f0ceebdc2f4bad4bb18d0f8d3b8f821b26c813a7883759e2ba5c12e`, is consumed as source findings and an implementation constraint, not a DMA build/function pass or a new native-launch approval gate.

The parent verified the report hash, all13 donor file hashes and all5 auxiliary PIM hashes. It directly checked the executable direction enum versus reversed comments, source-interface address-width selection, read/write state handshakes, write completion, CSR strobe/decode handling and all-bank response combination. Static Python calculations reproduced the513-beat AWLEN example and9-bit burst-count overflow. These are source/arithmetic checks, **not executed RTL tests**. Exact references are in review §§2–5,10.

## Missing-wrapper follow-up completed

Fetched only the two pinned missing files from immutable commit `e0e07f7b1878a477dc4d1191918db8430193e148`, and verified raw Git blob SHA1 against the retained nontruncated tree before saving. [Capture manifest](dma-extra-source01/manifest.json):

- `ip/dma/dma_engine.sv`, blob `ca43851a04c84a7da510be293529c20807957eca`.
- `ip/dma/dma_fifo_if.sv`, blob `cd903bff64957489088ff361f2100c50dfaedf79`.

The wrapper directly shares `wr_fsm_done` between reader and writer; no additional B-response drain/retirement logic intervenes. Its response-FIFO flags are the **payload data FIFO** full/empty signals, not an AXI B-response queue. That FIFO has `AXI_MM_DATA_W + 2` bits for payload plus two flags, and the configured DMA_DATA_FIFO_DEPTH. The address-width localparams in the wrapper do not widen the actual `src_mem` interface. The explicit fifo_if instances override its generic default width. These observations close the two-file acquisition gap, **not the reported completion/address/handshake defects**. See [pinned wrapper](https://github.com/altera-fpga/agilex-ed-ai-suite/blob/e0e07f7b1878a477dc4d1191918db8430193e148/agilex7/iseries_ofs_pcie/ip/dma/dma_engine.sv) and [FIFO interface](https://github.com/altera-fpga/agilex-ed-ai-suite/blob/e0e07f7b1878a477dc4d1191918db8430193e148/agilex7/iseries_ofs_pcie/ip/dma/dma_fifo_if.sv).

The optional `ase_hw.tcl` is not acquired: the new fabric does not retain that branch. The auxiliary native-Avalon PIM response example in the review must **not** be relabeled the active Work21 mapping; captured Work21 PIM is native AXI. Its exact selected address macro, host data/IOVA dimensions, response ordering and fence/visibility path still need binding for actual DMA integration. A nominal57-bit default is not that binding.

## Consequences for the current implementation

Keep the donor DMA engine uninstantiated in the current fabric until the source-supported adaptation is ready. The completed fabric03/connected-elab01 gate contains protocol adapters and exported DMA/PIM boundaries, **not this DMA engine**, so its native pass neither exercised nor cleared these hazards. The independent fabric review remains separate and pending.

Prioritize preserving host IOVA bits, stable accepted-request handshakes, explicit DDR-only slicing/bank ownership, truthful response/error/drain accounting and burst-length correctness. Full64-bit CSR writes and a one-descriptor/one-burst restriction alone do not fix the original transport. Do not substitute busy/GO/FIFO-empty, IRQ or constant-zero exception status for numerical copyback and proven visibility. No architecture replacement, source correction, DMA simulation or live access occurred in consuming this review.

No FPGA programming, device access, driver change or reboot. DDR simulation remains SKIPPED BY USER. Report and manifest may be published as one bounded source-review milestone; downloaded donor payloads stay local/hash-referenced under the2,000,000-byte artifact policy.

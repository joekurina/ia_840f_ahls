# Tutorial AFU campaign — complete under recorded-failure policy

**All eight variants were built, loaded and card-tested; six passed and two failed data verification.** Every gate has a consumed independent disposition and a pushed, verified milestone. This is completion of the requested campaign, not an all-pass hardware qualification.

- [Final human-readable summary](FINAL-SUMMARY121.md)
- [Machine-checked eight-variant aggregate](FINAL-AGGREGATE121.json)
- [Results and limitations](README.md)

| Variant | Final verdict | Published milestone |
|---|---|---|
| hello_world / avalon | PASS: full greeting check | `019f51432c6af00cc4a322f15f00f292801d21a3` |
| hello_world / ccip | PASS: full greeting check | `3c62fa8341c7042fc0741f9685f85060b39d127f` |
| hello_world / axi | PASS: full greeting check | `4aa239eb6c9790b154c46daef1d3fd59d26ef40f` |
| clocks / single | PASS: relative-frequency check after authorized ACL fix | `d29b40874a6bf4a21d3aee997f70fec1bd48e8ce` |
| local_memory / avalon | PASS: commanded-data checks, banks 0/1 | `f6dabd611090e291c5f54da4fc7bd5638170ff73` |
| local_memory / axi | PASS: commanded-data checks, banks 0/1 | `d51a6394fc82028c84c966dffbf7c3c6ebdd5d32` |
| copy_engine / single | FAILED: 2,048 checked bytes mismatched; host1 | `c5f52a35cf1626780809eb538885db1bb6f74dca` |
| dma / single | FAILED: 128 checked words mismatched; host1 | `e995487003a6702be7f7fc45bffd41ef6742e0be` |

`PIM_advanced` is README-only and explicitly skipped, outside the eight-variant count. All native/effective builds and final PR loads exited0; host/data failures are not waived by that success. See [copy disposition](copy_engine-single/FINAL-DISPOSITION120.json) and [DMA disposition](dma-single/FINAL-DISPOSITION120.json). Root causes remain unresolved.

## Authority, preservation and end state

Joe's explicit power-cycle/reboot authority supersedes the old permission hold. One source-supported BMC Off/On and one normal workstation reboot were performed after exact card-only preparation; no reflash or FPGA rebuild occurred. Corrected reboot preparation resolved weak-updates module paths without repeating the completed power cycle. [Power](recovery-power110-collection.json), [postboot](recovery-postboot113-collection.json), [VF setup](recovery-VF114-collection.json).

Serial card ownership, owned tmux, no speculative MMIO/BAR probing, exact source/tool/image bindings and raw-failure preservation remain in force. Programming images, licensed binaries, databases, oversized logs and embedded transport payloads stay local/remote-only and SHA-referenced. Original tutorial inventory verifies 85 unchanged files. Preserve Joe's current goal-file edit; it is outside this publication allowlist.

Final observed boot is `c5b29027-5b6b-4bf2-b7ed-ace79cc87e73`; no native build/card operation/review remains active. Ordinary process/fd/maps ownership is empty, but material VFIO pending-transaction timeout/FLR warnings at `195.897734` and `310.912886` remain unwaived. No global hardware drain, reset qualification, future-health or no-hang guarantee is claimed. [Final raw kernel/ownership evidence](final-card119-collection.json).

## Next action

**None for this goal. Stop the completed campaign.** New data-path diagnosis, repairs, stronger hardware qualification or performance work require a separately directed follow-on; do not rebuild, reload or power-cycle solely to replace an honest failed disposition with PASS. Historical pending/hold flags in frozen receipts remain historical, not active jobs or authority holds.

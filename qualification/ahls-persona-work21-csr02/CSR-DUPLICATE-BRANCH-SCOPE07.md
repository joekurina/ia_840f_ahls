# CSR duplicate-branch query07 — narrow execution scope

Continue the standing source-side goal using Quartus 25.1 only. Reuse completed fit01; preserve setup/release/source/SDC/clock policy and all prior results. No hardware, full fit, source modification, or unchanged query repetition.

The completed independent review05/06 (SHA256 `2f36edf7819bc3f8f05206e02fa9a037d5248560ec3798dc0fab2da394a2cfe1`) identifies two previously enumerated, unqueried duplicate cells. Query only descriptor length14 DUPLICATE.comb at FF_X259_Y66_N13 and length0 DUPLICATE.comb at FF_X259_Y69_N26. Reuse06's installed-supported cell/pin/intersection APIs, actual pin collections, finite caps, normal global loader and all-five-corner setup/hold reporting. The changed query checks four new D/ENA pins. Do not assume that DUPLICATE implies source-function equivalence.

Purpose: determine whether length14's duplicate supplies the old source-side add_0/add_1 contribution, and whether length0's duplicate enable drive shares the already-observed retimed admission/storage chain. Emit a small old-function/current-pin/keeper-segment coverage map; keep sequential boundaries and all-bit limits. The accepted six-pin06 sweep is not repeated. Numerical minima are per segment and may not be added.

Execution uses the existing bounded supervisor in a fresh exclusive root, all allowed CPUs and 64 GiB per-process AS limit. Exact completed-fit/source/generated/release/tool bindings and resource/competing-job checks run before native start. Keep native/effective/outer statuses separate; preserve any failure. No vendor DDR simulation. Design Closure FAIL and hardware gates remain unchanged.

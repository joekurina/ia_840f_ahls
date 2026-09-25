# CAPS03 functional milestone accepted

Independent review `deleg_62722d13` found no blocker in sim05 and closed the two
integration findings from `deleg_90848114`. Parent verification corroborated the
source hashes and native setup source selection; see [review receipt](review-consumed06.json)
and [actual functional result](RESULT05.md).

The vendor-primitive bank1 reset joins the application reset and invalidates a
previous completion. Its tested release is idle, not success. This does not qualify
stopped clocks or active-transaction reset recovery.

All 16 native setup HDL selections match their capsule and selection manifest in
order. Fifteen are byte-identical to compiled sim05 inputs, including the tested
page-safe bank0 shim. All 269 generated files represented in sim05 match native
setup. The AFU top's only staging delta enables the simulation-tested completion
configuration for **offline implementation qualification**; maintained default is
disabled and no hardware activation is authorized by this acceptance.

Verified simulation: six numerical cases, 133 integer results, 1600 copied result/
guard bytes; native B-error and premature DMA-GO rejection; intermediate split-B
error observation before suppression; bank1-only reset invalidation. Native,
effective and outer exits are zero, preservation checks pass, and diagnostic errors
are empty. Warnings and failed prior attempts remain preserved.

This closes the functional candidate milestone, not physical implementation or the
project goal. Acceptance is conditional on one exclusive owner, ordered programming
and no outstanding DMA at launch. Bank0 read errors remain outside completion-error
telemetry; numerical copyback checks stay mandatory. Actual 3.000 ns timing,
reset/CDC, OPAE/card arithmetic, final boot/DDR/sustained operation and clean teardown
remain separate acceptance gates.

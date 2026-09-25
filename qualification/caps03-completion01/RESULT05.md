# CAPS03 functional acceptance and review disposition

The independent design review `deleg_90848114` accepted the finite completion
mechanism under one exclusive owner, valid ordered programming, no outstanding
DMA at launch and stable memory clocks/resets. This is not hardware acceptance.
Its bank1-reset finding is addressed with the unchanged vendor
`ofs_plat_join_resets` in the additive `ia840f_ahls_memory_reset.sv`.
Its source-selection finding is addressed by binding the exact tested bank0 shim
from the simulation capsule, not the different repository-original shim.

## Actual sim05 result

[Hash-bound native result](sim05-result.json), [HLS log](sim05-capture/vsim.log),
[split-response log](sim05-capture/split_fault.log).

- Six numerical cases, sizes 1, 8, 17, 65, 9, 33: 133 integer results and 1600
  copied result/guard bytes passed through the real generated HLS and DMA path.
- The completion CSR, not a white-box retirement delay, admitted copyback.
- Native B-error and premature DMA GO prevented success.
- The separate actual-PIM fixture observed an errored intermediate split response
  before suppression: native AW/W/B=2/4/2, upstream B=1, observed split error=1.
- A bank1-only reset after completion cleared the application/completion state;
  release returned idle with no false success. This is reset distribution evidence,
  not active-transaction recovery or stopped-clock/hardware qualification.
- 30 DMA descriptors and 402470 integration checks, including negative cases.
- Native/effective/outer exits all 0, no diagnostic errors; original inputs,
  copied inputs and tools unchanged; no owned native processes remain.
- The original local completion unit result remains 11 cases/71 checks. sim01's
  compile failure and sim03's insufficient split-coverage attempt remain retained.

## Build boundary

Reuse Work21 and the existing generated full-width HLS/fabric. Select the exact
simulation-bound bank0 shim/core/DMA, the new bank1 completion shim, guard, monitor
and vendor-reset integration. No mailbox, epoch, snapshot or custom CDC remains.

The maintained top is disabled by default. The offline qualification source copy
must instantiate the tested `COMPLETION_SUPPORTED=1` configuration: otherwise start
is constant-rejected and synthesis can prune the completion logic we need to time.
This is an explicit **unaccepted, offline-only build candidate**, not permission
to activate publication on the card. No deployment before synthesis/fit/actual
3.000 ns timing and reset/CDC review. No source clock relaxation or new exception.

OPAE numerical execution, final-image boot, final DDR/sustained tests and clean
lifecycle remain open. Output B errors do not cover bank0 read errors; copied-back
numerical verification stays mandatory.

# Work14 isolated PCIe constraint comparison01

## Scope

A new source-bound **offline A/B STA experiment**, not a refit or maintained-source promotion. The accepted E2 diagnostic is published at `686223f0638d37cef8b62410d743030950dd9bfb`. Parent has consumed its result review. The [source recommendation](../exception-disposition-research.md) supports this bounded hypothesis. Joe's renewed safe-iteration authority covers ordinary source/build/offline work; original Work14, SOURCE, PIM and previous attempts remain immutable. `ready_for_build=false`; no FPGA/OPAE/device/sysfs/PCI/JTAG/programming/reset/reboot actions.

- A: new copied Work14 fitted database, original top.sdc constraints, finite new reports.
- B: separate equivalent copy; replace only the obsolete generated-clock command at top.sdc:35–37 with a source of the separately bound guarded clock helper and its invocation. Do not alter any existing asynchronous group, multicycle or generated vendor SDC.
- Define exactly `pcie_wrapper|pcie_ss.top|host_pcie.pcie_ss|pcie_ss|avmm_clock0`, modern observed divider `inclk`/`clock_div2`, existing `sys_pll|iopll_0_clk_100m` master, divide_by2. No nominal period/phase, new base clock, blind `-add`, overwrite, rename-to-evade-groups or PLL change.
- On this exact Work14 baseline, any pre-existing output clock is a changed starting state and rejects the attempt. Future already-correct vendor flows need separate reconciliation; this experiment does not claim a general idempotent source solution.

## Reporting and interpretation

The installed Quartus26.1.1 help is captured in `../api-help01` and `../api-help02`. `get_clocks -of_objects` supplies propagated/target clock information; unlike E2's target-name-only comparison, it is used on the actual divider input/output and receiver keepers. Load normal SDC order, positively confirm candidate helper execution and actual SDC filenames, then update timing. Original fitted QDB may reference preserved ordinary-file generated SDCs; this is not an OS sandbox or a claim of hermetic reads.

Use structural fanout/adjacency inventories to retain physical paths even if baseline unclocked paths cannot appear in `get_timing_paths`. Record all clock definitions and group memberships; compare global clock-transfer matrices and exception summaries. Enumerate timed, false-path and applicable data-delay endpoint pairs to/from the complete divider load set. Native `-false_path` reports cut paths without removing constraints; do not reclassify their hypothetical slack as active timing coverage. Detailed exception reports include clock groups and overridden multicycles. The multicycles have no safety credit while dominated by the asynchronous cut.

For every enabled operating condition, retain all global domain summaries, global worst-path samples (explicitly samples), complete affected bounded endpoint-pair inventories, full numerical net-delay reports, skew results, unconstrained-path reports and min-pulse-width results. Verify all eight previously invalid FIFO assignments remain represented and become numerical; evaluate actual source/destination periods and required/actual/slack, not hard-coded limits or warning counts. Full transfer-matrix changes outside the C load set are a **coverage gap to investigate**, not implicitly accepted by the scoped enumeration.

Installed `report_design_assistant` and `report_drc` names were unavailable in the no-project STA help context. The experiment uses documented `check_timing` checks for clock validity, multiplicity, uncertainty and exception consistency. This is not a substitute claim for full post-fit Design Assistant sign-off; the existing High-rule violations remain open.

## Finite limits and failure behavior

Two serial native runs only, baseline then candidate. No candidate launch if baseline execution/preservation fails. Separate exclusive claims/logs/report roots; installed STA hashes, exact executable/argv/cwd and live runner ancestry are bound. Require owned tmux, host/UID and at least80GB available RAM with no competing Quartus/qsys process. Per-native address-space cap64GiB, per-file cap128MiB, wall limit1800s, report-total cap1GiB. Cap failure terminates only that owned ordinary-file subprocess group, preserves raw status and partial output, and never triggers a retry or another stage.

Query limits: at most256 clocks,4096 divider loads,4096 adjacent nodes per load and50000 emitted adjacency records; path queries request20001 unique pairs and reject when count reaches20001; at most16 analysis corners. Bounded exception/skew output hitting its limit is incomplete and prevents promotion. Numerical negative slack is retained as evidence and is not converted into a script failure or waiver; native/query/preservation completion and numerical acceptance remain separate.

## Required review/result gates

Prepare actual readback/manifests; test source-bound missing-authorization rejection and local inert Tcl guards. Obtain fresh independent SPEC→QUALITY reviews, parent exact-binding consumption and one-use authorization before either native analysis. Afterward independently review actual A/B preservation, loaded-source identities, clock propagation/ratio, numerical FIFO checks, full changed-transfer/exception coverage and every report cap. No source promotion or constrained fit is implied by experiment execution or native rc0. The separate EMIF1−0.004ns hold and hardware gates remain unresolved.

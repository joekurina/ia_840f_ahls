# Parent acceptance — connected AHLS numerical simulation

**ACCEPT_CONNECTED_NUMERICAL_SIMULATION_AND_SCOPED_CORRECTIONS.** FINAL [independent review](independent-review01.md), SHA256 `d5de4e1dc031bbb15e72c3c3f5e6ebee401a286a98f390f20c6212fd3583e733`, consumed after [parent re-verification](parent-review-verification02.json) of54 frozen files,4219 source payloads across8 runs, all dispatch/result/log receipts, and native lifetime/preservation records.

Path08 passes with native/effective/outer0:4cases at n=1,8,17,65;91 correct signed-int sums;1088 copied bytes checked, comprising364 result bytes and724 guard/padding bytes;16 DMA transfers;2729 total checks. All sums in these cases are positive despite mixed-sign operands. Native simulation0errors/255warnings and compilation0errors/43warnings remain unwaived. [Cases](cases08.json), [result and scope](RESULTS08.md).

Accepted narrow corrections: two fixed-bound generated LSU reset loops expanded to constant-index assignments (three hunks, events/reset/NBA values and non-reset logic preserved); final bank shim03 uses existing PIM page splitting/NO_REPLY/WLAST/metadata/CDC and a legal internal LEN5; fixture RLAST expectation removed only at the actual AXI-Lite boundary. Earlier failed variants and native0/fatal outcomes remain failed. Do not compile duplicate wrapper variants.

**R1 retained:** no negative/zero result, signed extremes, source burst over32beats, HLS page-crossing store, exhaustive alignment/protocol or maximum descriptor coverage. **R2 retained:** first library collector rc1 lacks a preserved exact traceback; the later mapping evidence supports but does not retroactively supply it. No unchanged rerun is required.

The numerical oracle does not drive result memory. However the fixture waits for synthetic accepted-store byte counts and B inactivity before copyback. That is explicitly **not a deployed software fence/global drain**, nor permission to release pinned buffers, retry/reset or reconfigure. Primary PCIe mapper/OPAE and physical DDR are not simulated; host endpoint uses the disclosed linear line-request convention. No FPGA timing or hardware-equivalence claim follows.

The exact source candidate subsequently completed a separate Quartus25.1 A&E gate (`qualification/ahls-memory-pim02`); its acceptance/publication remains independent. Review text saying that step is outstanding is historical, not permission to rewrite this frozen report. Upper-MMIO protection/posted errors, telemetry, control/drain/fences, freeze/PR/fullFIMsignoff, large/sustained physical tests and durable boot remain open.

No FPGA/device/driver/flash/reboot operation. Vendor DDR simulation remains **SKIPPED BY USER**. Goal incomplete.

# Work22 completed physical result — timing rejected

**Completed native implementation; not a deployable image.** Native/CMake/effective/outer status is0, Fitter and Assembler completed, but the exact EMIF1 bit243 hold transfer remains **−0.004 ns at Fast vid2 100°C**. No programming, device test, reset or reboot occurred. Work22 is preserved and must not be restarted.

## Evidence and independent disposition

- [Independent fit/STA review49](timing-review49.md), `deleg_ebbca77d`, SHA256 `7c55f54a7073d2428f58b2046fd6f0d8d33f8d0e33b658c981d0e273f5f0f9b2`; [parent consumption52](review-consumed52.json). The parent rechecked all nine timing47 members against decoded capture bytes and hashes, plus the new PR/electrical rows. Fitter completion is accepted with findings; timing and deployment are rejected.
- [Final completion51 receipt](completion51-collection.json) and local-only compressed capture retain eleven verified exports, terminal status, Assembler/flow reports, final project metadata and a3,963-entry reusable-input inventory. The collection observed no active vendor processes. The completion waiter separately observed outer0 at `2026-10-01T18:18:44.878632+00:00`; delayed notifications do not mean an active build.
- Assembler report records **Successful**, AGFB027R25A2E2V, **0 errors/1 warning**. Warning20536 says legacy GENERATE_RBF_FILE is ignored by the compilation flow. This is a native artifact-generation observation, not timing/electrical/persona acceptance.
- Full-device SOF SHA256: `3d2996d40bec2e7ae4544aa46aa39049bd3a9d06aef7a5759a2f6517e7e12cf9`,7,845,411bytes. Exported static QDB: `da69c84ae7ec47de9320fa11ead914de0c7b60dd527f6b6e09a18e24b25ed9e8`,78,549,439bytes. Images/QDB stay local to the workstation; PMSF/MSF intermediates and green-region RBF are separately inventoried, not relabelled qualified personas.
- Generated FME interface identity: `c67b3296-1a3d-58f1-867c-df13480baf4c`. Not a programmed-image identity or compatible-persona approval.

## Timing and findings retained

All788 summary records are accounted for; exactly one is negative. The exact transfer has hold slacks **+0.132,+0.167,+0.047,+0.006,−0.004 ns** across the five native corners, every path explicitly **No SDC Exception on Path**. The physical launch remains a Hyper-Register. Actual fit-only10ps markers and STA signoff-skip markers are verified; no margin inflation or waiver is granted.

The81 clock-table rows match Work21, and the actual PLL remains1410MHz VCO with the expected seven outputs. All144 prior net-delay identities remain, with two additional generated debug-FIFO constraints; all146 pass. The new minimum1.022ns and old1.024ns belong to different RX/TX constraints. Two MPW summary checks are no longer reported even though their clocks remain; the reason is unproven.

Preserve23/88 failed DRC rules and zero waivers, disclosed unconstrained I/O, PR initialization/freeze and reset findings,1,077 dangling PR inputs including `pr_freeze_to_afu`, and missing explicit SYS_REFCLK termination alongside the BMC-pin warnings. These are not cleared by completed fitting or scalar-AFU compilation. Existing project-approved nonblocking findings remain findings, not new gates for the bounded offline seed experiment.

[PIM review42](pim-user-type-review42.md) and [parent consumption53](pim-review-consumed53.json) rule out the simple scalar-user-collapse interpretation: the actual exit skid is580bits and SOP bit513 appears in native merges. The exact dynamic SOP/commit driver equation was not read back. Ordinary compiler semantic trust supports the unchanged offline retry; no categorical warning closure, DM1/new-persona proof or hardware qualification is claimed. No new source correction or diagnostic campaign was launched.

## Next bounded experiment

Prepare a separate Work23 with **SEED2→3 as its only physical-design setting change**, plus necessary path/gate/metadata rebinding. Reuse accepted generated IP/HLS outputs and headers; do not regenerate standalone artifacts. Preserve Work22 inputs/results and the unchanged3.000ns, floorplan, clocks, exact-register retiming restriction, snapshots, four-line PCIe constraint and existing fit-only margin.

The parent verified that the comparable W15–W18 and Work22 fits all used seed2; repeated failure is not a multi-seed experiment. Compared with the passing Work21 path, Work22 retains the same physical data sites and0.288ns data delay. Matched native arc rows show the0.086ns advantage in Work21 consists of0.084ns clock-compensation difference at `TILECTRL_X172_Y0_N298|pa_core_clk_out[0]` and0.002ns clock-interconnect difference. This identifies a comparison target, not a proven tool defect or promised seed remedy. Reconcile those terms and every corner in the successor. If it repeats the same failure/path/timing terms, do not continue blind seed iteration.

The [vendor floorplan review](../vendor-floorplan-review01/REVIEW.md) establishes that the stepped geometry is inherited and actually consumed. Static placed ALMs occupy75.27% of the90,320-ALM static allocation; whole-chip7% utilization is not static headroom. No region modification follows from this observation.

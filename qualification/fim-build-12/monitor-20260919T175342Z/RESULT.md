# Work12 bounded monitor — FINAL: compile complete, native+runner rc0

Batch: `monitor-20260919T175342Z` (local: `new_bsp/new/qualification/fim-build-12/monitor-20260919T175342Z/`, remote: `E/monitor-20260919T175342Z/`). Read-only; no build/process/claim/source modification. Owned tmux session `ia840f_mailbox_monitored_01`; fresh windows `@486` (failed transport attempt, receipt retained), `@488 w12mon-175342-run3` (monitor, rc0). Existing panes incl. `@483/%483` untouched.

## Outcome

The once-only Work12 full compile **finished before this batch's first sample** (ended 2026-09-19T12:36:31Z; this monitor first read state at ~17:56Z). Relative to the RUNNING-HANDOFF (11:43Z, synthesis active): synthesis, fitter, STA, and assembler all completed; flow status **Successful**; native returncode **0**; outer runner returncode **0**; `gate_rejection:false`; zero Error/Fatal diagnostics and zero gate markers (`IA840F_GATE_REJECTED` / `NOT READY` / `EXPERIMENTAL GATE:` / `125091` = 0) across native.log and all stage reports.

- Wall time 11:41:16Z→12:36:31Z ≈ 55m11s (native.log final elapsed matches). Stage elapsed: Synthesis 00:07:15, Fitter 00:36:51, Timing Analyzer 00:01:01, Assembler 00:05:40.
- Fitter Successful 05:25:42 (remote-local), 78,716/912,800 ALMs (9%), 321 pins, 1 P-Tile, 8 PLLs. Quartus 26.1.1 Build 130 SC Pro, AGFB027R25A2E2V, Final models.

## Timing: W12 vs Work11 (full STA, not reduced)

W12 full STA `ofs_top.sta.rpt` 46,655,195 B, SHA256 `3dbae18d751539cdc76de0d7f9b6402f6fb71e911a703b59211e6c6ab2a29081` (retained in `readback/captured/output_files/`).

- **W12 has exactly one negative-slack row**: Hold `emif_1_phy_clk_l_0` −0.004 ns, TNS −0.004, Fast vid2 100C. All Setup checks met; worst setup slack +0.093 (pcie ptile rx_ch15, Slow vid2b 100C).
- Work11 (full STA rehashed locally: `9b851e84ea597e8c7b8b846d630609ce69ed6436ce555cc853858f6ec91f838c`, 46,834,561 B — matches handoff) had **3** violations: Setup emif_0_core_usr_clk −0.508 (TNS −185.081), Setup emif_1_core_usr_clk −0.170 (TNS −29.340), Hold emif_1_phy_clk_l_0 −0.004.
- **Delta: both MSA setup violations are eliminated in W12; the −0.004 hold on emif_1_phy_clk_l_0 is unchanged between builds.** Timing acceptance remains PENDING REPORT REVIEW (`compile_fit_assembly_timing_acceptance` in status.json); native rc0/assembly is not timing acceptance.

## Programming images (separate MSF/PMSF intermediates)

| File | Bytes | SHA256 |
|---|---:|---|
| ofs_top.sof | 8,744,710 | `f0710784aff43e76a0acadc48bee84c947951abb8d7fbdfffd9bedb9c9864616` |
| ofs_top.green_region.rbf | 8,458,240 | `e5ebd5849c076aa4e1e5af1e9f51eea157aee905a4a4581f59174121b4e74ecf` |
| ofs_top.green_region.pmsf | 8,109,814 | `18db06019311175a6eb7ef124f87790d978f1d2e26e42ce0b9faf3daa6b7c818` |
| ofs_top.static.msf | 3,341,315 | `241d61e9db4fe30653e3d67bd0b959e051c149d849ef57e600e8ecadec53bfef` |

## Evidence integrity

Export via unique buffer `monitor-20260919T175342Z-export`: archive 3,795,017 B, SHA256 `9fa7c1710945d2d4b62b1202bbebbecb3cb6b5107a2cb5f3c51fa5009fd1edbc` (declared==computed), 32 members. All 31 manifest files rehashed locally: **0 failures**. Key hashes: status.json `bf9340b2…`, native-status.json `4ee41119…` (rc0 @12:36:31.614Z), runner-returncode.json `f1ace7fc…` (rc0 @12:36:31.629Z), native.log `437fbe02…` (3,042,729 B), invocation.json `ed280035…` (matches handoff), claim `b8c1d51c…` (matches handoff).

## Issues / notes

- First window `@486` failed before any work: launch referenced a script path before the remote dir existed. Receipt in `window-486-failed-receipt.txt`; no window/claim consumed; retried via scp'd hash-verified `monitor_run.py` (`3fae98b6…`) in `@488`.
- Only `snapshot-00` exists (build already finished at first sample — no in-batch progression observable by design).
- No next monitor needed: build is complete. Remaining decision for parent: the −0.004 ns hold violation (identical to Work11) — accept or iterate.
- All qualification flags remain false; AFU is the default standard exerciser; no DDR sim, no hardware ops, no gate/source/work edits, no commits.

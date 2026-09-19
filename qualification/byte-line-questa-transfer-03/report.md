# Bounded adapter Questa simulation — PASS

User approved simulations excluding detailed calibration, long traffic and extensive reset/error tests. Test scope is unchanged byte-to-line adapter with real PIM interface in unit fixture, not generated BSP/DDR4 integration.

Actual run: remote qualification/byte-line-questa-run-03, launched in ia840f_mailbox_monitored_01:questaunit03. Full retrieved and SHA-verified receipts/logs: run-03-evidence.json. Both runner and simulator returncode 0. All 154 CHECKED records sequential; unique exact `PASS scenarios=154 checks=160007`. Native transcript: 0 errors, 0 warnings, $finish at 1546 ns. Compile elapsed 0.115972 s; simulation elapsed 1.768176 s; summed vendor-stage elapsed 2.231010 s. Inputs and tools unchanged.

## Corrections and preserved attempts

Run01 rejected unsupported vlib -version. Package02 removed only that version probe. Run02 rejected vlog-12110 because isolated modelsim.ini lacked VoptFlow=1. Diagnostic03 established supported setting with real bounded version probes. Package03 adds `[vsim] VoptFlow = 1`; no error suppression or HDL changes.

Initial package03 write was blocked by file-write protection; initial staging/inert logs therefore describe unchanged package02 bytes and are NOT final correction evidence. Targeted patch applied afterward. First corrected staging command exceeded tmux command length and did not run. Compressed corrected staging succeeded before any run03 invocation. Final stage receipt: corrected-stage-readback.txt. Final package manifest SHA256: ad0590c42d4d9337e0d6aadcdfe505853177dce8be4842aafa901104e94e611f. Corrected inert tests: 4 passed in disposable copy. Prior evidence retained.

## Acceptance boundaries

| Check | Result |
|---|---|
| Sealed package and input hash validation | PASS |
| HDL compilation | PASS |
| Bounded adapter simulation | PASS |
| Ordered checks and exact success marker | PASS |
| Post-run input/tool identity | PASS |
| Full DDR4/BSP simulation | NOT RUN |
| Physical calibration, timing, hardware | NOT RUN |

Reset coverage is simultaneous reset/stall overlap, not interruption of an already-stalled write. No maintained source changes, programming, commits or pushes. BSP readiness remains false.

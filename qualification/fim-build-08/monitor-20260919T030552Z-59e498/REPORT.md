# Work08: placement preparation reached; compile still running

Last snapshot: 2026-09-19 03:08:58 UTC (September 18 20:08:58 PDT).

- New verified milestone versus previous snapshot: native log line 8883, Info (170189), "Fitter placement preparation operations beginning". Lines 8880–8882 record added slack to base iopll clock crossings, high-frequency FIM user-clock constraint application during quartus_fit, and Placement Effort Multiplier 1.0. Last line 8886 is truncated to "Info (170191): Fitter plac"; no completion is inferred from it.
- Fitter PID 110405 remains running (elapsed 23:24, accumulated CPU 01:47:11), with flow PID 108175 and native PID 108158. status.json remains state=running; no native exit code is available.
- Native log remained 2,535,534 bytes across 13 samples during this bounded observation. A quiet log alone is not proof of a stalled fitter.
- No actual Error diagnostic, IA840F_GATE_REJECTED, or 125091 found in copied native log/reports. Synthesis remains successful: 0 errors, 34 warnings. Info 21650 at native line 8177 still records qsfp_ref_clk CC19 preserving unused channels.
- No final fit/place/route, STA, or assembler summary is available in the captured report inventory. flow.rpt's Successful status is the earlier 19:45:28 stage, not full compilation success.
- Clock/constraint review remains pending: unmatched sys_pll clock uncertainty, ignored PCIe false-path collections, non-dedicated bwbmc_fpga_max_sclk, absent AFU region target, and S1 removed oscillator exception cannot be resolved using these partial artifacts. No effective fitted STA exception/transfer inventory is available; absence is not proof of a no-op.

## Evidence

Reused the previous bounded collector in a new exclusive directory. Remote hostname Agilex7Workstation and UID 1000 verified by collector. All remote actions used tmux session ia840f_mailbox_monitored_01, owned monitoring pane %339; build pane %324 untouched. Exact commands are recorded in monitor-metadata.json. Collector source, console output, 13-sample snapshot, status, native log, reports, source-path/SHA256 receipt, verification, and line-numbered diagnostics are preserved. All 11 copied source artifacts independently SHA256-verified against receipt.json.

Local: /home/joe/Projects/Thesis/AHLS/new_bsp/new/qualification/fim-build-08/monitor-20260919T030552Z-59e498
Remote: /home/uwb_student00/ahls/new_BSP/qualification/fim-build-08/monitor-20260919T030552Z-59e498

Readiness and functional acceptance remain false. DDR simulation SKIPPED BY USER. No build restart, new Quartus invocation, input/constraint changes, process stop, hardware programming/reset, driver/install changes, commits, or push. Existing compilation continues independently.

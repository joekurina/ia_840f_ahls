# Work08 placement successful; overall compilation still running

Latest process/status sample: 2026-09-19 03:14:55 UTC (September 18 20:14:55 PDT).

- NEW verified milestone: ofs_top.fit.place.rpt dated September 18 20:11:42 explicitly records Info (170137) Fitter placement was successful, Info (170192) placement operations ending (00:03:45), and Physical Synthesis operations ending (00:01:24). See milestone-lines.txt for exact lines. Native log is buffered/quiet and still ends with partial Info (170191); report evidence supersedes that incomplete tail.
- Overall state remains running. Fitter PID 110405 elapsed 29:22, CPU 02:29:13; flow PID 108175 and native PID 108158 remain present. Across 15 samples CPU increased from 01:58:29 to 02:29:13 (+1844 CPU seconds) despite unchanged native-log size 2,535,534 bytes. Quiet native logging is not a stall diagnosis.
- No fatal Error diagnostic, IA840F_GATE_REJECTED, or 125091 found in final captured artifacts. Synthesis remains successful (0 errors, 34 warnings); Info 21650 confirms qsfp_ref_clk CC19 channel preservation.
- No route/final-fit/STA/assembly completion established by captured artifacts. flow.rpt Successful is stale synthesis-era status at 19:45:28, not full compilation success. Clock/S1 exception review remains pending; no absence/no-op inference from partial reports.
- Host Agilex7Workstation UID 1000 verified. Remote work confined to separate monitoring pane %340 in ia840f_mailbox_monitored_01; build pane %324 untouched. No new Quartus invocation, restart, stop, source edits, readiness change, hardware/driver/install action, or commit. DDR simulation SKIPPED BY USER; readiness and functional acceptance remain false.

## Evidence

Local: /home/joe/Projects/Thesis/AHLS/new_bsp/new/qualification/fim-build-08/monitor-20260919T031118Z-89da00
Remote: /home/uwb_student00/ahls/new_BSP/qualification/fim-build-08/monitor-20260919T031118Z-89da00

Collector source, exact SSH/tmux commands, console, timestamped status/process samples, final native log and reports, source-path SHA256 receipt, and verification are preserved. All 12 copied artifacts SHA256 verified against receipt. Log/report transfer performed once, after bounded observation. Collector polled native log only during the interval; successful placement was discovered in the final report snapshot, demonstrating why future collectors should also check stage reports during polling.

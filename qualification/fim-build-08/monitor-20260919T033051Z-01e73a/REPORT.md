# Work08 bounded read-only continuation

Outcome: fitter completed; final STA executed but timing FAILED; assembler still running at final sample. No native exit observed.

- Six samples from 2026-09-19 03:31:04Z through 03:34:14Z (September 18, 20:34:14 PDT final).
- Verified Agilex7Workstation UID 1000; all remote operations through tmux session ia840f_mailbox_monitored_01, own window/pane %343. Build pane %324 untouched. No build restart, extra Quartus invocation, source/constraint edit, or process control.
- Native log line 8930: Fitter successful, 0 errors, 202 warnings; ended 20:28:44 PDT, elapsed 00:43:10. Fit summary status timestamp 20:28:40.
- Native log line 9490: Critical Warning (332148), Timing requirements not met. Worst-case setup slack -0.366 ns. STA summary: emif_1 core user clock slack -0.366 ns, TNS -117.103 ns; emif_0 core user clock slack -0.236 ns, TNS -61.410 ns, Slow vid2 100C Model.
- Native log line 10182: Critical Warning: DDR Timing requirements not met. Design not fully constrained for setup and hold; invalid PCIe set_net_delay destination clock reported.
- Final Timing Analyzer execution successful at 20:32:48 PDT: 0 errors, 240 warnings. This is tool execution success, NOT timing acceptance. PR SDC export Timing Analyzer successful at 20:33:30, 0 errors, 181 warnings.
- Final sample: quartus_asm PID 115772 Rl+, elapsed 00:20, CPU 00:00:19; native PID 108158 and flow PID 108175 remain live. run/status.json remains running; ready_for_build=false and functional_acceptance=false.
- No Error/Fatal or gate rejection found; scan included Critical Warning (125091), not merely Error (125091). Other critical warnings, including timing failure, remain present.
- No SOF/RBF/POF/JIC in output_files at final snapshot. No assembler completion report captured.
- Final fitter resource summary: 86,223 ALMs (9%), 232,567 dedicated logic registers, 664 RAM blocks (5%), 8 PLLs (22%).
- S1/TRS oscillator and complete clock/resource/exception review remain unresolved. DDR simulation remains SKIPPED BY USER; timing analysis does not substitute for simulation.

Evidence: 20 report/status/log files collected once at monitoring end and independently verified against remote SHA-256 and byte-size receipt. Includes final fit and STA reports/summaries. receipt.json, verification.json, snapshot.json, monitor-code.py and monitor-metadata.json retain provenance. Matching remote directory is /home/uwb_student00/ahls/new_BSP/qualification/fim-build-08/monitor-20260919T033051Z-01e73a.

Local continuation runner: /home/joe/work08_monitor_continuation_readonly.py. Prior collector and evidence untouched. Monitor finished; Work08 left running unchanged.

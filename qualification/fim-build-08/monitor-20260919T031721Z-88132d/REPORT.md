# Work08 bounded monitor

- Routing milestone observed: ofs_top.fit.route.rpt line 458, Info (16607): Fitter routing operations ending: elapsed time is 00:05:38. Report mtime 2026-09-18T20:17:22.614029-07:00.
- Build still running at 2026-09-19T03:21:27.415956+00:00; fitter PID 110405 Rl+, elapsed 35:42, CPU 03:04:01. CPU increased 1140 seconds over 10 samples; native.log remained 2535534 bytes, not evidence of a stall.
- Stage reports read on every poll. Route-ending wording was not matched by early-exit regex (ended/complete), so collector ran its bounded duration; corrected reusable local collector to include ending.
- No fatal Error or gate 125091 observed in native log. Synthesis successful, 0 errors, 34 warnings; Info 21650 confirms qsfp_ref_clk CC19.
- No final fitter, STA, or assembler completion established. Early flow report success is not full-build success. No standalone STA/assembler report in captured output_files inventory.
- Pending constraint review unchanged: sys_pll clk50m, PCIe false paths, BMC sclk, AFU region, and removed S1 ALTERA_INSERTED_INTOSC_FOR_TRS|divided_osc_clk exception. DDR simulation SKIPPED; readiness false, functional acceptance false.
- Existing build untouched; all remote operations through named tmux session ia840f_mailbox_monitored_01, exclusive monitor pane %341; no new Quartus invocation.
- Evidence transferred once at end via tmux buffer; all 14 receipt-file SHA256 hashes verified locally. Remote directory: /home/uwb_student00/ahls/new_BSP/qualification/fim-build-08/monitor-20260919T031721Z-88132d. Local collector and metadata retained here.

# Work08 bounded milestone

- Last sample: 2026-09-19 02:57:47 UTC (September 18 19:57:47 PDT).
- Synthesis successful: 0 errors, 34 warnings; native log line 8051. Synthesis summary records completion September 18 19:45:20 2026.
- Actual fitter BTI decision observed: `Info (21650): REFCLK qsfp_ref_clk at location CC19 is used to preserve unused channels` (native log line 8177; ofs_top.fit.plan.rpt line 8463).
- No Error, 21636, or 125091 matches in preserved reports/native log. This is not final fitter/functional acceptance.
- Fitter still running PID 110405; flow PID 108175, native PID 108158, runner PID 108156. Periphery placement ended with elapsed time 00:09:57. No completed fitter result yet.
- Preserved existing fit.plan report has zero matches for `ALTERA_INSERTED_INTOSC_FOR_TRS` or `divided_osc_clk`; no STA report was present in the output_files *.rpt snapshot. This is NOT proof of clock absence: no complete clock report is available. No additional Quartus tools were launched, and no constraints were changed.
- Readiness remains false; DDR simulation SKIPPED BY USER; no hardware programming/testing.

## Evidence

11 original status/log/report/summary files copied into this directory; all SHA256 values in receipt.json independently verified locally in verification.json. snapshot.json contains 17 timestamped samples, process IDs/arguments and milestones. monitor-metadata.json records exact SSH/tmux commands and pane %336, session ia840f_mailbox_monitored_01. Remote monitor PID is in snapshot.json; local collector PID 4148134. Existing build pane %324 and earlier monitor pane %327 untouched.

Remote counterpart: /home/uwb_student00/ahls/new_BSP/qualification/fim-build-08/monitor-20260919T025343Z-ecec9b
Local counterpart: /home/joe/Projects/Thesis/AHLS/new_bsp/new/qualification/fim-build-08/monitor-20260919T025343Z-ecec9b

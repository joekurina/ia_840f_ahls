# Work09 placement milestone; routing in progress

Observed 2026-09-19 04:42:53–04:48:23 UTC across 9 bounded samples.

- `ofs_top.fit.place.rpt` line 9070: `Info (170137): Fitter placement was successful`; next line records placement ending (00:03:48). This was already present in the first new sample; no exact wall-clock placement completion time is claimed.
- A fitter routing report now exists. Full fitter/route completion and final timing are not established. No final STA report was present in the captured output_files report inventory.
- PID 126976/start ticks 7930670 remains the Work09 quartus_fit child of flow 125068, under native 125051 and runner 124991. Executable hash, argv, cwd and ancestry captured. CPU ticks rose from 837125 to 1077262.
- All sampled reports and final copied reports have no Error/Fatal, Critical Warning (125091), or IA840F_*REJECTED matches. Native log remains behind stage reports; it is not used as sole progress evidence.
- Readiness, timing acceptance and functional acceptance remain false. No build controls, source/gate edits, query runs, DDR simulation, hardware operations or commits.

Evidence is in `verified/`: nine sample JSON files plus one final report/log snapshot, monitor source, invocation and summary. `verification.json` confirms 27 manifest files and archive bytes/SHA256. Archive: 2154393 bytes, SHA256 `20122dabf4a808603bcfe2d2fc88eb9480cfcbf9f90c13e009dc11c71e5f247a`.

Remote evidence: `/home/uwb_student00/ahls/new_BSP/qualification/fim-build-09/monitor-compact-20260919T044253Z`.
Own tmux window: `ia840f_mailbox_monitored_01:work09_compact_20260919T044227Z`. Existing panes untouched. Local `ssh-invocation.json` records exact remote command; `driver.py`, `transfer.json`, `pane.log` and `verification.json` preserve transfer provenance.

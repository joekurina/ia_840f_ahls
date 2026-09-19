# Work09 routing/fitter milestone captured

Observed 2026-09-19 04:56:05–04:58:58 UTC, five bounded read-only samples in owned tmux window `ia840f_mailbox_monitored_01:work09_routing_20260919T045601Z`.

- Routing ended: `ofs_top.fit.route.rpt:458`, Info (16607), elapsed 00:05:23; also `ofs_top.fit.rpt:44311`.
- Fitter succeeded: `ofs_top.fit.rpt:124` and `ofs_top.fit.summary:1`, tool timestamp Fri Sep 18 21:58:49 2026. `ofs_top.fit.rpt:44325`: `Quartus Prime Fitter was successful. 0 errors, 202 warnings`.
- Original fitter PID 126976/start ticks 7930670 progressed from CPU ticks 1320940 to 1354911 across the first four samples; absent in the final sample. Runner 124991/start ticks 7881963, native 125051/7882108, and flow 125068/7882414 remain live. Final descendants: post-fit hook PID 133909/start ticks 8196228 and `quartus_cdb ofs_top -c ofs_top --update_mif` PID 133919/start ticks 8196442. Executable hashes, argv, cwd and ancestry are retained.
- Native stdout lagged actual reports. Final status still says running. No final STA report was present; no native final exit or timing acceptance is established.
- No Error/Fatal, Critical Warning (125091), or IA840F_*REJECTED matches in any sample. This does not mean warning-free: the fitter report includes Critical Warning (20727) about unused partition input ports, among its 202 warnings.
- Readiness, timing acceptance and functional acceptance remain false pending full review. No query04 access/retry, build launch/restart/stop, source/gate changes, DDR simulation, hardware work or commits.

## Verified evidence

`verified/` contains five compact samples and one final report/log snapshot, monitor source, invocation, summary and manifest. `verification.json` confirms all 27 manifest files by SHA256 and size, plus the complete transferred archive: 2600204 bytes, SHA256 `0f8aa3eb0657ed1bb0306826b2ed184af9f0473d7eab11a526638bbe2ff640e7`.

Remote evidence: `/home/uwb_student00/ahls/new_BSP/qualification/fim-build-09/monitor-routing-20260919T045605Z`. Transfer used a unique tmux buffer; all remote operational commands ran inside the named authorized session. Writes were restricted to exclusive evidence directories. Local files include monitor.py, driver.py, ssh-invocation.json, pane.log, transfer.json, evidence.tar.gz, verification.json, this report and verified/.

Context issue: RUNNING-HANDOFF.md was not inside the previous monitor directory; the existing file was read from the parent fim-build-09 directory instead.

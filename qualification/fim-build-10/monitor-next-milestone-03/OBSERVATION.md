# Work10 bounded observation — placement successful

## Outcome
- The unchanged observation approach (only exclusive batch/window identifiers retargeted from monitor-02) captured two samples at 2026-09-19 06:06:11.910418 and 06:07:52.720842 UTC. It ended early on a new placement milestone, within the six-minute observation bound.
- `ofs_top.fit.place.rpt` establishes `Info (170137): Fitter placement was successful`, placement ending in 00:03:31, and subsequent physical synthesis ending in 00:02:07. This placement marker was absent in both monitor-02's final snapshot and this batch's first sample.
- Fitter remained active at the final capture: PID 142018, start ticks 8435815, parent 140702, state R. Its CPU advanced 58217 ticks between samples. Exact argv, executable hash, cwd and ancestry are preserved in samples.jsonl and transfer-verification.json. Runner 140682/8387716, native 140684/8387852 and flow 140702/8388162 identities matched throughout.
- Native stdout lagged the stage report: unchanged 2535534 bytes, SHA256 9f303c2a5225e2e56b675b5a90cf025eed4dd646c5c534fbed5c012a5bb2ac75. This is not evidence of a stall.
- Routing completion, full fitter completion and active routing were not established by the captured evidence. No route, final STA or assembler report, native exit, or programming image was captured. Native status remains running. The older flow-success entry is synthesis-era, not full-build completion.
- Synthesis remains successful with 0 errors and 34 warnings. Error/Fatal, Critical Warning 125091 and explicit IA840F gate-rejection/not-ready marker counts were zero across captured files; this is not warning-free acceptance.
- No actual final Work10 all-corner DDR setup/hold WNS/TNS, failing endpoint counts or constraint-completeness results are available. Work09 figures must not be substituted for Work10. Readiness, timing and functional acceptance remain false; unresolved S1/PCIe divider and other review blockers are unchanged. Native exit zero, if later obtained, would not itself establish acceptance.

## Verified evidence
- Host Agilex7Workstation, UID 1000. All remote operations were through owned tmux window `ia840f_mailbox_monitored_01:work10-milestone-03`, pane `%379`, or its unique export buffer. Existing panes `%375`–`%378` were not targeted or modified.
- One final snapshot and compact per-sample records were exported using unique buffer `work10-milestone-03-143623`.
- Transfer: 4170089 bytes, SHA256 `324a5841806d1db9bf5954f42eac01efd3880096f339983da1c627c2df656d5e`.
- All 15 exported files passed remote size/SHA256 comparison and local readback verification. Exported monitor source matched the local observer.
- Placement report: 7238624 bytes, SHA256 `8e1e6258d856be7ad8a650915e9d4d368a0939146e9142350921a79c4ee29957`.

Local additions are confined to this new directory: monitor.py, launch.py, retrieve.py, launch-command.json, monitor.pane, pane-capture.txt, export.json.zlib, transfer-verification.json, readback/ and this report. Remote additions are confined to the corresponding exclusive evidence directory and owned tmux window/buffer. No SOURCE/WORK/gate edits, restart/stop, authorization reuse, extra Quartus queries, Query04, DDR simulation, hardware operation, permission/install change or commit occurred. No operational issues were encountered.

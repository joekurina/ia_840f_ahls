# Work10 bounded observation — fitter active after physical synthesis

Six verified samples: 2026-09-19 05:57:36.874431–06:03:36.073005 UTC. Host Agilex7Workstation, UID 1000. Observation used only its own tmux window `ia840f_mailbox_monitored_01:work10-milestone-02`, pane `%378`; panes `%375`, `%376`, `%377` were untouched.

## Outcome
- Genuine progress since monitor-01: native output now records periphery placement operations ending (00:09:58), fitter preparation ending (00:09:39), and Fitter Physical Synthesis operations ending (00:00:40), followed by clock-sector/fanout inventory. These messages were already present in this batch's first sample. No additional successful-stage marker appeared during its six samples; the automated `new_milestones: []` compares against this batch's first sample, not monitor-01, and matches successful/status markers rather than all operation-ending messages.
- Fitter remains active: PID 142018, start ticks 8435815, parent 140702, state R at final capture. CPU ticks increased by 316702 within this batch. Executable `/opt/altera/26.1.1/quartus/linux64/quartus_fit`, SHA256 `31e90c7dcdaee32f0dea50d633e2b6edc8bac075b44bc5caa278a9aaf016d35c`; exact argv/cwd/ancestry are in the samples and verification JSON. Original runner/native/flow start identities matched throughout.
- Native log was unchanged during this batch at 2535534 bytes, while fitter CPU advanced. No quiet-log stall diagnosis is justified. Stage report inventory was also checked: fit.plan.rpt remains present; no final placement/routing/fitter/STA/assembler report was captured. Do not infer active routing or completed placement from this snapshot.
- Synthesis remains successful: 0 errors, 34 warnings. Native status remains `running`; no final native exit or programming images exist in the captured inventory.
- Error/Fatal, Critical Warning 125091, and the three explicit gate-rejection/not-ready marker counts are zero across captured files. This does not mean warning-free.
- No final Work10 setup/hold WNS, TNS, endpoints, all-corner timing or constraint-completeness result is available to compare with Work09. Readiness, timing and functional acceptance remain false. No Query04, source/WORK/gate edit, build intervention, DDR simulation, hardware operation, permission/install change or commit occurred.

## Evidence
One final report snapshot, plus compact per-sample process/file/diagnostic/progress records, was exported from unique remote tmux buffer `work10-milestone-02-142583`. Transfer: 3815331 bytes, SHA256 `6fad992aba1513ef66a2cd3d5ea4e3475ebf2328aa85bc8fc2e9854538ed9728`. All 14 exported files were verified against remote size/hash, written locally, and read back; exported observer source equals local monitor.py. Exact launch and transport commands are preserved.

Local additions are confined to this directory: monitor.py, launch.py, retrieve.py, launch-command.json, monitor.pane, pane-capture.txt, export.json.zlib, transfer-verification.json, readback/, and this report. Remote additions are confined to the corresponding exclusive evidence directory and owned tmux window/buffer. Existing evidence and the live build were preserved.

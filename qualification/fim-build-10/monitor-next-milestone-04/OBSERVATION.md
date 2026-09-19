# Work10 bounded observation — routing and Hyper-Retimer ended

- Six snapshots: 2026-09-19 06:14:14.215862–06:20:14.447316 UTC. Observation continued through the bound, not stopped by the old placement marker.
- New relative to monitor-03: `ofs_top.fit.route.rpt` records Info (170193) routing beginning and Info (16607) routing operations ending, elapsed 00:05:36; already present in this batch's first snapshot. `ofs_top.fit.retime.rpt` first appears in sample 2 and records Info (17968) Completed Hyper-Retimer operations and Info (18821) ending, elapsed 00:01:36. These are operation-ending evidence, not overall fitter-success or timing-closure evidence. The success-only `result.json` new_milestones array is empty and must not be mistaken for absence of progress.
- At final snapshot fitter 142018/start 8435815 remained R, parent 140702/start 8388162. Runner 140682/8387716 and native 140684/8387852 identities matched throughout. Exact executable/argv/cwd/SHA256 and full captured ancestry are in samples.jsonl and transfer-verification.json. Fitter CPU advanced 213605 ticks within this batch, and 277174 ticks between monitor-03's final sample and this batch's first sample.
- Native status remains running. No final fitter/STA/assembler report or native exit was available; no SOF/RBF/MSF/PMSF image was found in the monitored output directory. Native stdout remains 2535534 bytes, SHA256 9f303c2a5225e2e56b675b5a90cf025eed4dd646c5c534fbed5c012a5bb2ac75: stage reports show progress despite buffered stdout.
- Synthesis remains successful, 0 errors / 34 warnings. All six snapshots have zero captured Error/Fatal, Critical Warning 125091 and explicit IA840F rejection/not-ready diagnostic occurrences. The synthesis-era flow-success marker is not final completion.

## Timing comparison

| Metric | Work09 baseline supplied by parent | Work10 final |
|---|---:|---|
| EMIF0 setup WNS / TNS (ns), failing endpoints | -0.435 / -152.255, 580 | unavailable |
| EMIF1 setup WNS / TNS (ns), failing endpoints | -0.313 / -86.055, 545 | unavailable |
| Worst hold (ns) | -0.004 | unavailable |
| Unconstrained clock / input / output counts | 1 / 2 / 2 | unavailable |

No all-corner Work10 WNS/TNS, endpoint, ignored-constraint or constraint-completeness conclusion can be made before final STA. No numerical improvement/regression is established. Ready-for-build, timing acceptance and functional acceptance remain false; S1/PCIe divider review blockers remain unresolved. A future native exit zero would not itself qualify the build.

## Evidence and scope

- Owned tmux window `ia840f_mailbox_monitored_01:work10-milestone-04`, pane `%380`, unique buffer `work10-milestone-04-143900`; panes %375–%379 were not targeted or modified.
- Host Agilex7Workstation / UID 1000 verified by observer. All remote operations used tmux. No SOURCE/WORK/gate changes, restart/stop, authorization reuse, extra Quartus queries, Query04, DDR simulation, hardware action, permission/install change or commit.
- One final snapshot exported. Transfer 4217171 bytes, SHA256 fac140942914e9e760cfd1aa4d4ea36bba3fcbf1601bb007d2b12350332b209c. All 17 exported files verified against remote size/SHA256 and local readback; monitor source byte-equality also verified.
- Routing report: 237942 bytes, SHA256 1f0df5128379b47badd110beb5cd8cc8b7d6a4c28d03d976444df7d3bb6a193e.
- Retimer report: 104324 bytes, SHA256 91da2f5c19c135c16db364f1a90561f0542e5a35db59dc98938fa58b7286099e.
- Local additions confined to this exclusive directory: observer/launcher/retriever, command and pane records, transfer archive/verification, readback snapshots, operations log and this observation. Remote additions confined to corresponding evidence directory and owned tmux window/buffer.
- Retrieval initially arrived before export completion and failed closed; retried after 35 seconds and verified successfully. Six-sample observation spans approximately six minutes; export/transfer time is additional. No vendor failure was encountered.

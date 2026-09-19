# Work08 completion snapshot

Native completed 2026-09-19 03:40:03Z (Sep 18 20:40:03 PDT), return code 0. Assembler successful at 20:39:23 PDT; target AGFB027R25A2E2V, Agilex 7, ofs_top/top. Full compilation reports 0 errors, 950 warnings.

**Timing acceptance FAILED; readiness false; functional acceptance false; DDR simulation SKIPPED BY USER.** Native success does not override STA/DDR timing failure. Prior independent timing review remains applicable; no duplicate review performed.

Final sample 03:41:52Z: no matching Quartus/native processes. Final fatal/gate scan includes Critical Warning (125091); no matching fatal/gate diagnostics. Native status gate_rejection=false.

## Images (not programmed; remote inventory only)
- /home/uwb_student00/ahls/new_BSP/work_ia840f_fim_08/syn/board/ia840f/syn_top/output_files/ofs_top.sof; 9277992 bytes; SHA256 01772449f7210f3a7bff9f4327a41b921bb37c56b261a0ed16ccbfec05022d49
- /home/uwb_student00/ahls/new_BSP/work_ia840f_fim_08/syn/board/ia840f/syn_top/output_files/ofs_top.green_region.rbf; 9109504 bytes; SHA256 9156400055f3947e9ab03c8650b54e50cdd41e6ce70598f7c68fd66767e78a02

## Diagnostics
- Critical Warning (332148): Timing requirements not met
- Critical Warning: DDR Timing requirements not met
- Info: Quartus Prime Assembler was successful. 0 errors, 1 warning
- Info (21793): Quartus Prime Full Compilation was successful. 0 errors, 950 warnings

Evidence: 21 report/status/log files transferred once and independently SHA256/size verified; receipt and snapshot additionally verified against remote collector hashes. Native status, assembler report, fit/STA reports and summaries, commands, process IDs, and image metadata preserved. No build restart/stop, extra Quartus, edits to inputs/constraints, programming, driver or permission changes. All remote operations used owned tmux window %344 under ia840f_mailbox_monitored_01; build pane %324 untouched.

Collector issue: initial local completion detector missed line-wrapped DONE; recovered via tmux capture-pane -J and transferred completed snapshot once. Poll terminal predicate used status instead of state, so bounded monitor continued after completion; no impact on build or captured final state.

# Work08 bounded monitor

Outcome: still running; no final fitter, STA, assembler, or native return code observed. No build/input/constraint changes or process control performed.

- Remote operations confined to new pane `%342`, separate window `monitor-20260919T032349Z-539349` in existing `ia840f_mailbox_monitored_01`; build pane `%324` untouched.
- Host verified `Agilex7Workstation`, UID 1000.
- Ten samples from 2026-09-19 03:24:00Z through 03:27:51Z (September 18 20:27:51 PDT last sample).
- Last fitter PID 110405: `Rl+`, elapsed 42:08, cumulative CPU 03:28:53. CPU increased 459 seconds across samples. Flow PID 108175 and native PID 108158 remain present.
- `run/status.json` remains `running`; readiness and functional acceptance false; DDR simulation `SKIPPED BY USER`.
- Native log remains 2,535,534 bytes, with buffered partial placement message. Activity is established by advancing fitter CPU, not log growth.
- Route report remains timestamped 03:17:22Z; historical routing-ending milestone is not final fitting completion. Hyper-Retimer report ends with Info (18821), elapsed 00:01:29, timestamp 03:19:50Z. Early flow report remains stale at 02:45:29Z.
- No final fit summary, STA report/summary, or assembler report/summary in captured output_files report inventory. No SOF/RBF/POF/JIC files in that directory at snapshot. These are snapshot-scoped statements, not assertions about future outputs or other directories.
- No actual Error/Fatal or IA840F_GATE_REJECTED lines, including Error (125091), found in captured reports/native log. Synthesis success remains 0 errors, 34 warnings; Info (21650) retains qsfp_ref_clk at CC19.
- No timing pass asserted. S1/TRS oscillator exception and complete clock/resource/exception transfers remain unresolved; prior unmatched sys_pllclk50m, ignored PCIe false paths, non-dedicated BMC sclk, and absent AFU region concerns are not resolved by this snapshot.

Evidence: 14 report/status/log files transferred via tmux buffer and independently verified against remote SHA-256 and byte-size receipt. `receipt.json`, `snapshot.json`, `monitor-code.py`, and `monitor-metadata.json` preserve source paths, process samples, inventory, collector, and exact SSH/tmux commands. Remote matching evidence directory is `/home/uwb_student00/ahls/new_BSP/qualification/fim-build-08/monitor-20260919T032349Z-539349`.

Collector stops on fatal error, disappearance of Quartus processes, or its bounded monitoring deadline—not on the old routing-ending milestone. The monitor has completed; Work08 was left running unchanged.

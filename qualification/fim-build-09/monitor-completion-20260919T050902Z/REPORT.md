# Work09 complete — native exit 0; timing FAIL; readiness false

## Final native outcome

Bounded read-only observation ran 2026-09-19 05:09:07–05:10:39 UTC (four samples) in owned `ia840f_mailbox_monitored_01:work09_completion_20260919T050902Z`. Host/UID verified as Agilex7Workstation/1000.

- Native `run/status.json` is `finished`, ended **2026-09-19T05:10:09.842816+00:00**, `native_returncode: 0`, `gate_rejection: false`. Its report-review field remains `PENDING REPORT REVIEW`; this report supplies the separate failed timing disposition, without modifying the native receipt.
- Assembler successful: **0 errors, 1 warning**; report completion Fri Sep 18 22:09:30 2026 host time, elapsed 00:05:46. Full compilation reports **0 errors, 950 warnings**. These native success statements do not establish timing acceptance.
- Original runner/native/flow/assembler PID and start-tick identities were observed: 124991/7881963, 125051/7882108, 125068/7882414, 134880/8225033. No matching original processes or their selected descendants remained at final sample. Exact executable hashes, argv, cwd and ancestry are in `verified/sample-00.json` and subsequent samples.
- Assembler warning 20536 says legacy `GENERATE_RBF_FILE` is ignored because programming-file generation moved out of compilation. The actual PR RBF below nevertheless exists; this is not evidence that a full-device RBF was generated.
- No Error/Fatal, Critical Warning 125091 or IA840F_*REJECTED matches in this captured compact report/log set. Timing critical warnings remain failures, not suppressed diagnostics.

Native command (cwd `/home/uwb_student00/ahls/new_BSP/ofs-agx7-pcie-attach`):
```sh
./ofs-common/scripts/common/syn/build_top.sh --stage=compile -k -p ia840f /home/uwb_student00/ahls/new_BSP/work_ia840f_fim_09
```
Actual assembler argv (cwd WORK09 `syn/board/ia840f/syn_top`):
```sh
quartus_asm --ipc_flow=17 --ipc_mode --read_settings_files=on --write_settings_files=off ofs_top -c ofs_top
```

## Programming image inventory

Remote prefix: `/home/uwb_student00/ahls/new_BSP/work_ia840f_fim_09/syn/board/ia840f/syn_top/output_files/`. Two programming images were found by the recorded extension inventory; bytes were hashed remotely, not transferred or programmed.

| File | Exact bytes | SHA256 |
|---|---:|---|
| `ofs_top.green_region.rbf` | 9060352 | `ae7a38d70de8a29a966d7c8a091dcb7733a44f620866af8afeca39119d80aa91` |
| `ofs_top.sof` | 9264706 | `3a2f5ae29293f6ed1d367431a75ec864a8c3d298eb2cb788dfa1d90dd43b0648` |

Assembler also lists `ofs_top.static.msf` and `ofs_top.green_region.pmsf` intermediate assembler outputs; these are not included in the programming-image extension inventory and their sizes/hashes are not claimed.

## Failed timing disposition preserved

The already-captured complete STA report was re-read locally and SHA256 reverified, not re-transferred: `../monitor-final-20260919T050111Z/verified/latest/work_ia840f_fim_09/syn/board/ia840f/syn_top/output_files/ofs_top.sta.rpt`, 46,853,462 bytes, SHA256 `eca0bb5aff2272f5e609b98a21f653d4aee3a60a2c04b367c1fecab93e315cd4`.

- EMIF0 core setup: **-0.435 ns**, TNS -152.255 ns, 580 failing endpoints (line 2749).
- EMIF1 core setup: **-0.313 ns**, TNS -86.055 ns, 545 failing endpoints (line 2750).
- EMIF1 PHY hold: **-0.004 ns**, TNS -0.004 ns, one failing endpoint (line 2780).
- Unconstrained summary lines 207920–207929: **1 clock, 2 input ports (78 pairs), 2 output ports (10 pairs)** for setup and hold. Line 207938 names the PCIe divider clock.

**Timing acceptance FAIL; constraint acceptance false; readiness/ready_for_build false; functional acceptance false. Native exit 0 and generated images do not override these dispositions.** S1/TRS and BMC IRQ/JTAG policy remain unresolved. DDR simulation remains SKIPPED BY USER.

## Evidence integrity and scope

Compact archive: 119635 bytes, SHA256 `74309f0b8d42d92b4d029abe4278fde96ebef2de43de20e2d02eca69cb2e0da3`. All 17 manifest files verified for exact size and SHA256; monitor source and batch identity also matched. Remote evidence: `/home/uwb_student00/ahls/new_BSP/qualification/fim-build-09/monitor-completion-20260919T050907Z`.

The directory contains exact SSH invocation, project-local monitor/driver, pane log, transfer and verification receipts, archive, final status/native/runner logs, assembly/flow reports, compact summaries, image inventory and process samples. No duplicate full STA report or image payload was transferred.

No source/WORK/gate edits, build restart/stop, new Quartus query, query04 interaction, DDR simulation, hardware operation or commit. Only new evidence directories and this local report/handoff documentation were written. Initial path lookup misread “read monitor-final” as “readmonitor-final”; corrected using the on-disk directory inventory before remote work. No execution or transfer failures.

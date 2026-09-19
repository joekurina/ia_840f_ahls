# Work10 seed-2 native compile — RUNNING

Verified 2026-09-19T05:31:58.288429+00:00. Fresh authorization issued once and native Quartus 26.1.1 synthesis is running. No completion or timing/functional acceptance is claimed.

## Execution
- Owned tmux `ia840f_mailbox_monitored_01:build10_execution` (pane %375); observer `build10_observer` (%376).
- Remote evidence: `/home/uwb_student00/ahls/new_BSP/qualification/fim-build-10`.
- Native start: 2026-09-19T05:30:51.670057+00:00; runner PID 140682 / start ticks 8387716; native PID 140684 / start ticks 8387852; Quartus flow PID 140702 / 8388162; synthesis PID 140735 / 8389066.
- Actual runner: `PYTHONDONTWRITEBYTECODE=1 python3 launch_native_compile.py`; actual issuer: `python3 issue_authorization.py /home/uwb_student00/ahls/new_BSP/qualification/fim-build-10/consumed-reviews.json`. Explicit tool/licensing environment is in `issued-readback/run/invocation.json`.
- Native argv: `./ofs-common/scripts/common/syn/build_top.sh --stage=compile -k -p ia840f /home/uwb_student00/ahls/new_BSP/work_ia840f_fim_10`, cwd `/home/uwb_student00/ahls/new_BSP/ofs-agx7-pcie-attach`.
- Authorization SHA256 `dac6fb16074cbec5684f1e2ac7c99a06146937809e8b3de154efc4789c255052`; consumed reviews `c76c1a67d2d352f291a9e6babadff9b513d87b6dd0f8e382fdc545e8ee9594f4`.

## Bindings and verification
Recomputed 73 unique exact review-listed file bindings and all 60 package manifest entries locally. Full live SOURCE baseline, PIM, 5564 initial WORK entries, all 106 draft dependencies and tool hashes passed before issuance. No other active compile or existing Work10 authorization/claim/run existed. Actual reviews were transferred exclusively and read back against local hashes. Timing review covers exactly five files, gate review four; inherited Work05 review covers the unchanged three DDR source files; handoff pins issuer/runner/draft. Parent disposition accepts only this bounded experiment, not constraint acceptance.

Issuer returned zero. Actual authorization, exclusive claim, status, invocation and issuance evidence are hash-verified under `issued-readback/`. Export SHA256 `35e6a19fb4daedbbc2d5240888583b7086ca213a0ad9fecd592b8e56a5c3560a`. `final-marker-check.json` verifies the live claim PID/start ticks and full synthesis ancestry through the native shell. All production rejection-marker counts are zero at observation. Executable, argv, cwd, hashes and native activity are captured; this is not merely a queued launcher.

## Native migration versus source edits
Maintained SOURCE exactly matches all reviewed overlay digests. Exactly three SOURCE files changed relative to the accepted baseline: SEED 1→2 QSF, compile gate retarget, dispatcher retarget. Nine other overlay contents are unchanged. Native project loading migrated WORK QSF to `OPTIMIZATION_MODE "HIGH PERFORMANCE EFFORT"` plus `GLOBAL_PLACEMENT_EFFORT "MAXIMUM EFFORT"`, with deprecation comment and version update. See `issued-readback/native-generated-qsf-20260919T053125Z.diff`. SOURCE retains the reviewed maximum-placement mode. All other overlay WORK hashes match. No operator edited live WORK or weakened gates.

## Limits and next observation
Follow `run/status.json`, `run/native.log` and stage reports; do not restart or reuse authorization. No watchdog added. Readiness, timing, constraint and functional acceptance remain false until final report review. Compare DDR WNS/TNS/endpoints/routing-cell composition, hold, clocks, unconstrained paths and ignored constraints. S1/TRS, PCIe divider and BMC IRQ/JTAG issues remain open. Query04 stays blocked and untouched. Work09 and Work04 were not modified. No DDR simulation, hardware, driver installation, permission changes, commits or pushes.

Project-local helpers: `execute_reviewed.py`, `observe_execution.py`, `verify_live_execution.py`; retained preflight/issuance/runner logs and exact review readbacks. No execution blocker encountered.

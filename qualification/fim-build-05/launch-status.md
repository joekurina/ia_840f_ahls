# Work05 native launch — real Quartus running, rejection observed

Observed 2026-09-19T00:01:50.998074+00:00 (2026-09-18 17:01:50 PDT).

The accepted full native compile was launched once inside persistent tmux on Agilex7Workstation, UID 1000. Actual Quartus 26.1.1 Build 130 08/06/2026 SC Pro Edition started; IP generation reported success (0 errors, 1 warning), and synthesis is running. **The post-IP-generation callback has already emitted a source-bound gate rejection. This run cannot be accepted as a successful build even if Quartus subsequently exits zero.** The reviewed monitor/runner remains running and will preserve and reject that output. No retry, claim reuse, authorization broadening or process termination was performed.

## Identity and authorization

- Parent's consumed-reviews.json was exclusively created remotely, 1022 bytes, SHA256 `339abae3e215ebc0b915a67921b3d7f5de2e08a9582d8ec64d14f837559a6176`; exact bytes were read back.
- Issuer, runner and draft matched all three reviewer-pinned hashes before execution.
- Issuer exited 0 and synchronized the seven accepted overlays to maintained SOURCE.
- Issued authorization SHA256 `2d52dc134ff2e3fba073b8c7e0acdf4351bfe1b4745ed855b01c436cf2174a18`, 1408030 bytes; complete remote bytes retrieved and hash-verified in `issued-authorization.remote.json`.
- `ready_for_build=false`, `functional_acceptance=false`; DDR simulation SKIPPED BY USER.

## Persistent process and monitoring

- SSH: `ssh -o BatchMode=yes uwb_student00@100.101.227.97`
- Compile tmux: `ia840f_mailbox_monitored_01:fim05-native-compile`, window `@258`, pane `%258`; its shell persists after launcher completion.
- Latest read-only monitor: `ia840f_mailbox_monitored_01:fim05-progress-readback`, window `@261`, pane `%261`.
- Runner PID 96412, native PID 96414. Native start 2026-09-18 17:01:10 PDT, `/proc` claim start_time `6409760`.
- Quartus flow PID 96431, start 17:01:13 PDT: `quartus_sh --flow compile ofs_top -c ofs_top`.
- Current synthesis PID 96464, start 17:01:22 PDT: `quartus_syn --ipc_flow=17 --ipc_mode --read_settings_files=on --write_settings_files=off ofs_top -c ofs_top`.
- Exact native argv: `./ofs-common/scripts/common/syn/build_top.sh --stage=compile -k -p ia840f /home/uwb_student00/ahls/new_BSP/work_ia840f_fim_05`.
- Native cwd: `/home/uwb_student00/ahls/new_BSP/ofs-agx7-pcie-attach`.

## Exact rejection and focused diagnosis

Quartus downgraded the Tcl rejection to Critical Warning (125091), then continued to synthesis. Rejected executable `/opt/altera/26.1.1/quartus/linux64/quartus_sh`, SHA256 `5740e47134517eac623c1391837761d12ab18b99a2db78be790cf764af3e3bce`:

```text
quartus_sh --ipc_mode -t ../../../../syn/shared_config/post_module_hook.tcl quartus_ipgenerate ofs_top ofs_top
cwd=/home/uwb_student00/ahls/new_BSP/work_ia840f_fim_05/syn/board/ia840f/syn_top
IA840F EXPERIMENTAL GATE: unrecorded compile executable/argv/cwd
```

Read-only comparison against the issued finite contexts shows the matching relative-path and absolute-path post-IP-generation contexts omit `--ipc_mode`. This is an actual-argv mismatch, not a reason to grant broad permissions. Any correction needs a separately bound attempt; do not reuse this consumed claim.

Latest captured log ends during `Info (23030): Evaluation of Tcl script ../../../../syn/shared_config/post_module_hook.tcl was succes`; process observation independently confirms synthesis and its catalog children remained alive. A final native return code was not yet available.

## Durable evidence

Remote evidence root: `/home/uwb_student00/ahls/new_BSP/qualification/fim-build-05/`

- `run/invocation.json`, `run/native.log`, `run/status.json` (live authoritative files)
- `native-compile.claim.json`, `launcher.log`, `authorization-issuance.log`, `authorization-readback.json`
- `launch-observation.json` (latest complete snapshot with process list and captured log)
- Native SOURCE log: `/home/uwb_student00/ahls/new_BSP/ofs-agx7-pcie-attach/build_fim_work_ia840f_fim_05.log`

Local evidence in this directory:

- `launch-status.json`: remote observation including full native log snapshot and process list.
- `launch-evidence/`: individual captured remote files, each verified against its remotely computed SHA256.
- `issued-authorization.remote.json`: full exact authorization readback.

No DDR simulation, hardware binding/programming, installation, commits or Work04 modification was performed. No bitstream, fit or timing success is claimed.

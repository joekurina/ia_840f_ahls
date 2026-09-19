# Work06 — narrow IPC gate candidate, fresh retry staged, NOT LAUNCHED

**Independent focused gate/handoff review pending.** No Work06 authorization, issuance lock, run directory or native claim exists. `ready_for_build=false`, `accepted_execution=false`, `functional_acceptance=false`. DDR simulation **SKIPPED BY USER**.

## Work05 outcome and preserved evidence

Work05 is **INVALID due to gate rejection**, independently of synthesis status. Its authorization and claim remain byte-identical to the original launch evidence. No maintained SOURCE, active gate, authorization, Work04, or historical record was edited.

Three distinct real rejected command forms were captured:

```text
quartus_ipgenerate --ipc_flow=17 --ipc_mode ofs_top -c ofs_top --run_default_mode_op
quartus_sh --ipc_mode -t ../../../../syn/shared_config/post_module_hook.tcl quartus_ipgenerate ofs_top ofs_top
quartus_syn --ipc_flow=17 --ipc_mode --read_settings_files=on --write_settings_files=off ofs_top -c ofs_top
```

Quartus downgraded rejection to Critical Warning 125091 and continued. This was not merely the initially reported callback mismatch.

Process control was restricted to the verified native invocation's Quartus descendants in owned tmux window `@258`, pane `%258`. PID/starttime/argv/cwd/ancestry were captured. SIGINT was sent to synthesis PID 96464 at 17:07:34 PDT; it continued. SIGINT was then sent to verified flow PID 96431; the parent runner finished at **17:08:28 PDT**, `native_returncode=1`, `gate_rejection=true`, `native_exit_accepted=false`. No monitor/runner pane, process group or unrelated process was killed; no stronger signal was used. The synthesis child subsequently completed at **17:09:02 PDT**. Later verification found no Quartus processes for UID 1000 and all original native/runner/flow/synthesis PIDs absent.

### Actual HDL/tool results, separate from gate validity

- Final `ofs_top.syn.rpt`: **Synthesis successful, 0 errors, 35 warnings**, elapsed 00:07:39, Quartus 26.1.1 Build 130, PID 96464.
- `ofs_top.syn.summary`: AGFB027R25A2E2V; estimated 79,769 ALMs; 219,616 dedicated registers. These are invalid-attempt synthesis observations, not accepted implementation results.
- Additional Critical Warning **19854**: explicitly defined initial values in partition `green_region`.
- Synthesized Design Assistant: **5 of 13 enabled rules failed**, no high-severity violations. Medium: RES-30132 (6 registers may not be properly reset), LNT-30023 (1 reset-polarity conflict). Low: LNT-30010 (5 reset/enable net violations), TMC-20501 (3 shallow duplication cases), TMC-20500 (2 duplication cases). Full node lists are preserved; no HDL repair was attempted here.
- No independent fatal HDL/compiler error surfaced. Synthesis-only `ofs_top.flow.rpt` says Successful, but contains only synthesis: **not full-flow, fit, timing, assembly or bitstream acceptance**.

`work05-before.json`, `work05-sigint.json`, `work05-after.json` preserve snapshots and original ancestry. `work05-final-evidence.tar.gz` contains 134 captured files including all available Work05 report/log/summary files, final runner status, native logs, authorization/claim and Work06 staging receipts. Includes inherited generation reports, not all are fresh compilation products. Archive SHA256: `28f0574d6279992f2b7d17ed3b8d5e74fe740daeb83525edffb02d8ed7493c4f`. Whole archive and every member were hash-verified against remote values. Final synthesis reports were deliberately recaptured after the parent exited. Expanded files: `remote-evidence/`; actual final reports under `remote-evidence/work_ia840f_fim_05/syn/board/ia840f/syn_top/output_files/`.

## Narrow candidate and evidence limits

Only production-code delta is `candidate/ia840f_compile_gate.py` (`candidate/gate.patch`), not applied to maintained SOURCE. It targets new Work06 paths and adds exact IPC forms:

- All **73 original command forms retained**, with Work06 paths.
- **16** exact post-module alternatives: `--ipc_mode` immediately before `-t`, existing eight module names and two existing hook paths. No arbitrary Tcl/script/module path or flag permission.
- **46** exact existing native task alternatives with the literal prefix `--ipc_flow=17 --ipc_mode`. No arbitrary IPC number, flag stripping, optional argument normalization or prefix on hook-launched helper scripts.
- Total **135 unique contexts**, same ten runtime executables. All executable/argv/cwd/hash, SOURCE/PIM/dependency inventory, environment, exclusive claim, PID/starttime and native ancestry checks remain unchanged.

Installed flow/task Tcl was inspected read-only and preserved in `installed-sources.json`. Its shell templates **omit** IPC prefixes. Inspection of the installed `libda_flng.so` and `libsys_flow.so` found post-module construction symbols and native formats including `%s%s%s --ipc_flow=%s --ipc_mode...`; `callback-construction.json` records their hashes and string excerpts plus full OFS hooks. This is **compiled-library string evidence, not available C++ implementation source**. Both libraries are new dependency pins in the draft. Runtime evidence validates the three forms above; the other equivalent alternatives remain source/constructor-derived, unexercised permissions. Literal 17 is conservatively pinned from observation, not proven invariant across every future flow. A different actual ID or argv still rejects; do not broaden it live.

## Fresh staging and tests

Remote `work_ia840f_fim_06` was copied from preserved Work04, not the invalid Work05 synthesis databases. Initial copy was hash-equal, then the seven already-accepted overlays were carried forward (only compile-gate bytes changed). Existing integration source review is reused from the pinned Work05 consumed receipt; no repeat source review is requested.

170 textual-path/symlink relocations are recorded; copied QDB/output/history authorization moved under Work06 `inherited-output/`. Generated synthesis HDL/XML retained; relocation mtimes preserved. Work04 full inventory was reread unchanged. The new draft binds 5,563 work entries, current maintained source plus exact overlays, 106 dependencies, original tool identities, target and part. Fresh vendor cache acceptance still belongs to the next actual invocation.

- **10 focused gate tests passed locally and remotely**, inert identity fixtures: original grammar retained, exact observed IPC commands accepted only when recorded, unexpected flags/IPC ID/script/project/cwd rejected, source/tool mutation, missing/reused/wrong-ancestry claim, changed work/readiness/permissions rejected, claim bytes preserved.
- **3 outer-runner tests passed locally and remotely**, real inert Python children: rc propagation, zero+rejection invalidation, zero is exit-only acceptance, prior evidence unchanged on rerun.
- **2 issuer tests passed locally and remotely**, inert files/mocked inventory: consumed source review reuse, exact gate/handoff maps, source/review mutations rejected before writes, exclusive reissue preservation.
- Actual remote fresh native shell invocation rejected for **missing Work06 authorization** before native log/claim creation; no vendor launched.
- `verification.json`: staged WORK equals draft, predicted SOURCE equals draft, maintained source still equals accepted Work05 overlay, all dependency pins match; Work05 authorization/claim unchanged. No Work06 claim or authorization exists.

## Exact parent handoff

Local root: `/home/joe/Projects/Thesis/AHLS/new_bsp/new/qualification/fim-build-06`.
Remote root `E=/home/uwb_student00/ahls/new_BSP/qualification/fim-build-06`.

Review the small gate diff, IPC evidence/limits, tests, issuer, runner and exact blocked draft at `remote-evidence/qualification/fim-build-06/compile-authorization.draft.json`. Do not re-review the unchanged accepted integration fixes. `review-request.json` has `gate_review.accepted=false`, exact four gate-file hashes, and exact `handoff_files` map. Parent must consume an actual independent focused review, then exclusively create remote `consumed-reviews.json` with that same map and accepted gate review. Do not simply flip readiness or reuse Work05 claims.

Pinned artifacts:

- issuer `669c1e83fd1099696ad0c3899d8ee6a696181846e5847208242d0def13aa27bb`
- runner `6d0973fd9964fdfa1036acd7eb01201592ba72ad158c72456d29062833696360`
- draft `3fdf2899d0b1aa6e3ad88a996ff83ca2bc7a0e38082351953956a99aa6848471`
- candidate gate `3c33edeb2ba9f24ab6c5e4fe5d109413e174a35e68cad94ed3bf722bf970dfb5`

Only after that review, inside an owned persistent `ia840f_mailbox_monitored_01` tmux window (SSH BatchMode to uwb_student00@100.101.227.97, verify Agilex7Workstation/UID1000):

```bash
python3 /home/uwb_student00/ahls/new_BSP/qualification/fim-build-06/issue_authorization.py /home/uwb_student00/ahls/new_BSP/qualification/fim-build-06/consumed-reviews.json
python3 /home/uwb_student00/ahls/new_BSP/qualification/fim-build-06/launch_native_compile.py
```

Issuer synchronizes only exact reviewed overlays and exclusively issues the new record; runner then invokes native `build_top.sh --stage=compile -k -p ia840f /home/uwb_student00/ahls/new_BSP/work_ia840f_fim_06`. It retains reviewed Quartus/PATH/license selection and output rejection handling. Read `E/run/status.json`, native log and final reports; any gate rejection invalidates the attempt regardless of vendor rc. No fresh Quartus was run by this task.

No DDR tests/research, installs, hardware access/programming, PLL/pin/calibration remapping, source repair or commits. Local scratch transport scripts are `/home/joe/fim06_*.py`; substantive artifacts and receipts are confined to new qualification/fim-build-06 and remote fresh Work06.

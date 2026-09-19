# FIM build 05 — staged native full-compile handoff

**Staged and verified; compilation NOT STARTED.** `ready_for_build: false`.
`accepted_execution: false` until the parent consumes independent source and gate reviews. DDR simulation is **SKIPPED BY USER**, not passed and not a compile prerequisite.

## Delivered

- Remote fresh `/home/uwb_student00/ahls/new_BSP/work_ia840f_fim_05` copied from Work04, initially verified byte-for-byte, then seven exact candidate overlays applied. Maintained remote source is unchanged until review consumption. No repair-source modifications by this worker.
- Work04 full inventory independently re-read unchanged; original authorization/claims/output remain untouched. Copied QDB and output databases (including opaque absolute Work04 paths) and copied historical authorization were moved under `qualification/fim-build-05/inherited-output/`, not edited or reused as valid compiler databases.
- 170 textual-path/symlink relocations recorded; all Work05 symlinks resolve inside Work05. Old Work04 absolute path absent from every remaining regular Work05 file. Generated synthesis HDL and cache XML retained, relocation mtimes preserved. Seven overlays, 5,563 work inventory entries, 73 exact source-derived native contexts / ten runtime tools, 103 dependency hashes bound in the blocked draft.
- Only literal remaining `/home` path in Tcl/QSF/QIP/IP/QSYS/SDC is the maintained SOURCE dummy AFU JSON, covered by full SOURCE inventory. Literal `qip_path` join scan of 97 QIPs found one missing `altera_avalon_sc_fifo.v` in the legacy HE-HSSI traffic-controller QIP; source search finds that QIP referenced by `common/filelist_common.txt`, not a Tcl/QSF registration. This is not claimed as full dynamic Tcl/source closure or a demonstrated active compile blocker. Compiler elaboration still establishes actual active closure.

## Gate changes and verification

Changed local maintained files:

- `ofs-common/tools/ofss_config/ia840f_experimental_gate.py`: three compile-specific CLI dispatches, preserving original Work04 setup policy.
- `ofs-common/scripts/common/syn/build_fim_compile.sh`: native IA840F compile runs the exact existing full flow through the rejection-output monitor. Existing entry checks remain before side effects.
- New `ofs-common/tools/ofss_config/ia840f_compile_gate.py` and `test_ia840f_compile_gate.py`.

The Work05-only policy binds SOURCE/PIM inventories, copied WORK baseline, exact target/part/revisions, explicit toolchain PATH and hashes, readiness false, exact native command/cwd, a single-use native PID/starttime claim, and finite runtime executable/argv/cwd/hash contexts. Every runtime callback must descend from the claimed native invocation. No standalone compile/module/generation permission, `-e`, custom seed, stage labels, arbitrary Tcl, wrong work path, altered source/tool or missing review record is accepted. The top-level rejection occurs before native log creation; the inherited inner guard and downgraded warning 125091/`IA840F_GATE_REJECTED` output detection remain.

- Local existing + focused gate suites: **50 tests PASS**, `local-tests-final.log` (inert identity fixtures; no vendor execution).
- Outer persistent runner: **3 tests PASS**, `runner-tests-final.log`, using real inert Python children: rc7 propagation, rc0+gate marker rejection, rc0 exit-only acceptance, and byte-preserving rerun rejection.
- Bash syntax check passed for modified native compile script.
- Real remote candidate native shell entry returned rc1 for missing new authorization, before native log/claim creation: `remote-evidence/missing-record-rejection.log`.
- Remote readback and transferred evidence bundle hashes verified. `remote-evidence/` has exact draft, path/inventory/relocation receipts and readback checks.

## Actual native dependencies, not setup assumptions

Read live Work04 build database: `Q_REVISION=ofs_top`, `Q_PR_REVISION=ofs_pr_afu`; these remain unchanged. Read installed 26.1.1 `qsh_flowengine.tcl`, classic/DNI compile flows and shell task templates. Read actual OFS post-module hooks: IP configuration headers after IP generation, FIM macros after synthesis, FME ID/MIF update + ASP resource output after fit, partition QDB after assembler, and PR SDC/IP list after timing. Those tool/script contexts are in the finite grammar and draft.

**The 73 contexts are source-derived permitted alternatives, not observations from an executed full compile.** A previously unseen actual vendor argv will reject and must be reviewed from its exact rejection evidence; do not broaden the gate blindly. Installed DNI flow conditionally includes assembler, so exit zero alone must not be reported as assembly acceptance; verify actual `.asm.rpt` and fresh SOF plus fit/timing reports. No finish/PR-release stage is authorized by this command.

## Parent review consumption and exact next commands

Remote evidence directory `E=/home/uwb_student00/ahls/new_BSP/qualification/fim-build-05` contains:

- `compile-authorization.draft.json` (all approval/consumption fields false): SHA256 `46c30801c8a25d53f76857570ae06a5afb2b7d77035d95e596aa92d58c2d0da7`.
- `issue_authorization.py`: SHA256 `6d32a4b31bb1cbea28afc7b8fbadd62e34065ea8fe7142699dbef947efdfa424`.
- `launch_native_compile.py`: SHA256 `9130fcc486c2830d62d5a7dbc25527e9370b2ce73c18378a667f8419bd0a3c35`.
- `source-overlay/`, before hashes, full inventories and `overlay-sha256.json`.

After actual independent reviews, parent writes `consumed-reviews.json` with `source_review` and `gate_review`, each containing `accepted: true` and an exact `files` relative-path→SHA256 map. Source map is the three integration-repair files; gate map is the remaining four entries of `overlay-sha256.json`. Review the issuer, runner and draft as part of gate review too. Do not manufacture that accepted receipt before consuming the reviews.

Inside the owned `ia840f_mailbox_monitored_01` tmux session only:

```bash
python3 /home/uwb_student00/ahls/new_BSP/qualification/fim-build-05/issue_authorization.py /home/uwb_student00/ahls/new_BSP/qualification/fim-build-05/consumed-reviews.json
python3 /home/uwb_student00/ahls/new_BSP/qualification/fim-build-05/launch_native_compile.py
```

The issuer validates unchanged before-state + both exact review maps, synchronizes only the seven overlays to maintained SOURCE, revalidates SOURCE inventory, exclusively issues the new authorization, and never starts Quartus. Issuance and native execution have separate exclusive locks/claims. Failed issued attempts are preserved, not auto-retried.

The runner executes from maintained SOURCE exactly:

```bash
./ofs-common/scripts/common/syn/build_top.sh --stage=compile -k -p ia840f /home/uwb_student00/ahls/new_BSP/work_ia840f_fim_05
```

It uses `/opt/altera/26.1.1/quartus`, explicitly prepends its `bin` and `sopc_builder/bin`, and sets LM/MGLS/SALT to `/home/uwb_student00/quartus_26/LR-191011_License.dat`. It does not source the old `.bashrc`, invoke a simulator, or impose a short watchdog. Run in an owned new window for persistence. Status is `E/run/status.json`, native stdout/stderr `E/run/native.log`, invocation `E/run/invocation.json`; the native SOURCE log is also preserved. Read status/logs through owned tmux, not direct SSH operational commands.

## Acceptance stays separate

AGFB027R25A2E2V, discrete0/RDIMM1 two 16 GiB x64 channels, BOT/BOT, calibration pair mapping, core470 and seven-output PLL, P-Tile Gen4x16, PF1 BMC/BAR configuration are not changed. Calibration-index interpretation, PIM USER semantics, effective CSR/system clocks, timing, PF1 FLR/drain constraints, complete active source closure and fresh fit/assembly/PR products remain report-review acceptance items. No hardware access/programming, SDK/install/vendor-directory writes, commits, or unrelated AHLS repair.

## Preparation issues retained honestly

Initial oversized tmux new-window payload was rejected (`command too long`) before staging. Retried via named tmux stdin buffer, then verified hashes. An inspection script initially named `inspect.py` shadowed Python stdlib inspect in runner tests; renamed `remote_inspection.py`, retained failing test log, and reran successfully. No preparation failure was replaced with fabricated vendor output.

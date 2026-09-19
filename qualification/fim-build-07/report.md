# Work07 — corrected checkout dispatch; staged and path-tested, NOT LAUNCHED

**Parent focused gate/handoff review pending.** No Work07 authorization, issuance lock, native claim or run exists. `ready_for_build=false`, `accepted_execution=false`, `functional_acceptance=false`. DDR simulation **SKIPPED BY USER**. No fit, timing, assembly or hardware acceptance claimed.

## Work06 outcome and exact cause

Work06 is **INVALID: gate rejection**, not an IPC-context failure. Maintained and copied `ia840f_experimental_gate.py` had identical SHA256 `06edce372f3267f86071174c5f9624656be5ed9ad8f1d43e8a00e6eb637179f1`. Their line 291 recognized only `work_ia840f_fim_05/syn/board/ia840f/syn_top` for `quartus` dispatch. The compile validator itself correctly targeted Work06. Thus the copied Work06 callback fell through `main()` line 300 into the legacy generation `quartus_context()` / `load_record()`, whose lines 74–75 accept only maintained SOURCE or Work04-IPGEN script locations. It emitted **unapproved checkout location before the compile validator was reached**. Quartus downgraded this to Critical Warning 125091 and continued synthesis.

Observed native stack, captured with exact argv/cwd/exe/starttime:

```text
runner 100551 → build_top.sh 100553 → build_fim_compile.sh 100561
 → maintained experimental_gate.py run-native-compile 100569
 → quartus_sh --flow compile ofs_top -c ofs_top 100570
 → quartus_syn --ipc_flow=17 --ipc_mode --read_settings_files=on
   --write_settings_files=off ofs_top -c ofs_top 100603
```

Callback source path established from both QSF revisions and actual Tcl:

```text
ofs_top.qsf / ofs_pr_afu.qsf → ../setup/build_gate.tcl
 → python3 WORK/ofs-common/tools/ofss_config/ia840f_experimental_gate.py quartus
 → stale Work05 cwd dispatch → legacy IPGEN gate → checkout rejection
```

`all-entrypoints.json` captures/hash-verifies maintained, Work06 and fresh Work07 native guards and Python dispatchers. `tcl-dispatch-tests.json` records both QSF references and helper resolution. Inspected early guards in build_top, build_fim_compile, build_fim, setup/finish plus setup/PIM/OFSS entry routes; only compile entry/native-run branches and the QSF callback are on this compile path. No additional compile checkout allowlist was added.

### Safe stop and retained history

At **2026-09-19T00:27:06.974043Z**, SIGINT was sent only to verified synthesis PID 100603/start 6548196 and flow PID 100570/start 6547415 after rechecking argv, cwd, executable and ancestry to native PID 100553/start 6547109, runner 100551/start 6546970. No process group, monitor, runner or unrelated process was signaled. No stronger signal used.

Runner finished **00:27:07.012125Z**, native rc=1, `gate_rejection=true`, `native_exit_accepted=false`. Subsequent readback found all four PIDs absent and no UID1000 Quartus processes. Owned pane `%282` in window `@282`, session `ia840f_mailbox_monitored_01`, shows `RUNNER EXIT 1` and idle bash. Work06 authorization and claim remain hash-identical. Final capture contains IP-generation reports but **no successful Work06 synthesis report**; do not infer synthesis/fit completion.

Evidence: `work06-before.json`, `work06-sigint.json`, `work06-after.json`; final 137-file archive `work06-final-evidence.tar.gz`, SHA256 `ffff2cd2491fb3ca857233131da01afb96da47fd2069236f1c9a7d54c405e4ae`. Whole archive and every member were checked against remote hashes. Expanded under `remote-evidence/`; inherited generation logs are not fresh compile results. Historical Work05/06 attempts were not rewritten or recycled.

## Minimal correction

`candidate/gate.patch` contains only:

- One dispatch literal: Work05 cwd → exact fresh Work07 cwd in experimental entry gate.
- Compile gate Work06 → Work07 WORK/evidence constants and docstring.

**135-context IPC grammar unchanged**, including literal IPC17. No blanket root allowlist, removed gate, new authorization framework, normalization or source/tool/target/cwd/readiness/ancestry relaxation. Existing native, runtime and source-inventory checks are unchanged. Maintained SOURCE and the failed Work06 tree were not edited; the future SOURCE overlay and copied Work07 contain the same candidate gate bytes.

Fresh Work07 was copied/hash-verified from preserved Work04-IPGEN, not failed synthesis databases. The seven accepted overlay slots were carried forward with only the two gate files changed. 170 symlink/text relocations retained generated HDL/XML; copied QDB/output/history record moved into new `inherited-output/`. Full Work04 inventory was verified unchanged after staging and again after tests. Maintained SOURCE full inventories still match issued Work06. Source acceptance is reused honestly from the pinned Work05 consumed receipt, not repeated or declared newly reviewed. Device AGFB027R25A2E2V and accepted DDR pair mapping/PTILE-PF1/BMC core4707 integration bytes are unchanged.

## Executed regressions and limits

- **40 real-path entry invocations passed**: 12 positive / 28 negative across actual Work07 copied gates and the future-maintained SOURCE overlay. Real `os.chdir`, exact root constants and normal module loading; production `main`, `load_record`, `claim_ancestor`, `check_context`, native and launch functions exercised. Covers flow, IPC IP-generation/synthesis, post-module callback, exact launch-helper argv and exclusive native-claim open; Work04/05/06, wrong cwd/paths, source-binding mutation, changed readiness, reused claim and unexpected argv reject.
- These are explicitly **inert fixtures**, not vendor success: future approved record/claim, process identities and only the two future SOURCE gate hashes are supplied in memory. Actual filesystem WORK, installed tool/dependency hashes and unchanged source inventories are read. Vendor launch is intercepted and its exact argv recorded; no persistent authorization/claim created. Both entry variants run the real compile runtime, unlike the previous isolated-validator-only tests.
- **Tcl resolution test passed**: actual Work07 `build_gate.tcl` with inert `exec` records exact `python3 WORK/.../ia840f_experimental_gate.py quartus 2>@1`, preserving readiness false. Separate real Tcl→Python execution rejects for **missing Work07 authorization**, not checkout location; no Quartus invoked.
- **10 gate tests, 3 runner tests, 2 issuer tests passed remotely**. Existing real temporary-file source/tool mutation, claim/history preservation and runner exit-propagation tests retained. IPC test now asserts exact equality with maintained Work06's 135 contexts.
- Actual fresh native shell stage rejects missing Work07 authorization before log/claim creation. Draft binds 5,563 work entries, 106 dependencies and ten runtime executables. `verification.json` confirms stable staged WORK, dependencies, unchanged Work04/SOURCE/Work06 claim and no fresh run.

## Parent handoff

Local `N=/home/joe/Projects/Thesis/AHLS/new_bsp/new`, artifacts at `N/qualification/fim-build-07`.
Remote `E=/home/uwb_student00/ahls/new_BSP/qualification/fim-build-07`.
Draft also available locally under `remote-evidence/qualification/fim-build-07/compile-authorization.draft.json`.

Review **the minimal two-gate delta, dispatch regression, issuer/runner and blocked draft**. Reuse accepted integration-source and IPC review; do not redo DDR/HW/pin/QoS work. `review-request.json` gives exact four gate-overlay hashes and handoff map, with gate acceptance false. Parent should consume an actual focused review into a fresh remote `consumed-reviews.json` with accepted gate map plus exact `handoff_files`. Issuer verifies/reuses the already-consumed source receipt and synchronizes only reviewed overlay bytes.

Pinned handoff SHA256:

- issuer: `261a640b3951ad8e1c6328c1ba2faeb6f400d22afc7853cf2588c2ab5634cce7`
- runner: `ec85f2df7a46acd9775f9ccb1be21186186e07831248e4b13a577926472ed894`
- draft: `527a99ec1228f1e223af0f227901e36ff16643ea0fc0df45fd86ef880cf7df66`
- experimental gate: `24f2d01ddd27111010db6f19d6a8b109b2ce69302e698ae7ad30658960b8949f`
- compile gate: `562f45bff4d5d239c4cf2c39388ce081d47c8ca98e5f40056a3823d50f3b76e2`

Only after parent review, inside an owned persistent tmux window on verified Agilex7Workstation/UID1000 using BatchMode SSH to uwb_student00@100.101.227.97:

```bash
python3 /home/uwb_student00/ahls/new_BSP/qualification/fim-build-07/issue_authorization.py /home/uwb_student00/ahls/new_BSP/qualification/fim-build-07/consumed-reviews.json
python3 /home/uwb_student00/ahls/new_BSP/qualification/fim-build-07/launch_native_compile.py
```

These have **not been executed** for Work07. The runner preserves reviewed PATH/license and rejection handling. Any gate rejection still invalidates the next attempt regardless of native rc. No source repair, hardware programming, SDK/driver changes, DDR runs, tuning, or commits performed.

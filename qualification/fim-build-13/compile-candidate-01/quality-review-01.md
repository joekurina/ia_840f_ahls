# Quality review 01 — fim-build-13 compile-candidate-01 (issuer + runner)

Reviewer: independent quality subagent (read-only; no vendor tools launched, no git,
no mutations; the only write is this report). Scope: fail-closed logic and once-only
semantics of `issue_authorization.py` / `launch_native_compile.py` and the gate wiring
they bind to. Source inventories/draft consistency are the parallel spec review's scope.

Method: byte-level diff vs the reviewed W12 references
(`qualification/fim-build-12/compile-candidate-01/{issue_authorization.py,launch_native_compile.py}`,
exercised successfully 2026-09-19, run evidence at `fim-build-12/run/`, claim
`native-compile.claim.json` pid 176868 == recorded native_pid), full read of both gate
modules (gate-copy == live SOURCE == live W13, sha256 verified), inert Python only:
AST/name analysis, a no-side-effect execution attempt of the issuer (crashes at module
level before `preflight()`), and pure-function dry-calls (`allowed_commands()` → 135
unique argv, all argv0 in the finite tool set; dispatch-order checks on `main()`).
Remote state verified absent before review: no `compile-authorization.json`, no
`native-compile.claim.json`, no `run/`, no `authorization-issuance.lock/`, no
`consumed-reviews.json` under fim-build-13.

Line citations are to the file in this package unless prefixed.

---

## Check 1 — issue_authorization.py issuance path: **FAIL**

Structural ordering is correct, but the module cannot run at all (NameError), so the
issuance path is broken end-to-end.

**1a. NameError — `C` and `W` are undefined (BLOCKING).**
Line 7 was adapted from W12's `P=E/'compile-candidate-01'; C=B/'ofs-agx7-pcie-attach'; W=B/'work_ia840f_fim_12'`
to just `P=E/'compile-candidate-01'` — the `C` and `W` definitions were deleted, but
every use survived:
- line 9: `sys.path.insert(0,str(C/'ofs-common/tools/ofss_config'))` ← crashes here
- line 17: `for root in (P,C,W,E,gate.common.PIM)`
- line 25: `source=str(C),work=str(W)` in the `expected` draft fields

Inert execution confirmed: `python3 issue_authorization.py <any>` →
`NameError: name 'C' is not defined` at line 9, exit 1, before any side effect. The
issuer is unrunnable; issuance can never happen. Fail-closed, but broken. The fix is to
restore `C=B/'ofs-agx7-pcie-attach'; W=B/'work_ia840f_fim_13'` on line 7.

Sub-properties, assessed on the code as written (all sound):
- **Preflight entirely before first side effect — PASS.** `issue()` line 48 calls
  `preflight()` (reads/`sha`/inventory + asserts only, incl. the absence asserts at
  lines 42–43), then review assertions lines 49–58; the first side effect is the lock
  `mkdir()` at line 59. Verified by AST: no store to the filesystem anywhere earlier.
- **Lock mkdir is the exclusive claim — PASS.** Line 59 `Path.mkdir()` with default
  `exist_ok=False` is an atomic EEXIST-arbitrated claim. Preflight's absence check
  (42–43) racing another issuer is harmless: mkdir arbitrates, loser exits before any
  write. No TOCTOU hole on the lock itself.
- **consumed-reviews.json with open('x') — PASS.** Line 60; read-back assert line 61.
- **Record only after all review assertions pass — PASS.** Review assertions
  (parent_acceptance_explicit, manifest hash, per-section accepted/files/report hash,
  cross-binding spec↔quality, distinct report paths) are lines 51–58, before line 59.
- **Draft→approved flips exactly the 4 flags — PASS.** Line 62 flips exactly
  `approved, accepted_execution, source_review_consumed, gate_review_consumed`;
  preflight lines 23–27 pinned all four `False` pre-flip. `load_record()` in the gate
  (compile gate lines 104–108) later requires all four `True` plus
  `ready_for_build=False` — matches.
- **dependency_sha256 extended before record write — PASS.** Lines 63–65 add
  consumed-reviews, review-package-sha256.json, the draft, the reviews file and both
  report paths before the record `open('x')` at line 66.
- **Half-issued record on failed assert — none.** After the lock, the only writes are
  consumed-reviews (60) and the record (66, exclusive create). A crash between them
  leaves reviews consumed but NO record; a retry is blocked by the line 42–43 absence
  assert → the package is spent, fail-closed, no double issuance (W12-inherited
  preserve-on-failure semantics). A crash mid-`json.dump` leaves a partial record file
  which similarly blocks retry and launch (`load_record` would fail JSON parse or field
  checks). No ordering lets a *valid* record exist with unpassed assertions.
- **Reviews consumed without issuance — no unauthorized path.** The window above
  consumes reviews without producing a record, but never the reverse; no run is
  possible without the record. Non-blocking observation (identical in W12).

## Check 2a — W13 adaptation: source-pins vs W12 provenance: **FAIL** (wrong, not weaker)

Line 40:
```python
import json as _j; _r12=_j.loads((B/'qualification/fim-build-12/compile-authorization.json').read_text()); assert draft['source_sha256']==_r12['source_sha256'], 'source pins differ from W12 provenance'
```
What it actually compares: the **full** source-pins dict (all 5 trees, every file) —
not a weakened subset. Full-strength but **wrong for W13**: this package's own
`source-inputs/delta-report.json` documents SOURCE differing from W12 in exactly the 2
retargeted gate files, and the draft correctly pins the *new* tree (preflight line 29
re-verifies the draft against the live SOURCE inventory).

Measured (inert JSON compare, draft vs W12 record):
- `ofs-common/tools/ofss_config/ia840f_compile_gate.py`: W12 `b5b9de19…` → draft
  `967d045a…`
- `ofs-common/tools/ofss_config/ia840f_experimental_gate.py`: W12 `f8fb4eb4…` → draft
  `cc4b9ce6…`
- all other trees/files: 0 differences (total delta = 2 entries)

Live SOURCE and live W13 copies hash exactly to the draft's new pins (967d…/cc4b…,
same as gate-copy/), so the draft is right and the assertion is unsatisfiable: even
after fixing 1a, preflight aborts at line 40 with 'source pins differ from W12
provenance'. The correct W13 form is "draft-vs-W12 delta == exactly the 2 reviewed
gate-file entries" (bound to `source-inputs/delta-report.json`/`gate-swap.json`
hashes), not full equality. As written, issuance is impossible → blocking.

## Check 2b — W13 adaptation: work-inventory binding: **PASS**

Line 41 `assert draft['work_inventory']==gate.work_inventory(), 'W13 work inventory drift'`
imports the *retargeted* W13 compile gate (gate-copy == live SOURCE == live W13 tree,
967d…, whose `work_inventory()` walks `work_ia840f_fim_13`, compile gate lines 15,
37–50). This binds the draft (5424 entries) to the live W13 tree at issuance time.
Note it duplicates preflight line 31 — redundant but harmless, and it does not weaken
anything (the launch side re-checks at runner line 23 and gate `native()` line 182).

## Check 3 — launch_native_compile.py: **PASS**

- **Byte-identical to W12's reviewed runner except path strings — PASS.** `diff -u`
  shows exactly one changed line: line 6
  `E=N/'qualification/fim-build-13';W=N/'work_ia840f_fim_13'` (E and W strings only).
  Local sha256 68fe5673c83f3c113f6c9154ba9420a51dfffb8dbc8c505b737159b2ced97dbe ==
  remote == manifest.
- **Once-only semantics — PASS.** Gate import from SOURCE (line 21, the swapped W13
  gate → RECORD/CLAIM under fim-build-13, verified via gate-copy import);
  `load_record()`+`environment()` (line 22); work-inventory match (line 23);
  **claim-absence assert before any write** (line 24); exclusive `run_dir.mkdir()`
  without exist_ok (line 25) — a rejected rerun aborts at 24/25 with zero writes and
  cannot touch retained evidence (all run/ files are `open('x')`/`open('xb')`/created
  only after the fresh mkdir).
- **Env sanitization — PASS.** Lines 12–20 strip `OFS_BUILD_TAG_*` and the 10 forbidden
  keys (incl. `AFU_WITH_PIM`, `SEED`, pre/post scripts, `BUILD_VAR_SETUP_COMPLETE`),
  then set explicit OFS_ROOTDIR/PIM/PATH/licenses/`PYTHONDONTWRITEBYTECODE=1` and
  replace `os.environ` wholesale. Matches gate `environment()` (compile gate lines
  149–158, incl. the falsy-tag nuance `OFS_BUILD_TAG_*` with truthy value).
- **status.json lifecycle — PASS.** `starting` (26–29, with authorization_sha256,
  ready_for_build=False) → `running` + native_pid (34) → `finished` (40–43).
  `native-status.json` persists the raw `native_returncode` (37) **before** the
  fallible log read/rejection scan (38–39). W12 run evidence shows exactly this shape
  (status finished, native-status rc=0 written 4 ms before status ended).
- **gate_rejection scanning — PASS.** Line 39 byte-scans the whole native.log for all
  four `REJECTION_MARKERS` (incl. `Critical Warning (125091)` for downgraded QSF Tcl
  errors), independent of rc.
- **Exit-code propagation — PASS.** Line 45: negative rc → `128-rc` (=128+signal);
  rc>0 → rc; rc==0 → 1 if rejected else 0. Exception path (46–51): if rc is known,
  nonzero propagates and rc==0 postflight failure returns 1 (fail-closed); otherwise
  re-raises; status.json gets `runner-error` best-effort.

## Check 4 — gate wiring (retargeted gates on SOURCE + W13): **PASS**

Verified gate identity first: gate-copy/ == live SOURCE ofss_config == live W13
ofss_config for both files (967d…, cc4b…). W12→W13 gate diffs are minimal and
declared: compile gate = pure path retarget (`work_ia840f_fim_12`→`_13`,
`fim-build-12`→`13`, 2 lines); exp gate = main() quartus branch drops the dead W12
header-gate dispatch (321→317 lines). Launch chain trace:

1. Runner Popen(TOP_ARGS, cwd=C) → `build_top.sh --stage=compile -k -p ia840f WORK13`
   from SOURCE cwd. Guard at build_top.sh:160 (`native "$STAGE" "$1" "$WORK_DIR"`
   triggers on `$1==*ia840f*`/WORK match/build_gate.tcl existence) → exp gate `main()`
   branch `['native','compile']` (exp lines 298–301) → compile gate `native()`.
2. `native()` (compile gate 177–192): exact target/work (178), `environment()` (179),
   cwd==SOURCE + work dir sanity (180), `load_record()` (181) — re-verifies source pins
   per tree, PIM, tool outer/inner identities + PATH, all 135 contexts (cwd==PROJECT,
   exe under linux64/ finite set, argv in grammar), all 477 dependency hashes — then
   live work-inventory match (182) and revision-count check (183–184) **before** the
   claim write. Parent must be `/usr/bin/bash` at cwd SOURCE with argv in
   [TOP_ARGS, bash+TOP_ARGS, /bin/bash+TOP_ARGS] (185–187) → CLAIM `open('x')` with
   record_sha256 + pid + start_time (188–189). Alternative parent argv
   [CHILD, ia840f, WORK] (+bash prefixes) → `claim_ancestor()` instead (190–192).
   Order is correct: no claim is consumed on any record/inventory mismatch.
3. build_top.sh:192 dispatches `${OFS_ROOTDIR}/ofs-common/scripts/common/syn/build_fim_compile.sh "$1" "$WORK_DIR"`
   (CMD=build_fim_compile.sh for stage=compile; OFS_ROOTDIR=SOURCE from runner env).
   build_fim_compile.sh:38–39 guard → same `native compile ia840f WORK13` entry →
   claim_ancestor path. Claim walk (compile gate 161–174): ≤64 PPid hops, `pid>1`
   guard so a non-descendant hits 'not a descendant of claimed native compile',
   pid-reuse defeated by `/proc/pid/stat` starttime (field 22, parsed after the
   `comm` `)` — correct), and the claimed bash's exe/argv/cwd re-verified (170).
   W12's exercised claim proves the pipeline depth (`| tee` at build_top.sh:192)
   stays within the walk.
4. build_fim_compile.sh cd's to WORK (73) then `-P quartus_proj_dir` → PROJECT (75);
   for `$1==ia840f` it runs the gate `run-native-compile` (112) instead of bare
   quartus_sh → exp gate main branch (295–297) → `run_compile()` (207–214):
   environment, load_record, claim_ancestor, cwd==PROJECT, exact FLOW context,
   `monitor_setup_output` streams the tool with rejection-marker detection (exp gate
   226–249, chunk-overlap scan so markers split across reads are caught, rc=0 cannot
   override rejection).
5. `quartus_sh --flow compile ofs_top -c ofs_top` from PROJECT → ofs_top.qsf:2
   `SOURCE_TCL_SCRIPT_FILE ../setup/build_gate.tcl` → build_gate.tcl (W13 copy)
   resolves the gate relative to itself and execs `python3 <gate> quartus` with
   quartus's cwd == PROJECT → exp main branch 1 (exp 290–294) now requires cwd ==
   `work_ia840f_fim_13/syn/board/ia840f/syn_top` (retargeted literal verified) →
   compile gate `quartus_context()` (201–204): `load_record(inner=True)` (Quartus-side
   inner tool paths), `claim_ancestor()` (callback ancestry: gate python → quartus_sh
   → … → claimed build_top bash), `check_context` on the *actual parent* process
   identity — FLOW/argv must be one of the 135 recorded contexts with cwd==PROJECT.

Holes looked for, not found: argv alternatives are finite and enumerated on both
sides (TOP_ARGS/CHILD each allow plain, `bash `-, `/bin/bash `-prefixed — matching how
scripts actually exec); the `quartus` branch cwd literal prevents an older WORK root
from falling through to a setup gate (the exp gate's own setup branches are
unreachable from the W13 syn_top cwd, and `native()` there requires
`work_ia840f_ipgen_04` which cannot match WORK13); context cwd is pinned to PROJECT
for all 135; ancestry depth 64 ≫ actual chain (~6); claim process-reuse check is
start_time-based; a second top-level launch hits CLAIM `open('x')` → FileExistsError
→ OSError caught in exp `main()` → exit 1, no partial effects; `work_inventory()`
skips `__pycache__`/`.pyc` so bytecode cannot break the match, and the runner sets
PYTHONDONTWRITEBYTECODE.

## Check 5 — failure-path probes (inert/reasoned): **PASS**

- **E13/run already exists (rerun):** runner aborts at line 24/25 (claim assert /
  `mkdir()` FileExistsError) before status.json exists; zero writes; prior evidence
  bytes untouched (all run/ files are exclusive-create). Gate side: claim `open('x')`
  fails → clean exit 1.
- **Claim exists but pid dead:** runner line 24 assert fails → exit 1 pre-write.
  Gate `claim_ancestor`: dead claimed pid never matches in the walk → `pid>1` guard
  trips → rejection; claim preserved (never auto-deleted). If the pid was reused by a
  new process, start_time mismatch (line 168) rejects.
- **Dependency hash drift between issuance and launch:** `load_record()` re-hashes
  all 477 deps (143–144) before `native()` reaches the claim write; runner also
  re-verifies inventory (23) before mkdir. Drift → ValueError/OSError → exit 1, no
  claim consumed, no run dir.
- **TMUX/session assert fails:** runner line 10 / issuer lines 14–16 fail before any
  side effect (issuer's is moot this round — the NameError at line 9 fires even
  earlier).
- **W13-specific crash:** the NameError itself is fail-closed (module level, zero
  side effects) — but see must-fix.

---

## Must-fix (blocking issuance)

1. `issue_authorization.py` line 7: `C` and `W` definitions were dropped in the W13
   retarget; line 9 (`str(C/'ofs-common/tools/ofss_config')`), line 17, and line 25
   still use them → `NameError: name 'C' is not defined` (confirmed by inert
   execution). Restore `C=B/'ofs-agx7-pcie-attach'; W=B/'work_ia840f_fim_13'`.
2. `issue_authorization.py` line 40: `assert draft['source_sha256']==_r12['source_sha256'], 'source pins differ from W12 provenance'`
   is unsatisfiable — SOURCE legitimately differs from W12 in exactly the 2 retargeted
   gate files (delta-report documents b5b9…→967d…, f8fb…→cc4b…; live SOURCE/W13 match
   the new pins; measured total draft-vs-W12 delta = those 2 entries). Full equality
   must be replaced by "delta == exactly the reviewed 2 gate-file entries" bound to
   the delta-report/gate-swap hashes. Until then the issuer can never issue this
   package (fail-closed, but broken).

Both must-fix items block issuance; after fixing them, re-run the (non-consuming)
issuer preflight before reviews-acceptance is consumed.

## Non-blocking observations

- `gate-swap.json` "before" hashes equal "after" (swap pre-dated the record); true old
  hashes live only in delta-report.json. Cosmetic provenance gap for the spec review.
- Reviews can be consumed without a record if the process dies between issuer lines 60
  and 66 (W12-inherited; preserves failed attempts, no unauthorized run possible).
- Narrow race: report files re-hashed at issuer line 56 (compared to reviews) and again
  at 63–65 (pinned); a change in that ms-window would pin the new hash unflagged
  (W12-inherited; launch-side dep re-hash still binds the record to on-disk bytes).
- Duplicate work-inventory assert (issuer lines 31 and 41) — redundant, harmless.
- Runner line 6 defines `W` unused (W12-inherited cosmetic).

VERDICT: REJECTED <issuer unrunnable: NameError from missing C/W definitions (line 7/9); source-pins assertion (line 40) unsatisfiable given the reviewed 2-gate-file delta vs W12>

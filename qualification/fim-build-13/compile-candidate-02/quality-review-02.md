# Quality review 02 — fim-build-13 compile-candidate-02 (issuer + runner)

Reviewer: independent quality subagent, 2026-09-19 (PDT). Read-only remote inspection via
ssh (uwb_student00@100.101.227.97, Agilex7Workstation). No vendor tools launched, no git,
no mutations; the only write is this report file. Inert probes only: module import via
importlib (no `__main__`), a `preflight()` call outside tmux (expected fail-closed), pure
JSON/hash recomputation, byte diffs. `python3 -B` + the module's own
`sys.dont_write_bytecode=True` (issuer line 10, set before the gate import at 11–12) —
package and ofss_config listings verified byte-identical pre/post probe.

Scope: fail-closed logic and once-only semantics of `issue_authorization.py` /
`launch_native_compile.py`, the two candidate-01 fixes, runner identity vs the W12-reviewed
original, gate wiring, failure paths. Blocking-defect baseline: candidate-01
spec-review-01.md (FAIL) and quality-review-01.md (REJECTED: NameError + unsatisfiable
lineage assert + gate-swap before-block mislabeled).

Line citations: bare numbers = this package's `issue_authorization.py` (85 lines) or
`launch_native_compile.py` (52 lines); gate/script paths prefixed.

## Check 0 — Manifest rehash and package composition: PASS

All 8 entries of review-package-sha256.json rehashed → 0 mismatches (README 7a44a1d4…,
draft aa1a63fd…, gate-copy/compile 967d045a…, gate-copy/experimental cc4b9ce6…,
issue_authorization.py 483d1c23…, launch_native_compile.py 68fe5673…,
delta-report 80fbfdcf…, gate-swap 3187df77…). 9th on-disk file is the manifest itself
(W12 self-exclusion pattern); no extra or missing files. Changed-vs-candidate-01 entries are
exactly README, issue_authorization.py, gate-swap.json — i.e. the three fixed items; the
five "identical to candidate-01" claims (draft, both gate-copy files, runner, delta-report)
verified byte-identical by `cmp`.

## Check 1 — Issuance path: preflight ordering, once-only, crash windows: PASS

- **Preflight entirely before first side effect — PASS.** `issue()` line 63 calls
  `preflight()` (lines 15–59: reads, `sha`, inventories, asserts only), then review-path
  resolve + review assertions lines 64–73. First filesystem mutation anywhere in the module
  is the lock `mkdir()` at line 74. Verified by full read: no store/write before it
  (import at 12 is read-only; `dont_write_bytecode` prevents .pyc writes).
- **Lock mkdir is the exclusive claim — PASS.** Line 74 `Path.mkdir()` default
  `exist_ok=False` — atomic EEXIST-arbitrated claim. The absence pre-check at 57–58 racing
  another issuer is harmless: mkdir arbitrates; the loser exits before any write.
- **consumed-reviews.json via open('x') — PASS.** Line 75, exclusive create; read-back
  assert line 76.
- **RECORD via open('x') — PASS.** Line 81, exclusive create; read-back assert line 82.
  Rerun/second issuer hits FileExistsError → fail-closed, no overwrite.
- **Flags flip exactly at issuance — PASS.** Preflight pins
  approved/accepted_execution/source_review_consumed/gate_review_consumed all False and
  ready_for_build False via the `expected` dict check (lines 25–29). Line 77 flips exactly
  those four to True; `ready_for_build` is NOT flipped and stays False — matching compile
  gate `load_record` (ia840f_compile_gate.py lines 101–108), which requires all four True
  plus ready_for_build=False.
- **dependency_sha256 extended before RECORD write — PASS.** Lines 78–80 add
  consumed-reviews.json, review-package-sha256.json, the draft, the reviews file, and both
  report paths into `draft['dependency_sha256']` before the `open('x')` at line 81; the
  gate re-hashes every dependency at launch (`load_record`, compile gate 143–144), so the
  record binds reviews/reports/draft/manifest bytes into the launch gate.
- **Crash windows — no half-issued state.** (i) Crash after lock mkdir (74), before
  consumed-reviews (75): lock exists, nothing else; retry blocked by absence assert 57–58
  (lock path is in the tuple) → package spent, fail-closed. (ii) Crash 75→81: reviews
  consumed, NO record; `load_record` needs RECORD → no run possible; retry blocked. (iii)
  Crash mid-`json.dump` of RECORD: partial file → `load_record` JSON/field checks fail →
  fail-closed. No ordering yields a valid record with unpassed assertions. The
  reviews-consumed-without-record window (ii) is W12-inherited preserve-on-failure
  semantics — non-blocking (see observations).
- **Live state preconditions — PASS.** All five absence targets verified absent today
  (RECORD, CLAIM, fim-build-13/run/, authorization-issuance.lock/, consumed-reviews.json).

## Check 2 — The two fixes

### 2a. C/W restored, import succeeds: PASS

Line 8 now reads `P=E/'compile-candidate-02'; C=B/'ofs-agx7-pcie-attach';
W=B/'work_ia840f_fim_13'` — every prior use (line 11 sys.path, line 19 roots, line 27
expected source/work) resolves. Inert import via importlib (module name ≠ `__main__`, so
line 85 does not auto-invoke `issue()`): **IMPORT OK, NameError gone**; C/W/P printed with
correct values; gate module loaded from live SOURCE ofss_config; no side effects, no new
__pycache__. Calling `preflight()` outside tmux raised AssertionError at the line-17
identity assert (TMUX unset) — fail-closed before any side effect; package listing
unchanged post-probe. (Issuance environment exists: tmux session
`ia840f_mailbox_monitored_01` is live on the host.)

### 2b. Delta-exact lineage block (lines 44–56): PASS — sound and satisfiable

Logic, tree by tree, replicated inertly against the live draft, the W12 issued record
(fim-build-12/compile-authorization.json, approved=true), and
source-inputs/delta-report.json:

1. **Scope assert (46–47):** `set(_dr)` must equal exactly the two retargeted gate paths —
   catches delta-report scope drift (a third report entry → reject) and prevents extending
   the reviewed set.
2. **Per-tree measured-vs-reviewed (48–52):** `_measured = {k for k in _new if
   _old.get(k) != _new[k]}` (changed OR newly added files), `_reviewed` = delta-report
   entries stripped to tree-relative; `assert _measured == _reviewed` per tree. An
   unexpected third changed or added SOURCE file appears in `_measured` but not
   `_reviewed` → reject. Verified live: measured == reviewed == the two gate files under
   `ofs-common`; empty for syn/src/ipss/tools.
3. **Old/new binding (53–56):** for each reported file, W12 record pin ==
   `delta-report[k]['old']` AND draft pin == `delta-report[k]['new']` — prevents
   laundering different hashes through the report (all four hashes verified:
   f8fb4eb4…→cc4b9ce6…, b5b9de19…→967d045a…).

**Satisfiability confirmed by replication: every assert in the block passes against live
data** (candidate-01's unsatisfiable full-equality form is gone; the duplicate
work-inventory assert is dropped as claimed — single occurrence remains at line 33).
Independently, the live SOURCE inventory equals `draft['source_sha256']` for all 5 trees
(141/77/149/953/41 entries), so the draft is bound to the live tree, and the lineage block
bounds live-vs-W12 drift to exactly the reviewed delta.

**Blind spot assessed (non-blocking):** `_measured` iterates `_new` keys only, so a file
*deleted* from SOURCE (present in the W12 record, absent from draft+live) would not be
flagged by this block (a changed or added third file IS caught). Measured today: the
symmetric delta (union of old/new keys) is exactly the 2 changed gate files — zero
additions, zero deletions — so the block's guarantee holds for the actual data.
Composition is independently double-bound: draft == live inventory (line 31) plus the spec
review's independent inventory recomputation. Recommend a future candidate iterate
`set(_old)|set(_new)` for symmetric coverage. Not blocking.

### 2c. gate-swap.json before-block (supporting fix): PASS

All four `before` values verified against the W12 issued record: SOURCE copies match
`r12['source_sha256']['ofs-common']` pins (f8fb4eb4…/b5b9de19…), W13-tree copies match
`r12['work_inventory']` sha256 pins (same values — the W13 tree was copied from W12
postheader). All four `after` values match live hashes at both locations. The
candidate-01 mislabeling (post-swap hashes in before) is corrected; delta-report.json is
byte-identical to candidate-01's (spec-review-01 already cross-checked it exhaustively:
159/12/8 exact set equality; its source_delta block re-verified here).

## Check 3 — Runner byte-identity vs W12-reviewed original: PASS

`diff -u` fim-build-12/compile-candidate-01/launch_native_compile.py vs this package:
**exactly one changed line — line 6**, `E` fim-build-12→fim-build-13 and `W`
work_ia840f_fim_12→work_ia840f_fim_13. Path strings only; also byte-identical to
candidate-01's runner (sha 68fe5673… == manifest). Once-only semantics re-verified on the
retargeted binding:

- Gate import from SOURCE (line 21) → retargeted W13 gate → RECORD/CLAIM under
  fim-build-13 (gate identity below); `load_record()`+`environment()` (line 22) re-verify
  record fields, 5-tree pins, PIM, tools, 135 contexts, 477 deps, native binding.
- **Claim-absence assert before any write** (line 24); **exclusive `run_dir.mkdir()`**
  (line 25) — rerun aborts at 24/25 with zero writes; all run/ artifacts are exclusive
  (`open('x')`/`open('xb')`, lines 30/32/37) inside the freshly created dir, so retained
  evidence cannot be overwritten (status.json write at 29 is post-fresh-mkdir).
- **Env sanitization** (12–20): strips `OFS_BUILD_TAG_*` + the 10 forbidden keys, sets
  explicit OFS_ROOTDIR/PIM/KEEP_WORK_ARG/QUARTUS_ROOTDIR_OVERRIDE/PATH/licenses/
  PYTHONDONTWRITEBYTECODE, wholesale `os.environ` replacement — matches gate
  `environment()` (compile gate 149–158).
- **Status lifecycle** (26–29 starting → 34 running+native_pid → 40–43 finished);
  `native-status.json` persists raw rc (37) **before** the fallible log read/rejection
  scan (38–39).
- **Rejection scanning** (39): byte-scans the whole native.log for all four
  `REJECTION_MARKERS` (verified tuple, incl. `Critical Warning (125091)`), rc-independent.
- **Exit propagation** (45): rc<0 → 128-rc; rc>0 → rc; rc==0 → 1 if rejected else 0.
  Exception path (46–51): rc known → propagate (rc==0 postflight failure → 1, fail-closed);
  else re-raise; `runner-error` status best-effort.

## Check 4 — Gate identity and launch-chain wiring: PASS

**Identity:** gate-copy/ == live SOURCE ofss_config == live W13-tree ofss_config for both
files (967d045a… compile, cc4b9ce6… at all three locations, sha256-verified). The issuer
imports the gate from SOURCE (issuer line 11) and the draft pins both gate files inside
`source_sha256['ofs-common']` (line 31 re-verifies), so a post-review gate swap breaks
preflight.

**Chain trace (live files, cited):**
1. Runner Popen(TOP_ARGS, cwd=C) → `build_top.sh --stage=compile -k -p ia840f
   work_ia840f_fim_13` from SOURCE. build_top.sh:158–160 ia840f guard → exp gate
   `native compile` → exp main() branch at ia840f_experimental_gate.py:297–299 → compile
   gate `native()`.
2. compile gate native() (ia840f_compile_gate.py:177–192): exact target/work (178),
   environment() (179), cwd==SOURCE + work sanity (180), `load_record()` (181; full
   re-verification incl. 135 contexts pinned cwd==PROJECT + finite linux64 executable set
   + argv grammar, 477 dependency hashes, native_argv/native_cwd binding), live
   work-inventory match (182) and revision counts (183–184) — all BEFORE any claim write.
   Parent must be `/usr/bin/bash` at cwd SOURCE with argv in [TOP_ARGS, bash+TOP_ARGS,
   /bin/bash+TOP_ARGS] (185–187) → CLAIM `open('x')` with record_sha256+pid+start_time
   (188–189); build_fim_compile.sh parent argv (CHILD form) → `claim_ancestor()` instead
   (190–192). No claim is consumed on any record/inventory mismatch.
3. build_top.sh:176–177 (stage=compile → CMD=build_fim_compile.sh) and :192 dispatch from
   `${OFS_ROOTDIR}` (SOURCE, from runner env) → build_fim_compile.sh:37–40 guard → same
   `native compile` entry → claim_ancestor path. Claim walk (compile gate 161–174): ≤64
   PPid hops, `pid>1` guard, claimed-pid start_time match defeats pid reuse, claimed
   bash's exe/argv/cwd re-verified. W12's exercised run proves pipeline depth stays within
   the walk.
4. build_fim_compile.sh:102 `quartus_sh --flow compile ofs_top -c ofs_top`; :110–112 for
   ia840f runs exp gate `run-native-compile` (exp main 294–296) → compile gate
   `run_compile()` (207+): environment, load_record, claim_ancestor, cwd==PROJECT, exact
   FLOW context, `monitor_setup_output` (exp 226–250) streams the tool with
   chunk-overlap rejection-marker scanning — markers split across reads are caught, rc=0
   cannot override rejection (249–250).
5. ofs_top.qsf:2 `SOURCE_TCL_SCRIPT_FILE ../setup/build_gate.tcl` → build_gate.tcl
   resolves the gate relative to itself and execs `python3 <gate> quartus` with quartus's
   cwd == PROJECT → exp main 291–293: `['quartus']` branch requires cwd ==
   `work_ia840f_fim_13/syn/board/ia840f/syn_top` (retargeted literal verified live) →
   compile gate `quartus_context()` (201–204): `load_record(inner=True)` (Quartus-side
   inner tool paths), `claim_ancestor()` (callback ancestry: gate python → quartus_sh → …
   → claimed build_top bash), `check_context` (195–198) on the actual parent — FLOW
   argv/cwd must be one of the 135 recorded contexts.

**Holes looked for, not found:** argv alternatives finite and enumerated on both sides;
the bare `['quartus']` fallback (exp 300–301) belongs to the ipgen_04 setup flow (exp
WORK/PROJECT at 27–29) and is unreachable from the W13 syn_top cwd, which the 291 literal
pins; all 135 contexts pinned cwd==PROJECT; ancestry budget 64 ≫ actual ~6; claim
start_time check defeats pid reuse; a second top-level launch hits CLAIM `open('x')` →
OSError caught in exp `main()` (310–312) → exit 1, no partial effects;
`work_inventory()` skips `__pycache__`/`.pyc` and the runner sets PYTHONDONTWRITEBYTECODE.

## Check 5 — Failure-path probes (inert/reasoned): PASS

- **TMUX/session assert fails: EXERCISED.** `preflight()` outside tmux → AssertionError
  at issuer line 17 before any side effect; package listing byte-identical post-probe.
  Runner line 10 equivalent fires before any write.
- **E13/run pre-exists (rerun):** runner aborts at line 24 (claim exists post-run) or
  line 25 `mkdir()` FileExistsError — both before status.json exists; zero writes; prior
  run evidence untouchable (exclusive-create artifacts only).
- **Claim exists with dead pid:** runner line 24 assert fails pre-write. Gate side: dead
  claimed pid never matches in the walk → `pid>1` guard trips → rejection; claim never
  auto-deleted. Pid reuse → start_time mismatch → rejection.
- **Dependency drift between issuance and launch:** `load_record()` re-hashes all 477 deps
  (compile gate 143–144) before `native()` reaches the claim write; runner re-verifies
  inventory (line 23) before mkdir. Drift → exception → nonzero exit, no claim consumed,
  no run dir.
- **Manifest/draft tampering:** issuer lines 20–23 rehash the full manifest; line 31–34
  re-verify draft vs live inventories/deps; any mismatch aborts pre-lock.

All probed paths fail closed with no partial side effects.

## Must-fix (blocking)

None.

## Must-fix (non-blocking) / observations

1. **Lineage block deletion blind spot (issuer 48–52):** `_measured` iterates `_new` keys
   only; a file deleted from SOURCE vs the W12 record would not be flagged (changed/added
   files ARE caught). Measured symmetric delta today is exactly the 2 reviewed gate files
   (0 added, 0 deleted), and composition is independently bound by line 31 + spec-review
   inventory recomputation. Recommend `set(_old)|set(_new)` iteration in a future
   candidate.
2. Reviews-consumed-without-record window between issuer lines 75 and 81 (crash after
   consumed-reviews, before RECORD): package spent, fail-closed, no unauthorized run
   possible; W12-inherited preserve-on-failure semantics.
3. Narrow race: report files hashed at issuer line 71 (vs reviews) and pinned at 78–80; a
   change in that window pins the new hash unflagged (W12-inherited; launch-side dep
   re-hash still binds the record to on-disk bytes).
4. gate-swap.json is evidence-only (not consumed by issuer or gate code); its before-block
   is now correct — provenance labeling defect from candidate-01 resolved.
5. Cosmetic, W12-inherited: unused `hashlib` import (issuer line 7); runner line 6 defines
   `W` unused; bare AssertionError without message on issuer line 17.

## Verdict summary

Both candidate-01 blocking defects are fixed and verified: the issuer imports cleanly
(C/W restored, line 8; NameError gone) and the lineage check (44–56) is sound, satisfiable
(replicated PASS against live draft/W12 record/delta-report), and catches scope drift and
per-file drift for changed/added files, with old/new hashes bound to the reviewed
delta-report. Runner is the W12-reviewed original with path strings only. Gate identity
holds at all three locations; the full launch chain re-verified with live line citations;
once-only and fail-closed semantics intact on every probed failure path. Manifest 8/8.
No blocking defects found.

VERDICT: APPROVED

# SPEC REVIEW 02 — fim-build-13 compile-candidate-02

Reviewer: independent spec-review subagent (read-only SSH session on Agilex7Workstation).
Constraints honored: no vendor tool launched, no git, no mutating sudo; the only write performed
by this review is this report file. All probes ran `python3` read-only; the issuer's `issue()`
was NEVER called and created no file (lineage logic was replayed inertly in the reviewer's own
process).

Package under review: `/home/uwb_student00/ahls/new_BSP/qualification/fim-build-13/compile-candidate-02/`
(manifest `review-package-sha256.json`, 8 files). Supersedes compile-candidate-01
(spec-review-01.md FAIL, quality-review-01.md REJECTED).

---

## 1. Manifest re-hash — PASS

- 8 manifest entries; all 8 re-hashed with sha256: **8/8 match, 0 mismatches**.
- Manifest paths all relative, no `..`, none absolute; no symlinks anywhere in the package
  (`find . -type l` → 0).
- No unlisted regular files in the package beyond the manifest itself (no `__pycache__`
  generated — reviewer ran with `sys.dont_write_bytecode=True`).

## 2. Import-free static check of issue_authorization.py — PASS

- `ast.parse` succeeds (no syntax error; no import needed).
- Module-level definitions present and consistent (both on line 9):
  - `C = B / 'ofs-agx7-pcie-attach'` — 5 Load-context uses (lines 19, 27, 28, 31 …).
  - `W = B / 'work_ia840f_fim_13'` — 2 Load-context uses (lines 27, 28).
  - candidate-01's NameError-at-import defect is fixed.
- Full-equality lineage assert REMOVED: AST scan of every `ast.Compare` with `Eq` finds **no**
  comparison joining `draft['source_sha256']` (whole dict) with `_r12['source_sha256']`.
  The only `_r12` uses are the delta-exact block (lines 44–56): per-tree measured-delta set vs
  reviewed set, plus per-file `_old.get(rk) == _dr[k]['old'] and _new[rk] == _dr[k]['new']`.
- Duplicate work-inventory assert absent (work_inventory asserted exactly once, line 33).

## 3. Inert execution of the fixed lineage logic — PASS (positive + 4 negatives)

The issuer's lineage block (lines 44–56, extracted verbatim via `ast.unparse` and `exec`'d in
the reviewer's process against the LIVE trees; `issue()` not called, nothing written):

```
_r12 = json.loads((B / 'qualification/fim-build-12/compile-authorization.json').read_text())
_dr = json.loads((P / 'source-inputs/delta-report.json').read_text())['source_delta']
assert set(_dr) == {'ofs-common/tools/ofss_config/ia840f_experimental_gate.py',
                    'ofs-common/tools/ofss_config/ia840f_compile_gate.py'}, 'delta-report scope unexpected'
for t in gate.common.TREES:
    _new = draft['source_sha256'][t]; _old = _r12['source_sha256'][t]
    _measured = {k for k in _new if _old.get(k) != _new[k]}
    _reviewed = {k[len(t)+1:] for k in _dr if k.startswith(t + '/')}
    assert _measured == _reviewed, f'{t}: source delta != reviewed set'
    for k in _dr:
        if k.startswith(t + '/'):
            rk = k[len(t)+1:]
            assert _old.get(rk) == _dr[k]['old'] and _new[rk] == _dr[k]['new'], k
```

Gate imported live from SOURCE (`ofs-common/tools/ofss_config`, sha 967d045a… compile /
cc4b9ce6… experimental); `gate-copy/` is byte-identical to both live SOURCE gate files.

- **3a PASS** — block replays clean with the draft's `source_sha256` values.
- **3b PASS** — block replays clean with the reviewer's independently LIVE-measured
  inventories (fresh `gate.common.inventory(C/tree)`), i.e. it passes against the live trees,
  not just the draft's self-description.
- **3c PASS (negative)** — injected a fake third changed file
  (`ofs-common/tools/ofss_config/ROGUE_EXTRA_FILE.py`) into an in-memory copy of the measured
  dicts → AssertionError (`ofs-common: source delta != reviewed set`). Delta-exactness is
  load-bearing, not tautological.
- **3d PASS (negative)** — tampered the delta-report `old` pin for ia840f_compile_gate.py in
  memory → AssertionError (old/new binding).
- **3e PASS (negative)** — reverted the experimental-gate entry to its W12 (old) hash in
  memory, simulating an un-swapped gate → AssertionError (measured set lost a reviewed file).
- **3f PASS (negative)** — added a third entry to `source_delta` in memory → AssertionError
  (`delta-report scope unexpected`).

Measured ground truth: SOURCE vs W12 record differs in exactly the 2 reviewed gate files;
old hashes f8fb4eb4… (experimental) / b5b9de19… (compile) match the W12 record's
`source_sha256['ofs-common']` pins AND its `work_inventory` pins; new hashes cc4b9ce6… /
967d045a… match the live SOURCE and W13-tree files.

## 4. Draft binding to live trees — PASS

- **4a** `draft.source_sha256` == live `gate.common.inventory(C/tree)` for all 5 trees:
  syn=141, src=77, ipss=149, ofs-common=953, tools=41 files (1361 total) — equal=True.
- **4b** `draft.pim_sha256` == live `inventory(PIM)` — 530 files, equal=True.
- **4c** `draft.work_inventory` == live `gate.work_inventory()` — **5424 entries**
  (5415 files + 9 symlinks), equal=True.
- **4d** contexts: `len(gate.allowed_commands())` = **135** = `len(draft.contexts)` = 135;
  full recomputation from `allowed_commands()` (executable path + fresh sha256 of each of the
  10 unique /opt/altera/26.1.1/quartus/linux64 tools + argv + cwd) reproduces
  `draft.contexts` exactly.
- **4e** `dependency_sha256`: **477/477 exist and hash-match** (0 missing, 0 mismatch).
- **4f** flags all false: approved=False, accepted_execution=False,
  source_review_consumed=False, gate_review_consumed=False, ready_for_build=False;
  `fixture_only` key absent (assert `not draft.get('fixture_only', False)` holds).
- **4g** native binding: `native_argv` == gate.TOP_ARGS =
  `['./ofs-common/scripts/common/syn/build_top.sh','--stage=compile','-k','-p','ia840f',
  '/home/uwb_student00/ahls/new_BSP/work_ia840f_fim_13']`; `native_cwd` == SOURCE
  (`/home/uwb_student00/ahls/new_BSP/ofs-agx7-pcie-attach`); `work` == work_ia840f_fim_13.

## 5. gate-swap.json provenance — PASS

- **5a** before-block == W12 issued-record pins:
  - SOURCE copies pinned from `r12.source_sha256['ofs-common']`: experimental
    f8fb4eb4d243…, compile b5b9de19d84a…;
  - W13-tree copies pinned from `r12.work_inventory[key]['sha256']`: same two hashes
    (W13 tree was copied from W12 postheader, so pre-swap values are the W12 pins).
- **5b** after-block == live gate hashes: cc4b9ce640e3… (experimental) and 967d045a0597…
  (compile) in BOTH trees — measured directly from disk.
- **5c** delta-report binding: `source_delta` scope is exactly the 2 gate files; each `old`
  == W12 pin; each `new` == live hash (and == gate-copy == after-block).
- **5d** candidate-01's dishonest before-block NOT carried over: candidate-01's before-block
  was byte-identical to its after-block (post-swap hashes recorded as pre-swap state);
  candidate-02's before ≠ after and before == the true W12 pins.

## 6. Launch safety — PASS

- **6a** Runner: candidate-02 `launch_native_compile.py` (sha 68fe5673c83f…) is byte-identical
  to candidate-01's. The W12-REVIEWED runner is
  `fim-build-12/compile-candidate-01/launch_native_compile.py` (sha 80bb3835eb77…, pinned by
  W12's consumed-reviews files==manifest and by the W12 record's dependency_sha256). Diff of
  candidate-02 vs that reviewed runner = **exactly 2 changed lines, both the path-string
  line** (`fim-build-12`→`fim-build-13`, `work_ia840f_fim_12`→`work_ia840f_fim_13`); zero
  non-path diffs.
- **6b** Issuer write surface (from AST/source): only `P/authorization-issuance.lock`
  (mkdir), `P/consumed-reviews.json` (open 'x'), `gate.RECORD` (open 'x' at
  `qualification/fim-build-13/compile-authorization.json`). All state checks precede the
  first side effect; exclusive-creation modes prevent overwrite/rerun. Only subprocess use is
  `tmux display-message -p #S` (check_output, read-only session identity probe).
- **6c** Nothing in the package launches a vendor tool at review time: issuer has no Popen at
  all; the gates' `Popen` lives in `monitor_setup_output`, reachable only via runtime dispatch
  after an approved RECORD exists; the runner's `Popen(gate.TOP_ARGS)` is preceded by
  `gate.load_record()` (requires the approved RECORD) and the tmux-session assertion. This
  review itself imported both gates live with zero tool launches.
- Cleanliness confirmed: no `compile-authorization.json`, no `native-compile.claim.json`, no
  `run/`, no lock, no `consumed-reviews.json` exists anywhere in fim-build-13 — once-only
  issuance still available.

## Supplementary (informational, all consistent)

- delta-report W13 work sections: |W12 work_inventory| = 5277, w13_removed = 12,
  w13_added = 159 → 5277 − 12 + 159 = **5424** == live W13 inventory size; keyset identity
  `(W12keys − removed) ∪ added == live keys` holds exactly; the 8 `w13_changed` entries are
  all present in both inventories and genuinely differ (2 gate files, 2 symlink retargets
  fim_12→fim_13 paths, 4 content files: afu_json_info.vh, build_env_db.txt, fme_id.mif,
  ofs_pr_afu.json).
- History preserved: candidate-01 dir untouched; spec-review-01.md sha 65cb06d364e5a0d7… and
  quality-review-01.md sha 65babefd322808ca… verified; candidate-02's draft and gate-copy are
  byte-identical to candidate-01's (only the reviewed fix files differ: issue_authorization.py
  and source-inputs/gate-swap.json).
- Draft contains no fim-build-13/candidate-01 self-references; its 7 dependency paths naming
  "candidate-01" all point at `fim-build-12/compile-candidate-01/` (W12 lineage inputs).
- Reviewer-probe corrections during this review (both reviewer-side, not package defects):
  the W12-reviewed runner reference was initially mis-taken as the fim-build-12 top-level
  runner (4685bc42…, the as-executed W12 artifact) before binding it via W12's consumed
  reviews to 80bb3835…; one supplementary comparison initially mishandled symlink inventory
  entries (`.get('sha256')` None on both sides) — re-verified with full-entry comparison.

---

Every check above: PASS (0 FAIL).

VERDICT: PASS

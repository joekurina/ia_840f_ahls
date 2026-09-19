# Spec Review 01 — fim-build-13 compile-candidate-01

Date: 2026-09-19 (PDT). Reviewer scope: read-only remote inspection via `python3` on
Agilex7Workstation (ssh uwb_student00@100.101.227.97). No vendor tools launched, no git
commands, no writes to the remote except this report file.

Package: /home/uwb_student00/ahls/new_BSP/qualification/fim-build-13/compile-candidate-01
Baselines: W12-issued gate copies at fim-build-12/compile-candidate-01/gate-copy/ofs-common/tools/ofss_config/
(Identity of that baseline independently confirmed: its hashes f8fb4eb4…/b5b9de19… equal the
W12 issued record's `source_sha256` pins for those two SOURCE paths, i.e. it IS the W12-issued
gate content.) W12 issued record: fim-build-12/compile-authorization.json.

## Check 1 — Manifest rehash (8 files): PASS

All 8 entries of review-package-sha256.json rehashed; 0 mismatches.

| file | sha256 (recomputed) |
|---|---|
| README.md | f276ce14855a62a0df2baef269d91bbf655270a50709476b9c0d7d8f26d52e81 |
| compile-authorization.draft.json | aa1a63fddc1ba12d989262b5cbf04dcccd2a7df41d1a288a44a328a6a3c18ec7 |
| gate-copy/ia840f_compile_gate.py | 967d045a0597ff4c1b5b090af19f5da4ca9a8361906e5cd53167dc4b3d0999ed |
| gate-copy/ia840f_experimental_gate.py | cc4b9ce640e39934a7ea9fd59dff5f66f4ba485a1d213314939ae0bd0762871f |
| issue_authorization.py | abb88688c8eac84938339bc48af1b029cd30994556a178684ad352712bb6b79d |
| launch_native_compile.py | 68fe5673c83f3c113f6c9154ba9420a51dfffb8dbc8c505b737159b2ced97dbe |
| source-inputs/delta-report.json | 80fbfdcf7e40d93e96914ce5fdbd89be8baa434629acf044b54a5392cf1f7e50 |
| source-inputs/gate-swap.json | e834e9544f80cd80c2b9d0716c258f1dc1b69277ef6999c098d7c0a7532a2032 |

9th on-disk file is review-package-sha256.json itself (self-exclusion is the W12 pattern).
No extra or missing files in the package.

## Check 2 — Gate diffs vs W12-issued: PASS

- ia840f_experimental_gate.py: exactly ONE hunk vs W12-issued — `main()` retargets the
  syn_top cwd test from work_ia840f_fim_12 to work_ia840f_fim_13 and drops the dead
  header-gate dispatch branch (the `import ia840f_header_gate` / HEADER_ARGS parent-argv
  check collapses to direct `ia840f_compile_gate.quartus_context()`). 321 → 317 lines.
  Zero residual `fim_12` / `fim-build-12` / `header_gate` references; ast.parse OK.
- ia840f_compile_gate.py: exactly two line changes — `WORK = … fim_12 → fim_13`,
  `EVIDENCE = … fim-build-12 → fim-build-13`. 214 → 214 lines. Zero residual refs; ast OK.
- Live agreement: gate-copy hashes == live SOURCE copies == live W13-tree copies
  (cc4b9ce6… / 967d045a… at all three locations).
- Discrepancy noted (evidence defect, not gate integrity): source-inputs/gate-swap.json
  records identical before/after hashes for all 4 entries — its "before" block carries the
  POST-swap hashes, not the pre-swap W12-issued values (f8fb4eb4…/b5b9de19…) that
  delta-report.json correctly records. Live hash equality of the 4 files is real; the
  labeling is wrong.

## Check 3 — Draft independently recomputed: PASS

Loaded gate from gate-copy via sys.path (same import the issuer uses) and recomputed:

- (a) source_sha256 vs live SOURCE inventories: EXACT equal, all 5 trees
  (syn=141, src=77, ipss=149, ofs-common=953, tools=41 entries).
- (b) pim_sha256 vs live PIM inventory: EXACT equal (530 entries).
- (c) work_inventory vs live `gate.work_inventory()`: EXACT equal (5424 entries).
- (d) contexts: `gate.allowed_commands()` → 135 commands; mapped with
  executable=/opt/altera/26.1.1/quartus/linux64/<argv0>, sha256 of that executable,
  cwd=str(gate.PROJECT) → EXACT equal to draft['contexts'] (135).
- (e) dependency_sha256: 477/477 paths exist and hash-match. Key set and values are
  identical to the W12 issued record's dependency set (0 only-in-13, 0 only-in-12,
  0 value diffs) — the W12 dep set rehashed, as claimed.
- tools/quartus_tools: 16/16 entries resolve and hash-match; groups cover gate.common.TOOLS.
- (f) Draft flags: schema=1, approved=false, accepted_execution=false,
  source_review_consumed=false, gate_review_consumed=false, ready_for_build=false,
  permissions=['native-full-compile'], target='ia840f', part=AGFB027R25A2E2V,
  toolchain='Quartus Prime Pro 26.1.1 Build 130',
  native_argv=['./ofs-common/scripts/common/syn/build_top.sh','--stage=compile','-k','-p','ia840f','/home/uwb_student00/ahls/new_BSP/work_ia840f_fim_13'],
  native_cwd='/home/uwb_student00/ahls/new_BSP/ofs-agx7-pcie-attach'. All exact.

## Check 4 — delta-report.json cross-check (recomputed live): PASS

SOURCE delta (W13 draft source_sha256 vs W12 record source_sha256): EXACTLY 2 entries,
both gate files, old hashes == W12-issued values:
- ofs-common/tools/ofss_config/ia840f_experimental_gate.py f8fb4eb4… → cc4b9ce6…
- ofs-common/tools/ofss_config/ia840f_compile_gate.py b5b9de19… → 967d045a…
Computed delta == delta-report['source_delta'] exactly.

W13 work-inventory delta (live W13 vs W12 record work_inventory): computed
+159 / −12 / ~8 changed; delta-report lists 159 / 12 / 8 — EXACT set equality on all three.

- Added: 159, ALL under syn/board/ia840f/syn_top/afu_with_pim/ (afu.tcl, ahls_binding RTL,
  ahls_ip/qual_vec_op.report.prj tree). 0 files outside the AFU assembly set.
- Removed: 12 = 2 exerciser stubs (afu_with_pim/afu/hw/afu.qsf, afu/hw/dummy_afu.json)
  + 10 dni/qdb bookkeeping (8 dni/* lock/manifest/kvp files + qdb/_compiler/ofs_top/
  _flat/26.1.1/legacy/1/ofs_top.db_info).
- Changed: 8, exactly the allowed set, subclassified:
  - PR JSON UUID swap: syn_top/ofs_pr_afu.json (contains 67bc266a-56f7-440a-bb75-12b5f446d842)
  - 2 symlink rebinds W12→W13: syn/board/ia840f/setup/config_env.tcl, syn_top/mem_ss.ip
  - 2 W12-compile-mutated files identical W12==W13 on disk today: syn_top/build_env_db.txt,
    syn_top/fme_id.mif (disk12 hash == live13 hash; both differ only from the W12 record pin)
  - 2 gate files: ofs-common/tools/ofss_config/ia840f_{experimental,compile}_gate.py
  - afu_json_info.vh: syn_top/afu_with_pim/afu/hw/afu_json_info.vh
- NO file outside the allowed sets. Stage-1 provenance exists
  (qualification/ahls-afu-fim-01/report.md, sha256 0a25d5242098bd934b31ccbfa8b3b17696615dc4a128ccd44301a0672612de26).

## Check 5 — Runner / issuer adaptation vs W12-reviewed originals: FAIL

- launch_native_compile.py: PASS. W12 original identity pinned in the W12 issued record
  (dependency 80bb3835eb77f15e…; disk W12 copy matches). W13 diff = ONE line: the `N=…`
  binding retargets fim-build-12→fim-build-13 and work_ia840f_fim_12→work_ia840f_fim_13.
  Nothing else changed.
- issue_authorization.py: FAIL — two defects.
  W12 original identity pinned in the W12 issued record (c831dd5d99b7e795…; disk matches).
  Diffs vs W12: path retarget (E/P), the two documented adapted assertions ARE present
  (lines 40–41), but:
  1. **NameError at import (mechanical retarget corruption).** The W12 line
     `C=B/'ofs-agx7-pcie-attach'; W=B/'work_ia840f_fim_12'` was split into
     `P=E/'compile-candidate-01'` only; `C` and `W` definitions were lost while `C`/`W`
     remain used at lines 9, 17, 25, 26, 29. Verified: `ast` shows no assignment to C or W;
     module import exits 1 with `NameError: name 'C' is not defined`. The issuer cannot run.
  2. **Adapted assertion (line 40) is unsatisfiable.** It requires
     `draft['source_sha256'] == W12 record's source_sha256`, but those differ in exactly the
     2 gate-file entries (verified equality check returns False) — which is the package's own
     documented, verified gate swap. Line 40 directly contradicts line 29
     (live SOURCE inventory == draft source_sha256, which passes). Even with defect 1 fixed,
     preflight can never pass. The correct W13 form would assert live-inventory equality
     (already line 29) plus "delta vs W12 record == exactly the 2 gate files".
  (Line 41 duplicates line 31 — redundant but harmless.)

## Check 6 — Nothing in the package launches tools: PASS

- issue_authorization.py: preflight() is all asserts (identity, manifest, draft, deps,
  tools, contexts, absence of RECORD/CLAIM/run/lock/consumed-reviews — all verified absent
  under fim-build-13 today); the only subprocess is `tmux display-message -p #S` (read-only
  session query). issue() writes only: authorization-issuance.lock (mkdir), 
  consumed-reviews.json (open('x')), RECORD (open('x')) — after all review checks.
- launch_native_compile.py (by design the sole launcher): re-verifies record + environment +
  work inventory, asserts CLAIM absent, `run_dir.mkdir()` (exclusive, once), writes status/
  invocation, single `Popen(gate.TOP_ARGS, cwd=SOURCE)` = build_top.sh --stage=compile -k -p
  ia840f work_ia840f_fim_13 — exactly the recorded native binding. Reviewer launched nothing.

## Additional observations (no verdict impact)

- postheader_inventory_sha256 semantics: W12 record = sha256 of
  fim-build-12/header-run/postheader-work-inventory.json (da828e32…, verified);
  W13 draft = sha256 of json.dumps(work_inventory, sort_keys=True) (0d17d448…, derivation
  verified). Self-consistent with the pinned W13 inventory; the field is not consumed by
  gate.load_record (inert provenance).
- W13 draft omits 5 fields present in the W12 draft/record (calibration_association_qualified,
  constraint_completeness_qualified, functional_acceptance, header_result_review_sha256,
  timing_qualified). None are consumed by the W13 gate; not carrying W12 acceptance markers
  forward is the correct direction, noted for the quality review.

## Discrepancies found

1. issue_authorization.py: `C`/`W` variable definitions lost in retarget → NameError at
   import; issuer unrunnable (import verified exit 1).
2. issue_authorization.py line 40: `draft['source_sha256']==W12rec['source_sha256']` is
   unsatisfiable — they differ in exactly the 2 gate files that the package itself swapped
   and pinned; contradicts passing line 29. Issuer can never issue this package as written.
3. gate-swap.json "before" block contains post-swap hashes (before==after for all 4
   entries) instead of the pre-swap W12-issued values; delta-report.json carries the
   correct old hashes. Evidence-labeling defect only.

## Verdict summary

Checks 1, 2, 3, 4, 6 and the runner half of 5 PASS with exact measured equality. The
issuer half of check 5 FAILS on two independent, verified defects. The draft and inventories
are internally sound; the package cannot be issued until issue_authorization.py is repaired
(restore C/W definitions; make the source-pin assertion verify live inventory plus the
2-gate-file delta vs W12) and re-hashed into the manifest, then re-reviewed.

VERDICT: FAIL issue_authorization.py is unrunnable (NameError: lost C/W definitions in retarget) and its adapted assertion draft.source_sha256==W12-record.source_sha256 (line 40) is unsatisfiable — it contradicts the package's own verified 2-gate-file SOURCE swap; issuer can never issue as written. Secondary: gate-swap.json 'before' block records post-swap hashes. All other checks (manifest 8/8, gate diffs, draft recomputation 5-trees/PIM/5424-inventory/135-contexts/477-deps, delta cross-check 159/12/8, runner, no-launch) PASS exactly.

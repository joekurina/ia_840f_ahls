# Independent specification re-review — mailbox migration 01

## Verdict

**GAPS FOUND — not PASS. `ready_for_build: false`.**

Both defects identified in the original `spec-review.md` are corrected within their stated scope: the initial upgrade now rejects pre-existing scratch escapes/drift before per-stage writes, and completed vendor/semantic failures now produce nonzero CLI status after report persistence. However, independent testing found one remaining whole-scratch review-barrier gap in the later child/parent stages. Do not advance to a PASS-based quality-review gate yet.

This is a local implementation review, not authorization to stage on the workstation, execute vendor tools, integrate changes, rebind sources, generate HDL, or build. Live runtime/catalog/API/project prerequisites remain unresolved.

## Remaining gap — medium: later review barriers ignore empty-directory additions and deletions

**Locations:** `migration.py:64–73`, `371–382`, `423–425`; documented full-scratch barrier at `README.md:157–164`.

The new directory-aware `scratch_snapshot()` is used for staging and the initial upgrade only. Upgrade/child reports still record `scratch_inventory_without_report=inventory(ROOT)`, a file-only dictionary. Child/parent preflight compares another file-only `inventory(ROOT)` against that dictionary. Neither requires HOME/TMPDIR to exist as directories. The traversal rejects symlinks it encounters, but an empty directory added or removed between approval and the next invocation contributes no file entry and is invisible.

Consequently an unchanged report with valid exact-hash approval authorizes a vendor launch after deleting HOME or TMPDIR, or after adding an unreviewed empty directory. This is not a concurrent race or receipt tampering. It violates the stated whole-scratch post-review immutability barrier and fails to preserve the explicitly staged environment directories through every vendor invocation. Missing HOME/TMPDIR can also change vendor cache/temp behavior; no outside-scratch write was attempted or established by these inert probes.

### Independent reproduction

Used the inspected suite's `staged_fixture()` with the real binding checker and mocked immutable source/tool identities. All subprocess calls were intercepted. Synthetic upgrade/child XML was used only to reach the ordinary review barriers; no Tcl or vendor process executed. Each approval bound the exact previous report and supplied the existing required checks. Files and receipts were not edited after approval; only the named directory mutation was made.

| Next stage | Mutation after prior-stage approval | Intercepted vendor calls | `write_new` calls | Result |
|---|---|---:|---:|---|
| child | Remove empty `home` | 1 | 4 | `errors: []`; child claim exists |
| child | Add empty `tmp/unreviewed-empty` | 1 | 4 | `errors: []`; child claim exists |
| parent | Remove empty `tmp` | 1 | 4 | `errors: []` |
| child | Replace `home` directory with regular file | 0 | 0 | `post-review scratch drift`; evidence unchanged |
| child | Replace `home` with symlink to scratch `tmp` | 0 | 0 | symlink rejection; evidence unchanged |

The four writes in each admitted case were claim, semantic before-image, raw before-bytes and final report; the log is opened separately. All synthetic completed reports still had `accepted: false`. Thus this is a pre-execution review-barrier defect, not automatic readiness promotion or an assertion that symlink escapes remain possible in later stages.

**Required correction:** persist directory-aware, fail-on-walk-error snapshots in every stage report and compare the complete reviewed file/directory state before child/parent claims, logs, before-images or subprocesses. Exclude only the report's own file hash to avoid self-reference. Explicitly retain HOME/TMPDIR directory requirements. Reject old file-only receipts rather than silently treating them as equivalent. Add inert regressions at both later barriers for missing HOME/TMPDIR and extra empty directories, retaining retyped-directory, symlink/ancestor and readback checks. Invalid state must produce zero vendor calls, zero per-stage writes, and unchanged prior evidence. Do not add automatic cleanup or receipt rebinding.

## Original findings rechecked

### Initial upgrade isolation — corrected

`migration.py:76–94` checks root and ancestor directory types, rejects symlinks through `no_links()`, inventories files and all directories including empty ones, and propagates traversal errors. `stage()` persists that state at lines 360–361. `run()` reads and compares it at lines 383–388, before the first per-stage write at line 392 or log open at line 398.

The independently rerun regressions cover post-stage HOME and TMPDIR symlinks, an unexpected file, an unexpected empty directory, a missing directory, a directory replaced by a file, and scratch replaced by a symlink. Each asserts zero subprocess calls, zero `write_new` calls and unchanged evidence containing only `staged.json`.

An additional independent inert probe renamed the temporary parent **above scratch** and replaced that parent with a symlink, leaving the binding strings unchanged. Result:

```text
ABOVE_ROOT_SYMLINK: calls=0 writes=0 evidence_unchanged=True
rejection=symlink: /tmp/mailbox-inert-s5yq4dcz
```

The parent path was restored before temporary-fixture cleanup. This verifies ancestor rejection beyond the suite's scratch-as-ancestor-of-evidence case. No outside-directory payload was written.

### CLI failure status — corrected

`run()` persists and returns the report at lines 423–428. `main()` raises `SystemExit(1)` at lines 445–448 when the report has nonzero vendor status or any errors. The rerun tests separately verified:

- Vendor rc 7 with otherwise valid synthetic leaf: persisted report contains only `vendor returncode 7: None`; CLI status 1.
- Vendor rc 0 with unchanged old leaf: persisted report contains `saved mailbox: public catalog resolution drift`; CLI status 1.
- Vendor rc 0 with valid synthetic leaf: normal CLI return, but `accepted: false`, `requires_independent_review: true`, and `ready_for_build: false`.

The tests read back retained reports, log bytes and claims. Pending independent review is not incorrectly treated as an execution error.

## Complete specification cross-check

- **Exact isolated context:** production root remains `/home/uwb_student00/ahls/new_BSP/qualification/mailbox-migration-01/scratch`; source is separately bound. Fixed QPF revision is `mailbox_migration`; QSF has only Agilex 7 family and `AGFB027R25A2E2V`. No FIM hook, callback, top-level assignment, implicit project creation or project bypass is introduced. Initial isolation checks pass; later directory-state limitation is the remaining finding above.
- **Source/work03 preservation and claims:** full source byte copies, exclusive scratch creation, exclusive per-stage files and retained failed claims remain. Source and active board wrapper/setup hashes are rechecked. There is no source integration, work03 mutation, cleanup/retry, generation or build action. The rerun inventory test verified all 34 bound BMC files, including 24 IP leaves, plus active boundary hashes.
- **Exact command/project/search binding:** the selective vector still targets `bmc_spi_sub.qsys` and only `--batch=./ip/bmc_spi_sub/sdm_mailbox.ip`, with explicit scratch project/revision/part and literal `,$` standard-catalog suffix. Child/parent use the same context, fixed scripts and proposed API 26.1. Extra/bypass options are rejected. All four template harness hashes match current bytes; template source hashes match the baseline.
- **Leaf → child → parent review chain:** separate stages and exact-report-hash approvals remain, with no auto-approval writer. Child saves the leaf, targets sync/reload/validation to `sdm_mailbox`, and saves the immediate system. Parent targets only `bmc_spi_sub_0`. The intercepted three-stage regression reaches all stages while preserving false acceptance and checking the missing-child-approval barrier. Directory-blind later inventory comparison is the specific outstanding weakness, not absence of approvals.
- **Retained settings and connections:** full saved module parameter dictionary and part/speed checks remain; public mailbox version must be 23.0.0. FIFO depths 1024/1024/4, memory selections and feature flags are retained. Nontarget Qsys structure, logical references, address/reset/IRQ routes, old ports and board wrapper/setup hashes remain protected. Child checks both proxy boundaries; parent preserves external boundaries. Independent tests exercised parameter mutations, unrelated leaf/RTL changes, lost ports, waitrequest name/width, address/reset/logical-reference drift and stale proxy state.
- **Coherence and scope:** leaf mapping/output/locked-boundary checks and child proxy checks are structural, not proof of actual live nonconstant waitrequest. Catalog core resolution, complete target deltas, timing metadata, nontermination and cross-representation coherence remain explicit human review obligations. Other newly produced scratch outputs require human review; new source/catalog/project files are rejected by the implemented policy. No forced metadata repair or readiness promotion was added.
- **Fail-closed template and live prerequisites:** template remains unreviewed, executable hashes null, readiness false and prerequisite flags false. The real checker rejects `reviewed: false` first. Runtime/launcher closure, catalog/helper closure, competing-resolution exclusion, installed API/package compatibility, minimal-project acceptance and write footprint are still blockers. The inspected discovery receipt records help rc 0 but both API discovery attempts rc 1; it is not successful installed integration evidence. Real selective migration, persisted refresh, independent acceptance, later standalone/nested generation, protocol/reset/FLR, synthesis/timing and hardware qualification remain unproven and separately gated.

## Verification and limits

Inspected the Python harness and tests before executing inert tests. Read the original review, fix report, README, template, baseline, both Tcl scripts, refresh procedure and installed discovery receipt. Ran from `/home/joe`:

```text
PYTHONDONTWRITEBYTECODE=1 python3 /home/joe/Projects/Thesis/AHLS/new_bsp/new/qualification/mailbox-migration-01/test_migration.py
Ran 33 tests in 13.641s
OK
exit code 0
```

Additional inspected inline Python probes produced the evidence above. They used temporary fixtures and intercepted every vendor subprocess. The original suite passes, but does not cover the later-stage empty-directory omissions demonstrated here. No live tool/runtime/catalog compatibility is inferred from mocked identities or synthetic XML.

No remote access, vendor/Tcl execution, build, generation, commit, source modification, work03 operation or persistent claim creation occurred. The only persistent project file created by this re-review is `spec-rereview.md`; `spec-review.md` and implementation files were left untouched. A preliminary read-only shell command tried unavailable bare `python` and exited 127; subsequent commands used `python3`. This did not affect verification.

## Reviewed SHA-256 identities

Paths are relative to this qualification directory unless shown otherwise.

```text
e72e617ee926bc5731662e486d8d8d7c626e4294d2837bcc99753acb7cfd5d24  spec-review.md
ad8b73f51d21c946d926b3f44f17b15854532d8eeb8882ba46c1b2757fb96ce8  fix-report.md
bbd0030bab03b1e411f1957b7a9c3c36063e29c954f94c21fd3ac86031f7988b  migration.py
655d78d0b983924ffc672cee6dbede2efd611b467ab19f39512961c5908ba114  test_migration.py
884960c9de30ca4c7244ece4cc05c1acd158f48fe48202c2e9906923d2ba935b  binding-template.json
97f429c91a96a4665ab148fffaaac12b3c6b3344aba41193b573b922897c69d2  README.md
148bb2897db6416a5950d152b6a8104c39cffda494e2723c97afecce9efb3a57  source-baseline.json
bab7fd328d6b053e6ce3e270e847229d35f7d9f296f4c3b79fb29d6f238cb9ba  child.tcl
98bd59f3dfdcc324990e6281cc7f15deebf44450be0559a0719ff53e5e23ea9b  parent.tcl
6a2c5f79388773e93252a19547565db6cfed0c477a409c826184df607f3598ff  ../ipgen-03/mailbox-refresh-procedure.md
79db4ecb18aa7eeeeadb4de914902594c99bca775bb4a0e545e8769df5954ffd  ../ipgen-03/installed-refresh-tool-discovery.json
```

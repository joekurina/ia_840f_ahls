# Final independent specification review — mailbox migration 01

## Verdict

**PASS — the reviewed local implementation satisfies the specification-review correction criteria. No remaining concrete specification defect found. `ready_for_build: false`.**

The original initial-HOME/TMPDIR isolation and CLI-status findings remain corrected. The later child/parent empty-directory gap is now corrected at both barriers. Quality review may follow this specification PASS; this is not quality-review approval, permission to execute vendor tools, migration acceptance, or build/qualification readiness.

## All-stage correction verified

References below are to the reviewed `migration.py`.

- **Complete snapshots:** lines 76–94 record sorted directory paths, including empty directories, and regular-file SHA-256 hashes. Root and ancestor directory checks, symlink rejection and `os.walk(..., onerror=walk_error)` prevent accepting missing/retyped paths, symlink escapes or silently incomplete walks.
- **Required runtime paths:** lines 365–370 independently require `home`, `tmp`, `bwbmc`, `evidence` and every ancestor to remain non-symlink directories on every invocation. Even an exactly approved receipt that already omits HOME cannot bypass this requirement.
- **Before all stage evidence and execution:** child/parent check prior success, exact report-hash approval, source inventory, directory-aware receipt structure and complete scratch equality at lines 375–391. Upgrade compares the initial staged snapshot at lines 392–397. All these checks precede the first stage claim at line 401, before-images at lines 402–404, log opening at line 407 and subprocess at lines 409–410. Invalid preflight state does not create a new phase claim/log/receipt or launch a process.
- **Old receipts reject:** lines 385–388 require exactly the `directories` and `files` members with list/dictionary types. File-only receipts fail closed even with updated exact-hash approval; no conversion, cleanup or rebinding was introduced.
- **Self-exclusion is consistent:** staging snapshots before creating `staged.json` (line 361); initial preflight removes only that file hash. Every completed phase snapshots before creating its own report (lines 432–435); later preflight removes only the immediately previous report's hash (line 390). Directory paths, prior claims/logs/before-images, the staged receipt and older reports stay bound. The exact previous report bytes are independently protected by approval SHA-256.
- **CLI semantics retained:** completed reports persist before `main()` exits 1 for nonzero vendor return code or semantic/log errors (lines 454–457). Successful execution pending review returns normally without promoting acceptance/readiness.

## Original specification cross-check

- **Isolation and exact bindings:** production scratch remains `/home/uwb_student00/ahls/new_BSP/qualification/mailbox-migration-01/scratch`, separate from the bound original source. The only proposed QPF revision is `mailbox_migration`; QSF has only family `Agilex 7` and device `AGFB027R25A2E2V`. Part/speed, cwd, environment, project text, complete command vectors, search string, source inventory, active board boundaries, harness and supplied tool/catalog/evidence identities remain checked. Template argv, QPF/QSF, source inventory and all four harness hashes were independently compared and match the implementation/baseline.
- **Immutable source/work03 and retained claims:** staging reads original source and writes independent bytes under scratch; original source and active wrapper/setup hashes are checked again. No source integration, work03 mutation, retry cleanup, gate removal, generation or build action exists. Scratch mkdir and phase files are exclusive; failed claims and partial evidence remain. Tests verify the actual local baseline of 34 BMC files, including 24 IP leaves, and active boundary hashes.
- **Selective upgrade and targeted refresh:** the fixed upgrade targets immediate parent `bmc_spi_sub.qsys` with exactly `--batch=./ip/bmc_spi_sub/sdm_mailbox.ip`. It does not request all-IP generation, synthesis, simulation or project bypass. Child Tcl saves the mailbox and targets sync/reload/validation only to `sdm_mailbox`; parent Tcl separately targets `bmc_spi_sub_0`. Explicit scratch project/revision, fixed scripts, proposed API package 26.1 and literal `,$` search suffix remain intact. No implicit project creation or FIM callback was added.
- **Independent barriers:** child and parent require separate exact-prior-report-hash approvals with all five required review checks. Neither phase automatically chains or writes approval. Parent completion still requires final independent review. Independent probes below additionally exercised missing approval and stale approval hashes at both barriers.
- **Retained parameters/routes and unrelated changes:** the complete saved mailbox module-parameter dictionary, device/speed, FIFO depths 1024/1024/4, memory selections and feature flags remain checked. Non-target source bytes and Qsys structure, address/reset/IRQ connections, proxy identities, logical references, existing ports and external parent boundaries remain protected. Mutation tests exercise these checks. Public version 23.0.0, waitrequest mapping/output/locked-boundary and child proxy checks remain structural requirements; target timing/catalog/coherence and real nonconstant backpressure still require independent live evidence, not inferred acceptance.
- **No automatic qualification:** every report retains `accepted: false`, `requires_independent_review: true`, and `ready_for_build: false`. There is no integration or qualification action. The template remains deliberately unreviewed, with null executable hashes and false prerequisite flags; `check_binding` rejects it at its first check before writes.

## Independent execution evidence

Inspected the harness and entire test suite before running it; also read both earlier specification reviews, the all-stage fix report, README, template and both Tcl scripts. From `/home/joe`, ran:

```text
PYTHONDONTWRITEBYTECODE=1 python3 /home/joe/Projects/Thesis/AHLS/new_bsp/new/qualification/mailbox-migration-01/test_migration.py
Ran 35 tests in 89.118s
OK
exit code 0
```

The child and parent barrier tests each exercise 12 mutation subcases: missing HOME/TMPDIR, extra empty directory, HOME/TMPDIR replaced by files or symlinks, scratch symlink, above-root ancestor symlink, old file-only receipt, newly approved receipt already missing HOME, and injected walk error. Their rejection assertions verify zero intercepted launches, zero `write_new` calls, no new phase evidence and byte-identical previous evidence. Setup launches are intercepted and the mock is reset before each invalid attempt. These tests use the real binding checker with substituted immutable source/tool identities.

Additional independent inline Python probes, also using inspected temporary fixtures and fully intercepted subprocesses, returned:

| Next phase | Mutation | Launches | `write_new` calls | Evidence |
|---|---|---:|---:|---|
| child | Missing approval | 0 | 0 | Unchanged |
| child | Stale approval hash | 0 | 0 | Unchanged |
| child | Modified prior upgrade log | 0 | 0 | Unchanged after mutation |
| child | Modified older staged receipt | 0 | 0 | Unchanged after mutation |
| parent | Missing approval | 0 | 0 | Unchanged |
| parent | Stale approval hash | 0 | 0 | Unchanged |
| parent | Modified prior upgrade log | 0 | 0 | Unchanged after mutation |
| parent | Modified older staged receipt | 0 | 0 | Unchanged after mutation |

Approval probes rejected with `independent semantic/log/catalog approval required`; evidence-drift probes rejected with `post-review scratch drift`.

A further complete synthetic upgrade → child → parent sequence used the real binding checker with mocked immutable source/tool identities. It returned three intercepted calls, no stage errors, exact readback snapshot equality for every report, and false acceptance/readiness. This supplements the suite's sequence that mocks the binding checker. Synthetic XML and mock identities are not vendor results; the synthetic parent invocation does not establish actual refresh behavior.

Both expected implementation hashes were rechecked after these tests and still match. All 11 entries of the stored `test-results.json` artifact hash table and all six preserved-file hashes match disk. That artifact table includes `all-stage-fix-report.md` and excludes `test-results.json` itself. The fix report's hash table excludes itself and the results receipt, consistently avoiding circular identities. This final review is a new downstream artifact and does not modify or rebind those earlier receipts.

## Remaining prerequisites and limits

Actual launcher/runtime dependency closure, resolved catalog/helper closure and absence of competing resolutions, installed API/package compatibility, minimal QPF/QSF loader acceptance, actual selective upgrade and persisted refresh behavior, and complete write-footprint review remain mandatory unmet live prerequisites. They are not evidence of vendor success and do not turn this local implementation PASS into execution authorization.

The wrapper is not an OS/process sandbox or concurrent hostile-filesystem-race defense. Interrupted/malformed output can retain incomplete evidence with a durable claim. Real catalog/core resolution, waitrequest coherence/nontermination, independently accepted saved deltas, later standalone/nested generation, shared-reset/FLR, protocol, synthesis, timing and hardware qualification remain separate gates.

No remote access, vendor executable, Tcl interpreter, build, generation, commit, source edit, work03 operation or production scratch operation was performed. Tests used disposable local temporary fixtures only. The only persistent project file created by this review is `spec-final-review.md`; no implementation or prior report was modified. No execution blockers or test failures occurred during this review.

## Reviewed SHA-256 identities

Paths are relative to this qualification directory. This report excludes its own hash.

```text
35a69d8c0cfdea91434c907bdba5ea41123fd9dfed3ac8a82f7a934a731e44c7  migration.py
a1da53d2bc47e941a84004944ecf24e9b051a01591153f7416bc58d276522eb6  test_migration.py
0bf737cd94f50033255b4abc1966c454433d1c467f5eae8f369e65d82f1bbed5  README.md
a9a597bf88a3a8cfd1792ba7456ce3d9cc0cfb477486eccf1ee47327cba8c8a0  binding-template.json
bab7fd328d6b053e6ce3e270e847229d35f7d9f296f4c3b79fb29d6f238cb9ba  child.tcl
98bd59f3dfdcc324990e6281cc7f15deebf44450be0559a0719ff53e5e23ea9b  parent.tcl
148bb2897db6416a5950d152b6a8104c39cffda494e2723c97afecce9efb3a57  source-baseline.json
e72e617ee926bc5731662e486d8d8d7c626e4294d2837bcc99753acb7cfd5d24  spec-review.md
d85248707be374e9debecaaff7a042680d21fb1bbd54d0611be47bdeb66d0640  spec-rereview.md
ad8b73f51d21c946d926b3f44f17b15854532d8eeb8882ba46c1b2757fb96ce8  fix-report.md
6e7530aeb156a0493095a2a11b5e6613d1cf588832c9b7f11c740726ac14ae3f  all-stage-fix-report.md
a8f98e35343777fb3582060b59903379aa476b9a3cfc9c045c494237b4400711  test-results.json
```

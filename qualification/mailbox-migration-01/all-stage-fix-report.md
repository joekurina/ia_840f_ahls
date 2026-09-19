# All-stage directory inventory correction

**Local inert verification passes; independent specification re-review and then
quality review remain required. `ready_for_build: false`.**

## Correction

The remaining finding in `spec-rereview.md` was confirmed: child/parent compared
file-only scratch inventories, so removing HOME/TMPDIR or adding an empty directory
could pass approval and reach evidence writes and an intercepted launch.

Every completed upgrade, child and parent report now persists `scratch_snapshot(ROOT)`
in `scratch_inventory_without_report`: exact sorted directory paths (including
empty directories) and file SHA-256 hashes. Child/parent require this structured
receipt and compare both sets before any stage claim, before-image, log or launch.
Old file-only receipts are explicitly rejected, not converted or rebound. Directory
walk errors propagate. Each report excludes only its own file hash; prior reports
and the staged receipt stay included. Exact report-hash approval is unchanged.

Every run separately requires HOME, TMPDIR, source cwd, evidence and all their
ancestors to be actual non-symlink directories, even if an approved snapshot itself
omits a required directory. Initial staging/upgrade snapshot semantics remain intact.
This is preflight validation, not a concurrent-filesystem-race sandbox.

## Inert verification

Inspected the suite before executing it. Added separate child and parent regression
tests, each exercising 12 mutation subcases with the real binding checker and
mocked immutable source/tool identities:

- Missing HOME and missing TMPDIR.
- Added unexpected empty directory.
- HOME and TMPDIR replaced by regular files, or by directory symlinks.
- Scratch symlink and symlinked ancestor above scratch (restored before fixture cleanup).
- Old file-only receipt despite exact-hash approval.
- Newly approved directory-aware receipt already missing HOME.
- Injected directory-walk error.

Each rejected attempt asserts zero intercepted launches, zero `write_new` calls,
no new phase evidence and byte-identical prior evidence. Synthetic fixture setup
launches are intercepted separately and reset before testing the invalid attempt.
The intended three-stage path still succeeds with synthetic XML, exact approval
barriers and readback equality of every report snapshot, while remaining unaccepted.

RED: the two new tests against the previous implementation returned exit 1:
8 subcase failures (missing HOME/TMPDIR, empty addition and old receipt at both
barriers) and 2 injected-walk errors (old walker did not supply `onerror`).
These are test failures, not real vendor execution.

GREEN, from `/home/joe` with bytecode writes disabled:

```text
PYTHONDONTWRITEBYTECODE=1 python3 /home/joe/Projects/Thesis/AHLS/new_bsp/new/qualification/mailbox-migration-01/test_migration.py
Ran 35 tests in 87.480s
OK
exit code 0
```

The unchanged CLI failure-status regressions also pass. The actual unreviewed
template `stage` invocation returned exit 1 with `ValueError: unreviewed binding`
before writes. Template harness hashes and source bindings were checked against
current files. `test-results.json` retains full captured final output and RED output.

## Scope and remaining gates

Modified only `migration.py`, `test_migration.py`, `README.md`,
`binding-template.json`, and `test-results.json`; created this report.
Preserved both original review reports, `fix-report.md`, Tcl scripts and
`source-baseline.json` byte-for-byte. No remote access, vendor/Tcl execution,
build, generation, commit, BSP/work03/source editing or gate changes occurred.
No live tool, API, catalog or runtime compatibility is established. No production
scratch was created, repaired or reused. Readiness remains false.

## Final artifact SHA-256

This table excludes this report and `test-results.json` to avoid circular identities.
`test-results.json` includes this report's hash and excludes only itself.

```text
35a69d8c0cfdea91434c907bdba5ea41123fd9dfed3ac8a82f7a934a731e44c7  migration.py
a1da53d2bc47e941a84004944ecf24e9b051a01591153f7416bc58d276522eb6  test_migration.py
0bf737cd94f50033255b4abc1966c454433d1c467f5eae8f369e65d82f1bbed5  README.md
a9a597bf88a3a8cfd1792ba7456ce3d9cc0cfb477486eccf1ee47327cba8c8a0  binding-template.json
e72e617ee926bc5731662e486d8d8d7c626e4294d2837bcc99753acb7cfd5d24  spec-review.md
d85248707be374e9debecaaff7a042680d21fb1bbd54d0611be47bdeb66d0640  spec-rereview.md
ad8b73f51d21c946d926b3f44f17b15854532d8eeb8882ba46c1b2757fb96ce8  fix-report.md
bab7fd328d6b053e6ce3e270e847229d35f7d9f296f4c3b79fb29d6f238cb9ba  child.tcl
98bd59f3dfdcc324990e6281cc7f15deebf44450be0559a0719ff53e5e23ea9b  parent.tcl
148bb2897db6416a5950d152b6a8104c39cffda494e2723c97afecce9efb3a57  source-baseline.json
```

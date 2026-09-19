# Independent code-quality review — mailbox migration 01

## Verdict

**APPROVED for the bounded, review-gated local harness, with one nonblocking minor finding.** No critical or important code defect found. `ready_for_build: false`.

This is not vendor execution authorization, migration acceptance, source-integration approval, or build readiness. Read the actual `spec-final-review.md` PASS and independently reviewed the implementation rather than treating that PASS as code-quality evidence. The expected `migration.py` SHA-256 matches exactly.

## Findings

### Critical

None found within the stated accidental-execution-prevention scope.

### Important

None found. Missing actual runtime/catalog closure, installed API compatibility and minimal-project acceptance remain execution prerequisites, not demonstrated implementation defects.

### Minor — reject duplicate boundary roles explicitly

**Location:** `migration.py:180–190`, particularly the dictionary construction at line 183.

`wait_port()` indexes ports by role without first rejecting duplicate roles. A later valid port silently hides an earlier conflicting port. An independent in-memory probe inserted a second `waitrequest` port with direction `Input` immediately before the valid output in the synthetic leaf's decoded `lockedInterfaceDefinition`; `check_leaf()` returned normally. The expected role-set check therefore proves the set of dictionary keys, not uniqueness of the serialized roles.

Suggested follow-up: count the AVMM port elements and reject duplicate roles before building the dictionary; add a fixture with conflicting duplicate waitrequest ports in both orders and in each checked boundary representation. No implementation change was made in this review.

This is nonblocking for this harness because successful structural checks never confer acceptance: the full changed target XML is retained, independent review must explicitly approve all target deltas and waitrequest representations before proceeding, and real catalog/validation/coherence evidence remains mandatory. It would become an acceptance defect if these helpers were later reused as a complete automatic schema or interface validator.

## Quality assessment

- **Paths and environment:** exact production root/source/cwd/project/argv/search bindings precede mutation. Scratch files are copied as independent bytes, not linked to originals. Every phase checks required runtime directories and ancestors; full directory-aware snapshots include empty directories and fail on walk errors. The subprocess receives the reviewed environment rather than an inherited environment, with explicit HOME/TMPDIR and no shell command expansion. The literal `,$` catalog suffix is preserved.
- **Receipt integrity:** staging excludes only its own snapshot bytes. Completed stages exclude only their own report bytes from their recorded snapshot. The next phase checks exact prior-report-hash approval and removes only that report from the current comparison. Older reports, claims, logs, before-images, staged receipt, source hashes and directory paths remain bound. Missing approval, failed prior execution, changed source or scratch drift prevents creation of the next phase's evidence. Claims are exclusive and are not cleaned up after failure.
- **Error propagation and diagnostics:** Tcl catches errors, prints the error and Tcl error information, then exits 1. Python captures combined stdout/stderr, checks return status, diagnostic markers and refresh completion markers, and saves a report before the CLI returns failure for completed erroneous runs. Independently exercised launcher `OSError` and zero-return-code critical-warning cases both retained failed claims and reports and blocked a subsequent child attempt. Interrupted, unreadable or malformed output can still leave partial evidence rather than a complete report, as expressly documented; this is not represented as successful execution or permission to retry.
- **XML and selectivity:** non-target source files are byte-protected; target Qsys removal for comparison preserves the remainder, including connections, addresses, clock/reset/IRQ routes, device metadata, proxy identity and logical reference. Existing ports/mappings are retained; module settings are compared as a complete dictionary, including hidden parameters. Decoded XML retains namespace-qualified tags, attributes and ordering. This is a purpose-built structural comparator for the saved schemas, not a general XML canonicalizer or schema validator. Parent external boundaries are protected separately. Target timing/property changes still require review rather than silent normalization.
- **Vendor command plausibility:** the proposed immediate-parent selective upgrade with one batch leaf agrees with the reviewed procedure. `save_component` is not misrepresented as the version-upgrade operation. Sync/reload/validation name their target instances; parent refresh is separate and bottom-up. Validation message lists are logged, not wrongly interpreted as boolean return values. Explicit project/revision and package selection are present. Installed behavior is not established by these static checks or the intercepted tests.
- **Original/work03 and readiness:** no original/work03 write path or source integration action is implemented. Original BMC and board boundary hashes are rechecked. No acceptance/readiness promotion is performed. Actual continuous nonconstant waitrequest, retained readdatavalid, both upstream requesters and shared global reset still need separately authorized generated-design evidence; a clean Python report cannot prove those properties.
- **Maintainability:** the fixed-scope command grammar and separated binding, staging, comparison and execution functions are understandable. Fixed constants duplicated across Tcl/template/Python are acceptable in this deliberately bound artifact; actual template command vectors, source inventory and harness hashes were mechanically compared and match. Any later edit needs coordinated rebinding and review. Tests clearly label synthetic XML and inert identities.

The previously reported initial symlink, CLI exit-status and child/parent empty-directory defects are corrected in the reviewed bytes and are not re-reported here. No hostile filesystem race resistance, installation-wide immutability or OS sandbox guarantee was demanded.

## Verification performed

Read all of `migration.py`, `child.tcl`, `parent.tcl`, `test_migration.py`, `binding-template.json`, `source-baseline.json`, `README.md`, the final specification report, and both referenced ipgen-03 mailbox procedure/review documents. Inspected the tests before execution; fixture subprocess calls remain intercepted.

From `/home/joe`:

```text
PYTHONDONTWRITEBYTECODE=1 python3 /home/joe/Projects/Thesis/AHLS/new_bsp/new/qualification/mailbox-migration-01/test_migration.py
Ran 35 tests in 91.416s
OK
exit code 0
```

Additional inline inert Python probes:

- Conflicting duplicate boundary role: reproduced the minor finding above without files or subprocesses.
- Launcher `OSError`: failed report persisted with `returncode: null`, retained claim and exact readback snapshot; child blocked despite an exact-hash approval; only one intercepted launch.
- Vendor rc 0 plus `Critical Warning`: failed report persisted, retained claim and exact readback snapshot; child blocked; only one intercepted launch.
- Template argv, source inventory and all supplied harness hashes match actual implementation/baseline values.
- Recomputed reviewed-file hashes after the tests; implementation hashes remain unchanged.

A read-only `git status --short` at the supplied AHLS directory reported that it is not a Git repository. Consequently no Git diff/status cleanliness claim is made. Direct file inspection and SHA-256 identities supplied the review basis; tests and probes succeeded.

No remote access, vendor executable, Tcl interpreter, build, generation, commit, production scratch operation, source edit or work03 operation was performed. Temporary test fixtures were disposable local files. The only persistent project file created by this review is `quality-review.md`.

## Remaining execution and acceptance gates

The unreviewed template still cannot authorize staging. Actual executable/runtime identities, complete reviewed catalog/helper/search closure, installed help/API/package compatibility, minimal QPF/QSF acceptance, named tmux/workstation instructions, licensing environment and complete side-effect review are still required. These cannot be replaced with synthetic test identities or flipped booleans. Later vendor execution must establish selective writes, actual resolved versions, saved-target coherence and validation messages. Separately authorized standalone and nested generation must establish real backpressure and retained shared-reset/FLR behavior before broader qualification. Approval here removes none of those gates.

## Reviewed SHA-256 identities

Paths are relative to this directory. The report excludes its own hash.

```text
35a69d8c0cfdea91434c907bdba5ea41123fd9dfed3ac8a82f7a934a731e44c7  migration.py
bab7fd328d6b053e6ce3e270e847229d35f7d9f296f4c3b79fb29d6f238cb9ba  child.tcl
98bd59f3dfdcc324990e6281cc7f15deebf44450be0559a0719ff53e5e23ea9b  parent.tcl
a1da53d2bc47e941a84004944ecf24e9b051a01591153f7416bc58d276522eb6  test_migration.py
a9a597bf88a3a8cfd1792ba7456ce3d9cc0cfb477486eccf1ee47327cba8c8a0  binding-template.json
148bb2897db6416a5950d152b6a8104c39cffda494e2723c97afecce9efb3a57  source-baseline.json
0bf737cd94f50033255b4abc1966c454433d1c467f5eae8f369e65d82f1bbed5  README.md
668b9bfb028228b8cd07069e3009140dfbfdba80f9090f8edb8fba5960c61412  spec-final-review.md
6a2c5f79388773e93252a19547565db6cfed0c477a409c826184df607f3598ff  ../ipgen-03/mailbox-refresh-procedure.md
30e542ea71577ef8f3742a1b9e0384f451e19e08a4efcd9c493eda159a130212  ../ipgen-03/bmc-mailbox-generation-review.md
```

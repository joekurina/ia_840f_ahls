# Independent successor specification review

## Decision

**PASS — exact successor preparation only. No execution authorization. `ready_for_build: false`.**

The delivered successor conforms to `../first-experiment-binding-proposal.json` and `../first-experiment-binding-review.md`. No discrepancy was found in the permitted source transformations, candidate binding, baseline preservation or recorded inert regression scope. This is not approval of a live launch, observer completeness, saved-state migration acceptance, or generated RTL. Independent quality review remains separate.

This review used local reads, SHA-256 calculations, byte comparisons and Python AST/JSON parsing only. It did not import or execute the harness or tests, invoke remote/vendor/Tcl/HDL tools, stage scratch, edit source, or commit anything. The only review deliverable written is this file.

## Independently verified identities and scope

Governing proposal SHA-256: `3a43e54127052568364e5bdbeb1e70b7a2d98a0454132f9777c4c24859bfaf83`.

Governing review SHA-256: `60f00b2d8f574a006499f5a20e7ca25e156f7a2116b754ebe7822bea06dc2e91`.

| Successor file | Independently calculated SHA-256 |
|---|---|
| `migration.py` | `a4f360484dba25f4e0a12a7cdb294b1387c86f1bb7b884480acb630368bb2f9c` |
| `child.tcl` | `3b735d9ccb1886dfbc3791a905abde3afa067892743798a5e4ed344cb7071362` |
| `parent.tcl` | `5b8d78e78e61cec558fcbe8abd5f1eb9cdd6a76efc203cfb4d598adf2fbcf51d` |
| `source-baseline.json` | `148bb2897db6416a5950d152b6a8104c39cffda494e2723c97afecce9efb3a57` |
| `binding-template.json` | `12493ca49698ef00603e1722e7ea363d3997e86ac2b89921e5c5a9de9aeceb5a` |
| `test_migration.py` | `71e2bad62827541cf96f57dbb4c0d43b2b15e308dc0334294eac2ee1ab58df5f` |
| `regression-results.json` | `6a5bac5ab8883e9c3d1f57e5757a12bad9da75d08b38444398288f70f75de971` |

- Compared directly against the proposal's `required_source_transformations_not_applied`, not merely the successor's receipt: each old source hash matches; each old string occurs exactly once; performing the specified replacement in memory produces the exact successor bytes. The only harness changes are Python's fixed ROOT and the two Tcl cwd assertions. All three result hashes match the proposal and requested identities.
- Parsed `binding-template.json` equals the complete proposal `candidate_binding` object exactly, rather than the proposal envelope. All review/readiness booleans remain false and reviewer remains null. Exact candidate argv, six-key environment, source/hash maps, part, speed grade, QPF/QSF and search path are preserved.
- `source-baseline.json` is byte-identical to the original. Independently recomputed the complete local BMC inventory: 34 files, exact baseline equality. Both board-boundary hashes match.
- All 28 preexisting mailbox files listed in the regression receipt still match their recorded hashes, including the original harness, tests, template, proposed binding and governing documents. This verifies current preservation against the recorded identities; it is not a historical write-monitoring claim.
- The test file is byte-for-byte the original with only `LOCAL_N = m.HERE.parents[1]` replaced by `LOCAL_N = m.HERE.parents[2]`, exactly once. Direct execution imports the sibling successor and the extra directory level resolves the same local source fixtures.
- Every delivered-file hash in the receipt and every one of the ten existing `SHA256SUMS` entries matches actual bytes. No fixture directory remains in the successor directory. The existing manifest predates this review and does not cover this new review file; it was not modified.

## Regression receipt verification and limits

`regression-stderr.txt` contains 35 distinct successful test records and `Ran 35 tests in 157.198s`, followed by `OK`. AST enumeration independently finds exactly 35 test methods, with the same class/method pairs as the log. The receipt reports return code 0, no failures, errors or skips. Raw stdout contains synthetic stage reports, including intentional failure fixtures, with acceptance false; these are not live vendor results. Both raw log hashes match the receipt and manifest. The recorded resolved Python executable exists locally and its bytes match the receipt's interpreter hash.

Read the complete test source. Vendor invocations are intercepted through mocked `m.subprocess.run`; fixture writes use temporary local roots, and source fixtures are read. The suite covers parser semantics, binding mutations, exclusive staging, directory/symlink and snapshot barriers, report-hash approvals, and CLI failure propagation. Its positive binding is explicitly an inert fixture, not execution of the full real candidate envelope or proof of deployed tool/catalog identities. No fresh test run occurred during this independent review: the result above is verified retained evidence, not a claimed rerun.

## Execution and acceptance remain blocked

- `migration.py:304-307`, `341-342` and `364-365` preserve first-check rejection of this unreviewed/null-reviewer candidate before claims, writes or subprocesses. The exact successor does not itself implement an observer or an unconditional vendor ban for a separately approved binding; therefore its unchanged approval checks must not be mistaken for observer enforcement.
- Independently inspected the adjacent observer source and documentation. `observer.py`'s `vendor_gate()` consists of an unconditional `raise Refusal(...)`; its CLI `upgrade` branch calls that gate before preflight. No approval or successful harmless preflight overrides it. The observer explicitly lacks complete syscall/path/FD/rename/mmap auditing and race-safe descendant accounting. Its gate must remain intact. This check is not a full independent observer quality review.
- The successor README retains mandatory external observation, precise limits and retention policy, exact candidate invocation/environment, separate approvals, no automatic chaining, and independent upgrade/child/parent barriers. Parent authorization, complete independently reviewed observation, fresh remote identity/path/hash checks and deployment readback remain outstanding. No remote state was checked here.
- The known `wait_port()` weakness remains at `migration.py:183`: a role-keyed dictionary can overwrite duplicate AVMM roles. Preserving it is part of the exact successor scope, not a finding that it is safe. At every future barrier, independently inspect the full actual XML **before** constructing role dictionaries: decoded leaf `lockedInterfaceDefinition`, both child `componentDefinition` and `defaultBoundary`, and relevant parent representations. Reject duplicate AVMM roles; check physical-name uniqueness, IP-XACT maps, unique one-bit output waitrequest, retained readdatavalid, nontermination, all prior ports/parameters/routes and actual selected versions. Apply schema-specific treatment to conduit roles. A harness helper result alone cannot establish acceptance.
- There is no actual migrated XML from an authorized experiment to accept in this preparation review. Standalone and nested generated RTL must later establish real nonconstant end-to-end backpressure and reset/FLR ownership under separate authorization; serialized ports and inert fixtures do not establish those properties.

**Disposition:** preparation specification PASS; quality review and all live-launch prerequisites remain separate. Do not flip approval/readiness flags, bypass the observer gate, or launch on the strength of this report.

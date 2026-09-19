# Mailbox migration 01 — spec-review corrections

**Both reported defects corrected locally; independent spec re-review and quality review pending. `ready_for_build: false`.**

## Corrections

1. **Initial scratch preflight:** `migration.py` now persists a whole-tree staging snapshot in `evidence/staged.json`, containing file SHA-256 values and every directory path (including empty HOME/TMPDIR). Only the snapshot's own bytes are excluded to avoid a self-hash. Before the initial upgrade writes any per-stage claim, before-image, log or invokes a subprocess, it checks the current tree against that persisted snapshot. The traversal rejects symlinks, validates root/ancestor directory types, checks regular file types, and propagates directory-walk errors. Missing/retyped directories and unexpected files or empty directories fail closed. Existing source, script, project and claim bindings remain required.
2. **CLI failure propagation:** `run()` returns its report only after writing it. `main()` raises `SystemExit(1)` for vendor nonzero or any recorded semantic/log/binding error, including a vendor-zero semantic failure. An error-free stage awaiting independent review still exits normally while remaining `accepted: false`, `requires_independent_review: true`, and `ready_for_build: false`.

These are ordinary preflight and status corrections, not an OS sandbox or protection against concurrent hostile filesystem mutation or an operator modifying the harness/receipts. Interrupted or malformed-output report limitations are unchanged. Older file-only staged receipts fail closed; no automatic migration, cleanup or retry is introduced.

## Inert verification

Read the existing implementation and tests before execution. Executed from `/home/joe`, with bytecode writes disabled:

```text
PYTHONDONTWRITEBYTECODE=1 python3 /home/joe/Projects/Thesis/AHLS/new_bsp/new/qualification/mailbox-migration-01/test_migration.py
Ran 33 tests in 26.805s
OK
exit code 0
```

Ten regressions augment the original 23 tests:

- Separate stage-then-mutate HOME and TMPDIR symlink tests.
- Unexpected file, unexpected empty directory, missing directory, directory replaced by file, and scratch symlink (ancestor of evidence) tests.
- Separate CLI vendor-rc-7 failure, vendor-rc-0 semantic failure, and successful-but-awaiting-review tests.

The new fixtures use the real binding checker with mocked immutable source/tool identities. Preflight regressions assert zero subprocess calls, zero `write_new` calls and unchanged evidence with only `staged.json` present. CLI regressions intercept every vendor subprocess, use synthetic XML only, exercise `main()` and `SystemExit`, and read the persisted report/log/claim after return or failure. The vendor-rc-7 test produces only the vendor error; the zero-vendor failure test produces a saved-mailbox semantic error. The existing intercepted three-stage sequence still enforces independent approvals and false acceptance.

The final unreviewed-template Python CLI rejection was also captured: exit 1, `ValueError: unreviewed binding`, before source access or scratch creation. Full output and final artifact hashes are in `test-results.json`. All four template harness hashes were verified against final bytes.

## File/scope accounting

Modified: `migration.py`, `test_migration.py`, `binding-template.json` (migration harness hash only), `README.md`, and `test-results.json`.

Created: `fix-report.md`.

Preserved without edits: `spec-review.md`, `child.tcl`, `parent.tcl`, `source-baseline.json`. Source/boundary hashes are verified by the passing existing inventory test. No work03 or source-tree writes, remote access, vendor execution, Tcl execution, configure/build, generation, integration, gate changes, commits, or live approval occurred. All vendor calls in successful fixture paths were intercepted. Exact command vectors, exclusive claims, source bindings, staged approvals and false readiness remain intact.

No implementation/test execution failures were encountered. Live executable/runtime/catalog/API/minimal-project prerequisites remain unresolved as previously documented. This report does not supersede the original independent review or claim a new independent PASS.

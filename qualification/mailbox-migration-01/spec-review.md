# Independent specification review — mailbox migration 01

## Disposition

**GAPS FOUND — not PASS. `ready_for_build: false`.**

The implementation substantially follows the requested scratch-only, staged migration design. One pre-execution isolation defect prevents an unconditional specification pass. A separate CLI failure-status defect should also be corrected. Missing live tool/catalog/API bindings are explicitly unfulfilled prerequisites, not evidence that vendor execution succeeded or necessarily implementation defects.

This review authorizes no staging on the workstation, vendor execution, integration, source rebinding, generation, or qualification.

## Concrete implementation gaps

### 1. High: first upgrade can launch with HOME/TMPDIR symlink escapes

References: `migration.py:311–317`, `320–339`, `342–375`, `397–400`.

`check_binding` checks the environment's **strings**, then calls `no_links(ROOT)`, but does not check `ROOT/home` or `ROOT/tmp`. Staging creates these directories safely, but staging and upgrade are separate operator invocations. For the first upgrade, `run` verifies the BMC inventory, QPF/QSF, scripts and claim; it does not inventory the complete scratch tree before launching. Thus a directory replaced by a symlink between staging and upgrade reaches `subprocess.run`. The complete scratch inventory rejects the symlink only **after** the subprocess has run. A tool respecting the supplied HOME/TMPDIR can therefore write outside scratch before rejection.

This does not require a race, modification of the harness, or changing the approved binding. The acknowledged absence of an OS sandbox does not excuse accepting a pre-existing escape through an explicitly controlled output path.

**Inert reproduction:** staged into a temporary local fixture, replaced its empty `home` directory with a symlink to a sibling temporary directory, used the real binding checker with the existing suite's mocked source/tool identity inputs, and intercepted the vendor subprocess. Result:

```text
INTERCEPTED_VENDOR_LAUNCH home_is_symlink=True
POST_LAUNCH_REJECTION symlink: /tmp/mailbox-review-inert-8ae9_huz/scratch/home
LAUNCH_COUNT 1
```

No vendor process executed and no outside-home payload was written. The same missing preflight applies to TMPDIR by code inspection. Child/parent have a full prior-report scratch inventory check, so this finding specifically concerns the initial upgrade barrier.

**Required correction criterion:** before any upgrade claim/log/write or vendor launch, validate the whole initial staged scratch state, including HOME/TMPDIR directory types and all ancestors, against the staged expected state. Reject symlinks and unexpected additions before launch. Add inert regressions for HOME and TMPDIR replacement after staging; assert zero subprocess calls and no new per-stage evidence writes. This is an ordinary preflight requirement, not a claim of protection against concurrent hostile filesystem mutation.

### 2. Medium: failed vendor/semantic stages return successful CLI status

References: `migration.py:389–401`, `404–422`.

`run` records failure in JSON but returns normally even when the vendor return code is nonzero or semantic errors exist. `main` does not propagate a failure status. A future operator invoking the documented CLI therefore receives exit zero for a completed-but-rejected stage. This undermines machine-readable failure reporting, though it does **not** bypass the next-stage receipt/approval checks.

**Inert reproduction:** intercepted `subprocess.run` to return code 7, called `main` with a temporary fixture binding and mocked live prerequisites. Result:

```text
{"phase": "upgrade", "errors": ["saved mailbox: public catalog resolution drift", "vendor returncode 7: None"], "accepted": false}
MAIN_RETURNED_NORMALLY_AFTER_VENDOR_RC_7
RECORDED_VENDOR_RC 7
```

The probe process exited 0. The report correctly retains vendor status; the defect is CLI status propagation, not concealed report contents.

**Required correction criterion:** persist evidence first, then exit nonzero when vendor execution or semantic checks failed; keep `accepted: false` for successful stages awaiting review. Add separate inert nonzero-vendor and zero-vendor/semantic-error CLI tests.

## Requirements satisfied by the inspected design

- **Explicit isolated context:** production constants restrict the successor to `/home/uwb_student00/ahls/new_BSP/qualification/mailbox-migration-01/scratch`. The QPF uses revision `mailbox_migration`; the QSF contains only family `Agilex 7` and device `AGFB027R25A2E2V`. No FIM source hook, pre/post callback, top-level assignment, bypass option, or implicit new-project flag is introduced. This is a practical minimal **proposal**, not proof of installed loader acceptance.
- **Source preservation:** initial staging makes independent byte copies of the complete bound BMC tree. The baseline covers 34 files including 24 IP leaves; the suite independently checked those counts and hashes, plus active wrapper/setup hashes. The production harness has no integration, original-source rewrite, work03 cleanup, claim cleanup, or build stage. Existing qualification gates are not removed by these files.
- **Fail closed on the supplied template:** the template is unreviewed, has null executable hashes and false prerequisite flags. `check_binding` rejects `reviewed: false` before source access, directory creation or vendor subprocesses. The inspected stored test receipt records CLI exit 1; the independently rerun suite covers pre-write rejection. Local harness hashes match the template.
- **Binding structure:** fixed source/root/part/speed, QPF/QSF content, cwd, search string, argv and harness hashes are checked. Supplied tool/catalog/evidence hashes are checked; four captured mailbox catalog identities are pinned. Source and tool reads reject ancestor symlinks. Complete transitive runtime/catalog closure remains a review obligation, expressly disclosed rather than falsely claimed to be dynamically resolved.
- **Exclusive attempts:** scratch directory creation is exclusive; claims and partial staging are retained after failure. Per-stage claim creation is exclusive. There is no automatic retry or cleanup.
- **Correct proposed selective command:** the upgrade command targets immediate parent `bmc_spi_sub.qsys` with exactly `--batch=./ip/bmc_spi_sub/sdm_mailbox.ip`. It does not target the outer subsystem or request synthesis/simulation. Installed help's generic “all IP cores” wording is correctly treated as insufficient evidence of actual selectivity. The upgrade comparison rejects changes to every other bound source, including the immediate parent, even if the vendor exits zero.
- **Separate stages and review barriers:** upgrade, child save/refresh and parent refresh are separate invocations. Child requires an independently supplied approval of the exact upgrade report; parent similarly requires child approval. Reports/logs/scratch hashes are checked before progression. Parent reports remain unaccepted, with final independent review still required.
- **Targeted Tcl:** child operates on `sdm_mailbox`; parent sync/reload/validation operates only on `bmc_spi_sub_0`. Leaf save is separate from upgrade. Child checks retained public parameters before/after save and after sync. Catch handlers print an error marker and exit 1. No Tcl was executed in this review.
- **Retained configuration and shared ownership:** saved leaf module parameters must exactly match the complete retained dictionary, including FIFO depths 1024/1024/4, memory selections, feature settings, device and speed. Non-target Qsys structure, address/reset/IRQ connections, logical references and board wrapper hashes are protected. Parent proxy external boundary representations must remain unchanged.
- **Waitrequest and semantic evidence:** leaf checks cover public version 23.0.0, retained old ports, AVMM waitrequest mapping, physical output, locked boundary and boundary mapping. Child checks both saved proxy boundaries and public originalModuleInfo. These are useful structural checks, not proof of live nonconstant backpressure or all possible metadata semantics. Full target deltas, timing, catalog/core resolution and nontermination/coherence remain explicit human approval obligations. That limitation is disclosed and is not automatic acceptance.
- **Evidence and scope limits:** normal completion produces raw combined stdout/stderr, vendor return code, raw source before-images, decoded XML deltas, source inventory and full scratch after-inventory. Reports always retain false readiness and acceptance. Interrupted/malformed-output reporting limits are documented. Generation, standalone/nested correctness, protocol, FLR, synthesis, timing and hardware qualification remain out of scope.

## Missing live prerequisites — distinct from the code defects

The following are correctly still blockers, not reasons to mark the harness or hardware ready:

1. Actual executable/launcher/runtime identities and complete dependency closure.
2. Resolved standard catalog closure, custom IRQ helper dependencies and absence of competing catalog resolutions.
3. Acceptance of the explicit minimal QPF/QSF by the installed loader, including its actual project-reference/write behavior.
4. Installed API/package compatibility for the proposed 26.1 Tcl context.
5. Successful selective migration of this saved leaf, followed by real persisted child/parent refresh and independent semantic/log review.
6. Evidence of public/core catalog resolution and coherent, unterminated real waitrequest, followed later by separately authorized standalone and nested generation/wiring verification.

The inspected `installed-refresh-tool-discovery.json` records help exits 0, but both API-discovery attempts exit 1: one lacks required project context and the other attempts an invalid hyphenated implicit project name. Neither establishes API availability or minimal-project success. The refresh procedure and BMC generation review correctly separate documented syntax, captured installed-source facts, migration acceptance and generation acceptance.

## Verification performed and review limits

Read the migration harness, Tcl scripts, template, baseline, README, test suite and stored results, and the three specified ipgen-03 evidence/procedure files. Inspected code before running inert tests.

Executed from `/home/joe`:

```text
PYTHONDONTWRITEBYTECODE=1 python3 /home/joe/Projects/Thesis/AHLS/new_bsp/new/qualification/mailbox-migration-01/test_migration.py
Ran 23 tests in 8.796s
OK
exit code 0
```

The printed synthetic upgrade/child/parent reports all remain `accepted: false`. Also verified all four template harness hashes and ran the two independent inert probes above. One initial symlink-probe wrapper recursed because of a reviewer mocking mistake; it produced no vendor execution and was corrected before obtaining the reported result. Fixtures used disposable temporary directories and intercepted subprocesses; synthetic XML is not vendor evidence.

No remote access, vendor executable, Tcl interpreter, build, generation, commit, or source/gate/claim modification was performed. The only persistent project file created by this review is this report. No implementation changes were made. **Readiness remains false.**

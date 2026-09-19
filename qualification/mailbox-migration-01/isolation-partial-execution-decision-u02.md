# Parent decision: one u02 partial nonvendor preflight

Within the standing IA-840F build/test task, authorize staging and one invocation of the independently specification-PASS and quality-APPROVED u02 bundle in `ia840f_migration_preflight`, subject to the pre-execution checks below. This is a new bounded decision, not renewal of u01.

- Manifest SHA-256: `8bad241dbf06925614014ba101476d91319be8d64a1fd6af4c5a81a44a39efac`.
- Input file: `isolation-preflight-u02/parent-inputs.json`, SHA-256 `d9936662bcaac9f3e97c11668b7aae54f96f55316fe1b723eff31ec72950bd03`.
- Deployment: `/home/uwb_student00/ahls/new_BSP/qualification/mailbox-migration-01/isolation-preflight-u02`.
- Exclusive fixture: `/home/uwb_student00/ahls/new_BSP/qualification/mailbox-migration-01/preflight-isolation-7c407469a419-u02`.

Parent reviewed the exact input roles/paths and tmux hash against `isolation-parent-input-evidence-live01.json`, and reviewed their consumers in current `preflight.py:519` onward. They match that observed evidence, not a new live observation. Fresh input bytes explicitly retain authorization/readiness/vendor flags false. The untouched template remains NOT_APPROVED. The exact partial scope is expressed by approval_scope, not by a general authorization flag.

Before staging/launch, verify current host/user/named tmux identity, workstation instruction hash, absent deployment and fixture, no-link ancestors, and interpreter identity/privilege. Bind command to the above manifest/input hashes. Drift stops; do not silently rebind. Stage with exclusive writes and verify every member before invocation. Retain exact invocation, complete output and exit status; read back result and any fixture final receipt.

Scope is only three fixed Python fixture probes and their reviewed supervisory cleanup. No vendor tools, license checkout, real migration scratch, source edits, installations, driver/boot changes, or programming. Preserve u01 and all failed evidence. No automatic retry, alternate suffix, cleanup or reuse after refusal/failure.

Explicitly accept the documented partial-control limitations for this experiment: runtime-only mount view; no full source/catalog content inventories; no vendor/license view; supervisory rather than kernel-enforced bounds; no full exec/syscall allowlist or hostile-code containment claim. This does not amend the existing vendor observer refusal. A result of exit 2 is never interpreted by itself as success; inspect detailed status and teardown evidence. All build-readiness and vendor-authorization flags remain false.

The nonblocking runner-docstring issue is recorded in quality-review.md; do not modify reviewed bundle bytes to fix it before this attempt.

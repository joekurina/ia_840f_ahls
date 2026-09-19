# Independent specification review — u02 role-scoping correction

## Verdict: PASS — exact partial nonvendor correction only

No specification blocker found for the narrow successor correction to the fixed Python-only isolation experiment. This is not execution approval, full-proposal acceptance, installed-sandbox qualification, hostile-code containment, vendor/license acceptance, or build readiness. Independent quality review and a fresh explicit parent decision with exact input bindings remain separate prerequisites. Authorization, readiness and vendor-run flags remain false.

Reviewed bindings:

- `HASHES.json`: `8bad241dbf06925614014ba101476d91319be8d64a1fd6af4c5a81a44a39efac`
- `preflight.py`: `a05eae4011bb02f3a1e5d73a4f0f65305eda3712ef73f398f97e3c54c55da34b`

## Concrete findings

### 1. Closed role classification satisfies the disposition

`preflight.py:27–36,207–231` binds executed tools exactly to `{python3, bwrap, tmux}` and inventory-only tools exactly to `{unshare, mount, setpriv, strace}`. The overlap and exact-union checks precede identity collection. Missing and unknown names refuse rather than defaulting to inventory-only. Returned roles derive from reviewed source; caller-supplied `role` fields cannot override them.

Every entry remains subject to the existing `/usr/bin/` location rule, expected realpath equality, regular-file type requirement, cumulative file-size/hash-byte allowance, capability detection and SHA-256 equality. The running interpreter realpath check remains. Only ENODATA is interpreted as absent capability data; other capability-query errors refuse. Mode is actual `st_mode`, not an expected-mode pin; capability bytes are retained as hex. Actual metadata overrides any similarly named caller fields.

SUID/SGID and nonempty capability bytes reject every executed tool, but no longer reject inventory-only entries merely for their privilege metadata. Privileged inventory mount still must be regular, hashed and capability-queried; its actual `0o104755` mode is retained, not normalized. This grants no execution permission and introduces no chmod, capability removal, fallback command or skipped identity check. Universal checks remain fail-fast: refusal of one entry need not collect later entries.

### 2. Production change is confined to ROOT and tool-role handling

An independently generated textual diff against immutable u01 contains only the successor ROOT constant, the two role constants, additive `tool_roles`, and the narrow `tool_identities` change. AST comparison independently finds only `tool_identities` changed and `tool_roles` added; every other function/class is unchanged, including `main`, fixed argv, preclaim ordering, B1 ownership and B2 cleanup/receipts. `probe.py`, `test_b1b2.py`, `tools.json`, `source-provenance.json` and `run_local_b1b2.py` are byte-identical to u01.

The ROOT-only audit projection independently hashes to `385b426817c8fe927550a9ee8473c70ca4f3cac406ca880fbdc229f2efc1a8dc`, matching its record. It is not an executed intermediate implementation. The old abstract-listener name and reserved vendor/observation paths deliberately remain unchanged; they are not successor deployment or fixture paths.

B1 still promotes an info-pipe candidate only after the repeated live-pidfd identity/ancestry/namespace checks against the fork-owned supervisor. Rejected handles are closed, not signaled. B2 still independently stops owned processes, performs bounded nonblocking reaping and namespace/exit verification, closes descriptors, preserves the primary error and terminal reserve, and reports uncertain teardown or unavailable terminal evidence honestly. The u01 `spec-b1b2-review.md` and `quality-b1b2-review.md` were read as the accepted partial-scope baseline, not reused as approval for u02.

### 3. Payload privilege safeguards remain mandatory

`probe.py:58–84,87–89,136–137` is unchanged: both controls and lifecycle require the baseline before substantive fixture actions. It requires `NoNewPrivs=1` and zero `CapInh`, `CapPrm`, `CapEff`, `CapBnd`, and `CapAmb`. The unchanged fixed launch uses isolated Python without optimization flags and requests `--cap-drop ALL`; no role-conditioned payload bypass was added.

README correctly distinguishes read-only `/usr` exposure from `noexec`/`nosuid` and from a kernel execution allowlist. Setuid mount remains visible and executable in the intended runtime view. Installed bwrap must establish no-new-privileges, and the payload must observe it; no installed success is asserted. No-new-privileges does not revoke already-held privilege, so the zero-capability checks remain essential. Interpreter trust before invocation remains a separate requirement, not something the running controller can establish retroactively.

### 4. Successor and authorization boundaries are preserved

The sole new fixture root is:

`/home/uwb_student00/ahls/new_BSP/qualification/mailbox-migration-01/preflight-isolation-7c407469a419-u02`

The documented future deployment is:

`/home/uwb_student00/ahls/new_BSP/qualification/mailbox-migration-01/isolation-preflight-u02`

No filled parent-input or approval/decision file was carried into this successor. The only input template remains `NOT_APPROVED`, with null tool/path values and explicit false authorization/readiness/vendor flags. Retained final CLI evidence reports exit 2, `REFUSED_BEFORE_CLAIM`, approval-scope mismatch, and no retained fixture root. Static main ordering confirms this refusal precedes host/tool discovery and claim creation. That is retained local refusal evidence, not a newly executed review test.

The consumed u01 authorization is not renewed by fixture absence. Even a future successful partial experiment retains `FINITE_FIXTURE_CONTROLS_OBSERVED_PROPOSAL_INCOMPLETE` and exit 2, not full acceptance.

## Independent static verification

Read IMPLEMENTATION, README, manifest, source/successor provenance, preservation records, disposition, prior B1/B2 reviews, implementation/payload, new tests/runner, and retained test evidence. Read-only Python parsing, hashing and filesystem metadata enumeration were used; no reviewed module was imported or executed, no tests rerun, no subprocess/tool launch or remote action performed.

- Both reported digests above match actual bytes; all 14 manifest members match.
- All three source-provenance bindings match their source documents. All copied-source hashes in successor provenance match u01, and its disposition digest matches.
- All seven final `tested_sha256` entries match current source/test/runner bytes. All seven files parse with Python 3.9 grammar; this does not establish execution on Python 3.9.
- AST-enumerated test names exactly match successful final transcript names: 14 existing, 19 B1/B2 and 15 new tests, **48 total**, with zero recorded failures/errors/skips. Final evidence identifies Python 3.13.5. These are retained inert/local tests, including the inherited ordinary Python-child pidfd test, not namespace or installed-tool observations.
- New tests cover closed roles, missing/unknown/overlapping maps, role override resistance, actual privileged inventory metadata, executed SUID/SGID/capability rejection, universal identity/type/location/realpath/hash/capability-query failures, cumulative inventory size accounting, interpreter mismatch and mandatory payload privilege fields.
- All 96 entries in `EVIDENCE-HASHES.json` match current recorded mode and, where applicable, size/hash or symlink target. Special files were not opened.
- Independently enumerated the qualification tree excluding u02: exactly 502 entries match `preservation-before.json`, with no additions, deletions or metadata/content differences. This includes immutable u01 and retained attempted-run evidence; no remote receipts were fetched or independently inspected.
- The retained RED failure and first verification batch are not hidden: final evidence supersedes the earlier single cumulative-cap fixture failure. The first and final batches bind identical production preflight bytes; final source/test bindings match the reviewed files.

## Remaining limits and review effect

The already-declared missing full-proposal identity/content inventories, vendor/license view, complete aggregate bounds and other broader controls are not new blockers for this explicitly partial experiment. Installed bwrap topology, namespace denial behavior, no-new-privileges establishment, lifecycle propagation and actual teardown remain unverified. Passing retained local tests does not resolve them.

Only `isolation-preflight-u02/spec-review.md` was created by this review. No implementation, historical record, approval input, readiness flag or manifest was changed. This scoped PASS supplies neither staging permission nor permission to retry or execute remotely.

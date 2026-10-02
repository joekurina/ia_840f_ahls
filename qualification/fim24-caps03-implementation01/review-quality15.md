# Execution QUALITY review15 — NOT APPROVED

**Verdict:** one important, deterministic runner/callback integration defect blocks admission of this package. SOURCE/API08 and its consumed09 preparation acceptance remain intact; no vendor-internal requalification is requested.

Reviewer: **GPT-6 / `openai-codex`, substituting for unavailable GLM5.3**. This review used local reads, hashes, JSON comparisons and AST inspection only. No project code was executed or imported; no Tcl, tests, vendor tools, remote commands, Git or hardware operations were executed. Only this review is written.

## Frozen evidence verified

Rehashed **91/91** members of `quality-freeze14.json`: exact recorded sizes and SHA-256, no mismatches. Freeze SHA-256:

`099964758e95e360a28700f88c71ef23450ee08e18dafe2aa9c08b830dd4df46`

Independently rehashed **60/60** SOURCE members and confirmed their unchanged inclusion in the QUALITY freeze. All nine stage13 exports match their captured payloads and local readbacks. Candidate/staged runner, callback, Tcl and CMake bytes agree.

Compared the recorded inventories: exactly 857 old copied DNI entries form the archive; only the two new gate paths were added; the only changed retained entry is the PR QSF, with exactly the two gate-reference substitutions. Active 2589 and critical 2588 differ only by QPF. All eight draft inventory maps equal the pinned prepared metadata; original setup 3443 agrees with the copy's original inventory. External 298, release 3454, eight tools and 92 OPAE helpers remain bound. Static QDB and QPF-before records agree with retained evidence. These are retained-evidence checks, not a fresh remote filesystem observation.

## Important Q15-1 — live owner identity can never match

**Locations:** `candidate09/run-synthesis09.py:19–24,174,262–263`; `candidate09/ia840f_persona_gate09.py:16–24,56,60–66,79–87`. The staged copies contain the same defect.

The runner's `identity()` returns `start_ticks` directly from `fields[19]`, therefore as a **string**. It stores that identity in `result['runner']` and serializes it unchanged into `authority.json`. Conversely, the callback's `proc()` returns `start_ticks=int(s[19])`, therefore an **integer**. JSON round-trip preserves this distinction. `owner_live()` compares these values directly alongside PID/executable/cwd/argv, so its equality assertion fails even for the exact live owner. The ancestor comparison repeats the incompatible equality.

This is not speculative Quartus behavior: the retained clean runner fixture also records string start ticks in its process identities. Once a real admitted synthesis reaches the first callback, it necessarily rejects at `owner_live()` before accepting inputs/context. Its fallback rejection-file append calls the same failing owner check, so that append also fails; the stderr/Tcl rejection marker remains. The supervisor/postflight should fail closed, but the exclusive synthesis attempt would already have been consumed without a usable accepted callback. This is a functionality blocker, not an authorization bypass.

**Why retained tests missed it:** `test-gate10.py:25–27,33,63` supplies integer-valued owner/native identities on both sides and mocks `proc()`. `test-runner12.py:31–44,63` mocks admission and writes synthetic callback events instead of invoking the gate. Issuer fixtures mock imported preflight. Stage13 missing-authority rejection never reaches live-owner validation. Thus the green component fixtures do not establish this producer/consumer boundary.

**Required correction:** use one explicit start-tick representation across the actual runner-produced, JSON-serialized authority and actual callback process/ancestor readers, preserving strict PID/start/executable/cwd/argv equality. Add a bounded inert integration regression crossing that real serialization/reader boundary, with current-owner acceptance and changed-start/stale-owner rejection; it must fail on these frozen bytes and pass on the corrected package. Rebind changed controls and dependent receipts/draft through the parent. Do not edit original sources, retained evidence or any in-flight copy to conceal the mismatch.

## Other execution and issuer assessment

- Early preflight precedes exclusive run creation and binds the exact manifest, code, prerequisites, prepared maps, complete design entry set, static UUID/QDB, resources and competing-process absence. Environment construction retains only current license variables plus explicit paths/settings; `OPAE_PLATFORM_GEN` is absent and the gate rejects even its value `0`. CMake exposes direct version/synthesis targets, not fit/STA/assembly/GBS flows.
- Supervision protects immediately after spawn, retains the unreaped leader until group signaling, drains within the original deadline, and checks rejection/125091 markers and log size during running, draining and final reads. Raw CMake status is persisted before postflight; nonzero CMake status is not misrepresented as an independently known vendor exit. Limits are 36 CPUs, 64 GiB per process, 60/60/1200-second deadlines and a polled 32 MiB log threshold—not a sandbox, aggregate-memory limit or filesystem quota.
- Acceptance includes all eight preservation domains, empty acquisition-error/diagnostic sets, version/banner checks, accepted callback evidence, three nonempty reports and fresh QDB inventory. QPF handling retains raw before/after and requires unique supported keys, unchanged version 26.1 and sole revision `ofs_pr_afu`; this is not a generic metadata waiver. Mapping/source diagnostics still require independent actual-result review, not timing/hardware acceptance.
- Issuer16 pins the exact draft and runner, restricts the five packet members, reconstructs the permitted admission delta, creates receipts/manifest exclusively, verifies readback, and calls only non-consuming preflight. Partial issuance remains preserved. Its unrendered digest is not authority; protocol fixtures do not prove an actual admissible runtime package.

Retained case counts reconcile exactly: **21 gate, 22 runner, 5 CMake, 2 Tcl, 7 issuer**. Their documented mocks and inert children are not native project-load/synthesis evidence. Runner coverage includes seven preservation-drift families; predecessor-result drift is checked in production but has no dedicated mutation case in `test-runner12.py`.

**Disposition:** withhold QUALITY consumption and admission issuance pending Q15-1 correction and focused regression/review. No synthesis, fit, STA, assembly, GBS, programming or hardware authority follows from this report.

# Work24 PR-export QUALITY review21

**Verdict: REQUEST_CHANGES.** One blocking supervision defect (I1); the SOURCE SPEC passes remain valid within their stated scopes. Do not issue the admitted record for this runner yet.

Reviewer: GPT-6/openai-codex, substituting for unavailable GLM5.3. Local reads, hashing, AST inspection and in-memory comparisons only; no prepared-script/test execution, native tools, SSH, Git or hardware operations. Only this report is authored. Paths below are relative to `qualification/fim24-pr-platform01/` unless absolute.

## Critical

None identified.

## Important

**I1 — Descendant draining stops enforcing the log/rejection watchdog.** `candidate15/run-export15.py:192–214` scans log size and gate markers only while `waitid(...WNOWAIT)` reports the CMake leader running. Once that leader exits, the residual-group loop at lines 210–212 only sleeps and enumerates processes. A surviving same-group helper can therefore keep writing beyond the admitted 32 MiB limit, or emit `IA840F_GATE_REJECTED`/125091, without intervention until it finishes or the original deadline expires (up to 600 seconds for export). The postflight scan at lines 143–149 rejects the eventual result, but does not restore the missing live resource/rejection protection. This is an existing lifecycle path, not a request for sandboxing or new infrastructure.

Keep the existing bounded size/marker checks active throughout residual-group draining while retaining the unreaped leader and original deadline. Add a real inert case in which the leader exits first and a surviving writer crosses the limit or emits a rejection marker; require prompt owned-group termination, failure evidence and unchanged replay receipts. The current `finite_descendant` merely sleeps, while `short_lived_log_overflow` has no surviving writer (`test-export-runner15.py:103,106`), so neither covers this gap. Preserve the frozen runner and receipts; bind the corrected successor and its evidence before renewed QUALITY consumption/issuance.

## Minor

**M1 — The post-spawn fixture does not demonstrate termination of the advertised sleeping child.** In `test-export-runner15.py:61–64,72–74,102`, the identity fault triggers on the first configure child, whose actual code is `raise SystemExit(0)`. The supplied export sleep is never reached. `export-runner-inert15.json` and the retained `postspawn_exception/operation/status.json` record only configure, raw rc0, and the injected identity exception. This proves exception-to-failure handling, not cleanup of a long-running child after bookkeeping failure. Target a genuinely live child when strengthening this fixture; do not describe the existing receipt as that stronger proof. This is not an additional implementation blocker by itself.

## Verified binding and evidence

- Independently verified **35/35** sizes/SHA256 values in `quality-freeze20.json`, SHA256 `2c7111a8dc3189eabf58575876fa8c1b3de0cdb633de2039c93b5d5446138a91`. Also verified its nested 24-member final freeze and 224-member source freeze, both review/consumption hash links, and all seven resource16 transport exports against local readbacks.
- Local and actual-readback runner bytes both hash to `a459526f387618395ba479f0333e837cb11b1a7e60fabd41599aa22f093e9bf6`. The final draft binds that runner and the captured 4,285-entry inventory; comparison with prepared10 shows exactly the PR-QSF resource-line change. All 2,541 critical-input hashes agree with that inventory. The stage digest resolves to the captured 6,160-entry original inventory and unchanged five static-artifact bindings.
- Reviewed all ten final lifecycle cases and compared retained fixture statuses/results and available log hashes with the frozen report. Evidence includes raw nonzero propagation, late125091 producing outer failure despite child zero, finite-descendant completion, TERM-resistant timeout with effective124 and no recorded live residuals, postflight failure, overflow rejection and replay preservation. Admission/CMake/tmux/artifact data are mocked; these are not vendor integration results. `resource16-readback/entry-rejection16.json` separately proves only actual missing-admission rejection before operation/target creation.
- `candidate03/CMakeLists.txt` invokes direct pinned version/export targets with explicit paths and no release `-f`. The Python/Tcl gate retains exact executable/cwd/argv/self/source hashes and live runner ancestry, release-only scope and build-readiness false. Twenty gate fixtures and five configure/help checks reconcile to their declared totals and candidate hashes. Original gates remain preserved.
- Fresh preflight binds original/prepared inventories, tools/providers and 276 PIM members; full 36-CPU affinity, 64 GiB soft/hard per-process address space, headroom and competing-job checks remain. License values are inherited, not printed by the runner. Postflight rejects late Error/Fatal diagnostics and preservation failures. No aggregate memory containment is claimed.

## Issuance boundary

`EXECUTION-SCOPE19.md:29–33` otherwise gives a coherent sequence: consume final reviews, derive admission from exact draft15, bind review/consumption bytes, resolve the pending field, exclusively create `prepared15/export-inputs.admitted.json`, read back its digest and dispatch through owned tmux. I1 blocks that sequence for the presently frozen runner. Six finite contexts remain unchanged; actual 26.1.1 IPC serialization is properly left to the first bounded experiment, not made a circular prerequisite. PR A&E/DRC, exported PIM/source closure, static-image/interface matching and independent actual-result acceptance remain future obligations, not persona or hardware qualification.

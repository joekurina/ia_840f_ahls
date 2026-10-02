# Migrated Questa execution QUALITY review20

**Verdict: REQUEST_CHANGES.** One important scoreboard-parser defect prevents approval of the frozen runtime. No source/API re-review or vendor-RTL change is requested. This review grants no issuance or launch authority.

**Reviewer:** GPT-6 (`gpt-6-astra-900k`), provider `openai-codex`, substituting for unavailable GLM5.3. Review used local reads, in-memory SHA256/size verification, static source/AST comparisons and retained receipts. No package script was imported or executed; no tests, CMake, simulator, SSH, Git or hardware operations were run. Only this report was authored. Paths below are relative to this qualification directory unless stated otherwise.

## Frozen identity

Verified **610/610 members**, including every declared size and SHA256, with zero mismatches; repeated verification before reporting. All **590 accepted source members** remain identical to `source-freeze13.json`. The remaining 20 members bind runtime, staging, SPEC consumption and issuer evidence. `quality-freeze20.json` SHA256:

`3b4495d03c9f11143dbdf138697c19c1d51499966437480a90613e4658911c28`

Candidate/staged runtime copies are byte-identical. Bindings:

- Runner: `8496650c3579b5d8d8b7abc82b247b05c5086d913bcd9635c52e0508b43b7fa5`.
- CMake: `ab48c447de4f10c13510721a2f3d7eaafdab19c69c7e3a6eff27dea6031d2414`.
- Draft17: `b0bd629a1e077453a3d85da5942a316583df1f43dbc906c5d5e221c625157364`.

Verified the SPEC14 → consumption19 digest chain, stage17 compressed-envelope identity and all five decoded readbacks. Draft inventories equal prepared metadata: 560 inputs/15,337,338 bytes, 542 originals, 19 simulator/INI/library bindings, three runtime tools and 458 unique compile entries. CMake's ordered compile vector equals the draft. SPEC PASS is retained without reopening vendor internals.

## Critical

None identified within the stated ordinary-account, unit-simulation scope.

## Important — I1: scoreboard matching is not exact

`candidate13/run-simulation13.py:93–97` (identical staged copy) counts literal **substrings** for reset/split markers and counts only regex-matching main rows. This does not enforce the exact counters and duplicate rejection required by `SCOPE12.md:21` and `source-spec-review14.md:43`.

Static counterexamples with otherwise valid, diagnostic-free logs:

- A split line ending `observed_split_errors=10` still contains the complete expected literal ending `observed_split_errors=1`; `split_count` remains one.
- `BANK1_RESET_INVALIDATION_PASS checks=10` likewise satisfies the required `checks=1` substring.
- One valid reset/split row followed by another row with different counters can leave the expected-substring count at one. A malformed second `AHLS_PATH_UNIT_PASS` row can similarly be ignored by `findall`.

Consequently, the functional predicate can report pass without the specified exact scoreboard evidence. These are source-derived counterexamples, not executed fixtures or claimed native failures. Native status/diagnostic rejection is valuable but does not repair this independent acceptance predicate.

**Required correction:** parse complete scoreboard records, permitting the actual Questa transcript prefix while rejecting trailing numeric/text extensions; count every occurrence of each scoreboard marker family, require exactly one well-formed record per family, and compare parsed counter values. Retain the existing main totals and positive-check requirement. Add narrow negative fixtures for numeric suffixes and valid-plus-wrong/malformed duplicate records, with the existing positive control. Rebind the corrected runner/tests/staged draft and issuer pins for review; do not issue the currently frozen draft. Functional RTL and accepted command/source selection need not change.

## Minor

No separate blocking or actionable minor finding raised.

## Native supervision and failure handling

`candidate13/run-simulation13.py:53–84,128–241` performs admission, host/session, code/prerequisite, metadata/inventory, setup-result, resource and competing-tool checks before exclusive `native01` creation. The pinned metadata prevents empty secondary inventories from making preservation vacuous. The environment uses fresh HOME/TMPDIR, copied installed INI through MODELSIM, explicit tool PATH and inherited license values without recording their values. Configure and six targets execute serially.

Static comparison with accepted persona setup03 confirms identical identity/group helpers and supervisor body except the two native-zero label tuples. Protection starts immediately after spawn; the leader stays unreaped until group signaling finishes, descendants drain under the original deadline, and log-size/rejection checks cover leader, drain and final bytes. Raw CMake status is persisted before postflight; individual nonzero vendor status is correctly left unknown rather than inferred from CMake.

Postflight requires seven logs, pinned version, all seven preservation domains and no acquisition errors. Error/Fatal detection includes timestamp/internal and parenthesized qualifiers plus nonzero Errors summaries; native zero cannot override these failures. The preserved postflight-exception case yields failure despite zero command statuses. Limits are 36 CPUs, 64 GiB **per process**, declared command deadlines and a polled 2,000,000-byte log threshold—not aggregate containment, a filesystem quota or an operator-proof sandbox.

## Admission and retained coverage

`issue-admission21.py.in:8–40` mechanically retargets the accepted setup issuer: fixed five-member packet, exact pinned draft, review/consumption cross-binding, whole-target equality, exclusive admission directory/manifest, exact readback and only hash-verified non-consuming runner preflight. Allowed record changes are parent acceptance, four receipt prerequisites and `execution_review`; hardware readiness stays false. The single packet-digest placeholder remains unrendered.

Reconciled retained results: **15 runner cases**, **11 negative scoreboard fixtures plus positive control**, **five CMake checks**, and **seven issuer cases**. Receipts cover failure/status propagation, missing/wrong scoreboards, fatal diagnostics, drift, overflow, timeout, drain rejection, postflight exception and unchanged replay; recorded owned groups finish empty. They do not cover I1. Host/admission/CMake/tmux and fixture artifacts are mocked; real inert Python children and dry-run quoting are preparation evidence, not native compatibility. Stage17 records actual missing-admission rejection before operation creation, not a fresh remote observation.

After correction and approval, parent consumption, sole-literal issuer rendering, live preflight/readback and durable outer-status capture remain required. No native simulation is accepted. Full PCIe/AFUtop/pr_slot, physical DDR, timing and hardware remain excluded; the retained Quartus legacy-addenda gap belongs only to the separately reviewed future compile copy.

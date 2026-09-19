# Narrow correction quality review — byte-line-questa-02

**PASS for local candidate correctness and inert regression checks.** This is a
self-review of the narrow repair, not independent parent acceptance, remote
readback, or simulator qualification. Parent quality acceptance/attestation must
refer to this corrected pin before any subsequent execution.

## Evidence and scope

The preserved `../byte-line-questa-transfer-01/run-01-evidence.json` records
`vlib -version` returning 1 with usage, then `Stage rejected: vlib-version`.
No HDL compilation or simulation was reached. This was a runner compatibility
failure, not an HDL failure and not a reason to redesign the fixture.

`old-new.diff` was inspected after the successful test run. The runner has exactly
one changed line: the version-probe tuple is now `('vlog', 'vsim')`. The
executable-presence check and before/after identity/hash inventory still include
`vlib`, and the real `vlib work` stage and its 30-second timeout are unchanged.
All compile/simulation commands, timeouts, transcript criteria, failure-code
propagation, isolation settings, and runtime identity guards remain unchanged.

The README corrects the two version logs and candidate path and explicitly labels
inherited inert logs/preparation evidence as historical. The test's expected stage
sequence removes only the unsupported probe and adds exact argument/timeout
assertions for both version probes and `vlib work`, plus retained vlib hash and
before/after tool equality assertions. No test fixture source was changed.

## Verified locally

- Exact original manifest SHA-256 and all 24 pinned member hashes checked before
  copying; only those members plus the manifest were copied.
- Candidate is exactly 25 files, including its 24-member manifest; no symlinks,
  caches, or unpinned root `spec-review.md`. Pinned `provenance/spec-review.md`
  remains included. New reviews and evidence stay outside the package.
- All 13 inputs and the input manifest are byte-identical to -01; `sources.f`
  is unchanged. The only changed members are README.md, run.py, test_runner.py,
  plus the necessarily recomputed inventory file.
- Four inert tests passed (exit 0) in a disposable copy. Actual Python child exit
  and timeout handling were exercised; vendor stages were mocked and no fixture
  tool was executed. Parser, runtime rejection, compile-failure barrier, hash
  rejection and exclusive rerun-evidence tests remain passing.
- Candidate hashes/file set are unchanged by testing, and the complete original
  -01 directory, including its unpinned review, remains unchanged.

See `inert-tests-02.log`, `inert-test-execution.json`, `verification.json`, and
`pins-and-diff.json`. `verify_candidate.py` records the performed preparation/test
procedure; it is intentionally single-use (exclusive evidence creation), not a
command to rerun against existing evidence.

## Pins and next acceptance boundary

Both manifests are 3276 bytes:

- Old: `ec6800e15dff71f9b57ce51e39111cb1db9b4c55d9683896a7aa00bf1fae8fbe`
- New: `9349f62a93c416f743e3f15262814b028c95f7f6fa81d91463ba7e8176205b2d`

For a later parent-authorized transfer, use exactly the candidate's manifest-listed
paths plus `package-sha256.json`, verify this retained new manifest pin and each
member's size/hash and exact recursive file set at the destination, and use fresh
exclusive package/results paths. Do not copy this transfer/review directory into
the execution package or reuse run-01 output. Keep the established tmux/UID/host
and license requirements. The user has approved simulations within the existing
unit-fixture scope; do not expand to detailed calibration, long traffic, or
extensive reset/error tests. No extra user reapproval is implied by this technical
review boundary.

No remote contact, vendor commands, HDL compilation/simulation, maintained-source
edits or commits occurred in this task. Actual Questa behavior after the repaired
probe remains unverified until the bounded simulator attempt. Existing expected
154 scenarios are not claimed as executed. No remaining local defect was found
within the narrow correction scope.

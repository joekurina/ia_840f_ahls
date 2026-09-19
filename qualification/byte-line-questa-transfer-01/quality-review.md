# Byte-line Questa execution package — quality review

**Verdict: APPROVE for the bounded, reviewed execution attempt under `disposition.md` and `followup-spec.md`. No blocking quality defect found.** This is execution-package acceptance, not successful transfer, simulator qualification, or BSP qualification. **Actual HDL cycles executed: 0.**

## Reviewed identity and transfer boundary

Reviewed `../byte-line-questa-01/run.py`, `test_runner.py`, the real DUT/interface/package dependencies, unchanged bench, source list, input/package manifests, README, original spec review, and the explicit R1 closure.

Independently verified:

- `package-sha256.json`: 3276 bytes, SHA-256 `ec6800e15dff71f9b57ce51e39111cb1db9b4c55d9683896a7aa00bf1fae8fbe`.
- All 24 manifest entries match their recorded sizes and hashes. The transferable payload is exactly those entries plus the manifest: **25 files**.
- All 13 input copies match both their manifest pins and actual original source paths. The three historical provenance copies match `../byte-line-protocol-01/` byte for byte.
- Package-root `spec-review.md` must remain outside the transferred payload; **`provenance/spec-review.md` must be included**. Do not use a basename exclusion. R1 is closed by the explicit supersession, not by modifying the manifest or weakening inventory checks.

## Quality findings

### Real bench and dependency closure

`sources.f` compiles the actual CCI-P package before the log package, Avalon interface, adapter and bench. The active umbrella/clock includes resolve within the copied inputs; guards handle their recursive inclusion. The three explicit fixture definitions cover the active host-port count, data-width and MMIO-width references. Native-class wrappers are inactive; the unchanged top configuration disables legacy compatibility, not interface validation. No substitute DUT/package or assertion suppression is used.

The bench checks address normalization, alignment rejection, request/data/mask/user forwarding, reset/stall behavior, response wiring and its synthetic storage oracle against the real combinational adapter. Static expansion and arithmetic confirm **154 planned checked cycles and 160007 planned checks**, consistent with the required terminal marker. This does not imply that those checks ran. Reset coverage is reset/stall overlap, not interruption of an already-held stalled write; the alternating offset stalls and synthetic memory/burst limitations remain correctly disclosed.

### Fail-closed, bounded execution

`run.py:110-156` checks target identity, real/effective UID, TMUX, license/tool prerequisites, fresh output location, exact package inventory and source pins before creating the run directory or invoking tools. Remote named-tmux and separate manifest-pin readback are operator/procedure requirements, not an OS security boundary.

`run.py:193-212` orders three version stages, library creation, compilation and simulation, with explicit per-stage timeouts. A failed stage or diagnostic prevents later stages, including simulation after a zero-exit compilation containing errors. Timeout handling kills the child process group and records rc 124. Positive native failure codes propagate; signal failures remain nonzero. The simulation do-string has nonzero error/break/fallback exits.

`run.py:213-245` requires ordered CHECKED entries 1 through 154, one exact PASS marker, zero simulation rc, clean diagnostics and an existing clean native transcript. Final source/configuration/package/tool comparisons can revoke a tentative PASS. There is no conversion of a missing log, partial simulation or changed source into qualification.

### Evidence and preservation

Fresh exclusive run/stage directories and exclusive JSON/log creation prevent reruns from replacing existing evidence. The runner captures exact stage argv, cwd, explicit environment, timeout, combined stdout/stderr, return code and log hash; it preserves version logs and before/after source, configuration and tool identities. Sources are copied into the fresh result directory; maintained sources and original evidence are not execution destinations. Tool pins cover the selected launchers, not every internal executable/shared library; this limitation is disclosed and is not a blocker to the trusted-tool experiment.

## Inert verification actually performed

Constructed disposable exact-manifest payload copies outside the original package, with bytecode writes disabled. Ran the supplied suite using the Python interpreter with `-B <disposable-payload>/test_runner.py`:

```text
test_compile_failure_blocks_simulation_and_preserves_rerun ... ok
test_real_inert_python_stage_and_timeout ... ok
test_runtime_identity_rejected ... ok
test_transcript_acceptance_and_mutations ... ok
Ran 4 tests in 0.247s
OK
process rc: 0
```

These tests exercised real **Python-only** child exit/timeout handling, evidence immutability, parser mutations, identity rejection, source-tamper rejection and the mocked compile barrier. The synthetic transcripts are not HDL results.

Five supplementary in-memory mocked-stage checks on a disposable copied runner also passed:

| Inert case | Observed runner result |
|---|---|
| Complete synthetic transcript and clean native log | rc 0, PASS, six mocked stages |
| Compile diagnostic with native rc 0 | rc 2, FAIL; simulation not called |
| Missing native simulator transcript | rc 2, FAIL |
| Staged bench changed after mock simulation | rc 2, FAIL |
| Tool identity changed after mock simulation | rc 2, FAIL |

Mock tool identity files were nonexecutable and were never invoked. Disposable files were removed. Independently compared the original package's complete file set and every file's size/hash before and after testing: unchanged.

## Execution disposition and remaining uncertainty

Proceed only with the already specified exact-set transfer/readback, named tmux, exclusive fresh execution-package directory and separate fresh results directory. Preserve failed attempts and review real diagnostics rather than weakening acceptance gates. No package correction is requested by this quality review.

Installed option compatibility, licensing, isolated ini behavior, real compilation/elaboration and `$finish` exit semantics remain unverified until the actual bounded attempt. Those are explicit experimental acceptance questions, not evidence of a presently demonstrated defect. Even a later simulator PASS qualifies only this adapter unit fixture, not a functional integrated BSP or hardware.

**Sole retained write:** `byte-line-questa-transfer-01/quality-review.md`. No remote contact, transfer, vendor/HDL execution, maintained-source/package modification or commit occurred.

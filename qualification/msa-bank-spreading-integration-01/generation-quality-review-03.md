# Independent code-quality / execution review — candidate03

## Verdict: APPROVE the exact bounded memory-generation runner

No concrete critical or important must-fix defect remains in the reviewed scope. This is quality acceptance of the proposed experiment, not authorization consumption, remote verification, vendor acceptance, or readiness/functional/timing qualification.

Exact reviewed identities (independently computed):

- `generation-candidate-03/package-manifest.json`: SHA256 `8da56f00d8e49f95fe1d3fbd90812440cd7c5af39f8bd4d267b3c360e9b9543c`.
- `generation-candidate-03/run_generation.py`: SHA256 `4ab5a5e10a78afc2029e7aaf868b99553de173a581407a38f88718904b397e12`.
- Accepted preceding `generation-spec-review-03.md`: SHA256 `d940386f4f95c7506227fe4cb189d75b03b659ce4e27f8065d7e22040f4b57b9`.

Read specification reviews 02/03, correction03 REPORT, candidate REVIEW/SUCCESSOR, complete runner, Tcl, checker, both test files, review template, manifest and execution binding. Accepted predecessor source/help-grounded scope is retained, not reopened into broad research. Captured installed help was checked for generation options and optional project context.

## Findings

- **Binding and entry ordering:** `check_package` requires explicit spec/quality approval, exact manifest identity and `execution_ready=false`, then verifies every bound file. This precedes tmux inspection, claim, WORK, logs and vendor invocation. SOURCE gate bytes are checked before import; complete SOURCE/PIM/dependencies are compared before launch, at the save callback, between stages and after successful comparison. Bound inventory counts are 1,360 SOURCE files, 530 PIM entries and 419 dependencies. The Tcl's first command checks review, active stage, exact live runner identity and ancestry. These are trusted normal-account guards, not adversarial containment.
- **Exclusive lifecycle / failure propagation:** exclusive RUN/WORK creation and exclusive claim/invocation/log/result writes prevent reuse of failed attempts. Native nonzero status propagates through the outer main (including negative-signal conversion); timeout remains rc124. Native error/fatal/qualified diagnostics and the captured project-loader rejection warning are independent rejection conditions even with native zero. Failure evidence and false readiness are preserved. Mutable active-stage bookkeeping is within the exclusively owned attempt, not reusable authorization.
- **S1 timeout correction:** the `start_new_session=True` leader remains unreaped through TERM, the full ten-second grace, and KILL to its owned PGID independently of launcher exit. Absent-group signal races are tolerated. The bounded post-KILL check distinguishes Z/X from live writers and reports unsuccessful cleanup without an unbounded wait or false death claim. Prior spec03 includes the independent writer and synthetic persistent-D branch evidence; this review additionally reran the real fork regression. Deliberate group escape and kernel uninterruptible-task removal are not promised.
- **Native scope:** exact Quartus 26.1.1 `sopc_builder/bin` paths and AGFB027R25A2E2V remain bound. The first stage is the accepted memory-only `qsys-script --qpf=none` preset deployment, archive, reload and save. Generation receives only the new positional `mem_ss.ip`, synthesis VERILOG, explicit part/search path and parallel off. There is no broad project open/enumeration, upgrade, full-FIM setup, compile or Query04. Native acceptance of this exact new run remains unproven.
- **Comparison gating:** generation cannot begin until complete saved comparison accepts exactly both scoped FIFO 8→0 changes with copies1, and first-save/reload bytes match. The checker includes the 3,016 scoped saved/nested parameters and complete serialized XML, rather than flattening interface properties. Strict saved metadata drift is a valid retained rejection requiring itemized review, not grounds to weaken the checker or block the experiment speculatively.
- **Generated evidence, not qualification:** the checker inventories the full fresh output and compares captured synthesis hierarchy XML plus wrappers, ports, full ordered parameter/connection maps and both MSA zero/copies1 changes. Generated directory tokens pair filenames only; full content deltas remain. Missing counterparts or failed MSA checks reject. Other generated drift remains available for independent review. Even the tested inert completion path records `generated_acceptance=false` and all readiness false. The wrapper recognizer is scoped to the captured vendor format, not a general Verilog semantic proof.

No SOURCE/gate, QSF, hold ON / seed2 / maximum-placement, pin/clock, memory geometry, calibration or PCIe change is proposed. The existing integrated three-file correction and receipt identity `8357a7547a844044ceaf4b2414224c69974ab2d730a09613c24562fee626924a` remain the accepted historical integration context, not a new live remote observation. Work11 failed-timing evidence remains preserved.

## Actual independent local execution

After inspection, copied the package into `/tmp/msa-quality-review03-1qowbe7c/candidate` and ran:

`/usr/bin/python3 -B -m unittest -v test_candidate test_timeout`

PYTHONOPTIMIZE was unset; PYTHONDONTWRITEBYTECODE=1. **All 14 tests passed, exit 0.** The actual inert timeout returned rc124 after 11.052 seconds; descendant PID339223, PGID/SID339222, was Z at return, not live. Rejected rerun preserved evidence. The fixture adopted/reaped its own orphan.

Independently authored `/tmp/msa-quality-review03-1qowbe7c/probe.py` and executed it with `/usr/bin/python3 -B`: **all five additional probes passed, exit 0**:

1. Actual inert zero-exit child emitting a timestamp-prefixed `Error (suppressible):` rejects before generation.
2. Original saved FIFO values reject before generation.
3. Otherwise accepted saved parameters with changed first-save bytes reject before generation.
4. A synthetic two-stage completion with both wrapper FIFO changes reaches the actual generated checker, retains XML drift, and leaves generated acceptance and every readiness flag false.
5. Real package verification accepts an exact local fixture, rejects readiness=true, and rejects changed Tcl bytes without creating a run.

Fixture preflight/dependency checks were explicitly mocked; child executables were inert local Python only. The completion fixture copied captured baseline artifacts into temporary scratch: it is **not generation or a vendor result**. No actual host identity, Tcl/vendor integration, remote inventory, calibration, timing or functionality was tested.

Retained evidence SHA256:

- `tests.log`: `4709c6fc6f8a853b571c567870204e72341afa2fb243a4fd4341bab05e0d0600`.
- `probe.py`: `55f86f48869d1f3006e3fb94eb8277d552df3cb838d32d14c5999ed599011d69`.
- `probe.log`: `12e30a458d9d092381f17aa204167a8205ff304025bf7a78c8ac01678994e72f`.

All reside under `/tmp/msa-quality-review03-1qowbe7c/`, along with inert fixture records.

## Preservation and next consumption

Independently verified all 35 manifest entries and exact coverage of all 36 package files including the manifest. Rehashed all 181 preexisting qualification-tree files after tests/probes: unchanged. Candidate03 has no supplied consumed review or run. Only this report was created in the qualification tree, outside the manifest; test/probe artifacts are under the fresh local temporary root.

**Next:** parent consumes specification and this quality acceptance against the exact manifest above; fresh remote 36-file package transfer and exact readback (review consumption remains a separate explicit record, not a manifest edit); live preflight verifying current SOURCE/PIM/dependencies/tools, owned session and absent WORK/RUN; then once-only bounded generation. Preserve every failed attempt and review actual native/drift evidence before proceeding further. Standing user scope needs no invented incremental approval question.

Candidate03 is still local-only at this review. No staging, remote call, authorization consumption, SOURCE/gate edit, vendor generation, compile, Query04, DDR simulation, hardware action, installation, permission change or commit occurred. Approval does not establish execution readiness, native compatibility, generated-interface acceptance, calibration association, functionality or timing.

# Work24 PR export — final execution scope

## Selected operation

One CMake-native export of the accepted Work24 copy using Quartus Pro 26.1.1 Build 130 and retained PIM `3c21189e728009d4c492fa2be54c0ab1008b06dc`. No new FIM fit, hardware access, conversion, programming, reset or reboot. The export produces a base-compatible PR/PIM template, not a compiled persona or DDR acceptance.

- Original: `/home/uwb_student00/ahls/new_BSP/work_ia840f_fim_24`.
- Copy: `/home/uwb_student00/ahls/new_BSP/work_fim24_pr_platform01/base01`.
- Final preparation: `.../work_fim24_pr_platform01/prepared15`.
- Single-use operation: `.../work_fim24_pr_platform01/export01`.
- Absent release target: `.../work_fim24_pr_platform01/release01`; no vendor target `-f`.
- Runner: `prepared15/candidate15/run-export15.py`, SHA256 `a459526f387618395ba479f0333e837cb11b1a7e60fabd41599aa22f093e9bf6`.
- Expected interface: `fc603c44-5c8f-5e94-bcbe-a5780030947c`.

## Bound preparation and review limits

The independently accepted prepared10 SOURCE package is preserved under [source-freeze11](source-freeze11.json), [SPEC12](review-spec12.md) and [parent consumption16](spec-consumed16.json). The final design-copy amendment is exactly one `NUM_PARALLEL_PROCESSORS 36` statement in the PR QSF; the other 4,284 entries are unchanged. Actual remote preparation/readback, original Work24/prepared10 preservation and missing-admission rejection are recorded in [resource16](resource16-readback/resource-preparation16.json). [Final freeze17](final-package-freeze17.json) binds 24 successor-package members. The resource-only source supplement and execution QUALITY must be consumed before issuance; earlier reviews do not grant launch authority.

The runner was exercised with ten real-inert-child cases, including success/nonzero, delayed gate diagnostics, post-spawn/postflight exceptions, finite and TERM-resistant descendants, log overflow, wrong version and unchanged evidence on rejected replay. Admission/CMake/tmux and artifact data were synthetic in those tests, not vendor integration. The actual remote runner separately rejected an absent admitted manifest before creating its operation or target. [Tests](export-runner-inert15.json), [actual rejection](resource16-readback/entry-rejection16.json).

## Native boundaries

- All 36 recorded available CPUs and 64 GiB per-process address-space limit, with fresh affinity, memory, disk and competing-job checks. This is not aggregate OS-enforced containment or a guarantee that Quartus creates 36 workers.
- Configure deadline 120 s; version deadline 60 s; export deadline 600 s. Logs are bounded at 32 MiB. Owned process groups drain within the command deadline and are terminated on expiry/error; the leader stays unreaped until signaling is finished.
- Preserve current inherited license variables without copying or printing their values. Use explicit 26.1.1 paths, owned HOME/TMPDIR and the selected PIM.
- Direct targets: CMake configure, `version`, then `export`. The export target invokes the prepared vendor `generate_pr_release.sh` with `-t <release01> ia840f <base01>`. Six exact native callback contexts are retained; actual 26.1.1 IPC serialization remains an experimental outcome, not a preclaimed result.
- The release-only Python/Tcl callback binds its self hash, exact executable/cwd/argv, live runner ancestry and critical source hashes. Readiness for ordinary build remains false. Original gates remain intact. Reject `IA840F_GATE_REJECTED`, Critical Warning 125091, Error/Fatal diagnostics, nonzero status, unfinished descendants and unexpected preservation failures.

## Issuance and outcome

After final source/QUALITY consumption, construct the admitted record from the exact captured draft15, explicitly bind final review/consumption bytes, set execution acceptance true and resolve the pending-review field. Stage that record exclusively as `prepared15/export-inputs.admitted.json`, read back its exact digest, and pass that digest to the already bound runner through owned tmux. Do not reuse an old authority or a consumed operation. Fresh preflight still decides admission.

Retain configure/CMake/effective/outer statuses separately. A zero direct CMake vendor target supports propagated child-zero status; nonzero CMake does not reveal each vendor command's original code. Inspect actual gate events, logs, PR A&E/DRC reports, exported PIM/configuration and source closure. Match the released interface/static QDB/SOF/MSF/PMSF to the accepted Work24 artifacts and preserve originals. Execution cleanliness is not final export acceptance; an independent actual-result review precedes downstream persona qualification.

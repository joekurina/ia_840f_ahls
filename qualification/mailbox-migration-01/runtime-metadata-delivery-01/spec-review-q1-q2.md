# Independent specification review — Q1/Q2 correction

## Verdict: PASS (local correction and preservation only)

The narrow Q1/Q2 requirements in the original `quality-review.md:11–33` are satisfied by source inspection and source-bound retained regression evidence. No blocking specification gap was found in these corrections. This is **not** production approval, remote execution permission, retry authority, or a replacement for independent quality review. Authorization/readiness/vendor flags remain false.

## Review method and scope

Read the original REQUEST_CHANGES and specification report, README, corrected delivery/fixture sources, original and new tests, revision-check runner, integrity record, manifests, archive bindings, and retained RED/GREEN records. Independently recomputed lengths/SHA-256 values, compared old/new source text, parsed Python ASTs, and inspected recorded test output as data. No reviewed module was imported, compiled for execution, or executed. No tests, validator, fixture, generated command, tmux, SSH, workstation, vendor tool, or consumed u03 operation was run. No source, manifest, sibling, permission, flag, or commit was changed. Only this report was created, intentionally outside the manifest.

## Q1 — capture errors and explicit completion: PASS

- `fixture.py:21–47` encloses selector creation/registration, file acquisition, selection/read/write/flush, file context cleanup, and selector cleanup in exception reporting. The nested body handler records the original traceback before file close can raise another exception; the outer handler and selector-close handler retain subsequent failures. `raw.extend` precedes persistence (`:31–36`), preserving already-read bytes even when the sink fails. Short writes also fail closed.
- Clean completion is set only after cleanup and only with no errors (`:48`). `require_clean_capture` rejects a live worker, any recorded error, or missing explicit clean state (`:51–54`). Main sets stop, joins, applies that gate, and re-decodes final bytes (`:119–122`) before writing streams or PASS (`:135–141`). An earlier decodable R-containing snapshot cannot override a worker error.
- `test_review_regressions.py:30–75` supplies an entire valid O/E/S/R transcript on the first read and injects read/write/flush failures on the second operation. It explicitly confirms the retained prefix still decodes, then requires the error detail, an unset clean flag, and `Incomplete` from the completion gate. File-close and selector-close failures are also covered. Setup failures and explicit clean/dead/live combinations are covered at `:77–101`.
- These are mocked worker/gate regressions, not a live main/fixture integration rerun. That limitation is disclosed and consistent with the authorized correction scope. The source call order supplies the static connection between the tested gate and PASS publication.

## Q2 — narrow reserved unterminated prefix: PASS

- `delivery.py:105–111` defines the reserved fragment narrowly: line-start `D1`, `D1 `, a matching prefix of this acquisition's token/marker, or continuation beginning with the complete marker. A lone `D` and nonmatching D1 text are not reserved.
- `delivery.py:169–170` applies this rule to the final LF-delimited pane fragment after framing has started. It therefore rejects the missing-token/separator counterexample even when the containing outer `%output` record is complete. The existing full-marker truncation and misalignment checks remain intact (`:144–149`). The source diff adds only the helper and final guard; it does not change generator, protocol, stream/status, or permission semantics.
- `test_review_regressions.py:104–112` appends every marker prefix from `D1` through the full marker to an otherwise completed transcript and explicitly confirms outer LF completion before requiring `Incomplete`. `:114–119` retains ordinary prompts, lone D, nonmatching D1 text, and pre-frame printf echo. The unchanged original prompt-echo test remains present (`test_delivery.py:57–59`).

## Independent integrity and provenance checks

All following counts were computed from the local data, not copied from the implementer claim:

| Inventory | Entries checked | Length/hash mismatches |
|---|---:|---:|
| Original archive bindings | 90 | 0 |
| Archived original JSON artifact manifest | 86 | 0 |
| Archived original SHA256SUMS | 87 unique paths | 0 |
| Corrected JSON artifact manifest | 190 | 0 |
| Corrected SHA256SUMS | 191 unique paths | 0 |

Before this report was created, the only files outside the current JSON artifact inventory were `manifest.json` and `SHA256SUMS`; the latter binds the former. The original-name comparison finds changes only to `README.md`, `delivery.py`, `fixture.py`, `manifest.json`, and `SHA256SUMS`. Excluding intentional manifest updates, this agrees with `q1-q2-integrity.json:4–8`. Original reviews, original tests, proposal, validation, original red/green output, cleanup record, and all historical fixture evidence remain byte-identical to the bound archive. The archive itself contains the 90 originals plus its new binding inventory.

`README.md:17–23` and `manifest.json:9–11` explicitly associate historical fixture/validation evidence and old review verdicts with archived sources, not corrected sources. The corrected implementation is verified by the new mocked test record, not a reassigned historical live fixture result. Binding agreement establishes internal consistency, not independent timestamped proof of history.

For all three new phases, independently verified each of the five source length/hash bindings and the retained unittest output hash:

- **Initial RED:** old delivery/fixture/original tests bind to the archive; initial regression/runner versions bind to their retained copies under `q1-q2-red/`. Exit 1; recorded six methods, 38 failures and seven errors. This is not valid Q1 reproduction: its AST source read occurs inside the Path.open mock, producing the disclosed harness error. The preserved source diff shows the correction moves that read ahead of mocks (`test_review_regressions.py:12–13,20`). README `:44–46` explicitly disclaims the attempt as Q1 evidence.
- **Confirmed RED:** old implementation binds to the archive, while fixed regression/runner hashes match the current files. Exit 1; recorded six methods, 43 failures and two errors. `q1-q2-red-confirmed/unittest.txt:79–104` records the actual disappearing read/write/flush exceptions after a decodable prefix; `:106–149` records cleanup/setup exceptions. The two errors are the missing new gate API (`:52–68`), not a substitute for the concrete defect failures. Reserved-prefix cases fail because `Incomplete` is not raised.
- **GREEN:** all five source bindings match current bytes, including corrected delivery/fixture. `q1-q2-green/unittest.txt:1–19` records 14 named successes, `Ran 14 tests in 2.933s`, and `OK`; checks.json records exit 0. AST enumeration independently finds eight original test methods and six added methods. This review inspected and hash-verified those results; it did not rerun them.

Python 3.9 grammar AST parsing succeeds for the six files enumerated by `q1-q2-integrity.json`. This is not Python 3.9 runtime certification. All 74 occurrences of authorization/readiness/vendor/remote-execution/independent-adapter-approval keys found across retained JSON records are false; corrected source return/result flags are also explicitly false (`delivery.py:172–173`, `fixture.py:136–140`).

## Boundaries remain unchanged

Production helper-startup gating, failure restoration, fresh identity/exclusive ownership, acquisition/controller error integration, and receiver integration remain unimplemented or unverified (`delivery.py:64–81`; README `:191–196,209–255`; original spec review `:40–47`). This PASS does not resolve or waive them. The existing local cleanup inference and PASS-before-final-cleanup limitation remain disclosed by the original quality review (`quality-review.md:49`); consumers must retain process outcome and cleanup evidence. No remote execution, retry, build, or vendor action is approved.

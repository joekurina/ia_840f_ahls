# Independent static quality re-review — Q1/Q2

## Verdict: APPROVED

Approved only for the narrow local Q1/Q2 correctness corrections. No blocking regression was found in the corrected capture-worker failure handling or reserved trailing-prefix rule. This is not production readiness, adapter deployment authorization, permission to rerun a fixture, or approval to execute remote diagnostics/build/vendor work. All runtime permission/readiness/vendor flags remain false.

## Method and evidence boundary

Read the original quality findings, specification re-review, corrected sources, both test files, README, revision runner, integrity record, and source-bound regression records. Independently compared archived/current delivery and fixture source text, parsed test definitions as AST data, and recomputed every source and output hash in the initial RED, confirmed RED, and GREEN checks records; all matched their appropriate archived, retained-harness, or current files. No reviewed module was imported or executed; no tests, validator, fixture, generated command, tmux, SSH, workstation, vendor command, permissions operation, or commit was run. Review-tool Python was used only for local text, AST, JSON, diff, and hash analysis.

The specification review's broader inventory counts (90 archive bindings, 190 current artifact entries, 191 current SHA entries; `spec-review-q1-q2.md:24–46`) are attributed to that independent review, not presented as this review's recomputation. Historical fixture evidence remains bound to prior sources (`README.md:17–23`). No live fixture result verifies the corrected source.

## Q1 — closed, with the publication path independently traced

- **Setup and cleanup:** selector construction/registration and file acquisition sit inside the outer handler (`fixture.py:21–24,42–47`). Selector-close failures are separately appended. The inner handler records a body traceback before leaving the file context (`:25–43`), so a subsequent file-close failure cannot erase the original read/write/flush failure. Both can remain in `errors`; selector close can add another. Catching `BaseException` is deliberate containment at this worker boundary, not suppression into success.
- **Failure after a complete prefix:** bytes are added to `raw` before write/flush (`:31–38`). Thus a sink error may leave memory ahead of the disk artifact, but the error channel prevents those bytes or any earlier decodable prefix from establishing success. Short writes explicitly raise. EOF, deadline, and cap errors also enter the same failure path.
- **No dead-thread shortcut:** clean state is cleared initially and set only after file and selector cleanup, with no errors (`:20,48`). Main stops and joins the worker, requires dead/error-free/explicitly-clean state, and decodes final retained bytes again (`:119–122`). PASS publication is later (`:135–141`). A candidate R snapshot observed while persistence is unfinished cannot bypass this gate; a worker still alive after the bounded join also fails. A worker dying before setting clean fails even with an empty error list.
- **Regression relevance:** `test_review_regressions.py:30–75` returns a complete O/E/S/R transcript on the first read and injects the second read/write/flush failure. It explicitly proves the retained data still decodes before requiring recorded error detail, no clean flag, and gate rejection. This targets the original false-PASS condition rather than merely a pre-completion timeout. Close and selector-close variants exercise errors after a valid prefix too. Setup errors and clean/dead/live state combinations are covered at `:77–101`.

These tests invoke the real extracted worker synchronously with mocked I/O and a fake thread-state object; they do not exercise real thread scheduling or fixture.main. Static ordering of the actual main call sites supplies the connection to publication. This is sufficient for the scoped correction, not live acquisition certification.

## Q2 — closed without broad prompt rejection

The new helper (`delivery.py:105–111`) recognizes exactly a final fragment that is either a matching prefix of this acquisition's marker, beginning at `D1`, or begins with the complete marker. The final guard applies after framing has started (`:169–170`). Consequently, completed O/E/S/R plus an outer-LF-terminated `%output` carrying inner `D1`, `D1 `, a partial matching token, or the whole token without its separator now raises `Incomplete`. The full marker and unfinished frame continuation remain rejected by the existing truncation check (`:144`).

This reasoning depends on pane bytes, not outer control-record boundaries: output is concatenated before splitting into LF-delimited fragments (`:122,142–146`), so splitting a reserved suffix between control-output records does not conceal it. An empty final fragment after a proper inner newline is not reserved. Lone `D`, nonmatching `D1-tools$ ` / `D1 other$ `, and a marker prefix embedded inside an ordinary prompt are intentionally not reserved. Existing complete-marker misalignment rejection remains unchanged (`:147–149`). Pre-frame printf echo remains ignored rather than becoming framing state.

`test_review_regressions.py:105–112` covers every marker prefix from `D1` through the full separator and explicitly asserts the outer newline survives. Positive prompt/pre-frame echo cases are at `:114–119`; the original echo and fragmentation tests remain at `test_delivery.py:57–67`. The source diff changes only the helper and final guard, not generator bytes, stream/status validation, or flags. The rule intentionally does not claim to reject every vaguely D1-looking line: newline-terminated nonmarkers and mismatching tokens remain outside this narrowly documented unterminated-prefix contract (`README.md:34–38`).

## Coverage notes — nonblocking

No mandatory source fix remains. Useful future inert regression additions, only if separately authorized:

1. Inject a body write/flush error **and** file-close **and** selector-close errors in one call, asserting all error details survive. Current tests choose one failure at a time (`test_review_regressions.py:38,50–55`); the nested handlers are correct by inspection, but simultaneous-error preservation is not directly tested.
2. Cover selector-constructor failure and a short sink write. Current setup tests cover open/register/select, not constructor failure, and the mock write always returns the full length (`:45–47,77–83`). Both omitted branches are explicitly handled in source.
3. Split a post-completion partial marker over several complete outer records. Existing prefix tests use one record per suffix; original fragmentation coverage exercises valid complete frames. Concatenation makes the expected failure clear statically.

These are coverage-strengthening suggestions, not evidence of a remaining false PASS or grounds to widen the authorized work.

## Recorded outcomes and retained limitations

`q1-q2-green/unittest.txt:1–19` records 14 passing methods and OK; GREEN checks records exit 0 and binds the current sources/output. Initial RED is retained but is not valid Q1 reproduction because Path.open mocking intercepted the worker source read (`README.md:44–46`; fixed source read at `test_review_regressions.py:12–20`). Confirmed RED uses the fixed harness against archived implementation and records disappearing post-prefix read/write/flush errors (`q1-q2-red-confirmed/unittest.txt:79–104`), independently of missing-new-gate API errors. None of these results was rerun here.

The existing PASS-before-final-cleanup and failed-list-sessions-as-absence limitations remain (`fixture.py:141–168`; original `quality-review.md:49`); result.json alone is not overall fixture/process/cleanup success. The acquisition/shutdown-tail split is also unchanged. Production transactional helper startup, failure restoration, fresh identity/exclusive ownership, acquisition/controller error integration, and receiver integration remain deferred and unauthorized (`delivery.py:64–81`; `README.md:191–196,209–255`). Local approval does not resolve these boundaries or historical u03 cause.

Only this new report, `quality-review-q1-q2.md`, was created, intentionally outside the manifest. No source, evidence, manifest, immutable sibling package, consumed u03, or permission/readiness/vendor flag was changed.

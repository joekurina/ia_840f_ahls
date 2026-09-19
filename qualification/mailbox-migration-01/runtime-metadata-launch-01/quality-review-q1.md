# Independent static quality re-review — Q1

**Verdict: APPROVED — Q1 is resolved; no remaining delta-focused quality defect identified.**

This approves the localized cleanup correction and its evidence bindings, not execution. Read the original `quality-review.md` and specification PASS in `spec-review-q1.md`; independently inspected the revised sources, exact diff, regression, and retained evidence rather than relying on that PASS.

## Q1 disposition

- **Primary error retained:** `launcher.py:195–196` appends the initiating failure. The new `try`/`except OSError` at `199–203` appends a distinct `gate_close` error instead of replacing the first error or escaping the cleanup block. The structured result remains INCOMPLETE with false authorization/readiness/vendor flags (`246–263`); nonempty errors prevent completion.
- **Remaining cleanup continues:** the caught gate-close error falls through to exact-owned-pidfd error signaling (`204–211`), direct-child reaping (`214–218`), bounded nonblocking post-reap draining (`219–240`), and remaining owned descriptor closes (`241–245`). Acquisition refusal has no child pidfd and introduces no signal fallback; probe refusal retains its acquired handle for cleanup. These are control-flow guarantees for this OSError path, not a new hard deadline for blocked kernel calls or recovery from parent death.
- **No close retry:** `close()` removes the descriptor from `fds` before `os.close()` (`106–109`). Therefore the failed gate writer is not retried by the remaining-close loop. This preserves the existing Linux descriptor ownership discipline.
- **Exact signaling unchanged:** independently established byte-for-byte that the sole launcher change is this exception guard. The send helper remains pidfd-only (`111–115`); acquisition/probe-before-release (`144–150`), deadline signaling (`155–164`), and error cleanup (`204–211`) are unchanged. Numeric `waitpid(pid, 0)` is direct-child reaping, not a signal fallback.

## Regression sufficiency

`test_launcher.py:146–204` is sufficient for this localized defect. One new test exercises acquisition refusal and probe refusal separately with fake child/descriptors and mocked I/O. It checks both errors in order, INCOMPLETE and false flags, no gate write, no numeric kill, the exact child wait, every owned close, one failed gate-close attempt only, remaining closes after wait, reads of both output descriptors, and the expected owned-pidfd probe/KILL sequence only in the probe case (`184–204`).

The drain assertions use mocked EOF, not buffered-output preservation under an actual failing close; that is an appropriate narrow continuation regression, not a claim of new kernel-level coverage. Static inspection confirms drain placement after successful reap and before final closes. The original tests and unchanged drain implementation supply the surrounding coverage; no unrelated redesign or additional blocking test demand is warranted.

The retained before-fix log records both subcases escaping at the former unguarded close (`q1-regression-before-fix.txt:4–5,16–32,43–59`). The after-fix log reports the regression passing with exit 0 (`q1-regression-after-fix.txt:3–10`). `q1-test-results.txt:3–31` reports 22 passing inert local tests and exit 0: the original 21 plus this one regression. These are retained execution reports, **not tests rerun by this reviewer**.

## Independently verified static bindings

Only standard-library file reads, SHA-256 calculations, AST/literal parsing, strict base64 decoding as data, and textual comparisons were used.

| Check | Result |
| --- | --- |
| Regenerated four-file unified diff versus `q1-exact-changes.diff` | Byte-identical |
| Sole launcher delta | Exactly the requested gate-close OSError guard |
| Current `SHA256SUMS` | All 25 entries match |
| Archived original `SHA256SUMS` | All 7 entries match |
| Archived `ARCHIVE-SHA256SUMS` | All 10 entries match |
| Sibling diagnostic `SHA256SUMS` | All 5 entries match |
| Original reviews/results retained at top level | Byte-identical to archive |
| `validate_local.py` | Unchanged from archive |
| Both revisions' four Python files and embedded collector | Parse under Python 3.9 grammar |
| Both transport payloads | Strictly decode to their exact launcher bytes; length/hash agree |
| Both embedded collectors | Exact sibling collector bytes; length/hash agree |
| AST test method identifiers versus retained named successes | Exact matches: original 21, revised 22 |
| Four current source length/hash records in `q1-validation.txt` | Match current files |

Current launcher: **30087 bytes**, SHA-256 `2670ff15528edcbd134b647624d335f6eca79263fa547b9e7515d7c3444ce3c2`.

Current transport: **41045 bytes**, SHA-256 `29e2864c3e4c560a737bffdf9b65db41dd5a89736e29d40718acbdbf5cdebd60`.

Unchanged embedded/sibling collector: **13851 bytes**, SHA-256 `6a524fbb0793822b55ef41855ea1f97f5d1e7210c0783cee53a5176e810ff897`.

Transport binding checks still precede compilation/execution (`transport.py:12–28`); only payload/declared length/hash changed. Archive consistency is checked against the retained original manifest and original review bindings, not asserted solely from the newer archive manifest. AST compatibility and retained local results do not establish target Python runtime behavior or receiver integration.

## Scope and outstanding execution prerequisites

Fresh independent live attestation, reviewed receiver/delivery integration, and a separate execution decision remain outstanding; they are not automatically quality defects in this Q1 delta. `authorization`, `ready_for_build`, and `vendor_run` remain false. Consumed u03 remains untouched and INCONCLUSIVE. This approval authorizes no launch, vendor action, retry, or mutation of the diagnostic sibling or consumed artifacts.

Created only `quality-review-q1.md`. No reviewed module was imported or executed; no tests, validator, launcher, transport, collector, remote command, vendor command, or commit was run. No source, manifest, archive, retained result, sibling diagnostic artifact, or consumed u03 artifact was modified.

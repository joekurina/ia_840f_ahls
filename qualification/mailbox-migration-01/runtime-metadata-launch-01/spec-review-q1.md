# Independent static specification re-review — Q1

**Verdict: PASS — Q1 cleanup correction and refreshed bindings satisfy the requested localized correction.** No blocking specification gap identified in this delta. This is not the subsequent quality re-review, execution authorization, or deployment acceptance. Independent live account/session/interpreter attestation and approved binary-exact delivery/captured-output receiver integration remain execution prerequisites. `authorization`, `ready_for_build`, and `vendor_run` remain false; consumed u03 remains outside this change and INCONCLUSIVE.

## Delta findings

- **Minimal implementation change:** independently regenerated the full four-file unified diff from `revision-01-pre-q1-fix/` and compared it byte-for-byte with `q1-exact-changes.diff`; exact match. Independently checked that the entire launcher differs solely by the `try`/`except OSError` around the cleanup gate close (`launcher.py:197–203`). Transport changes are the refreshed payload/length/hash, the test change is one targeted regression, and the README addition identifies the revision and retained evidence. `validate_local.py` is unchanged.
- **Initiating versus cleanup failure:** the existing outer exception handler first appends the initiating failure (`launcher.py:195–196`). The new handler appends a distinct `gate_close:<type>:<message>` without overwriting it or escaping the remaining cleanup. The nonempty error list precludes completion (`246–263`), preserving the structured INCOMPLETE result and false flags.
- **Owned cleanup continues:** following the caught gate-close error, the existing owned-pidfd signal cleanup, direct-child `waitpid(pid, 0)`, bounded nonblocking post-reap draining, and remaining owned-descriptor closes remain reachable (`204–245`). The helper removes a descriptor from the ownership set before invoking `os.close` (`106–109`), so the failed gate descriptor is not blindly retried. Acquisition refusal has no child pidfd and no signal fallback; the unreleased child remains subject to the existing gate EOF/timeout refusal. Probe refusal retains the acquired pidfd for exact-child cleanup. These are continuation guarantees for the specified close-error path, not new guarantees against blocked kernel calls or parent death.
- **Exact signaling unchanged:** the launcher byte comparison establishes that preflight, gating, signal delivery, direct-child reaping, 65/70-second decisions, fixed identity/source constraints, I/O caps, and completion rules are otherwise untouched. Nonzero signaling remains through the owned pidfd; no numeric-PID/group/name fallback was introduced.
- **Regression is appropriately narrow:** `test_launcher.py:146–204` mocks acquisition and probe refusal separately, followed by gate-close `OSError`, using fake descriptors and a fake child. It asserts both errors in order, no gate write, no numeric kill, INCOMPLETE/false flags, the exact direct-child wait, all remaining closes, no retry of the failed close, post-reap output reads, and the expected owned-pidfd signal sequence only in the probe case. The retained before-fix result records both subcases failing at the former unguarded close; the after-fix result records success. These logs were read, not rerun.

## Independent static verification

Only local file reads, standard-library AST/literal parsing, strict base64 decoding as data, SHA-256 calculations, and textual comparisons were performed. All static assertions passed:

| Verification | Result |
| --- | --- |
| Current `SHA256SUMS` | All 25 entries match |
| Archived original `SHA256SUMS` | All 7 entries match |
| `revision-01-pre-q1-fix/ARCHIVE-SHA256SUMS` | All 10 archived original files match |
| Sibling diagnostic `SHA256SUMS` | All 5 entries match |
| Current versus archived original reviews/results | `spec-review.md`, `quality-review.md`, `test-results.txt`, and `validation.txt` are byte-identical |
| Python 3.9 grammar | All four Python files in both revisions and the embedded collector parse |
| Transport payload | Strictly decoded bytes equal each revision's launcher, with declared length/hash matching |
| Embedded collector | Both revisions decode to the sibling collector exactly, with fixed length/hash matching |
| Current validation evidence | All four recorded source lengths/hashes match current files |
| Current test names | Exactly 22 AST-enumerated test methods match exactly 22 named successful entries in `q1-test-results.txt`, including method identifiers; one added Q1 test |

| Current bound artifact | Bytes | SHA-256 |
| --- | ---: | --- |
| Launcher / transport payload | 30087 | `2670ff15528edcbd134b647624d335f6eca79263fa547b9e7515d7c3444ce3c2` |
| Transport envelope | 41045 | `29e2864c3e4c560a737bffdf9b65db41dd5a89736e29d40718acbdbf5cdebd60` |
| Sibling / embedded collector | 13851 | `6a524fbb0793822b55ef41855ea1f97f5d1e7210c0783cee53a5176e810ff897` |

The original launcher and envelope hashes in the archived manifests agree with the original reviews. Archive integrity and preservation are supported by those bindings and the exact comparisons, not by treating a newly written manifest alone as historical proof. `q1-test-results.txt` reports 22 passing tests and exit 0; `q1-validation.txt` reports exit 0. Neither was executed by this reviewer. AST compatibility is not target Python 3.9 runtime validation, and retained local results establish neither live attestation nor receiver correctness.

## Handoff and scope

The Q1 revision may proceed to the separate independent quality re-review. The original reviews remain historical evidence, not approval of the revised bytes. No new unrelated design requirement is introduced. Fresh live attestation, accepted startup/path-race limitations, separately reviewed delivery/receiver integration, and separate exact execution authorization remain required; this PASS supplies none of them.

Created only `spec-review-q1.md`. No reviewed module, test, validator, launcher, collector, or transport was imported or executed. No remote action, tmux query, vendor command, or commit occurred. No source, manifest, archive, retained result, sibling diagnostic artifact, or consumed u03 artifact was modified.

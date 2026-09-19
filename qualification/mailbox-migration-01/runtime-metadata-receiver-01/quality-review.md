# Independent static quality review

## Verdict

**APPROVED for the scoped local receiver code.** No blocking correctness defect was identified under the documented precondition of finished, independently bounded, immutable local capture files. This approval grants no execution authority and is not delivery approval, runtime certification, or historical-cause evidence.

Reviewed receiver SHA-256: `bc5d4cc16ecb38568868e70692ce261a0c890eb345fa6c39dea51ce64662a389` (12097 bytes), independently verified exactly.

## Scope and verification

Read receiver, tests, README, manifest, retained red/final results, validation record, specification review, immutable launcher README acceptance requirements (`178-196`), and collector source for failure-shape comparison. Verification used local file reads, SHA-256 and AST parsing only. No reviewed module import, test execution, collector/launcher/transport execution, remote access, vendor command, commit, or consumed-u03 operation occurred.

All six manifest entries match. Receiver and test source parse with Python 3.9 grammar; this does not establish Python 3.9 runtime behavior. The twelve AST-discovered test methods match the twelve named passing entries in retained `test-results.txt`; those are synthetic recorded passes, not independently rerun tests or runtime certification. The red record is the expected initial missing-module failure.

Independent sibling hashes and lengths match the reviewed bindings:

- Launcher: 30087 bytes, `2670ff15528edcbd134b647624d335f6eca79263fa547b9e7515d7c3444ce3c2`.
- Collector: 13851 bytes, `6a524fbb0793822b55ef41855ea1f97f5d1e7210c0783cee53a5176e810ff897`.
- Transport: 41045 bytes, `29e2864c3e4c560a737bffdf9b65db41dd5a89736e29d40718acbdbf5cdebd60`.

## Correctness assessment

- **Parsing, types and integrity — receiver.py:33-69,98-150,158-194.** ASCII decoding and a single JSON parse reject malformed/trailing documents, duplicate keys, nonfinite constants and float overflow. Recursion errors from parsing are rejected. Exact integer/boolean checks avoid bool-as-int acceptance for statuses, counts, flags and bindings. Both streams are independently checked for strict canonical base64, decoded size, exact length and SHA-256. Expected identity fields are type-checked. This is validation of acceptance fields, not exhaustive validation of auxiliary metadata or authentication of a sender.
- **Completion versus filesystem observation — receiver.py:72-83,177-200.** COMPLETED requires no issues, explicit captured integer exit zero, coherent outer control fields and completed collector terminal, empty close errors, guard and roots. The error observation additionally requires intact structural/integrity checks, exit 1, wait status 256, INCOMPLETE outer terminal, successful reap, no timeout, no launcher/transport errors and the recognized OSError shape. It never upgrades the overall INCOMPLETE classification. Collector failure and close-error data are retained without path normalization. Stop/refusal/deadline reports do not meet that recognizer. The recognized shape matches collector.py:74-81; it is not an independent proof that reported operation/path/errno occurred.
- **Preservation — receiver.py:124-150,204-243.** Raw capture is copied before parsing; outer stderr and collector stdout/stderr remain separate binary files. Decoded streams are saved before canonicality/length/hash rejection, so those failures do not discard decodable evidence. Undecodable or oversized streams remain represented by the raw envelope rather than being silently truncated. Missing/nonzero status still permits preservation. A failed local write returns failure and can leave partial evidence, as README:18-20 explicitly warns; such a directory must not be treated as a completed acquisition.
- **Finite local resources — receiver.py:101-103,130-134,204-215,233-239; README:31-35.** Parsing is capped at 3 MiB and each decoded stream at 1 MiB. Preservation uses bounded-memory chunks but deliberately follows the entire supplied capture size, including oversized rejected captures. There is no enforced disk quota, regular-file check or ingestion deadline. This is consistent with the finished finite-file caller contract, not a safe API for arbitrary live FIFO/device/growing-file inputs. No bounded-time or unbounded-capture-service claim is justified.
- **Interpretation — receiver.py:92-95,195-200; README:44,51,59-61,76-108.** Reported hashes/identity are not attestation; current successful traversal and current error observation do not establish or exclude u03 history. All authorization/readiness/vendor flags remain false. The proposed tmux adapter is explicitly unimplemented and unauthorized, not a delivered channel. Remote proof is not required for this local code review, and this approval supplies none.

## Nonblocking findings and minimal follow-ups

1. **LOW — filesystem-classifier negative coverage (`test_receiver.py:156-173`; `receiver.py:72-83,197-200`).** The retained tests cover a positive failure shape and timeout/launcher-error/hash corruption, but do not directly mutate each terminal failure field or test a genuine Stop-shaped terminal against the observation label. Minimal follow-up: table-driven synthetic cases for phase, operation, exception, errno (including bool), missing nullable fields, non-null reason, a result-bearing terminal, wrong command/raw-wait status and transport errors; assert `unvalidated_or_incomplete`, while preserving exact terminal and decoded bytes. The implementation's short-circuit checks appear correct statically; this is regression coverage, not a demonstrated classifier bug.

2. **LOW — end-to-end error-preservation coverage (`test_receiver.py:112-126,205-229`; `receiver.py:229-243`).** CLI coverage verifies success, missing status, existing output and oversized raw capture; hash-failure retention is checked only through `evaluate`, and that assertion checks stream presence rather than byte equality. Minimal follow-up: a synthetic CLI case with a wrong stream hash/length and a malformed-envelope case, asserting nonzero result plus exact raw, separate outer stderr and every available decoded stream. Strengthen the direct retention assertion to byte equality. No reviewed tests were run or changed.

## Ownership and remaining boundary

Only `quality-review.md` was created by this review. Source, tests, manifest, immutable siblings and consumed-u03 evidence were not modified. This review file is intentionally outside the existing manifest. Separately authorized delivery implementation, live attestation and an explicit execution decision remain outstanding; approval here grants none of those permissions.

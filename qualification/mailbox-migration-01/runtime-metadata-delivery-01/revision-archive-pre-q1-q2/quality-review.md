# Independent static quality review

## Verdict: REQUEST_CHANGES

Scope is **LOCAL PREPARATION ONLY**: inert pinned command generation, a strict finished-capture decoder, and synthetic fixture evidence. The specification PASS is not being expanded into a production-controller requirement. Two local fail-closed defects need small corrections and focused regression coverage before quality approval.

This review used file reads only. No reviewed module was imported or executed, and no tests, fixture, validator, generated command, tmux, SSH, vendor tool, workstation operation, permission change, or commit was performed. Only this report is written, outside the immutable manifest. Source, sibling packages, consumed u01/u02/u03, and authorization/readiness/vendor flags are unchanged.

## Required changes

### Q1 — Capture-thread exceptions can disappear while the fixture reports PASS

**Priority: medium. Locations: `fixture.py:32–44,81–91,104–110`.**

The capture worker records explicit deadline, EOF, and cap failures in `errors`, but does not catch exceptions from selector setup/read, file opening, writing, flushing, or closing. Python thread exceptions do not propagate through `join()`. The main thread checks only whether the worker is still alive and whether `errors` is populated.

Consequently, if a complete stream/status/restoration prefix has already entered `raw`, a subsequent read/write/flush failure can kill the capture worker without populating `errors`. Main can decode the earlier complete prefix, observe a dead worker with no recorded error, and write `PASS_SYNTHETIC_ONLY`. A subsequent chunk already read from the client but lost on `f.write()`/`f.flush()` is also absent from both `raw` and the shutdown drain. This contradicts README `:131–133` that disk/I/O errors never constitute completed capture. Failure before any complete prefix normally times out; the defect is specifically failure after a decodable prefix exists.

**Minimal fix:** put the entire worker setup/body/cleanup under exception reporting to the shared capture-error channel, and require an explicit clean worker completion state after joining before publishing successful artifacts. Preserve the original exception in the failure record. Do not convert a worker exception into a successful prefix. No production-controller work is needed.

**Regression needed:** a local mocked capture-worker failure after a valid R-containing prefix, including a write/flush exception and a read exception, must prevent PASS and remain classified incomplete. Current `test_delivery.py:17–82` tests the generator/decoder but never this worker error path.

### Q2 — A truncated reserved frame prefix after completion is silently accepted

**Priority: medium. Locations: `delivery.py:133–140,160–162`; tests `test_delivery.py:69–79`.**

The pane-byte truncation check looks only for the entire marker `D1 <token><space>` in the final LF-delimited fragment. Every line not beginning with that complete marker is otherwise ignored unless it contains the complete marker after framing started.

A source-level counterexample is a valid completed O/E/S/R pane stream followed by the unterminated pane bytes `D1 <token>` (the final marker separator and remaining frame are missing), enclosed in an otherwise complete `%output` control record ending in LF. The outer protocol passes its LF check. The final pane fragment does not contain the full marker, so line 135 does not reject it; lines 138–140 ignore it; the previously obtained status and restoration then return success. Thus finishing the outer control record does not prove that a recognizably started reserved frame finished. This is a parser-local gap, not the deferred question of how a remote controller reports disconnects.

**Minimal fix:** after framing has started, reject an unterminated trailing fragment recognizably beginning a reserved D1 frame, including a truncated token/marker, rather than treating it as ordinary prompt text. Preserve the intentional handling of pre-frame shell echo and ordinary post-completion prompts. Define the reserved-prefix rule narrowly and explicitly so prompt tolerance is not accidentally removed.

**Regression needed:** append truncated D1/token/marker prefixes to an otherwise successful completed pane stream, wrap them in complete control-output records, and require `Incomplete`; retain successful prompt-echo and ordinary prompt cases. Existing raw suffix cuts remove the final control LF or the required R itself; they do not cover this complete-outer-record/incomplete-inner-prefix case. This counterexample was reasoned from source, not executed.

## What is sound within the bounded scope

- `proposed_command()` checks both payload length and SHA-256 before generation (`delivery.py:84–88`). The generic synthetic `command()` is deliberately not a production binding gate. Token validation and octal payload quoting keep payload bytes out of shell syntax (`:56–60`).
- Output channels remain separately sequenced and decoded. Canonical base64, per-record size, per-stream caps, EOF-before-status, helper/writer success, relay/restoration success, and duplicate/order checks are explicit (`:144–160`). Nonzero Python status is preserved rather than replaced by tmux status.
- Encoders bound single shared-pipe writes, and the relay handles partial writes (`:14–34`). The generated pipeline copies PIPESTATUS immediately (`:71–77`). These are coherent static design choices; this review does not certify runtime behavior.
- Explicit disconnect, pause, extended-output, error records, malformed acknowledgements, and unsupported control records fail closed (`:107–132`). Expected pane bytes are isolated from other-pane output. All returned permission/readiness/vendor fields are false (`:161–162`).
- Raw and decoded caps are separate. Fixture polling does not rerun the synthetic command. The retained acquisition/shutdown split is explicitly documented and must not be erased.

## Retained evidence and verification limits

Read `spec-review.md`, README, implementation, fixture, tests, `validate.py`, `validation.json`, retained green test output, the manifest header/initial entries, and fixture-08's result. The prior independent specification report records verification of all 87 SHA256SUMS entries and 86 JSON artifact entries, plus independent inspection of final raw fixtures. Those are **the specification review's checks**, not hashes recomputed in this quality review.

`green-results.txt:1–15` retains eight passing tests and exit 0. The source supports binary stream separation, nonzero status, exact-cap decoded output, escaping/fragmentation, binding refusal, and several negative cases. This review did not rerun those tests. The retained fixture-08 result records matching parent identity, EOF, nonzero Python status, restored termios, and false flags. Validation retains the final-fixture stream hashes and proposal binding. Nothing in the source findings proves those historical successful runs were corrupt; they show untested failure paths that the retained successful runs cannot establish as safe.

The existing cleanup inference (`fixture.py:128–134`) treats any failed list-sessions query as server absence. The specification review already discloses this limitation and separately cites explicit no-server evidence for the retained final fixture. Do not generalize that inference into remote cleanup authority. PASS artifacts are also written before final cleanup, so consumers must retain the companion process outcome and cleanup evidence rather than treating `result.json` alone as overall fixture success.

## Production boundary remains blocked

Asynchronous helper readiness is not transactionally gated before dispatch (`delivery.py:64–71`), and terminal restoration is normal-path only (`:73–81`). Production identity, exclusive ownership, acquisition/error propagation, and receiver integration are absent. These disclosed, explicitly deferred requirements are **not** reasons for the local change requests above and are not waived by any future local approval. No remote execution, retry, build, or vendor activity is authorized.

Only `quality-review.md` was created. Minimal implementation/test corrections require a separate authorized change; this review makes none.

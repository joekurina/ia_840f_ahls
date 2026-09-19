# Independent static specification review

## Verdict

**PASS for the scoped local receiver specification. Delivery remains an unimplemented, unauthorized proposal; this is not an end-to-end delivery PASS or execution authority.** No blocking receiver-specification failure was identified in the inspected revision. The parent must decide delivery scope separately.

Scope: local reads, SHA-256/length checks and AST parsing only. Neither reviewed modules nor tests were imported or executed. No remote, tmux, collector, launcher, vendor, build, permission-change, commit or consumed-evidence operation was performed. The only review-owned write is this file.

## Source and evidence bindings

Independent local hashing confirmed:

| Artifact | Bytes | SHA-256 |
|---|---:|---|
| `receiver.py` | 12097 | `bc5d4cc16ecb38568868e70692ce261a0c890eb345fa6c39dea51ce64662a389` |
| sibling `runtime-metadata-launch-01/launcher.py` | 30087 | `2670ff15528edcbd134b647624d335f6eca79263fa547b9e7515d7c3444ce3c2` |
| sibling `runtime-metadata-launch-01/transport.py` | 41045 | `29e2864c3e4c560a737bffdf9b65db41dd5a89736e29d40718acbdbf5cdebd60` |
| sibling `runtime-metadata-diagnostic-01/collector.py` | 13851 | `6a524fbb0793822b55ef41855ea1f97f5d1e7210c0783cee53a5176e810ff897` |

All six entries in `SHA256SUMS` matched; they covered every package file except the manifest before this review was added. This new review is intentionally not manifest-bound; the existing manifest was not changed. AST parsing of receiver and tests with Python 3.9 grammar succeeded; that is not Python 3.9 runtime certification. The local tmux manual hash also matched `validation.txt:7`, without executing tmux.

The twelve AST-discovered `test_*` methods match the twelve named entries in `test-results.txt` exactly. That file reports 12 tests passing and exit 0, explicitly on synthetic fixtures. This review did not rerun or independently reproduce those results. `red-results.txt` records the expected missing-module failure, not evidence that the current suite fails. Manifest consistency binds the present artifacts, not their historical execution provenance.

## Receiver findings

- **Raw preservation and separation:** `receiver.py:204-215,226-243` copies raw input verbatim into a new directory using binary I/O and exclusive creation, preserves optional outer stderr separately, and writes decoded collector stdout/stderr separately. There is no newline conversion, path resolution, or raw JSON rewriting. Decodable streams are retained before subsequent canonical-base64/length/hash failures (`132-143`). Oversized streams are rejected, not silently shortened; their encoded evidence remains in the raw file.
- **Size semantics:** `101-103,130-134,233-239` enforce at most 3 MiB parsed envelope and at most 1 MiB per decoded stream. `204-215` preserves an already captured oversized file in full with bounded-memory chunks, then rejects it. This is deliberately not a 3 MiB disk-preservation cap or a network-capture implementation. README `31-35` correctly requires independently completed/bounded capture and immutable inputs. Preservation I/O failures return failure and may leave a partial directory, as documented; that is not completed evidence.
- **Strict parsing and status:** `33-59` rejects duplicate keys, nonfinite values, non-object JSON and non-ASCII input; JSON parsing consumes one document with only JSON whitespace around it. `98-100` requires an actual integer zero outer-command status for acceptance; missing status cannot be inferred from the envelope. `112-143` enforces false flags, exact pinned source bindings, canonical strict base64 and exact stream lengths/hashes. Integer checks exclude booleans.
- **Completion:** `158-196` checks collector flags, counts, elapsed, selection-list type, close-error-list type and expected identity, plus exact completed terminal, passed guard and permitted nonempty roots. The outer terminal/reap/raw-wait/timeout/error fields are type-checked against completed/true/0/false/empty-list. These match the actual envelope fields emitted by launcher `246-263,300-302`, the transport binding at `transport.py:27-28`, and the collector report/completion shape at `collector.py:52-54,169,210,280-302`. Reported identity and source hashes are not live attestation or sender authentication. This is acceptance-field validation, not a claim to validate every auxiliary collector metadata field.
- **Current filesystem failure:** `72-83,197-200` requires the actual operation/path/exception/errno/failure shape together with coherent outer exit 1, raw wait 256, INCOMPLETE terminal, reap/no-timeout/no-launcher-errors, valid bindings and no transport errors. This matches collector `74-81` and the launcher's nonzero path. `156-157` retains terminal and close-error values without normalizing paths. The overall classification remains INCOMPLETE. Stop/refusal reports do not satisfy this filesystem-error recognizer. `92-95` leaves historical-cause establishment and all authorization/readiness/vendor flags false; no historical u03 attribution is made.

The fixtures explicitly cover whitespace, size boundaries, missing/wrong statuses, flag layers, malformed JSON, integrity failures, non-normalized error paths and CLI preservation (`test_receiver.py:51-229`). Their synthetic success is not production evidence or exhaustive schema testing.

## Delivery boundary and unresolved prerequisites

Receiver README `76-108` correctly labels the builtin-printf octal/pipe/direct-child Python/status-frame/control-mode concept as a candidate, not an implemented channel. No adapter or control-mode decoder is delivered in this package. The immutable launcher README `62-81,95-124,178-196` requires independently approved exact-byte stdin plus EOF, complete capture and exact command exit status; it prohibits remote redirects and does not authorize this candidate.

In particular, parentage, shell compatibility, exact transmitted bytes, separate outer stderr, status framing, terminal-mode effects, protocol expansion and capture throughput remain unverified. A tmux command acknowledgement or client exit is not the Python exit status; PTY/control-mode output alone does not establish separate original streams. The proposed future controller must preserve its full local transcript, budget envelope plus protocol/framing expansion, losslessly decode pane output and classify missing status, disconnect, lag or truncation as INCOMPLETE. These are delivery integration/authorization blockers, not grounds to claim a delivered channel or demand an unrelated receiver redesign.

Fresh independent live identity attestation, approved channel integration and explicit execution authorization remain outstanding. This review supplies none of them and grants no retry, remote execution or historical-evidence reinterpretation authority.

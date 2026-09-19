# Independent code-quality review

## Disposition

**APPROVED — bounded LOCAL/fake-channel controller only.** No critical or important implementation defect identified within the specification-passed contract. This is a static quality review, not a test rerun, production transport validation, readiness decision, or mailbox fix.

`authorization=false`, `ready_for_build=false`, `vendor_run=false`.

Reviewed `controller.py`: **9686 bytes**, SHA-256 **4efbc12f982d32c0827a1c91b16502dc62d91875c18134ee7631b6d277147e78**. Relative citations refer to this package unless a sibling path is specified.

## Scope and method

Read `spec-review.md`, current controller/tests/runner, README, manifest, validation record, retained test output and source bindings, and the immutable delivery decoder and receiver source. Independently checked local bytes using reviewer-authored standard-library hashing, JSON inspection and AST parsing. No controller, sibling module, fixture or test was imported or executed. No tests were rerun; no network, remote operation, vendor tool, tmux, subprocess fixture, permission change, commit or push was performed. The only created file is this review.

The original implementation dispatch is reported truncated (`spec-review.md:9–13`). This review uses the supplied narrow review contract and explicit README limitations, without inventing missing historical requirements. `CAPTURE_END` is trusted cooperative LOCAL/fake completion, not proof of production draining. A missing production backend is an explicit exclusion, not a defect to repair in this package.

## Critical / important findings

**None within the reviewed contract.** The following paths were traced independently rather than relying solely on the specification PASS:

- **Late acquisition errors cannot become successful completion.** The read loop does not call the parser or stop on an S/R prefix; only the identity sentinel establishes the explicit boundary. Empty bytes, raised errors, invalid return types and oversized returns reject acquisition (`controller.py:127–159`). Cleanup runs before decoding, and missing boundary is an additional error (`controller.py:160–176`). A valid retained prefix with a late read failure can still yield useful decoded evidence, but accumulated transport errors prevent receiver acceptance (`controller.py:181–187,213`; `../runtime-metadata-receiver-01/receiver.py:98–100,195–200`). Tests specifically retain bytes and assert all simultaneous late-read/sink-close/channel-close errors reach receiver issues (`test_controller.py:220–233`).

- **Short writes and independent cleanup errors remain visible.** Every controller sink write verifies an exact integer byte count and does not retry (`controller.py:116–125,153`). Flush and close are separate guarded calls, followed by a separately guarded channel close (`controller.py:104–114,160–165`). A write failure does not suppress that sink's later flush/close attempts; a cleanup exception does not replace an earlier error. This conclusion assumes the documented ordinary binary-file sink interface, not hostile custom attribute access (`README.md:42–46`).

- **Acceptance is not persisted before cleanup.** The first receiver result is used only to obtain collector streams; its assessment is discarded (`controller.py:189`). Receiver files and metadata are written and closed before the final assessment (`controller.py:190–213`). `acquisition.json` unconditionally records INCOMPLETE with `final_receipt_required=true`, so its own failing write/flush/close cannot leave a persisted success claim (`controller.py:199–210`). Final evaluation receives the accumulated error list. Exclusive directory/file creation prevents accidental reuse under the explicitly trusted-parent assumption (`controller.py:49–50,75–78,121–125,190`; `README.md:48–54`).

- **Exact bytes and status remain separate.** All six source bindings are checked before either parser is compiled, and the actual checked byte strings are used (`controller.py:30–46`). Finished retained bytes go unchanged to the pinned decoder (`controller.py:168–176`). Its stdout goes unchanged to the receiver; command stderr is separate, and status comes from the decoded S record, never the envelope's inner wait status (`controller.py:178–196`; `../runtime-metadata-delivery-01/delivery.py:161–172`). Decode failure leaves envelope/stderr/status unavailable rather than supplying a success status. Collector stream file names derive from the pinned receiver's fixed stdout/stderr iteration, not arbitrary envelope keys (`../runtime-metadata-receiver-01/receiver.py:124–135`).

- **Bounds match the limited claim.** Reads request at most CHUNK and remaining cap plus one. Valid returned bytes are retained before persistence; exactly one overflow byte can be retained, and cap overflow cannot reach acceptance (`controller.py:139–157,171–176`). Overlarge contract-violating returns are rejected without claiming preservation (`README.md:58–64`). The calculated file-content ceiling is 42,008,577 bytes; metadata has its own refusal cap (`controller.py:22–25,206–210`). Parser allocations and exception formatting are not advertised as a strict RSS bound (`README.md:130–139`). The deadline is cooperative acquisition/evidence checking, not a hard whole-function bound; the final receiver evaluation itself is not followed by another deadline check (`controller.py:211–218`), consistent with the explicit parser/non-preemption limitations (`README.md:141–150`).

- **Partial evidence and receiver exceptions fail closed.** Raw bytes survive sink failures in memory, and successful delivery decoding preserves exact envelope and separate command stderr even if the receiver rejects them (`controller.py:152–154,168–196`). A raised receiver exception is caught and represented by an INCOMPLETE fallback; a later successful evaluation still sees the earlier error (`controller.py:181–187,213`). If final receiver evaluation raises, collector streams returned by that final call are unavailable, but previously saved collector files are not removed and raw/envelope bytes remain in the receipt. The filesystem is not promised to record failures it cannot persist (`README.md:93–109`). Resource exhaustion and hostile injected implementations are not certified by this review.

## Independently verified retained evidence

Reviewer-authored static verification completed successfully; no reviewed program was run.

| Check | Result |
| --- | --- |
| Current controller length and expected SHA-256 | Match |
| Manifest artifact lengths and SHA-256 values | 19/19 match |
| Unique SHA256SUMS entries, including manifest | 20/20 match |
| Controller immutable sibling bindings | 6/6 match |
| Retained source maps and output hashes | All three stages match; nine source entries per stage, including RED's absent controller |
| Current controller/test/runner vs. green-final snapshots | Byte-identical |
| Final AST test names vs. validation and retained success log | Exact agreement, 14 methods |
| Retained source bindings parsed with Python 3.9 AST grammar | Pass; not Python 3.9 runtime certification |
| Manifest, validation and retained checks flags | All three flags false |

Recorded execution, **inspected rather than reproduced**:

- RED: exit 1, missing-controller import; nine test methods exist in the retained source, but the log reports one failed loader item, not nine executed failing tests (`red/checks.json:11,19–20`; `red/unittest.txt:1–18`).
- GREEN-01: exit 0, nine recorded passing methods (`green-01/unittest.txt:1–14`).
- GREEN-FINAL: exit 0, 14 recorded passing methods, 5.126 seconds; interpreter recorded as Python 3.13.5 (`green-final/checks.json:2–12`; `green-final/unittest.txt:1–19`).

The runner hashes sources before execution and then records output (`check_local.py:23–44`). Matching retained hashes establish internal consistency, not independent authentication of historical execution or exclusion of concurrent historical source changes. No such change is evidenced. The manifest expressly excludes future review files (`manifest.json:3–6`); this review is not claimed to be covered by the existing checksums.

## Optional coverage improvements — not approval blockers

1. Add separate first-call-only and final-call-only receiver exceptions. The existing test makes both calls fail (`test_controller.py:247–254`); separate cases would lock down prior-error propagation and partial collector-evidence retention (`controller.py:181–196,213–216`).
2. Add explicit channel return-contract cases: non-bytes, oversized return, and a deadline crossed while returning CAPTURE_END. The code rejects these cases (`controller.py:141–155`), but current deadline coverage targets pre-read and close paths (`test_controller.py:186–194,255–264`).
3. Extend isolated sink-fault coverage to command stderr and both collector files, and add receiver-directory creation failure. Existing broad faults cover several of these only alongside a channel-close failure; the strengthened isolated matrix covers control.raw, raw-envelope.bin and acquisition.json (`test_controller.py:150–167,208–218`). Shared persistence helpers are correctly fail-closed on static inspection.

## Remaining gates

Only parent disposition within the LOCAL/fake scope follows from this approval. Production helper startup, attestation, acquisition boundary/backend and one-shot execution authorization remain absent and blocked (`README.md:188–198`). Current BSP generation still fails on BMC mailbox waitrequest metadata. This infrastructure review neither fixes that condition nor authorizes remote diagnostics, vendor execution, historical u03 work, or build/readiness promotion. All three flags remain false.

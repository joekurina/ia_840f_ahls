# Payload-before-notification candidate126

## Scope and decision

Create an **additive, local-only candidate**, not a replacement of the maintained mailbox or a production source selection. Preserve the original mailbox, timing46 observer, endpoint/top, generated HLS/fabric, static FIM, clocks and constraints. Parent performs all implementation and test execution.

[BUNDLE-DESIGN94](../caps02-afu-publication09/BUNDLE-DESIGN94.md), section6, identifies source-side payload installation followed by a later notification as the first structural alternative when an absolute-settling proof cannot be maintained under transformations. [Result124](../caps02-afu-publication09/BUNDLE-RESULT124.md) supplies complete original-fit raw/timed point records but does not qualify aperture or protocol margin. [clock-envelopes125.json](../caps02-afu-publication09/clock-envelopes125.json) and its executable [reducer](../caps02-afu-publication09/analyze-clock125.py) further extract local clock-branch offsets for all3680 bundle pair/corner entries, explicitly without a Gmin certificate.

The design choice is to avoid requiring a positive minimum propagation delay through an asynchronous first-stage request/ack route. Such a route can become faster in a changed fit. A whole extra **source** cycle between held-payload installation and notification is an explicit protocol separation instead. This is not a finding that the original mailbox is physically unsafe, not an assertion that a constraint-only solution is impossible, and not a timing waiver. No larger absolute settling target is proposed: retain the existing3ns target for subsequent physical qualification.

The observed combined local offsets are worst−0.796ns request and−0.838ns response in the old fit. Under the reviewed nominal two-destination-edge protocol, subtracting the unchanged3ns settling target leaves algebraic allowances2.204/2.162ns for all other terms; a hypothetical extra3ns source cycle makes these5.204/5.162ns **before source-cycle contraction and new-fit remeasurement**. These are not qualified timing margins. Aperture, jitter/uncertainty allocation, positive guard, all-transition envelope coverage, common-prefix interpretation and overwrite bounds remain subject to independent review and physical evidence. No constraint value is authorized by this comparison.

## Exact functional change

1. Accept a request on the existing `source_accept` edge. Install all130 held request bits and assert `core_busy`, clear `core_valid`, and assert `request_pending`.
2. On the next active core edge, toggle `request_toggle` and clear `request_pending`; keep ownership/busy asserted. `source_complete` explicitly excludes `request_pending`, because the old ack equals the still-unpublished request toggle during that state.
3. Keep the existing two-stage request synchronizer and bank-side single command strobe.
4. On the existing qualified observer acknowledgement edge, capture the entire snapshot and both sidecar flags and assert `response_pending`. Keep `waiting_bank_ack` asserted.
5. On the next active bank edge, publish `ack_toggle`, clear `response_pending`, and release `waiting_bank_ack`. Give this pending-publication branch priority over another response capture, so a held observer ACK cannot recapture changing inputs.
6. Keep the existing two-stage ACK synchronization and one-edge core installation/sequence update. Preserve all error priority, rejected-RELEASE history, sequence overflow and asynchronous local-reset behavior. Each pending bit resets in the same local process as its held payload/toggle.

All public ports/widths remain unchanged. The new file/module is `afu/ahls_memory/control/ia840f_ahls_observer_mailbox_timing126.sv`. It is not selected by the maintained endpoint/top or a QSF. [source126.json](source126.json) and [mailbox126.diff](mailbox126.diff) bind the exact delta.

## Local functional qualification

- Reuse the existing timing46 observer mailbox suite with only its top/module selectors changed: original drivers, values, assertions and timeouts preserved. Run production64-bit sequences under the three already-used clock ratios, plus the8-bit overflow configuration.
- Add a separate source-staging fixture: exact request/response one-edge separation; no premature core completion during request-pending; complete payload and sidecar immutability; held observer ACK capture-once; exactly one command and completion; bank/core stopped during pending notification; reset of each pending state; rejected busy command and DMA contamination on notification edges; same-edge completion faults; no stale replay after reset. Count actual check/phase hits.
- Use deliberately broken local candidate mutants to prove that missing pending-completion inhibition, same-edge request notification, and same-edge response notification are rejected by the targeted fixture. These are labeled synthetic RTL mutations, not hardware evidence.
- Preserve compile/run logs, statuses, hashes, all original sources and any failures. A local simulation pass is separate from independent result acceptance, integrated Questa, mapping, fit/STA, CDC/reset/MTBF and hardware acceptance.

## Physical continuation boundary

This changes HDL and therefore does not reuse synthesis59 as the candidate's mapped result. Future source selection and native qualification must be separate, source-bound steps. Recheck all payload/sidecar/direct-predicate consumers and notification replicas; add pending-state local-control paths to physical coverage. Quantify Gmin/Hmin with explicit reliability/aperture assumptions and supported25.1 constraints before claiming CDC closure. The original reset/RDC and observer fitted-timing failures remain open. `PUBLISH_SUPPORTED=0`; no FPGA/device operation is part of this candidate.

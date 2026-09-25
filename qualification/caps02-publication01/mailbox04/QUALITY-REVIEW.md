# Mailbox04 — full-slice QUALITY review

**APPROVED for the standalone digital mailbox slice. No remaining critical or important source defect found.**

This review covers the complete mailbox04 RTL and connected fixture, not only the RELEASE-predicate delta. It accepts the completed mailbox04 SPEC PASS/B1 closure and the unchanged candidate02 counter QUALITY approval; neither is requalified here. Approval does not establish vendor synthesis, physical CDC/reset timing, real CSR/AFU integration, controller visibility or hardware acceptance. Unrelated width-adapter experiments are outside scope.

## Evidence and inherited verdicts

Read-only SHA256/JSON checks returned exit0. Current source hashes match `green02.json`; the RED source and fixture match `red01.json`. Both consumed review hashes match their actual review files. Bindings independently measured for this review:

| File | SHA256 |
|---|---|
| `ia840f_ahls_observer_mailbox.sv` | `980384d81f0bf54ade59f1a70e4f14bd72d83893709a71069fc5f595db3abc0a` |
| `tb_observer_mailbox.sv` | `1973821ef7a048c029740d67a77eaa7160c16a33b560dbb152f4929a5e12ecf2` |
| `SPEC-REVIEW.md` | `1944d0aa7998befde4e2d297be37f8572b5f1260cbff1a049f2664c452820d50` |
| `spec-consumed.json` | `1fbdf359fd2a03f98c3920a3ec5028399b7c23360f23bee1b1186dc56948ea26` |
| `green02.json` | `c12e34f1c3376b5bc909ca30e81d3ce228c7a8dd49ffc72d8e900dae0ee5a9d5` |
| `red01.json` | `6035105edc6780f19ed8f7017ac74eed6a5c117adb256b746f57f8a922b19092` |
| `RESULT.md` | `41ea3a6f5c638cf30abc12bf375e5dbcbc8d573a906b883ec29a50239eb14fce` |
| `../candidate02/QUALITY-REVIEW.md` | `7a557751ca3e6babc8a87a80ed966e35ad5b0c2659648e91d67f2a874118b9fc` |

The connected counter still hashes to `a903505e0fd7f0c64815ab1541cbeff4a0aa2feced83be434db0e99d80a516f3`, the approved counter identity. Its registered command/ack interface and reset/fault connections were inspected only to establish mailbox behavior. Its internal accounting and previously disclosed limits retain the existing approval.

`../mailbox03/PLAN.md` and `RESULT.md` supply the inherited pulse, reset-lineage and coverage contract; mailbox03 RTL is superseded. The completed SPEC review's executable/simulator binding checks and original-fail/fixed-pass disposition are reused, not repeated by executing their artifacts. `RESULT.md:9` retains historical pending-review wording; `spec-consumed.json` establishes the completed SPEC disposition, and this document supplies QUALITY approval.

## Full RTL findings

References below use `RTL` for the mailbox, `TB` for its fixture and `OBS` for the unchanged connected counter.

### Synthesis portability

- No inferred latch, conflicting register owner, combinational feedback or variable-size storage was found. State is owned by explicit edge-triggered blocks; sticky error-bit assignments and their whole-vector reset belong to the same block. Request/response bundles and controls have explicit packed widths (`RTL:30–147`).
- Sequence arithmetic is unsigned and width-bounded. The maximum comparison gates the increment, and narrower sequences zero-extend into the fixed-width output. The attempted completion beyond the maximum faults rather than wraps; reaching the maximum itself remains a valid completion (`RTL:50–59,99–104,124–125`).
- The constant `initial` geometry check with `$fatal` is simulation/elaboration validation, not implemented protection. No functional register depends on declaration initialization. Front-end handling of that check and `async_reg` attributes remains unverified by vendor synthesis; empty Icarus diagnostics are not a portability or timing signoff. Wide payload registers, sequence arithmetic and reset fanout also remain unmeasured implementation costs. None is a demonstrated source defect in this scope.

### Command/response ordering and one-cycle pulses

- `source_accept` requires ready, which excludes busy; `source_complete` requires busy. Thus the independent enqueue/install `if` statements cannot both execute for the same pre-edge state. A command offered on the existing completion edge is rejected, not silently accepted or allowed to replace its held fields (`RTL:53–61,116–125`). There is an intentional turnaround before another acceptance.
- Enqueue registers the fields and toggles the request on the same core edge. The bank detects the mismatch only after request synchronization, then registers the held bundle and emits one native strobe. `waiting_bank_ack` prevents redelivery and ignores an acknowledgement outside an outstanding native command (`RTL:80–85,134–145`).
- With the actual observer, the next native edge consumes that strobe and registers `cmd_ack` and command effects; the following edge captures the resulting observer state and changes `ack_toggle` (`OBS:126–134`). This is not same-edge sampling of the pre-command state. The registered ack has returned low before a subsequent request can make the round trip, so it cannot falsely acknowledge the successor.
- `bank_cmd_valid` is defaulted low on every nonreset native edge; request detection raises it for only one cycle. `core_done` is likewise defaulted low and raised only on installation; clearing busy prevents another completion of the same toggle (`RTL:115–125,139–145`). Held source valid is deliberately a protocol violation that latches rejection, not a conventional held-valid/ready transaction. Native ack and core done indicate processing, including rejection, not success.
- A stopped native clock cannot manufacture an outstanding response. A response already captured before the stop may still finish crossing legitimately. No timeout or automatic replay is invented, and core-visible ready/busy/status logic uses local registers and synchronized controls rather than combinational native progress.

### Bundled-data lifetime and coherence

- `request_hold` changes only on accepted enqueue or link reset. Busy excludes another enqueue until the response installs, so it remains fixed across destination synchronization, command execution and acknowledgement. `bank_request` separately holds the delivered command fields (`RTL:112–118,136–144`). Perturbing external fields while busy cannot change the delivered request.
- The whole response, armed flag and error flag are captured together before the ack crosses. They remain unchanged until another native response. A new request cannot be accepted before the old response has installed at the core, so the next transaction cannot overwrite the old response during its capture window; a separate return handshake is not missing (`RTL:120–125,142–144`).
- The bank capture is a coherent observation of the observer's pre-capture-edge registered state, including the preceding command edge. It does not include additional observer updates made on the capture edge itself. Core snapshot data then remains frozen until another completion or reset, even when validity is revoked by a later live fault. `response_error` is the captured native error, not an aggregate of local errors; neither it nor a stale armed/target bit replaces `core_valid` and live error checks.
- These are digital lifetime guarantees. They depend on the separately required physical settling bounds for the unsynchronized request/response bundles relative to synchronized control. Attributes and directed simulation do not prove those bounds or make a frozen snapshot an instantaneous native-state certificate.

### Independent reset, epoch and error semantics

- Either reset asserts both observer-only link resets asynchronously; each clock releases its own link reset through its pipeline. Both handshake halves, held payloads and pending native-command state clear. Readiness also requires synchronized bank-up, so a halted/reset bank does not make the link ready prematurely (`RTL:30–39,71–85,110–113,134–137`). The fixture really resets the observer with `bank_link_reset_n` (`TB:44–47`). No memory/FIM reset is driven.
- Bank-only reset clears snapshot validity and abandons pending mailbox state without rewinding the surviving core sequence or clearing core fault/epoch history. The stretched link reset is observable by the history block, which poisons an active epoch. Core reset instead clears that history and the sequence as a new lineage, while also resetting the native observer. Busy-clear due to reset is not completion, and no old toggle is replayed (`RTL:88–105`).
- The history block intentionally uses `core_reset_n`, not the bank-joined link reset. Physical assertion width and reset recovery/removal remain integration obligations, including release of this directly core-reset history block; the two link synchronizers alone are not proof of every register's reset timing.
- Error bits remain sticky until core reset; a bank-only reset cannot rehabilitate an errored epoch. Local bits0–4 are private mailbox status, not the observer ERRORS ABI. Unused local bits remain reset to zero. Captured native rejection and synchronized live native error both poison local status (`RTL:90–105`). Reset/timeout still means lost or unknown invocation, not cancellation, safe retry or permission to release memory ownership.

### Same-edge fault dominance

- DMA monitoring begins on accepted ARM itself and includes every edge of the retained window, including RELEASE installation. Its local sticky capture is authoritative even if a late fault reaches a native observer already disarmed by RELEASE (`RTL:56–57,94–104`). Parallel request/fault synchronization therefore cannot turn a locally contaminated command into valid success.
- Completion validity explicitly checks prior local error, current rejection/DMA, captured native error, synchronized live native error and sequence exhaustion. RELEASE closure applies the corresponding fault guards plus the held RELEASE opcode and returned disarmed state. It does not rely on a just-updated nonblocking error register becoming visible on the same edge (`RTL:99–104,120–128`).
- B1's added `!source_reject` makes closure consistent with invalidation. The completed SPEC closure is accepted. Reset excludes completion through link reset/busy clearing, so reset invalidation cannot simultaneously become a successful RELEASE. An invalid completion may still install diagnostic data, pulse done and advance a nonexhausted sequence; none of those actions independently certifies success.

## Test coverage and claim accuracy

These are inspected retained executions, **not reviewer reruns**:

| Sequence bits | Core/bank half-periods, ns | Cases | Checks | Native commands | Compile / simulation exit |
|---|---|---:|---:|---:|---|
| 64 | 5 / 7 | 10 | 76 | 15 | 0 / 0 |
| 64 | 7 / 3 | 10 | 76 | 15 | 0 / 0 |
| 64 | 5 / 17 | 10 | 76 | 15 | 0 / 0 |
| 8 | 5 / 7 | 11 | 847 | 271 | 0 / 0 |

All GREEN compiler outputs are empty. The JSON includes explicit compile/simulation argv and emitted-executable hashes. RED records the original mailbox03 compiling successfully and exiting1 at the intended rejected-RELEASE-window assertion using the same expanded fixture, not an elaboration failure or different GREEN fixture.

The fixture connects the real counter, checks payload/token/sequence and invalidity rather than only completion, and includes delayed B, immutable snapshots during later traffic, clock stop/resume, busy rejection, active/idle bank reset, core-reset replay suppression, native rejection and narrow sequence exhaustion. Checks reject unknown conditions; stimulus generally changes on falling edges and observations follow nonblocking updates by `#1`, with a finite watchdog (`TB:53–89,92–157`).

The added RELEASE collision checks continued DMA and bank-reset fault capture without a core reset; the separate enqueue test limits DMA to the actual ARM-acceptance edge. Those accepted SPEC conclusions are supported by the fixture, while the older broader contamination case alone would not isolate that edge.

Coverage remains directed, not exhaustive:

- Clock schedules repeat the same scenarios; they are not disjoint coverage or physical metastability tests.
- `await_done` checks busy-clear, not `core_done` pulse width. Native command counts are checked in selected cases, not asserted for every transaction. One-cycle behavior is therefore additionally established by source inspection.
- No exhaustive reset-position/clock-phase sweep, field-perturbation-while-busy test, held-source-command sequence or stop-at-every-handshake-stage test is present.
- Same-edge DMA/native-fault RELEASE collisions and every multi-fault combination are not all directed tests. The source predicates cover the reviewed combinations; B1's negative control does not establish general mutation coverage.
- Sequence exhaustion is exercised at width8, not near the production-width limit. Other legal geometry values are not separately exercised.

These are bounded evidence limits, not additional proven source defects or blockers for the stated standalone scope.

## Retained integration obligations

1. Wire the real bank1 FIU observation/reset boundary and core-clock DMA-attempt signal, retaining the exclusive known-lineage host contract and the unchanged observer assumptions.
2. Implement the separately deferred local CSR response path, full access validation and one-cycle command generation. Require fresh sequence, matching token, valid snapshot and live error-free status; expose local faults without confusing their bit positions with the native snapshot ABI. Prove prompt responses with a stopped bank there.
3. Establish native synthesis acceptance, effective synchronizer recognition, bundled-data max-delay/settling constraints and reset assertion/release timing in the actual integrated design. No physical STA or CSR implementation is demanded as a defect remedy for this standalone slice.
4. Keep publication capability clear until exact controller post-B visibility is established. TARGET_RETIRED, snapshot delivery and RELEASE prove neither PUBLISHED, all-master drain nor reset/buffer-release safety.

Review actions were local source/evidence reads and read-only hashing/JSON assertions. No build, simulator/vendor execution, SSH, device access, git operation or implementation edit occurred. The only created or modified file is `qualification/caps02-publication01/mailbox04/QUALITY-REVIEW.md`.

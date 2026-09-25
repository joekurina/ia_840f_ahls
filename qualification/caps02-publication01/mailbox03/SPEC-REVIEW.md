# Connected two-clock mailbox — independent SPEC review

**FAIL — one blocking bounded-spec defect: a busy request rejected on the RELEASE-completion edge incorrectly closes the retained core epoch window (B1).** The same edge still latches an error and invalidates the snapshot; this is **not** a demonstrated false-success or publication path. It violates the promised successful-completion-only epoch-window closure and consequently stops subsequent DMA/reset monitoring for that failed completion.

Scope: `PLAN.md`, applicable mailbox/reset/fault requirements in `../DESIGN01.md` §§3–5, the exact mailbox and connected candidate02 observer, testbench, manifests and retained outputs. No CSR implementation or physical CDC qualification is required for this bounded verdict.

## Evidence inspected and bound

Independently recomputed source SHA256 values; all match `test02.json`:

| Source | SHA256 |
|---|---|
| `ia840f_ahls_observer_mailbox.sv` | `25ed4e4c7c02cc9a74d57f6e8a4dec932392a17735e76862853b08b21fd8710e` |
| `tb_observer_mailbox.sv` | `1caa189a7c00082348079925ca65ec5481a7ebe854dbafb08000e01c1f9b546b` |
| `../candidate02/ia840f_ahls_write_observer.sv` | `a903505e0fd7f0c64815ab1541cbeff4a0aa2feced83be434db0e99d80a516f3` |

`test02.json` SHA256: `13b445956b23864d62ef7357ad07c6c7d422456f048e1e41ed09d756d183d45b`.
`negative-reset.json` SHA256: `9f897c8d0301bdb391ad68c8775c4de70f312539de5b067cb54aca1d90f1597f`.

The fixture really instantiates the unchanged observer and connects its registered acknowledgement, native errors/armed state and complete 768-bit payload (`TB:23–24,35–51`); responses are not mocked.

| Sequence bits | Core/bank half-period, ns | Recorded simulation output | Compile / simulation exit |
|---|---|---|---|
| 64 | 5 / 7 | 8 cases, 63 checks, 12 native commands | 0 / 0 |
| 64 | 7 / 3 | 8 cases, 63 checks, 12 native commands | 0 / 0 |
| 64 | 5 / 17 | 8 cases, 63 checks, 12 native commands | 0 / 0 |
| 8 | 5 / 7 | 9 cases, 834 checks, 268 native commands | 0 / 0 |

All recorded compiler outputs are empty. The retained `mailbox-64-5-7.vvp` header identifies Icarus 12.0 stable and the matching parameters. These are inspected prior-run outputs, **not reviewer reruns**; the manifests do not separately bind VVP executable hashes or record a simulation argv. Repeated clock schedules are not disjoint coverage or metastability evidence.

The negative mutant hash matches `negative-reset.json`; its only source delta removes `bank_reset_n` from `common_reset_n`. It compiled successfully, then exited 1 at `CHECK brief native reset poisons active lineage`, with `core_errors=00`, `valid=1`, `seq=1`. This is the intended negative control, not evidence that the correct RTL fails. `missing-feature.json` is only an absent-module elaboration failure. `attempt01.json` binds the earlier fixture, not the current parameterized testbench.

## B1 — same-edge local rejection loses the retained epoch window

**Requirement:** `PLAN.md:5–7` retains the core epoch from ARM enqueue until a **successful** RELEASE acknowledgement. `RESULT.md:34` expressly says acknowledgement/busy-clear is not success unless resulting error/valid/token/sequence fields pass. Error precedence must also hold on coincident events.

**Location:** `ia840f_ahls_observer_mailbox.sv:94,99–104,124–128`.

The RELEASE-clear predicate guards against prior `core_errors`, same-edge `dma_now`, synchronized native error and sequence exhaustion, but omits **same-edge `source_reject`**. The completion-valid predicate correctly includes it. Because the error-bit update is nonblocking, testing `core_errors==0` does not see the new rejection until after this edge.

Concrete reachable trace, without simultaneous clock/reset stimulus races:

1. Complete a clean ARM and the exact required write retirement; enqueue RELEASE.
2. Wait until its successful native response has reached the core acknowledgement synchronizer. Before the core edge that installs it, pulse another `core_cmd_valid` while `core_busy=1`. This is precisely the invalid busy request the mailbox promises to reject, not a second accepted command.
3. At that edge, `source_complete=1`, `source_reject=1`, the held opcode is RELEASE, `return_armed=0`, `return_error=0`, prior `core_errors=0`, and no DMA/native/sequence fault is present.
4. RTL sets `core_errors[0]=1`, `core_valid=0`, clears busy and pulses done, **but also sets `epoch_window=0`**.
5. Subsequent DMA write attempts no longer satisfy `dma_now`; a subsequent bank-only reset no longer satisfies the epoch-reset-fault predicate (`:56–57,95–96`). The local rejection remains sticky, so these events cannot restore success, but the promised retained window and additional fault capture are lost.

A read-only evaluation of these exact source predicates returned `source_reject=True`, `release_clears_epoch=True`, `completion_valid=False`. This is a source-derived counterexample, **not an additional RTL simulation result**. None of the recorded tests targets this coincidence: the busy-rejection case uses SNAPSHOT; the RELEASE case has no coincident rejection (`TB:102,108–110`).

**Required disposition:** make window closure use a fault-dominant successful-completion qualification that includes the same-edge local rejection. In a successor, regress a one-core-cycle busy request on the RELEASE-install edge and require the epoch to remain open, validity low and rejection sticky; then exercise a DMA attempt and bank-only reset to establish continued fault capture. No implementation was changed by this review.

## Other requirement findings

References below use `RTL` for the mailbox and `OBS` for the unchanged candidate02 observer.

| Requirement | Finding |
|---|---|
| Coherent, frozen snapshots | **PASS by source inspection and bounded tests.** `request_hold` changes only on enqueue; busy excludes another acceptance. Destination captures the bundle after synchronized request detection. It samples the complete observer payload after the observer's registered command ack, including the command's registered effects (`RTL:116–125,134–145`; `OBS:126–134`). `response_hold` remains fixed until another command response; the source installs the whole payload together and does not refresh it in the background. Sampling excludes updates on the capture edge itself, giving a coherent preceding native state rather than promising an instantaneous view. Delayed-B and later-traffic immutability checks support this (`TB:96–101`). |
| One native command strobe | **PASS.** Detection sets `bank_cmd_valid` for one cycle and `waiting_bank_ack` blocks redelivery; the next native edge executes the actual observer command. The following edge sees its registered ack, captures its result and advances the ack toggle (`RTL:139–145`; `OBS:93–109,134`). The source must supply command pulses, not a held valid/ready transaction. |
| Either-side reset and stale replay | **PASS for inspected digital logic.** Either reset asynchronously clears both link-reset pipelines and both handshake halves; releases are independently synchronized. The observer uses `bank_link_reset_n`. Request/ack toggles and pending native command state are cleared, preventing old requests/acks from completing after reset (`RTL:30–39,71–86,110–113,134–137`). Core reset also clears sequence/epoch/error history; bank-only reset preserves those core registers and stretched link reset faults an active epoch (`:88–105`). Active/idle bank reset and a pending ARM interrupted by core reset are exercised (`TB:112–123`). B1 is the exception to retaining an active window after a failed completion. |
| DMA contamination window | **PASS except B1.** `dma_now` includes ARM acceptance itself and every edge with the window open, including the RELEASE-install edge. Same-edge DMA fault prevents validity and window closure; sticky contamination crosses to the native observer (`RTL:56–57,80–85,94–104,124–128`). A late fault after native RELEASE can be absent from frozen native errors; the retained core fault remains authoritative. |
| Native clock stop | **PASS for an outstanding, not-yet-produced response.** No ack is manufactured without native command processing. With the initialized bank clock stopped before a request, busy remains set and valid remains clear; resuming completes exactly one request (`TB:104–106`). A response already captured before a clock stop may legitimately finish crossing to the core. Local CSR response latency is not exercised here. |
| Sequence and error dominance | **PASS for snapshot validity; B1 for window closure.** Counter increments only on response installation, saturates at its maximum, and faults/invalidates an attempted overflow without wrapping (`RTL:99–104,120–128`). The width8 run actually reaches the limit. Prior local faults, same-edge rejection/DMA, synchronized native errors and captured native rejection all prevent valid success. Invalid-token ARM returns a faulted completion (`TB:129–135`). Errors persist until core reset; a bank-only reset does not erase them. |

## Simulation races and test weaknesses — separate from B1

- Command and AXI stimulus normally changes at the respective falling edge; checks follow rising edges by `#1` (`TB:53–54,67–89`). No specific race was found that invalidates the retained passing outputs. Equal-time unrelated-domain edges and clock-enable/resume scheduling are not an exhaustive phase sweep, however. The B1 trace can place the extra command safely before its core sampling edge and does not depend on simulator process ordering.
- The claimed enqueue-edge DMA test is not edge-isolating: `dma_write_attempt` remains high through a later core edge after ARM acceptance (`TB:125–127`). A mutant that omitted the explicit ARM-enqueue term could still fault after `epoch_window` rises. Keep the observed contamination result, but do not claim this test alone proves the exact starting edge. Source inspection establishes that edge in the current RTL.
- Coverage does not exhaust reset positions in the request/ack round trip, perturb request fields while busy, test contamination exactly on RELEASE completion, or assert every `core_done` pulse and every native-strobe count. `await_done` checks busy-clear, not the done pulse. The clock-stop case begins before delivery, not at every native handshake stage. These are bounded evidence limitations, not additional proven RTL defects or demands for whole-AFU implementation.

## Exact deferred integration obligations — not additional blockers here

1. Connect the observer at the actual bank1 FIU AW/W/B boundary after all splitting/CDC; pack the documented 768-bit fields from that same native domain. Supply the real bank1 and AFU/shim reset coverage, keep this reset network observer-only, and derive core-clock `dma_write_attempt` from `dma_bank[1].awvalid || dma_bank[1].wvalid`, including stalled attempts.
2. Implement locally terminated CSR responses with full address/access validation, a one-cycle command pulse and frozen command fields, immediate busy rejection, and prompt registered reads despite a stopped bank. Accept only fresh sequence/matching-token/valid/error-free snapshots. OR core-local faults into live STATUS; do not mistake the mailbox's private `core_errors` bit positions for the observer ERRORS ABI. Document FIRST_ERROR code2 ID as offending AWID or BID, not always BID.
3. Establish physical bundled-data settling/max-delay, synchronizer recognition and reset assertion/release timing in the integrated constraints and native reports. RTL `async_reg` attributes and digital simulation do not prove physical CDC, reset recovery/removal or implementation acceptance.
4. Preserve the exclusive known-lineage host contract and treat reset/timeouts/faults as unknown/failed invocation, not cancellation or permission to retry/teardown. Keep the publication capability clear until the exact controller post-B visibility rule is source-bound; this slice establishes neither PUBLISHED nor global drain.

Review actions were local reads, hashing, textual comparison and source-predicate evaluation only. No build, simulator execution, vendor tool, SSH, device operation, git operation or implementation edit occurred. The only authored file is this review.

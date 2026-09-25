# Native write observer — code-quality review

**APPROVED for the bounded passive native-clock observer slice. No critical or important issue found.**

This is a source-quality review of `ia840f_ahls_write_observer.sv`, its directed testbench and recorded results. The completed SPEC PASS is accepted, not reopened. This approval is neither native synthesis/timing acceptance nor approval of mailbox, CSR, physical integration or hardware behavior. No adjacent mailbox files were reviewed.

## Evidence binding and review method

Independently recomputed SHA256 values:

| File | SHA256 |
|---|---|
| `ia840f_ahls_write_observer.sv` | `a903505e0fd7f0c64815ab1541cbeff4a0aa2feced83be434db0e99d80a516f3` |
| `tb_write_observer.sv` | `8b3053ddf3717507f17372996b2dfa8c05ea593960f1bae57591c7ffbbcb9632` |
| `SPEC-REVIEW.md` | `dfdc57ad5fe6a7db2301de236e7e393609c6e4c0b372288f762b0486dacfb95d` |
| `test-final.json` | `023ae6557ac7766f332645a4b70c9fce13bc3dad337cace8eac33eed3e693300` |
| `negative-control.json` | `4b93530d7ade7af947204c4c0d5550b7c09843d6975ef1c0dd4d626b35833f1f` |
| `mutant-empty-only.sv` | `156edbe7043aebb94c66923715dd5f351b4df129374960d810e8a0faf16e4119` |

Source/test and mutant hashes match their respective manifests. Read-only Python checks also verified the mutant's exact textual delta and arithmetic bounds across every permitted counter width. Those checks exited 0; they are not RTL simulation or synthesis. No compilation, build, simulator execution, git, SSH, device access or vendor tool was performed by this reviewer. The only authored file is this review.

## RTL implementation findings

### Synthesis portability and timing exposure

- **No inferred-latch or multiple-driver defect found.** The combinational block assigns every next-state value and temporary on every path; loop bounds are constant. A single edge-triggered block owns the state, with consistent active-low asynchronous reset (`RTL:60–135`). The datapath uses packed unsigned vectors, fixed-width additions, comparisons and multiplexers; it has no dynamic storage, variable-bound loop, delay or vendor primitive.
- The constant `initial` parameter check containing `$fatal` (`RTL:55–58`) is simulation/elaboration validation, not an implemented hardware safeguard. For the supported `COUNTER_BITS=8..64` domain its branch is false. Its handling by a particular synthesis front end has not been exercised; Icarus acceptance must not be described as vendor synthesis acceptance. No functional initialized state relies on that block.
- **Concrete timing exposure remains unmeasured:** the procedural 64-lane population sum feeds cumulative-byte addition, saturation, epoch subtraction/comparison and checkpoint selection in one combinational cone (`RTL:60–91,111–112`). The code expresses serial accumulator dependencies; whether synthesis balances/restructures them is unproven. Wide counter comparisons and fault fan-in also feed that cone. Passive channel ownership does not mean zero added fanout or guaranteed timing after integration. This is a disclosed implementation risk, not a demonstrated timing defect or a reason to demand deferred integration here.

### Arithmetic and widths

- All six incrementing totals have an explicit carry bit before saturation (`RTL:31–33,63–80`). The largest increment is AWLEN+1 = 256. At width8, maximum prior value plus that increment is 511, which fits nine bits; the same extra-bit bound holds for all permitted widths through 64. No carry is lost before overflow detection.
- The seven-bit WSTRB population accumulator holds all 64 enabled lanes. Byte increments therefore fit the widened accumulator even at width8. Fixed 64-bit output assignments zero-extend the narrower unsigned counters. `COUNT_MAX` has a valid constant shift throughout the supported parameter range (`RTL:30,42–48,61–68`).
- Epoch comparisons use unsigned values and explicit extensions in the next-state path. Both public and internal success predicates separately guard against delta underflow. Saturation latches an error, and every error suppresses checkpoint advancement; equal saturated totals cannot restore target success (`RTL:50–53,79–91,111–112`).
- ARM checks the requested volume against the counter maximum, not remaining cumulative capacity. An otherwise valid epoch near exhaustion may consequently fault rather than complete. This is fail-closed, already acknowledged by the SPEC review, and not a promise of indefinite no-reset operation. Production-width near-limit behavior was inspected algebraically, not exercised by the recorded RTL tests.

### State, error and command edges

- All accepted AW/W/B changes are evaluated together before credit checks and checkpoint decisions; W-before-AW is intentionally not rejected. C is a clean-boundary checkpoint, not a per-response byte accumulator. The final `en!=0` guard also cancels tentative C advancement on a command fault (`RTL:63–112`).
- Sticky errors cannot be cleared by a later good response, SNAPSHOT or RELEASE. The first-error payload remains stable once valid. The descending loop deliberately leaves the lowest-numbered simultaneous fault as the selected first code; its integer-to-eight-bit assignment only uses codes 1–8 (`RTL:113–123`). Code2's ID payload may identify AWID or BID, not unconditionally BID.
- ARM checks next-state cleanliness, rejects presented channel activity even without a handshake, and sees a DMA fault on the ARM edge. Rejected ARM retains epoch fields. RELEASE sees current-edge faults and requires exact retirement plus no presented channel activity. A same-edge fault therefore cannot be hidden by successful release (`RTL:81–108`).
- `cmd_valid` executes on **every asserted clock edge**; `cmd_ack` is its registered processing acknowledgement, including rejection, not an independent success or ready signal. Held ARM/RELEASE can cause a subsequent invalid-command fault. SNAPSHOT does not freeze any output. These are explicit native-strobe semantics, not a missing mailbox implementation.
- Reset clears counters, armed state and error/token history together. No prior completion survives reset. The native reset-release discipline and already-synchronized sticky DMA/link input premises are not established by this module. Token freshness means nonzero and different from the immediately preceding token; it is not an unbounded replay history.

## Tests and claim quality

- The hash-matched `test-final.json` records explicit width64 simulation with **23 cases / 109 checks**, and width8 with **26 cases / 115 checks**. Both recorded compilations use `-g2012 -Wall`, return 0 with empty diagnostics, and both simulations return 0. Width64 is explicitly selected rather than inferred from the testbench's width8 default. These are inspected prior-run results, not reviewer reruns.
- Test stimulus is applied away from the active clock edge and sampled after nonblocking updates; failed or unknown check conditions terminate via `$fatal`, with a finite watchdog (`TB:20–55,128`). The tests check state and byte totals, not only acknowledgement. Delayed final data/response, sparse upper-half strobes, cumulative successor epochs, held error response, W-before-AW, simultaneous channels and narrow saturation have meaningful assertions.
- The negative control changes only the public target predicate to the empty-only form. Its recorded compile succeeds and its simulation fails at the intended first armed/no-output check with all totals zero. It does not mutate internal RELEASE qualification and does not establish mutation coverage of other failure modes.
- **Specific coverage limits:** no near-limit 64-bit counter stimulus; no exhaustive multi-fault precedence/payload matrix; no directed held-command sequence, DMA fault exactly at ARM, or valid RELEASE coincident with a new fault; no all-position WLAST checker. The reviewed logic handles the identified command/error combinations by inspection, not by those absent tests. The simultaneous AW/W/B case is an arithmetic stress case, not evidence of legal slave response latency.
- `PLAN.md` and `RESULT.md` correctly distinguish injected native fragment observations from testing an actual splitter or vendor path. Their synthesis/integration/hardware exclusions are material and remain in force. `RESULT.md`'s historical statement that independent reviews are still required is not a claim that those reviews already occurred; this report supplies the quality verdict only.

## Residual scope

The approved result is **live TARGET_RETIRED under the stated transport, ownership, clock/reset and synchronized-fault premises**. It neither validates address/data correctness nor makes `empty`, a stale target sample, or a previous token into a persistent completion certificate. Further zero-strobe transactions remain possible; global drain, PUBLISHED/post-B visibility and reset/buffer-release safety are not established. These are precise limits of this slice, not blocking findings or demands to implement the separately deferred mailbox.

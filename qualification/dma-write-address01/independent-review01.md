# Independent review — DMA writer AW correction

**Status: FINAL. Verdict: ACCEPT WITH FINDINGS — bounded AW source/native-unit acceptance only. NOT a qualified DMA writer, DMA subsystem, completion contract, or hardware release.**

An IN_PROGRESS draft was written before detailed inspection. This final report accepts the specific AW admission/valid, stalled-payload and full-versus-tail scheduling correction, together with the completed three-original-fail/candidate-pass evidence. No blocking defect was found in that correction within the stated unit contract. The unchanged response-retirement defect is positively observed, not waived. W-channel/FIFO behavior outside the fixture, integration and physical visibility remain open.

## 1. Review boundary and identity

`N = /home/joe/Projects/Thesis/AHLS/new_bsp/new`; `V = N/qualification/dma-write-address01`; `S = N/afu/ahls_memory/dma`.

Local source/evidence only: no SSH, network fetch, simulator/vendor-tool execution, hardware access, source changes, git operations or task transitions. Native execution was performed previously by the parent; this reviewer inspected its retained evidence and did not rerun it. Only this report was created/updated. The accepted donor findings in `qualification/ahls-memory-fabric01/DMA-DONOR-REVIEW01.md` are reused rather than reopening a broad donor audit. Its accepted commit `e76531dc98b3d5903b6abdd50d1ffd5b573aa23f` is parent-supplied provenance, not a git assertion independently rechecked here. Pending fabric/reader gates are independent and were not edited or awaited. DDR vendor simulation: **SKIPPED BY USER**.

### Independently checked full-file identities

| File / source | SHA256 |
|---|---|
| `V/review-package01.json` | `49036facd1a0c725876a39206e3ed25288d31eb0c80280052bc04eb5ac363874` |
| `V/source-binding01.json` | `2fd867e22cd4cab2ddc001347e3087fad3de0f08997007b15875285fa6601a4b` |
| Original `dma_write_engine.sv` | `fe85a45f43743fb161f48caa4157d9b22c33a6ea40a33a102613140531b8b682` |
| Candidate `dma_write_engine.sv` | `ec1483378ff7e3ce448bd92ff16ebc175831ac640dbae01dcb79b8924228e5f2` |
| `S/patches/write_address_handshake.patch` | `dd576d2b626c9a53a0b977765740dfa84dc6e43f083cd5f241d1471da0a6f81e` |
| `S/tests/write_address_tb.sv` | `299a2daebbe353ed5dfe61952ce026cffc9ca8cea5f9907077def8ee12a0893f` |
| `V/result-red01.json` | `242a356c9bbec112454711bb306efaa2957bbfa42996eb2f1bd0b549db2c5d19` |
| `V/result-red02.json` | `6c210492f3231fdf215a55846fbbd7b8b8a27fd8617d4c775a706b8efe72bf56` |
| `V/result-red03.json` | `0ef16803e946f8e3123910ad4de7f0ccf337776dba5559a9ef8f35267448283f` |
| `V/result-green01.json` | `db98ed148915913f7cdabdd553ee2be5129251672035f12a671e1abb1d5039de` |

All **21/21** manifest members match their recorded byte sizes and hashes. The original writer matches the retained donor path identified by `source-binding01.json`, whose AI Suite pin is `e0e07f7b1878a477dc4d1191918db8430193e148`. Both input trees' six dependency files match each other and their exact locally retained donor/PIM paths and hashes. A freshly computed original-to-candidate unified diff equals the entire submitted patch, including its three hunks; no hidden DATA/FIFO/B-response/status/reset/counter edits occur.

The four local invoking runners were parsed with `ast.literal_eval`, **not imported or executed**. Each embedded ten-member input set was decoded and byte-compared with the local source/test files and result input hashes. Only `dma_write_engine.sv` differs between original and candidate. Replacing each literal runner configuration with `C=@CONFIG@` reproduces the frozen `run-native.py.in` exactly. Runner hashes match their dispatch receipts; outer receipts bind the exact result-file hashes. All **16/16** embedded native log texts reproduce their recorded byte sizes and SHA256 values. Remote tool/process/source-preservation claims are therefore accepted as bound captured evidence, not as a new live inspection.

## 2. Source/spec review

Citations `W` refer to `V/inputs-candidate/dma_write_engine.sv`; `T` to `S/tests/write_address_tb.sv`; `P` to `V/inputs-candidate/dma_pkg.sv`.

### Admission and AWVALID — accepted

IDLE admission now requires descriptor GO, descriptor availability and input-data availability, **not AWREADY** (`W:105–119`). In SEND_WR_REQ, AWVALID is unconditionally one (`W:292–297`); the state only exits on AWVALID && AWREADY. Thus an address can be presented to a sink that waits for valid, and lowering ready cannot combinationally retract valid. Reset remains the existing synchronous reset; reset-in-flight is not qualified.

This is an AW-source repair, not a new promise that the whole writer tolerates arbitrary channel dependencies: its existing need for FIFO data before initial admission and its W-channel control remain unchanged.

### Payload hold — accepted

The sequential payload block is selected by **next** SEND_WR_REQ, but now writes only when **current** state is not SEND_WR_REQ (`W:184–197`). At IDLE→SEND entry, address, size, burst and initial length are registered before AWVALID is presented. At ADDR_SETUP→SEND entry, the already advanced address is retained and the next length is loaded. During every SEND→SEND stall cycle there is no AW payload assignment. Other payload fields were reset as part of the entire AW structure and remain unchanged (`W:163–169`).

On the eventual acceptance edge, next is FIFO_EMPTY, which saves the current address rather than overwriting AW (`W:202–204`). This covers repeated stalls and the final stalled-to-ready edge, not only the first low-ready cycle. It also removes the original repeated length reload, which could replace a full burst's AWLEN with the descriptor tail while stalled.

### Full/tail timing and address progression — accepted within assumptions

`wlast_valid` counts **accepted WLAST** (`wvalid && wready && last`), not FIFO pops. `need_more_wlast` includes the currently accepted last beat, while the registered count increments on that edge (`W:96–98,171`). Under the exercised always-ready, continuously supplied data path:

| Boundary | Relevant timing |
|---|---|
| First address | IDLE→SEND loads `num_wlasts = floor((length-1)/256)+1`; the initial AWLEN decision uses the descriptor directly, not the old count. |
| Nonfinal WLAST edge | RD_FIFO_WR_DEST chooses ADDR_SETUP; `wlast_cnt` increments and the address upper slice increments from `saved_awaddr`. The RD state's FIFO/valid gate suppresses the next data launch at this boundary (`W:142–148,180–182,305–307`). |
| Following address entry | ADDR_SETUP→SEND sees the **already updated** completed-burst count. `(wlast_cnt + 1) < num_wlasts` means the next burst is nonfinal, hence full. Otherwise it is the final tail. |
| Stalled request | Neither AW payload nor the scheduling decision is reloaded until a later distinct request entry. |

For 513 beats, the subsequent-entry counts are 1 and 2 with `num_wlasts=3`, giving 256,256,1 beats overall. For exact multiples of 256, assigning low-byte `length-1` into the 8-bit AWLEN yields 255 for the final full burst. Positive shorter descriptors use length-minus-one. These are source-timing conclusions corroborated by the native cases, not an exhaustive proof for every descriptor/state sequence.

With the unit's 512-bit data width, the unchanged increment is 16,384 bytes (`W:31–36`; `P:111–114`). Incrementing the address slice above bit13 while retaining low14 bits adds that amount, including for the tested nonzero low offsets. `saved_awaddr` is captured from the active burst in FIFO_EMPTY/RD_FIFO_WR_DEST (`W:202–208`). Address advancement happens at the completed nonfinal burst boundary, not repeatedly in SEND stalls. Full beats, compatible widths, stable descriptor ownership, correct incoming WLAST/packet markers, no address overflow and nonoverflowing burst counts are necessary assumptions; none is newly enforced by this patch.

## 3. Fixture and scoreboard quality

The DUT is the **complete donor writer**, not a reduced behavioral replacement. It uses actual `dma_pkg`, `dma_fifo_if`, PIM AXI interface/types/checker/log packages. The FIFO interface is real source; the FIFO **producer/storage behavior is synthetic**. Unit-only packages set two banks, 34 local-address bits, 512 data bits and 57 host/source-address bits; the umbrella header does not instantiate any PIM mapper. The FIFO/DUT parameter 514 carries 512 payload bits plus WLAST and packet-complete (`T:14–20,63–64`; `W:277–279`).

The checks are non-vacuous for the stated contract:

- Stimulus changes on negedge plus delay; handshakes are sampled on posedge before the DUT's nonblocking updates (`T:59–110`). This separates testbench driving from the edge being checked. The falling-ready test additionally observes the combinational withdrawal before the next rising edge; red02 is not a recorded lost accepted transfer.
- Expected AW length/address come from the descriptor and **scoreboard-announced** beat count, not DUT state or DUT counters (`T:88–95`). Expected burst count is independently computed with ceiling division. Duplicate addresses are rejected.
- Every accepted W beat is compared against the address-dependent payload for the **accepted W count**, with all strobes and expected WLAST checked. FIFO pops are separately counted and checked for empty access (`T:96–103`). Sharing the deterministic payload generator between injection and comparison is appropriate for transport preservation; it does not prove a physical memory operation or qualify the upstream reader's marker generation.
- A previous stalled cycle requires both retained AWVALID and equality of the **whole AW structure** on the next sampled edge, including the accepting edge (`T:80–85`). The saved record reports 87 exercised stalled-address cycles. The PIM checker is enabled by default and included by the actual interface, but is primarily an initialization checker, not a full AXI legality/4KiB/response checker.
- W count must reach the requested length, and AW count/FIFO-pop count must match before finishing. Extra or unaddressed W beats fail. A finite trailing quiet interval is monitored; local and global watchdogs prevent no-progress from becoming a pass (`T:98–112,127`). This is not an indefinite no-late-activity guarantee.
- `wr_fsm_done` is **not a pass criterion**. Every case keeps BVALID zero and separately records done-without-B (`T:50–51,104–115`). No completion scoreboard is being made green by feeding synthetic acknowledgments.

Coverage restrictions are material: WREADY is permanently high; FIFO data is continuously supplied until exhausted, and the final head is deliberately retained on empty. Each case resets the DUT, the descriptor remains stable, and only HOST_TO_DDR/INCR is selected. No W stalls, mid-transfer FIFO starvation, arbitrary empty-head behavior, descriptor turnover, back-to-back-no-reset or in-flight reset are exercised. The held final head enables the existing packet-complete logic to progress; it must not be mistaken for proof of real FIFO/drain semantics.

The three original runs demonstrate three distinct failures, but do **not** separately mutation-test each changed line. In particular, original failures occur before an isolated stalled-payload assertion failure; payload-hold acceptance rests on direct source review plus the candidate's repeated full-structure stall checks. This is adequate for the narrow result, not an exhaustive mutation campaign. Multiburst non-full tails in this suite are one beat; two- and 63-beat lengths are single-burst tests. General tail arithmetic is source-supported, while multiburst tails 2..255 remain an unexecuted coverage extension.

## 4. Native evidence reconciliation

Saved version logs identify **Questa Intel FPGA Edition 2024.3**, invoked under `/opt/altera/25.1/questa_fe`. Exact commands and native process identities are retained in each result. Each run has a distinct work directory and dispatch receipt. The finite existing runner was reused; no new execution framework or authorization gate is implied.

| Run | Input / selection | Retained observation | Native/effective command RCs | Outer RC |
|---|---|---|---|---|
| red01 | Original, `+ONLY=0` | Fatal cycle25: source waited for AWREADY before AWVALID | version/vlib/vlog/vsim all 0 | 1 |
| red02 | Original, `+ONLY=1` | Fatal cycle1: AWVALID followed ready low | all 0 | 1 |
| red03 | Original, `+ONLY=2` | Fatal cycle261: case2 burst1 expected256 beats, actual1 | all 0 | 1 |
| green01 | Candidate, no ONLY argument | Exactly one final unit-pass marker; all twelve case rows present | all 0 | 0 |

The runner scans full logs for fatal/error diagnostics and nonzero native error summaries before setting `unit_pass` (`run-native.py.in:102–120`). Consequently `$fatal` accompanied by native RC0 is correctly rejected. All three original results have diagnostics, no pass score and `unit_pass=false`; candidate diagnostics are empty and `unit_pass=true`. All retained runs report complete collection, no timeout, drained owned groups and unchanged original/input/tool identities. These are not masked native failures or reused candidate results labeled as original failures.

### Candidate rows independently parsed and aggregated

Patterns: 0 = ready waits for valid/age; 1 = initial ready drop after valid; 2 = always ready; 3 = periodic stalls.

| Case | Length, beats | Pattern | AW requests | Accepted W beats | Done without B |
|---|---:|---:|---:|---:|---:|
| 0 | 513 | 0 | 3 | 513 | 1 |
| 1 | 513 | 1 | 3 | 513 | 1 |
| 2 | 513 | 2 | 3 | 513 | 1 |
| 3 | 1 | 0 | 1 | 1 | 1 |
| 4 | 2 | 1 | 1 | 2 | 1 |
| 5 | 63 | 2 | 1 | 63 | 1 |
| 6 | 256 | 3 | 1 | 256 | 1 |
| 7 | 257 | 3 | 2 | 257 | 1 |
| 8 | 512 | 0 | 2 | 512 | 1 |
| 9 | 769 | 1 | 4 | 769 | 1 |
| 10 | 1024 | 2 | 4 | 1024 | 1 |
| 11 | 1025 | 3 | 5 | 1025 | 1 |
| **Total** | — | — | **30** | **5,448** | **12** |

The twelve unique IDs, lengths, patterns and individual burst/beat counts agree with the testbench and final scoreboard. Its additional totals are **5,709 monitored cycles, 33,284 checks and 87 stalled-address cycles**. Check accounting also reconciles to the source guards: 5,709 control checks + two checks per stall + four per AW + five per transported beat (one pop/four W checks) + fifteen falling-ready checks + two reached initial-valid watchdog checks + twenty-four final accounting/watchdog checks. The one-beat pattern0 case finishes before phase24 and does not execute that particular watchdog guard. These are monitored cycles/check invocations, not total elapsed reset-inclusive cycles or distinct formal properties.

The address formula produces aligned starts in the upper half of the 16GiB bank-local range, with alternating low offsets; all case extents remain within that range. It exercises preservation of bit33 and nonzero low offsets, not physical bank selection or high host-IOVA routing.

### Diagnostics

Candidate `vsim.log` ends **Errors:0, Warnings:4**: two vopt-13314 relaxed input-kind warnings for descriptor/csr_control and two vsim-8315 unique-case warnings at time0 before the first synchronous reset edge. `vlog.log` separately reports the same two input-kind sites as vlog-13314 (Warnings:2). Thus the final simulator summary is four, while six warning-line occurrences exist across the two stage logs; they are not six distinct defects. The originals show the same classes/sites, with the output-state case line shifted by the patch. No additional post-reset warning or candidate fatal is present. This accepts their observed unit context, not a global warning waiver or synthesis conclusion.

## 5. Residual findings and disposition

1. **High — response-drained completion is still false.** All twelve candidate cases assert `wr_fsm_done` while the test returns **no B responses at all**. `W:150–153,266,277–279,310–314` still bases retirement on the packet marker/WAIT state rather than successful response accounting. The observed `undrained_done_cases=12` is a retained defect, not a completion pass. Before integration use, repair truthful response/error/drain retirement and verify delayed, absent and error responses; do not treat done as buffer-reuse, bank-switch or DDR/host visibility permission. This finding does not reject the AW-only correction.
2. **High — W backpressure and real FIFO semantics remain unqualified.** Existing ready-dependent data/pop behavior is byte-unchanged (`W:221–261,274–279,305–307`). AW scheduling depends on accepted WLAST and correct interburst suppression; the entry/count reasoning above does not clear unsupported W/FIFO paths. Qualify repaired data flow with stalls at first/middle/final beats, interburst boundaries and FIFO starvation, using the bound real FIFO contract. No claim of correctness outside WREADY-high/continuous-input is made here.
3. **High — length, burst legality and platform binding remain open.** Counters remain nine bits against a twenty-bit length (`W:81–98,187`; `P:111–114`). The arithmetic-only nonoverflow bound is 511 bursts / 130,816 beats; 130,817 needs 512 bursts and truncates the stored count. This is not an accepted operating maximum. Zero length, overflow, boundary crossing and unsupported modes are not rejected by this patch. Large unit INCR requests do not prove AXI4 4KiB legality, host WRAP behavior or active PIM splitting/width conversion.
4. **Scope — no full-system or hardware acceptance.** Source-IOVA truncation, physical bank ownership/routing, mode lifetime and downstream visibility are not exercised. No DMA top, real host or DDR, AHLS workload, memory-array checker, mapped synthesis, fit/timing or hardware result is included. Unit-only geometry is not a generated active-platform binding. Independent fabric/reader review outcomes cannot be inferred from this acceptance.
5. **Coverage — retain the exact test boundaries.** Finite trailing observation, reset-per-case, one selected mode and the restricted tail distribution do not establish back-to-back descriptors, all alignments/modes/parameters or arbitrary sink/FIFO behavior. Expanding these tests can support subsequent work; it is not a reason to rerun the unchanged accepted AW package now.

## 6. Final disposition and report digest

Accept publication/reuse of the hash-bound **AW-handshake/payload/burst-scheduling source correction and native unit evidence with the findings above**. The three changes belong to one bounded AW scheduling repair, not a full engine replacement. Keep completion and integration gates open; no task transition or execution permission is granted by this report.

The frozen package was verified unchanged during review. Only `V/independent-review01.md` was written (early draft, then this final version). The **full-file SHA256 of this FINAL report is supplied in the delivery receipt after writing it**; it is deliberately not embedded in its own bytes, which would be self-referential. No hash exclusions or normalization are used.

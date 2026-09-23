# Independent DMA read-request handshake review

Status: **FINAL — ACCEPT the narrow source correction and completed read-unit old-fail/new-pass evidence, with the limits below.** An **IN_PROGRESS** draft was written before detailed verification and is superseded by this report.

## 1. Bounded verdict

No blocking defect was found in the **two changed next-state decisions**, under the existing stable-descriptor, valid-length and well-formed-response assumptions. The correction removes the premature ARREADY dependency, retains ARVALID and its payload through stalls, and makes advancement conditional on the actual request handshake without removing the two-request credit bound. The completed native pair supports acceptance/publication of that result: the original fails a real stalled-request assertion; the candidate completes all declared cases and payload checks with the same driver, dependencies and native tools.

This is **source + standalone read-unit acceptance only**. It is not acceptance of the complete DMA, generic AXI4 burst legality, the actual deployed PIM configuration, mapped synthesis, FIM integration, clocks/reset, host/DDR numerical behavior, physical storage or hardware operation. No writer, response-retirement, source-width or CSR repair is included. Prior donor findings remain open except for this specific read-request handshake defect in the candidate. DDR vendor simulation remains **SKIPPED BY USER**.

This review governs evidence acceptance/publication, **not a new execution-approval gate**. It neither requests an unchanged native rerun nor waits on the separate fabric review. Parent-owned publication/status updates may cite this report; the frozen files still saying “review pending” have intentionally not been edited here.

## 2. Scope, identity and independent checks

Paths used below:

- `N = /home/joe/Projects/Thesis/AHLS/new_bsp/new`
- `U = N/qualification/dma-read-handshake01`
- `S = N/afu/ahls_memory/dma`
- `R = U/inputs-candidate/dma_read_engine.sv`; `O` is the corresponding `inputs-original` file.
- `TB = S/tests/read_request_tb.sv`; `RUN = U/run-native.py.in`.

The supplied donor pin is `e0e07f7b1878a477dc4d1191918db8430193e148`. This local review verified retained source identities, not the remote repository or commit history. The earlier `qualification/ahls-memory-fabric01/DMA-DONOR-REVIEW01.md` was read for its already-established findings, especially §§4.3 and 10; no broad DMA re-audit was performed. The parent's supplied consumed/publication reference `e76531dc98b3d5903b6abdd50d1ffd5b573aa23f` is provenance, not a git state checked here.

### Checks actually performed

1. Recomputed the full-byte package SHA256, verified the declared **13 entries**, and checked every entry's exact size and SHA256. All matched.
2. Read both complete engines. Their complete textual diff exactly equals `S/patches/read_request_handshake.patch`; no other module changes are hidden in the candidate. The original also equals the retained donor file under `qualification/ai-suite-ofs-reference01/captures/source/agilex7/iseries_ofs_pcie/ip/dma/`.
3. Checked each variant's engine and **six actual dependencies** against `source-binding01.json`. Both copies of all six dependencies also match their ledger-listed local source origins. Read the actual DMA package/FIFO interface and PIM AXI interface/checker/types/logging package, rather than assuming interface names imply their behavior.
4. Reconciled all **10 input hashes per run** with the retained source/fixture bytes. The input name sets are equal and **only `dma_read_engine.sv` differs**. Native tool records, original Work21 source bindings and the four command argv lists match between attempts.
5. Parsed, but did **not execute or import**, the payload runners. Each runner is the frozen `.in` template with only its configuration substituted. Both full script hashes match dispatch receipts; every decoded source payload matches the corresponding native-result input hash. Expected totals in both configurations are 12 cases, 22 requests and 3,145 beats.
6. Recomputed size/SHA256 for all **four embedded full log texts per run**, parsed all case rows and final scoreboards, and independently reconciled diagnostics, status and metadata. All matched their records. Case IDs are exactly 0 through 11, in the declared order, without omissions or duplicates. Static arithmetic independently gives 22 requests and 3,145 payload beats from the driver lengths.

Only local file reads, static parsing/comparison and checksum/arithmetic calculations were used. No SSH, native tool/simulator execution, hardware access, source edits, git operations, task transitions or changes to the separate fabric package occurred. Only this review file was written. One initial read-only verification command had a Python syntax error before doing any work; the corrected command and subsequent cross-checks completed successfully. No verification blocker remains.

### Key full-file identities

| Artifact | SHA256 |
|---|---|
| `U/review-package01.json` | `7768d63c7e7cbc706c861721bef27f0469942d9e32c909134302718328a3e591` |
| `U/source-binding01.json` | `3ec016e711085a0065b834692efeb423e95edfc8712fb69b5f8d1d1c3e2d640d` |
| Original complete reader | `9383e34c8dfda15ea1d77a3b7cce37b9b6e3292e85a037001a1054ad8ed3c4b2` |
| Candidate complete reader | `dd50e2de9ab6139d93fc36b95e16f8ac2a9a1bd249384026bfe3944a55c00f6a` |
| Handshake patch | `b299f18437fbb4422eb2be1358e3927c8a138738ba9c9aefb55ac5cf5ecd0d31` |
| Testbench | `5eddfbb18f8b24f3529af5c973d58726e1d28b69439d3aa4de5d8419e84bd09b` |
| Native runner template | `39badc3892e52c3d8ea20deb3dbe989c296755d22fe5cbece6eac1f8a7f9ade5` |
| `U/result-red01.json` | `76e46b9bcebe123f796350858f3d686a6d394b38c05b84cbee705c4e1df506ea` |
| `U/result-green01.json` | `bd47c6c3bf9294d33692f0f13b9f11857b1d6d3dd1ed93ae7c32a06c7a769514` |

The source ledger retains all dependency origins/hashes; the frozen package retains the other report/dispatch/fixture hashes. This report's own full-byte SHA256 is returned in the final handoff after writing, not embedded recursively into its own hashed contents.

## 3. Source correctness: trace through the unchanged registers

### 3.1 Issue without requiring ready

`O:103–112` required ARREADY in ADDR_SETUP, before the registered ARVALID appeared, and then left SEND_RD_REQ without requiring its handshake. A sink permitted to wait for valid could deadlock that source, and a sink dropping ready after the setup observation could lose the request.

`R:103–115` now enters SEND_RD_REQ whenever `(rd_req_cnt - rlast_cnt) < NUM_PENDING_RDS`, with `NUM_PENDING_RDS = 2` unchanged at `R:35`. The registered `next[SEND_RD_REQ]` branch asserts ARVALID (`R:161–166`) independently of ARREADY. There is no new combinational valid-from-ready path.

### 3.2 Hold valid and payload while stalled

If the request is not accepted, `R:112` keeps next state SEND_RD_REQ. The sequential branch therefore keeps ARVALID asserted, retains ARADDR, and recomputes the same LEN/BURST/SIZE from unchanged request count, request total, descriptor and interface constants. Other AR fields retain their reset-established values (`R:127–179`). Neither the request count nor the address advances in this stall branch.

**Important precondition:** the descriptor length and mode remain stable while active. Those fields are not newly latched; LEN/BURST are still recomputed from the live descriptor. The unit holds the descriptor until completion. Acceptance is not a claim that arbitrary active-descriptor mutation is safe.

### 3.3 Advance only on handshake, preserving existing count convention

For a nonfinal accepted request, SEND_RD_REQ now reaches ADDR_SETUP only through `ARVALID && ARREADY`. On that edge the existing register branch clears ARVALID, increments `rd_req_cnt` once because the current state is SEND_RD_REQ, and advances ARADDR once by `ADDR_INCR` (`R:151–158`). Subsequent credit-wait cycles are ADDR_SETUP→ADDR_SETUP, so they do not increment either again. At the tested width/length parameters, `ADDR_INCR` is 16,384 bytes.

For the last request, the handshake selects CP_RSP_TO_FIFO and clears ARVALID (`R:113–114,169–170`). The donor **does not increment `rd_req_cnt` for that final request**; this convention is unchanged. It does not cause an extra issue because CP_RSP_TO_FIFO has no request-issue transition. The review does not promote that internal counter into a generally accurate externally visible total/outstanding counter.

### 3.4 Credit and response interaction

During request scheduling, `rd_req_cnt` accounts for accepted nonfinal requests, and `rlast_cnt` advances only on accepted RLAST (`R:86,139`). Before a new valid request is presented, the unchanged predicate permits fewer than two outstanding accepted requests. While a request is stalled, no second request can be launched; responses may only release credits. Accepting the pending request can bring the outstanding total to two, not above it. A response accepted while ADDR_SETUP is credit-blocked may cost a conservative extra cycle before issuing; this does not weaken the bound.

This reasoning assumes well-formed in-order responses, stable descriptors and nonoverflowing counts. It does not fix invalid lengths, unsolicited/malformed RLAST, RRESP handling or burst-counter overflow. The unchanged response/FIFO path and final packet tag were exercised by the unit, not redesigned (`R:117–123,139–141,173–175,183–210`).

## 4. Driver quality and exact exercised coverage

### 4.1 It is a real request/response test, not a pass-marker stub

- The entire read-engine module is instantiated (`TB:13–21`), with actual donor/PIM dependencies. Only the platform packages and umbrella header are synthetic: 2 banks, 34-bit local byte address, 512-bit data and 57-bit host/source address. FIFO payload width is explicitly 514 bits. No deployed width binding is claimed.
- Stimulus changes at falling edge plus a delay; handshakes are sampled at the rising edge before the DUT's nonblocking register updates (`TB:73–155`). FIFO checking observes the registered output pulse/data rather than assuming the response and FIFO pulse occur in the same cycle.
- The sink queues **only accepted AR requests**. It returns their expected beat counts in order, holds its response position until `RVALID && RREADY`, and derives every 512-bit payload from the accepted address and beat offset (`TB:93–103,122–136`). The separate FIFO oracle derives expected data from the descriptor base and FIFO index, so a misaddressed request is not silently blessed by matching the sink alone.
- Each preceding stalled request requires next-cycle ARVALID and exact equality of the **whole packed AR payload**, including the eventual handshake edge (`TB:110–115`). Every accepted request is checked for duplicate count, full address, LEN, SIZE and INCR burst type. Outstanding accepted requests are checked against two (`TB:122–132`).
- Every FIFO write is checked for bounds, full data, burst-last and packet-complete bits. Completion requires exact AR/R/FIFO counts, exactly one final marker, and an empty/inactive sink (`TB:138–153`). Per-case and global watchdogs prevent a hung source from reaching the final success print (`TB:157,173`).
- Positive stall and credit-block coverage is required. The real original assertion failure additionally establishes non-vacuity of the stalled-valid monitor. The original stops in the first case; it does **not** provide separate old-fail observations for all later schedules or for each patch decision individually.

### 4.2 Exact case matrix

Lengths are **beats**, not bytes. These are selected length/schedule pairs, not a full Cartesian cross-product.

| Case | Beats | Pattern | Accepted requests | Checked FIFO beats |
|---|---:|---:|---:|---:|
| 0 | 1 | 0 | 1 | 1 |
| 1 | 257 | 0 | 2 | 257 |
| 2 | 1 | 1 | 1 | 1 |
| 3 | 513 | 1 | 3 | 513 |
| 4 | 256 | 2 | 1 | 256 |
| 5 | 512 | 2 | 2 | 512 |
| 6 | 769 | 3 | 4 | 769 |
| 7 | 63 | 3 | 1 | 63 |
| 8 | 1 | 4 | 1 | 1 |
| 9 | 257 | 4 | 2 | 257 |
| 10 | 2 | 5 | 1 | 2 |
| 11 | 513 | 5 | 3 | 513 |
| **Total** | | | **22** | **3,145** |

Schedules (`TB:75–92`): pattern 0 first exposes ready then withdraws it for six sampled cycles when the first valid appears; pattern 1 waits for valid and its fourth observed valid cycle before ready; pattern 2 alternates ready; pattern 3 permits ready at phases 14–18 of a 19-cycle period; pattern 4 is always ready; pattern 5 initially withholds ready until phase 32 and then uses phases 3–6 of a seven-cycle period. All except pattern 4 also toggle the fixture's almost-full input. Pattern 1's completion cannot occur if the source waits for ready before producing valid; its explicit phase-24 check is additional coverage, not the sole liveness safeguard.

### 4.3 Scope limitations that remain material

1. **Not a real FIFO/writer/completion test.** `almost_full` is controlled stimulus, not occupancy from a real data FIFO. `wr_fsm_done` is supplied only after all expected R and FIFO beats plus a quiet interval (`TB:104–105`). The driver checks no early dequeue relative to this acknowledgment; it proves neither actual writer AW/W behavior nor B-response drain/host visibility.
2. **Not a high-IOVA/truncation repair.** The unit's source interface is explicitly 57 bits, bypassing the separate `dma_top` source-interface defect. Full-vector address comparisons are present, but the actual tested beat addresses span only `0x200004000` through `0x2000bc000`; bits above 33 are zero. This does not exercise preservation of host address bits 34–56, physical bank selection or a bank boundary.
3. **Not general AXI burst qualification.** Only DDR_TO_HOST/INCR is selected. The sink deliberately accepts donor-sized requests up to 256 beats and does not enforce the AXI4 4KiB rule. There is no host WRAP or actual PIM burst-conversion test. The retained PIM checker checks initialization of control/selected fields, not full protocol legality or 4KiB compliance; the driver's explicit checks supply the handshake evidence.
4. **Finite normal-response/reset coverage only.** Each case resets the unit and reinitializes the descriptor. There is no back-to-back-no-reset or in-flight-reset qualification, no invalid/overflow-length test, no R error/malformed-response injection and no arbitrary response-latency/interleaving campaign. The sink is delayed and in order. The reported cycles/checks are verification totals, not a performance result.

These limits are nonblocking for the stated two-decision correction and prevent expanding its acceptance into integrated DMA correctness.

## 5. Native evidence, diagnostics and metadata

The retained native tool version is **Questa Intel FPGA Edition 2024.3** under `/opt/altera/25.1/questa_fe`, not inferred from the directory name alone. Both runs use separate exclusive directories beneath `/home/uwb_student00/ahls/new_BSP/work_dma_read_handshake01/`, identical compile/simulation argv and identical tool records.

| Observation | red01 | green01 |
|---|---|---|
| Native version/vlib/vlog/vsim return codes | 0 / 0 / 0 / 0 | 0 / 0 / 0 / 0 |
| Per-command effective return codes | All 0 | All 0 |
| Functional result | `unit_pass=false` | `unit_pass=true` |
| Native simulation summary | 1 error / 3 warnings | 0 errors / 3 warnings |
| Completion scoreboard | None | Exactly one, all 12 cases |
| Outer status | **Not separately observed** | 0 recorded in parent comparison |
| Owned live groups after commands | Empty | Empty |

The red log contains `Fatal: READ_REQUEST_FAIL cycle=3 ARVALID dropped before handshake` at **85 ns**. This is the expected old-source functional failure, not a compile or library-setup failure. Native vsim returned zero despite the fatal because its finish behavior is not a reliable functional verdict. `RUN:103–112` separately rejects Error/Fatal diagnostics, nonzero error summaries and a missing/wrong scoreboard. Its final exit logic would reject this result, but that code inspection is **not** an observation of the red outer rc; the parent explicitly records null after the pane ended.

The candidate log reports:

```text
READ_REQUEST_UNIT_PASS cases=12 cycles=3931 checks=16955 requests=22 beats=3145 stalls=142 credit_blocks=2961
```

All 12 raw case rows match the table above. The final marker, decoded result scoreboard and parent scoreboard agree; there are no detected Error/Fatal diagnostics. Thus this is not acceptance from rc0, `complete=true`, or a success substring alone. The green outer rc0 is a retained parent observation, not a fresh process observation made by this reviewer.

Warnings are retained, not suppressed: default descriptor input-port kind **13314** appears at compile/optimization, and two unique-case warnings occur at **time zero** before synchronous reset. The native simulation summary remains **three warnings**, not warning-clean. The candidate shifts one reported source line because of the added comments/condition; the diagnostic class and time are unchanged.

Metadata records exact argv, command PID/start ticks, start/end times, no timeouts, empty residual groups and before/after preservation of the ten inputs, native tools and six prebound Work21 source files. Local checks verify consistency and hashes of these retained records; they do not independently re-observe the remote filesystem or processes. Work21 preservation is not proof that its generated PIM packages were compiled into this synthetic unit.

`RUN:5–36,54–85` retains exclusive directories, isolated environment, two-CPU affinity, a 16GiB **per-process** address-space limit and 120-second native-command deadlines. The finite child-group supervisor keeps the leader unreaped through natural helper drain and possible group signaling. No new generic runner framework or supervisor requalification is needed for accepting these completed logs, and none was created or executed here. These bounds are not an OS sandbox or aggregate process-tree memory guarantee.

## 6. Remaining disposition

- **Closed narrowly:** premature-ready request admission and unconditional SEND_RD_REQ advancement in the reviewed candidate; source identities and same-driver native old-fail/new-pass evidence are accepted.
- **Retained implementation prerequisites for later whole-DMA work:** writer handshake and multi-burst scheduling; truthful response/error retirement and CSR status; `dma_top` source-width truncation; stable descriptor/mode/bank ownership; actual PIM address/data/burst/ID/user/fence binding; FIFO integration, reset/drain and visibility contracts. These are the prior review's remaining work, not changes bundled into this patch or newly imposed launch approvals.
- **Evidence wording requirement:** publish the result as a standalone read-request handshake correction with retained warnings and synthetic platform/driver limits. Do not call it integrated DMA, mapped/FIM, DDR, numerical or hardware qualification. Preserve the original native-zero/fatal outcome and the unknown red outer status exactly.
- **Files changed by this reviewer:** only `U/independent-review01.md`, first as IN_PROGRESS and now FINAL. Original sources, candidate sources, testbench, runners, native results, the 13-file frozen package and the separate fabric review were not modified.

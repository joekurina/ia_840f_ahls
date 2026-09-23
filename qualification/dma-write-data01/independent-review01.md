# Independent review — DMA writer W-channel correction

Status: **FINAL — ACCEPT the bounded W-channel elastic-buffer/FSM correction and its completed native AW/W unit evidence. NOT whole-writer, DMA, completion, visibility, or deployment acceptance.**

An **IN_PROGRESS** report was written before detailed inspection. Specification compliance was reviewed first, followed by complete source delta, dependencies, test quality, and captured execution evidence. No blocking defect was found in the specified correction under its stated preconditions. Residual integration/completion blockers and nonblocking test limitations are below.

This is a local-only independent result review. No SSH, simulator/vendor execution, hardware access, implementation, git, or task transitions were performed. Python was used only for inert local parsing, comparison, hashing, and evidence arithmetic; captured payload runners were not imported or executed. Only this report was written. This verdict governs result acceptance/publication, not a new execution-approval gate. Prior AW and connected-fabric acceptance remain separate; neither is promoted by this review. DDR vendor simulation remains **SKIPPED BY USER**.

## 1. Specification compliance — PASS within the declared contract

Source references `C` and `B` below mean the complete `inputs-candidate/dma_write_engine.sv` and `inputs-baseline/dma_write_engine.sv` beside this report; `T` means `../../afu/ahls_memory/dma/tests/write_data_tb.sv`.

| Requirement | Independent finding |
|---|---|
| Existing output register becomes a one-entry elastic buffer | `C:197–212` updates WVALID only when the slot is empty or the current beat can be consumed. It loads data only on `rd_en`. There is no new secondary queue or unaccounted pop path. |
| Valid is not contingent on the sink first asserting ready | With WVALID=0, the slot is available regardless of WREADY; a nonempty input in a data phase is admitted and registered as valid. While WVALID=1 and WREADY=0, neither WVALID nor any W payload field is assigned. This is registered occupancy control, not a combinational ready-to-valid path. |
| Entire packed W remains stable while stalled | The bound PIM W struct has exactly data, strb, last, and user (`ofs_plat_axi_mem_if.sv:132–143`). Whole-struct reset and the common update enable preserve every field during a stall. Every admitted beat sets full strobe and zero user (`C:199–210`). |
| Pop only into an empty or simultaneously consumed slot | Both reachable data-state pop expressions require `not_empty & (!wvalid | wready)`; all other normal states default or explicitly set pop to zero (`C:214–273`). FIFO head capture and pop share that same edge and predicate. Thus an empty slot admits independently of ready; a stalled full slot cannot pop; a consumed nonlast slot may refill once. |
| No prefetch across buffered WLAST | Both expressions additionally require `!(wvalid & w.last)` (`C:246–256`), including the cycle in which WLAST is accepted. The last beat drains without replacement; the next burst cannot be prefetched behind it. |
| Burst phase advances on accepted WLAST, including empty/stall overlap | `wlast_valid = wvalid & wready & w.last` (`C:96`) is the sole normal exit trigger from RD_FIFO_WR_DEST (`C:125–127`). `need_more_wlast` includes the handshake on the current edge. FIFO emptiness and packet-complete no longer preempt this data-phase decision. A buffered last beat survives an input gap and advances the burst exactly when accepted. |
| FIFO_EMPTY / retained legacy-state behavior | All three next-state arms lead to RD_FIFO_WR_DEST (`C:121–123`); enum values are unchanged. NOT_READY and FIFO_EMPTY_NOT_READY have no normal incoming transition. On the reachable SEND_WR_REQ→FIFO_EMPTY edge the W buffer is empty; FIFO_EMPTY can load the first beat as it advances to RD_FIFO_WR_DEST, so a first/single-beat WLAST cannot be accepted prematurely in that bridge state. This reasoning assumes normal reset/state progression, not forced/corrupt states. |
| AW and out-of-scope logic preserved | The complete file-to-file diff is exactly `write_data_elastic.patch`. AW register/field generation, AWVALID control, burst-count widths, B/error logic, CSR/counters, and final WAIT→IDLE condition are unchanged apart from the intended data-phase/pop changes. Interburst entry timing is deliberately corrected by the W FSM; no accidental AW-field edit was found. |
| Packed FIFO layout retained | At the explicitly tested DATA_W=514, `[511:0]` is payload, `[512]` is WLAST, and `[513]` is packet-complete (`C:206–207,223`; `T:14–19,79–81`). Packet-complete still comes directly from the FIFO head, without validity qualification, and still controls WAIT→IDLE. It is not buffered retirement metadata. |

The pop expression depends on registered W state, current FSM state, and external ready/nonempty, not on next-state feedback. WVALID/data are registered, and next state depends on the accepted registered last beat. No internal combinational cycle or duplicate-pop mechanism was found in the complete writer. This is source reasoning plus selected native cases, not formal reachability or real-FIFO integration proof.

Preconditions remain material: positive representable/nonoverflowing length, aligned full-width data, a stable active descriptor, correctly tagged synchronous FWFT input, and the stated single-descriptor/reset setup. The retained module defaults are not a proof of arbitrary parameter combinations. Changes to state visitation do not qualify unchanged status/counter semantics.

## 2. Source and evidence identity — VERIFIED

The baseline is the **prior AW-corrected writer**, not pristine donor source. Its complete bytes match the prior AW candidate named in `source-binding01.json`. The underlying AI Suite pin remains `e0e07f7b1878a477dc4d1191918db8430193e148`; PIM files have their separate recorded local origins.

Independent local checks established:

- Exact expected review-package SHA256 and all **18** manifest entries' full-file hashes and sizes.
- Both complete writer copies, all **six** dependency copies in each input directory, and all six recorded dependency origins match their bindings.
- The generated complete baseline/candidate unified diff is byte-for-byte the supplied additive patch. No unreviewed tail or hidden source difference exists.
- Each of the three runner files is exactly the frozen runner template with its literal `C` configuration substituted. AST/literal parsing did not execute them. Their full hashes match the dispatch receipts.
- All **10** decoded input payloads per run match both their recorded hashes and the corresponding local complete source/fixture files. Only `dma_write_engine.sv` differs between baseline and candidate. Tool/INI identities, original-source identity maps, and version/vlib/vlog argv agree. Simulation selection intentionally differs: `+ONLY=0`, `+ONLY=2`, and all cases.
- All **four** complete embedded log texts per run reproduce their recorded byte sizes and SHA256 values. Result-file hashes match the outer receipts and frozen manifest. Unique dispatch/result/outer-buffer identities are retained.
- Captured commands record native/effective zero, no timeout, no remaining owned group, and unchanged tools/inputs/originals. These are reviewed retained execution records, not a new observation of the remote machine.

### Full-file SHA256 bindings

| Artifact | SHA256 |
|---|---|
| `review-package01.json` | `5d8c187294b98ee1e19b011b0e8f9337e9ef491f6b2bd3a38b3bc3674191ee3d` |
| Complete baseline writer | `ec1483378ff7e3ce448bd92ff16ebc175831ac640dbae01dcb79b8924228e5f2` |
| Complete candidate writer | `c6c4e1c4f9a8678d7a9dc64d22bfe1de663daeffdc12998dfe04ac930e9dcf8c` |
| `write_data_elastic.patch` | `d1c701db8e2addef179e301dbb816e5bc442c9a2d23d47dc0e7ce6b17baf1010` |
| Complete `write_data_tb.sv` | `e80966cf18d003b3f9446120174916ae37bdd852dad1908697a77b26858358f0` |
| `source-binding01.json` | `8632139f60447367575f20606b38284fa134880cb6516a12f4e225cb28d9c868` |
| `run-native.py.in` | `e68688d94f53e44ada6c2073f073cafdd1a7266bbead4d846b73bf9da5d969ed` |
| `result-red01.json` | `95d9d16f398f239ffc5b12153ab598ffa4c60cba5a9f7a496cf9263625e4c81a` |
| `result-red02.json` | `45fe8353acd6d7c2fbb0115d317f32f7cdbc29d3b6f736eaab2a8bdc4427e983` |
| `result-green01.json` | `97eb03a2407ccf95a59a894d6e0fcd91a8fb6c3d93bd69239161dcb61a874d15` |

The final full-file SHA256 of **this report** is supplied separately in the review handoff after writing it; it is not embedded recursively in its own hashed bytes.

## 3. Native results and warning reconciliation

The retained version logs identify Questa Intel FPGA Edition 2024.3 under `/opt/altera/25.1/questa_fe`. All three runs used fresh distinct work directories. The unchanged finite supervisor retains two-CPU affinity, a 16GiB **per-process** address-space limit, 120s/native-command deadline, and preflight resource checks; these are not an aggregate-memory sandbox claim.

| Run | Actual functional evidence | Native vsim / outer exit | Final vsim summary |
|---|---|---|---|
| red01 | `WRITE_DATA_FAIL cycle=81 source waited for WREADY before WVALID` | 0 / 1 | 1 error, 4 warnings |
| red02 | `WRITE_DATA_FAIL cycle=284 extra/unaddressed data` under case2's stalled boundary plus input gap | 0 / 1 | 1 error, 12 warnings |
| green01 | Exact full scoreboard and case IDs 0–11 present | 0 / 0 | 0 errors, 4 warnings |

All version/vlib/vlog native commands also returned zero. The two baseline failures occur in simulation, not compilation. Native zero is **not** treated as a pass: the runner rejects fatal/error diagnostics and requires a complete scoreboard. The red02 mechanism is consistent with `B:121–148`: while FIFO_EMPTY_NOT_READY holds the stalled last beat, the accepted last can be consumed without the missing next-address transition, unlike the candidate's single data-state handshake rule.

Candidate totals verified against the exact raw marker and parent record: **12 cases, 10,060 checked cycles, 53,382 checks, 30 AW requests, 5,448 accepted checked W beats, 97 AW-stall cycles, 2,832 W-stall cycles, 2,592 input-gap cycles, and 12 done-without-B cases**. Independently parsed per-case lengths/requests/beats agree and sum to the request/beat/done totals. The cycle/check/stall totals are the testbench's captured counters, not independently reconstructed waveforms.

Warning accounting is stage-specific, not a broad waiver:

- Every vlog log reports **0 errors / 2 warnings**, both relaxed input-port-kind 13314 for descriptor and csr_control. The same two port diagnostics recur as vopt warnings inside vsim; they are not four distinct source defects.
- Green01 and red01 vsim each contain those two port warnings plus two 8315 unique-case warnings at **time 0**, in the next-state/output-control blocks (`C:107,226`; `B:107,281`). Uninitialized state before the first synchronous reset explains their time-zero scope; no later candidate occurrence is present in the captured run. This does not qualify in-flight reset or every initialization environment.
- Red02 vsim additionally has **seven** post-reset 8315 occurrences and **one** 8360 overlap at **2705–2765ns**, in baseline AW-register/status blocks (`B:172,337`). The AW-register unique case lacks a FIFO_EMPTY_NOT_READY arm, and the status case mixes a current-state arm with next-state arms (`B:351`), consistent with the observed incomplete/overlap diagnostics during that excursion. They are real retained baseline warnings, **not all initialization noise**. The candidate avoids the legacy states on its normal path; no global waiver or claimed repair of the unchanged status block follows.

## 4. Test quality — adequate for this bounded verdict

The test instantiates the **complete writer** with actual DMA package/FIFO interface and PIM AXI interface/checker/types/logging, not a translated behavioral writer. Configuration/umbrella files and the synthetic FWFT producer are explicitly fixtures. The actual PIM checker principally checks unknown controls/selected fields; it is not a complete AXI transaction/protocol checker (`ofs_plat_axi_mem_checker.vh:11–165`). The custom scoreboard supplies the relevant handshake/data assertions.

Strengths:

- Descriptor-position oracles check every accepted AW address/length/size/type and W payload/strobe/last; expected data is not derived solely from the candidate's AW. Each payload lane is address-dependent (`T:31–34,115–129`).
- Whole packed AW/W payload and valid persistence are checked across stalls. Pop from empty and pop-minus-accepted outside `[0,1]` fail (`T:96–131`).
- Ready-waits-for-valid, boundary/final stalls, periodic W stalls/input gaps, concurrent AW stalls, short/full/multiple/tail bursts, and the specific empty-input/stalled-WLAST overlap are exercised. Case2 sets a 12-cycle input gap after a boundary pop with a six-cycle W stall (`T:64–78`).
- All cases have finite per-case/global watchdogs, request/pop totals, and an eight-cycle quiet observation window. Reset and stimulus are away from the active sampling edge; the scoreboard samples the pre-NBA handshake values.
- Done does **not** control success: completion is based on accepted AW/W accounting. The no-B observation is separately printed rather than hidden.

Nonblocking limitations / actionable follow-up:

1. **Per-case outer acceptance is not a positive control.** `run-native.py.in:111` requires positive AW stalls, W stalls, and FIFO gaps for every selection. Case0 has no FIFO gaps by construction; case2 sets AWREADY continuously high. Therefore their individual `+ONLY` invocations cannot pass that aggregate coverage gate even with corrected RTL. This does **not** invalidate the retained baseline failures: both have explicit, independently verified `$fatal` diagnostics, and candidate all-case execution includes both scenarios. If isolated positive runs are used later, make coverage expectations selection-aware; never cite outer=1 alone as proof of the RTL failure.
2. The `[0,1]` accounting bound does not by itself forbid a single next-burst prefetch while last is buffered; the source's explicit guard establishes that stronger property here. A direct no-pop-while-buffered-WLAST assertion would improve future mutation coverage. Accepted WUSER=0 is source-checked, while the test checks its stall stability/knownness rather than a separate accepted-value oracle. Neither omission exposes a contradiction in this candidate.
3. Cases are selected length/pattern pairs, not a Cartesian or randomized proof. The test is not throughput evidence. Its quiet window cannot establish absence of arbitrarily delayed activity.

## 5. Residual findings and broader-acceptance blockers

**R1 — Retained completion failure; blocks whole-writer/transport acceptance.** No B responses are supplied (`T:53–54,147–149`), yet done is observed in all 12 candidate cases. `C:260–262` asserts done by WAIT state alone, and `C:129–132,223` still uses unqualified FIFO-head packet-complete to return idle ahead of response retirement. The model retaining the last head after empty is an explicit assumption, not proof about the real FIFO. Before broader acceptance, bind truthful accepted-request/response/error/drain accounting and active descriptor/mode/bank lifetime to an actual response model. AW/W success cannot authorize buffer reuse or establish visibility.

**R2 — FIFO/platform/protocol integration remains unqualified.** No actual FIFO, mapper, bank selector, memory, or host transport is instantiated. Only HOST_TO_DDR/INCR is tested, with a sink accepting large bursts; 4KiB legality and actual PIM/host WRAP adaptation are not qualified. The fixture declares two banks, 34-bit local addresses, 512-bit data, and a 57-bit source/address interface. Exercised beat addresses range from `0x200004000` to `0x2000c4240`: upper-half offsets within a 16GiB region, but **bits 34–56 are all zero**. This is neither high-IOVA preservation nor physical bank-mapping evidence. Resolve these boundaries in their own source-bound integration work, not by broadening this result.

**R3 — Existing donor lifecycle/arithmetic/status hazards remain open.** Invalid/overflowing lengths and 9-bit burst counts, malformed tags, response errors/IDs, busy/status/counters, CSR/descriptor lifetime, back-to-back descriptors without reset, and in-flight reset are not cleared. Reuse `../ahls-memory-fabric01/DMA-DONOR-REVIEW01.md` for the existing broader findings; this review does not repeat or supersede that audit. Mapped synthesis, connected AHLS/OPAE/DDR behavior, timing, hardware correctness, and visibility still require their own evidence.

**Disposition:** publish/accept this exact source-bound **W-channel correction and AW/W unit result**, retaining the warnings and residual findings. No corrective source change or unchanged native rerun is required by this bounded review. Do not label the writer/DMA qualified, apply the patch to live/maintained source, or deploy on the strength of this verdict alone.

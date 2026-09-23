# Writer-local response retirement — independent review

Status: **FINAL**

**Verdict: BOUNDED ACCEPT for the final writer-local correction and publication of the preserved finite native results, with the coverage limitations below.** No blocking implementation defect was identified within the stated valid-descriptor, same-ID/in-order response contract. This is not exhaustive spec proof, full-DMA/hardware acceptance, acceptance of prior independent handoffs, or launch authorization. Parent publication verification remains separate.

Review was local source/evidence inspection and read-only hashing/parsing only. No simulator/vendor execution, SSH/device access, implementation edits, git changes, or task transitions; this report is the sole modified file.

Paths below are relative to `new_bsp/new`: **B** = `qualification/dma-write-response01`; **S** = `afu/ahls_memory/dma`; **RTL** = `B/inputs-candidate02/dma_write_engine.sv`; **TB** = `S/tests/write_response_tb.sv`. JSON citations identify exact keys where embedded logs occupy one long line.

## 1. Bounded spec compliance — checked first

|Requirement|Independent source/evidence assessment|
|---|---|
|Accepted AW and credited B counted separately; invalid replies cannot consume valid credit|RTL:81–120,125,129 uses separate 9-bit counters, ID-zero, outstanding accepted AW, and accepted-or-same-edge WLAST. Separate increments preserve AW/B overlap. Credited non-OKAY replies retire bus credit while setting sticky failure; EXOKAY is not success. Cases4–9,13–14 cover the enumerated errors, not every duplicate pattern.|
|Success only after retirement, with no hidden current error|RTL:99–101,163–165,294–296 requires expected AW=WLAST=B, no buffered WVALID, final-wait state, and neither sticky nor current bad response. FIFO packet-complete is absent from the success predicate; its remaining functional read only feeds debug-close logic (256–257,383–388). Completion-edge fault rejection is source-inspected, not directly exercised; see R1.|
|Early faults do not abort the current descriptor|RTL:117–118 captures faults in every phase; data/address transitions at147–165 continue until the accounted descriptor drains. ERROR then holds without done (167–170,300–304). Missing valid replies can leave the writer waiting indefinitely, intentionally.|
|Sticky clocked status, retained ownership and no dispatcher-reset replay|RTL:103–119,253,300–304,313–325 implements module-reset-only sticky clearing and busy while active/ERROR. The ERROR state cannot be exited by `reset_dispatcher`. TB:185–208 observes error drain/hold and no done while input is re-offered with dispatcher reset (91–93); this is a finite local observation, not live recovery proof.|
|Narrow source delta|The final patch reconstructs the exact final RTL from the recorded AW+elastic-W baseline in memory. It changes retirement/error/busy handling and the legacy chained idle assignment to explicit zero (RTL:186–188), not AW/W payload scheduling or geometry. The entire candidate01→02 diff removes the raw `response_bad` OR from `wr_rsp_err`, leaving clocked `response_error` (RTL:253; `source-binding02.json:4–6`).|

Counter-width correctness is conditional on valid lengths needing at most 511 bursts; the native tests reach only 5 bursts. The 20-bit descriptor field is not thereby qualified (`inputs-candidate02/dma_pkg.sv:111–114`; RTL:81–89,200). Sticky error is **not permission to release host buffers**: current-descriptor AW/W/B traffic intentionally continues after early error.

## 2. Completed native evidence — independently reconciled

|Attempt|Exact observed result|Native / outer|
|---|---|---|
|red01, AW/W baseline, `+ONLY=0`|Fatal cycle 541, 5465 ns: `premature done before response retirement`|Four commands 0 / 1|
|red02, same baseline, `+ONLY=4`|Fatal cycle 266, 2716 ns: `response error was not latched`|Four commands 0 / 1|
|green01, first response candidate|Fatal cycle 606, 6116 ns: `spurious response error`|Four commands 0 / 1|
|green02, final candidate, all cases|16 case rows and one complete PASS scoreboard|Four commands 0 / 0|

Primary citations: `B/result-{red01,red02,green01,green02}.json` keys `commands`, `logs.vsim.log.text`, `diagnostic_errors`, `scoreboards`, `unit_pass`; corresponding `outer-*.json` keys `observed_outer_rc`/`result_sha256`, and `dispatch-*.json` keys `pane`/`script_sha256`. Native zero is **not** mistaken for functional success. Final vsim summary is 0 errors/4 warnings; failed simulations each 1 error/4 warnings. The four final simulation warnings are two 13314 port-kind and two time-zero 8315 unique-case warnings; vlog separately reports 0 errors/2 warnings. No suppression flag is present.

Independently verified:
- Frozen manifest SHA and all 25 listed file sizes/full hashes; all 16 embedded log byte lengths/full hashes; all four dispatch runner hashes and outer result bindings.
- All 40 embedded runner source payloads against the actual local inputs/test files; exactly 10 inputs per run, only writer RTL varies. Same compiler argv, tool/original hash maps and nonwriter sources; only the stated red case-selection plusargs differ. All runner bodies match the frozen template outside literal configuration.
- All 16 commands have native/effective 0, no timeout or surviving owned group, and recorded input/tool/original preservation. These are reviewed completed-run receipts, not a new live process audit. Tool identity is Questa Intel FPGA Edition 2024.3 under `/opt/altera/25.1`; owned dispatch windows are 197–200. The finite 120s-command/2CPU/16GiB-process supervisor is preserved (`run-native.py.in:9–21,49–85,88–121`).
- Native case rows exactly match `cases02.json`; parsed totals match `parent-verification01.json`: **11059 cycles, 75576 checks, 42 AW, 7500 W beats, 44 physical B = 41 credited + 3 injected invalid**, 7 success/8 error-hold/1 missing-hold, 5 AW/B overlaps and 5 successors without reset. Case 15 finishes the simulation with one outstanding transaction: 128 completed-data observations are a hold test, **not completion/drain success**.

`GREEN01-FAILURE.md:3–7` is consistent with the observed assertion and exact one-line correction: after accepting B, counter updates can make the still-present raw response look uncredited between edges. Removing that raw expression from status avoids a false post-edge report while preserving synchronous error capture and the current-bad completion gate. This remains a source/timing explanation; no waveform was captured.

## 3. Source/test quality and unresolved findings

The test instantiates the complete writer and actual DMA/PIM interface/package/checker sources, not a rewritten writer model (TB:14–20). Stimulus changes away from the sampling edge. It independently checks every accepted AW address/length/ID/size/burst, W payload/strobe/last, whole packed AW/W stall holding and FIFO-pop minus accepted-beat occupancy0..1 (TB:126–168). Data expectations derive from independent base+index, not DUT address. Empty FIFO data is zeroed (88–95), defeating retained-end-tag completion. The two red tests are useful negative controls on the identical final testbench.

**R1 — Directed edge/phase coverage remains open (nonblocking for these finite results).** Normal B scheduling depends on previously observed `wbursts` (TB:104–123); there is no explicit first-credit B/WLAST-same-edge stimulus. All three invalid injections occur before descriptor completion, so an extra/error B precisely on the otherwise-successful completion edge, or an idle-phase stray B, is not directly tested. The current-bad gate/all-phase latch is source-compliant, not dynamically proven for those edges. Busy checking is concentrated after data completion (190–193), not every active cycle. Action: keep those claims source-inspected, or add separately scoped directed cases plus per-cycle active-busy and invalid-credit assertions before claiming comprehensive coverage. No rerun or new launch is requested by this review.

**R2 — Length/response-domain limits remain open.** Tests cover 1–1025 beats, at most 5 bursts; they do not prove the 511-burst boundary, overflow rejection or the full descriptor-length domain. Aggregate same-ID counters also cannot identify a duplicate substituted for another outstanding valid response (RTL:94–101). Action: retain the valid-length/in-order-response preconditions explicitly; qualify counter boundaries and enforce unsupported-length rejection before broadening deployment claims. Do not describe cases 7–9 as universal duplicate detection.

**R3 — Integration/ownership semantics remain unqualified, as already disclosed.** Synthetic2-bank/34-bit-local/512-bit-data/57-bit-address configuration, FWFT input and B sink are not the real reader/BRAM FIFO/PIM path (`tests/unit_platform_pkg.sv:1–9`; TB:14–20,67–69). Reader acknowledgment is indeed tied to done at `qualification/dma-read-handshake01/inputs-candidate/dma_read_engine.sv:201–203`; the acquired wrapper wires reader/writer and actual BRAM FIFO at `qualification/ahls-memory-fabric01/dma-extra-source01/ip/dma/dma_engine.sv:47–100`, but neither is instantiated here. Action: retain separate integration obligations for failed-descriptor ownership, software error/cancel/fence, response origin and safe global drain/reset. A sticky error is not quiescence; module reset is not qualified recovery; a successful B is not physical DDR visibility or PCIe posted-write completion.

HOST_TO_DDR/INCR only. Host WRAP, high IOVA bits 34–56, 4KiB conversion, malformed data, real widths/bank selection and system behavior remain outside this verdict (`RESULTS02.md:59–65`). Error reset testing spans a 10-observation terminal window, with `reset_dispatcher` asserted only after its first two observations—not ten full observations with reset asserted (TB:91–93,192–199). Prior AW/W/reader/fabric reviews remain independent. DDR vendor simulation is **SKIPPED BY USER**; no hardware claim is made.

## 4. Full-file SHA256 bindings

|Artifact|SHA256|
|---|---|
|`B/review-package01.json` (25-file frozen manifest)|`79a9c72d21153fef8079fce2d10f05bfd3d3decdf4f078a0c3118419c7b82192`|
|`B/inputs-baseline/dma_write_engine.sv` (AW+W candidate, not pristine donor)|`c6c4e1c4f9a8678d7a9dc64d22bfe1de663daeffdc12998dfe04ac930e9dcf8c`|
|`B/inputs-candidate/dma_write_engine.sv` (failed, retained)|`bf42ac45289f8532ea629fb25e5d3c8d3e5c2f6cb2882bd99cab516308b67967`|
|`B/inputs-candidate02/dma_write_engine.sv` (accepted bounded candidate)|`fb2d589ddd54a26ef9237eb7b38a490d0b5096b7b648b82dcba97462db7fe14b`|
|`S/patches/write_response_retirement02.patch`|`4540bf29819a2e1842c91497fbf6e22ac8bb989475f3dfd2116180732815840e`|
|`S/tests/write_response_tb.sv`|`4a415334d1045ea9c5270df3340f7be17c8a01bd3cae1e9581590b34b201283c`|
|`B/result-green02.json`|`68ee911d8dbab12d9068e99d1b523e66c789653366b26e309465156a8cf9c1d5`|

The final patch is relative to the AW+elastic-W baseline, **not** donor pin `e0e07f7b1878a477dc4d1191918db8430193e148`; the unsuffixed response patch remains failed history. All other frozen artifact hashes are in the verified manifest. This completed report's own full-file SHA256 is returned in the handoff, outside the file to avoid a self-referential checksum.

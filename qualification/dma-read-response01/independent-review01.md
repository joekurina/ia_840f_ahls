# Independent review — DMA read-response correction and paired native evidence

**Status: FINAL**  
**Verdict: PASS — bounded read-response error/retirement correction and completed baseline-fail/candidate-pass native evidence. No blocking finding within the stated contract.** The coverage notes below remain open; this is not exhaustive protocol proof, system/hardware acceptance or launch authorization. Parent result acceptance and publication remain separate.

An early IN_PROGRESS draft preceded this final report. Review used local source/evidence inspection and read-only hashing/parsing only. No SSH, vendor/simulator execution, hardware access, implementation edits, git operations or task transitions were performed. Only this report was written. Both runner configurations were AST/literal-decoded, never imported or executed; patch replay occurred entirely in memory.

Paths are relative to `new_bsp/new`: **R** = `qualification/dma-read-response01`; **S** = `afu/ahls_memory/dma`; **RTL** = `R/inputs-candidate/dma_read_engine.sv`; **TB** = `S/tests/dma_read_response_tb.sv`; **WR** = `R/inputs-baseline/dma_write_engine.sv`. JSON citations identify keys where native logs occupy long lines.

## 1. Bounded specification compliance — checked first, PASS

Read `SCOPE.md`, `RESULTS01.md`, `source-binding01.json`, `parent-verification01.json` and `cases01.json` before assessing source/test quality. The applicable contract is valid supported descriptors and same-ID, ordered, correctly sized read replies, not arbitrary AXI traffic.

| Requirement | Independent assessment |
|---|---|
| Capture accepted non-OKAY RRESP, including nonexclusive EXOKAY | RTL:73–86 defines bad as `rvalid && rready && resp != OKAY`, synchronously sets the sticky error, and captures the code only while the prior sticky bit is clear. Reset has precedence. Ordinary OKAY responses and descriptor boundaries do not clear either register. TB:134–141,203–209 checks the accepted first code after NBA and on subsequent monitored cycles. |
| Continue valid current-descriptor traffic after an early fault | The five-hunk patch changes only error capture/status and IDLE/WAIT/ERROR retirement control. RTL:121–137,148–202 retains the baseline AR scheduling, two-pending-request limit, RLAST accounting and FIFO datapath. No early abort, forced reset or cancellation is added. Read-error cases transfer all expected R/W beats and requests. |
| Retain descriptor ownership and suppress retirement | RTL:223–225 rejects ack for either sticky or current accepted bad R; this also prevents the actual-edge descriptor counter increment at246–247. RTL:139–144 selects ERROR rather than IDLE after writer-local done and makes ERROR absorbing. Busy remains asserted outside next IDLE (239–255); stopped-on-error is asserted in ERROR (228–231). |
| Guard a fault in IDLE | RTL:115–118 prioritizes sticky/current fault over descriptor go. This branch is source-compliant but not directly exercised with a stray idle reply; it does not qualify unsolicited-response handling. |
| Preserve distinct write-error/missing-B outcomes | WR:99–101,163–170,294–295 requires drained credited replies and no write error for done. A read error plus write error therefore leaves the reader in WAIT with sticky read status while the writer holds ERROR. Missing B leaves the reader waiting, even after data transfer. Neither outcome is misclassified as successful retirement. |
| Preserve successful operation and the earlier counter fix | Good cases0,1,10,11 retire once with model-memory comparison; cases1 and11 follow good predecessors without module reset. TB:179–184,209 checks the actual ack and counter. The baseline exactly matches pair02; only the reader differs between this red/green pair. |
| Keep error separate from drain, visibility and recovery | Bad data is deliberately forwarded; the failed descriptor result must be discarded and buffers kept pinned. Sticky status is not global quiescence, a fence, safe unpin or reset permission. Fixture module resets between error cases are not qualified live recovery. |

## 2. Completed native pair — independently reconciled

### Identity and execution evidence

- Verified the full SHA256 of the frozen **14-entry** manifest and every listed byte size/hash, including a final preservation recheck. No mismatch was found.
- Verified **13 decoded source/test payloads per runner** against local files and result input maps. `inputs-candidate/` contains only the changed reader; the baseline test copy equals the maintained additive test. The **12 non-test baseline inputs** match pair02's result bindings exactly. Both complete runner bodies reproduce `run-native.py.in` after literal configuration substitution; configurations differ only in run identity and reader source bytes.
- Verified both dispatch script hashes, outer receipt result hashes, and all **10 embedded native log** byte lengths/full hashes. Native argv, tool maps and original-file maps are identical across the pair. Tool/original maps also equal pair02. These are verified retained receipts, not a new remote-host audit.
- The actual donor `dma_engine.sv` and actual PIM `ofs_plat_prim_fifo_bram.sv` match their bound originals byte-for-byte. Wrapper lines47–101 wire real writer done, reader ack and the 32-entry FIFO; the FIFO instantiates installed `scfifo` with a registered output and active wrapper overflow/underflow assertions (FIFO:38–99). All literal includes resolve within the bound inputs; no substitute `module scfifo` exists there. `vdir` lists `MODULE scfifo`, and simulation uses `-L altera_mf_ver`. The optimized log does not contain a separate scfifo load line; identity rests on source composition and bound library/mapping evidence, not an invented load trace.
- The installed modelsim.ini and **6-file / 2,652,245-byte** `altera_mf` library remain exactly pair02-bound. Version output identifies Questa Intel FPGA Edition2024.3 under `/opt/altera/25.1`.
- The retargeted runner preserves the prior 120-second command deadline, 2-CPU affinity, 16-GiB per-process address-space bound, exclusive fresh directory, memory/disk and no-concurrent-native-tool preflight. Its only non-retarget addition is the durable unique result-SHA tmux buffer. All ten command receipts show native/effective0, no timeout and no surviving owned group; input/original/tool preservation is true. This is not an aggregate-memory or OS-sandbox claim.

| Attempt | Native result | Native/effective vs outer |
|---|---|---|
| red01, tmux `@205 %205` | Two good cases, then fatal at monitored cycle909 / simulation time9276ns: `accepted bad read response was not latched`; no PASS scoreboard; final1 error/9 warnings | All five steps0 / outer1 |
| green01, tmux `@206 %206` | All16 case rows, one exact full PASS scoreboard, read-error/almost-full coverage marker, final0 errors/9 warnings | All five steps0 / outer0 |

Sources: `result-{red01,green01}.json` keys `commands`, `logs`, `diagnostic_errors`, `scoreboards`, `unit_pass`; `dispatch-*.json`; `outer-*.json`. Baseline native zero is correctly rejected by the fatal-aware functional verdict; it is not silently converted into a native nonzero result.

### Candidate accounting and coverage

Independently parsed native case rows equal `cases01.json` exactly, with unique IDs0–15. Programmatic sums equal the parent verification and the independently parsed native scoreboard:

- **16 cases; 17,508 monitored cycles; 229,774 checks; 40 AR / 40 AW / 6,800 R / 6,800 W / 37 B.**
- **4 success / 10 terminal-error holds / 2 missing-B holds.** Successful cases are0,1,10,11. Read-only terminal errors are2–9; case12 is write-only error; case15 combines read and write errors in one descriptor. Cases13/14 withhold B, with case14 also carrying a sticky read error. Ten cases accept a bad read response; these classifications intentionally overlap.
- All6,800 transport beats are checked through the R-driven enqueue, real FIFO dequeue and W destination path. Only the four successful descriptors additionally qualify **1,796 model-memory copyback beats**. Failed/held traffic is not successful computation.
- First-beat SLVERR, middle-beat SLVERR/DECERR, final-beat EXOKAY/DECERR and a single-beat SLVERR are present (TB:63–70,104–105). Case7 accepts an initial SLVERR and later DECERR while retaining SLVERR as the first code. EXOKAY is also exercised at the first beat in case9.
- Read/write stalls are **6,062 / 9,878 cycles**, maximum R-minus-W is**34**, and FIFO almost-full is observed**6,463 cycles**. TB:225 now requires `max_buffered >= DMA_DATA_FIFO_DEPTH` and nonzero almost-full observations, addressing predecessor integration-review Q1 for this new test without modifying the frozen prior test.
- Accepted full57-bit AR/AW comparisons exercise upper host-source bits in eight cases and upper host-destination bits in eight cases. The checks include lengths, size/ID/burst metadata, strobes, data, last/packet markers, packed stalled AR/AW/W payloads and pipeline occupancy.
- Terminal errors are observed for ten cycles. Each missing-B case ends after128 completed-data observations with replies still outstanding; the fixture resets before the following case. That is a bounded hold observation, **not recovered/drained hardware**.

### Diagnostics

Green's final simulator summary is **0 errors / 9 warnings**: five13314 relaxed-input-port-kind sites and four8315 unique-case warnings, all four at time zero before synchronous state initialization. Vlog separately reports0 errors/5 warnings at the same port-kind sites; vopt repeats them. This is not fourteen distinct design-warning sites or a warning-free result. No later unique-case warning, FIFO assertion failure, suppression option or native error appears in the retained green logs.

## 3. Source/test quality and findings

**Source quality — PASS in scope.** Exact in-memory replay of `read_response_retirement.patch` reconstructs the candidate from baseline SHA `7433c99064fcd9b2b07cd86edc1b1d4d2a02019af041e1c5bc7ccae4079f6cf6`, with no extra delta. The baseline contains no RRESP use and has no active ERROR transition; the added latch and retirement guard directly address the red failure. The patch is additive after the prior AR-handshake and descriptor-count corrections, not standalone against pristine donor RTL. Scheduling/counters remain unchanged except for fault-dependent retirement, and status uses the clocked first-error state rather than raw current-response status.

**Test quality — PASS for the finite claims.** Drivers change away from posedge; handshake accounting is sampled before NBA and sticky status/counter checks after NBA. Expected payloads derive independently from source base, beat index and case identity, not only DUT-observed addresses. The actual reader/FIFO/writer linkage is exercised. Successful retirement requires complete R/W/B/enqueue/dequeue accounting, local empty-pipeline predicates, one ack and model-memory comparison. Error cases keep offering the descriptor, check sticky code/busy/no ack each monitored cycle after the fault, and preserve descriptor counts. Red and green use the identical final test, making the negative control causal rather than a changed-test comparison.

**Q1 — Nonblocking directed-edge coverage limitation.** Idle stray R and a new bad R exactly coincident with otherwise-successful writer done are not explicitly driven. Their priority/no-ack logic is source-inspected only (RTL:115–118,139–144,223–225). Under the valid current-descriptor flow, the last valid R precedes completion of the corresponding downstream W/B traffic; testing an additional completion-edge R would extend the reply-domain assumptions. Case15 proves combined faults in one descriptor, not same-clock R/B error acceptance. Keep these claims narrow; no new launch or rerun is required for this bounded verdict.

**Q2 — Nonblocking domain and finite-hold limitations.** R replies are IDzero/in-order with correct RLAST/count, and the current run reaches only four bursts per descriptor. The reader still relies on RLAST accounting and lacks qualified RID/unsolicited-response credit validation. Neither the nine-bit transaction-count maximum/overflow behavior, invalid lengths, four-bit descriptor-count wrap nor indefinite error holding is dynamically proven. The absorbing ERROR source supports the intended hold, but ten-cycle observation is not an unbounded liveness proof. These are retained exclusions, not defects claimed repaired by this patch.

No additional in-scope blocking source/test defect or evidence-integrity issue was identified.

## 4. Boundaries and predecessor disposition

External endpoints are **synthetic linear line-request models**, retaining donor host WRAP metadata rather than implementing generic AXI4 WRAP/4KiB semantics. Unit geometry is synthetic two-bank/34-bit-local/512-bit-data/57-bit-address; wrapper MODE remains HOST_TO_DDR while descriptor modes1/2 exercise engine branches. Full-width engine testing does not repair or qualify actual dma_top host narrowing or bank selection. Actual mapper/top is not instantiated.

Real descriptor/CSR queue behavior, zero-gap producer behavior, CSR aggregation, software ownership/error/quiescence, address admission, ID/USER/clock adapters, PIM/AFU routing and primary ownership, PCIe/physical DDR, stop/cancel/reset/global drain, fences/visibility, mapped synthesis/fit/timing, OPAE and durable boot remain unqualified. No FPGA operations occurred. **DDR vendor simulation: SKIPPED BY USER.**

Both separately FINAL predecessor reviews were read and their supplied full hashes verified. Their scopes are neither reopened nor enlarged here. `source-binding01.json` historical `parent_acceptance_pending` fields and the frozen result's review-pending language are retained history; parent supersession/publication is outside this report. This review adds no execution gate.

## 5. Principal full-file SHA256 bindings

| Artifact | SHA256 |
|---|---|
| `R/review-package01.json` | `f84b205e883fd4934aaa0c21d065042dae33628230aa6c9a899fa786968ad9e0` |
| `R/inputs-baseline/dma_read_engine.sv` | `7433c99064fcd9b2b07cd86edc1b1d4d2a02019af041e1c5bc7ccae4079f6cf6` |
| `RTL` | `3fc1937ad8268d0cfaf3453a85f8573a10aa1b98ae695deff62a89d772145a88` |
| `S/patches/read_response_retirement.patch` | `c9e910c28998e6ad80a0b3cb7d35bef82ef219edb50bbedfdefd162885dd0914` |
| `TB` | `4216a78866fd6ccb89ec2ea91440f53b756f8997ef64afe7e1bfe05251c1e5f8` |
| `WR` | `fb2d589ddd54a26ef9237eb7b38a490d0b5096b7b648b82dcba97462db7fe14b` |
| `R/run-red01.py` | `c8656a1ba87d35c22598e772aa263022653ccb2780b9c4a2a1d1ce530ab51b1b` |
| `R/run-green01.py` | `ab24643c2542a08934b2ce3dcd20efbbda89b5af77078f9ba1eeb6fd6b1119ba` |
| `R/result-red01.json` | `0796c5006d5441503bca2ca30726738c214008fba82c04fd16164a7fe26b9a77` |
| `R/result-green01.json` | `c1dc835606a7d72b707e365f5a71d998ca51273e1364ce782da5f700fe8c5fc8` |
| `qualification/dma-write-response01/independent-review01.md` | `ba4bcb62e243f9e04b8bf49c31c61c581517979fd1a4b142944a0a548fd027cf` |
| `qualification/dma-engine-integration01/independent-review01.md` | `fed904d2e1307d64923f85eea7277b555ed1406695bfe5fd9b9f86d4d3bbd342` |

Remaining exact tool, log and input identities are preserved in the verified manifest-bound native results. This report's full-file SHA256 is returned outside the file to avoid a self-referential checksum.

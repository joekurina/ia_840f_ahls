# Independent review — full DMA-top routing

Status: **FINAL**  
Bounded specification verdict: **PASS**  
Source/test/evidence quality verdict: **PASS WITH NONBLOCKING NOTES**

The completed evidence supports accepting the two source corrections for the specified finite, single-descriptor DMA-top routing composition. **No in-scope acceptance blocker found.** This is not full AFU/PIM integration, mapped synthesis, timing, physical DDR, host visibility or hardware acceptance. Parent acceptance/publication remains separate; this review neither launches nor authorizes another run.

## Review binding and method

- Reviewed frozen `review-package01.json`, SHA256 **`86bd17891642f8c7ef4cd4b53d1b9b90da89c2e0c827e48f16fda246332bbd70`**. Independently recomputed its hash and the size/SHA256 of **all 27 entries**: exact matches.
- Read `SCOPE.md`, `RESULTS01.md`, `source-binding01.json`, `cases01.json`, `parent-verification01.json`, `FIXTURE02-NOTE.md` and `RED01-TIMEOUT.md`; then inspected actual sources, fixture assertions and complete embedded native logs, rather than accepting the summaries alone.
- Parsed all five `run-*.py` files using **AST and literal decoding only**. Decoded and hash-checked **125 source payloads, 25 per run**, against their recorded input hashes and the actual baseline/successor files. Verified runner hashes against dispatch receipts, result hashes against outer receipts, and every embedded log's bytes/SHA256. All runner bodies match `run-native.py.in` after replacing only the literal configuration.
- Verified all 25 baseline files, the ten added local dependency originals, and the local-memory template transformation: only `_@GROUP@` / `_@group@` placeholder removal for group0. The four added donor RTL files match the pinned capture manifest at `../ai-suite-ofs-reference01/source-manifest01.json`, donor **`e0e07f7b1878a477dc4d1191918db8430193e148`**. Remote before/after preservation is supported by the captured runner/results, not by a fresh remote inspection.
- Local read-only review, except this report, first written as IN_PROGRESS and now finalized. No SSH, simulator/vendor execution, runner execution/import, hardware access, implementation edits, git actions or task transitions. Python checks performed hashing, inert parsing, exact diffs and log/ledger reconciliation only.

## 1. Bounded specification compliance

### 1.1 Actual composition and admitted contract

The test instantiates `dma_top`, not a replacement engine wrapper. Its CSR manager feeds the real descriptor FIFO; the descriptor controls the donor directional mux and DDR selector. Both mux register slices instantiate the real `ofs_plat_axi_mem_if_reg_impl`, ready-enable skid and FIFO2. The corrected reader/writer connect through the real BRAM FIFO/scfifo. See:

- `inputs-test02/dma_top_routing_tb.sv:24–38` — full top and external interfaces.
- `inputs-width/dma_top.sv:60–123,138–200` — CSR/status, descriptor queue, routing and engine.
- `inputs-baseline/dma_axi_mm_mux.sv:87–147` — width-replicated source/destination register slices and mode routing.
- `inputs-baseline/ofs_plat_axi_mem_if_reg.sv:73–168` and `ofs_plat_prim_ready_enable_skid.sv:33–49` — actual registered ready/valid paths, not bypass mocks.
- `inputs-baseline/dma_engine.sv:57–101`, `dma_pkg.sv:27–28` and `ofs_plat_prim_fifo_bram.sv:53–87` — 32-entry data FIFO, 16-entry descriptor FIFO and native scfifo implementation.

The reviewed contract is modes1/2, valid supported lengths, 64-byte-aligned addresses, no bank crossing, ordered ID-zero replies with correct RLAST, good selected R/B responses, one descriptor at a time, and no control-stop/reset/replay intervention. The FIFO depth is instantiated; full-depth descriptor admission or concurrent producers are not tested.

### 1.2 Experiment isolation and outcomes

Independently comparing the decoded configurations gives exactly the following changes, apart from the fresh run identity/directory:

| Attempt / owned window | Change from predecessor | Native evidence and disposition |
|---|---|---|
| red01 / @207 | Initial full-top fixture | Native vlog0. Vsim reaches the finite120s deadline; native leader0, effective124, outer124. No CSR/assertion activity in its retained log. Owned group drained. Not a reproduced width assertion. |
| red02 / @208 | Fixture only: continuous field-wise wiring plus START marker | DUT bytes unchanged. All five native/effective statuses0; outer1 correctly rejects the logged cycle7 first-read address/count fatal. Source CSR readback retains the high address before that failure. |
| width01 / @209 | `dma_top.sv` source-interface address width only | Same corrected fixture, original selector and all other inputs. All five native/effective statuses0, outer0; eight cases,100317checks. Inactive-bank readiness remains high, replies absent. |
| isolate_red01 / @210 | `+ISOLATE` only; no source payload changes | All five native/effective statuses0, outer1. Cycle1 fatal: `inactive bank1 reply was consumed`. This is the fixture's inactive RREADY/BREADY level assertion under forced reply-valid, not a separately recorded accepted-response edge. |
| isolate_green01 / @211 | `dma_ddr_selector.sv` only | Same width candidate, same fixture and `+ISOLATE`. All five native/effective statuses0, outer0; eight cases,108863checks. |

All **25 native command records** are present: version, vlib, vdir, vlog and vsim per attempt. Recorded commands retain the same tools,20vlog source units and finite deadline; only the isolation argument differs between stimulus variants. Outer statuses independently reconcile to **124,1,0,1,0**. Native exit zero alone is not acceptance: the runner also requires the expected scoreboard, no fatal/error diagnostics, completion and preservation receipts (`run-native.py.in:99–123`). Both red assertions demonstrate that this distinction matters.

The red01 fixture change supports a fixture/simulator scheduling interaction. The precise simulator event-loop cause remains unproven. Its SIGTERM diagnostic belongs to deadline cleanup, not a newly identified hardware or DMA address failure. The original fixture, timeout and diagnostics remain preserved; no increased timeout or unchanged rerun is needed to interpret the completed sequence.

### 1.3 Measured coverage and numerical checks

Parsed the passing native case rows and compared every field with `cases01.json`; independently summed the counts and decoded the CSR log transactions. Final isolated result:

- **8 cases / 8626 monitored cycles / 108863 checks**.
- **19 AR,19 AW,3397 R,3397 W,19 B;8 successful retirements;0 error/held cases**.
- Lengths in 64-byte beats: **1,257,514,1024,513,63,256,769**. Each direction×bank combination occurs twice.
- **32 aligned full64-bit CSR writes and16 reads**: source,destination,length,go for each descriptor; source-address readback and final status read. Native offsets/data match the fixture's programmed addresses, bank bit, lengths and modes. Completion status gives the advancing descriptor count, idle and empty descriptor queue.
- **3397 transport beats** checked for payload/order through FIFO and destination handshakes, with all3397 destination model-memory values compared again at successful retirement. Address-dependent/case-dependent data and independent expected addresses prevent an address-clipped source model from silently validating itself.
- Host source bits **34/56**, host destination bits **35/55**, and local-offset bit **33** are actually set. All cases are aligned and stay within the local bank window. Descriptor bit34 selects bank1's16GiB window; external bank address checks use the low34-bit offset.
- Read/write stall cycles **3069/4908**; maximum accepted R minus accepted W **38**. Full packed stalled AR/AW/W stability, request length/size/ID/burst, FIFO payload/markers/bounds, destination data/strobes/WLAST, delayed B accounting and non-premature retirement are checked. Seven successor descriptors run without another module reset.

These are finite monitored/model observations, not every simulation clock, physical memory readback, maximum-length qualification, queue saturation, modulo-counter wrap or zero-gap successor proof. Relevant fixture sections are `:124–158` (patterns/CSR), `:175–201` (addresses/programming), `:203–316` (routing/stalls/accounting/retirement), and `:317–339` (status, completion and watchdogs).

### 1.4 Execution, preservation and warnings

Captured native banner is **Questa Intel FPGA Edition2024.3** under `/opt/altera/25.1/questa_fe`, not Quartus mapped synthesis. All runs bind the same tool/INI identities and the same **six-file,2652245-byte** precompiled altera_mf library. The runner preflights competing native processes and resources, enforces two CPU cores and16GiB process address space, and uses fresh owned directories. Results record all input/original/tool preservation booleans true and all owned groups empty after cleanup. No remote or live-state re-verification was performed by this reviewer.

Both passing vsim logs end **Errors:0, Warnings:11**. Independently reconciled:

- Seven distinct13314 relaxed input-kind sites: reader descriptor; writer descriptor/control; engine descriptor/control; selector descriptor; CSR status. Vlog emits eight occurrences because `csr_mgr.sv:36` appears twice; vopt emits seven. These are declared typed-input/compile-semantics diagnostics, not reported truncations or new multiple-driver faults. Acceptance remains tied to this native compilation mode, not other tools.
- Four8315 unmatched unique-case diagnostics, all at time0: reader `:114,:212`, writer `:140,:260`. Source state registers receive IDLE on the synchronous reset edge; the warnings occur before that initialization. No later occurrence is logged in either passing run. This bounds their disposition to the tested reset sequence, not arbitrary reset/CDC recovery.

No suppression or native error was used to obtain a passing result.

## 2. Source and test quality

### 2.1 Width correction — accepted for this composition

`../../afu/ahls_memory/dma/patches/top_source_address_width.patch` is byte-for-byte the unified diff between the pristine captured top and `inputs-width/dma_top.sv`. No other top edit is hidden in the candidate.

The original `src_mem` macro uses local-bank ADDR_WIDTH34, even for host reads. The replacement at `inputs-width/dma_top.sv:143–151` uses `max(HOST_ADDR_W,DDR_ADDR_W)`,57 here. Its DATA_WIDTH,BURST_CNT_WIDTH,USER_WIDTH,RID_WIDTH and WID_WIDTH expressions exactly preserve the five non-address properties in `inputs-baseline/ofs_plat_local_mem_axi_mem.vh:50–56`. It does not accidentally adopt host ID/USER/data defaults while fixing address width.

The mux replicates this source width into its actual register slice and copies addresses by field; the DDR destination interface still projects to the local-bank width. The red02/width01 source-only contrast, high-bit source CSR readback, external full-address assertion and successful copies support the narrowing diagnosis and remedy. This is not proof of all parameter combinations, arbitrary IOVA allocation or pre-truncation descriptor admission.

### 2.2 Selected-bank ownership correction — accepted for this contract

`../../afu/ahls_memory/dma/patches/ddr_selected_bank_ownership.patch` is byte-for-byte the unified diff between the pristine captured selector and `inputs-selected/dma_ddr_selector.sv`. The width candidate remains unchanged.

At `inputs-selected/dma_ddr_selector.sv:32–42,60–118`, the patch:

1. Keeps direction-dependent descriptor bank selection.
2. Masks each bank's ARREADY/AWREADY/WREADY and RVALID/BVALID by that selection.
3. OR-reduces selected readiness, replacing the original all-bank AND that allowed an inactive bank to block progress.
4. Masks every packed R/B payload bit by the corresponding selected valid before reduction.
5. Holds unselected RREADY/BREADY low while retaining selected request/response wiring.

With a stable admitted descriptor and two valid bank choices, this implements selected-bank ownership without a new clocked state or separate outstanding-bank policy. Descriptor ownership is only adequate here because retirement waits for the tested local traffic/response drain and descriptors are submitted serially. Multi-descriptor overlap, generic bank-count/default-parameter behavior and independent bank clocks are not established.

### 2.3 Fixture independence and strength

The corrected fixture observes the actual host/bank ports using its own `h2d` and `selected_bank`, derived from case id (`inputs-test02/dma_top_routing_tb.sv:50–111,175`). It does **not** use the DUT's channel-select index to choose its expected endpoint. DUT hierarchy is read for status/FIFO assertions and to bound the deliberate interference interval; descriptor contents are supplied through real CSR transactions, not forced into the queue.

`+ISOLATE` drives inactive request-ready low and injects R/B valid with wrong payload/ID/error codes. The final candidate must still progress on the chosen bank, prevent request leaks and leave inactive response readiness low. This is useful synthetic interference, not a faithful unsolicited-response model of a compliant physical DDR controller. The baseline fatal exercises the readiness assertion first; it does not separately demonstrate every original reduction defect. Source inspection plus the passing combined interference test supports the combined selector correction without overstating that red trace.

The R-to-enqueue and dequeue-to-W allowances of three beats at `:291–293` are justified by each added two-slot FIFO2 register slice plus the original one-beat engine stage. The real FIFO occupancy/not-full/not-empty checks and exact retirement totals remain; the allowance does not excuse dropped or duplicated beats. Full packed stability and the per-beat/model-copyback comparisons remain enabled in the corrected fixture. The only red01→red02 fixture edits are wiring form and the START marker; no scoreboard relaxation was mixed into the source-fix experiments.

## 3. Findings and retained boundaries

**F1 — Low, nonblocking documentation defect.** Both as-run test headers still say “No … selector/CSR queue” (`inputs-test02/dma_top_routing_tb.sv:2–5` and baseline header). That statement is false for the actual module body/native composition. `RESULTS01.md:35` and CURRENT disclose it. Preserve these as-run bytes; correct the comment only in a future edited fixture. No rerun is warranted for this prose defect.

**F2 — Nonblocking evidence-language boundary.** The isolated red message says “reply was consumed,” but the actual failing predicate checks inactive RREADY/BREADY at a negative-edge observation while reply valid is deliberately high (`:203–212`), not a logged rising-edge transfer. Treat it as exposed response acceptance/readiness, not an independently observed consumed reply. The report already makes this distinction. Likewise, retain red01 as an unresolved-mechanism fixture timeout, not a width-defect reproduction or a vendor hardware hang.

**F3 — Material integration limits, outside this bounded acceptance.** The top still ties first-read response encoding to zero and CSR aggregation substitutes NOT_SUPPORTED (`inputs-width/dma_top.sv:86–89`; `inputs-baseline/csr_mgr.sv:94–97`). Selected replies here are good; inherited dormant error/missing-response branches in the fixture are not exercised full-top fault cases. Accepted reader error evidence does not qualify end-to-end CSR error code, failure lifecycle, buffer-release safety or reset recovery. CSR high-address aliases, ignored byteenables, upper address/length truncation, admission/overflow and control-stop/reset/replay remain open (`csr_mgr.sv:190–215,294–322`; `dma_top.sv:73–75,121`). Do not promote this pass to resolution of those issues.

**F4 — Model/platform boundary, not a blocker.** `unit_platform_pkg.sv` is explicitly synthetic: two banks,34-bit local byte offsets,512-bit data,8-bit AXI len,ID9/USER14 and host57. The actual PIM macros/dependencies are present, but this is not an actual generated PIM import or fabric ID18/USER2 adaptation. `afu_json_info.vh` is a simulation-only UUID and cannot support live discovery/deployment. Host WRAP metadata is modeled as linear line requests: no generic AXI4 WRAP/4KiB, actual splitter, invalid-length or maximum-burst proof. Both bank ports are exercised serially, not simultaneous physical DDR transactions. Clock/reset CDC, PR, one-primary-host ownership, PCIe/fences/global drain/physical visibility, real PIM mapping, synthesis/fit/timing, OPAE and durable boot remain unqualified. DDR vendor simulation is **SKIPPED BY USER**; no device/MMIO/driver/programming/reboot action was performed.

**F5 — Historical dependency flag, resolved for review bookkeeping.** `source-binding01.json:126` records read-response review pending **at preparation**. The current read-response checkpoint reports FINAL independent and parent acceptance; its report's recomputed hash is `c89d075bbf000e55f8d308764c04025e33e1da6b936d72a47009e2a2fda374c9`. Current routing documentation records publication `fda7ddabefab1a44db1a73759c7f3fd61e5456fd`. The tested reader hash is `3fc1937ad8268d0cfaf3453a85f8573a10aa1b98ae695deff62a89d772145a88`; writer is `fb2d589ddd54a26ef9237eb7b38a490d0b5096b7b648b82dcba97462db7fe14b`. The frozen historical flag should not be rewritten or treated as a present blocker. Predecessor engine audits were reused, not repeated or broadened.

## Final disposition

**Accept the finite native DMA-top routing evidence and both exact source patches within SCOPE.md's admitted contract.** The specification-first and source/test-quality reviews found no blocking mismatch; the documentation and inference limitations above remain explicit. No additional launch gate, unchanged native rerun, deadline extension or predecessor re-audit is requested. Parent acceptance/publication is the remaining administrative step; broader integration and hardware qualification remain separate work.

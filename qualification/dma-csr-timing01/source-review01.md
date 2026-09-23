# DMA CSR timing cone — source-only review and correction recommendation

**Disposition: recommend a narrow registered-endpoint candidate, not a timing waiver. No implementation or execution qualification is claimed.**

The smallest source-supported pipeline here does **not** require changing the AXI-Lite state machine: continuously register the two inclusive end addresses derived from the stored source/destination/length, and use those registered values in GO admission. The existing single-outstanding write/B-response serialization guarantees that these derived values have caught up before any later GO can execute. Preserve all other admission predicates, their evaluation edge, freshness side effects, response generation and FIFO ownership. This cuts the observed arithmetic-to-admission-to-register-enable feedback while retaining the exact transaction schedule.

If this serialization invariant is not retained, use an explicit held-request validation phase instead; simply adding an unqualified delayed validity bit would be incorrect. A changed native regression and changed fit/final STA are required before accepting either remedy.

## 1. Specification and exact binding — reviewed first

Paths below are relative to `/home/joe/Projects/Thesis/AHLS/new_bsp/new` (**N**). **B** means `qualification/dma-csr-timing01/csr_mgr-baseline01.sv`. **R** means `qualification/ahls-persona-work21-sta01/run-sta01.py`. **P** means the timing-report directory under `qualification/ahls-persona-work21-sta01/artifacts-sta01/persona/build/syn/board/ia840f/syn_top/output_files/timing_report/`.

This review independently verified all six sizes/hashes in `qualification/dma-csr-timing01/review-package01.json`, whose SHA256 is:

`7193881157a18c67d975099feb512711a59bd6064c064bde5d890481a163317b`

R was parsed with Python AST and its literal `C` dictionary decoded **without importing or executing the runner**. All 13 `source_files` payloads matched their declared lengths/hashes. B is byte-identical to R's `source_files['afu/csr_mgr.sv']`, not a filename-based substitution. R binds the remote source root `/home/uwb_student00/ahls/new_BSP/work_ahls_persona_work21_01/setup01/afu_sources`; this review did not contact it.

| Exact object | SHA256 |
|---|---|
| R | `63a2c41a696d577619fe37ca691c6a6b87eeb96020f2b8148eef704d88db1380` |
| B / decoded `afu/csr_mgr.sv` | `b526562f8663139a1a5654e54695ada8de67ee260b3b6a79014344ab7f3c4073` |
| Decoded `afu/dma_pkg.sv` | `aa0668a1b3dd0e6553cd0d7673b2b040a615094493e8a0b747f76a0e562dba99` |
| Decoded `afu/dma_top.sv` | `c511c923145adfcac4a7aeaa091ae64e075815f1b4d8990dac46f41df443a058` |
| Decoded `afu/ofs_plat_afu.sv` | `3b5bf9eac55f5117858b8a746308a09ebc3d7c6f8a99c66907777139278785ca` |
| Decoded `afu/ia840f_ahls_memory_core.sv` | `31976de3c28d2c539a8b08e80468f89108cb90b48ea0c49df4e3d01ffde305fa` |
| P/`ofs_pr_afu_2_slow_vid2_100c_setup.rpt` | `193e002559c05015da8ab547f87c6d1ac4be514960332a3ab4b544ae662462b0` |
| P/`ofs_pr_afu_2_slow_vid2b_100c_setup.rpt` | `ff78779d876b56cdcbae6da6058c640fc7594326a1eaa4d61927b20a08ef79dc` |

The old admission gate's `inputs-baseline/dma_pkg.sv` and `dma_top.sv` were checked byte-identical to those exact decoded sources. Its `inputs-candidate02/csr_mgr.sv` is B. **Its `inputs-baseline/csr_mgr.sv` is not the Work21 baseline.**

### Widths and command encodings are source facts, not names/comments

- Decoded `dma_pkg.sv:104–117` obtains `HOST_ADDR_W` from `ofs_plat_host_chan_pkg::ADDR_WIDTH_BYTES`; source/destination width is the larger of that and aggregate DDR width. Length is 20 bits; AXI LEN is 8 bits. The host address width is **57**, not 34. Decoded `ofs_plat_afu.sv:57–67` rejects geometry other than host57/data512, two banks with34-bit byte offsets/data512; decoded core line488 passes `(2,34,57)` to `dma_top`.
- The real host package has `ADDR_WIDTH_BYTES = ADDR_WIDTH_LINES + $clog2(DATA_WIDTH_BYTES)` at lines21–24. Its hash `6c8d8ade8edf79f705c6206e84869c2da0c8c9245edc4b13b075c6aaa23b4bfc` and generated top-config hash `cab8e6cae5c2a30f7e7d90e226606d4b1edd9287fb4cdfbadf74c1c7a4340c66` match R's actual persona inventory. Local byte-matching copies were read under `qualification/source-resume-01/remote/home/uwb_student00/ahls/new_BSP/work_ia840f_fim_13/syn/board/ia840f/syn_top/afu_with_pim/`: package at `pim_template/hw/lib/build/platform/ofs_plat_if/rtl/ifc_classes/host_chan/afu_ifcs/include/ofs_plat_host_chan_pkg.sv`, top config at `afu/build/platform/ofs_plat_if/rtl/ofs_plat_if_top_config.vh`. Top-config line49 declares51 line-address bits; the bound wrapper requires512-bit data, giving57 byte-address bits. These copies are used because their **bytes match**, not because the older directory name establishes identity.
- DDR uses a **35-bit aggregate address**: bank-select bit34 plus a34-bit offset. Validate high DDR bits and same-bank inclusive end before any downstream projection to the34-bit bank port. Do not replace the DDR predicate with a host-width test, nor treat bank-select bit34 as an illegal offset.
- `dma_pkg.sv:133–138` defines `STAND_BY=0`, `HOST_TO_DDR=1`, `DDR_TO_HOST=2`, `DDR_TO_DDR=3`. The adjacent comments at147–149 reverse directions and are not authoritative.
- **Specification discrepancy to carry explicitly:** the task context says “command0/1/2 and reject3.” B:145–148 accepts **only descriptor modes1/2**, including on non-GO descriptor-control writes; it rejects mode0 as well as3. The accepted admission fixture explicitly rejects GO/mode0. Raw descriptor-control data0 is also SLVERR in B. Legacy `DMA_CONTROL` is a different CSR: B:150 accepts any low32-bit value, including0/1/2/**3**; any nonzero stored control subsequently blocks GO. A timing-only correction must preserve these exact behaviors. Accepting descriptor mode0, or rejecting legacy control3, would be a separate ABI change requiring an explicit spec decision, not a timing repair.

### Required preserved contract

| Area | Exact baseline behavior to retain |
|---|---|
| Access/decode | B:95–102,131–153 validates the entire received byte address before bits7:3 decode. Readable aligned words0x00–0x90; writable0x28/30/38/40/50; size3, all write strobes. Invalid access => DECERR; invalid read data zero. Access errors take precedence over value errors. |
| Raw values | Source/destination raw64-bit writes checked against57-bit field width before narrowing. Length must be nonzero, fit20 bits and be <=130816 beats. Invalid value => SLVERR; old stored field remains. |
| Command | Only GO bit31/mode bits27:26 may be set (`0x000000008c000000` mask); modes1/2 only. Non-GO valid mode writes do not require descriptor admission and do not consume freshness. GO adds all admission checks. |
| Length/endpoints | 130816 =511 full256-beat bursts, derived from9-bit request/reply counters, not from20-bit field capacity. At64 bytes/beat it is8372224 bytes. Require64-byte alignment; inclusive end arithmetic remains65-bit; host start/end fit57 bits; DDR bank index <2 and end bank equals start bank. |
| Fresh staging | Access-valid valid field write sets that field fresh; access-valid invalid value clears only that field's flag. Any access-valid GO write consumes all three flags, **even if command, range, full queue or status rejects it**. Access-invalid writes do not consume/invalidate flags. |
| Admission/status | GO also requires non-full FIFO, no `rd_rsp_err`, no `wr_rsp_err`, and entire legacy control ==0, evaluated at the original write-service edge. Do not cache these live predicates early. |
| Transport | AW/W accepted independently; exact address ID/USER retained. One B response only after both channels; B and R payloads/valid held through stalls. No request overwrite while validation/response is pending. |
| Ownership | A valid GO generates one registered pulse; FIFO receives the packed staging descriptor on the following edge. Rejections neither enqueue nor flush/alter existing queue entries. Rejection/legacy-control writes must not clear sticky engine faults or create retirement. |

B:156–169,323–407 implements the side effects above. Decoded `dma_top.sv:72–95,108–123` shows the sole enqueue source is the registered GO field and the FIFO's actual not-full signal feeds admission. Decoded reader lines224–225 suppress descriptor dequeue on read fault; decoded writer lines167–170 retains ERROR rather than replaying through dispatcher reset. Preserve these boundaries without editing the engines.

## 2. Actual critical cone — what the detailed path establishes

The existing final-snapshot STA failed setup on EMIF0 `core_usr_clk`, relationship3.000ns. Slow vid2 slack/TNS is **-0.367/-26.907ns**; Slow vid2b is **-0.356/-25.662ns** (`qualification/ahls-persona-work21-sta01/RESULTS01.md:11–16`). Each supplied detailed report contains20 worst violated setup paths, not exhaustive endpoint coverage.

The first vid2 path is explicitly:

```text
csr_mgr_inst|dma_csr_map.descriptor.length[14]~ENA_dff
  -> length[14]~.comb|ena -> bypassed ALM-register q
  -> add_0 carry/sum group
  -> add_1 carry/sum group
  -> i657~42xsyn -> i657~36xsyn
  -> write_response[1]~0
  -> i2590~0 / shared control routing
  -> dma_csr_map.descriptor.length[0]~DUPLICATE|ena
```

Evidence: vid2 report lines50–89 gives endpoint/clock/no-exception/statistics; lines100–104 identify the Hyper-Register launch and bypassed enable path;112–144 shows both serial arithmetic groups;152–178 shows comparison/control and named write-response logic;185 explicitly identifies the **destination enable pin**, not length data bit0. There are six reported logic levels,3.186ns data delay,1.740ns cell,1.198ns routing and0.248ns uTco. The vid2b first path uses the same named chain and enable endpoint,3.176ns data delay. The `~ENA_dff`, `~SCLR_dff` and `~DUPLICATE` names describe mapped transformations; they do not themselves prove a source-level arithmetic recurrence or a reset bug.

Source correspondence:

1. B:103–128 constructs65-bit starts, `length * AXI_MM_DATA_W_BYTES`, and inclusive `start + nbytes - 1` for both endpoints; then mode selection, representability/bank comparisons, freshness and live-status gates.
2. B:144–148 combines that result with command-mask/mode/GO validity.
3. B:153 produces encoded `write_response`.
4. B:387–396 uses **one shared `write_response == OKAY` guard** around the writes to source, destination, length, descriptor-control and control. This allows a descriptor admission cone to enter the physical update-enable network of length, despite a length-field write logically needing only its own raw-value test.

Thus this is our CSR admission/feedback path, not the vendor PHY and not an unavoidable length-to-length datapath operation. Constant multiplication/modulo by64 is shift/alignment logic, not evidence of a general multiplier/divider bottleneck. The detailed report proves serial mapped carry groups and the response/enable suffix; without a mapped equation/source-node database it does **not** prove which `add_N` corresponds uniquely to source addition, destination addition or subtraction. Do not label those arithmetic cells more specifically than the evidence supports.

The source-level length-write and descriptor-control addresses are mutually exclusive, but that does not license a false-path constraint on the actual physical cone. Fix the logic structure and measure it.

## 3. Recommended minimal code-level correction

### 3.1 Register only the arithmetic endpoints; keep the transaction machine

Add private `logic [64:0] src_last_q, dst_last_q` in `csr_mgr`. Compute them every active clock from the **stored** descriptor source/destination/length. They are derived state, not additional CSR-visible staging fields and not FIFO entries. Use a pure helper with explicit arguments and the same unsigned65-bit inclusive-end calculation. Illustrative proposal, **not an implemented or compiled patch**:

```systemverilog
logic [64:0] src_last_q, dst_last_q;

function automatic logic [64:0] last_byte(
    input logic [63:0] start_addr,
    input logic [LENGTH_W-1:0] beats
);
    logic [64:0] nbytes;
    nbytes = 65'(beats) * AXI_MM_DATA_W_BYTES;
    return {1'b0, start_addr} + nbytes - 65'd1;
endfunction

always_ff @(posedge clk) begin
    if (!reset_n) begin
        src_last_q <= '0;
        dst_last_q <= '0;
    end else begin
        src_last_q <= last_byte(64'(dma_csr_map.descriptor.src_addr),
                                dma_csr_map.descriptor.length);
        dst_last_q <= last_byte(64'(dma_csr_map.descriptor.dest_addr),
                                dma_csr_map.descriptor.length);
    end
end
```

In B's `descriptor_ok`, pass the two registered ends as explicit formal arguments along with command, use them as `src_end`/`dst_end`, and remove the now-redundant local recomputation of `nbytes`/ends. Keep starts, mode selection and **every return predicate** unchanged. For example the call becomes `descriptor_ok(mmio64_reg.w.data, src_last_q, dst_last_q)`; the two new input formals are65-bit. Do not use a zero-argument helper whose captured-state sensitivity must be inferred. Retain explicit declaration ordering before use.

Everything else in the first candidate should remain byte-preserved where practical: full-address/access/value checks, response code priority, freshness block, read path, AW/W capture, B response logic, GO clear, update case, reset of architectural fields and the package/queue/engines. No interface, register-map or timing-constraint change. The nominal new derived-state width is130 bits before optimization; actual mapped register/ALM cost is unknown.

### 3.2 Why one-cycle-old arithmetic is current when it matters

Only B:391–393 and reset write source/destination/length. GO itself does not change these fields. B:231 defines write service from held AWVALID && WVALID. B:323–324 denies new AW/W acceptance while BVALID is high; B:327–348 consumes both held requests on the service edge; B:356–372 creates BVALID on that same edge, even if BREADY is already high.

For the tightest legal master, with BREADY continuously high:

| Edge | Architectural write and request state | Derived endpoints |
|---|---|---|
| E0 | Commit the most recent source/destination/length write; clear held AW/W; set BVALID. | Capture arithmetic from pre-E0 staging, so it may still be old just after E0. |
| E1 | Earliest handshake of that B response. AWREADY/WREADY were low before this edge, so no next request capture. | Capture arithmetic from the updated fields: now current. |
| E2 | Earliest capture of next AW and W together. | Remain current. |
| E3 | Earliest service of that next request, including GO. | Already current before E3; live checks/freshness/response are evaluated exactly as in B. |

Stalled B or split AW/W can only increase this interval. A request cannot slip in on E1 because ready is derived from the pre-edge BVALID. Even an aggressively preasserted VALID must wait for a real handshake. A same-request field write and GO is impossible because they are different CSR addresses. A rejected field write leaves its stored value unchanged and clears freshness; it cannot admit a stale endpoint. Reset clears freshness and outstanding requests, so zero/uninitialized descriptor arithmetic cannot authorize GO.

Consequently **no added response latency or changed full-queue/error sampling edge is necessary**. No new request latch, FSM, reservation, pending bit or enqueue delay is necessary either. This proof depends on preserving the current nonpipelined AW/W/B architecture and exclusive ownership of staging writes. Add a regression assertion that registered ends equal fresh full-width arithmetic at every service of an access-valid GO with all fields fresh. This is the key acceptance condition, not an assumption based on typical software delays.

### 3.3 Intended timing split and limits

The candidate changes the structural path into:

```text
stored src/dst/length -> inclusive-end arithmetic -> src_last_q/dst_last_q
src_last_q/dst_last_q + stable starts/mode/freshness/live status
    -> end-range/bank checks -> write response / GO / update enables
```

Direct length nonzero/maximum comparators remain, correctly. The long end-address arithmetic no longer sits combinationally ahead of the admission/response/update-enable suffix. The existing handshake idle interval hides the arithmetic pipeline latency without relaxing STA; **both new stages remain ordinary single-cycle timed paths at3.000ns**. Do not add multicycle constraints on the rationale that software is slow.

This is a proposed structural improvement, not a prediction of positive slack. Arithmetic-only timing, new derived-register placement, comparator fanout and fitter retiming can still fail. The current routed-delay numbers cannot be subtracted to manufacture a predicted new slack. If native evidence shows arithmetic alone still limiting, split the arithmetic further in a fresh candidate with an explicitly checked validity/latency schedule; do not silently add deeper stale derived state.

## 4. Alternatives and quality risks

### Smaller pure factoring, but weaker basis for closure

Factoring architectural field updates by their own exact access/raw-value predicates would remove the irrelevant GO result from source/destination/length/control enables. For example, length acceptance depends on `is_csr_write`, full valid access, **exact length address**, and the raw length predicate, not a global encoded response result. Descriptor-control acceptance alone needs command/admission checks. Reset precedence, GO self-clear and all freshness side effects must remain separate.

This may be a useful separately measured candidate, but it leaves the entire arithmetic/range cone to B-response and GO endpoints. The20-path samples cannot establish those endpoints already meet timing. Moving the failure from length enable to GO/B is not closure. Prefer the endpoint pipeline as the first targeted arithmetic cut; do not combine unrelated engine/CSR cleanups into it.

### Explicit validation-phase fallback if write serialization changes

If the parent chooses to free request registers early, accept the next transaction while B is pending, or add another writer of staging, the continuously updated endpoint proof above no longer applies. Then explicitly hold AW/W, freeze or snapshot the complete staging descriptor/freshness, register arithmetic, and only in a later commit phase generate one B response and one accepted GO. Use separate pair-present, validation-active and commit events; do not leave `is_csr_write` firing side effects every held cycle. Do not clear freshness on phase entry and then evaluate live cleared flags on phase exit. Keep command-mask/access-error precedence, ID/USER and B stability.

Such a phase adds an observable admission edge: decide deliberately how full/errors are sampled, rather than accepting a request that was full when an earlier decision was made or missing a sticky error that arose during validation. Full cannot grow from another enqueue during the current baseline's serialized transaction because this CSR is the sole enqueue producer, but late reader/writer error can arise from previously queued work. An early cached OK bit is not a substitute for live status. The recommended no-protocol-change endpoint pipeline avoids this new policy decision entirely.

### Do not silently broaden the scope

- Do not narrow endpoints to34/35 bits before checking, remove start checks, drop the extra arithmetic carry, or assume alignment instead of enforcing it.
- Do not replace65-bit inclusive-end semantics with exclusive-end arithmetic or a special-case carry optimization in the same first candidate. That may be equivalent with a proof, but introduces unnecessary boundary risk here.
- Do not cache `descriptor_ok` continuously as one bit: it includes live FIFO/error/control and freshness, and those predicates must retain the original service-edge meaning.
- Do not use BREADY as the enqueue/commit gate: B may stall after the descriptor has correctly been admitted, and holding it must not repeat or postpone ownership transfer.
- Reset/freeze/drain/fences/physical visibility, pinned host-allocation ownership and CPU visibility of posted-write errors remain unqualified. Retain the Work21 signoff/unconstrained/DRC findings and broader acceptance limits.

## 5. Required directed regressions before the changed fit

These are requirements for the parent's separately authorized candidate/native unit work; **none were executed by this review**. Both timing baseline and timing candidate should pass the same functional fixture. The original donor's historical alias failure is not an expected failure of this hardened timing baseline.

### A. Bind and reuse the right existing tests

Reuse `afu/ahls_memory/dma/tests/dma_csr_admission02_tb.sv`, byte-identical to `qualification/dma-csr-admission01/inputs-test02/dma_csr_admission_tb.sv`, SHA256 `65143df8bd1a6d05780c3cd478d91d37ca07d4d19bc609a051605aba845b07e8`. Retain its corrected split-channel driver at185–211: WVALID must stay low until the new payload exists. The unsuffixed fixture is historical and contains the stale-W driver problem.

Retain the current guard cases plus the actual DMA-top/FIFO/PIM-slice numerical copy regression in both directions/banks, high host bits and inactive-bank isolation. Bind exact new expected case IDs/counts, not merely positive guard totals. The historical fixture's eight data cases and its boundary-only enqueues are distinct evidence classes; do not turn maximum-length admission into a claimed maximum-length copy. Snapshot the changed fixture and candidate alongside B; do not overwrite frozen predecessors.

### B. Fastest-legal scheduling — new pipeline's decisive tests

1. Program source/destination/length in every order, always with BREADY high and no avoidable idle cycles. Make **each field in turn the last write immediately before GO**. Use new values that change the end-range verdict from valid to invalid and invalid to valid, especially near host and both bank ends. This catches old-length and old-address cache use; a test with generous CSR delays is insufficient.
2. Repeat with AW first/W later, W first/AW later, simultaneous arrivals, and payload/ID/USER changes on external buses after their handshakes. Preassert the next request through the prior B stall without assuming it was accepted. Assert paired requests are never mixed and exactly one response follows each pair.
3. At an access-valid fresh GO service edge, compare both derived endpoints against an independent full-width calculation from the current stored descriptor. Also check the packed descriptor actually presented at FIFO enqueue, not only BRESP.
4. Differentially compare baseline/candidate cycle-by-cycle for AWREADY/WREADY/ARREADY, response-valid/packed payload while valid, architectural CSR values, freshness effects and GO/FIFO enqueue. Ignore undefined invalid payload bits. The recommended candidate should not need latency-tolerant comparison: its protocol timing is unchanged.
5. Reset with AW only, W only, a held B response, and immediately after a field write. Then re-prime and issue minimum-gap GO; assert no stale admission/response after reset. These are synchronous module-reset tests only, not evidence that live system reset or buffer release is safe.

### C. Preserve each predicate independently

- Raw-address tests: high aliases of all writable words, out-of-range0x98, unaligned addresses, read-only writes, size other than3, partial/zero strobes. Include malformed descriptor-control GO. Expect DECERR before value checks, no staging/freshness change and no enqueue. Invalid reads return DECERR/zero with preserved R ID/USER through stalls.
- Raw source/destination bit57 and bit63 set: reject SLVERR before narrowing; old CSR data retained; only the failed field freshness cleared. Conversely exercise real host high bits34 and56 in both roles: they must not be clipped to DDR width.
- Length0,1,130816,130817, a high bit beyond20 and field maximum. Max accepted length is130816; explicitly isolate overflow/freshness from address range. Retain max admission-only labeling unless transport is separately exercised.
- Command table: modes0/1/2/3 each with GO0 and GO1; reserved bits below26,28–30,32–63. For descriptor control, mode0/3 reject regardless of GO; clean modes1/2 with GO0 are OKAY/no enqueue and do not consume freshness. GO1 modes1/2 require every predicate. Verify exact raw constants `0x84000000` (H2D) and `0x88000000` (D2H), not reversed comments. Isolate non-GO acceptance with missing freshness/full/sticky status so it is not accidentally overconstrained.
- Legacy control:0 permits otherwise-valid GO; each relevant nonzero low32-bit value (including1/2/3) is an accepted control write that blocks subsequent GO. A high32-bit value is SLVERR and preserves prior control. Do not call these safe reset/drain tests.
- Alignment: each endpoint misaligned independently; correct endpoint addresses with all other checks satisfied.
- Inclusive limits, both directions: one beat at host `0x1ffffffffffffc0`, bank0 `0x3ffffffc0`, bank1 `0x7ffffffc0` is valid; two beats there crosses the corresponding limit and rejects. Exercise bank-select bit34 and offset bit33 independently; DDR bit35/high-bank index rejects at GO even though it fits the raw57-bit staging register. For larger length, test start at `limit - length*64` and64 bytes above it, using a wider reference calculation.

### D. Isolate freshness, full queue and failed ownership

1. With otherwise-valid retained data, test every incomplete source/destination/length freshness combination. Only the fully fresh set can admit GO.
2. Successful GO followed by another GO without rewriting fields must reject; partial rewrites still reject; rewriting all fields admits exactly once.
3. With all data valid, reject an access-valid GO **only** because of reserved command bits or unsupported mode; the immediately following clean GO must still reject from consumed freshness. This fixes the old repeated-invalid-range test's inability to isolate GO consumption.
4. With all data valid, send an access-invalid GO, then a clean GO without re-priming: the malformed access must not consume freshness. Separately show a non-GO command does not consume freshness.
5. Isolate `rd_rsp_err`, `wr_rsp_err`, and nonzero control one at a time. A direct CSR unit may drive its public status input to precisely control the edge; do not force internal production state. Reject each valid GO/no enqueue, consume freshness, leave sticky status/queued ownership unchanged. In a full-top regression produce actual response errors and verify no successful retirement/replay follows.
6. Fill the actual descriptor FIFO with identifiable entries, assert full and reject the next fresh GO. Do not hardcode total capacity as16: the existing wrapper includes an output stage. Then drain/check every prior entry's identity/order where the engine is healthy; rejection must not flush, replace or append an entry. For faulted ownership, assert the head/retirement remains blocked rather than assuming it can safely drain.
7. Exercise status changes between split AW/W arrivals and at the service boundary, and hold BREADY low afterward. Both versions must make the same service-edge decision; changing status after BVALID must not change BRESP or create an enqueue. Check exactly one accepted GO pulse/FIFO write during a long B stall and no second request handshake until B has cleared.

## 6. Next acceptance boundary and limitations

Parent's minimal next action: add the endpoint-register candidate alongside B, extend the corrected fixture with the scheduling/isolated-predicate cases above, and run a bound baseline/candidate native regression. If functional checks pass, use the existing changed-build workflow and compare actual synthesis/fitter/final STA at the same EMIF0 clock, unchanged clocks/constraints and existing build policy. Inspect new endpoint-register timing, remaining admission/B/GO paths, all corners/metrics, resource/DRC changes and any new worst endpoint. No random seed trial, false path or slowed DDR clock is justified.

The supplied20-path samples do not establish all CSR paths, and the proposed cut is not timing-proven. Existing hold/recovery/removal/pulse-width summaries, unconstrained-path and signoff findings are not waived by repairing this setup cone. No vendor DDR simulation, hardware access, native compiler/simulator/vendor invocation, SSH or git operation was performed. No source was implemented or modified. The only created file is this report.

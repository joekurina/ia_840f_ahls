# DMA donor ABI and two-bank IA840F review

Status: **FINAL — source review, with explicit unresolved dependencies.** An **IN_PROGRESS** draft was written before detailed inspection. This is not implementation, an execution authorization, or a new native-launch gate.

## 1. Decision and evidence boundary

The donor is reusable transport source, **not a drop-in correctness-qualified DMA**. Two 16GiB banks require 34-bit bank-local byte offsets and bank-select bit 34, but geometry changes alone do not resolve the source-visible hazards:

1. **Direction comments are reversed:** executable enum/mux use `1 = HOST_TO_DDR`, `2 = DDR_TO_HOST`.
2. **Length is a count of full data beats, not bytes.** A 20-bit field does not mean a validated 20-bit transfer range: burst counters are only 9 bits, and multi-burst write-length scheduling has a separate defect.
3. **Host-read address truncation:** `src_mem` uses the local-memory interface macro. With the inspected local PIM macro, that makes its address only bank-offset-wide, truncating a host IOVA before host routing. Keep the platform host IOVA width; fix the internal source interface, not the host address mask.
4. **Completion is not response-drained completion.** The write FSM asserts done in `WAIT_FOR_WR_RSP` without counting or waiting for successful B responses. Response errors, busy, and descriptor-count status are not trustworthy success indicators.
5. **No source-proven stop/reset/drain ABI exists in the inspected subset.** Mode/bank can change while writes/responses remain buffered. The selector ANDs all banks' ready signals and ORs their responses rather than isolating the selected bank.

### Scope / identity

- `N = /home/joe/Projects/Thesis/AHLS/new_bsp/new`.
- Donor immutable pin supplied and checked against the retained source manifest: `e0e07f7b1878a477dc4d1191918db8430193e148`, tag `rel-2026.1.1`.
- Donor root `D = N/qualification/ai-suite-ofs-reference01/captures/source/agilex7/iseries_ofs_pcie`.
- Citations `[P:104–117]` below mean exact file/line ranges in the source key in §10. Donor comments are not treated as stronger evidence than assignments or state transitions.
- Reused `N/qualification/ai-suite-ofs-reference01/AHLS-DONOR-MAP.md` and `REUSE-FINDINGS.md`; did not reopen broad donor research.
- Auxiliary local PIM templates are explicitly identified separately from the AI Suite pin. They establish local macro semantics and a possible response boundary, **not the generated active IA840F PIM configuration**.
- Parent-supplied baseline: standalone corrected HLS2026.1.0 / DDRIP native25.1 import and analysis/elaboration accepted at `ab4eef797a3d47612bc8eae397de01c288169e92`. Not rerun here. Supplied AHLS interfaces: two 34-bit byte-addressed / 256-bit Avalon hosts; x/y bank-local inputs on logical `gmem0`, z on logical `gmem1`; 5-bit WORDS, 64-bit-data CSR, 256-byte span. Integrated physical-bank mapping remains parent-owned and unverified here.
- Parent's proposed fresh fabric: one MMIO AXI port; donor DMA aperture base 0; kernel CSR base `0x10000`; one DMA AXI input plus AHLS Avalon arbitration per bank; AXI bank outputs. Preserve the existing scalar AFU and host services, and instantiate only one primary host-channel0 PIM mapper.
- **No SSH, live accesses, network fetches, simulator/vendor execution, git operations, source edits, or task transitions. Only this report was written. DDR vendor simulation: SKIPPED BY USER.** Expected host PCIe is Gen3 x16, not measured here. No build/elaboration/timing/hardware/numerical pass is claimed by this review.

## 2. Descriptor ABI: exact storage, direction, and programming contract

### 2.1 Widths and packed layout

Let `H = ofs_plat_host_chan_pkg::ADDR_WIDTH_BYTES`, `A = LOCAL_MEM_BYTE_ADDR_WIDTH`, `K = LOCAL_MEM_NUM_BANKS`, and `W = max(H, A + clog2(K))`. Both descriptor addresses have width W; length has width 20; descriptor control has width 32. `[P:104–117,133–159]`

The internal SystemVerilog packed descriptor is **not a software memory-resident descriptor ring**. Host software writes separate 64-bit MMIO staging registers; GO enqueues their packed contents into an on-chip FIFO. `[C:294–322; T:65–76,108–123]`

| Internal packed field | Bits (LSB-based) | Host-facing staging register |
|---|---|---|
| `descriptor_control` | `[31:0]` | byte `0x40`, low 32 bits |
| `length` | `[51:32]` | byte `0x38`, low 20 bits |
| `dest_addr` | `[W+51:52]` | byte `0x30`, low W bits |
| `src_addr` | `[2W+51:W+52]` | byte `0x28`, low W bits |

Total packed width is `2W + 52`. If the resolved host width is 57, W remains 57 for both donor 4×8GiB and target 2×16GiB, and the packed width is 166 bits: source `[165:109]`, destination `[108:52]`. **57 is the default parameter in dma_top, not a verified active host-width value.** Its top-level instantiation passes the PIM-derived H. `[T:26–40; O:29–36,1252–1262]`

Descriptor control: GO bit 31; reserved `[30:28]`; mode `[27:26]`; reserved `[25:0]`. Write reserved bits as zero. Executable enum values and mux routing, not the contradictory field comment at P:148–149, define direction:

| Mode | Actual source → destination | GO control value, zero reserved bits | Status/qualification |
|---|---|---|---|
| 0 | STAND_BY name, but mux defaults DDR→host and burst helpers return X | do not submit | Not a safe no-op descriptor |
| 1 | Host IOVA → selected DDR bank/offset | `0x0000000084000000` | HOST_TO_DDR |
| 2 | Selected DDR bank/offset → host IOVA | `0x0000000088000000` | DDR_TO_HOST |
| 3 | DDR_TO_DDR name only; mux default still routes DDR→host, selector defaults bank0 | do not submit | Unsupported, not a bank-to-bank engine |

Evidence: `[P:133–152; M:130–146; S:29–42; R:58–69; W:65–76]`.

### 2.2 Submission rules justified by source

Use ordered, aligned **64-bit MMIO writes** to source, destination, length, then descriptor control/GO last. GO self-clears in the staging register on the next clock; that is a launch pulse, **not completion**. The FIFO holds the descriptor (including GO) until dequeue. Software must serialize staging-register ownership and check available capacity before committing. FIFO depth is 16; enqueue is GO without `notFull` gating, MMIO never blocks for descriptor capacity, and no overflow acknowledgment is exposed. A full FIFO may reject/drop or otherwise mis-handle enqueue according to the uninspected FIFO implementation; there is no guaranteed host-visible error here. `[P:27–37; C:239–287,294–322; T:72–76,108–123]`

Use one outstanding descriptor initially as a simplifying **design constraint**, not a claim that this makes the original completion contract safe. Do not reuse/free a host buffer or switch direction solely because GO clears, MMIO B responds, FIFO becomes empty, or busy clears.

## 3. MMIO register ABI and byte enables

All offsets below are **bytes relative to the DMA aperture at base 0**. Register index is address `[7:3]`; low three address bits and every bit above bit 7 are ignored by csr_mgr. Consequently it aliases every 256 bytes within any larger decoder aperture. Unimplemented reads return zero and unimplemented/read-only writes do nothing while receiving an OKAY response. The intended donor PD DMA aperture is 16 address bits (64KiB), with base 0; its kernel/DLA branch begins at `0x10000`. `[P:57–82; C:179–215,268–287,302–312; Q:146–153,791–799]`

**Byte enables are transported to csr_mgr but ignored there.** It latches `w`, then overwrites whole low-width fields from `w.data`; no `w.strb`, AW size, or alignment validation appears in write decoding. Even a zero strobe can change a register. Do not use byte/32-bit/RMW partial writes as though they were honored. A faithful initial software ABI must demand AW size for 8 bytes, 8-byte alignment, `WSTRB = 0xff`, and full 64-bit payloads. A hardened endpoint can explicitly reject other accesses or implement byte merging. MMIO OKAY only acknowledges CSR handling, not descriptor admission or execution. `[C:242–287,294–322; O:404–439]`

| Index | Byte offset | Name / access | Implemented payload / semantics |
|---|---|---|---|
| 0 | `0x00` | DFH / R | `0x1000010000000000`; AFU type, EOL set. Do not reuse as a promise of a discoverable second DFH at kernel base. |
| 1 | `0x08` | GUID_L / R | low 64 bits of generated `AFU_ACCEL_UUID` |
| 2 | `0x10` | GUID_H / R | high 64 bits of same UUID; actual generated value not supplied by these files |
| 3 | `0x18` | reserved1 / R | `0xDEADBEEFABCDEF01` |
| 4 | `0x20` | reserved2 / R | `0xBADDC0DEFEDCBA10` |
| 5 | `0x28` | SRC_ADDR / RW | W bits; upper input bits truncated, read zero-extended |
| 6 | `0x30` | DEST_ADDR / RW | W bits; same |
| 7 | `0x38` | LENGTH / RW | low 20 bits, full-beat count (§4), upper bits discarded |
| 8 | `0x40` | DESCRIPTOR_CONTROL / RW | low 32 bits, GO pulse and mode above |
| 9 | `0x48` | STATUS / R | lower 64 bits of packed status, decoded below |
| A | `0x50` | CONTROL / RW | low 32 bits; bit0 stop_dispatcher, bit1 reset_dispatcher, bit2 stop_on_error, bit5 stop_descriptors; rest reserved |
| B | `0x58` | WR_RE_FILL_LEVEL / R | 32-bit `{write[15:0],read[15:0]}` declaration; reset to zero, never updated by csr_mgr |
| C | `0x60` | RESP_FILL_LEVEL / R | 32-bit reserved/response declaration; reset to zero, never updated |
| D | `0x68` | WR_RE_SEQ_NUM / R | 32-bit write/read declaration; reset to zero, never updated |
| E | `0x70` | CONFIG_1 / R | actually 30-bit packed structure; see below, not reliable geometry discovery |
| F | `0x78` | CONFIG_2 / R | 32 bits; fixed 400 in `[31:23]`, others zero, i.e. `0xc8000000`; not measured clock |
| 10 | `0x80` | TYPE_VERSION / R | 32-bit type/version declaration, reset to zero, never updated |
| 11 | `0x88` | RD_SRC_PERF_CNTR / R | 40 bits: valid-beat count `[19:0]`, clock count `[39:20]`; high 24 bits zero |
| 12 | `0x90` | WR_DEST_PERF_CNTR / R | same packing for write destination |

Evidence: `[P:61–82,166–255; C:71–129,190–228,302–322]`. Counters are 20-bit modulo counters with FSM-dependent start/stop behavior, not timestamps or 32+32-bit counter pairs. `[R:212–248; W:321–362]`

### STATUS bits that software actually sees

`[0] busy`; `[1] descriptor_fifo_empty`; `[2] descriptor_fifo_full`; `[3] response_fifo_empty`; `[4] response_fifo_full`; `[5] stopped`; `[6] resetting`; `[7] stopped_on_error`; `[9:8] zero`; `[10] wr_rsp_err`; `[12:11] wr_resp_enc = 0`; `[13] rd_rsp_err`; `[15:14] rd_resp_enc = 0`; `[21:16] wr_state`; `[27:22] rd_state`; `[31:28] descriptor_count`; `[33:32] FIFO-head dma_mode`; `[63:34] zero. `[P:176–198; C:87–107; T:72–98]`

Important non-contracts:

- STATUS struct is **150 bits**, because it includes two 40-bit perf structs and a 36-bit reserved field in addition to 34 status bits. The CSR assignment truncates it to its low 64 bits; separate perf registers are the usable perf readouts. Do not copy the misleading reserved field name as a bit-layout specification.
- Write FSM is 9-bit one-hot but `wr_state` is only 6 bits, truncating states RD_FIFO_WR_DEST, WAIT_FOR_WR_RSP and ERROR. Read FSM fits its 6 bits. `[P:19–20,181–183; W:38–63,95; R:37–56,85]`
- `wr_dest_status.busy` is cleared on reset/IDLE but **never asserted** anywhere in the inspected write module. Aggregate busy therefore cannot certify write drain. `[W:321–364; T:97]`
- The read module's 4-bit descriptor count is not FIFO occupancy. Its increment is in the `next[WAIT_FOR_WR_RSP]` branch, but `descriptor_fifo_rdack` becomes true in the **current** WAIT state with `wr_fsm_done`, which simultaneously makes next IDLE. Thus normal completion does not execute the counter increment branch. Do not poll it as a completion sequence number. `[R:118–120,181–200,223–245]`
- Response-FIFO flags are supplied by the missing dma_engine source; their exact meaning is not established. Fill/sequence registers above are just reset-held zero. Mode when FIFO empty is not a stable last-completed mode contract.
- `stopped` and `resetting` echo the software control bits, not independently observed stopped/reset acknowledgments. `[C:101–102]`

CONFIG_1 is malformed as a discovery ABI: the packed declaration has no reserved bits for the comment's apparent `[17:16]` gap. Actual low bits match the documented fields through bit15, then enhanced_features is bit16, error_enable17, error_width `[20:18]`, max_burst_count `[24:21]`, max_byte `[29:25]`. Assigning 512 to a 3-bit data_width yields zero; assigning depth32 to a 4-bit data_fifo_depth yields zero. With 512-bit data and current constants, actual readback is `0x0000000000012003`, not an encoded capacity report. Error-enable advertises zero while the engine compile constant ENABLE_ERROR is one. `[P:27–37,50–53,225–238; C:109–120]`

For the fresh fabric, decode `0x10000..0x100ff` only to the supplied AHLS 256-byte CSR and translate byte offsets to its WORDS address. Do not send that address straight to csr_mgr: it would alias the DMA DFH. Existing scalar AFU status at `0x40` is a **different persona's ABI**, not this DMA's descriptor-control register. Preserve that baseline separately.

## 4. Address geometry, length, alignment, and burst limits

### 4.1 Two-bank address encoding

The selector uses the descriptor's **DDR-side** address: source for DDR_TO_HOST, destination for HOST_TO_DDR. Bits `[A+clog2(K)-1:A]` select the bank. Host-side bits never intentionally select the bank. `[S:29–42]`

| Quantity | Donor requested geometry | IA840F target geometry |
|---|---|---|
| banks K | 4 | 2 |
| per-bank byte-offset width A | 33 | 34 |
| bank-select field | `[34:33]` | `[34]` |
| aggregate byte-address width | 35 | 35 |
| bytes per bank | 8GiB | 16GiB = 17,179,869,184 bytes |
| bank1 global base | `0x200000000` | `0x400000000` |
| bank-local mask | 33-bit offset | `0x3ffffffff` |
| target combined valid global range | — | `0..0x7ffffffff` |

Target DDR descriptor encoding is `global_ddr = (bank << 34) | local_offset`, bank 0 or 1, offset `< 2^34`; bits above bit34 must be zero. Reject rather than silently masking invalid high bits. Enforce `offset + byte_count <= 2^34` and no host IOVA end overflow. A descriptor never switches physical bank on an address increment; crossing a bank end can wrap/alias inside the selected bank. Split at bank boundaries.

The actual DDR AXI interfaces remain **bank-local 34-bit byte-addressed ports**, and must receive only the low 34 bits after selection. The descriptor retains all 35 aggregate DDR bits. The selector copies interface payloads without an explicit address mask; truncation currently occurs through local-width interfaces/macros. Prefer explicit, audited DDR-only slicing at that boundary, not an IOVA mask. `[T:138–159; S:98–117; Q:580–599,653–672]`

**Critical asymmetry:** `dest_mem` replicates host_mem, but `src_mem` uses `LOCAL_MEM_AXI_MEM_PARAMS_DEFAULT`. Local PIM template `[A1:50–56]` sets that macro's ADDR_WIDTH to A. The read engine writes descriptor.src_addr into `src_mem.ar.addr` before the mux widens/copies it to host_mem. Consequently, using this local macro on IA840F retains only IOVA `[33:0]` on HOST_TO_DDR. On the donor's A=33 configuration it retains only `[32:0]`. A W-bit descriptor and a nominal HOST_ADDR_W parameter do not repair already lost high bits. **Make the internal read-source address path at least W bits wide**, through its register slice/mux, and truncate only when routing to DDR. Check burst/ID/user/data widths explicitly rather than swapping macros blindly. `[T:138–150; R:148–164; M:75–85,87–124,130–138]`

Keep H PIM-derived and preserve 64-bit software IOVA storage/accesses. H is not a request to widen physical host addressing to an invented value, nor to narrow it to 34 or 35. The auxiliary PIM host package computes byte width from line width plus log2(line bytes). `[A2:18–24]`

### 4.2 Length units and arithmetic limits

Let `B = LOCAL_MEM_DATA_WIDTH / 8`. The code uses `ceil(length / 256)` read requests, AxLEN counts beats-minus-one, and address increments of `256*B`; it never divides descriptor length by B. Therefore **length is full beats**. For an actual 512-bit fabric, B=64 and a requested byte size must be converted to `length = bytes/64`. No tail byte-enable generator exists: destination WSTRB is all ones. `[P:111–117; R:31–35,74–80,88,148–164; W:31–36,81–98,184–192,216–228]`

- Zero length underflows `length-1` and is **invalid**, not a zero-work descriptor. No rejection is implemented.
- Length is stored modulo 20 bits. Representable positive maximum is 1,048,575 beats, nominally 67,108,800 bytes at B=64. That is **not a safe supported maximum**.
- `num_rd_reqs`, `rd_req_cnt`, `num_rlasts`, `rlast_cnt`, `num_wlasts`, `wlast_cnt` are `[AXI_LEN_W:0]`, i.e. 9 bits with AXI_LEN_W=8, although the count expression requires up to 13 bits. At most 511 bursts fit without count overflow, bounding the arithmetic to 130,816 beats = 8,372,224 bytes at B=64. Length 130,817 already needs 512 bursts and truncates the stored burst count to zero. This is a necessary bound only, not operational qualification.
- There is a **separate multi-burst AWLEN defect**. After a nonfinal WLAST, the write FSM proceeds through ADDR_SETUP to SEND_WR_REQ. AWLEN recomputation tests *current* state IDLE/RD_FIFO_WR_DEST/FIFO_EMPTY, none true on that ADDR_SETUP→SEND edge, and falls back to the descriptor's low-byte tail length. For length 513 the intended read burst sizes are 256,256,1, but the AW scheduling expressions select 256,1,1. Intermediate full bursts are wrong for such nonmultiple lengths. `[W:113–119,136–148,184–192]`
- A conservative future bring-up contract can use one full-width burst per descriptor (1..256 beats, at most 16KiB if B=64) while these issues are corrected; **that restriction does not cure handshake, completion, address truncation, or error-visibility problems**. Do not present it as a qualified original engine mode.

### 4.3 Alignment and actual protocol obligations

Require both addresses B-byte aligned and the byte count a positive multiple of B. There is no unaligned/tail repair or bounds checking in the reviewed DMA. Read AX size uses source interface byte-index width; write size uses destination interface byte-index width. Data width equality between local memory and host memory is an implicit assumption: P says both host/data widths equal local width, while host_mem itself uses the host PIM macro; no DMA-side width converter is shown. Verify actual 512-bit PIM/host data width before using the numerical examples. The AHLS 256-bit clients need explicit supported width conversion to that bank fabric, not a changed DMA beat interpretation. `[P:112–116; O:187–203,290–304; R:163; W:91,187]`

Host-facing bursts are coded **WRAP**, DDR-facing bursts **INCR** in both directions. Under ordinary AXI4, WRAP supports only 2/4/8/16 beats, wraps within its aligned burst region, and AXI bursts must not cross 4KiB. This donor can request 256-beat/16KiB host bursts; the top specifically relies on PIM to translate large requests to legal host-channel requests. **Do not assume that a generic AXI bridge accepts the same relaxed PIM-facing contract, that WRAP is equivalent to linear copy at arbitrary offsets, or that PIM downstream repair excuses the upstream interface.** Bind the generated selected PIM path and either document the exact accepted contract or change the internal copy protocol to correctly split INCR bursts. Use burst-region-aligned host addresses if retaining wrap semantics; page/burst/bank boundaries must be explicit. `[R:58–69; W:65–76; O:198–202]`

At B=64 the address step is 16KiB. The write engine increments the address slice above bit13 and preserves low14 bits, mathematically adding that step; it does not implement an arbitrary-byte-tail shifter. `[W:31–36,180–202]`

**Backpressure hazard independent of length:** read ADDR_SETUP tests ARREADY in the cycle before asserting ARVALID; SEND_RD_REQ then advances without checking the actual ARVALID/ARREADY handshake. If ready falls, the request can be lost. Write AWVALID is assigned AWREADY in SEND_WR_REQ, and the initial start also waits for AWREADY; that relies on a sink that asserts ready without seeing valid. A fresh PD fabric must not inherit an undocumented always-ready assumption. Hold valid/payload until acceptance, and advance counters only on actual handshakes. `[R:103–116,148–168; W:108–119,287–290]`

## 5. Completion, response/error visibility, and physical commitment

### 5.1 What the reviewed RTL actually retires

The reader marks `packet_complete` on the final accepted source RLAST and packs `{packet_complete, r.last, r.data}` into the data FIFO. Writer `packet_complete` is unpacked from FIFO data, **not produced by a B response**. The write FSM enters WAIT_FOR_WR_RSP based on this marker/WLAST progress and asserts `wr_fsm_done = 1` whenever it is in WAIT. The reader sees that done, dequeues the descriptor, and goes IDLE. Writer WAIT returns IDLE when packet_complete is set; no successful-response count participates. `[R:86–88,114–120,136–138,180–200; W:113–153,259–308]`

Therefore retirement establishes only the engines' FIFO/WLAST control-path progress under their assumptions. It is **not proof of all destination B responses, no pending write data in register slices, downstream visibility, or physical DDR commit**. Even describing it categorically as final external W acceptance would overstate the evidence: the marker is not valid/handshake-gated in the write combinational unpacking, and the actual data FIFO implementation is missing. Intermediate register slices can still hold requests when the descriptor changes. `[M:100–124]`

### 5.2 Exceptions are not trustworthy success evidence

- RRESP is never tested in the read FSM; ERROR is declared but has no normal incoming transition. Read-error flag normally stays zero. `[R:95–122,180–207]`
- BREADY is permanently one. `wr_resp_ok` is computed but unused. The only write response error test is inside WAIT, compares SLVERR **twice** instead of SLVERR/DECERR, and loses priority to packet_complete. Errors arriving in other states are ignored. `[W:92–94,150–157,259–264]`
- Reported response encodings are forced zero both by top aggregation and csr_mgr. Thus zero response status is not evidence of downstream OKAY. `[T:86–89; C:94–97]`
- The donor DMA bank bridges actually expose BRESP/RRESP; error loss is in DMA handling, not an inevitable lack of AXI error wires. Preserve these signals through fresh PD ports. The removed DLA branch did disable response codes, so do not copy those settings for AHLS/DMA. `[Q:545–550,567–569,618–643,691–715]`

Minimum semantic repair is a stable active descriptor/mode/bank plus counts of accepted read/write requests, accepted source data, accepted destination data, and returned responses; sticky first-error/response context; descriptor retirement only after all required transport events. Do not count IRQ/fence responses as DMA-write completions. Provide a truthful completed sequence and outstanding/drained status rather than reusing the broken descriptor_count or control-bit echoes. These are proposed implementation requirements, not performed changes.

### 5.3 AXI B is a boundary, not necessarily physical DDR commit

Even after waiting for every B, identify who generated it. Auxiliary local PIM native-Avalon mapping uses `LOCAL_WR_RESPONSE(1)` at `[A3:275–283]`; its converter synthesizes a zero-error write response on `write && !waitrequest && end_of_packet`, not a memory-array commit acknowledgment. `[A4:210–237]` This establishes a concrete source example of an acceptance-level B response; **it does not identify the active generated IA840F PIM mapping**. The parent must bind that path.

The supplied corrected AHLS `extwriteack` similarly means an accepted output beat, not physical DDR commit. A constant-zero AHLS exception bus or synthesized zero-error response does not prove computation or storage correctness. Distinguish:

1. AHLS/DMA accepted-beat completion;
2. interconnect/PIM response-drained completion;
3. coherent visibility under the selected DDR/PCIe ordering contract;
4. exact numerical copyback/readback correctness.

For DDR→host, PCIe posted-write visibility and software cache/synchronization rules need the actual PIM/platform completion/fence contract; neither GO clear nor DMA WAIT proves host visibility. Auxiliary host PIM defines an explicit `HC_AXI_UFLAG_FENCE` (AWLEN=0 plus W packet). The donor DMA generates no such fence, and its IRQ mux zeros normal AW/W user flags, which would erase a newly added fence unless that path is adapted. `[A5:24–32; W:164–170,216–228; H:136–167]` This is a review requirement, **not permission to issue a live fence or MMIO probe**.

### 5.4 Bank/mode handoff and IRQ ownership

Selector channel_select is driven continuously by the current FIFO-head descriptor. All-bank ARREADY/AWREADY/WREADY are AND-reduced; RVALID/BVALID and valid-masked payloads are OR-reduced. Unselected banks get RREADY=BREADY=1. Therefore an unrelated bank's low ready can block the selected DMA, late responses from an old bank can be consumed after selection changes, and overlapping responses can be OR-corrupted. `[S:29–42,60–116]`

The fresh per-bank arbiters must route only that DMA client's responses back to its donor input (never mix AHLS responses). Select request-ready and response payloads by the active transaction context, and do not release that context until drained. Merely replacing all-bank ready ANDs with a mux is insufficient while old-bank responses remain outstanding. Mode switching also reroutes host/DDR channels outside the source/destination register slices. `[M:87–146]`

No DMA IRQ output appears in dma_top. The top's IRQ comes from the DLA wrapper and is muxed onto host writes; it is not a donor descriptor-completion interrupt. The IRQ mux forwards all host B responses to DMA and does not itself separate IRQ response ownership. Preserve one host-channel0 owner and implement any new AHLS/DMA IRQ policy deliberately. `[T:26–37; O:1296–1297,1347–1354; H:158–166]`

## 6. Reset, stop, and quiescence assumptions

- All DMA/CSR/PD-side interfaces are assumed synchronous in bank0's core clock/reset domain. csr_mgr independently uses its MMIO clock/reset; dma_top uses host_mem clock/reset; there is no explicit CDC between its CSR map and descriptor FIFO. The donor top makes those domains common and uses PIM CDC shims for the host and each physical bank. Preserve separate bank-side clocks. Do not mix the older uClk_usrDiv2 composition into this direct wiring. `[C:39–43; T:43–51; O:38–57,246–275,306–331]`
- Actual module reset is active-low and synchronously sampled by the reader/writer/CSR always_ff blocks. Descriptor FIFO reset input is top reset_n only. Reset in flight is not a defined flush/cancel protocol for the downstream host or memory system. PIM reset/PR-freeze sequencing, clock availability and per-bank calibration readiness are external prerequisites, not proven by these modules. `[T:108–123; R:90–93,124–135; W:100–103,163–170,216–228; C:316–322]`
- `reset_dispatcher` is visibly used by the writer only to leave ERROR; it does not generally reset all state, data FIFO, descriptor FIFO, or pending bus requests. The absent dma_engine may add behavior; that cannot be assumed. The status resetting bit is just its software echo. `[W:150–157; T:111–123,177–193; C:101]`
- `stop_descriptors` gates FIFO **dequeue only**, not enqueue and not the reader's GO/not-empty start condition. With it asserted, a completed FIFO head can remain GO=1 and be executed again when the reader returns IDLE. It is not a reliable pause-before-start or drain primitive. `[T:74,121; R:98–101,118–120,198–200]`
- Neither read-engine start nor the visible write start uses stop_dispatcher or stop_on_error. The missing engine prevents a complete whole-system control trace; the visible CSR echoes are still not acknowledgments. `[R:17–29,98–101; W:108–111; T:177–193]`
- PD bridge defaults include BACKPRESSURE_DURING_RESET=0; an asserted reset must not be inferred to advertise safe readiness or traffic cancellation. `[Q:150,585,658]` The host IRQ mux also locally pipelines reset release, a distinct reset boundary. `[H:50–60]`

**Required quiescence definition for adaptation:** stop new submissions and new AHLS starts; block new descriptor starts; finish already accepted transfers; account for all request/data/response queues, arbiters and clock crossings; publish a stable drained state; only then permit the separately authorized lifecycle action. Keep host buffers pinned until the selected visibility contract is satisfied. No MMIO sequence using the existing stop/reset bits can be recommended as a source-proven way to achieve this. A timeout is unresolved outstanding traffic, not permission to reset/reconfigure/retry hardware.

## 7. PIM-derived versus hardcoded: minimum adaptation deltas

| Boundary | Source origin / current behavior | Minimum IA840F action (not performed) |
|---|---|---|
| PIM bank count / byte offset / data | PIM-derived in `[P:104–116; O:29–32]` | Verify resolved K=2, A=34 and actual data width. Do not equate physical x64 DDR with a 64-bit fabric. |
| Host address width | H from host PIM; top fallback57 `[T:26–40]` | Keep H unchanged; maintain 64-bit software IOVA values; audit complete read and write paths. |
| Internal source interface | local-width macro `[T:143–150; A1:50–56]` | Widen internal source address to max(H,35), preserve it in register slice/mux, then explicitly slice low34 only for DDR. |
| Bank-selection field | `clog2(K)` above A `[S:29–42]` | For target, bit34; reject high DDR bits and crossing descriptors; retain bank-local AHLS pointers without OR-ing bit34 into AHLS's 34-bit ports. |
| PD bank dimensions | independent Tcl defaults 4/33/512 `[G:4–8; Q:580–599,653–672]` | Fresh parent PD: two banks, 34-bit AXI byte addresses, actual PIM data width; supported 256→fabric-width AHLS conversion and per-bank arbitration. Derive/verify rather than assume Tcl follows PIM. |
| Explicit bank enables | four preprocessor defines `[E:14–20]`, guarded ports in O | If reusing donor wrapper fragments, enable only0/1, remove bank2/3 connections and out-of-range array references. Parent fresh wrapper need not retain DLA macros. |
| Span-extender branch | hardcoded 35-bit aggregate AXI `[Q:219–226]`, stride8GiB `[Q:828–832]` | If omitted from new minimal fabric, no span-extender delta is needed. If retained, stride becomes `0x400000000`; aggregate35 is already sufficient, but missing ase_hw.tcl internal window must also agree. |
| DMA CSR map | 16-bit PD aperture, low8-bit aliased decoder | Retain base0 and safe64-bit accesses; kernel at0x10000 with256-byte span; explicit decode before narrowing. Decide DFH/UUID/persona contract rather than copying AI UUID/EOL as AHLS identity. |
| Descriptor/FIFO | 20-bit length,16 entries,32 data entries `[P:27–28,111]` | No geometry-only need to expand length; bound/chunk correctly, reject invalid/full submission, repair counts/AWLEN if supporting larger transfers. Missing engine/fifo files must be supplied before data-FIFO conclusions. |
| AXI length / burst / backpressure | hardcoded8-bit LEN and9-bit burst counts, host WRAP, early ready assumptions | Ensure interface LEN fields really support eight bits; explicitly configure DMA interfaces or derive limits. Correct transfer admission/handshake and burst generation before claiming generic fabric compatibility. |
| ID and user fields | hardcoded16→18 PD IDs and donor bit17:16 compression `[O:34–35,1134–1240; Q:591,598,664,671]` | Fresh two-client arbitration may require a different routing-tag budget. Derive full ID round trip from generated fabric and PIM widths, preserve distinct AHLS/DMA response ownership; do not paste donor's three-client compression masks. |
| Error/complete/drain | no successful-B retirement; incomplete error decoding; status defects | Add truthful completion/outstanding/error state and stable mode/bank, preserve response codes, distinguish acceptance from commit, bind required visibility/fence behavior. |
| Host/IRQ services | primary channel0 only, shared IRQ mux clears user flags | Keep one mapper; preserve existing services, and partition DMA/IRQ/fence completions. Do not treat AHLS done/IRQ as automatic DMA drain. |
| Clock/reset | common bank0 AFU side, per-bank PIM CDC | Keep that coherent composition or deliberately adapt all boundaries. No invented calibration/reset success from port wiring. |

Geometry calculations do not change aggregate DDR width: both 4×8GiB and 2×16GiB total 32GiB. The change is the bank/offset split and per-bank interfaces, not host IOVA width. No blanket 35-bit or 34-bit mask may be applied to host addresses.

The scalar AFU and host-service library remain separate preserved baselines. The parent must bind `gmem0` and `gmem1` to the intended physical bank shims in the new composition. Serial selected-bank DMA does **not** demonstrate simultaneous DDR traffic; simultaneous AHLS/bank exercisers and exact numerical copyback remain distinct future evidence.

## 8. Missing source and smallest follow-up

These exact pinned donor files are listed in the retained source tree/filelist but absent from the cache; no substitutes were treated as their contents:

| Missing path relative to D | Retained Git blob identity | Consequence |
|---|---|---|
| `ip/dma/dma_engine.sv` | `ca43851a04c84a7da510be293529c20807957eca` | Cannot finish internal data-FIFO depth/tag wiring, engine control/reset interaction, response-FIFO status, or parameter-use trace. Top instantiates it at T:177–194. |
| `ip/dma/dma_fifo_if.sv` | `cd903bff64957489088ff361f2100c50dfaedf79` | Cannot independently verify FIFO interface/tag widths and declarations. |
| `ase_hw.tcl` | `14e9ca345d5dd284335f51cc9667f12aae5f3724` | Only needed if parent retains span extender; internal window/control geometry not reviewed. |

`filelist.txt:14–23` confirms the two DMA files are required. A bounded local filename search found only the separate tutorial `N/examples-afu/tutorial/afu_types/01_pim_ifc/dma/hw/rtl/dma_engine.sv`; it was **not** substituted for the pinned AI Suite engine. No remote acquisition was attempted.

Smallest source follow-up: have the parent provide those first two exact blobs locally, plus the **selected generated** PIM local/host configuration and macro files defining K/A/data/burst/ID/H, and the selected local-memory AXI shim/native mapping. Inspect only those dependencies and the parent fresh-fabric interface map. If retaining the span extender, add its one missing Tcl file. This is a finite source request, not another broad donor survey or a precondition invented for native launch.

For any later authorized functional qualification, focus first on high IOVA bits, bank1 and the upper half of each16GiB bank, short/full/tail bursts, lengths around burst-counter overflow, backpressure changes after ready, delayed/error B and R responses, mode/bank handoff, and truthful drain. Those are **test requirements, not tests run here**; no DDR vendor simulation is requested by this review. Keep simultaneous-bank load, exact numerical copyback, and platform reset/visibility evidence separate from interface-elaboration success.

## 9. Verification performed and limits

- Direct local source inspection of all eight requested entry files, with targeted Tcl/header/IRQ dependencies.
- Recomputed SHA256 for the **13 donor files in §10**, compared each to retained `captures/source-manifest03.json`: **13/13 matched**. The manifest is retained provenance for the supplied immutable pin; no git/network validation was run.
- Used local Python arithmetic for descriptor packing, status/config packing, bank masks/strides, burst-count overflow and length conversions. These are static calculations, **not RTL execution or simulation**.
- Auxiliary PIM source hashes recorded separately; they are local-template evidence, not proof of the generated active image.
- No implementation changes or execution results were produced. Missing dependencies, actual resolved PIM widths, full reset/drain semantics, physical commit/host visibility and numerical correctness remain explicitly unverified.
- The whole-file SHA256 of this finalized report is returned in the handoff message after writing; it is intentionally not self-embedded, so the digest covers the exact file bytes.

## 10. Source key and SHA256 inventory

All donor paths below are relative to D and correspond to the supplied pin. Remote location for provenance only (not fetched during this review): `https://github.com/altera-fpga/agilex-ed-ai-suite/blob/e0e07f7b1878a477dc4d1191918db8430193e148/agilex7/iseries_ofs_pcie/` plus the path.

| Key | Donor file | SHA256 (verified against retained manifest) |
|---|---|---|
| P | `ip/dma/dma_pkg.sv` | `aa0668a1b3dd0e6553cd0d7673b2b040a615094493e8a0b747f76a0e562dba99` |
| C | `ip/dma/csr_mgr.sv` | `e3ab7d4e79836bed79bcebdd3922d31a1750d2f5481faeb831f3f0a105a79463` |
| T | `ip/dma/dma_top.sv` | `a527dedc0250cae2a8394d91b32f3938d62fb4f7ff88115031b27999d4340400` |
| S | `ip/dma/dma_ddr_selector.sv` | `e95431355bd035e7a0f05a5be370d967bd7992bf013fa34588e41f82944ae2e1` |
| R | `ip/dma/dma_read_engine.sv` | `9383e34c8dfda15ea1d77a3b7cce37b9b6e3292e85a037001a1054ad8ed3c4b2` |
| W | `ip/dma/dma_write_engine.sv` | `fe85a45f43743fb161f48caa4157d9b22c33a6ea40a33a102613140531b8b682` |
| M | `ip/dma/dma_axi_mm_mux.sv` | `4dcaedc0f35b2fbee172b971cedf14d434a0d8d95ef4179280a37dde1ac07806` |
| O | `ofs_plat_afu.sv` | `f958ec2723fd851847b4f05b65e1465863b4528f0958edca5294b33462346166` |
| G | `parameters.tcl` | `9eeb28346530dbd6c188416d5d450c4c2052b2718518333cc4f3480d3ca0d813` |
| E | `ofs_dla.vh` | `2a6b3bd87a342a39acaa084cd42051e0c30b7fafe4ac552de8bb5e2cf8dd1b80` |
| Q | `dla_afu_hw.tcl` | `f1aaaa6bbfc34341c9b4a961bc6af0f9b7994a10630e39074ebc53c846a1862f` |
| H | `dla_host_mem_if_mux.sv` | `978ed22047b766b8fa96d467e98bc954544eea2d43384bcd2e289cc4c5eb2b49` |
| F | `filelist.txt` | `2d4d88708fee5f8510571b0807309d10ec2b1f309c52fc083132ba26f3e3d639` |

Auxiliary root `A = N/ofs-platform-afu-bbb/plat_if_develop/ofs_plat_if/src/rtl`. These files are **not asserted to be at the AI Suite pin or the active generated PIM revision**:

| Key | Local PIM path relative to A | SHA256 |
|---|---|---|
| A1 | `ifc_classes/local_mem/afu_ifcs/ofs_plat_local_mem_GROUP_axi_mem.vh` | `4a5c99ae529e310d06ed7e844fc1535eda4c8f6891c1df9a676c4cf9cd4f7d3d` |
| A2 | `ifc_classes/host_chan/afu_ifcs/include/ofs_plat_host_chan_GROUP_pkg.sv` | `610f5903e3ea06874c90b5a8e5860c15ba8943679c2046a0aac9a4485c49941d` |
| A3 | `ifc_classes/local_mem/native_avalon/ofs_plat_local_mem_GROUP_as_axi_mem.sv` | `1a7ec227a7ee40937e2e4335abf26cb5889d4515a35f13dbecb465431285f313` |
| A4 | `base_ifcs/avalon/prims/ofs_plat_avalon_mem_rdwr_if_to_mem_if.sv` | `9604ee941d32430080fe17840879923bd0516d988b6e27c2ebc54725449bb564` |
| A5 | `ifc_classes/host_chan/afu_ifcs/axi/ofs_plat_host_chan_axi_mem_pkg.sv` | `53f2237eb33dd4c632858d34b547f52bedf0c481cc26eca90b3639261a01ec20` |

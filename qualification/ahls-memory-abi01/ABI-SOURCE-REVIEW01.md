# DDRIP ABI source review — AHLS 2026.1.0

## Disposition

**Pointer packing/projection and CSR indexing are resolved at the captured RTL boundary. Finish accounting is resolved as a two-bit, delayed-clear-on-read counter, with a read/completion collision hazard. Downstream write retirement is NOT accepted: the active generated interconnect synthesizes external write acknowledgments without qualifying them by `!waitrequest`.**

This is local source research, not hardware acceptance, an implementation change, or authorization to execute anything. Only this report was authored. No SSH, device access, vendor tools, compilation, simulation, sample execution, source edits, or git changes were performed. The running workstation/FIM build was not contacted.

### Actionable boundary mapping

- Program component-relative byte offsets **x `0x80`, y `0x88`, z `0x90`, size `0x98`; start `0x08`; status `0x00`; finish `0x30`**. The imported `_di` CSR address is a **64-bit-word index**, respectively **16, 17, 18, 19, 1, 0, 6**. Do not shift twice or connect raw byte offsets to the five-bit `_di` input.
- Each pointer occupies one 64-bit CSR slot, but only its low **34 bits** survive CSR packing. x/y are internally zero-extended; z is internally rebuilt as `0x20000000000 | pointer[33:0]`. All three LSU wrappers then project effective addresses to **34 bits**. The high memory-2 prefix is real compiler-internal encoding, not a required software-supplied prefix or a physical host address.
- x/y use `avm_mem_gmem0_1_port_0_0_rw`; z uses `avm_mem_gmem1_2_port_0_0_rw`. These are independent, **byte-addressed**, 256-bit hosts with 32-byte-aligned output addresses. Source buffer groups do not establish physical FIM bank numbers.
- Read the finish slot as an aligned 64-bit read at **`0x30`**; meaningful data is **bits `[1:0]`**, bits `[63:2]` are zero. It wraps modulo four, is not a monotonic software counter, and is not cleared by start. Do not use the duplicate generated `FINISHCOUNTER_REG` macro unchanged.
- Do **not** equate `done` with accepted downstream stores, DDR persistence, DMA completion, or CPU visibility. The active pending-write logic attempts to wait beyond LSU enqueue, but its acknowledgment producer has a concrete backpressure-accounting defect described below.

## Evidence identity and citation convention

Repository: `/home/joe/Projects/Thesis/AHLS/new_bsp/new`.

`P/` below means `qualification/ahls-memory-abi01/artifacts/build/mmhost_ia840f.report.prj/` relative to that repository. `K/` means `P/kernel_hdl/DDRIP/`. All cited lines are original extracted-file line numbers, not normalized or regenerated text.

For readable exact citations, these aliases name single files:

| Alias | Exact file under the above roots |
|---|---|
| D | `P/mmhost_ia840f_report_di.sv` |
| C | `K/DDRIP_function_cra_agent.sv` |
| W | `K/DDRIP_function_wrapper.sv` |
| A | `K/DDRIP_i_sfc_logic_s_c0_in_for_body_i_ddr0000ter1591_ddrip_90_0gr.sv` |
| B | `K/DDRIP_bb_B1_stall_region.sv` |
| E | `K/DDRIP_i_sfc_logic_s_c1_in_for_body_i_ddr0000_enter_ddrip_361_0gr.sv` |
| L0 | `K/DDRIP_i_llvm_fpga_mem_memcoalesce_load_d0000ique_0_ddrip_329_0gr.sv` |
| L1 | `K/DDRIP_i_llvm_fpga_mem_memcoalesce_load_d0000ique_1_ddrip_405_0gr.sv` |
| S | `K/DDRIP_i_llvm_fpga_mem_memdep_ddrip_467_0gr.sv` |

Integrity checks performed with byte-preserving Base64 decoding, SHA-256 and exact byte comparison:

1. `result01.json.gz` SHA-256 matches **`433f3bb0135bb3c955a1598c03237d52fe230d09f8fe93e25210f7777a2ea263`**. Collection identity is `ia840f_ahls_memabi01`, timestamp `2026-09-23T05:29:26.711219+00:00`.
2. **169/169 members, totaling 3,450,821 bytes**, match their embedded sizes/hashes and extracted local bytes. Each also matches the size/hash in the **original** `qualification/ahls-memory-ip01/result01.json.gz` generated inventory. This independently repeats the parent's member verification; it is not merely trust in collector success flags.
3. The preceding `qualification/ahls-memory-ip01/result-independent-review01.md` matches SHA-256 **`27f5e0aa865441a6979066095d7f90f4bf78bc59905a797ae2e5feb297cfef4a`**. Its report-generation-only acceptance is not expanded into native import or hardware acceptance here.
4. `afu/ahls_memory/src/mmhost_ia840f.cpp` remains SHA-256 **`bbc41b6fb33646066a42d7fa1b009aca46ebc8a1f295feb0f8d200fe63f37b64`**, the preceding review's exact source. Its pin is hls-samples `2026.1.0`, commit `0abae6d78af5daca3fe5d67e617ab037e58aff89`; the preceding review established only the two `awidth<32>` to `awidth<34>` edits plus provenance comments. Source lines 14–43 retain x/y buffer location 1, z location 2, alignment 32, 256-bit data, maximum burst 8, signed `int size`, eight-way unroll, and `z[i] = x[i] + y[i]`.

Selected captured hashes:

| File | SHA-256 |
|---|---|
| D | `c072b420ca510e98de233184d1fc7664b50a158714f5516b82991452e2540756` |
| `P/kernel_system.sv` | `c826ac8842403f9392d531b72380f47e48c25ce60272930e885124cabaf8d8ea` |
| C | `2f011cfb6aacb19cef4dab7e9648b0607def46ddf8d926b7ef11eb8c54d6bdc7` |
| W | `3d7fa2711e80e2057e9bfa314a9802b0b8659bac5b37967915bca15a0ab115c5` |
| S | `9699246eeef923fc4fa182ce125e62927ace8cd52118b9a235513b2a1cdfd717` |
| `P/ip/lsu_top.sv` | `873549f18428fe6ba0797fef228c2028bf1df62076e85f1942c9dca5310cf8a0` |
| `P/ip/lsu_burst_coalesced_pipelined_write.sv` | `a1662618eab5784456b0bde941648383532109b68045d520af58f5ab14932cce` |
| `P/ip/lsu_ic_top.sv` | `35ec54a3a59e24a52b317a6cba670499061bba1ff00d5ba5e6bcc6726421ddbe` |
| `P/ip/lsu_token_ring.sv` | `0ba6bc0d7f5bb8c34282930c227546398d05434a5de035372d029a01401f9719` |
| `P/ip/acl_has_pending_write.sv` | `b15b7d70b00ffa42fcfce0cfbcc45a0d9e5f02d1d3ab36b1f6e1cab31fd96f4d` |

## 1. Active hierarchy and address units

The component fileset explicitly selects `mmhost_ia840f_report_di` as top and includes D (`P/mmhost_ia840f_report_di_hw.tcl:10–14`). D instantiates the DDRIP partition, CRA ring, both interconnects, generated function wrapper, and actual finish detector (`D:127–181,183–316,327–353,456–477,498–597,656–707`). This analysis follows those instantiated paths, not every generic LSU library option shipped in the capture.

The generated alternative outer hierarchy is useful independent corroboration: `P/kernel_system.sv:80–122` instantiates `_sys`, which instantiates `_di` with direct CSR wiring (`P/mmhost_ia840f_report_sys.sv:78–119`). **`kernel_system.sv:127` explicitly implements `sys_cra_ring_address = kernel_cra_address >> 3`** into a five-bit signal declared at line 73. `_sys` does not add another conversion. Thus `_di` consumes byte-address bits `[7:3]`, while the outer `kernel_system` consumes a byte address. High outer address bits are discarded, not validated: an integrating aperture decoder must prevent aliases outside the intended 256-byte CSR window.

Within D the root/node both have five address bits, 64-bit data, `ID_W=0`, and `ZERO_LATENCY=1`; root waitrequest allowance is zero (`D:763–819`). Active root logic qualifies read/write with `!avs_waitrequest` and passes address/data/byteenable unchanged (`P/ip/cra_ring_root.sv:181–212`). Active node logic has unconditional ID match, preserves all five address bits and forwards byteenable/data (`P/ip/cra_ring_node.sv:87–109`). C compares these word indices directly.

**Distinct unresolved import question:** `P/mmhost_ia840f_report_di_hw.tcl:382–448` declares both hosts and CSR but does not set `addressUnits`. Its CSR `addressAlignment DYNAMIC` is not an explicit address-unit setting. The above RTL proves what the boundary requires, **not** what Quartus 25.1's native importer will infer or how an eventual generated adapter will implement it. Required semantics are memory-host byte/symbol addresses and `_di` CSR 64-bit-word addresses. No native 25.1 discovery/import/validation/generation was executed or accepted here.

## 2. CSR payloads, byte enables and launch

`P/include/register_map_offsets.h:4` places DDRIP at component offset zero. This is not a PCI BAR base.

| Register | Component byte offset | `_di` address | Actual payload/behavior | RTL evidence |
|---|---:|---:|---|---|
| Status | `0x00` | 0 | Low 32 bits contain version 5 in `[31:16]`, running `[15]`, busy `[2]`, done `[1]`; upper 32 bits zero | C:220–230,348–367,400–404,491–531,545–600 |
| Start | `0x08` | 1 | Write low-lane bit 0 = 1, with byteenable bit 0 asserted | C:232–311 |
| Finish | `0x30` | 6 | Read `{62'b0, counter[1:0]}`; schedules clear irrespective of read byteenable | C:442–489,539–543,578–613 |
| x | `0x80` | 16 | Low/high 32-bit words become arguments 0/1 | C:823–891 |
| y | `0x88` | 17 | Low/high 32-bit words become arguments 2/3 | C:753–821 |
| z | `0x90` | 18 | Low/high 32-bit words become arguments 4/5 | C:668–748 |
| size | `0x98` | 19 | Low 32-bit arguments 6; upper lane unused | C:630–663 |

**Writes:** each of the eight CSR byteenable bits is replicated to its eight data bits; argument byte updates preserve unselected bytes. Low data `[31:0]` corresponds to BE `[3:0]`, high data `[63:32]` to BE `[7:4]` (`C:232–266,351–355,677–693`, then each argument's masked update). Full pointer writes therefore use BE `0xff`; low-32-bit size/start writes can use BE `0x0f`. A split upper-32-bit access, if an integrating bridge supports one, must place data in `[63:32]` with BE `0xf0` and the same word index—not increment that index. This review does not certify such a bridge. Aligned 64-bit pointer writes avoid that ambiguity.

**Reads:** C does not mask readdata by byteenable. Finish read-clear tests only address 6 and read (`C:451–468`); reads with only high-lane byte enables, or even no byte enables at this raw boundary, still schedule the same clear. Argument-address reads do **not** read back the programmed arguments: the non-finish read mux returns status in the low lane, normally zero in the high lane (`C:548–587`). Word 1's high read lane selects `acl_counter_size`, which D's CRA instantiation does not connect (`C:551–561; D:456–477`); this is not a supported start-register readback contract. Use status at word 0, not incidental mirrored status at holes.

**Launch:** the start write becomes a self-clearing start-register bit (`C:271–311`). It is buffered while running and dispatched when idle (`C:313–349`). The buffered argument registers are copied to the active argument registers on `start_from_buffered_start_NO_SHIFT_REG_q`, then the packed bus is pipelined twice (`C:655–663,705–739,778–812,848–882,893–907`). Start has its own pipelining (`C:909–955`), and the instantiated start-chain element forwards it to the function and finish logic (`D:550–565; P/ip/acl_start_signal_chain_element.sv:58–84`). This is not an arbitrary-depth invocation queue; busy reflects a buffered start while running (`C:400–401`). Do not overwrite buffered arguments or issue repeated starts as if every start owned an independent argument snapshot.

The conservative future host contract is one in-flight invocation, all argument bytes established before start, and no status-register writes. Although the header describes status as read-only, C contains a masked write path for low status bits (`C:357–367,503–529`); writing those bits can manufacture misleading status and is not needed for ordinary execution.

## 3. Pointer packing, prefix and projection

C first stores all 64 software-written pointer bits, but the **active kernel argument bus is not a verbatim copy**:

- x: join arguments 1/0, extract `[33:0]`, prepend 30 zero bits (`C:750–751,884–891`).
- y: join arguments 3/2, extract `[33:0]`, prepend the same zeros (`C:814–821`).
- z: join arguments 5/4, extract `[33:0]`, prepend constant `30'b000000000000000000000010000000` (`C:665–666,741–748`). That constant is 128; shifted by 34 it is **`0x20000000000`**, matching `P/board_spec.xml:6–7`.
- Packed `[223:0]` order is `{size[31:0], z_internal[63:0], y_internal[63:0], x_internal[63:0]}` (`C:893–907`). W explicitly selects x `[63:0]`, y `[127:64]`, z `[191:128]`, size `[223:192]` and feeds the function (`W:133–150`).

Consequently, software-written bits `[63:34]` are ignored. A canonical software payload for this raw component is the desired **per-host byte offset**, not a CPU virtual pointer and not an assumed FIM-global address. Software need not supply the memory-2 prefix: C adds it. Conversely, supplying that prefix does not transmit it to the 34-bit host.

A's active address generation uses the synchronized x/y/z argument values, drops the low five base bits and inserts zeros (`A:832–856,914–935,995–1016`). It scales the nonnegative loop index by four bytes and adds it to the aligned base (`A:858–907,937–956,1018–1037`). The returned address fields identify x, y, z explicitly (`A:1115,1123–1124`). B selects the x field into load 0, the y field into load 1, and delays the z field into the store (`B:872–887,1449–1473,1931–1948,2025,575`). Both load wrappers explicitly take `in_i_address[33:0]` (`L0:143–145; L1:143–145`), as does the store wrapper (`S:144–155`). **No bit-41-dependent physical bank decoder exists on this path.**

The LSUs disable bank permutation (`L0:183–222; L1:183–222; S:185–224`); `P/ip/lsu_permute_address.sv:114–120` is the resulting identity branch. D routes both read LSUs into one read-only interconnect and the store into a distinct write-only interconnect, each with one memory system/one bank and bank interleaving disabled (`D:142–180,183–243,254–316`). `P/ip/lsu_ic_top.sv:531–546` removes five low zero bits for its internal word addressing and restores those zeros at its external output. `P/ip/lsu_token_ring.sv:129–136` loses no bank bits with `NUM_DIMM=1`. D finally assigns those addresses directly to the two host ports (`D:245–253,318–326`).

For valid aligned pointers and in-range execution, each eight-int group's host byte address is its local base plus the group's byte offset, truncated to 34 bits; successive eight-int groups advance by 32 bytes. A wrapper must reject invalid ranges rather than rely on truncation. Low-five-bit clearing is a compiled alignment assumption, **not support for misaligned buffers**. Likewise, CSR high-bit discard is aliasing, not a bounds check. Require 32-byte-aligned bases and ensure the complete accessed memory extent stays within the intended per-host aperture; `2^34` is 17,179,869,184 bytes, not proof the attached physical bank supplies that capacity.

**Physical bank mapping remains a wrapper decision.** The proposed bank0-reads/bank1-writes arrangement is compatible with these separate logical ports but is not established by buffer locations 1/2 or the XML prefix. No physical bank, DMA mapping, or PCIe address identity was verified.

## 4. Memory byte enables, alignment and bursts

The actual LSU parameters are `AWIDTH=34`, `WIDTH_BYTES=MWIDTH_BYTES=32`, `ALIGNMENT_BYTES=32`, `BURSTCOUNT_WIDTH=4`, `STYLE="BURST-COALESCED"`, `HYPER_PIPELINE=1`, `USE_STALL_LATENCY=1`. Loads have `READ=1`, no cache, and no byteenable input; the store has `READ=0`, `USE_BYTE_EN=1`, `USE_WRITE_ACK=0` (`L0:183–222; L1:183–222; S:185–224`). These select **`lsu_burst_coalesced_pipelined_read/write`**, not `hld_global_load_store` or the generic non-aligned LSU branch (`P/ip/lsu_top.sv:1116–1187,1214–1305`).

- Loads issue full 32-byte words; their active implementation sets `avm_byteenable='1` (`P/ip/lsu_burst_coalesced_pipelined_read.sv:918–920`). The active interconnect's read output also uses all-one byte enables (`P/ip/lsu_token_ring.sv:1373–1385`). For a positive size not divisible by eight, reserve/readably map the rounded-up final 32-byte input word; individual unused input lanes are not prevented from being read by byte enables.
- Store data is `{element7,...,element0}`, each element 32 bits (`S:132–133`). E makes **four adjacent byteenable bits per element predicate**, preserving lane order (`E:64–93,98–100`; the long line 93 was parsed to verify all 32 bit selections). B propagates that mask into the store (`B:934–949,1002–1009,1070–1084,1430–1431,1472–1473`). The mask is not always all ones: it protects inactive lanes of the final unrolled group. Do not widen every write into an unconditional full-word store.
- The active write coalescer preserves input byte enables, zeroes predicated/invalid inputs, combines enabled data bytes, and carries enables to the memory port (`P/ip/lsu_burst_coalesced_pipelined_write.sv:282–298,480–490,518–537,1012–1017`). It clears low address bits in the output address (`same file:576–579,880–888`). Any 256-bit-to-FIM width adapter must preserve masks, address lane selection and burst semantics.
- Maximum burst eight is the source/XML contract (`afu/ahls_memory/src/mmhost_ia840f.cpp:19–33; P/board_spec.xml:4,7`), not permission to interpret four burstcount bits as sixteen valid beats. One beat is 32 bytes; the maximum declared burst is 256 bytes. Respect zero-allowance `waitrequest` and `readdatavalid`; the generated source does not grant fixed-latency read assumptions.

Signed-int source arithmetic is unchanged. Future numerical tests should avoid signed-32-bit overflow and negative/invalid sizes unless separately specifying and reviewing such cases. No numerical correctness, tail execution, throughput, or error handling was exercised here.

## 5. Finish counter and read-clear timing

### Width and status

C declares `finish_counter_NO_SHIFT_REG_q` as `[1:0]` (`C:102`), adds a qualified finish pulse using a three-bit temporary and retains only `[1:0]` (`C:442–449`), then zero-pads to 64 bits (`C:539–543`). It therefore **wraps modulo four**, does not saturate, and is neither two duplicated 32-bit counters nor one 64-bit counter. The generated header's duplicate `DDRIP_REGISTER_MAP_FINISHCOUNTER_REG` definitions at `0x30` and `0x34` are unsafe (`P/include/kernel_headers/DDRIP_register_map.h:26–28,80–88`). An upper-lane-only read at `0x34`, if translated correctly by a bridge, returns zero data yet clears the same counter. An unaligned 64-bit read at `0x34` has no justification here.

A finish is counted only on `kernel_done && !last_finish_state && running` (`C:412–429`). Start is not a counter-clear condition (`C:451–489`). Done status is recomputed from a nonzero finish counter **or** `kernel_done && running` (`C:403–404,491–501`); running clears on kernel_done unless a new buffered start is being dispatched (`C:223–230,348–349`). Thus an old undrained completion can keep done asserted during a subsequent invocation. Status reads themselves do not clear the finish counter. Busy is not a substitute for running.

### Exact clock-edge behavior

Define pre-edge values: `C_t` is the two-bit counter, `F_t` is the qualified finish pulse, `R_t` is `avs_cra_read && address==6`, and `Q_t` is the registered clear request. The implemented sequential equations, ignoring reset, are:

```
Q_(t+1) = R_t
C_(t+1) = Q_t ? (F_t ? 1 : 0) : ((C_t + F_t) mod 4)
read_data_(t+1) = zero_extend(C_t)   when address==6
read_valid_(t+1) = avs_cra_read_t
```

These follow `C:431–489,578–613`; they are algebraic source interpretation, **not a simulation result**. The CRA agent samples read data on the read edge; its clear occurs one further edge later. BE and `avs_cra_enable` do not qualify that clear. The enclosing ring's read strobe has already been waitrequest-qualified.

**Collision hazard:** a finish pulse on the *read-sampling edge* is absent from returned old `C_t`, is added into the counter on that edge, and is then erased by the delayed clear on the next edge unless another finish occurs then. A finish on the *clear edge* is retained as one. Do not describe this as a fully lossless atomic fetch-and-clear. Closely spaced destructive reads also interact with the delayed clear; returned values are not independent atomic completion tickets.

For later host design, drain/verify an **idle** baseline before start, use non-destructive status polling, and read the aligned finish slot only after completion is quiescent with no queued start. Do not poll finish destructively during the completion transition. This avoids relying on the collision behavior, but **does not solve the downstream-write issue below** and is not a hardware-test authorization.

## 6. Does done wait for downstream writes?

### The active design attempts a downstream drain

The raw function-valid path can finish before the memory system is empty: `USE_WRITE_ACK=0` selects the write LSU's early valid-release branch (`P/ip/lsu_burst_coalesced_pipelined_write.sv:1268–1307`). However, that parameter **does not eliminate write-pending tracking**:

1. The same active LSU instantiates `acl_has_pending_write` unconditionally. It increments for **LSU-side accepted write beats**, `avm_write & ~avm_waitrequest`, and decrements for `avm_ext_writeack` (`same file:1036–1048`). Its `o_active` OR includes this pending flag as well as input/coalescer/FIFO/Avalon/valid-generator activity (`same file:1392–1401`). `P/ip/lsu_top.sv:1634–1647` adds a register to the active output.
2. S exposes that active signal (`S:251,265–266`), B forwards it (`B:1490,2160`), and it reaches the function and wrapper unchanged (`K/DDRIP_bb_B1.sv:170,200; K/DDRIP_function.sv:280–287; W:260–270`). Both wrapper `has_a_write_pending` and `has_a_lsu_active` are **this store-LSU active signal**, not independently measured downstream/global idle flags.
3. D connects it to the task finish detector (`D:567–581`). The detector remembers raw kernel valid-out and only sets finished when that remembered valid exists **and pending write is false**; `PIPELINE_VALID_OUT` defaults to one and is not overridden (`P/ip/acl_task_copy_finish_detector.sv:26–38,59–94`). The finish-chain element forwards completion into the CSR's `kernel_done`; C edge-detects it (`D:450–465,583–597; P/ip/acl_finish_signal_chain_element.sv:59–105; C:412–429`). No assumption about the preceding scalar AFU is needed.

### Active acknowledgment producer is not acceptance-qualified

For the write host D explicitly sets **`HYPER_PIPELINE=1`, `ENABLE_BSP_WAITREQUEST_ALLOWANCE=0`, `ENABLE_BSP_AVMM_WRITE_ACK=0`, `NUM_RD_PORT=0`, `NUM_WR_PORT=1`, `NUM_DIMM=1`, `NUM_AVM_OUTPUT_PIPE_STAGES=1`** (`D:254–292`) and wires both synthesized acknowledgment paths back to the LSU (`D:298–315,535–547`). The declared external host `writeack` input is not the active retirement source.

The instantiated `lsu_ic_top` takes its ordinary token-ring path (`P/ip/lsu_ic_top.sv:654,727–798`). With one write port, the token ring takes `GEN_SINGLE_PORT` (`P/ip/lsu_token_ring.sv:135–136,1402–1409`): ordinary `writeack` acknowledges LSU enqueue (`same file:1487–1506`). Because waitrequest allowance is **zero**, its host-root FIFO remains active (`same file:1311–1388`). At the external boundary:

```
o_avm_write[z] = host_root_fifo_data_out[z].write && !host_root_fifo_empty[z];
host_root_fifo_rdreq[z] = !host_root_fifo_empty[z] && !i_avm_waitrequest[z];
```

These are `P/ip/lsu_token_ring.sv:1385,1387`. A stalled write is held asserted; it is not an accepted-beat pulse.

Nevertheless, the selected **BSP-write-ack-disabled** branch generates the pending counter's external ack as:

```
o_avm_ext_writeack_next[o_wr_id[z]] |= o_avm_write[z];
o_avm_ext_writeack <= o_avm_ext_writeack_next;  // registered one cycle
```

See **`P/ip/lsu_ic_top.sv:549–575`, especially 569 and 574**. There is **no `!i_avm_waitrequest[z]` qualification**. The comment about external completion at line 572 does not change the assignments. The correctly qualified-looking write-ack code elsewhere in the generic token ring does not override this actual `lsu_ic_top` external-ack producer.

**Finding: confirmed source-level acknowledgment/accounting mismatch in the active configuration.** If an external write is held under backpressure, the LSU receives repeated external-ack pulses even though the host-root FIFO has not removed that beat. `acl_has_pending_write` increments/decrements a counter seeded at minus two and derives its flag from counter bits (`P/ip/acl_has_pending_write.sv:73–94`); it neither checks external waitrequest itself nor suppresses duplicate acknowledgments. A stalled beat can therefore be counted as retired before acceptance, with excess pulses subsequently corrupting pending accounting. Early finish or a stuck/spurious pending indication is a source-supported risk; an end-to-end waveform or hardware manifestation has **not** been produced in this read-only review.

**Answer:** done is gated on the store LSU's internal active/pending machinery, so it is not merely raw pipeline completion. But the captured active acknowledgment path does **not reliably establish all external write handshakes under backpressure**. Even with correctly matched synthetic acknowledgments, this mechanism would establish acceptance at the `_di` output boundary, not completion inside a downstream bridge/DDR controller or visibility to the DMA/host reader. There is no active physical write-response dependency here. A fixed post-done delay or tying an unused external writeack input cannot repair this source-level contract.

## 7. Explicit unresolved items and next boundaries

1. **Write retirement — blocking:** independently confirm the cited active ack-producer mismatch, then decide a separately scoped vendor/source correction or integration contract. Any future verification must include sustained downstream waitrequest and the final store beat, observing accepted writes and completion together. No patch, workaround, simulation, or vendor execution was authorized or performed here.
2. **Finish read collision — blocking for destructive polling designs:** retain the exact delayed-clear semantics in the host ABI; do not assume lossless concurrent finish polling. If concurrent queued invocations are needed, obtain a separately verified collision/queue contract instead of generalizing the one-in-flight protocol.
3. **Quartus 25.1 native import:** effective addressUnits/defaults, generated adapter address scaling, complete fileset dependency closure, tool compatibility and elaboration remain unverified. The captured 169-file subset is not a claim that every build dependency was exported. Earlier 26.1.1/scalar imports do not settle this component.
4. **Physical integration:** FIM instance/bank numbering, local-memory aperture/range, 256-bit width conversion, byteenable lane placement, bursts, ordering across read/write/DMA paths, clock/reset/freeze/IRQ handling and upstream CSR window decoding remain wrapper work. Preserve the XML device-model discrepancy already documented by the prior review; the metadata model name is not a new physical-device qualification.
5. **Execution and acceptance:** no persona synthesis/fit/timing/CDC/DRC or image-to-source binding, DDR numerical test, DMA copy-back, overflow-safe host reference, or hardware recovery/readiness gate was established. Source-proven register and pointer mappings alone do not make the AFU safe to run.

Reusable review rule from this case: trace `USE_WRITE_ACK`, LSU `o_active`, and the **actual instantiated** external-ack producer as separate paths; an early-valid setting is not proof that pending-write tracking is absent, and a signal named external-writeack is not proof of accepted downstream writes. The same discipline applies to read-clear timing: inspect both data sampling and the clear-register edge, not merely the header's “clear on read” label.

# CAPS02: minimal bank-write publication observer

**Design only; no implementation or execution authorization.** Add a passive, bank1-wide **enabled-byte / response-retirement observer at the native FIU AXI boundary**, plus an epoch/snapshot CSR block. Keep HLS, generated Platform Designer (PD) RTL, DMA datapaths and PIM sources unchanged. A clean empty-boundary observation alone is expressly insufficient: require the known invocation's complete enabled-byte total as well.

**Limit of the present proof:** this design closes the upstream-buffering and hidden-response observation gaps. Calling its result *DMA-visible publication* additionally requires the exact controller post-B visibility fact in §6. Until that fact is source-bound, advertise `TARGET_RETIRED`, not `PUBLISHED`, and keep the publication capability bit clear. No guessed delay, dummy write, same-ID ordering slogan or successful test substitutes for that fact.

Scope: local source/evidence reads and this document only. No SSH, devices, MMIO, vendor tools, builds, simulations, cancelled diagnostics, capsule execution/import or git. Host-hanging operations and speculative MMIO remain prohibited. Recovery permission does not waive those prohibitions.

## 1. Bound source and exact connection points

Paths relative to `N=/home/joe/Projects/Thesis/AHLS/new_bsp/new`:

- `A = qualification/caps01-dma-burst01/diagnosis09/afu`
- `P = qualification/caps01-dma-burst01/diagnosis09/platform/ofs_plat_if/rtl`
- `G = qualification/ahls-memory-functional01/inputs-path08/generated/ip/ahls_memory_dma_fabric/ahls_memory_dma_fabric_fabric`
- `H = qualification/caps01-kernel-host01/HOST-CONTRACT01.md`

Current capsule `qualification/ahls-persona-work21-caps01/run-setup01.py` was parsed as AST literal `C`, never executed. Its SHA256 is `798134e3b3d91622b1207c2e10635868b7fb0a0bea5918533bb65812b4765dd9`. All 13 `A` files match `C.files`, including their decoded payloads. Selected composition, bank1/MMIO interconnect, master-agent and function-wrapper files match `C.generated_inventory`. The PIM local-memory mapper, user mapper, burst mapper, async shim and register pipeline match **current `C.release_inventory`**, not just a neighboring checkout. This is a finite binding check, not a whole-generated-tree audit.

| Point | Exact evidence and proposed connection |
|---|---|
| Existing completion | `G/mmhost_ia840f_report_di_10/synth/lsu_ic_top.sv:549–576` acknowledges accepted HLS beats; `DDRIP_function_wrapper.sv:260–264` drives both activity flags from one LSU signal; `mmhost_ia840f_report_di.sv:452–464` connects those flags to CRA. Leave these contracts unchanged. |
| Bank1 composition | `G/ia840f_ahls_memory_fabric_dma_10/synth/ahls_memory_dma_fabric_fabric_ia840f_ahls_memory_fabric_dma_10_bw6p3iy.v:2331–2359` connects kernel `gmem1_2` and the bank1 AXI output. `G/altera_mm_interconnect_1920/synth/ahls_memory_dma_fabric_fabric_altera_mm_interconnect_1920_wgwcdgy.v:649–710,1232–1275` disables HLS write responses; `:1368–1379,1657–1700,2004–2029` has separate read/write muxes and an upstream command pipeline. Do not add an observer here and call empty counters a drain. |
| Physical observer | Instantiate a new passive `ia840f_ahls_write_observer` **inside `A/ia840f_ahls_memory_bank_shim.sv` for bank1 only**, reading its `to_fiu` AW/W/B signals and `to_fiu.clk`. This is the same actual bus connected to `plat_ifc.local_mem.banks[1]` by `A/ofs_plat_afu.sv:47–51`, not `banks[1]` at the core-facing side. No ready/valid/data signal is driven or gated by the observer. |
| Why this boundary | Bank shim `:15–47` first page-splits, then invokes `memory_shim`. `P/ifc_classes/local_mem/ofs_plat_local_mem_as_axi_mem.sv:121–187,199–265` adds possible further splitting, metadata, independent CDC channels and registers before `to_fiu`. Observe **after all of them**. |
| Hidden responses | `P/base_ifcs/axi/prims/ofs_plat_axi_mem_if_map_bursts.sv:61–80,275–281,316–323` fixes split WLASTs and suppresses intermediate `NO_REPLY` B responses without aggregating their errors. Every native B must be checked, including ones later hidden from HLS/DMA. Neither core-facing B nor only the last split B is sufficient. |
| IDs / CDC | Local-memory mapper `:169–187` forces physical AWID/ARID to zero; `P/ifc_classes/local_mem/prims/ofs_plat_axi_mem_if_user_ext.sv:114–163` retains the original ID/user in a FIFO and restores them later. `P/base_ifcs/axi/prims/ofs_plat_axi_mem_if_async_shim.sv:53–125` separately transports full AW, W and B payloads. Do not infer a kernel/DMA source from physical BID. |
| CSR path | Extend `A/ia840f_ahls_mmio_guard.sv:35–52,113–142` with a **locally terminated** new aperture, preserving full-address validation and existing serialization. Add explicit sideband ports between guard, top and observer mailbox; do not route new addresses into PD's low-bit decoder. |
| DMA contamination | Add one output from `A/ia840f_ahls_memory_core.sv`, derived from `dma_bank[1].awvalid || dma_bank[1].wvalid` (`:398–420,488–489`), into a core-clock sticky epoch fault. Bank1 has both DMA and HLS writers. Enable this fault detector **from local ARM enqueue through RELEASE acknowledgement**, including ARM's CDC round trip; flag even a stalled write attempt. Do not stall DMA or count its bytes as kernel output. No generated hierarchy reference is needed. |

Proposed changed-source surface: new observer/mailbox module and source-list entry; additive ports/instances in bank shim/top; additive local CSR logic in MMIO guard; one DMA-write-attempt output in core. No HLS regeneration or change to the accepted write-ack correction.

## 2. Smallest accounting: retire at clean checkpoints, not per burst

In bank1's native clock, continuously maintain unsigned **64-bit saturating** totals from a known reset lineage. Updates occur only on `VALID && READY`:

| Total | Increment |
|---|---|
| `A` | One per AW handshake |
| `Q` | `zero_extend(AWLEN) + 1` per AW handshake; declared W beats, **not bytes** |
| `W` | One per W handshake |
| `L` | One per W handshake with WLAST |
| `T` | `popcount(WSTRB)` per W handshake; count enabled bytes, not bus width |
| `B` | One per B handshake, including error responses |

Compute widened **next-state** values once per edge, including simultaneous AW/W/B; derive faults and checkpoint state from those same next values. Require `B <= A` and `B <= L`; violation poisons accounting. **Do not require `W <= Q` or `L <= A` while busy:** the independent channel pipelines can deliver W ahead of AW. Store separate totals, not an unsigned outstanding-data counter that underflows on legal W-before-AW.

Define `empty = (A == B) && (Q == W) && (L == A)`. When `empty` and no sticky fault, update `C := T`; otherwise retain `C`. `C` is **clean-checkpoint retired enabled bytes**, not a continuously precise per-B byte sum. This eliminates a burst-metadata FIFO/per-ID scoreboard: all observed writes must have B responses before their aggregate bytes are certified. Until the checkpoint, reporting `C` conservatively undercounts retirement. This assumes a legal, non-duplicating AXI slave; the aggregate observer is not a complete AWLEN/WLAST positional protocol checker.

On every B handshake, treat **any BRESP other than OKAY** as an error; never advance `C` on that edge. Physical AWID and BID must remain zero for this bound design, or fault. With all writes accounted at an empty checkpoint, no response-order inference between different original AFU IDs is required. If the physical ID-forcing policy is changed, requalify the design rather than silently claiming the same bound contract.

Accounting covers:

- **Width adaptation / tail masks:** count native WSTRB population. HLS's 256-bit beats become a 512-bit bank interface, but a four-byte final integer still contributes four bytes, not 32/64. Address bit5 and masks remain the existing adapter's responsibility (`H:42–48`).
- **Page/burst splits:** every physical AW, every W beat and every B is counted independently, after both splitters. Do not multiply an original burst count by its final fragment size or discard intermediate B errors.
- **Delayed final W:** `T` lacks enabled bytes and/or `Q != W`, `L != A`; no successful target checkpoint. **Delayed final B:** `A != B`, so `C` cannot advance to cover that write.
- **Upstream commands not yet here:** `empty` may be true, but `C - baseline` is still smaller than the required finite total. Empty is never independently advertised as whole-pipeline drain.
- **Zero strobes:** increment W/L bookkeeping normally, add zero bytes. A future upstream all-zero transaction is not ruled out by byte equality; the result certifies enabled result bytes, not absence of every possible command or safe global reset.

## 3. Epoch invariant and minimal host use

Use the existing exclusive, one-invocation contract (`H:52–63`). The source has exactly `z[i] = x[i] + y[i]` for positive signed32 `n` (`afu/ahls_memory/src/mmhost_ia840f.cpp:18–44`; SHA256 `bbc41b6fb33646066a42d7fa1b009aca46ebc8a1f295feb0f8d200fe63f37b64`). For this kernel, set **`E = 4*n`**, not the rounded allocation size; `H:48,85–93` defines its enabled-byte/tail contract. Example: `n=9` means `E=36`.

1. Complete and retire all preparation DMA descriptors, establish known HLS idle and completion-history baseline exactly as in `H`. No unknown previous start, pending DMA, concurrent owner/writer or reset is permitted. A momentary native `empty` sample does **not** establish these preconditions.
2. Program `EXPECTED=E` and a fresh nonzero `TOKEN`, then `ARM`. In the native clock, ARM succeeds immediately or rejects: require clean checkpoint and no AW/W/B transfer or presented AW/W on the ARM edge, then latch `baseline=C=T`, expected and token, and mark armed. This rejects local activity; the host's preparation-retirement evidence still excludes writes hidden upstream. Await an acknowledged, coherent armed snapshot with that token before the sole kernel start. Never start merely because the command write returned.
3. No bank1 DMA writes from ARM through RELEASE, including sentinel initialization. For simplicity, defer all DMA descriptors until kernel retirement is established. The core-side DMA attempt fault makes accidental bank1 writer sharing fail closed; raw AXI IDs cannot identify provenance. Bank0 kernel reads remain unaffected.
4. Run the unchanged argument/start/status/finish-ticket sequence. After fresh completed-idle HLS status and finish ticket exactly1, request snapshots until the **same armed token**, error-free snapshot satisfies:

   `empty && (T - baseline == E) && (C - baseline == E)`.

   Subtractions are checked/non-wrapping. Smaller totals mean pending/unknown, even with zero AW/B imbalance. A larger enabled-byte delta is an epoch error, never success under `>= E`. This establishes `TARGET_RETIRED` only. DMA copyback additionally requires §6's source-proven visibility capability.
5. After that gate, ordinary serial bank1 DMA **reads** for copyback may run while armed; they do not increment the write totals. Require normal fresh DMA completion and numerical/guard checks. RELEASE is allowed only after the target-retired condition; it is not abort/cancel. Host HLS/ownership checks remain required because the generic observer does not inspect the kernel finish counter.

**Why finite bytes solve the actual missing-upstream problem:** under the bound kernel's exactly-E enabled output bytes, no other epoch writer and a clean pre-start baseline, retiring E bytes means no enabled output byte remains merely accepted in PD, width/page adapters or CDC. AW/B emptiness alone cannot prove this. Byte totals are not a numerical/address-coverage checker: duplicated/wrong-address stores could fool a count while violating the kernel/transport-correctness premise; retain numerical and guard verification. A future kernel with unknown write volume or additional stores needs a new declared-volume contract or source-specific issued-byte accounting, not this E formula.

## 4. Additive proposed CSR ABI and clock crossing

**Proposed only; these addresses must not be accessed on CAPS01.** BAR0 byte aperture `[0x20100,0x201A0)`, locally decoded by the guard, does not overlap current kernel/DMA or `[0x20000,0x20020)` guard telemetry (`A/ia840f_ahls_mmio_guard.sv:35–66`). All accesses remain aligned R64/W64, AXI size3; W64 requires `WSTRB=0xff`. Reserved bits are zero; unsupported offsets/shapes return DECERR, writes to RO/invalid command state return SLVERR. Existing addresses retain their ABI.

| Offset | Register | Definition |
|---:|---|---|
| `0x20100` | ID, RO | `0x4341505330325031` (`CAPS02P1`) |
| `0x20108` | CAPS, RO | `[7:0]=1` ABI revision; `[15:8]=1` observed bank; bit16 native-B observation; bit17 checkpoint-byte accounting; bit18 **post-B read visibility source-proven** (must remain0 until §6 closes); others0 |
| `0x20110` | EXPECTED, RW | Set only disarmed; current profile accepts positive multiples of4 through `0x1fffffffc`, matching positive signed32 n. Frozen at ARM. |
| `0x20118` | TOKEN, RW | Nonzero host epoch token, set only disarmed, different from previous epoch's token; frozen at ARM |
| `0x20120` | COMMAND, WO | Full value1 ARM, 2 SNAPSHOT, 3 RELEASE; other values invalid; one request outstanding |
| `0x20128` | STATUS, RO | bit0 mailbox busy; bit1 coherent snapshot valid; bit2 live epoch/link fault; others0. Reads always return local registered state, never wait for memory. |
| `0x20130` | SNAP_TOKEN, RO | Token echoed by the native observer, not merely the programming register |
| `0x20138` | SNAP_SEQ, RO | Monotonic 64-bit completion sequence, increments only when a new whole snapshot is installed; no wrapping |
| `0x20140` | BASE, RO | Frozen native baseline for the armed epoch |
| `0x20148` | ACCEPTED_BYTES, RO | Snapshot T |
| `0x20150` | RETIRED_BYTES, RO | Snapshot C (checkpoint semantics above) |
| `0x20158` | AW_TOTAL, RO | Snapshot A |
| `0x20160` | B_TOTAL, RO | Snapshot B |
| `0x20168` | EXPECTED_W_BEATS, RO | Snapshot Q |
| `0x20170` | W_TOTAL, RO | Snapshot W |
| `0x20178` | WLAST_TOTAL, RO | Snapshot L |
| `0x20180` | ERRORS, RO | Snapshot sticky error bitmap; OR with STATUS's live epoch/link fault before accepting success |
| `0x20188` | FIRST_ERROR, RO | `[7:0]` first error code; `[9:8]` BRESP when relevant; `[18:10]` native BID when relevant; bit63 valid; other bits0 |
| `0x20190` | SNAP_FLAGS, RO | bit0 armed; bit1 native empty checkpoint; bit2 TARGET_RETIRED from the complete snapshot predicate; other bits0 |
| `0x20198` | reserved | DECERR |

Guard/CSR runs in `core_clk` (`A/ofs_plat_afu.sv:6–38`); bank1 FIU clock may differ. Use a request/ack **bundled-data mailbox**: source freezes opcode/expected/token until ack, synchronized control crosses, destination captures after data is stable, freezes the entire result until acknowledged, source installs all result registers together. Do not independently synchronize binary counter bits. Enforce CDC timing constraints and reset-safe link initialization; no hierarchical peeks into generated RTL.

MMIO COMMAND acknowledges local enqueue only, without waiting for DDR or mailbox ack. A second request while busy is locally rejected, not held until a bank responds. R64 registers always return promptly from the core clock even if the bank clock stops. Host waits for busy=0, a **new** SNAP_SEQ, valid=1 and matching SNAP_TOKEN; then reads the frozen bank and checks STATUS again. No automatic background snapshot replacement and no read-to-clear registers. ARM/RELEASE completions also install snapshots. A native-side rejection returns a new **faulted** completion snapshot and clears busy; an immediate local rejection returns SLVERR and latches the local command fault. Neither is successful ARM/retirement. Local faults remain visible in STATUS even if absent from the captured native ERRORS field.

## 5. Fault and reset semantics

Define sticky error bits/codes in this order: bit0/code1 non-OKAY B; bit1/code2 unexpected physical ID; bit2/code3 B accounting violation; bit3/code4 any total/sequence overflow; bit4/code5 epoch enabled-byte excess; bit5/code6 DMA bank1 write attempt while armed; bit6/code7 epoch reset/link loss; bit7/code8 invalid epoch command. Capture first error, retain all bits, and make error precedence dominate any simultaneous target match. No software clear while retaining an epoch; no saturating total may later satisfy the success predicate.

Native observer reset must include both native bank reset and the AFU reset crossing used by the existing shim (`P/ifc_classes/local_mem/ofs_plat_local_mem_as_axi_mem.sv:55–70,103–112`). Core reset currently joins **bank0**, not bank1 (`A/ofs_plat_afu.sv:6–12`): explicitly bring bank1 link/reset health back to the CSR domain. On reset of either side, clear armed/valid/target state, invalidate mailbox lineage and reject stale acknowledgements. A surviving side latches epoch-reset fault. A full image reset clears the hardware history, but is **not** a successful retirement and does not preserve an epoch token. Initialize the link before accepting a new explicit ARM; never replay a pre-reset ARM request after reset.

A stop in the native clock yields busy/no new snapshot, not success. Timeout, reset, overflow, non-OKAY B, token mismatch or contamination leaves invocation outcome unknown/failed. Preserve ownership/storage under `H`; no automatic retry, release, reset, PR or teardown follows. RELEASE changes observer bookkeeping only and proves neither memory-wide quiescence nor device recovery safety.

## 6. Exact remaining source fact and later acceptance gate

**Still required before enabling CAPS bit18:** for the exact accepted IA840F FIM memory subsystem, a successful native bank1 B response must mean that the enabled bytes of that write are observable by a later DMA-originated AR accepted on this same bank interface after all those B handshakes, with the actual AW/AR attributes. Establish where B is produced and the controller's post-response read visibility rule, including any write buffering/forwarding. If B merely acknowledges an upstream queue with no such guarantee, this observer measures queue retirement only; move the tap to the real completion boundary or use an explicitly documented controller completion mechanism. Do not invent one.

The bound PIM source `ofs_plat_local_mem_as_axi_mem.sv:174–179` explicitly says matching IDs order **within** the read or write channel, not relative read/write ordering. Its actual assignments prove B forwarding/metadata restoration and the suppression point, **not** the controller visibility rule. The locally inspected standalone `ofs-agx7-pcie-attach/.../local_mem_wrapper.sv:61–70` merely instantiates `mem_ss_top`; that file and `mem_ss_top.sv` have no same-named entries in current `C.release_inventory`, so this review does not promote that checkout into exact current controller evidence. The release inventory does contain generated memory-IP paths, but inventory names/hashes alone are not a readable completion contract.

After that fact is closed, the proof is narrow: clean epoch + exact E + all native responses successful + fresh HLS completion + subsequent DMA AR implies result-byte publication. It does **not** establish host DMA completion, CPU visibility, all-master quiescence or reset safety.

Later implementation acceptance must exercise the *new mechanism*: full/partial masks including z bit5, page and maximum-burst splits, delayed final W and B, an early hidden split-B error, W-before-AW after CDC, DMA-contaminated epoch, simultaneous counter updates, overflow and reset/mailbox replay. Verify no target assertion before E and all responses, and bounded local CSR responses with an unresponsive bank. These are implementation acceptance requirements, **not diagnostics run here**. Do not rerun the cancelled original-gap study.

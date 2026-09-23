# Independent review — guarded actual-PIM integration

Status: **FINAL**

Verdict: **PASS — bounded guarded-top source integration, Quartus 25.1 analysis/elaboration, and standalone mapped-synthesis diagnostic evidence. No blocking defect found within that acceptance scope.**

This is not a warning-clean design, board-ready fit boundary, mapped functional qualification, or hardware release. The active-path mapping questions in R1/R2 below remain explicit follow-ups before stronger mapped-functional claims. The artificial pin boundary and reset findings prohibit treating this project as a usable board image. They do not invalidate the completed diagnostic or justify an unchanged rerun.

## Scope, method and identities

Review order: specification (`SCOPE.md`, stage results and preserved synth01 failure), then RTL/source binding, then native evidence and diagnostic quality. This report was first written **IN_PROGRESS**, then finalized. Review operations were local reads, inert AST/literal/base64 decoding, byte comparisons, hashes and report parsing. No runner was imported or executed. No SSH, vendor/simulator command, source change, git write, task transition or hardware access was performed. This report is the sole authored deliverable.

Paths are relative to `/home/joe/Projects/Thesis/AHLS/new_bsp/new`:

- `U` = `qualification/ahls-memory-pim03`.
- `I` = `U/inputs-elab01`, the captured platform/core source.
- `A` = `U/artifacts-synth02`.
- `K` = `qualification/ahls-memory-functional01/inputs-path08/generated`.
- `G` = `K/ip/ahls_memory_dma_fabric/ahls_memory_dma_fabric_fabric/mmhost_ia840f_report_di_10/synth`.
- `TOP` = `afu/ahls_memory/pim/ofs_plat_afu_guarded.sv`.
- `GUARD` = `afu/ahls_memory/control/ia840f_ahls_mmio_guard02.sv`.
- `SYN` / `AE` / `DRC` = `A/output_files/ia840f_ahls_memory_pim_elab.syn.rpt`, `.syn.ae.rpt`, and `.drc.synthesized.rpt` respectively.

| Reviewed identity | SHA256 |
|---|---|
| Frozen `U/review-package01.json`, all **72** entries checked | `68a57e4566537c6641757296986591a19ab0c534dd4f7e29e2c91d2120d6ce09` |
| `TOP` | `3b5bf9eac55f5117858b8a746308a09ebc3d7c6f8a99c66907777139278785ca` |
| `GUARD` | `25512e0c4a697fa897e1ff472258eab2430dd157efd0bd94462a4a8a0824d627` |
| `U/source-binding01.json` | `4280fdf1675b30261c9639594e6516e6b1378f72063775c5201f8253e326ff7f` |
| `SYN` | `5705fff78222c11aad8226ec9c07631a9c162e07f3e5f6b7997cabb431fe3e9b` |

Published predecessors remain accepted, not reopened: actual page-safe PIM02 commit `77c64e122c9c03783a428a7b31bcb3f122f5ac6b`, review `c2dded6f3eb2f1531ca556fd9a94863fdf2a7e1124a00ed003b21dd5220be04d`; connected numerical commit `3594bb42ca062c754ce68e7c0ca987069bfb30b1`; guard simulation commit `ce4a40ee6c3e5867ae4d7d77e0d292ee19f1faa3`, review `e37bd057122f4418155c3812222bfd073a50058faeb6d93af6f5d60dfb4220ef`. The PIM02 and guard review-file hashes were independently checked locally. Their acceptance is not proof of primary-PCIe behavior or mapped functionality of this new integration.

## 1. Specification review

The acceptance contract is coherent and appropriately staged:

1. Add the exact accepted guard before generated address routing, preserving the actual primary host mapper, connected core/DMA/generated kernel, both page-safe bank shims and accepted reset-index overlays.
2. Preserve the existing top and select one alternate `ofs_plat_afu` plus one guard in this standalone compile; do not replace the scalar top or change FIM/pins/clocks/SDC/tool installations.
3. Retain full 20-bit MMIO admission with 64-bit data, read/write IDs of 16 bits and USER width 1. Explicitly share upstream MMIO clock/reset/instance; the guard is not a CDC.
4. Use the accepted guard contract: aligned 64-bit accesses, full write strobes, forward `[0,0x10100)`, local read-only diagnostics at `0x20000/08/10/18`, local rejection and retained telemetry. This is an outer aperture/format check, not full register-value/lifecycle validation, a control state machine, global drain or a PCIe fence.
5. Distinguish A&E from mapped synthesis. `SCOPE.md:9–13` explicitly extends the stage and preserves the failed stage-only invocation. Neither the `_elab` basename nor the common success banner determines the stage.

The explicit non-goals are necessary: no live MMIO/programming/driver changes/reboot, no physical-DDR acceptance, and vendor DDR simulation **SKIPPED BY USER**. Full-FIM/persona reset, freeze, timing, PR, host visibility, software ordering and buffer lifetime remain open. Nothing in this review changes those exclusions.

## 2. RTL integration and exact delta

**Conforming.** Independently decoded the PIM02 and current runner configuration literals without executing them. The complete core/platform inventory delta is exactly one added `afu/ia840f_ahls_mmio_guard.sv` and one changed `afu/ofs_plat_afu.sv`; no removed entries. Generated inventories, both reset overlays, platform-original bindings, tool bindings and QPF are identical to PIM02. The QSF delta is exactly one `SYSTEMVERILOG_FILE` for the guard immediately before the selected top. The reconstructed top diff is byte-identical to `U/top-delta01.patch`.

- `TOP:18–27` retains exactly one `primary_axi` owner of `plat_ifc.host_chan.ports[0]`. The existing primary mapper continues to drive upstream `mmio`; the guard does not instantiate another host mapper.
- `TOP:29–38` instantiates the full-width downstream interface and explicitly assigns its clock, reset and instance number from upstream. `GUARD:8–16` consumes that clock/reset and rejects unsupported geometry. No CDC or reset-domain change is introduced by this delta.
- Parsed all **171** flat-core connections. Exactly **28** change from `mmio.*` to matching `guarded_mmio.*`, including both request and response handshakes, IDs and USER. All other ports are unchanged. The five unchanged MMIO connections are AWLEN=0, AWBURST=INCR, ARLEN=0, ARBURST=INCR, and the existing unused single-beat RLAST wire. AXI-Lite has no RLAST field to redirect.
- The guard sees the complete address before the core. `I/afu/ia840f_ahls_memory_core.sv:12,30,247,265` preserves 20-bit transport. Generated write/read routers `altera_merlin_router_1921_pleb25y.sv` and `..._bknbsua.sv` retain `ADDR_RANGE=0x10100`, optimized address extraction and low-bit decode at lines 162–174,214–221. The high-address admission is therefore placed before the aliasing projection, not after it.
- `TOP:42–66` retains two 34-bit-byte-address/512-bit/ID18/USER2 banks, the 57-bit-byte-address/512-bit host path and all fixed-geometry rejection conditions. `I/afu/ia840f_ahls_memory_bank_shim.sv:15–46` retains the internal LEN-width 5 interface, clock-driving connector, 4096-byte page mapper and NO_REPLY metadata convention. Neither bank is bypassed.
- The copied guard bytes exactly equal `GUARD` and the accepted guard hash. Local rejection remains ahead of downstream VALID; forwarded responses return through the guard. This review does not extend the already accepted guard's stimulus coverage.

Native parameter excerpts were independently matched to their exact raw A&E report lines. They confirm top-level `guarded_mmio` 20/64/RID16/WID16/USER1, host and bank geometry and retained page splitters. Successful native elaboration supports structural/type/parameter integration, not temporal equivalence.

## 3. Evidence integrity and native-stage attribution

Read the source binding, both parent-verification records, both native-panel files, both warning ledgers, all three dispatch/outer/manifest records, start snapshots, templates and stage-delta records. Independent checks established:

- All 72 frozen package members have matching lengths/hashes, including the full local native reports. The frozen package was checked again at the end of analysis and remained unchanged.
- All three runner files parse inertly; their bodies exactly equal the corresponding template after replacing only the literal `C` assignment. Each full script hash matches its dispatch receipt.
- Every field of the three literal configurations other than `run` is identical. Source, QSF/QPF, generated overlays and tool bindings were not changed to obtain synth02 success.
- **825** embedded core/platform payloads checked across the three runs: **275 per run**, exact base64-decoded lengths/hashes, matching source binding, native-result hashes and `I` files.
- All **255** generated candidate files independently checked using the exact local paths in `parent-verification02.json`; both already-overlaid reset files also equal the embedded candidate bytes. The four dependency exports are preserved PIM02 files, not invented regeneration.
- All **37** exported archive members checked (**13/9/15**): decoded bytes match embedded metadata, manifest and local artifact bytes. Whole compressed archive hashes match manifests and outer receipts. Non-exported native output/QDB hashes remain captured inventories, not locally re-read QDB contents.
- Native result/tool/input records agree with the configs; QSF readback is exact. All six recorded preservation domains are true for each run, with empty postflight-error lists, no timeout and no remaining owned process group. These are retained per-run receipts, not a new inspection of the remote workstation.

| Attempt | Native / effective / outer | Actual result | Compressed archive SHA256 |
|---|---|---|---|
| elab01, `@240/%240` | 0 / 0 / 0 | A&E only; ended `2026-09-23T13:31:41.073625Z` | `9a5014586428e1668861aeefee414d87ced5846dc24ba0105f029258e818ab48` |
| synth01, `@243/%243` | 3 / 3 / 3 | Stage-only prerequisite failure, preserved | `b746f22a19854af4c280320f1345d94525fa7bbed71ba03f745a235cd7cc6797` |
| synth02, `@245/%245` | 0 / 0 / 0 | Fresh full synthesis from source; ended `2026-09-23T13:39:42.776159Z` | `5cbecb87a6b3e12528fb45a8733f655b274b1e523328b0e697d34d5284e2bb75` |

Synth01's native log explicitly says Analysis & Elaboration has not run, followed by Error 23035 loading absent `report.cmp`. This is an invocation defect, not an observed RTL synthesis failure. Recognized `--help=synthesis` output supplied no prerequisite semantics. Synth02 correctly removes only the stage-only selector and uses normal `quartus_syn --read_settings_files=on --write_settings_files=off ... -c ...` in a fresh root. The inspected runner creates that root exclusively and copies source/settings, not predecessor QDBs.

Synth02 is genuinely beyond A&E: `A/synthesis.log:11157–11163` records saving post-synthesis snapshots and synthesized DRC; the output inventory contains synthesized-stage records; raw `SYN:801` supplies mapped utilization; `SYN:31913` retains the guard entity; `SYN:32478` begins the FSM summary. It reports 2m44s and 3539 MB peak virtual memory. The independent review did not load a QDB or simulate this netlist.

Resource preflights record CPU affinity `[0,1]`, available memory above 80 GB, free disk above 10 GB and no competing listed native processes. Templates retain per-process 16 GiB address-space limits and 600-second supervision. These normal-account source guards are not an OS sandbox or aggregate host-memory guarantee. Fallible archive/export operations remain an inherited acquisition limitation; the actual three archives and outer statuses were recovered and verified, so that limitation does not invalidate these results.

## 4. Diagnostic quality and disposition

### Counts and mapped resources

Reparsed every warning row from the full logs and matched both ledgers' line/text/ID records. A&E has **226 explicit occurrences**, exactly the PIM02 multiset after only root relocation, with native banner **1**. Synth02 contains that same 226-row prefix plus **5,390** mapping occurrences, totaling **5,616** explicit warnings; native banner **5,391** is the A&E summary 1 plus 5,390. Both count conventions are retained; no count-only rerun is needed. No new A&E warning names the guard.

Raw mapped panels and row headers agree with the extracted panels:

- **32,154 ALMs / 912,800**, native display **4%**, a synthesis estimate rather than fitted utilization.
- **79,163 dedicated logic registers**, **0 estimated DSP blocks**.
- Guard entity: **269 combinational ALUTs**, **331 dedicated registers**, no block-memory bits/DSPs. ALUTs are not ALMs.
- Guard `ws` and `rs` both have four states and are retained. Native One-Hot/Safe labels are compiler encoding/safeness classifications, not runtime/reset/functional-safety evidence.
- **8 input / 0 output / 5,143 bidirectional pins**, an artificial standalone interface boundary, not IA840F card wiring.

### R1 — Medium, nonblocking for this diagnostic: active read-burstcount transformation needs a bounded semantic closure for stronger claims

`A/synthesis.log:7691–7695` has one 13046 grouping and four 13047 warnings on `k0|lsu_ic_top_gmem|...lsu_n_fast`, feeding `read_ring_output_pipe_rd_burstcount[1][3:0]`. This is an active read-request length path, not an unused external pin.

The exact specialization is now source/native grounded: `AE:13504–13522` gives READ=1, NUM_PORT=2, AWIDTH=29, BURST_CNT_W=4, ID_WIDTH=1, HYPER_PIPELINE=1 and NUM_DIMM=1. `G/lsu_n_fast.sv:349–354` assigns the same `request_dout` to the same output tuple once per port; `386–392` drives it from the single registered selected request. There are two identical continuous drivers, not two independently enabled data sources. `G/lsu_token_ring.sv:324–353,382–387` carries this burstcount through the read-output pipeline to the root request.

This materially narrows the risk: ORing identical defined binary values is source-consistent, and the warning alone does not demonstrate corrupted read lengths. It does **not** prove the optimized netlist's exact fan-in, initialization behavior or mapped equivalence. The prior connected simulation is not a test of this Quartus transformation.

**Smallest follow-up before claiming this transformation functionally cleared:** inspect the already-produced mapped cone (or a separately authorized finite read-only netlist query if that cone is not locally available) and establish that each of these four bits still corresponds to the registered `request_dout` burstcount slice for both selectable read ports, with no independent floating/alternate driver. Preserve the warning; do not edit installed generated RTL, disable fast mode, suppress diagnostics or rerun unchanged synthesis merely because an OR conversion was reported. No confirmed new source defect or required source correction is established here.

### R2 — Medium, nonblocking for this diagnostic: RAM pruning is partly explained, not blanket waived

The five 14284 groupings, five 14285 RAM groupings and **177** 14320 node occurrences are not 177 complete FIFOs proven removed. Reconciled leaf families from the full log:

| Named family | Removed leaf occurrences |
|---|---:|
| bank0 map-user write FIFO | 1 |
| bank0 asynchronous AW FIFO | 2 |
| bank0 asynchronous B / R FIFOs | 11 / 11 |
| bank1 asynchronous B / R FIFOs | 11 / 11 |
| primary MMIO asynchronous B / R FIFOs | 19 / 8 |
| kernel gmem host-root FIFO | 66 |
| primary host ROB AW / W / AR FIFOs | 10 / 4 / 7 |
| primary read-ROB metadata RAM | 1 |
| primary write-fence metadata | 7 |
| primary read-response tracker | 8 |

Concrete source dispositions:

- **19 MMIO B payload bits:** source-justified unused upstream response data. `I/.../ofs_plat_host_chan_map_as_axi_mem_if.sv:126–128` explicitly ignores write responses and holds BREADY high; the AXI-Lite B struct is ID16 + RESP2 + USER1 (`I/.../ofs_plat_axi_mem_lite_if.sv:109–117`). The B async FIFO packs that struct (`I/.../ofs_plat_axi_mem_lite_if_async_shim.sv:95–120`). Log lines 5383–5401 enumerate all 19 payload leaves. This is expected posted-write response pruning, not proof that CPU software observes BRESP. The guard records downstream/local faults before handing its response to that upstream path; readable telemetry remains important.
- **66 kernel host-root leaves:** source-supported constant/unused fields, not a removed read queue. The exact leaves are `dataout_wire[1]` and `[258:322]` (`A/synthesis.log:5410–5475`). `AE:10254–10300` gives NUM_RD_PORT=2, NUM_WR_PORT=0, AWIDTH=29, BURST_CNT_W=4, MWIDTH_BYTES=32. `G/lsu_token_ring.sv:133–138,1133–1145,1302–1309,1352–1385` defines a read/write union, disables the write ring, zero-extends the read address/count into its wider payload, and places write/read flags in the low two bits. Bit 1 is the constant write flag; the listed high bits are outside the read payload. The matching gmem mapped host-root hierarchy retains logic/register resources (`SYN:31427`), rather than disappearing as an entire queue. This supports these particular leaf removals; it is not a proof of every RAM implementation transformation.
- The other **92** leaves remain an explicit bit-to-field qualification item. The names locate real response/ID/metadata and request queues; constant sidebands and narrowed physical IDs are plausible but not sufficient by themselves to waive each bit. In particular, seven write-fence metadata leaves and eight read-response-tracker leaves must not be declared harmless merely because they are in PIM/vendor code. Their producers/consumers are visible in `I/.../ofs_plat_host_chan_gen_wr_tlps.sv:216–235` and `...gen_rd_tlps.sv:178–199`.

**Smallest follow-up:** use retained clearbox/source-to-netlist metadata or a bounded mapped-cone inspection to associate the remaining leaf indices with actual packed fields and constants/unused consumers; retain which reply/credit/ID/data fields survive. The archive records temporary clearbox output identities but does not export those TDF bodies, so exact bit attribution is not established by this package alone. Do this before a mapped-functional or full-FIM warning-closure claim; no unchanged standalone rerun or blanket vendor waiver is warranted. None of these warnings names the newly added guard, and no missing required behavior has been demonstrated by the retained diagnostic.

### R3 — Physical-release boundary, not a defect to fix by guessing pins

All **2,489** 13040, **624** 13033 and **2,070** 13010 rows name `plat_ifc.*`; grouping warnings are 13039×12, 13032×1 and 13009×1, plus 24566×1. They explain the artificial undriven/constant/permanently enabled tri-state/open-drain treatment of the standalone SystemVerilog interface. These are not appropriate card pin assignments and are not proof of electrical adequacy.

**Required direction for physical qualification:** use the matching Work21 FIM/PR-persona boundary and verify its release/source/tool prerequisites, so these PIM interfaces become the intended internal boundary. Do not blind-fit this standalone project, assign guessed pins/clocks, tie arbitrary inputs, or prune interfaces merely to reduce warnings. Successful mapped synthesis does not waive the retained full-FIM findings, including the stated Work21 23/88-rule result and 1,076 dangling boundary inputs.

### Reset, freeze and DRC remain open

Raw DRC panels were matched to the extracted text, not accepted solely from the narrative:

- Partitioned **RES-10204 High1**: missing device-level Reset Release remains, unchanged from the accepted component baseline.
- Synthesized **4 of 13 enabled rules failed**, zero waived (`DRC:48`); seven other rules were disabled according to the native log. **RES-30134 Medium `5,000+`** is a saturated `max_violations=5000` result, not an exact count.
- **FLP-10500 Low8** (`DRC:5085`): unused clock/reset fields on the four top host AXI-stream interfaces. Resolve boundary semantics in the FIM, not with arbitrary tie-offs.
- **TMC-20501 Low3** (`DRC:5105`): bank0/bank1 soft reset and `join_afu_reset|b_to_a|dup_leaf`, requested chain length 6, implemented 0 because fanout is within one hierarchy. This is not fitted reset-distribution proof.
- **LNT-30010 Low1** (`DRC:5120`): `join_afu_reset|joined_reset_n` drives 488 async-reset, 1,376 sync-reset and 513 enable endpoints. Preserve the mixed-use reset review.
- Enabled rules report zero combinational loops and zero inferred-latch paths; they do not establish CDC/timing/reset safety. `freeze_cc` is still swept: a connected freeze port does not provide effective quiescence.

The real FIM must establish device-level reset release and reachability without adding a speculative duplicate Reset Release IP to the persona. Guard FSM retention does not close initialization, live-reset or PR obligations.

## 5. Acceptance conditions and remaining work

Accept this exact package as **guarded actual-PIM source integration + successful native A&E + completed bounded standalone mapping evidence**, retaining synth01 as a failed invocation. The diagnostic is useful precisely because its warnings and limits are preserved. No in-scope blocker or justified corrective RTL delta was found; R1/R2 remain explicit qualification work for stronger claims, not conditions requiring repetition of the completed diagnostic.

Retain the accepted guard fixture limitations unchanged: **F1**, response-hold checks do not explicitly reject VALID gaps; **F2**, count visibility under overlap does not independently isolate the B-retirement edge. The accepted simulation's 11 bad writes, 5 bad reads, 91 numerical sums, 1,088 compared bytes and 16 DMA transfers are not primary-PCIe or mapped-netlist coverage, nor exhaustive AXI validation. Improve those assertions only in the next changed fixture if that stronger coverage is sought; do not reopen the published milestone.

Still open: matching FIM/persona release and full fit/STA/CDC/DRC, physical reset/freeze/PR, active-path mapped-functional qualification, PCIe/OPAE and posted-write error visibility, software fences/global drain/control/capability/error state and host-buffer lifetime, simultaneous physical-DDR qualification and durable boot. No hardware operation is authorized by this report. Vendor DDR simulation remains **SKIPPED BY USER**. **The hardware goal is incomplete.**

# Work03 actual generated-memory review

**Not accepted. No source, pins, gates, readiness records or donor files changed.** The review supports retaining one narrow zero-QoS source proposal, but exposes a new concrete calibration-association discrepancy. OFS generated-interface acceptance remains blocked by skipped exports. This is static local inspection only: no remote/vendor execution, API emulation, compilation, simulation, timing, hardware test or commit.

## Receipt and evidence notation

`memory-artifacts.json`: **9,004,434 bytes**, SHA-256 `a333f976a8f95024b37ad918051b379c3922bd66b91e123e09fc575e95eb60ae`. Independently verified all **87 full-text payload hashes and byte counts**, out of **99 records / 12 missing**, with no non-missing receipt issues. This finite collection is **not a complete generated tree**.

`F<n>` below denotes the zero-based `files[n]` receipt record; line numbers refer to decoded `content`. The companion JSON contains the full path/hash manifest, extracted synthesis port declarations, saved top SOPC port records, source bindings, exact QoS diff and unresolved-boundary actions. Principal evidence:

| ID | Captured artifact | SHA-256 |
|---|---|---|
| F36 | `ipss/mem/qip/mem_ss/mem_ss/synth/mem_ss.v` | `f5fd9ee05e8cf89c202039c0bc6d5950b55aace9d0447402da17bf46c9e14e75` |
| F61 | nested `mem_ss_mem_ss_501_qm5zaka/synth/mem_ss_mem_ss_501_qm5zaka.v` | `418804c91789aa650b3679ce69a6a30258a93185d8d6fd76a2304cc9a9a4d45f` |
| F64 | top `mem_ss.sopcinfo` | `dc321127d0922fa990b97ea944c6fe34767a5e19c4f553e032d31654a8d0f440` |
| F86 | nested `mem_ss_mem_ss_501_qm5zaka.sopcinfo` | `b38e5977cca192148ca335cae7034fc80c2dc35d506f03b6fd100f8897029fcc` |
| F66 | EMIF0 SOPC metadata | `ebb2a5f77eb0b2f04c0e9d12559fcb67c678f1566e389b196d028f134b725cc7` |
| F72 | EMIF1 SOPC metadata | `916dd675375f7adc13026ec0ccbdeb356758dedcfab47f33bb4790d6c96857e3` |
| F6 | saved `mem_ss.ip` | `883ff7f07d572a91e8fa67ccff2f971dd50823779eb33edeeae3fe6e960f5952` |

All source hashes in `ipgen-03/final-memory-correction-proposal.json` still match current local files. Captured source F9–F20, F22–F23 also matches current local source, including board top, pin Tcl and producer. The earlier final review correctly described its report-only capture; its statement that raw synthesis evidence was unavailable is superseded **for this new receipt**, not retroactively falsified. F31:28 still records enclosing generation returncode 1; missing header-stage receipts and absent OFS exports remain a separate failure boundary.

## Actual synthesis boundary and saved geometry

F36 and F61 each have **128 ports**, with equal name/direction/width signatures. All top ports match F64 after the ordinary SOPC `Bidir` → Verilog `inout` terminology normalization. This is parsed HDL/metadata, not reconstructed Qsys API responses.

- F36:7–46: two DDR4 physical interfaces, each 64 DQ, eight DQS/DQS_N/DBI_N, 17 address bits, two BA and two BG bits. CK, CK_N, ACT_N, CKE, CS_N, ODT, RESET_N, PAR and ALERT_N are width one; raw HDL expresses these as `[0:0]`.
- F36:51–90,93–132: two application AXI interfaces, 512-bit data, 64-byte strobes, 34-bit byte addresses, nine-bit IDs, eight-bit burst lengths, four-bit AWQOS/ARQOS, **14-bit AWUSER/ARUSER**, one-bit BUSER; **no raw WUSER or RUSER**.
- F36:47–50: request/cold-reset inputs, ready/ack outputs. F36:91–92,133–134: per-channel calibration success/fail outputs. No external subsystem CSR port appears.
- F66/F72:6041–6139 confirm distinct **discrete channel0 / RDIMM channel1**, x64, one rank, row17/column10/BA2/BG2. Repeated parameter occurrences agree. Parsed configured capacity is `2^(17+10+2+2) * (64/8) * 1 = 17,179,869,184 bytes = 16 GiB` per channel, matching the existing source contract. This is saved generated configuration, not installed DIMM/SPD or hardware verification.
- F6:3833–3856 saves `DDR4,DDR4`, `STORAGE,STORAGE`, and connection vectors `1,0` / `0,1`. F61:344–462 connects i0/i1 to matching MSA0/MSA1, with channel-specific clocks/resets, Avalon paths and status. F59/F60 show actual MSA leaf wrappers; F59:94–104,164–165 disables/terminates WUSER/RUSER. The underlying `mem_ss_msa_top` implementation is not captured, so request USER command-bit meanings are not inferred from widths.

## New concrete discrepancy: calibration associations are not preserved

**Do not report donor calibration order as confirmed.** Actual nested HDL is direct:

- F61:242–248: EMIF0 uses `emif_cal_bot_emif_calbus_0_*`.
- F61:296–302: EMIF1 uses `emif_cal_bot_emif_calbus_1_*`.
- F61:315–328: calibration instance return-data and sequence-table ports confirm the same direct associations.
- F86:15344–15416 independently records `emif_cal_bot.emif_calbus_0 -> emif_0.emif_calbus` and `emif_cal_bot.emif_calbus_1 -> emif_1.emif_calbus`.

The board contract/source map requires reversed donor associations: **calbus_1 → physical0/discrete; calbus_0 → physical1/RDIMM**. The actual donor `old_bsp/ia-840/IOFS_BUILD_ROOT/ofs-ia840f/ipss/mem/qip/mem_ss/mem_ss_fm_0.qsys:15632,15639` confirms this (SHA-256 `49ac14b0a1b6e1dd2cf419f4fe9033261f29c8e3b8a29b23fc697632049c083f`). Raw mem0/mem1 physical export wiring and generated format metadata remove the ambiguity of simply mistaking channel names.

This is a demonstrated contract discrepancy, **not proof that 26.1 calibration fails electrically** or that old/new calibration indices have identical implementation semantics. No supported source parameter/composition correction is established by this receipt. Do not patch generated HDL, swap pins, swap complete discrete/RDIMM channels, or waive the donor requirement. **Next action:** inspect the installed subsystem composition routine and documented calibration ordering/remapping controls for the saved IP, then propose a source-bound correction or obtain explicit evidence resolving semantic equivalence.

## Physical grouping, index and scalar CS remain an OFS export boundary

The complete raw synthesis and saved SOPC DDR interfaces have equal role/direction/width sets (F64 interfaces begin at 706 and 1082). Producer F12:420–507 coalesces matching structures; F12:778–791 emits scalar width-one members. These strengthen the **source-derived prediction** of a single two-element physical interface group (`ddr4_mem[0]`, `ddr4_mem[1]`) and scalar `cs_n`. They are not actual emitted OFS declarations or observed API return values.

Current pin Tcl F15:4–123 has **118** targets under `ddr4_mem_group_1[0]`; F15:155 has `PIN_HB29 -to ddr4_mem[0].cs_n[0]`. Board top F20:46–53 and memory top F9:274–279 select group ports conditionally from generated macros. Missing F24–F27 means no proof of the actual OFS grouping/index/member export. Thus **no pin patch is issued**. After emitted confirmation, the narrowly scoped intended changes remain those 118 target prefixes to `ddr4_mem[1]`, and the HB29 target to scalar `ddr4_mem[0].cs_n`—not any package-pin change. Do not remove conditional group-1 RTL now.

The current **241** location assignments match the selected donor channel0/1 package-pin multiset. Stronger member/pin comparison also passes after explicit existing aliases: group1[0] ↔ donor channel1, scalar ALERT_N/CS_N spelling, and refclk/OCT moved into the separate modern reference interface. Donor pin Tcl SHA `606feee0a053afa1cab1e397df963b516b0c8a416a55472e3f138e07a6171bae`; current SHA `44fdb76902f22b83df265da656f531fca9d5abe61a74c696190b5465c0da579d`. Preserve all coordinates, including RDIMM positive reference HH48 and OCT GW48; no RDIMM negative clock pin is invented.

**Next action:** a separately authorized header stage must capture the OFS wrapper, interface/parameter headers, package and producer log, then compare actual group/index/scalar declarations. F22:10–12 explicitly says `memory_groups=2` requests separate discrete/RDIMM **simulation models**, not physical groups. Do not change this count from wrapper grouping predictions.

## Active generated PIM and USER mismatch

Both generated build copies are now observed: F37/F44 top configuration, F39/F46 local-memory package, F40/F47 FIU interface and F43/F50 gasket. Each corresponding pair is byte-identical. F37/F44:70–86 selects `native_axi`, `fim_emif_axi_mm`, and **AXI_MEM_WUSER_WIDTH** for FIM USER. F39/F46:38–41 adds the PIM flag width. Current source F10:51–55 supplies WUSER fallback one; source F18:13–25 defines a one-bit `NO_REPLY` flag. Thus the source-derived expectation is **1 + 1 = 2 bits**, versus actual raw AW/AR USER=14, if the expected no-WUSER headers are emitted. With the header stage skipped, this is not a claimed compiled ABI value.

Generated gasket F43/F50:45,75 directly assigns request USER; :61 returns BUSER; F9:341 zeros FIM RUSER. Widening an INI parameter alone does not establish how PIM `NO_REPLY` should be separated from MSA command bits or how response metadata survives. No WUSER→AWUSER substitution or arbitrary zero USER mapping is proposed.

**Capture-path issue:** missing F41/F42/F48/F49 requested `local_mem/ofs_plat_local_mem_axi_mem.vh` and `local_mem/axi/...pkg.sv`. Actual generated QSF F38:36 references **`local_mem/afu_ifcs/axi/ofs_plat_local_mem_axi_mem_pkg.sv`**, not the missing-record path. The wrong-path misses do not prove the real generated files are absent. **Next action:** capture the QSF-referenced `afu_ifcs/axi` package and applicable `afu_ifcs/include` header plus MSA command USER definitions; review the complete request/response bit mapping before writing an ABI correction.

## One retained exact patch proposal: defined QoS defaults

Current/captured `ofs-agx7-pcie-attach/ofs-common/src/fpga_family/agilex/mem_ss/mem_ss_top.sv` SHA `7211a02c56ba18d8bc58c749de56242c3e1eb3c94e8c92d84c42a742cf04618c` omits AWQOS/ARQOS assignments in F9:298–341. Generated PIM gasket F43/F50:44,74 also comments out its QoS drivers; merely forwarding FIM QoS would therefore not supply a defined upstream value. Actual F36/F61/leaf MSA synthesis now proves four-bit QoS inputs exist.

Retain the earlier guarded zero-default proposal, with unique anchors and exact unified diff independently reproduced in the companion JSON; **not applied**:

```diff
@@ after original line 308
    assign ss_axi_mm[c].awprot   = afu_mem_if[c].awprot;
+ `ifdef IFC_MEM_SS_I_AXI_MM_IF_WIDTH_AWQOS
+   assign ss_axi_mm[c].awqos    = '0;
+ `endif
@@ after original line 332
    assign ss_axi_mm[c].arprot   = afu_mem_if[c].arprot;
+ `ifdef IFC_MEM_SS_I_AXI_MM_IF_WIDTH_ARQOS
+   assign ss_axi_mm[c].arqos    = '0;
+ `endif
```

This is a defined-default policy, not arbitration-performance acceptance. **Next action:** confirm emitted macro spellings/field presence and sole-driver connectivity, then separately authorize the source edit and rebind affected inventories. Missing headers must not be fabricated to test this proposal.

## Reset, CSR, parser and remaining physical checks

| Boundary | Evidence and conclusion | Small next action |
|---|---|---|
| Reset/clock/status | F61:205–260,305–348,398–409,459–462 connects each MSA and user bridge to its own EMIF clock/reset. Reset controller uses EMIF0 `pll_ref_clk_out`/`pll_locked`; request/done paths remain channel-matched. Raw calibration status passes through the corresponding MSA. This is structural evidence, not reset/calibration behavior acceptance. | After calbus reconciliation and OFS export capture, independently review end-to-end reset/status connectivity; do not enable reset bypass. |
| CSR | Saved F6:3948–3951 is DISABLED; complete raw top has no CSR. F62 `emif_csr_ic.v` is a separate interconnect and does not create a memory CSR export. Existing F9:168–184 supports DFH/status-only fallback. | Verify actual emitted macro absence and fallback selection. Do not restore legacy memory-local 0x800 aperture or invent CSR clock/reset ties. |
| Aggregate header | F29 exists but is **zero bytes**, SHA `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855`; individual OFS memory exports and header receipts are missing. | Capture successful producer output under separate authorization; an empty file is not a valid configuration database. |
| List parser | F6 saves comma lists; F13:105–113 whitespace-splits `get_instance_parameter_value`. Saved XML is not API return evidence, and no parser failure is observed. | Capture those two actual API return strings in the authorized header stage before proposing delimiter changes. |
| SPD/physical/model qualification | Generated geometry is established, but selected RDIMM SPD, negative differential-clock board evidence and derived simulation-model configuration are not qualified. | Check module SPD and board clock evidence; separately compare saved `ed_sim_mem*.ip` derived geometry with each EMIF channel, without changing physical grouping or model count. |

Only this review and `generated-memory-correction-proposal.json` were created. The JSON retains every acceptance/readiness field false. No finite static receipt, raw synthesis HDL, or saved metadata substitutes for the missing OFS export, tool connectivity acceptance or hardware qualification.

# Final work03 memory correction review

**Not accepted. All readiness and qualification fields remain false.** This is a final review of the available captured evidence, not a claim that final synthesis HDL was inspected. Work03 generation finished FAIL; headers were not run. Only this report and `final-memory-correction-proposal.json` are written. No source, donor, shared manifest, authorization or gate is changed. No remote operation, vendor tool, HDL/Tcl execution, simulation, build, test or commit was performed. Python was used only for local text/JSON/XML inspection, hashing, arithmetic and proposal construction.

## Evidence boundary — the important final finding

`final-generation-evidence.json` SHA-256: `91887ab033812ff6bd416b90f58afea652868bcf4967053eeb9081c8bd936a84`.
All **109** captured payload SHA-256 values and byte counts independently match. The capture contains 105 generation reports plus the invocation, result, full log and enumerated-IP inventory. **Eleven reports are under memory `/synth/` paths, but zero captured files are HDL, saved IP/Qsys, SOPC interface metadata or generated headers.** Reports that say HDL was generated are not that HDL. The enumerated input inventory is not an output interface capture. A local filename search likewise did not locate a work03 raw memory HDL payload. No remote retrieval was attempted.

The receipt `files["qualification/ipgen-03/generate-result.json"]` records returncode 1. `execution-status.md:7-9` records the BMC mailbox failure and headers NOT RUN; the two header receipts are explicitly missing. `run-post-setup.py:13-16` writes the stage result and exits on a nonzero return before proceeding. The mailbox root cause/repair is owned by the separate reviewer and is not re-diagnosed here.

Decoded captured-file line references below refer to each payload's content, not the outer JSON line numbers:

- `R = work_ia840f_ipgen_03/ipss/mem/qip/mem_ss/mem_ss/mem_ss_generation.rpt`. R:3 is the simulation invocation; R:4 names AGFB027R25A2E2V. The final report also includes synthesis activity: R:586 targets that part with `--synthesis=VERILOG`; R:678-680 reports the nested subsystem done and synthesis HDL creation finished; R:726-728 finishes system and synthesis HDL creation. Do not classify this final report as simulation-only just because its first invocation is simulation.
- `S = work_ia840f_ipgen_03/ipss/mem/qip/mem_ss/mem_ss/mem_ss_mem_ss_501_qm5zaka/synth/`. The nested subsystem report at `S/mem_ss_mem_ss_501_qm5zaka/mem_ss_mem_ss_501_qm5zaka_generation.rpt:3,95-96` confirms the synthesis-generation invocation, 16 modules/8 files, and finish message.
- Under `S/ip/mem_ss_mem_ss_501_qm5zaka/`, EMIF0's report:3,16-17 and EMIF1's report:3,17-18 name the target and report three modules/50 files each and finish. These are generator-reported totals, not independently captured HDL counts. EMIF1:4 requires module-specific SPD verification; both reports mention calibration-IP clock/conduit dependency, Scheme 2 placement, estimated I/O usage and 33.333 MHz reference-clock-based frequency choices. None demonstrates fitted placement or actual operating frequency.
- The nested synthesis subsystem's `csr_*`/`global_csr` parameterization messages (:14-32,59) do not establish an exported CSR interface.

Memory synthesis **generation reports** therefore exist and show completion despite the enclosing BMC failure. Actual synthesis port shapes, internal associations and OFS wrapper/header contracts remain unobserved in this final capture. No memory-interface acceptance is promoted.

## Source and interim boundary reconciliation

Paths below are relative to `/home/joe/Projects/Thesis/AHLS/new_bsp/new`:
`C=ofs-agx7-pcie-attach`; `M=C/ofs-common/src/fpga_family/agilex/mem_ss`;
`G=C/ofs-common/scripts/common/syn/ip_get_cfg`;
`P=ofs-platform-afu-bbb/plat_if_develop/ofs_plat_if/src/rtl/ifc_classes/local_mem`.
`W` is decoded `files["sim/mem_ss.v"].content` from `interim-memory-wrapper.json`, explicitly **simulation** evidence. Its snapshot and current source hashes are recorded in the proposal JSON.

Static re-parsing confirms W has 128 port declarations and equal normalized mem0/mem1 DDR4 port shapes: each x64 DQ, eight DQS pairs/DBI, 17 address bits and two BA/two BG bits (W:7-46). Two application interfaces expose 512-bit data, 34-bit byte addresses, nine-bit IDs, eight-bit burst lengths, four-bit QoS and fourteen-bit AW/AR USER. W:61,73,103,115 declares the QoS inputs; W:62,74,104,116 declares request USER. No raw WUSER, RUSER or external CSR port appears. Reset request/cold reset inputs and ready/ack outputs are W:47-50; calibration status is W:91-92,133-134. These are not substituted for synthesis ports.

The interim HTML reports DDR4,DDR4; STORAGE,STORAGE; BOT,BOT; one-to-one connection vectors 1,0 and 0,1; CSR DISABLED. Those are configuration observations, not captured Qsys API return values or internal synthesis wiring.

Current preset `C/ipss/ia840f/presets/ia840f_mem.qprs` statically preserves the required discrete channel 0 and RDIMM channel 1. Relevant lines are 668-714 and 2092-2138: x64, row17/column10/BA2/BG2, one rank, discrete versus RDIMM formats. XML parsing computes `2^(17+10+2+2) * (64/8) * 1 = 17179869184` bytes per channel, **16 GiB each**. This is source-configured capacity, not a final saved/generated geometry or hardware capacity attestation.

The current 241 active memory location statements have the same package-pin multiset as the vendor's 241 selected channel-0/1 statements in `old_bsp/ia-840/IOFS_BUILD_ROOT/ofs-ia840f/syn/setup/emif_loc.tcl`. Static parsing accounts for the quoted negative-refclk alias. Donor hash and candidate hash are in JSON. No pin was moved, invented or rewritten.

## One exact source-supported patch proposal: defined QoS defaults

`M/mem_ss_top.sv:298-341` does not assign subsystem AWQOS/ARQOS. `M/ofs_fim_emif_axi_mm_if.sv:44,73` declares the fields; `P/native_axi/prims/gasket_fim_emif_axi_mm/map_fim_emif_axi_mm_to_local_mem.sv:44,74` comments out upstream QoS assignments. Forwarding only at the FIM would forward an undriven upstream value.

Propose zero defaults at the subsystem-facing mapping, after original lines 308 and 332, guarded by the corresponding producer width macros. `G/ip_gen_sv_wrapper.tcl:762-791` emits interface-presence/width macros; the guards avoid references to fields absent on other configurations. The proposal's exact old/new strings and unified diff are bound to current `mem_ss_top.sv` SHA-256 `7211a02c56ba18d8bc58c749de56242c3e1eb3c94e8c92d84c42a742cf04618c`. Anchors were checked unique in static text; nothing was applied or compiled. This is a narrowly supported defined-default policy, not validated arbitration behavior. Acceptance still requires actual generated headers confirming the macro names/fields and a separately authorized connectivity review.

```diff
--- a/ofs-agx7-pcie-attach/ofs-common/src/fpga_family/agilex/mem_ss/mem_ss_top.sv
+++ b/ofs-agx7-pcie-attach/ofs-common/src/fpga_family/agilex/mem_ss/mem_ss_top.sv
@@ -306,6 +306,9 @@
    assign ss_axi_mm[c].awlock   = afu_mem_if[c].awlock;
    assign ss_axi_mm[c].awcache  = afu_mem_if[c].awcache;
    assign ss_axi_mm[c].awprot   = afu_mem_if[c].awprot;
+ `ifdef IFC_MEM_SS_I_AXI_MM_IF_WIDTH_AWQOS
+   assign ss_axi_mm[c].awqos    = '0;
+ `endif
    assign ss_axi_mm[c].awuser   = afu_mem_if[c].awuser;
    // Write data channel
    assign afu_mem_if[c].wready  = ss_axi_mm[c].wready;
@@ -330,6 +333,9 @@
    assign ss_axi_mm[c].arlock   = afu_mem_if[c].arlock;
    assign ss_axi_mm[c].arcache  = afu_mem_if[c].arcache;
    assign ss_axi_mm[c].arprot   = afu_mem_if[c].arprot;
+ `ifdef IFC_MEM_SS_I_AXI_MM_IF_WIDTH_ARQOS
+   assign ss_axi_mm[c].arqos    = '0;
+ `endif
    assign ss_axi_mm[c].aruser   = afu_mem_if[c].aruser;
    // Read response channel
    assign ss_axi_mm[c].rready   = afu_mem_if[c].rready;
```

## Deferred corrections — missing evidence must not be guessed

| Finding | Exact source | Disposition |
|---|---|---|
| Expected one physical group versus candidate split | `G/ip_gen_sv_wrapper.tcl:420-504` compares interface structures (equality at 477); `C/syn/board/ia840f/setup/emif_loc.tcl:4-123` has 118 bundle targets under `ddr4_mem_group_1[0]` | Equal raw simulation shapes predict one two-element group, but actual API structures, synthesis boundary and emitted OFS SV are absent. Only if confirmed, replace those target prefixes with `ddr4_mem[1]`, preserving every PIN and refclk/OCT index. No executable pin patch is issued. |
| Width-one CS target | `emif_loc.tcl:155`: `set_location_assignment PIN_HB29 -to ddr4_mem[0].cs_n[0]`; producer `ip_gen_sv_wrapper.tcl:778-791` scalarizes width one | After emitted scalar confirmed, the exact intended target is `set_location_assignment PIN_HB29 -to ddr4_mem[0].cs_n`. No claim of current tool rejection; no pin patch now. |
| Conditional PIM USER mismatch | `C/src/top/ofs_agilex.ini:54-69`, specifically 66; `M/includes/ofs_fim_mem_if_pkg.sv:51-55`; `P/native_axi/local_mem_GROUP_cfg_pkg.sv:38-41`; `P/afu_ifcs/axi/ofs_plat_local_mem_axi_mem_pkg.sv:13-25` | With this selected template and missing WUSER, one-bit fallback plus one-bit NO_REPLY gives two bits, against W's fourteen-bit AW/AR inputs. Gasket:45,75 directly assigns request USER; response BUSER assignment is :61 and FIM RUSER is zero at `mem_ss_top.sv:341`. Need active generated PIM plus authoritative MSA bit semantics. Do not replace WUSER with AWUSER blindly or export the PIM flag as an EMIF command bit. |
| Comma list parsing | `G/mem_ss_get_cfg.tcl:105-113` whitespace-splits API values; HTML/preset serializes comma lists | API values not captured; headers never ran. No proven parser failure and no exact parser patch supported yet. |
| CSR absent | `ia840f_mem.qprs:7`; `M/mem_ss_top.sv:168-184,263-267` | Disabled source/interim boundary predicts DFH/status-only fallback, not restoration of legacy memory-local 0x800 subsystem CSR. Confirm emitted macro absence; no CSR enable, guessed aperture or clock/reset tie-off. |

Do not remove conditional group-1 RTL or change `DDR4_NUM_MEM_GROUPS`/OFSS `memory_groups=2` merely to follow the predicted physical group. The latter selects simulation-model configuration, not structural wrapper grouping (`ia840f_memory.ofss:10-12`). Two generated simulation model reports do not qualify model geometry or prove two physical groups.

The reset/status names and directions support the interim mapping, but actual synthesis clock/reset/calibration connections are not captured. Preserve the donor's reversed calbus association (calbus_1 to physical0, calbus_0 to physical1); do not infer it from group indices. RDIMM negative reference-clock coordinate remains unresolved; preserve positive HH48 and OCT GW48 and do not invent a negative pin. Module SPD values, model derived fields, reset-controller associations and cold-reset behavior remain qualification gates.

## Required next evidence, not execution authorization

Per `plan.md:77-88,170-177`, keep board-port, CSR, calibration, geometry and generated export checks open. Obtain same-run/same-input raw synthesis memory HDL and saved metadata, including internal EMIF/MSA/reset/calibration connections. Separately obtain the OFS producer outputs `mem_ss_sv.sv`, `mem_ss_if_info.vh`, `mem_ss_ip_params.vh`, `mem_ss_param_pkg.sv`, `ofs_ip_cfg_local_mem.vh`, aggregate `ofs_ip_cfg_db.vh` and producer diagnostics, plus active generated PIM configuration. Headers were skipped, so this is not a request to pretend these already exist.

Verify two application channels, widths, exact physical group/index map, scalar members, CSR macro state and actual API list values against that evidence. Then independently review pin-target and PIM ABI corrections. A later source edit must preserve donor provenance and rebind affected source inventories under separate authorization. No manually fabricated headers, fallback widths, reset bypass, model-count change or mailbox workaround can satisfy these gates.

The accompanying JSON records one source-supported QoS proposal and six deferred finding categories. **All readiness remains false; no source correction or generated interface is accepted.**

# Work03 PCIe/PLL live01 static review

**ready=false; ready_for_build=false; execution_authorized=false.** This review grants no capture, generation, build or test authority. Only the supplied local evidence was parsed; no remote access, Tcl/HDL/vendor execution, tests, source corrections or commits were performed. No part, routing contract, BAR or pin changes are proposed.

## Findings

1. The system PLL saved interface metadata advertises **outclk1 = 100,714,286 Hz (100.714286 MHz)**, not the requested 100 MHz. This is a saved elaborated nominal value, not yet a verified generated primitive/divider implementation, fitted clock or hardware measurement. It supplies the previously missing number behind the output-1 warning, at the saved-metadata layer only.
2. The PCIe parent still serializes **TILE_user=R-TILE**, but **does not serialize a parameter named TILE** anywhere in its full XML. Therefore this capture cannot directly certify the effective TILE value. Prior generation reports select P-Tile, and this batch's generated simulation file list names the P-Tile HIP. The R-TILE user field is inconsistent/stale relative to that selection; it must not be substituted for the effective selector or silently rewritten. Child configuration remains the next check.
3. Full saved parent configuration and interface footprints retain AGFB027R25A2E2V, Gen4 1x16, two PFs, PF0 with one VF, PF1 with zero VFs, the required PF1 BARs, 64-byte/two-segment datapath and CSR request 100. These are parent/interface facts, not full generated-child or behavioral acceptance.
4. No rendered SDC or QIP pathname occurs in these six payloads. Six exact simulation HDL paths can now be proposed from literal file-list references, without inventing synthesis counterparts. Rendered constraints and actual child/PLL configuration remain required.

## Capture integrity and scope-aware method

Input container: `pcie-generated-live01.json`, **1,654,814 bytes**, SHA256 `47f3b1dda97561f129a7ba0627a423d871c9b66a7af3ff313ad302f3af1a5ba4` (locally recomputed). All **six** full UTF-8 payload byte lengths and SHA256 values match their records; total decoded payload bytes **1,604,545**, errors **0**. This checks captured data consistency, not current remote state. The capture records vendor_run=false and ready_for_build=false.

`live01-next-reads.json` retains each verified input path/size/hash. The PCIe parent hash matches the earlier saved summary's source digest, but this review uses the full XML rather than that flattened summary.

XML was parsed namespace-aware with ordered parameter records retaining component/interface/vendor-extension scope, name, value and attributes. PCIe has **3,705 parameter records**, including **3,429 module parameters**, **72 bus interfaces** and **170 model ports**. PLL has **331 parameter records**, including **264 module parameters**, **10 bus interfaces** and **10 model ports**. There are no duplicate (scope,name) pairs. Across different scopes, repeated-name occurrences beyond the first number **202** for PCIe and **43** for PLL; flattening these would lose meaning. Module and system `device` occurrences both retain the exact part. In particular, a `clockRate` from a reference input is not the CSR input clock.

All four complete scripts were processed as inert text. Line counts: PCIe common list 343, PCIe mentor setup 449, PLL common list 82, PLL mentor setup 449. The common lists contain 261 and 2 literal HDL file references respectively. Both setup scripts reference the common list at decoded line 168 and contain a default QSYS_SIMDIR at lines 111–112; nothing was sourced. The ordered literal-reference inventory is retained in the next-reads JSON, including setup-script library references. Presence in a compile list does not prove an active instantiated branch: notably both P-Tile and R-Tile wrapper sources occur in the PCIe list.

Both XML files refer to `QUARTUS_SYNTH` through `model/instantiations/componentInstantiation/fileSetRef/localName`; neither contains a populated fileSet/file inventory. `QUARTUS_SYNTH` is not a filesystem path. No `.sdc` or `.qip` reference occurs in the six full bodies.

## Saved PCIe contract and interface footprint

Unless stated otherwise, parameters below belong to `component[pcie_ss]/vendorExtensions/altera_module_parameters/parameters`. Decoded XML line references refer to the captured PCIe `.ip` body.

| Requirement | Saved evidence | Boundary |
|---|---|---|
| Exact part | `device=AGFB027R25A2E2V`, repeated consistently in system parameters | No fitted-device result |
| P-Tile Gen4 x16 | `top_topology_hwtcl=Gen4 1x16`; generated list line 28 names `pcie_ss_intel_pcie_ptile_ast_1100_ndgxg4a.sv` | Effective `TILE` absent; `TILE_user=R-TILE` at lines 5889–5892; child body needed |
| PF/VF counts | `core16_total_pf_count_hwtcl=2`, `core16_pf0_vf_count_hwtcl=1`, `core16_pf1_vf_count_hwtcl=0`, at lines 18219,18229,18234 | Preserves PF0VF0 AFU/PF1 BMC contract; functional routing not tested |
| PF1 BAR0 | `core16_pf1_bar0_type_user_hwtcl=Disabled`; width remains 12 | Width does not enable a disabled BAR |
| PF1 BAR2 | Type `64-bit prefetchable memory`, address width `28` (line 8639) | No generated decode or aperture/bridge change justified |
| PF1 BAR4 | Type `64-bit prefetchable memory`, address width `14` (line 8659) | Preserve exactly |
| Datapath workaround | `core16_dwidth_byte_user_hwtcl=64` (6444); `core16_num_seg_user_hwtcl=2` (6584) | Parent footprint supports this, generated child still needed |
| CSR request | `core16_axi_lite_clk_freq_user_hwtcl=100` (6524) | Request only; not source-domain measurement |

PF0 has BAR0 64-bit prefetchable width20, BAR2 disabled width0, BAR4 64-bit prefetchable width14; its VF BAR0/2/4 have the same enabled/type/width pattern. PF1 VF BAR0/2/4 are disabled width0 and PF1 has no VF. These settings must not be mistaken for additional active functions.

ID conversions were computed locally from decimal XML values:

| Function | Vendor/device | Revision/class | Subsystem vendor/device | VF device |
|---|---|---|---|---|
| PF0 | 0x8086 / 0xbcce | 0x1 / 0x120000 | 0x8086 / 0x1771 | 0xbccf |
| PF1 | 0x12ba / 0x70 | 0x1 / 0x120000 | 0x12ba / 0xb5d4 | 0x0 (inactive: VF count zero) |

Saved model ports have RX/TX data vector endpoints 0 and 511, keep endpoints 0 and 63, and last_segment/hvalid endpoints 0 and 1. These are a 512-bit/64-byte, two-segment **saved boundary footprint**, not captured generated HDL acceptance. Preserve the XML's endpoint ordering rather than silently rewriting it as an HDL declaration. `hip_serial` maps tx_n_out, tx_p_out, rx_n_in and rx_p_in for lanes 0–15; refclk0/refclk1 and pin_perst_n remain present. This is logical pin/interface evidence, not physical pin-placement qualification; existing physical assignments remain untouched.

### Clock scope correction

- `busInterface[p0_axi_lite_clk]`: input logical clk maps to physical `p0_axi_lite_clk`, **clockRate=0**, externallyDriven=false. Zero is not proof of a stopped clock or a physical frequency.
- `busInterface[p0_axi_st_clk]`: clockRate=0 as well; do not transfer another interface's rate here.
- `busInterface[p0_lite_csr]`: associatedClock=`p0_axi_lite_clk`, associatedReset=`p0_axi_lite_areset_n`.
- `busInterface[p0_axi_lite_areset_n]`: associatedClock=`p0_axi_lite_clk`, synchronousEdges=`DEASSERT`.
- `busInterface[refclk0]` and `[refclk1]`: clockRate=100000000, **reference inputs**, not the CSR source.
- `busInterface[coreclkout_hip_toapp]`: clockRate=500000000, clockRateKnown=true, **HIP output**, not the CSR source.

`core16_axi_lite_source_freq_hwtcl` remains proven only as the SDC-template dictionary key described in `existing-evidence-review.md`, not a demonstrated child-IP parameter. Its absence must not be turned into a fabricated child-field acceptance rule. Need the rendered PCIe SDC, targeted clock objects/periods and actual consumer binding.

## PLL nominal metadata: request versus saved result

The PLL component is `iopll_0` (library sys_pll, version 21.1.0). Module parameters declare Integer-N PLL, direct operation, seven output clocks, reference request 100.0 MHz and reference period 10000.0 ps. Scoped refclk metadata also says 100000000 Hz. This is a design assumption, not a measurement of SYS_REFCLK.

For each output below, the `busInterface[outclkN]/parameters` scope supplies `clockRate` and `clockRateKnown=true`. The serialized system parameter `systemInfos` independently repeats those exact CLOCK_RATE values per named outclk connection point. The outclk1 logical clk maps specifically to physical **outclk_1**. No flattened last-value selection was used.

| Output | Request MHz | Saved nominal clockRate Hz | Nominal MHz | Difference from request |
|---|---:|---:|---:|---:|
| 0 | 470 | 470000000 | 470 | 0% |
| 1 | 100 | 100714286 | 100.714286 | +0.714286% |
| 2 | 235 | 235000000 | 235 | 0% |
| 3 | 630 | 705000000 | 705 | +11.904762% |
| 4 | 50 | 50357143 | 50.357143 | +0.714286% |
| 5 | 117.5 | 117500000 | 117.5 | 0% |
| 6 | 350 | 352500000 | 352.5 | +0.714286% |

All conversions and differences were calculated with Python from the captured values: MHz=clockRate/1e6; relative difference=(nominal/request−1). Output1's saved rate corresponds to **9.929077986 ns**, about **+7142.86 ppm** above the request. Integer-Hz metadata precision does not establish an exact divider ratio or extra physical accuracy. This pattern agrees with the prior report warnings on outputs 1,3,4,6; it does not establish an approved tolerance.

**Do not compute the implemented PLL from stale GUI defaults.** The same module serializes gui_multiply_factor=6, gui_divide_factor_n=1, all gui_divide_factor_cN=6, gui_vco_frequency=600.0 and gui_fixed_vco_frequency=600.0. But gui_en_adv_params=false and gui_fix_vco_frequency=false. Naively applying 100×6/(1×6) yields 100 MHz for every output, contradicting both the requested multirate configuration and scoped output metadata. These fields are not evidence of actual selected primitive counters. Some serialized frequency_ps fields also retain 10000.0 despite different MHz requests. Do not reverse-engineer or assert M/N/C or a VCO from rounded rates; inspect the generated PLL netlist next.

The maintained source trace in the previous review connects SYS_REFCLK to sys_pll, outclk_1 to clk_100m, clk_csr=clk_100m and wrapper csr_clk to p0_axi_lite_clk. This batch improves the saved output mapping and metadata evidence, but has not captured that complete generated/fitted continuity. Thus the supported statement is **saved nominal CSR producer metadata approximately 100.714286 MHz under the 100 MHz reference assumption**, not "hardware is exactly 100 MHz" and not yet "generated implementation independently verified at 100.714286 MHz." PCIe's separate internal PLL must not be confused with this board CSR producer.

## Finite next reads and unresolved boundary

`live01-next-reads.json` proposes **six exact simulation HDL files**: PCIe top, generated AXI subsystem, P-Tile bridge, P-Tile HIP, sys_pll top and sys_pll PLL netlist. Each has the literal reference, decoded source line, original capture source path, explicit QSYS_SIMDIR and lexically normalized absolute path. The references come from PCIe common-list lines 284,101,100,28 and PLL common-list lines 23,22 respectively. No directory traversal, inferred suffix or synth/sim substitution is authorized. The complete inert script reference inventory is evidence, **not an expanded capture allowlist**.

These files can expose actual simulation-generation parameters and wiring. Their existence/content has not been checked remotely, and they are not assumed to be synthesis-identical. If encrypted, missing or over cap, preserve that outcome rather than guessing an alternative. The proposal caps each file at 4 MiB and the batch at 16 MiB, with no execution or regeneration and separate authorization required.

**Blocked exact paths:** no literal generated synthesis QIP/manifest or rendered PCIe/PLL SDC path is present in the current payloads. Do not manufacture `synth/...`, replace `.vo` with `.v`, or append `pcie_ss.sdc` to a guessed directory. A later separately authorized evidence root must establish those exact paths. The simulation HDL batch is useful but does not itself close this gap.

## Acceptance disposition

- PASS, captured-parent layer: exact part, requested link topology, PF/VF counts, BAR types/widths, IDs, width/segment workaround and CSR request.
- PASS, scoped saved-interface layer: explicit 100714286 Hz output1 nominal metadata and logical outclk1→outclk_1 mapping; saved PCIe clock/reset associations and datapath footprint.
- P-Tile selection corroborated by prior generation report plus generated file-list reference; literal effective TILE and complete generated child acceptance remain NOTEST.
- Prior PCIe simulation-model/synthesis-HDL generation completion remains report-level evidence only. Work03 overall generation failure, including mailbox errors, is not cured by this review.
- Generated PLL divider/primitive verification, rendered SDC and synthesis hierarchy binding, approved clock tolerance, resets/CDC, fitting/timing closure and hardware behavior remain NOTEST. No simulation was run.

**Keep ready=false.** Preserve AGFB027R25A2E2V, PTileGen4x16, PF0VF0 AFU, PF1 BMC, PF1 BAR0 Disabled, BAR2 width28, BAR4 width14 and existing pins. Nothing here authorizes source remediation or capture execution.

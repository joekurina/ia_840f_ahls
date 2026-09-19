# Work03 PCIe generated-evidence review

**Decision: ready=false.** Local static review only. No remote access, Tcl/HDL/vendor execution, tests, source/gate changes, or commits. This review does not authorize capture or generation. Memory and mailbox remediation are outside this review.

## Outcome

PCIe itself completed simulation-model and synthesis-HDL generation in Work03. That is stronger evidence than installed schema exposure, but it is not the missing generated parameter/export acceptance. The captured PCIe report does not print the CSR frequency, PF counts, BAR widths/types, or generated port dimensions. The actual CSR producer frequency remains unknown, and the Work03 system PLL report explicitly repeats the output-1 requested-versus-actual warning.

**Important correction to the earlier evidence interpretation:** `core16_axi_lite_source_freq_hwtcl` in captured `pcie_ss_fileset.tcl:212–265` is a local **SDC template parameter**, inside `pcie_ss_sdc_handling`, not demonstrated child-IP parameter forwarding. Lines 223 and 249 read the parent's requested frequency and put it in the template dictionary; lines 261–264 render `pcie_ss.sdc.terp` and register `pcie_ss.sdc`. Therefore demanding a child-IP field with that name alone is not a justified acceptance test. Inspect the generated SDC and its clock objects/periods, as well as generated child configuration and wiring. Neither a template dictionary nor saved interface `clockRate` is a physical measurement.

## Evidence inspected and limits

All paths below are relative to `N=/home/joe/Projects/Thesis/AHLS/new_bsp/new` unless explicitly absolute.

- `plan.md:166–177`: Stage C requires exact generated exports, part, width/segments, PF/VFs, BARs/IDs, and clocks/resets before synthesis acceptance. Source strings alone are insufficient.
- `qualification/ipgen-03/pcie-csr-clock-correction.md`: donor request 100; Work02 saved parent 250; translated modern port-0 request. Its historical local test results were not rerun or treated as vendor qualification.
- `qualification/ipgen-03/remote-setup-full.log:305`: actual deployment command contains `core16_axi_lite_clk_freq_user_hwtcl="100"`, `core16_dwidth_byte_user_hwtcl="64"`, `core16_num_seg_user_hwtcl="2"`; no legacy unprefixed frequency assignment was found.
- `qualification/ipgen-03/remote-saved-pcie-summary.json`: saved-IP digest `7a3d6d059753bd88c4dfe905f59db15033c29667eb3df520e1016758a4fb1166`, with a flattened parameter dictionary. This is not full XML, an ordered scope-aware extraction, or generated child/export data. Generic `associatedClock`, `clockRate=100000000`, and `clockRateKnown=true` have lost interface scope and cannot establish physical frequency. The original saved IP cannot be rehashed from this summary.
- `qualification/ipgen-03/final-generation-evidence.json`: decoded complete report contents, not the tool UI's shortened long-line display, were inspected. It contains the PCIe and sys_pll generation reports, full generation log/result/invocation and enumerated input-IP manifest. The non-report entries contain no generated QIP, SDC, HDL, SOPCINFO, or child parameter/export files. `generation-interim-evidence.json` adds no PCIe/PLL generated bodies. This absence statement is bounded to these supplied captures, not an installation-wide search.
- `qualification/goal-initial-preflight/pcie-installed-dependency-discovery.md:18–24`: installed P-Tile child version 11.0.0 and PF1 BAR2 schema admit the requested type/width. This remains installed-source evidence, not a generated BAR acceptance report.
- `reference/quartus-26.1.1-pcie/hwtcl/pcie_ss_fileset.tcl:64–78,212–265`: effective `TILE` selects child kind; CSR request drives the SDC template dictionary.

SHA256 computed locally for the two capture containers:

| Capture | SHA256 |
|---|---|
| `qualification/ipgen-03/final-generation-evidence.json` | `91887ab033812ff6bd416b90f58afea652868bcf4967053eeb9081c8bd936a84` |
| `qualification/ipgen-03/remote-saved-pcie-summary.json` | `4644d764f892d98f43655284425c34ef310bdb82f0a6052d2f01b2b155c24399` |

The decoded PCIe and sys_pll report hashes were recomputed and matched their capture records. This verifies capture consistency, not live remote state.

## Contract dispositions

PASS means only the evidence layer explicitly named here; NOTEST means missing verification, not a demonstrated functional defect.

| Contract | Disposition | Evidence and remaining boundary |
|---|---|---|
| Project-wide Stage C generation | **FAIL** | Recorded return code 1; full log ends unsuccessful with 8 errors/1025 warnings. Mailbox `Agent with readdatavalid must use waitrequest` errors are recorded. Header invocation/result are explicitly missing. No overall generation acceptance. |
| PCIe simulation/synthesis generation step | **PASS — report only** | `work_ia840f_ipgen_03/ipss/pcie/qip/pcie_ss/pcie_ss_generation.rpt` reports completion: simulation 6 modules/261 files, synthesis 6 modules/268 files; no claim of design compilation, simulation execution or timing closure. |
| AGFB027R25A2E2V | **PASS — request/report** | Saved parent `device`; both PCIe report commands use exact part. Fitted-device acceptance NOTEST. |
| P-Tile Gen4 x16 | **PASS — parent topology and generated child selection; NOTEST exact child export** | Parent `top_topology_hwtcl=Gen4 1x16`; report says one x16 port and generates `intel_pcie_ptile_ast` child. Flattened `TILE_user=R-TILE` is also present: do not silently rewrite it or treat it as the effective `TILE`. Installed callback selects from `TILE`, while the report demonstrably selects P-Tile. Obtain scoped effective metadata before closing this discrepancy. |
| Two PFs; PF0 has VF0; PF1 has no VF | **PASS — saved parent; NOTEST full generated acceptance** | `core16_total_pf_count_hwtcl=2`, `core16_pf0_vf_count_hwtcl=1`, `core16_pf1_vf_count_hwtcl=0`. Report prints PF0/PF1 IDs but no exhaustive VF-count export. PF0VF0 AFU/PF1 BMC routing behavior NOTEST. |
| PF1 BAR0 disabled | **PASS — saved parent; NOTEST generated decode** | `core16_pf1_bar0_type_user_hwtcl=Disabled`; saved width 12 does not enable a disabled BAR. |
| PF1 BAR2 64-bit prefetchable, width 28 | **PASS — saved parent; NOTEST generated decode** | Exact type `64-bit prefetchable memory`, width `28`. Installed schema capability is not promoted to generated acceptance. |
| PF1 BAR4 width 14 | **PASS — saved parent; NOTEST generated decode** | Width `14`, type `64-bit prefetchable memory`. No aperture or bridge widening justified. |
| IDs retained | **PASS — named generation report values; NOTEST exhaustive config comparison** | P-Tile child report prints PF0 0x8086/0xbcce, VF device 0xbccf; PF1 0x12ba/0x70; both revision 0x1/class 0x120000. Logs for inactive PCIe2/3 defaults are not proof of additional active ports. |
| Modern datapath workaround | **PASS — saved parent; NOTEST generated width/segments** | `core16_dwidth_byte_user_hwtcl=64`, `core16_num_seg_user_hwtcl=2`. Do not revert these to legacy controls; no exported port dimensions captured. |
| CSR request correction | **PASS — command and saved parent** | `core16_axi_lite_clk_freq_user_hwtcl=100`; legacy `axi_lite_clk_freq_user_hwtcl` absent from saved summary. |
| Generated CSR constraint/child acceptance | **NOTEST** | No generated SDC, parameter/export report or child body captured. `core16_axi_lite_source_freq_hwtcl` absent from summary and is proven only as SDC-template input in installed source. |
| CSR source-domain connectivity | **PASS — maintained source intent; NOTEST Work03 generated/fitted continuity** | Trace below; no generated wrapper or clock report captured. |
| Actual sys_pll output-1 / tolerance | **NOTEST; warning unresolved** | Work03 report explicitly says actual frequency 1 differs from request. No actual number, divider implementation, generated-clock constraints or approved tolerance assessment. Exact physical 100 MHz is not established. |
| CDC/reset, timing and hardware behavior | **NOTEST** | No tests, fitting or measurements in this review; a successful model-generation message is not a simulation result. |

## Actual generated-report observations

The PCIe report names these generated modules (names are evidence, not permission to guess file suffixes/directories):

- `pcie_ss_intel_pcie_ss_axi_500_gycdipy`
- `pcie_ss_intel_pcie_ss_axi_intel_pcie_ptile_ast_500_pxriq3y`
- `pcie_ss_intel_pcie_ptile_ast_1100_ndgxg4a`
- `pcie_ss_altera_iopll_2110_5imavpa`

The system PLL report names `sys_pll_altera_iopll_2110_3lkpvti` and finishes synthesis-HDL generation with 2 modules/7 files, but repeats warnings for outputs 1, 3, 4, 6. PCIe's separate `intel_ptile_io_pll_250` message says it can implement its settings. That PLL is **not evidence that board CSR is 250 MHz**, nor does its successful generation resolve the system PLL output-1 warning.

Report keys in `final-generation-evidence.json`:

- `work_ia840f_ipgen_03/ipss/pcie/qip/pcie_ss/pcie_ss_generation.rpt`
- `work_ia840f_ipgen_03/ofs-common/src/fpga_family/agilex/sys_pll/sys_pll/sys_pll_generation.rpt`

## Clock connectivity and remaining acceptance

Maintained board source `ofs-agx7-pcie-attach/src/board/ia840f/top.sv:509–520` connects SYS_REFCLK to sys_pll and `outclk_1` to `clk_100m`; line 300 aliases `clk_csr=clk_100m`; line 590 passes `clk_csr` to `pcie_wrapper.csr_clk`. The wrapper forwards `csr_clk` (`ofs-common/src/fpga_family/agilex/pcie_ss/pcie_wrapper.sv:177,225,269`). The PCIe adapters connect `p0_axi_lite_clk` to `csr_clk` (`pcie_ss_dm_top.sv:232`, also `pcie_ss_axis_top.sv:716`); the DM path connects `p0_axi_st_clk` to `fim_clk` and distinct CSR reset at lines 231–234. These are source intentions, not the generated Work03 hierarchy/constraint binding.

Required subsequent static review: recover generated PLL output frequency and divider configuration; reconcile reference-clock assumption and output-1 mapping; inspect the rendered PCIe SDC clock names, periods and scope; confirm that those constraints reach the actual `p0_axi_lite_clk` consumer, including resets/CDC. Distinguish requested 100, implemented nominal frequency from PLL configuration, and measured hardware frequency. A mismatch warning alone does not supply the actual number or justify editing PLL settings. Fitted timing and hardware measurements remain separate later qualifications.

## Bounded missing capture proposal

`next-exact-reads.json` contains **six exact missing files** grounded in the captured report commands and emitted simulation-script lists: two original saved IPs and four generated file-list scripts. These are the next evidence roots, not a claim to possess a complete generated synthesis-file inventory. Both original saved IP bodies are needed for scope-aware metadata and any serialized generation/file manifest; only PCIe has the flattened local summary.

No generated QIP body or persisted child export manifest is present in the reviewed captures. Report module names alone do not establish full child file paths. Consequently this review deliberately does **not** guess `synth/...`, child `.v`/`.sv`, `.qip`, `.sopcinfo`, or generated SDC paths. The simulation list scripts can name actual generated HDL, but must not be mistaken for synthesis-only timing evidence. Parse them as inert text, never source them. Any subsequently referenced synthesis QIP, SDC, generated PLL implementation or child export must be proposed in a separate finite exact-path batch after its literal reference is available. If these roots do not name the needed synthesis metadata, report that blocker rather than authorize directory traversal or infer a suffix.

Proposal limits: exact files only; no globbing/recursive scans, vendor execution or regeneration; preserve missing/oversize/read-error outcomes; cap each file at 4 MiB and the batch at 16 MiB; capture full bytes, path, size and SHA256 or explicitly mark omitted. Do not silently truncate parameter/export evidence. Separate approval is required even for this read-only capture. **ready=false; execution_authorized=false.**

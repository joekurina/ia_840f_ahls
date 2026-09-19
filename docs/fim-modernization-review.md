# IA840F FIM modernization source review

## Outcome and boundary

**Source preparation only; `ready_for_build=false` remains mandatory.** One concrete missing-module dependency was corrected using the pinned modern OFS implementation. This is not a build-ready FIM, a qualified standard/USM BSP, or a toolchain-compatibility claim.

Only the FIM board bridge and its provenance manifest were modified, plus this report. No configure/setup, IP generation, compilation, build, simulation, tests, vendor-tool execution, installation, remote access, hardware operation, commit or push was performed. Evidence below is local source reading, XML/JSON parsing, hashing, Git read-only inspection and text comparison, not HDL/Tcl execution.

Source roots:

- Vendor: `/home/joe/Projects/Thesis/AHLS/new_bsp/old_bsp/ia-840/IOFS_BUILD_ROOT/ofs-ia840f` (read-only).
- Candidate: `/home/joe/Projects/Thesis/AHLS/new_bsp/new/ofs-agx7-pcie-attach`.
- Pinned FIM: `599ac052eafbc9cede22561c099233ae4a54cb7d`, corresponding to the existing lock's `ofs-2025.1-1` selection.
- Pinned `ofs-common`: `34a8540697fdf3d66fbcaa263fa037bae17cc32f`.

Both actual checkout HEADs match these pins. “Current pinned upstream” here means these locked local sources, not a fresh assertion about GitHub's latest release. No upstream shared file was modified. Existing custom hostchannel experiments were not imported or made the baseline.

## Implemented correction: BMC CDC reference migration

Changed `src/board/ia840f/bwbmc_st2mm.sv`:

1. The candidate still instantiated `pcie_axis_cdc_fifo` twice. That module exists in the old vendor `ofs-common/src/common/st2mm/pcie_axis_cdc_fifo.sv`, but no definition exists in the pinned modern tree. Copying the candidate wrapper without this migration left an unresolved module dependency.
2. Replaced those instances with the actual `ofs_fim_axis_cdc` implementation and TX skid stage used by modern `ofs-common/src/common/st2mm/st2mm.sv:116–142`. Its implementation is already registered by `ofs-common/src/common/lib/lib_design_files.tcl`; no legacy common library was overlaid.
3. Kept the vendor `DEPTH_LOG2=6` and `ALMFULL_THRESHOLD=4` rather than silently adopting the management reference's depth 4. Modern CDC computes its packed payload width from the interface and carries data, keep, vendor user and last.
4. Added a local RX interface bound to the bridge's `clk` and endpoint `rst_n`, connected with the reference library's `ofs_fim_axis_pipeline #(.PL_DEPTH(0))` bypass. This is necessary because the new CDC uses `axis_s.clk/rst_n`, while `fim_afu_instances.sv` binds the outer mux interfaces to global `rst_n[0]` and passes PF1 `port_rst_n[p]` separately into this bridge. A mechanical module rename using the outer interface would lose PF1 ownership of the RX FIFO clear.
5. Bound TX CDC output and the reference TX skid to the endpoint clock/reset. Preserved global CSR reset for the CSR logic and TX FIFO write side. Kept the existing polling-only MSI-X tie-offs, BMC address/data widths, request/response bridge, and PF identity routing untouched.

This changes buffering implementation; it is not asserted to be cycle-equivalent to the old FIFO or to resolve FLR behavior. The old FIFO used a source-reset output-valid register; the new CDC's FIFO asynchronous clear derives only from its input interface. The modern TX skid supplies an endpoint-reset output stage, but the CSR-domain TX FIFO can retain data through PF1 FLR. Outstanding requests, stale completions and reset ordering still need a reviewed transaction policy and later authorized qualification. No speculative reset-domain redesign was made.

Changed `syn/board/ia840f/source_manifest.json` to bind the new wrapper bytes and explicitly name the modern source paths/commit. The legacy origin hash remains unchanged.

## Vendor hardware retained

- **Part/configuration:** `syn/board/ia840f/syn_top/ofs_top.qsf` retains `AGFB027R25A2E2V`, active-serial x4, 125 MHz device-initialization oscillator selection, PMBus slave address `01`, linear exponent `-12`, and vendor SDM pin selections. No N6001 or development-kit part/power defaults replaced them.
- **Board top and AFU:** comparison against pinned `src/top/top.sv` and `src/afu_top/afu_top.sv` shows the candidate's changes are BMC sideband ports and their forwarding connections. Modern PR, local-memory and PCIe/FLR APIs remain the reference implementations.
- **Static endpoint:** candidate `fim_afu_instances.sv` selects BMC by `PFVF_ROUTING_TABLE[p].pf == 1 && !vf_active`, not legacy mux index. Reference exercisers in other branches are inherited source, not evidence that additional PFs are intended for IA840F.
- **Pins and inactive hardware:** pin scripts, memory-group proposal, vendor reference copies, PR floorplan and BMC timing files were not changed in this review. HSSI, HPS, PMCI and UART remain disabled in the board QSF. No development-kit QSFP/PMCI control was substituted for BittWare's board management.

## Unresolved mixed discrete DDR4 / RDIMM contract

The vendor's selected `ipss/mem/mem_design_files.tcl:24–40` explicitly uses manually generated `mem_ss_fm_0.qsys` and its sub-IP to add RDIMM on the second channel. It does not select the commented-out monolithic `mem_ss_fm.ip`.

Static parsing of the actual vendor `mem_ss_fm_0_intf_0.ip` and `mem_ss_fm_0_intf_1.ip` confirms:

| Parameter | Channel 0 | Channel 1 |
|---|---|---|
| `MEM_DDR4_FORMAT_ENUM` | `MEM_FORMAT_DISCRETE` | `MEM_FORMAT_RDIMM` |
| `MEM_DDR4_DQ_WIDTH` | 64 | 64 |
| `MEM_DDR4_RANKS_PER_DIMM` | 1 | 1 |
| Row / column / bank / bank-group widths | 17 / 10 / 2 / 2 | 17 / 10 / 2 / 2 |
| `PHY_DDR4_MEM_CLK_FREQ_MHZ` | 1333.333 | 1333.333 |
| `PHY_DDR4_USER_REF_CLK_FREQ_MHZ` | 33.333 | 33.333 |
| `CTRL_DDR4_ECC_EN` | false | false |

These are configured source properties, not installed DIMM/SPD observations. Preserve the full per-interface timing, skew, termination and calibration settings in the retained vendor source; the table alone is insufficient to author a replacement preset.

Modern `ipss/mem/mem_design_files.tcl:43–65` selects `ipss/mem/qip/mem_ss/mem_ss.ip`, registers it for `mem_ss_get_cfg.tcl`, and selects additional simulation-model groups according to `DDR4_NUM_MEM_GROUPS`. The candidate sets that macro to 2 and proposes `ddr4_mem[0]` for discrete and `ddr4_mem_group_1[0]` for RDIMM. This is still a proposal, not a known generated-IP pin contract. Resolve:

- Whether the modern part-specific `mem_ss` preset can represent both physical formats, with correct channel/group ordering and actual generated types/ports.
- Refclk/OCT association, package-pin mapping, alert/parity scalar/vector shape, AXI widths/IDs and calibration-location compatibility.
- The active IP-generation and configuration-database contract; do not rename old Qsys/IP wrappers or manufacture DB headers.
- Missing/implicit physical information such as the second reference clock's negative-pin assignment; do not invent it.

`config/ia840f_memory.ofss` continues to name `ia840f_discrete_rdimm_PENDING_MIGRATION`. No guessed modern preset, generic two-channel substitution, or generated IP was added.

## Unresolved PCIe and BMC contract

### PCIe hardware identity and apertures

The actual vendor `ipss/pcie/qip/pcie_ss.ip` has `top_topology_hwtcl=Gen4 1x16`, `core16_total_pf_count_hwtcl=2`, PF0 VF count 1 and PF1 VF count 0. Its PF1 vendor/device numeric values are 4794/112; preserve them rather than generic OFS identities. PF1 BAR0 is **Disabled**, even though an inactive BAR0 width parameter remains 12. BAR2 is **64-bit prefetchable memory, width 28**; BAR4 is **64-bit prefetchable memory, width 14**. PF0 vendor/device numeric values are 32902/48334 and its VF device value is 48335. The stale vendor five-PF OFSS and PF3 comments must not supersede the selected IP/routing source.

Modern `ofs-common/tools/ofss_config/ip_params/intel_pcie_ss_axi_parameters.py` hardcodes the PF BAR0 type to enabled 64-bit prefetchable memory and exposes BAR0/BAR4 width controls; it does not supply the required PF1 BAR2/disabled-BAR0 contract. A default `[pf1]` section is not an IA840F port. `pcie_ip.py` also contains the P-Tile Gen4x16 two-segment workaround, which must survive any reviewed generation approach.

`config/ia840f_pcie.ofss` remains `ip_component=intel_pcie_ss_axi` with `ia840f_pf0vf0_pf1_bmc_PENDING_MIGRATION`. Resolve modern IP parameter availability, identity/apertures, single-link topology, routing-table generation, reset/FLR, MSI-X/CSR layout and board-software assumptions before replacing that placeholder. No IP parameter guesses were made.

### BittWare subsystem dependencies

The selected `ipss/ia840f/bwbmc_sources.tcl` preserves vendor Qsys, the SPI-to-Avalon path, mailbox, shared memory, host/BMC arbitration and IRQ components. It appends board-local custom-IP search paths; this is source discovery preparation, not successful Qsys discovery or regeneration.

Dependencies remain old: SPI IP 19.1.3, SDM mailbox 20.2.2, custom `arbiter_hw.tcl` requiring exactly Qsys 16.0 and `irq_generator_hw.tcl` requiring exactly Qsys 15.1. Version strings were not edited to claim modern compatibility. The BMC IRQ-to-host MSI-X path is unimplemented: wrapper `pcie_irq` remains disconnected and `msix_strb` remains zero. Polling-only behavior must not be advertised as interrupt support.

The new CDC correction removes a missing module, **not** these blockers. PF1 reset versus global CSR reset still permits transactions to span unlike reset domains; the upstream FLR manager response is not proof the BMC path has drained. Resolve the complete outstanding-transaction/reset policy before any readiness claim.

## Other gates retained

- Board `setup/build_gate.tcl` still sets readiness false and errors without an environment-variable bypass. Both board QSF revisions still reference it.
- No preset placeholders were replaced; no gate was removed or weakened.
- Clock coherence (legacy PLL/source comments versus modern generated clock configuration), BMC timing, PR floorplan/timing and physical fit remain unresolved.
- Standard and USM ASP integration, compiler-visible host pipes and MMD behavior are outside this FIM patch. A FIM TLP endpoint does not establish oneAPI host-pipe support. No custom queue architecture or per-frame launcher substitution was introduced.
- Requested Quartus 26.1.1/oneAPI FPGA compatibility is unverified. Source-only preparation cannot establish device/IP/PR/tool support.

## Static evidence

A stdlib-only source inspection parsed the manifest and source IP XML, enumerated the selected files and compared SHA-256 values. Results after the edit:

- All **86** manifest entries match their candidate files; zero candidate hash mismatches.
- Zero origin-hash mismatches for entries carrying `source_sha256`; **61** entries have byte-identical candidate/origin hashes.
- Active BMC wrapper contains **two** modern `ofs_fim_axis_cdc` instances, the TX skid, and no `pcie_axis_cdc_fifo` reference. Legacy reference copies remain untouched.
- Both `ofs_top.qsf` and `ofs_pr_afu.qsf` retain the gate reference, and manifest readiness remains false.
- The untouched files' pre-existing manifest hashes still match, including the board pins, IP descriptions, BMC wrapper, gate, modern board top/AFU and retained vendor originals.

| Source | SHA-256 |
|---|---|
| Edited `src/board/ia840f/bwbmc_st2mm.sv` | `472b7c2ad6828ff6bdfd48c7f722388bbdb1ca788a7dacc0dbf28fceddb72a07` |
| Unchanged `syn/board/ia840f/setup/build_gate.tcl` | `0440ac3808cd456b2e32925caacbf4a5bc00459d17135596db32b1c1fe4b0b34` |
| Reference `ofs-common/src/common/st2mm/st2mm.sv` | `14323d5ff492ef67d70ca84cc24c52e863e06689c928064148ec9087ff3d2dca` |
| Reference `ofs-common/src/common/lib/axis/ofs_fim_axis_cdc.sv` | `da9aa206429ba57a9e0ffc71be3143dbfea876fdf33a76d76d1cae6ad91bd868` |
| Reference `ofs-common/src/common/lib/axis/ofs_fim_axis_pipeline.sv` | `2ae338e5c2f7b89cb7820bbfb8125a663873de47025d0d1d108d43f32b558086` |

These checks do not establish Tcl evaluation, HDL syntax/elaboration, complete module closure, timing, CDC correctness, electrical compatibility, runtime functionality or hardware readiness. The result is a narrower, source-grounded candidate with explicit blockers, not a qualified BSP.

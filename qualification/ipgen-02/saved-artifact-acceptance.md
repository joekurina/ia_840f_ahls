# Work02 saved-artifact checks

These are parent filesystem/XML checks of preserved work02, not RTL generation, elaboration, timing, or hardware acceptance. Readiness remains false. No work02 source, claim, authorization, or output was changed by these inspections.

## Evidence

- `remote-post-setup-artifact-snapshot.json`: 205 IP/Qsys/QSF/QPF/preset entries; claim equals authorization SHA256.
- `remote-deployed-ip-source-content.json`: byte content and SHA256 for five saved IP files. Every SHA256 matched the earlier snapshot.
- `deployed-ip-scoped-parameters.json`: ordered XML parameter records with packaged-component scopes. Use this rather than `deployed-ip-parameter-snapshot.json`, whose flattened parameter names lose nested-component distinctions.
- `memory-preset-saved-ip-comparison.json`: exact source-preset versus saved-IP string comparison.
- `remote-project-and-generation-baseline.json`: project contents, baseline file hashes, and absent directories/artifacts.
- `source-to-work02-project.diff`: source/work QSF and QPF differences.

## Finite findings

PCIe saved core16 configuration has two PFs, PF0 one VF and PF1 zero VFs. PF1 BAR0 is disabled; BAR2 is 64-bit prefetchable memory width 28; BAR4 is 64-bit prefetchable memory width 14. Data width is 64 bytes with two segments. These are saved parameters, not child callback or interface acceptance.

PCIe `core16_axi_lite_clk_freq_user_hwtcl` is saved as **250**, whereas the setup producer requested 100 using an ignored unprefixed parameter. This is a real source/configuration discrepancy, not a warning waiver. A board-specific correction is under investigation. The actual PLL CSR output still requires generated clock evidence; changing the PCIe request alone does not establish clock compatibility.

Memory packaged `emif_0` retains `MEM_FORMAT_DISCRETE`; `emif_1` retains `MEM_FORMAT_RDIMM`. Each has DDR4 DQ width 64, row width 17, and DDR4 ECC false. Of 2,930 preset parameters, 2,914 match exactly, none are absent, and 16 differ solely as `Rank 0` versus `Rank,0` ODT strings. Those differences require serialization/consumer interpretation; no equivalence is asserted. Saved grouping and model count do not establish physical generated-port grouping.

PLL GUI requested output frequencies remain 470/100/235/630/50/117.5/350 MHz. GUI VCO/divider values also exist but are not treated as validated implemented frequencies. The setup warnings on outputs 1/3/4/6 remain open.

## Setup versus generation baseline

The inspected PCIe, memory-controller, and PLL output directories are absent. The simulation-model directory contains the two saved `.ip` files. The OFS configuration-header directory exists, but `ofs_ip_cfg_db.vh` and `ip_gen_sv_wrapper_inc.tcl` are both **zero bytes**; directory existence is not header-generation success.

The PR macro/IP imports, base SDC, and QDB are absent, consistent with their later producer stages. Do not fabricate these or reuse donor artifacts.

Quartus rewrote both revision QSFs from `SUPERIOR PERFORMANCE` to `HIGH PERFORMANCE EFFORT` and updated `LAST_QUARTUS_VERSION` to 26.1.1. QPF includes both base and PR revisions, with base listed first. These observed setup mutations are preserved in the diff; they do not prove implementation or timing behavior.

## Next acceptance requirements

Use fresh, source-bound work03 for the reviewed wrapper and any reviewed PCIe correction. Preserve work02 authorization/claim and all failed work01 evidence. Require clean monitored setup before project inventory, complete base RTL generation, and header generation. Check actual generated manifests/HDL, nested BMC dependencies, child PCIe settings, memory grouping, PLL clocks/SDC and nonempty meaningful headers before later gates. Do not equate process exit zero with these acceptance checks.

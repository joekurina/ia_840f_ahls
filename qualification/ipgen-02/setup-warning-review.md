# work02 setup warning review and next artifact checks

## Decision

**Accept work02 as a completed setup/deployment experiment, not as completed base IP RTL generation, clock qualification, synthesis, or PR acceptance.** Advance by reading the saved work02 IP contents and the rewritten project settings, then conducting the separately authorized base-IP RTL-generation experiment. Do not rerun setup merely to obtain files that the post-setup snapshot now proves exist. Do not wait for post-synthesis/post-STA PR artifacts before attempting base IP generation.

Evidence reviewed: all 658 lines of `remote-setup-full.log`, `remote-setup-result.json`, and the file inventory/record/process evidence in `remote-post-setup-artifact-snapshot.json`. Source paths below are relative to `ofs-agx7-pcie-attach/` unless prefixed `reference/` (relative to the enclosing `new/` directory). This review used local source/data reads only; no remote connection, vendor execution, source modification, or clock waiver.

- Result JSON records `--stage=setup`, `COPY_WORK=1`, work `/home/uwb_student00/ahls/new_BSP/work_ia840f_ipgen_02`, and return code 0.
- Full-log scan finds 10 warning lines: three missing initial IP files, four PLL frequency differences, one ignored PCIe parameter, and two missing PR Tcl files. No `125091`, `IA840F_GATE_REJECTED`, `IA840F NOT READY`, or `IA840F EXPERIMENTAL GATE:` occurs. Individual Quartus summaries reporting zero warnings do not erase plain-text warnings from scripts or earlier subprocesses.
- Base `ofs_top` preparation ends successfully with zero errors/warnings (log 646–658); PR preparation ends with two warnings (606–626). Neither is compilation.
- Snapshot has 205 file entries. It records nonempty files for all five OFSS deployment outputs, including the three initially missing paths. This establishes post-setup presence/size/hash, **not parsed configuration, child-IP acceptance, or generated HDL correctness**.
- Snapshot claim text equals record SHA256 `30781e47965b9afe69b9686b19c8799ebd329066de46426125270eb18a95a8bb`; the claim file's own hash is a different quantity. Record remains `ready_for_build: false`, with permission only for `setup`. Parent reports no `quartus_sh`, `quartus_ipgenerate`, `qsys-generate`, or Java process in that point-in-time snapshot; this is not proof of a generation run.

## Producer ordering: why these warnings are not interchangeable

`ofs-common/scripts/common/syn/build_fim_setup.sh` first copies the worktree, enters its project directory, sets `BUILD_ROOT_REL`, and copies mutable QSF/QPF files (70–205). It then runs IP enumeration/copying through `emit_project_ip.tcl --mode=ip_lib` (249–262), **before** OFSS deployment (312–320), PIM/AFU preparation (322–329), and PR then base `--prepare` (334–345).

`gen_ofs_settings.py:64–98,128–145` orders IOPLL, PCIe, memory and simulation-memory deployments. The selected `syn/board/ia840f/config/ia840f.ofss:4–8` imports the base, PCIe vendor-source, 470 MHz IOPLL, and two-group memory configurations. `ofs_ip.py:141–172` checks subprocess return status; its preset path uses `AUTOMATIC_VALIDATION false`, applies the preset and calls `save_component` (203–236). `get_qsys_gen_command:252–264` is an example string, not an executed RTL-generation step. The setup log reports PIM template RTL creation, but not completed vendor PCIe/memory/base IP RTL generation.

## Warning disposition

### Initial missing PCIe and memory files — resolved as presence failures

Log 187–189 names:

- `ipss/pcie/qip/pcie_ss.ip`
- `ipss/mem/qip/mem_ss/mem_ss.ip`
- `ipss/mem/qip/ed_sim/ed_sim_mem_group1.ip`

`emit_project_ip.tcl:101–123,140–145` enumerates registered files and prints a warning/returns when a file does not exist. Enumeration saying “found in the project” is registration evidence, not filesystem existence. PCIe registration is `ipss/pcie/pcie_ss_design_files.tcl:12–16`; memory/group registration is `ipss/mem/mem_design_files.tcl:43–64`. The additional group simulation model is not a physical hardware instance; the file is nevertheless registered and must exist for the requested project/simulation flow.

Later OFSS explicitly deploys these paths (log 335,363–369,427–433) and lists all five updates (438–443). Snapshot now closes the specific post-setup missing-file question:

| Work-relative path | Snapshot bytes | SHA256 |
|---|---:|---|
| `ofs-common/src/fpga_family/agilex/sys_pll/sys_pll.ip` | 115202 | `80b62a76642038c38263bffa72e19ec6d2dc575e5ca4a75f51465e7a0f90b176` |
| `ipss/pcie/qip/pcie_ss.ip` | 1369721 | `a41f8a7e4b2c54f4fb6720434994f305b2cc0f2cec4e9d0cec13e38c14e14341` |
| `ipss/mem/qip/mem_ss/mem_ss.ip` | 1253621 | `883ff7f07d572a91e8fa67ccff2f971dd50823779eb33edeeae3fe6e960f5952` |
| `ipss/mem/qip/ed_sim/ed_sim_mem.ip` | 698862 | `c12a49e5752453ad6a89fb4a05f31fa43274b7972262a7f3820562c2b86aba65` |
| `ipss/mem/qip/ed_sim/ed_sim_mem_group1.ip` | 698886 | `8880c23dc3742d2277542b7eba82733411a697f2638ddd5cd3e250d3b0e5780e` |

**Disposition:** not a remaining setup-presence blocker and not a reason to prevent a bounded base RTL-generation experiment. Still require content/interface checks; successful `save_component` with automatic validation disabled is not memory validation.

### PLL requested-versus-actual differences — clock acceptance unresolved

Log 287–290 says the PLL is implementable but actual output frequencies 1, 3, 4, and 6 differ. `iopll_component_parameters.py:4–22` names these `clk_100m` (requested 100 MHz), `clk_630m_noc` (630), `clk_50m` (50), and `clk_350m_noc` (350). `iopll_ip.py:70–93` overrides outputs 0/2/5 with 470/235/117.5 MHz. Log 276 confirms these requests. **The log does not give actual frequencies; absence of a warning on 0/2/5 is not independent verification of their generated values.**

Board `src/board/ia840f/top.sv:509–520` wires those outputs to system, CSR, and NoC clocks; line 300 assigns `clk_csr = clk_100m`. Its output-3 comment says 600 MHz while the selected producer requests 630 MHz: a source-comment discrepancy to reconcile against the real memory/NoC requirements, not authority to change either frequency. The approximate-100-MHz comment at 505 does not establish an allowed tolerance.

**Disposition:** deployment succeeded, so not evidence of a fatal base generation error. Actual frequencies, dividers, generated timing constraints, and consumer requirements must be reconciled before accepting clocks or advancing to an accepted hardware build. No rounding allowance or clock requirement is waived here.

### Ignored `axi_lite_clk_freq_user_hwtcl=100` — real schema/configuration gap

Log 316 explicitly rejects this assignment while PCIe deployment continues (335–337). The source producer is `ofs-common/tools/ofss_config/ip_params/intel_pcie_ss_axi_parameters.py:5`, loaded by `pcie_ip.py:56–64` and copied into deployment parameters at 163–179. The full deployment command has the unprefixed assignment, not a `core16_axi_lite_clk_freq_user_hwtcl` replacement.

Saved installed-source evidence `reference/quartus-26.1.1-pcie/hwtcl/pcie_ss_parameters.tcl:1721` declares `core16_axi_lite_clk_freq_user_hwtcl`, with a schema default of 250 and range 100–250. `pcie_ss_fileset.tcl:223–249` reads it and forwards it as `core16_axi_lite_source_freq_hwtcl`. **That default is a risk, not proof the work02 IP actually saved 250.** Read the actual saved parent and later generated child parameters before concluding.

The board drives PCIe `csr_clk` from PLL output 1 (`top.sv:300,514,590`); `ofs-common/src/fpga_family/agilex/pcie_ss/pcie_ss_dm_top.sv:232` maps `p0_axi_lite_clk` to `csr_clk`. Thus this ignored assignment and the output-1 PLL warning must be resolved together, not independently dismissed as cosmetic.

**Disposition:** does not by itself prove RTL generation cannot run; it does prevent claiming the intended AXI-Lite clock configuration was accepted. A bounded RTL experiment can expose the actual child implementation, but its success alone cannot qualify the clock. If saved content already proves a mismatch, correct the source-bound experiment through the parent's reviewed change/rebinding workflow, not by silently editing work02 or reusing its setup claim.

### Missing PR Tcl imports — later base-build outputs, mandatory for PR

Log 617/619 reports `fim_project_macros.tcl` and `fim_base_ip.tcl` absent during `ofs_pr_afu --prepare`. `syn/board/ia840f/syn_top/ofs_pr_afu.qsf:117,121` imports them. They are **not setup-produced files**:

1. Base `ofs_top.qsf:122` loads `ofs_top_sources.tcl`; that script registers `syn/shared_config/post_module_hook.tcl` at line 20.
2. `post_module_hook.tcl:75–77` sources `ofs_post_module_script_fim.tcl`.
3. `ofs_post_module_script_fim.tcl:59–68` writes `fim_project_macros.tcl` only for `quartus_syn`, using `emit_project_macros.tcl --mode=tcl`.
4. The same script at 103–117 writes `fim_base_ip.tcl` only for `quartus_sta`, using `emit_project_ip.tcl` in its default Tcl mode. That emitter writes the base project's IP/QSYS registrations (45–80).

Setup's `src/top/ofs_agilex.macros` (log 465) is text-mode PIM input, **not** `fim_project_macros.tcl`. The base-IP-generation post-module branch (41–57) produces the `ofs_ip_cfg_db` database, not either missing PR import.

**Disposition:** expected stage-order absence during PR prepopulation; neither file is a prerequisite of the base revision's IP RTL generation. Both remain mandatory PR-acceptance prerequisites. PR also imports `ofs_top.out.sdc` and `ofs_top.qdb` (`ofs_pr_afu.qsf:95,112`), produced at STA and ASM respectively (`ofs_post_module_script_fim.tcl:92–116`). Do not fabricate empty Tcl files, remove PR imports, or call this PR-ready on setup rc0.

### Other messages worth retaining

Log 97–102 and 612–616 describes deprecated `SUPERIOR PERFORMANCE`, QSF rewriting/backups, and defaults migrated from 22.3 to 26.1.1. These are informational messages, not additional warning lines. They require a work-versus-source QSF/defaults diff before later build acceptance. PCIe SR-IOV automatically enabling FLR and the ID notices (323–334) are also informational; verify saved and generated capabilities rather than treating those notices as functional acceptance.

## Exact next remote read-only checks for the parent

Use **existing** `W=/home/uwb_student00/ahls/new_BSP/work_ia840f_ipgen_02` and `Q=$W/syn/board/ia840f/syn_top`. Read/copy files with ordinary filesystem tools or Python; do not source Tcl, open Quartus projects, invoke vendor commands, regenerate components, or mutate WORK in this read-only step.

1. **Capture the five IP files in the table**, byte-for-byte, with resolved path, symlink status, size and SHA256. Compare hashes to the snapshot before parsing; flag changed artifacts instead of attributing later content to this setup. Parse XML locally without importing executable vendor helpers. Record component/version/device and effective parameter values with original names. The inventory already proves presence; content is the missing evidence.
2. **PLL content:** read `$W/ofs-common/src/fpga_family/agilex/sys_pll/sys_pll.ip`. Extract every output's requested and actual-frequency fields, reference clock, clock names and divider/VCO fields wherever stored. If this saved component lacks implemented-frequency data, explicitly record that limitation and carry it to the later generated RTL/SDC check. Do not infer actual frequency from a `gui_output_clock_frequency*` request field.
3. **PCIe content:** read `$W/ipss/pcie/qip/pcie_ss.ip`; extract both the ignored legacy key, if retained, and `core16_axi_lite_clk_freq_user_hwtcl`, plus any derived `core16_axi_lite_source_freq_hwtcl` and AXI-ST clock parameters. Check component `intel_pcie_ss_axi`, part `AGFB027R25A2E2V`, Gen4 x16/single enabled link, PF0 one VF/PF1 zero VFs, IDs/BAR/MSI-X/SR-IOV/FLR configuration against the selected vendor-source configuration and overlay. Report missing fields as unknown, not as defaults successfully applied.
4. **Memory content:** read `$W/ipss/mem/qip/mem_ss/mem_ss.ip` and both `$W/ipss/mem/qip/ed_sim/ed_sim_mem*.ip` files. Extract saved channel/group structure, discrete/RDIMM differences, widths, clock requirements, preset-derived settings, and component/device metadata. Compare to the selected `ia840f_discrete_rdimm_source` and `_group1` preset records. A group1 simulation model alone does not prove physical-channel mapping.
5. **Project mutations and wiring:** capture `$Q/ofs_top.qsf`, `$Q/ofs_pr_afu.qsf`, `$Q/ofs_top.qpf`, their `.qsf.backup` files, `*_assignment_defaults.qdf`, `build_env_db.txt`, and relevant WORK source Tcl/RTL. Diff source and work QSF assignments; confirm default revision `ofs_top`, device, gate hook, two memory groups, IP registration paths, post-module hook, and unchanged real CSR/NoC wiring. Capture `$W/src/top/ofs_agilex.macros` separately; never use it as a substitute PR import.
6. **Record generation baseline without assuming filenames:** recursively inventory existing files under `$W/ipss/pcie/qip/pcie_ss/`, `$W/ipss/mem/qip/mem_ss/mem_ss/`, `$W/ipss/mem/qip/ed_sim/`, `$W/ofs-common/src/fpga_family/agilex/sys_pll/sys_pll/`, and `$Q/ofs_ip_cfg_db/`. Explicitly record absent directories. Identify synthesis HDL/QIP, child IP, simulation collateral and SDC if present, hash them and read their actual manifests. The current snapshot extension filter does not establish presence or absence of generated HDL/SDC/Tcl.
7. **Record PR stage baseline:** filesystem-stat `$Q/fim_project_macros.tcl`, `$Q/fim_base_ip.tcl`, `$Q/ofs_top.out.sdc`, `$Q/ofs_top.qdb`. Their absence now does not block the base IP experiment. After their respective base producer stages eventually run, require nonempty content, provenance tied to this base build, complete macro/IP lists with resolvable paths, and matching SDC/QDB before PR acceptance.

After these reads, proceed to the separately reviewed/authorized **base RTL-generation stage**, not synthesis/fit/flash by implication. Preserve the full command, tool identity, return status, complete log and new artifact hashes. The immediate generation acceptance checks are real generated PCIe/memory/PLL HDL and child parameters/interfaces, complete file manifests, required OFS configuration headers, and clock metadata reconciled against consumers. A saved `.ip`, setup return code, PIM template, or generated-file count is not a replacement for those checks. Clock discrepancies remain open until resolved with actual artifacts and requirements; PR acceptance remains downstream of its real base-build producers.

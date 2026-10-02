# Actual PR/PIM closure review36

**Verdict: captured export closure passes; PF1-specific persona bindings remain conditional.** No missing QIP file edge or new PIM-interface incompatibility was found. A real inherited generated-routing discrepancy needs disposition before freezing PF1-oriented host/persona configuration; it does not block geometry-based fabric preparation or invalidate the base export by itself.

Local reads, in-memory hashing/parsing only. No scripts/tests, native tools, SSH, Git or hardware operations. GPT-6 (`openai-codex`) substitutes for unavailable GLM-5.3. Only this report is written.

## Evidence identity

Paths below are relative to this evidence directory. `B` means release-relative `hw/lib/build`; `J=B/syn/board/ia840f/syn_top`. Captured bytes reside in `completion31-readback/release`, `closure32-readback/release`, and `config33-readback` (the latter has no `release/` prefix).

- Rehashed **374/374** members of `actual-result-freeze34.json`: zero size/hash mismatches. Freeze SHA256: `4819f02a84124a8079b68c8d0bdd9c6b60c8512c24051534bf7da73f8e9e30b5`.
- Verified completion31/closure32/config33 compressed-archive digests, every decoded member against readback bytes, and every captured release member against `completion31-readback/operation/result.json.release_inventory`: **3,454 entries** (3,451 regular, three symlinks).
- Closure32 exactly covers **211 PIM regular files / 1,510,668 bytes** and **94 QIPs / 1,691,550 bytes**, a disjoint 305-member union. All 11 config33 members match inventory. All **276** local retained-PIM files match `tools-pim-bindings02.json`, whose inventory/pin also exactly matches frozen `export-inputs.admitted29.json`: `3c21189e728009d4c492fa2be54c0ab1008b06dc`.
- UUID is `fc603c44-5c8f-5e94-bcbe-a5780030947c`. Native export/CMake returned zero under Quartus **26.1.1 Build 130**; raw outer **1**, `execution_clean=false`, and both DNI postflight changes remain untouched. Static-image/QDB preservation and matching are recorded true. Their independent result disposition is outside this lane; this is not total acceptance.

## Complete QIP file-edge accounting

An inert parser inspected all 94 QIPs, including global and instance assignments. Every **1,519** `*_FILE` assignment uses the exact supported form `[file join $::quartus(qip_path) "literal"]`; resolving relative to its containing QIP reaches **1,448 distinct regular-file inventory records**. No missing target, unsupported expression or external file target; all 11 nested QIP references are captured. No broad string stripping, arbitrary Tcl evaluation or filename-only matching was used.

| Assignment | Occurrences |
|---|---:|
| SYSTEMVERILOG_FILE / VERILOG_FILE / VHDL_FILE | 831 / 258 / 4 |
| SOPCINFO_FILE / MISC_FILE / OCS_IP_FILE | 94 / 178 / 60 |
| SOURCE_FILE / SLD_FILE / QIP_FILE | 37 / 2 / 11 |
| SDC_ENTITY_FILE / TCL_ENTITY_FILE | 21 / 23 |

`SOURCE_FILE` includes **six HEX** references, plus SOPCINFO/DAT/ZIP/TXT/IP-XACT/MIF/OCP; none was silently excluded. The 94 `SLD_INFO` values are QSYS metadata, not filenames. This proves declared-edge membership against frozen inventory, not recursive Tcl/HDL elaboration, encrypted-IP semantics, or local rehashing of every dependent file body.

## Restored boundary and generated configuration

`J/ofs_top.qpf:31` selects only `ofs_pr_afu`; QSF `:112–139` retains root `ofs_top.qdb`, green-region rebinding, macros/base-IP and source-loader chain. All **83** `fim_base_ip.tcl` IP/QSYS references resolve. Generated PIM addenda supplies **162** file assignments and 13 search paths, all inventoried. Release-inventory-hash-matched local common sources confirm `afu_main.tcl:16–69` selects shared main and the PIM connector, then `afu_with_pim/afu.tcl` loads future `hw/afu.qsf`.

That AFU QSF and `platform_afu_top_config.vh` are absent from the base release by design: application setup must supply its JSON/top-class/source selection. The latter is distinct from the already generated `ofs_plat_if_top_config.vh`. Missing `ofs_plat_hssi_wrapper.vh` is guarded by an absent HSSI class; captured macros do not enable HSSI. The two exported `other` extension copies are byte-identical; `OTHER_IMPORT` records an import-origin string, while addenda selects the copied extension.

**Memory:** generated top config `:70–86` → config33 `ofs_fim_mem_if_pkg.sv:36–88,139–145` → `mem_ss_if_info.vh` → `mem_ss_param_pkg.sv` establishes **two banks**, 512-bit data, 34-bit byte/28-bit line addresses, nine-bit read/write IDs and nine-bit PIM burst count. The last two headers were read from `../fim-build-12/header-execution-02/retrieved/work/ipss/mem/qip/mem_ss/sv_wrapper/` only after matching exact release hashes `901fa97b882f41c7aa7ae2278a47134b5972ed04df1023fca0ca3838b40a80d1` and `25908195980bb69b085f2ae004b490a7e6fe38dd04fe6e4779db46b321d65aa7`. The fallback one-bank branch is not selected.

**Clocks/freeze:** retain `MAIN_CLK_MHZ → sys_pll_pkg::clock_name_to_actual_mhz("clk_sys")`, pClk/div2/div4 and user-clock wiring, and independent bank clocks/resets; no guessed MHz. Inventory-matched connector `port_afu_instances.sv:135–157` drives clocks and `plat_ifc.pr_freeze_to_afu_in`; generated `ofs_plat_if.sv:33` declares that scalar. Original-inventory-matched `pr_slot.sv:366` supplies the new producer. This is connectivity, not drain/CDC/hardware qualification.

## Preparation obligations and retained limits

**Host/routing discrepancy:** config33 `ofs_ip_cfg_pcie_ss.vh:8–35,131–158` describes P-Tile Gen4×16, one link; the package/header chain yields one 512-bit PIM host port. However, `OFS_FIM_IP_CFG_PCIE_SS_PF0_NUM_VFS=1`. Together with `top_cfg_pkg.sv:50–54,93–117`, the generated table selects **PF0/VF0**, not PF1. Both files hash-match original Work24 inventory: this is inherited, not export corruption. Preserve the intended source-level PF1 architecture; reconcile this actual generated configuration/accepted-shell routing before freezing PF1 host bindings. Do not silently change topology or claim fitted/live routing from this review.

Parent preparation must bind the new UUID/release, CAPS03 origins/corrected HLS, fresh 26.1.1 fabric/QIPs and matching simulation inputs; preserve both DDR banks and clocks. Supply application-generated files, unset `OPAE_PLATFORM_GEN`/`BBS_LIB_PATH`, and prepare fresh copied-scope gate/authority bindings through separate review—not bypass the retained gate, whose absolute paths/ended owner cannot authorize persona compilation. Retain malformed ASP-preset and proxy/leaf outstanding-16-versus-1 findings without default changes. Empty-template success proves neither a memory persona (Work24 AFU remains scalar/no-DDR), timing, nor hardware behavior; actual persona execution is not required to accept this bounded export closure.

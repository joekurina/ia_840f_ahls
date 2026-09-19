# Work12 actual header result — independent review 02

## Disposition: PASS, narrowly for compile preparation

The actual regenerated memory wrapper, interface information, package and selected FIM/PIM consumers support **preparing a fresh compile binding from the actual postheader inventory**. Neither the malformed ASP preset nor the sparse local-memory header is an active FIM compile-input defect for this selected configuration. This is not compile authorization, compile acceptance, timing closure, constraint-completeness, calibration-association or functional qualification.

Do not rerun the consumed header authorization. Do not issue the old preheader compile fixture. Preserve all existing evidence and readiness/authorization flags. A separately reviewed, fresh postheader compile binding remains necessary before native execution.

## Evidence integrity and actual execution

Independently recomputed `header-execution-02/REPORT.md` SHA256:
`e297ee4f3525392a3902bc64205b1fb3b58bd701d1edb3766eebe9e5a1b9a9b0`.

Reverified all **37/37 transferred files**, each size and SHA256, and the compressed archive SHA256 `b8b7f687d75860ce8b357e44accc432a46666c59db5aff315b6bf01dbdf23ae6`. Reviewed actual native checkpoint, result, log, output manifest, authorization and postflight receipts, not just the summary. Native return code is 0; final log says “Quartus Prime Shell was successful. 0 errors, 0 warnings”. Final result has no collection errors or gate/diagnostic rejection. The immediate native checkpoint intentionally has `native_exit_accepted=false`; the later mechanical result has it true. Neither is independent functional acceptance.

All eight required outputs were absent in the authorized preheader inventory, have positive sizes and timestamps later than native start, and match the transferred bytes and postheader hashes. The log freshly generates `ipss/mem/qip/mem_ss/sv_wrapper/mem_ss_sv.sv` and `ofs_ip_cfg_local_mem.vh` from the corrected saved IP. Only PCIe and sys-PLL wrappers were skipped as up to date. The include Tcl selects the new memory wrapper directory and places `mem_ss_param_pkg.sv` before `mem_ss_sv.sv`.

Missing consumer sources were read in three finite, read-only batches in fresh owned tmux windows of `ia840f_mailbox_monitored_01` on `uwb_student00@100.101.227.97`. Each producer verified Agilex7Workstation and UID1000. Unique buffers, batch identities, file sets and remotely calculated hashes were checked locally. The supplemental capture has 91 unique artifacts; Work12 regular-file hashes match the captured postheader inventory. The `config_env.tcl` symlink resolves to the separately captured matching WORK target. Four Work11 wrapper files were read only for direct byte comparison. No vendor tools, project interrogation, simulation or hardware operations were run.

## Active consumer chain and ASP applicability

1. The reviewed compile route is `build_top.sh --stage=compile -k -p ia840f <WORK12>` → native entry guard → `build_fim_compile.sh` → its compile guard → selected `quartus_sh --flow compile ofs_top -c ofs_top`. The compile stage does **not** execute `build_fim_setup.sh` or `build_fim_finish.sh`. Its shell explicitly has no OFS pre/post-compile hook execution. The launcher clears seed/variant overrides; no setup replay is implied by this review.
2. WORK QSF loads `../setup/build_gate.tcl`, compile flags, `config_env.tcl`, then `ofs_top_sources.tcl`. The latter loads `ofs_ip_cfg_db.tcl` first and gives the aggregate-header directory a search path. The database loader sources the generated `ip_gen_sv_wrapper_inc.tcl`.
3. `ipss/mem/mem_design_files.tcl` registers the selected `mem_ss.ip` and `local_mem mem_ss_get_cfg.tcl`. The actual native log confirms this selection. QSF has INCLUDE_DDR4; memory setup emits INCLUDE_LOCAL_MEM. INCLUDE_HPS is commented out. This is the FIM/PIM path, not a oneAPI ASP instantiation.
4. `ofs_top_sources.tcl` selects `syn/shared_config/post_module_hook.tcl`; its final source edge invokes `ofs_post_module_script_fim.tcl`. After ipgenerate, that hook calls the configuration exporter. After synthesis it emits project macros; after fit it updates FME/MIF and **writes another** ASP resource preset; after assembly it exports the partition; after STA it emits PR SDC/IP lists. None reads or parses the local-memory ASP preset.
5. The separate finish/release script `generate_pr_release.sh:261–262` glob-copies `ofs_ip_cfg_db/*.qprs` as collateral. Copying is not XML parsing and this release stage is not the selected compile stage. No active selected setup/compile/post-module consumer found in this bounded chain parses `ofs_ip_cfg_local_mem_asp.qprs`.
6. PIM setup is driven by INI plus emitted project macros: `build_fim_setup.sh` → `ofs_pim_and_afu_config.sh` → `ofs_pim_setup.sh` / `afu_synth_setup`. It does not consume ASP XML. In the existing WORK, `afu_main.tcl` loads the present `afu_with_pim/pim.tcl` → `platform_if_addenda.qsf` → PIM packages and gasket. No `afu_with_pim/afu.tcl` occurs in the postheader inventory, so the default standard-exerciser AFU branch is selected; loading the PIM does not itself imply a PIM-wrapped AHLS AFU has been instantiated.

**ASP finding retained, not repaired:** ElementTree reproduces `mismatched tag: line 22, column 2`. The exporter opens `<presets>` but emits `</preset>` twice. This is a real exporter defect in unconsumed ASP collateral, not a reason to invent FIM macros or reject the active FIM header set. The collateral must not be called valid or accepted for a future ASP workflow. If ASP consumption is later requested, the minimal correction scope is the exporter-source outer closing tag, followed by separately reviewed regeneration; do not patch generated XML. No such correction was performed or is required for this compile-preparation disposition.

## Sparse header and generated macro consumers

The sparse header is consistent with the selected exporter source, not evidence of a failed channel export. `mem_ss_get_cfg.tcl` validates channels and widths, emits the ENTITY, and emits optional HPS/CSR state only when applicable. It does not emit the old general geometry macros into this `.vh`; its width/count information is provided by the separate generic SystemVerilog wrapper exporter. Here CSR is DISABLED and no HPS channel exists.

The actual aggregate header includes `mem_ss_if_info.vh`, `mem_ss_ip_params.vh`, and `ofs_ip_cfg_local_mem.vh`. In `ofs_fim_mem_if_pkg.sv`, `MEM_SS_PORT_I_AXI_MM_IS_VEC` selects the Agilex 7 `GEN_AXI_MEM_PARAMS(MEM_SS, I_AXI_MM)` branch. Channel counts derive from `mem_ss_param_pkg::NUM_PORTS`, not missing `OFS_FIM_IP_CFG_LOCAL_MEM_NUM_*` macros. AXI widths derive from `IFC_MEM_SS_I_AXI_MM_IF_WIDTH_*`; DDR4 group count derives from `MEM_SS_PORT_MEM_DDR4_IS_VEC`. The fallback/no-memory branch is not selected.

`mem_ss_top.sv` checks the local-memory include guard, which is present. It consumes generated interface-presence macros for DDR4/CSR and the optional HPS macro only conditionally. It instantiates the actual `mem_ss_sv`, maps both AXI channels, reference clocks/RZQ, status and reset handshake, and ties AXI QoS to zero. The actual top and `local_mem_wrapper` use the same package counts and generated DDR4 interfaces.

PIM's generated `ofs_plat_if_top_config.vh` binds local-memory banks, address/data widths and IDs to `ofs_fim_mem_if_pkg`; `local_mem_cfg_pkg.sv` then derives line/byte address parameters. `map_fim_emif_axi_mm_to_local_mem.sv` maps the FIM interface. No dependence on malformed ASP XML or missing old geometry definitions appears in this chain. PIM user metadata is not synonymous with the memory IP's 14-bit address-user field: its configured base user width derives from WUSER with PIM extension flags. This unchanged mapping is not newly functionally qualified here.

## Wrapper/interface and saved-IP checks

The four actual wrapper artifacts are **byte-identical in full to Work11's corresponding wrapper artifacts**, including all interface definitions, modports, parameters, package and wiring; not merely matching selected dimensions. Separately parsed the corrected generated `mem_ss/synth/mem_ss.v` port declarations and the actual wrapper's named instance connections: **128/128 ports covered, no missing or extra names, all connection widths match**.

Verified NUM_PORTS=2; AXI read/write data512, address34, ID9, address-user14, strobe64; DDR4 A17/DQ64/DQS8/BA2/BG2/CS1 per channel. Both clock/reset/status groups and all four subsystem reset-handshake signals are wired. Saved `mem_ss.ip` SHA256 remains `58b2409deb345a56a34b557d735d532d9b61b93b4a58c9dce2c5ab26f02e45c4`; it is unchanged in the complete before/after inventory. XML inspection retains both NUM_BANK_FIFOS=0 and both NUM_COPIES=1. Those internal FIFO changes correctly do not change the wrapper interface. No simulation, elaboration or reset/calibration proof is inferred from this static match.

## Complete change accounting and review bindings

Recomputed the union/difference of the complete authorized preheader and actual postheader WORK inventories: exactly **14 paths**, equal to the postflight receipt, with every after-hash matching the actual transferred changed artifact. They are the eight required outputs, memory wrapper log, configuration README, PCIe configuration header, WORK QSF, QSF backup and QDB db_info. Saved IP and all other WORK entries remain unchanged.

SOURCE integration receipt contains exactly the experimental gate, compile gate and header gate changes. Existing-gate backup bytes are preserved; the header gate was previously absent. Receipt post-integration SOURCE inventory equals issued authorization SOURCE inventory; authorization and consumed-review hashes match. Postflight reports full SOURCE/PIM/dependencies/tools preserved; this review does not claim a fresh exhaustive remote scan of those unrelated trees.

Consumed specification and quality mappings each exactly match the successor's 76 payload entries; the overlaid package has 77 entries including manifest. Only runner, draft and manifest changed in that overlay. Exact bindings:

- Specification: `92456ef5bd6814c9d5001a951a40c1fa51ca24afd4c8c35eec4b2842cf35c0a0`
- Quality: `dcc90dc88752de6fd56b5dceb0d0012a06c8b570cce810c018a50bb5b5c05058`
- Successor manifest: `ed1422e5dfc4acfddace312cfe5ab35c5575ab3dc43fcf6730a4df50d1a7c6e9`
- Header authorization: `c4da8cf0ba16e8a201574b68fce9c1e54658dbeda2511bf71827e351c6f8cc30`
- Actual postheader inventory: `da828e3203f2019951fa370f103d6c22d6e3c20906949c16e1fd46ac79d1d4c3`

SOURCE QSF remains `ad68b5bf4666731449b2ae326a0f307065d112fb6bb0a9a0a072a0cd6cb1516c`. WORK QSF is `d72f033986ea4a020a9d60b3c11af074dd9de3cff23534b4052750291e67fb41`. Reviewed native diff migrates deprecated maximum-placement optimization to HIGH PERFORMANCE EFFORT plus GLOBAL_PLACEMENT_EFFORT MAXIMUM EFFORT and updates LAST_QUARTUS_VERSION. Seed2 and hold-closure ON remain unchanged. This native migration is not an operator timing-setting overlay.

## Deliverables and boundaries

Machine-readable evidence: `header-result-review-02.evidence.json`, SHA256 `44e3399128d6bb9e49fdaa6b76e5e9c568a28b8cc9f37dcaa2bb256b92ed4857`. It contains exact artifact hashes, full supplemental consumer source, finite remote command/batch records, original transfer mapping, output freshness records, complete WORK delta and port-coverage checks.

Only this report and its evidence JSON were created locally. No SOURCE/WORK/generated artifact, authorization, gate, claim or existing evidence was modified. No vendor execution, Query04/equivalent, DDR simulation, installs, permissions changes, hardware programming or commits. Existing flags remain untouched: compile authorization/readiness/functional acceptance are not granted. Timing, calibration association and constraint completeness remain unqualified; they need not be solved to prepare the unchanged-constraints experiment. Prepare from the actual postheader inventory, preserve the malformed but unconsumed collateral, and independently review fresh compile bindings before any launch.

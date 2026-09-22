# Shortest native full-FIM successor after the clock trial

**Recommendation: reuse Work14's recorded generated inputs in one fresh WORK, promote only the reviewed PCIe SDC correction, and mechanically retarget the existing Work14 compile package. Run the existing `--stage=compile` flow once. Do not repeat setup, standalone IP/header qualification, the EMIF research, or a seed sweep.**

This is a prospective reuse report, not source promotion, authorization or execution. The saved guard02 acceptance covers an experimental component, not a successful native correction or a full-flow SDC. The parent must first accept the actual clock-trial result and the exact source correction it supports. No candidate hash or successful trial is assumed here.

## Paths and reusable package

- Local repository `N = /home/joe/Projects/Thesis/AHLS/new_bsp/new`.
- Remote parent `R = /home/uwb_student00/ahls/new_BSP`.
- Maintained SOURCE `C = R/ofs-agx7-pcie-attach`.
- Preserved donor `W14 = R/work_ia840f_fim_14`.
- PIM `R/ofs-platform-afu-bbb`, retaining the Work14 record's complete pinned inventory.
- `Q = N/qualification/fim-build-14`.
- **Use the captured native package** `P = Q/compile-readback03/compile-candidate-01`, not an older local gate copy. `Q/local-gate-sync-inspection01.json` records historical local/remote gate divergence.
- Successor `W` and evidence root `E` must be new, parent-selected, confirmed-absent paths under `R`; no successor name is reserved by this report.

### Exact files needed

| Purpose | Existing file(s) / destination |
|---|---|
| Copy preparation recipe | `Q/prepare_work02.py` — reuse its input-inventory-only copy, symlink/text-root relocation and preservation logic; replace its Work13/Work14 roots, UART payload and historical failed-attempt preconditions. It is **not** runnable unchanged. |
| Source integration / draft recipe | `Q/prepare_compile03.py` — retain check-all-targets-before-writing, backups, complete SOURCE delta, fresh WORK inventory and draft construction; replace UART-specific inputs and predecessor references. |
| Issuer and runner | `P/issue_authorization.py`, `P/launch_native_compile.py`, with fresh roots and corrected lineage. |
| Gates to retarget in **both C and W** | `ofs-common/tools/ofss_config/ia840f_compile_gate.py` and `ofs-common/tools/ofss_config/ia840f_experimental_gate.py`, using `P/gate-copy/` as the donor. |
| Sole intended functional source delta | `C/syn/shared_config/top.sdc` and the identical correction in `W/syn/shared_config/top.sdc`; replace the defective generated-clock block at lines 35–37, retaining the surrounding exception bytes unless a separately reviewed change is justified. |
| Clock-trial evidence input, not automatic production overlay | `N/qualification/pcie-clock-repair-01/experiment04/guard02/{clock-repair.tcl,ACCEPTANCE.md,manifest01.json}` plus the actual accepted trial/result and promoted-SDC review. Use `apply_v2`, not predecessor `apply`, for the experimental helper. Its fitted-object assertions are not automatically qualified for every full-compile SDC-loading stage. |
| Fresh package records | Successor `compile-authorization.draft.json`, `review-package-sha256.json`, `source-inputs/delta-report.json`, `source-inputs/source-after.json`, `source-inputs/integration-receipt.json`, copied-input/relocation/metadata receipts, and exact-package spec/quality reviews plus parent consumption. Reuse the existing formats, not old approvals. |

**Unchanged native machinery to carry in the inventory:**

- `ofs-common/scripts/common/syn/{build_top.sh,build_fim_compile.sh,ofs_post_module_script_fim.tcl,update_fme_ifc_id.py}`;
- `syn/shared_config/post_module_hook.tcl`;
- `syn/board/ia840f/setup/{build_gate.tcl,config_env.tcl}`;
- `syn/board/ia840f/syn_top/{ofs_top.qpf,ofs_top.qsf,ofs_top_sources.tcl,ofs_pr_afu.qsf,ofs_pr_afu_sources.tcl,build_env_db.txt,fme_id.mif}`;
- `quartus_proj_dir` and all recorded generated IP/QIP/RTL/HEX/SDC/configuration-header inputs. The authoritative complete file set is `work_inventory` in `R/qualification/fim-build-14/compile-authorization.json`; the local draft in `P` supplies the captured pre-compile inventory. Do not substitute this short list for that inventory.

The generated vendor constraint `W14/ipss/pcie/qip/pcie_ss/intel_pcie_ss_axi_500/synth/pcie_ss.sdc` is comparison/reuse input, **not** the edit target. Do not rebuild or hand-edit the PCIe IP to repair the maintained integration constraint. If the eventual promoted implementation needs a separate helper file, bind that explicit additional file in the reviewed delta; no such production helper is selected by this report.

## Minimal sequence for the parent

1. **Accept the actual clock result and correction.** Establish the real divider/input/master binding and relevant exception/FIFO consequences. A hierarchy fix can activate existing asynchronous groups and multicycles; dominated multicycles receive no safety credit. A successful old-fit clock trial does not establish new-fit timing.
2. **One ordinary-file preflight and fresh input copy.** In the parent's owned tmux, verify complete current SOURCE/PIM/tool bindings against the Work14 issued record, reconcile any accepted intervening changes explicitly, check ownership/resources and unspent successor paths. Copy only recorded pre-compile input entries from W14. Exclude inherited `db`, `qdb`, `output_files` and `incremental_db`; do not copy the fitted trial tree as the new full-build baseline. Preserve generated inputs and valid mtimes; relocate exact old-root text and absolute symlinks with a receipt. Never rewrite opaque databases or alter W14.
3. **Apply the bounded overlay and retarget.** The functional delta is the accepted clock constraint, with two gate-path retargets recorded separately. Keep the Work14 UART fix and all board/timing settings. Follow `prepare_compile03.py` for target-before hashes, backups and exact whole-SOURCE delta verification. Bind the fresh prepared WORK independently from maintained SOURCE.
4. **Use the existing narrow review/issuance path.** Update issuer lineage from the old UART-specific three-file assertion to the exact reviewed successor delta against Work14. Preserve the finite command grammar and installed tool/dependency hashes. Resolve roots consistently in preparation, dispatcher, compile gate, issuer and runner. Reuse the existing non-consuming preflight and focused missing-record checks; do not grow a new test/gate framework. Exact changed package bytes need fresh spec/quality/parent acceptance, then a fresh one-use record/claim. Every prior attempt remains spent.
5. **Launch once through the retargeted runner**, in a new window of `ia840f_mailbox_monitored_01`. The runner's native entry remains:

   ```text
   cwd: C
   ./ofs-common/scripts/common/syn/build_top.sh --stage=compile -k -p ia840f W
   ```

   `C` and `W` above are path placeholders, not an issued command. The child follows `W/quartus_proj_dir` into `W/syn/board/ia840f/syn_top`, then runs `quartus_sh --flow compile ofs_top -c ofs_top` through the existing gate/monitor. Preserve the runner's Quartus 26.1.1 environment, explicit `quartus/bin` and `quartus/sopc_builder/bin` PATH, PIM binding, and removal of inherited seed/variant/partial-flow options. `--stage=compile` does not run setup or finish; native IP-generation/header callbacks within the full compile still run normally.
6. **Inspect the real result**, not only rc0: synthesis, fit, full STA/unconstrained and clock/FIFO findings, High-rule violations, assembly, emitted image hashes and new FME interface identity. Reuse `Q/collect_reports11.py` and `Q/collect_completion12.py` as collection recipes with fresh roots; no repeat broad source research is needed.

## Pitfalls that can block an otherwise minimal reuse

- **SOURCE versus WORK routing:** top/child shell guards use SOURCE; QSF `../setup/build_gate.tcl` resolves a helper in WORK. `ia840f_experimental_gate.py:291` dispatches `quartus` by exact WORK project cwd. Updating only `ia840f_compile_gate.py` can fall through into the old setup validator. Keep the unrelated setup constants unchanged; retarget the compile branch and both deployed gate copies.
- **Runtime contexts:** Work14's issuer binds 135 finite contexts at the WORK project cwd, including relative/absolute callbacks, `--ipc_flow=17 --ipc_mode` task variants, post-module `--ipc_mode`, MIF update and partition export. Retarget paths, not the grammar; retain native ancestry checks and outer/inner executable distinctions. Do not replace all tools with the experimental gate's smaller `RUNTIME_EXES` map.
- **Native metadata is not arbitrary drift:** Work14 inherited a native-migrated QSF already. Its prepared and final WORK QSF hash is `d72f033986ea4a020a9d60b3c11af074dd9de3cff23534b4052750291e67fb41`; maintained SOURCE QSF is recorded as `ad68b5bf4666731449b2ae326a0f307065d112fb6bb0a9a0a072a0cd6cb1516c`. Do not overwrite either with stale local bytes or force false SOURCE/WORK equality. The WORK has `HIGH PERFORMANCE EFFORT`, `GLOBAL_PLACEMENT_EFFORT "MAXIMUM EFFORT"`, seed 2 and aggressive hold closure ON. All-path hold optimization is already effective.
- **Completed-donor metadata:** compare every recorded input and inspect only finite native changes, following `Q/METADATA-DISPOSITION.md` rather than reusing its Work13 hashes blindly. `Q/completion12/manifest.json` records Work14's completed `build_env_db.txt` SHA256 `795791cddda2b44ba971e0e74ed2a6af81cb4892204fe03d924dffb70de6172a`, `fme_id.mif` `672e04b51bff8dbcf27a6c9995703dbc35bc787ecba6789f14d1871738d0714a`, and `ofs_top.qpf` `cc43f69eb9482389d7794d9a45fd5a51ae804026307518d893be9b5576e35c3f`. Their pre-compile bytes are bound in the draft. These receipts identify expected comparison inputs, not present remote-state verification.
- **FME/persona dependency:** the existing post-fit hook runs `update_fme_ifc_id.py`, rewrites `build_env_db.txt`, `fme-ifc-id.txt` and `fme_id.mif`, then runs `quartus_cdb --update_mif` before assembly. Let the successor regenerate its identity. Work14's recorded ID is `5c04f735-4245-5537-88d6-380f16bcc372`; W13's persona ID is `c281e23b-5a95-5aa9-8678-d2ecf1f80f6c`. Neither establishes successor compatibility. Matching PR release/persona work is a later dependency after the relevant FIM acceptance; the base green-region RBF is not an AHLS persona.

## Existing recorded SHA256 anchors

These are copied from saved manifests/receipts, not newly measured remote hashes.

| Anchor | SHA256 |
|---|---|
| Work14 issued authorization (`Q/status-readback05/launch04/issuance-readback.json`) | `42cb4974f9e6aba80aa25e5df385de1faac09251dd6695123448d0db931127be` |
| Work14 package manifest | `d6323f8f243d1fceefb233680fa851a25676889b761348b0760de23b3602dc8b` |
| `P/issue_authorization.py` | `08199afcf7985e5d4639e52630e952251c9a841b965a78835bb55b0e1f129fbe` |
| `P/launch_native_compile.py` | `e22c0d5cb796df1015e58de6110802e649958333015f10d19b08af267cc18e7c` |
| `P/gate-copy/ia840f_compile_gate.py` | `7c3e938da8507e69564761a29c249018fcd18acf40a3a3999ec28e4f93d00be5` |
| `P/gate-copy/ia840f_experimental_gate.py` | `6d40de976fde2caec77a264e46d29a89ea94aebbe9e542edac55555f69626e94` |
| Original maintained/WORK `syn/shared_config/top.sdc` | `8255b34c200a46178174b9788bdc9231072ae829f57c34703cc63dd28ab66c3d` |
| Generated `pcie_ss.sdc` at the path above | `b5fa069c1876031a8f63c1198f98b99dfabf5e7ad0cb748e5614bc235e04c265` |
| guard02 experimental helper | `4967de098cd857a936ccaeb16b22092259872292488ca44d5bce46b594af8bdc` |

## Acceptance boundary

`Q/RESULT-ACCEPTANCE.md` accepts Work14's native/result evidence, **not timing**: rc0 and assembly coexist with the −0.004 ns EMIF1 hold failure, unconstrained PCIe divider and seven High rules / 34 violation rows. The corrected constraint is a meaningful new fit variable; whether the new placement/routing clears EMIF1 hold must be observed. No hold waiver, repeated existing optimization setting, or promise of closure is justified.

Preserve both 16 GiB DDR channels, PR, PF1 BMC, the Gen4-capable endpoint with expected Gen3 x16 host link, and UART/HPS absence. DDR simulation remains skipped by user; no dummy-CSR exercise. This report performed only finite local source/receipt reads and wrote this file. It did not implement a correction, run tests/vendor tools, contact the workstation, modify git, issue authorization, or access/program/reset/reboot hardware. Future remote operations belong solely to the parent in owned tmux under the unchanged GOAL-PROMPT safety boundary.

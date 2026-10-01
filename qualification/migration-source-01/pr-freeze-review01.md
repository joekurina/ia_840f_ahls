# PR-freeze / PIM seam — independent source review01

**Verdict: retain PIM `3c21189e728009d4c492fa2be54c0ab1008b06dc`.** It already supplies the exact interface field required by the new common connector. This is a **PIM-pin/source-interface verdict only**, not acceptance of migration elaboration, timing, hardware behavior, or active PR.

## Basis and scope

Repository: `/home/joe/Projects/Thesis/AHLS/new_bsp/new`; branch `migration-ofs-2026.1-quartus26.1`; root HEAD observed `1697cc289911a554a939c55f31fc05d3957703a2`. Local source/git-object reads only; only this report was written. No tests, generators, vendor tools, SSH/device contact, network retrieval, or git mutations.

| Identity | Exact commit |
|---|---|
| Target FIM, `ofs-agx7-pcie-attach` (`F`) | `866c25bb166810f65aae4f6b15374d0a89810e69` |
| Target `F/ofs-common` (`C`) | `147cae890b7d1245301cf5cde229f761b287b70d` |
| Recommended `ofs-platform-afu-bbb` (`P`) | `3c21189e728009d4c492fa2be54c0ab1008b06dc` |
| Initial on-disk FIM donor HEAD | `599ac052eafbc9cede22561c099233ae4a54cb7d` |
| Initial on-disk common donor HEAD (`C_old`) | `34a8540697fdf3d66fbcaa263fa037bae17cc32f` |

`git ls-tree F ofs-common` independently returned the exact target common gitlink above. All **C/F reasoning uses `git show <full-target>:<path>`, not moving donor working files**. PIM HEAD equals the recommended pin; its tracked worktree was clean and the three PIM sources hashed below match that pin byte-for-byte.

The existing official-origin receipt `qualification/migration-source-01/basis01/fetch-results.json:108–120` records PIM `refs/heads/master` at the recommended SHA; the queried `ofs-2026.1-1` PIM tag produced no entry. This review did not contact origin. `git show` identifies the pin as **merge PR #27, “adding PR freeze to pr wrapper”**; its first-parent diff adds `logic pr_freeze_to_afu_in` and its optional-use comment to the PIM template. Thus the migration prompt's suggestion that this PIM pin lacks PR-freeze support (`GOAL-PROMPT-MIGRATION.md:28,102–114`) does not justify advancing it. Compatibility was re-derived from the producer/consumer code, not cross-repository ancestry or commit dates.

**Model substitution:** requested preference GLM-5.3/zai was not selectable in this delegation; review inherited parent model `gpt-6-astra-900k` / `openai-codex`. It is not a GLM review.

## Selected source path and signal chain

Paths below are relative to the named repository and exact commit above. Let `G = src/fpga_family/agilex/port_gasket/` within C and `R = plat_if_develop/ofs_plat_if/src/rtl/` within P.

| Edge / selection | Exact source evidence |
|---|---|
| Shared wrapper selection | `C/src/fpga_family/agilex/afu_main.tcl:16–30` always registers `G/afu_main_std_exerciser/fim_compile/afu_main.sv` and the shared-wrapper macros. `:55–69` selects `G/afu_main_pim/port_afu_instances.sv` when `afu_with_pim/afu.tcl` exists; `:34–44` selects its template for platform generation. `:80–86` instead selects the standard exerciser when no PIM AFU is configured. Merely loading PIM does not select a PIM AFU. |
| Controller → slot | `C/G/port_gasket.sv:448–462` connects PR controller `o_pr_freeze` to `pr_freeze` under `INCLUDE_PR`; `:198–234` passes it into `pr_slot`. |
| Slot → shared `afu_main` | `C/G/pr_slot.sv:107–118` forms `pr_freeze_fnmx_out` from the clocked register chain; `:331–366` connects `.pr_freeze_to_afu(pr_freeze_fnmx_out)`. |
| Shared main → PIM connector | `C/G/afu_main_std_exerciser/fim_compile/afu_main.sv:83–85` declares the input; `:310–327` passes it to `port_afu_instances`. |
| Connector → PIM interface → AFU | `C/G/afu_main_pim/port_afu_instances.sv:68` declares the input, `:120` instantiates `plat_ifc`, `:157` assigns `plat_ifc.pr_freeze_to_afu_in = pr_freeze_to_afu`, and `:279–281` passes that interface to `PLATFORM_SHIM_MODULE_NAME`. The body is excluded during template generation (`:112,283`); an AFU supplying its own main interface excludes this connector (`:23–28`). |
| PIM member exists | `P/R/ofs_plat_if.template.sv:29–35` declares the separate soft reset, optional `logic pr_freeze_to_afu_in`, and power state. This is the field added by merge #27. |

**Existing isolation is not the new notification.** `C/G/pr_slot.sv:77–81,129–162,209–256` already gates/configures shell PCIe and local-memory freeze bridges, with separate memory-domain synchronization. The old-to-target diff leaves those bridges and the application reset/clock connections unchanged; the slot change exports an existing freeze signal to the AFU. This adds no AFU drain acknowledgment or proof of transaction quiescence. The standard exerciser accepts but does not consume its new input (`C/G/afu_main_std_exerciser/fim_compile/port_afu_instances.sv:41`, its sole freeze occurrence). No isolation redesign or inactive tie-off is needed or recommended for the reviewed PIM seam.

## Actual AHLS consumers, not just the interface declaration

- **Historical generic binding:** `afu/ahls/ahls_binding_sources.tcl:1–15` registers reusable modules, not an AFU top. `rtl/ahls_board_binding.sv:13,46–51` passes `plat_ifc` to board services and exports MMIO clock/reset. `rtl/ahls_ofs_board_services.sv:31–40,53–68` uses `uClk_usrDiv2.clk/reset_n`, maps host/memory, and ties off unused resources. Neither module reads or forwards PR freeze. An unused optional interface member is **not** a missing named module port, but these generic modules cannot be described as consuming the notification.
- **CAPS03 integration source:** `qualification/caps03-persona01/source-selection01.json:64–71` selects `afu/ahls_memory/pim/ofs_plat_afu_completion.sv`; its recorded source SHA matches the working file. That receipt separately records a staged `COMPLETION_SUPPORTED 0 → 1` delta, so the working source is not asserted byte-identical to the staged persona. The captured `setup01-capture/persona/build/platform/platform_afu_top_config.vh:19–20,37` selects `ofs_plat_afu`, consistent with the PIM connector branch. These historical selection records do not prove a newly generated migration build exists.
- **Connected CAPS03 freeze path:** `afu/ahls_memory/pim/ofs_plat_afu_completion.sv:14–17` drives the existing PIM CDC primitive from `plat_ifc.pr_freeze_to_afu_in`, with source clock `pClk`, destination `core_clk`, and initial value `1'b1`; `:93–97` wires its `core_freeze` output to `.freeze_freeze`. `afu/ahls_memory/core/ia840f_ahls_memory_core_publication.sv:8,242–245` declares and forwards freeze to `ahls_memory_dma_fabric`. `P/R/utils/prims/ofs_plat_prim_clock_crossing_reg.sv:5–8,24–40` implements slow-changing-value synchronization, **not a request/acknowledge or drain protocol**.
- **Preserve application clocks/resets:** CAPS03 `ofs_plat_afu_completion.sv:6–13,95–97` uses bank-0 memory clock and the existing joined reset, independently of freeze. `pim/ia840f_ahls_memory_reset.sv:10–18` joins bank-0, host soft reset, and bank-1 reset with the existing PIM primitive. Do not convert freeze into reset, switch clocks, or alter the application-clock target as part of this source-pin decision.

## Findings and remaining boundaries

1. **No PR-freeze name/type mismatch or unconnected edge was found in the selected target-common → pinned-PIM → CAPS03 source chain.** Retain the PIM SHA explicitly rather than silently reusing it or inventing a matching PIM release tag.
2. **Old donor gap:** `C_old/G/pr_slot.sv:364–366` has no AFU freeze connection; `C_old/G/afu_main_pim/port_afu_instances.sv:62–75,149–158` has neither the input nor assignment. Pairing that old connector with the current PIM template leaves this interface member undriven by the connector. `P/R/ofs_plat_if_tie_off_unused.template.sv:31–57` only ties off resource classes, not this scalar. The CAPS03 consumer's presence alone therefore never proved an old-shell freeze source. Do not infer a hardware value or prior active-PR safety from this source observation.
3. **Source-connected, runtime-unverified:** the new donor closes the source producer gap, but generated migration source selection, elaboration, CDC/STA, freeze assertion/release behavior, in-flight transaction handling, and safe active PR remain unverified here. Rebind the actual generated release/persona sources to this tuple before claiming implementation connectivity; do not reuse old generated connector bytes as evidence for the new chain. This review authorizes no execution and proposes no new protocol.
4. **Scope:** change the intended FIM/common basis only; PIM remains as recommended. Existing examples-afu and HLS-samples pins are outside this change and are not requalified here. No blocker to the **PIM pin** was found; no combined-toolchain, timing, or hardware verdict is issued.

## Byte identities (SHA-256)

Working-source paths are root-relative. `P/R` uses the expansion above and matches the pinned blob. Other C references are immutable git objects rather than claims about working-donor bytes.

| Working source / evidence | SHA-256 |
|---|---|
| `afu/ahls/ahls_binding_sources.tcl` | `d85a2a6fbcdc27815de6d3b9b7cb9aa7da6c11ff8225797f22b622afa5f14ec3` |
| `afu/ahls/rtl/ahls_board_binding.sv` | `dfdc163d67cb26a0f6757a699eedd5655584df09b9f29fbe0e31a083c1384d93` |
| `afu/ahls/rtl/ahls_ofs_board_services.sv` | `823aa941b8f7dc2addba78d0f9748cf3d22b2429e2e2835d6567099f235294a9` |
| `afu/ahls_memory/pim/ofs_plat_afu_completion.sv` | `20b34e61d4bd6d88e75085203e700492a502801f27a53687028927df8a054134` |
| `afu/ahls_memory/pim/ia840f_ahls_memory_reset.sv` | `a1593e6a642bd4d6595859ced76749658589b2154a5fcd835826e59b5ef9b8e6` |
| `afu/ahls_memory/core/ia840f_ahls_memory_core_publication.sv` | `429903d0d88e2b8d1f29f0aa4c70ca4d080124e45299ce8c14f4578ca1144949` |
| `P/R/ofs_plat_if.template.sv` | `64ba5e88a622df9321d650504df804de67fea15b3ced77cada38bab418f1707c` |
| `P/R/ofs_plat_if_tie_off_unused.template.sv` | `9734e6862cea4d3395e422ef85081e9e67b1432ee2f355b3bc8000d9413d5886` |
| `P/R/utils/prims/ofs_plat_prim_clock_crossing_reg.sv` | `a65022ab1b5493d178c969e44a04d55c72dcabe62cd897a605ed85673355c024` |
| `qualification/caps03-persona01/source-selection01.json` | `208c966d8fb42376e95e97088bd67f77311ecb2ea6cb16c1b1b89edeed0bd201` |
| `qualification/caps03-persona01/setup01-capture/persona/build/platform/platform_afu_top_config.vh` | `abe5da1132568f464bc72e5991f76ac6668c9761562cda4b822f47e0938dae97` |
| `qualification/migration-source-01/basis01/fetch-results.json` | `cb41430d198c526a539629bf24c22662eaa6df1beccebda26f797623ca5c7588` |
| `GOAL-PROMPT-MIGRATION.md` (reviewed snapshot) | `cad9e913b7ec8bf06f0a1bf247facd77b3ad5e8e30df6cb0e91d9dd3ae5ba226` |

Pinned C seam blob SHA-256: `pr_slot.sv` = `91f3645129c9865a9f3750f60e43a3e56f61879d42dd098dd751fee69d4ceebc`; `afu_main_std_exerciser/fim_compile/afu_main.sv` = `530481dc6604fb5cbc1df983dd5f91ae37b02c2f981e7b35e25f24cd117069d5`; `afu_main_pim/port_afu_instances.sv` = `afa164f17b5b89cab5020d1dc5add8df4c9d51ae56ec62877712f19eb51059e1` (all beneath G); `src/fpga_family/agilex/afu_main.tcl` = `800b6fc92915cd4e66aba8cc051997ceea8fe155a2b2ae20dec85a2db21c2f47`.

Method: read-only `git --no-optional-locks -C <repo> show <commit>:<path>`, `ls-tree`, merge metadata/first-parent diff, and old-to-target path diffs; hashes computed with Python `hashlib.sha256` over actual file/blob bytes. No source file or pin was edited by this reviewer.

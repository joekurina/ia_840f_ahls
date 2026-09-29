# IA-840F static FIM and PIM platform workflow

This is the FIM/PIM portion of release `ia840f-caps03-v1.1.0`. Continue with the [CAPS03 AFU build](ia840f-build.md), [SDK deployment](ia840f-sdk-flashing.md) and [OPAE host execution](ia840f-run.md) guides. The [AHLS GettingStarted programs](../examples/ahls/README.md) are a separate standalone compiler/simulator workflow.

## 1. Understand the components

| Component | Role | Build/deployment product |
|---|---|---|
| Static FIM | PCIe, DFL/FME, board clocks/reset, memory controllers and the PR-region boundary | Static implementation database and base image |
| PIM | Generates the AFU-facing host/MMIO/local-memory interfaces and platform build infrastructure | Generated HDL/packages and platform metadata; not a separately runnable program |
| CAPS03 AFU/persona | Adapted AHLS DDRIP computation, DMA/fabric integration and completion controls | Persona implementation assembled with the preserved matching static image |
| OPAE host | Configures the selected application backend, transfers data, starts the AFU and verifies copyback | CPU executable plus dynamically loaded entry module |

The hardware path is **AHLS → OFS/PIM → OPAE/DFL**, not the old oneAPI BSP/MMD runtime. PF0/FME remains on DFL; the accepted application reaches PF0 VF0 through the explicit VFIO backend. Management PF1 is separate ([host access map](../qualification/ahls-host-offline-01/HOST-ACCESS-MAP.md), [runtime acceptance](../qualification/caps03-runtime01/ACCEPTANCE26.md)).

## 2. What the checkout can reproduce

**Do not mistake the maintained FIM source for a ready-to-run Work21 workspace.** The tag contains board adaptations, donor sources and accepted reports, but not the complete prepared native build.

| Starting point | Available action | Additional dependency |
|---|---|---|
| Release checkout + installed HLS/Questa/Quartus | Build/run the original GettingStarted programs | Follow their environment/overlay instructions; no static FIM required |
| Release checkout + installed HLS | Generate the adapted DDRIP report/RTL project | This alone is not the accepted integrated fabric bundle |
| Retained matching Work21 PR platform + bound integrated AFU sources | Prepare and build the CAPS03 persona with the tracked CMake stages | Fresh stage workspaces and the exact dependency/constraint/callback closure |
| Retained matching CAPS03 image and private OPAE runtime | Prepare a fresh authorized numerical application run | Current image/boot/VF/ownership/reset admission |
| Release checkout alone | Inspect sources, manifests and native evidence | **Cannot reconstruct the complete static FIM or hardware runtime automatically** |

There is no repository-root CMake project and no CMake project in the FIM or PIM trees. The committed native CMake interfaces cover AHLS report generation, persona stages and host builds. The locally retained `afu/ahls_memory/persona/CMakeLists.txt` is not tracked; use the snapshot paths in the AFU guide. Do not invent `cmake --build ... --target fim` or treat a historical wrapper as a portable replacement.

## 3. Select the baseline and board configuration

| Item | Accepted selection |
|---|---|
| FPGA | `AGFB027R25A2E2V`, BittWare IA-840F |
| Implementation tool | Quartus Prime Pro 25.1.0 Build 129 SC Pro |
| FIM donor | `ofs-2025.1-1`, commit `599ac052eafbc9cede22561c099233ae4a54cb7d` |
| FIM common donor | `34a8540697fdf3d66fbcaa263fa037bae17cc32f` |
| PIM donor | `3c21189e728009d4c492fa2be54c0ab1008b06dc` |
| Base project / revision | `ofs_top` / `ofs_top` |
| PR revision / partition | `ofs_pr_afu` / `green_region` |
| Matching static FME UUID | `fc4bf1c1-760f-5cd7-8040-b3e86fa0d31e` |
| CAPS03 AFU UUID | `d48dde9f-f551-578d-8bb0-69483ac95ec6` |

The donor pins are independent identities; the working design includes board-specific adaptations. Historical 26.1.1 planning fields in the [source lock](../sources.lock.json) are not the accepted Work21 toolchain. Use the [Work21 result acceptance](../qualification/fim-build-21/RESULT-ACCEPTANCE.md) and [final project metadata](../qualification/fim-build-21/final-capture01/project/build_env_db.txt).

### Selected OFSS chain

`ofs-agx7-pcie-attach/syn/board/ia840f/config/ia840f.ofss` selects:

1. `ia840f_base.ofss` — IA840F/Agilex/base_x16 and exact device.
2. `ia840f_pcie_vendor_source.ofss` — vendor-derived PCIe source and board-specific override hook.
3. `tools/ofss_config/iopll/iopll_470MHz.ofss` — selected board clock configuration.
4. `ia840f_memory.ofss` — the two vendor-derived discrete/RDIMM memory groups.

The endpoint configuration is Gen4 x16, with one PF0 VF and no PF1 VF. That is endpoint capability, not a promise of negotiated Gen4 on this workstation. The selected PCIe hook preserves the management PF1 aperture contract. **Do not replace it with the separate `ia840f_pcie.ofss`**, which still names a pending-migration preset. The default `tools/ofss_config/ia840f.ofss` path does not exist; initial setup must select the board OFSS explicitly ([selected OFSS](../ofs-agx7-pcie-attach/syn/board/ia840f/config/ia840f.ofss), [selected PCIe configuration](../ofs-agx7-pcie-attach/syn/board/ia840f/config/ia840f_pcie_vendor_source.ofss)).

The completed Work21 [QSF](../qualification/fim-build-21/final-capture01/project/ofs_top.qsf) records seed 2, maximum router/placement effort, aggressive hold closure, intermediate snapshots, the exact EMIF1 bit243 retiming restriction, board pin/SDM settings and selected subsystem macros. The maintained candidate [QSF](../ofs-agx7-pcie-attach/syn/board/ia840f/syn_top/ofs_top.qsf) is not byte-identical and retains seed 1. Do not rebuild from the latter and call it the accepted Work21 configuration.

## 4. Tool environment and prerequisites

Set these only in the owned build session, with absolute paths to the separately prepared FIM source and pinned PIM:

```bash
export QUARTUS_ROOTDIR_OVERRIDE=/opt/altera/25.1/quartus
export PATH="/opt/altera/25.1/quartus/bin:/opt/altera/25.1/quartus/sopc_builder/bin:/usr/local/bin:/usr/bin:/bin"
export OFS_ROOTDIR="$FIM_SOURCE"
export OFS_PLATFORM_AFU_BBB="$PINNED_PIM"
```

Supply installed licenses/device support separately; never put license contents or access configuration into the repository. Native setup/export uses the actual OPAE `PACSign`, `packager`, `afu_json_mgr` and platform tools, with their Python packages/schemas—not copied console-entrypoint files alone. The vendor [OPAE setup script](../ofs-agx7-pcie-attach/ofs-common/scripts/common/syn/setup_opae_sdk.sh) may enter dependency bootstrap if tools are absent. Satisfy the pinned prerequisites first; do not allow a missing dependency to become an uncontrolled download from a moving branch.

Use owned `tmux` for workstation operations, fresh absolute work directories, full available CPU affinity and the current 64 GiB per-process address-space policy for new authorized runs. Record the native/effective/outer result separately. Those current settings do not authorize editing or replaying a finished historical run ([operating rules](../GOAL-PROMPT.md)).

## 5. Static FIM preparation and compile: exact historical route

This section explains the source-verified pipeline and its missing preparation boundary. **The text commands are historical interfaces, not a clean-clone execution recipe or permission to rerun Work21.**

### Initial source setup interface

From the prepared FIM source cwd, the earlier setup route selected the board configuration explicitly:

```text
COPY_WORK=1 OFS_ROOTDIR="$FIM_SOURCE" OFS_PLATFORM_AFU_BBB="$PINNED_PIM" \
./ofs-common/scripts/common/syn/build_top.sh --stage=setup -p \
  --ofss "nodefault,$FIM_SOURCE/syn/board/ia840f/config/ia840f.ofss" \
  ia840f "$FRESH_WORK"
```

Setup creates the project, deploys/enumerates IP, emits PIM scaffolding and prepares base/PR revisions. It is not complete vendor-IP RTL generation, fitting or image acceptance. The earlier setup evidence does not qualify clean-source regeneration under 25.1 ([setup review](../qualification/ipgen-02/setup-warning-review.md), [setup implementation](../ofs-agx7-pcie-attach/ofs-common/scripts/common/syn/build_fim_setup.sh)).

### How Work21 was actually prepared

Work21 copied the recorded Work18 precompile input set, retained Work20's two Python child-environment corrections, preserved the QSF/SDC, and replaced only the generated `scjio_agilex` subtree with captured native-25.1 output. Its source-bound command/context package was retargeted for the fresh attempt. It did **not** regenerate the entire design from the maintained source tree ([iteration basis](../qualification/fim-build-21/iteration-basis.md), [preparation evidence](../qualification/fim-build-21/native-iteration-check01.json)).

The actual native invocation was:

```text
./ofs-common/scripts/common/syn/build_top.sh --stage=compile -k -p ia840f \
  /home/uwb_student00/ahls/new_BSP/work_ia840f_fim_21
```

The compile stage follows `quartus_proj_dir`, reads `Q_REVISION` and invokes the guarded native flow equivalent to:

```text
quartus_sh --flow compile ofs_top -c ofs_top
```

The post-module chain emits synthesis macros, updates the FME interface identity after fitting, exports the static QDB after assembly, and emits `ofs_top.out.sdc` / `fim_base_ip.tcl` after STA. **`--stage=compile -p` does not execute PR-platform export.** That is a separate operation ([Work21 checkpoint and exact invocation](../qualification/fim-build-21/CURRENT.md), [native compile implementation](../ofs-agx7-pcie-attach/ofs-common/scripts/common/syn/build_fim_compile.sh)).

### Why the historical command cannot simply be replayed

The committed [compile gate](../ofs-agx7-pcie-attach/ofs-common/tools/ofss_config/ia840f_compile_gate.py) still targets Work14; its [shared tool/context gate](../ofs-agx7-pcie-attach/ofs-common/tools/ofss_config/ia840f_experimental_gate.py) retains 26.1.1 bindings. Work21-specific gate/callback copies remain local-only. The preparation also depends on retained earlier worktrees and generated payloads. Its existing authorization is consumed.

A new full-FIM build therefore needs a separately reconstructed, reviewed and freshly bound preparation package. Do not edit the old gate's constants casually, strip callbacks, point a consumed authorization at a new directory, or invent a new shell/Python wrapper to claim the tag is reproducible. Reuse the accepted static platform when the kernel/static design is unchanged.

## 6. Reuse or export the matching PIM/PR platform

### Preferred path: reuse the completed matching platform

The accepted workstation platform is:

```text
/home/uwb_student00/ahls/new_BSP/work_fim21_pr_platform01/release03
```

Verify its static identities against [PR prerequisites](../qualification/fim21-pr-platform01/PREREQUISITES01.md) and [export acceptance](../qualification/fim21-pr-platform01/RESULT-ACCEPTANCE.md). The static QDB SHA256 is `7f8f25463afe3ae95d9660ddf4c5c6755d6704f828fd400de34ae38fa2aa0fc8`; the matching FME UUID is `fc4bf1c1-760f-5cd7-8040-b3e86fa0d31e`. The complete QDB/SOF/MSF/PMSF identity table is in the [AFU build guide](ia840f-build.md#4-supply-the-matching-work21-static-platform).

The platform includes `hw/lib/build`, static collateral, generated platform metadata and PIM outputs. It is not merely the PIM Git source tree, and its successful export did not produce a persona GBS or newly deployable full-device image.

### Export interface, when a new export is actually required

The recorded native interface, on a separately prepared Work21 copy with an absent destination, is:

```text
cd "$PREPARED_WORK21_COPY"
export OFS_ROOTDIR="$PREPARED_WORK21_COPY"
export OFS_PLATFORM_AFU_BBB="$PINNED_PIM"
/bin/bash "$PREPARED_WORK21_COPY/ofs-common/scripts/common/syn/generate_pr_release.sh" \
  -t "$ABSENT_RELEASE_TARGET" ia840f "$PREPARED_WORK21_COPY"
```

This runs Quartus prepare, source-discovery/archive and restore operations. The successful export copy also needed owned TMPDIR/QAR paths, a PR-only QPF revision list, the release callback and its Python archive dependency, and bounded generated-XML source-path relocation. The original Work21 and binary QDB were preserved. Those preparation changes are part of the successful recipe, not optional details ([recorded export template](../qualification/fim21-pr-platform01/run-release03.py.in), [independent export review](../qualification/fim21-pr-platform01/independent-review01.md)).

The export then invokes PIM generation. In source-variable form, the observed command is:

```text
ofs_pim_setup.sh -t "$RELEASE" -n ofs_agilex \
  -i "$BASE/src/top/ofs_agilex.ini" -p ofs_plat_if
```

It uses `gen_ofs_plat_json` and `gen_ofs_plat_if` to produce platform JSON and the `ofs_plat_if` HDL tree. The [INI configuration](../ofs-agx7-pcie-attach/src/top/ofs_agilex.ini) selects native PCIe-TLP host channels and native AXI local memory; widths/counts come from generated FIM packages. Address-width properties can be in line units, so do not reinterpret them as byte-address widths. The export's [native log](../qualification/fim21-pr-platform01/artifacts-export03/run/release.log) records enabled local memory and disabled HSSI.

Export03 completed native/effective/outer 0/0/0 with disclosed findings. Residual historical XML paths prevent a blanket relocation/portability claim. Preserve the platform's matched static database and resolve active dependencies rather than mass-rewriting all metadata. Absence of a `.done` marker was not an export failure ([accepted scope](../qualification/fim21-pr-platform01/RESULT-ACCEPTANCE.md)).

## 7. Hand the platform to the CAPS03 AFU build

Given the matching absolute `RELEASE` path and a fresh `SETUP` tree with the **selected** source/generated bundle:

```bash
export OPAE_PLATFORM_ROOT="$RELEASE"
export OPAE_PLATFORM_FPGA_FAMILY=AGILEX
export QUARTUS_VERSION=25.1
export QUARTUS_VERSION_MAJOR=25
unset OPAE_PLATFORM_GEN BBS_LIB_PATH

afu_synth_setup \
    --lib "$RELEASE/hw/lib" \
    --sources "$SETUP/afu_sources/sources.txt" \
    "$SETUP/persona"
```

Unset `OPAE_PLATFORM_GEN`; a value of `0` still selects the wrong branch. Preserve the CAPS03 UUID, its completion-enabled staged top (`COMPLETION_SUPPORTED(1)`), both generated fabric QIPs and their complete dependency closure. The maintained default top remains disabled and is not a drop-in replacement ([setup evidence](../qualification/ahls-persona-work21-01/SETUP-RESULTS01.md), [selected CAPS03 inputs](../qualification/caps03-persona01/source-selection01.json)).

Then follow the [native CMake stage table](ia840f-build.md#6-run-the-native-cmake-stages-in-order): `synthesis`, `fit`, `timing`, `assembly`, each in its own freshly prepared stage workspace. These targets are independent, not an automatic pipeline. Assembly yields a full-device SOF containing the preserved static shell and selected persona; it is subsequently converted/deployed through the SDK route, not executed as a host program.

## 8. Acceptance and operation

The static FIM's native success is bounded by its [final review](../qualification/fim-build-21/RESULT-ACCEPTANCE.md), not a general signoff pass. Later CAPS03 physical and real-hardware acceptances have their own scope. Keep native Design Closure findings, the exact accepted lifecycle warning, and unqualified PR/cold/stopped-clock recovery visible.

For an existing accepted image, the practical run path is: verify the retained image/runtime → deploy only if needed → establish the current DFL/VFIO application binding → execute the OPAE numerical host under its admitted ownership contract. See [deployment](ia840f-sdk-flashing.md), [host build/run](ia840f-run.md), and [final accepted hardware scope](../qualification/caps03-final01/ACCEPTANCE.md).

No FIM generation, platform export, persona build, programming or hardware test was executed while preparing this documentation release.

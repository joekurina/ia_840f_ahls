# IA-840F CAPS03 AFU build guide

This guide accompanies release `ia840f-caps03-v1.1.0`. It describes the accepted **Work21 static FIM + CAPS03 AHLS memory persona** and the native CMake entrypoints retained in this repository. Begin with the [FIM/PIM platform workflow](ia840f-fim-pim.md) for the static shell and matching interface package. After building or selecting the AFU image, use the [BittWare SDK flashing and activation guide](ia840f-sdk-flashing.md) and the [OPAE host build/run guide](ia840f-run.md).

The original AHLS GettingStarted designs have a separate [complete build/run guide](../examples/ahls/README.md). They use CPU/emulation and RTL simulation; their standalone `fpga` target characterizes IP rather than building this complete FIM/PIM/AFU system. The verified tutorial LSU overlay is not retroactively applied to the accepted CAPS03 image or its source-bound generated-IP inputs.

> **A clean clone is not a self-contained full-image build package.** The tag contains source, manifests, accepted evidence and native-stage CMake snapshots. It does not contain the matching generated HLS/fabric bundle, Work21 QDB/image collateral, all stage-preparation payloads, licensed tools or bitstreams. With only the checkout and compiler installation, the AHLS report target below is available; full-persona synthesis onward requires the separately retained, correctly prepared native workspace. Do not bypass missing prerequisites or claim a new build is already qualified.

The release documents existing accepted execution; no new build, FPGA test or hardware operation was performed to publish it. The larger upstream HLS sample qualification remains incomplete and stopped ([scope correction](../qualification/hls-samples-2026.1.0-01/CORRECTION.md), [CAPS03 acceptance](../qualification/caps03-final01/ACCEPTANCE.md)).

## 1. Select the exact baseline

| Item | Selected baseline |
|---|---|
| Card / FPGA | BittWare IA-840F / `AGFB027R25A2E2V` |
| FPGA implementation | Quartus Prime Pro **25.1.0 Build 129 SC Pro** |
| Recorded Quartus root | `/opt/altera/25.1/quartus` |
| HLS compiler | HLS IP Gen **2026.1.0**, build `461da9be608f74678d9c52a2dc1cbb67c58d57fa` |
| CMake | At least 3.16 for the tracked HLS/persona projects; the flashing guide's conversion example requires 3.20 |
| Application clock target | **3.000 ns**, unchanged |
| Runtime | OPAE/DFL with PIM integration, not the historical oneAPI BSP/MMD runtime |

The compiler/device selections are established by the [IP-generation review](../qualification/ahls-memory-ip01/result-independent-review01.md#compiler-target-and-exact-source), [HLS CMake source](../afu/ahls_memory/CMakeLists.txt), [native synthesis receipt](../qualification/caps03-persona01/SYNTHESIS-RECEIPT02.json), and [physical acceptance](../qualification/caps03-persona01/PHYSICAL-ACCEPTANCE01.md). The historical Quartus 26.1.1 planning fields in `sources.lock.json` are not the accepted CAPS03 implementation toolchain.

### Source pins

| Donor | Pin |
|---|---|
| OFS FIM `ofs-agx7-pcie-attach`, tag `ofs-2025.1-1` | `599ac052eafbc9cede22561c099233ae4a54cb7d` |
| OFS FIM common | `34a8540697fdf3d66fbcaa263fa037bae17cc32f` |
| PIM `ofs-platform-afu-bbb` | `3c21189e728009d4c492fa2be54c0ab1008b06dc` |
| `altera-fpga/hls-samples`, tag `2026.1.0` | `0abae6d78af5daca3fe5d67e617ab037e58aff89` |

The pins identify independent donor baselines, not an unmodified upstream combination that reproduces this adapted card project. Preserve the repository's board-specific changes and each donor's separate identity ([source lock](../sources.lock.json), [HLS provenance](../afu/ahls_memory/provenance.json)).

The HLS source is derived from `Tutorials/Features/hls_flow_interfaces/mmhost/part3_ddr_hosts/src/mmhost.cpp`. The C++ adaptation changes both memory-host `awidth<32>` properties to `awidth<34>` and adds provenance comments; signed-int `z[i] = x[i] + y[i]` is unchanged. Later generated-IP/fabric integration and physical implementation are separate from that C++ adaptation ([source review](../qualification/ahls-memory-ip01/result-independent-review01.md#compiler-target-and-exact-source)).

## 2. Environment and workspace

Install the required licensed tools and board/IP support separately. The source checkout does not install Quartus, HLS IP Gen, the BittWare SDK, native OPAE platform tools, drivers or license files. Native persona setup needs the actual OPAE **`platmgr`/`packager`** installation and schemas, not merely copied console entrypoints ([setup evidence](../qualification/ahls-persona-work21-01/SETUP-RESULTS01.md)).

On the recorded workstation, initialize HLS and explicitly select Quartus 25.1:

```bash
source /home/uwb_student00/ahls/altera_hls/aclsycl/fpgavars.sh
export QUARTUS_ROOTDIR_OVERRIDE=/opt/altera/25.1/quartus
export PATH="/opt/altera/25.1/quartus/bin:/opt/altera/25.1/quartus/sopc_builder/bin:$PATH"
```

Supply the valid local licensing environment separately; the recorded native stages set `LM_LICENSE_FILE`, `MGLS_LICENSE_FILE` and `SALT_LICENSE_SERVER`. Do not copy credentials/license-server values into Git. Confirm the actual tool version rather than trusting an inherited environment variable or a historical QPF header ([recorded IP-generation environment](../qualification/ahls-memory-ip01/generate01.py), [persona environment template](../qualification/caps03-persona01/synth01.py.in)).

All remote workstation actions belong inside an owned `tmux` session. Use fresh, absolute, owned work directories and retain command logs, native exit status, source/artifact hashes and unchanged-input checks. Existing accepted run directories and consumed authorization files are evidence, not work directories to overwrite or replay ([repository policy](../README.md#repository-policy)).

## 3. Generate the AHLS report/IP project

From the repository root, set `BUILD` to a fresh absolute build directory:

```bash
cmake -S afu/ahls_memory -B "$BUILD" \
    -DFPGA_DEVICE=AGFB027R25A2E2V
cmake --build "$BUILD" --target report --parallel 1 --verbose
```

The tracked [CMake project](../afu/ahls_memory/CMakeLists.txt) invokes `ahls` with `FPGA_HARDWARE`, `-Xshardware`, the explicit FPGA part and `-fsycl-link=early`. Expected generated material is beneath:

```text
$BUILD/mmhost_ia840f.report.prj/
```

This is report/RTL/interface generation—not a complete board image and not an executable FPGA test. Verify the backend log's exact `AGFB027R25A2E2V` target and emitted interfaces; a successful front-end link alone is insufficient. `.ip` files are not required at this stage; they arise during later Platform Designer import ([IP-generation acceptance](../qualification/ahls-memory-ip01/result-independent-review01.md)).

Do not substitute fresh report output for the accepted integrated HLS/fabric inputs solely because the C++ source matches. The subsequent generated-IP corrections, memory/CSR adaptation, DMA fabric and selected QIP closure must be preserved or reconstructed and reviewed separately. The accepted CAPS03 stage reuses its bound integrated inputs; “unchanged HLS” in its reports is relative to those inputs ([CAPS03 source selection](../qualification/caps03-persona01/source-selection01.json), [selected QSF](../qualification/caps03-persona01/synth01-capture/persona/hw/afu.qsf), [functional integration acceptance](../qualification/caps03-completion01/ACCEPTANCE06.md)).

## 4. Supply the matching Work21 static platform

The persona flow does **not** build the static FIM. The accepted static baseline is Work21; its full-FIM native history is in [Work21 CURRENT](../qualification/fim-build-21/CURRENT.md) and [result acceptance](../qualification/fim-build-21/RESULT-ACCEPTANCE.md). Its historical OFS `build_top.sh --stage=compile` invocation is provenance, not a replacement for the native CMake persona flow or a clean-clone reproduction command.

The matching exported platform was retained on the workstation at:

```text
/home/uwb_student00/ahls/new_BSP/work_fim21_pr_platform01/release03
```

Required static collateral includes:

| Artifact | SHA256 |
|---|---|
| `ofs_top.qdb` (83178648 bytes) | `7f8f25463afe3ae95d9660ddf4c5c6755d6704f828fd400de34ae38fa2aa0fc8` |
| `ofs_top.sof` | `bbede03c8c432e50ae6ae1f30739af3bfd3330781776d2c623269cc131b38ca4` |
| `ofs_top.static.msf` | `da2395b08b6713e6e4335b488f5757e052d583b44b908837e8d18747bb151705` |
| `ofs_top.green_region.pmsf` | `27b3e78810d54cf452dcc1aa834c62584290c9d3358e84f00a374294426a3663` |

The matching static FME interface UUID is `fc4bf1c1-760f-5cd7-8040-b3e86fa0d31e`. Hashes and scope are recorded in [PR-platform prerequisites](../qualification/fim21-pr-platform01/PREREQUISITES01.md), superseded for completed export status by [PR-platform acceptance](../qualification/fim21-pr-platform01/RESULT-ACCEPTANCE.md).

Use the completed matching platform when available. Vendor PR-template export is a separate native operation on a prepared **copy** of Work21, not a harmless file copy; it runs Quartus preparation/archive and PIM generation. Existing export evidence does not make all embedded absolute paths relocatable. Do not rebuild the unchanged FIM, run export against immutable Work21, or substitute an older/static-only platform to compensate for missing files ([completed export](../qualification/fim21-pr-platform01/RESULTS03.md)).

## 5. Prepare the exact CAPS03 persona

Before running the native-stage targets, supply a prepared source tree containing the bound HLS/fabric QIPs, DMA/core/PIM sources, AFU JSON and correct generated constraints. [source-selection01.json](../qualification/caps03-persona01/source-selection01.json) records the selected files, hashes and source list; [the captured QSF](../qualification/caps03-persona01/synth01-capture/persona/hw/afu.qsf) records the actual generated-QIP and absolute-path dependencies.

**The default maintained top is not the accepted selection.** The source `ofs_plat_afu_completion.sv` keeps `COMPLETION_SUPPORTED(0)`; the accepted staged copy explicitly used `COMPLETION_SUPPORTED(1)`, with its own hash. Preserve the original and bind the staged selection. The CAPS03 AFU UUID is `d48dde9f-f551-578d-8bb0-69483ac95ec6` ([maintained top](../afu/ahls_memory/pim/ofs_plat_afu_completion.sv), [selected-copy delta](../qualification/caps03-persona01/source-selection01.json)).

For a separately prepared source selection, the recorded setup interface is:

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

`RELEASE` and `SETUP` must be absolute paths to the matching platform and a fresh staged source root. Unset `OPAE_PLATFORM_GEN`; setting it to `0` is not equivalent. This setup command does not synthesize, fit or assemble the design, and the repository does not supply a complete portable generator for the missing staged source bundle ([native setup interface](../qualification/ahls-persona-work21-01/SETUP-RESULTS01.md), [CAPS03 selected source closure](../qualification/caps03-persona01/source-selection01.json)).

Prepare each native stage from an immutable completed predecessor in a fresh directory. Preserve the accepted static partition, exact selected RTL/QIP closure and 3.000 ns constraints. Retain stage-specific QSF callbacks, fresh source-bound admission and immutable-input checks; do not remove them or replay consumed authorities to make a copied project run ([native-stage CMake](../qualification/caps03-persona01/asm01-capture/cmake-source/CMakeLists.txt), [synthesis preservation](../qualification/caps03-persona01/SYNTHESIS-ACCEPTANCE02.md), [physical preservation](../qualification/caps03-persona01/PHYSICAL-ACCEPTANCE01.md)).

## 6. Run the native CMake stages in order

Set `REPO` to this checkout's absolute path. For each separately prepared stage, set `RUN` to its fresh work root and choose `SRC` and `TARGET` from this table:

| Stage | `SRC` relative to `REPO` | `TARGET` |
|---|---|---|
| Mapped synthesis | `qualification/caps03-persona01/synth01-capture/cmake-source` | `synthesis` |
| Fit completed synthesis | `qualification/caps03-persona01/fit02-capture/cmake-source` | `fit` |
| Final-snapshot multicorner timing/CDC | `qualification/caps03-persona01/sta01-capture/cmake-source` | `timing` |
| Assemble accepted final implementation | `qualification/caps03-persona01/asm01-capture/cmake-source` | `assembly` |

All four directories are tracked. They are independent custom targets—not a dependency-driven pipeline. Running `assembly` does not automatically run synthesis, fit or timing. The required prepared project directory is `$RUN/persona/build/syn/board/ia840f/syn_top`, containing at least `ofs_pr_afu.qsf` and the accepted `ofs_top.qdb` plus the complete stage-specific source/database closure. CMake checks the first two prerequisites but does not create them ([CMake source](../qualification/caps03-persona01/asm01-capture/cmake-source/CMakeLists.txt)).

Preserve the native stage environment:

```bash
export OPAE_PLATFORM_ROOT="$RELEASE"
export BUILD_ROOT_REL=../../../..
export PR_COMPILE=1
unset OPAE_PLATFORM_GEN
```

With `SRC` set to the **absolute** selected CMake source directory:

```bash
cmake -S "$SRC" -B "$RUN/cmake-build" \
    -G "Unix Makefiles" \
    -DCMAKE_MAKE_PROGRAM=/usr/bin/make \
    -DPERSONA_PROJECT="$RUN/persona/build/syn/board/ia840f/syn_top" \
    -DQUARTUS_ROOT=/opt/altera/25.1/quartus

cmake --build "$RUN/cmake-build" --target "$TARGET" --parallel 1
```

These flags match the recorded [synthesis configure/build](../qualification/caps03-persona01/SYNTHESIS-RECEIPT02.json) and [fit/STA verification](../qualification/caps03-persona01/physical-parent-verification01.json). The captured CMake source deliberately rejects a different `QUARTUS_ROOT` string; changing the installation path requires an explicit source change, not an undocumented flag workaround. `--parallel 1` serializes CMake targets, not Quartus's internal workers. The recorded synthesis used all 36 allowed CPUs and a 64 GiB per-process address-space cap; those are historical run settings, not a claim about another machine's resources.

For inspection, the CMake targets invoke these native commands from the prepared project directory; use the CMake interface rather than bypassing it:

```text
quartus_syn --read_settings_files=on --write_settings_files=off ofs_top -c ofs_pr_afu
quartus_fit --read_settings_files=on --write_settings_files=off ofs_top -c ofs_pr_afu
quartus_sta ofs_top -c ofs_pr_afu --snapshot=final --multicorner=on --do_report_timing --do_report_cdc_viewer
quartus_asm --read_settings_files=on ofs_top -c ofs_pr_afu
```

Do not use bare `make`, the full `afu_synth` flow, or a new wrapper to obtain a single already-completed stage. Preserve failed attempts; a corrected fresh stage must have an identified change and matching predecessor rather than silently reusing an interrupted fitter database.

## 7. Accept the output at its actual scope

For each stage retain the native-tool result, CMake result, postflight/preservation result and outer transport result separately. A watcher returning zero is not a native success. Require expected output files, matching part/source/static inputs, and no unexpected residual process or error. The exact existing acceptances are [synthesis](../qualification/caps03-persona01/SYNTHESIS-ACCEPTANCE02.md), [physical timing/CDC](../qualification/caps03-persona01/PHYSICAL-ACCEPTANCE01.md), and [assembly](../qualification/caps03-persona01/ASSEMBLY-ACCEPTANCE01.md).

The accepted assembly produced:

```text
$RUN/persona/build/syn/board/ia840f/syn_top/output_files/ofs_pr_afu.sof
```

Its retained local copy is:

```text
qualification/caps03-persona01/asm01-capture/persona/build/syn/board/ia840f/syn_top/output_files/ofs_pr_afu.sof
```

**Accepted identity:** 10065141 bytes, SHA256 `8f778fca292cc77f87c196deb198d4798a1bd111999d69b0245d570fa2bfe276`. This is the full-device SOF containing the preserved static shell and intended persona. Assembly also emitted the PR PMSF/RBF; it did not by itself produce or qualify a GBS. None of these binaries is stored in Git ([assembly artifact table](../qualification/caps03-persona01/ASSEMBLY-ACCEPTANCE01.md#new-artifacts), [retained artifact](../qualification/caps03-final01/ACCEPTANCE.md#retained-working-artifact)).

A new successful compile is not automatically byte-identical or covered by the old hardware qualification. Native **Design Closure FAIL** remains disclosed for the accepted bounded DRC/unconstrained-port scope; the application target was not slowed to obtain acceptance. Only the specific VF pending-before-FLR lifecycle warning was later accepted. General PR/cold/stopped-clock recovery and all upstream HLS samples remain outside this release's claims ([physical limits](../qualification/caps03-persona01/PHYSICAL-ACCEPTANCE01.md), [final scope and erratum](../qualification/caps03-final01/ACCEPTANCE.md#exact-exception-and-retained-limits)).

After selecting an accepted full-device artifact, proceed to [SDK RPD generation and flashing](ia840f-sdk-flashing.md). Do not feed a SOF, JIC, GBS or PR-RBF directly to the SDK writer.

## 8. Clean-checkout checklist

The tag contains the AHLS CMake project and the four stage CMake snapshots above. There is **no repository-root `CMakeLists.txt`** and no tracked QDB/SOF/MSF/PMSF. The locally present `afu/ahls_memory/persona/CMakeLists.txt` is not part of this release; use the tracked snapshot paths in this guide.

A full-image rebuild additionally requires:

1. The licensed Quartus/HLS tools, native build tools, local licenses and installed OPAE platform dependencies.
2. The exact matching Work21 PR platform and preserved static collateral.
3. The accepted integrated generated HLS/fabric files and all QSF-referenced dependencies, not only raw HLS report output.
4. The exact CAPS03 selected sources, AFU JSON, completion-enabled staged top and stage-specific constraints/callbacks.
5. Freshly prepared, source-bound stage workspaces. The retained `.py.in`/receipt material is evidence, not an automatically executable clean-clone setup system.

If these are unavailable, stop at the missing prerequisite; do not copy a different platform, delete guards or claim clean-clone reproducibility. These exclusions follow the [repository publication policy](../README.md#evidence-and-repository-policy) and [persona evidence policy](../qualification/caps03-persona01/README.md). Building a portable complete preparation package would be separate work, not something this documentation tag silently implements.

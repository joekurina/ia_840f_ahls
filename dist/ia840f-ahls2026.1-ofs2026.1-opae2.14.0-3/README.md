# IA-840F ASP — AHLS 2026.1 / OFS 2026.1

This package uses the maintained OFS `oneapi-asp` implementation, an IA-840F
board port, and the accepted OFS 2026.1-1 static FIM. The old BittWare BSP was
used only to check board facts and package layout; its implementation and
runtime are not dependencies.

## Validated hardware matrix

| Variant | Flow | Operating clock | Vector-add |
|---|---|---:|---|
| `ofs_ia840f` | `afu_flat` | 618 MHz | 10,000 outputs, native exit 0 |
| `ofs_ia840f` | `afu_flat_kclk` | 490 MHz | 10,000 outputs, native exit 0 |
| `ofs_ia840f_usm` | `afu_flat` | 592 MHz | 10,000 shared-USM outputs, native exit 0 |
| `ofs_ia840f_usm` | `afu_flat_kclk` | 479 MHz | 10,000 shared-USM outputs, native exit 0 |

All four executables were linked by the actual AHLS driver with the BSP selected
at hardware link time. Their embedded GBS and resource reports were compared
with the fitted results. The loaded SYCL/OpenCL/FPGA runtime libraries match the
AHLS installation, and the MMD is the tested current-source IA-840F build.
`qualification/FOUR-WAY-HARDWARE679.json` retains the source receipts and hashes.

The final OPAE **2.14.0-3** runtime regression checked 10,000 outputs/native exit 0
on all four rows: 40,000 comparisons. The OPAE source is pinned to
`e4b329185d2c462f5b8c3c74443a5c5cdb25f3b3`, with the supplied configuration-only
module-search relocation patch. Programming functions and FPGA images are
unchanged. Core, plugins, CLI and Python modules are bundled in `opae/`;
MMD/MPF were rebuilt against that release. The prior 18-probe campaign remains
historical engineering evidence, not a claim that those probes were rerun for
this runtime release. The sample display assumes a size of at least three.

## Package layout

- `board_env.xml`, `hardware/`: compiler metadata, both variants, current RTL,
  device models and matching PR collateral.
- `cmake/`, `CMakeLists.txt`: board-local AHLS/CMake backend and explicit
  software-build targets. Clock selection is part of the BSP callback, not an
  application-side manual step.
- `source/`, `software/`: current-source MMD/MPF and board-local overrides.
- `linux64/lib`, `linux64/libexec`: tested runtime and board utilities.
- `bringup/binaries/<variant>__<flow>.fpga`: four distinct SYCL fat binaries.
- `bringup/aocxs/<variant>__<flow>.aocx`: matching extracted compiler containers.
- `bringup/images/<variant>__<flow>.gbs`: matching PR programming images.
- `bringup/binaries/<variant>.fpga` and `bringup/aocxs/<variant>.aocx`:
  default aliases to **plain `afu_flat` only**. The kclk files are never overwritten.
- `board_local/`: reviewed IA-840F overrides applied in the generated project;
  shared donor RTL remains intact, including the unchanged kclk DMA selection.
- `bringup/prebuilt/<variant>__<flow>.fpga.a`: native compiler import archives
  reproducing the verified executables without a new FPGA backend job.
- `examples/vector-add/`: the migrated CMake sample, original source and
  preserved oneAPI 2025 reference recipes.
- `qualification/`, `manifest.json`: exact accepted results and package inventory.

ASE and old/reference recipes are retained as source context, not qualified
execution modes. Use the current AHLS targets rather than the legacy `icpx`
recipes. No system-wide installation or FCD/ICD registration is required.

## Tool and platform inputs

Use AHLS 2026.1.0, Quartus Prime Pro 26.1.1 Build 130, and the accepted OFS
2026.1-1 IA-840F PR export. These external licensed tools are not redistributed.
The target part is `AGFB027R25A2E2V`; the static interface UUID is
`fc603c44-5c8f-5e94-bcbe-a5780030947c`.

On the qualification workstation:

```bash
AHLS=/home/uwb_student00/ahls/altera_hls/aclsycl
QUARTUS=/opt/altera/26.1.1/quartus
PR=/home/uwb_student00/ahls/new_BSP/work_fim24_pr_platform01/release01
BSP=/absolute/path/to/extracted/ia840f
source "$AHLS/fpgavars.sh"
export INTELFPGAOCLSDKROOT="$AHLS"
export QUARTUS_ROOTDIR="$QUARTUS"
export QUARTUS_ROOTDIR_OVERRIDE="$QUARTUS"
export PATH="$QUARTUS/bin:$QUARTUS/sopc_builder/bin:$AHLS/bin:$PATH"
export OPAE_PLATFORM_ROOT="$PR"
export OPAE_PLATFORM_FPGA_FAMILY=AGILEX
export QUARTUS_VERSION=26.1 QUARTUS_VERSION_MAJOR=26
export PR_COMPILE=1 BUILD_ROOT_REL=../../../..
ulimit -v 57671680
```

The resource policy is a 55-GiB **per-process virtual-address-space limit**,
not an aggregate RSS cap. Admit no more than two simultaneous fits and check
live memory headroom before starting another build.

## Compiler-driven application build

The normal pattern is compile, then hardware link to the BSP:

```bash
ahls -DFPGA_HARDWARE -c vector-add-buffers.cpp -o vector-add-buffers.o
ahls -Xshardware -Xstarget="$BSP:ofs_ia840f" -Xsbsp-flow=afu_flat \
  vector-add-buffers.o -o vector-add-buffers.fpga
```

Use the AHLS/Altera header and selector dialect (`sycl/ext/altera/fpga_extensions.hpp`)
when adapting older Intel examples. The packaged CMake project makes this
change in a build-local copy without changing its kernel arithmetic or oracle:

```bash
cmake -S "$BSP/examples/vector-add" -B ./vector-add-build \
  -DAHLS_ROOT="$AHLS" -DQUARTUS_ROOT="$QUARTUS" \
  -DASP_ROOT="$BSP" -DASP_VARIANT=ofs_ia840f -DASP_FLOW=afu_flat \
  -DOPAE_PLATFORM_ROOT="$PR" -DASP_RUNTIME_ROOT="$BSP"
cmake --build ./vector-add-build --target fpga --verbose
```

Change `ASP_VARIANT` and `ASP_FLOW` explicitly for each row. The BSP hook owns
Quartus integration, operating-clock selection, final STA, assembly and image
creation. Do not invoke separate vector-add clock-selection scripts.

The qualification reused each unchanged early-link kernel archive and its
completed integration fit through the BSP callback, avoiding new synthesis and
fitting. An arbitrary new application still needs its own full build and timing
qualification; these vector-add frequencies are not guaranteed for it.

For rebuilding the unchanged example without any FPGA compilation, use the
verified native prebuilt-image archive. The imported archives contain the
original host and symbol/property metadata plus the exact fitted AOCX. Native
AHLS links of all four archives reproduced the hardware-qualified executables
**byte-for-byte**:

```bash
cmake -S "$BSP/examples/vector-add" -B ./vector-add-prebuilt \
  -DAHLS_ROOT="$AHLS" -DQUARTUS_ROOT="$QUARTUS" \
  -DASP_ROOT="$BSP" -DASP_VARIANT=ofs_ia840f -DASP_FLOW=afu_flat \
  -DOPAE_PLATFORM_ROOT="$PR" -DASP_RUNTIME_ROOT="$BSP" \
  -DAHLS_PREBUILT_ARCHIVE="$BSP/bringup/prebuilt/ofs_ia840f__afu_flat.fpga.a"
cmake --build ./vector-add-prebuilt --target fpga --verbose
```

Select the matching variant/flow archive explicitly. This imports the original
program and image; it does not compile changed kernel code. A prebuilt import
is exclusive with the other reuse options. The installed AHLS `-reuse-exe`
checks declined reuse in the retained object/early-archive trials, so that
unqualified route is not the packaged example's recommended reuse mechanism.
The guard prevented fallback fitting in those rejected trials; no tool internals
or metadata hashes were weakened to obtain a pass.

## Private runtime and qualified card operations

`activate.sh` generates FCD/ICD/OPAE selector files **inside this prefix**. It
changes no global registration. These are hardware operations: execute them
only in an owned tmux session, with the exact card identity, matching static FIM,
verified empty ownership and the established VF setup. The qualified workstation
uses FME `0000:4f:00.0` and application VF `0000:4f:00.2`; do not assume these
addresses on another host.

After those prerequisites, the validated pattern is a supported PR load followed
by the matching fat binary under the selected runtime:

```bash
sudo bash --noprofile --norc -c '
  source "$1/activate.sh"
  exec /usr/bin/fpgaconf 0000:4f:00.0 "$1/bringup/images/ofs_ia840f__afu_flat.gbs"
' ia840f "$BSP"
sudo bash --noprofile --norc -c '
  source "$1/fpgavars.sh" >/dev/null
  source "$2/activate.sh"
  exec "$2/bringup/binaries/ofs_ia840f__afu_flat.fpga" 10000
' ia840f "$AHLS" "$BSP"
```

A failure, timeout or uncertain owner is not permission for another PR, reset,
kill or retry. Preserve the original process/resources and reconcile its state.
Do not execute `initialize`, `diagnose`, AER-control or persistent flash merely
to validate the extracted package.

## Retained limitations and recovery

The exact pre-existing warning
`vfio-pci 0000:4f:00.2: timed out waiting for pending transaction; performing function level reset anyway`
remains an accepted scoped erratum. The numerical runs returned zero with empty
ownership, but `lifecycle_clean=false` is retained; no universal clean-drain or
reset guarantee is claimed. Other AER/IOMMU, data or ownership failures are not
covered by this disposition.

The package is x86-64 Linux and requires a compatible host glibc/system runtime.
Relocation tests do not establish compatibility with every Linux distribution.
Fitted clock values are timing/GBS metadata, not live frequency measurements.
No blanket CDC/MTBF claim, new static-FIM image, persistent flash, or rollback
programming is implied. The card is left in the last tested USM/kclk479 persona;
prior accepted images and source receipts remain separate fallback evidence.

## Support manual

The 31-page LaTeX PDF and source bundle are in `docs/support-guide/`.
The guide covers tool setup, FIM/PIM provisioning, native BSP linking,
prebuilt import, VF setup and full-oracle runtime verification.
It documents OPAE2.14.0-3 only.

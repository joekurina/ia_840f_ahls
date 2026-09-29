# IA-840F CAPS03 OPAE host build and run guide

This guide covers the **real-card** application for the accepted Work21/CAPS03 image. It is not the SYCL host embedded in an AHLS report output and not the old oneAPI BSP/MMD runtime. Read the [FIM/PIM workflow](ia840f-fim-pim.md), [AFU build guide](ia840f-build.md) and [SDK deployment guide](ia840f-sdk-flashing.md) first if those artifacts are not already available.

The release documents previously executed commands and their acceptance. It does not authorize a new device operation merely because a command appears below. Run workstation operations inside owned `tmux`, preserve the current image/runtime/ownership bindings, and use a fresh admitted run rather than replaying a spent qualification script.

## 1. Application architecture and prerequisites

The accepted host consists of:

1. `ahls_memory_caps03_startup`: validates and seals the explicit configuration before loading OPAE-linked code. It links the SDK configuration parser, json-c and dynamic-loader support, **not libopae-c**.
2. `libahls_memory_caps03_entry_vfio_strict.so`: initializes the matching private strict VFIO runtime, calls the numerical frontend and finalizes on an eligible normal return.
3. The bound private OPAE runtime: `libopae-c`, `libopae-v`, `libopaevfio`, `libopaemem`, json-c, UUID, libc and loader closure.
4. PF0/FME on `dfl-pci`, with the exact PF0 VF0 application function bound to `vfio-pci` and exposed through its singleton IOMMU group.

A generic `-lopae-c` build is not equivalent. The entry requires the project-specific `ia840f_opae_initialize_vfio_strict` symbol and has no fallback to `fpgaInitialize`. The separate `tests/ia840f/caps03_host` target `caps03_frontend` links an **inert API model**, not a hardware backend ([production recipe](../qualification/caps03-host01/CMakeLists-native01.txt), [strict entry](../src/host/ahls_memory_entry_vfio_strict.c), [inert CMake](../tests/ia840f/caps03_host/CMakeLists.txt)).

### Required build/runtime environment

| Path visible inside the accepted build environment | Required contents |
|---|---|
| `/sdk` | Matching OPAE SDK source/public headers, `libraries/libopae-c` configuration parser sources/headers and `tests/framework/mock/opae_std.c` dependencies |
| `/work/sdk-build/lib/libopae-c.so` | Matching private strict-initialization library build, not arbitrary stock OPAE |
| `/work/prefix/usr` | json-c headers/library and the bound runtime dependencies |
| `/diag/source` | Fresh staged host source/build files listed below |
| `/diag/build` | Fresh output directory |
| `/empty` | Empty read-only working directory |

The recorded build used CMake ≥3.20, C11 and GCC 11.4.0 inside the existing AHLS Ubuntu SIF. The recipe's `/sdk`, `/work/prefix/usr` and `/work/sdk-build/lib/libopae-c.so` values are hardcoded ordinary CMake variables, not documented relocation cache options. Do not invent `-DSDK` or `-DOPAE` overrides. Bind the intended paths, or treat relocation as a separately verified code change ([native build evidence](../qualification/caps03-host01/NATIVE-BUILD01.md), [bound SDK/source inputs](../qualification/caps03-host01/native-build01-inputs.json)).

The SIF, installed Apptainer, prepared SDK/prefix/private libraries, host binaries and kernel/admin tooling are **not included in a clean clone**. The complete runtime closure and historical paths/hashes are recorded in [live21-runtime-binding.json](../qualification/caps03-runtime01/live21-runtime-binding.json). Source headers and strict-initializer additions in Git are not an installed/runtime-qualified SDK.

## 2. Stage the committed host sources

Set `REPO` to this checkout and `HOST_WORK` to a new absolute owned work directory. This step only copies source files; it does not load OPAE or access hardware.

```bash
: "${REPO:?Set REPO to the release checkout}"
: "${HOST_WORK:?Choose a fresh absolute host build directory}"
test ! -e "$HOST_WORK" || { printf 'Choose a fresh HOST_WORK directory.\n' >&2; exit 1; }
mkdir -p "$HOST_WORK"/{source/opae,build,empty,scratch,tmp}

for file in \
    ahls_memory_caps03.c \
    ahls_memory_caps03_startup.c \
    ahls_memory_entry_vfio_strict.c \
    ahls_qualification_core.c ahls_qualification_core.h \
    ia840f_dma_transfer_core.c ia840f_dma_transfer_core.h \
    ia840f_dma_lifetime.c ia840f_dma_lifetime.h \
    ia840f_dma_capabilities.h ia840f_dma_segments.h \
    opae/ia840f_vfio_strict_init.h opae/ia840f_vfio_config.h; do
    cp -p "$REPO/src/host/$file" "$HOST_WORK/source/$file"
done
cp -p "$REPO/qualification/caps03-host01/CMakeLists-native01.txt" \
    "$HOST_WORK/source/CMakeLists.txt"
```

These are the 14 files in the native build's `source_bindings` table. At this release their bytes match that table. Do not replace the recipe with the inert-test CMake or overwrite the original sources ([bindings](../qualification/caps03-host01/native-build01-inputs.json)).

## 3. Configure and build in the prepared compile-only environment

The recorded compile namespace bound the private runtime root at `/work:ro`, SDK source at `/sdk:ro`, this owned host workspace at `/diag:rw` and its empty directory at `/empty:ro`. It used Apptainer `--containall --cleanenv --no-home --no-mount sys,hostfs,cwd,bind-paths --no-eval`, working directory `/empty`, and **no FPGA/VFIO/UIO nodes or live sysfs**. Establish and verify that environment before invoking CMake; do not pass all host devices merely to compile ([actual namespace argv and checks](../qualification/caps03-host01/native-build01-result.json)).

Inside that prepared environment, the exact successful commands were:

```bash
/usr/bin/cmake -S /diag/source -B /diag/build \
    -DCMAKE_BUILD_TYPE=Release \
    -DFETCHCONTENT_FULLY_DISCONNECTED=ON

/usr/bin/cmake --build /diag/build --parallel 36 --verbose
```

`36` is the recorded allowed-CPU count; use the actual allowed count in a newly authorized environment. This CMake project builds only the host object, entry module and startup executable. It does not synthesize the FPGA or execute the application. All recorded translation units use `-O2 -Wall -Wextra -Werror -UNDEBUG`; linking includes `-Wl,-z,defs`. Native configure/build returned 0 ([native result](../qualification/caps03-host01/native-build01-result.json), [compiler/link options in the recipe](../qualification/caps03-host01/CMakeLists-native01.txt)).

Expected outputs are:

```text
/diag/build/ahls_memory_caps03_startup
/diag/build/libahls_memory_caps03_entry_vfio_strict.so
```

The exact named targets are `frontend_object`, `ahls_memory_caps03_entry_vfio_strict`, and `ahls_memory_caps03_startup`. The existing accepted launcher/module can be reused when unchanged; do not rebuild merely to recover context. Historical captures are deliberately mode 0600: never execute or chmod those immutable originals in place. Hardware execution uses a separately owned, hash-bound executable copy. A new build is not automatically identical to, or covered by, the old runtime acceptance ([artifact identities](../qualification/caps03-host01/NATIVE-BUILD01.md#produced-artifacts)).

## 4. Establish the current card and application VF

This is hardware/administrative scope, separate from building the host. **Do not copy the recorded BDF/group numbers onto an unverified boot or machine.** The accepted topology was:

| Function | Historical BDF | IDs / binding |
|---|---|---|
| PF0, static DFL/FME | `0000:4f:00.0` | `8086:bcce`, subsystem `8086:1771`, `dfl-pci` |
| PF0 VF0, application | `0000:4f:00.2` | `8086:bccf`, subsystem `8086:1771`, `vfio-pci`, singleton group 76 |
| PF1, BittWare management | `0000:4f:00.1` | `12ba:0070`, subsystem `12ba:b5d4`; separate management binding |

Source/driver preflight, current boot and image identity, no competing VFIO/programmer/application holders **or memory maps**, and the admitted normal-idle/reset state are prerequisites. A PID-name search alone is not ownership evidence. The static FME UUID `fc4bf1c1-760f-5cd7-8040-b3e86fa0d31e` does not prove AFU UUID `d48dde9f-f551-578d-8bb0-69483ac95ec6`. The application checks its exact BDF/PCI IDs/UUID and BAR0 identity/capabilities; do not substitute PF0 BAR access or scan candidate offsets ([preflight](../qualification/caps03-runtime01/preflight18-result.json), [entry admission](../qualification/caps03-runtime01/entry-admission.json), [frontend source](../src/host/ahls_memory_caps03.c)).

### Source-verified VF setup order

For a separately admitted boot with **zero existing VFs**, the recorded sequence is:

1. Verify the PF0/PF1 identity, intended owner, installed admin-tool semantics and empty ownership. Keep the management daemon inactive for application execution.
2. Set only the bound PF0's `sriov_drivers_autoprobe` to `0` before VF creation.
3. Create one VF using the installed OPAE `pci_device` helper.
4. Verify the resulting VF's IDs, `physfn`, unbound state and singleton IOMMU group.
5. Set only that VF's `driver_override` to `vfio-pci`.
6. Initialize that exact VF and explicitly selected user/group with `opae.io`.
7. Read back the VF driver, node ownership/permissions, singleton group and unchanged PF0/PF1 bindings; restore PF0 autoprobe to `1` and recheck ownership.

The two actual helper commands were:

```text
sudo -n /usr/bin/pci_device 0000:4f:00.0 vf 1
sudo -n /usr/bin/opae.io init -d 0000:4f:00.2 uwb_student00:uwb_student00
```

They are shown with historical identifiers to preserve the actual receipt, not as an auto-detect script. The ordered sysfs writes and exact before/after data are in [create19-result.json](../qualification/caps03-runtime01/create19-result.json) and [bind20-result.json](../qualification/caps03-runtime01/bind20-result.json). If a VF already exists or any prerequisite differs, do not blindly create another, unbind PF0, reset the device, or reuse a prior boot's admission.

## 5. Configuration, runtime namespace and CLI

Use the committed [ia840f_caps01_vfio.cfg](../src/host/config/ia840f_caps01_vfio.cfg). Its `caps01` filename is historical and was intentionally retained for CAPS03. Startup requires an effective table with exactly one `8086:bccf / 8086:1771` row, module basename `libopae-v.so`, empty configuration `{}`, and no extra row. The config's IDs/name are **not BDF confinement**; the separate target filter and namespace matter ([validator](../src/host/opae/ia840f_vfio_config.h)).

The accepted runtime namespace exposed only `/dev/vfio/vfio` and the selected singleton VF group, with read-only sysfs. It bound the private runtime at `/work:ro`, the host build at `/caps03:ro`, fresh diagnostics at `/diag:rw`, and the executable copy at `/exec:ro`. Working directory `/empty` was empty and read-only because inherited library RUNPATHs include empty components. Keep the complete transitive library closure bound, not only the top-level `.so` ([runtime identities](../qualification/caps03-runtime01/live21-runtime-binding.json), [actual mounts/argv/loader observations](../qualification/caps03-runtime01/live21-result.json)).

The launcher accepts **only this fixed argument order**:

```text
ahls_memory_caps03_startup --config FILE --module ABSOLUTE_MODULE \
    --run-qualified-caps03-hls dddd:bb:dd.f
```

There is no `--help`, `--length`, `--bank`, iteration, timeout or reset option. BDF syntax includes the full domain; invalid inputs return 2 before application startup. Config must be a regular non-symlink file of 1–32768 bytes; the module must be an absolute regular-file path. Startup seals the configuration, selects explicit initialization, clears ASE/log overrides and blocks signals before loading the OPAE entry ([startup implementation](../src/host/ahls_memory_caps03_startup.c)).

## 6. Run the accepted bounded numerical workload

**The following is the application fragment inside an already preflighted, ownership-retaining runtime environment. It is not a substitute for that supervisor or a runnable clean-clone container launcher.** Do not run the old `live21.py` capsule or copy its consumed boot/process authority to a new run.

The recorded environment was:

```bash
export PATH=/usr/bin:/bin
export HOME=/diag
export TMPDIR=/diag/tmp
export LANG=C
export LC_ALL=C
export LD_LIBRARY_PATH=/work/sdk-build/lib:/work/prefix/usr/lib/x86_64-linux-gnu
export LD_DEBUG=libs
export LD_DEBUG_OUTPUT=/diag/loader
cd /empty
```

With the historical target binding, the exact application argv was:

```bash
/exec/ahls_memory_caps03_startup \
    --config /work/source/config/ia840f_caps01_vfio.cfg \
    --module /caps03/build/libahls_memory_caps03_entry_vfio_strict.so \
    --run-qualified-caps03-hls 0000:4f:00.2
```

Use a newly verified BDF for a new invocation; the shown value is not a discovery mechanism. The native run receipt binds the command, environment, current image/reset entry, both EMIF-ready observations, exact loaded libraries and empty before/after ownership ([live21 result](../qualification/caps03-runtime01/live21-result.json)).

### Expected computation and evidence

The fixed source vectors are:

```text
X = [-4, 7, -9, 0, 11, -13, 17, -19, 23]
Y = [ 1,-7,  4,-5, -6,  20, -8,   3,-30]
Z = [-3, 0, -5,-5,  5,   7,  9, -16, -7]
```

The host writes inputs to bank0, invokes the HLS computation, reads the result span from bank1, compares all nine signed results and surrounding guards/padding, and checks both host pages. The six DMA descriptors and full 192-byte copyback span are part of the original test; completion status alone is not numerical validation ([frontend, lines 226–299](../src/host/ahls_memory_caps03.c#L226-L299)).

The actual accepted native log includes:

```text
FPGA Test HLS ticket=1 completion=0x10002
FPGA Test HLS DATA PASS: integers=9 result_bytes=36 guard_bytes=156 descriptors=6
FPGA Test CAPS03 frontend PASSED: integers=9 copied_span_bytes=192 descriptors=6 verified_payload_and_guards=1
No simultaneous-bank, sustained or full-DDR qualification. Live VFIO lifecycle acceptance is separate.
```

Require the real comparison path, native exit, cleanup disposition, postflight ownership and kernel interval—not just these strings. The displayed `0x10002` is the local completion observation, **not proof of global PCIe drain** ([native log](../qualification/caps03-runtime01/live21-native.log), [normal-return acceptance](../qualification/caps03-runtime01/ACCEPTANCE26.md)).

## 7. Success, failure and lifecycle handling

The nine-integer run returned **native 0** with empty postflight ownership. Its historical classifier still records raw `success=false`, outer **1** and `lifecycle_clean=false`, because it rejected this exact warning:

```text
vfio-pci 0000:4f:00.2: timed out waiting for pending transaction; performing function level reset anyway
```

Joe's subsequent exception accepts only that pending-before-FLR observation for the qualified scope; the raw record is not rewritten. It is not an FLR-completion timeout, proof of exclusive erratum causation, a warning-free teardown claim, or permission to accept other PCIe/reset errors ([exception](../qualification/caps03-runtime01/ERRATUM-ACCEPTED25.md), [acceptance](../qualification/caps03-runtime01/ACCEPTANCE26.md)).

If `HOLD_UNKNOWN_DMA` appears, the application deliberately retains buffers/file descriptors and stops without further device access or cleanup. This is **not** a safe-to-kill timeout. Do not add generic `timeout`, send SIGCONT, force cleanup, retry, reset or reboot by default; preserve ownership/evidence and use the separately authorized recovery decision. Ordinary success allows normal cleanup only after all required checks. SIGKILL, OOM, fatal faults and host loss are outside the containment guarantee ([lifetime implementation](../src/host/ia840f_dma_lifetime.c)).

Earlier live13 deliberately retained ownership after DATA PASS and has native exit **null**, outer 1. Its later disposition does not turn it into a normal-return success. Use the later live21 acceptance for the bounded normal-idle run.

## 8. Other accepted workloads are separate entry modules

The operation token stays `--run-qualified-caps03-hls`; the selected module determines the workload. These are not hidden CLI size/bank options. Each has a separate native CMake recipe, source selection, runtime binding and acceptance:

| Workload | Native CMake recipe | Entry-module target |
|---|---|---|
| Repeated/boundary HLS | [caps03-coverage01](../qualification/caps03-coverage01/CMakeLists-native01.txt) | `ahls_memory_caps03_coverage_entry_vfio_strict` |
| Serial DDR/isolation | [caps03-ddr01](../qualification/caps03-ddr01/CMakeLists-native01.txt) | `ahls_memory_caps03_ddr_entry_vfio_strict` |
| Walking-bit follow-up | [caps03-walk01](../qualification/caps03-walk01/CMakeLists-native01.txt) | `ahls_memory_caps03_walk_entry_vfio_strict` |
| Bulk HLS | [caps03-bulk01](../qualification/caps03-bulk01/CMakeLists-native01.txt) | `ahls_memory_caps03_bulk_entry_vfio_strict` |
| Both full DDR apertures | [caps03-full-ddr01](../qualification/caps03-full-ddr01/CMakeLists-native01.txt) | `ahls_memory_caps03_full_ddr_entry_vfio_strict` |

CMake produces `lib<TARGET>.so` for these shared targets. Do not swap a module into the nine-integer run without its own source/runtime/ownership admission. The full-DDR run is already spent and is not a default smoke test.

All six normal application lifecycles had native 0 and empty postflight ownership. Coverage's outer status remains unknown/null; the original nine-integer outer status remains 1; the four other listed runs have outer 0. None is relabeled `lifecycle_clean=true`. The [reconciliation](../qualification/caps03-lifecycle01/reconciliation04.json) and [final acceptance](../qualification/caps03-final01/ACCEPTANCE.md) retain the exact distinctions.

## 9. What remains external to this release

The tag supplies the host sources, CMake recipes, configuration and evidence. It does not include the prepared strict OPAE SDK/runtime tree, SIF/Apptainer installation, current device setup, FPGA programming image, kernel modules, or a portable replacement for the source-bound hardware supervisor/preflight. Historical `live*.py`, dispatch/preparation capsules and consumed authority files are not reusable launch commands.

For the original GettingStarted tutorials, use their [standalone guide](../examples/ahls/README.md) instead. Their CPU/emulator and RTL-simulator runs need neither the CAPS03 host module nor an application VF. Publishing this release performed no new native host build, OPAE load, FPGA access, reset, flashing or reboot.

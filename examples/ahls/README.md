# AHLS GettingStarted tutorials on the IA-840F workstation

This directory imports only the three requested [upstream GettingStarted tutorials](https://github.com/altera-fpga/hls-samples/tree/0abae6d78af5daca3fe5d67e617ab037e58aff89/Tutorials/GettingStarted): `fpga_compile`, `fast_recompile`, and `fpga_template`. Upstream `main` matched release **2026.1.0**, commit `0abae6d78af5daca3fe5d67e617ab037e58aff89`, when imported. The original files, images, shared exception header and MIT license are byte-identical; see [UPSTREAM.json](hls-samples/UPSTREAM.json) and [License.txt](hls-samples/License.txt).

The instructions below use the upstream CMake projects directly. No board/BSP substitution, source-size reduction, FPGA flashing or CAPS03 rebuild is involved.

## Programs and verification scope

| Program | Original numerical check |
|---|---|
| `fpga_compile`, `PART=1` | Ordinary CPU C++; compares all 256 integer sums |
| `fpga_compile`, `PART=2` | SYCL functor with USM; compares all 256 integer sums |
| `fpga_compile`, `PART=3` | SYCL lambda with USM; compares all 256 integer sums |
| `fpga_compile`, `PART=4` | SYCL lambda with buffers; compares all 256 integers after copyback |
| `fast_recompile` | 32 float sums; checks squared error against the original `0.001` tolerance squared |
| `fpga_template` | SYCL functor with USM; compares all 256 integer sums |

Sources: [fpga_compile](hls-samples/Tutorials/GettingStarted/fpga_compile/README.md), [fast_recompile](hls-samples/Tutorials/GettingStarted/fast_recompile/src/host.cpp), [fpga_template](hls-samples/Tutorials/GettingStarted/fpga_template/src/fpga_template.cpp). The integer samples use their original input vectors; these checks are not an exhaustive arithmetic or address-pattern test.

Build targets have different meanings:

| Target | Output / execution |
|---|---|
| `fpga_emu` | Runnable CPU/emulator program. For PART1 it is ordinary CPU code despite the target name. |
| `report` | Generated RTL/IP and optimization reports; not a runnable card program. |
| `fpga_sim` | Runnable host plus RTL simulation project; uses Questa, not the physical FPGA. |
| `fpga` | Full isolated-IP Quartus compilation and reports. **Not an IA-840F card executable.** |

PART1 supplies only `fpga_emu`. The remaining five variants supply all four targets. Integration into OFS/PIM with an OPAE host is separate from these original programs; do not run a `.fpga` output as if it were a board application ([upstream flow explanation](hls-samples/Tutorials/GettingStarted/fpga_compile/README.md)).

## Current verification

The original tutorial sources are preserved. The four affected integer RTL simulations now pass with an explicit Agilex 7 family configuration; the earlier six family errors per run are gone. This is a real compiler-input correction, not a diagnostic filter ([correction results](../../qualification/ahls-getting-started-fix01/RESULT.md), [native verification](../../qualification/ahls-getting-started-fix01/verification18.json)).

| Variant | CPU / emulator | Report / RTL | RTL simulation | Reported component Fmax (MHz) |
|---|---|---|---|---:|
| `fpga_compile` PART1 | CPU PASS, retained baseline | N/A | N/A | N/A |
| `fpga_compile` PART2 | PASS, retained baseline | PASS, retained baseline | Corrected build/run PASS; no Error/Fatal | 667.11 |
| `fpga_compile` PART3 | PASS, retained baseline | PASS, retained baseline | Corrected build/run PASS; no Error/Fatal | 781.86 |
| `fpga_compile` PART4 | PASS, retained baseline | PASS, retained baseline | Corrected build/run PASS; no Error/Fatal | 772.20 |
| `fast_recompile` | PASS, retained baseline | PASS, retained baseline | Baseline PASS, including host-only reuse demonstration | 711.24 |
| `fpga_template` | PASS, retained baseline | PASS, retained baseline | Corrected build/run PASS; no Error/Fatal | 667.11 |

Fmax values are the actual entries in the original FPGA Optimization Reports, **not values guessed from slack and not measured/programmed card clock rates**. The corrected template full-IP build was repeated; its entire clock/resource QoR data remains identical at 667.11 MHz. The other original characterization runs were retained rather than repeated unnecessarily ([original report data](../../qualification/ahls-getting-started-fix01/timing-interpretation07.json), [corrected template verification](../../qualification/ahls-getting-started-fix01/verification18.json)).

**Timing-assessment correction:** the HLS handbook explicitly says the standalone flow targets 1000 MHz for placement optimization and is not expected to close that constraint. The previous description of these expected warnings as unresolved application timing failures used the wrong acceptance criterion. Use the reported component Fmax, then verify the actual integrated operating-clock constraints separately. No SDC was relaxed to make the reports green.

## Corrected simulator family configuration

The inspected HLS support RTL leaves `DEVICE` unset at two `lsu_bursting_read` call sites. The child defaults to `Stratix V`, which reaches its SCFIFO model even though our compile targets Agilex 7. The compatibility recipe supplies `.DEVICE("Agilex 7")` at those two instantiations. It does not change algorithms, interfaces, resets, timing constraints, primitive models or the installed SDK ([exact two-line patch and guarded preparation](compatibility/lsu-family/README.md)).

The setup below prepares the correction with CMake and read-only-binds it only inside the private compiler namespace. Use a fresh build directory: the upstream `-reuse-exe` mechanism may retain an older uncorrected device image. The four fresh corrected runs each returned exit 0, passed all 256 original integer checks, and produced no Error/Fatal in the complete transcript ([corrected simulator evidence](../../qualification/ahls-getting-started-fix01/simulator-verification14.json)).

Warnings are retained, including the mixed-version compatibility warning below. The original failures and earlier parser mistakes are preserved as historical evidence, not rewritten ([baseline diagnostic record](../../qualification/ahls-getting-started-01/diagnostic-disposition13.json)). PART1's historical OPAE link diagnostics also remain recorded; its CPU numerical pass is not represented as a diagnostic-free original compilation.

## Installed setup

The current execution uses:

- HLS IP Gen **2026.1.0**, build `461da9be608f74678d9c52a2dc1cbb67c58d57fa`.
- Quartus Prime Pro **25.1.0 Build 129**, `/opt/altera/25.1/quartus`.
- Questa-Altera FPGA Edition **2024.3**, `/opt/altera/25.1/questa_fe/bin`.
- CMake **3.31.8** and the explicit part `AGFB027R25A2E2V`.
- All 36 currently allowed CPUs and a **64 GiB per-process virtual-address limit** for fresh jobs. This is not an aggregate resident-memory limit or a requirement that another host have exactly 36 CPUs.

The compiler emits a warning that HLS IP Gen 2026.1 supports Quartus **26.1**, whereas the selected implementation installation is **25.1**. Keep that warning visible: observed successful modes do not establish vendor validation of this mixed-version setup. Do not silently switch installations to hide it ([tool versions](../../qualification/ahls-getting-started-01/capture06/runs/fast-sim/versions.log), [compiler compatibility warning](../../qualification/ahls-getting-started-01/capture06/runs/fast-sim/build.log)).

Quartus, HLS, Questa/device support and licenses must already be installed. Set the valid local licensing environment before entering the build shell; do not store license contents or server credentials in this repository. `vsim -version` alone does not test license checkout; `vsim -c -do 'quit -f'` does.

## Prepare an isolated CPU/compiler shell

Run workstation operations inside an owned `tmux` session. The commands here assume Bash and an existing repository checkout. Use a fresh `WORK` directory; do not overwrite retained build results.

From the repository root:

```bash
export REPO="$(git rev-parse --show-toplevel)"
export SAMPLES="$REPO/examples/ahls/hls-samples"
export WORK="$REPO/examples/ahls/work/getting-started-fixed"
test ! -e "$WORK" || { printf 'Choose a fresh WORK directory.\n' >&2; exit 1; }
mkdir -p "$WORK"/{home,tmp,runtime,icd,build,logs}
ln -s /opt/altera/25.1/quartus/linux64/libstdc++.so.6 \
    "$WORK/runtime/libstdc++.so.6"
printf 'libintelocl_emu.so\n' > "$WORK/icd/Intel_FPGA_SSG_Emulator.icd"

# File-only preparation outside the compiler namespace; SDK input stays unchanged.
export SDK_LSU=/home/uwb_student00/ahls/altera_hls/aclsycl/ip/lsu_top.sv
cmake -S "$REPO/examples/ahls/compatibility/lsu-family" \
    -B "$WORK/lsu-overlay" \
    -DFPGA_DEVICE=AGFB027R25A2E2V \
    -DAHLS_LSU_TOP="$SDK_LSU"

/usr/bin/bwrap --die-with-parent --unshare-pid \
    --ro-bind / / --bind "$WORK" "$WORK" \
    --ro-bind "$SAMPLES" "$SAMPLES" \
    --ro-bind "$WORK/icd" /etc/OpenCL/vendors \
    --ro-bind "$WORK/lsu-overlay" "$WORK/lsu-overlay" \
    --ro-bind "$WORK/lsu-overlay/lsu_top.sv" "$SDK_LSU" \
    --dev /dev --proc /proc --tmpfs /sys --tmpfs /tmp \
    --chdir "$WORK" --setenv HOME "$WORK/home" \
    --setenv TMPDIR "$WORK/tmp" \
    /bin/bash --noprofile --norc
```

Continue **inside that shell**:

```bash
source /home/uwb_student00/ahls/altera_hls/aclsycl/fpgavars.sh
set -e -o pipefail
export QUARTUS_ROOTDIR_OVERRIDE=/opt/altera/25.1/quartus
export PATH="/opt/altera/25.1/questa_fe/bin:/opt/altera/25.1/quartus/bin:/opt/altera/25.1/quartus/sopc_builder/bin:$PATH"
export LD_LIBRARY_PATH="$WORK/runtime:${LD_LIBRARY_PATH:-}"
export OCL_ICD_FILENAMES=libintelocl_emu.so
ulimit -v 67108864
ulimit -c 0
ahls --version
cmake --version
```

The private `/dev` and empty `/sys` prevent eager FPGA discovery from reaching the real card, even while linking. The process-local `libstdc++.so.6` override supplies the `GLIBCXX_3.4.30` symbol required by this HLS runtime on the recorded Rocky Linux installation. Do not replace system libraries or prepend the whole Quartus `linux64` directory. The checked library SHA256 is `7aff636775fff8c7c851dc7ade8ca807e45431298ea36bbcd776c1643d4e7621` ([preflight](../../qualification/ahls-getting-started-01/preflight01-result.json)).

An empty sysfs can emit the exact warning `hwloc/linux: failed to find sysfs cpu topology directory, aborting linux discovery.` Preserve it. Exclude only that exact warning from a failure-text scan in this verified isolated context; do not ignore numerical failures, SYCL exceptions or simulator Error/Fatal diagnostics.

## Build and run `fpga_compile` PART1–4

Use a distinct build directory for each part. Explicitly providing the common include path avoids reliance on the upstream projects' differing relative include paths without modifying their CMake files.

```bash
for PART in 1 2 3 4; do
    B="$WORK/build/fpga_compile-part$PART"
    cmake -S "$SAMPLES/Tutorials/GettingStarted/fpga_compile" -B "$B" \
        -DPART="$PART" -DFPGA_DEVICE=AGFB027R25A2E2V \
        -DUSER_INCLUDE_PATHS="$SAMPLES/include"
    cmake --build "$B" --target fpga_emu --parallel "$(nproc)" --verbose
    (cd "$B" && ./vector_add.fpga_emu)
done
```

Require each command's successful exit and the original complete numerical check:

```text
add two vectors of size 256
PASSED
```

PART2–4 additionally identify the FPGA emulation device. PART1 is CPU-only. Keep each part's result separately; one `PASSED` does not cover the other parts.

Generate reports for PART2–4 only:

```bash
for PART in 2 3 4; do
    cmake --build "$WORK/build/fpga_compile-part$PART" \
        --target report --parallel "$(nproc)" --verbose
done
```

Outputs include `vector_add.report.prj/`. Check the inner backend log for `-target=AGFB027R25A2E2V`, not only the front-end command or report filename.

## Build and run `fast_recompile` and `fpga_template`

```bash
for SAMPLE in fast_recompile fpga_template; do
    B="$WORK/build/$SAMPLE"
    cmake -S "$SAMPLES/Tutorials/GettingStarted/$SAMPLE" -B "$B" \
        -DFPGA_DEVICE=AGFB027R25A2E2V \
        -DUSER_INCLUDE_PATHS="$SAMPLES/include"
    cmake --build "$B" --target fpga_emu --parallel "$(nproc)" --verbose
    (cd "$B" && "./$SAMPLE.fpga_emu")
    cmake --build "$B" --target report --parallel "$(nproc)" --verbose
done
```

`fast_recompile` requires `PASSED: results are correct` and exit 0 after all 32 float comparisons. `fpga_template` requires the 256-element output and `PASSED`/exit 0. Report generation does not run these programs.

## RTL simulation

Inside the same device-isolated shell, select the simulator runtime and verify the installed license:

```bash
export OCL_ICD_FILENAMES=libintelocl_emu.so:libalteracl.so
export CL_CONTEXT_MPSIM_DEVICE_INTELFPGA=1
vsim -c -do 'quit -f'

for PART in 2 3 4; do
    B="$WORK/build/fpga_compile-part$PART"
    cmake --build "$B" --target fpga_sim --parallel "$(nproc)" --verbose
    (cd "$B" && ./vector_add.fpga_sim)
done

for SAMPLE in fast_recompile fpga_template; do
    B="$WORK/build/$SAMPLE"
    cmake --build "$B" --target fpga_sim --parallel "$(nproc)" --verbose
    (cd "$B" && "./$SAMPLE.fpga_sim")
done
```

The original `-Xsghdl` option saves simulator waveforms; it does not select the GHDL simulator. Keep each `.fpga_sim.prj` beside its executable and run from the build directory. Require the simulator device, native exit 0, all original numerical checks, and no Error/Fatal or failed simulator teardown—even if a host prints `PASSED`.

PART4's simulator can request a **32 GiB virtual shared mapping** for its small original vector. A prior 24 GiB address-space cap caused `IPCSharedMemoryMaster() failed to map shared memory`; the identical binary passed with a 48 GiB allowance. Fresh jobs use 64 GiB. This is a virtual-address requirement, not evidence that the test consumes 32 GiB of resident RAM. Preserve sparse backing files if copying a simulation workspace; do not materialize them accidentally.

## Demonstrate host-only fast recompilation

Use a separate source copy so the imported upstream sample stays unchanged:

```bash
cp -a "$SAMPLES/Tutorials/GettingStarted/fast_recompile" "$WORK/fast-demo"
B="$WORK/build/fast-demo"
cmake -S "$WORK/fast-demo" -B "$B" \
    -DFPGA_DEVICE=AGFB027R25A2E2V \
    -DUSER_INCLUDE_PATHS="$SAMPLES/include"
cmake --build "$B" --target fpga_sim --parallel "$(nproc)" --verbose
(cd "$B" && ./fast_recompile.fpga_sim)
```

Change only the host success message in `$WORK/fast-demo/src/host.cpp`, for example from `PASSED: results are correct` to `PASSED: results are correct (host-only recompile)`. Leave kernel code, data size, device options and build directory unchanged. Then:

```bash
cmake --build "$B" --target fpga_sim --parallel "$(nproc)" --verbose
(cd "$B" && ./fast_recompile.fpga_sim)
```

The original CMake already supplies `-reuse-exe=<existing executable>`. The first build's missing-executable warning is expected. The second should actually extract/reuse the existing device image, and the changed-message executable must still pass the original numerical check. A short rebuild duration alone is not reuse proof. In this verification, the compiler's image-extraction path was observed without a new simulator-generation phase, and the exact host-only delta and both numerical runs passed. The embedded device payload was not separately retained before relinking, so independent before/after payload byte equality is **not** claimed ([reuse evidence](../../qualification/ahls-getting-started-01/simulator-verification07.json)). Changing device code/options can legitimately force regeneration; do not claim reuse in that case ([upstream explanation](hls-samples/Tutorials/GettingStarted/fast_recompile/README.md#using-the--reuse-exe-flag)).

## Full isolated-IP compile

For PART2–4, `fast_recompile`, and `fpga_template`, use their configured build directories:

```bash
export OCL_ICD_FILENAMES=libintelocl_emu.so
for PART in 2 3 4; do
    cmake --build "$WORK/build/fpga_compile-part$PART" \
        --target fpga --parallel "$(nproc)" --verbose
done
for SAMPLE in fast_recompile fpga_template; do
    cmake --build "$WORK/build/$SAMPLE" \
        --target fpga --parallel "$(nproc)" --verbose
done
```

This runs the HLS/Quartus isolated-IP characterization flow. Keep complete native compiler/Quartus reports, actual part binding, result status and reported Fmax. Read the **Quartus Fitter: Clock Frequency (MHz)** section of the FPGA Optimization Report; its captured data is `reports/resources/quartus_data.js` under the `.fpga.prj` directory. The generated 1000 MHz placement constraint and associated timing warnings are documented behavior, not a requirement for these components to operate at 1 GHz. `-Xsclock` affects HLS scheduling effort; it is not a blanket replacement for integrated timing signoff ([handbook quotation and interpretation](../../qualification/ahls-getting-started-fix01/timing-interpretation07.json)). It can take substantially longer than emulation or simulation. **Do not execute the `.fpga` output, pass it to the flash writer, or interpret it as an OFS/OPAE card test.** No application VF, FPGA flash, BMC cycle or workstation reboot is required for these standalone builds.

## Evidence and repeatability

The verification record distinguishes retained accepted runs from new runs. It includes original-source hashes, commands, native exit codes, numerical outputs, report target binding, simulator artifacts, the host-only message delta and full-IP outcomes. Original failures remain recorded rather than replaced by later passes.

The import's license and all original source bytes remain untouched. Generated build products, executable images, sparse simulation memory files and licensed components stay outside Git. Our supplemental setup instructions live here rather than replacing upstream READMEs; their original repository-root license links refer to upstream, while the imported license is linked at the top of this page.

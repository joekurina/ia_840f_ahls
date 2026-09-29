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

The requested import and build/run verification are complete, **with the diagnostic and timing limitations below**. This is not an all-green qualification or a real-card test. The imported bytes match the retained prior results; completed unchanged modes were revalidated rather than rerun.

| Variant | CPU / emulator | Report / RTL | RTL-simulator numerical check | Simulator diagnostics | Full isolated-IP build |
|---|---|---|---|---|---|
| `fpga_compile` PART1 | CPU PASS (reused) | N/A | N/A | Historical link diagnostics retained | N/A |
| `fpga_compile` PART2 | PASS (reused) | PASS (reused) | PASS (reused) | Six family errors | Completed, exit0; timing not met |
| `fpga_compile` PART3 | PASS (reused) | PASS (reused) | PASS (reused) | Six family errors | Completed, exit0; timing not met |
| `fpga_compile` PART4 | PASS (reused) | PASS (reused) | PASS (same-binary recovery reused) | Six family errors | Completed, exit0; timing not met |
| `fast_recompile` | PASS (reused) | PASS (reused) | PASS (new), including host-only recompile/run | No Error/Fatal in captured transcript; warnings retained | Completed, exit0; timing not met |
| `fpga_template` | PASS (reused) | PASS (reused) | PASS (new) | Six family errors | Completed, exit0; timing not met |

The final verification covers 1 CPU run, 5 emulator numerical passes, 5 report builds, 5 RTL-simulation numerical passes, the host-only recompile demonstration and 5 new full isolated-IP compilations. Four simulator flows are not diagnostic-clean, and none of the five standalone builds meets its generated 1.000 ns timing target. No FPGA card program was executed.

See the [result report](../../qualification/ahls-getting-started-01/RESULT.md), [machine-readable final verification](../../qualification/ahls-getting-started-01/verification23.json), [reused evidence](../../qualification/ahls-getting-started-01/prior-verification03.json), and [simulator diagnostic correction](../../qualification/ahls-getting-started-01/diagnostic-disposition13.json). All native jobs and the completion observer have ended; no other sample batch was resumed.

## Known simulator diagnostics

Numerical success and diagnostic-clean simulation are separate. The retained transcripts for `fpga_compile` PART2, PART3, PART4 and `fpga_template` each contain six `Error! Unknown INTENDED_DEVICE_FAMILY=Stratix V.` messages, despite native exit0 and successful original numerical checks. `fast_recompile` has no occurrences of this diagnostic. The transcript audit and exact lines are in [diagnostic-disposition13.json](../../qualification/ahls-getting-started-01/diagnostic-disposition13.json).

The messages come from generated FIFO instances passing a legacy family parameter to the installed `altera_mf_ver.scfifo` model. Its source emits this check with `$display` rather than stopping; the Pro model's family-validity list does not accept `Stratix V`. This explains why an error message and a numerical pass can coexist; it does **not** make the four simulations diagnostic-clean or justify suppressing the text. Do not change the requested FPGA part to Stratix V, modify the vendor model, or claim that a toolchain change has fixed it without an actual changed result. No such correction is included here.

The original PART1 build also retains OPAE `**ERROR**` messages from linking with private-sysfs discovery disabled. Its later CPU numerical pass is valid, but the historical compilation is not described as diagnostic-free. Original logs and superseded parser verdicts are preserved. Acceptance checks must inspect the simulator transcript as well as host stdout and recognize `Error!` and decorated `**ERROR**`, not only `Error:`.

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
export WORK="$REPO/examples/ahls/work/getting-started"
test ! -e "$WORK" || { printf 'Choose a fresh WORK directory.\n' >&2; exit 1; }
mkdir -p "$WORK"/{home,tmp,runtime,icd,build,logs}
ln -s /opt/altera/25.1/quartus/linux64/libstdc++.so.6 \
    "$WORK/runtime/libstdc++.so.6"
printf 'libintelocl_emu.so\n' > "$WORK/icd/Intel_FPGA_SSG_Emulator.icd"

/usr/bin/bwrap --die-with-parent --unshare-pid \
    --ro-bind / / --bind "$WORK" "$WORK" \
    --ro-bind "$SAMPLES" "$SAMPLES" \
    --ro-bind "$WORK/icd" /etc/OpenCL/vendors \
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

This runs the HLS/Quartus isolated-IP implementation flow. Keep complete native compiler/Quartus reports, actual part binding, result status and timing findings. It can take substantially longer than emulation or simulation. **Do not execute the `.fpga` output, pass it to the flash writer, or interpret it as an OFS/OPAE card test.** No application VF, FPGA flash, BMC cycle or workstation reboot is required for these standalone builds.

## Evidence and repeatability

The verification record distinguishes retained accepted runs from new runs. It includes original-source hashes, commands, native exit codes, numerical outputs, report target binding, simulator artifacts, the host-only message delta and full-IP outcomes. Original failures remain recorded rather than replaced by later passes.

The import's license and all original source bytes remain untouched. Generated build products, executable images, sparse simulation memory files and licensed components stay outside Git. Our supplemental setup instructions live here rather than replacing upstream READMEs; their original repository-root license links refer to upstream, while the imported license is linked at the top of this page.

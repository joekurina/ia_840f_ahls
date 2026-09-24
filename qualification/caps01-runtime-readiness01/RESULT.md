# CAPS01 runtime readiness — static initialization observed, no AFU open

## Completed concrete step

On Work21 boot `598f7b27-1798-4a88-8a79-9e4a2659c64d`, **both existing EMIF initialization accessors returned1**:

| Kernel accessor | Observed value |
|---|---:|
| `dfl_dev.5/inf0_init_done` |1 |
| `dfl_dev.5/inf1_init_done` |1 |

Exactly one read of each accessor, no polling/retry, no writes, no VF device open. Runner/outer0, completion `2026-09-24T20:01:22.549012+00:00`, same boot afterward, no device holders/competing selected tools/D-state processes found beforehand. Receipt: [emif-init03-result.json](emif-init03-result.json). This is reported initialization/calibration-success state, **not** a DDR data-integrity test, physical clock measurement, complete reset/freeze readiness proof, or AFU qualification.

## Supported static accessor recovered from the actual workstation

The prior local-only review `deleg_f054bf3d` completed with no verified accessor in its captured source subset. Its completed transcript was recovered; it is not still running and was not respawned. Actual workstation source/metadata collection found `drivers/memory/dfl-emif.c` and the already-bound `dfl-emif` driver at:

`/sys/devices/pci0000:4e/0000:4e:00.0/0000:4f:00.0/fpga_region/region0/dfl-fme.0/dfl_dev.5`

Cached type0/feature9 and parent PF0 establish the intended feature. No driver install/rebind was needed. See [source01-result.json](source01-result.json) (contains binary payloads, local-only).

`dfl-emif.c:60–70` performs one64-bit read at feature base+8 and extracts `shift+index`. The loaded module's GNU build ID matches its on-disk ELF; disassembly `emif_state_show+0x13` confirms the64-bit base+8 load. Decoded actual ELF attribute records confirm `inf0_init_done` shift0/index0 and `inf1_init_done` shift0/index1. Exact module SHA `a4c380d2ce62d75e198ea9f56eb153cb6140c4ab26d7099af4104fedea065aa9`, build ID `61c6d0685e6cd38c270c840f6e31641d5b26f877`. See [accessors02-result.json](accessors02-result.json) (binary payloads, local-only) and [emif-init03-plan.json](emif-init03-plan.json).

The inspected static RTL matches the retained Work21 original inventory in `qualification/fim21-pr-platform01/result-stage01.json.gz`: `mem_ss_csr.sv:43–46,207–214` defines the RO status register, `mem_ss_top.sv:120–146,168–184` synchronizes calibration outputs into **clk_csr**, and board `top.sv:1233–1278` binds `clk_csr/rst_n_csr[0]`. `fabric_width_pkg.sv:70` assigns EMIF feature base0x15000; the status is thus source-derived PF0 BAR0 offset0x15008. **No raw BAR read was used.** Reading this static CSR does not depend on the AFU bank0 CSR clock. The actual read uses the kernel-bound feature resource, not a guessed offset.

## Two false-positive traps excluded

1. **Calibration-failure ABI mismatch.** Installed `dfl-emif.c:21–24,127–128` and its actual ELF expect cal_fail bits8/9. The two-channel RTL concatenates `{cal_fail,cal_success}`, placing failures at bits2/3. Consequently these `inf*_cal_fail` accessors cannot establish absence of calibration failure on this image. They were **not read** and no failure-free claim is made. The low initialization bits do match. No driver/RTL replacement or resynthesis was attempted.
2. **Bridge `state` is not a hardware reset check here.** `dfl-fme-br.c:55–57` provides only `enable_set`, no `enable_show`. `fpga-bridge.c:292–304` defaults to enabled when enable_show is absent. The actual modules were captured/bound; no `state` read was used as readiness evidence. This generic status string cannot prove soft reset released or PR freeze inactive. [Captured source](files/dfl-fme-br.c), [bridge implementation](files/fpga-bridge.c).

## Existing host build: static library closure verified without execution

Target01 is reused unchanged, not rebuilt. The device-free AHLS container check (`--containall`, no host sysfs/home/default binds, target tree mounted read-only) ran Python/readelf only. FPGA/VFIO/UIO devices were absent. No application binary, OPAE library constructor, backend or device was executed/opened. The AHLS SIF and Apptainer wrapper/runtime hashes match the accepted compile receipts. [loader06-result.json](loader06-result.json).

The initial `loader04` file-only check correctly rejected **empty RUNPATH entries** in existing SDK libraries. Its completed diagnostic was recovered without replaying it; [loader-capture05-result.json](loader-capture05-result.json). These entries denote CWD, not absence of a search directory. The successor `loader06` explicitly maps them to `/empty`, verified empty and read-only, with proposed `LD_LIBRARY_PATH=/work/sdk-build/lib:/work/prefix/usr/lib/x86_64-linux-gnu`. No ELF bytes were modified.

Static DT_NEEDED resolution covers10 ELF objects. All8 objects under `/work` match their accepted Target01 original/copied-build receipts; libc and the interpreter are hashed inside the unchanged image. Every earlier absolute OPAE plugin search prefix was checked absent before relying on the required literal module token `libopae-v.so`. [loader-binding07.json](loader-binding07.json).

This is a **static resolution/identity result**, not an observed dynamic load or proof of all runtime dlopen activity. A future live launcher must use explicit minimal execve environment, the verified empty read-only CWD, unchanged library/config bytes and exact device visibility. The accepted launcher is deliberately mode0600; use a separately hash-verified executable copy when live execution is justified, leaving the accepted original unchanged.

## Remaining immediate boundary

- No AFU UUID/DFH/capability read, DMA, DDR data check or AHLS execution has occurred.
- Actual loaded VFIO kernel open/close/reset behavior is under local-only review `deleg_7f2987b9`, using captured exact kernel modules; parent alone controls hardware. Consume its delivered result, do not respawn or probe a device to infer reset behavior.
- Calibration-success flags alone do not settle bank0 reset/host soft-reset/freeze behavior across an implicit VFIO reset. Reconcile the exact reset path before authorizing the application open/read/close sequence.
- Keep PF0 DFL and managementPF1 VFIO bindings unchanged; use only existing isolated VF4f:00.2/group76 after any required current-state checks. No new flash, VF creation, rebuild, UART work or recovery/reset experiment is justified.

Overall functional goal **NOT COMPLETE**. Publication remains pending; this step did not commit/push. Kernel ELF payloads and raw capture JSON containing them remain local-only despite file sizes below2MB.

## Receipt hashes

- `source01-result.json`: `7d9fabcacd7d4c7a1ce13052c7c6243c4c4ac6a1fd3eb28863229b46fbb59257`.
- `accessors02-result.json`: `91cd26f7b9aad66585c1a7154fb86686791cea18b83edc16d943a1fa7520ba4b`.
- `emif-init03-result.json`: `c54babb523ca1fe4702ebca7bc6835d0286829829482c0aa6d1db2351a4a96d9`.
- `loader04-result.json`: `fb1b8a3b0f81c3c1286fe2e76acc2d84edfd3f89c6f57a2d8feda70c1971af12`.
- `loader-capture05-result.json`: `75f184efcbbc7a2f985b3012eda3786a880d865a74839be9f86b2e2fc9009d03`.
- `loader06-result.json`: `75acae541631d1c0ec4d2338b837b8529e9fec3115e9fb339acbce5006c3ccc9`.
- `loader-binding07.json`: `0938abd70ffaa5f4bdc162e7704f50941a7f5de7cdaa9623722d6125402ae53f`.

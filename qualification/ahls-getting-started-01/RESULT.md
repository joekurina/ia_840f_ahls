# GettingStarted import and verification results

> Historical baseline. The later [corrected flow](../ahls-getting-started-fix01/RESULT.md) removes the four simulator family-error cases and corrects the timing interpretation: the HLS handbook explicitly expects timing warnings from its deliberate 1000 MHz standalone characterization target. Use reported component Fmax, not closure of that artificial target as an application gate. The raw observations and initial assessment below are preserved; see [current setup instructions](../../examples/ahls/README.md).

## Outcome

The requested three tutorial roots and six program variants are imported and their named standalone build/run modes have recorded results. **Verification work is complete, but the result is not diagnostic-clean or timing-closed in every mode.** No real-card execution, flash, BMC action, reboot, toolchain switch or vendor-model edit occurred. The broader release-wide sample work remains stopped and the existing CAPS03 release tag is unchanged.

The import contains 16 exact upstream files, including the required common header, MIT license and tutorial images. Both requested upstream main and release2026.1.0 resolved to `0abae6d78af5daca3fe5d67e617ab037e58aff89` ([source manifest](../../examples/ahls/hls-samples/UPSTREAM.json), [setup README](../../examples/ahls/README.md)).

## Per-variant results

| Variant | CPU / emulator | Report / RTL | RTL-simulator numerical check | Simulator diagnostics | Full isolated-IP build |
|---|---|---|---|---|---|
| `fpga_compile` PART1 | CPU PASS (reused) | N/A | N/A | Historical link diagnostics retained | N/A |
| `fpga_compile` PART2 | PASS (reused) | PASS (reused) | PASS (reused) | Six family errors | Completed, exit0; timing not met |
| `fpga_compile` PART3 | PASS (reused) | PASS (reused) | PASS (reused) | Six family errors | Completed, exit0; timing not met |
| `fpga_compile` PART4 | PASS (reused) | PASS (reused) | PASS (same-binary recovery reused) | Six family errors | Completed, exit0; timing not met |
| `fast_recompile` | PASS (reused) | PASS (reused) | PASS (new), including host-only recompile/run | No Error/Fatal in captured transcript; warnings retained | Completed, exit0; timing not met |
| `fpga_template` | PASS (reused) | PASS (reused) | PASS (new) | Six family errors | Completed, exit0; timing not met |

Reused does not mean a new execution from this checkout: the imported original bytes were matched to the pinned source and retained native commands/results. [prior-verification03.json](prior-verification03.json) revalidates 1 CPU run, 5 emulator runs, 5 report builds and the earlier PART2–4 numerical simulations. Each integer host checks all256 original elements; fast-recompile checks all32 floats at the source's squared tolerance. These are the samples' own oracles, not exhaustive address/arithmetic coverage.

New native execution comprised two simulator builds/runs, the extra host-only recompile/run, and five full isolated-IP builds. The sequential worker completed all7 selected jobs and returned0. The postflight found no live owned process and all16 original source files unchanged. `verify-final23.py` was executed locally with exit0 against the captured evidence; it performs no vendor or hardware operation ([final verification](verification23.json), [worker completion](finished01.json), [postflight](postflight22.json)).

## Simulator diagnostic limitation

The actual transcripts for PART2, PART3, PART4 and fpga_template each contain six `Error! Unknown INTENDED_DEVICE_FAMILY=Stratix V.` messages. They coexist with native0 and a successful original numerical comparison. Fast-recompile has no matching Error/Fatal diagnostic in its captured transcript; compatibility and model warnings remain. Do not call the four affected simulations diagnostic-clean ([parent-confirmed review/disposition](diagnostic-disposition13.json), [exact transcripts](diagnostics13/)).

The mapped `altera_mf_ver.scfifo` model reports the family-validity check with `$display` and continues. Generated HLS FIFO paths pass the legacy family parameter; the inspected Pro model validity list excludes it. This is source-grounded diagnostic context, not a new model correction or a reason to target a Stratix V FPGA. We did not suppress messages, patch vendor models, or rerun the kernel to erase the historical outcome.

The early `simulator-verification07.json` mistakenly called template's transcript error-free because its detector only recognized colon-form errors. That immutable receipt is superseded for diagnostic cleanliness by `diagnostic-disposition13.json`. The retained PART4 recovery transcript also contains the six messages, so its numerical recovery remains accepted but is not diagnostic-clean. PART2/PART3 transcripts were captured separately for this follow-up; absence from an older local collection was not treated as proof of cleanliness.

PART1's original CPU build also contains OPAE `**ERROR**` messages during private-sysfs platform discovery. The later CPU numerical pass is separate from those link diagnostics. No claim of warning/error-free compilation is made ([original link log](prior03/compile1-original-build/part1-emulator-build.log)).

## Isolated-IP compilation and timing

All five original `fpga` targets completed with CMake exit0 and native Quartus full-compilation success. Their reports bind AGFB027R25A2E2V and Quartus25.1.0 Build129. The compiler generated a1.000ns standalone optimization clock; **none of these builds closes that target**. This is separate from the accepted CAPS03 image's3.000ns application target, and is not measured card performance. No clock constraint was relaxed to turn these findings into a pass ([complete result records](verification23.json)).

| Variant | Generated clock period (ns) | Setup slack (ns) | Hold slack (ns) | Minimum-pulse-width slack (ns) |
|---|---:|---:|---:|---:|
| `compile2-ip` | 1.000 | -0.499 | 0.011 | -0.279 |
| `compile3-ip` | 1.000 | -0.247 | 0.014 | -0.279 |
| `compile4-ip` | 1.000 | -0.295 | 0.011 | -0.279 |
| `fast-ip` | 1.000 | -0.184 | 0.018 | -0.406 |
| `template-ip` | 1.000 | -0.499 | 0.011 | -0.279 |

The full-IP flow produces isolated implementation/area/timing results—not a board executable or deployment image. The successful native tool status does not override negative timing slack or establish OFS/PIM integration. Do not run these `.fpga` outputs as IA-840F applications.

## Fast-recompile demonstration

A private working copy changed only the success message in `host.cpp`; the imported original remained unchanged. Both runs passed the original32-float checker. The second compile logged extraction of the existing embedded `aocx.0` image and did not repeat the initial simulator-generation phase. This verifies the observed compiler reuse path and host-only change, not an independent byte comparison of the device payload: standalone before/after payload inventories were empty and the old payload bytes were not separately retained before relink ([bounded evidence](simulator-verification07.json), [recompile log](capture06/runs/fast-sim/host-only-recompile.log)).

## Toolchain and retained failures

The actual installation is HLS IP Gen2026.1.0, Quartus Pro25.1.0 Build129, Questa2024.3 and CMake3.31.8. The HLS warning that26.1 is its supported Quartus version is retained. Observed successes do not claim vendor validation of the25.1 combination. The process-local libstdc++ override and64GiB virtual-address allowance are documented in the [setup guide](../../examples/ahls/README.md).

PART4's original24GiB mapping SIGABRT, later unchanged-binary48GiB numerical pass, and intermediate instrumentation failures remain recorded. A local prior-evidence verifier first assumed recorded waveform hashes meant the waveform binaries were locally transferred; the failed verifier/partial exports remain local and the corrected receipt explicitly records metadata-only waveform reconciliation. A missing native Quartus log in collection15 was recovered by the exact hash-matched collection17 supplement, not a native rerun ([prior reconciliation](prior-verification03.json), [native-log supplement](collection17.json)).

## Evidence and publication

The completed-run collections06/15/17/20/21 contain197 hash-verified transferred files. Oversized native reports remain local-only with exact sizes/hashes in their collection manifests; binaries, waveforms, licensed models/tools, embedded transport envelopes and temporary source probes are not publication payloads. Preserve the original raw logs and imported source whitespace. Final evidence is bounded by [verification23.json](verification23.json); publication uses an explicit path/hash allowlist and leaves unrelated repository changes untouched.

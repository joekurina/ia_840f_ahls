# GettingStarted import/build checkpoint

## Completed scoped work

The requested GettingStarted source import and build/run verification are complete **with recorded simulator-diagnostic and timing limitations**. The result is not an all-green FPGA qualification. See [RESULT.md](RESULT.md), [verification23.json](verification23.json) and the [build/run README](../../examples/ahls/README.md).

The scope is only `fast_recompile`, `fpga_compile` PART1–4 and `fpga_template`. The broader release-wide sample work remains stopped. Do not restart its cancelled worker, reflash CAPS03, move `ia840f-caps03-v1.0.0`, or infer card execution from the standalone `fpga` target.

## Source and verified modes

- Six program variants across three tutorial roots; 16 original upstream files, including common header/license/images, remain byte-identical to main/tag2026.1.0 commit `0abae6d78af5daca3fe5d67e617ab037e58aff89` ([import manifest](../../examples/ahls/hls-samples/UPSTREAM.json)).
- Prior results were source-bound and revalidated offline: 1 CPU run, 5 emulator numerical runs, 5 report builds and PART2–4 numerical RTL simulations. Completed unchanged device builds were not repeated ([prior verification](prior-verification03.json)).
- New fast-recompile/template simulator builds and numerical runs completed. The extra host-only message recompile/run passed; the compiler extracted its embedded image without a new simulator-generation phase. Independent before/after payload-byte equality is not claimed ([bounded simulator/reuse evidence](simulator-verification07.json)).
- All 5 original full isolated-IP builds completed with CMake exit 0 and native Quartus full-compilation success for AGFB027R25A2E2V. None meets its generated 1.000 ns timing target. This is separate from CAPS03's 3.000 ns application clock and is not a card-execution result ([timing/result records](verification23.json)).

## Diagnostic correction and retained limits

Review `deleg_71fb0d01` is delivered, consumed and parent-confirmed. PART2, PART3, PART4 and fpga_template transcripts each contain six `Error! Unknown INTENDED_DEVICE_FAMILY=Stratix V.` diagnostics despite native exit 0 and numerical success. They are **not diagnostic-clean**. The initial template error-free flag in `simulator-verification07.json` is superseded, not rewritten. Original OPAE link errors for CPU PART1 are also retained. Exact transcript hashes, source findings and the corrected detector are in [diagnostic-disposition13.json](diagnostic-disposition13.json).

The installed HLS compiler warns that it supports Quartus 26.1 while the selected setup is 25.1; no installation was changed. We did not suppress model errors, modify vendor models, relax timing constraints or claim that changing tool versions fixes the diagnostics. Preserve PART4's original mapping SIGABRT and unchanged-binary recovery, the failed local waveform-collection assumption, and the later hash-matched native-log supplement.

## Native ownership — finished

The single remote worker under `/home/uwb_student00/ahls/new_BSP/work_ahls_getting_started_01` finished all seven jobs at `2026-09-29T18:59:30.960581+00:00`, outer exit 0. Its original tmux `@104 %104`, completion channel `ahls-gs-done-f20dfc61eaba` and exit buffer `ahls-gs-rc-f20dfc61eaba` are historical. Do not wait on the consumed completion channel again or replay the worker.

Observer `proc_5e31d42add61` / `watch01.py` exited 0. [finished01.json](finished01.json) and [postflight22.json](postflight22.json) establish completion, no live owned process, and unchanged imported source. All native work ran with private device/PID namespaces, empty sysfs, full live CPU affinity and 64 GiB per-process address-space limits. No physical-card operation occurred.

The completed collections06/15/17/20/21 contain 197 rehashed files. Reports over 2,000,000 bytes, binaries/waveforms, licensed models, transfer envelopes and source-probe payloads remain local-only with hash references. Unrelated root `.gitignore`, `docs/hw-programming-recovery.md` edits and other untracked work must stay untouched.

## Publication

Publish only the explicit imported-source, authored-documentation and selected evidence allowlist. Remote publication verification is stored outside the repository to avoid a self-referential commit hash. No build/test task remains active; any model correction, timing change or actual-card integration is a separately scoped follow-up, not an automatic continuation.

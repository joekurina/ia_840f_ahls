# GettingStarted correction — completed

The concrete simulator family-parameter defect is fixed and verified. The earlier timing assessment is corrected using the HLS handbook and actual Optimization Report Fmax values. See [RESULT.md](RESULT.md), [verification18.json](verification18.json) and the [updated runnable instructions](../../examples/ahls/README.md).

## Implemented and exercised

- Additive CMake preparation under `examples/ahls/compatibility/lsu-family/` generates an owned support-RTL copy with only two `.DEVICE("Agilex 7")` instantiation arguments added. It rejects an unexpected FPGA part or original source hash.
- The compiler receives that file through a private read-only bwrap bind. Original SDK source SHA256 remains `873549f18428fe6ba0797fef228c2028bf1df62076e85f1942c9dca5310cf8a0`; compiler-visible/generated overlay SHA256 is `cfee3826587686ddc36919ac18db973c620f72bfd8f555ab2f3622b19b21d333`. Imported C++ and primitive models are unchanged.
- Fresh fpga_template and fpga_compile PART2/PART3/PART4 builds/runs each exited 0, passed all 256 original integer checks and had zero Error/Fatal in their complete simulator transcripts. Original six-per-run family errors remain in the baseline records; they were not suppressed or rewritten ([simulator-verification14.json](simulator-verification14.json)).
- The corrected template full-IP build completed. Its entire Optimization Report clock/resource data is byte-identical to the original, including Fmax 667.11 MHz. Its 1 ns characterization SDC is byte-identical too. No timing relaxation, hardware execution or bitstream equivalence claim ([verification18.json](verification18.json)).

## Correct timing interpretation

HLS IP Gen Handbook §9.1.1 explicitly expects timing warnings from the generated 1000 MHz placement/characterization constraint. Reported component Fmax is the appropriate result; do not demand 1 ns application closure or rerun unchanged fits to make this artificial target green. Original estimates are PART2 667.11, PART3 781.86, PART4 772.20, fast_recompile 711.24 and template 667.11 MHz ([quotation and exact report data](timing-interpretation07.json)).

Read-only baseline review `deleg_657b51c8` was delivered, consumed and parent-checked. The vendor oneAPI BSP performs post-fit clock selection and packages board runtime/PR metadata. It did not require an observed 1 GHz vector-add operating clock. Its exact final vector-add frequency remains unlocated; no unrelated board-test number is substituted ([vendor-baseline11.json](vendor-baseline11.json)).

## Ownership — all work finished

Remote root `/home/uwb_student00/ahls/new_BSP/work_ahls_getting_started_fix01` contains five completed jobs: template-sim, part2-sim, part3-sim, part4-sim and template-ip. Native worker/outer status is 0; all source checks pass; postflight found no owned live process. Completion observer `proc_131d1f310b22` exited 0 ([finished06.json](finished06.json), [postflight17.json](postflight17.json)).

Tmux `@130 %130`, `gs-fix-rc-b5d4e78e13e9` and `gs-fix-done-b5d4e78e13e9` are historical handles. Do not dispatch the worker again or wait on the consumed channel. No native build, simulator, review or card operation remains active for this correction.

## Scope and publication

The existing HLS 2026.1 / Quartus 25.1 compatibility warning and other non-error warnings remain visible. No installed SDK/toolchain, original tutorial source, existing release tag, card image or unrelated working edit is changed. The broader sample-release work remains paused.

This is a verified compiler-input/simulator correction, not restoration of the old oneAPI MMD/SYCL board runtime or a new on-card execution of these original kernels. Actual OFS/PIM integration and its final operating-clock signoff remain distinct. Publish only the explicit new code/docs/small-evidence allowlist; raw source probes, licensed models, binaries and oversized reports remain local. The final remote commit verification is retained outside the repository to avoid self-reference.

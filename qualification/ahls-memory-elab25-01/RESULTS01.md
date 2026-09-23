# Native Quartus 25.1 memory-IP elaboration result

**Native rc0; strict runner rc125; independent result review pending.** The native `--analysis_and_elaboration` invocation completed and reported success. This is not full mapped synthesis or fit/timing. The wrapper asked for a nonexistent stage-specific success banner and expected a byte-identical QSF; native25.1 emits the generic `Quartus Prime Synthesis was successful` banner and appended exactly two power-format assignments. Original receipts remain unchanged; no repeat of the native command is justified by those two bookkeeping assumptions alone.

[Manifest](manifest-elab01.json) records seven captured members, original/copied222-input preservation, tool hashes, no timeout and no surviving owned process group. Archive `7ce24877a886417f6ff2e379f79b2a2ead0a07eb7a38399e5b8d1665f7456480` is 348519 bytes. Peak virtual memory was2301MB, native elapsed20seconds. Native project top is `ahls_memory_import`, partAGFB027R25A2E2V, tool25.1 Build129. All four generated QIPs were included with their native library assignments; [finite dependency ledger](qip-dependencies01.json) contains177edges/174unique targets.

QSF delta (and only delta):
```tcl
set_global_assignment -name PWRMGT_VOLTAGE_OUTPUT_FORMAT "LINEAR FORMAT"
set_global_assignment -name PWRMGT_LINEAR_FORMAT_N "-12"
```
The `--write_settings_files=off` option did not prevent these native project defaults. Neither changes the copied HDL. Do not relabel `qsf_unchanged=false` or `accepted_by_runner=false` as true in the original result.

## Findings retained

- Native reports contain the actual DDRIP/LSU hierarchy and659elaborated partitions. No missing-component or elaboration-error result was observed.
- The final native banner says **0 errors /1 warning**, whereas the full log has 57 explicit diagnostic occurrences. [Diagnostic ledger](warning-ledger01.json) is an occurrence list, not a replacement summary total; reconciliation is assigned to review.
- **RES-10204 / Critical20759:** no Reset Release IP in this standalone component-only project. No full-device configuration or reset acceptance is claimed; binding to the FIM reset/clock service remains necessary. Do not add a second device-level reset-release instance blindly in a persona.
- Width truncation and undriven-output warnings need parameter/hierarchy/source disposition. All 14 referenced files have hash-matching local sources in the ledger; no warning is waived from vendor origin.
- Only source elaboration compatibility is at issue. Full synthesis, functional reset/burst/backpressure/completion, DMA/PIM, actual DDR banks and host visibility, fit/STA and hardware remain open. DDR simulation remains **SKIPPED BY USER**.

This result does not modify Work21, the original import/generated inputs or live hardware. It does not establish numerical kernel behavior.

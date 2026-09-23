# Parent acceptance — corrected AHLS memory-component elaboration

**ACCEPT_STANDALONE_ANALYSIS_ELABORATION_WITH_FINDINGS.** This accepts the exact Quartus 25.1 Build 129 analysis/elaboration snapshot for `AGFB027R25A2E2V`, not mapped synthesis, a functional kernel, an integrated AFU or working hardware.

The parent consumed the FINAL [independent review](independent-review01.md), full-file SHA256 `5732305356db51da07f5adda98ebdb3700bbc588b0b80e3335869b5095a5e610`. [Parent verification](parent-verification01.json) rehashed all 17 frozen entries, decoded and compared all 7 native capture members, and verified all 14 warning-source mappings against the captured source inventory. The [manifest](manifest-elab01.json) metadata agrees with the original archive. No fresh remote inspection is claimed.

## Native result and preserved rejection

The exact command was `quartus_syn --analysis_and_elaboration --read_settings_files=on --write_settings_files=off ahls_memory_elab -c ahls_memory_elab`. Native/effective rc0, no timeout or surviving owned group, and the actual DDRIP/LSU hierarchy are supported by [review sections Native outcome and Actual active hierarchy](independent-review01.md). This is analysis/elaboration only despite the generic Synthesis success banner.

Outer rc125 and `success_marker=false`, `native_stage_pass=false`, `qsf_unchanged=false`, `accepted_by_runner=false` remain unchanged. The wrapper expected a different banner and a byte-identical QSF; the only QSF delta was two native power-format defaults. Source/tool preservation is supported by the captured postflight. Acceptance follows inspection of the actual result, not a rewritten receipt or redundant rerun. See [original result account](RESULTS01.md) and [exact comparison](parent-verification01.json).

## Retained findings and integration obligations

- The log and native report panels agree on **57 occurrences: 56 Warning and 1 Critical Warning**. The final banner's **1 warning** remains an unresolved summary-accounting discrepancy. Neither count replaces the other ([review Diagnostic reconciliation](independent-review01.md)).
- **RES-10204 / Critical20759 remains unwaived:** the standalone component project has no device Reset Release IP. Bind the component to the real FIM configuration/reset-release and clock service; establish the integrated device-level instance without blindly duplicating it in the persona ([review warning 1](independent-review01.md)).
- Reviewed address/burst narrowing is source-explained for this configuration; no active clipping defect was established. Preserve all 34 address bits, byte/word semantics, burst boundaries, write masks and nonwrapping buffer extents in connected adapters. No traffic test was performed ([review warnings 2–4](independent-review01.md)).
- Pending-write accounting remains an active path. The unit-tested acknowledgment fix is present, but integrated reset, backpressure, request/ack balance, kernel completion and downstream visibility remain unproven ([review warning 3](independent-review01.md)).
- The exported **64-bit exception bus is constant zero**. Zero is not evidence of error detection or successful computation. Its enclosing-interface contract must make that limitation explicit ([review warning 4](independent-review01.md)).

Full mapped synthesis, FIM/DMA/PIM integration, physical-bank routing, fit/STA, numerical results, DDR transfers and sustained/durable hardware operation remain open. **DDR simulation: SKIPPED BY USER.** No hardware, driver, flash or reboot operation occurred. This acceptance creates no new execution-approval barrier and authorizes no live access.

# Write-ack correction checkpoint

The source-local candidate and actual unit regression are independently accepted as **ACCEPT_SCOPED_SOURCE_AND_UNIT_ONLY**. See [RESULT-ACCEPTANCE.md](RESULT-ACCEPTANCE.md) and the FINAL [independent-review01.md](independent-review01.md), SHA256 `5ef3a28732020c6baa33bd8cdb58cb2fd3b7429a0aad536d2492e22a8a9f423e`. Review package SHA256: `626f992f7283d6d58356bcde4c4546fd66f024f054d18c3d572d0aeed4cc485d`.

- **RED:** original captured block genuinely fails at106ns, cycle7, write1/waitrequest1/ack1/expected0. Final-driver red03 exits1 after rejecting Fatal/error-summary diagnostics and the absent pass marker, despite native vsim exit0.
- **GREEN:** the candidate passes5scenario groups,796cycles,2491checks;107accepted beats match107acks. All native commands and the final wrapper exit0. No Error/Fatal diagnostics.
- Patch: `afu/ahls_memory/patches/zero_allowance_writeack.patch`. Original full generated RTL remains untouched; candidate is retained under `candidate-inputs/lsu_ic_top.sv` and hash-bound by `patch-manifest01.json`.
- Fixtures: `afu/ahls_memory/tests/ack_unit_wrapper.sv.in` and `writeack_unit_tb.sv`. Native runner template and raw result JSONs preserve exact invocations, source/tool identities and all failed attempts. Payload-bearing launch scripts and vendor-source copies remain local-only.
- Native directories: `/home/uwb_student00/ahls/new_BSP/work_ahls_writeack_fix01/{red01,red02,red03,green01}`. All are spent; do not rerun them in place.

The accepted scope is an isolated source-extracted acknowledgment generator plus the unchanged pending counter. Full FIFO/LSU/kernel behavior, native25.1 Platform Designer import, DMA/PIM integration and host visibility remain open. DDR simulation stays SKIPPED BY USER. No hardware operations were performed. Publish this as its own accepted milestone, preserving the separately reviewed Work21 evidence.

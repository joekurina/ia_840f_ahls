# UART vendor-scope correction — implemented locally, static check PASS

## Scope

Joe explicitly directed keeping UART absent and following the old vendor BSP convention. The scope decision is resolved. The local maintained RTL now uses feature ID `12'h0` for `uart_dummy_csr`, matching the vendor disabled-UART branch. Only that token changed. Remote SOURCE integration, native compilation and live deployment have **not** occurred for this change.

Joe then excluded exercising the dummy CSR and reinforced rapid, non-reckless iteration. Validation is deliberately limited to static before/after checks and independent source review. **No dummy-CSR RTL simulation or hardware test ran.** An isolated simulator package had been fetched into local scratch before that correction, but was not used for RTL simulation and was not installed system-wide.

## Exact change and evidence

- [Diff](uart-only.diff): `ofs-agx7-pcie-attach/src/board/ia840f/afu_top.sv:747`, `12'h24` → `12'h0`.
- Original SHA256: `67c43a85a93c23c851a5f1136b05c1467bd541ab5bedb6da373af7d9d87d3bdc`.
- Corrected SHA256: `df74b8e8e04408f2009f398444c5375c0e6ed66fa01452e8f594dfe2712fd60c`.
- Vendor [afu_top.sv](vendor/afu_top.sv):620–630 uses ID 0, revision 0, next offset 0x10000, EOL 0. Vendor [standard](vendor/standard_ofs_top.qsf):101–102 and [USM](vendor/usm_ofs_top.qsf):101–102 disable UART/HPS.
- [Source input manifest](source-inputs.json) binds seven reference files and retains original vendor paths. Local maintained, captured remote maintained and captured W13 target files matched before the edit.

The [static checker](../../tests/ia840f/uart_absent/check_source.py) requires exact complete-file equality with the captured W13 source apart from this one token. Consequently the real-UART branch, clocks/resets, tie-offs, neighboring instances, generated offset/EOL expressions and AHLS route remain byte-identical. It also checks literal UART/HPS macro assignments and the captured generated APF links: ST2MM 0x40000 → UART slot 0x60000 → port-gasket slot 0x70000. This is **not** a full DFL walk, Tcl evaluation, synthesis, or proof of live device behavior.

## Executed checks

- [Before](before-check.json): checker rc1 with the expected old-ID rejection.
- [After](after-check.json): same checker rc0, PASS.
- [Optimized Python](after-check-optimized.json): rc0, PASS; acceptance checks do not disappear under `python -O`.
- `git diff --check`: rc0.
- Existing accepted fix-01 diagnosis and evidence remain unchanged; no new UART-function claim.

[Independent driver research](driver-id0-research.md) supports the ID-zero convention for this private DFHv0 placeholder: traversal is controlled by next-offset/EOL, and neither UART ID nor GUID matching selects `8250_dfl`. The placeholder may still enumerate as a generic DFL resource; it is not erased from the chain or universally immune to other driver matches. The research report's maintained-source ID-0x24 description records its pre-edit inspection; the corrected local bytes are bound above. Independent spec and quality acceptance are still pending. A fresh source-bound native FIM build is justified by this real RTL correction after the review gate; preserve W13/persona rather than modifying/rebuilding their existing trees.

## Remaining boundaries

Source/offline acceptance does not qualify timing or hardware. Current image/VF/backend/clock-reset identity, pre-filter OPAE accesses, finite live-operation review, explicit authorization and independent host recovery remain unresolved. Udev activation, PR, programming, DDR/transfer/AHLS numerical tests and durable boot remain unperformed for this correction. DDR simulation stays SKIPPED BY USER.

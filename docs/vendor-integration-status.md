# Vendor implementation integration status

This pass supersedes the earlier contract-only state. Target remains Altera AHLS RTL + OFS/PIM + OPAE with Quartus Pro 26.1.1 intended. Sources are integrated to the extent described below, not build-ready or hardware-qualified.

## Implemented and connected

- **Memory:** board-local `mem_ss` and two simulation-model source presets are selected by `ia840f_memory.ofss`. Full matched vendor EMIF parameters are transferred through explicit modern schema mappings, including discrete/RDIMM geometry, timing/electrical settings and BOT/BOT calibration location evidence. [Derivation](vendor-derived-presets.md).
- **PCIe:** the IA840F-only override hook selects the board-local vendor source overlay. It now includes exact PF1 BAR2 64-bit prefetchable memory/width 28 values backed by hash-bound installed Quartus 26.1.1 subsystem definitions. IA840F is explicitly P-Tile. The generic Python schema is unchanged. The helper now enforces source-bound, single-run experimental authorization rather than unconditional rejection. Installed subsystem/child schema evidence does not establish actual child-IP acceptance, generated interfaces/capabilities or toolchain qualification; readiness remains false. Deterministic source derivation matches all four XML/JSON artifacts; memory/simulation preset bytes are unchanged. This is not FPGA IP generation.
- **BMC:** active board-owned source list selects the actual BittWare wrapper and Qsys/custom IP closure. CSR interface clocks/reset are explicit. Parent independently confirmed two open vendor IRQ inputs and made the board-local software-cause-only correction, retaining the original vendor file and source hash. This does not implement MSI-X or fix FLR transaction draining. [Details](vendor-derived-bmc.md).
- **AHLS board-side library:** five connected RTL modules supply PIM board services, DFH/CSR aperture routing, serialized tagged-MMIO-to-Avalon adaptation and native-width byte/line memory adaptation. The actual PIM shared-to-split converter is reused. No old `kernel_system` is relabeled as AHLS. [Binding details](vendor-derived-ahls-binding.md).

## Integration boundaries still open

The [BAR2 source trace](pcie-bar2-source-trace.md) resolves the installed subsystem source schema, P-Tile allowed values and forwarding path, not downstream child acceptance. Subsequent installed child-schema evidence must be distinguished from actual callbacks, generation and interface/capability qualification, which remain unperformed by this local correction. Earlier missing-child/helper/template findings describe the original finite source snapshot, not proof that installed tools lack them. The filename “known schema” denotes a source overlay, not a fully accepted/generated preset. Memory controller/model derived-field semantics and generated interface/pin mapping still need qualification. BMC retains known shared-reset/FLR, unsupported SPI window and IRQ-transport limitations. The AHLS library is not an activated `ofs_plat_afu`: actual generated IP and register map, any required width/stream/global/IRQ adapters, host software and ordered completion/quiescence are unbound. Its current normalized boundary requires 64-bit CSR, native-width aligned memory and at least one local bank; these are library restrictions, not user workload requirements.

## Completed memory and BMC source reviews

The [memory source map](memory-port-source-map.md) and its [machine-readable evidence](../reference/vendor-integration/memory-port-source-map.json) trace both physical channels and vendor calibration connections. Modern grouping is structural: two simulation models do not prove two physical interface groups. Existing group-specific pin names remain proposals pending generated-interface evidence. The map also records the unspecified RDIMM negative reference-clock coordinate and untransplanted model fields. No unconditional configuration correction was proven; no pins, presets or RTL were changed by this review.

The subsequent [memory CSR source review](memory-csr-source-review.md) and [register/routing evidence](../reference/vendor-integration/memory-csr-source-review.json) refine the earlier topology finding: the modern common wrapper already supplies the outer DFH/subsystem split at memory-local `0x000`/`0x800`. The unresolved contract is the enabled modern subsystem/MSA diagnostics, register semantics and clock/reset export—not a missing outer router. `CSR_EN` has not been proven equivalent to legacy `DIAG_ENABLE_CSR`; neither enable was changed. Vendor controller-MMR routes at internal `0x00100000` and `0x00110000` lie outside the actual outer 11-bit subsystem aperture and are not demonstrated directly host-accessible capability. No aperture widening or manual generated-interface macro was introduced. The review records 58 legacy register entries, 14 management connections and 24 source hashes; the parent independently rehashed all 24 with no mismatches. These remain finite static evidence, not IP acceptance.

The [BMC FLR review](bmc-flr-source-review.md) found no vendor/OFS-proven narrow cancellation/drain correction. PF1 reset clears RX CDC and TX skid but not all CSR request/response state or TX CDC. Clearing TX CDC alone cannot prevent late completions; resetting the host master against a live shared AXI slave risks partial-write ownership. The timer and unused edge-pulse acknowledgment are not drain evidence. Shared SPI/SDM resets and BMC RTL remain unchanged.

The [BMC component source-closure review](bmc-component-source-closure.md) and [machine-readable inventory](../reference/vendor-integration/bmc-component-source-closure.json) establish the finite local registration graph: 34 active source/registration files, two Qsys systems, 25 module records and 24 leaf IPs. Both custom components' filesets resolve to four unique RTL files. No omitted vendor-owned source or mismatched registration was found, so no source patch was warranted. The parent independently rehashed all 34 candidate files and their 34 donor counterparts with zero mismatches. Tool-provided catalog IP, legacy Qsys packages/helper Tcl and generated interconnect/library binding remain unqualified; this does not close FLR, interrupt or Quartus 26.1.1 compatibility requirements.

These reviews are complete as source investigations, not as closure of their unresolved interface contracts. Earlier finite hash receipts below retain their original scope and are not fresh whole-project qualification.

## BAR2 correction static evidence

The inspected read-only inventory returned source consistency **pass**, 99 FIM
manifest entries checked, no errors and no compiled board artifacts. Separate
hash checks verified all 16 copied installed files and all 17 derivation input
dependencies. XML comparison found exactly two added BAR2 fields and all 102
previous PCIe values unchanged (104 now). Memory and simulation preset bytes
are unchanged. Python AST parsing confirmed the helper's preceding checks are
unchanged and its final rejection was unconditional at that historical review;
the helper was not executed then. The later experimental gate replaces that
unconditional rejection without declaring readiness. Current manifest hashes were refreshed while donor and prior hashes
were preserved. These are source consistency results, not project tests.

## Parent static evidence

`reference/vendor-integration/static-integration-receipt.json` records the independent inventory: 99 FIM manifest entries checked, 17 selected AHLS source-origin hashes checked, source consistency pass and no errors. `pre-integration-fim-manifest.json` preserves the full prior manifest; current records preserve original source hashes and prior candidate hashes. This is finite source consistency, not HDL elaboration or behavior verification.

Independent read-only RTL review completed without a confirmed defect within the documented normalized-interface contract. Parent inspection of `ahls_avmm_byte_to_line.sv:22–31` confirmed its continuous alignment check: every asserted write beat, including noninitial burst beats, must carry an aligned address. This restriction is now explicit in the binding documentation; no RTL behavior changed. Generated-component binding and all qualification gates remain open. No HDL compiler/linter/simulator/project test has run.

The earlier source-only review prohibited workstation and vendor execution. A later bounded experimental setup/generation authorization is enforced by the source-bound gate; it does not confer general build or hardware permission. This correction pass uses local sources and Python/Bash policy tests only, with no remote or vendor execution, install, programming, commit or push. Installed-source evidence and help results are not generated-IP acceptance. Original BittWare and sibling reference sources were not edited. The active target remains AHLS/OFS/OPAE with Quartus 26.1.1; oneAPI is reference-only.

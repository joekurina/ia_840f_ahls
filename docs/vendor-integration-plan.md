# Vendor-derived implementation integration

## Authorized scope

Use existing BittWare BSP implementations to derive and integrate memory/PCIe presets, BMC and AHLS-facing board infrastructure. This instruction advances source implementation beyond the preceding contract review. AHLS remains the compiler target; vendor oneAPI artifacts supply board/reference implementation evidence, not an automatic AHLS runtime or generated-port ABI.

No builds, setup/configure, IP generation, tests, vendor-tool execution, workstation operations, installation, programming, commits or pushes. Original inputs remain read-only. All edits stay beneath `new/`; gates remain closed.

## Parallel source work

1. Memory/PCIe: derive board-specific source presets from full vendor parameters and current OFS schemas. Connect them through board-local configuration. Track all preserved and translated values, plus any parameter requiring later authoritative IP metadata. Do not silently apply a different devkit's geometry.
2. BMC: trace and connect vendor management source closure, compare selected reset/FLR ownership and modern OFS interfaces, and make justified source corrections. Preserve actual SPI/SDM sharing rather than inventing a reset policy.
3. AHLS boundary: extract/adapt reusable vendor-side MMIO and memory infrastructure, with explicit interfaces and provenance. Component-specific AHLS ports and generated register maps must remain distinct from the old `kernel_system` ABI. No workload-specific protocol or experimental hostchannel engine is imported by assumption.

## Parent integration

- Review actual source edits and reference derivations, not worker completion labels.
- Resolve cross-owner source-list/IP dependencies explicitly.
- Preserve original source hashes and prior candidate hashes when refreshing the FIM manifest. New entries must identify derivation sources; a current SHA256 alone is not source provenance.
- Independently inspect source lists, XML/JSON/configuration, pin/source preservation and gates. Do not run Tcl or project tools to do so.
- Update the source handoff with implemented bindings and precise residual gaps; do not carry old blocker wording forward when real source implementation resolves it.

Completion means the defensible vendor-derived source implementations are integrated and statically reviewed. It does not mean generated-IP acceptance, HDL elaboration, compiled functionality, timing closure or hardware qualification.

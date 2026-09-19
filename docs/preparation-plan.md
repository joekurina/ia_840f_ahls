# IA-840F AHLS/OFS source-preparation plan

The user's explicit correction selects **Altera AHLS**, not the Intel oneAPI compiler or runtime. See [current scope](ahls-scope.md). No configuration, compilation, generation, tests, workstation access, installation, programming or Git publication is authorized.

## 1. Reconcile the source project

Update README and lock metadata without changing donor commits or removing reference code. Preserve prior oneAPI standard/USM work as reference only. Retain historical receipts and experimental archives. Identify old reports as superseded in scope rather than erase their findings.

## 2. Establish the AHLS boundary from real sources

Inspect the local AHLS handbook and official samples plus OFS PIM/tutorial implementations. Record exact source hashes/paths and interface responsibilities under `afu/ahls/` and `docs/ahls-integration.md`. Identify generated component metadata, invocation/CSR, memory-master, streaming and clock/reset boundaries. Do not invent generated port names, fixed widths, or a common register map unsupported by actual output metadata.

No application accelerator is selected by this board project. Do not resume the paused CKKS migration. A reusable integration contract must distinguish general board services from component-specific ports/addresses and generated artifacts.

## 3. Continue the real FIM port

Preserve vendor AGFB027R25A2E2V, two mixed-format DDR4 channels, PCIe topology/IDs/apertures, BMC and pin assignments. Audit modern OFS source/IP schemas against vendor settings. Make only evidence-backed source corrections and refresh affected provenance hashes. Keep gates closed. Document unresolved exact parameters/port mappings instead of guessing development-kit presets.

## 4. Keep transport requirements separate

Use actual OFS/PIM interfaces for host memory, MMIO and local memory. AHLS memory-master ports are hardware bus masters, not an automatic PC runtime. Host DMA addresses require real registered device-visible mappings later. Kernel-to-kernel pipes, external streams and CPU transport are separate contracts. Preserve existing DMA references without asserting that ordinary DDR DMA supplies a stream endpoint or that oneAPI USM exports carry across unchanged.

## 5. Static integration review

Read/hash/parse/diff only: ensure lock role metadata reflects AHLS, gates remain closed, source manifest hashes match, preserved references remain intact, new evidence links resolve and no fabricated generated source is presented as real. Keep historical oneAPI source checks distinct from active AHLS source checks. These are not compiler tests or HDL elaboration.

## Deferred qualification

AHLS/Quartus 26.1.1 and OFS/vendor-IP compatibility, generated IP/PR interfaces, RTL simulation, runtime behavior, timing closure and hardware qualification require separate authorization. No old QDB reuse or readiness relabeling.

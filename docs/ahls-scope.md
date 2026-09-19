# Active scope: Altera AHLS + OFS on IA-840F

## Decision and precedence

The user explicitly corrected the compiler target to **Altera AHLS** and authorized continued source preparation. This supersedes the earlier attachment's oneAPI compiler/runtime BSP requirement. The prior standard/USM source work is retained for board and implementation reference; it is not the active deliverable. All other restrictions remain: general-purpose board integration, real reference implementations, vendor hardware authority, no builds/setup/generation/tests/workstation/install/programming/commits/pushes.

The active route is **AHLS-generated component RTL → OFS AFU/PIM → IA-840F FIM**, with **OPAE/DFL host control/data access**. This is an integration architecture, not a claim that AHLS emits a complete PCIe runtime or that a generated component has been connected already.

This document and the current README/preparation plan take precedence over earlier oneAPI-oriented feature matrices, port reports and compiler-support findings. Historic evidence remains valid within its recorded scope.

## Toolchain evidence

The local archived handbook (absolute source path below) states that Quartus Prime Pro **26.1** is required for Agilex 7. Authoritative source is the [Altera HLS IP Gen handbook](https://docs.altera.com/r/docs/m615048/current/hls-ip-gen-handbook/1-altera-hls-ip-gen-handbook).

Local evidence path: `/home/joe/Documents/Obsidian/School/Thesis/AHLS/Handbook/02 - Getting Started with the Altera HLS IP Gen for Altera FPGA Development.md`, Quartus section around lines 41–54. Exact installed AHLS/Quartus bindings are not re-inspected; the workstation remains untouched. The 26.1 family requirement is not proof of whole-board OFS/vendor-IP compatibility with patch 26.1.1.

Pinned OFS 2025.1 documentation specifies Quartus 25.1. That source migration question remains relevant. Its warning that oneAPI is not validated, and oneAPI 2025.0's supported Quartus range, do **not** determine AHLS acceptance. No downgrade is needed merely to satisfy a compiler not being used.

## Current acceptance matrix

| Area | Active requirement | Not an assumed substitute |
|---|---|---|
| Board shell | Vendor-derived device/pins/DDR/PCIe/BMC migrated to pinned OFS | Development-kit presets with different hardware |
| Compiler | AHLS-generated RTL/IP integrated using its actual metadata/interfaces | oneAPI `-Xstarget=ia840f:...` board compilation |
| Host | OPAE discovery/MMIO and device-visible registered memory where needed | oneAPI MMD, SYCL runtime launch or application virtual pointers as DMA addresses |
| Memory | Explicit AFU bridges to board DDR and/or host memory | Automatic oneAPI standard/USM variant semantics |
| Streams | Actual AHLS external stream interfaces plus a separately evidenced transport binding | Generic PIM host channels or HSSI alone as CPU pipes |
| PR | Fresh matching shell/AFU platform contract later | Vendor Quartus 23.1 fitted database |
| Readiness | Source closure and explicit unresolved contracts | Gates or static hash success as functional proof |

## Preserved prior work

`oneapi-asp/`, the standard/USM XMLs, MMD selection fix, historical reports and experiments remain intact. No new active AHLS path should import their runtime merely because those directories exist. Reference DMA RTL or board settings may be reused only after their dependencies and interfaces have been reviewed explicitly.

No physical host stream ABI, application queue layout, accelerator kernel, component-specific address map or performance target is invented by this change.

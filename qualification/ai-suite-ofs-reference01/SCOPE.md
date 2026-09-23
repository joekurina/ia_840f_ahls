# FPGA AI Suite OFS example — read-only reuse research

User supplied the rel-26.1 OFS PCIe example and asked for web research into useful material for the IA-840F AHLS/OFS/OPAE project. This is a new evidence lead, not implementation/build/deployment authority.

Inspect official documentation, public source and release metadata for concrete reusable AFU, DMA, CDC, PR, runtime or FIM/timing material. Distinguish package availability from inspected source; distinguish the example's supported boards and release matrix from our IA-840F. Preserve the selected stack and both16GiB DDR instances. No vendor installs, remote commands, hardware actions, project-source edits, or copying development-kit images/settings.

Current Work18 baseline: Quartus26.1.1, AGFB027R25A2E2V, P-Tile Gen4-capable x16 with expected host Gen3x16, two16GiB x64DDR4 channels, UART/HPS absent. AHLS-generated RTL in OFS/PIM AFU, real OPAE host path; not an OpenVINO application or oneAPI runtime BSP. FIM donorOFS2025.1, examplesOFS2026.1 selected. Work18 native compilation completedrc0 but EMIF1hold−0.004ns persists on vendor-forced HyperRegister→UFI→PHY; no qualified image. Exact register-retiming restriction and Fitter-only10ps margin showed no measured closure. Existing historical diagnostics/results remain immutable. Research may identify new leads but must not assert a fix from another board/IP/version.

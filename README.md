# IA-840F OFS / Altera AHLS source project

**Active target: Altera AHLS-generated RTL integrated into an OFS AFU through PIM, with OPAE/DFL host access. Not an Intel oneAPI compiler/runtime BSP. Source preparation in progress; not build-ready.**

The BittWare vendor platform remains the authority for device, pins, memory, PCIe identities/apertures, clocks/reset and management. Modern OFS provides reference infrastructure. No application-specific accelerator, fixed queue protocol or stream width is imposed.

## Active layout

- `sources.lock.json`: exact donor pins and source-only policy; Quartus Pro **26.1.1** remains intended.
- `ofs-agx7-pcie-attach/`: pinned `ofs-2025.1-1` FIM and its FIM-common dependency.
  - `syn/board/ia840f/`: board configuration, source manifest and closed gates.
  - `src/board/ia840f/`: vendor-derived board RTL and modern OFS adaptations.
  - `ipss/ia840f/`: retained board IP references; migration remains incomplete.
- `ofs-platform-afu-bbb/`: PIM donor, for AFU-side host/MMIO/local-memory integration.
- `examples-afu/`: actual OFS reference implementations, not automatically working IA840F designs.
- `docs/ahls-scope.md`: corrected requirements and documentation precedence.
- `docs/preparation-plan.md`: current source-only work sequence.

The AHLS AFU interface contract is recorded in [afu/ahls/integration-contract.json](afu/ahls/integration-contract.json), with [source evidence and bridge requirements](docs/ahls-integration.md). It is descriptive, not executable configuration; no generated component ports or completed wrapper are claimed. See [AHLS source handoff](docs/ahls-source-handoff.md) and [FIM dependency review](docs/fim-ahls-review.md) for the latest results.

## Preserved reference material—not active runtime dependencies

`oneapi-asp/` retains the prior standard/USM source candidate and reusable reference implementations. It is not the AHLS compiler target, host runtime, or acceptance criterion. No oneAPI MMD/runtime dependency is required by the new project direction. Existing files and gates are preserved rather than deleted.

`afu/hostpipe_csr/`, `interfaces/dma_hostchannel/`, and `experiments/asp-baseline-separation/` are historical research. Neither oneAPI hostchannel APIs nor USM labels establish AHLS physical host streaming or shared-memory support.

The prior `docs/source-preparation-report.md`, `docs/feature-matrix.md`, `docs/asp-port.md` and `docs/upstream-baseline-review.md` record the earlier oneAPI evaluation. Their compiler compatibility warnings do **not** block the selected AHLS route. See `docs/ahls-scope.md` for current acceptance criteria.

## Board facts and remaining integration

Vendor evidence identifies **AGFB027R25A2E2V**, one discrete DDR4 channel plus one RDIMM channel, each 16 GiB, and Gen4 x16 PCIe with PF0/VF0 AFU and PF1 BMC. Preserve the actual selected IP/routing evidence rather than stale PF3 comments. See [board evidence](docs/fim-port.md) and [modernization source review](docs/fim-modernization-review.md).

Unresolved contracts include modern mixed-memory presets/ports, PF1 PCIe apertures and identity, BMC IP migration/reset/CDC, clocks and PR floorplan, and the actual AHLS component-to-PIM boundary. A fresh matching PR template is required later; the vendor fitted QDB is not the new platform.

## Toolchain

AHLS documentation requires **Quartus Pro 26.1 for Agilex 7**. This supports the selected toolchain family, but does not by itself qualify patch 26.1.1 with the pinned OFS FIM (documented for 25.1) or old BittWare IP. The workstation installation has not been inspected in this task. No downgrade to an older oneAPI-compatible stack is requested or applied.

## Execution boundary

**No builds, configure/setup flows, IP generation, simulation/tests, workstation access, installation, programming, commits or pushes.** Board-local gates remain closed and cannot establish readiness by themselves. Direct invocation of untouched upstream scripts is also unauthorized.

Original vendor and sibling donor repositories remain read-only. Existing static inventory utilities inspect source/XML/hash consistency; their prior ASP results are historical evidence, not AHLS integration qualification. No compiler-generated or hardware-validated support is claimed.

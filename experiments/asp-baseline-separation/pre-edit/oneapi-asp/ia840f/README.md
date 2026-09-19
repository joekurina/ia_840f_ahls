# IA840F source-only ASP port

Based on upstream oneapi-asp `1af2ca74c452cb6ebbf54beb86e758e53489e826`,
using the current N6001 layout, not old generated BSP outputs.

- `ofs_ia840f`: local-memory/DMA source configuration (default).
- `ofs_ia840f_usm`: same plus upstream USM path.
- FPGA: `AGFB027R25A2E2V`; two 16-GiB DDR4-2666 banks.
- Host pipes: **not implemented or advertised**. HSSI/I/O variants omitted.
- All provided setup/build entrypoints are intentionally locked. Do not run them.

Read [`../../docs/asp-port.md`](../../docs/asp-port.md) for provenance,
UUIDs, source changes, blockers, and the requirements for future authorization.
No compiler, configure, IP generator, simulation, test, or hardware run has
qualified this port. Quartus 26.1.1 compatibility is unverified.

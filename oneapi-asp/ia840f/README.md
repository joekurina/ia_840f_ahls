# IA840F source-only ASP port

General-purpose standard and USM source baseline derived from BittWare's
`old_bsp/ia-840/IOFS_BUILD_ROOT/oneapi-asp/ia840f`. The vendor board identity,
memory geometry, UUIDs and variant split are authoritative. Current common
implementation and interface naming come from OFS oneapi-asp
`1af2ca74c452cb6ebbf54beb86e758e53489e826` (N6001 is an interface/layout
reference, not a substitute board). No old generated BSP outputs are imported.

- `ofs_ia840f`: local-memory/DMA source configuration (default).
- `ofs_ia840f_usm`: same plus the reference USM path.
- FPGA: `AGFB027R25A2E2V`; two 16-GiB DDR4-2666 banks, backed by distinct
  discrete-DDR4 and RDIMM physical interfaces, not interchangeable devkit banks.
- No application-specific queues or streaming DMA hostchannel implementation.
  The earlier experiment is preserved under `../../experiments/asp-baseline-separation/`.
- Host pipes are **not advertised as qualified**. A reference runtime CSR path
  exists, but compiler/RTL/board integration remains unverified. Non-CSR DMA
  hostchannels and HSSI/I/O variants are not supplied by this baseline.
- All provided setup/build entrypoints are intentionally locked. Do not run them.

Read [`../../docs/asp-modernization-review.md`](../../docs/asp-modernization-review.md)
for the baseline audit and hash-bound preservation evidence, and
[`../../docs/asp-port.md`](../../docs/asp-port.md) for the earlier port details
and requirements for future authorization.
No compiler, configure, IP generator, simulation, test, or hardware run has
qualified this port. Quartus 26.1.1 compatibility is unverified.

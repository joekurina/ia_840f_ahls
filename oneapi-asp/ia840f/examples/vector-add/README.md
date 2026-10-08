# Vector-add — IA-840F AHLS2026.1 native BSP build

The original buffer/shared-USM samples are preserved. CMake adapts only the
Intel-to-Altera FPGA header/selector dialect into build-local source. The full
CPU oracle checks every output; the default size is10,000 and the sample display
requires at least three elements.

Use the [LaTeX support manual](../../../../docs/ia840f-asp2026-manual/IA-840F_OFS2026.1_AHLS_Support_Guide.pdf)
and [public release notes](../../../../docs/releases/ia840f-asp-v1.0.0.md).
The native hardware link selects the prepared board with
`-Xstarget=<prepared-BSP>:<variant>` and `-Xsbsp-flow=<flow>`; the BSP owns clock
handling. `AHLS_PREBUILT_ARCHIVE` imports an unchanged verified program through
the real AHLS linker. It is not permission to discard source changes.

A Git checkout alone does not contain the prepared BSP, matching static/PIM
netlists, prebuilt compiler archives, licensed AHLS/Quartus tools or runtime
binaries. Obtain those prerequisites before running the manual's commands.
No device operation is authorized by this source publication.

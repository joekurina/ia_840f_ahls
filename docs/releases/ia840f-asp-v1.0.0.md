# IA-840F ASP v1.0.0

AHLS2026.1.0 / Quartus Prime Pro26.1.1 / OFS2026.1 / OPAE2.14.0-3.

## Qualified hardware matrix

| Variant | Flow | Operating-clock metadata | Full comparisons | Native exit |
|---|---|---:|---:|---:|
| ofs_ia840f | afu_flat |618MHz|10,000|0|
| ofs_ia840f | afu_flat_kclk |490MHz|10,000|0|
| ofs_ia840f_usm | afu_flat |592MHz|10,000|0|
| ofs_ia840f_usm | afu_flat_kclk |479MHz|10,000|0|

All40,000 comparisons passed with the final private OPAE core/plugins and
matching MMD/MPF. The hardware images and native SYCL fat binaries were unchanged
for the software upgrade. Four packaged prebuilt imports reproduced the complete
qualified executables byte-for-byte, and relocated loader/Python checks passed.

## Included

- Maintained board-local RTL/MMD overrides and native AHLS BSP backend.
- Migrated buffer/shared-USM vector-add CMake example.
- Final OPAE2.14.0-3 qualification and package verification records.
-31-page LaTeX support manual, its source bundle and required compatibility patches.

See [board source](../../oneapi-asp/ia840f/README.md),
[qualification](../../qualification/asp26-release01/README.md) and
[manual](../ia840f-asp2026-manual/IA-840F_OFS2026.1_AHLS_Support_Guide.pdf).

## External inputs and retained limits

A clean checkout supplies source and evidence, not the prepared BSP/netlist export,
licensed AHLS/Quartus tools or compiled runtime/programming-image bundle. Obtain
those inputs before running the manual's build/programming procedures. The full
qualified vendor-style archive remains at the recorded workstation path; its SHA256
and complete verification are in ARCHIVE-VERIFIED683.json. Public release assets
exclude licensed runtime binaries and programming images under repository policy.

The disclosed configuration-only OPAE module lookup patch makes private plugin
selection relocatable; programming functions and FPGA logic are unchanged.
The exact VF pending-before-FLR warning remains, with lifecycle_clean=false.
MHz values are STA/GBS metadata, not throughput or live-frequency measurements.
Earlier optional probes are historical and are not relabeled as rerun under this
runtime. Arbitrary kernels, universal reset recovery, MTBF and cross-distribution
compatibility are not claimed. Existing CAPS03 releases/tags remain unchanged.

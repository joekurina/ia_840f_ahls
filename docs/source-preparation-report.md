# IA-840F source-preparation report

## Status

A vendor-based, general-purpose standard/USM source candidate is organized under `new/`. The audit, experimental separation and defensible source corrections are complete for this pass. **The overall complete-source-port goal is not yet met:** modern board IP presets/interface contracts and a supported toolchain combination remain unresolved. The project is not build-ready, compiled, functional, timing-closed or hardware-qualified. Closed gates do not substitute for missing integration.

## Actual changes in this modernization pass

1. **FIM source correction:** `ofs-agx7-pcie-attach/src/board/ia840f/bwbmc_st2mm.sv` now uses pinned modern OFS CDC and TX skid implementations instead of undefined legacy `pcie_axis_cdc_fifo`. Vendor depth/threshold and explicit endpoint RX reset ownership are retained. The [FIM review](fim-modernization-review.md) explains the exact source reference and unresolved FLR behavior. Its board `source_manifest.json` binds the new bytes; hostpipe wording was also corrected to conditional scope without opening readiness.
2. **General-purpose ASP separation:** restored five common files to pinned upstream; removed eight experimental files from active paths only after preserving their complete bytes. Kept IA840F MMD identity selection, standard/USM configurations and nine board-local gates. [ASP review](asp-modernization-review.md) lists every affected active path. [Changed-file inventory](../experiments/asp-baseline-separation/changed-files.json) enumerates worker additions/modifications/deletions; [preservation manifest](../experiments/asp-baseline-separation/preservation-manifest.json) binds 44 saved files.
3. **Upstream research:** added [upstream-baseline-review.md](upstream-baseline-review.md) and `reference/modernization-upstream/`, containing official releases/tags, dependency observations, source snapshots and compiler/runtime evidence. No checkout pins or intended toolchain were switched.
4. **Top-level reconciliation:** updated `README.md`, `sources.lock.json`, this report, `docs/preparation-plan.md`, and [feature-matrix.md](feature-matrix.md). Marked `docs/host-pipes.md`, the three `docs/dma-hostchannels-*.md` documents and `interfaces/dma_hostchannel/transport-contract.md` as historical experiments. Their original source remains preserved; neither the standalone CSR example nor the custom ABI is active BSP functionality.
5. **Static inventory:** extended `tools/source_inventory.py` with standard/USM device, memory and XML-gate checks; historical CSR research is no longer a required BSP component. Added `tools/modernization_static_review.py` for archive/evidence hashes, exact upstream restoration, active experiment exclusion, retained ASP gate hashes, donor cleanliness and whitespace inspection. Updated `source-inventory.json` and added `modernization-static-review.json`.

No new application protocol, DMA engine, runtime API or guessed modern IP preset was introduced.

## Checks actually performed

The final parent review ran only the two reviewed Python source-inspection utilities, read-only Git operations, XML/JSON parsing, source comparison and hashing. [Machine-readable receipt](../modernization-static-review.json):

- Source inventory: **pass**, zero errors; all **86 FIM manifest entries** match.
- Both variants parsed with the IA840F model and **two 16-GiB bank declarations**. Only USM declares host/shared memory. All declared generation/synthesis actions remain source-only stops.
- **44 preserved experiment files** independently verified by size/SHA-256.
- **64 retained upstream research files** independently verified by size/SHA-256.
- Five restored common ASP files independently compared byte-for-byte against the pinned Git commit.
- No custom hostchannel dependency tokens remain in the inspected active common hardware/host trees.
- **Nine ASP gate files** remain byte-identical to preserved pre-edit bytes.
- All four original donor Git working trees remain clean; candidate `git diff --check` succeeded.
- No compiled artifacts in the inspected board-specific candidate paths. This is a bounded inventory, not a claim about every upstream reference directory.
- The ASP worker's separately retained receipt reports **145 passing static checks** covering board/reference declarations and preservation. The parent independently rechecked the key archive/restoration/gate invariants; it did not reclassify those checks as executable tests.

These checks establish source consistency only. They do not execute HDL/Tcl, prove complete module closure, elaborate IP, validate runtime symbols, measure performance or inspect hardware.

## Findings that prevent an honest completion claim

### Toolchain/source baseline

The latest named Agilex 7 FIM release, **ofs-2025.1-1**, explicitly says oneAPI is not validated and points oneAPI users to the older release. The selected newest donor heads therefore remain an unqualified integration candidate. The documented coordinated comparison set is:

- FIM `ofs-2024.2-1`: `ab9d0728a68caa353d720c837237f54eb88db6f8`
- PIM `ofs-2024.2-1`: `e0251f7d00f37176df7f63c15fd9ad4ab609137e`
- ASP `ofs-2024.2-2`: `76ba584312fcc1e08c76407f26b2034d315fd53e`
- Quartus Pro 24.1 with patches 0.18, 0.26 and 0.02iofs.

That is reference evidence, not a silent downgrade or automatic IA840F qualification. Requested **26.1.1** remains intended but outside oneAPI 2025.0's documented Quartus **22.3–24.2** range. The latest FIM names **25.1**. Official citations and caveats are in the [upstream review](upstream-baseline-review.md).

### Board contracts

- Modern `mem_ss` must express the actual discrete-DDR4/RDIMM combination with known group/port/refclk/OCT mapping. The legacy full settings are retained, but the new generated contract is not established.
- Modern PCIe configuration must preserve BittWare identity, disabled PF1 BAR0, BAR2 width 28 and BAR4 width 14. Inspected generic OFSS controls do not provide the needed complete configuration.
- Retained BMC Qsys/custom IP version requirements, outstanding-transaction/FLR policy, reset/CDC, clocks, SDC hierarchy and PR floorplan remain unresolved.
- A fresh matching PR template/interface contract must be generated only during a separately authorized stage; the old fitted QDB is not reused.

The existing pending preset names intentionally prevent accidental use of a wrong development-kit preset. They are explicit gaps, **not completed configurations**. Further progress requires authoritative modern board/IP configuration evidence and a decision on the supported toolchain/source route; execution remains prohibited until separately authorized.

### Host pipes

Ten relevant reference board XMLs and associated implementation sources were inspected. No complete applicable PCIe oneAPI hostpipe BSP path was established. N6001's actual stream path is UDP/HSSI; generic host channels, DMA and USM are not replacements. CSR-backed pipes have real runtime source support but no qualified reference-board/compiler integration was established. Consequently no hostpipe support is advertised and no custom replacement was invented.

## Execution boundary

No builds, configure/setup flows, IP generation, simulation, executable tests, vendor-tool execution, workstation access, installation, programming, commits or pushes. Original vendor/reference inputs remain read-only. All edits and evidence for this pass are beneath `new/`. No old generated image/QDB/library was promoted into the active source baseline.

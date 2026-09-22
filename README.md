# IA-840F OFS / Altera AHLS source project

**Active target: Altera AHLS-generated RTL integrated into an OFS AFU through PIM, with OPAE/DFL host access. Not an Intel oneAPI compiler/runtime BSP. W13 FIM and sanctioned persona artifacts exist; timing and hardware acceptance remain incomplete.**

## Current qualification checkpoint

[GOAL-PROMPT.md](GOAL-PROMPT.md) governs execution and safety. The
[source-side continuation report](qualification/source-resume-01/REPORT.md)
and [feature matrix](docs/feature-matrix.md) distinguish actual results from
blocked hardware checks. No FPGA operation was performed during that continuation.

The separate offline gates now have **spec PASS and quality APPROVED**;
[parent acceptance](qualification/offline-milestone-review-01/ACCEPTANCE.md)
records exact review bindings and the final fresh test receipts. Bound reports
retain their earlier pending-review wording as immutable history.

- Source-proven AFU path: **PF0 VF0 BAR0**, not the PF0 protocol-checker window.
  See the [host access map](qualification/ahls-host-offline-01/HOST-ACCESS-MAP.md).
- The additive exact-numerical host test passed its inert C/API suites and
  compiled/linked against native OPAE; the native binary was **not executed**.
- [UART-absent source correction](qualification/dfl-uart-fix-02/ACCEPTANCE.md)
  is independently accepted: only the dummy feature ID changes from 0x24 to
  the vendor's ID 0. UART/HPS remain absent; chain links and clocks are retained.
  Native build, timing and live behavior are not qualified by this source gate.
- [Udev successor02](qualification/dfl-udev-fix-02/REPORT.md) narrows the
  rejected candidate's board scope; 21 inert tests pass. It is not installed
  or native/live-verified; independent approval covers staged/inert scope only.
- W13/persona timing failures, live OPAE, DDR, host transfers, PR, sustained
  operation and final durable-boot acceptance remain unresolved.

## Evidence and repository policy

Project-requested qualification reports, finite test sources, commands,
results and SHA256 inventories are retained under `qualification/<run-id>/`.
Files **over 2 MB stay local-only**, excluded by the applicable `.gitignore`
and SHA256-referenced by reports; compact lossless evidence archives may be
tracked when under the cap. Bitstreams, licensed binaries/installers, license
files, secrets, compiler build directories and internal agent transcripts are
not repository deliverables. Preserve failed attempts and accepted provenance;
commit only independently reviewed milestones. This project-local evidence
policy is explicitly required by the goal, not permission to scatter internal
agent scratch files through the repository.

The BittWare vendor platform remains the authority for device, pins, memory, PCIe identities/apertures, clocks/reset and management. Modern OFS provides reference infrastructure. No application-specific accelerator, fixed queue protocol or stream width is imposed.

## Historical source-preparation layout

The source-only status claims in this section describe the earlier preparation
stage. Use the current checkpoint above and the feature matrix for execution
status; old handoffs do not authorize rebuilding or hardware access.

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

## Historical execution boundary — superseded by GOAL-PROMPT.md

The original source-only restriction is superseded for resumed project work.
Ordinary in-scope source correction, offline tests, justified generation/builds
and reviewed milestone commit/push are authorized by GOAL-PROMPT.md. Live
device access, system-rule activation, programming and disruptive recovery
remain separately gated. Never rebuild unchanged artifacts, bypass a native
source-bound guard, or treat successful compilation as live authorization.

Original vendor and sibling donor repositories remain read-only. Existing static inventory utilities inspect source/XML/hash consistency; their prior ASP results are historical evidence, not AHLS integration qualification. No compiler-generated or hardware-validated support is claimed.

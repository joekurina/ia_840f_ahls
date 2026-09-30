# IA-840F OFS / Altera AHLS source project

## IA-840F CAPS03 release instructions

Release **`ia840f-caps03-v1.1.0`** includes the corrected AHLS GettingStarted
flow and detailed instructions for the FIM/PIM/AFU hardware path. Start with the
[release notes and checkout command](docs/releases/ia840f-caps03-v1.1.0.md), then
choose the appropriate workflow:

1. [Static FIM and PIM platform: architecture, source pins, preparation and export](docs/ia840f-fim-pim.md).
2. [CAPS03 AFU: AHLS generation and native CMake synthesis, fit, timing and assembly](docs/ia840f-build.md).
3. [Deploy the FPGA image: BittWare SDK flashing and activation](docs/ia840f-sdk-flashing.md).
4. [Run the AFU: OPAE host build, DFL/VFIO setup, numerical checks and lifecycle](docs/ia840f-run.md).
5. [Run the standalone AHLS tutorials: CPU/emulation, RTL simulation, reports and characterization](examples/ahls/README.md).

The FIM and AFU run as configured FPGA logic; PIM is their interface/build
infrastructure, not a separate executable. The actual card test uses the OPAE
host. Tutorial `.fpga_sim` programs use a simulator, while their `.fpga` outputs
are isolated-IP characterization products—not card executables or flash images.

Use `bw_agilex_flash_programmer` with the accepted SDK-compatible RPD; JIC is
not writer input and JTAG is not this project's flash route. The release retains
the accepted CAPS03 source/evidence baseline and its disclosed limitations.
A clean clone does not include the prepared full-image workspaces, generated
build databases, licensed tools or programming images; each guide identifies
its external prerequisites. The existing `ia840f-caps03-v1.0.0` tag is unchanged.

> Scope correction: the overall hls-samples 2026.1.0 goal is incomplete and reopened.
> The CAPS03 acceptance covers only the DDRIP sample integration and supporting
> hardware. The claim that it completed the release-wide goal was incorrect.
> See [active correction](qualification/hls-samples-2026.1.0-01/CORRECTION.md).

**Active target: Altera AHLS-generated RTL integrated into an OFS AFU through PIM, with OPAE/DFL host access. Not an Intel oneAPI compiler/runtime BSP. The Work21-based CAPS03 memory-HLS integration and scoped hardware qualification are complete, with the exact user-accepted lifecycle erratum exception.**

The selected build uses Quartus 25.1 at the unchanged 3.000 ns application-clock
target, and the final multi-corner STA passes it: all 913 numeric records are
nonnegative (worst setup slack +0.213 ns, zero negative slacks, TNS 0.000), with
vendor FIFO pointer-skew constraints verified across all five corners. See
[bounded physical acceptance](qualification/caps03-persona01/PHYSICAL-ACCEPTANCE01.md)
and [assembly acceptance](qualification/caps03-persona01/ASSEMBLY-ACCEPTANCE01.md).

**"Design Closure: FAIL" is a Quartus Design-Assistant panel, not a timing
failure.** It retains the disclosed LNT-30010 reset-fanout finding (1735 CLRN /
981 SCLR / 513 ENA loads on the joined reset), reserved JTAG/BMC unconstrained
ports, and the earlier DRC items; none produced a failing timing path, and reset
recovery/removal timing is genuinely met (+0.592 / +0.155 ns). Numerical hardware
results were accepted with these findings disclosed, not waived.

The [SDK deployment milestone](qualification/caps03-flash01/ACCEPTANCE48.md)
separately accepts full-input flash readback/comparison, observed BMC Off/On,
and the deployment reboot with cached static-FME identity. It does not infer
numerical or application-lifecycle acceptance from programming success.

## AHLS GettingStarted tutorials

The original `fpga_compile` PART1–4, `fast_recompile`, and `fpga_template`
samples are imported under [examples/ahls](examples/ahls/README.md), pinned to
HLS IP Gen sample release 2026.1.0. The setup guide documents native CMake build/run
commands, the verified Agilex 7 LSU family correction, and reported component Fmax.
The standalone flow deliberately optimizes at 1000 MHz; its expected timing warnings
are not an application timing-failure gate. See the [corrected results](qualification/ahls-getting-started-fix01/RESULT.md).
These standalone programs are not IA-840F card executables; they do not replace
the accepted CAPS03 deployment.

## Completed memory-HLS qualification

The [final acceptance](qualification/caps03-final01/ACCEPTANCE.md) records the
working image and exact scope: SDK flash/readback and BMC/reboot activation,
OPAE numerical copyback, 34 repeated/boundary cases, 65,536-integer bulk HLS,
independent/isolation/sustained DDR, walking-bit follow-up and both complete 16 GiB
DDR apertures. All actual-result reviews are consumed; six normal application
lifecycles ended with native 0 and empty postflight ownership.

Only the exact pending-before-FLR warning is accepted: teardown is not warning-free,
original live21 raw false/outer 1 remain, and the 34-case run's outer status is unknown.
Full-capacity runtime was 78.38 minutes—an inefficient harness result, not DDR bandwidth.
General cold/PR/stopped-clock/active-failure recovery and every other upstream HLS
kernel are not claimed qualified. See [limits](qualification/caps03-final01/ACCEPTANCE.md#exact-exception-and-retained-limits).

The [maintained goal](GOAL-PROMPT.md) separates this accepted CAPS03 integration
from the incomplete release-wide HLS sample work. That broader work remains
stopped except for the explicitly requested [GettingStarted subset](examples/ahls/README.md).
Neither documentation publication nor these standalone compiler/simulator checks
authorize another CAPS03 FPGA operation.
[Publication evidence](qualification/caps03-publication01/CURRENT.md)
identifies the separately accepted commits. The local accepted SOF path and SHA256
are in [the final artifact record](qualification/caps03-final01/ACCEPTANCE.md#retained-working-artifact).

## Repository policy

Project-requested qualification reports, finite test sources, commands,
results and SHA256 inventories are retained under `qualification/<run-id>/`.
Files **over 2,000,000 bytes stay local-only**, excluded by the applicable `.gitignore`
and SHA256-referenced by reports. Generated launchers with embedded source/binary
payloads and raw transport archives remain local-only at any size; payload-free
metadata retains their exact sizes and hashes. Bitstreams, licensed binaries/installers, license
files, secrets, compiler build directories and internal agent transcripts are
not repository deliverables. Preserve failed attempts and accepted provenance;
commit only independently reviewed milestones. This project-local evidence
policy is explicitly required by the goal, not permission to scatter internal
agent scratch files through the repository.

The BittWare vendor platform remains the authority for device, pins, memory, PCIe identities/apertures, clocks/reset and management. Modern OFS provides reference infrastructure. No application-specific accelerator, fixed queue protocol or stream width is imposed.

## Historical sections (superseded context, preserved)

The sections below describe the earlier source-preparation stage and its
predecessor scopes. Use [GOAL-PROMPT.md](GOAL-PROMPT.md) for execution and
safety, the current checkpoint above for status, and the
[feature matrix](docs/feature-matrix.md) to distinguish actual results from
blocked hardware checks. Old handoffs do not authorize rebuilding or hardware
access; no FPGA operation was performed during that continuation.

### Historical source-side checkpoint

The [source-side continuation report](qualification/source-resume-01/REPORT.md)
records the resumed source work. The separate offline gates have **spec PASS and
quality APPROVED**;
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
- [Work14 compile package](qualification/fim-build-14/COMPILE-PACKAGE-ACCEPTANCE.md)
  passed independent reviews; its [native compile completed with exit 0](qualification/fim-build-14/RESULT.md)
  and successful assembly. [Independent result review is consumed](qualification/fim-build-14/RESULT-ACCEPTANCE.md):
  timing remains failed (−0.004 ns EMIF1 hold, an unconstrained PCIe divider,
  and unresolved constraint/CDC findings).
  Work14 has a new FIM interface UUID, so the W13 persona is not a matching
  PR artifact. W13 is preserved; no hardware deployment occurred.
- [Udev successor02](qualification/dfl-udev-fix-02/REPORT.md) narrows the
  rejected candidate's board scope; 21 inert tests pass. It is not installed
  or native/live-verified; independent approval covers staged/inert scope only.

### Historical source-preparation layout

The source-only status claims in this section describe the earlier preparation
stage; the vendor-tool and board layout items below are superseded by the
delivered CAPS03 integration above.

- `sources.lock.json`: exact donor pins and source-only policy. **Stale:
  Quartus Pro 26.1.1 is no longer the intended toolchain — the delivered
  platform uses Quartus Prime Pro 25.1.0 Build 129.**
- `ofs-agx7-pcie-attach/`: pinned `ofs-2025.1-1` FIM and its FIM-common dependency.
  - `syn/board/ia840f/`: board configuration, source manifest and closed gates.
  - `src/board/ia840f/`: vendor-derived board RTL and modern OFS adaptations.
  - `ipss/ia840f/`: retained board IP references; migration completed in the
    delivered CAPS03 platform.
- `ofs-platform-afu-bbb/`: PIM donor, for AFU-side host/MMIO/local-memory integration.
- `examples-afu/`: actual OFS reference implementations, not automatically working IA840F designs.
- `docs/ahls-scope.md`: corrected requirements and documentation precedence.

The AHLS AFU interface contract is recorded in [afu/ahls/integration-contract.json](afu/ahls/integration-contract.json), with [source evidence and bridge requirements](docs/ahls-integration.md). It is descriptive, not executable configuration. See [AHLS source handoff](docs/ahls-source-handoff.md) and [FIM dependency review](docs/fim-ahls-review.md).

### Preserved reference material—not active runtime dependencies

`oneapi-asp/` retains the prior standard/USM source candidate and reusable reference implementations. It is not the AHLS compiler target, host runtime, or acceptance criterion. No oneAPI MMD/runtime dependency is required by the project direction. Existing files and gates are preserved rather than deleted.

`afu/hostpipe_csr/`, `interfaces/dma_hostchannel/`, and `experiments/asp-baseline-separation/` are historical research. Neither oneAPI hostchannel APIs nor USM labels establish AHLS physical host streaming or shared-memory support.

The prior `docs/source-preparation-report.md`, `docs/feature-matrix.md`, `docs/asp-port.md` and `docs/upstream-baseline-review.md` record the earlier oneAPI evaluation. Their compiler compatibility warnings do **not** block the delivered AHLS route. See `docs/ahls-scope.md` for acceptance criteria.

### Board facts

Vendor evidence identifies **AGFB027R25A2E2V**, one discrete DDR4 channel plus one RDIMM channel, each 16 GiB, and Gen4 x16 PCIe with PF0/VF0 AFU and PF1 BMC. See [board evidence](docs/fim-port.md) and [modernization source review](docs/fim-modernization-review.md). The earlier source-preparation open items (mixed-memory presets/ports, PF1 apertures/identity, BMC IP migration, clocks, PR floorplan, AHLS-component-to-PIM boundary) were resolved by the delivered CAPS03 integration; the vendor-fitted QDB is not the delivered platform.

### Historical toolchain planning

AHLS documentation requires **Quartus Pro 26.1 for Agilex 7** as the documented
compiler baseline; the delivered platform uses Quartus Prime Pro **25.1.0 Build
129** with HLS IP Gen 2026.1.0, and the installed compiler emits a retained
mixed-version warning. Do not silently switch installations to hide it. No
downgrade to an older oneAPI-compatible stack was requested or applied.

### Historical execution boundary — superseded by GOAL-PROMPT.md

The original source-only restriction is superseded for resumed project work.
Ordinary in-scope source correction, offline tests, justified generation/builds
and reviewed milestone commit/push are authorized by GOAL-PROMPT.md. Live
device access, system-rule activation, programming and disruptive recovery
remain separately gated. Never rebuild unchanged artifacts, bypass a native
source-bound guard, or treat successful compilation as live authorization.

Original vendor and sibling donor repositories remain read-only. Existing static inventory utilities inspect source/XML/hash consistency; their prior ASP results are historical evidence, not AHLS integration qualification.

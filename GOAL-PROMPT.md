# IA-840F goal and current handoff

## Goal

Deliver a functional **OPAE + DFL FIM and AFU for the BittWare IA-840F**, using the
validated **Quartus Prime Pro 25.1** toolchain. The primary implementation references
are **[OFS Agilex 7 PCIe Attach, tag `ofs-2025.1-1`](https://github.com/OFS/ofs-agx7-pcie-attach/releases/tag/ofs-2025.1-1)**
and the **BittWare-supplied IA-840F oneAPI BSP**. The
[FPGA AI Suite OFS example](https://altera-fpga.github.io/rel-26.1/ed-ai-suite/agilex7/ofs/ofs_pcie_getting_started)
is a supplementary integration reference, not permission to expand scope.
Get the applicable [HLS samples tagged 2026.1.0](https://github.com/altera-fpga/hls-samples/releases/tag/2026.1.0)
working through the real OPAE host path, beginning with the existing memory-capable
vector-add kernel. Correct numbers on the card, not a debug subsystem, are the objective.

Success includes the selected image booting from QSPI after a power cycle, correct
DFL/OPAE discovery and MMIO, both DDR channels passing the
[hardware validation gate](docs/ddr-hardware-validation-gate.md), verified transfers
in both directions, numerical comparisons after copyback, and sustained
operation with normal teardown under the exact user-accepted erratum exception. Reuse existing evidence where it applies to the exact image;
do not repeat completed bring-up as a default sequence. **The overall goal is INCOMPLETE.**
Joe explicitly reaffirmed the entire HLS samples release2026.1.0. The earlier
CAPS03 completion covered only the adapted DDR-host vector-add kernel and its
supporting hardware qualification, not the requested sample collection.
[Correction and active sample work](qualification/hls-samples-2026.1.0-01/CORRECTION.md).

**DO NOT DO ANYTHING THAT COULD CAUSE THE WORKSTATION TO HANG.** Protecting the
workstation, its data, and remote access takes precedence over progress.

## Scope and authority

- **Do not add features or infrastructure absent from the two primary reference
  implementations.** This is a port/integration task, not a new platform design.
  Reuse their implemented mechanisms; limit adaptation to the IA-840F board and
  required HLS/OPAE interface integration without inventing new subsystem behavior.
  A vendor FIFO underneath a novel custom protocol does not make that protocol
  reference-derived. Existing CAPS02 code is not an exception merely because it was
  already written. If a required behavior has no implementation counterpart in these
  references, report the gap and obtain Joe's scope decision before adding it.
- Pin source reasoning to `ofs-2025.1-1`, not a moving latest branch or another
  release. Its [release notes](https://github.com/OFS/ofs-agx7-pcie-attach/releases/tag/ofs-2025.1-1)
  specify Quartus 25.1 and explicitly say oneAPI was not validated with this release;
  they do not list IA-840F among the target boards. BittWare's BSP supplies the
  board-specific reference. Do not claim that the combined IA-840F/OPAE/HLS stack is
  vendor-validated or change the chosen toolchain/runtime because of that caveat.
- A request to edit, review, or display this prompt is documentation-only. It does
  not launch implementation, builds, tests, remote operations, commits, or deployment.
- When explicitly invoked to continue execution, work through the release-wide
  sample inventory below; one completed kernel is not the overall goal. Joe has
  explicitly renewed this work and approved in-scope iteration, including flashing and
  rebooting when justified; the hard safety boundary still applies. Do not ask again
  for blanket permission for safe ordinary source work.
- This is the **authoritative handoff**, replacing all earlier handoff/next-action
  instructions in the parent prompt, saved task lists, and qualification reports.
  Old reports remain evidence, not executable runbooks. In particular,
  `qualification/caps01-resume02/CURRENT.md` records the previous diagnostic route;
  its pending-review and next-query instructions are superseded by this prompt.
- Preserve original sources, accepted artifacts, failed results, and unrelated edits.
  Selecting a simpler additive candidate does not authorize deleting prior code.
- **Standing IA-840F flash rule (Joe's explicit correction): ALWAYS use the
  BittWare SDK flash writer `bw_agilex_flash_programmer`. It is the only flash
  route.** Do not repair, retry, or continue diagnosing JTAG. A JTAG target
  failure such as `Hardware not attached` triggers the SDK route, not JTAG
  recovery or another route-selection question. The prepared `caps03.jic` is
  file-only conversion evidence and is **not SDK-writer input**. Generate the
  SDK RPD from the exact accepted full-device SOF with Quartus25.1 and the
  recorded `MT25QU02G`/`ASX4`/`AGFB027R25A`/`bitswap=OFF` contract; the installed
  SDK reader reverses every input byte. Bind current management access and
  complete non-RSU layout/erase footprint before writing, preserving the current
  flash scheme rather than substituting an RSU user-slot update. Require the
  original native exit plus completed erase, program, readback and successful
  comparison by named phase. Then execute the already-approved BMC Off/On with
  separate readbacks and one normal workstation reboot. Conversion, programming,
  activation and numerical qualification remain distinct outcomes.
  [SDK lineage and writer contract](qualification/caps01-bwflash01/PROGRAM02-RESULT.md),
  [preserved pre-correction state](qualification/caps03-flash01/RECOVERY18.md).

## Current handoff — release-wide HLS samples in progress

The whole `hls-samples`2026.1.0 release is the active worklist, not only DDRIP.
Exact tag/HEAD is `0abae6d78af5daca3fe5d67e617ab037e58aff89`; donor checkout is clean.
[Active scope and correction](qualification/hls-samples-2026.1.0-01/CORRECTION.md).

Continue through the exact-release per-sample and per-variant inventory,
checking the latest local execution records before choosing the next stage.
Keep CPU execution, FPGA emulation, RTL generation, RTL simulation and real-card
execution separate. Reuse completed mode artifacts; do not count custom
qualification frontends or repeated runs as additional upstream samples.
CPU/emulator/report batches do not authorize incidental live hardware discovery.

Previously accepted CAPS03/DDR results remain valid only for that exact image and
sample; reuse them rather than resynthesizing or rerunning them. The earlier
[CAPS03 acceptance](qualification/caps03-final01/ACCEPTANCE.md) is a completed
submilestone, not authority to close this release-wide goal.

### Selected implementation

Use the existing application clock and accepted PIM crossings, finite expected
enabled-byte accounting and AW/W/B retirement at the additive bank shim. Read-only
completion CSRs replace the abandoned CAPS02 snapshot mailbox. Producer completion
and balanced responses establish the finite copyback rule; a common clock alone
is not a fence. The unchanged generated HLS and Work21 static shell were reused
([functional acceptance](qualification/caps03-completion01/ACCEPTANCE06.md)).

Actual changes are the additive completion monitor/MMIO guard, bank shim/reset
integration/AFU top under `afu/ahls_memory/`, CMake-native persona targets, and
additive host frontends plus finite tests under `src/host/` and
`tests/ia840f/caps03_host/`. The maintained top remains default-disabled;
`COMPLETION_SUPPORTED=1` belongs to the exact qualified build copy, not blanket
readiness for an arbitrary rebuild. CAPS02 `PUBLISH_SUPPORTED=0` stays unchanged.

### Completed results — reuse, never replay

- Quartus 25.1 synthesis, fit, final STA and assembly completed; bounded physical
  acceptance at the unchanged 3.000 ns target. Native Design Closure FAIL remains
  disclosed ([physical](qualification/caps03-persona01/PHYSICAL-ACCEPTANCE01.md),
  [assembly](qualification/caps03-persona01/ASSEMBLY-ACCEPTANCE01.md)).
- BittWare SDK full-input flash readback/comparison, independent BMC Off/On and
  workstation reboot accepted. This observed durable deployment is separate from
  the later AFU numerical proof ([deployment](qualification/caps03-flash01/ACCEPTANCE48.md)).
- Original OPAE/HLS case: nine signed results, 156 guard/padding bytes, six DMA
  descriptors, native 0 and empty postflight ownership
  ([numerical evidence](qualification/caps03-runtime01/NUMERICAL21.md)).
- Repeated/boundary:34 cases, 2,982 integers, 536 descriptors; actual-result review
  `deleg_103db8bc` accepted, consumed and published at
  `08a849bf09f4e44b625d2073367630a5af7576e7`
  ([acceptance](qualification/caps03-coverage01/ACCEPTANCE04.md)).
- Sampled DDR isolation/sustained: 2 GiB written/read per bank, 67,108,864 descriptors,
  590.093506230 s; walking follow-up 30 addresses/bank and120 descriptors accepted
  ([DDR](qualification/caps03-ddr01/ACCEPTANCE07.md),
  [walking](qualification/caps03-walk01/review04-consumed.json)).
- Bulk HLS: 65,536 integers, 262,144 result bytes + 128 DDR guard bytes, 8,324 descriptors,
  source-supported concurrent bank0-read/bank1-write functionality accepted;
  not a measured wire-overlap or bandwidth claim
  ([review](qualification/caps03-bulk01/review04-consumed.json)).
- Full capacity:both complete 16 GiB logical apertures written/read/compared,
  536,870,912 descriptors / 64 GiB traffic / 512 progress rows, native 0 / outer 0 and empty
  ownership. Actual-result review `deleg_25953609` accepted the remaining full
  aperture and combined [agreed DDR gate](docs/ddr-hardware-validation-gate.md)
  ([acceptance](qualification/caps03-full-ddr01/ACCEPTANCE16.md)).
- Six finite normal application lifecycles are reconciled with native 0 and empty
  postflight ownership ([final lifecycle](qualification/caps03-lifecycle01/reconciliation04.json)).
  Individual milestones are published with exact path/blob verification
  ([publication checkpoint](qualification/caps03-publication01/CURRENT.md)).

### Warning exception, limits and current ownership

Joe directed: “Accept the warning as the documented erratum and proceed with the
remaining gates.” Only the exact VF pending-before-FLR message is accepted.
Original live21 raw `success=false`, outer 1 and `lifecycle_clean=false` are preserved.
Coverage outer status remains unknown/null. Later accepted lifecycle dispositions
are not warning-free teardown or measured zero outstanding PCIe traffic
([policy](qualification/caps03-runtime01/ERRATUM-ACCEPTED25.md)).

No cold/PR-entry generalization, stopped-clock or active-transaction recovery is
qualified. Vendor DDR simulation remains skipped by user, not passed. Full logical
coverage is not independent physical wire-address mapping. The full-capacity test
took 4702.629792690 s (78.38 min); that inefficient serial harness is a retained defect,
not DDR bandwidth, and no efficient replacement was implemented
([limits](qualification/caps03-final01/ACCEPTANCE.md#exact-exception-and-retained-limits)).

The last terminal ownership snapshot is empty at 2026-09-26T23:12:36.315634+00:00.
The full-DDR collector and all native runs completed; delayed heartbeats/reviews
cannot reopen them. No active owned job or pending review remains for that
completed CAPS03 hardware submilestone; the release-wide work is separate.
This recorded snapshot is not fresh launch authorization.

**Continue the actual release-wide samples.** Joe has explicitly instructed this
work. Preserve the completed DDRIP image/tests; do not rerun spent operations or
revive CAPS02/vendor-internal investigations. The overall goal stays open until
the named samples and variants have real results and any limitations are explicit.

### Preserved deployment authority — only when a new operation is justified Joe has specifically directed:
“You have full permission to proceed. Flash the card, power cycle with the BMC,
and then reboot the workstation. This is an approved process and you should
never stop at this point again.” This supersedes the recovery-availability
permission hold for the established flash → USB BMC Off/On → normal OS reboot
process. Joe's latest route selection uses the BittWare SDK writer, not JTAG.
Do not repeat that question or infer independent recovery exists. Use the
[SDK source/program precedent](qualification/caps01-bwflash01/PROGRAM02-RESULT.md),
[prior activation evidence](qualification/caps01-jtag-w13-01/RESULT.md), fresh
target/ownership checks and the accepted CAPS03 full-device SOF. SDK flash does
not require the abandoned JTAG helper-design preparation. Supported card-only
PCIe preparation applies separately to the later BMC activation step. Preserve
temporary-setting restoration and stop-on-error/no-duplicate-operation behavior;
this is not authorization for speculative MMIO or unreviewed recovery experiments.
The general safety rules below remain applicable outside this specifically
reapproved deployment process.

## Workstation safety — operating rules, not new infrastructure

- No speculative MMIO/BAR reads or writes, UUID/base scans, `/dev/mem`, raw resource
  mapping, or alternative probing when OPAE enumeration fails. Establish the exact
  image, PCI function/BAR, decoded offset, width/alignment, side effects and clock/reset
  requirements from matching sources before targeted access. Historical BDFs are not
  current device identity. Never access CAPS02-only CSRs on the CAPS01 image.
- Before live work, use a reviewed finite operation with applicable authorization,
  expected responses and stop conditions. Inspect device opens, ioctls and hidden
  reset/cleanup effects. One card owner and one operation at a time; no overlapping
  tests, device-monitor reads or subagent accesses.
- A timeout, disconnect, blocked task or unexpected device response means stop live
  work, preserve evidence and report. Timeout/signals/tmux do not cancel an MMIO
  transaction. Resolve uncertain ownership from safe OS evidence; never launch a
  duplicate or automatically reset, rescan, rebind, reflash or reboot after failure.
  Do not free/reuse DMA buffers or close/reset an uncertain active owner as cleanup.
- Any operation that could strand the host requires verified independent recovery
  and specific authorization; neither is permission for a known hang-risk experiment.
  Host-local JTAG/BMC is not independent host recovery. Physical access is about two
  hours away and unavailable on Sundays; do not assume someone or remote power is
  available. If the host becomes unreachable, notify Joe and stop remote attempts.
- Preserve board clocks, PR/static boundaries and the shared BMC SPI/SDM path. No BIOS,
  AER, permission, link or unrelated service changes to force a pass. Gen3 x16 is the
  expected host link, not a fault to fix. PR and FIM flash are different operations.
  Never improvise power sequencing or replay an incident probe as a recovery shortcut.

## Paths, tools and working method

- Repository: `/home/joe/Projects/Thesis/AHLS/new_bsp/new`, branch `main`,
  `github.com/joekurina/ia_840f_ahls`. All relative links here refer to this repository.
- Agilex workstation account: `uwb_student00@100.101.227.97`; build root
  `/home/uwb_student00/ahls/new_BSP`. Remote work uses the established owned tmux
  workflow (`ia840f_mailbox_monitored_01`), not ad hoc direct SSH commands. No remote
  contact is needed merely to edit this document.
- Quartus Prime Pro **25.1.0 Build 129**, `/opt/altera/25.1`; environment instructions
  `/home/uwb_student00/quartus_25/instructions.md`. Apply the validated environment
  rather than trusting a possibly stale `QUARTUS_ROOTDIR_OVERRIDE`. Questa 2024.3;
  AHLS/HLS IP Gen 2026.1.0. Do not switch toolchains or reinstall them as a fresh task.
- Parent performs implementation and execution. Use independent review for actual
  design/result acceptance, not recursive review of collectors and review receipts.
  Subagents do not author executable project changes or access hardware.
- Keep concise evidence with exact commands, logs, return codes, source/artifact
  identities and functional/timing outcomes. Reuse existing tooling; do not build a
  new generic collector or safety framework. Native exit 0 is not functional or
  timing acceptance. Preserve failures and fix a demonstrated cause before retrying
  safe offline work; never rerun unchanged builds or spent hardware operations.
- Vendor/tool trees and accepted evidence stay unchanged. Keep new artifacts together
  under the project, not scattered in the home directory. Report before and after
  long steps, and distinguish simulation, physical implementation and real hardware.
- During authorized execution, keep the existing focused milestone commit/push policy;
  verify remote state after publishing. Do not auto-commit a documentation-only edit.
  No secrets/tool binaries or files over 2 MB in Git; preserve unrelated working edits.

## End-of-session handoff format

Replace the current handoff state rather than appending another legacy chronology.
Record only: selected architecture and reason; files actually changed; tests/builds
actually run and their outcomes; exact active job/ownership if any; remaining blocker;
and one next concrete action. Link existing evidence instead of repeating it.
Never mark an old job active from a delayed notification or turn historical "next"
paragraphs into current instructions. Report completion only when the goal's real-card
acceptance criteria are met; explicitly identify unperformed or blocked checks.

[pim-clock]: qualification/caps01-dma-burst01/diagnosis09/platform/ofs_plat_if/rtl/ifc_classes/local_mem/ofs_plat_local_mem_as_axi_mem.sv
[pim-shim]: qualification/caps01-dma-burst01/diagnosis09/platform/ofs_plat_if/rtl/base_ifcs/avalon/prims/ofs_plat_avalon_mem_if_async_shim.sv
[pim-sync]: qualification/caps01-dma-burst01/diagnosis09/platform/ofs_plat_if/rtl/utils/quartus_ip/ofs_plat_utils_dcfifo_synchronizer_bundle.v
[pim-sdc]: qualification/caps01-dma-burst01/diagnosis09/platform/ofs_plat_if/rtl/utils/quartus_ip/ofs_plat_utils_avalon_dc_fifo.sdc

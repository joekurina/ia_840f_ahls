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
in both directions, numerical comparisons after copyback, and clean sustained
operation and teardown. Reuse existing evidence where it applies to the exact image;
do not repeat completed bring-up as a default sequence. **The overall goal is incomplete.**

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
- When explicitly invoked to continue execution, take the next concrete unfinished
  step below. Joe has approved in-scope work and iteration, including flashing and
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

## Established baseline — reuse, do not redo

These are retained results, not a fresh observation of the running workstation.

- **Toolchain and base images:** Quartus 25.1 and the Work21 FIM/CAPS01 persona have
  already been built and used. Toolchain installation, the earlier EMIF hold/version
  investigation, initial programming/activation, identity, and basic OPAE/DMA bring-up
  are not new tasks. Preserve their recorded limits rather than labeling the entire
  system qualified. See [Work21 acceptance](qualification/fim-build-21/RESULT-ACCEPTANCE.md),
  [CAPS01 evidence](qualification/ahls-persona-work21-caps01/) and the
  [source-bound host contract](qualification/caps01-kernel-host01/HOST-CONTRACT01.md).
- **Real-card transfers:** the unchanged Work21/CAPS01 image completed serial writes
  and reads of 2 GiB per logical bank with checked data. This is **DATA PASS**, not
  simultaneous/full-capacity DDR, numerical HLS, or clean teardown acceptance.
  [Recorded result](qualification/caps01-dma-gib01/RESULT03.md).
- **Lifecycle finding:** the VFIO close path reported a pending-transaction timeout
  before FLR. An applicable P-Tile sticky-status erratum is documented; it neither
  proves real transactions were outstanding nor proves they were absent. Retain this
  separate lifecycle issue; do not turn it into justification for expanding CAPS02.
  [Erratum disposition](qualification/caps01-dma-gib01/ERRATUM11.md).
- **Kernel and fabric:** the corrected generated HLS kernel and the additive full-width
  Avalon-to-AXI memory routes already exist. Integrated simulation checked six cases
  and 133 integer results. Reuse the generated kernel, accepted LSU corrections,
  page-safe shims, DMA and functional tests. Do not repeat HLS generation, width-adapter
  feasibility studies, or the original handshake fixes.
  [Full-width result](qualification/caps02-fabric-fullwidth01/RESULT05.md).
- **CAPS02 custom publication path:** local/integrated simulations and synthesis/fit
  ran, but fitted mailbox crossing/reset timing was rejected. The candidate has not
  been deployed; `PUBLISH_SUPPORTED=0`. Successful simulation or native exit 0 does
  not change that. [Local acceptance](qualification/caps02-mailbox-timing126/ACCEPTANCE155.md),
  [STA result](qualification/caps02-afu-publication09/STA-RESULT175.md),
  [crossing results](qualification/caps02-afu-publication09/BUNDLE-RESULT226.md).
- The extensive retiming/collector/review investigation is **not the next work item**.
  Do not restart its interrupted review, repeat completed queries, or seek independent
  compiler-equivalence proof as a new prerequisite. Existing diagnostics remain
  available if a specific retained circuit later needs them.
- **Vendor DDR simulation remains skipped by user**, not passed and not an instruction
  to run it now. Real hardware numerical execution and final system qualification
  remain unfinished.

## Architecture conclusions to apply

1. **Minimize CAPS02 before repairing it.** The publication protocol, epoch tracking,
   snapshot mailbox and extensive observer are implementation choices, not automatic
   requirements for every route to numerical execution. Do not assume ARM/SNAPSHOT/
   RELEASE or a wide snapshot must survive. Keep only functionality needed for correct
   execution, observable completion and safe ownership/lifecycle.
2. **Prefer a common AFU/application clock with the PIM handling memory crossings,
   where the actual integration permits it.** Native bank interfaces expose their own
   clocks, but `ofs_plat_local_mem_as_axi_mem` explicitly supports `ADD_CLOCK_CROSSING`
   to present an interface on `afu_clk`; the Avalon wrapper carries that option too.
   This is a supported architecture choice, not a claim that the whole current design
   is already single-clock. [Retained PIM local-memory implementation][pim-clock].
3. **Reuse a complete vendor FIFO or interface shim for any necessary CDC.** The
   Avalon async shim uses command/response transport and an additional FIFO for write
   responses when enabled. Use the real implementation, its reset/flow-control
   semantics and matching SDC. Do not introduce another raw wide-bus capture or invent
   a CDC framework. [Retained async shim][pim-shim].
4. **`dcfifo_synchronizer_bundle` is not a payload FIFO.** It is a bank of single-bit
   synchronizers used for Gray-coded FIFO pointers. Sending arbitrary snapshot bits
   through it alone does not provide coherent word transfer. Reuse the whole FIFO,
   not this helper in isolation. [Synchronizer source][pim-sync].
5. **Vendor SDC is not a blanket waiver.** The shipped FIFO constraints bound pointer
   delay/skew and warn against blanket asynchronous clock groups or false paths that
   override them. Include and check the matching constraints on the actual selected
   hierarchy. Ignored generic `async_reg` attributes do not by themselves explain or
   resolve payload timing. A custom held-data handshake could be valid with a proper
   contract, but constraint-only repair is not the preferred route here.
   [Shipped FIFO constraints][pim-sdc].
6. **Clock crossing and write completion are separate issues.** A common clock or FIFO
   does not automatically make HLS done a memory fence. The existing simulation
   demonstrated HLS completion before native write retirement; the current host
   contract identifies the kernel-to-DMA visibility gap. Resolve this with the smallest
   supported response/ordering mechanism, not a guessed sleep, a CPU fence, or a new
   sprawling publication subsystem. Safe teardown is a further separate obligation.
   [Host contract, sections 4–5](qualification/caps01-kernel-host01/HOST-CONTRACT01.md),
   [retirement observation](qualification/caps02-fabric-fullwidth01/RESULT05.md).

These conclusions do not claim that every vendor sample uses one particular clock
architecture, that vendor practice authorizes arbitrary deployment, or that one
rebuild is guaranteed to finish the project.

## New handoff — next execution steps

**Handoff state:** the selected additive candidate uses the existing application
clock, with finite expected enabled-byte accounting and AW/W/B retirement rather
than the snapshot mailbox. The reference rule is finite producer completion plus
balanced responses (`ofs-platform-afu-bbb/plat_if_tests/local_mem_params/hw/rtl/axi/local_mem_engine_axi.sv:600–606`);
tagged OFS `ofs-common/src/common/he_lb/mode_lpbk.sv:370–418` supplies the B-before-read
counterpart. Expected enabled-byte counting is the required HLS-interface adaptation,
not a claimed verbatim vendor module. Observe the existing page-limited interface
inside an additive bank shim, before the outer mapper suppresses split responses;
the inner PIM mapper is passthrough for its 5-bit source/8-bit sink burst widths.
This keeps every B/error visible in the application domain without new CDC.

Actually added under `afu/ahls_memory/`: completion monitor and MMIO guard in
`control/`, completion bank shim, vendor-primitive reset integration and AFU top in
`pim/`, plus native Quartus CMake targets in `persona/`. Start/size use the existing
HLS programming sequence; read-only completion CSRs replace ARM/SNAPSHOT/RELEASE.
The maintained top defaults to `COMPLETION_SUPPORTED=0`. The **offline-only**
qualification copy uses the simulation-tested value 1 so synthesis does not prune
constant-disabled completion logic. This is not hardware activation or acceptance.

[Latest functional result](qualification/caps03-completion01/RESULT05.md): local
monitor 11 cases/71 checks; actual Questa2024.3 HLS six numerical cases/133 integers/
1600 result-and-guard bytes; B-error and premature DMA-GO rejection; separate actual
PIM intermediate split-B-error; bank1-only reset invalidates prior completion and
releases to idle, not success. sim05 native/effective/outer all0, no diagnostic errors,
original/input/tool preservation true, no remaining simulation owner. Generated HLS
is unchanged; failed sim01 and sim03 remain preserved. Review `deleg_90848114` was
consumed; bank0 selection is explicitly the tested shim and bank1 reset uses the
unchanged vendor reset-joining primitive. Focused review `deleg_62722d13` accepted
sim05 and both integration fixes; [functional milestone](qualification/caps03-completion01/ACCEPTANCE06.md).
Bounded steady-state physical acceptance is recorded below; reset-entry and
hardware acceptance remain open.

Native setup and [mapped synthesis](qualification/caps03-persona01/SYNTHESIS01.md)
passed for AFU UUID `d48dde9f-f551-578d-8bb0-69483ac95ec6`; native/CMake/effective/
outer exits0 and all preservation checks passed. The completion entity is retained
in the synthesis resource table. This is not timing/reset/CDC acceptance.

**Completed fit:** CAPS03 `fit02` finished at 22:30:38 UTC on 2026-09-25.
Native/CMake/effective/outer exits are all0, with no owned residual process,
preservation failures or diagnostic errors. All20 captured members were hash-verified.
[Receipt](qualification/caps03-persona01/fit02-outer.json),
[final observation](qualification/caps03-persona01/fit02-progress08.json).
Delayed fitter heartbeats are historical; watcher `proc_4574b929720e` completed.

**Completed final STA:** CAPS03 `sta01` finished at 00:56:20 UTC on 2026-09-26,
with native/CMake/effective/outer exits all0, all preservation checks true and no
postflight errors. All15 captured members were hash-verified against the native
archive. [Receipt](qualification/caps03-persona01/sta01-outer.json),
[numeric screen](qualification/caps03-persona01/sta01-numeric-summary.json).
Both memory/application clocks remain3.000ns. All913 summary records have numeric,
nonnegative slack: worst setup0.213ns, printed hold0.000ns, recovery0.242ns,
removal0.140ns; no nonzero TNS. Bounded independent review `deleg_cf5dcc3a` is
consumed: [steady-state physical acceptance](qualification/caps03-persona01/PHYSICAL-ACCEPTANCE01.md)
is supported at3.000ns. The parent reverified all35 captured members and all913
summary records, plus200 effective current-instance FIFO-skew results covering
40 pointer-direction bundles at five corners. Bank0 recovery/removal are0.592/
0.155ns; the earlier0.242/0.140ns figures are global minima, not bank0 values.
Design Closure remains FAIL with retained DRC findings. Four additional bank0
reset-sequence cycles are required. Source-bound normal-FLR counter phases have
substantial budget, but actual reset-entry readiness is not inferred from a timer;
cold/PR-entry, stopped-clock and active-transaction recovery remain unqualified.
Prior STA owner was @175/%175, PID58992/start_ticks8662683; stale watcher messages
must not relaunch it. No card operation or application hardware execution.
The [fit01 startup failure](qualification/caps03-persona01/FIT01-FAILURE.md) is
preserved: missing fitter tool-hash entry, owned processes terminated, originals
unchanged. fit02 corrects that finite binding and copies completed synthesis;
no synthesis or constraint change was repeated.

The accepted functional milestone is pushed as `636c29fcf055165a6cf297d62916aa4565b4252d`;
[remote/blob verification](qualification/caps03-completion01/publication-verification06.json).
The bounded synthesis milestone is also pushed as
`819cd5155aec78c95da61bd5fcd5cb02fcfd60a7`; local/remote-tracking/live-main agree
and the exact27 published paths/blobs were verified.
[Synthesis publication receipt](qualification/caps03-persona01/publication-verification02.json).
The bounded physical milestone is pushed as
`b6072ed59ff83731b5b3d71544266aeb42254377`; local/remote-tracking/live-main and all39 committed paths/blobs
were verified. [Physical publication receipt](qualification/caps03-persona01/publication-verification03.json).
Reset-entry and hardware acceptance remain excluded.
The additive native CMake `timing` target passed an inert configure/dry-run command
check before launch. The final STA runner now binds the completed fit and exact
5,505-file persona inventory, protecting344 physical snapshot paths while reusing
only the26 established STA-output roles. The earlier local binding assertion
mistook the intentionally removed publication constraint for unexplained drift;
[the disposition](qualification/caps03-persona01/sta01-preparation-inventory-failure.json)
keeps it absent. [Final bindings](qualification/caps03-persona01/sta01-preparation-binding.json).
Review `deleg_9fda88cf` is consumed: [bounded synthesis acceptance](qualification/caps03-persona01/SYNTHESIS-ACCEPTANCE02.md)
found no defect requiring a fitter stop or resynthesis; the 244-warning footer is
exactly the post-A&E population, not the full log count. That synthesis review did
not itself establish physical reset/CDC acceptance.
The additive `src/host/ahls_memory_caps03.c` and sibling startup source implement
one nine-integer kernel invocation with ordered completion and guarded copyback.
[46/46 inert frontend cases passed](qualification/caps03-host01/RESULT01.md), using
only mocked OPAE symbols. Independent review `deleg_88b749ca` accepted the bounded
host functionality; the parent reverified all46 logs/receipts and the inert ELF.
The [native AHLS-image build](qualification/caps03-host01/NATIVE-BUILD01.md)
subsequently passed: startup and strict entry both compiled/linked with GCC11.4.0,
`-Werror` and assertions enabled; all14 captures verified, all64 SDK bindings
unchanged. The artifacts remain mode0600. No application or OPAE loading occurred;
actual runtime resolution, numerical FPGA execution and live teardown remain open.

**Completed native assembly:** `asm01` finished at01:50:46 UTC on2026-09-26;
native/CMake/effective/outer exits all0, preservation true, no owned residuals or
postflight errors. All17 captured members were hash-verified, all344 physical
snapshots and the inherited static images remain byte-identical, and the QSF
delta is only stage hooks. [Receipt](qualification/caps03-persona01/asm01-outer.json),
[parent verification](qualification/caps03-persona01/assembly-parent-verification01.json).
New SOF is10,065,141bytes, SHA256
`8f778fca292cc77f87c196deb198d4798a1bd111999d69b0245d570fa2bfe276`;
new PMSF and PR-RBF are also present/hash-verified. Native reports0 errors and19
warnings (20727×1,18502×17,20536×1). Completed independent assembly review
`deleg_2fbb4609` returned ACCEPT with no assembly blocker and is consumed:
[assembly acceptance](qualification/caps03-persona01/ASSEMBLY-ACCEPTANCE01.md).
Waiter `proc_5e26e8571cb2` completed0/output0; @181/%181 and native
PID60560/start_ticks8960870 are historical, not a running build.
The additive CMake `assembly` target passed inert configure/dry-run; the native
run copies the exact5,518-file completed STA inventory, retains344 physical
protections and the26 established assembly-output roles, and binds both assembler
launcher/native hashes. All allowed36 CPUs and64GiB per-process address space are
retained. Required new SOF/PMSF/PR-RBF artifacts are explicit acceptance predicates.
No resynthesis, fit, constraint change, application execution or hardware access.

**Current explicit deployment authority:** Joe has specifically directed:
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

**Historical JTAG deployment outcome (route retired):** accepted SOF → MT25QU02G/ASx4 JIC conversion passed,
with no rebuild. JTAG remains unavailable: native0 accompanied by “Unable to read
device chain - Hardware not attached,” without FPGA/TAP ID. Instrumented native
USB capture shows successful control/interface operations but queued requests
not completing. A supported USB-Blaster-only device reset returned0 but did not
restore the chain. Under the renewed as-needed reboot authority, one normal OS
recovery reboot returned0; the workstation is reachable on verified new boot
`4945ac3f-5bfd-43d3-a4bf-748af43e70b6`. Its first chain check still failed identically.
No flash erase/program, BMC power cycle, PCI removal/AER change or kernel/DMA launch.
The prepared JIC is unchanged. [Current evidence](qualification/caps03-flash01/RECOVERY18.md).

**Current route decision:** Joe explicitly directed “Switch to the bittware sdk
flasher.” Use the installed `bw_agilex_flash_programmer`, not Quartus/JTAG. Retire
JTAG-restoration prerequisites while preserving the raw failure records. Prepare
a writer-compatible full-image RPD from the accepted CAPS03 SOF, preserving the
complete non-RSU layout and verified image lineage. Recheck current management
binding/ownership; execute one SDK program/readback/compare before the already
approved BMC Off/On and workstation reboot. JIC is conversion evidence, not SDK
input. Do not substitute the unrelated RSU user-slot address. The existing
flash/BMC/reboot approval remains valid; this is not a permission or independent-
recovery hold. Numerical, application reset-entry, DDR and teardown acceptance
remain open.

[Completed SDK deployment](qualification/caps03-flash01/SDK23.md): the unchanged
CAPS03 SOF was packaged as the writer-compatible10653696-byte RPD/SHA256
`0319b7fd35d968d73f02f9a6f49706cb249c3559dec1759a3f2d3a37122e4bcf` with identical
map/JIC. Original program23 completed09:43:50UTC on2026-09-26 with native/effective/
outer0, full readback and byte comparison passed. Observer`proc_f6d2723897fa` is
complete/consumed. No reprogramming or standalone verify is needed.

USB BMC Off/On and separate readbacks passed, followed by one successful normal
OS reboot. [Postboot47](qualification/caps03-flash01/postboot47-result.json) verifies
new boot`fb857f04-2297-4a93-9b32-26636641713b`, expected PF0dfl-pci/PF1vfio-pci,
Work21 cached FME UUID`fc4bf1c1-760f-5cd7-8040-b3e86fa0d31e`, restored original
AER masks and empty FPGA/VFIO ownership. No VF exists before per-boot setup.
This completes the requested deployment sequence, not the overall goal: the FME
UUID does not independently identify CAPS03 or qualify HLS/reset/DDR/lifecycle.

**Current runtime result:** [CAPS03 runtime01](qualification/caps03-runtime01/RESULT.md)
completed the first real numerical FPGA Test and a subsequent original-frontend
normal-return case on the unchanged accepted image and 3.000ns target. Normal-idle
first entry was admitted after fully consuming review`deleg_62c01146`, including its
missing projected PR-slot register: source accounting with that stage leaves229.315ns
beyond the four additional bank0 cycles. RESET08 is not claimed as cycle-exact
full-chain coverage. No new readiness register, mailbox, FPGA rebuild or reflash
was introduced.

[First hardware data pass](qualification/caps03-runtime01/NUMERICAL13.md): on
2026-09-26T19:11:12Z, VF`0000:4f:00.2` passed exact CAPS03 identity/capability
comparisons, all six DMA descriptors, HLS ticket1/completion`0x10002`, all nine
signed results and all156 non-result bytes in the192-byte copyback span. Both
source-bound static EMIF init flags were1 before entry. OS postflight found only
two normal VF enabling-device notices in the test-interval kernel log, no errors.

**Current owner state:** the live13 owner ended through the supported ordinary
reboot16 after consuming review`deleg_6b73b417` and passing fresh owner-bound
recovery-pre15. Postboot17 verified new boot`8121620d-a638-42f8-abab-a547aae32076`,
ended old ownership and expected Work21 FIM/PF state. VF creation/binding was restored
by create19/bind20. No preliminary signal, BMC cycle, reflash or explicit PCI reset
was used. Live13 still has no normal exit; reboot is recovery, not a retroactive
lifecycle pass. [Recovery/postboot](qualification/caps03-runtime01/postboot17-result.json).

[Normal-return hardware test](qualification/caps03-runtime01/NUMERICAL21.md)
then reused the original already-built frontend and passed the same six descriptors,
nine signed results and156 guard/padding bytes with **native exit0**. Postflight
observed no owners or D-state tasks. Its kernel interval nevertheless reported:
`timed out waiting for pending transaction; performing function level reset anyway`.
The result retains`lifecycle_clean=false`, overall`success=false`, and outer1.
That live21 completion left no owners; later successor state is recorded below.
Do not revive the old PID7231 recovery hold.

**User-directed erratum disposition:** Joe explicitly instructed: “Accept the
warning as the documented erratum and proceed with the remaining gates”. Review
`deleg_474adbdd` is completed/consumed. The exact VF pending-transaction-before-FLR
message is accepted with disclosure; historical raw`lifecycle_clean=false` and
outer1 stay unchanged. Different warnings, FLR-completion timeouts, unknown/retained
ownership, or numerical/guard failures remain failures. [Policy](qualification/caps03-runtime01/ERRATUM-ACCEPTED25.md).
Stop the pending-status workaround investigation. Do not add CII, status-clearing
logic, reset bypasses or an FPGA rebuild to remove the accepted warning. [Repeated/boundary hardware coverage](qualification/caps03-coverage01/RESULT.md)
now passed on the accepted image: 34 cases, 2,982 integers, 536 descriptors,
native0 and empty postflight ownership. The sole kernel concern was the exact
accepted erratum; raw lifecycle_clean=false remains separate from
lifecycle_accepted=true. Review deleg_a09ed8e0 is consumed, not pending.
[CAPS03 DDR sweep](qualification/caps03-ddr01/RESULT.md) completed with DATA PASS:
one serial W0,W1,R0,R1 ownership session,2GiB written/read per channel across
its16GiB aperture,67,108,864 descriptors and590.09350623s. Native0/outer0;
parent verified all four phases,64 progress records and empty ownership in
[parent-verification06](qualification/caps03-ddr01/parent-verification06.json).
Collector proc_38c154bded66 exited0 and is consumed; live02 is spent.
Selected geometry/mapping review deleg_e0bf825c is consumed. The physical
all-bank/all-row derivation remains conditional on protected-MSA byte ordering;
retain that limitation rather than reopening vendor-internal qualification.
The [walking-bit follow-up](qualification/caps03-walk01/RESULT.md) also passed:
30 addresses per bank,120 descriptors,1920 copied-back bytes per bank, all writes
before reads, fresh completion and both host-page checks. Native0/outer0 and
empty ownership; the three correlated sparse-sweep pairs are now independently
exercised. Both runs retain lifecycle_clean=false/lifecycle_accepted=true for
only the exact accepted erratum. Those runs completed with no retained owners;
the later full-capacity operation also completed, as recorded below.
Simultaneous-workload analysis deleg_dd4cbc6b is consumed: the unchanged finite-
buffered HLS pipeline supports the concurrent bank0-read/bank1-write streaming leg,
not a measured DDR-wire overlap claim. Bulk live02 has now ACTUALLY PASSED:
65536 integers,262144 result bytes+128 DDR guard bytes,8324 descriptors/268tiles,
native0/outer0, empty ownership, sole accepted erratum. The [parent verification](qualification/caps03-bulk01/parent-verification03.json)
binds the raw result. Bounded source/walking-bit review deleg_7f0585bb accepted and
is consumed; bulk actual-result review deleg_0ea2b2d1 accepted and is consumed. Live02 is spent.
DDR result review deleg_79ea1085 accepted independent logical-bank, W0W1R0R1
isolation and serial sustained gates ([ACCEPTANCE07](qualification/caps03-ddr01/ACCEPTANCE07.md)).

The [full-capacity follow-up](qualification/caps03-full-ddr01/RESULT.md) has completed
its single live02 invocation. At 23:12:36 UTC on 2026-09-26, both 16 GiB logical
apertures passed all W0/W1/R0/R1 phases: 536,870,912 descriptors and 64 GiB aggregate
traffic. All 512 progress records, payload/host-page checks, native/outer exits 0,
unchanged boot and empty postflight ownership were independently checked by the
parent ([verification](qualification/caps03-full-ddr01/parent-verification15.json)).
Only the exact accepted pending-before-FLR warning occurred; warning-free teardown
is not claimed. Collector `proc_1145e5e6a582` completed 0; no test owner remains in
the final receipt. Do not replay live02. Actual loop time was 4702.629792690 seconds;
this inefficient serial harness is not a DDR-bandwidth measurement or a test to
repeat. The accepted image, generated HLS and 3.000 ns target remain unchanged.

Full-capacity actual-result review `deleg_25953609` is accepted and consumed in
[review16](qualification/caps03-full-ddr01/review16-consumed.json); it confirms the
combined agreed DDR gate is satisfied. Six normal lifecycles are reconciled in
[reconciliation03](qualification/caps03-lifecycle01/reconciliation03.json).
Normal-HLS, serial-DDR, walking, bulk and full-capacity acceptance milestones are
published; latest remote-verified main is `68ed8ba142078bcd70864d87d86bcca1dfe2ef83`.
Next concrete action: consume the separate repeated/boundary actual-result review
`deleg_103db8bc`, publish that gate, then close the final qualification checkpoint.
No new build, flash, power cycle, reboot or hardware test is justified. Overall
completion remains pending that final result-review/publication step.

1. **Make a bounded architecture decision.** Start from the existing top/core, the
   host contract's exact visibility gap, the full-width fabric and retained PIM
   interfaces. Identify the implementation counterpart in the tagged OFS release or
   BittWare BSP for each proposed mechanism; reject feature/infrastructure additions
   absent from those references rather than redesigning them under a different name.
   Identify what already runs in the AFU domain, what genuinely must stay
   bank-local, and what existing response/ordering mechanism can make completed HLS
   stores observable before DMA copyback. Prefer eliminating an unnecessary crossing;
   otherwise use the complete vendor shim/FIFO for only the necessary information.
   State the chosen delta, files affected, and concrete acceptance test briefly here;
   do not start another general audit, proof framework or series of review documents.
2. **Implement the smallest justified additive candidate under execution scope.**
   Preserve the Work21 static shell, original code and unchanged generated HLS.
   Reuse the corrected DMA, width/page adapters and existing tests. Do not retain all
   CAPS02 machinery merely to preserve an experimental ABI. Conversely, do not remove
   the only retirement observation without replacing its required semantics.
3. **Exercise the changed path using existing functional infrastructure.** Keep real
   HLS arithmetic, partial/tail outputs and guard-byte checks. Challenge delayed final
   writes/responses and potential read overtaking so the host-visible completion rule,
   rather than a white-box testbench delay, determines safe copyback. Check relevant
   reset/stall behavior without broadening into an unrelated verification platform.
4. **Build only what changed with Quartus 25.1.** Use the established CMake-native
   project flow and accepted static image. Review actual synthesis, fit, timing and
   reset/CDC results for the selected design, including effective vendor constraints.
   No unchanged FIM rebuild, automatic kernel regeneration, clock slowdown, relaxed
   existing 3.000 ns target, blanket false paths, or premature publication enablement.
   A FIFO transport change alone is not acceptance of the whole design.
5. **Return to the real OPAE numerical path after design and safety requirements are
   met.** Use an exclusive owner, source-bound accesses and supported completion/error
   behavior. Perform the smallest admitted kernel case, copy back and compare actual
   results and guards; then extend to repeated/boundary cases and remaining DDR,
   sustained-operation and lifecycle requirements. Reuse baseline bring-up evidence;
   deploy a changed image only when required and separately review its exact operation.
   Complete only missing final-image boot/power-cycle acceptance, not an automatic
   repeat of the old flash sequence.

If no supported completion/ordering path can be established in the bounded source
inspection of the primary references, report the specific missing contract and ask
for a scope decision; do not invent additional features or infrastructure to fill it.
Do not substitute speculative MMIO, an assumed fence, or weeks of generic sign-off
machinery. State an actual user-input blocker clearly and stop when input is needed.

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

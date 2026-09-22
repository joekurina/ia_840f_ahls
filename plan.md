# IA-840F BSP Build and Test Implementation Plan

> **For Hermes:** Use the subagent-driven-development skill for separately authorized implementation tasks, with source review before execution. This document is a plan, not permission to execute it.

**Goal:** Build and qualify the vendor-derived IA-840F platform in stages, including its Linux DFL/OPAE host stack and a real AHLS-generated AFU.

**Architecture:** AHLS-generated RTL/IP connects through OFS PIM to the IA-840F FIM. Linux DFL discovers and manages the applicable FPGA features; OPAE supplies userspace discovery, MMIO, buffer and reconfiguration access. The BittWare board implementation remains the hardware authority.

**Tech stack:** AGFB027R25A2E2V, P-Tile Gen4 x16, two distinct 16 GiB DDR4 channels (discrete and RDIMM), pinned OFS FIM/common/PIM, Altera AHLS, intended Quartus Prime Pro 26.1.1, Linux DFL and OPAE.

## Current continuation checkpoint

The active `GOAL-PROMPT.md` supersedes this plan's original source-only and
no-commit authorization wording. Source-side continuation and milestone
commits/pushes are authorized; live installation, device access, PR/programming
and recovery remain separately gated. Host-local JTAG/BMC is not independent
host recovery. Gen3 x16 is the expected workstation link, not a fault.

[Source-resume-01](qualification/source-resume-01/REPORT.md) records the current
checkpoint: W13/persona artifacts preserved; false UART advertisement
identified and now corrected in locally maintained source under the vendor
UART-absent convention; udev candidate offline-tested but not
activated; PF0 VF0 BAR0 source/OPAE mapping; additive exact-numerical host test
offline-tested and natively linked, never run on hardware. Negative W13/persona
timing remains unaccepted. DDR simulation remains SKIPPED BY USER. The older
stage descriptions below are implementation history/templates, not permission
to repeat completed work or launch their hardware commands.

The [parent acceptance record](qualification/offline-milestone-review-01/ACCEPTANCE.md)
now closes the separate source-evidence, UART-diagnosis, staged-udev and offline
host-software review gates (spec PASS, quality APPROVED). Fresh local checks:
CTest 2/2, UART 12/12 and udev 21/21. Native hardware execution remains blocked;
the UART scope decision is resolved and its [one-token source correction](qualification/dfl-uart-fix-02/ACCEPTANCE.md)
is independently accepted. Original bound reports are preserved, including
pre-review status wording and rejected candidate01. Joe has now explicitly
approved flash programming and host reboot once the build is ready; independent
host recovery and the finite source-supported live procedure remain prerequisites.
The source correction itself does not qualify a new build, timing or hardware.

The [Work14 compile package](qualification/fim-build-14/COMPILE-PACKAGE-ACCEPTANCE.md)
is now independently accepted. Its fresh native full-FIM compile started once
at 2026-09-21 21:34:56 PDT; [launch/process evidence](qualification/fim-build-14/RUNNING.md)
confirms the actual Quartus flow and synthesis in Work14. The [native run completed](qualification/fim-build-14/RESULT.md)
at 22:27:14 PDT with exit 0 and successful assembly. Do not reissue or restart
the consumed run. [Independent result review is consumed](qualification/fim-build-14/RESULT-ACCEPTANCE.md);
timing remains FAIL / NOT accepted (−0.004 ns EMIF1 hold, unconstrained PCIe
divider and unresolved constraint/CDC findings). Next: trace the obsolete PCIe
divider binding and dependent exceptions before a narrow correction; do not
repeat already-effective hold settings. Work14's new FIM interface does not
match the existing W13 persona. All hardware gates remain open.

## 1. Authorization and acceptance model

**Current state: source-only; `ready_for_build: false`.** Creating this plan authorizes no workstation access, setup/configuration, IP generation, compilation, simulation, tests, installation, programming, commits or pushes. No gate is changed by this plan. Earlier standard/USM oneAPI trees remain reference-only, not active build/test targets; see [AHLS scope](docs/ahls-scope.md).

Request explicit authorization for each applicable action class before executing:

| Stage | Separate authorization needed | Outcome, not a claim made today |
|---|---|---|
| A | Local source/configuration changes | Closed source prerequisites and reviewed experimental gate policy |
| B | Read-only workstation access | Actual toolchain, kernel, driver and board inventory |
| C | Setup, IP generation and simulation | Accepted generated interfaces and passing protocol checks |
| D | FPGA and host-software builds | Source-bound FIM, matching PR artifacts and host binaries |
| E | Host installation, driver changes or reboot | Verified DFL/OPAE environment, with rollback |
| F | Volatile programming, PR and hardware tests | Measured board/platform behavior |
| G | Persistent flash programming, if requested | Separately reviewed durable deployment |

All Agilex workstation operations, including inspection, must run inside named **tmux** sessions. Do not silently reconnect, install dependencies, change the kernel, reboot, disable protections or flash hardware. Do not commit/push unless separately requested. Give updates before and after long stages and during synthesis/fitting.

Use separate acceptance fields for source consistency, IP generation, simulation, synthesis, timing, driver binding, hardware tests and release qualification. Permission to attempt an experimental build is **not** build readiness or platform qualification. Keep `ready_for_build` false until a separately reviewed definition and evidence justify changing it.

## 2. Inputs, directories and evidence

The source root is `/home/joe/Projects/Thesis/AHLS/new_bsp/new` (called `N` below); `C` is `N/ofs-agx7-pcie-attach`. The original vendor tree at `../old_bsp/ia-840/IOFS_BUILD_ROOT/ofs-ia840f` and sibling donor repositories stay read-only.

### Agilex workstation paths

- **Target working directory:** `/home/uwb_student00/ahls/new_BSP/` (preserve capitalization).
- **Quartus instructions:** `/home/uwb_student00/quartus_26/instructions.md`.

For authorized workstation execution, use `/home/uwb_student00/ahls/new_BSP/` as the remote project root (`N`); confirm the transferred checkout layout before resolving `C`, source references and disposable `work*` directories beneath it. The local source root above remains the source-preparation location, not the workstation execution path.

Before any authorized Quartus setup, IP generation or build, read `/home/uwb_student00/quartus_26/instructions.md` and follow its workstation-specific instructions. Reconcile any conflict with this plan before proceeding. These are user-supplied paths; adding them does not claim remote inspection or authorize workstation access. All workstation operations remain subject to the tmux and staged-authorization requirements above.

Read these before implementation:

- [Source pins](sources.lock.json), [feature matrix](docs/feature-matrix.md), [integration status](docs/vendor-integration-status.md).
- [Memory mapping](docs/memory-port-source-map.md), [memory CSR review](docs/memory-csr-source-review.md), [preset derivation](docs/vendor-derived-presets.md).
- [PCIe BAR2 trace](docs/pcie-bar2-source-trace.md), [BMC integration](docs/vendor-derived-bmc.md), [BMC source closure](docs/bmc-component-source-closure.md), [BMC FLR review](docs/bmc-flr-source-review.md).
- [AHLS binding](docs/vendor-derived-ahls-binding.md), [integration contract](afu/ahls/integration-contract.json), [board source-registration audit](docs/board-source-registration-audit.md).

Proposed future outputs, **not created by this plan**:

| Path relative to N | Purpose |
|---|---|
| `qualification/<run-id>/` | Immutable source hashes, commands, environment, logs, reports, test results |
| `qualification/<run-id>/host-stack/` | Kernel/modules/packages, binding, permissions, rollback evidence |
| `qualification/<run-id>/generated-contracts/` | PCIe/memory/AHLS exports and comparisons |
| `work_ia840f_<run-id>/` | Disposable OFS worktree, separate from maintained source |
| `tests/ia840f/` | New protocol and board-level FPGA Test definitions |
| `afu/ahls/qualification/` | Separate generic AHLS qualification component/top/host source |

The OFS work directory must follow the checked-in flow's `work*` naming and location rules. `N/work_ia840f_<run-id>` is outside `C`, rather than a forbidden deep subdirectory of the FIM source root; confirm transferred workstation paths before using it. Never overwrite an existing run or import vendor QDB/build trees. Record original donor hashes separately from current edited-file hashes.

## 3. Stage A — Resolve source prerequisites and stage-specific gates

### Task A1 — Freeze the source candidate

**Files:** `sources.lock.json`, `C/syn/board/ia840f/source_manifest.json`, `afu/ahls/provenance.json`, `qualification/<run-id>/source-inventory.json` (new).

1. Record exact repository/submodule commits and dirty/untracked source changes.
2. Rehash manifest targets and original donors; retain prior receipts unchanged.
3. Record the FPGA part, pin inventory, memory topology, PCIe identities, PF/VF routing, clocks and constraints.
4. Check every selected source/configuration path, not merely filenames listed in older receipts.

**Accept:** no unexplained source/hash differences; generated artifacts remain outside the maintained baseline. Source consistency alone is not dependency or behavior qualification.

### Task A2 — Resolve memory interfaces and management

**Files:** `C/ipss/ia840f/derive_presets.py`, its `presets/` and `preset_derivation.json`; `C/syn/board/ia840f/config/ia840f_memory.ofss`; `C/syn/board/ia840f/setup/emif_loc.tcl`; `C/src/board/ia840f/top.sv`.

1. Obtain authoritative modern `mem_ss`/MSA definitions for the intended toolchain; inspect them before changing aliases or enables.
2. Establish actual physical grouping and controller-to-pin mapping. Two simulation models do not establish two physical interface groups. Preserve the reversed vendor calibration-bus association and resolve the RDIMM differential reference-clock evidence without guessing a pin.
3. Resolve the untransplanted simulation-model fields from the target component, not devkit geometry.
4. Establish modern memory CSR enable, diagnostics, register semantics and clock/reset directions. The outer router already exists; do not create another router or equate `CSR_EN` with `DIAG_ENABLE_CSR` without evidence.
5. Preserve the actual outer aperture. Vendor internal controller-MMR routes outside it are not demonstrated direct host access.
6. Apply only supported source corrections; refresh current hashes while retaining donor provenance.

**Accept:** explicit board-port and enabled/disabled feature contracts ready to compare with generated exports. If authoritative source cannot settle a generated detail, track it as a Stage C acceptance item; do not manufacture it or mark it complete. Evidence: [mapping](docs/memory-port-source-map.md) and [CSR prerequisites](docs/memory-csr-source-review.md).

### Task A3 — Resolve PCIe/BMC contracts

**Files:** `C/ofs-common/tools/ofss_config/ia840f_vendor_pcie.py` (locate and confirm the maintained helper before editing), `C/ipss/ia840f/preset_derivation.json`, board PCIe configuration, `C/src/board/ia840f/bwbmc_st2mm*.sv`, `bwbmc_wrapper.sv`, `fim_afu_instances.sv`.

1. Close the missing P-Tile child-IP, Lampas/WHR and template source evidence identified in the [BAR2 trace](docs/pcie-bar2-source-trace.md).
2. Preserve PF0 VF0 for AFU and PF1 for BMC; preserve vendor IDs and PF1 BAR0 disabled, BAR2 width 28 and BAR4 width 14. Do not drop PF1/BAR2 to obtain a passing build.
3. Check the BMC's 17-bit local aperture against PCIe BAR routing and MSI-X interception. Do not widen the bridge simply because BAR2 is larger.
4. Resolve legacy catalog-IP compatibility using the [component closure inventory](docs/bmc-component-source-closure.md). Existing local filesets close; tool acceptance is still pending.
5. Establish a proven PF1 host-transaction cancellation/drain contract before reset-under-traffic tests. Clearing one FIFO is insufficient; never reset shared SPI/SDM on PF1 FLR or use the unused edge pulse as a drained acknowledgment.
6. Define safe handling and acceptance for unsupported SPI service windows and interrupt transport; do not advertise missing functionality.

**Accept:** generated-interface checks and protocol tests have explicit expected behavior. If no source-proven FLR fix exists, record the specific restriction; it is a blocker for full reset qualification, not permission to invent a protocol.

### Task A4 — Reconcile gates before any execution

**Files:** `C/syn/board/ia840f/setup/build_gate.tcl`, PCIe source-only helper, board README/OFSS comments, [status](docs/vendor-integration-status.md).

1. Identify both unconditional gates and all actual entry points; do not assume a QSF gate prevents earlier setup/IP generation.
2. Correct stale descriptions in a separately authorized source change: the BAR2 subsystem schema is now known; host pipes are not an invented mandatory AHLS ABI; board presets now exist.
3. Propose a reviewed, explicit stage-specific experimental authorization mechanism, bounded to the approved source snapshot and toolchain. No blanket environment bypass, no deletion of guards and no wholesale promotion to ready.
4. Distinguish generation/elaboration permission from full fit, host installation and hardware access. Qualification findings that require execution must not create a circular demand for qualification before the first controlled experiment.

**Accept:** the user authorizes the exact next stage and reviewed gate change. Until then, all existing gates stay closed.

## 4. Stage B/E — DFL driver stack and OPAE host environment

### Authoritative baseline

The user's [OFS 2025.1-1 software guide, §2](https://ofs.github.io/ofs-2025.1-1/hw/common/sw_installation/pcie_attach/sw_install_pcie_attach/#20-ofs-software-overview) describes DFL as the kernel feature-discovery/driver layer and OPAE as userspace. Its Table 2 lists **RHEL 9.4**, **Linux DFL `intel-1.12.0-2`** and **OPAE `2.14.0-3`**. This is a reference BKC, not proof that the IA-840F or the workstation's actual kernel is qualified. The guide's §4.2 names a `2.14.0-2` prebuilt OPAE archive, differing from Table 2: resolve exact release assets and checksums rather than silently mixing versions.

Do not install every module shown in the guide as though every feature exists on this board. IA-840F uses vendor BittWare management, not an assumed Intel MAX10/PMCI replacement. DFL does not provide the out-of-band BMC implementation. Source: [guide §§2–4](https://ofs.github.io/ofs-2025.1-1/hw/common/sw_installation/pcie_attach/sw_install_pcie_attach/).

### Task B1 — Inspect the existing workstation stack first

**Output:** `qualification/<run-id>/host-stack/preflight.md` and package/module inventory.

After read-only workstation authorization, inside tmux:

1. Record OS release, running kernel, architecture, secure-boot/module-signing state, kernel configuration and matching development packages.
2. Record installed DFL/OPAE packages, DKMS status where applicable, module search paths and source provenance.
3. Inspect `dfl-pci`, DFL core, FME/AFU drivers and FPGA manager/bridge/region dependencies. Compare installed `modinfo` filename, `vermagic`, `srcversion` and signer with loaded `/sys/module/<name>/srcversion` and actual PCI driver links.
4. Discover the current BDFs from actual enumeration; do not hard-code a historical BDF. Record IDs, subsystem IDs, BARs, link capability/status, IOMMU groups and SR-IOV capability.
5. Record boot arguments, IOMMU enablement, BIOS PCIe width/generation and SR-IOV support. IA-840F's target is Gen4 x16, not the R/F-Tile devkit topology.
6. Establish whether the existing stack already works against the current known-good image before changing it.

**Accept:** a live host-stack inventory and explicit retain-versus-change decision. A module under `weak-updates`, or an older vermagic on a kABI-compatible distribution, is not by itself reason to rebuild when loaded/installed identities and device binding agree. No changes during this inspection.

### Task E1 — Build/install DFL only if needed and authorized

**Sources:** [DFL backport release](https://github.com/OFS/linux-dfl-backport/releases/tag/intel-1.12.0-2), [guide §3](https://ofs.github.io/ofs-2025.1-1/hw/common/sw_installation/pcie_attach/sw_install_pcie_attach/#30-ofs-dfl-kernel-drivers).

1. Choose and document one kernel-compatible DFL route: retain a proven existing stack, reviewed matching binary packages, or a pinned source/backport build. Record exact commit/package hashes and any kernel adaptation patches.
2. For a source build, inspect that pinned tree's Makefile/packaging instructions first. The guide shows `make && make rpm`; do not assume it applies unchanged to the actual kernel or treat it as authorization to install a new kernel.
3. Compare supported PCI IDs/DFL layouts with the IA-840F FIM. Do not force-bind an unsupported device using `new_id` to hide a driver/FIM mismatch.
4. Resolve matching kernel headers/devel, compiler, symbols, signing and DKMS/installation procedure. Do not disable Secure Boot or replace the OS as an incidental workaround.
5. Preserve existing package/module inventory, boot configuration and a known-good kernel/driver recovery route. Review the installation transaction and module conflicts before applying it.
6. If boot arguments must change, review them for this host. The guide's `intel_iommu=on`, `pcie=realloc` and hugepage example are not unconditional settings for every CPU or test. Size hugepages from the chosen test requirements, not an invented BSP requirement.
7. Install/reboot only with explicit permission. Re-inspect installed and loaded modules, kernel logs and actual binding afterward.

**Accept:** correct modules load with compatible symbols/signatures, no duplicate conflicting stack, intended PCI function binds, feature discovery completes without probe faults, and rollback remains possible. File presence or `lsmod` alone is insufficient.

### Task E2 — Install/verify OPAE and permissions

**Sources:** [OPAE release](https://github.com/OFS/opae-sdk/releases/tag/2.14.0-3), guide §§4.1–4.2.

1. Inventory the existing runtime/development/tools packages and userspace plugin configuration before selecting changes.
2. Pin a consistent OPAE package set compatible with the chosen DFL ABI. Inspect exact release assets; do not execute the guide's broad package-removal examples against the workstation blindly.
3. Build/package only when necessary; keep installation separate from build authorization. Record actual resolved libraries/plugins and package versions.
4. Determine the intended PF0 management and PF0 VF0 AFU access routes, including DFL device nodes versus VFIO according to the real platform/plugin configuration. Do not bind all PFs to VFIO or detach PF1 BMC indiscriminately.
5. Establish least-privilege device permissions, VF creation and IOMMU/buffer registration behavior. Do not use permanent world-writable nodes, unrestricted root tests or no-IOMMU mode as a fix.
6. Verify management discovery and AFU enumeration/MMIO as the intended non-root user. Exercise OPAE buffer allocation/registration and release only when no DMA is outstanding.

**Accept:** FME/port/AFU identity matches the programmed image; PF1 management remains intact; non-root MMIO and approved DMA access work with known ownership and isolation. Generic Intel PMCI telemetry commands are not assumed applicable to BittWare.

## 5. Stage C — IP generation and simulation before a full fit

### Task C1 — Inspect installed tools and generate into an isolated worktree

**Inputs:** `C/syn/board/ia840f/config/ia840f.ofss` and Stage A source contracts.

1. After authorization, record actual Quartus 26.1.1, AHLS release, simulator, licenses and device support. Do not downgrade to satisfy historical oneAPI limits.
2. Inspect the current OFS build target parser and IA840F registration; determine the exact target token and worktree paths. Do not substitute an N6001 target for a missing IA840F entry.
3. Generate board IP in a clean copied worktree, recording all parameter reports, warnings, upgrades and generated files. No edits to vendor originals.
4. Compare generated memory/PCIe/BMC exports against Stage A contracts before synthesis. Verify part, width/segments, PF/VFs, BARs/IDs, memory geometry, clock/reset directions, physical groups, calibration and CSR exports.
5. Verify BMC custom components resolve through their filesets; retain the inactive external IRQ-cause correction. Check that default memory initialization does not spuriously require a custom `onchip_mem.hex`.
6. Freeze generated interface/configuration evidence and update only justified board adaptations in maintained source.

**Accept:** every selected IP generates with explained diagnostics and exact required interfaces. Upgrading IP or matching source parameter strings does not establish equivalent behavior.

### Task C2 — Define and run protocol FPGA Tests

**Create after authorization:** `tests/ia840f/README.md`, protocol benches and explicit invocation/source lists under `tests/ia840f/`. Choose commands only after selecting the supported simulator and actual generated source/library lists.

| Test | Required checks | Failure gate |
|---|---|---|
| AHLS MMIO bridge | Read/write byte enables, tag/user preservation, stalls, reset, aperture boundaries, one response per accepted request | Loss, duplicate response or cross-aperture access |
| Byte-to-line adapters | Native aligned accesses, partial writes through byte enables, bursts and stalls; aligned address on every asserted write beat | Silent truncation or unsupported producer contract |
| Memory subsystem | Both distinct model configurations, group mapping, resets, calibration/status and CSR behavior | Devkit assumptions or unexplained model/port differences |
| BMC host bridge | Queued reads, separated AXI write channels, backpressure, pending responses and reset intervals | Stale completions, abandoned partial writes, shared-state corruption |
| PF1 FLR | Before/during/after reset, late Qsys response and global-mux-held response cases | No proven cancellation/drain policy; stop rather than mark timer expiry safe |
| CDC/reset | Domain-specific assertion/release, asynchronous crossings, FIFO/skid ownership | Undocumented crossing or reset ownership |
| Completion/host memory | Fence/user semantics, host-visible writes before notification, buffer lifetime | Posted-write acceptance mistaken for visibility |

Use failing checks to drive narrow source-supported repairs and rerun the affected test set. Retain failures and logs. Do not invent a cancellation protocol just to satisfy a bench. ASE/PIM simulation cannot qualify physical PCIe, DDR training, board reset behavior or fitted CDC/timing.

## 6. Stage D — Build the FIM and fresh PR platform

### Task D1 — Validate entry points, then run staged builds

The checked-in [OFS build entry](ofs-agx7-pcie-attach/ofs-common/scripts/common/syn/build_top.sh) supports `--stage=setup`, `--stage=compile`, `--stage=finish`, `--ofss`, `-p`, `-k` and `-e`. Setup itself can generate IP. The `-e` path passes `-end synthesis`; do not describe it as a read-only parser or assume it avoids compilation. The [flow documentation](ofs-agx7-pcie-attach/ofs-common/scripts/common/syn/README.md) explains worktree and PR production.

**Future invocation templates, deliberately not runnable until variables and gates are reviewed:**

```bash
# Run only inside the authorized workstation tmux session.
# C, WORK and REVIEWED_IA840F_TARGET must be established from the real checkout.
# Run ONE approved stage at a time, capturing its exact exit status and full log.
cd "$C"
./ofs-common/scripts/common/syn/build_top.sh --stage=setup -p \
  --ofss "nodefault,$C/syn/board/ia840f/config/ia840f.ofss" \
  "$REVIEWED_IA840F_TARGET" "$WORK"

# Only after generation/interface review passes:
./ofs-common/scripts/common/syn/build_top.sh --stage=compile -k -p \
  "$REVIEWED_IA840F_TARGET" "$WORK"

# Only after compilation/timing review passes:
./ofs-common/scripts/common/syn/build_top.sh --stage=finish -k -p \
  "$REVIEWED_IA840F_TARGET" "$WORK"
```

Recheck how this pinned flow persists options across stages before using the template. `nodefault` prevents accidental reference-board defaults; it must not suppress the explicit IA840F selection. Do not run default `all` for the first attempt. Use the native OFS/Quartus flow; do not add a bespoke build wrapper. Any later CMake targets must be CMake-native rather than hiding shell orchestration.

### Task D2 — Synthesis and fit acceptance

1. Inspect synthesized hierarchy for real BMC, intended PF/VFs, both memories, active clocks/resets and expected PR boundary; reject black boxes, accidental devkit top, missing management or silently pruned required logic.
2. Review inferred widths, ignored parameters, critical warnings and pin/IO standards against vendor evidence.
3. Fit and inspect setup/hold, recovery/removal, clock transfers, unconstrained paths, DDR reports and reset/CDC constraints. Do not globally false-path a failure or lower requested clocks without review.
4. Capture utilization and timing reports as compiler evidence, not measured performance. Check exact programmed clock configuration separately later.
5. Finish/package only after reviewed compile results. Preserve fresh QDB/interface identity, exported SDC, generated PIM configuration and PR template with source/tool hashes. No legacy 23.1 QDB substitution.

**Accept:** required logic exists, all relevant timing domains are covered and meet their approved constraints, and fresh matching FIM/PR artifacts are traceable. A zero tool exit is necessary, not sufficient.

## 7. AHLS binding and generic qualification AFU

### Task D3 — Separate platform tests from application assumptions

**Inputs:** existing `afu/ahls/rtl/`, `afu/ahls/ahls_binding_sources.tcl` and [normalized contract](afu/ahls/integration-contract.json).

1. First use the pinned OFS `examples-afu/tutorial/afu_types/01_pim_ifc/hello_world`, `local_memory` and `dma` sources as platform qualification references. Keep their source lists and test protocols isolated from the reusable platform API.
2. Build a small generic AHLS qualification component using the installed AHLS-supported flow. Preserve compiler-generated RTL/IP, register map, interface metadata and compiler invocation. Do not invent generated ports or reuse an old oneAPI `kernel_system`.
3. Add a real `ofs_plat_afu` top and import the generated AHLS component alongside the existing library. Choose and record an actual application UUID and nonoverlapping CSR allocation at this point, not in advance as a guessed platform ABI.
4. Verify CSR width, memory width/address/burst/response/user geometry, waitrequest allowance, alignment, reset, optional streams/interrupts/globals and fence semantics. Add only adapters actually required by the generated component.
5. Bind host code to the actual register map. Implement discovery, control, bounded completion, error reporting, buffer registration, transfer ordering and explicit quiescence before release/reconfiguration.
6. Treat host↔DDR DMA as a separate integration using the existing OFS implementation; ordinary PIM memory ports are not a complete transfer engine. Do not invent rings, queues or stream transport to fill gaps.
7. Generate the AFU build environment from the fresh matching PIM/PR release, then compile and review timing. The checked-in [local-memory example](examples-afu/tutorial/afu_types/01_pim_ifc/local_memory/README.md) demonstrates `afu_sim_setup`/`afu_synth_setup` source-list use; inspect the installed tools and selected platform before supplying final paths/arguments.

**Accept:** the AFU is genuinely generated-component-bound and instantiated, with matching host code and independently checked data results. The existing five-module library alone does not satisfy this stage. No oneAPI MMD/USM/host-pipe support is implied.

## 8. Stage F — Safe hardware bring-up and FPGA Tests

### Task F1 — Recovery and volatile FIM bring-up

1. Obtain explicit programming/test authorization and identify the exact card/BDF and exclusive ownership.
2. Save the known-good image identity, host-stack baseline and recovery instructions. Confirm a usable out-of-band/JTAG recovery path before replacing the running FIM.
3. Review the vendor-supported volatile programming method and exact artifact; do not assume generic `fpgasupdate` supports this BMC. Stop if safe volatile/recovery access is unavailable. Durable deployment on this host requires **QSPI flash** via the BittWare SDK `bw_agilex_flash_programmer` (reboots power-cycle the machine, so JTAG SOF is volatile-only): exact procedure, AER-off steps and recovery gates in [hw-programming-recovery.md](docs/hw-programming-recovery.md).
4. Program only the reviewed FIM. Re-enumerate PCIe and revalidate DFL/OPAE binding from Stage E.
5. Inspect link negotiation, IDs, BAR allocation, PF/VF layout, AER/kernel logs, clocks, both DDR calibrations and actual BittWare management health.

**Accept:** expected hardware identities and healthy management/calibration, without new unexplained PCIe/driver errors. Persistent flash is excluded.

### Task F2 — Ordered hardware test matrix

Run each applicable test with recorded input sizes/patterns/seeds, bounded timeouts, numerical comparisons, return status and before/after error counters. Select repeat/stress counts explicitly in the run record; never invent completed counts.

| Order | FPGA Test | Acceptance |
|---|---|---|
| 1 | DFH/DFL and OPAE discovery | Correct feature chain, FME/AFU identity, no malformed walk or probe fault |
| 2 | MMIO | Exact known-register values and side effects; access limits enforced; no broad undocumented CSR sweep |
| 3 | Per-bank DDR | Nonzero, walking-bit and address-sensitive patterns; independent bank addressing; low/high regions and supported burst boundaries; no cross-bank alias |
| 4 | Host memory/DMA | Both directions, byte-for-byte comparisons, sizes/boundaries allowed by the actual reference DMA; correct IOVA lifetime and host visibility |
| 5 | AHLS integration | Generated-register control, correct results for repeated and boundary inputs; no stale output; completion means retired visible data |
| 6 | Quiescence/PR | Drain work before reconfiguration; matching FIM/AFU interface IDs; clean rediscovery and repeat data tests |
| 7 | Reset/error paths | Only after simulated/source-reviewed safety: approved PF/VF reset cases, outstanding work handling, no stale completions or shared BMC corruption |
| 8 | Sustained operation | Agreed duration/repeats; stable data, calibrated memories, bounded completion, temperatures and error counters |

Do not start PF1 FLR-under-traffic testing while its known cancellation/drain contract remains unresolved. Do not use raw BAR4 writes as an MSI-X test until interception/decode is established. A passing MMIO or DMA test does not close those gaps.

Measure throughput/latency only after correctness passes. Record transfer size, direction, timing boundaries and live clock/link state. No performance threshold is invented here, and simulation time is not FPGA performance.

## 9. Failure handling and final deliverables

For each stage, preserve exact commands, exit status, complete logs, source/tool hashes and the first relevant failure. Do not silently retry with another target, disabled PF1, dropped BAR2, reduced memory capacity, invented pin assignments, old PR artifacts or a different toolchain. Diagnose and obtain approval for scope changes. On hardware timeout, do not free potentially live DMA buffers; retain ownership until a proven recovery/quiescence procedure completes.

**Release checklist:**

Current §9 disposition: final release remains **BLOCKED / NOT QUALIFIED**.
Offline review acceptance is recorded [separately](qualification/offline-milestone-review-01/ACCEPTANCE.md);
it does not check off the hardware release criteria below.
The new [host evidence](qualification/ahls-host-offline-01/REPORT.md) closes an
offline software checkpoint only. [UART](qualification/dfl-uart-fix-01/REPORT.md)
and [udev successor02](qualification/dfl-udev-fix-02/REPORT.md) have separate dispositions;
neither is live-verified. Existing compile success does not clear the recorded
timing failures. All hardware matrix checks below remain unchecked. Historical
bare-RPD/reboot instructions are withdrawn, as marked in the recovery document.


- [ ] Source pins and current/donor provenance reconciled.
- [ ] Generated memory/PCIe/BMC/AHLS contracts reviewed.
- [ ] Protocol and reset/CDC tests pass, with unsupported cases explicitly blocked.
- [ ] FIM synthesis/fit and relevant timing domains accepted.
- [ ] Fresh matching PIM/PR platform and actual AHLS AFU built.
- [ ] DFL kernel/driver and OPAE userspace versions, bindings and non-root access verified.
- [ ] Board management, both memories, DMA, AHLS results, quiescence and approved PR/reset tests pass.
- [ ] Hardware error/thermal/stress evidence recorded.
- [ ] Feature matrix distinguishes qualified, restricted and unsupported capabilities.
- [ ] Final report links every artifact/test result and states all unperformed checks.
- [ ] Persistent deployment remains separately authorized.

The final handoff is `qualification/<run-id>/report.md` plus an artifact/checksum inventory and updated [feature matrix](docs/feature-matrix.md). Build success, driver installation and hardware qualification must be reported separately. No stage in this plan has been executed by creating the document.

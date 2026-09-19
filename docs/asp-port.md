# IA840F oneAPI ASP source port — generation locked

## Status and scope

This is an **unqualified, source-only configuration port**, not a generated BSP,
installed runtime, working host-pipe implementation, or FPGA image. No setup,
configure, IP generation, compiler, simulation, test, or hardware command was run.
Quartus **26.1.1 compatibility is unverified**. The old source is from the 23.1-era
IA840F distribution; neither that history nor current XML version labels establish
compatibility with the requested future toolchain or OFS FIM.

Upstream basis: `oneapi-asp` commit
`1af2ca74c452cb6ebbf54beb86e758e53489e826`, specifically its `n6001/` layout.
Upstream `README.md` advertises N6001 and D5005, not IA840F. N6001 provides
`ofs_n6001`, `ofs_n6001_usm`, `ofs_n6001_iopipes`, and
`ofs_n6001_usm_iopipes`; its text incorrectly calls these “2” variants while
listing four. This local addition provides only the following two:

| Target | Configured source functionality | Qualification |
|---|---|---|
| `ofs_ia840f` (default) | One DMA channel and local DDR memory system | Unverified |
| `ofs_ia840f_usm` | Same, plus upstream host/shared-memory USM path | Unverified |

N6001 and D5005 board files are unchanged by this port. Common MMD CMake now
has an explicit IA840F selector and rejects unsupported selectors, as described
below; common host source and hardware are unchanged by this MMD selection fix.
Nothing from old generated QDBs, images, libraries or build trees was copied.
Board additions are beneath `oneapi-asp/ia840f/`, alongside this document and
the narrow `oneapi-asp/common/source/CMakeLists.txt` selection change.

## Board evidence and geometry

Reference root (read-only):
`../../old_bsp/ia-840/IOFS_BUILD_ROOT/` relative to this document's directory.

- `ofs-ia840f/syn/syn_top/ofs_top.qsf` specifies
  `set_global_assignment -name DEVICE AGFB027R25A2E2V`.
- `oneapi-asp/ia840f/hardware/ofs_ia840f/board_spec.xml` and the sibling
  `ofs_ia840f_usm/board_spec.xml` specify device model
  `agfb027r25a2e2v_dm.xml`, two DDR4-2666 banks, each `0x400000000` bytes
  (16 GiB), 512-bit ASP interfaces, burst size 16 and bandwidth metadata 42656.
  Aggregate capacity is 32 GiB. Bandwidth is inherited metadata, not measurement.
- New `parameters.tcl` files use two banks and **34-bit byte addresses** per bank,
  not N6001's four banks and 32-bit addresses. This is the ASP address width, not
  the physical DDR row/column/bank pin geometry.
- Local-only bank bases: `0x000000000`, `0x400000000`.
  USM host address space: base zero, size `0x1000000000000`.
  USM device bank bases: `0x1000000000000`, `0x1000400000000`.

Latest interface naming/structure is retained: `device0`, `kernel_device0_0`,
`kernel_device0_1`, `kernel_host0`, `agent`/`host` roles, and compilation revision
`ofs_pr_afu`. Old `DDR`/`device`, `kernel_ddr4a/b`, `kernel_mem`, and
`slave`/`master` spellings are deliberately not restored. Board XML version
`24.1` and board environment version `2024.0` are upstream metadata, not an
assertion that any particular compiler or Quartus release supports this port.

Historical IA840F used-resource estimates are copied with explicit XML comments:
local ALMs/FFs/DSPs/RAMs = 129071/516284/778/1461; USM =
134333/537332/778/1536. They replace unrelated N6001 resource counts but must be
recomputed against the new FIM/ASP before any usable compiler budget is claimed.
No new fit or resource estimate was fabricated.

## UUIDs and source-prepared MMD selection

| Variant | AFU accelerator UUID |
|---|---|
| Local-memory/DMA | `51ED2F4A-FEA2-4261-A595-918500575509` |
| USM | `5D9FEF7B-C491-4DCE-95FC-F979F6F061BE` |

These UUIDs are unchanged from both upstream N6001 variant JSON/Tcl files and
the old IA840F branch in `oneapi-asp/common/source/CMakeLists.txt` (lines 13–16
in the old tree). New JSON cluster **names** change to IA840F; JSON UUIDs and
Tcl high/low halves agree. No new UUIDs were invented. They identify ASP AFUs,
not the FIM interface UUID: a future matching FIM interface identity must come
from the newly authorized IA840F PR release/template, not an old QDB/template.
Shared N6001/IA840F UUIDs are historical behavior, not proof of interchangeable
hardware; review collision/board-discovery policy before deploying both together.

**IA840F MMD selection is now source-prepared, not runtime-qualified.** The
local `common/source/CMakeLists.txt` adds an explicit `ASP_AFU_ID=IA840F`
branch with the historical UUID pair above and `BOARD_TYPE=1`. Existing explicit
N6001/D5005 selections retain their UUIDs and board types (1/0). An unknown,
empty or unset selector now reaches `FATAL_ERROR` rather than silently selecting
D5005; all existing board build-mmd scripts specify a supported selector. The
IA840F script still exits 78 before its unchanged configure/build body.

The old vendor CMake did **not** define `BOARD_TYPE`: its IA840F branch defined
`PCI_OCL_BSP_AFU_ID`/`SVM_OCL_BSP_AFU_ID`, and old
`common/source/host/mmd_device.cpp:116–122` compared that PCI UUID with
`N6001_PCI_OCL_BSP_AFU_ID` to derive `board_type=1`. This is the evidence for
retaining 1, not inventing a new IA840F board-type number. In current common
source, `BOARD_TYPE` initializes `Device::board_type`; its only downstream
uses are the constructor debug label and `Device::get_temperature()`. The
latter retains the vendor type-1 path
`dfl_dev.*/*-hwmon.*.auto/hwmon/hwmon*/temp15_input`, versus the type-0
SPI/hwmon `temp1_input` path. The inherited type-1 debug text still says
“n6001 board”; it describes the legacy classification, not detected IA840F
identity. No host source or board-management behavior was changed.

These static source comparisons establish selection consistency only. The
current FIM/driver's temperature-node mapping, enumeration, programming and
USM behavior still require qualification; shared UUIDs cannot distinguish the
physical boards. No configure, build, runtime or hardware validation was run.
`board_env.xml` retains the upstream OPAE/MPF/MMD library chain, but none of those
libraries is supplied or represented as built.

## Host pipes and HSSI

**True host pipes remain unqualified.** A CSR-backed FPGA Test source and opt-in
CMake target are now available under `afu/hostpipe_csr/`; see [host-pipes.md](host-pipes.md).
The official runtime uses ordinary MMD kernel-interface reads/writes for CSR pipes,
without calling the missing hostchannel functions. Compiler-generated metadata/RTL
and the ASP address-span window must still be reconciled before advertising support.
Non-CSR streaming host channels remain unimplemented: they need compiler channel
XML, real hardware endpoints and MMD hostchannel APIs. No declarations or transport
stubs were invented. USM, HSSI and generic OFS host-memory channels are not substitutes.

N6001 `_iopipes` variants are HSSI/UDP I/O pipes, not host pipes. No IA840F
`_iopipes` target is supplied because a matching physical-lane, MAC/PCS and
new-FIM interface mapping has not been verified in this port. This does **not**
claim the card lacks transceivers; it avoids advertising an unqualified path.
Both configurations keep `p_IOPIPE_SUPPORT false` and `INCLUDE_IO_PIPES`
commented out. Upstream conditional HSSI macro scaffolding remains inert.

## Source changes and fail-closed entrypoints

- N6001 board environment/name, variant XML and JSON names changed to IA840F.
- FPGA model, DDR bank count/extents/bandwidth and historical resource metadata
  taken from the old IA840F source as described above.
- Latest per-variant RTL flags retained (DMA, local write ACKs and USM where
  selected); local-memory bank-2/bank-3 enables removed. Banks 0/1 and exact
  FIM macro/hierarchy mapping still require future integration review.
- Candidate `hardware/common/build/ofs_asp.sdc` retains the latest N6001
  host/kernel clock-group structure but lists only two EMIF clocks. Exact IA840F
  FIM clock hierarchy and CDC intent are unverified; these are not qualified
  timing constraints.
- N6001's Quartus-23.3-specific `ini_password` workaround is **not** enabled:
  board-local `quartus.ini` contains only explanatory comments.
- Board-local `scripts/build-asp.sh`, `scripts/build-mmd.sh`, common `run.sh`
  and `ase-sim-compile.sh` preserve upstream bodies for review but exit 78
  before any of those bodies, tool discovery, copies or subprocesses run.
- `scripts/setup-asp.py` rejects execution before dispatching upstream setup.
  Common board-local `entry.tcl` errors before any Quartus packages/commands.
- Both XML compile flows' generate and synthesize commands call a supplied
  `sh build/scripts/source-only-stop.sh`, which exits 78. Each variant has that
  file already; the common copy protects later reviewed file-overlay use.
- There is intentionally **no environment-variable unlock**. Future explicit
  authorization must be followed by a reviewed source change that resolves the
  prerequisites below and restores upstream generation/synthesis commands.

Locks are board-local safeguards, not a security boundary. Untouched upstream
`common/scripts/` remains executable outside this board's entrypoints; invoking
it directly or copying over these locks bypasses the intended workflow and is
not authorized. Project-wide entrypoint protection is handled separately.

## Required before any future generation/build

1. Explicit user authorization for the exact configure/generate/build stages.
2. Complete and review the IA840F FIM/PIM migration, physical memory interface,
   bank ordering, clocks, reset, PCIe PF/VF layout and USM/VTP prerequisites.
3. Qualify exact Quartus/device-support/oneAPI-FPGA/OPAE versions. An installed
   Quartus 26.1.1 does not establish support. No remote toolchain was inspected.
4. Qualify the source-prepared IA840F MMD selection and board management, and
   resolve the true host-pipe hardware/API contract; do not use I/O pipes or USM
   as substitutes.
5. Obtain a matching newly generated IA840F FIM PR template/interface UUID only
   after authorization. Do not import old compiled artifacts into this tree.
6. Confirm exact SDC hierarchies and update resource accounting; bind dependencies
   rather than relying on disabled upstream scripts' mutable clone defaults.
7. Review unlocking all board-local entrypoints and restore the upstream
   `generate`/`synthesize` commands deliberately, not through an automatic bypass.

## Static checks performed

Python standard-library XML/JSON parsing and source-text inspection confirmed
both targets' two nonoverlapping 16-GiB banks, aggregate capacity, matching
JSON/Tcl AFU UUID halves, disabled bank-2/bank-3 RTL macros, and the presence of
blocked generate/synthesize commands. File inventory contains no QDB, object,
static/shared library, AOCX, GBS, RBF or RPD artifacts. These are source checks,
not tests of scripts, tools, timing, runtime, compilation or physical hardware.

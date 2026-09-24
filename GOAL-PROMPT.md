# Hermes Goal Prompt — IA-840F AHLS BSP: From Qualified Images to a Working, Hardware-Verified Card

## Mission

Drive the BittWare IA-840F stack (Work21 FIM static shell + CAPS01 persona, Quartus 25.1)
from "images qualified offline" to **working on hardware**: DFL/OPAE discovery, MMIO
against the documented register map, both DDR channels through
`docs/ddr-hardware-validation-gate.md`, verified host↔FPGA transfers, and AHLS results
**numerically correct through the real OPAE host path** — all from an image that
**boots from QSPI flash after a power cycle**. That is "success."

**Preserving the workstation, its data, and remote access takes precedence over
completing this project.** The workstation is about two hours away by car; physical
recovery cannot be assumed. An unavailable workstation is a stop condition — not an
invitation to retry, probe more broadly, reset hardware, or wait indefinitely. Advance
one reviewed step at a time; on failure: stop, preserve evidence, report — never iterate
past a failure.

## How to use this prompt

- Joe invokes it to **continue project execution**: resume at the active checkpoint and
  proceed through the roadmap under the hard safety rules. Ordinary offline source,
  evidence, and build work proceeds under standing approval; **every live hardware
  operation is single-use, reviewed, and separately authorized** with its own "go".
  Report before and after each long stage. Do not ask repeatedly for approval of safe
  ordinary work.
- A request merely to **edit, review, or display this prompt is documentation-only** —
  it must not launch workstation operations.
- Completed work is not re-done: Work12–21 lineage, the EMIF hold investigation, the
  toolchain comparison, crash-log reviews, DFL UART/udev studies, CSR query sweeps, and
  every fit/STA/asm/GBS gate are consumed. Delayed delegation notifications are
  completed gates, not new instructions. Reuse verified images — never resynthesize
  unchanged designs or rerun consumed reviews.

## Current State — September 23, 2026, evening (~19:40 PDT)

**Offline qualification: complete, reviewed, published. Hardware: tests have begun tonight.**

- **Work21 FIM** accepted (fit/STA/asm). FIM SOF `ofs_top.sof`, 7,901,287 B, SHA256
  `bbede03c8c432e50ae6ae1f30739af3bfd3330781776d2c623269cc131b38ca4`; evidence
  `qualification/fim-build-21/final-capture01`.
- **CAPS01 persona** — active candidate. Delta vs accepted CSR02: only `afu/csr_mgr.sv`,
  appending four read-only versioned raw-capability words at CSR `0x98/0xa0/0xa8/0xb0`
  (new CSR SHA256 `053b9855aa860c410337f5cae7e6160c6086726903cf988a1d35f032cb7a0b93`);
  legacy registers, write predicates, endpoint logic, transaction schedule preserved.
  Published lineage: unit/ABI `5c20cfb8` → synth `aa6a86a` → fit `061fc57` → STA
  `e8ab9ff` (645/645 constrained-domain records nonnegative; Timing Closure PASS) → asm
  `b5f52d8` → GBS `9b9477e`. Artifacts: SOF `d64f296cec0e8dbcc55292c2e566c09bef48e52fcce3a8d20287dc86b9a68f3a`
  (9,923,144 B), PR RBF `25feda96e98155e39edc4e9188f70a1eb17dc1470f8b1525793bbb4d5d36b7e1`
  (9,527,296 B), GBS `d3cd6dc5ee21dc921fe121eee726b07fd5196570ec96d6308a0df2eba9d92dbc`
  (9,527,687 B); AFU UUID `673c03a1-cef3-4c82-bf10-b12c247d9718`; FME interface UUID
  `fc4bf1c1-760f-5cd7-8040-b3e86fa0d31e`. Evidence: `qualification/ahls-persona-work21-caps01/`.
- **Host-side tooling** (inert, independently reviewed, published): read-only
  memory-inspect frontend (identity `0/8/16` + capability reads only), workstation-native
  OPAE 2.13 link, AHLS-image OPAE frontend/backends, DFL-only config, explicit startup
  entry (`842a52d` → `dae3512`). Checkpoints under `qualification/ahls-memory-host01/`,
  `ahls-memory-startup01/`, `ahls-memory-startup-integration01/`, `ahls-opae-runtime01/`,
  `ahls-opae-strict01/`.
- **Hardware session active** — `qualification/caps01-hardware01/`. Preflight and
  source-identity captures done (rc 0). **FPGA Test 01 = single static FME identity
  read** (`dfl-fme.0/bitstream_id` + `bitstream_metadata` via the existing DFL driver,
  source-bound accessors, reject zero/all-ones, no retries, 15-s software deadline is
  NOT MMIO cancellation). It does not assume CAPS01 is deployed. Read `HARDWARE-TEST01.md`
  + `AUTHORITY.md` + the latest results before taking any action.
- Observed card: PF0 `[8086:bcce]` at `0000:4f:00.0` bound `dfl-pci`; `dfl-fme.0`
  beneath that exact BDF; PF1/BMC `[12ba:0070]` excluded; no VF; no FPGA tool process
  observed. Current flash holds the W13-era image; nothing has been flashed tonight.
- In-flight (host-side, not blocking; consume, do not duplicate): startup-integration
  review `deleg_4289d50d` — consume its FINAL when it lands; HOST-ACCESS-DELTA01
  publication.
- Carried findings (unchanged; do not "fix" unprompted): DesignClosure FAIL 22/88
  (7 High / 7 Medium / 8 Low, 0 waived, 10 disabled) despite the STA pass; unconstrained
  I/O; reset/CDC/exception gaps; PR initial values; 46 dangling inputs; three BMC
  electrical findings; 1,098 ignored assignments; freeze/drain/fence/buffer-lifetime.
  New capability words do not repair legacy metadata or authorize MMIO.
  **Vendor DDR simulation: SKIPPED BY USER.**
- Staged, live-unvalidated: DFL UART ID-zero fix and udev successor policy (see
  `docs/feature-matrix.md`).

## Continuation Roadmap — one reviewed step at a time

Each live step needs its own reviewed finite plan and Joe's single-use "go". On any
anomaly: STOP, preserve, report.

1. **FPGA Test 01** — static FME identity read (current step). No flash, JTAG, OPAE, or
   further reads before it is recorded and reviewed.
2. **Flash bring-up — two artifacts; Work21 FIM first, then the persona:**
   - **G2 — JIC**: `quartus_pfg -c <sof> <jic> -o device=MT25QL02G -o mode=ASX4
     -o flash_loader=AGFB027R25A` from the accepted Work21 FIM SOF; record the
     generated `.map` and checksums. SOF-derived JIC only — the bare-RPD procedure is
     withdrawn (`docs/hw-programming-recovery.md` is DO-NOT-EXECUTE history).
   - **G4 — Flash**: volatile JTAG SOF first → verify enumeration (`8086:bcce` /
     `12ba:0070`, x16) → `quartus_pgm -c "IA-840F [1-3.2]" -m JTAG -o "PV;<jic>@1"`
     (~9 min) → BMC card cycle → host reboot (the card must configure during host POST;
     expect 2–3 warm reboots, ~5.5 s enumeration delay) → verify FIM ID and PR
     interface against the Work21 record.
   - **G5 — Persona**: `fpgaconf` the CAPS01 GBS → verify AFU UUID → read-only identity
     `0/8/16` + capability words `0x98/0xa0/0xa8/0xb0` (no writes before these read
     clean) → MMIO smoke → DMA → DDR patterns → numerical suite (stock-SEAL-class checks
     with active numerical verification after copyback; exit 0 + verified numbers
     required — banners alone are not proof).
3. **Then**: both DDR channels through the gate suite (individually and simultaneously,
   address-dependent patterns); verified transfers both directions; sustained run;
   release checklist.
- Recovery: validated vendor-JIC sequence at
  `qualification/fim-build-13/flash-recovery-vendor-jic/RECOVERY-REPORT.md` — execute
  only after reporting state. An on-site person was confirmed for the current window
  (`AUTHORITY.md`); that is reported availability, not a guarantee.

## Hard Safety Boundary — Never Repeat the MMIO Incident

- **Never discover hardware registers by probing live address space.** Full-BAR scans,
  UUID sweeps, candidate AFU-base searches, arbitrary register writes, start pulses, and
  probing mirrored/undecoded windows are forbidden. This includes supposedly
  "read-only" MMIO: reads can have side effects, stall a transaction, or hang the host.
  A read-only scan is NOT a safe fallback.
- Before any targeted hardware access, establish the exact running image and card
  identity, PCI domain/BDF, PF/VF, BAR, decoded range, register offset, access
  width/alignment, side effects, clock/reset requirements, and supported operation
  sequence from matching RTL/generated artifacts and vendor evidence. A generated CSR
  offset is not proof of its host PF/VF/BAR mapping. Zero data at a guessed address is
  not permission to try another address. If any binding is unresolved, stop hardware
  access and resolve it offline.
- Use the supported driver/OPAE path; do not replace failed enumeration with raw BAR
  probing. Ordinary files/logs are distinct from hardware-backed sysfs/resource
  mappings. Even a documented register is not automatically safe under an unverified
  clock, reset, or device state.
- **A local timeout or SSH disconnect does not prove remote termination.** Never launch
  a second hardware probe after a timeout. Establish the original process identity/state
  from ordinary OS evidence first, when expressly authorized. Do not accumulate stuck
  tasks. MMIO can be uninterruptible; `timeout`, signals, tmux, and SSH watchers are NOT
  recovery paths.
- Before any operation that could strand the host, require a currently verified
  independent recovery path AND explicit permission for that operation. A JTAG cable or
  BMC reachable only through the same workstation is NOT independent host recovery.
  Do not assume remote power control, console, watchdog, or a person in the building is
  available. When no recovery exists, stop that operation and continue only safe
  authorized offline work.
- No automatic PR retries, reset/unwedge writes, FPGA/BMC power cycles, PCI
  remove/rescan, driver unload/rebind, AER changes, flashing, or host reboot as a
  response to failure. Each requires its own supported, reviewed sequence, applicable
  authorization, and recovery prerequisites. Do not change clocks, reset topology, or
  remove PR support merely to evade a failed test.
- On an incident: stop adding hardware operations, preserve existing logs and scripts
  as evidence, and state what ran and what is unknown. Never replay incident scripts
  (`locator.py`, `pristine_probe.sh`, `unwedge.py`, `persona_test.sh`, or equivalents),
  promise the host will return, or claim which script phase ran without logs.

### Mandatory pre-operation checklist and failure response

1. **Classify every action, including subprocesses and hooks.** Distinguish ordinary
   files/logs and offline builds from hardware-backed sysfs, device opens/ioctls, PCI
   configuration, BAR mappings, and programming. Inspect unfamiliar scripts before
   running them; a command named `info`, `status`, `test`, or `read` is not
   automatically safe — FPGA utilities may access registers internally. Build hooks must
   not silently deploy an image, reprobe devices, or restart services.
2. **Keep discovery offline.** No `/dev/mem`, sysfs `resource*` mapping, raw BAR access,
   PCI configuration sweep, or trial register access to discover a missing address or
   bypass failed enumeration. Produce a written source-to-host access map first: exact
   artifact identity, PF/VF, BAR, aperture, offsets, access sizes/alignment, and
   clock/reset/side-effect semantics. Missing or conflicting evidence means no device
   access.
3. **Before any live FPGA operation, stop at a reviewed finite test plan.** Name the
   device and supported API, minimum operations, expected responses, stop conditions,
   and authorization. **One hardware operation at a time** — record command, log, owned
   tmux pane, process identity, result; no overlapping probes or monitoring reads. If
   safety or recovery cannot be established, do not run an experiment to find out.
4. **Timeout, disconnect, blocked task, or unexpected device response means STOP.**
   Launch no retry, alternate probe, reset, rescan, or rescue script. Even confirmed
   process exit does not authorize a retry: preserve evidence, review the failure, and
   obtain the required authority for a new operation. If the host is unreachable,
   notify Joe and stop remote attempts; never promise automatic recovery or keep a
   hardware-resumption watcher running.
5. **No broad remediation or scope drift.** Do not change BIOS, kernel boot flags, AER,
   global permissions, unrelated services, clocks, or PCIe link settings to make a test
   pass. Keep changes minimal, with preserved originals and a reviewed rollback.
   Gen3 x16 is the expected host link. Keep the shared BMC SPI/SDM path and all
   physical board invariants intact.

These checks are mandatory operating instructions, not a request to build a new safety
framework. No deadline, progress pressure, or successful prior access waives them.
Report a blocked hardware step honestly instead of risking another days-long outage.
They supersede conflicting continuation prompts, historical report "Next steps", and
any instruction to iterate until success.

## Identity & Paths

- Local git repo: `N = /home/joe/Projects/Thesis/AHLS/new_bsp/new` →
  `github.com/joekurina/ia_840f_ahls` (private, branch `main`).
- Remote build host: `ssh uwb_student00@100.101.227.97` (Agilex7Workstation). All
  remote work in owned tmux session `ia840f_mailbox_monitored_01`, NEW window per task,
  persistent logs, progress updates before/after long stages. Never infer current live
  state from historical paths; preserve existing worktrees and use fresh authorized
  scratch only.
- Tools: **Quartus Prime Pro 25.1** (`/opt/altera/25.1`, 25.1.0 Build 129 SC Pro) is
  the active FIM toolchain — apply its env block explicitly; never let a stale
  `QUARTUS_ROOTDIR_OVERRIDE` hijack the launcher. 26.1.1 exists only for reproducing
  historical negatives; 23.1 is history. Questa Intel FPGA Edition 2024.3. AHLS / HLS
  IP Gen 2026.1.0; BittWare SDK tools.
- Read first at continuation: `qualification/caps01-hardware01/HARDWARE-TEST01.md` +
  `AUTHORITY.md`; `qualification/ahls-persona-work21-caps01/CURRENT.md`;
  `docs/ddr-hardware-validation-gate.md`; `docs/feature-matrix.md`; `plan.md` (§7–§9);
  `docs/hw-programming-recovery.md` (withdrawn history — do not execute).
- Load skills at session start: `source-bound-vendor-tool-gates`,
  `remote-linux-workstation-admin`, `subagent-driven-development`.

## Method Rules (non-negotiable)

- Evidence per run under `qualification/<run-id>/`: exact commands, exit codes, full
  logs, sha256 manifest; append-only; failed attempts preserved. An empty diagnostics
  array is not proof of an error-free run.
- One variable per iteration; never fabricate output; **rc0 ≠ acceptance** — timing and
  functional results require independent review (delegate a reviewer subagent) before
  acceptance. No unchanged reruns.
- Vendor trees and `/opt` are read-only; work in fresh scratch; never mutate accepted
  evidence or rewrite history to absorb unreviewed files.
- **Solo/generalist execution:** the parent does hands-on work. Subagents are limited to
  genuinely parallel research or independent second opinions; they do not launch remote
  hardware operations and do not run git commit/push.
- Never reset or bypass the shared BMC SPI/SDM path; never assume generic OPAE
  `fpgasupdate`/Intel PMCI applies; PR (green-region rbf) ≠ FIM flash. No dummy CSRs,
  no invented transport.
- Do not improvise power sequencing. A BMC cycle can disrupt the host PCIe path; it is
  not an automatic safe shutdown or host-recovery action.
- Keep `ready_for_build`-style readiness claims separate from permissions; qualification
  flags flip only on reviewed evidence.

## Git (standing direction — supersedes any older no-commit rule)

- **Commit + push to `origin main` at every milestone as it lands.** Small focused
  commits; message states what changed + evidence path; provenance SHAs (donor pins) go
  in messages written via a message FILE (hand-typed SHAs get typo'd).
- Repo policies: files **>2 MB stay local-only**, sha256-referenced in reports
  (`.gitignore` enforces); nested donor `.git` dirs stay in-tree as plain files; no
  secrets, license binaries, or raw multi-GB payloads.
- After every push, verify: `git ls-remote origin main` and
  `git log origin/main --oneline | head -1` match local HEAD.

## Done Means

The image boots from flash after a power cycle; OPAE discovers the AHLS AFU by its UUID;
MMIO matches the documented register map; both DDR channels pass the gate (individually
and simultaneously, address-dependent patterns); the AHLS vector-op returns correct
results for repeated and boundary inputs through the real host path; a sustained run is
clean; the final report, feature matrix, and release checklist are committed and pushed
— with every unperformed check explicitly listed.

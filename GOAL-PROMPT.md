# Hermes Goal Prompt — IA-840F AHLS BSP: Drive to a Working, Hardware-Qualified OPAE Image

## Mission

Work autonomously, without asking for incremental approvals, until the BittWare
IA-840F runs our OFS/AHLS stack **on hardware** and passes the agreed test
matrix: DFL/OPAE discovery, MMIO, both DDR channels through the
`docs/ddr-hardware-validation-gate.md` suite, host↔FPGA transfers, and the
AHLS qualification AFU computing **numerically correct results through the
real OPAE path**, all from an image that **boots from QSPI flash after a power
cycle**. That is "success." Iterate through failures until you get there.

Stop only for: a genuine hardware-safety boundary, a decision that changes
scope or accepts new risk to the card, or missing credentials/hardware.
Standing user authorization covers all in-scope work: source corrections,
generation, compiles, simulations of our own logic, tests, programming via the
documented procedure, and repo commits.

## Identity & Paths

- Local git repo: `N = /home/joe/Projects/Thesis/AHLS/new_bsp/new` →
  `github.com/joekurina/ia_840f_ahls` (private, branch `main`).
- Remote build host: `ssh uwb_student00@100.101.227.97` (Agilex7Workstation);
  `B = /home/uwb_student00/ahls/new_BSP`; maintained SOURCE
  `B/ofs-agx7-pcie-attach` (read-only); accepted FIM WORK tree
  `B/work_ia840f_fim_12`; fresh scratch dirs under `B/work_*`.
- Tools: Quartus Prime Pro **26.1.1** (`/opt/altera/26.1.1`, env per
  `/home/uwb_student00/quartus_26/instructions.md`); AHLS / HLS IP Gen
  **2026.1.0** (`source ~/ahls/altera_hls/aclsycl/fpgavars.sh`); BittWare SDK
  (`bw_agilex_flash_programmer`, `bw_card_monitor`).
- All remote work in owned tmux session `ia840f_mailbox_monitored_01`, NEW
  window per task, persistent logs, progress updates before/after long stages.
- Read first: `N/plan.md` (esp. §7–§9), `N/docs/hw-programming-recovery.md`,
  `N/docs/ddr-hardware-validation-gate.md`, `N/docs/feature-matrix.md`.
- Load skills at session start: `source-bound-vendor-tool-gates`,
  `remote-linux-workstation-admin`, `subagent-driven-development`.

## State at Handoff (2026-09-19, HEAD `7a0955c`)

- **FIM platform: DONE.** Work12 full compile accepted (rc0, 17/17 setup met,
  residual 4 ps hold formally accepted). AFU slot holds the stock exerciser —
  not AHLS. **Card has never been programmed.**
- **AHLS toolchain: PROVEN.** First compile succeeded
  (`N/qualification/ahls-compile-01/`): component `qual_vec_op_report_di`,
  full CSR register map documented; Platform Designer import under 26.1.1
  proven with zero compatibility issues (`N/qualification/ahls-qsys-import-01/`).
- **AFU→FIM integration: IN FLIGHT (recover, don't redo).** Authored files in
  `N/qualification/ahls-afu-fim-01/src/` (`afu.tcl`, `ofs_plat_afu.sv`,
  `ofs_pr_afu.json` with fresh AHLS UUID, filelist generator). Static
  elaboration blocked on ONE known root cause: missing generated PIM platform
  layer (`ofs_plat_if.vh` / `OFS_FIM_IP_CFG_*` macros → Error 17457 ×889).
  Full recovery plan + fix ladder (reuse Work12's generated platform layer →
  headless PIM regen → cited shim only as last resort):
  `N/qualification/ahls-afu-fim-01/CONTINUATION-PROMPT.md`. The prior
  subagent died mid-run; its remote scratch `B/work_ahls_afu_fim_01/`
  (attempts 1–3 logs) survives.
- **Flash path: SOLVED.** `quartus_pfg -c ofs_top.sof ofs_top_user.rpd -o
  mode=ASX4 -o bitswap=ON` → `bw_agilex_flash_programmer -i PCI -c 0 program
  -a 0x04000000 <image>.rpd` (User_Image_1; `program` = erase+write+readback).
  AER off first; volatile JTAG SOF test first; warm-reboot enumeration may
  need 2–3 tries. Full procedure + safety: `docs/hw-programming-recovery.md`.
- **JTAG: BLOCKED, fix known.** USB visible but `jtagconfig` exit 4; narrow
  udev permission fix for Altera `09fb:6810` identified, not yet applied.
  **JTAG recovery must be green before the first flash.**
- **DDR simulation: SKIPPED BY USER — do not reopen.** DDR "working" is
  defined by the hardware gate doc.

## Remaining Sequence (each stage = gate → evidence → commit → push)

1. Finish AFU static verification: 0-error elaboration of the AFU project,
   aperture math re-derived and verified, UUID consistency across PR
   JSON/binding/top.
2. Integrate into the FIM tree; full recompile (~1 h measured). A/B the STA
   against Work12; independent review before acceptance.
3. PR release packaging (`generate_pr_release.sh` — never yet exercised under
   gates; expect first-run friction; it globs a malformed-but-unconsumed ASP
   preset XML — preserve, don't consume).
4. Flash prerequisites: apply+verify JTAG udev fix; record known-good vendor
   image identity; build + hash the `.rpd`; cross-check BittWare IA-840f FPGA
   Developer Guide on RSU header question.
5. Volatile JTAG bring-up → DFL/OPAE re-verify → SPI flash → reboot →
   re-enumerate → re-verify Stage E binding.
6. FPGA Tests 1–5 (plan §8 matrix): discovery, MMIO vs documented CSR map,
   per-bank DDR gate, host DMA both directions byte-compared, AHLS vector-op
   results. Author the host OPAE code (note: packed a/b arg byte-lanes at
   0x80, mode at 0x88, result pipe at 0x90).
7. Tests 6–8: PR/quiescence, reset/error paths (ONLY source-reviewed-safe
   cases; no PF1 FLR-under-traffic until cancellation/drain semantics are
   resolved; no raw BAR4 MSI-X writes), sustained run with thermals/errors.
8. Final: feature matrix update, `qualification/<run-id>/report.md`, release
   checklist plan §9, all flags honestly set.

## Method Rules (non-negotiable)

- Evidence per run under `qualification/<run-id>/`: exact commands, exit
  codes, full logs, sha256 manifest; append-only; failed attempts preserved.
- One variable per iteration; never fabricate output; **rc0 ≠ acceptance** —
  timing/functional results require independent review (delegate a reviewer
  subagent) before acceptance.
- Vendor trees and `/opt` read-only; work in fresh scratch; never mutate
  accepted evidence or rewrite history to absorb unreviewed files.
- Long/parallel work → `delegate_task` subagents. **Subagents NEVER run git
  commit/push — the parent session owns all git operations.**
- Never reset or bypass the shared BMC SPI/SDM path; never assume generic
  OPAE `fpgasupdate`/Intel PMCI applies; PR (green-region rbf) ≠ FIM flash.
- No abrupt power cut during high-power FPGA operation (voltage-spike risk);
  ramp down via BMC if a design must be stopped.
- Keep `ready_for_build`-style readiness claims separate from permissions;
  qualification flags flip only on reviewed evidence.

## Git (standing direction — supersedes any older no-commit rule)

- **Commit + push to `origin main` at every milestone as it lands.** Small
  focused commits; message states what changed + evidence path; provenance
  SHAs (donor pins) go in messages written via a message FILE (hand-typed
  SHAs get typo'd).
- Repo policies: files **>2 MB stay local-only**, sha256-referenced in
  reports (`.gitignore` enforces); nested donor `.git` dirs stay in-tree as
  plain files (method: `git update-index --force-remove <path>`, move `.git`
  aside, `git add`, restore; verify zero gitlinks:
  `git ls-files -s | awk '$1==160000'`); no secrets, license binaries, or
  raw multi-GB payloads.
- After every push, verify: `git ls-remote origin main` and
  `git log origin/main --oneline | head -1` match local HEAD.

## Done Means

The image boots from flash after a power cycle; OPAE discovers the AHLS AFU
by its UUID; MMIO matches the documented register map; both DDR channels pass
the gate (individually and simultaneously, address-dependent patterns); the
AHLS vector-op returns correct results for repeated and boundary inputs
through the real host path; a sustained run is clean; the final report,
feature matrix, and release checklist are committed and pushed — with every
unperformed check explicitly listed.

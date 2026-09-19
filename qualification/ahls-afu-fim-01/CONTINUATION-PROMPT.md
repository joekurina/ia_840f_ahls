# Continuation Goal Prompt — ahls-afu-fim-01 (recovery + completion)

## Goal

Complete the AHLS AFU → FIM PR-slot integration **static verification** under
Quartus 26.1.1 (NO full FIM recompile yet), recovering and finishing the work
of a subagent whose delegation owner died mid-run (outcome was never recorded).

Work **until static verification genuinely succeeds** (quartus_sh
analyze/elaborate of the AFU hierarchy with zero errors) or until you hit a
real design boundary that a library addition cannot solve — in which case
document it precisely. Do not stop at cosmetic completion; do not fake or
patch warnings away.

## Recovery — do this FIRST

A prior subagent (deleg_efe1c772) died at 2026-09-19 ~13:34 local after
authoring the integration files and running 3 static-verification attempts.
Its artifacts survive and are the baseline you build on:

**Local (authoritative authored files):**
- `N/qualification/ahls-afu-fim-01/src/`:
  - `afu.tcl` — the missing CRITICAL-gap Platform Designer script binding the
    AHLS component into the PR slot
  - `ofs_plat_afu.sv` — the real `ofs_plat_afu` top importing the AHLS chain
  - `ofs_pr_afu.json` — PR AFU JSON, default-exerciser UUID replaced with
    fresh AHLS UUID
  - `ahls_qual_vec_op.json`
  - `gen_ahls_filelist.py`
- Transcript of the dead run (to mine for intent):
  `/home/joe/.hermes/cache/deleg_ation/live/deleg_efe1c772/task-0.log`
  (actual path: `/home/joe/.hermes/cache/delegation/live/deleg_efe1c772/task-0.log`)

**Remote (uwb_student00@100.101.227.97, B=/home/uwb_student00/ahls/new_BSP):**
- Scratch `B/work_ahls_afu_fim_01/` — contains:
  - Root copies of the same 5 files + `awp/` (attempt-3 project: qpf/qsf,
    qdb, dni, `ahls_afu.syn.ae.rpt`, flow/syn reports)
  - `logs/attempt2_ae.log`, `logs/attempt3_ae.log`, `logs/assemble_and_static_verify.log`
- Owned tmux window `ia840f_mailbox_monitored_01:afu_int_01` (window 296) —
  idle; DONE3 marker at end. **Reuse this window** (it is the owner's
  persistent log); do not create spurious new windows.

**Diagnosed state (from dead child's transcript tail):**
- Attempts 1–3 of `quartus_sh --analyze_elaboration` failed with **889 errors,
  all one systematic root cause**: the PIM/platform macro layer is missing at
  elaboration — `ofs_plat_if.vh` and platform macros (e.g.
  `OFS_FIM_IP_CFG_*`) never expand, so PIM generator ranges error as
  `Error 17457: range must be bounded by constant expressions` (e.g.
  `ofs_plat_utils_ccip_gen_bmask.sv:22`,
  `ofs_plat_host_chan_gen_wr_tlps.sv:127`).
- Attempt-2 errors (missing include `ofs_plat_if.vh`, undeclared
  `local_mem_cfg_pkg`) were partially fixed in attempt-3 (cwd moved to
  `$S/awp`, include path fixed, `.vh` removed from sources); the residual 889
  are the macro layer.
- This is **not a design error** — it is the missing generated platform layer
  that the FIM flow generates at IP-generation stage (`build_top.sh`), which a
  standalone AFU project must supply.

## Fix strategy (in order of preference)

1. **Reuse Work12's generated platform layer.** The accepted Work12 WORK tree
   `B/work_ia840f_fim_12` already generated `ofs_plat_if.vh` + platform build
   dir for its AFU (the exerciser). Locate it (likely
   `src/afu_top/mux/`... find `ofs_plat_if.vh` and the PIM `build/platform`
   tree under the Work12 WORK tree). Copy (read-only source, fresh scratch
   destination) into the attempt-3 project so the macros expand. Check
   host-chan config consistency (Work12's platform was generated for
   native_axis_pcie_tlp 512-bit / 51-bit line addr — matches ours).
   Record sha256 of reused files.
2. If reused platform files are config-mismatched (macros disagree with our
   afu.tcl parameters), regenerate the platform layer headless via the PIM
   scripts (`afu_with_pim/afu.tcl` flow: `ofs_plat_afu_setup.tcl` /
   `build/platform` generation) in the fresh scratch, following the flow
   `build_top.sh` uses (read `B/ofs-agx7-pcie-attach/ofs-common/scripts/common/syn/build_top.sh`
   and the `pim.tcl`/`ofs_plat_*.tcl` it invokes to learn the exact
   generation step and its required env/args).
3. Only if both fail: author a minimal macro shim (e.g. `ofs_plat_afu_params`
   overrides) — but **never invent PIM parameters**; every shim value must be
   cited from Work12 generated files or donor AFU examples.

## Verification bar (success criteria)

- `quartus_sh --analyze_elaboration` (or equivalent 26.1.1 elaboration) of the
  AFU project: **0 errors**. Warnings reviewed, severe ones dispositioned.
- Port-width/address consistency verified and recorded: component
  `csr_ring_root_avs` (5-bit word addr, 64-bit) ↔ binding
  `csr_address[19:0]` byte addr ↔ PR boundary 512-bit/51-bit line addr ↔
  CSR aperture (CSR_BASE_BYTES=0x40, CSR_SIZE_BYTES=0x100 from the dead
  child's math — verify this math yourself and correct if wrong).
- The PR JSON UUID matches the UUID in `ofs_plat_afu.sv` / binding instance.
- No source-tree mutation of vendor/maintained trees (all work in fresh
  scratch under `B/`; maintained SOURCE `B/ofs-agx7-pcie-attach` read-only).

## Git repo instructions (important — new standing convention)

- Repo: `github.com/joekurina/ia_840f_ahls` (private), branch `main`.
  Local root N is the git tree. Current HEAD at dispatch time: `7a0955c`.
- **You do NOT commit or push** — the parent (Hermes main agent) owns all
  commits. Deliverables land on disk under `N/qualification/ahls-afu-fim-01/`
  (append-only; never delete prior evidence) and the parent commits them.
- Do not run any git commands except read-only inspection (`git status`,
  `git log --oneline -5`) to confirm the tree state. Never `git add`, commit,
  push, checkout, reset, or stash.
- Keep every artifact ≤2 MB per file (repo policy); hash-reference larger
  outputs in the report and leave them local-only (the report records their
  sha256 + path).
- If you need a stable identity for your deliverables, write a
  `manifest.json` in your evidence dir (file → sha256, size, role) — the
  parent will use it when committing.

## Deliverables

- Completed static verification with 0 errors, logs + reports under
  `N/qualification/ahls-afu-fim-01/` (append-only) + remote mirror at
  `B/qualification/ahls-afu-fim-01/`.
- `report.md` updated: recovery summary, platform-layer fix chosen (which
  option, why, file provenance + hashes), attempts ledger (attempts 1–3 from
  dead child + your own numbered attempts), final elaboration result
  (exit code, error/warning counts), aperture math verification, UUID
  consistency check, open risks for the recompile stage.
- `manifest.json` (file → sha256) for everything you wrote or changed.
- Progress updates to the parent transcript before/after long steps (the
  workspace persists across your calls).
- Mirror deliverables to remote `B/qualification/ahls-afu-fim-01/` via the
  same hash-verified tmux-buffer or scp method used previously.

## Hard rules

- No FIM recompile, no synthesis, no hardware access, no programming.
- No commits/pushes (parent-owned). No vendor-tree writes. No fabricated
  results — if a step fails, log it and iterate; honest failure documented
  precisely beats a green lie.
- One variable at a time; every attempt logged with full command + exit code.
- Load skills before starting: `source-bound-vendor-tool-gates`,
  `remote-linux-workstation-admin`, `subagent-driven-development`.

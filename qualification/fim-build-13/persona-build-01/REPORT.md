# Persona Build-01 & PR Engine Live-Probe — Report

Run: 2026-09-19/20, Agilex7Workstation, W13 FIM running from flash
(Bitstream `0x5010202599AC052`, interface `c281e23b-5a95-5aa9-8678-d2ecf1f80f6c`).

## 1. Sanctioned persona GBS — built successfully

- Flow: `afu_synth_setup` + release `bin/afu_synth` in `work_ahls_persona_01`
  against frozen W13 `ofs_top.qdb` (pr_release_13a tree, gate hook scoped out of
  this scratch build only — documented in run2 script; build 1 was invalidated
  by 125091 gate-rejection discipline and preserved at `persona_build.log`).
- Build 2 result: **full compile successful, 0 errors, 685 warnings**
  (`persona_build2.log`: SYN_RC=0, RC=0; gen_gbs.tcl OK).
- Artifact: `work_ahls_persona_01/build/syn/board/ia840f/syn_top/output_files/ofs_pr_afu.green_region.gbs`
  6,873,478 B, payload 6,873,088 B raw, interface-uuid `c281e23b-…`,
  AFU uuid `67bc266a-56f7-440a-bb75-12b5f446d842`, magic-no 488605312.
- Hierarchy verified in syn report: full chain
  `pr_slot|afu_main|port_afu_instances|ofs_plat_afu|ahls_binding` and
  `ofs_plat_afu|qual_vec_op_k0|IDQualVecOp_*` present (nothing swept).

## 2. Load result — same PR engine failure

`sudo fpgaconf` → RC=5, `PR Completion ACK timeout` (dmesg 8756.889). **This
closes the payload question**: a sanctioned-flow persona with correct UUIDs and
frozen-QDB parent fails identically to every prior payload. Combined with the
isolation-01 matrix (vendor persona GBS loads RC=0 on vendor 23.1 FIM; all
payloads fail on W13), the defect is in **W13's fabric PR path** (26.1.1 PR IP /
config-stream endpoint → SDM), not host driver, not GBS packaging, not our RTL.

## 3. Live PR register probe (50 ms sampling during fpgaconf)

States observed (PF0 BAR0 +0x70000 PR_MGMT):

| Phase    | CTRL  | STS        | ERR |
|----------|-------|------------|-----|
| idle     | 0x0   | 0x1ff      | 0x0 |
| pushing  | 0x3000| 0x51101ff  | 0x8 |
| after    | 0x0   | 0x101ff    | 0x8 |

Decode vs `ofs-common/src/common/port_gasket/pr_ctrl.sv`:
- ERR bit3 = `pr_ip_error` (`PR_ERROR_IS_TRIGGERED` from the `PR_IP` core —
  the Agilex `altera_s10_pr` IP whose `config_stream_endpoint` talks to the SDM
  over the configuration-mailbox fabric).
- STS ctrlr field 001 = HW remap of IP status `100` = PR_ERROR_IS_TRIGGERED;
  host FSM field 5 = PR_CTL_PR_IN_PROGRESS.
- Engine consumes the whole stream (no credit timeout) then errors mid-stream:
  stream-level rejection by the PR IP / SDM service.
- PR_RST handshake unwedges the FSM cleanly (CTRL 0x11 → RSTACK; STS returns
  0x1ff) — register interface itself healthy.
- SDM mailbox otherwise ALIVE on W13: `bw_agilex_flash_programmer -s`
  config_status query returns clean data (conf_done=1, init_done=1, no errors).

## 4. W13 base image already contains the AHLS persona

- `afu_with_pim/afu.tcl` present in W13 syn_top → `afu_main.tcl` took the
  "Loading PIM-based AFU" branch → green region = our `ofs_plat_afu` persona.
- Fit report: 111 `IDQualVecOp` + 802 `ahls_binding` hierarchy matches.
- Therefore runtime PR is NOT required for the goal-prompt test matrix if the
  baked persona is reachable via MMIO.

## 5. MMIO reachability findings (partially resolved)

- Port-header AFU_ID is a **hardcoded RTL constant** `3ab49893-138d-42eb-9642-b06c6b355b87`
  (`pg_csr.sv:791-794`) in this FIM tree — never reflects the persona, on
  vendor or W13. OPAE UUID enumeration via port afu_id is architecturally
  impossible here.
- DFH chain (W13): FME hdr@0x0 … PR_MGMT@0x70000, PORT hdr@0x71000 (GUID =
  the constant above), user_clkm@0x72000, STP@0x73000, UAFU marker@0x80000
  (id 0x2010, EOL). UAFU words +0x08/+0x10 read **zeros both on W13 and on
  vendor-with-persona-loaded** — zeros at this marker are NOT proof of an empty
  slot; the persona's own DFH (from `ahls_mmio_aperture`, UUID words at bytes
  0x08–0x17) must appear at the persona window base, location TBD.
- Pristine flash boot (BMC cycle + reboot, PR idle, PORT_CONTROL=0x4): same
  facade at 0x80000 — resolved register set is DFH + a small repeating pattern;
  no UUID visible at that offset.
- `/dev/uio0` maps only the 4 KB user-clock feature (0x1014), not the AFU
  window.

## 6. Host incident (unresolved)

A comprehensive BAR0 locator script (full-BAR UUID scan + distinct-block map +
CSR write probes at candidate AFU bases) was launched in tmux `locator`; the
host became unreachable (SSH + ping timeout) ~1 min into the run. Write probes
at unqualified BAR offsets are a possible cause (non-AFU decode window hit).
Recovery watcher running; state after reboot to be captured before any further
probing. Locator script retained (`/tmp/fim13-gates/locator.py`, local copy
`/tmp/fim13-locator.py`) — future runs must restrict to read-only scanning
first.

## Artifacts (remote /tmp/fim13-gates/, volatile)

- `persona_run2.sh` (local `/tmp/fim13-persona-run2.sh`), `persona_build2.log`
- `persona_test.sh` (local `/tmp/fim13-persona-test.sh`), `persona_test1.log`
- `pr_live.sh` (local `/tmp/fim13-pr-live.sh`), `pr_live_probe.txt`
- `unwedge.py` (local `/tmp/fim13-unwedge.py`), `pristine_probe.sh`,
  `pristine_cycle.sh` + log, `locator.py` + `locator.log` (if preserved)
- GBS sha256: see `work_ahls_persona_01/ofs_pr_afu.gbs` — record on next
  evidence sync (build artifact >2 MB, stays local/remote, SHA-referenced).

## Next steps

1. After host recovery: capture post-reboot state (was it a crash/reboot?),
   re-run read-only scans only; determine the persona window base from PIM RTL
   decode (MMIO_ADDR_WIDTH / csr window routing in the green region), not by
   write-probing.
2. If persona reachable: run `/tmp/ahls_mmio_test` (adapted to raw-window mode)
   → full goal-prompt matrix on the flash-booted image.
3. If not reachable: diagnose PIM MMIO routing in W13 fit (QDB hierarchy),
   consider persona-in-base fix (the baked-in build may need its user clock /
  PR-freeze released by driver-managed flow, or an `INCLUDE_PR`-mode rebuild).

# Work04 two-channel DDR smoke — prepared, pending review

**No HDL compilation, elaboration, or simulation executed. `ready_for_build=false`.**

Local package: `/home/joe/Projects/Thesis/AHLS/new_bsp/new/qualification/ddr-smoke-02`.
Remote staged package: `/home/uwb_student00/ahls/new_BSP/qualification/ddr-smoke-02`.
All remote operations used owned panes of `ia840f_mailbox_monitored_01` on `uwb_student00@100.101.227.97`; existing monitor pane was untouched. Normal-account scratch, not an OS sandbox. No maintained/generated DUT/model edits or commits.

## Deliverables and actual checks

- `tb_mem_ss_smoke.sv`: concrete 128-port `mem_ss` instance, two actual 16-port memory models, explicit wiring, two concurrent finite channel drivers. No `ed_sim`, empty-model replacement, TG hierarchy, force/release, or calibration overrides.
- `run_smoke.py`: executable, inert by default; explicit `--execute`, accepted source-bound review record, correct named tmux session, and fresh output required. The pending record is deliberately rejected. Creates isolated INI with `[vsim] VoptFlow=1`, uses specified Questa tools and SALT/LM/MGLS license variables, copies/checks all five HEX files, preserves ordered compile commands/library names, checks source hashes before/after, records exact invocations/logs/tool hashes/results, kills its process group on timeout, and returns nonzero on error/timeout/missing scoreboard.
- `manifest.json`: 142 ordered IP commands (124 Work04 DUT + 9 discrete model + 9 RDIMM model), 27 design libraries, 20 installed precompiled device-library mappings, five exact simulation initialization HEX paths/hashes, and the setup script's unconditional `simsf_dpi.cpp` source. **Empty IP-specific DPI list does not mean the setup script has no DPI compilation.**
- `make_harness.py`, `ports.json`: reproducible explicit wiring from captured real top declarations.
- `inert_check.py`, `inert-check.json`: passed structural wiring/width/direction checks (128 DUT and 32 model pin connections), command closure checks, positive/negative scoreboard-parser fixtures, real Python child nonzero/timeout handling, and early review rejection without output creation. These are not HDL syntax/elaboration/functional tests.
- `review-pending.json`: all acceptance fields false, bound to current harness/runner/manifest hashes.
- `stage-*.txt`, `stage-inert.txt`: remote byte/hash readback and remote inert runner exit 0. Remote contains the four deliverables plus their `.z64` transfer files and Python import cache; no compile/run output directory exists.
- `input-verification.txt`, `final-verification*.txt`: all 147 DUT/model/HEX inputs matched prior hashes, then all 148 including `simsf_dpi.cpp` matched after staging. Installed device-library paths exist. This establishes unchanged finite inputs, not successful library loading.
- `evidence/`, `clock-verification.txt`, source/probe files: source-grounding and reproducible read-only inspection. `inventory.json` lists exact local artifacts and hashes.

## Traffic and failure contract

Each channel writes full-strobe single 512-bit beats to byte addresses 0 and 64, waits for each B response, then reads both back. Patterns differ by channel, address, and 32-bit lane. AWLEN/ARLEN=0, AWSIZE/ARSIZE=6, INCR; IDs are channel-distinct. AW/W/AR independently remain asserted until their own handshakes; output driving is on falling user-clock edges and acceptance sampling on rising edges. B/R readiness is enabled only after the corresponding request(s) are accepted. Check BID/RID, OKAY, RLAST, all 512 data bits, and X/Z in accepted payloads (including BUSER). Channel completion is set only after both reads; global completion requires both channels.

Exact required final line:

`DDR_SMOKE_PASS channels=2 writes=4 reads=4 bits_checked=2048`

Runner also requires exactly one channel-done marker for each channel. Synthetic parser test strings are explicitly labeled and never treated as simulation output.

Bounds: 4096 user-clock cycles per entire write/read transaction, 500 us startup bound, 1 ms hard simulation watchdog, 120 s for the combined elaboration/run invocation. Compile commands have a proposed 600 s total / 120 s per-command cap; this separate compilation budget is not permission for long simulated traffic. No automatic bound extension, full-calibration switch, repeated resets, or error injection. These are fail-closed proposed experiment caps, not measured feasibility/performance claims.

## Actual source grounding and remaining blocker

Both EMIF readmes specify 33.333 MHz references and `SIM_CAL_MODE_SKIP`; `clock-verification.txt` records exact source hashes. Harness half-period `15.00015 ns` rounds to 15 ns at 1 ps precision (nominal 33.333 MHz). It uses each channel's actual exported user clock/reset. The actual `altera_emif_fm_280` wrappers override `DIAG_FAST_SIM=1` and `DIAG_USE_ABSTRACT_PHY=0`; lower-level parameter defaults are not the effective settings. See `final-verification2.txt`. OCT simulation inputs are tied low; physical DDR pins connect directly, including model-driven ALERT_n.

**Reset protocol source acceptance remains unresolved.** The generated `mem_reset_ctrl` instance is clocked from `emif_0_pll_ref_clk_out_clk` and reset by `emif_0_pll_locked_pll_locked`, and its visible wrapper forwards both EMIF local-reset handshakes (`NUM_FM_EMIF=2`). However, both generated simulation implementation and installed implementation are encrypted. Visible wrapper/template/declare sources do not establish minimum cold-pulse duration or whether cold assertion must wait for readiness/acknowledgment. Therefore the concrete initial cold reset held for 100 reference cycles with `app_ss_rst_req=0` is **a review candidate, not falsely claimed source-proven**. Startup requires both exported user resets, both calibration successes, and cold acknowledgment high. Calibration failure fails immediately; loss/XZ of status after startup also fails.

Before HDL execution, reviewer must resolve/accept that initial reset sequence against vendor protocol evidence or a specifically reviewed bounded experiment, then complete model/harness review and bind the accepted record to the exact files. The runner refuses the supplied pending record. This is a technical review barrier, not a request for incremental user permission.

HDL syntax, device-library/encrypted-IP loadability, actual startup time, DPI build/link behavior, wall-clock cap suitability, and DDR readback remain untested until that reviewed full-DUT experiment. No success is implied by preparation.

## Exact model paths

Remote repair root `/home/uwb_student00/ahls/new_BSP/qualification/ddr-model-repair-01`:

- `ed_sim_mem/sim/ed_sim_mem.v`
- `ed_sim_mem/altera_emif_mem_model_191/sim/ed_sim_mem_altera_emif_mem_model_191_tododxq.v`
- `ed_sim_mem_group1/sim/ed_sim_mem_group1.v`
- `ed_sim_mem_group1/altera_emif_mem_model_191/sim/ed_sim_mem_group1_altera_emif_mem_model_191_kpsc7si.v`

The nine files per model include the seven real DDR4 model dependencies. Original Work04 portless models are excluded.

## Reviewed execution shape (not executed)

From an owned pane in the required remote session, after review closes the reset item and provides a hash-matched accepted record:

```sh
python3 /home/uwb_student00/ahls/new_BSP/qualification/ddr-smoke-02/run_smoke.py \
  --execute --review-record /absolute/path/to/accepted-review.json \
  --output /home/uwb_student00/ahls/new_BSP/qualification/ddr-smoke-02/run-01
```

Do not reuse an existing output directory. Acceptance remains `ready_for_build=false` even if the future smoke passes.

## Inspection issues retained

First capture included excessive HEX payload and lost its leading scrollback; superseded by compact hashed capture. One guessed inner-wrapper location was absent; corrected using the actual ordered source closure. Large tmux command payloads were rejected before execution; finite input verification used compression and staging used bounded chunks. These did not trigger HDL execution or input changes.

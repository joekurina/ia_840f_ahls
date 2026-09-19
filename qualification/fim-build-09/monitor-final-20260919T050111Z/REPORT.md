# Work09 STA captured — timing FAIL; assembly still running

Observation: 2026-09-19 05:01:16–05:05:16 UTC, six bounded samples, exclusively in owned `ia840f_mailbox_monitored_01:work09_final_20260919T050111Z`. No further remote monitoring after the bound.

## Native milestones

- Fitter successful: 0 errors, 202 warnings (21:58:49 host time).
- Full STA report completed: 0 errors, 240 warnings, but Setup Summary and Hold Summary both FAIL. Critical Warning (332148): Timing requirements not met; Critical Warning: DDR Timing requirements not met. A subsequent native Timing Analyzer invocation also reported 0 errors, 181 warnings; this does not supersede the full STA timing failures.
- Final sampled status remains running; original runner PID/start ticks 124991/7881963, native 125051/7882108 and flow 125068/7882414 remain live. Assembly PID 134880/start ticks 8225033, state R, CPU ticks 38256: `quartus_asm --ipc_flow=17 --ipc_mode --read_settings_files=on --write_settings_files=off ofs_top -c ofs_top`. Exact executable hashes, cwd and ancestry are in verified/summary.json and samples.
- No assembly completion or final native exit is established. Output image inventory is empty at capture, so there is no final image hash to claim.
- No Error/Fatal, Critical Warning 125091 or IA840F_*REJECTED detected in captured reports/logs. Timing-critical warnings above remain real acceptance failures.

## Actual DDR timing versus supplied Work08 baseline

All values ns. Both setup domains remain 333.33 MHz / 3.000 ns, Slow vid2 100C Model.

| Domain | Work08 slack | Work09 slack | Slack delta | Work08 TNS | Work09 TNS | Work09 failing endpoints |
|---|---:|---:|---:|---:|---:|---:|
| EMIF0 core setup | -0.236 | -0.435 | -0.199 | -61.410 | -152.255 | 580 |
| EMIF1 core setup | -0.366 | -0.313 | +0.053 | -117.103 | -86.055 | 545 |
| EMIF1 PHY hold | -0.004 | -0.004 | 0.000 | not supplied | -0.004 | 1 |

EMIF0 regressed; EMIF1 setup improved but still fails. EMIF1 hold is unchanged at Fast vid2 100C Model. EMIF0 core hold is 0.000; EMIF1 core hold is +0.001, both with zero TNS.

Worst setup paths remain MSA bank selection, not a changed DDR clock:
- EMIF0: `msa_0|msa_0|msa_adapter|rdreq_bank_spreading|rdreq_select_bank_fifo_read[1]~SynDup` to `wrreq_bank_spreading|wrreq_select_bank_fifo_read[1]~SynDup_72` (also _71), -0.435.
- EMIF1: `msa_1|msa_1|msa_adapter|rdreq_bank_spreading|rdreq_select_bank_fifo_read[0]~SynDup_5RTM` to `rdreq_select_bank_fifo_read[0]~SynDup_12DUPLICATE` (also _12), -0.313.
- Hold: `emif_1|emif_1|arch|arch_inst|hmc.amm.amm.data_if_inst|amm_writedata_0_r[0][243]` to `io_tiles_wrap_inst|io_tiles_inst|tile_gen[2].lane_gen[1].lane_inst|lane_inst~phy_reg1`, same endpoint family as Work08.

Full exact hierarchical names and source line references are retained in worst-path-rows.json. STA summary rows are at lines 2749–2750 and 2780; clocks at 2630/2652; setup path rows at 156266–156267 and 157740–157741; hold path at 142705.

## Constraint acceptance remains false

Full STA unconstrained summary (207920–207929): 0 illegal clocks; 1 unconstrained clock; 2 unconstrained input ports / 78 pairs; 2 unconstrained output ports / 10 pairs, identically for setup and hold. Unconstrained clock is PCIe `u_pciess_clock_divider|clkdiv_inst~div_reg` (207938). Ignored PCIe false/multicycle constraints and other constraint warnings persist; selected warning lines are in constraint-warnings.txt. S1/TRS and BMC IRQ/JTAG policy are not resolved by this monitoring. Readiness, timing, constraint and functional acceptance remain false.

## Evidence integrity and scope

Single compressed final transfer verified: 3,839,854 bytes, SHA256 `acf9d77e11c998006fa7d28388cde8e1c7ed86b6afa616926b5662325f517acd`; all 32 manifest files verified for SHA256 and size. Complete STA report is 46,853,462 bytes, SHA256 `eca0bb5aff2272f5e609b98a21f653d4aee3a60a2c04b367c1fecab93e315cd4` in verified/latest/work_ia840f_fim_09/syn/board/ia840f/syn_top/output_files/ofs_top.sta.rpt.

Remote exclusive evidence directory: `/home/uwb_student00/ahls/new_BSP/qualification/fim-build-09/monitor-final-20260919T050116Z`. Local directory contains monitor.py, driver.py, exact ssh-invocation.json, pane.log, transfer.json, evidence.tar.gz, verification.json, verified/ snapshot, timing extraction and this report.

No query04 access/retry, new Quartus query, build restart/stop, source/SDC/gate edit, DDR simulation, hardware action or commit. No existing pane touched. No execution/transfer issues encountered.

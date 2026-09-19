# Work10 completed natively; timing and constraint acceptance FAIL

## Final result

- Native compile ended **2026-09-19 06:35:58.651822 UTC**, return code **0**, state `finished`, `accepted_execution=true`, `gate_rejection=false`. Final readback at 06:36:34 UTC has no remaining captured runner/descendant processes. Native execution acceptance is not timing or functional acceptance.
- Fitter: **successful, 0 errors / 202 warnings**, reported 23:24:32 PDT (06:24:32 UTC). Full STA: **successful tool execution, 0 errors / 240 warnings**, but **Setup Summary FAIL and Hold Summary FAIL**, with timing-requirements-not-met critical warnings. Subsequent native STA reports 0 errors / 181 warnings and does not invalidate the full STA failures.
- Assembler: **successful, 0 errors / 1 warning**, reported 23:35:19 PDT. Warning 20536 says legacy `GENERATE_RBF_FILE` is ignored; nevertheless the final filesystem inventory contains the specific green-region RBF below. This is not evidence of a full-board RBF.
- Ready-for-build, timing acceptance, constraint acceptance, and functional acceptance remain **false**. S1/TRS, PCIe-divider and BMC IRQ/JTAG review blockers are not resolved by native exit zero.

## Actual Work09 → Work10 timing

Parsed independently from both complete, hash-verified native STA reports. These are the all-corner worst-case clock summary values; all 17 setup and 17 hold clock rows and their limiting corners are preserved in `timing-analysis.json`, not a single-corner estimate. The five reported models are Slow vid2 100C, Slow vid2b 100C, Fast vid2a 0C, Fast vid2a 100C, and Fast vid2 100C. No additional vendor query was run.

| Metric (ns unless endpoints) | Work09 | Work10 | Work10 minus Work09 |
|---|---:|---:|---:|
| EMIF0 core setup WNS | -0.435 | **-0.508** | -0.073 |
| EMIF0 setup endpoint TNS | -152.255 | **-185.081** | -32.826 |
| EMIF0 failing endpoints | 580 | **711** | +131 |
| EMIF1 core setup WNS | -0.313 | **-0.170** | +0.143 |
| EMIF1 setup endpoint TNS | -86.055 | **-29.340** | +56.715 |
| EMIF1 failing endpoints | 545 | **403** | -142 |
| Worst hold WNS / TNS | -0.004 / -0.004 | **-0.004 / -0.004** | 0 / 0 |
| Hold failing endpoints | 1 | **1** | 0 |

EMIF0 regressed; EMIF1 improved but still fails. Both setup domains remain **333.33 MHz / 3.000 ns**, limiting corner Slow vid2 100C. Hold failure remains EMIF1 PHY at Fast vid2 100C. EMIF0 core hold remains 0.000; EMIF1 core hold changes from +0.001 to 0.000, with zero TNS in both.

Full Work10 STA source references: clocks lines 2630/2652; setup lines 2749/2750; worst hold line 2780.

Worst setup paths remain inside MSA bank spreading, but the actual limiting endpoint pairs differ from Work09:
- EMIF0, line 156129: `msa_0|msa_0|msa_adapter|wrreq_bank_spreading|bank_fifos_dataout_out_valid[6]` → `wrreq_select_bank_fifo_read[1]~SynDup_8DUPLICATE`, -0.508 ns.
- EMIF1, line 157591: `msa_1|msa_1|msa_adapter|rdreq_bank_spreading|bank_fifos_dataout_out_valid[5]~RTM` → `bank_fifos_dataout_out_valid[2]~RTM`, -0.170 ns.
- Hold, line 142587: EMIF1 `amm_writedata_0_r[0][243]` → `tile_gen[2].lane_gen[1].lane_inst|lane_inst~phy_reg1`, -0.004 ns, same pair as Work09.
- Exact full hierarchies, all matching worst-path rows and both builds' comparisons are retained in `timing-analysis.json`.

## Constraints

Work10 full STA lines 207659–207668 confirm the same counts as Work09 for both setup and hold: **0 illegal clocks, 1 unconstrained clock, 2 input ports / 78 pairs, 2 output ports / 10 pairs**.
- Clock: PCIe `u_pciess_clock_divider|clkdiv_inst~div_reg` (207677).
- Inputs: `altera_reserved_tdi`, `altera_reserved_tms`.
- Outputs: `altera_reserved_tdo`, `bwbmc_bmc_irq`.
- Ignored PCIe false-path/multicycle constraints and ignored max-skew assignments remain. `constraint-warnings.txt` retains 208 matching warning occurrences with original STA line numbers; occurrences are not deduplicated unique constraints.

## Actual programming images

Remote read-only filesystem hashing after native completion; the inventory itself was transferred with size/SHA256 verification. Image bytes were not transferred or programmed.

| File under WORK `syn/board/ia840f/syn_top/output_files` | Bytes | SHA256 |
|---|---:|---|
| `ofs_top.sof` | 9327743 | `4cb9e1e5c43c810b20759b229fa27685cc747a956227c55a1115852a53efff91` |
| `ofs_top.green_region.rbf` | 9121792 | `b580972ff8e3ff6dfeae12f1eb9ee14d631726489d57a6d87adbee02b6c4ed83` |

Separate assembler intermediates, not SOF/RBF substitutes:
- `ofs_top.static.msf`: 3653083 bytes, `175e192b196bacca19b4e36b7cb35dadf8e0a6a1fbca583c34d6ad51c3d5e3eb`.
- `ofs_top.green_region.pmsf`: 8431159 bytes, `cb5aaef7dc7b682e7c39d3fb7fdafe0ed29dd5c48a59a46a6611007f9c10775c`.

## Evidence integrity, observations and scope

- Full-report batch: five compact samples, 06:23:41–06:29:23 UTC, six-minute observer bound including capture overhead. Initially the original fitter 142018/start 8435815 remained live; it had advanced 38088 CPU ticks relative to monitor-next-milestone-04. Fitter then completed, native CDB callbacks progressed, and full STA appeared. Native stdout lag was not treated as a lack of progress.
- Completion batch: six compact samples, 06:30:34–06:36:34 UTC, stopped on finished native status. This batch collected assembly/flow/status and the image inventory, without retransferring the already captured full STA. Exact process executable/argv/cwd/hash/start ticks and ancestry are in each batch's `readback/samples.jsonl` and `transfer-verification.json`.
- Full transfer: **10181375 bytes**, SHA256 `e9bfec666057689855c40486821b8e194a3e0feb9af2410cb233212cdb3b7465`, **23 files** verified against remote size/SHA256 and local readback.
- Completion transfer: **275291 bytes**, SHA256 `6548dca2bcff70572523f5fc38dac0055ae19119978809fd1e01f6d8334f287d`, **8 files** verified. Unique buffers `work10-final-01-144177` and `work10-completion-01-144992`; export completion was observed before retrieval. No stale-buffer reuse.
- Work10 complete STA: **46834561 bytes**, SHA256 `8e6002a2c4c7974f0382a9b458c8be9ca87034a120d4972da3c14081367aded4`.
- Work10 fitter report: **17961073 bytes**, SHA256 `118b90656eb59450598906fb3f191b5ba10ab7f9f0464a6f006dfafe284ac173`.
- Work09 complete STA locally reverified against its existing manifest: **46853462 bytes**, SHA256 `eca0bb5aff2272f5e609b98a21f653d4aee3a60a2c04b367c1fecab93e315cd4`. No retransmission or baseline assumption was needed.
- No captured Error/Fatal, Critical Warning 125091 or explicit IA840F reject/not-ready diagnostic occurrences. This does not suppress the actual timing and constraint warnings.
- Host Agilex7Workstation / UID 1000 asserted. All remote operations used owned named tmux windows in `ia840f_mailbox_monitored_01`: `work10-final-01` (%381), `work10-completion-01` (%382). Existing panes %375–%380 were not targeted or modified.
- Additions are confined to this local evidence directory and corresponding remote evidence directory, plus owned tmux windows/buffers. Included artifacts: observer/launcher/retriever scripts, exact launch and retrieval commands, completion-wait logs, pane exports, transfer verification, snapshots, baseline readback, analysis script/JSON and this report.
- No SOURCE/WORK/gate edits, restart/stop, authorization reuse, extra Quartus queries, Query04, DDR simulation, hardware action, permission/install change or commit. No execution or transfer failure encountered.

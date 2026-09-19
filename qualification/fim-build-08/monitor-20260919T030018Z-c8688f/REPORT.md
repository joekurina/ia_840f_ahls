# Work08 bounded fitter milestone — still running

Last sample: 2026-09-19 03:03:22 UTC / September 18 20:03:22 PDT.

- Native compile remains running: fitter PID 110405, flow 108175, native 108158. No completed fitter, place/route, STA or assembler summary in this snapshot; no final native return code is available.
- New milestone: native log line 8802 records fitter preparation ending (00:09:41); lines 8806–8807 record physical synthesis beginning and ending (00:00:40). Latest output enumerates clock-sector fanouts following HSSI/clock-region messages. This is not evidence of route or timing completion.
- Synthesis remains successful, 0 errors / 34 warnings (line 8051). BTI Info 21650 remains at line 8177 and fit.plan line 8463: qsfp_ref_clk at CC19 used to preserve unused channels.
- No actual Error diagnostics, IA840F_GATE_REJECTED, or 125091 observed in copied native log/reports. The earlier flow.rpt Successful status is timestamped 19:45:28 and is not full-build success.

## Clock/constraint evidence and issues

- Native log 8318–8321 / fit.plan 8604–8607: warnings 332174/332049, sys_pll|iopll_0_clk_50m unmatched; ignored clock uncertainty in work_ia840f_fim_08/ofs-common/src/fpga_family/agilex/sys_pll/sys_pll.sdc:33–34.
- Native log 8338 onward: ignored false paths to absent PCIe collections, starting work_ia840f_fim_08/ipss/pcie/qip/pcie_ss/intel_pcie_ptile_ast_1100/synth/intel_ptile_pcie.sdc:691. All captured warning lines retained in diagnostics.json, grouped by report, not treated as final stage warning totals.
- Native log 8171–8172: warning 21752, bwbmc_fpga_max_sclk on non-dedicated clock pin; not automatically promoted.
- Native log 8798–8799: warnings 15705/15706, afu_top|pg_afu.port_gasket|pr_slot|afu_main location/region target absent.
- No matches for ALTERA_INSERTED_INTOSC_FOR_TRS or divided_osc_clk in these reports/logs. No STA report is available. fit.plan enumerates pins, PLL usage and control signals, not a complete STA clock/transfer/exception inventory. Existing sdc_constraints.rpt only lists debug QIP source statements in post-elaboration/post-synthesis sections, insufficient for effective exceptions. S1 remains inconclusive; removed braced clock-name group is NOT proven a no-op. No syntax dismissal, source hunt, additional Quartus query, or input change.

## Evidence and boundaries

13 samples and 11 original files preserved; all 11 original file hashes independently verified against receipt.json in verification.json. Exact SSH/tmux commands in monitor-metadata.json; reused monitor-code.py. diagnostics.json contains line-numbered warnings and stage findings. Monitor owned pane %338, session ia840f_mailbox_monitored_01; build pane %324 and previous panes untouched.

Local: /home/joe/Projects/Thesis/AHLS/new_bsp/new/qualification/fim-build-08/monitor-20260919T030018Z-c8688f
Remote snapshot: /home/uwb_student00/ahls/new_BSP/qualification/fim-build-08/monitor-20260919T030018Z-c8688f

Readiness and functional acceptance remain false. DDR simulation SKIPPED BY USER. Build continues independently; no restart, stop, constraint edits, hardware programming/reset, install or commit.

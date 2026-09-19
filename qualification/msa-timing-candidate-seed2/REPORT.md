# Prepared only: single fitter seed experiment

## Candidate
Change only `syn/board/ia840f/syn_top/ofs_top.qsf:44` from `set_global_assignment -name SEED 1` to `set_global_assignment -name SEED 2` relative to the actual remote SOURCE. Candidate is `overlay/syn/board/ia840f/syn_top/ofs_top.qsf`; exact delta is `seed-only.patch`. No build launched, no live SOURCE/WORK/gate modification, no Query04 access.

Important: local SOURCE currently says SUPERIOR PERFORMANCE, whereas actual remote SOURCE says SUPERIOR PERFORMANCE WITH MAXIMUM PLACEMENT EFFORT. The candidate deliberately uses the captured remote baseline, NOT the stale local QSF. Baseline SHA256 ea5b7bfd3f1d5f35092afe7db1a0497033ed8d08d85b5fa82d4c8d7a16a243c3. Preserve the remote effort mode, speed settings and maximum router effort. Native Work09 migration to HIGH PERFORMANCE EFFORT plus GLOBAL_PLACEMENT_EFFORT MAXIMUM EFFORT is not an additional experiment.

## Path evidence
Full verified report: ../fim-build-09/monitor-final-20260919T050111Z/verified/latest/work_ia840f_fim_09/syn/board/ia840f/syn_top/output_files/ofs_top.sta.rpt.
- EMIF0 lines 156279–156315: setup -0.435 ns, 3.000 ns relationship, 11 logic levels, 3.570 ns data delay; routing IC 2.074 ns (58%), cells 1.124 ns (31%), uTco 0.372 ns (10%), skew -0.125 ns.
- EMIF0 lines 156351–156384: bank-select register -> bank-spreading mux -> cmd_fifo_takes_wrcmd -> effective_banks_read -> bank-spreading add/mux chain -> write bank-select register. Final logic branch has fanout 58. This is a combinational scheduler/selection feedback path, not a simple unrelated payload pipeline.
- EMIF1 lines 157753–157789: setup -0.313 ns, 9 logic levels, 3.233 ns data delay; IC 2.022 ns (63%), cells 0.811 ns (25%), uTco 0.400 ns (12%), skew -0.072 ns.
- Summary lines 2749–2750: EMIF0 TNS -152.255 ns / 580 failing endpoints; EMIF1 -86.055 ns / 545. Work09 REPORT.md lines 17–28 records opposite setup movement versus Work08 and unchanged -0.004 ns EMIF1 PHY hold.
Routing is the largest component but logic depth is material. Seed is a controlled placement-sensitivity probe, NOT a demonstrated fix or guaranteed closure.

## Why not a pipeline change
Installed /opt/altera/26.1.1/ip/altera/subsystems/mem_ss_pkg/ip_msa/declare.tcl, preserved in catalog/declare.tcl:
- Lines 54–128 enumerate MSA-specific parameters. No independent bank-selection pipeline/register-depth option was found.
- Lines 64–65: READY_LATENCY default 3 and VALID_LATENCY default 0 are hidden, DERIVED parameters, not evidence of a supported user-adjustable timing fix. These are declaration defaults, not a claim about generated instance values.
- Lines 85–90 expose NUM_COPIES, NUM_BANK_FIFOS and scheduler read/write quotas. NUM_BANK_FIFOS allows 0/2/4/8, but this changes scheduling/reordering rather than safely adding a pipeline.
- catalog/parameters.properties:18 says copies reduce available capacity; :22–25 says bank FIFOs reorder traffic and 0 disables spreading. Do not change either for this contract-preserving experiment.
- catalog/filesets.tcl:48 identifies drc_bank_spreading.sv as SYSTEM_VERILOG_ENCRYPT. Installed rtl/drc_bank_spreading.sv, rtl/ddrx_ropt_ctrl.sv, rtl/mem_ss_msa_top.sv and actual Work09 generated synth mem_ss_msa_top.sv begin with pragma protect (line 1). Internal RTL equations could not be inspected; no decryption or generated RTL edits attempted. Protected source prevents a source-proven ABI/latency/backpressure-preserving pipeline recommendation.

## Supported seed evidence and tradeoffs
remote-static.json contains installed libdb_acf.so help: Fitter Initial Placement Seed accepts any non-negative integer; changing it may or may not improve fitting, and small design/settings changes alter which seed is best. Existing native Work09 QSF has SEED 1 at line 43; actual remote SOURCE has SEED 1 at line 44. Seed 2 is simply the next untested non-negative value, not specially favorable. Installed documentation suggests seeds for small misses; these misses across many endpoints are substantial enough that success remains uncertain.

The one-setting delta changes placement search, not RTL, clocks, memory configuration or protocol. Preserve core4707 PLL outputs, 333 MHz DDR, two 16 GiB x64 BOT/BOT mappings, device AGFB027R25A2E2V, pins, PCIe PF/BAR and BMC. No SDC changes or timing cuts. This is the smallest supported remaining experiment; it may improve or worsen either domain and does not specifically address the PHY hold violation.

## Before any eventual run
Use a fresh separately reviewed WORK and its exact source/gate bindings; do not reuse/modify Work09 or consumed authorization. Apply only this delta to the matching captured baseline. Keep all acceptance false until native results. Compare both DDR setup WNS/TNS/endpoint counts, detailed routing/cell delay, all hold checks (including the -0.004 ns PHY path), clocks and constraint diagnostics. An image or successful fitter exit is not timing acceptance. No authorization/launcher was generated here.

## Artifacts and limits
remote-static.json and remote-catalog.json preserve remote paths/text/hash evidence; catalog/ provides line-readable declarations. verification.json records baseline/candidate hashes. Empty remote-parameters.json records an initial bounded util-only search with no hits; subsequent exact ip_msa capture resolved it. All remote operations used owned window ia840f_mailbox_monitored_01:msa_candidate_read on verified Agilex7Workstation UID1000. Initial tmux set-buffer transfer exceeded argv capacity; recovered with load-buffer stdin and new buffer names. No Quartus command executed. SSH remained read-only with respect to SOURCE/WORK; only owned tmux window/buffers were created. Local candidate preparation is not native project-load acceptance.

# Query03 native execution — FAILED, evidence preserved

The parent accepted both reviews. All reviewed local hashes were recomputed and matched; remote copies and all 8,027 prelaunch file bindings and 11 links verified before fresh schema-exact authorization. Candidate SHA256 remains `911bcf9cead7d2e7cd3e7c6c486a19633a07aa97070825a1fef1570dfd651428`, approved=false, ready_for_build=false. Earlier REPORT.md is preserved as prelaunch history.

## Native result

- Ran the exact bound `python3 -B /home/uwb_student00/ahls/new_BSP/qualification/fim-build-08/pcie-postfit-query-03/run-query.py` from query03, in session `ia840f_mailbox_monitored_01`, window `query03_execute`, pane `%365`, on Agilex7Workstation UID1000.
- Explicit Quartus 26.1.1 environment; native log confirms Build 130. Native command and cwd, environment and UTC timestamps are in execution-invocation.json.
- Start 2026-09-19T04:36:01.571789+00:00; runner end 04:36:54.241689+00:00. Native reports 47 seconds. Native and runner rc3, not a timeout; unchanged 80-second bound. No retry. Exclusive query.claim retained.
- Exact blocker (query.log:478): `Error (23035): Tcl error: can't set "pins": variable is array`, while executing `set pins [get_cell_info -pins $c]` (query.tcl:45, loop starts at line35). Followed by Error23031. Native reports 2 errors, 181 warnings. No 125091 diagnostic occurred; its absence does not override this failure.

## Findings and limits

- Final fitted database loaded successfully.
- One emitted divider: `pcie_wrapper|pcie_ss.top|host_pcie.pcie_ss|pcie_ss|EP_PFTILE_WRAPPER.gen_pciess.u_pciess_p0|u_pciess|gen_sub.u_hipif|u_pciess_clock_divider|clkdiv_inst`, type `tennm_clk_divider`.
- Warning332060 identifies corresponding `clkdiv_inst~div_reg` as a clock without an associated clock assignment. Info13166 names the PCIe `pld_avmm2_clk_rowclk.reg` load. This is not proof of input PLL identity, period, output ratio or alias equivalence.
- Pin/fanin and clock-target queries did not execute to output. No actual input period, source clock, output clock count or proposed output period was obtained. Fitted divider mode remains unavailable through the reviewed API; vendor divide-by-two evidence remains separate.
- No alias totals, TRS totals, oscillator-type inventory rows or inventory-end marker were emitted. The scan was interrupted; TRS absence is NOT established.
- Native read_sdc also read existing absolute Work08 database-embedded SDC references. Thus scratch was the opened project, but not every SDC read was scratch-local. Full Work08 hash/link inventory before and after matches (7,502 entries); Work09 was not touched.

## Smallest correction, not applied

In a fresh reviewed successor, rename the query's scalar `pins` and its loop reference to a unique query-local name, or isolate diagnostic variables in a procedure. Do not unset the vendor/global array, alter SDC, weaken gates, reset this consumed claim or extend timeout. No new general framework is needed.

## Preservation

Complete query.log, native-result.json, authorization, claim, reviews/disposition, invocation, runner console and preservation/preflight records were read back from remote and verified by SHA256 and byte size (11 files). See evidence-receipt.json. No surviving query-owned Quartus processes were observed. Candidate and Work08 unchanged. No SDC edits, build, DDR simulation, hardware action, install, permissions change or commit performed.

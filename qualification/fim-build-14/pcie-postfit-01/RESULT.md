# Work14 fitted-copy diagnostic01 — failed native query, partial evidence

**Native rc3 / diagnostic INCOMPLETE. Timing NOT ACCEPTED. Hardware NOT RUN.** Independent result review pending. This is not a lost/unknown process: the persistent runner returned3 and the owned pane returned to its shell. Do not relaunch or overwrite this consumed attempt.

## Actual execution and preservation

The independently SPEC/QUALITY-reviewed, parent-accepted package ran once in owned tmux `@35/%35`. Exact invocation and process identity are in [native-process.json](result-readback01/native-process.json) and [query.claim](result-readback01/query.claim).

- Start `2026-09-22T06:48:07.148514+00:00`.
- End `2026-09-22T06:48:46.491196+00:00`.
- Native rc3; runner outward rc3.
- [Preservation-after receipt](result-readback01/preservation-after.json): original Work14, maintained SOURCE and original PIM all unchanged.
- [Full log](result-readback01/query.log), 137,604 bytes; exact exports bound by [result-manifest01.json](result-manifest01.json).
- Exact result archive `result01.json.gz` SHA256 `ffdaae298232356de12fc050486cfe6c80495c110989b04c0c8e92c77c211459`; batch identity `ia840f_w14_postfit_result01`, five exports independently size/hash-verified after retrieval.

## Useful partial output — not a clock repair

The actual fitted divider cell is under `pcie_wrapper|pcie_ss.top|host_pcie.pcie_ss|pcie_ss|EP_PFTILE_WRAPPER.gen_pciess.u_pciess_p0|u_pciess|gen_sub.u_hipif|u_pciess_clock_divider|clkdiv_inst`, type `tennm_clk_divider`.

Its `inclk` is an input clock pin; clock fanin resolved to `sys_pll|iopll_0|tennm_pll|outclk[2]`. The fanin target-associated clock is `sys_pll|iopll_0_clk_100m`, period9.929ns, master `sys_pll|iopll_0_n_cnt_clk`, master source `sys_pll|iopll_0|tennm_pll~ncntr_reg`. Input `NET_ID {}` is not connectivity evidence; the separate fanin result is.

The output `clock_div2` is an output clock pin. Inspection then stopped before completing its target-clock association or the four FIFO groups. Do not infer missing output clocks/FIFO connectivity from this interruption.

## Exact failure and successor scope

`targets $p ...` passed a single pin object to a helper that uses `foreach_in_collection`. Quartus Error23035: `Collection does not exist with name: _quartus_sta_pin__53563`. The stack points to the helper's collection iteration at the divider output. Script Error23031 and native failure followed. This is an observed query-interface error, not evidence that the divider pin is missing or hardware failed.

Prepare a new isolated successor that accepts a Tcl list of node names in the helper: convert fanin collections to names and pass the output name with `[list $pn]`. Preserve this failed attempt and all review-bound bytes. Fresh package review precedes native execution; this result is not permission to modify clocks/exceptions or fit again. No live FPGA operation occurred.

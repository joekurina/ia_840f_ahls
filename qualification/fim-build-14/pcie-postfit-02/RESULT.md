# Work14 corrected fitted-copy diagnostic02 — native result

**Native rc0 / finite query COMPLETED. Independent result review PENDING. Timing NOT ACCEPTED; hardware NOT RUN.** This records actual query completion, not a source-constraint repair or qualification pass.

## Execution and evidence

- Owned tmux `@37/%37`; [dispatch](launch-dispatch01.json), [issuance and outer-result capture](launch-pane-result01.txt).
- Exact package accepted after SPEC PASS and QUALITY APPROVED: [acceptance](ACCEPTANCE.md), [parent hash receipt](parent-consumption01.json).
- Native start `2026-09-22T07:29:09.177473+00:00`, end `2026-09-22T07:29:57.714346+00:00`; process16291; native and outer rc0. [Raw native status](result-readback01/native-result.json), [process](result-readback01/native-process.json).
- Full log181593 bytes/718 lines, SHA256 `6d934bb5862574a6518fc5803d051757eefcb88a3caaf2f7db44850971460b89`. Tool reports0 errors/201 warnings, peak virtual memory7017MB, elapsed00:00:48. No gate rejection or125091 was found in the captured full log.
- Result archive SHA256 `9ef433fa35707fb6811ce0be2b888041476e8974ac5c5094fbe6bee075e9a273`, batch `ia840f_w14_postfit02_result01`. All five raw exports matched their byte counts/digests before saving: [manifest](result-manifest01.json), [parsed summary](result-summary01.json).
- [Postflight preservation](result-readback01/preservation-after.json) is true for original Work14, maintained SOURCE and original PIM. This is the reviewed runner's captured complete-inventory comparison, not a separate local inventory of the remote originals.

## Actual diagnostic findings

The common prefix is:

```text
pcie_wrapper|pcie_ss.top|host_pcie.pcie_ss|pcie_ss|EP_PFTILE_WRAPPER.gen_pciess.u_pciess_p0|u_pciess|gen_sub.u_hipif
```

1. Exactly one divider cell; exact pin selector counts `inclk=1`, `clock_div2=1`, `clock_div2x=0`. The fitted output pin is `u_pciess_clock_divider|clkdiv_inst|clock_div2`; the fitter's net representation and the STA register alias must not be substituted into the pin selector.
2. Divider input has one clock input and fanin `sys_pll|iopll_0|tennm_pll|outclk[2]`, associated with `sys_pll|iopll_0_clk_100m`, period9.929ns, master `sys_pll|iopll_0_n_cnt_clk`, source `sys_pll|iopll_0|tennm_pll~ncntr_reg`.
3. Divider output's exact target-association query reports `CLOCK_TARGET_COUNT 0`. This query result alone is not an exhaustive propagated-clock absence proof. Existing Warning332060 is separate unassigned-clock evidence.
4. Every selected FIFO group has8 cells; every cell has one clock input and the same clock fanin alias `u_pciess_clock_divider|clkdiv_inst~div_reg`. All32 cell queries report zero target-associated clock objects, rather than failing early as attempt01 did.

| Group | FIFO under common prefix | Selected receiver chain | Cells |
|---|---|---|---:|
|0|`u_pciess_cplto_if|cplto_fifo_avmm_inst`|`rs_dgwp|dffpipe`|8|
|1|`u_pciess_cplto_if|cplto_fifo_lite_inst`|`ws_dgrp|dffpipe`|8|
|2|`EP_CFG_IF.u_pciess_cfg_if|u_axi_lite_clk_to_user_avmm_clk_fifo`|`rs_dgwp|dffpipe`|8|
|3|`EP_CFG_IF.u_pciess_cfg_if|u_user_avmm_clk_to_axi_lite_clk_fifo`|`ws_dgrp|dffpipe`|8|

`QUERY_INVENTORY_END`, final cardinalities and `W14_POSTFIT_QUERY_COMPLETE` are present. These receivers establish the queried divider connectivity, not all possible integrated crossing paths. Input-pin `-net` remains excluded as connectivity proof.

## Remaining work

Obtain independent actual-result review, then consume this evidence with the accepted generated-SDC/source diagnosis. A future isolated clock-repair experiment must define its new scope explicitly, preserve the actual master/divide-by-two intent, and review reactivated asynchronous groups and multicycles. Asynchronous cuts override the same-pair multicycles; do not claim those multicycles provide safety coverage. No guaranteed eight-warning cure, new source clock, updated exception, fit, timing pass or hardware result is established here. Separate EMIF1 hold and the broader qualification gates remain open.

The exact single-use attempt is spent. Do not rerun or edit its bound package; future experiment changes require a fresh package and reviews.

# Work14 fitted-copy diagnostic02 — native rc0, result evidence accepted

**Single-use native inspection COMPLETE. Timing NOT ACCEPTED; hardware NOT RUN.** The exact corrected query ran once in owned tmux `@37/%37`, native and outer rc0. Start `2026-09-22T07:29:09.177473+00:00`, end `2026-09-22T07:29:57.714346+00:00`. [Actual result](RESULT.md), [full log](result-readback01/query.log), [outer receipt](launch-pane-result01.txt).

## Findings and limits

- One divider; exact pin selectors `inclk=1`, `clock_div2=1`, `clock_div2x=0`.
- CSR input clock `sys_pll|iopll_0_clk_100m`, reported period9.929ns, via fitted PLL `outclk[2]`.
- Four FIFO receiver groups,8 cells each, all queried clock fanins reach the exact divider `clkdiv_inst~div_reg` alias. Their target-association queries and the divider output's target-association query report0 clocks. This is not exhaustive propagated-clock absence proof; Warning332060 separately identifies the unassigned clock.
- Explicit final cardinalities and `W14_POSTFIT_QUERY_COMPLETE`; tool0 errors/201 warnings. Original Work14/SOURCE/PIM preservation checks alltrue. No source clock or exception was changed.

## Evidence and consumed execution gate

[Parent acceptance](ACCEPTANCE.md) consumed SPEC PASS `deleg_1d433eee` and QUALITY APPROVED `deleg_e9ce44d1`; [hash receipt](parent-consumption01.json) binds the exact prepared package. Authorization was issued once and the claim is spent. Do not rerun or alter the bound files.

- Prepared manifest SHA256 `ad784bb3b9f490cda8ba4690545e52910aa4412f80f6e258b9b218595e8e627b`.
- Candidate SHA256 `bac66033e796c0ecb6f3390dd512751b3475b1bca440c1a7d591092e4e4821f4`;7,880 prelaunch files,7,757 callback files,10 links.
- Preparation archive SHA256 `9b47e7fd48b04f35b491ddf6af0f815ddf06e141cf855d6cbb752bf647f9c31c`; raw large candidate is local-only and retained losslessly there.
- Result archive SHA256 `9ef433fa35707fb6811ce0be2b888041476e8974ac5c5094fbe6bee075e9a273`; all five exports size/hash verified against [manifest](result-manifest01.json).
- [Predecessor](../pcie-postfit-01/RESULT-ACCEPTANCE.md) remains accepted strictly as failed/partial evidence, published in4cce4dc. Successor's narrow helper correction and isolated retargets are documented in [delta](query-delta.diff).

## Active handoff

Both local-only leaves of `deleg_038b930d` completed. Parent verified and [accepted the diagnostic result](RESULT-ACCEPTANCE.md), with [exact consumption receipt](parent-result-consumption01.json). Separate clock/exception research supports preparing a fresh isolated baseline/candidate comparison; it is not approval of executable bytes or a source/timing repair. No changed-clock native experiment or fit has run. The immutable [initial result](RESULT.md) retains its review-pending historical wording; this checkpoint and acceptance supply the later disposition.

The selected [OFS2026.1 target](../../ofs-2026-target-01/DISPOSITION.md) remains reconciled; no donor-pin migration or upstream divider fix. Separate EMIF1 hold, other CDC/timing issues, matching persona, live backend/recovery and full hardware qualification remain open.

# CPA feedback observations — parent comparison pending independent review

Three bounded STA observations completed on preserved netlist copies. They did not synthesize, fit, change timing requirements, program an image or access hardware. Each command completed with supervised/native-CMake/effective/outer zero, confirmed process termination and preserved original Work/PIM file/link inventories. Exact interpretation remains under independent review; no timing correction is established.

## Acquisition

- [feedback37](cpa-feedback37/collection40.json), Quartus26.1.1 / Work23: reproduced the −0.004 ns anchor and measured the core feedback loop. Explicit board-reference-clock→PHY-feedback queries found no paths. Their `0 0.000` return is **unavailable path data, not zero physical delay**.
- [feedback41](cpa-feedback41/collection43.json), Quartus26.1.1 / Work23: separated rising/falling raw min/max paths and allowed the selected PHY feedback pin's immediate upstream keeper to be reported. All eight requested reports returned one path.
- [work21-46](cpa-work21-46/collection49.json), original Quartus25.1 / Work21: performed the matched observation on a fresh copy of the passing baseline and reproduced its +0.082 ns anchor. The original fallback was not rebuilt or changed. All eight reports returned one path.

The core pair is `pa_core_clk_out[0]`→`pa_core_clk_in[0]` on EMIF1 primary tile1. The PHY reports consistently start at `pll_inst|pll_inst|lvds_clk[0]` and end at tile1 `pa_fbclk_in[1]`. All are final-snapshot **Fast vid2 100C** observations. No broad clock-network fanout report was used.

## Matched raw delays

| Feedback path | Polarity | Metric | Work21 /25.1 | Work23 /26.1.1 | W23−W21 |
|---|---|---|---:|---:|---:|
| Core | Rise | Minimum | 3.479 ns | 3.478 ns | −0.001 ns |
| Core | Rise | Maximum | 3.857 ns | 3.853 ns | −0.004 ns |
| Core | Fall | Minimum | 3.458 ns | 3.455 ns | −0.003 ns |
| Core | Fall | Maximum | 3.834 ns | 3.829 ns | −0.005 ns |
| PHY | Rise | Minimum | 1.166 ns | 1.166 ns | 0.000 ns |
| PHY | Rise | Maximum | 1.356 ns | 1.356 ns | 0.000 ns |
| PHY | Fall | Minimum | 1.166 ns | 1.166 ns | 0.000 ns |
| PHY | Fall | Maximum | 1.355 ns | 1.355 ns | 0.000 ns |

[Machine comparison50](feedback-comparison50.json) preserves exact source/capture identities and path-row checks. The core paths are **not structurally identical**: 58 versus57 reported rows. PHY path structures have seven rows each. Do not broaden those statements into complete implementation or Boolean equivalence; retain fanout and all raw report differences.

## Remaining distinction

The signoff launch-clock CPA `COMP` term still changes **−2.208→−2.292 ns**, whereas these measured core-loop extrema change by at most0.005 ns and the PHY extrema do not change. The old signoff advantage remains0.084 ns COMP plus0.002 ns clock interconnect, with the same0.288 ns data delay and2.968 ns required time.

Those observations do **not** define the production CPA compensation equation, prove a compiler defect or justify choosing arbitrary min/max/mean values until an equation fits. The remaining explanation could involve unmeasured internal CPA/model treatment or effective implementation properties; it must be supported, not invented.

The installed26.1.1 help exposes `report_path`, but not `report_delay_calculation`; no imported CPA/compensation command was found in the bounded name discovery. `report_clock_network` expands target fanin/fanout, and `-initial_depth` only collapses GUI rows—it is not a query-size cap. The named raw-path observations above are deliberately narrower.

No further fit, seed, margin change, generated-clock phase/latency edit or vendor-RTL override is scheduled. The migrated images remain undeployable. Consume the independent diagnostic review before selecting any next observation or declaring the remaining vendor-support gap.

# Actual Work21 persona STA01 — timing FAIL

**Analysis completed; numerical timing and signoff FAIL. Independent evidence review pending.** Native/effective **0/0**, original wrapper **125** retained; no timeout or surviving owned group. Ended 2026-09-23T17:01:47.204913Z. Native runtime 00:03:52; peak virtual memory 10,133 MB. Native footer **0 errors / 380 warnings**, matching the parsed occurrence ledger. [Receipt](outer-sta01.json), [warnings](warning-ledger01.json).

The result archive SHA256 is `387cdff4f13b15f37cbf9155c1d71576aedd13a63ee52447cada56384cdd91b6`; 5,872,202 bytes, all **14 embedded members verified**. A separately captured dedicated signoff report supplements the original collection. The outer rejection traces to one native SQLite runlog appended row; **6,015 other bound entries and all 344 protected snapshots unchanged**, with no source/constraint/static-image drift detected. Original status is not relabeled. [Output-role reconciliation](NATIVE-DELTA-DISPOSITION01.md).

## Numerical result

The existing OFS helper reported **645 clock-domain/corner/metric records: 643 nonnegative, two negative**, across five corners. These are domain summaries, not an exhaustive set of timed paths or coverage proof. [Parsed literal records](domain-timing-records01.json).

| Corner | Metric | Clock domain | Slack | TNS |
|---|---|---|---:|---:|
| 2_slow_vid2_100c | setup | EMIF0 core_usr_clk | -0.367 ns | -26.907 ns |
| 2_slow_vid2b_100c | setup | EMIF0 core_usr_clk | -0.356 ns | -25.662 ns |

The worst reported cone is **inside our DMA CSR manager**, not a new vendor-PHY hold defect: `descriptor.length[14]~ENA_dff` → `descriptor.length[0]~DUPLICATE`, both in `core|dma|csr_mgr_inst`, same 3.000 ns clock, no SDC exception, six logic levels and 3.186 ns data delay. The detailed reports contain only the worst 20 setup paths per failing corner. [Exact detailed path reports](artifacts-sta01/persona/build/syn/board/ia840f/syn_top/output_files/timing_report/).

Native closure summary: setup FAIL; hold/recovery/removal/minimum-pulse-width summaries Pass; Unconstrained Paths FAIL; Design Assistant High Severity Violations. Unconstrained summary reports two inputs / 78 endpoint-pairs and two outputs / 10 pairs for both setup and hold; zero illegal/unconstrained clocks is not full coverage. Signoff DRC reports **24/88 rules failed**. Keep capped/disabled/native suppression limitations and all F1–F6 fit-review findings. [Exact line-bound panels](native-panels01.json), [dedicated DRC](artifacts-reports03/persona/build/syn/board/ia840f/syn_top/output_files/ofs_pr_afu.tq.drc.signoff.rpt).

## Clock behavior and stage limits

The native log confirms **Loading final database**, and detailed path reports identify snapshot `final`. The existing report hook ran, declared user clock high unused by the AFU, computed candidate rates and retained actual **200 MHz high / 100 MHz low**, matching the requested auto ceilings. It reread SDC as expected. These are not this AFU core's frequency or a timing remedy: the failing core uses bank0 memory clock. No requested frequency, SDC or RTL was changed. [Computed-clock file](artifacts-sta01/persona/build/syn/board/ia840f/syn_top/output_files/user_clock_freq.txt).

Next correction work traces the exact CSR combinational admission/range cone and seeks a minimal protocol-preserving pipeline/logic change with directed regression, rather than slowing DDR, adding false paths, discarding guards or blindly changing seed. The negative evidence and output-role supplement require independent review before acceptance. No new native build or hardware action follows automatically.

No synthesis/fit rerun, assembler/GBS, device access, programming, reset, driver change or reboot occurred. Vendor DDR simulation SKIPPED BY USER; the overall hardware goal remains incomplete.

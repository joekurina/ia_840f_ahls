# Work15 result acceptance — clock progress accepted; timing FAIL

**ACCEPT native compile/fit/STA/assembly evidence and the narrow PCIe clock correction on the fresh fit. Timing FAILS; hardware NOT RUN/NOT QUALIFIED; ready_for_build=false.** Parent consumed the independent result review and next-iteration recommendation from `deleg_6a2be4c6`. This is neither deployment authority nor a timing waiver. ([Independent review](result-independent-review01.md), [parent receipt](parent-result-consumption01.json))

Parent reverified all 55 frozen files and lossless closure of 19 preparation, 16 completion and nine completed-report exports. Native rc0 and successful assembly are established separately from timing failure. Original Work14 and PIM remained unchanged; maintained SOURCE has the accepted SDC/two-gate overlay plus the recorded native build-log addition. Work15 itself has the two native FME metadata changes. ([Freeze](result-review-freeze01.json), [postflight](postflight-summary01.json), [review](result-independent-review01.md))

## Accepted fresh-fit change

The final clock table is exactly original80 plus generated PCIe `avmm_clock0`, with all original reported fields unchanged: period19.858ns, waveform0.000/9.929ns, modern divider inclk→clock_div2, master `sys_pll|iopll_0_clk_100m`, divide2. The divider is constrained; native intra-clock setup/hold worst slacks are17.489/0.056ns. Parent matched the146 net-delay assignment keys across Work14/15 and verified the eight former Invalid-clock FIFO assignments now have positive numerical results (minimum15.369ns). No Invalid-clock net-delay summary rows remain. These are actual fresh-fit results, not transferred claims from the earlier fitted-copy trial. ([Parent receipt](parent-result-consumption01.json), [review §§3–4](result-independent-review01.md))

## Not accepted or closed

EMIF1 core→PHY hold remains −0.004ns/TNS−0.004, Fast vid2 100C. Reported failing endpoints, physical data path and delays are unchanged from Work14; only a clock-tree fanout field differs. Setup minimum+0.151ns, recovery+0.274ns, removal+0.137ns and pulse-width0.000ns do not waive hold. High signoff remains seven failed rules/34violations/zero waived. Unconstrained JTAG ports and BMC IRQ, overridden multicycles, cut crossings, detailed skew/exception completeness and warning follow-ups remain open. ([Review §§4–5](result-independent-review01.md), [warning disposition](warning-review01/PARENT-DISPOSITION.md))

The new FME interface is `fd2baeed-3092-5735-90c9-52ef20542b75`; previous personas do not inherit compatibility. SOF/RBF size/hash observations are provenance only. No DDR/transfers/AHLS numerical behavior, PR, flash/QSPI boot, sustained operation or hardware safety qualification follows from this build. ([Review §6](result-independent-review01.md))

## Next native iteration

Retain the supported PCIe correction. The EMIF path is a vendor-directed Hyper-Register→UFI→hard-PHY transfer, not a fabric logic chain to lengthen blindly. All Paths/aggressive hold/maximum effort are already enabled. Resolve the exact Fitter-stage objective and legal tighter fit-only control before changing it; do not guess `-add` semantics, edit generated PHY RTL, relax final requirements or sweep seeds. Use the current Quartus→reports→correction→Quartus procedure, with no new mock/source-SPEC/QUALITY loop. ([Next-iteration recommendation](next-iteration-recommendation01.md), [iteration authority](ITERATION-AUTHORITY.md))

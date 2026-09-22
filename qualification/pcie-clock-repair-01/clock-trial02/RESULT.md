# Clock-trial02 — completed native candidate trial

> Initial observation record retained below. Independent result review has since been consumed: see [RESULT-ACCEPTANCE.md](RESULT-ACCEPTANCE.md) for the narrow accepted scope and remaining limits. Pending-review wording below is historical.

**Native/effective/outer rc0/0/0. Termination confirmed; originals preserved. Independent actual-result review pending. Timing NOT ACCEPTED; ready_for_build=false. Attempt SPENT — do not rerun or reissue.**

The accepted package was published as `a12310a9609f8a80fa3e7d86e6bc92182a99e91c`. The separately inspected issuer ran once in owned tmux @56/%56. Native STA PID23848 ran from 2026-09-22T17:13:12.813331+00:00 to 17:14:42.458290+00:00. Quartus reported 0 errors/187 warnings. The supervisor confirmed termination, empty final live PID set and no supervision errors; all three original Work14/SOURCE/PIM inventories are unchanged (`result-readback01/native-result.json`, `execution-status.json`, `preservation-after.json`). Ordinary-file status readback in @57/%57 independently found no live group and verified authorization/issuance records (`native-status01.json`).

## Actual observations, not signoff

The final-clock guard completed. Native inventory contains 81 clocks: the original 80 plus C; native C period is 19.858ns, generated metadata `sys_pll|iopll_0_clk_100m pcie_wrapper|pcie_ss.top|host_pcie.pcie_ss|pcie_ss|EP_PFTILE_WRAPPER.gen_pciess.u_pciess_p0|u_pciess|gen_sub.u_hipif|u_pciess_clock_divider|clkdiv_inst|inclk 2 1`, waveform `0.000 9.929 `. Original master M period is 9.929ns. Known-receiver and tile checks completed; this does not turn all conservative nodes into clock loads (`result-readback01/reports/audit.tcllist`; `native-observations01.json`).

All eight previously invalid FIFO net-delay assignments now have numerical Required/Actual/Slack in all five acquired corner iterations, with four detailed paths per assignment; minimum observed slack is 15.229ns. Every net-delay report contains 146 assignment rows, zero Invalid clock rows and at most48 detailed paths for any assignment, below the requested20001. These are mechanical observations pending independent validation of selectors, corner semantics, provenance and completeness (`baseline-fifo-row-anchors01.json`, `fifo-numerical-observations01.json`).

The native reports still state setup/hold incompletely constrained. Negative domain summaries, including the separate EMIF1 hold issue, remain explicit in `native-observations01.json`. Timing/exception samples, skew summaries and MPW domain summaries are not exhaustive coverage or DRC signoff. No maintained-source edit, refit, hardware access or new bitstream occurred.

## Evidence and continuation

The verified result archive `result01.json.gz` SHA256 `1619230e6582918bc8eb51e3f05c0514348f4b34c7f0afb6535bd1e5cb4d533f` is1763076bytes and retains all86 exports losslessly, including79 report files totaling49058648bytes. `result-manifest01.json` SHA256 `f0dd91835a63a5f9b09bacd7a07aa1935d1effb1cf6943848534f9983d8ed2a7` and `result-verification01.json` bind every extracted byte. Oversized raw `reports/sdc.rpt` stays local and is recoverable from the archive.

Independent result review and a parallel **conditional source-only** minimal production-delta recommendation are active in deleg_6a5a7667. Neither may launch tools or accept the mission. The parent must consume the actual result verdict before deciding source promotion/fresh changed-design fit. Existing Work14 compile machinery is the intended reuse route, not a new framework. Hardware/recovery, matching persona, full timing/CDC/DRC, DDR/transfers/AHLS/PR/sustained/QSPI gates remain open.

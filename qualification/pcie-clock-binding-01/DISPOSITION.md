# Parent disposition — PCIe clock-binding source diagnosis

**Source diagnosis accepted; correction NOT IMPLEMENTED. Timing NOT ACCEPTED. Next fitted-database inspection is blocked pending resolution of the earlier Query04-specific approval stop.**

## Verified result

The [independent local-evidence review](independent-research.md), SHA256 `27150f6a979e761d6207793397a33c72a05f3fa20de28f3f979745413f426547`, identifies obsolete hierarchy in maintained `syn/shared_config/top.sdc:35–37`. The [parent receipt](parent-source-verification01.json) independently matches **eight generated payloads and five maintained files** to the actual Work14 authorization. Parent also rehashed the complete Work14 STA/fitter reports and checked STA:2706,208866–208872,209811–209818 and FIT:31722–31725 against the review.

Generated `pcie_ss.sdc:191–192` supports the modern P-Tile divider path and a divide-by-two generated relationship. Its creation is conditional on the standalone Lite-clock port, while the integrated design supplies CSR clock internally. Work14 reports `sys_pll|iopll_0_clk_100m` at its evaluated 100.71 MHz; no replacement nominal 100/50-MHz base clock is justified. See [review §§2–4](independent-research.md).

The fitted divider exists, but the evidence does **not** establish exact final `inclk`/`clock_div2` pin matches, their clock association, or equivalence to the fitter's `clock_div2x` and STA's `~div_reg` aliases. Restoring `avmm_clock0` also changes applicability of existing asynchronous groups and multicycles. The four named FIFO destination groups have eight invalid destination-clock-dependent net-delay assignments; their clock connectivity remains unverified. This is not a safe blind two-selector edit. See [review §§5–6](independent-research.md).

## Precise next scope and approval boundary

The next required evidence is a **bounded offline Quartus inspection of a preserved copy of Work14's fitted database**, limited to:

1. The exact divider input/output pin collections and master-clock association.
2. Existing generated-clock definitions/applicability, including missing or duplicate bindings.
3. Clock connectivity of the four already named FIFO destination groups and the existing dependent timing exceptions.

This is software analysis, not live FPGA/MMIO access. It would require a reviewed finite script and the normal tool approval path; it does not authorize synthesis, fitting, a full rebuild, constraint/source edits, programming, reboot or hardware access. Original Work14 artifacts must remain preserved. Do not run or reroute the older Query04 command under a new name.

History was checked to avoid misattributing the restriction: the earlier Query04 preparation was stopped **by the tool's approval timeout**, not by a demonstrated hardware fault or a user statement that ordinary offline analysis is unwanted. The tool explicitly said the command did not run and prohibited retries/rephrasing/alternate routes pending a user response. That specific unresolved stop is distinct from the standing approval for ordinary source/build work. No invocation was attempted in this continuation; the needed scope decision is now made explicit rather than silently bypassed.

## Scope retained

No maintained RTL/SDC/gate changes, remote calls, vendor execution, simulation or hardware access occurred. The separate −0.004 ns EMIF1 hold failure remains unresolved. Work14's changed FIM interface still requires a matching persona. DDR simulation remains SKIPPED BY USER. Deployment approval is recorded, but independently verified host recovery and the finite source-supported live procedure remain missing prerequisites. This diagnosis is not mission completion.

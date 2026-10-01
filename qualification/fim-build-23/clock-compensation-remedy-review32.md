# EMIF1 CPA compensation: remedy review32

**Outcome:** no supported, requirement-preserving correction is established. The differing `COMP` row belongs to the EMIF **clock phase alignment (CPA) loop**, not an added data-delay element or a freely adjustable timing requirement. The next discriminator is the fitted CPA feedback/compensation calculation—not another seed.

Scope: local retained evidence and bounded official-source research only. **GPT-6 / openai-codex substituted for unavailable GLM5.3.** No native tools, remote access, hardware, implementation, or source-script execution. OFS2026.1, Quartus26.1.1 Build130, AGFB027R25A2E2V, the unchanged 3.000ns requirement, clocks, DDR and PR/static boundaries remain mandatory.

## What is established

The parent's [seed disposition](seed-disposition30.json) establishes that seed3 did not fix seed2: all five slacks and all 49 ordered reported rows/corner match after only the explicit six-row `refclk_Duplicate`→`refclk_Duplicate_3` alias at the same site. This is reported-path equality, not complete physical-clock-tree identity.

I recomputed the [Work21→Work22 decomposition](reference-clock-compensation18.json) with decimal arithmetic:

| Corner | Passing 25.1 slack | Failing 26.1.1 slack | CPA COMP advantage | Launch-clock IC advantage |
|---|---:|---:|---:|---:|
| Slow vid2 100C | 0.242 | 0.132 | 0.096 | 0.014 |
| Slow vid2b 100C | 0.272 | 0.167 | 0.083 | 0.022 |
| Fast vid2a 0C | 0.118 | 0.047 | 0.056 | 0.015 |
| Fast vid2a 100C | 0.086 | 0.006 | 0.072 | 0.008 |
| Fast vid2 100C | 0.082 | −0.004 | 0.084 | 0.002 |

All quantities are ns. At the failing corner, `COMP` is −2.208 versus −2.292 at `TILECTRL_X172_Y0_N298`, `…|tile_gen[1].tile_ctrl_inst|pa_core_clk_out[0]`; launch-clock IC is 3.238 versus 3.236. Their 0.086ns sum accounts for the reported slack difference; data delay 0.288 and required 2.968 remain unchanged. The separate IOPLL `COMP` is not the changing row. See [Work22 STA](../fim-build-22/timing47-readback/output_files/ofs_top.sta.rpt), lines 142594–142710. This localizes the difference; **it does not prove a compiler defect or identify an adjustable 84ps setting**.

## What sets this clock behavior

TimeQuest's `COMP` label denotes compensation delay; the old AN471 establishes that reporting vocabulary, not Agilex applicability.[1] The correct-family F/I-Series guide explains that CPA “employs negative feedback to dynamically adjust the phase of the core clock signal to match the phase of the PHY clock signal.” It is version 23.2, not evidence of a 26.1.1 fix.[2]

The retained generated source closes the architecture-to-pin connection:

- [PLL RTL][pll], line 396, uses `.feedback("direct")`, explicitly commenting that EMIF alignment is handled by CPA, not PLL compensation. Both actual Fitter reports show EMIF1 direct mode, the same site, M40/N1 and 750ps VCO: [Work21](../fim-build-21/final-capture01/ofs_top.fit.rpt), 6742–6751; [Work22](../fim-build-22/timing47-readback/output_files/ofs_top.fit.rpt), 40640–40649. Generic “change PLL compensation mode” advice is therefore misplaced.
- [Core-clock RTL][core], 48–51 and 422–435, expects feedback **after propagation through core clock networks**, permits Fitter-inserted clock buffers, and returns the buffered clock to CPA. [Tile RTL][tiles], 1715–1723, connects that feedback to `pa_core_clk_in`, the PHY reference to `pa_fbclk_in`, and CPA output to `pa_core_clk_out`.
- [Tile RTL][tiles], 1618–1636, fixes both phase offsets to zero and disables core phase-control inputs; output 0's PHY-feedback mux depends on rate-converter enable. The [evaluated wrapper][evaluated], 83–84, 107, 543, 572, 1702, selects ratios 4/4, primary tile 1, `CPA_FB_MUX_1_SEL="local_p_clk"`, rate-converter enabled, and VCO phase 0. Generated output 0 therefore selects `fb1_p_clk`. **`CPA_FB_MUX_1_SEL` controls output 1's mux, not the failing output 0.**

SHA256 comparison against the [actual native Work22 generation inventory][inventory] matched the local tile, core-clock, PLL, tile-wrapper, evaluated-wrapper, IP-parameter Tcl and SDC files. These are actual native-generation source bytes, not merely older templates. Their feedback connectivity explains why compensation can depend on fitted clock-network behavior; they do **not** expose the numerical STA equation producing −2.292.

## Remedy boundary

No reviewed source proves a supported user control that changes this CPA loop while preserving the required clock contract. Internal phase-offset fields are physical-looking parameters, but modifying vendor RTL or inventing overrides is not an authorized remedy. `DIAG_USE_CPA_LOCK` selects reset/lock handling ([core][core], 170–171), not an output-phase adjustment. Editing generated-clock phase/latency or subtracting 84ps from STA would change the analysis, not establish corrected hardware.

The [previous force-Hyper-Register/delay-chain branch](../fim-build-18/VENDOR-RESEARCH-DISPOSITION.md) remains closed; its eSRAM workaround supplies no CPA applicability. No margin, effort, retiming or seed retry is proposed. “Not established here” is distinct from “vendor declares unsupported” or “no remedy exists.”

## Smallest precise remaining evidence gap

Obtain **the implemented feedback paths and the compiler's compensation calculation for this one CPA output**, comparing Work21/25.1 with Work23/26.1.1 at **Fast vid2 100C**. Required discriminator:

1. For `local_mem_wrapper|mem_ss_top|mem_ss_sv|mem_ss|mem_ss|emif_1|emif_1|arch|arch_inst|io_tiles_wrap_inst|io_tiles_inst|tile_gen[1].tile_ctrl_inst`, identify the implemented core return to `pa_core_clk_in[0]`, selected PHY-feedback input, effective offset/divider settings, and contributing min/max delays.
2. Explain how those values produce the reported `pa_core_clk_out[0]` COMP −2.208/−2.292. This separates changed feedback implementation from changed compensation/model treatment; neither is currently proven.

The retained Work21/22 STA and FIT reports contain **no EMIF1 `pa_core_clk_in` or `pa_fbclk_in` rows**. Reprinting the launch-clock path cannot fill this gap. No inspected installed source identifies the production STA calculation; simulation-atom files would not establish it.

**Smallest next documentation probe, parent only:** request `help -cmd report_delay_calculation` and `help -cmd report_path` in 26.1.1 Timing Analyzer, without opening a project. The `help -cmd` interface is evidenced by [Work18's retained query](../fim-build-18/assignment-readback01/query.tcl), 17–20; command-specific support for CPA decomposition is **not yet verified**. Public command-page fetches failed. Do not invent options or atom keys. If documented support exists, limit the subsequent read-only existing-netlist inquiry to the object/corner above; ordinary cell/IC output alone must not be relabeled CPA compensation evidence.

If the documented interface cannot expose that calculation, the remaining blocker is a **vendor-supported CPA model/implementation explanation or applicable 26.1.1 patch**, not a locally justified clock edit. No vendor contact, upload, patch download or tool-version change is implied. Timing closure remains unmet.

Research boundary: six targeted searches and six official-page retrieval attempts, including browser recovery; only the two substantive official sources below support external claims. No further searches are proposed.

## Sources

[1] [AN 471: High-Performance FPGA PLL Analysis with TimeQuest (August 2007)](https://docs.altera.com/api/khub/documents/O6p4tSxkt5RnrxLEaBfhgg/content).
[2] [Agilex 7 F/I EMIF User Guide v23.2, §3.1.8](https://docs.altera.com/r/docs/683216/23.2/external-memory-interfaces-agilextm-7-f-series-and-i-series-fpga-ip-user-guide/agilextm-7-f-series-and-i-series-emif-architecture-clock-phase-alignment).

[tiles]: ../msa-bank-spreading-integration-01/generation-execution-03/actual-results/work/mem_ss/mem_ss_mem_ss_501_qm5zaka/synth/ip/mem_ss_mem_ss_501_qm5zaka/mem_ss_mem_ss_501_qm5zaka_emif_1/altera_emif_arch_fm_191/synth/altera_emif_arch_fm_io_tiles.sv
[core]: ../msa-bank-spreading-integration-01/generation-execution-03/actual-results/work/mem_ss/mem_ss_mem_ss_501_qm5zaka/synth/ip/mem_ss_mem_ss_501_qm5zaka/mem_ss_mem_ss_501_qm5zaka_emif_1/altera_emif_arch_fm_191/synth/altera_emif_arch_fm_core_clks_rsts.sv
[pll]: ../msa-bank-spreading-integration-01/generation-execution-03/actual-results/work/mem_ss/mem_ss_mem_ss_501_qm5zaka/synth/ip/mem_ss_mem_ss_501_qm5zaka/mem_ss_mem_ss_501_qm5zaka_emif_1/altera_emif_arch_fm_191/synth/altera_emif_arch_fm_pll.sv
[evaluated]: ../msa-bank-spreading-integration-01/generation-execution-03/actual-results/work/mem_ss/mem_ss_mem_ss_501_qm5zaka/synth/ip/mem_ss_mem_ss_501_qm5zaka/mem_ss_mem_ss_501_qm5zaka_emif_1/altera_emif_fm_280/synth/mem_ss_mem_ss_501_qm5zaka_emif_1_altera_emif_fm_280_gdk3rhy.v
[inventory]: ../fim-build-22/regeneration17-readback/qualification/fim-build-22/regeneration17/inventory.json

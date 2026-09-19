# Work08 PCIe divider review

## Outcome

**Source-supported missing-clock cause identified; corrective relationship is divide-by-2 from the existing CSR clock, not a new 100 MHz base clock. Exact fitted divider pin/input confirmation remains necessary before applying the candidate.** Protected vendor HDL prevents a complete static primitive connectivity trace. No Quartus query was launched: no separately bound post-fit query context was established, and the existing source-bound gate was not bypassed. S1/TRS consequently remains narrowly open.

Work08 was not changed. All remote operations ran through owned tmux window `pcie_clock_review`, pane `%345`, session `ia840f_mailbox_monitored_01`, SSH `uwb_student00@100.101.227.97`. The first probe verified `Agilex7Workstation`, UID 1000, and found no process whose executable name begins `quartus`. The re-read final flow report says Successful, Fri Sep 18 20:39:23 2026. This does not turn the independent timing FAIL into PASS.

## Evidence

`W=/home/uwb_student00/ahls/new_BSP/work_ia840f_fim_08`. JSON files contain original absolute paths, complete source text and remotely calculated SHA256. The collector independently recomputed each SHA256 from the transferred text and asserted equality. Sources below are exact Work08 readbacks, not maintained-tree substitutes.

- `sources-01.json`: generated `ipss/pcie/qip/pcie_ss/intel_pcie_ss_axi_500/synth/pcie_ss.sdc`, SHA256 `b5fa069c1876031a8f63c1198f98b99dfabf5e7ad0cb748e5614bc235e04c265`.
- Same file: `hip_if_adaptor/pciess_clock_divider.sv`, SHA256 `604f5ed9a6d0c2c89bed6c190693d7c6e018fa372c735d741f4c4f2f500e166c`, is protected/encrypted; no cleartext division/input body was available. No decryption attempted.
- `sources-03.json`: `pciess_hip_if_adaptor.sv`, `pciess.sv`, and `intel_pciess_ptile_wrapper.sv` are also protected; generated top `pcie_ss_intel_pcie_ss_axi_500_gycdipy.sv` is readable, SHA256 `ea4e45e5539f8153dbb0590c01c75f3f2c36103e83d989894033d567eaf55536`. It exposes input `p0_axi_lite_clk` at 1138 and forwards it as `.axi_lite_clk(p0_axi_lite_clk)` at 4692 and other configuration branches.
- `sources-04.json`: actual `ofs-common/src/fpga_family/agilex/pcie_ss/pcie_ss_axis_top.sv:716` wires `.p0_axi_lite_clk(csr_clk)`.
- `sources-05.json`: `src/board/ia840f/top.sv`, SHA256 `6061a38dd44ed4ae935f3b0ee89a664139205446b94a441ea384e921b7be0a9d`: line 302 `assign clk_csr = clk_100m`; sys PLL logical outclk_1 drives clk_100m at 516; pcie_wrapper receives clk_csr at 592. `pcie_wrapper.sv`, SHA256 `4dd941c11890bbb38f2851ce9bc59dd79a8c457f1c738f904eaf38d47a4be0e0`, passes csr_clk through the common argument macro at 269 and instantiates pcie_ss_axis_top at 300.
- `sources-03.json`: final `ofs_top.flow.rpt`, SHA256 `02dda2081d5458cfed931a4cc8d53c254e2c85b567a2b1a102fcf35d7e4ac40c`, line 22 final successful flow status.
- Prior final STA snapshot `../monitor-20260919T033051Z-01e73a/13-ofs_top.sta.rpt:2680` explicitly gives `sys_pll|iopll_0_clk_100m`, actual 100.71 MHz / 9.929 ns, target `{sys_pll|iopll_0|tennm_pll|outclk[2]}`. Do not confuse the wrapper logical output index with the fitted physical index.

## Why the generated constraint is missing

Generated SDC lines 23–40 implement port existence with `get_ports`. Lines 161–172 create `p0_axi_lite_clk` only if `p*_axi_lite_clk` exists as a port. Lines 187–188 compute clock existence but then **gate the generated-clock block on port existence**, not on the actual internal CSR clock. Lines 191–192 specify exactly:

```tcl
create_generated_clock -name avmm_clock0 -source p0_axi_lite_clk -master_clock p0_axi_lite_clk -divide_by 2 \
 ${pcie_ss_inst}|EP_PFTILE_WRAPPER.gen_pciess.u_pciess_p0|u_pciess|gen_sub.u_hipif|u_pciess_clock_divider|clkdiv_inst|clock_div2 -add
```

This IP is integrated with internal CSR wiring, not a top-level `p0_axi_lite_clk` input. The port-based applicability test therefore does not describe the integrated clock source. The final STA lacks avmm_clock0 and explicitly lists the fitted divider as unconstrained. These observations support a skipped standalone-oriented SDC clock block as the integration defect. A live query of the actual scoped `get_ports` collection would close the remaining runtime scoping detail; the protected primitive prevents claiming the complete fitted input trace from RTL alone.

The **divide-by-2 relationship is vendor-SDC evidence**, not an inference from `clock_div2x`. Do not use the generated `core16_lite_clk_freq=100` parameter (SDC:90) to replace the implemented clock. The correct candidate inherits the real PLL master and its precision.

SDC:628–641 explains both warning sites: 631 and 639 compute `set_net_delay` from `dst_clock_period`, multiplier 0.8. An unconstrained destination supplies no period. This is consistent with the divider failure, but exact FIFO keeper-to-divider connectivity still needs the fitted query. Do not claim that every warning disappears until reanalysis verifies it.

## Minimal corrective candidate, not applied

Add one board-integration generated clock, after the actual CSR master is defined, targeting **the verified output pin of this one divider**, with source the actual CSR master target and `-divide_by 2`. Do not modify vendor RTL or regenerate the CSR PLL; do not create a nominal-100MHz base clock. `candidate.sdc.disabled` records the finite proposed command and fail-closed collection checks. It is deliberately not an active SDC and is not a tested patch.

Two exact target representations differ: vendor SDC uses `clkdiv_inst|clock_div2`; final fit calls its output `clock_div2x`, while STA identifies `clkdiv_inst~div_reg`. This is why a target replacement must not be guessed or broadened with a wildcard. The candidate retains the vendor pin as a **lookup requiring confirmation**, not a proven post-fit pin.

Do not copy SDC:218's asynchronous clock-group cut into the corrective candidate. The requested minimal repair is a generated relationship, not a speculative false path. Existing CDC constraints remain independently reviewable.

## Single remaining bounded query

In a separately source-bound post-fit context, fresh diagnostic outputs, with supported installed APIs established first:

1. Load completed Work08 revision ofs_top / AGFB027R25A2E2V and final SDC set without changing Work08. Resolve only `...u_pciess_clock_divider|clkdiv_inst~div_reg` (CLKDIVBLOCK_X11_Y330_N106, fanout 355), its input/output pins and enabled division setting. Record its input clock/master and the concrete source/target pin names. Check `p*_axi_lite_clk` scoped port collection and clock absence.
2. Trace the FIFO destination keepers from STA:3612–3619 to that output; then test the one-clock candidate in the fresh diagnostic context. Verify no unconstrained divider and no invalid destination-period assignments at SDC:631/639. Retain all other warnings/errors, no new cuts.
3. In the same loaded fitted netlist, enumerate exact/hierarchical `ALTERA_INSERTED_INTOSC_FOR_TRS` and `divided_osc_clk` clocks **and resources**. Report complete oscillator resource inventory. Only absence of both resource and clock closes S1 as inapplicable. Report-only token absence is insufficient; the existing SLD oscillator is not TRS.

The independent MSA setup failures and EMIF1 hold -0.004 ns remain unaffected by this proposed constraint repair. Core470, seven requested outputs, DDR clocks/geometry/mapping, PF1 and BAR contracts remain unchanged. No DDR simulation, programming, installation, permission change or commit occurred.

## Collection issues

Initial source batch 02 failed remotely because `ofs_top.asm.summary` does not exist; a stale shared tmux buffer was mistakenly exported as `sources-02.json`. **Exclude that file from evidence** (it is duplicate batch 01, not a successful second read). Collector now uses a per-batch buffer name, failing on missing buffers; successful corrected batch is sources-03. One later local command had a Python syntax error before SSH, then was corrected. No external project write occurred in either failure.

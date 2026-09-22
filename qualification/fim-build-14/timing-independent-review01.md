# Work14 independent timing and bounded compile-result review

## Verdict

**TIMING NOT ACCEPTED. Native compile/fit/assembly completion is supported; timing/constraint closure and hardware acceptance are not.** Work14 has one reported failing hold endpoint/path, −0.004 ns at **Fast vid2 100C Model**. The full report identifies it completely; another timing run is not needed to discover it. The most concrete source-resolvable constraint defect is an obsolete PCIe divider hierarchy in the maintained `top.sdc`, not an absent optional device.

Analysis only: local byte/hash checks and filtered report/source reads; only this report is written. No Quartus, OPAE, remote access, hardware operation, build, simulation, source change or git write. DDR simulation remains **SKIPPED BY USER**. This does not close the parent task or authorize deployment.

## Evidence and integrity

Citations are **1-based original file lines**. Aliases:

- **STA** = [reports11/output_files/ofs_top.sta.rpt](reports11/output_files/ofs_top.sta.rpt); **SUM** = its `.sta.summary`; **FIT** = `reports11/output_files/ofs_top.fit.rpt`.
- **DRC** = [reports13/output_files/ofs_top.tq.drc.signoff.rpt](reports13/output_files/ofs_top.tq.drc.signoff.rpt).
- **C** = [completion12](completion12/); **S** = `../../ofs-agx7-pcie-attach/` relative to this report.
- **PCIe-SDC** = the decoded `intel_pcie_ss_axi_500/synth/pcie_ss.sdc` payload in [pcie-rendered-constraints-live06.json](../pcie-generated-evidence-01/pcie-rendered-constraints-live06.json).

Before findings, independently matched all **5/5 reports11** raw sizes/SHA256 and their gzip hashes/decompressed bytes to its manifest. Subsequently matched **16/16 completion12** and **4/4 reports13** captured raw files to their manifests. Completion metadata confirms unchanged full STA/FIT identities. Also verified the frozen [result-review-inputs01.json](result-review-inputs01.json), SHA256 `99f58803c9b05c4c37a4203701176d517d866d9969d649c51fa4244ef1ede744`, and **39/39 unique bound files**, including the parent's immutable RESULT.md. Its bounded compile/timing/identity claims agree with the underlying evidence reviewed here; this is not blanket acceptance of its remaining hardware gates. Key hashes:

| Evidence | Bytes | SHA256 |
|---|---:|---|
| STA | 48,068,193 | `8c51a45bcff167fb80feb39a9338c62691401d0fa7be36d7a2caa0d94969c5e6` |
| SUM | 57,622 | `21b3a56b7a7380e8e63c5420301f4fa14e2e409414962063e2038c5f4f4d198b` |
| FIT | 19,940,793 | `32b311d2216c1675bf1cfc8813b93d1a55346977dd773a674ff9e8bee9b073ad` |
| DRC | 835,792 | `5e9a16353d01da508f057bdd04d40a830b664f15b5516541accea4bc3f8e705e` |

Narrow source reads were hash-matched to the actual [issued authorization](status-readback05/compile-authorization.json), SHA256 `42cb4974f9e6aba80aa25e5df385de1faac09251dd6695123448d0db931127be`: `top.sdc`, `pmci_top.sdc`, board `ofs_top_sources.tcl`, `top.sv`, `afu_top.sv`, `fim_afu_instances.sv`, `bwbmc_wrapper.sv` and `afu_design_files.tcl`. The prior decoded PCIe-SDC payload also matches Work14's inventory: `b5fa069c1876031a8f63c1198f98b99dfabf5e7ad0cb748e5614bc235e04c265`. The local maintained **QSF differs** from Work14; only **C/project/ofs_top.qsf** and final flow settings support this run's settings.

## 1. Actual timing failure and report sufficiency

Independent parsing of all **743 SUM Type blocks** finds one negative numeric entry and preserves eight `Invalid clock` entries. Worst setup **+0.015 ns**, hold **−0.004 ns**, recovery **+0.214 ns**, removal **+0.132 ns**, minimum pulse width **0.000 ns** agree with STA:209993–209997. Zero pulse-width slack is a reported pass, not positive margin. STA:2721–2738 explicitly fails overall closure, hold, DDR and unconstrained paths and reports high-severity Design Assistant violations.

**Exact Work14 hold path** — STA:126754–126762:

```text
From: local_mem_wrapper|mem_ss_top|mem_ss_sv|mem_ss|mem_ss|emif_1|emif_1|arch|arch_inst|hmc.amm.amm.data_if_inst|amm_writedata_0_r[0][243]
To:   local_mem_wrapper|mem_ss_top|mem_ss_sv|mem_ss|mem_ss|emif_1|emif_1|arch|arch_inst|io_tiles_wrap_inst|io_tiles_inst|tile_gen[2].lane_gen[1].lane_inst|lane_inst~phy_reg1
Launch clock: local_mem_wrapper|mem_ss_top|mem_ss_sv|mem_ss|mem_ss|emif_1|emif_1_core_usr_clk
Latch clock:  local_mem_wrapper|mem_ss_top|mem_ss_sv|mem_ss|mem_ss|emif_1|emif_1_phy_clk_l_0
```

- Arrival **2.964 ns**, required **2.968 ns**; **no SDC exception**; corner **Fast vid2 100C Model**. Hold relationship 0.000 ns, skew −0.080 ns, data delay 0.288 ns, one logic level (STA:126758–126783).
- Physical launch is Hyper-Register **BLOCK_INPUT_MUX_PASSTHROUGH_X192_Y3_N0_I32**; path passes **UFI_X210_Y0_N355**, tile2/lane1/pin3/phase3 `data_lane_c2p_ufi_i`, to **IO12LANE_X184_Y0_N374**, `data_from_core[19]`/`phy_reg1` (STA:126818–126826). Required-path uncertainty is 0.030 ns and uTh 0.342 ns (126860–126863).
- STA:2806 reports **one failing endpoint**, endpoint TNS −0.004 ns. The only two negative detailed path headers, STA:126747 and 172148, repeat the **same** endpoint/clock/corner summary, not two independent violations. DDR core reporting independently fails EMIF1 at this corner (209795–209801).

Thus the published STA is sufficient to identify and locate this failure, including arrival/required clock paths. No Work13 physical-path identity or historical acceptance is assumed, and −0.004 is not rounded away. Seed **2**, hold optimization **All Paths**, and aggressive hold closure **On** are already effective (FIT:175,204; C/project/output_files/ofs_top.flow.rpt:299,399). Reapplying those settings is not a fix; the evidence does not identify a proven replacement setting or justify modifying vendor/encrypted EMIF internals.

## 2. Exact unconstrained objects and invalid net-delay constraints

STA:209848–209854 reports, for **both setup and hold**, zero illegal clocks, **one unconstrained clock**, **two input ports/78 path pairs**, and **two output ports/10 path pairs**.

**Clock target** (STA:209862):

```text
pcie_wrapper|pcie_ss.top|host_pcie.pcie_ss|pcie_ss|EP_PFTILE_WRAPPER.gen_pciess.u_pciess_p0|u_pciess|gen_sub.u_hipif|u_pciess_clock_divider|clkdiv_inst~div_reg
```

FIT:9588,31151 independently places the divider's `clock_div2x` at **CLKDIVBLOCK_X11_Y330_N106**, fanout **355**. This is present clocking hardware, not a disabled-UART/PMCI empty collection.

**Ports** (STA:209951–209962; repeated 209971–209982):

- Inputs: `altera_reserved_tdi`, `altera_reserved_tms`.
- Outputs: `altera_reserved_tdo`, **`bwbmc_bmc_irq`**.

JTAG requires the applicable vendor constraint disposition; its reserved names do not automatically waive it. BMC IRQ is **not** the disconnected BMC-to-PCIe interrupt: S/src/board/ia840f/fim_afu_instances.sv:243–252 connects `.bmc_irq(bwbmc_bmc_irq)` while leaving `.pcie_irq()` open; `bwbmc_wrapper.sv:112–120` connects the support IP's BMC interrupt and CSR clock/reset. Its external receiver/timing contract remains unresolved. These tables name ports and give aggregate pair counts, **not all 88 individual endpoint pairs**; no internal pair list is inferred.

**Eight invalid assignments** are explicit at STA:3620–3627 and 209811–209818 (`pcie_ss.sdc:631,639`: no destination clock period). Define exact prefix:

```text
P = pcie_wrapper|pcie_ss.top|host_pcie.pcie_ss|pcie_ss|EP_PFTILE_WRAPPER.gen_pciess.u_pciess_p0|u_pciess|gen_sub.u_hipif|
```

Each following FIFO has two invalid assignments; append suffixes literally to `P`:

- `u_pciess_cplto_if|cplto_fifo_avmm_inst|auto_generated|`: `delayed_wrptr_g*` → `rs_dgwp|dffpipe*|dffe*`, and that destination pattern → itself.
- `u_pciess_cplto_if|cplto_fifo_lite_inst|auto_generated|`: `*rdptr_g*` → `ws_dgrp|dffpipe*|dffe*`, and destination → itself.
- `EP_CFG_IF.u_pciess_cfg_if|u_axi_lite_clk_to_user_avmm_clk_fifo|auto_generated|`: `delayed_wrptr_g*` → `rs_dgwp|dffpipe*|dffe*`, and destination → itself.
- `EP_CFG_IF.u_pciess_cfg_if|u_user_avmm_clk_to_axi_lite_clk_fifo|auto_generated|`: `*rdptr_g*` → `ws_dgrp|dffpipe*|dffe*`, and destination → itself.

PCIe-SDC:628–639 derives these limits from **destination clock period**, multiplier 0.8. STA's Net Delay Summary “Pass” (2732), or DRC's zero TMC-20023 violations, cannot turn invalid-clock rows into evaluated passes.

**Concrete source defect:** S/syn/shared_config/top.sdc:35–37 seeks `...|pcie_ss|u_pciess_p0|gen_sub.u_hipif|...`, whereas the actual prefix includes `EP_PFTILE_WRAPPER.gen_pciess.u_pciess_p0|u_pciess|`. STA:208866–208872 explicitly rejects both source and target collections and the generated clock. Its dependent groups/multicycles also fail to resolve (208882–208899). The hash-bound PCIe-SDC:187–192 already names the modern hierarchy and divide-by-two relationship, but conditionally gates creation on port existence. This supports a **narrow clock-binding repair investigation**, not a guessed frequency or unconditional duplicate clock. Connectivity from this divider to all four invalid FIFO groups remains unproven by these reports.

**Source-resolvable disabled-feature noise is separate:** C/project/fim_project_macros.tcl:7–17 omits PMCI/UART; C/project/ofs_top.qsf:99–107 explicitly disables them. Board `top.sv:100–125,620` conditionally removes PMCI ports/instance, while `ofs_top_sources.tcl:66` unconditionally loads `pmci_top.sdc`. Its unmatched `spi_egress_*`, `spi_ingress_*`, QSPI and m10 GPIO constraints (STA:208962–209085) are therefore stale disabled-PMCI applicability, suitable for narrowly guarded inclusion—not new clocks or fake endpoints. This does **not** dispose of BMC IRQ, the fitted PCIe divider, or active PCIe/AFU CDC findings.

## 3. High-severity Design Assistant findings

DRC:123–133 contains **seven failing High rules / 34 violation rows / zero waived**. Their detailed rows were compared with the corresponding STA panels and agree. These are not 34 proven hardware failures, but none is cleared by a successful compile or disabled-UART change.

| Exact rule | Count | Relevant detailed scope / citation |
|---|---:|---|
| CDC-50001 — 1-Bit Asynchronous Transfer Not Synchronized | 13 | Eight CSR power-good→AFU frozen/status crossings; timeout-frozen feedback, `flr_rcvd_vf_flag`, and three MSI-X `u_flrcmpl_fifo` pointer bits. DRC:227–239. |
| CDC-50004 — MUX-type CDC Transfer with Insufficient Constraints | 7 | Protocol-checker timeout address/length/requester/tag, PU-mode and two TX-header capture buses; missing data-delay constraints, mostly missing skew. DRC:252–258. |
| TMC-20027 — Collection Filter Matching Multiple Types | 5 | PCIe-SDC false-path destination filters at **442–445,451**, keeper/cell ambiguity. DRC:271–275. |
| RES-50001 — Asynchronous Reset Is Not Synchronized | 4 | Protocol-checker FIFO reset duplicates and MSI-X `u_rst_stclk_sync1/2` driving opposite-domain FIFO registers. DRC:288–291. |
| CDC-50007 — CDC Bus Constructed with Multi-bit Synchronizer Chains with Insufficient Constraints | 2 | MSI-X `u_ctrlshadow_dcfifo` and `u_flrrcvd_fifo` delayed-write-pointer chains; skew/data delay unconstrained, net delay constrained. DRC:304–305. |
| CDC-50012 — Multiple Clock Domains Driving a Synchronizer Chain | 2 | `protocol_checker_csr|mmio_immediate_frozen_reg` and user-clock PLL `qph_reconfig_from_pll_resync|...|din_s1`. DRC:318–319. |
| CDC-50003 — CE-Type CDC Transfer with Insufficient Constraints | 1 | `PCIE_LINK_CONN[0].tx_sb.pipe_tx|cpl_metering|impl|u_hia_dm_st_cplto_sync`: 10-bit `data_in_d1[*]`→`data_out[*]`, all three constraint fields unconstrained. DRC:332. |

Protocol-checker, FLR/MSI-X, completion-timeout and user-clock reconfiguration are active functional/safety-relevant areas. They require focused source/CDC-contract disposition, not blanket “vendor warning” dismissal or widening false paths. DRC:318 itself abbreviates its source list as **`[+ 3 more]`**; the separate DRC does not supply those omitted names. The small `reports13/output_files/ofs_top.sdc_constraints.rpt:15–30` lists only two SLD QIP registrations at each stage, not expanded unconstrained-path connectivity. These are bounded evidence gaps, not reasons to rerun broad vendor qualification.

## 4. Bounded final compile-result verification

**Supported execution result:** C/evidence/run/native-status.json:2–3 records native **rc0**, ending **2026-09-22T05:27:14.852099+00:00**. `status.json:20–24` independently records finished/rc0/no gate rejection. Invocation argv/cwd and authorization SHA match the issued record. C/manifest.json:320,346 records an empty captured process list at **05:30:12.353247Z**; this is snapshot evidence, not a present live-process assertion.

Final flow **Successful**, revision `ofs_top`, top `top`, device **AGFB027R25A2E2V**, final timing/power models, **Quartus 26.1.1 Build 130** are at C/project/output_files/ofs_top.flow.rpt:22–30. Assembly is Successful (asm.rpt:44–51), **0 errors/1 warning** (169); full native log reports **0 errors/978 warnings** (11290). Main STA remains **0 errors/260 warnings** (STA:209835), despite failed closure. The separate post-module STA reports 201 warnings (native.log:11014); these invocation counts must not be summed.

**MIF/source-context diagnostic:** native.log:11294 says Analysis & Synthesis is out of date because `fme_id.mif` changed. The same log records post-fit interface-ID update, loading the final database, processing this exact MIF and committing the updated database successfully **before assembly** (9212–9255, especially 9250,9254–9255). Preserve the freshness diagnostic and distinguish synthesis freshness from successful MIF update/assembly; it is not by itself evidence of failed compilation or grounds to repeat the unchanged full build. Warning 20536 at native.log:11164 ignores legacy `GENERATE_RBF_FILE`; it neither disproves the captured RBF metadata nor validates that RBF for runtime PR.

**Captured remote artifact metadata only** — C/manifest.json:10–39; sizes and timestamps also agree with its output listing. Binary contents were not fetched/rehashed locally in this review:

| Artifact | Bytes | Captured SHA256 |
|---|---:|---|
| `ofs_top.sof` | 7,837,547 | `5e4192340cabd6cbf915a857476480988452364b995768de4c5f2753b2293250` |
| `ofs_top.green_region.rbf` | 7,254,016 | `8f34a7285021387de61e1a540a596fd37d0aa827335901d216c5906c157517e1` |
| `ofs_top.green_region.pmsf` | 7,186,783 | `b69d57703c8b3dce597548d41990684c0936ed09a6013deab4708922ece334ce` |
| `ofs_top.static.msf` | 3,269,060 | `baf978a4b5b0b706c897915fddd60f5750134851761bc34b8898db1bb9486746` |

**Interface identity changed:** C/project/build_env_db.txt:11 and decoded fme_id.mif:12–13 agree on **`5c04f735-4245-5537-88d6-380f16bcc372`**; asm.rpt:146 records replacement of **`c281e23b-5a95-5aa9-8678-d2ecf1f80f6c`**. A persona expecting the old interface cannot be assumed compatible. A matching release/persona binding remains separate; do not relabel an old GBS or treat the raw green-region RBF as a validated runtime persona.

## Smallest justified next step

**Target the maintained PCIe divider clock binding, not another full build or report harvest.** Use the above exact hierarchy mismatch to prepare one narrowly scoped `syn/shared_config/top.sdc:35–37` correction proposal. Before applying it, establish the exact final divider input/output pin matches, incoming/master clock and fanout to the four invalid FIFO destination groups; reconcile the existing generated-SDC branch and dependent groups/multicycles so a repair does not silently activate unjustified exceptions. The existing report/source evidence justifies that target but not a guessed clock period or a guaranteed eight-warning cure. Any needed final-netlist query or subsequent bounded STA is a separately authorized action, not performed here.

Keep the named **EMIF1 bit243→phy_reg1 hold failure** separately open for a supported fitting/hold remedy or explicit justified disposition; no proven remedy is supplied by this capture. No speculative seed sweep, clock relaxation, false path, timing waiver, dummy-CSR test, DDR simulation or encrypted-IP requalification is recommended. Reuse these detailed reports; restrict remaining CDC/source work to the named active interfaces. Hardware data-check acceptance, new-interface deployment/persona binding and verified independent host recovery remain unresolved despite recorded flash/reboot permission.

# Lane 04 — EMIF/CPA configuration controls

**Outcome:** the instantiated IP exposes memory frequency/rate, reference-clock selection and additional PLL outputs, but this review establishes **no exposed CPA-phase or C2P pipeline control that preserves the complete present contract**. Several tempting settings are demonstrably derived or hidden. This is not a finding that physical closure is impossible: supported clock-distribution changes remain evaluable under unchanged STA/project gates without reconstructing the full CPA equation.

Research only; **GPT-6/openai-codex substituted for unavailable GLM5.3**. No SSH, native/vendor execution, tests, source changes or hardware access. Four targeted official searches and one primary fetch were used; the fetch supplied the complete F/I-Series guide, version **23.2**, not a 26.1.1 erratum. Newer M-Series/Agilex 5 access-mode documentation was not applied to this F-Series IP.

## 1. Actual identity, saved requests and evaluated state

The saved `mem_ss.ip` is `mem_ss` **5.0.1**, containing `emif_0` and `emif_1`, targeting **AGFB027R25A2E2V**, speed grade 2. Its SHA256 `58b2409deb345a56a34b557d735d532d9b61b93b4a58c9dce2c5ab26f02e45c4` matches the actual [Work22 regeneration inputs][inputs]. The instantiated leaf is **`altera_emif_fm` 2.8.0**, architecture **`altera_emif_arch_fm` 19.1**, not the different M-Series EMIF.[saved]; [metadata]

Both saved instances request `PHY_DDR4_MEM_CLK_FREQ_MHZ=1333.333`, `PHY_DDR4_RATE_ENUM=RATE_QUARTER`, `PHY_DDR4_DEFAULT_REF_CLK_FREQ=false`, `PHY_DDR4_USER_REF_CLK_FREQ_MHZ=33.333`, and `PHY_DDR4_REF_CLK_JITTER_PS=10.0`. They use PHY plus hard controller, x64 DDR4 and no extra PLL outputs.[saved]

**Provenance correction:** the retained generation-execution `.sopcinfo` is not byte-identical to Work22. I recovered the **actual Work22 EMIF1 SOPCINFO** from [metadata18-result.json.gz][metadata], verified its SHA256 against [inventory][inventory], and compared it: only the generation-date comment differs. All **2,344 leaf and 4,088 architecture parameter records**, including `derived/enabled/visible/valid`, match exactly. The retained deployment `.xml` also has a different hash and is not claimed as current fitted evidence. Four CPA/PLL/evaluated RTL files independently match Work22's inventory and the [Work23 source bindings][bindings].

Evaluated `USER_CLK_RATIO=4`, `C2P_P2C_CLK_RATIO=4`, `PHY_HMC_CLK_RATIO=2` and `PLL_MEM_CLK_FREQ_PS=750` give **3.000 ns core-user/low-rate PHY**, while HMC/high-rate PHY run at **1.500 ns**. Public documentation describes this automatic half-rate-controller/quarter-rate-user conversion.[1] The scalar AFU instead uses 156.25 MHz through PIM CDC; lowering that AFU clock does not directly repair this transfer.[scope]

## 2. Exposed controls: legal semantics, not guessed ranges

Actual leaf metadata marks the DDR4 frequency, user-rate, manual/recommended reference choice and jitter inputs **non-derived, visible, enabled and valid**. `PLL_ADD_EXTRA_CLKS=false` is likewise visible; its subordinate count/phase fields are hidden while disabled.[metadata]

- **Frequency/rate:** `PHY_DDR4_MEM_CLK_FREQ_MHZ` and `PHY_DDR4_RATE_ENUM` determine the transfer clocks. The guide permits half-rate or quarter-rate user arrangements subject to configuration, describing half-rate users as for “extremely slow interfaces only.” It requires memory latency and timing updates when frequency changes.[1] Installed `ip_arch_fm/pll.tcl:170–199` additionally filters frequency choices by protocol/rate FMIN/FMAX and PLL legality. **The exact selected-device legal interval and alternative-rate list are unresolved**, not an arbitrary continuous MHz range.[installed]
- **Reference choice:** the Boolean recommendation switch selects automatic versus manual selection; a manual value must come from the evaluated legal list. `pll.tcl:92–124,404–429` derives choices from PFD limits, integer M/N and the slowest-clock ratio; N is 1 and M must be divisible by that ratio. `PLL_BW_CTRL` is then derived from M (`379–399`), not an independent EMIF bandwidth selector. A new declared reference frequency requires the corresponding real board clock—not just a parameter edit.[1] ([installed])
- **Extra clocks:** documented `PLL_EXTRA_CLK_ACTUAL_PHASE_PS_GUI_5` through `_8` belong to additional outputs, **not CPA output0**. Installed generation quantizes these phases in VCO-period/8 steps; at the current 750 ps VCO period that is 93.75 ps, not a free 4 ps trim. These clocks are explicitly asynchronous to `emif_usr_clk`/`afi_clk`; repurposing one requires CDC and a changed integration contract.[1] ([installed])
- **Jitter:** the 10 ps input describes reference-source peak-to-peak jitter. Changing it does not physically improve the source or set CPA phase. The guide's 20 ps peak-to-peak source requirement does not authorize lowering the modeled value without evidence.[1]

## 3. Internal fields that must not become “user knobs”

Actual architecture metadata marks `USER_CLK_RATIO`, `C2P_P2C_CLK_RATIO`, `PHY_HMC_CLK_RATIO`, `PLL_PHY_CLK_VCO_PHASE`, `PLL_BW_CTRL`, `CPA_FB_MUX_1_SEL` and `REGISTER_AMM_C2P` **derived**. A derived architecture field can itself have `visible=true`; visibility alone is insufficient.[metadata]

Conversely, `DIAG_HMC_HRC=auto`, `DIAG_EXTRA_CONFIGS=""`, `DIAG_ADD_READY_PIPELINE=true` and `PHY_DDR4_CORE_CLKS_SHARING_ENUM=CORE_CLKS_SHARING_DISABLED` are non-derived but **hidden at the actual user leaf**. They are not documented exposed controls for this configuration. `ip_top/diag.tcl:241–258` explicitly hides the internal extra-config group.[metadata]; [installed]

Installed source establishes what these would affect, without authorizing them: `ddrx.tcl:105–148` makes HRC override select PHY/HMC ratio 2 or 4; `main.tcl:1233–1239` makes the ready-pipeline diagnostic affect **P2C** (`REGISTER_AMM_P2C=2` here), while C2P remains 1. `pll.tcl:202–274` routes forced VCO ratio/PHY phase through hidden diagnostics. No supported numeric override domain is established.[installed]

Current tile RTL fixes both CPA offsets to zero and disables external core phase controls. Output0 selects `fb1_p_clk` because rate conversion is enabled; `CPA_FB_MUX_1_SEL` controls **output1**. `DIAG_USE_CPA_LOCK` is reset/lock handling, not a phase adjustment. PLL feedback is `direct`; ordinary IOPLL compensation advice does not transfer automatically to this CPA-aligned EMIF.[rtl]; [review]

## 4. Candidate matrix

“Regenerate” means a later authorized supported IP/topology generation plus rebuild, **not permission to edit generated HDL**.

| Candidate / status | Physical target and documented limit | Contract / regeneration | Smallest discriminator |
|---|---|---|---|
| **Same-3ns reference delivery/sharing — conditional** | Reference network; DDR4 permits reference sharing but restricts ref pins to address/command lane2 indices0/1.[1] Not core-clock sharing or an adjustable CPA offset. | Rates could stay unchanged; bank/pin/interface preservation is unproved. Topology changes need re-elaboration; no existing EMIF phase knob. | Other clock lane verifies exact board wiring and supported routing control; reject if it changes the fixed clock/pin contract. |
| **Different manual/recommended reference — variant** | PLL M and derived bandwidth; legal discrete list, real source required.[1] ([installed]) | Could retain 3ns outputs, but changes board reference operating point; IP regeneration required. | Exact legal-list/schema plus available board source; scope decision first. |
| **Additional PLL phase outputs — not targeted** | Extra outputs only; quantized phases and mandatory CDC to EMIF core.[1] ([installed]) | Creation adds ports/resources; using one instead of CPA clock changes integration. Regenerate. | No direct CPA-output0 effect established; do not offer this as its phase trim. |
| **Jitter/turnaround changes — not a physical fix** | Jitter describes a source; turnaround parameters add idle controller cycles for board bus contention, not C2P clock delay.[1] | Could retain nominal 3ns; altered IP inputs need regeneration. | Actual source/board discrepancy, absent here; no hold-fix claim. |
| **HRC-off, core-clock sharing, CPA/PLL derived fields — unsupported user route** | Hidden or derived; HRC could change PHY ratio and selected feedback, but is not an exposed option here.[metadata]; [installed] | A 3ns user clock alone would not preserve internal PHY operation. Not eligible for an override. | Exact 26.1.1 public exposure/support evidence; request R04-1, not an experiment. |
| **Lower DDR, retain quarter-rate — changed point** | Changes memory/PHY clocks and automatically derived PLL settings.[1] ([installed]) | User period exceeds 3ns; bandwidth changes. Regenerate both banks and check latency/timing/integration. | Legal discrete operating point plus explicit scope decision; hold improvement is not guaranteed. |
| **Lower DDR plus half-rate user — changed interface** | Conditionally, about 666.667 MHz DDR clock could retain about 333.333 MHz user clock; legality unverified. | x64 Avalon data becomes **256 rather than 512 bits**; byte enables and word addressing change. Full subsystem regeneration/adaptation, scope decision.[installed] | Selected-device half-rate legality and complete port/clock/geometry comparison. |
| **Mimic HPS / PHY-only — different configuration** | Public configuration options are family-dependent; Mimic HPS imposes HPS tile restrictions.[1] | Not a free placement/CPA control; bank placement or controller interface changes. Regenerate. | Fixed-board eligibility and explicit architectural scope decision, not a default remedy. |

## 5. Decision and finite next evidence

Keep **unchanged-clock physical implementation candidates separate from lower-DDR/ratio variants**. Reducing frequency does not automatically improve a compensated hold relationship. In particular, choosing half-rate at the *current* DDR frequency would demand a 1.5 ns user clock, not a slower one; reducing DDR enough to retain 3ns still changes the interface width/addressing. The installed width rule is `2 × C2P_P2C_CLK_RATIO × DQ_WIDTH` (`ddr4.tcl:3033–3050`).[installed]

[R04-1](04-requests.json) asks the parent for one bounded installed-schema inspection, seeded by the exact component-definition path recorded in retained metadata, to resolve legal ranges and any **public** same-contract control missed by the available declaration subset. No native invocation is requested now. Existing source QSYS capability tags and accepted parameter serialization are not fitted settings.

Any later supported physical candidate must prove its actual implementation delta, retain unchanged signoff constraints and all-corner setup/hold/project acceptance, and retain the separately authorized two-bank hardware qualification. **A full CPA equation is not an added gate.** No new seed/effort/force-Hyper/eSRAM-delay-chain experiment is proposed.[scope]

## Sources and exact local anchors

[1] https://docs.altera.com/r/docs/683216/23.2/external-memory-interfaces-agilextm-7-f-series-and-i-series-fpga-ip-user-guide/agilextm-7-f-series-and-i-series-emif-ip-ddr4-parameters-general?contentId=nSlYeervRYvapvN_ffhu9Q — full F/I-Series v23.2 guide retrieved; relevant sections: 3.1.7–3.1.8, 3.4.1.1–3.4.2, 6.1.1, 6.1.6 and 6.4.3.4. Cached full text: `/home/joe/.hermes/cache/web/docs.altera.com-c421f27d7a.md` (general clocks lines16295–16340; rate conversion6414–6428; ref pins18658–18668). Version semantics are corroborated by installed26.1.1 source, not promoted to new-release defect guidance.

[metadata]: ../fim-build-22/metadata18-result.json.gz
[inputs]: ../fim-build-22/ip-regeneration-inputs11.json
[inventory]: ../fim-build-22/regeneration17-readback/qualification/fim-build-22/regeneration17/inventory.json
[bindings]: ../fim-build-23/reviews-consumed36.json
[saved]: ../msa-bank-spreading-integration-01/generation-execution-03/actual-results/work/mem_ss.ip
[installed]: ../emif-hold-objective-01/source03.json.gz
[review]: ../fim-build-23/clock-compensation-remedy-review32.md
[scope]: SCOPE01.md
[rtl]: ../msa-bank-spreading-integration-01/generation-execution-03/actual-results/work/mem_ss/mem_ss_mem_ss_501_qm5zaka/synth/ip/mem_ss_mem_ss_501_qm5zaka/mem_ss_mem_ss_501_qm5zaka_emif_1/altera_emif_arch_fm_191/synth/altera_emif_arch_fm_io_tiles.sv

**Archive member identities:** `[metadata]` member `ipss/mem/qip/mem_ss/mem_ss/mem_ss_mem_ss_501_qm5zaka/synth/ip/mem_ss_mem_ss_501_qm5zaka/mem_ss_mem_ss_501_qm5zaka_emif_1/mem_ss_mem_ss_501_qm5zaka_emif_1.sopcinfo`, SHA256 `04e99b9e3904874c584ab5496d3bbe10ca880f124360083587611b927bba63a0`. `[installed]` contains base64 ordinary-file captures under `/opt/altera/26.1.1/ip/altera/emif/`; member names used above are relative to that prefix. Its compressed archive SHA256 is `5bf86f3cef9684193883c0766dd3b5011968b91ad554cac0a7a0fb144efaa151`; all42 decoded member hashes matched their recorded hashes. RTL anchors: tile1618–1636; core-clock/reset170–171; PLL396; evaluated wrapper83–85,107,543,572,1701–1702. These are generation/architecture evidence, not a resolved fitted-attribute inventory.

# CPA numerical/reference-plane audit

**Outcome:** the existing reports already reject a single rigid CPA phase-shift interpretation. They show a wider **analysis-role-dependent COMP separation**, not merely an 84ps translation. This does not isolate a tool defect. A documented, contract-preserving physical experiment need not await reconstruction of the production CPA equation.

Reviewer: **GPT6 / openai-codex**, substituting for unavailable GLM5.3. Local files and in-memory, standard-library Python only; no native tools, source scripts/tests, SSH, implementation, hardware or Git mutations. Scope: [SCOPE01](SCOPE01.md). Numerical statements below are **reported/modelled timing**, not silicon measurements.

## 1. New discriminator obtained without a fit

I indexed every COMP row for the exact EMIF1 `tile_gen[1].tile_ctrl_inst|pa_core_clk_out[0]` in [W21 STA][s21] and [W23 STA][s23]: **1,100 / 1,099 appearances**, including report repeats—not independent experiments. Each corner/analysis-role group has one value. Hold-arrival equals setup-required; setup-arrival equals hold-required. All these rows have RR transitions at `TILECTRL_X172_Y0_N298`.

| Corner | Hold-arrival COMP Δps | Setup-arrival COMP Δps | Separation W21→W23, ps | First hold/setup COMP lines W21; W23 |
|---|---:|---:|---:|---|
| Slow vid2 100C | −96 | +53 | 264→413 | 5169/3916; 21089/19836 |
| Slow vid2b 100C | −83 | +58 | 238→379 | 35619/34366; 51539/50286 |
| Fast vid2a 0C | −56 | +40 | 165→261 | 66077/64824; 81969/80716 |
| Fast vid2a 100C | −72 | +36 | 187→295 | 96515/95262; 112405/111152 |
| Fast vid2 100C | **−84** | **+31** | **211→326** | 126944/125691; 142839/141586 |

Δ is W23−W21. At the failing corner the two COMP values are **−2.208/−1.997ns → −2.292/−1.966ns**. Reverse clock-path roles reproduce them ([s21]:128241,129531; [s23]:144136,145426). Thus neither “COMP is one physical phase setting” nor “all CPA uses shifted by −84ps” describes the reports. The role pattern is consistent with early/late treatment; its production selection rule remains unproved. **Do not average these values into an asserted nominal phase.** Changed implementation can affect bounds too; widening alone does not identify a version-only model change.

The exact hold reconciliation still stands: **−84ps COMP −2ps launch IC = −86ps slack**, with data 0.288ns and required 2.968ns unchanged ([paired anchors][a23]:44–46,100–104,162–175; [W21 anchor][a21]:44–46,100–104,163–176).

## 2. Reference planes and unmeasured quantities

Independent parsing reproduced all **16 explicit-edge feedback extrema** in [W21 feedback][r21] and [W23 feedback][r23]: core changes −1/−4ps rise min/max and −3/−5ps fall; PHY changes zero at printed precision. Core ordered rows change 58→57; all four PHY seven-row comparisons match, including fanout. Equality of the latter is not whole-clock-tree equality.

- **Core:** starts at logical `pa_core_clk_out[0]`, includes the downstream output CELL arc, ends at `pa_core_clk_in[0]`; it does not traverse the internal detector. The physical `__core_clk_out[1]` suffix does not change that logical identity.
- **PHY:** starts at PLL `lvds_clk[0]`, after its producing timing arc, and ends at `pa_fbclk_in[1]`. The COMP-bearing anchor instead reaches CPA via `pll_vco_in[0]`. Subtracting these raw totals silently conflates reference planes, divider/edge origins and possibly detector-internal delays.
- **Polarity:** RR/FF continuity is verified, but does not establish which divided-clock events the detector compares or their cycle correspondence. Query37's board-reference zero-path result crossed a keeper boundary: **not zero delay** ([help35]:73–80; [review52]:21–35).
- **Variation/calibration:** min/max propagation is neither a runtime calibration observation nor a measured jitter distribution. Shared-path correlation, nominal-delay selection and internal alignment residual are unmeasured. The anchor separately includes pessimism removal, advanced clock effects, uncertainty and hold micro-time ([a23]:209–212); do not fold these indiscriminately into feedback delay.
- **Quantization:** three printed decimals do not identify a hardware phase step. Zero requested offsets/disabled external control and the generated offset-code comment do not reveal automatic loop code, rounding, saturation or lock state ([tile RTL][tiles]:1618–1636,1715–1723). They also do not prove all effective fitted parameters.

## 3. What can actually be falsified?

For the explicitly restricted hypothesis `COMP = P − F + K`, using one fixed matching-edge/min-or-max selector and unchanged K, the reports predict changes **+1/+4/+3/+5ps**, not −84ps. Residuals are **85–89ps**. Even a conditional one-display-unit error per input gives only a 6ps six-term discrepancy bound. This rejects that raw-extrema substitution, **not negative-feedback physics**. No selector or constant was fitted to obtain agreement.

Conversely, merely allowing unknown values somewhere inside the raw rise intervals yields arithmetic P−F ranges **[−2.691,−2.123] / [−2.687,−2.122]ns**, containing the respective COMP values. These are not proven attainable detector bounds. Their overlap shows why unrestricted nominal/variation guesses cannot discriminate the mechanism.

## 4. Ranked, bounded next options

1. **No fit; complete here:** use the role/corner matrix above instead of requesting another raw-delay inventory. Acceptance: reconcile both COMP roles, not just the failing hold number. Any proposed fixed-offset explanation must explain the opposite-sign changes or be rejected.

2. **No fit; join the parallel lanes:** combine lane01's *effective* mux/divider/offset/filter/feedback-state evidence with lane02's exact route identities. Seek a documented definition of the role-dependent COMP treatment only if an identifiable local production artifact is available. Acceptance: distinguish a consumed-setting difference from source-only equality; bind evidence to the exact output, version and snapshot. Identical requested RTL does not eliminate hidden settings; identical effective settings would still leave topology versus model treatment confounded. Full numerical reconstruction is optional, not a prerequisite. No new native acquisition is requested: `report_delay_calculation` is absent and bounded CPA discovery is spent ([help35]:22–25; [help36]:22–25). Unbounded clock-network fanout is not a substitute ([help36]:145–167).

3. **Later, one authorized fit:** choose one documented physical lever established by lanes03/04, hold tool/version, seed3 and constraints fixed, and compare against retained Work23. Require actual consumption and the intended physical delta—not just a QSF entry. Prefer a targeted change to launch-versus-feedback routing or data arrival over an unspecified shorter shared tree. On the present rising early paths, output-to-launch delay is **3.726→3.724ns**, versus return **3.479→3.478ns**: their difference is **0.247→0.246ns** ([anchors][a23]; [r21]; [r23]). In an ideal locked loop, equal common-path changes can cancel at the launch; this is a conditional design warning, not the production equation. Record both COMP roles, feedback/launch/data terms and endpoint identity. No intended physical change means an ineffective/inapplicable experiment; a changed route with unchanged failure rejects that candidate, not every physical remedy.

**Acceptance remains unchanged:** OFS2026.1, Quartus26.1.1 Build130, AGFB027R25A2E2V, 3.000ns EMIF clocks, board contract, both DDR banks and PR/static boundaries. Require original all-corner STA/signoff gates and the existing later hardware qualification; a rounded zero or isolated bit243 improvement is not sufficient evidence. No blind seed, margin/latency waiver, unsupported phase override or deployment is authorized. A supported physical correction may succeed without settling why W21 differed.

[s21]: ../fim-build-21/final-capture01/ofs_top.sta.rpt
[s23]: ../fim-build-23/timing22-readback/output_files/ofs_top.sta.rpt
[a21]: ../fim-build-23/cpa-work21-46/result-readback/reports/anchor-hold.rpt
[a23]: ../fim-build-23/cpa-feedback41/result-readback/reports/anchor-hold.rpt
[r21]: ../fim-build-23/cpa-work21-46/result-readback/reports/
[r23]: ../fim-build-23/cpa-feedback41/result-readback/reports/
[review52]: ../fim-build-23/feedback-review52.md
[help35]: ../fim-build-23/cpa-help35/readback/help.log
[help36]: ../fim-build-23/cpa-help36/readback/help.log
[tiles]: ../msa-bank-spreading-integration-01/generation-execution-03/actual-results/work/mem_ss/mem_ss_mem_ss_501_qm5zaka/synth/ip/mem_ss_mem_ss_501_qm5zaka/mem_ss_mem_ss_501_qm5zaka_emif_1/altera_emif_arch_fm_191/synth/altera_emif_arch_fm_io_tiles.sv

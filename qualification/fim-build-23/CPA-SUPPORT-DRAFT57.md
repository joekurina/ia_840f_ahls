# Support request draft — Agilex 7 EMIF CPA compensation and hold timing

**Draft only. Not sent, uploaded or filed.** The attached reports contain design hierarchy and local build paths. No project archive, QDB, programming image, licensed tool, license file or credentials are included. Additional project data should be shared only after the owner approves the recipient and scope.

## Suggested subject

Agilex 7 AGFB027R25A2E2V: persistent EMIF core-to-PHY hold −0.004 ns under Quartus Pro26.1.1; CPA COMP differs from passing25.1

## Question for Altera/BittWare engineering

Please provide the supported, output-specific CPA compensation calculation or an applicable documented correction/patch for the case below. We are not requesting a hold waiver, artificial clock-latency adjustment, or an unsupported edit to generated EMIF RTL.

We need to understand how `TILECTRL_X172_Y0_N298`, logical output `pa_core_clk_out[0]`, receives COMP **−2.208 ns** in the passing25.1 implementation versus **−2.292 ns** in the failing26.1.1 implementation. The measured external feedback paths differ little, as shown below. Please identify:

1. The calculation's start/reference planes and phase-detector endpoints, including any segments not present in the attached raw path reports.
2. The relevant edge/divider relationship, nominal versus early/late delay treatment, calibration/model allowances, and effective internal CPA settings.
3. A numerical decomposition that reproduces both COMP values without fitted/ad hoc constants.
4. Whether there is an applicable known issue or patch for Quartus Pro26.1.1 Build130 and this Agilex 7 part/EMIF configuration.
5. If the values are expected, which **supported physical implementation control** can close this transfer while preserving the 3.000 ns requirements, clock/interface contract, both DDR banks and PR/static boundaries.

## Platform and comparison limits

- Board: BittWare IA-840F; device: **AGFB027R25A2E2V**.
- Current migration: **OFS `ofs-2026.1-1` / Quartus Prime Pro26.1.1 Build130**.
- Passing reference: Work21, OFS2025.1 baseline / **Quartus Prime Pro25.1.0 Build129**.
- Timing requirement: unchanged **3.000 ns**; the failing pair is EMIF1 core-user clock→PHY-l0 clock.
- Work22 seed2 and Work23 seed3 both fail the same transfer. The actual seed settings were checked in native Fitter reports.
- Both designs use the same physical launch, UFI and capture sites for this transfer. Tool version and implementation are not the sole isolated variable; **we do not claim a proven compiler defect**.
- Maximum router/placement effort, aggressive hold closure, All Paths hold optimization, a fit-only10ps objective and an exact launch-register retiming restriction were already present. Signoff skips the extra fit-only margin; every compared path explicitly states **No SDC Exception on Path**.
- The launch remains a Hyper-Register. We have not overridden vendor CPA phase fields or the force-Hyper-Register/delay-chain attributes.

## Exact failing transfer

Prefix:

```text
local_mem_wrapper|mem_ss_top|mem_ss_sv|mem_ss|mem_ss|emif_1|
```

Launch suffix:

```text
emif_1|arch|arch_inst|hmc.amm.amm.data_if_inst|amm_writedata_0_r[0][243]
```

Capture suffix:

```text
emif_1|arch|arch_inst|io_tiles_wrap_inst|io_tiles_inst|tile_gen[2].lane_gen[1].lane_inst|lane_inst~phy_reg1
```

Physical sites: `BLOCK_INPUT_MUX_PASSTHROUGH_X192_Y3_N0_I32` → `UFI_X210_Y0_N355` → `IO12LANE_X184_Y0_N374`.

At **Fast vid2 100C**, the passing/failing signoff difference is:

| Quantity | Work21 /25.1 | Work23 /26.1.1 |
|---|---:|---:|
| Hold slack | +0.082 ns | −0.004 ns |
| Data arrival | 3.050 ns | 2.964 ns |
| Data required | 2.968 ns | 2.968 ns |
| Data delay | 0.288 ns | 0.288 ns |
| CPA COMP increment | −2.208 ns | −2.292 ns |
| Launch-clock IC increment | 3.238 ns | 3.236 ns |

The −0.086 ns slack change reconciles as −0.084 ns COMP and −0.002 ns clock interconnect. This explains the reported signoff difference, not the production of COMP.

The current seed2→seed3 transfer slacks remain **+0.132 / +0.167 / +0.047 / +0.006 / −0.004 ns** across Slow vid2 100C, Slow vid2b 100C, Fast vid2a 0C, Fast vid2a 100C and Fast vid2 100C. Reported delay/location fields match after one bounded reference-clock duplicate alias pairing, but fanout changes; the complete implementations are not identical.

## Matched CPA feedback measurements

Native final-netlist observations were run on preserved copies with each build's original tool version, original SDC and Fast vid2 100C model. The anchor reports independently reproduced +0.082 and −0.004 ns. Explicit rising/falling raw max/min reports returned one path each.

- Core: EMIF1 primary tile1 `pa_core_clk_out[0]`→`pa_core_clk_in[0]`.
- PHY: actual upstream keeper `pll_inst|pll_inst|lvds_clk[0]`→primary tile1 `pa_fbclk_in[1]`.

| Path / edge | W21 minimum | W23 minimum | W21 maximum | W23 maximum |
|---|---:|---:|---:|---:|
| Core rise | 3.479 ns | 3.478 ns | 3.857 ns | 3.853 ns |
| Core fall | 3.458 ns | 3.455 ns | 3.834 ns | 3.829 ns |
| PHY rise | 1.166 ns | 1.166 ns | 1.356 ns | 1.356 ns |
| PHY fall | 1.166 ns | 1.166 ns | 1.355 ns | 1.355 ns |

Core routing/topology and fanout differ. All reported PHY route fields, including fanout, are identical. These are propagation extrema—not CPA compensation, slack, board-reference-to-detector delays, or an established CPA equation. We have not selected arbitrary min/max/mean combinations to fit the 84ps difference.

## Connectivity evidence and diagnostic limits

Hash-matched generated RTL places the changing COMP at CPA. EMIF PLL feedback is `direct`; the source explicitly assigns core/PHY alignment to CPA rather than ordinary PLL compensation. Requested phase offsets are zero, core phase controls are disabled, and output0 selects `fb1_p_clk`. The parameter named `CPA_FB_MUX_1_SEL` controls output1, not the failing output0. This is requested/generated configuration evidence, not proof of every effective internal setting.

Installed26.1.1 `report_delay_calculation` is absent. No imported CPA/compensation command was found in a bounded command-name discovery. Documented `report_path` provided the attached observations. A board-reference-to-PHY attempt returned no paths because of the keeper-boundary limitation; it was not treated as zero delay. No broad clock-network fanout scan, hardware probe, additional refit, or timing override was used.

## Attachments and provenance

The packet includes two anchor hold reports, eight raw feedback reports per build, the exact query scripts, a compact comparison, independent review, and a SHA256 manifest. Full native reports, projects and databases remain retained locally and can be supplied through an approved support channel if needed. Original Work21/Work23/PIM files were preserved; neither failed migrated image was programmed.

Please distinguish an applicable EMIF/CPA remedy from the historical eSRAM delay-chain workaround; no eSRAM guidance is assumed to apply here.

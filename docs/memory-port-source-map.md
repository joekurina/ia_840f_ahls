# IA840F memory port source map

**ready_for_build: false.** Source-only AHLS/OFS/OPAE preparation; oneAPI is reference-only. This map does not authorize configuration, generation, builds, tests or programming. Original vendor and sibling trees were read-only. Only this document and `reference/vendor-integration/memory-port-source-map.json` are owned outputs of this pass; no shared manifest/configuration was edited.

## Evidence and interpretation

Paths in the source registry are relative to `/home/joe/Projects/Thesis/AHLS/new_bsp`. Citations `[Snn:line-range]` resolve to that registry and its full-file SHA-256. The JSON carries exact per-bit old/new pin names, declaration widths, channel connections/exports, parameter values and line references, plus the complete untransplanted model inventory. Hashes are a source snapshot, not a generated-design or hardware attestation.

Static Python parsed text/XML/JSON and simple literal width expressions; no project Python module, HDL, Tcl, Qsys or vendor tool was executed. No remote access, builds/configure, IP generation, functional tests, installation, programming, commit or push occurred.

## Physical channels and controller association

| Physical source channel | Hardware kind | Legacy controller / adapter / application | Derived modern EMIF / MSA | Current pin-group proposal (not confirmed) | Configured capacity |
|---|---|---|---|---|---|
| 0 | discrete DDR4 (P1 component memory) | `intf_0` / `msa_0` / `i0_axi_mm` | `emif_0` / `msa_0` | `ddr4_mem[0]` | 16 GiB |
| 1 | DDR4 RDIMM | `intf_1` / `msa_1` / `i1_axi_mm` | `emif_1` / `msa_1` | `ddr4_mem_group_1[0]` | 16 GiB |

Channel 0 trace: [S40:1171-1184], [S38:223-241], [S36:15522], [S05:62-90]. Full Qsys exports and controller/calibration/reset connections are retained in JSON.

Channel 1 trace: [S40:1171-1184], [S38:243-261], [S36:15543], [S05:62-90]. Full Qsys exports and controller/calibration/reset connections are retained in JSON.

Capacity is the static geometry `2^(17+10+2+2) × 64/8 × 1 rank`, not installed-DIMM SPD evidence. Both active channels are x64 with no ECC, eight DQ per DQS, 17 address outputs, two BA and two BG. Comments saying x32/x72 in the old wrapper are stale relative to the actual package/interface/IP declarations. The physical source channel number is not a generated group ID.

**Critical finding:** modern wrapper grouping is structural, not discrete-versus-RDIMM classification. The generator compares exported signal names, directions, types and widths; matching interfaces with contiguous indices coalesce. Because the old physical declarations match, a single two-channel group is a credible outcome. Two simulation model presets and `DDR4_NUM_MEM_GROUPS=2` do not prove two generated physical groups. Do not rewrite pins to either outcome before generated interface evidence is authorized and available.

Grouping evidence: [S12:143-205], [S12:418-520], [S12:1103-1144], [S13:190-236], [S18:92-105].

## Exact declared top-level interfaces

Legacy declaration: `ofs_ddr_no_ecc_if.emif ddr4_mem [DDR_CHANNEL-1:0]`, with `DDR_CHANNEL=2`. [S40:34-35]; [S37:11-32].

| Legacy member on each `ddr4_mem[i]` | Exact packed range in declaration | Resolved bits | Direction at FPGA | Declaration |
|---|---|---:|---|---|
| `ck` | `[CK_WIDTH-1:0]` | 1 | output | [S39:31] |
| `ck_n` | `[CK_WIDTH-1:0]` | 1 | output | [S39:32] |
| `a` | `[ADDR_WIDTH-1:0]` | 17 | output | [S39:33] |
| `act_n` | `scalar` | 1 | output | [S39:34] |
| `ba` | `[BA_WIDTH-1:0]` | 2 | output | [S39:35] |
| `bg` | `[BG_WIDTH-1:0]` | 2 | output | [S39:36] |
| `cke` | `[CKE_WIDTH-1:0]` | 1 | output | [S39:37] |
| `cs_n` | `[CS_WIDTH-1:0]` | 1 | output | [S39:38] |
| `odt` | `[ODT_WIDTH-1:0]` | 1 | output | [S39:39] |
| `reset_n` | `scalar` | 1 | output | [S39:40] |
| `par` | `scalar` | 1 | output | [S39:41] |
| `alert_n` | `scalar` | 1 | input | [S39:42] |
| `dqs` | `[DQS_WIDTH-1:0]` | 8 | inout | [S39:43] |
| `dqs_n` | `[DQS_WIDTH-1:0]` | 8 | inout | [S39:44] |
| `dbi_n` | `[DQS_WIDTH-1:0]` | 8 | inout | [S39:45] |
| `dq` | `[DQ_WIDTH-1:0]` | 64 | inout | [S39:46] |
| `oct_rzqin` | `scalar` | 1 | input | [S39:48] |
| `ref_clk` | `scalar` | 1 | input | [S39:49] |

The legacy scalar `alert_n` is assigned as `.alert_n[0]` in vendor location text. Candidate text uses `.alert_n`. Width-one legacy `ck/ck_n/cke/cs_n/odt` declarations are packed `[0:0]`, while their pin targets omit `[0]`; all exact spellings are preserved in the appendix/JSON. Differential `ref_clk(n)` is a pin-constraint alias, not a second HDL signal.

| Candidate exact top-level name | Interface type | Declared array bound | Status |
|---|---|---|---|
| `ddr4_mem_ref_clk` | `ofs_fim_mem_ddr4_ref_clk_if.ip` | `[NUM_DDR4_CHANNELS-1:0]` | [S19:47]; physical count unresolved |
| `ddr4_mem` | `mem_ss_mem_ddr4_if.ip` | `[NUM_GROUP_0_DDR4_CHANNELS-1:0]` | [S19:48-50]; physical count unresolved |
| `ddr4_mem_group_1` | `mem_ss_mem_g1_ddr4_if.ip` | `[NUM_GROUP_1_DDR4_CHANNELS-1:0]` | [S19:51-53]; physical count unresolved |

The hand-written reference-clock interface declares only scalar `clk` and `oct_rzqin` for Agilex 7: [S17:22-38]. The DDR4 member names/widths are generated, not declared in the board top. The candidate pin file is **not** evidence that these generated member declarations exist. `NUM_DDR4_CHANNELS`, both group sizes and AXI widths come from generated wrapper macros, not model-count settings: [S14:31-97].

## Clock, reset and calibration source contract

mem_ss_top synchronizes reset into channel-0 reference clock; rst_hs uses that clock and app_ss_rst_req/app_ss_cold_rst_n plus ready/ack. Qsys reset_controller.generic_clk is intf_0.pll_ref_clk_out and generic_conduit_reset_n is intf_0.pll_locked. Each intf_i user clock/reset feeds msa_i; separate local_reset_req/status pairs exist for both controllers.

Board local_mem_wrapper receives clk_sys, ~rst_n_sys_mem (rst_n_sys[0]), clk_csr and rst_n_csr[0]. mem_ss_top maps refclk/OCT arrays by physical index, synchronizes reset using mem_pll_ref_clk[0] and drives generated ss_reset_if handshake. SIM_MODE_NO_MSS_RST bypass exists in source only, not asserted active here. Generated user clocks/resets are forwarded to each AFU interface; calibration status success/fail is resynchronized to CSR clock.

Both intf_0 and intf_1 use emif_cal_location_bottom_row.emif_calbus_clk. Bus index is reversed relative to channel: calbus_1 -> intf_0, calbus_0 -> intf_1. Candidate MEM_INTFS_LOCATION=BOT,BOT establishes placement intent only, not generated bus ordering.

References: [S38:57-99], [S36:15606-15617], [S36:15632-15673], [S36:15688], [S36:15723-15728], [S19:179-184], [S19:1230-1276], [S16:78-82], [S16:107-165], [S16:262-296].

| Reference/OCT assignment | Discrete physical 0 | RDIMM physical 1 |
|---|---|---|
| Reference positive | `HF23` | `HH48` |
| Explicit reference negative | `HH22` | **Not assigned in selected vendor source; unresolved** |
| OCT RZQ | `HB23` | `GW48` |

All reference/OCT exact target names and line citations are in the pin appendix. No devkit negative pin is substituted.

### Vendor-to-preset settings

The table lists exact vendor values. JSON records each field's matching modern value (or null if not transplanted), with independent vendor and preset citations. Frequency numbers are configuration requests, not measured clocks.

| Field | Physical 0 | Physical 1 | Vendor evidence |
|---|---|---|---|
| `MEM_DDR4_FORMAT_ENUM` | `MEM_FORMAT_DISCRETE` | `MEM_FORMAT_RDIMM` | [S31:5847-5848], [S32:5770-5771] |
| `MEM_DDR4_DQ_WIDTH` | `64` | `64` | [S31:5852-5853], [S32:5775-5776] |
| `MEM_DDR4_DQ_PER_DQS` | `8` | `8` | [S31:5857-5858], [S32:5780-5781] |
| `MEM_DDR4_RANKS_PER_DIMM` | `1` | `1` | [S31:5877-5878], [S32:5800-5801] |
| `MEM_DDR4_ROW_ADDR_WIDTH` | `17` | `17` | [S31:5892-5893], [S32:5815-5816] |
| `MEM_DDR4_COL_ADDR_WIDTH` | `10` | `10` | [S31:5897-5898], [S32:5820-5821] |
| `MEM_DDR4_BANK_ADDR_WIDTH` | `2` | `2` | [S31:5902-5903], [S32:5825-5826] |
| `MEM_DDR4_BANK_GROUP_WIDTH` | `2` | `2` | [S31:5907-5908], [S32:5830-5831] |
| `CTRL_DDR4_ECC_EN` | `false` | `false` | [S31:9182-9183], [S32:9105-9106] |
| `PHY_DDR4_MEM_CLK_FREQ_MHZ` | `1333.333` | `1333.333` | [S31:4257-4258], [S32:4180-4181] |
| `PHY_DDR4_USER_REF_CLK_FREQ_MHZ` | `33.333` | `33.333` | [S31:4267-4268], [S32:4190-4191] |
| `PHY_DDR4_DEFAULT_REF_CLK_FREQ` | `false` | `false` | [S31:4262-4263], [S32:4185-4186] |
| `PHY_DDR4_RATE_ENUM` | `RATE_QUARTER` | `RATE_QUARTER` | [S31:4277-4278], [S32:4200-4201] |
| `PHY_DDR4_CORE_CLKS_SHARING_ENUM` | `CORE_CLKS_SHARING_DISABLED` | `CORE_CLKS_SHARING_DISABLED` | [S31:4282-4283], [S32:4205-4206] |
| `PHY_DDR4_REF_CLK_JITTER_PS` | `10.0` | `10.0` | [S31:4272-4273], [S32:4195-4196] |
| `PHY_DDR4_USER_PLL_REF_CLK_IO_STD_ENUM` | `unset` | `unset` | [S31:4397-4398], [S32:4320-4321] |
| `MEM_DDR4_TCL` | `23` | `23` | [S31:5972-5973], [S32:5895-5896] |
| `MEM_DDR4_WTCL` | `14` | `14` | [S31:6007-6008], [S32:5930-5931] |
| `MEM_DDR4_TRCD_NS` | `15.0` | `15.0` | [S31:6497-6498], [S32:6420-6421] |
| `MEM_DDR4_TRP_NS` | `15.0` | `15.0` | [S31:6502-6503], [S32:6425-6426] |
| `MEM_DDR4_TRFC_NS` | `550.0` | `550.0` | [S31:6512-6513], [S32:6435-6436] |
| `MEM_DDR4_DM_EN` | `true` | `true` | [S31:5912-5913], [S32:5835-5836] |
| `MEM_DDR4_ALERT_PAR_EN` | `true` | `true` | [S31:5917-5918], [S32:5840-5841] |
| `MEM_DDR4_AC_PARITY_LATENCY` | `DDR4_AC_PARITY_LATENCY_DISABLE` | `DDR4_AC_PARITY_LATENCY_DISABLE` | [S31:6087-6088], [S32:6010-6011] |
| `DIAG_EXPORT_PLL_REF_CLK_OUT` | `true` | `false` | [S31:9767-9768], [S32:9690-9691] |
| `DIAG_DDR4_SIM_CAL_MODE_ENUM` | `SIM_CAL_MODE_SKIP` | `SIM_CAL_MODE_SKIP` | [S31:9952-9953], [S32:9875-9876] |
| `DIAG_DDR4_CAL_FULL_CAL_ON_RESET` | `true` | `true` | [S31:10112-10113], [S32:10035-10036] |
| `DIAG_DDR4_SKIP_VREF_CAL` | `false` | `false` | [S31:10087-10088], [S32:10010-10011] |
| `CAL_DEBUG_CLOCK_FREQUENCY` | `50000000` | `50000000` | [S31:3637-3638], [S32:3560-3561] |

`SIM_CAL_MODE_SKIP` is a simulation setting, not evidence of calibrated hardware. Legacy bottom calibration IP has `NUM_CALBUS_INTERFACE=2`; this derived cardinality is not explicitly transplanted into the modern preset. Bottom calibration diagnostic fields and reset-controller parameters are inventoried in JSON. [S30:462-463].

## Source selection and modern reference conventions

- Vendor memory source list selects handwritten `mem_ss_fm_0.qsys` plus both `intf`/`msa` IPs, not the commented monolithic IP: [S28:24-45].
- Board OFSS now actually selects `ia840f_discrete_rdimm_source`, output `mem_ss`, and `memory_groups=2`: [S21:6-12]. Older docs calling that memory preset nonexistent are superseded.
- QSF explicitly sets `DDR4_NUM_MEM_GROUPS=2` and `INCLUDE_DDR4`: [S26:96-99]. Modern memory Tcl uses the macro for extra simulation-model inclusion; configured `mem_ss.ip` is registered for IP-database extraction: [S09:30-65].
- Model naming is base preset / `_group1` with output `ed_sim_mem` / `ed_sim_mem_group1`, not an independent proof of physical grouping: [S18:92-105].
- `agilex7f-ed-gsrd` is board-specific GHRD/EMIF reference material, not IA840F authority: [S01:8-11] and [S02:8-36]. No devkit geometry/pins were copied.
- The `iseries-dk-8g-rdimm` and `iseries-dk-no_dimm` presets supplied schema/connection-vector conventions only; IA840F leaf values and BOT/BOT placement came from vendor sources: [S05:62-115].

## Unresolved generated contracts and model fields

### physical_grouping — unresolved

Discrete/RDIMM format or memory_groups=2 does not define generated physical groups. Generator compares complete exported SV interface structures and contiguous indices. Both legacy physical interfaces have identical 18-member declarations. If modern DDR4 exported shapes match, expect one two-element mem_ddr4 group, not two singleton groups; this is conditional, not generated evidence.

Evidence: [S12:143-205], [S12:418-520], [S12:1103-1144], [S13:190-236], [S18:92-105].

### generated_members_and_widths — unresolved

No IA840F mem_ss.ip or board-local ofs_ip_cfg_db was found at the listed expected paths. mem_ss_mem_ddr4_if, optional mem_ss_mem_g1_ddr4_if, vector counts and AXI widths require authorized generation later. Current pin spellings are proposals, not exact generated declarations. Width-one generated members normally become scalars; alert_n[0] in the old pin file disagrees lexically with the old scalar declaration. Clock (n) targets are differential constraint aliases, not declared HDL members.

Evidence: [S19:45-54], [S14:85-97], [S12:760-791], [S39:31-55].

### rdimm_negative_refclk — unresolved

Vendor and candidate explicitly assign only RDIMM reference positive HH48 and OCT GW48. No negative package coordinate was invented; tool/device pin-pair inference or an authoritative board source is needed.

Evidence: [S41:37-39], [S23:12-14].

### derived_model_fields — unresolved

Each model leaves 822 reference fields untransplanted, including irrelevant protocol/device metadata as well as critical DDR4 flattened widths, mode-register words, read/write latency, RCD/RDIMM configuration and ODT tables. Reference-only values in this map are explicitly not IA840F values. Legacy simulation TCL=19 conflicts with actual EMIF TCL=23.

Evidence: [S05:116-142], [S29:4224-4225].

### controller_semantics — unresolved

Modern AUTO_PRECHARGE=SS_CONTROLLED retained instead of casting legacy true; AXI ID/scheduling/latency/CSR semantics and unmapped DDR4 controls remain unqualified. Legacy active CSR topology is not reproduced by modern ENABLE_MEM_CSR_INTF=DISABLED and MSA CSR_EN=false defaults. No unreviewed CSR-enabling patch is proposed.

Evidence: [S05:92-109], [S38:200-221], [S13:116-125].

### serialized_lists — qualification_required

Checked-in modern QPRS presets and IA840F use comma-separated lists. mem_ss_get_cfg.tcl consumes get_instance_parameter_value using whitespace split. Whether the Qsys parameter API normalizes list serialization is not established by static text; do not change commas to spaces on this evidence alone.

Evidence: [S07:5], [S13:104-114].

### device_and_calibration — qualification_required

AGFB027R25A2E2V is the selected board device. Automatic legacy device metadata is excluded from derivation; consumed traits, calibration-bus generated indices, electrical derivations and target-IP acceptance must be recomputed/qualified. Bottom-row placement is source-proven; the old calbus_0-to-intf_1 and calbus_1-to-intf_0 wiring is not a modern group order. Simulation skip-calibration is not hardware calibration evidence.

Evidence: [S26:10-11], [S36:15632-15645], [S05:58-72].

### modern_device_dispatch — qualification_required

Modern mem_design_files.tcl selects mem_ss only if get_base_device_of(get_part_info(DEVICE)) matches *FM*. No vendor/device helper was executed, so this dispatch for AGFB027R25A2E2V and toolchain acceptance remain unqualified.

Evidence: [S09:9-27], [S09:43-65].

### Model inventory is not a proposed configuration

Each model has 1,519 explicit source parameters. Each additionally has 822 untransplanted reference fields, fully enumerated in JSON with their reference-only values and null IA840F derived values. That inventory mixes active DDR4 derivations with inactive protocols, device traits and generic fields; it is not a claim that all 822 require active DDR4 settings.

In particular, do not copy `MEM_DDR4_MR0`–`MR6`, `MEM_READ_LATENCY`, `MEM_WRITE_LATENCY`, `MEM_DDR4_RCD_COMMAND_LATENCY`, `MEM_DDR4_RDIMM_CONFIG`, `MEM_DDR4_*_CYC`, `MEM_DDR4_TTL_*`, DQS widths or ODT tables from the reference. Example: the RDIMM reference's derived DQS width is 16, while IA840F's configured x64 / eight-DQ-per-DQS implies eight strobes. The reference value is deliberately untransplanted. Vendor simulation CL19 also cannot replace the actual EMIF CL23.

Model example evidence: [S11:12187]; [S29:4224-4225]; [S31:5972-5973]; [S32:5895-5896].

### Correction disposition

**No unconditional configuration patch is proven by this source-only pass; none is proposed or applied.** Group collapse is conditional on the future exported modern interface. Missing RDIMM negative refclk evidence is not permission to invent a pin. Changing CSR policy, comma-list serialization, or legacy controller enums without their modern semantic contract is not a narrowly proven correction. Preserve the build gate and hand these questions to a separately authorized generation/qualification pass.

## Static consistency audit

- 2 physical channels; 18 declared members and 120 logical bits per channel.
- Discrete: 121 location statements (120 logical bits plus one explicit negative refclk alias). RDIMM: 120 location statements.
- 241 candidate memory assignments match the vendor-selected memory package-coordinate set exactly; every target rename matches the current proposed mapping. All logical declared bits have one location.
- Non-memory assignments were counted only, not researched: 77; combined 318 statements, 318 unique package pins and 318 unique targets. Commented assignments, inactive HPS and old alternate channel maps are excluded.
- 2930 memory parameters; 1,519 per model. All 1,424 exact EMIF copies per channel match original vendor values. Memory/model output hashes match the derivation report.
- No IA840F-generated `mem_ss.ip` or board-local `ofs_ip_cfg_db` was found at the expected paths listed in JSON. This is a bounded path check, not a claim that no generated files exist anywhere in the workspace.
- These are static source audits, **not tests**, IP acceptance, timing, electrical sign-off, calibration results or fitted hardware evidence.

## Exact memory package-pin map

Every row is an active location assignment. Vendor/candidate paths are identified by each citation; `(n)` denotes a constraint alias. Candidate names remain proposed until modern generation resolves interface grouping.

| Physical channel | Package pin | Exact vendor target | Exact candidate target | Vendor line | Candidate line |
|---:|---|---|---|---|---|
| 0 | `PIN_HF25` | `ddr4_mem[0].ck` | `ddr4_mem[0].ck` | [S41:188] | [S23:151] |
| 0 | `PIN_HH24` | `ddr4_mem[0].ck_n` | `ddr4_mem[0].ck_n` | [S41:187] | [S23:150] |
| 0 | `PIN_GW20` | `ddr4_mem[0].a[16]` | `ddr4_mem[0].a[16]` | [S41:167] | [S23:131] |
| 0 | `PIN_HB21` | `ddr4_mem[0].a[15]` | `ddr4_mem[0].a[15]` | [S41:168] | [S23:132] |
| 0 | `PIN_HH20` | `ddr4_mem[0].a[14]` | `ddr4_mem[0].a[14]` | [S41:169] | [S23:133] |
| 0 | `PIN_HF21` | `ddr4_mem[0].a[13]` | `ddr4_mem[0].a[13]` | [S41:170] | [S23:134] |
| 0 | `PIN_GW22` | `ddr4_mem[0].a[12]` | `ddr4_mem[0].a[12]` | [S41:171] | [S23:135] |
| 0 | `PIN_GJ24` | `ddr4_mem[0].a[11]` | `ddr4_mem[0].a[11]` | [S41:173] | [S23:137] |
| 0 | `PIN_GG25` | `ddr4_mem[0].a[10]` | `ddr4_mem[0].a[10]` | [S41:174] | [S23:138] |
| 0 | `PIN_GP24` | `ddr4_mem[0].a[9]` | `ddr4_mem[0].a[9]` | [S41:175] | [S23:139] |
| 0 | `PIN_GU25` | `ddr4_mem[0].a[8]` | `ddr4_mem[0].a[8]` | [S41:176] | [S23:140] |
| 0 | `PIN_GJ26` | `ddr4_mem[0].a[7]` | `ddr4_mem[0].a[7]` | [S41:177] | [S23:141] |
| 0 | `PIN_GG27` | `ddr4_mem[0].a[6]` | `ddr4_mem[0].a[6]` | [S41:178] | [S23:142] |
| 0 | `PIN_GP26` | `ddr4_mem[0].a[5]` | `ddr4_mem[0].a[5]` | [S41:179] | [S23:143] |
| 0 | `PIN_GU27` | `ddr4_mem[0].a[4]` | `ddr4_mem[0].a[4]` | [S41:180] | [S23:144] |
| 0 | `PIN_GJ28` | `ddr4_mem[0].a[3]` | `ddr4_mem[0].a[3]` | [S41:181] | [S23:145] |
| 0 | `PIN_GG29` | `ddr4_mem[0].a[2]` | `ddr4_mem[0].a[2]` | [S41:182] | [S23:146] |
| 0 | `PIN_GP28` | `ddr4_mem[0].a[1]` | `ddr4_mem[0].a[1]` | [S41:183] | [S23:147] |
| 0 | `PIN_GU29` | `ddr4_mem[0].a[0]` | `ddr4_mem[0].a[0]` | [S41:184] | [S23:148] |
| 0 | `PIN_GW28` | `ddr4_mem[0].act_n` | `ddr4_mem[0].act_n` | [S41:191] | [S23:154] |
| 0 | `PIN_HB19` | `ddr4_mem[0].ba[1]` | `ddr4_mem[0].ba[1]` | [S41:164] | [S23:128] |
| 0 | `PIN_HH18` | `ddr4_mem[0].ba[0]` | `ddr4_mem[0].ba[0]` | [S41:165] | [S23:129] |
| 0 | `PIN_GW18` | `ddr4_mem[0].bg[0]` | `ddr4_mem[0].bg[0]` | [S41:161] | [S23:126] |
| 0 | `PIN_HF29` | `ddr4_mem[0].bg[1]` | `ddr4_mem[0].bg[1]` | [S41:163] | [S23:127] |
| 0 | `PIN_HB27` | `ddr4_mem[0].cke` | `ddr4_mem[0].cke` | [S41:189] | [S23:152] |
| 0 | `PIN_HB29` | `ddr4_mem[0].cs_n[0]` | `ddr4_mem[0].cs_n[0]` | [S41:192] | [S23:155] |
| 0 | `PIN_HF27` | `ddr4_mem[0].odt` | `ddr4_mem[0].odt` | [S41:190] | [S23:153] |
| 0 | `PIN_HH28` | `ddr4_mem[0].reset_n` | `ddr4_mem[0].reset_n` | [S41:193] | [S23:156] |
| 0 | `PIN_GW24` | `ddr4_mem[0].par` | `ddr4_mem[0].par` | [S41:185] | [S23:149] |
| 0 | `PIN_HF19` | `ddr4_mem[0].alert_n` | `ddr4_mem[0].alert_n` | [S41:166] | [S23:130] |
| 0 | `PIN_FT21` | `ddr4_mem[0].dqs[0]` | `ddr4_mem[0].dqs[0]` | [S41:198] | [S23:159] |
| 0 | `PIN_GC21` | `ddr4_mem[0].dqs[1]` | `ddr4_mem[0].dqs[1]` | [S41:211] | [S23:170] |
| 0 | `PIN_FT27` | `ddr4_mem[0].dqs[2]` | `ddr4_mem[0].dqs[2]` | [S41:224] | [S23:181] |
| 0 | `PIN_GC27` | `ddr4_mem[0].dqs[3]` | `ddr4_mem[0].dqs[3]` | [S41:237] | [S23:192] |
| 0 | `PIN_FT33` | `ddr4_mem[0].dqs[4]` | `ddr4_mem[0].dqs[4]` | [S41:251] | [S23:203] |
| 0 | `PIN_GC33` | `ddr4_mem[0].dqs[5]` | `ddr4_mem[0].dqs[5]` | [S41:265] | [S23:214] |
| 0 | `PIN_FT39` | `ddr4_mem[0].dqs[6]` | `ddr4_mem[0].dqs[6]` | [S41:279] | [S23:225] |
| 0 | `PIN_GE38` | `ddr4_mem[0].dqs[7]` | `ddr4_mem[0].dqs[7]` | [S41:293] | [S23:236] |
| 0 | `PIN_FP20` | `ddr4_mem[0].dqs_n[0]` | `ddr4_mem[0].dqs_n[0]` | [S41:197] | [S23:158] |
| 0 | `PIN_GE20` | `ddr4_mem[0].dqs_n[1]` | `ddr4_mem[0].dqs_n[1]` | [S41:210] | [S23:169] |
| 0 | `PIN_FP26` | `ddr4_mem[0].dqs_n[2]` | `ddr4_mem[0].dqs_n[2]` | [S41:223] | [S23:180] |
| 0 | `PIN_GE26` | `ddr4_mem[0].dqs_n[3]` | `ddr4_mem[0].dqs_n[3]` | [S41:236] | [S23:191] |
| 0 | `PIN_FP32` | `ddr4_mem[0].dqs_n[4]` | `ddr4_mem[0].dqs_n[4]` | [S41:250] | [S23:202] |
| 0 | `PIN_GE32` | `ddr4_mem[0].dqs_n[5]` | `ddr4_mem[0].dqs_n[5]` | [S41:264] | [S23:213] |
| 0 | `PIN_FP38` | `ddr4_mem[0].dqs_n[6]` | `ddr4_mem[0].dqs_n[6]` | [S41:278] | [S23:224] |
| 0 | `PIN_GC39` | `ddr4_mem[0].dqs_n[7]` | `ddr4_mem[0].dqs_n[7]` | [S41:292] | [S23:235] |
| 0 | `PIN_FH21` | `ddr4_mem[0].dbi_n[0]` | `ddr4_mem[0].dbi_n[0]` | [S41:196] | [S23:157] |
| 0 | `PIN_FY21` | `ddr4_mem[0].dbi_n[1]` | `ddr4_mem[0].dbi_n[1]` | [S41:209] | [S23:168] |
| 0 | `PIN_FH27` | `ddr4_mem[0].dbi_n[2]` | `ddr4_mem[0].dbi_n[2]` | [S41:222] | [S23:179] |
| 0 | `PIN_FY27` | `ddr4_mem[0].dbi_n[3]` | `ddr4_mem[0].dbi_n[3]` | [S41:235] | [S23:190] |
| 0 | `PIN_FH33` | `ddr4_mem[0].dbi_n[4]` | `ddr4_mem[0].dbi_n[4]` | [S41:249] | [S23:201] |
| 0 | `PIN_FY33` | `ddr4_mem[0].dbi_n[5]` | `ddr4_mem[0].dbi_n[5]` | [S41:263] | [S23:212] |
| 0 | `PIN_FH39` | `ddr4_mem[0].dbi_n[6]` | `ddr4_mem[0].dbi_n[6]` | [S41:277] | [S23:223] |
| 0 | `PIN_FV38` | `ddr4_mem[0].dbi_n[7]` | `ddr4_mem[0].dbi_n[7]` | [S41:291] | [S23:234] |
| 0 | `PIN_FH19` | `ddr4_mem[0].dq[0]` | `ddr4_mem[0].dq[0]` | [S41:199] | [S23:160] |
| 0 | `PIN_FK22` | `ddr4_mem[0].dq[1]` | `ddr4_mem[0].dq[1]` | [S41:200] | [S23:161] |
| 0 | `PIN_FK18` | `ddr4_mem[0].dq[2]` | `ddr4_mem[0].dq[2]` | [S41:201] | [S23:162] |
| 0 | `PIN_FT19` | `ddr4_mem[0].dq[3]` | `ddr4_mem[0].dq[3]` | [S41:202] | [S23:163] |
| 0 | `PIN_FH23` | `ddr4_mem[0].dq[4]` | `ddr4_mem[0].dq[4]` | [S41:203] | [S23:164] |
| 0 | `PIN_FP22` | `ddr4_mem[0].dq[5]` | `ddr4_mem[0].dq[5]` | [S41:204] | [S23:165] |
| 0 | `PIN_FP18` | `ddr4_mem[0].dq[6]` | `ddr4_mem[0].dq[6]` | [S41:205] | [S23:166] |
| 0 | `PIN_FT23` | `ddr4_mem[0].dq[7]` | `ddr4_mem[0].dq[7]` | [S41:206] | [S23:167] |
| 0 | `PIN_GC19` | `ddr4_mem[0].dq[8]` | `ddr4_mem[0].dq[8]` | [S41:212] | [S23:171] |
| 0 | `PIN_FV22` | `ddr4_mem[0].dq[9]` | `ddr4_mem[0].dq[9]` | [S41:213] | [S23:172] |
| 0 | `PIN_GE18` | `ddr4_mem[0].dq[10]` | `ddr4_mem[0].dq[10]` | [S41:214] | [S23:173] |
| 0 | `PIN_GE22` | `ddr4_mem[0].dq[11]` | `ddr4_mem[0].dq[11]` | [S41:215] | [S23:174] |
| 0 | `PIN_FY19` | `ddr4_mem[0].dq[12]` | `ddr4_mem[0].dq[12]` | [S41:216] | [S23:175] |
| 0 | `PIN_FY23` | `ddr4_mem[0].dq[13]` | `ddr4_mem[0].dq[13]` | [S41:217] | [S23:176] |
| 0 | `PIN_FV18` | `ddr4_mem[0].dq[14]` | `ddr4_mem[0].dq[14]` | [S41:218] | [S23:177] |
| 0 | `PIN_GC23` | `ddr4_mem[0].dq[15]` | `ddr4_mem[0].dq[15]` | [S41:219] | [S23:178] |
| 0 | `PIN_FH25` | `ddr4_mem[0].dq[16]` | `ddr4_mem[0].dq[16]` | [S41:225] | [S23:182] |
| 0 | `PIN_FP28` | `ddr4_mem[0].dq[17]` | `ddr4_mem[0].dq[17]` | [S41:226] | [S23:183] |
| 0 | `PIN_FT25` | `ddr4_mem[0].dq[18]` | `ddr4_mem[0].dq[18]` | [S41:227] | [S23:184] |
| 0 | `PIN_FK28` | `ddr4_mem[0].dq[19]` | `ddr4_mem[0].dq[19]` | [S41:228] | [S23:185] |
| 0 | `PIN_FK24` | `ddr4_mem[0].dq[20]` | `ddr4_mem[0].dq[20]` | [S41:229] | [S23:186] |
| 0 | `PIN_FT29` | `ddr4_mem[0].dq[21]` | `ddr4_mem[0].dq[21]` | [S41:230] | [S23:187] |
| 0 | `PIN_FP24` | `ddr4_mem[0].dq[22]` | `ddr4_mem[0].dq[22]` | [S41:231] | [S23:188] |
| 0 | `PIN_FH29` | `ddr4_mem[0].dq[23]` | `ddr4_mem[0].dq[23]` | [S41:232] | [S23:189] |
| 0 | `PIN_FY25` | `ddr4_mem[0].dq[24]` | `ddr4_mem[0].dq[24]` | [S41:238] | [S23:193] |
| 0 | `PIN_GC29` | `ddr4_mem[0].dq[25]` | `ddr4_mem[0].dq[25]` | [S41:239] | [S23:194] |
| 0 | `PIN_GC25` | `ddr4_mem[0].dq[26]` | `ddr4_mem[0].dq[26]` | [S41:240] | [S23:195] |
| 0 | `PIN_FY29` | `ddr4_mem[0].dq[27]` | `ddr4_mem[0].dq[27]` | [S41:241] | [S23:196] |
| 0 | `PIN_FV24` | `ddr4_mem[0].dq[28]` | `ddr4_mem[0].dq[28]` | [S41:242] | [S23:197] |
| 0 | `PIN_FV28` | `ddr4_mem[0].dq[29]` | `ddr4_mem[0].dq[29]` | [S41:243] | [S23:198] |
| 0 | `PIN_GE24` | `ddr4_mem[0].dq[30]` | `ddr4_mem[0].dq[30]` | [S41:244] | [S23:199] |
| 0 | `PIN_GE28` | `ddr4_mem[0].dq[31]` | `ddr4_mem[0].dq[31]` | [S41:245] | [S23:200] |
| 0 | `PIN_FT31` | `ddr4_mem[0].dq[32]` | `ddr4_mem[0].dq[32]` | [S41:252] | [S23:204] |
| 0 | `PIN_FH35` | `ddr4_mem[0].dq[33]` | `ddr4_mem[0].dq[33]` | [S41:253] | [S23:205] |
| 0 | `PIN_FH31` | `ddr4_mem[0].dq[34]` | `ddr4_mem[0].dq[34]` | [S41:254] | [S23:206] |
| 0 | `PIN_FP34` | `ddr4_mem[0].dq[35]` | `ddr4_mem[0].dq[35]` | [S41:255] | [S23:207] |
| 0 | `PIN_FK30` | `ddr4_mem[0].dq[36]` | `ddr4_mem[0].dq[36]` | [S41:256] | [S23:208] |
| 0 | `PIN_FT35` | `ddr4_mem[0].dq[37]` | `ddr4_mem[0].dq[37]` | [S41:257] | [S23:209] |
| 0 | `PIN_FP30` | `ddr4_mem[0].dq[38]` | `ddr4_mem[0].dq[38]` | [S41:258] | [S23:210] |
| 0 | `PIN_FK34` | `ddr4_mem[0].dq[39]` | `ddr4_mem[0].dq[39]` | [S41:259] | [S23:211] |
| 0 | `PIN_FY31` | `ddr4_mem[0].dq[40]` | `ddr4_mem[0].dq[40]` | [S41:266] | [S23:215] |
| 0 | `PIN_FV34` | `ddr4_mem[0].dq[41]` | `ddr4_mem[0].dq[41]` | [S41:267] | [S23:216] |
| 0 | `PIN_GC31` | `ddr4_mem[0].dq[42]` | `ddr4_mem[0].dq[42]` | [S41:268] | [S23:217] |
| 0 | `PIN_GC35` | `ddr4_mem[0].dq[43]` | `ddr4_mem[0].dq[43]` | [S41:269] | [S23:218] |
| 0 | `PIN_FV30` | `ddr4_mem[0].dq[44]` | `ddr4_mem[0].dq[44]` | [S41:270] | [S23:219] |
| 0 | `PIN_FY35` | `ddr4_mem[0].dq[45]` | `ddr4_mem[0].dq[45]` | [S41:271] | [S23:220] |
| 0 | `PIN_GE30` | `ddr4_mem[0].dq[46]` | `ddr4_mem[0].dq[46]` | [S41:272] | [S23:221] |
| 0 | `PIN_GE34` | `ddr4_mem[0].dq[47]` | `ddr4_mem[0].dq[47]` | [S41:273] | [S23:222] |
| 0 | `PIN_FT41` | `ddr4_mem[0].dq[48]` | `ddr4_mem[0].dq[48]` | [S41:280] | [S23:226] |
| 0 | `PIN_FH37` | `ddr4_mem[0].dq[49]` | `ddr4_mem[0].dq[49]` | [S41:281] | [S23:227] |
| 0 | `PIN_FP40` | `ddr4_mem[0].dq[50]` | `ddr4_mem[0].dq[50]` | [S41:282] | [S23:228] |
| 0 | `PIN_FK40` | `ddr4_mem[0].dq[51]` | `ddr4_mem[0].dq[51]` | [S41:283] | [S23:229] |
| 0 | `PIN_FP36` | `ddr4_mem[0].dq[52]` | `ddr4_mem[0].dq[52]` | [S41:284] | [S23:230] |
| 0 | `PIN_FK36` | `ddr4_mem[0].dq[53]` | `ddr4_mem[0].dq[53]` | [S41:285] | [S23:231] |
| 0 | `PIN_FT37` | `ddr4_mem[0].dq[54]` | `ddr4_mem[0].dq[54]` | [S41:286] | [S23:232] |
| 0 | `PIN_FH41` | `ddr4_mem[0].dq[55]` | `ddr4_mem[0].dq[55]` | [S41:287] | [S23:233] |
| 0 | `PIN_GC37` | `ddr4_mem[0].dq[56]` | `ddr4_mem[0].dq[56]` | [S41:294] | [S23:237] |
| 0 | `PIN_FY41` | `ddr4_mem[0].dq[57]` | `ddr4_mem[0].dq[57]` | [S41:295] | [S23:238] |
| 0 | `PIN_FY37` | `ddr4_mem[0].dq[58]` | `ddr4_mem[0].dq[58]` | [S41:296] | [S23:239] |
| 0 | `PIN_GC41` | `ddr4_mem[0].dq[59]` | `ddr4_mem[0].dq[59]` | [S41:297] | [S23:240] |
| 0 | `PIN_FV36` | `ddr4_mem[0].dq[60]` | `ddr4_mem[0].dq[60]` | [S41:298] | [S23:241] |
| 0 | `PIN_FV40` | `ddr4_mem[0].dq[61]` | `ddr4_mem[0].dq[61]` | [S41:299] | [S23:242] |
| 0 | `PIN_GE36` | `ddr4_mem[0].dq[62]` | `ddr4_mem[0].dq[62]` | [S41:300] | [S23:243] |
| 0 | `PIN_GE40` | `ddr4_mem[0].dq[63]` | `ddr4_mem[0].dq[63]` | [S41:301] | [S23:244] |
| 0 | `PIN_HB23` | `ddr4_mem[0].oct_rzqin` | `ddr4_mem_ref_clk[0].oct_rzqin` | [S41:172] | [S23:136] |
| 0 | `PIN_HH22` | `ddr4_mem[0].ref_clk(n)` | `ddr4_mem_ref_clk[0].clk(n)` | [S41:159] | [S23:124] |
| 0 | `PIN_HF23` | `ddr4_mem[0].ref_clk` | `ddr4_mem_ref_clk[0].clk` | [S41:160] | [S23:125] |
| 1 | `PIN_HH46` | `ddr4_mem[1].ck` | `ddr4_mem_group_1[0].ck` | [S41:53] | [S23:28] |
| 1 | `PIN_HF47` | `ddr4_mem[1].ck_n` | `ddr4_mem_group_1[0].ck_n` | [S41:54] | [S23:29] |
| 1 | `PIN_GW50` | `ddr4_mem[1].a[15]` | `ddr4_mem_group_1[0].a[15]` | [S41:33] | [S23:8] |
| 1 | `PIN_HB51` | `ddr4_mem[1].a[16]` | `ddr4_mem_group_1[0].a[16]` | [S41:34] | [S23:9] |
| 1 | `PIN_HH50` | `ddr4_mem[1].a[13]` | `ddr4_mem_group_1[0].a[13]` | [S41:35] | [S23:10] |
| 1 | `PIN_HF51` | `ddr4_mem[1].a[14]` | `ddr4_mem_group_1[0].a[14]` | [S41:36] | [S23:11] |
| 1 | `PIN_HB49` | `ddr4_mem[1].a[12]` | `ddr4_mem_group_1[0].a[12]` | [S41:38] | [S23:13] |
| 1 | `PIN_GJ46` | `ddr4_mem[1].a[10]` | `ddr4_mem_group_1[0].a[10]` | [S41:40] | [S23:15] |
| 1 | `PIN_GG47` | `ddr4_mem[1].a[11]` | `ddr4_mem_group_1[0].a[11]` | [S41:41] | [S23:16] |
| 1 | `PIN_GP46` | `ddr4_mem[1].a[8]` | `ddr4_mem_group_1[0].a[8]` | [S41:42] | [S23:17] |
| 1 | `PIN_GU47` | `ddr4_mem[1].a[9]` | `ddr4_mem_group_1[0].a[9]` | [S41:43] | [S23:18] |
| 1 | `PIN_GJ44` | `ddr4_mem[1].a[6]` | `ddr4_mem_group_1[0].a[6]` | [S41:44] | [S23:19] |
| 1 | `PIN_GG45` | `ddr4_mem[1].a[7]` | `ddr4_mem_group_1[0].a[7]` | [S41:45] | [S23:20] |
| 1 | `PIN_GP44` | `ddr4_mem[1].a[4]` | `ddr4_mem_group_1[0].a[4]` | [S41:46] | [S23:21] |
| 1 | `PIN_GU45` | `ddr4_mem[1].a[5]` | `ddr4_mem_group_1[0].a[5]` | [S41:47] | [S23:22] |
| 1 | `PIN_GJ42` | `ddr4_mem[1].a[2]` | `ddr4_mem_group_1[0].a[2]` | [S41:48] | [S23:23] |
| 1 | `PIN_GG43` | `ddr4_mem[1].a[3]` | `ddr4_mem_group_1[0].a[3]` | [S41:49] | [S23:24] |
| 1 | `PIN_GP42` | `ddr4_mem[1].a[0]` | `ddr4_mem_group_1[0].a[0]` | [S41:50] | [S23:25] |
| 1 | `PIN_GU43` | `ddr4_mem[1].a[1]` | `ddr4_mem_group_1[0].a[1]` | [S41:51] | [S23:26] |
| 1 | `PIN_HB43` | `ddr4_mem[1].act_n` | `ddr4_mem_group_1[0].act_n` | [S41:58] | [S23:33] |
| 1 | `PIN_GW52` | `ddr4_mem[1].ba[1]` | `ddr4_mem_group_1[0].ba[1]` | [S41:29] | [S23:4] |
| 1 | `PIN_HF53` | `ddr4_mem[1].ba[0]` | `ddr4_mem_group_1[0].ba[0]` | [S41:32] | [S23:7] |
| 1 | `PIN_HB53` | `ddr4_mem[1].bg[0]` | `ddr4_mem_group_1[0].bg[0]` | [S41:30] | [S23:5] |
| 1 | `PIN_HH42` | `ddr4_mem[1].bg[1]` | `ddr4_mem_group_1[0].bg[1]` | [S41:59] | [S23:34] |
| 1 | `PIN_GW44` | `ddr4_mem[1].cke` | `ddr4_mem_group_1[0].cke` | [S41:55] | [S23:30] |
| 1 | `PIN_GW42` | `ddr4_mem[1].cs_n` | `ddr4_mem_group_1[0].cs_n` | [S41:57] | [S23:32] |
| 1 | `PIN_HH44` | `ddr4_mem[1].odt` | `ddr4_mem_group_1[0].odt` | [S41:56] | [S23:31] |
| 1 | `PIN_HF43` | `ddr4_mem[1].reset_n` | `ddr4_mem_group_1[0].reset_n` | [S41:60] | [S23:35] |
| 1 | `PIN_HB47` | `ddr4_mem[1].par` | `ddr4_mem_group_1[0].par` | [S41:52] | [S23:27] |
| 1 | `PIN_HH52` | `ddr4_mem[1].alert_n[0]` | `ddr4_mem_group_1[0].alert_n` | [S41:31] | [S23:6] |
| 1 | `PIN_FP50` | `ddr4_mem[1].dqs[7]` | `ddr4_mem_group_1[0].dqs[7]` | [S41:66] | [S23:41] |
| 1 | `PIN_GE50` | `ddr4_mem[1].dqs[6]` | `ddr4_mem_group_1[0].dqs[6]` | [S41:77] | [S23:52] |
| 1 | `PIN_FP44` | `ddr4_mem[1].dqs[5]` | `ddr4_mem_group_1[0].dqs[5]` | [S41:88] | [S23:63] |
| 1 | `PIN_GE44` | `ddr4_mem[1].dqs[4]` | `ddr4_mem_group_1[0].dqs[4]` | [S41:99] | [S23:74] |
| 1 | `PIN_GU33` | `ddr4_mem[1].dqs[0]` | `ddr4_mem_group_1[0].dqs[0]` | [S41:110] | [S23:85] |
| 1 | `PIN_HF33` | `ddr4_mem[1].dqs[1]` | `ddr4_mem_group_1[0].dqs[1]` | [S41:121] | [S23:96] |
| 1 | `PIN_GU39` | `ddr4_mem[1].dqs[2]` | `ddr4_mem_group_1[0].dqs[2]` | [S41:132] | [S23:107] |
| 1 | `PIN_HF39` | `ddr4_mem[1].dqs[3]` | `ddr4_mem_group_1[0].dqs[3]` | [S41:143] | [S23:118] |
| 1 | `PIN_FT51` | `ddr4_mem[1].dqs_n[7]` | `ddr4_mem_group_1[0].dqs_n[7]` | [S41:67] | [S23:42] |
| 1 | `PIN_GC51` | `ddr4_mem[1].dqs_n[6]` | `ddr4_mem_group_1[0].dqs_n[6]` | [S41:78] | [S23:53] |
| 1 | `PIN_FT45` | `ddr4_mem[1].dqs_n[5]` | `ddr4_mem_group_1[0].dqs_n[5]` | [S41:89] | [S23:64] |
| 1 | `PIN_GC45` | `ddr4_mem[1].dqs_n[4]` | `ddr4_mem_group_1[0].dqs_n[4]` | [S41:100] | [S23:75] |
| 1 | `PIN_GP32` | `ddr4_mem[1].dqs_n[0]` | `ddr4_mem_group_1[0].dqs_n[0]` | [S41:111] | [S23:86] |
| 1 | `PIN_HH32` | `ddr4_mem[1].dqs_n[1]` | `ddr4_mem_group_1[0].dqs_n[1]` | [S41:122] | [S23:97] |
| 1 | `PIN_GP38` | `ddr4_mem[1].dqs_n[2]` | `ddr4_mem_group_1[0].dqs_n[2]` | [S41:133] | [S23:108] |
| 1 | `PIN_HH38` | `ddr4_mem[1].dqs_n[3]` | `ddr4_mem_group_1[0].dqs_n[3]` | [S41:144] | [S23:119] |
| 1 | `PIN_FK50` | `ddr4_mem[1].dbi_n[7]` | `ddr4_mem_group_1[0].dbi_n[7]` | [S41:65] | [S23:40] |
| 1 | `PIN_FV50` | `ddr4_mem[1].dbi_n[6]` | `ddr4_mem_group_1[0].dbi_n[6]` | [S41:76] | [S23:51] |
| 1 | `PIN_FK44` | `ddr4_mem[1].dbi_n[5]` | `ddr4_mem_group_1[0].dbi_n[5]` | [S41:87] | [S23:62] |
| 1 | `PIN_FV44` | `ddr4_mem[1].dbi_n[4]` | `ddr4_mem_group_1[0].dbi_n[4]` | [S41:98] | [S23:73] |
| 1 | `PIN_GG33` | `ddr4_mem[1].dbi_n[0]` | `ddr4_mem_group_1[0].dbi_n[0]` | [S41:109] | [S23:84] |
| 1 | `PIN_HB33` | `ddr4_mem[1].dbi_n[1]` | `ddr4_mem_group_1[0].dbi_n[1]` | [S41:120] | [S23:95] |
| 1 | `PIN_GG39` | `ddr4_mem[1].dbi_n[2]` | `ddr4_mem_group_1[0].dbi_n[2]` | [S41:131] | [S23:106] |
| 1 | `PIN_HB39` | `ddr4_mem[1].dbi_n[3]` | `ddr4_mem_group_1[0].dbi_n[3]` | [S41:142] | [S23:117] |
| 1 | `PIN_FK52` | `ddr4_mem[1].dq[63]` | `ddr4_mem_group_1[0].dq[63]` | [S41:61] | [S23:36] |
| 1 | `PIN_FH53` | `ddr4_mem[1].dq[62]` | `ddr4_mem_group_1[0].dq[62]` | [S41:62] | [S23:37] |
| 1 | `PIN_FP52` | `ddr4_mem[1].dq[61]` | `ddr4_mem_group_1[0].dq[61]` | [S41:63] | [S23:38] |
| 1 | `PIN_FT53` | `ddr4_mem[1].dq[60]` | `ddr4_mem_group_1[0].dq[60]` | [S41:64] | [S23:39] |
| 1 | `PIN_FK48` | `ddr4_mem[1].dq[59]` | `ddr4_mem_group_1[0].dq[59]` | [S41:68] | [S23:43] |
| 1 | `PIN_FH49` | `ddr4_mem[1].dq[58]` | `ddr4_mem_group_1[0].dq[58]` | [S41:69] | [S23:44] |
| 1 | `PIN_FP48` | `ddr4_mem[1].dq[57]` | `ddr4_mem_group_1[0].dq[57]` | [S41:70] | [S23:45] |
| 1 | `PIN_FT49` | `ddr4_mem[1].dq[56]` | `ddr4_mem_group_1[0].dq[56]` | [S41:71] | [S23:46] |
| 1 | `PIN_FV52` | `ddr4_mem[1].dq[55]` | `ddr4_mem_group_1[0].dq[55]` | [S41:72] | [S23:47] |
| 1 | `PIN_FY53` | `ddr4_mem[1].dq[54]` | `ddr4_mem_group_1[0].dq[54]` | [S41:73] | [S23:48] |
| 1 | `PIN_GE52` | `ddr4_mem[1].dq[53]` | `ddr4_mem_group_1[0].dq[53]` | [S41:74] | [S23:49] |
| 1 | `PIN_GC53` | `ddr4_mem[1].dq[52]` | `ddr4_mem_group_1[0].dq[52]` | [S41:75] | [S23:50] |
| 1 | `PIN_FV48` | `ddr4_mem[1].dq[51]` | `ddr4_mem_group_1[0].dq[51]` | [S41:79] | [S23:54] |
| 1 | `PIN_FY49` | `ddr4_mem[1].dq[50]` | `ddr4_mem_group_1[0].dq[50]` | [S41:80] | [S23:55] |
| 1 | `PIN_GE48` | `ddr4_mem[1].dq[49]` | `ddr4_mem_group_1[0].dq[49]` | [S41:81] | [S23:56] |
| 1 | `PIN_GC49` | `ddr4_mem[1].dq[48]` | `ddr4_mem_group_1[0].dq[48]` | [S41:82] | [S23:57] |
| 1 | `PIN_FK46` | `ddr4_mem[1].dq[47]` | `ddr4_mem_group_1[0].dq[47]` | [S41:83] | [S23:58] |
| 1 | `PIN_FH47` | `ddr4_mem[1].dq[46]` | `ddr4_mem_group_1[0].dq[46]` | [S41:84] | [S23:59] |
| 1 | `PIN_FP46` | `ddr4_mem[1].dq[45]` | `ddr4_mem_group_1[0].dq[45]` | [S41:85] | [S23:60] |
| 1 | `PIN_FT47` | `ddr4_mem[1].dq[44]` | `ddr4_mem_group_1[0].dq[44]` | [S41:86] | [S23:61] |
| 1 | `PIN_FK42` | `ddr4_mem[1].dq[43]` | `ddr4_mem_group_1[0].dq[43]` | [S41:90] | [S23:65] |
| 1 | `PIN_FH43` | `ddr4_mem[1].dq[42]` | `ddr4_mem_group_1[0].dq[42]` | [S41:91] | [S23:66] |
| 1 | `PIN_FP42` | `ddr4_mem[1].dq[41]` | `ddr4_mem_group_1[0].dq[41]` | [S41:92] | [S23:67] |
| 1 | `PIN_FT43` | `ddr4_mem[1].dq[40]` | `ddr4_mem_group_1[0].dq[40]` | [S41:93] | [S23:68] |
| 1 | `PIN_FV46` | `ddr4_mem[1].dq[39]` | `ddr4_mem_group_1[0].dq[39]` | [S41:94] | [S23:69] |
| 1 | `PIN_FY47` | `ddr4_mem[1].dq[38]` | `ddr4_mem_group_1[0].dq[38]` | [S41:95] | [S23:70] |
| 1 | `PIN_GE46` | `ddr4_mem[1].dq[37]` | `ddr4_mem_group_1[0].dq[37]` | [S41:96] | [S23:71] |
| 1 | `PIN_GC47` | `ddr4_mem[1].dq[36]` | `ddr4_mem_group_1[0].dq[36]` | [S41:97] | [S23:72] |
| 1 | `PIN_FV42` | `ddr4_mem[1].dq[35]` | `ddr4_mem_group_1[0].dq[35]` | [S41:101] | [S23:76] |
| 1 | `PIN_FY43` | `ddr4_mem[1].dq[34]` | `ddr4_mem_group_1[0].dq[34]` | [S41:102] | [S23:77] |
| 1 | `PIN_GE42` | `ddr4_mem[1].dq[33]` | `ddr4_mem_group_1[0].dq[33]` | [S41:103] | [S23:78] |
| 1 | `PIN_GC43` | `ddr4_mem[1].dq[32]` | `ddr4_mem_group_1[0].dq[32]` | [S41:104] | [S23:79] |
| 1 | `PIN_GG31` | `ddr4_mem[1].dq[4]` | `ddr4_mem_group_1[0].dq[4]` | [S41:105] | [S23:80] |
| 1 | `PIN_GJ30` | `ddr4_mem[1].dq[5]` | `ddr4_mem_group_1[0].dq[5]` | [S41:106] | [S23:81] |
| 1 | `PIN_GU31` | `ddr4_mem[1].dq[6]` | `ddr4_mem_group_1[0].dq[6]` | [S41:107] | [S23:82] |
| 1 | `PIN_GP30` | `ddr4_mem[1].dq[7]` | `ddr4_mem_group_1[0].dq[7]` | [S41:108] | [S23:83] |
| 1 | `PIN_GG35` | `ddr4_mem[1].dq[0]` | `ddr4_mem_group_1[0].dq[0]` | [S41:112] | [S23:87] |
| 1 | `PIN_GJ34` | `ddr4_mem[1].dq[1]` | `ddr4_mem_group_1[0].dq[1]` | [S41:113] | [S23:88] |
| 1 | `PIN_GU35` | `ddr4_mem[1].dq[2]` | `ddr4_mem_group_1[0].dq[2]` | [S41:114] | [S23:89] |
| 1 | `PIN_GP34` | `ddr4_mem[1].dq[3]` | `ddr4_mem_group_1[0].dq[3]` | [S41:115] | [S23:90] |
| 1 | `PIN_HB31` | `ddr4_mem[1].dq[12]` | `ddr4_mem_group_1[0].dq[12]` | [S41:116] | [S23:91] |
| 1 | `PIN_GW30` | `ddr4_mem[1].dq[13]` | `ddr4_mem_group_1[0].dq[13]` | [S41:117] | [S23:92] |
| 1 | `PIN_HF31` | `ddr4_mem[1].dq[14]` | `ddr4_mem_group_1[0].dq[14]` | [S41:118] | [S23:93] |
| 1 | `PIN_HH30` | `ddr4_mem[1].dq[15]` | `ddr4_mem_group_1[0].dq[15]` | [S41:119] | [S23:94] |
| 1 | `PIN_HB35` | `ddr4_mem[1].dq[8]` | `ddr4_mem_group_1[0].dq[8]` | [S41:123] | [S23:98] |
| 1 | `PIN_GW34` | `ddr4_mem[1].dq[9]` | `ddr4_mem_group_1[0].dq[9]` | [S41:124] | [S23:99] |
| 1 | `PIN_HF35` | `ddr4_mem[1].dq[10]` | `ddr4_mem_group_1[0].dq[10]` | [S41:125] | [S23:100] |
| 1 | `PIN_HH34` | `ddr4_mem[1].dq[11]` | `ddr4_mem_group_1[0].dq[11]` | [S41:126] | [S23:101] |
| 1 | `PIN_GG37` | `ddr4_mem[1].dq[20]` | `ddr4_mem_group_1[0].dq[20]` | [S41:127] | [S23:102] |
| 1 | `PIN_GJ36` | `ddr4_mem[1].dq[21]` | `ddr4_mem_group_1[0].dq[21]` | [S41:128] | [S23:103] |
| 1 | `PIN_GU37` | `ddr4_mem[1].dq[22]` | `ddr4_mem_group_1[0].dq[22]` | [S41:129] | [S23:104] |
| 1 | `PIN_GP36` | `ddr4_mem[1].dq[23]` | `ddr4_mem_group_1[0].dq[23]` | [S41:130] | [S23:105] |
| 1 | `PIN_GG41` | `ddr4_mem[1].dq[16]` | `ddr4_mem_group_1[0].dq[16]` | [S41:134] | [S23:109] |
| 1 | `PIN_GJ40` | `ddr4_mem[1].dq[17]` | `ddr4_mem_group_1[0].dq[17]` | [S41:135] | [S23:110] |
| 1 | `PIN_GU41` | `ddr4_mem[1].dq[18]` | `ddr4_mem_group_1[0].dq[18]` | [S41:136] | [S23:111] |
| 1 | `PIN_GP40` | `ddr4_mem[1].dq[19]` | `ddr4_mem_group_1[0].dq[19]` | [S41:137] | [S23:112] |
| 1 | `PIN_HB37` | `ddr4_mem[1].dq[28]` | `ddr4_mem_group_1[0].dq[28]` | [S41:138] | [S23:113] |
| 1 | `PIN_GW36` | `ddr4_mem[1].dq[29]` | `ddr4_mem_group_1[0].dq[29]` | [S41:139] | [S23:114] |
| 1 | `PIN_HF37` | `ddr4_mem[1].dq[30]` | `ddr4_mem_group_1[0].dq[30]` | [S41:140] | [S23:115] |
| 1 | `PIN_HH36` | `ddr4_mem[1].dq[31]` | `ddr4_mem_group_1[0].dq[31]` | [S41:141] | [S23:116] |
| 1 | `PIN_HB41` | `ddr4_mem[1].dq[24]` | `ddr4_mem_group_1[0].dq[24]` | [S41:145] | [S23:120] |
| 1 | `PIN_GW40` | `ddr4_mem[1].dq[25]` | `ddr4_mem_group_1[0].dq[25]` | [S41:146] | [S23:121] |
| 1 | `PIN_HF41` | `ddr4_mem[1].dq[26]` | `ddr4_mem_group_1[0].dq[26]` | [S41:147] | [S23:122] |
| 1 | `PIN_HH40` | `ddr4_mem[1].dq[27]` | `ddr4_mem_group_1[0].dq[27]` | [S41:148] | [S23:123] |
| 1 | `PIN_GW48` | `ddr4_mem[1].oct_rzqin` | `ddr4_mem_ref_clk[1].oct_rzqin` | [S41:37] | [S23:12] |
| 1 | `PIN_HH48` | `ddr4_mem[1].ref_clk` | `ddr4_mem_ref_clk[1].clk` | [S41:39] | [S23:14] |

## Source snapshot registry

Full-file SHA-256; paths relative to the base specified above. No generated binaries are inputs.

| ID | Source path | Lines | SHA-256 |
|---|---|---:|---|
| S01 | `agilex7f-ed-gsrd/agilex_soc_devkit_ghrd/construct_agilex_emif.tcl` | 186 | `a5bc5fc29ca8f82fb24076234c85297057d0da008bc46f2a4a663dc3daff429f` |
| S02 | `agilex7f-ed-gsrd/agilex_soc_devkit_ghrd/pin_assign_agilex_emif.tcl` | 64 | `c3e97ee12ebd0095e60e17301cb65021fc16220096fcb593c62a1bef048f15f7` |
| S03 | `new/docs/fim-port.md` | 111 | `4927cf956af4ed8f66c1b9d04d18c83e84834d524e8806741e92649596acee2d` |
| S04 | `new/docs/vendor-derived-presets.md` | 190 | `9d78cdc5d75b08e9f73f7f70a8fff9b06e28ba646a402d9aa236f79a9582bf7a` |
| S05 | `new/ofs-agx7-pcie-attach/ipss/ia840f/derive_presets.py` | 249 | `a41dbb3a23bd2153f128c994f8ccf68eeae03676543b16b05e19da4bf06c88f5` |
| S06 | `new/ofs-agx7-pcie-attach/ipss/ia840f/preset_derivation.json` | 10320 | `e58e146ea0ec90e1a2528ddffdba2553339f4168dadda0b109574844c41d2d06` |
| S07 | `new/ofs-agx7-pcie-attach/ipss/ia840f/presets/ia840f_mem.qprs` | 2937 | `26cf53d439221fc7a9cd6ecaef55c232945df9ab38883499dfb63d1d78841c1e` |
| S08 | `new/ofs-agx7-pcie-attach/ipss/ia840f/presets/ia840f_sim.qprs` | 3047 | `8af9954c412405597fd073d1b2507dfac2e3475ef21871e1973f4ddbd666465e` |
| S09 | `new/ofs-agx7-pcie-attach/ipss/mem/mem_design_files.tcl` | 84 | `bb091aaefafb777f629b1c4823adc7db6209fdc1b2ec7011f6522182a598bac1` |
| S10 | `new/ofs-agx7-pcie-attach/ipss/mem/qip/presets/mem_presets.qprs` | 222628 | `f5721a1b79b627fdbe0c290dabeae65af985d18a19c20087591b7a4285c5475e` |
| S11 | `new/ofs-agx7-pcie-attach/ipss/mem/qip/presets/sim_presets.qprs` | 13329 | `2987a2ab51742652bf173b82e3fb220b9cea94d87e338c0eb1946bf3f02e0cff` |
| S12 | `new/ofs-agx7-pcie-attach/ofs-common/scripts/common/syn/ip_get_cfg/ip_gen_sv_wrapper.tcl` | 1323 | `3db40a80626db64e217a60bfd97022bfdc10187f0a2d559c6c99120a486da190` |
| S13 | `new/ofs-agx7-pcie-attach/ofs-common/scripts/common/syn/ip_get_cfg/mem_ss_get_cfg.tcl` | 326 | `918fb1d93dc73828de06d5d331fe65debdf586b8c9973fa00a7290837c2eabb1` |
| S14 | `new/ofs-agx7-pcie-attach/ofs-common/src/fpga_family/agilex/mem_ss/includes/ofs_fim_mem_if_pkg.sv` | 158 | `f816e463f345769260b476bea663ac63fcbd6f087a191facbd69be6db389fff1` |
| S15 | `new/ofs-agx7-pcie-attach/ofs-common/src/fpga_family/agilex/mem_ss/local_mem_wrapper.sv` | 86 | `ddffffd4b860b3e91c776b90ea5e317ce792ff2224b483dfb9384fdd7b4bb6cb` |
| S16 | `new/ofs-agx7-pcie-attach/ofs-common/src/fpga_family/agilex/mem_ss/mem_ss_top.sv` | 345 | `7211a02c56ba18d8bc58c749de56242c3e1eb3c94e8c92d84c42a742cf04618c` |
| S17 | `new/ofs-agx7-pcie-attach/ofs-common/src/fpga_family/agilex/mem_ss/ofs_fim_emif_ddr4_if.sv` | 45 | `6c878236ee9b6597811d5eead943c09d10b1d84837fd395a9a71ae1916acb708` |
| S18 | `new/ofs-agx7-pcie-attach/ofs-common/tools/ofss_config/memory_ip.py` | 129 | `ef4d1aeb2745693cf21fc67721a2a7b388b3d89ec600066fb30e77bb57a297d9` |
| S19 | `new/ofs-agx7-pcie-attach/src/board/ia840f/top.sv` | 1291 | `bb6ea012f3e2bbecafa6a238df7574bb145c02443b9612a99da8cd5c0e98d6fa` |
| S20 | `new/ofs-agx7-pcie-attach/syn/board/ia840f/config/ia840f.ofss` | 8 | `d47626b139e6826b3fb2d0f08ec7944ba8dc75d7713076cc88578e056bbd4b16` |
| S21 | `new/ofs-agx7-pcie-attach/syn/board/ia840f/config/ia840f_memory.ofss` | 12 | `052462c4c404a980111ac61e8eacb684e1561c3410477a3f4f31b020f6ca1798` |
| S22 | `new/ofs-agx7-pcie-attach/syn/board/ia840f/setup/build_gate.tcl` | 6 | `0440ac3808cd456b2e32925caacbf4a5bc00459d17135596db32b1c1fe4b0b34` |
| S23 | `new/ofs-agx7-pcie-attach/syn/board/ia840f/setup/emif_loc.tcl` | 244 | `44fdb76902f22b83df265da656f531fca9d5abe61a74c696190b5465c0da579d` |
| S24 | `new/ofs-agx7-pcie-attach/syn/board/ia840f/setup/top_loc.tcl` | 93 | `c8233935058d0ef43246fe0404c6eeeeb218c52a2e1ab688ff5ee33e7c68d53b` |
| S25 | `new/ofs-agx7-pcie-attach/syn/board/ia840f/syn_top/ofs_pr_afu.qsf` | 143 | `7895adcb83f6057bf26f1ec51a26433339aef9cf12440282732a4723283016f4` |
| S26 | `new/ofs-agx7-pcie-attach/syn/board/ia840f/syn_top/ofs_top.qsf` | 128 | `30149d42e1c4f17bd4f9222fb9b48a55c783ba6dd9169b3364eddc811dd568fb` |
| S27 | `new/ofs-agx7-pcie-attach/syn/board/ia840f/syn_top/ofs_top_sources.tcl` | 108 | `59b03764caf719c6716920bed2cd89da6dd04539d5f7ee15fda5cc5a1e8e4828` |
| S28 | `old_bsp/ia-840/IOFS_BUILD_ROOT/ofs-ia840f/ipss/mem/mem_design_files.tcl` | 45 | `ae9f0e8dccc70d52fdf3b5b5767c51e4f99c41ada5e36ce64dfc9ec4514ba36e` |
| S29 | `old_bsp/ia-840/IOFS_BUILD_ROOT/ofs-ia840f/ipss/mem/qip/ed_sim/ed_sim_mem.ip` | 12403 | `351ebc41519afec4fada77355db0d8d986d5e9e5c29cd89cb6b862cf100f30a6` |
| S30 | `old_bsp/ia-840/IOFS_BUILD_ROOT/ofs-ia840f/ipss/mem/qip/mem_ss/ip/mem_ss_fm_0/mem_ss_fm_0_emif_cal_location_bottom_row.ip` | 838 | `b4cc10cc9c9b8712438a5379ebea4f797afdbf84d55753459c1b36b273a1c42e` |
| S31 | `old_bsp/ia-840/IOFS_BUILD_ROOT/ofs-ia840f/ipss/mem/qip/mem_ss/ip/mem_ss_fm_0/mem_ss_fm_0_intf_0.ip` | 14419 | `fa915fa6ae8dad27275abc1e269189c9ece4ecc2aaf4bc8ef328ba3c359b4dde` |
| S32 | `old_bsp/ia-840/IOFS_BUILD_ROOT/ofs-ia840f/ipss/mem/qip/mem_ss/ip/mem_ss_fm_0/mem_ss_fm_0_intf_1.ip` | 14260 | `d6ee7d9c0220270a16231314a6c9e3182377a1001fd41e96e44d36b44117f743` |
| S33 | `old_bsp/ia-840/IOFS_BUILD_ROOT/ofs-ia840f/ipss/mem/qip/mem_ss/ip/mem_ss_fm_0/mem_ss_fm_0_msa_0.ip` | 3203 | `693e29897af8d3f9d8cfa91f0e30ab740762aa7fe7a916dff31d59dafe30d03f` |
| S34 | `old_bsp/ia-840/IOFS_BUILD_ROOT/ofs-ia840f/ipss/mem/qip/mem_ss/ip/mem_ss_fm_0/mem_ss_fm_0_msa_1.ip` | 3203 | `6f92ed9ce9ab66c5c5fab14cefc6d6835df764d1ba7b73eae02c737985177150` |
| S35 | `old_bsp/ia-840/IOFS_BUILD_ROOT/ofs-ia840f/ipss/mem/qip/mem_ss/ip/mem_ss_fm_0/mem_ss_fm_0_reset_controller.ip` | 826 | `3b5c8941955ca87105ed5409e483c81660834ff34f0f11287481c8e92f03c261` |
| S36 | `old_bsp/ia-840/IOFS_BUILD_ROOT/ofs-ia840f/ipss/mem/qip/mem_ss/mem_ss_fm_0.qsys` | 16092 | `49ac14b0a1b6e1dd2cf419f4fe9033261f29c8e3b8a29b23fc697632049c083f` |
| S37 | `old_bsp/ia-840/IOFS_BUILD_ROOT/ofs-ia840f/ipss/mem/rtl/mem_ss_pkg.sv` | 38 | `b0462deb14fa1d35b3f4d887a27edbc276102b1ced398a7904a1edbaf4a2d97d` |
| S38 | `old_bsp/ia-840/IOFS_BUILD_ROOT/ofs-ia840f/ipss/mem/rtl/mem_ss_top.sv` | 576 | `dedcf3db004977399334ea423a7acdcdc1e0fd6919146e6a28f45a15f7dd8c99` |
| S39 | `old_bsp/ia-840/IOFS_BUILD_ROOT/ofs-ia840f/ipss/mem/rtl/ofs_fim_emif_if.sv` | 98 | `1a81610b696acc81c02791cf9d0754b240e0898c005b5ddfa06d950a105c1657` |
| S40 | `old_bsp/ia-840/IOFS_BUILD_ROOT/ofs-ia840f/src/top/top.sv` | 1211 | `a01d9caaa644c5f60e029b7e3382237b080be8e0e9eb2e7b5dd7fe788692da50` |
| S41 | `old_bsp/ia-840/IOFS_BUILD_ROOT/ofs-ia840f/syn/setup/emif_loc.tcl` | 779 | `606feee0a053afa1cab1e397df963b516b0c8a416a55472e3f138e07a6171bae` |

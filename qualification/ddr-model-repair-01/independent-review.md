# Independent DDR4 model repair review

## Verdict

**PASS — static repaired-model acceptance for preparation of the approved short smoke.** No repaired-model mismatch was found in the local evidence. This is **not** an HDL compile, elaboration, simulation, or build PASS. `ready_for_build=false` remains mandatory.

The runnable smoke still needs its bounded harness and simulator/library integration. The complete paired controller SOPCINFO files and live Work04 tree are not present locally: controller-value agreement below is against captured `*.controller-parameters.json`, not a fresh parsing/hash of remote originals. This limits provenance assurance, not the demonstrated correctness of the local XML/RTL comparison. Do not describe this review as a live Work04 revalidation. Before execution, rebind the actual source files to the recorded hashes in the execution environment.

## Independent checks performed

Used fresh Python/XML parsing and SHA256 computation on the saved artifacts, not the implementer's verification script or acceptance booleans. No vendor tools, remote commands, HDL compilation or simulation were executed. Only this report was written.

- Parsed before and after model XML: 2345 unique parameters each, identical key sets, no additions/deletions. Independently recomputed **116** discrete and **118** RDIMM changes; all before/after maps and complete change dictionaries equal `*.full-parameter-diff.json`. Every changed final value equals its exact paired captured controller value. All parameters outside these changes are unchanged.
- Classified changed fields from the paired captured SOPCINFO derived flags: **108 + 8** and **110 + 8**. Eight non-derived changes are precisely six `SYS_INFO_DEVICE*` fields and `TRAIT_SUPPORTS_VID`, `TRAIT_IOBANK_REVISION`.
- Matched actual original model hashes to both Work04 manifests and the earlier smoke-inspection report. Compared `work04-before.json` and `work04-after.json`: identical 326-path maps. All **124** earlier `ddr-smoke-01/inspection/source-closure.json` controller HDL hashes agree with those manifests. This checks the recorded preservation chain; it does not freshly hash inaccessible remote Work04 files. SOPCINFO files are not covered by that 326-file inventory.
- Recomputed every repaired source-closure file hash and byte size: **18 entries / 11 distinct hashes**. Seven common vendor SV dependencies per model are byte-identical across the two models; each closure also contains its distinct parameterized leaf and top. Static extraction of generated `modelsim_files.tcl` lists exactly matches the ordered nine filenames per closure. `_bb.v` and `_inst.v` templates are excluded. Comparison to an installed vendor directory remains captured evidence, not an independently repeated local check.
- Parsed actual top and leaf RTL ports and locked interface widths: all agree, 16 DDR signals per model. A17, BA2, BG2, DQ64, DQS8, DQS_n8, DBI_n8; all other pins width 1. ALERT_n is model output, DQ/DQS/DQS_n/DBI_n inout, remaining pins model inputs.
- `.qgsimc` identifies class `altera_emif_mem_model_core_ddr4`, entity `altera_emif_ddrx_model`; actual leaf instantiates that entity, and the supplied SV declares it. Captured vendor component definition in `19-core-vendor.txt` explicitly assigns that TOP_LEVEL. A same-named class/module is not required.
- Independently read final-generation status files and logs: both returncode 0; logs identify 26.1.1 build 130 and three modules/nine files, with no error/warning/assertion text. `repair4.status.json` returncode 0 and clean `repair4.log`. These are retained generation results, not new executions.
- Checked all eleven `repair4.tcl` list setters per model against final XML: die revisions are three elements; each of ten ODT arrays is four elements. Joining the brace-preserved Tcl list elements with SOPCINFO's comma separator reproduces final XML exactly. Space-containing elements such as `(Drive) RZQ/7 (34 Ohm)` are not split into words. Final generated QGSIMC also contains the correct serialized values. Commas in saved XML are expected serialization, not evidence of the rejected comma-string setter mistake.

## Pairing and identity

| Model | Paired controller | Format | Final IP SHA256 |
|---|---|---|---|
| ed_sim_mem | Work04 emif_0 SOPCINFO | Discrete | e0eeb165be0adf7c695807eee02472b2bc292d6e9c43c7823fec06e0e376c594 |
| ed_sim_mem_group1 | Work04 emif_1 SOPCINFO | RDIMM | 5370d008d02ad2855acb470746e481bd1c0ce07b3cba5c7de0baed8e386657d7 |

Both retain row17/column10/BA2/BG2, x64, noECC, one rank, DDR4, fast simulation, skip calibration, abstract PHY disabled. Generated wrapper geometry independently computes **17179869184 bytes (16 GiB) per channel**. The different model formats and channel-specific captured latency/board values are retained, not cross-copied. BOT/BOT is recorded in `21-provenance.txt` for Work04 `mem_ss.ip` hash `883ff7f07d572a91e8fa67ccff2f971dd50823779eb33edeeae3fe6e960f5952`; it is not a field in the repaired model XML and was not freshly read from the remote file here.

The recorded paired controller SOPCINFO hashes are:
- emif_0: `2f0a95043be5708f94f43a22dbe4efc411d82af60b6e25eefca80e6a40df2a62`
- emif_1: `ddddee4e58ae7aa9008c7cccd645b1738229f4383c007df6b665b1df3f406bce`

## Behavior changes versus inherited metadata

This repair is not merely a family-label edit. It enables real memory composition and corrects actual DDR pin widths from stale A1/DQ72 to A17/DQ64. The family-only intermediate must remain rejected. Actual wrappers now pass `MEM_TRCD=20` and `MEM_TRTP=10` rather than inherited 14/9; supplied rank RTL uses these for tRCD/tRTP behavior/checks. Correct addressing/data geometry and the retained discrete-versus-RDIMM selection are materially relevant to simulation.

Other changed saved parameters include derived timing cycles, MR0–MR6 encodings, RDIMM config and RCD command latency, reference-clock derivation, board/OCT/Vref, controller reorder/auto-precharge and diagnostic metadata. These are **external-model inherited fields**, not changes to Work04 controller/PHY behavior, reference clocks, pin placement or calibration. Do not claim every saved derived field directly configures the behavioral core: the concrete leaf parameter interface is narrower. In particular, wrapper `MEM_INIT_MRS0..3` remain zero even though saved DDR4 MR encodings changed; saved MR updates are not proof of core mode-register initialization to those encodings. Many fields do not appear as leaf core parameters. RDIMM operation and mode-register command handling still require the bounded execution test.

Existing controller/model differences remain intentionally unforwarded: unique ID, eight ODT label serialization differences, `CTRL_DDR4_MMR_EN`, simulation verbosity and DDR4 user-mode/verbose settings. Recomputed complete changes show no newly introduced differences outside the approved refresh. They are not grounds to overwrite model-specific settings indiscriminately.

## Exact remaining smoke prerequisites / acceptance limits

1. Supply and review the actual finite `mem_ss` harness and execution script. The repaired models alone are not testbenches. Preserve separate channels, their user clocks/resets and physical pin pairings; one initial reset, no full calibration, long traffic or reset/error campaign.
2. Rebind actual remote controller/model files and SOPCINFO against the recorded hashes before use. For a stronger fully offline independent provenance review, export the two complete paired SOPCINFO files and Work04 `mem_ss.ip`; the current extracted maps alone cannot prove their source hashes.
3. Integrate the preserved controller closure, these repaired model closures, required device libraries and initialization files in fresh scratch; check compile/elaboration results. Use the actual harness top, not standalone model tops. No such simulator result is in this repair evidence.
4. A short smoke PASS must require bounded startup, finite channel-distinct write/read checks on both channels, correct AXI handshakes/responses/IDs/last/data and no accepted X/Z; calibration-fail, vendor model ERROR diagnostics, mismatch, fatal or timeout must fail the run. The vendor model contains `$display` ERROR checks, so exit code alone is insufficient. Preserve finite simulation/transaction/wall-time caps; do not silently extend into detailed calibration or extensive traffic.

No repaired-model blocker found for moving to this bounded harness/compile/run work within existing approval. No claim of functional DDR correctness or readiness promotion is made.

## Complete independently recomputed parameter delta

The table covers the union of changed names; `unchanged` marks a name changed only on the other channel. Empty strings are shown as `(empty)`. Full unchanged maps were checked as described above.

| Parameter | Discrete before → after | RDIMM before → after |
|---|---|---|
| `BOARD_DDR4_AC_ISI_NS` | `0.0` → `0.15` | `0.0` → `0.15` |
| `BOARD_DDR4_RCLK_ISI_NS` | `0.0` → `0.15` | `0.0` → `0.15` |
| `BOARD_DDR4_RDATA_ISI_NS` | `0.0` → `0.075` | `0.0` → `0.12` |
| `BOARD_DDR4_SKEW_WITHIN_AC_NS` | `0.0` → `0.18` | `0.0` → `0.18` |
| `BOARD_DDR4_SKEW_WITHIN_DQS_NS` | `0.0` → `0.02` | `0.0` → `0.02` |
| `BOARD_DDR4_WCLK_ISI_NS` | `0.0` → `0.038` | `0.0` → `0.06` |
| `BOARD_DDR4_WDATA_ISI_NS` | `0.0` → `0.09` | `0.0` → `0.13` |
| `CTRL_AUTO_PRECHARGE_EN` | `false` → `true` | `false` → `true` |
| `CTRL_REORDER_EN` | `false` → `true` | `false` → `true` |
| `DIAG_EFFICIENCY_MONITOR` | `(empty)` → `EFFMON_MODE_DISABLED` | `(empty)` → `EFFMON_MODE_DISABLED` |
| `DIAG_ENABLE_DEFAULT_MODE` | `false` → `true` | `false` → `true` |
| `DIAG_EXPORT_SEQ_AVALON_HEAD_OF_CHAIN` | `false` → `true` | `false` → `true` |
| `DIAG_EXPORT_SEQ_AVALON_SLAVE` | `(empty)` → `CAL_DEBUG_EXPORT_MODE_DISABLED` | `(empty)` → `CAL_DEBUG_EXPORT_MODE_DISABLED` |
| `DIAG_EXPORT_TG_CFG_AVALON_SLAVE` | `(empty)` → `TG_CFG_AMM_EXPORT_MODE_JTAG` | `(empty)` → `TG_CFG_AMM_EXPORT_MODE_JTAG` |
| `DIAG_SIM_CAL_MODE_ENUM` | `(empty)` → `SIM_CAL_MODE_SKIP` | `(empty)` → `SIM_CAL_MODE_SKIP` |
| `DIAG_TG2_TEST_DURATION` | `(empty)` → `SHORT` | `(empty)` → `SHORT` |
| `FAMILY_ENUM` | `FAMILY_INVALID` → `FAMILY_AGILEX` | `FAMILY_INVALID` → `FAMILY_AGILEX` |
| `MEM_BURST_LENGTH` | `-1` → `8` | `-1` → `8` |
| `MEM_DDR4_ADDR_WIDTH` | `1` → `17` | `1` → `17` |
| `MEM_DDR4_IDEAL_VREF_IN_PCT` | `60.0` → `68.0` | `60.0` → `68.0` |
| `MEM_DDR4_IDEAL_VREF_OUT_PCT` | `60.0` → `70.0` | `60.0` → `70.0` |
| `MEM_DDR4_INTEL_DEFAULT_RTT_NOM_ENUM` | `DDR4_RTT_NOM_RZQ_4` → `DDR4_RTT_NOM_ODT_DISABLED` | `DDR4_RTT_NOM_RZQ_4` → `DDR4_RTT_NOM_ODT_DISABLED` |
| `MEM_DDR4_INTEL_DEFAULT_RTT_NOM_ENUM_DISP` | `RZQ/4 (60 Ohm)` → `ODT Disabled` | `RZQ/4 (60 Ohm)` → `ODT Disabled` |
| `MEM_DDR4_INTEL_DEFAULT_RTT_PARK_ENUM` | `DDR4_RTT_PARK_ODT_DISABLED` → `DDR4_RTT_PARK_RZQ_4` | `DDR4_RTT_PARK_ODT_DISABLED` → `DDR4_RTT_PARK_RZQ_4` |
| `MEM_DDR4_INTEL_DEFAULT_RTT_PARK_ENUM_DISP` | `Park ODT off` → `RZQ/4 (60 Ohm)` | `Park ODT off` → `RZQ/4 (60 Ohm)` |
| `MEM_DDR4_MR0` | `0` → `2656` | `0` → `2656` |
| `MEM_DDR4_MR1` | `0` → `65537` | `0` → `65537` |
| `MEM_DDR4_MR2` | `0` → `131104` | `0` → `131104` |
| `MEM_DDR4_MR3` | `0` → `197632` | `0` → `197632` |
| `MEM_DDR4_MR4` | `0` → `264192` | `0` → `264192` |
| `MEM_DDR4_MR5` | `0` → `332896` | `0` → `332896` |
| `MEM_DDR4_MR6` | `0` → `395279` | `0` → `395279` |
| `MEM_DDR4_RCD_COMMAND_LATENCY` | unchanged | `1` → `2` |
| `MEM_DDR4_RDIMM_CONFIG` | unchanged | `(empty)` → `00000020000000004700001D40040B0F556000` |
| `MEM_DDR4_R_DERIVED_ODT0` | `,,` → `(Drive) RZQ/7 (34 Ohm),-,-,-` | `,,` → `(Drive) RZQ/7 (34 Ohm),-,-,-` |
| `MEM_DDR4_R_DERIVED_ODT1` | `,,` → `-,-,-,-` | `,,` → `-,-,-,-` |
| `MEM_DDR4_R_DERIVED_ODT2` | `,,` → `-,-,-,-` | `,,` → `-,-,-,-` |
| `MEM_DDR4_R_DERIVED_ODT3` | `,,` → `-,-,-,-` | `,,` → `-,-,-,-` |
| `MEM_DDR4_R_DERIVED_ODTN` | `,,` → `Rank 0,-,-,-` | `,,` → `Rank 0,-,-,-` |
| `MEM_DDR4_TFAW_CYC` | `27` → `28` | `27` → `28` |
| `MEM_DDR4_TINIT_CK` | `499` → `666667` | `499` → `666667` |
| `MEM_DDR4_TRAS_CYC` | `36` → `43` | `36` → `43` |
| `MEM_DDR4_TRCD_CYC` | `14` → `20` | `14` → `20` |
| `MEM_DDR4_TREFI_CYC` | `8320` → `10400` | `8320` → `10400` |
| `MEM_DDR4_TRFC_CYC` | `171` → `734` | `171` → `734` |
| `MEM_DDR4_TRFC_DLR_CYC` | `109` → `120` | `109` → `120` |
| `MEM_DDR4_TRP_CYC` | `14` → `20` | `14` → `20` |
| `MEM_DDR4_TRTP_CYC` | `9` → `10` | `9` → `10` |
| `MEM_DDR4_TTL_ADDR_WIDTH` | `1` → `17` | `1` → `17` |
| `MEM_DDR4_TTL_DQ_WIDTH` | `72` → `64` | `72` → `64` |
| `MEM_DDR4_TWR_CYC` | `18` → `20` | `18` → `20` |
| `MEM_DDR4_VREFDQ_TRAINING_RANGE` | `DDR4_VREFDQ_TRAINING_RANGE_1` → `DDR4_VREFDQ_TRAINING_RANGE_0` | `DDR4_VREFDQ_TRAINING_RANGE_1` → `DDR4_VREFDQ_TRAINING_RANGE_0` |
| `MEM_DDR4_VREFDQ_TRAINING_RANGE_DISP` | `Range 2 - 45% to 77.5%` → `Range 1 - 60% to 92.5%` | `Range 2 - 45% to 77.5%` → `Range 1 - 60% to 92.5%` |
| `MEM_DDR4_VREFDQ_TRAINING_VALUE` | `56.0` → `70.0` | `56.0` → `70.0` |
| `MEM_DDR4_WRITE_CMD_LATENCY` | `5` → `6` | `5` → `6` |
| `MEM_DDR4_W_DERIVED_ODT0` | `,,` → `(Park) RZQ/4 (60 Ohm),-,-,-` | `,,` → `(Park) RZQ/4 (60 Ohm),-,-,-` |
| `MEM_DDR4_W_DERIVED_ODT1` | `,,` → `-,-,-,-` | `,,` → `-,-,-,-` |
| `MEM_DDR4_W_DERIVED_ODT2` | `,,` → `-,-,-,-` | `,,` → `-,-,-,-` |
| `MEM_DDR4_W_DERIVED_ODT3` | `,,` → `-,-,-,-` | `,,` → `-,-,-,-` |
| `MEM_DDR4_W_DERIVED_ODTN` | `,,` → `Rank 0,-,-,-` | `,,` → `Rank 0,-,-,-` |
| `MEM_HAS_BSI_SUPPORT` | `false` → `true` | `false` → `true` |
| `MEM_READ_LATENCY` | `-1.0` → `23.0` | `-1.0` → `26.0` |
| `MEM_TTL_NUM_OF_READ_GROUPS` | `-1` → `8` | `-1` → `8` |
| `MEM_TTL_NUM_OF_WRITE_GROUPS` | `-1` → `8` | `-1` → `8` |
| `MEM_WRITE_LATENCY` | `-1` → `14` | `-1` → `17` |
| `PHY_AC_CALIBRATED_OCT` | `false` → `true` | `false` → `true` |
| `PHY_AC_DEEMPHASIS_ENUM` | `(empty)` → `DEEMPHASIS_MODE_OFF` | `(empty)` → `DEEMPHASIS_MODE_OFF` |
| `PHY_AC_IO_STD_ENUM` | `(empty)` → `IO_STD_SSTL_12` | `(empty)` → `IO_STD_SSTL_12` |
| `PHY_AC_MODE_ENUM` | `(empty)` → `OUT_OCT_40_CAL` | `(empty)` → `OUT_OCT_40_CAL` |
| `PHY_CALIBRATED_OCT` | `false` → `true` | `false` → `true` |
| `PHY_CK_CALIBRATED_OCT` | `false` → `true` | `false` → `true` |
| `PHY_CK_DEEMPHASIS_ENUM` | `(empty)` → `DEEMPHASIS_MODE_OFF` | `(empty)` → `DEEMPHASIS_MODE_OFF` |
| `PHY_CK_IO_STD_ENUM` | `(empty)` → `IO_STD_SSTL_12` | `(empty)` → `IO_STD_SSTL_12` |
| `PHY_CK_MODE_ENUM` | `(empty)` → `OUT_OCT_40_CAL` | `(empty)` → `OUT_OCT_40_CAL` |
| `PHY_CONFIG_ENUM` | `(empty)` → `CONFIG_PHY_AND_HARD_CTRL` | `(empty)` → `CONFIG_PHY_AND_HARD_CTRL` |
| `PHY_CORE_CLKS_SHARING_ENUM` | `(empty)` → `CORE_CLKS_SHARING_DISABLED` | `(empty)` → `CORE_CLKS_SHARING_DISABLED` |
| `PHY_DATA_CALIBRATED_OCT` | `false` → `true` | `false` → `true` |
| `PHY_DATA_IO_STD_ENUM` | `(empty)` → `IO_STD_POD_12` | `(empty)` → `IO_STD_POD_12` |
| `PHY_DATA_OUT_DEEMPHASIS_ENUM` | `(empty)` → `DEEMPHASIS_MODE_HIGH` | `(empty)` → `DEEMPHASIS_MODE_HIGH` |
| `PHY_DATA_OUT_MODE_ENUM` | `(empty)` → `OUT_OCT_40_CAL` | `(empty)` → `OUT_OCT_40_CAL` |
| `PHY_DDR4_AC_DEEMPHASIS_ENUM` | `unset` → `DEEMPHASIS_MODE_OFF` | `unset` → `DEEMPHASIS_MODE_OFF` |
| `PHY_DDR4_AC_IO_STD_ENUM` | `unset` → `IO_STD_SSTL_12` | `unset` → `IO_STD_SSTL_12` |
| `PHY_DDR4_AC_MODE_ENUM` | `unset` → `OUT_OCT_40_CAL` | `unset` → `OUT_OCT_40_CAL` |
| `PHY_DDR4_AC_SLEW_RATE_ENUM` | `unset` → `SLEW_RATE_FM_FAST` | `unset` → `SLEW_RATE_FM_FAST` |
| `PHY_DDR4_CK_DEEMPHASIS_ENUM` | `unset` → `DEEMPHASIS_MODE_OFF` | `unset` → `DEEMPHASIS_MODE_OFF` |
| `PHY_DDR4_CK_IO_STD_ENUM` | `unset` → `IO_STD_SSTL_12` | `unset` → `IO_STD_SSTL_12` |
| `PHY_DDR4_CK_MODE_ENUM` | `unset` → `OUT_OCT_40_CAL` | `unset` → `OUT_OCT_40_CAL` |
| `PHY_DDR4_CK_SLEW_RATE_ENUM` | `unset` → `SLEW_RATE_FM_FAST` | `unset` → `SLEW_RATE_FM_FAST` |
| `PHY_DDR4_DATA_IN_MODE_ENUM` | `unset` → `IN_OCT_60_CAL` | `unset` → `IN_OCT_60_CAL` |
| `PHY_DDR4_DATA_IO_STD_ENUM` | `unset` → `IO_STD_POD_12` | `unset` → `IO_STD_POD_12` |
| `PHY_DDR4_DATA_OUT_DEEMPHASIS_ENUM` | `unset` → `DEEMPHASIS_MODE_HIGH` | `unset` → `DEEMPHASIS_MODE_HIGH` |
| `PHY_DDR4_DATA_OUT_MODE_ENUM` | `unset` → `OUT_OCT_40_CAL` | `unset` → `OUT_OCT_40_CAL` |
| `PHY_DDR4_DATA_OUT_SLEW_RATE_ENUM` | `unset` → `SLEW_RATE_FM_FAST` | `unset` → `SLEW_RATE_FM_FAST` |
| `PHY_DDR4_PLL_REF_CLK_IO_STD_ENUM` | `unset` → `IO_STD_TRUE_DIFF_SIGNALING` | `unset` → `IO_STD_TRUE_DIFF_SIGNALING` |
| `PHY_DDR4_REF_CLK_FREQ_MHZ` | `-1.0` → `33.333` | `-1.0` → `33.333` |
| `PHY_DDR4_RZQ_IO_STD_ENUM` | `unset` → `IO_STD_CMOS_12` | `unset` → `IO_STD_CMOS_12` |
| `PHY_DDR4_STARTING_VREFIN` | `70.0` → `68.0` | `70.0` → `68.0` |
| `PHY_FPGA_SPEEDGRADE_GUI` | `(empty)` → `E2V (ES3) - change device under 'View'->'Device Family'` | `(empty)` → `E2V (ES3) - change device under 'View'->'Device Family'` |
| `PHY_REF_CLK_JITTER_PS` | `-1.0` → `10.0` | `-1.0` → `10.0` |
| `PHY_RZQ` | `0` → `240` | `0` → `240` |
| `PHY_TARGET_IS_ES3` | `false` → `true` | `false` → `true` |
| `PHY_TARGET_IS_PRODUCTION` | `true` → `false` | `true` → `false` |
| `PHY_TARGET_SPEEDGRADE` | `(empty)` → `E2V` | `(empty)` → `E2V` |
| `PHY_USER_PERIODIC_OCT_RECAL_ENUM` | `(empty)` → `PERIODIC_OCT_RECAL_AUTO` | `(empty)` → `PERIODIC_OCT_RECAL_AUTO` |
| `PLL_EXTRA_CLK_ACTUAL_FREQ_MHZ_5` | `0.0` → `1333.333` | `0.0` → `1333.333` |
| `PLL_EXTRA_CLK_ACTUAL_FREQ_MHZ_6` | `0.0` → `1333.333` | `0.0` → `1333.333` |
| `PLL_EXTRA_CLK_ACTUAL_FREQ_MHZ_7` | `0.0` → `1333.333` | `0.0` → `1333.333` |
| `PLL_EXTRA_CLK_ACTUAL_FREQ_MHZ_8` | `0.0` → `1333.333` | `0.0` → `1333.333` |
| `PLL_VCO_CLK_FREQ_MHZ` | `0.0` → `1333.333` | `0.0` → `1333.333` |
| `PREV_PROTOCOL_ENUM` | `(empty)` → `PROTOCOL_DDR4` | `(empty)` → `PROTOCOL_DDR4` |
| `SYS_INFO_DEVICE` | `(empty)` → `AGFB027R25A2E2V` | `(empty)` → `AGFB027R25A2E2V` |
| `SYS_INFO_DEVICE_DIE_REVISIONS` | `(empty)` → `HSSI_WHR_REVA,HSSI_CRETE3_REVA,MAIN_FM8_REVA` | `(empty)` → `HSSI_WHR_REVA,HSSI_CRETE3_REVA,MAIN_FM8_REVA` |
| `SYS_INFO_DEVICE_FAMILY` | `(empty)` → `Agilex 7` | `(empty)` → `Agilex 7` |
| `SYS_INFO_DEVICE_POWER_MODEL` | `(empty)` → `STANDARD_POWER` | `(empty)` → `STANDARD_POWER` |
| `SYS_INFO_DEVICE_SPEEDGRADE` | `(empty)` → `2` | `(empty)` → `2` |
| `SYS_INFO_DEVICE_TEMPERATURE_GRADE` | `(empty)` → `EXTENDED` | `(empty)` → `EXTENDED` |
| `TRAIT_IOBANK_REVISION` | `UNKNOWN` → `IO96A_REVB2` | `UNKNOWN` → `IO96A_REVB2` |
| `TRAIT_SUPPORTS_VID` | `0` → `1` | `0` → `1` |

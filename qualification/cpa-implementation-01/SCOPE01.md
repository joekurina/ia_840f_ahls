# Parallel CPA implementation investigation

## Current instruction and boundary

Joe explicitly requested investigation of effective fitted settings, available implementation data, and documented physical clock-network/EMIF controls, with multiple parallel subagents. This resumes local investigation; the older vendor-support-only blocker wording is not an instruction to stop it.

**Research/inspection only.** No configuration edits, refits, device operations, programming, resets, installs or support submissions are authorized by this task. Parent alone handles any needed workstation ordinary-file/native read-only acquisition through owned tmux. Children work from local evidence and official documentation and write only their assigned report/request file. No child may execute source scripts, tests, vendor tools, SSH or Git mutations.

Preserve OFS2026.1, Quartus26.1.1 Build130, AGFB027R25A2E2V, board clock/interface contract, both DDR banks and PR/static boundaries. Classify any candidate that would change these as needing a scope decision; do not apply it. Full CPA model reconstruction is not a new mandatory acceptance gate: a documented physical change may be evaluated later under the approved experiment budget and unchanged signoff/hardware requirements.

## Verified starting point

- Work22 seed2 and Work23 seed3 both fail EMIF1 bit243 hold by−0.004 ns at Fast vid2 100C. All five exact-transfer slacks match; no path exception. All builds/diagnostic queries are completed, preserved and spent.
- Work21 / Quartus25.1 passes +0.082 ns. The reported signoff difference is−0.084 ns CPA COMP and−0.002 ns launch-clock interconnect. Data delay0.288 ns and required2.968 ns are unchanged. This is not isolated compiler-defect proof.
- Named path: `local_mem_wrapper|mem_ss_top|mem_ss_sv|mem_ss|mem_ss|emif_1|emif_1|arch|arch_inst|hmc.amm.amm.data_if_inst|amm_writedata_0_r[0][243]` → corresponding `io_tiles_wrap_inst|io_tiles_inst|tile_gen[2].lane_gen[1].lane_inst|lane_inst~phy_reg1`.
- Physical launch/UFI/capture: `BLOCK_INPUT_MUX_PASSTHROUGH_X192_Y3_N0_I32`, `UFI_X210_Y0_N355`, `IO12LANE_X184_Y0_N374`. Changing COMP is on `TILECTRL_X172_Y0_N298`, logical `tile_gen[1].tile_ctrl_inst|pa_core_clk_out[0]`.
- Matched final-netlist feedback observations: core rise min3.479→3.478/max3.857→3.853 ns, fall min3.458→3.455/max3.834→3.829; PHY rise min1.166/max1.356, fall min1.166/max1.355 are identical. Core topology/fanout differ; PHY full rows match. These propagation extrema are not the production CPA equation or detector-reference-plane delays.
- Generated CPA offsets are zero and external core phase controls disabled; output0 selects `fb1_p_clk`. `CPA_FB_MUX_1_SEL` controls output1, not output0. Generated source is not exhaustive effective fitted-setting evidence.
- Active effort is already High Performance, Maximum placement/router, aggressive hold ON, All Paths hold optimization, exact bit243 retiming-OFF and fit-only10ps with STA skip. Do not re-propose already enabled settings as new experiments. The launch remains a Hyper-Register; effective precedence of vendor force versus OFF is not proved.
- Current3.000 ns clocks relevant to this failure are EMIF core-user / low-rate PHY clocks (~333.33 MHz), from the quarter-rate memory configuration. The compiled scalar AFU selects `uClk_usrDiv2` (156.25 MHz), with CDC; do not call3 ns a universal AFU clock. Goal wording was overly broad.

## Evidence locations

`evidence-index01.json` pins key reports. Paths below are relative to the repository:

- `qualification/fim-build-23/timing22-readback/output_files/`: complete Fitter/STA/DRC reports. `result-review32.md` provides native line citations.
- `qualification/fim-build-21/final-capture01/`: passing25.1 fit/STA and metadata.
- `qualification/fim-build-23/cpa-feedback41/result-readback/reports/`: eight explicit-polarity26.1 feedback reports and anchor.
- `qualification/fim-build-23/cpa-work21-46/result-readback/reports/`: matched25.1 reports and anchor.
- `qualification/fim-build-23/feedback-review52.md`, `feedback-comparison50.json`, `reference-clock-compensation18.json`: accepted observations, differences and limits.
- `qualification/fim-build-23/clock-compensation-remedy-review32.md`: exact generated-source links and existing CPA evidence.
- `qualification/fim-build-23/cpa-help35/readback/help.log`, `cpa-help36/readback/help.log`, `cpa-help45/readback/help.log`: installed API documentation.
- `qualification/router-native-capability-01/remote-evidence/`: actual26.1.1 Agilex7 assignment-name and fitter-name lists plus metadata/default queries. Generic assignment metadata is not device applicability or effective consumption.
- `qualification/fim-build-18/assignment-readback01/02/03/` and `VENDOR-RESEARCH-DISPOSITION.md`: earlier bounded findings. Atom command presence did not establish documented key semantics; eSRAM delay-chain100 does not transfer to EMIF.

`report_delay_calculation` is absent in the inspected26.1.1 STA. Bounded CPA/compensation command-name discovery found none. `report_path` supports bounded min/max and edge filters; keeper boundaries matter. `report_clock_network` includes fanin/fanout and its `initial_depth` only collapses GUI rows, not query extent. Avoid an unbounded fanout substitute.

## Five independent lanes and outputs

1. **Effective settings:** `01-effective-settings.md`, optional `01-requests.json`.
2. **Physical topology:** `02-clock-topology.md`, optional `02-requests.json`.
3. **Physical clock controls:** `03-clock-controls.md`, optional `03-requests.json`.
4. **EMIF controls:** `04-emif-controls.md`, optional `04-requests.json`.
5. **Numerical/experiment audit:** `05-model-audit.md`, optional `05-requests.json`.

Reports should distinguish proven facts, source requests, actual fitted observations, documented supported controls, hypotheses and gaps. For each candidate give exact evidence, target, intended physical effect, whether clock/interface requirements change, and the smallest discriminator. No invented assignment names or unsupported atom keys. Use references inline. Return requests for missing exact files/API help to the parent; do not access the workstation.

Preferred GLM5.3 is unavailable through this runtime's delegation interface; reviewers use the inherited GPT6/openai-codex model and must disclose that substitution. No model-routing configuration is changed.

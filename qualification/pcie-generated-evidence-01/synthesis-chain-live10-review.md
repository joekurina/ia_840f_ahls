# PCIe synthesis chain live10 — static disposition

**ready=false; ready_for_build=false; execution_authorized=false.** All four literal QIP-selected synthesis bodies are byte-identical to their retained simulation counterparts. This closes the four-body comparison, not the actual compiled board source set, dependency closure, timing or hardware acceptance. No new RTL defect is established and no source fix is justified.

## Scope and integrity

Local captured-text/Python inspection only. No workstation/network acquisition, HDL/Tcl/vendor execution, simulation, tests, source edits or commits. No protected directives detected; no decryption. PLL live08/live09 is a separate review, not re-reviewed here.

`pcie-synthesis-chain-live10.json`: **11551912 bytes**, SHA256 `89fab314daae1a4ec64f87f8cd8f6fc1e0de23a007edb8691ac8574156fd4a33`, `errors=[]`. Independently recomputed the container and four UTF-8 payload lengths/hashes: four unique payloads, **11404444 bytes** total. Independently checked comparison payload hashes and live02/live03 container hashes against the retained review. Live02's historical HIP cap error is not a live10 failure: the complete comparison HIP is from live03.

Citations are **1-based decoded payload lines**, not JSON lines. Q is `/home/uwb_student00/ahls/new_BSP/work_ia840f_ipgen_03/ipss/pcie/qip/pcie_ss/pcie_ss.qip` in live06. Exact synthesis aliases:

- **TOP** = `/home/uwb_student00/ahls/new_BSP/work_ia840f_ipgen_03/ipss/pcie/qip/pcie_ss/synth/pcie_ss.v`
  - 2454833 bytes; 3219 lines; SHA256 `c64ce327ff29f6a92c9af4bbf8ede410fe6b94c88796f6bf774866e85c3c8e9f`; Q:348.
  - Byte-identical comparison: `/home/uwb_student00/ahls/new_BSP/work_ia840f_ipgen_03/ipss/pcie/qip/pcie_ss/sim/pcie_ss.v` (live02).
- **AXI** = `/home/uwb_student00/ahls/new_BSP/work_ia840f_ipgen_03/ipss/pcie/qip/pcie_ss/intel_pcie_ss_axi_500/synth/pcie_ss_intel_pcie_ss_axi_500_gycdipy.sv`
  - 755529 bytes; 12989 lines; SHA256 `ea4e45e5539f8153dbb0590c01c75f3f2c36103e83d989894033d567eaf55536`; Q:162.
  - Byte-identical comparison: `/home/uwb_student00/ahls/new_BSP/work_ia840f_ipgen_03/ipss/pcie/qip/pcie_ss/intel_pcie_ss_axi_500/sim/intelfpga/pcie_ss_intel_pcie_ss_axi_500_gycdipy.sv` (live02).
- **BRIDGE** = `/home/uwb_student00/ahls/new_BSP/work_ia840f_ipgen_03/ipss/pcie/qip/pcie_ss/intel_pcie_ss_axi_500/synth/pcie_ss_intel_pcie_ss_axi_intel_pcie_ptile_ast_500_pxriq3y.v`
  - 712613 bytes; 12548 lines; SHA256 `3e158e13cfd3f772c765938ba10eb32eda0bd885bbf5fb2bcadcca4ecc53deaf`; Q:161.
  - Byte-identical comparison: `/home/uwb_student00/ahls/new_BSP/work_ia840f_ipgen_03/ipss/pcie/qip/pcie_ss/intel_pcie_ss_axi_500/sim/pcie_ss_intel_pcie_ss_axi_intel_pcie_ptile_ast_500_pxriq3y.v` (live02).
- **HIP** = `/home/uwb_student00/ahls/new_BSP/work_ia840f_ipgen_03/ipss/pcie/qip/pcie_ss/intel_pcie_ptile_ast_1100/synth/pcie_ss_intel_pcie_ptile_ast_1100_ndgxg4a.sv`
  - 7481469 bytes; 43093 lines; SHA256 `5d2743a48beed5c3a5bd0e0560b7cebf31ee435431fb7fd0ca8280049d01e40a`; Q:88.
  - Byte-identical comparison: `/home/uwb_student00/ahls/new_BSP/work_ia840f_ipgen_03/ipss/pcie/qip/pcie_ss/intel_pcie_ptile_ast_1100/sim/pcie_ss_intel_pcie_ptile_ast_1100_ndgxg4a.sv` (live03).

Identity was directly computed, not assumed from suffixes or required as a general rule for simulation versus synthesis representations. Here all four are identical, so earlier decoded PCIe citations remain valid for synthesis. No `.vo`/modular normalization was necessary for these PCIe files.

## Source selection and effective generated contract

Q:348/162/161/88 explicitly registers TOP/AXI/BRIDGE/HIP in libraries pcie_ss/intel_pcie_ss_axi_500/intel_pcie_ss_axi_500/intel_pcie_ptile_ast_1100. Q:2 records26.1.1, Q:16 AGFB027R25A2E2V, Q:20 STANDALONE, Q:21 SYNTHESIS_ONLY_QIP; Q:6 also says PRE_COMPILED_MODULE ON. These registrations identify the requested bodies, not proof of loaded FIM source/library resolution or a compiled database.

- **TOP:179–183,216,458–464,1169**: AXI instance `pcie_ss` explicitly receives TILE=P-TILE, device_type=EP, topology=pcie_x16, function mode=pcie_g4_x16_ep, qhip_mode=1, DWIDTH=512 and NUM_OF_SEG=2. This is effective generated selection, not the saved parent's stale R-TILE field.
- **AXI:11521,12208–12211**: that selection activates `gen_ptile.u_ptile`, BRIDGE without parameter overrides. F-Tile/RP branches are not this path. **BRIDGE:11050–11070,11954** instantiates HIP as `intel_pcie_ptile_ast_qhip`, overriding Agilex7/NATIVE/pcie_x16. **HIP:22882,42312** forwards into `ptile_pcie_adapter_avst_wrapper inst`; its implementation is outside these four bodies.
- **TOP:949–952; BRIDGE:11212–11224; HIP:41417,41423–41424**: two PFs, SR-IOV enabled, PF0 one VF, PF1 zero VFs, total one VF. Two PFs means PF0/PF1, not enabled PF2. Preserve PF0VF0 AFU/PF1 BMC intent; no end-to-end routing validation is inferred.
- **BRIDGE:11121/11123/11125**: PF1 BAR0 width12, BAR2 width28, BAR4 width14. **HIP:3396/3399/3402**: BAR0 disabled, BAR2/BAR4 enabled. **HIP:3244–3255**: BAR2/BAR4 memory, prefetchable, 64-bit. These low-level HIP declarations are unoverridden by the complete BRIDGE instance override list, not defaults from an inactive module. **HIP:26124–26135,26276,41451/41453** forwards types/prefetch/enable/widths. **HIP:20391–20409**, especially20392, gates BAR masks by enable/count: width12 does not enable BAR0.
- **BRIDGE:11108–11119** preserves PF0 BAR0/2/4 and PF0 VF BAR0/2/4 widths20/0/14. Existing generated-hdl-review.md's IDs and remaining PCIe parameter findings apply to these identical bodies; no new hardware-ID claim is made.
- **AXI:4530–4541,4687** selects `EP_PFTILE_WRAPPER.gen_pciess.u_pciess_p0` and forwards DWIDTH512 / segments2 into `intel_pciess_ptile_wrapper`. Python conversion confirms64 bytes; preserve the64-byte/two-segment workaround. This datapath consumer is a parallel AXI child, not a claim that CSR passes serially through BRIDGE and HIP.

No `defparam` or conditional preprocessor override directives were found in the four bodies. AXI:3387 does define a BAR-size macro; absence of conditional overrides is not absence of all macros or dependencies.

## CSR clock wiring: exact limit of closure

Prior maintained-source evidence (`clock-consumer-contract-review.md:28–42`) traces sys_pll output1 -> clk_100m -> clk_csr -> PCIe csr_clk; both DM and AXIS wrapper choices forward csr_clk to p0_axi_lite_clk. That maintained board-source trace is not newly captured board elaboration evidence.

**TOP:14,1177** declares/forwards input `p0_axi_lite_clk` into AXI. **AXI:1138,4530–4533,4687,4692** passes it directly to the selected P-Tile datapath wrapper's `.axi_lite_clk(p0_axi_lite_clk)`; **TOP:16,1179; AXI:4694** similarly forwards its reset. The four bodies do not retime this input or prove a frequency for it.

Neither BRIDGE nor HIP contains an `axi_lite_clk` token. Do not invent a serial CSR edge through those modules: their HIP clock is distinct. **HIP:21727** assigns `coreclkout_hip=adapter_clk`; **BRIDGE:12074; AXI:12209; TOP:1171** forward that output as coreclkout_hip_toapp. Its presence and BRIDGE:11058's adapter clock source=IOPLL do not bind CSR to the HIP adapter clock or establish evaluated clock frequencies.

The literal next source, only if deeper static CSR/divider traversal is required, is Q:166's `/home/uwb_student00/ahls/new_BSP/work_ia840f_ipgen_03/ipss/pcie/qip/pcie_ss/intel_pcie_ss_axi_500/synth/intel_pciess_ptile_wrapper.sv`, which matches AXI:4533's consumer module. No acquisition is performed or authorized here. Follow only literal references after that body; stop at protected source. This one path is not a request for broad recursive dependency capture.

## Remaining evaluated timing and source-selection boundary

Live06 rendered AXI SDC:82–94 supplies Lite100 and its period expression; :161–164 conditionally creates p0_axi_lite_clk only if its port collection exists and exact lookup returns-1. :133 snapshots clock targets; :162 uses `lsearch -exact` with literal `p*_axi_lite_clk`, not wildcard matching. :191–192's AVMM divide-by2 target is inside the P-Tile datapath wrapper, not inside the four-file HIP chain. New RTL confirms the selected wrapper and forwarding; it does **not** evaluate these Tcl conditions or resolve that internal divider target.

The prior nominal system-PLL100.7142857 MHz versus conditional SDC100 MHz is a numerical source-level discrepancy, **not proof of conflicting effective timing clocks**. PLL synthesis evidence belongs to the independent live08/live09 review. No TimeQuest objects exist in this evidence. Still needed for timing judgment: actual compiled board/header/library/source selection and loaded QIP/SDC order; current instance and get_ports collections; target-list snapshot and lookup result; incoming PLL clock name/source/period/targets; whether the conditional clock is created/replaced/coexists at the same sink; resolved AVMM master/target. No timing execution is authorized by this report. Four-body byte identity does not close reset/CDC behavior or quantitative consumer frequency tolerance.

## Disposition

- PASS_STATIC: four captured identities, literal QIP registrations, synthesis/simulation byte comparison, generated P-Tile Gen4x16/PF/VF/BAR/datapath contract, CSR forwarding to the selected datapath wrapper.
- UNRESOLVED: actual compiled FIM source/hierarchy selection, transitive implementation closure, evaluated clock binding, tolerance, timing, hardware and overall generation recovery.
- Proven new defects: **none in this scoped comparison**. No speculative retune, BAR edit, constraint relaxation, pin/channel change, or source fix proposed.
- Preserve core470, seven-port PLL interface, AGFB027R25A2E2V and all existing geometry/pins/channels. **ready_for_build remains false.**

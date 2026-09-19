# Generated PCIe and PLL HDL: local static disposition

**ready=false; ready_for_build=false; execution_authorized=false.** Generated simulation HDL resolves P-Tile selection and the nominal PLL-divider discrepancy. It does not establish synthesis identity, approved clock tolerance, timing closure or hardware behavior. Only the two owned review outputs were written. No HDL/Tcl/vendor tools, simulation, tests, remote access, source/pin/channel/gate modifications or commits were performed.

## Integrity and exact file aliases

Read `live01-review.md` and used only the six entries of `live01-next-reads.json.capture_roots` as the finite inventory, not its trailing reference inventory. Independently recomputed both container SHA256 values and all six payload UTF-8 lengths/hashes. Exact path order matches those six roots; six unique payloads total **11,418,190 bytes**.

- live02: **4,001,719 bytes**, SHA256 `f452ab6228090f0d4ccad08a7f54913c0ae64e0541f7a7c3660fb020f7d7ebf0`. Three complete files. Its recorded HIP error is `RuntimeError('capture byte limit: 7481469')`; this is the earlier 4 MiB cap stop, not a corrupt partial HIP accepted as complete.
- live03: **7,565,580 bytes**, SHA256 `9d7b704043d754e19b9d5089a28eb96f7e67060edcfb538d71d231d7aa9038ec`. HIP and both PLL files complete; `errors=[]`. The separate receipt supplies the larger HIP under the stated 8 MiB cap.
- No HDL protection directive marker was detected. `bti_protected` identifiers in HIP are parameter names, not protected/encrypted payload markers. No decoding or decryption was attempted. Integrity is of captured bytes, not proof of current remote state.

Line citations below are 1-based decoded payload lines, **not JSON-container lines**.

- **TOP** = `/home/uwb_student00/ahls/new_BSP/work_ia840f_ipgen_03/ipss/pcie/qip/pcie_ss/sim/pcie_ss.v`
  - pcie-generated-live02.json; 2454833 bytes; 3219 decoded lines; SHA256 `c64ce327ff29f6a92c9af4bbf8ede410fe6b94c88796f6bf774866e85c3c8e9f`.
- **AXI** = `/home/uwb_student00/ahls/new_BSP/work_ia840f_ipgen_03/ipss/pcie/qip/pcie_ss/intel_pcie_ss_axi_500/sim/intelfpga/pcie_ss_intel_pcie_ss_axi_500_gycdipy.sv`
  - pcie-generated-live02.json; 755529 bytes; 12989 decoded lines; SHA256 `ea4e45e5539f8153dbb0590c01c75f3f2c36103e83d989894033d567eaf55536`.
- **BRIDGE** = `/home/uwb_student00/ahls/new_BSP/work_ia840f_ipgen_03/ipss/pcie/qip/pcie_ss/intel_pcie_ss_axi_500/sim/pcie_ss_intel_pcie_ss_axi_intel_pcie_ptile_ast_500_pxriq3y.v`
  - pcie-generated-live02.json; 712613 bytes; 12548 decoded lines; SHA256 `3e158e13cfd3f772c765938ba10eb32eda0bd885bbf5fb2bcadcca4ecc53deaf`.
- **HIP** = `/home/uwb_student00/ahls/new_BSP/work_ia840f_ipgen_03/ipss/pcie/qip/pcie_ss/intel_pcie_ptile_ast_1100/sim/pcie_ss_intel_pcie_ptile_ast_1100_ndgxg4a.sv`
  - pcie-generated-live03.json; 7481469 bytes; 43093 decoded lines; SHA256 `5d2743a48beed5c3a5bd0e0560b7cebf31ee435431fb7fd0ca8280049d01e40a`.
- **PLLTOP** = `/home/uwb_student00/ahls/new_BSP/work_ia840f_ipgen_03/ofs-common/src/fpga_family/agilex/sys_pll/sys_pll/sim/sys_pll.v`
  - pcie-generated-live03.json; 1173 bytes; 32 decoded lines; SHA256 `497aeec1120e0832dd0406944aaf06f5f519cc54b88ffb98bab7918bab9ab044`.
- **PLLVO** = `/home/uwb_student00/ahls/new_BSP/work_ia840f_ipgen_03/ofs-common/src/fpga_family/agilex/sys_pll/sys_pll/altera_iopll_2110/sim/sys_pll_altera_iopll_2110_3lkpvti.vo`
  - pcie-generated-live03.json; 12573 bytes; 430 decoded lines; SHA256 `b66b89ab8030a6beed7ffb593c13fca1030ef18dab1f0fc8401b06aa0a4f500d`.

## Active PCIe chain, not inactive defaults

1. **TOP:179–180,183,216,460** instantiates AXI with `TILE="P-TILE"`, `device_type="EP"`, `pciess_topology="pcie_x16"`, `qhip_mode_hwtcl=1`. This resolves effective generated selection independently of the saved parent's stale/inconsistent `TILE_user=R-TILE`. Do not rewrite the parent from this observation.
2. **AXI:11521** therefore selects `gen_ptile`; **AXI:12208–12211** instantiates BRIDGE as `u_ptile` with no parameter override. The F-Tile and RP alternatives are not the active path. **AXI:4530–4541** selects the EP P-Tile datapath wrapper separately and forwards `DWIDTH` and `NUM_OF_SEG`.
3. **BRIDGE:11050–11954** instantiates HIP as `intel_pcie_ptile_ast_qhip`, explicitly overriding device family to `Agilex 7` (11051), adapter to `NATIVE` (11052), core16 topology to `pcie_x16` (11070), PF/VF counts and BAR widths below.
4. **HIP:22882–42312** instantiates `ptile_pcie_adapter_avst_wrapper` as `inst` and forwards the effective parameters. The wrapper implementation itself is outside this six-file review. The HIP file is one module (15–43091), not permission to treat every parameter or auxiliary core as active. HIP's generic PF count=1, VF counts=0 and BAR width16 declarations are overridden by BRIDGE; they do **not** describe this instantiation.
5. Low-level HIP IDs/BAR type/enable fields below are **unoverridden declarations of this actively instantiated generated module**, then forwarded into `inst`; these are not arbitrary defaults selected from uninstantiated modules. The full BRIDGE override list was checked for each, and the JSON retains declaration and downstream consumer line references. No `defparam` or preprocessor conditional overrides were found in the six bodies.

### Preserved generated contract

| Item | Effective values and exact evidence |
|---|---|
| Gen4 x16 | TOP:216 and BRIDGE:11070 `pcie_x16`; HIP:424 topology `pcie_x16`; HIP:2657/2688 PF0 maximum `pf0_max_16gts` / target `pf0_trgt_gen4` (PF1 analogous at 3451/3470) |
| PF/VF counts | TOP:949–952 and BRIDGE:11212–11224: multi-function=1, total PF=2, SR-IOV=1, PF0 VF=1, PF1 VF=0, total VF=1; HIP:2542 `pf0_max_func_num="pf0_two_functions"` and 2560 multi_func true corroborate |
| PF1 BAR0 | BRIDGE:11121 width12, but HIP:3396 `...pf1_pci_type0_bar0_enabled="disable"`; width12 does not enable it |
| PF1 BAR2 | BRIDGE:11123 width28; HIP:3244/3245/3247 memory / prefetch true / `pf1_bar2_mem64`; HIP:3399 enabled |
| PF1 BAR4 | BRIDGE:11125 width14; HIP:3252/3253/3255 memory / prefetch true / `pf1_bar4_mem64`; HIP:3402 enabled |
| PF0 BARs | BRIDGE:11108/11110/11112 widths20/0/14; HIP:2596/2599/2602 enabled/disabled/enabled; HIP:2257–2276 preserve 64-bit prefetchable BAR0/BAR4 |
| PF0 VF BAR widths | BRIDGE:11115/11117/11119 =20/0/14; PF1 VF widths0 at 11128/11130/11132 with VF count0 |
| Datapath | TOP:463–464 `core16_DWIDTH=512`, `core16_NUM_OF_SEG=2`; AXI:4540–4541 forwards to active P-Tile wrapper. Python conversion: 512/8=64 bytes; preserve the 64-byte/two-segment workaround |

“PF2” as a count means **two PFs (PF0 and PF1)**, not an enabled function indexed PF2. PF0's sole VF is VF0. Preserve PF0VF0 AFU / PF1 BMC routing intent; no transaction or end-to-end AFU/BMC routing acceptance is inferred.

HIP mask logic is also consistent: `get_bar_size_mask` at **20321–20335** forms low address-bit masks; **20391–20409** gates PF1 masks by active count/function and BAR enable. BAR0's actual `pci_type0_bar0_mask_31_1` is zero because enable is disabled (20392), despite the width12 bookkeeping mask. BAR2/BAR4 pair masks derive from widths28/14: Python computes `0x0fffffff` / `0x3fff`, corresponding to 268435456 / 16384-byte nominal apertures. These are the generator's size-mask representation, not a claim about software BAR readback or bridge behavior. No aperture or decode change is warranted.

### IDs on the same active chain

All decimal-to-hex and class-code assembly below were calculated with Python. Parameter prefix is `hssi_ctp_u_wrpcie_top_u_core16_pfN_`.

| Function | Vendor / device | Revision / class | Subsystem vendor / device | VF device | HIP declaration evidence |
|---|---|---|---|---|---|
| PF0 | 0x8086 / 0xbcce | 0x1 / 0x120000 | 0x8086 / 0x1771 | 0xbccf | 2605–2606; 2872; 2281/3034/2783; 3035–3036; 3030 |
| PF1 | 0x12ba / 0x0070 | 0x1 / 0x120000 | 0x12ba / 0xb5d4 | 0x0, inactive | 3405–3406; 3571; 3260/3683/3492; 3684–3685; 3679 |

Class bytes are base18, subclass0, programming-interface0, not a flattened arbitrary class occurrence. HIP:25478–25479 and 26294–26295 forward vendor/device IDs, with all remaining consumer lines retained in the JSON.

## Actual PLL primitive and nominal divider derivation

**PLLTOP:19–29** instantiates PLLVO; outclk_1 maps explicitly at line24. **PLLVO:147–286** instantiates `tennm_iopll` as `tennm_pll`. This is the system PLL, not PCIe's internal PLL.

- `feedback="direct"` (247); `refclk_time="100.0 MHz"` (281); `refclk_src_mux="clk_0"` (280). Dedicated reference is wired from `refclk` at 109 and into the primitive at 312.
- M bypass=false (249), high71/low70 (251–252): **M=141**.
- N bypass=false (256), high5/low5 (257–258): **N=10**.
- PFD/VCO strings are `10.0 MHz` / `1410.0 MHz` (269/285), agreeing with 100/10 and 100×141/10 under the reference assumption.
- Outputs0–6 map to primitive outclk[1]–[7] (**72–78**); do not mistake public outclk_1 for C1. Counters1–7 enabled, counters0/8 disabled (**132–140**).
- Active C1–C7 bypass=false and high/low counts are **2+1, 7+7, 3+3, 1+1, 14+14, 6+6, 2+2** at **157–203**. Thus C={3,14,6,2,28,12,4}. Duty settings do not change these nominal divider totals.

Python `fractions.Fraction` computed `f_out = 100000000 × 141 / (10 × C)` and compared rounded integer Hz with saved metadata from live01. Every listed saved rate matches that rounding.

| Public output | Primitive counter | C | Request MHz | Divider nominal MHz | Saved Hz | Difference from request |
|---|---|---:|---:|---:|---:|---:|
| outclk_0 | C1 | 3 | 470 | 470.000000000 | 470000000 | +0.000000000% |
| outclk_1 | C2 | 14 | 100 | 100.714285714 | 100714286 | +0.714285714% |
| outclk_2 | C3 | 6 | 235 | 235.000000000 | 235000000 | +0.000000000% |
| outclk_3 | C4 | 2 | 630 | 705.000000000 | 705000000 | +11.904761905% |
| outclk_4 | C5 | 28 | 50 | 50.357142857 | 50357143 | +0.714285714% |
| outclk_5 | C6 | 12 | 117.5 | 117.500000000 | 117500000 | +0.000000000% |
| outclk_6 | C7 | 4 | 350 | 352.500000000 | 352500000 | +0.714285714% |

**outclk_1 is 705000000/7 Hz = 100714285.7142857… Hz**, rounding to saved **100714286 Hz**, not exactly the request100 MHz. Its nominal period is **9.929078014184396 ns**, difference **+0.7142857142857143% / +7142.857142857143 ppm**. The primitive's own outclk2 string at PLLVO:262 is `100.714286 MHz`; agreement now exists at both generated counter and metadata layers, not just inferred from rounded output rates.

**outclk_3 is 705 MHz**, not requested630 MHz: **+11.904761904761905%**. PLLVO:264 explicitly says `705.0 MHz`, even though clock_name_4 is `clk_630m_noc` at 219. Similarly `clk_100m` at 217 is a name, not proof of an exact100 MHz clock. No acceptable tolerance was supplied for either mismatch.

The saved GUI M=6, N=1, C=6 fields noted by live01 are inactive/stale GUI settings, not these instantiated counters. This review supersedes the earlier “generated divider not yet verified” status **only for nominal static simulation-generated primitive configuration under a100 MHz reference assumption**. It does not measure SYS_REFCLK or prove fitted clocks.

## Source and constraint implications; unchanged boundaries

- TOP:1177 connects external `p0_axi_lite_clk` into AXI; active EP P-Tile datapath instance consumes it as `.axi_lite_clk(p0_axi_lite_clk)` at AXI:4692 and reset at4694. PLLTOP:24 and PLLVO:73 independently fix the generated producer mapping to C2. Prior maintained-source trace in live01 connects SYS_REFCLK → sys_pll → outclk_1/clk_100m → clk_csr → wrapper csr_clk → p0_axi_lite_clk. That whole board hierarchy is not contained or fitted in these six files; distinguish prior source trace from newly captured producer/consumer endpoints.
- `core16_axi_lite_source_freq_hwtcl` remains demonstrated only as an **SDC-template dictionary key**, not a required or missing generated-child IP parameter. It is absent from these HDL bodies; that absence does not establish a new failure criterion.
- No rendered PCIe/PLL SDC or synthesis QIP was captured. Need independently established literal constraint/source-manifest paths and actual clock objects/periods/consumer binding before judging whether constraints reflect this nominal producer. Do not invent `synth/...` counterparts, substitute extensions or guess SDC paths.
- The nominal100 versus100.7142857 mismatch and630 versus705 mismatch require contract/tolerance and source/constraint reconciliation by the responsible review, not speculative source edits. Do not rename clocks, retune PLL counters, change PCIe request, alter BARs or silently grant tolerance here.
- All six inputs are simulation file-list roots. Generated simulation parameters are now statically resolved, but identity with synthesis HDL and the source set actually compiled for the target **remains unproven**. No build, elaboration, synthesis or simulation was run. Prior overall Work03 generation failure/mailbox issues remain unresolved.

## Acceptance matrix

| Criterion | Status | Evidence boundary |
|---|---|---|
| Six finite captured payload identities | PASS | Local independent UTF-8 byte/hash verification; not remote freshness |
| Effective P-Tile Gen4 x16 selection | PASS_STATIC | Active simulation-generated instantiation chain |
| Two PFs, PF0 one VF, PF1 zero VFs | PASS_STATIC | Literal override chain; PF count 2 does not mean PF2 enabled |
| PF1 BAR0 disabled; BAR2 prefetchable64 width28; BAR4 prefetchable64 width14 | PASS_STATIC | Active generated parameters and mask equations |
| PF0/PF1 IDs and 64-byte two-segment datapath | PASS_STATIC | Generated parameter values; no transaction behavior tested |
| PLL primitive counters and nominal clock derivation | PASS_STATIC | 100 MHz reference assumption; saved rates match integer-Hz rounding |
| Out1 exactly requested 100 MHz | MISMATCH_NOMINAL | Divider nominal 705000000/7 Hz; tolerance not supplied |
| Out3 exactly requested 630 MHz | MISMATCH_NOMINAL | Divider nominal 705000000 Hz; tolerance not supplied |
| Synthesis/simulation source identity and hierarchy | NOTEST | No rendered synthesis QIP/source manifest |
| Rendered SDC periods, target objects and source binding | NOTEST | No rendered SDC captured; no guessed path |
| Clock tolerance, reset/CDC, timing fit and hardware behavior | NOTEST | No vendor execution, simulation, fitting or measurements |
| Full Work03 generation recovery / build readiness | NOTEST | Prior overall generation failure not cured |

Preserve **AGFB027R25A2E2V, PTileGen4x16, PF0VF0 AFU, PF1 BMC, PF1 BAR0 Disabled, BAR2 width28, BAR4 width14,64-byte/two-segment datapath and existing pins/channels**. Exact part remains prior saved-parent evidence, not a new physical-fit result. **Keep ready=false.**

Companion `generated-hdl-disposition.json` retains container/payload hashes, exact aliases,57 scope-resolved parameter records with consumer lines, exact rational PLL arithmetic and acceptance statuses. A missing bare `python` executable was the only local tooling issue; calculations and read-only parsing used `python3` instead. No vendor executable was invoked.

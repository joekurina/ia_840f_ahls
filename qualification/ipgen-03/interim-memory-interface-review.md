# Interim work03 memory interface review

**ready_for_build: false. generation_complete: false. Not accepted.** This is a local, read-only source comparison against an interim **simulation boundary**, not synthesis RTL acceptance, complete IP generation, elaboration, timing, calibration, or hardware qualification. The enclosing run is still running according to the supplied task context and has an overall BMC error; this review does not independently poll that run or clear that error.

Only this report is written. No source, preset, donor hash, manifest, authorization, or readiness setting is changed. No remote access, project Tcl/Python execution, vendor tool, build, or test was used. Python only parsed captured text and calculated hashes/counts.

## Evidence and naming

Paths are relative to `/home/joe/Projects/Thesis/AHLS/new_bsp/new`:

- `C` = `ofs-agx7-pcie-attach`.
- `M` = `C/ofs-common/src/fpga_family/agilex/mem_ss`.
- `G` = `C/ofs-common/scripts/common/syn/ip_get_cfg`.
- `P` = `ofs-platform-afu-bbb/plat_if_develop/ofs_plat_if/src/rtl/ifc_classes/local_mem`.
- `W:Lx` denotes line x of the decoded `files["sim/mem_ss.v"].content` in `qualification/ipgen-03/interim-memory-wrapper.json`, not the JSON line number.

The snapshot SHA-256 is `4a0143d5e8aa397ff58df6693cd23f3d0f80de9bb388883c07c8e33dbfc4c347`. All three decoded payload hashes independently match their recorded SHA-256:

| Captured file | SHA-256 |
|---|---|
| `sim/mem_ss.v` | `f5fd9ee05e8cf89c202039c0bc6d5950b55aace9d0447402da17bf46c9e14e75` |
| `mem_ss_generation.rpt` | `51ee26e568173b483c5dcb9bfa0608e15f6b66904522bb17fe48faf8509f33e7` |
| `mem_ss.html` | `b9ae70c03a137a780c602575bbc339a4abfdc656667a3c77a1c2322230e07a68` |

`W` identifies ACDS 26.1.1 build 130. The report explicitly invokes simulation generation for AGFB027R25A2E2V. Its nested-generation warnings say the Quartus project was not specified; this is another reason not to treat the wrapper as project-level qualification. The HTML shows `mem_ss v5.0.1`, `DDR4,DDR4`, `STORAGE,STORAGE`, BOT/BOT, connection vectors `1,0` and `0,1`, and `ENABLE_MEM_CSR_INTF=DISABLED`. Its `deviceFamily=UNKNOWN` parameter does not supersede the report's explicit device configuration and is not a device-acceptance result.

The earlier `docs/memory-port-source-map.md` and `docs/memory-csr-source-review.md` remain historical source reviews. This snapshot resolves some raw port questions they left open; it does not rewrite their evidence or prove the OFS-generated SV/header stage completed.

## Actual raw boundary

Static parsing found **128 port declarations**. The two DDR4 physical bundles have identical direction/width/name shapes after removing `mem0_` versus `mem1_` prefixes.

| Raw ports, for each n=0,1 | Direction at IP | Width |
|---|---|---|
| `mem<n>_pll_ref_clk`, `mem<n>_oct_rzqin` | input | scalar each |
| `mem<n>_ddr4_ck`, `_ck_n`, `_act_n`, `_cke`, `_cs_n`, `_odt`, `_reset_n`, `_par` | output | `[0:0]` each |
| `mem<n>_ddr4_a` | output | `[16:0]` |
| `mem<n>_ddr4_ba`, `_bg` | output | `[1:0]` each |
| `mem<n>_ddr4_alert_n` | input | `[0:0]` |
| `mem<n>_ddr4_dqs`, `_dqs_n`, `_dbi_n` | inout | `[7:0]` each |
| `mem<n>_ddr4_dq` | inout | `[63:0]` |
| `mem<n>_ss_app_usr_clk`, `_ss_app_usr_reset_n` | output | scalar each |
| `mem<n>_local_cal_success`, `_local_cal_fail` | output | scalar each |

References: W:L7–46,91–92,133–134. Interface comments call these `mem0_ddr4`/`mem1_ddr4`, with roles `mem_ck`, `mem_a`, etc.; status interfaces are `mem0_status`/`mem1_status` with roles `local_cal_success`/`local_cal_fail`.

Application interfaces are **`i0_axi_mm` and `i1_axi_mm`**, W:L51–90 and 93–132. For each n, input signals have prefix `i<n>_app_ss_mm_`; output signals have prefix `i<n>_ss_app_mm_`:

| Suffixes | Direction | Width |
|---|---|---|
| `awid`, `arid` | input | 9 |
| `awaddr`, `araddr` | input | 34 |
| `awlen`, `arlen` | input | 8 |
| `awsize`, `arsize` | input | 3 |
| `awburst`, `arburst` | input | 2 |
| `awlock`, `arlock` | input | 1 |
| `awcache`, `arcache`, `awqos`, `arqos` | input | 4 |
| `awprot`, `arprot` | input | 3 |
| `awuser`, `aruser` | input | 14 |
| `wdata`, `wstrb` | input | 512, 64 respectively |
| `awvalid`, `arvalid`, `wvalid`, `wlast`, `bready`, `rready` | input | 1 each |
| `awready`, `arready`, `wready`, `bvalid`, `rvalid`, `rlast` | output | 1 each |
| `bid`, `rid` | output | 9 each |
| `bresp`, `rresp` | output | 2 each |
| `buser` | output | 1 |
| `rdata` | output | 512 |

There is **no raw `wuser`, `ruser`, CSR AXI-Lite, CSR clock, or CSR reset port**. Internal `csr_*` generation messages do not establish an externally accessible CSR interface.

The `subsystem_reset` conduit contains scalar inputs `app_ss_rst_req`, `app_ss_cold_rst_n` and scalar outputs `ss_app_rst_rdy`, `ss_app_cold_rst_ack_n` (W:L47–50). There is no extra exported reset clock or per-channel local reset request port at this boundary.

## Raw RTL versus OFS wrapper/header producer

`M/mem_ss_top.sv:262–291` instantiates **`mem_ss_sv`**, not raw `mem_ss`. Thus `.i_axi_mm`, `.mem_ddr4`, `.mem_status`, vector clocks/OCT and `.subsystem_reset` are not mistaken raw-port spellings: they are contracts of the separate OFS producer.

`G/ofs_ip_cfg_db.tcl:69–88,96–138` first generates `ipss/mem/qip/mem_ss/sv_wrapper/mem_ss_sv.sv`, `mem_ss_if_info.vh`, `mem_ss_ip_params.vh` and `mem_ss_param_pkg.sv`, then runs `mem_ss_get_cfg.tcl` for `ofs_ip_cfg_db/ofs_ip_cfg_local_mem.vh`. `ofs_ip_cfg_db.vh` includes these headers. A raw simulation wrapper alone is not proof that these outputs exist, are current, or agree.

`G/ip_gen_sv_wrapper.tcl:143–214` derives members from ROLE and removes common prefixes. Its lines 420–520 compare full resulting interface structures, not memory format; lines 1103–1144 require dense indices to coalesce. Lines 762–791 emit presence/width macros and make width-one members **scalar**. Applied to the visible roles/shapes, the expected mapping is:

- `mem0_ddr4` and `mem1_ddr4` → `mem_ddr4[0:1]` conceptually, type `mem_ss_mem_ddr4_if`; the actual declaration convention is to be read from emitted SV. Members become `ck`, `ck_n`, `a`, etc.
- `i0_axi_mm` and `i1_axi_mm` → `i_axi_mm`, type `mem_ss_i_axi_mm_if`, two entries.
- The individual clocks, resets, refclks and OCT inputs → two-entry `mem_ss_app_usr_clk`, `mem_ss_app_usr_reset_n`, `mem_pll_ref_clk`, `mem_oct_rzqin` vectors.
- `mem0_status` and `mem1_status` → `mem_status`, type `mem_ss_mem_status_if`, with `success`/`fail` after removing `local_cal_`.
- `subsystem_reset` retains the four distinct handshake member names.

These are **source-derived expectations, not captured OFS outputs**. Additional associated-clock/reset metadata is obtained through the Qsys API by the producer and is not fully represented by raw Verilog comments. Require actual emitted SV, headers and producer log before accepting the mapping. Two external simulation model presets do not establish two physical wrapper groups.

Expected header checks include `MEM_SS_PORT_I_AXI_MM_IS_VEC=2`, `MEM_SS_PORT_MEM_PLL_REF_CLK_IS_VEC=2`, `MEM_SS_PORT_MEM_DDR4_IS_VEC=2`, `HAS_IFC_MEM_SS_MEM_DDR4_IF`, the AXI widths above, and absence of a CSR interface macro. A second physical group is not justified by the matching raw shapes. `M/includes/ofs_fim_mem_if_pkg.sv:36–97` consumes the wrapper macros for channel counts and widths; its fallback values at 119–136 are explicitly nonfunctional defaults, not a valid substitute.

### Header-parser risk remains specific

`G/mem_ss_get_cfg.tcl:104–125` whitespace-splits `MEM_INTFS_TYPE`/`APP_INTFS_TYPE`; the captured HTML serializes them with commas. If the API returns the literal displayed strings, the app loop does not recognize `STORAGE,STORAGE` and the physical loop rejects `DDR4,DDR4` at lines 193–198. The HTML is not a capture of `get_instance_parameter_value`; do not claim that failure already occurred. Next obtain the actual API values/producer diagnostics from an authorized stage. If comma serialization is confirmed, narrowly normalize separators at this consumer, retaining strict token/cardinality validation, rather than changing valid saved IP presets or manually defining macros. No such patch is applied here. The oneAPI ASP QPRS output at lines 256–324 is reference-only and is not the source of the FIM's AXI width macros.

## Exact integration findings and minimal dispositions

### 1. Candidate physical pin split conflicts with the visible equal shapes

`C/src/board/ia840f/top.sv:47–53` conditionally supports base and group-1 interfaces. That conditional RTL need not be removed. The fixed candidate location targets in `C/syn/board/ia840f/setup/emif_loc.tcl`, however, place physical channel 1 under `ddr4_mem_group_1[0]`. With the expected one-group producer result that name does not exist; channel 1 belongs at `ddr4_mem[1]`. The old source-only concern is now supported by equal **actual raw generated** DDR4 shapes, but final producer grouping remains to be captured.

Minimal later correction, conditional on emitted SV: rename only the channel-1 physical bundle targets from `ddr4_mem_group_1[0]` to `ddr4_mem[1]`, preserving every package pin and retaining refclk/OCT indices 0 and 1. Do not derive application-bank grouping or model selection from this pin rename. `DDR4_NUM_MEM_GROUPS=2`/OFSS `memory_groups=2` controls model configuration/inclusion, not the wrapper's structural comparison; do not blindly change these to one.

A separate exact lexical issue is the discrete `ddr4_mem[0].cs_n[0]` target (emif_loc.tcl:155): the producer emits width-one `cs_n` as a scalar. After observing actual SV, normalize that target to `ddr4_mem[0].cs_n`; do not assert tool rejection without elaboration. Raw `[0:0]` ports do not require `[0]` on OFS interface members. Candidate scalar `alert_n` is consistent with producer scalarization. No DQ/DQS/address-width discrepancy is visible: 64/8/17 and BA/BG 2/2 match the prior source map. RDIMM negative-refclk package evidence remains unresolved; no pin is invented.

### 2. Real QoS connectivity omission

W:L61,73,103,115 exports four-bit `awqos`/`arqos` inputs. `M/ofs_fim_emif_axi_mm_if.sv:44,73` declares them, but **`M/mem_ss_top.sv:298–341` never assigns `ss_axi_mm[c].awqos` or `.arqos`**. The PIM gasket also comments out both QoS assignments (`P/native_axi/prims/gasket_fim_emif_axi_mm/map_fim_emif_axi_mm_to_local_mem.sv:44,74`). This is an undriven-input source defect, not a numeric width conflict.

The narrowest defined-default proposal is to tie the two subsystem-facing QoS fields to `'0` in the FIM mapping when these members are present. If QoS propagation is desired instead, both FIM and PIM mappings must be completed; adding only the FIM assignments propagates the PIM's undriven values. Do not equate this proposal with validated arbitration behavior. No edit is made.

### 3. PIM USER-width source is inconsistent with the exposed request fields

`C/src/top/ofs_agilex.ini:54–69` selects native AXI, bank count from `NUM_MEM_CHANNELS`, and **`user_width=ofs_fim_mem_if_pkg::AXI_MEM_WUSER_WIDTH`**. Raw mem_ss has no WUSER, so the package fallback is 1 (`M/includes/ofs_fim_mem_if_pkg.sv:51–55`). PIM adds its one-bit `LM_AXI_UFLAG_NO_REPLY` field (`P/native_axi/local_mem_GROUP_cfg_pkg.sv:38–41`; `P/afu_ifcs/axi/ofs_plat_local_mem_axi_mem_pkg.sv:13–25`), yielding a **two-bit native PIM USER field** with this configuration. The FIU interface instantiates that width through `P/afu_ifcs/ofs_plat_local_mem_GROUP_axi_mem.vh:58–65` and `P/native_axi/ofs_plat_local_mem_GROUP_fiu_if.sv:29–36`.

The gasket directly assigns PIM AW/AR `.user` to 14-bit FIM AWUSER/ARUSER (gasket:45,75); therefore it cannot convey all 14 request bits, and the upper 12 bits are extension rather than independently expressible metadata. BUSER is one bit and RUSER is fabricated zero by `M/mem_ss_top.sv:341`, so a single symmetric USER setting cannot be assumed semantically equivalent across channels. PIM's internal NO_REPLY flag must not be mistaken for an EMIF command bit.

This is a source-derived width/semantic mismatch **if this INI/template path is selected**, not a claim about a captured generated PIM. Obtain the active generated PIM config and field layout, plus the modern MSA definition of AWUSER/ARUSER/BUSER. Then choose explicit board-scoped adaptation/ties or justified parameterization. Merely changing `user_width` from WUSER to AWUSER is not yet a justified fix: it also changes the PIM flag layout and response field widths.

Other PIM dimensions are consistent in source: expected two banks, data 512, IDs 9; line-address width is 28 and the native AXI package restores it to 34 byte-address bits (`local_mem_GROUP_cfg_pkg.sv:31–36`). The INI encodes burst count as 9 bits and the AXI macro subtracts one, restoring 8. These transformations are not address/burst mismatches.

### 4. CSR absent by configuration; enabled-clock/reset questions remain open

The raw boundary has no CSR ports and HTML explicitly disables the interface. Thus absence of `HAS_IFC_MEM_SS_CSR_AXI_LITE_IF` should select the existing outer FIM DFH/status route in `M/mem_ss_top.sv:168–184`. It does **not** restore the legacy subsystem CSR bank at memory-local `0x800`. This is a deliberate current configuration gap relative to vendor diagnostics, not a missing wire that can be connected on this wrapper.

The guarded open `.csr_app_ss_lite_aclk()`/`.csr_app_ss_lite_areset_n()` at 264–265 are not active ports in this snapshot. Their direction, width and association for an enabled configuration remain unproven; the current snapshot cannot justify tying them to CSR clock/reset. Retain the earlier CSR review prerequisites for modern register semantics, MSA `CSR_EN` versus legacy `DIAG_ENABLE_CSR`, and the existing 11-bit subsystem aperture. Do not enable CSR, invent an MMR aperture, or define presence macros by hand.

### 5. Reset/status names agree; timing/association does not follow from names

The four raw reset directions match `rst_hs` usage at `M/mem_ss_top.sv:149–165`. The FIM synchronizes board reset to physical refclk 0 (108–118), maps refclk/OCT by index (78–83), forwards each generated user clock/reset (295–296), and resynchronizes calibration status to CSR clock (120–147). The PIM gasket registers each bank's reset for one user-clock cycle (24–31). No name/polarity correction is demonstrated here.

Still check generated reset-controller clock association, readiness/ack protocol, clock availability during cold reset, and whether application clocks/status correspond to the intended one-to-one physical connections. HTML connection vectors support configuration intent, not complete internal wiring verification. Do not infer calibration-bus ordering from wrapper groups or two models. Do not enable `SIM_MODE_NO_MSS_RST` to conceal an unresolved handshake.

## Next evidence, in priority order

1. Preserve this interim snapshot; separately capture final run outcome and errors. Overall BMC failure and incomplete generation prohibit acceptance even if memory files exist.
2. Under separately authorized execution only, collect the actual OFS SV wrapper, interface-info/IP-parameter headers, aggregate/local-memory headers and producer log bound to the same saved IP. Check exact ports, roles, direction, widths, group sizes/index maps and API list values. This review requests evidence; it does not authorize running that stage.
3. Reconcile the physical pin targets with the emitted scalar members/group map, and reconcile independent simulation-model selection with each physical channel. Keep all coordinates fixed unless separate board evidence justifies a change.
4. Review the QoS default fix and PIM USER adaptation separately. Capture the selected generated PIM bank/width configuration and authoritative MSA user-bit semantics before proposing ABI changes.
5. Check generated internal reset/clock/status associations and, only if CSR enablement is separately intended and proven, enabled CSR/register semantics. Later authorized elaboration/connectivity checks must detect undriven inputs and width conversion; none was performed here.

## Current source bindings retained

These hashes were calculated from the inspected local files, not substituted for original donor identities:

| Source | SHA-256 |
|---|---|
| `M/mem_ss_top.sv` | `7211a02c56ba18d8bc58c749de56242c3e1eb3c94e8c92d84c42a742cf04618c` |
| `G/mem_ss_get_cfg.tcl` | `918fb1d93dc73828de06d5d331fe65debdf586b8c9973fa00a7290837c2eabb1` |
| `G/ip_gen_sv_wrapper.tcl` | `3db40a80626db64e217a60bfd97022bfdc10187f0a2d559c6c99120a486da190` |
| `C/src/top/ofs_agilex.ini` | `3518f0bdabd3004e3e8920745056640db7783f6dc95f233cc50f8b61c48d5b54` |
| `C/syn/board/ia840f/setup/emif_loc.tcl` | `44fdb76902f22b83df265da656f531fca9d5abe61a74c696190b5465c0da579d` |

The inspected current board gate still explicitly sets `ia840f_ready_for_build false`. No bound source was edited and no qualification was promoted.

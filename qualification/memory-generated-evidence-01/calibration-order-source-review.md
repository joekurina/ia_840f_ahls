# Calibration ordering: donor versus generated source review

**Disposition: wiring discrepancy confirmed; electrical incompatibility not established; no supported calibration remap established.** Existing derivation preserves bottom-block membership but does **not** preserve or assert the donor's per-controller calibration-bus suffix. The smallest next action is the finite, read-only installed-source capture described in `calibration-source-lookup.json`, not an HDL, pin, channel-order or preset edit.

## Scope and evidence notation

`N=/home/joe/Projects/Thesis/AHLS/new_bsp/new`; paths below are relative to N unless prefixed `D/`. `D=../old_bsp/ia-840/IOFS_BUILD_ROOT/ofs-ia840f`. `F<n>:line` denotes decoded `files[n].content` in `qualification/memory-generated-evidence-01/memory-artifacts.json`, not a line of the JSON container. Full original paths and hashes are in that receipt and `generated-memory-correction-proposal.json:evidence_manifest`.

Read the prior review, especially lines 33–44, and companion proposal. Independently recomputed payload byte counts and SHA-256: **87 matching full-text payloads**. The receipt remains finite and incomplete: 99 records, 12 missing. Receipt SHA-256 is `a333f976a8f95024b37ad918051b379c3922bd66b91e123e09fc575e95eb60ae`. These checks are static evidence validation, not execution tests or IP acceptance.

No remote access, installation scan, vendor/Tcl execution, tests, build, simulation or commit. Only this new review and the new lookup request are owned outputs. No board/source/pin/topology/manifest/readiness changes are authorized or made.

## 1. Physical identity and connection ordering

| Identity | Donor | Generated 26.1.1 receipt |
|---|---|---|
| Physical 0, discrete/P1 component memory | `intf_0.mem` exported as `mem0_ddr4`; bottom `emif_calbus_1` feeds `intf_0.emif_calbus` | `emif_0` drives `mem0_ddr4_*`; `emif_cal_bot.emif_calbus_0` feeds it |
| Physical 1, RDIMM | `intf_1.mem` exported as `mem1_ddr4`; bottom `emif_calbus_0` feeds `intf_1.emif_calbus` | `emif_1` drives `mem1_ddr4_*`; `emif_cal_bot.emif_calbus_1` feeds it |

Exact donor references:

- `D/ipss/mem/qip/mem_ss/mem_ss_fm_0.qsys:15850,15884` exports `intf_0.mem` and `intf_1.mem` to the corresponding physical port names. Lines 15522 and 15543 connect `msa_0/1.ctrl_amm` to corresponding `intf_0/1.ctrl_amm_0`.
- Same Qsys:15632–15645 explicitly connects **bus0 to intf1, bus1 to intf0**. Lines 15606–15607 distribute the same bottom calibration clock to both.
- `D/ipss/mem/rtl/mem_ss_top.sv:223–261` wires mem0/mem1 to `ddr4_no_ecc[0/1]`; `D/src/top/top.sv:1171–1184` connects that array to board `ddr4_mem`. Stale width/disabled-channel comments do not override live connections and saved format parameters.
- `D/ipss/mem/qip/mem_ss/ip/mem_ss_fm_0/mem_ss_fm_0_intf_0.ip:5846–5849` saves discrete format; sibling `mem_ss_fm_0_intf_1.ip:5769–5772` saves RDIMM format.

Exact generated references:

- F61:205–248 associates EMIF0 with mem0 physical/refclk/OCT ports and calbus0; F61:261–302 associates EMIF1 with mem1 and calbus1.
- F61:315–328 confirms **return data and each 4096-bit sequence-parameter table** follow the same controller as read/write/address/data, so this is not just an output-net naming discrepancy.
- F86:15344–15416 independently serializes the direct calibration connections. F66/F72:6041–6044 respectively save `MEM_FORMAT_DISCRETE` and `MEM_FORMAT_RDIMM`.
- F57:7–18,22–36 exposes both calibration buses and forwards them into `altera_emif_cal_280_kyo6ogi`; it is a wrapper, not the implementation that interprets controller indices or parameter tables.

The new board's source boundary remains conditional on generated OFS interfaces: `ofs-agx7-pcie-attach/src/board/ia840f/top.sv:46–54` and `ofs-agx7-pcie-attach/ofs-common/src/fpga_family/agilex/mem_ss/mem_ss_top.sv:262–290`. Missing OFS exports prevent claiming fitted physical grouping. They do not undo the raw generated controller/physical-port association above.

### Physical-location evidence has a defined limit

The candidate preset saves `MEM_INTFS_LOCATION=BOT,BOT` (`ofs-agx7-pcie-attach/ipss/ia840f/presets/ia840f_mem.qprs:40`; F6:3838–3841). The donor connects both controllers to the bottom-named calibration component. This proves source placement intent/block membership, **not a fitted I/O-column coordinate or a physical meaning for calbus suffix 0/1**.

Pin anchors preserve physical identity independently of suffixes:

| Signal | Discrete 0 | RDIMM 1 |
|---|---|---|
| Reference positive | HF23 | HH48 |
| Explicit reference negative | HH22 | Not assigned in the selected donor source |
| OCT | HB23 | GW48 |
| CS | HB29 | GW42 |

References: `D/syn/setup/emif_loc.tcl:37,39,57,159–160,172,192`; candidate `ofs-agx7-pcie-attach/syn/board/ia840f/setup/emif_loc.tcl:12,14,32,124–125,136,155`. Do not infer a bank/column ordering from package coordinates, invent the RDIMM negative reference pin, or exchange the physical channels.

## 2. What calibration metadata does and does not establish

- Donor bottom calibration IP is `altera_emif_cal` 2.7.0 (`D/.../mem_ss_fm_0_emif_cal_location_bottom_row.ip:451–452`). Its `AXM_ID_NUM=0` is labelled **AXI ID**, and `NUM_CALBUS_INTERFACE=2` is labelled **Number of Calibration Interfaces** (same file:456–464). Neither label establishes a controller permutation.
- Generated calibration is `altera_emif_cal` 2.8.0, with `AXM_ID_NUM=0` (hidden) and `NUM_CALBUS_INTERFACE=2` (visible): F78:81–107. Its nested `altera_emif_cal_iossm` 2.8.0 is identified at F78:480–488. `NUM_CALBUS_USED=2` is derived (F78:531–538), and `SEQ_GPT_COLUMN_ID=1` is derived (F78:627–634).
- `SEQ_GPT_COLUMN_ID=1` alone cannot be equated with board physical channel1 or calbus1. There is one captured bottom calibration block serving both controllers. The source deriving this field and the consuming implementation are not captured here.
- Generated EMIF0/1 are `altera_emif_fm` 2.8.0 (F65/F71:5–8). Both have `EMIF_0_CONN_TO_CALIP=CALIP_0` (F66/F72:17953–17960); parsed `EMIF_0` through `EMIF_15_CONN_TO_CALIP` all equal `CALIP_0`, as in both donor EMIF IPs. These fields do not distinguish the observed bus permutation. Do not treat a Cal-IP selector as a proven calbus-suffix override.
- Both generated EMIF architecture metadata sets contain identical primary/secondary tile/lane index values (F66:39216–39295; F72:39092–39171). These are not evidence assigning each board channel to a different absolute package location.
- Donor calibration automatic metadata names `AGFA006R16A2E1V`; generated F78:197–200 names target `AGFB027R25A2E2V`. Derivation deliberately excludes `AUTO_DEVICE*`. Do not transplant stale donor device metadata to force numbering.

Consequently, the **literal donor association is not preserved**, but numeric suffix equivalence across the donor's 23.1 connection schema and generated 26.1.1/2.8.0 implementation is unresolved. Whole-bus and sequence-table consistency is observed; successful calibration, sequencing equivalence, physical controller-index equivalence and electrical failure are all unproven.

## 3. Derivation audit: the missing mapping is explicit

Source: `ofs-agx7-pcie-attach/ipss/ia840f/derive_presets.py`.

1. Lines 62–65 read both donor EMIFs, MSAs and bottom calibration IP.
2. Lines 67–72 parse donor connections, but assert only that each `intf_i.emif_calbus` starts with `emif_cal_location_bottom_row.`. The predicate never checks the trailing `emif_calbus_0` versus `emif_calbus_1`. **It would accept either permutation.** This is static inspection of the predicate, not an executed mutation test.
3. Lines 75–83 set `BOT,BOT`, two DDR4/storage interfaces and modern application identity vectors. `MEM_CH_0_CONNS=1,0` and `MEM_CH_1_CONNS=0,1` are not a recorded calibration-index mapping.
4. Lines 84–90 whitelist donor EMIF fields through modern reference leaf names and exclude automatic metadata. Lines 110–115 copy only whitelisted bottom-calibration fields.
5. `preset_derivation.json:2876–2879` records location as “vendor bottom calibration connections” and connections as the modern two-storage-channel identity mapping. It does not record the donor bus suffix permutation.

Parsed candidate preset contains neither `mem_ss|emif_cal_bot|AXM_ID_NUM` nor `mem_ss|emif_cal_bot|NUM_CALBUS_INTERFACE`. Other omitted donor calibration fields are `ENABLE_DDRT`, `PHY_DDRT_EXPORT_CLK_STP_IF` and automatic device fields. The preset's bottom-calibration entries are diagnostic/name fields (`ia840f_mem.qprs:2891–2898`). Thus the earlier statement that donor cardinality is not explicitly transplanted is correct. **Its omission is not a demonstrated cause:** generated cardinality is already two, and generated AXM ID already equals donor zero. The significant unpreserved source relation is the Qsys connection's indexed start endpoint, not a proven missing numeric controller-index parameter.

No explicit per-controller calibration-index mapping was found in the derivation or emitted preset. No source edit is proposed merely to reproduce a number whose implementation meaning is unresolved.

## 4. Saved controls versus supported correction

Observed configuration surface:

- `RUN_COMPOSE=true`, displayed as “Generate IPs within Subsystem” in F6:3828–3831; candidate preset:42.
- `MEM_INTFS_TYPE=DDR4,DDR4`, `MEM_INTFS_LOCATION=BOT,BOT`, `APP_INTFS_TYPE=STORAGE,STORAGE`; application identity vectors at preset:5,20,31,40–42 and F6:3833–3856.
- Leaf calibration interface count and diagnostic controls described above.

These are **saved controls**, not evidence of a supported arbitrary calibration-order override. The local saved areas contain no identified `mem_ss_hw.tcl`, `altera_emif_cal_hw.tcl`, or captured memory composition callback implementation. Existing installed-source receipts inspected are mailbox/tool discovery, not the missing memory routine. The generated QIPs identify the active kinds and versions but do not establish source callback semantics. No evidence here supports changing `RUN_COMPOSE`, stuffing `DIAG_EXTRA_PARAMETERS`, changing AXM ID/cardinality, or swapping `MEM_CH_*_CONNS` to repair calibration wiring.

## 5. Smallest next action and stop condition

**Separately authorize one capped static capture of the memory-subsystem descriptor, parameter declaration and calibration-connection composition routine from the recorded 26.1.1 installation.** Inspect how it allocates a per-location calbus counter, orders EMIF instances, forwards calibration parameters and derives physical-location metadata. Capture the EMIF calibration descriptors only within the same finite name/path budget if needed. The companion JSON gives exact roots, finite nonrecursive glob patterns, byte/file limits, search terms and stop conditions. Candidate filenames are explicitly lookup patterns, not claims of file existence.

If composition simply enumerates BOT controllers in ascending instance order, that explains the direct output but does not prove electrical equivalence or authorize overriding it. A supported correction requires an actual documented/declared control with a traced implementation; semantic equivalence requires evidence linking bus slots, per-controller sequence tables and physical calibration addressing. If relevant definitions lie outside the finite batch, report exact source references and stop for a newly reviewed request—do not chase recursive dependency closure.

Until then retain the donor-association qualification requirement as unresolved. Preserve all pins, discrete/RDIMM identities, application topology, generated HDL and readiness gates.

## Source bindings

| Local input | SHA-256 |
|---|---|
| `ofs-agx7-pcie-attach/ipss/ia840f/derive_presets.py` | `a41dbb3a23bd2153f128c994f8ccf68eeae03676543b16b05e19da4bf06c88f5` |
| `ofs-agx7-pcie-attach/ipss/ia840f/preset_derivation.json` | `e58e146ea0ec90e1a2528ddffdba2553339f4168dadda0b109574844c41d2d06` |
| `ofs-agx7-pcie-attach/ipss/ia840f/presets/ia840f_mem.qprs` | `26cf53d439221fc7a9cd6ecaef55c232945df9ab38883499dfb63d1d78841c1e` |
| `D/ipss/mem/qip/mem_ss/mem_ss_fm_0.qsys` | `49ac14b0a1b6e1dd2cf419f4fe9033261f29c8e3b8a29b23fc697632049c083f` |
| F61 nested synthesis HDL | `418804c91789aa650b3679ce69a6a30258a93185d8d6fd76a2304cc9a9a4d45f` |
| F78 calibration SOPC metadata | `00ba2b2a2ccf6677ee7eb70590cf4b972f19b03133504757702be3d73e1e11ec` |
| F86 nested SOPC metadata | `b38e5977cca192148ca335cae7034fc80c2dc35d506f03b6fd100f8897029fcc` |

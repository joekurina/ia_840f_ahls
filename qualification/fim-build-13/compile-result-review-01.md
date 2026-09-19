# W13 FIM Compile Result Review — compile-result-review-01

Independent read-only review of the finished W13 IA-840F FIM compile vs the accepted W12 baseline.

- **W13 tree**: `/home/uwb_student00/ahls/new_BSP/work_ia840f_fim_13/syn/board/ia840f/syn_top/output_files/` — finished 2026-09-19T23:16Z, rc 0, 0 errors / 978 warnings.
- **W12 baseline**: `/home/uwb_student00/ahls/new_BSP/work_ia840f_fim_12/syn/board/ia840f/syn_top/output_files/` — same static region; stock exerciser AFU; its single −0.004 ns EMIF PHY hold violation was reviewed and ACCEPTED.
- **W13 delta**: AHLS AFU (accelerator-type-uuid `67bc266a-56f7-440a-bb75-12b5f446d842`) in the PR slot via `afu.tcl`; FME_IFC_ID retargeted to `c281e23b-5a95-5aa9-8678-d2ecf1f80f6c`.
- Toolchain both: Quartus Prime Pro 26.1.1 Build 130, part AGFB027R25A2E2V, Timing/Power Models Final.

---

## Check 1 — STA (ofs_top.sta.rpt / ofs_top.sta.summary) — **PASS**

Per-clock worst slack from `ofs_top.sta.summary` (17 setup + 17 hold clock entries in **both** builds; clock name sets identical, no clocks added or removed).

### Setup slack (ns), W12 → W13

| Clock | Freq | W12 | W13 | Δ |
|---|---|---:|---:|---:|
| sys_pll\|iopll_0_clk_sys | 470 MHz | 0.139 | **0.185** | +0.046 |
| pcie\|…xcvr_hip_native\|rx_ch15 | — | 0.093 | 0.206 | +0.113 |
| mem_ss\|emif_1\|emif_1_core_usr_clk | 333.33 MHz | 0.443 | 0.443 | +0.000 |
| mem_ss\|emif_0\|emif_0_core_usr_clk | 333.33 MHz | 0.637 | 0.635 | −0.002 |
| mem_ss\|emif_1\|emif_1_phy_clk_l_0 | 333.33 MHz | 0.652 | 0.652 | +0.000 |
| mem_ss\|emif_0\|emif_0_phy_clk_l_0 | 333.33 MHz | 0.690 | 0.692 | +0.002 |
| uclk\|iopll_0_outclk0 (user clk) | 312.5 MHz | 2.730 | 2.766 | +0.036 |
| uclk\|iopll_0_outclk1 (user clk) | 156.25 MHz | 5.963 | 4.919 | −1.044 |
| mem_ss\|emif_0\|emif_0_phy_clk_0 | 666.66 MHz | 2.473 | 2.226 | −0.247 |
| mem_ss\|emif_1\|emif_1_phy_clk_0 | 666.66 MHz | 2.534 | 2.534 | +0.000 |
| sys_pll\|iopll_0_clk_100m | 100.71 MHz | 0.851 | 1.098 | +0.247 |
| sys_pll\|iopll_0_clk_sys_div2 | 235.0 MHz | 3.934 | 3.939 | +0.005 |
| sys_pll\|iopll_0_clk_sys_div4 | 117.5 MHz | 8.197 | 8.069 | −0.128 |
| altera_int_osc_clk | — | 2.032 | 2.051 | +0.019 |
| mem_ss\|emif_0\|emif_0_ref_clock | 33.33 MHz | 28.879 | 28.859 | −0.020 |
| altera_reserved_tck | — | 42.381 | 43.620 | +1.239 |
| bwbmc_fpga_max_sclk | — | 86.844 | 86.888 | +0.044 |

- **Setup met on every clock in both builds.** W13 worst setup **+0.185 ns** (`sys_pll|iopll_0_clk_sys`, Slow vid2b) — exactly the briefed expectation. No setup regression below W12's worst (+0.093).

### Hold slack (ns), W12 → W13 (all non-violating clocks ≥ 0 in both)

| Clock | W12 | W13 | Δ |
|---|---:|---:|---:|
| mem_ss\|emif_1\|emif_1_phy_clk_l_0 | **−0.004** | **−0.004** | +0.000 |
| mem_ss\|emif_1\|emif_1_core_usr_clk | 0.000 | 0.000 | +0.000 |
| mem_ss\|emif_0\|emif_0_core_usr_clk | 0.001 | 0.001 | +0.000 |
| pcie\|…rx_ch15 | 0.041 | 0.001 | −0.040 |
| sys_pll\|iopll_0_clk_sys | 0.004 | 0.006 | +0.002 |
| uclk\|iopll_0_outclk1 | 0.101 | 0.007 | −0.094 |
| uclk\|iopll_0_outclk0 | 0.089 | 0.102 | +0.013 |
| sys_pll\|iopll_0_clk_100m | 0.014 | 0.007 | −0.007 |
| altera_int_osc_clk | 0.020 | 0.011 | −0.009 |
| mem_ss\|emif_0\|emif_0_ref_clock | 0.023 | 0.011 | −0.012 |
| mem_ss\|emif_0\|emif_0_phy_clk_l_0 | 0.101 | 0.103 | +0.002 |
| mem_ss\|emif_1\|emif_1_phy_clk_0 | 0.354 | 0.354 | +0.000 |
| mem_ss\|emif_0\|emif_0_phy_clk_0 | 0.484 | 0.632 | +0.148 |
| bwbmc_fpga_max_sclk | 0.557 | 0.549 | −0.008 |
| sys_pll\|iopll_0_clk_sys_div2 | 0.095 | 0.095 | +0.000 |
| sys_pll\|iopll_0_clk_sys_div4 | 0.098 | 0.107 | +0.009 |
| altera_reserved_tck | 0.090 | 0.091 | +0.001 |

- **Single violating entry in each build**, identical: hold **−0.004 ns** on `emif_1_phy_clk_l_0`. `grep 'Slack : -'` over both full summaries returns exactly one hit each (line 91 in both).
- **Same path/cone, verified from ofs_top.sta.rpt in both builds** (the only "VIOLATED" path report in each):
  - From: `…emif_1|arch|arch_inst|hmc.amm.amm.data_if_inst|amm_writedata_0_r[0][243]`
  - To: `…emif_1|arch|arch_inst|io_tiles_wrap_inst|io_tiles_inst|tile_gen[2].lane_gen[1].lane_inst|lane_inst~phy_r…`
  - Launch `emif_1_core_usr_clk` → Latch `emif_1_phy_clk_l_0`, Fast vid2 100C.
  - From/To nodes, launch/latch clocks and slack are **byte-identical between W12 and W13** → this is the W12-accepted 4 ps EMIF PHY hold violation, not a new cone. (Vendor-IP acceptance standard applies: no requalification of EMIF internals behind the hardware data-check gate.)
- Small hold-slack motion on other clocks (e.g. pcie 0.041→0.001, uclk/outclk1 0.101→0.007) stays non-negative; consistent with re-placement of the AFU-adjacent fabric, not new analysis cones.

### Unconstrained clocks/pins vs W12 (identical, known-open W12 lineage)

| Unconstrained | W12 | W13 |
|---|---:|---:|
| Unconstrained clocks | 1 | 1 |
| Unconstrained input ports | 2 | 2 |
| Unconstrained output ports | 2 | 2 |
| Paths from unconstrained inputs (pairs-only) | 78 | 78 |
| Paths to unconstrained outputs (pairs-only) | 10 | 10 |

The one unconstrained clock is the same in both: `pcie_wrapper|…|u_pciess_clock_divider|clkdiv_inst~div_reg`. Unconstrained-port path families (protocol_checker_csr timeout CSRs, MSI-X dcfifo pointers, cpl_metering sync) are the same entries in both reports.

**Check 1 result: PASS** — no new violating clock vs W12; setup met everywhere; hold violation identical (same clock pair, same endpoints) to the accepted W12 EMIF PHY 4 ps violation; unconstrained counts unchanged.

---

## Check 2 — Fitter utilization (ofs_top.fit.summary / ofs_top.fit.rpt) — **PASS**

| Resource | W12 | W13 | Δ |
|---|---:|---:|---:|
| Logic utilization (ALMs) | 78,716 (9%) | 66,380 (7%) | −12,336 |
| Total dedicated logic registers | 217,766 | 176,152 | −41,614 |
| Total block memory bits | 2,136,140 | 1,553,884 | −582,256 |
| Total RAM blocks (M20K) | 372 (3%) | 302 (2%) | −70 |
| Total DSP blocks | 0 | 12 | +12 |
| Total pins | 321 (36%) | 321 (36%) | **0** |
| HSSI P-Tiles | 1 | 1 | 0 |
| PLLs | 8 | 8 | 0 |

- **All deltas are AFU-attributable.** Fitter "Resource Utilization by Entity": the `afu_top` subtree shrank 46,715.1 → 34,469.5 ALMs (−12,245.6), which accounts for essentially the entire chip-level ALM delta (−12,336); the adjacent static `afu_intf_inst` is unchanged (2,759.8 → 2,761.8). W13's PR region contains the AHLS persona (`port_afu_instances|ofs_plat_afu|ahls_binding` with `tlp_as_avalon_mem`/`tlp_mapper`, plus `qual_vec_op_k0` HLS kernels); W12's contained the stock exerciser (`port_afu_instances` exerciser, PCIE_FREEZE_BRIDGE pipelines, no DSP). The exerciser's heavy traffic generators/BRAMs being replaced by the leaner AHLS AFU explains ALM/register/BRAM **decreases**; the 12 DSPs are new math in the AHLS kernel (syn.summary "Estimated DSP Blocks Post-Merging: 12").
- **I/O pins identical**: Total pins 321 in both, and `ofs_top.pin` is **byte-identical** between W12 and W13 (`cmp` clean). Memory pins preserved: 242 `ddr4_mem*` rows (236 `ddr4_mem[0]/[1]` interface pins — 118 per instance — plus 6 `ddr4_mem_ref_clk` rows: 2 ref clks + 2 (n) legs + 2 oct_rzqin), same in both.
- **Fitter status**: "Successful" in both. **Zero Error lines in either native.log.** No `PRESERVE_UNUSED_XCVR_CHANNEL`-class errors: both logs show only the benign Info messages `(21650) REFCLK qsfp_ref_clk … used to preserve unused channels`, `(24608)/(24609) Preserved 44 unused RX/TX channel(s)` — identical counts in W12 and W13.

**Check 2 result: PASS** — utilization deltas explained entirely by the AFU persona swap; pins byte-identical; no new fitter errors.

---

## Check 3 — Assembly / PR / persona wiring — **PASS**

Artifacts in W13 `output_files/` (sizes):

| File | Size |
|---|---:|
| ofs_top.sof | 7,846,742 B |
| ofs_top.green_region.rbf | 6,909,952 B |
| ofs_top.green_region.pmsf | 7,196,318 B |
| ofs_top.static.msf | 3,276,373 B |

- **PR slot is reconfigurable**: Fitter Partition Summary (both builds) lists `green_region` at hierarchy `afu_top|pg_afu.port_gasket|pr_slot|afu_main` with Type **Reconfigurable**; `root_partition`, `auto_fab_0`, `auto_fab_1` are Default. `ofs_top.asm.rpt`: "Generate Partial Reconfiguration Raw Binary File (.rbf) … On"; `Info (20553): Using PR Region: ofs_top.green_region Hash 029634CD…`; final snapshots loaded for root_partition/green_region/auto_fab_1/auto_fab_0; native.log tail confirms `Partition "root_partition" is exported` and `Partition "auto_fab_0" is exported`.
- **Persona UUID wiring (AHLS AFU)**:
  - `ofs_pr_afu.json`: `accelerator-type-uuid = 67bc266a-56f7-440a-bb75-12b5f446d842` (W12: `222baa4c-0ab8-4574-bf74-aa35b945a223`, the stock exerciser).
  - `afu_with_pim/afu.tcl` documents UUID 67bc266a-…; generated `afu/hw/afu_json_info.vh` carries `` `define AFU_ACCEL_UUID 128'h67bc266a_56f7_440a_bb75_12b5f446d842 ``.
  - **FME_IFC_ID update**: native.log `update_fme_ifc_id.py` — `Updating ::env(FME_IFC_ID) from "f833fdf5-533f-5f77-80c9-f0a5c2f065df" to "c281e23b-5a95-5aa9-8678-d2ecf1f80f6c"`, followed by a recompile explicitly triggered by the changed `fme_id.mif`. W13 `fme_id.mif` words 02/03 = `8678d2ecf1f80f6c` / `c281e23b5a955aa9` (little-endian c281e23b-5a95-5aa9-8678-d2ecf1f80f6c); W12's encoded f833fdf5-…. Matches the briefed log note (c281e23b-…).
- `green_region.rbf` smaller than W12's (6.91 MB vs 8.46 MB), consistent with the smaller AHLS persona — expected for a PR-region-only image; the static FIM (sof/msf) is unaffected in pin behavior.

**Check 3 result: PASS** — SOF + green-region RBF present; PR slot reconfigurable; AHLS persona UUID wired through ofs_pr_afu.json → afu.tcl → afu_json_info.vh, and FME_IFC_ID/fme_id.mif updated to c281e23b-….

---

## Check 4 — Gate evidence (run/status.json, invocation.json, authorization) — **PASS**

| Item | Value | Match |
|---|---|---|
| status.json state | `finished` (started 2026-09-19T22:24:04Z, ended 23:16:16Z) | ✓ briefed 23:16Z |
| native_returncode | `0` | ✓ rc0 |
| gate_rejection | `false` (native_exit_accepted `true`, accepted_execution `true`) | ✓ |
| invocation argv | `./ofs-common/scripts/common/syn/build_top.sh --stage=compile -k -p ia840f /home/uwb_student00/ahls/new_BSP/work_ia840f_fim_13` | ✓ = authorization `native_argv` |
| invocation cwd | `/home/uwb_student00/ahls/new_BSP/ofs-agx7-pcie-attach` | ✓ = authorization `native_cwd` |
| authorization_sha256 (recorded) | `204cd46e869b7d78ef8978ac01ac88b19cd99f5f7a6e6152de2a1d8fadc51df1` | ✓ = briefed sha 204cd46e… |
| **Recomputed** sha256 of `compile-authorization.json` | `204cd46e869b7d78ef8978ac01ac88b19cd99f5f7a6e6152de2a1d8fadc51df1` | ✓ record matches file |
| native-compile.claim.json | `record_sha256` = same sha, pid 210823 | ✓ |
| Authorization content | approved true; part AGFB027R25A2E2V; Quartus 26.1.1 Build 130; permissions `native-full-compile`; work = work_ia840f_fim_13 | ✓ |

**Check 4 result: PASS** — evidence chain intact; argv/cwd bind to the issued authorization; sha independently recomputed and matching.

---

## Check 5 — Warnings triage (978 warnings) — **PASS**

- **Official totals**: W13 `Quartus Prime Full Compilation was successful. 0 errors, 978 warnings`; W12: `0 errors, 948 warnings`. Delta +30, no errors in either.
- **Warning-ID families identical**: the set of distinct `Warning (NNNNN)` IDs in native.log is **identical** between W12 and W13 (set difference empty in both directions — no new warning family introduced, none removed). Count shifts within families only, e.g. 13469 (245→184), 332174 (100→160), 21610 (149→156), 13410 (5→49 — AFU-source timing-assignment notes); top family 332049 unchanged at 401.
- **Critical Warnings: 4 in each build, same IDs and text** — (19854) explicit initial values in Partition green_region; (20727) PR/Reserved-Core partitions with unused input ports; (332148) Timing requirements not met; "DDR Timing requirements not met" — i.e. the accepted 4 ps EMIF hold path. **No new Critical Warnings vs W12.**
- Per-stage (final pass): Synthesis 81 vs 32, Fitter 222 vs 202, Timing Analyzer 260/201 vs 240/181, Assembler 1 vs 1, IP-gen/MIF 0 — growth concentrated in synthesis/fitter where the AHLS AFU sources entered; consistent with the persona swap.

**Check 5 result: PASS** — counts and families consistent with W12 + AHLS AFU swap; no new critical warnings.

---

## Summary table

| # | Check | Result |
|---|---|---|
| 1 | STA per-clock vs W12 (setup met, hold = same accepted EMIF PHY path, unconstrained counts) | **PASS** |
| 2 | Fitter utilization deltas AFU-attributable; pins byte-identical; no XCVR-preserve errors | **PASS** |
| 3 | SOF/RBF present; green_region Reconfigurable; persona UUID + FME_IFC_ID wiring | **PASS** |
| 4 | Gate evidence: finished/rc0/no rejection; argv/cwd/sha bind to authorization 204cd46e… | **PASS** |
| 5 | Warnings: 0 err/978 warn, same ID families, same 4 critical warnings | **PASS** |

Worst setup **+0.185 ns**; worst hold **−0.004 ns** (W12-accepted EMIF PHY path, verified identical endpoints/clock pair); **no new violating timing cone vs W12**.

VERDICT: ACCEPT

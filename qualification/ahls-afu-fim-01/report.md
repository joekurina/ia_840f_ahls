# ahls-afu-fim-01 — AHLS AFU → FIM PR-slot static verification (COMPLETE)

**Result: PASS — `quartus_syn --analysis_and_elaboration` rc=0, 0 errors** (Quartus
Prime Pro 26.1.1, `Info: Quartus Prime Synthesis was successful. 0 errors, 1 warning`),
with the full AHLS AFU hierarchy (binding + generated kernel) confirmed elaborated
and all binding parameters verified in the A&E report.

## Recovery summary

A prior subagent (deleg_efe1c772) died 2026-09-19 ~13:34 local after authoring the
integration files and running A&E attempts 1–3. Its artifacts were recovered as the
baseline:

- **Local (authoritative, verified byte-identical to remote):**
  `src/afu.tcl`, `src/ofs_plat_afu.sv` (complete, 244 lines — the file being written
  at death is finished and clean), `src/ofs_pr_afu.json`, `src/ahls_qual_vec_op.json`,
  `src/gen_ahls_filelist.py`. Hashes in manifest.json.
- **Remote:** `B/work_ahls_afu_fim_01/` survives intact (root file copies, `awp/`
  attempt-3 project with `afu_with_pim/` tree, `logs/` with all attempt logs).
- The dead child's transcript was mined for intent; its geometry derivations
  (byte-agent widths, USER_WIDTH ≥ 14, BURST_CNT_WIDTH) were spot-checked against
  the Work12 PIM sources and found correct — kept as authored.

## Diagnosis (why 889 errors)

Attempt 3 failed with 889 errors that looked like a missing PIM platform layer, but
decomposed as a single systematic cascade with a different precise root:

| Code  | Count | Meaning |
|-------|-------|---------|
| 16827 | 24    | `ofs_ip_cfg_db.vh` cannot open 6 generated includes (`pcie_ss_if_info.vh`, `pcie_ss_ip_params.vh`, `sys_pll_if_info.vh`, `sys_pll_ip_params.vh`, `mem_ss_if_info.vh`, `mem_ss_ip_params.vh`) — **root cause** |
| 13406 | 671   | downstream "object not declared" (dead `top_cfg_pkg`/`ofs_fim_cfg_pkg` → `sys_pll_pkg` undefined, etc.) |
| 13363 | 171   | downstream "package ignored due to previous errors" |
| 17457 | 12    | downstream "range must be bounded by constant expressions" (the visible symptom named in the handoff) |
| 17081 | 1     | downstream constant-function failure |

Root cause: `top_cfg_pkg.sv` and `ofs_fim_cfg_pkg.sv` (Work12 FIM context) both
`include "ofs_ip_cfg_db.vh"`, which includes six per-subsystem generated `.vh` files
that live in three `sv_wrapper` directories Work12 generated at IP-generation stage
(`ipss/pcie/qip/sv_wrapper`, `ofs-common/.../sys_pll/sv_wrapper`,
`ipss/mem/qip/mem_ss/sv_wrapper`). The standalone AFU project's QSF had none of them
on its include path. **The PIM platform layer itself (ofs_plat_if tree, copied from
Work12 under `awp/afu_with_pim/afu/build/platform/`) was present and correct all
along — reusing it (fix-ladder option 1) was already done by the prior child.**

## Fix chosen — fix-ladder option 1 (reuse Work12 generated layer), completed

Attempt 4 added, to the attempt-3 QSF (single variable):

- 3 × `SEARCH_PATH` for the `sv_wrapper` dirs (absolute `$W`-paths)
- 3 × `SYSTEMVERILOG_FILE` `*_param_pkg.sv` + 3 × `*_sv.sv` (mirroring Work12's own
  `ofs_ip_cfg_db/ip_gen_sv_wrapper_inc.tcl` exactly — the sanctioned PR-flow pattern,
  with absolute paths since our project root differs)
- `sys_pll_pkg.sv` (required by `ofs_fir_cfg_pkg.sv:21`'s
  `sys_pll_pkg::clock_name_to_actual_mhz("clk_sys")`)

No fix-ladder escalation was needed: no headless PIM regen (option 2), no macro shim
(option 3). All reused files are read-only references into `B/work_ia840f_fim_12`;
nothing was copied for attempt 4 (the platform tree copy already existed under
`awp/` from the prior child's assembly). Verified zero files in Work12 modified
after 2026-09-19 13:40 (`find $W -newermt` empty).

## Attempts ledger

| # | What | Result |
|---|------|--------|
| 1 | First assembly driver (`afu_json_mgr`, filelist gen, `quartus_map` A&E) | FAIL — `quartus_map` binary gone in 26.1.1 (internal crash, QSYN qsyn_cmd.cpp:845); manifest parser bug (ValueError). Log: `logs/assemble_and_static_verify.log` |
| 2 | `quartus_syn --analysis_and_elaboration`, project in `$S/awp` root | FAIL — include-path errors: missing `ofs_plat_if.vh`, `local_mem_cfg_pkg` undeclared. Log: `logs/attempt2_ae.log` |
| 3 | Project moved to `$S/awp` so `pim.tcl` relative paths resolve; `.vh` dropped from compiled sources | FAIL — 889 errors, cascade root `ofs_ip_cfg_db.vh` sub-include resolution (see Diagnosis). Log: `logs/attempt3_ae.log` |
| 4 | + sv_wrapper closure (3 SEARCH_PATHs, 3 param_pkgs, 3 `_sv.sv`, `sys_pll_pkg.sv`) | **PASS — rc=0, 0 errors, 1 critical warning, 79 warnings.** Log: `logs/attempt4_ae.log`, report `logs/attempt4_ae.rpt` |

Driver script for attempt 4: sha256 `86e9a2e8a78dcd08452d426b89c4d6db2680959e60be83bf593aea6a892b09e6`
(`afu_fim01_attempt4.sh`, transferred via unique tmux buffer `ahls_fim01_a4_drv`,
executed in owned window `ia840f_mailbox_monitored_01:afu_static_02`).

## Final elaboration result

- Command: `quartus_syn ahls_afu -c ahls_afu --analysis_and_elaboration`
  (quartus_syn = `/opt/altera/26.1.1/quartus/bin/quartus_syn`, 26.1.1 Build 130)
- **Exit code 0. Errors: 0. Critical warnings: 1. Warnings: 79.**
- Hierarchy verification (from `ahls_afu.syn.ae.rpt`): top `ofs_plat_afu` →
  `ahls_binding` (`ahls_board_binding`) → `aperture` (`ahls_mmio_aperture`) →
  `qual_vec_op_k0` (`qual_vec_op_report_di`, AHLS-generated) →
  `cra_ring_wrapper_inst|csr_ring_node...` — the full authored chain elaborated,
  and the Work12 PIM platform tree compiled clean alongside it.

### Warning disposition (all 79 + 1 critical)

- **Critical 20759 / DRC RES-10204 (1 High)**: "No Reset Release IP in project".
  Expected and correct: this is a PR-slot AFU; the Reset Release IP lives in the
  FIM (Work12 base), not the PR partition. The DRC check is a whole-design check
  misapplied to the partition-only project. No action; will not appear when the
  AFU is integrated into the FIM recompile (Stage 2). **Disposition: accepted.**
- **13469 (29)**: PIM platform primitives truncation warnings (`ofs_plat_prim_rob`,
  `lutram`, etc.) — vendor tree, identical pattern in Work12's own compiles.
  Not ours to fix. **Accepted.**
- **21610 (17)**: undriven output ports tied to gnd — including `avm_enable`/
  `avm_burstcount` on `cra_ring_node` (generated dummy ports per the component's
  own `ip/cra_ring_root.sv` "dummy ports : for bind_port compatibility" comment —
  precisely the ports tied inactive in `ofs_plat_afu.sv`) and PIM `.t.last` fields.
  Benign. **Accepted.**
- **21442 (15)**: parameters-in-package treated as localparam (incl. `ccip_cfg_pkg`)
  — LRM-conformant informational. **Accepted.**
- **16803 (6)**: PIM `align_tx_tlps` user-field indexing on non-array type —
  vendor pattern. **Accepted.**
- **16788 (4)**: PIM `map_as_avalon_mem_if` undriven `.t.last` nets — vendor. **Accepted.**
- **21705 (2)**: `$fatal` elaboration guards ignored for synthesis — by design
  (our own geometry checks; they guard sim/elab only). **Accepted.**
- **16752 (2)**: "potential always loop" in PIM ccip shims — vendor. **Accepted.**
- **13461 (2), 23762 (1), 21620 (1, = DRC High above)**: parameter-decl style,
  sweep optimization of idle hierarchies (the request-idle host/local byte agents,
  swept as designed), DRC summary. **Accepted.**

None of the 79 warnings or the 1 critical is an integration defect; all trace to
vendor PIM/FIM files, generated dummy ports, or partition-scope DRC artifacts.

## Aperture math (re-derived and verified)

Component register map (source: generated
`qual_vec_op.report.prj/include/kernel_headers/IDQualVecOp_register_map.h` +
`register_map_offsets.h`, IDQUALVECOP_REGISTER_MAP_OFFSET=0x0, CSR version 5):

| Offset | Reg | Access |
|--------|-----|--------|
| 0x00 | Status[63:0] | R |
| 0x08 | Start[31:0] | W |
| 0x30/0x34 | FinishCounter[31:0] (clear-on-read) | R |
| 0x80 | arg_a[31:0] lo / arg_b[31:0] hi (packed 64-bit) | W |
| 0x88 | arg_mode[31:0] | W |
| 0x90 | ResultPipe channel data[63:0] | R |

Highest touched byte = 0x90+7 = **0x97** → span fits in 0x100.

- `csr_ring_root_avs_address[4:0]` (verified in `qual_vec_op_report_di.sv:36`):
  5-bit **word** address over 64-bit data → 32 words × 8 B = **256 B span**.
- DFH/UUID aperture (binding `ahls_mmio_aperture`) occupies bytes 0x00–0x27
  (DFH words 0–4), requires `CSR_BASE_BYTES ≥ 40`.
- **CSR_BASE_BYTES = 0x40 (64)**: first 64B-aligned window past the DFH hole
  (words 5–7 = bytes 0x28–0x3F stay decode-error; nothing lost — no registers there).
- **CSR_SIZE_BYTES = 0x100 (256)**: exactly the component's 5-bit word-address
  space. In-aperture rebased byte addresses run 0x40..0x13F → `csr_address[7:3]` is
  the component word address; `csr_address[19:8]` are always zero in-aperture
  (binding decodes the window out of the 20-bit VF-BAR0 MMIO byte address).
  Lossless by construction.
- Host-visible offsets = 0x40 + map offset: status 0x40, start 0x48,
  finish 0x70/0x74, args 0xC0 (a lo + b hi), mode 0xC8, result 0xD0.

The prior child's math was **correct** — confirmed against the generated register
map rather than taken on faith.

## UUID consistency (verified)

`67bc266a-56f7-440a-bb75-12b5f446d842` appears identically in all four places:

1. `src/ofs_pr_afu.json` → `accelerator-clusters[0].accelerator-type-uuid`
2. `src/ahls_qual_vec_op.json` → AFU JSON (source of afu_json_info.vh)
3. Generated `afu_json_info.vh` → `` `AFU_ACCEL_UUID 128'h67bc266a_56f7_440a_bb75_12b5f446d842 ``
   (verified remote, `awp/afu_with_pim/afu/hw/afu_json_info.vh:10`)
4. `src/ofs_plat_afu.sv` AFU_UUID localparam + `$fatal` guard (line 230), and the
   binding instance parameter `AFU_UUID` — elaborated value verified in
   `logs/attempt4_ae.rpt` §"Parameter Settings for User Entity ahls_board_binding
   Instance: ahls_binding" (binary 01100111 01111000 ... = 0x67bc266a...,
   CSR_BASE_BYTES=64, CSR_SIZE_BYTES=256, NUM_LOCAL_MEM_BANKS=2,
   CSR_BYTE_ADDR_WIDTH=20 all confirmed in the same table).

## Provenance of reused WORK12 files (sha256)

All read-only references into `B/work_ia840f_fim_12`; none modified (verified:
`find $W -newermt "2026-09-19 13:40" -type f` → empty).

ip-cfg-db headers:
- `cc0a7eb7c0538185d6e15db040d9f918d482951e079208421d004ac02fa9e937` ofs_ip_cfg_db.vh
- `1e22cf7064ce3653e67b5acd2bb59a313eb450c30dd62c67055bb7e90ca27d8c` ofs_ip_cfg_pcie_ss.vh
- `7d3afe01cbf131889cbac70de33e4d3d7d8e79c4aadd94f19c243a338df8814d` ofs_ip_cfg_local_mem.vh

sv_wrapper generated set:
- `5e194ae3669e56b1bcda29745616c66c1899ccfd9708aceb47bc1db91ad4614c` pcie_ss_if_info.vh
- `ff4d6d6d0d5ca28f741836195ad77c1533e966a16e67f3753f3202784e1824e9` pcie_ss_ip_params.vh
- `2490b3f16066b5b2aa65c2a8fbaeb8ccf1f43a5c24109d041efac51e6aa5cb84` pcie_ss_param_pkg.sv
- `dc6c496ecf816c207f2eee17c0dec1dcd6cb12507f48755b21dcb4069a798c5c` pcie_ss_sv.sv
- `baa461dd8e4b1c377734d22dca780cf2932dcaabbd226934bd2ac1d4337e53dc` sys_pll_if_info.vh
- `814728c53a5a2c19e5909e601ac3d16dd18db3b0dde7d171dbdb012ac67bd0c5` sys_pll_ip_params.vh
- `ae46adb6be159a97676c7a6df26364dda766a42a1c7ea7fc12b782a81f55b053` sys_pll_param_pkg.sv
- `0a865b0eeba83a190f870127432d2b3644d384944d56fc6a596b174c153f4461` sys_pll_sv.sv
- `0f125935d8003f42e57c736ba2ed93984a3224dfe3741fb6466b9fdc3fc5b2fb` sys_pll_pkg.sv
- `901fa97b882f41c7aa7ae2278a47134b5972ed04df1023fca0ca3838b40a80d1` mem_ss_if_info.vh
- `04440c2eca2ad57ed1997b75d562f7cd194cec354d267a34ebd42de140f42c07` mem_ss_ip_params.vh
- `25908195980bb69b085f2ae004b490a7e6fe38dd04fe6e4779db46b321d65aa7` mem_ss_param_pkg.sv
- `5da695996ab296ff0a1b643a18a76cfbdd74055d47538ecdc9ed4a974df4a38e` mem_ss_sv.sv

PIM platform (copied under `awp/` by the prior child; hash-identical to Work12):
- `34d937690403df4c2f08d794f0dd872ba1fac84ffb7052ca901e9d51cc98865e` ofs_plat_if.vh
  (Work12 `.../afu/build/platform/ofs_plat_if/rtl/ofs_plat_if.vh` = awp copy, verified equal)
- `abe5da1132568f464bc72e5991f76ac6668c9761562cda4b822f47e0938dae97` platform_afu_top_config.vh
- `cab8e6cae5c2a30f7e7d90e226606d4b1edd9287fb4cdfbadf74c1c7a4340c66` ofs_plat_if_top_config.vh
- `b77f4ae2413b67816230a82ac7691ed3bab84f14e2928cd186f4eb1723567c22` local_mem_cfg_pkg.sv

Host-chan config consistency: Work12's platform was generated for
`native_axis_pcie_tlp`, 512-bit, 51-bit line address
(`OFS_PLAT_PARAM_HOST_CHAN_IS_NATIVE_AXIS_PCIE_TLP 1` etc. in
`ofs_plat_if_top_config.vh`), matching this AFU's binding geometry — no
config mismatch, so fix option 2 (headless PIM regen) was never required.

## Open risks for the FIM-integration recompile (Stage 2)

1. **Sweep of idle agents** (warning 23762): the request-idle host/local byte
   agents' hierarchies were optimized away in this standalone A&E. Harmless for
   elaboration; the FIM recompile treats the same code identically.
2. **freeze / kernel_irqs / device_exception_bus unconnected** in
   `ofs_plat_afu.sv`: no PIM PR-freeze line and no PIM interrupt routing bound by
   the reusable binding library. Kernel control relies on CSR start/status only.
   Revisit if the qualification tests need kernel IRQs.
3. **Host pipe (`ResultPipe 0x90`) is read via MMIO polling**; the generated
   component's host-pipe channel is not wired to host memory (no DMA in this AFU).
   Test 5 host code must poll 0xD0 (rebased 0x90).
4. **`attempt4.qsf` uses `$::env(BUILD_ROOT_REL)` absolute Work12 paths** — the
   Stage-2 FIM recompile uses its own source list (`ofs_pr_afu_sources.tcl` +
   `afu_main.tcl` path); the sv_wrapper closure entries are already present in
   Work12's own `ofs_ip_cfg_db/ip_gen_sv_wrapper_inc.tcl`, so Stage 2 needs no
   QSF portability fix. The standalone project remains as evidence only.
5. **DRC RES-10204** (reset-release) will not apply once the AFU sits in the full
   FIM design (reset release is in the FIM base).
6. **PR release packaging (Stage 3)** will regenerate `afu_json_info.vh` etc. via
   the OPAE tools; UUID 67bc266a-56f7-440a-bb75-12b5f446d842 must be re-checked
   there (single source of truth remains `ahls_qual_vec_op.json`).

## File inventory

- `src/` — 5 authored files (unchanged from prior child; verified clean)
- `logs/` — attempts 1–4 logs + attempt-4 A&E/flow/DRC reports + final QSF
- `manifest.json` — file → sha256 for everything under this evidence dir
- `logs/attempt4_ae.rpt` (9.2 MB) and `logs/attempt3_ae.log` (1.8 MB) exceed the
  2 MB repo policy → kept local-only, listed in `.gitignore` for this dir,
  sha256-referenced here: attempt4_ae.rpt =
  `a625ad394d15a8f26c4648b4f1d1da64fa85daadbfbeefdea57338d7820661f6`,
  attempt3_ae.log =
  `8c1419a46ea8fda3c57adc885ac6208fcdb592fecada5941668c5d5df8b35a47`.
  Remote copies: `B/qualification/ahls-afu-fim-01/logs/`.

Remote mirror: `B/qualification/ahls-afu-fim-01/` (logs hash-verified via scp both
directions; report.md + manifest.json mirrored after this write).

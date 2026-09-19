# FIM integration 05 — source correction and build handoff

ready_for_build: false

## Outcome

Applied only the three proven integration corrections to local maintained source: 118 stale RDIMM `ddr4_mem_group_1[0]` targets now name `ddr4_mem[1]`; discrete HB29 CS_N now names the scalar `ddr4_mem[0].cs_n`; the memory wrapper drives AWQOS and ARQOS to zero, independently guarded by the actual generated presence/width macros. No geometry, package coordinate, calibration routing, PLL, PF/BAR, BMC, AHLS ABI or gate change.

**DDR simulation is SKIPPED BY USER**, not passed and not a compile prerequisite. No new simulator invocation, device-library search, or DDR experiment was performed. Prior unsupported-parameter and protected-source simulator failures do not establish failure of the separate Quartus synthesis compiler.

Changes are **local only** pending the focused parent review. Remote maintained source and Work04 remain unchanged. Workstation inspection ran only in newly owned `fim05-*` windows of `ia840f_mailbox_monitored_01`, with BatchMode SSH and checked hostname/UID. Current Quartus instructions were read. No board/driver/service operations, programming, commits or pushes.

## Evidence and checks

`python3 qualification/fim-integration-05/check_integration.py` returned **0 / PASS**; full output is `targeted-checks.log`.

- 241 assignments and unique package coordinates preserved, in the same order.
- Exact target delta is 118 group-prefix changes plus one scalar CS_N correction. Reference clock/OCT assignments unchanged, including the existing discrete negative differential companion.
- Against the actual generated SystemVerilog declaration schema: stale/unmatched HDL spellings reduce from 119 to zero. This is a source-schema check, **not Quartus pin elaboration/fitter acceptance**. `(n)` is retained as Quartus differential-companion syntax, not claimed as an HDL field.
- One guarded zero assignment per QoS field within the two-channel mapping loop; removing those two guarded blocks reproduces the original RTL byte-for-byte. No other RTL delta.
- Three negative target fixtures rejected: stale group1, scalar-as-vector CS_N, out-of-range DQ.
- Ten protected configuration/preset/top/gate files unchanged.
- All captured Work04 header payload self-hashes verified. Five current remote generated-header/wrapper hashes independently match the captured Work04 records (`headers-remote.log`). The actual generated interface has two physical instances, scalar CS_N, and 4-bit AWQOS/ARQOS.
- Pinned common donor `HEAD:src/fpga_family/agilex/mem_ss/mem_ss_top.sv` hashes to the exact pre-edit source. Original pin donor provenance stays in the manifest.

| Check | Status |
|---|---|
| Target schema / coordinate preservation / exact QoS delta | PASS, actual Python execution |
| Live generated-header hash agreement | PASS |
| QoS HDL elaboration/accepted-request behavior | NOT RUN; check in native compilation, source analysis alone is not behavioral evidence |
| DDR simulation | SKIPPED BY USER |
| FIM synthesis / fit / timing | NOT RUN |
| Hardware / calibration / programming | NOT RUN |

`receipt.json` contains exact before/after SHA256, source provenance and test scope. `before/`, `after/` and `changes.patch` preserve exact deltas. The maintained board manifest updates only this pin file's current hash and retains its old/source hashes. New common RTL provenance is bound in this run's receipt, not falsely added to a historical manifest count.

## Concrete next native stage

1. Focused independent review of these source changes and tests, then synchronize just reviewed maintained files. Preserve Work04 as an immutable generation baseline; use a new copied worktree such as `/home/uwb_student00/ahls/new_BSP/work_ia840f_fim_05`, preserving generated file provenance and fixing/binding any copied path references. Do not overwrite old authorization records or claims.
2. Extend/rebind the actual source-bound compile gate for that new worktree and stage. The current gate is **technically setup-only**: `ia840f_experimental_gate.py` hardcodes `WORK=work_ia840f_ipgen_04`; `native()` permits only `setup`/`setup-entry`, and its Quartus command grammar does not permit compilation. Passing a new permission label cannot authorize compile. Native `build_top.sh` and `build_fim_compile.sh` both call it before stage side effects. Keep readiness false; allow exact reviewed compilation contexts rather than removing these checks. Capture actual child executable/argv/cwd and tool hashes and fail on `IA840F_GATE_REJECTED` / warning 125091, not only outer rc.
3. In the new bound worktree, invoke the existing native entry (not a bespoke compile wrapper):

   `./ofs-common/scripts/common/syn/build_top.sh --stage=compile -k -p ia840f /home/uwb_student00/ahls/new_BSP/work_ia840f_fim_05`

   **This is the proposed next invocation, not presently runnable through the setup-only gate.** Current `build_fim_compile.sh` constructs `quartus_sh --flow compile ofs_top -c ofs_top`. Live Work04 `build_env_db.txt` confirms `Q_REVISION=ofs_top`, `Q_PR_REVISION=ofs_pr_afu`; copied configuration must retain them. Inspect/rebind the actual QSF callbacks and generated-IP path closure before launching.

   Important source finding: despite old help/plan saying `-end synthesis`, the current script's `ANALYSIS_AND_ELAB_ONLY` branch actually appends `-end dni_elaboration -aggressive_compile_time -fast_functional_test`. Do not describe `-e` as synthesis. The ordinary compile invocation above has no such truncation and is the native full compile path. Parent may use a reviewed bounded elaboration stage first, but should not mistake its completion for a fitted FIM.

4. Use explicit 26.1.1 environment; inherited `.bashrc` points to 23.1. Set `QUARTUS_ROOTDIR_OVERRIDE=/opt/altera/26.1.1/quartus`, Quartus 26.1.1 bin and `quartus/sopc_builder/bin` plus matching Questa only if needed in PATH, and the current license path per instructions. No persistent shell/tool changes required.

## Remaining acceptance, not blanket compile prohibitions

Native compile must establish the actual elaborated DDR port assignments, single defined QoS drivers, complete generated include/QIP source closure, both memories, intended PF0/VF0 AFU and PF1 BMC. Work04 generated synthesis RTL is not already-synthesized FIM logic. Preserve AGFB027R25A2E2V, two distinct configured 16 GiB x64/no-ECC channels (discrete0/RDIMM1), BOT/BOT and whole-pair 0→0/1→1; do not remap calibration.

Carry these into compilation/report review: unresolved vendor-vs-modern calibration-index semantics, PIM request/response USER semantics (do not infer lost NO_REPLY only from width), effective PCIe CSR clock and seven-output system PLL timing (core470 request unchanged), existing BMC warnings/unused conduits/legacy leaf target settings and PF1 FLR cancellation/drain restriction. Do not retune PLL or drop PF1/BAR2 to obtain a fit. PCIe contract remains P-Tile Gen4x16, 64-byte/two-segment datapath, PF1 BAR0 disabled, BAR2 width28/BAR4 width14 both 64-bit prefetchable.

These unresolved functional acceptance items must remain visible, but DDR simulator incompatibility is explicitly not a prerequisite for trying the synthesis compiler. Compilation, fit/timing, fresh matching PR products and eventual working hardware are separate results. Full-FIM programming still requires a verified compatible BittWare update method and genuinely usable recovery without JTAG; compile authorization does not establish that safety.

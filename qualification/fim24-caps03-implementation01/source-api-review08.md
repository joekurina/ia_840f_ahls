# Source/API review08 — PASS with limits

**Verdict:** the captured copy, selected source chain and installed API support the proposed minimal, parent-only mapped-persona-synthesis preparation. This is **not** runtime/QUALITY approval, authority issuance, project-load validation or synthesis acceptance. An unissued future execution package is not a source/API blocker.

Reviewer: **GPT-6 / `openai-codex`, substituting for unavailable GLM5.3**. Local reads, hashes, JSON comparisons and Python AST inspection only; no project scripts, Tcl, tests, native/remote commands, Git or hardware execution. Only this review is written.

## Evidence and copy

Rehashed **60/60** members of `source-api-freeze07.json`, with exact sizes/SHA-256 and no mismatches. Freeze SHA-256: `9b3af5470d5f9852fbb68c5489439898b103352db39f3be7129baadd84009104`. Also verified all six copy/loader/help result archives against their frozen collection records and all exported readbacks against their captured bytes. Loader02–04 tool/DNI maps agree. These checks authenticate retained evidence, not the present remote filesystem.

`copy01-readback/prepared-copy01.json` agrees with the hash-bound accepted setup result's original inventory: **3443** original entries retain content/link text; **3444** prepared entries contain **530236524 regular-file bytes**. The sole added entry is:

`build/platform/ofs_plat_if/par/platform_if_addenda.qsf → ofs_plat_if_addenda.qsf`

Its relative text and recorded resolution point inside the new `work_fim24_caps03_implementation01/base01` copy. Canonical/root bytes remain unchanged. The canonical body is byte-identical to `../fim24-caps03-persona01/legacy-addenda-reference14.qsf`, SHA-256 `5bfcfac51eee587bdb3b240031cc489e7066507d31d8b8e328114cd18e835fbd`. Both names share the directory used by canonical line9's `THIS_DIR`; no basename-dependent rewrite is needed. This is an operator-added compatibility entry, not tool-emitted or Quartus-validated collateral.

The two inherited symlinks retain their text: `build/quartus_proj_dir` resolves into the new copy (only its recorded resolution changes), while `hw/ia840f_ahls_memory.json` still resolves to the original external `prepare01/afu_sources` input. Copy01 records original-setup preservation. This review changes neither setup, release, static inputs nor generated fabric. Basis: `../fim24-caps03-persona01/SETUP-ACCEPTANCE19.md` and `addenda-compatibility-review17.md`.

## Actual selected loader and remaining consumption limits

The copied `ofs_pr_afu.qsf` retains configuration, FIM macro/base-IP lists and `ofs_pr_afu_sources.tcl`. In the loader02 capture, **line35 directly selects canonical PIM addenda**, and line38 selects current `ofs-common/.../afu_main.tcl`.

The loader03 `afu_main.tcl:8–14,34–86` makes `PR_IMPL` select `PR_COMPILE`. With **OPAE_PLATFORM_GEN absent**, the existing `afu_with_pim/afu.tcl` selects the normal PIM connector and application sources, not export generation or the generic exerciser branch. No `pim.tcl` exists in the prepared inventory; canonical PIM loading already occurs directly. Bind environment-variable **absence**, not the string `0`, in future admission.

Loader04 `afu_with_pim/afu.tcl:4–5` selects `../../../../../hw/afu.qsf` and the matching native UUID-header search path. That actual QSF contains **16 SV + two QIP** assignments, all pointing into external `work_fim24_caps03_persona01/prepare01/afu_sources`; copying did not repoint them. Preserve these accepted selections, including generated dependencies, without historical overlays or regeneration.

All canonical literal HDL/SDC/Tcl targets are present in the recorded prepared inventory; canonical lines188–193 retain three SDCs and the JSON/user-clock helpers. The captured helper bodies also match the copy inventory. This establishes source selection and recorded existence, not complete native/transitive dependency resolution, once-only consumption, effective constraints or mapped behavior. The repaired generated-root alias edge need not execute when inactive; do not force it into the selected chain merely to validate the filesystem link.

JSON remains **auto-200/auto-100**, AFU UUID `d48dde9f-f551-578d-8bb0-69483ac95ec6`, static interface UUID `fc603c44-5c8f-5e94-bcbe-a5780030947c`. Inventory pins imported `ofs_top.qdb` at **78571428 bytes**, SHA-256 `dbc1684ab873b3d317d20019430c99177653daf221e7471b227b1966d7ef30b4`. The PR QSF preserves `AGFB027R25A2E2V`, top `top`, revision `ofs_pr_afu`/`PR_IMPL`, `green_region`, existing **36** processors, SDC/import/user-clock hooks and native `OPTIMIZATION_MODE "HIGH PERFORMANCE EFFORT"`.

## Installed synthesis API

Help05 identifies **26.1.1 Build130** and `-c/--rev`; targeted help06 explicitly advertises both settings options as `[=on|off]`, although generic help omits them. Five direct version/help targets returned native/CMake/effective zero; both configure steps have CMake/effective zero and native status not applicable. Both batches record tool preservation and outer zero. Eight executable-file bindings distinguish launcher/Linux binaries plus Python/CMake/make/bash.

`candidate07/CMakeLists.txt:12–15` matches the proposed direct command:

`/opt/altera/26.1.1/quartus/bin/quartus_syn --read_settings_files=on --write_settings_files=off ofs_top -c ofs_pr_afu`

Proposed callback executable: `/opt/altera/26.1.1/quartus/linux64/quartus_syn`; cwd: `/home/uwb_student00/ahls/new_BSP/work_fim24_caps03_implementation01/base01/build/syn/board/ia840f/syn_top`; option tuple exactly as above. No flow-manager IPC flags are justified; reject unexpected contexts. The old25.1 CMake/template were inspected only as provenance, never imported/executed or reused for authority/licenses. Help establishes syntax, not combined-option/project applicability, absence of native rewrites, or successful mapping.

## Minimal next preparation and acceptance boundary

1. Archive exactly the **857** copied DNI entries outside the active project; the separate DNI inventory equals that prepared subset. Preserve the originals, archive and static QDB; bind the precise input/output-role delta.
2. Add fresh synthesis-only Python/Tcl gates and replace **only PR QSF lines2–3** referencing spent export gates. Preserve all other QSF bytes, especially existing processor count36; no RTL, SDC, clock, protocol, pin or region changes. The CMake proposal alone is not an admission gate.
3. Bind complete prepared sources/links, external AFU/generated dependency closure, static inputs, helpers/tools and exact contexts/live runner ancestry. Require early rejection before output side effects, exclusive ownership, readiness/hardware flags false, current license environment without disclosure, all36 CPUs, **64GiB per-process** and **1200s** synthesis deadline.
4. Retain rejection-marker/Critical-Warning125091 detection and corrected whole-descendant supervision: protect immediately after spawn, drain within the original deadline, inspect logs during draining and at completion, keep the leader unreaped until possible group signals finish, and preserve raw/effective status and termination evidence. These controls are not an OS sandbox or aggregate-memory guarantee.

Fresh runtime review/issuance and native selected-source/constraint diagnostics, mapping/output identity, preservation and independent result acceptance remain future work. Keep simulation acceptance37/consumption36 and its coverage limits; no unchanged simulation/HLS rerun. No fitter, STA, assembly, GBS, programming or hardware authority follows from this PASS.

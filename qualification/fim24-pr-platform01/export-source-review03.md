# Work24 PR export — independent source review03

**FINAL: no visible change requires different callback flags, project/revision, board target, or PIM pin. Two new dependency edges need bounded follow-up; exact 26.1.1 runtime serialization remains unverified.** This is source analysis, not prepared SPEC/QUALITY approval or execution authority.

Reviewer: GPT-6/openai-codex, substituting for unavailable GLM-5.3/zai. Followed `GOAL-PROMPT-MIGRATION.md` Phase5. Local reads, hashing and in-memory comparisons only; no source/native/test execution, project opening, SSH, Git mutation or hardware access. Only this report was authored.

Paths below are relative to this directory: `S=stage01-readback`; `I=installed02-readback/common/tcl`; `H=../fim21-pr-platform01`; `G=S/ofs-common/scripts/common/syn/generate_pr_release.sh`; `Q=I/apps/qpm/qar.tcl`; `C=I/packages/qpm/qpm-ccl-lib.tcl`.

All twelve installed captures match `tools-pim-bindings02.json`; all 25 selected source readbacks match `stage01-metadata.json`, including dereferenced `config_env.tcl`. Vendor release/environment/PIM scripts and selected PR sources match the historical captures; the 276-member PIM inventory matches the predecessor. These are local capture checks, not fresh remote revalidation.

## 1. Six proposed contexts

`release-contexts-proposed03.json` is exactly the old six-context table with tool/root retargeting, not newly observed authority.

| Proposal entries | Source-grounded disposition |
|---|---|
|1: prepare|Keep `--prepare -r ofs_pr_afu ofs_top` in the staged project. `G:201–204`; unchanged `I/internal/qsh_prepare.tcl:97–126` opens that revision.|
|2: archive|Keep custom `auto/db/qsf`, native `-force`, and owned QAR output. `G:206–208`; `Q:1333–1352` forces discovery with neither full-synthesis/export option enabled.|
|3–4: restore|One invocation starts at `release01/hw/lib/build` (`G:210–215`); project opening changes cwd (`Q:1985–1994,2046–2051`). Preserve the proposed outer/project-directory alternatives, but distinguish them from observations.|
|5: macro emission|Keep the staged-project cwd, `--mode=sim` and release output path (`G:218–220`; `S/ofs-common/scripts/common/syn/emit_project_macros.tcl:35–40`).|
|6: discovery|`C:824–855` still requests `execute_module -tool map` with `--disable_all_banners --analysis_and_elaboration` and conditional `--dni`. No visible argument delta.|

Historical `H/artifacts-export03/run/gate-events.jsonl` contains six accepted events but only **five distinct contexts**: indices `1,2,6,4,4,5`; entry3 was not observed. The `quartus_syn` mapping, IPC4 prefix, settings flags and duplicate DNI serialization are **history-plus-source basis**, not current-runtime proof: the captured Tcl delegates to `flow` (`Q:128`; `C:851`) and does not expose that implementation. Do not substitute compile IPC17, deduplicate DNI, or admit arbitrary flags. The first bounded experiment may validate this exact proposal; prior native proof is not a circular prerequisite.

## 2. Concrete 26.1.1 deltas

- **New dependencies:** `Q:123` unconditionally requires `fileutil`; `I/packages/qpm/qpm-qsf-pkg.tcl:277–283` unconditionally calls `::qpm::pkg::vds::get_archive_files`, newly indexed at `I/packages/qpm/pkgIndex.tcl:32`. Their providers are absent from this twelve-file capture, not demonstrated absent from the installation. Package enumeration also eagerly loads installed `qpm-*-pkg.tcl` (`Q:695`; `C:1093–1103`). Request one bounded same-release readback/hash of `qpm-vds-pkg.tcl` and the actual `fileutil` index/provider before closing this dependency review; inspect their immediate requirements. Do not infer VDS inactivity solely from no `.vds` inventory entries, or expand into installation-wide closure.
- **Path behavior changed:** `C:1408–1417,1592–1669,1690–1693` replaces selected `file normalize` uses with lexical absolute-path/dot-segment handling. Symlink spellings and archive common-root/layout can differ. Recheck actual restored project/helper/QDB paths; do not preemptively broaden cwd authorization or rewrite binaries.
- **No new flags required:** DSS/upload, target and TGZ support are opt-in (`Q:97–103,1627–1672,1749–1751`); ordinary `.qar` remains the fallback (`C:1337–1353`). Windows registry/path additions are platform-conditional (`Q:136–139,164–169`). Leave those branches unselected.

## 3. Copy-only preparation

- Retarget a dedicated release callback, replacing only the PR QSF's current hook (`S/syn/board/ia840f/syn_top/ofs_pr_afu.qsf:2`); preserve original gate files/base QSF. Historical gate roots/version are stale (`H/release-only-gate01.py:3,11`). Keep exact binary/context/live-ancestry binding, not a global compile-gate bypass.
- Retain explicit Python `TEXT_FILE`: QSF file-assignment collection remains active (`I/packages/qpm/qpm-qsf-pkg.tcl:235–257`; `C:945–982`) despite changed descriptive text. Keep only `ofs_pr_afu` in the copied QPF (`S/syn/board/ia840f/syn_top/ofs_top.qpf:31–32`). Restore still bypasses project-open failures and iterates revisions (`Q:1967–1994`); native zero cannot clear missing-helper/125091 diagnostics.
- Retarget exactly the three QAR references (`G:208,214–215`) to exclusive owned TMPDIR. Retain native archive `-force`, never vendor target `-f` (`G:55–60,183–184`).
- XML relocation must be source-location-only and resolve to an existing owned target. The historical regex scans whole XML (`H/run-release03.py.in:36–46`), so existence alone is not semantic classification. Preserve unmapped metadata, original Work24, base QSF, static QDB and images.
- Clean inherited build selectors (`G:136–145`; `S/syn/scripts/build_var_setup.sh:166–170`); use current inherited license variables only. Child-only `OPAE_PLATFORM_GEN=1` selects an empty template (`S/ofs-common/src/fpga_family/agilex/afu_main.tcl:34–46`), not persona/hardware acceptance. No source-derived need changes the planned independent CMake version/export targets or direct vendor Bash route.

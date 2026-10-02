# Addenda filename compatibility review17

**Finding:** a real Quartus dependency-name mismatch, not missing PIM functionality. Recommend one same-directory relative compatibility link in a **future fresh compile copy**. Nothing is implemented or authorized here.

Reviewer: GPT-6 / `openai-codex`, substituting for unavailable GLM5.3. Local read/hash/JSON inspection only; no project/vendor/Tcl execution, SSH, Git or hardware access.

Paths below are relative to this evidence directory: `P = completion13-readback/persona/build/platform`; `I = prepare02-readback/installed/lib/python3.9/site-packages/platmgr`.

## Evidence and coverage

Rehashed **100/100** `actual-result-freeze15.json` members with matching sizes/digests; all **26** readbacks match `actual-result-index14.json`. Prepared02/draft06 tool maps agree on **92** entries; captured installed sources match those bindings, and prepare02's prior tool-binding map agrees. These are captured-evidence checks, not fresh remote attestation or comprehensive compile qualification.

`completion13-readback/operation/result.json` contains **3443** persona inventory entries. `copy-reconciliation14.json` records **3438** unchanged copied entries plus five outputs. The inventory contains the canonical addenda but not the literal target of `P/platform_if_addenda.qsf:22`:

- Emitted target: `${THIS_DIR}/ofs_plat_if/par/platform_if_addenda.qsf` — absent.
- Existing body: `P/ofs_plat_if/par/ofs_plat_if_addenda.qsf`.

Direct raw-byte comparison against `legacy-addenda-reference14.qsf` confirms equality: **21503 bytes**, SHA-256 `5bfcfac51eee587bdb3b240031cc489e7066507d31d8b8e328114cd18e835fbd`. The legacy reference is recovered data from the qualified older simulation, not an executed capsule or proof of current Quartus acceptance. The generated root/header are real native outputs; successful file setup did not resolve or validate this Quartus edge. `RESULT14.md` correctly retains the defect.

## Installed emitter contract

- `I/db/afu_top_ifc_db/ofs_plat_afu.json:3–12` selects the OFS module/shim and `ofs_plat_if`/`afu` port class; it supplies no addenda filename override.
- `I/tools/afu_synth_setup.py:181–223,268–299` copies the release build with `symlinks=True`, then invokes `rtl_src_config`, `afu_platform_config --qsf --tgt platform`, and `afu_json_mgr`. It does not manufacture the missing nested compatibility name.
- `I/tools/afu_platform_config.py:453–468,550–563,593–611` selects the release's existing OFS tree, not the installed generic fallback, and rewrites the default QSF prefix to `${THIS_DIR}/ofs_plat_if`.
- `I/lib/emitcfg.py:379,394–428` writes the root QSF, establishes `THIS_DIR`/`platform_cfg`, then unconditionally appends `/par/platform_if_addenda.qsf`. This explains the observed output without assuming an installation change.
- `I/db/platform_if/par/platform_if_addenda.qsf:7–49` is the generic fallback's older `PLATFORM_IF_SRC`/CCI-P source set. **Do not copy that template into the OFS tree:** matching its basename does not make its contents appropriate.

An unchanged setup rerun would reproduce the same mismatch; none is required.

## Smallest correction and alternatives

In the separately owned fresh persona compile copy only, recommend:

**New link:** `build/platform/ofs_plat_if/par/platform_if_addenda.qsf`  
**Relative link text:** `ofs_plat_if_addenda.qsf`

Leave the canonical body and emitted root QSF unchanged. This adds one filesystem metadata entry, retains the installed consumer's filename contract, and neither duplicates nor edits PIM HDL. It is a recorded compatibility adaptation, **not** a native setup output.

The canonical body resets `THIS_DIR` to `[file dirname [info script]]` at line 9. Both names reside in the same `par` directory, even if link resolution exposes the canonical name; no body logic depends on the basename. Thus its search paths, HDL assignments, three SDC assignments (188–190), and `afu_json.tcl`/`user_clock_config.tcl` assignments (192–193) keep the same directory semantics and order. All literal HDL/SDC/Tcl targets exist in the recorded inventory; this is not a live dependency-closure test.

A **byte-identical regular-file copy** under the compatibility name is equally source-supported and avoids link-packaging assumptions, but duplicates the body and requires equality checks against drift. Use that representation if later packaging cannot preserve the relative link. Replacing only the root line's final basename with `ofs_plat_if_addenda.qsf` also preserves `THIS_DIR`, namespace, source and constraint semantics; it is the smallest textual edit, but modifies generated output and must be reapplied after regeneration. Prefer the single compatibility entry. Do not combine fixes, invent a Tcl forwarding helper, substitute an empty stub, or patch vendor RTL/tools.

## Remaining validation, not launch authority

Keep `/home/uwb_student00/ahls/new_BSP/work_fim24_caps03_persona01/setup01/persona` untouched. Preserve PIM `3c21189e728009d4c492fa2be54c0ab1008b06dc`, Quartus 26.1.1, static UUID `fc603c44-5c8f-5e94-bcbe-a5780030947c`, native AFU UUID `d48dde9f-f551-578d-8bb0-69483ac95ec6`/header and auto-200/auto-100 JSON. Retain bindings to `prepare01/afu_sources` and `/home/uwb_student00/ahls/new_BSP/work_fim24_pr_platform01/release01`.

Fresh preparation must bind the exact delta, link type/text/resolved in-copy target, canonical/root digests, copied source paths and archive/readback behavior. Retarget copied spent gates under fresh compile ownership. Subsequent authorized native validation must establish once-only QSF consumption, actual HDL/SDC/Tcl resolution and clock/JSON handling; successful elaboration, implementation/timing and hardware remain separate gates. Direct retained Questa uses explicit HDL lists, not this QSF; it cannot validate this correction, full PCIe mapping, AFU-top or `pr_slot` integration.

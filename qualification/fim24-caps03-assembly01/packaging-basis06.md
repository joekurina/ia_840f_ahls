# Offline GBS packaging basis06 — FINAL

Reviewer: **gpt-6.1-sol-900k / openai-codex**. Local reads, hashes, AST and JSON/text inspection only; no project-code import, CLI, Quartus/project opening, remote, Git or hardware operation.

## Frozen basis

Read SOURCE-SCOPE04 first. Independently verified freeze04 SHA256 **`e09ee53ec5c0db3612a8c180dbba5f35fc16eff1936de3a2442d8c2d8da1ffd4`**, declared/actual **36/36** members, every size/hash matching. Fresh-copy evidence records 4038 accepted STA entries/all733 QDB members preserved; no assembly/authority exists in this frozen basis. The inherited STA06 gate remains deliberately unsuitable for assembly pending its separately reviewed callback. This packaging review is not an additional assembly blocker. Qualified help02 is 26.1.1 Build130; rejected help01's older-root selection remains preserved. [Scope](SOURCE-SCOPE04.md), [freeze](source-api-freeze04.json), [copy](copy03/index.json).

## Exact selection and metadata

The maintained, copied and help02 `gen_gbs.tcl` are byte-identical, SHA256 `b012ad8ae74a5cf79b8d50716a780cff807a320a1ae4dfec653e2469e020e21b`. Its `main` opens the project; bare assembler does **not** invoke POST_FLOW. Avoid that unnecessary project opening by reproducing only the supported resolved packager operation. [Script:75–125](copy03/readback/project/ofs_partial_reconfig/gen_gbs.tcl#L75), [QSF:124–139](copy03/readback/project/ofs_pr_afu.qsf#L124).

Actual loader route: PR source Tcl → Agilex `afu_main.tcl` PIM branch → `afu_with_pim/afu.tcl` → `../../../../../hw/afu.qsf`. The 213-byte loader capture matches current hash `0be4ad0d16d6d9b36e141e8122a61ea0d4a65170b1117ab7c73fbe235057f625`; AFU QSF matches `c69f35bf04f78ef8a14b3e181bac49c4c870b591caa5f12a45fd8070ec656cfa`. PIM `afu_json.tcl` getter returns the first JSON **MISC_FILE**, which here names `/home/uwb_student00/ahls/new_BSP/work_fim24_caps03_persona01/prepare01/afu_sources/ia840f_ahls_memory.json`; do not select WORK_PR_JSON_FILE/glob fallback. JSON bytes match current external binding SHA256 `4391d1756d904ab7fc9125c9cd5dac923f470130223ea21d625081414547bbab`. [PR selection](copy03/readback/project/ofs_pr_afu_sources.tcl#L33), [loader member](../fim24-pr-platform01/completion31-result.json.gz), [QSF/getter/JSON members](../fim24-caps03-persona01/completion13-result.json.gz), [current bindings](copy03/readback/prepared-copy03.json).

AFU UUID is **`d48dde9f-f551-578d-8bb0-69483ac95ec6`**; class `ofs_plat_afu`, version1, power0, one context. Source clocks stay `auto-100`/`auto-200`. Interface UUID is **`fc603c44-5c8f-5e94-bcbe-a5780030947c`**, from this build_env, not historical CAPS01/live hardware. Completed user-clock metadata is numeric **low100/high200 MHz**; bank0/core **3.000ns** remains distinct. [Environment](copy03/readback/project/build_env_db.txt), [clocks](copy03/readback/project/output_files/user_clock_freq.txt), [STA](../fim24-caps03-sta01/NUMERICAL-ACCEPTANCE32.md).

## Installed packager basis and smallest remaining qualification

**Selected implementation/getter sources are available, not missing.** Fourteen exported entrypoint/package/schema files in historical `gbs-prerequisites01` independently match the current inherited92-tool map; `/usr/bin/python3.9` also matches. Entry `/usr/bin/packager` selects `packager.tools.packager`, not the OPAE runtime namespace. Current-hash source supports create-gbs, gbs-info and get-rbf; same-hash historical native creation/help/readback corroborates syntax, not this future image. Installed schema requires `afu-top-interface.class`; AFU overrides convert clock strings to integers without saving source JSON. [Captured implementation](../ahls-persona-work21-caps01/gbs-prerequisites01/usr/lib/python3.9/site-packages/packager/tools/packager.py#L94), [AFU handling](../ahls-persona-work21-caps01/gbs-prerequisites01/usr/lib/python3.9/site-packages/packager/utils/afu.py#L97), [native precedent](../ahls-persona-work21-caps01/result-gbs01.json.gz).

After separate native acceptance of new `ofs_pr_afu.sof`, `ofs_pr_afu.pmsf` and `ofs_pr_afu.green_region.rbf`, minimum remaining qualification is **one bounded offline package/readback**, not afu_synth/full compile/refit. Reverify current tool/input hashes; bind an exclusive fresh output leaf and exact copied JSON/RBF. Define P as `work_fim24_caps03_assembly01/base01/build/syn/board/ia840f/syn_top` under `/home/uwb_student00/ahls/new_BSP`; G is the future separately bound leaf. Source-derived argv, **not authorization**:

```text
/usr/bin/packager create-gbs --gbs=G/ofs_pr_afu.green_region.gbs --afu-json=G/afu.json --rbf=G/persona.rbf --set-value interface-uuid:fc603c44-5c8f-5e94-bcbe-a5780030947c afu-image/clock-frequency-low:100 afu-image/clock-frequency-high:200
/usr/bin/packager gbs-info --gbs=G/ofs_pr_afu.green_region.gbs
/usr/bin/packager get-rbf --gbs=G/ofs_pr_afu.green_region.gbs --rbf=G/extracted.rbf
```

Require native zero/drain/preservation, full metadata equality allowing only interface insertion, two numeric clock replacements and default magic `0x1d1f8680`. Independently check 16-byte `XeonFPGA\xb7GBSv001`, unsigned little-endian four-byte serialized JSON length, strict in-bounds metadata and payload starting at20+length; do not use the creation object's dictionary-key count as header length. Require extracted/native and independently parsed payload **byte-for-byte equal** to accepted P/output_files RBF. [Writer/reader](../ahls-persona-work21-caps01/gbs-prerequisites01/usr/lib/python3.9/site-packages/packager/utils/gbs.py#L147), [serialized length](../ahls-persona-work21-caps01/gbs-prerequisites01/usr/lib/python3.9/site-packages/packager/metadata/metadata.py#L36).

**Verdict:** source/CLI basis established; fresh assembly inputs, output binding and current-artifact package/readback remain unperformed. Raw RBF is not runtime payload. Correct GBS does not establish live-shell compatibility, deployment, reset-entry, electrical or hardware acceptance; retain narrow CDC acceptance and raw false flags. [Boundaries](../fim24-caps03-cdc03/CDC-ACCEPTANCE73.md#L16).

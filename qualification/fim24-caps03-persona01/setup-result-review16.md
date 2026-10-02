# Actual matching-persona setup — independent result review16

**Verdict: ACCEPT WITH FINDING, narrowly for completed file generation and current-header acquisition for simulation/configuration preparation. NOT Quartus compile-ready.** F1 remains a real unresolved dependency; neither simulation nor persona implementation is accepted.

Reviewer: GPT-6 (`gpt-6-astra-900k`), `openai-codex`, substituted for unavailable GLM5.3. Review used local reads, in-memory hashes and parsing only: no project scripts/tests, native execution, SSH, Git or hardware. Only this report was written. Below, `O` means `completion13-readback/operation`; `P` means `completion13-readback/persona`.

## 1. Evidence and execution identity — PASS

Independently rehashed **100/100** members of `actual-result-freeze15.json`, with no size/hash mismatch. Freeze SHA256: `2f8fd9954da10aa47e66afca4881eae735861b11aa3e58d90b84cfac89954acc`. All **26** completion13 payloads reproduce their readbacks and index14 metadata: 20 configuration/source-list files and six operation records/logs.

`setup-inputs.admitted12.json` and `admission12-readback.json` are byte-identical, SHA256 **`3e1923e703bbc4925c7162a4718a00469dcfa7faf930e426b302035a3b84e094`**, matching dispatch and actual result. SPEC08/consumed09 and fresh QUALITY11/consumed12 identities reconcile with admission prerequisites and execution-review bindings.

`O/result.json` SHA256 is `7b1c4c9397ab51bdd09ee369630392a5aab2b76edf91ac0efea108aacaf74e67`; `status.json` differs only by its trailing newline. Both collected setup09 representations have identical parsed contents. The outer log's different digest correctly identifies the matching **gzip transport**, not the raw JSON.

The one operation ran **2026-10-02T07:51:30.078566+00:00 → 07:51:35.420960+00:00**, owned pane **@258/%258**. `candidate03/CMakeLists.txt:19–26` binds direct Quartus `--version` and `/usr/bin/afu_synth_setup --lib … --sources … <persona>` targets, not persona compilation. Actual logs identify **26.1.1 Build130 SC Pro**, the intended Work24 release/platform database and persona directory; the generated UUID header names the source JSON.

Configure/version/setup CMake and effective codes are **0/0/0**. Configure native status is **not applicable**; version/setup native zero is propagated through their direct CMake targets, not independently sampled helper exits. Completion-event wait/readback/outer statuses are zero and agree with the single waiter's channel/buffer and capture13. `complete` and `execution_clean` are true; diagnostics, postflight errors, timeouts, gate rejections and recorded surviving owned groups are empty/false. No live short-helper identity witness is claimed.

## 2. Copy, selected sources and preservation — PASS

Using the admitted-digest-matching release result recovered from `../fim24-pr-platform01/completion31-result.json.gz`, independently compared **every** original build entry with the native persona inventory: **3,438 unchanged**, comprising 3,437 byte-bound regular files and one unchanged relative symlink; **zero changed/missing**. Exactly five additions produce **3,443** entries, agreeing with `copy-reconciliation14.json`:

- `build/platform/platform_afu_top_config.vh`
- `build/platform/platform_if_addenda.qsf`
- `hw/afu.qsf`
- `hw/afu_json_info.vh`
- `hw/ia840f_ahls_memory.json` — symlink to the admitted AFU source JSON, not a rewritten JSON file.

Static `ofs_top.qdb` matches the release inventory, SHA256 `dbc1684ab873b3d317d20019430c99177653daf221e7471b227b1966d7ef30b4`. Exported interface identity matches admission/result: **fc603c44-5c8f-5e94-bcbe-a5780030947c**.

Parsed `P/hw/afu.qsf` independently: exactly the admitted **16 ordered SYSTEMVERILOG_FILE + two ordered QIP_FILE** assignments and AFU include directory. All 16 local selected bodies match admission/source-selection hashes. All **280** selected generated-fabric payloads match the admitted-digest-matching fresh fabric result and staged inventory. The **298-entry** staged inventory and **92 setup-tool** bindings equal prepared02. Actual postflight records all six preservation domains true: release, original fabric, AFU inputs, setup tools, runtime tools and controls.

These are captured preservation observations: capture13 rehashed the complete persona inventory; this review did not perform a new remote rehash. Its empty argv/operation-root process scan is **not exhaustive host/device ownership**.

## 3. Headers and policy — PASS within preparation scope

`P/hw/afu_json_info.vh:8–13` contains matching accelerator names, power0, `ofs_plat_afu`, and both UUID literals **`128'hd48dde9f_f551_578d_8bb0_69483ac95ec6`**, agreeing with unchanged JSON **auto-200/auto-100** policy. This native header replaces the older simulation-only `001122…` placeholder; old-header byte equality is neither expected nor claimed. No staged input shadows it with another UUID header.

The fresh platform header selects OFS_AGILEX/AGILEX/AGILEX7 and `ofs_plat_afu`; inherited PIM configuration retains native PCIe-TLP host and native-AXI local-memory definitions, including its platform-header include. Source/header identity does not establish RTL behavior or physical clock frequencies.

## 4. F1 — missing generated Quartus addenda target: OPEN

**`P/build/platform/platform_if_addenda.qsf:22` references `${THIS_DIR}/ofs_plat_if/par/platform_if_addenda.qsf`, absent from the complete persona inventory.** The present canonical target is `ofs_plat_if/par/ofs_plat_if_addenda.qsf`. Its bytes equal both the release capture and `legacy-addenda-reference14.qsf`, SHA256 **`5bfcfac51eee587bdb3b240031cc489e7066507d31d8b8e328114cd18e835fbd`**. Installed `emitcfg.py:425–428` explains the legacy filename emission; it does not resolve the missing file.

Earlier preparation not expecting a nested output does **not** make this generated Quartus dependency benign. Preserve the completed tree; do not rerun setup, fabricate tool-emitted collateral or silently waive closure. Any compatibility-name resolution belongs in a separately bound fresh compile copy, with source/path review and fresh authority. Copied release gates remain spent.

The retained direct Questa recipe (`../caps03-completion01/sim05.py:88`) uses explicit HDL/include arguments, not this QSF. Thus F1 does not invalidate acquired simulation headers, but also supplies no simulation pass. The separately captured **19 Questa2024.3 bindings** reconcile with their receipts; fresh compile/elaboration and both behavioral tests remain open. Full PCIe mapper/AFU-top/pr_slot integration, persona implementation, physical timing/reset, programming and hardware acceptance remain unproven.

# Final-snapshot STA SOURCE/API review07

**PASS with limits — no SOURCE/API blocker to parent runtime implementation.** This reviews one separately owned, state-changing final-snapshot multicorner STA, not runtime QUALITY, admission or timing acceptance. Reviewer: GPT-6 (`gpt-6-astra-900k`, `openai-codex`), substituting for unavailable GLM5.3. Local reads, hashes, AST/literal inspection and JSON reductions only; no Tcl, project imports, tests, CMake/vendor execution, remote access, Git or hardware.

## Evidence and fresh fitted copy

Independently verified **69/69 distinct frozen members**, exact sizes and SHA256, zero mismatches. [Freeze06](source-api-freeze06.json) SHA256: `301fe613ea9009bdebd49bd057f694c0061d2d39d715137a97902053b7d6c766`. Its 35 explicit sibling references are reused evidence, not executable authority. Raw copy/CMake/help exports match retained readbacks. The accepted FIT and consumed reviews remain settled; no reopening of vendor internals or the prior 220-member review. [Acceptance38](../fim24-caps03-physical01/FIT-ACCEPTANCE38.md); [consumption37](../fim24-caps03-physical01/result-reviews-consumed37.json).

[Copy metadata](copy01-readback/prepared-copy01.json) SHA256 `4140996eca7899e1d4278e35d6b0b531a1c9e85059cea3b8693d139b84b8b616` reconciles exactly with [completed-fit basis36](../fim24-caps03-physical01/sta-copy-basis36.json): **4025 entries/945,375,763 file bytes** and all **729 fitted-QDB bindings**, including unchanged static QDB. Only two symlinks' resolved-path metadata changes to the new root; target text/target hashes remain unchanged. Copy receipts record preservation of original fit, mapped, setup, release, external/archive inputs and tools. This is local verification of captured bindings, not a new remote database rehash or native snapshot-load test. [Copy preparation:44–82](prepare-copy01.py#L44-L82); [collection](copy01-collection.json).

## Exact STA roles

[Roles02](input-output-roles02.json) is a disjoint, complete partition: **3999 immutable +26 existing runtime outputs =4025**, every binding matching the current copy. The 26 are exactly:

- Two shared reports: `ofs_pr_afu.flow.rpt`, `ofs_pr_afu.sdc_constraints.rpt`.
- Twelve `_all/1/report.{cmp,fit,routing,rtm,syn,taw}.{model,rdb}` databases.
- Eleven enumerated timing/retiming caches across final/planned/placed/routed/retimed.
- One `legacy/1/runlog.db`.

The **280 physical/static members are a subset of the 3999**, not the entire protection boundary. QPF, `ofs_pr_afu.fit.qmsgdb`, structural snapshots and all remaining source/configuration/results stay immutable. The failed initial fit.qmsgdb classification was corrected before publication/native work; no FIT863 exclusion set survives. New STA/frequency/report-directory outputs are absent initially, not exemptions of existing inputs. Two future gates yield **4027 active/4001 critical** entries. Preserve complete original fit and mapped trees independently; never rewrite their binary snapshots. [Derivation02](role-derivation02.json); [plan05](source-plan05.json).

Supplemental path-only corroboration: all 26 equal the retained [25.1 STA list](../ahls-persona-work21-caps01/sta-input-roles01.json), SHA256 `fa539c1fe94ebb1cf3d0b1cbe58088dc25cb9f0a4d2747b7246e0daad56e5989`, after only `/_flat/25.1.0/` → `/_flat/26.1.1/`. This supplements the freeze; old hashes/authority are not reused and 26.1 runtime mutation behavior is not yet observed. Unlisted drift remains a rejection, not permission to broaden roles.

## Proposed QSF/CMake and installed API

Byte comparison and reconstructed [delta03](qsf-delta03.patch) prove exactly two substitutions: `build_gate_physical08.tcl` → `build_gate_sta06.tcl`, and `ia840f_physical_gate08.py` → `ia840f_sta_gate06.py`. Old gates remain; new bodies are future work. Everything else—including NUM36, seed1, PR_IMPL/static import, clocks, source selection and timing settings—is unchanged. The captured actual QSF still selects the spent fitter gate; do not open it before fresh controls/admission. [Candidate QSF](candidate03/ofs_pr_afu.qsf); [actual QSF](copy01-readback/project/ofs_pr_afu.qsf).

[Candidate CMake](candidate03/CMakeLists.txt) matches tested readback byte-for-byte: only version/timing custom targets, neither in ALL, exact project and `/opt/altera/26.1.1/quartus` checks, no synthesis/fit/assembly dependency. Six recorded configure/help/dry-run/refusal cases reconcile: four expected zero statuses, two expected nonzero refusals, no vendor invocation, copy preserved. These establish CMake behavior, not runtime gate correctness. [Receipt04](cmake-inert04.json); [timing dry-run](cmake04-readback/timing_dry.log).

Let `D=/home/uwb_student00/ahls/new_BSP/work_fim24_caps03_sta01/base01`, `J=D/build/syn/board/ia840f/syn_top`. Native identity is `/opt/altera/26.1.1/quartus/linux64/quartus_sta`, cwd `J`, argv:

```text
ofs_top -c ofs_pr_afu --snapshot=final --multicorner=on --do_report_timing --do_report_cdc_viewer
```

CMake uses the separately bound `bin/quartus_sta` launcher. Reused help identifies **26.1.1 Build130**; its tool-binding literals equal current copy metadata. Help supports final snapshot, all available operating conditions and hierarchical CDC transfer tables. Do not import fitter-only read/write-settings flags absent from STA help. `--do_report_timing` reports one worst setup path per destination clock, not exhaustive coverage. [Version](../fim24-caps03-physical01/help01-readback/sta_version.log); [STA help](../fim24-caps03-physical01/help01-readback/sta_help.log); [snapshot](../fim24-caps03-physical01/help02-readback/sta_snapshot.log); [multicorner](../fim24-caps03-physical01/help02-readback/sta_multicorner.log); [timing](../fim24-caps03-physical01/help02-readback/sta_do_report_timing.log); [CDC](../fim24-caps03-physical01/help02-readback/sta_do_report_cdc_viewer.log).

## State-changing helper/output contract

The unchanged QSF hook sources clock computation **before** OFS reporting. Current-copy hashes match captured PIM JSON/configuration/addenda/options helpers. Computation deletes/recreates `user_clock_freq.txt`, selects rates and rereads SDC/updates timing; reporting replaces `timing_report`, iterates available corners and setup/hold/recovery/removal/MPW, and emits bounded failing-path detail. Preserve source JSON auto-200/auto-100 separately from generated frequency metadata and the bank0 application's **3.000ns** requirement. [Hook](copy01-readback/project/ofs_partial_reconfig/ofs_sta_report_script_pr.tcl); [computation:31–96,351–362](copy01-readback/project/ofs_partial_reconfig/user_clock_freqs_compute.tcl#L31-L362); [reporter:47–88](copy01-readback/project/ofs_partial_reconfig/report_timing.tcl#L47-L88); [clock contract](../fim24-caps03-physical01/clock-stage-review07.md).

Fmax selection excludes hold/removal despite its broad comment; missing-clock/slack **10000MHz** fallbacks are not measured passes. Capture `.sta.rpt`, `.sta.summary`, dedicated signoff DRC, clocks, OFS pass/fail summaries and computed frequencies. Only the failure summary may be empty; require other primary outputs nonempty. Neither native zero nor an empty fail file establishes numerical/coverage acceptance. No assembly/GBS hook is authorized. [Fmax implementation:170–284](copy01-readback/project/ofs_partial_reconfig/user_clock_freqs_compute.tcl#L170-L284); [output contract](source-plan05.json#L93-L119).

## Limits retained

Parent runtime implementation/QUALITY, exact issuance/readback/preflight and independent numerical/coverage review remain next—not defects in this source proposal. Preserve 36 logical CPUs allowed/NUM36 requested, 64GiB per-process, 60/60/1800s deadlines and 32MiB polled logs; these do not promise 36 engine workers, aggregate containment or a hard log quota. [Plan](source-plan05.json).

Retain 139 constraint diagnostics, 1098 ignored assignments including 16 current reset-synchronizer rows, 47 unused PR ports, additional reset cycles **3 clk_sys/7 bank0**, and four electrical omissions. Actual propagation, all-corner timing, current PIM CDC/synchronizers/skew/net-delay, exceptions and unconstrained coverage remain open. None requires an unchanged refit before analysis; none is waived. No timing, reset-entry, electrical or hardware acceptance is granted. [Diagnostic/reset35](../fim24-caps03-physical01/fit-diagnostic-reset-review35.md).

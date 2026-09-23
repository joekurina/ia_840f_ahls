# CAPS01 Work21 native assembly01 — FINAL independent review

**Status: FINAL. Specification: PASS. Evidence/acquisition quality: PASS WITH FINDINGS. Recommendation: ACCEPT WITH FINDINGS the bounded completed native assembly01 stage.** No concrete blocker to that stage's acceptance was found. This is not warning clearance, timing/DesignClosure acceptance, independently decoded QDB/image equivalence, GBS completion, deployability, runtime PR or hardware acceptance.

## Evidence notation and boundary

`CAP` is `qualification/ahls-persona-work21-caps01` under `/home/joe/Projects/Thesis/AHLS/new_bsp/new`. Short paths are relative to CAP. `LOG` is `artifacts-asm01/assembly.log`; `ASM` is `artifacts-asm01/persona/build/syn/board/ia840f/syn_top/output_files/ofs_pr_afu.asm.rpt`; `QSF` is the adjacent `ofs_pr_afu.qsf`. `OUT` denotes that `output_files` directory. Native line citations use the original captured files.

`RAW` denotes inert gzip/JSON decoding of `result-asm01.json.gz`; `PRE` denotes `result-asm-prereq02.json.gz`; `STA` denotes the completed predecessor `result-sta01.json.gz`. `CFG` denotes the literal `C` assignment at `run-asm01.py:5`, decoded using AST/literal parsing, never import or execution. JSON citations identify exact keys rather than invented line numbers for one-line serialized records.

Read `ASM-SCOPE01.md` first, then `RESULTS-ASM01.md`, then the exact frozen package. This review used only local frozen-file reads, SHA256, AST/literal/base64/gzip decoding and report parsing. An early IN_PROGRESS checkpoint preceded this FINAL report. No runner, vendor tool, simulator, Git, network/SSH, device or hardware operation was executed; no implementation or task state was changed. No mutable CURRENT or separately active sibling-review artifact was polled or used. Frozen accepted predecessor reviews are reused, not re-performed. Only this report was written. [Scope: `ASM-SCOPE01.md:3–9`.]

## 1. Specification review — PASS

### 1.1 Required stage, context and claims

| Requirement | Independent verification and disposition |
|---|---|
| One completed standalone assembly of the actual CAPS01 Work21 persona | RAW has exactly one command, label `assembly`, with `complete` and `success` true. Exact command below; `LOG:9,11–12,29–35,67–71` shows actual PIM loading, Assembler identity, final snapshots and completion. Not an empty-template, source-only or component-only compile. |
| Matching Work21 release03, target and PR revision | `CFG.release` is `/home/uwb_student00/ahls/new_BSP/work_fim21_pr_platform01/release03`; `CFG.setup_root` is completed CAPS01 `sta01`. `ASM:43–50` reports successful `ofs_pr_afu`, top `top`, Agilex 7, `AGFB027R25A2E2V`. `QSF:11–12,26,111–114` binds the exact family/device/top, green_region, imported root QDB and `PR_IMPL`. Historical comments or QPF headers do not override native identity. |
| Native Quartus 25.1.0 Build 129 | `LOG:12` and `ASM:3` identify `25.1.0 Build 129 03/26/2025 SC Pro Edition`. Captured launcher/runtime hashes and PID-qualified native observations agree (§2.3). |
| Application UUID continuity | `CFG.uuid`, RAW.uuid and captured AFU JSON agree on `673c03a1-cef3-4c82-bf10-b12c247d9718`; generated `artifacts-setup01/persona/hw/afu_json_info.vh:8–13` carries that UUID and `ofs_plat_afu`. This establishes source/config identity, not independently decoded binary UUID or hardware authentication. |
| Unchanged source, clocks and SDC policy; only stage-hook QSF delta | All 13 AFU payloads, 255 generated records, source list, AFU JSON and release inventory match completed CAPS01 setup/synthesis/fit/STA configurations. The exported QSF is exactly predecessor bytes with the two STA hook names replaced by ASM hook names, with no other delta. The inherited selected user-clock file remains byte-identical, 100/200, and requested AFU JSON remains `auto-100`/`auto-200`. No frequency or timing-policy correction is claimed. |
| New persona images distinguished from inherited static images | Three required new persona SOF/PMSF/PR RBF files are present in verified archive/local bytes and absent from PRE's complete pre-copy inventory. Three inherited static images remain hash/size-identical to PRE and matching release records (§1.3). |
| Warning and closure limitations preserved | All 19 occurrences classified in §3: 17 Warning18502, one Critical Warning20727 and one Warning20536. Existing reset/BMC/CDC/PR/lifecycle and DesignClosure failures are not waived. |
| No substituted acceptance or additional execution gate | Accepted source/unit/setup/synthesis/fit evidence is reused. Completed final STA is bound as predecessor acquisition only; its independent acceptance is separate, neither claimed nor awaited. GBS, deployability and hardware goals remain excluded. Vendor DDR simulation remains **SKIPPED BY USER**. This review does not grant, withhold or extend execution authority. |

Exact completed native command:

```text
/opt/altera/25.1/quartus/bin/quartus_asm --read_settings_files=on ofs_top -c ofs_pr_afu
```

The exclusive native project cwd was:

```text
/home/uwb_student00/ahls/new_BSP/work_ahls_persona_work21_caps01/asm01/persona/build/syn/board/ia840f/syn_top
```

### 1.2 Exact source and predecessor chain

The mandatory predecessor archive is **5,747,132 bytes**, SHA256:

```text
1b306237f3f8edebfddd23753cab0a9777f1db725d92e0e0324e2f12be990834
```

Its local archive hash equals `CFG.predecessor_result_sha256`, `PRE.sta_result_sha256` and `asm-input-roles01.json.predecessor_result_sha256`. The predecessor receipt is complete/successful with one final-snapshot multicorner STA command, native/effective zero, no timeout or recorded survivors. This verifies the input acquisition, not independent STA signoff. The prerequisite collector and assembler runner check that exact digest before use (`capture-asm-prereq02.py:4–8`; `run-asm01.py.in:17–23`).

Reconciled all **5,749 predecessor critical bindings**: **5,479 copied-persona** hashes agree with PRE's pre-copy inventory and **270 external** hashes remain in the ASM critical map. All **726 predecessor QDB output records** agree with PRE's QDB entries. Thus the assembler uses the completed CAPS01 physical state, not an inferred or interrupted predecessor.

The complete **4,936-record release inventory**, all **13 AFU source payloads**, **255 generated records**, source list, JSON and UUID compare equal across the frozen setup/synthesis/fit/STA/ASM literal configurations. The source payloads were base64-decoded and checked against their own sizes/SHA256. `afu/csr_mgr.sv` is **22,655 bytes**, SHA256 `053b9855aa860c410337f5cae7e6160c6086726903cf988a1d35f032cb7a0b93`, and equals the separately accepted `../dma-csr-metadata01/csr_mgr-candidate01.sv` bytes. This confirms reuse of the accepted additive raw-capability source; it is not a new CSR unit or mapped-function review.

The imported `ofs_top.qdb` is **83,178,648 bytes**, SHA256 `7f8f25463afe3ae95d9660ddf4c5c6755d6704f828fd400de34ae38fa2aa0fc8`, matching the release record and PRE/CFG inventory. It is an immutable critical input, separate from the 344 protected compiler-snapshot entries below. Its remote binary was not exported for independent decoding.

The accepted fitter disposition is reused exactly from `FIT-ACCEPTANCE.md:3–21` and frozen FINAL `fit-independent-review01.md`, SHA256 `59a3cc5f80fd6b64b027e4d7fcfe40e8391505f2193e643a12e173dc2b0b5410`. Fitted Reconfigurable green_region, retained physical region and native **100.00% static-core preservation excluding PR subblocks** remain native-report claims, not independently decoded equivalence. No new fit, source/unit or STA acceptance is substituted here.

### 1.3 Image identities and the precise generation claim

All paths below are within OUT. Every image's archive base64 decoded successfully, matched recorded size/SHA256, matched `RAW.output_hashes`/`RAW.programming_images`, and equaled local captured bytes.

| Class | File | Bytes | SHA256 |
|---|---|---:|---|
| **New persona** | `ofs_pr_afu.sof` | 9923144 | `d64f296cec0e8dbcc55292c2e566c09bef48e52fcce3a8d20287dc86b9a68f3a` |
| **New persona** | `ofs_pr_afu.green_region.pmsf` | 9222093 | `568f4927a093e78843e23bdab5e706cafbd6c15c05280d0ed06e91e5811ce783` |
| **New persona** | `ofs_pr_afu.green_region.rbf` | 9527296 | `25feda96e98155e39edc4e9188f70a1eb17dc1470f8b1525793bbb4d5d36b7e1` |
| **Inherited static baseline** | `ofs_top.sof` | 7901287 | `bbede03c8c432e50ae6ae1f30739af3bfd3330781776d2c623269cc131b38ca4` |
| **Inherited static baseline** | `ofs_top.static.msf` | 3309305 | `da2395b08b6713e6e4335b488f5757e052d583b44b908837e8d18747bb151705` |
| **Inherited static baseline** | `ofs_top.green_region.pmsf` | 7202780 | `27b3e78810d54cf452dcc1aa834c62584290c9d3358e84f00a374294426a3663` |

The three persona paths are absent from `PRE.inventory`/`CFG.persona_inventory`/`RAW.original_setup_inventory`; the runner requires an absent destination root and a bound copy before assembly (`run-asm01.py.in:5,22,34–35`). These are newly emitted stage outputs, not inherited placeholder/static images. The three static files match both preinventory and the corresponding `CFG.release_inventory` entries; they were not newly built here.

`ASM:231–236` explicitly lists **SOF and PMSF only** in Assembler Generated Files. The PR RBF claim is instead supported by its actual captured new bytes, exact output identity, absent-before record, exclusive stage and native PR-RBF setting **On** (`ASM:99`; RAW.files). I do not pretend that the Generated Files panel lists the RBF.

`LOG:59–61` records use of the inherited green-region PMSF, static MSF and root SOF for mask/root-region checks. Successful assembly supports that native baseline-check result at the tool's scope. It is not independent QDB or image functional equivalence, physical PR transport qualification or runtime safety. The native PR-region/design/keyed hashes (`LOG:62–66`; `ASM:245–257`) are not substituted for file SHA256. The logged FME interface UUID `fc4bf1c1-760f-5cd7-8040-b3e86fa0d31e` is also distinct from the application UUID.

**No GBS claim.** `QSF:123–124` configures a post-flow script, but the observed command is bare `quartus_asm`; neither RAW.commands nor LOG records a post-flow/packager invocation. Captured `asm-prerequisites02/files/ofs_partial_reconfig/gen_gbs.tcl:75–123` describes a distinct operation consuming RBF, AFU JSON, FME interface UUID and user-clock settings before calling `packager create-gbs`. It was read, not executed. No GBS is among captured exports; because the collector's selection does not include `.gbs`, this is **not** a complete-filesystem absence proof. Neither the RBF nor the SOF/PMSF is presented as a verified deployable GBS.

## 2. Evidence/acquisition quality — PASS WITH FINDINGS

### 2.1 Frozen package and complete transfer verification

Independently rehashed **165/165 frozen members, 429,678,751 bytes, zero mismatches** against `asm-review-package01.json`, whose SHA256 is:

```text
49b20b85450243a21046da8f6869a3da8e82b4c5380b3bddd6b8b61a1ed0eee1
```

The assembly archive is **35,648,567 bytes**, SHA256:

```text
6e59dcf930e814b09106ef4710d2c67327700a9fe4ef87193608b75b1c3430f2
```

That matches `outer-asm01.json` and frozen package metadata. Decoded and verified **all 15 exports**, not a sample: assembly log, accepted gate event, QSF, QPF, ASM report, flow report, SDC-constraints report, inherited signoff DRC report, inherited selected-clock file and all six images. Their exact key set, sizes, hashes, base64 payload bytes, RAW.output_hashes and local exports agree. No export is accepted merely because the command banner or parent summary says it exists. Full per-member identities are retained in the frozen package and RAW.files/output_hashes; the parent's `asm-parent-verification01.json` agrees with these independent checks.

The collector requires the unique completion channel, reads outer status independently, checks the archive digest, validates the run identifier and each safe relative member path, and creates files exclusively (`await-asm01.py:11–24`). Completion notification alone is not the verdict. The dispatch's embedded-runner digest matches frozen `run-asm01.py` SHA256 `697f22d573ea3f285600ce09df57e03c56803b8d121403ebccf571fc3be66567`. The outer wrapper itself is represented by its recorded dispatch hash, not exported wrapper bytes; independent wrapper reconstruction is not claimed.

### 2.2 Exact inputs, permitted mutable roles and preservation

AST/literal-decoded CFG inserted into `run-asm01.py.in` reproduces the frozen runner **byte-for-byte**; its AST also matches. The embedded guard and helper scripts were inspected as text/AST only. The runner's preconditions bind the completed predecessor, release, source, generated records and tools, make an exclusive symlink-preserving copy, and replace only the two stage-hook references. Source-list/JSON critical hashes were reconstructed from actual captured bytes, not a guessed JSON serialization (`run-asm01.py.in:17–68`).

| Evidence class | Independently checked result |
|---|---|
| Complete pre-copy inventory | **5,516 exact records**; equality of PRE.inventory, CFG.persona_inventory and RAW.original_setup_inventory, including the one recorded AFU-JSON symlink. PRE captures size/mtime stability per read (`capture-asm-prereq02.py:18–21`). |
| Runtime mutable roles | **26 unique exact paths**, present in preinventory and equal across CFG, RAW and `asm-input-roles01.json`. Categories: two text reports, twelve report-database files, eleven timing/RTM cache files and one `runlog.db`. Not a blanket QDB/source exemption. No additional ASM exclusion was introduced. |
| Actual mutable-path changes | **Five changed, 21 unchanged**. Changed paths are `output_files/ofs_pr_afu.flow.rpt`, `output_files/ofs_pr_afu.sdc_constraints.rpt`, and QDB `_all/1/report.cmp.model`, `_all/1/report.cmp.rdb`, `legacy/1/runlog.db` under the exact `_compiler/ofs_pr_afu/_flat/25.1.0/` prefix. All post-state metadata agrees with corresponding RAW output/QDB records. This is hash/role accounting, not a decoded SQLite semantics claim. |
| Protected physical snapshots | **344 unique entries**: 34 partitioned, 33 synthesized and 277 final. All are disjoint from mutable roles, included in critical bindings, and all post-ASM QDB sizes/hashes equal preinventory. The imported root `ofs_top.qdb` is separately immutable. |
| Critical inputs | Independently reconstructed **all 5,762 hashes**, exactly equal to RAW.input_hashes: 5,490 nonmutable copied paths with the QSF hash replaced by exact post-hook bytes, the 13 AFU/255 generated bindings, new Python/Tcl guards and captured source JSON/list. |
| New STA evidence stays immutable | All 13 `asm-input-roles01.json.new_STA_files_immutable` paths remain critical inputs, including predecessor STA reports, signoff DRC, selected clocks, STA report databases and copied STA guards. No STA-report exclusion was added for assembly. |
| QDB postinventory | **729 output records** versus 726 before. Only three preexisting QDB records changed, all among the explicit mutable roles above. Three new report artifacts appear: `_all/1/report.asm.model`, `_all/1/report.asm.rdb`, `legacy/1/ofs_pr_afu.asm.qmsgdb`. No unaccounted preexisting QDB hash change was found. |
| Preservation verdict | RAW `setup_unchanged`, `release_unchanged`, `tools_unchanged`, `bound_inputs_unchanged` are all true; `postflight_errors` is empty. The exact runner checks these predicates in its final success expression (`run-asm01.py.in:122–143`). |

The exported QSF matches `RAW.source_delta.qsf_after` exactly; PRE's QSF matches `qsf_before`. The complete delta is only `build_gate_persona_sta01.tcl` → `build_gate_persona_asm01.tcl` and `ia840f_persona_sta_gate01.py` → `ia840f_persona_asm_gate01.py` at lines 2–3. Both before and after retain the sole processor setting36. QPF, selected clocks and dedicated signoff DRC bytes equal completed STA exports. The SDC-constraints report differs only in its timestamp header; it is not fresh SDC-policy evidence.

Preservation findings describe the captured checks and available postflight hash records, not a fresh remote audit or independent binary-netlist decode. The 344 protected entries are files, not 344 independent entire database trees.

### 2.3 Native identity, finite resources, cleanup and statuses

The sole accepted callback event (`artifacts-asm01/gate-events.jsonl:1`), RAW command and captured live snapshot all agree on PID **143823**, start ticks **16410993**, exact project cwd and native argv. Runtime executable:

```text
/opt/altera/25.1/quartus/linux64/quartus_asm
SHA256 b7580ae1a942bf02c5f8c974e265edd83caa2da65eefcf5f5b2744348cc60f98
```

The bin launcher is 2,449 bytes with SHA256 `222fa669a9b10a6d443268fdc506e885597b5867e77bbf13ff656b8a272933dd`; the native runtime is 225,384 bytes. PRE.tools and CFG.quartus_tools agree. The live snapshot collector checked executable hash and exact context before recording the snapshot (`capture-asm-snapshot01.py:9–14`), and the guard checks runtime hash, exact native context, PID/start-qualified runner ancestry, every critical input and QSF identity. These are captured installed-tool measurements, not local remeasurement of remote executables.

The copied Tcl guard removes only LD_LIBRARY_PATH when invoking its Python checker; the checker requires `OPAE_PLATFORM_GEN` absent, Quartus override25.1, `persona-asm-only` scope and readiness false. The runner also watches explicit callback rejection evidence. One accepted callback and no rejection are recorded. Historical readiness/scope fields do not become a new permission request through this review.

| Completion/resource observation | Verified value and limit |
|---|---|
| Native/effective/outer | **0 / 0 / 0**. Native is the vendor exit; effective is the runner command/cleanup status; outer is the transport wrapper result. Separate RAW success/preservation predicates and actual output checks also pass. |
| Native receipt interval | `2026-09-23T22:00:38.140604+00:00` through `2026-09-23T22:06:48.872269+00:00`. LOG independently prints PID143823 and successful footer. |
| Timeout and owned cleanup | `timeout=false`, `descendants_observed_at_leader_exit=[]`, `descendants_after_leader=false`, `owned_group_live_after=[]`; diagnostics and postflight errors empty. No recorded owned survivors or cleanup defect. |
| Finite ownership mechanism | Exclusive log/new session, 1,800-second deadline, same-group helper checks and unreaped leader until possible group termination is finished (`run-asm01.py.in:85–117`). This establishes recorded owned-process cleanup, not whole-host containment or proof about arbitrary escaped processes. |
| Historical headroom | 124149317632 bytes available memory; 1272400805888 bytes free disk; no enumerated competing tools. Not a current host-state assertion. |
| Affinity/resource policy | CPUs0–35, QSF36, native setting36 (`ASM:59`); snapshot confirms the full allowed affinity and 68719476736-byte soft/hard address-space limit. **64 GiB is per-process**, not aggregate containment. No claim of 36 simultaneously active workers. |
| Native report values | Footer **0 errors /19 warnings**, elapsed **00:06:09**, peak virtual **19405 MB** (`LOG:67–70`). Flow report's Assembler module elapsed **00:06:07** is a separately labeled field (`OUT/ofs_pr_afu.flow.rpt:421`), not forced to equal the footer. |

### 2.4 Acquisition limitations and resolved local-check issues

**Q1 — Image presence is not part of the runner's success expression.** `run-asm01.py.in:142` checks completion, effective status, diagnostics/banner and preservation, but does not require named image members; collection at lines131–135 skips absent paths. Therefore generic `RAW.success=true` alone is insufficient for generation acceptance. In this completed run the parent explicitly verified all three required new images, and this review independently verified their presence, before-state absence, exact sizes/hashes and archive/local bytes. That closes the actual stage's evidence requirement; it does not justify a mandatory unchanged rerun or an implementation edit during review.

**Q2 — Preparatory failure is retained, not concealed.** `outer-asm-prereq01.json` preserves outer125 with no result and no assembler execution. Its exact original traceback was not retained, so I do not invent it. The first collector asserted that installed paths existed (`capture-asm-prereq01.py:29–32`); successor PRE explicitly records `/usr/bin/afu_synth` and the guessed `.../common/tcl/internal/flow.tcl` missing while capturing the release-local `release03/bin/afu_synth`. This explains a supported recovery path, not a claim of the exact lost exception. Successor prerequisite outer0 and the separate help-only native0 result are hash-bound preparatory evidence, not extra assembly runs or substitutes for the completed native receipt.

The prior 92 tool bindings are unchanged; ASM adds only the captured release-local `bin/afu_synth` binding, bringing that map to93. Actual ASM launcher/runtime bindings are separately pinned. Missing guessed package paths do not establish an assembler compatibility failure and do not justify inventing packaging completion.

`RESULTS-ASM01.md:27` discloses the parent's local JSON-dictionary `.encode()` schema mistake; critical JSON verification here used exact captured JSON bytes. My initial cross-stage comparisons likewise encountered the setup schema's `files` rather than `source_files` key and an overstrict whole-tool-map equality assumption; explicit schema handling and enumeration of the single added binding resolved both. These were local analysis assumptions, not source drift or native failures. No evidence/runner bytes were modified, and no native work was repeated.

## 3. Warning classification and inherited findings — no waivers

Reparsed LOG with leading-whitespace-aware numbered Warning/Critical Warning matching. All **19 occurrences**, including original line, severity, ID and complete message, equal `asm-warning-ledger01.json.occurrences`; its source hash, counts and footer agree. There are **18 Warning and one Critical Warning**. The ASM Messages panel contains the identical occurrence sequence; those copied messages are not counted twice. No numbered/Error/Fatal-colon diagnostic is present in the assembly log or ASM report.

### A1 — Warning18502: all 17 current/base SDC assignment differences retained

**Classification: confirmed inherited assignment-list differences; constraint/CDC adequacy remains unresolved.** The full 17-message sequence equals the already accepted fit log's 18502 sequence (`artifacts-fit01/fitting.log:53–69`). These are new assembly diagnostic occurrences of inherited differences, not an assembly source-policy change. Neither export/path conventions nor successful generation prove the constraints harmless or complete.

Each row below is one Warning18502, with exact path and side reported by the native message. All retain this classification; no occurrence is omitted or waived.

| LOG line / ASM line | Native assignment-list difference | Exact file |
|---|---|---|
| 41 /186 | Current-only | `ofs_top.out.sdc` |
| 42 /187 | Current-only | `../../../../platform/ofs_plat_if/rtl/utils/prims/ofs_plat_prim.sdc` |
| 43 /188 | Current-only | `../../../../platform/ofs_plat_if/rtl/utils/quartus_ip/ofs_plat_utils_avalon_dc_fifo.sdc` |
| 44 /189 | Current-only | `../../../../platform/ofs_plat_if/rtl/utils/quartus_ip/ofs_plat_utils_mf_dcfifo.sdc` |
| 45 /190 | Current-only | `ofs_partial_reconfig/user_clocks.sdc` |
| 46 /191 | Base-only | `../../../../ofs-common/src/common/port_gasket/user_clock/user_clock.sdc` |
| 47 /192 | Base-only | `../../../../ofs-common/src/fpga_family/agilex/sys_pll/sys_pll.sdc` |
| 48 /193 | Base-only | `../../../../ofs-common/src/common/mem_tg/tg_axi_mem/mem_ss_tg/mem_ss_tg_axi_100/src/mem_ss_tg_axi.sdc` |
| 49 /194 | Base-only | `../../../shared_config/setup_user_clock_for_pr.sdc` |
| 50 /195 | Base-only | `afu_with_pim/afu/build/platform/ofs_plat_if/rtl/utils/prims/ofs_plat_prim.sdc` |
| 51 /196 | Base-only | `afu_with_pim/afu/build/platform/ofs_plat_if/rtl/utils/quartus_ip/ofs_plat_utils_avalon_dc_fifo.sdc` |
| 52 /197 | Base-only | `afu_with_pim/afu/build/platform/ofs_plat_if/rtl/utils/quartus_ip/ofs_plat_utils_mf_dcfifo.sdc` |
| 53 /198 | Base-only | `../../../shared_config/fim_dcfifo.sdc` |
| 54 /199 | Base-only | `../../../shared_config/top.sdc` |
| 55 /200 | Base-only | `../setup/bti_refclk.sdc` |
| 56 /201 | Base-only | `../../../shared_config/pmci_top.sdc` |
| 57 /202 | Base-only | `../setup/bwbmc.sdc` |

Before any stronger timing/CDC assertion, the relevant actual constraint/object/exception coverage must support that assertion. This is a retained claim limit, not a request to rerun unchanged fit/STA or alter SDC merely to suppress the list differences.

### A2 — Critical Warning20727: unused PR inputs remain

**Classification: confirmed native unused boundary inputs; correspondence/runtime implications remain open.** One occurrence at `LOG:36` / `ASM:181`, followed by four informational20728 details at `LOG:37–40` / `ASM:182–185`. All four are under `afu_top|pg_afu.port_gasket|pr_slot|afu_main` in green_region: `clk_div2`, `clk_div4`, `uclk_usr`, `uclk_usr_div2`.

Four detailed names in this assembly log do not replace the accepted fitter's **46 dangling-input rows** or clear response-ID/user/remote-STP/transport correspondence. Reconfigurable region presence and baseline-mask success do not establish that pruned metadata or clocks satisfy functional/runtime PR contracts. Preserve fit F2 and synthesis R1/R2; no speculative noprune or region-setting repair is justified solely by this warning (`fit-independent-review01.md:119–123,161–167`; `FIT-ACCEPTANCE.md:14,19`).

### A3 — Warning20536: obsolete generic RBF setting, not absent PR RBF

**Classification: confirmed ignored legacy setting; current requested PR-image generation is independently observed.** One occurrence at `LOG:64` / `ASM:209` identifies exactly `GENERATE_RBF_FILE`, active in `QSF:86`. `ASM:99` separately reports Generate Partial Reconfiguration Raw Binary File On; generic Generate programming files is Off at `ASM:138`. The commented `GENERATE_PR_RBF_FILE` line at `QSF:66` is not falsely treated as an active assignment. Actual new PR-RBF bytes are verified in §1.3.

Thus this warning is real, not suppressed, but it is not evidence that the observed PR RBF is missing. The warning's general PFG/CPF advice is not authority to run those tools, edit the frozen QSF or impose an unchanged native rerun. It supplies no GBS/deployability acceptance.

### A4 — Prior electrical, reset, CDC, DesignClosure and lifecycle findings remain

Retain the accepted fitter **F1–F6**, synthesis **Q1–Q4/R1/R2**, and their original qualifications in full (`FIT-ACCEPTANCE.md:13–21`; `fit-independent-review01.md:99–169`):

- Fitter resource-report/request distinctions remain historical, not measured assembly worker utilization.
- **46 PR dangling-input rows**, response/credit/ID/user-metadata and burstcount correspondence are not cleared by the four assembly clock details or native static preservation.
- Current/base SDC differences, ignored/problematic constraints, unmatched filters and **1,098 ignored implementation-assignment rows** remain; that row count is neither 1,098 warnings nor 1,098 proven independent defects.
- BMC pins `bwbmc_bmc_irq`, `bwbmc_bmc_mst_en_n`, `bwbmc_fpga_max_miso` retain missing termination/slew findings. No electrical adequacy or guessed board remedy is inferred.
- Native reset requirements remain **two additional sys-clock cycles and four additional EMIF0-core cycles**, not total reset widths or proof of adequate assertion/deassertion, retimed reset reachability or initialization.
- PR initial values, synthesized **5/13 failed enabled DRC rules /14 violations /0 waived**, ineffective swept freeze logic, legacy capability/status/clock limitations, and R1/R2 all-bit/metadata correspondence limits remain.
- Descriptor/kernel drain, outstanding response retirement, posted-write fences, freeze/PR handoff, reset/CDC/initialization and pinned host-buffer ownership/lifetime are not proven by image generation, status bits or fixed delays.

The carried dedicated signoff report is byte-identical to completed STA and still says **22 of 88 rules failed** (`OUT/ofs_pr_afu.tq.drc.signoff.rpt:123–214`; its 88-row table has zero waived entries). Frozen `RESULTS-STA01.md:13–17` records **TimingClosure PASS / DesignClosure FAIL**, **10 disabled rules**, unconstrained I/O and 645 nonnegative constrained-domain records. Those are predecessor observations, not a new STA review or full signoff here. Assembly neither clears DesignClosure nor converts constrained-domain numerical results into universal timing/reset/CDC adequacy.

Vendor DDR simulation remains **SKIPPED BY USER**. No acceptance of physical DDR/PCIe/OPAE, numerical hardware, programming, reset/driver/reboot operations, runtime PR, host recovery, durable QSPI boot or deployability is made.

## 4. Final recommendation

1. **ACCEPT WITH FINDINGS completed CAPS01 Work21 native assembly01**, bound to the exact frozen package, source/static/tool context, successful native/effective/outer0/0/0, preserved inputs, recorded owned cleanup and verified new SOF/PMSF/PR-RBF bytes.
2. Preserve all A1–A4/Q1–Q2 findings and inherited fitter/synthesis/STA limitations. Acceptance is of this completed generation stage, not warning/constraint/reset/DesignClosure clearance, independent binary equivalence, GBS completion or hardware safety.
3. No unchanged native rerun, source/unit/fit/STA repeat, implementation correction or new execution-permission gate is needed to finish this review. Ordinary safe continuation remains the parent's responsibility under existing project scope. Separate STA acceptance is not claimed or awaited.
4. No binary image publication was performed. Only `CAP/asm-independent-review01.md` was created/updated; its full SHA256 is returned separately to avoid a self-referential digest.

# Independent review 01 — Work21 AHLS persona

Status: **FINAL**

## Verdict

**PASS WITH FINDINGS — accept the completed native OPAE setup and the bounded evidence of actual guarded AHLS/DMA/page-safe-bank mapped synthesis in the matching Work21 PR context.** No blocking source defect or justified corrective RTL delta was established within that scope.

This does **not** turn synth01 into runner success: native/effective **0/0**, outer **125**, `success=false` and `bound_inputs_unchanged=false` remain the original result. The independent exact-delta reconciliation supports accepting the native mapping evidence despite the runner's confirmed input/output-role defect. Do not rerun unchanged synthesis to manufacture a green receipt.

This is not fitted utilization, timing/CDC/reset signoff, mapped-functional equivalence, a persona GBS, safe runtime PR, physical DDR qualification or hardware acceptance. Future fit requires a fresh source-bound stage scope, not reuse of this synthesis authority. **Hardware goal incomplete.**

## 1. Specification first and review boundary

Read `SCOPE.md`, `SETUP-RESULTS01.md`, `RESULTS-SYNTH01.md` and `NATIVE-DELTA-DISPOSITION01.md` before assessing source and native evidence. The contract is coherent:

- Compose the accepted guarded AFU with the real Work21 static import and `green_region`, using board top `top`, part `AGFB027R25A2E2V`, project `ofs_top`, revision `ofs_pr_afu`, Quartus 25.1. Do not fit the previous naked `ofs_plat_if` diagnostic or invent card pins/constraints.
- Use installed OPAE setup machinery, select the real AFU rather than the `OPAE_PLATFORM_GEN` empty template, preserve accepted sources and originals, and distinguish setup from mapping.
- Exclude fit, STA, assembly, programming-image generation and all live FPGA/MMIO/driver/reset/reboot operations from these stages. Vendor DDR simulation remains **SKIPPED BY USER**.

Reused `../ahls-memory-pim03/independent-review01.md`, FINAL bounded PASS, SHA256 `67c967fda957c13ce52ea4690c76e52b4c826d5e9a97aee34998a7db49402349`, for the accepted dependency published as `c1e675730dc802bc8a0f999c4aa5b7d43ce81cf2`. Its R1/R2 and other limits remain open; its unchanged acceptance gate was not reopened. The separate release03 generation review is not decided here. Matching static identity is checked through retained inventories and the supplied parent-verified release chain; this review neither waits for nor represents that other review as completed.

Only local reads, inert AST/literal/base64 decoding, report parsing and hashing were performed. No runner or installed tool module was imported/executed; no SSH, native/vendor/simulator/device execution, source edit, git operation or task transition occurred. This report was written early as **IN_PROGRESS**, then replaced by this FINAL report. It is the sole authored file.

Paths below are relative to `/home/joe/Projects/Thesis/AHLS/new_bsp/new`:

- `P` = `qualification/ahls-persona-work21-01`.
- `U` = `qualification/ahls-memory-pim03`.
- `A` = `P/artifacts-synth01`; `J` = `A/persona/build/syn/board/ia840f/syn_top`.
- `SYN`, `AE`, `DRC` = `J/output_files/ofs_pr_afu.syn.rpt`, `.syn.ae.rpt`, `.drc.synthesized.rpt`.
- `LOG` = `A/synthesis.log`. Line references are to the complete local files, not guessed report positions.

## 2. Evidence integrity and source binding

### Frozen package and transport

Independently verified **all 238 frozen members, 89163476 bytes, zero size/hash mismatches**, and repeated that check at the end of analysis. The report itself is outside the frozen package.

| Evidence | Full SHA256 |
|---|---|
| `P/review-package01.json` | `010ee211c032a017e8b5a9b9aab3e4e75a33ed4a8bea12cc515cab8b87e70866` |
| `P/result-setup01.json.gz` | `603773feb38f1012d0b4fed00b4e531df32e127d540b86827e7a48c03fd4309b` |
| `P/result-synth01.json.gz` | `4f696aa58d79d1c65629261e5ff151acfcbe4dd25ee7cff69f9bab1eef147cca` |
| `P/result-synth01-delta01.json.gz` | `24f0d61059716ec863d37b0aa21e9d979838ba36cc2f92eb46ce87d73cc006b3` |
| `LOG` | `21998b3e7c991ce64696036d5951336f32c77f17c78676248b38e6eec6807417` |
| `SYN` | `df3a38134a4049a78bb386f62cd9835ed9c86671a519f079ecf90d244fe38d69` |
| `AE` | `af7cbc64f1cc24caefc5fe2d3683a24775447dde4432ca212408db9a5d7addce` |
| `DRC` | `b0938960d74901e04fba4860c877ab90ecfe251ae1969ee3e8d2757e37872a18` |

Both runner hashes match their dispatch receipts. All **7 setup exports** and **11 synthesis exports** were decoded and checked against embedded lengths/hashes and local artifact bytes. Compressed payload hashes match the outer receipts. All four `native-panels-synth01.json` excerpts match their exact raw report ranges and report identity.

### Accepted AFU and generated payloads

Inertly parsed runner configurations and compared actual embedded bytes:

- All **13 selected AFU RTL payloads** are identical between setup01, synth01, `source-binding01.json` and the accepted PIM03 synthesis configuration. These include the guard, selected guarded top, DMA/core and both-bank shim implementation.
- All **255 generated fabric/HLS inventory entries** equal the accepted corrected PIM03 inventory. All 255 local source files were independently rehashed using `U/parent-verification02.json`'s explicit local-path map; no mismatch. This is reuse, not HLS regeneration or a substitute kernel.
- Generated `artifacts-setup01/persona/hw/afu.qsf:3–17` lists exactly those 13 RTL files plus both required generated QIPs. `SYN:2407–2419` records reading each selected RTL source once. Platform/FIM RTL comes from the matching release rather than a duplicate standalone platform source list.
- The diagnostic placeholder UUID header is omitted. The generated real header has UUID `673c03a1-cef3-4c82-bf10-b12c247d9718` (`afu_json_info.vh:10–13`) and `AFU_TOP_IFC "ofs_plat_afu"`. This is candidate identity, not deployment evidence.

### Static-root identity and preservation

The setup inventory of **4925 file paths** exactly matches the synthesis runner's copy baseline and the synthesis result's original-setup inventory. The release inventory and source/tool bindings agree across runners. Reconciled current hashes retain:

| Bound artifact | Full SHA256 |
|---|---|
| Imported `ofs_top.qdb`, 83178648 bytes | `7f8f25463afe3ae95d9660ddf4c5c6755d6704f828fd400de34ae38fa2aa0fc8` |
| Base `ofs_top.sof` | `bbede03c8c432e50ae6ae1f30739af3bfd3330781776d2c623269cc131b38ca4` |
| Base `ofs_top.static.msf` | `da2395b08b6713e6e4335b488f5757e052d583b44b908837e8d18747bb151705` |
| Base `ofs_top.green_region.pmsf` | `27b3e78810d54cf452dcc1aa834c62584290c9d3358e84f00a374294426a3663` |

The QDB identity matches `../fim21-pr-platform01/RESULTS03.md:20`; that release's FME interface ID is `fc4bf1c1-760f-5cd7-8040-b3e86fa0d31e`. Parent verification of the original 7598-entry Work21 tree and programming/FME identity is reused, not relabeled as a new live inspection. Binary QDB/MSF/PMSF contents were not loaded with Quartus here; remote file identities are retained hash evidence, not independent netlist semantic examination.

The exact synthesis preparation QSF delta is only replacement of the copied release callback/helper paths with the persona callback/helper and addition of `NUM_PARALLEL_PROCESSORS 2`. `J/ofs_pr_afu.qsf:111–114` binds `green_region`, imports root `ofs_top.qdb`, rebinds `afu_main` and selects `PR_IMPL`. No guessed PR-type assignment, pin assignment or timing exception was added. The excluded QPF was separately read back and matches the setup inventory; its legacy 26.1 header is not the actual compiler identity.

## 3. Native OPAE setup and execution quality

**Setup acceptance: native/effective/outer 0/0/0.** Only the native Quartus version query and installed `/usr/bin/afu_synth_setup --lib …/release03/hw/lib --sources …/setup01/afu_sources/sources.txt …/setup01/persona` ran in this stage. This is not a project compile.

The console entrypoint imports `platmgr.tools.afu_synth_setup`, not the unrelated OPAE runtime API namespace. Inspected installed copies establish the actual chain: `afu_synth_setup.py:181–217,228–302,344–371` copies the absent destination's build tree, invokes `rtl_src_config`, `afu_platform_config` and `afu_json_mgr`, and generates source QSF/platform configuration/header. No `--force` was used. All **92 installed source/database bindings** have matching captured local bytes and match both runners' tool inventories.

`packager/schema/afu_schema_v01.json:11–24` requires the `class` key in the supplied top-interface object and permits the `auto-*` clock strings. The installed `ofs_plat_afu.json` class database selects the `ofs_plat_if` AFU interface. Generated `platform_afu_top_config.vh:19–23,37` names `ofs_plat_afu`, Agilex and `AFU_TOP_REQUIRES_OFS_PLAT_IF_AFU`. The donor's unrelated `name` spelling was not silently accepted in place of `class`.

`auto-200` high / `auto-100` low are requested MHz ceilings, not measured or programmed clocks. Metadata `power: 0` is not a zero-power result. The explicit AGILEX family and 25.1 version environment agree with the platform configuration and real `25.1.0 Build 129` version result. They avoid the source-visible `CompletedProcess.wait()` misuse in installed `rtl_src_config.py:335–338,360–373` without modifying installed packages.

**Synthesis command:**

```text
/opt/altera/25.1/quartus/bin/quartus_syn --read_settings_files=on --write_settings_files=off ofs_top -c ofs_pr_afu
```

Remote cwd: `/home/uwb_student00/ahls/new_BSP/work_ahls_persona_work21_01/synth01/persona/build/syn/board/ia840f/syn_top`.

The retained native command starts `2026-09-23T14:45:31.272324+00:00` and ends `2026-09-23T14:50:00.078656+00:00`, native/effective 0. `LOG:6621–6625` reports success, 0 errors, 230 warnings, 4590 MB peak virtual memory and 00:04:28 elapsed. `syn.summary:1–9` confirms top, revision, part and Quartus 25.1 Build 129. `LOG:6614–6617` saves post-synthesis snapshots for four partitions and runs synthesized DRC: this is mapped synthesis, not merely A&E or an inherited empty-template report.

Runtime/source safeguards were inspected inertly:

- Exclusive attempt roots and log creation; explicit normal-account environment; no `OPAE_PLATFORM_GEN`; per-process 16 GiB address-space limit, zero core limit, CPU affinity `[0,1]`, setup 600-second and synthesis 1200-second native deadlines.
- Retained preflight records show sufficient memory/disk and no competing process from the enumerated vendor-tool set. This is finite scope, not proof of absence of every possible host workload.
- `persona-gate01.py:9–25` checks exact executable/argv/cwd/hash, live ancestry to the recorded runner identity and critical input hashes. `gate-events.jsonl` records acceptance of native PID 119824/start ticks 13800306 with the exact linux64 synthesis executable and argv. The callback's source equals the embedded gate bytes.
- The supervisor protects post-spawn bookkeeping, observes the leader with `WNOWAIT`, drains same-group helpers within the deadline and does not reap before possible group signals. Native receipts show no timeout, no residual owned live group, no gate rejection or Error/Fatal diagnostic, and empty postflight-error lists. These are historical completion receipts, not a new live host check.
- Original setup/release/tools preservation flags are true. Setup additionally preserves original generated files and AFU inputs. The synthesis false bound-input flag is treated separately below.

These guards are **not an OS sandbox**, aggregate-memory enforcement or standing authorization. No assertion here depends solely on `hardware_access=false`; the inspected call paths are file generation and compile, not MMIO/programming/driver access. Fallible postflight/export code is not a universal acquisition guarantee; these actual archives were recovered and verified.

## 4. Confirmed actionable defect: DNI files misclassified as immutable inputs

**F1 — Medium, evidence-runner/preparation defect; reconciled for this completed result, must not be copied into the next stage's role model.**

`run-synth01.py:32–33` claims no mutable checkpoint snapshots while checking only `qdb/` and `db/`. Lines 46–50 bind the copied `dni/` files along with true inputs, and lines 118–133 correctly reject the resulting blanket equality failure. The comment and input classification are wrong; the preserved outer125 is not a vendor failure or evidence that RTL changed.

Recomputed the delta across **all 5196 bound input hashes**, with identical before/after key sets:

- Exactly **34** differ, all under candidate `syn_top/dni/` checkpoint/report paths.
- Exactly **4345 non-DNI bound inputs** remain unchanged, including all selected RTL, generated fabric, QSF, root static QDB and copied programming artifacts.
- Recomputed changed entries exactly equal `native-delta-disposition01.json`; after removal of the transport-only `base64` field they also equal `result-synth01-delta01.json.gz`'s changes. Every one of its **28 inline changed-file bodies** matches its size/hash. Larger changed database bodies remain hash-only evidence.
- The complete unchanged non-DNI dictionary also matches the disposition exactly. Original setup/release/tools flags are independently true. QPF readback is unchanged.

The freshly read AFU sources, real mapped hierarchy/resources, native synthesized snapshot completion and exact source preservation justify accepting **bounded native mapping evidence**. Nothing justifies changing the old receipt, treating the copied empty-template checkpoints as the new result, authorizing arbitrary output-directory exclusions or rerunning unchanged synthesis.

**Action for the next changed runner/fitter preparation:** bind a fresh source/tool/static/synthesized-input inventory; enumerate stage-owned mutable checkpoint/report roles from the actual next-stage call chain; preserve the completed synthesis database as its proper input; reject unaccounted changes. Use fresh paths/ownership and a finite fit grammar. Do not broadly exempt `dni/` or all databases from all future checks, and do not reuse this ended synthesis authority.

## 5. Real composition demonstrated

`LOG:9` says **Loading PIM-based AFU**. The captured `afu_main.tcl:34–69` makes this the ordinary PIM branch, distinct from `OPAE_PLATFORM_GEN`. Most importantly, `SYN:3571–3580` reports:

- root partition import: `ofs_top.qdb`;
- `green_region` type: **Reconfigurable**;
- hierarchy: `afu_top|pg_afu.port_gasket|pr_slot|afu_main`.

Both bank shims and both page splitters survive (`SYN:38311,38485,38495,38669`); the actual primary host mapper survives (`38680`); source-read and native core/fabric/DMA parameter/hierarchy panels identify the accepted generated composition. This is not a naked interface at the card boundary.

| Mapped estimate | Native evidence |
|---|---|
| Whole project: 96955 ALMs, 252626 dedicated registers, 0 estimated DSPs | `syn.summary:7–9` |
| Green region: 36362 ALMs, 85806 registers, 1373376 block-memory bits, 0 DSPs | `SYN:47571–47604` |
| Green-region boundary: 4960 ports | Same partition resource panel; **not board pins** |
| Guard: 255 combinational ALUTs, 331 registers | `SYN:38679` |
| Guard `rs` and `ws`: four states each, One-Hot, Safe | `SYN:39250–39251` |

ALUT counts are not ALM counts. Compiler “Safe” encoding is not lifecycle safety or functional proof. Synthesis estimates are not fitter results.

## 6. Diagnostic quality and retained findings

### Complete emitted-warning ledger, not global warning clearance

Reparsed the complete native log and checked every line number, raw line including indentation, ID and severity against `warning-ledger-synth02.json`: **443 explicit occurrences**, comprising 441 Warning and 2 Critical Warning rows. ID counts agree exactly. The **224 unindented rows** explain the earlier incomplete ledger; that file is retained and superseded. Native footer **230** is a separate vendor summary convention and is not silently made equal to explicit occurrences. Repeated copies of the same diagnostics in `.syn.rpt`/`.ae.rpt` were not added to log counts.

| ID(s), explicit occurrences | Disposition / smallest relevant follow-up |
|---|---|
| 13461×2, 17498×1 | Parameter/localparam semantics warnings; retain source specialization. No new source defect established by these messages. |
| 16752×2 | Potential always-loop messages in CCI-P shim source. Enabled synthesized loop rule reports zero, but this is not all-path CDC/timing evidence. |
| 13469×90 | Width truncations in actual PIM/generated specializations. Retain exact fields and accepted geometry; mapping success is not proof against clipping on every active path. |
| 21705×2 | `$fatal` ignored for synthesis. Do not treat simulation assertions as implemented hardware interlocks. |
| 16788×22, 21610×92 | Undriven nets/default-grounded outputs in PIM, generated HLS and wrappers. These include optional/inactive fields as well as connected interface fields. No blanket “vendor harmless” waiver; preserve named producers/consumers and active-path follow-up. |
| 24420×1 | Mixed valid/invalid pragma at `ofs_fim_pcie_dm_req_splitter.sv:298`. Retain unsupported pragma scope; do not infer all pragmas were applied. |
| 23762×1 | Hierarchies swept; inspect the named native sweep panel rather than claiming all connected exports survive. |
| 14284×7, 14285×7, 14320×177 | RAM/node pruning groups and leaves, not 177 complete functional FIFOs proved absent. Preserve PIM03 R2 attribution limits. |
| 20580×1 | Imported PR type not explicitly specified in current project; retain, but native table proves a Reconfigurable green region at synthesis. |
| 19854×1 | Explicit initial values in green region; PR/reset lifecycle qualification remains required. |
| 13046×1, 13047×4 | Active LSU read-burstcount tristate-to-OR transformation; PIM03 R1 remains unresolved. |
| 13024×1, 13410×31 | Constant **partition-boundary groups**, principally local-memory sidebands/IDs/upper length fields; not card-pin assignments or automatic proof that active requests were removed. |

**F2 — Diagnostic-coverage qualification, not a newly demonstrated RTL defect.** “Zero waived” in DRC must not be read as “all warnings enabled” or “all nodes enumerated.” The unchanged `J/ofs_pr_afu.qsf:105` sources `suppress_warning.tcl`; its local bytes match bound SHA256 `44c5f7c4115342c24a24ab00f0ff004a2d24cb6887b24c35bd3569eade7f0084`. It contains pre-existing global message disables and scoped 14320 RAM-message suppressions. Native source-assignment panels also retain generated-source MESSAGE_DISABLE attributes. No new suppression is added or endorsed by this review.

`SYN:917,45921` limits/truncates the removed-register table at 5000 entries. The PR initial-condition report setting is 100 (`SYN:947`); its actual explicit-power-up table has **69 grouped rows**, no adjacent truncation marker (`47451–47524`), not a count of individual register bits. **Action:** carry these coverage limits into later reports; use a targeted retained-source/cone check for any stronger claim rather than interpreting absence from a capped/suppressed report as absence of a defect. No unchanged rerun is required.

### PR, initialization and mapping obligations

**O1 — Physical PR preservation:** 20580 at `LOG:6099` does not invalidate `SYN:3578`'s Reconfigurable type. Do not guess `PARTIAL_RECONFIGURATION_PARTITION` constraints. Require the next fitter's actual static-import/partition/region preservation and boundary evidence before physical acceptance.

**O2 — Initial state, reset and freeze:** 19854 at `LOG:6540` corresponds to actual native power-up rows, including reset duplication, joined reset, freeze-bridge and ROB state. Successful synthesis does not prove PR reinitialization or a safe handoff. The AFU's `freeze_cc` still appears in **Hierarchies Optimized Away During Sweep** (`SYN:37646`); merely exporting freeze is not effective kernel/DMA quiescence. Preserve reset assertion/deassertion, descriptor/kernel drain, outstanding response retirement, posted-write fences and buffer-lifetime obligations; do not add a speculative duplicate Reset Release IP.

**O3 — Active mapped-path semantics:** `LOG:6560–6564` retains the four actual LSU read-burstcount OR conversions. Reuse PIM03 R1's source explanation—identical source drivers narrow the risk—but do not call mapped fan-in/equivalence proved. R2's remaining RAM reply/credit/ID/metadata attribution also stays open; native success or familiar vendor origin does not close it. The 31 boundary groups at `LOG:6566–6596` include `ext_mem_if[0/1]` AR/AW IDs and length upper bits. Retained page-splitter geometry makes some constants plausible, but exact mapped field correspondence remains the required discriminator. Use already-produced cone/clearbox metadata, or a separately bound finite query if necessary, before a mapped-functional warning-closure claim. This is not a demand to reopen unchanged source acceptance or rerun standalone synthesis.

### DRC is visible and unwaived

Partitioned DRC reports **0 of 10 rules failed**, including Reset Release instance count. Synthesized DRC reports **5 of 13 enabled rules failed**, all waiver counts zero (`DRC:48–65`); `LOG:6617` also records **7 disabled rules**.

| Rule | Severity / violations | Exact scope and obligation |
|---|---|---|
| RES-30132 | Medium / 2 | `afu_top|clk_div2_q1`, `afu_top|clk_div2_q2` (`DRC:77–78`); preserve reset/startup analysis. |
| LNT-30023 | Medium / 1 | PCIe MSI-X `intc_st_cpl_tx_tvalid` driving differing SCLR polarity uses (`DRC:91`); retain actual endpoint semantics. |
| LNT-30010 | Low / 6 | Mixed reset/enable uses (`DRC:104–109`), including persona `join_afu_reset|joined_reset_n`; not cleared by zero missing-reset-release violations. |
| TMC-20501 | Low / 4 | `dup_rst`, both bank soft-reset chains, joined-reset crossing; requested depth6/implemented0, native reason same hierarchy (`DRC:122–125`). Fit must establish adequacy. |
| TMC-20500 | Low / 1 | `rst_link[0].rst_p[0].dup_port_rst` depth7/implemented6, non-register source reason (`DRC:138`). |

The one enabled High synthesized rule has zero violations. Enabled latch, combinational-loop, reset-release reachability and non-driving-top-input rows are zero in this snapshot; this removes the particular naked-interface diagnostic boundary problem, **not** all reset/CDC/electrical/functional obligations. Preserve Work21's retained full-FIM signoff limits as well.

## 7. Handoff

- Accept setup01 and the actual Work21-context mapping evidence with **F1's preserved failed outer receipt** and exact source-preservation disposition. No in-scope blocker or established corrective RTL delta was found.
- Fix the **next stage's** role classification/ownership, carry **F2's** diagnostic limits, and obtain real fit/STA evidence without guessed constraints or blanket waivers. The report is evidence acceptance, not a new launch-approval framework and not authority reuse.
- Keep O1–O3, all unwaived DRCs, full-FIM/PR/reset/freeze/ordering/drain/visibility, physical DDR, installed-host routing/OPAE and numerical/sustained hardware qualification separate. Hardware memory acceptance must cover instances individually and simultaneously with address-dependent data and active numerical checks, not only status flags.
- No fit, STA, assembly, GBS generation, live FPGA/MMIO/programming/driver operation, reset or reboot was done by these reviewed stages or by this reviewer. Candidate UUID is not deployed. Vendor DDR simulation remains **SKIPPED BY USER**. **Goal incomplete.**

Only `P/independent-review01.md` was written. All frozen members remain unchanged. The final report's full SHA256 is supplied separately after writing, not embedded in its own contents.

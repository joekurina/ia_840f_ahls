# CAPS01 Work21 native fit01 — FINAL independent review

**Status: FINAL. Specification: PASS. Quality: PASS WITH FINDINGS. Recommendation: ACCEPT WITH FINDINGS the completed, source-bound native fitter stage only.** No substantive package, acquisition or bounded-fit acceptance blocker was found. This is not warning clearance, full timing/design closure, independently decoded QDB equivalence, runtime PR or hardware acceptance.

## Evidence notation and review boundary

`CAP` is `qualification/ahls-persona-work21-caps01` under `/home/joe/Projects/Thesis/AHLS/new_bsp/new`. Unless otherwise stated, short document paths below are relative to CAP. `LOG` means `artifacts-fit01/fitting.log`; `FIT` means `artifacts-fit01/persona/build/syn/board/ia840f/syn_top/output_files/ofs_pr_afu.fit.rpt`; `QSF` is the adjacent `ofs_pr_afu.qsf`. Other native report filenames refer to that same `output_files` directory. Line citations refer to original files, not whitespace-compacted display excerpts.

`RAW` means the inert gzip/JSON decoding of `result-fit01.json.gz`; its serialized JSON is one line, so citations identify object keys instead of invented pretty-print line numbers. `CFG` means the literal `C` assignment at `run-fit01.py:5`, obtained with AST/literal decoding, never runner import/execution. Embedded guard citations give line numbers within `CFG.guard` or `CFG.guard_tcl` strings.

Read `FIT-SCOPE01.md` and `RESULTS-FIT01.md` first. Review used local frozen reads, SHA256, inert AST/literal/base64/gzip decoding and report parsing only. No native tool, simulator, host test, network/SSH, Git, hardware operation, implementation edit or task-state change was performed. Neither the separately owned final-STA job nor mutable CURRENT was inspected, polled, operated, awaited or gated. Existing unit/synthesis acceptance is reused, not repeated. These boundaries are explicit in `FIT-SCOPE01.md:3–7` and `SYNTH-ACCEPTANCE.md:5–11,23–27`.

## 1. Specification review — PASS

### 1.1 Exact completed stage and target

| Requirement | Verified evidence and disposition |
|---|---|
| Actual matching Work21 release03 PR persona, not an empty template or naked-interface diagnostic | `CFG.release` is `/home/uwb_student00/ahls/new_BSP/work_fim21_pr_platform01/release03`; `CFG.setup_root` names completed CAPS01 `synth01`; actual PIM loading and database imports are at `LOG:9,34–40`. `FIT:244–247` identifies imported final root/static context and Reconfigurable green_region. |
| Quartus Prime Pro 25.1.0 Build 129; AGFB027R25A2E2V; project ofs_top, top entity top; revision ofs_pr_afu/PR_IMPL | Native version/device at `LOG:14,31–38,72`, `FIT:118–126`; exact part/top/PR assignments at `QSF:11–12,26,111–114`. Launcher versus linux64 executable identity is reconciled below. Historical comments or QPF headers are not substituted for native identity. |
| Application UUID `673c03a1-cef3-4c82-bf10-b12c247d9718` | `RAW.uuid` and `CFG.uuid`; generated `artifacts-setup01/persona/hw/afu_json_info.vh:8–13` and JSON `ia840f_ahls_memory.json:12–14`. UUID continuity is not image authentication or permission for MMIO. |
| Only the accepted additive raw-capability source correction | Decoded CAPS01 setup/synthesis/fit source dictionaries agree exactly. Compared against frozen CSR02 setup payloads: only `afu/csr_mgr.sv` differs; all other **12 AFU source payloads** and **255 generated records** agree. Candidate bytes match the accepted source SHA256 `053b9855aa860c410337f5cae7e6160c6086726903cf988a1d35f032cb7a0b93`; baseline is `42d09ffffb91152b9f688014bcff9ffc13e5382cddd7f478e5f9b992da232a77`. This is identity/delta verification, not another functional unit review (`source-delta01.json:2–17`; `../dma-csr-metadata01/UNIT-ACCEPTANCE.md:5–9`). |
| Unchanged clock and implementation policy | Source list and AFU JSON match CSR02; JSON retains `auto-200`/`auto-100` (`artifacts-setup01/persona/hw/ia840f_ahls_memory.json:5–6`). Native target messages remain auto 200/100 (`LOG:540–541,660–667`). Full fit-QSF delta from completed synthesis is exactly the two callback/file-hook replacements at `QSF:2–3`; no timing/resource assignment delta occurs during fitting. Final exported QSF equals the captured prelaunch post-hook bytes. |
| Full native fitter completion, no extra native stage | One command only, complete/success true, native/effective/outer **0/0/0**, no timeout, callback rejection, native diagnostic error or postflight error. Native final-database commitment and success footer are at `LOG:678–684`; `fit-parent-verification01.json:7–28,127–135` and `outer-fit01.json:2–4` agree with RAW. |
| No broader acceptance or new permission gate | No final STA/timing, assembly/GBS, deployment, electrical, physical DDR/PCIe/OPAE, numerical hardware, reset/CDC/lifecycle or durable-boot acceptance is inferred. Vendor DDR simulation remains **SKIPPED BY USER**. Existing source all-bit correspondence limits are not a newly observed defect or a new generic prerequisite to eligible STA or hardware access (`FIT-SCOPE01.md:5–7`; `SYNTH-ACCEPTANCE.md:15–27`). |

The exact completed native command was:

```text
/opt/altera/25.1/quartus/bin/quartus_fit --read_settings_files=on --write_settings_files=off ofs_top -c ofs_pr_afu
```

The QSF contains assembler/GBS-related settings, but a standalone fitter invocation does not establish that those stages ran (`QSF:42–43,86–88,123–124`; `LOG:31`). This review recommends acceptance of the observed fitter result, not issuance or extension of execution authority.

### 1.2 Frozen package and source/context chain

Independently recomputed the package identity and every declared member's bytes/SHA256: **81/81 files, 225,044,304 bytes, zero mismatches**. Package SHA256:

```text
4ff19613048180a4be815ef99284f8f35213087771932f3341cb6d4781651332
```

All 42 entries in the accepted synthesis package are included in this fit package with identical metadata; no accepted synthesis member was substituted. The reviewed FINAL synthesis report matches SHA256 `45e4acbdb9184dcc6b6d8e6d175b566d5ee24835d4e8919feacb1866afb8bb18` (`fit-review-package01.json:13–23,125–167,269–287`; `SYNTH-ACCEPTANCE.md:5–9`).

Independently decoded every exported payload and compared declared size/hash, archive bytes and local export bytes: **18/18 fit, 11/11 synthesis and 7/7 setup members** match. Fit `output_hashes` and the parent's complete export list match the same 18-member map, not merely its cardinality (`fit-parent-verification01.json:30–126`). Fit archive: **4,096,728 bytes**, SHA256:

```text
4807b92fdc0cf84ef015c566e9f77a350f1fd91e6f59fa7d9a80da553824f5cb
```

The setup, synthesis and fit configurations retain the same complete **4,936-record release inventory**, **92-record tool-binding map**, generated inventory, source list, JSON and UUID. Fit adds the explicitly bound fitter launcher/runtime to its Quartus tool map. Setup retains release-result identity `6ec17215ca58ffd136418de08fb45ba1700a01887f84ea7b2d93afe06ad808b9`. The imported `ofs_top.qdb` is consistently **83,178,648 bytes**, SHA256 `7f8f25463afe3ae95d9660ddf4c5c6755d6704f828fd400de34ae38fa2aa0fc8`, across release, setup and fit-input records. This verifies the captured chain to accepted release03; it is not a new local rehash of the remote binary or an independent static-netlist decode (`CFG.release_inventory`, setup/synthesis literal configurations at their respective `run-*.py:5`; `RAW.original_setup_inventory`; `QSF:112`; `LOG:37–40`).

The fit-prerequisite archive is also frozen/hash-valid. Its **5,373-entry inventory** equals `CFG.persona_inventory` and `RAW.original_setup_inventory` exactly, including recorded link metadata. It recaptures all **602 synthesized QDB entries** without size/hash differences and all nine persona-file exports from completed synthesis. All **4,345 completed-synthesis critical hashes** are accounted for: **4,075** copied-persona paths match the fit preinventory and **270** external paths retain the same fit bindings. `capture-fit-prereq01.py:4–6,15–19` binds the completed synthesis archive and describes those source and stable-read checks. This is reuse of completed synthesized/static inputs, not checkpoint-free fitting.

## 2. Evidence, protection and execution quality — PASS WITH FINDINGS

### 2.1 Exact copy and role accounting

The fit runner requires an absent exclusive root, binds the original synthesized persona/release/tools/source, makes an exact copy with preserved symlinks, and rebinds the copy before changing only its hooks (`run-fit01.py.in:5–18,29–43`). AST-decoded configuration inserted into the template reproduces `run-fit01.py` byte-for-byte; the same template identity check passes for setup and synthesis. Dispatch's embedded-runner digest matches the frozen runner (`dispatch-fit01.json:6–7`). The outer dispatch wrapper itself is represented by a recorded hash, not exported wrapper bytes; I do not claim independent reconstruction of that wrapper.

| Protection class | Independently checked result |
|---|---|
| Full pre-copy inventory | **5,373** exact paths, including one recorded symlink; equality across prerequisite/config/RAW, not a selected RTL-only list. |
| Runtime mutable output roles | **1,133 unique exact paths**, all members of the preinventory; equality across `CFG.runtime_mutable_paths`, `RAW.input_output_role_exclusions` and `fit-input-roles01.json:3–1137`. Includes DNI/compiler outputs, explicit report/QPF roles and manifests/locks. It is not a blanket `qdb/` exclusion. |
| Protected partitioned/synthesized snapshots | **67 unique exact paths**, disjoint from mutable roles, all prebound. Every recorded post-fit QDB size/hash still equals its pre-fit entry (`fit-input-roles01.json:1138–1206`; `RAW.protected_synthesis_paths`, `qdb_outputs`). These are the 67 immutable QDB entries, not 67 entire QDB trees. |
| PID-qualified clearbox | **97** actual synthesis-PID `138522` paths are present and immutable; none is mutable. The **97** predecessor-PID `128094` names are absent and correspond by exact PID-component substitution (`fit-input-roles01.json:1207–1406`). This is role/inventory retargeting, not evidence that fit deleted predecessor files: the fit runner copies the completed synthesis tree and has no such clearbox-deletion step. |
| Runtime critical map | Reconstructed **all 4,512 hashes exactly** from the **4,240 nonmutable copied paths**, copied-QSF replacement, 13 AFU sources, 255 generated records, new Python/Tcl hooks and source JSON/list. This equals `RAW.input_hashes`; source/static QDB/SDC/settings are not hidden by mutable output roles (`run-fit01.py.in:48–59`; `fit-parent-verification01.json:123–131`). |
| Preservation | `setup_unchanged`, `release_unchanged`, `tools_unchanged`, `bound_inputs_unchanged` are all true, with empty postflight errors. The runner checks all four in its final success expression (`run-fit01.py.in:113–120,132`; RAW and `fit-parent-verification01.json:127–135`). |

The preservation result is captured postflight hash evidence, supported by the exact code and available inventories. It is not a fresh remote filesystem audit. New post-fit physical databases are represented by RAW's **722-entry QDB hash/size inventory**, including **284 paths under final snapshot roles** across root_partition, auto_fab_0, green_region, auto_fab_1 and _flat. These binary members were not exported for independent decoding. Native commitment plus this recorded inventory supports the bounded completed-fit claim; it does not establish all-bit netlist equivalence.

### 2.2 Native identity, finite ownership and cleanup

The accepted callback event records PID **140032**, start ticks **16043569**, executable `/opt/altera/25.1/quartus/linux64/quartus_fit`, exact PR-project cwd and argv. These match RAW's command receipt and the sole allowed `CFG.contexts` entry (`artifacts-fit01/gate-events.jsonl:1`; `fit-parent-verification01.json:9–27`). The executable's bound SHA256 is `c5cef4cc906aaffdfc177728e4ade3de6d40bb844d794dc8d6c59bbb894e91e0`; the launcher hash is `222fa669a9b10a6d443268fdc506e885597b5867e77bbf13ff656b8a272933dd` (`CFG.quartus_tools`). These are captured installed-tool bindings, not locally remeasured remote executables.

The guard requires the exact executable/cwd/argv, executable hash, live runner ancestry with PID/start/executable/cwd/argv equality, every critical hash, correct family/device/top/PR_IMPL, no OPAE_PLATFORM_GEN, and persona-fit-only scope with readiness false (`CFG.guard:9–26`). Tcl calls the guard with only LD_LIBRARY_PATH removed (`CFG.guard_tcl:1–8`). A Tcl error by itself would not prove native fail-closed behavior; the supervisor also watches explicit rejection evidence, and acceptance requires no errors plus all preservation results (`run-fit01.py.in:84–86,129–136`). No rejection is observed in this run.

Native timing receipt: `2026-09-23T20:59:23.904524+00:00` through `2026-09-23T21:41:42.010813+00:00`. The runner uses a **10,800-second finite deadline**, an exclusive log, a new session/process group, and an unreaped leader while waiting for same-group helpers and before potential group signals (`run-fit01.py.in:76–108`). RAW records no timeout, no descendants at leader exit, no residual-descendant failure, and no owned live survivors. Native/effective/outer are separately zero; a collector notification alone is not the success basis (`outer-fit01.json:2–4`; `await-fit01.py:11–24`). No observed cleanup defect or orphan is present, and no cleanup was attempted during this review.

Recorded preflight has no enumerated competing tools, available memory **124,312,813,568 bytes**, free disk **1,274,802,843,648 bytes**, affinity CPUs **0–35**, requested parallelism **36**, and per-process address-space limit **68,719,476,736 bytes (64 GiB)** (`RAW.resource_preflight`; `run-fit01.py.in:19–28,44–47,71–74`). These are historical run measurements, not present host-state claims. RLIMIT_AS is per-process, not aggregate sandboxing.

**Resource finding:** `FIT:147,234–235` records setting36, machine-detected36 and maximum allowed24. `LOG:10–11` says up to24 while Warning20031 says only18 system processors. Preserve all three observations; neither affinity/requested36 nor the up-to24 limit establishes actual simultaneous worker utilization. The native peak is **22,621 MB** and elapsed **00:42:16** (`LOG:682–684`). The flow's module elapsed **00:42:11** is a separately labeled native field, not a forced equality (`ofs_pr_afu.flow.rpt:416–419`). No unverified worker override or resource-policy correction is proposed.

## 3. Native physical fit evidence and its limits

The tool loaded final root_partition/auto_fab_0 and synthesized green_region/auto_fab_1 (`LOG:36–40`), committed the final database (`LOG:678`) and returned the successful fitter footer (`LOG:681`). All six fit-stage/main reports were scanned for numbered and Error/Fatal-colon diagnostics; none was found, consistent with the full native log and recorded zero status. This is not a diagnostic-waiver claim.

| Physical observation | Native evidence and accepted interpretation |
|---|---|
| Reconfigurable green_region | `FIT:240–247`, at `afu_top\|pg_afu.port_gasket\|pr_slot\|afu_main`; imported root is final `ofs_top.qdb`. This advances the earlier synthesis-only PR-presence observation to native fitted-context evidence. |
| Retained placement/routing region | `FIT:25189–25218`: placement regions `(301,0)–(390,20)`, `(101,21)–(390,100)`, `(0,101)–(390,333)` and routing region `(0,0)–(390,333)`, with nonzero region usage. Thus Warning15706 is not proof that the entire PR region disappeared. |
| Static-core preservation | `FIT:25225–25227,25256–25277` reports root_partition **100.00% preserved core logic**, dedicated registers, combinational ALUTs and memory ALMs **excluding PR subblocks**. Green-region preservation is0.00%, not an unchanged-persona assertion. The include-PR subsection instead reports60.64% root total (`FIT:25249`). No independent QDB/static functional-equivalence or runtime-PR claim follows. |
| Actual fitted CSR presence | `FIT:18310,18719` identifies `...\|ofs_plat_afu\|core\|dma\|csr_mgr_inst`, entity csr_mgr, **527 combinational ALUTs /1,011 dedicated registers**. This is the fitted changed-CSR instance; these totals do not directly read back the four capability constants or prove optimized-cone equivalence. |
| Region versus whole-design resources | Region table reports **40,241.0 final-placement ALMs**, **105,970 dedicated registers**, **1,373,376 memory bits**, **178 M20Ks**, zero DSPs (`FIT:25202–25214`). Whole-design summary separately reports **123,717 logic-utilization ALMs** and **272,674 registers** (`FIT:127–132`). Different table metrics/rounding are not conflated with the region's estimated ALMs-needed value34,738.3. |
| Boundary ports are not board pins | Green-region boundary table gives4,960 ports,2,287 inputs and2,673 outputs (`FIT:25229–25231`); this is not a physical-pin count or proof of transport correspondence. |

`ofs_top.qpf`, both dedicated synthesis/partition DRC reports, synthesis A&E, mapped synthesis report and synthesis summary are byte-identical to accepted synthesis exports. They are carried evidence, not freshly executed Fitter DRC. The SDC-constraints export differs only in its timestamp header. `LOG:530,627,679` explicitly says Design Assistant did not run in plan/place/finalize because no enabled rule existed to check; `FIT:167–170` still has Design Assistant On, include-IP Off and a5000-per-rule limit. Successful fit therefore does not clear retained synthesized DRC failures, disabled rules, exclusions or report limits.

## 4. Retained quality findings — no waivers

### F1 — Exact warning accounting, not a warning-clean build

Reparsed the complete native log with leading whitespace permitted: `^\s*(Critical Warning|Warning) \((\d+)\):`. All **167 occurrences**, including every line number, severity, ID and message, exactly equal `fit-warning-ledger01.json`. Its source hash and all group totals also match. This is **161 Warning +6 Critical Warning**, and the native footer independently says **0 errors/167 warnings** (`LOG:681`). The indented **15706 at LOG:538** is essential; a column-zero-only parser misses it. Repeated stage occurrences are retained, but copies in native reports are not added a second time.

| ID | Actual occurrences | Exact locations / disposition |
|---|---:|---|
| 20031 | 1 | `LOG:11`; processor-count qualification above. |
| Critical20727 | 5 | `LOG:41,532,628,654,668`; unused PR inputs, retained F2. |
| 18502 | 17 | `LOG:53–69`; current/base SDC_FILE differences, retained F3. |
| Critical15714 | 1 | `LOG:81`; actual BMC electrical-assignment gaps, retained F4. |
| 332174 | 40 | `LOG:112–194`; unmatched clocks/register filters, retained F3. |
| 332054 | 41 | `LOG:113–424`; accepted-but-problematic clock/group/I/O-delay assignments, retained F3. |
| 332049 | 58 | `LOG:140–414`; ignored constraints, retained F3. |
| 332158 | 1 | `LOG:434`; preliminary Agilex7 uncertainty characteristics; not timing closure. |
| 15705 | 1 | `LOG:537`; ignored region/location group; fitted region still present. |
| 15706 | 1 | `LOG:538`, indented; exact afu_main hierarchy warning, not proof PR was lost. |
| 171167 | 1 | `LOG:680`; native ignored-assignment panel, retained F5. |

### F2 — PR input pruning and preservation have different meanings

**Confirmed native observation; transport/runtime implications not fully qualified.** `FIT:256–301` lists **46 dangling input rows**: clk_div2/clk_div4, both banks' BID/RID bits and BUSER/RUSER, remote-STP reset/vir_tdi, and user clocks. That compiled panel is broader than the four clock inputs shown at the final log occurrence (`LOG:668–672`); the initial log's detail is abbreviated (`LOG:42–52`). Do not turn five repeated Critical20727 messages into five distinct faults, or four final printed names into exhaustive all-stage coverage.

The supported native finding is that unused boundary ports exist while a Reconfigurable physical region and static preservation are retained. Existing R1 active-LSU burstcount fan-in/OR transformation and R2 reply/credit/ID/metadata correspondence remain open; no noprune repair or region-assignment change is justified solely by this warning. Exact correspondence must be resolved before asserting it, not through a new universal equivalence barrier (`SYNTH-ACCEPTANCE.md:15–17`; `synth-independent-review01.md:163–169`).

### F3 — SDC/clock/exception consumption is not established by fit success

**Confirmed ignored/problematic assignments; timing/CDC adequacy remains unqualified.** The17 current/base SDC_FILE mismatch messages include exported `ofs_top.out.sdc`, PIM/user-clock scripts and base-only sys-PLL, top, FIFO, BMC and reference-clock scripts (`LOG:53–69`). Their existence is not proof all necessary constraints are absent, and export/rebinding conventions are not blanket justification for them.

The58 ignored332049 occurrences comprise **24 set_max_skew,26 set_false_path and8 set_multicycle_path** messages. Exported bank/MMIO CDC selectors produce empty-register filters (`LOG:140–194`); PCIe generated constraints also have nonmatching hierarchy/object-ID failures (`LOG:397–414`). The41 problematic332054 occurrences comprise **5 set_clock_groups,12 set_output_delay,16 create_clock,6 set_input_delay and2 create_generated_clock** messages. The latter overwrite the two user-clock outputs (`LOG:422,424`). Forty332174 filter warnings and preliminary uncertainty warning332158 remain separately counted.

These are occurrences, not unique affected paths or an all-path constraint audit. Before stronger timing/CDC claims, use actual endpoint/clock/exception coverage from the appropriately scoped downstream evidence. No SDC change, waiver, inherited CSR02 timing pass or claim about the separately running STA is made here. Its execution is not conditional on this review.

### F4 — BMC electrical-assignment gaps remain real and named

**Confirmed incomplete assignments; electrical adequacy unresolved.** The actual I/O Assignment Warnings panel identifies only the following three rows, each with **missing termination setting and slew rate**: `bwbmc_bmc_irq`, `bwbmc_bmc_mst_en_n`, `bwbmc_fpga_max_miso` (`FIT:5838–5845`). Do not generalize Critical15714 to missing DDR/PCIe pins, and do not declare these BMC gaps harmless merely because static logic was preserved. Board-supported electrical requirements and effective settings must support any later electrical/hardware acceptance; no guessed pin assignment is recommended.

### F5 — Ignored implementation assignments remain separately visible

**Confirmed ignored assignments; target-specific impact not fully determined.** Parsed every row of `FIT:26334–27431`: **1,098 reported rows**, not1,098 warnings or proven functional failures.

| Assignment class | Reported rows | Exact native rows |
|---|---:|---|
| Programmable De-emphasis | 18 | 26334–26351: EMIF0/1 mem_ck_n and mem_dqs_n assignments. |
| Global Signal | 1 | 26352: PCIe warm-reset dreg target, valueOFF. |
| Force Hyper Register for Periphery to Core Transfer | 4 | 26353–26356: EMIF0/1 sequencer P2C targets. |
| Hyper Register Delay Chain | 502 | 26357–26858: EMIF C2P UFI targets. |
| Force Hyper Register for Core to Periphery Transfer | 500 | 26859–27358: EMIF C2P UFI targets. |
| Synchronizer Identification | 73 | 27359–27431: static PCIe/FIFO and AFU generated reset/FIFO targets. |

For example, `FIT:27359–27362` includes protocol-checker/MSI-X and reset synchronizers; `FIT:27426–27431` includes generated kernel bursting-write and read-root FIFO reset-handler synchronizer heads. A vendor/HDL origin or imported-final static partition does not prove these assignments were effectively consumed or redundant. Keep this separate from actual physical PR preservation, and resolve the specific effective-assignment/CDC/timing or electrical implication before claiming it. No vendor-internal edit, suppression, force-retiming remedy or repeated fit is warranted by the panel alone.

### F6 — Additional reset cycles are a requirement, not an adequacy result

**Confirmed native requirement; system reset/lifecycle proof remains open.** The reset table's heading is **Number of additional cycles** (`FIT:26066–26069`), and its note explicitly attributes the minimum additional sequence to retiming (`FIT:26152`). Nonzero entries are:

- **2 additional cycles** for `sys_pll|iopll_0_clk_sys` (`FIT:26098`).
- **4 additional cycles** for `local_mem_wrapper|mem_ss_top|mem_ss_sv|mem_ss|mem_ss|emif_0|emif_0_core_usr_clk` (`FIT:26132`).

These are not total reset widths, not additive requirements in a single shared clock domain, and not evidence that implemented reset satisfies them. Zero rows likewise do not mean no reset protocol is required. Native success, static preservation and timing-model status do not establish assertion/deassertion ordering, initialization, reset-domain crossing or retimed reset reachability.

Retain accepted synthesis **Q1–Q4/R1/R2** in full, with their exact source/native citations in `synth-independent-review01.md:130–195` and parent disposition in `SYNTH-ACCEPTANCE.md:13–21`:

- **Q1:**443 synthesis log occurrences versus230 footer warnings; inherited exclusions, disabled rules, message policy and truncation limits are unchanged. Current fitter warning accounting is separately167, not a replacement count.
- **Q2/R1/R2:** Critical20580 remains historical synthesis evidence. This fit supplies native physical-region/static-preservation evidence for the formerly fit-pending subclaim only; it does not resolve burstcount transformations, pruned response metadata or all-bit mapped correspondence.
- **Q3:** Critical19854/PR initial values and synthesized failures remain: RES-30132(2), LNT-30023(1), LNT-30010(6), TMC-20501(4), TMC-20500(1), totaling14 violations across5/13 failed enabled rules with0 waived. The copied report is not a newly passing fitter/reset DRC. Swept `freeze_cc` is not effective quiescence.
- **Q4:** the new tagged read-only words do not repair legacy512-to3-bit width,32-to4-bit depth,150-to64 status narrowing or clock400 metadata. A capability tag is not image identity, measured clocking, a completion guarantee or permission to touch hardware.
- **Lifecycle:** descriptor/kernel drain, outstanding response retirement, posted-write fences, reset/CDC/initialization, freeze/PR handoff and pinned host-buffer ownership/lifetime remain separate contracts. Neither status bits, fixed delays, reported geometry nor retained physical resources clear them.

No unchanged synthesis or source-unit rerun is required. These retained limits are not converted into a new generic native-execution permission barrier.

## 5. Final recommendation

1. **ACCEPT WITH FINDINGS CAPS01 Work21 native fit01** for the exact package, source/static/tool context, protected-input roles and successful committed fitter result bound above.
2. Accept native Reconfigurable green_region, retained region usage and100.00% static-core preservation **only at the vendor report's stated scope excluding PR subblocks**. Do not relabel this as independently decoded QDB equivalence, constant-word readback, runtime PR, warning/DRC clearance or full design acceptance.
3. Preserve F1–F6 and synthesis Q1–Q4/R1/R2; timing, electrical, reset/CDC/initialization, lifecycle, assembly/GBS and hardware goals remain outside this verdict. Vendor DDR simulation remains **SKIPPED BY USER**.
4. This FINAL result review neither operates nor gates the parent's separately owned eligible STA, and grants no hardware authority. It creates no new permission gate for otherwise eligible native or hardware work under the existing project rules.

No evidence mismatch or bounded-fit blocker was found. One local comparison initially compared a two-field metadata projection to a source record also containing base64; correcting the comparison to equal representations passed all source identities. That was a review-script shape error, not source drift; no evidence was edited or native work repeated. Only `CAP/fit-independent-review01.md` was authored. Its SHA256 is returned separately, avoiding a self-referential digest.

# Independent review 01 — completed actual Work21 AHLS persona fit02

Status: **FINAL**

## Verdict

**ACCEPT BOUNDED FIT02 EVIDENCE WITH FINDINGS.** The actual guarded AHLS/DMA/page-safe-bank persona completed the native Quartus 25.1 fitter in the matching Work21 PR context. Native/effective/outer status is **0/0/0**; the verified archive supports runner success, preserved bound inputs and originals, and successful final database commitment. The native partition and Logic Lock panels establish retained physical PR-region/static-import structure within this stage.

**No blocker to accepting this completed fitter evidence was found.** This is **not** numerical timing or constraint-coverage signoff, mapped-functional equivalence, reset/quiescence qualification, runtime PR compatibility, an assembled persona image, or hardware acceptance. Findings below block those stronger claims, not acquisition of the next justified STA result. Do not rerun unchanged synthesis or fit, reuse the failed fit01 database, or request another blanket approval.

## 1. Specification first

Read the frozen `F/SCOPE.md:3–9`, fit01 failure/delta record and existing actual-persona acceptance before judging native success. The relevant contract is:

- Fit only, on a fresh exact copy of completed actual `synth01`, with unchanged accepted RTL/generated inputs, clock intent, signoff constraints, static QDB, board geometry and optimization intent. The deliberate copied-QSF change is only the fresh fit-only callback/helper binding.
- Keep the interrupted fit01, its **5/5/5** OOM failure and original databases intact. For fit02 change fresh run/authority/transport identities and the finite per-process address-space cap from **16 GiB to 32 GiB**, keeping two CPUs, memory/disk preconditions and the finite deadline.
- Preserve immutable inputs and the completed synthesis/partitioned snapshots while allowing only enumerated copied stage-output paths to change. These controls are source-bound normal-account execution, not a sandbox or aggregate-memory containment.
- No resynthesis, STA, assembly/GBS, programming, FPGA/device/MMIO, driver, reset or reboot operation belongs to this fitter stage. Vendor DDR simulation remains **SKIPPED BY USER**.

`SCOPE.md:7`'s 16 GiB describes fit01, not fit02. The immutable predecessor is reconciled by `FIT01-FAILURE.md:5–11`, `source-delta-fit02.json:10–22`, actual runner `run-fit02.py:70–73`, and the recorded result; it must not be silently rewritten or misquoted as the retry limit. The broader hardware mission and safety boundary remain separate (`N/GOAL-PROMPT.md:5–23,65–107`).

Reused the accepted setup/mapping gate (`P/RESULT-ACCEPTANCE.md:3–21`) and matching release-template gate (`Q/RESULT-ACCEPTANCE.md:3–18`), not a new review of unchanged generation. The supplied publication identifiers are `bcaf115c` and `425376f`; publication is not new native or hardware evidence.

### Citation and inspection convention

Paths are relative to `N = /home/joe/Projects/Thesis/AHLS/new_bsp/new`:

- `F = qualification/ahls-persona-work21-fit01`.
- `P = qualification/ahls-persona-work21-01`; `Q = qualification/fim21-pr-platform01`; `U = qualification/ahls-memory-pim03`.
- `J = F/artifacts-fit02/persona/build/syn/board/ia840f/syn_top`.
- `LOG = F/artifacts-fit02/fitting.log`; `FIT = J/output_files/ofs_pr_afu.fit.rpt`; `DRC = J/output_files/ofs_pr_afu.drc.synthesized.rpt`; `SYN = J/output_files/ofs_pr_afu.syn.rpt`.
- `TOP = N/afu/ahls_memory/pim/ofs_plat_afu_guarded.sv`, whose bytes exactly equal the selected `afu/ofs_plat_afu.sv` payload, SHA256 `3b5bf9eac55f5117858b8a746308a09ebc3d7c6f8a99c66907777139278785ca`.
- `BANK` means the decoded `C.source_files['afu/ia840f_ahls_memory_bank_shim.sv'].base64` in `F/run-fit02.py:5`, with line numbers in that decoded source. `MEM` means the decoded `C.core_inputs['platform/ofs_plat_if/rtl/ifc_classes/local_mem/ofs_plat_local_mem_as_axi_mem.sv'].base64` in `U/run-synth02.py`; its hash `5fdb8f450bd4bac78da51a80ab3a186af5354752006048079c977351946450c6` exactly matches fit02's copied platform binding. No runner was imported or executed to obtain either source.
- `USER = N/ofs-platform-afu-bbb/plat_if_develop/ofs_plat_if/src/rtl/ifc_classes/local_mem/native_axi/prims/ofs_plat_axi_mem_if_user_ext.sv`, independently hash-matched to the actual platform input: `a9fc9d526c8924ecf47111be9157a930c5345be995c149004fa80166f406a898`.

All analysis was local, inert AST/literal/base64 inspection, hashing and report parsing. No SSH, vendor/simulator execution, device access, git operation or task transition occurred. This report was written early as **IN_PROGRESS** and is the sole authored file.

## 2. Evidence integrity and exact source/database roles

### Independently recomputed, not accepted from navigation aids

- Frozen `review-package01.json`: **113 entries / 229,909,665 bytes**, all available, all size/SHA256 checks pass. Manifest SHA256: `4bb900f4f3f9cbf2718f49beca11fd3f6d17ac23444383e5ac5bbd4659b3c376`.
- `result-fit02.json.gz`: SHA256 `ff6e3e6a5a92b41e655900862638ca03bb89751ae561e8b6cdeb74db8e4c4aab`, matching its outer receipt. All **18 embedded exports** decode to the declared sizes/hashes and exactly match the local artifacts.
- All **14 packaged compressed JSON captures** parse. All **40 embedded base64 file payloads** across them verify. That includes all 12 failed-fit exports and all 10 prerequisite/helper exports; all corresponding decoded local copies match.
- Both fit runner hashes match their own dispatch receipts. Both runners and the embedded fit-only guard parse inertly. The configuration delta is exactly `run`, `root`, `guard`, `contexts`; outside the configuration, the AST difference is only the cap and fresh transport-buffer names. The embedded guard differs only in its owned fit-root path.
- All **13 selected RTL payloads** verify individually and exactly equal the accepted PIM03 source payloads. Source/generated/release/installed-tool dictionaries are unchanged from the completed actual-persona synthesis runner. All **255 generated files** were rehashed from the existing explicit local map in `U/parent-verification02.json`; every one matches fit02's inventory. Metadata and source-list hashes also reproduce exactly.
- Reconstructed the complete **4,512-entry immutable input-hash dictionary**, including copied inputs, changed callback-bound QSF, new guard/Tcl bytes, selected AFU/generated files and metadata. It equals the result's dictionary exactly, not just a selected subset.
- All **5,639 prelaunch entries** agree between the prerequisite capture, runner configuration and result. The **1,399 enumerated mutable paths** and **67 protected synthesized/partitioned paths** match the configuration and result, are disjoint, and are respectively absent/present in the immutable runtime bindings. The 34 accepted native DNI after-state changes from synthesis agree with the fitter copy baseline; unchanged non-DNI copied-input hashes reconcile too.
- All seven `native-panels-fit02.json` ranges match their original native report lines and report hash. Every entry of the 166-row warning ledger matches the raw log's line number, text, ID and severity. The QDB inventory equals the result's captured inventory. These aids were checked against primary bytes, not used as substitutes for them.

The source-bound static import is `ofs_top.qdb`, **83,178,648 bytes**, SHA256 `7f8f25463afe3ae95d9660ddf4c5c6755d6704f828fd400de34ae38fa2aa0fc8`, consistent with the accepted release chain. `LOG:7` retains FME interface UUID `fc4bf1c1-760f-5cd7-8040-b3e86fa0d31e`. These are captured identities, not a new local semantic inspection of remote binary QDB/image contents or proof of deployment.

### Native result and preservation

`run-fit02.py:17–34` verifies source/release/tools and preconditions, creates an exclusive fresh leaf, copies **synth01**, and verifies that copy. It does not copy fit01. Lines 35–43 replace only the callback/helper QSF lines; exact before/after QSF comparison confirms no timing, RTL, pin or optimization delta. Lines 44–56 set a clean 25.1 environment, omit `OPAE_PLATFORM_GEN`, bind exact fitter context and live runner ancestry. The native callback receipt identifies PID **122381**, start ticks **14010045**, expected executable/argv/cwd (`artifacts-fit02/gate-events.jsonl:1`).

The command is exclusively:

```text
/opt/altera/25.1/quartus/bin/quartus_fit --read_settings_files=on --write_settings_files=off ofs_top -c ofs_pr_afu
```

Actual preflight records CPUs **[0,1]**, available memory **124,518,346,752 bytes**, free disk **1,290,545,377,280 bytes**, and no competitor from the enumerated native-tool set. Code imposes 32 GiB RLIMIT_AS, zero core size and a **10,800-second** native deadline; this is not a global host-workload or aggregate-memory guarantee (`run-fit02.py:19–28,70–85`). The supervisor retains the leader unreaped while draining/signaling its owned group (`:83–106`). The completed record has no timeout, no observed/surviving owned descendants, all four preservation flags true and no postflight errors. These are historical receipts, not a present remote-process check.

Native start/end: **2026-09-23T15:20:28.655108+00:00 → 2026-09-23T16:41:54.011294+00:00**. `LOG:677–684` reports final database committed, successful fitter, **0 errors / 166 warnings**, **24,234 MB peak virtual memory**, **01:21:23** elapsed. Independent error-line parsing found no native Error/Fatal or gate-rejection line. `fit.summary:1–9` identifies **25.1.0 Build 129 SC Pro**, revision `ofs_pr_afu`, top `top`, Agilex 7 **AGFB027R25A2E2V**. “Timing Models: Final” is model maturity, not timing signoff.

The result's success expression explicitly requires the preservation flags and empty postflight errors (`run-fit02.py:112–135`). It did not silently promote failed fit01: `artifacts-fit01/fitting.log:547` contains `Out of memory in module quartus_fit (15933 megabytes used).`; native/effective/outer remain **5/5/5**, success false. The runner's colon-based diagnostic parser misses that OOM wording, but native nonzero and absent success marker correctly reject it. Preserve that parser limitation; no rerun is needed to repair historical bookkeeping.

### Provenance limits that must survive handoff

Both DRC reports, both `.syn*.rpt` reports and `.syn.summary` are byte-identical copied predecessors, **not newly run fitter DRC or synthesis**. QPF is unchanged; QSF has the intended gate delta. Fit-stage reports/summary are new; flow and SDC-constraint reports differ from the copied originals. `J/output_files/ofs_pr_afu.sdc_constraints.rpt:15–29` is a narrow post-elaboration/post-synthesis QIP statement report, not a coverage inventory of effective timing exceptions.

Captured QDB inventory: **722 file entries**, **284 under `/final/`**. Bytes remain remote. `FIT:219` and `LOG:528` explicitly disable intermediate snapshot retention. Small files under paths named `routed`, `retimed`, etc. are metadata/SOPCINFO/model residue, not evidence of loadable preserved timing snapshots. Final commitment is established; successful future final-snapshot loading must still be checked in that future run.

## 3. What the completed fit establishes

`LOG:36–39` loads final root/static and synthesized persona snapshots. `FIT:240–248` explicitly reports:

- `root_partition`: **final**, database `ofs_top.qdb`;
- `green_region`: **Reconfigurable**, nonempty;
- `auto_fab_0`: **final**; actual persona `auto_fab_1` also present.

`FIT:25183–25213` retains the real named AFU Logic Lock region, placement bounds `(301,0)–(390,20); (101,21)–(390,100); (0,101)–(390,333)`, routing bounds `(0,0)–(390,333)`, and nonzero usage. Thus current Warning 15706 is not evidence that the PR region vanished. The inherited synthesis 20580 warning is not a reason to invent a PR-type assignment. This closes the prior request for actual fitter evidence of the imported static root and physical region, not runtime PR behavior.

| Accounting scope | ALMs needed | ALMs used in final placement | Dedicated registers | M20Ks |
|---|---:|---:|---:|---:|
| Whole design (`FIT:18222–18298`) | 124,781 | 106,524 | 263,456 | 469 |
| AFU Logic Lock region (`FIT:25192–25213`) | 34,449.3 | 39,980.0 | 96,752 | 178 |

The native fractional region estimate is retained literally. Whole-design totals are **not AFU-only resources**. The whole-device pin count is 321; the dangling partition-port count below is not a physical pin count. Actual mapped/physical names include `mmio_guard`, `core`, `map_banks[0/1].shim|memory_shim` and `page_splitter` (`FIT:1036–1141`); presence/resources do not establish their full functional semantics.

## 4. Findings and smallest actionable checks

### F1 — High for timing signoff: effective active-path constraint coverage remains unproved

**Confirmed:** 17 base/current SDC assignment differences (`LOG:52–68`), plus missing collections, ignored constraints and replacements. Current exported `ofs_top.out.sdc` diagnostic selectors at lines 1673 onward name the predecessor scalar `ahls_binding|board|banks[...]` hierarchy, while the actual top uses `core` and `map_banks` (`TOP:37–55,73–78`; `FIT:1036–1141`). `LOG:139–195` includes the old scalar skew targets. There are 24 old-scalar missing-filter occurrences and 24 corresponding ignored-skew argument occurrences. **This proves those literal selectors fail; it does not prove every current CDC path lacks another effective constraint.**

Other groups are not all harmless stale scalar selectors: `LOG:111–136` includes PCIe optional-clock names, the obsolete-looking `mem_ss_inst` PHY-clock selector, `spi_egress_sclk`, and memory/reset synchronizer pin selectors. `LOG:286–354` records 18 DDR I/O-delay replacements and 16 DDR clock replacements; user-clock definitions add two further clock replacements (`LOG:421–423`). `LOG:356–413` includes ignored PCIe false-path/multicycle arguments. Retain preliminary uncertainty Warning 332158 (`LOG:433`) even though the summary labels timing models Final.

**Smallest next checks:** inspect the bound `ofs_top.out.sdc` selectors named by these exact native lines against the matching active PIM SDC/RTL hierarchy; use a separately bound final-database STA result to enumerate actual endpoint/clock matches and effective exceptions for the primary host CDC, both `map_banks[*].shim|memory_shim|cc.async_shim` crossings, joined resets and active memory/PCIe clocks. Capture effective I/O delays/master clocks after the recorded replacement order, unconstrained endpoints and cut/overridden exceptions. Distinguish inactive feature selectors from missing active targets individually. Do not mass-rewrite hierarchy names, add false paths, drop constraints, or infer coverage from a zero exit code.

**Gate:** blocks timing/CDC signoff; does not block accepting fit02 or obtaining that first exact-source-bound STA result.

### F2 — PR boundary: source-explained pruning is not runtime-PR safety

Critical 20727 occurs **five times** (`LOG:40,531,627,653,667`), not five different defects. `FIT:252–302` has exactly **46 dangling green-region inputs**:

- Four clocks: `clk_div2`, `clk_div4`, `uclk_usr`, `uclk_usr_div2`.
- Forty response-sideband bits across the two banks: nine-bit BID, nine-bit RID, one-bit BUSER and one-bit RUSER per bank.
- Debug inputs `remote_stp_jtag_if.reset` and `.vir_tdi`.

Do not substitute the historical empty/static-template count of 1,076 or recommend card pin changes for these ports.

**Narrow source checks completed:** `TOP:6–16,23–27,47–55` selects bank0's memory clock for the core and explicit host/bank CDCs, supporting unused alternate AFU clock inputs without proving every lifecycle condition. `BANK:13–37,42–46` retains the 5-bit internal page limit, clock-driving connector and page splitter. Exact generated `MEM:169–187` forces both physical request IDs and user fields to zero; byte-matched `USER:84–104,114–134,143–178` stores request metadata in FIFOs and restores response ID/USER from that metadata when the force flags are enabled. Therefore the 40 unused physical return-ID/USER bits have a concrete source explanation; they are **not evidence of silently truncating the 18-bit AFU IDs**.

**Remaining smallest checks:** retain exact compiled `map_user` parameter/cone attribution and R2's response-metadata/credit-RAM mapping, including enqueue, final-read-beat dequeue and accepted-write-response retirement. Confirm source ownership/tie-off and mapped disposition of the two debug inputs in the actual `afu_main`/remote-STP branch before waiving them. Carry the four unused clocks and all 46 ports into PR-boundary acceptance; inspect vendor-prescribed boundary treatment only in that separate context. Do not add noprune registers merely to make the count disappear.

**Gate:** source-justified expected behavior for ID/USER pruning, plausible selected-clock pruning, unresolved debug/PR-lifecycle disposition. No confirmed new fitter defect; not runtime PR clearance.

### F3 — Electrical completeness: three real BMC pins remain unresolved

Critical 15714 (`LOG:80`) is concretely scoped by `FIT:5838–5845`: `bwbmc_bmc_irq`, `bwbmc_bmc_mst_en_n`, `bwbmc_fpga_max_miso`, each **missing termination setting and slew rate**. These are physical static-shell pins, unlike F2's PR ports. Final static import is not evidence of electrical adequacy.

**Smallest check:** compare these three exact pin directions and effective I/O-standard/termination/slew assignments with the matching IA840F schematic/electrical requirements and bound board setup constraints. Record whether the applicable input/output direction and native default require an explicit assignment, with manufacturer-backed values if needed. No guessed termination/slew or broad pin-table rewrite is justified by this report.

**Gate:** electrical/hardware acceptance remains open; not a reason for an unchanged persona refit.

### F4 — Ignored assignments: prioritize current reset/CDC targets, not blanket vendor waivers

Warning 171167 (`LOG:679`) corresponds to exactly **1,098 rows**, not 1,098 independent RTL failures (`FIT:29085–30187`):

| Native assignment group | Rows | Primary native lines |
|---|---:|---|
| Programmable De-emphasis | 18 | 29089–29106 |
| Global Signal | 1 | 29107 |
| Force Hyper Register for Periphery to Core Transfer | 4 | 29108–29111 |
| Hyper Register Delay Chain | 502 | 29112–29613 |
| Force Hyper Register for Core to Periphery Transfer | 500 | 29614–30113 |
| Synchronizer Identification | 73 | 30114–30186 |

**Smallest checks:** separate imported static EMIF attributes from current-persona reset/synchronizer attributes. For the 16 current `core|fabric|...|k0` synchronizer rows (`FIT:30171–30186`), trace the exact generated `acl_reset_handler` specialization and resulting retained register/clock/reset cone; do not waive them as historical scalar hierarchy. Keep PCIe `coreclk_warm_rst_n|dreg[1]` (`FIT:29107`) in reset/clock-routing review. For EMIF rows, inspect effective family-supported behavior and real timed endpoints in the existing accepted-static/next-STA evidence before proposing an override. “Hyper Register Delay Chain” is not proof of an inserted data-delay remedy.

Warning 15705/15706 (`LOG:536–537`) remains an invalid node-assignment observation, but the real Logic Lock region and partition table above rebut the stronger claim that PR placement was lost. No source correction follows merely from its prose.

**Gate:** unresolved applicability/coverage and reset/timing adequacy, not a proven broken interface or justification for blanket suppression.

### F5 — DRC, initialization, mapped function and quiescence remain inherited open obligations

Neither copied DRC report is a new fitted check. `LOG:529,626,678` explicitly says no enabled Design Assistant rule was run at plan/place/finalize. Copied synthesized DRC remains **5 of 13 enabled rules failed**, zero waived (`DRC:48–65`): RES-30132 Medium2; LNT-30023 Medium1; LNT-30010 Low6; TMC-20501 Low4; TMC-20500 Low1. The hash-matched predecessor synthesis log retains **seven disabled rules** (`P/artifacts-synth01/synthesis.log:6614–6617`). Partitioned 0/10 and the enabled High rule's zero violations do not supersede these findings.

**Smallest checks:** examine the exact two resetless divider registers (`DRC:77–78`), MSI-X polarity uses (`:91`), mixed reset/enable paths including `join_afu_reset` (`:104–109`), and requested-versus-implemented reset duplication (`:122–125,138`) against the final clock/reset paths. Preserve the copied synthesis power-up-state and `freeze_cc` sweep observations (`SYN:47451–47524,37646`), active LSU burstcount transformation R1 and RAM/ID/credit attribution R2 from the accepted mapping review (`P/independent-review01.md:168–186`). Fit completion does not close them.

Before a mapped-functional or runtime-PR claim, establish actual reset assertion/deassertion, effective freeze consumers, descriptor/kernel drain, accepted-response retirement, posted-write visibility/fences and host-buffer lifetime. The exported freeze port and exception bus are not a numerical checker or a quiescence proof. Reuse accepted source/unit evidence and resolve the exact missing cone/contract, not another unchanged full synthesis.

**Gate:** mapped-functional, reset/lifecycle, PR and hardware claims remain blocked; no additional source defect was established within this bounded fitter review.

### F6 — Next STA must be an explicitly bounded analysis, not a read-only-looking flow shortcut

`J/ofs_pr_afu.qsf:98` installs `ofs_sta_report_script_pr.tcl`, and `:124` retains the GBS post-flow hook. The actual fit-only argv and receipts do not show either running. Do not turn future analysis into a full compile/packaging invocation.

The captured STA report hook sources **user-clock computation before reporting** (`F/source-capture02/ofs_partial_reconfig/ofs_sta_report_script_pr.tcl:11–14`). The computation deletes/rewrites the computed clock-frequency file, treats unused clocks specially, and can reload SDC/update the timing netlist (`user_clock_freqs_compute.tcl:34–36,54–79,103–118,350–362`). Its Fmax computation explicitly omits hold/removal from the clock-period adjustment and can emit assumed 10 GHz values for missing/non-required clocks or missing slack (`:166–203,281–294`). Such a value is **not achieved AFU performance**; this persona's core clock is bank0's memory clock, not the dangling user clocks.

`report_timing.tcl:47–88` deletes/recreates its report directory, enumerates corners/clock-domain metrics and emits at most 20 failing detailed paths per domain/type. Its pass/fail summaries do not establish complete unconstrained/exception/CDC coverage.

**Smallest pre-STA source check:** bind the actual helper/dependency closure and exact finite argv/callback grammar on a fresh copy of the completed final database. Decide explicitly whether the existing auto-clock computation is included; preserve requested ceilings, emitted computed frequencies and pre/post-load clock identities separately. Do not let automatic adjustment be misreported as unchanged fixed-frequency signoff. Enumerate expected writable report/clock-file/database roles while preserving the completed fit and source/static inputs. Require final-snapshot load evidence, all-corner setup/hold/recovery/removal/min-pulse-width results and F1/F4/F5 coverage gaps. No nonexistent routed-snapshot comparison is required.

**Source-selection caution:** the similarly named maintained `afu/ahls_memory/pim/ofs_plat_afu.sv` and plain `ia840f_ahls_memory_bank_shim.sv` are not the selected payload bytes. The selected guarded top was hash-matched; the selected bank shim was read from the exact encoded payload, including its corrected 5-bit page boundary and connector. Preserve these bindings for the next stage instead of rebuilding from a plausible sibling filename. This is a navigation/reuse hazard, not observed drift in fit02.

## 5. Complete warning accounting

Counted each explicit raw-log warning once, including indented lines, not repeated report copies. **166 occurrences = 160 Warning + 6 Critical Warning**, exactly matching `LOG:680`.

| ID | Occurrences | Disposition |
|---|---:|---|
| 20727 | 5 critical | F2: 46 actual dangling boundary inputs; no blanket waiver |
| 18502 | 17 | F1: base/current SDC assignment deltas |
| 15714 | 1 critical | F3: three BMC pins, incomplete electrical assignments |
| 332174 | 40 | F1: unmatched clock/register/pin filters |
| 332054 | 41 | F1: accepted-but-problematic groups/clock/delay replacements |
| 332049 | 58 | F1: ignored skew/false-path/multicycle constraints |
| 332158 | 1 | Preliminary uncertainty characterization retained |
| 15705 | 1 | F4: ignored location/region assignment group |
| 15706 | 1 | F4: missing named node, not absent physical PR region |
| 171167 | 1 | F4: 1,098 ignored-assignment rows |

Inherited global/scoped warning suppressions (`J/ofs_pr_afu.qsf:102–105`) and capped/disabled predecessor diagnostics remain coverage limits. Matching the footer is not proof that every potential warning was enabled or every node was reported.

## 6. Handoff decision

1. **Accept this frozen completed native fit02 result WITH FINDINGS.** No in-scope integrity, source-preservation, retry-origin or native-completion blocker remains. Keep failed fit01 and all accepted predecessors intact.
2. **Next justified native evidence is STA on an isolated, exact-bound copy of the committed final database**, with the helper behavior and coverage contract above. The ended fit-only authority is not reusable STA authority. This is a technical stage boundary, not a request for blanket user approval or another unchanged fit.
3. **Do not claim timing, mapped function, reset/freeze/drain, runtime PR, electrical or hardware acceptance.** F1–F6 explain the exact unresolved discriminators. No assembly/GBS or deployment occurred; candidate UUID `673c03a1-cef3-4c82-bf10-b12c247d9718` remains not deployed. Vendor DDR simulation stays **SKIPPED BY USER**. The hardware goal remains incomplete.

Only `F/independent-review01.md` was authored. All frozen inputs remain unchanged. The report's full-file SHA256 is supplied separately after finalization rather than embedded in its own contents.

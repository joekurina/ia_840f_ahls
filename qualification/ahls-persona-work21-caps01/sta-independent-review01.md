# CAPS01 Work21 final-snapshot multicorner STA01 — independent review

**Status: FINAL**  
**Specification: PASS for the bounded acquisition and constrained-domain scope.**  
**Quality: PASS WITH FINDINGS; recommend bounded ACCEPT WITH FINDINGS.**  
**Native Design Closure remains FAIL. This is not full timing/design, mapped-functional, lifecycle, fit, or hardware acceptance.**

## 1. Specification first: scope and frozen identity

I read `STA-SCOPE01.md:1–7`, then `RESULTS-STA01.md:1–17`, before evaluating the evidence. The acceptance object is the completed CAPS01 STA01 run against the actual matching Work21 PR persona and completed final fit snapshot, not an empty template, an earlier candidate, or a generic assertion that the design is safe. Fit is a separate independent review. No mutable CURRENT or parallel fit-review report was inspected.

The frozen `sta-review-package01.json` SHA256 is **`58a3e88ec24d64cf3a153d696fee5335da12e74c7a18261516d240019774b210`**. I independently hashed every listed local member and checked its exact length: **122 files / 342,429,472 bytes; no missing member, length mismatch, or SHA256 mismatch**. The manifest itself is the separately hash-bound index, not an extra member in that total (`sta-review-package01.json:1–494`).

Only local hashing, AST/literal decoding, strict base64/gzip decoding, source comparison and report parsing were used. Runners and callbacks were neither imported nor executed. No network/SSH, vendor tools, simulator, host tests, Git, hardware access, source edits, frozen-evidence edits, remote process operation or task transition occurred. The sole authored deliverable is this report.

### Citation notation

Paths below are relative to this CAPS01 directory unless stated otherwise:

- **STA** = `artifacts-sta01/persona/build/syn/board/ia840f/syn_top/output_files/ofs_pr_afu.sta.rpt`.
- **LOG** = `artifacts-sta01/timing.log`.
- **PASS** = `artifacts-sta01/persona/build/syn/board/ia840f/syn_top/output_files/timing_report/clocks.sta.pass.summary`.
- **DRC** = `artifacts-sta01/persona/build/syn/board/ia840f/syn_top/output_files/ofs_pr_afu.tq.drc.signoff.rpt`.
- **QSF** = `artifacts-sta01/persona/build/syn/board/ia840f/syn_top/ofs_pr_afu.qsf`.
- **FIT** = `artifacts-fit01/persona/build/syn/board/ia840f/syn_top/output_files/ofs_pr_afu.fit.rpt`.
- JSON pointers on compressed receipts identify decoded fields, not newly materialized files. Captured Tcl line references refer to strict base64-decoded `result-sta-prereq01.json.gz#/files/<name>/base64`; those bytes were checked against their recorded lengths/hashes and the copied-input inventory.

## 2. Specification checks: acquisition, predecessor and exact inputs

### 2.1 Actual native acquisition — PASS

The verified invocation is:

```text
/opt/altera/25.1/quartus/bin/quartus_sta ofs_top -c ofs_pr_afu --snapshot=final --multicorner=on --do_report_timing --do_report_cdc_viewer
```

The native result is **native/effective/outer 0/0/0**, complete/success/success-marker true; no timeout, recorded descendants at leader exit, surviving owned process group, native diagnostic errors or postflight errors. Recorded command time is `2026-09-23T21:45:26.993246+00:00` to `2026-09-23T21:46:56.531855+00:00`, PID **142599**, start ticks **16319879**. The accepted callback's executable, cwd and argv match the sole literal permitted STA context, and its PID/start ticks match the command receipt. This is recorded completed-run evidence, not a new observation of the workstation's present process state (`artifacts-sta01/gate-events.jsonl:1`; `sta-parent-verification01.json:3–32`; `run-sta01.py.in:85–119`).

Actual native identity is **Quartus Prime Pro 25.1.0 Build 129**, **AGFB027R25A2E2V**, project **ofs_top**, top **top**, revision **ofs_pr_afu / PR_IMPL**, final snapshot, Work21 **release03**, UUID **`673c03a1-cef3-4c82-bf10-b12c247d9718`**. The LOG explicitly loads final databases for root_partition, green_region and both auto_fab partitions. The native timing report identifies final timing models and sign-off delay models. These measured identities, not legacy comments/version headers, govern this review (`LOG:13–39,62`; `STA:2506–2528`; `QSF:11–12,26,111–114`; `run-sta01.py:5` literal config; `result-sta01.json.gz#/uuid`).

I verified the **5,747,132-byte** STA archive against outer receipt SHA256 **`1b306237f3f8edebfddd23753cab0a9777f1db725d92e0e0324e2f12be990834`**. All **13** embedded exports strictly decode and match their declared byte counts, SHA256 values, output-hash entries and local artifact bytes. They include the separate signoff DRC report, the native main and summary reports, both pass/fail summary files, clocks report and selected user-clock file; the zero-byte failed-domain summary is an actual captured member, not an omitted report. Native footer: **0 errors, 380 warnings** (`outer-sta01.json:1–5`; `sta-parent-verification01.json:33–100`; `run-sta01.py.in:130–144`; `LOG:3647–3652`). The STA main-report SHA256 is `1b7d4b12d18131f495fadb789f9337ca8c0d44fc69be1d85a17fca16e79a4213`.

### 2.2 Completed-fit and source chain — PASS within the receipt/hash boundary

The runner and prerequisite capture bind the exact completed CAPS01 fit archive SHA256 **`4807b92fdc0cf84ef015c566e9f77a350f1fd91e6f59fa7d9a80da553824f5cb`**, **4,096,728 bytes**, not a same-named prior fit. I decoded and checked all **18** fit exports against their lengths/hashes and local bytes as predecessor-chain evidence. Its receipt is complete/success with native/effective/outer 0/0/0; the native log commits the final database and reports fitter success (`artifacts-fit01/fitting.log:678–681`; `capture-sta-prereq01.py:4–8`; `run-sta01.py.in:17–23`). This verifies native completion and provenance, not the separate independent physical-fit verdict.

The completed-fit prerequisite inventory, STA literal `persona_inventory`, and STA `original_setup_inventory` are exactly equal: **5,503** entries. All **722** completed-fit QDB output hash/length records reconcile with that prerequisite inventory. The **344** protected physical records consist of **277 final**, **34 partitioned**, and **33 synthesized** paths; each is hash/length-equal across fit output, prerequisite capture and STA output, and every one is in the reconstructed critical input set. The imported static `ofs_top.qdb` is additionally bound to matching release03 and critical inputs: **83,178,648 bytes**, SHA256 `7f8f25463afe3ae95d9660ddf4c5c6755d6704f828fd400de34ae38fa2aa0fc8` (`sta-input-roles01.json:2–377`; `run-sta01.py.in:22,35–39,57–61,126–138`; receipt/config inventories).

Source provenance also reconciles through the actual setup → synthesis → fit → STA configs: **13 AFU sources**, **255 generated records**, **4,936 release records**, and **92 non-Quartus tool bindings** remain identical across the relevant stages; both newly bound STA executables match prerequisite tool records. Decoding the original setup's AFU payloads and comparing with frozen CSR02 setup proves only `afu/csr_mgr.sv` differs. The other **12** AFU files and generated inventory match. Candidate CSR SHA256 **`053b9855aa860c410337f5cae7e6160c6086726903cf988a1d35f032cb7a0b93`** matches the accepted raw-capability candidate; baseline SHA256 is `42d09ffffb91152b9f688014bcff9ffc13e5382cddd7f478e5f9b992da232a77` (`source-delta01.json:1–20`; `run-setup01.py:5`, `run-synth01.py:5`, `run-fit01.py:5`, `run-sta01.py:5`; `../dma-csr-metadata01/csr_mgr-candidate01.sv:90–119,343–353`).

That already accepted CAPS01 source delta adds tagged read-only capability words and extends read-address eligibility; it does not change the descriptor/data controls. Its source/unit acceptance remains separately scoped. I did not rerun or expand the prior unit result into mapped equivalence (`../dma-csr-metadata01/UNIT-ACCEPTANCE.md:5–9,19–23`; `SYNTH-ACCEPTANCE.md:9–11`).

### 2.3 Preservation and output roles — PASS with explicit boundaries

I reconstructed **all 5,749 critical path→SHA256 bindings** from the copied persona inventory minus the exact runtime-role list, the after-QSF, AFU/generated inventories, two new gate payloads, JSON and source list. The reconstructed dictionary equals `result-sta01.json.gz#/input_hashes` exactly, rather than merely agreeing with the parent's count (`run-sta01.py.in:57–68`).

The **26 exact existing runtime-output roles** agree across the config, role ledger and result; they are disjoint from all 344 protected records. They preserve the prior reviewed role set, including the exact `qdb/_compiler/ofs_pr_afu/_flat/25.1.0/legacy/1/runlog.db` path. There is no blanket QDB exclusion. The **97 PID-qualified clearbox** files remain immutable critical inputs, not ignored temporary files (`sta-input-roles01.json:4–31,378–479`).

All seven changed pre-existing QDB records are within those roles: report.cmp/report.fit/report.syn model+RDB pairs and runlog.db. Two enumerated text outputs also change (flow and SDC-constraints reports). Four additional QDB outputs are report.sta model/RDB, `da_report_timing_signoff_final.sqlite3`, and `ofs_pr_afu.sta.qmsgdb`. None of these changes is a protected physical-path change. I verified the precise before/after inventories, not an assumption that every QDB byte is immutable. I make no claim here to have independently decoded runlog.db contents or native structural databases.

All four native postflight preservation flags are true: original fit persona (`setup_unchanged`), release, tools and bound inputs; postflight errors are empty (`sta-parent-verification01.json:101–110`; `run-sta01.py.in:121–142`). Local rehashing independently authenticates captured bytes and their chain; preservation of remote-only files is supported by the bound runner's pre/post checks and receipts, not a fresh remote rehash during this local review.

### 2.4 Template, resources and no STA policy change — PASS, no worker-utilization inference

AST comparison establishes that `run-sta01.py` is the frozen template with only its literal config substituted, and the dispatch's embedded-runner digest matches the file: **`ac11c04e4e2bc4b9b6461ae3b51c8866cefc44a44c09f1724875b8c3e13d9c2f`** (`dispatch-sta01.json:1–10`). No runner import was used.

The new template takes `fit_parallel_processors` from the completed predecessor rather than assuming the historical value 2. I verified that field is **36**, agrees with the completed-fit resource receipt and the sole copied QSF processor assignment, and agrees with the fresh allowed affinity. The actual before/after QSF diff is **only two hook assignments**, at lines 2–3, changing fit callback names to STA callback names. NUM_PARALLEL_PROCESSORS remains 36. There is **no STA-stage RTL, SDC or clock-policy change**; all **45** copied `.sdc` inventory records also exactly match the frozen CSR02 STA baseline. Existing constraints/exceptions are not thereby certified correct (`run-sta01.py.in:41–56`; `sta-template-delta01.patch:3–11`; `sta-input-roles01.json:479`; `QSF:2–3,95–98,146`). The earlier preparation record is explicitly historical/prepared-only; the later completed receipt and bound config resolve its pending fit digest/inventory, not an edit to that record (`sta-preparation01.json:2,29–31`).

Recorded affinity/QSF parallelism is **36**; per-process RLIMIT_AS is **68,719,476,736 bytes (64 GiB)**, with finite deadline and no competing native process in the captured preflight. However, native Parallel Compilation reports **36 detected / maximum 24**, while Warning20031 reports **18 system processors**. These distinct observations do **not** establish 36, 24 or 18 effectively utilized STA workers. The per-process address-space limit is not aggregate containment (`run-sta01.py.in:24–33,46–50,80–95`; `sta-parent-verification01.json:125–165`; `STA:2532–2538`; `LOG:10–11`).

## 3. Specification checks: clock policy and constrained-domain observations

### 3.1 The actual native reporting policy is accounted for

The selected QSF hook sources `user_clock_freqs_compute.tcl`, then `report_timing.tcl`. The former is not a read-only report action: it computes/selects auto frequencies, writes the user-clock output and rereads SDC/updates the netlist. Its frequency calculation uses **setup, recovery and minimum pulse width**, not hold/removal; the broad introductory Fmax comment is not a substitute for that implementation. Its optional-clock/no-slack **10000 MHz** fallback is not a measured timing pass. Separately, `report_timing.tcl:54–84` loops every available operating condition and the five metrics, sending nonnegative domain records to PASS and negatives to FAIL. It emits its extra per-corner detailed-path files only for negative domains. Thus their absence here is not evidence that every passing source cone received a targeted detailed query (`QSF:97–98`; captured `ofs_sta_report_script_pr.tcl:11–14`; captured `user_clock_freqs_compute.tcl:50–79,175–180,195–203,281–283,358–361`; captured `report_timing.tcl:54–84`).

Actual requested and selected user clocks remain **high 200 MHz / low 100 MHz**. The native log explicitly says high is unused by the AFU, records the request and saves 200/100, then updates the timing netlist (`LOG:3101–3129`). I compared **all 81 clock-property rows, every cell**, in current and frozen CSR02 main reports and found exact equality. The selected user-clock output is byte-identical to CSR02 (`STA:2755–2840`; corresponding CSR02 `ofs_pr_afu.sta.rpt:2755–2840`; both `output_files/user_clock_freq.txt:1–3`). No frequency reduction or newly added false-path/waiver explains the reported result. Existing false paths, ignored filters and coverage limitations remain. In particular, 200/100 is not the bank-core timing frequency or proof of an active AHLS timing path on those user clocks.

### 3.2 Independently parsed result — bounded PASS

I parsed the entire native PASS file with strict record grammar and decimal arithmetic, checked every record against the parent ledger, checked uniqueness of `(corner, metric, clock)` keys, and verified the failed-domain file is empty. Result: **645/645 reported domain records nonnegative, all TNS exactly 0.000**. Each corner has **129 records: 17 setup, 17 hold, 10 recovery, 10 removal and 75 minimum-pulse-width**. The complete key set equals frozen CSR02; it is not a selectively reduced comparison set. The 129 per-clock worst values and 129 TNS cells also reconcile exactly with the native main report's multicorner table (`PASS:1–2580`; `sta-domain-timing-records01.json:1–5162`; `STA:216345–216500`). N/A cells in the native main table were not treated as zero or passing tested domains.

All numbers below are **reported domain minima in ns**, not matched-endpoint measurements:

| Native corner | Records | Setup | Hold | Recovery | Removal | MPW | PASS lines |
|---|---:|---:|---:|---:|---:|---:|---|
| `2_slow_vid2_100c` | 129 | 0.216 | 0.000 | 0.278 | 0.204 | 0.000 | 1–515 |
| `2_slow_vid2b_100c` | 129 | 0.225 | 0.004 | 0.242 | 0.211 | 0.000 | 517–1031 |
| `MIN_fast_vid2a_0c` | 129 | 0.720 | 0.007 | 0.674 | 0.142 | 0.000 | 1033–1547 |
| `MIN_fast_vid2a_100c` | 129 | 0.596 | 0.003 | 0.575 | 0.147 | 0.000 | 1549–2063 |
| `MIN_fast_vid2_100c` | 129 | 0.587 | 0.000 | 0.578 | 0.140 | 0.000 | 2065–2579 |
| **All-corner minimum** | **645** | **0.216** | **0.000** | **0.242** | **0.140** | **0.000** | `STA:216349` |

There are **seven exactly 0.000 reported slack cells**, not positive margin everywhere: EMIF1 core hold at slow vid2 and fast vid2, plus `altera_int_osc_clk` MPW at all five corners (`PASS:69–71,217–219,733–735,1249–1251,1765–1767,2133–2135,2281–2283`). “Exact” here refers to the reported decimal cells, not unrounded internal timing precision.

EMIF0 core slow setup domain minima are **+0.319 ns** and **+0.332 ns** (`PASS:9–11,525–527`), versus prior CSR02 **+0.375/+0.398 ns** (`../ahls-persona-work21-csr02/sta-domain-timing-records01.json`, matching keys; prior `STA-ACCEPTANCE.md:5`). These remain nonnegative but are **not** an exact old-launch/old-capture endpoint comparison or proof that a particular source feedback/arithmetic/admission path has the same mapping. No all-bit/source-cycle mapped-equivalence conclusion is made.

## 4. Quality second: findings retained without waiver

### Q1 — High: native Design Closure FAIL is material and unchanged by numerical timing acceptance

The native Design Closure Summary says **Timing Closure Pass; Design Closure Fail**, with Design Assistant **High Severity Violations** and **Unconstrained Paths Fail** (`STA:2844–2866`). The enabled signoff table has **22/88 failed rules: 7 High, 7 Medium, 8 Low**, zero waived. I parsed thousands-separated counts rather than dropping `2,496`, and matched the main-report rule table to the separate DRC export (`STA:216505–216597`; `DRC:123–215`).

| Severity | Failed rule | Reported violations | DRC line |
|---|---|---:|---:|
| High | TMC-20027 — collection filter matches multiple types | 19 | 127 |
| High | CDC-50001 — unsynchronized 1-bit asynchronous transfer | 13 | 128 |
| High | CDC-50004 — MUX-type CDC insufficient constraints | 7 | 129 |
| High | RES-50001 — asynchronous reset not synchronized | 4 | 130 |
| High | CDC-50007 — multi-bit synchronizer bus insufficient constraints | 2 | 131 |
| High | CDC-50012 — multiple clock domains drive synchronizer | 2 | 132 |
| High | CDC-50003 — CE-type CDC insufficient constraints | 1 | 133 |
| Medium | BBD-60000 — PR/core ports not directly registered | 2,496 | 134 |
| Medium | BBD-60002 — constant-driven PR/core output | 152 | 135 |
| Medium | BBD-60001 — PR/core input does not drive register | 40 | 136 |
| Medium | TMC-20025 — ignored/overridden constraints | 32 | 137 |
| Medium | TMC-20026 — unmatched-filter empty collection | 31 | 138 |
| Medium | RDC-50003 — multiple asynchronous reset synchronizers in domain | 5 | 139 |
| Medium | LNT-30023 — reset polarity conflict | 2 | 140 |
| Low | CDC-50101 — intra-clock false-path synchronizer | 45 | 141 |
| Low | FLP-40006 — potentially recoverable pipeline registers | 35 | 142 |
| Low | RES-50101 — intra-clock false-path reset synchronizer | 20 | 143 |
| Low | CDC-50008 — multi-bit synchronizer bus | 16 | 144 |
| Low | CDC-50102 — synchronizer after controlled CDC topology | 8 | 145 |
| Low | LNT-30010 — net drives reset and clock enable | 7 | 146 |
| Low | TMC-20604 — high timing-path endpoint span | 3 | 147 |
| Low | TMC-20603 — high immediate fan-out span | 1 | 148 |

These are native rule findings, not independently proven counts of functional failures or disjoint affected objects. **Info22360 says ten rules are disabled**; zero waived must not be presented as “all rules enabled” (`STA:215637`; `LOG:3095–3099`). Their full disabled-rule applicability is not established here. The minimal condition for a future stronger closure claim is an instance/constraint-supported disposition of the relevant failures and disabled coverage; a successful STA process or unchanged warning ID is not such a disposition. This does not block accepting the recorded bounded domain observation.

### Q2 — High: unconstrained paths, missing categories and exception coverage remain open

Both setup and hold report **2 unconstrained inputs / 78 pairs** and **2 unconstrained outputs / 10 pairs**. Inputs are `altera_reserved_tdi`, `altera_reserved_tms`; outputs are `bwbmc_bmc_irq`, `altera_reserved_tdo`. Clock counts of zero illegal/unconstrained clocks do not clear these ports (`STA:216196–216206,216299–216334`). Reserved/vendor names alone do not authorize false paths, and the BMC output is not cleared by timing inside other domains.

The Design Closure panel marks **Setup Data Delay, Recovery Data Delay, Max Clock Skew, TCCS and RSKM summaries Not Found**. Existing “Pass” labels for other summary categories, including DDR and metastability, are native category outcomes, not complete reset/CDC/exception/physical-DDR qualification (`STA:2854–2864`). The 645 domain records are the reported constrained set, not all possible physical paths. Default report paths and accepted prior representative CSR02 query07 work do not automatically establish detailed CAPS01 source-equivalent path coverage. No all-bit/source-cycle mapping or mapped equivalence is claimed; absence of that broader proof is not itself evidence of a new CAPS01 defect and is not a new generic execution blocker. No unchanged representative sweep or unchanged fit/STA rerun is requested merely because this limit persists (`STA-SCOPE01.md:3–7`; `RESULTS-STA01.md:13–17`).

### Q3 — All 380 native warning occurrences retained; no warning-clean claim

I re-parsed all native log warning lines, including indentation, and compared every `(line, severity, ID, message)` tuple with `sta-warning-ledger01.json`. Exact result: **379 Warning + 1 Critical Warning = 380 occurrences**, matching the footer. Repeated reads of SDC and log/report duplication are not additional independent defects; no warning is suppressed by this review.

| ID | Occurrences | First LOG line | Disposition |
|---|---:|---:|---|
| 20031 | 1 | 11 | Resource-report inconsistency retained; no effective-worker inference. |
| 20727 | 1 | 40 | Critical PR unused-input warning; clk_div2, clk_div4, uclk_usr and uclk_usr_div2 are explicitly dangling, not silently qualified. |
| 18502 | 17 | 45 | Current/base SDC assignment differences retained; unchanged policy is not proof of adequate coverage. |
| 332174 | 80 | 85 | Unmatched clock/register filters remain coverage risks requiring target-specific disposition. |
| 332054 | 163 | 86 | Accepted assignments with problems remain; do not equate acceptance with effective endpoint coverage. |
| 332049 | 116 | 113 | Ignored constraints remain, including active-bank async-shim matching issues; domain minima do not waive them. |
| 332158 | 1 | 414 | Native preliminary clock-uncertainty-characteristics warning retained alongside final timing-model labels. |
| 21620 | 1 | 3097 | Seven failing High signoff rules retained; see Q1. |

The complete native warning text and the dedicated DRC export remain the evidence, not just this group table (`LOG:40–61,85–113,414,3097,3647`; `sta-warning-ledger01.json`). Existing message/exclusion policy was not newly changed or justified here (`QSF:101–105`; `SYNTH-ACCEPTANCE.md:15–21`).

### Q4 — Reset, PR lifecycle, metadata and hardware limits remain separate gates

The completed fit's reset table calls for **two additional sys-clock cycles** and **four additional EMIF0-core cycles** due to retiming. Those are not total reset widths and do not prove actual reset assertion/deassertion reaches every relevant register. I checked the native table and its explanatory note directly (`FIT:26066–26068,26098,26132,26152`). Fitter electrical findings remain for `bwbmc_bmc_irq`, `bwbmc_bmc_mst_en_n`, `bwbmc_fpga_max_miso` (`FIT:5838–5844`). No independent physical-fit verdict is supplied by this STA review.

All synthesis **Q1–Q4 / R1 / R2** remain: warning/disabled-rule/message-policy limits; Critical20580/PR interpretation; active LSU burstcount fan-in/OR transformation and pruned reply/credit/ID/metadata correspondence; Critical19854 and PR initialization/reset findings; swept `freeze_cc`; and unqualified legacy metadata. Fitted preservation and native timing do not silently clear these issues (`SYNTH-ACCEPTANCE.md:13–21`; `RESULTS-FIT01.md:7–11`). In particular:

- A freeze port or swept synchronizer is not a demonstrated quiescence mechanism. Descriptor/kernel drain, accepted-response retirement, posted-write fencing, PR handoff, reset recovery and pinned-host-buffer lifetime remain unproven at the system boundary.
- Additive raw-capability words do not repair legacy raw512→3-bit width, raw32→4-bit depth, packed150→64-bit status, or hardcoded clock400 metadata. Source/unit acceptance and this STA observation neither authenticate a running image nor authorize MMIO (`SYNTH-ACCEPTANCE.md:18`; `../dma-csr-metadata01/UNIT-ACCEPTANCE.md:19–23`).
- No assembly, persona GBS, deployment, runtime/physical PR, electrical acceptance, physical DDR, PCIe/OPAE execution, numerical hardware correctness or durable-boot result is established. QSF's post-flow GBS assignment and configured assembler option are not evidence those stages ran; the sole observed command is STA (`QSF:42,123–124`; `run-sta01.py.in:119`). **Vendor DDR simulation: SKIPPED BY USER.**

## 5. Final disposition

The frozen records support **trustworthy completed final-snapshot multicorner acquisition and the bounded nonnegative constrained-domain observations**, with the actual source/fit/context chain and preservation/output-role boundaries verified above. No discrepancy requiring reacquisition of this unchanged STA snapshot was found.

Retain **DesignClosure FAIL**, seven zero-slack reported cells, all enabled-rule failures and disabled-rule limitations, unconstrained ports, missing categories, every warning, and every lifecycle/source-mapping/metadata/physical limitation. Source/unit evidence, native fit completion and independent fit acceptance, domain timing, detailed source-equivalent path evidence, full design closure and hardware qualification are distinct claims. Neither prior-candidate representative paths nor successful source/unit tests collapse those distinctions.

This FINAL report recommends **bounded ACCEPT WITH FINDINGS only**. It does not transition a task, waive a design rule, authorize a native/hardware operation, require an unchanged rerun, or create a new user-authorization barrier. Parent acceptance/publication and the separately owned fit review remain separate actions.

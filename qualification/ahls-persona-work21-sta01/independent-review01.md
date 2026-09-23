# Independent review 01 — actual Work21 persona STA01

Status: **FINAL**

## 1. Specification first

The contract is the frozen `T/SCOPE.md:3–7`, read before judging the result: one native Quartus 25.1 Timing Analyzer invocation on a fresh exact copy of completed fit02, preserving accepted RTL/generated inputs, imported static QDB, design SDC, requested auto-clock policy, tool identities and originals. Only the copied STA-only callback/helper and corresponding two QSF lines deliberately change. The existing OFS report hook is included; it is **not a purely observational hook**, because it computes a user-clock file and rereads SDC.

Acceptable acquisition evidence requires exact provenance, bounded native execution/completion, preservation reconciliation and truthful negative reports. It does **not** require pretending that timing passed. Numerical setup/hold/recovery/removal/minimum-pulse-width results, unconstrained paths, CDC/exception/reset coverage and PR/electrical/hardware acceptance are separate decisions. Prior fit02 acceptance retains F1–F6 (`F/RESULT-ACCEPTANCE.md:3–24`); this review does not reopen unchanged fitting or erase those findings.

No SSH, vendor/native/simulator execution, device access, synthesis/fit rerun, assembly/GBS, MMIO, programming, reset, driver change, reboot, implementation edit or git operation is within this review. Vendor DDR simulation remains **SKIPPED BY USER**. Source-correction analysis belongs to the separately scoped `qualification/dma-csr-timing01`, not this review. Parent alone consumes and publishes this disposition.

### Citation convention

All paths are relative to `N = /home/joe/Projects/Thesis/AHLS/new_bsp/new`:

- `T = qualification/ahls-persona-work21-sta01`; `F = qualification/ahls-persona-work21-fit01`.
- `J = T/artifacts-sta01/persona/build/syn/board/ia840f/syn_top`; `O = J/output_files`.
- `LOG = T/artifacts-sta01/timing.log`; `STA = O/ofs_pr_afu.sta.rpt`.
- `DRC = T/artifacts-reports03/persona/build/syn/board/ia840f/syn_top/output_files/ofs_pr_afu.tq.drc.signoff.rpt`.
- `D2 = O/timing_report/ofs_pr_afu_2_slow_vid2_100c_setup.rpt`; `D2B` is the corresponding `2_slow_vid2b_100c` report.
- `H = T/source-capture01/ofs_partial_reconfig`; `SDC = T/source-capture01/ofs_top.out.sdc`.
- `CSR = qualification/dma-csr-timing01/csr_mgr-baseline01.sv`, independently byte-equal to the selected `C.source_files['afu/csr_mgr.sv']` payload in `T/run-sta01.py:5`, SHA256 `b526562f8663139a1a5654e54695ada8de67ee260b3b6a79014344ab7f3c4073`.
- `TOP` means the decoded selected `afu/ofs_plat_afu.sv` payload from that same AST-literal configuration, with line numbers in its decoded bytes. It is the guarded actual top, not a similarly named scalar predecessor.
- `PIM = N/ofs-platform-afu-bbb/plat_if_develop/ofs_plat_if/src/rtl`. Specifically inspected FIFO/reset/SDC files below were individually hash-matched to the actual copied-persona inventory before use.

## 2. Bounded verdict

**ACCEPT TRUSTWORTHY NEGATIVE NATIVE STA01 EVIDENCE WITH FINDINGS, including the finite output-role/source-preservation supplement.** No unresolved in-scope integrity or native-completion blocker was found. This is acceptance of evidence that the design **fails setup timing and signoff coverage**, not acceptance of the design for timing signoff or deployment.

Preserve the exact historical result: **native/effective 0/0; outer 125; `success=false`; `bound_inputs_unchanged=false`; `timing_accepted=false`.** Do not rewrite the consumed runner, its result or receipt. The subsequent evidence justifies a separate bounded reconciliation of the runlog bookkeeping change, not an all-zero relabeling. No unchanged STA/synthesis/fit rerun is justified to fix this accounting issue.

**Signoff remains rejected:** two negative setup-domain summaries, unconstrained input/output paths, 24 failed enabled signoff DRC rules, disabled/suppressed reporting limits and unresolved active reset/CDC/PR obligations. The hardware goal remains incomplete.

## 3. Evidence and source quality

### Independently verified integrity

- Rehashed **all 74 frozen package members / 68,143,607 bytes**; all sizes and SHA256 values match. `T/review-package01.json` SHA256 is `5a103e04c7c0784c47f62c137baf061e628fa7590b20ec9735d14fa598421712`. A final pre-publication recheck also found no frozen-member drift.
- `T/result-sta01.json.gz`: **5,872,202 bytes**, SHA256 `387cdff4f13b15f37cbf9155c1d71576aedd13a63ee52447cada56384cdd91b6`, matching `T/outer-sta01.json:2–4`. All **14 embedded exports** decode to their declared sizes/hashes and match the local artifact bytes.
- Parsed every packaged `result-*.json.gz`, verified its outer receipt, and verified every embedded file payload. The dedicated DRC, two SQLite exports and seven prerequisite/helper exports also match their hashes. The DRC is **1,242,378 bytes**, SHA256 `f16c5f51627e34603c07878a9403e65c3a0403cb73501ccc98606cd58a0e8c3c`; its 88-rule summary is cell-for-cell identical to the standard STA report's summary.
- Parsed the **actual** STA and fit02 runner configurations using `ast.parse`/`ast.literal_eval` only. Neither runner nor its guard was imported or executed. STA code outside the literal configuration equals `run-sta01.py.in` outside its placeholder line. Actual runner hash equals the dispatch receipt's `embedded_runner_sha256`.
- Reconstructed **all 6,016 immutable runtime input bindings**, including copied inputs minus the 25 exact exclusions, the changed callback-bound QSF, new guard/Tcl bytes, selected AFU/generated sources and the exact serialized JSON/source-list bytes. The reconstructed dictionary equals the raw result dictionary, not merely a selected subset.
- The **5,769-entry** prelaunch inventory agrees among the prerequisite capture, actual configuration and result. Actual source/generated/release/tool-binding dictionaries, JSON, source list and AFU UUID agree with accepted fit02. The Quartus tool map adds the two required STA launcher/native identities; this is not a changed inherited tool identity.
- Verified the exact QSF before/after bytes: only `SOURCE_TCL_SCRIPT_FILE` and its `TEXT_FILE` helper change from the fit callback to the STA callback. The seven current source captures match their prerequisite payloads and prelaunch hashes. The supplementary `F/source-capture02` options/package-index files also match this STA input inventory.
- Independently reconstructed the raw 380-warning ledger, all 645 domain-summary records and all four line-bound native panels; the supplied aids match exactly. The aids were navigation, not substitutes for raw reports.

The static import remains bound as `ofs_top.qdb`, **83,178,648 bytes**, SHA256 `7f8f25463afe3ae95d9660ddf4c5c6755d6704f828fd400de34ae38fa2aa0fc8`. Source hashes and remote preservation receipts establish the bounded chain; this review does not claim local semantic inspection of all remote binary QDB contents, installed Tcl/tool internals, or exhaustive dependency closure.

### Actual native execution and stage boundary

The one command was:

```text
/opt/altera/25.1/quartus/bin/quartus_sta ofs_top -c ofs_pr_afu --snapshot=final --multicorner=on --do_report_timing --do_report_cdc_viewer
```

`T/run-sta01.py:17–43` verifies originals, creates an exclusive fresh STA leaf, copies completed fit02 and checks that copy before the narrow callback delta. Lines 44–56 bind the clean environment, exact STA context and live runner ancestry; `OPAE_PLATFORM_GEN` is absent. `T/artifacts-sta01/gate-events.jsonl:1` records accepted native PID **125808**, start ticks **14594603**, the exact native executable/argv/cwd. No gate rejection is exported or present in the native log.

The configured limits are two CPUs, **32 GiB per-process RLIMIT_AS**, no core dump and a **10,800-second** deadline (`:70–106`). Preflight records CPUs `[0,1]`, available memory **124,512,952,320 bytes**, free disk **1,289,090,904,064 bytes**, and no competing process from the enumerated tool set. These are normal-account source-bound controls, not a sandbox or aggregate-memory guarantee.

The native command ended **2026-09-23T17:01:47.204913+00:00**, with no timeout, observed residual group or surviving owned group. The later result-persistence timestamp is **17:01:55.380843+00:00**; do not conflate it with native completion. These are historical receipts, not a fresh remote process inspection.

`LOG:34` actually loads the final database; `STA:2506–2527` identifies **Quartus 25.1.0 Build 129 SC Pro**, Agilex 7 **AGFB027R25A2E2V**, revision `ofs_pr_afu`, snapshot `final` and sign-off delay models. `D2/D2B:17–21` independently identify final-snapshot detail. `LOG:3677–3683` records successful analyzer completion, **0 errors / 380 warnings**, **10,133 MB** peak virtual memory and **00:03:52** elapsed. “Successful” and “Final” identify execution/model state, not nonnegative timing.

### Output-role rejection reconciliation — accepted separately

The original acceptance expression requires all preservation flags (`T/run-sta01.py:112–137`); the false bound-input flag therefore correctly yields outer 125 despite native zero. Setup, release and tools are recorded unchanged, with an empty postflight-error list. Do not call this a timing-parser rejection: numerical acceptance was explicitly left false independently.

The finite ordinary-file supplement (`T/capture-delta01.py:5–23`) binds the exact original result archive, requires completed native execution/no owned survivors, rejects an enumerated active Quartus process, reads every authorized bound entry and checks read-time size/mtime stability. Its raw result reports exactly **one changed bound entry / 6,015 unchanged**:

```text
qdb/_compiler/ofs_pr_afu/_flat/25.1.0/legacy/1/runlog.db
before: a74cf367239a0c48ecc1b352b06fc9f47e783df456d5d313cf08dcb40bbebcb8
after:  6388e1c05fae09a23a5e203ec3b8332eb62bf6dea6ab28364379d7cf90ddbbc7
```

Both versions are **8,192-byte SQLite databases**. Independently opened them locally using SQLite `mode=ro&immutable=1`: schema is identical, all **nine prior rows** are identical, none is removed, and precisely one row is added: ID 10, **Timing Analysis (Finalize)**, 100 percent, `done/done`, native PID **125808**, zero errors and two critical warnings. The row corresponds to the observed native run; it is not a modified RTL/SDC/static-image record.

The enumerated **25 mutable report/cache paths** and **344 protected physical/synthesis/partition snapshot paths** agree among configuration, role ledger and raw result and are disjoint. Independently compared all 344 protected hashes against both native postflight and supplemental QDB inventories: all unchanged. The complete **726-entry** native QDB inventory also equals the later supplemental inventory. The six changed pre-existing report-model/report-database entries are already inside the explicit output-role exceptions; the extra bound-input rejection is the runlog alone.

**Disposition:** accept the negative native evidence with this supplement; retain outer 125 and the original false flag. On the next genuinely changed stage, classify only this exact proven status-database role as mutable, retaining exact prelaunch binding and immutable source/static/final snapshots. Do not broadly exempt QDB or rerun unchanged analysis.

The original export selection (`:121–125`) omitted `.tq.drc.signoff.rpt`. `T/capture-reports03.py:4–11` is an ordinary-file read/export, not a native rerun. Its stable-read check, byte payload/hash and identical standard-report summary satisfactorily repair the **collection gap**, not the failed DRC. Include the dedicated report explicitly in a future changed collector.

## 4. Verified numerical result and clock/report phases

### Domain summaries are negative, not exhaustive path enumeration

`H/report_timing.tcl:47–88` enumerates available operating conditions and five metrics, then writes domain summaries. Independently counted:

| Metric | Domain/corner records | Negative records |
|---|---:|---:|
| Setup | 85 | 2 |
| Hold | 85 | 0 |
| Recovery | 50 | 0 |
| Removal | 50 | 0 |
| Minimum pulse width | 375 | 0 |
| **Total** | **645** | **2** |

Each of five corners contributes 129 records; **643 are nonnegative**. `clocks.sta.fail.summary:1–7` identifies the exact failing clock `local_mem_wrapper|mem_ss_top|mem_ss_sv|mem_ss|mem_ss|emif_0|emif_0_core_usr_clk`:

| Corner | Setup slack | Keeper TNS |
|---|---:|---:|
| `2_slow_vid2_100c` | **-0.367 ns** | **-26.907 ns** |
| `2_slow_vid2b_100c` | **-0.356 ns** | **-25.662 ns** |

The worst reported paths are **our current DMA CSR manager**, not a vendor EMIF PHY hold defect. In both `D2/D2B:50–76`, the worst launch is `core|dma|csr_mgr_inst|dma_csr_map.descriptor.length[14]~ENA_dff`; the destination is `...descriptor.length[0]~DUPLICATE`. Both clocks are EMIF0 core-user clock, relationship **3.000 ns**, with **no SDC exception** and **six logic levels**. D2 reports **3.186 ns** data delay; D2B reports **3.176 ns**. D2's native delay accounting is cell 1.740 ns, uTco 0.248 ns and routing-element 1.198 ns (`:81–90`), not a routing-only diagnosis.

Each detail file contains exactly **20 violated path bodies**, matching `-npaths 20` (`:4–18`; `H/report_timing.tcl:77–80`). All 20 source/destination pairs in each summary are descriptor-length registers in this same current CSR cone, with ENA/SCLR-derived launch registers. The requested detail cap is saturated; this is **not exactly 20 failures in the design**, not complete endpoint enumeration and not proof that every failing path has been diagnosed.

### Auto user clocks did not fix the bank-clocked core

The hook order is user-clock computation then OFS timing reporting (`H/ofs_sta_report_script_pr.tcl:11–14`). `user_clock_freqs_compute.tcl:34–79,350–362` deletes/recreates the computed-clock file and rereads SDC/update timing. Its broad Fmax comment must be read against implementation: the period adjustment considers setup/recovery/MPW, **not hold/removal** (`:195–203`), and has 10 GHz advisory fallbacks (`:175–180,281–283`). No such fallback appears in this actual log.

`LOG:3118–3146` reports high clock unused by the AFU, advisory calculations **334.44 / 181.91 MHz**, and actual retained **200 MHz high / 100 MHz low**. `O/user_clock_freq.txt:1–3` agrees. Before-hook native clock-table rows and after-hook `clocks.rpt` contain **81 identical clock-property rows**, including user-clock periods 5.000/10.000 ns and EMIF0 core period 3.000 ns (`STA:2761–2762,2782`; `clocks.rpt:8–9,29`). Requested `auto-200`/`auto-100` bytes are unchanged. These results are neither achieved AFU throughput nor a frequency reduction that cured the setup failure; `TOP:6,23–27,47–51,73–75` clocks the actual core from bank0 memory.

**Phase distinction:** default analysis/DRC runs before the hook (`LOG:3112–3118`); the hook rereads SDC (`:3146–3659`) before its custom domain/path reports (`:3660–3677`). Identical clock tables establish clock-property agreement, **not full exception-set or coverage equivalence across both passes**. Do not advertise the earlier CDC/DRC panels as newly regenerated after the second SDC load.

## 5. Actionable findings — no waivers

### F1 — Confirmed setup failure; smallest source check is the current CSR feedback cone

**Blocks timing signoff.** `CSR:103–128` computes length-dependent end addresses, host/bank range and admission conditions; `:136–153` folds that into `write_response`; `:379–405` uses the shared successful-write condition to update descriptor fields, including length. This provides a concrete source path to investigate against the native ENA/SCLR-to-length cone; it does not by itself establish the exact optimizer factoring of every reported cell.

**Next:** the separately scoped correction analysis should connect the reported nodes to these expressions and evaluate the smallest protocol-preserving decode/logic or staging correction. Retain full-address/size/strobe validation, range/overflow/bank/length guards, supported modes, descriptor-field freshness, FIFO/error gating, accepted write/B-response semantics and exactly-once descriptor ownership. Directed regression must cover invalid GO, stale fields, queue full/errors, split AW/W and backpressure/reset interactions before any changed native result is accepted. Do not lower DDR clocks, invent false paths/multicycles, discard guards, or try an unchanged seed/fit as an explanation.

### F2 — Unconstrained I/O and effective exception coverage remain open

**Confirmed native failure, not merely missing documentation.** `STA:216426–216436` reports, for both setup and hold, **2 unconstrained inputs / 78 pairs** and **2 unconstrained outputs / 10 pairs**. `:216529–216565` names inputs `altera_reserved_tdi`, `altera_reserved_tms`, outputs `bwbmc_bmc_irq`, `altera_reserved_tdo`. Zero illegal/unconstrained clocks is not full path coverage; these are pairs-only counts, not a sum of distinct physical pins or disjoint setup/hold paths.

**Next:** identify exact JTAG/BMC signal ownership and required asynchronous/external timing treatment from the bound static-shell constraints and board/vendor contract; establish the applicable effective delay/exception and receiver endpoints. Reuse the existing static-source chain before requesting any missing finite source capture. Do not add guessed I/O delays or blanket false paths. Keep BMC electrical termination/slew obligations from fit F3 separate from this timing finding.

`O/ofs_pr_afu.sdc_constraints.rpt:15–28` contains only narrow post-elaboration/post-synthesis QIP statement rows; it is **not** an effective timing-exception audit. The CDC transfer matrices (`STA:4014–5630`) contain timed and cut endpoint observations, not proof of synchronizer correctness or complete endpoint/exception coverage.

### F3 — Stale selectors are real, but current-persona skew coverage is not wholly absent

`SDC:1673–1684` retains the predecessor `ahls_binding|board|banks[...]` / `primary_avalon` selectors; actual `TOP:23–27,47–51,73–75` uses `primary_axi`, `map_banks` and `core`. DRC TMC-20025/20026 explicitly rejects those literal skew selectors (`DRC:3109–3121,3141–3170`). Other invalid/overridden constraints concern PCIe/reset/memory clock names, not just the scalar predecessor (`:3096–3108,3122–3127,3165–3168`). A fully overridden multicycle gets no safety credit.

**Important narrowing from raw reports:** bound `PIM/utils/quartus_ip/ofs_plat_utils_avalon_dc_fifo.sdc:21–39` also enumerates current FIFO instances dynamically. The native max-skew panels contain **40 current-persona assignment-summary rows per corner**: 20 primary-host, 10 bank0, 10 bank1; all are nonnegative across five corners (`STA:3097–3776`). First-corner examples: primary `:3124`, bank1 `:3154`, bank0 `:3155`. Minimum current-persona summary slack by panel is **1.333, 1.338, 1.427, 1.383, 1.378 ns**. Thus stale exported selectors do **not** prove all actual host/bank FIFO skew constraints are missing.

**Next:** reconcile expected active primary/bank FIFO pointer directions with these actual dynamic-SDC summaries, effective net/data-delay constraints and their timed/cut endpoint collections. Preserve source-clock/destination-clock identities, replacement order, actual matched objects and per-assignment detail/count limits. These 40 rows per corner are assignment summaries, not exhaustive path counts. Resolve named remaining gaps before a targeted hierarchy repair; no blind global replacement, new false path or claim of full closure follows from matching names or positive summary slack.

### F4 — Signoff DRC includes both imported-static risks and a current-persona high reset finding

`DRC:123–214` contains **24 failed / 88 enabled rules**, **zero waived**. `LOG:3114–3117` additionally records **10 disabled rules**, and failure distribution 8 High, 7 Medium, 9 Low. Do not replace this with the copied earlier synthesized DRC, or present 64 passing enabled rules as all-rule coverage.

| High rule | Violations | Primary detail / disposition |
|---|---:|---|
| TMC-20027 | 19 | `DRC:227–245`: ambiguous collection object types in PCIe/MSA/reset constraints; inspect effective collections, not vendor-origin waiver |
| CDC-50001 | 13 | `:258–270`: static protocol-checker/reset/FLR and MSI-X crossings |
| CDC-50004 | 7 | `:283–289`: static protocol-checker MUX transfers, with literal unconstrained cells |
| RES-50001 | 4 | `:302–305`: static reset crossings into protocol-checker/MSI-X logic |
| CDC-50007 | 2 | `:318–319`: MSI-X FIFO Gray-pointer buses; unconstrained skew/data-delay observations |
| CDC-50012 | 2 | `:332–333`: multiple clock domains into protocol-checker/user-clock synchronization |
| CDC-50003 | 1 | `:346`: static completion-metering CE transfer, unconstrained skew/net/data delay |
| RES-50004 | 1 | `:359`: **actual persona `primary_axi` read-ROB response FIFO write-reset chain**, not a stale scalar selector |

**Smallest current-persona check:** inspect the exact `primary_axi|e|impl|hc|s.rob|rd_rob|cc.rob|dc_ctrl|rsp_fifo|af.f|dcfifo|write_reset_sync` chain and its fitted reset drivers. Bound FIFO RTL registers the two domain resets, ORs them into `reset_merged` and drives depth-3 asynchronous reset synchronizers (`PIM/utils/quartus_ip/ofs_plat_utils_avalon_dc_fifo.v:217–254`). Bound `ofs_plat_utils_reset_synchronizer.v:37–54` establishes intended common asynchronous assertion/synchronous release. The native row names different mapped `reset_merged` LUT outputs feeding members of this chain. Compare effective mapped polarity/connectivity/assertion-release behavior with that source; **do not infer a functional defect solely from alias names, but do not waive the high result because source intent is familiar**.

Also inspect current reset reconvergence and polarity observations: `DRC:3183,3186–3187` includes actual primary/bank reset chains, and `:3201` reports a current primary-host response-credit/burst-mapper polarity conflict. These cannot all be dismissed as imported static noise. For the static high rows above, first compare the exact accepted static image/source and effective CDC/reset exceptions; no persona source change is justified merely because their instance names are vendor-owned.

PR boundary Medium findings are **2,496 not-directly-registered ports, 152 constant-driven outputs, 40 inputs not driving registers** (`DRC:135–137,368 onward`). They are not 2,496 independent functional failures or the fitter's distinct 46 dangling-input list. Carry them into source-bound PR-boundary review with prior fit F2, not automatic noprune insertion or a blanket waiver. Remaining Medium/Low groups include overridden/empty collections, reset convergence/polarity, intra-clock false-path synchronizers, recoverable pipeline registers and tension/span advisories (`DRC:138–150`); they remain findings, not proof of a specific corrective assignment.

Per-rule report limits are finite (500 or 5,000), and native fields may abbreviate member lists (for example `DRC:332`). Do not infer full node enumeration from a rule total, a sample register or an abbreviated list.

### F5 — Preserve phase/collection quality limits in the next changed stage

No further capture or unchanged native run is needed to establish **this negative verdict**. For the next changed stage only:

1. Include the dedicated signoff report and the exact mutable runlog role without weakening source/static/final bindings.
2. Preserve pre-hook and post-reread clock/exception/coverage phase labels; if claiming post-hook coverage equivalence, collect the missing effective exception/coverage evidence rather than assuming it from identical clocks.
3. Keep capped path detail, disabled rules and inherited warning suppressions explicit. `J/ofs_pr_afu.qsf:102–105` sources the shared suppression script; no warning-clean or universally enabled-rule claim is supportable.
4. Retain all prior mapped-functional, kernel-reset, freeze/drain, response-retirement, host-buffer-lifetime, electrical and runtime-PR findings. This STA result closes the prior question of whether final-snapshot STA can load and finish; it does not close those acceptance gates.

## 6. Complete native warning accounting

Independently counted each explicit warning occurrence in `LOG`, including indented diagnostics, without recounting copies in `.rpt` files. **380 = 378 Warning + 2 Critical Warning**, exactly matching `LOG:3678`.

| ID | Occurrences | Disposition |
|---|---:|---|
| 20727 | 1 critical | Actual PR unused inputs; retain fit F2 and signoff boundary findings |
| 18502 | 17 | Base/current SDC assignment differences, `LOG:44–60`; not newly edited design SDC |
| 332174 | 80 | Unmatched filters: 40 in initial load, 40 in hook reread |
| 332054 | 163 | Accepted-but-problematic assignments/replacements: 41 initial, 122 after hook begins |
| 332049 | 116 | Ignored constraints: 58 initial, 58 in reread |
| 332158 | 1 | Preliminary clock-uncertainty characterization, `LOG:413` |
| 332148 | 1 critical | Timing requirements not met, `LOG:419` |
| 21620 | 1 | Eight failing High DRC rules, `LOG:3115` |

The increase from fitter warning counts is not evidence of that many new RTL defects: the report hook evaluates SDC again, producing repeated missing-filter/ignored-constraint diagnostics and additional replacements. Conversely, repetition does not make a real ignored active constraint harmless. No Error/Fatal or gate-rejection line was found; this does not convert the explicit timing and coverage failures into a pass.

## 7. Handoff and limits

- **Consume this frozen STA01 result and output-role supplement WITH FINDINGS as trustworthy negative evidence.** Preserve native/effective/outer **0/0/125** and original false runner status.
- **Do not sign off timing/coverage or deployment.** Prioritize the separately scoped CSR source correction; retain the exact unconstrained, active-reset and effective-coverage checks above. No unchanged native rerun is recommended and no hardware/native launch is authorized by this review.
- No assembler/persona GBS or live hardware qualification was produced. The overall goal remains incomplete; vendor DDR simulation stays skipped.

Only `T/independent-review01.md` was authored, first as **IN_PROGRESS**, then this **FINAL** report. All review computation was local and inert. One local bulk AST-inspection cell timed out; it had no native command or file write, and the necessary checks were completed using bounded AST/literal inspection afterward. No evidence blocker remains from that local tool issue. The full report SHA256 is supplied separately after finalization, not embedded self-referentially here.

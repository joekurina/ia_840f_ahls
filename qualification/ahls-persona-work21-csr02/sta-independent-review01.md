# CSR02 final multicorner STA01 — independent review

Status: **FINAL**

**Verdict: SPECIFICATION PASS; QUALITY PASS WITH FINDINGS. ACCEPT WITH FINDINGS only the completed native final-snapshot acquisition and the reported nonnegative constrained-domain summaries.** Direct CSR-cone closure is **NOT ESTABLISHED**. Overall native Design Closure remains **FAIL**. This is not full timing/design/hardware signoff or authorization for another operation.

## 1. Specification first: scope and evidence identity

Read `STA-SCOPE01.md` and `RESULTS-STA01.md` first. The acceptance requested is truthful acquisition and nonnegative reported domain results, not universal path coverage. This review used static file reads, AST/literal parsing, gzip/base64 decoding, hashing, and exact comparisons only. No runner was imported or executed; no SSH/network/vendor/simulator/device operation, Git action, implementation edit, task transition, or mutable CURRENT/review edit occurred. The sole deliberately authored project artifact is this report, first IN_PROGRESS and then FINAL.

Frozen package `sta-review-package01.json`:

- SHA256 **`8fd61cc06233f8f1f6c04e3b7d9212967f4d60bce498e7c332280d5c0edb14b2`**.
- Independently hashed **111/111 members, 337,171,232 bytes**; every size and SHA256 matched. A second complete package/member verification also matched before finalizing this report.
- STA archive `result-sta01.json.gz`: **5,770,723 bytes**, SHA256 **`2c95ee5dd45f1f9781af202016273e1cfb333467eae12b89c356519732979f40`**.
- Decoded and verified **13/13 exported payloads**, including the empty failed-domain summary, against their embedded lengths/hashes, `output_hashes`, and exact local artifact bytes. The dedicated `ofs_pr_afu.tq.drc.signoff.rpt` is included, not silently omitted by a `.sta.*` filter.

All paths below are frozen package members or embedded payloads of those members. References use these abbreviations:

- **STA**: `artifacts-sta01/persona/build/syn/board/ia840f/syn_top/output_files/ofs_pr_afu.sta.rpt`, SHA256 `d33c273f316425a02a757377e0d56c415c27d16a8901b5118c08c4fba58323f6`.
- **LOG**: `artifacts-sta01/timing.log`, SHA256 `87921b9ad4070b26db2e66525264d5c8a0b77e6c2201422aac0f538aae943f03`.
- **DRC**: sibling `ofs_pr_afu.tq.drc.signoff.rpt`, SHA256 `dad3c4ff69d6f93e11ff0fe29657ac6be5a237ea250f3795a990ea4bdf96c561`.
- **SYN**: corresponding `artifacts-synth01/.../output_files/ofs_pr_afu.syn.rpt`.
- **FIT**: corresponding `artifacts-fit01/.../output_files/ofs_pr_afu.fit.rpt`.
- **OLD**: `../ahls-persona-work21-sta01/artifacts-sta01/persona/build/syn/board/ia840f/syn_top/output_files/ofs_pr_afu.sta.rpt`, SHA256 `78a9336f50e8416b342940e888eec5eca98d55a9fb7b7c37000657afa8f1572b`.

### 1.1 Acquisition, native identity, and prerequisites — PASS

The sole recorded command is:

```text
/opt/altera/25.1/quartus/bin/quartus_sta ofs_top -c ofs_pr_afu --snapshot=final --multicorner=on --do_report_timing --do_report_cdc_viewer
```

Native/effective/outer **0/0/0**. PID **131265**, start ticks **15393786**, started **2026-09-23T19:11:06.066296+00:00**, ended **2026-09-23T19:12:36.114564+00:00**. The completed archive has `complete=true`, `success=true`, the native success marker, no acquisition diagnostics or postflight errors, no timeout, no observed residual descendants at leader exit, and no surviving owned group. These are completed-run receipt observations, not a new live process inspection.

The live acquisition snapshot and accepted callback event agree on PID/start ticks, executable, argv, and exact copied-project cwd. The guard's statically inspected checks bind native context, executable hash, ancestor runner identity, critical inputs, device/project identity, and absence of `OPAE_PLATFORM_GEN`; the TCL callback clears `LD_LIBRARY_PATH` only for its Python invocation. `ready_for_build=false` and STA-only scope are not hardware readiness.

`STA:2506–2527` identifies Quartus **25.1.0 Build 129**, Agilex 7 **AGFB027R25A2E2V**, revision `ofs_pr_afu`, **final** snapshot and final/sign-off delay models. The prerequisite-captured executable binding is `/opt/altera/25.1/quartus/linux64/quartus_sta`, SHA256 `979845fbc25bad3fb1aa72d26fa5a18337834a3a31d7113fef9328d40f21c91b`. Both captured STA tool bindings match the runner literals. The wrapper SHA is `222fa669a9b10a6d443268fdc506e885597b5867e77bbf13ff656b8a272933dd`.

Fit is used strictly as a prerequisite, not re-reviewed for all fitter findings here. Its frozen archive SHA256 is `f33d14f057fb0b5d9351eb0b5a6d9a375cf003a25e25e8c39d1a4f09e9e6d5ee`; native/effective result is 0/0 with complete/success true and no timeout/survivors. `artifacts-fit01/fitting.log:677,680` records successful final-database commit and fitter success. All **722** recorded fit QDB outputs match the later prerequisite inventory. The separate fit-only reviewer retains ownership of fitter acceptance; this report does not relabel its frozen pending status.

Accepted setup/mapped-synthesis scope remains separate (`SYNTH-ACCEPTANCE.md`). Static literal comparisons found identical **13 AFU source payloads**, **255 generated bindings**, and requested JSON policy across setup/synthesis/fit/STA. Every embedded AFU source payload hash verifies. `afu/csr_mgr.sv` is byte-identical to the frozen candidate `../dma-csr-timing01/csr_mgr-candidate01.sv`, SHA256 `42d09ffffb91152b9f688014bcff9ffc13e5382cddd7f478e5f9b992da232a77`.

### 1.2 Copied inputs, output roles, and preservation — PASS within receipt scope

- Reconstructed `run-sta01.py` exactly from `run-sta01.py.in` and its AST-extracted literal configuration, without execution. Its hash agrees with `dispatch-sta01.json.embedded_runner_sha256`. The outer transport-script hash remains receipt metadata; an absent transport wrapper body is not independently reconstructed here.
- The **5,503-entry** completed-fit persona inventory agrees exactly among prerequisite capture, runner configuration, and `original_setup_inventory`.
- Independently rebuilt the complete **5,749-entry** critical-input hash dictionary, including the copied persona after role exclusions, changed QSF, AFU/generated source bindings, JSON/source list, and two new gate files. It equals the archive dictionary, not merely its count.
- Exactly **26 mutable-output paths** agree among configuration, `sta-input-roles01.json`, result exclusions, and post-run output records. They are explicit flow/SDC report products, report databases, timing/cache products, and the exact native `legacy/1/runlog.db`; there is no broad QDB exemption. All 26 have post-run records; **9** changed hashes. This does not assert that every cache changed or that the current runlog bytes were independently decoded as SQLite.
- All **344 protected physical/synthesis paths** are disjoint from those roles, remain critical bindings, and match original inventory and post-STA QDB hashes: **277 final**, **34 partitioned**, **33 synthesized** paths. Imported `ofs_top.qdb` is separately critical-bound with SHA256 `7f8f25463afe3ae95d9660ddf4c5c6755d6704f828fd400de34ae38fa2aa0fc8`.
- Original fit persona, **4,936-entry** release inventory, tools, and critical inputs all have true postflight preservation flags with no exception. The release inventory matches the fit configuration; its 92 tool bindings are unchanged and prior Quartus bindings are preserved. Remote originals not exported as file bodies are verified through the hash-bound runner's before/after checks and receipts, not falsely claimed as independently re-read from this workstation.

The exact copied-QSF delta is limited to two callback references (`fit01` to `sta01`) and `NUM_PARALLEL_PROCESSORS 2` to `36`. Captured pre-QSF equals the fit QSF; post-QSF equals precisely those replacements. QPF is unchanged. No SDC, RTL/fitted logic, or requested clock-policy edit is part of this stage. The seven prerequisite payloads, including the selected SDC and report hooks, have valid hashes matching their inventory bindings.

The original preceding negative STA's **0/0/125**, false bound-input flag, and separately accepted runlog-only disposition remain historical facts (`../ahls-persona-work21-sta01/RESULT-ACCEPTANCE.md`, `NATIVE-DELTA-DISPOSITION01.md`). Current explicit runlog classification does not retroactively turn that attempt into 0/0/0 or waive arbitrary physical-database drift.

### 1.3 Resources and unchanged clock policy — PASS with explicit worker limit

The acquisition snapshot records native affinity CPUs **0–35** and both address-space limits **68,719,476,736 bytes (64 GiB)**. Runner preflight had the same complete allowed set, QSF request36, no competing native process, and passed finite memory/disk checks. The source contains a finite 10,800-second native deadline.

**Do not claim 36 effective workers.** `STA:2532–2538` reports 36 detected, **maximum allowed24**. `LOG:11`, Warning20031, additionally says parallel compilation is enabled for24 processors but there are only18 processors in the system. These are distinct native/resource observations; this review does not infer actual concurrency or silently reconcile different processor-count semantics.

Requested JSON remains **auto-200 / auto-100**; captured `user_clock_freq.txt` reports actual high200/low100. All **83 semicolon clock-table rows**, comprising title/header plus **81 clock-property data rows**, are byte-identical between current and preceding native reports (`STA` and `OLD`, table begins at2755). The table is unchanged, not just frequency cells. The EMIF0 core clock's original CSR path relationship is **3.000 ns**, not a substituted 200MHz DMA target.

The selected OFS hook runs `user_clock_freqs_compute.tcl` and then `report_timing.tcl`. Its implementation is not purely observational: it computes/writes actual clock frequencies, rereads constraints and updates timing. `LOG:3106–3129` discloses the user-high AFU clock being unused and actual200/100 retained. Frequency-selection code explicitly excludes hold/removal and has10000 advisory fallbacks for missing optional clock/slack cases; those are not measured timing passes. Separate reported hold/removal records were checked below. No increased/lowered target or fallback number is credited as closure.

## 2. Numerical summaries — independently reconciled PASS, bounded scope

Parsed every record directly from native `timing_report/clocks.sta.pass.summary` with a complete format match and Decimal comparisons. No unparsed residue remained. The result equals `sta-domain-timing-records01.json` exactly. The failed summary is genuinely zero bytes. All **645 unique (corner, metric, clock) records** match the preceding frozen dataset's exact keyset; none was dropped to obtain a pass.

Each corner has **129 records**: setup17, hold17, recovery10, removal10, minimum-pulse-width75. Across all five corners this is setup85, hold85, recovery50, removal50, MPW375. All slack values are nonnegative and all TNS values are **0.000**. Eight slack records are exactly **0.000** at report precision; claim nonnegative, not positive margin everywhere.

| Corner | Setup minimum ns | Hold minimum ns | Recovery minimum ns | Removal minimum ns | MPW minimum ns |
|---|---:|---:|---:|---:|---:|
| `2_slow_vid2_100c` | 0.191 | 0.000 | 0.278 | 0.204 | 0.000 |
| `2_slow_vid2b_100c` | 0.200 | 0.004 | 0.242 | 0.211 | 0.000 |
| `MIN_fast_vid2a_0c` | 0.661 | 0.006 | 0.674 | 0.142 | 0.000 |
| `MIN_fast_vid2a_100c` | 0.509 | 0.003 | 0.575 | 0.147 | 0.000 |
| `MIN_fast_vid2_100c` | 0.496 | 0.000 | 0.578 | 0.140 | 0.000 |

The native aggregate setup/hold/recovery/removal/MPW tables (`STA:2898,2929,2960,2984,3008`) independently agree with minima over these records, and show zero endpoint TNS/failing endpoints. The native Multicorner Timing Analysis Summary (`STA:216392` onward) agrees as well, with its slack and TNS subblocks parsed separately. Its N/A cells were preserved as N/A, not treated as passing checks.

For clock `local_mem_wrapper|mem_ss_top|mem_ss_sv|mem_ss|mem_ss|emif_0|emif_0_core_usr_clk`:

| Corner | Prior setup slack/TNS ns | Current setup slack/TNS ns |
|---|---:|---:|
| `2_slow_vid2_100c` | -0.367 / -26.907 | +0.375 / 0.000 |
| `2_slow_vid2b_100c` | -0.356 / -25.662 | +0.398 / 0.000 |

These two preceding negative **domain minima** are no longer negative in the changed build. This is not an identity-preserving before/after timing report for any particular launch/capture pair. It does not establish which newly mapped CSR path is worst, complete exception coverage, or direct old/new cone closure.

## 3. Quality findings and broader failures — retained, not waived

### Q1. Native Timing Closure PASS does not make Design Closure PASS

All four extracted panels in `sta-native-panels01.json` were checked against exact full-native line slices. `STA:2844–2866` reports:

- **Timing Closure PASS**: setup, hold, recovery, removal, MPW, max skew, net delay, metastability and DDR summary pass as native panel results.
- **Design Closure FAIL**, Design Assistant **High Severity Violations**, **Unconstrained Paths FAIL**.
- **Not Found**: Setup Data Delay, Recovery Data Delay, Max Clock Skew, TCCS and RSKM. Missing categories are not passes.

`STA:216243–216253` retains **2 unconstrained inputs / 78 pairs** and **2 unconstrained outputs / 10 pairs**, separately for setup and hold. No illegal/unconstrained clocks are reported, which does not cure unconstrained I/O. Named ports at `STA:216346–216381` are inputs `altera_reserved_tdi`, `altera_reserved_tms`, and outputs `bwbmc_bmc_irq`, `altera_reserved_tdo`. The report says relevant input/output delays or exception/skew assignments were not found. Resolve actual external JTAG/BMC timing requirements and effective constraint intent before a stronger signoff claim; no automatic false-path waiver follows from these names.

The dedicated DRC enabled-rule table (`DRC:123` onward) is cell-identical to the main STA table (`STA:216552–216644`). Independently parsed **88 rules**, **22 failed** (7High,7Medium,8Low), **zero reported waived counts**. `LOG:3096` also reports **10 disabled rules**. Zero waived is not all-checks-enabled coverage; the enabled table does not provide a complete named disabled-rule roster.

All failing rule counts remain:

- **High:** TMC-20027=19; CDC-50001=13; CDC-50004=7; RES-50001=4; CDC-50007=2; CDC-50012=2; CDC-50003=1.
- **Medium:** BBD-60000=2,496; BBD-60002=152; BBD-60001=40; TMC-20025=32; TMC-20026=31; RDC-50003=5; LNT-30023=2.
- **Low:** CDC-50101=45; FLP-40006=35; RES-50101=20; CDC-50008=16; CDC-50102=8; LNT-30010=7; TMC-20604=3; TMC-20603=1.

Thousands separators were parsed as counts, not skipped. High findings include concrete reset/control transfers between system/CSR clocks, protocol-checker state, FLR state, and PCIe FIFO synchronization (`DRC:254–270`), not merely generic warning prose. Constraint/CDC/reset/PR findings remain open even where numerical summaries pass. Preserve inherited message suppressions and earlier synthesis scope limitations; this review adds none and certifies no universal unsuppressed coverage.

### Q2. All 380 native warnings reconciled; unresolved risk remains

Reparsed every Warning/Critical Warning occurrence from LOG and matched all380 ledger entries exactly, including original line, severity, ID and text. The native footer independently reports **0errors/380warnings**. Repeated warning occurrences are retained rather than deduplicated into the native total.

| ID | Occurrences | Classification and smallest disposition |
|---|---:|---|
| 20031 | 1 | Resource-report discrepancy/limitation: LOG11's24-enabled/18-system statement coexists with affinity36 and native maximum24. No36-effective-worker claim. No unchanged rerun is needed for accounting. |
| 20727 | 1 Critical | Potential PR boundary risk: unused PR/reserved-core inputs (LOG40). Retain the separate fit review's exact port/partition disposition; this does not qualify quiescence or runtime PR. |
| 18502 | 17 | Explicit current-versus-base SDC assignment differences (LOG45–61), including PR/user clocks and PIM constraints. Separate PR assignment sets are source-visible; effective coverage is not thereby harmless. Reconcile exact constraint ownership/collections before signoff. |
| 332174 | 80 | Ignored unmatched clock filters,40 distinct texts, LOG85–3394. Captured SDC886–887 includes alternate PCIe clock-name filters. Classify per actual selected instance; do not declare all ignored filters inactive. |
| 332054 | 163 | Accepted-but-problematic constraints,122 distinct texts, LOG86–3631. Includes10 clock-group,24 output-delay,58 create-clock,12 input-delay and59 generated-clock occurrences. Inspect exact objects/override semantics rather than treating acceptance as effective application. |
| 332049 | 116 | Ignored constraints,58 distinct texts, LOG113–3622. Captured SDC1673 onward still targets `ahls_binding|board|banks[...]` FIFO selectors while this persona has different current hierarchy. Reconcile effective current FIFO/CDC/skew coverage, not blind string replacement or an assumption that all active coverage is absent. |
| 332158 | 1 | Tool-model qualification limitation: Agilex7 clock uncertainty characteristics preliminary (LOG414), despite the native final delay-model panel. Preserve both observations. |
| 21620 | 1 | Confirmed native signoff failure:7 of34 High rules report violations (LOG3097), consistent with DRC enabled results. Open design-risk evidence, not a waived advisory. |

The total is380 across8IDs;20727 is the sole Critical Warning occurrence in this STA log. Numerical domain pass, same clocks and empty failed-domain output cannot disposition these classes. Warning triage here is STA-specific; it does not duplicate or consume the separate fitter review.

### Q3. Direct CSR cone query is missing — required before path-specific closure

Confirmed by scanning the complete native STA report: **zero literal `src_last_q`, zero `dst_last_q`, and zero `csr_mgr_inst` occurrences**. This is a report-coverage limitation, not evidence that endpoint logic vanished. The selected captured `report_timing.tcl` emits domain summaries for all available corners, but detailed domain timing reports only when slack is negative. Its `report_timing ... -show_routing -npaths20` branch is not taken for passing domains. Main default reporting likewise supplies no direct CSR path detail here.

There is useful source/mapping evidence for a much smaller next query:

1. Frozen source lines103–124 compute unsigned65-bit inclusive endpoints from committed address/length;125–176 consumes them in descriptor admission;179–191 handles freshness;379–387 captures write response;402–428 qualifies descriptor/control updates with the admission result. This is the intended arithmetic → endpoint-register → admission/register-enable split, not a full mapped-equivalence proof.
2. `SYN:39836–39837` explicitly merges `src_last_q[58..62,64]` into `src_last_q[63]`, and `dst_last_q[58..63]` into `dst_last_q[64]`, under the exact CSR hierarchy below. Thus demanding130 distinct physical endpoint flops is wrong.
3. `FIT:838` records an actual routability duplicate `dst_last_q[34]~DUPLICATE`. `FIT:820–837` also records descriptor-address/length duplicates, including `length[0]`, `length[14]`;839–841 includes response/valid/freshness duplicates. A synthesis-name-only query can miss physical copies.
4. `OLD:158172–158181` retains10 original failing summary rows representing6 unique launch/capture pairs. Launch is `dma_csr_map.descriptor.length[14]~ENA_dff`; targets are `length[0]`, `length[0]~DUPLICATE`, `length[17]`, `length[19]`, `length[3]~DUPLICATE`, `length[5]~DUPLICATE`, each prefixed as below. Both clocks are EMIF0 core, relationship3.000ns. Their exact current mapped identity is not established by the new domain minima.

#### Smallest source-bound next query — recommendation only, NOT EXECUTED

Use one separately authorized finite native query on an exact copy of the already completed **final** snapshot, retaining the current source/SDC, auto200/100 policy, clock table, physical-input bindings and resource rules. Do not rerun synthesis/fit or unchanged blanket STA. Do not reuse the spent STA-only guard/argv authorization for a new `-t` command. Bind the proposed query's installed Quartus25.1 API/options and its separate context before execution; this report is a target/coverage specification, not executable authority.

Exact hierarchy prefix:

```text
H = afu_top|pg_afu.port_gasket|pr_slot|afu_main|port_afu_instances|ofs_plat_afu|core|dma|csr_mgr_inst|
```

First enumerate and record actual final-netlist register/pin names **only below H**, then map the following source families to physical representatives, including retained `~ENA_dff`, `~DUPLICATE` and other proven aliases. Treat brackets literally when matching names; do not let Tcl substitution or wildcard syntax silently change bit selectors. Return collection sizes and the full selected name list. An empty/multiple unexpected match is an unresolved mapping result, never a timing pass.

| Query family | Source-bound launches | Source-bound captures / required coverage |
|---|---|---|
| Original feedback/admission | Exact old `H + dma_csr_map.descriptor.length[14]~ENA_dff`; if absent, establish its current source-to-final counterpart rather than substituting a similarly named object | The six old capture names above and their proven current physical representatives. Include admission-driven register-enable arcs, not just payload D paths. |
| New arithmetic → endpoint | Mapped `H + dma_csr_map.descriptor.src_addr`, `.dest_addr`, `.length` register bits and physical copies | All resolved `H + src_last_q` / `dst_last_q` bits/representatives. Include high-bit merge representatives `src_last_q[63]`, `dst_last_q[64]`, and known `dst_last_q[34]~DUPLICATE`; account explicitly for each source bit merged/constant/renamed. |
| Endpoint → admission | All resolved endpoint representatives/copies | Actual admission-fed `dma_csr_map.descriptor` and `dma_csr_map.control` register data/enable captures, `mmio64_reg.b.resp`, and source-reachable freshness captures. Derive the final capture set from the source use/physical fanout, not from the name `write_value_ok` alone. |

For each of the same five available corners, update the timing netlist under unchanged constraints and obtain worst **setup and hold** timing for each selected capture/family, with explicit `-from`/`-to` collections, routing/path detail and launch/capture clocks. At least one worst path per selected capture is needed; a single top20 domain report is not evidence that every selected family/capture was covered. Retain the exact old six-pair outcomes separately. Report slack/TNS where available, clock relationship, physical launch/capture and endpoint pin/enable, and any exception, no-path, unconstrained or empty-collection outcome. If a requested old path is optimized away, record the demonstrated mapping and current source-equivalent cone; absence alone is not resolution. No false-path/multicycle or frequency change is proposed.

This is the smallest missing discriminator: use the accepted final database to test original feedback plus **both sides** of the introduced pipeline. A pipeline can relocate a violation; domain pass cannot substitute for this direct check. Complete constraint/reset/CDC signoff remains separate even after that query.

## 4. Final disposition and exclusions

The reviewed evidence supports **successful completed final multicorner acquisition** and **645/645 nonnegative reported constrained-domain records**, with exact identity, preservation, counts and clock-policy reconciliation. No frozen evidence discrepancy blocks that bounded acceptance.

Carry Q1–Q3 forward. Do **not** claim exact original-path closure, all-path timing closure, full Design Closure, reset/CDC/exception coverage, mapped-system functional equivalence, vendor-DDR simulation, physical DDR/PCIe/OPAE operation, hardware access, PR/reset safety, assembly/GBS, deployment or workstation recovery. A native DDR-summary pass is neither vendor-DDR simulation nor a physical memory data test. Vendor DDR simulation remains **SKIPPED BY USER**. The parent alone owns subsequent workstation activity and acceptance transitions.

**FINAL: SPEC PASS / QUALITY PASS WITH FINDINGS / bounded acquisition-and-domain-summary ACCEPT WITH FINDINGS. Direct CSR cone check OPEN; native Design Closure FAIL; full signoff NOT ACCEPTED.**

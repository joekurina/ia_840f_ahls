# Experiment04 report acquisition and cap accounting

**Design only. Acquire the required reports directly to complete ASCII files, with explicit finite limits; interpret their actual tables offline. Do not require another selector diagnostic, help batch, or a guessed panel schema before acquisition.** Native rc0, successful report acquisition, completeness acceptance, and numerical timing acceptance are separate outcomes. `ready_for_build=false`; all native/package/hardware gates remain closed. No authorization is supplied here.

## Sources and scope

Paths below are local; citations are 1-based lines. `N=/home/joe/Projects/Thesis/AHLS/new_bsp/new`; `R=N/qualification/pcie-clock-repair-01`; `Z=R/experiment04`; `H=R/api-help01/commands`; `STA=N/qualification/fim-build-14/reports11/output_files/ofs_top.sta.rpt`; `DRC=N/qualification/fim-build-14/reports13/output_files/ofs_top.tq.drc.signoff.rpt`.

The governing requirements are `R/native-mapping-disposition03.md:98–123`. The query is still components, not an assembled acquisition stage (`Z/QUERY-REPORTING03.md:21–23`; `Z/QUERY-STAGES02.md:19–21`). Experiment03 produced **no downstream reports**; its authored schema is not native evidence (`R/experiment03/baseline/RESULT-ACCEPTANCE.md:3–7`). This design leaves the parent's member/clock associations and finite query scheduling intact.

## 1. What the saved native reports actually establish

Counts below were computed from complete local table rows, excluding titles, headers and borders—not search-result excerpts.

| Native evidence | Exact schema/count and consequence |
|---|---|
| `STA:2881–2957`, **Minimum Pulse Width Summary** | Header at :2883: `Clock; Slack; End Point TNS; Failing End Points; Type; Worst-Case Operating Conditions`. **73 domain-summary rows**, :2885–2957; type distribution 51 `High Pulse`, 19 `Low Pulse`, 3 `Min Period`. These are neither individual check counts nor complete per-corner checks. Example :2885: `altera_int_osc_clk; 0.000; 0.000; 0; Min Period; Slow vid2 100C Model`. |
| **Max Skew Summary** plus corner, `STA:2968,3070,3172,3274,3376` | Exact suffixes: `Slow vid2 100C Model`, `Slow vid2b 100C Model`, `Fast vid2a 0C Model`, `Fast vid2a 100C Model`, `Fast vid2 100C Model`. Header at :2970 (same columns in each): `Name; Slack; Required Skew; Actual Skew; From Node; To Node; Launch Clock; Latch Clock; Options; SDC Location`. **94 assignment-summary rows per corner**, ranges :2972–3065, :3074–3167, :3176–3269, :3278–3371, :3380–3473. No latest/earliest result-count column. Launch/latch fields are blank in these rows; selectors are not resolved endpoint inventories. |
| `STA:2972–2973` | Both report `set_max_skew; 1.158; 1.701; 0.543` on the same FIFO selectors, but locations differ: `../../../shared_config/fim_dcfifo.sdc:21` versus `../../../../ipss/pcie/qip/pcie_ss/intel_pcie_ss_axi_500/synth/pcie_ss.sdc:629`. **Do not merge assignments by selector or numerical equality**, or interpret these as the two arrival directions. |
| `STA:3478–3627`, **Net Delay Summary** | Header :3480: `Name; Slack; Required; Actual; From; To; Type; SDC Location; Worst-Case Operating Conditions`. **146 assignment-summary rows**, :3482–3627. Exactly **eight** at :3620–3627 have `Slack=Invalid clock`, `Required=--`, `Actual=Invalid clock`, `Type=max`, blank corner. These are assignments, not eight matching edges. |
| `DRC:4448–4577`, **TMC-20025 - Ignored or Overridden Constraints** | :4450 declares `Number of violations: 120`; :4451 has `max_violations = 5000`. Header :4455: `Ignored Constraint; Location; Reason; Waived`. Exactly **120 rows**, :4457–4576, reconcile the declared total. :4457 says `Exception is invalid (covers no paths)`; :4458 says `Exception is fully overridden`; :4528–4531 retain the four integration multicycles with errors. This is a DRC violations table—not `report_exceptions` path detail or a complete exception inventory. Its 5000 rule limit is unrelated to experiment04's 20001 sentinel. |

No native `report_exceptions -detail path_summary` table, latest/earliest **detailed skew** layout, or individual **MPW check** layout was found in the examined Work14/repair evidence. Searches were broadened to native logs/reports and case-insensitive exception statuses; the additional hit was the DRC table above, not the missing format. Thus their future exact child titles/column names and zero-result encodings remain **unobserved**. The saved API documents semantics, not those concrete layouts. This does not block a bounded, lossless first acquisition inside the future reviewed A/B.

## 2. Smallest acquisition contract

For **each side and each enabled corner**, after the parent's explicit corner selection/update, give each scheduled query a unique file and record side, actual corner, analysis type, exact options and scope identities. Use `.txt` ASCII output, not HTML, no append and no stdout duplication. Retain every byte, including headings, assignment metadata, statuses, warnings, path/check tables and trailing text. A log receipt should retain command start/end, Tcl completion code and **raw** result; process return code remains separate. Check and preserve errors rather than converting them to empty reports.

The following are **command forms for later authoring, not executed commands**. Scope options/targets come from already validated collections and the parent's predeclared schedule; they are not new guessed selectors.

| Required report | Minimal form / limit |
|---|---|
| Global and affected exceptions | `report_exceptions -report_clock_groups -<setup\|hold\|recovery\|removal> -num_exceptions 20001 -npaths 20001 -pairs_only -detail path_summary -file <unique.txt>`, plus the scheduled scope/clock-edge filters for affected queries. Each analysis flag is a separate call. The global call has no endpoint restriction. Do not add `-valid`, slack filtering or an exception-type filter that would hide statuses/types. |
| Skew, once per corner | `report_max_skew -npaths 20001 -detail full_path -file <unique.txt>`. This command covers all assignments; its saved grammar has **no** `-from`, `-to`, per-assignment selector or `-pairs_only`. Do not invent them. |
| Affected MPW | `report_min_pulse_width -type all -nworst 20001 -detail full_path -file <unique.txt> <targets>`. Cover both the conservative node scope and C/other actually changed clocks; retain overlap provenance rather than summing duplicate checks across queries. |
| Net delay, once per corner | `report_net_delay -file <unique.txt>`, deliberately **without `-nworst`**. This documented operation emits matching edges for each assignment, not every combinational route. |

Support: `H/report_exceptions.txt:3,27–39,95–135,158–185`; `H/report_max_skew.txt:3,13,28–59,61–72`; `H/report_min_pulse_width.txt:3,12–18,30–58`; `H/report_net_delay.txt:3,11,26–37`. File output and combined file/panel output are documented; `-split_by_corner` has **no effect on files**, so it cannot replace explicit corner scheduling (`H/report_exceptions.txt:39`; `H/report_min_pulse_width.txt:15`; `H/report_net_delay.txt:13`). `full_path` retains clock context without adding detailed routing.

Use the global exception path-summary report itself for its exception inventory when that inventory is present; no preliminary summary-only probe is necessary. Reconcile against the already-required `report_sdc` and `report_sdc -ignored` outputs, which supply used constraints and ignored reasons (`H/report_sdc.txt:3,11,25–27`). If an errored/ignored record is absent from the default exception output, it remains explicitly accounted for by ignored-SDC evidence; never manufacture a path group or silently declare it valid. Clock groups may be expanded into clock-to-clock exceptions, so one SDC command is not necessarily one reported exception (`H/report_exceptions.txt:196–200`).

`-pairs_only` deliberately requests bounded endpoint-pair coverage, not all routed paths. The global call does not replace the parent's affected launch/latch-clock/edge partitions: collapsing pairs can hide distinct clock cases (`R/native-mapping-disposition03.md:90–96`). For absent baseline C, preserve the baseline no-clock/structural accounting; do not invent a C collection or call an API failure a zero-path report.

**No unbounded path setting:** no exception `-npaths 0`, no skew `-npaths 0`, no alleged MPW `-nworst 0` unlimited mode. No automatic cap increase, partition refinement or retry after saturation. Keep 256 clocks, 4096 affected nodes (including unions), 4096 adjacent nodes per source, 50000 adjacency records and 16 corners; per-file128MiB, total-report1GiB, address-space64GiB, wall1800s (`R/native-mapping-disposition03.md:121`; `R/experiment03/SPEC.md:24–26`). Apply byte/time bounds during acquisition, not just after completion. All raw files, optional panel dumps and logs share the existing budget. Resource failure preserves partial evidence and fails acquisition/comparison; it does not authorize another run.

### Panel getters are optional transport, not a count oracle

Direct `-file` is the minimum and avoids needing an unobserved panel hierarchy. If the parent also wants structured rows, add a unique `-panel_name` to the **same** report invocation—not a redundant native report. Discover the exact resulting root/descendants with `get_report_panel_names`, retain full names, resolve actual IDs, and export every row of every table, preserving row indices and empty cells. Do not capture only the root summary or a first matching panel.

`get_number_of_rows -id` is a **table row count**, not an exception/path/check count; its example iterates indices from zero to less than that count (`H/get_number_of_rows.txt:22,48–63`). `get_report_panel_row` returns the row (`H/get_report_panel_row.txt:24–32,67–70`). Derive data/header/metadata roles from the actual native schema; never blindly subtract one from every panel or reject a whole multi-group/full-path panel at 20001 physical rows. Path point rows and aggregate summaries are not additional logical checks.

Use exact full names, not shortened TOC names (`H/get_report_panel_names.txt:21–31`); missing ID is `-1`, and cached IDs become invalid on reload (`H/get_report_panel_id.txt:21–36`). Folder/non-table access can error (`H/get_number_of_rows.txt:79`); record that distinction without silently dropping an unknown table. `get_report_panel_data` errors for **empty data as well as missing data** (`H/get_report_panel_data.txt:26–30`), so per-cell probes cannot establish emptiness/completeness. Do not reload a stored compilation report and assume it contains the just-created live reports. Raw ASCII remains the independent retained evidence if optional structured export is unavailable.

## 3. Completeness checks on the retained result

These are semantic counters, established from actual native group boundaries/rows—not invented API return meanings. Preserve raw ordinal/identity and source location, selectors, options, corner and analysis type. Repeated source lines from generated loops are not unique assignment IDs; retain instantiated selectors and occurrence distinctions.

### Exceptions: two independent sentinels

1. For **each query**, count actual reported exceptions, independently of path rows. Record/flush count and `num_exceptions=20001` before any rejection; **count ≥20001 fails completeness**. Reconcile reported exception identities/statuses with global and ignored-SDC inventories, including clock-group expansion, applicability and overridden cases. Any native declared total must reconcile; an unaccounted exception fails even below the cap.
2. For **each exception in each required scope/analysis/corner/edge partition**, count its returned logical path-summary records. Record/flush each count against `npaths=20001`; **any count ≥20001 fails**, regardless of aggregate count or slack. Do not apply this sentinel to all exceptions' combined rows. There is no independently supported path-count return for `report_exceptions` (`H/report_exceptions.txt:256–262`).
3. Preserve status literally: `Complete`, `Partially overridden`, `Fully overridden`, `Invalid`, and `Paths will not be analyzed`; preserve ignored/error reasons as well. A restricted `Complete` means only complete relative to that scope. An explicit invalid/no-path or other-analysis status can explain zero path rows, but zero rows with missing identity/status or an unexplained disappearance cannot (`H/report_exceptions.txt:61–96`). A false-path report analyzes as though the cut were absent; numerical slack is not active timing coverage (:183–185).

The help's default one path, or an intentionally retained global `-detail summary -npaths 1` report, is a **sample**, not a saturated exhaustive query. It may support status/worst-slack inventory only; it cannot satisfy the per-exception path obligation. `-num_exceptions` is a separate output bound; `-nworst` would impose another endpoint sample limit and is deliberately omitted (:116–135,158–170).

### Skew: each assignment, each arrival direction

For every `set_max_skew` assignment and corner, bind the actual detailed results to the assignment and count the **latest-arrival** and **earliest-arrival** result groups separately. Record both counts; either reaching20001, an unexplained absent group, or an unmatched assignment fails completeness. Preserve paired reference-path identities and clock context. Do not count both witness paths, clock/data point rows or repeated summary displays as separate skew results. The source definition compares each path against another path and never itself (`H/report_max_skew.txt:28–43`).

The documented two-element result is **number of paths found in the analysis, worst slack** (:80–83). Retain it, but do not reinterpret its first element as number of assignments, count per arrival direction, total uncapped population or a saturation flag. Its aggregate may exceed20001 without any individual group saturating. Conversely, aggregate rc0/small count cannot establish every group's completeness. Default `-npaths 1` is one worst result pair per assignment, not an exhaustive report (:13,52–59). The saved 94-row summary tables establish assignment-level evidence only; their blanks cannot supply missing clocks or latest/earliest counts.

### MPW: checks, not domains or unique nodes

For each MPW query/corner, count **every returned logical check**, across all types together, and reject count ≥20001. Also retain per-type and node/clock identities for coverage reconciliation. The one `-type all` limit is not permission for20001 of each type. Do not deduplicate High versus Low or omit minimum-period checks. Nodes other than registers/latches can have pulse-collapse checks; registers/latches additionally have minimum-period checks (`H/report_min_pulse_width.txt:30–44`). Reconcile conservative members and C/changed-clock results with the parent's actual associations, preserving explicit no-clock/nonapplicability reasons and unexplained missing checks. Do not assume every member has exactly three checks.

The saved native **domain summary** uses `High Pulse`, `Low Pulse`, `Min Period`; API prose describes check kinds `High`, `Low`, `Period`. Preserve the actual future detail labels before mapping them—neither is proof of an unseen detail header. MPW help supplies no numerical count-return contract (:84–92). Old worst20/global summaries remain labeled samples, never affected completeness evidence (`R/native-mapping-disposition03.md:119–120`).

### Net delay and the eight assignments

Keep the source-supported no-`-nworst` acquisition. For each assignment reconcile all returned matching-edge rows, exact endpoint identities and numerical Required/Actual/Slack with the assignment inventory; this is not a path-sentinel workaround. The eight invalid baseline rows at `STA:3620–3627` must remain traceable and become numerical in B at every applicable corner, not disappear. Retain matched sets, clocks/periods and provenance; verify destination-period-derived net-delay and source-period-derived pointer-skew bounds as required by `R/native-mapping-disposition03.md:104–115`. Summary row count146 does not prove edge completeness. Additional changed FIFO assignments remain in scope; do not restrict the global native reports to these eight.

## 4. Acceptance boundary when a detailed format is new

A successful bounded native command with its complete file/receipt is **acquired, interpretation pending**, not `complete=true`. Retain the whole new layout first. Offline interpretation must identify every assignment/exception/check group, headers, records, no-result statuses and any totals/truncation indications, then reconcile all counters above. Unknown schema, ambiguous group ownership, unparsed rows, mismatched totals, a missing expected group or any cap hit leaves completeness **false/unresolved**. Do not repair that uncertainty by treating the command result as a count or assuming a header-only report means zero.

This permits useful first-result acquisition without a preliminary diagnostics run. It does not waive the parent's baseline-before-B gate or authorize either side. If the retained bytes resolve the schema, interpret those same bytes—no native rerun is needed. If information is genuinely absent, report the exact missing assignment/check scope; do not launch a generic selector/help follow-up. Negative numerical slack, even with complete reports, remains a separate timing failure. No build, promotion, CDC/DRC waiver or hardware action follows.

## 5. Work performed and source bindings

Only this Markdown file was created. Local saved help/report reads, table counts and SHA256 calculations were performed; no implementation, fixture replay, vendor/native/help invocation, remote/hardware access or git operation occurred. The missing detailed native layouts are the identified interpretation limitation, not a fabricated result or a prerequisite for another standalone diagnostic. SHA256 values below were computed from the local source bytes.

| Source | SHA256 |
|---|---|
| `R/native-mapping-disposition03.md` | `dd00b40ba78960c51d0ac875ad8619f75af3a65d980cf7bac7d34283be6181b7` |
| `Z/QUERY-REPORTING03.md` | `c17f4ef1269efeadfb145460d60211a4170699681456dc6a6de89444f5a8242a` |
| `Z/QUERY-STAGES02.md` | `8595f266847d4cdee31815b2f30461abd1c82f0f46dc958a95de5630715972e5` |
| `R/experiment03/SPEC.md` | `bfeea5337982945c4d5d0cfd0133307a8167d6607cc8ae28516c02ce650599ff` |
| `R/experiment03/baseline/RESULT-ACCEPTANCE.md` | `51091902df286ccc87e2f6e6fb643977de087ad280190759d36705f3c5f56225` |
| `STA` | `8c51a45bcff167fb80feb39a9338c62691401d0fa7be36d7a2caa0d94969c5e6` |
| `DRC` | `5e9a16353d01da508f057bdd04d40a830b664f15b5516541accea4bc3f8e705e` |
| `H/report_exceptions.txt` | `740db7ea29c4766fcd56dab6e1d4ab44d8e7072408abdc39dc33cbfbfc1e2974` |
| `H/report_max_skew.txt` | `fc5b4c397f637b511284f654630a07454ecb8f7a1cf37136bfe2350907b9006b` |
| `H/report_min_pulse_width.txt` | `011791d8b14e110aea6d880fc1506d2b4fd0cf25b0b2b119898d9de760ba0524` |
| `H/report_net_delay.txt` | `2a71a56c22d482516eed89615513dc4a9a4433005429db1ad412b47791b9d4e7` |
| `H/report_sdc.txt` | `f75e1fe524dfe7e0ec4e0da7f5665fae0e4d256bf359b24db4ec4f96ec857bd6` |
| `H/get_report_panel_names.txt` | `ea5c5397847480155531f44aaff377570500b5542f5d59fc56408490148709d2` |
| `H/get_report_panel_id.txt` | `d76041d4e81a65d28b87a43f9303c1a574f2a12f61de8262ff9a010469c2f203` |
| `H/get_number_of_rows.txt` | `ba0cbc3aa824db6fa0d5203d1efed33c4318e36b56d4901fbd34b3e6e3ab7a6b` |
| `H/get_report_panel_row.txt` | `5438b3c4cbec2329076842ee7725582ee7efdef0fc2da50ab2499a78b32aa4e1` |
| `H/get_report_panel_data.txt` | `2056721750a2459fbf487a53b622aa836a09e74a19707ff98842b29791d62bc9` |

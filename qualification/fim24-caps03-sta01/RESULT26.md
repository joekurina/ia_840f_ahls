# Matching persona final STA — completed, result review pending

## Actual execution

One admitted final-snapshot multicorner STA completed in owned tmux `@304/%304`. Native version/timing, CMake/effective and outer statuses are zero; all owned command groups drained. The admitted runner interval is `2026-10-02T18:45:18.119732Z` to `18:46:57.549876Z` (99.430144 s, including configure/version/postflight). The live native witness is PID358538/start51582736 with exact 26.1.1 executable SHA `d675f96e7dffe1f7c736dfe2a20e1d3f4e576a5a53f714a644d2082c00fd4fae`, admitted argv/cwd and accepted callback; runner PID358489/start51581526. This is not a refit or hardware operation. [Dispatch20](sta20-dispatch.json), [observation21](observation21-collection.json), [raw result](completion24-readback/operation/result.json), [completion event](sta20-completion-event.json).

QUALITY18 was consumed after114/114 and69/69 SOURCE reverification. Issuer19 wrote/read back the exact manifest and passed live non-consuming preflight; packet1,657,040bytes was below2MiB. Admission `df665c0f2656fa6343d78c79637c04ee6b53c8b5155b417a983e37292eeaf9d1` is now **spent**, never replayable. Raw result SHA `45f6185771f6538548faaa2916c597cde5bb529c0ddd06ff5446e2dd1512a07d`. [Consumption19](quality-consumed19.json), [rendering19](issuer-rendering19.json), [admission collection](admission19-collection.json).

## Acquisition and preservation

All54 captured members (70,744,266 bytes) verified against remote sizes/hashes, including all seven primary STA outputs. Only the zero-byte failure summary is allowed empty; no rejection file exists. Fifteen capture preservation checks pass, including4001 critical inputs,280 protected physical/static members, original fitted/mapped full entry sets and bytes, external/setup/release/archive/tools/controls/five predecessor results. QPF is byte-identical. Of26 admitted runtime outputs,17 are unchanged and9 changed, none removed. The post-STA QDB inventory has733 files/394,551,887bytes; its four additional members are not a new physical implementation. No matching owned native processes remained at capture. [Index24](completion-index24.json), [verification25](native-result-verification25.json), [role deltas25](runtime-output-deltas25.json).

## Initial numerical result — PASS, not full coverage acceptance

The same reviewed complete-record parser was recomputed from captured raw bodies and exactly reproduces the native runner result. Every Type/line is accounted for; every reported slack is finite/nonnegative and every applicable TNS is exactly zero. There are no invalid records, violations, duplicate domains or unresolved population differences in this screen. Native totals are923 records:127 clock/family aggregates,650 Max Skew and146 Net Delay. The hook has635 passing records across the five observed corners and zero failing records. These are overlapping reporting views, not1,558 distinct physical paths. [Verification25](native-result-verification25.json), [summaries](completion24-readback/reports/ofs_pr_afu.sta.summary), [hook](completion24-readback/reports/clocks.sta.pass.summary).

| Family | Native records | Minimum reported slack (ns) |
|---|---:|---:|
| Setup |17|0.002|
| Hold |17|0.000|
| Recovery |10|0.232|
| Removal |10|0.109|
| Minimum Pulse Width |73|0.000|
| Max Skew |650|1.178|
| Net Delay |146|1.012|

Zero hold/MPW is nonnegative, not positive margin; the2ps setup result is retained without tolerance or requirement changes. All81 named clocks have Constrained status. The actual bank0 application clock is3.000ns at native report line2784. Its five families are present in all five hook corners. Native path summaries at lines158135/158274/158413/158552 show the actual `map_banks[1].output_bank.shim` ready-to-`completion|accepted_bytes` setup paths at0.002ns, with3.000ns setup relationship and **No SDC Exception on Path**. This corroborates real application endpoint propagation, not exhaustive endpoint coverage. [Panels25](report-panels25.json), [selected paths26](selected-path-evidence26.json), [native report](completion24-readback/reports/ofs_pr_afu.sta.rpt).

The static/current clock name sets are equal(81), but do not claim byte-identical clock tables: the two user-PLL outputs are analyzed at200/100MHz instead of static312.5/156.25MHz, matching current low100/high200 metadata and unchanged auto requests. Other recorded differences are printed Frequency fields with unchanged periods/other table fields. The bank0 application3.000ns is unchanged and is not either user-clock output. This is reported analysis configuration, not a hardware frequency measurement. [Clock comparison26](clock-comparison26.json), [frequency output](completion24-readback/reports/user_clock_freq.txt), [source contract07](timing-coverage-review07.md#L30-L44).

## Findings that numerical success does not waive

- Native footer:0 errors/379 warnings, reconciled as378 Warning plusone Critical20727. Codes:20031(1),20727(1),18502(17),332174(80),332049(116),332054(163),21620(1). Native says24 processors versus18 physical;36-CPU affinity/request is not a claim of36 workers. [Diagnostics25](diagnostics25.json), [log](completion24-readback/operation/timing.log#L3675).
- Actual Signoff Design Assistant ran:23 of88 rules failed, including7 of34 High severity rules. This is current STA evidence, distinct from the earlier unperformed Finalize DA. No rule or violation is waived by this document. [Signoff report](completion24-readback/reports/ofs_pr_afu.tq.drc.signoff.rpt), [parsed88-rule table](report-panels25.json).
- Unconstrained summary has0 illegal/0 unconstrained clocks, but two input ports(`altera_reserved_tdi/tms`) and two output ports(`altera_reserved_tdo`, `bwbmc_bmc_irq`),78 input-path pairs and10 output-path pairs in both setup/hold views. They match the named standing posture; current path/exception/CDC applicability still requires result review. [Native report](completion24-readback/reports/ofs_pr_afu.sta.rpt#L216255-L216396).
- Review current `primary_axi`/`map_banks` CDC, pointer skew/net-delay and effective exceptions/empty collections, current synchronizer/reset/PR boundary dispositions, and the retained physical assignment findings. Summary labels do not prove endpoint coverage. The limited selected-path extraction finds no EMIF1bit243 Path Summary; it does not reinterpret missing selected detail as absence/failure of the preserved static transfer. Work24 physical acceptance remains a separate bound predecessor.
- Preserve **additional** reset cycles3sys/7bank0, four electrical omissions and protocol/entry requirements from accepted FIT. Successful numerical STA neither proves reset sequencing nor authorizes assembly, deployment or hardware. [FIT acceptance](../fim24-caps03-physical01/FIT-ACCEPTANCE38.md), [diagnostic/reset review](../fim24-caps03-physical01/fit-diagnostic-reset-review35.md).

**Status:** `execution_clean=true`, initial `numeric_screen_pass=true`, `timing_accepted=false` pending independent actual-result/coverage/diagnostic review. No source/SDC/RTL requirement was relaxed. No native retry, assembly, conversion, programming or hardware test occurred. Migration remains incomplete.

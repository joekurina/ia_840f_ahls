# Actual STA result review28

**ACCEPT WITH FINDINGS — acquisition, runtime and numerical-record integrity only.** No blocker was found in that scope; this is not full timing/coverage, diagnostic-waiver, assembly or hardware approval. Reviewer: **GPT-6 (`gpt-6-astra-900k`, `openai-codex`), substituting for unavailable GLM5.3**. Review used local reads, hashes, JSON/AST and independent standard-library text/Decimal calculations only: no project imports, tests, Tcl/CMake/vendor execution, remote access, Git or hardware.

## Frozen evidence and authority

Independently checked **204/204 distinct members**, every byte count and SHA256, totaling **167,597,471 bytes**, with zero mismatches. Freeze SHA256 is `92fdf20b9ef8413426dc83bc994c988a8917582998bfda5d2fabd81e5ef0d8e9`. RESULT26's acquisition/numerical claims agree with the underlying captures, subject to the limits below. [Freeze27:1–824](actual-result-freeze27.json#L1-L824); [RESULT26:3–39](RESULT26.md#L3-L39).

Reverified the 114-member QUALITY and 69-member SOURCE freezes, consumed07 bindings and QUALITY18 SHA `d33226ee049e7102f3faf5def5c174cc2d28bd9b6b3dcab1aad8a7ac3539697e`. Candidate, staged and completed runtime code match; the admission is exactly the reviewed draft plus its authorized consumption delta. Issuer19 differs from its template only in the packet-digest slot; the recorded 1,657,040-byte packet satisfies the 2MiB bound. Decoded admission readback matches the completed manifest, SHA `df665c0f2656fa6343d78c79637c04ee6b53c8b5155b417a983e37292eeaf9d1`; successful non-consuming preflight preceded the single dispatch. **That admission and @304/%304 are spent, not replay authority.** [Consumption19:2–29](quality-consumed19.json#L2-L29); [rendering19:2–10](issuer-rendering19.json#L2-L10); [issuer19:12–42](issue-admission19.py#L12-L42); [dispatch20:2–27](sta20-dispatch.json#L2-L27).

## Actual execution and readback

Observation21's decoded process chain links native PID358538/start51582736 through CMake/make to runner358489/start51581526. Native executable hash is `d675f96e7dffe1f7c736dfe2a20e1d3f4e576a5a53f714a644d2082c00fd4fae`; exact argv/cwd agree with admission and the accepted callback. Native stdout confirms 26.1.1 Build 130, final-snapshot loading and the requested multicorner timing/CDC command—not synthesis or fit. [Callback:1](completion24-readback/operation/gate-events.jsonl#L1); [authority:8–34](completion24-readback/operation/authority.json#L8-L34); [native log:13–62](completion24-readback/operation/timing.log#L13-L62).

The runner interval is **18:45:18.119732–18:46:57.549876Z on 2026-10-02: 99.430144s**, including configure/version/postflight. The CMake timing target spans **86.595784s**; native stdout reports 85s. CMake/effective/outer statuses are zero; configure has no native status. **Native zero is inferred from successful direct CMake vendor targets, not a separately sampled native wait status.** No timeout, rejection, log-bound event, postflight error or residual owned group is recorded. Completion-event20 and post-completion observation22 agree; capture24 finds no matching owned processes. [Commands:5–125](completion24-readback/operation/result.json#L5-L125); [CMake:14–23](completion24-readback/control/runtime/CMakeLists.txt#L14-L23); [footer:3675–3681](completion24-readback/operation/timing.log#L3675-L3681); [completion20:7–13](sta20-completion-event.json#L7-L13); [capture24:19–37](completion-index24.json#L19-L37).

Decoded and hash-checked **all 54 exports/70,744,266 bytes** against their retained bodies and index, including all seven required reports and three logs. Raw result SHA is `45f6185771f6538548faaa2916c597cde5bb529c0ddd06ff5446e2dd1512a07d`; result/status/captured-result agree, with only an added final newline in status. Only the allowed fail-summary is empty; the optional rejection file is absent. [Index24:3–18](completion-index24.json#L3-L18); [report/log bindings:205–277](completion24-readback/operation/result.json#L205-L277).

## Preservation

All **15 capture preservation checks** pass, with no acquisition errors. Reconciled the disjoint **4027 = 4001 critical + 26 runtime** inventory; the 280 physical/static inputs remain a critical subset. Bound domains include original fitted 4025 and mapped 3894 entries, external 298, setup 3443, release 3454, archive 857, tools 14 plus OPAE 92, controls and five predecessor results. Collector/runner checks cover original fitted/mapped entry sets as well as bytes. [Checks24:20–36](completion-index24.json#L20-L36); [collector:77–102](capture-completion24.py#L77-L102); [runner:146–156](candidate06/run-sta06.py#L146-L156).

Recomputed runtime deltas: **17 unchanged, 9 changed, 0 removed**. QDB metadata reconciles **729→733 files, 394,551,887 final bytes**, four added STA/report/DA/qmsg members and seven changed existing report/runlog members. Protected QDB metadata matches; QPF readback is byte-identical. This is not a new physical implementation. **These are independently checked captured bodies/metadata and recorded remote preservation witnesses—not a fresh remote rehash of every original file.** [QDB delta:2–103](qdb-delta27.json#L2-L103); [verification25:1385–1398](native-result-verification25.json#L1385-L1398); [QPF:3554–3565](completion24-readback/operation/result.json#L3554-L3565).

## Independent numerical reconstruction

Without importing the reviewed parser or running analyze-result25.py, reconstructed every native/hook record, field, location and outside-record line. All three parsed components equal the stored runtime components: **3031 native lines/923 records; 2540 hook-pass lines/635 records; zero hook-fail lines/records**. Every slack is finite/nonnegative; every applicable TNS is exactly zero. Domain keys are unique, observed corner/domain populations reconcile, and no malformed/orphan record or unresolved screen difference was found. Anonymous constraint records were retained, not deduplicated. [Parser contract:34–153](candidate06/sta_numeric06.py#L34-L153); [counts/minima25:15–155](native-result-verification25.json#L15-L155).

| Family | Native | Hook | Minimum native slack, ns |
|---|---:|---:|---:|
| Setup |17|85|0.002|
| Hold |17|85|0.000|
| Recovery |10|50|0.232|
| Removal |10|50|0.109|
| Minimum Pulse Width |73|365|0.000|
| Max Skew |650|—|1.178|
| Net Delay |146|—|1.012|

The 127 native clock/family aggregates and five-corner hook records overlap: **not 1,558 distinct physical paths**. Zero hold/MPW is not positive margin. Raw tables confirm 81 constrained clocks, bank0 application period 3.000ns and all 25 application corner/family hook records. Four selected ready→accepted_bytes setup summaries genuinely report 0.002ns, 3.000ns relationship and no SDC exception: propagation corroboration, **not all-endpoint proof**. Identical static/current clock names do not imply identical periods: user outputs are 200/100 versus 312.5/156.25MHz; bank0 remains 3.000ns. These are analyzed clocks, not hardware measurements. [Clock25:235–254](native-result-verification25.json#L235-L254); [selected26:8–85](selected-path-evidence26.json#L8-L85); [clock delta26:7–62](clock-comparison26.json#L7-L62).

## Findings and outcome separation

- **Execution-clean is not warning-clean:** independently reconciled 0 errors/379 warnings, including one Critical 20727. Native reports up to 24 processors versus 18; 36-CPU affinity/request does not establish 36 workers. [Log:10–40](completion24-readback/operation/timing.log#L10-L40); [footer:3675](completion24-readback/operation/timing.log#L3675).
- Signoff DRC has **23/88 rules with violations, including 7/34 High**. Unconstrained-clock counts are zero, but input 2/78 pairs and output 2/10 pairs remain in setup/hold. Their disposition belongs to the separate diagnostic/coverage reviews; numerical success supplies no waiver. [DRC:123–215](completion24-readback/reports/ofs_pr_afu.tq.drc.signoff.rpt#L123-L215); [unconstrained:216255–216265](completion24-readback/reports/ofs_pr_afu.sta.rpt#L216255-L216265).
- Preserve the **additional** 3 clk_sys/7 bank0 reset cycles, four electrical omissions and entry/protocol conditions. No hardware, reset-sequencing or universal endpoint/CDC/exception coverage acceptance follows. [FIT acceptance:17–30](../fim24-caps03-physical01/FIT-ACCEPTANCE38.md#L17-L30).

**Accepted here:** execution/acquisition integrity and initial numerical screen. **Still separate:** actual timing/coverage/diagnostic acceptance; `timing_accepted=false` remains appropriate. No native rerun is warranted solely to restate these captured results. [Raw outcome:3564–3574](completion24-readback/operation/result.json#L3564-L3574); [remaining review:61383–61393](completion24-readback/operation/result.json#L61383-L61393).

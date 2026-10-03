# ACTUAL migrated IA840F assembly result review26 — FINAL — PASS WITH LIMITS

**Reviewer:** independent Hermes subagent; actual model `gpt-6.1-sol-900k`, provider `openai-codex`.

**Verdict: PASS WITH LIMITS for the completed, exact admitted `asm01` native persona assembly and acquisition of its actual artifacts.** The result is accepted, not merely the prepared runner or a historical assembly. No assembly/acquisition corrective blocker remains. This verdict does **not** accept GBS packaging, programming, hardware behavior, timing/CDC closure, or migration completion; it neither issues fresh native authority nor changes tracked tasks or readiness flags.

**Method and boundary:** local file reads, SHA256/byte counts, JSON/gzip/base64 decoding, static source comparison and Python AST parsing only. No project imports, tests, Git, remote/vendor execution, hardware access or executable changes. Remote preservation/drain observations are the hash-bound captured runtime's observations, not a new live workstation check. Only this report was written.

## 1. Frozen basis, ancestry and acquisition integrity

Read `result-freeze24.json` first. Its **3,235 bytes** hash to **`712f4b58762019f2537defcd2a10cefbc67dad38bf8c4f94159541501bff4018`**. Independently rehashed **19 declared / 19 enumerated / 19 exact size-and-SHA256 matches / zero mismatches**. Appendix A gives every member. The freeze remains unchanged; supplement25 is separately bound, not retroactively inserted into freeze24. [result-freeze24.json:2–82](result-freeze24.json#L2)

Also independently reverified ancestry: **quality-freeze14:18/18**, SHA256 `93ab4c2f441917da88fd262a4978d0e0da08156d886c545749a4a31f621db09c`; **source-api-freeze04:36/36**, SHA256 `e09ee53ec5c0db3612a8c180dbba5f35fc16eff1936de3a2442d8c2d8da1ffd4`; zero byte/hash mismatches in either. SOURCE/API05 SHA256 `86fb4833277ce0abf9be14fe13cfe9df8612d13d9c7cb4471562ff2d47019fff` and FINAL QUALITY15 SHA256 `e8a5e8d1bc0dd9ab8862248b1ba83a87c8ad8db9f6d022157a8a533fffe43b25` are the actual reviewed texts. Their assembly-result obligations were inspected, rather than inferred from `execution_clean`. [source-api-review05.md:33–40](source-api-review05.md#L33), [quality-review15.md:149–159](quality-review15.md#L149)

The actual production admitted manifest is **7,609,937 bytes**, SHA256 **`d9466be2aa039c5160bbf4082fc241ff431387ccb14564fa06ade03ee54d3549`**. Its retained bytes match the admission18 envelope/export/index; the result, runner invocation and callback all bind that same SHA256. A local structural comparison against draft12 finds exactly three changed top-level keys: `parent_execution_accepted` becomes true, `quality_admission` is added, and `prerequisites` adds the exact QUALITY freeze/review/consumption bindings. All 13 compared prepared inventory/binding domains remain equal; executable/context/output/resource contracts do not change. `ready_for_build=false` and `hardware_ready=false` remain false. The admission receipt records full admitted preflight success with the operation then absent. [admission18/index.json](admission18/index.json), [quality-consumed17.json](quality-consumed17.json), [admitted manifest:123840–125289](admission18/readback/asm-inputs.admitted.json#L123840)

**Capture integrity:** decoded every retained payload and compared its bytes, size, SHA256 and export metadata against the local readback/index. All envelope capture fields equal their index fields; index-only transport/outer fields remain separate. The envelope/index native result objects equal the parsed actual `result.json`.

| Capture | Verified exports | Envelope compressed bytes | Verified envelope SHA256 |
|---|---:|---:|---|
| assembly19 | 13/13 | 122880 | `f5b8b6a7711f3c9056752de7afe7005036a5dbcaaca507bc9f1d6860220b3c4a` |
| admission18 | 1/1 | 1914152 | `bf26438d6c2b57dabf1941f88df6fc334e83350bbfde407283c6c63229267da0` |
| images25 | 3/3 | 22328185 | `6718d61635b42429baea34202f5ddcc33baeeda3edc59e87a8b4675191c80814` |

assembly19 has runner outer0 and collector outer0, owned pane `@399 %399`. Supplement25 has success true/outer0, pane `@402 %402`, and binds the completed assembly result SHA256. `copy-images25.py` performs ordinary-file reads and tmux publication only; it neither invokes a native stage nor accesses a device. Its SHA256 is `7158aec0661c20eb7f8e98cb1c0ade3b706f9f1989b3359b3805b136433f081d`. Supplement index SHA256 is `08759a07bb99c9d20135335019f91245481066627b782e6041774e2f49836afe`. [assembly19/transport.json:8–11](assembly19/transport.json#L8), [assembly19/index.json:3536–3619](assembly19/index.json#L3536), [images25/index.json](images25/index.json), [images25/transport.json:8–11](images25/transport.json#L8), [copy-images25.py:8–20](copy-images25.py#L8)

## 2. Actual native stage, status, callbacks and drain

The reviewed CMake source contains one direct vendor command, with no synth/fit/STA/full-flow/GBS/programmer dependency:

```text
/opt/altera/26.1.1/quartus/bin/quartus_asm ofs_top -c ofs_pr_afu
```

Exact cwd:

```text
/home/uwb_student00/ahls/new_BSP/work_fim24_caps03_assembly01/base01/build/syn/board/ia840f/syn_top
```

The real configure/build command records select the admitted runtime, private `asm01/cmake-build`, `--target assembly --parallel 1` and this project. Native log line29 independently records `quartus_asm ofs_top -c ofs_pr_afu`; line12 identifies **26.1.1 Build130 SC Pro Edition**. SOURCE/API05's rejected help01 wrong-root observation is not reused as qualification of this result. The runner selects an explicit26.1.1-only vendor environment and excludes `OPAE_PLATFORM_GEN`. [candidate07/CMakeLists.txt:1–21](candidate07/CMakeLists.txt#L1), [candidate07/run-asm07.py:226–232,315–318](candidate07/run-asm07.py#L226), [result.json:5–90](assembly19/readback/result.json#L5), [assembly.log:11–30](assembly19/readback/assembly.log#L11)

| Actual command/status layer | Native rc | CMake rc | Effective rc | Outer rc |
|---|---:|---:|---:|---:|
| Configure | null: no vendor tool | 0 | 0 | n/a: runner/collector below |
| Direct assembly target | 0, propagated child-zero basis | 0 | 0 | n/a: runner/collector below |
| Reviewed runner | n/a | n/a | completed clean postflight | 0 |
| assembly19 collector/transport | n/a | n/a | successful acquisition | 0 |

**Native zero is propagated through the direct CMake vendor target, not separately recovered by waiting on the vendor PID.** CMake zero plus the exact target supports child zero, corroborated by the native successful footer. Individual vendor nonzero would be unknown/null if CMake were nonzero; no such nonzero occurred here. Do not confuse runner-log `result_sha256` with raw result.json SHA: its `6df038d7dc04d3caa85f6fc0e1b85e2ab265ea85a7ba9e0d6fde8108d6b29415` was independently reproduced from gzip-compressed sorted-key result JSON. Raw result.json SHA is `d8a03af543af01c422af7adac8fdc50a709fa8df4a9e6e68d058157f93760f1c`. [candidate07/run-asm07.py:297–308,326–331](candidate07/run-asm07.py#L297), [runner.log:1–16](assembly19/readback/runner.log#L1)

Both real command records have **timeout=false, gate_rejected=false, log_bound_exceeded=false, no descendants observed at leader exit, and empty owned_group_live_after**. The result is complete; diagnostics, gate rejections and postflight acquisition errors are empty. Configure log170 bytes and assembly log9,746 bytes both match runtime log bindings. Native PID384580 ran from08:53:46 to08:59:49, elapsed00:06:03; result timestamps are15:53:45.068730 to16:00:04.494282UTC. Different report/log end seconds do not change status. The flow report's retained synthesis/fit/STA rows are cumulative predecessor records, **not new execution by this assembly operation**. [result.json:5–90,157–204,3524–3530](assembly19/readback/result.json#L5), [assembly.log:27–29,68–73](assembly19/readback/assembly.log#L27), [flow.rpt:410–441](assembly19/readback/output_files/ofs_pr_afu.flow.rpt#L410)

**One actual accepted callback / zero rejections.** Event bytes equal the result event object. Native exe `/opt/altera/26.1.1/quartus/linux64/quartus_asm`, argv `[quartus_asm,ofs_top,-c,ofs_pr_afu]`, exact cwd, PID384580/PPID384579/start ticks`59193325` agree with the native log and admitted context. Runner PID384534/start ticks`59191960`, argv isolated `/usr/bin/python3 -I -B .../run-asm07.py <admitted-hash>`, matches the captured invocation. Static callback source verifies native executable hash/context and the live owner identity/ancestry before emitting acceptance; the event is evidence that that bound callback accepted, not a captured full ancestor-chain listing. The callback/runner ASTs parse and their locally rehashed bytes equal admitted bindings. [gate-events.jsonl:1](assembly19/readback/gate-events.jsonl#L1), [result.json:94–110,182–204](assembly19/readback/result.json#L94), [candidate07/ia840f_asm_gate07.py:41–73](candidate07/ia840f_asm_gate07.py#L41)

Resource record preserves CPUs0–35, per-process address-space cap68,719,476,736 bytes, configure60s/assembly1800s. Native peak virtual memory is19,344MB. These are captured supervision bounds, not aggregate memory isolation, a security sandbox, or current remote availability. No hardware access was recorded. [result.json:112–156](assembly19/readback/result.json#L112), [candidate07/run-asm07.py:231–308](candidate07/run-asm07.py#L231), [assembly.log:69–71](assembly19/readback/assembly.log#L69)

## 3. Preservation and actual runtime delta

Parsed admitted/prepared metadata independently reconfirms **4,040 active entries = 4,014 critical + 26 exact existing mutable roles**, disjoint with exact union and matching bindings. All280 protected static/physical bindings are a matching critical subset; none is mutable. The four corrected STA databases remain critical. Replacing only the two early STA gate filenames in copy03's QSF with assembly gate filenames reproduces staged QSF byte-for-byte; the stage does not alter part, parallelism, RTL, SDC or PR import settings. [candidate07/run-asm07.py:84–118](candidate07/run-asm07.py#L84), [stage12/readback/ofs_pr_afu.qsf:2–3,11–12,26–27,95–139](stage12/readback/ofs_pr_afu.qsf#L2), [source-consumed07.json:13–30](source-consumed07.json#L13)

| Captured preservation domain | Bound entry count | Actual result |
|---|---:|---|
| Active critical inputs | 4014 | preserved |
| Protected static/physical snapshots | 280 | preserved; physical presence true |
| Original accepted-STA source | 4038 | preserved, full inventory equality |
| Original fitted source | 4025 | preserved, full inventory equality |
| Original mapped source | 3894 | preserved, full inventory equality |
| External inputs | 298 | preserved |
| DNI archive | 857 | preserved |
| Original setup | 3443 | preserved |
| Original release | 3454 | preserved |
| Tool and OPAE/package-source bindings | 14 + 92 | preserved |
| Reviewed controls/prepared metadata/prerequisites | exact manifest bindings | preserved |
| Predecessor results | 6 | preserved |

All **12 preservation-domain flags** at result lines157–168 are true, plus QPF semantics preserved=true. These source-bound postflight checks rehash actual bound bytes; full-tree equality is used for original STA/fitted/mapped inventories, while other domains check their enumerated bindings. This does not claim arbitrary unlisted paths were inaccessible or hash checks prevented writes. [result.json:157–168](assembly19/readback/result.json#L157), [candidate07/run-asm07.py:46–72,145–161](candidate07/run-asm07.py#L46)

**Independent captured-QDB reconciliation:** before733 members, after736 members; no missing member. Exactly three new paths are the required assembly model/RDB/qmsgdb. Only three existing QDB members change: `report.cmp.model`, `report.cmp.rdb`, `legacy/1/runlog.db`, all admitted mutable roles. All **709 pre-existing critical QDB bindings** and **279 protected members within qdb/** match the after-inventory size/SHA metadata with zero mismatches. The280th protected entry is imported `ofs_top.qdb` outside qdb/, whose continued preservation is covered by the actual critical/protected runtime flags; it is not falsely counted as a separately transferred binary. [result.json:211–3157](assembly19/readback/result.json#L211), [admitted protected bindings:123855–125256](admission18/readback/asm-inputs.admitted.json#L123855)

**26/26 runtime before/after records reconcile against admitted before-bindings; five change,21 are unchanged; no role disappears or becomes a symlink.** The five exact changes, relative to the project cwd, are:

| Mutable path | Before bytes / SHA256 | After bytes / SHA256 |
|---|---|---|
| `output_files/ofs_pr_afu.flow.rpt` | 133377 / `a90a7c5f3ab4c0015fe351218921ca7d548588f2495bcadc9e3ca174099b41e2` | 133553 / `3aef95d47358768909a595dc24027f90ebfcb39bb216a57b0f749222998c0297` |
| `output_files/ofs_pr_afu.sdc_constraints.rpt` | 2439 / `90783cbc43f6f256378ac9e447b0508129ba51fc5f73ff4089a2900fc68a4f83` | 2439 / `43f2008593d1a41d8711dceb754c9508702ca70fa90ec274d0698d31ba924528` |
| `qdb/_compiler/ofs_pr_afu/_flat/26.1.1/_all/1/report.cmp.model` | 137 / `2bf638ede6e8c9a00118c951bdb652f9167a1244723751c9050447099068674c` | 137 / `288c5ad0b2ebcc1d626c6da12300c80c0e1bf1ce2ede9ab1829b64f376b301b0` |
| `qdb/_compiler/ofs_pr_afu/_flat/26.1.1/_all/1/report.cmp.rdb` | 8950 / `ae4ab879725499f215310f9e1bad30fb0b8e8c7ff5ed81613dca0b31c15f7042` | 9002 / `88ddb29add5c9b08da1343778c726041a300f17df440caa2567b3bb9658d9d7b` |
| `qdb/_compiler/ofs_pr_afu/_flat/26.1.1/legacy/1/runlog.db` | 8192 / `a0e8924598b94305a8c64b73c8e8a9e84b72021cbe5d4579f68f59ceb0cf6957` | 8192 / `fe5e5a09f6ba3f16fa7ea910bd8e139bbbb3f544b1d4dbfb089f88e0402f8ddb` |

These changes are admitted report/bookkeeping roles, not evidence of resynthesis, refit or new STA. All26 exact paths and their before/after hashes are retained in result.json; the allowed set was not broadened after execution. [result.json:3158–3497](assembly19/readback/result.json#L3158), [quality-review15.md:78–109](quality-review15.md#L78)

QPF is **byte-identical**, not merely semantically preserved: before/after/readback1,345 bytes, SHA256 `722db807ae6fdd05fa999d773bf7b86817da9cafedb396e197c9d8f7d4cc0108`; `qpf_changed=false`. `PROJECT_REVISION="ofs_pr_afu"` and `QUARTUS_VERSION="26.1"` remain unchanged. Clock metadata stays100/200MHz,133 bytes/SHA256 `f5ed24d88af0253192249260b91cf463d7fbdfe382e695a7d2a2c6030e2c3c71`, matching the critical before-binding and local bytes. No clock recomputation or QPF rewrite is claimed. [result.json:3498–3509](assembly19/readback/result.json#L3498), [ofs_top.qpf](assembly19/readback/ofs_top.qpf), [user_clock_freq.txt:1–3](assembly19/readback/output_files/user_clock_freq.txt#L1)

### Immutable STA databases, required final members and baseline bindings

All following QDB before/after metadata agree. Final member presence is not merely inferred from a fitted success flag.

| QDB path relative to project | Bytes | Unchanged SHA256 |
|---|---:|---|
| `qdb/_compiler/ofs_pr_afu/_flat/26.1.1/_all/1/report.sta.model` | 137 | `9272ecb8a7b06c23460c9a3f036bcf7198b31ec62176d5d8a81a0894d50359c3` |
| `qdb/_compiler/ofs_pr_afu/_flat/26.1.1/_all/1/report.sta.rdb` | 5061188 | `688ae43f301bc79c2a340bdf747cc4db58d99dc11380481b9e58efbad4135b57` |
| `qdb/_compiler/ofs_pr_afu/_flat/26.1.1/legacy/1/da_report_timing_signoff_final.sqlite3` | 3211264 | `cbb9cb04cadd9b474157c8ba29f8d88e553ebbef1a49268fd97a82141891883e` |
| `qdb/_compiler/ofs_pr_afu/_flat/26.1.1/legacy/1/ofs_pr_afu.sta.qmsgdb` | 5627904 | `099cd298a0cc554c69c32047f4e7a1696d2fea29de1df1449870e8cf08dee620` |
| `qdb/_compiler/ofs_pr_afu/_flat/26.1.1/final/1/chip.chip.cdb` | 677798 | `2b558c5d7ccc2f9b3452c59ebf4ebf0fb77615de7ef4dd20869085bd38e83c0b` |
| `qdb/_compiler/ofs_pr_afu/_flat/26.1.1/final/1/idb.idb` | 3398 | `43168e19ae4c458c2c65e1cada4dce9b5c3b7761a43aea7fecd1d635b1b28fb5` |
| `qdb/_compiler/ofs_pr_afu/green_region/26.1.1/final/1/netlist.atom.cdb` | 14420971 | `08a8ed103aa69fa8ed2480922524e2e0ad56379b39d36e2d5c1acfc36aa42ead` |
| `qdb/_compiler/ofs_pr_afu/green_region/26.1.1/final/1/physmap.cdb` | 3083712 | `a3e4c7b83379bc590be4ff6734567ce69d8a1cae34f0807b126d1172c2fe3572` |
| `qdb/_compiler/ofs_pr_afu/green_region/26.1.1/final/1/routing.cdb` | 19410210 | `62e116663b65a20c75f429198d543f1e35b63f65c2c0529030ad58ae8da53e0e` |

Imported static QDB is bound at78,571,428 bytes/SHA256 `dbc1684ab873b3d317d20019430c99177653daf221e7471b227b1966d7ef30b4`. The assembler explicitly loaded the **final** root_partition, green_region, auto_fab_1 and auto_fab_0 snapshots, then reported successful final-database load. It selected the following unchanged critical baseline artifacts for PR mask, static mask and root-logic-preservation verification:

| Native baseline role | Critical path | Bytes | Preserved binding SHA256 |
|---|---|---:|---|
| PR region mask | `output_files/ofs_top.green_region.pmsf` | 7184035 | `7af20ac5606c423469343b78f694018775fea5ffbfdec63149e1c104c763ccc1` |
| Static mask | `output_files/ofs_top.static.msf` | 3279948 | `b6bf7bd66b1b3dffd65c650dc8bf53faad42c09add1c9fdabf7ed1e241e395ec` |
| Root-region logic | `output_files/ofs_top.sof` | 7836539 | `16812c62675e31bb7d3bdbdce80e9342c32bb7263c6a862611da427249c85195` |

Actual native messages are Info16734/16678 and Info18936/18938/18937, followed by successful assembly with zero errors. They establish the named vendor baseline-verification route under the accepted vendor/compiler trust model; this report does not turn the wording “Using ... as a baseline ... verification” into a newly captured independent bit-equivalence proof. No new fit, Boolean-equivalence or vendor-internal qualification is needed for this assembly acceptance. [assembly.log:31–35,58–68](assembly19/readback/assembly.log#L31), [asm.rpt:176–180,203–213](assembly19/readback/output_files/ofs_pr_afu.asm.rpt#L176), [source-api-review05.md:35–40](source-api-review05.md#L35)

## 4. Actual assembler report/database roles and images

Actual report is **24,907 bytes**, SHA256 **`bbc98a8a5838a91d40cb43ee433cbdfd3cc69737695dcf0adc87e2a04534f084`**. Its own header is26.1.1 Build130; summary says **Successful**, revision`ofs_pr_afu`, entity`top`, familyAgilex7, device`AGFB027R25A2E2V`, final timing/power/device models. It contains the actual native footer: **“Quartus Prime Assembler was successful. 0 errors, 19 warnings”**. [asm.rpt:1–3,40–51,213–217](assembly19/readback/output_files/ofs_pr_afu.asm.rpt#L1)

All three new assembler database/report roles were actually collected, decoded and locally hash-verified; they were absent before. This satisfies the semantic/acquisition obligation that the prepared runner's clean flag alone did not enforce:

| New assembler QDB role | Bytes | Local verified SHA256 |
|---|---:|---|
| `qdb/_compiler/ofs_pr_afu/_flat/26.1.1/_all/1/report.asm.model` | 137 | `e15df75a54eb74e07823609f026736fe5321aaed2de3ddf252056926d7af2642` |
| `qdb/_compiler/ofs_pr_afu/_flat/26.1.1/_all/1/report.asm.rdb` | 3235 | `b37ff974e2dd460d8b09d4bacd4304539c5e7949623c9c85ff03e8a6a492042c` |
| `qdb/_compiler/ofs_pr_afu/_flat/26.1.1/legacy/1/ofs_pr_afu.asm.qmsgdb` | 73728 | `a558c666443c3fa1919e850767a118dfac236d6a7c52a1ce4c4e3cf434ce8246` |

[launch19.py:24–29](launch19.py#L24), [assembly19/index.json:3550–3616](assembly19/index.json#L3550), [quality-review15.md:153–155](quality-review15.md#L153)

**Three real image files, three native runtime bindings, three supplement25 exports, three ordinary/non-symlink local readbacks, all matching size/SHA256.** Total actual image bytes **29,578,023**. Required persona image paths and assembler report were absent from the admitted before-inventory; inherited baseline images are not substituted. The PMSF is explicitly region-qualified.

| Actual image in `images25/readback/` | Bytes | Local/native/supplement identical SHA256 |
|---|---:|---|
| `output_files/ofs_pr_afu.sof` | 10067421 | `00dbd01b5b8c7c0b49fb1f9340ac9464e61a634ff045a1c0c4b79a464175d46f` |
| `output_files/ofs_pr_afu.green_region.pmsf` | 9409866 | `598bd9e969feffb95653fd0ffef246362257a3605a32098cfe64bdbbe70f023e` |
| `output_files/ofs_pr_afu.green_region.rbf` | 10100736 | `9f7830bdf6f12cd2a1934dddaae26f7a231657e1764d3e9dc8c3e239f882964a` |

The native Generated Files panel lists SOF and region PMSF only; **it does not list the RBF**. That omission is not hidden or replaced with an invented line. Report setting line99 has “Generate Partial Reconfiguration Raw Binary File (.rbf)” **On**, and the actual new region RBF is separately proven present/nonempty by runtime inventory plus the matching decoded/local supplement bytes. This is PR-RBF acquisition, not a claim that obsolete full-device RBF generation worked. [asm.rpt:99,231–238](assembly19/readback/output_files/ofs_pr_afu.asm.rpt#L99), [result.json:3510–3525](assembly19/readback/result.json#L3510), [images25/index.json](images25/index.json), [copy-images25.py:8–16](copy-images25.py#L8)

Result interface UUID is **`fc603c44-5c8f-5e94-bcbe-a5780030947c`**; AFU UUID is **`d48dde9f-f551-578d-8bb0-69483ac95ec6`**. These equal admitted metadata; the interface UUID also appears in the actual native environment messages. This verifies captured assembly identities, not a GBS-header extraction or UUID discovery from raw bitstream internals. User clocks remain100/200MHz. [result.json:109–110](assembly19/readback/result.json#L109), [assembly.log:1–9](assembly19/readback/assembly.log#L1)

## 5. Complete native warning reconciliation and disposition

Parsed every column-zero **and indented** Warning/Critical Warning occurrence in both complete native log and assembler report. **18 ordinary + 1 critical = 19**, exactly the native footer. Report and log messages are identical repeated copies, not38 independent warnings; the parent reconciliation23 occurrence ledger equals the independently parsed log ledger. Four nested Info20728 port names belong to the one CW20727 and are not four extra warnings. No Error/Fatal/callback-rejection diagnostic is present in the completed log/result. [assembly.log:36–68](assembly19/readback/assembly.log#L36), [asm.rpt:181–213](assembly19/readback/output_files/ofs_pr_afu.asm.rpt#L181), [assembly-reconciliation23.json](assembly-reconciliation23.json)

### Warning18502 —17 current/base SDC assignment differences

**Disposition:** source-supported PR-current/base assignment distinction, retained timing-constraint caution; not a newly introduced assembly input mutation and not waived as universally harmless. The PR QSF intentionally uses`ofs_top.out.sdc` and an imported base QDB with PR_IMPL/entity rebinding; the normal selected loader imports PIM sources. Current constraints/RTL/final STA databases and clock metadata are protected and actually preserved. The assembler consumes an accepted final fitted/STA corpus; it is not recomputing or relaxing timing. This warning does not invalidate the narrow assembly/artifact result. Native warning text itself gives every current-only/base-only assignment; no additional unchecked path is inferred. [staged QSF:95–139](stage12/readback/ofs_pr_afu.qsf#L95), [selected loader:8–21,46–78](../fim24-caps03-sta01/completion24-readback/design/build/ofs-common/src/fpga_family/agilex/afu_main.tcl#L8), [source-api-review05.md:27–31,35–40](source-api-review05.md#L27)

**Smallest relevant follow-up, only if constraints/persona change:** compare that changed PR/base assignment set and effective constraints to the accepted STA/CDC basis before seeking new timing acceptance. Do not suppress18502, reinterpret this assembly as fresh STA, or rerun unchanged fit/STA just to eliminate expected source/base differences.

| Log line / asm.rpt line | Side containing the SDC assignment | Exact native file token |
|---|---|---|
| 41 / 186 | current only | `ofs_top.out.sdc` |
| 42 / 187 | current only | `../../../../platform/ofs_plat_if/rtl/utils/prims/ofs_plat_prim.sdc` |
| 43 / 188 | current only | `../../../../platform/ofs_plat_if/rtl/utils/quartus_ip/ofs_plat_utils_avalon_dc_fifo.sdc` |
| 44 / 189 | current only | `../../../../platform/ofs_plat_if/rtl/utils/quartus_ip/ofs_plat_utils_mf_dcfifo.sdc` |
| 45 / 190 | current only | `ofs_partial_reconfig/user_clocks.sdc` |
| 46 / 191 | base only | `../../../../ofs-common/src/common/port_gasket/user_clock/user_clock.sdc` |
| 47 / 192 | base only | `../../../../ofs-common/src/fpga_family/agilex/sys_pll/sys_pll.sdc` |
| 48 / 193 | base only | `../../../../ofs-common/src/common/mem_tg/tg_axi_mem/mem_ss_tg/mem_ss_tg_axi_100/src/mem_ss_tg_axi.sdc` |
| 49 / 194 | base only | `../../../shared_config/setup_user_clock_for_pr.sdc` |
| 50 / 195 | base only | `afu_with_pim/afu/build/platform/ofs_plat_if/rtl/utils/prims/ofs_plat_prim.sdc` |
| 51 / 196 | base only | `afu_with_pim/afu/build/platform/ofs_plat_if/rtl/utils/quartus_ip/ofs_plat_utils_avalon_dc_fifo.sdc` |
| 52 / 197 | base only | `afu_with_pim/afu/build/platform/ofs_plat_if/rtl/utils/quartus_ip/ofs_plat_utils_mf_dcfifo.sdc` |
| 53 / 198 | base only | `../../../shared_config/fim_dcfifo.sdc` |
| 54 / 199 | base only | `../../../shared_config/top.sdc` |
| 55 / 200 | base only | `../setup/bti_refclk.sdc` |
| 56 / 201 | base only | `../../../shared_config/pmci_top.sdc` |
| 57 / 202 | base only | `../setup/bwbmc.sdc` |

### Critical Warning20727 —1 unused-input warning with four Info20728 details

Affected partition is`green_region`, instance`afu_top|pg_afu.port_gasket|pr_slot|afu_main`; exact input leaves are **clk_div2, clk_div4, uclk_usr, uclk_usr_div2**. Native log36–40/report181–185 identify them. The hash-joined selected `afu_main.sv` declares these optional clocks at44–47 and passes them at321–324; its preserved-clock noprune registers are explicitly under`ifndef PR_COMPILE` at378–433, with comments381–384 stating base-build preservation is not required for PR-build instances. The selected loader sets`PR_COMPILE` for PR_IMPL. This gives a concrete source reason for unused optional clock inputs in this persona, rather than treating the severity or vendor origin as proof of harmlessness. Source SHA256`530481dc6604fb5cbc1df983dd5f91ae37b02c2f981e7b35e25f24cd117069d5` matches the admitted design binding; selected loader SHA256`800b6fc92915cd4e66aba8cc051997ceea8fe155a2b2ae20dec85a2db21c2f47` also matches. [afu_main.sv:43–47,310–324,374–433](../../ofs-agx7-pcie-attach/ofs-common/src/fpga_family/agilex/port_gasket/afu_main_std_exerciser/fim_compile/afu_main.sv#L43), [loader:8–21](../fim24-caps03-sta01/completion24-readback/design/build/ofs-common/src/fpga_family/agilex/afu_main.tcl#L8), [assembly.log:36–40](assembly19/readback/assembly.log#L36)

**Disposition:** source-justified expected unused optional-clock boundary in the unchanged assembled persona, with an unwaived PR-interface preservation recommendation/risk. No noprune/source retrofit or new fit is warranted for artifact acquisition. **Smallest relevant future check:** if a later persona needs one of those clocks, verify its consumer and static/PR boundary preservation contract against the actual final database before qualifying that changed persona. This report does not certify future personas or hardware clock delivery.

### Warning20536 —1 ignored obsolete GENERATE_RBF_FILE setting

The exact staged QSF87 still assigns`GENERATE_RBF_FILE ON`; native log65/report210 says that legacy setting is ignored. **Disposition: confirmed obsolete setting, nonblocking for the actual required PR-RBF output.** The distinct PR-RBF report option is On and the real region RBF was acquired/hash-verified above. Do not claim the obsolete setting was effective, create an unqualified RBF alias, or require a converter replay merely because this message mentions Programmer File Generator/Convert Programming File. If a later stage specifically requires a different programming-file type, qualify its supported generator then; that is outside this result. [stage12/readback/ofs_pr_afu.qsf:67–89](stage12/readback/ofs_pr_afu.qsf#L67), [assembly.log:65–68](assembly19/readback/assembly.log#L65), [asm.rpt:99,210–213](assembly19/readback/output_files/ofs_pr_afu.asm.rpt#L99)

**Warning ledger conclusion:**17 W18502 +1 CW20727 +1 W20536 =19/19 reconciled; no dropped occurrence, suppression added by the assembly delta, or actionable assembly/acquisition blocker. The existing QSF suppress_warning loader remains inherited; this review does not claim it never suppressed other inherited warning classes. This is specifically the complete emitted assembler-warning ledger.

## 6. Actionable blockers and acceptance limits

**For this exact completed assembly and artifact acquisition: none.** Actual status chain, native/report semantics, callbacks, drain, preservation, allowed delta, three assembler DB roles and three byte-identical image readbacks all meet the consumed SOURCE/API05 and QUALITY15 obligations. Parent may consume this FINAL against its exact file SHA256; **do not rerun native assembly to obtain already acquired images or to requalify unchanged predecessors**.

Unchanged limits remain explicit:

- **GBS is not accepted or produced by this review.** A later offline packaging result must separately establish supported packager schema/CLI, current interface/AFU/100–200MHz metadata and extracted payload byte-equality. Raw RBF/SOF/PMSF are not GBS or deployment acceptance.
- Existing numerical STA setup+.002ns, zero hold/MPW and static signoff/DRC findings stay retained; the accepted current40-bundle/20-FIFO discriminator is not universal CDC/MTBF/Boolean-equivalence closure. No new vendor-internal/static requalification is imposed on this offline assembly.
- Operation-bound reset entry (three additional sys/seven additional bank0 cycles), both-bank initialization/containment, the four named electrical dispositions, SDK/BMC/readback/reboot and actual-card numerical/DDR/walking-bit/bulk/data tests remain separate. No implementation change or hardware action was undertaken or authorized here.
- Actual result retains`hardware_access=false`, `hardware_ready=false`, `coverage_accepted=false`, `deployment_ready=false`; admitted`ready_for_build=false` is also unchanged. Accepted artifact acquisition does not overwrite these raw flags or close a migration task.

[quality-review15.md:157–159](quality-review15.md#L157), [source-api-review05.md:40](source-api-review05.md#L40), [CDC-ACCEPTANCE73.md:16–24](../fim24-caps03-cdc03/CDC-ACCEPTANCE73.md#L16), [result.json:91–111,3526–3530](assembly19/readback/result.json#L91)

**FINAL disposition: PASS WITH LIMITS — completed migrated IA840F native assembly and actual artifact acquisition accepted; zero in-scope corrective blockers; no hardware/GBS/migration-completion claim.**

## Appendix A. Independently verified result-freeze24 members

Paths are relative to this capsule. This is the19-member frozen set, not a count of native images; image supplement25 remains separately bound above.

| Frozen member | Bytes | Independently verified SHA256 |
|---|---:|---|
| `admission18/index.json` | 1395 | `1093348ac6a3c43bf963a32b758385e4a2a7cce59b268d0aed12dd9bee186271` |
| `assembly-reconciliation23.json` | 8535 | `390d5043467ce8cb19bebaf1a3119cd82ceaa67cfa17914c6bccd97215d401ad` |
| `assembly19/index.json` | 185290 | `e0498c296e7c02718ee147c8b161dd50dabaceef5d8e3f9577b3375dd1bbc66b` |
| `assembly19/readback/assembly.log` | 9746 | `2b0f068d764c28dc261fd5e0fd3a56b76b10772633c6f94a9317b48af688f0a8` |
| `assembly19/readback/build_env_db.txt` | 314 | `64db499a57f720a29040970f496031b6e63a450f66af4ae56b7a7e89b2bae55b` |
| `assembly19/readback/configure.log` | 170 | `fd8cb1b59f8aa5498db71aae4f34e56362ff4217bb6ade68ffa9f887bf97de5e` |
| `assembly19/readback/gate-events.jsonl` | 442 | `6100547d1b0121213fd0b0c0c2b366507df8abd538483dbc99c431bd97b26cdc` |
| `assembly19/readback/ofs_top.qpf` | 1345 | `722db807ae6fdd05fa999d773bf7b86817da9cafedb396e197c9d8f7d4cc0108` |
| `assembly19/readback/output_files/ofs_pr_afu.asm.rpt` | 24907 | `bbc98a8a5838a91d40cb43ee433cbdfd3cc69737695dcf0adc87e2a04534f084` |
| `assembly19/readback/output_files/ofs_pr_afu.flow.rpt` | 133553 | `3aef95d47358768909a595dc24027f90ebfcb39bb216a57b0f749222998c0297` |
| `assembly19/readback/output_files/user_clock_freq.txt` | 133 | `f5ed24d88af0253192249260b91cf463d7fbdfe382e695a7d2a2c6030e2c3c71` |
| `assembly19/readback/qdb/_compiler/ofs_pr_afu/_flat/26.1.1/_all/1/report.asm.model` | 137 | `e15df75a54eb74e07823609f026736fe5321aaed2de3ddf252056926d7af2642` |
| `assembly19/readback/qdb/_compiler/ofs_pr_afu/_flat/26.1.1/_all/1/report.asm.rdb` | 3235 | `b37ff974e2dd460d8b09d4bacd4304539c5e7949623c9c85ff03e8a6a492042c` |
| `assembly19/readback/qdb/_compiler/ofs_pr_afu/_flat/26.1.1/legacy/1/ofs_pr_afu.asm.qmsgdb` | 73728 | `a558c666443c3fa1919e850767a118dfac236d6a7c52a1ce4c4e3cf434ce8246` |
| `assembly19/readback/result.json` | 173532 | `d8a03af543af01c422af7adac8fdc50a709fa8df4a9e6e68d058157f93760f1c` |
| `assembly19/readback/runner.log` | 234 | `d9d8e301445fd52daf6b9361c4e21ec11ad2b6e908cf6ab7e608f59e19b35f1d` |
| `quality-consumed17.json` | 1289 | `cb220335eefa07d8d8284dee76b8baa64183ca3829e39ab294f7217d147c6ae4` |
| `quality-freeze14.json` | 2888 | `93ab4c2f441917da88fd262a4978d0e0da08156d886c545749a4a31f621db09c` |
| `quality-review15.md` | 24438 | `e8a5e8d1bc0dd9ab8862248b1ba83a87c8ad8db9f6d022157a8a533fffe43b25` |

## Appendix B. Hash-bound selected source/control bytes

These are local source identities joined to admitted bindings, not claims of a new remote read. Python files were parsed, not imported or executed.

| Source/control | Bytes | Verified SHA256 |
|---|---:|---|
| `candidate07/CMakeLists.txt` | 1192 | `3eba22d917d297b5ec349357adb0be9afd70b9c1e56c8492e2c3f4159bba22be` |
| `candidate07/build_gate_asm07.tcl` | 509 | `e7618a9de9970acbad49066c5f481e04b00cf6df9c57b58fd58cbe41af3c81f8` |
| `candidate07/ia840f_asm_gate07.py` | 5232 | `8f20b708d34c01921ed3885fc63668971a197d1095f3bb67cae9374cbd7a8e44` |
| `candidate07/run-asm07.py` | 24425 | `1e90a0b24b92824edd616f129fc14f34594c23a17525117f21e30f14f225db1d` |
| `stage12/readback/ofs_pr_afu.qsf` | 7770 | `c0d193d2a0b9f2f7f971c4552762763e2c1a8d34c2625c81b4e916acd967c611` |
| `source-api-review05.md` | 8138 | `86fb4833277ce0abf9be14fe13cfe9df8612d13d9c7cb4471562ff2d47019fff` |
| `source-consumed07.json` | 1554 | `e2ceb45ae6f0622cab30eba0a5040694ab48c9e81fbe5c4a6ec814875943c028` |
| `launch19.py` | 4151 | `3b6e75aa2ac0a786d67c0449189abe1a19524d884db0419b94e0fae60e7ad97b` |
| `copy-images25.py` | 2425 | `7158aec0661c20eb7f8e98cb1c0ade3b706f9f1989b3359b3805b136433f081d` |

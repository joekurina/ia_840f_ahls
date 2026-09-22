# Independent QUALITY review — exact prepared fanout-diagnostic01

## Verdict: APPROVED

**No blocking implementation defects found in `prepared-readback02/`.** Approval is limited to the quality of the unchanged-SDC, baseline-only diagnostic package. It is **not execution authorization, native-result acceptance, collector validation, successful A/B evidence, maintained-source repair or timing/hardware qualification**. No unseen issuer is approved.

The consumed SPEC PASS was independently verified: `spec-review01.md` is 134 lines, SHA256 `c36f41c60a61bc642d8d1c1ba7312b442d7dd41b4dc66609bae666ab3a54969c`; `parent-spec-consumption01.json` SHA256 is `aeeb7e38f1df121bc740289f4df9ee5e285496a9b8c91ede2e7ec9bd26c7769d`. All bindings in that consumption record were rehashed successfully.

Only local reads, hashing/parsing and the four expressly permitted inert fixture invocations were performed. No remote connection, vendor/help invocation, real preparer/runner/gate/issuer entry, authorization, git, hardware operation or task closure occurred. Only this report was authored; saved receipts were not redirected or rewritten.

### Citation convention

- `F`: this report's directory; `D`: `F/prepared-readback02/`.
- `Z`: sibling `experiment03/`; predecessor means `Z/baseline/prepared-readback01/`.
- Unqualified implementation line references below refer to **D**, not merely authoring copies. Fixture sources are under F. All line references are 1-based.
- Remote-state statements describe saved captures, not a fresh remote inspection.

## 1. Exact package binding and retarget — verified

Decoded `preparation02.json.gz` in memory and verified batch `ia840f_clock_fanout01_preparation02`, the exact 14-export file set, base64 bytes, sizes and SHA256 values against the manifest, actual readback and parent consumption. All eight applicable authoring files equal their prepared exports. The archive contains the complete candidate regardless of raw-candidate ignore rules.

| Artifact | SHA256 |
|---|---|
| `prepared-manifest02.json` | `19c972f6e5e173c3b48e1bef4af73359dec0e695ddecf062daa07762b62e52e3` |
| `preparation02.json.gz` — 1,042,822 bytes | `8fb8eab7b421c0d9fb5f06f6f7169c598dbf347a38c43ae0988793a81e251f3c` |
| `D/candidate.json` | `39afbfaec768985d9472da0b95c58df676afd0c273d1257a9f40180b9f44a719` |
| `D/query.tcl` | `16ec28ff6ed66b9867338b09d4d12af0c3fa12d5926efd3b85cdc0c47edd0086` |
| `D/known-receivers.tcl` | `3bca69f770cba775919b7134822ae5eedcb324c1a25ed5540b781667d798ef6a` |
| `D/clock-repair.tcl` | `8486a48acbe4f024beecefb95d09eeab69ce0331d3f16d4a1f9c0591cdb117f2` |
| `D/run-query.py` | `fabd282e8c382f8eb36de419cc9959346ad7018f1dc3673782df23ee18288ff7` |
| `D/ia840f_clock_fanout01_gate.py` | `986c97fc71690c59b01e74e4fce2d0a56298f374fdfa3c198c87db1b3701d653` |
| `D/ia840f_experimental_gate.py` | `e59e732fc91c40d017206a9bca9478aa47dafe924b09ba4143268e283fd81cad` |
| `D/prepare02.py` | `87f3ba5f3c3acc0a8b120ad671f8b752620e1d989c4da6b1877a2f686a827522` |
| `D/top.sdc` | `8255b34c200a46178174b9788bdc9231072ae829f57c34703cc63dd28ab66c3d` |

The candidate recounts **7,885 file bindings, 7,762 callback bindings and 10 links**. Callback coverage is exactly the full map minus `.qpf`, `.rpt`, `.log` and `.summary` suffix classes. Query/helper/known-name/runner/document/top-SDC bindings and both copied gates reconcile. `approved=false`, `ready_for_build=false`, target `ia840f`, part `AGFB027R25A2E2V`, permission `exact-offline-fanout-diagnostic01` remain intact.

The remote root is `/home/uwb_student00/ahls/new_BSP/qualification/pcie-clock-repair-01/fanout-diagnostic01`. Candidate argv is `/opt/altera/26.1.1/quartus/bin/quartus_sta -t <root>/query.tcl`; the native identity is `/opt/altera/26.1.1/quartus/linux64/quartus_sta` with argv `quartus_sta -t <root>/query.tcl`, cwd `<root>/scratch/syn/board/ia840f/syn_top`. Runner identity is `/usr/bin/python3.9`, argv `python3 -B <root>/run-query.py`, cwd `<root>`. Tool hashes are recorded bindings, not new measurements of the remote installation.

Compared the actual predecessor and successor sources, not just `runtime-retarget01.diff`. The complete runner is byte-identical after only exact root/module, result-buffer, result-label and completion-expression substitutions. The gate differs only by exact root/module, permission and rejection identity. Dispatcher equality holds after exact root/module retarget, with the new cwd branch first (`ia840f_experimental_gate.py:289–305`). No supervision control-flow change is hidden in this retarget.

Recomputed the complete normalized inventory delta: **one addition, nine changes, no removals**, equivalent links. This equals `predecessor-delta-verification02.json` exactly. Seven changes are direct authored/gate bindings; the other two are documented `mem_ss.xml` and `ofs_top.qar_info.json` text relocations. Both relocation receipts reconcile their identical before hashes and respective after hashes; both link relocations reconcile. All **81 SDC** and **1,265 QDB-path/file** bindings remain equal. These are inventory comparisons, not fresh reads of every remote file. Actual helper, top.sdc and constraint-delta exports equal the predecessor bytes; preservation digest remains `ba54fad92731357ffa65f163bdb402f133d3841f5e90660df752ac98f18394af`.

## 2. Query correctness and failure semantics — accepted

- **Unchanged baseline and routing:** `query.tcl:64–85` checks exact cwd, rejects spent reports, exclusively creates the audit, opens only `ofs_top`, checks the project-gate failure sentinel, then performs normal netlist creation, argument-free `read_sdc` and update. No repair `apply`/`verify_created`, second SDC load, timing-path sweep or fit is called. The helper remains definitions-only; `created` must be false and C absent. Procedure/namespace-local temporaries avoid the earlier global `pins` collision.
- **Clock properties:** `:28–40` emits the clock count before cap256. Generated-only properties are confined to `generated`/`virtual_generated`; base types record `not_applicable`, unexpected types reject. No blanket Warning22890 suppression is added. Existing lookup `-nowarn` options do not catch API errors or invent empty results.
- **Two declared roots, not fallback:** `:86–99` uses the helper's validated one-output-clock-pin collection O, then independently resolves exact K through both keepers and registers. Full-name/count checks remain strict; indexed names are escaped before pattern lookup (`:13–25`). There is no `clock_div2x` substitution, root broadening or fanout `-stop_at_clocks`. Genuine collection handles, not individual iterator handles, are passed to collection-consuming commands.
- **Truthful count ordering:** pin count emits and flushes immediately; the independently obtained keeper count also emits before either load-range decision (`:90–102`, `emit:10`). A keeper/API failure may stop after the pin count; it cannot fabricate a keeper count. The old missing count is not reconstructed.
- **Complete sets or explicit failure:** `enumerate_loads:42–58` treats zero as a complete empty set and counts above4096 as incomplete/unavailable, skips only that enumeration, and retains the other planned observations. Every enumerated full name is retained without prefix/FIFO filtering and receives an exact keeper lookup plus actual `get_clocks -of_objects` association. Raw, enumerated and unique counts must agree; sorting/deduplication cannot silently qualify duplicates. Both roots can contribute up to4096 enumerated loads each. This is an enumeration/output bound, not a bound on native graph traversal before counting.
- **Set and known-receiver checks:** `:103–159` emits full pin-only/keeper-only lists and intersection count only for two complete sets; otherwise relation is unavailable. Each known cell and clock input is exact-resolved. Reverse fanin count is emitted before cap32 and the baseline requires exactly one K. Four groups require eight each plus full name-set equality; duplicate known cells reject. T is independently resolved, with both memberships and actual clocks. These checks cannot be replaced by count-only evidence.
- **Completion is not support:** `:160–168` separates completeness from support. Both empty sets or missing known membership can complete observations with false support; cap/duplicate failures prevent the diagnostic marker. API/identity failures propagate. The marker is exactly `IA840F_FANOUT_DIAGNOSTIC_COMPLETE`, after audit close and netlist/project cleanup, and is distinct from the old comparison marker. Even positive support flags do not validate a collector.

Independently parsed all32 manifest cell/pin records and matched them to `known-receivers-provenance.json` and Query02's actual CELL, input-clock-pin, reverse-fanin and count1 records. There are32 unique cells/pins and four groups of eight. Query02 log SHA256 is `6d934bb5862574a6518fc5803d051757eefcb88a3caaf2f7db44850971460b89` (`qualification/fim-build-14/pcie-postfit-02/result-readback01/query.log:513–702`). T matches the prior baseline's **Info13166 under Warning332060**, not a Warning13166 (`Z/baseline/result-readback01/query.log:493–494`).

The saved installed help supports the finite API choices: `api-help01/commands/get_fanouts.txt:29–40,67–75`, `get_fanins.txt:29–44,59–68`, `get_keepers.txt:24–38`, `get_clocks.txt:38–42`, `get_clock_info.txt:44–54`, and `api-help02/commands/get_pins.txt:26–45,63–70`. The source diagnosis and the seven checked help01 command hashes reconcile. Help and historical reverse fanin justify this observation, not an assertion that native O/K sets will agree.

## 3. Whole-lifetime supervision, gates and preservation — accepted

The inherited Q1 analysis remains applicable to the verified corresponding bytes; `Z/quality-review01.md:27–37` was read and its SHA256 verified as `e9c42ba465b7af2c69c8f131a031646ea002be2e47f7a594d32f3351d6875363`.

- `run-query.py:312–316` calls **main_supervised**, not the retained legacy `main`/`wait_bounded`. `supervise_native:141–159` checks wait support/SIGCHLD, exclusively reserves metadata before spawn and immediately protects the successful child lifetime. Metadata dump/flush/close and wait-loop exceptions enter cleanup.
- `:160–248` observes exit with `WNOWAIT`, retaining the leader's PGID identity through all TERM/KILL/drain operations. Normal raw0/7 leader exit with live descendants is not completion. Drain requires observed leader exit and two quiescent samples before confirmation; reaping occurs only after all possible group signals. Inspection/reap uncertainty remains explicit failure, not assumed termination.
- Available raw status is stored in `native-result.json` before fallible postflight (`:274–300`); abort status, native status and effective status remain distinct. Postflight errors cannot convert native failure into success. Storage/export failures can leave incomplete receipts, but do not release the claim or fabricate acceptance.
- Exclusive claim/log/metadata/result creation and spent-artifact rejection remain. The runner checks host, UID1000, the executing pane's owned `ia840f_mailbox_monitored_01` session, exact runner identity and no competing quartus_/qsys- process (`:252–274`). Wall1800s, RLIMIT_AS64GiB, individual-file128MiB, report-total1GiB and minimum MemAvailable80,000,000,000bytes remain; preparation additionally requires20,000,000,000bytes free.
- `ia840f_clock_fanout01_gate.py:10–41` retains live PID/PPID/start-tick/executable/argv/cwd claim comparison, callback ancestry, exact native executable/argv/cwd and file/link hash checks. Missing authorization rejects before launch. This review does not issue that authorization.
- `prepare02.py:45–59,106–108` checks the bound Work14 results, inventories Work14/SOURCE/PIM, verifies initial copies and compares originals afterward. Scratch relocations and gate wiring are distinct from maintained-source modification. Runner postflight requires three literal-true preservation comparisons.

The saved actual preparation tests equal the archive's `D/tests.json`: runner and dispatcher each rc1 for missing reviewed authorization, initial-copy equality and unchanged originals, `vendor_launched=false`, `authorization_issued=false`. These captures are not native diagnostic results.

## 4. Preparation correction — verified, history preserved

`prepare02.py:8–10,49–50,117–121` fixes the stale relative root, starts OWNED false, sets it only after successful exclusive leaf creation, and restricts failure-receipt writing to that owned leaf. Fresh02 input/script/export identities are explicit. The permitted preparer fixtures reproduce both prior defects and verify corrected root agreement and no new file on successor rejection of an existing leaf.

The historical preparation01 failure remains distinct: it rejected before copying/native work but appended a new error receipt to the unowned old phase. It is incorrect to say the entire old phase received no new file. Independently matched all21 `preflight02.json` prior-artifact hashes to accepted local prepared/result files; the saved preflight records the new leaf absent and retains the appended error. Earlier AST/import-only verification is not treated as proof of root agreement. No failed preparation was rerun here.

## 5. Independent permitted replay

Executed with `python3 -B`, cwd `/home/joe`, without redirecting output into retained receipts. Every invocation returned **rc0 with empty stderr**; parsed counts, pass flags, source hashes and the complete JSON results equal the saved current receipts.

| Fixture | Passed | Receipt |
|---|---:|---|
| `test-query.py` | 18/18 | `query-tests02.json` |
| `test-query.py --prepared` | 18/18 | `query-prepared-tests02.json` |
| `test-supervision.py` | 11/11 | `supervision-tests01.json` |
| `test-preparation.py` | 4/4 | `preparation-tests02.json` |

The Tcl fixture sources the actual full query/helper/known data with mocked package/filesystem/vendor APIs; prepared mode checks current candidate cwd and query/helper/known-name file/callback hashes. Cases cover empty/equal/subset/missing sets, each cap branch, duplicate loads, missing/duplicate keeper root, group/reverse drift, API error, preexisting C, wrong/old cwd, spent reports and project-open sentinel. Exact argv was separately reconciled against the candidate.

The eleven supervision cases exercise the current runner's main_supervised with real inert children and mocked gate/host/resources/tmux. All returned without a live owned child; heartbeat stopped and spent reruns preserved every evidence byte without a second spawn. Leader-with-descendant cases retained native0/7 and effective124; persistent inspection failure retained effective124 and `termination_confirmed=false`. Metadata failure, wall/output caps and wait/inspection errors cleaned up. This is not a vendor result.

Fixture SHA256 values: query `1131838518fa8b9d2493a88256601536a93cec53320965c96dc03ebf998f1ce9`; supervision `432500338bd8f40c3009806e2f09e14828b6bb87e34aed38dc3ebe59dc402cc9`; preparation `e1fa8b992144eb1cf0a642607420431f00ee48a946ae6b88b3659be8d6d531c4`. Supervision/preparation fixtures use authoring files proven byte-identical to D. The historical `test-query-source01.py` still matches its historical receipt. Prepared Python exports parse with Python3.9 grammar; this is not native Python3.9 execution proof.

## 6. Blockers, nonblocking notes and disposition

**Blocking QUALITY findings: none.** No package changes requested.

Nonblocking notes and limits:

1. Inert Tcl collections are mock lists and clock associations are mocked. The suite is not native collection/API proof or exhaustive fault injection: exact cap boundaries, every missing pin/type variant, each API error location, metadata flush/close and reap failures are not separately exercised. Those paths were inspected statically; successful new native measurements are not prerequisites to approving this unrun observation package.
2. For an incomplete set, `member` returns `unavailable`, while `MISSING_KNOWN` includes names lacking confirmed membership. A consumer must use `SET_STATUS` and per-receiver membership fields, not interpret that list alone as proven absence. The query correctly makes relation unavailable, support false and completion fail in that case.
3. Supervision is ordinary same-group Linux process control and source-bound validation, **not an OS sandbox**, aggregate memory containment, protection against arbitrary supervisor/kernel failure or containment of deliberately escaped descendants. The4096 cap does not bound native traversal itself. No stronger claim or new generic containment framework is required here.
4. Normal SDC loading may expose original paths embedded in fitted databases. Loaded-file identity, raw diagnostics and preservation must be reconciled in actual-result review; no opaque-QDB rewrite or suppression is authorized. This narrow diagnostic intentionally does not produce the later full A/B timing reports.

Parent exact-binding consumption and a **separately inspected one-use issuer** still precede any native diagnostic. Actual-result review must independently check native/effective/outer status, literal-true termination, all counts/caps/errors, loaded SDC identities, complete sets and support discrepancies, and original-tree preservation before selecting a future full A/B collector. Diagnostic completion cannot satisfy experiment03's comparison-baseline gate; its candidate remains unissued/blocked. The failed baseline's missing count remains unknown between zero and greater-than4096; fitter355 is not an STA count.

A later A/B package still needs whole-domain/out-of-prefix and propagated-clock coverage, understood set/global-transfer changes, all eight numerical FIFO assignments, exception precedence, all corners, unconstrained paths and truncation checks. Existing asynchronous cuts and multicycles earn no new safety credit. No maintained repair, refit, timing/CDC/DRC, DDR, OPAE/backend, recovery, persona or durable-boot qualification is granted; historical exclusions are not reopened.

All52 pre-existing F files in the frozen review set were rehashed unchanged after replay; mutable `CURRENT.md` was excluded and was not edited. No blocking issue was encountered. The retained preparation01 defect is addressed by the exact preparation02 bytes, not erased from history.

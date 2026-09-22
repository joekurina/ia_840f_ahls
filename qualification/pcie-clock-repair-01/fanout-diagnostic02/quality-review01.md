# Independent QUALITY review — exact prepared Work14 fanout-diagnostic02

## Verdict: APPROVED

**No critical or important blocking implementation defect found in the exact `prepared-readback01/` package. No package changes requested.** This verdict covers implementation, failure handling, mechanical retargets, inherited supervision and local testing of the bounded unchanged-SDC diagnostic. It is **not authorization, native-result acceptance, collector validation, successful A/B evidence, source repair, timing or hardware qualification**. No unseen issuer or future launch is approved.

### Scope and citation convention

- `N`: `/home/joe/Projects/Thesis/AHLS/new_bsp/new`.
- `R`: `N/qualification/pcie-clock-repair-01`; `G`: `R/fanout-diagnostic02`.
- `D`: `G/prepared-readback01`, the actual review target. Unqualified implementation citations below refer to **D**, not merely the authoring copies.
- `F`: `R/fanout-diagnostic01`; its accepted prepared predecessor is `F/prepared-readback02`.
- `Q2`: `N/qualification/fim-build-14/pcie-postfit-02`.
- `H0`: `N/qualification/fim-build-08/pcie-postfit-query-01/api-help2.log`; `H1`: `R/api-help01/commands`; `H2`: `R/api-help02/commands`.
- All citations use original 1-based text lines. Complete JSON inventories and fixture outputs were parsed, not inferred from excerpts.

Only local reads, hashing/parsing and the four explicitly permitted inert fixture invocations were performed. No remote, native/vendor/help, standalone preparer/runner/gate/issuer entry, authorization, hardware, git or task-state operation occurred. The fixtures' expressly permitted mocked entries and owned temporary inert children are not vendor execution. This report is the only authored persistent project file; saved receipts were not overwritten.

## 1. Consumed SPEC prerequisite and exact package — verified

Read all 136 lines of `G/spec-review01.md`, including its limitations, source citations and preservation evidence. Recomputed its SHA256 as `94ef36a0a39a9c09fef580f2250275a9074f63dfa34da615624c785f0450d5d7`. Recomputed `G/parent-spec-consumption01.json` as `7a64d00b3bfd950f1c41b898b82214528ade26c3109e685f5ecea3f66db0ed11`. Every file binding and prepared-export digest in that consumption record matches local bytes. Its scope is consumed SPEC, not QUALITY or permission (`G/parent-spec-consumption01.json:3–18,65–80`).

Independently decoded gzip/JSON/base64 and verified batch `ia840f_clock_fanout02_preparation01`, the exact **15-export** name set, sizes, hashes and byte equality against both manifest and readback. All **eight corresponding authoring files** equal their exports. Archive SHA256 is `d2541de0791d6c5da4f017279ea74ae9b3cb0be32629900a5be8112018ef05cc`, size **1,433,796 bytes**; manifest SHA256 is `69db4cf4a1b7c343ae9f607c9273a08473e1ed2cfcaf88c372c57872b767461f`.

| Actual prepared export | Independently recomputed SHA256 |
|---|---|
| `AUTHORITY.md` | `490d86e3d64bf7e58be4ae6d5d003ff821621f2de1dbf0d409e1055d578bbbb7` |
| `SPEC.md` | `2d8d91fad67d98d240b403ec3b487902584ccc1c723984efaaa8b79a27326e9a` |
| `candidate.json` | `a2a1ac74a55d76c5786be5c75517a2860bd53fe4ffc3e0f18720824ac6c77270` |
| `clock-repair.tcl` | `8486a48acbe4f024beecefb95d09eeab69ce0331d3f16d4a1f9c0591cdb117f2` |
| `constraint-delta.json` | `36be33c6f8a37a730e6c48fac1a0e089539354bab25eb01cedd78d076535ed1b` |
| `ia840f_clock_fanout02_gate.py` | `146314cf4d01ed8cf3ff06fb67c705aa8ff55757a8d0a350c5a2368770f02307` |
| `ia840f_experimental_gate.py` | `7fd44b22cbb6df4ce029d16e08e1db2791184202e405a37f48528f76d2b2b73b` |
| `known-receivers.tcl` | `3bca69f770cba775919b7134822ae5eedcb324c1a25ed5540b781667d798ef6a` |
| `path-relocations.json` | `df0f7528e1192657e5f6669de9d0829217220ddb34f2ed0a4e08b27d085696ce` |
| `prepare01.py` | `30ade2612c5f26b432813ba20249e186f8ef828b2157a66f490a3710412e84a8` |
| `preservation.json.gz` | `ba54fad92731357ffa65f163bdb402f133d3841f5e90660df752ac98f18394af` |
| `query.tcl` — 198 lines | `de849ce56c3ae6db993a1e27d427c574cf6cccb7b7d68272a1c0ca8ab2468e5c` |
| `run-query.py` | `3735fc3d24ce9c3bf94de92159284858dc2a12fc69c6d2a5e0df32b866be8475` |
| `tests.json` | `0f0a2887dc73e6e87ce860b40c27006b011bbed3cd3398b55f9543c24ee2a69e` |
| `top.sdc` | `8255b34c200a46178174b9788bdc9231072ae829f57c34703cc63dd28ab66c3d` |

Recounted **7,885 file bindings / 7,762 callback bindings / 10 links**. Callback coverage is exactly the full file map excluding `.qpf`, `.rpt`, `.log` and `.summary` suffixes. Verified the ten root exports that the candidate actually binds, copied gate and dispatcher bindings in both maps, and scratch top-SDC binding. Receipt/preparer exports are manifest-bound; they are not falsely counted as candidate inputs (`prepare01.py:91–113`).

The exact remote root is `/home/uwb_student00/ahls/new_BSP/qualification/pcie-clock-repair-01/fanout-diagnostic02`. Candidate command is `/opt/altera/26.1.1/quartus/bin/quartus_sta -t <root>/query.tcl`; native identity is `/opt/altera/26.1.1/quartus/linux64/quartus_sta`, argv `quartus_sta -t <root>/query.tcl`, cwd `<root>/scratch/syn/board/ia840f/syn_top`. Runner identity is `/usr/bin/python3.9`, argv `python3 -B <root>/run-query.py`, cwd `<root>`. `approved=false`, `ready_for_build=false`, target `ia840f`, part `AGFB027R25A2E2V`, permission `exact-offline-fanout-diagnostic02` remain intact. Tool identities here are verified recorded bindings, not new measurements of the remote installation.

## 2. Retarget and preparation implementation — accepted

Recomputed the complete unified diff directly from F/G bytes; it exactly equals `G/runtime-retarget01.diff`, SHA256 `ff834d840cc6591b54c8a00ea967ec73005dbb85f1731d726372c0db520c7470`. F authoring runtime/preparer/gate files equal the actual accepted predecessor readback; corresponding G files equal D. After only the declared root/module/rejection/permission/result-buffer/result-label/completion-marker substitutions, the runner, gate and dispatcher match their predecessor bytes. The preparer diff is the displayed retarget, filename and preservation-export addition, not a new preparation algorithm (`G/runtime-retarget01.diff:1–178`).

Normalized only successor root/module names in candidate keys and links. Recomputed **exactly nine changed file bindings, no added or removed file keys, and equivalent links**, equal to `G/preparation-verification01.json:30–70`. Changes are SPEC, AUTHORITY, query, root runner/gate, copied gate/dispatcher and the two relocated metadata files. The preservation export was already candidate-bound in F; adding it to transport did not silently broaden runtime inputs.

- `prepare01.py:34–50` retains host/UID/session/optimization checks, payload digest/scope, fresh-leaf rejection, RAM/disk/no-competing-native checks and bound Work14 evidence. `mkdir(parents=True, exist_ok=False)` owns only a fresh leaf; `OWNED` becomes true only afterward.
- `:51–59,106–108` retains original Work14/SOURCE/PIM inventories, initial copy comparison and original after-comparison. `:117–121` permits a failure receipt only in the leaf this invocation owns; it does not append to an unowned spent predecessor. The allowed actual-preparer rejection fixture exercises this branch.
- `ia840f_experimental_gate.py:289–305` puts the exact successor `quartus`/cwd branch before inherited compile/setup dispatch. Removing just that inserted block reconstructs the original Work14 dispatcher SHA256 `6d40de976fde2caec77a264e46d29a89ea94aebbe9e542edac55555f69626e94`; no unrelated dispatcher behavior changed.
- Saved `tests.json` matches the archive and preparation-verification receipt: actual runner and dispatcher each rejected missing authorization with rc1; initial-copy equality and unchanged donors are true; vendor launch and authorization issuance are false. These are saved preparation observations, not fresh remote checks or a native diagnostic result (`prepare01.py:101–108`).

Parsed the full exported preservation inventory: Work14 **7,346**, SOURCE **1,656**, PIM **536** entries. Candidate PIM equals its recorded original inventory. Scratch has no removals and only the added copied successor gate; changes are exactly the dispatcher insertion, **two links and two non-SDC text files** in `path-relocations.json:2–20`. Every recorded old/new value reconciles. Scratch/original/exported top-SDC hashes agree; no SDC or opaque database edit is present in that inventory delta.

Reconciled all **five literal original-Work14 QDB proxy SDC paths** in F's consumed loaded-path record against the original preservation inventory and G's copied candidate hashes. Each agrees. This is stronger saved-inventory reconciliation, **not per-open hashes, an access trace, or proof that a future native session opens scratch rather than the literal original paths**. Nothing here relabels those historical paths or claims fresh remote preservation (`SPEC.md:33`; `G/spec-review01.md:85–91`).

## 3. Query implementation and failure paths — accepted

The source diagnosis separates filter semantics from physical/timing representation; the consumed F result is rc3 and incomplete, not absence proof. Its review/research/consumption hashes were rechecked. G addresses those two questions without treating native success as a circular prerequisite (`R/forward-lookup-diagnosis01.md:5–9,70–85,124–134,150–180`).

| Implementation area | QUALITY finding and actual source |
|---|---|
| Entry and unchanged baseline | Namespace/procedure-local state avoids global SDC variable collisions. Exact cwd and spent-report checks precede project open; audit creation is exclusive. Gate sentinel, ordinary netlist/argument-free SDC/update ordering, absent C and helper-created=false are retained. No repair apply/verify, second SDC load, clock creation, mode setter or fit is called. `query.tcl:6–14,73–94`. |
| Native handles and exact roots | O uses the unchanged helper's one-pin cardinality/name/direction/clock-pin validation. K independently resolves as exactly one keeper and one register. Collections stay collections and iterator objects stay object IDs. No physical-cell string is required to become a keeper; no alternate root or `clock_div2x` fallback exists. `query.tcl:19–49,92–96`; `clock-repair.tcl:18–25`. |
| Count retention and complete sets | All four predeclared calls are explicit, each followed immediately by flushed raw count output. Cap4096 bounds enumeration, not native traversal. `observe` retains all in-cap names and rejects count/enumeration/uniqueness defects without hiding duplicates. A cap produces an incomplete record, not a successful empty result. `query.tcl:12,26–40,97–108`. |
| Relations and membership | Full a-only/b-only/intersection records are computed for the three declared pairs using exact-name membership; incomplete inputs yield unavailable relations/membership. Zero sets remain legitimate complete diagnostic data. Extra/out-of-prefix members are not filtered away. `query.tcl:51–58,109–117`. |
| T and selector matrix | T's identity/membership/clocks and all six first-known-name raw/transformed lookups precede physical-group decisions. T mismatch marks incomplete while allowing the selector matrix. The transformed pattern is only a hypothesis; there is no selected winning matcher or mode mutation. API exceptions propagate. `query.tcl:118–136`. |
| Physical groups | Four fixed full-hierarchy cell patterns require their complete expected eight-name sets, not just count8. Cap128 and uniqueness checks occur before mapping. A bad group is marked incomplete/skipped while other groups continue. Global visited/unique counts require all32 exactly once. `query.tcl:137–158,187–190`. |
| Cell-derived pins and reverse checks | Actual cells supply the pin collection; actual pin names/properties select input-clock pins. The saved single pin and exact reverse K are checked, with cap32. The reverse query receives a native pin ID in the same call shape already exercised by Q2, not an invented collection. Type/pin/reverse defects prevent completion while available later observations continue. `query.tcl:154–173`; `Q2/prepared-readback01/query.tcl:24–54`. |
| Buried-register mapping | Actual `get_cell_info -buried_regs` collections are counted and enumerated under cap32. Only real nonempty collections feed clock association; every returned register gets name/type/membership records. In-cap zero/multiple/alias mappings remain data and set the single-register flag appropriately. API errors are not converted into zero or empty success. `query.tcl:174–184`. |
| Clock inventory and completion | Up to256 clocks; generated-only properties are guarded by type, base clocks record non-applicability and unknown types reject. Explicit targets remain separate from driving associations. The final diagnostic marker follows complete checks, audit close and project/netlist cleanup; incomplete/API/cleanup failure cannot reach it. `query.tcl:60–71,189–195`. |

Source support was inspected, not merely cited: H0 documents actual cell-derived pin/buried-register collections and default level-by-level absolute hierarchy matching (`H0:519–537,549–557,589–653`); H1 documents same-root default versus clock-filtered traversal, collection-based driving/target association and register name/type (`get_fanouts.txt:17,29–40,67–85`; `get_fanins.txt:17,29–44,59–77`; `get_clocks.txt:12,38–42`; `get_register_info.txt:15–25,37–43`). No design-specific buried-register cardinality is assumed. H2 documents escaping setters and ordering, not an invented read-mode API (`use_timing_analyzer_style_escaping.txt:3–10,22–31,52–60`).

Independently parsed the complete known-receiver manifest and provenance and compared them with Q2's raw log: **32 unique physical cells and saved clock pins, four groups of eight, all `tennm_ff`, all32 reverse fanins exactly K with count1** (`Q2/result-readback01/query.log:513–702`). This validates the reused historical identity evidence, not a new forward collector or the completeness of the whole affected clock domain.

## 4. Whole-lifetime supervision and gates — accepted unchanged

Read F's accepted QUALITY reasoning (`F/quality-review01.md:58–69`), SHA256 `ee30a3a2902a0d0585bc95dd4f057529dfd20dacb8aa4f12d5e06b58a73ee784`, and independently inspected the corresponding actual G implementation. Exact retarget correspondence makes that inherited reasoning applicable; no generic supervisor redesign is required.

- **Actual CLI entry:** `run-query.py:312–316` calls `main_supervised`, not retained legacy `main`/`wait_bounded`. Wait API and SIGCHLD preconditions, exclusive metadata reservation before spawn, and immediate post-spawn try/finally protection remain (`:134–159`). Metadata write/flush/close or supervision exceptions cannot simply bypass child cleanup.
- **Owned lifetime:** normal leader exit is observed without reaping via `waitid(...WNOWAIT)`. Live same-group descendants make raw0/7 a failure requiring drain. TERM/KILL and two quiescent samples precede reaping; no later group signal can target a reused PGID. Persistent inspection/reap uncertainty remains explicit failure, not assumed termination (`:117–131,160–248`). Zombies are distinguished from live writers (`:24–31`).
- **Status and evidence:** available raw status and supervision state go into `native-result.json` before fallible original preservation/report capture. Native, abort and effective statuses remain distinct. Postflight errors cannot turn failure into success; missing/duplicate marker, selected native/gate diagnostics, report caps and original mismatches reject. Exclusive evidence and the claim remain after failure (`:263–309`). Storage/export failure can leave incomplete receipts, but cannot authorize a rerun or create acceptance.
- **Bounds and context:** exact host/UID/owned executing tmux pane, runner executable/argv/cwd, source/link hashes, live claim identity and callback ancestry remain. MemAvailable80,000,000,000 bytes; wall1800s; RLIMIT_AS64GiB; individual-file128MiB; reports1GiB; preparation disk20,000,000,000 bytes; competing quartus_/qsys- rejection remain (`run-query.py:252–274`; `prepare01.py:41–50`; `ia840f_clock_fanout02_gate.py:10–41`).
- **Permission separation:** missing or nonexact authorization fails before native spawn. Runtime compares parent executable/argv/cwd and the live runner chain, not a stage label. `ready_for_build` must remain false. The new diagnostic completion marker is not the old comparison marker (`ia840f_clock_fanout02_gate.py:25–41`; `run-query.py:291`; `query.tcl:189–195`; `AUTHORITY.md:5–9`).

## 5. Independent permitted fixture replay — 63 passing rows

Executed exactly the following commands with cwd `/home/joe`, capturing stdout/stderr in memory, without redirecting over saved receipts. Every invocation returned **outer rc0 and empty stderr**. Parsed full JSON, source/test digests, row pass flags and declared counts equal the saved receipts; stdout SHA256 also equals each receipt's SHA256.

| Command | Passed | Complete output matched |
|---|---:|---|
| `python3 -B /home/joe/Projects/Thesis/AHLS/new_bsp/new/qualification/pcie-clock-repair-01/fanout-diagnostic02/test-query.py` | 25/25 | `G/query-tests01.json` |
| `python3 -B /home/joe/Projects/Thesis/AHLS/new_bsp/new/qualification/pcie-clock-repair-01/fanout-diagnostic02/test-query.py --prepared` | 25/25 | `G/query-prepared-tests01.json` |
| `python3 -B /home/joe/Projects/Thesis/AHLS/new_bsp/new/qualification/pcie-clock-repair-01/fanout-diagnostic02/test-supervision.py` | 11/11 | `G/supervision-tests01.json` |
| `python3 -B /home/joe/Projects/Thesis/AHLS/new_bsp/new/qualification/pcie-clock-repair-01/fanout-diagnostic02/test-preparation.py` | 2/2 | `G/preparation-tests01.json` |
| **Total** | **63/63** | **No receipt rewritten** |

Query replay sources the actual main entry with distinct `COL` collection handles and cell/pin/register namespaces. It covers aliases and two explicit matcher scenarios, same names, zero/default/duplicate/over-cap sets, zero/multiple/failed buried mappings, group/type/pin/reverse/root defects, preexisting C, wrong/old/spent paths and project/gate errors (`G/test-query.py:18–24,82–153,157–193`). Early API failure retains only observations actually reached; for example fanout failure leaves one flushed forward count and no fabricated later data.

All eleven supervision scenarios returned with no live owned fixture children; heartbeat stopped, rejected reruns preserved evidence bytes, and no second spawn occurred. A zero-exit leader with a surviving writer retained native0/effective124; a nonzero leader retained native7/effective124. Persistent inspection failure retained `termination_confirmed=false` and effective124. Metadata/wait/wall/output-cap cases cleaned up (`G/test-supervision.py:119–146,153–174`). Its full difference from F is only the expected completion marker. Preparation replay verifies evaluated roots agree and the unowned existing leaf stays unchanged (`G/test-preparation.py:8–39`). All ten Python sources across G's root and D parse under Python3.9 grammar; this is not Python3.9 native execution proof.

Fixture SHA256 values: query `afd8b37c2d61cfec132210608ae021b7173949ab3cdf339f51b43e7c5a7c1d2e`; supervision `f5f22b56d486ed49f575d49f431fcf70f3abe69b0071c97d3bb13f64138df15d`; preparation `d0b5627173b725dc62a824deaaed69554f1f453a7c8c49b9d56c12a75ec97b8b`. Supervision/preparation exercise authoring files independently proven byte-identical to D.

## 6. Blocking findings versus nonblocking limitations

**Critical blockers: none. Important blockers: none. No requested changes to this frozen package.**

Nonblocking notes and limits:

1. **Tests are control-flow fixtures, not Quartus emulation.** Matching, graph traversal and clock associations are synthetic; `get_registers` delegates to the mock keeper lookup. The mock register type is `register` (`G/test-query.py:121–125`), whereas captured native help says `reg` (`H1/get_register_info.txt:41`). The implementation only records this value, so it does not depend on the mock spelling; native output must be interpreted from actual evidence. Filtered-positive/asymmetric full relation contents, exact cap boundaries, count/enumeration disagreement, every API failure location, metadata flush/close, reap and postflight storage failures are not all separately asserted/injected by these four suites. Relevant branches were inspected statically; the passing total is not exhaustive fault coverage.
2. **Incomplete data must not be read in isolation.** `observe` can carry empty `names` with `complete=0` on overflow; `clock_names` returns those names after the global incomplete flag is set. Use retained COUNT/INCOMPLETE and final diagnostic status, not an isolated empty association as absence proof. `mapping_single_register_each` also does not override overall incompleteness or prove clock-domain coverage (`query.tcl:26–43,174–190`). Completion correctly remains blocked in these cases.
3. **Source-bound supervision is not an OS sandbox.** It controls ordinary same-group children, not deliberately escaped descendants, aggregate memory consumption or arbitrary supervisor/kernel failure. Enumeration caps do not bound the native traversal before collection return; inherited wall/resources bound that experiment. Saved tool/source identities are not present remote-state evidence.
4. **Preservation and loaded-file provenance remain different claims.** Full saved original/copy inventories and the five historical proxy references reconcile, but no per-open hashes/access trace is claimed. A future native result still requires literal-path/diagnostic/status/termination/preservation review. A filename containing an original root is not renamed a scratch open by this report.
5. **Inactive future-candidate helper defect remains excluded, not approved.** `clock-repair.tcl:45–56` wrongly conflates upstream driving M at O with a generated-clock definition there. Neither `apply` nor `verify_created` is called in this observation; `SPEC.md:7` explicitly disclaims later candidate readiness. Fixing or authorizing that future path is not required to run this distinct unchanged-SDC observation, and this approval grants it no readiness credit.
6. **No scientific outcome inferred.** Documented buried-register behavior on these cells, real matcher outcomes and default-versus-filtered fanouts are experimental questions. Zero or positive counts, known32/T membership, or the diagnostic marker do not qualify a clock-only collector. Full A/B, all affected identities, timing/CDC/DRC, source repair and hardware/mission gates remain unresolved and outside this review.

## 7. Source hashes and frozen-file preservation

Additional independently recomputed source/evidence bindings:

| Evidence | SHA256 |
|---|---|
| H0 | `9ee495aad959b7119eb422b05ecef69345ecda80a7ab87f17d450f6b5d83b6d4` |
| `H1/get_fanouts.txt` | `09a71a0d9b786b8f1107fdd985714e18cf532fbee844c5c83511f564e28ae765` |
| `H1/get_fanins.txt` | `ae8f82a73242cc5f3a7eb9cfbfd8605dfd74e06d9f0b31582afddf5dc21b346b` |
| `H1/get_clocks.txt` | `b06a7efaebb9f06e161c469801a34b6d296506a827dad2db0a423a1ba5367980` |
| `H1/get_register_info.txt` | `402e81385d1f2c39db6c53244f46b2e6f561598f19effc3aa83a98950b095398` |
| `H2/use_timing_analyzer_style_escaping.txt` | `c4d12abc7ee429a3d078d4d2be11769754baa285b0288eca7f9e3d783f0d8b18` |
| `Q2/prepared-readback01/query.tcl` | `c2acd70013ff567004a77199ebc22a977aeb48af03b83c740c8eda24129a333d` |
| `Q2/result-readback01/query.log` | `6d934bb5862574a6518fc5803d051757eefcb88a3caaf2f7db44850971460b89` |
| `R/forward-lookup-diagnosis01.md` | `55a23ac37c58caeb96204e8c552c5cf6ab5e085fd0adeec1993dbfd560f0acf8` |
| `F/result-independent-review01.md` | `ba605b71b16adfb5eaae517a995e8118cb68c05bfb05d7c644d67604af754a51` |
| `F/parent-result-consumption01.json` | `bbc8b7fa8a736bbcdfd9ed999801d4f4c658a1834256fe02114a83c617920fe2` |

Before reads/fixtures, independently reconstructed the **40-file frozen G inventory** and matched the SPEC review and parent consumption inventory hash. Rehashed the same complete set after replay and review: **40 unchanged, no missing frozen file**. Both inventory SHA256 values are `666db7de22bff39b971669d528bd6444107fd12c5edccc4dccf55c2e9dca762a`, computed over UTF-8 `json.dumps(relative_path_to_sha256, sort_keys=True, separators=(',', ':'))`.

Mutable `CURRENT.md`, SPEC/consumption/reviewer reports and separately named future evidence are outside that frozen package. Parent-added `launch-source-inspection01.json` appeared during review; it was not read, modified or approved here. No frozen package file was added, removed or changed by this reviewer. The consumed SPEC and parent record bindings were independently verified as stated above.

## Disposition

**APPROVED for this exact manifest and candidate only.** Parent exact-binding consumption and the separately inspected one-use issuer barrier still precede native entry. Any frozen-package change invalidates this verdict. A future native attempt must receive independent result review; no unseen issuer or result is approved. F remains spent, experiment03's candidate remains unissued/blocked, and `ready_for_build=false`. No commit or task closure was performed.

# Independent QUALITY review — exact prepared experiment03 A/B

## Verdict: APPROVED

**No blocking implementation defects found. Predecessor Q1 is closed for the actual CLI path; the S1 routing correction is verified on both exact prepared packages.** Approval is limited to implementation quality of this bounded offline STA experiment, not authorization, native-result acceptance, timing closure, source promotion, a refit, or hardware qualification. A future issuer is not implicitly reviewed.

Prerequisite independently hash-verified: `spec-review01.md`, SPEC PASS with S1 closed, SHA256 `4a5f9512451e3863f2240cf567edd9e40df00bff288ab985a61f3dc891f900a8`. Parent consumption SHA256: `c08e636b5fb73be2ef9c1f2ea61c2c6ad542038d91c109f39c7e891e861e003a`. The original experiment01 QUALITY rejection was read and its supplied SHA256 `4b1b771d5743464f2383df47f319009394fb17f61d93b1b19aab4abd86d7bd8f` verified.

## Exact reviewed identities

Targets are `baseline/prepared-readback01/` and `candidate/prepared-readback01/`, with their sibling archives and manifests—not an assumed unchanged remote tree.

| SHA256 binding | Baseline A | Candidate B |
|---|---|---|
| `preparation01.json.gz` | `9de4c688f891c0e223b45fb0a1c47336b89eb4eaa2ca20444a996dffae4d4e8b` | `6bae03e93ac2676986d73222f08b41d4ed437e50a944afd20ae967d9e18e6a28` |
| `prepared-manifest01.json` | `f40688e915bb01f07759aa9b23aa6a7e216fc65c3905f8e7d99efbf702479b08` | `f32f1bd103131a7a770dcf675cddea6388b238c60c4b4dce7374f86f954a0221` |
| Actual `candidate.json` | `9d63cb5e78488b60df449514e2b2967d1694fa7a872fefbfa8d78b951beb3719` | `aa3d57f743b0db7450db1df48e0f796cc97a97aede2298c6d36f85ff51beac0e` |
| Actual `run-query.py` | `0a2f215c4440c8aa1d11a4cbcf5f047c0f6c64fcf3415c4790b8a9bdab9f9018` | `631ed0878d8f2d343e8449b7cb20ff38cbe11ad2fb2960128ad46275dbc40efc` |
| Actual phase gate | `881071cb30b238f70c54f20c9e3bfe6e8f4c9c040954d79e3845a136c3f3196d` | `f2c4d20179e4188d8f64331f9dc9e31c827cf0c7c05cbb263c1f5ed42ce933b6` |
| File / callback / link bindings | 7884 / 7761 / 10 | 7885 / 7762 / 10 |

Shared query SHA256: `b8df8ae59def64392bafb6681791809d7d84fa65451dbd2be4db428df249a8ac`.
Shared helper SHA256: `8486a48acbe4f024beecefb95d09eeab69ce0331d3f16d4a1f9c0591cdb117f2`.

Both gzip archives were decoded in memory. All **13 exports per phase** matched their readback bytes, declared sizes/hashes, exact manifest file sets and parent-consumed identities. Prepared Python exports parse with Python 3.9 grammar. Applicable authoring copies equal the prepared exports; runtime query/helper/runner/SPEC, copied phase gate/dispatcher and top-SDC bindings reconcile. Callback maps exactly equal the full inventories minus the specified `.qpf`, `.rpt`, `.log` and `.summary` suffix classes. No new remote observation is implied.

## Q1 lifetime and outcome persistence — accepted

The two prepared runners have identical control flow after their exact phase/path retarget. Findings refer to their common line numbers.

- **Actual CLI:** `run-query.py:312–316` calls `main_supervised`, not the retained legacy `main`/`wait_bounded`. The legacy definitions do not bypass the reviewed CLI path.
- **Post-spawn protection:** `supervise_native:141–159` checks non-reaping wait support and default SIGCHLD disposition before launch, exclusively reserves process metadata before `Popen`, and immediately protects the successful child lifetime. Metadata dump, flush, explicit close and wait-loop exceptions enter `BaseException` handling and the owned-group cleanup `finally` (`:154–248`). A metadata error no longer abandons the live child.
- **Normal leader exit is not completion:** `:161–166` detects live same-group descendants even after raw leader exit 0 or 7. Such a result fails the phase and drains the group before postflight. Non-reaping `waitid(P_PID, WEXITED|WNOHANG|WNOWAIT)` keeps the leader's PID/PGID reserved while group signaling remains possible. TERM/KILL and bounded drain precede reaping; no `killpg` follows the reap point.
- **Unknown is not success:** final confirmation requires an observed leader exit and two quiescent group observations. Inspection/reap failure retains explicit non-success and, where confirmation is unavailable, `termination_confirmed=false`. Raw native status is separate from the effective abort status; a killed child is not reported as successful merely because cleanup finished.
- **Persistence and reuse:** the supervision diagnostic is attempted in the persistent log; available raw status is recorded in `native-result.json` before preservation/report collection. Postflight errors fail acceptance while retaining raw status. Storage failures can prevent complete receipts; they do not fabricate success or release the exclusive claim for retry. The spent-artifact checks and exclusive opens prevent reuse. The replay verifies byte-identical evidence and no second spawn on rejected reruns.

These are ordinary Linux process-group protections, not an OS sandbox, protection from arbitrary supervisor/kernel failure, or containment of a deliberately escaped process group. No new generic containment requirement is imposed.

## S1, constraint scope and gate/report integrity — accepted

- Actual query line 7 has the current experiment03 root. Its sole change from experiment02 is the strict E constant, previously pointing at experiment01. Both prepared cwd/argv records reconcile with `<experiment03>/<phase>/scratch/syn/board/ia840f/syn_top`, the corresponding query, and `<phase>/reports/audit.tcllist`. Lines 38–49 retain strict phase selection, wrong-cwd rejection, spent-report rejection and exclusive audit creation before project opening. Prepared dispatchers select the current phase gate before legacy branches.
- Preparation, runners, phase gates and copied dispatchers are exact mechanical 02→03 retargets. No Q1 supervision changes were hidden in experiment03. Complete normalized old→new inventories reproduce nine changed file/callback bindings per phase, identical file sets/links and preservation digest `ba54fad92731357ffa65f163bdb402f133d3841f5e90660df752ac98f18394af`. Relocation receipt hashes/links reconcile with the current records.
- A→B reproduces ten changed bindings, one helper addition, no removals and equivalent links. Fitted-QDB and all 78 non-top-SDC bindings remain equal. Decoding the recorded single replacement exactly reproduces candidate top.sdc; removing the respective old/new blocks leaves identical remaining SDC, including asynchronous groups and multicycles. Shared helper and per-phase top.sdc are byte-identical to experiment02.
- The helper checks exact pin identity/cardinality/direction/type, divider identity/type, physical fanin and the existing master association; it rejects pre-existing named, propagated or target-associated output clocks before creation. The reviewed change remains the named existing master, observed divider and divide-by-two hypothesis, not a period/phase/base-clock/PLL/exception change. Candidate query completion requires helper execution and output/receiver propagation. Native API/object compatibility and numerical ratio acceptance remain experimental result gates.
- Gates retain exact authorization/record, target/readiness, file/link and executable/argv/cwd checks, plus live runner PID/start identity and callback ancestry. B requires native/effective baseline zero, literal-true native termination confirmation, exactly three literal-true preservation results, one completion marker and hashes of the five prescribed baseline artifacts. No authorization is created by these gates.
- Query cardinality/endpoint-pair limits, corner bounds, structural adjacency, clock/receiver inventories, global transfer/exception reports and numerical net-delay outputs remain. Runner wall/report limits, post-completion report size/cardinality checks, diagnostic rejection, report hashes and raw/effective status separation are retained. A completion marker or rc0 does not accept numerical timing; report truncation and complete changed-transfer coverage still require result review.

Saved preparation evidence records four missing-authorization rejections, unchanged originals/equal initial copies, and no native launch or authorization. This reviewer did not repeat actual preparation or unmocked gate/runner entry.

## Independent permitted inert replay

Executed only the following fixture entries with `python3 -B`, cwd `/home/joe`. Every invocation returned **0 with empty stderr**; counts and pass flags were checked programmatically. Source hashes and stable result fields agree with the saved parent-consumed receipts.

| Fixture | Passed | Meaning |
|---|---:|---|
| `test-supervision.py` | 26/26 | Four predecessor-defect reproductions; 22 successor cases, eleven per phase |
| `test-guard.py` | 17/17 | Inert Tcl guard/control checks |
| `test-candidate-gate.py` | 5/5 | Literal-true termination and failed-baseline rejection in temporary dummy-record fixtures |
| `test-routing.py` | 14/14 | Actual authoring Tcl entry to mocked project-open sentinel |
| `test-routing.py --prepared` | 14/14 | Exact prepared query/helper and record cwd/argv/callback bindings |

Successor supervision cases cover success/nonzero exit, post-spawn metadata failure, normal 0/7 leaders with TERM-resistant writers, wall/output caps, wait failure and transient/persistent inspection failure. **No successor writer remained live at runner return**; heartbeat checks stayed unchanged and all spent reruns retained evidence without spawning. The persistent-inspection-failure cases returned effective 124 with `termination_confirmed=false`; leader-with-descendant cases retained raw 0/7 while returning effective 124. Fixture cleanup uses PIDFD identities, not reused PGID signaling. Metadata flush/close and reap exception handling were also inspected statically; this report does not claim separate injected tests for them.

Routing tests source the actual full Tcl query/helper in libtcl8.6 with mocked package/cwd/file APIs and a stopping `project_open`. Correct routes reach the sentinel; old01/old02/wrong-phase/wrong-project and spent reports reject before report writes/project opening. Two cases reproduce S1 using experiment02 records. These are not native Quartus API or timing results.

## Disposition and remaining gates

**Blocking QUALITY defects: none.** Parent exact-binding consumption and separate one-use baseline authorization remain necessary. Inspect actual A completion, group termination and preservation before considering B; never pre-issue both or reuse a claim. Keep `approved=false` and `ready_for_build=false` in the prepared records. No authorization/native A/B run is asserted here.

Actual-result review must establish loaded SDC identities, generated ratio and propagated association, all eight FIFO assignments with numerical Required/Actual/Slack and actual periods, global changed transfers including outside C, exception precedence/per-exception truncation, all corners, UCP and every cap. Asynchronous cuts dominate overlapping multicycles; neither overridden multicycles nor hypothetical cut slack earns timing-safety credit. MPW `nworst20` is sampled; `check_timing` is not full Design Assistant sign-off. EMIF1 −0.004ns hold, CDC/DRC, matching persona and all hardware/recovery gates remain open. Unrun successful numerical outcomes are not prerequisites to this implementation approval.

Only this report was authored. All 30 frozen archive/manifest/export paths, SPEC/consumption and fixture sources were re-hashed unchanged before publication. The parent's concurrent unbound `CURRENT.md` update is outside the reviewed byte set and was not modified by this reviewer. A reviewer-only overbroad A→B text normalization initially renamed a local variable as well as phase strings; a focused path/module normalization resolved that comparison with no package change. No remote, vendor, hardware, git, real issuer/authorization, unmocked runner/gate/preparation action or task closure occurred.

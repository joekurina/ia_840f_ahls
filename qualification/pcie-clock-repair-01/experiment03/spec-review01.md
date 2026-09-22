# Independent SPEC review — actual prepared experiment03 A/B

## Verdict: PASS — S1 closed; no blocking SPEC gaps

This verdict covers only the fresh, bounded offline Work14 A/B STA experiment and the exact prepared bytes below. It is **not authorization**, native-result acceptance, timing closure, source promotion, fit or hardware qualification. Independent QUALITY on these final bytes, then parent exact-binding consumption, remain mandatory before one-use baseline issuance. A future issuer is not implicitly reviewed.

## Exact review targets and integrity

Targets: `baseline/prepared-readback01/` and `candidate/prepared-readback01/`, with their sibling archives and manifests. Independently decoded both gzip archives in memory: all **13 exports per phase** match the actual files, declared byte counts and SHA256 values, and the manifests contain exactly those files. Authoring copies and exported runtime/callback bindings agree. Python exports parse using Python 3.9 grammar.

| SHA256 binding | Baseline A | Candidate B |
|---|---|---|
| `preparation01.json.gz` | `9de4c688f891c0e223b45fb0a1c47336b89eb4eaa2ca20444a996dffae4d4e8b` | `6bae03e93ac2676986d73222f08b41d4ed437e50a944afd20ae967d9e18e6a28` |
| `prepared-manifest01.json` | `f40688e915bb01f07759aa9b23aa6a7e216fc65c3905f8e7d99efbf702479b08` | `f32f1bd103131a7a770dcf675cddea6388b238c60c4b4dce7374f86f954a0221` |
| Actual `candidate.json` | `9d63cb5e78488b60df449514e2b2967d1694fa7a872fefbfa8d78b951beb3719` | `aa3d57f743b0db7450db1df48e0f796cc97a97aede2298c6d36f85ff51beac0e` |
| File / callback / link counts | 7884 / 7761 / 10 | 7885 / 7762 / 10 |

Both actual queries: `b8df8ae59def64392bafb6681791809d7d84fa65451dbd2be4db428df249a8ac`.
Shared prepared SPEC: `bfeea5337982945c4d5d0cfd0133307a8167d6607cc8ae28516c02ce650599ff`.

## S1 correction and current routing — verified

The only query change from experiment02 is line 7's strict `E` constant, from `experiment01` to `experiment03`. Every remaining query byte is identical. Lines 38–49 retain exact phase selection, wrong-cwd rejection, exclusive report/audit creation and subsequent project opening.

Both actual records now agree with that constant:

- Root: `/home/uwb_student00/ahls/new_BSP/qualification/pcie-clock-repair-01/experiment03`.
- Per-phase native cwd: `<root>/<baseline|candidate>/scratch/syn/board/ia840f/syn_top`.
- Launcher argv: `/opt/altera/26.1.1/quartus/bin/quartus_sta -t <root>/<phase>/query.tcl`; runtime argv retains literal `quartus_sta` with the same query path.
- Reports: `<root>/<phase>/reports`, audit: `reports/audit.tcllist`.
- Runner remains `/usr/bin/python3.9`, exact `python3 -B <root>/<phase>/run-query.py` argv and phase-root cwd. The copied dispatcher's first branch selects the corresponding current phase gate; executable, file/link and live-ancestry grammar is not broadened.

Independently replayed the allowed `test-routing.py`, both authoring and `--prepared`: **14/14 each**, rc0 and empty stderr. It sources the actual full Tcl query and helper under Tcl 8.6, with mocked packages/cwd/report operations and a stopping `project_open` sentinel—not a duplicate Python path model. Both current phase paths reached the sentinel with their correct report/audit routes. Old01/old02, invalid phase/project and spent reports rejected before report writes/project opening. Two cases reproduced the old query's rejection of its own actual experiment02 records. Prepared record, query and callback hashes were checked. No report or vendor action occurred.

## Unchanged reasoning and narrow delta — verified

Reverified predecessor SPEC SHA256 `f6e948c57f9fe4fe8488368092f319348ecbb2cd44a9795cd69e822f1bce8acd`, its consumed parent rejection, and the predecessor archives/manifests/exports against that review's bindings. Reuse its unaffected source, scientific/reporting and Q1 reasoning; no research or release-authority reopening is needed.

- Preparation, runners, phase gates and copied dispatchers are exact mechanical 02→03 path/module/permission/buffer retargets. No supervision change. Complete normalized inventories reproduce **9 changed file and callback bindings per phase**, identical file sets and links. Metadata relocation receipts reconcile with current bindings. Preservation digest remains `ba54fad92731357ffa65f163bdb402f133d3841f5e90660df752ac98f18394af`.
- A→B remains exactly **10 changed bindings, one helper addition, no removals**, with equivalent links. The fitted QDB and all 78 non-top SDC bindings remain equal. The exact single generated-clock block replacement reproduces B; removing the respective blocks leaves byte-identical remaining SDC, including asynchronous groups and multicycles. Per-phase top SDC and shared helper are byte-identical to experiment02. The supported hypothesis remains the observed divider, existing `sys_pll|iopll_0_clk_100m` master and divide-by-two—not a new base clock, period/phase, PLL or exception experiment.
- Actual CLI entry remains `main_supervised`; Q1's non-reaping `waitid(WNOWAIT)`, protected post-spawn lifetime, owned-group drain, raw/effective status separation and fail-closed termination confirmation are retained. Independent inert replays passed **26/26 supervision** (four old-defect reproductions plus 22 successor checks), **17/17 guard**, and **5/5 candidate-gate**, each rc0/empty stderr. No successor fixture writer remained live at return. Saved fixture payloads and source/current-code hashes reconcile. These tests do not waive QUALITY or establish native Quartus compatibility.
- Saved actual preparation receipts show four missing-authorization checks returning 1, equal initial copies, unchanged Work14/SOURCE/PIM, and no authorization/native launch. Dispatch/pane evidence records `@43/%43`, outer rc0. These are verified captured preparation evidence, not new live remote observations.

## Remaining gates, not SPEC blockers

Keep `approved=false`, `ready_for_build=false`, exclusive claims, host/UID/owned-tmux checks and existing 1800s / 80GB headroom / 64GiB address-space / 128MiB-file / 1GiB-report limits. Source-bound guards are not an OS sandbox. Parent must inspect actual A before B issuance; B's `exact-offline-constraint-candidate03` permission binds five baseline files and requires native/effective status 0, literal-true termination, exactly three literal-true preservation results and one completion marker. Never pre-issue both or reuse a claim.

Actual-result review must reconcile loaded SDC identities, generated-clock ratio and propagated receiver association, all eight FIFO assignments as numerical Required/Actual/Slack evidence, global changed transfers (including outside C), exception precedence/truncation, all corners and every cap. Cut-path hypothetical slack and overridden multicycles receive no safety credit; MPW `nworst20` is sampled and `check_timing` is not full DRC. EMIF1 −0.004ns hold, CDC/DRC, matching persona and all hardware/recovery gates remain open. Successful unrun native results are not prerequisites to this experimental SPEC PASS.

**Review scope:** local read/hash/parse/static comparison plus only the four permitted inert fixture scripts. No actual preparation, unmocked runner/gate entry, issuer, authorization, remote/vendor/hardware or git action. All 132 pre-existing experiment02/03 files remained unchanged; the only durable file authored is this report. A reviewer-only receipt comparison initially omitted the saved `test_source_sha256` metadata field; it was reconciled and hash-verified in memory, with no package change or fixture failure. No tracked task or mission is closed.

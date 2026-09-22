# Clock-trial01 — independent prepared-package SPEC review

**PASS — no blocking SPEC defect found in the exact prepared package below.** This is permission to advance the technical review chain, **not native authorization, result acceptance, fit/source promotion, or task closure**. QUALITY, parent binding acceptance and separate one-use issuer inspection remain required (`prepared-readback01/AUTHORITY.md:5–9`).

Paths below are relative to `clock-trial01/`; `P` means `prepared-readback01/`, `H` means `../fanout-diagnostic03/`.

## Exact bindings independently verified

| Artifact | SHA256 |
|---|---|
| `prepared-manifest01.json` | `84b81bbbd7f911b49db15fcb43fc3b2f995683ff685bf7ae53afefaa7f190132` |
| `preparation01.json.gz` — 1,444,909 bytes | `7c4209eceab89971edd304e500fb6b4ac46029b37f9033f39bfb42ce0103dfff` |
| `P/candidate.json` | `d12b3121d6617744c422eab31e804cbf9af99940fdb9be88e94883fbc8bed707` |
| `P/clock-repair.tcl` — accepted guard02 | `4967de098cd857a936ccaeb16b22092259872292488ca44d5bce46b594af8bdc` |
| `P/preservation.json.gz` — identical to H | `ba54fad92731357ffa65f163bdb402f133d3841f5e90660df752ac98f18394af` |
| `P/top.sdc` | `7ac315c1a4e4fdd6c25fe734b0b80df7d7e6befca0f72867b2852f30a1406910` |
| `review-freeze01.json` — 40 protected files | `24be7bfedc025203eda08c2167b3bc369833fac14593396308d4f058da13db0d` |

Decoded and compared **all 20 exports**, including byte counts and SHA256, across archive batch `ia840f_clock_trial01_preparation01`, manifest and actual readback. All matched. All 40 frozen files matched before and after inspection. Parallel design recommendations are outside this freeze and are not prerequisites to this verdict.

## Findings

1. **The smaller experiment is explicit and implemented.** One fresh candidate-only fitted-copy STA run reuses the accepted original-SDC Work14/diagnostic03 baseline. It is not experiment04's ordered A/B execution or the old experiment03 candidate (`P/PRIORITY-AMENDMENT.md:5–13`; `P/SPEC.md:5–17`). The query has one normal `project_open → create_timing_netlist → read_sdc → update_timing_netlist` sequence, with argument-free SDC loading and explicit project-gate-marker rejection (`P/query.tcl:17–23`). No fit or hardware command is introduced.

2. **The constraint change is byte-exact.** Inverting the recorded replacement reconstructs H's complete original `top.sdc`, SHA256 `8255b34c200a46178174b9788bdc9231072ae829f57c34703cc63dd28ab66c3d`. Original lines 35–37 alone become attempt-local helper sourcing and `apply_v2`; all prefix/suffix bytes, including every exception, are identical (`P/constraint-delta.json:2–7`; `P/top.sdc:35–59`; `P/prepare01.py:80–92`). Guard02 is byte-identical to its accepted component, not merely similar. Its approved entry separates upstream driving association from explicit output definitions, creates once without `-add`, and checks exact source/master/target/ratio, returned-precision period/waveform and propagation (`P/clock-repair.tcl:115–188,194–203`). Older `apply`/`verify_created` procedures remain unused provenance.

3. **Source, inventory and runtime contexts close.** Independently reconstructed the complete scratch/PIM inventory from the retained originals plus exactly the four recorded relocations, top-SDC replacement, dispatcher change and added scratch gate. It equals the candidate: **7,890 files, 7,767 callback files, 10 links**. Callback membership is exactly the retained suffix policy; all link targets normalize inside scratch/PIM. The 15 external attempt inputs match readback hashes; both installed STA executable hashes equal H's bindings. Runner/tool/argv/cwd/part/readiness contexts equal H after mechanical retarget (`P/prepare01.py:45–62,93–107`; `P/candidate.json:7777–7780,15672–15703`). Runner, gate and dispatcher also equal actual H readback after only the named retarget substitutions. The new dispatcher branch precedes the old routes (`P/ia840f_experimental_gate.py:289–305`). This is inventory/source closure, not a per-open access trace or OS sandbox.

4. **Clock and finite receiver checks match the stated claim.** Data-only Tcl-list parsing proves the expected 80 definitions semantically equal H's actual native audit and the 459 names equal both retained O/K sets (`P/expected-baseline.tcl:3–4`; `H/result-readback01/reports/audit.tcllist:3–83,101,105`). The query requires exactly those 80 definitions plus C; no original definition may change (`P/query.tcl:23–29`; `P/clock-inventory.tcl:28–47`). Known32 is byte-identical to H, four groups of eight; mapping uses genuine cell-derived pin/buried-register collections and requires C at every known receiver and T (`P/receiver-mapping.tcl:19–79`). Conservative aggregate observations are explicitly not a complete clock-only domain (`P/scope-collections.tcl:55–86`).

5. **Reports are bounded observations, not automatic acceptance.** The corner loop counts the genuine collection, requires 1–16, uses `foreach_in_collection`, selects one returned object and updates timing (`P/query.tcl:31–58`). This follows captured installed help (`../api-help01/readback/help.log:2214–2228,2253–2265`). Domain summaries, transfer reports, explicit `check_timing`, sample20 timing and sample1 exception summaries use documented options; exceptions retain the 20,001 cap. Net-delay and skew limits are correctly per assignment, with skew additionally per latest/earliest result; detailed UCP is retained (`P/query.tcl:43–54`; `../api-help01/readback/help.log:1086–1105,1322–1333,1375,1729–1739`). `check_timing` is not represented as DRC. Completion explicitly denies comparison/timing/hardware acceptance (`P/query.tcl:59–64`).

6. **Accepted whole-lifetime safety is reused without weakening.** The supervisor functions are AST-identical to H; the live entry is `main_supervised`, not the legacy `main` (`P/run-query.py:117–249,252–316`). Host/UID/owned-tmux, live runner/native ancestry, missing-auth checks, exclusive claim, no competing vendor process, 80GB available RAM, 64GiB address space, 128MiB per file, 1GiB report total, 1,800s wall and 1,024 report-file ceiling remain (`P/ia840f_clock_trial01_gate.py:15–41`; `P/run-query.py:134–174,253–300`). Preparation retains 20GB disk headroom and original-tree comparisons (`P/prepare01.py:41–62,115–118`). Saved actual preparation checks show runner/dispatcher rc1 on missing authorization, unchanged donors and no vendor launch (`P/tests.json:2–15`); dispatch was `@54 %54`, outer rc0 (`preparation-dispatch01.json:3–8`; `preparation-verification01.json:15–19`).

## Evidence reuse and remaining native questions

Reused hash-bound saved evidence: H's 11 supervision cases; guard02's 36 cases; scope/receiver/inventory components' 26/29/18 cases. Verified component equality or the sole scope-root retarget and their saved hash bindings. Reviewed the tiny actual-entry records for fresh sentinel, wrong-root and spent-reports rejection (`authoring-check01.json:3–26`). **No package preparer, runner, gate, fixture suite, vendor/help command, SSH, issuer or hardware operation was executed during this review.** Local work was read-only hashing, AST/data parsing and source comparison; only this review file was written.

The real insertion state, strict guard's behavior across full SDC, candidate C propagation, native API behavior and report completion remain unproven until the bounded run. These are legitimate experimental questions, not reasons to require the paused experiment04 framework. A guard/API/cap failure must stop and preserve the consumed attempt; useful earlier output is not complete-query success (`P/SPEC.md:17,23–25`).

Independent actual-result review must inspect all eight formerly invalid FIFO assignment rows, Required/Actual/Slack, invalid/missing data, cap saturation, reported corners, diagnostics, native/effective status, termination and original preservation. Samples and summary tables do not prove exhaustive changed-transfer/exception coverage. The independent EMIF1 hold and High CDC/DRC issues remain open. **No source promotion, fresh fit, retry, cap increase or hardware access follows from this PASS.**

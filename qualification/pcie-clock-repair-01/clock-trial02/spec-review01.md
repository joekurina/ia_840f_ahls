# Clock-trial02 — actual prepared-package SPEC review

**PASS — the insertion/final-clock mismatch is corrected in the actual prepared bytes, with no blocking SPEC defect found.** This verdict permits progression to QUALITY, not native execution, result acceptance, source promotion, fit, hardware access or task closure. QUALITY must review this same package after SPEC; parent binding acceptance and separately inspected one-use issuance remain required (`P/AUTHORITY.md:5–9`; `P/SUCCESSOR.md:9`). No approval is inherited from clock-trial01: its earlier SPEC PASS was not parent-accepted (`P/SUCCESSOR.md:3`; `T/fast-route-review.md:5–19`).

Paths are relative to `clock-trial02/`: **P** = `prepared-readback01/`, **T** = `../clock-trial01/`, **H** = `../fanout-diagnostic03/`, **V** = `../experiment04/guard02/`.

## Exact package bindings

| Artifact | SHA256 |
|---|---|
| `prepared-manifest01.json` | `97f9c0664a266ef77d2025c710bd12078728e079dc75feec23b0e3a595ed6e22` |
| `preparation01.json.gz` — 1,446,908 bytes | `0894077b821624673b4e5f797db4606722a9270cd934a1ab5bc2afdde287ab52` |
| `P/candidate.json` | `c2fbb6e73f56aa4a8a212edade169e0b547286573662fc996c1196516f12fbc4` |
| `P/clock-repair.tcl` | `e0ca71dede69ea61942cf1dd52c9df8ae2580c7d2ec5f167d30800d0684964c1` |
| `P/expected-baseline.tcl` | `be4f6bda3be8f01d1bdbc491dbb83fc1256187df311ca018041bf13bac5c72e8` |
| `P/top.sdc` | `ea484352945e166842f1d84496d727730478434c11da84edb934ed5bf6c09590` |
| `P/preservation.json.gz` — identical to accepted H | `ba54fad92731357ffa65f163bdb402f133d3841f5e90660df752ac98f18394af` |
| `review-freeze01.json` — 46 protected files | `81d6f0aaccf8610689b15dc0b911cdd85e3d0838e1413d75ea8c5f53158154c2` |

Independently decoded **all 21 exports** in batch `ia840f_clock_trial02_preparation01`; archive payloads, manifest hashes/byte counts and actual P files match exactly. All 46 frozen files matched before and after source/data inspection and the focused inert replay. T's 40-file freeze also remains intact. This review binds remote-prepared readback, not merely authoring templates.

## 1. Concrete integration defect resolved

The accepted native log loads integration `top.sdc` at `H/result-readback01/query.log:258`, then `bti_refclk.sdc:356`, and `bwbmc.sdc`/internal oscillator at `:483–484`. Their final clocks `qsfp_ref_clk`, `bwbmc_fpga_max_sclk` and `altera_int_osc_clk` appear at `H/result-readback01/reports/audit.tcllist:81–83`. The original guard's `before_v2` is therefore an insertion snapshot, not the final full-SDC baseline.

The actual helper preserves **all 14,451 original guard02 bytes** as an unchanged prefix, SHA256 `4967de098cd857a936ccaeb16b22092259872292488ca44d5bce46b594af8bdc`. Insertion still records `before_v2`, rejects an existing definition/name or unexpected upstream association, creates C once without `-add`, sets `created`, and immediately enforces the C-only delta (`P/clock-repair.tcl:107–153`). Nothing overwrites that snapshot or resets the creation flag after loading.

The additive `verify_created_final_v3` instead calls the existing semantic inventory comparator with an explicitly supplied final baseline (`P/clock-repair.tcl:211–215`). A direct body comparison proved that every generated-C postcondition from `verify_created_v2` remains identical; only the procedure signature, boundary comparison and success-marker name differ (`:159–188,211–241`). Exact name/cardinality, type/target, source/master, integer ratio 2/1, non-inversion, returned-precision period/waveform relation, post-output-pin checks and C-only output association all remain. The old verifier is unchanged and is not called at the final boundary.

The query loads pinned baseline data before opening the project, then performs the normal `project_open → create_timing_netlist → read_sdc → update_timing_netlist` sequence and passes `$::ia840f_compare04_expect::clocks` to the new verifier (`P/query.tcl:4–23`). Audit initialization precedes that call (`:15`). There is no preloading/reordering/repeated SDC read, caught mismatch, late clock creation or candidate-derived replacement baseline. The existing subsequent inventory check remains (`:27`).

Data-only Tcl-list parsing independently reconciled **all 80 definitions** in `P/expected-baseline.tcl:3` with the accepted native audit, explicitly decoding its `generated_properties` record tag and list-valued properties without rounding or renaming. Audit and log hashes match H's result manifest. The comparator requires exactly the pinned 80 clocks plus C and unchanged original definitions; unlisted, missing or changed late clocks are not allowed (`P/clock-inventory.tcl:6–47`).

## 2. Narrow delta and candidate closure verified

Inverting `P/constraint-delta.json:2–7` reconstructs H's complete original `top.sdc`, SHA256 `8255b34c200a46178174b9788bdc9231072ae829f57c34703cc63dd28ab66c3d`. Exactly original lines 35–37 are replaced by attempt-local helper sourcing and `apply_v2`; all remaining bytes, including every exception, are identical (`P/top.sdc:35–59`; `P/prepare01.py:80–92`). Preserved asynchronous groups/multicycles may acquire new effect when C exists; byte preservation is not exception-precedence or CDC acceptance.

Reconstructed the complete candidate inventory from accepted original Work14/PIM inventories plus precisely four recorded relocations, the top-SDC replacement, dispatcher branch and new scratch gate. It matches **7,891 files, 7,768 callback files and 10 links**. Callback membership exactly follows the retained suffix policy. Every link normalizes inside scratch/PIM. All 16 external attempt inputs match actual readback hashes; the two installed STA executable hashes match H. Removing the new dispatcher branch reconstructs its original inventoried bytes (`P/prepare01.py:48–107`; `P/ia840f_experimental_gate.py:289–305`; `P/candidate.json:7774–7791`). This is source/inventory closure, not live per-open tracing or an OS sandbox.

Compared actual P executable files with T after explicit fresh-root/module/token substitutions. The only nonmechanical executable differences are the additive final verifier, its query call and inclusion of `SUCCESSOR.md` in the preparer's finite input/binding/export sets (`P/prepare01.py:40,106,120`). No timing limits, receiver policy or exception bytes changed. Python sources parse under the remote Python 3.9 grammar. T's documented closure was used as a comparison map, not an inherited approval.

## 3. Pilot and lifetime-safety contract unchanged

The scope remains **one fresh candidate-only copied-Work14 STA**, reusing the accepted original baseline, with no baseline rerun or prerequisite completion of experiment04's broader framework (`P/SPEC.md:5–25`; `P/PRIORITY-AMENDMENT.md:5–13`). Known32 is byte-identical to H; the retained 459-node baseline matches both native O/K sets. Actual cell-derived collections require C at each of the 32 mapped receivers and T, without claiming every conservative node is a C load (`P/receiver-mapping.tcl:19–79`; `P/scope-collections.tcl:55–86`).

Reports retain genuine 1–16-corner enumeration, corner selection/update, domain summaries, transfer tables, explicit `check_timing`, sample20 timing, sample1-per-exception summaries, 20,001 exception/per-assignment path bounds and UCP (`P/query.tcl:31–58`). Completion explicitly disclaims comparison, timing and hardware acceptance (`:59–64`). `check_timing` is not DRC, and sampled reports are not exhaustive coverage.

The whole-lifetime supervisor functions are AST-identical to H. The actual entry remains `main_supervised`, protecting spawn/bookkeeping, ordinary leader exit and descendants, non-reaping group signaling, termination confirmation and failure receipts (`P/run-query.py:117–249,252–316`). Host/UID/owned-tmux, exact runner/native ancestry, exclusive claim, missing-auth rejection, no competing Quartus/qsys, 80GB available RAM, 64GiB address-space, 128MiB/file, 1GiB report-total, 1,800s wall and 1,024-report-file checks remain; preparation retains 20GB disk headroom (`P/ia840f_clock_trial02_gate.py:15–41`; `P/run-query.py:253–300`; `P/prepare01.py:34–62`).

Actual preparation records show `@55 %55`, outer rc0, runner/dispatcher rc1 for missing authorization, unchanged original trees and no vendor launch (`preparation-dispatch01.json:3–9`; `preparation-verification01.json:15–21`; `P/tests.json:2–15`). Candidate remains `approved=false`, `ready_for_build=false`; later native preflight/issuance must bind these exact bytes.

## 4. Focused evidence and remaining native questions

Replayed only the existing nine-case harness with `ROOT` directed to actual P readback: **9/9 PASS**. It demonstrates old-verifier failure/new-verifier success with pinned late clocks; rejection of unlisted, missing and changed late clocks, wrong C source/ratio, lost propagation and missing post-output pin; unchanged insertion snapshot and rejected retry in every case (`test-final-boundary.py:50–95`). These are synthetic boundary checks, not native Quartus semantics or proof of the actual insertion clock count.

The preserved first fixture failure was missing `audit`, normally initialized by the query. Comparing the initial and current harness shows only that fixture initialization added; no production edit was needed (`boundary-fixture-failure01.json:2–6`; `test-final-boundary.py:72`; `P/query.tcl:15`). Saved guard02 36-case, scope 26-case, receiver 29-case, inventory 18-case and H supervision 11-case records were reused after source/hash checks, not broadly rerun. The three saved actual Tcl-entry records retain fresh project-open sentinel, wrong-root rejection and spent-report rejection (`authoring-check01.json:2–27`).

**No remaining SPEC blocker.** Native insertion behavior, full-SDC C definition/propagation, API execution and complete report production remain experimental. In particular, integer generated ratio **2/1 remains a strict hypothesis**, not established native behavior: an unexpected native representation must reject and preserve the attempt, never be silently converted or accepted (`P/clock-repair.tcl:224`).

Independent actual-result review must inspect all **eight formerly invalid FIFO assignments**, their numerical Required/Actual/Slack, selectors/provenance, invalid or missing rows, every reported corner and per-assignment saturation, plus diagnostics, native/effective status, confirmed termination and original preservation. Negative numerical slack is evidence, not acceptance. Partial reports or a completion marker alone cannot clear these requirements. EMIF1 hold −0.004ns, High CDC/DRC, full timing/coverage and mission hardware/QSPI gates remain open (`P/SPEC.md:15–25`; `P/AUTHORITY.md:9`).

Review operations were local read-only hash/AST/data/source inspection and the named focused inert harness only. No preparer, runner, gate, native/help command, SSH, issuer, authorization, hardware or git action was executed. **Only this report was written.**

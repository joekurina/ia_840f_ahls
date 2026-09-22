# Clock-trial02 — actual prepared-package QUALITY

**APPROVED — package-only. No critical or important blocker found.** This reviews the actual `prepared-readback01` bytes after the consumed SPEC PASS. It is not execution authorization or result acceptance. Parent binding acceptance/publication and inspection of the actual one-use issuer remain separate (`P/AUTHORITY.md:5–9`).

Paths below are relative to `clock-trial02/`: **P** = `prepared-readback01/`; **H** = `../fanout-diagnostic03/`; **T** = `../clock-trial01/`; **V** = `../experiment04/guard02/`.

## Binding and preservation

| Artifact | Verified SHA256 |
|---|---|
| Consumed `spec-review01.md` | `150bacc2bc29fc001c53e624a49572d948f4280eac0332c49c3849390ace970a` |
| `parent-spec-consumption01.json` | `cba79f6157a136b79efc174802df6ea129305a20daa6696bc114395931be8761` |
| `review-freeze01.json` | `81d6f0aaccf8610689b15dc0b911cdd85e3d0838e1413d75ea8c5f53158154c2` |
| `prepared-manifest01.json` | `97f9c0664a266ef77d2025c710bd12078728e079dc75feec23b0e3a595ed6e22` |
| `preparation01.json.gz` | `0894077b821624673b4e5f797db4606722a9270cd934a1ab5bc2afdde287ab52` |
| `P/candidate.json` | `c2fbb6e73f56aa4a8a212edade169e0b547286573662fc996c1196516f12fbc4` |
| `P/clock-repair.tcl` | `e0ca71dede69ea61942cf1dd52c9df8ae2580c7d2ec5f167d30800d0684964c1` |

All **46 frozen files**, the SPEC report and its consumption receipt matched before and after inspection. Independently decoded all **21 archive exports**: actual P bytes, hashes and sizes match the manifest. T's 40-file freeze also remains intact. Candidate counts are 7,891 files / 7,768 callback files / 10 links; callback membership, all 16 external attempt-input hashes, argv/cwd bindings and link boundaries were checked. The consumed SPEC's full inventory reconstruction and native 80-definition reconciliation are reused, not represented as new native observations (`spec-review01.md:32–40`).

## Findings

- **The actual final-boundary defect is corrected without weakening insertion checks.** H's native log really loads top SDC before the later reference/BMC/oscillator SDCs (`H/result-readback01/query.log:258,356,483–484`). P preserves the entire 14,451-byte accepted guard02 prefix. Direct body comparison shows the new verifier differs from `verify_created_v2` only in its parameter, pinned-baseline comparison and success marker. All C identity/type/source/master/target, strict ratio, precision/waveform, non-inversion and output-propagation checks remain (`P/clock-repair.tcl:159–188,211–241`). `apply_v2` still records the insertion snapshot, creates once, marks creation and immediately checks the C-only delta (`:115–153`).

- **The assembled query uses the correct boundary and reference.** It initializes audit, performs ordinary project-open/netlist/read-SDC/update ordering, and explicitly passes `$::ia840f_compare04_expect::clocks` to the final verifier. It neither overwrites `before_v2` nor catches the mismatch, reloads/reorders constraints or creates late clocks (`P/query.tcl:4–29`). The semantic comparator requires exactly the pinned 80 clocks plus C and unchanged original definitions; list serialization is canonicalized without numeric rounding (`P/clock-inventory.tcl:6–47`).

- **The change is narrow in actual prepared code.** After explicit fresh-attempt retarget substitutions, differences from T are only the additive verifier, its query call and `SUCCESSOR.md` inclusion in the preparer's finite sets (`P/prepare01.py:40,106,120`). Inverting the recorded SDC replacement reconstructs H's complete original file byte-for-byte, SHA256 `8255b34c200a46178174b9788bdc9231072ae829f57c34703cc63dd28ab66c3d` (`P/constraint-delta.json:2–7`). Preserved asynchronous groups/multicycles can become effective when C exists; unchanged bytes do not establish exception-precedence or CDC acceptance (`P/top.sdc:42–59`). T was never issued/run and its SPEC PASS was not parent-accepted (`P/SUCCESSOR.md:3`).

- **Safety and one-use routing remain intact.** Python parses under the remote 3.9 grammar; whole-lifetime supervision helpers are AST-identical to H. The actual entry is `main_supervised`, not the retained legacy main. It protects spawn/bookkeeping, drains descendants before reaping, records raw status before postflight, and preserves termination uncertainty (`P/run-query.py:117–249,252–316`). Exact authorization/source/link and live-runner/native-ancestry checks remain (`P/ia840f_clock_trial02_gate.py:15–41`; `P/ia840f_experimental_gate.py:289–294`). Host/UID/owned-tmux, exclusive claim, no competing native tools and unchanged resource limits remain: 80GB available RAM, 64GiB address space, 128MiB/file, 1GiB reports, 1,800s, 1,024 report files; preparation retains 20GB disk headroom. Saved actual preparation shows missing-auth runner/dispatcher rc1, preserved originals and no vendor launch (`P/tests.json`). These are source-bound guards, not an OS sandbox.

## Evidence limits and required result review

Reviewed and reused the saved 9/9 focused boundary results, SPEC's actual-P replay, and the existing 36/26/29/18 component and 11 supervision records; **no tests were rerun or expanded**. The initial fixture's missing-audit failure remains preserved; the actual query initializes audit before verification (`test-final-boundary.py:50–95`; `spec-review01.md:54–56`; `P/query.tcl:15`).

The strict generated ratio **2/1 remains a native hypothesis**. Unexpected native representation must reject and preserve the attempt, not be silently converted (`P/clock-repair.tcl:224`). Full-SDC/API/report execution is the purpose of this pilot, not a reason to revive the paused experiment04 framework.

Known32 plus T checks use real cell-derived collections; the conservative 459-node reference is not claimed to identify every C load (`P/receiver-mapping.tcl:19–79`; `P/scope-collections.tcl:55–86`). The genuine 1–16-corner loop retains sample20 timing, sample1-per-exception and capped 20,001-per-assignment net-delay/skew reports, not exhaustive coverage (`P/query.tcl:31–59`). Independent actual-result review must inspect **all eight formerly invalid FIFO assignments**, numerical Required/Actual/Slack, every corner, selector/provenance, missing/invalid rows and per-assignment saturation, together with diagnostics, native/effective status, confirmed termination and original preservation. Completion alone is not acceptance.

Approval is only for this one candidate-copy offline STA package, reusing the accepted original baseline without an A rerun. No fit, maintained-source promotion, full-comparison, timing, hardware or mission acceptance follows. EMIF1 hold and CDC/DRC remain separate and open (`P/SPEC.md:15–25`; `P/AUTHORITY.md:9`).

Only this report was written. Review actions were local read-only source/hash/AST/data inspection; no preparer, runner, gate, native/help, SSH, issuer, authorization, hardware, git or task-closure action was performed.

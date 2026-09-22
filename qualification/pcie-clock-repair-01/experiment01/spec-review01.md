# Independent SPEC review — actual prepared Work14 A/B packages

## Verdict: PASS

**PASS for the bounded offline experiment package specified in `SPEC.md`. No blocking SPEC gap was found in the actual prepared baseline/candidate exports.** This is not authorization issuance or parent acceptance, and does not approve still-unrun native results, a maintained-source repair, a constrained fit, timing closure, CDC correctness, or hardware use. Independent QUALITY review, parent exact-binding consumption and the separately bound one-use authorizations remain required before execution.

Review was local-only: read/hash/parse/static comparison of the actual `baseline/prepared-readback02/` and `candidate/prepared-readback02/` exports and retained prerequisite/help/test evidence. No remote, vendor, hardware, git, issuer, preparation or package-runner execution occurred. No reviewed bytes were changed. The only authored file is this report.

## 1. Exact review binding and integrity

Both lossless preparation archives were decoded in memory. Every exported byte, size and SHA256 was checked against its archive entry, sibling `prepared-manifest02.json`, actual readback file and consolidated `preparation-verification02.json`. Each archive has exactly **13 exports**, with no missing or extra readback files. Both large `candidate.json` records were parsed programmatically, not treated as authoring templates.

| Identity | Baseline | Candidate |
|---|---|---|
| `preparation02.json.gz` SHA256 | `2ae2be6137c26f586cae9a344839f17e105c09843ce29b11af44e910ebaf3891` | `53bda029311930529d3230ed527a56237dca5615244490372dc9a0abfc34e4a2` |
| Archive bytes | 1040024 | 1040491 |
| `prepared-manifest02.json` SHA256 | `5c2a19fa75d77616545e199d65eafc1cdde83bd7158471fea0d3c6fe1d99264c` | `e8ff407d11912bd0d4f70dda8a865b00a49c310ab9e1af06a187ee4f1ca67be0` |
| Actual `candidate.json` SHA256 | `828849ff7b597d5269de8193091202b51feac6cca2afdc89f374e962c75125c7` | `2164915affe8f96c369cd2084eca66b7bd0d08237ba924ce2d01b2083d47a1a0` |
| File / callback / link bindings | 7884 / 7761 / 10 | 7885 / 7762 / 10 |

The common prepared SPEC is byte-identical to `experiment01/SPEC.md`, SHA256 `324a7292be12cc68c95aa0e14846880f66f476bd2e6bf4681cd9ef4d58270d2b`. Consolidated preparation verification hashes to `7a6c9a4f9767e6f4632416b868fbf1c833b6291ded1a7788a306f96fbc24b90b`.

Both records explicitly retain `approved=false`, `ready_for_build=false`, target `ia840f`, part `AGFB027R25A2E2V`, original `work_ia840f_fim_14` database origin and separate phase-specific scratch/report roots. Exact launcher/native argv, executable, cwd and Python runner context were checked. The bound STA executable hashes match both retained installed-help receipts. Exported query, helper, gate, dispatcher and top-level SDC identities agree with their corresponding bound runtime files; candidate's copied SDC helper also matches the exported helper.

These checks verify the exported remote preparation evidence, not a new live inventory of the remote trees.

## 2. Equivalent copies and narrow constraint delta

**PASS.** The prepared baseline `top.sdc` is SHA256 `8255b34c200a46178174b9788bdc9231072ae829f57c34703cc63dd28ab66c3d`; candidate is `eb65af7949f130fffb011c6b5a96a5bc46bde5df7d57d99091e03730a441ff9a`.

Decoding `constraint-delta.json` proves that the old block occurs exactly once and that replacing only that block produces the actual candidate bytes. Removing the respective old/new blocks leaves byte-identical files. Thus **all remaining SDC bytes**, including asynchronous groups, the four multicycle statements and synchronizer constraints, are unchanged—not merely semantically similar. The replacement is only the helper source plus `::ia840f_clock_repair::apply` at the original generated-clock position.

After mechanical phase-path normalization, the complete bound inventories have exactly ten changed file bindings and one added helper binding. Changes are confined to the exported authority/delta/gate/runner/top-SDC records, scratch gate/dispatcher/top-SDC copies, and the two recorded path-relocated metadata files (`ofs_top.qar_info.json`, `mem_ss.xml`). Link inventories are equivalent. No other A/B inventory difference was found. In particular, the bound fitted QDB, all 555 PCIe subtree files and all 78 non-top `.sdc` entries agree. The fitted QDB identity is `2aa11f9cb027f377447ff77c8088e78aa2ee5b1744a1202444dbcfb6a978acd3`.

Both phases bind the same original-tree preservation receipt digest, `ba54fad92731357ffa65f163bdb402f133d3841f5e90660df752ac98f18394af`. The inspected preparation logic first verifies copied inventories against originals, then applies explicit relocations/overlays and rechecks originals. Saved `tests.json` receipts report initially identical copies and unchanged Work14/SOURCE/PIM. The preserved prepare01 missing-parent failure is not a consumed native attempt; the reviewed/exported preparation source is prepare02.

## 3. Clock hypothesis and guard semantics

**PASS.** The shared helper, SHA256 `8486a48acbe4f024beecefb95d09eeab69ce0331d3f16d4a1f9c0591cdb117f2`, implements the narrowly supported definition:

- `H = pcie_wrapper|pcie_ss.top|host_pcie.pcie_ss|pcie_ss`; clock name `H|avmm_clock0`.
- Observed modern divider `inclk` and `clock_div2`, not `clock_div2x` or a register alias used as a pin selector.
- Existing master `sys_pll|iopll_0_clk_100m`, generated-clock divide-by-two relationship, and physical source fanin `sys_pll|iopll_0|tennm_pll|outclk[2]`.

`clock-repair.tcl:18–58` checks exact pin cardinality/name/direction/clock-pin status, one expected `tennm_clk_divider`, one named master, physical source fanin and propagated input-clock association. It rejects pre-existing requested names, output-driving clocks and known output targets before creation. There is no new base clock, nominal period/phase, blind `-add`, deletion/overwrite, renamed clock to evade groups, or exception removal. A future already-correct baseline is deliberately a changed-state rejection requiring review, not automatic idempotent acceptance.

Postcreation checks (`:60–72`) require actual helper execution, one generated C with the intended master and sole target, and output propagation; native target/source/period/waveform/divide/multiply values are emitted for later acceptance. Namespace/procedure locals and collection-to-name conversion avoid the prior global `pins` and node-as-collection failures. Native behavior and resulting ratio remain empirical gates, not claimed results of this review.

The accepted prerequisite remains the completed E2 diagnostic, not a new selector query. Its independent result-review hash was reverified as `80271442ede068b230587be3a799000b10b0cf32d561ce09c95efc8f0907edb5`; the parent acceptance explicitly distinguishes target-name absence from exhaustive propagated-clock absence.

## 4. Reporting scope and finite completeness

**PASS as an experimental acquisition and later-review contract.** The common actual `query.tcl` hashes to `8ed2064e0b99c598b457a936f064ee6db6a260b2b672e9fe6c6949fd6d47124c`.

- `query.tcl:49–60` opens the fitted project, uses normal `read_sdc` order and updates timing, then positively requires candidate helper execution. Native source-loading diagnostics and SDC reports must subsequently establish the actual loaded filenames; no hermetic scratch-only-read claim is made.
- `:61–110` inventories all clock definitions and selected group memberships, discovers divider clock fanouts, audits propagated clocks on every resolved load and all four eight-receiver FIFO groups, and records synchronous/asynchronous structural adjacency. This retains baseline unclocked connectivity that constrained timing-path APIs cannot supply. Compatibility of actual fanout objects with exact keeper lookup is intentionally experimental; an unsupported object must fail, not be omitted or counted as an empty set.
- `:24–35,119–142` acquires timed/cut and applicable data-delay unique endpoint pairs in both directions over the complete discovered load collection; all global transfer matrices and exception summaries; scoped exception details with clock groups; global domain summaries; explicitly sampled worst paths; relevant MPW, full UCP and numerical net-delay/skew reports for the operating-condition loop.
- Installed help confirms that `get_clocks -of_objects` covers targeting/driving clocks, `-false_path` exposes constrained cut paths without removing cuts, `report_exceptions -report_clock_groups` includes group precedence, and `report_net_delay` without `-nworst` reports all matching edges of every assignment. Clock-transfer counts do not subtract path-specific false paths. None of those quantities is misclassified here as complete active timing coverage.
- The clock/load/adjacency/corner caps and the request-20001/reject-at-20001 path strategy are explicit. Skew return/count is retained and guarded. **Exception report truncation still needs per-exception result inspection:** its `-npaths` bound is per exception, and the command returns operation status rather than a completeness count. `COMPLETE` or native/effective rc0 alone therefore does not establish report completeness. SPEC:26,30 correctly blocks promotion on capped or otherwise incomplete evidence; no pre-run success proof or new reporting framework is required.

The eight formerly invalid FIFO assignments must later be individually reconciled as present, active numerical records with actual source/destination periods and Required/Actual/Slack at applicable corners. The script requests their full report class; this review does not assert they already became numerical. Global changes outside the scoped C load set require investigation and block promotion, as specified. Async cuts retain vendor intent; dominated M↔C multicycles receive no safety credit. Negative numerical results are evidence, not waivers, script-success criteria or automatic permission to fit.

The documented `check_timing` call is useful constraint checking, not full Design Assistant/DRC sign-off. Existing High-rule findings and the separate EMIF1 −0.004 ns hold violation remain open.

## 5. Bounded execution and retained tests

**PASS for SPEC scope; implementation remains subject to QUALITY review.** The baseline gate retains E2's exact process identity, live claim/ancestry and file/link-binding model with phase/permission retargeting. The candidate gate adds the required successful baseline native/effective status, three true preservation results, unique completion marker and exact five baseline-result SHA bindings in its authorization. A baseline execution/preservation failure cannot authorize B through this gate.

Both prepared runners are identical after phase retargeting. They require the owned tmux session, host/UID, unoptimized Python, 80 GB available RAM and no competing Quartus/qsys process; reserve exclusive artifacts; impose 64 GiB address space, 128 MiB file, 1800-second wall and 1 GiB report-total limits; and terminate only the owned process group on watchdog failure. The reviewed timeout path retains the leader through TERM/KILL, checks live descendants for a bounded drain and labels unconfirmed termination as failure. Raw native status is written before preservation/report postflight, with separate final effective status and `timing_accepted=false`. These are ordinary-file/process guards, not an OS sandbox.

Recomputed hashes link saved `guard-tests01.json` to the actual helper/query and `runner-tests02.json` to both actual runners. Their declared counts reconcile to **17** passing inert Tcl cases and **11** passing inert runner/import/regex cases, including the TERM-resistant descendant case. All prepared Python exports parse under Python 3.9 AST syntax. These are static/inert evidence only, not vendor API/netlist validation; this review did not rerun the fixtures.

Actual preparation receipts record runner and dispatcher missing-authorization rc1 for both phases, with `authorization_issued=false` and `vendor_launched=false`. Fresh native outcomes are absent by design. A future issuer must retain these exact reviewed bindings and the SPEC→QUALITY→parent-consumption sequence; it is not implicitly reviewed or authorized by this PASS.

## Disposition

**Blocking SPEC gaps: none for this exact bounded experiment package.** Proceed only through the remaining review/issuance gates. Any change to reviewed package bytes requires fresh binding/review. Acceptance of later results must separately reconcile loaded sources, preservation, clock propagation/ratio, numerical FIFO checks, exception/transfer coverage and every report cap. No maintained-source promotion, fit/timing pass or hardware acceptance is supplied.

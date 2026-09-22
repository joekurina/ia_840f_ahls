# Work14 fitted-netlist diagnostic — focused SPEC review 01

**Verdict: PASS for the bounded, source-bound offline diagnostic specification. No blocking gaps found in the reviewed prepared package.** This is not native-result acceptance, timing acceptance, build readiness, authorization issuance, or a release-selection endorsement.

## Reviewed identity and verification

Review target: `prepared-readback01/`, bound by `prepared-manifest01.json`, not a draft or an assumed remote working tree.

- Manifest SHA256: `41cacf060bbea75bf4455cb617a5f7b295d7d8c5f78079bb5553fbc0a90ed886`.
- Candidate: **4,001,828 bytes**, SHA256 `5e20a7a1b2be00d53a72972cdf09fa4ab1cc93d9e330f010f69c4b0954e52776`.
- Preparation archive SHA256: `ea27914ea09b40e29314b66bce4e1314f9c2ec707dd6ac09c58d53ad2636d283`; decoded batch is exactly `ia840f_w14_postfit_preparation01`.
- Recomputed size and SHA256 for **all nine manifest entries**: `AUTHORITY.md`, `candidate.json`, `ia840f_experimental_gate.py`, `ia840f_w14query01_gate.py`, `path-relocations.json`, `prepare01.py`, `query.tcl`, `run-query.py`, and `tests.json`. Every entry matches. Every readback also equals its decoded preparation-archive export byte-for-byte, including the export's size/hash; file sets are identical.
- Parsed the candidate programmatically: **7,880 prelaunch files, 7,757 callback files, 10 links**. Callback inventory is exactly the prelaunch inventory minus the established suffix classes: 112 `.rpt`, 4 `.log`, 2 `.qpf`, and 5 `.summary` entries. All retained digests are unchanged.
- Verified the candidate bindings for the actual query, runner, authority, gate, and copied scratch dispatcher/gate against the reviewed bytes. Python AST parsing succeeds for all four prepared Python files. No package code or vendor executable was run by this reviewer.

These checks verify exported bytes and their internal/provenance bindings. They do **not** claim an independent live rehash of the remote installation or all copied database files. Remote preparation attestations and future runner validation remain distinct from this local review.

## Requirement findings

### 1. Authority, isolation, and preservation — PASS

`AUTHORITY.md:3–17` expressly renews approval for this diagnostic and supersedes the historical Query04 approval-timeout blocker. It retains the overriding workstation-availability boundary and excludes hardware operations. No new incremental user-approval prerequisite is introduced by this review.

`prepare01.py:31–56,95–98` requires the ordinary build identity, owned tmux session, absent attempt directory, memory/disk headroom, no competing native tools, and the recorded Work14 authorization/STA/fit identities. It records original Work14/SOURCE/PIM inventories before copying, verifies initially identical Work14 and PIM copies, and verifies originals again after preparation. `tests.json` records those checks passing and preparation-only pane `%34`; it reports no authorization issued and no vendor launch.

The candidate retains Work14 as `database_origin`. Its copied fit/STA report pins match the exact hashes required by preparation; the fitted QDB is also bound. The recorded completed Work14 compile is provenance, not something this query reruns.

Compared preflight inventory membership with candidate scratch/PIM membership: no original entries are removed; only the new query gate is added to scratch. Verified unchanged candidate hashes for the exported QSF/QPF, build environment, project macros, top SDC/utilities, compile gate, and common config helper. All four declared relocation results match candidate bindings: two links and two text-file hashes. Every link resolves lexically within the diagnostic root. The scratch dispatcher is exactly the exported Work14 dispatcher plus its one diagnostic-specific first branch; unrelated branches are preserved.

The preparation and runner do not target W13 or persona artifacts. Post-native preservation checks explicitly cover Work14, maintained SOURCE, and original PIM via the candidate-bound `preservation.json.gz`; failures produce a nonzero runner result. The baseline gzip itself was not exported in this readback, so its contents/preservation outcomes are supplied preparation evidence, not independently reproduced local measurements.

### 2. Exact STA command and execution guard — PASS

The only runner-native argv is:

```text
/opt/altera/26.1.1/quartus/bin/quartus_sta -t /home/uwb_student00/ahls/new_BSP/qualification/fim-build-14/pcie-postfit-01/query.tcl
```

Its cwd is exactly the diagnostic `scratch/syn/board/ia840f/syn_top`. The runtime callback additionally requires `/opt/altera/26.1.1/quartus/linux64/quartus_sta`, argv `quartus_sta -t <that exact query path>`, and that project cwd. Both installed STA hashes match the captured preflight tool identities and are in prelaunch/callback bindings. Part remains `AGFB027R25A2E2V`; candidate `approved=false` and `ready_for_build=false` remain unchanged.

`ia840f_w14query01_gate.py` is byte-exact to the prior Query03 gate after the finite evidence-root, rejection-label, and permission retargets. It requires a separate reviewed authorization object bound to the actual candidate SHA256 and exact permission. Source/tool/link validation precedes native launch. The runner exclusively creates `query.claim` and `query.log`, never deletes a claim, and contains no retry. The claim records live runner PID, parent PID, start ticks, executable, argv, and cwd. Callback validation rereads that whole live identity, verifies the recorded runner context, traverses live ancestry to it, and separately checks the immediate STA context. This is not authorization from a stage environment label alone.

The captured actual prepared runner and dispatcher both reject missing authorization with rc1; preparation checks absence of native claim/log artifacts afterward. The candidate-bound `build_gate.tcl` resolves the scratch dispatcher relative to itself; its retained failure-result variable is checked immediately after `project_open` by the query, addressing the existing Quartus warning-downgrade behavior. No authorization was issued by this reviewer. Any later issuance must remain exclusive and bound to this reviewed candidate; this report does not permit bypassing the gate.

### 3. Workstation protection and persistent execution — PASS

`run-query.py:24–46` checks host, UID, and owned tmux session; requires at least 80,000,000,000 bytes MemAvailable immediately before claiming the run; rejects competing `quartus_`/`qsys-` processes; sanitizes inherited OFS/Python state; selects the installed 26.1.1 tool paths and scratch/PIM roots; sets a 64 GiB address-space limit and applies `os.nice(10)`. Preparation independently checks disk headroom. The native child is awaited without timeout or automatic retry, matching the amended persistent-run specification rather than the predecessor timeout.

Raw native status is persisted before fallible preservation checks/export, and the final status remains `PENDING LOG AND INDEPENDENT REVIEW`. Nonzero/signal statuses are propagated; detected original-tree changes fail the runner. Persistent claim/log/result records are retained. These are ordinary-account operational safeguards and source-bound guards, **not an OS sandbox or a guarantee against all vendor-tool failure modes**.

### 4. Diagnostic scope and evidence content — PASS

`query.tcl` opens the copied existing project, creates the default post-fit timing netlist, reads existing SDC, updates that netlist, performs inspections, and closes it. It has no new clock/exception commands, source edits, fitter/assembler launch, or hardware operations. Loading existing constraints is not a new constraint repair.

All query temporaries are procedure-local within `::ia840f_w14_query`, avoiding the prior global `pins` array collision. The query reports:

- Separate exact divider selectors and cardinalities for `inclk`, `clock_div2`, and `clock_div2x`; these names are not collapsed into aliases.
- Exact divider cell identity/type, all its pins, directions, clock-pin attributes, output target-associated clock counts, and actual input clock fanins.
- Matched clock names, periods, master-clock names, and master source pins when target association resolves.
- Four independently counted receiver groups: `cplto_fifo_avmm_inst` / `rs_dgwp|dffpipe`, `cplto_fifo_lite_inst` / `ws_dgrp|dffpipe`, `u_axi_lite_clk_to_user_avmm_clk_fifo` / `rs_dgwp|dffpipe`, and `u_user_avmm_clk_to_axi_lite_clk_fifo` / `ws_dgrp|dffpipe`, under the explicit PCIe hierarchy. Matching cells' clock-input pins and fanins are inspected.

Enumeration errors rather than silently truncates above 128 selected cells per FIFO group or 32 fanins per inspected clock pin. Divider-cell cardinality other than one and empty FIFO groups explicitly error. Selector, clock-input, fanin, and target-clock counts expose zero findings. `QUERY_INVENTORY_END` precedes the final cardinality checks and therefore is **not** a standalone success marker; `W14_POSTFIT_QUERY_COMPLETE` establishes script completion only.

Captured installed `fim-build-08/pcie-postfit-query-01/api-help2.log` supports the default post-fit netlist operation and the used cell/pin/clock/fanin query forms, including `get_fanins -clock -stop_at_clocks`. Help SHA256: `9ee495aad959b7119eb422b05ecef69345ecda80a7ab87f17d450f6b5d83b6d4`. Exact native object resolution remains the experiment's purpose, not a prerequisite to approving it. No new exhaustive fixture suite or hardware test is required for this diagnostic review.

## Result-review boundary

Before using native findings to propose a constraint change, inspect the complete log, raw native status, gate diagnostics, cardinalities, actual returned names, master/fanin evidence, and original-tree preservation results. Missing selectors, zero input/fanin/clock-target counts, empty master fields, or unsupported API behavior are unresolved/negative findings even if native rc is zero. Target-associated clock counts are not proof of complete propagated-clock coverage; `get_pin_info -net` is documented for output pins and must not make input-pin connectivity claims. The runner's pending acceptance status correctly avoids promoting these findings to success.

This PASS covers only the first bounded diagnostic of the preserved Work14 database. It neither accepts timing nor endorses the inherited release as the final target; the separately selected OFS2026.1-1 prerelease review/migration is outside this package.

## Review actions

Local file inspection, Python parsing, hashing, archive/readback comparisons, and finite source/provenance comparisons only. No remote access, vendor commands, hardware access, authorization issuance, source modification, git operation, or new fixture suite. The only requested artifact created is this review.

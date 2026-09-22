# Native mapping disposition03 — prepare a fresh A/B, not another selector diagnostic

## Verdict

**Yes: the minimum defensible next step is a freshly prepared, independently reviewed isolated A/B STA package on equivalent preserved Work14 copies.** A keeps the original constraints; B changes only the obsolete integration generated-clock definition to the guarded modern divide-by-two definition. Use the complete **unfiltered native fanout collections as a conservative affected-node reporting scope**, backed by global clock, transfer, exception and unconstrained-path comparison. Do **not** first demand proof that every one of the 459 returned nodes is a clock load, and do not describe this result as having supplied that proof.

Diagnostic03 completes the specific mapping experiment requested by the earlier diagnoses. Repeating its six selectors, four fanout contrasts, or scalar-collision investigation would not answer the next question: what the correctly defined clock actually changes. No additional pre-A/B native fact is indispensable to **preparing this experiment**. The actual insertion-time guard state, new-clock propagation, numerical constraints and changed coverage are deliberately measured inside the future experiment, with rejection before creation on an unexpected guard state and no comparison acceptance on incomplete reports.

This is a **source/research recommendation only**, not diagnostic03 result acceptance, SPEC/QUALITY acceptance, authorization, implementation, launch, source promotion or task closure. The separate actual-result review remains the parent's gate. All consumed attempts stay spent; experiment03's old candidate remains unissued/blocked and cannot inherit this recommendation. The helper corrections below are **not implemented**. `ready_for_build=false`; timing and hardware remain blocked. Workstation availability takes priority over progress.

## Evidence notation

All paths are local retained evidence; citations use 1-based file lines. Decoded SDC citations mean payload lines, not JSON container lines.

- `N = /home/joe/Projects/Thesis/AHLS/new_bsp/new`; `R = N/qualification/pcie-clock-repair-01`.
- `H = R/fanout-diagnostic03`; `HQ = H/prepared-readback01/query.tcl`; `HA = H/result-readback01/reports/audit.tcllist`; `HL = H/result-readback01/query.log`.
- `AQ` / `BQ` = `R/experiment03/{baseline,candidate}/prepared-readback01/query.tcl`; `AH` / `BH` are their `clock-repair.tcl` counterparts. A/B query bytes match, as do helper bytes; the helper also matches H's **definition-only** copy.
- `S = N/ofs-agx7-pcie-attach/syn/shared_config/top.sdc`; `V` = decoded `files[].content` whose path ends `/intel_pcie_ss_axi_500/synth/pcie_ss.sdc` in `N/qualification/pcie-generated-evidence-01/pcie-rendered-constraints-live06.json`.
- `A1 = R/api-help01/commands`; `A2 = R/api-help02/commands`; `CELLHELP = N/qualification/fim-build-08/pcie-postfit-query-01/api-help2.log`.
- `Q2 = N/qualification/fim-build-14/pcie-postfit-02`; `STA = N/qualification/fim-build-14/reports11/output_files/ofs_top.sta.rpt`.

Exact object abbreviations (not new executable definitions):

```text
Hprefix = pcie_wrapper|pcie_ss.top|host_pcie.pcie_ss|pcie_ss
P = Hprefix|EP_PFTILE_WRAPPER.gen_pciess.u_pciess_p0|u_pciess|gen_sub.u_hipif
D = P|u_pciess_clock_divider|clkdiv_inst
I = D|inclk
O = D|clock_div2
K = D~div_reg
M = sys_pll|iopll_0_clk_100m
C = Hprefix|avmm_clock0
T = Hprefix|gen_ptile.u_ptile|intel_pcie_ptile_ast_qhip|inst|inst|maib_and_tile|avmm2_3~maib_ss_lib/x0/u5_2/pld_avmm2_clk_rowclk.reg
RX = Hprefix|gen_ptile.u_ptile|intel_pcie_ptile_ast_qhip|inst|inst|maib_and_tile|xcvr_hip_native|rx_ch15
```

## 1. What changed the decision

| Retained evidence | Defensible consequence |
|---|---|
| Both unfiltered O/K collections have 459 unique exact names and are equal; both `-clock` collections are empty. Complete sets are at HA:98–108, especially :101/:105. | The documented all-edge traversal is a usable conservative reporting scope, not a validated clock-only collector. `A1/get_fanouts.txt:29–40` explicitly says no edge selector ignores no paths; `:67–70` explains why adding `-stop_at_clocks` would narrow scope. |
| Four physical group sets have eight cells each (HA:134,240,346,452); all 32 cell→clock-pin→K reverse mappings and cell-derived singleton buried-register mappings complete (HA:135–556). Registers have the same exact names as their respective cells, belong to both default sets, and have empty baseline driving-clock associations. | The earlier physical-cell/keeper uncertainty is resolved **for these 32**, through native mapping, not merely string coincidence. The clock-pin/buried-register APIs are documented at CELLHELP:519–557 and exercised at HQ:154–184. No all-459 physical mapping is claimed. |
| First indexed-name raw selectors resolve once; transformed selectors resolve zero in each of three APIs (HA:115–132). | Stop applying AQ's ordinary-Tcl `[[]` transformation to returned vendor identities. This proves the contrast only for the tested name, not arbitrary future indexed names. |
| C absent; 80 clocks; M period 9.929 ns (HA:2–8). O and K return M as a driving association (HA:84–93); T has no association (HA:109–113). | The repair hypothesis and distinction between definition and propagation remain necessary. The name “100m” is not a measured 10-ns clock. |
| HA:558–559 records complete mapping, expressly “no_collector_acceptance”; HL:493–498 retains the unassigned-divider warning and successful diagnostic completion. | The scalar rename worked in this native run. Its native array origin is still unknown and need not be investigated again. Neither rc0 nor disappearance of a future warning can establish timing success. |

The saved receipts report native/effective/outer rc0, termination and original-tree preservation; H/RESULT.md:7–27 explicitly leaves independent acceptance pending. This report does not redo or consume that separate gate. The canonical sorted/LF default name-set SHA256 recomputed here is `abc890d036cfa941693d691e1aa216adbc8cacbf145e18906bd6bc31def16c08`.

Keep every returned name. The 25 names containing `DUPLICATE` and 79 matching `lutramaN~reg1` are lexical buckets, **not physical equivalence evidence**. Do not strip suffixes, use `-no_duplicates` to conceal discrepancies, or remove nodes to manufacture the fitter's 355. `A1/get_keepers.txt:24–38` expressly distinguishes its duplicated-node matching behavior.

The earlier `forward-lookup-diagnosis01.md:182–188` correctly rejected an A/B resting on an empty purported full domain. That is not today's proposal: there is now a measured nonempty conservative scope with native known-receiver cross-checks, and the future comparison is required to test its sufficiency against global and C-directed evidence. `fanout-contrast-diagnosis02.md:129–139` already says the filter contrast need not be repeated; diagnostic03 supplies its previously interrupted mapping.

## 2. Minimum exact query/helper corrections for the future package

### A. Reuse the measured graph scope without relabeling it

1. **AQ/BQ:69–80:** replace the sole `get_fanouts -clock $output` collector with the already measured unfiltered O and K calls on actual validated collections. Keep each returned collection, its raw count, full names, and differences; form a conservative union with documented `add_to_collection` on real collections if needed (`A2/add_to_collection.txt:22–39`). The fresh A should reproduce the bound 459-name set, not merely its cardinality. Export B's sets independently and compare A-only/B-only/intersection; do not require B to be clock-only or silently discard an unexpected difference.
2. **AQ/BQ:72–73,84–87,100–102:** emit and flush actual counts and caps **before** every assertion. Preserve raw cardinalities before any name deduplication. An API error, mismatched identity, over-cap result or unsupported representation is not an empty set. The old baseline cannot supply these observations: its assertion preceded its count (`experiment03/baseline/RESULT-ACCEPTANCE.md:3–9`).
3. **AQ/BQ:12–19,75–90,104–107:** remove the transformed-name round trip where the existing native collection suffices. Use retained collections directly for fanout, adjacency and report filters; retain the natively proven cell→pins/buried-register route for known32. If a singleton collection is genuinely necessary, use the raw list-protected name and require the **actual count and complete returned exact-name set** to match the intended identity before use. A multi-match caused by duplicate matching is a rejection, not permission to pick the first. Raw first-name success is not pre-acceptance of every lookup. Do not pass individual IDs to collection iteration or invent a singleton constructor. `get_clocks -of_objects` specifically requires a collection (`A1/get_clocks.txt:38–42`).
4. **AQ/BQ:80:** remove “every conservative member must have exactly C.” Require C at the 32 established receiver registers and T, plus the actual C-driven domain discovered by candidate-native reporting; record all other conservative members' available associations/coverage without pretending they are clock loads. Unexpected extra clocks, ambiguous propagation at an established C receiver, or unexplained changed associations fail acceptance. Conversely, do not require baseline C: absent clocks are the baseline condition to account for.
5. **AQ/BQ:61–65:** reuse HQ:60–71's clock-type branch, querying generated-only fields only for generated types and recording non-applicability on base types. Keep diagnostic-specific scalar names, particularly HQ:159–163's `ia840f_fc_cell_pin_collection`. Preserve native collection/object distinctions. Do not switch Timing Analyzer escaping/natural-bus mode; `A2/use_timing_analyzer_style_escaping.txt:22–60` is not permission for a post-SDC global matcher change. No `get_node_info -type`, unsupported `get_collection`/`index_collection`, or arbitrary alias search is needed.

### B. Correct the actual creation guard, not just the downstream collector

**BH:45–55 currently combines two different tests and is not reusable unchanged:** it requires both zero explicit output definitions and zero driving associations. HA:90/:93 shows M as an association; `A1/get_clocks.txt:12,38–42` says that can be an upstream driving clock rather than a definition target.

The minimal future guard must retain BH:29–42's exact singleton I/O directions, divider name/type, M identity, physical source `sys_pll|iopll_0|tennm_pll|outclk[2]`, and incoming M association. At the **actual candidate insertion point**, before creation, log then separately check:

- C name count is zero.
- All explicit clock-definition targets are inventoried; no clock definition targets O or K.
- The output's association is exactly the single expected upstream M, with no duplicate/extra clock; M must not itself target O/K. This is the narrow expected branch justified for testing, **not a claim that insertion-time state has already been observed**. If that state differs, stop before creation and retain the exact precheck; do not broaden the guard live or infer an acceptable state from the post-`read_sdc` diagnostic.
- Global clock identities/definitions before and after creation and after complete SDC loading show only the intended addition, with no replacement or unexpected new domain.

Then create C at O, sourced from I, immediate master M, divide-by-two, with no `-add`, invented nominal period, phase, base clock or alternative name. `V:187–202` supports the modern endpoint target and divide relation, conditional on vendor port/topology logic; `V:218` supports retained async policy. Do not patch that vendor branch. The native target is **clock_div2**, not the fitted `clock_div2x` alias (`Q2/result-readback01/query.log:496–512`).

**BH:60–72 also needs stronger acceptance:** it currently prints source/ratio/waveform and checks target count, but does not assert the exact target name, source or ratio. Require one generated C, exactly O as its sole explicit target, exactly I as source, exactly M as immediate master, native `divide_by=2` and `multiply_by=1` for this generated definition, and the resulting period/waveform relative to the actual M. Reject rather than silently reinterpret an unexpected native ratio encoding. Check the unshifted divide-by-two edge relation, not a new nominal 50-MHz value; installed help describes equivalence to master edges `{1 3 5}` (`A1/create_generated_clock.txt:62–89`). Respect returned precision when checking numerical fields; doubled rounded 9.929 is not an independently measured candidate period. Capture real waveform/edges/inversion and propagation, not just echoed command arguments. Reject conflicting clocks, unexpected targets, ignored creation or absent positive helper completion even with process rc0. The API can overwrite/ignore a creation (`:38–44`), so the `created` flag is not proof.

Install this only in the future scratch top.sdc at original S:35–37, **before** S:43–60 executes. The old candidate's placement at its top.sdc:35–36 is reusable as a location pattern, not an approved implementation. Normal SDC read order remains PLL → PCIe entity → integration (HL:92,144,258). Do not append a clock after `read_sdc`, re-source vendor SDC, or repair period-derived bounds by hard coding them. Insertion-time observation belongs in this guard; it does not require a preliminary diagnostic-only run.

## 3. Make the A/B answer coverage, not just names

The old collector-dependent reporting at AQ/BQ:119–140 is a starting point, **not sufficient unchanged**. The following is the finite reporting amendment, using already captured APIs.

### Conservative sets and independent global backstop

For each side retain the full native O/K sets, their union, known32/T mappings, and synchronous/asynchronous structural adjacency with exact node identities. Compare `A-only`, `B-only`, and common identities; where both sides provide associations, compare old/new clock sets. Keep cross-session comparison in stable exact names, not numerical native handles. Handles must be reacquired independently in each session.

At every enabled corner retain complete global clock definitions/memberships, `report_sdc` and ignored SDC, setup/hold/recovery/removal `report_clock_transfers`, all global domain summaries, global exception statuses including groups, full `report_ucp`, and explicit `check_timing` results. A should match the 80-clock baseline identity set; B should add precisely C without unexplained changes to other definitions. Report unexpected extra clocks/children rather than hiding them under the 256 cap. Recheck relevant wildcard memberships, including `*avmm_clock0`, S:49/51, and the single-group exclusions at S:43–44; no additional matched clock is implicitly acceptable.

In addition to node-scoped reports on the conservative sets, obtain candidate timing/exception coverage directly **to and from C by clock selection**, without relying on the fanout list to define C's domain. This covers C→C as well as C↔every other actual clock, ports and applicable asynchronous controls. Reconcile resulting endpoint identities with conservative membership, structural adjacency, MPW/clock-node information and unconstrained reports. Newly observed C-related endpoints outside the old set are evidence to retain and explain, not to delete. No global change is accepted solely because known32 succeeds.

For every changed transfer pair—including changed exceptions or endpoint/clock associations even if aggregate counts match—retain complete endpoint-pair detail on both sides where applicable: launch/latch clocks and edges, timed/cut/data-delay/unconstrained classification, exception source and winning/overridden status. Native `get_timing_paths` supports setup/hold/recovery/removal, `-false_path`, applicable `-data_delay`, clock/edge filters and `-pairs_only` (`A1/get_timing_paths.txt:3–38`). Partition by the relevant launch/latch clock and edge combination where collapsing by endpoint pair would hide distinct clock cases; keep structural pairs distinct from actual timing paths. No enumeration of every combinational route is required.

**A global transfer matrix is a change detector, not complete endpoint coverage.** It does not subtract path-specific cuts (`A1/report_clock_transfers.txt:29–41`). Also, `-false_path` still reports only constrained paths (`A1/report_timing.txt:112–118`): baseline unclocked adjacency/UCP must account for candidate endpoints absent from A's timing paths. Compare “unconstrained→clocked but cut,” “timed→cut,” “already cut,” and newly timed separately. Do not count a newly hidden path as a timing improvement.

The new package must explicitly fail comparison acceptance if a changed pair/domain lacks corresponding A/B detail. If global differences extend beyond the predeclared native scope, preserve the useful experiment but mark that **specific pair/endpoint set** incomplete. The smallest follow-up is bounded reporting of that exact missing set in fresh copies under a new reviewed gate—not another general selector/fanout diagnostic, an unlimited graph walker, or a silently launched third analysis. This is an experimental completion condition, not a reason to demand a clock-only proof before preparing A/B.

### Exceptions: preserve bytes, prove effect and precedence

Retain every original exception for this isolated comparison. S:49 cuts C↔RX; S:51 cuts M↔C; S:50 is existing M↔RX context. S:57–60's setup2/hold1 multicycles overlap S:51 and receive **no safety credit** while dominated. Common master ancestry does not authorize deleting a vendor-consistent CDC cut; V:191–192 and :218 intentionally coexist. Also compare all other selectors/groups newly covering C, not just those named pairs. (`R/exception-disposition-research.md:92–108`; `R/DISPOSITION.md:5–18`.)

Use global and affected `report_exceptions -report_clock_groups` with active/partially overridden/fully overridden/invalid/ignored status and source locations, plus complete bounded per-exception path summaries. The captured help warns that “Complete” under a restricted from/to scope is not full-design completeness (`A1/report_exceptions.txt:61–96`). `-npaths` is **per exception**, default one; `-num_exceptions` is a separate bound (`:116–135`). Check every exception's returned count against the requested sentinel, reconcile the exception inventory, and reject truncation or an unexplained zero-match. A command-level rc0 or one aggregate count is insufficient. Retain max/min-delay effects as well as clock cuts. Classify changed transfers as supplied vendor-internal CDC, source-supported integration CDC, or unresolved integration paths; cuts alone do not validate the latter.

### Eight FIFO assignments must become numerical, not disappear

Under `P|<FIFO>|auto_generated|`, preserve these exact four pairs of assignments:

| FIFO | Pointer source → receiver at V:631 | Receiver-chain → same chain at V:639 | Baseline STA rows |
|---|---|---|---|
| `u_pciess_cplto_if|cplto_fifo_avmm_inst` | `delayed_wrptr_g*` → `rs_dgwp|dffpipe*|dffe*` | `rs_dgwp|dffpipe*|dffe*` → same | 3622–3623 |
| `u_pciess_cplto_if|cplto_fifo_lite_inst` | `*rdptr_g*` → `ws_dgrp|dffpipe*|dffe*` | `ws_dgrp|dffpipe*|dffe*` → same | 3620–3621 |
| `EP_CFG_IF.u_pciess_cfg_if|u_axi_lite_clk_to_user_avmm_clk_fifo` | `delayed_wrptr_g*` → `rs_dgwp|dffpipe*|dffe*` | `rs_dgwp|dffpipe*|dffe*` → same | 3626–3627 |
| `EP_CFG_IF.u_pciess_cfg_if|u_user_avmm_clk_to_axi_lite_clk_fifo` | `*rdptr_g*` → `ws_dgrp|dffpipe*|dffe*` | `ws_dgrp|dffpipe*|dffe*` → same | 3624–3625 |

These are eight **assignments**, not eight endpoints. Each needs actual matched from/to sets, launch/destination clocks and periods, corner, Required/Actual/Slack, and SDC provenance. Required max net delay is `0.8 × actual destination period`; pointer max skew uses `0.8 × actual source period`; retain V:633–634's max/min-delay handling too. Verify assignment and matching-edge coverage even under async cuts. `report_net_delay` without `-nworst` supplies all matching edges per assignment (`A1/report_net_delay.txt:11,26–37`). For `report_max_skew`, reconcile every assignment's latest/earliest result counts and saturation, not only AQ:138–139's aggregate return (`A1/report_max_skew.txt:13,28–43,52–59,80–83`). Include other changed FIFO checks: V:727–733 enumerates design dcfifos, not solely these four. Missing rows, `Invalid clock`, unreported endpoints or nonnumerical requirements are not repair success.

### Timing, MPW, unconstrained paths and all caps

- Preserve all available/enabled Work14 corner identities and explicit updates. Capture setup, hold, recovery, removal and MPW global summaries and complete affected results. Keep the old global worst20 reports only as labeled samples; they cannot substitute for affected coverage.
- **Replace AQ/BQ:135's MPW `-nworst 20` sample** with bounded exhaustive affected checks using documented `-type all` and an explicit saturation sentinel (the existing 20001 reporting sentinel is suitable). Cover the conservative scope and C/other actually changed clocks, not just known32. Parse every returned check; reject reaching the limit. Minimum pulse high/low and minimum-period checks are distinct; non-register nodes can also have pulse-collapse checks (`A1/report_min_pulse_width.txt:12,17–18,30–58`). Do not claim `-nworst 0` is unlimited: that meaning is not established by this saved help.
- Retain the existing finite bounds: 256 clocks; 4096 affected nodes and 4096 adjacent nodes per source; 50000 adjacency records; 16 corners; path sentinel 20001 with rejection on saturation. Apply the affected-set ceiling to each measured set and its reporting union. Preserve per-file128MiB, total-report1GiB, address-space64GiB and wall1800s bounds (`R/experiment03/SPEC.md:24–26`). Check each path query, each exception, every skew latest/earliest result group and MPW output separately. Any separately imposed exception-count cap also needs saturation rejection and total reconciliation. Do not raise caps, accept truncated text, set unbounded path enumeration, or silently continue after resource exhaustion.
- `report_ucp` must be the detailed form, not `-summary` (`A1/report_ucp.txt:3–13`), with exact affected unconstrained identities reconciled against structural adjacency and B's new timed/cut endpoints. No undocumented claim that its output is exhaustive if native reports expose truncation or unexplained totals. Global no-clock/multiple-clock/generated-clock and uncertainty checks complement that accounting.
- `check_timing` is constraint checking, not full Design Assistant/DRC sign-off (`A2/check_timing.txt:25–45,112–138`; `R/DISPOSITION.md:13–18`). Do not invent replacement DRC switches or waive the existing High-rule findings.

## 4. Reuse, acceptance boundary and the finite stop condition

**Reuse unchanged:** the preserved Work14 fit/netlist, generated/vendor source, original A SDC, all exception statements, exact divider/source hypothesis, known-receiver manifest, successful physical-pin/buried mapping pattern, saved API captures, and the previously reviewed exclusive-run/lifetime/preservation design. Retarget paths/bindings into a fresh package; do not re-open completed UART, memory-generation or DMA tasks. No new installed-help batch is needed for the operations specified here.

**Must change and be reviewed:** the old comparison collector and matching assumptions, count-before-assert ordering, base/generated property branching, output-association versus definition guard, exact postcreation assertions, global/new-domain coverage and per-report completeness/MPW acceptance. Reuse mechanisms, not spent identities or stale reviews. Actual prepared bytes require fresh SPEC→QUALITY→parent binding consumption; the separate diagnostic03 actual-result gate remains pending here. Future guard/entry tests belong to that preparation, not this report.

**Must be established by the future native result:** actual insertion state, one correctly defined C, native ratio/waveform/propagation, all eight numerical FIFO assignments and changed skew/net-delay checks, complete changed-transfer/exception/UCP coverage at every corner, and preserved originals/confirmed termination. Baseline execution or preservation failure blocks B. Native/query failure, ignored required commands, absent completion, report cap or unresolved coverage blocks comparison acceptance. A fully reported negative slack is still useful evidence; it is not a numerical pass or permission to waive/refit. Correct clock binding and numerical timing acceptance must have separate outcomes.

The independent **EMIF1 −0.004-ns hold violation remains** (`STA:126734,126747–126762`, Fast vid2 100C Model, core-user-clock write data→PHY). It is outside this repair and cannot be waived. No fit/seed/settings experiment, maintained-source promotion, vendor-IP edit, hardware/OPAE operation or task-closure claim follows. The practical next artifact is the **fresh corrected A/B proposal**, not another unchanged diagnostic or build.

## 5. Local work performed and byte bindings

This review read/hashed local files, parsed retained Tcl-list records as data (no Tcl evaluation), compared the baseline/candidate source bytes, and decoded/hash-checked the captured vendor SDC. It checked the raw fanout sets and finite mapping/lookup evidence supporting the recommendation; it did **not** independently accept the complete native result package or verify live remote preservation. No remote, vendor/help/native/hardware/git operation, fixture, standalone script or code/source edit was performed. Only this report was authored. No execution failure or unavailable local source blocked this recommendation.

SHA256 values below were recomputed from the local bytes (V from its decoded UTF-8 payload). The historical report/receipt bindings document what was read, not new authorization.

| File or payload | SHA256 |
|---|---|
| `HQ` | `22e5f6e05913325fa14a8753cda91c63bef98bec7893e333972f721e7c6e06b9` |
| `H/prepared-readback01/candidate.json` | `16acaa0babf1103eb573e76459f1e98fafc3aadeeff8b2acb23dd172d61a9949` |
| `H/prepared-readback01/known-receivers.tcl` | `3bca69f770cba775919b7134822ae5eedcb324c1a25ed5540b781667d798ef6a` |
| `HA` | `2ac1320fe295688a6cf5e300bf09bdc3a759499a3dbc0c2019c00a4dccb63b90` |
| `HL` | `8661045fe5aae4e282d03500861aad753233f51740552439d47863628f5ff440` |
| `H/result01.json.gz` | `11e2bf0eaf9e8d0a64ecb5ef7191e176ea0d8ead2563acd6794b0bc16e9461b2` |
| `H/RESULT.md` | `1963fd4609afd2d6181323a83a6cc7dbbaae5545e1b966e6d4828146c4c2125f` |
| `H/native-observations01.json` | `3f532ebf0a7c971e039be6ba02f8cd027e60f980fd831dc65c6b9c1c82c933a1` |
| `H/result-verification01.json` | `c00496f3ff9c0f8ddbeec16ff2b5d60304c48a07f7745863fc8ae4d3f2d529bc` |
| `AQ = BQ` | `b8df8ae59def64392bafb6681791809d7d84fa65451dbd2be4db428df249a8ac` |
| `AH = BH = H/prepared-readback01/clock-repair.tcl` | `8486a48acbe4f024beecefb95d09eeab69ce0331d3f16d4a1f9c0591cdb117f2` |
| `R/experiment03/SPEC.md (also both prepared SPECs)` | `bfeea5337982945c4d5d0cfd0133307a8167d6607cc8ae28516c02ce650599ff` |
| `R/experiment03/baseline/RESULT-ACCEPTANCE.md` | `51091902df286ccc87e2f6e6fb643977de087ad280190759d36705f3c5f56225` |
| `S = old prepared baseline top.sdc` | `8255b34c200a46178174b9788bdc9231072ae829f57c34703cc63dd28ab66c3d` |
| `Old prepared candidate top.sdc` | `eb65af7949f130fffb011c6b5a96a5bc46bde5df7d57d99091e03730a441ff9a` |
| `R/fanout-contrast-diagnosis02.md` | `2449999c2efeef88cee8307250c793b9c3e19042e62307c680f64d40081ea8cc` |
| `R/forward-lookup-diagnosis01.md` | `55a23ac37c58caeb96204e8c552c5cf6ab5e085fd0adeec1993dbfd560f0acf8` |
| `R/exception-disposition-research.md` | `c2f7424e28fc91e4a7631f4a0c8c60cfb9af37825f0904143f7824b17843747f` |
| `R/DISPOSITION.md` | `3794d66b237c6d77c84f62c21b069d7c30117f509583ea54c698965e2343b007` |
| `Q2/prepared-readback01/query.tcl` | `c2acd70013ff567004a77199ebc22a977aeb48af03b83c740c8eda24129a333d` |
| `Q2/result-readback01/query.log` | `6d934bb5862574a6518fc5803d051757eefcb88a3caaf2f7db44850971460b89` |
| `CELLHELP` | `9ee495aad959b7119eb422b05ecef69345ecda80a7ab87f17d450f6b5d83b6d4` |
| `STA` | `8c51a45bcff167fb80feb39a9338c62691401d0fa7be36d7a2caa0d94969c5e6` |
| `V JSON container` | `10e8e2b262ada40ed64e232194e8cdc20ec3f20083b18d0ba12e0f3fd97b3e0f` |
| `V decoded SDC` | `b5fa069c1876031a8f63c1198f98b99dfabf5e7ad0cb748e5614bc235e04c265` |

### Saved API command bindings

| Saved command file | SHA256 |
|---|---|
| `A1/get_fanouts.txt` | `09a71a0d9b786b8f1107fdd985714e18cf532fbee844c5c83511f564e28ae765` |
| `A1/get_keepers.txt` | `cc8b5793e7e0901e98b67ea54b04b762eb9084d3a653c188192da3698935fc34` |
| `A1/get_clocks.txt` | `b06a7efaebb9f06e161c469801a34b6d296506a827dad2db0a423a1ba5367980` |
| `A1/get_clock_info.txt` | `8e18fe3190f23b36be98cd89973915d2b254f35fb35fd99697b4fd691c0d212b` |
| `A1/create_generated_clock.txt` | `2341bafeb05c8737efed3327794e4d8831b80f21221f9e26b810bcfc2e2b583e` |
| `A1/get_timing_paths.txt` | `613130f05e830564cb23eeffe63ecfc4755d77c3257d27a29929d13b1008eb09` |
| `A1/report_timing.txt` | `7a87cb3fd90a407ee6e76df10126406b73212207675fded5e54e5cecd77fd1ce` |
| `A1/report_clock_transfers.txt` | `6439708090dc61a56a419a4c1b0bc14ef7c4b8afb0300e24c2bae3874e19ae78` |
| `A1/report_exceptions.txt` | `740db7ea29c4766fcd56dab6e1d4ab44d8e7072408abdc39dc33cbfbfc1e2974` |
| `A1/report_net_delay.txt` | `2a71a56c22d482516eed89615513dc4a9a4433005429db1ad412b47791b9d4e7` |
| `A1/report_max_skew.txt` | `fc5b4c397f637b511284f654630a07454ecb8f7a1cf37136bfe2350907b9006b` |
| `A1/report_min_pulse_width.txt` | `011791d8b14e110aea6d880fc1506d2b4fd0cf25b0b2b119898d9de760ba0524` |
| `A1/report_ucp.txt` | `d50e1ba58b465e40a5ec47cd544272f0ebe88f786766e8133a0a02d894705abb` |
| `A1/get_clock_domain_info.txt` | `b4b0a1d296b1bd3697956994a966dee84ca07950182b79bf5692070d3b736766` |
| `A2/add_to_collection.txt` | `c6f694f3be7f5d4808c30319a0f4a9c3acbacc792d5f717cde3e5f450af70918` |
| `A2/get_pins.txt` | `07f27e9c9c1f28f080030074929d314010764eddfe7e69cd7f282cfd2865616c` |
| `A2/use_timing_analyzer_style_escaping.txt` | `c4d12abc7ee429a3d078d4d2be11769754baa285b0288eca7f9e3d783f0d8b18` |
| `A2/check_timing.txt` | `ac9789b1b890fa22fbaa42c294146a007e3fae7ac360370eb3f09e5c734ce04e` |

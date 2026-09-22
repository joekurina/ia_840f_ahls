# Fanout contrast diagnosis02 — collision correction, not collector acceptance

## Recommendation

**Recommend only a diagnostic-owned scalar rename at the three `pins` assignment/reference sites in a fresh successor, with a caller-scope array regression.** Keep the existing procedure/namespace, API calls, exact roots, selector contrast, caps, physical/pin/register mapping and completion requirements. Do not unset or alter the existing array. The retained query already runs inside `::ia840f_fanout_contrast::main`; “put it in a procedure” is not a sufficient correction to this failure. The array's native creator and exact scope remain unproven. [`QUERY:73–85,154–185,198`; `LOG:496–520`]

The partial native result answers two narrower questions: removing `-clock` changes each of the same two roots' observed fanout sets from empty to the same 459 unique names; the first indexed raw selector succeeds in all three tested APIs while its `[[]` transformation fails. Neither result supplies a validated complete clock-only collector. All 32 known physical-cell **name strings**, plus the named tile T, occur in both default sets, but this run stopped before any cell-pin/reverse/buried-register mapping. [`AUDIT:94–135`]

This is an independent diagnosis and proposal, **not SPEC/QUALITY acceptance, result acceptance, issuance, implementation, constraint repair or task closure**. G and F remain spent; the old experiment03 candidate remains blocked. No rebuild is recommended while the PCIe constraint/domain question remains unresolved.

## Evidence notation

All citations are to locally retained bytes, with 1-based lines. JSON-contained SDC line numbers refer to decoded content, never evaluation of that content.

- `N = /home/joe/Projects/Thesis/AHLS/new_bsp/new`
- `R = N/qualification/pcie-clock-repair-01`
- `G = R/fanout-diagnostic02`; `F = R/fanout-diagnostic01`
- `QUERY = G/prepared-readback01/query.tcl`
- `KNOWN = G/prepared-readback01/known-receivers.tcl`
- `HELPER = G/prepared-readback01/clock-repair.tcl`
- `MOCK = G/test-query.py`
- `LOG = G/result-readback01/query.log`
- `AUDIT = G/result-readback01/reports/audit.tcllist`
- `Q2 = N/qualification/fim-build-14/pcie-postfit-02`
- `Q3 = N/qualification/fim-build-08/pcie-postfit-query-03`
- `H0 = N/qualification/fim-build-08/pcie-postfit-query-01/api-help2.log`
- `H1 = R/api-help01/commands`; `H2 = R/api-help02/commands`
- `LIVE06 = N/qualification/pcie-generated-evidence-01/pcie-rendered-constraints-live06.json`

Explanatory names, not newly installed Tcl definitions:

```text
H = pcie_wrapper|pcie_ss.top|host_pcie.pcie_ss|pcie_ss
P = H|EP_PFTILE_WRAPPER.gen_pciess.u_pciess_p0|u_pciess|gen_sub.u_hipif
D = P|u_pciess_clock_divider|clkdiv_inst
O = D|clock_div2
K = D~div_reg
C = H|avmm_clock0
M = sys_pll|iopll_0_clk_100m
T = H|gen_ptile.u_ptile|intel_pcie_ptile_ast_qhip|inst|inst|maib_and_tile|avmm2_3~maib_ss_lib/x0/u5_2/pld_avmm2_clk_rowclk.reg
```

## 1. What failed, and what its stack does not prove

Native Error23035 says `can't set "pins": variable is array`, at `set pins [get_cell_info -pins $cell]`, prepared query line159. The stack names the existing main procedure and entry line198. It is an assignment collision, not an observed unsupported `-pins` option, absent cell, cap overflow, invalid collection or reverse-fanin failure. Error23031 follows, and native supervision records rc3, confirmed termination, no live owned PIDs and no supervision errors. There is no reason here to reopen the inherited monitoring/gate design. [`LOG:496–527`]

The first enumerated physical cell was group0's `...|rs_dgwp|dffpipe5|dffe7a[2]`, type `tennm_ff`. This is **not** the first manifest/selector-test name, `...|rs_dgwp|dffpipe5|dffe6a[0]`. Group0's eight physical names exactly match KNOWN, but only one `CELL` record was emitted and no `pins:`, `reverse:`, `CLOCK_INPUT`, `CELL_REGISTER_MAP`, `REGISTER`, `DIAGNOSTIC_STATUS` or `COMPLETE` record followed. [`AUDIT:115–135`; `KNOWN:3–10`; `QUERY:159–191`]

### Scope assessment

- The query's only word-level `pins` uses are the scalar assignment, its observation argument and its iteration argument at lines159,160,163. `main` imports E/audit/complete/mapping_supported/cap, not `pins`; it does not declare a `pins` array. The helper does not supply such a declaration either. [`QUERY:74,159–163`; `HELPER:1–74`]
- An unrelated global `::pins` array is **not by itself sufficient** to reproduce this collision in ordinary Tcl with the actual procedure-local query and ordinary caller-frame iteration. The inert negative control below verifies that both retained and renamed queries complete in that case.
- An array introduced into the evaluating caller frame during mocked `read_sdc`, before evaluation of the collection-loop body, or as a mocked `get_cell_info -pins` side effect does reproduce it. These are deliberately synthetic scope mechanisms, not findings about Quartus internals. Native callback evaluation, caller-scope sourcing or variable linking would need implementation/runtime evidence to distinguish them.
- `read_sdc` is called **inside** main in G, unlike Q2, where SDC loading precedes the namespace procedures. Q2's successful `inspect_cell` uses `pin_collection`, not `pins`, and is itself a separate procedure. Q2 therefore supplies a successful API/storage precedent, but it is not a controlled proof that either procedure isolation or renaming alone caused that success. [`QUERY:73–85`; `Q2/prepared-readback01/query.tcl:3–9,37–54`]
- Historical Q3 also failed at `set pins [get_cell_info -pins $c]`, but in its top-level collection loop. That does not establish the scope of G's later array. [`Q3/query.tcl:35–46`; `Q3/query.log:476–496`]

**Exact vendor origin is unavailable in the inspected evidence.** H0 contains API help, not the implementation or live variable-frame state of `read_sdc`, `foreach_in_collection` or `get_cell_info`. A finite read of LIVE06's three captured generated SDCs found the IOPLL SDC checking/unsetting an existing unqualified `pins` at decoded lines84–86, not creating the observed array. Those older captured bytes do not establish G's complete loaded-SDC closure or executing frame. They cannot justify blaming that SDC, removing it, or copying its cleanup into our query. No vendor source or captured SDC was executed.

The general lesson is narrower than the historical “global array after read_sdc” account: avoid common diagnostic scalar names across vendor entry/callback boundaries, and regress the actual evaluating frame. Procedure/namespace isolation remains useful, but this native result disproves treating it alone as a guaranteed repair.

## 2. Narrow proposed delta and observed inert regression

### Rename only our scalar and its two references

```diff
-                set pins [get_cell_info -pins $cell]
-                set pi [observe "pins:$name" $pins 32 pin]
+                set ia840f_fc_cell_pin_collection [get_cell_info -pins $cell]
+                set pi [observe "pins:$name" $ia840f_fc_cell_pin_collection 32 pin]
                 if {![dict get $pi complete]} {continue}
                 set inputs {}
-                foreach_in_collection pin $pins {
+                foreach_in_collection pin $ia840f_fc_cell_pin_collection {
```

The `-pins` option and `pins:$name` audit label remain unchanged. Do not use a global text replacement of `pins`. Do not catch the error and substitute an empty collection, unset/convert the foreign array, move SDC loading, delete vendor constraints, change escaping mode, or replace pin/buried mapping with same-name assumptions.

This is the smallest source-supported intervention: the native error identifies the destination variable, H0 documents a collection result from `-pins`, and Q2 shows this API returning successfully into a differently named scalar. A diagnostic-specific name reduces this particular collision risk; it is not a guarantee against every unknown vendor side effect. [`H0:519–537,549–557`; `Q2/prepared-readback01/query.tcl:37–54`]

### Actual local experiment performed for this report

The retained 198-line query was evaluated from **memory**, including its full entry line198, in fresh **safe libtcl 8.6.16 interpreters** with newly written inert stubs. A second byte string differed only at the three sites above. No existing fixture was imported or run. Safe interpreters had no real file/exec/load/source access; source/file/open/project/SDC/vendor command names were inert stubs, audit output was held in memory, and KNOWN was parsed as list data. The actual helper and SDC sources were not evaluated. Distinct mock cell/pin/register/collection handles were used, with synthetic timing-register aliases and synthetic forward sets; this was **not a replay or emulation of the native graph/matcher**.

| Array scenario | Retained bytes | Rename-only bytes | Array preservation |
|---|---|---|---|
| No array | Tcl rc0; complete | Tcl rc0; complete | Not applicable |
| Global `::pins` only | Tcl rc0; complete | Tcl rc0; complete | Global sentinel unchanged |
| `read_sdc` stub creates caller-frame `pins` | Tcl rc1, exact array error | Tcl rc0; complete | Sentinel unchanged |
| `foreach_in_collection` stub creates `pins` in the body-evaluation caller frame | Tcl rc1, exact array error | Tcl rc0; complete | Sentinel unchanged |
| `get_cell_info -pins` stub creates caller-frame `pins` before returning its collection | Tcl rc1, exact array error | Tcl rc0; complete | Sentinel unchanged |

All ten executions met their asserted expected outcomes. Each of the three retained failing cases emitted one `CELL`, zero `CLOCK_INPUT`/`CELL_REGISTER_MAP`/`REGISTER`, and no completion marker. Each successful case emitted 32 of each of those four cell/mapping records, a `COMPLETE` record and `IA840F_FANOUT_CONTRAST_COMPLETE`. Caller-array snapshots were taken through the loop wrapper even on failure; their exact contents remained `{fixture_guard unchanged}`. Thus the old-fail/new-pass differential and non-mutation of the **synthetic** array were exercised, not merely proposed.

Byte bindings:

- Retained full query: 12,019 bytes, SHA256 `de849ce56c3ae6db993a1e27d427c574cf6cccb7b7d68272a1c0ca8ab2468e5c`.
- In-memory rename-only query: 12,094 bytes, SHA256 `a6e4534c2ed2cd250832df0bf957c912d6fe8504c5348776abe8d950bdb4e9b4`.
- Newly written inert Tcl stub-body string used in these executions: SHA256 `b819becf0d7998b1991c10503e31589cde2550a27bd13c0665e2e1b65327c386` (transient in-memory test material, not a published fixture/package).

**The rename-only byte string deliberately retains G's spent path. It is not an issuable successor and was not saved.** A fresh package requires its own complete path/context retarget and actual-prepared-byte reviews. The experiments prove ordinary Tcl behavior under the specified synthetic injections, not which injection, if any, describes native Quartus.

### Concrete minimal regression to add in the successor, not implemented here

The existing full-entry fixture's `read_sdc` only checks argument shape; its iteration stub is plain `uplevel 1 foreach`; its `get_cell_info -pins` branch merely returns a mock collection. No caller-frame array is introduced. Therefore its green results do not cover the native collision. [`MOCK:24,54,96–107,157–183`]

Add a dedicated case at `MOCK:54`, preserving the current argument check, with this case-guarded body before returning:

```tcl
if {$::case eq "pins_array_after_sdc"} {
    uplevel 1 {array set pins {fixture_guard unchanged}}
}
```

Do **not** use only `array set ::pins ...`; the global-only control passes on the old query. Keep full-entry execution rather than evaluating extracted procedure definitions only. For the two small companion cases, inject the same caller-frame `array set` (a) in `MOCK:24` when the iteration variable is `cell`, immediately before body evaluation, and (b) inside the `-pins` branch at `MOCK:101` immediately before returning its collection. Label both synthetic, not recovered vendor behavior. They protect against relying exclusively on an assumed SDC-origin story.

Retain old query bytes for the expected-failure differential; compare with the successor's actual prepared bytes. Extend the success-case classification/record assertions at `MOCK:168–176,191`, not just the case list. Require the exact old error plus missing mapping/completion, and new full 32-cell mapping/completion; retain the existing four-forward/six-lookup/T checks and negative cases. Capture caller-array contents through a catching loop wrapper or another inert observation while the frame still exists, and assert that both failing and successful queries leave it unchanged. A test that unsets the array to make the new query succeed defeats the purpose.

## 3. New native observations: questions answered, questions still open

The entire 491,967-byte audit was parsed via `Tcl_SplitList`, **never eval/source**. All 135 records, all 17 occurrence-matched COUNT/SET pairs (including repeated `clocks` labels), unique-name counts and the three recorded set relations were recomputed. Their totals agree with `G/partial-observations01.json`; the scientific statements below derive from the raw records, not merely that summary.

| Actual call on an already resolved collection | Returned names | Unique names | Cap |
|---|---:|---:|---:|
| `get_fanouts -clock $output` (O) | 0 | 0 | 4096 |
| `get_fanouts $output` (O) | 459 | 459 | 4096 |
| `get_fanouts -clock $keeper` (K) | 0 | 0 | 4096 |
| `get_fanouts $keeper` (K) | 459 | 459 | 4096 |

The two default sets are exactly equal, not just count-equal; both filtered sets are empty. T is in each default set and neither filtered set. [`AUDIT:94–113`; `QUERY:97–124`]

Captured help defines `-clock` as selecting clock-edge traversal, and says omitting `-synch/-asynch/-clock` does not ignore any paths. Thus this session establishes a real **filter-dependent returned-set difference** for these roots. It rules out the simple explanation that these valid roots have no reachable objects under every documented call form. It does not establish why native clock-edge traversal omitted loads, or that every default member is a clock receiver. No need to replace the root, add `-stop_at_clocks`, raise the cap or invent a new traversal merely to repeat this already answered contrast. [`H1/get_fanouts.txt:9–17,29–40,67–75`]

For the first known indexed name (`dffe6a[0]`), `get_cells`, `get_keepers` and `get_registers` each returned exactly one raw-selector match with that exact name. Each transformed `dffe6a[[]0]` selector returned zero. **For this name in this native state, the transformed selector is a demonstrated failing lookup while raw succeeds**, not merely an ordinary-Tcl hypothesis. The prior physical-name/keeper-name mismatch explanation is no longer needed to explain this particular failed transformed lookup. It remains inappropriate to generalize string equality to all physical/timing representations or to a buried-register mapping that never ran. [`AUDIT:115–132`; `QUERY:127–135`; prior `R/forward-lookup-diagnosis01.md:68–126`]

The evidence does not identify which native matching feature caused the contrast or the complete post-SDC matching-mode state. Captured escaping help distinguishes Timing Analyzer rules and warns that disabling the mode belongs before constraints/exceptions. Retain the six-way contrast as a control in the minimal successor rather than globally changing `literal`, changing escaping state, or converting all physical names into keeper assertions. [`H2/use_timing_analyzer_style_escaping.txt:22–60`]

The run also recorded C absent, 80 clocks, M driving O and K, and **no clock returned for T**. Native Warning332060 still says K has no associated clock assignment, while Info13166 explicitly identifies T as clocked by K. These coexist; empty clock-filtered sets or M at the source cannot be used to dismiss the unconstrained receiver. [`AUDIT:2–3,84–93,109–113`; `LOG:493–494`]

Warnings were independently recounted and matched to F: 332049×133, 332174×53, 332054×14, 332060×1, total201. This is unchanged baseline diagnostic evidence, not timing acceptance. No complete receiver mapping or completion status was reached in G. Historical Q2's 32 unique group/cell/pin identities and 32 K reverse-fanin observations were independently matched to KNOWN; that earlier positive evidence is not relabeled as G's missing mapping. [`Q2/result-readback01/query.log:513–705`; `KNOWN:3–34`; `LOG:521`]

## 4. Offline bounds on the 459 identities and the apparent extra104

All 32 exact KNOWN cell-name strings occur once in each default forward set, and T occurs once. There are **426 additional unique name strings beyond KNOWN plus T**, not 426 established extra clock loads. All 459 are lexically under `H|`; 437 are under `P|`, and 22 are under the sibling P-Tile hierarchy. This describes the complete **returned set**, not complete native clock-domain coverage. No objects were dropped. [`AUDIT:101,105`; `KNOWN:3–34`]

The following disjoint prefix partition was checked to cover exactly all 459 returned names. FIFO suffixes are relative to P; the last two rows are relative to `H|gen_ptile.u_ptile|intel_pcie_ptile_ast_qhip`.

| Lexical bucket | Total | KNOWN members | T | Other than KNOWN/T |
|---|---:|---:|---:|---:|
| `u_pciess_cplto_if|cplto_fifo_avmm_inst|` | 26 | 8 | 0 | 18 |
| `u_pciess_cplto_if|cplto_fifo_lite_inst|` | 53 | 8 | 0 | 45 |
| `EP_CFG_IF.u_pciess_cfg_if|u_axi_lite_clk_to_user_avmm_clk_fifo|` | 178 | 8 | 0 | 170 |
| `EP_CFG_IF.u_pciess_cfg_if|u_user_avmm_clk_to_axi_lite_clk_fifo|` | 61 | 8 | 0 | 53 |
| Other `u_pciess_cplto_if|` names | 61 | 0 | 0 | 61 |
| Other `EP_CFG_IF.u_pciess_cfg_if|` names | 58 | 0 | 0 | 58 |
| P-Tile `inst|inst|` | 2 | 0 | 1 | 1 |
| P-Tile `soft_logics|` | 20 | 0 | 0 | 20 |
| **Total** | **459** | **32** | **1** | **426** |

The second P-Tile `inst|inst|` name is `...|avmm2_4~maib_ss_lib/x0/u6_2/pld_avmm2_clk_rowclk.reg`; its presence in the returned set is not an independently verified T-like clock association. The soft-logic names include adapter and reset-synchronizer hierarchies. Bucket names and register-looking suffixes alone are not type, edge-class or physical-equivalence proof.

There is a useful **exact lexical count coincidence**, which must not be promoted to identity reconciliation:

- 25 distinct names end in literal `~DUPLICATE`; each also has its suffix-stripped base name present. They are not duplicate strings. Dropping these alone would leave434, not355.
- 79 names match `...|fifo_lutram|lutramaN~reg1`: two in `cplto_fifo_avmm_inst`, 77 in `u_axi_lite_clk_to_user_avmm_clk_fifo`. For every one, the same-container, same-decimal-index string `...|fifo_lutram|dataout_reg[N]` also occurs.
- These two lexical subsets are disjoint. Numerically, `25 + 79 = 104` and `459 - 25 - 79 = 355`.

This supplies a bounded **representation/duplication hypothesis** for the difference from the previously reported fitter Fan-Out355, not proof that these are the exact104 to discard or that the remaining355 are the fitter's identities. Same-container/index naming is not a demonstrated same-physical-object relation; even real replicated registers can be distinct loads. The audit has no full fitter-to-timing-object correspondence or type/clock-edge mapping for these subsets. Preserve all459, all25 suffixed entries, and all79 `~reg1` entries. Do not strip suffixes, deduplicate aliases or accept a collector just because the arithmetic can be made to match. [`AUDIT:101,105`; keeper duplication semantics: `H1/get_keepers.txt:24–38`]

This offline census narrows the extra-node question without requiring another diagnostic expansion before completing the already reviewed 32-cell mapping. Whether additional mapping beyond that is needed should follow the corrected native result, not precede it as speculative scope growth.

## 5. Forward path and retained blockers

1. Preserve both failed attempts and their exact bytes/claims. Propose a **fresh** successor carrying the scalar rename and the specific scope regression; no retries/reissuance of G or F.
2. Keep normal project/netlist/SDC/update ordering; four forward calls on O/K; six first-name contrasts; named T; four exact eight-cell physical groups; documented pin/buried-register collection APIs; all caps, uniqueness/identity checks and completion requirements. In particular, do not omit `-buried_regs`, infer its one-register mapping from string membership, or treat zero/multiple mapping observations as complete collector support. [`QUERY:73–191`]
3. Bind the successor's actual prepared bytes, regress those bytes, then obtain fresh **SPEC → QUALITY → parent acceptance → separate issuer** review/issuance. This report supplies none of those decisions. No new help/native/remote invocation is needed from this diagnosis to invent support for APIs already captured in H0/H1.
4. Judge the subsequent native result on its own output. The rename is source-supported and removes the reproduced scalar/array clash; it does not guarantee native mapping success, a full clock-only domain or constraint/timing acceptance.

The inactive helper still conflates “M drives output O” with “a conflicting clock definition already targets O”: `apply` requires the `-of_objects` result to be empty, although the API includes driving clocks and native G observed M there. Its later `verify_created` requirements are also untested candidate behavior. Neither helper entry was called by this diagnostic. Its actual insertion-point guard/propagation state remains a separate, unapproved future-candidate issue; do not repair/promote it incidentally with this scalar rename or issue a hierarchy-only one-line clock fix. [`HELPER:27–73`, especially `:45–56`; `H1/get_clocks.txt:12,38–42`; `AUDIT:90,93`]

Complete affected-domain coverage, pin/register mapping in G's corrected scope, any safe candidate guard, C propagation, exception/timing comparisons, and mission/hardware qualification remain unresolved. The practical next step is completion of this existing finite diagnostic, not a generic monitor redesign or another full fit with undefined PCIe constraints.

## 6. Verification boundaries and SHA256 bindings

Only this report was written. No project source/query/helper/test, fixture, preparer/runner/gate/issuer, authorization, claim, result or task-state file was changed. No existing test suite, captured SDC, raw audit code, native/help executable, remote command, git/auth operation or hardware action was run. All new Tcl execution was the bounded safe-interpreter experiment described above; the query's source/IO/vendor calls were inert. The retained prepared query was rechecked byte-identical after those experiments. Loaded skills were not edited because this task permits only this report write; the scope lesson is recorded here for the parent.

Bindings below were recomputed from local bytes during this review. They identify the evidence inspected, not a new external-state preservation certification or acceptance of any package.

| Evidence | SHA256 |
|---|---|
| QUERY | `de849ce56c3ae6db993a1e27d427c574cf6cccb7b7d68272a1c0ca8ab2468e5c` |
| KNOWN | `3bca69f770cba775919b7134822ae5eedcb324c1a25ed5540b781667d798ef6a` |
| HELPER | `8486a48acbe4f024beecefb95d09eeab69ce0331d3f16d4a1f9c0591cdb117f2` |
| MOCK | `afd8b37c2d61cfec132210608ae021b7173949ab3cdf339f51b43e7c5a7c1d2e` |
| LOG | `e479371884622dbac60844b9280ac94ab82991d649e5be2132d2bf3aee6fd484` |
| AUDIT (491,967 bytes) | `c85cdb0d21ac800a732c482f7e5f8e1a4d7f80c67de8cce1850340e600bac285` |
| `G/partial-observations01.json` | `8fafdb06e00d7b8049f6bfab5b9577f6626df37f9187c0e2390fa72e4a331e20` |
| `G/RESULT.md` at inspection | `3882a798cf30a7acf4c48d6a548491b3fa620542d0d858003ece5516cd1bbf26` |
| `F/result-readback01/query.log` | `f1a44b052a6cadd56d195010952a254f2fe19f1bdebd85c417ddca195252314a` |
| `Q2/prepared-readback01/query.tcl` | `c2acd70013ff567004a77199ebc22a977aeb48af03b83c740c8eda24129a333d` |
| `Q2/result-readback01/query.log` | `6d934bb5862574a6518fc5803d051757eefcb88a3caaf2f7db44850971460b89` |
| `Q3/query.tcl` | `9eba919bbceb7bf30a330eb9de589bf7d1433ff3df3c68234d7afab7d42af9a1` |
| `Q3/query.log` | `e3696a258947230792affeeb4d301db43337128513ca3e590cb20c19bb034f99` |
| H0 | `9ee495aad959b7119eb422b05ecef69345ecda80a7ab87f17d450f6b5d83b6d4` |
| `H1/get_fanouts.txt` | `09a71a0d9b786b8f1107fdd985714e18cf532fbee844c5c83511f564e28ae765` |
| `H1/get_keepers.txt` | `cc8b5793e7e0901e98b67ea54b04b762eb9084d3a653c188192da3698935fc34` |
| `H1/get_clocks.txt` | `b06a7efaebb9f06e161c469801a34b6d296506a827dad2db0a423a1ba5367980` |
| `H1/get_register_info.txt` | `402e81385d1f2c39db6c53244f46b2e6f561598f19effc3aa83a98950b095398` |
| `H2/use_timing_analyzer_style_escaping.txt` | `c4d12abc7ee429a3d078d4d2be11769754baa285b0288eca7f9e3d783f0d8b18` |
| LIVE06 | `10e8e2b262ada40ed64e232194e8cdc20ec3f20083b18d0ba12e0f3fd97b3e0f` |
| LIVE06 decoded IOPLL SDC | `6d2b95bfe3f3954da1dd60641bf0dac1f215a70c3112943c29752881c89da507` |
| LIVE06 decoded P-Tile SDC | `aa82e3d18d152d231ea0f256dd2e7cb2a62bbb6499ebcb8633dde27b5e7645a0` |
| LIVE06 decoded PCIe AXI SDC | `b5fa069c1876031a8f63c1198f98b99dfabf5e7ad0cb748e5614bc235e04c265` |
| `R/forward-lookup-diagnosis01.md` | `55a23ac37c58caeb96204e8c552c5cf6ab5e085fd0adeec1993dbfd560f0acf8` |

For the offline set computations, the canonical encoding is lexicographically sorted exact UTF-8 names, one per LF-terminated line. Both default sets have canonical SHA256 `abc890d036cfa941693d691e1aa216adbc8cacbf145e18906bd6bc31def16c08`; the 426-name difference after exact removal of KNOWN strings and T has SHA256 `e4643ef0017444781549524c10b0e6f995ad2814a88d57b19a74ecdd02fe68a2`. These are name-set bindings only; the original audit remains authoritative and unmodified.

# Forward-fanout and keeper-lookup diagnosis

## Decision

**There are two separate unresolved native semantics, not one demonstrated escaping bug.** The saved run establishes that the two particular `get_fanouts -clock` calls returned zero. It then establishes that one transformed physical-cell name did not resolve through `get_keepers`. Neither observation establishes absence of clock loads. Fixing indexed-name lookup alone cannot repair the forward collector.

The smallest justified change is to **stop requiring a physical cell name to resolve as a keeper before inspecting its already-observed clock pin**. Use the captured `get_cells` → `get_cell_info -pins` route, and the documented `get_cell_info -buried_regs` collection to expose the physical-cell/timing-register relationship instead of assuming it. In the same fresh, bounded, unchanged-SDC diagnostic, contrast the current edge-filtered forward calls with **`get_fanouts` without an edge-type filter**, on the same two already-resolved roots. This is a specific representation/filter experiment, not a replacement collector or a new generic framework. Record a first-receiver raw-versus-transformed lookup contrast so the escaping hypothesis can be tested rather than silently adopted.

**Do not issue the old candidate, rerun the spent diagnostic, raise a cap, substitute `clock_div2x`, or launch an unchanged full build.** There is not yet a positively validated complete clock-load collector. This report provides no authorization or timing acceptance; `ready_for_build=false`.

## Evidence convention

Paths are local unless explicitly described as captured remote paths. Line citations are 1-based original text lines; generated SDC citations refer to decoded payload lines, not JSON container lines.

- `N = /home/joe/Projects/Thesis/AHLS/new_bsp/new`
- `R = N/qualification/pcie-clock-repair-01`
- `F = R/fanout-diagnostic01`
- `QUERY = F/prepared-readback02/query.tcl`
- `HELPER = F/prepared-readback02/clock-repair.tcl`
- `KNOWN = F/prepared-readback02/known-receivers.tcl`
- `LOG = F/result-readback01/query.log`
- `AUDIT = F/result-readback01/reports/audit.tcllist`
- `Q2 = N/qualification/fim-build-14/pcie-postfit-02`
- `H1 = R/api-help01/commands`; `H2 = R/api-help02/commands`
- `H0 = N/qualification/fim-build-08/pcie-postfit-query-01/api-help2.log` — captured installed Quartus 26.1.1 help, version at lines 1–3.
- `LIVE06 = N/qualification/pcie-generated-evidence-01/pcie-rendered-constraints-live06.json`
- `PTILE = LIVE06.files[2].content`, generated `intel_pcie_ptile_ast_1100/synth/intel_ptile_pcie.sdc`.
- `VSDC = LIVE06.files[3].content`, generated `intel_pcie_ss_axi_500/synth/pcie_ss.sdc`.

Explanatory abbreviations, not new Tcl definitions:

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

## 1. Native facts and the exact failure boundary

| Established observation | Primary evidence | What it does not establish |
|---|---|---|
| C is absent; 80 clocks are inventoried. M has period 9.929 ns. | `AUDIT:2–8` | No new clock was created; the upstream M association is not C. |
| O resolves once as an output clock pin. `get_clocks -of_objects $output` returns M. | `AUDIT:84`; `QUERY:86–89` | This does not prove a clock definition targets O or that M correctly constrains every downstream receiver. |
| O's actual pin collection gives forward clock-fanout count 0, below cap 4096. | `QUERY:90–92`; `AUDIT:85` | Not overflow; not an invalid collection error; not physical absence. |
| K resolves once through each of `get_keepers` and `get_registers`, with exact name equality. Its actual keeper collection gives forward clock-fanout count 0. | `QUERY:94–99`; `AUDIT:86–91` | The prior pin-zero/keeper-positive hypothesis is not supported by this run. |
| Both queried sets were fully enumerated as empty. | `AUDIT:92–94` | `SET_STATUS ... 1` describes enumeration of those returned sets, not adequacy of their clock-domain coverage. |
| First known-receiver `get_keepers` count is 0, expected 1. | `AUDIT:95–96`; `QUERY:118–124`; `LOG:496–511` | No native known-clock-pin/reverse-fanin result was obtained in this run. The failure precedes line 124, not at `get_fanins`. |
| K still has no associated clock assignment, and native Info 13166 names T as a register clocked by K. | `LOG:493–494` | Empty forward queries cannot be interpreted as no clock loads. |
| Native rc3, termination confirmed, no live owned descendants/supervision errors, original Work14/SOURCE/PIM comparisons true. | `LOG:530–537`; saved native/preservation receipts | These are recorded historical results, not a fresh remote inspection. They do not qualify the incomplete diagnostic. |

The fatal error is `CLOCK_REPAIR_REJECT identity count {known_receiver} actual=0 expected=1`, wrapped by Error 23035 and followed by Error 23031. This is the query's assertion after a returned zero-size collection, not an exception saying `get_keepers` does not exist. Recounting the raw log gives 201 warnings: 332049×133, 332174×53, 332054×14, 332060×1; Warning 22890 is absent. No diagnostic completion/support verdict was emitted.

The exact first cell is:

```text
pcie_wrapper|pcie_ss.top|host_pcie.pcie_ss|pcie_ss|EP_PFTILE_WRAPPER.gen_pciess.u_pciess_p0|u_pciess|gen_sub.u_hipif|u_pciess_cplto_if|cplto_fifo_avmm_inst|auto_generated|rs_dgwp|dffpipe5|dffe6a[0]
```

**Independent positive structural evidence remains:** Q2's raw log contains 32 unique `tennm_ff` cells, eight per selected group, each with its saved clock pin and exactly K as reverse clock fanin. The KNOWN manifest's complete group/cell/pin identities match those raw records programmatically. Q2 obtained cells via `get_cells` and pins via `get_cell_info -pins`, then called `get_fanins -clock -stop_at_clocks` on the pin object; it did not establish a same-name keeper lookup. [`Q2/prepared-readback01/query.tcl:24–54,73–98`; `Q2/result-readback01/query.log:513–709`; `KNOWN:3–34`]

Q2 also directly established O, the divider input and its physical upstream PLL output; its `D|clock_div2x` pin query returned zero. [`Q2/result-readback01/query.log:496–512`] The earlier fitter Fan-Out 355 is a different representation/count and is not used as the expected STA collection size here.

## 2. Cause assessment: facts versus interpretations

### 2.1 Confirmed modeling defect: physical cells were promoted to keeper identities without evidence

`QUERY:123` calls `exact get_keepers $cell known_receiver`. Q2's `$cell` names came from the **cell** namespace and `get_cell_info -name`; their types were `tennm_ff`. `get_keepers` instead returns non-combinational timing nodes and may include duplicates. Those APIs do not promise that the physical cell's name is the timing register's name. [`H1/get_keepers.txt:24–38`; `H0:612–649`]

The existing root itself demonstrates that representations can differ: physical divider D and timing register K differ by `~div_reg`. This is evidence that aliases exist, **not** evidence that the FIFO aliases have any particular suffix. Do not invent a FIFO `~reg`, `~q`, or other suffix.

There is already an installed API bridge in saved evidence:

```text
get_cell_info -pins <cell_object>         returns a pin collection
get_cell_info -buried_regs <cell_object>  returns a buried-register collection
```

[`H0:519–537,549–557`] The first route was natively exercised in Q2. The second is documented but **not yet natively measured for these FIFO cells**. Its actual count/names must be observed, not assumed to be one or to equal the cell name. It can separate cell/keeper representation from spelling while avoiding pattern matching on returned register identities.

A correction should preserve a mapping of **physical cell name → actual clock-pin name → actual timing register names**, rather than merging them into a single `all_names` universe. Default duplicate behavior must remain visible; no `-no_duplicates` to conceal a mismatch.

### 2.2 Plausible lookup cause: ordinary Tcl glob escaping was applied to a vendor name-matching interface

The helper performs:

```tcl
string map [list {[} {[[]} {*} {[*]} {?} {[?]}] $name
```

and passes `[list [literal $name]]` to the native command. [`QUERY:13–25`] For the first receiver, its final component becomes `dffe6a[[]0]`.

A bounded, in-memory **ordinary libtcl 8.6.16** calculation performed for this report returned:

```text
transformed final component: dffe6a[[]0]
string match <transformed-full-name> <original-full-name>: 1
string match <original-full-name> <original-full-name>:    0
```

This verifies what the mock's Tcl matcher does, not what Quartus does. A Tcl list protects argument/list structure; it does not by itself specify the native matcher semantics.

Two separate vendor mechanisms matter:

1. Captured installed help says **Timing Analyzer-style escaping is on by default**, distinguishes it from ordinary Tcl/list/string-match escaping, and says to disable it *before adding constraints or exceptions*. That help chiefly explains backslash treatment; it does **not** specify what happens to this nested `[[]` pattern. [`H2/use_timing_analyzer_style_escaping.txt:22–60`; `H1/get_keepers.txt:35–38`]
2. The official **Quartus Pro 26.1.1 Scripting guide** separately documents natural bus naming: enabled by default, recognizes names such as `a[0]` and `a[*]`, and can automatically recognize bus names in commands taking string-match patterns, so double escaping is unnecessary. It distinguishes bus names from arbitrary bus-name patterns. [Official PDF, pp. 45, 325–327; source and hash below.]

These mechanisms make “plain Tcl `string match` accepted it” insufficient evidence. They do **not** prove which mechanism rejected this pattern in this particular STA session. The run did not record a live matching-mode state. The locally inspected query/helper and available source callsites do not establish the mode after every loaded SDC. There is no documented mode-query switch in the captured `use_timing_analyzer_style_escaping` usage; do not invent `-get` or treat a setter invocation as a read.

OFS source is consistent with vendor bus-name handling: `ofs_plat_utils_avalon_dc_fifo.sdc:23–39` uses untransformed indexed patterns such as `in_wr_ptr_gray[*]`; its procedure at lines 89–92 uses Tcl-level backslashes rather than `[[]`. The maintained `fim_dcfifo.sdc:42–62` uses bracket-free hierarchy/leaf wildcards for the same kinds of synchronizer chains. These are **usage precedents**, not native proof of the first receiver's keeper identity or a license to alter those constraints.

**Assessment:** an escaping/dialect mismatch is a credible hypothesis; a physical-cell/timing-register name difference is also credible. Both could coexist. The current result does not choose between them. Changing the global escaping mode to make the mock's assumptions true would change the experiment's constraint interpretation and is not a justified fix.

### 2.3 Confirmed mock limitation, not failed supervision

`F/test-query.py:57–81` builds the mocked keeper namespace from KNOWN's **cell names**, matches them using ordinary Tcl `string match`, and implements `get_registers` as `get_keepers`. The mock therefore assumes both disputed facts: cell/keeper identity and matcher equivalence. Its mocked `get_fanouts` returns fixture lists by scenario rather than exercising a timing graph (`:111–127`); its mocked `get_clocks -of_objects` returns empty (`:92–95`).

Passing inert tests establishes the tested control flow, not native API behavior. No existing test, fixture, gate, runner, preparation package or supervision code was changed or executed for this report. The accepted lifetime/routing mechanisms are not reopened as the bug.

### 2.4 The forward zero is independent of indexed-name escaping

Both forward commands use actual collections returned from successful pin/keeper lookup. O and K contain no bracket index. The failing indexed lookup occurs later. Thus a correction to `literal` cannot explain away the two recorded zero counts or make them become positive retroactively. [`QUERY:86–99,118–124`]

Captured help says `get_fanouts` returns reachable ports/registers and optionally clock targets; `-clock` selects traversal through clock edges. **With none of `-synch`, `-asynch`, `-clock`, it “does not ignore any paths.”** [`H1/get_fanouts.txt:29–40`] This supplies a specific finite contrast: filtered versus unfiltered traversal from the **same** known root collections. It does not guarantee that default traversal returns clock loads, and any non-clock results must not be relabeled as them.

There is source precedent for default traversal on a keeper collection: captured generated PTILE SDC obtains a keeper, calls `get_fanouts $from_keep`, and then examines the returned keepers (`PTILE:357–370`). **That code is inside a `Gen4x4, Interface - 128 bit` branch at line 351 and handles PLL-lock CDC, not this divider.** It establishes the call shape only; it is not proof that the branch runs here or that it solves this clock problem. No relevant direct `get_fanouts` callsite was found in the inspected maintained OFS Tcl/SDC tree.

Possible forward explanations remaining are edge-category/model semantics and logical-pin/synthetic-register representation behavior, potentially including behavior of an unassigned derived-clock source. **None is proven.** Saved help does not say that an undefined generated clock necessarily makes structural fanout empty. The positive reverse-fanin evidence and current T diagnostic argue against “there is no load.”

Adding `-stop_at_clocks` is not the correction: it changes stopping scope and may omit registers reachable only through a clock target, especially after creating C. [`H1/get_fanouts.txt:67–70`] Nor is a root-name string a justified substitute for the already-valid collection merely to retry the same hypothesis.

## 3. A second concrete trap before any future candidate

`HELPER:45–55` calls `get_clocks -of_objects $output` and requires that collection to be empty, under the error text “preexisting output clock.” Yet the native baseline observation is M at O and K. [`AUDIT:84,90`]

The API explicitly returns clocks **defined on OR driving** nodes; if a node is not a clock target it returns driving clocks. [`H1/get_clocks.txt:12,38–42`] Therefore “no generated-clock definition targets O/K” and “no clock is returned by `-of_objects O`” are different conditions. The current helper conflates them. Reusing it unchanged in an equivalent state would reject the observed M association even though C remains absent. The helper's actual insertion-time state during `read_sdc` has **not** been measured, so this is not a claim that B already ran or a guaranteed prediction of its exact failure point.

Before any new B, distinguish and retain:

- C name count and all explicit clock-definition targets at O/K;
- the exact upstream driving-clock association and physical source M;
- any conflicting target definition, extra clock, alternate master or ratio.

The smallest source-grounded *future* guard correction is to recognize the specifically observed upstream M as different from an existing generated clock at O, while still rejecting conflicting definitions and unexpected associations. Its expected state at the actual insertion point must be bound and reviewed; do not merely delete the precheck or allow arbitrary nonempty clocks. Keep the existing generated-clock target O, source `D|inclk`, master M and divide-by-two hypothesis. Vendor VSDC explicitly creates that ratio at O under the native endpoint branch (`VSDC:187–202`) and retains the Lite↔AVMM asynchronous cut (`:218`). No new nominal clock or exception change follows from the M observation.

## 4. Smallest justified next evidence step — proposal only

### One fresh, unchanged-constraint session with two discriminating contrasts

Reuse the accepted source-bound runner/supervision design and existing caps in a separately reviewed fresh attempt. Preserve F, the failed experiment03 baseline, unissued candidate and all originals. This report does not create that attempt or its authorization. Use normal project/netlist/SDC/update ordering; no project-wide hierarchy enumeration, clock creation, mode switch or constraint edit.

**A. Decouple receiver representation from exact-name spelling.**

1. Resolve the existing four **finite physical cell groups** using `get_cells` with full hierarchical, bracket-free leaf patterns already described by the group list (`QUERY:112–113,141–151`, but use the cell API, not an assumed keeper equivalence). `get_cells`' documented default matching is hierarchy-level-aware (`H0:616–640`). Require all returned physical names to equal KNOWN's exact eight names per group, not merely eight arbitrary matches. No broad `get_cells -hierarchical *` replay.
2. For the first saved receiver, obtain its clock pins and buried-register collection from its actual cell handle. Record their raw counts, exact names and types before any expectation. Use the already-native Q2 clock-pin/reverse-fanin route; no intervening `get_keepers $cell` prerequisite. The actual buried-register collection can also be passed to `get_clocks -of_objects`, without constructing a fake collection from a node ID.
3. For **that first saved name only**, record the raw `[list $cell]` versus existing transformed `[list [literal $cell]]` results for `get_cells`, `get_keepers`, and `get_registers`, with resolved names, not just counts. This is a predeclared finite diagnostic matrix, never “try selectors until one works.” Compare with handle-derived buried-register identities. Do not convert API errors to empty sets.
4. If the native identities permit it, carry the same physical-cell/pin mapping through all known32 and record their reverse clock evidence and actual clock associations. Retain any zero/multiple/alias discrepancy as unresolved rather than inventing a name. Observe the separately named T independently; a FIFO lookup discrepancy should not suppress all predeclared forward/T observations.

Interpretation is then discriminating: raw physical-name keeper success but transformed failure supports a dialect problem; physical-cell success with differently named buried registers supports representation mismatch; both differences can coexist. If the physical group or buried-register relationship is unavailable, preserve that result and stop collector acceptance. Do not broaden to an unbounded alias search.

**B. Contrast edge filtering on the same two roots.**

Capture these documented forms explicitly, retaining the existing filtered forms as same-session controls:

```tcl
get_fanouts -clock $output
get_fanouts        $output
get_fanouts -clock $keeper_root
get_fanouts        $keeper_root
```

Here `$output` and `$keeper_root` mean the real validated O and K collections, not strings of object IDs. Emit every raw count immediately. Preserve 4096 as the per-set enumeration ceiling; over-cap means incomplete, not permission to truncate or raise the cap. Keep the existing overall resource/report limits. Do not make the first zero/nonmatching receiver terminate the independent, predeclared count observations; diagnostic incompleteness must still fail acceptance.

If an unfiltered set is positive, export its **entire** in-cap identity set, keeping ports/registers and duplicate discrepancies visible. Compare against the **measured timing-register representation** of known32 and T, not automatically their physical-cell strings. Every extra/non-FIFO/out-of-prefix member needs classification. Mere positivity or inclusion of known32 does not turn a mixed all-edge set into a clock-only collector. Require an explained relationship to actual clock inputs/reverse connectivity and, later, candidate C propagation before adopting it for A/B coverage.

If both unfiltered sets also return zero, this finite contrast has ruled out the simple “`-clock` removed otherwise returned fanouts” explanation in that state. Stop; no recursive graph walker, alternate fitted alias, unlimited enumeration or assumed generated clock is authorized. A further representation/edge investigation would need its own source-supported question. **No additional no-project help is needed for the commands in this minimal proposal:** the cell/pin/buried-register APIs are already captured in H0, and the traversal forms in H1. Re-running help for the same APIs would not determine their design-specific return values or the live matching mode.

### Why not jump directly to an A/B with an empty baseline?

An empty/unconstrained A observation can be a legitimate experimental result; it is not legitimate to rename it a successfully validated complete domain. A revised A/B could only use it if another independently justified method supplies the complete affected structural domain, including nodes missing from timed-path queries in A. **That complete method is not established by the saved evidence.** Known32 plus T is a positive cross-check, not the full set; a candidate-only positive result does not by itself prove what A omitted.

Accordingly, this report recommends the finite representation/filter contrast above, not immediate B issuance. If it supplies an explained full in-cap set, proceed to a freshly reviewed full A/B rather than accumulating more generic mock infrastructure. If it does not, preserve the negative result and explicitly retain the coverage blocker.

Any eventual full comparison must retain all requirements in `R/experiment03/SPEC.md:14–30`: all eight previously invalid FIFO assignments represented and numerical at every enabled corner, actual source/destination periods and required/actual/slack, complete load identities including out-of-prefix loads, actual C propagation, full global transfer deltas, exception precedence/coverage with no safety credit for overridden multicycles, unconstrained paths and min-pulse-width results. Keep the 256-clock, 4096-load, 4096-adjacent-node, 50000-adjacency-record, 20001-path saturation rejection and 16-corner limits unchanged. Global transfer changes outside the selected domain remain gaps to explain. No blanket exceptions, nominal-period invention, source promotion or full-fit acceptance is implied.

## 5. Verification, scope and source bindings

Read-only local size/hash checks matched **all 14 prepared exports and all 8 result exports** to their saved manifests. The raw audit/log warning and tag counts were independently parsed. KNOWN was compared against Q2's raw group/cell/pin records, not its summary: all 32 unique identities match, with eight per group and 32 K reverse-fanin records. A first parsing expression failed because it expected an extra space between closing braces; it was corrected in memory and the complete comparison passed. This was a local parser correction, not a changed artifact or new native result.

The ordinary Tcl calculation above used only in-memory strings and libtcl; it did not source a query or execute any Quartus command. No test suite, native/help entrypoint, runner, gate, remote command, git operation or hardware access was executed. No existing evidence, source, test, authorization or task-state file was edited. The only authored file is this report.

The official Intel command-page URL redirected to the Altera guide landing page rather than the requested command. That redirect was not accepted as command evidence. The guide's official downloadable **26.1.1 PDF** was fetched into memory and parsed through `pdftotext` stdin/stdout; no PDF was published into the project. Relevant sections were checked directly. No forum claim is used as evidence.

### Official documentation citation

[Quartus Prime Pro Edition User Guide: Scripting, document 683432, edition 2026.08.10, version 26.1.1, official PDF](https://docs.altera.com/api/khub/maps/wtxI8~Jixj0Vp7f4eNfbvw/attachments/g~mxIWX1bNFVrI9Xh4oSdQ-wtxI8~Jixj0Vp7f4eNfbvw/content?download=true&locationValue=reader): natural bus naming §2.6.1 p.45; `disable_natural_bus_naming`/`enable_natural_bus_naming`/`escape_brackets` pp.325–327; `use_timing_analyzer_style_escaping` pp.741–742. PDF SHA256 `7622b848e8e5518e8c71b30406ae8243078cc6194eee32f4e80fef799f1528e2` (6,949,899 bytes). These page numbers are the PDF's printed pages.

### SHA256 bindings, recomputed from local bytes

| File / payload | SHA256 |
|---|---|
| `F/result01.json.gz` | `840a2bbd52b448a52c3ccae6ffe9968d09cd0a0a4fb9541044459cdac67bc78f` |
| `F/preparation02.json.gz` | `8fb8eab7b421c0d9fb5f06f6f7169c598dbf347a38c43ae0988793a81e251f3c` |
| `F/prepared-readback02/candidate.json` | `39afbfaec768985d9472da0b95c58df676afd0c273d1257a9f40180b9f44a719` |
| `F/prepared-manifest02.json` | `19c972f6e5e173c3b48e1bef4af73359dec0e695ddecf062daa07762b62e52e3` |
| `F/result-manifest01.json` | `9e85e068ea059ea3f506a2036e9f3db9d512c74bd5646abf1fbaebd75cbd4ed0` |
| QUERY | `16ec28ff6ed66b9867338b09d4d12af0c3fa12d5926efd3b85cdc0c47edd0086` |
| HELPER | `8486a48acbe4f024beecefb95d09eeab69ce0331d3f16d4a1f9c0591cdb117f2` |
| KNOWN | `3bca69f770cba775919b7134822ae5eedcb324c1a25ed5540b781667d798ef6a` |
| LOG | `f1a44b052a6cadd56d195010952a254f2fe19f1bdebd85c417ddca195252314a` |
| AUDIT | `0678b4defced15fc79b3d48a6d6431b1d543637bc9190c5e360784d5007fdce3` |
| `F/test-query.py` | `1131838518fa8b9d2493a88256601536a93cec53320965c96dc03ebf998f1ce9` |
| `Q2/prepared-readback01/query.tcl` | `c2acd70013ff567004a77199ebc22a977aeb48af03b83c740c8eda24129a333d` |
| `Q2/result-readback01/query.log` | `6d934bb5862574a6518fc5803d051757eefcb88a3caaf2f7db44850971460b89` |
| H0 | `9ee495aad959b7119eb422b05ecef69345ecda80a7ab87f17d450f6b5d83b6d4` |
| `H1/get_fanouts.txt` | `09a71a0d9b786b8f1107fdd985714e18cf532fbee844c5c83511f564e28ae765` |
| `H1/get_fanins.txt` | `ae8f82a73242cc5f3a7eb9cfbfd8605dfd74e06d9f0b31582afddf5dc21b346b` |
| `H1/get_keepers.txt` | `cc8b5793e7e0901e98b67ea54b04b762eb9084d3a653c188192da3698935fc34` |
| `H1/get_clocks.txt` | `b06a7efaebb9f06e161c469801a34b6d296506a827dad2db0a423a1ba5367980` |
| `H2/use_timing_analyzer_style_escaping.txt` | `c4d12abc7ee429a3d078d4d2be11769754baa285b0288eca7f9e3d783f0d8b18` |
| LIVE06 | `10e8e2b262ada40ed64e232194e8cdc20ec3f20083b18d0ba12e0f3fd97b3e0f` |
| PTILE decoded payload | `aa82e3d18d152d231ea0f256dd2e7cb2a62bbb6499ebcb8633dde27b5e7645a0` |
| VSDC decoded payload | `b5fa069c1876031a8f63c1198f98b99dfabf5e7ad0cb748e5614bc235e04c265` |
| `N/ofs-platform-afu-bbb/plat_if_develop/ofs_plat_if/src/rtl/utils/quartus_ip/ofs_plat_utils_avalon_dc_fifo.sdc` | `d0eee39ec72c5cf90ac4ba9892f8129e896322cd4d2be11c94f0d871af011c2f` |
| `N/ofs-agx7-pcie-attach/syn/shared_config/fim_dcfifo.sdc` | `545a9765c0cdc0c418eee33fc4e965a31712a46125e8b41025dbbadf2e6e4649` |
| `R/experiment03/SPEC.md` | `bfeea5337982945c4d5d0cfd0133307a8167d6607cc8ae28516c02ce650599ff` |
| Prior hypothesis report `R/fanout-diagnosis01.md` | `f8c83514f3df1433ddf45fa2deb304eab30b1aa6c2d28f74626c68120ae432cb` |

The prior report's positive-keeper-collector hypothesis and advice to preserve its exact-name escaping are **not native proof** and must not be carried forward unchanged. The new result disconfirms the positive-keeper case in this baseline and exposes the name/representation assumption. The proposed contrasts above are deliberately unverified; their outcome, not another idealized mock, must determine the next collector decision.

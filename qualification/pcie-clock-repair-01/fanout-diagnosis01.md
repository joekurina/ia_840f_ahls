# Experiment03 baseline: clock-load query diagnosis

## Decision

**The native failure is the query's own load-cardinality assertion, not evidence that the proposed generated clock is wrong. The saved result does not distinguish zero fanouts from more than 4096.** Recommend one fresh, narrowly scoped **baseline collector diagnostic** that records both the existing output-pin fanout count and fanouts from the independently observed divider keeper. Do not silently replace the collector, raise its cap, or issue experiment03's candidate.

The keeper is a source-supported next starting-node hypothesis, **not yet a natively validated replacement collection**. Native count/set evidence is needed before committing to the full A/B collector. It is not necessary to spend a separate count-only run before testing these two explicitly declared starting nodes together. The next diagnostic should collect both in one normal-load timing session, without creating a clock or changing any SDC.

This report changes no package code, authorizations, constraints, tracked task status or readiness. `ready_for_build=false`. No remote access, vendor/help invocation, runner, gate, test, git or hardware operation was performed. Only this report was written.

## Citation convention and exact objects

`N = /home/joe/Projects/Thesis/AHLS/new_bsp/new`.

- `R = N/qualification/pcie-clock-repair-01`
- `Z = R/experiment03`; `E = Z/baseline`
- `Q2 = N/qualification/fim-build-14/pcie-postfit-02`
- `W14 = N/qualification/fim-build-14/reports11/output_files`
- `H1 = R/api-help01/commands`; `H2 = R/api-help02/commands`
- `QUERY = E/prepared-readback01/query.tcl`
- `HELPER = E/prepared-readback01/clock-repair.tcl`
- `LOG = E/result-readback01/query.log`
- `AUDIT = E/result-readback01/reports/audit.tcllist`

All line citations below are 1-based lines of these saved files. SHA256 bindings are at the end. The following are explanatory abbreviations, not edited or executed Tcl:

```text
H = pcie_wrapper|pcie_ss.top|host_pcie.pcie_ss|pcie_ss
P = H|EP_PFTILE_WRAPPER.gen_pciess.u_pciess_p0|u_pciess|gen_sub.u_hipif
D = P|u_pciess_clock_divider|clkdiv_inst
O = D|clock_div2
K = D~div_reg
F = P|u_pciess_clock_divider|clock_div2x
C = H|avmm_clock0
M = sys_pll|iopll_0_clk_100m
T = H|gen_ptile.u_ptile|intel_pcie_ptile_ast_qhip|inst|inst|maib_and_tile|avmm2_3~maib_ss_lib/x0/u5_2/pld_avmm2_clk_rowclk.reg
```

**O is a logical pin, K a timing-netlist register/keeper representation, and F a fitter clock-net name. F does not include `|clkdiv_inst|`.** Their common hierarchy is not proof that API selectors or fanout sets are interchangeable.

## 1. Native-established facts

### The failing operation

`QUERY:69–73` performs, in order:

```tcl
set output [::ia840f_clock_repair::one_pin "$D|clock_div2" 0]
set loads [get_fanouts -clock $output]
set load_count [get_collection_size $loads]
require [expr {$load_count > 0 && $load_count <= 4096}] "clock load cardinality/cap"
emit LOAD_COUNT $load_count
```

`LOG:574–586,588–602` identifies the `require` expression as the Tcl failure. Error23035 wraps `CLOCK_REPAIR_REJECT clock load cardinality/cap`; Error23031 then reports unsuccessful script evaluation. The call chain got through `get_fanouts` and `get_collection_size`. It does **not** show a missing-collection error at either command.

`HELPER:18–25` explicitly returns the **collection from `get_pins`**, after checking cardinality, exact name, clock-pin status and output direction. Thus the prior node-handle-versus-collection pitfall is not the demonstrated defect here. Rewrapping a node handle as a Tcl list is not a justified fix. The failed assertion implies a count outside the permitted positive range; because `LOAD_COUNT` is after the assertion, **zero versus greater-than4096 remains unknown**.

Local parsing of the saved audit reproduced exactly `BEGIN:1`, `CLOCK:80`, `MEMBERSHIP:6` (`AUDIT:1–87`). There are no load, adjacency, receiver, corner, path or completion records. This phase did not reach `QUERY:74–147`. Its native/effective/outer status is3, termination is confirmed and the three original-tree comparisons are true in the saved records (`E/RESULT.md:3–19`, `E/result-verification01.json:5–16`, `E/result-readback01/native-result.json:2–11`). These are historical captured comparisons, not a fresh inspection of remote originals. The candidate was not authorized (`E/status01.json:1`).

### There is a real downstream clock structure, but its query count is missing

- `LOG:493` identifies K as a clock without an associated assignment; `LOG:494` expressly says register T is clocked by K. This supplies a useful additional receiver outside the four FIFO chains. It does not supply a complete load count.
- Accepted Query02 found one `D|inclk`, one O, and zero `D|clock_div2x` pins (`Q2/result-readback01/query.log:496–500`). The actual input clock path is physical `sys_pll|iopll_0|tennm_pll|outclk[2]` and M with period9.929ns (`:502,504–510`). The corresponding fitter PLL section reports counter2 at100.714286MHz (`W14/ofs_top.fit.rpt:6635,6662–6667`). Do not replace M with its own upstream master or a nominal clock.
- Re-parsing Query02's original receiver lines found four groups of eight unique cells, with all32 clock-fanin records naming exactly K (`Q2/result-readback01/query.log:513–704`; final group counts `:706–709`). Query02's target-name-only zero association results are **not** an exhaustive propagated-clock absence proof (`Q2/query.tcl:11–35`; `Q2/RESULT-ACCEPTANCE.md:19`).
- A bounded fitter excerpt supplies additional useful evidence: F has source node D, source type `CLKDIVBLOCK`, location `CLKDIVBLOCK_X11_Y330_N106`, and **fitter Fan-Out355** (`W14/ofs_top.fit.rpt:31722–31728`; also `:31151,42813`). The full STA independently retains the K warning and T relation (`W14/ofs_top.sta.rpt:209097–209098`).

**355 is the fitter's reported fanout for F, not the missing `get_fanouts -clock $output` count.** It grounds a bounded investigation rather than a cap increase. Differences between physical clock-network fanout and Timing Analyzer reachable keeper collections are not resolved by these excerpts; neither equality to355 nor a zero pin-based result may be asserted. The fitter entry relates F to D, while the reverse receiver evidence relates the selected receivers to K. The exact API-level O↔K load-domain relationship still needs measurement.

### Separate, nonfatal inventory defect

`QUERY:64` requests master/source/ratio properties on every clock without first discriminating its type. `LOG:496–573` contains78 Warning22890 messages tied to that line, saying the information is available only for generated clocks. The audit contains26 base and54 generated clocks. These warnings are distinct from the fatal load assertion; the saved warning counts are `332049:133`, `332174:53`, `332054:14`, `332060:1`, `22890:78`.

In any fresh query, read `get_clock_info -type` first. Query `-master_clock`, `-master_clock_pin`, `-divide_by` and `-multiply_by` only for generated types; emit an explicit not-applicable status for base types, not invented numerical values. Keep name/type/period/waveform/targets inventory for every clock. Installed help lists `base`, `virtual_base`, `generated`, `virtual_generated` (`H1/get_clock_info.txt:3,17–31,44–54`). If a virtual-generated property is inapplicable, preserve its native diagnostic rather than disguising it. Do not suppress Warning22890 globally or filter other warnings out of the raw log. This guard corrects the query, not the SDC.

## 2. What the installed API evidence permits

The saved help logs identify Quartus26.1.1 Build130 (`R/api-help01/readback/help.log:3`; `R/api-help02/readback/help.log:3`). Their hashes match the saved verification manifests, and the command excerpts cited below were locally verified to occur in the captured logs.

| API | Documented behavior | Consequence here |
|---|---|---|
| `get_fanouts -clock <filter>` | Starting nodes may be a pattern/list or collection; `-clock` traverses clock edges. Returns reachable ports/registers and optionally clock targets (`H1/get_fanouts.txt:3–17,29–40,72–75`). | Both the validated pin collection and an exact keeper collection are documented forms worth comparing. Help does **not** say the logical output pin must yield the same results as K, nor that zero is caused by the lack of a clock assignment. |
| `-stop_at_clocks` | Changes stopping behavior; targets may be returned and nodes only reachable through a clock target are omitted (`H1/get_fanouts.txt:67–70`). | Do **not** add it to the load collector as a guessed fix. Creating C in B could then alter stopping scope and hide downstream loads. |
| `get_keepers` | Returns non-combinational nodes; matching includes duplicated keepers by default (`H1/get_keepers.txt:24–38`). | Resolve K with an exact full-name pattern, record count and resolved names, and require one exact root. Do not use `-no_duplicates` to hide an unexpected match. |
| `get_registers` | Returns matching registers, including duplicates by default (`H1/get_registers.txt:25–37`). | A second exact lookup can establish K's register representation; it is a type/identity cross-check, not an alternative silently tried after failure. No documented `-of_objects` switch appears in this command's usage. |
| `get_fanins -clock -stop_at_clocks` | Returns reachable fanin keepers/optional clock targets with documented stop semantics (`H1/get_fanins.txt:29–44,59–68`). | Reuse the accepted reverse-clock check on the known32 exact receiver clock pins in the **baseline** diagnostic. Do not impose an unchanged stopping-target name on B after adding C. |
| `get_clocks -of_objects <collection>` | Accepts register/port/pin/cell collections; returns clocks defined on or driving those nodes (`H1/get_clocks.txt:12,38–42`). | Record actual clock associations on every enumerated load, not only equality to clock-definition targets. This query does not invert a clock into a complete register list. |
| `get_pins` | Returns pin collections and documents absolute versus hierarchical matching (`H2/get_pins.txt:26–45,63–70`). | Keep O as the generated-clock target. Neither K nor F is a drop-in replacement for the validated pin selector. |

No new help capture or generic external documentation is needed to prepare this finite diagnostic. The name-access forms are also directly exercised by accepted Query02 and illustrated in the captured fanout/fanin help. Avoid adding unsupported collection-indexing or a generic graph walker merely to diagnose these two counts.

## 3. Narrow proposed successor diagnostic — not implemented or authorized

### Preconditions and unchanged semantics

Use a fresh owned scratch/evidence identity with exact newly reviewed source/tool/netlist bindings and preserved original Work14/SOURCE/PIM. Retain the accepted Q1 lifetime supervision and S1 strict cwd/report routing design; their acceptance applies to the exact experiment03 bytes, not future changed bytes (`Z/ACCEPTANCE.md:5–15`; `Z/SPEC.md:32–40`). Fresh preparation, SPEC→QUALITY review and parent binding are required. No rerun of the spent experiment03 baseline or mutation/rebinding of its records.

Use the ordinary `project_open` → `create_timing_netlist` → argument-free `read_sdc` → `update_timing_netlist` sequence, as in `QUERY:49–53`. Default `read_sdc` order is documented at `H1/read_sdc.txt:28–37`. Keep all original constraints and positively retain their actual loaded filenames. Do not skip generated/entity SDC, create C after loading, remove cuts, or source the vendor SDC a second time. Confirm C remains absent on this baseline.

Limit this diagnostic to clock/root/load identity and membership. It need not run the expensive adjacency/corner/path-report portion merely to discover the missing count. Its completion must have a distinct diagnostic-only meaning, **never** `IA840F_CONSTRAINT_COMPARE_COMPLETE baseline` or permission to launch B. The failed full comparison remains incomplete even if this diagnostic completes.

### Exact requested outputs

Use procedure-local/namespace-local temporaries. The table is an output contract, not executable replacement code. All reported numbers must come from the new native session.

| Record | Query/data | Check and failure handling |
|---|---|---|
| `ROOT pin` | Current `one_pin "$D|clock_div2" 0`; resolved exact name, cardinality, direction/clock flags, and actual `get_clocks -of_objects` names. | Preserve the existing one-pin validation. Never reinterpret a node ID as a collection. |
| `FANOUT_COUNT pin n cap4096` | Exactly `get_fanouts -clock $output`, followed by `get_collection_size`. | **Emit and flush n immediately**, before any positive-count or cap assertion. |
| `ROOT keeper` | `get_keepers -nowarn [list "${D}~div_reg"]`; count and exact resolved names. Independently record `get_registers -nowarn [list "${D}~div_reg"]` count/names. | Emit counts before asserting exactly one K. Treat zero/multiple/root mismatch as unresolved, not permission to broaden the pattern. |
| `FANOUT_COUNT keeper n cap4096` | Exactly `get_fanouts -clock $keeper_collection`, then `get_collection_size`. | Emit and flush before any positive-count or cap assertion. This is a separately declared probe, not a fallback assigned to `loads`. |
| `LOAD <root> <exact_name> <clock_names>` | For each root collection whose count is at most4096, enumerate **all** returned objects; use exact keeper resolution and `get_clocks -of_objects` as in `QUERY:16–21,75–79`. | Record both raw collection count and unique-name count. Do not silently deduplicate away a discrepancy or truncate the set. Zero is an observed empty set; over-cap is not an empty set. |
| `SET_RELATION` | Complete pin-only and keeper-only names and counts, plus intersection count, when both collections were fully enumerated. | Compare names, not cross-session opaque object IDs. Mark unavailable if either set was capped or errored. |
| `KNOWN_RECEIVER` / `KNOWN_GROUP` | Resolve the four groups below, compare exact names with Query02's saved32 names, and record membership in **each** measured set. Query each receiver's exact clock input with `get_fanins -clock -stop_at_clocks` and record fanin count/names and actual clocks. | Eight exact receivers per group; baseline reverse fanin expected K. Emit every missing name; do not settle for a group count or assume a wildcard still selects the same cells. |
| `NAMED_TILE_LOAD` | Exact T from `LOG:494`: count/name, membership in each measured set, and actual clocks. | Positive cross-check outside the four chains. Its omission is a collector scope discrepancy to explain, not grounds to exclude this known load. |
| `DIAGNOSTIC_STATUS` | Counts, root identities, complete/capped/error flags, membership/set discrepancies and diagnostic-only completion status. | Native/API errors remain errors; no exception catch that converts a failure into an empty collection or comparison success. |

The retained groups under `P|<FIFO>|auto_generated|` are (`QUERY:94–107`; Query02's exact identities are in the saved log):

| Group | FIFO | Receiver chain pattern |
|---|---|---|
| 0 | `u_pciess_cplto_if|cplto_fifo_avmm_inst` | `rs_dgwp|dffpipe*|dffe*` |
| 1 | `u_pciess_cplto_if|cplto_fifo_lite_inst` | `ws_dgrp|dffpipe*|dffe*` |
| 2 | `EP_CFG_IF.u_pciess_cfg_if|u_axi_lite_clk_to_user_avmm_clk_fifo` | `rs_dgwp|dffpipe*|dffe*` |
| 3 | `EP_CFG_IF.u_pciess_cfg_if|u_user_avmm_clk_to_axi_lite_clk_fifo` | `ws_dgrp|dffpipe*|dffe*` |

Preserve the existing exact-name escaping for indexed receiver names (`QUERY:12–19`); a Tcl `[list ...]` preserves word boundaries but does not itself make wildcard brackets literal. A plain Tcl list of extracted names is appropriate for set comparison, not for pretending that it is a native collection.

**Ordering matters:** capture the pin count first; then, if the exact keeper root resolves, capture its count before applying either load-range rejection. A zero pin count must not prevent the explicitly planned keeper diagnostic. Any over-cap set must be reported as incomplete and not enumerated; still retain the other predeclared bounded observations rather than losing both counts. This is diagnostic evidence preservation, not acceptance of an invalid full-baseline collector. If no usable complete set remains, the collector question is unresolved.

Retain4096 as the enumeration ceiling. It is the reviewed operational limit (`Z/SPEC.md:24–26`), not a proven physical maximum. Fitter355 gives no reason to increase it and no authority to assert exactly355. The command obtains a collection before the count is available, so4096 is not a native traversal-runtime bound; preserve the existing owned-child wall/memory/output protections. No unbounded scan or recursive traversal is proposed. Both full sets may be exported independently up to that per-set limit; the diagnostic's total report budget must explicitly cover both.

### How to use the observations

| New observation | Justified next decision |
|---|---|
| Pin count0; keeper set positive, within cap, contains every known receiver and T | Supports K as the structural collector for a fresh full A/B query. Review its complete names, not just32 memberships. Keep the generated-clock target O unchanged and make K the explicit collector in both A and B; no runtime fallback between roots. This does not retroactively establish experiment03's missing count. |
| Pin count above4096 | Original cap branch is now observed on the new session. Stop full-comparison qualification and inspect the recorded scope; do not raise the cap merely to make the assertion pass. Keeper results and Fitter355 can guide a reviewed explanation but cannot waive the overflow. |
| Both positive and within cap | Require their complete set relation to be understood. A new in-range pin result differs from the failed bound baseline's implication; reconcile the actual source/netlist/tool/SDC context instead of calling the old result repaired by chance. |
| Keeper missing/ambiguous, both sets empty, known receiver missing, or unexplained set difference | No validated collector. Preserve the exact discrepancy and stop; it does not justify retargeting the SDC to F, suppressing warnings or narrowing to the FIFO subset. |

The diagnostic is designed to disambiguate the **new measured behavior** and validate the intended collection semantics. It cannot recover an unrecorded value from the spent run. Pin0/keeper-positive is only a working hypothesis until returned by native execution.

## 4. Requirements that must survive the later full A/B successor

The existing scientific hypothesis and exception disposition are unchanged: one guarded generated clock on O from the existing explicit M master, divide_by2; existing asynchronous groups, multicycles and generated vendor SDC remain byte-preserved. Same-pair multicycles receive no safety credit (`R/exception-disposition-research.md:63–108`; `Z/SPEC.md:5–18`; `HELPER:27–58`). This diagnosis does not reopen release selection, older query authority or unrelated memory research.

A successful known32 cross-check is **necessary, not complete-domain coverage**. The final structural collection must enumerate the entire relevant clock-edge fanout, including non-FIFO and out-of-prefix loads, with observed clock association for every returned keeper. Do not filter that collection to the four patterns or require exactly32. In B, the pin target and all intended loads must show actual C propagation. Compare A/B load identities explicitly; clock creation must not silently shrink the enumeration through altered stopping behavior.

Preserve the global transfer matrices, exception precedence/coverage, unconstrained-path outputs, every enabled corner and all eight actual numerical FIFO assignments (`QUERY:111–143`; `R/exception-disposition-research.md:128–139,143–175`). A matrix change outside the selected load set is still a coverage gap, not implicitly accepted. `report_clock_transfers` covers all clock transfers, but its uncut counts do not subtract path-specific false paths (`H1/report_clock_transfers.txt:29–41`); it is not complete endpoint-level proof by itself.

If an independent clock-domain cross-check is needed in the full successor, the already captured `get_timing_paths` syntax supports `-from_clock`/`-to_clock`, `-false_path`, `-pairs_only`, and bounded `-npaths` (`H1/get_timing_paths.txt:17–26,38`). C-scoped timed/cut endpoint sets can be compared against the structural set in B without removing cuts. Never pass an absent baseline C as an empty clock filter and interpret a broad or empty query as valid coverage. Any cap-reaching result stays incomplete; no top-N sample or clock-target-name comparison proves the entire newly constrained domain.

The narrow next action is therefore **fresh collector-diagnostic preparation/review**, followed by an evidence-based choice for a fresh full A/B query. No changed-constraint fit, maintained repair, candidate issuance, timing acceptance or hardware step follows from this report.

## 5. Local verification and source bindings

Read-only local Python parsing/hash checks verified all13 prepared exports and all8 result exports against their saved manifests, with no size/hash mismatch. Prepared baseline and candidate query bytes are identical, and their helpers are identical; neither was modified. Audit tags, warning codes and Query02's exact four eight-cell groups were independently recounted. The full STA/fitter files were hashed, but content inspection was limited to targeted lines, not an unbounded report dump. Captured help-log hashes matched their manifests and all10 command excerpts used here were found verbatim within those logs.

No native fanout count was obtained, no proposed diagnostic code was executed, and no claim is made that the prospective keeper lookup will succeed. The only encountered lookup gap was the absence of a standalone `api-help01/commands/get_node_info.txt`; the required `-name` usage is already supported by accepted native evidence and captured fanout/fanin examples, so it does not warrant another help run.

### Evidence SHA256 (recomputed from local bytes)

| File | SHA256 |
|---|---|
| QUERY | `b8df8ae59def64392bafb6681791809d7d84fa65451dbd2be4db428df249a8ac` |
| HELPER | `8486a48acbe4f024beecefb95d09eeab69ce0331d3f16d4a1f9c0591cdb117f2` |
| LOG | `d2ed7b2c22e56aeedf18b682f53c088cf38f3093c66f28ac60be59b07e7678dd` |
| AUDIT | `8e342dee3ca4d13fbe55b5766da37423294636399bda335ae553bb604eec7d0f` |
| `E/RESULT.md` | `77971eecd6d962b9b8d795a2612b3efa245827d7ab7d6eb3ae010fb7875fa230` |
| `E/result-verification01.json` | `88cab55033e05a25e584ac9952c8fc82fb3dae5a181034b2a82021d66b5ad858` |
| `E/prepared-manifest01.json` | `f40688e915bb01f07759aa9b23aa6a7e216fc65c3905f8e7d99efbf702479b08` |
| `E/result-manifest01.json` | `39676f8ba2fc2d0ab1075af549a341522a0ff5aedb14e83888ec566ef979f4dc` |
| `E/result-readback01/native-result.json` | `3c08c9d82cef9df4e1afaec644e25accbca6631101e9c20b7a890cff14dc2d99` |
| `E/status01.json` | `725a4208520ba038f7d6183e053b4854ef3277912063cdfc4bd5bd1d624c2d70` |
| `Z/ACCEPTANCE.md` | `d571b6e9376b85dfcce06fcf2777322230c516c36762df8b4976b8909f897c96` |
| `Z/SPEC.md` | `bfeea5337982945c4d5d0cfd0133307a8167d6607cc8ae28516c02ce650599ff` |
| `R/exception-disposition-research.md` | `c2f7424e28fc91e4a7631f4a0c8c60cfb9af37825f0904143f7824b17843747f` |
| `Q2/RESULT-ACCEPTANCE.md` | `029ef43854a56808f17616cae84213e543e97746ba371b2eb542062b712706b1` |
| `Q2/query.tcl` | `c2acd70013ff567004a77199ebc22a977aeb48af03b83c740c8eda24129a333d` |
| `Q2/result-readback01/query.log` | `6d934bb5862574a6518fc5803d051757eefcb88a3caaf2f7db44850971460b89` |
| `W14/ofs_top.sta.rpt` | `8c51a45bcff167fb80feb39a9338c62691401d0fa7be36d7a2caa0d94969c5e6` |
| `W14/ofs_top.fit.rpt` | `32b311d2216c1675bf1cfc8813b93d1a55346977dd773a674ff9e8bee9b073ad` |

### Installed-help SHA256

| File | SHA256 |
|---|---|
| `R/api-help01/readback/help.log` | `5a8989da4e1ac8fde989a0c41e39464d3d721e504870836ee23ebe8078ade335` |
| `R/api-help01/verification.json` | `3dd23a0cab952d64a49624bf1f9ece14eec2c562db400c24b0efe613b8b0b8f2` |
| `R/api-help02/readback/help.log` | `3d2e451648689e144cb438ee8dd6f4302ea1ccbe2af00de45f44f0c50c4b3141` |
| `R/api-help02/verification.json` | `be73f8b282b6ad9a0c4bdfbb04f1c66e328340805ba668a2947f8ec5dceaaa2f` |
| `H1/get_fanouts.txt` | `09a71a0d9b786b8f1107fdd985714e18cf532fbee844c5c83511f564e28ae765` |
| `H1/get_fanins.txt` | `ae8f82a73242cc5f3a7eb9cfbfd8605dfd74e06d9f0b31582afddf5dc21b346b` |
| `H1/get_keepers.txt` | `cc8b5793e7e0901e98b67ea54b04b762eb9084d3a653c188192da3698935fc34` |
| `H1/get_registers.txt` | `f6934d6fb2463696e057d1e0c18559f940fc010c1b4f840984069c452ef90c54` |
| `H1/get_clocks.txt` | `b06a7efaebb9f06e161c469801a34b6d296506a827dad2db0a423a1ba5367980` |
| `H1/get_clock_info.txt` | `8e18fe3190f23b36be98cd89973915d2b254f35fb35fd99697b4fd691c0d212b` |
| `H1/read_sdc.txt` | `0e46b0327f7442d18942fd002c0b4848f8b8023d23d9e319ac4fe089e2eb508b` |
| `H1/report_clock_transfers.txt` | `6439708090dc61a56a419a4c1b0bc14ef7c4b8afb0300e24c2bae3874e19ae78` |
| `H1/get_timing_paths.txt` | `613130f05e830564cb23eeffe63ecfc4755d77c3257d27a29929d13b1008eb09` |
| `H2/get_pins.txt` | `07f27e9c9c1f28f080030074929d314010764eddfe7e69cd7f282cfd2865616c` |

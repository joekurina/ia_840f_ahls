# CSR duplicate-branch query07 independent review — FINAL

Status: **FINAL**

**Verdict: ACCEPT WITH FINDINGS. Specification PASS for the completed, narrowly scoped acquisition; quality PASS for exact pin/keeper associations, the bounded nonnegative timing observations, and representative source-side arithmetic/admission/enable connectivity. Query07 closes the particular duplicate-branch reporting hole identified by the accepted05/06 review. It does not establish all-bit mapping, source-cycle equivalence, exhaustive closure of the old negative paths, or full design/hardware acceptance.**

No newly observed functional or timing defect justifies an RTL/SDC/clock-policy change, another fit, or another unchanged representative sweep. Remaining coverage limits must not be recast as observed circuit failures or a newly invented equivalence gate.

## 1. Specification first — acquisition and scope

### Frozen identity and review boundary

I read `CSR-DUPLICATE-BRANCH-SCOPE07.md`, `RESULTS-CSR-PATHS07.md`, the FINAL `csr-data-pin-independent-review01.md`, and `CSR-DATA-PIN-ACCEPTANCE.md`. Prior05/06 acceptance is reused only at its stated acquisition, representative connectivity and numerical boundaries; those reviews are not redone or superseded.

- Frozen package: `csr-duplicate-review-package01.json`, SHA256 **`40feec6131b3436480e6b64379223cd59fe9902bd63cd8043496e98043783377`**.
- Independently read and hashed **all407 listed files / 439617120 bytes**, with **zero byte-count or SHA256 mismatches**. This authored report is not a package member.
- Prior FINAL review independently rehashed to **`2f36edf7819bc3f8f05206e02fa9a037d5248560ec3798dc0fab2da394a2cfe1`**.
- Query07 archive: `result-csr-paths07.json.gz`, **1985462 bytes**, SHA256 **`404650507f9d3f3febf207218574802b3173aa6a24df6f11d143f111050962ff`**; matches `outer-csr-paths07.json`.

All work was static and local: reading, AST/literal decoding, gzip/base64 decoding, hashing, byte comparisons and numerical/set aggregation. No runner or gate was imported or executed. No SSH/network, vendor/simulator/device operation, source edit, Git, mutable CURRENT inspection or task transition occurred. The sole authored file is this report, initially IN_PROGRESS and now FINAL. This review does not authorize execution.

### Acquisition acceptance

| Check | Independently verified07 result |
|---|---|
| Native / effective / outer return code | **0 / 0 / 0** |
| Native identity | Quartus Prime25.1.0 Build129, final snapshot |
| Exported payloads | **46**, base64-decoded, length/hash checked, and byte-matched to local artifacts and output hash map |
| Complete / success / completion marker | all true; native successful banner and `CSR_PATH_QUERY_DONE` present |
| Preservation | setup, release, tools, bound inputs all true; no postflight errors |
| Timeout / owned survivors | false / none |
| Critical bindings / protected physical paths | **5750 / 344** |
| Native errors / warning occurrences | **0 / 159** |
| Hardware access / timing accepted fields | false / false |

The literal configuration binds completed `fit01`, whose archive rehashes to `f33d14f057fb0b5d9351eb0b5a6d9a375cf003a25e25e8c39d1a4f09e9e6d5ee`, and an exclusive `csr-paths07` copy. Config differences against06 are exactly `run`, `root`, `guard`, `contexts`, `query_tcl`; fit/source/generated/release/tool/clock-policy bindings are unchanged. The runner is exactly its template with the literal configuration substituted. Its hash agrees with the dispatch receipt. Standalone, embedded and exported07 Tcl bytes agree.

I reconstructed the full5750-entry critical map from the configuration, including source/generated inputs, copied persona inventory, gate/query, source list and JSON. All13 embedded source payloads match their length/hash declarations. All344 protected hashes agree between configured persona inventory, critical inputs and captured post-run QDB inventory; they are disjoint from the26 enumerated runtime-output roles. The captured QSF before-state equals completed fit01's QSF. Its only query-copy changes are the fitter-to-STA gate replacement and `NUM_PARALLEL_PROCESSORS 2→36`; no fitting, RTL or SDC change is implied by that reporting-resource adjustment.

Native `timing.log:34–60` loads final snapshots for root_partition, green_region and both auto_fab partitions, then confirms successful database loading. The gate event agrees with the native PID136910/start-ticks15828438 and exact STA argv/cwd. The receipt records affinity0–35, 64GiB per-process address-space limit and no competing native jobs. These are retained, hash-bound observations, not a new live workstation measurement, effective-worker count or aggregate-containment claim. The inspected runner keeps all four preservation flags and empty postflight errors in its acceptance expression.

The local definition-only Tcl probe is correctly recorded **NOT RUN: tclsh unavailable** in `csr-paths07-local-preflight.json`. It was not a failed native07 attempt. The completed actual Quartus execution establishes this successor's native Tcl acquisition; do not invent a local probe pass.

### Exact physical cells, pins and requested cut

Let **P** denote the exact common prefix:

`afu_top|pg_afu.port_gasket|pr_slot|afu_main|port_afu_instances|ofs_plat_afu|core|dma|csr_mgr_inst|`

All shortened CSR names below are suffixes after P unless explicitly stated otherwise.

| Seed suffix | Location | Cell / WYSIWYG type | Pins |
|---|---|---|---|
| `dma_csr_map.descriptor.length[14]~DUPLICATE.comb` | **FF_X259_Y66_N13** | cell / tennm_ff | clk, sclr, ena, d; q |
| `dma_csr_map.descriptor.length[0]~DUPLICATE.comb` | **FF_X259_Y69_N26** | cell / tennm_ff | clk, sclr, ena, d; q |

Both are exact singleton seeds in the1139-member CSR inventory, not guessed matches from a DUPLICATE suffix. Each has one buried node/register observation. The query obtains genuine cell-derived pin collections, intersects them with role collections using `A − (A − B)`, then checks cardinality1 and exact enumerated pin-name equality. This is the already-supported06 method, not the failed escaped-name lookup from05 (`csr-paths07.tcl:44–94`). All **10 PIN_ASSOC rows are EXACT_SINGLETON**, with zero GAP rows. Only the four new D/ENA collections become timing cuts; the six accepted06 cuts are not repeated.

In `artifacts-csr-paths07/csr-path-reports/topology.tsv`, length14 ENA and D associations/fanouts are at187–244 and257–309; length0 ENA and D are at582–601 and613–627. Clock pins have immediate-edge inventory but deliberately skipped neighborhood traversal. The56 EDGECOUNT records reconcile to79 edge observations /29 distinct edge IDs, all reported disabled flags0. Repeated selectors do not create additional physical edges. Whole-cell union neighborhoods remain distinct from the exact per-pin associations.

## 2. Bounded numerical verification

I parsed the native topology TSV independently of `csr-path-verification07.json`. Every PATHCOUNT equals the following group's actual PATH-row count. Result: **1200 overlapping worst-per-capture occurrences, 40 nonempty groups, five corners, zero negative slacks, zero SCLR-named launches, zero query gaps**. The largest group is49, below the fail-closed128 cap; the smallest is11.

| New through-pin label | Captures per corner/metric | Setup occurrences / minimum ns | Hold occurrences / minimum ns |
|---|---:|---:|---:|
| length0_duplicate_d | 11 | 55 / **+1.575** | 55 / **+0.088** |
| length0_duplicate_ena | 11 | 55 / **+1.150** | 55 / **+0.221** |
| length14_duplicate_d | 49 | 245 / **+1.404** | 245 / **+0.093** |
| length14_duplicate_ena | 49 | 245 / **+0.954** | 245 / **+0.268** |

Corners are exactly Slow vid2 100C Model, Slow vid2b 100C Model, Fast vid2a 0C Model, Fast vid2a 100C Model and Fast vid2 100C Model. Length14 D's worst setup is at Slow vid2b100C; the other setup minima are at Slow vid2100C. All hold minima are at Fast vid2a0C.

For every group, the capture-name set equals the independently traversed all-edge fanout-keeper set of its exact selected pin, with one row per capture. I also independently checked **all40 detailed reports /160 individual bodies**: the requested pin is an exact element in each **Data Arrival Path**, each slack/from/to tuple matches a native TSV row, the reported corner agrees, and every body says **No SDC Exception on Path**. The header serialization containing `get_pins {}` is not a replay recipe; executed Tcl, exact singleton association and actual arrival-path elements establish the cut.

All81 clock name/type/period/waveform tuples are identical to06. All returned paths launch/capture on the same EMIF0 core user clock, with setup relationship3.000ns or hold0.000ns, setup multicycles1/1 and hold0/0. No relaxed clock or timing exception explains these observations.

`-npaths 128 -nworst 1` is worst-per-capture reporting, not every launch/capture combination. The1200 occurrences overlap. Cap headroom and fanout-set equality are bounded completeness checks for these four cuts, not all-bit, false-path, unconstrained, recovery/removal or reset qualification. In particular, the ENA fanin sets still contain six keepers, including joined_reset_n, reduce_nor_7 and i611; only i2852 setup and Select hold launches are selected. Zero SCLR-named launches does not mean absence of reset/control influence.

## 3. Quality second — source and retimed-graph reconciliation

### Q1. The new source-side arithmetic branch is real, not a renamed add_2 assumption

Each length14 duplicate D/ENA fanout set contains **38 exact members of the52 known add_0 passthrough keepers and zero add_2 keepers**. Its49 captures are38 add_0, eight Select, one i919, one `mmio64_reg.r.data[14]` and the duplicate itself. This is distinct from06's nonduplicate length14 fanout of38 add_2 keepers plus its own representative and FIFO RAM.

There is actual detailed arithmetic evidence, not only arithmetic-like endpoint names: `3_length14_duplicate_d_hold.rpt:405–428` crosses the MMIO data[14] Hyper-Register, duplicate D/Q at FF_X259_Y66_N13, `add_0~186|datac` / `add_0~181|sumout`, and the add_0~181 Hyper-Register at X261_Y68_N0_I31. The native49-capture groups establish the other measured add_0 associations within the cut.

Conversely, the worst detailed D setup route (`2_length14_duplicate_d_setup.rpt:171–218`) goes through duplicate D/Q → **LessThan_3 / i919 / Select** → Select Hyper-Register. It does not traverse add_0/add_1 merely because other captures in the same group do. This additional direct admission-related branch is consistent with the source's live length predicates, but the anonymous logic names are not a bit-level source-equivalence proof.

The38-member add_0 set includes the exact `add_0~26_BLOCK_INPUT_MUX_PASSTHROUGH_X261_Y68_N0_I57_dff` and `add_0~66_BLOCK_INPUT_MUX_PASSTHROUGH_X261_Y68_N0_I56_dff` keepers already used as06 source38-D hold launches. Thus07's incoming arithmetic segment connects, **across those actual registered boundaries**, to the accepted06 add_1 → source38 D/Q → retimed admission segment. No new query is needed merely to discover those existing links. The other14 members of the52-object add_0 family are already in06's length0 cut; their absence from length14's fanout is not a dropped result or proof of missing arithmetic.

### Q2. Payload, enable and duplicated capture remain separate roles

For both duplicate D cuts, all selected setup/hold launches are the same corresponding MMIO payload keepers as06:

- bit14: `mmio64_reg.w.data[14]~DUPLICATE_BLOCK_INPUT_MUX_PASSTHROUGH_X259_Y66_N0_I16_dff`;
- bit0: `mmio64_reg.w.data[0]~DUPLICATE_BLOCK_INPUT_MUX_PASSTHROUGH_X259_Y69_N0_I36_dff`.

The duplicate ENA pins have exactly the same immediate drivers as their corresponding nonduplicates:

- bit14: `i2852~0~cw_ml_mlab/laboutt[8]`;
- bit0: `i2852~0~cw_ml_mlab/lab_lut6outt[2]`.

Every selected ENA setup launch is `i2852~0xsyn_BLOCK_INPUT_MUX_PASSTHROUGH_X260_Y70_N0_I20_dff`; every selected hold launch is `Select_0~10xsyn_20_BLOCK_INPUT_MUX_PASSTHROUGH_X260_Y70_N0_I19_dff`. Those identities match06 exactly. The bit0 hold detail actually reaches the duplicate's ENA and its timing capture (`3_length0_duplicate_ena_hold.rpt:171–187`), not the nonduplicate or SCLR pin. The old duplicated-enable endpoint's functional class now has a representative measured current segment.

Both current cells are explicitly **Bypassed ALM Register** in the routed details. A native node type `reg`, a `.comb` name or a timing path terminating at that keeper does not independently prove architectural storage at that ALM. Keep the actual upstream/downstream Hyper-Registers separate from those bypass arcs.

Length0 duplicate D/ENA each reach11 captures: eight Select, a different i919 representative, descriptor-FIFO RAM, and the duplicate itself. They do **not** have06 nonduplicate length0's104 arithmetic-keeper fanout. Shared payload and enable control do not require identical downstream partitions and do not establish complete source-function equivalence.

### Q3. Exactly eight shared Select objects, not all nine endpoint captures

For each of the four07 pins, intersection with06's nine source38-D captures is **eight exact Select keeper identities**; the same is true against destination37-D. These include the Select X260_Y70_N0_I19 register that launches the ENA hold paths.

The ninth object differs:

-06 endpoint-D: `i919~42_BLOCK_INPUT_MUX_PASSTHROUGH_X258_Y69_N0_I40_dff`;
-07 duplicate cuts: `i919~42xsyn_49_BLOCK_INPUT_MUX_PASSTHROUGH_X258_Y69_N0_I45_dff`.

These are distinct names/locations. Do not coalesce them under “i919” and claim all-nine overlap. The difference is an observed branch distinction, not a missing ninth capture from a07 group: each07 group's capture set already equals its own pin's full traversed fanout set.

### Q4. Old-function → current-pin/keeper ledger

The preserved old report rehashes to `78a9336f50e8416b342940e888eec5eca98d55a9fb7b7c37000657afa8f1572b`. Its −0.367ns path at158260–158295 goes from length14~ENA_dff through nonduplicate length14 ENA/Q, add_0/add_1, write_response/i2590, to old length0~DUPLICATE ENA. That old uninterrupted combinational path must not be relabeled as one of the newly partitioned current paths.

The bound `afu/csr_mgr.sv` decodes byte-identically to `qualification/dma-csr-timing01/csr_mgr-candidate01.sv`, SHA256 `42d09ffffb91152b9f688014bcff9ffc13e5382cddd7f478e5f9b992da232a77`. Source103–124 continuously registers65-bit inclusive endpoints;140–176 retains live length/range/freshness/FIFO/error/control admission predicates;346–395 serializes AW/W/B;410–428 controls descriptor writes/reset. The accepted `dma-csr-timing01/UNIT-ACCEPTANCE.md` already covers bounded functional preservation and the serialization invariant. It is reused, not converted into exhaustive post-fit equivalence or reopened for another simulation.

| Old functional obligation | Current source/physical evidence | Disposition |
|---|---|---|
| Length14 payload/update entry | Exact MMIO data[14] keeper → duplicate D; shared i2852 control → duplicate ENA | Representative payload/control roles independently established. |
| Source-side length arithmetic contribution | Duplicate14 D/ENA →38 add_0 keepers, including the exact add_0~26/~66 storage already linked by06 through add_1 and source38 D/Q | Previously missing representative source-side branch established; not the add_2 branch. |
| Endpoint/range contribution to admission | Reuse06's source38/destination37 D paths and their nine captures;07 independently reaches eight matching Select objects and its distinct i919 | Representative split-chain connectivity; no all-nine assertion or anonymous-logic equivalence claim. |
| Live length/admission path distinct from endpoint arithmetic |07 detailed LessThan/i919/Select route, consistent with retained source length checks | Real measured branch; not falsely routed through add_0. |
| Old duplicated length0 enable capture | Exact Select/i2852 → duplicate0 ENA timing segment, shared enable driver with06 nonduplicate | Specific formerly unqueried duplicate-enable segment covered; bypassed-cell storage semantics remain explicit. |
| Descriptor distribution/readback | Duplicate0 FIFO/admission fanout and duplicate14 readback/arithmetic fanout; source readback and descriptor writes retained | Observed partitioning, not a functional discrepancy merely because sibling fanouts differ. |
| Every old capture, source bit, merge/duplicate and source-cycle/reset behavior | Not established by these representative cuts; accepted directed RTL regression is separate evidence | Existing all-bit/source-equivalent coverage limit remains OPEN, not a newly demonstrated defect or new formal-equivalence prerequisite. |

The useful physical interpretation is a **split set of measured segments**: duplicate14 → add_0 storage; selected add_0 storage → add_1 / source endpoint bypass → admission storage; selected admission storage → enable logic / duplicate0. Setup and hold select different launches, and the source endpoint boundary has been retimed. **Do not concatenate slacks, erase registers, infer a single cycle from shared nodes, or claim exhaustive old-negative closure.**

## 4. Remaining obligations and smallest necessary next action

**For the two-cell representative question, no further native acquisition is necessary.** The source-side arithmetic contribution and duplicated enable association sought by scope07 have both been observed. Accept this bounded result and use the ledger above; stop the representative CSR sweep rather than requesting another unchanged06/07 pass, a refit, or a source/constraint change.

The remaining named obligations are evidence limits, not failures of07:

1. The old sample also contains length17/19 and duplicated3/5 captures. Retained03 inventory has current `length[17]~.comb` at FF_X260_Y65_N14, `length[19]~.comb` at FF_X259_Y66_N16, `length[3]~.comb` at FF_X259_Y69_N5 and `length[5]~.comb` at FF_X261_Y69_N50 (observations.tsv:112,139,224,226), with length17 SCLR separately recorded. Those names/locations alone do not associate all old captures or prove what happened to the old duplicate suffixes. Preserve their source/merge/current-pin mapping as unresolved; do not label a missing old spelling a lost circuit.
2. Existing family inventories and representative observations are not a bit-by-bit endpoint/length census. Carry/range cases, all merged or duplicated members, reset/control behavior and cut/unconstrained paths do not become covered by positive representative timing. In particular, neither the38/52 arithmetic subset nor the eight/nine endpoint overlap is a failed coverage count for the actual07 request.
3. Reuse the accepted directed CSR functional regression and its AW/W/B serialization maintenance invariant. No evidence here requires a fresh generic formal-equivalence campaign, all-bit sweep or repeated unit regression as a newly invented execution gate. Conversely, do not silently upgrade that directed acceptance to an exhaustive claim.

**Smallest parent action:** consume this FINAL review at its bounded acceptance level and retain the explicit unresolved rows in the existing coverage/merge ledger while continuing the already-authorized source-side qualification work. If a later claim truly requires all-old-capture or all-bit closure, first resolve a specifically named residual source/merge association from the already-retained synthesis/inventory evidence. Only an actual remaining discriminator—not merely the word OPEN—can justify one separately scoped new pin/keeper segment query. No such additional query is needed to answer scope07, and none is authorized by this report.

## 5. Unchanged signoff and hardware boundaries

The159 warning occurrences are independently reconciled by ID:332049×58,332054×41,332174×40,18502×17,20031×1,20727×1,332158×1. Successful exact-pin acquisition does not clear these inherited clock/constraint/PR diagnostics.

Retain the accepted full-STA **Timing Closure Pass / Design Closure FAIL / Unconstrained Paths FAIL** distinction and **22 of88 failed signoff rules**. Unconstrained I/O, reset extension/release, CDC/exception findings, missing/disabled categories, metadata, freeze, DMA drain/fence and host-buffer lifetime, electrical/PR boundaries and hardware qualification remain unresolved at their prior boundaries. Query07 does not establish safe live reset, PR, deployment, DDR/PCIe/OPAE operation or a hardware data-check pass. **Vendor DDR simulation remains SKIPPED BY USER.**

**Bottom line:** acquisition and exact new pin associations are sound; the duplicate source-arithmetic and enable reporting holes are closed representatively with nonnegative measured segments under unchanged timing policy. Broader source-equivalent/all-bit claims remain unproven, but there is no new observed defect and no technical reason to repeat this completed narrow diagnostic.

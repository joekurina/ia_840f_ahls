# CSR topology05 / data-pin06 independent review — FINAL

Status: **FINAL**

**Verdict: ACCEPT WITH FINDINGS for completed acquisition, the reported nonnegative numerical observations, and representative arithmetic/data/descriptor-enable connectivity. Original negative-path source equivalence and all-bit coverage remain NOT ESTABLISHED.** No implementation or timing-policy correction is justified by these observations. The useful remaining discriminator is the unqueried duplicated length/enable branch, not another unchanged six-pin sweep.

## 1. Specification first: scope and acquisition

I read `CSR-DATA-PIN-REVIEW-SCOPE01.md`, `RESULTS-CSR-PATHS05.md`, `RESULTS-CSR-PATHS06.md`, and the completed `csr-path-independent-review01.md` before accepting the new evidence. This review advances the prior pin/connectivity question; it does not repeat or supersede the accepted CSR03/04 acquisition review. The prior report hashes to `be9593dcc2c678fd534db9a356de4b8f46a72a20eb0f7b7f0cb1041dd618582e`.

Frozen package: `csr-data-pin-review-package01.json`, SHA256 **`85acb80c45be1e8c2ccd4355971f0267a307dc038cafa56fb2c914cfafc39cdf`**. I independently read and hashed **all 345 listed files / 419587668 bytes**, with **zero size/hash mismatches**. This review is excluded from that package.

All work was local static inspection, AST/literal parsing, decompression, byte comparison and numerical aggregation. No runner or embedded gate was imported or executed. No SSH/network, native/vendor/simulator/device operation, Git, source modification, mutable CURRENT inspection, or task transition occurred. The sole authored deliverable is this file, initially IN_PROGRESS and now FINAL. This review confers no execution authority.

| Specification check | Topology05 | Data-pin06 |
|---|---:|---:|
| Native / effective / outer return code | 0 / 0 / 0 | 0 / 0 / 0 |
| Native tool banner | Quartus 25.1.0 Build 129 | Quartus 25.1.0 Build 129 |
| Exported payloads decoded, size/hash checked, byte-matched to local artifacts | 6 | 66 |
| Gzip archive bytes | 527691 | 2754810 |
| Critical input bindings | 5750 | 5750 |
| Protected physical paths | 344 | 344 |
| Four preservation flags / complete and success markers | all true | all true |
| Postflight errors / timeout / owned live survivors | none / false / none | none / false / none |
| Native errors / warning occurrences | 0 / 177 | 0 / 159 |
| Exact pin lookups | 18 failed escaped-name lookups | 18 exact singleton associations |

Recomputed archive hashes, also matched to the outer receipts:

- `result-csr-paths05.json.gz`: `a83901e5fef0665e2c270f8bd20130271262aaab903eb00c4ed1ca687d4b6e21`.
- `result-csr-paths06.json.gz`: `6be3c55b4e7a76c1e2c678c894716cf1ee0e3d0f7a226c06819bcc493aee1275`.

Both literal configurations bind the same completed `fit01` result, SHA256 `f33d14f057fb0b5d9351eb0b5a6d9a375cf003a25e25e8c39d1a4f09e9e6d5ee`, and independently fresh query roots. Standalone, embedded and exported query Tcl are byte-identical within each attempt. The captured QSF before-state matches the completed fit QSF; its only changes are the fitter-to-STA gate replacement and NUM_PARALLEL_PROCESSORS 2→36. There is no RTL/SDC/clock-policy change. The 344 protected hashes agree between configured inventory, critical inputs and captured post-run QDB inventory, and are disjoint from the 26 explicitly enumerated runtime-output roles. The critical map agrees with the configured source, generated, persona, gate, query, source-list and JSON bindings. The resource receipt records affinity 0–35, a 64 GiB per-process address-space limit and no competing native jobs; these are not claims of aggregate containment or effective worker count.

Native logs load the **final** snapshots of root_partition, green_region and both auto_fab partitions and confirm successful database loading (`artifacts-csr-paths05/06/timing.log:33–60`). Gate-event PID/start-ticks/argv/cwd agree with the native command records. Preservation of the original fit, release, tools and bound sources is accepted from the hash-bound receipts and reviewed checking logic, not presented as a new live workstation measurement. Both archives deliberately retain `timing_accepted: false`; successful acquisition is not full signoff.

### Exact collections and physical identity

Let **P** denote the exact common prefix:

`afu_top|pg_afu.port_gasket|pr_slot|afu_main|port_afu_instances|ofs_plat_afu|core|dma|csr_mgr_inst|`

| Seed suffix after P | Physical location | Enumerated input / output pins |
|---|---|---|
| `src_last_q[38]~.comb` | FF_X261_Y68_N46 | clk, sclr, d / q |
| `dst_last_q[37]~.comb` | FF_X255_Y68_N43 | sclr, clk, d / q |
| `dma_csr_map.descriptor.length[14]~.comb` | FF_X259_Y66_N14 | sclr, ena, d, clk / q |
| `dma_csr_map.descriptor.length[0]~.comb` | FF_X259_Y69_N25 | clk, sclr, ena, d / q |

All four seeds occur exactly once in the 1139-member CSR inventory. Cell type is `cell`, WYSIWYG type `tennm_ff`; the seed objects remain native type `reg`. Names alone do not settle physical storage activity.

05's 18 zero pin-name lookup results and 18 GAP rows are retained as failures of that lookup method, not as absent pins. Its cell-derived pin handles, immediate edge records and synchronous whole-cell union neighborhoods remain valid. 06 uses **A minus (A minus B)**, where A is the genuine cell-derived pin collection and B the genuine simple role-suffix pin collection. It checks singleton cardinality and equality with the just-enumerated pin name before use. The six `d`/`ena` collections, not register collections or reconstructed escaped strings, become `-through` arguments (`csr-paths06.tcl:51–80,96–109,134–162`).

This is supported by captured installed help: `csr-help02.log:235–252` for cell pins, `382–437` for edges, `515–530,614–625` for keeper traversal, and `csr-help03.log:99–140` for collection subtraction. Help02/03 archive hashes/outer receipts and exported help text were checked. `index_collection` remains explicitly unavailable in captured help03; 06 does not depend on it or change the escaping mode.

Both topologies contain the same **119 edge observations / 41 distinct edge IDs**, with all recorded disabled flags zero. All 104 EDGECOUNT records reconcile with their following edge rows. Repeated observation through different traversal selectors is not additional physical connectivity. Returned edge types include asynchronous CELL arcs on the bypass paths: neither the selector label nor that edge-type string alone establishes a CDC crossing. 06's unrestricted edge-class keeper neighborhoods are intentionally distinct from 05's `-synch` union neighborhoods; do not attribute every union member to every pin.

## 2. Recomputed numerical acceptance — bounded to the six pins

I parsed the native `artifacts-csr-paths06/csr-path-reports/topology.tsv`, independently of the prepared verification JSON. Every PATHCOUNT equals its PATH-row count. The result is **3100 nonnegative path-record occurrences, 60 nonempty groups, zero query gaps, and zero SCLR-named launches**. These occurrences overlap; they are not 3100 distinct physical paths.

| Through-pin label | Records per corner/metric | Setup occurrences / minimum ns | Hold occurrences / minimum ns |
|---|---:|---:|---:|
| destination37_d | 9 | 45 / +0.637 | 45 / +0.754 |
| length0_d | 106 | 530 / +1.367 | 530 / +0.088 |
| length0_ena | 106 | 530 / +0.915 | 530 / +0.221 |
| length14_d | 40 | 200 / +1.223 | 200 / +0.093 |
| length14_ena | 40 | 200 / +0.704 | 200 / +0.268 |
| source38_d | 9 | 45 / +0.766 | 45 / +0.684 |

The five corners are Slow vid2 100C, Slow vid2b 100C, Fast vid2a 0C, Fast vid2a 100C and Fast vid2 100C, each with its native `Model` suffix. The smallest group has 9 records; the largest has **106, below the fail-closed cap128**. For each pin, the returned capture-name set equals its separately enumerated all-edge fanout-keeper set in every corner/metric group, with one record per capture. This is useful endpoint-set reconciliation **within the chosen six-pin cut**, not an all-bit census.

The **60 detailed reports contain 240 individual path bodies**. In every body I checked the exact requested pin in the **Data Arrival Path table**, not merely in the command header; each body's slack/from/to tuple matches a TSV row. Every body reports `No SDC Exception on Path`. Thus the claim is stronger than “the pin name appears somewhere in each report,” while still limited to the four worst detailed paths per group. The report's serialized command sometimes renders the cell-derived collection as `get_pins {}`; this is not the acquisition script or a safe replay recipe. The executed Tcl, singleton associations and actual arrival-path pins establish the real query.

All **81 clock name/type/period/waveform tuples** agree between05,06 and the accepted full-STA Clocks panel; only whitespace serialization and type capitalization were normalized for comparison. Every returned path uses the same EMIF0 core user clock at launch/capture, with setup relationship3.000 ns or hold0.000 ns. The recorded setup-end/start multicycles are1/1 and hold-end/start0/0 throughout. No altered timing requirement explains the positive slacks.

`get_timing_paths -npaths 128 -nworst 1` is worst-per-endpoint reporting, not enumeration of every launch/capture pair (`csr-help01.log:1042–1044,1068–1076`). The 39 source-D fanin keepers and 38 destination-D fanin keepers are not all separately selected launches. Unreturned, cut, unconstrained, recovery/removal and other-bit paths do not gain acceptance from cap headroom. The recomputed counts/minima agree with `csr-path-verification06.json`.

## 3. Quality second: what the physical data now establishes

### Q1 — the former reset-only substitution is genuinely corrected

The source and destination pin graphs distinguish arithmetic D from clear control:

- `Padd_1~26|sumout → Psrc_last_q[38]~.comb|d → |q`, separately from `Psrc_last_q[37]~SCLR_dff|q → ...|sclr → |q` (06 topology lines109–139).
- `Padd_3~76|sumout → Pdst_last_q[37]~.comb|d → |q`, separately from `Pdst_last_q[38]~SCLR_dff|q → ...|sclr → |q` (lines385–426).

Actual routed setup paths start at address passthrough Hyper-Registers, cross arithmetic carry/sumout logic and these bypassed D→Q arcs, then reach i919/Select logic and retimed capture storage. Concrete examples:

| Report under `artifacts-csr-paths06/csr-path-reports/` | Observed routed segment |
|---|---|
| `1_source38_d_setup.rpt:171–234` | src_addr[0] passthrough at X261_Y68_I4 → add_1 carry/sumout → source38 D/Q → i919 → Select_0~10xsyn_20 capture at X260_Y70_I19 |
| `1_destination37_d_setup.rpt:171–236` | dest_addr[0] passthrough at X255_Y68_I4 → add_3 carry/sumout → destination37 D/Q → i919 → the same Select capture |
| `3_source38_d_hold.rpt:171–215` | add_0~66 passthrough at X261_Y68_I56 → add_1 → source38 D/Q → i919~42 capture at X258_Y69_I40 |
| `3_destination37_d_hold.rpt:171–217` | add_2~76 passthrough at X255_Y68_I63 → add_3 → destination37 D/Q → that i919~42 capture |

Locations abbreviated X/Y/I in this table refer to the full `BLOCK_INPUT_MUX_PASSTHROUGH_X..._Y..._N0_I...` locations printed in those reports, not new node aliases. Across all records, source setup selects src_addr[0]; source hold selects add_0~26 or add_0~66. Destination setup selects dest_addr[0]; destination hold selects add_2~76. Each D pin reaches the same nine returned captures: eight Select representatives and one i919 representative.

These are accepted representative **arithmetic-through-endpoint-data-to-admission-related** physical routes. They are not the SCLR paths accepted numerically but rejected semantically in03/04. They also do not demonstrate two sequential transfers at the original `src_last_q`/`dst_last_q` source boundary: the routed tables explicitly call the intervening cells **Bypassed ALM Register**. The relevant physical registers have moved into the surrounding arithmetic/admission cones.

### Q2 — length D and ENA have distinct, source-consistent meanings

For length14 D, the launch is exactly `Pmmio64_reg.w.data[14]~DUPLICATE_BLOCK_INPUT_MUX_PASSTHROUGH_X259_Y66_N0_I16_dff`; for length0 D it is the corresponding data[0] object at X259_Y69_N0_I36. Setup detail crosses length D→Q and carry logic to arithmetic passthrough storage (`1_length14_d_setup.rpt:171–213`, `1_length0_d_setup.rpt:171–212`). This is received MMIO payload/update data, not an inference from the word “length.”

For both ENA pins, all selected setup launches are `Pi2852~0xsyn_BLOCK_INPUT_MUX_PASSTHROUGH_X260_Y70_N0_I20_dff`; all selected hold launches are `PSelect_0~10xsyn_20_BLOCK_INPUT_MUX_PASSTHROUGH_X260_Y70_N0_I19_dff`. Both drive actual i2852 logic leading to the verified length ENA pins. Setup detail continues through bypassed ENA→Q and arithmetic into add_2 storage; hold detail also explicitly ends on a length ENA capture (`1_length14_ena_setup.rpt:171–223`, `1_length0_ena_setup.rpt:171–223`, `1_length14_ena_hold.rpt:171–186`). Thus “descriptor-enable evidence” is warranted, but it must not be renamed a pure payload path or a direct old-register feedback equivalent.

The six all-edge ENA fanin keepers additionally include joined_reset_n passthrough, reduce_nor_7, i611 and another i2852 representative (topology lines735–741 and1188–1194). Only two become selected worst-path launches. No SCLR launches in06 does **not** mean reset/control inputs ceased to exist or that the whole cone is control-independent.

The bound source `afu/csr_mgr.sv` decodes byte-identically to `qualification/dma-csr-timing01/csr_mgr-candidate01.sv`, SHA256 `42d09ffffb91152b9f688014bcff9ffc13e5382cddd7f478e5f9b992da232a77`. Lines103–124 form continuously registered 65-bit inclusive endpoints;125–176 combine endpoint/range, freshness and live admission checks into the write response;346–395 implement serialized AW/W/B handling;410–428 gate descriptor field updates and reset. This supports the observed functional classes. It does not supply a bit-by-bit netlist equivalence certificate for anonymous i919/Select/i2852 logic or independently prove transformed reset/latency behavior.

### Q3 — reuse the already-visible split chain, but do not call it full feedback closure

The new evidence already links more than isolated seed names:

- length0 D/ENA capture sets contain **all52 add_0 and52 add_2 passthrough objects** previously inventoried in03, plus its own length0 representative and an i1458 retimed object. The arithmetic set matches the retained104-object inventory exactly. Its incoming sweeps need not be repeated.
- length14 D/ENA capture sets contain **38 add_2 objects**, its own length14 representative and one descriptor-FIFO RAM register: **40**, not a generic “all arithmetic” set.
- The length0 arithmetic captures include the exact add_0~26/add_0~66/add_2~76 registers selected as endpoint-D hold launches. The length14 captures include that add_2~76 register. Both endpoint-D groups capture the exact Select X260_Y70_I19 register that launches length ENA hold paths.

This is concrete representative evidence of retimed arithmetic/admission/enable segments with shared physical keeper identities. It is not necessary to run another unchanged query simply to discover those links. Conversely, setup and hold select different launches, the segments cross sequential boundaries, and shared graph nodes do not prove one source-equivalent cycle. **Do not concatenate path slacks, erase the intervening registers, or claim all old feedback arcs from the graph intersection.**

### Q4 — the remaining old-feedback gap is a specific unqueried branch

The preserved old negative report, hash-bound by `csr-old-negative-paths01.json`, has the −0.367 ns path through:

`length[14]~ENA_dff.Q → length[14]~.comb.ENA/Q → add_0/add_1 → write_response/i2590 → length[0]~DUPLICATE.ENA`

(Previous `qualification/ahls-persona-work21-sta01/.../ofs_pr_afu.sta.rpt:158260–158295`.) The currently selected **nonduplicated** length14 cell instead exposes the add_2 side. Names and source indices do not prove that this is the former add_0/add_1 branch under retiming.

Two current, already-enumerated but **unqueried** representatives are especially relevant:

| Current object suffix after P | Location | Existing evidence |
|---|---|---|
| `dma_csr_map.descriptor.length[14]~DUPLICATE.comb` | FF_X259_Y66_N13 | CSR03 observations.tsv:558,1328 |
| `dma_csr_map.descriptor.length[0]~DUPLICATE.comb` | FF_X259_Y69_N26 | CSR03 observations.tsv:554,1324 |

These are candidates, not established old-name replacements. A static search of the **101** current full-STA plus CSR03/06 detailed reports found no literal D/ENA pin detail for either duplicate. Prior SCLR-through evidence does not fill that hole. This is a demonstrated reporting/association gap, **not** evidence of a negative slack or a broken circuit.

All-bit/source-equivalent limits also remain explicit: the existing family inventory has38 source-endpoint objects (25 `.comb`,13 SCLR),39 destination-endpoint objects (26 `.comb`,13 SCLR), and36 length objects (28 `.comb`,8 SCLR). Four selected cells do not map these whole families, let alone every source bit, merge, duplicate, carry/range case, and every old capture (including length17/19 and duplicated3/5). The prior synthesis merge observations remain only their documented limited explanation. Neither positive representative paths nor absent old names prove exhaustive mapping.

## 4. Smallest non-redundant next step

**Accept05/06 at the boundaries above. Do not change RTL, SDC, clock policy or fitter settings, and do not repeat the six-pin sweep.** The smallest useful coverage correction is a **bounded duplicate-branch association**, with a clear new discriminator:

1. Start with the already-enumerated `Pdma_csr_map.descriptor.length[14]~DUPLICATE.comb` at **FF_X259_Y66_N13** (P is the exact prefix defined above). Reuse06's supported cell-derived collection/intersection method to identify its real D/ENA/control pins and actual keeper fanins/fanouts. Determine whether it carries the previously unobserved **source-side add_0/add_1** contribution. Do not assume that from the duplicate suffix.
2. Include `Pdma_csr_map.descriptor.length[0]~DUPLICATE.comb` at **FF_X259_Y69_N26** only as the bounded companion needed to associate the old duplicated enable capture. Identify whether its enable drive/physical register boundary is shared with or distinct from the already-proven length0 branch. Preserve zero, shared, multiple or unavailable results instead of forcing a one-to-one mapping.
3. Reuse the104 known arithmetic keepers, the nine existing endpoint-data captures and the shared Select keeper above. Acquire timing/detail **only for newly identified, previously uncovered D/ENA/keeper segments** needed for that old source-side branch, with both setup/hold and the existing five corners if fresh timing is necessary. An overlap with already-accepted06 paths is a reuse result, not a reason to report the same sweep again. Preserve real pin identity and sequential segment boundaries.

The immediate deliverable should be a small old-function → current duplicate/pin → actual keeper-segment map, with covered versus unresolved rows, not a new general diagnostic framework. If the duplicate slice does not explain the old branch, record that specific outcome before choosing another target. The broader all-bit obligation needs an eventual explicit coverage/merge/duplicate ledger; this two-cell discriminator alone would not close it. No new native operation was performed or authorized here; the parent alone controls any separately scoped execution.

## 5. Unchanged acceptance boundaries

Warning counts were independently recomputed by ID.06 retains **159 occurrences**:332049×58,332054×41,332174×40,18502×17,20031×1,20727×1,332158×1.05 has exactly18 additional332174 lookup warnings. Resolving those diagnostic lookups is not clearance of inherited clock/constraint warnings.

The accepted full STA still says **Timing Closure Pass / Design Closure Fail / Unconstrained Paths Fail** (`artifacts-sta01/.../ofs_pr_afu.sta.rpt:2844–2866`), and the signoff report still says **22 of88 rules failed** (`ofs_pr_afu.tq.drc.signoff.rpt:123`). Retain unconstrained I/O, reset/CDC/exception findings, missing/disabled categories, metadata, freeze, DMA drain/fence, electrical/PR boundaries and hardware limits. Existing reset-extension requirements are not proven adequate by these queries. This review does not approve full timing/design signoff, functional source equivalence, PR safety, packaging/deployment, DDR/PCIe/OPAE operation or hardware qualification. **Vendor DDR simulation remains SKIPPED BY USER.**

**Bottom line:**06 answers the representative data-versus-clear question and produces real nonnegative arithmetic/data/enable-through paths. The remaining issue is source-equivalent coverage, especially the unqueried duplicate/source-side feedback branch—not failed acquisition, a demonstrated new timing defect, or a need for another unchanged broad sweep.

# CSR03/04 independent review — FINAL

Status: **FINAL**  
Verdict: **ACCEPT WITH FINDINGS for completed native acquisition and the bounded numerical observations; arithmetic/source-equivalent path coverage remains NOT ACCEPTED.**

## 1. Specification verdict and evidence identity

I reviewed the specification before the quality/interpretation findings: `CSR-PATH-REVIEW-SCOPE01.md`, `RESULTS-CSR-PATHS03.md`, `RESULTS-CSR-PATHS04.md`, then the preserved `CSR-QUERY-FAILURE01.md` and `02.md`. All work was local static inspection. Runners and embedded Python gates were parsed as AST/literals only, never imported or executed. No SSH, network, vendor/simulator/device execution, Git, implementation change, task transition, or mutable CURRENT content inspection occurred. The sole authored deliverable is this report, initially IN_PROGRESS and now FINAL. This review grants no native-launch authority.

Frozen package: `csr-path-review-package01.json`, SHA256 **`a04a8dd7034055030f3ead3715b1662dc9a8b4e35bfbce4d83b4b5924c9a7bd1`**. Independently read and hashed **all 241 listed files / 385094119 bytes**, with zero size/hash mismatches. The package does not include this review. The exact frozen input set, not mutable project status, bounds the verdict.

| Acquisition check | CSR03 | CSR04 |
|---|---:|---:|
| Native / effective / outer return codes | 0 / 0 / 0 | 0 / 0 / 0 |
| Quartus identity | 25.1.0 Build 129 | 25.1.0 Build 129 |
| Exported payloads decoded, size/hash checked, and byte-compared to local artifacts | 46 | 26 |
| Gzip archive bytes | 2237276 | 1298399 |
| Native errors / warning occurrences | 0 / 159 | 0 / 220 |
| Critical input bindings / protected physical QDB paths | 5750 / 344 | 5750 / 344 |
| Complete marker, four preservation flags, empty postflight errors | verified | verified |
| Timeout / owned live survivors | false / none | false / none |

Archive SHA256s:

- CSR03: `c3e02495feea8ed3445d99ed6ff2bf088659ea25673ee720c6966fe03cdf5fab`.
- CSR04: `619b503c5a023c0eda58607d5e42f82f4c3eb00d12bcdd30b7f984ac4e95f156`.

These were recalculated from `result-csr-paths03/04.json.gz` and checked against their outer receipts, not just copied from verification summaries. Both literal configurations bind the same completed fit archive, SHA256 `f33d14f057fb0b5d9351eb0b5a6d9a375cf003a25e25e8c39d1a4f09e9e6d5ee`, and independently fresh query roots copied from `fit01`, not failed-query databases. Embedded query Tcl equals the standalone and exported Tcl bytes. The copied QSF delta is exactly the fitter-to-STA gate replacement and NUM_PARALLEL_PROCESSORS 2→36; no RTL/SDC/timing-policy modification is hidden in that delta. The 344 protected entries are disjoint from the 26 enumerated runtime-output roles; their configured, critical-input, and captured post-run QDB hashes agree. Original fit/release/tool/source preservation is accepted from the hash-bound native receipts and their explicit checking logic, not claimed as a new live workstation measurement.

The native logs explicitly load the **final** snapshots for root_partition, green_region and both auto_fab partitions, then report successful final database loading (`timing.log` lines 34–60 in both attempts). Gate-event PID/start ticks/executable/argv/cwd agree with the result command records. Both runners use the finite 1800-second deadline and captured 64 GiB per-process limit with CPU affinity 0–35; those observations do not prove aggregate containment or effective worker count.

The two preliminary failures remain failures: native/effective/outer 3/3/3, no acquired path evidence. CSR01 fails on `::userClocks::u_clk_fmax`; CSR02 on `get_afu_json_user_clock_freqs` (respective logs line 398). CSR03/04 move the whole project-open/netlist/SDC/update boundary to global Tcl scope and check the global PIM helpers. This resolves the observed diagnostic-loader problem without changing vendor constraints; it does not reclassify the earlier runs as successful or invalidate the separately accepted full STA.

## 2. Recomputed path scope — what is and is not accepted

I parsed the exported `observations.tsv` files directly, reconciled every PATHCOUNT with its PATH rows, checked all slack signs, and checked DONE=5. Both queries have the same 1139 all-CSR objects and the same 81 clock name/type/period/waveform rows. All 81 clock-property tuples also match the completed native STA Clocks panel (lines 2755–2840), with waveform whitespace treated as list serialization rather than a clock change.

### CSR03

There are 60 family/metric/corner queries, **9840 nonnegative path-record occurrences**, 40 nonempty groups and **20 NO_TIMED_PATH gaps**. The gaps are exactly arithmetic_to_src and arithmetic_to_dst, setup and hold, at each of five corners. Families overlap; 9840 is not a count of distinct physical paths.

| Queried family label | Setup occurrences / minimum ns | Hold occurrences / minimum ns | Important scope |
|---|---:|---:|---|
| src_to_admission | 50 / +1.201 | 50 / +0.364 | 10 returned captures per corner; all launches are SCLR representatives |
| dst_to_admission | 55 / +1.057 | 55 / +0.367 | 11 returned captures per corner; all launches are SCLR representatives |
| length_feedback | 90 / +2.668 | 90 / +0.076 | 18 returned captures per corner; all launches are SCLR representatives |
| csr_full | 4725 / +0.528 | 4725 / +0.048 | 945 returned captures per corner; mixed transformed CSR objects |

The query requests at most one worst path per returned endpoint and fewer than 1024 paths per group; maximum observed count is 945. The separate full-routing reports retain only four worst paths per nonempty group. Cap headroom does not convert endpoint-filtered, constrained setup/hold reporting into a structural census or a proof for every source-to-capture pair.

### CSR04

The unrestricted-launch incoming-family query returns **260 nonnegative occurrences**: 13 captures per family, metric and corner. Every launch is `afu_top|pg_afu.port_gasket|pr_slot|afu_main|port_afu_instances|ofs_plat_afu|join_afu_reset|joined_reset_n`; every capture is a source/destination SCLR representative. Minima are source +1.345 setup / +0.688 hold ns, destination +1.476 / +0.686 ns. **These are synchronous reset-control transfers, not arithmetic input paths.** Their existence explains why removing the CSR launch restriction changes the zero result, but does not solve the data mapping.

The old launch `dma_csr_map.descriptor.length[14]~ENA_dff` returns zero. All 60 capture lookups return zero, producing **60 OLD_NAME_UNRESOLVED rows** for six requested captures × two metrics × five corners. Those captures are length[0], length[0]~DUPLICATE, length[17], length[19], length[3]~DUPLICATE and length[5]~DUPLICATE, with the full preserved CSR hierarchy in the Tcl/TSV. All seven literal old names are also absent from the enumerated current all-CSR names.

The warning delta is exactly 61 additional Warning 332174 occurrences: one launch lookup and 60 capture lookups. Other warning-ID counts match CSR03. This is not warning clearance. Both queries retain ordinary returned-path setup relationship 3.000 ns, hold relationship 0.000 ns, and multicycle fields 1/1 setup, 0/0 hold. No inference about cut, unconstrained, recovery/removal, or unreturned paths follows.

## 3. Quality findings: the mapping gap is sharper than a renamed endpoint

For compact names below, **P** means the exact prefix:

`afu_top|pg_afu.port_gasket|pr_slot|afu_main|port_afu_instances|ofs_plat_afu|core|dma|csr_mgr_inst|`

### Q1 — native type `reg` does not establish an active arithmetic storage endpoint

The families returned by get_registers are:

| Family | Total objects | `.comb`-ending objects, including duplicates | SCLR objects |
|---|---:|---:|---:|
| src_last_q | 38 | 25 | 13 |
| dst_last_q | 39 | 26 | 13 |
| descriptor.length | 36 | 28 | 8 |

**All have get_node_info type `reg`.** Do not reinterpret `.comb` names as native type `comb`, and do not reinterpret their `reg` type as proof that their physical register is active. Detailed routing explicitly calls the sampled `.comb` objects **Bypassed ALM Register**, while the SCLR objects are **Hyper-Register**. Physical role/pin evidence is the missing discriminator, not more source-name enumeration.

Concrete current evidence:

- `Psrc_last_q[38]~.comb` is recorded at **FF_X261_Y68_N46** (`artifacts-csr-paths03/csr-path-reports/observations.tsv:177`). In `2_src_to_admission_setup.rpt:169–171`, `Psrc_last_q[37]~SCLR_dff|q` at **FF_X261_Y68_N75** drives that bypassed object's **`|sclr`**, then its **`|q`** feeds the admission cone. This is a control-to-output arc, not an observed arithmetic D-input arc.
- `2_dst_to_admission_setup.rpt:169–172` similarly shows `Pdst_last_q[38]~SCLR_dff|q` at **FF_X255_Y68_N75** driving **`Pdst_last_q[37]~.comb|sclr`** at **FF_X255_Y68_N43**, then `|q`. The SCLR bit label and the driven source-state bit label need not agree; same-index pairing would be wrong even in this preserved example.
- `1_length_feedback_setup.rpt:167–169` shows `Pdma_csr_map.descriptor.length[14]~DUPLICATESCLR_dff|q` at **FF_X259_Y66_N65** driving **`Pdma_csr_map.descriptor.length[14]~DUPLICATE.comb|sclr`** at **FF_X259_Y66_N13**. The +2.668 ns result is not an observation of the historical arithmetic/admission feedback arc.
- `artifacts-csr-paths04/csr-path-reports/1_any_to_src_setup.rpt:165–199` traces joined_reset_n through reset distribution to the **D pin of the SCLR Hyper-Register** at FF_X261_Y68_N79. A physical `|d` pin alone therefore does not establish arithmetic data: the transported signal here is reset control.

Across all CSR03 source/destination-to-admission and length-feedback TSV rows, **all 390 launches are SCLR-named representatives**. Across their 30 detailed report files, all 120 detailed path bodies contain the bypassed-register `|sclr` arc. Thus the family labels are query labels, **not accepted source-function classifications**. In particular, endpoint-data→admission and old-feedback coverage remain open as well as incoming arithmetic coverage. This qualifies the interpretation of RESULTS03; it does not reject its measured slacks or silently modify the frozen document.

### Q2 — source and old native path identify the required equivalence, not identical suffixes

The bound `afu/csr_mgr.sv` hash is `42d09ffffb91152b9f688014bcff9ffc13e5382cddd7f478e5f9b992da232a77`, equal to frozen `qualification/dma-csr-timing01/csr_mgr-candidate01.sv`. Its lines 103–124 continuously register unsigned 65-bit inclusive endpoints from start address plus scaled length minus one. Lines 125–176 consume these endpoints in descriptor/write admission; lines 410–428 gate descriptor writes on the response and apply reset. The new timing obligations are the actual arithmetic/storage boundary and the actual endpoint-data/admission/descriptor-update boundary after implementation transformations, not necessarily the old source register names.

Synthesis gives a specific, limited merge explanation: `ofs_pr_afu.syn.rpt:39836–39837` merges src_last_q[58..62,64] into src_last_q[63], and dst_last_q[58..63] into dst_last_q[64]. This is not a mapping of every bit or proof that missing incoming paths were optimized away. The completed Hyper-Retimer report records successful operations and additional reset-cycle requirements (`ofs_pr_afu.fit.retime.rpt:105,139,159,348–350`), but contains no source-to-final bit/pin correspondence table that settles this question.

The original worst feedback path is itself **enable-mediated**, not simply length[14].Q→length[0].D. In the frozen previous STA report identified by `csr-old-negative-paths01.json`, lines 158260–158294 trace:

`length[14]~ENA_dff|q → length[14]~.comb|ena → |q → add_0/add_1 carry logic → write_response[1]~0 → i2590~0 → length[0]~DUPLICATE|ena`.

Consequently, a successor association must account for descriptor update/enable semantics and any retimed storage split. Replacing an old ENA name with a similarly numbered current SCLR name would substitute a different function. Neither suffix substitution nor literal-name absence establishes resolution of the old −0.367 ns path.

### Q3 — useful current arithmetic candidates already exist in CSR03; reuse them

The all-CSR inventory already contains **52 `add_0~…_BLOCK_INPUT_MUX_PASSTHROUGH_…_dff` and 52 `add_2~…_BLOCK_INPUT_MUX_PASSTHROUGH_…_dff` objects**. For example:

- `Padd_0~101_BLOCK_INPUT_MUX_PASSTHROUGH_X261_Y68_N0_I46_dff`, location BLOCK_INPUT_MUX_PASSTHROUGH_X261_Y68_N0_I46 (`observations.tsv:658`).
- `Padd_2~116_BLOCK_INPUT_MUX_PASSTHROUGH_X255_Y68_N0_I46_dff`, location BLOCK_INPUT_MUX_PASSTHROUGH_X255_Y68_N0_I46 (`observations.tsv:659`).

Each family already has 260 incoming setup and 260 incoming hold records in csr_full, covering all 52 captures at five corners. Minima are add_0 +0.936/+0.224 ns and add_2 +0.692/+0.215 ns. These **1040 occurrences are a subset of the 9840**, not new evidence or an additional count. None of these candidate registers is selected as launch in the csr_full worst-per-endpoint records; that is selection scope, not proof of no fanout.

These are concrete retimed arithmetic-name candidates for the connectivity check. Their names and nearby physical locations do **not** prove which source endpoint bits they implement. Do not repeat their already-acquired incoming worst-path sweep merely to rediscover these numbers.

### Q4 — API semantics limit negative conclusions

Captured native help, `csr-help01.log`:

- get_registers returns registers and, by default, duplicated registers derived from matching names (lines 446–512). This is **duplicate-aware matching**, not a documented universal old-source-to-retimed-object translator. `[list {literal-name}]` protects Tcl substitution but does not independently qualify every Timing Analyzer filter/escaping interpretation. The negative result is the observed lookup under the retained invocation, not a physical absence theorem.
- get_node_info documents node IDs, mutually exclusive type/location/host-cell and synchronous/asynchronous/fanout-edge queries (631–696). A node handle, collection, host-cell handle, physical location string and pin name are not interchangeable.
- get_timing_paths is worst-case, constrained path reporting; `-nworst 1` is an endpoint selection limit (1018–1158). report_timing documents through **pins/nets** (1422–1425), while get_timing_paths explicitly rejects a through collection of an incompatible type (1152). Feeding the register collection straight into `-through` would not be a justified correction.
- Full-path detail includes clocks; it does not remove path filters or supply a netlist-equivalence proof. `-false_path` is a separate constrained-path query, not an unconstrained census (1457–1463).

**Finding classification:** a demonstrated reporting/identity/function-classification gap, with concrete retiming/control-path evidence. These family results do **not** themselves establish missing arithmetic, a broken implementation, a new negative slack, or arithmetic closure. Functional equivalence and the inherited reset obligations remain separate unresolved requirements.

## 4. Smallest non-redundant next discriminator

**Recommend one finite final-netlist pin/connectivity association check, not another five-corner name-filter sweep.** The immediately missing API/source prerequisite is the installed Quartus **25.1 help for `get_cell_info` and `get_edge_info`**: the current package documents obtaining a host cell/edge IDs but does not document how to decode those handles into actual pins, edge endpoints and active storage relationships. This is a targeted two-command help/source check, not an assumption those commands or any guessed switches apply. Record unavailability if either is absent; do not import a newer-release recipe, use undocumented atom keys, or claim a help body proves successful final-netlist applicability.

If that help supplies the necessary supported access, the smallest useful association batch has four fixed current seeds, using retained collection members/verified handles rather than old strings as guessed aliases:

1. `Psrc_last_q[38]~.comb`, FF_X261_Y68_N46.
2. `Pdst_last_q[37]~.comb`, FF_X255_Y68_N43.
3. `Pdma_csr_map.descriptor.length[14]~.comb`, FF_X259_Y66_N14.
4. `Pdma_csr_map.descriptor.length[0]~.comb`, FF_X259_Y69_N25.

Use the already documented get_node_info host-cell and edge access as the starting point, and only the newly verified cell/edge API syntax to expose each seed's **actual data, clear and enable pin roles and nearest active register boundaries**. Enumerate the real pin spellings; do not invent `.comb|d`, assume `.comb|q` excludes clear traffic, or pair objects by index/location similarity. Start with the source seed as a discriminator; source/destination and length/feedback seeds are the bounded extension within the same association task, not a full-netlist crawl.

The decisive result is a small explicit map: source-state representative → bypassed cell/pin → data-carrying predecessor/successor keeper(s), separately listing clear/enable representatives. Compare identified data keepers with the **existing** add_0/add_2 list. For the length seeds, locate the current descriptor-write/enable equivalent of the old feedback relation, allowing that retiming has split the former single path into multiple sequential segments. Zero, multiple, shared or unavailable associations must remain explicit outcomes, not silently forced into a one-to-one map.

Only after that pin/keeper identity is established should the parent formulate changed timing queries through the verified **data pin/net collections** or to the actual identified data registers, and for the mapped descriptor-update relation. Existing help supports get_timing_paths/report_timing `-through`, full-path detail, and get_path_info endpoints; it does not justify using a register collection as a through collection. Initially unrestricted launch identity avoids reproducing CSR03's hierarchy assumption. Preserve reset/control paths separately rather than crediting them as data. A representative map is a discriminator, not eventual all-bit/all-corner acceptance.

If the required supported connectivity access is unavailable, retain that precise API blocker and obtain the equivalent **mapped-connectivity slice for these fixed seeds** through a verified available native report/source mechanism. Do not compensate with another unchanged fit, another old-name query, altered SDC, a guessed waiver or a broad diagnostic framework. No such native operation was performed or authorized by this review; the parent alone operates the workstation.

## 5. Acceptance boundaries retained

The earlier parent `FIT-ACCEPTANCE.md` and `STA-ACCEPTANCE.md` remain stage-bounded acceptances, not expanded approvals. The completed full STA still reports **645 nonnegative domain records**, including **eight exactly 0.000 ns**, and native **Timing Closure Pass / Design Closure Fail**. The domain count/signs were checked; the failure is visible in the native Design Closure Summary (2844–2866).

Retain unconstrained-path findings, 22 of 88 enabled signoff rules failing, disabled/missing categories, inherited warnings/ignored assignments, electrical/PR-boundary findings, and reset sequence obligations (at least two additional sys-clock cycles and four additional EMIF0-core cycles, not total pulse widths or proof of adequacy). This review accepts neither full timing/design nor mapped functionality, reset/CDC/exception correctness, PR safety, DMA drain/fences, DDR/PCIe/OPAE operation, assembly/deployment or hardware qualification. Vendor DDR simulation remains SKIPPED BY USER. No closure is inferred from a missing source name or a reset-only path.

**Bottom line:** acquisition is sound within the frozen scope. The physical evidence already explains why the family queries miss their intended semantic targets: bypassed ALM representatives and retimed SCLR control storage are being mistaken for arithmetic state boundaries. Map the actual data/control pins and active keepers once, then qualify the identified source-equivalent paths. No implementation defect or arithmetic timing pass is established by CSR03/04 alone.

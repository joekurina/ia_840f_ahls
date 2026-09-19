# Independent specification review: donor bank-spreading translation

## Verdict

**PASS for the bounded structural candidate, with the implementation contract below mandatory.** Translate the two captured donor requests `BANK_SPREADING_EN=false, NUM_BANK_FIFOS=8` to modern `mem_ss|msa_0|NUM_BANK_FIFOS=0` and `mem_ss|msa_1|NUM_BANK_FIFOS=0`. This is a supported translation of saved intent, not proof of original donor generated behavior, timing closure, functional equivalence or execution authorization. A preset-only patch is NOT sufficient: derivation, provenance and regenerated memory preset must change together.

No implementation has been reviewed or executed. All readiness/functional/timing/constraint acceptance remains false.

## Independent evidence checks

I recomputed complete-file SHA256 and byte sizes for every entry in `source-manifest.json`: **20 entries, 20 unique capture paths, 20 passing hashes and sizes**. Manifest SHA256: `6f5d2262c6b92b1fc24364597e7d691de71919bee11e291a539dbb447cc4266f`. Full XML/JSON captures were parsed, rather than treating report excerpts as source; relevant Tcl and both complete generated wrappers were inspected. This verifies the supplied capture bytes, not a fresh remote-state inventory. The manifest is unchanged.

- `captured/01-*` and `02-*`: each donor module has 33 saved parameters, including false/8/1 for enable/count/write copies. Ready/valid=3/0, quotas=512/512, policy=1, auto-precharge=true and USE_SINGLE_CLOCK=1 are saved intent.
- `04-derive_presets.py:91–109`: accepted exact-name fields and aliases copy NUM_BANK_FIFOS directly; there is no bank-enable semantic translation. `05-preset_derivation.json` confirms direct count provenance and unresolved false enable for both MSAs. No inference about old RTL behavior follows from this gap.
- `06-ia840f_mem.qprs`: full parse yields 2930 parameters, with count=8 and copies=1 for both MSAs. `09-ia840f_memory.ofss` selects this preset. `11-mem_ss.ip` contains two nested NUM_BANK_FIFOS=8 parameters; `12-*` and `13-*` instantiate 8, copies=1, TXN_WINDOW, latency=3/0, quotas=512/512, ASYNC_EN=0 and SS_CONTROLLED.
- `18-declare.tcl:80–90` defines count as non-derived, HDL-affecting and legal in {0,2,4,8}. `20-parameters.properties:22–25` explicitly defines zero as no bank spreading and describes cross-bank traffic reordering/throughput. Hidden derived READY_LATENCY/VALID_LATENCY and SCHEDULER_POLICY are not new pipeline controls.
- `15-edit_qsys_fm.tcl:133–295` exposes count for regular DDR4, leaving it user-configured. The actual STORAGE/STORAGE, one-to-one topology is not the ASSOC_STORAGE branch at 361–411 that forces four copies, zero FIFOs and quotas16. `mapping.json` contains both actual DISABLED=false commands. `14-declare.tcl` and `16-elaborate.tcl` are consistent with this topology; no contradictory count override was found in these captured sources.
- `19-elaborate.tcl:17–18` rejects copies>1 together with count>0. Its address-width derivation depends on copies, not count. This supports retaining copies=1 and existing interfaces, but does not replace generated readback.
- Full preset geometry is row17/column10/bank2/group2, DQ64, ECC=false, chip-ID0; calculated capacity is 16 GiB per single-rank interface. Existing wrappers expose 34-bit addresses, 512-bit data, 64-bit strobes/byte enables, 9-bit IDs and 14-bit address USER. These are preservation baselines, not new interface design choices.

I also rehashed the full Work11 STA report to `9b851e84ea597e8c7b8b846d630609ce69ed6436ce555cc853858f6ec91f838c` (46834561 bytes), and Work10 to `8e6002a2c4c7974f0382a9b458c8be9ca87034a120d4972da3c14081367aded4`. Direct summary rows verify DDR0 setup -0.508 ns/TNS -185.081/711 endpoints, DDR1 setup -0.170 ns/TNS -29.340/403 endpoints, and DDR1 PHY hold -0.004 ns/one endpoint. An independent broad summary-row matcher found 52 equal rows in each full report (includes more categories than the completion report's 34 setup/hold rows; not a contradictory count). Final Work11 flow line396 records hold effort On versus default Off. Thus the hold setting was recognized and did not improve these results. Existing paths name bank-spreading/scheduler logic; this candidate has a structural rationale, not a guaranteed cone/slack result. Do not repeat a blind seed or hold-only retry.

## Required deterministic translation semantics

Keep this board-scoped and schema-checked. Do not introduce a global vendor-IP default change. Parse exact XML strings; never use Python string truthiness. The minimal accepted enable vocabulary is exactly `false` and `true`; alternate encodings require an explicitly documented, tested extension, not silent normalization. Preserve raw values in provenance.

| Donor input | Required result |
|---|---|
| Explicit false; legal saved count 0/2/4/8 | Emit 0. Record enable as decisive and count as retained but inactive donor evidence, not direct-copy provenance. |
| Explicit true; legal count 2/4/8; copies=1 | Preserve that exact count. Do not force 8 or 0. |
| Explicit true; count0 | Reject contradictory enabled-with-zero request; no silent disabling. |
| Missing enable; legal count0/2/4/8 | Preserve existing direct count, explicitly mark enable absent/semantics unresolved. Zero here comes from the explicit count, NOT an inferred false flag. Do not claim restored donor intent. |
| Missing count, with any enable state | Fail closed for this bounded implementation; do not inherit a reference default. A future permissive false-with-missing-count policy needs its own explicit specification. |
| Malformed enable or malformed/unsupported count | Reject before publishing any output, even with explicit false. Do not hide corrupt source data behind the disabling rule. |
| Any positive effective count with copies>1 | Reject the installed-schema conflict. Never fix it by changing copies. |
| Target field absent from accepted schema | Reject a requested translation rather than dropping it or widening the schema silently. |

For the actual two-channel fixture require copies=1 and explicit false/8 independently per instance. Do not share mutable instance state or assume both instances have identical donor values in generic tests.

## Required source changes and provenance

Minimal next implementation scope: `ipss/ia840f/derive_presets.py`, `ipss/ia840f/preset_derivation.json`, `ipss/ia840f/presets/ia840f_mem.qprs`, and focused pure-Python regression tests/documentation. Use the authoritative remote Work11 SOURCE as the later baseline, not a stale local QSF. The captured SOURCE QSF hash is `ad68b5bf4666731449b2ae326a0f307065d112fb6bb0a9a0a072a0cd6cb1516c`; verify current identity before subsequent deployment/rebinding. No generated RTL editing.

For each MSA, provenance must identify both source keys, their exact raw values, output scope/value, rule, supporting installed-source hashes/locations, and qualification limited to saved-intent translation. Remove NUM_BANK_FIFOS from simple direct-copy mappings when overridden; remove the resolved false enable from unresolved entries only while retaining it in the explicit semantic record. Retain all other unresolved fields, particularly old auto-precharge/policy/synchrony semantics. Do not invent an integer-policy-to-string equivalence. Update output hashes/counts truthfully; execution_ready remains false. A subsequent deterministic regeneration must produce the same bytes and must not restore 8.

The complete memory-preset semantic diff must be exactly the two count values. No parameter additions/removals/duplicates, count drift or unrelated value changes. Simulation and PCIe presets must remain byte-identical (captured hashes `8af9954c412405597fd073d1b2507dfac2e3475ef21871e1973f4ddbd666465e` and `420f73c5c4bf1432ce39508f068bc381f4e4f2117a87a96940ca8500a93c876e`). Do not run the existing broad --write against authoritative files merely to discover a mismatch: derive all outputs in memory, inspect full differences, then publish the reviewed artifact set.

## Required regressions before generation

1. Actual captured false/8/copies1 for both instances -> two zeros; full parameter-map equality outside the two targets; all four artifact/provenance expectations above.
2. False with each legal count, and true with each positive legal count; mixed-instance false/true and different enabled counts demonstrate independent mapping.
3. Missing flag with each legal count preserves count and unresolved status; missing flag must never be treated as false.
4. True+zero, missing count under false/true/absent flag, empty/unknown/mixed-case/whitespace enable tokens, and count empty/noninteger/negative/1/3/16/8.0 must reject under the strict policy. Include duplicate XML keys. If alternate lexical encodings are intentionally supported, replace the relevant reject expectations with an explicit closed-vocabulary test.
5. Positive effective count plus copies2/4/8 rejects; false plus copies1 remains1. Actual-fixture invariant rejects any capacity-reducing copy change even though zero/copies>1 can be legal in the generic vendor schema.
6. Missing modern target/schema support rejects; source/hash mismatch rejects wherever inputs are pinned. Test no output publication on validation failure, deterministic repeated derivation, no vendor subprocess invocation, and compare-only mode detects stale preset/provenance.
7. Assert resolved translation provenance is neither mislabeled direct-copy nor left as unresolved false enable; unrelated unresolved entries, topology, PCIe/simulation output bytes and false readiness flags are unchanged.

## Later generation acceptance, not performed here

Under standing user full-scope approval, ordinary reviewed correction/generation/build work does not require incremental user questions. Technical preflight, independent implementation review and source-bound records still apply. Preserve the Query04-specific prohibition: no retry, renamed/rerouted equivalent or gate bypass. REPORT.md's 'once separately permitted' must not be inflated into a new blanket vendor-tool ban; this evidence does not establish one. This review itself grants no execution authority and issues no record.

Require supported save/reload and fresh generation in a new bound worktree. Read back BOTH scoped values=0 from saved subsystem/nested leaf parameters and generated wrappers. Compare complete before/after parameter maps (including derived/hidden values), external/locked interface definitions, port widths/directions, clock/reset associations, connections and exported boundaries. Only two design parameter changes are expected; generation-dependent identifiers, paths and timestamps may change but must be itemized, not hidden by broad normalization. Reject ignored/unmatched parameters, unexplained derived changes or interface drift before full compile. Internal generated topology/resource changes are expected possibilities; external protocol correctness and cycle-level performance equivalence are not established by unchanged port lists.

Preserve two 16-GiB x64 no-ECC memories; BOT/BOT; application channel0->memory0 and1->1; copies1; quotas512/512; TXN_WINDOW; SS_CONTROLLED; ready/valid3/0; ASYNC_EN0; all memory clocks and reset wiring; core470 and seven-output PLL contract; P-Tile Gen4x16 PF/VF/BAR contract; all pins, SDC and constraints. Do not confuse PHY1333.333 MHz with controller333.33 MHz. These captures are not a complete PLL/pin/PCIe certification, so subsequent whole-tree inventories remain required.

Important distinction: donor QSYS calibration conduit indices are bottom calbus0->intf1 and calbus1->intf0. Both are BOT, but this is not evidence that donor calibration indices equal application channel indices. Do not 'repair' or swap calibration wiring as part of the count change; retain the reviewed current baseline and its separate calibration-association acceptance issue.

Disabling bank spreading may reduce bandwidth/efficiency and change transaction service order or load-dependent latency. It does not justify a no-reordering guarantee, a latency guarantee, or a claim to reproduce the original donor implementation. Later timing comparison must cover both controllers/all corners, WNS/TNS/endpoints, path depth and cell/interconnect delay, resources, hold and constraints. DDR1 PHY hold and unconstrained PCIe-divider/BMC IRQ/JTAG and S1/TRS applicability issues remain open even if setup improves. DDR simulation remains skipped by user; functional/hardware acceptance is not implied by generation or compilation.

## Review actions and limits

Only this fresh `spec-review.md` was written. No SOURCE/WORK/gate/manifest edits, remote/vendor calls, builds, DDR simulation, protected-RTL modifications, hardware actions, installations, permission changes or commits occurred. Initial bare `python` lookup failed; local verification succeeded with `python3`. No evidence access blocker remained. Historical transport-operation claims were not independently re-enacted; the independently checked claim here is the captured-file/hash and source-semantic chain.

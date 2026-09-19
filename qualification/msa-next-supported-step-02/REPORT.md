# Next supported MSA step: disable unintended bank spreading

## Decision

**A substantive supported candidate was found: change `mem_ss|msa_0|NUM_BANK_FIFOS` and `mem_ss|msa_1|NUM_BANK_FIFOS` from 8 to 0 in a separately reviewed successor configuration.** This is one semantic change applied to both memory adapters, not a seed, clock, latency, bank-address assignment, or fitter-toggle experiment. No change or vendor invocation was performed here.

The original vendor MSA files explicitly saved `BANK_SPREADING_EN=false` alongside `NUM_BANK_FIFOS=8`. The current migration copied the numerical FIFO count but left the legacy enable flag unresolved. Modern installed metadata defines `NUM_BANK_FIFOS=0` as **No bank spreading**; Work11 actually generated both adapters with 8. Thus the next step has a concrete configuration-migration rationale and directly targets the bank-spreading cones that fail setup. It is not a proven timing fix or proof that the old generated implementation honored its saved flag.

## Evidence chain (local captures preserve remote file line numbers)

1. **Original vendor request:** `captured/01-mem_ss_fm_0_msa_0.ip` and `02-mem_ss_fm_0_msa_1.ip`, lines 1972–1985, save `BANK_SPREADING_EN=false`, `NUM_BANK_FIFOS=8`, and `NUM_WRITE_COPIES=1`. Lines 1987–2015 save read/write quotas 512/512, scheduler policy integer 1, ready/valid latency 3/0, and auto-precharge true. These are original vendor files under `/home/uwb_student00/IA-840f/IOFS_BUILD_ROOT/ofs-ia840f/ipss/mem/qip/mem_ss/`, read-only.
2. **Translation gap:** `captured/04-derive_presets.py`, lines 91–109, copies matching accepted MSA fields, with explicit geometry/data-width/copy aliases but no legacy bank-enable translation. `captured/05-preset_derivation.json`, lines 2896/2920, records direct NUM_BANK_FIFOS copying; lines 6493/6517 retain `BANK_SPREADING_EN=false` in unresolved fields. This is an unresolved semantic migration, not a guessed mismatch.
3. **Current SOURCE request:** `captured/06-ia840f_mem.qprs`, lines 2909/2927, explicitly requests 8 for both scoped parameters; lines 2910/2928 preserve one copy. The OFSS selector in `captured/09-ia840f_memory.ofss` selects the vendor-derived preset.
4. **Actual Work11 saved and generated configuration:** `captured/11-mem_ss.ip`, lines 6358–6361 and 6502–6505, records 8 in msa_1 and msa_0 respectively. `captured/12-mem_ss_mem_ss_501_qm5zaka_msa_0.v` and `13-mem_ss_mem_ss_501_qm5zaka_msa_1.v`, lines 68–85, both instantiate NUM_BANK_FIFOS=8, NUM_COPIES=1, TXN_WINDOW, ready/valid=3/0, read/write quotas=512/512, and ASYNC_EN=0. These wrappers were only read.
5. **Supported modern control:** `captured/18-declare.tcl`, line 87, declares NUM_BANK_FIFOS as non-derived, HDL-affecting, with legal values 0/2/4/8. `captured/20-parameters.properties`, lines 22–25, says the bank FIFOs reorder traffic across banks and explicitly labels zero “No bank spreading.” This is not an arbitrary number or hidden derived latency override.
6. **Available in the actual regular-EMIF topology:** `captured/15-edit_qsys_fm.tcl`, lines 191–203, enables editing NUM_BANK_FIFOS alongside other MSA performance controls. Existing Work11 generation XML excerpts in `mapping.json` show `set_instance_package_parameter_property msa_0 NUM_BANK_FIFOS DISABLED false` and its msa_1 counterpart, plus actual value 8. The distinct fixed four-copy/zero-FIFO branch at lines 375–390 is not the requested change and must not be copied wholesale.
7. **Capacity guard:** `captured/20-parameters.properties`, lines 17–18, explicitly warns that copies reduce available storage capacity. NUM_COPIES must stay 1. `captured/19-elaborate.tcl`, lines 17–18, separately rejects simultaneous write copies and bank spreading. Neither copying nor changing geometry is needed for the proposed zero-FIFO setting.

## Comparison and implications

| Property | Original vendor saved request | Work11 generated adapter | Candidate |
|---|---|---|---|
| Bank-spreading control | enable=false, count=8 | count=8; no legacy enable parameter | count=0 (“No bank spreading”) |
| Memory copies | NUM_WRITE_COPIES=1 | NUM_COPIES=1 | unchanged |
| Read/write scheduler quota | 512/512 | 512/512 | unchanged |
| Scheduler policy | integer 1 | TXN_WINDOW | unchanged; no unverified enum translation |
| Ready/valid latency | 3/0 | 3/0 | unchanged |
| Auto-precharge | true | SS_CONTROLLED | unchanged; separate migration semantics not altered |
| Synchrony | USE_SINGLE_CLOCK=1 | ASYNC_EN=0 | unchanged |

The Work11 completion report establishes unchanged DDR0/DDR1 setup WNS -0.508/-0.170 ns and hold -0.004 ns after the recognized hold-ON experiment. Prior exact path evidence in `../msa-timing-next-01/emif0-path.txt` and `emif1-path.txt` identifies 10/11-level bank-spreading/scheduler cones. Removing the optional bank-spreading mode is therefore a plausible structural simplification of the implicated logic, unlike re-enabling an already active fitter optimization. Protected RTL internals were not inspected or changed in this investigation, so exact cone elimination and replacement critical paths require later generated/fitted evidence.

**Risk:** bank spreading is a throughput/reordering feature. Disabling it can reduce memory efficiency or change transaction service order/latency under load. The catalog documents this as a supported user performance setting, but that does not prove whole-FIM functional acceptance. No promise of recovered slack, equal bandwidth, identical cycle timing, or repaired PHY hold is made.

## Exact bounded next action, not executed

Prepare a fresh reviewed successor that translates the donor's disabled bank-spreading request to the modern scoped value 0 for both MSA instances. Correct the derivation logic/provenance as part of that later source change so regeneration cannot silently restore 8. Do not hand-edit generated RTL or the completed Work11 tree. The only intended generated-design delta is the two scoped NUM_BANK_FIFOS values; leave quotas, auto-precharge, copy count, policy, and latency untouched.

Before any vendor use, resolve the existing tool-prohibition/gate requirements; this report is neither authorization nor an issued build record. No Query04 retry is needed to identify this candidate. Once separately permitted, supported parameter save/reload and fresh generation must read back zero for both adapters and compare the full before/after parameter maps and interfaces. Only then consider a full timing experiment. Reject unexplained geometry/topology/clock/interface changes or unmatched/ignored parameters. Rebinding must use the live SOURCE, not the stale local tree.

Preserve two 16-GiB x64 no-ECC interfaces, BOT/BOT placement, channel 0→0 and 1→1, all core-470/seven-output PLL settings, memory/EMIF clocks, pins, P-Tile Gen4x16 and PF/BAR contracts. The captured preset retains MEM_CH_0_CONNS=1,0, MEM_CH_1_CONNS=0,1 and BOT,BOT (lines 20/31/40); changing MSA FIFO count does not request a connection or geometry alteration. This review is not a new whole-tree contract certification. Do not confuse saved PHY DDR4 memory frequency 1333.333 MHz with the 333.33-MHz controller domain.

A later timing comparison must cover both controllers, all corners, WNS/TNS/failing endpoints, actual path topology/depth and IC/cell delays, hold, resources and constraint completeness. The unrelated DDR1 PHY hold and unconstrained-clock/I/O blockers remain open even if this setup cone improves.

## Baseline, verification and scope

- Live remote SOURCE QSF SHA256 is `ad68b5bf4666731449b2ae326a0f307065d112fb6bb0a9a0a072a0cd6cb1516c`, matching the Work11 completion baseline. No native-migrated WORK QSF was copied back.
- `source-manifest.json` maps 20 full captured files to exact remote paths, sizes and SHA256 values. Every captured text was locally rehashed against its remotely computed whole-file SHA256. Each batch also has a verified payload SHA256 in its `*-transfer.json`; remote readers are retained.
- Existing four requested qualification reports and the prior MSA catalog evidence were read before remote work. No generic enum, seed or fanout investigation was repeated.
- All remote operational reads asserted Agilex7Workstation/UID1000 and ran in fresh owned `msa02-*` windows, panes %406–%411, within `ia840f_mailbox_monitored_01`. SSH only interacted with tmux. Unique buffers prevented stale-result reuse. No remote source/evidence files were written; only tmux transport buffers/windows were created.
- Local additions are confined to this fresh exclusive qualification directory. No maintained SOURCE, WORK, vendor source, gate, authorization, protected HDL, SDC, pin or project configuration was changed. No compile, simulation, hardware operation, install, permission change or commit occurred.
- Discovery path lists were capped and are not claimed as complete vendor-tree inventories. The decisive selected files were captured in full. No access failure blocked the analysis.

## Acceptance matrix

| Item | Result |
|---|---|
| Read-only source/configuration comparison | COMPLETE; hash-verified |
| Supported substantive setup candidate | IDENTIFIED; NUM_BANK_FIFOS 8→0 on msa_0/msa_1 |
| Candidate edits / generation / compile | NOT RUN |
| Setup and hold closure | FAIL in existing Work11; candidate untested |
| Constraint completeness | Existing blockers remain |
| DDR simulation | SKIPPED BY USER |
| Broader functional testing | NOT RUN |
| Hardware programming/testing | NOT RUN |
| Query04 / other vendor invocation this task | NOT RUN |
| Readiness / timing / functional acceptance | NOT ESTABLISHED; existing false gates retained |

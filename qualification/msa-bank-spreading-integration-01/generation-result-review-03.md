# Independent native memory-generation result review — candidate03

## Verdict: ACCEPT the native result and the narrow saved/generated drift

The captured once-only save/reload and synthesis-generation run is accepted for **native memory-generation completion, the exact two FIFO corrections, and preservation of the compared generated interfaces/topology**. No unexpected saved or compared generated drift was found. The next useful experiment is the full-FIM build with this corrected memory integrated into a fresh, source-bound WORK—not another parameter investigation or seed retry.

This is not functional, calibration, timing, constraint-completeness, or production-readiness acceptance. Calibration association remains unresolved. The original result and generated comparison deliberately retain their false acceptance/readiness fields; this separate review does not mutate those records or issue build authorization. Continuing ordinary in-scope build preparation needs no new incremental user question, but it still requires new exact source/work/tool/context bindings and an exclusive reviewed build attempt. No DDR simulation prerequisite is imposed; the user skipped it.

Paths below are relative to `qualification/msa-bank-spreading-integration-01`; `G` is `generation-candidate-03`, `R` is `generation-execution-03`, and actual outputs are `R/actual-results/work`.

## Integrity and independent tests actually executed

Local Python checks read the real retrieved bytes; no vendor process, remote call, candidate execution or consumed-attempt rerun occurred.

- Verified all **302 unique transfer entries**, each local size/SHA256, and exact coverage of the retrieved `actual-results` tree. Rehashed the archive, then read every payload directly from it and verified its hash. The archive contains **303 regular members**: the 302 payload files plus `transfer-inventory.json`, whose bytes also match. The initial check expecting 302 archive members was corrected after identifying that explicit extra manifest—not by dropping an unexplained file.
- Recomputed the complete **284-file WORK inventory** and matched every key/hash to `generated-comparison.json`. Precisely, this is **282 files under `mem_ss/`, plus `mem_ss.ip` and `first-save.ip`**; “284 generated files” in the execution summary denotes that whole WORK inventory, not 284 files beneath the synthesis-output directory.
- Rehashed all **21 captured Work11 baseline files** against the original bindings and the separately exported post-run preservation path/size/hash records. The exact synthesis counterpart set contains **17 files**; the four captured simulation-only baseline wrappers are preserved but are not new simulation outputs.
- Independently selected module-owned XML parameter collections through parent relationships, retaining subsystem scope rather than flattening repeated interface properties. Both complete parameter maps match the recorded maps: **3,016 scoped parameters**, exactly `mem_ss|msa_0|NUM_BANK_FIFOS` and `mem_ss|msa_1|NUM_BANK_FIFOS` change **8 → 0**. Both `NUM_COPIES` remain **1**.
- Independently walked paired XML trees recursively, retaining namespace-qualified tags, ordered children, every attribute, every text value, comments and tails. No structure/attribute/tail change occurred. This is stricter than a selected metadata comparison. Saved-tree coverage is **31,812 checker atoms**; the independent full-tree walk found only the same two value changes. First-save and reload are byte-identical.
- Independently compared entire HDL bytes. Each MSA wrapper is byte-identical after substituting exactly its single `.NUM_BANK_FIFOS      (8)` with `(0)`; both top wrappers are byte-identical without substitution. This verifies all HDL beyond the checker's recognized maps, not merely the selected FIFO field.
- Also reproduced the original checker on actual outputs as a cross-check. Saved maps/serialized deltas and generated inventories/maps/deltas reproduce; raw diff text reproduces after changing only the known local-versus-remote absolute filename labels. Python tuples were serialized for comparison with JSON lists. The independent tree/whole-byte checks above do not rely on that checker rerun for acceptance.

### Complete compared drift disposition

| Compared artifacts | Actual drift | Disposition |
|---|---|---|
| Saved `mem_ss.ip` | Two scoped FIFO values, 8 → 0 | Accepted requested correction |
| Twelve SOPCINFO files: outer and nested top, both EMIFs, both clock bridges, both reset bridges, BOT calibration, memory-reset controller, both MSAs | Exactly one `/EnsembleReport/1/#comment` timestamp each, from 2026.09.18 generation to 2026.09.19 generation | Accepted exact timestamp-comment changes; no general metadata waiver |
| Both MSA SOPCINFO files | Additionally `parameter name="NUM_BANK_FIFOS"`, value 8 → 0; type/derived/enabled/visible/valid unchanged | Accepted requested correction |
| Both MSA synthesis wrappers | One FIFO literal each; all other bytes unchanged | Accepted |
| Outer and nested top synthesis wrappers | Byte-identical | Accepted preservation |

Thus **15 of the 17 counterpart files change hash**: saved IP, twelve SOPCINFO files and two MSA wrappers; two top wrappers do not. Full paths, before/after hashes and every independent XML/HDL delta are retained in `generation-result-review-03-evidence.json`. No generated-directory token normalization was needed: the actual relative hierarchy names match.

Wrapper map cross-checks:

| Wrapper | Recognized ports | Ordered parameter/connection entries |
|---|---:|---:|
| MSA0 | 57 | 102 |
| MSA1 | 57 | 102 |
| Nested memory top | 127 | 389 |
| Outer `mem_ss.v` | 127 | 128 |

All four complete port lists are unchanged. The two MSA full maps differ only in FIFO count; both top maps are unchanged. These regex-recognized counts are not substitutes for the whole-byte and complete-XML comparison. For example the saved IP contains 128 physical port mappings, including metadata not counted by the HDL recognizer.

## Actual native execution and diagnostics

Read both exact invocation records and native logs, stage statuses, exclusive claim, outer runner/preflight statuses, generation reports, final result and the bound runner/checker/Tcl. The claim's binding hash matches `G/execution-binding.json`; both invocation argv/cwd/timeouts/environment match the exact stage bindings.

- Save/reload: installed Quartus 26.1.1 `sopc_builder/bin/qsys-script --qpf=none`, corrected preset, fresh `work_ia840f_msa_generation_01`; **native rc0**.
- Generation: installed `qsys-generate`, positional fresh `mem_ss.ip`, `--synthesis=VERILOG --part=AGFB027R25A2E2V`, explicit SOURCE IP search path, `--parallel=off`; **native rc0**.
- Native log shows both MSA leaf generations completing with two modules/17 files, nested generation, and final `Generation of .../mem_ss.ip (mem_ss) took 71278 ms`. The interconnect insertion messages are informational address-width adaptation, not errors.
- Preflight and outer runner statuses are **rc0**. Successful final-result emission follows the runner's complete post-generation source/dependency verification in the inspected code.
- Scanned all **16 retrieved `.log`/`.rpt` files** for timestamp/nested Error/Fatal and parenthesized severity forms, Critical Warning, assertions, rejection markers, ignored/unmatched parameters: **no rejecting diagnostic found**. `generate.log` has 13 warning lines, all the standalone “Quartus project not specified” warning; `mem_ss_generation.rpt` has 12 nested occurrences of the same warning, not twelve additional independent failures. Save/reload has no warning diagnostic.

The no-QPF warning is accepted in this deliberately reviewed standalone context, with explicit part/search path and actual completed outputs. It does not establish that a full-FIM project loads or compiles.

## Preserved contracts and evidence limits

The complete compared XML and byte-identical top wiring preserve the interface/clock/reset boundaries, not just selected public metadata. Actual nested wiring retains each MSA on its corresponding EMIF user clock/reset and its own Avalon/interconnect channel, and retains the two calibration endpoints and common calibration clock. The direct association remains `calbus_0 → EMIF0`, `calbus_1 → EMIF1`; this review neither swaps it nor resolves the prior donor-association discrepancy. BOT/BOT is preserved, not newly qualified.

Both saved EMIF maps retain DDR4 row17/column10/BA2/BG2, DQ64, one rank: configured capacity is 16 GiB per channel. EMIF0 remains DISCRETE and EMIF1 RDIMM. The application mapping, physical channel assignment, clocks, resets and all unrelated parameters are unchanged in the compared artifacts. No newly proven traffic behavior follows from turning bank spreading off; no protected RTL semantic proof, reset-protocol proof or calibration success is claimed.

Rehashed the 35 candidate manifest entries, all 36 staged package files against the captured readback, consumed-review envelopes and both accepted review hashes; also rehashed all 34 candidate02 manifest entries. The preservation transfer envelope matches `baseline-preservation.json` exactly. The three currently integrated local source files match the integration receipt. The binding inventories contain **1,360 SOURCE files, 530 PIM entries and 419 dependencies**. Captured post-verification records report them unchanged, and the verified runner's successful final path checks the complete inventories/dependency hashes again after generation. This is corroborated **captured post-run verification**, not a new independent remote inventory or a claim that all remote dependency bytes are locally available. Future build preflight must check them live again.

The bound SOURCE QSF remains SHA256 `ad68b5bf4666731449b2ae326a0f307065d112fb6bb0a9a0a072a0cd6cb1516c`: hold ON, seed2, maximum-placement effort. Seven-PLL-output/core-470 request, PCIe PF/BAR configuration, board pin assignments and application source mapping were outside the changed memory experiment and are not requalified here. Work11's failed timing and constraint limitations remain in force. No SOURCE/gate/authorization/candidate edit, compile, Query04/equivalent, DDR simulation, hardware action, installation, permission change or commit occurred.

## Minimal next full-build integration

Local procedural evidence inspected: `qualification/fim-build-11/prepare_remote.py`, its `remote-evidence/prepare_handoff_remote.py` and `launch_native_compile.py`, and `qualification/ipgen-04/run-setup.py`, `run-post-setup.py`, `generation-header-review.md`; also the maintained `ofs_ip_cfg_db.tcl` and `gen_ofs_ip_cfg_db.tcl`. These are recipes/evidence, not commands executed by this review.

**Do not simply retarget the Work11 clone recipe and call its Work04 memory corrected.** That recipe copied the old IP-generation tree. Use an exclusive fresh WORK, bind current integrated SOURCE/PIM and unchanged generated dependencies, archive inherited output/QDB/claims, and explicitly replace the obsolete memory subtree with the complete accepted saved/generated result (or regenerate that subsystem at its final location through the now-proven native flow). No need to rerun candidate03 or reopen parameter discovery.

The concrete minimal transplant is:

1. Put the accepted `mem_ss.ip` at `<fresh WORK>/ipss/mem/qip/mem_ss/mem_ss.ip`, and its complete `mem_ss/` output tree at `<fresh WORK>/ipss/mem/qip/mem_ss/mem_ss/`. `first-save.ip` is provenance, not a project dependency. Preserve the original generation evidence. Verify the fresh project selects this IP/QIP and complete vendor RTL/HEX/SDC dependency closure, not an old Work04 or standalone path. Audit/record any absolute-path and symlink relocation, including generation metadata; do not blindly modify protected HDL or binary databases. Unchanged non-memory generated dependencies may be reused only with exact provenance/hash verification. If relocation cannot be proven complete, generate the corrected saved memory at the final project path under a new binding instead.
2. **Re-emit OFS wrappers/configuration headers in the fresh project.** The proven native operation is `quartus_sh -t <fresh WORK>/ofs-common/scripts/common/syn/ip_get_cfg/gen_ofs_ip_cfg_db.tcl --project=ofs_top --revision=ofs_top`, with cwd `<fresh WORK>/syn/board/ia840f/syn_top` and newly bound callback contexts. Verify `ipss/mem/qip/mem_ss/sv_wrapper/mem_ss_sv.sv`, `mem_ss_param_pkg.sv`, `mem_ss_if_info.vh`, `mem_ss_ip_params.vh`, and project `ofs_ip_cfg_db/ip_gen_sv_wrapper_inc.tcl`, aggregate header and local-memory configuration/ASP preset. The exporter uses mtime-based skip conditions: a copied old wrapper/header newer than the transplanted IP must not be mistaken for fresh emission. Retain/exclude stale memory header outputs in this fresh work before emission, or otherwise prove the emission actually ran against the corrected IP. Do not fabricate `setup/emif.tcl`; the proven board include is `../setup/emif_loc.tcl`.
3. Bind the complete fresh integration inventory, actual entry dispatcher, top-level argv and native callback executable/argv/cwd/hash/ancestry contexts; regress missing-record rejection before launch. Use the already exercised Work11 full-build flow, mechanically retargeted only after these new inputs are captured: `build_top.sh --stage=compile -k -p ia840f <fresh WORK>` from SOURCE under its exclusive native runner. The observed Work04 project-IP enumeration flow is available if refreshing the project dependency list is required; wholesale unchanged PCIe/PLL regeneration is not justified by this two-field memory correction.
4. Inspect actual full compile, fit, STA and assembly results: both DDR channels' setup/hold WNS/TNS/failing endpoints, clocks/constraints, routing and warnings, generated hierarchy and artifact hashes. Preserve hold ON/seed2/effort, geometry, application mapping, BOT/BOT, PLL and PF/BAR contracts. An exit-zero image is not functional/timing readiness or permission to program hardware.

This is the next concrete integration/build task under standing scope, not authorization issued by this report. It adds neither a DDR-simulation barrier nor speculative missing-parameter research.

## Exact artifact identities

| Artifact | SHA256 |
|---|---|
| `R/REPORT.md` | `65f0777c353848a7d22fa8d66a00765a21114ac5d890a73137ea163ed31b4df3` |
| `R/actual-results.tar.gz` (2,351,038 bytes) | `4fce51d6111f5e160f8576de259cf4533d1b1174a9051b42626e789d0e5775a0` |
| `R/transfer-inventory.json` | `3eea1071c96e97525fdc41bffb16d81c6b6c14528b3f753e6a62bbd973d9723f` |
| `R/actual-results/package/run/result.json` | `25528e967ba7b1451af2608b3515db959fd23ea643d86eb183f5b94f7ab82247` |
| `R/actual-results/package/run/saved-comparison.json` | `5a6e66c9968977c0734c507569de9b1d9eeed727a0e090e2e58ae8685bc6bb36` |
| `R/actual-results/package/run/generated-comparison.json` | `dfa10442e7ef225d7178cb77c0ded7f5c1e26d36fd9f9f3b3f2616e858931767` |
| Saved/reloaded `mem_ss.ip`, each | `58b2409deb345a56a34b557d735d532d9b61b93b4a58c9dce2c5ab26f02e45c4` |
| Captured post-verification record | `ce47e6ac00e0d9a19a0a2f15cf97326e5522ac4451a66a3bc5880eacd2bc9f74` |
| `generation-result-review-03-evidence.json` | `8cc9a762b463b5a7a5fa7ac843bf4edd3717e885e970cc94c0e1aba82e44a433` |

The evidence JSON contains the complete 15-entry changed counterpart inventory. SHA256 of that list encoded as UTF-8 `json.dumps(changed_counterparts, sort_keys=True, separators=(',', ':'))` is `e81e1831498da6687025ef15bd9d7dc38d48c896b9e1dc9c83c347e91ca962a9`.

Created only this report and its bounded separate evidence JSON. Original generated results, acceptance flags, manifests, consumed reviews and baseline artifacts remain unchanged.

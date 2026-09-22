# Independent SPEC review — actual prepared fanout-diagnostic02

## Verdict

**PASS — package/SPEC review of the exact actual prepared package only. No blocking gap found for the bounded unchanged-SDC representation/edge-filter experiment.**

This is **not** native-result, collector, A/B, clock-repair, timing, hardware or task acceptance, and issues no authorization. QUALITY, parent exact-binding consumption and a separately inspected one-use issuer remain required before native entry. The documented `get_cell_info -buried_regs` behavior for these particular cells remains an experimental question, not a prerequisite that must already have succeeded. The spent predecessor and the old experiment03 candidate remain untouched and unissued by this review. [`AUTHORITY.md:5–9`; `SPEC.md:25–35`]

Review scope: local reads, hashing and parsing; the four explicitly permitted inert fixture commands listed below; this report as the sole authored project file. No remote/native/help/vendor invocation, standalone preparer/runner/gate/issuer entry, hardware, git, authorization or task-state update was performed. Fixture execution includes its expressly allowed mocked entries and temporary inert children; that is not native permission or vendor evidence.

### Path conventions

- `G`: this `fanout-diagnostic02` directory.
- `D`: `G/prepared-readback01` — the actual review target, not an authoring-only draft.
- `F`: sibling `fanout-diagnostic01`; `R`: parent `pcie-clock-repair-01`.
- `N`: `/home/joe/Projects/Thesis/AHLS/new_bsp/new`.
- `Q2`: `N/qualification/fim-build-14/pcie-postfit-02`.
- `H0`: `N/qualification/fim-build-08/pcie-postfit-query-01/api-help2.log`.
- `H1`: `R/api-help01/commands`; `H2`: `R/api-help02/commands`.

All citations are original 1-based text lines. JSON inventories were parsed in full rather than inferred from excerpts.

## 1. Exact package and provenance

Independently decoded the preparation gzip/JSON/base64 archive and checked **15/15 exports** against both the manifest and readback: identical name sets, sizes, hashes and bytes. All **eight** corresponding authoring files also match their exported bytes. Checked the ten exported root-file bindings, both copied gate/dispatcher bindings, and the copied top-SDC binding against actual candidate `files` and applicable `callback_files` entries. The preparer and other receipt-only exports remain manifest-bound; they are not misrepresented as additional candidate file bindings. [`prepared-manifest01.json:2–60`; `D/prepare01.py:91–113`]

| Artifact | Independently recomputed SHA256 |
|---|---|
| `preparation01.json.gz` — 1,433,796 bytes | `d2541de0791d6c5da4f017279ea74ae9b3cb0be32629900a5be8112018ef05cc` |
| `prepared-manifest01.json` | `69db4cf4a1b7c343ae9f607c9273a08473e1ed2cfcaf88c372c57872b767461f` |
| `D/candidate.json` | `a2a1ac74a55d76c5786be5c75517a2860bd53fe4ffc3e0f18720824ac6c77270` |
| `D/SPEC.md` | `2d8d91fad67d98d240b403ec3b487902584ccc1c723984efaaa8b79a27326e9a` |
| `D/AUTHORITY.md` | `490d86e3d64bf7e58be4ae6d5d003ff821621f2de1dbf0d409e1055d578bbbb7` |
| `D/query.tcl` — 198 lines | `de849ce56c3ae6db993a1e27d427c574cf6cccb7b7d68272a1c0ca8ab2468e5c` |
| `D/clock-repair.tcl` | `8486a48acbe4f024beecefb95d09eeab69ce0331d3f16d4a1f9c0591cdb117f2` |
| `D/known-receivers.tcl` | `3bca69f770cba775919b7134822ae5eedcb324c1a25ed5540b781667d798ef6a` |
| `D/run-query.py` | `3735fc3d24ce9c3bf94de92159284858dc2a12fc69c6d2a5e0df32b866be8475` |
| `D/ia840f_clock_fanout02_gate.py` | `146314cf4d01ed8cf3ff06fb67c705aa8ff55757a8d0a350c5a2368770f02307` |
| `D/ia840f_experimental_gate.py` | `7fd44b22cbb6df4ce029d16e08e1db2791184202e405a37f48528f76d2b2b73b` |
| `D/prepare01.py` | `30ade2612c5f26b432813ba20249e186f8ef828b2157a66f490a3710412e84a8` |
| `D/preservation.json.gz` | `ba54fad92731357ffa65f163bdb402f133d3841f5e90660df752ac98f18394af` |
| `D/top.sdc` | `8255b34c200a46178174b9788bdc9231072ae829f57c34703cc63dd28ab66c3d` |

Candidate counts are **7,885 files / 7,762 callback files / 10 links**. Recomputed the callback subset and checked exact root, command, runtime command, runner context, part and permission. `approved=false`, `ready_for_build=false`, permission `exact-offline-fanout-diagnostic02`; the root is exactly `/home/uwb_student00/ahls/new_BSP/qualification/pcie-clock-repair-01/fanout-diagnostic02`, with cwd `/scratch/syn/board/ia840f/syn_top` beneath it. [`D/candidate.json:2–7,7772–7774,15675–15692`]

After normalizing only the successor root/module names back to F, the candidate has exactly the **nine changed file bindings** recorded in `preparation-verification01.json:30–66`, no added/removed file keys, and equivalent links. These changes are SPEC, AUTHORITY, query, root runner/gate, copied gate/dispatcher and the two relocated non-SDC metadata files. The extra preservation **export** adds no candidate file: the same preservation digest was already bound by F.

The research and predecessor consumption chain were independently hashed and checked:

| Evidence | SHA256 |
|---|---|
| `R/forward-lookup-diagnosis01.md` | `55a23ac37c58caeb96204e8c552c5cf6ab5e085fd0adeec1993dbfd560f0acf8` |
| `F/result-independent-review01.md` | `ba605b71b16adfb5eaae517a995e8118cb68c05bfb05d7c644d67604af754a51` |
| `F/parent-result-consumption01.json` | `bbc8b7fa8a736bbcdfd9ed999801d4f4c658a1834256fe02114a83c617920fe2` |

The consumed result is rc3, failed/incomplete: two forward clock-filtered zeros followed by a physical-cell-as-keeper identity failure. This is not absent-load proof. G implements the two separate representation/filter questions identified by the completed research, rather than treating indexed-name escaping as an established sole cause. [`F/RESULT-ACCEPTANCE.md:3–9`; `R/forward-lookup-diagnosis01.md:5–9,70–85,124–134,150–180`]

## 2. Scientific contract and actual query

| Requirement | Finding from actual prepared source |
|---|---|
| Unchanged baseline and exact entry | Dedicated namespace/procedure-local variables; strict successor cwd and exclusive report path; normal `project_open`, timing-netlist creation, argument-free `read_sdc`, update; gate sentinel checked; C absent and helper-created false. `D/query.tcl:6–14,73–94`. |
| Driving association versus definition | Inventory retains explicit clock targets and branches generated-only properties on clock type. Root `get_clocks -of_objects` observations are labeled driving clocks, not new definitions. `D/query.tcl:60–71,95–96`; `H1/get_clocks.txt:12,38–42`. |
| Exact O/K roots | O passes the unchanged helper's exact name/cardinality/output-clock-pin checks. K must resolve exactly once as both keeper and register. No fitted `clock_div2x`, root fallback or guessed alias. `D/query.tcl:45–49,86–96`; `D/clock-repair.tcl:18–25`. |
| Four finite forward calls | Exactly `-clock O`, default O, `-clock K`, default K on validated collections. Every raw count is emitted/flushed before enumeration; no forward `-stop_at_clocks`. `D/query.tcl:12,97–108`. |
| Complete sets, bounded enumeration | Cap4096 per set, four sets/maximum16384 enumerated forward members. All returned names retained, including extra/out-of-prefix members. Duplicate or enumeration/count mismatch marks incomplete. Three declared differences/intersections and membership return unavailable for incomplete sets. No per-load keeper reconstruction. `D/query.tcl:26–40,51–58,108–117`. |
| Independent T and selector matrix | Exact T count/name, memberships and driving clocks precede physical-group decisions. A missing/wrong T marks incomplete without suppressing the first-known-name raw/transformed matrix through cells, keepers and registers. All six lookups retain inputs/counts/names under cap32; outcomes are data, not automatic selector adoption. `D/query.tcl:118–136`. |
| Finite physical groups | Four declared full-hierarchy patterns, bracket-free leaf wildcards, no recursive hierarchy scan. Count before cap128; each must equal its exact saved eight-name set. A mismatched group is marked incomplete/skipped while other groups continue. `D/query.tcl:137–153`. |
| Cell/pin/register namespaces separated | Actual cell IDs drive `get_cell_info`; actual pin collections are enumerated and pin names come from `get_pin_info`. Input-clock predicates select the saved clock pin. Reverse traversal receives a single actual pin ID, not a fabricated collection; count/cap32 and exact K checked. `D/query.tcl:154–173`. |
| Buried-register experiment | Actual `-buried_regs` collection retained and counted before cap32; no physical-name-as-keeper prerequisite. Only a nonempty real collection goes to `get_clocks -of_objects`; per-register name/type and forward memberships retained. Zero/multiple counts are data and set `mapping_single_register_each=false`; aliases are not guessed or rewritten. `D/query.tcl:174–184`. |
| Honest completion | All32 physical cells must be visited once. Cap/type/pin/reverse/group defects prevent completion; API errors propagate instead of becoming empty collections. Completion can legitimately have zero forward sets or zero/multiple buried mappings, but explicitly carries no collector/comparison acceptance. `D/query.tcl:14,26–40,154–195`. |

The physical/pin manifest is byte-identical to F. Independently parsed all32 manifest rows and compared them with the original Q2 raw log: **32 unique cells and saved clock pins, eight per group, all cell types `tennm_ff`, all32 reverse fanins exactly K**. The prior native single-pin-ID call is visible at `Q2/prepared-readback01/query.tcl:24–54`; its earlier broad discovery scan at lines80–95 is **not** copied into G.

The new API use has sufficient source support for this bounded experiment: H0 explicitly documents cell-derived pin and buried-register **collections**, and default level-by-level full-hierarchy matching (`H0:519–537,549–557,589–653`). H1 documents the same-root filtered/default fanout distinction and real-collection clock association (`get_fanouts.txt:17,29–40,67–75`; `get_clocks.txt:38–42`); `get_register_info.txt:15–25,37–43` documents register name/type. No successful design-specific buried-register return is presumed. Errors, zero counts, aliases and multiple mappings are legitimate possible experimental outcomes.

No global escaping/natural-bus mode is changed or queried through an invented switch. The narrow two-pattern matrix is an observation, not a vendor matcher emulator. Captured escaping help specifies setters, with disabling before constraints, not a mode-read API (`H2/use_timing_analyzer_style_escaping.txt:3–10,22–31,52–60`).

**Inactive helper limitation retained, not repaired here:** `D/clock-repair.tcl:45–56` conflates driving-clock association with an output-clock definition. Its `apply` and `verify_created` procedures are not called by this diagnostic; only definitions/identity helpers are used. SPEC explicitly disclaims its readiness for a future candidate (`SPEC.md:7`). Fixing or authorizing that inactive candidate path is outside this review.

## 3. Preparation, preservation and inherited supervision

The captured preparation completed with outer rc0; the archived tests record both actual runner and dispatcher missing-authorization rejections as rc1, `vendor_launched=false`, `authorization_issued=false`, initial copy equality and original preservation. These are saved preparation observations, **not fresh remote measurements by this reviewer**. [`preparation-pane01.txt:1–2`; `D/tests.json:2–15`; `D/prepare01.py:101–108`]

The full preserved original inventory is now exported. Parsed root-entry counts: Work14 **7,346**, SOURCE **1,656**, PIM **536**. Reconciled those recorded inventories with candidate scratch/PIM bindings:

- PIM is identical at the recorded file/link inventory level.
- Scratch has no removals; its sole added file is the copied successor gate. Differences are exactly two relocated links, two relocated non-SDC text files, and the dispatcher insertion. Every relocation old/new value matches `D/path-relocations.json:2–20`.
- Removing the exact new dispatch block from the exported dispatcher reconstructs the original Work14 dispatcher digest. The new block routes only exact `quartus`/successor cwd into the successor gate. [`D/ia840f_experimental_gate.py:289–294`]
- Top SDC agrees with both constraint-delta hashes and the recorded original/copy binding. The preservation inventory has the same digest already bound by F. [`D/constraint-delta.json:2–5`]
- The five historical original-Work14 QDB proxy SDC paths in F's consumed reconciliation now each have explicit equal original-inventory/copy-candidate hashes. This improves saved-inventory reconciliation; it does not rewrite literal logged original paths, prove future storage objects opened, or supply per-open hashes/an access trace. Opaque QDB files were not edited.

Recomputed `runtime-retarget01.diff` directly from F and G source bytes; it is exact. After the explicit root/module/permission/marker/buffer substitutions, runner and gate are byte-identical to their predecessor counterparts. The dispatcher also matches after the exact root/module normalization. Preparer changes are the shown retarget/filename/export delta; exclusive leaf ownership and failure-receipt ownership remain. No inherited supervision redesign is needed. [`runtime-retarget01.diff:1–178`; `D/prepare01.py:34–59,117–121`]

Runtime retains host/uid/owned-tmux checks; exact source, links, native and runner contexts; live claim identity/ancestry; exclusive claim/log/output checks; competing-vendor rejection; MemAvailable80,000,000,000 bytes; wall1800s; address-space64GiB; individual-file128MiB; reports1GiB; original preservation; raw/effective status and termination handling. Preparation retains disk20,000,000,000 bytes. [`D/ia840f_clock_fanout02_gate.py:15–41`; `D/run-query.py:134–135,252–300`; `D/prepare01.py:41–50`]

These are source-bound normal-account controls, **not an OS sandbox**. No unseen issuer is approved. The new `IA840F_FANOUT_CONTRAST_COMPLETE` marker is diagnostic-only and distinct from experiment03's `IA840F_CONSTRAINT_COMPARE_COMPLETE baseline` requirement. [`D/query.tcl:189–195`; `D/run-query.py:291–300`; `R/experiment03/baseline/run-query.py:291`]

## 4. Independent allowed fixture replay

Executed exactly these four fixture invocations, without redirecting over any retained receipt. All returned outer rc0; parsed counts agree with the enumerated passing rows. The complete JSON results also equal the respective retained receipt objects.

| Command, with G expanded to its absolute local path | Passing cases | Retained receipt |
|---|---:|---|
| `python3 -B G/test-query.py` | 25 | `query-tests01.json` |
| `python3 -B G/test-query.py --prepared` | 25 | `query-prepared-tests01.json` |
| `python3 -B G/test-supervision.py` | 11 | `supervision-tests01.json` |
| `python3 -B G/test-preparation.py` | 2 | `preparation-tests01.json` |
| **Total** | **63** | No receipt rewritten |

Query fixtures source the actual main entry using distinct collection/object namespaces; exercise aliases, two explicit matcher scenarios, same names, zero sets, duplicate/over-cap sets, zero/multiple/failed buried-register queries, physical-group/pin/reverse/root defects, and old/wrong/spent paths. They demonstrate control flow only, not Quartus matching, traversal, cardinality or clock propagation. [`test-query.py:18–24,82–153,157–193`]

Supervision replay returned no live owned fixture children in any case; rejected reruns left fixture evidence unchanged. In particular, a zero-exit leader with a surviving writer becomes effective124; deliberately unconfirmable inspection remains `termination_confirmed=false`/effective124 rather than passing. Recomputed the fixture delta: only its expected completion marker differs from F. Preparer replay verified equal evaluated roots and unchanged unowned existing leaf. Python sources in G and D also parsed for Python3.9 syntax. [`test-supervision.py:119–146,167–175`; `supervision-fixture-delta01.diff:3–11`; `test-preparation.py:8–39`]

## 5. Source bindings and preservation of this review target

Additional independently hashed source evidence:

| Evidence | SHA256 |
|---|---|
| H0 | `9ee495aad959b7119eb422b05ecef69345ecda80a7ab87f17d450f6b5d83b6d4` |
| `H1/get_fanouts.txt` | `09a71a0d9b786b8f1107fdd985714e18cf532fbee844c5c83511f564e28ae765` |
| `H1/get_fanins.txt` | `ae8f82a73242cc5f3a7eb9cfbfd8605dfd74e06d9f0b31582afddf5dc21b346b` |
| `H1/get_clocks.txt` | `b06a7efaebb9f06e161c469801a34b6d296506a827dad2db0a423a1ba5367980` |
| `H1/get_register_info.txt` | `402e81385d1f2c39db6c53244f46b2e6f561598f19effc3aa83a98950b095398` |
| `H2/use_timing_analyzer_style_escaping.txt` | `c4d12abc7ee429a3d078d4d2be11769754baa285b0288eca7f9e3d783f0d8b18` |
| `Q2/prepared-readback01/query.tcl` | `c2acd70013ff567004a77199ebc22a977aeb48af03b83c740c8eda24129a333d` |
| `Q2/result-readback01/query.log` | `6d934bb5862574a6518fc5803d051757eefcb88a3caaf2f7db44850971460b89` |

Compared the complete **40-file frozen G snapshot** before and after reads/fixtures: no changed, added or removed frozen file. The inventory SHA256 is `666db7de22bff39b971669d528bd6444107fd12c5edccc4dccf55c2e9dca762a`, computed over UTF-8 `json.dumps(relative_path_to_sha256, sort_keys=True, separators=(',', ':'))`. The explicitly mutable `CURRENT.md` is excluded, as are reviewer output filenames. CURRENT changed during the review, consistent with the allowed parent status update; it is neither candidate-bound nor modified by this reviewer. This report is the only authored project artifact.

## Disposition

**PASS for the exact candidate and manifest above; no package/SPEC blocker.** Proceed only through the remaining review/consumption/issuer barriers. Any frozen package change invalidates this exact-binding verdict.

A future native completion must still receive independent result review: counts and caps, complete identities and extra-member interpretation, physical/timing mapping, native diagnostics, literal SDC-load provenance, termination and original preservation. Empty or positive forward results do not themselves qualify a complete clock-only collector. Known32 plus T is a cross-check, not proof of the whole affected domain. The helper's future candidate defect, full A/B/timing evidence and every hardware/mission gate remain separate and unresolved.

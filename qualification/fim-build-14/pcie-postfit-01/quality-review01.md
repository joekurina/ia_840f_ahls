# Work14 fitted-netlist diagnostic — focused QUALITY review 01

**Verdict: APPROVED. No blocking defects found in the exact prepared package for this single bounded offline diagnostic.**

This is a quality-review disposition, not authorization issuance, native-result acceptance, timing acceptance, build readiness, hardware qualification, or completion of the larger task. The renewed authority in `AUTHORITY.md` is accepted; the historical Query04 approval timeout is not reopened.

## Reviewed identity

The target is the actual `prepared-readback01/` export, not the adjacent authoring copies or an assumed live remote tree.

| Artifact | SHA256 |
|---|---|
| `prepared-manifest01.json` | `41cacf060bbea75bf4455cb617a5f7b295d7d8c5f78079bb5553fbc0a90ed886` |
| `prepared-readback01/candidate.json` | `5e20a7a1b2be00d53a72972cdf09fa4ab1cc93d9e330f010f69c4b0954e52776` |
| Prerequisite `spec-review01.md` — PASS | `9030581389e80f35927540bc516edc440718dbc5e349a0183fda5c0a7c2979a3` |
| `preparation01.json.gz` | `ea27914ea09b40e29314b66bce4e1314f9c2ec707dd6ac09c58d53ad2636d283` |

Read the full SPEC review and all prepared code/documents; parsed the complete candidate and its inventories. Independently recomputed sizes and SHA256 for all **nine** manifest entries and checked exact file-set and byte equality with decoded preparation batch `ia840f_w14_postfit_preparation01`. All match. Candidate size is **4,001,828 bytes**.

Local inert checks passed:

- Python AST parsing of all four prepared Python files, including Python 3.9 grammar matching the recorded remote runner interpreter.
- `libtcl8.6.so` `Tcl_CommandComplete` returned **1** for the actual query bytes. The query was **not evaluated**; this is delimiter/completeness checking, not vendor API validation.
- Candidate contains **7,880 prelaunch file bindings, 7,757 callback file bindings, and 10 links**. Callback bindings equal the prelaunch map minus exactly 112 `.rpt`, 4 `.log`, 2 `.qpf`, and 5 `.summary` entries; retained digests are identical.
- Actual runner, query, authority, standalone gate, copied gate and scratch dispatcher hashes match their candidate bindings. Installed STA launcher/runtime hashes match captured preflight identities.
- The gate is exactly the previous Query03 gate after the finite evidence-root, rejection-label and permission retargets. The scratch dispatcher differs from the exported Work14 dispatcher only by its new first diagnostic branch.
- All four recorded relocation after-values match the candidate; all ten link targets remain lexically within the attempt root. Preflight/candidate membership comparison shows no removed Work14 or PIM entries and only the added diagnostic gate in scratch. Eight selected original exports, including QSF/QPF, existing SDC/utilities, build environment, project macros, compile gate and config helper, hash-match the corresponding candidate entries.

The preflight tree listing records ordinary-file sizes and links, **not a complete before-hash inventory**. It supports the membership comparison, not an independent byte-wide preservation claim. Complete original-tree preservation is the preparation's recorded check against `preservation.json.gz`, whose SHA256 is candidate-bound as `ba54fad92731357ffa65f163bdb402f133d3841f5e90660df752ac98f18394af`. That gzip was not exported here. No live remote remeasurement is claimed.

## Blocking findings

**None.** No package change or additional fixture framework is required by this review.

## Quality findings

### Guard and exact invocation — PASS

The sole runner-native argv is exactly:

```text
["/opt/altera/26.1.1/quartus/bin/quartus_sta", "-t", "/home/uwb_student00/ahls/new_BSP/qualification/fim-build-14/pcie-postfit-01/query.tcl"]
```

Native cwd:

```text
/home/uwb_student00/ahls/new_BSP/qualification/fim-build-14/pcie-postfit-01/scratch/syn/board/ia840f/syn_top
```

The callback separately requires executable `/opt/altera/26.1.1/quartus/linux64/quartus_sta`, argv beginning with literal `quartus_sta` followed by the same `-t` and absolute query path, and that exact project cwd. Launcher SHA256 is `06c1bd805bc078d9636015c472e09a054160c405f3f06b7c555e7a4b6f7d3f14`; runtime SHA256 is `d675f96e7dffe1f7c736dfe2a20e1d3f4e576a5a53f714a644d2082c00fd4fae`. The captured launcher source hash also equals the candidate's launcher pin, and its `exec` behavior explains the inner argv form.

The runner context is `/usr/bin/python3.9`, argv `["python3", "-B", "/home/uwb_student00/ahls/new_BSP/qualification/fim-build-14/pcie-postfit-01/run-query.py"]`, cwd `/home/uwb_student00/ahls/new_BSP/qualification/fim-build-14/pcie-postfit-01`.

`ia840f_w14query01_gate.py:25–40` requires an exact authorization object bound to the candidate hash and permission `exact-read-only-postfit-w14query01`, checks part `AGFB027R25A2E2V` and false readiness, and validates file/link bindings. `:10–24,37–40` rereads the whole live runner claim, including PID, parent PID, start ticks, executable, argv and cwd, then traverses live ancestry and independently validates the immediate native STA identity. It does not authorize an arbitrary process merely because it inherited a stage label.

`ia840f_experimental_gate.py:291–294` routes the actual scratch cwd first and returns after successful diagnostic validation; inherited compile/setup routes are retained. The candidate-bound `build_gate.tcl` resolves its dispatcher relative to the copied script. Its retained rejection variable is checked immediately after `project_open` in `query.tcl:5`, before netlist creation. Thus the known Quartus source-script error-to-warning downgrade is not silently treated as permission to continue this query.

The prepared `tests.json` records actual missing-authorization runner and dispatcher rejection with rc1, no vendor launch, and no authorization issuance. The preparation code also checks absence of query claim/log artifacts. These are existing preparation results, not tests rerun by this reviewer.

### Single-use execution and workstation protection — PASS

`run-query.py:24–46` checks the ordinary host/UID and executing pane's owned tmux session, validates the package before claiming, requires at least **80,000,000,000 bytes MemAvailable**, and rejects competing `quartus_`/`qsys-` process names. Preparation separately checks memory and **20,000,000,000 bytes** free disk before copying.

The runner exclusively creates `query.claim` before native launch and exclusively creates the log and result artifacts. It never removes the claim or retries the native operation. There is one `Popen` followed by `wait()` with **no timeout**, consistent with the persistent-run specification. It sets the **64 GiB soft/hard RLIMIT_AS** and applies `os.nice(10)` before spawning. Those limits are inherited process safeguards, not an aggregate cgroup limit or a guarantee of workstation survival.

Inherited OFS/Python setup state is sanitized, exact Quartus paths and copied scratch/PIM roots are supplied, and native output is retained in `query.log`. This is an ordinary-account, source-bound guarded experiment, **not an OS sandbox**.

### Preservation and result ordering — PASS

`prepare01.py:46–56,95–98` inventories original Work14/SOURCE/PIM, copies with `cp -a --reflink=auto`, verifies initial copies, and rechecks originals after the scratch-only relocations and gate insertion. The prepared receipt reports these checks passing. Existing W13, persona artifacts and historical claims are not modification targets.

`run-query.py:47–48` persists the raw native return code and explicit `PENDING LOG AND INDEPENDENT REVIEW` status **before** reading/decompressing the preservation baseline, rehashing originals, or exporting evidence. Original-tree mismatch produces a nonzero runner exit. On the ordinary postflight path, native nonzero codes are returned and negative signal codes become `128 + signal`. Claims and available evidence remain consumed/preserved after failure. Exceptional postflight handling has a nonblocking limitation described below; it does not erase an already written native status or promote it to success.

### Query scope and diagnostic correctness — PASS

The query opens the copied existing project/revision, creates the default post-fit timing netlist, loads existing SDC, updates that netlist, inspects it, and closes it. It does not add clock/exception commands, refit, assemble, program hardware, or edit maintained constraints. Native project/cache writes may occur in the copy; “read-only” here is diagnostic intent and preservation of original inputs, not a promise that Quartus writes no ordinary files.

All diagnostic temporaries are procedure-local inside `::ia840f_w14_query`, avoiding the earlier global scalar/array collision. The exact `inclk`, `clock_div2`, and `clock_div2x` selectors remain distinct. Divider cell/pin identity, directions, clock-pin attributes, input fanins and output clock-target counts are reported, with names/periods/master/source fields when target association resolves.

Four independently counted receiver groups are retained under the explicit PCIe hierarchy: `cplto_fifo_avmm_inst` with `rs_dgwp|dffpipe`; `cplto_fifo_lite_inst` with `ws_dgrp|dffpipe`; `u_axi_lite_clk_to_user_avmm_clk_fifo` with `rs_dgwp|dffpipe`; and `u_user_avmm_clk_to_axi_lite_clk_fifo` with `ws_dgrp|dffpipe`. The script inspects clock-input fanins for selected receiver cells. It errors instead of silently truncating above 128 selected cells per group or 32 fanins per inspected pin. Divider cardinality other than one and empty receiver groups fail explicitly.

The finite installed-help comparison supports default post-fit creation, hierarchical enumeration and `get_fanins -clock -stop_at_clocks` usage. Help file `fim-build-08/pcie-postfit-query-01/api-help2.log` hashes to `9ee495aad959b7119eb422b05ecef69345ecda80a7ab87f17d450f6b5d83b6d4`. Actual fitted object matches, missing/zero counts, unsupported API results and incomplete inventory remain **experiment outputs**, not circular prerequisites to allowing this diagnostic.

## Nonblocking hardening and interpretation notes

1. **Input-pin `-net` field — `query.tcl:45`.** The script requests `get_pin_info -net` for every selected pin, including input clock pins. Captured help documents that field for output pins. Do not interpret an input `NET_ID` value as proven connectivity. Input evidence comes from the separately requested fanins; a native rejection or unavailable result is an incomplete diagnostic finding. A future revision could restrict this optional field to output pins so it cannot interrupt otherwise useful input/fanin reporting. This does not require a new pre-execution API experiment or block these reviewed bytes.
2. **Exceptional postflight reporting — `run-query.py:49–56`.** A preservation-read/hash/export exception exits through Python and can replace the outward native exit code with rc1 or omit later receipts. The raw `native-result.json` has already been written. Optional future hardening could annotate each postflight/export failure independently and preserve native nonzero status at the outer boundary. For this attempt, use the stored native status, log and preservation receipt together; a missing preservation receipt is unresolved, never a preservation pass.

Neither item changes this verdict or authorizes modifying the review-bound files in place.

## Result-review and action boundary

`QUERY_INVENTORY_END` occurs before final cardinality checks; it is not a success marker. `W14_POSTFIT_QUERY_COMPLETE` indicates script completion only. Even with native rc0, zero selector/clock-input/fanin/clock-target counts, missing master fields, unsupported results or gate diagnostics require explicit interpretation. Target association is not proof of complete propagated-clock coverage. Inspect full native output and original-tree preservation before using findings to propose any constraint repair; this package performs no timing acceptance.

Work14 remains preserved diagnostic provenance. It is not relabeled as the selected final OFS `ofs-2026.1-1` target, whose independent companion/upstream review is separate. Hardware qualification is not made a prerequisite for this offline inspection.

Reviewer actions were local file reads, hashes, JSON/archive comparisons, Python AST checks, a non-evaluating Tcl completeness check, and finite captured-source/help comparisons only. No package main/preflight/guard/runner or vendor Tcl was executed; no remote, vendor, hardware, authorization, source or git operation was performed. The sole requested project artifact written is this report.

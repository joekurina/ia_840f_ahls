# Work14 pcie-postfit-02 — focused independent SPEC review

**Verdict: PASS. No blocking specification gaps found in the exact prepared successor package.** This approves the narrow diagnostic specification only, not authorization issuance, native success, timing acceptance, source-constraint changes, hardware qualification, or completion of the parent task. Fresh QUALITY review and parent consumption remain separate requirements.

## Exact review target and checks

Reviewed `AUTHORITY.md`, `successor-delta01.json`, `query-delta.diff`, and the actual `prepared-readback01/` exports. Reused the predecessor's accepted SPEC/QUALITY findings and `ACCEPTANCE.md`; verified their hashes against its parent-consumption receipt rather than repeating upstream research.

| Artifact | SHA256 |
|---|---|
| `prepared-manifest01.json` | `ad784bb3b9f490cda8ba4690545e52910aa4412f80f6e258b9b218595e8e627b` |
| `prepared-readback01/candidate.json` — 4,001,828 bytes | `bac66033e796c0ecb6f3390dd512751b3475b1bca440c1a7d591092e4e4821f4` |
| `preparation01.json.gz` | `9b47e7fd48b04f35b491ddf6af0f815ddf06e141cf855d6cbb752bf647f9c31c` |
| `prepared-readback01/query.tcl` | `c2acd70013ff567004a77199ebc22a977aeb48af03b83c740c8eda24129a333d` |
| `successor-delta01.json` | `3102684086d9acebe388eea75976d5604a03844599c4aeae1ecf3e1cfe49100b` |
| `query-delta.diff` | `ffa43801731726af63a5cc4795b2f19147149e51022ef879affecc68c39012a9` |

Local read-only verification passed:

- All **nine** manifest entries match recomputed byte counts and SHA256, the exact file set and decoded bytes of preparation batch `ia840f_w14_postfit02_preparation01`. Adjacent authoring files match their prepared exports where present.
- All four prepared Python files parse under Python 3.9 grammar. No imports, package functions, gate, preparation, runner, query or vendor commands were executed by this reviewer.
- The candidate contains **7,880 prelaunch files, 7,757 callback files and 10 links**. Callback bindings are exactly prelaunch bindings minus 112 `.rpt`, 4 `.log`, 2 `.qpf` and 5 `.summary` entries; retained digests agree.
- Query, runner, authority, standalone gate, copied gate and copied dispatcher hashes match candidate bindings. The two STA tool pins are unchanged from the accepted predecessor. All four relocation after-values match the candidate; all ten link targets remain lexically within this attempt.

These checks authenticate local exports and their internal/provenance consistency. They are not a live remote remeasurement or independent local rehash of every original/database file.

## Narrow-delta findings — PASS

The actual predecessor failed at `targets $p` because its helper iterated a single `_quartus_sta_pin__53563` handle as a collection. See [independent predecessor result review](../pcie-postfit-01/result-independent-review01.md). That is observed native failure evidence, not a speculative API prerequisite.

The recomputed Tcl diff equals `query-delta.diff` exactly, and every old/new digest in `successor-delta01.json` matches the corresponding prepared bytes. The sole semantic correction is:

1. `targets {names label}` accepts a plain Tcl list and uses exact name matching against clock targets; it no longer collection-iterates its argument.
2. `clock_fanins` still iterates the actual `get_fanins -clock -stop_at_clocks` collection, appending each node name into a list before calling `targets`.
3. An output pin calls `targets [list $pn] ...`, preserving its complete name as one list element.

This removes the observed node-versus-collection misuse without asserting that all subsequent native API behavior is proven. Exact native output remains the purpose of the corrected experiment.

Preparation, runner, gate and scratch dispatcher are **byte-exact mechanical retargets** after the finite attempt-path, gate-name, permission/rejection-label and unique-buffer substitutions. No extra operational logic changed. Candidate noninventory fields and links match the retargeted predecessor. Inventory membership is identical after path/gate-name retargeting; exactly eight bound file digests differ: authority, query, runner, two gate copies, dispatcher, and the two recorded path-relocated JSON/XML files. All remaining bindings, including fitted database, QSF/QPF, constraints, tool binaries and the preservation baseline, are unchanged. The relocation records retain identical original before-values; their new digests are bound, not independently reconstructed from unexported XML/JSON bytes.

## Requirements retained — PASS

### Isolation, authority and preparation

`AUTHORITY.md` explicitly carries the renewed user authority forward and does not reopen the historical Query04 approval timeout. `prepare01.py:7–8,39,46–56` requires a fresh attempt and copies **original Work14 and original PIM**, not attempt01's post-query scratch. Original Work14/SOURCE/PIM inventories are captured and rechecked (`:95–98`). W13, persona and the consumed predecessor are not modification targets.

The preparation dispatch records `@36/%36`; `tests.json` records initially identical copies and unchanged donors. Its actual runner and scratch-dispatcher missing-authorization tests each returned rc1 with `W14QUERY02_REJECT missing reviewed authorization`. Preparation checks absence of native claim/log artifacts before exporting and records `authorization_issued=false`, `vendor_launched=false`. These are captured preparation results, not tests rerun here or a claim about later live state.

The nine-file excerpt is not the full scratch tree. Missing adjacent compile-gate imports in a local excerpt are not evidence that the native tree lacks those files: the full candidate binds the unchanged `ia840f_compile_gate.py` and `build_gate.tcl`; actual prepared rejection tests reached the successor authorization rejection. No import-based hardening detour is required.

### Exact invocation and execution guard

The sole proposed native argv is:

```text
/opt/altera/26.1.1/quartus/bin/quartus_sta -t /home/uwb_student00/ahls/new_BSP/qualification/fim-build-14/pcie-postfit-02/query.tcl
```

Native cwd is the attempt's `scratch/syn/board/ia840f/syn_top`. Runtime validation separately requires `/opt/altera/26.1.1/quartus/linux64/quartus_sta`, literal runtime argv `quartus_sta -t <exact query path>`, and that cwd. Runner identity remains `/usr/bin/python3.9`, argv `python3 -B <exact attempt/run-query.py>`, cwd the attempt root.

The gate requires the exact separate authorization object, candidate digest and permission `exact-read-only-postfit-w14query02`, preserves part `AGFB027R25A2E2V` and false build readiness, validates files/links, rereads full live runner identity including PID/start ticks, checks live ancestry, and separately checks the immediate STA context. The dispatcher routes the successor cwd first. The query retains its immediate post-`project_open` gate-rejection check. Candidate `approved=false` and `ready_for_build=false` are unchanged; this review issues no authorization.

### Workstation safeguards and persistence

The unchanged runner requires the ordinary host/user and owned tmux session, at least **80,000,000,000 bytes MemAvailable**, and no competing `quartus_`/`qsys-` processes. Preparation also requires **20,000,000,000 bytes free disk**. The runner sanitizes inherited environment, sets **64 GiB RLIMIT_AS** and `os.nice(10)`, exclusively creates a persistent claim/log, starts one native process and waits without timeout or retry. Raw native status is written before fallible preservation/export work. These are operational safeguards, not an OS sandbox or guarantee of workstation survival.

### Query scope and completeness

All other Tcl is unchanged: namespace/procedure-local temporaries; separate `inclk`, `clock_div2`, `clock_div2x` selectors; divider pin/direction/clock attributes; fanin and target-associated clock/master/source reporting; and four independently counted FIFO groups:

- `cplto_fifo_avmm_inst` / `rs_dgwp|dffpipe`;
- `cplto_fifo_lite_inst` / `ws_dgrp|dffpipe`;
- `u_axi_lite_clk_to_user_avmm_clk_fifo` / `rs_dgwp|dffpipe`;
- `u_user_avmm_clk_to_axi_lite_clk_fifo` / `ws_dgrp|dffpipe`.

Bounds remain 32 fanins per inspected pin and 128 selected cells per FIFO group, with explicit errors on exceeding either, divider cardinality other than one, or an empty FIFO group. Existing SDC is loaded; **no new clock/exception command, maintained source edit, refit, assembly or hardware operation is added**.

## Retained limitations and result boundary

- Input-pin `get_pin_info -net` is not connectivity proof. Use separate fanin evidence; unsupported or interrupted API output remains incomplete evidence.
- Exceptional postflight/export handling can replace the outward native exit status or omit later receipts. Require raw `native-result.json`, full `query.log`, and `preservation-after.json` together; missing/false preservation is unresolved/failure, never pass. No unrelated runner hardening is demanded for this narrow successor.
- `QUERY_INVENTORY_END` precedes final cardinality checks. Even `W14_POSTFIT_QUERY_COMPLETE` plus rc0 establishes neither complete clock coverage nor timing acceptance. Review exact selectors, counts, returned names, masters/fanins, warnings and preservation after execution. Zero target-clock counts are not proof of complete propagated-clock absence.
- This PASS does not repair the independently observed unassigned divider-clock warning, qualify EMIF1 hold or other timing, or complete hardware acceptance. The selected OFS `ofs-2026.1-1` target remains unchanged; accepted upstream-pin review is not reopened.

Only local evidence reading, JSON/archive comparison, hashing, Python AST parsing and finite text comparison were used. No remote/vendor/hardware/source-modification/git action or authorization issuance occurred. The only written artifacts of this delegated review are this report and the requested predecessor result review.

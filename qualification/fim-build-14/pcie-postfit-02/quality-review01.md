# Work14 pcie-postfit-02 — focused QUALITY review 01

**Verdict: APPROVED. Blocking defects: none.**

The exact prepared successor integrates the narrow node-versus-collection correction without changing the accepted operational safeguards. This is package-quality approval only: not authorization issuance, native-result acceptance, timing acceptance, build readiness, hardware qualification, or completion of the parent task. Native success is an experiment outcome, not a prerequisite to this corrected diagnostic.

## Reviewed identity and verification

The review target is the actual `prepared-readback01/` export. The predecessor's accepted safety findings and parent dispositions are reused, not reopened.

| Artifact | SHA256 |
|---|---|
| Prerequisite `spec-review01.md` — PASS | `6a6817d6bf4b8a9d66ca0e2fc72e6a1cd5d13c197597b86e12cf069ad870ffb8` |
| `prepared-manifest01.json` | `ad784bb3b9f490cda8ba4690545e52910aa4412f80f6e258b9b218595e8e627b` |
| `prepared-readback01/candidate.json` — 4,001,828 bytes | `bac66033e796c0ecb6f3390dd512751b3475b1bca440c1a7d591092e4e4821f4` |
| `preparation01.json.gz` | `9b47e7fd48b04f35b491ddf6af0f815ddf06e141cf855d6cbb752bf647f9c31c` |
| `prepared-readback01/query.tcl` | `c2acd70013ff567004a77199ebc22a977aeb48af03b83c740c8eda24129a333d` |
| `successor-delta01.json` | `3102684086d9acebe388eea75976d5604a03844599c4aeae1ecf3e1cfe49100b` |
| `query-delta.diff` | `ffa43801731726af63a5cc4795b2f19147149e51022ef879affecc68c39012a9` |

Independent local checks passed:

- All **nine** prepared exports have exact manifest byte-count/SHA256 matches and equal the decoded bytes and file set of batch `ia840f_w14_postfit02_preparation01`. Adjacent authoring copies agree where present.
- The prerequisite SPEC and predecessor failed-result review match `parent-spec-consumption01.json`. The predecessor's consumed SPEC/QUALITY, manifest and archive hashes also match its `parent-consumption01.json`; its nine prepared exports match its manifest.
- All four prepared Python files parse using Python 3.9 grammar. Non-evaluating `Tcl_CommandComplete` returned **1** for the actual query bytes. No package code or Tcl query was executed.
- All old/new digest pairs in `successor-delta01.json` match the actual prepared files, and the recomputed query diff equals `query-delta.diff` byte-for-byte.
- Preparation, runner, gate and dispatcher are byte-exact mechanical retargets under the finite attempt-root, gate-name/rejection-label, permission and unique-buffer substitutions. No additional operational logic changed.
- Candidate metadata and link map equal the retargeted predecessor; inventory membership is identical. Exactly **eight** file digests differ in each inventory: authority, query, runner, standalone and copied diagnostic gates, scratch dispatcher, and the two recorded path-relocated XML/JSON files. All other bindings, including fitted database, QSF/QPF, constraints, STA tools and preservation baseline, are unchanged.
- There are **7,880 prelaunch files, 7,757 callback files and 10 links**. Callback entries retain their prelaunch digests and omit exactly 112 `.rpt`, 4 `.log`, 2 `.qpf` and 5 `.summary` files. Actual query/runner/authority/gate/dispatcher bytes match all six applicable candidate bindings. All four relocation after-values match the candidate; all ten links are lexically confined to this attempt.

These are export-integrity and internal/provenance checks, not live remote remeasurement or an independent rehash of unexported original trees. The XML/JSON relocation content and preservation baseline are inventory-bound evidence, not locally reconstructed payloads.

## Narrow diagnostic correction — PASS

The predecessor log was rehashed against its result manifest (`f0c8dce7b70dae4b917b18fbee0987bc16b699d30461e51a75fb12ac2e03e1e4`). Its `query.log:496–543` shows valid exact divider input/output pin resolution, a successful input fanin/clock association, then Error23035 at `targets $p`: the helper attempted to iterate `_quartus_sta_pin__53563` as a collection. The accepted independent result remains **native rc3 / partial evidence**, not a diagnostic pass.

The corrected prepared `query.tcl` resolves precisely that misuse:

1. **`:11–23` — names-list interface.** `targets {names label}` no longer collection-iterates its argument. It iterates the actual clocks and clock-target collections and uses `lsearch -exact` on returned node names. Hierarchy separators and bracket-bearing names remain data, not glob patterns. The inner `break` counts each matching clock once, rather than counting every target or fanin; explicit `CLOCK_TARGET_COUNT 0` remains possible and visible.
2. **`:24–35` — fanin collection conversion.** `get_fanins -clock -stop_at_clocks $pin` still supplies the collection actually traversed. Each returned node name is appended with `lappend`, preserving one list element per name, before passing the ordinary list to `targets`. The existing 32-fanin bound and emitted count remain intact. An empty collection produces an empty names list and zero target associations, not a collection-handle error.
3. **`:45–50` — singleton output.** `targets [list $pn]` supplies exactly one complete pin name. Neither the scalar pin handle nor an unquoted name is treated as a collection. Input clock pins still follow the separate fanin path.

This removes the observed failure mechanism. It does not establish that every later native API call will succeed or that all fitted clock associations will resolve.

### Cardinality and coverage retained

`query.tcl:60–63` keeps `inclk`, `clock_div2` and `clock_div2x` selectors separate. Their counts are reported rather than conflated; the predecessor's observed counts were respectively 1, 1 and 0. Divider inspection still reports all selected pins, directions and clock attributes. FIFO inspection still selects clock-input pins in four independently counted groups:

- `cplto_fifo_avmm_inst` / `rs_dgwp|dffpipe`;
- `cplto_fifo_lite_inst` / `ws_dgrp|dffpipe`;
- `u_axi_lite_clk_to_user_avmm_clk_fifo` / `rs_dgwp|dffpipe`;
- `u_user_avmm_clk_to_axi_lite_clk_fifo` / `ws_dgrp|dffpipe`.

More than 128 selected cells per FIFO group or 32 fanins per inspected pin raises an error rather than silently truncating. Final checks require exactly one divider cell and nonempty FIFO groups. Pin-selector, clock-input, fanin and clock-target counts are not all mandatory-positive success predicates; their actual values still require result interpretation. The predecessor's unprinted output-clock/FIFO results are incomplete evidence, not zero-valued design counts.

## Integration and retained safeguards — PASS

The prepared runner/gate/dispatcher point consistently to `pcie-postfit-02`, including the dispatcher's first scratch-cwd branch and immediate post-`project_open` rejection check. The sole proposed native command remains:

```text
/opt/altera/26.1.1/quartus/bin/quartus_sta -t /home/uwb_student00/ahls/new_BSP/qualification/fim-build-14/pcie-postfit-02/query.tcl
```

Its cwd is the attempt's `scratch/syn/board/ia840f/syn_top`. Exact launcher/runtime and runner identities, separate candidate-hash-bound permission `exact-read-only-postfit-w14query02`, live runner PID/start/context and ancestry checks, and persistent exclusive claim/log creation remain unchanged. Candidate `approved=false` and `ready_for_build=false` remain intact.

Preparation copies original Work14 and PIM, not attempt01's post-query scratch; its captured receipt records initially identical copies and unchanged original Work14/SOURCE/PIM. Actual prepared runner and dispatcher missing-authorization tests both returned rc1 with `W14QUERY02_REJECT missing reviewed authorization`, with no authorization issuance or vendor launch recorded. These are captured preparation results, not tests rerun here or a claim about later remote state.

The ordinary-user/owned-tmux checks, at least **80,000,000,000 bytes MemAvailable**, no competing native tools, **64 GiB RLIMIT_AS**, `nice(10)`, one persistent native invocation without timeout/retry, and raw native-status persistence before postflight/export are retained. They are safeguards, not OS sandboxing or a guarantee against vendor failure. No maintained constraint change, new clock/exception command, refit, driver/huge-page change or hardware operation was added.

## Nonblocking limitations and acceptance boundary

- **Input-pin `get_pin_info -net` (`query.tcl:46`)** retains the accepted output-only API caveat. An input `NET_ID` is not connectivity proof; use the separate fanin evidence. Unsupported or interrupted output remains incomplete evidence.
- **Exceptional postflight/export (`run-query.py:49–56`)** can alter the outward exit status or omit later receipts. Require stored `native-result.json`, full `query.log` and `preservation-after.json` together after any eventual run. Missing or false preservation is unresolved/failure, never pass; transport/outer status is not a replacement for native status.
- `QUERY_INVENTORY_END` precedes final cardinality checks. Neither that marker, `W14_POSTFIT_QUERY_COMPLETE`, nor native rc0 establishes complete propagated-clock coverage or timing acceptance. Inspect names, exact selectors, counts, masters/sources, fanins, warnings, gate diagnostics and preservation. Zero target associations are not proof of complete clock absence.

No package changes or additional fixture framework are required. Renewed in-scope authority and the accepted OFS2026.1 target disposition are not reopened. Existing timing and hardware acceptance remain incomplete.

**Review action boundary:** only local reads, hashing, JSON/archive comparison, static text/AST parsing and a non-evaluating Tcl completeness check were performed. No remote, vendor, hardware, git, source modification, authorization issuance or runner/gate/query execution occurred. The only file written by this reviewer is this report.

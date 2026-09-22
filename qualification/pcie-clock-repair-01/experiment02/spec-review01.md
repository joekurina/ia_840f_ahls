# Independent SPEC review — actual prepared experiment02 A/B

## Verdict: REQUEST_CHANGES — one blocking SPEC gap (S1)

**The actual prepared package cannot perform the specified fresh experiment02 acquisition: both bound queries still recognize only experiment01 project paths.** This is a deterministic package-path mismatch, not a demand for successful native timing results before approving an experiment. The source/constraint hypothesis remains supported. The Q1 supervision correction has the requested control-flow structure and passes the permitted inert regressions, but that does not cure S1 or replace the subsequent independent QUALITY review.

Do not issue either native authorization against these bytes. Preserve this package and its evidence; correct forward into a fresh, exactly bound package and obtain fresh SPEC→QUALITY→parent consumption before one-use issuance. No native outcome, source promotion, fit, timing closure or hardware acceptance is supplied.

## 1. Blocking S1 — unchanged query retains the rejected predecessor root

**Affected:** both `baseline/prepared-readback01/query.tcl` and `candidate/prepared-readback01/query.tcl`, SHA256 `8ed2064e0b99c598b457a936f064ee6db6a260b2b672e9fe6c6949fd6d47124c`.

The actual code sets, at line 7:

```tcl
variable E /home/uwb_student00/ahls/new_BSP/qualification/pcie-clock-repair-01/experiment01
```

At lines 38–43, `main` imports that namespace variable, starts `variant` empty, compares `[pwd]` literally against `$E/baseline/scratch/syn/board/ia840f/syn_top` and `$E/candidate/scratch/syn/board/ia840f/syn_top`, and rejects an empty variant with `CLOCK_REPAIR_REJECT unexpected project path`.

The two actual `candidate.json` records instead bind these launch working directories:

```text
/home/uwb_student00/ahls/new_BSP/qualification/pcie-clock-repair-01/experiment02/baseline/scratch/syn/board/ia840f/syn_top
/home/uwb_student00/ahls/new_BSP/qualification/pcie-clock-repair-01/experiment02/candidate/scratch/syn/board/ia840f/syn_top
```

Their argv directly selects the corresponding experiment02 `query.tcl` through `quartus_sta -t`. `run-query.py:152–153` uses the record's argv and cwd; neither runner supplies a Tcl root override. The query sets the old root itself and invokes `main` at line 150. The helper sourced at query line 4 does not change cwd or the comparison namespace's root.

An independent local string/record comparison returned **`any_path_match=false` for both phases**. Thus, when reached with either bound launch cwd, the query's own path check rejects before report-directory creation at lines 44–47 and `project_open` at line 49. This is a static control-flow conclusion; no native query was run. An issued launch would spend its runner claim without reaching the intended acquisition. Running in the old root is not a remedy: it contradicts the bound contexts and preserved-predecessor scope, and the query also derives its report destination from that old root.

### Why the existing green checks do not close S1

- Query/helper/top-SDC byte equality to experiment01 was independently confirmed. For this query, equality also preserves a live path constant; it is not proof of a complete successor retarget.
- `test-guard.py:118–127` removes the terminal `::ia840f_constraint_compare::main` call and tests definitions/literal escaping. It does not exercise phase selection against either prepared cwd.
- `test-supervision.py:35–62` exercises actual Python runner control flow with a temporary `E` and a real inert Python child that writes fixture reports. It deliberately does not execute the actual Tcl query.
- The real missing-authorization checks correctly reject before the query can run. The candidate-gate fixtures test baseline-result eligibility, not query routing.

### Narrow required correction

Mechanically bind the query's root to the fresh successor's exact phase/report roots, preserving its scientific/reporting logic and strict cwd rejection. Reconcile that root with both actual records' cwd/argv and the report locations using an inert/static regression that covers the query entry-path decision; retain rejection of old/wrong roots. Do not loosen the path guard, run the preserved predecessor, or introduce another clock/exception experiment.

Recompute the query's file and callback bindings, candidate records, lossless exports/manifests and relevant test receipts; independently review the resulting exact bytes. Revise the claim of byte-identical query reuse to distinguish the necessary mechanical path retarget from unchanged scientific logic. No package or test was changed by this reviewer.

## 2. Exact current binding and integrity — verified

Review targets are **only** `baseline/prepared-readback01/` and `candidate/prepared-readback01/`, with their sibling `prepared-manifest01.json` and `preparation01.json.gz`.

Both gzip archives were decoded in memory. Every exported byte, byte count and SHA256 matched the archive entry, manifest and actual readback file. Each actual directory contains exactly the declared **13 exports**, with no missing or additional files. Both large candidate records were parsed programmatically. Their bindings, counts and hashes match `preparation-verification01.json`.

| Identity | Baseline | Candidate |
|---|---|---|
| Preparation archive SHA256 | `95e2d1b87193af6522104bca89aa55b516c7d3aba84e4a7f7f7150fa568ebd9b` | `83627d222ab02cc383f27472a879077e50ea7532dbdba0180a6edf7167ccee6f` |
| Archive bytes | 1045449 | 1045207 |
| Manifest SHA256 | `98dcb735cf3c6229628c33cd0fe67b291a72995bb340b3d0a01c2cb711b61f8a` | `c3d059216645c63a7b3820094534563cf4027498ff9c160e0082214d9b9ae7bb` |
| Actual `candidate.json` SHA256 | `487a148b69fcec7eff394aa51e7ab042287f502ae8416e7e321d716c1a68296b` | `07eb232409e4101fe5de65e262fdac89f18e84209c10dc0a9eaf09af2958fc64` |
| File / callback / link bindings | 7884 / 7761 / 10 | 7885 / 7762 / 10 |
| Prepared runner SHA256 | `fc23abd0f8e1fdb48c3eec6776f7a3e96b3abb7e213836f7e24ba97ac9db9f6c` | `ed39af06ead1dcd6d46e1120905ece7ea000c0b04a4cbce9bb265f927a04a919` |
| Prepared phase gate SHA256 | `f4793677bd2249779c5d2407d2bfd4d895e1868ee9c4ab37787e5a579ca2c921` | `a354c5fab691cd3d472efa4001219ed0b5302466cfb0bb79112c098d0399b058` |

The prepared SPEC matches the root/phase copies, SHA256 `ea2c9c4e8427d337a8ccf38b57c983522682fd860eeb257f07ffec39a40c93ed`. The parent preparation-verification receipt hashes to `cb222ac6460c007f6b55e16eee83a6f91895fe8852167ef1026a0cfca54bb0cc`.

Prepared query/helper/runner/authority/SPEC/gate/prepare exports match their authoring copies. Runtime file bindings match the exported query, helper, runner, authority, SPEC, delta, top SDC and phase gate; copied gate/dispatcher/top-SDC hashes also match, as does B's added helper. Callback inventories are exactly the file inventories minus `.qpf`, `.rpt`, `.log` and `.summary` suffixes. All prepared Python exports parse with Python 3.9 AST syntax.

Both records retain `approved=false`, `ready_for_build=false`, target `ia840f`, part `AGFB027R25A2E2V`, original `work_ia840f_fim_14` database origin, separate phase roots and the recorded `/usr/bin/python3.9` runner context. Bound launcher/native STA hashes agree with both retained installed API-help receipts. This is verification of captured remote preparation evidence, **not** a new live observation of remote files, tools or hardware.

The four saved runner/dispatcher missing-authorization checks each returned 1. Their exact receipts report initial copy equality, unchanged originals, `authorization_issued=false` and `vendor_launched=false`, with pane `%42` and the supplied preparation timestamps. No real authorization or native A/B result was obtained by this review.

## 3. Preserved-copy and clock-only comparison — verified

Complete normalized old→new inventories reproduce exactly **eight changed bindings per phase**, no added/removed entries and equivalent links, agreeing with `predecessor-delta-verification01.json`. The changes are authority/SPEC/runner/gate, copied gate/dispatcher, and the two recorded metadata path relocations. Query/helper/top-SDC exports match the rejected predecessor per phase; S1 explains why query equality cannot be credited as complete retargeting.

Complete normalized A→B inventories reproduce exactly **ten changed bindings, one helper addition, no removals and equivalent links**. The fitted `ofs_top.qdb` is equal, SHA256 `2aa11f9cb027f377447ff77c8088e78aa2ee5b1744a1202444dbcfb6a978acd3`; all 78 non-top `.sdc` bindings and all inventoried PCIe-subtree bindings are equal. Non-constraint differences are the phase-specific package/gate records and the two declared metadata path relocations.

Both phases bind the same original Work14/SOURCE/PIM preservation receipt digest, also equal to the predecessor: `ba54fad92731357ffa65f163bdb402f133d3841f5e90660df752ac98f18394af`. Preparation source verifies copied inventories before overlays and rechecks originals afterward. No new preservation or hardware observation is inferred from that shared historical digest.

The actual SDC hashes are:

- A: `8255b34c200a46178174b9788bdc9231072ae829f57c34703cc63dd28ab66c3d`.
- B: `eb65af7949f130fffb011c6b5a96a5bc46bde5df7d57d99091e03730a441ff9a`.
- Shared clock helper: `8486a48acbe4f024beecefb95d09eeab69ce0331d3f16d4a1f9c0591cdb117f2`.

Decoding `constraint-delta.json` and performing its single old→new block substitution exactly reproduces B. Removing the respective blocks leaves **byte-identical remaining SDC**, including all asynchronous groups, the four multicycle statements and other exceptions. The new block only sources the bound helper and invokes `::ia840f_clock_repair::apply` at the original generated-clock location.

The helper retains the observed modern divider `inclk`/`clock_div2`, existing master `sys_pll|iopll_0_clk_100m` and exactly named `pcie_wrapper|pcie_ss.top|host_pcie.pcie_ss|pcie_ss|avmm_clock0` with `-divide_by 2`. It checks object cardinalities, directions/type, physical PLL fanin and incoming propagated master association; rejects pre-existing requested/output clocks; and verifies helper execution, generated-clock identity and output association. No new base clock, nominal period/phase, PLL change, blind `-add`, overwrite or rename-to-evade-groups was found.

The accepted source hypothesis in `../DISPOSITION.md` and `../exception-disposition-research.md`, and accepted completed E2 result at `../../fim-build-14/pcie-postfit-02/RESULT-ACCEPTANCE.md`, remain prerequisites already resolved for experimental acquisition. The selected prerelease authorization and historical Query04 stop are not reopened.

## 4. Q1 lifetime correction — checked, not a QUALITY waiver

The actual new runners have identical implementation after exact phase-path/module-prefix normalization. AST comparison against the exact rejected prepared runners verifies that `inventory`, `live_group`, `wait_bounded` and legacy `main` are retained unchanged after mechanical retarget. The sole CLI entry calls **`main_supervised`**, not legacy `main` or `wait_bounded`.

The new path implements the requested correction:

- `peek_owned_exit` uses Linux `waitid(P_PID, WEXITED|WNOHANG|WNOWAIT)`; the required APIs and default SIGCHLD disposition are checked before spawning.
- `supervise_native:150–178` reserves metadata before launch and immediately protects successful spawn through metadata dump/flush/close and waiting with a `BaseException` handler and `finally` cleanup.
- `:160–239` treats normal zero/nonzero leader exit with live descendants as failure, resolves the owned group on all protected completion paths, and retains the unreaped leader through possible TERM/KILL signals and bounded drain checks. No group signaling follows the reap point.
- Two quiescent observations plus observed leader exit are required before `termination_confirmed=true`; unknown inspection/reap status remains explicit non-success. Raw native status is separate from the effective abort/failure status.
- `main_supervised:273–300` persists available raw supervision status before normal preservation/report postflight and keeps `timing_accepted=false`. Failed storage does not authorize fabricated receipts or artifact reuse.

The existing host/UID/owned-tmux, exact source/link/executable/argv/cwd/live-ancestry checks and exclusive claims remain. Limits remain 80 GB available-memory headroom, 64 GiB address space, 128 MiB per file, 1800 seconds and 1 GiB report total. This is ordinary owned-process/source-bound supervision, not an OS sandbox or a guarantee against SIGKILL, kernel failure or deliberate process-group escape.

B's actual gate additionally requires baseline `termination_confirmed` **literally true**, native status 0, effective status 0, exactly three literal-true preservation results and one completion marker. Its exact `exact-offline-constraint-candidate02` authorization binds five baseline SHA256 values: `native-result.json`, `execution-status.json`, `preservation-after.json`, `query.log`, `query.claim`. Parent inspection before B issuance remains mandatory; pre-issuing both phases is not approved.

### Actual permitted inert replay

Only the three expressly allowed fixture entry points were replayed with `python3 -B` from `/home/joe`. Every replay exited 0, had empty stderr and programmatically reconciled its declared count with passing rows:

| Fixture | Actual result |
|---|---|
| `test-supervision.py` | 26/26: four predecessor-defect reproductions plus 22 successor checks, 11 per phase |
| `test-guard.py` | 17/17 |
| `test-candidate-gate.py` | 5/5 |

Supervision replay covered clean 0/7, post-spawn metadata write failure, normal 0/7 leader exit with a TERM-resistant writer, wall/output caps, resistant watchdog descendants, wait failure, recoverable inspection failure and persistent unconfirmable inspection. All successor cases had no live fixture writer at return, checked preservation/export hashes, and rejected a spent rerun without changed bytes or another spawn. Normal leader 0/7 with descendants retained raw 0/7 but returned effective 124. Persistent inspection failure retained `termination_confirmed=false` and effective 124. Fixture cleanup uses PIDFD identity, not a reaped PGID.

The gate replay admitted only the confirmed-success dummy baseline and rejected missing/false/nonboolean termination or failed effective status. These dummy temporary records are not real authorizations. The tested runner/query/helper/gate hashes match the actual prepared exports; saved test-receipt hashes also match `authoring-verification02.json`. As detailed in S1, none of these tests covers the actual query's prepared-root routing.

## 5. Reporting and later result acceptance — retained contract

Apart from S1 preventing entry, the unchanged query contains the intended normal `read_sdc` order, helper-execution check, clock definitions/group memberships, full discovered divider-load and 32 selected FIFO receiver associations through `get_clocks -of_objects`, structural adjacency for baseline unclocked connectivity, and bounded timed/cut/data-delay endpoint pairs in both directions. It requests global transfer matrices/exception summaries, scoped exceptions including clock groups, per-corner domain summaries and explicitly sampled worst paths, net delay, skew, UCP and MPW evidence.

The finite limits remain 256 clocks, 4096 loads, 4096 adjacent nodes per load, 50000 emitted adjacency records, request 20001 endpoint pairs with rejection at that count, and at most 16 corners. Installed help supports propagated-clock lookup and full net-delay report intent. **Per-exception `-npaths` completeness must be inspected in actual results:** `report_exceptions` returns operation status, not a completeness count. MPW detail uses `-nworst 20`, not an uncapped per-node listing. `check_timing` is not full DRC/Design Assistant sign-off.

Later result review must positively reconcile actual loaded source filenames and identities; no hermetic scratch-only-read claim is valid. It must establish the generated ratio/propagation, all eight formerly invalid FIFO assignments as present numerical Required/Actual/Slack records using actual periods, all changed transfers/exceptions including global changes outside C's load set, and every report cap. Missing, capped, nonnumerical or unexplained changed-global evidence blocks promotion. Cut-path hypothetical timing and dominated multicycles receive no active-timing or safety credit. Negative numerical results remain evidence, not waivers; rc0/COMPLETE is never timing, coverage or hardware acceptance.

Existing High-rule findings, EMIF1 −0.004 ns hold, full DRC/CDC, maintained-source promotion, any constrained fit, matching persona, host recovery and all device/data-path/AHLS/DDR/sustained/QSPI-boot gates remain open.

## 6. Scope and disposition

All activity was local read/hash/parse/static comparison plus the three allowed inert fixtures. No SSH/remote, vendor/native query, real preparation/issuer/authorization, hardware or git operation occurred. Fixture temporaries stayed in the designated scratch directory. A before/after hash snapshot verified every existing experiment02 file unchanged. The only durable file authored is this report.

The predecessor SPEC and QUALITY report hashes were independently reverified as `89b9554fefb0cb555fa3e875fefbb703e3c468696a5b5bb845c758bf70d3f4f7` and `4b1b771d5743464f2383df47f319009394fb17f61d93b1b19aab4abd86d7bd8f`. Neither old review authorizes new bytes. One reviewer-only AST assertion initially omitted the harmless `repr` builtin from its expected call list; it was corrected in memory to check local function calls and passed, without changing any package/test/evidence file.

**Blocking SPEC gaps: S1 only.** The Q1 correction and unchanged scientific/reporting scope may be reused as verified reasoning, but the stale query root must be corrected and rebound before this can receive SPEC PASS. A future issuer is not implicitly reviewed. No goal or tracked qualification task is closed.

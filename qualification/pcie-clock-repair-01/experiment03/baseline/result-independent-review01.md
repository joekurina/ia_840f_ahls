# Independent actual-result review — experiment03 baseline

## Verdict: ACCEPT AS FAILED / INCOMPLETE EVIDENCE ONLY

The exact captured baseline run failed natively with **raw rc3 / effective rc3**, with **literal-true termination confirmation and unchanged Work14/SOURCE/PIM preservation receipts**. The result archive is intact. The query stopped at its clock-load cardinality assertion before recording the count or performing the downstream analysis. This is an evidence-acquisition failure, **not a demonstrated failure of the proposed clock repair** and not timing acceptance.

**Candidate issuance remains prohibited by the failed baseline.** The captured status records candidate authorization absent; no candidate result or numerical A/B comparison exists in this evidence. Preserve the consumed baseline and the unissued candidate. This review grants no authority for another run, source promotion, fit, hardware operation or task closure.

## 1. Review boundary and exact package/issuance binding

Local read/hash/parse/static inspection only. No issuer, runner, gate, preparation entrypoint or tests were executed; no remote, vendor, hardware or git operation was performed. The only authored file is this report. Parent summaries may change independently; the reviewed frozen artifacts were checked unchanged before publication.

Read `../ACCEPTANCE.md`, parent consumption, both independent package reviews, the separately inspected actual issuer and its delta/inspection/dispatch receipts, the prepared runtime sources, captured status, full result archive and exports, and the parent result draft/verification. Independently decoded **all 13 prepared exports per phase**, matching exact manifest file sets, sizes, hashes and readback bytes. These are package identity checks, not repeated fixtures or new remote observations.

Verified SHA256 identities:

| Artifact | SHA256 |
|---|---|
| `../spec-review01.md` | `4a5f9512451e3863f2240cf567edd9e40df00bff288ab985a61f3dc891f900a8` |
| `../quality-review01.md` | `e9c42ba465b7af2c69c8f131a031646ea002be2e47f7a594d32f3351d6875363` |
| `../parent-consumption01.json` | `526890ac2651c6ed9a086149956c2d3c586fe54fe653858971ac6b3cad673972` |
| `../ACCEPTANCE.md` | `d571b6e9376b85dfcce06fcf2777322230c516c36762df8b4976b8909f897c96` |
| `prepared-manifest01.json` | `f40688e915bb01f07759aa9b23aa6a7e216fc65c3905f8e7d99efbf702479b08` |
| `prepared-readback01/candidate.json` | `9d63cb5e78488b60df449514e2b2967d1694fa7a872fefbfa8d78b951beb3719` |
| `issue-launch01.py` | `814e95d188e04c826ca9ffe07ef3cdd6c77dd3d6cc17f0c98e8fa972e11a4bfd` |
| `status01.json` | `725a4208520ba038f7d6183e053b4854ef3277912063cdfc4bd5bd1d624c2d70` |

Package approval does not implicitly cover a future issuer. Here the actual issuer hash equals the separately recorded inspection and dispatch hashes. Its five fixed review identities equal the current local artifacts and the actual captured issuance receipt. Source inspection confirms baseline-only permission, rejection of consumed artifacts and premature candidate issuance, exact prepared/file/link and preservation checks before issuance, exclusive writes, and exec of the reviewed runner. The prepared records retain `approved=false` and `ready_for_build=false`; only the separate baseline authorization has `approved=true`.

Captured issuance: `2026-09-22T10:21:57.835521+00:00`, pane `%44`, matching dispatch `@44 %44`. It binds the baseline candidate above, the exact runner argv/cwd and permission `exact-offline-constraint-baseline03`. Authorization SHA256 is `1716b6c4cb4fa480c374a130d1d026588d2acbe54dbdf4921ae5999bed051e13`; issuance SHA256 is `bd5c2a229dc3d40c69b8616e609deb0155284b90076170be420d852d558ae2ee`. Authorization/issuance are captured as parsed values plus remote byte hashes in `status01.json`, **not additional raw exports in the eight-file result archive**. Their hashes are reproducible using the inspected issuer's JSON serialization and captured values.

The single-use record/claim chain is consistent with one issued attempt. It must not be reissued or rerun.

## 2. Actual execution, failure propagation and termination

Remote phase root used by the records:

`/home/uwb_student00/ahls/new_BSP/qualification/pcie-clock-repair-01/experiment03/baseline`

- Runner claim: PID **19074**, PPID **19020**, start ticks **3578301**, executable `/usr/bin/python3.9`; argv `python3 -B <phase-root>/run-query.py`; cwd `<phase-root>`. All executable/argv/cwd fields match the prepared record and issuance.
- Native PID **19117**; launcher argv `/opt/altera/26.1.1/quartus/bin/quartus_sta -t <phase-root>/query.tcl`; cwd `<phase-root>/scratch/syn/board/ia840f/syn_top`. Exact argv/cwd match the prepared record. The log identifies Quartus Prime Timing Analyzer **26.1.1 Build 130**, the same PID and query, and successful loading of the final database (`query.log:1–39`). This is STA over the fitted copy, not a new fit despite the project's generic “Compiling PR Base revision” message.
- Recorded native interval: `2026-09-22T10:22:00.801273+00:00` to `2026-09-22T10:22:40.075800+00:00` (**39.274527 seconds**, including runner observation/cleanup).
- Native result: `native_started=true`, `native_rc=3`, `abort_reason=null`, `termination_confirmed=true`, `supervision_errors=[]`, `final_live_pids=[]`. The log's final `CONSTRAINT_SUPERVISION` object agrees exactly. Execution status retains native/effective **3**, `timing_accepted=false`, and precisely `missing/duplicate completion marker` plus `native/query/gate diagnostic`.
- The actual CLI source calls `main_supervised`. Its ordinary owned-process-group exit/drain/reap path supports these receipts; this was not a wall/report-cap abort, supervision exception or unconfirmed termination.
- Independently captured status at `2026-09-22T10:23:28.101122+00:00` records PID19117 absent. Its script hash matches `status-dispatch01.json`, captured through `@45 %45`. Every overlapping status value/hash matches the raw result export.

**Outer-status evidence limit:** parent context and `RESULT.md` report outer rc3 and return to a shell. The supplied local artifacts retain the dispatch command that prints `CLOCK_BASELINE03_OUTER_RC` and execs bash, but no raw captured pane output containing its resulting line. Thus raw/effective rc3 and native termination are independently verified here; outer rc3/shell return remain the parent's observed result, not a separately replayable pane receipt. This does not prevent accepting the captured native failure.

There is no native `CLOCK_BASELINE03_REJECT`, `SOURCE_BOUND_GATE_REJECTION_STOP`, `CONSTRAINT_RUNNER_FAILURE`, Warning125091, or wrong-project-path rejection in the log. Prior native-gate/Q1/S1 problems are not the failure shown by this run; the generic execution-status diagnostic label must not be mistaken for a gate-specific diagnosis.

## 3. Preservation and lossless result integrity

The bound preservation inventory file has SHA256 `ba54fad92731357ffa65f163bdb402f133d3841f5e90660df752ac98f18394af`. The issuer records originals unchanged before launch. The inspected runner compares complete file-hash/symlink-target inventories after termination. Its exported `preservation-after.json` contains **exactly these three keys, each literally true**:

- `/home/uwb_student00/ahls/new_BSP/work_ia840f_fim_14`
- `/home/uwb_student00/ahls/new_BSP/ofs-agx7-pcie-attach` — maintained SOURCE
- `/home/uwb_student00/ahls/new_BSP/ofs-platform-afu-bbb` — PIM

These are accepted captured preservation results under the reviewed inventory procedure, not a new remote rehash, scratch-tree immutability claim or OS-sandbox claim.

Decoded `result01.json.gz` entirely in memory: **24,273 bytes**, SHA256 `4f7374d66e519a6fe41c43d80af9946de455383431507984e604c4ca90462cb1`, exact batch `ia840f_clock_baseline03_result01`. All **eight** embedded exports match their declared bytes/hashes, the exact local readback file set, and `result-manifest01.json` (SHA256 `39676f8ba2fc2d0ab1075af549a341522a0ff5aedb14e83888ec566ef979f4dc`). No extra or missing result export was found.

| Export | Bytes | SHA256 |
|---|---:|---|
| `execution-status.json` | 223 | `0a4fe20017dbae5c5e5f28553b71998bce4ad5c70d791c4b613fb7733d6a5dc3` |
| `native-process.json` | 357 | `7a6a5be36a312349615ce1e3b9dbccf36fc9263228bd553ef68929af970312ba` |
| `native-result.json` | 330 | `3c08c9d82cef9df4e1afaec644e25accbca6631101e9c20b7a890cff14dc2d99` |
| `preservation-after.json` | 195 | `fd8467afa1a4f3f1edad5f0daf727e290f4e08377597b0a5f401a62e57b76750` |
| `query.claim` | 317 | `d66a2014a8f0dd2d151b24e0e2d0d6f01ac52f171afdcd77a542b4be510788d4` |
| `query.log` | 146158 | `d2ed7b2c22e56aeedf18b682f53c088cf38f3093c66f28ac60be59b07e7678dd` |
| `report-manifest.json` | 137 | `8b67030fb8531204ae502460a369c318db903c3a140b7ef41411bae40566b88c` |
| `reports/audit.tcllist` | 25967 | `8e342dee3ca4d13fbe55b5766da37423294636399bda335ae553bb604eec7d0f` |

**The report manifest lists exactly one report: `reports/audit.tcllist`, 25,967 bytes, hash as above. Eight result exports do not mean eight STA reports.** Its file set, size and hash match both archive and local reports directory. The parent's `result-verification01.json` values were independently reproduced. The status log tail is explicitly partial; diagnostic review used the complete 609-line raw log instead.

## 4. Exact failure and partial-evidence limits

`query.log:574` reports Error23035: `CLOCK_REPAIR_REJECT clock load cardinality/cap`. Its stack identifies the assertion in `query.tcl:72`; Error23031 at log line602 then records unsuccessful script evaluation. This is a Tcl query assertion, not an observed native API exception in `get_fanouts`.

The hash-bound query (`b8df8ae59def64392bafb6681791809d7d84fa65451dbd2be4db428df249a8ac`) executes:

1. `one_pin "$D|clock_div2" 0` — exact output-pin cardinality/name/direction/type checks (`clock-repair.tcl:18–25`).
2. `get_fanouts -clock $output`, then `get_collection_size $loads`.
3. Require `load_count > 0 && load_count <= 4096`.
4. Only after that assertion, emit `LOAD_COUNT`.

The run reached the assertion, but **no load count was persisted**. The evidence does not distinguish **zero from greater than4096**. Neither zero fanout nor a safe larger cap is established. Do not infer absent downstream circuitry from a missing enumeration; log lines493–494 separately retain Warning332060 for the unassigned divider and an explicitly named downstream register clocked by it.

The audit is exactly **87 records: BEGIN1, CLOCK80, MEMBERSHIP6**, with no other tags. It starts `BEGIN baseline no_fit no_hardware no_timing_acceptance`. Membership records retain no matching `*avmm_clock0` and do retain the named `sys_pll|iopll_0_clk_100m` master; these are narrow existing-clock observations, not candidate propagation evidence. No `CLOCK_REPAIR_CREATED` appears in the log.

Missing because execution stopped before their code paths: `LOAD_COUNT`, load/adjacency inventories, FIFO source/receiver results, `CORNERS`/per-corner analysis, path sets, global transfers, exception precedence/truncation, numerical Required/Actual/Slack for all eight FIFO assignments, net-delay/skew/MPW/UCP reports and completion. There are **zero** `IA840F_CONSTRAINT_COMPARE_COMPLETE baseline` markers and no audit COMPLETE record. Successful SDC reading and the clock inventory do not satisfy the complete loaded-SDC/timing comparison acceptance requirements. Later caps were not exercised; report size below the resource limit is not analysis completeness.

Warnings independently counted from the full native log:

| Code | Count |
|---|---:|
| 332049 | 133 |
| 332174 | 53 |
| 332054 | 14 |
| 332060 | 1 |
| 22890 | 78 |
| **Total** | **279** |

All 78 Warning22890 entries point to `query.tcl:64`: generated-only properties are requested while inventorying base clocks. Those warnings are separate from the fatal load assertion and do not reveal its missing count. Retain the other warnings; none is waived by this failed-result acceptance.

## 5. Disposition

No integrity, termination or original-preservation contradiction was found in the captured evidence. Accept and retain it as a **failed, incomplete baseline** with the outer-pane receipt qualification above. The scientific comparison remains unavailable, and candidate authorization is absent in the captured status. Failed baseline rc3 and missing completion independently forbid candidate issuance under the accepted gate.

This run neither validates nor disproves the candidate's generated-clock/exception hypothesis. It clears no timing, CDC/DRC or hardware gate; the older Work14 EMIF1 hold −0.004 ns issue, matching persona, backend/recovery, hardware data/boot requirements and other open acceptance items remain open. No new fit, maintained-source promotion or hardware execution is accepted. Diagnosis or a future collector change must remain distinct from this consumed attempt and receive its own required review/binding; this report authors and authorizes no such change.

Before publication, **88 pre-existing frozen files** were rehashed unchanged (excluding the parent's mutable `CURRENT.md`/`RESULT.md` summaries). No tracked task or mission was modified or closed.

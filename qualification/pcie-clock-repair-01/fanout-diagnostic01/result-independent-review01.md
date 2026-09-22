# Independent actual-result review — fanout-diagnostic01

## Verdict

**ACCEPT as preserved evidence of a failed, incomplete native diagnostic only.** The exported bytes are internally consistent with the exact reviewed preparation package and the captured launch/completion chain. Native/raw/effective/outer status is **3**, not success. Two explicit zero forward-fanout observations survive the failure; the planned known-receiver, reverse-fanin, group and named-tile checks did not complete.

This is **not** acceptance of a completed diagnostic, either collector, an A/B comparison, a source/clock repair, timing, hardware or task closure. No evidence gap prevents the narrow failed/incomplete classification. The receipt-level preservation and loaded-file limitations below remain explicit; this review does not turn them into direct remote filesystem measurements.

Scope of this review: local byte reads, SHA256 checks, gzip/base64/JSON parsing, source inspection and raw-log analysis only. No remote access, vendor/help/native invocation, project entrypoint or fixture execution, authorization, hardware access, git operation or rerun. The only authored file is this report. `RESULT.md`, `result-analysis01.json` and `result-verification01.json` were context, not substitutes for the raw evidence checks.

All relative paths below are within `fanout-diagnostic01/`, except the explicitly identified earlier Query02 log.

## 1. Exact evidence and package identity

Independently recomputed the following SHA256 values:

| Artifact | SHA256 |
|---|---|
| `prepared-manifest02.json` | `19c972f6e5e173c3b48e1bef4af73359dec0e695ddecf062daa07762b62e52e3` |
| `preparation02.json.gz` | `8fb8eab7b421c0d9fb5f06f6f7169c598dbf347a38c43ae0988793a81e251f3c` |
| `prepared-readback02/candidate.json` | `39afbfaec768985d9472da0b95c58df676afd0c273d1257a9f40180b9f44a719` |
| `spec-review01.md` | `c36f41c60a61bc642d8d1c1ba7312b442d7dd41b4dc66609bae666ab3a54969c` |
| `quality-review01.md` | `ee30a3a2902a0d0585bc95dd4f057529dfd20dacb8aa4f12d5e06b58a73ee784` |
| `parent-consumption01.json` | `3595a06189f5a3f5358edd41acdc1d102774b8a0511f01ac93f6dc71826f163a` |
| `ACCEPTANCE.md` | `2d7320f41c2c43c6cd5b0b6a33e3bf3545a4e398d0054ed9c3d84cb6f67342cc` |
| `result-manifest01.json` | `9e85e068ea059ea3f506a2036e9f3db9d512c74bd5646abf1fbaebd75cbd4ed0` |
| `result01.json.gz` | `840a2bbd52b448a52c3ccae6ffe9968d09cd0a0a4fb9541044459cdac67bc78f` |
| `completion-pane01.txt` | `ca9569954eccd1acd43b4706769985208702161d35f211dafbc46637d45e12e6` |

Both archives were decompressed and every embedded base64 payload was decoded and compared byte-for-byte with its corresponding readback file. For each file, independently checked the embedded size/hash against actual bytes and the separate manifest; file-name sets also agree. Results:

- Preparation batch `ia840f_clock_fanout01_preparation02`: **14/14** exports verified, no mismatch.
- Result batch `ia840f_clock_fanout01_result01`: **8/8** exports verified, no mismatch; compressed archive is **24,806 bytes**.
- Candidate inventories contain **7,885 files, 7,762 callback files and 10 links**. These are counts of bound entries, not a claim that this local reviewer rehashed the remote trees.
- Exported query, runner, helper, known-receiver manifest and top SDC hashes also match their exact remote-path entries in `candidate.json`.
- Candidate `approved=false`, `ready_for_build=false`, part `AGFB027R25A2E2V`, permission `exact-offline-fanout-diagnostic01`. The separate issuance receipt is not a mutation of that candidate.

All result exports are accounted for:

| Readback file | Bytes | SHA256 |
|---|---:|---|
| `query.log` | 136800 | `f1a44b052a6cadd56d195010952a254f2fe19f1bdebd85c417ddca195252314a` |
| `native-result.json` | 330 | `bcfa75d07f891663f200fb53849b4595e67224afca49c88d2d16127a0ba30aec` |
| `native-process.json` | 353 | `93b6838217a3e1f2610273db7e9cc2b827dbf76fde3b15d46e775b22d639bea5` |
| `query.claim` | 313 | `e6a470702cf6eb2ea0f1095ba39ea3c8de1137ec0274c22e016c7b2f5c6d905b` |
| `preservation-after.json` | 195 | `fd8467afa1a4f3f1edad5f0daf727e290f4e08377597b0a5f401a62e57b76750` |
| `execution-status.json` | 223 | `0a4fe20017dbae5c5e5f28553b71998bce4ad5c70d791c4b613fb7733d6a5dc3` |
| `report-manifest.json` | 137 | `2e9295c2cd6efd7464af042a0772ea435a64f536bbc5751a03f16f21b8b5ac04` |
| `reports/audit.tcllist` | 28715 | `0678b4defced15fc79b3d48a6d6431b1d543637bc9190c5e360784d5007fdce3` |

The report manifest contains exactly the audit report; its size/hash were checked independently against the actual audit bytes. There is no missing exported report implied by this manifest. Absence of later successful diagnostic records is instead explained by the native failure.

## 2. Launch, termination and preservation

`launch-dispatch01.json` (SHA256 `a3190f7fde94c3e4017dff96b6958f2dd16fb18d9aaf70a538f6df99b0616ccb`, lines 2–12) records dispatch at `2026-09-22T11:27:54.093152+00:00` to `@49 %49`, payload SHA256 `423aaa83240cc3660ef6ce75c5ea982b4ca2533b7879429ddc8b19468c0ea6d5`. This dispatch record is not itself evidence of native success.

`completion-pane01.txt:1` supplies the actual issuance receipt at `2026-09-22T11:28:01.036785+00:00`, pane `%49`, authorization SHA256 `db5a580f5660b8a6e8aad06a2ba277c98157c6e4e69b366a4277177afae1a083`. Its candidate hash and all **five** transported review hashes match the independently hashed local files and `issuer-inspection01.json`'s review payload. `originals_unchanged_before_launch` is literally true. `native_started_at_receipt=false` describes that issuance instant only; it does not contradict the subsequent native run.

The later issuer was **parent-inspected**, not independently reviewed by the package reviewers. This distinction is explicit in `issuer-inspection01.json:19–21` (SHA256 `d3713f132c889bcf586315bfef14770203c90667209e7ccaf098004a08a8270e`). `issue-launch01.py` hashes to `519f50ee7fcd2c4b195f56ab0e224b10ad96f367581382ccf046ac626d3deac8`; source lines 42–55 recheck prepared files, candidate bindings, links and originals, and lines 63–70 issue then exec the reviewed runner. Reading this source does not retroactively create an independent issuer approval or claim that its fixtures were rerun.

The saved claim identifies runner PID **20814**, start ticks `3974610`, executable `/usr/bin/python3.9`; saved executable/argv/cwd agree exactly with the candidate runner context. `native-process.json` identifies PID **20822** and agrees exactly with candidate native launcher argv/cwd:

```text
argv: /opt/altera/26.1.1/quartus/bin/quartus_sta -t /home/uwb_student00/ahls/new_BSP/qualification/pcie-clock-repair-01/fanout-diagnostic01/query.tcl
cwd:  /home/uwb_student00/ahls/new_BSP/qualification/pcie-clock-repair-01/fanout-diagnostic01/scratch/syn/board/ia840f/syn_top
```

`native-result.json:2–11` records interval `2026-09-22T11:28:04.064078+00:00`–`2026-09-22T11:28:43.231430+00:00`, native rc3, `native_started=true`, `abort_reason=null`, `termination_confirmed=true`, `supervision_errors=[]`, `final_live_pids=[]`. The raw supervision record at `query.log:537` agrees. `execution-status.json:2–10` retains effective rc3, the missing/duplicate-completion-marker and native/query/gate-diagnostic errors, and `timing_accepted=false`. Independent log counting resolves the ambiguous marker-error wording to **zero** completion markers, not duplicates. `completion-pane01.txt:2–4` records result/native rc3, outer rc3 and shell return.

Thus the captured terminal state is confirmed failure and drained owned processes, **not** an unresolved runner timeout or unknown native completion. This is an evaluation of saved evidence, not a fresh assertion about the remote host's present process table. The saved native-process JSON records launcher metadata, not a separately exported live `/proc` executable snapshot; runtime identity/ancestry checks are represented by the bound gate source and successful progress beyond its rejection point, not by an independent process trace.

`preservation-after.json:2–4` contains exactly three literal-true entries: original Work14, SOURCE (`ofs-agx7-pcie-attach`) and PIM (`ofs-platform-afu-bbb`). `prepared-readback02/run-query.py:280–287` shows these are whole inventory comparisons against the bound pre-copy preservation inventory, with missing/false entries treated as failure. The issuance receipt separately records the prelaunch original check. **Accept these as recorded preservation results**, not as locally repeated remote hashes. The underlying `preservation.json.gz` is candidate-bound to SHA256 `ba54fad92731357ffa65f163bdb402f133d3841f5e90660df752ac98f18394af`, but its bytes/full before inventory are not among the 14 prepared or 8 result exports. Consequently this local review cannot independently recompute every original before/after entry.

## 3. What the native query actually established

The bound `prepared-readback02/query.tcl` SHA256 is `16ec28ff6ed66b9867338b09d4d12af0c3fa12d5926efd3b85cdc0c47edd0086`. Its main sequence performs ordinary project open, timing-netlist creation, argument-free `read_sdc` and timing-netlist update (lines 72–76). The helper's clock-creation and verification procedures are not called. The original exported `top.sdc` hashes to `8255b34c200a46178174b9788bdc9231072ae829f57c34703cc63dd28ab66c3d`, equal to both hashes in the constraint-delta receipt and the candidate's scratch top-SDC entry. This is baseline observation, not an added-clock experiment.

Let:

```text
D = pcie_wrapper|pcie_ss.top|host_pcie.pcie_ss|pcie_ss|EP_PFTILE_WRAPPER.gen_pciess.u_pciess_p0|u_pciess|gen_sub.u_hipif|u_pciess_clock_divider|clkdiv_inst
O = D|clock_div2
K = D~div_reg
M = sys_pll|iopll_0_clk_100m
```

These symbolic definitions retain the distinction between pin O, synthetic keeper/register K and the different fitter net alias `clock_div2x`.

| Raw audit lines | Accepted observation, limited to this run |
|---|---|
| 1–3 | Diagnostic-only scope; target generated-clock-name count 0; clock inventory count 80, ceiling 256. |
| 4–83 | Exactly 80 `CLOCK` records. Generated-only properties are type-guarded in query lines 34–39. |
| 84–85 | Exact O resolved once, direction input=0/output=1/clock=1; `get_clocks -of_objects` association M; `FANOUT_COUNT pin 0 cap 4096`. |
| 86–90 | Exact K resolved once through each of `get_keepers` and `get_registers`; identities match; keeper association M. |
| 91 | Independent `FANOUT_COUNT keeper 0 cap 4096`. |
| 92–94 | Each set reports complete=1, raw/enumerated/unique=0; pin-only, keeper-only and intersection counts are all 0. These are complete empty enumerations of those two returned collections, not a complete diagnostic. |
| 95–96 | Manifest length 32 was emitted; first `known_receiver` identity count is 0, expected 1. |

The final audit record is exactly:

```text
IDENTITY_COUNT known_receiver {pcie_wrapper|pcie_ss.top|host_pcie.pcie_ss|pcie_ss|EP_PFTILE_WRAPPER.gen_pciess.u_pciess_p0|u_pciess|gen_sub.u_hipif|u_pciess_cplto_if|cplto_fifo_avmm_inst|auto_generated|rs_dgwp|dffpipe5|dffe6a[0]} 0 1
```

`query.log:496–530` records Error **23035**, `CLOCK_REPAIR_REJECT identity count {known_receiver} actual=0 expected=1`, the call `exact get_keepers $cell known_receiver`, and Error **23031** for unsuccessful Tcl evaluation. The inspected source places that call at `query.tcl:123`; the logged file entry is line 171. `exact` emits/flushes the count before the cardinality assertion (query lines 17–25), so this is an explicit native observation, not an inferred zero from an interrupted assertion.

Independently counted **96 audit records**. There are no `KNOWN_RECEIVER`, `KNOWN_FANIN_COUNT`, `KNOWN_FANIN`, `KNOWN_GROUP_COUNT`, `KNOWN_GROUP`, `NAMED_TILE_LOAD`, `MISSING_KNOWN`, `DIAGNOSTIC_STATUS` or `COMPLETE` records. The run stops before even the first known clock-pin lookup and its reverse-fanin query. No `LOAD` records are expected from the two empty forward sets. No known32 or tile membership verdict can be invented from the manifest count alone.

**Interpretation limits:**

- Both forward zeros are measured for this attempt. They do not prove that physical clock loads are absent, do not validate a collector and do not retrospectively fill the earlier experiment03 count that was never logged.
- The M associations do not clear Warning332060. In this same run `query.log:493–494` says K lacks an associated clock assignment and names the P-Tile row-clock register as being clocked by K. This counterevidence must remain visible.
- Independently hashed the earlier `qualification/fim-build-14/pcie-postfit-02/result-readback01/query.log`: `6d934bb5862574a6518fc5803d051757eefcb88a3caaf2f7db44850971460b89`. Parsed 32 distinct `FIFO_GROUP_* INPUT ... FANIN` observations, eight per group, all naming K; all 32 have corresponding `FANIN_COUNT 1` records. The pin-name set equals the known-receiver provenance set. Raw fanin lines run from 515 to 701; the first receiver that fails here has prior reverse-fanin evidence at line 647. This is earlier evidence, not a rerun of the missing current checks, and it prevents a no-loads conclusion.
- The current evidence does **not** decide whether the first lookup failed because of pattern/escaping semantics, cell-versus-keeper representation, or another identity/context issue. No cause or corrective patch is accepted here.

## 4. Loaded SDC path reconciliation

Independently parsed the literal `Reading SDC File:` messages in the raw log: **110 mentions, 38 distinct filenames**. Repetition includes per-instance loads; it is not evidence of 110 distinct SDC files or of a second top-level `read_sdc` call.

For each relative filename, joined it lexically to the exact recorded native cwd and resolved `.`/`..` without changing the logged token. **102 mentions / 33 distinct relative paths** map to exact scratch-file keys in both candidate `files` and `callback_files`, with equal stored digests. No relative filename lacked a bound entry. This includes normal generated PCIe/memory constraints, platform SDCs, board SDCs and `../../../shared_config/top.sdc` (`query.log:258`).

The remaining **8 mentions / 5 distinct paths**, at `query.log:484–491`, are literal absolute **original Work14** QDB `cpt_proxy` filenames, not scratch filenames. All share this prefix:

```text
/home/uwb_student00/ahls/new_BSP/work_ia840f_fim_14/syn/board/ia840f/syn_top/qdb/_compiler/ofs_top/_flat/26.1.1/source/1/.temp/cpt_proxy/
```

Mapping only the original Work14 root to the prepared scratch root locates the following corresponding candidate entries in **both** file maps:

| Exact suffix | Log lines | Corresponding copied-file SHA256 |
|---|---|---|
| `altera_internal_oscillator_atom.sdc` | 484 | `cd774f66e34d34c5a915b7eea9aba463edc025adfb36cd1c09ce3e196c40c2c2` |
| `altera_reset_controller.sdc` | 485–488 | `8834ac8de6421bc2c052c2ac8d7a71127477590111c6daab3bf9c8623501d769` |
| `altera_avalon_st_handshake_clock_crosser.sdc` | 489 | `7a0ef1540845742129401e98536483a5ec3c47580e57c7a591041327f91b2af1` |
| `alt_sld_fab_0_st_dc_fifo_1953_phmrs5y.sdc` | 490 | `3ede7ffdf15991078de85c4d7293e687b65868478f04369166e9da001b5ea73e` |
| `default_jtag.sdc` | 491 | `ba78fae51b3bd15e7b734275976a61bc32e1c7068461717478f4ec760fcd09d8` |

This mapping is an **evidence reconciliation**, not a claim that Quartus actually read the scratch paths instead of the printed original paths. The preparation source records full initial copy equality (`prepare02.py:48–59`), its saved receipt has `copies_initially_hash_identical=true` and `donors_unchanged=true`, and the complete relocation receipt has only two links and two non-SDC text files (`ofs_top.qar_info.json`, `mem_ss.xml`). There are no SDC relocations. The three original trees were subsequently checked unchanged at issuance and after native termination as described above. Those facts support original/copy SDC equivalence at the **recorded inventory and preservation-receipt level**; no loaded filename remains unexplained at that level.

**Precise residual limit:** the original absolute filenames are not themselves literal scratch candidate keys. Their equality relies on copy/preservation receipts; the complete original preservation inventory and original/copy proxy file bytes are not exported in this package. Native logging gives filenames, not per-open byte hashes or a file-access trace. Therefore this local review cannot independently reconstruct original proxy hashes, prove which storage object the QDB-backed loader opened, or establish absence of all unlogged dependencies or transient writes. It also does not claim every accepted constraint applied semantically: warnings show ignored constraints. These limits do not undermine the raw failed-query evidence, but must not be promoted into source isolation, a fully remeasured SDC closure, or future timing/A-B acceptance. No opaque QDB edit is warranted by this review.

## 5. Diagnostics, bounds and retained gates

Independent raw-log warning count: **201**, comprising Warning332049 **133**, Warning332174 **53**, Warning332054 **14**, Warning332060 **1**; Warning22890 **0**. The zero generated-property-warning count is consistent with the query's generated-only guard, not a timing pass or general warning suppression. Native footer (`query.log:531–535`) records two errors, peak **virtual** memory **7032 megabytes**, elapsed **00:00:37**, PID20822. These are vendor-reported metrics, not independent resident-memory measurements.

Both measured forward counts are below the unchanged **4096-per-set** enumeration ceiling; clock inventory is below 256. No cap-exceeded observation or supervision abort is present. The 4096 cap bounds emitted/enumerated output, not native graph-traversal cost. The sole report's measured size is within the runner's report cap. Source-bound checks and process supervision are not an OS sandbox. No fit or repaired-constraint timing comparison was performed by this query.

Disposition:

1. Retain the exact failed result and the useful partial observations; the one-use attempt is spent. **Do not reissue or rerun it.**
2. Keep the previously accepted executable package distinct from this failed native outcome. Package approval does not accept a collector or repair.
3. Keep experiment03 candidate unissued/blocked; nothing in this review authorizes it, a successor, a constraint change or maintained-source integration.
4. Any eventual collector/repair acceptance still requires separately reviewed native evidence resolving the forward/reverse/known-load discrepancies and the original full comparison/qualification gates. This narrow failure review does not require inventing a full A/B timing result, nor waive that future requirement.
5. Timing, CDC/DRC, persona/backend, memory/hardware validation and independent recovery requirements remain unqualified and unchanged. No hardware, reset, reconfiguration or mission/task closure follows from this report.

# Independent actual-result review — fanout-diagnostic02

## Verdict

**ACCEPT strictly as preserved failed/incomplete native evidence. No blocking evidence gap for that narrow disposition.** Native/effective/outer return codes are **3/3/3**. The diagnostic did not complete; useful preceding observations do not change that outcome. The one-use attempt is **SPENT and must not be reissued or rerun**. This review grants no collector, clock-repair, A/B, timing, hardware or task acceptance and authorizes no successor.

Scope: local reads, hashes, strict gzip/base64/JSON decoding, non-evaluating Tcl-list parsing and source/log inspection only. No preparer, runner, gate or issuer entry; no fixtures, remote access, vendor/help invocation, hardware, git or authorization operation. Only this report is authored. Parent summaries were cross-checks, not substitutes for raw results.

Path convention: `G` is this directory; `D=G/prepared-readback01`; `X=G/result-readback01`; `F=../fanout-diagnostic01`. Citations use original 1-based lines. `audit:L` means `X/reports/audit.tcllist:L`, `log:L` means `X/query.log:L`. Compressed JSON inventories are cited by exact decoded root/key and whole-file digest rather than fictitious text lines.

## 1. Exact package, acceptance chain and result transport

Independently decompressed and parsed both archives, rejected duplicate JSON keys, strictly decoded every base64 payload, and compared exact file-name sets, lengths, SHA256 values and bytes against each separate manifest and readback directory:

- Preparation batch `ia840f_clock_fanout02_preparation01`: **15/15 exports**, archive **1,433,796 bytes**.
- Result batch `ia840f_clock_fanout02_result01`: **8/8 exports**, archive **45,354 bytes**.
- `X/report-manifest.json:2–5` contains exactly **one report**, the audit; it matches both the result manifest and actual bytes. No report is missing from that declared set.
- All **eight** corresponding authoring files equal their prepared exports. Ten candidate-bound root exports, the copied gate/dispatcher and scratch top SDC match the actual candidate bindings. Other preparation exports remain manifest-bound, not invented candidate bindings.
- Recounted **7,885 files / 7,762 callback files / 10 links**. The callback map is exactly the file map with `.qpf`, `.rpt`, `.log`, `.summary` suffixes excluded. These are saved binding counts, not local remeasurement of remote files. Candidate part is `AGFB027R25A2E2V`, permission `exact-offline-fanout-diagnostic02`, `approved=false`, `ready_for_build=false`. (`D/candidate.json:2–7,7772–7774,15674–15692`.)

Recomputed bindings:

| Artifact relative to G | SHA256 |
|---|---|
| `preparation01.json.gz` | `d2541de0791d6c5da4f017279ea74ae9b3cb0be32629900a5be8112018ef05cc` |
| `prepared-manifest01.json` | `69db4cf4a1b7c343ae9f607c9273a08473e1ed2cfcaf88c372c57872b767461f` |
| `prepared-readback01/candidate.json` | `a2a1ac74a55d76c5786be5c75517a2860bd53fe4ffc3e0f18720824ac6c77270` |
| `spec-review01.md` | `94ef36a0a39a9c09fef580f2250275a9074f63dfa34da615624c785f0450d5d7` |
| `quality-review01.md` | `0bc8ebc3f463f189c3f94af0ebef69b7dd5e77ba5f1d4e668567b7a7c21b45ba` |
| `parent-consumption01.json` | `6793e070867b255995a9ab4d92e2def7b647975f4bdaa75d8ec257e74979a972` |
| `ACCEPTANCE.md` | `caf06f8357c96f82e20d832c089a708549f4da7831ffc7c6809ddff9517c090f` |
| `issue-launch01.py` | `265a1ded4dbc97bcf8595ced5864b113225440d2c1fcb13629311ffc928bfea6` |
| `issuer-delta01.diff` | `65d47e81342405feaee3e8ab1a955770122e979190fc6cb83d94e923881f5209` |
| `result01.json.gz` | `06bad8b420d448856c9983174e21340c7ea7080a894ca7fa631311b995234abf` |
| `result-manifest01.json` | `5642f236497754de6b24565709e05721c43908d73aa903325ebb4aea7a883766` |

Every binding in both parent consumption records, all five issuance-review bindings, and the candidate digest agree with local bytes. Independently reconstructed the **40-file prepared-package inventory**, yielding `666db7de22bff39b971669d528bd6444107fd12c5edccc4dccf55c2e9dca762a`, identical to the consumed package. Package SPEC/QUALITY approval and their reported 63-case fixture replays remain historical **package** evidence, not proof of native behavior; no fixtures were replayed here. (`parent-consumption01.json:8–33`; `parent-spec-consumption01.json`; `ACCEPTANCE.md:3–26`; `spec-review01.md:5–9,99–136`; `quality-review01.md:114–147`.)

All result exports:

| File relative to X | Bytes | SHA256 |
|---|---:|---|
| `execution-status.json` | 223 | `0a4fe20017dbae5c5e5f28553b71998bce4ad5c70d791c4b613fb7733d6a5dc3` |
| `native-process.json` | 353 | `219297f67d3122a58749a62016e45f28119692d5689ad6178a1e6adfbe6edcef` |
| `native-result.json` | 330 | `9e3b6f26c4416a37828ceb6ce8f1fa3bb8c5304bc8553185cce8608807056477` |
| `preservation-after.json` | 195 | `fd8467afa1a4f3f1edad5f0daf727e290f4e08377597b0a5f401a62e57b76750` |
| `query.claim` | 313 | `91dad37146187071687edf94098a00ec5bd37996f6ed9c191b98d3f78dd8c753` |
| `query.log` | 136376 | `e479371884622dbac60844b9280ac94ab82991d649e5be2132d2bf3aee6fd484` |
| `report-manifest.json` | 138 | `837988223a24e9b9e87b366340aac98acbb0ca7cb28872e61f9c5a3d28363f97` |
| `reports/audit.tcllist` | 491967 | `c85cdb0d21ac800a732c482f7e5f8e1a4d7f80c67de8cce1850340e600bac285` |

The above independently verifies `result-verification01.json:3–17`; its pending-review field is retained historical state, not a result-success flag. `RESULT.md:3–32` is supported as failed/incomplete evidence with the limits below.

## 2. Issuance, actual invocation and captured terminal state

The later issuer was **separately inspected by the parent, not independently approved by the package reviewers**. Its digest and delta match `issuer-inspection01.json:3–23` and `launch-dispatch01.json:2–12`; reading them here does not retroactively grant independent issuer approval. Source orders exact prepared/candidate/original checks before exclusive authorization publication and then `exec` of the unchanged runner (`issue-launch01.py:42–70`).

`completion-pane01.txt:1` contains the actual issuance receipt at `2026-09-22T12:38:44.492097+00:00`, pane `%51`; dispatch identifies window `@51`. Receipt authorization SHA256 is `46455210c7ccc8ed369a3c4ddb29b36a0d02610a59ac770ec4ba605335513fd3`. Candidate and all five review digests were independently matched. `originals_unchanged_before_launch` is literally true. **`native_started_at_receipt=false` describes issuance time only**, not the later result. The authorization file itself is not one of the eight result exports; this is receipt evidence, not a fresh read of that remote file.

`X/query.claim:1` records runner PID **21649**, PPID **21623**, start ticks `4398955`, executable `/usr/bin/python3.9`. Its executable/argv/cwd equal the candidate runner context. `X/native-process.json:1` records native PID **21690**, exact candidate launcher argv/cwd:

```text
argv: /opt/altera/26.1.1/quartus/bin/quartus_sta -t /home/uwb_student00/ahls/new_BSP/qualification/pcie-clock-repair-01/fanout-diagnostic02/query.tcl
cwd:  /home/uwb_student00/ahls/new_BSP/qualification/pcie-clock-repair-01/fanout-diagnostic02/scratch/syn/board/ia840f/syn_top
```

The native log confirms Quartus Pro **26.1.1 Build 130**, PID21690, this script, scratch INI and successful loading of the final fitted database (`log:2–3,18–21,34–39`). The project-script text “Compiling PR Base revision...” at `log:32` does **not** establish a new compile/refit: the recorded command is this offline STA query.

`X/native-result.json:2–11` records one invocation from `2026-09-22T12:38:47.499485+00:00` to `2026-09-22T12:39:26.666361+00:00`: native rc3, `native_started=true`, `abort_reason=null`, `termination_confirmed=true`, `final_live_pids=[]`, `supervision_errors=[]`, `hardware_access=false`. The final `CONSTRAINT_SUPERVISION` JSON at `log:527` agrees field-for-field. `X/execution-status.json:2–10` retains effective rc3, `timing_accepted=false`, and both completion-marker and native-diagnostic errors. Independent counting resolves the generic “missing/duplicate” error to **zero**, not duplicate, `IA840F_FANOUT_CONTRAST_COMPLETE` markers. `completion-pane01.txt:2–4` matches the result archive digest, reports native/effective/outer3 and shows shell return.

This is captured confirmed native failure with drained owned processes, **not an unresolved timeout**. Native-process JSON is launcher metadata, not an exported live `/proc` executable/ancestry trace. Source-bound runtime identity checks and these saved terminal receipts are not a fresh assertion about the workstation's present processes, all possible escaped descendants, or OS-enforced containment.

## 3. Exact failure and observation boundary

At `log:496–520`, Error **23035** is:

```text
Tcl error: can't set "pins": variable is array
while executing "set pins [get_cell_info -pins $cell]"
(procedure "::ia840f_fanout_contrast::main" line 82)
(file ".../fanout-diagnostic02/query.tcl" line 198)
```

The assignment is `D/query.tcl:159`; the top-level call is line198. Error **23031** records unsuccessful script evaluation. The failure occurs after group0's complete eight-name set and the first `CELL` record, before a pin count/set is emitted (`audit:133–135`; `D/query.tcl:148–175`). The first actually visited physical cell ends in **`rs_dgwp|dffpipe5|dffe7a[2]`**, type `tennm_ff`. This is distinct from the manifest's first-name selector test ending in **`dffe6a[0]`**.

**This is an assignment collision, not evidence that the pin API is unsupported or itself failed.** No returned pin collection was audited, so its cardinality, contents and usability are unestablished. The query already has a dedicated namespace and procedure (`D/query.tcl:6–14,73–74`). The trace does not establish where, when or in which variable scope the array originated. Do not assert a global-only cause, claim that procedure scoping fixed it, or mutate/unset vendor arrays on this evidence. The prior package review's expectation about scope isolation was not a native guarantee (`quality-review01.md:68`).

The entire audit has **135 valid Tcl-list records**. There is no `pins:*`, `reverse:*` or `buried:*` COUNT/SET; no `CLOCK_INPUT`, `CLOCK_INPUT_COUNT`, `CELL_REGISTER_MAP`, `REGISTER`, `VISITED_COUNT`, `DIAGNOSTIC_STATUS` or `COMPLETE`. No later group1–3 record exists. There is also no explicit `INCOMPLETE` row: this uncaught native exception interrupts before the final diagnostic status, and the failed native/status/marker evidence establishes incompleteness. Absence of a diagnostic row is not a successful empty observation.

## 4. Independently verified partial observations

Parsed **every row and nested list using the local Tcl library's `Tcl_SplitList`**, without creating/evaluating a Tcl script or sourcing project code. Whitespace splitting was not used for Tcl data. Checked all **17 COUNT/SET pairs** for adjacent labels, exact enumeration length, uniqueness and their actual caps; recomputed all three full set relations, not just their counts. Checked the six selector inputs/results, named-tile identity/memberships, all80 clock rows and the complete eight-name physical group against the non-evaluated 32-row saved manifest. Relevant fields in `partial-observations01.json:2–108` agree with the independently parsed evidence.

Exact symbolic identities (`D/clock-repair.tcl:3–6`; `D/query.tcl:86–96,119`):

```text
H = pcie_wrapper|pcie_ss.top|host_pcie.pcie_ss|pcie_ss
D = H|EP_PFTILE_WRAPPER.gen_pciess.u_pciess_p0|u_pciess|gen_sub.u_hipif|u_pciess_clock_divider|clkdiv_inst
O = D|clock_div2
K = D~div_reg
M = sys_pll|iopll_0_clk_100m
C = H|avmm_clock0
T = H|gen_ptile.u_ptile|intel_pcie_ptile_ast_qhip|inst|inst|maib_and_tile|avmm2_3~maib_ss_lib/x0/u5_2/pld_avmm2_clk_rowclk.reg
```

O and K are not the fitter net alias `clock_div2x`.

| Observation | Independently supported result | Raw evidence |
|---|---|---|
| Baseline C | Exact named generated clock count0 | `audit:2` |
| Clock inventory | 80 unique names, cap256: 26 base and54 generated; base rows have `not_applicable`, generated rows have five-element generated-property lists | `audit:3–83`; `D/query.tcl:60–71` |
| Roots | K resolves once with its exact name through both keepers and registers; O passes the exact one-pin name/cardinality/direction/clock-pin guard before ROOT output; each root's driving-clock collection is exactly M | `audit:84–93`; `D/query.tcl:92–96`; `D/clock-repair.tcl:18–25` |
| Named tile | One exact T; member of both default sets, neither clock-filtered set; its audited driving-clock collection is empty (count0/cap256) | `audit:109–113` |
| Selector matrix | For first manifest name ending `rs_dgwp\|dffpipe5\|dffe6a[0]`, raw `get_cells`, `get_keepers`, `get_registers` each return exactly that one name; each transformed `[[]` selector returns0, with cap32 | `audit:115–132`; `D/query.tcl:127–135` |
| Physical group0 | Exactly eight unique saved expected names, cap128; one `CELL` type `tennm_ff`, then interruption | `audit:133–135`; `D/known-receivers.tcl:2–35`; `D/query.tcl:140–159` |

### Four forward calls and full relations

| Exact query on validated collection | Raw count | Enumerated / unique | Cap | Audit lines |
|---|---:|---:|---:|---|
| `get_fanouts -clock O` | 0 | 0 / 0 | 4096 | 94,98–99 |
| `get_fanouts O` | 459 | 459 / 459 | 4096 | 95,100–101 |
| `get_fanouts -clock K` | 0 | 0 / 0 | 4096 | 96,102–103 |
| `get_fanouts K` | 459 | 459 / 459 | 4096 | 97,104–105 |

At `audit:106–108`, recomputation of every name in the emitted relation fields gives:

- pin-clock versus pin-default: a-only0, b-only459, intersection0;
- keeper-clock versus keeper-default: a-only0, b-only459, intersection0;
- pin-default versus keeper-default: a-only0, b-only0, intersection459 — **the two complete returned default name sets are exactly equal**.

As an additional **name-only** check, all32 saved physical-name strings and T occur in each default set; **426 other distinct strings** remain. This is derived from the complete sets (`audit:101,105`) and `D/known-receivers.tcl`, not a completed32-cell mapping result. The remaining names have not been established as clock-only loads, ports/register classes or the complete affected domain.

Scientific limits:

1. The clock-filtered zeros and default459 results are measured same-root filter contrasts in this run, not proof of absent physical clock loads, a validated clock-only collector, or equality to fitter **Fan-Out355**. Different native edge filters/representations cannot be equated by a count.
2. M is a **driving association**, not proof of a generated-clock definition at O/K. `log:493–494` simultaneously says K lacks an associated clock assignment and that T is clocked by K. Preserve this counterevidence rather than treating the ROOT association as timing closure. T's empty association is also limited to this measured query/context.
3. Raw-selector success and transformed-selector zero are native evidence for this one indexed name under this loaded design. They do not establish a universal escaping policy, a cause for F's earlier lookup failure, or correct mappings for all receivers. No global matcher mode was changed.
4. Only group0's names and one cell type were observed. No current pin/reverse/buried mapping completed, no single-register-mapping flag was reached, and the known32/T checks do not establish exhaustive domain coverage. Historical reverse-fanin evidence is not replayed or substituted for the missing current checks.
5. No cap was exceeded in retained collections. The4096 forward,256 clock,32 selector and128 physical-group caps limit enumeration, not pre-return native traversal. Missing later counts remain missing, not zero.

## 5. Full diagnostics, not just the terminal Tcl exception

Scanned all **527 log lines**. There are **two numbered native errors**, 23035 and23031, and **201 warnings**:

| Warning | Count | Meaning and current log evidence |
|---|---:|---|
| 332049 | 133 | Ignored constraints, including clocks, false/multicycle paths, delay/skew and I/O constraints; `log:114–481` |
| 332174 | 53 | Ignored filters/unmatched objects; `log:224–478` |
| 332054 | 14 | Clock-group assignments accepted with problems; `log:269–286,374,376` |
| 332060 | 1 | K determined to be a clock without an associated clock assignment; `log:493–494` |

The entire201-warning sequence equals F's saved sequence after only the attempt-root string substitution. Warning22890 count is0. No additional Fatal, Critical Warning, Internal Error, gate rejection,125091, Python traceback or cap-exceeded record was found. This does not erase the existing201 warnings or imply constraints all applied.

In particular, `log:262–268` explicitly retains unmatched original `u_pciess_p0` divider pin patterns and ignored `create_generated_clock` source/target collections. `log:260` also reports the ignored duplicate SYS_REFCLK assignment. Existing clock-group/multicycle warnings remain. These unchanged-SDC observations are not a repaired constraint set or A/B numerical timing/exception-coverage result.

The vendor footer reports **2 errors /201 warnings**, peak **virtual** memory **7014 megabytes**, elapsed **00:00:37**, PID21690 (`log:521–526`). The runner interval is **39.166876 seconds**; these are different measurements, not a contradiction. No abort/resource-cap failure is recorded; the sole491,967-byte report is under the bound1GiB total-report limit. These saved metrics are not fresh RAM measurements. Inherited wall1800s, address-space64GiB and individual-file128MiB guards remain source-bound controls (`D/SPEC.md:31`; `D/run-query.py:269–270,293–300`), not an OS sandbox.

## 6. Literal SDC paths and preservation reconciliation

Parsed actual `Reading SDC File:` messages, separating quoted filename tokens from any per-instance suffix. Recomputed **110 mentions /38 distinct filenames**, not assumed from F. Of these, **102 mentions /33 distinct relative paths** lexically joined to the recorded native cwd map to exact scratch `files` and `callback_files` keys. Each digest also equals the corresponding original Work14 inventory digest in the now-exported `D/preservation.json.gz`. This includes `../../../shared_config/top.sdc` at `log:258`; its exported bytes, before/after constraint-delta hashes, candidate entries and original inventory agree at SHA256 `8255b34c200a46178174b9788bdc9231072ae829f57c34703cc63dd28ab66c3d` (`D/constraint-delta.json:2–5`; `D/candidate.json:7724,15614`).

The remaining **8 mentions /5 filenames** at `log:484–491` are literal **original Work14**, not scratch, QDB proxy paths. Their exact common prefix is:

```text
/home/uwb_student00/ahls/new_BSP/work_ia840f_fim_14/syn/board/ia840f/syn_top/qdb/_compiler/ofs_top/_flat/26.1.1/source/1/.temp/cpt_proxy/
```

| Exact suffix under that prefix | Log lines | Candidate callback/file lines for corresponding scratch copy | Equal original-inventory/copy SHA256 |
|---|---|---|---|
| `altera_internal_oscillator_atom.sdc` | 484 | 6228, 14118 | `cd774f66e34d34c5a915b7eea9aba463edc025adfb36cd1c09ce3e196c40c2c2` |
| `altera_reset_controller.sdc` | 485–488 | 6237, 14127 | `8834ac8de6421bc2c052c2ac8d7a71127477590111c6daab3bf9c8623501d769` |
| `altera_avalon_st_handshake_clock_crosser.sdc` | 489 | 6224, 14114 | `7a0ef1540845742129401e98536483a5ec3c47580e57c7a591041327f91b2af1` |
| `alt_sld_fab_0_st_dc_fifo_1953_phmrs5y.sdc` | 490 | 6219, 14109 | `3ede7ffdf15991078de85c4d7293e687b65868478f04369166e9da001b5ea73e` |
| `default_jtag.sdc` | 491 | 6255, 14145 | `ba78fae51b3bd15e7b734275976a61bc32e1c7068461717478f4ec760fcd09d8` |

For each proxy, looked up the literal original path under the decoded Work14 root, then compared the corresponding scratch candidate entry in both maps; equality held. The full38-filename reconciliation also exactly matches F's consumed map after only `fanout-diagnostic01`→`fanout-diagnostic02` in copied-root paths; original tokens stay unchanged. F review SHA256 `ba605b71b16adfb5eaae517a995e8118cb68c05bfb05d7c644d67604af754a51`; F parent-consumption SHA256 `bbc8b7fa8a736bbcdfd9ed999801d4f4c658a1834256fe02114a83c617920fe2` (`F/result-independent-review01.md:116–140`; `F/parent-result-consumption01.json:19–212`). No logged SDC filename remains unexplained **at this inventory level**.

`D/preservation.json.gz` independently hashes to `ba54fad92731357ffa65f163bdb402f133d3841f5e90660df752ac98f18394af`; fully parsed original inventories contain **Work14 7,346 / SOURCE1,656 / PIM536 entries**. Candidate PIM equals its saved original inventory. Complete scratch-versus-Work14 comparison has no removals, one added successor gate, and exactly five changes: two relocated links, two relocated non-SDC text files, and the copied dispatcher. The four relocation old/new entries match `D/path-relocations.json:2–20`. No SDC or opaque database change appears in this saved preparation delta.

`X/preservation-after.json:2–4` contains exactly the same three original roots as that inventory, all **literally true**. Source shows full-inventory comparisons and false/missing-preservation rejection (`D/run-query.py:280–287`); the issuance receipt independently records the prelaunch preservation result. Preparation's initial copy-equality/donor-preservation receipt is also true (`D/tests.json:3,8`).

**Residual limits:** the full original *before* inventory is now exported, improving on F's missing-inventory limitation, but a complete measured after-inventory is not exported; the postrun booleans remain captured comparison receipts. Neither logged filenames nor original/copy hashes are per-open hashes or a file-access trace. Literal original paths must not be relabeled scratch opens. We cannot establish which QDB-backed storage object was opened, absence of unlogged dependencies or transient writes, semantic success of every constraint, fresh remote preservation, or OS-enforced isolation. No opaque-QDB edit is justified or performed.

## 7. Frozen evidence and disposition

Before review, captured **64 existing non-CURRENT files** in G, including preparation, result, review/consumption and issuer evidence. Rehashed the same set before publication: all64 unchanged, none missing. Snapshot SHA256 is `05a58b8f34be62f9b3f6cdf76d2647c081000a2b1b6189d0c589ca8d51b03dfb`, over UTF-8 `json.dumps(relative_path_to_sha256, sort_keys=True, separators=(',', ':'))`. The historical40-file preparation subset independently matches its consumed inventory hash above. Mutable `CURRENT.md` and separately named later artifacts are outside this snapshot; parent status/successor writes are not frozen-package drift. This report is the sole authored project file.

Retain the exact failed result and preceding measurements. **Do not rerun this consumed attempt.** The proposed collision diagnosis/minimal successor belongs to separate work, not this review. No implementation fix, new authorization or native launch is made here.

The ordinary baseline SDC load created its normal clock inventory; “no new clocks” in the result means **no additional diagnostic repair-clock creation**, not absence of baseline clocks. The diagnostic never invokes the inactive helper's `apply`/`verify_created`; its driving-association-versus-definition defect remains unfixed and unapproved (`D/SPEC.md:7`; `D/clock-repair.tcl:45–56`; `D/query.tcl:73–195`). Old experiment03 candidate remains unissued/blocked by this review.

**Execution:** confirmed failure. **Finite diagnostic:** incomplete. **Forward returned sets:** the precise partial observations above are retained. **Collector/receiver mapping:** not validated. **Source/clock repair and A/B timing/exception coverage:** unresolved. **Timing/CDC/DRC, fit acceptance, persona/backend/recovery, DDR/transfers/AHLS/sustained operation/durable boot and hardware:** no qualification granted. **Task closure:** none.

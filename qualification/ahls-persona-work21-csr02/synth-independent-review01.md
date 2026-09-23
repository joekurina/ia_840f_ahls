# Independent review — CSR02 Work21 setup and mapped synthesis

Status: **FINAL**. An **IN_PROGRESS** checkpoint was written to this same path before evidence verification; this final report supersedes it.

## 1. Specification verdict and boundary

**Specification: PASS for the exact completed setup01 and full native mapped synthesis01. Quality: PASS WITH FINDINGS for bounded evidence acceptance, not warning clearance or system qualification.** No blocking defect in acquisition, candidate identity or the requested setup/mapping claim was established. Accept these completed stages with the limitations and actionable findings below.

Read `SYNTH-SCOPE01.md` and `RESULTS-SYNTH01.md` first, then checked the frozen package and native reports. The reviewed target is Quartus Prime Pro **25.1.0 Build 129**, **AGFB027R25A2E2V**, project **ofs_top**, top **top**, revision **ofs_pr_afu / PR_IMPL**, in the matching Work21 PR context. This is neither the former naked-interface diagnostic nor empty-template elaboration.

This review is **evidence acceptance, not a build-authorization barrier**. It supplies no reason to stop or repeat the parent's already-running fitter for the nonblocking limits here. The parent alone owns that process; PID129114 was not polled, supervised or modified. Mutable `CURRENT.md` and fit/STA files outside the package were not inspected. No SSH/network, native/vendor/simulator or device execution, runner imports/execution, Git operations, task transitions or implementation changes occurred. Inspection used only local byte hashing, AST/literal/base64/gzip decoding, source reads and report parsing. This report is the sole authored project file.

**Not accepted:** changed fit, final STA/timing, mapped-functional equivalence, full reset/CDC/SDC coverage, physical PR preservation, runtime PR, assembly/GBS, physical DDR/PCIe/OPAE, deployment or hardware operation. The previous **-0.367/-0.356 ns** actual CSR setup failures remain unresolved pending changed final STA. Registered arithmetic and the accepted unit pass are not measured timing improvement. The UUID **673c03a1-cef3-4c82-bf10-b12c247d9718 is not deployed**. Vendor DDR simulation remains **SKIPPED BY USER**.

### Citation convention

All paths are under `/home/joe/Projects/Thesis/AHLS/new_bsp/new`:

- `B` = `qualification/ahls-persona-work21-csr02`.
- `P` = `qualification/ahls-persona-work21-01` (frozen preceding acceptance/context).
- `U` = `qualification/dma-csr-timing01` (separately accepted unit gate).
- `J` = `B/artifacts-synth01/persona/build/syn/board/ia840f/syn_top`.
- `SYN`, `AE`, `DRC`, `PART`, `SDC` = `J/output_files/ofs_pr_afu.syn.rpt`, `.syn.ae.rpt`, `.drc.synthesized.rpt`, `.drc.partitioned.rpt`, `.sdc_constraints.rpt`.
- `LOG` = `B/artifacts-synth01/synthesis.log`.
- `SRC:<name>:<line>` = decoded `run-setup01.py` literal `C['files']['afu/<name>']` bytes, identical to synthesis `C['source_files']`. These are actual embedded source bodies, not an imported runner. `SRC:csr_mgr.sv` also equals `U/csr_mgr-candidate01.sv` byte-for-byte.

Line references below are to actual complete files or decoded source bodies. Native diagnostic `File/Line` locations are identified as such when source bodies are not embedded in this package.

## 2. Exact package, inputs and stage identity

### Frozen integrity

Independently hashed **39 package members / 82,058,026 bytes**, with **zero length/hash mismatches**. Repeated the full member check after analysis. The manifest itself has the specified full SHA256:

`8640d4cb3f72ac9d04b575a801c832c8e2da685cf200998808119d72e0a82f38`

The report is deliberately outside that manifest. All frozen members were preserved byte-for-byte.

| Evidence | Full SHA256 |
|---|---|
| Setup runner | `b62715fc3cb71f1abe6392228f36eec80a617b3da6cd3825fb1fa4a20f91feb7` |
| Setup template | `5622fef1586cce613a8b47f06f0e649dcde403c020393682177b345b8111254b` |
| Synthesis runner | `1de11977fa9a19a0c66125393a2e0b555f7df223b554499fbb13e269d1fb2de6` |
| Synthesis template | `2cd1b30b6e9ff27895ce644ee4bb9feae16db213a2cac49733bcec8a015d5f4b` |
| Setup archive, 211027 bytes | `40f353c993c53d51235dcac64422b8b85c77652196d01581219a854670cbc997` |
| Synthesis archive, 2620160 bytes | `24caf48cc162519ef1a1a0256df76077b2e9f47d22cff15f7937c5e267ba537d` |
| Actual candidate CSR | `42d09ffffb91152b9f688014bcff9ffc13e5382cddd7f478e5f9b992da232a77` |
| `LOG` | `b00aee705fc2c78e81dfacd666b7d3188f23d72ee9874f6a9dda209c2972ca89` |
| `SYN` | `5a0c38ba3b78d0c02c83f5d77dc9f2bcd0edcf9e4085e383347ea5bafe8da8be` |

Each complete runner equals its `.py.in` template with exactly `@CONFIG@` replaced by `repr(C)`. Configurations were obtained using `ast.parse` and `ast.literal_eval`, without executing statements. Both dispatch receipts' `embedded_runner_sha256` fields match actual runner bytes. Both outer receipts match the actual compressed archive hash/size and outer0. All **7 setup** and **11 synthesis** embedded archive bodies were decoded, hashed and compared byte-for-byte with the matching local exports; synthesis `output_hashes` agrees with all 11 bodies.

Dispatch wrapper `script_sha256` fields remain hash-bound receipt metadata: full outer-wrapper bodies are not package members, so this review does not claim to have independently reconstructed those wrappers. Runner/archive/member identity and native completion are independently corroborated; this transport limit is not an observed mismatch.

### Sole functional delta and unchanged binding

Compared the literal setup configuration against the preceding frozen `P/run-setup01.py`, then against CSR02 synthesis:

- All **13 AFU source payloads** decode to their stated lengths/hashes and are identical between CSR02 setup and synthesis. The exact sole changed payload relative to the prior persona is **`afu/csr_mgr.sv`**. The other **12** are byte-identical.
- Baseline CSR SHA256 is `b526562f8663139a1a5654e54695ada8de67ee260b3b6a79014344ab7f3c4073`; candidate is the hash above and matches accepted unit source exactly.
- All **255 generated inventory entries**, JSON, source list, UUID, release inventory and tool inventories are identical across prior setup, CSR02 setup and CSR02 synthesis. This is generated-source identity reuse, not fresh generation or revalidation of every generated RTL cone.
- JSON preserves `clock-frequency-high: auto-200`, `clock-frequency-low: auto-100`, `afu-top-interface.class: ofs_plat_afu`. These are requested policy/ceilings, not measured clock results. Generated `afu_json_info.vh:8–13` carries the application UUID and interface identity; metadata power0 is not a measured power result.
- `SYN:2407–2419` records the 13 selected AFU sources, including actual CSR at2415, and its generated header dependency. Setup `persona/hw/afu.qsf` lists those sources plus both generated QIPs. The actual environment omits `OPAE_PLATFORM_GEN`; `LOG:9` says `Loading PIM-based AFU`.

The changed CSR source is continuously registered unsigned **65-bit inclusive endpoint** arithmetic (`SRC:csr_mgr.sv:103–124`), passed explicitly into admission (`125–151,167–171`). Freshness, length/alignment/range, FIFO-full, live response-error and control predicates remain on the original GO service edge. The exact diff changes only this arithmetic placement, function arguments and call. Serialized AW/W capture and B blocking remain (`344–395`); architectural writes remain at `410–429`. This rechecks the maintenance invariant, not a new simulation claim.

Reuse `U/UNIT-ACCEPTANCE.md` and its final independent review, the separately accepted **b2985a1** unit milestone supplied in task context; no Git lookup or unit rerun occurred. Keep its synthetic-status, queued-entry drain, real sticky-error recovery and directed-coverage limits (`UNIT-ACCEPTANCE.md:7–13`). Do not pipeline future writes through pending B or add another writer without renewed schedule validation.

### Setup copy, exclusions and preservation

The complete **4925-entry** setup inventory equals synthesis `C['persona_inventory']` and the synthesis archive's `original_setup_inventory`. Reconstructed all **4345** critical path/hash bindings directly from literals, exact QSF delta, source/generated inventories, gate texts, JSON and source-list bytes; the resulting dictionary equals archive `input_hashes` exactly.

The **851** excluded paths are exactly the setup entries under `build/syn/board/ia840f/syn_top/dni/`, matching both `discarded_copied_dni_inventory` and `source-delta01.json`. The runner first copies and verifies the entire setup inventory, then deletes that **copied DNI directory only in the absent/fresh synthesis root** (`run-synth01.py.in:17–18,29–39`). Original setup/release remain bound and preserved. This corrects the predecessor's copied-DNI input/output-role problem without rewriting its original outer125 receipt or reusing that failed preservation result as CSR02 success.

**This is not pristine checkpoint-free synthesis.** The matching imported static root `ofs_top.qdb` is deliberately retained: **83178648 bytes**, SHA256 `7f8f25463afe3ae95d9660ddf4c5c6755d6704f828fd400de34ae38fa2aa0fc8`. Identity agrees with frozen prior context. The release's SOF/MSF/PMSF identities also agree across configurations. These are recorded remote inventory/preservation identities, not a new local binary-netlist inspection or live remote rehash.

The exact setup-to-synthesis QSF delta replaces two copied release gate/helper references with persona equivalents and adds `NUM_PARALLEL_PROCESSORS 2`. No design/clock/SDC assignment was changed. The after-QSF export equals the archived string and bound hash; before-QSF matches setup inventory. The excluded QPF was separately checked and is unchanged. `J/ofs_pr_afu.qsf:95,105,111–114` retains output SDC, inherited warning policy, green-region partition, root QDB import, AFU rebind and `PR_IMPL`.

### Historical execution and ownership receipts

| Stage | Native / effective / outer | Observed identity |
|---|---|---|
| Setup version query | 0 / 0 / 0 (setup wrapper) | Quartus25.1 Build129, PID127811/start14840017 |
| `afu_synth_setup` | 0 / 0 / 0 | PID127828/start14840094; matching release03 `hw/lib`, CSR02 source list, fresh persona target |
| Full synthesis | **0 / 0 / 0** | PID128094/start14846952; `2026-09-23T17:39:57.727306+00:00` to `17:44:28.242473+00:00` |

Exact full native synthesis argv:

```text
/opt/altera/25.1/quartus/bin/quartus_syn --read_settings_files=on --write_settings_files=off ofs_top -c ofs_pr_afu
```

It is not `--analysis_and_elaboration` or stage-only `--synthesis`. `gate-events.jsonl:1` matches native PID/start, linux64 executable, project cwd and full argument suffix. Inert inspection of its embedded gate verifies exact context/runtime hash, runner ancestry and critical-input checks, with project part/revision checks. The templates implement fresh roots/logs, explicit environments, process-group supervision with unreaped leader during cleanup, finite setup600s/synthesis1200s deadlines, two selected CPUs and **16GiB per-process** address-space limits; these are historical settings, not a recommendation to change an active successor. Historical preflights record affinity `[0,1]`, sufficient memory/disk and an empty enumerated competing-tool set. They are not an OS sandbox, aggregate memory cap or universal workload detector.

Independently checked complete/success true, empty diagnostics and postflight-error lists, no timeout, no residual descendants and empty `owned_group_live_after` for all recorded commands. Setup's five preservation/header flags are true; synthesis's four preservation flags are true. Setup tool bindings equal its **92-entry** configuration inventory; release archive binding agrees. These are retained completion/preservation receipts, not present-day process observations. No current process polling was used.

## 3. Native mapping, PR context and endpoint evidence

`LOG:6101–6105,6605–6614` records successful synthesis of root_partition, auto_fab_0, green_region and auto_fab_1, then post-synthesis snapshots for all four. `LOG:6621–6625` records success, 0errors, footer230warnings and native PID128094. `syn.summary:1–9` confirms tool/device/top/revision. Native mapping and detailed entity/resource panels, not the shared success banner alone, establish completed mapped synthesis.

`SYN:3572–3580` explicitly lists imported root `ofs_top.qdb` and **Reconfigurable green_region** at `afu_top|pg_afu.port_gasket|pr_slot|afu_main`. This is affirmative synthesis PR-context evidence, not physical partition-preservation signoff and not a dismissal of Critical20580.

| Mapped observation | Exact evidence |
|---|---|
| Whole-design estimate **96883 ALMs / 252804 dedicated registers** | `syn.summary:7–8`; includes imported static context, **not green-region-only** |
| Green-region estimate **36380 ALMs / 85984 registers**, 1373376 block-memory bits, 0 DSPs | `SYN:47574–47606` |
| Green-region boundary **4960 ports** | `SYN:47594`; these are partition ports, not physical card-pin assignments |
| Actual CSR `core|dma|csr_mgr_inst`: **459 combinational ALUTs / 454 registers** | `SYN:37699`, parameters `8301–8314` |
| Guard retained: **256 ALUTs / 331 registers**; primary host mapper retained | `SYN:38680–38682` |
| Core/DMA/kernel composition retained | `SYN:37697–37701,37776` |
| Both bank shims and page splitters retained | `SYN:38312,38486,38496,38670` |

**Endpoint observation is real but bounded.** `SYN:39836–39837` identifies the candidate's `src_last_q[58..62,64]` merged into register `src_last_q[63]`, and `dst_last_q[58..63]` merged into register `dst_last_q[64]`, under the actual CSR hierarchy. Thus the candidate endpoint state reached native optimization; it was not simply omitted or substituted with old CSR. Together with source identity and retained CSR resources this supports the requested endpoint/CSR presence claim. It does **not** enumerate 130 individually retained physical flops, prove every mapped bit/cone equivalent, or measure the new critical paths. The merge rows must not be mislabeled wholesale removal. Synthesis ALUTs are not ALMs, and none of these counts is fitted utilization.

## 4. Quality findings and warning triage

### Q1 — Diagnostic scope remains limited; no blanket warning/DRC clearance

Reparsed every native log warning including indentation and compared every line/ID/severity/message to `warning-ledger-synth01.json`: exact equality. **443 explicit occurrences = 441 Warning + 2 Critical Warning**; **224 unindented / 219 indented**. Native footer **230 warnings / 0errors** is retained separately (`LOG:6621`). Neither 443 nor230 is a count of distinct functional defects. Copies in SYN/AE were not added. No Error/Fatal-colon diagnostic was found; native zero is also independently recorded.

| IDs and explicit occurrences | Native/source citation and classification |
|---|---|
| 13461×2; 17498×1 | `LOG:330,1354,5455`, native source locations `fim_pf_vf_nmux.sv:111`, `ofs_plat_shim_ccip_rob_rd.sv:42`, `lsu_rd_back.sv:416`: parameter/localparam interpretation. Retain specialization; no new candidate defect established. |
| 16752×2 | `LOG:1142–1143`, native `ofs_plat_shim_ccip_async.sv:234,357`: potential always loops. Enabled loop DRC is zero, not a blanket CDC/timing clearance. |
| 13469×90 | `LOG:5463–5612`: actual width truncations in PIM/generated and authored AFU paths. CSR metadata cases are specifically discussed in Q4; active mux/LSU/ID/counter fields remain geometry/cone obligations, not all waived as vendor behavior. |
| 21705×2 | `LOG:5479–5480`, native `ofs_plat_prim_fifo_lutram.sv:255,261`: ignored `$fatal`. Simulation assertions are not implemented hardware interlocks. |
| 16788×22; 21610×92 | `LOG:5516–5614,5626–5717`: undriven/default-grounded fields. Source supports inactive halves of read-only/write-only DMA interfaces (`SRC:dma_read_engine.sv:101,153–154`; `SRC:dma_write_engine.sv:127,254`), but this does not explain every ID/credit/LSU field. `LOG:5692` grounds actual kernel `device_exception_bus[0..63]`, native `mmhost_ia840f_report_di.sv:30`; do not use it as proof of error detection or numerical success. |
| 24420×1 | `LOG:5624`, native `ofs_fim_pcie_dm_req_splitter.sv:298`: mixed valid/invalid pragmas. Preserve unsupported pragma scope; mapping completion does not prove every directive applied. |
| 23762×1 | `LOG:5938`; actual sweep panel `SYN:37640–37646`: includes `freeze_cc`. Real lifecycle risk/limitation, Q3 below. |
| 14284×7; 14285×7; 14320×177 | `LOG:5939–6559`: grouped RAM pruning and individual leaf nodes, not proof that177 complete FIFOs disappeared. Examples at5941–5943 include bank0 map_user/wr_fifo and CDC AW/B RAM leaves. Preserve R2 exact reply/credit/ID/metadata attribution. |
| Critical20580×1 | `LOG:6099`: imported PR-type wording. `SYN:3578` still says Reconfigurable; next physical evidence must establish preservation, Q2. |
| Critical19854×1 | `LOG:6540`; explicit PR power-up table `SYN:47453–47525`: initial-state/reset lifecycle remains open, Q3. |
| 13046×1; 13047×4 | `LOG:6560–6564`: active LSU read-burstcount tristate-to-OR conversions, native `lsu_n_fast.sv:352`. **R1 remains open**; prior source reasoning narrows concern but is not mapped fan-in/equivalence proof. |
| 13024×1; 13410×31 | `LOG:6565–6596`, native `afu_main.sv:73`: constant boundary groups, including external-memory IDs and length upper bits. Not card pins or proof of dropped active transfers. `SRC:ia840f_ahls_memory_bank_shim.sv:17,44` retains 5-bit bursts/4096-byte page splitter, making some constants source-plausible, not closing exact mapped-field correspondence. |

Coverage limits checked in full native reports:

- `SYN:871–876`: Design Assistant enabled, **include IP blocks Off**, per-rule reporting cap5000, **Waive gated clock synchronizer check On**. Zero reported rule waivers must not be expanded into universal unsuppressed coverage.
- `LOG:5934`: partitioned **10 enabled / 1 disabled**; `LOG:6617`: synthesized **13 enabled / 7 disabled**. Dedicated reports enumerate enabled rules; a complete named roster of disabled rules is not supplied there. Do not infer those identities or confuse scoped `DESIGN_ASSISTANT_EXCLUDE` CDC rows (`SYN:60756–60767,66003–66006`) with a complete seven-rule roster.
- Protected-register and inverted-register tables are truncated at100 (`SYN:39401,46048`); removed-register report is truncated at5000 (`SYN:917,45923`). PR initial-condition report limit100 is configured (`SYN:947`); actual table has **69 grouped rows**, not69 individual bits, without an adjacent truncation marker.
- Inherited suppression policy remains sourced at QSF105, inventory SHA256 `44c5f7c4115342c24a24ab00f0ff004a2d24cb6887b24c35bd3569eade7f0084`; prior frozen review describes its global/scoped suppressions (`P/independent-review01.md:164–166`). Current native source-assignment panels independently show generated `MESSAGE_DISABLE` attributes, e.g. `SYN:4171–4172,4186–4187`. No suppression was added or endorsed here.
- `SDC:15–28` records only the generated SLD QIP source statement in its two panels. It is not evidence that every clock/reset/path is constrained. Bound `ofs_top.out.sdc` identity remains unchanged, SHA256 `ccdd8bce2d6aa19aacfb96e1b17d8207bd00eccaaba9319f521fbaf157de27eb`; unchanged text is not complete constraint-consumption proof.

**Action:** carry these exact scope limits into downstream acceptance. Before any stronger mapped/CDC coverage claim, resolve the specific retained cone or missing rule/constraint evidence. No unchanged synthesis rerun or speculative suppression/waiver is warranted merely to improve a ledger.

### Q2 — PR and active mapped-path semantics remain unqualified

Critical20580 is **retained**, not treated as proof PR is absent. The native partition table and matching imported QDB support synthesis context; actual fitter partition/region/static preservation must support later physical claims. Do not add guessed PR assignments based solely on warning wording.

**Mapping R1/R2 remain open:** active LSU burstcount fan-in semantics and pruning attribution for reply/credit/ID/metadata storage are not cleared by unit CSR acceptance, successful mapping, familiar vendor provenance, or retained entity totals. Reuse prior frozen source explanations (`P/independent-review01.md:158–174`) without promoting them. The smallest discriminator before claiming closure is exact mapped producer/consumer/bit correspondence, using already-produced cone/clearbox evidence or a separately authorized finite query if needed. That is a downstream evidence obligation, not a request for this reviewer to execute tools or interrupt fitting.

### Q3 — Initial state, freeze and reset/drain/fence obligations remain

Critical19854 maps to actual PR initial-value rows, including reset duplication, joined reset, freeze bridges and DMA state (`SYN:47457–47466`). Source connects a crossing for freeze (`SRC:ofs_plat_afu.sv:13–16,74–76`), but native sweep explicitly removes `freeze_cc` (`SYN:37646`). An exported/forwarded freeze input is not demonstrated quiescence.

The following synthesized DRC failures remain **unwaived** (`DRC:48–65`):

| Rule | Severity / violations | Exact target and follow-up boundary |
|---|---|---|
| RES-30132 | Medium / 2 | `afu_top|clk_div2_q1`, `clk_div2_q2` (`DRC:77–78`); reset/startup behavior needs its actual clock/reset context. |
| LNT-30023 | Medium / 1 | PCIe MSI-X `intc_st_cpl_tx_tvalid`, non-inverted `msix_tx_hdr.PH[0]|SCLR` vs inverted `fmt_type[1]|SCLR` (`91`); preserve polarity semantics, not a generic waiver. |
| LNT-30010 | Low / 6 | Drivers in `DRC:104–109`, including persona `join_afu_reset|joined_reset_n` driving asynchronous reset, synchronous reset and enables (`105`). Reset reachability alone does not establish safe deassertion/CDC. |
| TMC-20501 | Low / 4 | `dup_rst`, both bank memory-shim soft resets, joined-reset crossing; requested6/implemented0, native reason all fanout in same hierarchy (`122–125`). Physical/reset adequacy remains to be established. |
| TMC-20500 | Low / 1 | `rst_link[0].rst_p[0].dup_port_rst|dup_leaf[0]`, tree depth7/implemented6 with non-register source reason (`138`). Retain exact topology. |

The other eight enabled synthesized rules are zero, including the sole High combinational-loop rule, latch and reset-release-reachability rules. `PART:45–59` is **0/10 failed**, including Reset Release instance count; `LOG:5934` still discloses one disabled rule. These are bounded stage results, not all-reset/all-CDC safety. No speculative duplicate Reset Release IP is justified.

**Action before lifecycle/hardware acceptance:** preserve and establish reset assertion/deassertion, accepted transaction ownership, queued descriptor/kernel drain, outstanding response retirement, posted-write fences, buffer lifetime and PR handoff. Existing control bits/status and unit fixtures do not supply those contracts. No fixed delay or presence of a freeze bridge alone proves drain.

### Q4 — Exact metadata/control ABI is not hardware-qualified

Current candidate still emits **three** CSR truncation warnings (`LOG:5590–5592`): `csr_mgr.sv:223` raw data width into3bits, `:224` raw data FIFO depth into4bits, `:312` packed150-bit status into64bits. These lines are unchanged except shifted source positions by the endpoint insertion; the patch does not newly repair or validate them.

`SRC:dma_pkg.sv:27,112,176–198,225–249` and `SRC:csr_mgr.sv:217–234,300–320` make the limitations concrete: raw512 in3bits and raw32 in4bits both reduce to0; config clock metadata is hardcoded400, whereas preserved image policy is auto200/100. Those fields cannot be represented as independently validated physical properties or a documented host ABI merely because their truncations are deterministic. The oversized status structure contains performance fields and state/status; narrowing is visible, but the exact host interpretation/lifecycle needs a separately agreed contract. Separate performance reads and selected status fields are not proof of every advertised field.

**Classification:** retained source-visible metadata/ABI limitations, not an endpoint-pipeline regression and not a blocker to accepting completed synthesis. Before a host depends on them, bind exact encodings/status layout to the installed host contract; scope any correction in a fresh successor. Do not alter frozen implementation or silently equate legacy control to a drain/reset API.

## 5. Bounded acceptance recommendation

1. **Accept completed CSR02 setup01 and full native mapped synthesis01**, statuses **0/0/0**, exact source/static/tool binding, source preservation and historical owned-process completion, with Q1–Q4 retained.
2. Accept the native PR/CSR/endpoint **presence and mapping evidence at its stated resolution**. Do not claim one physical flop per declared endpoint bit, mapped-functional equivalence, green-region-only totals from whole-design summary, or warning/DRC clearance.
3. Leave the existing parent-owned native iteration alone. This report neither creates a launch gate nor authorizes another execution. Reuse the separately accepted unit result rather than rerunning it.
4. Obtain changed final STA for the original negative setup paths and the new arithmetic/endpoint/admission paths before any timing claim; retain the original negative evidence, clock policy and broader signoff obligations. This review has no fit/STA result.
5. Keep runtime PR, full reset/CDC/SDC, assembly/GBS, physical DDR/OPAE, deployment and numerical/sustained hardware qualification separate. **Hardware goal remains incomplete.**

Only `B/synth-independent-review01.md` was created/updated. The full report SHA256 is returned separately after writing; it is not embedded self-referentially in this report.

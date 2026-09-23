# CSR02 Work21 fit01 — independent review

Status: **FINAL**. This supersedes the IN_PROGRESS checkpoint at this path.

## 1. Verdict, order and authority

**Specification: PASS. Quality: PASS WITH FINDINGS. Recommend ACCEPT WITH FINDINGS for the exact completed native fit01 evidence only.** No acceptance-blocking defect in the requested fit-stage identity, acquisition, preserved-input binding or native completion was established. This is not warning clearance, timing closure, mapped-functional equivalence or hardware acceptance.

Specification review was completed and recorded as PASS before beginning quality review. `FIT-SCOPE01.md` and `RESULTS-FIT01.md` were read first. All analysis was local, static and restricted to the frozen package: byte hashing, AST/literal parsing, base64/gzip decoding and source/report inspection. No runner was imported or executed. No SSH/network, vendor/simulator/device execution, Git operation, implementation edit or task transition occurred. Mutable CURRENT and later STA evidence were not inspected. **The separate parent-owned final STA was not polled, supervised, delayed or changed; this review neither authorizes nor blocks it.**

Accepted claim: Quartus Prime Pro **25.1.0 Build 129**, **AGFB027R25A2E2V**, project **ofs_top**, top **top**, revision **ofs_pr_afu / PR_IMPL**, application UUID **673c03a1-cef3-4c82-bf10-b12c247d9718**, successfully fitted the actual CSR02 Work21 persona in its matching static-import/release context and committed a final database. This is not standalone component fitting or empty-template elaboration.

Excluded: final-STA acceptance, timing closure, unconstrained/CDC/reset/exception completeness, reset/freeze/drain/PR safety, mapped-system function, assembly/GBS, runtime PR, DDR/PCIe/OPAE, deployment and hardware qualification. Prior **-0.367/-0.356 ns** setup failures are **not cleared by fitting**. The application UUID is not established as deployed. Vendor DDR simulation remains **SKIPPED BY USER**.

### Citation convention

All paths are under `/home/joe/Projects/Thesis/AHLS/new_bsp/new`:

- `B` = `qualification/ahls-persona-work21-csr02`.
- `P` = `qualification/ahls-persona-work21-01`; `U` = `qualification/dma-csr-timing01`.
- `J` = `B/artifacts-fit01/persona/build/syn/board/ia840f/syn_top`.
- `FIT`, `SYN`, `DRC`, `SDC` = `J/output_files/ofs_pr_afu.fit.rpt`, `.syn.rpt`, `.drc.synthesized.rpt`, `.sdc_constraints.rpt`.
- `LOG` = `B/artifacts-fit01/fitting.log`; `RETIME` = `J/output_files/ofs_pr_afu.fit.retime.rpt`.
- `F` = decoded `B/result-fit01.json.gz`; `C` = AST-literal `C` in `B/run-fit01.py`.
- `SRC:<name>:<line>` = decoded `C['source_files']['afu/<name>']` bytes, independently checked against setup/synthesis literals. Native SDC file/line references are distinguished from locally available source bodies.

Line numbers identify complete native files, not a synthesized excerpt. Long fixed-width native panels were parsed in full; report-column padding was removed only for inspection, never from evidence files.

## 2. Specification review — verified evidence

### 2.1 Frozen identity and acquisition

Independently verified **75 files / 222405545 bytes**, with **zero byte-length/hash mismatches**, and repeated the complete check after analysis. Manifest SHA256:

`8af174a6a456e81fa1f896a129674a80272538fb3e08d06c4024b75c186759fa`

| Artifact | Full SHA256 |
|---|---|
| `B/run-fit01.py` | `e78fc8710e1c0153be9892547cffc62e4b24e2028801c837640b5c57fa17741f` |
| `B/run-fit01.py.in` | `06556f2babec086862727b5b6fb942d01daa596a1bef1f62d2b1432a3c24be42` |
| Fit archive, 4107120 bytes | `f33d14f057fb0b5d9351eb0b5a6d9a375cf003a25e25e8c39d1a4f09e9e6d5ee` |
| `LOG` | `b1dd327ac791159345ef6dc4702429d4d6d0744802e3599b02820f75ac6d90d6` |
| `FIT` | `2dbcf5f50e0bdff34521071755d385623fea1fa0f75224f206bd5c1145fefe59` |
| Bound CSR candidate | `42d09ffffb91152b9f688014bcff9ffc13e5382cddd7f478e5f9b992da232a77` |

Fit, setup and synthesis runners each exactly equal their `.py.in` template with the sole `@CONFIG@` substitution by `repr(C)`. Literal extraction used `ast.parse`/`ast.literal_eval`; no payload-bearing code was executed. Each corresponding dispatch `embedded_runner_sha256` matches. All **18 fit archive payloads**, **7 setup payloads** and **11 synthesis payloads** decode with validated base64, match their own byte count/hash, and equal the frozen local exports byte-for-byte. Fit/synthesis `output_hashes` also match. All corresponding outer receipts match compressed archive bytes/hash and outer0. The fit-prerequisite archive likewise matches its outer receipt.

Transport-wrapper `script_sha256` remains receipt metadata: the full dispatch-wrapper body is not supplied. This is a stated reconstruction limit, not an observed mismatch or a reason to repeat the successful run.

### 2.2 Fresh synthesis reuse, exact delta and preserved inputs

- `C['setup_root']` is the completed CSR02 **synth01** root; the fit root is distinct and required absent. The runner copies and prehash-verifies the entire persona before launching (`run-fit01.py.in:5,17–18,29–34`). All **5373** copied inventory records equal the frozen fit-prerequisite inventory and `F.original_setup_inventory`; paths, sizes and SHA256 formats were checked. All **602** predecessor `qdb_outputs` identities match this prefit inventory, as do **4075** predecessor critical paths inside the synthesized persona. This is fresh reuse of completed synthesis, not reuse of an interrupted fitter root. It deliberately includes accepted imported static/final state; it is not checkpoint-free synthesis.
- The only QSF delta is the two fit callback/helper references at `J/ofs_pr_afu.qsf:2–3`. Before/after strings, local exports and configured replacement agree exactly. QPF is unchanged. No RTL, SDC or clock-policy edit was made at this stage. The historical two-CPU setting remains unchanged.
- Reconstructed the complete **4512-entry** critical path/hash dictionary from all immutable copied inputs, exact post-retarget QSF, source/generated inventories, embedded gate texts, JSON and source list. It equals `F.input_hashes` exactly—not merely its count.
- **1133** predeclared exact output-role exceptions reconcile across `fit-input-roles01.json`, `C.runtime_mutable_paths` and `F.input_output_role_exclusions`: **590 DNI**, **535 QDB**, **7 output reports**, **1 QPF**. The runner uses exact membership, not a broad runtime directory waiver. The **67 protected** partitioned/synthesized paths (**34/33**) are disjoint from these exceptions; all match both prefit inventory and completed QDB inventory. All **97 newly generated clearbox paths** are immutable critical inputs and absent from the earlier setup inventory. This proves binding/preservation, not semantic review of their internal netlists.
- The five inherited synthesis/A&E/summary/DRC exports are byte-identical to synthesis. The SDC constraints report differs only in its timestamp. Flow-report changes add the Fitter result/receipt, not another synthesis command.
- All **13 AFU source bodies**, **255 generated identities**, JSON/source list, UUID, **4936-entry release inventory** and **92-entry tool inventory** remain identical to synthesis. Quartus tool bindings retain the four synthesis-stage entries and add exactly the fit frontend/runtime entries, for **6** total; this is an expected tool-scope addition, not tool drift. The bin frontend SHA256 is `222fa669a9b10a6d443268fdc506e885597b5867e77bbf13ff656b8a272933dd`; linux64 runtime is `c5cef4cc906aaffdfc177728e4ade3de6d40bb844d794dc8d6c59bbb894e91e0`.
- Compared prior Work21 setup literals: the sole changed AFU source remains `afu/csr_mgr.sv`; other sources, generated/release/tool inventories, UUID and clock policy are unchanged. Candidate bytes equal `U/csr_mgr-candidate01.sv`. `SRC:csr_mgr.sv:103–124` contains registered unsigned 65-bit inclusive endpoints. Existing unit acceptance and its serialization/coverage limits are retained; no new functional regression was run.
- Imported `ofs_top.qdb` is **83178648 bytes**, SHA256 `7f8f25463afe3ae95d9660ddf4c5c6755d6704f828fd400de34ae38fa2aa0fc8`, immutable in the critical set. Matching release is `work_fim21_pr_platform01/release03`. `LOG:1–9` identifies the Work21 FME interface `fc4bf1c1-760f-5cd7-8040-b3e86fa0d31e`, green_region and PIM-based AFU. JSON preserves `auto-200`/`auto-100`; these are requested user-clock policy, not measured core-clock results. The environment excludes `OPAE_PLATFORM_GEN`.

Original completed synthesis, release, tools and bound inputs all pass recorded postflight preservation, with empty postflight-error and diagnostic lists (`F`; `run-fit01.py.in:112–131`). These remote inventory/preservation receipts were independently reconciled locally; this review does not claim a live remote rehash.

### 2.3 Native ownership and completion

Exact command:

```text
/opt/altera/25.1/quartus/bin/quartus_fit --read_settings_files=on --write_settings_files=off ofs_top -c ofs_pr_afu
```

**Native/effective/outer = 0/0/0.** Native **PID129114 / start14892150** ran from **2026-09-23T17:47:29.706696+00:00** through **2026-09-23T19:07:54.310208+00:00**. `F.commands[0]` reports no timeout, no descendants observed at leader exit, no descendant leak and no surviving owned process group. `artifacts-fit01/gate-events.jsonl:1` independently matches PID/start, native executable, cwd and argument suffix.

The gate checks exact native context/runtime hash, issued runner ancestry, critical inputs, target part/top/revision and absence of empty-template mode. The runner preserves an unreaped group leader during owned-group cleanup, implements a finite **10800s** deadline, affinity **[0,1]**, **32GiB per-process** address-space limit and no core dumps (`run-fit01.py.in:44–46,60–107`). Historical preflight records sufficient memory/disk and an empty enumerated competing-tool set. These are not an OS sandbox, aggregate memory limit or universal escaped-process audit. They support the recorded owned-group completion; no current process state was inspected.

`LOG:677–684`: final database successfully committed (**Info20274**); Fitter successful, **0 errors / 166 warnings**; peak virtual memory **22924MB**, elapsed **01:20:23**. The fit-stage summary and detailed report confirm actual target identity (`FIT:116–138`). A flow-summary “Successful” is not substituted for the native status.

### 2.4 Actual final database and retained physical context

`F.qdb_outputs` contains **722** measured records, including **284 final-snapshot records**. The synthesized source had no `_flat`, green_region or auto_fab_1 final snapshots; fit adds respectively **27, 18 and 16** final records. In particular, under `qdb/_compiler/ofs_pr_afu/green_region/25.1.0/final/1/`:

| Member | Bytes | SHA256 |
|---|---:|---|
| `netlist.atom.cdb` | 14086400 | `e07ff36753f5d0aa5eabfddc5831ed9f9daaeb23c542bd62927ee8fa300bd3d7` |
| `physmap.cdb` | 2920053 | `9c1b602b9abd043b097808191a450e6a9f98a928f9c3bf85a8ea64e8f0d7a407` |
| `routing.cdb` | 18133117 | `b0edfe8f59fbeffa80b38c0263d304817ca12010e49688e40306512e198a3177` |

These are hash-bound completed-run inventory measurements, corroborated by final commitment and native panels, **not locally exported/decoded binary database bodies**. Do not claim independent binary-netlist equivalence. Eight copied final members in root_partition and eight in auto_fab_0 have new identities; all sixteen were explicitly declared output roles before execution. Thus “preserved static” means the native physical-preservation result below plus unchanged original import, not byte-identity of every compiler working database. Intermediate snapshots were explicitly not committed (`LOG:528`); no routed snapshot should be assumed.

`LOG:36–39` loads final root/auto_fab_0 and synthesized green_region/auto_fab_1. `FIT:240–248` reports **root_partition final preservation from ofs_top.qdb**, **Reconfigurable green_region**, and final-preserved auto_fab_0. `FIT:25188–25218` retains the actual AFU placement region:

```text
(301, 0) to (390, 20); (101, 21) to (390, 100); (0, 101) to (390, 333)
route region: (0, 0) to (390, 333)
```

`FIT:25255–25276`, **excluding partial-reconfigurable sub-blocks**, reports root **100.00% preserved core logic, dedicated registers, combinational ALUTs and ALMs used for memory**. These precise native physical observations narrow the synthesis Q2 physical-region/import gap. They do not establish runtime PR safety or bitstream compatibility by execution.

Whole-design totals are **123948 ALMs / 278200 dedicated registers / 469 RAM blocks / 321 physical pins** (`fit.summary:10–14`), including imported static design. The Logic Lock region panel separately reports **40198.5 ALMs used in final placement**, **111496 dedicated registers**, **178 M20Ks** (`FIT:25202,25207,25210`). Do not conflate “ALMs needed,” placed ALMs, partition statistics and whole-design summary. `FIT:18718` retains actual `core|dma|csr_mgr_inst` with **500 combinational ALUTs / 831 dedicated registers**; this is entity presence, not one physical flop per source bit or timing/function proof.

## 3. Quality review — warning reconciliation

Reparsed every warning occurrence in `LOG`, including indentation, and compared **line, severity, ID and complete message** to `fit-warning-ledger01.json`: exact equality, source hash equal. **166 = 160 Warning + 6 Critical Warning**, matching the native footer. Copies in stage reports are not added to that total; repeated native occurrences are not deduplicated away.

| ID | Occurrences | Scope / citation |
|---|---:|---|
| 20727 | 5 critical | Unused PR boundary inputs; `LOG:40,531,627,653,667`; finding F1 |
| 15714 | 1 critical | Incomplete I/O assignments; `LOG:80`; F2 |
| 18502 | 17 | Current/base SDC assignment-list differences; `LOG:52–68`; F3 |
| 332049 | 58 | Ignored zero/invalid-object skew/exception targets; F3 |
| 332054 | 41 | Empty clock groups, clock/delay replacement; F3 |
| 332174 | 40 | Unmatched clock/pin/register filters; F3 |
| 332158 | 1 | Preliminary Agilex7 clock-uncertainty characteristics; `LOG:433`; F3 |
| 15705 | 1 | Ignored location/region umbrella; `LOG:536`; F1 |
| 15706 | 1 | Named AFU hierarchy absent for an assignment lookup; `LOG:537`; F1 |
| 171167 | 1 | Invalid fitter assignments; `LOG:679`; F4 |

The ledger is complete for this captured native log under its inherited suppression policy, not proof of universally unsuppressed diagnostics. Fitting does not erase the separate synthesis warning/DRC record.

## 4. Exact findings and smallest follow-ups

**All findings below are retained later-qualification obligations or explicit evidence limits, not blockers to accepting this completed fit stage.** None authorizes a new native operation, alteration of running STA, speculative constraints, or an unchanged fit rerun.

### F1 — PR region retained; dangling ports and lookup warning not waived

**Narrowed:** `15705/15706` does not prove the PR region disappeared: the final partition/Logic Lock panels explicitly retain it, with native static preservation as above. Do not add guessed PR assignments based on that warning alone.

**Still open:** the complete Dangling PR/Reuse Boundary Ports panel (`FIT:252–302`) has **46 distinct input rows**: four clocks (`clk_div2`, `clk_div4`, `uclk_usr`, `uclk_usr_div2`), forty memory response sidebands (each bank's `bid[0..8]`, `rid[0..8]`, `buser[0]`, `ruser[0]`), and two remote-STP inputs (`reset`, `vir_tdi`). The first native warning's details are abbreviated with Info20186 (`LOG:40–51`); later stages list only the four clocks (`LOG:531–535,627–631,653–657,667–671`). Those shorter message blocks do not erase the complete panel or prove the other ports functionally repaired.

`SRC:ofs_plat_afu.sv:6,23–27,47–55` selects bank0 core clock, actual primary AXI host and two memory shims, making unused user clocks source-plausible. It does not settle every pruned response ID/USER bit. The vendor's noprune recommendation remains visible; no waiver is issued.

**Smallest next check before PR/boundary-functional acceptance:** map each retained dangling class to the selected PIM producer/consumer and actual ID/USER ordering contract; discriminate intentional unused inputs from required response information. Reuse exact mapped evidence for R2 rather than inferring from entity counts. Resolve the assignment lookup against retained region evidence before proposing any constraint change. Runtime PR handoff remains separate.

### F2 — Incomplete electrical assignments are specifically three BMC pins

`FIT:5838–5845` identifies **bwbmc_bmc_irq**, **bwbmc_bmc_mst_en_n**, **bwbmc_fpga_max_miso**: each “Missing termination setting and slew rate.” This is not a generic claim that the persona lacks board pin locations.

Native pin rows show user-assigned **L56**, **N57**, **U53**, bank **3A**, **1.2-V**, slew **2**, and output **Series 40 Ohm without Calibration** (`FIT:1436–1437,1504`); MISO is bidirectional with output-enable from inverted `bwbmc_fpga_spi_cs~input`. These are actual fitted/default values, **not proof of board-level electrical adequacy or explicit intended settings**.

**Smallest next check before electrical/hardware acceptance:** reconcile those three exact board nets with the approved BMC interface/board requirements and inherited static pin policy. No blanket warning suppression or speculative pin edit is justified by fit success.

### F3 — Constraint/clock coverage is incomplete evidence, not timing clearance

Full native occurrences distinguish the following scopes:

- **18502×17**: five current-only SDC entries and twelve base-only entries (`LOG:52–68`), including exported `ofs_top.out.sdc`, relocated PIM FIFO constraints, PR user clocks and base board/IP scripts. Export/import restructuring can explain list differences, but the messages do not prove constraint equivalence.
- **332174×40** (`LOG:111–193`): five unmatched clock filters, eleven memory reset/calibration pin filters, twenty-four register filters in inherited `ahls_binding|board` bank/MMIO FIFO hierarchy. R-Tile clock selectors are present among these warnings while the target uses P-Tile; EMIF and BMC/SPI names are also present. Do not label all forty as optional PCIe clocks.
- **332049×58**: twenty-four `set_max_skew` endpoint warnings at exported SDC lines **1673–1684** (`LOG:139–196`); eighteen P-Tile `set_false_path` zero-target warnings for p1/p2/p3 soft logic (`LOG:358–387`, native `intel_ptile_pcie.sdc:691–714`); eight false-path and eight multicycle warnings concerning `u_pm_dstate_sync` in `pcie_ss.sdc:589–608` (`LOG:390–413`). Some are companion “not an object ID” occurrences, not additional independent paths.
- **332054×41**: five empty clock-group warnings (`LOG:112–124`), sixteen overwritten DDR DQS input clocks and eighteen replaced DDR input/output delay constraints across both banks (`LOG:286–354`), plus two overwritten generated user clocks (`LOG:421,423`, native `user_clock_defs.tcl:29,35`). Do not add `-add_delay` blindly: first determine the intended precedence.
- **332158×1**: preliminary clock uncertainty (`LOG:433`) remains despite the summary's “Timing Models: Final.” The latter is not a universal signoff statement.

The inherited skew targets name `ahls_binding|board|banks[..].bank_avalon` and `primary_avalon`; actual bound source instantiates `core`, `primary_axi` and `map_banks[..].shim` (`SRC:ofs_plat_afu.sv:23–27,47–51,73–76`). That is evidence of stale-target scope, **not proof that actual active crossings lack every required constraint**. The tiny `SDC:15–28` report records an SLD-QIP source command, not comprehensive SDC consumption. Unchanged exported-SDC hash and clock policy do not settle active path coverage.

**Smallest next check before timing/CDC/exception acceptance:** correlate each active clock/crossing with its final object collections and effective constraints, proving optional/absent branches separately and checking delay/clock overwrite precedence. Preserve original failing CSR paths and new arithmetic-to-endpoint / endpoint-to-admission paths in the separately owned final-STA evaluation. No fit-only slack or auto-policy printout here clears **-0.367/-0.356 ns** or establishes a measured core frequency.

### F4 — Ignored assignments include reset/CDC and EMIF transfer attributes

Parsed the entire **1098-row** Ignored Assignments panel (`FIT:26333–27430`), with all six columns retained for classification:

| Assignment group | Rows | Exact scope |
|---|---:|---|
| Programmable De-emphasis | 18 | Both EMIF QIPs: `mem_ck_n[0]` OFF and `mem_dqs_n[0..7]` HIGH_LP; `26333–26350` |
| Global Signal | 1 | OFF on PCIe `coreclk_warm_rst_n|dreg[1]`, QSF assignment; `26351` |
| Force Hyper Register for Periphery to Core Transfer | 4 | Both EMIF sequencer P2C UFI indices16/18, ON; `26352–26355` |
| Hyper Register Delay Chain | 502 | EMIF UFI attributes, value350; `26356–26857` |
| Force Hyper Register for Core to Periphery Transfer | 500 | EMIF C2P UFI attributes, ON; `26858–27357` |
| Synchronizer Identification | 73 | 57 top/static targets and 16 AFU generated-kernel reset-handler targets; `27358–27430` |

Synchronizer values comprise **13 FORCED_IF_ASYNCHRONOUS, 56 FORCED, 4 OFF**. The AFU rows (`27415–27430`) include actual kernel FIFO `acl_reset_handler_inst|GEN_SYNCHRONIZER.synchronizer_head`, not only nonexistent optional host ports. The native panel does not provide a semantic reason for every ignored row. Source/vendor origin, static preservation or a familiar attribute name is not a waiver. Hyper Register Delay Chain is a clock-routing attribute, not evidence of an inserted data-delay buffer.

**Smallest next check before claiming those policies effective:** resolve the named active reset/synchronizer/EMIF targets against retained fitted objects and assignment precedence. Prioritize the sixteen AFU reset-handler rows, the exact PCIe warm-reset target and any relevant active transfer endpoints; separate absent-specialization targets from genuinely ignored active requirements. Do not requalify vendor internals or change IP merely because these rows exist; retain the exact deltas for the later approved qualification gate.

### F5 — Native retiming adds explicit reset-sequence obligations

**Newly explicit evidence:** the complete Reset Sequence Requirement table reports minimum **additional** reset cycles:

- **2** for `sys_pll|iopll_0_clk_sys` (`FIT:26097`; `RETIME:105`).
- **4** for `local_mem_wrapper|mem_ss_top|mem_ss_sv|mem_ss|mem_ss|emif_0|emif_0_core_usr_clk` (`FIT:26131`; `RETIME:139`).

The table's note explicitly ties the extra cycles to correct functionality after retiming (`FIT:26151`; `RETIME:159`). These are additions to the required sequence, not total pulse widths or proof the existing reset implementation satisfies them. Other zero rows are not all-reset safety certification. Source selects local-memory bank0 as core clock (`SRC:ofs_plat_afu.sv:6–12`), making this obligation relevant to the persona rather than dismissible as an unrelated clock.

**Smallest next check before reset/lifecycle acceptance:** bind the actual fitted clock/reset domain and reset assertion/deassertion sequence to these minimum additional-cycle requirements, including the existing joined-reset path and PR startup behavior. Preserve outstanding transaction/descriptor ownership during reset; a pulse-length check alone does not prove safe drain or recovery.

### F6 — Synthesis Q1–Q4, R1/R2 and metadata/lifecycle limits remain

The fit package includes byte-identical synthesis and DRC reports, not a new clean mapping result. Carry `B/SYNTH-ACCEPTANCE.md:9–20` and `B/synth-independent-review01.md:115–184` forward as follows:

- **Q1 retained:** synthesis explicit warning occurrences **443** versus native footer **230**, Critical20580/19854, disabled-rule/report-cap/suppression limits. Current `LOG:529,626,678` says no enabled Design Assistant rule to check in plan/place/finalize; that is **not** a clean all-rule fitter DRC result. Inherited `suppress_warning.tcl` remains bound to `44c5f7c4115342c24a24ab00f0ff004a2d24cb6887b24c35bd3569eade7f0084` and QSF105; no new suppression is accepted.
- **Q2 narrowed only for physical context:** the final PR/region/static-preservation panels now supply the previously missing bounded fitter evidence. **R1** active LSU burstcount fan-in semantics and **R2** reply/credit/ID/metadata RAM pruning remain unresolved at exact mapped bit/cone resolution (`P/independent-review01.md:158–174`; CSR02 review:146–150). Source-explained metadata pruning, native completion and retained resources are not functional acceptance.
- **Q3 retained:** synthesized DRC remains **5/13 failed**, with RES-30132×2, LNT-30023×1, LNT-30010×6, TMC-20501×4 and TMC-20500×1, all unwaived (`DRC:48–65`). The actual `freeze_cc` sweep persists in `SYN:37640–37647`; exported/forwarded freeze is not effective quiescence. Initial-state/PR reset, CDC, descriptor/kernel drain, response retirement, posted-write fences, sticky-error recovery and buffer lifetime remain open, augmented by F5.
- **Q4 retained and source rechecked:** `SRC:csr_mgr.sv:223–224` assigns raw data width512 into3 bits and FIFO depth32 into4 bits; both yield **0**, mechanically recalculated from `dma_pkg.sv:27,112,225–238` and the selected512-bit geometry. `csr_mgr.sv:230` hardcodes400MHz; this is not a measured image/core clock. `csr_mgr.sv:312` narrows the packed status (prior native warning150→64). These inherited ABI limitations were not introduced or repaired by endpoint registration. Exact encoding/status layout and host dependency must be agreed before use.

**Smallest next checks:** exact mapped producer/consumer/bit evidence for R1/R2; explicit host metadata/status contract for Q4; real reset/freeze/drain/fence/retirement contracts for Q3. Use existing accepted source/unit evidence at its stated limits. Any repair belongs in a fresh separately scoped candidate, never these frozen bytes.

### F7 — Acceptance wording must preserve evidence-class limits

No observed acquisition mismatch remains. Nevertheless:

- Complete local report/payload verification is stronger than merely accepting parent booleans, but remote QDB/tool/original preservation is still receipt-and-inventory evidence, not fresh local binary inspection or a live observation.
- Native “final preserved” does not imply unchanged compiler database bytes; the sixteen enumerated copied-final output changes above are retained explicitly. Stronger binary/functional equivalence claims would need different evidence.
- The final database exists by native commitment plus detailed measured inventory; the package does not include its binary bodies. It must not be described as independently decoded here.
- Frozen `RESULTS-FIT01.md`/`fit-parent-verification01.json` still say independent acceptance pending. This report supplies the independent recommendation without editing those historical files or performing parent task acceptance.

**Action:** retain these boundaries in the parent's disposition. No additional run is needed merely to replace historical wording or produce a cosmetically cleaner ledger.

## 5. Final bounded recommendation

1. **Accept completed native fit01 evidence with F1–F7 retained**, exact native/effective/outer **0/0/0**, original-input preservation and recorded owned-process completion. There is no identified blocker to that narrow acceptance.
2. Accept the native retained Reconfigurable green_region, actual placement/route-region and static-preservation observations, not runtime PR or mapped-functional equivalence.
3. Carry all **166** fitter warning occurrences and the prior synthesis findings forward. Do not transform missing-rule execution, ignored-target messages or source plausibility into warning waivers.
4. Keep the already-running, separately authorized final STA entirely under parent ownership. This review does not accept its results, create a launch gate or request an interruption. Prior negative setup results and full clock/reset/CDC/exception obligations remain open.
5. Hardware goal remains incomplete. No physical DDR/OPAE, programming, assembly, deployment, reset or PR operation is authorized by this report.

Only `B/fit-independent-review01.md` was authored/updated. The frozen manifest and all75 members remain unchanged. The full report SHA256 is returned separately after final writing, not embedded self-referentially here.

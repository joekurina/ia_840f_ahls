# Independent review — caps01 actual Work21 setup and mapped synthesis

Status: **FINAL**. This replaces the early IN_PROGRESS checkpoint at this same path.

## 1. Specification verdict first

**Specification: PASS for completed setup01 and full native Quartus25.1 mapped synthesis01. Quality: PASS WITH FINDINGS for that bounded stage acceptance.** No blocking mismatch in the requested functional delta, package identity, consumed source/context, preservation receipts or native setup/mapping outcome was established. This is not warning/DRC clearance, mapped-functional equivalence, or system signoff.

The actual target is Quartus Prime Pro **25.1.0 Build 129**, device **AGFB027R25A2E2V**, project **ofs_top**, top **top**, revision **ofs_pr_afu / PR_IMPL**, using matching **Work21 release03**. The persona is the real PIM-based AHLS memory/DMA composition, not an OPAE_PLATFORM_GEN blank template or naked-interface component diagnostic. The source delta is exactly the additive CSR capability extension specified below.

Read `SYNTH-SCOPE01.md` and `RESULTS-SYNTH01.md` first. Inspection was static and local: byte hashes, literal/AST/base64/gzip decoding, source comparison and native-report parsing only. No runner was imported or executed. No SSH/network, vendor/simulator/test/device execution, Git operation, source modification, task transition, mutable CURRENT read or fitter inspection occurred. The parent-owned fitter was not polled, operated, interrupted, awaited or gated. This review grants no new execution authority and requires no unchanged rerun.

**Not accepted here:** fit, final STA/timing, assembly/GBS, physical partition preservation, runtime PR, reset/CDC/lifecycle closure, electrical adequacy, physical DDR/PCIe/OPAE reachability, numerical hardware correctness or durable boot. Vendor DDR simulation remains **SKIPPED BY USER**. Q1–Q4 and R1/R2 below remain explicit limits. The hardware goal is incomplete.

### Citation convention

Paths are relative to `/home/joe/Projects/Thesis/AHLS/new_bsp/new`:

- `B` = `qualification/ahls-persona-work21-caps01`.
- `P` = `qualification/ahls-persona-work21-csr02`; its frozen review is predecessor context, not current caps01 qualification.
- `M` = `qualification/dma-csr-metadata01`.
- `J` = `B/artifacts-synth01/persona/build/syn/board/ia840f/syn_top`.
- `SYN`, `AE`, `PART`, `DRC`, `SDC`, `FLOW` = `J/output_files/ofs_pr_afu.syn.rpt`, `.syn.ae.rpt`, `.drc.partitioned.rpt`, `.drc.synthesized.rpt`, `.sdc_constraints.rpt`, `.flow.rpt`.
- `LOG` = `B/artifacts-synth01/synthesis.log`.
- `SRC:<file>:<line>` = decoded source body in setup runner literal `C['files']['afu/<file>']`, identical to synthesis literal `C['source_files']`. `SRC:csr_mgr.sv` is byte-identical to `M/csr_mgr-candidate01.sv`.

Native report source locations are distinguished from locally decoded source lines. Inventory-only binary identities below are captured remote bindings, not a new remote rehash or binary-netlist inspection.

## 2. Frozen integrity, consumed sources and exact delta

### Package and exports

Independently verified the manifest and all **42 members / 84,379,291 bytes**, with **zero size/hash mismatches**, then repeated the complete member check after analysis. Manifest SHA256:

`802e96d7a3d0f8c742d8b59b5154aae3cd34e89d0ed0fd914c9ffe0f26443834`

| Bound evidence | SHA256 |
|---|---|
| Setup runner | `798134e3b3d91622b1207c2e10635868b7fb0a0bea5918533bb65812b4765dd9` |
| Synthesis runner | `fcdb07ebb87ff30a016c597383492a66e6867d8800b0deb38986be15187959ff` |
| Setup archive, 211164 bytes | `b84f7a5286928bf343ae24259d0bd1aa3363abca98b8d5ad2d565c4ca6ccbf52` |
| Synthesis archive, 2607955 bytes | `213bab5472c662ed1da07fda0f66b6931117c18f85471425c9c1e7673f027e9c` |
| Baseline CSR | `42d09ffffb91152b9f688014bcff9ffc13e5382cddd7f478e5f9b992da232a77` |
| Candidate CSR | `053b9855aa860c410337f5cae7e6160c6086726903cf988a1d35f032cb7a0b93` |
| Native synthesis report | `19fac4e0ff6923dbf9dcc7e05888514df7e048a8567a8c6aaa336bb219067757` |
| Native synthesis log | `611f038b3b2bd1545c1ee94f1d034f936f8a197517e553d5027b9be94bbe3c23` |

Both complete runners exactly equal their bound `.py.in` templates with `@CONFIG@` replaced by the literal configuration. Used `ast.parse`/`ast.literal_eval`, not runner execution. Dispatch `embedded_runner_sha256` matches each runner; both outer receipts match actual archive size/hash and outer0. All **7 setup exports** and **11 synthesis exports** were strictly base64-decoded, size/hash-checked and compared with local artifact bytes. All 11 synthesis `output_hashes` agree with their payloads.

Full transport-wrapper bodies are not package members: `script_sha256` remains receipt metadata, not an independently reconstructed wrapper. Actual runner/archive/export/native corroboration is present; no transport mismatch was found.

### Exactly one functional file

Compared actual decoded caps01 setup bodies against the frozen CSR02 setup configuration, then caps01 synthesis configuration:

- Both have the same 13 AFU source names. **Only `afu/csr_mgr.sv` changes; all other 12 payloads are byte-identical.** Every caps01 body matches its declared size/hash and synthesis source binding.
- Decoded baseline/candidate CSR exactly match `M/csr_mgr-baseline01.sv` and `M/csr_mgr-candidate01.sv`. Independently generated unified diff exactly equals `M/raw-capabilities01.patch`.
- All **255 generated inventory entries** are unchanged across predecessor setup, caps01 setup and caps01 synthesis, including sizes/hashes. The native setup/synthesis preservation receipts also bind these generated files; this is reuse of their exact recorded bytes, not fresh generation or renewed functional qualification.
- Release path and **4936-entry release inventory**, generated-source root, source list, JSON, UUID, platform family, **92-entry tool inventory**, four Quartus tool bindings and release-archive identity are unchanged relative to predecessor setup. Caps01 synthesis agrees with caps01 setup in all shared source/generated/release/tool/JSON fields.
- The only setup-configuration changes are attempt identity/root and that CSR payload. Synthesis guard/context texts are the predecessor's exact mechanical `work21_csr02` → `work21_caps01` retarget; guard Tcl is unchanged. Nonconfiguration runner changes are the explicit CPU/address-space policy, its recorded metadata, synthesis parallelism assignment and unique transport names. Supervision/preservation/deadline logic is not weakened.

The actual diff adds capability constants, a static representability rejection branch, four read cases, and extends full-address eligibility from the old final word through0xb0 (`M/csr_mgr-candidate01.sv:88–125,346–349`). No descriptor arithmetic, state-update block, write predicate, write-value check, data-transfer logic, clock/reset wiring or SDC policy is edited.

| Byte offset | Added 64-bit read word | Source meaning |
|---|---|---|
| `0x98` | `49413834444d0001` | Exact ID tag / ABI1 |
| `0xa0` | `0002001000200200` | 2 banks; 16 descriptor entries; 32 configured FIFO beats; 512 data bits |
| `0xa8` | `0008004014393922` | Reserved0; AXI LEN8; beat64 bytes; length20; common descriptor57; host57; bank-local34 address bits |
| `0xb0` | `000000060001ff00` | Mode mask6 for modes1/2; maximum admitted130816 full beats |

These words were independently calculated from the decoded source geometry and formulas, not observed by MMIO or inferred from legacy metadata. `SRC:dma_pkg.sv:27–37,104–117` supplies FIFO/width definitions; `SRC:ofs_plat_afu.sv:57–67` rejects a nonmatching actual PIM geometry. The limit is `((1 << (8+1))-1) * (1 << 8)`. It is an admission limit, not an exercised maximum transfer.

The new cases use the existing registered response path. Full presented address/alignment and size3 are validated before the five-bit read index (`csr_mgr.sv:119–125,178–182,286–324`). Existing `csr_writable` still enumerates only the original writable words; every new capability write remains DECERR. The new interval therefore does not admit new architectural writes. Legacy read cases, response holding/reset behavior and all architectural writes are byte-preserved outside the exact patch (`324–345,352–457`). This is source reasoning, not a cycle-equivalence proof by this review.

The unchanged outer guard admits the DMA aperture and retains full-address/access-shape checks (`SRC:ia840f_ahls_mmio_guard.sv:35–52`). The source remains the guarded actual-PIM composition (`SRC:ofs_plat_afu.sv:18–38,73–88`); native CSR interface parameters are ADDR16/DATA64/RID18/WID18 (`SYN:8301–8314`). These do not establish a physical PF/VF/BAR mapping or host reachability. Debug/fixture values are not live OPAE results.

**Separate unit gate:** `M/RESULTS01.md:5–9` reports the retained baseline RED and candidate GREEN, including311cases/58635checks and pure host-decoder tests. Those results and their independent review belong to the separate unit-review delegation. Here their candidate source identity is verified; their tests were neither rerun nor independently re-reviewed, and their outcome is not promoted to mapped-functional/hardware qualification.

### Real setup, copy boundary and preserved inputs

`artifacts-setup01/setup.log:1–8` identifies the matching Work21 `release03/hw/lib/platform/platform_db/ofs_agilex.json` and copies that release build. Generated platform header/addenda select `ofs_plat_afu`; actual `persona/hw/afu.qsf:3–17` selects the 13 sources and both generated QIPs. The generated UUID header is **673c03a1-cef3-4c82-bf10-b12c247d9718**, unchanged application identity; capability presence/version must be detected through the tag, not a new UUID. It is not a deployment claim.

The explicit environments omit **OPAE_PLATFORM_GEN** (`run-setup01.py.in:37–38`, `run-synth01.py.in:50–51`), and `LOG:9` says `Loading PIM-based AFU`. `SYN:2407–2419` records the actual source closure; the CSR row at2415 names caps01 setup source and generated UUID-header dependency. JSON preserves `auto-200` / `auto-100`; these are requested clock policies, not measured frequency/timing. Power0 metadata is not measured power.

The setup archive's **4925-entry persona inventory** equals synthesis configuration and archive `original_setup_inventory`. Reconstructed **all4345 critical input path/hash bindings** from the literal inventories, QSF after-state, guards, JSON and source-list serialization; the reconstructed dictionary exactly equals synthesis `input_hashes`.

The discarded set is exactly **851 inherited DNI entries** under the copied project `dni/`, equal to `discarded_copied_dni_inventory`. The runner first verifies original setup/release and the complete fresh copy, then removes only this copied DNI directory (`run-synth01.py.in:17–18,29–39`). It asserts no inherited `qdb/` or `db/` and retains the matching static root **ofs_top.qdb**, **83178648 bytes**, SHA256:

`7f8f25463afe3ae95d9660ddf4c5c6755d6704f828fd400de34ae38fa2aa0fc8`

Thus this is fresh active-persona synthesis with deliberately imported accepted static state, **not checkpoint-free synthesis**. Original setup/release are not cleaned or modified.

The exact copied-QSF delta replaces two release gate/helper references with persona equivalents and adds `NUM_PARALLEL_PROCESSORS 36`; no RTL/clock/SDC/PR design assignment changes. The before-QSF hash matches setup inventory; after-QSF bytes match the export and critical binding. The excluded QPF was separately compared and is unchanged. `J/ofs_pr_afu.qsf:95,111–114` retains `ofs_top.out.sdc`, green-region partition, imported root QDB, rebind and PR_IMPL.

All recorded setup preservation/header flags are true (`release_unchanged`, `generated_originals_unchanged`, `tools_unchanged`, `afu_inputs_unchanged`, `uuid_header_correct`). All synthesis preservation flags are true (`setup_unchanged`, `release_unchanged`, `tools_unchanged`, `bound_inputs_unchanged`). Both postflight-error lists are empty. These are hash-bound completed-run observations, not claims about mutable present remote state.

## 3. Native outcome and bounded mapping

| Completed operation | Native / effective / outer | Historical identity |
|---|---|---|
| Quartus version query | 0 / 0 / 0, setup wrapper | PID138242/start15980329; Build129 |
| Actual `afu_synth_setup` | 0 / 0 / 0 | PID138259/start15980406; matching release03 library and caps01 source list |
| Full native synthesis | **0 / 0 / 0** | PID138522/start15989318; `2026-09-23T20:50:21.387511+00:00` through `20:54:45.367517+00:00` |

Exact completed native argv:

```text
/opt/altera/25.1/quartus/bin/quartus_syn --read_settings_files=on --write_settings_files=off ofs_top -c ofs_pr_afu
```

Not A&E-only or stage-only `--synthesis`. `gate-events.jsonl:1` corroborates accepted native linux64 executable, PID/start, cwd and argv. Both final archives have complete/success true, empty diagnostics/postflight errors; every command has no timeout, no observed residual descendants and no owned live survivors. Both outer receipts are zero. The earlier `result-synth-snapshot01.json` is correctly an in-progress historical snapshot; completion comes from the final archive/reports, not that snapshot.

**Resource policy:** both recorded preflights use CPUs0–35 and68719476736-byte per-process AS limits, sufficient recorded memory/disk, and an empty enumerated competing-tool set. The native synthesis snapshot independently records the same actual affinity and soft/hard AS limits. This supersedes predecessor2CPU/16GiB for these fresh runs only. QSF146, `SYN:862` and `FLOW:240` record requested/allowed parallelism36. No distinct actual worker-count/internal-maximum panel is supplied in these synthesis exports: **36 allowed/requested does not prove36 effective workers**, and no historical fitter-specific maximum is substituted. Per-process RLIMIT_AS is not an aggregate sandbox. Finite600s setup/1200s synthesis supervision and identity/preservation checks remain unchanged.

`LOG:6101–6105,6605–6614` records synthesis of root_partition, auto_fab_0, green_region and auto_fab_1 and saving four post-synthesis snapshots. `FLOW:399` contains a Synthesis resource-use row only; its Successful status is not full flow completion. The archive inventories602 QDB outputs, including partitioned and synthesized roles; no binary netlist query was made. Native summary and actual mapped resource panels establish mapping beyond the shared success banner.

| Current native observation | Citation / limit |
|---|---|
| Root import `ofs_top.qdb`; **Reconfigurable green_region** at `afu_top\|pg_afu.port_gasket\|pr_slot\|afu_main` | `SYN:3572–3580`; synthesis context, not fitted preservation |
| Whole-design estimate **96873 ALMs**, **252809 dedicated registers** | `syn.summary:7–8`; includes imported static context, not persona-only |
| Green-region estimate **36411 ALMs**, **85989 registers**, **1373376 block-memory bits**, **0 DSPs** | `SYN:47569–47601`; not fitted utilization |
| Green-region **4960 boundary ports** | `SYN:47589`; not physical board pins |
| Actual `core\|dma\|csr_mgr_inst`: **487 combinational ALUTs /455 registers** | `SYN:37699`; source-bound changed CSR retained |
| Guard **256 ALUTs /331 registers**, primary host mapper retained | `SYN:38680–38682` |
| Core/DMA/kernel retained | `SYN:37697–37701,37776` |
| Both bank shims and page splitters retained | `SYN:38312,38486,38496,38670` |

The retained registered endpoint optimization is also visible at `SYN:39836–39837`: selected upper bits of `src_last_q`/`dst_last_q` merge with other bits of the same endpoint registers. This is neither omission of the CSR nor a claim of130 distinct physical flops. Native CSR selection, geometry, retained resources and successful mapping support acceptance of synthesis of the changed source. The reports do **not** directly read back the four new constant words or prove every optimized cone equivalent. Constant localparams need not remain individually named mapped registers. No new exhaustive-equivalence framework is needed to label this stage honestly.

## 4. Quality findings — retained and bounded

### Q1 — Diagnostics and coverage are not clean merely because native returned0

Reparsed the entire native log and compared every warning occurrence's line, severity, ID and message to `warning-ledger-synth01.json`: **exact equality**. There are **443 explicit occurrences:441 Warning and2 Critical Warning;219 indented and224 unindented**. The native footer is independently **230warnings/0errors** (`LOG:6621`), not forced equal to occurrence count. Copies in SYN/AE were not added. No native Error/Fatal-colon or numbered Error/Fatal diagnostic was found in the log; recorded native zero remains independently decisive.

The ID totals match those documented by the frozen predecessor review. That comparison does **not** establish unchanged DRC targets, identical mapped circuitry, or harmless warnings; current dedicated DRC and mapping panels were read directly.

| IDs / explicit occurrence counts | Current evidence and disposition |
|---|---|
| 13461×2;17498×1 | `LOG:330,1354,5455`: parameter/localparam specialization; no new capability defect established, not blanket semantics clearance. |
| 16752×2 | `LOG:1142–1143`, `ofs_plat_shim_ccip_async.sv:234,357`: potential always loops; enabled combinational-loop DRC is0, not full CDC/timing qualification. |
| 13469×90 | `LOG:5463–5612`: truncations across generated/PIM and authored fields. Three CSR legacy cases are specifically retained in Q4. Other active ID/credit/LSU widths remain exact-cone obligations. |
| 21705×2 | `LOG:5479–5480`, PIM FIFO `$fatal` ignored; simulation assertions are not hardware interlocks. |
| 16788×22;21610×92 | Undriven/default-grounded fields. `LOG:5692` explicitly grounds kernel `device_exception_bus[0..63]`; do not use it as a numerical/error checker. Inactive interface halves do not explain away every active field. |
| 24420×1 | `LOG:5624`, PCIe request splitter: mixed valid/invalid pragmas. Successful mapping does not prove every pragma applied. |
| 23762×1 | `LOG:5938`, `SYN:37640–37646`: actual hierarchy sweep includes `freeze_cc`; lifecycle limitation Q3. |
| 14284×7;14285×7;14320×177 | Grouped RAM pruning plus individual leaves, including bank metadata/CDC, reply tracking and fence metadata (`LOG:5941–5943,6098,6543–6559`). Not177 complete FIFOs removed; R2 remains open. |
| Critical20580×1 | `LOG:6099`: imported PR-type mismatch wording; current partition still says Reconfigurable. Retain Q2, not a guessed constraint patch. |
| Critical19854×1 | `LOG:6540`; actual PR initial-value panel below. Retain Q3. |
| 13046×1;13047×4 | `LOG:6560–6564`: active LSU burstcount tri-state fan-out converted to OR, native `lsu_n_fast.sv:352`; retain R1. |
| 13024×1;13410×31 | `LOG:6565–6596`: constant PR boundary groups including IDs/upper LEN bits; not physical pins or proof of broken transfers. Existing5-bit page-limited shim gives bounded source rationale, not complete mapped-field clearance. |

Coverage qualifications remain material:

- `SYN:871–876`: Design Assistant On, include IP blocks Off, per-rule cap5000, gated-clock synchronizer check waiver On. No reported waived violations is not universal unsuppressed coverage.
- `LOG:5934,6617`: partitioned10enabled/1disabled; synthesized13enabled/7disabled. Dedicated reports list enabled rules, not a complete named roster of disabled rules. Scoped `DESIGN_ASSISTANT_EXCLUDE` rows (`SYN:60751–60762,65998–66001`) are not that roster.
- Protected-register table truncates at100 (`SYN:39401`), removed-register table at5000 (`45918`), inverted-register table at100 (`46043`). The PR initial-value table has69 grouped rows (`47452–47520`) under configured limit100 (`947`), not69 individual bits.
- Inherited warning policy is unchanged; actual generated `MESSAGE_DISABLE` assignments remain visible (`SYN:4171–4172,4186–4187`). No new suppression or waiver is introduced or endorsed.
- `SDC:15–28` records only the SLD QIP source statement in the two stage panels. It does not establish complete clock/path/reset constraint consumption.

**Bounded action:** preserve these distinctions in downstream acceptance. Resolve only the specific required cone/rule/constraint before claiming more; no unchanged synthesis rerun, generic framework, or warning-count gate is warranted.

### Q2 — PR and exact mapped transport semantics remain open

Current `SYN:3578` affirmatively retains Reconfigurable green_region despite Critical20580. This is not proof that the physical partition/static context has been preserved through fitting, electrical implementation or runtime PR. Matching downstream evidence must support those later claims; this reviewer did not inspect it.

**R1:** the exact active LSU burstcount producer/consumer fan-in semantics behind13046/13047 remain unqualified by these tables. **R2:** attribution of pruned reply/credit/ID/metadata bits, including page-shim and host response/fence storage, remains incomplete. Existing source explanations and vendor provenance narrow questions but do not close exact mapped correspondence. Native retained totals and unchanged warning IDs are insufficient.

**Bounded action before stronger mapping claims:** use already available exact cone/clearbox evidence for these named paths, or a separately scoped finite query if necessary. No new universal equivalence gate and no operation on the current fitter follows from this report.

### Q3 — Reset, initial state, freeze/drain/fence and host-buffer lifecycle remain open

Read the actual current dedicated reports, including target rows, rather than importing predecessor results from matching warning counts:

| Current synthesized DRC | Severity / violations / waived | Current target evidence |
|---|---|---|
| RES-30132, registers may not be properly reset | Medium /2/0 | `DRC:77–78`: `afu_top\|clk_div2_q1`, `clk_div2_q2` |
| LNT-30023, reset polarity conflict | Medium /1/0 | `DRC:91`: PCIe MSI-X `intc_st_cpl_tx_tvalid`, noninverted PH SCLR versus inverted fmt_type SCLR |
| LNT-30010, net drives reset and enables | Low /6/0 | `DRC:104–109`; persona `join_afu_reset\|joined_reset_n` row105 reaches490 async resets,1444 sync resets and513 enables |
| TMC-20501, duplication shallower than requested | Low /4/0 | `DRC:122–125`: dup_rst, both memory-shim soft resets, joined reset; requested6/implemented0, native reason all fanout in same hierarchy |
| TMC-20500, duplication shallower than possible | Low /1/0 | `DRC:138`: rst_link duplicate-reset leaf, depth7/implemented6, non-register source reason |

Thus the synthesized report has **5/13 failed enabled rules,14 violation rows,0 waived**. The other8 enabled rules are0, including combinational loops, inferred latches and reset-release reachability (`DRC:48–65`). The partitioned/elaborated report is **0/10 failed**, including Reset Release instance count (`PART:45–59`). Those are bounded stage results, not full-reset/all-CDC safety. No speculative duplicate Reset Release IP is justified.

Critical19854 corresponds to explicit power-up settings for reset duplication/joining, PCIe freeze bridges, bank resets and DMA state (`SYN:47448–47521`). Source wires the freeze crossing to the core (`SRC:ofs_plat_afu.sv:13–16,73–76`), but native sweep removes `freeze_cc` (`SYN:37646`). Forwarding a freeze port is not effective quiescence.

**Bounded action before lifecycle/hardware acceptance:** establish the actual reset assertion/deassertion/CDC contract; descriptor and kernel drain; outstanding response retirement and posted-write fences; host-buffer ownership/pinning lifetime; and PR handoff. Existing status/control bits, capability values, synthetic fixture status and a fixed delay do not establish these guarantees. Keep physical memory/electrical and independent recovery limits separate.

### Q4 — Capability extension avoids, but does not repair, inherited metadata defects

The three actual CSR truncation warnings remain at `LOG:5590–5592`, now candidate source247,248,336. Raw512 assigned to3bits and raw32 assigned to4bits both compute to0; the packed150-bit aggregate status narrows to64. `csr_mgr.sv:247–254,336` and `SRC:dma_pkg.sv:176–198,225–249` bind those widths/assignments. Hardcoded clock400 remains, while image policy stays auto200/100. None is newly qualified by native0 or the capability extension.

The new block instead supplies explicitly versioned raw geometry, widths, admitted limit and mode mask. It does not guess a logarithmic encoding, silently reinterpret old metadata, advertise frequency/drain/reset/fence support, or add a lifecycle bit. Same UUID means future host code must detect the exact new tag/version. New read-only constants are not proof that a deployed image or physical host path can reach them.

**Bounded action:** host consumers must use the separate versioned decoder contract for the new words, check actual API outcomes separately, and not infer reset/drain or hardware properties from either legacy status or the new geometry. Any later legacy repair needs its own fresh scoped delta. Source-visible metadata limitations are retained, not a blocker to acceptance of this completed setup/mapping result.

## 5. Final disposition

1. **Accept caps01 setup01 and full native mapped synthesis01**, with exact one-file additive capability delta, matching source/static/tool context, unchanged originals and native/effective/outer0 outcomes as bound above.
2. Accept actual changed-CSR/guard/core/bank presence and native mapped-stage completion at the report's resolution only. No constant-word readback, mapped-functional equivalence, warning/DRC clearance or timing result is claimed.
3. Preserve Q1–Q4/R1/R2 and downstream reset/CDC, metadata, drain/fence, host-buffer, electrical, physical PR and hardware limits. Vendor DDR simulation stays **SKIPPED BY USER**.
4. Leave the parent's independent fitter and the separate unit-result review alone. This is completed-evidence acceptance, not a new execution gate.

No substantive package/acquisition blocker was found. An initial local ledger-inspection snippet assumed an object rather than a list; it was corrected without changing evidence, and the subsequent complete occurrence comparison passed. Effective synthesis worker utilization is not reported and is explicitly not claimed. Only `B/synth-independent-review01.md` was authored/updated; no frozen member was changed. The report SHA256 is returned separately to avoid a self-referential hash.

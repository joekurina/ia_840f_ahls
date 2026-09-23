# Independent review: real PIM + DMA + AHLS analysis/elaboration

Status: **FINAL** — 2026-09-23 UTC.

## 1. Specification and bounded verdict

**ACCEPT the completed run as the first successful, source-bound Quartus25.1 analysis/elaboration of the actual generated PIM around the connected DMA/AHLS core. Do not accept functional correctness, mapped synthesis, timing, reset/PR safety, deployment, or hardware readiness.** No demonstrated new PIM structural defect requires an unchanged native rerun. The findings below remain actionable; several block broader acceptance, not this structural milestone.

Reviewed specification: `SCOPE.md`, then `RESULTS01.md` and `CAPTURE-DISPOSITION01.md`. This review is local-only: ordinary source/report reads, hashes, JSON/gzip/base64 decoding and AST/literal decoding of the runner configuration. No runner was imported or executed; no SSH, vendor/simulator/native execution, hardware access, source edits, git operation or task transition occurred. The sole authored file is this report, initially written **IN_PROGRESS** and now replaced with **FINAL**. Its exact final SHA256 is returned with the handoff, rather than embedded as a self-referential digest.

Path notation below: `P = qualification/ahls-memory-pim01`; `Z = qualification/ahls-memory-dma-core01`; `I = P/inputs-elab01`; `R = I/platform/ofs_plat_if/rtl`; `F = Z/artifacts-fabric01/ip/ahls_memory_dma_fabric/ahls_memory_dma_fabric_fabric`. Paths are relative to `/home/joe/Projects/Thesis/AHLS/new_bsp/new`. Native line references use `P/artifacts-elab01/output_files/ia840f_ahls_memory_pim_elab.syn.rpt` unless otherwise stated.

| Specification obligation | Independent disposition |
|---|---|
| Add an alternate AFU; do not replace scalar AFU or rerun the old component unchanged | Met for this stage. Project selects only the new `rtl/afu/ofs_plat_afu.sv`, whose bytes match `afu/ahls_memory/pim/ofs_plat_afu.sv`. Eleven carried-over AFU/core/header inputs match `Z/core-inputs01.json`. Native argv and hierarchy establish an actual changed PIM integration, not merely reuse of the old component result. |
| Use real Work21 PIM and finite FIM dependencies, not projected platform packages | Met for native closure, with local archive limitation F5. All 157 generated SV/Verilog assignments occur in exactly the same order in the flattened project; 211 platform members are captured. No `component_platform_pkg` is selected. |
| Exactly one primary host mapper and two actual bank shims | Met. New top lines23–44; native primary panel5077–5088 and bank panel5093–5154. `primary_axi|e|impl` is internal implementation hierarchy, not another primary owner. Both bank0 and bank1 appear under **All Instances** in the representative bank1 panel. |
| Preserve expanded fabric IDs and actual USER geometry | Met structurally. Fabric-facing banks retain18-bit IDs and2-bit USER; actual metadata FIFOs preserve them rather than slicing18 to9. No dynamic metadata/ordering proof follows. |
| Bank0 clock and source-supported reset/CDC integration | Met as wiring, not lifecycle proof. Bank0 clock drives the core; actual PIM reset joining combines bank0 reset and pClk soft reset. Per-bank vendor reset/CDC pipelines remain. F2 remains open. |
| Bound the native stage and preserve originals | Met on the captured records and independently checked local bytes. Native/effective/outer return codes are0, no timeout or remaining owned group is recorded, and all preservation flags are true. No current remote state was queried. |
| No promotion to full-device/functional readiness | Required and retained. Actual AHLS `DDRIP` computational hierarchy exists; this is not an elaboration of the physical DDR controllers/full FIM. User-clock/PR setup hooks were not run. Vendor DDR simulation is **SKIPPED BY USER**. Goal remains incomplete. |

## 2. Evidence identity, acquisition and closure

### Exact bindings

The frozen **20-entry** `review-package01.json` hashes to:

`f46d4db345d64752aa93bbabbbeb1ab2d48f21b59ea00f0518701b27842f2efd`

All20 entries matched their recorded byte counts and SHA256 at review start and at the final evidence check. This package's existence is not used as acceptance evidence.

| Artifact | SHA256 |
|---|---|
| New alternate `afu/ahls_memory/pim/ofs_plat_afu.sv` | `8297e5c3954fb6d27e3862a8206e7a857ccfa398d39baf7ac5d552166a426975` |
| `P/project01.qsf` and captured native QSF | `5a88496e0883482f3fb4eded0898e05cb1892b2da15cff7a83e26a1993928b0e` |
| `P/result-elab01.json.gz` | `175b1e72f65e1e1e015d786628d868300a9f90cd1ca332c33599c70769550633` |
| Native `elaboration.log` | `052b45ad59af79640cd9d093be6585ca826f8c3da4c70ac8a1830966dca40704` |
| Native `.syn.ae.rpt` | `8789c49f130a6a2bf73dbc9fd6beb03d97bde214958131f221f8b1cec7111fba` |
| Native `.syn.rpt` | `900ef2ad976f7a484106ccd739f898af295473ac8d8edb0c961c8a3968939383` |
| Native `.drc.partitioned.rpt` | `3e16091a9ccf8bf6c08595d62056b1d86079733c48bf291d44228e21bcce207c` |
| `P/run-elab01.py` — AST/literal read only | `f473fd585bb0f63e2a1bf806a33abba68e8c94c86859bc4213d64c24e6613757` |
| `P/run-elaboration.py.in` | `5abd22e01dc9a8d172b0fa869596ae0efd277f2376e57fb7b10a1e347ef700d6` |

The result archive matches the size/hash in `outer-elab01.json`. All9 exported members match both embedded decoded bytes and local artifact files. These are7 native log/report/project members plus2 copied PIM QSF metadata files, not9 independent native reports. `.syn.ae.rpt` is8,442,839bytes, `.syn.rpt`9,838,261bytes, and the log1,578,195bytes. The metadata-only manifest matches the decoded result.

The runner is exactly the template with its literal configuration substituted. Configuration inventories, tools, QSF and decoded273 input payloads match the input manifest and local copied files. Native inputs are273 platform/core members plus255 prior generated fabric members =528. All254 generated QIP dependency-ledger rows resolve to hash-bound entries in that255-member inventory, including the SDC_ENTITY_FILE and SYSTEMVERILOG_FILE header; both system and child QIPs are selected. This is stronger than checking only the system wrapper, but does not mean every prior generated member is locally exported (F5).

### Capture history and original preservation

- capture01 returned1; its pane disappeared and no precise failure diagnostic/result archive was captured. No exact cause is inferred.
- Independently decoded capture02:255members,254precompile matches, sole mismatch the completed Work21 context QSF (`801d9ae71588011828e6c217effb0c2292fadec8a08c39ebc5bd972549ca0256`). Its8 active macro values are copied literally. Commented-out feature macros are not enabled. The context QSF itself is not imported/executed or relabeled precompile-identical.
- capture03 adds3 packages and capture04 adds5 headers, all matching their expected hashes. Archive hashes and all embedded payload hashes verify. The combined262 non-context original path/hash pairs equal `platform_originals` exactly. These are the originals the runner checked before/after, not a claim of a fresh review-time remote rehash.
- The capture includes a memory-subsystem wrapper as context; it is not one of the compiled FIM input files. Real interface packages/headers supply geometry; physical EMIF is outside this top.
- `afu_json.tcl` and `user_clock_config.tcl` are retained but deliberately not executed. Three PIM primitive SDC assignments remain. No STA, generated user-clock configuration, PR release creation or deployed UUID is established.

### Native stage actually performed

```
/opt/altera/25.1/quartus/bin/quartus_syn --analysis_and_elaboration --read_settings_files=on --write_settings_files=off ia840f_ahls_memory_pim_elab -c ia840f_ahls_memory_pim_elab
```

Quartus25.1.0 Build129 SC Pro; target AGFB027R25A2E2V. Fresh remote work `work_ahls_memory_pim25_01/elab01`, recorded tmux@223/%223. Native interval2026-09-23T11:42:14.502411Z–11:43:16.122584Z, PID106956/startticks12700626. Native/effective/outer0; no recorded timeout, residual descendants or owned live group. Original/copy/platform/core/tool/QSF preservation flags are true and postflight errors empty. The `Synthesis was successful` banner is an A&E success marker under this exact argv, not evidence of mapped synthesis.

## 3. Wiring, geometry and clock/reset quality

**Flat connection audit:** independently parsed171 core declarations and171 new-top associations; all171 ledger expressions, directions and widths match. No missing final declaration or connection was hidden by a trailing-comma parser assumption.

- **Host:**57-bit byte address,512data,8-bit LEN,9-bit read/write IDs,4USER. Native primary settings explicitly enable read sorting, write sorting, read buffering, CDC and3 timing stages. Write sorting is a real supported extra setting, not an assumed donor default. Native DMA/top and register-slice parameters retain the wide host address; inactive local routing does not justify narrowing host IOVAs.
- **MMIO:** actual platform20-bit byte address,64data,16-bit IDs,1USER. Top lines68–100 bind LEN0 and INCR; RLAST is explicitly unused because the exposed interface is AXI-Lite. There is no top-level WLAST input to invent: native `mmio_control` bridge panel6702 has `USE_S0_WLAST=0`, and generated AXI bridge lines782–785 supply `'1`. The read-tag-plus-lane fit guard is source-supported. These facts do not cure upstream aliases or posted-write error visibility (F3).
- **Banks:** both34-bit byte address/512data/8LEN/18ID/2USER at the core boundary. `LOCAL_MEM_USER_WIDTH` comes from actual FIM WUSER fallback1 plus PIM NO_REPLY width1, not14-bit ARUSER/AWUSER metadata from an earlier synthetic fixture. The undefined `IA840F_UNSUPPORTED_PIM_GEOMETRY` branch in the new top would reject a mismatched selected shape; native success did not select it. This is a selected-configuration check, not a portability or dynamic protocol proof.
- **18-to9 warnings are not evidence of lost arbitration IDs:** `R/ifc_classes/local_mem/prims/ofs_plat_axi_mem_if_user_ext.sv:84–103,114–133` stores full request ID/USER on accepted AR/AW; lines143–178 override physical request IDs/USER to zero and restore response metadata. Native panel5290 confirms FIM_USER_WIDTH1, FORCE_RD_ID_TO_ZERO1, FORCE_WR_ID_TO_ZERO1, FORCE_USER_TO_ZERO1 and512 entries, with both banks listed. Zero physical IDs request ordering within each channel; they do not establish read-versus-write ordering or a global drain.
- **Clock/reset:** new top6–16 and `R/base_ifcs/clocks/ofs_plat_merge_resets.sv:20–35` show pClk reset crossing and a bank0-clocked joined reset. Bank shim55–70 combines crossed AFU reset with its own bank reset;103–112 and229–252 preserve its AFU-domain reset, CDC and pipelines. Both banks remain real shims even though core clock is bank0. Native async-shim panel5308 records both instances,3 stages,256 read credits and128 write credits. These are structural facts only; per-bank reset divergence, assertion/deassertion, stopped clocks, in-flight responses and recovery are not tested.
- **Ownership/tie-offs:** native mask panel5159–5169 records host mask1 and local mask3. IRQ is deliberately unrouted. The AHLS exception output is explicitly undriven/tied zero in native log5331 and cannot validate computation or errors.

## 4. Diagnostic accounting and classification

The full log was reparsed independently and matches the warning ledger row-for-row: **341 occurrences**, versus native banner **0 errors,1 warning**. All338 source-bearing rows resolve to available source files with matching hashes. Repeated log/report copies were not added together, and the vendor banner was not substituted for detailed diagnostics.

| ID | Occurrences | Classification and disposition |
|---|---:|---|
|21425|118|Confirmed project hygiene issue: duplicate command-line AFU_TOP_REQUIRES_OFS_PLAT_IF_AFU versus captured header37. Not an active functional failure; F6.|
|13469|87|Active width/arithmetic diagnostics:38 PIM,21 DMA/core,28 generated HLS/fabric. Some are source-justified transformations below; remaining numerical/protocol behavior is not blanket-waived.|
|21610|86|Undriven outputs:60 DMA/core,13 PIM,13 HLS/fabric. Classify by actual consumer/parameters; constant-zero exception and software status limitations remain meaningful.|
|16788|22|Undriven nets:5 PIM,4 DMA/core,13 HLS/fabric. Inactive directions/metadata are distinguishable from active memory traffic.|
|21442|19|Package parameters treated as localparams. Declaration semantics, not an observed data-path defect. No package override is required by this integration.|
|16752|2|Uninstantiated CCI-P error branches, **not an active AXIS combinational loop**. See exact hierarchy/source check below.|
|21705|2|Active PIM FIFO runtime `$fatal` checks ignored by synthesis. The RTL still sets its error latch, but native A&E did not exercise overflow/underflow or deliver a software-visible fault report.|
|13461|1|CCI-P ROB declaration-localparam diagnostic in the included, uninstantiated CCI-P path.|
|17498|1|HLS generated-block parameter treated as localparam (`lsu_rd_back.sv:416`); inherited declaration diagnostic.|
|20759|1|Critical warning: missing device Reset Release; full-FIM obligation, not waived.|
|21620|1|DRC summary of the same Reset Release High violation, not a second independent device-reset defect.|
|23762|1|Sweep summary. Actual panel records three instances; effective freeze is absent (F2).|

### Active versus inactive details

1. **CCI-P potential loops:** log878–879 points to `ofs_plat_shim_ccip_async.sv:234,357`, which are unconditional `always $display` statements only inside invalid-credit generate branches alongside `PARAMETER_ERROR`. Actual generated header45,59–61 selects native AXIS PCIe TLP; the native primary chain includes `tlp_mapper|fim_gasket` (panel7586), not the CCI-P shim. No CCI-P shim parameter instance or elaborating message occurs in the native reports/log. Source inclusion caused these parse warnings; this configuration does not instantiate the warned logic. This disposition must be revisited if the host class changes.
2. **PIM width idioms:** burst mapper177/273 copies fields then replaces LEN/address with gearbox outputs; source width8 versus sink width3 is expected in the active host mapper. FIFO225/238 explicitly wraps at N_ENTRIES−1. Credit counters use sized state and request gating (`ofs_plat_axi_mem_if_rsp_credits.sv:59–105,113–165`). These source patterns explain the warnings, not a test of counter conservation. Full18-bit bank response IDs are restored as described above. Dynamic packet split, response reconstruction and credit/metadata exhaustion remain functional checks.
3. **Unused PIM directions/fields:** the write-only MMIO helper has ARVALID0 and BREADY1 (`ofs_plat_host_chan_map_as_axi_mem_if.sv:123–128`); its dummy construction is explicit in `ofs_plat_host_chan_as_axi_mem.sv:332–338`. Internal generic-stream outer `.last/.keep/.user` warnings must not be confused with transaction fields: read completion uses `.t.data.last`, writes `.t.data.eop`, and packet metadata consumers use `.t.data`. Native TLP producer/consumer source supports that distinction; these warnings do not demonstrate dropped bus RLAST/WLAST. Posted MMIO BRESP is independently ignored and remains F3.
4. **DMA inactive/status fields:** source reader keeps AWVALID/WVALID0; writer ARVALID0. Opposite-direction payload warnings therefore do not identify an active request. `instance_number` is diagnostic metadata. `dma_top.sv:78–97` initializes aggregate CSR status and selects the driven read/write fields instead of treating every partial status struct as valid. It also explicitly zeros response encodings, resetting and stopped fields: those are unavailable status semantics, not proof of good responses or safe control. The mux's packed AR assignment is overwritten by field-by-field assignments in the same combinational macro (`dma_axi_mm_mux.sv:45,72–84`); its packed-width warning alone does not prove address scrambling. Local-address narrowing still relies on validated routing/admission and is not a global memory-safety guarantee.
5. **HLS specializations:** native panels11439/11493 show read-only gmem (2 read/0 write ports) and write-only gmem1_2 (0 read/1 write), with external write-ack/ECC features disabled. Native zero-width FIFO panels16488/16518/17248 explain the four `data_out[-1..0]` warnings; panel18112 has ENABLED0/FIFO_DEPTH0 for the warned fast-pipeline specialization. These are concrete parameter-bound explanations, not “vendor code is harmless.” Other inherited LSU/address/counter truncations have not been independently proved numerically by this A&E review. Reuse the separate core review and require real connected-kernel numerical evidence rather than repeating its entire source audit here.
6. **Sweep is bounded:** native30487–30494 lists the unused write-only MMIO formatter, one write-ROB RAM specialization and `freeze_cc`, each count1. It does not list removal of the whole core or either bank shim. Native core/DMA/metadata/CDC and AHLS DDRIP hierarchy panels remain present. Neither this observation nor the surviving hierarchy proves runtime function.

## 5. Actionable findings and retained blockers

### F1 — High for functional acceptance: establish the real burst contract next

**Source-confirmed boundary mismatch risk; no observed end-to-end failure is claimed.** `I/afu/dma_read_engine.sv:58–65,174–187` emits BURST_WRAP for host reads; `dma_write_engine.sv:65–72,197–209` emits BURST_WRAP for host writes. `dma_pkg.sv:126–131` gives that the AXI WRAP encoding. Length generation is not restricted to generic AXI legal WRAP lengths or alignment semantics; prior linear synthetic sinks do not settle this.

The actual native host mapper has PAGE_SIZE4096 and3-bit downstream LEN (panels5708–5750 and7280–7296). Its gearbox receives address/count, not burst type; `ofs_plat_axi_mem_if_map_bursts.sv:149–180,245–276` maps linear line addresses. Host request conversion uses address/line count, not generic WRAP address sequencing (`ofs_plat_host_chan_map_as_axi_mem_if.sv:353–357`). Conversely both local bank mappers have equal8-bit LEN widths, PAGE_SIZE0/NATURAL_ALIGNMENT0 (panel5275): the source selects the direct-connect branch, so **the bank shims themselves add no4KiB splitter**. Do not claim that host splitting cures every local PD boundary.

**Smallest next discriminator:** under the parent's permitted functional-test workflow, exercise the actual DMA→PD→PIM path, not a newly invented linear endpoint. Cover both directions/banks, short tails, maximum native bursts, starts near4KiB boundaries, split WLAST/RLAST, one visible response per original transaction, full ID/USER restoration and response/backpressure conservation. Trace whether PD splits the local bursts before they reach the bank shim. Reconcile or narrowly correct the emitted host burst encoding/contract if these checks establish a defect. No simulator was run here; vendor-DDR simulation remains excluded. A full unchanged Quartus rerun cannot answer this question.

### F2 — High for lifecycle/hardware acceptance: no effective freeze/global quiescence

New top forwards synchronized freeze into the unchanged core, but generated `F/mmhost_ia840f_report_di_10/synth/mmhost_ia840f_report_di.sv` only declares freeze at29, passes it to CRA at332, and declares it again at719 in `cra_ring_wrapper`; that module does not consume it. Native sweep removes `freeze_cc`. Freeze-capable helpers elsewhere in the fileset do not prove their instantiation on this path.

**Action:** retain PR/live-reset/buffer-release blocking status until admission stop, global drain, pending host/DDR transactions, software fences and reset/PR isolation are implemented/verified for the real system. Joined resets are not a drain protocol. Full-FIM integration must supply/prove the intended device Reset Release provider and resulting reset paths: DRC RES-10204 remains High1/0waived (`.drc.partitioned.rpt:49`). Do not add a duplicate persona-level Reset Release merely to silence this component DRC. No STA or reset-release timing proof exists in this run.

### F3 — High for host-visible control acceptance: MMIO/error/lifetime contract still incomplete

A20-bit PIM address interface does not repair the previously identified downstream low17-bit MMIO routing aliases; a16-bit DMA CSR reject check cannot reject addresses already aliased upstream. Actual PIM source explicitly ignores MMIO write responses (`ofs_plat_host_chan_map_as_axi_mem_if.sv:126–128`), so internal SLVERR is not a CPU-visible posted-write rejection mechanism. DMA top also zeros read/write response-encoding fields rather than publishing the captured first-response code. IRQ is unrouted; exception is tied zero.

**Action:** close full-width address admission before narrowing and provide readable, unambiguous admission/first-error status; test rejected writes for no side effects and observable status. Retain pinned-host extent/lifetime, one-in-flight/control restrictions, error destination invalidation, fences and verified global drain. Completion/status alone is not active numerical checking or permission to unpin/reset. This review does not reopen already accepted CSR-admission source work or waive its source-only predicate/guard-count-floor limits.

### F4 — Medium runner-quality finding: a preservation flag is omitted from acceptance

`P/run-elaboration.py.in:101` computes `platform_originals_unchanged`, but line116's `accepted_by_runner` conjunction omits it; it also does not explicitly require an empty postflight error list. Thus a future run could report platform-original drift and still obtain runner acceptance if the listed checks remain true.

**Current disposition:** not an observed preservation failure. This result has the omitted flag true and postflight errors empty, independently checked in the hash-bound archive. **Action:** on the next changed runner, include all required preservation results (including platform originals) and postflight errors in the acceptance predicate, with a focused inert rejection test. Do not mutate this consumed runner or rerun this unchanged native project to repair bookkeeping.

### F5 — Medium evidence-portability limitation: prior fabric export is not a complete local source mirror

273/273 copied PIM/core inputs rehash locally. Of255 prior generated members,251 exist under `Z/artifacts-fabric01` and all251 match. Four are absent there and absent as payloads from the prior generation archive, although their hashes are recorded in both native inventories:

- `ahls_memory_dma_fabric/ahls_memory_dma_fabric.cmp`
- `ip/ahls_memory_dma_fabric/ahls_memory_dma_fabric_fabric/ahls_memory_dma_fabric_fabric.cmp`
- `ip/ahls_memory_dma_fabric/ahls_memory_dma_fabric_fabric/altera_reset_controller_1924/synth/altera_reset_controller.sdc`
- `ip/ahls_memory_dma_fabric/ahls_memory_dma_fabric_fabric/mmhost_ia840f_report_di_10/synth/acl_parameter_assert.svh`

The last header's exact bytes are locally available in `qualification/ahls-qsys-import-01/artifacts/ip/qual_test/qual_test_k0/qual_vec_op_report_di_10/synth/acl_parameter_assert.svh`, SHA256 `34b039fd2b2bbf5e51500685220bb1b6a2f4070719e0dd56ba4d98ee069a8416`; I checked that equality without copying it. No matching reset SDC was found in the bounded older captures inspected; similar filenames were not substituted.

**Current disposition:** the captured runner verified all255 source/copy members before/after and the QIP ledger closes against their inventory. Missing local exports are not evidence that native A&E omitted them. They do prevent claiming an independently byte-complete local mirror or locally inspecting that exact reset SDC. **Action:** retain this qualification distinction; in a later authorized ordinary-file capture, retrieve the two CMPs and exact SDC and retain the known hash-identical header source. No regeneration or native rerun is necessary. No STA acceptance is granted now.

### F6 — Low: remove redundant command-line macro in the next changed project

The118 occurrences of21425 are explained by `project01.qsf:9` and captured `platform_afu_top_config.vh:37`. Remove only the redundant command-line definition when next changing the project, keeping the real captured platform header and native history intact. No suppression or counter-tidying rerun is warranted.

## 6. Handoff boundaries

This FINAL report independently accepts only the completed real-PIM structural A&E result. The separate component review `deleg_cd672a31` was last reported IN_PROGRESS; this review neither silently accepts it nor waits for a stale handoff. The supplied accepted/published CSR milestone `cbefc1a91b1cb417906eb360fddf0f15f33a4407` and routing milestone `f9a860d` remain separate evidence; no git state was queried or changed here.

The productive next functional discriminator is F1, with F2/F3 retained before lifecycle/hardware acceptance. F4–F6 are targeted quality/archive improvements, not a new approval framework. Complete AHLS numerics through the connected path, both-DDR physical testing, host↔FPGA copies, full mapped/FIM/persona fit and STA, reset/PR signoff, actual image/host identity and durable boot remain unproved. No FPGA/MMIO/device/driver/programming/reboot action is authorized or implied. **Goal incomplete.**

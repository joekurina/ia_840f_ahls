# Independent review — matching Work21 PR/PIM release export

**Status: FINAL**  
**Bounded verdict: ACCEPT the completed export03 release-template generation WITH FINDINGS.**

The evidence supports a matching-Work21 vendor OFS out-of-tree PR/PIM template, preserved static-image/interface bindings, successful source-discovery Analysis & Elaboration (A&E), and successful restored-project callbacks. It does **not** establish a ready-to-run actual-persona build, persona synthesis/fit/STA, effective reset/freeze, runtime PR, or hardware function. The release-only authority has ended and must not be replayed. This result review is not an additional user-permission barrier and does not require an unchanged FIM/export rerun.

## 1. Specification first and review boundary

Read `SCOPE.md`, `RESULTS03.md`, historical `PREREQUISITES01.md`, both failure dispositions, and `../fim-build-21/RESULT-ACCEPTANCE.md` before evaluating the source/results. Preparation-era statements that generation or the guarded diagnostic review is pending are historical, superseded by the later results and supplied accepted diagnostic disposition. The independently/parent-accepted guarded diagnostic published as `c1e675730dc802bc8a0f999c4aa5b7d43ce81cf2` is not reopened here.

The required result is an export of accepted Quartus25.1 Work21, not another static-shell build. The acceptance criteria are: preserved Work21 and base artifacts; narrow, recorded copied-project changes; exact source/tool/PIM binding; bounded native ownership; retained failed attempts; matching template output and honest diagnostic scope. Those criteria are satisfied for export03 with the qualifications below.

Work21 acceptance remains exactly bounded to fit, assembly and reported constrained numerical STA with unwaived findings. Its resolved historical EMIF hold failure is not reopened. Full-FIM signoff/CDC coverage, PR memory/debug retention, initialization, electrical adequacy, mapped-path R1/R2, RAM attribution, effective freeze/global drain/fences/buffer lifetime, and all hardware acceptance remain open. Vendor DDR simulation is **SKIPPED BY USER**. Goal incomplete.

Review actions were local ordinary-file reads, hashing, JSON/base64/gzip parsing, source inspection and in-memory comparisons. Runner configuration was recovered using `ast.parse`/`ast.literal_eval`, not import or execution. No SSH, vendor/native/simulator/device tools, programming, MMIO, driver/reset/reboot operation, commit or push was performed. The sole authored file is this report; an early IN_PROGRESS version preceded this FINAL version.

## 2. Frozen evidence verification

Repository root: `/home/joe/Projects/Thesis/AHLS/new_bsp/new`. Paths below are relative to this qualification directory unless explicitly repository-relative.

| Check | Independently verified result |
|---|---|
| Frozen manifest | `review-package01.json` SHA256 **`0b4851ed642595be0bb3db9db3e97cbc615577a11a833f5cc8902c047a287fc0`** |
| Frozen members | **145 entries; 41,568,179 bytes; zero missing/size/hash mismatches** |
| export03 compressed result | `result-export03.json.gz`, 734,909 bytes, SHA256 **`6ec17215ca58ffd136418de08fb45ba1700a01887f84ea7b2d93afe06ad808b9`**; agrees with `outer-export03.json` |
| Embedded result payloads | All **9** decoded payloads independently checked for size, SHA256 and exact local `artifacts-export03/` bytes |
| Release boundary readback | All **15** `result-boundary01.json.gz` payloads independently checked against embedded size/hash, local `boundary03/` bytes and exact release-inventory entries |
| Release inventory | **4,936 file paths**, including file symlinks; `release-inventory03.json` equals the embedded result inventory |
| Original path-set closure | **7,598 unique original entries** exactly equal the later `result-closure02.json.gz` original path set; no additions/removals |
| Failed-attempt evidence | export01 and export02 archive SHA256/size receipts and all **6** and **9** decoded payloads, respectively, agree with their local artifacts |

The release root is the **captured remote** `/home/uwb_student00/ahls/new_BSP/work_fim21_pr_platform01/release03`. I did not contact it. Large QDB/SOF/MSF/PMSF identities are supported by hash-bound remote ordinary-file inventories and the captured runner's pre/post checks, **not a new local rehash of those large remote binary files**. The 15 boundary files and 9 result payloads were actually available locally and independently rehashed. This distinction limits the claim without defeating the result.

## 3. Preservation, stage identity and source deltas

### 3.1 Exact staged subset and fresh-attempt attribution

`stage-manifest01.json` records 7,598 original entries, 1,889,831,843 regular-file bytes, and a 5,727-entry selected candidate with 829,199,320 regular-file bytes. Programmatic set comparison verifies that the selected set is exactly the original set minus the six recorded exclusion prefixes (1,871 entries): `compile-candidate-01`, `compile-candidate-02`, `run`, and project-local `db`, `qdb`, `tmp-clearbox` directories. The exported root `ofs_top.qdb` is not the excluded working `qdb/` directory.

All selected ordinary files are byte-identical to the original staging inventory. The only initial link differences are the recorded `config_env.tcl` and `mem_ss.ip` absolute-link relocations. Parsing the export03 embedded stage manifest shows only `staged_root` and these two link targets changed from base01 to **base03**; the original inventory and selected file hashes are unchanged. `run-release03.py:7,19–32` requires absent base03/export03/release03 roots and copies selected files directly from original Work21, not failed export01/export02 directories.

The preserved native result reports all four preservation checks true: original Work21, PIM, measured tool entrypoints, and base images. Postflight errors are empty. The subsequent original path-set audit closes the earlier byte/link check's inability to detect additions. This supports the completed snapshot's preservation, not an OS-level isolation guarantee.

**Finding F1 — low, wording/provenance qualification:** `RESULTS03.md:12` says “no predecessor database reuse.” That is supported for **failed export-attempt databases**, not for absence of all inherited database state. The selected Work21 inventory contains **277 `dni/` entries**, including original elaborated checkpoint material; it is deliberately copied along with the exported static QDB. Native source discovery creates a fresh PID-attributed DNI sandbox and changes two pre-existing candidate DNI metadata files. Use the narrower wording “fresh attempt roots copied from accepted Work21; no failed export01/export02 database reuse.” Do not claim a pristine database-free input or rerun merely to establish one.

### 3.2 Packaging changes and native-written metadata

`artifacts-export03/run/source-delta.json` and `run-release03.py:34–56` declare **82 XML file relocations** plus five packaging/gate files: vendor script, PR QSF, copied QPF, added Tcl callback, and added Python callback. All 82 XML before hashes match the original inventory, and their recorded after hashes match the release inventory.

- The copied vendor script changes only its three `/tmp/${Q_PR_REVISION}.$$.qar` references to `${TMPDIR}/${Q_PR_REVISION}.qar`. Each attempt has a distinct exclusively created run TMPDIR. No force-target option is added; the native archive's `-force` flag is retained and is not a release-target deletion authorization.
- PR QSF replaces only its historical gate reference and adds `TEXT_FILE ../setup/ia840f_release_gate01.py` for archive closure. The original `build_gate.tcl` remains byte-preserved. Native export subsequently changes `LAST_QUARTUS_VERSION` from `26.1.1 Pro Edition` to `25.1.0 Pro Edition`; an exact local diff against the planned QSF finds **only this additional native metadata edit**. The final QSF SHA256 is `850604824eca4998c036d2a921bb646af1dd348bb6c2eced28dc7b6562613ee4` and matches both the candidate native-delta record and boundary readback.
- Copied QPF deletes only `PROJECT_REVISION = "ofs_top"`; exact comparison confirms the boundary QPF retains only `ofs_pr_afu`. Its legacy 26.1 version header is preserved history, not evidence that the active compiler was 26.1.
- Apart from declared edits, the recorded pre-existing candidate changes are `dni/checkpoints/manifest.txt` and `dni/sandboxes/.properties.folder.kvp`. Newly generated native files are expected; the candidate-delta map is not a complete postflight inventory of every newly added candidate file.
- Release inventory comparisons preserve the base QSF, original gate, warning-suppression Tcl, `fim_base_ip.tcl`, `fim_project_macros.tcl`, and exported `ofs_top.out.sdc`. All **49 common original/release files selected by `.sdc`, `fim_base_ip.tcl`, or `fim_project_macros.tcl` identity** match. The exported SDC SHA256 is `ccdd8bce2d6aa19aacfb96e1b17d8207bd00eccaaba9319f521fbaf157de27eb`.

The vendor script itself deliberately generates/rewrites release-side PIM and AFU import files (`capture01/.../generate_pr_release.sh:273–324,329–381`). Those generated outputs are not original-FIM edits. No declared source change edits HDL logic, IP numerical parameters, or binary QDB contents. Captured hashes and runner source support this statement; I did not reconstruct every XML postimage locally.

### 3.3 Remaining metadata paths and portability

**Finding F2 — medium for reuse/relocation, not a failed export:** success does not mean a fully portable/regeneratable full-FIM source bundle. The relocation code replaces only matching existing copied-tree paths, and `xml_unmapped` retains:

1. A combined `mem_ss.xml` search expression containing historical Work12 `/**/*`, a historical `/tmp/alt0715_2357079155904054191.dir/0012_packageGeneration/**/*`, donor `ipss/**/*`, and `$`.
2. Five unique `scjio_agilex.xml` references under `work_sld25_regeneration01`: output directory, `.ip`, top synthesis HDL, generated soft-core JTAG HDL, and SLD endpoint wrapper. The captured unchanged XML really contains those provenance/source paths; they are not evidence that the equivalent local release HDL is missing.

`path-audit02.json` also records historical vendor-install references, including 26.1.1 generation metadata, outside the runner's Work-root relocation pattern. Completed PR archive discovery/restoration is useful evidence for the exercised flow, **not proof that every dormant simulation/regeneration path is independent of those historical locations**.

Smallest next check: when configuring the actual persona, resolve its selected QSF/QIP/SDC/PIM dependencies against the derived build and bind the selected installed tools. Treat any newly activated XML regeneration path separately. Do not mass-rewrite XML, regenerate vendor IP, rebuild Work21, or run vendor DDR simulation to dispose of inactive provenance paths.

## 4. Native attempts, gates and finite ownership

| Attempt | Verified disposition |
|---|---|
| export01 | Exact archive-discovery context rejected; release leader/native/effective **−15**, outer **143**; no timeout, owned group empty, preservation true. Six retained payloads. |
| export02 | Native/effective **0**, outer **125**, result unsuccessful. Missing restored Python callbacks and restoration of the base-FIM revision triggered gate/BMC-local-source errors, including Critical Warning125091. Nine retained payloads. Populated release files and script rc0 were correctly not accepted. |
| export03 | Native/effective/outer **0**; complete/success true; no detected Error/Fatal/critical-warning diagnostics, no timeout, no remaining owned group, no postflight errors. Nine retained payloads. |

Installed captured `qpm-ccl-lib.tcl:824–855` selects source-discovery A&E and DNI; `qar.tcl:1810–1836` bypasses project-open failures during restore and iterates the restored QPF revisions. Those sources explain both failures and the specific packaging corrections. They do not justify an arbitrary invocation-context expansion.

Exact observed export03 command, including **both** `--dni` flags:

```text
quartus_syn --ipc_flow=4 --ipc_mode --read_settings_files=on --write_settings_files=off ofs_top -c ofs_pr_afu --dni --disable_all_banners --analysis_and_elaboration --dni
```

`release-contexts03.json`, parsed runner configuration and `artifacts-export03/run/authority.json` agree. The **six accepted callback events** cover prepare, archive opening, exact source-discovery invocation, **two restored-project openings**, and macro emission (five distinct observed contexts). Both restore events have PID116980/start13658956 and the release03 project cwd; no base-revision callback appears. Native synthesis PID116836/start13650606 agrees with the generated sandbox path. The gate calls require OPAE_PLATFORM_GEN=1, exact compiler path/hash, declared argv/cwd, and issued runner ancestry with PID/start/exe/cwd/argv. Restored Tcl/Python bytes match the configuration and boundary inventory. The original gate is not deleted or made permissive.

The supervisor (`run-release03.py:67–114`) uses a new process session, two allowed CPUs, **per-process** RLIMIT_AS16GiB, core limit0, and a600-second deadline per native command. It keeps the leader unreaped until owned-group termination work ends and checks for surviving owned processes. Preflight resource values and completed timestamps are in `result-export03.json.gz`; later captured `native_processes` is empty. These are bounded owned-process controls, **not aggregate memory accounting, a cgroup/OS sandbox, or proof against descendants deliberately escaping the group**. The four measured Quartus launch/runtime entrypoints and 276-entry PIM inventory are hash-bound; installed archive Tcl dependencies are checked before invocation, not a claim that the entire installation was exhaustively postflight-hashed.

The gate validates its original issued project/critical inputs; it is not a general future-project validator. Its export03 owner and release-only grammar cannot authorize actual persona compilation. Preserve this evidence and bind fresh persona scope in a derived build under the existing native-iteration process, rather than removing/bypassing the callback or requesting another result-review permission gate.

## 5. Native diagnostic quality and actionable disposition

### 5.1 What actually ran

`artifacts-export03/reports/ofs_pr_afu.flow.rpt:42,69,86` reports Flow Successful, **Synthesis (Analysis & Elaboration)** only, and the duplicated-DNI invocation. `ofs_pr_afu.syn.rpt:73–87` binds revision `ofs_pr_afu`, top `top`, Agilex7 and AGFB027R25A2E2V. Version log and reports agree on **Quartus25.1.0 Build129 SC Pro**. A generic “Synthesis Successful” banner or the flow's generic Compilation label is not mapped-persona synthesis or fit.

`capture01/.../afu_main.tcl:34–46` selects the template when the **environment variable exists**, and captured `port_afu_instances.sv:14–19,112 onward` excludes actual PIM/AFU implementation under OPAE_PLATFORM_GEN. The native report includes that macro. Generated PIM file construction occurs later in the vendor export script. Therefore the A&E reports do not establish elaboration/mapping of the final generated PIM plus guarded AFU.

### 5.2 Reconciled warnings

Independent anchored parsing finds exactly **73 explicit warnings** in the release log, and the same distribution in each of the two native synthesis reports. Repeated report/log copies are not additional warnings. Native archive summary also says0errors/73warnings (`release.log:844`).

| ID | Count | Evidence and disposition | Smallest relevant next check |
|---|---:|---|---|
|13461|1|`release.log:436`; `fim_pf_vf_nmux.sv:89–111` declares body parameter `M=(N==1)?1:$clog2(N)` after a module parameter-port list. Native treats it as localparam. **Source-explained language diagnostic**, not demonstrated truncation/function failure.|If this mux participates in the actual persona, check effective N/select width and any attempted M override; do not alter accepted FIM for this export warning.|
|24420|1|`release.log:533`; byte-bound `ofs_fim_pcie_dm_req_splitter.sv:298` has `/* synthesis ramstyle = "mlab", no_rw_check */` on `meta_ram`. **Retained mapping/pragma risk**: the diagnostic does not identify which pragma is invalid or prove effective RAM/collision semantics.|Use the actual persona's native effective assignment/memory mapping for this exact instance. Do not equate this with resolving or reopening accepted diagnostic R2 attribution, and do not silently rewrite/suppress the pragma.|
|21610|70|`release.log:535–604`, all in template `port_afu_instances`; **source-justified expected for OPAE_PLATFORM_GEN only**.12PCIe output/ready groups and29groups for each DDR bank are tied to ground. Counts are diagnostics, not bits.|Unset OPAE_PLATFORM_GEN completely for the actual AFU; merely setting it to0 still selects the Tcl existence branch. Require actual payload/reset/interface retention in the persona reports.|
|23762|1|`ofs_pr_afu.syn.rpt:11145–11152` identifies exactly one `fim_dup_tree`,7gates before sweep, at `afu_top|pg_afu.port_gasket|pr_slot|afu_main|rst_link[0].rst_p[0].dup_port_rst`. **Expected unused reset distribution in the empty template; not effective reset acceptance.** Byte-bound `afu_main.sv:350–366` identifies its reset-fanout role.|Verify the actual persona's reset consumers, reachability and freeze/drain requirements in its real FIM context; do not clear them from this sweep.|

No export03 missing-helper gate rejection, Error/Fatal line, or Critical Warning125091 is present in the independently parsed release log. Existing warning-suppression Tcl is unchanged; “73 explicit warnings” is **not** an unsuppressed whole-design defect count or a blanket waiver.

### 5.3 DRC and assignment coverage

Partitioned/elaborated DRC shows **0of10enabled rules failed**, zero violations and zero waived cells, including RES-10204 Reset Release Instance Count. `release.log:823` additionally states **one rule was disabled**; the summary does not identify it. `syn.rpt:97` says Design Assistant include-IP-blocks Off. These details matter: do not call this exhaustive/unrestricted DRC or full-FIM reset signoff.

**Finding F3 — medium acceptance boundary:** the native `Assignments with Invalid Source or Target` panel (`syn.rpt:11126–11142`) includes the three `REMOVE_DUPLICATE_REGISTERS` reset targets and root `QDB_FILE_PARTITION ofs_top.qdb`, all with Target Valid No at this stage. The panel explicitly warns that Fitter-created targets may appear here and directs users to Fitter's ignored-assignment report. This is neither proof that the preserved QDB is defective nor evidence of effective later import/reset-constraint consumption. The export proves **QDB presence, exact identity and PR import configuration**, not future Fitter consumption. Carry the panel into the actual persona fit/constraint review; no unchanged Work21 rerun is justified.

No new constraint exception/waiver or disabled-rule change is introduced by the declared packaging edits. The enabled-rule zero-waiver result must not erase the original Work21 signoff holds or be generalized to a guarded persona that was absent.

## 6. Image, interface, PIM and release-template usability

The release inventory agrees with staging/parent verification; the three image/mask records also agree with accepted Work21's `../fim-build-21/final-capture01/manifest.json`:

| Artifact in `hw/lib/build/syn/board/ia840f/syn_top/` | Bytes | SHA256 |
|---|---:|---|
|`ofs_top.qdb`|83,178,648|`7f8f25463afe3ae95d9660ddf4c5c6755d6704f828fd400de34ae38fa2aa0fc8`|
|`output_files/ofs_top.sof`|7,901,287|`bbede03c8c432e50ae6ae1f30739af3bfd3330781776d2c623269cc131b38ca4`|
|`output_files/ofs_top.static.msf`|3,309,305|`da2395b08b6713e6e4335b488f5757e052d583b44b908837e8d18747bb151705`|
|`output_files/ofs_top.green_region.pmsf`|7,202,780|`27b3e78810d54cf452dcc1aa834c62584290c9d3358e84f00a374294426a3663`|

Boundary `hw/lib/fme-ifc-id.txt` equals captured Work21 bytes: **`fc4bf1c1-760f-5cd7-8040-b3e86fa0d31e`**. Platform class is `ofs_agilex`.

All **three** symlinks recorded by the closure collector resolve inside the captured release: `bin/run.sh -> afu_synth`, `hw/blue_bits/ofs_top.sof -> ../lib/build/syn/board/ia840f/syn_top/output_files/ofs_top.sof`, and the directory link `hw/lib/build/quartus_proj_dir -> syn/board/ia840f/syn_top`. The directory link is not an extra entry in the4,936file-path total. This symlink check does not establish absence of external references in text metadata.

The boundary proves a PR_IMPL QSF, exact device/root-QDB assignment, preserved macros/base-IP/SDC imports, PIM addenda import, and generated `afu_with_pim/afu.tcl` that expects the AFU-specific `hw/afu.qsf` supplied by setup. `bin/afu_synth` is the vendor full persona flow, not a command executed during this review or this export. The base QSF remains as a preserved file but is intentionally not a QPF revision advertised as rebuildable from an AFU-only archive.

Generated `ofs_plat_if_top_config.vh:45–86` selects native PCIe-TLP host channels and native-AXI local memory. Host `ADDR_WIDTH=51` is **line-level**, corroborated by hash-bound PIM `defaults.ini:55–56`; it is not a demonstrated51-bit byte IOVA path. Local-memory address/data/burst/user/ID widths derive from the imported `ofs_fim_mem_if_pkg` expressions, and generated macros preserve two DDR groups/local memory/PR/remote-STP feature identity. No live routing or numerical transfer is established.

**Finding F4 — medium future-build prerequisite:** captured `/usr/bin/afu_synth_setup`, `afu_json_mgr`, `afu_platform_config` and `packager` are path/entrypoint-byte identities only. Their underlying Python packages/APIs and compatibility have not been proven. Bind those selected packages, exact accepted guarded AFU inputs and fresh persona authority in a derived project before actual persona compilation. Preserve the static images and do not inherit OPAE_PLATFORM_GEN or replay the spent release-only gate. This is the existing next execution boundary, not rejection of export03.

There is **no `.done` file and no persona `.gbs`** in the release inventory. Complete native receipts/reports and output bindings establish this export; a historical marker expectation must not be fabricated or imposed through an unchanged rerun. No new programming image was produced. Copied SOF/PMSF/MSF and a retained green-region RBF elsewhere are not a qualified persona deployment payload.

## 7. Actionable disposition

1. Consume this as **FINAL acceptance of export03 template generation with the above findings**, without changing the frozen package or closing persona/full-FIM/hardware tasks.
2. In the next parent checkpoint, narrow the no-predecessor-database wording to failed-export-attempt reuse; retain the inherited Work21 DNI facts, native QSF version-only delta, one-disabled-rule detail and invalid-target panel scope. This report already records the qualifications; no native rerun is needed to improve that wording.
3. Continue the existing actual-persona integration path: fresh derived build/authority, exact PIM and installed-package bindings, OPAE_PLATFORM_GEN absent, dependency closure for selected sources, and native retention/import/fit/timing checks. Retain R1/R2 and reset/freeze/drain/visibility findings until the corresponding evidence exists.
4. Keep Work21 signoff/CDC/electrical/PR-initialization findings unwaived and all live FPGA/MMIO/programming/driver/reset/reboot actions outside this result review. VendorDDRsimulation remains SKIPPED BY USER. No tasks are marked closed.

## Appendix — supplemental local source bindings

These read-only sources lie **outside the145-member frozen review package**. Their bytes were independently hashed and matched to `stage-manifest01.json` original-file identities or the pinned PIM inventory before using them for warning/path attribution. Paths are repository-relative:

| Source | SHA256 |
|---|---|
|`ofs-agx7-pcie-attach/ofs-common/src/common/lib/mux/fim_pf_vf_nmux.sv`|`0d2ba9362954cde619337c4a2b6945a0e555c517941a7f62bfeeb39fb63f6265`|
|`ofs-agx7-pcie-attach/ofs-common/src/common/lib/pcie_shims/pcie_dm_req_splitter/ofs_fim_pcie_dm_req_splitter.sv`|`017bcc5f3f780bd57f2f48aed49178a20bc3060ddbe6d88469045ceaaebf2b0e`|
|`ofs-agx7-pcie-attach/ofs-common/src/fpga_family/agilex/port_gasket/afu_main_std_exerciser/fim_compile/afu_main.sv`|`ea02940bc34e6fa33e142e429bbb0df8db893239880c8e15ba6039751bfe8e1c`|
|`ofs-agx7-pcie-attach/syn/shared_config/suppress_warning.tcl`|`44c5f7c4115342c24a24ab00f0ff004a2d24cb6887b24c35bd3569eade7f0084`|
|`qualification/sld25-regeneration01/generated01/scjio_agilex/scjio_agilex.xml`|`7590d15be2784456ae7b12d3d8bb5c809526d021f2dc460c2a49ca502ed52062`|
|`ofs-platform-afu-bbb/plat_if_develop/ofs_plat_if/src/config/defaults.ini`|`62c3ce4e60b230d035f72eada3f8b90020e3d15a3a24c666e1f1449039e87d77`|

The final report SHA256 is supplied separately to avoid a self-referential hash claim.

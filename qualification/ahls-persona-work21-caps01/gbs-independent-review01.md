# CAPS01 GBS01 — independent completed-result review

**Status: FINAL**

**Recommendation: ACCEPT WITH FINDINGS, limited to completed native offline GBS01 packaging and artifact readback.** Specification compliance passes. The captured acquisition and independently checked container are sufficient for this narrow acceptance; no blocking packaging discrepancy was found. This is a recommendation to accept evidence, not execution permission, assembly acceptance, deployability approval, or full design/hardware signoff.

## 1. Specification FIRST — scope and frozen identity

Read `GBS-SCOPE01.md` before `GBS-RESULTS01.md`. The controlling boundary is offline installed `/usr/bin/packager` help/create-gbs/gbs-info/get-rbf, source-derived CLI applicability, input/tool/preservation bindings, and exact container readback. Existing source/unit/build evidence is reused. No synthesis, fit, STA, assembly or hardware qualification was repeated. [GBS-SCOPE01.md:3–9; GBS-RESULTS01.md:3–11]

All paths below are relative to `/home/joe/Projects/Thesis/AHLS/new_bsp/new/qualification/ahls-persona-work21-caps01` unless explicitly absolute. Abbreviations for exact captured source locations:

- **P** = `gbs-prerequisites01/usr/lib/python3.9/site-packages/packager`.
- **A** = `gbs-prerequisites01/home/uwb_student00/ahls/new_BSP/work_ahls_persona_work21_caps01/asm01/persona/build/syn/board/ia840f/syn_top`.
- **J** = `gbs-prerequisites01/home/uwb_student00/ahls/new_BSP/work_ahls_persona_work21_caps01/setup01/afu_sources/ia840f_ahls_memory.json`.
- **G** = the recorded remote output/cwd `/home/uwb_student00/ahls/new_BSP/work_ahls_persona_work21_caps01/gbs01` (not accessed remotely by this reviewer).

### Frozen package validation

Independently SHA256-checked the manifest and every listed local member: **203 files, 447,412,702 bytes, zero size/hash mismatches**. The manifest contains no mutable CURRENT or sibling assembly-review artifact; neither was inspected. Hashing prior evidence for identity is not re-reviewing its timing/reset conclusions.

| Binding | SHA256 |
|---|---|
| `gbs-review-package01.json` | `6103674292a98c06e7a736680479c4d4553c25bbf278c8e55fd220fd7c0915e8` |
| `run-gbs01.py` | `04425803113697b50f5976a7d249cd802fb7d5073d8cccfbde88a38f5fa805e1` |
| `run-gbs01.py.in` | `96bcc58b63a6c50b302244023ed028a5c6867fc2d63a750e079092da0ca723a1` |
| `result-gbs-prereq01.json.gz` | `4cd59ee35bb9b97f6e75d92642de8ba00dce9e459391a55c43d74549591b3a2a` |
| `result-gbs01.json.gz` | `957e24b46a41918c5a7f91ae942f4b2c7728e3dee859bfbde7cb622a488599a7` |
| predecessor `result-asm01.json.gz` | `6e59dcf930e814b09106ef4710d2c67327700a9fe4ef87193608b75b1c3430f2` |

The expanded runner was parsed with AST and its `C` assignment read with `ast.literal_eval`, never imported or executed. It is byte-for-byte the template with its exact configuration literal substituted. Its digest matches `dispatch-gbs01.json.embedded_runner_sha256`. The predecessor digest matches the actual assembly archive, prerequisite receipt, runner configuration and completed result. `outer-gbs01.json` matches the actual 6,574,952-byte GBS result archive and records outer rc0.

### 1.1 Source-derived applicability — PASS

`asm-prerequisites02/files/ofs_partial_reconfig/gen_gbs.tcl:89–120` derives the RBF from the PR revision/partition, the interface UUID from the FME build environment, and clock overrides from `output_files/user_clock_freq.txt`. Lines108–123 construct and execute `packager create-gbs --gbs=… --afu-json=… --rbf=… --set-value interface-uuid:…` followed by those clock settings. The GBS prerequisite copy has the same SHA256 `b012ad8ae74a5cf79b8d50716a780cff807a320a1ae4dfec653e2469e020e21b`.

The recorded direct CLI implements **that packaging operation** using exact copied inputs and a new output location. It does not claim execution of the full Tcl script, which opens a project at line79, or the full `afu_synth`/recompile flow. No native project reopening is needed to establish the observed software-container transformation.

The installed console script selects `/usr/bin/python3.9` and `packager.tools.packager.main`. The inspected branch dispatches creation to AFU/GBS, info to GBS printing, and extraction to GBS file writing. The unrelated version branch's Git calls were not selected. AFU loads the adjacent installed schema, applies hierarchical/legacy UUID overrides, converts clock values to native integers, adds default magic, and serializes JSON plus RBF. The schema contains no `$ref`. No libOPAE/device operation appears in this selected source chain; this is not a complete dynamic-dependency or syscall proof. [Captured `usr/bin/packager:1–8`; P/`tools/packager.py:78–115,163–195`; P/`utils/afu.py:40–42,65–76,97–180`; P/`utils/utils.py:52–72`; P/`schema/__init__.py:28–31`; P/`schema/afu_schema_v01.json:1–42`; P/`utils/gbs.py:59–73,98–115,121–132,147–175`]

### 1.2 Exact input and interface chain — PASS

All five configured input records equal the prerequisite receipt. Their available local captured bytes independently match sizes and hashes. All five also match the finite assembly input/output preservation map, including the PR RBF as an assembly output rather than a pre-assembly input.

| Explicit input | Bytes | SHA256 |
|---|---:|---|
| completed persona `ofs_pr_afu.green_region.rbf` | 9,527,296 | `25feda96e98155e39edc4e9188f70a1eb17dc1470f8b1525793bbb4d5d36b7e1` |
| A/`output_files/user_clock_freq.txt` | 133 | `f5ed24d88af0253192249260b91cf463d7fbdfe382e695a7d2a2c6030e2c3c71` |
| A/`build_env_db.txt` | 358 | `cd70202b481da9f56deab32123b9fc6bba5f6aeff01e37a985eafb7992814372` |
| A/`ofs_partial_reconfig/gen_gbs.tcl` | 3,786 | `b012ad8ae74a5cf79b8d50716a780cff807a320a1ae4dfec653e2469e020e21b` |
| J, original AFU JSON | 391 | `5deaf1592fcf4fba303cee357488aba5b11acb99dd5bc40e5d60f884ebcf816f` |

The environment specifies `Q_PR_REVISION=ofs_pr_afu`, `Q_PR_PARTITION_NAME=green_region`, and `FME_IFC_ID=fc4bf1c1-760f-5cd7-8040-b3e86fa0d31e`. The clocks are exactly low100/high200. The same clock-file digest occurs in the completed CAPS01 STA and assembly exports. J retains `auto-200`/`auto-100`, class `ofs_plat_afu`, and AFU UUID `673c03a1-cef3-4c82-bf10-b12c247d9718`; the setup-exported JSON and generated AFU header agree. No live image was authenticated and no hardware frequency was measured. [A/`build_env_db.txt:9–11`; A/`output_files/user_clock_freq.txt:1–3`; J:1–18; `artifacts-setup01/persona/hw/ia840f_ahls_memory.json:1–18`; `artifacts-setup01/persona/hw/afu_json_info.vh:8–13`; `result-gbs-prereq01.json.gz.input_records`; `result-asm01.json.gz.input_hashes/output_hashes`]

### 1.3 Permitted transformation and strict readback — PASS

Independently parsed the actual local exported GBS using only standard-library byte/struct/JSON operations, not the runner or vendor parser. Checked exact header, little-endian length, in-bounds nonempty metadata and payload, strict UTF-8, duplicate-key rejection, nonfinite-number rejection, complete metadata equality, integer clock/magic types, and every payload byte against the captured assembly RBF. Also reconstructed the exact source-described serialized container in memory and compared every byte.

| Region | Independently verified value |
|---|---|
| identifier bytes `[0,16)` | `58656f6e46504741b747425376303031` = `XeonFPGA\xb7GBSv001` |
| length bytes `[16,20)` | `73010000`, unsigned little-endian371 |
| metadata bytes `[20,391)` | 371-byte valid JSON |
| payload bytes `[391,9527687)` | 9,527,296 bytes, identical to the current persona PR RBF |
| complete container | **9,527,687 bytes** |
| GBS SHA256 | **`d3cd6dc5ee21dc921fe121eee726b07fd5196570ec96d6308a0df2eba9d92dbc`** |
| payload SHA256 | **`25feda96e98155e39edc4e9188f70a1eb17dc1470f8b1525793bbb4d5d36b7e1`** |

The entire metadata object equals the unchanged original JSON with **only** these transformations:

- `afu-image/clock-frequency-high`: string `auto-200` → integer `200`.
- `afu-image/clock-frequency-low`: string `auto-100` → integer `100`.
- Add `afu-image/interface-uuid`: `fc4bf1c1-760f-5cd7-8040-b3e86fa0d31e`.
- Add `afu-image/magic-no`: integer `488605312` (`0x1d1f8680`), the installed AFU default, not an undocumented manual override.

Version1, power0, interface class, accelerator name, context count1, AFU UUID and all other fields are unchanged. There are no extra bytes outside the exact expected header/metadata/payload construction. Native `gbs_info.log` parses to this same whole object. [P/`metadata/constants.py:27–36`; P/`metadata/metadata.py:36–54`; P/`utils/afu.py:123–180`; `artifacts-gbs01/ofs_pr_afu.green_region.gbs`; `artifacts-gbs01/gbs_info.log`; `artifacts-asm01/persona/build/syn/board/ia840f/syn_top/output_files/ofs_pr_afu.green_region.rbf`]

## 2. Acquisition/implementation quality SECOND — ACCEPT WITH FINDINGS

### 2.1 Actual invocation, completion and cleanup

The exact recorded command sequence matches the source-derived runner/configuration:

```text
/usr/bin/packager create-gbs --help
/usr/bin/packager create-gbs --gbs=G/ofs_pr_afu.green_region.gbs --afu-json=G/afu.json --rbf=G/persona.rbf --set-value interface-uuid:fc4bf1c1-760f-5cd7-8040-b3e86fa0d31e afu-image/clock-frequency-low:100 afu-image/clock-frequency-high:200
/usr/bin/packager gbs-info --gbs=G/ofs_pr_afu.green_region.gbs
/usr/bin/packager get-rbf --gbs=G/ofs_pr_afu.green_region.gbs --rbf=G/extracted.rbf
```

Here `G` expands literally to the absolute path defined in §1; recorded argv contains that full path, not an environment-variable token. The bound launch implementation sets cwd=G, uses an argument list rather than a shell, and supplies a restricted explicit environment with fresh HOME/TMPDIR, `/usr/bin:/bin`, `PYTHONDONTWRITEBYTECODE=1`, and `PYTHONNOUSERSITE=1`. This is source-bound launch evidence, not an independently captured complete executable/library runtime trace. [Actual `run-gbs01.py:5,27–36,54–60,88–94`; `result-gbs01.json.gz.commands`]

| Command label | PID / start ticks | Native rc | Effective rc | Timeout | Live owned group after |
|---|---|---:|---:|---|---|
| help | 148222 / 16565149 | 0 | 0 | false | empty |
| create_gbs | 148223 / 16565166 | 0 | 0 | false | empty |
| gbs_info | 148224 / 16565193 | 0 | 0 | false | empty |
| get_rbf | 148225 / 16565210 | 0 | 0 | false | empty |

Native command interval: **2026-09-23T22:26:19.733654Z–22:26:20.587448Z**; result postflight ended22:26:22.982471Z. All four records also have empty descendants-at-leader-exit and `descendants_after_leader=false`. Outer rc is0. `complete` and `success` are true, with no recorded error, timeout, survivor, diagnostic or postflight error. The four complete logs independently contain no Error/Fatal (including qualified forms) or traceback diagnostic; creation/extraction logs name the intended output files. [Result `.commands/.complete/.success/.diagnostics/.postflight_errors`; `outer-gbs01.json`; `artifacts-gbs01/{help,create_gbs,gbs_info,get_rbf}.log`]

The runner reserves G exclusively before copying the exact RBF/JSON; the prerequisite capture also requires G absent. It uses all36 recorded allowed CPUs, a64GiB per-process address-space limit and a120-second per-command deadline, with no competing enumerated native jobs in preflight. It supervises the owned process group while retaining the unreaped leader before any possible signals, allows helpers to drain inside the deadline, and records native/effective status separately. Final acceptance explicitly includes all four preservation flags, empty postflight errors, complete readback, four zero effective codes and no diagnostics. These are completed-run observations plus static source inspection, not a new generic runner qualification. [Capture `capture-gbs-prereq01.py:6,10–24`; runner:5–27,37–86,95–117; result `.resource_preflight`]

### 2.2 Finite bindings and preservation

- **22 installed tool-file records** match exactly between the prerequisite receipt and the runner configuration. The console entrypoint and its Python3.9 launcher are explicitly bound. Fourteen tool-source/schema files have locally hash-verified byte exports; eight entries, including the Python binary and unused test/JSON-manager files, are hash/size records rather than locally exported bytes. The prerequisite's eighteen total byte exports comprise those fourteen files and four small explicit inputs; all eighteen were base64-decoded and independently matched to their on-disk captures. The RBF is available through the assembly export.
- **5 explicit inputs** are verified as in §1.2. Copies of JSON/RBF are made only inside the new G leaf. Their equality and the originals' hash preservation are checked after the native operations.
- **5,770 preserved assembly critical/output bindings** were reconstructed independently:5,762 assembly input-hash entries plus15 captured output entries, with7 identical overlapping entries. The resulting path→SHA256 map equals the runner configuration exactly, with no silently changed overlap. Of these bindings5,500 are within the assembly root and270 outside it. This verifies the stated finite map, not every possible file on the workstation.
- Completed `inputs_unchanged`, `tools_unchanged`, `assembly_unchanged` and `copies_unchanged` are all true; `postflight_errors=[]`. The code invokes the actual bound-map checks both before and after, and separately checks the predecessor archive. No broad all-files/OS containment claim follows from these flags. [Runner:7–15,28–35,102–112; config at line5; prerequisite `.tools/.input_records/.files`; assembly `.input_hashes/.output_hashes`; GBS result preservation fields]

### 2.3 Export and readback quality

All **five** result exports were independently base64-decoded, size/SHA256-checked and compared byte-for-byte with their local files: help666bytes, creation105bytes, info550bytes, extraction91bytes and GBS9,527,687bytes. The compressed archive matches the outer receipt. The separate parent-verification record agrees, but the container/metadata/payload conclusions above were recomputed rather than accepted from its booleans.

Native extraction equality is supported by the actual zero-return get-rbf command, its complete output log, and the hash-bound runner's exact `(G/extracted.rbf).read_bytes()==source_rbf` assertion before setting `complete` and `native_extraction_equal`. **The extracted RBF itself is not one of the five exported files.** This review therefore distinguishes receipt-backed native extraction equality from its own direct full-byte comparison of the exported GBS payload with the exported assembly RBF. The latter independently verifies the actual packaged payload without another native run. [Runner:94–100,107–113; result `.container/.files`; `gbs-parent-verification01.json`]

## 3. Findings, retained limits and final disposition

**Q1 — finite provenance/containment boundary; nonblocking for offline artifact acceptance.** The22 bindings are not exhaustive dynamic Python/jsonschema/shared-library closure. Local review directly rehashes the exported package and sources; remote-only tool and5,770-path preservation facts remain backed by the captured hash-bound checks, not a new live audit. There is no OS sandbox, complete syscall trace, cryptographic image authentication or hardware-compatibility proof. The source-selected call chain is file-only; do not turn that into a universal claim about arbitrary library code or workstation state.

**Q2 — native extraction evidence granularity; nonblocking.** Native extracted-byte equality is a completed runner assertion/receipt, not a separately exported extracted-file comparison by this reviewer. Independent strict parsing and full equality of the actual exported GBS payload provide a separate check of the accepted artifact. Do not describe this as a new local execution of get-rbf. No unchanged native rerun is requested for this distinction.

**Q3 — inherited design/hardware limitations remain; outside packaging acceptance.** Reuse `STA-ACCEPTANCE.md:7–18` rather than reopening its full analysis. It accepts bounded final STA acquisition WITH FINDINGS and reports numerical constrained-domain results; **DesignClosure remains FAIL:22/88 enabled signoff rules failed,10 disabled,0 waived**, with unconstrained I/O and missing timing categories. All retained electrical, reset/CDC/initialization, synthesis, metadata/status/clock-reporting, freeze/drain/fence, PR handoff and buffer-lifetime findings remain. Packaging's numeric200/100 metadata does not clear the separate clock400/status metadata finding. Vendor DDR simulation remains **SKIPPED BY USER**.

Assembly's independent acceptance is separate and was in progress at the frozen handoff. This review neither reads its sibling review nor changes its disposition. It grants **no GBS deployability, runtime PR, live OPAE/PCIe/DDR, programming, MMIO, numerical hardware, reset/recovery, reboot or durable-boot acceptance**. A matching recorded interface UUID does not prove that any live shell matches it or that loading is safe.

**Final bounded recommendation:** accept this exact GBS as a correctly acquired offline container of the captured CAPS01 persona PR RBF with the exact source-supported metadata delta, retaining Q1–Q3. No packaging correction, unchanged native rerun, generic execution gate or task transition is requested. Parent consumption of this report is separate from this recommendation.

Review method remained local-only source/report reading, hashing, AST/literal decoding, gzip/base64 decoding and binary/JSON parsing. No runner/vendor code was imported or executed, and no native tool, simulator, Git, network/SSH or hardware operation was invoked. The only intentionally authored project artifact is this report, first IN_PROGRESS and now FINAL. Its final SHA256 is returned separately to avoid a self-referential digest.

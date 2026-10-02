# Source/API review07 — PASS with limits

**PASS for the first-fit SOURCE/API basis only.** No SOURCE blocker found. This is not execution QUALITY, authority issuance, physical acceptance, or permission to open the current project. Reviewer: GPT-6 (`gpt-6-astra-900k`), provider `openai-codex`, substituting for unavailable GLM-5.3.

## Evidence and verification

Independently verified **66/66 frozen members**, each exact byte count and SHA256, with zero mismatches. Freeze SHA256: `ba3f0de514b4c9721f824cca781c4b8a6db494e404369bd9ee557587a7dc3eb0`. The six explicit `../fim24-caps03-implementation01/` members are predecessor acceptance/basis evidence, not accidental scope escapes. Decoded and verified the four result packages, their exported readbacks, dispatch/collection identities, script hashes and successful receipts. Only local reads, hashes, JSON reductions and Python AST inspection were performed; no project imports, Tcl, tests, CMake, vendor tools, remote operations, Git or hardware execution. [Freeze06](source-api-freeze06.json)

Independently reconstructed all 32 copy-metadata fields using basis34, the hash-matching predecessor admission and preserved receipts; reconstructed the proposed QSF patch and complete role map separately. Remote database bodies were not locally rehashed: this review verifies the captured preparation evidence, not present remote-host state. The mapped stage remains accepted with findings; unchanged logic needs no resynthesis. [Acceptance36](../fim24-caps03-implementation01/SYNTHESIS-ACCEPTANCE36.md), [consumption35](../fim24-caps03-implementation01/result-reviews-consumed35.json), [copy03](copy03-readback/prepared-copy03.json)

## Actual fresh copy and proposed delta

Copy metadata SHA256 is `8606a19ffab26f23caa5b8ee23bb51ecfab0aa3bdcc3e96898c30b5b5af818c5`. Its inventory reconstructs exactly from the accepted completed tree: **3894 entries, 648,172,944 regular-file bytes**, including all 608 QDB members and the imported static QDB. Only two internal symlinks' resolved-path metadata changes with the new root; link text and target bytes remain unchanged. The external AFU-JSON symlink is unchanged. External/setup/release/archive maps match the predecessor admission, and copy receipts record their preservation plus preservation of the original completed synthesis. No binary relocation or functional rewrite is proposed. [Basis34](../fim24-caps03-implementation01/physical-copy-basis34.json), [producer03:44–85](prepare-copy03.py#L44-L85), [receipt03](copy03-collection.json)

The exact regenerated unified diff equals [qsf-delta05.patch](qsf-delta05.patch): only the two gate references change to `build_gate_physical08.tcl` and `ia840f_physical_gate08.py`. Device, NUM_PARALLEL_PROCESSORS36, seed1, PR_IMPL, green partition, root QDB import, optimization settings and source/SDC assignments are unchanged. Both old gate files remain protected. The actual copied QSF still selects the spent persona09 gate; neither replacement gate exists in this starting inventory. **Do not open this project before fresh controls are implemented, reviewed and admitted.** [Candidate QSF](candidate05/ofs_pr_afu.qsf), [plan05](source-plan05.json)

## Current role boundary

Independently classified every current path, then compared bindings, roles, partition union and disjointness against [roles05](input-output-roles05.json):

| Class | Entries | Runtime treatment |
|---|---:|---|
| Sources/configuration/static artifacts | 2688 | Immutable |
| Partitioned/synthesized snapshots | 67 | Immutable |
| QDB temporary HDL/source snapshots | 276 | Immutable |
| DNI checkpoints/bookkeeping | 590 | Enumerated native-output roles |
| QDB reports/cache/manifests/import materialization | 265 | Enumerated native-output roles |
| Persona reports | 7 | Enumerated native-output roles |
| QPF | 1 | Separately constrained metadata |

Thus **3031 immutable + 863 runtime-byte-output entries = 3894**. All 99 clearbox source files and three inherited static image artifacts remain immutable. The 67 mapped/partitioned members plus standalone `ofs_top.qdb` give 68 protected snapshots. The 265-entry class contains 229 imported `root_partition`/`auto_fab_0` final-materialization entries and 36 report/bookkeeping entries; it does not exempt green-region snapshots or source payloads. [Roles05](input-output-roles05.json), [preparation basis34](../fim24-caps03-implementation01/physical-preparation-basis34.json)

This finite current-copy partition is adequate for a **controlled first-fit experiment**, not proof of an unexecuted fit. It neither reuses the historical 1133 exclusions nor permits blanket directory exemptions. Bind all 3894 entries before launch; retain the immutable subset during execution and inventory new outputs afterward. Adding the two gates yields 3896 active/3033 critical entries. Preserve the entire completed original independently. QPF requires raw before/after capture, unchanged `QUARTUS_VERSION = "26.1"`, sole `PROJECT_REVISION = "ofs_pr_afu"`, and only date/comment variation—not arbitrary metadata replacement. [QPF](copy03-readback/project/ofs_top.qpf), [roles05](input-output-roles05.json)

## CMake/API and stage limits

[Candidate CMake](candidate05/CMakeLists.txt) pins `/opt/altera/26.1.1/quartus` and the exact fresh project:

`/home/uwb_student00/ahls/new_BSP/work_fim24_caps03_physical01/base01/build/syn/board/ia840f/syn_top`

It exposes only `version` and `fit`, without `ALL`, synthesis, STA or assembly targets. Wrong paths and missing QSF/static-QDB/qdb-directory are rejected by source inspection. These existence checks are not database-content validation; full inventory binding belongs to the forthcoming controls. The bin launcher and planned native `linux64/quartus_fit` are both hash-bound. Exact fit arguments are:

`--read_settings_files=on --write_settings_files=off ofs_top -c ofs_pr_afu`

Installed help01/02 records 26.1.1 Build130, all CMake/effective statuses zero and vendor-target statuses zero; configure invokes no vendor tool. AST-extracted tool maps equal the current 14-entry map: the original eight plus six fit/STA/assembler launcher/native bindings. Every future context must resolve against that actual map, not a historical subset. [Help01](help01-result.json.gz), [help02](help02-result.json.gz), [fit help](help01-readback/fit_help.log)

Read-on explicitly gives QSF assignments precedence over database assignments; write-off avoids command-line-assignment writeback. It is not a universal no-write guarantee. Help establishes syntax, not project-load or fit success. Later STA snapshot/multicorner/report options are observations only, not authorization or complete timing coverage. [Read option](help02-readback/fit_read_settings_files.log), [write option](help02-readback/fit_write_settings_files.log)

The 490,165-byte flattened SDC and PIM loader/helper chain remain unchanged. `user_clock_freq.txt` is a generated output, absent initially; its helper attempts deletion in fitter context. STA reporting and GBS post-flow hooks remain collateral, outside these targets. This does not relax the application/EMIF 3.000ns target or establish realized clocks. [Source chain](copy03-readback/project/ofs_pr_afu_sources.tcl), [clock helper:130–207](helpers04-readback/build/platform/ofs_plat_if/par/user_clock_config.tcl#L130-L207), [scope05](SOURCE-SCOPE05.md)

## Preconditions for the parent

Bind the exact reviewed delta, new controls, full/critical inventories, external inputs, originals and every executable context before issuance. Fresh owner/ancestor validation, early rejection and supervision remain separate implementation/QUALITY work, not defects in this unimplemented SOURCE package. Retain 36 CPUs, 64GiB **per-process**, 60/60/10800-second configure/version/fit deadlines and the 32MiB **polled** log threshold; claim neither aggregate isolation nor a hard filesystem quota. [Plan05](source-plan05.json)

Actual fit must establish root/import/PR physical preservation for20580; native green “Reconfigurable” is insufficient. Carry19854's 73 power-up rows and DRC5/13 failed rules,15 violations, seven disabled rules without waiver. Require subsequent physical review and separate multicorner STA/reset/CDC/electrical acceptance before assembly or hardware. Keep originals and spent claims intact; readiness and authority remain false. [Acceptance36:13–27](../fim24-caps03-implementation01/SYNTHESIS-ACCEPTANCE36.md#L13-L27)

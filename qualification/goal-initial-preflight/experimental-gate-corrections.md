# IA840F experimental gate corrections — complete local report

## Outcome and scope

**Local corrections and regression verification PASS. Vendor integration remains untested.** The final suite passes 23 tests, including executed negative native Bash entry paths, retained PCIe identity checks, and corrected positive policy fixtures. Seven native scripts also pass explicit `bash -n`. Real source inventory traversal passes and includes the selected IOPLL configuration. No remote access or vendor tool was executed, including help/version probes. No authorization was issued; source authorization record is absent. `ready_for_build` remains false, and single-run/no-bootstrap restrictions remain enforced.

Local root: `/home/joe/Projects/Thesis/AHLS/new_bsp/new`.

C in the task was a placeholder; the actual local checkout is `ofs-agx7-pcie-attach`, not a literal `C` directory. This downloaded source tree is not a Git repository (`git status --short` returned fatal: not a git repository). No commits were made. Initial lookup of a literal C path found no file; discovery resolved the actual local path before edits.

## Exact changed-file list

Relative to the local root:

1. Modified `ofs-agx7-pcie-attach/ofs-common/tools/ofss_config/ia840f_experimental_gate.py` — corrected exact command grammar, dependency coverage, runtime ELF identity and header permission.
2. Modified `ofs-agx7-pcie-attach/ofs-common/tools/ofss_config/test_ia840f_experimental_gate.py` — updated fixtures and added eight regression tests (23 total).
3. Modified `qualification/goal-initial-preflight/experimental-gate-implementation.md` — reconciled contract, exact commands, inventory/tool requirements and integration limits.
4. Created `qualification/goal-initial-preflight/experimental-gate-corrections.md` — this complete report with real final command outputs.
5. Modified `ofs-agx7-pcie-attach/ofs-common/tools/ofss_config/gen_ofs_settings.py` — shebang only, python to python3, preserving the prior native guard.
6. Modified `ofs-agx7-pcie-attach/syn/board/ia840f/README.md` — removed obsolete schema/missing-preset/mandatory-host-pipe claims; distinguished schema evidence from actual acceptance.
7. Modified `ofs-agx7-pcie-attach/syn/board/ia840f/config/ia840f.ofss` — comments only; no selection/parameter changes.
8. Modified `ofs-agx7-pcie-attach/syn/board/ia840f/config/ia840f_pcie_vendor_source.ofss` — comments only; no parameter changes.
9. Modified `docs/vendor-integration-status.md` — corrected current gate description and marked earlier unconditional-rejection/restriction statements as historical; preserved acceptance caveats.

No native shell/Tcl file required modification. No BMC source, board configuration parameters, PCIe helper, shared manifest, prior test log, proposal, or prior changed-hash receipt was changed. The later explicit user scope extension authorized board documentation/OFSS comment changes only. The parent owns refreshing shared deployment receipts after review.

## Corrections and native evidence

### 1. Required native PIM macro emission

`ofs-common/scripts/common/syn/build_fim_setup.sh:323` invokes PIM setup. `.../pim/ofs_pim_and_afu_config.sh:63-69` changes to WORK_SYN_TOP_PATH and executes the source-tree macro emitter with mode txt and an output obtained by replacing the PIM INI suffix with `.macros`. `syn/scripts/build_var_setup.sh:260` sets that INI under WORK/src/top. The gate now permits only the exact `pim_macros` context below, still subject to setup permission, record/claim, project CWD, actual ELF/hash and complete argv checks. Alternate scripts, revisions, output paths, modes, missing/extra/reordered arguments and wrong tool reject.

### 2. Selected source and PIM dependency closure

Added the entire `tools` tree to the required source inventory. The real selected root OFSS is `syn/board/ia840f/config/ia840f.ofss`; its dependency closure comprises that file and:

- `syn/board/ia840f/config/ia840f_base.ofss`
- `syn/board/ia840f/config/ia840f_pcie_vendor_source.ofss`
- `tools/ofss_config/iopll/iopll_470MHz.ofss`
- `syn/board/ia840f/config/ia840f_memory.ofss`

A regression walks the actual [default]/[include] closure, checks that every path is within an inventoried tree, rejects unresolved variable expansion, and confirms all five selected files, including IOPLL. `syn`, `src`, `ipss`, `ofs-common`, and `tools` are all checked as full inventories; old four-tree records reject. Tests independently mutate the IOPLL file and omit tools coverage.

Native PIM additionally invokes `afu_synth_setup` at `.../pim/ofs_pim_and_afu_config.sh:85-87`; it was absent from required tool identities. It is now required before setup, PATH/resolved-path/hash bound, with missing-tool and drift regressions. That same script accepts AFU_WITH_PIM as an external filelist at lines 75-79, outside source/PIM inventories. Nonempty AFU_WITH_PIM now rejects before side effects, keeping the native dummy AFU under inventoried ofs-common. There is no new install/clone branch.

These checks bind the reviewed project inputs and selected entry executables, not every imported library or the entire tool installation. They do not turn the guard into an OS sandbox or a race-free filesystem snapshot.

### 3. Exact project-wide RTL generation syntax

Replaced the old unordered, optional, uppercase candidate grammar with one exact invocation using `-c ofs_top`, lowercase verilog for synthesis/simulation, modelsim, and parallel=off. The task supplied the prior installed 26.1.1 help result; this correction did not rerun it or claim vendor acceptance. Missing options, uppercase values, aliases, reordering, duplicate options, alternate simulator, parallel=on and arbitrary options/scripts reject. The existing exact IP-library enumeration script remains allowed separately; it is not full RTL generation.

### 4. Header generation and the post-module hook

`.../ip_get_cfg/gen_ofs_ip_cfg_db.tcl:45-54` opens the project, invokes `::ofs_ip_cfg_db::generate` when available, then closes the project. It therefore cannot simply run outside the project-open gate.

The selected IA840F project registers `syn/shared_config/post_module_hook.tcl` in `syn/board/ia840f/syn_top/ofs_top_sources.tcl:20`. The board-independent hook is sourced at `syn/shared_config/post_module_hook.tcl:77`. In `ofs-common/scripts/common/syn/ofs_post_module_script_fim.tcl:41-56`, the quartus_ipgenerate branch does provide header generation after project_open in the normal compilation flow.

**This source trace does not establish that standalone quartus_ipgenerate runs the hook.** Rather than grant a broad post-module exception or assume headers appear, added the exact separate `headers` context below, requiring explicit permissions `["setup", "generate", "headers"]` issued before the claim. `["setup"]` and `["setup", "generate"]` cannot authorize this context. Negative permission, script/revision/argument and runtime binding tests cover it.

No generic hook context is authorized. If the installed direct generation command starts an additional hook process that opens the project, the existing gate will reject it unless separately reviewed in a future narrow correction; no guessed argv or catch-all has been added. Preserve the failure/claim, collect exact process evidence and stop for review, rather than silently widen or retry. The separate header script warns instead of failing if the generator procedure is absent, so later acceptance must inspect actual header files and contents, not just the command exit code. No header or RTL result is claimed here.

### 5. Delayed review: WORK inventory/header variants and Python 3

The final delayed review requires the post-setup `project_ip` emission context below. It emits project assignments, not RTL. It requires generate permission and exact WORK script/project/revision/output/CWD. Explicit header generation likewise uses WORK, not SOURCE. Native setup's ip_lib and PIM macro contexts continue to use SOURCE exactly as observed in their native scripts. No interchangeable SOURCE/WORK aliases are permitted: only the actually required variants are allowed. Both permitted WORK scripts must hash identically to their already-inventoried SOURCE counterparts at the project-open check. A new regression independently mutates the work script for both contexts and verifies rejection, plus exact-grammar/permission rejection.

Remote Python 3.9.25, no unversioned python command, and distutils availability were reported by the parent; no remote check was performed here. The directly executed native OFSS entry had an env-python shebang and now explicitly uses env-python3. Imported helper modules need no shebang change. A regression checks the entry shebang, and local AST parsing checks Python 3.9 grammar; neither substitutes for remote interpreter/tool integration. Parent reports source/PIM pins match.

The parent also confirmed real installed `quartus_ipgenerate --help` line 21 and `--help=rev` line 2: `-c <revision name> | --rev=<revision name>`, rc0, in remote `qualification/goal-initial-preflight/ipgenerate-revision-help.json`. `--help=revision` was unavailable despite rc0. The direct grammar retains only exact `-c ofs_top`, not custom Tcl `--revision` syntax. This is attributed parent evidence, not a help probe executed by this task.

### 6. Real ELF versus argv[0]

The production runtime allowlist pins `/opt/altera/26.1.1/quartus/linux64/quartus_sh` and `/opt/altera/26.1.1/quartus/linux64/quartus_ipgenerate`. Their argv[0] must be the basename. Exact recorded ELF hash/full argv/project CWD still must match. PATH launchers remain separately hashed in `tools`; runtime contexts must use the actual ELF and its hash, not the launcher hash. Old fixture assumptions using an absolute argv[0] were removed. The regression uses synthetic process/hash evidence for these exact ELF-shaped paths; it does not read or execute installed vendor ELF files. Actual local Python `/proc` rejection is also retained.

## Exact permitted command contexts after correction

These commands were **not executed** here. Expand the following fixed paths when issuing a reviewed deployment record:

```text
SOURCE=/home/uwb_student00/ahls/new_BSP/ofs-agx7-pcie-attach
WORK=/home/uwb_student00/ahls/new_BSP/work_ia840f_ipgen_01
PIM=/home/uwb_student00/ahls/new_BSP/ofs-platform-afu-bbb
CWD=$WORK/syn/board/ia840f/syn_top
```

All contexts use the real ELF paths above, basename argv[0], exact full argv/hash record, CWD and matching single-use claim:

```sh
# prepare; setup permission
quartus_sh --prepare -r ofs_top ofs_top
quartus_sh --prepare -r ofs_pr_afu ofs_top

# ip_lib; setup permission
quartus_ipgenerate -t "$SOURCE/ofs-common/scripts/common/syn/emit_project_ip.tcl" --project=ofs_top --revision=ofs_top --mode=ip_lib

# pim_macros; setup permission
quartus_sh -t "$SOURCE/ofs-common/scripts/common/syn/emit_project_macros.tcl" --project=ofs_top --revision=ofs_top --mode=txt --output="$WORK/src/top/ofs_agilex.macros"

# project_ip; generate permission; emits assignments, not RTL
quartus_ipgenerate -t "$WORK/ofs-common/scripts/common/syn/emit_project_ip.tcl" --project=ofs_top --revision=ofs_top --output=project_ip_for_generation.tcl

# generate; generate permission
quartus_ipgenerate ofs_top -c ofs_top --generate_project_ip_files --synthesis=verilog --simulation=verilog --simulator=modelsim --parallel=off

# headers; separate headers permission, after generation
quartus_sh -t "$WORK/ofs-common/scripts/common/syn/ip_get_cfg/gen_ofs_ip_cfg_db.tcl" --project=ofs_top --revision=ofs_top
```

No new synthesis, fitting, assembly, all/compile/finish, PR release, programming or hardware-test context is accepted. No arbitrary Tcl/options or output locations were added. The guard remains an accidental-execution boundary, not protection against an operator modifying its code/record.

## Local verification methodology

All positive authorization records and tool files are temporary fixtures. Fixture tool files are inert text and are never executed. A few tests renew fixture claim hashes solely to test independent permission cases; production claims are never reset by the gate. Native negative-entry tests execute actual Bash scripts with an isolated temporary output root, assert rejection diagnostics/nonzero exits, and assert that the root remains empty: no worktree/log/bootstrap effects. Original component, PF/VF, preset/donor hash and preset-kind checks remain tested. AST parsing does not emit bytecode.

The first regression run passed 21 tests in 1.421s. An intermediate run after the ConfigParser identity-lambda adjustment passed 21 tests in 1.325s. After the delayed review additions, the final verification below reran the entire expanded suite (23 tests). Every final command returned exit code 0. Outputs are copied directly from the local tool results, not synthesized vendor results.

### Python regression suite

Working directory: `/home/joe/Projects/Thesis/AHLS/new_bsp/new/ofs-agx7-pcie-attach/ofs-common/tools/ofss_config`

```sh
PYTHONDONTWRITEBYTECODE=1 python3 -m unittest -v test_ia840f_experimental_gate
```

Exit code: 0

```text
test_denied_stages_do_not_read_record (test_ia840f_experimental_gate.PolicyTests.test_denied_stages_do_not_read_record) ... ok
test_generation_has_no_optional_defaults_or_aliases (test_ia840f_experimental_gate.PolicyTests.test_generation_has_no_optional_defaults_or_aliases) ... ok
test_installed_elf_paths_and_basename_argv_are_distinct (test_ia840f_experimental_gate.PolicyTests.test_installed_elf_paths_and_basename_argv_are_distinct) ... ok
test_inventory_change_and_escape (test_ia840f_experimental_gate.PolicyTests.test_inventory_change_and_escape) ... ok
test_missing_record_and_spoofed_stage (test_ia840f_experimental_gate.PolicyTests.test_missing_record_and_spoofed_stage) ... ok
test_only_reviewed_commands (test_ia840f_experimental_gate.PolicyTests.test_only_reviewed_commands) ... ok
test_pim_macros_and_header_exact_grammar (test_ia840f_experimental_gate.PolicyTests.test_pim_macros_and_header_exact_grammar) ... ok
test_real_selected_ofss_closure_is_in_inventoried_trees (test_ia840f_experimental_gate.PolicyTests.test_real_selected_ofss_closure_is_in_inventoried_trees) ... ok
test_runtime_context_uses_actual_process (test_ia840f_experimental_gate.PolicyTests.test_runtime_context_uses_actual_process) ... ok
test_wrong_target_work_and_options (test_ia840f_experimental_gate.PolicyTests.test_wrong_target_work_and_options) ... ok
test_actual_context_and_generation_permission (test_ia840f_experimental_gate.RecordTests.test_actual_context_and_generation_permission) ... ok
test_each_binding_fails_closed (test_ia840f_experimental_gate.RecordTests.test_each_binding_fails_closed) ... ok
test_missing_malformed_record_and_tool_drift (test_ia840f_experimental_gate.RecordTests.test_missing_malformed_record_and_tool_drift) ... ok
test_native_ofss_uses_python3 (test_ia840f_experimental_gate.RecordTests.test_native_ofss_uses_python3) ... ok
test_ofss_context_bound_to_native_argv_and_output (test_ia840f_experimental_gate.RecordTests.test_ofss_context_bound_to_native_argv_and_output) ... ok
test_options_and_missing_tools (test_ia840f_experimental_gate.RecordTests.test_options_and_missing_tools) ... ok
test_pim_and_headers_runtime_permission_and_identity (test_ia840f_experimental_gate.RecordTests.test_pim_and_headers_runtime_permission_and_identity) ... ok
test_post_setup_work_scripts_are_exact_and_source_bound (test_ia840f_experimental_gate.RecordTests.test_post_setup_work_scripts_are_exact_and_source_bound) ... ok
test_single_run_consumption (test_ia840f_experimental_gate.RecordTests.test_single_run_consumption) ... ok
test_tools_inventory_and_pim_executable_binding (test_ia840f_experimental_gate.RecordTests.test_tools_inventory_and_pim_executable_binding) ... ok
test_valid_record_and_new_work (test_ia840f_experimental_gate.RecordTests.test_valid_record_and_new_work) ... ok
test_original_pcie_checks_retained (test_ia840f_experimental_gate.ShellAndPcieTests.test_original_pcie_checks_retained) ... ok
test_shell_entries_reject_before_side_effects (test_ia840f_experimental_gate.ShellAndPcieTests.test_shell_entries_reject_before_side_effects) ... ok

----------------------------------------------------------------------
Ran 23 tests in 0.913s

OK
```

### Native Bash syntax

Working directory: `/home/joe/Projects/Thesis/AHLS/new_bsp/new/ofs-agx7-pcie-attach/ofs-common/scripts/common/syn`

```sh
for script in build_top.sh build_fim.sh build_fim_setup.sh build_fim_compile.sh build_fim_finish.sh setup_opae_sdk.sh pim/ofs_pim_and_afu_config.sh; do bash -n "$script" || exit; printf "PASS bash -n %s\n" "$script"; done
```

Exit code: 0

```text
PASS bash -n build_top.sh
PASS bash -n build_fim.sh
PASS bash -n build_fim_setup.sh
PASS bash -n build_fim_compile.sh
PASS bash -n build_fim_finish.sh
PASS bash -n setup_opae_sdk.sh
PASS bash -n pim/ofs_pim_and_afu_config.sh
```

### Real source inventories and Python syntax

Working directory: `/home/joe/Projects/Thesis/AHLS/new_bsp/new/ofs-agx7-pcie-attach/ofs-common/tools/ofss_config`

```sh
PYTHONDONTWRITEBYTECODE=1 python3 -c 'import ast,json; from pathlib import Path; import ia840f_experimental_gate as g; s=Path.cwd().parents[2]; inventories={t:g.inventory(s/t) for t in g.TREES}; print(json.dumps({t:len(v) for t,v in inventories.items()},sort_keys=True)); print("selected IOPLL bound:", "ofss_config/iopll/iopll_470MHz.ofss" in inventories["tools"]); print("source authorization record exists:", (s/g.RECORD_REL).exists()); [ast.parse(Path(p).read_text(),filename=p) for p in ("ia840f_experimental_gate.py","test_ia840f_experimental_gate.py")]; print("PASS Python AST parse (2 files)")'
```

Exit code: 0

```text
{"ipss": 149, "ofs-common": 949, "src": 77, "syn": 140, "tools": 41}
selected IOPLL bound: True
source authorization record exists: False
PASS Python AST parse (2 files)
```

### Python 3.9 grammar compatibility

Working directory: `/home/joe/Projects/Thesis/AHLS/new_bsp/new/ofs-agx7-pcie-attach/ofs-common/tools/ofss_config`

```sh
PYTHONDONTWRITEBYTECODE=1 python3 -c 'import ast; from pathlib import Path; files=("ia840f_experimental_gate.py","test_ia840f_experimental_gate.py","gen_ofs_settings.py"); [ast.parse(Path(p).read_text(),filename=p,feature_version=(3,9)) for p in files]; print("PASS Python 3.9 grammar (3 files); not a Python 3.9 runtime test")'
```

Exit code: 0

```text
PASS Python 3.9 grammar (3 files); not a Python 3.9 runtime test
```

## Changed implementation SHA-256 evidence

The following local command hashes the changed code/tests/implementation document (this report is excluded to avoid a self-hash). This is evidence for the parent, not an edit to the shared manifest:

```sh
sha256sum ofs-agx7-pcie-attach/ofs-common/tools/ofss_config/ia840f_experimental_gate.py ofs-agx7-pcie-attach/ofs-common/tools/ofss_config/test_ia840f_experimental_gate.py ofs-agx7-pcie-attach/ofs-common/tools/ofss_config/gen_ofs_settings.py qualification/goal-initial-preflight/experimental-gate-implementation.md ofs-agx7-pcie-attach/syn/board/ia840f/README.md ofs-agx7-pcie-attach/syn/board/ia840f/config/ia840f.ofss ofs-agx7-pcie-attach/syn/board/ia840f/config/ia840f_pcie_vendor_source.ofss docs/vendor-integration-status.md
```

```text
a5748b5ac824f795c0ccfef1dab6c262cd0b824d0e1bdfef4254f0aa409fd0f2  ofs-agx7-pcie-attach/ofs-common/tools/ofss_config/ia840f_experimental_gate.py
356862629a3e91fe8a9c47ed30c951a4a06628362756b3ab4557ea7770859ab6  ofs-agx7-pcie-attach/ofs-common/tools/ofss_config/test_ia840f_experimental_gate.py
e364b38696729d296cc35dbaafa71d8edb775de7fb064b4b2d1285a1cd844594  ofs-agx7-pcie-attach/ofs-common/tools/ofss_config/gen_ofs_settings.py
17d2fab93096c7ccb645f987901214c5401992d536786393371f6ac621c32645  qualification/goal-initial-preflight/experimental-gate-implementation.md
84da254cf42e0286247502162117d1604e52d15b35ea8ff0b68aeb29d74526fd  ofs-agx7-pcie-attach/syn/board/ia840f/README.md
525489cb80200b707309a9f4f0f5fdf83737b678f49d3a833a1e15a98d8055ed  ofs-agx7-pcie-attach/syn/board/ia840f/config/ia840f.ofss
515b0dbffb60d96516a48e6b27733de86d4b07ed8438f997e75929dbab01e9b8  ofs-agx7-pcie-attach/syn/board/ia840f/config/ia840f_pcie_vendor_source.ofss
4b870c8d726a4c9e7e0874a286ae7ce9e266bebc4bb6788389b6277d588c9d29  docs/vendor-integration-status.md
```

## Remaining deployment checks / issues

- This task cannot establish installed Quartus/Tcl integration, hook dispatch, licenses, generated RTL completeness, header correctness or interface acceptance because remote/vendor execution was explicitly prohibited.
- Record issuance must include tools inventory, afu_synth_setup, exact macro context, lowercase full generation context, ELF hashes/basename argv[0], and separate headers permission/context when used. Old receipts/records are intentionally incompatible and must not be silently reused.
- Parent must refresh the source receipt/manifest after review. Do not alter the record after claiming the single run, clear a failed claim, bootstrap missing prerequisites or widen the gate after an unexpected invocation.
- No BMC/board changes were used to hide integration failures. Readiness stays false pending real bounded generation and independent interface validation.

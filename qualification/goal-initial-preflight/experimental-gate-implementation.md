# Local experimental gate implementation

Status: implemented and corrected locally. No authorization record issued, workstation access, vendor-tool execution, RTL generation, synthesis or hardware test performed by this correction task. `ready_for_build` remains false. See `experimental-gate-corrections.md` for corrections, source findings and complete local test evidence. The proposal and previous test log remain historical evidence.

## Reviewed native flow

`build_top.sh` guards IA840F before opening a log. Direct `build_fim.sh`, setup, compile and finish guards run before board sourcing, worktree creation or dependency setup. Default all, compile, finish and analysis/elaboration remain prohibited. Other boards are unchanged.

Setup copies the worktree, runs the native source pre-compile hook, checks preinstalled OPAE tools, enumerates/copies IP with `emit_project_ip.tcl`, invokes OFSS, configures PIM and prepares `ofs_pr_afu` and `ofs_top`. PIM invokes `emit_project_macros.tcl` from the WORK project directory with source script path and WORK output path. Both enumeration and macro emission open the project and therefore require exact QSF-gate contexts. OFSS guards before deployment (including IOPLL), not only at PCIe. Existing PCIe component, preset, PF/VF, donor hash and preset-kind checks remain unchanged.

Missing dependencies reject instead of bootstrapping. The required PIM checkout is inventoried; `afu_synth_setup`, used by native PIM setup, is now a required hashed tool. Nonempty `AFU_WITH_PIM` is forbidden, keeping the source-bound native dummy AFU rather than accepting an external filelist.

## Fixed authorization contract

C = `/home/uwb_student00/ahls/new_BSP/ofs-agx7-pcie-attach`

WORK = `/home/uwb_student00/ahls/new_BSP/work_ia840f_ipgen_01`

PIM = `/home/uwb_student00/ahls/new_BSP/ofs-platform-afu-bbb`

PROJECT = `WORK/syn/board/ia840f/syn_top`

Record = `C/syn/board/ia840f/setup/experimental-authorization.json`

No environment variable selects a different record. No live record is shipped. Temporary fixtures and patched constants exist only in tests; there is no production test-mode switch.

Required fields:

- `schema: 1`, `approved: true`, `ready_for_build: false`, `target: "ia840f"`, `part: "AGFB027R25A2E2V"`, `toolchain: "Quartus Prime Pro 26.1.1 Build 130"`.
- Exact `source`, `work`, `pim` paths above.
- `permissions`: exactly `["setup"]`, `["setup", "generate"]`, or `["setup", "generate", "headers"]`. Headers need separate explicit permission. No compilation permission exists.
- `source_sha256`: exactly `syn`, `src`, `ipss`, `ofs-common`, **`tools`**; each is the full `inventory(C / tree)` relative-path/SHA-256 dictionary. `tools` covers the selected `tools/ofss_config/iopll/iopll_470MHz.ofss`. Missing, added and modified files reject. Bytecode and the authorization record itself are excluded. External file symlinks and directory symlinks inside inventories reject.
- `pim_sha256`: full `inventory(PIM)`.
- `tools`: `quartus_sh`, `quartus_ipgenerate`, `ip-deploy`, `qsys-script`, `PACSign`, `packager`, `afu_json_mgr`, **`afu_synth_setup`**; each has `path` (resolved PATH executable) and `sha256`. Version is an operator attestation bound to hashes, not a locally executed version probe.
- `quartus_contexts`: exact objects containing `executable`, `sha256`, complete `argv`, `cwd`, and `kind`. Runtime executable is exactly `/opt/altera/26.1.1/quartus/linux64/quartus_sh` or `/opt/altera/26.1.1/quartus/linux64/quartus_ipgenerate`; `argv[0]` is its basename, not its full ELF path. Runtime ELF hash is distinct from any PATH launcher hash. The record must bind both correctly. CWD is exactly PROJECT. Every object must also satisfy the closed grammar below.

Native entry requires COPY_WORK=1, -p, exact `nodefault,C/syn/board/ia840f/config/ia840f.ofss`, pinned PIM, absent WORK and absent claim. Keep-work, user hooks, analysis/elaboration, preloaded build variables, external AFU filelist and nonempty variant tags reject. Setup-entry creates `WORK.authorization-claim` exclusively, storing the record hash. Preserve it after failure. Record changes invalidate the claim; no automatic reset, new run, retry path or bootstrap is authorized.

## Closed Quartus grammar

The following are descriptions of permitted contexts, **not commands executed by this task**. C/WORK placeholders must be expanded to the exact fixed paths. All run from PROJECT with the matching executable/hash/full argv record:

```text
# kind prepare; setup permission
quartus_sh --prepare -r ofs_top ofs_top
quartus_sh --prepare -r ofs_pr_afu ofs_top

# kind ip_lib; setup permission
quartus_ipgenerate -t C/ofs-common/scripts/common/syn/emit_project_ip.tcl --project=ofs_top --revision=ofs_top --mode=ip_lib

# kind pim_macros; setup permission
quartus_sh -t C/ofs-common/scripts/common/syn/emit_project_macros.tcl --project=ofs_top --revision=ofs_top --mode=txt --output=WORK/src/top/ofs_agilex.macros

# kind project_ip; generate permission; assignment emission only
quartus_ipgenerate -t WORK/ofs-common/scripts/common/syn/emit_project_ip.tcl --project=ofs_top --revision=ofs_top --output=project_ip_for_generation.tcl

# kind generate; generate permission
quartus_ipgenerate ofs_top -c ofs_top --generate_project_ip_files --synthesis=verilog --simulation=verilog --simulator=modelsim --parallel=off

# kind headers; headers permission in addition to setup/generate
quartus_sh -t WORK/ofs-common/scripts/common/syn/ip_get_cfg/gen_ofs_ip_cfg_db.tcl --project=ofs_top --revision=ofs_top
```

The WORK project_ip and headers scripts must hash identically to their inventoried SOURCE counterparts. Only these exact WORK variants and the native SOURCE setup variants are permitted. The native OFSS executable now uses `#!/usr/bin/env python3`, matching the reported Python 3.9.25 deployment without an unversioned python command.

Generation uses the exact lowercase help-supported syntax supplied by the prior installed-tool review. Parent subsequently confirmed installed `--help` and `--help=rev` explicitly support `-c <revision name> | --rev=<revision name>` (remote `qualification/goal-initial-preflight/ipgenerate-revision-help.json`); this task did not retrieve or execute that remote evidence. No optional defaults, uppercase VERILOG, reordered/duplicated/extra flags, arbitrary Tcl, alternate output or alternate revision is permitted. Help was not rerun here; installed-tool behavior and complete generated interfaces are not established by Python fixtures.

## Headers and post-module hooks

The selected project assigns `syn/shared_config/post_module_hook.tcl`; it sources `ofs_post_module_script_fim.tcl`, whose `quartus_ipgenerate` branch opens the project and invokes `::ofs_ip_cfg_db::generate`. That is a compilation-flow hook, not proof that a standalone `quartus_ipgenerate` command executes it. The separate exact `gen_ofs_ip_cfg_db.tcl` context supports deliberate header generation after RTL generation, with its own permission recorded before the single-use claim is created.

No generic post-module script exception is added. If the installed standalone command actually invokes a separate Quartus hook process, an unrecorded/unsupported project-open context must fail closed; collect its exact invocation and obtain a separate narrow review. Do not bypass the gate to finish the run. Header script success alone is insufficient: it can warn rather than fail if `::ofs_ip_cfg_db::generate` is absent. Validate generated header existence/content as well as complete PCIe/memory/BMC RTL and interfaces. No board or BMC configuration was changed to avoid this issue.

## Verification and remaining limits

The local test suite executes Python policy fixtures, actual negative native Bash entries, Bash syntax checks and actual non-Quartus `/proc` rejection. Fixture tool files are inert and never executed; synthetic ELF identities are clearly marked. Source closure tests read the real selected OFSS files. See the correction report for the exact final commands, outputs and file inventory counts.

Before deployment, the parent must refresh its source manifest/receipt (not edited here), independently review changed inventories/tool bindings and issue a complete real record. The single run still requires actual tool/license/environment readiness, logged execution, preservation of failures and independent generated-interface acceptance. The guard is not a runner or OS sandbox, a signature authority, an immutable tool installation, a race-free filesystem snapshot, or a guarantee of generated-worktree correctness. Allowed project-management commands can repeat inside the claimed run; new setup cannot. No synthesis, fitting, assembly, finish, PR release, programming or hardware-test permission is conferred.

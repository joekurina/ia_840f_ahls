# Corrected IA840F experimental gate — code-quality review

## Verdict: APPROVED

No important or critical defect found in the corrected experimental gate within the requested scope. This approves the local source-bound guard for the reviewed bounded experiment; it does **not** establish successful Quartus setup, complete RTL generation, header/interface acceptance, or build readiness. `ready_for_build` remains false.

Root reviewed: `/home/joe/Projects/Thesis/AHLS/new_bsp/new/ofs-agx7-pcie-attach` (paths below are relative to this root unless stated otherwise).

## Scope and source findings

Reviewed the correction/implementation reports and independent spec re-review, the complete Python policy and regression suite, guarded native Bash dispatch/setup/compile/finish entries, OPAE prerequisite branch, Tcl project-open guard, OFSS and PCIe guards, and supporting work-copy/build-variable/PIM/IP-inventory/header paths. The review focused on gate correctness, accidental bypasses, failure behavior, native command consistency, and regression adequacy rather than general BSP cleanup or adversarial sandbox design.

### Authorization, input binding, and single-run handling

- `ofs-common/tools/ofss_config/ia840f_experimental_gate.py:62–88` checks the fixed record, strict types for fixed identity/readiness fields, exact permission sets, complete five-tree source inventories, pinned PIM inventory, canonical roots, and the resolved PATH identities/hashes of all required tools. No environment-selected record or bootstrap fallback is introduced.
- Inventory traversal at lines 38–59 detects added, removed, and changed regular files, rejects external/file-directory symlink escapes, and intentionally excludes bytecode and the authorization record. The top-level `tools` tree closes the selected IOPLL input gap.
- Lines 158–184 require the exact setup environment, target and work path, absent worktree and claim, and prohibit inherited build state, variant tags, hooks and external AFU input. Exclusive claim creation fails closed on contention; failed runs retain the claim. Lines 133–136 bind subsequent use to the same record hash. There is no automatic retry/reset path.

### Actual process and command restrictions

- Lines 91–119 implement explicit ordered argument lists, not substring or optional-flag matching. Native preparation, SOURCE IP-library enumeration and PIM macros are distinct from WORK project inventory, direct generation and explicit headers.
- Lines 122–126 and 139–155 inspect the actual parent `/proc` executable, argv and cwd; require the installed ELF path with basename argv[0]; check the fixed project directory, recorded runtime hash/full context and appropriate permissions. Generation and headers are separately gated. WORK inventory/header scripts are compared with their inventoried SOURCE counterparts.
- `syn/board/ia840f/setup/build_gate.tcl:4–8` retains false readiness and converts validator failure into a Tcl error. Both IA840F QSF revisions register this guard at line 2. The reviewed grammar does not add synthesis, fit, assembly, compile, finish or programming authorization.

### Native integration and ordering

- `ofs-common/scripts/common/syn/build_top.sh:158–161` checks authorization before opening the build log; lines 172–192 route setup directly to `build_fim_setup.sh`, avoiding the intentionally forbidden all-stage entry. The setup guard at `build_fim_setup.sh:16–19` runs before board setup/work writes and consumes the claim.
- Setup's inspected command construction agrees with the policy: SOURCE ip_lib at lines 249–254, exact native OFSS at lines 306–313, PIM at lines 318–323, and the two preparation revisions at lines 328–331.
- `pim/ofs_pim_and_afu_config.sh:63–69` emits macros from the WORK project using the SOURCE script. `syn/scripts/build_var_setup.sh:258–260` supplies the policy's exact macro basename/output directory. PIM setup uses the pinned checkout, and `afu_synth_setup` invoked at lines 85–87 is now included among required hashed tools. External `AFU_WITH_PIM` is rejected, leaving the inventoried dummy AFU.
- `setup_opae_sdk.sh:47–55` refuses the IA840F missing-prerequisite branch rather than cloning/building dependencies. Native stage scripts retain explicit nonzero rejection and setup uses `set -e`; `build_top.sh` retains pipeline failure propagation.
- `ofs-common/tools/ofss_config/gen_ofs_settings.py:110–117` checks IA840F before project construction/deployment or IP deployment. The directly executed file uses Python 3 and has executable permissions locally. `ia840f_vendor_pcie.py:14–37` retains component, PF/VF, preset hash and preset-kind checks before the final contextual authorization.
- `emit_project_ip.tcl:45–80` opens the project before writing its inventory output. `ip_get_cfg/gen_ofs_ip_cfg_db.tcl:45–54` likewise opens the project before header generation. The separate permission/WORK variants therefore address real guarded entry points rather than unneeded aliases.

## Independent local execution

All commands below were executed locally by this reviewer. No vendor binary, remote connection, dependency installation or authorization issuance was used.

1. From `ofs-common/tools/ofss_config`:

   `PYTHONDONTWRITEBYTECODE=1 python3 -m unittest -v test_ia840f_experimental_gate`

   Exit 0; **23 tests passed**. Actual summary: `Ran 23 tests in 1.265s`, `OK`.

   Coverage includes exact positive command fixtures, missing/reordered/additional option rejection, ELF/argv/cwd mismatches, permission boundaries, source and tool drift, single-use claims, real selected OFSS closure, copied WORK script drift, actual negative native shell entries with no temporary-root side effects, and retained PCIe checks. Positive vendor identities are inert/mocked fixtures, not vendor execution. The suite also contains an actual non-Quartus `/proc` rejection under a valid fixture record.

2. Explicit `bash -n` on `build_top.sh`, `build_fim.sh`, `build_fim_setup.sh`, `build_fim_compile.sh`, `build_fim_finish.sh`, `setup_opae_sdk.sh`, and `pim/ofs_pim_and_afu_config.sh`:

   Exit 0; all seven reported PASS.

3. `ast.parse(..., feature_version=(3,9))` on the gate, its tests and `gen_ofs_settings.py`:

   Exit 0; `PASS Python 3.9 grammar (3 files)`. This is syntax compatibility, not execution using the remote Python 3.9 interpreter.

4. Local permission inspection reported `0o775` for the native OFSS executable, `build_fim_setup.sh`, and `pim/ofs_pim_and_afu_config.sh`.

## Limits and deployment conditions

These are retained experimental acceptance conditions, not findings requiring a gate redesign:

- Installed Quartus/Tcl invocation behavior, licenses and actual generated RTL remain untested here. Installed-help assertions are supplied parent evidence, not independently executed by this reviewer.
- Header generation can warn and return without emitting headers when the generator procedure is absent (`gen_ofs_ip_cfg_db.tcl:47–51`). Command success alone must not be treated as header/interface acceptance.
- Standalone ipgenerate hook dispatch is not established by source inspection. Unexpected child/project-opening commands must remain denied; preserve the failure and seek separate review instead of broadening the grammar during the run.
- Refresh deployment receipts after the reviewed changes, issue the complete matching authorization before claiming, preserve failures, and independently validate actual generated outputs. Do not reset the claim or reuse an incompatible earlier record.
- The declared boundary is accidental execution/source binding, not protection against an operator modifying guarded code or records, an immutable WORK snapshot, or exhaustive hashing of every imported tool library. No approval beyond that boundary is implied.

## Changes made by this review

Created only `qualification/goal-initial-preflight/experimental-gate-quality-review.md` under the local root above the checkout. No source edits, commits, vendor execution or remote calls. No blocking review issue encountered.

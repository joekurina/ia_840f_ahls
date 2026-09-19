# Independent IA840F experimental gate spec re-review

## Verdict: PASS

No necessary spec corrections found in this focused re-review. The previous command, inventory and documentation defects are corrected. The inspected native setup call chain is consistent with the corrected gate. This is a **local source/policy spec PASS**, not a claim that native Quartus setup, RTL generation or generated-interface acceptance has succeeded. A separate quality review and deployment prerequisites remain outstanding.

Scope: read the correction and implementation reports, Python gate/tests, native setup/PIM/OPAE/copy paths, project-open Tcl gate, IP inventory/header scripts, and corrected board/status documentation. No remote access, vendor executable, dependency installation, authorization issuance or commit was performed. Only this review report was created.

## Previous defects and required additions

- **Native PIM macros — resolved.** `ofs-common/scripts/common/syn/build_fim_setup.sh:323` calls PIM setup; `pim/ofs_pim_and_afu_config.sh:63–69` runs the SOURCE macro emitter from WORK's project directory. `syn/scripts/build_var_setup.sh:258–260` makes its exact output `WORK/src/top/ofs_agilex.macros`. `ia840f_experimental_gate.py:97–104` permits the required SOURCE script with `--project=ofs_top --revision=ofs_top --mode=txt --output=WORK/src/top/ofs_agilex.macros`, without accepting a generic macro/script exception.
- **Selected IOPLL/source coverage — resolved.** `TREES` includes top-level `tools`; record loading requires exactly all five source inventories. The actual selected OFSS closure includes `tools/ofss_config/iopll/iopll_470MHz.ofss`. Existing tests walk the real five-file closure and reject missing tools coverage or changed IOPLL input.
- **Full generation grammar — resolved.** The sole direct generation grammar is exactly `quartus_ipgenerate ofs_top -c ofs_top --generate_project_ip_files --synthesis=verilog --simulation=verilog --simulator=modelsim --parallel=off`. It is distinct from setup IP copying and assignment inventory emission. Case changes, omitted/reordered/extra arguments and alternative generation settings reject. The supplied installed-help evidence establishes `-c`/`--rev` support; this reviewer did not rerun or independently retrieve remote help.
- **Actual runtime identity — resolved.** Production runtime executables are the supplied `/opt/altera/26.1.1/quartus/linux64/{quartus_sh,quartus_ipgenerate}` paths, with basename argv[0]. Actual parent `/proc` executable/argv/CWD and ELF hash must equal a recorded exact context. PATH launcher hashes remain separately bound.
- **WORK inventory/header contexts — resolved.** The exact WORK `emit_project_ip.tcl` command writes `project_ip_for_generation.tcl` and requires generate permission. The exact WORK `ip_get_cfg/gen_ofs_ip_cfg_db.tcl` command requires separate headers permission. Both WORK entry scripts are hash-compared with their inventoried SOURCE counterparts at project opening. Native setup ip_lib and PIM macro commands retain their required SOURCE paths; aliases are not interchangeable.
- **Native PIM/tool/interpreter viability — resolved at the inspected source level.** Native setup requires and binds `afu_synth_setup`, which the PIM script actually invokes. Nonempty `AFU_WITH_PIM` rejects; the default dummy AFU remains within inventoried ofs-common. The directly executed OFSS entry has an env-python3 shebang, avoiding the reported missing unversioned python. Local grammar checks support Python 3.9 syntax, but are not remote Python 3.9 execution evidence.
- **Stale documentation — resolved in reviewed correction scope.** Implementation/correction reports, IA840F README, selected OFSS comments and vendor integration status distinguish source/schema evidence from generated-IP acceptance. They retain false readiness and no longer present the old unconditional rejection, absent installed schema, or mandatory host pipes as the current contract.

## Native setup and retained boundaries

`build_top.sh` rejects before its build log; setup-entry validates and exclusively claims before board sourcing or worktree creation. Setup then copies the worktree, checks existing OPAE tools, runs SOURCE ip_lib inventory/copy, invokes the guarded OFSS entry, invokes SOURCE PIM macros and pinned PIM generation, runs bound `afu_synth_setup`, and prepares the two allowed revisions. The corrected command grammar covers the inspected project-opening steps with the native project/revision/output/CWD values.

COPY_WORK=1, fixed SOURCE/WORK/PIM paths, the exact OFSS selection, absent initial WORK, and an exclusive record-hash claim remain enforced. Missing dependencies do not trigger the IA840F OPAE bootstrap branch; the pinned PIM environment prevents the native missing-PIM clone branch. The claim remains after failure, and changing the record invalidates it. Both project revisions still load `build_gate.tcl`, which keeps readiness false. No synthesis, fit, assembler, compile/all, finish, programming or generic Tcl context was added. Original PCIe component/PF/VF/preset checks remain exercised.

The explicit header command is appropriate: the source post-module hook contains a header-generation branch, but source inspection does not prove standalone ipgenerate dispatches it. An unexpected hook process must remain denied and reviewed, not accommodated by broadening the gate during a run. The separate header script can warn and exit without generating headers if its procedure is absent; later acceptance must check files and contents, not just exit status. These limits are correctly documented rather than hidden.

## Independent local verification

Commands ran locally with bytecode disabled; positive records/tools were the existing inert temporary fixtures. No fixture vendor tool was executed.

1. In `ofs-agx7-pcie-attach/ofs-common/tools/ofss_config`:
   `PYTHONDONTWRITEBYTECODE=1 python3 -m unittest -v test_ia840f_experimental_gate`
   — exit 0; **23 tests passed**, `Ran 23 tests in 1.346s`, `OK`. Includes actual negative native Bash entry execution and original PCIe checks.
2. Explicit `bash -n` on `build_top.sh`, `build_fim.sh`, `build_fim_setup.sh`, `build_fim_compile.sh`, `build_fim_finish.sh`, `setup_opae_sdk.sh`, and `pim/ofs_pim_and_afu_config.sh`
   — exit 0; all seven passed.
3. Real `inventory()` traversal returned `{"ipss": 149, "ofs-common": 949, "src": 77, "syn": 140, "tools": 41}`. Selected IOPLL membership was `True`; local source authorization record existence was `False`.
4. `ast.parse(..., feature_version=(3,9))` passed for the gate, regression suite and `gen_ofs_settings.py`. This checks syntax compatibility only, not the reported remote runtime or installed packages.

## Remaining prerequisites, not spec defects

- Refresh deployment receipts/source manifest after review; issue a complete record with current inventories, required tools, real runtime hashes, exact contexts and explicit headers permission if headers are intended.
- Preserve the unique claim/failure evidence; do not reset, silently retry, bootstrap, alter board/BMC inputs to mask failures, or widen authorization on unexpected native behavior.
- Actual Quartus/Tcl integration, license/environment readiness, standalone hook behavior, full RTL generation and header/interface correctness remain unverified by this local review. Readiness stays false.
- This is the approved accidental-execution/source-binding boundary, not an adversarial OS sandbox or an immutable snapshot of every imported tool library.

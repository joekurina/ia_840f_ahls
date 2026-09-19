# Experimental gate runtime correction — local only

## Finding

The saved `remote-setup-result.json` records setup return code 0. The saved `remote-setup-full.log` contains **four** `Critical Warning (125091)` diagnostics wrapping `IA840F NOT READY` / `IA840F EXPERIMENTAL GATE: tool path: quartus_sh`. Quartus downgraded errors from the QSF `SOURCE_TCL_SCRIPT_FILE` callback to warnings. Bash `set -e` could not reject a vendor process that returned zero. This is not accepted setup and not RTL generation/acceptance. The previously completed IOPLL, PCIe, memory and two model deployments remain diagnostic artifacts, not readiness evidence.

The parent supplied results of a successful no-project probe: Quartus prepends its internal directories to PATH. Its inner identities differ from the outer launchers for `quartus_sh`, `quartus_ipgenerate`, `ip-deploy`, and `qsys-script`. The actual runtime ELF and basename argv[0] rules remain unchanged. The referenced `quartus-inner-environment.json` was not present locally when first checked; this subagent did not perform that probe or any remote execution.

## Exact local changes

Paths below are relative to `ofs-agx7-pcie-attach/`:

- `ofs-common/tools/ofss_config/ia840f_experimental_gate.py`
  - Retains native outer PATH checks and adds a separately required `quartus_tools` identity map. Both maps must cover exactly `TOOLS`; every recorded file in both maps is hash-checked. Only the Quartus callback selects the inner PATH map; native and OFSS entry checks still select outer identities.
  - Fixes the four permitted inner paths to `/opt/altera/26.1.1/quartus/linux64/{quartus_sh,quartus_ipgenerate}` and `/opt/altera/26.1.1/qsys/bin/{ip-deploy,qsys-script}`. Other inner tools must retain their outer paths. No same-basename or hash-only fallback is permitted. Recorded paths must be canonical.
  - Adds `run-setup-quartus TOOL ARGS...`, restricted to existing exact `ip_lib`, `pim_macros`, and `prepare` command grammars. It validates record, claim, setup environment and project cwd before spawning the hash-bound outer launcher.
  - Streams merged stdout/stderr in at most 65,536-byte chunks, with marker overlap across chunk boundaries. Any `IA840F_GATE_REJECTED`, `IA840F NOT READY`, `IA840F EXPERIMENTAL GATE:`, or `Critical Warning (125091)` causes failure even if the subprocess exits zero. Nonzero subprocess status also fails. Output is preserved.
- `syn/board/ia840f/setup/build_gate.tcl`
  - Emits stable `IA840F_GATE_REJECTED` to stderr before its existing error. Keeps readiness false. Does not guess vendor `qexit` behavior.
- `ofs-common/scripts/common/syn/build_fim_setup.sh`
  - Routes IA840F IP enumeration and both prepare commands through the bounded setup wrapper, with explicit failure exits. A rejected IP enumeration cannot reach OFSS deployment; a rejected first prepare cannot reach the second prepare. Explicitly propagates PIM configuration failure.
- `ofs-common/scripts/common/syn/pim/ofs_pim_and_afu_config.sh`
  - Routes IA840F macro emission through the same wrapper before PIM removal/setup. Other board command paths remain unchanged.
- `ofs-common/tools/ofss_config/test_ia840f_experimental_gate.py`
  - Adds inner/outer identity separation, missing-inner-record rejection, inner hash mutation, pre-spawn grammar/claim rejection, clean/nonzero/zero-exit-warning output tests, stderr and split-marker tests, and execution of actual native shell command blocks with inert Python subprocesses in place of vendor tools.

## Verification actually run

Command, from `ofs-common/tools/ofss_config/`:

```text
python3 -m unittest -v test_ia840f_experimental_gate.py
----------------------------------------------------------------------
Ran 30 tests in 3.630s

OK
```

The shell-block tests exercised clean success, nonzero child status, and warning-with-zero-child-status for IP enumeration, PIM macro emission and revision preparation. On rejection they returned 1 and did not reach the following-stage marker. Existing tests still reject synthesis/compile/finish, unauthorized generation, changed sources/tools, unrecorded argv/cwd/runtime identity, missing claims, and early native-entry side effects. Bash syntax checks are exercised by the suite for the native entry scripts and the changed PIM script.

A separate **local inert Python replay** of the actual saved remote log returned these verified results:

```json
{
  "replay": "local inert Python replay, not Quartus",
  "warning_125091_count": 4,
  "input_bytes": 64742,
  "output_preserved": true,
  "rejected": "IA840F EXPERIMENTAL GATE: setup Quartus subprocess reported gate/Tcl rejection despite exit 0"
}
```

`tclsh` was not installed locally (`shutil.which('tclsh')` returned `None`). No Tcl/vendor-runtime integration success is claimed.

## Parent handoff / remaining qualification

- The parent must issue the new record with **all eight** `quartus_tools` entries, each `{ "path": canonical_installed_path, "sha256": observed_installed_file_hash }`, in addition to the existing outer `tools` map. The four differing paths are fixed above; the remaining four must equal outer paths. Old records lacking this map fail closed. No manifest, authorization record, run-path constant or claim was changed by this subagent.
- The changed source inventory must be reflected by the parent's reviewed deployment process. The parent owns run-path rotation and deployment. Do not reuse/reset the original authorization claim or erase `work_ia840f_ipgen_01`.
- This correction enforces failure **at the native setup subprocess boundary**, before subsequent stages; it does not forcibly interrupt a vendor process already running. Direct Quartus invocations outside this wrapper still have Quartus's warning-conversion behavior. Post-setup generation/header commands are not newly enabled or covered by this setup-only runner; they require their own reviewed failure propagation before execution.
- No workstation connection, deployment, setup rerun, RTL generation, synthesis, fitting, finishing or programming was performed. Remote artifacts, authorization and claims were left untouched. Real corrected integration remains unverified until the parent explicitly authorizes and performs it.

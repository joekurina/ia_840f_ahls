# Independent runtime-correction spec review

## Verdict: PASS — bounded setup correction only

No source change is required for this correction's stated setup-boundary contract. This is a source/local-test review, **not** corrected Quartus integration acceptance, generation qualification, or build readiness. `ready_for_build` remains false.

Reviewed `experimental-gate-runtime-correction.md`, all five named source/test files, the native outer dispatch/propagation chain, and saved setup evidence. No remote/vendor commands, deployment, claim resets, board changes, source edits, or commits were performed.

## Findings

- **Zero-exit warning rejection:** `ia840f_experimental_gate.py:226–261` reads the child's merged stdout/stderr as bytes, forwards and flushes every chunk, retains overlap for split markers, and rejects either nonzero status or any of the four stated rejection markers. The wrapper waits for the current child to finish; it does not promise to interrupt that child or undo its effects. Rejecting every `Critical Warning (125091)` is the intended conservative Tcl-error boundary, not merely a match for the original tool-path diagnostic.
- **Native chain stops:** `build_fim_setup.sh:253–256` explicitly exits after rejected IP enumeration, before OFSS at lines 312–320. Macro rejection exits the subshell in `ofs_pim_and_afu_config.sh:66–76`; that separate executable has `set -e`, so it stops before PIM removal/setup at lines 78–79. Its parent invocation explicitly propagates failure at setup line 329. Both prepare calls explicitly exit on failure at lines 334–346, so rejected first preparation cannot reach the second. `build_top.sh:165–199` enables `pipefail` around the setup/tee pipeline and exits nonzero on failure. The `all` route remains prohibited for IA840F; this correction does not enable compile or finish.
- **Closed setup grammar:** `run_setup_quartus` permits only existing exact `ip_lib`, `pim_macros`, and `prepare` forms. It validates record, claim, setup environment, and project cwd before invoking the recorded outer launcher as an argv list. It does not accept arbitrary executables, scripts, extra flags, generation, synthesis, or programming. The existing Quartus callback continues checking actual parent executable, basename argv[0], full argv/cwd, executable hash, and recorded context.
- **Identity separation:** both eight-entry maps are mandatory and every recorded file is canonical-path/hash checked. Only the Quartus callback selects the inner PATH map. Native/OFSS/wrapper checks retain outer identities. The inner overrides are exactly `/opt/altera/26.1.1/quartus/linux64/{quartus_sh,quartus_ipgenerate}` and `/opt/altera/26.1.1/qsys/bin/{ip-deploy,qsys-script}`; remaining inner paths must equal their corresponding outer paths. There is no basename/hash-only substitution fallback.
- **Tcl and readiness:** `build_gate.tcl:4–11` retains false readiness and emits `IA840F_GATE_REJECTED` to stderr before its existing error. No unverified vendor `qexit` mechanism was introduced. The Python monitor also detects the old diagnostics when the stable marker is absent.
- **Python 3.9:** both Python files pass `ast.parse(..., feature_version=(3,9))`. Reviewed runtime API use is compatible with 3.9, including `Path.is_relative_to` (available in 3.9). The actual local interpreter is Python 3.13.5; Python 3.9 and `tclsh` are not installed. A Python 3.9 runtime test or Tcl/vendor integration pass is therefore **not** claimed.

## Independently executed verification

From `ofs-agx7-pcie-attach/ofs-common/tools/ofss_config/`:

```text
python3 -m unittest -v test_ia840f_experimental_gate.py
Ran 30 tests in 4.701s
OK
```

The suite executes actual extracted native command blocks with inert Python child processes, including clean success, nonzero child status, zero-exit warnings, stderr markers, and byte-split markers. It also runs native rejection entries and Bash syntax checks. Identity/context positive tests use synthetic files and mocks; shell-block tests substitute the wrapper entry with an output-monitor harness. These are meaningful local propagation tests, not end-to-end execution of an authorized vendor setup.

An independent inert Python replay of the saved `remote-setup-full.log` through the actual monitor yielded:

```json
{
  "inert_replay": true,
  "input_bytes": 64742,
  "warning_count": 4,
  "preserved": true,
  "rejection": "IA840F EXPERIMENTAL GATE: setup Quartus subprocess reported gate/Tcl rejection despite exit 0"
}
```

Output equality was asserted byte-for-byte. The saved `remote-setup-result.json` records return code 0. Thus the original run remains rejected despite its process status; the correction demonstrably rejects its diagnostic stream locally.

## Remaining execution prerequisites, not defects in this bounded correction

1. Parent must rotate to fresh `work_ia840f_ipgen_02`, update bound paths/contexts and reviewed inventories/manifests, and issue all eight observed/hash-bound `quartus_tools` entries alongside the existing outer map. The reviewed source still targets work01; this review does not authorize running it against the consumed claim.
2. Preserve failed work01 and its original claim. No reset or reuse is permitted by this review.
3. Corrected real setup integration remains unverified. Local tests establish wrapper behavior, not successful installed inner-tool resolution or vendor project loading.
4. Before post-setup generation/project-IP/header execution, implement and review their own process-level warning/failure propagation. Existing callback command recognition and the user's RTL-generation approval do not make this setup-only wrapper cover those commands. Do not widen this wrapper to arbitrary command grammar.
5. No OS-sandbox requirement is asserted: this is the stated source-bound accidental-execution guard, not protection against an operator able to alter the guard/record.

## Reviewed source fingerprints

Paths relative to `ofs-agx7-pcie-attach/`; SHA-256 values computed locally:

```text
0150a7894f9cea434bb34ba61f4f908d76ad749dcd214603692d96f4d57f859f  ofs-common/tools/ofss_config/ia840f_experimental_gate.py
8e701253cb597ba5bc8c81146c918e3ab2d823fb1d62e73140fbd12904b49878  ofs-common/tools/ofss_config/test_ia840f_experimental_gate.py
3e8c3017f0af5f6160c3ea52ea2dbe06c038327261a5f0537b74c5de4d9e948f  ofs-common/scripts/common/syn/build_fim_setup.sh
4fe07ded5ae70ee886b4e01ee557e6cbef7c35e13dd5bc482b95610182fed28c  ofs-common/scripts/common/syn/pim/ofs_pim_and_afu_config.sh
7a0a835d0b7e19fed419f3d05e8a565ac6ec1dbb185e32a2fda1b5fc6aaa7d98  syn/board/ia840f/setup/build_gate.tcl
```

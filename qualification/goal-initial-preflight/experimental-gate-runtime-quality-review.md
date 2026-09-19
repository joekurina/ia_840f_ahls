# IA840F runtime correction — independent quality review

## Verdict: APPROVED — bounded setup correction only

No blocking implementation or test-quality defect found in the correction reviewed after spec PASS. This approves the local setup-boundary correction, not a setup rerun, vendor integration acceptance, post-setup generation/header execution, or build readiness. `ready_for_build` remains false.

Read the correction and spec-review reports, all five named changed files, and the native setup/outer dispatch chain. Recomputed all five source fingerprints and confirmed exact agreement with the spec PASS fingerprints. No source edits, remote/vendor commands, deployment, claim changes, or commits were performed.

## Implementation quality findings

- **Exact setup-only runner:** `ia840f_experimental_gate.py:253–261` first applies the existing closed command grammar, then restricts it to IP enumeration, PIM macro emission, and the two exact prepare forms. It validates the record, consumed-run claim, setup environment, and project cwd before spawning the recorded outer tool path as an argv list. Generation/header recognition elsewhere does not enable those commands through this runner. All accepted record permission lists include setup.
- **Identity separation is explicit, not a fallback:** lines 73–109 require both complete eight-tool maps, canonical recorded paths, and hashes for every tool in both maps. Only the Quartus callback requests inner PATH validation. The four fixed installed inner overrides do not relax native outer launcher resolution; the other inner paths must equal their outer counterparts. The callback separately retains actual process executable, basename argv[0], complete argv/cwd, hash, and recorded-context checks. Installed identities still require the parent's observed records; synthetic identity tests are not installation evidence.
- **Output handling addresses the actual failure mode:** lines 226–250 preserve raw merged stdout/stderr while scanning bounded chunks with enough overlap to detect split markers. Nonzero child status fails; zero child status does not override any rejection marker or Critical Warning 125091. Matching all such warnings is intentionally conservative. Waiting for the current child to finish is consistent with the stated stage-boundary contract; this is not a promise to interrupt or undo vendor-side effects.
- **Native failure propagation is sound:** rejected enumeration explicitly exits before OFSS. Macro rejection exits its subshell; the separately executed PIM script has `set -e`, so it stops before deleting/rebuilding PIM. The setup parent explicitly propagates PIM failure with `|| exit 1`. Both prepare calls explicitly propagate failure. The outer setup/tee pipeline uses `pipefail` and checks its result. The separate-executable boundary matters: the parent's OR-list does not turn off errexit inside the independently launched PIM Bash script.
- **Tcl stays conservative:** `build_gate.tcl` retains false readiness and emits the stable stderr rejection marker before raising its existing error. The monitor also recognizes the original diagnostics, so correction effectiveness does not depend solely on the new marker or on unverified vendor `qexit` semantics.
- **Tests are useful and honestly bounded:** record tests use inert identities/mocks; propagation tests execute extracted native blocks with an inert monitor harness. They cover clean/nonzero/zero-exit-warning behavior, stderr, split markers, identity separation, missing records/claims, and prohibited command forms. These substitutions are appropriate for local policy/propagation verification, but are not full authorized native setup or Quartus integration tests.

## Independently executed verification

From `ofs-agx7-pcie-attach/ofs-common/tools/ofss_config/`:

```text
PYTHONDONTWRITEBYTECODE=1 python3 -B -m unittest -v test_ia840f_experimental_gate.py
Ran 30 tests in 4.306s
OK
```

The suite also executes Bash syntax and early-entry rejection checks.

Additional local checks, without source/test edits:

1. Replayed the saved setup log through the actual `monitor_setup_output` using an inert Python subprocess. Verified **64,742 input bytes**, **four Critical Warning (125091) occurrences**, and **byte-for-byte output preservation**. The monitor rejected the zero-exit child with:

   ```text
   IA840F EXPERIMENTAL GATE: setup Quartus subprocess reported gate/Tcl rejection despite exit 0
   ```

2. Executed the **full existing PIM shell script** in a temporary fixture through a parent `script -s || exit 1` call, replacing only its `python3` command with an inert harness calling the real output monitor. Tested a stable rejection marker with child exit zero and a child exit seven. Both returned one, skipped the parent's following-stage marker, and preserved an existing PIM-directory sentinel. This supplements the suite's extracted-block coverage and directly checks the subprocess/errexit boundary before `rm -rf`.
3. Recomputed SHA-256 for all five reviewed source/test files and asserted each matched the spec PASS report exactly.

## Execution boundaries and remaining prerequisites

- Work01 remains consumed and must be preserved with its claim. This review does not authorize reuse/reset. Parent owns rotation to fresh work02, corresponding source/path/context updates, refreshed inventories/manifests, and issuance of both complete observed tool maps.
- The reviewed fingerprints describe the pre-rotation correction. Subsequent path/record changes must remain mutually consistent and be verified by the parent before execution.
- Corrected installed Quartus/Tcl integration is still unverified. Local inert checks do not establish successful installed inner-tool lookup or project loading.
- Generation/project-IP/header process-level failure enforcement remains a separate future prerequisite, not a defect to resolve by widening this setup wrapper.
- This is the stated source-bound accidental-execution guard, not an adversarial OS sandbox.

Only this review report was created as a persistent task artifact. No blocking issues encountered.

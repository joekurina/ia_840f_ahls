# Work05 independent compile-entry review

## Decision: PASS

No blocking defect found in the bounded Work05 compile gate, issuer, runner and staged draft. Accept the four gate overlays below for the native compile attempt. Carry forward the independently ACCEPTED three-file integration source delta from `qualification/fim-integration-05/independent-review.md`; do not reopen pin/QoS qualification.

This is review acceptance, **not an issued or consumed authorization**, successful compilation, or functional readiness. Parent may consume these exact review maps and invoke the reviewed issuer/runner. `ready_for_build` remains false. DDR simulation is **SKIPPED BY USER**, not passed. No hardware programming is covered.

## Reviewed behavior

- Read the full handoff report, actual compile gate and test, experimental dispatch delta, native top/compile scripts, project Tcl guard, issuer, runner and tests, draft preparation code and transferred staging/readback evidence.
- Native binding is exactly `./ofs-common/scripts/common/syn/build_top.sh --stage=compile -k -p ia840f /home/uwb_student00/ahls/new_BSP/work_ia840f_fim_05`, cwd `/home/uwb_student00/ahls/new_BSP/ofs-agx7-pcie-attach`. Compile monitor invokes the pinned launcher with `--flow compile ofs_top -c ofs_top`. No setup, finish, custom seed, analysis-only or standalone tool permission is introduced.
- SOURCE/PIM inventories, fresh WORK inventory, target/part, false readiness, explicit reviewed tool paths/hashes, native argv/cwd, runtime executable/argv/cwd/hash and dependency pins are checked. The exclusive claim binds native Bash PID/start time and authorization hash; callback checks require live ancestry of that exact native command, not just an inherited stage flag. Missing/mutated records and work/tool/source/option bindings reject before native log creation or vendor launch. The second native guard precedes work-directory changes.
- Work05 dispatch is separate from the old Work04 setup policy. Work04 authorization and claims are not reused. Work05 runtime checks read the new authorization even when reached through the copied project Tcl guard.
- Issuer requires both exact accepted maps, staged/work overlay hashes and maintained-source before-state, then reserves an exclusive issuance directory before the seven source writes. It verifies resulting full SOURCE inventories and exclusively creates/readbacks the new authorization, adding the consumed-review file hash. A failed partial synchronization retains its lock and does not silently retry or become permission. Parent consumption remains a trusted operation; this is not cryptographic reviewer identity or OS containment.
- Runner checks the owned tmux session, sanitizes compile option environment, explicitly selects the current Quartus and sopc-builder PATH and license, validates authorization/work and absence of claim, then exclusively reserves `run/` before evidence writes. Invocation/log creation is exclusive; status updates occur only within that reservation. It returns child nonzero status, converts zero plus gate markers to failure and preserves evidence against reruns. Native shell itself can normalize a deeper tool failure to rc1; the runner propagates the native child's actual return code.
- Streaming gate monitor and outer log check retain rejection markers including `IA840F_GATE_REJECTED`, `IA840F NOT READY`, `IA840F EXPERIMENTAL GATE:` and `Critical Warning (125091)`. The monitor rejects acceptance, not immediately terminates all vendor work on a downgraded QSF error. This matches the bounded trusted-vendor execution policy; it is not an exhaustive syscall monitor or sandbox.

## Independent checks and evidence limits

- Recomputed all seven overlay hashes against local actual source, the transferred overlay map, draft SOURCE entries and draft WORK entries: exact equality. Compared all five full local SOURCE inventories with the draft: exact equality. Compared staged WORK inventory with draft inventory: exact equality (5,563 entries).
- Recomputed issuer, runner and draft hashes below. Issuer/runner hashes match draft dependency pins; local overlay-map, source-before and staging-receipt hashes also match those pins. Transferred handoff receipt reports the same draft/overlay hashes and remote unchanged Work04/SOURCE readback. No fresh remote read or remote write was performed by this reviewer; staged equivalence is grounded in the transferred readback records and matching pinned content, not a new live remote attestation.
- All 73 draft runtime argv contexts exactly equal the actual gate's finite source-derived grammar; cwd is exactly the Work05 project. Ten runtime tools and 103 dependency pins are recorded. These are permitted source-derived alternatives, not observations from a full compile. Unknown real vendor contexts must fail and be reviewed from preserved evidence, not silently broadened.
- Executed `PYTHONDONTWRITEBYTECODE=1 python3 -m unittest test_ia840f_experimental_gate test_ia840f_compile_gate` from `ofs-common/tools/ofss_config`: **50 tests PASS**. Executed `test_runner.py`: **3 tests PASS**, with actual inert Python children including rc7 propagation, zero-plus-marker rejection, exit-only success and byte-preserving rerun rejection. `bash -n` on modified compile script passed. No vendor tool was executed.
- Initial unittest discovery from repository root produced nine subcase failures in an existing subprocess import test (`ModuleNotFoundError`); rerunning from the test module directory resolved all 50 tests without source edits. This was a test-launch cwd issue, not a gate correction.
- Functional/include closure, actual callback compatibility, pin-name elaboration, fit/timing and fresh assembly remain native-tool acceptance. Inspect actual fresh `.asm.rpt`/SOF and fit/timing reports even if native exit is zero; no working FIM or PR release is claimed here.

## Additional reviewed pins

| Artifact (under this qualification directory) | SHA256 |
|---|---|
| `issue_authorization.py` | `6d32a4b31bb1cbea28afc7b8fbadd62e34065ea8fe7142699dbef947efdfa424` |
| `launch_native_compile.py` | `9130fcc486c2830d62d5a7dbc25527e9370b2ce73c18378a667f8419bd0a3c35` |
| `remote-evidence/compile-authorization.draft.json` | `46c30801c8a25d53f76857570ae06a5afb2b7d77035d95e596aa92d58c2d0da7` |

The reviewed draft has `approved`, `accepted_execution`, `source_review_consumed`, `gate_review_consumed` and `ready_for_build` all false. This reviewer did not change those values.

## Exact acceptance maps — review output only

Derived from `remote-evidence/overlay-sha256.json`, independently hash-checked above. This embedded object is not a remote consumption receipt; parent owns creating that receipt after consuming both independent reviews.

```json
{
  "source_review": {
    "accepted": true,
    "files": {
      "syn/board/ia840f/setup/emif_loc.tcl": "a48a84b89fd6c5d5fd36c87cfe5c7d03264f3dea08ea6a447151351a21b523c3",
      "syn/board/ia840f/source_manifest.json": "82d5dabdc760bb24128ab0c9a5c96650da2d72f6d16f88f2d0d1780e4e745b0e",
      "ofs-common/src/fpga_family/agilex/mem_ss/mem_ss_top.sv": "b9b0deb0582d554cb2178ed4ee090c088d9841951b19d1223cd4ca96bd9498a1"
    }
  },
  "gate_review": {
    "accepted": true,
    "files": {
      "ofs-common/tools/ofss_config/ia840f_experimental_gate.py": "06edce372f3267f86071174c5f9624656be5ed9ad8f1d43e8a00e6eb637179f1",
      "ofs-common/tools/ofss_config/ia840f_compile_gate.py": "e4971f81975c03dc4e8ea8536c985c2bd54d52982a33da9bfabefe9070f1f3a1",
      "ofs-common/tools/ofss_config/test_ia840f_compile_gate.py": "d53dd05b86fbb93393033b6aef170e31ab7fbd517a0fb00259ffc603268e26e2",
      "ofs-common/scripts/common/syn/build_fim_compile.sh": "0514c9be94702a7ec87e16d6e90d844e37a48d097aecc73a0a731331650c7c07"
    }
  }
}
```

## Reviewer writes

Only this local review report was created. No production edit, remote operation, authorization issuance/consumption, compile, DDR simulation, commit or hardware operation.

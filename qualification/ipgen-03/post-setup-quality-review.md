# Work03 post-setup wrapper — independent quality review

## Decision

**APPROVED — no corrections required for the minimal wrapper/dispatcher and work03 rotation at the exact hashes below.** This approves local implementation quality within the accidental-execution boundary, not deployment, vendor integration, setup acceptance, generated-artifact acceptance, or build readiness. `ready_for_build` remains false.

Reviewed root: `/home/joe/Projects/Thesis/AHLS/new_bsp/new`.

Read the actual complete gate and test module, the exact proposal, implementation report, and PASS specification review. Also inspected the actual Tcl gate and compile-stage guard and read manifest readiness. The separate `ia840f_vendor_pcie.py` clock-mismatch change and its independent tests are excluded from this approval.

## Exact reviewed evidence

Paths are relative to the reviewed root; values are SHA-256 computed from actual local bytes after the test run.

| Artifact | SHA-256 |
|---|---|
| `ofs-agx7-pcie-attach/ofs-common/tools/ofss_config/ia840f_experimental_gate.py` | `005144000108164d6dd967aa50d757ce35423014cc7f00329a24391602d469e2` |
| `ofs-agx7-pcie-attach/ofs-common/tools/ofss_config/test_ia840f_experimental_gate.py` | `beb921e3f388b6649927611c45e7d601c1e1142e9a8e9b8be81b791cc50b5173` |
| `qualification/ipgen-02/post-setup-enforcement-proposal.md` | `199c52232abf220f45ba97a6ed16d1e46bbadc9b763522614a091664246b58d1` |
| `qualification/ipgen-03/post-setup-implementation.md` | `7e50b1cc28aa7f67d175b0728ab2809a280527514edd602dd45f85086ebf4e15` |
| `qualification/ipgen-03/post-setup-spec-review.md` | `0eea8397b5c6e828ab89e15955cb19fcbe31ee50a8ef5ce9d9f2aefe4976aea2` |

Independent in-memory reconstruction removed the literal proposal wrapper and dispatcher, reversed the work03 constant, and separately removed the added test block/import. Reconstructed original hashes matched the proposal:

- Gate: `53e996bddbcb7288353de3c44013eb6d27935832f1d6ed42c20d8142be4c48b2`.
- Tests: `8e701253cb597ba5bc8c81146c918e3ab2d823fb1d62e73140fbd12904b49878`.

Thus the existing monitor, grammar, loader, native checks, claim semantics, callback and original tests are byte-preserved. No reconstructed files were written.

## Quality findings

### Fail-closed preflight and child invocation

Gate lines 264–286 are small, explicit and auditable. Classification precedes record loading; only the three existing exact post-setup argument lists are accepted. The record, immutable claim, resolved project cwd, permission, copied script equality where applicable, and exact runtime context are all checked before monitor invocation. Context dictionary equality binds executable, hash, argv, cwd and kind together rather than accepting partial matches.

The child uses the recorded **outer launcher** path plus unchanged arguments as an argv list. There is no shell interpolation, arbitrary executable runner or direct substitution of the runtime ELF for the launcher. `load_record()` retains outer PATH validation; the independent in-Quartus callback retains inner PATH and actual `/proc` process checks. Synthetic tests deliberately separate outer and inner identities and reject mismatches. Missing files and malformed/broken bindings do not result in a child launch.

The copied-script relative path operation is safe within this grammar: the preceding exact-list match already fixes its WORK path. The slight duplication between wrapper preflight and actual callback is justified: calling the callback from the wrapper would inspect the wrong parent. A refactor to merge them is neither needed nor desirable in this minimal patch.

### Real output bytes and failure status

The unchanged monitor at lines 226–250 merges child stderr into stdout, reads bounded binary chunks, writes/flushes bytes without decoding, scans with sufficient cross-read overlap and waits for the actual child. Nonzero child status fails; any configured marker also fails when the child returns zero. Broad `Critical Warning (125091)` rejection remains intact. The dispatcher and existing exception handler return failure through the executable entry point.

Reviewed tests exercise real inert Python children, not simulated output return values: all three command kinds, rc7, clean rc0, each rejection marker on either descriptor, one-byte reads, empty output, invalid UTF-8 and large output. Assertions check byte preservation and failure status. The separate-process harness checks the actual Python process return code and captured bytes while injecting the fixture-validated wrapper into the dispatcher. Positive spawn-boundary assertions separately establish the precise outer-launcher argv. This is good layered local evidence, not an unmodified end-to-end vendor invocation.

The test-only sequence correctly retains failed-stage evidence and checks that later sentinels/logs and the acceptance receipt are absent. Logging is not used as the command status. It is not a production orchestration implementation and does not claim to test a shell `tee` pipeline.

### Permission scope and maintainability

No broad compile permission was added. Native stages remain limited to setup/setup-entry; the actual compile shell guard rejects IA840F before its ordinary compile command. The post-setup wrapper rejects setup grammar, executable paths, arbitrary Tcl, altered/extra/reordered flags and prohibited tool forms. The literal `--synthesis=verilog` flag requests IP output; it does not authorize a synthesis/compile stage.

The implementation follows the proposal literally, reuses the monitor rather than adding another streaming implementation, and changes no existing function bodies. Existing diagnostic wording still says “setup Quartus”; this is cosmetic, known and not a reason to expand scope. New fixture records are finalized before exclusive claim creation; tests explicitly distinguish fixture-only restoration from operational claim migration. The tests are larger than the wrapper but their separation into permissions, contexts, drift, bytes/status and orchestration cases makes failures diagnosable.

No blocking correctness or maintainability issue was found within the specified boundary.

## Independent execution

Ran the exact gate module rather than broad discovery, to avoid enrolling the other worker's independent clock tests:

```sh
# cwd: ofs-agx7-pcie-attach/ofs-common/tools/ofss_config
PYTHONDONTWRITEBYTECODE=1 python3 -m unittest -v test_ia840f_experimental_gate
```

Actual result:

```text
Ran 42 tests in 16.721s
OK
exit_code=0
```

All new wrapper tests and retained regressions passed, including existing bounded Bash rejection/no-side-effect and syntax-check tests. The existing PCIe regression in this module also passed; that does not qualify the separate helper change. No fixture vendor executable was run. Manifest JSON independently reported `ready_for_build=False`, and `build_gate.tcl` retains its explicit false assignment and rejection marker.

## Remaining operational holds and limitations

1. **Verify these gate/test hashes before deployment.** Finalize and independently review the separate helper change, then refresh affected manifest entries and complete source inventories and run combined regression checks. This report does not approve that helper's final bytes or authorize a stale manifest.
2. Preserve work02 and its original authorization/claim evidence. Archive exact predecessor bytes and transition provenance before issuing a new, reviewed, initially finalized work03 authorization. Do not extend a consumed record, renew a claim, reuse/copy work02 as work03 or use `-k`.
3. The claim proves consumption, not setup completion. Independently accept fresh native work03 setup before post-setup operations. The wrapper deliberately implements neither stage ordering nor a permanent failed-run latch. The caller must check each wrapper status, stop before the next operation on failure and preserve separate logs/status. A successful logger is not successful execution.
4. The monitor is an acceptance boundary, not immediate cancellation: a rejected child may continue writing until it exits. No timeout, adversarial race protection or OS sandbox is established. These are not new promises of this patch.
5. Local Python/Bash evidence does not establish installed launcher behavior, actual vendor project loading, supported generation syntax, full RTL/interface qualification or fresh nonempty headers. Ordinary missing-header-generator warnings still require explicit artifact rejection even if the monitor returns zero. Readiness remains false; compile, fit, assembly, finish and programming remain prohibited.

## Changes and issues

Created only `qualification/ipgen-03/post-setup-quality-review.md`. No source, test, manifest, authorization or claim edits; no remote access, vendor execution, deployment or commit. No test failure or review blocker encountered. Approval is confined to the exact wrapper/test evidence above and does not remove the operational holds.

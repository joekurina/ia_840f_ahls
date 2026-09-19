# Work03 post-setup wrapper — independent specification review

## Verdict

**PASS — the local gate/test implementation conforms to the exact minimal additive wrapper proposal. No wrapper source corrections are required.** This is a specification-conformance decision for the reviewed bytes, not deployment approval, setup acceptance, vendor integration qualification, or build readiness. `ready_for_build` remains false. Independent quality review and the separate deployment/qualification holds remain mandatory.

Reviewed root: `/home/joe/Projects/Thesis/AHLS/new_bsp/new`.

Specification: `qualification/ipgen-02/post-setup-enforcement-proposal.md`, especially lines 26–69 (literal implementation), 71–105 (execution/authorization boundaries), and 107–124 (tests and acceptance). Also read `qualification/ipgen-03/post-setup-implementation.md`; its claims were checked against source and fresh local execution rather than accepted as test evidence.

In the evidence below, **gate** means `ofs-agx7-pcie-attach/ofs-common/tools/ofss_config/ia840f_experimental_gate.py`; **tests** means its adjacent `test_ia840f_experimental_gate.py`.

## Exact implementation and preservation evidence

An independent read-only Python check extracted the two Python blocks from the proposal, required the complete proposed wrapper text to occur in the current gate, and required the proposed dispatcher branch with only its enclosing indentation added. Both matched. The check then removed precisely those additions and reversed the WORK rotation. It separately removed the new test helper/class block and reversed the added `contextmanager` import. Both reconstructed SHA-256 values matched the original values published in the proposal.

Actual output:

```text
exact_proposal_wrapper_and_dispatch=PASS
gate_sha256=005144000108164d6dd967aa50d757ce35423014cc7f00329a24391602d469e2
tests_sha256=beb921e3f388b6649927611c45e7d601c1e1142e9a8e9b8be81b791cc50b5173
reconstructed_original_gate_sha256=53e996bddbcb7288353de3c44013eb6d27935832f1d6ed42c20d8142be4c48b2
reconstructed_original_tests_sha256=8e701253cb597ba5bc8c81146c918e3ab2d823fb1d62e73140fbd12904b49878
original_bytes_preserved=PASS
new_test_methods=12
```

Thus, relative to the proposal's recorded baseline, the gate delta is exactly the wrapper, dispatcher, and `work_ia840f_ipgen_02` → `work_ia840f_ipgen_03` constant rotation. All original gate functions and original test bytes are preserved; this is stronger evidence than a tracked diff for these untracked files. WORK/PROJECT are fixed at gate lines 25–29; the explicit regression is tests 532–534.

## Requirement-by-requirement review

| Boundary | Source and test evidence | Decision |
|---|---|---|
| Closed command grammar | Gate 112–140 retains exact list equality for the WORK `emit_project_ip.tcl` assignment-output command, bounded `quartus_ipgenerate` generation flags, and WORK header Tcl command. New wrapper 265–267 accepts only `project_ip`, `generate`, `headers`. Tests 552–588 reject setup commands, SOURCE post-setup scripts, executable paths, arbitrary scripts/tools, each argument's removal/mutation/duplication, extra/reordered flags, alternate simulator and parallel mode. Existing grammar tests 24–78 remain intact. | PASS |
| No synthesis/build widening | `native()` 193–205 still accepts only `setup`/`setup-entry`; tests 134–139 reject all/compile/finish/synthesis/fit/assembler before record access. Wrapper grammar cannot authorize compile, synthesis tools, fitting, assembly, finish or programming. Existing shell early-denial tests 887–911 passed. `build_fim_compile.sh` 37–40 still guards before its ordinary compile invocation at 102–112. `--synthesis=verilog` remains an exact IP-generation flag, not native synthesis permission. | PASS |
| Record and source binding | Wrapper 268 calls unchanged `load_record()` with its default outer context. Gate 73–109 validates approved/schema/part/toolchain/fixed roots/readiness, exact permission alternatives, full source-tree coverage, PIM inventory, aliases, both tool maps and selected PATH. Inventory 49–66 excludes only its specified record/bytecode cases. Tests 607–648 exercise source/PIM/gate/test drift, readiness and record/permission failures before monitor invocation. | PASS |
| Immutable claim | Wrapper 269 calls unchanged `check_claim()`; gate 150–157 rejects claim symlinks and compares the claim to the complete fixed SOURCE record's byte hash. Native exclusive creation remains 200–205. Tests 608–624 cover missing/changed/symlink claim and serialization-only record drift. Tests 684–705 demonstrate permission extension fails without changing the original claim and a distinct new fixture succeeds while old record/claim bytes are preserved. Original single-run regression 281–289 is retained. | PASS |
| Permissions and output cwd | Wrapper 270–274 requires resolved PROJECT cwd and `generate` for project-IP/generation, `headers` for header emission. Tests 536–550 exercise all three commands against separately finalized setup-only, setup+generate, and setup+generate+headers records. They also make any accidental `setup_environment()` call fail. | PASS |
| WORK script equality | Wrapper 275–278 hashes each copied WORK Tcl script against its SOURCE counterpart. Exact grammar fixes the permitted WORK path before `relative_to(WORK)`. Tests 650–662 reject both missing and drifted copied scripts before spawn. Actual-callback equality checks remain gate 170–172 and original tests 375–407. | PASS |
| Runtime contexts and launcher selection | Wrapper 279–286 requires exact dictionary equality for runtime executable/hash/argv/cwd/kind, then launches the recorded outer path with unchanged argv through the monitor. Runtime paths remain `/opt/altera/26.1.1/quartus/linux64/{quartus_sh,quartus_ipgenerate}`. Tests 497–507 deliberately separate inert outer/inner identities; 590–605 independently mutate every context field or remove the context before finalizing the record/claim. Positive launcher assertions are 545–546. | PASS |
| Independent actual-process callback | Gate 160–176 still uses `load_record(quartus_inner=True)`, `/proc` parent executable/argv/cwd, basename argv[0], permissions, copied-script equality and exact recorded context. New callback fixtures 664–682 cover all three kinds and permission sets, outer-versus-inner executable mismatch, absolute/empty argv[0], cwd and extra args. `/proc` reader remains gate 143–147. Fixtures do not claim to be real Quartus process observations. | PASS |
| Output/CLI propagation | Unchanged monitor 226–250 merges stderr into stdout, streams raw bytes, carries marker overlap across reads, waits for termination, and rejects nonzero status or any marker at rc0. Wrapper uses it directly; dispatcher 295–296 and existing handler 301–304 propagate failures. No shell command construction or `shell=True` was introduced. Tests 707–794 exercise real inert Python children through the wrapper/dispatcher, all kinds, rc7, every marker on either descriptor, one-byte reads, empty/invalid-UTF-8/large output, byte preservation, spawn failure, and a separate Python-process return status. | PASS |
| Stop-before-next-stage | Tests 796–822 run a checked-status test-only sequence, preserve per-stage logs/status, and verify rejection at every position leaves later sentinel/log files and acceptance receipt absent. Both rc7 and rc0/125091 are tested; clean runs reach all stages in order. This is not a production orchestration script or a `tee`/PIPESTATUS integration test, and none is claimed. The proposal permits checked subprocess status as the alternative to a shell pipeline. | PASS |

The actual Tcl callback entry was also inspected: `syn/board/ia840f/setup/build_gate.tcl` lines 4–11 retains readiness false, invokes `python3 ... quartus`, and emits `IA840F_GATE_REJECTED` before its Tcl error. The unchanged monitor recognizes this marker, `IA840F NOT READY`, `IA840F EXPERIMENTAL GATE:`, and broad `Critical Warning (125091)` (gate 22–23). No narrowing to only the current Tcl message occurred.

## Independent execution

Executed from the actual ofss_config directory with bytecode disabled:

```sh
PYTHONDONTWRITEBYTECODE=1 python3 -m unittest discover -v -s . -p 'test*.py'
```

Actual result from this review:

```text
Ran 42 tests in 14.322s
OK
exit_code=0
```

All 12 new `PostSetupTests` methods and all retained policy, record, output-propagation, shell-denial and PCIe regression tests passed. The fixture vendor identities are inert files and were not executed. Child execution is Python and the existing bounded shell rejection/harness paths, not vendor tools or native initialization.

`git diff --check` returned zero for both the FIM repository and nested ofs-common repository. Their status shows existing modifications and untracked files, including the reviewed gate/test and a preexisting bytecode directory; a clean working tree is not asserted. An initial status command at `new/` failed because that directory is not a Git repository; subsequent checks used the actual child repositories. No cleanup or source edits were made.

The manifest was read as JSON and reported `manifest_ready_for_build=False`; its top-level readiness is also visible at `syn/board/ia840f/source_manifest.json:3`. The Tcl readiness assignment and loader's mandatory false value independently remain present. This review did not refresh or validate new deployment inventories.

## Scope limitations and remaining holds

1. **No source correction is required for this wrapper patch.** The proposal's manifest refresh, complete inventories, reviewed tool identities, archived predecessor authorization/claim evidence and append-only transition receipt remain separate pre-deployment work. Passing this review does not mean the proposal's complete operational transition has been performed.
2. Preserve work02 and its original claim/record evidence. Do not renew a consumed claim, mutate a consumed record, reuse/copy work02 as work03, or use `-k`. Work03 needs an initially finalized authorization and a fresh exclusive claim/native setup under the reviewed transition.
3. A claim proves consumption, not successful setup. Independently accept fresh work03 setup before the three monitored operations. This minimal patch deliberately does not encode that acceptance receipt, stage order or a permanent failure latch. The caller must stop on each failed wrapper status and preserve separate logs/status; a logger must not mask failure.
4. Local tests do not establish installed Quartus launcher behavior, Tcl project loading, generation syntax support or vendor output acceptance. Monitor success is necessary but does not establish complete RTL, generated interfaces, memory/BMC/FLR qualification, or fresh nonempty headers. In particular, the ordinary missing-header-generator warning requires separate artifact acceptance. The monitor waits for exit rather than immediately canceling vendor writes.
5. Mid-review steering reported a separate worker investigating/editing only `ia840f_vendor_pcie.py` and separate helper tests for the ignored AXI-Lite clock request. That change is outside this wrapper review. The reported 42-test execution completed before that steering message; no helper-related test failure or hash race was observed in this run. This report does not approve the helper change or assert its final hashes. Deployment must wait for both reviewed changes, refreshed manifests/inventories, and the required combined regression checks.
6. The source-bound guard is not an OS sandbox against an operator able to edit code or authorization evidence. Existing policy limitations have not been presented as protections added by this patch.

## Review artifacts and actions

Created only `qualification/ipgen-03/post-setup-spec-review.md` (this report). No source, test, manifest, authorization or claim was edited by this reviewer. No remote access, vendor execution, deployment or commit was performed. Independent quality review follows; `ready_for_build=false` remains in force.

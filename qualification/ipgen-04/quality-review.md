# Integration05 / prepared Work04 — independent quality review

## Disposition

**Mailbox integration05: PASS. Prepared Work04 deployment/orchestration: NEEDS TWO NARROW REPAIRS before execution.** The source/tool binding and Work04 rotation are coherent; the execution-wrapper defects below concern failure reporting and preservation of invocation evidence. Continuing user approval is in scope and is not a missing prerequisite. `ready_for_build` remains false.

This is a local static review plus local inert regression checks, not remote deployment, a vendor run, or BSP/hardware qualification. Reviewed root: `/home/joe/Projects/Thesis/AHLS/new_bsp/new`. Read integration report, receipt and PASS specification review before inspecting source evidence. Parsed the large deployment constants with AST/literal evaluation; did not execute the deployment or issuer.

## Required repairs

### Q1 — setup wrapper returns success after failed native setup

**Location:** `run-setup.py:10–11` (end of file).

`subprocess.run()` does not use `check=True`. The wrapper correctly writes the child's nonzero `returncode` into `setup-result.json`, but then falls off the end without exiting nonzero. A shell, tmux launcher or automation checking the wrapper process will observe success after failed setup. Printing `SETUP04_COMPLETE_EXIT 7` is not exit-status propagation.

**Local reproduction:** executed the actual AST statement bodies in a fully in-memory harness, replacing filesystem/environment/subprocess dependencies with fixtures. With a mocked child return code 7, output was `SETUP04_COMPLETE_EXIT 7`, followed by normal Python fallthrough (process status would be 0). No native script or vendor tool ran. The same harness confirmed that the post-setup wrapper correctly raises `SystemExit(7)` on its first failed child.

**Narrow repair:** after persisting the setup result, exit with the child status (for example `raise SystemExit(p.returncode)`). Add a runner-level inert-child regression proving a nonzero setup child produces a nonzero wrapper exit while retaining its result/log. The gate's existing subprocess tests do not cover this outer runner.

**Containment already present:** `run-post-setup.py:4` independently reads and rejects a nonzero setup receipt, so this bug does not by itself make that runner accept failed setup. It nevertheless violates the required error propagation and can mislead its caller.

### Q2 — rejected reruns overwrite the original invocation receipt

**Locations:** `run-setup.py:9–10`; `run-post-setup.py:13–14`.

Each wrapper writes its `*-invocation.json` with truncating `write_text()` **before** attempting the exclusive `*-full.log` open. On rerun, the existing log correctly blocks a second child, but only after the first run's invocation receipt has been replaced with the second attempt's start time/environment. The original result and log survive, yet the primary invocation evidence no longer describes them. This also occurs after a failed run, not just successful completion.

**Local reproduction:** in the same in-memory AST harness, ran each wrapper with child rc7, saved its invocation bytes, then invoked it again. Both second attempts raised `FileExistsError` at their log open; both invocation receipts had already changed. The only second-attempt filesystem event in each fixture was the invocation overwrite. No actual filesystem evidence was changed by this reproduction.

**Narrow repair:** reject an already-used stage before any existing evidence is written; use exclusive creation for invocation and result receipts as well as logs, reserving the stage before launching its child. Existing logs, results and invocation bytes must remain unchanged on a rejected duplicate. Do not clear claims or delete failed logs to make a retry work. Add runner-level duplicate-attempt tests for setup and post-setup. This is a small orchestration repair, not a request for new approval machinery.

## Accepted integration and provenance

Independent local checks established:

- Both maintained XML files are byte-for-byte equal to the accepted refresh02 UTF-8 payloads. Hashes are `e3571b6d6b0e04bcc488be3c0a309571c2ccb6a0564c530f43b41dabe4cfd82a` for `bmc_spi_sub.qsys` and `b6b28be4555938f513102b9a32ac99dc40a61083bb6b063c8f2c20b03e54a8c6` for `sdm_mailbox.ip`.
- Recomputed 13 receipt-listed maintained/before-copy/evidence checks; all matched. This includes all three maintained artifacts, their before copies, four source-evidence files and three separately listed before-copy hashes.
- Both manifests contain 99 file entries. Exactly two entries differ; original donor `source` and `source_sha256` are unchanged and each `prior_sha256` equals the before entry's hash. The only changed top-level fields are `files` and the new scoped `mailbox_migration_integration_05` provenance object. Readiness remains false.
- All 32 other receipt-inventoried BMC files match current maintained bytes. The accepted specification review independently establishes the broader generation05 inventory and interface claims; this review adds exact integration/provenance checks rather than claiming a new vendor generation.

No integration-quality defect was found. Historical generation success is correctly distinguished from full BSP/hardware acceptance. The implementation receipt's pending-review language is historical implementation status, not evidence that the supplied PASS review is absent.

## Accepted Work04 preparation

- The deployment embeds exactly five files: the two mailbox replacements, their manifest, the gate and its test. Every decoded payload self-hash and current maintained-file hash matches. Each gate/test predecessor hash is recovered by reversing **only** `work_ia840f_ipgen_04` to `work_ia840f_ipgen_03`; there is no hidden gate logic or test relaxation in this rotation.
- AST-extracted `EXPECTED` matches every current non-Git file under the five bound source trees with no missing, extra or mismatched source inputs. Against Work03's recorded expected inventory, the non-Git changes are exactly those five deployed files. PIM expected hashes are unchanged. Local Git metadata appears in the new constant, but issuance intentionally excludes `.git` from cross-machine parity and then records the actual remote inventory for subsequent exact checks; it is not silently excluding source files.
- `INNER` and `OUTER` identities are unchanged from the predecessor deployer. Issuance explicitly checks observed outer identities against `OUTER` and hashes every inner tool, then calls `g.load_record()` to revalidate the completed record. This is prepared enforcement, not a claim that remote tools were checked during this review.
- The issuer constructs all seven initially bound contexts: two `prepare`, `ip_lib`, `pim_macros`, `project_ip`, `generate`, and `headers`. AST-only evaluation against the gate's closed grammar classified all seven successfully. All context cwd values resolve by construction to the Work04 project; no Work03 command context remains. Work03 references in the deployer are deliberate predecessor-claim/archive checks.
- Deployment checks the predecessor record SHA-256 `a19998d51fa0b7bf5e2d5dfac99e50d16f28f85fd3cdbc569a707cb2401ff7f0`, its Work03 claim, the old gate's loaded record and every old payload hash before replacing source. It creates a new qualification directory, backs up old source bytes, exclusively archives the exact authorization, then replaces sources and removes only the active authorization pathname before fresh issuance. It never edits Work03 work/output/claim, and checks the old claim again at the end.
- New Work04 work/claim absence is checked in preparation; native setup additionally rejects aliases/existing paths and consumes an exclusive claim. A failed run's claim is not removed. The new authorization is created exclusively with approval true, readiness false and the explicit setup/generate/headers permission list. It is read back and validated before an issuance receipt is written.
- Post-setup checks successful setup status plus gate/Tcl rejection markers before launch. Its exact stage sequence stops on nonzero wrapper status. The underlying gate monitor still rejects nonzero vendor exits and rejection markers even when a vendor exits zero; copied Work Tcl scripts remain hash-bound to SOURCE. No compile/readiness permission was added.

These checks support the prepared binding and rotation, subject to Q1/Q2. They do not establish remote prerequisites, successful fresh setup, generation completeness or nonempty valid generated headers. Those require actual subsequent run evidence, not another user-approval barrier.

## Executed local checks and reviewed hashes

Ran from `ofs-agx7-pcie-attach/ofs-common/tools/ofss_config`:

```sh
PYTHONDONTWRITEBYTECODE=1 python3 -B -m unittest test_ia840f_experimental_gate test_ia840f_pcie_csr_clock
```

Actual result: **49 tests, 7.829 seconds, OK, exit 0**. These tests plus the separate in-memory runner reproductions are local evidence only. Neither a vendor executable nor the real deployment/runner entry point was invoked.

| Prepared artifact | Reviewed SHA-256 |
|---|---|
| `deploy-work04.py` | `3c7540e19fb8ac98be2152e6ffd8f68d94516c72839ebf330d9ca528efec2d9a` |
| `run-setup.py` | `e0cb26733b121d45411a78403f16f5d86109c64cedc63095331e1d1b262bb378` |
| `run-post-setup.py` | `8e66fe11b0137eed82e3e096d77c1f4d6e6e182df6c1820187d31dec92153f15` |
| maintained gate | `6084d5f5509e46e8da916d97392a05de464d2cbd2e8afd32b7720cf729ebdb30` |
| maintained gate test | `cb20ed275febd618621859059ca9ba8c6b6eed284c35c367c855234407120070` |

Created only this report. No maintained source, runner, authorization, existing evidence or claim was edited; no remote execution, deployment or commit occurred. A missing bare `python` command was handled by using `python3`; the initial fixture harness needed a missing mocked `STDOUT` constant and was rerun successfully. Neither affected reviewed artifacts.

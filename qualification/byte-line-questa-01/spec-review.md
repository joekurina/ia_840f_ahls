# Corrected byte-line Questa package — spec review

**Verdict: NOT READY under the documented whole-directory transfer procedure — one packaging/procedure defect.** The original two dependency defects are corrected. No additional source or acceptance-gate defect was found in this review. This is a static preparation review, not HDL qualification: **154 planned cycles, 0 executed HDL cycles**.

## Exact remaining defect

### R1 — Required review artifact conflicts with the sealed inventory and whole-directory transfer instruction

`run.py:148-151` requires the complete recursive file set to equal the 24 entries in `package-sha256.json` plus the manifest itself. `README.md:52-53` instructs the operator to transfer this entire directory without extra files. The required review creates `spec-review.md` in that directory, but the execution manifest must remain pinned and does not include this report. Consequently, transferring the entire reviewed directory and following the documented invocation causes `Unexpected/missing package files (including caches)` before any vendor stage, even when every pinned byte is correct. Other parent review reports would have the same effect.

This is a deterministic inventory/procedure conflict, not a Questa diagnostic or a reason to weaken the runner. The manifest-set comparison was checked in memory: adding `spec-review.md` changes equality to false. No runtime identity guard was bypassed and no vendor process was started.

**Required resolution:** explicitly define the transferable execution payload as exactly the manifest-listed files plus `package-sha256.json`, retaining this report and any other review artifacts separately. Verify that exact payload after transfer against the separately retained manifest pin. Do not re-pin the manifest merely to absorb review outputs, delete original evidence, or loosen inventory checking. This review does not implement that transfer or modify the instructions; the documented whole-directory procedure still needs correction/explicit supersession before execution.

## Prior findings and execution contract

- **Actual sources preserved:** independently hashed all 13 copied inputs and their recorded source paths. Every size and SHA-256 matches. This includes the ten original maintained DUT/PIM inputs, the actual additional `ccip_if_pkg.sv`, and the unchanged bench/configuration fixture. No substitute DUT, interface or package is used.
- **Missing macro repaired:** `run.py:20-22,196-197` supplies exactly `OFS_PLAT_PARAM_HOST_CHAN_NUM_PORTS=1`, `OFS_PLAT_PARAM_HOST_CHAN_DATA_WIDTH=512`, and `OFS_PLAT_PARAM_HOST_CHAN_MMIO_ADDR_WIDTH=18`. The clock declaration and actual CCI-P package dependencies are covered. These remain compile-only synthetic fixture values, not generated board geometry or ABI claims.
- **Missing package repaired:** `sources.f:2-6` compiles the real CCI-P package before the real log package, Avalon interface, adapter and unchanged bench. `+incdir+inputs` and the staged working directory provide portable dependency paths. The unchanged top configuration suppresses legacy compatibility only; native-class wrappers remain inactive and interface validation is not disabled.
- **Behavioral scope preserved:** reviewed the adapter and bench oracle. Static expansion gives 154 planned cycles and 160007 planned checks, matching the prospective terminal marker `PASS scenarios=154 checks=160007`. The reset case is correctly described as reset/stall overlap only, not interruption of an already-held stalled transaction. The alternating-stall offset sweep and synthetic storage/response limitations remain disclosed.
- **Preserved evidence/fresh outputs:** the runner rejects an existing output path, package descendants and ancestors, reserves a fresh output directory, and exclusively creates stage evidence. Original source/evidence paths are not execution destinations. The three copied provenance records are byte-identical to the originals.
- **Remote prerequisites:** hostname `Agilex7Workstation`, real/effective UID 1000, nonempty `TMUX`, readable license, override directory and executable paths are checked before output creation or tool invocation. The documented TMUX assertion is not represented as an anti-spoofing boundary.
- **Execution evidence and bounds:** exact stage argv, working directory, environment, version logs, combined stdout/stderr, return codes and timeouts are recorded. Tool/source/configuration hashes are captured. Stages are ordered, and any failed prerequisite or compilation prevents simulation. Timeout handling kills the stage process group and records rc 124; positive native failures propagate.
- **Acceptance:** the console parser requires ordered CHECKED entries 1 through 154, one exact PASS marker, simulation rc zero and no error/fatal/failure diagnostics. A clean native transcript is also required. Final package, staged input/configuration and tool comparisons can revoke a tentative PASS. The fail-closed simulation do-string is retained.
- **Unverified vendor behavior remains explicit:** installed option compatibility, isolated ini behavior, licensing, compilation, elaboration and `$finish` exit behavior are not established by this package or review. A future execution must satisfy all gates; no actual simulation PASS is claimed.

## Verification and write scope

- Verified all **24 pinned package entries**, with no hash/size mismatches and no extra files before creating this report.
- Verified all **13 input copies and original source paths** against the expanded input manifest.
- Verified byte identity of the copied original before/after manifests and prior spec review against `../byte-line-protocol-01/`.
- Parsed `run.py` and `test_runner.py` with Python AST parsing. Exercised only the pure transcript parser in memory: a synthetic valid transcript qualified; duplicate PASS, nonzero rc, injected error and changed CHECKED ordering were rejected. These strings are test data, never HDL execution evidence.
- Read the existing inert-test log reporting four successful tests; did not rerun the file-writing suite because this task authorizes only this report write.
- Pinned execution manifest: `package-sha256.json`, **3276 bytes**, SHA-256 **`ec6800e15dff71f9b57ce51e39111cb1db9b4c55d9683896a7aa00bf1fae8fbe`**. It is unchanged; this report is deliberately not included in it.

Only `spec-review.md` was created. No maintained source, bench, runner, manifest, original evidence or other package file was modified. No remote contact, vendor execution, installation or commit occurred.

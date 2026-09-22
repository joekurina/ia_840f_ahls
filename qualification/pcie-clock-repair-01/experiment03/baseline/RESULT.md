# Experiment03 baseline result — native failure, incomplete comparison

**Native/effective/outer rc3. Termination confirmed; originals unchanged. Candidate NOT AUTHORIZED / NOT RUN. Failed-result independent review pending. Timing NOT ACCEPTED.**

The [package acceptance](../ACCEPTANCE.md) followed SPEC PASS and QUALITY APPROVED; it was experimental permission, not prediction of native success. Baseline issued once in @44/%44 at `2026-09-22T10:21:57.835521+00:00`; native PID19117 ran from `10:22:00.801273` to `10:22:40.075800` UTC. [Status readback](status01.json) binds the exact issuance/authorization and shows the native PID absent afterward. The outer pane returned to the shell with rc3. Authorization SHA256 `1716b6c4cb4fa480c374a130d1d026588d2acbe54dbdf4921ae5999bed051e13` is spent; never reissue or rerun this phase.

## Actual failure and evidentiary limit

[Full log](result-readback01/query.log):574–607 reports Error23035, `CLOCK_REPAIR_REJECT clock load cardinality/cap`, then Error23031. The actual [query](prepared-readback01/query.tcl):69–73 resolves the exact output pin, computes `get_fanouts -clock $output`, and rejects unless `load_count > 0 && load_count <= 4096`. **It emits LOAD_COUNT only after that assertion. No LOAD_COUNT is present; therefore this capture does not distinguish zero from greater-than4096.** Do not invent a count, claim zero fanout, increase the cap blindly, or treat this as proof that a source clock repair fails.

Only the audit report was produced. Its tag counts are `{'BEGIN': 1, 'CLOCK': 80, 'MEMBERSHIP': 6}`; it ends after clock-membership records. There is no receiver/adjacency/corner/path/completion evidence from this run, no generated-clock candidate result, and no numerical A/B timing comparison. Prior accepted Query02 receiver fanin findings remain distinct evidence, not a substitute for this missing load enumeration.

Native warnings by code: `{'332049': 133, '332174': 53, '332054': 14, '332060': 1, '22890': 78}` (279 total). Code22890 warnings at query:64 come from requesting generated-only properties while inventorying base clocks. They are separate from the fatal load check. The existing unassigned-divider Warning332060 remains at log:493, followed by a named downstream-register clocking relation at :494.

## Preserved evidence

- [Result archive](result01.json.gz): SHA256 `4f7374d66e519a6fe41c43d80af9946de455383431507984e604c4ca90462cb1`; eight exact exports verified against [manifest](result-manifest01.json).
- [Parent verification](result-verification01.json) verifies all export hashes/sizes and report manifest. [Native result](result-readback01/native-result.json) has `termination_confirmed:true`, no supervision errors and no final live PIDs; [execution status](result-readback01/execution-status.json) retains native/effective3 and expected missing-completion/diagnostic errors.
- [Preservation](result-readback01/preservation-after.json): Work14, maintained SOURCE and PIM are each literally true. [Status](status01.json) records candidate authorization absent.

Next: independent failed-result review plus a source-grounded query diagnosis using retained installed API help and accepted fitted evidence. Any new query or collector uses fresh identities, unchanged scientific constraints unless separately justified, actual preparation and fresh SPEC→QUALITY→parent acceptance. Preserve experiment03 and its unissued candidate; no fit, maintained-source promotion or hardware operation is warranted by this failure.

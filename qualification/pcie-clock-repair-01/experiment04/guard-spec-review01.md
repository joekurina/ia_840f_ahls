# Experiment04 independent guard-component SPEC review01

## Verdict

**BLOCKED — one narrow component SPEC gap: the postcreation output-pin lookup does not record/flush its raw count before asserting cardinality.** The additive association-versus-definition correction and all 34 existing inert cases otherwise check out. This is a diagnostic-evidence compliance defect, not an observed unsafe creation or native failure.

Review contract: `GUARD-SPEC.md` in full. `IMPLEMENTATION-PLAN.md` was read in full as future integration context, not as current component acceptance criteria. The unfinished query/report, runner/gate/preparer, prepared bindings and full-package reviews are **not** reasons for this verdict.

## Blocking finding F1 — legacy postcheck bypasses count-before-assert

- **Requirement:** `GUARD-SPEC.md:6` requires recording/flushing counts before assertions while retaining exact pin identity, direction/type and cardinality.
- **Implementation:** `clock-repair.tcl:186` calls the original `one_pin` for the postcreation O lookup. That original function performs `get_collection_size == 1` immediately at `:20`, with neither a preceding count record nor a flush (`:18–25`). On zero or multiple matches, its rejection message contains the pin name but not the observed count. The `raw_names_v2` call at `:187` is for the later clock-association collection and cannot record the failed pin lookup. The insertion-time O count at `:121` is an earlier observation, not the count of this new postcheck collection.
- **Consequence:** an unexpected postcreation/full-SDC pin cardinality still rejects, but loses the exact observation required by the component contract. Preservation of the old function is correct; selecting it from the new verification path does not satisfy the new logging requirement.
- **Regression gap:** `test-guard-v2.py:46–55,165–168` injects missing/multiple output pins from the beginning, so those cases reject in `apply_v2`, before creation. No case introduces the pin fault only after creation. The harness collects `puts` events at `:22–24` but does not assert their contents/order; `flush` is an inert no-op.
- **Minimal fix:** leave the original 4865-byte prefix untouched. Route this new postcheck through an additive, `ia4_`-local pin validation path that emits and flushes the actual pin count before its cardinality assertion and retains the exact name/direction/type checks. Add inert post-only zero/multiple-output-pin cases that verify rejection after one creation, the retained created flag, and count/flush ordering before rejection. No additional native precondition run or broader package feature is requested.

This finding is established by source inspection; I did not execute an extra probe or modify the frozen harness to demonstrate it.

## Verified component behavior

- **Additive preservation:** the complete predecessor helper is an unchanged byte prefix. The saved unified delta exactly reproduces the current additive change. New support-procedure locals are prefixed; the original `apply` remains intact and remains unsuitable for the future entry.
- **Correct creation distinction:** `apply_v2` separately requires absent C, no explicit O/K definition targets, exact upstream-M output-driving association and the expected PLL target for M (`clock-repair.tcl:134–150`). This corrects the original contradiction without accepting an empty/extra association. Saved `get_clocks` help at `../api-help01/commands/get_clocks.txt:12,38–42` explicitly distinguishes target and driving associations.
- **Precreation structure and grammar:** exact I/O names, clock-pin directions, singleton divider/name/type, singleton M, physical fanin and incoming M are checked. New precreation collection paths record and flush raw counts. Creation is exactly the specified name/source-collection/master/divide-by-two/output-collection command, without `-add`, nominal period, phase, inversion or fallback. The created flag is set before subsequent postcreation assertions (`:150–152`).
- **Bounded global comparison:** snapshots capture clock name/type/period/waveform/targets and generated master/source/ratio fields; generated-only fields are skipped for base types. Raw counts and duplicate identities are checked, with clock cap256 and target cap4096. The immediate and verification-time comparisons require C-only addition and equality of every other captured definition (`:80–114,139,152,162`).
- **Generated-C verification:** the implementation asserts the exact generated type, target O, source I, immediate master M, integer divide2/multiply1, non-inversion, period/waveform relationships using returned decimal precision, and exact output C association. Edge/shift metadata is logged, not invented. The even divide-by-two relation is consistent with the saved creation help's `{1 3 5}` equivalence (`../api-help01/commands/create_generated_clock.txt:62–89`). The output-pin logging exception is F1 above.
- **Single-use behavior:** the current positive cases test second-invocation rejection without another creation. Source inspection confirms the created flag is retained when later checks fail; no helper code resets it after creation.

## Independent permitted execution

After reading the helper and complete harness, I ran only the authorized behavioral entry, captured entirely in memory without overwriting the saved receipt:

```text
cwd: /home/joe/Projects/Thesis/AHLS/new_bsp/new/qualification/pcie-clock-repair-01/experiment04
argv: python3 -B /home/joe/Projects/Thesis/AHLS/new_bsp/new/qualification/pcie-clock-repair-01/experiment04/test-guard-v2.py
return code: 0
stderr: empty
JSON declared count: 34
JSON enumerated cases: 34
all pass: true
complete stdout JSON == guard-v2-tests01.json: true
complete stdout bytes == guard-v2-tests01.json: true
stdout SHA256: 678e6bb3de8ca3fb5d762624fec629dc584624aa263a8b0f9fb039b26f3cdd99
```

Programmatic reconciliation found the old-guard rejection, two positive cases (including returned-period rounding, each also checking rerun rejection), 18 precondition faults with zero creations and 13 postcondition faults with one creation. Distinct collection handles and object IDs are used; the base-clock mock rejects generated-only property access. These are synthetic control tests, not Quartus emulation or insertion-state proof.

The retained red receipt reports the missing `apply_v2` failure on `new_positive`; the current harness orders the old rejection case before it. I inspected that historical receipt but did not replay its old state. This is not a claim of full end-to-end TDD or native proof.

## Bindings and preservation

The seven entries of `guard-authoring-manifest01.json` matched their recorded sizes and hashes. The manifest and those seven files were unchanged across the independent regression. The freeze does not cover future neighboring files, CURRENT updates or this review output.

| Binding | Verified SHA256 |
|---|---|
| `guard-authoring-manifest01.json` (919 bytes) | `39312c368f64d627490aacca35444f783dea7675b7e580ce2b3c910a13606da7` |
| `clock-repair.tcl` (13720 bytes) | `206469a5053556dd613de41af23a08ead1637d85059ce3eec30097b8d0fb3dff` |
| `test-guard-v2.py` (9741 bytes) | `58927d910e13d98b8443d60c62ed6f0a0aa4082248770ae68ae8e709651c8229` |
| Original helper prefix (4865 bytes) | `8486a48acbe4f024beecefb95d09eeab69ce0331d3f16d4a1f9c0591cdb117f2` |

I also hash-verified the supplied independent diagnostic03 review, source disposition, parent result-consumption receipt and mechanically extracted baseline inventory. `../fanout-diagnostic03/RESULT-ACCEPTANCE.md:3–5,17–20,26–30` and its parent receipt establish that the finite diagnostic result has already been accepted/consumed. No sibling wait or repeated selector diagnostic is requested.

## Native and integration limits

Saved `get_clock_info` help describes divide/multiply fields as relative to the **base clock** (`../api-help01/commands/get_clock_info.txt:10,21`). Therefore returned 2/1 for C is an explicit finite experimental rejection rule, not a documented guarantee about immediate-master encoding. The implementation rejects another representation rather than converting it. Neither this review nor the inert fixture proves that the future native tool will satisfy that rule, its timing precision, or the insertion-time association expectation.

After the narrow F1 correction and fresh component review, future integration must still select `apply_v2` at the planned normal-SDC insertion point, not the defective preserved `apply`, and arrange verification after full SDC. This review does not accept that unbuilt integration.

Only this report was authored. No helper/test/source/top-SDC changes, remote/vendor/help/native/hardware/git operations, standalone preparer/runner/gate/issuer execution, authorization, issuer approval, source promotion or task closure occurred. No native, collector, timing, fit or hardware acceptance follows. `ready_for_build=false`; old attempts remain spent and experiment03's candidate remains blocked.

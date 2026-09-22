# Guard02 independent QUALITY review01

## Verdict

**APPROVED — frozen guard component only. No critical or important quality defect found.**

The consumed SPEC PASS was verified against its exact report and parent receipt before this review. I inspected the complete successor helper and complete 36-case harness, both component specifications, exact predecessor-to-successor diffs, saved receipts and relevant saved API documentation. An independent execution of the unmodified permitted harness passed all 36 cases and reproduced the entire saved receipt byte-for-byte.

This does not accept the unfinished query, an assembled/prepared A/B package, native behavior, an issuer or any authorization. The predecessor `../guard-spec-review01.md` remains **BLOCKED F1**; this approval applies only to the manifest-bound guard02 successor.

## Quality findings

### F1 is repaired at the actual failing lookup

- `clock-repair.tcl:186` replaces the legacy `one_pin` call with `post_output_pin_v2`. The appended procedure at `:193–205` reacquires O as an actual collection and returns that same collection; it does not reconstruct a collection from a native object ID or name.
- At `:197–199`, acquisition is followed by `raw_names_v2` and only then singleton/identity rejection. The shared helper records the raw count and flushes stdout at `:81–82`, before cap, enumeration or duplicate-identity assertions. Thus a missing collection records count0 before rejection; the duplicate-ID multiple-match fixture records count2 before duplicate rejection. The diagnostic does not substitute an earlier insertion-time count or a deduplicated count.
- The postcheck retains exact node identity plus pin name, clock-pin status and output-only direction checks (`:199–201`). All new procedure-local temporaries use `ia4_` names. There is no array unset, vendor-state mutation, matcher-mode change or fallback.
- The change is narrow: one call substitution in the rejected helper plus the appended procedure. Both stored unified diffs exactly match diffs recomputed from actual predecessor/successor bytes. The original 4865-byte helper prefix is unchanged and byte-equal to the retained experiment03 baseline and diagnostic03 helper copies. The old procedures remain provenance, not approved future entry points.

### Preserved guard paths remain coherent and fail closed

- `apply_v2` validates the exact I/O collections, divider identity/type, M identity, physical PLL fanin and incoming M association before the sole creation call (`:118–150`). Definition targets are inventoried separately from driving associations: C must be absent, no explicit definition may target O/K, O must be driven by exactly M and M must explicitly target the expected PLL output (`:137–149`). This avoids the old association-versus-definition contradiction without broadening the accepted branch.
- Creation uses exactly `-name $C -source $ia4_input -master_clock $M -divide_by 2 $ia4_output`, with actual validated collections. There is no `-add`, invented base clock, nominal period, phase/offset/inversion override or recovery branch. `created` is set before the immediate snapshot/postchecks (`:150–152`) and is not reset after failure. Re-entry rejects at `:117`.
- The bounded snapshot uses raw clock cap256 and per-definition target cap4096, checks enumeration/uniqueness and branches generated-only queries by clock type (`:80–105`). The C-only addition checks require every prior name and captured definition to remain equal, not merely equal counts (`:107–114`). They execute immediately after creation and again through `verify_created_v2`; actual post-full-SDC placement is still an integration obligation.
- Verification requires generated C, sole target O, exact source I and immediate master M, integer divide2/multiply1, no inversion and output association exactly C (`:162–187`). Unsupported property values or API errors are not converted into success. The timing checks use returned M/C precision and the unshifted divide2 relation, not a nominal frequency (`:155–157,177–184`). The source rising edge and next source rising edge determine this even-divider waveform; M's falling edge is not needed for that relation. Native edge/shift metadata is logged for later interpretation, not treated as already proven vendor behavior.
- Tcl errors are not caught and suppressed inside the new paths. This is component-level rejection behavior, not proof that a future Quartus loader/outer runner will propagate it correctly. That integration and its positive completion requirements remain outside this approval.

### Harness quality and regression relevance

`test-guard-v2.py` was read in full before execution. It loads the local Tcl library, evaluates synthetic mocks and the actual helper, explicitly checks return codes/rejection markers and creation counts, and deletes each fresh interpreter in `finally` (`:172–207`). Its acceptance logic uses explicit conditions/raises rather than Python `assert`. It reads inputs and emits JSON; it does not write the saved receipt or invoke Quartus.

The mocks distinguish `COLn` collection handles from pin/cell/clock IDs; the creation mock checks the exact command grammar and dereferences the actual I/O collections (`:149–152`). Base-clock generated-only property requests fail (`:116`). These properties catch relevant handle/branch errors without claiming to emulate vendor matching or propagation.

For the new regressions, `get_pins` changes O to zero/multiple only when a creation has already occurred (`:50–51`). Separate `puts` and `flush` events are recorded (`:23–24`). The checks at `:192–202` require, after rejection:

1. The final two events are the exact `CLOCK_REPAIR_COUNT_V2 post-output-pin 0/2 cap 32` record and then `flush stdout`.
2. `created == 1` and the total creation count is one.
3. A second `apply_v2` rejects as a second invocation without another creation.

Both cases passed. The multiple-match case intentionally uses duplicate `PIN_O` IDs; its count2 must be preserved before uniqueness rejection. The receipt's `post_pin_count_flush_order: false` on other cases means that particular assertion was not performed there, not a failed check.

The suite is finite control-flow evidence, not exhaustive fault coverage or Quartus emulation. This review does not infer native insertion state, ratio encoding, natural-bus matching or real channel durability from mocks. The existing 34 outcome records are identical after excluding the new per-case ordering field; no old expected outcome was weakened to accommodate F1.

## Independent permitted execution

Only this behavioral entry was executed, once, after full source inspection:

```text
cwd: /home/joe/Projects/Thesis/AHLS/new_bsp/new/qualification/pcie-clock-repair-01/experiment04/guard02
argv: python3 -B /home/joe/Projects/Thesis/AHLS/new_bsp/new/qualification/pcie-clock-repair-01/experiment04/guard02/test-guard-v2.py
return code: 0
stderr bytes: 0
stdout bytes: 6292
declared / enumerated / unique cases: 36 / 36 / 36
all cases pass: true
entire stdout bytes == guard-tests01.json: true
entire parsed stdout JSON == guard-tests01.json: true
stdout SHA256: 7a76cf5a282720f787fe20ff534b3acfa1a80663dc4263fa6384f1fa73a0d855
```

Programmatic outcome reconciliation:

| Group | Cases | Creation count per case |
|---|---:|---:|
| Old guard rejects measured upstream-M association | 1 | 0 |
| New positive and rounded-period positive | 2 | 1, with denied rerun |
| Precondition rejection cases | 18 | 0 |
| Original postcondition rejection cases | 13 | 1 |
| New post-only missing/multiple O cases | 2 | 1, with count/flush order and denied rerun |

Stdout/stderr were captured and compared entirely in memory. No fixture or receipt was rewritten. `guard-f1-red01.json` was read and hash-verified as historical evidence: it records the first `post_output_missing` count/flush failure against the rejected helper. I did not replay rejected helper bytes and do not claim the second red case executed before that harness stopped.

## Frozen bindings and preservation

All seven successor manifest entries and all seven predecessor manifest entries matched their recorded sizes/SHA256 values before execution and remained byte-identical afterward. The freeze comparison covered 25 files, including both manifests, both guard02 prerequisite records, both specifications, the predecessor review, retained original helper copies, the source disposition and the three saved API files. The guard02 directory gained no file during the harness execution. Only this review report is authored by this task; independent neighboring parent work outside guard02 is not part of the directory freeze.

| Binding | Bytes | SHA256 |
|---|---:|---|
| `manifest01.json` | 913 | `35417e3c6c7e46c87d2dca78cf09602c5d9646c2f0bc3a816af5ce4d76f273df` |
| `clock-repair.tcl` | 14451 | `4967de098cd857a936ccaeb16b22092259872292488ca44d5bce46b594af8bdc` |
| `test-guard-v2.py` | 11117 | `846168e982969eee1f7748d8f65b7f42e9e103bdef861da717763d32e4cd5e5a` |
| `clock-repair.tcl.diff` | 1532 | `700d16cd284f2915d54e2c7f4f081a3cd8e60415f9fe3893ec1e39350c9d1d33` |
| `test-guard-v2.py.diff` | 3508 | `d8b67b508d6968c2e89789c95703f5f02c938d6da7527c5635465c133a1dbf2f` |
| `guard-f1-red01.json` | 877 | `c30ae42bbf8120305bc4b20085033027ac1374f8f7fdf05f1329c08d19c6ae35` |
| `guard-tests01.json` | 6292 | `7a76cf5a282720f787fe20ff534b3acfa1a80663dc4263fa6384f1fa73a0d855` |
| `SPEC.md` | 1543 | `716741c56761d3b71c202a66d8e0995b4fcc53218f0b38c35317a92bdcb93a4d` |
| `spec-review01.md` | 10227 | `d51a86383b068360352a843cf51700ef52e8e2d5311e8b1634c7f19f0f14ea5b` |
| `parent-spec-consumption01.json` | 1658 | `5fdef882cac6e0ff67c65f6c65690d6ee14da9a1b747226a162e0f198b436d45` |
| Original helper prefix | 4865 | `8486a48acbe4f024beecefb95d09eeab69ce0331d3f16d4a1f9c0591cdb117f2` |
| `../guard-authoring-manifest01.json` | 919 | `39312c368f64d627490aacca35444f783dea7675b7e580ce2b3c910a13606da7` |

## Remaining boundaries

Saved `../../api-help01/commands/get_clocks.txt:12,38–42` supports separating driving association from definition target. Saved `get_clock_info.txt:10,21` describes divide/multiply values relative to the **base clock**, and `create_generated_clock.txt:62–89` describes the divide2 / `{1 3 5}` waveform relation. Consequently C=2/1 and the required returned precision remain explicit finite experimental acceptance criteria, not guarantees about what Quartus will return. Unexpected encoding/state must fail closed. No new help or native diagnostic is requested by this review.

Future preparation must copy **this guard02 helper**, not the rejected root helper, select `apply_v2` at the intended normal-SDC insertion point and call `verify_created_v2` after full SDC. Actual prepared bytes still require independent full-package SPEC→QUALITY→parent consumption and a separately inspected one-use issuer. This component approval cannot be transferred to changed or unreviewed integration bytes.

No helper/test/top-SDC edits, git, remote/vendor/help/native/hardware operations, standalone preparer/runner/gate/issuer execution, authorization or source promotion occurred. No execution blocker was encountered. `ready_for_build=false`; prior attempts remain spent and experiment03's candidate remains blocked. No collector, numerical timing, fit, hardware or whole-goal acceptance follows.

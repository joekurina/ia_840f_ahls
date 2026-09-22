# Guard02 independent SPEC re-review01

## Verdict

**PASS — F1 is corrected in this frozen successor guard component; no remaining blocking component SPEC gap found.** The complete `../GUARD-SPEC.md` contract and this directory's `SPEC.md` were reviewed against the actual helper, complete harness and an independent 36-case inert replay. This is SPEC acceptance of the guard component only, not QUALITY acceptance, acceptance of an unbuilt A/B package, native authorization or task closure.

The predecessor `../guard-spec-review01.md` remains BLOCKED F1 and its parent consumption remains unchanged. This report does not relabel that rejected helper or transfer acceptance to future prepared bytes.

## F1 correction and narrow delta

- `clock-repair.tcl:186` now calls additive `post_output_pin_v2`, not legacy `one_pin`. The only change within the predecessor helper is that one lookup substitution; the new procedure is appended at `:193–205`. Both stored unified diffs exactly match diffs recomputed from the actual predecessor and successor files.
- The new procedure obtains the actual O collection at `:197`, then invokes `raw_names_v2` with label `post-output-pin` and cap32 at `:198`. That support procedure records the raw count and immediately flushes stdout at `:81–82`, before its cap/uniqueness assertions or the new procedure's singleton/name/direction/clock-pin checks. It returns the actual collection at `:203`, not a pin ID or reconstructed name list.
- A zero collection is recorded/flushed before singleton rejection. The multiple-match fixture contains duplicate `PIN_O` IDs: its raw count2 is recorded/flushed before the duplicate-identity rejection. Thus neither path hides its raw observation through deduplication or the old `one_pin` assertion.
- New procedure-local temporaries are `ia4_`-prefixed. Original namespace identities and original functions remain unchanged in the 4865-byte prefix, also byte-equal to both retained original helper copies checked from experiment03 baseline and diagnostic03 preparation. No original/vendor array mutation or matcher-mode change was added.

## Preserved component contract

| Contract | Source inspection and inert evidence |
|---|---|
| Exact D/I/O/M/C identity, singleton cardinality, direction/type and physical source | `clock-repair.tcl:118–136` retains exact divider/name/type, input/output clock-pin directions, master identity, physical fanin `sys_pll\|iopll_0\|tennm_pll\|outclk[2]` and incoming M. New collection paths record/flush counts before assertions. |
| Association is not a definition | `:137–149` separately requires absent C name, no explicit clock target at O or K, exactly upstream M driving O, and M explicitly targeting the expected PLL output. Empty/extra associations fail before creation. This agrees with saved `get_clocks.txt:12,38–42`; post-full-SDC observations are not represented as insertion-time proof. |
| Exact creation, single use, retained created flag | `:150` creates exactly C using actual input/output collections, master M and divide2; no `-add`, phase, offset, inversion, base-clock creation, nominal period or fallback. `:151` sets `created` before any subsequent postcheck; `:117` rejects a repeat. The original `apply` is preserved as provenance, not approved as the future entry. |
| Bounded definitions and C-only addition | `:80–114,139,152,162` retain clock cap256, target cap4096, raw-count/duplicate checks, and generated-only property branching. Snapshots compare name/type/period/waveform/targets and applicable master/source/divide/multiply fields, requiring exactly C added and every other captured definition unchanged. The immediate check and reusable verification-time check remain present. Actual placement after full SDC is a future integration requirement, not exercised by this fixture. |
| Exact generated-C postconditions | `:163–187` requires generated C, sole explicit target O, source I, immediate master M, returned integer divide2/multiply1, no inversion, and exact output C association. Edges and shifts are recorded/flushed. Unexpected ratio representation is rejected, not converted. |
| Returned-precision timing relationship | `:155–157,177–184` uses actual M/C period and relevant waveform values, at least three fractional decimal digits and half-quantum bounds from returned precision. The divide2 rise/fall relation remains unshifted and no nominal period is introduced. Saved creation help `create_generated_clock.txt:62–89` documents the divide2 / `{1 3 5}` edge relationship. |
| Inert collection discipline and regression preservation | Harness collections use distinct `COLn` handles separate from node/clock IDs; invalid collection/ID use fails in the relevant mocks. Base-clock generated-only property requests reject. All prior34 case outcome fields are identical to the preserved prior receipt; the two new post-only cases additionally check count/flush order and denied rerun. These are synthetic control checks, not vendor semantics. |

## Independent permitted replay

After reading the complete helper and harness, the only behavioral entry executed was:

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

Complete stdout/stderr were captured and compared in memory; the saved receipt was not overwritten. Programmatic reconciliation established:

- Old guard: measured upstream-M association with no explicit output definition rejects, zero creations.
- Two positive cases: normal and rounded period; each creates once and denies a second invocation.
- Eighteen precondition faults: reject with zero creations.
- Thirteen prior postcondition faults: reject after one creation.
- Two new post-only pin faults: `post_output_missing` and `post_output_multiple`, each rejecting after one creation. The `get_pins` faults activate only after `::calls` is nonzero (`test-guard-v2.py:50–51`). Checks at `:192–202` require the final two recorded events to be the exact `puts` count0/count2 record and then `flush stdout`, require `created == 1`, and require rerun rejection with the creation count still one. Both returned `post_pin_count_flush_order: true`.

The historical `guard-f1-red01.json` is bound to the unchanged rejected helper and the current harness. It records rc1, empty stdout and the first `post_output_missing` count/flush assertion failure. I inspected, hash-verified and retained it; I did not replay rejected bytes. The harness stopped there, so this report does **not** claim the second red fault executed.

## Byte bindings and preservation

Before and after the independent replay, both seven-entry manifests matched every recorded size/hash, both manifest bytes were unchanged, and all protected predecessor/source/API files were unchanged. The guard02 directory gained no file during execution. The predecessor review hash also matches its parent consumption receipt.

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
| Original helper prefix | 4865 | `8486a48acbe4f024beecefb95d09eeab69ce0331d3f16d4a1f9c0591cdb117f2` |
| `../guard-authoring-manifest01.json` | 919 | `39312c368f64d627490aacca35444f783dea7675b7e580ce2b3c910a13606da7` |
| Rejected `../clock-repair.tcl` | 13720 | `206469a5053556dd613de41af23a08ead1637d85059ce3eec30097b8d0fb3dff` |

The source disposition `../../native-mapping-disposition03.md` was verified at SHA256 `dd00b40ba78960c51d0ac875ad8619f75af3a65d980cf7bac7d34283be6181b7`. The already-consumed diagnostic03 acceptance supports preparing the future experiment without another standalone selector/native precondition diagnostic; this review neither reopens nor expands that finite mapping acceptance.

## Native and integration limits

Saved `get_clock_info.txt:10,21` describes divide/multiply properties relative to the **base clock**. Returned C=2/1 is therefore a prospective fail-closed acceptance criterion, not established immediate-master encoding. Native API behavior, timing precision and insertion-time state remain unproven. The fixture neither emulates Quartus nor measures those properties.

Future preparation must select **this guard02 helper**, not the still-rejected 13720-byte parent helper, and wire `apply_v2` at the intended normal-SDC insertion point plus `verify_created_v2` after full SDC. No approval is given to unbuilt query/report coverage, future integration or a complete A/B package. Actual prepared bytes still require independent SPEC→QUALITY→parent consumption and a separately inspected one-use issuer.

Only `guard02/spec-review01.md` was authored. No helper/test/source/top-SDC edit, git/remote/vendor/help/native/hardware operation, standalone preparer/runner/gate/issuer execution, authorization, source promotion or task closure occurred. No execution blocker was encountered. `ready_for_build=false`; previous native attempts remain spent and experiment03's candidate remains blocked. No collector, timing, fit or hardware acceptance follows.

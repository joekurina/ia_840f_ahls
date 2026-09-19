# IA840F bank-spreading saved-intent candidate

## Result

**Implemented and locally verified; ready for independent implementation review, not generation or build.** No maintained SOURCE, old vendor tree, completed WORK, gate, authorization, generated HDL, clock, calibration wiring, pin, SDC or QSF was edited. No vendor invocation, Query04 retry, DDR simulation, hardware action, install, permission change or commit occurred. `execution_ready` remains false.

The isolated deliverable is `candidate/source/ipss/ia840f/`, plus `candidate.patch`. The patch changes exactly:

- `ipss/ia840f/derive_presets.py`
- `ipss/ia840f/preset_derivation.json`
- `ipss/ia840f/presets/ia840f_mem.qprs`

Original functions remain; a pure helper was added alongside them. The script still derives all four outputs in memory before its existing write loop. Duplicate module and preset parameters are explicitly rejected. No global vendor defaults changed.

## Authoritative baseline and inputs

The complete reviewed specification was read and hash-verified as `666656350e7630c1d1e5764b4d7bb8961ee0578bb6d78503c56e4c82d5affbbe`. All 20 earlier capture entries passed size/SHA256 verification. The source manifest and reviewed specification/report are copied under `review-contract/` for handoff.

Fresh remote capture and final readback asserted `Agilex7Workstation`, UID1000. All operational remote code ran in owned `msa-fix01-*` windows within `ia840f_mailbox_monitored_01`; SSH only interacted with tmux. Successful before capture used pane `%414`, after readback `%415`. `remote-before.json` and `remote-after.json` cover 32 capture labels / 29 distinct remote paths, including required derivation inputs, all earlier evidence, SOURCE artifacts/QSF and selected completed Work11 files. Every listed byte size/hash matched before and after.

The live SOURCE QSF remains `ad68b5bf4666731449b2ae326a0f307065d112fb6bb0a9a0a072a0cd6cb1516c`. No local stale QSF was used or copied into the candidate. Hold ON remains the baseline; Work11 native exit0 with failed timing and unchanged Work10 summary results is not reverted or reinterpreted here.

A bounded dependency-location issue was encountered: the five PCIe evidence inputs do not exist at remote `SOURCE.parent/reference/quartus-26.1.1-pcie`. Initial read-only captures in panes `%412` and `%413` failed before producing an accepted payload. The visible error was `FileNotFoundError` for `hwtcl/pcie_ss_fileset.tcl`. No schema contradiction occurred. These five files were reused from the proven local `new/reference` fixture only after matching every SHA256 in authoritative `preset_derivation.json`. Modern schemas and donor inputs were freshly captured remotely. No dependency installation or large source-tree copy was needed.

Successful compressed transfer buffer `msa-fix01-baseline-20260919-c` had SHA256 `d97dfebb4663b1f95c3acbbda37004ed52aa4c75eb6aac08d56d7f304796c223`; every exported file was individually verified. Failed initial transport used buffer name `...-a` twice but neither attempt produced an accepted payload; the successful capture used a fresh name. After readback used separate `msa-fix01-after-20260919-d`. Exact successful SSH/tmux argv and remote Python readers are retained. These are scoped inventories, not a new complete whole-SOURCE/WORK qualification.

## Semantics and provenance

The helper accepts only literal strings `false`/`true`, counts `0/2/4/8`, and copies `1/2/4/8`. Explicit false validates the count first, then emits zero. True preserves a positive legal count and rejects zero. Missing enable preserves the explicit legal count, records absence and unresolved semantics, and never infers false. Missing/invalid counts, malformed flags, missing target/copy schema, duplicate XML keys and positive effective counts with copies>1 reject before output publication.

Generic zero/copies>1 remains vendor-schema-legal; the separate actual-fixture guard rejects any departure from false/8/copies1 independently for each channel. No write-copy or calibration adjustment is made to accommodate a request.

Each semantic record includes raw enable/count/copies, donor input path/hash, output scope/value, rule, explicit qualification limits and four supporting installed-source locations/hashes/line traces. Captured supporting-source hashes identify reviewed evidence, not a live installation acceptance check. Overridden counts are removed from direct-copy provenance, and resolved false flags are removed from unresolved entries while retained in the semantic record. All unrelated unresolved fields and defaults remain byte-value equivalent, including policy, auto-precharge and synchrony semantics. No integer-policy/string equivalence is asserted.

## Verified preservation

- Full memory map: **2930 unique parameters**, identical keys, no additions/removals/duplicates.
- Exactly two value changes: `mem_ss|msa_0|NUM_BANK_FIFOS` and `mem_ss|msa_1|NUM_BANK_FIFOS`, both **8 -> 0**.
- All other memory values identical, including copy counts1, geometry, quotas, latency-related/default fields, topology and calibration parameters.
- Simulation and PCIe presets byte-identical to remote baseline.
- All four original artifacts reproduced byte-for-byte by the original derivation using the bounded fixture, before checking the candidate.
- Repeated candidate derivation and compare-only invocations succeeded; tests did not change any baseline/candidate file.
- `candidate.patch` passed `git apply --check`, was applied only to a temporary three-file baseline, and produced exact candidate bytes.

Pins, core470/seven-output PLL, memory clocks, PF/BAR settings outside these outputs, constraints and calibration wiring are not edited by this three-file patch. This is not a fresh certification of those broader contracts. The separate calibration-association acceptance issue remains open; nothing was swapped.

## Tests and reproduction

From this package directory:

```sh
python3 -B -m unittest -v test_bank_spreading
python3 -B stage_candidate.py
python3 -B verify_package.py
```

Latest result: **16 unittest methods PASS**, including strict lexical subcases, independent mixed channels, complete map/provenance assertions, absent enable, copies conflicts, duplicate input/schema keys, missing schema, pinned input tampering, actual copy invariant, stale preset/provenance detection, deterministic repeats and no-publication rejection cases. The production derivation is exercised with subprocess creation forbidden in direct tests; subprocess tests invoke only Python itself. The initial RED run failed because the helper was absent; retained `red.log` documents that expected failure. Earlier `green.log` contains the initial 13-test pass; authoritative final logs are `verification/01.log` through `04.log`.

`stage_candidate.py --publish` was run once to publish only the two derived candidate artifacts **after** all four in-memory outputs passed full-map, fixture, collateral-byte, provenance and hash checks. This is not the broad derivation `--write` against authoritative files. Negative `--write` tests run only in temporary copied fixtures. `stage_candidate.py` defaults to compare-only. `verify_package.py` records actual argv/exit codes/logs, recreates the standalone patch, and checks before/after local inventories. Remote capture scripts are evidence of the completed bounded read; do not rerun them as part of normal local review.

## Candidate hashes (SHA256)

| Artifact | Candidate SHA256 |
|---|---|
| derive_presets.py | `bb07cdfc817e50517e3277cb6cb4daca2f80c4da37a6e158ceed36403cbe46c4` |
| preset_derivation.json | `31218876eab8d532bbebe2f7e486a02f602dff20acb931bf9cb8a997f7913069` |
| presets/ia840f_mem.qprs | `59d7f4dcd38386e6a3e54d86a22e3945c116f5951353c49dbf032e20a0b4bdbd` |
| presets/ia840f_sim.qprs (unchanged) | `8af9954c412405597fd073d1b2507dfac2e3475ef21871e1973f4ddbd666465e` |
| presets/ia840f_pcie_known_schema.qprs (unchanged) | `420f73c5c4bf1432ce39508f068bc381f4e4f2117a87a96940ca8500a93c876e` |
| candidate.patch | `bf4f4b8f6198fb3e0b9c0d3e186376b317460fcf3c01535c32e11f2969f8fcb2` |

Full package inventory is `artifact-manifest.json`; before/after artifact hashes are in `verification/results.json` and inventory files.

## Limits / review handoff

Independent implementation review is still required; this is implementer verification, not self-issued approval. No source deployment/rebinding or execution authorization was issued. Pure-Python acceptance does not validate native save/reload, generated nested parameters, interfaces, timing, functional behavior, or hardware. Future approved work must retain the specification's generated readback and whole-tree preservation checks. Query04 remains specifically prohibited; this task's no-vendor-call boundary is not a blanket new prohibition on other future reviewed vendor work.

Disabling bank spreading can change bandwidth, ordering and load-dependent latency. No guaranteed cone removal, slack gain, no-reordering guarantee or original generated-behavior equivalence is claimed. DDR1 PHY hold, unconstrained paths and S1/TRS applicability remain unresolved. DDR simulation remains skipped by user.

A reusable lexical/provenance/publication lesson was added to the existing `source-bound-vendor-tool-gates` skill outside the project; no other profile was touched.

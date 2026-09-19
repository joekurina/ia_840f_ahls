# Independent implementation specification review

## Verdict: PASS — isolated structural candidate only

The implementation satisfies the mandatory local translation, provenance, preservation and regression contract in `../msa-next-supported-step-02/spec-review.md` (SHA256 `666656350e7630c1d1e5764b4d7bb8961ee0578bb6d78503c56e4c82d5affbbe`). No must-fix implementation-specification defect was found. **Next step is independent code-quality review, not deployment or vendor execution.** Quality approval has not been performed or implied.

This is saved-intent translation acceptance only. It is not original donor generated-behavior equivalence, functional acceptance, timing qualification, live installed-tool acceptance, source deployment/rebinding approval or an execution authorization. `execution_ready` remains false.

## Evidence identity and exact change scope

I read the complete authoritative specification, implementation report, patch, tests, staging/verifier scripts and candidate derivation; parsed the complete candidate and baseline provenance JSON and parameter XML; and independently recomputed package identities.

- `artifact-manifest.json`: **79 entries, 79 unique paths, all sizes and SHA256 values pass**. Before this review's report, the package contained 80 files; only the manifest itself was unlisted. Manifest SHA256: `2f21d07debb62e0068aef60497efb98b8bec408a0f6c72205c7a80a14812d526`.
- Reviewed source manifest: **20 entries, 20 unique capture paths, all sizes/hashes pass**. The copied specification is byte-identical to the authoritative specification.
- Candidate source changes are exactly the three required files below. The regenerated patch is byte-identical to the supplied patch. Independently applying every unified-diff hunk in Python, checking original context and hunk lengths, reconstructs all three exact candidate files. No git or vendor subprocess was needed.

| Candidate artifact | SHA256 |
|---|---|
| `ipss/ia840f/derive_presets.py` | `bb07cdfc817e50517e3277cb6cb4daca2f80c4da37a6e158ceed36403cbe46c4` |
| `ipss/ia840f/preset_derivation.json` | `31218876eab8d532bbebe2f7e486a02f602dff20acb931bf9cb8a997f7913069` |
| `ipss/ia840f/presets/ia840f_mem.qprs` | `59d7f4dcd38386e6a3e54d86a22e3945c116f5951353c49dbf032e20a0b4bdbd` |
| `candidate.patch` | `bf4f4b8f6198fb3e0b9c0d3e186376b317460fcf3c01535c32e11f2969f8fcb2` |

All original functions remain: `derive`, `main`, and nested `read`, `ip`, `preset`, `xml`, `automatic`. The board-local pure translation helper is added without a global vendor default change. The original derivation, executed against the isolated bounded fixture, reproduced all four original outputs byte-for-byte, including original provenance; this is reproduced evidence, not merely the implementer's stored claim.

## Mandatory contract checks

1. **Complete output preservation:** Both memory maps have 2930 unique parameters with exactly equal keys. The only value changes are `mem_ss|msa_0|NUM_BANK_FIFOS` and `mem_ss|msa_1|NUM_BANK_FIFOS`, each `8 -> 0`. Copies remain `1` independently. No additions, removals, duplicates or other memory-value changes occur. Simulation and PCIe presets remain byte-identical with hashes `8af9954c412405597fd073d1b2507dfac2e3475ef21871e1973f4ddbd666465e` and `420f73c5c4bf1432ce39508f068bc381f4e4f2117a87a96940ca8500a93c876e`. Metadata counts are memory2930, simulation1519/1519 and PCIe104.
2. **Strict semantics:** Exact `false` validates legal count0/2/4/8 before emitting zero; exact `true` preserves 2/4/8 and rejects zero. Missing enable preserves each explicit legal count, with `enable_present=false`, raw enable null, unresolved semantics and direct-count provenance. Missing counts under all three flag states reject. Empty, unknown, mixed-case, whitespace and noncanonical enable/count strings reject, including invalid counts under false. Positive effective counts conflict with copies2/4/8; copies are never silently changed.
3. **Generic versus actual fixture:** Generic legality is not incorrectly restricted to copies1: full derivation with false and copies2/4/8 succeeds with zero and the unchanged copy count. Actual publication is separately constrained to each donor's explicit false/8/copies1, pinned inputs and the exact two-value delta. Both channels' raw fixture records independently reject flag, count or copies departures. The fixture guard does not rewrite output or substitute for the generic translation. Generic mixed false/true and differently enabled counts are exercised through full derivation, outside the fixture guard.
4. **Schema, duplicate and failure handling:** Duplicate donor keys and preset parameters reject. Missing bank-count or copies target in either applicable reference scope rejects. The schema's second source scope is msa_2, mapped to output msa_1; this was tested explicitly. The production derive/main path obtains all four outputs before its first write. Malformed-input, conflict and duplicate rejection tests leave output inventories unchanged. Supplemental tests also verify both-scope schema absence prevents `--write`, and mutation of every one of the 17 pinned input files prevents staging `--publish` with unchanged candidate outputs.
5. **Provenance:** Both semantic records contain exact raw enable/count/copies, source path and actual donor hash, scoped zero output, decisive-false rule, inactive-count status, supporting installed-source locations/hashes and saved-intent-only qualification. Overridden counts are neither direct-copy mappings nor modern defaults; resolved false enables leave the unresolved dictionary but remain in semantic evidence. I normalized only these explicit additions/removals and the memory output hash, then compared the entire provenance object to baseline: exact equality. Thus unrelated unresolved fields, policy/auto-precharge/synchrony semantics, topology mappings, PCIe evidence, counts and readiness/status are preserved, not merely selected spot checks.
6. **Supporting evidence:** Rehashed all four supporting captures and read the cited schema, conflict, zero-description and regular-DDR4 versus associated-storage source excerpts. These establish static reviewed semantics; the recorded hashes are not live-installed-state checks and do not establish native parameter acceptance. Derivation's PCIe evidence checks and staging's broader pinned-input checks are distinct; generic donor mutations are intentionally permitted by `derive`, while actual-fixture staging enforces the captured donor identity.
7. **Determinism and comparison:** Repeated candidate derivation is byte-identical and retains both zeros. Both stage compare-only runs and the derivation CLI compare-only run pass. Stale memory-preset and provenance mutations are detected without modifying them. The baseline/candidate inventories remain unchanged after the reproduced verifier.

## Reproduction and precise coverage assessment

All executed package code was first inspected. I copied the package to fresh `/tmp/ia840f-independent-spec-oktl1gbx/package` and invoked `verify_package.py` there using `/home/joe/.hermes/hermes-agent/venv/bin/python -B`. Its four local-Python commands returned zero: unittest, stage comparison, derivation comparison, repeated stage comparison. **All 16 supplied unittest methods pass** (46.588 seconds in this reproduction). The verifier's patch/log/result rewrites occurred only in that temporary copy. No remote capture/transport script was executed.

The supplied suite's method count alone is not sufficient coverage evidence. Specific limitations and independent supplemental checks were:

- Legal false/true/absent matrices are primarily helper tests; missing-enable integration covers only count8. I executed **22 full-derivation cases**, all required legal flag/count combinations on each channel, checking emitted value, raw/presence/resolution evidence and direct-count classification.
- Conflict tests use count8 as the representative. I executed the complete **18-case** true/absent × positive-count2/4/8 × copies2/4/8 helper matrix; all reject.
- Generic zero with multiple copies is represented by a copies2 helper assertion. I executed full derivation with copies2/4/8 and confirmed all remain legal and unchanged.
- The supplied actual-copy guard test modifies output msa_0 and can fail at the earlier full-map gate, so it does not itself prove the raw fixture guard. I independently exercised **12 raw-record mutations across both channels**, preserving the output map, and observed the specific `actual donor intent drift` rejection.
- Supplied pin tests cover representative files and mostly assert an exception rather than publication preservation. I mutated **all 17 pinned inputs**, independently checked rejection, then exercised staging `--publish` for every mutation and verified unchanged output inventories.
- Supplied missing-schema integration covers only bank count in the first reference scope. I tested bank-count and copies absence in each of the two reference scopes through production `main --write`: **four rejection/no-publication cases**.

These supplemental checks close the relevant review-evidence gaps; incorporating them into the maintained regression suite is a useful quality-review follow-up, not an observed specification failure. There was one reviewer-only introspection error (treating the source manifest list as a dictionary), corrected before verification; no candidate failure or remaining access blocker resulted.

## Preserved boundaries and remaining acceptance

The exact preset delta preserves all existing physical geometry, memory clocks, topology/application mapping and calibration parameters. The patch does not modify pins, SDC, QSF, PCIe collateral, core470/seven-output PLL or generated RTL. This is not a fresh whole-tree physical-contract certification. Calibration-conduit association remains a separate acceptance issue; no swaps or repairs were attempted.

Work11 remains the completed failed-timing baseline; hold ON, seed2 and maximum-placement settings remain unchanged. No new setup/hold outcome is claimed. Query04 remains prohibited. DDR simulation remains skipped. Later saved/nested/generated readback, external/locked interfaces, clock/reset associations, full parameter preservation, constraints and all-corner timing/resource acceptance remain required under their appropriate review gates.

Only this fresh report was added to the original package, outside its existing manifest. All 80 pre-existing package files, including report, patch, manifests and verification results, were byte-identical immediately before report publication. Temporary-copy tests made no maintained SOURCE/WORK edits. No remote calls, vendor generation/compilation, DDR simulation, hardware action, installation, permission change, authorization issuance or commit occurred.

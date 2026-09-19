# Independent code-quality review — IA840F bank spreading

## Verdict: REQUEST_CHANGES — one bounded publication defect

The three-file translation candidate is structurally correct, and the normal local reproduction passes. **Do not advance the package to deployment/generation preparation until Q1 below is corrected and independently rechecked.** The defect is in the package publisher, not in the false/8-to-zero translation. No vendor execution or readiness approval is granted. `execution_ready` remains false.

The accepted implementation-spec review was read in full and independently hashed to `4c54b3938a390521ff910f53b005628c68a686c437333d3d440cf60e456a5a23`. The authoritative original specification and implementation report were also read in full. The prior review's supplementary coverage is useful evidence; its recommendations are not automatically must-fix findings. Q1 is a separately reproduced behavior not covered by those checks.

## Q1 — Important / must fix: collateral rejection occurs after publication

**Location:** `stage_candidate.py:108–114` (related validation at `90–94`).

`validate_outputs()` checks freshly derived simulation/PCIe bytes against the captured baseline. It does not compare the existing candidate simulation/PCIe files, which `--publish` deliberately does not replace. `main()` then writes the memory preset and provenance at lines111–112, before line114 compares all existing candidate files. Consequently stale or missing collateral causes a validation failure only after the selected output pair has already been published.

This violates the intended no-output-publication-on-validation-failure boundary. It is not a hypothetical interrupted write, filesystem race, optimized-Python invocation, or vendor failure: both reproductions used the ordinary documented Python invocation and only local copies.

### Reproduction, actual results

Two independent fresh package copies under `/tmp/ia840f-quality-iuaxj6zb/`:

1. Restore candidate memory preset and provenance to their captured pre-publication baseline bytes.
2. Append one newline to either candidate `presets/ia840f_sim.qprs` or `presets/ia840f_pcie_known_schema.qprs`, separately.
3. Run `/home/joe/.hermes/hermes-agent/venv/bin/python -B stage_candidate.py --publish` in that copy.
4. Compare the entire candidate board-directory file inventory before and after.

Both commands returned **1**, with respectively:

- `ValueError: stale candidate: presets/ia840f_sim.qprs`
- `ValueError: stale candidate: presets/ia840f_pcie_known_schema.qprs`

Both nevertheless changed **exactly** `presets/ia840f_mem.qprs` and `preset_derivation.json`:

| File | Before SHA256 | After SHA256 |
|---|---|---|
| Memory preset | `26cf53d439221fc7a9cd6ecaef55c232945df9ab38883499dfb63d1d78841c1e` | `59d7f4dcd38386e6a3e54d86a22e3945c116f5951353c49dbf032e20a0b4bdbd` |
| Provenance | `e58e146ea0ec90e1a2528ddffdba2553339f4168dadda0b109574844c41d2d06` | `31218876eab8d532bbebe2f7e486a02f602dff20acb931bf9cb8a997f7913069` |

Detailed local reproduction results, including tracebacks and hashes: `/tmp/ia840f-quality-iuaxj6zb/publication-rejection-results.json`.

**Minimum correction:** before the first write, compare every non-published on-disk output with its validated derived bytes and reject absent/stale collateral. Do not require the two intended publication targets already to equal the regenerated outputs, since updating those is the purpose of publication. Retain the final readback. Add negative tests for stale and missing simulation/PCIe collateral starting with non-current publication targets, asserting the whole output inventory is unchanged; also retain a successful publication test. No broad transaction framework or vendor/source changes are needed for this fix.

## Other findings and production integration

- **No additional must-fix translation defect found.** The pure helper validates exact lexical enable/count/copies values, validates counts even when false, distinguishes missing enable from false, and independently maps each channel. Effective positive counts with multiple copies reject; generic zero/multiple-copy legality is distinct from the actual-fixture copies1 guard. Explicit exceptions implement the new semantic/schema and duplicate checks.
- **Low-priority regression maintenance:** promote the accepted spec review's additional full-derivation matrices, both reference scopes, raw-fixture guards and all-pinned-input publication checks into the maintained suite. These are durability improvements, not failures inferred from a test-method count.
- **Low-priority inherited hardening:** `derive_presets.py:270–277,320` still uses `assert` for older PCIe evidence/value and compare-only checks; optimized Python removes assertions. This is inherited rather than introduced by the bank-spreading patch. Keep the actual next-stage Python invocation unoptimized, including its environment; future cleanup should use explicit validation exceptions. No optimized invocation is claimed tested here.
- **Deployment prerequisite, not a new translation defect:** production derivation requires the donor tree, modern preset/Python schemas and `SOURCE.parent/reference/quartus-26.1.1-pcie` evidence tree. The implementation report explicitly says that evidence directory was absent at the captured remote location. Copying only the three changed source files therefore does not establish that derivation can run there. Prepare/hash-verify the exact existing dependencies and compare-only invocation before integration acceptance, without fetching/installing or silently changing pins. The helper's four supporting-source hashes are historical evidence identifiers, not runtime installed-source validation; source-bound generation must validate the actual installation independently.
- The publisher is package-specific and must not be repurposed as an authoritative SOURCE deployer. Production `derive/main` computes all four artifacts before its write loop, but broad `--write` is not the reviewed integration procedure. Existing serial writes also are not an all-or-nothing guarantee against disk errors; Q1 concerns a deterministic, avoidable validation ordering defect instead.

## Independently verified evidence and code

All package code executed below was inspected first: complete candidate derivation, patch, staging script, verifier and tests. Complete baseline/candidate XML and JSON were parsed, including full provenance comparison after reversing only the intentional changes.

- Artifact manifest: **79 entries, 79 unique paths, all sizes and hashes pass**. Manifest SHA256 `2f21d07debb62e0068aef60497efb98b8bec408a0f6c72205c7a80a14812d526`.
- Source manifest: **20 entries, 20 unique capture paths, all sizes and hashes pass**.
- Exactly three source artifacts differ; all original function definitions remain, with the pure helper added. Regenerated patch is byte-identical to the reviewed patch.
- Memory map: **2930 unique parameters**, identical keys, exactly `mem_ss|msa_0|NUM_BANK_FIFOS` and `mem_ss|msa_1|NUM_BANK_FIFOS` change **8 -> 0**. Copies remain1. Simulation and PCIe collateral are byte-identical to baseline.
- Both complete semantic records contain raw false/8/1, source identity/hash, scoped output, decisive rule, evidence identities and saved-intent limits. Reversing the semantic additions, direct-count/unresolved-flag removals and memory output hash yields exact equality of the entire provenance object to baseline. No unrelated policy, auto-precharge, synchrony, topology or readiness drift was found.

| Reviewed artifact | SHA256 |
|---|---|
| `candidate/source/ipss/ia840f/derive_presets.py` | `bb07cdfc817e50517e3277cb6cb4daca2f80c4da37a6e158ceed36403cbe46c4` |
| `candidate/source/ipss/ia840f/preset_derivation.json` | `31218876eab8d532bbebe2f7e486a02f602dff20acb931bf9cb8a997f7913069` |
| `candidate/source/ipss/ia840f/presets/ia840f_mem.qprs` | `59d7f4dcd38386e6a3e54d86a22e3945c116f5951353c49dbf032e20a0b4bdbd` |
| `candidate.patch` | `bf4f4b8f6198fb3e0b9c0d3e186376b317460fcf3c01535c32e11f2969f8fcb2` |

## Bounded execution evidence

Executed only fresh temporary copies, never the original package:

- `/tmp/ia840f-quality-iuaxj6zb/package`: `python -B verify_package.py` returned **0**. Its four child commands all returned0: unittest, stage comparison, production derivation comparison, repeated stage comparison. **16 tests passed in 43.553 seconds.** Original four-artifact derivation reproduced, and baseline/candidate inventories stayed unchanged. Logs/results are under that copy's `verification/` directory.
- Separate relocated production layout with `source/` and `vendor/`, without `reference/`: ordinary `derive_presets.py --vendor-root ... --write` returned **1 / FileNotFoundError** for the missing evidence manifest, with the complete board-directory output inventory unchanged.
- Adding the exact captured `reference/` tree to that relocated layout allowed ordinary production compare-only invocation to return **0** with `{"source_artifacts": 4, "match": true, "execution_ready": false}`; outputs remained unchanged. This exercises actual root resolution and dependency layout, not merely helper calls.
- Mutating the relocated pinned PCIe fileset capture caused production `--write` to return **1 / AssertionError**, with outputs unchanged under the tested unoptimized invocation.
- The two additional publication-rejection probes above both exposed Q1. Normal tests passing does not override those observed failures.

## Minimum next stage and preserved boundaries

First correct Q1 locally, update the package evidence and obtain focused independent re-review. After approval, the minimum next stage is **reviewed source integration plus a source-bound fresh supported save/reload and generation**, not a direct compile of this fixture. Recheck the actual SOURCE baseline/QSF and required dependencies, bind the exact candidate and installed tools to a fresh worktree, and preserve the standing user approval without incremental user questions. This review issues no authorization record.

Before compile, require both scoped saved/nested values0 and generated wrappers0/copies1, complete before/after parameter maps including hidden/derived values, external/locked interfaces, ports, connections, clock/reset associations and exported boundaries. Itemize generation-only identity/path/timestamp differences; reject ignored parameters or unexplained drift. Preserve hold ON, seed2, maximum placement, clocks/core470/seven-output PLL, geometry, PCIe, pins/SDC and current calibration wiring. Do not conflate calibration indices with application mapping. The calibration-association acceptance issue remains separate.

No timing, readiness, functional, original generated-behavior equivalence or hardware qualification follows. Query04 remains prohibited; DDR simulation remains skipped. Work11 remains the completed failed-timing baseline, with no new timing outcome claimed.

## Changes and integrity boundary

Only this fresh `quality-review.md` was added to the reviewed package, outside its manifest. All **81 pre-existing package files** were inventoried and remained byte-identical before report publication; final verification is reported by the reviewer after publication. No SOURCE/WORK/gate/auth files were changed; no remote/vendor calls, generation/compile, Query04, DDR simulation, hardware actions, installation, permission changes or commits occurred. Temporary test evidence remains under the stated `/tmp` root. A single reusable collateral-preflight lesson was appended to the existing default-profile `source-bound-vendor-tool-gates` skill outside the package. No other profile was touched.

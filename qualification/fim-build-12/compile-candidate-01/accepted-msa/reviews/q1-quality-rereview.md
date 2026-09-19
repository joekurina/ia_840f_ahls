# Independent focused Q1 quality re-review

## Verdict: APPROVED — Q1 correction only

No must-fix finding remains in the minimal publisher correction. This verdict supersedes **Q1 only** in inherited `quality-review.md`; that review, `implementation-spec-review.md`, `review-contract/`, and inherited reports/logs/manifests remain historical evidence, not fresh successor approval. The prior translation/specification PASS remains applicable to the byte-identical three-file source candidate. This is not deployment, vendor execution, timing, functional or readiness acceptance; `execution_ready` remains false.

## Inspection and integrity

Read Q1-CORRECTION.md, the correction patch and changed-file inventory, inherited quality/spec reviews, and complete publisher, verifier and tests. Independently parsed and checked the current manifest rather than trusting its declared totals:

- Current `q1-artifact-manifest.json` SHA256: `39af42362e1e52f59658aab56173f64f22aa797ecb5d99af79f9f02d3bb857e9`.
- All **98 entries**, unique paths, byte lengths and hashes pass; they cover all **99 pre-review package files** except the manifest itself.
- Predecessor has **82 files**; all match the captured original inventory exactly. Its historical manifest's **79 entries** also independently pass.
- Actual successor delta agrees exactly with `q1-changed-file-inventory.json`: only **stage_candidate.py and test_bank_spreading.py modified**, **17 evidence/report files added**, none deleted. All other inherited files remain byte-identical. Independently generated unified diff equals `q1-correction.patch` exactly.
- Publisher SHA256: `d47b49f752fff8cad74ce8a8ca12b58401b7c2f913974012d523ddf0200ce98c`; tests SHA256: `2edfe21aad3c78e294bbdda33b6ba28298c8ebbacac9acfa98c7b689d77b3ebd`.

Unchanged accepted source identities:

| Artifact under candidate/source/ipss/ia840f | SHA256 |
|---|---|
| derive_presets.py | `bb07cdfc817e50517e3277cb6cb4daca2f80c4da37a6e158ceed36403cbe46c4` |
| preset_derivation.json | `31218876eab8d532bbebe2f7e486a02f602dff20acb931bf9cb8a997f7913069` |
| presets/ia840f_mem.qprs | `59d7f4dcd38386e6a3e54d86a22e3945c116f5951353c49dbf032e20a0b4bdbd` |

`candidate.patch` remains `bf4f4b8f6198fb3e0b9c0d3e186376b317460fcf3c01535c32e11f2969f8fcb2`. The inherited `artifact-manifest.json` intentionally describes predecessor bytes; it is not the successor authority.

## Failure-before-write compliance

At stage_candidate.py:112–115 the publisher checks every non-published output's existing file status and exact validated bytes before reaching either write at 116–117. The selected memory/provenance pair need not already be current. Full validation and deterministic derivation still precede publication, and the all-output final readback at 118–119 remains intact. Thus missing/stale simulation or PCIe collateral rejects before publication, as Q1 requires. The implementation is a narrow ordering fix, not a new transaction framework. No source derivation, gate policy or inherited assertion cleanup was introduced.

This approval concerns deterministic validation ordering, not atomicity under disk failure or concurrent filesystem mutation. Those are not the reproduced Q1 defect and no new guarantee is claimed.

## Independent execution

Execution was confined to fresh temporary copies under `/tmp/q1-independent-rereview-wn1svntv/`. Used `/home/joe/.hermes/hermes-agent/venv/bin/python -B`, `PYTHONDONTWRITEBYTECODE=1`, with `PYTHONOPTIMIZE` removed from the child environment. No historical package verifier was run in place.

In `package/`, `python -B verify_package.py` returned **0**. All four child commands returned **0**: unittest, stage compare, production derivation compare, repeated stage compare. **All 21 tests passed** (69.820 seconds), including all five PublicationOrder cases. The verifier reproduced the original four artifacts, preserved baseline/candidate inventories, and regenerated a byte-identical candidate.patch. Fresh logs/results are in that temporary copy's `verification/` directory.

Additionally ran five independent subprocess probes, not calls to the new test methods. Each started in a separate fresh package copy, with both selected publication files restored to actual captured pre-publication bytes (confirmed different from candidate bytes), then ran `python -B stage_candidate.py --publish`. Compared the entire package file inventory, lengths and SHA256 values before/after, including missing paths:

| Probe directory | Exit | Before/after file counts | Changed files |
|---|---:|---|---|
| stale-sim | 1 | 99 / 99 | none |
| missing-sim | 1 | 98 / 98 | none; missing simulation file remains absent |
| stale-pcie | 1 | 99 / 99 | none |
| missing-pcie | 1 | 98 / 98 | none; missing PCIe file remains absent |
| positive | 0 | 99 / 99 | exactly memory preset and provenance |

Negative diagnostics were `ValueError: stale or missing candidate: presets/ia840f_sim.qprs` or `ValueError: stale or missing candidate: presets/ia840f_pcie_known_schema.qprs`, as appropriate. Successful publication produced the exact accepted candidate bytes for both targets; nothing else changed. These observations independently close Q1, including missingness and the formerly misleading already-published baseline case.

## Boundaries and next step

Only this fresh report is added to the evidence package, outside the current manifest. Immediately before report publication all 99 original successor files and all 82 predecessor files were re-inventoried and byte-identical to review start. Final post-publication integrity verification is reported with the report hash in the reviewer handoff. Temporary fixture mutations/verifier outputs are isolated; no maintained SOURCE/WORK, gates or authorization records were edited. No remote/vendor calls, generation, compile, Query04, DDR simulation, hardware actions, installs, permission changes or commits occurred. No blocker was encountered.

Next is reviewed integration with dependency verification, then source-bound fresh supported save/reload and generation **before compile**, under standing approval without incremental user questions. The known missing deployment PCIe reference dependency must be addressed by verifying/staging exact pinned existing files and the required donor/schema/reference layout, with no fetch/install or pin relaxation. Preserve unoptimized Python. Require actual saved/nested zero values, generated wrapper zero values/copies1, complete parameter/interface/clock/reset/boundary preservation and explained generation-only drift. Retain the inherited physical constraints and separate calibration-association acceptance issue. This report does not issue authorization or establish timing/readiness, and does not reopen the accepted source translation for a broad investigation.

# Work14 isolated constraint comparison01 — prepared, native NOT RUN

**QUALITY REQUEST_CHANGES is parent-consumed: Q1 child-lifetime supervision blocks this package. SPEC PASS is retained, not sufficient for execution. No authorization or native A/B run occurred. Exact prepared exports and reviews remain unchanged; experiment02 was subsequently SPEC-rejected for stale Tcl routing. Fresh experiment03 has actual-entry routing tests passed, SPEC and QUALITY parent-consumed; its baseline subsequently failed rc3 at a load-cardinality assertion with termination/original preservation confirmed, and its candidate remains unissued.**

Review target is **`baseline/prepared-readback02/` and `candidate/prepared-readback02/`**, with their `prepared-manifest02.json` and `preparation02.json.gz`; not an assumed unchanged live tree or neighboring authoring files. Each archive has13 exports. [Parent readback verification](preparation-verification02.json).

| Binding | Baseline | Candidate |
|---|---|---|
| Candidate JSON SHA256 | `828849ff7b597d5269de8193091202b51feac6cca2afdc89f374e962c75125c7` | `2164915affe8f96c369cd2084eca66b7bd0d08237ba924ce2d01b2083d47a1a0` |
| Preparation archive SHA256 | `2ae2be6137c26f586cae9a344839f17e105c09843ce29b11af44e910ebaf3891` | `53bda029311930529d3230ed527a56237dca5615244490372dc9a0abfc34e4a2` |
| Archive bytes |1040024|1040491|
| Prelaunch / callback files |7884 /7761|7885 /7762|
| Symlinks |10|10|
| top.sdc SHA256 | `8255b34c200a46178174b9788bdc9231072ae829f57c34703cc63dd28ab66c3d` | `eb65af7949f130fffb011c6b5a96a5bc46bde5df7d57d99091e03730a441ff9a` |

## Actual preparation

- Attempt01 `%40` stopped at leaf `mkdir` because the new parent directory did not exist, **before copies/authorization/native execution**. [Failure](preparation-failure01.txt), original phase `prepare01.py` files and [dispatch01](preparation-dispatch01.json) retained.
- Attempt02 uses new `prepare02.py` files and fresh transfer/result buffers. Owned tmux `@41/%41` completed both phases, outer rc0. Baseline receipt `2026-09-22T08:27:29.913078+00:00`; candidate `08:27:50.041098+00:00`. [Dispatch02](preparation-dispatch02.json).
- Both report initial hash-identical copies and unchanged original Work14/SOURCE/PIM inventories. Each actual runner and dispatcher rejected missing authorization with rc1; neither created native artifacts.
- Parent verified decoded archive/readback/manifest equality, actual prepared Python3.9 syntax, byte-identical common query/helper/spec, and exact top.sdc before/after reconstruction. Only candidate's original generated-clock block is replaced; existing exception statements remain byte-identical. Both full top.sdc files are exported.

## Tests and prerequisites

- [Guard tests](guard-tests01.json):17 inert Tcl checks, not vendor API or fitted-result validation.
- [Runner tests](runner-tests02.json):11 checks using actual inert Python children and mocked gate import, including success/nonzero, time/output caps and a TERM-resistant descendant. Initial termination-delivery race failure is preserved in [failed test receipt](runner-tests01-failed.json); corrected runner waits for live process-group drain before returning from abort handling.
- [Specification](SPEC.md) separates finite completion, coverage completeness and numerical acceptance. [Research disposition](../DISPOSITION.md) binds source intent and actual installed report help. Unsupported Design Assistant API names are explicitly excluded; check_timing is not full DRC sign-off.
- E2 diagnostic result accepted and published at **`686223f0638d37cef8b62410d743030950dd9bfb`**. That is the latest established pushed milestone. This experiment/research arc has not been committed or pushed.

## Next handoff

The completed [SPEC review](spec-review01.md), SHA256 `89b9554fefb0cb555fa3e875fefbb703e3c468696a5b5bb845c758bf70d3f4f7`, is consumed by [parent receipt](parent-spec-consumption01.json) after fresh archive/manifest/readback and narrow-delta verification. All 13 exports per phase match; ten normalized changed bindings, one added helper and equivalent links agree with SPEC. [QUALITY REQUEST_CHANGES](quality-review01.md), SHA256 `4b1b771d5743464f2383df47f319009394fb17f61d93b1b19aab4abd86d7bd8f`, is consumed in [rejection receipt](parent-quality-rejection01.json). Do not issue against this package. Fresh [experiment02](../experiment02/) adds complete child supervision; it requires its own prepared-byte SPEC→QUALITY→parent acceptance before baseline issuance. Candidate authorization binds five successful baseline result records and rejects failed/incomplete/unpreserved baseline state. Do not pre-issue both or reuse any consumed stage.

Preserve readiness false. Separate EMIF1 hold, full timing/CDC closure, matching persona, live-backend/recovery and DDR/transfer/AHLS/sustained/QSPI-boot gates remain open. No hardware operations are part of these packages.

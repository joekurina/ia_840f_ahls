# CAPS01 actual Work21 persona qualification

Completed setup and mapped synthesis are accepted with findings; begin with [SYNTH-ACCEPTANCE.md](SYNTH-ACCEPTANCE.md) and the [FINAL independent review](synth-independent-review01.md). The additive raw-capability unit gate is separately accepted in [metadata01](../dma-csr-metadata01/UNIT-ACCEPTANCE.md). Mutable CURRENT.md tracks later-stage work; no fit, timing, hardware or lifecycle acceptance follows from this synthesis milestone.

## Publication policy

Per-file cap: **2,000,000 bytes**. Larger native reports remain local with exact sizes/SHA256 in the [synthesis inventory](SYNTH-PUBLICATION-INVENTORY01.json). Raw transport captures and generated payload-bearing runners remain local irrespective of size. Vendor/runtime binaries, installers, license material and agent transcripts are not published. `.gitignore` covers local runner/archive/report classes; curated small native artifacts are force-added only by the explicit reviewed allowlist.

`*-config-metadata.json` and `*-result-metadata.json` remove only base64 payload bodies. Where the metadata object exceeds the cap, named inventories are separately serialized and replaced by relative filename/size/SHA256 references. Parent reconstructed each full payload-stripped object exactly. These are metadata, not executable launchers; no raw payload is split to bypass the cap.

Frozen source/native/report whitespace stays unchanged. Exact path/hash-bound exceptions are recorded in [the audit](SYNTH-PUBLICATION-AUDIT01.json), not silently normalized or broadly waived. Historical "review pending" text in frozen RESULTS-SYNTH01.md remains unchanged; SYNTH-ACCEPTANCE.md is its additive final disposition. The same applies to the completed review's reference to then-separate unit review.

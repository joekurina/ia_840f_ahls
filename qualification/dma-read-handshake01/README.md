# DMA read-request qualification evidence

Current disposition: [ACCEPT_SCOPED_SOURCE_AND_READ_UNIT_ONLY](RESULT-ACCEPTANCE.md). See [independent review](independent-review01.md), [parent verification](parent-review-verification02.json) and [current checkpoint](CURRENT.md). Frozen pre-review reports remain byte-identical; their pending-review language is historical.

## Artifact policy

Maximum published artifact size:2,000,000bytes. Publish only explicit reviewed/accepted evidence, authored patch/tests and the payload-free runner template. Full original/candidate/vendor/PIM sources in `inputs-original/` and `inputs-candidate/`, and payload-bearing `run-red01.py`/`run-green01.py`, remain local-only under this directory even when smaller than the cap; `.gitignore` excludes them. Their SHA256 bindings remain in source-binding01.json, native result input ledgers and dispatch receipts. Preserve original licensing/provenance; do not publish tool/license/runtime bytes or raw agent transcripts.

The compact native result JSON includes the complete bounded native logs, command/tool identities and source hashes. It contains no source payload or license contents. Never normalize hash-bound raw evidence or the context lines in the patch to silence whitespace findings.

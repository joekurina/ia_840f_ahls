# Corrected AHLS memory IP — native Quartus 25.1 elaboration

[Parent acceptance](RESULT-ACCEPTANCE.md), [independent review](independent-review01.md), [verification](parent-verification01.json) and [current checkpoint](CURRENT.md) establish successful standalone analysis/elaboration with findings. Historical `RESULTS01.md` and `warning-ledger01.json` retain their pre-review wording; they are immutable review inputs, not the current acceptance state.

## Evidence and artifact policy

The artifact cap is **2,000,000 bytes per file**. The two larger native synthesis/elaboration reports and compressed raw transfer remain local-only, excluded by `.gitignore`. Exact hashes and sizes are in [manifest-elab01.json](manifest-elab01.json); [review-package01.json](review-package01.json) binds the reviewed inputs. Small native logs/DRC/flow reports, launch scripts, dependency and warning ledgers are published byte-for-byte. No vendor runtime, installer or license bytes are published; license paths are not license contents.

- Original archive `result-elab01.json.gz`: 348,519 bytes; SHA256 `7ce24877a886417f6ff2e379f79b2a2ead0a07eb7a38399e5b8d1665f7456480`.
- Local raw reports: `artifacts-elab01/output_files/ahls_memory_elab.syn.rpt` and `ahls_memory_elab.syn.ae.rpt`.
- The source inventory and dependency ledger refer to the isolated copy of accepted [native import/generation](../ahls-memory-pd25-import01/RESULT-ACCEPTANCE.md). They are not a live image-to-source binding.

Native rc0 and outer125 are both preserved. Do not rerun the spent standalone project merely to change bookkeeping flags. The project is not a board image to program. No mapped synthesis, DMA/PIM integration, numerical, timing or hardware acceptance follows. DDR simulation remains **SKIPPED BY USER**.

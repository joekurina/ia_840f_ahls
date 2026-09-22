# Work15 native clock-corrected FIM iteration

See [CURRENT.md](CURRENT.md) and [RESULT.md](RESULT.md). Native compilation and assembly completed; numerical timing **FAILS**. Independent native-result review is parent-consumed in [RESULT-ACCEPTANCE.md](RESULT-ACCEPTANCE.md). No hardware operation occurred.

## Evidence recovery

- `synthesis02.json.gz` and `synthesis-manifest02.json` additionally retain the full synthesis report, verified identical to the original warning snapshot. Decode its per-file `gzip_base64` exactly as the report archive below. Raw synthesis is ignored under reports01/. Warning triage and the added complete-panel readback are parent-consumed, without clearing the remaining warnings.


- [reports-manifest01.json](reports-manifest01.json) binds nine complete native reports. `reports01.json.gz` contains gzip-compressed JSON; each `files[relative_path]` has a `gzip_base64` field. Base64-decode, gzip-decompress, and verify the recorded size/SHA256 to reconstruct the ignored `reports01/` tree.
- [completion-manifest01.json](completion-manifest01.json) binds final native status, log, summaries, flow/assembly and metadata. `completion01.json.gz` uses the same per-file encoding, with absolute original remote paths. Local readback splits those into `completion-readback01/evidence/` and `completion-readback01/project/`. The oversized raw native log is ignored but retained losslessly in the archive.
- [postflight-summary01.json](postflight-summary01.json) and `postflight01.json.gz` preserve full original/source inventories. The SOURCE root gained the native build log; it is not globally byte-identical.
- [result-review-freeze01.json](result-review-freeze01.json) binds 55 actual prepared/result inputs. Later postflight evidence is an explicit supplement, not a rewrite of that freeze.
- [warning-review01/README.md](warning-review01/README.md) describes the parallel warning snapshot and its extraction limits.

Keep raw evidence bytes unchanged, including vendor whitespace. Archives are lossless evidence, not executable tools. Default publication cap is 2 MB per file; no bitstreams, installed binaries, license contents or secrets are included. Assembly artifacts are only inventoried by size/hash in completion evidence; they were not programmed or hardware-qualified.

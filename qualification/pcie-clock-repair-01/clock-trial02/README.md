# Clock-trial02 evidence storage

This directory contains the accepted candidate-only offline STA package and its completed native result. Package acceptance and native-result acceptance are separate: see `ACCEPTANCE.md`, `CURRENT.md` and `RESULT.md`. The narrow native result is independently accepted in `RESULT-ACCEPTANCE.md`; no timing or hardware acceptance is implied.

## Byte-preserving result storage

The publication artifact cap is **2,000,000 bytes per raw artifact**. Oversized candidates remain local under `prepared-readback01/`; their exact bytes are retained in the preparation archive and bound by `prepared-manifest01.json`.

`result01.json.gz` is a lossless gzip JSON export, 1,763,076 bytes, SHA256 `1619230e6582918bc8eb51e3f05c0514348f4b34c7f0afb6535bd1e5cb4d533f`. Its `files` mapping contains all 86 result exports, each with `base64`, `bytes` and `sha256`. These include all 79 report files, totaling 49,058,648 uncompressed bytes. `result-manifest01.json` binds the full set; `result-readback01/report-manifest.json` binds the report subset.

All raw `.rpt` tables stay local under `result-readback01/reports/`, avoiding duplicated bulk in Git. They can be recovered byte-for-byte by gzip-decoding the archive, JSON-decoding `files`, base64-decoding the selected entry, and verifying its declared byte length/SHA256 against both manifests. The native audit Tcl-list and process/status/log receipts remain separately publishable. Do not evaluate the audit as Tcl code; parse it as data.

This storage policy does not omit evidence from the archive, replace native reports with summaries, or change frozen bytes. The independent reviewer has the full extracted set locally. Preserve whitespace and line endings of every raw capture. Never publish licensed tools, installers, bitstreams, secrets or raw agent transcripts.

# Work18 completed-native-run milestone scope

This milestone closes the independently reviewed **actual-result evidence** gate, not timing or hardware qualification. Result disposition: native rc0, numerical hold−0.004ns persists, all five detailed corner paths unchanged. See RESULT-ACCEPTANCE.md and result-independent-review01.md.

Preserve the102frozen inputs byte-for-byte. Oversized native logs/STA/fitter stage payloads remain local at their manifest paths; exact decoded bytes are reconstructible from the compact hashed completion01.json.gz, reports01.json.gz and postflight01.json.gz archives. Existing reports01/ exclusion also avoids duplicating smaller decoded report files. Reports/scripts/archives over2MB are not tracked; all archived exports were verified. No programming images, rawQDB, license contents, secrets or agent transcripts are published.

The local mutable CURRENT.md, subsequent assignment-readback directories/dispositions and concurrent vendor-remedy research are **not included** in this accepted compile milestone. They do not inherit independent acceptance from the compile review. New ignore policy for oversized postflight reports is administrative and does not alter frozen evidence. Unrelated repository edits are preserved and excluded.

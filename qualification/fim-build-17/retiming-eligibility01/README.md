# Work17 exact-register retiming eligibility

[Result acceptance](RESULT-ACCEPTANCE.md) records the independently reviewed native synthesized-snapshot evidence. Exactly one literal EMIF1 bit243 register was returned, and installed Quartus metadata lists `ALLOW_REGISTER_RETIMING` for Agilex 7 Fitter instance scope with legal On/Off values. This is eligibility only, not assignment consumption, a timing fix, or hardware qualification. The subsequent Work18 trial is a separate in-flight scope.

The native diagnostic finished with return code 0, no errors and one retained Critical Warning 20727. [Independent review](result-independent-review01.md), [parent consumption](parent-result-consumption01.json), [native result](RESULT.md).

## Evidence storage

Individual tracked artifacts are limited to 2 MB. The oversized decoded `prepared-readback01/candidate.json` is excluded by the local `.gitignore`; exact bytes are retained losslessly inside `preparation01.json.gz` and bound by `prepared-manifest01.json` and the review freeze. Candidate SHA256: `a5e24ad6e8e302277e0fd181ec03f64d9f7ecb5b0a20495ee0c37bebf8606239`.

The preparation archive contains 13 exports; `result01.json.gz` contains 9. Captures and native-source whitespace remain byte-preserved. Original build databases stay remote and are referenced by inventory hashes, not published as payloads. No license contents, installers, vendor runtimes or programming images belong in this milestone. Internal publication audits remain outside the repository.

The completed diagnostic authorization is spent. Nothing here authorizes a rerun or device access.

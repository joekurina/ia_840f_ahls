# Preparation01 rejection and preparation02 correction

Preparation01 in @46/%46 stopped with outer rc1 at the pre-existing-attempt check, before headroom inventory/copy/native work. [Failure pane](preparation-failure01.txt). Parent's retarget matched absolute `/qualification/...` strings in runner/gate, but missed the preparer's relative `E=B/'qualification/.../experiment03/baseline'`. AST/inert import alone did not check that value. This was a parent implementation error, not a Quartus or host failure.

The predecessor catch handler also appended a new `preparation-error.json` under the old baseline root because it checked existence rather than ownership. It overwrote no existing file. Parent preserved that appended receipt in [ordinary-file preflight02](preflight02.json); all21 named old prepared/result artifacts hash-match their accepted local manifests. The prospective fanout-diagnostic01 leaf was absent. No native tool or authorization was launched by this failed preparation. The earlier baseline's native failure and evidence acceptance are unchanged; this note does not claim its entire evidence directory received no new file.

[prepare02.py](prepare02.py) corrects the relative root explicitly, uses fresh02 script/input/export buffers and exports its own prepare02.py identity. Its error handler can write only after this invocation successfully created the exclusive leaf (`OWNED=True`), never merely because a prior leaf exists. The failed prepare01.py and transport receipts remain intact.

[Four inert regressions](preparation-tests02.json) reproduce the stale old root and unowned error append, verify preparer/runner/gate roots agree, and exercise the actual successor rejection entry with a pre-existing local fixture leaf, requiring no new files. No remote/vendor action occurs in those fixtures. [Correction diff](preparation-correction02.diff).

The query, helper, known receivers, runner and gate were not changed by this correction; the native-input payload hash remains unchanged. Fresh prepared readback and SPEC→QUALITY→parent acceptance are still mandatory before any diagnostic authorization. No candidate A/B phase is authorized.

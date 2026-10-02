# Q15-1 identity-boundary correction — unissued

[QUALITY15](review-quality15.md) is **NOT APPROVED** and remains unchanged. No admission or native synthesis was issued from that package. The original SOURCE/API08 design-preparation acceptance is retained; [source-continuity20](source-continuity20.json) proves the narrow successor delta.

## Reproduced defect and correction

The production runner returns `/proc/<pid>/stat` start ticks as a string; callback09 converted the same field to integer. Strict owner and ancestor equality therefore rejected the real owner. [The same nine-case driver](test-identity17.py) failed three positive cases on the frozen originals ([oldfail17](identity-oldfail17.json)), then passed all nine on the correction ([pass18](identity-pass18.json)). It uses actual production identity(), JSON serialization and /proc readers, a finite inert Python child and current-owner/child ancestry. Only the callback-parent entry point, file/context bindings and environment are fixture substitutions; no Quartus/native executable or remote operation is represented by these cases. Changed start ticks/executable/cwd/argv and an exited real owner remain rejected.

The callback retains the **raw decimal start-tick string** without numeric normalization. Strict PID/start/executable/cwd/argv comparisons are untouched. Its only other edit is control09→control19. The runner changes only that control root and its own filename run-synthesis09.py→run-synthesis18.py; its identity producer, supervisor, commands/resources and postflight remain byte-identical after inverse retarget. [Gate delta18](gate-delta18.patch), [runner delta18](runner-delta18.patch).

## Exact preparation and preservation

[Stage19](stage19-readback/correction19.json) created fresh control19 and backed up the old copied-project callback before replacing that **unissued** callback. This is not a claim that base01's old callback path is unchanged: exactly that one entry changed. All remaining design bytes/links and QSF, Tcl, CMake, source loader, contexts, settings, RTL, SDC and static QDB are unchanged. The old callback body is exact in predecessor/ia840f_persona_gate09.py and the retained91-member package. All874 remote control09 entries, including857 DNI archive entries, remain unchanged; no old admission or synth01 exists. Original setup/release/external/tool/result preservation was rechecked. Draft19 additionally pins every predecessor non-archive control file as a prerequisite; the DNI remains separately fully bound.

Active inventory2589/critical2588/external298/archive857 and all36 CPUs/64GiB per-process/60-60-1200-second deadlines/32MiB polled logs remain unchanged. The QPF prelaunch/postflight treatment and all independent actual-result obligations in [execution scope14](EXECUTION-SCOPE14.md) remain. Historical references there to control09/issuer16/tests12 are superseded by this correction, not rewritten.

## Tests and issuance boundary

Corrected gate:21 inert cases. Runner:23 real-inert-child cases, adding the previously absent predecessor-result-drift rejection. Integration:9 real process/serialization cases. Issuer23:7 protocol fixtures. The unchanged CMake and Tcl retain their previously recorded5 and2 cases; those are reused evidence, not new executions. Actual staged corrected runner and callback reject missing authority without creating synth01. Those rejection checks do not constitute native project-load acceptance.

Issuer23 is a mechanical retarget of unissued issuer16: control19/admission23, exact draft19/runner18 SHA256, source-continuity20/review-quality22/quality-consumed23 receipts. Only its bound transport digest can be rendered after renewed execution QUALITY. It still verifies the exact permitted admission delta, writes exclusively, reads back and invokes only non-consuming preflight. No actual issuer23 invocation has occurred.

**Next:** fresh focused QUALITY22 against this revision and its91-member preserved predecessor, then parent consumption, exact admission/readback/preflight and at most one owned mapped synthesis. No fit, STA, assembly, GBS, programming or hardware is included.

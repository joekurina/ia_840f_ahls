# Fanout diagnostic01 — native rc3, partial observation

**Native/raw/effective/outer rc3. Diagnostic INCOMPLETE. Independent actual-result review pending. No collector, A/B, timing or hardware acceptance.**

One source-bound diagnostic executed in @49/%49, native PID20822, from2026-09-22T11:28:04.064078+00:00 through11:28:43.231430+00:00. [Native receipt](result-readback01/native-result.json), [execution status](result-readback01/execution-status.json), and [captured outer rc3/shell return](completion-pane01.txt) agree. Termination is literally true, no live owned descendants, no abort and no supervision errors. [Preservation](result-readback01/preservation-after.json) records original Work14/SOURCE/PIM all unchanged. Single-use attempt is spent; never reissue it.

[Result archive](result01.json.gz) SHA256 `840a2bbd52b448a52c3ccae6ffe9968d09cd0a0a4fb9541044459cdac67bc78f`,24806bytes, binds8 exports. [Manifest](result-manifest01.json) and [parent verification](result-verification01.json) verify every export and the sole audit report. [Programmatic analysis](result-analysis01.json) retains all audit tag counts, warning counts and SDC-load mentions.

## Actual partial findings

- Exact pin O was resolved; its `get_fanouts -clock` count was0, cap4096.
- Exact synthetic K=`D~div_reg` resolved once through each of get_keepers/get_registers; its separate `get_fanouts -clock` count was also0, cap4096.
- Both enumerations were complete empty observations, with no differences/intersection. This is the result of these specific forward queries, **not proof that physical clock loads are absent**; prior reverse-fanin and unassigned-clock diagnostics remain.
- Known manifest count32 was emitted. The first exact known_receiver lookup through get_keepers returned0 and required1, before any complete known32/tile membership or reverse-fanin audit. Native Error23035: `CLOCK_REPAIR_REJECT identity count {known_receiver} actual=0 expected=1`; Error23031 follows. The audit retains the exact failing name. Do not yet attribute this to pattern escaping or a cell-versus-keeper naming difference without source/API diagnosis.
- No completion marker. No support verdict or collector replacement is accepted. Do not retrospectively claim the old experiment03 missing count was recorded: this is a separate measured attempt.
-201 warnings match the prior diagnostic classes; generated-only property guard produced no Warning22890. Warnings disappearing is not timing success. Original-path SDC mentions embedded in the fitted QDB remain and require binding reconciliation, not opaque-database editing.

The previously approved package remains an independently reviewed executable specification; its real partial result failed and is not accepted by that package approval. Candidate experiment03 remains unissued/blocked. Next is independent result review plus bounded local source/API diagnosis, retaining the original cap and all mission gates. No automatic rerun, constraint change, full fit, vendor-IP edit, reset or hardware access.

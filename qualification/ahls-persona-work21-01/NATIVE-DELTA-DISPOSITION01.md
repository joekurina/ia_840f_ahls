# Preserve outer125; reconcile native output mutation

synth01 completed native/effective0 with no timeout or surviving owned group, but the runner returned outer125 because its blanket input-preservation predicate included copied Quartus **DNI checkpoint/report outputs**. The original receipt and false predicate remain unchanged. This is not rewritten as runner success.

The subsequent exact readback found **34 changed bound entries, all under the candidate project's `dni/` directory**. All **4345 non-DNI bound inputs**, including RTL, generated fabric, QSF, static root QDB and copied base programming artifacts, remain byte-identical to their bound values. Original setup, release and installed tools were independently preserved. [Full delta](native-delta-disposition01.json), [readback receipt](outer-synth01-delta01.json).

The preparation checked absence of `qdb/` and `db/` but overlooked the archive's `dni/` checkpoint directory. Its comment claiming no mutable checkpoint snapshots was too broad; the native rewrite demonstrates that distinction. The log and reports prove the real selected AFU was newly elaborated/mapped; do not treat inherited empty-template checkpoint contents as the new result. No unchanged synthesis rerun is justified to satisfy this overly broad bookkeeping predicate. Future stages must distinguish bound RTL/static/synthesis inputs from enumerated stage-owned database/report outputs, without weakening source/tool checks.

Parent source-preservation reconciliation is complete; independent acceptance of the bounded native mapping evidence is pending. All warnings/DRCs, fit/timing/PR and hardware obligations remain open.

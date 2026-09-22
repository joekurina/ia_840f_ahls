# Guard02 successor component SPEC

This fresh local component corrects only F1 in [the rejected guard review](../guard-spec-review01.md). The complete [original component contract](../GUARD-SPEC.md) remains in force. Original reviewed files/manifest/report and original helper prefix remain unchanged. No complete A/B package, native authorization or source promotion is implied.

- New post_output_pin_v2 validates the actual postcreation/full-SDC O collection: record and flush its raw count before cardinality/name/direction/type rejection. verify_created_v2 selects it instead of legacy one_pin. Keep exact O and all other guard behavior.
- The harness records puts and flush events separately. Two post-only faults make O lookup zero/multiple only after one clock creation; require error, exact count-record then flush ordering, retained created flag and denied rerun without another create.
- Preserve all existing34case outcomes. The new36case receipt is inert/local only. guard-f1-red01.json preserves the expected first missing-post-count failure against rejected helper bytes; it is not a native result or proof that both red faults were reached before the harness stopped.
- Future integration must copy this reviewed successor helper, not the rejected parent helper, and must call apply_v2/verify_created_v2 at the planned positions. Native insertion-time state and returned clock-property representation remain unproven; fail closed when unexpected. Full prepared package will need its own source-bound review and authorization.

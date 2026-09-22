# Fanout diagnostic03 — native rc0 complete; finite diagnostic evidence accepted

**One-use diagnostic completed @53/%53: native/effective/outer rc0, termination confirmed, original Work14/SOURCE/PIM preserved. Complete finite mapping of all32 selected cells. Both `deleg_5b886765` leaves completed and parent-consumed in [RESULT-ACCEPTANCE.md](RESULT-ACCEPTANCE.md). Finite32 mapping accepted; fresh corrected A/B preparation is the next step. No collector/timing/hardware acceptance. Attempt SPENT; `ready_for_build=false`.**

Actual review target: `prepared-readback01/`,15 exports. [Preparation verification](preparation-verification01.json) binds lossless archive/manifest/readback equality,8 authoring matches,7885 files/7762 callback files/10 links, nine normalized changed bindings with no additions/removals, equivalent links and identical full original preservation inventory. Original Work14/SOURCE/PIM remained unchanged; original top.sdc is unchanged. Actual runner/dispatcher missing-authorization checks each returned rc1 and launched no vendor tool.

- Archive SHA256 `b9e6c8c35888553380cb047bb363fecf9c3d50e0b4f3b5e90339c0af18b63a70` (1434403 bytes).
- Manifest SHA256 `063e0f0baa29c39bd52981ef2b033538fec5068272dc221205c8433b017f3dca`.
- Candidate SHA256 `16acaa0babf1103eb573e76459f1e98fafc3aadeeff8b2acb23dd172d61a9949`.
- Actual query SHA256 `22e5f6e05913325fa14a8753cda91c63bef98bec7893e333972f721e7c6e06b9`.

The only query semantics change is our scalar and its two references renamed to `ia840f_fc_cell_pin_collection`, plus fresh root identity. No vendor array is unset. All roots, four forward calls, six selector controls,32-cell pin/reverse/buried mapping, caps, logs and completion checks remain. [Exact delta](query-delta01.diff), [SPEC](SPEC.md), [accepted source diagnosis](../fanout-contrast-diagnosis02.md).

All83 recorded inert cases passed across six fixture invocations:25 authoring query +25 actual-prepared query +10 authoring collision executions +10 actual-prepared collision executions +11 supervision +2 preparation. Each collision suite contains three expected old failures and corresponding successor successes, no-array/global-only controls, full entry, complete32 mappings on success and preserved sentinels. These exercise synthetic scopes/control flow, not native array origin or Quartus graph semantics.

SPEC `deleg_544e7c59` PASS and QUALITY `deleg_552f61f8` APPROVED are complete and parent-consumed in [ACCEPTANCE.md](ACCEPTANCE.md) and [parent-consumption01.json](parent-consumption01.json). Both independently replayed all 83 inert cases; prepared bytes remain unchanged. Package accepted and published `bb983ec50f711df0e2f6d0ece9bc5070f18e0ae8`. Separately inspected issuer was consumed once; [native result](RESULT.md) completed rc0 and its finite diagnostic evidence is independently accepted. No rerun/reissue. Predecessor diagnostic02 is spent; failed-result evidence published `bedc78a6f1361a985b83a55529d00981c501b571`. The inactive helper and old experiment03 candidate remain blocked. No collector/A-B/clock-repair/timing/CDC/DRC/hardware acceptance.

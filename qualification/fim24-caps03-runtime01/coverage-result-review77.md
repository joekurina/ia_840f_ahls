# FINAL — PASS WITH LIMITS

**ACCEPT the ACTUAL migrated-image coverage74 result for the one 34-case boundary/repeat gate. Primary technical blockers: none within that scope.** This independent review used local ordinary-file reads, hashes, AST/JSON inspection and arithmetic only: no project imports, project execution/tests, native/vendor tools, Git, remote/device access or code changes. Only this review file was written. Parent acceptance/state transition remains separate.

## Integrity and actual cardinality

- Verified [coverage-freeze76.json](coverage-freeze76.json), SHA256 `ced983766056932c264b921eb82648029b7fa3dc7fc88e87632e84f5a8de0282`: **24/24 frozen members**, exact sizes/digests.
- Independently decoded [coverage74/envelope.json.gz](coverage74/envelope.json.gz), SHA256 `b089f2f7a511e7379a33cdc51af3e5c9fa48fba290ea7dad1222d429c70b76c5`: **16/16 actual exports**, exact filename set, remote source paths, sizes, digests and local readback bytes. Batch `ia840f_capture_56e9547f2e02440d92f1d2e696dea66f` and script SHA256 `c1cbf19444e9d334d5a5da66edbbd2c95f2f43dafa9445a4bdae1f0728822786` match frozen index/transport and [coverage74.py](coverage74.py). Envelope, index, raw result, nested inner receipt and original logs reconcile exactly—not just parent75's reduction.
- [Raw result](coverage74/readback/result.json), SHA256 `37fc5468f150c45c1a5a998f2525a499b00106bf09c764f3ae0ae10b87e2c324`, confirms application start/runtime preflight, **native0/container0/outer0**, `EXITED`, finite success and **no retained owner**. No manual reset, retry or error is recorded; original bound objects remain unchanged.
- Reconstructed the complete case/segment plan from retained [live02-inner.py](../caps03-coverage01/live02-inner.py), without importing/executing it. Both layouts contain exactly lengths **1,8,9,16,17,31,32,33,63,64,65,127,128,129,255,256,257**, in order. Padded input/guarded output spans and `min(128, remaining, DDR-page room, host-page room)` segmentation reproduce every exposed submission field and cumulative case count. The **entire 1,116-line native log** equals the expected ordered transcript: **34 case rows, 536 submissions, 536 retirements (sequences 0–535), one exact footer**—**1,107 scoreboard records**. No missing, extra, malformed, duplicate, FAIL/FAILED or HOLD record occurs. Independently derived rows/totals also equal parent75.

Exact footer:

```text
FPGA Test CAPS03 COVERAGE PASSED: cases=34 integers=2982 descriptors=536 verified_payload_and_guards=1
```

## Actual data and finite runtime acceptance

- Totals: **2,982 signed integers, 11,928 result bytes, 5,224 guard bytes, 536 descriptors**, across 34 HLS invocations in one owner. Selected coverage frontend/original frontend/segment-header bytes match original native01 source bindings. Coverage source SHA256 is `1395f980d5a5ba7a903d236348c905d312e2488486ad8e0cf99088872a9546e6`; its reused ELF SHA256 `760a9e4768e9dc10f6ac510e948aa0b4691948ff242908bc23921ed6505964ed` agrees with native01, admission73 and the actual binding.
- The bound frontend checks little-endian signed `a+b` throughout each result span, unchanged DDR prefix/tail guards, **both complete 4,096-byte host pages after every descriptor**, ticket1, exact completion `0x10002`, zero guard status and quiescence before case PASS. Expectations fit signed int32. This accepts source-bound **in-process actual-data comparisons**, not a separately dumped hardware vector or second out-of-process numerical verification.
- Reused accepted numerical/normal-entry provenance [review71](copyback-result-review71.md)/[parent72](COPYBACK-ACCEPTANCE72.json), without reopening its 14-source/23-record reset corpus or replaying setup/deployment. AST confirms original coverage `C/BIND/INNER/NEW/supervisor` literal assignments unchanged; wrapper `exec(compile(BODY,...))` preserves embedded source strings. Exact accepted72 SHA256 `6093d318aeac6eb6fde6dc97652534b62bb3466d5e486dcec68ac2402fb232ab` is consumed before exclusive coverage74 creation; in-run admission equals admission73.
- Fresh coverage74 checks retain migrated StaticFME `fc603c44-5c8f-5e94-bcbe-a5780030947c`, unchanged boot `3e2d2060-d6c0-44b5-a269-1adf1e450041`, loaded-module bindings, exact VF `0000:4f:00.2`/singleton group76/literal `flr\n`, and both named EMIF init readings **1** at current `dfl_dev.4` before the frontend. Actual loader initializations/control transfer reconcile **10 bound ELF objects** and their transitive closure; runtime/plugin/CWD checks and the checked read-only `/work`, `/coverage`, `/exec`, `/empty`, `/sys` mount targets remain bound. Only VFIO76/vfio device bindings are exposed. UNKNOWN ownership-retention semantics remain unchanged; that path was not entered.

## Lifecycle acceptance and limits

The unsuppressed original kernel interval contains exactly one concern:

> vfio-pci 0000:4f:00.2: timed out waiting for pending transaction; performing function level reset anyway

It is the exact user-accepted pending-before-FLR erratum, not a warning-free result: preserve **`lifecycle_clean=false` / `lifecycle_accepted=true`**. No other concern/fault appears. Before/after root-visible observers reconcile to empty holders/maps/D-state/errors, inactive SDK service, unchanged PCI route/boot and only this transport's relevant processes. These are finite endpoint observations, **not proof of globally drained transactions or clean reset/clock waveforms**. Different warnings/faults remain failures; nothing was suppressed or bypassed.

Acceptance covers **only this boundary/repeat result**. It establishes no DDR-independent/isolation/sustained qualification, walking-bit or concurrent-bank bulk gate, all-capacity/all-DDR correctness, throughput, MTBF, electrical/DRC signoff, cold/PR/active-fault/universal reset safety, universal physical equivalence or `hardware_ready`. Prior timing/CDC/electrical limitations remain intact. No flash, reboot, reset/rebind replay, new gate admission or overall task closure follows from this review; parent alone may consume the scoped result.

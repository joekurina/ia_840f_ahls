# FINAL — PASS WITH LIMITS

**ACCEPT the ACTUAL migrated bulk92 source-supported concurrent-bank functional result. Primary technical blockers: none within the agreed finite gate.** This independent review used local ordinary-file reads, SHA256, AST/JSON/text inspection and arithmetic only. No project imports/execution/tests, native/vendor tools, Git operations, remote/device access, hardware operations or code changes occurred. This report is the sole write; parent alone consumes acceptance and closes the task.

## Integrity and actual completion

- Verified [bulk-freeze94.json](bulk-freeze94.json), SHA256 `617da219a0ca2b93220a1049f2e01c6f386b4e28ba1ab60dec33381f3183184d`: **24/24 members**, exact sizes/digests, unchanged at final verification.
- Independently decoded [bulk92/envelope.json.gz](bulk92/envelope.json.gz), SHA256 `0b570c6e15f933da75c5098377e7f05b2a38359da5dc7f967e3579b2b8c5a0f4`: **16/16 exports**, exact filename set, remote source paths, sizes, hashes and local readback bytes. Batch `ia840f_capture_942a5bea6b6d449da149f3233ac9d20f` and [bulk92.py](bulk92.py) SHA256 `f98dc21e571ce7ccccd80bac6ef187a268f8278a716441c6b5eca3c0679bddb3` reconcile with transport/index. Envelope, raw result, nested inner receipt and actual logs agree, not merely parent93's reduction.
- [Raw result](bulk92/readback/result.json), SHA256 `160ef6a439d3cb4c9daf33e2ee8b4009cc2b323118db153e7a74090a4b7958fa`, establishes application start/runtime preflight, **native0/container0/outer0**, **`EXITED` / no retained owner**, successful numerical completion and unchanged bound objects. No recorded failure, manual reset or retry.

## Whole transcript, data and completion

Reconstructed the complete **411-line / 27,257-byte** [native transcript](bulk92/readback/native.log), SHA256 `62dd3208f64fa8acb464ba1ebf31cf43fc2a210c4fab650f8fa9d44c29dcb1e5`, byte-for-byte from the unchanged frontend and original `caps03-bulk01/live02-inner.py`: **3 identity notices, 4 capability notices, 1 quiescent-history notice, 66 sampled submissions, 66 sampled retirements, 268 tile records, 1 HLS completion, 1 exact PASS footer and 1 limitation banner**. All fields and complete inter-family ordering match; no extra/malformed/duplicate/missing row or FAIL/FAILED/HOLD/UNKNOWN marker. Counts also reconcile with inner and parent93.

The independently reconstructed 3,968-byte tile / host-offset64 / at-most128-byte page-tail segment plan matches the original retained address-domain plan exactly:

| Region | Mode / bank | DDR base | Bytes | Descriptors / tiles |
|---|---|---|---:|---:|
| X preload | 1 / 0 | `0x10000` | 262144 | 2048 / 67 |
| Y preload | 1 / 0 | `0x60000` | 262144 | 2048 / 67 |
| Z poison + guards | 1 / 1 | `0xffc0` | 262272 | 2114 / 67 |
| Z copyback + guards | 2 / 1 | `0xffc0` | 262272 | 2114 / 67 |

- **8,324 descriptors / 268 tiles** total; exposed submit/retire rows are only sequence%128==0, from0 through8320. This does **not** claim 8,324 individual log rows. Unchanged C still checks every descriptor's arguments/readback, error-free finite completion-counter advance and quiescence, and both complete **4,096-byte host pages after every descriptor** before reuse.
- Verified **15 selected current host-source bindings** against original native01. [Bulk frontend](../../src/host/ahls_memory_caps03_bulk.c) SHA256 `9d564d77755e787553c90ef41cc1838ef68dd631594e9556cb651e11ff71deeb` is unchanged; retained native01 **43,856-byte ELF** independently decodes/hashes to `1c79f4378e947edb8c43d045597b1a767a38b6b73f580396fdaf8411139bddcd`, matching actual binding, admission and module argv.
- Source-bound actual validation covers **all65,536 integers / all262,144 result bytes**, with `X=i`, `Y=2*i+1`, expected `Z=3*i+1`, little-endian encoding and signed32-safe arithmetic. Z starts as the complement of every expected payload byte; both64-byte DDR guards are initialized and checked unchanged. Every copyback segment, full tile and full host pages must match. This is independently audited in-process actual-data validation, **not exported DDR vectors or a second out-of-process payload comparison**.
- Exactly one invocation reaches **ticket1 / completion`0x10002`** after all three preloads and before copyback. Final acceptance additionally requires guard status0, completion still`0x10002`, the last DMA report quiescent and sequence8324; only then is kernel uncertainty cleared. PASS follows successful buffer release, MMIO unmap, handle close and token/property cleanup. The unchanged retention path handles uncertain outcomes and was not entered.

The accepted [source-review01 basis](../caps03-bulk01/source-review01-consumed.json) is reused, not new authority: two finite-buffered load LSUs feeding eight adders and a separate store LSU support streaming bank0 X/Y loads with bank1 Z stores under approved compiler/vendor semantics. Current kernel annotations/arithmetic agree. The host DMA phases themselves are serial. This finite actual invocation supports the agreed concurrent-bank **functional** gate, not observed DDR-wire overlap or sustained concurrent bandwidth.

## Reused provenance and fresh finite lifecycle

- Reused accepted walking89/90, DDR83/84, coverage77/78, numerical71/72, normal-entry58/62 and deployment56/60; review pins agree. Exact WALK90 SHA256 **`d29fde3c0cb44e87546c623c07c1ad0f20ba363ffdd1872815a47147e36086ff`** matches its retained remote readback. Acceptance predates bulk92; AST verifies exact hash/accepted checks before exclusive fresh leaf creation. No reset14-source/23-record corpus re-audit, setup/flash replay or rebuild.
- AST confirms original **`C/BIND/INNER/NEW/supervisor` unchanged**, emitted inner/binding/supervisor match actual exports, and the complete original try body matches after the enumerated migration replacements plus exclusive-admission/cached-FME additions. Wrapper `exec(compile(BODY,...))` preserves embedded source text. Deltas remain fresh root/boot, exact pre63/bind66 pins, current EMIF `.4`, strong observer, exclusive admission, current cached FME, prior walking90 and batch transport. UNKNOWN owner/namespace/buffer-retention semantics remain unchanged.
- Fresh checks pass for boot **`3e2d2060-d6c0-44b5-a269-1adf1e450041`**, cached StaticFME **`fc603c44-5c8f-5e94-bcbe-a5780030947c`**, runtime/loaded-module/config bindings, exact VF **`0000:4f:00.2` / singleton group76 / literal `flr\n`**, and both named **`inf0_init_done=1` / `inf1_init_done=1`** at driver-bound `dfl_dev.4` before frontend start. Pre63/bind66 retained results match their exact admission pins. Actual loader init/control-transfer accounts for **10 bound ELF objects / 19 dependency edges**, without missing closure members. Empty CWD/absent-plugin checks, only VFIO76/vfio exposure and checked RO `/work`, `/bulk`, `/exec`, `/empty`, `/sys` mount targets remain intact; not every sysfs submount is claimed RO.

The unsuppressed kernel interval contains exactly one concern:

> 2026-10-03T19:21:36-0700 Agilex7Workstation kernel: vfio-pci 0000:4f:00.2: timed out waiting for pending transaction; performing function level reset anyway

Preserve **`lifecycle_clean=false` / `lifecycle_accepted=true`** under the already accepted exact pending-before-FLR erratum; no other concern/fault appears. Before/after root-visible observers show empty holders/maps/D-state/errors, inactive SDK service, unchanged boot/PCI route and only this batch's transport processes. These are finite observations, **not global transaction drain, reset/clock waveforms, MTBF or electrical proof**.

**Only the actual bulk concurrent-bank functional gate passes here.** No full-capacity/all-physical-row or physical-equivalence claim, measured wire overlap, sustained concurrent bandwidth, new benchmark/reset/timing/electrical gate, `hardware_ready`, further-operation authority or task closure follows. Accepted predecessors retain their own scopes and limits; parent acceptance/goal-state closure remains separate.

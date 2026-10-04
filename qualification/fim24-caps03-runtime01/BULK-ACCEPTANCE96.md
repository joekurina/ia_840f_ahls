# Migrated CAPS03 bulk concurrent-bank functional gate — accepted with limits

**Independent FINAL PASS WITH LIMITS; no primary technical blockers** within the actual finite **bulk92 source-supported concurrent-bank functional gate**. This closes the final named hardware gate; the parent campaign aggregate/handoff is separate. [Review95](bulk-result-review95.md), [parent acceptance96](BULK-ACCEPTANCE96.json).

## Actual result, data and completion

Application/container/outer exits are **0/0/0**, `EXITED`, no retained owner. The complete **411-line /27,257-byte** transcript reconciles three identity notices,four capability notices,one quiescent-history notice,66 sampled submissions,66 sampled retirements,268 tile rows,one HLS completion,one PASS footer and the limitation banner. No missing/extra/failure/hold record occurs. [Native log](bulk92/readback/native.log), [raw result](bulk92/readback/result.json), [parent93](bulk-parent93.json).

| Region | Mode / bank | DDR base | Bytes | Descriptors / tiles |
|---|---|---|---:|---:|
| X preload | 1 / 0 | `0x10000` | 262144 | 2048 / 67 |
| Y preload | 1 / 0 | `0x60000` | 262144 | 2048 / 67 |
| Z poison + guards | 1 / 1 | `0xffc0` | 262272 | 2114 / 67 |
| Z copyback + guards | 2 / 1 | `0xffc0` | 262272 | 2114 / 67 |

**8,324 descriptors /268 tiles** are source-validated; exposed submit/retire rows are sequence%128==0, not8,324 individual log rows. Every descriptor checks arguments/readback, fresh finite completion, quiescence and both complete4096-byte host pages before reuse. All **65,536 integers /262,144 output bytes**, expected `Z=3*i+1` from `X=i`,`Y=2*i+1`, and both64-byte DDR guards are actively compared. Poison is complementary to expected output. This is source-bound in-process actual-data verification, not an exported hardware vector or separate out-of-process payload comparison. [Frontend](../../src/host/ahls_memory_caps03_bulk.c), [review reconstruction](bulk-result-review95.md#whole-transcript-data-and-completion).

Exactly one HLS invocation reaches **ticket1/completion`0x10002`** after the preloads and before copyback. Final guard0/completion/quiescence/sequence8324 accounting precedes uncertainty clearance and successful normal cleanup. The retained UNKNOWN owner/namespace/buffer policy is unchanged and was not entered.

Accepted source/compiler/vendor semantics support two buffered bank0 load LSUs feeding eight adders and a bank1 store LSU. This real finite invocation closes **source-supported concurrent-bank functionality**, not measured DDR-wire overlap, sustained concurrent bandwidth or full-capacity coverage; host DMA phases themselves are serial. Keep `source_supported_concurrent_workload=true` and `wire_level_overlap_measured=false` literal. [Scope analysis](bulk-result-review95.md#whole-transcript-data-and-completion).

## Finite provenance and lifecycle

Accepted walking89/90,DDR83/84,coverage77/78,numerical71/72,normal-entry58/62 and deployment56/60 are reused. Original C/BIND/INNER/NEW/supervisor/ELFs remain identical. Fresh exclusive root/boot/pre63/bind66/current EMIF`.4`/strong observer/admission/cachedFME/prior-walking bindings are exact; accepted90 hash checks precede leaf creation. Current modules/runtime/config/loader/RO mount targets,exactVF`0000:4f:00.2`/group76/literal`flr\n`,both named init values1 and ownership checks passed before frontend loading. Ten actual ELF objects/19 dependency edges reconcile. [Admission91](BULK-ADMISSION91.json), [binding](bulk92/readback/binding.json), [loader](bulk92/readback/loader.16).

Boot remained **`3e2d2060-d6c0-44b5-a269-1adf1e450041`**, cached static FME **`fc603c44-5c8f-5e94-bcbe-a5780030947c`**. Root-visible holders/maps/D/errors are empty. The sole unsuppressed kernel concern is:

```text
vfio-pci 0000:4f:00.2: timed out waiting for pending transaction; performing function level reset anyway
```

Preserve **lifecycle_clean=false /lifecycle_accepted=true** under the existing exact warning policy. Different faults remain failures; this does not establish global transaction drain, waveform/MTBF/electrical or universal reset proof. [Kernel interval](bulk92/readback/kernel-journal.log), [user policy](../caps03-runtime01/ERRATUM-ACCEPTED25.md).

Review/parent verified **24/24 frozen members**, **16/16 exports** and exact original result/log consistency. Accepted96 bytes were read back identically on the workstation. [Freeze94](bulk-freeze94.json), [acceptance readback](acceptance96-readback/index.json).

No hardware_ready,full-capacity/all-physical-row,wire-overlap,performance or new timing/electrical qualification is claimed. Prior scopes/limitations remain. Encoded archives/source-payload launchers/images/proprietary bodies remain local with size/SHA references; publication metadata is not replacement executable authority. `main` remains untouched fallback; no further hardware operation is required by this completed gate.

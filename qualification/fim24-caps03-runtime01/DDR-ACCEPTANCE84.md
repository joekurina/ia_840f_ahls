# Migrated CAPS03 DDR trio — accepted with limits

**Independent FINAL PASS WITH LIMITS; no primary technical blockers** for the actual **DDR80 independent-bank / serial isolation / sustained trio**. This closes that agreed gate, not walking-bit, concurrent-bank bulk or the overall migration. [Review83](ddr-result-review83.md), [parent acceptance84](DDR-ACCEPTANCE84.json).

## Actual data and duration

Application/container/outer exits are **0/0/0**, `EXITED`, no retained owner. The complete native transcript matches **64 progress rows, four ordered phases, one elapsed row and one exact footer**, without missing/extra/failure/hold records. [Original native log](ddr80/readback/native.log), [raw result](ddr80/readback/result.json), [parent81](ddr-parent81.json).

| Phase | Mode / bank | Transferred bytes | Cumulative descriptors |
|---|---|---:|---:|
| W0 | 1 / 0 | 2,147,483,648 | 16,777,216 |
| W1 | 1 / 1 | 2,147,483,648 | 33,554,432 |
| R0 | 2 / 0 | 2,147,483,648 | 50,331,648 |
| R1 | 2 / 1 | 2,147,483,648 | 67,108,864 |

Both banks completed their own address-and-bank-dependent roundtrips. All W0/W1 writes preceded either read, establishing **serial isolation at the exercised locations**. Each unchanged C-loop descriptor checks payload/source preservation and both complete4096-byte host pages/guards before reuse. This accepts source-bound in-process hardware data comparison, not separately exported DDR vectors. [Source](../../src/host/ahls_memory_caps03_ddr.c), [review data analysis](ddr-result-review83.md#actual-data-phases-and-duration).

Total **67,108,864 descriptors / 8,589,934,592 traffic bytes**. Each bank has16,777,216 sampled locations:128 bytes per1-KiB block, distributed across a16-GiB logical aperture, **2 GiB written and2 GiB read per bank**. This is one-eighth byte coverage, not full-byte/all-capacity or physical-row mapping. No sixth/full-capacity test is added.

Actual monotonic checked-transfer-loop time is **`594.000209015` seconds**. Both inner `sustained_duration_pass=true` and outer `trio_sustained_accepted=true` hold; **180≤elapsed<3600** is explicitly part of the new outer acceptance, fixing the legacy omission without changing frontend/inner code. This is sustained correctness testing, **not wire bandwidth or simultaneous channels**. The original no-kernel/no-simultaneous limitation banner remains unchanged.

## Finite runtime and lifecycle provenance

Accepted numerical/normal-entry71/72 and coverage77/78 were reused. Original C/BIND/INNER/NEW/supervisor/ELFs are identical; deltas are fresh exclusive run/boot/pre63/bind66/current EMIF`.4`/strong observer/admission/cachedFME/prior-coverage bindings plus the explicit agreed duration condition. The historical command label `caps03-34-repeat-boundary-cases` remains a labeling defect; actual DDR module argv/hash/records define the workload. [Admission79](DDR-ADMISSION79.json), [bound delta](ddr80-bound-delta.json), [binding](ddr80/readback/binding.json).

Fresh DDR80 checked both named EMIF initialization values1, current module/runtime/config/loader closure, exact VF`0000:4f:00.2`/singleton group76/literal`flr\n`, empty CWD/plugin prefixes and checked RO mount targets before frontend loading. Actual loader reconciles ten ELF objects. Boot remained **`3e2d2060-d6c0-44b5-a269-1adf1e450041`**, cached static FME **`fc603c44-5c8f-5e94-bcbe-a5780030947c`**. Root-visible before/after holders/maps/D/errors are empty; UNKNOWN retention was not entered. [Loader](ddr80/readback/loader.16), [original result](ddr80/readback/result.json).

The sole unsuppressed kernel concern is the exact accepted warning:

```text
vfio-pci 0000:4f:00.2: timed out waiting for pending transaction; performing function level reset anyway
```

Preserve **lifecycle_clean=false / lifecycle_accepted=true**. Different messages/faults stay failures. This does not establish warning-free cleanup, globally drained transactions, waveform/MTBF/electrical or universal reset safety. [Kernel interval](ddr80/readback/kernel-journal.log), [existing user policy](../caps03-runtime01/ERRATUM-ACCEPTED25.md).

Review and parent verified **26/26 frozen members**, **16/16 exports** and exact original receipt/log consistency. Original collector `proc_5c751de8930b` exited0 and is consumed/historical, never a new waiter or relaunch target. Parent accepted84 bytes were read back identically on the workstation. [Freeze82](ddr-freeze82.json), [acceptance readback](acceptance84-readback/index.json).

Walking-bit and bulk concurrent-bank remain separate gates. Existing STA/CDC/reset/electrical/DRC limitations are retained; hardware_ready/all-DDR/full-byte qualification is not claimed. Encoded raw archives, source-payload transfer launchers, images and proprietary bodies remain local with exact size/SHA references; metadata is not executable replacement authority. `main` remains untouched fallback.

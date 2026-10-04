# Migrated CAPS03 34-case coverage — accepted with limits

**Independent FINAL PASS WITH LIMITS; no primary technical blockers.** This closes the actual migrated-image **coverage74 boundary/repeat gate only**. It does not close DDR independent/isolation/sustained, walking-bit, bulk concurrent-bank or the overall migration. [Review77](coverage-result-review77.md), [parent acceptance78](COVERAGE-ACCEPTANCE78.json).

## Actual result and data

Original application/container/outer exits are **0/0/0**, `EXITED`, no retained owner. Both layouts exercised lengths **1,8,9,16,17,31,32,33,63,64,65,127,128,129,255,256,257**, exactly34 cases. The complete reconstructed transcript matches **1,116 lines**, including **34 cases,536 submissions,536 retirements and one exact footer**:1,107 scoreboard records, no missing/extra/failure/hold row. [Original native log](coverage74/readback/native.log), [raw result](coverage74/readback/result.json).

Totals are **2,982 signed integers**, **11,928 result bytes**, **5,224 guard bytes** and **536 descriptors**. The unchanged bound frontend checked little-endian signed addition, complete guarded spans, both4096-byte host pages after every descriptor, fresh HLS ticket1/completion`0x10002`, guard0 and quiescence before each case pass. This accepts source-bound in-process hardware comparisons, not a separately dumped result vector. [Parent reduction75](coverage-parent75.json), [source](../../src/host/ahls_memory_caps03_coverage.c).

## Finite provenance and lifecycle

Accepted numerical/normal-entry71/72 and deployment are reused, not re-audited or replayed. Original C/BIND/INNER/NEW/retention supervisor are unchanged; only fresh exclusive roots/boot/receipt/current feature/observer/admission/cached identity bindings differ. Accepted72 hash was consumed before new coverage74 leaf creation. Both named current EMIF initialization reads were1 before frontend loading. Exact VF`0000:4f:00.2`/singleton group76/literal`flr\n`, current loaded modules/runtime/config/RO mounts and ten actual loader ELF objects remain bound. [Admission73](COVERAGE-ADMISSION73.json), [binding](coverage74/readback/binding.json), [loader](coverage74/readback/loader.16).

Boot remains **`3e2d2060-d6c0-44b5-a269-1adf1e450041`**, cached static FME **`fc603c44-5c8f-5e94-bcbe-a5780030947c`**. Root-visible before/after holders/maps/D/errors are empty, management service inactive. The sole kernel concern is the exact already accepted warning:

```text
vfio-pci 0000:4f:00.2: timed out waiting for pending transaction; performing function level reset anyway
```

Preserve unsuppressed **lifecycle_clean=false / lifecycle_accepted=true**. This is not a warning-free result, globally drained transactions or measured reset/clock waveform. Different concerns remain failures. [Kernel interval](coverage74/readback/kernel-journal.log), [user policy](../caps03-runtime01/ERRATUM-ACCEPTED25.md).

Review and parent verified **24/24 frozen members** and **16/16 original exports**. Parent acceptance78 was materialized and read back byte-identically on the workstation before the next operation. [Freeze76](coverage-freeze76.json), [acceptance readback](acceptance78-readback/index.json).

The scoped UNKNOWN retention policy remains; no uncertain state occurred. No flash/reboot/reset/rebind replay, warning suppression, hardware_ready, MTBF, electrical/DRC signoff, universal reset safety or physical-equivalence claim is added. Existing limitations stay disclosed. Three remaining hardware gates need their own actual results and independent acceptance; DDR trio retains its separate sustained-duration requirement. Images/encoded raw archives/generated source-payload launchers remain local, SHA-referenced. Publication metadata is not executable replacement authority; `main` remains untouched fallback.

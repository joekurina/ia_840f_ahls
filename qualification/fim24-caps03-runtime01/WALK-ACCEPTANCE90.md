# Migrated CAPS03 logical walking-bit/address gate — accepted with limits

**Independent FINAL PASS WITH LIMITS; no primary technical blockers** in the actual finite **walk86 logical address scope**. This closes walking-bit only; bulk concurrent-bank and final campaign closure remain separate. [Review89](walk-result-review89.md), [parent acceptance90](WALK-ACCEPTANCE90.json).

## Actual result and checked data

Application/container/outer exits are **0/0/0**, `EXITED`, no retained owner. The **549-line transcript** reconciles seven identity/capability notices,120 submissions,120 retirements,120 segment-page records,120 burst-page records,60 bank-data records,one exact PASS footer and the limitation banner. No missing/extra/failure/hold record occurs. [Native log](walk86/readback/native.log), [original result](walk86/readback/result.json), [parent87](walk-parent87.json).

Exactly **30 locations per bank**: `[0] + [1<<bit for bit in range(6,34)] + [(1<<34)-64]`. Four serial W0/W1/R0/R1 phases give **120 page-contained64-byte descriptors**, **1,920 copied-back bytes per bank** and **7,680 traffic bytes**. All writes precede every read. Retirement counters advance exactly one modulo16; both complete4096-byte host pages/source preservation/destination guards and every returned payload byte are checked before reuse. The unchanged address-and-bank-dependent uint64 pattern yields60 distinct location/bank payloads. This is source-bound in-process hardware comparison, not a separate DDR vector dump. [Source](../../src/host/ahls_memory_caps03_walk.c), [review data reconstruction](walk-result-review89.md#records-and-source-bound-data-checks).

Known logical pairs **0x80/0x400**, **0x100/0x800**, **0x200/0x1000** are separately exercised with distinct expectations in both banks. This tests serial alias/isolation behavior at selected logical locations; it does **not** establish physical-address equivalence, all-row/all-byte coverage, concurrent traffic or bandwidth.

## Finite fresh provenance and lifecycle

Accepted DDR83/84,numerical71/72,coverage77/78 and normal-entry58/62 are reused. Original C/BIND/INNER/NEW/supervisor/ELFs remain identical; only fresh exclusive root/boot/pre63/bind66/current EMIF`.4`/strong observer/admission/cachedFME/prior-DDR bindings differ. Accepted84 bytes were hash-checked before fresh leaf creation; walking admission85 matches the run. No setup/flash/rebuild/reset-corpus replay. [Admission85](WALK-ADMISSION85.json), [binding](walk86/readback/binding.json).

Fresh checks passed for both named EMIF initialization values1, current loaded modules/runtime/config/loader closure, exact VF`0000:4f:00.2`/singleton group76/literal`flr\n`, empty CWD/plugin prefixes and checked read-only mount targets. Ten ELF objects reconcile to actual loader initialization/control transfer. Boot remained **`3e2d2060-d6c0-44b5-a269-1adf1e450041`**, static cached FME **`fc603c44-5c8f-5e94-bcbe-a5780030947c`**, root-visible holders/maps/D/errors empty; UNKNOWN retention was not entered. [Loader](walk86/readback/loader.16), [original result](walk86/readback/result.json).

Only the exact existing unsuppressed VF warning occurred:

```text
vfio-pci 0000:4f:00.2: timed out waiting for pending transaction; performing function level reset anyway
```

Preserve **lifecycle_clean=false / lifecycle_accepted=true**. No other concern appears; different faults remain failures. These are finite software observations, not globally drained transactions, clean reset/clock waveforms, MTBF/electrical or universal reset proof. [Kernel interval](walk86/readback/kernel-journal.log), [user policy](../caps03-runtime01/ERRATUM-ACCEPTED25.md).

Independent review/parent verified **24/24 frozen members**, **16/16 exports** and exact original log/result consistency. Parent accepted90 bytes were read back identically on the workstation before the next operation. [Freeze88](walk-freeze88.json), [acceptance readback](acceptance90-readback/index.json).

No hardware_ready,full-DDR,universal physical-equivalence or timing/CDC/electrical signoff is added. Existing findings remain; final bulk gate needs independent actual-result acceptance. Encoded archives/generated source-payload launchers/images/proprietary captures remain local with size/SHA references; metadata is not replacement executable authority. `main` remains untouched fallback.

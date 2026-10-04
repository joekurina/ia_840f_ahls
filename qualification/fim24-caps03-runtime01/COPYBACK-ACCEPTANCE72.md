# Migrated CAPS03 numerical copyback — accepted with limits

**Independent FINAL PASS WITH LIMITS; primary technical blockers none.** This closes the actual finite migrated-image **copyback68 numerical gate**, not all-DDR qualification, hardware readiness or the migration goal. [Review71](copyback-result-review71.md), [parent acceptance72](COPYBACK-ACCEPTANCE72.json).

## Actual result

Original application/container/outer exits are **0/0/0**. The retained FPGA Test verified **9 signed integers**, **36 result bytes**, **156 guard/padding bytes**, **192 copied-span bytes** and **6 descriptors**, HLS ticket1/completion`0x10002`. All six submissions/retirements and complete host-page checks occur in order, with exactly one numerical/footer pass and no failure/hold marker. The bound frontend compares `[-3,0,-5,-5,5,7,9,-16,-7]` and guards in process; this is not a separately exported hardware result vector or a second out-of-process decryption/comparison. [Native log](copyback68/readback/native.log), [original result](copyback68/readback/result.json), [parent reduction69](copyback-parent69.json).

Application state is `EXITED`, retained_owner=false; root-visible before/after holders/maps/D/errors are empty and boot remains **`3e2d2060-d6c0-44b5-a269-1adf1e450041`**. Cached migrated static FME **`fc603c44-5c8f-5e94-bcbe-a5780030947c`** matches accepted deployment. Raw `lifecycle_clean=false` is retained; `lifecycle_accepted=true` accepts only the exact existing warning:

```text
vfio-pci 0000:4f:00.2: timed out waiting for pending transaction; performing function level reset anyway
```

No other kernel concern appears. This is not warning-free cleanup or proof of globally zero pending traffic. The historical live21 false/outer1 receipt is unchanged. [Kernel interval](copyback68/readback/kernel-journal.log), [existing user policy](../caps03-runtime01/ERRATUM-ACCEPTED25.md).

## Finite fresh provenance

- Accepted deployment56/60 and normal-idle reset review58/consumption62 are reused. Current19sys/12bank0 source route includes the PR slot; fitted additional3sys/7bank0 cycles fit within the existing source-supported normal-idle sequence using exact clock ratios. No new reset/clock waveform, stopped-clock/cold/PR/active-fault or MTBF claim. [Reset review58](../fim24-caps03-flash01/migrated-normal-entry-review58.md), [consumption62](../fim24-caps03-flash01/NORMAL-ENTRY-CONSUMED62.json).
- Fresh pre63 verified ordinary files, SIF/runtime/config, eight loaded-module notes/files, cached FME/topology/empty ownership. Current EMIF is PF0-descendant driver-bound type0/id9 **`dfl_dev.4`**, not historical `.5`. File-only container64 verified ELF/search/mount/config closure; both named initialization reads returned1 before VF creation. No mismatched cal-fail accessor or generic bridge state was used as readiness. [Pre63](preflight63/readback/result.json), [runtime/init64](runtime-init64/readback/result.json).
- One create65/native0 made only PF0's VF with autoprobe disabled and verified it unbound. One bind66/native0 selected exactVF`0000:4f:00.2`/singletongroup76/vfio-pci,0660uid/gid1000,restored per-PF autoprobe1 and literal `flr\n`; PF0 DFL/PF1 management retained. [Creation65](create65/readback/result.json), [binding66](bind66/readback/result.json).
- Fresh exclusive admission67 and copyback68 rechecked current initialization, runtime/loader/RO mounts, exact VF/group/FLR and ownership. Retained frontend/launcher ELF,C/BIND/INNER/NEW and retention supervisor are unchanged. UNKNOWN still retains application/container/buffers without reset/kill/retry/release; no such state occurred. [Admission67](ADMISSION67.json), [binding](copyback68/readback/binding.json), [actual loader](copyback68/readback/loader.16).

Independent review verified **38/38 frozen members**, **16/16 original exports**,11 host-source files, and consumed62's14source/23record bindings. Parent verified exact review/freeze and read back identical accepted72 bytes remotely. [Freeze70](copyback-freeze70.json), [acceptance readback](acceptance72-readback/index.json).

Remaining gates are34-case boundary/repeat,DDR independent/isolation/sustained trio,walking-bit and bulk concurrent-bank. This acceptance neither substitutes for them nor adds a performance/full-capacity sixth gate. Existing STA/CDC/electrical/DRC/reset findings remain disclosed. Raw encoded archives, payload-bearing generated launchers, images and proprietary captures stay local with exact size/SHA references; publication metadata is not replacement executable authority. `main` remains unchanged fallback.

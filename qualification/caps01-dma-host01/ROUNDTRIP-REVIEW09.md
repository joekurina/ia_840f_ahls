# ROUNDTRIP-REVIEW09 — independent completed-result review

## Verdict: ACCEPT WITH BOUNDED LIMITS

**Accept both completed real OPAE/VFIO 64-byte logical-bank roundtrips. No concrete blocker to accepting these two samples was found.** Each invocation has independently reconciled **native/container/outer = 0/0/0**, exactly one H2D followed by one D2H submission, successful active payload and whole-host-page checks, and clean recorded postflight. This does not qualify the complete DDR subsystem or numerical AHLS.

Review scope: local, read-only inspection and Python parsing/hash verification of retained evidence and narrowly relevant source; only this report was written. No remote connection, device operation, build, test executable, git operation, source change, or publication occurred. FRONTEND-REVIEW04's source/contract acceptance is reused; the prior mapping, SDK and FLR audits were not reopened. Runtime observations below describe the captured runs, not a new live-host inspection.

Paths below are relative to `G=/home/joe/Projects/Thesis/AHLS/new_bsp/new/qualification/caps01-dma-host01`; host sources are under `../../src/host/`.

## 1. Completed invocations and data acceptance

| Evidence | bank0-07 | bank1-08 |
|---|---|---|
| Selected logical bank | 0 | 1 |
| Native / container / separate outer receipt | 0 / 0 / 0 | 0 / 0 / 0 |
| Native process state | EXITED; no retained owner | EXITED; no retained owner |
| H2D / D2H submissions | Exactly 1 / 1 | Exactly 1 / 1 |
| Payload per direction | 64 bytes | 64 bytes |
| Bank-local DDR byte offset | `0x10000` | `0x10000` |
| Aggregate DDR byte address | `0x10000` | `0x400010000` |
| Returned source / destination IOVA base | `0` / `0x1000` | `0` / `0x1000` |
| Actual host payload IOVA | `0x40` / `0x1040` | `0x40` / `0x1040` |
| Retired status, mode 1 / mode 2 | `000000011041000a` / `000000022041000a` | Same |
| Retired counter, mode 1 / mode 2 | 1 / 2 | 1 / 2 |
| Polls per descriptor | 2 / 2 | 2 / 2 |
| Source / destination page check | 4096 / 4096 bytes | 4096 / 4096 bytes |

The two separate native logs match their receipt-embedded bytes and SHA256 values exactly. Each separate outer receipt binds the matching complete result hash and records literal `raw="0"`, `outer_rc=0`. Native exit agrees at the process, inner and outer-result levels; the actual Apptainer command exit is also zero. Parsed cardinality is **2 invocations, 4 submissions, 4 retirements**. `roundtrip-summary09.json` agrees with the raw receipts, logs, decoded status fields, loader selections and verification extents. Bank1's receipt binds the exact completed bank0 predecessor.

This is not acceptance from a pass banner alone. The build-bound `ahls_memory_dma_roundtrip.c:130–185` allocates two separate flags-zero 4096-byte buffers, initializes both pages, constructs bank/address-dependent data, and poisons every destination payload byte with its complement. Its two-iteration loop calls the transfer core once per direction; the core (`ia840f_dma_transfer_core.c:62–96`) writes/readbacks the three descriptor arguments and performs one GO write, with no retry. GO words are `0x84000000` then `0x88000000`; length is one 64-byte beat. The second operation follows the first successful local retirement.

Source and successful exit jointly establish the active checks: volatile reads must match all 64 returned payload bytes, then all 4096 bytes of each host page must match expected payload/guards. Mismatch enters the non-returning hold, not a pass path. The final pass marker follows normal buffer/API cleanup; startup returns zero only if entry and explicit finalization succeed. The log does not separately dump buffer contents or every MMIO transaction; these claims are tied to the verified native source/build, not an independent bus trace or second out-of-process data comparison.

Decoded final statuses satisfy the bound idle/FIFO/error predicates and counters. Freshness relative to each pre-GO baseline is enforced by the core; baseline values and intermediate poll values are not logged. **Two polls do not prove an observed busy transition.** IOVA zero is a returned DMA address, not a null CPU pointer. These first 64-byte samples are at bank-local `0x10000`, not DDR address zero; that address is not a kernel-MMIO write.

## 2. Native build and actual runtime binding

- Recomputed the local-only `dma-build03-result.json` hash and verified every one of its **14 encoded captures** against recorded byte length/SHA256, including both ELF payloads, without writing or executing those payloads. The **13 source/CMake bindings** match the current local files and `build03-inputs.json`; the build inner-script hash matches that manifest, which enumerates 64 SDK pins.
- Captured native configure/build commands and container command exit zero. The verbose native compile/link records include the real frontend, transfer core, production lifetime helper and strict entry, not `mock_dma_opae.c`. The launcher uses the previously reviewed parser/libc support; the SDK `tests/framework/mock/opae_std.c` path is not evidence of a mock OPAE hardware backend. Build-time application execution, OPAE loading and hardware access are recorded false.
- Native ELF metadata binds launcher `b34b3d9026e87a248ef24fdfbf2cd5c7e2add9cca0ecbe956966746d9334fb1f` (36792 bytes) and entry `507ad139e3f3c24a48e34f1b8ff72c2e32a345f7f9b10529e6e6f2ad906dd829` (35352 bytes). Launcher NEEDED is json-c/libc, not OPAE; entry NEEDED is libopae-c/libc. The live runners verify these exact bytes, execute a separately permissioned launcher copy and leave the original mode-0600 artifact unchanged.
- **Actual loader evidence**, not merely search-path prediction: both complete `LD_DEBUG=libs` logs hash to `79d7edcd06ef103e7d2d2193fa674bca514547d0902a0b4e588b462b8f64c6e1` (8747 bytes). They transfer control to `/exec/ahls_memory_dma_vfio_startup`, then record `calling init` for `/dma/build/libahls_memory_dma_entry_vfio_strict.so`, `/work/sdk-build/lib/libopae-c.so.2`, `libopae-v.so`, `libopaevfio.so.2`, `libopaemem.so.2`, and the bound json-c/uuid/libc/loader dependencies. No xfpga, UIO or ASE library is initialized in these logs. Normal fini records are present.
- Both runtime inner scripts verify the dependency-object hashes/resolved paths and configuration; selected mounts and empty CWD are read-only, and the VFIO namespace contains only `76` and `vfio`. Existing SDK trailing-empty RUNPATH entries are constrained by that empty read-only CWD, not silently removed. Embedded inner scripts, binding dictionaries and production supervisor bytes in both launchers match their retained standalone copies.

Build03's outer-zero claim is inherited from the supplied completed-build context/RESULT04; this gate contains no separate build03 outer-receipt file. The build's native/container statuses and artifact chain were checked directly. **Both live roundtrips do have separate outer receipts and independently verified 0/0/0 triples.** No repeated build or hardware run is needed to establish these sample results.

## 3. Preservation and postflight

Both receipts retain boot `598f7b27-1798-4a88-8a79-9e4a2659c64d` before/after, matching preflight06 and each other. Recorded postflight drivers match preflight: PF0 `0000:4f:00.0` is `dfl-pci`; management PF1 and AFU VF (`0000:4f:00.1`, `.2`) are `vfio-pci`.

The runner predicates actually rehash the **nine selected original runtime/configuration files plus both new build artifacts** before/after. `original_files_unchanged=true` therefore has a concrete bounded preservation set; it is not a whole-filesystem claim. Module-file hashes/loaded build-ID notes and SIF/runtime hashes are checked before launch; postflight checks driver bindings, not a second complete module/SIF hash inventory.

All four pre/post ownership command outputs hash correctly and parse to exactly `{"d_state": [], "relevant": [], "holders": []}`. The scanner's source hash matches the runner's pinned `75982c77a2a751c8e8241c3a8bed407125f02700b59f8ea53c0a31c562d7629f`. It scans `/proc` process states and FD targets for VFIO/DFL/FPGA/devmem, plus selected programming-process names. These are successful privileged **snapshots**, with process-race/permission exceptions skipped; they are not continuous exclusion, an all-thread D-state census, or proof of every possible kernel/device reference. There is no recorded lingering owner or D-state process in their observed scope.

The receipts and inspected live runner contain no explicit reset, rebind, retry, reflash or reboot. Ordinary implicit VFIO reset/open/close behavior remains part of these invocations; this is not a reset-free experiment or fresh reset certification.

## 4. Container ownership retention: tested behavior and limits

The exact production `runtime-supervisor05.py` hash is bound in the device-free fixture and both live inner scripts. The fixture uses the same SIF, Apptainer wrapper and runtime hashes as the live launchers. Its source enforces no accelerator devices/sysfs exposure. All **four** recorded cases reconcile:

- **Clean:** child native0, successful EXITED record.
- **Production-helper hold:** the original regular-file/RAM owner remains stopped (`T`) with its file FD; namespace `appinit` and supervisor remain alive after the separate observer exits.
- **Deadline:** the sleeping owner/FD, supervisor and init survive normal observer exit; no child termination is used as timeout handling.
- **Post-spawn save error:** the injected save exception leaves no state JSON, but both fallback log markers and retained-process/FD observations establish retention. It is not a fabricated successful receipt write.

For all three retained cases, both recorded membership snapshots preserve the same PID/start-tick/namespace identities and owner FD. The second snapshot follows a short 0.1-second observation gap: this proves the exercised behavior, not indefinite endurance. Only those known **device-free fixture namespaces** were subsequently killed; their final membership lists are empty. The kill code is in `supervisor05.py`'s fixture controller, not the production module or live runners.

Source inspection (`runtime-supervisor05.py:19–52`) confirms ordinary signals are blocked before spawn; post-spawn metadata/save/poll errors, hold marker, log overflow or deadline enter a save-best-effort non-returning retention loop. The outer live runner uses a new session and does not signal/kill on its observation deadline. The log-overflow path is source-inspected, not a fifth exercised fixture case. The real hardware runs took the clean path, not a forced hardware-uncertainty hold.

**Remaining failure limits:** the fixture tests normal observer exit, not arbitrary observer/runtime/namespace-init destruction or all session-manager behavior. Its observer also masks ordinary signals; do not promote that to general signal-resistance of the live container init. SIGKILL, fatal child faults, OOM, runtime/init death and host loss remain outside containment. An already exited child (including nonzero exit) is reported EXITED and allowed to return; the supervisor cannot preserve mappings already destroyed by that exit. Retention does not stop FPGA DMA, establish physical quiescence, repair a wedged MMIO instruction, or authorize resource reclamation/recovery. The 45-second inner/60-second outer deadlines are observation bounds, not cancellation or no-hang guarantees.

## 5. Claim and publication boundaries

**Sequential write/read samples do NOT prove physical bank isolation.** Both can pass if the logical banks alias, because bank0 is read before bank1 overwrites the aliased location. Bank-dependent data does not fix that test-order limitation. Cross-bank retention, simultaneous traffic, large/high bank-local address coverage, boundaries, sustained DDR/refresh/thermal behavior, and numerical AHLS/kernel execution remain untested. Selecting the aggregate bank1 address does not establish large bank-local coverage. No latency/throughput claim follows from supervised run timestamps or poll counts.

The prior source review's duplicate-successful-WSID cleanup defect remains a nonblocking, unexercised malformed-allocator-output limitation; these successes do not repair or qualify it. Deterministic patterns are not per-invocation nonces. This review does not newly certify general cache coherence, absence of later stray writes, whole-system drain, controller/pin/calibration association, or all DDR timing/qualification items. It adds no new gate to acceptance of these two samples.

Publication screen covered 23 explicit compact candidates: ROUNDTRIP-RESULT09, roundtrip-summary09, FRONTEND-REVIEW04, review-consumed05, RESULT04, both bank plans/results/native logs/outer receipts/runner scripts/inner scripts, runtime-supervisor05, supervisor05-result, supervisor-fixture05-inner, bank0-07-binding, build03-inputs and dma-preflight06-result. Content inspection plus text scans found no embedded ELF payload, long encoded binary, private key or apparent credential value in that set. It does include host/account paths, boot/PID/PCI/IOVA and build metadata; those are disclosure metadata, not credentials. This is a bounded payload/secret screen, not a blanket licensing or repository-release audit.

**Keep `dma-build03-result.json` LOCAL ONLY:** its JSON embeds two complete base64 ELF files despite its modest size. Keep raw native/inert executables, vendor `bound-rtl/` and retained vendor/SDK source bodies local; a small-file cutoff or whole-directory publication is unsafe. Publish compact reports, source references and hashes only, or separately selected reviewed text evidence. No publication was performed here. Historical RESULT04/review-consumed05 describe pre-run state; ROUNDTRIP-RESULT09's pending-review statement is superseded by this report, not a reason to rewrite frozen evidence.

## SHA256 evidence ledger

All values below were recomputed locally; the build receipt is referenced by hash only and is not a publishable payload.

```text
7128ec0fda39452dab83cfe255f998719f057d3356a185c8803750f2ed89da83  ROUNDTRIP-RESULT09.md
240642682d947d1282aec5dc562b0b1014353e61fea31ac930c24ea0c6e718e7  roundtrip-summary09.json
f716fe4ff1dbe3ae83be4df0076770c86c1432a7ff4a58a926bbae782ad98c24  FRONTEND-REVIEW04.md
1d87c64a465f6f54b09d156aabca9efdd1edcefbac6895e0735641ebac8d6839  bank0-07-result.json
ce54fedf593dd942ce8185177f19586227a661d41bd09b5d70a2a940089074e4  bank1-08-result.json
a5aa74f69723eaa0d0f41db1d85f74487a0ce681af79a4921ae8aab80bf46fbe  bank0-07-native.log
b0e288e12447249b0de19727079d48354f44ac8e4b222f003cb3b643492eba42  bank1-08-native.log
c4f2644e6df1e717b5aff9a35125e21e77549323005ec360f7d8acd7bed67070  bank0-07-outer-result.json
35972c156c3ada49297addc553a48a2c50f4a0b4832830900f2c86e55642dfe0  bank1-08-outer-result.json
483dea60dd7f386dd67b391779730b6033f30d18d4ac4a2233acebb16779bbea  dma-build03-result.json [LOCAL ONLY]
f6da790aa89ae5db0092a3ab649654fe81499f33a78fcc043b7cbd6343264c52  bank0-07-binding.json
f707c78aff97e29eea1a42dca301532af3fc312b89c9f36b7e2746d7244fbc20  dma-preflight06-result.json
12e0016b32cbf4e9a0a1c084bdb342fe2c668bd1d8053f3e418c9bfc6ceefa33  runtime-supervisor05.py
ec48870ff8943c29d4f2151d321f323477c887912e66f00d46f2b6cdd53d7fbe  supervisor05-result.json
48c7a80f21f3e8069ff609d2406e7c7e3f7c1ba97f782a0efc5291e61e71c7da  bank0-07.py
5f0975283ee714c7dc5aac65b8a6cf1bba798734adf91da5e896b00edfd36e2e  bank1-08.py
```

**Disposition:** accepted as two tiny, separately completed logical-bank data-path samples, with no concrete blocker in that scope. Broader hardware claims and unrestricted publication remain outside this acceptance.

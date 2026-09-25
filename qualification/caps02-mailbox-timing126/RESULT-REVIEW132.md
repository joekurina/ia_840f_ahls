# RESULT-REVIEW132 — independent local functional-result and test-quality review

## Verdict

**PASS, bounded to the retained run127 local RTL functional evidence. No blocking functional-result or test-quality defect found; no implementation correction requested.** Five positive runs report **51 cases and 1522 executed checks**, and three labeled synthetic RTL mutants compile successfully and fail at their intended live assertions. Manifest identities, logs, metrics, cancellation accounting and compiled-artifact hashes reconcile.

This accepts the completed local results, not physical CDC safety, metastability behavior, mapping, fit/STA, reset/RDC/MTBF, integrated Questa, DDR, PCIe, OPAE or hardware operation. The candidate remains unselected by the maintained production sources, as established by the consumed source review; **`PUBLISH_SUPPORTED=0` remains required**. The separately prepared additive endpoint Questa133 work is a separate functional integration step, not dependent on this review accepting a physical timing model.

Only this document was written. Review operations were local reads, JSON/log parsing, byte comparisons, hashing and arithmetic. No test, implementation, launcher, analyzer, simulator/vendor tool, git, remote or hardware operation was executed. `SOURCE-REVIEW129.md` was already PASS and consumed by `review-consumed131.json`; its source/spec disposition was used, not repeated as a broad source review.

## 1. Evidence identity and integrity — PASS

Root: `/home/joe/Projects/Thesis/AHLS/new_bsp/new`. Unless otherwise specified, paths below are relative to `qualification/caps02-mailbox-timing126/`.

The following SHA-256 values were calculated from the retained local bytes:

| Evidence | SHA-256 |
|---|---|
| `run127/summary.json` | `6ea406c8a2a76c4b2285072ba40f951d0b896f83710ea3f01b260480bb19a543` |
| `run127/inputs.json` | `bdec190cddda180721d7a5956db5fc1f00655dec07527c152f977e5b8943f964` |
| `verification130.json` | `3089eb251cbe8b95b5e2d9041300bedcbb0bfda265313682f758d2b2212bbbbf` |
| `RESULT130.md` | `033f938dfea72c77f815aaed945b8c213e2c926e973ccbf108baded56bc57146` |
| `DESIGN126.md` | `378a62b834b5946fcc618a0684ce838c753ceb776d6ba926ccdf1cf58392d41e` |
| `source126.json` | `31d382f988de9bcd3545dfdf6b6c9989c498621d4e395c6ee9497837ec2e7103` |
| `run127.py` | `caa4984530de820849934def7647147e972e650010a86b4c4c7bc004d02f911d` |
| `tb_mailbox_timing127.sv` | `0a63274c9dc71febf74db82344287bc6a6fd9d7d081f04cc6da7b239b871206d` |
| `tb_staging127.sv` | `9682e6a60e393a3aea2cfd7871c4017e73bc3b644c6a24e9eabff14e62d7ee61` |
| `SOURCE-REVIEW129.md` | `4c220b80f628955f413f95a671dae26c6fda44e2027bc1501b5889fb74aa6692` |
| `review-consumed131.json` | `4b0b9c528c448fb4315c5b17b901f5f09273f933965e3eafe0b63c01392a8634` |

Independent read-only verification found:

- All **44** input/source/tool/backend members match `inputs.json`; that map exactly equals the summary's input map. All bindings in `verification130.json` match, including its summary digest. Hashing the clock-analysis files did not execute or reassess that analysis.
- There are exactly **eight** test directories and eight corresponding summary records, without duplicate or missing labels. Every per-test `result.json` parses identically to its embedded summary record. Each directory contains exactly `result.json`, `compile.log`, `simulation.log` and `test.vvp`.
- All **24** recorded compile-log, simulation-log and compiled-artifact hashes match. Each compile log is empty. Each stage's separate log digest matches its actual log. DUT and fixture digests match the actual files selected by the recorded compile argv.
- Compile argv selects the expected fixture top, clock/sequence parameters, timing46 observer and candidate or labeled mutant. Runtime argv selects that test's retained `test.vvp`. Read-only inspection of compiled file-reference tables also identifies the expected fixture and candidate/mutant paths.
- All four `source126.json` source/fixture pins match. The original mailbox and timing46 observer retain their accepted identities. The fixture byte diff has only the top-name and mailbox-module-selector substitutions; all drivers, checks, limits and observer selection remain the timing56 fixture's.
- The source-review digest in consumed131 matches the actual review. Historical `independent_result_acceptance: false` fields describe the pre-review state; they were deliberately not rewritten. This document supplies the new, bounded result disposition.

The candidate SHA is `d521d67614ab2d405ac9fd39852ee0f1d968adb3dadba87d816057b8c562b627`; the timing46 observer SHA is `20cfd22f082a0924b7130d3721b2483a1308aa1e619bd1a3c2a548393a8e515b`.

## 2. Positive results and cardinalities — PASS

All five positive records have compile status **0**, simulation status **0**, and no timeout. Each simulation log has exactly one appropriate PASS line, with parsed fields equal to its recorded metrics, no `FATAL`/`ERROR`, and a normal fixture `$finish` location.

| Test label | Sequence bits | Cases | Checks | Simulated bank command strobes |
|---|---:|---:|---:|---:|
| `64-5-7` | 64 | 10 | 76 | 15 |
| `64-7-3` | 64 | 10 | 76 | 15 |
| `64-5-17` | 64 | 10 | 76 | 15 |
| `8-5-7` | 8 | 11 | 847 | 271 |
| `staging` | 64 | 10 | 447 | 10 |

The first four rows exactly match the corresponding accepted `caps02-observer-timing48/run56` result/log metrics: `[64,10,76,15]` three times and `[8,11,847,271]` once. The reference artifacts' recorded hashes and successful stage statuses also match. This is preservation of functional coverage/cardinality, not cycle-latency equivalence; the retained finish times differ. `native_commands` means simulated bank strobes, not vendor-tool or hardware execution.

The focused log reports, in its actual field order:

```text
cases=10 checks=447 req_install=11 req_publish=10 req_cancel=1
rsp_install=10 rsp_publish=9 rsp_cancel=1 commands=10 completions=9
```

These numbers are mutually consistent: **11 = 10 + 1** request installations, **10 = 9 + 1** response installations, **10 commands = 10 published requests = 10 response installations**, and **9 completions = 9 published responses**. The missing command belongs to the unpublished reset-cancelled request; the missing completion belongs to the already-serviced but unpublished reset-cancelled response. Neither cancellation is silently counted as success. Cases/checks are executed fixture counts, including repeated monitor checks and repeated baseline scenarios, not 51 distinct specifications or 1522 independent properties.

## 3. Actual coverage and observation quality — PASS within scope

Line references in this section refer to `tb_staging127.sv` unless stated otherwise.

- **Request staging, ownership and payload:** the core monitor samples old pending/accept/toggle/hold state, checks completion inhibition before the active edge's nonblocking updates, and checks installation and the next-edge publication after `#1` (`50–73`). It checks all 130 request bits and busy ownership. The full-width signatures are changed at the live inputs after acceptance; coherent bank delivery is compared against the saved request (`113–127`, `155–163`). The busy-rejection case changes command, expected value and token while pending and checks that the saved request survives (`201–206`).
- **Response staging and complete sidecars:** the bank monitor checks capture of snapshot, armed and error together while retaining ownership, then checks publication on the next active bank edge (`74–99`). The held-ACK case changes live data and armed state across publication and additional bank edges, then checks the held and installed response (`155–163`). The stopped-bank case preserves an armed response after the input clears (`172–178`). The error-sidecar case captures armed/error high, clears both live inputs and data before publication, and still requires both installed flags high with invalid completion (`214–218`). These are actual opposing-value checks, not merely checks that valid toggles. The focused snapshot is 32 bits; the unchanged observer integration fixture separately exercises the 768-bit production-width snapshot. This is not exhaustive per-bit/pattern coverage.
- **Paused clocks:** the core is stopped after accepting a request but before its notification; six bank edges must produce no bank command while pending/busy survive. Resumption must complete (`165–170`). The bank is stopped after response capture but before ACK notification; eight core edges must leave the old held response pending and core busy, then resumption installs it (`172–178`). Both pauses begin on falling edges, avoiding accidental extra active source edges. The reused baseline also tests a stopped bank before request service.
- **Reset cancellation and no replay:** pending-state assertions precede each intentional cancellation. Bank reset cancels the unpublished ARM while preserving poisoned epoch history; the subsequent observation interval requires no command/completion and no sequence advance (`180–185`). Core reset cancels the installed/unpublished response; after release the fixture requires ready, no valid/busy/pending, zero sequence, one already-issued command and no completion/replay (`187–193`). The final equations reconcile each cancellation with observed install/publication counters (`233–236`). This covers the two specified pending-state cancellation witnesses, not every reset/clock combination.
- **Faults on added notification edges:** `send` returns on the falling core edge immediately before request publication. The next active edge samples local CSR fault, a rejected busy command, or DMA contamination in three distinct cases; subsequent clean-looking replies must still be invalid (`195–212`). Phase-hit assertions require all three cases to have run. The tests do not claim a separate exhaustive fault matrix on response publication.
- **Completion-edge RELEASE fault:** the fixture observes the naturally asserted `source_complete`, drives rejected input on the preceding falling edge, and checks retirement, sequence, invalidity and retained epoch together, followed by later DMA contamination (`220–230`). It does not force internal state. A stimulus delayed until after completion would instead permit a fresh acceptance/busy transition and fail these checks. The unchanged baseline also checks retained history against later bank reset (`tb_mailbox_timing127.sv:135–145`).
- **Inherited integration semantics:** baseline coverage retains coherent ARM/snapshot/RELEASE operation, snapshot immutability, paused-bank service, busy rejection, active/idle reset history, cancellation, enqueue-edge DMA contamination, observer rejection, rejected-RELEASE history and 8-bit sequence saturation without wrap (`tb_mailbox_timing127.sv:95–157`). Local CSR fault is intentionally tied inactive there and covered in the focused fixture.

**Scheduling assessment:** stimulus is driven away from the relevant DUT sampling edge; functional post-edge observations use `#1` after nonblocking updates. Command counting observes the pre-edge bank strobe, while completion counting observes post-edge `core_done`. The clean per-case cardinality check occurs after `done_wait` has allowed another core edge and reached a falling edge. Required phase counters have settled before final accounting. No drive/sample race was found that invalidates these completed scenarios.

There is a narrow **reporting portability caveat**, not a result blocker: the final `repeat(3)cc()` returns in the same core-edge-plus-`#1` time slot as the core monitor, and the immediate final report/`$finish` does not explicitly serialize that last idle monitor check (`47`, `57–70`, `231–238`). Thus **447 is the retained Icarus trace's check count**, not a promised cross-simulator count; final idle-check ordering is not independently established. The relevant transactions and required phase counts completed earlier. If later work requires cross-simulator equality of this instrumentation count, move final reporting to a subsequent falling edge or explicit monitor barrier. No rerun or change to this accepted run is requested.

## 4. Non-vacuous synthetic mutants — PASS

All three negative records use the same focused fixture, have compile status **0**, simulation status **1**, no timeout, an empty compile log, exactly one fatal assertion report, and no PASS marker. Their actual source diffs are the single substitutions stated in `run127.py:95–104`, not unrelated broken fixtures or a deliberately failing compile.

| Synthetic mutant | Observed fatal label | Logged time (ps) | Why the witness is relevant |
|---|---|---:|---|
| `missing-pending-guard` | `F_PENDING_GUARD` | 95000 | Old ACK/request equality makes completion eligible while the newly installed request is still pending; the live pre-update predicate is checked. |
| `early-request` | `F_REQUEST_EARLY` | 86000 | The request toggle already changed on the accepting edge, violating the required installation-only first edge. |
| `early-response` | `F_RESPONSE_EARLY` | 148000 | ACK already changed on the qualified response-capture edge, violating response installation before notification. |

The early-request mutation also leaves the later pending publication in place, but it fails at the **first early edge**, before any later double-toggle consequence; its sensitivity is not attributed to that secondary defect. The response mutant likewise fails immediately on capture. Positive execution through these same monitor sites, explicit pending-state checks and nonzero phase counters exclude a never-reached assertion explanation. These controls establish sensitivity to the three targeted synthetic defects only; they are neither observed hardware faults nor an exhaustive mutation campaign.

## Final disposition

**Independent run127 local functional-result/test-quality PASS. No blocking correction.** Existing logs, metrics, manifests and source/compiled identities support the bounded claims in RESULT130. Source/spec129 remains consumed PASS; this document does not reopen it. Separate additive integration may proceed under its own source capsule and acceptance criteria. Physical implementation, reliability and hardware/publication gates remain open, unchanged, and outside this verdict. **`PUBLISH_SUPPORTED=0`.**

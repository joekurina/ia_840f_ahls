# Independent review — DMA CSR/descriptor admission

**Status: FINAL**  
**Verdict: PASS_WITH_NONBLOCKING_FINDINGS — bounded source/native evidence only.**

No blocking defect found in the stated CSR/descriptor-admission contract or in the final red02/green03 causal comparison. The final correction and recorded native result support bounded acceptance; they do not qualify deployment or hardware. Two nonblocking source/test-quality findings are recorded below. Predecessor routing review disposition, inherited reader/writer prerequisites, parent acceptance and publication remain separate; this review neither substitutes for them nor treats a review pending at preparation as launch denial.

This report replaces its early IN_PROGRESS version. All review work was local and read-only except this report. No SSH, simulator/vendor/native execution, hardware access, implementation edits, git operations or task transitions occurred. Python was used solely for inert file/JSON/AST inspection, byte comparisons, in-memory patch reconstruction, arithmetic and log reconciliation. Runner files were never imported or executed.

## 1. Bounded specification compliance — reviewed first

Authority: `SCOPE.md`, interpreted with the explicit evidence limitations in `RESULTS03.md`. References below use **C** = `inputs-candidate02/csr_mgr.sv`, **T** = `inputs-test02/dma_csr_admission_tb.sv`, and **B/** = `inputs-baseline/`.

| Requirement | Independent assessment and evidence |
|---|---|
| Validate received CSR address before narrowing | **Pass by source and representative native rejection cases.** C:95–102,131–135 checks the whole received address, alignment, size and writable whitelist before C:277/390 uses bits7:3. B/dma_pkg.sv:61–79 defines contiguous indices0..18: exactly19 readable words0x00..0x90; writes are0x28/30/38/40/50. The test interface is16 bits (T:26), not the upstream20-bit aperture. Native red02 fails on0x128; green03 rejects it. |
| Decode/access failures return DECERR; invalid reads zero | **Pass.** C:153 gives access failure precedence over value failure; C:268–299 initializes read payload to zero and performs data selection only on a valid access. T:261–269 covers high alias, unaligned, partial/zero strobes, wrong size, RO/unknown write and four bad reads. |
| Preserve response identity and stall behavior | **Pass within tested interface.** C:239–311,323–372 retains the existing independent AW/W capture and registered B/R response structure; ID/USER come from the corresponding address request. T:185–231 splits AW before W and holds each checked B / rejected R response for three cycles, comparing the complete packed response plus nonzero ID/USER. Real mapper ID/USER adaptation is not covered. |
| Reject raw values before descriptor narrowing | **Pass.** C:139–143 validates64-bit source/destination representability and nonzero length before C:391–393 narrows fields. C:88–89 bounds length by actual request/reply-counter capacity, not merely the20-bit length field. T:237–243,270–273 proves preservation of old CSR values on five invalid field writes and subsequent freshness rejection with otherwise valid old values. |
| Correct maximum admission bound | **Pass by source/arithmetic and admission-only boundary.** B/dma_read_engine.sv:94–97,174–175 and B/dma_write_engine.sv:81–89,200 use9-bit counts with256 beats per full burst. Independently calculated maximum is511×256 =130816 beats;130817 needs512 bursts. T:292 admits130816 but does not transport it. No maximum-length transfer proof is inferred. |
| Supported GO mode, command mask, fresh fields, alignment and ranges | **Pass by source with representative native cases.** C:145–148 accepts modes1 HOST_TO_DDR /2 DDR_TO_HOST and only GO/mode bits; C:103–128 checks freshness,64-byte alignment, host start/end, valid DDR bank and same-bank inclusive end. End arithmetic is65 bits before range comparison. T:274–286 covers modes0/3, reserved low/high and upper command bits, both endpoint misalignments, high DDR bits in both directions, bank0 crossing/bank1 end crossing and host end overflow in both directions. T:290–292 provides three positive admission boundaries. |
| Reject full queue / sticky engine fault / nonzero legacy control | **Pass by source; full queue dynamically exercised.** C:126–128 rejects all three conditions. B/dma_top.sv:87–95 connects actual reader/writer error and FIFO-full status. T:293–303 fills the actual descriptor FIFO then proves no enqueue for the rejected next GO. Sticky-error and nonzero-control predicates are not independently isolated dynamically in this test. |
| Freshness and rejection side effects | **Pass by source; field invalidation dynamically isolated.** C:156–168 changes freshness only for access-valid writes; rejected field values clear only their corresponding freshness flag. Any access-valid GO consumes all three flags, even if command/admission fails. C:387 gates stored CSR updates on OKAY. Address/size/strobe failures therefore leave staging/freshness unchanged. T:287–288 does not independently prove GO consumption, because the retained descriptor also remains range-invalid; see F1. |
| Accepted FIFO entries unaffected by rejected admission | **Pass by source; no-enqueue checked natively.** C:383–395 creates a single registered GO pulse only for an accepted descriptor. B/dma_top.sv:72–75,108–123 copies that descriptor into the actual FIFO; rejection adds no reset, flush or rewrite path. Serial CSR writes and the sole enqueue producer prevent another CSR enqueue from racing into the slot between validation and its registered GO pulse. T:165–173 checks no enqueue/no memory requests during empty-queue negative cases; T:301–303 separately checks no enqueue on full-queue rejection. This is not a test of draining queued work after rejection. |

The command validator also constrains non-GO descriptor-control writes to supported modes and reserved-bit cleanliness (C:145–148). This does not provide a cancel or clear-error command. Legacy control remains writable with its original low32-bit behavior; nonzero control prevents later admission but does not establish safe behavior for already active work.

## 2. Source identity and final-pair causality

Independently verified all **28** manifest entries, sizes and hashes:

- `review-package01.json`: `08476221571779c6bdbd93d60c6166b4dd848fe4a12b35270719be7cbba1d773`.
- Original CSR: `e3ab7d4e79836bed79bcebdd3922d31a1750d2f5481faeb831f3f0a105a79463`.
- Final CSR: `b526562f8663139a1a5654e54695ada8de67ee260b3b6a79014344ab7f3c4073`.
- Final test: `65143df8bd1a6d05780c3cd478d91d37ca07d4d19bc609a051605aba845b07e8`.
- Final patch: `0da75241a03d9f00b5ba005ca4d1c8f340004ce00ab640fa177d89826f85167c`.
- `result-red02.json`: `2679ee66b849295ef305ee0d440efa82fecd796d1f8aba3c82581c6058061944`.
- `result-green03.json`: `e30e76ff4a97d728c9e1a1d951771cc876a14320014c2e320d92f9212d061174`.

Literal AST decoding recovered25 payloads per attempt for all five attempts. All125 decoded payloads matched their hashes, result-input maps and the appropriate local baseline/candidate/test snapshots. Dispatch script hashes and outer-result hashes matched. Every embedded native log's byte length and SHA256 matched its retained text. The runner body was identical to `run-native.py.in` after replacing only its literal configuration assignment.

Red02 and green03 differ in exactly **`csr_mgr.sv`**, not the test or other dependencies. The shared inputs match predecessor `dma-top-routing01/run-isolate_green01.py`, except final CSR; only the test filename/payload is replaced for this gate. The predecessor manifest hash matches `source-binding01.json`. The eight positive cases' task body is unchanged from that predecessor apart from its display-marker name. No whole predecessor audit was repeated.

Strict in-memory unified-patch reconstruction reproduced both the historical first candidate and the final candidate exactly from the original CSR. `afu/ahls_memory/dma/tests/dma_csr_admission02_tb.sv` is byte-identical to the final test snapshot. First-to-final CSR change is solely declaration ordering; first-to-final test change is solely `mmio.wvalid=(t>=4)&&!wdone` instead of premature `!wdone`.

## 3. Completed native evidence

All assertions here are about retained, hash-bound native records, not fresh execution or a new remote state observation.

| Attempt | Native / outer result | Independent disposition |
|---|---|---|
| red01 @212 | Five steps0; outer1 | Original alias failure, but first fixture had the stale-W defect; preserved, not the authoritative final negative control. |
| green01 @213 | vlog2; outer2; no vsim | Real undefined `is_csr_write` declaration-order error, preserved. |
| green02 @214 | Five steps0; outer1 | At495ns partial-write check failed because the fixture sent stale value1/full strobes, not intended0xdead/partial strobes. Native log and one-line test correction agree. |
| red02 @215 | Five steps0; outer1 | Corrected fixture sends0xdead at0x128; original CSR returnsOKAY rather thanDECERR; fatal at285ns. |
| green03 @216 | Five native/effective steps0; outer0 | Complete guard and positive-copy scoreboards; no Error/Fatal diagnostics. |

Native-zero fatal rejection is real: red02's `vsim.log` lines58–65 contains the intended0xdead, fatal and Errors:1 despite native rc0. The outer runner rejects that result. The unchanged120-second per-command deadline and existing Error/Fatal/qualified-severity/nonzero-summary checks were retained; no timeout or surviving owned group is recorded in any attempt.

Tool/original bindings are identical across attempts: Questa Intel FPGA Edition2024.3 under `/opt/altera/25.1`, installed `modelsim.ini`,13 tool/library entries including six `altera_mf` library files, and12 original-file bindings. The captured `vdir` enumerates `scfifo`; source instantiates the real BRAM FIFO wrapper/scfifo and actual PIM register-slice/skid composition. All recorded original/input/tool preservation flags are true. This establishes the captured run's provenance, not a live re-hash of the remote installation.

### Reconciled results

From `result-green03.json` → `logs["vsim.log"].text` (line numbers within that text):

- Line426: `DMA_ADMISSION_GUARD_PASS checks=56 rejected_writes=32 rejected_reads=4 rejected_go=20 queue_accepts=20`.
- Actual queue fill is17 entries, consistent with16 scfifo slots plus its registered first/output stage (B/ofs_plat_prim_fifo_bram.sv:32–79). With three boundary-only admissions,20 total entries are **admission-only**, not completed copies.
- Lines439–530: exactly eight case rows, byte-for-value consistent with `cases03.json`. Independently summed:19AR /19AW /3397R /3397W /19B /8 retirements; each direction×bank combination occurs twice.
- Line531:8626 monitored transfer-loop cycles,110977 total `require_ok` checks,8 successes,0 error/held cases,3069 R stalls,4908 W stalls, maximum R-minus-W occupancy38,4 high-source and4 high-destination cases. The check count includes CSR/admission assertions; the cycle counter advances only in the positive transfer loop.
- T:393–447 checks request address/length/size/ID, FIFO data/order/markers/occupancy, destination address/data/strobes/WLAST, response accounting and retirement. All3397 transport beats and3397 destination model-memory copyback values are checked. This is numerical synthetic-memory evidence, not physical memory visibility.
- Raw CSR messages count204 writes /31 reads. Line532's legacy152 writes /27 reads omits52 `write_checked` and4 `read_rejected` transactions. The guard's56 is a checked-transaction count, not an assertion total. Parent reconciliation is correct.
- Lines533–536: normal finish at101521ns; **Errors:0, Warnings:11**. Seven distinct13314 relaxed-input-kind sites plus four8315 unique-case warnings occur at time zero before synchronous reset initializes the engine state. `vlog.log` separately has8 warning occurrences, including duplicate CSR-site reporting. No width/latch/truncation diagnostic or warning suppression appears in the final captured invocation. These warnings do not establish a mapped-synthesis/reset qualification.

## 4. Source/test quality findings and actions

### F1 — Nonblocking: several admission predicates remain source-only, not isolated dynamic proofs

**Evidence:** C:126–128,156–168; T:261–288,293–304; `RESULTS03.md`:49–50. Failed-field freshness is genuinely isolated: `bad_field` preserves a valid old value and otherwise valid staging before the failed GO. In contrast, the repeated GO at T:288 follows a descriptor whose retained data are also invalid for its new direction, so removing GO-consumption alone would not necessarily fail that test. Sticky read/write error, nonzero legacy control and staging preservation across malformed GO/access shapes are not each tested with every other predicate valid. The full-queue phase verifies rejection/enqueue count, not later queue-content drain.

**Action:** Keep those claims explicitly source-checked when consuming this result, as the current results document does. In a future changed, authorized fixture, isolate successful-GO replay and failed-command-GO consumption using valid retained fields; isolate malformed-access non-consumption with a subsequent valid GO; and isolate each sticky-error/control predicate. If dynamic preservation of existing queued descriptors is later claimed, drain/check their identities rather than resetting them away. No unchanged rerun or broader hardware test is needed to accept this bounded result.

### F2 — Nonblocking: runner guard acceptance checks positivity, not the frozen coverage totals

**Evidence:** `run-native.py.in`:107–115 parses a single guard marker but only requires each guard value to be positive; `expected_score` constrains the positive transfer totals, not the five guard counts. A future fixture losing several negative tests could still satisfy this guard acceptance floor. Current evidence is not invalidated: the frozen fixture is inspected and all five actual totals were independently reconciled exactly.

**Action:** When preparing a future changed package, bind an explicit expected guard dictionary and compare all five values exactly, alongside the existing diagnostic/native checks. Also distinguish total CSR transactions from legacy-helper counters in the emitted marker to avoid repeating the152/204 and27/31 reporting ambiguity. Preserve this consumed package and its observed counts; do not edit it or rerun it merely to improve bookkeeping.

## 5. Acceptance boundaries and disposition

- Acceptance covers this finite source/admission contract and eight inherited positive-copy cases. It remains dependent on separate predecessor routing review and inherited accepted reader/writer/read-response evidence; no finding there is waived.
- 130816 is an **admission limit**, not a demonstrated maximum transfer. Valid same-ID-zero, ordered/valid-RLAST responses and synthetic linear line-request endpoints define the data-test domain. Generic AXI WRAP/4KiB semantics, malformed response streams, counter wrap, all boundary traffic and parallel physical-bank operation are not qualified.
- CSR validation checks the16 bits actually received. It cannot repair20-bit-aperture clipping or aliases introduced before this interface.
- Internal DECERR/SLVERR is not proof that host software observes a posted PCIe MMIO write fault. Readable admission-error reporting and host pinned-extent/ownership validation remain integration work.
- Admission-only requests are abandoned by testbench module reset. Inherited isolation/poison endpoint stimulus may offer irrelevant responses during those boundary phases; those phases claim no completed copy. This is not cancellation, safe reset, global drain, buffer release or live recovery.
- CSR error-code aggregation, legacy-control safety, generated/deployed PIM geometry and single-primary mapper, ID/USER conversion, clocks/reset/PR, fences and physical visibility, host buffers, mapped Quartus synthesis/FIM signoff and hardware acceptance remain open.
- Vendor DDR simulation is **SKIPPED BY USER**. No device, MMIO, driver, programming or reboot operation was performed or authorized by this review.

**Disposition:** No in-scope implementation correction or native rerun is required by this review. Parent may consume this bounded PASS_WITH_NONBLOCKING_FINDINGS, carrying F1/F2 and the explicit integration limits forward. Only `qualification/dma-csr-admission01/independent-review01.md` was created/modified by this reviewer; frozen package/source/test/evidence bytes were rechecked unchanged before final reporting.

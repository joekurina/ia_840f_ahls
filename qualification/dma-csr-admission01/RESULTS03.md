# DMA CSR/descriptor admission — completed native evidence

**Native test PASS; independent review pending.** Narrow candidate changes only `csr_mgr.sv` against the prior full-top routing composition. Original donors, predecessor evidence and all installed tools are unchanged. [Scope](SCOPE.md), [source bindings](source-binding01.json), [final pair](source-binding02.json), [parent verification](parent-verification01.json).

## What changed

[Final patch](../../afu/ahls_memory/dma/patches/csr_descriptor_admission02.patch) validates the entire **received CSR byte address** before the original low-bit index decode. Allowed readable range is the defined contiguous64-bit words0x00–0x90; writable targets remain source0x28, destination0x30, length0x38, descriptor control0x40, legacy control0x50. Require aligned8byte size3 access and all8write strobes; read-only/undefined/high alias/unaligned/wrong-size/partial-write requests return DECERR. Invalid reads return zero data. Preserve ID/USER and stalled-response stability.

Check source/destination raw64-bit writes against the actual descriptor width before assignment; check length before its20-bit narrowing. Reject zero or more than130816beats. This maximum follows ceil(length/256)<=511 for both9-bit request/reply counters, **not** the20-bit field maximum. Source-side arithmetic plus admission boundary testing is not proof of maximum-length data transport.

On access-valid GO: require supported executable mode1HOST_TO_DDR or2DDR_TO_HOST, zero reserved/upper command bits, freshly accepted source/destination/length fields,64-byte-aligned endpoints, representable host start/end, a real bank index and no bank crossing, non-full descriptor FIFO, no sticky reader/writer error and zero legacy control. Range arithmetic uses65bits including the final byte, retaining both16GiB banks/bit34 selection and57-bit host addresses. Mode-specific bank/host roles are tested both ways. Invalid descriptor/admission returns SLVERR and does not enqueue. Failed value writes preserve stored CSR data but invalidate that field's freshness; access-valid GO consumes all three freshness flags even when rejected. Address/size/strobe rejection leaves staging unchanged. Already queued descriptors are untouched.

This adds no cancellation or FIFO reset. Legacy control behavior remains, including its unresolved stop/reset semantics. It is not a safe lifecycle API.

## Native attempts (preserved)

|Attempt|Actual result|Disposition|
|---|---|---|
|red01 @212|All5native steps0, outer1; 0x128 write returnedOKAY instead ofDECERR|Original CSR alias reproduced with first fixture; later paired red02 is authoritative negative control.|
|green01 @213|vlog native/effective2, outer2; vsim not run|Declaration-order error for is_csr_write. [Failure](GREEN01-FAILURE.md).|
|green02 @214|All5native steps0, outer1; expected partial-writeDECERR but gotOKAY|Fixture offered stale WVALID/data before t4. Raw native log records value1 rather than intended0xdead. [Failure](GREEN02-FIXTURE-FAILURE.md).|
|red02 @215|All5native steps0, outer1; at corrected fixture's first alias case0x128 returnedOKAY instead ofDECERR|Same final test as green03.|
|green03 @216|All5native/effective0, outer0; complete guard and data scoreboards|Native bounded PASS, pending independent acceptance.|

Final red02/green03 have exactly one differing input: csr_mgr.sv. All25decoded source payloads/run, script dispatch hashes, embedded log sizes/hashes, separate result SHA and outer buffers were verified. No timeout or surviving owned group in any attempt. Identical original-file/tool bindings preserved. Version is Questa Intel FPGA Edition2024.3 under /opt/altera/25.1; installed INI and real6-file altera_mf/scfifo library retained. These are offline RTL tests, not Quartus mapped synthesis.

## Actual tested results

`DMA_ADMISSION_GUARD_PASS checks=56 rejected_writes=32 rejected_reads=4 rejected_go=20 queue_accepts=20`.

- Seven access/write-shape errors, four invalid reads; source high-alias write cannot change source readback.
- Five invalid-field cases: high source, high destination, zero length,130817length and high-bit length. Readback proves failed value writes did not change the old field; subsequent GO on otherwise-valid preserved values is rejected by the invalid freshness flag.
- Unsupported modes0/3, low/high reserved command bits, upper32bit command; source/destination misalignment; high DDR source/destination; bank0→bank1 and bank1→outside crossing; host end overflow in both transfer directions. Twenty rejected GO transactions include missing-freshness/full-queue attempts, not twenty unique defect classes.
- Three admission-only positive boundaries: last host/bank0 beat, last bank1/host beat,130816beat length. No transfer at that maximum is claimed.
- Actual descriptor FIFO accepts17entries while endpoints are stalled, then rejects the next GO without an enqueue. Its configured16-entry scfifo plus registered output stage explains the observed capacity; do not call it a16-total-entry hardware queue. Together with the three boundary admissions,20accepted descriptors are admission-only, not completed copies.
- Split AW then W arrival and three-cycle held B/R responses verify response status, ID/USER and packed response stability. The repaired fixture holds WVALID low until its new payload is prepared.

The full-top positive regression still reports **8cases /8626monitored transfer cycles /110977checks;19AR/19AW/3397R/3397W/19B;8successes**. Every3397transport beat is verified and the3397destination model-memory values are checked at retirement. [Eight case rows](cases03.json). Both directions through both bank ports, high host bits, local offset bit33, backpressure and inactive-bank isolation remain exercised. There is no physical DDR model or actual primary PIM host mapper.

Actual native CSR log count is **204writes /31reads**. The legacy `CSR_COUNTS writes=152 reads=27` marker counts only the original successful helpers;52write_checked and4read_rejected transactions are additional. The guard's56checks count those checked transactions, not all assertions. Transfer-cycle8626 excludes CSR-only and admission phases; total simulation ends101521ns. No performance claim.

Final native summary **0errors/11warnings**: seven distinct relaxed-input-kind13314 sites and four time-zero unique-case8315 warnings; vlog separately has8occurrences with csr_mgr repeated. No warnings suppressed. First failed candidate has a genuine compiler error; fatal/native0 simulations remain outer1, not rewritten as native errors.

## Limits retained for integration

- This checks the16-bit CSR interface received by csr_mgr. Bits lost in an upstream fabric/host decoder cannot be recovered here; the outer20-bit aperture and known kernel/fabric alias still need exact decode before narrowing.
- DECERR/SLVERR on this internal bus is **not** proof that OPAE observes a posted PCIe MMIO write failure. Readable admission-error reporting and host-side validation/ownership must be established when connecting the real mapper. Valid-range checks do not prove a host address belongs to a currently pinned allocation.
- The current fixtures use synthetic geometry/AFU identity and linear line-request endpoints, not general AXI4WRAP/4KiB semantics. No max-length or all-boundary data traffic, malformed RID/RLAST, counter-wrap, bank-parallel traffic or deployed addressing claim.
- Freshness after failed value writes is directly exercised. GO-consumption and legacy-control/sticky-error admission predicates are source-checked; not every cause is independently isolated by dynamic negative tests. The final repeated failed-GO case also retains invalid range data.
- Admission-only entries are deliberately abandoned by **testbench module reset**. This is not safe live reset, global drain, cancellation, buffer release or recovery. The inherited isolated endpoint stimulus may offer irrelevant replies during these boundary-only phases; no completed data path is claimed for those entries. Successful numerical data evidence comes only from the subsequent eight fully checked cases.
- CSR error-code aggregation, safe legacy-control semantics, real PIM/fabric ID/USER/clock/reset/PR integration, fences/physical visibility, FIM signoff and all hardware gates remain open. Predecessor routing independent review is still a separate handoff; this gate does not waive its findings.

No devices, MMIO, programming, driver changes or reboot. DDR vendor simulation **SKIPPED BY USER**. No hardware acceptance or milestone publication until independent review is consumed.

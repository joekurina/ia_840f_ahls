# Raw-capability ABI v1 — parent acceptance

## Decision

**ACCEPT the exact additive source/interface correction, completed native RED/GREEN CSR differential, and pure offline C decoder tests.** Independent specification PASS and quality PASS; no blocking defect or required rerun. This is not acceptance of the legacy ABI or changed physical implementation. [FINAL independent review](independent-review01.md), [parent verification](parent-review-verification01.json).

Parent read the complete FINAL report and matched its SHA256 `eb670aa3ba00b1e2a84fe2a7f0e981c2cbed83673cda94463e5371a78481a1ff` to the returned identity for `deleg_d9a54295`. All **31 frozen members / 3,411,284 bytes** were rehashed without mismatch; package SHA256 `0b72641bb90d51ed3582230ea2d5ab9120aa9f6cf147ada0867ee736b06155fd`. The exact source diff was reproduced, request/response masking and malformed-access cases inspected, both transport receipts and ten log payloads verified, and source/host-result identities checked. [Frozen package](review-package01.json), [source delta](raw-capabilities01.patch), [test fixture](csr_capability_diff01_tb.sv).

Candidate SHA256 `053b9855aa860c410337f5cae7e6160c6086726903cf988a1d35f032cb7a0b93`; baseline SHA256 `42d09ffffb91152b9f688014bcff9ffc13e5382cddd7f478e5f9b992da232a77`. Four aligned 64-bit read-only words at AFU-relative offsets 0x98/0xa0/0xa8/0xb0 expose a tagged exact-target raw capability record. Legacy assignments/functions, effective write eligibility, endpoint logic and transaction schedule are unchanged. New-address writes are rejected; no datapath or clock-policy change is included. [ABI](ABI01.md), [decoder](ia840f_dma_capabilities.h).

## Completed evidence and diagnostic clarification

- RED: native/effective stages all 0/0 but expected fatal on the first new-word read, unit_pass=false, **outer 1**. This remains a functional failure, correctly detected by the harness; exit zero alone was not accepted.
- GREEN: all stages 0/0, outer 0 and unit_pass=true. Exact scoreboard: tests=311, writes=1536, reads=51, enqueues=85, endpoint_checks=226, min_gap=674, b_stalls=138, r_stalls=255, resets=251, cycles=8955, checks=58635, cap_reads=16. The 311 count is the retained GO-oriented scenario counter, not 311 independent metadata cases; min_gap counts three-cycle service-gap events, not a latency of 674 cycles. [Native results](RESULTS01.md).
- **Compilation separately reports four repeated vlog-13314 warning occurrences per run; simulation reports two vopt-13314 warnings per run.** These concern candidate/baseline status-port kind under the existing relaxed default. No suppression or new defect is implied. The frozen results' simulation-only warning statement remains intact; do not summarize the entire attempt as two warning occurrences. [Review finding 2](independent-review01.md).
- Both runs preserve original/input/tool bindings and leave no owned survivors. Each carries 27 verified source payloads (three declared lengths, 24 derived lengths) and five verified logs. This is not 27 compiled files or a real DMA-memory datapath test.
- Host decoder: C11 O0 and O2, strict warnings, assertions enabled and UBSan; each passed the valid record, all 256 single-bit mutations and both null checks, preserving output on rejection. Header/test/executable identities match saved receipts. No test was rerun during parent acceptance. [Host receipts](host-test-results01.json).

## Unwaived limits

Synthetic platform/status and directed CSR equivalence do not establish live host routing, physical transfers, maximum-length execution or hardware behavior. The new capability path intentionally does **not** repair narrowed legacy width/depth fields, hardcoded clock 400 or 150-to-64 aggregate status. It supplies no drain, fence, cancellation, reset/CDC/PR or buffer-release contract. A matching capability record authenticates neither an image nor permission for MMIO.

Changed synthesis, fit and final STA remain separate gates; prior CSR02 physical evidence does not transfer automatically. Full Design Closure and the hardware goal remain incomplete. Vendor DDR simulation is **SKIPPED BY USER**. The existing CAPS01 fitter and separate synthesis review are unaffected; this acceptance neither restarts them nor creates an execution barrier.

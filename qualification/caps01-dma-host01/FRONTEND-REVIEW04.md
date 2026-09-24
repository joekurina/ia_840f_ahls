# FRONTEND-REVIEW04 — independent CAPS01 DMA frontend review

## Verdict: ACCEPT WITH BOUNDED LIMITS

**No blocking defect found in the intended two-buffer, one-outstanding-descriptor, 64-byte roundtrip using the bound flags-zero VFIO backend.** The explicit uncertain-GO/error paths retain ownership and cannot return into cleanup or entry finalization. This accepts the reviewed source for the next bounded qualification step; it is **not a native launcher/entry build result, hardware DMA pass, whole-system drain proof, or guarantee against a host-stranding MMIO access**.

One concrete **non-blocking defensive-path defect** is recorded below: duplicate successful WSIDs are rejected before GO but then released twice. The bound backend's ordinary two-live-allocation path does not provide such duplicate WSIDs; acceptance does not extend to malformed successful allocator outputs.

Scope: local source and retained test-evidence inspection only. No remote connection, device access, build, test executable invocation, reset, programming, SDK installation, or git operation. Only this report was written. The supplied Work21/CAPS01 identity acceptance, VF `0000:4f:00.2`/group76 context, physical presence and continuing authorization are reused, not re-audited. Original inspection frontend/startup hashes still match `reviews-consumed02.json`.

Paths are relative to `N=/home/joe/Projects/Thesis/AHLS/new_bsp/new`; `G=qualification/caps01-dma-host01`. In references below, **F** is `src/host/ahls_memory_dma_roundtrip.c`, **C** is `src/host/ia840f_dma_transfer_core.c`, **S** is `src/host/ahls_memory_dma_vfio_startup.c`, **L** is `src/host/ia840f_dma_lifetime.c`, and **M** is `tests/ia840f/dma_host/mock_dma_opae.c`.

## Source findings

### 1. Literal identity, modes, addresses and raw extents — accepted

- F:77–99 and S:102–106 require the exact new option, exact bank token `0` or `1`, and syntactically valid full BDF. `ahls_parse_bdf` checks length, separators, hexadecimal characters and PCI device/function limits before narrowing. The production source takes the BDF from argv; it does not hard-code this physical VF or confer authorization on another BDF.
- F:89–129 filters the exact accelerator GUID and PCI/subsystem IDs, requires one match, maps MMIO0, and checks three identity words and all four capability words before allocation/submission. The capability decoder accepts only the intended raw geometry, including 57-bit host addresses, 34-bit bank-local addresses, two banks and 64-byte beats.
- C:4–9,62–83 use aligned 64-bit accesses: source `0x28`, destination `0x30`, length `0x38` in beats, GO `0x40`, status `0x48`, control `0x50`. Control must read zero and is never written. Each descriptor's three arguments are written once and fully read back before GO; there is no GO retry.
- The enum and mux, not the stale reversed mode comment, support these exact commands:

| Direction | Mode | GO word | Source | Destination |
|---|---:|---|---|---|
| Host to DDR | 1 | `0x84000000` | returned source IOVA + 64 | bank address |
| DDR to host | 2 | `0x88000000` | bank address | returned destination IOVA + 64 |

The fixed DDR byte address is `0x10000` for bank0 or `0x400010000` for bank1. Each submission has length one beat. Relevant bound RTL: `dma_pkg.sv:61–79,133–152`, `dma_axi_mm_mux.sv:130–144`, `dma_ddr_selector.sv:29–41`, and `csr_mgr.sv:149–215,324–349`.
- C:26–36 validates raw request values before the transfer core performs any MMIO or address addition: mode/bank, positive aligned length no greater than one page, exactly one-page mapped extent, page-aligned IOVA with the entire page below `2^57`, aligned host offset with payload within the page, aligned DDR offset and no crossing of the selected bank, and nonzero polling budget. Short-circuit ordering keeps the subtractive bounds from underflowing. Bank validation precedes the shift/OR. F's identity accesses and allocation necessarily precede this transfer-core request validation; they are not descriptor access.

### 2. Ownership and partial failures — accepted within the bound allocator contract

F:130–157 obtains two backend-owned 4096-byte buffers with flags zero, records each successful acquisition before GetIOAddress, validates returned CPU/IOVA alignment and full IOVA extents, and rejects overlapping pages/duplicate identities before GO. It programs returned IOVAs, never CPU pointers. Both complete pages are initialized before the first descriptor. Neither page is modified by the CPU while DMA may own it.

F:191–197 releases the successfully acquired WSIDs in reverse order, then unmaps/closes/destroys metadata, recording cleanup errors as failure. Allocation/GetIOAddress failure at each position retains the correct acquisition count. The retained backend publishes pointer/WSID outputs on the success path (`opae_vfio.c:1543–1564`); unreported backend-internal allocation leaks are not frontend-owned WSIDs and must not be guessed or retried. A failed second pre-GO setup may clean up after the first H2D has already locally retired; this is a failed test, not a completed roundtrip. No descriptor is submitted after any API failure.

**Non-blocking defect, F:139–141 versus F:191–192:** if two successful PrepareBuffer calls return the same WSID, the overlap check branches to cleanup with `prepared == 2`; the release loop invokes ReleaseBuffer twice with that same WSID. This is not safe generic malformed-output handling: the retained VFIO release implementation dereferences WSID as buffer metadata (`opae_vfio.c:1574–1580`), so a second call can dereference freed metadata. No GO has occurred on that path. The ordinary bound flags-zero allocator obtains separate live mappings/metadata, so this requires a violated backend contract rather than an identified reachable normal allocation failure. The `alias_iova` fixture uses distinct WSIDs and does **not** cover it. Before claiming robust duplicate-WSID rejection, add a dedicated inert case and make cleanup ownership unique; no such source change was made here.

### 3. GO ambiguity and completion freshness — accepted as local retirement

C:77–83 sets `go_may_have_been_issued=1` and clears `quiescent` **before** calling the GO writer. Thus even an API error on the GO store is hazardous. C:85–101 preserves unknown ownership on status API failure, error/stop/reset flags, unexpected retirement count, failed wait, or polling exhaustion. F:165–170 directs every such result to the non-returning production hold. There is no extra diagnostic MMIO on that failure branch.

Completion requires all of: exactly the next retired-descriptor count modulo16, busy clear, both relevant FIFOs empty/not full, no error/stop/reset flags, and both reported FSM fields idle. A fast transfer need not expose busy; stale idle is not success. C initializes a fresh report/baseline for each serial descriptor, and the second descriptor cannot be reached until the first has returned successful local retirement. Only the second descriptor's pre-GO failure paths can clean up without a completed roundtrip; they do not abandon an unresolved first descriptor.

The bound RTL increments the count at actual descriptor dequeue (`dma_read_engine.sv:223–247`), conditioned on writer completion/no read error. Writer completion accounts for accepted AW, WLAST and matching OKAY B credits (`dma_write_engine.sv:92–118,294–303`). This supports **source-local AXI retirement**. The six-bit status writer-state field is not a full decoder of the wider writer FSM; the tested idle encoding remains valid. Neither status nor a C atomic fence is independently a physical PCIe/host-memory visibility fence.

### 4. Payload, freshness poison and guards — accepted for this tiny roundtrip

F:143–156 constructs the bank/address-dependent payload, distinct full-page source/destination guard patterns, and a destination poison that differs from the expected payload in **every byte**. After two locally retired descriptors, F:178–185 reads host RAM through volatile byte loads, waits for all 64 payload bytes to match, then checks all 4096 bytes of both pages. Source corruption and destination guard corruption cannot be reported as a pass. Missing visibility, payload mismatch, or either full-page mismatch enters hold even though local retirement was reported; it does not release buffers.

This establishes observed copied-back data and sampled guards for this operation, not cache-coherence qualification on arbitrary platforms, physical completion throughout the PCIe fabric, proof against later stray writes, or correctness beyond the selected 64 bytes. The expected pattern is deterministic per bank/address, not a per-run nonce; it does not distinguish a delayed earlier identical transfer. The single-owner/no-prior-unknown-DMA boundary therefore remains material.

### 5. Production hold and startup ordering — accepted at source level

- S:137–140 blocks ordinary signals before `dlopen` of the OPAE-linked entry. Explicit initialization is later at S:158, and frontend entry at S:163. F:85 repeats protection before its first OPAE API. This covers ordinary library-created threads inheriting the mask under the intended parser-only startup linkage; the native ELF/dependency composition is still the parent's pending build verification.
- L:9–15 blocks the process thread's signal set. L:22–31 reports captured state, flushes, and loops forever in self-SIGSTOP. SIGCONT can only resume that loop and cause another stop. It has no OPAE/device access, release, close, exit or return.
- The `_Noreturn` declaration and actual body agree. The strict entry simply calls the frontend. S:164 can finalize only after entry returns; an uncertainty hold cannot reach that statement or ordinary exit/destructors.
- `hold-result03.json` records the actual production helper linked into an inert RAM/regular-file owner: SIGSTOP/stopped state and retained file descriptor both initially and after TERM+CONT. Its later SIGKILL was cleanup of that exact inert child, **not** a permissible procedure for a DMA owner. This proves the narrow OS hold behavior, not a native OPAE process/thread integration result.

Do not wrap a live owner in automatic timeout/TERM-to-KILL cleanup, kill traps, retries, or a successor probe. A hold is a failed attempt with retained ownership, not cancellation. SIGKILL, fatal faults, OOM, host loss and explicit changes to signal handling remain outside this containment. Diagnostic output itself can block, but that still retains the original owner rather than releasing resources. Polling limits bound returned accesses, not the duration of a stalled MMIO instruction or retained-owner lifetime.

## Actual inert receipt and mock audit

I parsed `frontend-tests02/result.json`, read/hash-checked **all 76 referenced logs**, checked unique case names/counts and receipt predicates, and compared the retained ELF against its recorded SHA256. Results: **76 planned = 76 executed = 76 unique = 76 passing; 76 log files; zero hash/size/predicate discrepancies.** Return-code distribution: 2 successes, 60 failures with rc1, 4 argument rejections with rc2, and 10 mock holds with rc77.

- 2 bank successes independently assert the literal GO words, source/destination IOVAs, selected bank address, one-beat length and eight golden payload words.
- 51 single API-failure cases cover each call position in the successful bank0 trace, not all possible API executions. Calls22/23/24/25 are the two PrepareBuffer/GetIOAddress pairs; observed release counts are respectively0/1/1/2. Calls34/35 and44/45 are the two GO writes and their following status reads; all retain both buffers with zero releases. Calls36–43 fail before the second GO after the first successful retirement and clean up normally. Calls46–51 test cleanup failures and suppress a pass result.
- 12 named scenarios cover zero/multiple/partial-error enumeration, out-of-range IOVA, equal IOVAs, argument-readback mismatch, sticky read-response error, stale count, missing visibility, payload corruption, destination guard corruption and source corruption.
- 7 identity/capability single-bit mutations and 4 CLI rejections complete the receipt.
- Every one of the 10 mock-hold logs contains its hold record and retained-state summary with no release/unmap/close/destroy API or pass marker. M:28–34 intentionally calls `exit(77)` only in this device-free fixture; it is **not the production helper**. M:30–31 checks the resource ownership at that boundary.
- `normal-result01.json` and `sanitized-result01.json` each contain 33 passing core cases, zero compile/test statuses, and matching current core/header/test source hashes. These are the same 33 cases in ordinary and ASan/UBSan builds, not 66 distinct cases. They add counter wrap, busy-then-done, non-idle baseline/control, writer-state/FIFO rejection, both response errors, extra retirement, wait failure and 16 raw invalid requests.

### Coverage limits, not hidden claims

1. The frontend harness replaces **all three lifetime helpers**. It does not run the new startup, strict initialize/entry/finalize chain, native OPAE buffer mapping, or signal inheritance in real library threads. The hold fixture separately exercises the production helper, but not those integration boundaries.
2. M completes memcpy and increments retirement synchronously in the successful GO call. It models stale/error status but not real bus ordering, partial/delayed visibility, delayed successful completion in the complete frontend, later-poll API failure, or spontaneous device failure. Core fixtures cover some delayed/status cases but do not establish physical behavior.
3. Successful malformed allocation outputs are not comprehensively injected: equal IOVAs and an out-of-range IOVA are covered; duplicate WSIDs/CPU pointers, null or misaligned CPU pointers, frontend signal/page-size failure, and exact accepted top-of-range boundaries are not. The concrete duplicate-WSID issue above is therefore absent from the 76-case claim.
4. Failures are injected one at a time. Except partial enumeration, the mocks generally fail before acquiring the operation's resource. The close mock does not implement the backend's destructive remaining-buffer cleanup; its leftover bitmask is fixture bookkeeping, not proof that native release/unpin succeeded. No fixture proves a failed kernel unmap is harmless.
5. Corruption fixtures flip selected bytes; they are not exhaustive fault injection over every guard byte/status bit. Source inspection establishes the full-page byte loops. Normal/sanitized core receipts bind their source hashes; the frontend receipt binds its ELF, and its build record provides argv, but neither the frontend build record nor hold receipt records a full build-time source/dependency hash inventory. The hashes below bind **this review's current files**, not a retroactive native provenance claim.

## Bounded execution conclusion

Proceeding to the parent's already-planned native launcher/entry build and verification is consistent with this source verdict. Use the production lifetime implementation and strict startup, not the frontend mock executable. The next live scope remains one selected bank, two 4096-byte allocations, serial one-beat H2D then D2H, no retry/reset, no kernel launch, and no outstanding/held predecessor or competing descriptor producer. No new permission or renewed mapping/reset/FPGA/SDK audit is requested here.

Successful local retirement plus observed host data is a bounded test result. It does **not** prove whole-system drain, full DDR coverage, simultaneous-bank behavior, sustained throughput, universal physical visibility ordering, or that retaining a stopped process can prevent an independent FPGA/PCIe/host failure. The hold preserves buffers/WSIDs/FDs; it does not stop DMA or supply a reclamation/recovery sequence.

## SHA256 bindings measured during this review

### Host and test sources

```text
cdfaed0583b4e521ff492993eacab067b6f27f6f8e503382b3e5c487883d25c9  src/host/ahls_memory_dma_roundtrip.c
ed21d8a205bd8c1a0803f766a027fa11069379b6cb12b58ddbd36c6da25342c2  src/host/ahls_memory_dma_vfio_startup.c
4b039f9e6649aed655b7f7625ee869e3610073429c8289a3df38a56f38ead58b  src/host/ia840f_dma_transfer_core.c
baeaab8d6a226ffb26bd76a8a50342d863013bfbed09a16c34dab2a22f7ef567  src/host/ia840f_dma_transfer_core.h
3d34125b24e7d24c7399c930281526a069c65ffe6cfd61c2751760a0dcaaf2ae  src/host/ia840f_dma_lifetime.c
0f96cbe4589c000307c110bee8e6c69bf2df75f200e1b56c961a696689c3df5c  src/host/ia840f_dma_lifetime.h
ca1ca46f034753378a36a7481bfe68f5f28a0e923c3b14d5548240e9cdd53caa  src/host/ahls_memory_entry_vfio_strict.c
52e7ff9492d0432bfb1e55dceb4368720bbe17c994f6d49a60c67b660454ca74  src/host/ahls_qualification_core.c
fbd6e3c8999bfb803419309954c281a92c4326960d81cce8614305ba6195bf6f  src/host/ahls_qualification_core.h
908907f046da9ed16fe6d10e9433bd84e85807ea80be6882c568de35d34a4c49  src/host/ia840f_dma_capabilities.h
075465a069be7539aa61715cd99d0bd7463a04961c38b52cffaa22d417fb85ff  tests/ia840f/dma_host/mock_dma_opae.c
8ecb7bcef550368c46a9eceaedb7bc7ca16c604008b5dca7cd537e6a18e3be19  tests/ia840f/dma_host/test_dma_frontend.py
7fb2e4caf053c842b497350d54327a05e485122367c2e55d51f5c6fff754e920  tests/ia840f/dma_host/test_lifetime_hold.c
bd748e673cede092ac78fe30ccefb083d1cebb5d26fef66683b04dd974994ad5  qualification/caps01-dma-host01/test_dma_transfer_core.c
```

### Contracts, receipts and inert executables (paths relative to G)

```text
74b6ab2bd2f29ae51257e4e04aa8d3639f7bb9bc22a7944c8537794af0b2924d  REGISTER-CONTRACT01.md
948a2e6956cfb8823f30dd216fc44faf023825c0614b4943bd29af5700579ecd  BUFFER-LIFETIME01.md
98b0730113dc8ec1700bda35d76ec9403bfe60145dde6f03170fd7f871e06e32  normal-result01.json
e3e08d1c32c5193b01626e8c33e335e1d74c58c1cf965d090188aa22dff78213  sanitized-result01.json
809fe1c5789ec91af4b90ebc9212105671b9a4b0f797da55d506b329a8f74e6b  frontend-first-green02.json
11eaf3395df061e2364148364066d70c13e2b37691e58f6f694a0cb526e30aa1  frontend-tests02/result.json
3f66cfe0101fd741c77f49f624a4c0d50ac16af5a233f0f9f72dca3631727c35  hold-result03.json
24bcbdcb8acd953a02ea2c04640a3be2971ddfcb93b996b6cf68908121ff5547  frontend-green
c1a89551674200dd0a9ea53927247ae416ae4f5fa904d069e3a97458ac2f41e5  test-lifetime-hold
```

### Bound RTL cited for the register/retirement contract (relative to G)

Vendor source bodies remain local-only; hashes and source references below do not publish them.

```text
053b9855aa860c410337f5cae7e6160c6086726903cf988a1d35f032cb7a0b93  bound-rtl/csr_mgr.sv
4dcaedc0f35b2fbee172b971cedf14d434a0d8d95ef4179280a37dde1ac07806  bound-rtl/dma_axi_mm_mux.sv
c9a9ad5394e52d9d75ff46a50a0352da53dc8e5f57ee05a8d7afb92836357812  bound-rtl/dma_ddr_selector.sv
aa0668a1b3dd0e6553cd0d7673b2b040a615094493e8a0b747f76a0e562dba99  bound-rtl/dma_pkg.sv
3fc1937ad8268d0cfaf3453a85f8573a10aa1b98ae695deff62a89d772145a88  bound-rtl/dma_read_engine.sv
fb2d589ddd54a26ef9237eb7b38a490d0b5096b7b648b82dcba97462db7fe14b  bound-rtl/dma_write_engine.sv
```

The two retained backend sources narrowly consulted for successful-output and release semantics also match BUFFER-LIFETIME01's bindings:

```text
8ff7fde00206024f70108d37fd3ebfae9daddea5f3b23175b12bd7c5a63d2b6a  qualification/source-resume-01/remote/home/uwb_student00/opae-sdk/libraries/plugins/vfio/opae_vfio.c
9228499743db5e96fb9ceef4f38ca086840fee616af2d174b19098fc9a00baed  qualification/source-resume-01/remote/home/uwb_student00/opae-sdk/libraries/libopaevfio/opaevfio.c
```

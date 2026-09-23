# Independent CAPS01 memory-AFU frontend review

**Status: FINAL**

## Recommendation

**ACCEPT the frozen additive frontend and its completed inert OPAE matrices, within the offline source/API-contract boundary.** Specification: **PASS**. Implementation and completed-evidence quality: **PASS, with one nonblocking future-harness hardening observation below**. No candidate-blocking defect or required testcase rerun was found.

This is not native libopae/backend qualification, live-operation authorization, source-to-live-endpoint acceptance, or hardware signoff. The hardware goal remains incomplete; vendor DDR simulation is **SKIPPED BY USER**. Passing CLI flags or test results grant no permission.

## Review binding and method

Read `SCOPE.md`, then `RESULTS01.md`, then the frozen manifest before examining implementation/test quality. Independently rehashed the manifest and every member:

- `review-package01.json` SHA256: `3e8f181c16d05818d40f80a1962a151908e33b8f4d9064f44c5d2b05ff51b9b1`.
- **35 members, 1,474,346 member bytes, zero hash or size mismatches.** The byte total excludes the manifest itself.
- Frontend SHA256: `eb36fb35fb3e26087ba9d2bb59d02750a14f7c6fa7ad852378fc20dc268ede2b`.
- Accepted decoder and new installed source copy are byte-identical, SHA256 `908907f046da9ed16fe6d10e9433bd84e85807ea80be6882c568de35d34a4c49`.
- All seven historical host/core/offline-test paths in the RED receipt still match their recorded original hashes. This preserves the scalar path; it is not a newly executed scalar regression.

Performed local source/header reads, Python AST/JSON analysis, byte hashing, ELF byte inspection, and independent reduction of existing completed logs. No testcase, compiler, native/vendor tool, hardware-access executable, or device operation was run by this reviewer. No SSH, network, Git, implementation edit, or task transition was performed. The sibling `HOST-ACCESS-DELTA01.md` was neither read nor awaited. This report is the sole written artifact.

Paths below are relative to the project root unless stated otherwise. Build `flags.make`/`link.txt` are supplementary local reads, not additional frozen manifest members. The two existing ELF files are bound through the binary hashes in the frozen GREEN receipts; they were read as bytes, never executed or dynamically loaded.

## 1. Specification review — PASS

### 1.1 Identity and register contract

The new program is additive and does not replace the scalar frontend. Its identity is the current memory AFU UUID **`673c03a1-cef3-4c82-bf10-b12c247d9718`**, not the historical scalar UUID. Independently checked the UUID's low/high split against the frozen AFU JSON and generated header. The CSR source assigns the matching full DFH and low/high UUID words (`qualification/dma-csr-metadata01/csr_mgr-candidate01.sv:71–80`). The following is the exact successful read contract:

| Order | AFU-relative byte offset | Expected 64-bit word |
|---|---|---|
| DFH | `0x00` | `0x1000010000000000` |
| UUID low | `0x08` | `0xbf10b12c247d9718` |
| UUID high | `0x10` | `0x673c03a1cef34c82` |
| Raw ABI identity/version | `0x98` | `0x49413834444d0001` |
| Geometry | `0xa0` | `0x0002001000200200` |
| Address/beat widths | `0xa8` | `0x0008004014393922` |
| Admission limits | `0xb0` | `0x000000060001ff00` |

All accesses are aligned `fpgaReadMMIO64` calls on **OPAE window 0**. Identity words are checked individually before any capability read. Each API failure stops the operational sequence immediately. An identity mismatch stops at that identity word. The capability record is deliberately collected as four words and then decoded: a bad first capability word therefore still produces all four capability reads before rejection, not an early per-field rejection. This is consistent with reuse of the accepted whole-record decoder and is reflected honestly in the test expectations.

The raw layout agrees with `ABI01.md:15–35`, the accepted decoder, and the CSR packing/decode (`csr_mgr-candidate01.sv:88–110,178–179,321–349`). Independently recomputed the packed words and maximum: 512 data bits, 64-byte beats, 32 configured data-FIFO beats, 16 descriptor entries, two banks, 34 bank-local address bits, 57 host/common descriptor-address bits, 20 length bits, 8 AXI LEN bits, mode mask 6, and maximum 130816 admitted beats. The latter follows `((1 << (8 + 1)) - 1) * (1 << 8)`; it is not an exercised transfer length.

The decoder checks the exact version/tag, reserved top byte, and every field, so unknown or changed geometry fails closed. It neither guesses legacy compact encodings nor uses the legacy hardcoded clock/status words. Its prior acceptance is explicitly bounded in `qualification/dma-csr-metadata01/UNIT-ACCEPTANCE.md`; no new decoder regression is needed merely because an identical header is reused.

### 1.2 Discovery and input restrictions

`src/host/ahls_memory_inspect.c:44–71` requires exactly the new option and one strictly parsed `dddd:bb:dd.f`. The original generic parser (`ahls_qualification_core.c:22–36`) enforces width, separators, hexadecimal characters, device range and function range. The new code passes the parsed segment/bus/device/function to OPAE rather than hardcoding the fixture BDF.

The single properties object contains all ten restrictions: accelerator object type, current GUID, segment, bus, device, function, vendor `8086`, device `bccf`, subsystem vendor `8086`, and subsystem device `1771`. There is exactly one enumeration call, with one filter and capacity for one token; it separately requires the returned **total match count** to equal one. This correctly rejects multiple matches despite a one-token output capacity, consistent with captured `opae/enum.h:53–91`. The returned token is still destroyed on multiple-match or modeled partial-error enumeration paths. There is no second discovery pass, alternate BDF, fallback BAR, or retry.

The only valid BDF exercised dynamically is synthetic `0000:ab:1f.7`. This is not a live card address or proof of arbitrary-BDF runtime coverage; source inspection establishes that the generic parser's outputs are actually used.

### 1.3 Operational boundary and cleanup

The frontend invokes no MMIO write, reset, DMA-buffer operation, kernel start, finish/status poll, raw-BAR access, or alternate read width. The old scalar execution/identity functions remain compiled in the shared generic core but are not called by this new frontend; only the parser and unique-match helper are reused.

Every result-bearing OPAE call is checked. Acquired properties/token/handle state is initialized to NULL, and the mapping flag is set only after map success. Cleanup attempts unmap, close, destroy token, and destroy properties as applicable; a failed destructor does not suppress subsequent cleanup and makes the process fail. There is no destructor retry. A success message is emitted only after successful cleanup (`ahls_memory_inspect.c:93–110`).

The captured MMIO header permits the NULL pointer argument to `fpgaMapMMIO`; the program uses API reads rather than a returned raw pointer (`opae/mmio.h:160–183`). The fixture's map/resource bit is an API-contract model, not evidence about real page mappings or backend close/reset effects. The source comments and scope correctly retain this distinction.

## 2. Implementation and completed-test quality — PASS within scope

### 2.1 Actual RED/GREEN evidence

The RED receipt builds the unchanged `ahls_opae_qualification.c` with the new inert fixture. Its only process returns **2** on the unsupported new option, before any API call; the Python expected-success assertion fails and CTest returns **8**. This demonstrates absence of the new operation, not an RTL, arithmetic, or hardware failure. The documented pre-execution tool serialization error is not counted as a test result.

Both GREEN receipts show successful local GCC **14.2.0** CMake configuration/build and CTest execution. The build requests C standard 11; the actual generated dialect is precisely **`-std=gnu11`**, with `-O0` or `-O2`, `-Wall -Wextra -Werror -pedantic -UNDEBUG -fsanitize=undefined -fno-sanitize-recover=all`. Link commands contain the new frontend, inert mock, and unchanged generic core, with UBSan and no OPAE link library. No warning/error output appears in the saved successful build receipts.

Independent reduction of the complete JSON records, rather than reliance on the pass banner or parent summary, yielded:

| Case class | O0 | O2 |
|---|---:|---:|
| Exact success | 1 | 1 |
| Individual successful-path API failpoints | 25 | 25 |
| Individual bit faults, seven words × 64 bits | 448 | 448 |
| Zero/multiple/partial-error enumeration | 3 | 3 |
| Invalid argument vectors | 12 | 12 |
| **Total process records** | **489** | **489** |

There are **978 GREEN process records** overall. Every matrix has unique case keys, every failpoint 1–25 exactly once, every `(word, bit)` pair exactly once, and the exact twelve specified invalid argument vectors. O0 and O2 records are semantically identical after normalizing only executable paths.

For **every record**, independently checked return code, complete numbered API sequence, attempted read-offset prefix, pass-message eligibility, and resource/call summary. Identity-fault diagnostics contain the exact expected single-bit-corrupted value. Capability faults report decoder rejection. No recorded sanitizer/assertion diagnostic was accepted as an expected failure.

The successful sequence is properties creation, ten setters, one enumeration, one open, one map, seven reads, then four cleanup calls. For operational failures, cleanup releases all previously acquired modeled resources. For destructor failpoints 22–25, only the deliberately failed resource remains (masks 8/4/2/1 respectively); later cleanup is still attempted. Enumeration rejection never reaches open/map/read. Invalid arguments have no API/summary output and return 2. All other negative cases return 1, not a crash or an accidental pass.

### 2.2 Fixture isolation and test strength

The C mock is compiled against the seven frozen captured installed OPAE headers, not replacement prototypes. It checks concrete filter values, handle/resource ownership, window number, alignment and read order, and it traps MMIO writes. Its operational-failure guard allows cleanup but rejects further operations; its exit invariant is `live == failed_cleanup`, not a blanket exemption for failed tests (`mock_memory_opae.c:21–37`). The fixture's filter counter alone is not a full setter-order oracle, so the independent full-sequence reduction above matters: it verifies the actual named setters and their order in the completed evidence.

Direct Python inspection of both retained ELF byte streams matched the frozen receipt hashes:

- O0: `505d7cd854a1d521af7584e6626be2e99e3a5760c5871ef957e0eb2efe53f328`.
- O2: `7e826ebff63c248d95ebae9919ef054f1d1e3f186f1132017c1c8d296f7e5087`.

Their `DT_NEEDED` entries are exactly **`libubsan.so.1` and `libc.so.6`**. Every frontend `fpga*` call resolves to a definition in its executable; there are no undefined `fpga*` symbols. The fixture's `fpgaWriteMMIO64` symbol is a rejecting stub, not a frontend write path. This corroborates the recorded readelf/nm evidence without launching either ELF. It does not qualify a real libopae link or backend initialization.

The single-fault matrix is strong evidence for this finite frontend, not exhaustive fault combinations, arbitrary partial allocations by real plugins, or physical resource reclamation. These are scope limits, not reasons to rerun unchanged accepted scalar tests or invent a broader framework.

### 2.3 Nonblocking observation: Python optimization guard

`tests/ia840f/memory_host/test_memory_frontend.py:5` uses **`assert __debug__`**. This does not protect the harness from `python -O`/`PYTHONOPTIMIZE`: the guard itself and the other Python assertions are removed under optimization. CMake invokes Python with `-B`, which controls bytecode-file writing, not assertion optimization. Thus the harness's PASS banner should not, by itself, be treated as fail-closed under an arbitrary future Python environment.

**Disposition: nonblocking for this frozen completed evidence.** The preserved RED traceback proves the expected assertion operated in RED; the two complete GREEN matrices have now been checked independently record-by-record, including actual failures, outputs and cleanup. No GREEN result is being accepted solely because of a removable Python assertion or its summary banner. A small future harness hardening would replace the guard with an ordinary `if not __debug__: raise ...` check, but this review does not edit frozen inputs, demand a rerun, or turn that improvement into a new acceptance/permission gate. The C fixture separately has `-UNDEBUG` and retained assertion symbols.

## 3. Unwaived limits and final disposition

The UUID/DFH/capability agreement is a source-bound expected-response contract, not proof that a live endpoint serves those words, image authentication, or source-to-host route acceptance. Token filters do not isolate every backend's initialization/prefilter activity. Real OPAE linking/execution, live BDF/BAR/image identity, source mapping, clock/reset state, backend open/close/kernel/reset behavior, device binding, IOMMU, exclusive ownership, applicable permissions and independent recovery remain separately unresolved. No process timeout here establishes containment of hung MMIO or workstation safety.

No numerical AHLS result, physical DDR bank operation, DMA transfer, maximum-length transfer, completion/drain/fence property, buffer lifetime, lifecycle recovery, PR, durable boot, or full design closure is established. Legacy metadata limitations are unchanged. The separate source-map work is not consumed by this review.

**FINAL: bounded acceptance of the exact additive source and completed inert matrices; no candidate blocker, no new generic gate, and no required rerun solely for completeness.** Parent retains execution responsibility. No hardware-route acceptance or hardware access is authorized by this report.

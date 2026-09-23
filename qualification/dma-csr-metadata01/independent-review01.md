# Independent review — IA840F raw-capability ABI v1

Status: **FINAL**. This replaces the early **IN_PROGRESS** checkpoint at this path.

## 1. Specification verdict — reviewed first

**Specification: PASS for the exact additive candidate. Quality: PASS for the completed native RED/GREEN CSR differential and offline C decoder evidence, with the bounded findings below. No blocking candidate defect or required additional regression was identified for this change.** Recommend accepting this narrow source/interface correction and these completed functional results, not the hardware goal or changed physical implementation.

Read `ABI01.md`, `RESULTS01.md`, then `raw-capabilities01.patch` before inspecting implementation and test quality. The source baseline is the accepted CSR02 continuous-endpoint implementation, SHA256 `42d09ffffb91152b9f688014bcff9ffc13e5382cddd7f478e5f9b992da232a77`. Candidate SHA256 is `053b9855aa860c410337f5cae7e6160c6086726903cf988a1d35f032cb7a0b93`.

This fits **ordinary goal-approved host-interface correction**, not an architecture replacement: it exposes explicit read-only facts about existing DMA geometry/admission, preserves existing functions and controls, and adopts neither the AI runtime nor the older oneAPI MMD contract. `GOAL-PROMPT.md:18–23,52–63,266–277` permits ordinary source-side correction while separating live operations and excluding adoption of the AI runtime. This review does not grant execution authority or create a new gate for the parent's separately running synthesis.

**Not accepted:** new synthesis, fit, final STA/timing, mapped equivalence, live PF/VF/BAR routing, deployed image identity, physical DDR/PCIe/OPAE, numerical hardware results, frequency, global drain, posted-write fences, cancellation, reset/CDC/PR safety, or host-buffer lifetime. FullDesignClosure remains **FAIL** and the hardware goal remains incomplete. Vendor DDR simulation remains **SKIPPED BY USER**. Prior CSR02 physical evidence does not automatically qualify the changed persona.

### Citation convention and method

- `N` = `/home/joe/Projects/Thesis/AHLS/new_bsp/new`.
- Unprefixed files are in `N/qualification/dma-csr-metadata01` (`M`). `TB` means `csr_capability_diff01_tb.sv`; `CSR` means `csr_mgr-candidate01.sv`.
- `SETUP` = `N/qualification/ahls-persona-work21-caps01`; `SRC:<file>:<line>` means the decoded literal `C['files']['afu/<file>']` in `SETUP/run-setup01.py`.
- `UNIT:<file>:<line>` means decoded `C['sources'][<file>]` in `run-green01.py`. Relevant DMA bodies match SETUP byte-for-byte.
- `REDLOG` and `GREENLOG` refer to the exact embedded `logs['vsim.log']['text']` in the corresponding result JSON; line numbers count those decoded texts.
- `G` = `N/qualification/ahls-memory-dma-core01/artifacts-fabric01/ip/ahls_memory_dma_fabric/ahls_memory_dma_fabric_fabric`.

Inspection was local byte hashing, AST/literal/base64/gzip decoding, source/patch comparison, ELF metadata parsing and arithmetic. No runner was imported or executed. No test executable, compiler, vendor tool, simulator, SSH/network, device operation, Git command, mutable CURRENT content, current synthesis result, or task transition was used. Only this report was authored. Historical tool preservation/termination is established from the bound receipts and inspected runner logic, not a fresh remote process check.

## 2. ABI and source compliance

### Exact layout and derivation

| AFU/DMA-relative byte offset | Independently recomputed value | Meaning |
|---|---|---|
| `0x98` | `49413834444d0001` | Exact tag/version, ABI1 |
| `0xa0` | `0002001000200200` | 2 banks, 16 descriptor FIFO entries, 32 configured data FIFO beats, 512 data bits |
| `0xa8` | `0008004014393922` | Reserved high byte zero; AXI LEN8, beat bytes64, length20, common descriptor address57, host byte address57, bank-local byte address34 |
| `0xb0` | `000000060001ff00` | Mode mask6 (accepted modes1/2), maximum admitted full beats130816 |

The RTL packing at `CSR:88–112` matches the ABI table and host extraction exactly. Geometry follows `UNIT:dma_pkg.sv:27–37,104–138`: raw FIFO depths, generated-PIM-derived bank/data/address geometry, length20, AXI LEN8, and the actual enum values HOST_TO_DDR=1 / DDR_TO_HOST=2. The stale reversed direction prose inside the legacy descriptor type is not used to infer the mode mask. `UNIT:dma_engine.sv:71–74` and `UNIT:dma_top.sv:108–111` instantiate the corresponding configured FIFO depths.

The limit is `(2^(8+1)-1) * 2^8 = 130816`, matching the existing admission constant, not the larger range of a 20-bit length field. The request/last/response accounting uses AXI_LEN_W+1-bit counters (`UNIT:dma_read_engine.sv:94–97,174–175`; `UNIT:dma_write_engine.sv:81–89,200`). This is an **admission ceiling**, not proof that a maximum-length data transfer has run successfully. Configured FIFO depth is not total buffering; addressable bank geometry is not physical wiring or installed-memory qualification.

The elaboration guard checks the listed field upper bounds, equal source/destination descriptor widths and the 32-bit limit before accepting this encoding (`CSR:106–112`). The bound values are representable. The actual top also rejects incompatible PIM geometry (`SRC:ofs_plat_afu.sv:57–67`). This review does not promote the guard to a general-purpose parameter-validity proof or claim that negative elaboration branches were exercised; arbitrary retargeting is outside the exact-target ABI.

### Additive change, unchanged legacy behavior

An independently generated unified diff is byte-identical to `raw-capabilities01.patch`. The only CSR changes are new constants/representability guard, extension of the shared address-range helper, and four read cases. No existing function is removed. Continuous endpoint registers/arithmetic, freshness, descriptor validation, GO service, write data/state, and response scheduling are unchanged.

The shared helper also participates in write admission, but **effective write eligibility is unchanged**: `csr_writable` remains the same five exact old addresses (`CSR:119–125,178–200`). New addresses cannot pass that conjunction; they produce DECERR rather than SLVERR and cannot update CSR state. For reads, alignment and size3 are checked before narrowing `ar.addr[7:3]`; full received-address comparison prevents high-address aliasing (`CSR:119–120,178–179,315–349`). The four added indices19–22 were outside the old maximum18. Old indices0–18 still dispatch to exactly the same data assignments.

The legacy defects are intentionally retained, **not repaired or newly validated**: raw512 narrows into3 bits to0; raw32 narrows into4 bits to0; config2 still hardcodes400; aggregate status is150 bits narrowed to64 (`CSR:218–259,336`; `UNIT:dma_pkg.sv:176–198,225–249`). This is consistent with the frozen prior synthesis review's Q4. A host must not treat those old fields as repaired capability metadata, clock measurement, or lifecycle guarantees.

Comparing the current SETUP literal with the hash-bound preceding CSR02 setup literal confirms exactly one changed AFU payload, `afu/csr_mgr.sv`, and **12 unchanged other AFU payloads**. Both generated inventories contain **255 identical records**, and the release inventories are equal. No memory datapath, kernel, guard, bank shim, or fabric-source change is hidden in this candidate. This is source/inventory preservation, not a fresh remote rehash of every generated file.

### Source routing, not live reachability

`SRC:ofs_plat_afu.sv:18–38,79–110` retains the full20-bit MMIO address into the existing guard; `SRC:ia840f_ahls_mmio_guard.sv:35–36` forwards the fabric range below `0x10100`. All four new offsets are within its DMA portion. Generated read/write routers `G/altera_merlin_router_1921/synth/*_bknbsua.sv` and `*_pleb25y.sv:162–174,214–223` decode `[0,0x10000)` to DMA and `[0x10000,0x10100)` to the kernel. Their optimized low17-bit decode is **not** a standalone high-address guard; the upstream guard remains necessary and unchanged.

Those two captured router bodies and `G/altera_mm_interconnect_1920/synth/*_7cfzhiy.v` were rehashed against SETUP's generated inventory; the interconnect instantiates the write/read routers at1506/1522. `SRC:ia840f_ahls_memory_core.sv:178–185,279–309,488–489` connects the16-bit DMA CSR export to actual `dma_top`. Thus no source-side aperture expansion is needed for these offsets. The unit fixture is not this complete routed fabric, and none of this identifies a live PF, VF, BAR or safe running-device access sequence.

### No invented donor encoding

The saved public AI donor tree has exact pin `e0e07f7b1878a477dc4d1191918db8430193e148`, **1284 entries**, and `truncated=false`. Inspection found only three generated `fpga_arch_instantiator.h` C/C++-family entries, no runtime C/C++ DMA decoder or software/runtime subtree. This bounds the claim to that captured public tree, not private SDK software.

Retained OFS `examples-afu/tutorial/afu_types/01_pim_ifc/dma/sw/dma.c:184–188` reads and prints config1/config2 without decoding the disputed fields. Its `dma.h:25–29` retains the old indices. Older `oneapi-asp/common/source/host/mmd_dma.cpp:64–84` instead uses directional CSR bases at DFH+0x80/0x100 and source/destination/length offsets0/8/0x10. Neither supplies an encoding contract for this donor's truncated raw geometry. A separately tagged additive raw ABI is justified; no log2 interpretation was invented.

## 3. Native RED/GREEN evidence and fixture quality

### Binding and outcomes

Independently verified the frozen manifest SHA256:

`0b72641bb90d51ed3582230ea2d5ab9120aa9f6cf147ada0867ee736b06155fd`

All **31 members / 3411284 bytes** match declared sizes and hashes. Each native runner's literal configuration was decoded inertly. Removing only its C assignment reproduces `run-capability01.py.in` exactly. Dispatch embedded-runner hashes match; outer result receipts match actual JSON sizes/hashes. Full outer dispatch wrapper bodies are not package members, so their `script_sha256` values remain receipt metadata rather than independently reconstructed scripts.

Each run binds **27 source payloads**: all hashes verified, **3 declared lengths verified / 24 inherited lengths derived**, not falsely counted as declared. All **5 embedded logs per run** round-trip to their exact size/hash. These are payload inventories, not claims that27 source files were compiled: the native vlog command names the platform/interface/packages, two CSRs and the differential fixture, not a running DMA memory datapath.

RED and GREEN have the **same fixture bytes**, baseline module renamed only for co-instantiation, and identical source payloads except candidate `csr_mgr.sv`. RED's candidate slot equals unchanged CSR02; GREEN's equals the new candidate. Apart from source data, only the run identifier changes in their configurations.

| Run | Native/effective stages | Functional result / outer | Native log evidence |
|---|---|---|---|
| RED | version/vlib/vdir/vlog/vsim all0/0 | `unit_pass=false`; outer1 | First new read0x98, then expected fatal at cycle8450/test307, `new capability absent or legacy response changed`; `REDLOG:6063–6070` |
| GREEN | version/vlib/vdir/vlog/vsim all0/0 | `unit_pass=true`; outer0 | One exact pass scoreboard; no diagnostic errors; `GREENLOG:6391–6395` |

**RED vsim0 is not a pass.** The runner scans fatal/error text and requires the pass scoreboard; its functional rejection produces outer1 even though the native process returns0 (`run-capability01.py.in:103–123`). The fatal remains preserved. Both runs record completed execution, all original/input/tool preservation flags true, no timeout and no surviving owned group. Native version is Questa Intel FPGA Edition2024.3. These are completed unit runs, not inferred outcomes from shell dispatch.

GREEN's exact scoreboard is **311 cases, 1536 writes, 51 reads, 85 enqueues, 226 endpoint-check events, 674 minimum-gap events, 138 B-stall observations, 255 R-stall observations, 251 resets, 8955 cycles, 58635 checks, 16 capability reads**. Endpoint events each perform two assertions; min_gap counts observed three-cycle service gaps, not674 cycles of latency. The311 count is the retained GO-oriented scenario counter, not311 independent metadata cases.

### Differential comparison is narrowly masked

`TB:38–65` masks only aligned size3 reads of the four exact new words. Even there it requires candidate OKAY/expected data, baseline DECERR/zero, and identical ID/USER. Ready/valid timing remains cycle-equal. All other valid read responses and all valid B responses are compared packed; architectural maps `cm/rm` and freshness remain equal before and after clocked updates. The request register remains associated with the held response because the CSR serializes reads, so the mask is not based on a changing external address.

`TB:70–91,99–145` checks held packed R/B stability, request metadata, watchdogs, accepted-write/GO ownership and endpoint freshness. `TB:227–279` retains field-order, direction/bank, validity transitions, split AW/W, malformed controls, legacy reads and invalid accesses. `TB:280–295` reads all four words in idle, synthetic busy, synthetic read-error and synthetic write-error states, with held R; rejects new-address writes, split/partial/wrong-size writes, unaligned/wrong-size reads and +0x100 read aliases. `TB:296–307` retains AW-only, W-only, held-B and post-commit reset phases.

The public status and platform constants are explicitly **synthetic**. A staged descriptor plus busy/error input is not a real FIFO entry or PCIe transaction. The assertion of16 capability reads makes missing metadata phases fail the fixture. The exact source delta plus this focused native regression is proportionate; no new framework, exhaustive formal proof, changed maximum-length transfer test, or redundant memory-path rerun is required to accept this constant/read-decode-only change.

## 4. Offline C decoder and test evidence

`ia840f_dma_capabilities.h:26–52` is a pure scalar decoder: it checks pointers, exact tag/version and reserved high byte, extracts all fields with fixed-width unsigned shifts/casts, rejects anything outside the exact qualified geometry/modes/limit, then performs its only output assignment. It makes no MMIO/OPAE call and leaves output bytes untouched on rejection. It is deliberately not a permissive decoder for future boards. A valid record does not authenticate an image or recover a failed MMIO/API call; the caller must check every supported API return separately.

`capabilities_test.c:8–35` supplies the independent expected words, accepts the good record, flips each of all256 bits individually, requires rejection with byte-preserved sentinel output, and checks both null-argument cases. This mutation sweep is not exhaustive arbitrary-input execution, but source inspection shows the fixed-field checks cover every input bit: exact word0, all geometry fields, all address fields plus reserved bits, and both limit/mode halves. No actual false acceptance, output corruption or undefined arithmetic was found.

The two `host-test-results01.json` records bind the exact header/test and saved executable hashes. Both compile/run statuses are0, compiler stdout/stderr and run stderr are empty, and each stdout reports `valid=1 bit_mutations_rejected=256 null_checks=2`. Recorded commands use C11, `-O0` / `-O2`, `-Wall -Wextra -Wconversion -Werror -pedantic -UNDEBUG -fsanitize=undefined -fno-sanitize-recover=all`; assertions are not compiled out.

Read-only ELF parsing independently confirms both binaries' `.comment` is `GCC: (Debian 14.2.0-19) 14.2.0` and their only direct DT_NEEDED entries are `libubsan.so.1` and `libc.so.6`, matching the retained dynamic-section evidence. Neither binary was executed during review. These source/dependency/result records support pure offline data tests, not enumeration, host-I/O or transitive-runtime auditing.

## 5. Findings, minimum action and final scope

1. **No blocking defect in this exact additive ABI, implementation or completed regression.** Recommend narrow acceptance without additional source edits or mandatory reruns. Retain the existing RED/GREEN fixture and strict decoder tests for any later change to these constants, layout, access predicates or output validation. A future geometry/ABI retarget needs its own bound values and regression; that is not a missing test for the present target.
2. **Nonblocking diagnostic-accounting clarification:** `RESULTS01.md:8` accurately says native *simulation* has0 errors/2 warnings, both vopt-13314 at candidate/baseline status ports. Each run also has **vlog0 errors/4 warning occurrences**, vlog-13314 at the same two ports, each printed twice (`vlog.log:15,19,20,23,29`). Do not summarize the whole compile/sim attempt as having only two warning occurrences. No suppression flag was added, and no candidate-specific port-kind defect is demonstrated.
3. **Retained legacy ABI defects are not closed.** Zero-valued narrowed width/depth fields, hardcoded400 clock metadata and150-to64 status narrowing remain. Only a new explicit capability path is supplied; no legacy decoder migration or installed runtime adoption is claimed. Existing control/status still supplies no drain/fence/reset/buffer-release contract.
4. **Evidence boundaries remain operative, not new blockers for this unit change.** Directed CSR equivalence, synthetic status, read-only geometry, historical preservation flags and offline decoder results do not establish physical data movement, maximum transfer operation, source-to-host live routing, reset/CDC/PR correctness, measured frequency or timing closure. Leave broader signoff/hardware limits open.
5. **SETUP is provenance only.** Its compressed result and outer receipt match; both native/effective stages return0, outer0, seven exports verify and the inventory contains4925 entries, with preservation/UUID checks true. This establishes actual Work21-derived setup and exact candidate source binding, not mapped synthesis or hardware success. Current synthesis was not inspected, polled, modified or used for this verdict.

The frozen documents' launch-time “review pending” wording is historical; this FINAL supplies the independent review disposition without rewriting them. Parent evidence acceptance and all broader task/closure transitions remain parent-owned.

### Supplemental source bindings

Outside the31-member manifest, the preceding CSR02 `run-setup01.py` was read only after matching its prior frozen review's SHA256 `b62715fc3cb71f1abe6392228f36eec80a617b3da6cd3825fb1fa4a20f91feb7`; this enabled the exact13-source/255-generated-record comparison. The three locally captured generated routing/interconnect bodies match current SETUP inventory hashes `48aae72152e179b517cc3cfba0b4ee9d896f6b0ef6c9455b1239f04663eb78c3`, `a9c084447266fe7fc7faf565cd73ad29c15de5e463de98defe45e24885a70b40`, and `8e8fe7de8b2961f2d8d5b3a411c3a2071f34123a5bfbd0985510d6ae361ed3a0`, respectively. The goal document read for authority/safety context hashes to `f13822c1965960a4702b8c946ecaa892ab73c33a2cc918c1f4bbfeb0449def29`. These supplemental reads do not enlarge the accepted result scope.

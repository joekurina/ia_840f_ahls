# Independent code-quality and integration review 01

## Verdict

**APPROVED for the reviewed offline milestone.** No critical or important defect was found in the additive host implementation, its offline integration, the UART diagnosis, or the staged successor02 udev policy. Two nonblocking test-hardening findings are listed below.

The separately supplied OPAE backend-binding supplement passes the bounded local evidence-consistency review described below. Neither approval authorizes native execution or closes the hardware mission, timing, UART implementation, udev activation, or complete backend-access/provenance gates.

All paths are relative to `/home/joe/Projects/Thesis/AHLS/new_bsp/new` unless otherwise stated.

## Prioritized findings

### Critical

None identified within the reviewed scope.

### Important

None identified within the reviewed scope. The known native initialization/enumeration footprint and transitive dependency limitations remain blockers for a future native operation, not defects requiring rejection of this offline milestone.

### Minor Q1 — injected failures disable resource-cleanup assertions

**Locations:** `tests/ia840f/offline/mock_opae.c:18–29,37,57–61`; `tests/ia840f/offline/test_opae_frontend.py:18–21`.

`verify_exit()` checks that properties, tokens, handles and mappings have been released only when `failed` is false. Every injected API failure sets that flag, including failures in ordinary operations before cleanup. Consequently, the injection suite verifies failure status and prohibits subsequent non-cleanup API calls, but does not require all applicable cleanup calls to occur after a failure. The Python driver only requires exit code 1 and `failure_injected=1` for those runs.

A future regression that skips cleanup specifically after an injected operational failure could therefore remain green. This is a coverage gap, not an observed leak: the current frontend's `src/host/ahls_opae_qualification.c:92–98` independently attempts all applicable cleanup operations and retains failure status when a destructor fails.

**Recommended follow-up:** track acquired resources and attempted releases separately. After an operational failure, require release of every acquired resource; after a deliberately failing destructor, permit only that failed release to remain unresolved while requiring all later applicable cleanup attempts. Include a failure-path assertion for cleanup order and no resumed work. Do not introduce retries to satisfy the test.

### Minor Q2 — Python optimization can silently remove frontend test checks

**Locations:** `tests/ia840f/offline/test_opae_frontend.py:12–24`; `tests/ia840f/offline/CMakeLists.txt:20–21`.

The process-result checks use Python `assert`. CTest launches the script with `-B`, which prevents bytecode-file writes but does not disable an inherited `PYTHONOPTIMIZE` setting. Under optimization, the runner still launches subprocesses and prints its JSON, but loses the assertions rejecting incorrect return codes, missing injection evidence and malformed-BDF behavior. Thus some regressions could be reported as a successful CTest invocation in an optimized Python environment.

Independently compiling the inspected script to in-memory Python code objects found seven top-level `LOAD_ASSERTION_ERROR` instructions at optimization level 0 and none at level 1. The runner itself and its C subprocesses were not executed by that check.

**Recommended follow-up:** use explicit conditional exceptions or unittest assertions for acceptance checks, or explicitly reject optimized execution and isolate the interpreter from `PYTHONOPTIMIZE`. The C fixtures already preserve assertions using `-UNDEBUG`; the corresponding Python safeguard is missing. This does not invalidate the inspected retained receipts or the source review.

## Implementation and integration assessment

### Additive host core and frontend

- **Defined arithmetic:** `src/host/ahls_qualification_core.c:39–51` checks each signed32 addition/subtraction term before multiplying with int64 intermediates, then checks the product before narrowing. The uint32 XOR produces the required bit pattern without signed-overflow dependence. This agrees with `qualification/ahls-compile-01/src/qual_vec_op.cpp:31–49`. Independently recomputed all twelve source cases and matched both fixture answer tables: `0x8, 0x10, 0x30, 0x30, 0x0, 0xfffffff0, 0x700, 0xff00, 0x0, 0x0, 0x10, 0x8`.
- **Strict BDF handling:** `ahls_qualification_core.c:22–36` requires exact length and separators, checks hexadecimal characters with the unsigned-char ctype conversion, bounds device/function, and assigns outputs only after validation. Fixed field widths bound segment/bus conversion. The frontend requires the explicit command form and supplies accelerator type, GUID, domain/bus/device/function, vendor and device filters (`ahls_opae_qualification.c:54–75`). Enumeration errors and zero/multiple matches do not reach application open/map/MMIO. This is application-level filtering, not process-wide backend isolation.
- **Finite register sequence:** `ahls_qualification_core.h:5–7` and `.c:60–120` use the documented aligned whitelist. The core checks identity, idle CSR v5, bounded stale finish count and a cleared baseline; writes packed arguments/mode and one start; accepts exactly one new completion; then checks idle and the whole zero-padded result. There is no 0x74 access, address sweep, speculative reset or retry.
- **Bounded polling and failures:** `.c:87–120` rejects zero/excessive timeout values, callback failures, backward time, stale/multiple completions and numerical mismatches. The operation ceiling terminates polling even when the supplied clock stalls. Short-circuit argument writes stop at the first failure. A callback or hardware transaction that never returns cannot be bounded by this software loop; the access map states that limitation rather than claiming containment.
- **Generated RTL reconciliation:** directly inspected `qualification/source-resume-01/remote/home/uwb_student00/ahls/new_BSP/work_ia840f_fim_13/syn/board/ia840f/syn_top/afu_with_pim/afu/hw/ahls_ip/qual_vec_op.report.prj/kernel_hdl/IDQualVecOp/IDQualVecOp_function_cra_agent.sv:384–485,523–552`. The two-bit clear-on-read finish counter and zero-padded result agree with the core. `afu/ahls/rtl/ahls_mmio_aperture.sv:25–44,73–84` supports rebasing and identity. No new HDL simulation was needed or performed.
- **Cleanup:** frontend resources start null, the mapping flag is set only after successful mapping, and cleanup is conditional and ordered. Each cleanup failure sets a failing exit status without suppressing later cleanup attempts (`ahls_opae_qualification.c:47–49,75,92–100`). This does not qualify native backend close/reset consequences.
- **Build separation:** `tests/ia840f/offline/CMakeLists.txt:6–31` keeps the core device-independent, links the actual frontend to local mock API symbols for the inert target, and leaves the native frontend OFF by default and outside CTest registration. Inspected the saved generated link/test files and `mock-elf-needed.txt`; the mock linkage lists only libc as a dynamic dependency. Warning-as-error flags and enabled C assertions are explicit.

### Udev successor02

`qualification/dfl-udev-fix-02/90-intel-fpga-opencl.rules.candidate:4,15–19` selects the exact snapshot PF0 BDF and four PCI IDs conjunctively, skips the old actions only for the target, and applies root:root 0600 to FME and root:uwb_student00 0660 to port. `test_rule.py:64–72` places all ancestor predicates on one parent. The collision/split-parent tests and original-byte comparison are pertinent to the actual selector and fallback.

The byte-preserved unrelated 0666/RUN fallback is intentional minimal-scope preservation, not a new grant and not a broad security repair. The evaluator stores RUN strings as data and never executes them. `check_access()` remains an external per-event fixture model; `spec-response01.md:12–30` explicitly leaves native required-node detection and acceptance UNVERIFIED. No activation or native udev behavior is accepted here.

### UART diagnosis and checkpoint integration

`qualification/dfl-uart-fix-01/test_contract.py:39–80` tests the retained disabled-UART/dummy-advertisement diagnosis and the separately enabled metadata contract. Direct inspection of the captured `drivers/tty/serial/8250/8250_dfl.c:35–105,118–136` corroborates the required one-u64 clock/FIFO/layout parameters and failure before registration. The report clearly identifies diagnosis-only scope; no driver or RTL fix is implied.

The current additions in `README.md`, `docs/feature-matrix.md` and `plan.md` distinguish offline tests/native compile-link evidence from live BLOCKED/NOT RUN gates and preserve skipped DDR simulation as skipped. The old `src/host/ahls_mmio_test.c` is unchanged relative to HEAD; the new implementation is additive.

## Review binding and verification

### Original milestone

- Read `spec-review02.md` and `spec-response01.md` before evaluating scope.
- Independently verified all **247** `spec-input-manifest01.json` entries for SHA256 and size, including rechecks after the supplemental review: **zero mismatches**. Manifest SHA256: `7abbdfa2047b5b3e3d926334ae52152bbec3d2d2dc52ffc1d57de0e005c5f49d`.
- Additional review-input hashes: `spec-review02.md` = `408a25d0fa723e45ea98da246aa28827408dc398ae0ca104eda594abd1911a94`; `spec-response01.md` = `36941b7b91df71abcd2aa199e35207e63acc43cab651beb44da32706ba651c4d`.
- Fresh execution, using only the inspected inert scripts: `python3 -B qualification/dfl-udev-fix-02/test_rule.py` **21/21 PASS**, then `python3 -B qualification/dfl-uart-fix-01/test_contract.py` **12/12 PASS**; combined exit status 0. These scripts read captured ordinary files, not live device/sysfs paths.
- Inspected retained `qualification/ahls-host-offline-01/run-03-step-2.json`: **CTest 2/2 PASS**. Independently parsed all **160** frontend process records and confirmed **151** contiguous injected API-failure indices with exit code 1, the expected positive/negative scenarios, and four malformed-BDF exits. **Neither C executable nor CTest was rerun in this review.** Existing build artifacts and receipts were not overwritten.
- Parsed `native_compile01.py` as data, without import/execution. All **five** embedded source/build payloads are byte-identical to current files and agree with `native-result01.json` source hashes. The retained native receipt records successful configure/build commands and artifact SHA256 `95ab4bcb856e68f1bc2b123024bea40b2731843352ccfff6c5cdffe2579aa0a8`; the driver does not invoke the artifact. This is retained compile/link evidence, not a new build or native execution by this reviewer.
- Read-only git status/diffs were run with `GIT_OPTIONAL_LOCKS=0`. `git diff --exit-code HEAD -- src/host/ahls_mmio_test.c` returned 0 with no output. Existing unrelated changes were not modified.

### Separate backend-binding supplement

**Bounded sanity verdict: PASS.** This is a separate input, not an amendment to the 247-file manifest or a claim of complete runtime equivalence.

Supplement: `qualification/opae-backend-binding-01/manifest01.json`, SHA256 `ba2385177deb2833d5f47deb3779d21aae60645305d467589941d15c3a633242`.

- Verified all **seven** manifest members for size/hash: zero mismatches. The collector bytes match both their manifest entry and `launch01.json`'s collector SHA256 `47d8b3155243f4ac7be77c3ec24c0a5e78c3505f6a326c6f32aab8c85a0edc09`.
- Read and AST-parsed the collector, **without importing or running it**. `collect01.py:16–20,28–62` uses four fixed installed/build paths, regular-file/size and ELF64 little-endian checks, bounded section-table traversal, file-backed SHF_ALLOC hashes, readelf metadata, and a whole-file reread hash. It contains no OPAE loading or device API call. Its subprocess commands are readelf and tmux evidence transport, not native library execution.
- JSON/gzip digests agree with the manifest, verification record and wrapped pane receipt; gzip decompresses byte-exactly to JSON. Batch completion is true, pane `%17` agrees with launch/capture references, and recorded launch/readelf return codes are zero.
- Recomputed pair comparisons from the recorded per-section sizes/hashes, rather than trusting saved equality flags or report totals:

| Pair | Equal / compared allocated file-backed sections | Differences |
|---|---|---|
| Installed/build UIO plugin | 20 / 22 | `.dynamic`, `.dynstr` |
| Installed/build lower VFIO library | 19 / 21 | `.dynamic`, `.dynstr` |

- Parsed retained readelf outputs: NEEDED lists and build IDs agree within each pair; only build copies have the build-directory RPATH. UIO build ID is `037cf77d7242ff8a1b0aabd6a2437b25626195a2`; lower VFIO build ID is `d1b5cfe2dff39c93d395ec5475f98263a63a437c`. `.text`, `.rodata` and build-ID section comparisons agree with the report.
- Independently compared all four whole-file hashes and sizes against applicable original source batches05/06: all agree. The report, comparison record and receipts are mutually consistent.

This supports the stated static section-identity evidence and an install-path metadata explanation. Actual binary contents were not supplied to this reviewer, so section hashes were not independently recomputed from ELF bytes. Allocated file-backed sections are not every ELF byte, and differing `.dynamic`/`.dynstr` contents are not fully decoded by this check. Loaded dependency resolution, UIO's `libopaeuio.so.2`, lower VFIO's `libopaemem.so.2`, and complete transitive/runtime access behavior remain UNVERIFIED. The supplement does not remove xfpga's prefilter-access blocker documented in `spec-review02.md:44–51`.

## Boundary and authored output

No remote contact, live device access, native libopae import/loading/execution (including help), native udev operation, vendor-tool run, rebuild, source edit, git write, commit, or task closure was performed by this reviewer. The only authored output is this report. No execution blocker or evidence inconsistency was encountered during the permitted review.

**Final disposition: APPROVED — offline scope only; minor Q1/Q2 are follow-up hardening, not release-blocking changes for this milestone.**

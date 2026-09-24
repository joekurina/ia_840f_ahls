# FINAL — Independent explicit-startup review

## 1. Specification verdict

**PASS for the bounded additive startup-ordering candidate and the retained 525-process inert integration evidence. No blocking defect found within `SCOPE.md`.** This is not acceptance of an installed launcher, real AHLS-image compile/link integration, real OPAE/backend execution, or hardware safety. Parent acceptance/publication remains separate.

The review read `SCOPE.md` before `RESULTS01.md`. It inspected source, build records, retained process results, ELF bytes and preservation bindings. It did not run a compiler, test, executable, shared library, simulator, container, SSH, network or git command. Independent computations were limited to local standard-library hashing, JSON/AST inspection, text comparison and inert ELF parsing. The only review-created file is this report.

### Specification checks

| Requirement | Verdict and evidence |
|---|---|
| Additive implementation; existing frontend/core/scalar/config preserved | PASS. The new launcher and bridge are separate files. CMake compiles the existing memory frontend with `main=ahls_memory_frontend_main`; its body is unchanged. Current bytes match the frozen package and the earlier source bindings described below. |
| No libopae-c dependency in the launcher | PASS for the supplied build. GREEN02 ELF has only `libjson-c.so.5`, `libubsan.so.1`, `libc.so.6` as direct NEEDED entries, and no OPAE/FPGA dynamic symbols. Link input and map agree. |
| Exact CLI/BDF before module loading | PASS. `ahls_memory_startup.c:107–119` checks argument count, fixed option positions and the unchanged strict BDF parser before config/module work. The parser checks exact length/separators/hex digits and device/function ranges (`ahls_qualification_core.c:22–36`). |
| Validate the actual SDK-parsed DFL table without launcher fallback | PASS. `ahls_memory_startup.c:68–86` directly calls `opae_parse_libopae_json`, rejects NULL, and requires exactly two ordered rows: `(8086,bcce,8086,1771)` and `(8086,bccf,8086,1771)`, each with `/work/sdk-build/lib/libxfpga.so` and `{}`. This is parsed-table equality, not a canonical JSON/schema validator. |
| Hand the entry immutable validated config bytes | PASS by source and bounded inert evidence. The regular-file snapshot is validated, then the same original buffer is copied to a memfd with WRITE/GROW/SHRINK/SEAL seals. Its fd remains open through initialization, frontend and finalization (`:30–105,120–172`). |
| Environment cleanup before dlopen | PASS. Explicit initialization and the sealed config path are set; WITH_ASE, LIBOPAE_LOGFILE and LIBOPAE_LOG are removed before `RTLD_NOW | RTLD_LOCAL` loading (`:135–145`). Constructor/initialization markers support the ordering. |
| Explicit initialize → unchanged frontend → finalize once | PASS for the launcher/bridge call chain. All three symbols must resolve before explicit initialization. Initialization failure returns without frontend/finalization; successful initialization is followed by one frontend call and one finalization, including frontend-error returns. Finalization failure forces rc1. The bridge maps directly to the captured init API (`ahls_memory_entry.c:4–16`, launcher `:147–173`). |
| No application/init retries or forced module unloading | PASS. There is no retry of initialization, entry or finalization and no dlclose. EINTR handling in byte I/O is not an application/backend retry. Module residency is retained until process exit. |
| Inert RED and GREEN integration, not real device execution | PASS within the retained evidence. RED is the direct-linked inert constructor before old `--help` rejection. GREEN02 uses the actual unchanged frontend against local inert API definitions and the SDK config-parser sources, not real OPAE/backend libraries. |

## 2. Implementation and evidence quality

### Frozen package and preservation

Independently verified the exact manifest SHA256:

`3ec4f08c89e8b8c9389f5a668433a0fef6a69383dfbfb8c5d7e7a32254d1f365`

All **95 listed regular files, totaling 1,898,023 bytes**, match their recorded sizes and SHA256 values; no mismatch or missing member was found. This includes both new sources, the current test driver/CMake/fixture, SDK parser inputs, RED and earlier GREEN artifacts, corrected GREEN02 ELF/map/build evidence, and the complete process-result JSON. It is verification of the enumerated package, not a claim about every file in the repository or historical filesystem activity.

Supplementary preservation checks reconciled all **12** entries in `qualification/ahls-memory-host01/source-bindings01.json` (manifest SHA256 `d74adce964102f914e1ae60459774f42e987d904f6be3840c3084fd3e389e7db`). These include the original scalar frontends, shared core/header, memory frontend/decoder, and existing offline/memory fixtures and CMake files. All matched. The current config also matches the predecessor config binding.

The **21** parser-rejection JSON inputs reused from `qualification/ahls-opae-runtime01/matrix02` are outside the startup manifest; each matched that gate's `review-package01.json` (SHA256 `4920c1a6c29dd677cb70b6e8fd7baf379f634a019a96f49475fdb35f5128b465`). The seven referenced runtime-source bindings and the recorded JSON-C runtime hash also matched. These are supplementary provenance checks, not a new verdict on the separate actual-parser qualification gate.

### Source and build observations

- The parser consumes/frees its input even on failure (`opae-cfg.c:341–387`). Passing a duplicate while retaining the original snapshot for sealing is correct; there is no duplicate-buffer leak on that path. The returned table is freed after validation.
- The launcher bypasses the SDK default-returning wrapper (`cfg-file.c:330–338`). The linker map discards that wrapper and retains the direct parser. **The default table itself remains in the executable**, referenced by the config-free routine's sentinel check; its presence is not evidence that fallback executes.
- The FIFO correction is narrow and appropriate: the only source delta from preserved `startup-candidate01.c` is the O_PATH/type/size check and subsequent read-open through the held `/proc/self/fd` inode. Ordinary FIFO, terminal symlink, directory and absent-file rejects no longer reach the constructor. This does not establish safety of arbitrary mounts/pseudo-filesystems or a universal filesystem timeout.
- CMake, generated compile flags, link commands, build log and ELF compiler comments agree on GCC 14.2.0, O2, Wall/Wextra/Werror, UNDEBUG and nonrecovering UBSan. The shared frontend object has only the main-symbol rename and PIC added. The test CMake file is not a production installation or real-library integration recipe.
- Direct NEEDED lists decoded from the RED, GREEN01 and GREEN02 ELF bytes agree with their captured readelf logs. Both GREEN02 inert modules need only UBSan/libc. The launcher's JSON-C RUNPATH is a single explicit local test path. `commands01.json` records dependency inspection before RED execution, the earlier GREEN execution, and the GREEN02 matrix. This is direct-dependency/build evidence, not complete ambient-loader attestation.

### Independent reduction of all retained process records

`matrix01/results.json` has **525 records and 525 distinct names**. Independently reconstructed the expected API traces from the unchanged frontend/fixture, checked every recorded rc, marker count/order, sequential API numbering, cleanup summary and relevant failure diagnostic. No inconsistency, UBSan/assertion diagnostic, or MMIO-write trace was found.

| Category | Verified count |
|---|---:|
| API fault positions, exactly 1 through 25 | 25 |
| Single-bit mutations, every pair in 7 words × 64 bits | 448 |
| Invalid argument sets | 12 |
| Config/file rejects: 21 parser fixtures + 7 file/type cases | 28 |
| Other startup/enumeration/module cases | 12 |
| **Total** | **525** |

Recorded return codes are rc0: **3**, rc1: **480**, rc2: **42**. Across the matrix there are **482** constructor markers, **481** explicit-init/sealed-config pairs, and **480** finalization markers. These cardinalities reconcile with pre-load rejections, one missing-entry module that runs its constructor only, and one initialization failure that runs neither frontend nor finalization.

The positive trace is constructor → initialize/seal check → the expected **25 API calls / seven reads** → finalize. All application traces finalize after their last API/cleanup call. Cleanup-fault cases deliberately permit the fixture's corresponding failed-destruction resource bit; they do not prove real resource release. The driver terminates with the exact retained `FPGA_TEST_EXPLICIT_STARTUP_PASS processes=525 api_faults=25 bit_faults=448` marker and recorded rc0.

RED's raw receipt shows the inert constructor and rc2 for old `--help`; it does not claim real-library execution. The initial FIFO failure and source remain preserved. `fifo-red01.json` records killed-and-waited termination, but contains no raw timeout/process receipt; the one-second duration comes from the supplied task context. Corrected `reject-fifo` independently has rc2, empty stdout and no constructor in the retained matrix. No rerun was needed or performed.

## 3. Nonblocking limitations and quality notes

1. **Finite test coverage, not universal parser or syscall fault coverage.** The 25 injected failures are frontend API positions, not all launcher allocation, file-I/O, environment, sealing or loader failures. Constructor markers test presence of the explicit-init variable, while the source establishes its literal value `1`. The fixture checks all four seals and config/environment agreement, but identifies the config contents by a module-path substring rather than whole-byte equality. The source establishes the stronger same-buffer copy property.
2. **The config replacement fixture is precisely an in-place truncation/rewrite.** It writes `{` to its own copied input during construction; it is not a concurrent pathname-rename/swap test. The unchanged sealed input is sufficient for the observed success, without claiming broader race testing.
3. **Receipts retain names/argv/rc/stdout/stderr, not per-case environments.** Fault/environment selection is recoverable from the hash-bound driver. This is adequate for the retained finite matrix but less self-contained than recording those overrides in each receipt. The driver does not itself enforce the preceding ELF-review step; the ordered command/evidence package supplies that procedure boundary.
4. **Exactly-once real-runtime teardown is source-derived, not dynamically qualified.** The fixture lacks the real OPAE destructor and real partial-init state. Captured `init.c:218–244` explains why removing WITH_ASE and retaining OPAE_EXPLICIT_INITIALIZE suppresses implicit init/finalize; it does not qualify backend teardown, resource lifetime or cancellation.

None of these warrants rejecting the bounded candidate or repeating an unchanged matrix merely for completeness.

## 4. Blockers to broader acceptance and scoped recommendation

**No in-scope acceptance blocker found. Recommend parent acceptance/publication of the frozen candidate and inert startup-ordering evidence only.** Do not deploy, execute real OPAE, or transition the overall hardware task on this review.

The following remain blockers to broader/runtime/hardware acceptance, rather than new generic sandbox requirements:

- The bridge still lacks actual AHLS-image library compile/link acceptance. The module and dependency bytes, loader namespace/preloads, paths and trusted runtime identity are not bound by this launcher. Missing-symbol rejection occurs after dlopen constructors, as the missing-entry test correctly demonstrates.
- **Launcher fallback rejection must not be generalized to actual initialization.** The captured real `pluginmgr.c:548–565` re-reads the explicit path and still calls `opae_parse_libopae_config`; that wrapper returns its default table when reading/parsing yields no table. A sealed snapshot prevents input replacement, not every later read/allocation/parser failure. The inert initializer does not exercise this runtime path. Actual runtime fallback/partial-init/finalization behavior remains unqualified.
- Exact BDF syntax and PCI ID rows are not device/process isolation. No claim is made about real enumeration side effects, driver/image/BAR routing, MMIO no-hang behavior, clocks/reset, IOMMU, buffer lifetime or successful recovery. Independent hardware no-hang/recovery prerequisites and device-access authorization remain mandatory.
- Do not load the separately captured scratch OPAE libraries as a shortcut; their build-context/empty-element RUNPATH issue remains outside this inert acceptance.

No maintained source was changed by this review, no existing evidence was rewritten, and no tests or targets were executed. Overall qualification remains incomplete. **Vendor DDR simulation remains SKIPPED BY USER.**

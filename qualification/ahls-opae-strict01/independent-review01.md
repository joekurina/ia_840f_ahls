# Independent review 01 — additive strict OPAE initialization

## Disposition

**SCOPED ACCEPTANCE RECOMMENDED for the additive source candidate and the captured actual-manager/parser inert unit evidence. No blocking defect found within that gate. Parent acceptance/publication remains pending and is exclusively the parent's decision.**

This is not acceptance of a real strict-core/entry build, deployment, startup integration, backend lifecycle, device access, or hardware operation. Those claims remain blocked by the exclusions and prerequisites below. Vendor DDR simulation remains **SKIPPED BY USER**.

## Specification first

I read `SCOPE.md` before `RESULTS01.md` and evaluated the candidate against that bounded contract: an opt-in addition beside unchanged SDK functions; explicit fresh-state startup; no ASE; an explicit absolute config path; direct parsing and an exact effective two-row CAPS01 table before platform discovery/loading; no compiled-default fallback, silent no-adapter success, or strict-API retry. Partial-backend recovery is expressly excluded.

The distinction between **exact parsed table** and **exact input document / exact loaded-library identity** is material. The implementation enforces the former. It does not independently seal a file, make the SDK JSON parser lexically strict, bypass the SDK's loader-prefix search, or establish BDF/namespace isolation. The comment requiring a caller-supplied sealed regular-file snapshot is a caller precondition, not an implemented file-integrity check.

## Review method and evidence identity

Local static review only. I read source, captured logs and JSON; used standard-library hashing, JSON/base64/gzip decoding, AST inspection, source comparison and ELF byte parsing. I did not import or execute a runner, compile, execute a fixture or SDK binary/library, invoke native inspection tools, use Git/SSH/network/container/simulator/device tools, inspect mutable real-target integration files, or perform workstation actions.

- Independently recomputed `review-package01.json` SHA256: `c4009e23ca7c0a37f1d90e1673b99c27942fe334e0e59f9ae1123b2b9838dd1a`.
- All **120 listed files / 1,627,145 bytes** matched the manifest's sizes and SHA256 values. A second full check found no drift.
- All **42 captured SDK source/header bindings** matched the existing `sdk_input_inventory` in `qualification/ahls-memory-host01/result-apptainer-build10.json.gz`. The separate generated `config.h` matched that receipt's captured bytes. All **35 newly transported headers** also matched the decoded `result-sdk-headers01.json` payload. Earlier retained manager/config-reader files and parser/mock-header captures agreed.
- The bound old `src/host/ahls_memory_entry.c` matches the earlier `ahls-memory-startup01/unit-publication-inventory01.json` record. This is a finite preservation check, not a new audit of installed libraries, FPGA trees, or every unbound launcher/frontend file.

Principal candidate bindings:

| File | SHA256 |
| --- | --- |
| `src/host/opae/ia840f_strict_init.inc` | `64d85b1eb4bbd09305873ce964bc0c417abbd075875540edb8ef30849edf2cee` |
| `src/host/opae/ia840f_strict_init.h` | `47755c1d8d755290641946d5062ee750e72ed57c188158c617a12b2ca81576f9` |
| `src/host/ahls_memory_entry_strict.c` | `eb4f8c58b1538b3b7b3c3a9511a7a104d0e5199007f34d8dc0fa22399fc011de` |

Preservation context receipts used, without executing their contents:

- `qualification/ahls-memory-host01/result-apptainer-build10.json.gz`: `1621ad273b763c0c9cbd90952894a632e0263abef1d8a1154b7e03dacf04b3ca`.
- `qualification/ahls-memory-startup01/unit-publication-inventory01.json`: `2ead8432840e17ff8927580fa4b44ddbe686abbbddaa90795b98150c779d0cf9`.

## Source findings

1. **Ordering and fallback barrier are correct for this contract.** `ia840f_strict_init.inc:29–45` locks the actual manager's recursive mutex; rejects attempted/initialized/finalizing/adapter/table state; latches the attempt before config prerequisites; requires an absolute path, presence of `OPAE_EXPLICIT_INITIALIZE`, and absence of `WITH_ASE`; rejects a NULL reader result; and calls `opae_parse_libopae_json` directly. It never invokes the default-returning `opae_parse_libopae_config` wrapper. The real parser consumes the raw buffer (`opae-cfg.c:383–387`).
2. **Effective-table check is narrow and explicit.** Lines 8–20 require exactly two ordered rows: vendor/subvendor `0x8086`, device `0xbcce` then `0xbccf`, subsystem `0x1771`, zero initial flags, module `/work/sdk-build/lib/libxfpga.so`, and serialized configuration `{}`. NULL, incomplete, extra, reordered, wildcard or otherwise nonmatching effective rows cannot reach discovery through this check. This relies on the bound parser's sentinel-terminated table representation, not an arbitrary caller-provided table.
3. **Startup status is not silently successful without an adapter.** Lines 46–57 install the validated table, preserve the SDK reentrancy guard during loading, require both detected platforms and a registered adapter before initialization, propagate loader/initializer errors, and clear/free the table on failure. The attempted latch is not cleared by the existing finalizer. No new forced cleanup or recovery was added; existing loader/configure failure cleanup remains SDK behavior.
4. **The sibling entry opts in without a fallback.** Its initializer names only `ia840f_opae_initialize_strict`; the frontend forwarding and `fpgaFinalize` bridge remain. This source inspection does not demonstrate that any real launcher selects or resolves the sibling correctly. Original manager functions are included unchanged, not replaced.

## Captured test and ELF evidence

I reconciled raw result lines against the JSON observations, independently checked every category predicate, reconstructed the expected case names from the driver's AST and the manifest's negative fixtures, and verified all command-log hashes. There are **39 unique expected and recorded cases**, not merely 39 claimed passes:

| Category | Cases | Observed boundary |
| --- | ---: | --- |
| Valid | 1 | one scan, four synthetic identity reads, one configure/init, initialized=1 |
| Pre-detection rejection | 29 | nonzero strict result; zero scans, identity reads, loads, configure/init callbacks |
| No usable detection | 3 | no-device, wrong-device, failed scan; nonzero result and no load/init |
| Loader failure | 3 | load/symbol/configure failures; nonzero result, no initializer, initialized=0 |
| Initializer failure | 1 | nonzero result, one inert initializer, initialized=0 |
| Repeat after success | 1 | second call rejected without another read/scan/load/init |
| Repeat after initializer failure | 1 | same no-retry observation after partial initialization |

The 29 pre-detection cases comprise eight mode cases and **21 inspected config mutations**. All mutations have the described semantic differences from the bound candidate; the malformed fixture is literally `{`. Allocation injection covers the first two parser `opae_calloc` calls, not every allocation. Every recorded native case returned zero because the probe reports the initializer outcome in `RESULT`; the Python driver checks that outcome. Expected error diagnostics are retained. No captured UBSan runtime-error/assertion diagnostic was found.

**RED is meaningful and preserved.** The original manager's NULL-read case has native rc0 and initializer rc0, one synthetic scan, ten fake loader attempts selecting default `libopae-v.so`/`libopae-u.so`, and two inert initializer callbacks. That violates the strict predicate; it is not real backend loading or a native crash. Its raw log agrees with `red-result01.json`.

**GREEN01 is an honest fixture failure, not a semantic RED.** Its build rc2 and implicit-declaration/int-conversion errors are preserved. Comparing `strict-probe-red01.c` with the final fixture shows only the two config-read/discovery `#undef` directives moved past the strict include. That explains the error and fix without suppressing warnings or changing the production fragment. Captured GREEN02 build flags retain O2, Werror, UNDEBUG and nonrecovering UBSan; ELF `.comment` identifies GCC 14.2.0.

**Static inertness evidence agrees with the source.** Parsing both retained ELF files directly reproduced the recorded undefined-symbol sets and direct dependencies: `libjson-c.so.5`, `libubsan.so.1`, `libc.so.6`. Neither imports real `dlopen`, `dlsym`, `dlclose`, `dlerror`, `opendir`, `readdir`, `ioctl` or `mmap`. Config reader/discovery bodies are absent from the retained symbol sets; their test substitutes and loader wrappers are present. GREEN02 retains the private strict initializer and direct parser, not the original initializer/default-returning wrapper. Source/link evidence excludes `init.c`, `api-shell.c`, and real backends. Real `fopen` in the fixture reads its named JSON input; sysfs reads use `fmemopen` synthetic strings.

- RED ELF SHA256: `0dfad899cfda572d9137ceb22eb023a36ee3a6d0184307d19c2048b536c57879`.
- GREEN02 ELF SHA256: `983ec56ecefd4c96f95d39d024e76d3a7d35d3e351b81fdcce0ff1ea72fe5ac7`.

The command receipts place ELF/symbol inspection before each binary's execution batch. They do not record a separate ELF inspection before each of the 39 processes; `RESULTS01.md:31` should be read at that batch granularity. This is direct-link/source evidence, not a syscall trace, independently repeated execution, or an OS sandbox/transitive-library audit.

## Limitations and gates on broader acceptance

These do not block the finite source/inert-evidence recommendation, but they block stronger claims:

- **Real integration remains unqualified.** A separately reviewed actual core/entry build and startup selection must establish symbol resolution, constructor/explicit-init ordering, intended library identities and stop-on-error behavior. The old API is still callable and can fall back to defaults. Checking environment presence inside the private function does not retroactively control a constructor or prove the process never used legacy initialization.
- **Real config I/O is replaced, not tested.** `read-fail` injects NULL. The captured SDK reader still ignores seek results and loops while short of its measured size without testing EOF (`cfg-file.c:145–168`); a file truncated after sizing can therefore stall rather than return NULL. This is a source-derived inherited limitation, not a reproduced run. The sealed stable regular-file precondition and bounded real startup behavior must be addressed before claiming general read-failure handling.
- **Parsed exactness is not raw-document strictness.** The SDK parses only selected configuration content, and integer conversion narrows into 16-bit IDs before this addition compares them (`cfg-file.c:188–250`, `cfg-file.h:196–217`). Extra ignored content or out-of-range lexical IDs are not independently rejected by the addition if the resulting table matches. Do not advertise byte/schema-exact input validation from these tests.
- **Loader and device isolation are unresolved.** The positive case records five fake loader attempts because the existing SDK prepends its search prefixes even to the absolute module string. The exact absolute string is the final attempt, not an exclusive load path. Dependency searches, predecessor trailing-colon runtime paths, and BDF isolation are outside this gate.
- **Partial state and lifecycle remain unresolved.** An initializer failure can leave an adapter registered and loaded; the caller must stop, not retry legacy initialization or assume safe cleanup. The latch's persistence after finalization is established by source, not a finalize/reinitialize test. No concurrency, cancellation, hardware cleanup or lifecycle signoff follows.
- **Coverage is finite.** No injected parser strdup/JSON-C allocation failure, adapter-allocation failure, individual sysfs-file error, lock failure, preexisting adapter/table/finalizing-state case, or both-device discovery/deduplication case is present. The driver checks useful category-level invariants, but does not pin the negative-fixture name set/count internally or assert every reported field/load path. The reviewed manifest plus this independent exact-set reconciliation closes that evidence-count question for this frozen run only. Future expansion should preserve the current failures and use a new evidence identity.

## Write scope

Only `qualification/ahls-opae-strict01/independent-review01.md` was created by this review. No source, frozen evidence, CURRENT/task state, acceptance or publication record was changed. No execution or hardware approval is granted.

FINAL

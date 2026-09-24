# Independent review — FINAL

## 1. Specification verdict: PASS within the stated gate

**Recommend parent acceptance of the additive configuration and retained inert SDK parser evidence only. No blocking specification defect found.** This is not permission to install the candidate, load OPAE/backends, invoke a host frontend, or access hardware.

Reviewed `SCOPE.md` first, then `RESULTS01.md`. Let `N` be `/home/joe/Projects/Thesis/AHLS/new_bsp/new` and `R` be this report's directory. The frozen `review-package01.json` SHA256 is:

`4920c1a6c29dd677cb70b6e8fd7baf379f634a019a96f49475fdb35f5128b465`

Independent local hashing verified **all 101 listed files, 850,948 bytes**, with no missing files, size/hash mismatches, or symlink members. These counts exclude the manifest itself and this new report.

| Requirement | Review result |
|---|---|
| Separate DFL-only candidate | PASS. `N/src/host/config/ia840f_caps01_dfl.cfg` contains one selected/enabled configuration and one enabled plugin. It is documented as not installed; there is no installation action in the reviewed test target or command receipts. |
| Exact selection contract | PASS. Exactly `8086:bcce/8086:1771` and `8086:bccf/8086:1771`, each selecting `/work/sdk-build/lib/libxfpga.so` with `{}`. No wildcard, alternate backend, management/RSU/daemon/AER recipe, or BDF-isolation claim is added. |
| Actual SDK parser, not a reimplementation | PASS. The build inputs are the actual SDK `cfg-file.c`, `opae-cfg.c`, ordinary libc-wrapper `opae_std.c`, and required headers. The probe calls `opae_parse_libopae_config`; its own code reads the named fixture and serializes the returned table. |
| No OPAE initializer/plugin-manager/backend in the fixture | PASS for the reviewed executable and link evidence. No `libopae-c`, `init.c`, plugin manager, or backend is linked; direct dependencies and retained/discarded sections corroborate the source boundary. |
| RED against unmodified SDK configuration | PASS. SDK JSON independently expands to the captured 54 rows. Native parser rc is **0**; the exact-candidate Python predicate returns **1**, as intended. This does not diagnose an upstream configuration defect. |
| GREEN for the candidate | PASS. Captured two-row output equals the literal required table, including order, full module path, and empty objects. Native parser and predicate both return **0**. |
| Normal and optimized negative/default matrix | PASS. Each retained matrix has 22 unique cases: 1 exact, 13 default-fallback, 2 empty, 6 parsed-but-nonexact. Both command receipts return 0. Matrix02 explicitly uses Python `-O`. |
| Preserve evidence and respect exclusions | PASS for the inspected package. Original matrix harness, command-receipt prefixes, raw results, and SDK baseline remain retained. No reviewed source/artifact was changed during this review. No current remote/system preservation claim is inferred from a local snapshot. Vendor DDR simulation remains **SKIPPED BY USER**. |

Candidate: 858 bytes, SHA256 `9f49f4d455e672de26dc8546a8ccdc029dbdfe521bee1beca47d102cb63ef5e4`.

## 2. Quality and evidence verdict: sufficient for bounded acceptance

### Source and build provenance

- All **nine SDK files / 79,023 bytes** match both their local source-and-results bindings and the predecessor archive's `sdk_input_inventory`. The archive hash independently matches `cd082a192597e9bd0b32500acfc7973a6d67209f59efa4170451d04a41744a88`. This check used only the source inventory and the relevant captured `config.h`; it does not reopen the independent container-build gate.
- All seven entries in `runtime-source-bindings01.json` also match that SDK inventory. Captured build `config.h` is byte-identical to the archive payload, supporting the stated module-search-prefix evidence.
- `CMakeLists.txt:8–21`, generated `flags.make`, `link.txt`, configure/build logs, and `commands03.json` agree: GCC 14.2.0, GNU C11, `-O2 -Wall -Wextra -Werror`, section garbage collection, UBSan, and nonrecovering undefined-behavior instrumentation. The current compiler-file hash matches its recorded binding; it was not executed for this review.
- The retained Ubuntu authentication receipt reports successful signature verification. Both JSON-C 0.15 package files match their recorded sizes/hashes, and the extracted runtime matches its source-and-results hash. The `libjson-c.so` and SONAME symlinks resolve to that same local runtime file. Signature verification and extraction were not rerun. An optional stdlib-only archive-content check could not decode `data.tar.zst`; therefore no independent package-payload-to-header comparison is claimed.

### Executable boundary

The 55,080-byte probe matches SHA256 `bdbc8b04b46f0e228bc2d3425dee909b9a13c5212c37e2f2eef04d1fa42180b1`.

Independent parsing of its ELF bytes corroborates the retained logs: direct `DT_NEEDED` entries are only `libjson-c.so.5`, `libubsan.so.1`, and `libc.so.6`; RUNPATH points to the local extracted JSON-C directory. Its sole `.init_array` entry resolves to CRT `frame_dummy`, not the OPAE constructor. Symbol-name comparison agrees with the retained `nm` log after excluding ELF file symbols and accounting for symbol-version notation.

`parser.map:451–479` lists only the probe, the three SDK C translation units, JSON-C, sanitizer/compiler support, and libc/startup inputs. The map discards SDK configuration discovery/reading (`:24–31`) and unused open/ioctl/process/directory wrappers (`:323–394`). Those wrappers are real libc calls in the source, not inert mocks; their absence from the retained executable matters. Ordinary probe `fopen`/`fread` remain, as expected. No OPAE API, initializer, plugin-manager, backend, `dlopen`/`dlsym`, ioctl, or mmap entry is retained in the inspected symbol table. This is a direct executable/source boundary, not exhaustive transitive dependency qualification or an OS sandbox.

### Test-result reconciliation

The compiled-default C literals independently reconstruct the captured **52-row** NULL-input table. All 44 recorded case outcomes were independently checked as data, including native rc, table class, and the exact candidate predicate. The six nonexact outputs also match the particular intended mutations, not merely their broad result class. Matrix fixture files are byte-identical across runs; their candidate JSON is semantically identical to the separate maintained candidate.

The only harness revision is the explicit `spec is None or spec.loader is None` guard at maintained matrix lines 10–11. AST inspection finds no `assert` in either matrix version or the exact-check module. Thus the optimized run does not disable acceptance checks. This is not a byte-identical-harness comparison: matrix01 used the retained earlier version, while matrix02 used the guard-corrected version; the acceptance logic is unchanged.

A complete recursive comparison of the two receipts finds exactly one differing field: `cases[2].stderr`, for `missing-configs`. It differs only by the literal `matrix01` versus `matrix02` fixture-directory path. Rows, rc, verdicts, all other diagnostics, and metadata agree. The initial whole-receipt equality rejection is appropriately disclosed and neither receipt was rewritten. The normal/optimized PASS logs agree with the parsed case counts; the retained optimized diagnostics contain no UBSan/runtime-error report.

## 3. Ranked findings and limitations

### F1 — High consequence for future execution; acknowledged, not a defect in this gate

**The two-row result is neither fail-closed runtime enforcement nor device isolation.**

- `init.c:179–236` runs a constructor before ordinary application main: log-file handling precedes the explicit-init check, `WITH_ASE` takes precedence, and both controlling environment variables are presence tests. Application argument checks are not a pre-main safety boundary.
- `cfg-file.c:57–121` can fall through from an unresolved environment-selected path to HOME/system discovery. `:330–339` returns the compiled default table on NULL/failed parsing. The tested malformed and incomplete JSON cases retain native success with broad fallback rows.
- `pluginmgr.c:254–288,290–459,462–581` selects modules by PCI ID tuples during sysfs discovery, loads them, and initializes adapters independently of later application token filtering. Its loader (`:60–79`) concatenates search prefixes even for the configured absolute string before trying the empty prefix. The absolute module string is therefore not itself proof of the actual loaded ELF.
- xfpga `plugin.c:39–62` invokes sysfs/ioctl initialization and ignores plugin JSON configuration. VFIO `plugin.c:48–86` separately discovers devices and likewise ignores that argument. A hypothetical JSON `bdf` field would not establish isolation.

These limitations are substantially and correctly retained in `RESULTS01.md` and the candidate README. Do not promote this acceptance into loader, driver-binding, enumeration, open/close, MMIO, DMA, physical DDR, numerical AHLS, lifecycle, boot, or hardware-safety qualification.

### F2 — Low, nonblocking: negative mutation assertions are intentionally coarse

`test_opae_config_matrix.py:39–45` accepts any nonempty, nondefault, nonexact table for a `different` case. Consequently a future regression producing the wrong nonexact rows could still pass that case. It also uses the observed NULL table as its fallback oracle rather than pinning that table inside the harness.

This does not invalidate the current evidence: the frozen default table was independently matched against C literals, and all six frozen mutation outputs were checked against their exact expected rows. If the harness is extended, explicit per-case row expectations would strengthen regression detection. No rerun or maintained-code edit is required for this bounded result.

### F3 — Low, nonblocking: distinguish source-only discovery findings from exercised fallback

`RESULTS01.md:59–63` places environment/path discovery and JSON parse fallback together before saying the matrices confirm fallback observations. Only the latter was exercised. The probe supplies already-read input directly; `opae_find_cfg_file` and `opae_read_cfg_file` are discarded from its executable. The unresolved-environment-path behavior is supported by source inspection, not a discovery test. Preserve this distinction in the parent's acceptance summary; there is no need to add discovery execution to this gate.

## 4. Bounded FINAL recommendation

**ACCEPT the additive, uninstalled configuration and the actual parser-only results as satisfying `SCOPE.md`, with the nonblocking qualifications above. Parent alone accepts/publishes.** Preserve every predecessor artifact and the disclosed receipt-comparison issue; do not revert defaults or rerun completed matrices merely to erase that history.

The next permissible engineering conclusion is that this exact candidate parses into the required DFL-only table. Any future runtime step still needs its separately supported startup/loader sequence, exact ELF/namespace and configuration handling, actual driver-binding justification, source-derived access footprint, and unresolved device/image/clock-reset/IOMMU/ownership/recovery prerequisites. This report grants no new execution or hardware authorization.

Review activity was local read-only hashing, JSON/AST interpretation, source/log/map reading, and static ELF-byte inspection. No reviewed Python/C code, parser, application, compiler, simulator, container, OPAE library/backend, network/SSH operation, git operation, or dynamic ELF loader was invoked. No mutable CURRENT or other independent review was consulted. The sole created file is this report.

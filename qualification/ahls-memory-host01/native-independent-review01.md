# Independent workstation-native CAPS01 memory-frontend review

**Status: FINAL**

## Recommendation

**ACCEPT the completed workstation-native compile/link and static ELF evidence, solely as intermediate API/link compatibility evidence for the unchanged CAPS01 memory frontend.** Specification: **PASS**. Acquisition and completed-evidence quality: **PASS within the stated boundary**. No blocking discrepancy, missing required exported artifact, or reason to rerun this acquisition was found.

This is a result-review recommendation, **not a new execution gate, an execution authorization, a task transition, or parent acceptance**. Parent owns acceptance. The user-approved workstation-native check does not establish AHLS/Apptainer target readiness; that separate investigation is not consumed or awaited here. The hardware goal remains incomplete, vendor DDR simulation remains **SKIPPED BY USER**, and live OPAE/MMIO/hardware operations remain outside this review.

## Review binding and method

Read `NATIVE-SCOPE01.md`, then `NATIVE-RESULTS01.md`, then `native-review-package01.json`, before acquisition/quality analysis. Paths below are relative to this report's directory unless explicitly project-relative.

- Frozen manifest SHA256: `4bc44d9db66d966bd13cb24cfd7b5cee98e7436cfde98840affe520ff6b4a3e8`.
- Independently verified **68 members, 1,671,771 member bytes, zero size/hash mismatches**. The manifest itself and this review are not included in that member total.
- Native runner SHA256: `12b0e3f776157249e7eef263aa04191ece172c3a007d6a6ff78d1a19689ac59f`; matches `dispatch-native01.json`.
- Native archive: `result-native01.json.gz`, **38,760 bytes**, SHA256 `e0c12d473df7782b2d2509e163b424638c23ceb1db7b445dfde7072912cbceca`; size/hash match `outer-native01.json`.
- All **16 exported members, 78,435 decoded bytes**, match their individual size/hash records and the corresponding `artifacts-native01/` files byte-for-byte. Their set is exactly seven logs, the cache/flags/link metadata, the executable, and five source/build-recipe inputs.

Used local file reads, hashing, JSON/gzip/base64 decoding, Python AST/literal evaluation, and independent ELF parsing with `struct`. **The native runner was never imported or executed.** Its `C` assignment was recovered with `ast.literal_eval`; the complete actual runner equals `run-native01.py.in` with precisely that literal substituted for `@CONFIG@`. No compiler, native application, readelf, container, library-loading operation, SSH/network, Git, hardware operation, or testcase was run by this reviewer. `CURRENT.md` was not read. This report, initially IN_PROGRESS and now FINAL, is the sole written artifact.

## 1. Specification review — PASS

The native specification requests compilation/linking of the already accepted frontend against the workstation installation, static ELF inspection, exact source/tool/header/core-library bindings, finite supervised children, preservation, and output identities. It expressly excludes application execution, OPAE loading, device access, installation/driver changes, reset/programming, and full transitive tool/runtime closure (`NATIVE-SCOPE01.md:3–7`). The completed flow fits that intermediate scope.

The retained independent inert review is FINAL and its digest matches `parent-review-verification01.json`: `a74b5c292ccb58b46fd479cb3c57c1921eb4f7a5aacc9619bbea7568360543a3`. Its accepted package digest is `3e8f181c16d05818d40f80a1962a151908e33b8f4d9064f44c5d2b05ff51b9b1`. `UNIT-ACCEPTANCE.md` explicitly accepts only the additive source and inert API-contract tests. The native frontend, shared core/header, and decoder match those accepted package entries exactly. O0/O2 matrix bytes/hashes were checked only as provenance; their tests and semantic acceptance were neither rerun nor reopened. Earlier `native_link_accepted: false` is the prior inert acceptance's scope, not a contradictory native-result verdict.

The native CMake recipe compiles only `ahls_memory_inspect.c` and `ahls_qualification_core.c`, uses the bound installed OPAE include/library paths, and contains no application invocation, test, install, custom command, or `try_run`. The runner's seven native command entries contain only tool-version queries, configure/build, and static readelf operations; none launches the resulting application or a dynamic loader. It removes executable permission after linking. Its `binary_executed: false` and `hardware_access: false` declarations are consistent with that source and the captured commands. This is scoped acquisition evidence, not a system-wide syscall audit or an OS sandbox.

## 2. Literal inputs and installation identity — PASS

All five literal base64 inputs independently decode to their recorded sizes/hashes, match their maintained local origins, and match the archived source copies:

| Input | Bytes | SHA256 |
|---|---:|---|
| `ahls_memory_inspect.c` | 5163 | `eb36fb35fb3e26087ba9d2bb59d02750a14f7c6fa7ad852378fc20dc268ede2b` |
| `ahls_qualification_core.c` | 4631 | `52e7ff9492d0432bfb1e55dceb4368720bbe17c994f6d49a60c67b660454ca74` |
| `ahls_qualification_core.h` | 1190 | `fbd6e3c8999bfb803419309954c281a92c4326960d81cce8614305ba6195bf6f` |
| `ia840f_dma_capabilities.h` | 2332 | `908907f046da9ed16fe6d10e9433bd84e85807ea80be6882c568de35d34a4c49` |
| `CMakeLists.txt` | 915 | `fb1c97885cc456ff09923f618c431a94e6dea5e2db4274bbaf9cf15d93378b1e` |

The literal configuration's seven tool-path bindings plus core library, all 24 installed-header records, OPAE configuration record, and allowed CPU list exactly match `native-prerequisites01.json`. The compressed prerequisite capture decodes to that same JSON value; its archive and decoded-file digests match `outer-native-prereq01.json` (outer 0), and its capture-script digest matches its dispatch receipt.

| Bound path | Captured resolved path | SHA256 |
|---|---|---|
| `/usr/bin/cc`, `/usr/bin/gcc` | `/usr/bin/gcc` | `a31b06d4dafdcffdc9418b39ffa498e7924e880c3f7610cdbf54e341704f9328` |
| `/usr/bin/cmake` | same | `1595178000979d0b735d82d993ff8411835fba8f8fbe7e340bdfaf7ae6ab700d` |
| `/usr/bin/make` | same | `644e3132422d860e5777400e1fe153695f5d2e8d1a6dcff7b37e2ccceacaea87` |
| `/usr/bin/as` | same | `2870525fb59869f6f4c51cae67ffc6124f6635129db00a7d0818b84f7d069c56` |
| `/usr/bin/ld` | `/usr/bin/ld.bfd` | `ac6bbc7393b95278ffa294cbdf18c65b5003d4e15dc805ce24a8146a8a154c42` |
| `/usr/bin/readelf` | same | `51bc80f3a187e54e0b267fe6e64de09129f7761aafe615177d9d0be2229afcff` |
| `/usr/lib64/libopae-c.so` | `/usr/lib64/libopae-c.so.2.13.0` | `2cc2f37de8fdbb396add0c7a61a96bd9a7051d14ccfc4c7f79d42679ff825ddf` |

The core library is recorded as **202,312 bytes**. The seven OPAE headers in the accepted frontend package—`access.h`, `enum.h`, `mmio.h`, `properties.h`, `types.h`, `types_enum.h`, `utils.h`—independently match the captured current-installed sizes/hashes. Their OPAE include edges close within that set. All 20 distinct frontend OPAE call names have declarations in those captured headers, including subsystem setters and `fpgaReadMMIO64`.

These are verified **captured workstation identities**. This local-only review did not rehash live remote installations, and the tool/core-library binaries themselves are not exported package members. Compiler subprograms, startup objects, system headers, loader and transitive dependencies are not comprehensively bound; the specification does not claim that closure. The dispatch receipt's outer-wrapper script digest is retained, but wrapper bytes are not a package member and were not independently reconstructed.

## 3. Native acquisition and preservation — PASS

Recorded exclusive root:
`/home/uwb_student00/ahls/new_BSP/work_ahls_memory_host01/native01`

Run: `memory-host-native01`; dispatch `@343 %343`, matching result pane `%343`. The runner rejects an existing root and disabled Python assertions, checks the captured identities before work, writes the five exact inputs into its fresh source directory, and uses a clean explicit tool environment. Supervision retains the child leader unreaped while checking/draining its owned process group, with a 120-second command deadline and termination paths. This review accepts the observed completed path; it does not claim fresh fault-injection qualification of every supervisor branch.

All seven recorded label/argv pairs exactly match the inspected runner command list, with the literal root above:

| Command label | Recorded operation | Native / effective |
|---|---|---|
| `compiler_version` | `/usr/bin/cc --version` | 0 / 0 |
| `cmake_version` | `/usr/bin/cmake --version` | 0 / 0 |
| `configure` | CMake `-S <root>/source -B <root>/build -G "Unix Makefiles"`, explicit `/usr/bin/cc`, `/usr/bin/make`, Debug, `/usr/lib64/libopae-c.so`, `/usr/include` | 0 / 0 |
| `compile_link` | `/usr/bin/cmake --build <root>/build --target ahls_memory_inspect --parallel 36 --verbose` | 0 / 0 |
| `elf_dynamic` | `/usr/bin/readelf --dynamic <root>/build/ahls_memory_inspect` | 0 / 0 |
| `elf_symbols` | `/usr/bin/readelf --dyn-syms --wide <root>/build/ahls_memory_inspect` | 0 / 0 |
| `elf_notes` | `/usr/bin/readelf --notes <root>/build/ahls_memory_inspect` | 0 / 0 |

**Outer status: 0.** Native means the child tool's status; effective means the supervisor's status; outer is the retained runner/transport receipt. Every command has `timeout: false`, `descendants_after_leader: false`, and empty observed/final owned-live-group lists. The result has `success: true`, `inputs_unchanged: true`, `original_bindings_unchanged: true`, and `postflight_errors: []`.

Preflight records the complete allowed CPU set **0–35**, matching prerequisite/configuration, and **68,719,476,736 bytes (64 GiB) RLIMIT_AS per child**, matching the source setter. It records 124,457,566,208 available-memory bytes, 1,271,119,409,152 free-disk bytes, and no listed competing tools. These are historical launch observations and per-process limits, not present-state measurements, aggregate containment, or proof of 36 active compiler workers.

Build evidence establishes GCC **11.5.0 20240719 (Red Hat 11.5.0-14)** and CMake **3.31.8**. Both translation units were compiled with exactly `-g -std=c11 -O2 -Wall -Wextra -Werror -pedantic`; Debug does not negate the target's explicit O2. The verbose link command uses the two actual objects and `/usr/lib64/libopae-c.so`, not inert mock objects. Configure/build logs contain no warning/error/fatal diagnostics and show the target completed. Cache, `flags.make`, `link.txt`, and verbose commands agree on the selected compiler/library and effective flags. No native runtime or UBSan execution is claimed.

All 12 local entries in `source-bindings01.json` match their recorded sizes/hashes; all seven historical host/core/offline-test files also match `parent-results01.json`. Remote preservation checks cover the five staged inputs and the explicitly recorded tool/header/library/configuration bindings. They are not a whole-workstation, image, or FPGA-design inventory. The inspected flow contains no programming or maintained-design modification operation; no broader preservation proof is inferred from the boolean name.

## 4. ELF and source/API assertions — PASS, carefully bounded

Independently parsed the archived executable as inert bytes, corroborating the native static logs:

- **40,424 bytes**, SHA256 `a68f2e2a8b374db28fd90cffde002c4c20a9c900ef00a855592b331b396b7dd8`.
- ELF64 little-endian, x86-64, `ET_EXEC`; remote recorded mode **0600** after build.
- GNU build ID `556dc9db7e790878c65b06d55e983e7b99e2b2d4`, matching `elf_notes.log`.
- Exactly two direct `DT_NEEDED` entries, in recorded order: **`libopae-c.so.2`, `libc.so.6`**.
- No `DT_RPATH` or `DT_RUNPATH`. The cache's `CMAKE_SKIP_RPATH:BOOL=NO` is not an observed RPATH: the recipe sets a normal variable ON, and the actual link/ELF has none.
- `.dynsym` contains **36 entries**, including **20 distinct undefined OPAE symbols**. That OPAE set exactly equals the frontend's source call-name set and the captured symbol log, including both subsystem filters, enumeration, open/map, ReadMMIO64, cleanup and error reporting. No direct application OPAE write/reset/buffer/DMA import is present.

The last statement is deliberately about **direct imports and this frontend's source**, not every machine instruction, transitive library, backend or possible hardware effect. The complete shared core is linked; the ordinary symbol table retains `ahls_run_case` and `ahls_verify_identity`, among other helpers. The core contains callback-based scalar operations, including write callbacks, but the memory frontend does not call those helpers. Their retention does not add an application OPAE write import, nor does absent write/reset imports prove a harmless process.

Seven ordered reads, filters, rejection and cleanup behavior belong to the unchanged source and separately accepted inert API evidence. An ELF import list cannot prove those sequences, actual runtime behavior, backend initialization/cleanup safety, hardware isolation, or successful device access. The captured executable was **not executed or dynamically loaded** by this flow or review, including for help. Runtime resolution may select libraries/plugins beyond the link-time core; static dependency names do not qualify them. The symbol log also records `__libc_start_main@GLIBC_2.34`; nothing here establishes the AHLS target's compatible runtime.

## Final disposition

The frozen evidence supports the claimed **workstation-native compile/link compatibility and static ELF identity/dependency result**, with no required correction or rerun of this completed acquisition. Retain it unchanged as useful intermediate evidence.

AHLS target-environment compatibility, loaded-backend selection and footprint, startup/cleanup safety, source-to-live image/BDF/BAR mapping, live enumeration/MMIO, physical DDR/DMA, numerical accelerator correctness, completion/fences/buffer lifetime, reset/PR, timing/full-design closure and durable boot are **not established**. These exclusions are not new gates imposed by this review. No hardware permission or completion of the overall goal follows from this recommendation.

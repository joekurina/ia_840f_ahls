# FINAL — Independent AHLS target-image startup compile/link review

## 1. Specification verdict

**PASS within `TARGET-SCOPE01.md`. Recommend bounded parent acceptance of the completed target-image compile/link and static-inspection evidence, with the limitations below. No in-scope blocker found. Parent alone accepts/publishes.**

I read `TARGET-SCOPE01.md` before `TARGET-RESULTS01.md`, then reviewed the implementation and captured evidence independently of `target-parent-verification01.json`. This gate establishes that the unchanged launcher/entry/frontend sources compile and link in the bound AHLS image against the accepted OPAE 2.13 build. It does not establish executable behavior, loader resolution, real initialization/finalization, device isolation or hardware safety.

The earlier `independent-review01.md` FINAL and its 95-file/525-process gate were used only as predecessor/context. That matrix was neither reopened nor rerun. This target build uses a different compiler and no UBSan; successful linking does not transfer functional-equivalence claims from the inert build.

| Specification requirement | Independent disposition |
|---|---|
| Unchanged AHLS SIF and previously accepted OPAE libraries | PASS. Image/runtime identities agree with the accepted backends11 archive; all six bound prebuilt library payload identities agree with that archive and the original/copied inventories. |
| Preserve six application sources; additive build recipe only | PASS. All six payloads match both the target package and predecessor source bindings. The seventh submitted input is the new CMake recipe. The frontend receives only the build-time `main=ahls_memory_frontend_main` rename and PIC. |
| Build only application targets; no SDK/backend/FPGA rebuild or installation | PASS. Native CMake produces the launcher and shared entry, with an intermediate frontend object target. It compiles the SDK's parser and ordinary libc-wrapper sources into the launcher; it does **not** rebuild the prebuilt SDK/core/backend libraries. No install/download/test target or FPGA tool appears in the recipe or commands. |
| Actual target tools and requested compile/link flags | PASS. Captured GNU C 11.4.0 and CMake 3.22.1, compile database, verbose build, link commands and ELF compiler comments agree. Effective compile options include O2/Wall/Wextra/Werror/UNDEBUG; both links use `-z defs`. |
| Launcher/entry dependency boundary and exports | PASS. Independently parsed ELF bytes establish the exact direct dependencies, three defined bridge ABI exports and 22 actual OPAE imports, all defined by the bound core. No local OPAE API stubs are linked. |
| Explicit nonempty RUNPATHs on new outputs | PASS. Both exact paths match the scope and contain no empty element. This does not fix inherited SDK RUNPATHs or attest a runtime namespace. |
| Fresh owned root, bounded resources, preservation and captured isolation | PASS for the observed completed run. Runner guards, recorded receipts, postflight acceptance and actual mount/device evidence agree; limitations of source-bound supervision remain. |
| No produced target invoked, no OPAE/backend loading or device work | PASS for the reviewed flow. The complete dispatch/runner/CMake path contains build and static-inspection operations, not execution/loading of either target. Receipts agree. No runtime or hardware test is credited. |

## 2. Input, payload and result identities

The frozen `target-review-package01.json` has SHA256:

`7af02abc5f5c861426b7d8f211c9bf8057fa2bb075e6fbeb4c1d09a192c966c7`

Independently rehashed **all 52 listed files / 2,254,639 bytes**, with no missing member or size/hash mismatch. Rechecked the package after the substantive review. This verifies the enumerated package, not unrelated repository state.

The dispatch payload's base64 decodes byte-for-byte to `run-target01.py`. Its AST matches `run-target01.py.in` after literal substitution of `C` and `INNER`; embedded `INNER` is byte-identical to `target-inner01.py`. Runner inspection used AST/literal/base64 operations only: the runner was never imported, compiled for execution or executed.

- Dispatch SHA256: `d375753cf83c761f799edf095df528fe7cd2f75098edd4fff952d289198962a1`.
- Runner SHA256: `ba8cb35750c4db17676e21afa18de5da17c87d88bf2880c190061331a16fce11`.
- Target result archive: **94,315 bytes**, SHA256 `5b3b36526657c5b2a2812e565c7b5494ef1828db8d601eae495e4c5284f9a0d6`.
- Accepted predecessor archive SHA256: `cd082a192597e9bd0b32500acfc7973a6d67209f59efa4170451d04a41744a88`.
- AHLS SIF: **422,834,176 bytes**, SHA256 `7f10d218cb18b9a33c4a8fff076cdf12a72ae528db5d3c2b2a224fa3f26c6fab`.

All **27 target archive payloads**, totaling **196,081 decoded bytes**, match their internal sizes/hashes and the corresponding exported local files. The embedded build-result object equals the exported `build-result.json`; each of the 13 command-log hashes matches its actual payload. The outer archive receipt, dispatch hashes and parent summary reconcile with this independent reduction. I also decoded and hash-checked all 21 predecessor archive members to establish the reused artifact chain, without reopening predecessor acceptance.

### Preservation acceptance

The literal runner configuration contains the same **1,177 SDK entries** as the accepted predecessor inventory. Its **51 prefix entries** equal the target run's original and copied prefix entries. Every one of the **66 copied prerequisite entries** equals its counterpart in the **688-entry original snapshot**. The six bound library files match their predecessor archive bytes; the `libopae-c.so` → `libopae-c.so.2` → `libopae-c.so.2.13.0` link chain is explicit. The core payload is SHA256 `1947fa09b223734acbe49f330ea5c75ea0ba0156296978fa4598f30745dda6f4`.

All seven submitted source/recipe base64 payloads independently satisfy their recorded sizes and hashes. The six application payloads also match the predecessor startup manifest. SIF, wrapper and real runtime records equal their accepted predecessor records.

Acceptance was evaluated as a conjunction, not inferred from native rc0 alone:

- exact package, dispatch, input and archive identities;
- native/effective/outer **0/0/0**, all **13** exact expected inner argv records with rc0;
- no recorded timeout, post-leader descendants or owned-group survivors;
- both outer result and inner build result successful;
- empty `postflight_errors` and all five preservation flags true: `original_unchanged`, `copied_prerequisites_unchanged`, `inputs_unchanged`, `sdk_unchanged`, `tools_unchanged`;
- complete payload agreement and independently satisfied output/dependency/symbol predicates.

Every term passed. The implementation recomputes the original and copied snapshots and rehashes bound SDK entries, submitted inputs and image/runtime files in `run-target01.py.in:140–152`; a postflight exception sets success false and exit125. The before/after preservation claim is supported by that hash-bound executed code and its receipt, not by separately exported full after-inventories or a live remote recheck. SDK preservation covers the bound entries; it is not an assertion that no unlisted file ever existed.

## 3. Actual commands, environment and build linkage

`result-target01.json.gz` records the single supervised Apptainer invocation, native/effective0/0, PID/start-tick identity, and completion without timeout or residual group members. Here native is the container entry process's exit; the compiler/CMake/static-tool calls also have their own 13 rc0 receipts. `outer-target01.json` supplies outer0. The reviewed dispatch wrapper carries the runner exit into the outer buffer and signals its own completion channel.

The 13 inner commands are compiler version, CMake version, application configure, application build, four static inspections for each target, and core dynsym inspection. Their labels, order and argv independently match the inner script. CMake uses `--parallel 36`; the eight compile-database entries and verbose log show only the expected application/parser/wrapper translation units and the two application links. No application, `--help`, `ldd`, `dlopen` probe or backend executable is invoked by the build flow.

Recorded available RAM is **124,449,894,400 bytes** and disk free **1,271,089,393,664 bytes**, above the declared thresholds. The runner captures all 36 allowed CPUs, applies that affinity and a **68,719,476,736-byte** soft/hard per-process address-space limit, and has outer600s/inner240s deadlines. It requires an absent target root and tmux, and performs the named competing-native-process scan before launch (`run-target01.py.in:6–14,37–39,55–86,104–132`). These are finite normal-account guards, not proof of aggregate memory containment, all possible competing jobs or escaped-descendant control.

The actual mount record shows the target-owned `/work` bind, read-only `/sdk`, private scratch-backed `/tmp` and `/var/tmp`, minimal `/dev`, and no sysfs mount (`artifacts-target01/mounts.log`). The captured device names contain no vfio/dfl/fpga/uio/dri/mem entry. The specified containall/cleanenv/no-home/no-host-sys/default-bind restrictions are therefore supported by observed mounts, not merely argv. This is not a generic OS or network sandbox claim.

### Source/header consistency

`target-CMakeLists01.txt:14–42`, the compile database, flags, link commands and maps agree:

- Entry: unchanged frontend object plus `ahls_memory_entry.c` and shared core, linking the copied real `libopae-c.so`.
- Launcher: `ahls_memory_startup.c`, shared core, actual SDK `cfg-file.c`/`opae-cfg.c`, and `tests/framework/mock/opae_std.c`, linking JSON-C and the platform dl link option. The wrapper file contains ordinary libc calls, not inert FPGA definitions; its directory name is not a mock-runtime substitution.
- The eight captured public OPAE headers used for API cross-checking match the runner's SDK hashes, including `init.h`, `mmio.h`, `access.h`, `enum.h`, `properties.h`, `utils.h` and their type headers. Every one of the 22 referenced OPAE functions has a declaration in that matched header set. Nine captured parser/wrapper source/header files also match the bound SDK entries. These are supplementary frozen-context comparisons, not additions to the target package's 52-file count.
- The bridge's `fpgaInitialize(const char *)` and `fpgaFinalize(void)` calls match the real header. The three launcher function-pointer signatures agree with the bridge, and the frontend symbol rename is visible in the actual compile command.
- CMake Release initially contributes `-O3 -DNDEBUG`; the later per-target `-O2 ... -UNDEBUG` determines compilation. Link command appearances of Release flags do not establish disabled source assertions. No UBSan flags/dependency are present.

## 4. Independent ELF boundary checks

ELF64 little-endian x86-64 bytes were parsed with standard-library code, without invoking readelf, nm, a loader or either output. Dynamic tags were obtained from the program-header dynamic segment and its mapped string table; symbol tables were decoded independently. Every captured dynsym row agrees: **49 launcher, 50 entry and 250 core rows**, including the null entries. Target NEEDED/RUNPATH and undefined-symbol sets agree with the captured readelf/nm logs.

| Artifact | Bytes | SHA256 |
|---|---:|---|
| `ahls_memory_startup` | 36,592 | `14e33130d072b0007874effce3e78133962d48d711e283ef45e9ddce09329ee6` |
| `libahls_memory_entry.so` | 26,128 | `ea31d2b187a57263cf6569a81ff23df6777415d31ac191bff066a023b27eb1e5` |

- Launcher NEEDED: exactly `libjson-c.so.5`, `libc.so.6`; RUNPATH exactly `/work/prefix/usr/lib/x86_64-linux-gnu`. No `fpga*` dynsym entries. It is a PIE with interpreter `/lib64/ld-linux-x86-64.so.2`.
- Entry NEEDED: exactly `libopae-c.so.2`, `libc.so.6`; RUNPATH exactly `/work/sdk-build/lib:/work/prefix/usr/lib/x86_64-linux-gnu`; SONAME `libahls_memory_entry.so`.
- All three `ia840f_memory_initialize`, `ia840f_memory_entry`, `ia840f_memory_finalize` symbols are defined GLOBAL/DEFAULT functions, not just substring matches or undefined names.
- The entry's 22 `fpga*` undefined symbols equal both the independently extracted source-call set and the recorded required-export set. All 22 have real GLOBAL/DEFAULT function definitions in the byte-bound predecessor core.
- Link maps contain no OPAE initializer/plugin-manager/backend object in the launcher and no inert FPGA implementation in the entry. The launcher retains the direct JSON parser and free routine; its default-returning wrapper and ioctl wrapper are discarded. The default table itself remains as the free routine's sentinel, not proof that the launcher executes fallback.

## 5. Findings and limits retained with acceptance

1. **Real fallback and lifecycle remain unqualified.** The actual source-bound `pluginmgr.c:548–565` rereads the explicit configuration and calls `opae_parse_libopae_config`; `cfg-file.c:330–338` returns the default table if reading/parsing produces no table. A sealed memfd prevents replacement of validated bytes, not subsequent read, allocation or parser failures. The launcher bypasses this wrapper for its own validation, but that does not remove it from real initialization. Matched `init.c:178–252` supports the environment-before-load ordering and explicit-init destructor distinction, not live partial-init cleanup or recovery. No such runtime was exercised here.
2. **New RUNPATHs are clean only locally.** Direct parsing of the unchanged core confirms `/work/prefix/usr/lib/x86_64-linux-gnu:` with its trailing empty element. The accepted SDK/backend build's inherited findings remain. The new `/work` paths are build-context paths, not relocation/installation qualification, transitive-byte attestation or a safe loader namespace. This gate does not authorize loading either output.
3. **Retain the native warning and evidence-strength distinctions.** `configure.log` warns that `FETCHCONTENT_FULLY_DISCONNECTED` was unused. The custom recipe contains no fetch/download operation; the flag is not itself a network barrier. Do not call the build warning-free. `target-inner01.py:27` sets both output modes to0600 before successful completion, but exported payload records do not independently record mode; they establish bytes, not a separate mode attestation. Neither point blocks compile/link acceptance or requires an unchanged rerun.
4. **Compilation is not runtime or hardware acceptance.** Strict BDF syntax, configured PCI IDs and seven frontend read sites do not prove process-wide device confinement or no-hang behavior. No DFL/OPAE discovery, MMIO, physical DDR/DMA, AHLS numerical hardware, lifecycle/drain/reset/buffer-lifetime, full design closure or durable boot pass is established. **Vendor DDR simulation remains SKIPPED BY USER.**

## Final recommendation and review activity

Recommend accepting the exact frozen **target-image compile/link result and static boundaries only**, retaining the findings above. This supplies evidence for the predecessor's missing AHLS-image compilation/linkage item, subject to parent acceptance; it does not close the runtime/hardware items. No concrete in-scope blocker or reason to repeat the completed build was found.

Review operations were limited to local frozen/context text, JSON/gzip/base64, hashing, AST/literal inspection and inert ELF byte parsing. No SSH, network, compiler, native inspection tool, simulator, container, executable/shared-object loading, git or device activity occurred. No mutable CURRENT, live remote task, maintained source, frozen evidence or task state was changed. **The only file created by this review is `qualification/ahls-memory-startup01/target-independent-review01.md`.**

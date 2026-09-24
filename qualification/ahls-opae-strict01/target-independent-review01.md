# Independent review — strict-core target01 native AHLS-image build

**FINAL scoped recommendation: ACCEPT as native compile/link and static-ELF integration evidence only, with the retained limitations below. No blocking defect was found for that scope.** This is a recommendation to the parent, not acceptance, publication, runtime approval or hardware authorization. The separate 39-case unit review is neither consumed nor superseded here.

## 1. Specification-first assessment

I read `TARGET-SCOPE01.md` before `TARGET-RESULTS01.md`, then checked the frozen source, submitted payload, native records and artifact bytes. The required result is a fresh build of the native SDK CMake target `opae-c`, with one read-only append-only plugin-manager overlay, followed by the unchanged launcher and additive strict entry. It is not a backend rebuild, installation, loading experiment, functional test or hardware qualification.

| Requirement | Assessment and evidence |
|---|---|
| Fresh target root and actual AHLS image | PASS. The runner exclusively creates `/home/uwb_student00/ahls/new_BSP/work_ahls_opae_strict01/target01`. Its recorded argv and actual `/work` mount select that root. Image, wrapper and architecture-specific runtime identities match the bound predecessor. |
| Native SDK target, accepted options | PASS. `sdk_configure` argv equals the predecessor's `sdk_reconfigure` argv exactly. `sdk_build` selects only `opae-c`; native output compiles its ten C sources and ends with `Built target opae-c`. Backend enable options in the cache do not mean those targets were rebuilt. |
| One read-only source overlay, original bytes retained | PASS. The 15,977-byte overlay begins with all 15,844 original bytes and adds only a comment and the strict-fragment include. The captured mount and pre-configure digest assertion identify the overlaid compiler input. |
| Separate own-source bindings | PASS. All ten submitted source/build payloads have valid size/SHA256/base64 bindings. The three strict files match their project-local counterparts; the embedded inner program matches `target-inner01.py` exactly. |
| Preserve original and immutable copied inputs | PASS within the explicitly recorded inventory domains. All 1,177 original SDK bindings match the predecessor inventory. The native record reports original 688-entry preservation, all preservation predicates true and no postflight errors. Among 66 copied entries, only the core ELF changed; generated `config.h`, all five other SDK libraries and the 51-entry prefix remained unchanged. |
| Required API/bridge symbols and static ELF inspection | PASS. Independent byte parsing confirms the new private core export, all 21 FPGA API imports used by the strict entry, no `fpgaInitialize` import in that entry, and all three bridge exports. Native application links use `-z defs`. |
| Finite execution, no result loading or hardware | PASS as the captured build-only operation. Native/effective/outer status is 0/0/0; all 16 inner commands returned zero; no timeout or owned surviving process group is reported. No launcher, entry or OPAE/backend execution appears in the command path. No sysfs mount or relevant device nodes are exposed in the captured container namespace. |
| Retain warnings, RUNPATH and runtime limits | PASS with limitations, not warning-free or installation-ready acceptance. The inherited empty core RUNPATH component, plugin prefix search behavior, optional-dependency messages and unused options remain visible. |

These findings do not depend on any behavioral result from the concurrent unit review. No unit-review file was opened, and no unit behavior was rerun or independently adjudicated.

## 2. Frozen evidence and provenance

### Independently verified byte bindings

- `target-review-package01.json`: SHA256 `67c8d0da25aae602754276ee5f84dc15933abb0083b551b5aa6913a219926a6e`. All **60** listed files matched, totaling **3,269,737 bytes**.
- `result-target01.json.gz`: **385,168 bytes**, SHA256 `044a42537526cfd59a3dc1496e04d44dda063269d895ea36e3a8d94edfa37121`. All **33** decoded members passed size/SHA256 verification and byte equality with `artifacts-target01/`.
- Bound predecessor `qualification/ahls-memory-host01/result-apptainer-backends11.json.gz`: SHA256 `cd082a192597e9bd0b32500acfc7973a6d67209f59efa4170451d04a41744a88`. All **21** archived members passed size/SHA256 verification. Its six completed library identities equal the runner's prerequisite library map; its SDK source inventory equals the runner's complete 1,177-entry map. The prefix bindings also match the predecessor's inventory.
- Dispatch payload SHA256 `fa941318a7464640b6353eb8764658c1027de1797f53fafc8822726f4d6ec386`; decoded runner SHA256 `98b0eff9d80739abafd3bb2eb279b501c0525ce0b736cee368332aaeedcecec1`. The decoded bytes equal `run-target01.py`, which also equals its template with the two literal substitutions. The dispatch receipt's hashes, evidence-buffer names and completion channel reconcile exactly.
- The local SDK source/header bindings in `source-bindings01.json` were checked against their bytes and, for SDK source/header files, against the native SDK inventory. Generated `config.h` was separately compared with the predecessor and target artifacts. The captured native `libopae-c/CMakeLists.txt` also matches its SDK inventory entry.

The parent verification JSON was corroborated rather than treated as the primary proof: I checked the archive, members, command logs, payload literals, ELF bytes and source integration independently.

### Environment identity and roots

The target and predecessor records agree on:

| Object | SHA256 |
|---|---|
| `/home/uwb_student00/ahls/ubuntu-ahls.sif` | `7f10d218cb18b9a33c4a8fff076cdf12a72ae528db5d3c2b2a224fa3f26c6fab` |
| Apptainer shell wrapper | `55ae0ec39abf785e3812fe2eb6626ada05a078c3f41431dc37107741a7218f9a` |
| Architecture-specific Apptainer executable | `f18f7ca8cc134ec17bd903e80ecf4575c9b78d048313202fac8ee3d8bd4d6a45` |

The recorded image tools are GNU C **11.4.0**, CMake **3.22.1**, and the SDK configure identifies **Ubuntu 22.04**. This is GCC compilation inside the AHLS SIF, not an AHLS FPGA compiler invocation. The inner record binds resolved paths, sizes and hashes for Python, CMake, cc, ld, readelf and nm; the immutable SIF provides the broader image context.

`run-target01.py` lines 6–14 and 103–134 establish the normal-account/host/tmux guard, absent-root requirement, clean launch environment, resource checks, source preparation and literal invocation. `mounts.log` lines 16–18 confirm `/sdk` read-only, the intended target root at `/work`, and the single read-only `pluginmgr.c` overlay. The invocation uses `--containall --cleanenv --no-home --no-mount sys,hostfs,cwd,bind-paths --no-eval`; its inner Python uses `-I -S`.

The record contains CPU affinity 0–35, a 68,719,476,736-byte per-process address-space limit, and both CMake builds use `--parallel 36`. The source supervisor has a 600-second outer deadline and the inner command wrapper has a 240-second per-command timeout. Recorded preflight free memory/disk passed their finite thresholds. The supervisor preserves the leader until group supervision/signaling completes; the successful record reports no residual group, no timeout and no termination requirement. These are resource/ownership controls, not proof of 36 simultaneous workers, aggregate-memory containment or universal process isolation.

## 3. Native source integration

### Append-only overlay reaches the actual compiler

The original plugin manager SHA256 is `8bcd9f8c9c2b3a449bc46ed3bb9f3019b9b4ae2a3d7567a1a0b882f108d13ad2`. The submitted overlay SHA256 is `7212a9663fccfbb26d4a485ceda27d68c6df31e4c3567c7111c64c4339056282`. Its exact appended text is:

```c

/* Source-bound IA-840F opt-in addition; original functions above unchanged. */
#include "/work/source/opae/ia840f_strict_init.inc"
```

There is no replacement, deletion or rewrite within the original prefix. `target-inner01.py:23` requires the visible `/sdk/libraries/libopae-c/pluginmgr.c` digest before configuring; the successful subsequent command sequence establishes passage through that check. `mounts.log:18` records the actual overlay source/destination and `ro` mount option. `sdk_build.log:18` then compiles that exact SDK path with `HAVE_CONFIG_H=1`, native SDK include roots and the native CMake options. Together these bind payload, visible source view and native compile, rather than relying only on a proposed bind argv.

The strict include shares the native plugin-manager translation unit, so its references to the SDK's static state/helpers are source-supported; no SDK visibility change is needed. Native `config.h:240–242` supplies `STATIC static`. `opae-cfg.c:341–387` defines the direct `opae_parse_libopae_json` function with the signature declared by the fragment, and the native CMake source list includes `opae-cfg.c`. Independent ELF parsing finds both that native function and `ia840f_opae_initialize_strict` defined, not unresolved. The strict function is a GLOBAL/DEFAULT FUNC with nonzero size (886 bytes) in the rebuilt core. The native build is not the inert unit fixture: it compiles the SDK target's own source list, including the SDK-selected `tests/framework/mock/opae_std.c`, without substituting the unit fixture's boundary implementations.

### Runtime filename suffix and private API compatibility

The fragment's literal module path `/work/sdk-build/lib/libxfpga.so` agrees with the inherited native artifact. The native parser copies the JSON module string unchanged (`opae-cfg.c:263–270,325–326`); the plugin finder constructs `search_prefix + lib_path` (`pluginmgr.c:60–79`). Neither adds another `.so` suffix. The unchanged launcher uses the same complete module path. There is therefore no source-level missing/duplicated-suffix integration blocker in this package.

This does **not** make the filename an exclusive loader binding. The native search-prefix list in `config.h:233–238` tries installation/system prefixes before the empty prefix, even for this absolute-looking module string. Exact runtime resolution remains unqualified.

`ahls_memory_entry_strict.c` calls the declared private `int ia840f_opae_initialize_strict(const char *)` API, retains the frontend handoff, and retains `fpgaFinalize` for the finalize bridge. It does not fall back to `fpgaInitialize`. The new core's dynamic export set equals the predecessor's set plus exactly `ia840f_opae_initialize_strict`; no predecessor dynamic export was removed. Undefined core references from the preserved VFIO and xfpga backends that were supplied by the old core are still represented by the new core's export set. This is symbol-surface compatibility evidence, not runtime ABI/behavior proof.

## 4. Artifacts, linking and diagnostics

| Artifact | Bytes | SHA256 |
|---|---:|---|
| Rebuilt `sdk-build/lib/libopae-c.so.2.13.0` | 592,584 | `78f625f66da37e32596507a36418fa3579945f2ecd06377b9659f68b9fd427b1` |
| `build/ahls_memory_startup` | 36,592 | `14e33130d072b0007874effce3e78133962d48d711e283ef45e9ddce09329ee6` |
| `build/libahls_memory_entry_strict.so` | 26,152 | `d1ce56a3217154988b2b579c30a4858700fffd2eeae92d627dd05aaccd6f06e6` |

The launcher matches the supplied unchanged-launcher baseline digest. The separately bound backend predecessor archive contains the old core, not the old startup entry/launcher pair; I do not claim a new independent before/after hash acquisition of that separate startup root.

I decoded ELF64 little-endian section, dynamic, symbol and program-header bytes directly, without running an ELF utility or loader. All three artifacts are x86-64; their GNU_STACK flags are RW, not executable. The launcher carries `/lib64/ld-linux-x86-64.so.2`; the two libraries have no interpreter. Byte-derived dependency/path strings agree with the archived native readelf logs:

| Artifact | DT_NEEDED | DT_RUNPATH |
|---|---|---|
| Launcher | `libjson-c.so.5`, `libc.so.6` | `/work/prefix/usr/lib/x86_64-linux-gnu` |
| Strict entry | `libopae-c.so.2`, `libc.so.6` | `/work/sdk-build/lib:/work/prefix/usr/lib/x86_64-linux-gnu` |
| Rebuilt core | `libjson-c.so.5`, `libuuid.so.1`, `libc.so.6` | `/work/prefix/usr/lib/x86_64-linux-gnu:` |

The entry's OPAE/private undefined-symbol set equals the recorded 22-symbol requirement exactly: 21 `fpga*` exports and the private strict export. All are defined by the captured core. The exact bridge definitions are `ia840f_memory_initialize`, `ia840f_memory_entry`, and `ia840f_memory_finalize`. The launcher has no FPGA API import or OPAE DT_NEEDED edge. Native `build.log:43,48`, saved link commands and the entry link map bind the actual application links; the strict entry links `/work/sdk-build/lib/libopae-c.so`, whose preserved symlink chain ends at the new versioned core.

The copied core changed from 589,816 bytes, SHA256 `1947fa09b223734acbe49f330ea5c75ea0ba0156296978fa4598f30745dda6f4`, to the artifact above. The allowed metadata output `config.h` remained byte-identical, SHA256 `f62b0fb339ec1aa2a352669e2b8a50fbae8f08fa8d5e463c97fb578efaf72c62`. No other pre-existing copied prerequisite changed. Newly generated CMake/build files are output files, not an assertion that the whole fresh worktree had only one new or changed file.

The native compile/link logs contain no warning/error-colon diagnostics, and use `-Wall -Wextra -Werror`; the application compile commands also end with `-UNDEBUG`. Nevertheless, configure output is not warning-free:

- SDK configure reports unavailable Python development components and PkgConfig, and documentation unavailable without Doxygen.
- SDK configure reports unused `RUN_LDCONFIG`.
- Application configure reports unused `FETCHCONTENT_FULLY_DISCONNECTED`.

These do not block the selected target, but neither unused variable should be presented as an independently enforced safety control. No install/ldconfig invocation occurs. The accepted SDK configure arguments are unchanged from the predecessor; fresh native target selection, not merely option names, is what restricts this build.

## 5. Acceptance conjunction and evidence quality

The acceptance evidence is a conjunction, not just the native zero:

1. Hash-matching package, dispatched runner, embedded inner source, submitted source payloads and predecessor inputs.
2. Recorded native/effective/outer 0/0/0 and all 16 inner command/log hash pairs at rc0.
3. Inner build success, actual target completion and required ELF outputs/symbols.
4. All five recorded preservation predicates true: original, immutable copied inputs, SDK, submitted inputs and image/runtime tools.
5. No postflight errors, timeout or owned surviving group.
6. Complete 33-member export and local/archive/artifact equality.

The runner's actual success path reaches all preservation checks. Although outer `success` is set before the `finally` block, any failed preservation assertion clears it and forces rc125 (`run-target01.py:134–156`). The original/copied conditional checks cannot be bypassed by a successful build path because their inventories are established before launch. Thus the observed success is not relying on an omitted required preservation predicate. Collection skips absent optional paths, so archive creation alone would not prove completeness; the actual required artifacts and complete observed member set were checked separately here.

Retained evidence limits, not blockers to this completed build:

- This is local independent analysis of frozen records. Remote original-source and full-tree preservation are reported by the source-bound runner; this review did not reacquire live remote bytes. The SDK check binds the specified 1,177 entries, not arbitrary new directory membership. The 688-entry original inventory is this target's prelaunch baseline and is not confused with the older predecessor's pre-backend-build inventory.
- The overlay digest is enforced by the bound inner assertion, corroborated by successful continuation, mount capture and native compile path; it is not also emitted as a separate measured digest field in `build-result.json`.
- The competing-process check is a finite preflight executable-name list, not continuous whole-host exclusion. Source-bound guards, writable `/work`, normal-account execution and per-process limits are not an OS sandbox.
- The wrapper/executable/SIF identities are bound; this target does not independently rehash every host-side Apptainer configuration/helper file. Actual mount/device capture is therefore important. No broader runtime-installation attestation is claimed.
- The raw native rc at the outer level is the Apptainer/inner-program result; the individual compiler/build/static-inspection commands are additionally represented by their inner rc/log records. This distinction is preserved rather than presenting a single compiler exit as the entire stage.

For a future changed runner, separately recording the measured overlay digest and explicitly requiring all expected exported roles would make acceptance more self-describing. Those improvements do not require rerunning this already complete native build or modifying its frozen evidence.

## 6. Retained limitations and disposition

**No compile/link blocker remains in the reviewed target01 package.** The source integration is native, additive and byte-bound, and the required outputs and symbols are present. Parent acceptance can be scoped to that result without waiting for a hardware experiment or repeating an unchanged build.

The following are not cleared:

- The core retains its predecessor's trailing-colon RUNPATH, introducing an empty/current-working-directory search component. Preserved `libopae-v`, `libopaevfio` and `libxfpga` also retain build-context/empty-component RUNPATHs. Launcher/entry paths are cleaner, but this does not close their transitive runtime resolution.
- Private strict behavior is opt-in through the new API/entry. The original functions, constructors, legacy fallback and original libraries/entry are not globally replaced or newly qualified. The unchanged launcher accepts a module path; it does not attest that the user selected this reviewed module and dependency closure.
- Real initialization, backend detection/loading, runtime dependency identity, partial-initialization cleanup, finalization/recovery and the full lifecycle remain untested by this build. Symbol presence and `-z defs` do not prove them.
- No device access, BDF confinement, driver/OPAE readiness, MMIO, DDR/DMA, numerical AHLS correctness, boot, programming, timing/full signoff or working-card acceptance follows. The hardware goal remains incomplete. Vendor DDR simulation remains **SKIPPED BY USER**.

Review operations were limited to local reads, AST/literal inspection, JSON/gzip/base64 and hash verification, and direct ELF-byte parsing. I did not import a runner or invoke SSH/network/git, a compiler, ELF utility, simulator, container, loader, test or device operation. The only created/modified file is this report. No source, frozen evidence, CURRENT/task state or other review was changed. Parent alone accepts and publishes.

# AHLS Apptainer compile/link and backend-build independent review

**Status: FINAL.** Independent, local-only review of the frozen completed acquisitions. Parent acceptance/publication remains a separate action.

## 1. Specification verdict

**PASS for the bounded target-image compile/link and named-backend-build gate; recommend parent acceptance of that evidence only.** Build10 compiled the actual OPAE SDK core and linked the exact memory-AFU frontend inside the existing AHLS Ubuntu image. Backends11 used a fresh, verified copy to build the named `opae-v` and `xfpga` targets and their required library dependencies. Neither result establishes an installed, initialized or hardware-qualified runtime.

The controlling specification is [APPTAINER-SCOPE01.md](APPTAINER-SCOPE01.md), read before [APPTAINER-RESULTS01.md](APPTAINER-RESULTS01.md). The frozen `apptainer-review-package01.json` was independently hashed as:

`637f17d46bcc365cc5378ae1aafc6ac0df0baa534ff2c71008aa1e277e2fa10e`

All **119 members / 10,094,673 bytes** matched their declared sizes and SHA256 values, including the four maintained frontend source/header files included in the package. Mutable `CURRENT.md` and in-flight native-publication files were not reviewed.

### Completed-path acceptance evidence

| Acquisition | Inner commands | Exported members verified | Native / effective / outer | Preservation and result |
|---|---:|---:|---|---|
| `apptainer-build10` | 10 | 17 / 17 | 0 / 0 / 0 | Four package extractions, SDK configure/core build, frontend configure/build, two static ELF inspections; image/wrapper and tracked SDK preservation reported true |
| `apptainer-backends11` | 8 | 21 / 21 | 0 / 0 / 0 | SDK reconfigure, named backend build, six static ELF inspections; image/wrapper, tracked SDK and selected original build-tree preservation reported true |

The archived native records have `timeout=false`, no descendants observed at leader exit, `descendants_after_leader=false`, and empty final `owned_group_live_after`. These are observations of the completed paths, not universal supervision proof. Outer receipts bind the actual compressed archive bytes and SHA256. Dispatch runner hashes match the frozen launcher files. Every decoded exported member matches its receipt size/hash and its frozen local artifact bytes. Inner command-log hashes and the exported `build-result.json` agree with the archive's inner result. The parent reduction's counts, artifacts, native command records and preservation values reconcile with these independent checks.

### Target image, dependencies and source identity

- Both stages identify the same 422,834,176-byte SIF, SHA256 `7f10d218cb18b9a33c4a8fff076cdf12a72ae528db5d3c2b2a224fa3f26c6fab`. Prior ordinary-file inventory identifies Ubuntu 22.04.5 and no OPAE in the inspected installation roots. This is not a whole-filesystem absence proof.
- The wrapper SHA256 is `55ae0ec39abf785e3812fe2eb6626ada05a078c3f41431dc37107741a7218f9a`; its captured source matches that hash. The pinned real Apptainer executable is `f18f7ca8cc134ec17bd903e80ecf4575c9b78d048313202fac8ee3d8bd4d6a45`, also matching the post-build captured identity in both stages. These are retained acquisition identities, not a new remote inspection.
- Signed Jammy-updates packages supplied `libjson-c-dev`/`libjson-c5` version `0.15-3~ubuntu1.22.04.2` and `uuid-dev`/`libuuid1` version `2.37.2-4ubuntu3.6`, all amd64. The four inner commands are explicitly `dpkg-deb --extract ... /work/prefix`, not installation or maintainer-script execution. No workstation-distribution library injection or SIF modification is evidenced.
- Both SDK inventories contain **1,177 tracked entries** and are identical. The runner source recomputes the recorded entries after acquisition and reports equality. The 38 captured SDK source payloads independently match their embedded sizes/hashes; the tracked ones match the inventories. The 34 explicit captured-source pins in each launcher also match. The preserved source identifies OPAE 2.13.0.
- Backends11 records **568 file/link entries** across `prefix`, `sdk-build`, `frontend` and `frontend-build`. Its source checks the exact build10 archive hash, copies those subtrees with symlinks preserved, requires copy equality before native execution, and compares the original snapshot again afterward. The available original artifact/source entries reconcile with build10, including the relative core-library symlink chain. Preservation is scoped to these recorded subtrees and entries.

### Literal configuration and exact frontend binding

The launchers were parsed with Python AST; neither they nor their embedded programs were imported or executed. Literal embedded source, package/frontend payloads and SDK hash maps were inspected. A deliberately restricted AST reader reconstructed the finite configure/build and outer container argv and matched the recorded commands.

The container commands use `exec --containall --cleanenv --no-home --no-mount sys,hostfs,cwd,bind-paths --no-eval`, fresh owned workdirs, an explicit owned `/work:rw` bind and `/home/uwb_student00/opae-sdk:/sdk:ro`. The inner entry is `/usr/bin/python3 -I -S /work/inventory.py`; its source rejects exposed `/dev` names beginning with vfio/dfl/fpga/uio. This is source-bound, observed build isolation, not an OS sandbox against an operator able to alter code or a general device-access prohibition.

All four embedded deb payloads exactly match the frozen package files. All five embedded frontend files exactly match the four frozen source/header files plus `native-CMakeLists01.txt`, and match the recorded copied frontend inventory. The source-binding record agrees for the four frontend source/header members. The build uses `/sdk/include`, `/usr/bin/cc`, strict `-std=c11`, `-O2 -Wall -Wextra -Werror -pedantic`, and the actual `/work/sdk-build/lib/libopae-c.so`. The captured frontend CMake definition has no tests, custom execution or install target.

SDK build10 requests only `opae-c`; backends11 requests only `opae-v xfpga`. The configure argv differ at exactly one option: **`OPAE_BUILD_LIBOPAEUIO=OFF` → `ON`**. Captured xfpga CMake source explicitly links `opaeuio`; VFIO source links `opaevfio`, which depends on `opaemem`. The compiler/link logs show those actual library builds. Enabling the UIO option is not evidence that Python bindings or test executables were built: those were not requested, and `OPAE_WITH_PYBIND11` remains OFF.

This is not a byte-identical cache claim. Besides the option change, the saved SDK caches change the generated makefile count from 37 to 39 and retype six uuid/json-c cache entries from PATH/STRING to UNINITIALIZED without changing their values. Frontend cache and generated SDK `config.h` bytes are unchanged.

### Artifact and static ELF verification

The retained artifacts were parsed as inert ELF bytes using Python `struct`, without a loader or `ldd`. Dynamic tags and dynamic-symbol names agree with all eight captured static ELF logs. The files are ELF64 little-endian x86-64; the frontend has a program interpreter and the libraries do not. Static frontend OPAE imports are present among the core library's defined public exports; this is not a transitive loader-resolution test.

- Frontend: **43,336 bytes**, SHA256 `2d6d0de6d59fb9681f1fb83aaacb60a06d1d771b761fc579dc7b3e013aed6cc2`.
- Core: **589,816 bytes**, SHA256 `1947fa09b223734acbe49f330ea5c75ea0ba0156296978fa4598f30745dda6f4`.
- Both remain byte-identical across the stages. The inner successful build10 path applies `chmod(0600)` to the frontend after linking; the exported byte records do not independently record filesystem mode.
- Backends11 exports the real `libopae-v.so`, `libxfpga.so`, `libopaevfio.so.2.13.0`, `libopaeuio.so.2.13.0` and `libopaemem.so.2.13.0`; their exact sizes/hashes match the frozen manifest, inner artifact records and parent reduction.

| Artifact | Direct DT_NEEDED entries |
|---|---|
| Frontend | `libopae-c.so.2`, `libc.so.6` |
| `libopae-c.so.2.13.0` | `libjson-c.so.5`, `libuuid.so.1`, `libc.so.6` |
| `libopae-v.so` | `libopae-c.so.2`, `libopaevfio.so.2`, `libuuid.so.1`, `libc.so.6` |
| `libxfpga.so` | `libopae-c.so.2`, `libjson-c.so.5`, `libuuid.so.1`, `libopaeuio.so.2`, `libc.so.6` |
| `libopaevfio.so.2.13.0` | `libopaemem.so.2`, `libc.so.6` |
| `libopaeuio.so.2.13.0`, `libopaemem.so.2.13.0` | `libc.so.6` |

The frontend has no RPATH/RUNPATH. The core uses RUNPATH `/work/prefix/usr/lib/x86_64-linux-gnu:`; opaevfio uses `/work/sdk-build/lib:`; both plugin modules use `/work/sdk-build/lib:/work/prefix/usr/lib/x86_64-linux-gnu:`. Preserve the trailing colons literally: they include an empty search-path element, normally interpreted as the current directory by the ELF loader. These are scratch-build artifacts, not a reviewed deployment configuration.

## 2. Acquisition and evidence-quality verdict

**SUFFICIENT for the completed bounded gate, with the ranked limitations below; no blocking contradiction found.** The evidence is materially stronger than an exit-zero banner: source payloads, actual verbose compiler/link logs, independent inner/native/outer records, retained artifact bytes, static ELF data and source-preservation checks agree. It remains an acquisition record rather than independent machine attestation or exhaustive toolchain closure.

### Signed-dependency provenance

The captured `signature-verification.json` records gpgv rc0 and a good Ubuntu Archive Automatic Signing Key (2018) signature using fingerprint `F6ECB3762474EDA9D21B7022871920D1991BC93C`. Its keyring hash matches both the frozen 7,399-byte keyring and the decoded keyring09 export extracted from the pinned SIF. Its image hash matches the build image.

Independently checked the full chain: frozen InRelease SHA256 → its SHA256 entry for `main/binary-amd64/Packages.xz` (3,854,816 bytes) → decompressed exact package stanzas → all four deb sizes/hashes and embedded build10 payloads. Package versions, architectures, dependency text, archive URLs and filenames agree. This review relied on the captured successful gpgv receipt; it did not execute a new signature verifier.

An optional in-memory package-data inspection stopped because this Python stdlib tar reader does not support the first deb's `data.tar.zst`. No extraction tool, external decompressor or installation was substituted. Thus no fresh unpacked-file equivalence is claimed. The bounded evidence instead comprises authenticated deb bytes, the successful recorded extraction commands and the resulting library hashes, which also agree with the copied-prefix inventory.

### Ranked findings and retained limitations

1. **High significance — runtime and hardware claims remain excluded, not failed acceptance criteria.** No frontend execution, OPAE/backend dynamic loading, plugin selection/initialization or installed deployment was performed. Static NEEDED/export agreement cannot prove transitive symbol/version resolution, constructor behavior or safe device initialization. The scratch RUNPATHs, including empty elements, reinforce why these are not deployment evidence. The SDK's `tests/framework/mock/opae_std.c` is ordinary runtime support: inspected `opae_open`, `opae_read`, `opae_ioctl` and related functions delegate to libc. Its directory name does not turn these real libraries into the separate inert frontend mock or make them safe to load casually.

2. **Medium significance — completed-path supervision is established, not universal fault safety.** The outer source creates a new session, retains the leader unreaped with `waitid(...WNOWAIT)` while handling its process group, imposes a 600-second outer deadline and records final group observations. The inner command timeouts are 180 seconds for build10 and 240 for backends11. But the frozen acquisitions do not exercise every bookkeeping, persistence, signal or postflight exception branch; a failure in cleanup/status collection can interrupt later receipt completion. Group scans do not establish control over descendants that escape the group. No unchanged rerun or new supervisor test is required to accept these already completed observations.

3. **Medium significance — identity/preservation scope is finite.** The 1,177-entry SDK check binds tracked file contents or symlink text; it is not an inventory of all untracked files, all metadata or the complete host filesystem. The 568-entry original-tree check covers the four named subtrees, not every acquisition-root entry. SDK postflight equality is evidenced by the captured boolean and inspected recomputation logic, not a separately exported complete after-inventory. The SIF and selected tool identities do not provide a comprehensive compiler/linker/transitive-system-file closure or bitwise reproducibility proof. No such broader claim is needed for this gate.

4. **Medium significance — resource and isolation bounds must stay precise.** Both stages inherited the allowed CPU set of 36 and applied 64 GiB per-process RLIMIT_AS plus disabled core dumps. Recorded memory/disk headroom exceeds the explicit preflight thresholds. This is not an aggregate memory bound, CPU reservation, universal namespace/syscall confinement, or proof that no competing native tool was running; these outer runners have no competing-tool assertion.

5. **Low significance — configuration warnings and historical failures are retained honestly.** The core, frontend and backend compiler/link logs contain no compiler warning/error lines. Configuration still reports unavailable Python development components and Doxygen, plus missing pkg-config during build10. Build10 explicitly warns that `RUN_LDCONFIG` was unused. Not invoking install is the relevant protection; the ignored variable supplies no safety credit. Earlier dependencies07 actually entered the container: apt update returned rc0 with DNS warnings, download returned rc100, and native/effective/outer were 1/1/1. Its `container_executed=false` is a success-path assignment artifact, not proof of nonexecution. Inspect01 preflight failure and static03 help rc1 remain failures. `AHLS-ENVIRONMENT01.md` is historical prerequisite evidence; its pre-build wording is superseded by the completed results, not evidence that these builds never happened.

## 3. Bounded FINAL recommendation

Recommend that the parent accept and publish **metadata/evidence for these completed AHLS-image frontend/core compile-link and DFL/VFIO backend builds only**, retaining the warnings and boundaries above. Keep raw archives, embedded-payload launchers, package payloads and binaries local with size/SHA references. No unchanged native rerun is warranted for completeness, and no hardware gate is added by this review.

Do not promote this recommendation into permission to execute the frontend, load a backend, run discovery/help through OPAE, install the scratch artifacts, or perform hardware operations. Endpoint/driver/IOMMU behavior, MMIO, clock/reset/recovery, DDR, transfers, numerical AHLS, buffer/fence lifecycle, timing/full-design closure and boot remain unqualified. **The overall hardware goal is incomplete. Vendor DDR simulation remains SKIPPED BY USER.**

Review activity used only local inert reads, stdlib parsing/decompression/hashing and this report write. No SSH, network, git, vendor/compiler/simulator/container/application/library/device execution, tests, installation, maintained-source changes, commit, publication or task transition was performed. Only `apptainer-independent-review01.md` was created as the review deliverable. Parent alone decides acceptance/publication.

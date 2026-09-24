# Completed AHLS-image compile/link and backend-build evidence

**Native completion verified; independent/parent gate acceptance pending.**

The source-bound frontend compiled/linked in the existing Ubuntu 22.04.5 SIF using GCC 11.4.0, actual OPAE 2.13.0 SDK sources and unpacked Ubuntu dependencies. [Parent reduction](apptainer-parent-verification01.json) binds the receipts and every exported member; [scope](APPTAINER-SCOPE01.md) defines the claim boundary.

| Acquisition | Inner commands | Native/effective/outer | Exports | Result |
|---|---:|---|---:|---|
| build10 | 10 | 0/0/0 | 17 | Four package extractions, SDK configure/core build, frontend configure/build, two static ELF reads |
| backends11 | 8 | 0/0/0 | 21 | SDK reconfigure, named backend build, six static ELF reads |

Each stage binds 1,177 tracked SDK entries before/after. Backends11 copied and verified 568 original build-tree file/link entries; its predecessor remains unchanged. The SIF, wrapper and real Apptainer executable match the captured identities. Both outer native commands ended without timeout, observed residual children, or final owned survivors. See the raw `result-apptainer-*.json.gz` and `outer-apptainer-*.json` receipts, not old heartbeat notifications.

## Artifacts and deliberate delta

- Frontend: 43,336 bytes, SHA256 `2d6d0de6d59fb9681f1fb83aaacb60a06d1d771b761fc579dc7b3e013aed6cc2`, retained unchanged in backends11, remote mode0600 set after link in build10.
- Core `libopae-c.so.2.13.0`: 589,816 bytes, SHA256 `1947fa09b223734acbe49f330ea5c75ea0ba0156296978fa4598f30745dda6f4`, byte-identical across both stages.
- Backends11 produces `libopae-v.so`, `libxfpga.so`, `libopaevfio.so.2.13.0`, `libopaeuio.so.2.13.0`, and `libopaemem.so.2.13.0`; exact sizes/hashes are in the parent reduction.
- The sole reconfiguration option delta is `OPAE_BUILD_LIBOPAEUIO=OFF` to `ON`, required by xfpga's source-defined `opaeuio` dependency. The read-only SDK sources and frontend are unchanged. No Python bindings/tools/tests/install target was requested.
- `tests/framework/mock/opae_std.c` is part of the SDK's ordinary core/backend targets: its captured functions delegate to libc open/read/ioctl/etc. Its directory name does not mean these compiled runtime libraries are the inert frontend mock. See `sdk-backend-sources03.json` and target CMake source captures.

## Dependency acquisition and retained failures

`dependencies07` failed DNS resolution to Ubuntu archives. Apt update returned warnings, and download then failed rc100; outer1. Preserve its logs/receipt. The old `container_executed` boolean is assigned after command success and must not be used to deny that failed container execution: actual native argv/logs establish what ran.

The agent host fetched Jammy-updates InRelease and verified it with gpgv using the Ubuntu archive public keyring extracted from the unchanged SIF. Verified signed-index SHA256 and every package size/SHA before transferring four packages. No package installation scripts or system install were run: `dpkg-deb --extract` only into owned prefix. `ubuntu-dependencies08/verified-packages01.json` and `signature-verification.json` retain provenance. Json-c is 0.15-3~ubuntu1.22.04.2; uuid is 2.37.2-4ubuntu3.6. These unpacked dependencies supplement, not modify, the image. Earlier PATH/help discovery failures remain preserved too.

## Warnings and scope limits

- Core and backend compile logs have no compiler warning/error lines. Configuration reports missing Python development pieces, pkg-config during build10, and unavailable Doxygen; these optional targets were not built. Build10 warns that `RUN_LDCONFIG` was unused. Its safety comes from not invoking install, not from that ignored variable.
- Both stages use the inherited all-allowed CPU set (36) and 64GiB per-process RLIMIT_AS; recorded memory/disk headroom passed. No comprehensive toolchain/transitive-system-file closure or aggregate-memory sandbox is claimed. The outer runner captures resource headroom but has no competing-native-tool assertion in these particular container stages.
- Build10 frontend DT_NEEDED is `libopae-c.so.2`, `libc.so.6`; no frontend RPATH/RUNPATH. The SDK library/build-plugin RUNPATHs refer to `/work/sdk-build/lib` and/or `/work/prefix/usr/lib/x86_64-linux-gnu`. These are build-context paths, not an installed deployment or a proven loader configuration.
- `--containall --cleanenv --no-home --no-mount sys,hostfs,cwd,bind-paths` plus explicit owned `/work:rw` and SDK `/sdk:ro` binds were used. The inner source rejects exposed vfio/dfl/fpga/uio device names. This is not a universal syscall or namespace-isolation proof. Do not execute a hardware frontend or load plugins as a next 'verification' shortcut.
- No installed backend was selected or initialized; no frontend/OPAE library was run for help or discovery. Live endpoint/driver/IOMMU/clock-reset/recovery, MMIO, DDR, transfers, numerical AHLS, lifecycle, timing/full closure, and boot remain unqualified.

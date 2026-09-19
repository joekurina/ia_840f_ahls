# Upstream baseline review: IA-840F standard/USM modernization

## Decision and scope

Source review retrieved **2026-09-18 UTC (2026-09-17 PDT)**. The existing lock correctly identifies the latest published release of **OFS/ofs-agx7-pcie-attach** as **`ofs-2025.1-1`**, but it is **not a qualified oneAPI combined release**. Its release notes explicitly say oneAPI has not been validated and direct oneAPI users to **OFS 2024.2-1**. The requested **Quartus Pro 26.1.1** is outside both this FIM release's documented Quartus version and Intel's published FPGA-capable oneAPI 2025.0 support range.

Keep the older BittWare IA-840F vendor sources as the board-port baseline, with distinct standard and USM variants. Use the existing newer sources as pinned modernization donors, not as evidence of qualification. Do not replace IA-840F hardware identity, DDR topology or board management with a reference-development-kit configuration. No repository switch or lock modification was performed.

This review read source, Git identities and official HTTP documents only. No setup/configure, IP generation, compilation, simulation, tests, installation, workstation/hardware access, commits or pushes were performed. Source presence, XML declarations and API implementations do not establish successful synthesis, runtime interoperability or hardware behavior.

## 1. Exact upstream identities and release semantics

The four local donor HEADs matched `new/sources.lock.json`; their tracked working trees were clean at collection. The GitHub default heads also matched these pins when retrieved.

| Component | Existing immutable commit | Observed upstream identity |
|---|---|---|
| Agilex 7 PCIe FIM | `599ac052eafbc9cede22561c099233ae4a54cb7d` | `ofs-2025.1-1`; default branch `release/ofs-2025.1`; published 2025-07-03 |
| FIM common gitlink | `34a8540697fdf3d66fbcaa263fa037bae17cc32f` | Exactly the FIM gitlink and remote `ofs-2025.1-1` tag |
| PIM (`ofs-platform-afu-bbb`) | `3c21189e728009d4c492fa2be54c0ab1008b06dc` | Default `master`; latest published release `ofs-2024.3-1` is a different commit, `85b5c4da78da6912ea43b5ec96fdb203e0a0acdf` |
| AFU examples | `4a1350e3c9e223d8bac3cb47f756a1d919ef8de1` | Default `main`; `ofs-2026.1-1` exists but is marked **prerelease** |
| oneAPI ASP | `1af2ca74c452cb6ebbf54beb86e758e53489e826` | Default `master`; GitHub latest release is `ofs-2024.2-2`, `76ba584312fcc1e08c76407f26b2034d315fd53e` |
| ASP MPF/BBB gitlink | `6f185d10be192d05ecb2b77dfe3df1c4f9b3f859` | Exactly the ASP gitlink and initialized local submodule HEAD |

The newer ASP `ofs-2024.3-1` tag resolves to `dd16ca0ade960133a4878b05874b2c88af3493ce`, but its release is marked **prerelease**. A newer tag/date does not establish a newer stable ASP release. Similarly, the examples `ofs-2026.1-1` does **not** establish an OFS Agilex 7 FIM 2026 release. The examples `/releases/latest` endpoint returned `ofs-2024.1-1` even though its release listing contains a newer non-prerelease `ofs-2024.3-1`; therefore API “latest”, chronologically newest release, tag and default branch are recorded separately rather than conflated.

Evidence: `../reference/modernization-upstream/retrieval-index.json`, `*-tags.json`, `*-releases.json`, `*-releases-latest.json`, `*-metadata.json`, `*-default-head.json`, `fim-common-tag-ref.json`, `submodule-verification.json`. The tag/release listings returned fewer than the requested 100 entries for each repository; the FIM list contains eight releases and eight tags, ending at `ofs-2025.1-1` at this observation. This is a bounded statement about the specified repositories, not every OFS project or unpublished release.

Official sources:

- [FIM release notes, ofs-2025.1-1](https://github.com/OFS/ofs-agx7-pcie-attach/releases/tag/ofs-2025.1-1).
- [Pinned FIM README](https://github.com/OFS/ofs-agx7-pcie-attach/blob/599ac052eafbc9cede22561c099233ae4a54cb7d/README.md).
- [ASP stable release, ofs-2024.2-2](https://github.com/OFS/oneapi-asp/releases/tag/ofs-2024.2-2).

## 2. Dependency coherence: newest donors versus documented BKC

### FIM 2025.1

The FIM 2025.1 release explicitly specifies Quartus Pro **25.1**, no Quartus patches, OPAE **2.14.0-3**, OPAE SIM **2.14.0-1**, driver **intel-1.12.0-3**, and FIM common **ofs-2025.1-1**. It reports RHEL 9.4/kernel 5.14.0 for its tested OS environment. The exact FIM-common tag/gitlink relationship was verified.

**No exact coordinated PIM or ASP commit/tag for oneAPI-on-FIM-2025.1 was found in the retrieved FIM release notes, root README, ASP root/board READMEs or inspected dependency scripts.** This absence is consistent with the release's explicit oneAPI-not-validated warning; it is not a claim that no external document or future combination could exist.

The [pinned FIM-common PIM setup script](https://github.com/OFS/ofs-fim-common/blob/34a8540697fdf3d66fbcaa263fa037bae17cc32f/scripts/common/syn/pim/setup_ofs_platform_afu_bbb.sh#L40-L81) defaults to `master`, tries a matching FIM `ofs-*` tag when present in the PIM repository, and warns in comments that taking latest HEAD can introduce incompatibility. The retrieved PIM tag inventory has **no `ofs-2025.1-1` tag**. The script is a selection heuristic, not a qualification manifest. The [ASP build script](https://github.com/OFS/oneapi-asp/blob/1af2ca74c452cb6ebbf54beb86e758e53489e826/iseries-dk/scripts/build-asp.sh#L66-L79) similarly falls back to cloning PIM `master` through an OPAE URL if no PIM is supplied. It does not pin a coordinated commit. These scripts were read, not executed.

### Explicitly documented oneAPI reference combination

The [versioned OFS 2024.2-1 ASP getting-started guide](https://ofs.github.io/ofs-2024.2-1/hw/common/user_guides/oneapi_asp/ug_oneapi_asp/) section 2.2 explicitly selects PIM `ofs-2024.2-1`; Table 2-4 selects FIM `ofs-2024.2-1` and ASP `ofs-2024.2-2`:

| Role | Documented tag | Exact commit resolved from official tag inventory |
|---|---|---|
| FIM | `ofs-2024.2-1` | `ab9d0728a68caa353d720c837237f54eb88db6f8` |
| PIM | `ofs-2024.2-1` | `e0251f7d00f37176df7f63c15fd9ad4ab609137e` |
| ASP | `ofs-2024.2-2` | `76ba584312fcc1e08c76407f26b2034d315fd53e` |

That BKC specifies Quartus Pro **24.1** with **0.18, 0.26 and 0.02iofs**, OPAE **2.13.0-3**, driver **intel-1.11.0-2**, RHEL 8.8/kernel 4.18.0-dfl. Its oneAPI row says **“Latest version”**, not an immutable compiler version; do not reinterpret that historical wording as permission to install current non-FPGA oneAPI. The ASP release notes discuss a oneAPI 2024.2 patch, but this review does not invent a single exact compiler patch-level BKC from that mention.

These alternative tags are **reference evidence only**. The repositories and lock were not changed. The existing independently pinned donor set remains suitable for source comparison, but must retain its “not vendor-qualified combined release” classification.

## 3. Actual reference host-pipe evidence

Distinguish three different facilities:

1. PIM `host_chan`: a host PCIe/MMIO/DMA interface, not automatically a SYCL host pipe.
2. ASP I/O pipes: compiler kernel streams connected to external I/O, here UDP/HSSI.
3. SYCL host pipes: runtime-mediated host/kernel pipes, with distinct non-CSR hostchannel and CSR-backed implementations.

### Board inventory at ASP `1af2ca74c452cb6ebbf54beb86e758e53489e826`

All ten `board_spec.xml` files for the four requested board directories were inspected. XML parsing excludes commented-out interfaces.

| Reference board | Variants inspected | Actual active channel declarations | Supported conclusion |
|---|---|---|---|
| `fseries-dk` | standard, USM | None | No board-specific streaming host-pipe implementation established |
| `iseries-dk` | standard, USM | None | Same; USM is a memory path, not host-pipe evidence |
| `iseries-dk_2link` | standard, USM | None | Two PCIe links do not imply host pipes |
| `n6001` | standard, USM | None | No channels declared in these variants |
| `n6001` | `ofs_n6001_iopipes`, `ofs_n6001_usm_iopipes` | Each has eight 64-bit `udp_out_0..7` sinks and eight 64-bit `udp_in_0..7` sources | Real **UDP/HSSI I/O** reference path, not proof of PCIe CPU host-pipe transport |

Pinned citations:

- [F-series variants](https://github.com/OFS/oneapi-asp/blob/1af2ca74c452cb6ebbf54beb86e758e53489e826/fseries-dk/README.md#L30-L39).
- [I-series standard XML](https://github.com/OFS/oneapi-asp/blob/1af2ca74c452cb6ebbf54beb86e758e53489e826/iseries-dk/hardware/ofs_iseries-dk/board_spec.xml) and [two-link variants](https://github.com/OFS/oneapi-asp/blob/1af2ca74c452cb6ebbf54beb86e758e53489e826/iseries-dk_2link/README.md#L30-L39).
- [N6001 I/O-pipe declarations](https://github.com/OFS/oneapi-asp/blob/1af2ca74c452cb6ebbf54beb86e758e53489e826/n6001/hardware/ofs_n6001_iopipes/board_spec.xml#L50-L83), [USM I/O-pipe declarations](https://github.com/OFS/oneapi-asp/blob/1af2ca74c452cb6ebbf54beb86e758e53489e826/n6001/hardware/ofs_n6001_usm_iopipes/board_spec.xml#L54-L87), and [variant descriptions](https://github.com/OFS/oneapi-asp/blob/1af2ca74c452cb6ebbf54beb86e758e53489e826/n6001/README.md#L30-L46).
- [Actual UDP engine](https://github.com/OFS/oneapi-asp/blob/1af2ca74c452cb6ebbf54beb86e758e53489e826/common/hardware/common/build/rtl/udp_offload_engine/rtl/udp_offload_engine.sv#L6-L108): `INCLUDE_IO_PIPES` gates the module, kernel AVST streams enter TX/RX, and the non-loopback branch connects to `hssi_pipes`. Comments call these streams “hostpipe”, but the instantiated endpoints are Ethernet. `kernel_wrapper.v` supplies the matching UDP kernel ports.

The versioned [ASP reference manual](https://ofs.github.io/ofs-2024.2-1/hw/common/reference_manual/oneapi_asp/oneapi_asp_ref_mnl/) section 2.1.8 defines `channels` as kernel-to-I/O streaming; its hardware description calls the path kernel-to-HSSI. This agrees with the source trace.

### Non-CSR MMD channels: bounded negative result

A recorded search of upstream `common/source/host` and `common/source/include` C/C++ source/header files found only the four `aocl_mmd_hostchannel_*` declarations in `include/aocl_mmd.h` (lines 376, 392, 414, 437), not implementations in the inspected host source. The corresponding vendor directories yielded the same declaration-only result. No binary symbol/runtime export audit was performed. Declaration-only findings cannot establish an implemented streaming transport.

The complete tracked ASP keyword search (`host.?pipe`, `hostchannel`, `csr_stream`, channel declarations and UDP endpoints) and board inventory are saved. The official ASP reference manual does describe all four hostchannel APIs in sections 4.1.12–4.1.15; those interface specifications do not supply the missing board-specific implementation in the inspected source. The result does **not** establish that all possible host-pipe routes are unavailable.

### CSR host pipes must remain a separate question

Pinned official Intel runtime source **`32a36fe51d3bab2c7caff98e744e7ee3dd55da7d`** proves a distinct source path:

- [`acl_program.cpp:1349–1365`](https://github.com/intel/fpga-runtime-for-opencl/blob/32a36fe51d3bab2c7caff98e744e7ee3dd55da7d/src/acl_program.cpp#L1349-L1365): `implement_in_csr` bypasses `hostchannel_create` and stores the CSR address; the other branch creates a physical hostchannel.
- [`acl_hal_mmd.cpp:3122–3135`](https://github.com/intel/fpga-runtime-for-opencl/blob/32a36fe51d3bab2c7caff98e744e7ee3dd55da7d/src/acl_hal_mmd.cpp#L3122-L3135): CSR pipe access uses ordinary synchronous MMD kernel-interface reads/writes.
- [`acl_auto_configure.cpp:654–690`](https://github.com/intel/fpga-runtime-for-opencl/blob/32a36fe51d3bab2c7caff98e744e7ee3dd55da7d/src/acl_auto_configure.cpp#L654-L690) parses host-pipe metadata; `acl_hostch.cpp` contains CSR access/handshake branches.
- The pinned ASP implements ordinary `aocl_mmd_write` and `aocl_mmd_read` in `common/source/host/mmd.cpp:1214,1262` and reports its kernel interface at lines 1045–1046.

This is **runtime source evidence, not a completed reference-board host-pipe design or a verified installed runtime**. No compiler-emitted CSR host-pipe metadata/RTL for these reference boards was established by this review. No source-supported basis was found to advertise a functioning IA-840F host-pipe feature yet. If pursuing the CSR route later, prove compiler metadata, CSR reachability and runtime behavior independently; do not require nonexistent non-CSR exports as its only gate, and do not call it DMA streaming or infer unrelated device-memory fence semantics.

**Modernization consequence:** keep hostpipes conditional/unadvertised pending an actual applicable reference implementation and later qualification. Do not invent a custom PCIe transport merely because N6001 offers Ethernet I/O pipes.

## 4. Local vendor baseline

The actual reference root is `old_bsp/ia-840/IOFS_BUILD_ROOT/` beneath `new_bsp`; the lock's `../old_bsp/...` is relative to its `new/` location. Both vendor IA-840F XML variants were saved with source paths and SHA-256 hashes:

- `oneapi-asp/ia840f/hardware/ofs_ia840f/board_spec.xml`
- `oneapi-asp/ia840f/hardware/ofs_ia840f_usm/board_spec.xml`

Both specify model `agfb027r25a2e2v_dm.xml`, XML board version `22.4`, two 512-bit DDR interfaces and no `channels` interfaces. The USM variant adds `global_mem name="host" allocation_type="host, shared"` and a `kernel_mem` interface; this is memory capability evidence, not a host-pipe claim. The inspected vendor `ofs_top.qpf` source records Quartus **23.1**, illustrating why the XML `version="22.4"` is not a reliable current Quartus-version assertion.

These are authoritative local board-source inputs for this review, not independently verified provenance for old fitted databases. No old binary/QDB/image was promoted into the new platform.

## 5. Quartus 26.1.1 and FPGA oneAPI compatibility

| Evidence boundary | Documented fact | Consequence |
|---|---|---|
| Vendor source | Existing IA-840F project files record 23.1 | Board source is useful; old fitted databases are not evidence for 26.1.1 compatibility |
| Latest named Agilex 7 FIM release | `ofs-2025.1-1` names Quartus Pro 25.1 and says oneAPI not validated | Not a validated 26.1.1 + oneAPI baseline |
| Documented OFS oneAPI BKC | FIM 2024.2-1 / PIM 2024.2-1 / ASP 2024.2-2 with Quartus Pro 24.1 + listed patches | A coherent historical comparison point, not an automatic IA-840F qualification |
| Intel oneAPI compiler system requirements, 2025 page | FPGA **2025.0 only**; Agilex 7 supported Quartus Pro range **22.3 to 24.2** | **26.1.1 is outside the published range**; even FIM 25.1 exceeds it |
| Intel FPGA support-package notice | Integrated FPGA support removed starting with compiler **2025.1** | Installing newer generic oneAPI is not a documented fix |

Sources: [Intel system requirements](https://www.intel.com/content/www/us/en/developer/articles/system-requirements/oneapi-dpcpp/2025.html) (retrieved page ID 846316, updated 2025-10-27), and [FPGA support-package notice](https://www.intel.com/content/www/us/en/developer/tools/oneapi/fpga.html). Complete extracted pages are retained in `official-document-extracts.json`.

The ASP release notes say newer unsupported Quartus versions can be **evaluated** and may elicit compiler warnings. Evaluation permission is not validation. This review neither claims the requested combination works nor asserts it cannot ever work. Installed 26.1.1 and oneAPI patch versions remain user-reported/uninspected. A separate generated-RTL/AHLS integration flow does not itself supply the oneAPI acceleration compiler, BSP ABI or runtime compatibility.

## 6. Evidence and remaining gates

All retained evidence is under `new/reference/modernization-upstream/`:

- `retrieval-index.json`, release/tag/API JSON: observed upstream state and local HEADs.
- `additional-retrievals.json`: additional source URLs, retrieval times and downloaded-byte hashes.
- `submodule-verification.json`: exact gitlinks versus initialized HEADs.
- `official-document-extracts.json`: four official documentation pages, including BKC and tool support boundaries.
- `source-snapshots/` and `source-snapshot-manifest.json`: selected unmodified donor/vendor source bytes and hashes.
- `board-channel-summary.json`: parsed active XML channel and memory declarations.
- `hostpipe-source-inventory.json`, `mmd-bounded-search.json`: bounded search scopes and line-numbered results, including vendor observations.
- `runtime-*.txt`: immutable-commit Intel runtime source evidence, not an installed-runtime claim.
- `evidence-manifest.json`: hashes for the retained evidence files (excluding itself).

Before claiming a working modern standard or USM BSP, the project still requires an explicitly approved toolchain choice, source/IP migration review, fresh matching FIM/PR/ASP artifacts, and runtime/hardware qualification. Host-pipe support additionally needs an identified reference-backed path and compiler/runtime/board integration evidence. None of those execution gates was authorized or performed here.

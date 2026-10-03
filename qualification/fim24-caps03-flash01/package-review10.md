# FINAL — PASS WITH LIMITS

**Scope:** independent, local read-only review of actual `conversion06` file packaging; no execution/replay of CMake, Quartus, SDK, remote or hardware operations. **File-package blockers: 0. Hardware/deployment readiness: false.**

## Frozen evidence and provenance

Read `package-freeze09.json` first and verified its SHA256 `6386e2393baea95af7327f326a9a656ac942ac6abb8d428a8c2f40f9ccd6d907`. Independently verified **20/20 members**, including full actual SOF/RPD bytes, against both size and SHA256; **0 mismatches**. Reconciled **8/8 local exports** with `conversion06/index.json:185–225` and the runner's embedded CMake/GBS-control bindings. The proprietary SDK capture was parsed locally only; no source body or new capture is reproduced here.

The selected SOF matches `../fim24-caps03-assembly01/assembly-acceptance28.json:20–29`; consumed `GBS-ACCEPTANCE34.json` is accepted **offline-only PASS WITH LIMITS**, not hardware approval. The assembly's 19 warnings and inherited STA/CDC/reset/electrical limits are not erased by this conversion's warning-free result.

## Actual native result and concrete acceptance

`conversion06/readback/result.json:7–101` records configure plus three direct CMake targets: **4/4 CMake exits 0**, no timeout, and empty owned live groups after draining; `conversion06/index.json:227` records **outer exit 0**. The three native PFG zeros are inferred from successful direct single-command targets, **not independently captured vendor wait statuses**. Each native log independently contains exactly one PFG invocation, **26.1.1 Build 130**, and a success footer with **0 errors, 0 warnings**.

`candidate05/CMakeLists.txt:5–15` and `conversion06/readback/conversion.log:17–45` establish one actual `quartus_pfg -c` using the accepted migrated SOF with JIC/MAP/RPD outputs and exactly `device=MT25QU02G`, `mode=ASX4`, `flash_loader=AGFB027R25A`, `bitswap=OFF`. Concrete acceptance is established by this run and its outputs, not merely help availability. `PFG-SOURCE-BASIS05.json:15–18` retains the earlier help02 wrong-banner collector rejection/recovery; no native replay is required.

Source SOF, tools and controls are all recorded preserved (`result.json:180–182`; runner `convert06.py:67–92`). Local SOF/control bytes and embedded bindings agree. Recorded launcher/native PFG hashes are respectively `06c1bd805bc078d9636015c472e09a054160c405f3f06b7c555e7a4b6f7d3f14` and `e9b5587f7308bdc245bfea0bd5d6d135f47b96faba006798b95b8e5a371ca3b1`; this is retained conversion-time evidence, not a fresh live installation attestation.

## Native information, actual artifacts and layout

SOF and JIC native information agree on **AGFB027R25A2E2V**, **Active Serial x4**, and SOF checksum **0x76DE5159** (`source-info.log:41–53`, `image-info.log:93–108`, under `conversion06/readback/`). JIC names **MT25QU02G** and four CMF copies at `0x00000000`, `0x00040000`, `0x00080000`, `0x000C0000`, all version **0x1A010100 (26.1.1)** (`image-info.log:41–87`).

| Artifact | Bytes | SHA256 |
|---|---:|---|
| Accepted SOF, locally verified | 10067421 | `00dbd01b5b8c7c0b49fb1f9340ac9464e61a634ff045a1c0c4b79a464175d46f` |
| RPD, locally verified | 10670080 | `96fb0dc9e0716a712f9e77a09b11161ac495a6e16436beb756bf7fd04874647e` |
| MAP, locally verified | 364 | `818df1df710349adf3b6720508ea3a91481a25162bb3ec304fb4eba3dcc0ffc2` |
| JIC, remote retained only | 268435686 | `2e6f6bb02b04a511ba03cb4b93feab16f7570073826b46b15e989c552feacd1c` |

JIC identity/location comes from `result.json:164–167`: `/home/uwb_student00/ahls/new_BSP/work_fim24_caps03_flash01/convert05/migrated-caps03-sdk.jic`. **No local JIC export or independent local JIC hash check is claimed.**

Actual `migrated-caps03-sdk.map:3–15` has exactly **2 contiguous byte-addressed regions**: BOOT_INFO `0x00000000..0x001FFFFF`, P1 `0x00200000..0x00A2CFFF`; their combined extent equals the actual RPD length. Together with native four-CMF evidence and the established predecessor route (`../caps03-flash01/ACCEPTANCE48.md:7–8`, `SDK23.md:21–24`), this qualifies a **complete single-application non-RSU package at 0x00000000**, not an RSU user-slot payload at `0x04000000`. Prior-image programming/boot does not prove this migrated image boots.

## Writer orientation and literal erase footprint

Historical source provenance is `../caps01-bwflash01/source01-result.json`, SHA256 `67f61bac050d149cf00caa6ef5a9c034432598fac07a77d4ecfa9a81120d81b9`. Its embedded `bw_agilex/tools/bw_agilex_flash_programmer.py` hash is `d114deddc47bd4daf7d0dfa4ca012f5b6e24adb27535a39f3b1c2a86a4351c63`; lines **70–327, 338–366** define the LUT/reader, and **438–458** perform erase/write/full-length readback/compare. Independently checked **256/256 literal LUT entries** against byte bit reversal. This reverses bits within each byte, not byte order; applying it to the actual OFF RPD gives SHA256 **`f7cc592f86182c792a5a8fdfc1347dfefd3299c538760a1d98e51fb50976772e`**, unchanged length. Its 64-byte input header matches the established predecessor's input convention. No transformed file was written.

Captured `bw_agilex/components/sdm_mailbox.py`, SHA256 `f51ccfe1804709042dc8c221fbf8c7eca685355d7ff23e09a1a7dc3ab7c31084`, lines **207–209, 631–678**, uses sector mask **0xFFFF**, **0x4000 words / 65536 bytes**, and permits erasure to the sector end by default. For this nonaligned payload, its literal adjustment clears the low sector bits then adds the **word-count constant**, yielding **10633216 adjusted bytes**; integer conversion of the adjusted byte/sector ratio plus one yields **163 sectors**. At address zero the erase covers **10682368 bytes**, through **0x00A2FFFF**, including **12288 bytes beyond the RPD**. This reproduces the captured algorithm, **not an idealized ceiling replacement**, and independently agrees with `package-reconciliation08.json`.

## Limits and remaining live gates

Power/VID metadata is deliberately not flattened: SOF reports **Version 1**, JIC **Version 2**; both report VID enabled, **PMBUS_SLAVE**, address **01** (`source-info.log:77–82`, `image-info.log:132–137`). Conversion and matching reported fields provide no independent electrical qualification.

Before any later SDK action, the parent must freshly bind installed CLI/programmer/mailbox sources, exact current management target and ownership, and the reviewed RPD/address/erase range. Captured SDK hashes are **historical**, not current installed/live-target bindings. No fresh pre-write device backup exists; retained packages are not device snapshots. Activation/reset/electrical and inherited functional obligations remain separate; no new sandbox, equivalence, vendor-internal or timing criterion is imposed here. **No SDK/card/BMC/reboot action occurred for this package; this FINAL neither authorizes hardware access nor closes the accelerator task.**

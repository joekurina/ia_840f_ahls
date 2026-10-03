# Migrated CAPS03 SDK flash package — accepted file artifact

The first Quartus **26.1.1 Build130** CMake-native SOF→JIC/MAP/RPD conversion and two file-info targets are independently accepted **PASS WITH LIMITS**. Four CMake commands returned0; native PFG zero is propagated through the three direct single-command targets, each with0 errors/0 warnings and owned drain. Source SOF, tools and controls remained unchanged. [Actual conversion06](conversion06/readback/result.json), [FINAL review10](package-review10.md), [parent acceptance13](PACKAGE-ACCEPTANCE13.json).

## Exact package and intended writer

| Artifact | Bytes | SHA256 |
|---|---:|---|
| Accepted full-device SOF | 10067421 | `00dbd01b5b8c7c0b49fb1f9340ac9464e61a634ff045a1c0c4b79a464175d46f` |
| SDK input RPD | 10670080 | `96fb0dc9e0716a712f9e77a09b11161ac495a6e16436beb756bf7fd04874647e` |
| MAP | 364 | `818df1df710349adf3b6720508ea3a91481a25162bb3ec304fb4eba3dcc0ffc2` |
| JIC, retained remote only | 268435686 | `2e6f6bb02b04a511ba03cb4b93feab16f7570073826b46b15e989c552feacd1c` |

The RPD/MAP are mirrored under `conversion06/readback/`; the JIC remains on the workstation at `work_fim24_caps03_flash01/convert05/migrated-caps03-sdk.jic`. **JIC is file-only collateral, not SDK input or JTAG authority.** Use only `bw_agilex_flash_programmer` with the accepted RPD; never pre-transform that input. [Native command](conversion06/readback/conversion.log), [recorded CMake](candidate05/CMakeLists.txt).

Native info binds AGFB027R25A2E2V, MT25QU02G, Active Serial x4, and identical SOF/JIC SOF checksum `0x76DE5159`. Four CMF copies are26.1.1. The map is a complete **non-RSU BOOT_INFO/P1** layout at address `0x00000000`: BOOT_INFO0..0x001FFFFF, P1 0x00200000..0x00A2CFFF. It is not an RSU user-slot payload at0x04000000. [Source info](conversion06/readback/source-info.log), [JIC info](conversion06/readback/image-info.log), [actual map](conversion06/readback/migrated-caps03-sdk.map).

## Writer orientation and erase prediction

`bitswap=OFF` follows the established SDK input convention. The captured reader's literal256-entry LUT reverses bits within each byte. Independently transforming this actual RPD gives SHA256 `f7cc592f86182c792a5a8fdfc1347dfefd3299c538760a1d98e51fb50976772e`; it is a prediction of writer representation, not a second file to flash. [Independent review](package-review10.md#writer-orientation-and-literal-erase-footprint).

The captured mailbox's literal erase arithmetic—not an idealized ceiling—predicts163 sectors/10,682,368bytes through0x00A2FFFF, including12,288padding bytes beyond the RPD. No fresh device backup or whole-flash snapshot is claimed. [Reconciliation08](package-reconciliation08.json), [reviewed footprint](package-review10.md#writer-orientation-and-literal-erase-footprint).

## Limits and reuse

This milestone accepts **file packaging only**, not flash write/readback, activation, boot, or hardware correctness. SOF Power/VID Version1 versus JIC Version2 is retained; shared VIDenabled/PMBUS_SLAVE/address01 does not independently prove electrical behavior. Existing STA/CDC/reset/electrical findings remain. Live SDK source/target/ownership/readiness, full built-in comparison, BMC Off/On readbacks, one normal reboot, new static FME identity and numerical/DDR gates are separate. [Review limits](package-review10.md#limits-and-remaining-live-gates).

Raw JIC/RPD/SOF, transport archives, embedded transfer launchers and proprietary SDK source captures remain local-only under the2,000,000-byte publication policy, with exact size/hash references. Metadata projections are not executable replacement launchers. Clean checkout lacks accepted images/native workspaces/licensed tools. No conversion, assembly, fitting or STA is to be repeated to reconstruct this accepted package. `main` remains the published fallback.

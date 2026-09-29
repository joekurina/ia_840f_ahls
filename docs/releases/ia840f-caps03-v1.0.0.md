# IA-840F CAPS03 v1.0.0 — build and SDK flashing instructions

This release tags the accepted **Work21-based CAPS03 memory-HLS integration** and adds an operator guide for building its components and deploying the retained full-device image. It is a source-and-documentation release, not a newly compiled image or certification of the entire `hls-samples` release.

## Start here

- [Build guide: toolchain, source pins, AHLS IP, Work21 prerequisites and native CMake stages](https://github.com/joekurina/ia_840f_ahls/blob/ia840f-caps03-v1.0.0/docs/ia840f-build.md)
- [Flashing guide: SDK RPD preparation, target binding, program/readback comparison, BMC Off/On and one reboot](https://github.com/joekurina/ia_840f_ahls/blob/ia840f-caps03-v1.0.0/docs/ia840f-sdk-flashing.md)
- [Accepted CAPS03 results and limitations](https://github.com/joekurina/ia_840f_ahls/blob/ia840f-caps03-v1.0.0/qualification/caps03-final01/ACCEPTANCE.md)

```bash
git clone --branch ia840f-caps03-v1.0.0 --single-branch \
    https://github.com/joekurina/ia_840f_ahls.git
cd ia_840f_ahls
```

The repository is private; use an account with access.

## Deployment contract

**`bw_agilex_flash_programmer` is the only IA-840F flash writer for this project. No JTAG repair or retry route is included.** Generate a writer-compatible RPD from the reviewed full-device SOF using Quartus Pro 25.1, `MT25QU02G`, `ASX4`, loader `AGFB027R25A`, and **`bitswap=OFF`**. JIC is conversion evidence, not SDK input. The accepted complete non-RSU image is programmed at **`0x00000000`**, not the RSU user-slot address.

Require the original writer's native exit 0, completed **erase, program and readback** phases, and `Flash programmed successfully.` after comparison. Only then follow the source-bound card quiescence, separate BMC Off/On readbacks and one workstation reboot in the guide. A flash write alone does not activate or functionally qualify an image ([deployment acceptance](https://github.com/joekurina/ia_840f_ahls/blob/ia840f-caps03-v1.0.0/qualification/caps03-flash01/ACCEPTANCE48.md)).

## Retained image identities

| Artifact | Bytes | SHA256 |
|---|---:|---|
| Full-device CAPS03 SOF | 10065141 | `8f778fca292cc77f87c196deb198d4798a1bd111999d69b0245d570fa2bfe276` |
| SDK input RPD | 10653696 | `0319b7fd35d968d73f02f9a6f49706cb249c3559dec1759a3f2d3a37122e4bcf` |

These identify the retained accepted artifacts; a new build is not automatically identical or accepted. Programming images, generated build databases, licensed tools and runtime binaries are **not attached or stored in Git**. The build guide identifies the external/native-workspace prerequisites; a clean clone is not a self-contained, one-command reproduction package ([artifact record](https://github.com/joekurina/ia_840f_ahls/blob/ia840f-caps03-v1.0.0/qualification/caps03-final01/ACCEPTANCE.md#retained-working-artifact)).

## Scope and known limits

- Accepted CAPS03 evidence covers the adapted DDRIP computation, host/DDR transfers, repeated and bulk numerical checks, and both complete 16 GiB logical DDR apertures. It is not acceptance of every upstream HLS sample.
- Quartus Pro **25.1.0 Build 129** and the **3.000 ns** target remain the selected baseline. Native **Design Closure FAIL** is retained for the disclosed bounded physical scope.
- Only the documented VF pending-before-FLR warning is accepted. General PR/cold/stopped-clock recovery and warning-free teardown are not claimed.
- This release adds documentation only. No new build, conversion, flash, BMC cycle, reboot or hardware test was performed to publish it. The stopped release-wide sample qualification was not resumed.

See [physical acceptance](https://github.com/joekurina/ia_840f_ahls/blob/ia840f-caps03-v1.0.0/qualification/caps03-persona01/PHYSICAL-ACCEPTANCE01.md) and [final qualification scope](https://github.com/joekurina/ia_840f_ahls/blob/ia840f-caps03-v1.0.0/qualification/caps03-final01/ACCEPTANCE.md).

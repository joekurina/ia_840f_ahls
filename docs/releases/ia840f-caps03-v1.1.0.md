# IA-840F CAPS03 v1.1.0 — FIM/PIM/AFU and AHLS GettingStarted

This release brings together the sources and evidence for the accepted **Work21 static FIM + PIM + CAPS03 memory-HLS AFU**, detailed build/deployment/host-run instructions, and the original HLS IP Gen 2026.1.0 GettingStarted tutorials with the verified Agilex 7 LSU family correction.

It is a source, documentation and qualification-evidence release. Publishing this tag does not rebuild, program or test the card. The retained hardware acceptance is unchanged; the newer tutorial correction was compiled and tested separately in emulation/RTL-simulation/isolated-IP modes as documented below.

## Checkout

```bash
git clone --branch ia840f-caps03-v1.1.0 --single-branch \
    https://github.com/joekurina/ia_840f_ahls.git
cd ia_840f_ahls
export REPO="$(pwd -P)"
```

The repository is private; use an account with access. The annotated `ia840f-caps03-v1.0.0` tag remains unchanged.

## Detailed operator instructions

Follow the hardware path in this order. Each guide identifies required external artifacts, exact recorded commands, expected results and the boundary between building and hardware access.

| Stage | Instructions |
|---|---|
| Understand, prepare or reuse the static FIM and matching PIM platform | [FIM/PIM workflow, source pins, platform export and clean-checkout prerequisites](https://github.com/joekurina/ia_840f_ahls/blob/ia840f-caps03-v1.1.0/docs/ia840f-fim-pim.md) |
| Generate AHLS IP and build the CAPS03 AFU against that static platform | [AHLS generation, selected source closure, native CMake synthesis/fit/timing/assembly](https://github.com/joekurina/ia_840f_ahls/blob/ia840f-caps03-v1.1.0/docs/ia840f-build.md) |
| Deploy the complete accepted FPGA image, if deployment is needed | [BittWare SDK RPD generation, program/readback comparison and activation](https://github.com/joekurina/ia_840f_ahls/blob/ia840f-caps03-v1.1.0/docs/ia840f-sdk-flashing.md) |
| Build the OPAE host and run the accepted AFU | [Host sources/build, DFL/VFIO prerequisites, numerical execution and shutdown semantics](https://github.com/joekurina/ia_840f_ahls/blob/ia840f-caps03-v1.1.0/docs/ia840f-run.md) |
| Build/run the original GettingStarted tutorials independently of the card | [Complete CPU/emulator, report, RTL-simulator, fast-recompile and full-IP commands](https://github.com/joekurina/ia_840f_ahls/blob/ia840f-caps03-v1.1.0/examples/ahls/README.md) |
| Understand/apply the tutorial compiler-input correction | [Pinned CMake preparation and private read-only LSU overlay](https://github.com/joekurina/ia_840f_ahls/blob/ia840f-caps03-v1.1.0/examples/ahls/compatibility/lsu-family/README.md) |

**These are two different execution paths.** The hardware path runs the adapted DDRIP computation through the project's OPAE/DFL host. The unmodified GettingStarted tutorial `fpga` target produces isolated IP characterization—not an IA-840F executable or flash image. Its `fpga_sim` executable runs RTL simulation, not the board. This release does not restore the old oneAPI BSP/MMD runtime.

## What is new since v1.0.0

- Imported the three upstream GettingStarted roots—`fpga_compile` PART1–4, `fast_recompile`, and `fpga_template`—at exact upstream commit `0abae6d78af5daca3fe5d67e617ab037e58aff89`. Original source/header/license/image bytes are preserved ([import manifest](https://github.com/joekurina/ia_840f_ahls/blob/ia840f-caps03-v1.1.0/examples/ahls/hls-samples/UPSTREAM.json)).
- Fixed missing `DEVICE` propagation at two HLS support-RTL bursting-read instantiations. A build-local `.DEVICE("Agilex 7")` configuration replaces the unintended legacy-family fallback without editing installed SDK files or primitive models ([correction](https://github.com/joekurina/ia_840f_ahls/blob/ia840f-caps03-v1.1.0/qualification/ahls-getting-started-fix01/RESULT.md)).
- Verified fresh corrected PART2/PART3/PART4/template simulations: each native build/run returned 0, checked all 256 original integer results, and had zero Error/Fatal in the complete transcript. Original failed diagnostics are retained ([native verification](https://github.com/joekurina/ia_840f_ahls/blob/ia840f-caps03-v1.1.0/qualification/ahls-getting-started-fix01/verification18.json)).
- Corrected the earlier timing interpretation: the handbook explicitly expects warnings from its intentional 1000 MHz standalone placement-characterization constraint. Use reported component Fmax, then qualify integrated timing separately. The corrected template full-IP build still reports **667.11 MHz**, with unchanged clock/resource QoR data and unchanged SDC ([timing evidence](https://github.com/joekurina/ia_840f_ahls/blob/ia840f-caps03-v1.1.0/qualification/ahls-getting-started-fix01/timing-interpretation07.json)).
- Added detailed static FIM/PIM and real OPAE host-run documentation, linked with the existing AFU build, SDK deployment and tutorial guides.

## Build prerequisites and artifact availability

The accepted implementation uses **Quartus Prime Pro 25.1.0 Build 129**, **HLS IP Gen 2026.1.0**, FPGA part **AGFB027R25A2E2V**, and the unchanged **3.000 ns integrated application target**. The tutorial simulator setup uses Questa-Altera FPGA Edition 2024.3. The HLS 2026.1/Quartus 25.1 compatibility warning remains visible; empirical passes do not make this a vendor-supported mixed-version combination ([setup and versions](https://github.com/joekurina/ia_840f_ahls/blob/ia840f-caps03-v1.1.0/examples/ahls/README.md#installed-setup)).

A clean clone contains source, native CMake snapshots and evidence—not the complete prepared Work21/platform/persona workspaces. Full-image rebuilding additionally needs the matching generated HLS/fabric inputs, static QDB/MSF/PMSF/SOF collateral, installed OPAE platform tools, source-bound stage preparation and licensed tools/support. Do not replace missing inputs with an unrelated platform or bypass old guards. The guides distinguish directly reproducible tutorial/host steps from these retained-workspace dependencies ([full-image checklist](https://github.com/joekurina/ia_840f_ahls/blob/ia840f-caps03-v1.1.0/docs/ia840f-build.md#8-clean-checkout-checklist)).

Programming images, build databases, licensed binaries, license files, transport payloads and files over the project's 2,000,000-byte publication cap are not release assets. Existing excluded artifacts remain hash-referenced; this tag is not a downloadable ready-to-flash binary distribution.

## Existing hardware image and deployment contract

| Retained artifact | Bytes | SHA256 |
|---|---:|---|
| CAPS03 full-device SOF | 10065141 | `8f778fca292cc77f87c196deb198d4798a1bd111999d69b0245d570fa2bfe276` |
| SDK-compatible input RPD | 10653696 | `0319b7fd35d968d73f02f9a6f49706cb249c3559dec1759a3f2d3a37122e4bcf` |

These identify existing accepted artifacts, not the guaranteed output of a future rebuild. **`bw_agilex_flash_programmer` remains the only flash route.** Use the reviewed SOF-to-RPD lineage with `bitswap=OFF`; a JIC is not writer input. Require the original operation's native exit 0, complete erase/program/readback phases and successful byte comparison before the separately authorized BMC Off/On and single-reboot activation sequence ([deployment guide](https://github.com/joekurina/ia_840f_ahls/blob/ia840f-caps03-v1.1.0/docs/ia840f-sdk-flashing.md)).

## Retained acceptance limits

The scoped hardware evidence covers the adapted DDRIP AFU, numerical copyback, repeated/boundary and bulk HLS tests, bank isolation and both full 16 GiB logical DDR apertures. Native **Design Closure FAIL** for the disclosed physical scope and the exact accepted VF pending-before-FLR warning remain recorded. General PR/cold/stopped-clock/active-failure recovery and every upstream HLS sample are not qualified by this release ([final hardware acceptance](https://github.com/joekurina/ia_840f_ahls/blob/ia840f-caps03-v1.1.0/qualification/caps03-final01/ACCEPTANCE.md)).

The broader release-wide HLS qualification remains paused/incomplete. This release neither restarts it nor turns the standalone tutorial results into new card execution. Its documentation was checked against committed source and actual retained receipts; no new native build, flash, reset, reboot or FPGA test was performed to publish the tag.

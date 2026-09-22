# W13 source-to-host access map — not live authorization

## Binding and limits

This map describes W13 source artifacts, **not the present running image or
current VF BDF**. [Source-binding comparison](../source-resume-01/w13-source-binding.json)
compares 116 captured W13 files against the existing
[fim-build-13 authorization inventory](../fim-build-13/compile-authorization.json):
116 match, zero mismatches. It is a selected-source comparison, not a new
full-tree inventory or timing acceptance.

W13 SOF SHA256:
`fe566004accde825cb910e69fd458f87669ad2c67f0c7f36e81a115f57298c37`.
Sanctioned persona GBS SHA256:
`198d57cf69c36a53702136b535ea79e5b402056c522fa4a76613d5b663ecd3c2`.
Both remain remote, unchanged; sizes/hashes are in
[source batch03 archive](../source-resume-01/batch03.json.gz). Historical interface UUID:
`c281e23b-5a95-5aa9-8678-d2ecf1f80f6c`; intended AFU UUID:
`67bc266a-56f7-440a-bb75-12b5f446d842`.

For citations below, `W` is the captured directory
`../source-resume-01/remote/home/uwb_student00/ahls/new_BSP/work_ia840f_fim_13/`.
`O` is captured `../source-resume-01/remote/home/uwb_student00/opae-sdk/`.
The relative paths and exact remote source hashes are preserved in batches.

## Function and BAR routing

| Host function | Source route | Meaning |
|---|---|---|
| PF0, VF_ACTIVE=0 | `afu_top` management PID → ST2MM → APF/BPF | FME/static management, not the AHLS CSR aperture |
| **PF0 VF0, VF_ACTIVE=1, BAR0** | PG shared-VF PID → port-gasket port 0 → PR slot → PIM host channel 0 → `ofs_plat_afu` | **AHLS AFU identity and CSRs** |
| PF1 | static-region route → BittWare BMC | Preserve; never bind/reset as a shortcut |

The chain is explicit in `W/src/afu_top/mux/top_cfg_pkg.sv:73–119`,
`W/ofs-common/src/common/lib/mux/pf_vf_mux_default_rtable.vh:77–98`,
`W/src/board/ia840f/afu_top.sv:416–481,508–532,634–702`, and
`W/ofs-common/src/fpga_family/agilex/port_gasket/afu_main_pim/port_afu_instances.sv:179–201,279–281`.
The last maps function-tagged stream 0 to `plat_ifc.host_chan.ports[0]` and
instantiates the selected AFU. The checked AHLS service binding connects that
channel to its MMIO interface (`afu/ahls/rtl/ahls_ofs_board_services.sv:31–39`).

**PF0 BAR0 + 0x80000 is the protocol checker.** `W/src/includes/fabric_width_pkg.sv`
and the board `afu_top.sv:328–359` connect `apf_achk_slv_if` to its CSR block.
`W/ofs-common/src/common/protocol_checker/protocol_checker_csr.sv:237–241`
emits type 3, EOL 1, revision 2, feature ID 0x10. The historical printed
`0x2010` combined revision and feature ID. Zero words there do not measure an
AHLS UUID. No scan of this region is warranted.

Saved active `core16` PCIe parameters specify PF0 and its VF BAR0 as 64-bit
prefetchable memory, address width 20. Generated
`W/syn/board/ia840f/syn_top/ofs_ip_cfg_db/ofs_ip_cfg_pcie_ss.vh:131–158`
confirms PF0+PF1, one PF0 VF and 20-bit PF/VF BAR0 decode. The effective byte
aperture is **1 MiB (0x00000–0xfffff)**, not the stale “20-bit / 2 MiB” comment.
Saved PCIe IDs are PF0 `8086:bcce`, VF `8086:bccf`, subsystem `8086:1771`.
See [scoped saved parameters](../source-resume-01/pcie-saved-contract.json).
Actual live BAR allocation, VF creation and binding remain unverified.

## OPAE enumeration path

The port-header hardcoded GUID in `pg_csr.sv` is not proof that AFU UUID
enumeration is impossible. The captured Linux DFL
`drivers/fpga/dfl-afu-main.c:515–533` reads GUID from `PORT_FEATURE_ID_AFU`,
not automatically from the port-header GUID. Its parser also requires an
associated FIU for that DFL path (`dfl.c:1405–1418`). Do not assume the
management port is the standalone VF.

A source-supported **VFIO backend** path exists for a standalone AFU:

- Installed OPAE is the locally built **2.13.0** tree at commit
  `5b228074a765473d25ee7f7e03168f2c146a826c`, with clean source status.
  Installed `libopae-c.so.2` is byte-identical to its build artifact.
  Installed `libopae-v.so` and `libxfpga.so` differ in whole-file hashes from
  build copies, but `.text`, `.rodata` and GNU build-ID sections match exactly.
  These distinctions are retained in batches 05–07; they are not hidden as
  whole-file equality.
- `O/libraries/libopae-c/cfg-file.c:40–73` searches LIBOPAE_CFGFILE, then home
  candidates, then `/usr/local/etc/opae/opae.cfg`, then `/etc/opae/opae.cfg`.
  The captured tmux environment had no override; earlier candidates were
  absent. Captured `/etc/opae/opae.cfg:498–527` enables `libopae-v.so` for
  `n6001_vf` (`8086:bccf/8086:1771`), matching W13's saved IDs. This is
  configuration applicability, not live binding evidence.
- `O/libraries/plugins/vfio/opae_vfio.c:1276–1328,1390–1403` applies PCI
  address/ID filters before walking a matched endpoint. The new frontend
  supplies domain, bus, device, function, vendor/device, object type and UUID.
- `opae_vfio.c:602–674` opens the matched endpoint, maps BAR0, reads its GUID
  at +8/+16, and when it is not a legacy FME creates an FPGA_ACCELERATOR
  token for BAR0 with MMIO offset zero. No arbitrary address sweep is needed.
- `opae_vfio.c:523–560` has a PF/VF-pair open only if the PF is also VFIO-bound;
  otherwise it opens the VF directly. This is not approval to rebind PF0.
  Device open/close semantics, VFIO kernel behavior, IOMMU isolation and
  present reset state still require the live safety review.

A BDF-filtered enumeration is **still hardware access**. Plugin initialization
and supported discovery may read sysfs or open/map endpoints. Never run the
native binary, even as an informal “enumeration-only” check, until its exact
finite operation is authorized and independent recovery is established.

## AFU-local register contract

All listed offsets are relative to **VF BAR0 / OPAE MMIO window 0**, not PF0.
Use only aligned 64-bit accesses for this test; no access at 0x74.

| Offset | Access | Contract / side effect |
|---|---|---|
| 0x00 | R64 | DFH `0x1000010000000000` |
| 0x08 | R64 | UUID low `0xbb7512b5f446d842` |
| 0x10 | R64 | UUID high `0x67bc266a56f7440a` |
| 0x40 | R64 | CSR v5 in bits 31:16; running bit 15, busy bit 2 |
| 0x48 | W64, value 1 | Start pulse via low word; no speculative writes |
| 0x70 | R64 | **Two-bit, clear-on-read finish counter**, zero-padded to 64 |
| 0xc0 | W64 | packed signed32 a in low half, b in high half |
| 0xc8 | W64 | signed32 mode in low half, high half zero |
| 0xd0 | R64 | signed32 result bit-pattern zero-padded to 64 |

Identity/aperture: `afu/ahls/rtl/ahls_mmio_aperture.sv:73–81`, W13
`afu_with_pim/afu/hw/ofs_plat_afu.sv:62–75,206–220`.
Generated CSR truth: `.../ahls_ip/qual_vec_op.report.prj/kernel_hdl/IDQualVecOp/IDQualVecOp_function_cra_agent.sv:435–471,526–546`.
The generated header misleadingly duplicates the finish macro at 0x30/0x34;
RTL resolves the semantics. The new test does not include that duplicate macro.
The AHLS aperture is 0x40–0x13f, but **not every address there is a supported
register**. The whitelist above is the entire test access set.

The AHLS clock/reset come from `plat_ifc.clocks.uClk_usrDiv2` through the PIM
CDC/service binding. The compiled persona uses automatic clock metadata;
current clock frequency, PLL lock, port reset and PR-freeze state are **not
live-verified**. The source does not make accesses safe while those are unknown.

## Finite future CSR test — BLOCKED, not an instruction to run

Prerequisites: exact current image/card/domain/VF BDF and BAR proven through an
approved identification procedure; reviewed timing disposition, supported
VFIO/OPAE ownership and IOMMU group; known clock/reset/quiescent state;
exclusive ownership; specific permission and verified independent host recovery.
No VF creation, binding, permissions, programming, reset or PR is implicit.

Sequence after those gates: filter for the single exact VF+UUID; fail on any API
error or zero/multiple matches; open/map OPAE window 0; verify three identity
words; require idle CSR v5; drain and verify zero on clear-on-read finish; write
packed args/mode and one start; require exactly one fresh completion within a
3-second software deadline; require idle and compare the entire result word
against the exact eight-element XOR reference. Stop on first error. The full
staged test contains 12 cases, including repeats and defined signed boundaries.
A preliminary one-case operation would be a separately reviewed subset, not a
raw-window fallback.

The software deadline cannot contain a hung MMIO transaction. On timeout,
disconnect, unexpected response or blocked task: no retry, alternate probe,
reset, rebind or programming. Backend close may have kernel-side consequences;
its safety is part of the operation review, not guaranteed by this code.

This AFU ties both memory masters idle. It cannot qualify DDR or host transfers;
separate source-bound reference DMA/memory integration is still required.

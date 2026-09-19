# IA840F FIM: AHLS source-only dependency review

## Scope and status

**Not ready for build.** The target is Altera AHLS with OFS and retained Quartus
26.1.1, not a mandatory oneAPI compiler flow. Changing the application compiler
does not qualify the board IP, FIM interfaces, clocks, reset protocols or PR flow.
No build, configure, setup, IP generation, HDL/Tcl execution, tests, vendor tools,
workstation access, installation, commit or push was performed for this review.

Paths below are relative to `new/ofs-agx7-pcie-attach/`, unless marked vendor.
Vendor root is `old_bsp/ia-840/IOFS_BUILD_ROOT/ofs-ia840f/` relative to `new_bsp/`.
Read-only Git inspection confirmed the reference checkouts at:

- OFS FIM: `599ac052eafbc9cede22561c099233ae4a54cb7d`.
- OFS common: `34a8540697fdf3d66fbcaa263fa037bae17cc32f`.

## Corrections made

1. Added `memory_groups = 2` to the deliberately pending
   `syn/board/ia840f/config/ia840f_memory.ofss`. This follows the actual mixed-memory
   reference `tools/ofss_config/memory/memory_rtile_8g_rdimm.ofss`, not a guessed
   field. `ofs-common/tools/ofss_config/gen_ofs_settings.py:79-94` defaults an
   omitted field to one and uses it to request simulation models. The vendor's
   discrete and RDIMM channels require distinct model configurations. This field
   **does not determine or validate physical interface group numbering**.
2. Updated the manifest's mandatory toolchain blocker to
   `supported Altera AHLS/OFS/Quartus 26.1.1 toolchain and board-IP qualification`.
3. Updated only the changed configuration's current SHA-256 in the manifest,
   retaining its previous hash in `prior_sha256`. No original `source_sha256`
   value was replaced. No preset, generated interface, RTL or gate was invented
   or removed.

## Memory: a real mixed reference exists, but it is not this board

Vendor inputs are
`ipss/mem/qip/mem_ss/ip/mem_ss_fm_0/mem_ss_fm_0_intf_{0,1}.ip`
and their enclosing `mem_ss_fm_0.qsys`. Direct XML inspection gives:

| Parameter | Vendor channel 0 | Vendor channel 1 |
|---|---|---|
| `MEM_DDR4_FORMAT_ENUM` | `MEM_FORMAT_DISCRETE` | `MEM_FORMAT_RDIMM` |
| `MEM_DDR4_DQ_WIDTH` | 64 | 64 |
| `MEM_DDR4_ROW_ADDR_WIDTH` | 17 | 17 |
| `MEM_DDR4_COL_ADDR_WIDTH` | 10 | 10 |
| Bank / bank-group widths | 2 / 2 | 2 / 2 |
| `MEM_DDR4_RANKS_PER_DIMM` | 1 | 1 |
| `CTRL_DDR4_ECC_EN` | false | false |
| `PHY_DDR4_MEM_CLK_FREQ_MHZ` | 1333.333 | 1333.333 |
| `PHY_DDR4_USER_REF_CLK_FREQ_MHZ` | 33.333 | 33.333 |

These are source settings, not measured clock rates or calibration evidence.

`ipss/mem/qip/presets/mem_presets.qprs` contains the **real**
`iseries-dk-8g-rdimm` preset, kind `mem_ss`. Despite its short description, its
actual payload has three storage channels: `emif_0` and `emif_1` are discrete,
`emif_2` is RDIMM. All have x64 DQ and row width 16, not the vendor's row width 17.
Its locations are `TOP,TOP,BOT`, not an IA840F mapping. It is therefore a useful
mixed-memory schema reference, **not a drop-in IA840F preset**. Single-RDIMM
F-series presets also exist but do not match the two-channel board.

The concrete modern schema includes top-level `MEM_INTFS_TYPE`,
`MEM_INTFS_LOCATION`, `APP_INTFS_TYPE`, `MEM_CH_n_CONNS`, and nested
`mem_ss|emif_n|MEM_DDR4_*` / `PHY_DDR4_*` plus `mem_ss|msa_n|*` parameters.
`mem_fm_presets.qprs` instead targets kind `mem_ss_fm`; the current generator in
`ofs-common/tools/ofss_config/memory_ip.py` chooses `mem_ss`. Do not transplant
legacy flat or `mem_ss_fm` parameters under the wrong component kind.

`sim_presets.qprs` supplies `iseries-dk-8g-rdimm` (discrete) and
`iseries-dk-8g-rdimm_group1` (RDIMM). `SimMemory.get_ip_settings()` selects
`<preset>_group<n>` for additional models. Thus a future IA840F preset must have
corresponding board-specific model presets too; setting `memory_groups=2` does
not create them. The old three-name allowlist in `Memory.check_configuration()`
is not currently called by `process_configuration()`; it is not an active
reason why an IA840F preset cannot be authored.

**Still required:** a reviewed two-channel `mem_ss` preset preserving full vendor
geometry, timings, RDIMM register configuration, electrical/board settings,
controller/MSA geometry and location; associated two model presets; and generated
port/interface evidence resolving every existing board pin to the intended
channel. The current `setup/emif_loc.tcl` explicitly proposes discrete group 0
and RDIMM group 1. This remains provisional: `ip_gen_sv_wrapper.tcl:461-509`
groups matching interface definitions, while `mem_ss_get_cfg.tcl:190-235`
compares generated port-width dictionaries. Neither simply assigns groups from
memory format names. No generated mapping was claimed here.

## PCIe: PF1 enabled, its BAR0 disabled

Do not interpret “PF1 disabled BAR0” as disabling the BMC function. Vendor
`ipss/pcie/qip/pcie_ss.ip` explicitly sets Gen4 1x16, two PFs, one VF on PF0 and
zero VFs on PF1. Its relevant contract is:

| Function | BAR0 | BAR2 | BAR4 | IDs |
|---|---|---|---|---|
| PF0 | 64-bit prefetchable, width 20 | disabled | 64-bit prefetchable, width 14 | vendor/device `8086:bcce`, subsystem `8086:1771` |
| PF0 VF | 64-bit prefetchable, width 20 | disabled | 64-bit prefetchable, width 14 | VF device `bccf` |
| PF1 BMC | **disabled** (stored inactive width 12) | 64-bit prefetchable, width **28** | 64-bit prefetchable, width **14** | vendor/device `12ba:0070`, subsystem `12ba:b5d4` |

The selected modern component is `intel_pcie_ss_axi`. Its actual OFSS schema is
`ofs-common/tools/ofss_config/ip_params/intel_pcie_ss_axi_parameters.py`:

- Identity overrides exist: `pci_type0_vendor_id`, `pci_type0_device_id`,
  `subsys_vendor_id`, `subsys_dev_id`, and VF identity overrides.
- BAR0/BAR4 address widths are exposed, but their types are hardcoded to
  64-bit prefetchable memory. BAR2 type/width are absent. Merely adding
  `bar0_type` or `bar2_address_width` to an OFSS file would not implement them.
- `pcie_ip.py:160-178,201-259` takes a separate preset path. A preset bypasses
  ordinary PF/VF parameter processing, including its Gen4x16 width workaround
  (`core16_dwidth_byte_user_hwtcl=64`, `core16_num_seg_user_hwtcl=2`). A future
  preset must preserve the applicable complete contract, not assume PF sections
  or that workaround are automatically overlaid on it.
- The checked-in `pcie_presets.qprs` contains `iseries-dk-gen4` and
  `iseries-dk-gen5`, both kind **`pcie_ss`**, not `intel_pcie_ss_axi`. Their PF1
  BAR0 is enabled, BAR2 disabled, and identities are not the BittWare contract.
  They demonstrate legacy raw parameter spellings, not a modern compatible
  IA840F preset.

**Still required:** source evidence for the selected modern IP's BAR0-disable /
BAR2 / full PF1 identity schema and a complete board-specific preset or a reviewed
schema extension; PF0VF0 AFU / PF1 BMC routing consistency; MSI-X offsets and
function capabilities; and generated configuration matching the modern FIM.
The pending PCIe preset was deliberately not replaced by either reference preset
or by renamed legacy IP.

## BMC: retained management is not qualified management

`src/board/ia840f/fim_afu_instances.sv:217-237` selects PF1 by routing-table
identity and attaches a 17-bit, 64-bit AXI-lite BMC aperture. The vendor wrapper
has the same 17-bit AXI address input. **Do not enlarge that local AXI aperture
to 28 merely because PCIe BAR2 advertises 28 address bits.** Board BAR semantics,
address truncation/alias behavior and MSI-X handling need review together.

The previous port's modern `ofs_fim_axis_cdc` and TX pipeline remain unchanged.
PF1's port reset reaches PCIe-side interfaces, but the CSR-side bridges and
`bwbmc_wrapper` still use global CSR reset. `flr_rst_mgr` produces the PCIe FLR
response, while the BMC bridge's `flr_rst_n` is tied high and its local `flr_ack`
is unused. Consequently this source does not establish draining/canceling an
in-flight CSR request or preventing an old completion across FLR. Resetting the
entire shared SPI/SDM subsystem on every PF1 FLR without a source-backed
management contract would be an unjustified fix.

BMC IRQ-to-MSI-X remains unimplemented (`msix_strb=0`), not newly qualified.
The preserved `bw_840_support.qsys`, `bmc_spi_sub.qsys` and leaf IP retain old
versions, including AXI bridge 19.3.1, SPI-to-AVMM 19.1.3, pipelines 20.0.1,
SDM mailbox 20.2.2 and board-local interrupt/arbiter IP. Qsys connection metadata
includes 23.1. These version strings are inventory evidence, not proof of
Quartus 26.1.1 incompatibility or compatibility. Source/IP migration and the
shared management/reset/interrupt contract remain dependencies. No replacement
with an unrelated PMCI block or arbitrary tie-off was made.

## Static preservation result

Read-only Python XML/JSON/hash inspection found:

- 86 manifest file entries, 86 unique paths, matching the declared count.
- All 86 current file hashes match the manifest after the one OFSS correction.
- All 76 recorded source hashes match the original source paths.
- Removing exactly the appended memory-model setting/comment block recovers the
  previous configuration hash `4eb637cb59983a0deed102a09916ac6f988a0e520e4bb114b1e04c326eac4060`.
- Both IA840F QSF revisions still include `build_gate.tcl`; readiness is false;
  both `PENDING_MIGRATION` presets remain unresolved.
- Inspected memory/PCIe preset and generator files match the pinned sibling
  checkouts byte-for-byte. No original vendor or sibling file was modified.

The remaining gates cover memory, PCIe, BMC, clocks/PR timing/floorplan and
AHLS/OFS/Quartus board-IP qualification. Host streaming remains unadvertised
unless an applicable transport implementation is established and bound. This review neither advertises unsupported host pipes nor
introduces application-specific transport. Physical/toolchain qualification
remains explicitly unperformed, not blocked on obsolete oneAPI compatibility.

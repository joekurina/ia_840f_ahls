# IA840F BMC component source closure

## Result and boundary

**The finite local BMC source-registration graph closes. No omitted vendor-owned
source or mismatched registration was proven; no source copy or patch is warranted.**
This does not establish elaboration, generated-IP acceptance or build readiness.
`ready_for_build` remains **false**. Target: AHLS/OFS/OPAE, Quartus 26.1.1;
oneAPI is reference-only.

Paths below are relative to `new/ofs-agx7-pcie-attach/`, with `B` denoting
`ipss/ia840f/bwbmc/`. Original sources were read only from
`old_bsp/ia-840/IOFS_BUILD_ROOT/ofs-ia840f/ipss/bwbmc/` beneath `new_bsp/`.
The companion [JSON evidence](../reference/vendor-integration/bmc-component-source-closure.json)
contains all source paths, byte sizes, SHA-256 values, original comparisons,
25 graph edges, assignment line numbers and literal custom fileset evidence.

| Inspected inventory | Count |
|---|---:|
| Active source/registration files, including wrapper and board setup | 34 |
| Qsys systems / module records / nested-system edges | 2 / 25 / 1 |
| Leaf `.ip` files | 24 |
| Custom component definitions / leaf instances | 2 / 3 |
| Custom filesets / fileset file entries / unique RTL files | 6 / 12 / 4 |
| Original vendor BMC source-directory files | 34 |
| Active inventory files byte-identical to their vendor counterparts | 32 |
| Missing registered files / kind-version binding mismatches | 0 / 0 |
| Sources copied / existing source files modified in this pass | 0 / 0 |

## Registration and nested bindings

`src/board/ia840f/bwbmc_wrapper.sv:80–81` instantiates `bw_840_support`.
The board-owned `syn/board/ia840f/setup/bwbmc_design_files.tcl:36–64`
registers this wrapper, both Qsys systems and exactly the 24 traversed leaf IPs.
Its lines 8–19 check both custom Tcl definitions and all four custom RTL paths;
line 34 supplies the board-local recursive component search paths.
The registered QSYS/IP set equals the recursively reachable set: no extra,
missing or duplicate path in that list. No custom RTL needs another global HDL
assignment. Preserved `B/bwbmc_wrapper.sv` and `B/bwbmc_design_files.tcl` are
not the active wrapper/setup selected by this list.

The XML traversal reads each `altera:module`'s `logicalView` and parses its
embedded `componentDefinition/originalModuleInfo`; it does not confuse the
`altera_generic_component` proxy's version 1.0 with the actual component kind
and version. Every leaf's `vendorExtensions/entity_info` agrees with that kind
and version; every leaf `model/.../moduleName` agrees with its catalog kind.

- `bw_840_support.qsys`: eight modules, seven leaf IPs plus
  `bmc_spi_sub_0 -> bmc_spi_sub.qsys`.
- `bmc_spi_sub.qsys`: seventeen modules, all bound to leaf IPs.
- Nested `bmc_spi_sub` has root name `bmc_spi_sub` and version `1.0`.
  The enclosing `originalModuleInfo` omits its version. This is recorded, not
  silently repaired or treated as a contradictory version.
- All saved `generationInfoDefinition/fileSets/.../fileSetFiles` lists are
  empty. They are generation metadata, not evidence that custom source files
  must be duplicated there. Leaf `.ip` files refer to `QUARTUS_SYNTH`; custom
  source ownership is supplied by the discovered `_hw.tcl` filesets.

## Custom implementation closure

| Catalog kind/version | Fileset top | Physical source bindings (relative to defining Tcl) |
|---|---|---|
| `Arbiter` / `2.0` | `arbiter` | `hdl/arbiter_v2.vhd`, `../common/rtl/pkg_global.vhd`, `../common/rtl/arbiter_frr.vhd` |
| `IRQ_Generator` / `1.0` | `irq_generator` | `irq_generator.v` |

All three filesets (`QUARTUS_SYNTH`, `SIM_VERILOG`, `SIM_VHDL`) per component
resolve to existing source files and declared top-level units. Custom leaf port
name sets match the Tcl declarations and physical RTL top-level port name sets.
This is lexical/source verification, not HDL compilation or width/timing validation.

Exact evidence:

- `B/ip/arbiter/arbiter_hw.tcl:22–23` declares `Arbiter` 2.0;
  lines 39–61 define the three filesets. Logical filename `arbiter.vhd`
  **explicitly maps to** physical `hdl/arbiter_v2.vhd`; the name difference is
  not a missing file. `arbiter_v2.vhd:40` declares `entity arbiter` and
  lines 63–71, 82 instantiate the declared `arbiter_frr` component.
- `B/ip/common/rtl/arbiter_frr.vhd:51` imports `work.pkg_global.all`;
  its `arbiter_frr` entity and the `pkg_global` package/body are physically
  present in the same filesets. The package implements the used `and_reduce`
  function. Remaining imports are IEEE/tool libraries, not omitted board RTL.
- `B/ip/irq_generator/irq_generator_hw.tcl:23–25` declares `IRQ_Generator`
  1.0; lines 50–69 bind all three filesets to RTL top `irq_generator`.
  The leaf catalog `moduleName=IRQ_Generator` is not a request to rename the
  case-sensitive Verilog module. The Tcl `TOP_LEVEL` establishes that mapping.
- `irq_generator.v:45` declares the expected module and has no nested
  component or include dependency. Its existing inactive external-cause tie-off
  at line 224 is retained exactly; this pass does not re-review interrupt or FLR
  behavior.

The 34-file vendor source directory has **no uncopied relative path** in `B`.
The active inventory differs from vendor bytes only in the already board-owned
setup list and intentionally adapted IRQ RTL. All other active inventory files,
including both Qsys files, all leaf IPs, custom Tcl, VHDL and active wrapper,
match their original bytes. No generated vendor build outputs were consulted or
copied.

## Remaining tool-provided dependencies

These source bindings are present; their catalog implementation and acceptance
by Quartus 26.1.1 have **not** been loaded or qualified:

| Catalog kind | Saved version | Instances |
|---|---|---:|
| `altera_avalon_mm_bridge` | 20.0.1 | 11 |
| `altera_avalon_onchip_memory2` | 19.3.7 | 1 |
| `altera_avalon_sysid_qsys` | 19.1.3 | 1 |
| `altera_axi_bridge` | 19.3.1 | 1 |
| `altera_clock_bridge` | 19.2.0 | 2 |
| `altera_reset_bridge` | 19.2.0 | 3 |
| `altera_s10_mailbox_client` | 20.2.2 | 1 |
| `spi_slave_to_avalon_mm_master_bridge` | 19.1.3 | 1 |

Additional dependencies are `package require -exact qsys 16.0` in the arbiter
Tcl, `qsys 15.1` in the IRQ Tcl, and the IRQ Tcl line 16 source of
`$env(QUARTUS_ROOTDIR)/../ip/altera/sopc_builder_ip/common/embedded_ip_hwtcl_common.tcl`.
The latter supplies tool helper functionality, including the validation callback's
`proc_get_boolean_parameter`; it is not an omitted BittWare file to invent/copy.
IEEE `std_logic_1164`, `numeric_std`, `std_logic_unsigned` and `std_logic_arith`,
generated interconnect/adapters, library binding and mixed-language simulation
also remain tool responsibilities. Saved 23.1 interface metadata is not evidence
of 26.1.1 compatibility.

`ocmem.ip` sets `initializationFileName=onchip_mem.hex`, but also
`useNonDefaultInitFile=false`, `copyInitFile=false` and
`autoInitializationFileName=ocmem_ocmem`. A missing custom `onchip_mem.hex` is
therefore **not** a required board-source omission.

Outside these custom filesets, the wrapper's `fpga_defines.vh` include and
`ofs_fim_axi_lite_if` interface have existing local files at
`src/includes/fpga_defines.vh` and
`ofs-common/src/common/includes/ofs_fim_axi_lite_if.sv`; their hashes are recorded
as boundary evidence, not counted as BMC-owned RTL.

## Verification and disposition

Namespace-aware XML parsing, embedded XML parsing, literal Tcl inspection,
HDL declaration/dependency inspection and SHA-256 comparisons verified the
finite graph and inventory counts. Pre-existing BMC files, active wrapper/setup
and read-only vendor BMC files were rehashed unchanged. JSON syntax was checked.
No build, configure, setup flow, IP generation, compiler, HDL/Tcl execution,
project test, vendor tool, workstation access, install, programming, commit or
push was performed. Shared manifest, overview documents, existing RTL/config
and build gate were not edited.

**Proposed source patch: none.** Later elaboration/IP acceptance and physical or
protocol qualification remain separate gates. This finding neither resets shared
SPI/SDM nor treats `flr_ack` as draining; existing qualification gaps are not used
to avoid the completed local source review.

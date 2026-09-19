# Vendor-derived IA840F BMC integration

## Delivered source integration (not generated-IP qualification)

The active target is AHLS RTL + modern OFS, not a oneAPI runtime port. The
BittWare implementation is selected, not replaced with PMCI or a management
stub. All paths in the integration tables are relative to
`new/ofs-agx7-pcie-attach/`. Vendor paths are relative to
`old_bsp/ia-840/IOFS_BUILD_ROOT/ofs-ia840f/` under `new_bsp/`.

This pass:

- Installs the actual, byte-identical BittWare `bwbmc_wrapper.sv` in the active
  board source directory, retaining its copyright/license. Its previous copy
  under `ipss/ia840f/bwbmc/` remains preserved, but is no longer compiled by the
  active board source list.
- Selects a board-owned `setup/bwbmc_design_files.tcl`, derived from the actual
  vendor list. It binds the wrapper, both Qsys systems and all 24 leaf IP files,
  with the vendor custom-component discovery paths. Explicit existence checks
  close the six custom-component Tcl/RTL inputs; these HDL files remain in
  Qsys component filesets, not duplicate global design-unit assignments.
- Corrects the previously unconnected `clk` and `rst_n` on the modern
  `bwbmc_csr` AXI-lite interface. Both are now explicitly the CSR-domain signals;
  17-bit addresses and 64-bit read/write data are explicit. Existing bridges
  already receive their clocks separately, so this is an interface-binding
  omission correction, **not** a claim that FLR handling has been fixed.
- Preserves the modern CDC adaptation, TX skid, PF1 identity-based routing,
  software/BMC management implementation, physical pins and shared reset
  ownership. The legacy wrappers, previous source list, all IP definitions,
  originals and build gate remain available. No IP version strings were edited.

`source_manifest.json` is parent-owned and was not edited. The old
`ipss/ia840f/bwbmc_sources.tcl` must not be additionally registered, because it
would bind a second copy of the same wrapper and IP. The new board list replaces
that one include, not the OFS common-source include.

## Actual source and bus closure

`top.sv -> afu_top.sv -> fim_afu_instances.sv` carries the physical BMC SPI and
IRQ/master-enable pins. Link 0's PF/VF routing table selects PF1 with
`vf_active == 0`; it is not a legacy numeric PID assumption. That endpoint
instantiates `bwbmc_st2mm` and the vendor `bwbmc_wrapper`.

The request path is `ofs_fim_axis_cdc -> bwbmc_st2mm_rx_bridge ->
st2mm_packet_filter -> mmio_req_bridge -> bwbmc_csr`. Response metadata/data
return through `st2mm_tx_bridge -> mmio_rsp_bridge`, the vendor-priority TX mux,
modern CDC and TX pipeline. Modern `mmio_req_bridge.sv` is byte-identical to the
vendor common implementation; the modern response bridge retains its
interface-width adaptation. OFS common's existing `st2mm_design_files.tcl` and
library source lists provide these dependencies, FIFOs, CDC and MSI-X encoder.
The BMC RX UMSG sink remains ready, without advertising MCTP support.

The active wrapper uses the existing full-AXI Qsys boundary as single-beat
AXI-lite: IDs/lengths/burst fields remain vendor constants; AW size follows
write strobes and AR size follows address bit 2. No new AXI transaction engine
was invented. Qsys defines the external AXI address width as 17, data width 64,
and one outstanding transaction. The saved boundary has no external `wlast`
input; do not invent a missing `axi_s_bw_wlast` wrapper port.

Qsys logicalView traversal, not filename matching alone, resolves:

- `bw_840_support.qsys`: AXI bridge, MM bridge, system ID, host SDM and BMC
  support pipelines, clock/reset bridges, and nested `bmc_spi_sub.qsys`.
- `bmc_spi_sub.qsys`: SPI-to-AVMM, SPI ingress/SDM/support/cardtest/transceiver
  pipelines, host SDM/support pipelines, dual-port on-chip RAM, shared SDM
  pipeline/mailbox/reset, system clock/reset, two IRQ generators and arbiter.
- `IRQ_Generator` 1.0: `irq_generator_hw.tcl -> irq_generator.v`.
- `Arbiter` 2.0: `arbiter_hw.tcl -> hdl/arbiter_v2.vhd`,
  `../common/rtl/pkg_global.vhd`, `../common/rtl/arbiter_frr.vhd`.

The arbiter's PCIe request is writedata bit 0, BMC request bit 1, and readback
reports requests in bits 0/1 and grants in 4/5. It is a software-visible ownership
register, **not** a hardware gate on all SDM transactions. Actual host and SPI
SDM pipelines both connect to `sdm_pipeline.s0`, then `sdm_mailbox.avmm`.
The custom arbiter's HPS conduit is unused in this board implementation.

### Source-defined host byte offsets

| Host local offset | Target |
|---|---|
| `0x0000` | System ID |
| `0x1000` | SDM mailbox via host SDM pipeline |
| `0x4000` | Shared 4096-byte RAM, host port s2 / SPI port s1 |
| `0x5000` | Arbiter's PCIe register window |
| `0x5010` | PCI-to-BMC IRQ generator |
| `0x5020` | BMC-to-PCI IRQ generator |

These are Qsys connection base addresses; they do not assert that all bytes
outside the windows complete safely. On-chip RAM uses default generated
initialization (`useNonDefaultInitFile=false`), not a missing required custom
`onchip_mem.hex` input.

PF1 BAR0 remains disabled, BAR2 has width 28, BAR4 width 14. The endpoint MMIO
bridge truncates addresses to its 17-bit local aperture and does not itself
select a BAR. BAR4 MSI-X accesses depend on the PCIe subsystem/shim interception;
this document does not qualify BAR aliases or the resulting generated BAR4 map.
The 28-bit BAR2 does **not** justify widening this AXI interface.

## Shared reset and FLR: exact retained behavior

The wrapper sends inverted global `reset_csr_n` to both Qsys `sysrst` and
`sdm_reset`. `sysrst_bridge.out_reset` resets the AXI/MM/host pipelines and nested
`system_rst`. Nested system reset reaches SPI transport, pipelines, RAM,
arbiter and IRQ generators. The separate `sdm_reset.out_reset` reaches only
`sdm_mailbox.in_reset`. The wrapper intentionally supplies both from global CSR
reset. They are not per-PF resets; PF1 FLR must not blindly reset shared SPI/SDM
or destroy a BMC-originated transaction.

`flr_rst_mgr` produces PF/VF resets and timer-based PCIe FLR responses. PF1's
port-reset duplication tree resets the PCIe side of BMC. Both the original
vendor endpoint and current endpoint tie `bwbmc_st2mm.flr_rst_n` high and leave
its edge-pulse `flr_ack` unused. That pulse is not a transaction-drained ACK and
cannot be wired into the response manager as a correctness fix.

The modern CDC uses the **source interface reset** for FIFO asynchronous clear.
The zero-stage RX interface binding correctly selects PF1 port reset as RX
FIFO source reset. TX FIFO source is CSR-reset-domain `st2mm_tx_if`, so PF1 FLR
alone does not clear TX FIFO contents. The TX skid resets on PF1 port reset.
The original `pcie_axis_cdc_fifo` also used its sink reset for FIFO clear and a
separate output reset. Thus preserving modern CDC is appropriate, but neither
version proves request draining, partial AXI cancellation, or old-completion
suppression across FLR. No such qualification is claimed.

## Interrupt behavior and exact handoff outside this worker's ownership

The actual BittWare IRQ generator implements software initiate, mask, reason
and write-one-to-clear registers; it drives the physical BMC interrupt through
`pci_to_bmc_irq_gen`. `bmc_to_pcie_irq_gen` produces the wrapper's `pcie_irq`.
The vendor endpoint never connects that output to a valid MSI-X request
protocol; its MSI-X inputs were undriven. The modern source's existing
`msix_strb=0` and zero vector remain in place. No level-to-strobe, vector number
or interrupt transport has been invented.

Inspection of **existing vendor generated RTL**, used only as evidence, finds a
real inherited omission: both IRQ generators have `.irq_in()` unconnected.
`irq_generator.v` samples `{irq_in, irq_in, data_in}`, so unconnected external
IRQ bits can contaminate reason bits 4..7 (and masked IRQ output). These are not
connected SDM IRQs: `sdm_mailbox_irq_irq` is also unused at the enclosing level.

Parent integration has now applied the following narrow edit to the active board copy, after independently confirming both open vendor `.irq_in` connections. The original vendor file remains untouched and its hash remains in the source manifest. The worker's original requested edit follows (owned
`ipss/ia840f/`): in the active board-specific
`bwbmc/ip/irq_generator/irq_generator.v`, replace exactly
`d1_data_in <= {irq_in, irq_in, data_in};` with
`d1_data_in <= {4'b0000, data_in};`, with a comment that this board binds only
software IRQ causes and has no external IRQ source. Retain the port signature,
register layout, software bits 0..3, mask/W1C behavior and original vendor copy.
This narrow board-local tie-off of **unconnected input causes** is not an
IRQ-to-MSI-X implementation. Alternatively bind both external inputs explicitly
low using a proven Qsys termination schema; do not merely edit a cached
`terminationValue`, because that value is already zero while the existing
generated RTL still leaves the ports open. No Qsys syntax has been guessed here.

The vendor generated enclosing system also leaves the SPI cardtest and
transceiver master response inputs open. Those are exported by the nested
system but neither connected nor exported by `bw_840_support`. Do not add
fabricated successful responders. Their intended board services must be located
or unsupported SPI access behavior explicitly designed before qualification.
No Qsys/leaf IP upgrade is requested without generated-interface evidence.

## Outstanding generated-IP and physical qualification (separate from closure)

The source graph resolves locally; generated RTL for the modern project has not
been produced. Retained AXI 19.3.1, SPI 19.1.3, pipelines 20.0.1, SDM 20.2.2,
custom component Qsys package requirements 15.1/16.0 and 23.1 connection metadata
are provenance, not version upgrades or evidence of Quartus 26.1.1 support.
Required later evidence includes component loading/generation and library
binding, exact generated ports/widths/resets, PCIe BAR/MSI-X mapping, all
shared-management clock/CDC constraints, FLR transaction safety, unsupported
SPI-window behavior, and board operation. Build readiness gates remain closed.
No build/configure/setup/IP generation, Tcl/HDL execution, tests, vendor tools,
workstation access, installation, programming, commit or push was performed.

## Exact source provenance

SHA-256 values below were computed from actual original bytes. Every vendor
BMC file below was compared again after the edits and remained unchanged.
This is a finite BMC source inventory, not a whole toolchain/build attestation.

| Original vendor BMC path | SHA-256 |
|---|---|
| `ipss/bwbmc/bmc_spi_sub.qsys` | `71bcb8de75167546c7dcb0b159021fa16666f2ed92cdaacb8d9f9ed67c36f952` |
| `ipss/bwbmc/bw_840_support.qsys` | `8c597695379a47c4426220fee88789e1fcce5ab84ab29612e9c10348ccd36098` |
| `ipss/bwbmc/bwbmc_design_files.tcl` | `2996ffcb72aa56062e31a7cd6a25bed75dfcad11e4fdfd2dd892aaa8aa1c70b1` |
| `ipss/bwbmc/bwbmc_wrapper.sv` | `c96b7ca1de13f989ed6ad71c81bbb6ee8e2f7644fe1035f3a0e068b5910da800` |
| `ipss/bwbmc/ip/arbiter/arbiter_hw.tcl` | `b85ba844dc85ebe9447e73c6b52aa5a119aed4a7f75f96c51259f647e442b26b` |
| `ipss/bwbmc/ip/arbiter/hdl/arbiter_v2.vhd` | `9085fc684a2054c1bbecd462e9371987e89f2e0a5e284911ff533a9570303d1f` |
| `ipss/bwbmc/ip/bmc_spi_sub/bmc_spi_cardtest_pipe.ip` | `461ec47075fd499891df37d8f53afc7fc73aebef0b794409c0df52ef261f7e12` |
| `ipss/bwbmc/ip/bmc_spi_sub/bmc_spi_pipe0.ip` | `925390f1e227e8d4354ee869e15303e71a046573467d58c258068eef4ee35eea` |
| `ipss/bwbmc/ip/bmc_spi_sub/bmc_spi_sdm_pipe.ip` | `18c69e7734956ba69b412302c6a92f35ceeca88cdf901baae250df9d528a191a` |
| `ipss/bwbmc/ip/bmc_spi_sub/bmc_spi_support_pipe.ip` | `c7e12dd61bb6ea7993cf4d8e7028ceef0da7f7dc6976dee9d13c3e4513ceda3c` |
| `ipss/bwbmc/ip/bmc_spi_sub/bmc_spi_to_avmm.ip` | `6f6906669d71643a72566bcd404d0f81d5cb81b7fa559a6d5d8fc1fc847aebcd` |
| `ipss/bwbmc/ip/bmc_spi_sub/bmc_spi_xcvr_pipe.ip` | `d185db7abfc2944c3f5d87e23c39609ff0f25337dfefdf4fcb695a965027dcbb` |
| `ipss/bwbmc/ip/bmc_spi_sub/bmc_to_pcie_irq_gen.ip` | `69833c95fe26120ab42b672e0e00dd139fa7419e43cac97f0220461e3e1d6dae` |
| `ipss/bwbmc/ip/bmc_spi_sub/host_sdm_pipe.ip` | `fd66d08deb116b491a4cd16523447c8b679e814c8b0ebd00bdd3242f382951f0` |
| `ipss/bwbmc/ip/bmc_spi_sub/host_support_pipe.ip` | `284ef9a6d6de4ec8c3733ebbe8a8ac8b0643749b9a4ac80fd3abbb3b227c205d` |
| `ipss/bwbmc/ip/bmc_spi_sub/ocmem.ip` | `c50d93095e7c5b9d6c75f3b2136f49b6bd9da4932554db05b9325a200b327258` |
| `ipss/bwbmc/ip/bmc_spi_sub/pci_to_bmc_irq_gen.ip` | `eb217952389020a41786e1a47d52c4c2baac3b746f7d3f9568e411ec2936d354` |
| `ipss/bwbmc/ip/bmc_spi_sub/sdm_mailbox.ip` | `539fc0453b109b25a820863e002a5ae6e633705c307699bfdee974f9a71222f1` |
| `ipss/bwbmc/ip/bmc_spi_sub/sdm_pipeline.ip` | `d244f88b13a8a12b4ba35765a4b7723bf5cbdd4a932e888ea748d96b78029e74` |
| `ipss/bwbmc/ip/bmc_spi_sub/sdm_reset.ip` | `efbd0443b246327f33fa8a3aa15b3e4aa81254cdecf2c48b13e51a33354a6583` |
| `ipss/bwbmc/ip/bmc_spi_sub/system_arbiter.ip` | `9c42b33591a796111acd6409a67489cefb0c9041c6ca4405b123735167ee9832` |
| `ipss/bwbmc/ip/bmc_spi_sub/system_clk_bridge.ip` | `b3396a9b1fc417f398a88528a0bf3292b06d25f65ae72d5463874db078f59be0` |
| `ipss/bwbmc/ip/bmc_spi_sub/system_rst_bridge.ip` | `09a2bca3f21c615c51367c83ae708619e035e6471f3d329894346865c9c7db47` |
| `ipss/bwbmc/ip/bw_840_support/bw_840_support_axi_bridge_0.ip` | `4c57b9d4dbe14745e39ad61b134ddeb2d3f2e2976300176b7197000fcab8a4ca` |
| `ipss/bwbmc/ip/bw_840_support/bw_840_support_mm_bridge_0.ip` | `9291ae00ba6628fc24da22390e888952e5e3d38d7e61a0779dfaeb7ce1ba5ca5` |
| `ipss/bwbmc/ip/bw_840_support/bw_840_support_sysid_qsys_0.ip` | `6fcc75b9dd992a5650f5517562fac4414b9de976c66845b3774e6b8e22e35a35` |
| `ipss/bwbmc/ip/bw_840_support/host_bmc_support_pipeline.ip` | `08cfa7d90e1eda3671ead4100fa370f42c2f4a14bc506c643c042d5fd0dcd4bc` |
| `ipss/bwbmc/ip/bw_840_support/host_sdm_pipeline.ip` | `05900870bc1e2923a4ae38518028593f6ad31ec2f7c1b059b7de2d1e600e9688` |
| `ipss/bwbmc/ip/bw_840_support/sysclk_bridge.ip` | `2db3475c9aa0397a3e976824a84d61c338593f49792f83b6fa20db26be93b703` |
| `ipss/bwbmc/ip/bw_840_support/sysrst_bridge.ip` | `6aedcc883f09b74b05cb8e67577eb4d9873548a3b9645614cbc56b89cc7596c8` |
| `ipss/bwbmc/ip/common/rtl/arbiter_frr.vhd` | `f46c956089027b30668841bc9299a0d9ec89a896afa5fcf08e252e945b752353` |
| `ipss/bwbmc/ip/common/rtl/pkg_global.vhd` | `60081028bb8a69c96c526d2c90aae9c5425acace58aa84b7365364f446872bd5` |
| `ipss/bwbmc/ip/irq_generator/irq_generator.v` | `5b7d3e060958855a65a31481838035400e417f515fcb0f542b28f237d09b5bb2` |
| `ipss/bwbmc/ip/irq_generator/irq_generator_hw.tcl` | `59dcd99e672e99e69930956ce9006219170dfd3acc3df9ba6a29af46ee9262ba` |

### Additional original evidence (not compiled from old generated outputs)

| Vendor path | SHA-256 |
|---|---|
| `src/afu_top/fim_afu_instances.sv` | `e38eaebe2058437ae41a040efd451d42f977f89173f5865e79ae2f7237f6fa14` |
| `src/afu_top/bwbmc_st2mm/bwbmc_st2mm.sv` | `766b1e91d1c9d27e8ba19e957cbc7f6c45031bdeb3a6fe8a26d5301205e6ac42` |
| `src/afu_top/bwbmc_st2mm/bwbmc_st2mm_rx_bridge.sv` | `d08d83658f1a9a0aad26a8d6298732b916ea056fea5a17e284b1dcb4964ec378` |
| `ofs-common/src/common/st2mm/pcie_axis_cdc_fifo.sv` | `f656074238f9bb51146ca52791fc1bcbea9e2bbbc0bcb44e0977ed1c3a4350dd` |
| `work-ofs-23.1-2-build/syn/ip_lib/ipss/bwbmc/bw_840_support/synth/bw_840_support.v` | `1ec19fb9dc682ef26547c7d43918afacaf06524fefbd926bc71ec4743a2a0588` |
| `work-ofs-23.1-2-build/syn/ip_lib/ipss/bwbmc/bmc_spi_sub/synth/bmc_spi_sub.v` | `da889fedfbe8008a2db021e4ca9b320a6413127f316471c37404c465decf6426` |

### Actual changed integration paths

| Path | Before SHA-256 | After SHA-256 |
|---|---|---|
| `src/board/ia840f/fim_afu_instances.sv` | `777fd931b73990f722e888173867faa1c1dfef65e791847443d0355d6901f502` | `e890723f848a4567a8b9390a2f8e4cc27bbd70c92d248367406585d1e493bc76` |
| `syn/board/ia840f/setup/afu_design_files.tcl` | `4ea6002766e044c7870411f5ac0812c8eea3352da97d117165c759645f4c4d74` | `6d508346610f16420d098bb50801d9d82fda626de9c5b2e1af3569844d4f538c` |

### Created files

| Path | SHA-256 |
|---|---|
| `src/board/ia840f/bwbmc_wrapper.sv` | `c96b7ca1de13f989ed6ad71c81bbb6ee8e2f7644fe1035f3a0e068b5910da800` |
| `src/board/ia840f/legacy/pre-vendor-bmc-integration/src/board/ia840f/fim_afu_instances.sv` | `777fd931b73990f722e888173867faa1c1dfef65e791847443d0355d6901f502` |
| `src/board/ia840f/legacy/pre-vendor-bmc-integration/syn/board/ia840f/setup/afu_design_files.tcl` | `4ea6002766e044c7870411f5ac0812c8eea3352da97d117165c759645f4c4d74` |
| `syn/board/ia840f/setup/bwbmc_design_files.tcl` | `e76835e1c2440cba1b041d76665490b1d37f53865a222a73ecd38b29716f1bc0` |

Also created `new/docs/vendor-derived-bmc.md` (this document, deliberately not
self-hashed). The two files under `legacy/pre-vendor-bmc-integration/` preserve
exact pre-edit integration bytes. Existing legacy copies are untouched.

### Static inspection result

Namespace-aware XML parsing resolves both Qsys systems, all 24 `.ip` paths and
the two custom-component filesets' four RTL paths. The new explicit IP/Qsys
assignment set equals that traversal, with no missing or additional IP.
The active board wrapper equals the original BittWare file byte-for-byte.
All pre-existing files in this worker's owned directories except the two listed
integration edits remained byte-identical, including CDC/RX bridge sources,
legacy originals and `build_gate.tcl`. This is parsing/hash/source inspection,
not a HDL/Tcl test run, elaboration, synthesis or generated-IP qualification.

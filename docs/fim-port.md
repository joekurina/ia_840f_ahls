# IA840F source-only FIM port

## Status and scope

`ready_for_build=false`. This is a board-specific source migration onto the parent's pinned `ofs-agx7-pcie-attach` commit `599ac052eafbc9cede22561c099233ae4a54cb7d` with the parent's pinned `ofs-common` revision beginning `34a8540`. Neither compatibility with Quartus 26.1.1 nor a working FIM/oneAPI BSP is claimed.

Both board QSF revisions load `syn/board/ia840f/setup/build_gate.tcl`, which unconditionally rejects use while the gate is false. There is no environment-variable bypass. The board OFSS files deliberately name pending, nonexistent PCIe and memory presets rather than silently selecting an electrically wrong Intel development-board preset. Do not execute the OFSS files as a generation recipe yet. No build, configure, IP generation, simulator, test, vendor tool, remote access, flash operation or commit was performed for this port.

The source inventory was read from:

- Legacy: `/home/joe/Projects/Thesis/AHLS/new_bsp/old_bsp/ia-840/IOFS_BUILD_ROOT/ofs-ia840f`.
- Modern reference: `/home/joe/Projects/Thesis/AHLS/new_bsp/ofs-agx7-pcie-attach` and the parent's fresh pinned staged checkout.
- Destination: `/home/joe/Projects/Thesis/AHLS/new_bsp/new/ofs-agx7-pcie-attach`.

No `work-ofs-*`, QDB, SOF, GBS, RBF, generated synthesis output, or compiled artifact was imported. Original source IP descriptions, including the manually maintained legacy memory Qsys hierarchy, were preserved. `syn/board/ia840f/source_manifest.json` binds each staged input/derived file to its source and SHA-256. The manifest itself is outside its own hash list.

## What was implemented

- A native `syn/board/ia840f/{syn_top,setup,config}` layout with IA840F FPGA/SDM/power configuration, modern FIM/PR source-list structure, modern IP-configuration database hooks, source-selected board RTL, separate BMC timing constraints, and an explicit build gate.
- Board-specific modern `top.sv`, `afu_top.sv`, and `fim_afu_instances.sv` under `src/board/ia840f`. The current multi-link PCIe/FLR, local-memory and `pg_afu.port_gasket` APIs are retained. Only BMC sideband propagation and the PF1 static endpoint were added. Upstream shared RTL and scripts were not overwritten.
- BMC selection is by routing-table PF identity (`pf == 1 && !vf_active`), not the old mux index. Modern static-region routing excludes management PF0: blindly carrying legacy `BWBMC_PID=1` would select the wrong endpoint.
- BMC MMIO adapter source under `src/board/ia840f`, original BittWare Qsys/IP/custom VHDL under `ipss/ia840f/bwbmc`, and a relocated root-relative `ipss/ia840f/bwbmc_sources.tcl`. The original legacy Tcl is retained but is not the selected entry point.
- The legacy bridge had undriven MSI-X request signals and no BMC PCIe-interrupt connection. The candidate explicitly disables MSI-X requests, provides deterministic TX idle defaults and drains unused user messages. This is polling-only BMC support, not an implemented interrupt path. Reset/CDC behavior remains unqualified.
- A physical pin subset excluding inactive HSSI/HPS/PMCI pins. Memory pins retain original package coordinates while adapting refclk/OCT names and proposing one group per memory kind. `pin_inventory.json` lists every selected package-pin assignment.
- Verbatim legacy physical constraints, QSF, PCIe IP, PLL IP, routing table and BMC bridge sources under `src/board/ia840f/legacy`; complete legacy memory Qsys and sub-IP under `ipss/ia840f/legacy_mem`. Extracted IP parameter JSON is reference data, not a generated replacement IP.

## Exact board facts

### FPGA, configuration and power

Legacy `syn/syn_top/ofs_top.qsf` selects **AGFB027R25A2E2V**, not modern N6001's AGFB014R24A2E2V or F-series development kit's AGFD023R24C2E1VC. The modern board QSF uses family spelling `Agilex 7` while preserving the physical part string exactly.

Preserved legacy configuration:

- Active Serial x4; device initialization clock `OSC_CLK_1_125MHZ`.
- PMBus slave address `01`, `VID_OPERATION_MODE "PMBUS SLAVE"`, linear format exponent `-12`.
- SCL `SDM_IO14`, SDA `SDM_IO11`, alert `SDM_IO12`.
- CONF_DONE `SDM_IO16`, INIT_DONE `SDM_IO0`, direct-to-factory `SDM_IO13`.
- Compressed SOF and RBF enablement; no added development-kit power-controller assumptions.

The old QSF's `LAST_QUARTUS_VERSION` string says 22.3, while its source IP includes 23.1 metadata. It is retained as provenance only, not a current tool-version requirement or support claim. The old build script disabled flash-image creation (`ENA_FLASH=0`). No Intel MAX10 development-kit flash packaging was copied into this port.

### Clocks and key pins

| Signal | Package pins / source setting |
|---|---|
| SYS_REFCLK | P C52 / N A53; TRUE DIFFERENTIAL SIGNALING; 100 MHz constraint |
| PCIE_REFCLK0 | P DF57 / N DD56; HCSL; 100 MHz |
| PCIE_REFCLK1 | P CV57 / N CT56; HCSL; 100 MHz |
| PCIE_RESET_N | GJ56; 1.8 V |
| DDR channel 0 refclk | P HF23 / N HH22; legacy IP reference 33.333 MHz |
| DDR channel 0 OCT | HB23 |
| DDR channel 1 refclk | HH48; source does not explicitly assign the negative pin |
| DDR channel 1 OCT | GW48 |
| BMC IRQ | L56; 1.2 V |
| BMC master-enable-n | N57; 1.2 V; driven low by the wrapper to advertise the SPI subsystem |
| BMC SCLK / MISO / MOSI / CS | W52 / U53 / G56 / J57; all 1.2 V |

BMC SCLK is constrained at 200 ns; MOSI/CS input delays 0–10 ns; MISO output delays 1–12 ns. The old asynchronous grouping against `sys_pll|iopll_0_clk_100m` is carried into a separate board SDC and still needs timing review.

The legacy PLL source has a 100 MHz input and output settings 470, 100, 175, 155.555556 and 50 MHz. It is internally inconsistent with stale `clk_sys_div2` comments, the 400 MHz `ofs_axi_fim_clk_pkg`, and PCIe IP's `axi_st_clk_freq_user_hwtcl=400MHz`. The old PIM INI says 470 MHz. The board selection references modern `iopll_470MHz.ofss`, which must generate a coherent modern clock tree; the old PLL is not imported into the active design. No fitted/live clock is inferred.

Full PCIe lane assignments are retained in the new `setup/top_loc.tcl`. For quick orientation, lane 0 TX P/N is GA62/GD63, RX P/N GA68/GD69; lane 15 TX P/N DA59/CW60, RX P/N DA65/CW66. Lane order must not be replaced by a development-kit pin map.

### Memory

Authoritative source: legacy `ipss/mem/mem_design_files.tcl` explicitly selects manually edited `mem_ss_fm_0.qsys` and its sub-IP, not the formerly used monolithic IP. The note says the second channel was added for RDIMM.

- `intf_0`: P1 discrete DDR4, `MEM_FORMAT_DISCRETE`.
- `intf_1`: RDIMM, `MEM_FORMAT_RDIMM`.
- Both: DDR4 clock 1333.333 MHz, user reference 33.333 MHz, 64 DQ, 8 DQ per DQS, one rank, one CS/CKE/CK, row 17, column 10, bank 2, bank-group 2; ECC disabled.
- Geometry describes 16 GiB per channel. This is configured geometry, not SPD/hardware verification of the installed DIMM.
- DDR4-2666 speed bin; CL 23; write CL 14; read DBI on; write DBI off; DM on; alert/parity enabled. Timing and board skew parameters are retained in full in the original IP and `emif_parameters.json`.
- Legacy application interface: two controllers, 512-bit AXI data, 34-bit byte address, 9-bit ID, 1-bit USER, 8-bit burst-length field.
- Legacy per-interface IP version is 2.7.0, with 23.1 interface metadata.

Modern FIM uses generated `ofs_ip_cfg_db` memory types and `mem_ss.ip`, `ofs_fim_mem_ddr4_ref_clk_if`, `mem_ss_mem_ddr4_if` and optional `mem_ss_mem_g1_ddr4_if`. It cannot simply consume the old handwritten `mem_ss_pkg` and `mem_ss_fm_0` wrapper. The candidate pin mapping proposes discrete memory as `ddr4_mem[0]`, RDIMM as `ddr4_mem_group_1[0]`, and both refclk/OCT pairs in `ddr4_mem_ref_clk`. `DDR4_NUM_MEM_GROUPS=2` is explicit. This grouping and scalar `alert_n` spelling remain gated until the actual modern generated interface is known. No missing negative refclk pin was invented.

### PCIe and BMC

The actual checked-in PCIe IP and `src/afu_top/mux/top_cfg_pkg.sv` agree on **Gen4 x16, one link, two PFs, one VF on PF0**:

- PF0: OFS management, 8086:bcce.
- PF0 VF0: PR/oneAPI AFU, 8086:bccf.
- PF1: BittWare board management, 12ba:0070; subsystem device b5d4.

Despite comments still saying PF3, actual `BWBMC_PID=1` and the old routing table put BMC on PF1. Legacy `ipss/pcie/qip/pcie_ss.ofss` is stale: it says five PFs and three PF0 VFs. Do not port that stale file as the board topology.

The actual PF1 IP has BAR0 disabled, BAR2 64-bit prefetchable with address width 28 (256 MiB aperture), BAR4 64-bit prefetchable with address width 14, no VFs. The 17-bit BMC internal address space is reached through that aperture; do not equate aperture size with CSR space. PF0 and VF0 use BAR0 width 20 and BAR4 width 14.

Modern `ofs-common/tools/ofss_config/pcie_ip.py` defaults to **intel_pcie_ss_axi**, whereas the legacy source describes **pcie_ss 1.0.0**, AXI-ST Data Mover. The current default parameter dictionaries expose PF IDs and BAR0/BAR4 widths but do not expose a PF-specific BAR2 override / BAR0-disable contract. A bare `[pf1]` section would silently create the wrong mapping. The staged pending preset name therefore fails rather than silently substituting those defaults. Preserve BittWare identity/aperture through a reviewed modern preset or an explicitly reviewed board-specific generator before opening the gate. Also retain the upstream P-Tile Gen4x16 workaround forcing 64-byte width and two segments when using intel_pcie_ss_axi.

BMC source contains the SPI-to-Avalon bridge, SDM mailbox, host/BMC arbitration, on-chip shared memory and IRQ generators. The MAX10 is SPI master. The original source uses old component versions, including SPI 19.1.3, mailbox 20.2.2, bridges 19.x/20.x, custom Arbiter 2.0 and IRQ generator 1.0. Custom component scripts explicitly request Qsys 16.0 and 15.1. They were not edited to assert compatibility with a newer Qsys package. Porting the source file list does not upgrade those components.

### Optional hardware deliberately disabled

Legacy QSF disables HSSI, PMCI, HPS and UART. IA840F QSFP sideband control is via an I2C GPIO expander, not the direct N6000 QSFP pins. The retained legacy source maps eight E-tile serial lanes to QSFP-DD-1 (RX P DL8, DN13, DY8, EB13, EH8, EK13, ET8, EV13; TX P DL1, DN4, DY1, EB4, EH1, EK4, ET1, EV4), with refclk CC19/BW19. Those inactive constraints are reference-only. Enabling modern HSSI requires an actual board expander/control design and modern `hssi_if` naming; setting `INCLUDE_HSSI` alone is unsafe. PMCI is not an IA840F substitute for the BittWare BMC.

## Required work before opening the build gate

1. **Modern mixed-memory IP:** author and review a board-specific `mem_ss` preset or equivalent source-generation contract using the preserved legacy geometry, timing, board skew, discrete/RDIMM distinctions and physical banks. Generate only with separate permission. Reconcile group ordering, widths, ECC, AXI parameters, calibration location, refclk/OCT and the modern DB wrapper outputs. Do not rename old `.qsys` to `.ip` or fabricate DB headers.
2. **Modern PCIe preset:** carry the two-PF/one-VF topology, vendor/device IDs, PF1 BAR2/BAR4 and disabled BAR0, plus modern PCIe width/reset/FLR behavior. Reconcile any changes in CSR/MSI-X offsets with actual board software. The candidate BMC routing assumes exactly one link and PF1 with no VFs.
3. **BMC upgrade and reset review:** resolve original Qsys package requirements and regenerate its old IP legally and explicitly. Verify relocated Qsys component discovery. The candidate preserves the old policy of resetting the TLP adapter with PF1 port reset while keeping BMC CSR logic in the global CSR-reset domain; prove this cannot leave an outstanding transaction stranded after FLR. PCIe interrupt-to-MSI-X is intentionally unimplemented, not tied off and advertised as supported.
4. **Clock and timing:** resolve the legacy 470/400/175 discrepancy through the modern generated clock contract. Revalidate the copied BMC asynchronous constraint, PCIe constraints and PR boundary timing. Copied physical floorplan coordinates (`X0 Y101 X390 Y333; X101 Y21 X390 Y100; X301 Y0 X390 Y20`, route `X0 Y0 X390 Y333`) are an AGFB027 starting point, not a modern-fit result.
5. **Mandatory host pipes:** implement and qualify the AFU/BSP host-channel hardware, board XML declaration, MMD API and oneAPI semantics separately. This FIM port retains a PR host TLP interface but does not prove SYCL host-pipe support. Do not replace the requirement with per-frame launcher kernels.
6. **Board discovery and build orchestration:** parent integration must select the new board path and board OFSS explicitly; the upstream default OFSS discovery path is not modified here. The candidate board config is stored under `syn/board/ia840f/config`, not registered as a default build target. Keep flash generation disabled until an IA840F-specific safe packaging recipe is established. Both QSF gates must remain closed while any required item is unresolved.
7. **Tool qualification:** no claim is made that this part, PR flow, legacy IP or oneAPI backend is supported by Quartus 26.1.1. Choose and pin the actual supported toolchain before regeneration and compilation. Build/fit and hardware qualification require new authorization.

## Inspection evidence

Only source inspection and file-inventory/hash calculations were used. All staged verbatim copies matched their original source bytes. The selected BMC Tcl's explicit root-relative SV/IP/Qsys paths resolved to staged source files. The board pin inventories contain 77 non-memory and 241 memory location assignments, each with unique targets and package pins within its respective list. This is source consistency, not Quartus parsing, elaboration, electrical sign-off, timing closure, functional testing, or a supported BSP claim.

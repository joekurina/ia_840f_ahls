// Copyright (C) 2022 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef __OFS_PLAT_IF_TOP_CONFIG_VH__
`define __OFS_PLAT_IF_TOP_CONFIG_VH__

//
// This is the primary parameterization of the platform.
//
// Preprocessor parameters allow AFUs to configure their connections
// based on platform-specific details. Some of the parameters must be
// defined in order for the platform definition to conform to the OFS
// top-level interface standard.
//


// ========================================================================
//
//  clocks interface parameters
//
// ========================================================================

`define OFS_PLAT_PARAM_CLOCKS_PCLK_FREQ int'(ofs_fim_cfg_pkg::MAIN_CLK_MHZ)
`define OFS_PLAT_PARAM_CLOCKS_PCLK_FREQ_MHZ_REAL ofs_fim_cfg_pkg::MAIN_CLK_MHZ


// ========================================================================
//
//  define interface parameters
//
// ========================================================================

`define PLATFORM_FPGA_FAMILY_AGILEX 1
`define PLATFORM_FPGA_FAMILY_AGILEX7 1
`define ASE_AFU_MAIN_IF_OFFERED 1
`define AFU_MAIN_API_USES_INCLUDE_HSSI 1


// ========================================================================
//
//  host_chan (native_axis_pcie_tlp) interface parameters
//
// ========================================================================

`define OFS_PLAT_PARAM_HOST_CHAN_IS_NATIVE_AXIS_PCIE_TLP 1
`define OFS_PLAT_PARAM_HOST_CHAN_NUM_PORTS top_cfg_pkg::PG_AFU_NUM_PORTS*top_cfg_pkg::PG_NUM_LINKS
`define OFS_PLAT_PARAM_HOST_CHAN_NUM_MULTIPLEXED_PORTS top_cfg_pkg::PG_NUM_LINKS
`define OFS_PLAT_PARAM_HOST_CHAN_NUM_CHAN_PER_MULTIPLEXED_PORT top_cfg_pkg::PG_AFU_NUM_PORTS
`define OFS_PLAT_PARAM_HOST_CHAN_ADDR_WIDTH 51
`define OFS_PLAT_PARAM_HOST_CHAN_DATA_WIDTH ofs_pcie_ss_cfg_pkg::TDATA_WIDTH
`define OFS_PLAT_PARAM_HOST_CHAN_MMIO_ADDR_WIDTH ofs_fim_cfg_pkg::MMIO_ADDR_WIDTH_PG
`define OFS_PLAT_PARAM_HOST_CHAN_MMIO_DATA_WIDTH 64
`define OFS_PLAT_PARAM_HOST_CHAN_BYTE_EN_SUPPORTED 1
`define OFS_PLAT_PARAM_HOST_CHAN_ADDRESS_SPACE "IOADDR"
`define OFS_PLAT_PARAM_HOST_CHAN_NUM_INTR_VECS ofs_fim_cfg_pkg::NUM_AFU_INTERRUPTS
`define OFS_PLAT_PARAM_HOST_CHAN_MAX_BW_ACTIVE_FLITS_RD 1024
`define OFS_PLAT_PARAM_HOST_CHAN_MAX_BW_ACTIVE_FLITS_WR 128
`define OFS_PLAT_PARAM_HOST_CHAN_SUGGESTED_TIMING_REG_STAGES 0
`define OFS_PLAT_PARAM_HOST_CHAN_GASKET pcie_ss
`define OFS_PLAT_PARAM_HOST_CHAN_GASKET_IS_PCIE_SS
`define OFS_PLAT_PARAM_HOST_CHAN_NATIVE_CLASS "native_axis_pcie_tlp"


// ========================================================================
//
//  local_mem (native_axi) interface parameters
//
// ========================================================================

`define OFS_PLAT_PARAM_LOCAL_MEM_IS_NATIVE_AXI 1
`define OFS_PLAT_PARAM_LOCAL_MEM_NUM_BANKS ofs_fim_mem_if_pkg::NUM_MEM_CHANNELS
`define OFS_PLAT_PARAM_LOCAL_MEM_ADDR_WIDTH ofs_fim_mem_if_pkg::AXI_MEM_ARADDR_WIDTH-$clog2(ofs_fim_mem_if_pkg::AXI_MEM_RDATA_WIDTH/8)
`define OFS_PLAT_PARAM_LOCAL_MEM_DATA_WIDTH ofs_fim_mem_if_pkg::AXI_MEM_RDATA_WIDTH
`define OFS_PLAT_PARAM_LOCAL_MEM_BURST_CNT_WIDTH ofs_fim_mem_if_pkg::AXI_MEM_BURST_LEN_WIDTH+1
`define OFS_PLAT_PARAM_LOCAL_MEM_ECC_WIDTH 0
`define OFS_PLAT_PARAM_LOCAL_MEM_MASKED_FULL_SYMBOL_WIDTH 8
`define OFS_PLAT_PARAM_LOCAL_MEM_MAX_BW_ACTIVE_LINES_RD 256
`define OFS_PLAT_PARAM_LOCAL_MEM_MAX_BW_ACTIVE_LINES_WR 128
`define OFS_PLAT_PARAM_LOCAL_MEM_SUGGESTED_TIMING_REG_STAGES 2
`define OFS_PLAT_PARAM_LOCAL_MEM_USER_WIDTH ofs_fim_mem_if_pkg::AXI_MEM_WUSER_WIDTH
`define OFS_PLAT_PARAM_LOCAL_MEM_RID_WIDTH ofs_fim_mem_if_pkg::AXI_MEM_ARID_WIDTH
`define OFS_PLAT_PARAM_LOCAL_MEM_WID_WIDTH ofs_fim_mem_if_pkg::AXI_MEM_AWID_WIDTH
`define OFS_PLAT_PARAM_LOCAL_MEM_ENABLED_BY INCLUDE_LOCAL_MEM
`define OFS_PLAT_PARAM_LOCAL_MEM_NATIVE_CLASS "native_axi"
`define OFS_PLAT_PARAM_LOCAL_MEM_GASKET fim_emif_axi_mm
`define OFS_PLAT_PARAM_LOCAL_MEM_GASKET_IS_FIM_EMIF_AXI_MM


// ========================================================================
//
//  other (ports) interface parameters
//
// ========================================================================

`define OFS_PLAT_PARAM_OTHER_IS_PORTS 1
`define OFS_PLAT_PARAM_OTHER_TEMPLATE_CLASS generic_templates
`define OFS_PLAT_PARAM_OTHER_NATIVE_CLASS "ports"
`define OFS_PLAT_PARAM_OTHER_NUM_PORTS 1
`define OFS_PLAT_PARAM_OTHER_TYPE ofs_plat_fim_other_if
`define OFS_PLAT_PARAM_OTHER_IMPORT "../../ofs-common/src/fpga_family/agilex/port_gasket/afu_main_pim/extend_pim/"


// ========================================================================
//
//  Compatibility
//
// ========================================================================

`include "platform_afu_top_config.vh"

//
// Define preprocessor parameters expected by older code.
//

// Is local memory available? (Required by PIM v1 AFUs.)
`ifdef OFS_PLAT_PARAM_LOCAL_MEM_NUM_BANKS
  `ifdef AFU_TOP_REQUIRES_LOCAL_MEMORY_AVALON_MM
    `define PLATFORM_PROVIDES_LOCAL_MEMORY 1
  `elsif AFU_TOP_REQUIRES_LOCAL_MEMORY_AVALON_MM_LEGACY_WIRES_2BANK
    `define PLATFORM_PROVIDES_LOCAL_MEMORY 1
  `endif
`endif


// ========================================================================
//
//  ASE
//
// ========================================================================

// When OFS_PLAT_PROVIDES_ASE_TOP, the OFS platform provides an ASE top-level
// module that generates ofs_plat_if. With this mechanism, the platform can
// construct a platform-specific simulated top-level environment.
// The macro specifies the module name that ASE's root module should
// instantiate.
`ifdef AFU_TOP_REQUIRES_AFU_MAIN_IF
  // Platform-specific afu_main() top-level emulation
  `define OFS_PLAT_PROVIDES_ASE_TOP ase_top_afu_main
`elsif SHARED_AFU_MAIN_TO_PORT_AFU_INSTANCES
  // The afu_main() and PIM entry in this FIM uses a standard afu_main()
  // provided by the FIM. Use that path to instantiate a PIM-based AFU.
  // We could also use ase_top_ofs_plat(), but that is a generic
  // environment constructed for simulation. We may as well simulate
  // the real afu_main() path.
  `define OFS_PLAT_PROVIDES_ASE_TOP ase_top_afu_main
`else
  // PIM ofs_plat_afu() top-level emulation
  `define OFS_PLAT_PROVIDES_ASE_TOP ase_top_ofs_plat
`endif

`endif // __OFS_PLAT_IF_TOP_CONFIG_VH__

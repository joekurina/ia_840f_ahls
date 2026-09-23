//
// This file has been generated automatically by afu_platform_config.
// Do not edit it by hand.
//
// Platform: ofs_agilex
// AFU top-level interface: ofs_plat_afu
//

`ifndef __PLATFORM_AFU_TOP_CONFIG_VH__
`define __PLATFORM_AFU_TOP_CONFIG_VH__

`define PLATFORM_CLASS_NAME "OFS_AGILEX"
`define PLATFORM_CLASS_NAME_IS_OFS_AGILEX 1

// This may be passed as the "intended_device_family"
// parameter to simulated megafunctions.
`define PLATFORM_INTENDED_DEVICE_FAMILY "AGILEX"

`define AFU_TOP_MODULE_NAME ofs_plat_afu
`define PLATFORM_SHIM_MODULE_NAME ofs_plat_afu

`define PLATFORM_FPGA_FAMILY_AGILEX 1
`define PLATFORM_FPGA_FAMILY_AGILEX7 1
`define ASE_AFU_MAIN_IF_OFFERED 1
`define AFU_MAIN_API_USES_INCLUDE_HSSI 1


// These top-level port classes are provided
`define PLATFORM_PROVIDES_OFS_PLAT_IF 1


//
// These top-level ports are passed from the platform to the AFU
//

// ofs_plat_if
`define AFU_TOP_REQUIRES_OFS_PLAT_IF_AFU 1


`endif // __PLATFORM_AFU_TOP_CONFIG_VH__

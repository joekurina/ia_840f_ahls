// (C) 2001-2026 Altera Corporation. All rights reserved.
// Your use of Altera Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files from any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License Subscription 
// Agreement, Altera IP License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


///////////////////////////////////////////////////////////////////////////////
// This module is responsible for exposing the controller sideband interfaces 
// through which soft logic interacts with the Hard Memory Controller. 
// The tile WYSIWYG blocks collapse the individual sideband signals into big
// buses. This module re-logics the big buses into proper interfaces.
// 
///////////////////////////////////////////////////////////////////////////////
module altera_emif_arch_fm_hmc_sideband_if #(

   // Parameters describing lanes/tiles
   parameter NUM_OF_HMC_PORTS                        = 1,
   parameter HMC_AVL_PROTOCOL_ENUM                   = "",
   parameter PHY_PING_PONG_EN                        = 0,
   parameter LANES_PER_TILE                          = 1,
   parameter NUM_OF_RTL_TILES                        = 1,
   parameter PRI_AC_TILE_INDEX                       = -1,
   parameter SEC_AC_TILE_INDEX                       = -1,
   parameter PRI_RDATA_TILE_INDEX                    = -1,
   parameter PRI_RDATA_LANE_INDEX                    = -1,
   parameter PRI_WDATA_TILE_INDEX                    = -1,
   parameter PRI_WDATA_LANE_INDEX                    = -1,
   parameter SEC_RDATA_TILE_INDEX                    = -1,
   parameter SEC_RDATA_LANE_INDEX                    = -1,
   parameter SEC_WDATA_TILE_INDEX                    = -1,
   parameter SEC_WDATA_LANE_INDEX                    = -1,
   parameter PRI_HMC_DBC_SHADOW_LANE_INDEX           = -1,

   // Definition of port widths for "ctrl_user_refresh" interface
   parameter PORT_CTRL_USER_REFRESH_REQ_WIDTH        = 1,
   parameter PORT_CTRL_USER_REFRESH_BANK_WIDTH       = 1,

   // Definition of port widths for "ctrl_self_refresh" interface
   parameter PORT_CTRL_SELF_REFRESH_REQ_WIDTH        = 1,

   // Definition describing ECC
   parameter PRI_HMC_CFG_ENABLE_ECC                  = "disable",
   parameter SEC_HMC_CFG_ENABLE_ECC                  = "disable",

   // Definition of port widths for "ctrl_ecc" interface
   parameter PORT_CTRL_ECC_WRITE_INFO_WIDTH          = 1,
   parameter PORT_CTRL_ECC_READ_INFO_WIDTH           = 1,
   parameter PORT_CTRL_ECC_CMD_INFO_WIDTH            = 1,
   parameter PORT_CTRL_ECC_WB_POINTER_WIDTH          = 1,
   parameter PORT_CTRL_ECC_RDATA_ID_WIDTH            = 1
   
) (
   // Collapsed sideband signals going into/out of tiles
   output logic [41:0]                                                  core2ctl_sideband_0,
   input  logic [13:0]                                                  ctl2core_sideband_0,
   output logic [41:0]                                                  core2ctl_sideband_1,
   input  logic [13:0]                                                  ctl2core_sideband_1,
   
   // Additional ECC signals going into/out of lanes
   input  logic [12:0]                                                  ctl2core_avl_rdata_id_0,
   input  logic [12:0]                                                  ctl2core_avl_rdata_id_1,
   output logic [12:0]                                                  core2l_wr_ecc_info,
   input  logic [11:0]                                                  l2core_wb_pointer_for_ecc,

   // Ports for "ctrl_user_refresh" interface
   input  logic [PORT_CTRL_USER_REFRESH_REQ_WIDTH-1:0]                  ctrl_user_refresh_req,
   input  logic [PORT_CTRL_USER_REFRESH_BANK_WIDTH-1:0]                 ctrl_user_refresh_bank,
   output logic                                                         ctrl_user_refresh_ack,

   // Ports for "ctrl_self_refresh" interface
   input  logic [PORT_CTRL_SELF_REFRESH_REQ_WIDTH-1:0]                  ctrl_self_refresh_req,
   output logic                                                         ctrl_self_refresh_ack,

   // Ports for "ctrl_will_refresh" interface
   output logic                                                         ctrl_will_refresh,
   
   // Ports for "ctrl_deep_power_down" interface
   input  logic                                                         ctrl_deep_power_down_req,
   output logic                                                         ctrl_deep_power_down_ack,

   // Ports for "ctrl_power_down" interface
   output logic                                                         ctrl_power_down_ack,
      
   // Ports for "ctrl_zq_cal" interface
   input  logic                                                         ctrl_zq_cal_long_req,
   input  logic                                                         ctrl_zq_cal_short_req,
   output logic                                                         ctrl_zq_cal_ack,

   // Ports for "ctrl_ecc" interface
   input  logic [PORT_CTRL_ECC_WRITE_INFO_WIDTH-1:0]                    ctrl_ecc_write_info_0,
   output logic [PORT_CTRL_ECC_WB_POINTER_WIDTH-1:0]                    ctrl_ecc_wr_pointer_info_0,
   output logic [PORT_CTRL_ECC_READ_INFO_WIDTH-1:0]                     ctrl_ecc_read_info_0,
   output logic [PORT_CTRL_ECC_CMD_INFO_WIDTH-1:0]                      ctrl_ecc_cmd_info_0,
   output logic                                                         ctrl_ecc_idle_0,
   output logic [PORT_CTRL_ECC_RDATA_ID_WIDTH-1:0]                      ctrl_ecc_rdata_id_0,
   
   input  logic [PORT_CTRL_ECC_WRITE_INFO_WIDTH-1:0]                    ctrl_ecc_write_info_1,
   output logic [PORT_CTRL_ECC_WB_POINTER_WIDTH-1:0]                    ctrl_ecc_wr_pointer_info_1,
   output logic [PORT_CTRL_ECC_READ_INFO_WIDTH-1:0]                     ctrl_ecc_read_info_1,
   output logic [PORT_CTRL_ECC_CMD_INFO_WIDTH-1:0]                      ctrl_ecc_cmd_info_1,
   output logic                                                         ctrl_ecc_idle_1,
   output logic [PORT_CTRL_ECC_RDATA_ID_WIDTH-1:0]                      ctrl_ecc_rdata_id_1

);
   timeunit 1ns;
   timeprecision 1ps;
   
   localparam NUM_C2L_FANOUT = NUM_OF_RTL_TILES * LANES_PER_TILE;

   assign core2ctl_sideband_0[3:0]   = ctrl_user_refresh_req;
   assign core2ctl_sideband_0[19:4]  = ctrl_user_refresh_bank;
   assign core2ctl_sideband_0[20]    = ctrl_deep_power_down_req;
   assign core2ctl_sideband_0[24:21] = ctrl_self_refresh_req;
   assign core2ctl_sideband_0[25]    = ctrl_zq_cal_long_req;
   assign core2ctl_sideband_0[26]    = ctrl_zq_cal_short_req;
   
   assign ctrl_user_refresh_ack      = ctl2core_sideband_0[6];
   assign ctrl_deep_power_down_ack   = ctl2core_sideband_0[7];
   assign ctrl_power_down_ack        = ctl2core_sideband_0[8];
   assign ctrl_self_refresh_ack      = ctl2core_sideband_0[9];
   assign ctrl_zq_cal_ack            = ctl2core_sideband_0[10];
   assign ctrl_will_refresh          = ctl2core_sideband_0[13];
   
  
   
   assign ctrl_ecc_read_info_0       = ctl2core_sideband_0[2:0];
   assign ctrl_ecc_cmd_info_0        = ctl2core_sideband_0[5:3];
   assign ctrl_ecc_idle_0            = ctl2core_sideband_0[12];
   assign ctrl_ecc_rdata_id_0        = ctl2core_avl_rdata_id_0;
   
   assign ctrl_ecc_wr_pointer_info_0 = l2core_wb_pointer_for_ecc[11:0];
   assign core2ctl_sideband_0[41:27] = ctrl_ecc_write_info_0;
   
   assign core2l_wr_ecc_info         = (NUM_OF_HMC_PORTS>0 && HMC_AVL_PROTOCOL_ENUM == "CTRL_AVL_PROTOCOL_ST")? ctrl_ecc_write_info_0[14:2] : 13'b0;
   
   assign ctrl_ecc_read_info_1       = 3'd0;
   assign ctrl_ecc_cmd_info_1        = 3'd0;
   assign ctrl_ecc_idle_1            = 1'b0;
   assign ctrl_ecc_rdata_id_1        = 13'd0;
   assign ctrl_ecc_wr_pointer_info_1 = 12'd0;
   assign core2ctl_sideband_1[3:0]   = '0;  
   assign core2ctl_sideband_1[19:4]  = '0;  
   assign core2ctl_sideband_1[20]    = '0;  
   assign core2ctl_sideband_1[24:21] = '0;  
   assign core2ctl_sideband_1[25]    = '0;  
   assign core2ctl_sideband_1[26]    = '0;  
   assign core2ctl_sideband_1[41:27] = 15'd0;

endmodule

`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "5CuDA+N0ipkxBbEFUigHJZjgKRBExUzGn9z/NRXk7X5L9zeYM+vdBVJ1f18yt+xMvY/22tVeb7s/H98agD+jK7YsarPT8vFtti1g/cmz8hXnwEr5xu5LhqSR+2HHb+em2Q3utiK6fTAx1ALvUZepSHwtTJ/aE66X1iGtlQu5tPocyrl5DTgTR40cmiiOLVMSsyIS5Ao4CrdifHzFPIRQUTo/6nxhwZ/xBegvjthbnPEpNc/Th2035pf70LTY1HlOiF0daGPyyB4H0sXC+XafW1bMrQui0kXxgoHMeTJU5otOpl44Beqmf990BGC3SyCML0me48xODR+GFWsh8esIYoQ4EVo9oGtMekcuC3raBHgYuL1/msscArXAMVdMcNfnzCHD6yusN8m7UgB58VIC92sReVMF74SjNU3lEYi+Jk4jMnp5hEmWo5Yy+JQe3mzJhBSQsAkQWcqEFcIPoKYOpv+Or6/Cb2h50H+fnHGbDKO3JUZefJKhTxNESWZeOgsHbTEAQD1jM4wpOV8U3ITvzZMRLmK6ECRT6QLkclPucnno0iBBxnqHXR8JrEcveKhKTZqqHTScfuXRXae9lcuORPri3p4FZB+R2FAtRxVQ9GDplXIoriH5DDmuJtxz8hIUo+wVMRCNxAxnT2XXw+XQmT+JRyk6VU1eOre29kT4nBjJtCQGDGrgHvxE1D/nB/SoP7E9T8BxpE3sK6BpJ5/TnInfYVPXZFiiWjtAGFJSvw/np8ZjVCkbgZrnihgumLHVBJlnE+TOiQye3tV5vtu/pZWsgIPHJe/k3HKT+7c1pftjG77YRAKWDAaIv9sClRhuSzPP6G4M9cCiw9OlYHaF9KKIkX2vrM0DlvGoVcvKn/xSjbp9e5+r/JGuTnGMzDsbueZ6WA6PmHUmFwtRfzWOx6+GCplnZa4xnAQ7uILWtGBXbw0w8CZHYUA2xR7vYTsj/XGls7Py3Q0XbD9M1s8vXKV08mYIaDfxX6BTuT9ZFji9U51yi5eeqgxN9eNdtBZf"
`endif
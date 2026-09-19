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
// This module handles the creation and wiring of the HPS clock/reset signals.
//
///////////////////////////////////////////////////////////////////////////////

// altera message_off 10036

 module altera_emif_arch_fm_hps_clks_rsts #(
   parameter PORT_CLKS_SHARING_MASTER_OUT_WIDTH      = 32,
   parameter PORT_CLKS_SHARING_SLAVE_IN_WIDTH        = 32,
   parameter PORT_DFT_ND_CORE_CLK_BUF_OUT_WIDTH      = 1,
   parameter PORT_DFT_ND_CORE_CLK_LOCKED_WIDTH       = 1,
   parameter PORT_HPS_EMIF_H2E_GP_WIDTH              = 1
) (
   // For a master interface, the PLL ref clock and the global reset signal
   // come from an external source from user logic, via the following ports. 
   // For slave interfaces, they come from the master via the sharing interface.
   // The connectivity ensures that all interfaces in a master/slave
   // configuration share the same ref clock and global reset, which is
   // one of the requirements for core-clock sharing.
   // pll_ref_clk_int is the actual PLL ref clock signal that will be used by the
   // reset of the IP. For a master interface it is equivalent to pll_ref_clk. 
   // For a slave interface it is equivalent to the pll_ref_clk signal of the master.
   input  logic                                                 pll_ref_clk,
   output logic                                                 pll_ref_clk_int,
   
   // Feedback signals to CPA via the core
   output logic [1:0]                                           core_clks_fb_to_cpa_pri,
   output logic [1:0]                                           core_clks_fb_to_cpa_sec,
   
   // Reset request signal.
   // local_reset_req_int is the actual reset request signal that will be
   // used internally by the rest of the IP. For a master interface it
   // is equivalent to local_reset_req. For a slave interface it is
   // equivalent to the local_reset_req signal of the master.
   input  logic                                                 local_reset_req,
   output logic                                                 local_reset_req_int,
   
   // The following is the master/slave sharing interfaces.
   input  logic [PORT_CLKS_SHARING_SLAVE_IN_WIDTH-1:0]          clks_sharing_slave_in,
   output logic [PORT_CLKS_SHARING_MASTER_OUT_WIDTH-1:0]        clks_sharing_master_out,
   
   // The following are all the possible core clock/reset signals.
   // afi_* only exists in PHY-only mode (or if soft controller is used).
   // emif_usr_* only exists if hard memory controller is used.
   output logic                                                 afi_clk,
   output logic                                                 afi_half_clk,
   output logic                                                 afi_reset_n,

   output logic                                                 emif_usr_clk,
   output logic                                                 emif_usr_half_clk,
   output logic                                                 emif_usr_reset_n,
   
   output logic                                                 emif_usr_clk_sec,
   output logic                                                 emif_usr_half_clk_sec,
   output logic                                                 emif_usr_reset_n_sec,

   // DFT
   output logic [PORT_DFT_ND_CORE_CLK_BUF_OUT_WIDTH-1:0]        dft_core_clk_buf_out,
   output logic [PORT_DFT_ND_CORE_CLK_LOCKED_WIDTH-1:0]         dft_core_clk_locked
);
   timeunit 1ns;
   timeprecision 1ps;
   
   // HPS clocks are not modeled for simulation.
   // Also in HPS mode we do not generate clocks that are visible to user logic.
   assign pll_ref_clk_int    = pll_ref_clk;
   
   // Reset request is not supported by HPS EMIF.
   // HPS EMIF has its own way of reset request mechanism.
   assign local_reset_req_int     = 1'b0;

   assign afi_clk                 = 1'b0;
   assign afi_half_clk            = 1'b0;
   assign afi_reset_n             = 1'b1;
   
   assign emif_usr_clk            = 1'b0;
   assign emif_usr_half_clk       = 1'b0;
   assign emif_usr_reset_n        = 1'b1;
   
   assign emif_usr_clk_sec        = 1'b0;
   assign emif_usr_half_clk_sec   = 1'b0;
   assign emif_usr_reset_n_sec    = 1'b1;
   
   assign core_clks_fb_to_cpa_pri = '0;
   assign core_clks_fb_to_cpa_sec = '0;
   assign clks_sharing_master_out = '0;
   
   assign dft_core_clk_locked     = '0;
   assign dft_core_clk_buf_out    = '0;
   
endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "5CuDA+N0ipkxBbEFUigHJZjgKRBExUzGn9z/NRXk7X5L9zeYM+vdBVJ1f18yt+xMvY/22tVeb7s/H98agD+jK7YsarPT8vFtti1g/cmz8hXnwEr5xu5LhqSR+2HHb+em2Q3utiK6fTAx1ALvUZepSHwtTJ/aE66X1iGtlQu5tPocyrl5DTgTR40cmiiOLVMSsyIS5Ao4CrdifHzFPIRQUTo/6nxhwZ/xBegvjthbnPHyqlaaKCrYQo3fSvnX2zmsuf5WOcpPEWc5xVGjAChlYmZc4KIIOJl0LYxaM0+q+LcDH8Q0iMXSO80NPfS0Zbw0LsC9uLFoYj1b6rzo52fkrnxMKXNpR5gbPJl3W6Zwe90QXKotVt3NJy5thS3KEnJ9mz1LoQ5BBxizslvF3jlgGyBN+mcWdh+3XE+xaMcqzSkkCPyLJGB4s6tGU4sVOzVgDzPttBrvca1YdAwd7nqCV+frciAhC1yAy/Z3SXTgbKEApejBtmyQ9ysYB+4F5mq39H9zcAZL1UpAb6Wk+s/vFvkIvphc4DJbnqquYletPOsAfMKqsJK498fKwD5y7DWrBWS9Ec3ks6uVrEkAMaynRn0DvPKNDdAi6CguC7gpuPd1MdM6C6EsF+Xw4iiCFAlW7t2pfN5gP7FzcbykUZ0OvtKSVDG+ac90hzhC11pgCakGPc4pI7OkkVNHqU4cPSosPxeGBrbD6f+LV6rOOC2DaravnansrhsOumEtVAjZveTi/GEBtpa5EWzPgr1dg+eNfpVIhPb8MrIzccg4N5yDOHb44ZHtCsG8d8ogOVmpZ1VOf0ZFomLjovc8BWf8hfY0p72KrvO3eUE0qZ1pEVD0lpMk+cVy6joSoHbeBjPnUzH4i4MmU8ASOVTIWfrS74JINKZrFvV/3UnTCN72KKSoU2fQW2q5SJq8JwN34OpjUiQuxbhoWj9sr+tSQnl0Tl3dkmMrC001l0WsCuJ69+PRMnDPA49jZjJ2Y/8KBX4PR5e53fJSKykBOA2xEwYnGy/W"
`endif
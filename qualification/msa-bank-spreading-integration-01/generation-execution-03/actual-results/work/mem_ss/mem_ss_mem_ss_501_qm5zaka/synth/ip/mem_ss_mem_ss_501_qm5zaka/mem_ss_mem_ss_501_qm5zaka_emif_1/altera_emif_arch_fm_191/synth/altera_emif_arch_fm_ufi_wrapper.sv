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
// UFI wrapper for FalconMesa EMIFs
///////////////////////////////////////////////////////////////////////////////

module altera_emif_arch_fm_ufi_wrapper #(
   parameter MODE   = "pin_ufi_use_in_direct_out_direct",
   parameter IS_HPS = 1,
   parameter IS_C2P = 1,
   parameter HIPI_DELAY= 225,
   parameter TIEOFF = 0
) (
   input logic                                       i_src_clk,
   input logic                                       i_dst_clk,

   input  logic                                      i_din,
   output logic                                      o_dout
);
   generate
     if (TIEOFF) begin
        assign o_dout = i_din;
     end else begin
        if (IS_HPS && !IS_C2P) begin : hps_p2c_ufi
           (* altera_attribute = {"-name FORCE_HYPER_REGISTER_FOR_PERIPHERY_CORE_TRANSFER ON; -name HYPER_REGISTER_DELAY_CHAIN 225; -name PRESERVE_FANOUT_FREE_WYSIWYG ON"} *)
           tennm_ufi #(
             .mode    (MODE),
             .datapath("p2c")
           ) preserved_ufi_inst (
             .srcclk (i_src_clk),
             .destclk(i_dst_clk),
             .d      (i_din),
             .dout   (o_dout)
           );
        end else begin
           if (!IS_C2P) begin : p2c_ufi
              (* altera_attribute = {"-name FORCE_HYPER_REGISTER_FOR_PERIPHERY_CORE_TRANSFER ON"} *)
              tennm_ufi #(
                .mode    (MODE),
                .datapath("p2c")
              ) ufi_inst (
                .srcclk (i_src_clk),
                .destclk(i_dst_clk),
                .d      (i_din),
                .dout   (o_dout)
              );
           end else if (HIPI_DELAY == 350) begin : c2p_350_ufi 
              (* altera_attribute = {"-name FORCE_HYPER_REGISTER_FOR_CORE_PERIPHERY_TRANSFER ON; -name HYPER_REGISTER_DELAY_CHAIN 350"} *)
              tennm_ufi #(
                .mode    (MODE),
                .datapath("c2p")
              ) ufi_inst (
                .srcclk (i_src_clk),
                .destclk(i_dst_clk),
                .d      (i_din),
                .dout   (o_dout)
              );
           end else if (HIPI_DELAY == 100) begin: c2p_100_ufi
              (* altera_attribute = {"-name FORCE_HYPER_REGISTER_FOR_CORE_PERIPHERY_TRANSFER ON; -name HYPER_REGISTER_DELAY_CHAIN 100"} *)
              tennm_ufi #(
                .mode    (MODE),
                .datapath("c2p")
              ) ufi_inst (
                .srcclk (i_src_clk),
                .destclk(i_dst_clk),
                .d      (i_din),
                .dout   (o_dout)
              );
           end else begin: c2p_225_ufi
              (* altera_attribute = {"-name FORCE_HYPER_REGISTER_FOR_CORE_PERIPHERY_TRANSFER ON; -name HYPER_REGISTER_DELAY_CHAIN 225"} *)
              tennm_ufi #(
                .mode    (MODE),
                .datapath("c2p")
              ) ufi_inst (
                .srcclk (i_src_clk),
                .destclk(i_dst_clk),
                .d      (i_din),
                .dout   (o_dout)
              );
           end

        end
     end
     
   endgenerate 
         

endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "5CuDA+N0ipkxBbEFUigHJZjgKRBExUzGn9z/NRXk7X5L9zeYM+vdBVJ1f18yt+xMvY/22tVeb7s/H98agD+jK7YsarPT8vFtti1g/cmz8hXnwEr5xu5LhqSR+2HHb+em2Q3utiK6fTAx1ALvUZepSHwtTJ/aE66X1iGtlQu5tPocyrl5DTgTR40cmiiOLVMSsyIS5Ao4CrdifHzFPIRQUTo/6nxhwZ/xBegvjthbnPFzClioatDTfuhS1kR/x9DT6Ok1ku/0gS4d72jE0bmbfnG2/fBO6Dz5KIbvYjux3uw8Ac1/tMhmgOL1gNZOaPHeEFvNSLujB5owocNGQ0BiUXEpIXH3BIK1xr0lEHg6y3WG7jQoI+sNUvS/aJ7oZLm7hYFZIVJTRxagp3ur9Abr9nZsfPZ1skM80dfo+WAY9ncXwpIT1FRD4KyQ7r60KEjqYybfkS1to7DbvZtDNAeOc08A5fWacszqB+rjAI9y0jW7Z/2MlItTTUw+pYwyGw6p3+fLorQIaMZw0GGZc8YPhcI/9r6DP0Wr4e0N90dJFaeOCty05kAGJrrMMR9eRl2Iv6l8sBnNlx+g2HgmXNBQOzdDfw6zevCGPaq9QVId61F4EZvEJvKH6vXOqwYEAtlgQASKeNI4DORsIficGZdWBrRkZHNscIJmd54a/dGEHWYVH3I0NAuFUwPFamn82j+/Qkou+KW4cPRlZApCnvqGAelrmsrRuZNQvJaYOP8GTytzYfs+ZGS6trZrLf7cL2OSh6JEVPfwOdyI+NA8Qe6BIas1Pb6KwAgDqix0hpD99CWoR5L0bnld9orpJSRKDoieyRNUh+pkzbyE4UA2hVMnwoJbTCeSfJZqIhvrNCWZtJ1EcvnbOPwHGPxNuqNLK/c9HeXaa4EVtB1q3s6sY85t2XDQ7RbNpyoZIZ/vr2EEv7XLpEGV27QbX1jvL5ZPIKikWopnI5sxM20mbum15N4iapN5Sra6KxwL4MUvg5OcRgk6Yb4LHYSuTxhLpWTrOuil"
`endif
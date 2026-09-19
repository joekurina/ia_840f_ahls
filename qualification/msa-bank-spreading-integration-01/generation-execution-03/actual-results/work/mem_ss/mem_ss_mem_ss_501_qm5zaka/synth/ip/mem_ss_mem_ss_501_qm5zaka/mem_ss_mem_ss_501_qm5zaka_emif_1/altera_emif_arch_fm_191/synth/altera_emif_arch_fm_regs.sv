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
// This module handles the creation of a conditional register stage.
// This module may be used to implement a synchronizer (with properly selected
// REGISTER value)
///////////////////////////////////////////////////////////////////////////////

// The following ensures that the register stage isn't synthesized into
// RAM-based shift-regs (especially if customer logic implements another follow-on
// pipeline stage). RAM-based shift-regs can degrade timing for C2P/P2C transfers.
(* altera_attribute = "-name AUTO_SHIFT_REGISTER_RECOGNITION OFF" *)

 module altera_emif_arch_fm_regs #(
   parameter REGISTER       = 0,
   parameter WIDTH          = 0
) (
   input  logic              clk,
   input  logic              reset_n,
   input  logic [WIDTH-1:0]  data_in,
   output logic [WIDTH-1:0]  data_out
) /* synthesis dont_merge */;
   timeunit 1ns;
   timeprecision 1ps;

   generate
      genvar stage;

      if (REGISTER == 0) begin : no_reg
         assign data_out = data_in;
      end else begin : regs
         logic [WIDTH-1:0] sr_out [(REGISTER > 0 ? REGISTER-1 : 0):0];

         assign data_out = sr_out[REGISTER-1];

         for (stage = 0; stage < REGISTER; stage = stage + 1)
         begin : stage_gen
            always_ff @(posedge clk or negedge reset_n) begin
               if (~reset_n) begin
                  sr_out[stage] <= '0;
               end else begin
                  sr_out[stage] <= (stage == 0) ? data_in : sr_out[stage-1];
               end
            end
         end
      end
   endgenerate
endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "5CuDA+N0ipkxBbEFUigHJZjgKRBExUzGn9z/NRXk7X5L9zeYM+vdBVJ1f18yt+xMvY/22tVeb7s/H98agD+jK7YsarPT8vFtti1g/cmz8hXnwEr5xu5LhqSR+2HHb+em2Q3utiK6fTAx1ALvUZepSHwtTJ/aE66X1iGtlQu5tPocyrl5DTgTR40cmiiOLVMSsyIS5Ao4CrdifHzFPIRQUTo/6nxhwZ/xBegvjthbnPGCI5EWmqXbq6F1/BWoQq1TkLoB57GvYgeq5NELpspDRn0p5usHdehCwS8258E8KTjUXlXp6di7ER6PBVkUWXwl8Kmbq2dLL0r5AkEz3tBbALAX2JBtkux4XFFvvKylK7JM1DN7MidhZwqZamhgapA3VTsAOBJc+vA2B9H6c1QfLsVbsMmg9E06wDTDfADOJaqDrsu+oEyzufxGFnz4FCYBG+bz1ymn+V82E3Q+c/5k/lVnVzlks4EwVC/mZafPOGSh4RQDAY8YF+0L6MKd3Q5ibBl8l0W9mg90P3pHvGhI8lbx53MqEhOeqviLAB7LUsnr7VDbQ1MDpVCFKSldvn/l/Ev4gvszLh7b0zPmZpwI451JiYFx5mAQrGj3aTh/yMcxsVQYihlftBD/ctecNOv3f4ZBWZuS0A8r1Ns9SKbdvF568sF44jpRXwNbxe6IEsMF1tpY6e+rcxs80dd1rwSl8+mS02fQuR2vDV+LOIrJImlALAKiS8+RCTiPjBF2sIFDyWLQDngvxdQIvKLvdc12oMEzdw6dKesA6lTTXQ6NP0BfdOZ4yumcZepDjP7MMULiZ7RP5rfESpZOMkCHH9znwkr9yiJQ6fvUN/y9IDkJZ9lotJs+5S6OaMdqmmsO8LHxrFHYQXZpZmoMdv507yNQlMwvdek24UUqthfR13vSvD4JlGig3G1sVOvAqb/UzTDHY9WccbNxhLopTeYTrfu8JXafRLSqiIIlozBrQW6++jfsqL7/VD6JMV22OuTwbFuLKSJhH25uLpH4+fRYjF7j"
`endif
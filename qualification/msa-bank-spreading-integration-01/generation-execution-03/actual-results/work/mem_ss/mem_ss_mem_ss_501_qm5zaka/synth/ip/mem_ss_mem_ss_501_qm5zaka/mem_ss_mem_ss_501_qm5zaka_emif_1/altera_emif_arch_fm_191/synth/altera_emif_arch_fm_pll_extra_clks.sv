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



////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  Expose extra core clocks from IOPLL
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////
module altera_emif_arch_fm_pll_extra_clks #(
   parameter PLL_NUM_OF_EXTRA_CLKS = 0,
   parameter DIAG_SIM_REGTEST_MODE = 0
) (
   input  logic                                               pll_locked,            
   input  logic [8:0]                                         pll_c_counters,        
   output logic                                               pll_extra_clk_0,       
   output logic                                               pll_extra_clk_1,
   output logic                                               pll_extra_clk_2,
   output logic                                               pll_extra_clk_3,
   output logic                                               pll_extra_clk_diag_ok
);
   timeunit 1ns;
   timeprecision 1ps;
   
   logic [3:0] pll_extra_clks;
   
   // Extra core clocks to user logic.
   // These clocks are unrelated to EMIF core clock domains. The feature is intended as a
   // way to reuse EMIF PLL to generate core clocks for designs in which physical PLLs are scarce.
   assign pll_extra_clks   = pll_c_counters[8:5];
   assign pll_extra_clk_0  = pll_extra_clks[0];
   assign pll_extra_clk_1  = pll_extra_clks[1];
   assign pll_extra_clk_2  = pll_extra_clks[2];
   assign pll_extra_clk_3  = pll_extra_clks[3];
   
   // In internal test mode, generate additional counters clocked by the extra clocks
   generate
      genvar i;
      
      if (DIAG_SIM_REGTEST_MODE && PLL_NUM_OF_EXTRA_CLKS > 0) begin: test_mode
         logic [PLL_NUM_OF_EXTRA_CLKS-1:0] pll_extra_clk_diag_done;
      
         for (i = 0; i < PLL_NUM_OF_EXTRA_CLKS; ++i)
         begin : extra_clk
            logic [9:0] counter;

            always_ff @(posedge pll_extra_clks[i] or negedge pll_locked) begin
               if (~pll_locked) begin	
                  counter <= '0;
                  pll_extra_clk_diag_done[i] <= 1'b0;
               end else begin
                  if (~counter[9]) begin
                     counter <= counter + 1'b1;
                  end
                  pll_extra_clk_diag_done[i] <= counter[9];
               end
            end         
         end
         
         assign pll_extra_clk_diag_ok = &pll_extra_clk_diag_done;
         
      end else begin : normal_mode
         assign pll_extra_clk_diag_ok = 1'b1;
      end
   endgenerate
   
endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "5CuDA+N0ipkxBbEFUigHJZjgKRBExUzGn9z/NRXk7X5L9zeYM+vdBVJ1f18yt+xMvY/22tVeb7s/H98agD+jK7YsarPT8vFtti1g/cmz8hXnwEr5xu5LhqSR+2HHb+em2Q3utiK6fTAx1ALvUZepSHwtTJ/aE66X1iGtlQu5tPocyrl5DTgTR40cmiiOLVMSsyIS5Ao4CrdifHzFPIRQUTo/6nxhwZ/xBegvjthbnPGnH8JoJtV0nroFuiqHuAZPTgEm7qf0fEluMYT2p0ELyjd0kxo+fIC8gK4kM6GOhOoMUbRnUdUb5mJvVaZXi4/SycyhcHqvTtNoS+0pBgzs7LtlDHKIXWRQStp5m+hUbxgVZvSbl4zOpaTZon7cmRLLsPRlzESKnq9jzb+STgrNmVNcxy2u+q6YN1UrEoYZqbzELm+X6c9sSARAArg3PqxraHeTKGSHfuIdxIOrkVYUhLxM2Gcrhq9arWttObGCG92pLFdqrdwbv6jtRlW94hwDBh14LTpYQOnTcRiqBOoVpi2Y15ZB6xqs7Rfos6qGw2+aR7XOURDqflTdHkXWdaYli4lVpZQFC7cRC8GzIF49XNmdWaurcL7ULDvz7yU6r9ASXgbI8ZsFRiS0W2dLBD7iWSWax37uJJ7B6/2iKsIPnW0VHS0SSGYRCZk765kkOFHfw7Y2J093o+PRQgJgDa/ijTpAxfa6gZ2hTlPxuikdUtwbTwktfHL40FNQp0/hV7rvYCqlCaLQ/DWXDxxtaLnFgqigXyEDzsyPJuZqasoLSNXEp5Od7LNxqDrw3ipBTvkEQeHt8s+8w+kLbsL4guBiTZZG2IjBP4/f423YkhzjwZfBWNPR5NqPDLc3Tk7w11uY8boTZF345Nr5N4sPGvYxo93TX0ddZX9bwmaG+0MjsFB+oTGfNu7m4lriOVHU/m/xvip+XRKKEgePap93h9KgT3efJXIMhTaR3OJkxRmV31YWN3n2cqyIkQmaG3gheZydup1sr7oTSEgqjQpdrVNv"
`endif
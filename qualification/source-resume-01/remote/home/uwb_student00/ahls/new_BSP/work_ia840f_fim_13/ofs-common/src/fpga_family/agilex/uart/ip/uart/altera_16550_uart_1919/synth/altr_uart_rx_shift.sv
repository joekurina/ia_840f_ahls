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


//
//Rx Shift Register
//
`timescale 1 ps / 1 ps
module altr_uart_rx_shift #(
    parameter DSIZE = 8
) (
   //Clock and Reset
   input  clk,
   input  rst_n,
   input  baud_clken,

   //CSR Interface
   input  lcr_eps_l,
   input  lcr_pen_l,

   //Serial Input
   input  sin_i,

   //RXFSM
   input  rxfsm_start,
   input  rxfsm_data,
   input  rxfsm_parity,
   input  rxfsm_stop,
   input  rxfsm_break1,

   //bit-timer
   input  half_bit_time,
   input  stop2_bit_time,
   input  [3:0] data_cnt,

   //shift reg output
   output logic [DSIZE-1:0] rx_shift_reg,
   output logic rx_parity,
   output logic rx_frame_error,
   output logic rx_parity_error,
   output logic rx_stop2

);

logic [DSIZE-1:0]  rx_shift_reg_nxt;
logic rx_parity_nxt;
logic rx_frame_error_nxt;
logic rx_parity_error_nxt;
logic rx_stop2_nxt;

//------------------------------------------------------------------------------
//RX_SHIFT_REG Logic
//------------------------------------------------------------------------------

always_ff @(posedge clk or negedge rst_n) begin
   if (!rst_n)          rx_shift_reg <= '0;
   else if (baud_clken) rx_shift_reg <= rx_shift_reg_nxt;
end

//For loop required to stamp out 8 copies of rx_shift_reg_nxt
//sin_i is loaded onto rx_shift_reg_nxt depending on the value
//of data_cnt
always_comb begin
   for(int i = 0; i < DSIZE; ++i) begin
      if (rxfsm_start)
         rx_shift_reg_nxt[i] = 0;
      else if (rxfsm_data & half_bit_time & (data_cnt == i))
         rx_shift_reg_nxt[i] = sin_i;
      else
         rx_shift_reg_nxt[i] = rx_shift_reg[i];
   end
end

//------------------------------------------------------------------------------
//RX_PARITY Logic
//------------------------------------------------------------------------------

always_ff @(posedge clk or negedge rst_n) begin
   if (!rst_n)          rx_parity <= 0;
   else if (baud_clken) rx_parity <= rx_parity_nxt;
end

always_comb begin
   if (rxfsm_start)
      rx_parity_nxt = 0;
   else if (rxfsm_parity & half_bit_time)
	  rx_parity_nxt = sin_i;
   else
      rx_parity_nxt = rx_parity;
end

//------------------------------------------------------------------------------
//RX_FRAME_ERROR Logic
//------------------------------------------------------------------------------

always_ff @(posedge clk or negedge rst_n) begin
   if (!rst_n)          rx_frame_error <= 0;
   else if (baud_clken) rx_frame_error <= rx_frame_error_nxt;
end

always_comb begin
   if (rxfsm_start)
      rx_frame_error_nxt = 0;
   else if (rxfsm_stop & half_bit_time)
      rx_frame_error_nxt = ~sin_i;
   else
      rx_frame_error_nxt = rx_frame_error;
end

//------------------------------------------------------------------------------
//RX_PARITY_ERROR Logic
//------------------------------------------------------------------------------

always_ff @(posedge clk or negedge rst_n) begin
   if (!rst_n)          rx_parity_error <= 0;
   else if (baud_clken) rx_parity_error <= rx_parity_error_nxt;
end

always_comb begin
   if (rxfsm_stop & half_bit_time)
	   rx_parity_error_nxt = lcr_eps_l ^~ (^(rx_shift_reg) ^ rx_parity);
   else
      rx_parity_error_nxt = rx_parity_error;
end

//------------------------------------------------------------------------------
//RX_STOP2 Logic
//------------------------------------------------------------------------------

always_ff @(posedge clk or negedge rst_n) begin
   if (!rst_n)          rx_stop2 <= 0;
   else if (baud_clken) rx_stop2 <= rx_stop2_nxt;
end

always_comb begin
   if (rxfsm_start)
      rx_stop2_nxt = 0;
   else if (rxfsm_break1 & stop2_bit_time)
      rx_stop2_nxt = sin_i;
   else 
      rx_stop2_nxt = rx_stop2;
end

endmodule: altr_uart_rx_shift
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "AKY/VDqroC56S5zYqI2FH+pDtMm2XXjvzWe8rGJiybS03yo4KNBMg81pmtWbHVIPiTA81zIuGQJqb5vOIzimr/z+D85S4Jjtk9u3+kDOlkJUsrbYjDeARoR1d2Gy20nZHckh8FGW+dSF0ir+jochMyts2Y//A4WlmCaB7gD83g5rkI4jT1ldDhtPnUUhGKawcEehCEezQ12Toa+YG3kf1PWegnVnp6lxL1nZ0P1Qzo8GDEslC1QB+ZbzPig5D1SeQrEb7WfiR3fZCkG3hPIWiPa59LvugHV/1DB3P4jGM3JocPsYqf0sJQoiIhPdluShgrKq+/utR2Z7qEs9JkmhrYfUhwe2U8CTzNNJ+pvOloGbvwap2MWPYzXhAYxI2+9CWKrqleLL0Vsf+C6zMrbAlBPBOi9Rz17wDDXLBJ9JCkZiBMd+RBwc7iru4wSN7VEf7WMV3WtJUoRioj11jw/2s182d3OiKXjf0EzYRW5UUM8Q2rbzx6cxrWRmDueQuX7nmcPnR1ReKDEsqSt061s7clToeaqjbIRJ8h4Iyh9u+Qd4jmab/B2qBCOQTnPhZcGBS+IF+Q4U9j3QgojIy/t8lYvDO7546nhOGbgYEnpaNUKtkYdjkJlyskw89IWcYb72Sm8J+9NfPs2khel1HG1iKL3EQJsqVIoIkbiSgHXPWZSu9hVGN1OMXAj0G9ninawVIFXC0FO/awSGmvXji1SNlWanXmwbdFX8QAve4n3ReNuUHvk9WUMX5mhvBTN3NflTI3yS4ReiO0W4Kj8Lr4AJPpvju7MdLsIFpqI0klMg8oOPNXRUxyS9GctGiPerN0Fc5+5q03kO1KYwLSEMG9jDp4VSrVIAQu2t2ipGEAdZ6DscsgpN+B67M71vFq+tpGuOjNW5FV3FXrpIQ04uUqdtAzAMOE4Vhb+04XrVrH1eQ+rxvizJPW6kUh8cNEYvYlGfKfaJp1hees+Ze03umcS5pB9+PnJc6j+Rc47Sp0JHaKGSkezcy3L+QJy7BoVdRbEL"
`endif
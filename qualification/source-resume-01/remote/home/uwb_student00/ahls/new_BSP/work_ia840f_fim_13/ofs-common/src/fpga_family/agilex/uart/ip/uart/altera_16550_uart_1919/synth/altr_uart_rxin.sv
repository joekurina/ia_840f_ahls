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
//RXIN samples serial input from SIN
//
`timescale 1 ps / 1 ps
module altr_uart_rxin #(
    parameter ACTUAL_DSIZE = 8,
	parameter EXPAND_DSIZE = 11
) (
   //Clock and Reset
   input  clk,
   input  rst_n,
   input  baud_clken,

   //CSR Interface
   input  lcr_sp,
   input  lcr_eps_l,
   input  lcr_pen_l,
   input  lcr_stop_l,
   input  [2:0] lcr_dls_l,

   //Serial Input
   input  sin_i,

   //Put Signal
   output rxin_put,

   output rxfsm_idle,

   //Shift register output
   output [EXPAND_DSIZE-1:0] rx_data

);

//bit-timer counts
logic  half_bit_time;
logic  qtr_bit_time;
logic  stop2_bit_time;
logic  [3:0] bit_timer;
logic  bit_timer_inc;

//data_cnt counts
logic  data_cnt_full;

//RXFSM state indicators
logic rxfsm_start;
logic rxfsm_data;
logic rxfsm_parity;
logic rxfsm_stop;
logic rxfsm_break1;
logic rxfsm_break2;

//break detection
logic p_rx_break;
logic rx_break;
logic rx_break_indicator;

//new load logic
logic rxfsm_load;

logic data_cnt_s_rst;
logic data_cnt_inc;
logic [3:0] data_cnt;

//shift reg output
logic [ACTUAL_DSIZE-1:0] rx_shift_reg;
logic rx_parity;
logic rx_frame_error;
logic rx_parity_error;
logic rx_stop2;

//------------------------------------------------------------------------------
//RXFSM Logic
//------------------------------------------------------------------------------
altr_uart_rxfsm rxfsm (
   .*
);

//------------------------------------------------------------------------------
//Break Detection Logic
//------------------------------------------------------------------------------

//Possible Break condition where >1 stop bits are configured
assign p_rx_break =  lcr_stop_l & rx_frame_error & ~rx_parity & (rx_shift_reg == {ACTUAL_DSIZE{1'b0}});

//Break condition where 1 stop bit is configured
assign rx_break   = ~lcr_stop_l & rx_frame_error & ~rx_parity & (rx_shift_reg == {ACTUAL_DSIZE{1'b0}});

//When both p_rx_break and rx_break are both zero - that means no break condition exists

//This will be the break indicator sent "upstream" to RXSTOR
//Break is detected at 2 points
// 1) in BREAK1 state when 1 stop bit is configured
// 2) in BREAK2 state when 1.5/2 stop bit is configured [last stop bit must be zero]
assign rx_break_indicator = (rxfsm_break1 & rx_break) | (rxfsm_break2 & ~rx_stop2);

//------------------------------------------------------------------------------
//RX_BIT_TIMER Logic
//------------------------------------------------------------------------------

//Rx Bit Timer Increment Term
assign bit_timer_inc = rxfsm_start | rxfsm_data | rxfsm_parity | rxfsm_stop | rxfsm_break1;

//Rx Bit Timer Outputs
assign half_bit_time = (bit_timer == 4'h8);
assign qtr_bit_time = (bit_timer == 4'h4);
assign stop2_bit_time = (lcr_dls_l == 3'b000) ? qtr_bit_time : half_bit_time;

//Rx Bit Timer Instantiation
altr_uart_bit_timer rx_bit_timer (
   .inc(bit_timer_inc),
   .s_rst(~bit_timer_inc),
   .*
);

//------------------------------------------------------------------------------
//RX_DATA_CNT Logic
//------------------------------------------------------------------------------

assign data_cnt_s_rst = ~rxfsm_data | data_cnt_full;
assign data_cnt_inc   = rxfsm_data & half_bit_time;

altr_uart_data_cnt rx_data_cnt (
   .s_rst(data_cnt_s_rst),
   .inc(data_cnt_inc),
   .*
);


//------------------------------------------------------------------------------
//RX OUTPUT Logic
//------------------------------------------------------------------------------

assign rx_data = {rx_parity_error & lcr_pen_l, rx_frame_error, rx_break_indicator, rx_shift_reg};

//Loading will happen in BREAK1 state under all circumstances
//except when a BREAK is detected where number of stop bits > 1
always_comb begin
   rxfsm_load = (rxfsm_break1 & ~p_rx_break) | rxfsm_break2;
end

//This logic intentionally runs on "clk" - NOT baud_clk
logic rxfsm_load_r;

always_ff @(posedge clk or negedge rst_n) begin
   if (!rst_n) rxfsm_load_r <= 0;
   else rxfsm_load_r <= rxfsm_load;
end

assign rxin_put = rxfsm_load & ~rxfsm_load_r;


//------------------------------------------------------------------------------
//RX_SHIFT_REGISTER Logic
//------------------------------------------------------------------------------
altr_uart_rx_shift  #(
   .DSIZE(ACTUAL_DSIZE)
) rx_shift (.*);

endmodule: altr_uart_rxin
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "AKY/VDqroC56S5zYqI2FH+pDtMm2XXjvzWe8rGJiybS03yo4KNBMg81pmtWbHVIPiTA81zIuGQJqb5vOIzimr/z+D85S4Jjtk9u3+kDOlkJUsrbYjDeARoR1d2Gy20nZHckh8FGW+dSF0ir+jochMyts2Y//A4WlmCaB7gD83g5rkI4jT1ldDhtPnUUhGKawcEehCEezQ12Toa+YG3kf1PWegnVnp6lxL1nZ0P1Qzo/5bfm1DpZnjmS9FreKPErj+L3OnjsW0MctXSMDJv1LDKdb7LMkBtwG42+wMhMn4rk+zvoY7TRXRFvEDN2deilqGLyyy0zJnt+Di0cJeK7vWAg2BJ1b8szByZY9I1QVx3DUkrt/uqYsBGcZDAF5vE+Ss4+MApr8ar6vhEHDtx0gAXuTjvgcnvM0xWz0nXnPo0RFyZy4FMyVIUUoPoTZcJCvadh4bzNFEBYoKDkm5RR4QT8FrB61uV90t4jnjIh54XTlFIE/bslCrjSUpvM/K6nVSbpQafKjd4D1rOSHjyEByN8cXLQ6Ey2FMVMMTUrj2H+2zhm/ne0uhaW/LScf3chykmkrHA/i7lEPzfOhC/VJRtCPgODwedGI32S/yIALewrUGB9kjPwJB9L/VfmR58IKenLPTJYGArgxz35DaZpxp1Ua0ueUDSyIHJw2JDwUb6Hm+O/igoiUsSe1hr19FYQiqtyXbLkneRUhAv0Uu8nQKZ7e1tvk2SP7/HoaQGJVDjuHNndFi0JaYby/lp/zluC7KbJoa/0b6Aj3Lz/HjavweQx+lE9et72urZo+zYKRfMkwv4XvR+LbiOgMQ/BePO3Pc3gLTULrAMb+jZI16YS7v3caLkybpyOrq/GKXt+FZlKsZ5SFmKLRljSHtbBf2Bkp3j2Zhrx8litG4by1m6J0ZCgCcreNuB5P4EYcdJlNh98hIpdiPsZbMShkfWdWmJsRugrmU1owNvkPh77BY2vcLghJEXRVbpt+zdW8RNKs0fNdg/8pO4a5dWEqQvg02hRb"
`endif
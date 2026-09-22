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
//TXOUT drives serial data out to SOUT
//
`timescale 1 ps / 1 ps
module altr_uart_txout #(
    parameter DSIZE = 8
) (/*port details*/
   //Clock and Reset
   input  clk,
   input  rst_n,
   input  baud_clken,

   //CSR Inputs
   input  lcr_break,
   input  lcr_pen_l,
   input  lcr_sp_l,
   input  lcr_eps_l,
   input  lcr_stop_l,
   input  [2:0] lcr_dls_l,

   //Consolidated avail input from TXSTOR or TXFC
   input  txout_avail,

   //Consolidated datapath from TXSTOR and TXFC
   input  [DSIZE-1:0] tx_data,

   //Get output from TXOUT
   output txout_get,

   //RXFC FSM - XON state
   input  rxfc_xon,

   //TXFSM Idle state
   output txfsm_idle,

   //SOUT signal
   output sout_pre,
   output sout_oe_pre
);

//txfsm internal signals
logic txfsm_start;
logic txfsm_data;
logic txfsm_parity;
logic txfsm_stop;

//bit_timer internal signals
logic [3:0] bit_timer;
logic bit_timer_inc;
//logic bit_timer_zero;
logic one_bit_time;
logic one_bit_time_m1;
logic half_bit_time;
logic half_bit_time_m1;

//data_cnt internal signals
logic data_cnt_s_rst;
logic data_cnt_inc;
logic data_cnt_full;

//get internal signal
logic load_r;

//tx_shift_reg controls
logic load;
logic shift;

//------------------------------------------------------------------------------
//TXFSM Logic
//------------------------------------------------------------------------------
altr_uart_txfsm txfsm (.*);

//------------------------------------------------------------------------------
//TX_BIT_TIMER Logic
//------------------------------------------------------------------------------

//Tx Bit Timer Increment Term
assign bit_timer_inc = txfsm_start | txfsm_data | txfsm_parity | txfsm_stop;

//Tx Bit Timer Outputs
//assign bit_timer_zero   = (bit_timer == 4'h0);
assign one_bit_time     = (bit_timer == 4'hF);
assign one_bit_time_m1  = (bit_timer == 4'hE);
assign half_bit_time    = (bit_timer == 4'h8);
assign half_bit_time_m1 = (bit_timer == 4'h7);


//Tx Bit Timer Instantiation
altr_uart_bit_timer tx_bit_timer (
   .inc(bit_timer_inc),
   .s_rst(~bit_timer_inc),
   .*
);
  
//------------------------------------------------------------------------------
//TX_DATA_COUNTER Logic
//------------------------------------------------------------------------------

assign data_cnt_s_rst = ~txfsm_data | data_cnt_full;
assign data_cnt_inc = txfsm_data & one_bit_time;

//Tx Data Counter Instantiation
altr_uart_data_cnt tx_data_cnt (
   .s_rst(data_cnt_s_rst),
   .inc(data_cnt_inc),
   .data_cnt(),
   .*
);

//------------------------------------------------------------------------------
//TXOUT Get Logic
//------------------------------------------------------------------------------

//txout_get drains 1 character from TXSTOR
// txout_get runs in "clk" domain while 
// load runs in "baud_clken" domain
// txout_get should only assert after load
// use falling edge detect on load for txout_get
always_ff @(posedge clk or negedge rst_n) begin
   if (!rst_n) load_r <= 0;
   else        load_r <= load;
end

//txout_get has additional qualifiers to take into account possibility that txout_avail
//can deassert before txout_get
//txout_get uses a combination of logic in both baud_clk and clk domain
assign txout_get = ~load & load_r & txfsm_start & txout_avail;

//------------------------------------------------------------------------------
//TX_SHIFT_REG Logic
//------------------------------------------------------------------------------

//load signals is now exactly the same as the signal that triggers
//the transition from IDLE to START state for TXOUT FSM
//load = arc_IDLE_START
//load uses a combination of logic in both baud_clk and clk domain
assign load = txfsm_idle & txout_avail & rxfc_xon;

//shift logic
assign shift = txfsm_data & one_bit_time;

//tx_shift_reg instantiation
altr_uart_tx_shift #(
   .DSIZE(DSIZE)
) tx_shift (.*);

//------------------------------------------------------------------------------
//SOUT_EN logic
//------------------------------------------------------------------------------

//Beta-feature (Fogbugz: 112424)
//Signal is used to turn on transmit buffer
assign sout_oe_pre = ~txfsm_idle;

endmodule: altr_uart_txout
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "AKY/VDqroC56S5zYqI2FH+pDtMm2XXjvzWe8rGJiybS03yo4KNBMg81pmtWbHVIPiTA81zIuGQJqb5vOIzimr/z+D85S4Jjtk9u3+kDOlkJUsrbYjDeARoR1d2Gy20nZHckh8FGW+dSF0ir+jochMyts2Y//A4WlmCaB7gD83g5rkI4jT1ldDhtPnUUhGKawcEehCEezQ12Toa+YG3kf1PWegnVnp6lxL1nZ0P1Qzo+G5aU61UuAhtwgXiVoj6s35TFrsY8TxmQb9xxiABjb3jKqi3Grew1tnimsPMmONUQcP29fSjwy39l31ABQWB10rqHL6YCpa0+9x6RNI2yfig2qm6TZwr1j8ypEC2xh513RK8wbacQrUfdQrf3NVgC1TpNBjWEPr1y99uYDvUkapjkvjYC8ZoK6C+TqXC/Y7mcXIEYL9OME8HKStCfRchqABKfoFlSrwx4OPU/mpIeipgxpSSsBGEjS2sCGSwgImfo+OdTcz6Hh4v2x4i2I5iGmDCsecAyL1RQrTbfPgt8piI7Da0LhOZJXv26ERubjyJldeM3qKi4+F/LbeghOXv9b8D1EzHlCL+RevASxROuGK0kGCRyTcCAoVAXkJyF3ZqNLUn29UWK9mTBVG2HXhThgEnX4bwy3qZl2T5dzlkk8LpUqyJw5CnBcerReB5ZFnOvqxz33GCHIY+9R5kWTHE5W53RZ5vBTE5IFe7uLRi/vIEPAJ88ESM12tWVhS9HOTF78dK/1c9wYUBkJ6BH2qnHrxaYatKFazCj8Ccy5Xq5vS0mSUVNEOPCkDwehn1fazMh5pG7GFuf/Bwj8y5nQCijveb2owgIvMsgsoA2FRQhiwwFY2axl0l+VolNSvX/J41Mmf6cnZt8GQKsIxyUg0V9Njgd5Uj/hcEJDoIx5VGN/yn1ovrmWncMH+H3ZV4L9M6VCHq1MaULD0uFJ6IFLP3Zj2k1OsD+Fbw8Frv9SOAj4886tUlta8BdPbQWvGlsJfCslPECfCi+wEwAMHwVjZlHt"
`endif
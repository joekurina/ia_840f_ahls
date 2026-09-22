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
//Transmit shift register
//Drives data out to SOUT
//Implements 3 functions actually
//1. The data shift register
//2. Parity calculator
//3. Output Mux
//
`timescale 1 ps / 1 ps
module altr_uart_tx_shift #(
    parameter DSIZE = 8
) (
   //Clock and Reset
   input  clk,
   input  rst_n,
   input  baud_clken,

   //CSR Inputs
   input  lcr_break,
   input  [2:0] lcr_dls_l,
   input  lcr_sp_l,
   input  lcr_eps_l,

   //Consolidated datapath from TXSTOR and TXFC
   input  [DSIZE-1:0] tx_data,

   //Shift register controls
   input  load,
   input  shift,

   //TXFSM states - these will exclusively be used to drive SOUT
   input txfsm_idle,
   input txfsm_start,
   input txfsm_data,
   input txfsm_parity,
   input txfsm_stop,

   //SOUT signal
   output logic sout_pre

);

localparam MARK = 1'b1;
localparam SPACE = 1'b0;


logic [DSIZE-1:0] tx_data_i;
logic [DSIZE-1:0] tx_shift_reg, tx_shift_reg_nxt;

logic tx_parity, tx_parity_nxt;

//------------------------------------------------------------------------------
//Align txout_data with data length configuration
//------------------------------------------------------------------------------
always_comb begin
   case(lcr_dls_l)
  		3'b000: tx_data_i = {4'b0, tx_data[4:0]};
  		3'b001: tx_data_i = {3'b0, tx_data[5:0]};
  		3'b010: tx_data_i = {2'b0, tx_data[6:0]};
 		3'b011: tx_data_i = {1'b0, tx_data[7:0]};
		3'b100: tx_data_i = tx_data[8:0];
		default : tx_data_i = {DSIZE{1'b0}};
   endcase
end

//------------------------------------------------------------------------------
//Tx Shift Registers
//------------------------------------------------------------------------------
always_ff @(posedge clk or negedge rst_n) begin
   if (!rst_n)          tx_shift_reg <= '0;
   else if (baud_clken) tx_shift_reg <= tx_shift_reg_nxt;
end

always_comb begin
   //Unique --> full_case & parallel_case
   //       --> all cases have been defined
   //       --> don't build priority encoder
   //       --> load and shift cannot assert at the same time
   unique case({load, shift})
      2'b00: tx_shift_reg_nxt = tx_shift_reg;
      2'b01: tx_shift_reg_nxt = tx_shift_reg >> 1;
      2'b10: tx_shift_reg_nxt = tx_data_i;

      default: tx_shift_reg_nxt = 0;
   endcase
end

//------------------------------------------------------------------------------
//Tx Shift Registers
//------------------------------------------------------------------------------
always_ff @(posedge clk or negedge rst_n) begin
   if (!rst_n)          tx_parity <= 0;
   else if (baud_clken) tx_parity <= tx_parity_nxt;
end

always_comb begin
   if (load)
      tx_parity_nxt = lcr_sp_l ? ~lcr_eps_l : lcr_eps_l ^~ (^(tx_data_i));
   else
      tx_parity_nxt = tx_parity;
end

//------------------------------------------------------------------------------
//Output Mux
//------------------------------------------------------------------------------

//This is a priority case. Specifically - lcr_break is allowed to assert at the
//same time as txfsm_* - lcr_break should always have the highest priority
//priority keyword basically states that the case is "full" - one of the case
//branches must be true at all times
always_comb begin
   priority case(1'b1)
      lcr_break   : sout_pre = SPACE;
      txfsm_idle  : sout_pre = MARK;
      txfsm_start : sout_pre = SPACE;
      txfsm_data  : sout_pre = tx_shift_reg[0];
      txfsm_parity: sout_pre = tx_parity;
      txfsm_stop  : sout_pre = MARK;

      default: sout_pre = SPACE;
   endcase
end

endmodule: altr_uart_tx_shift
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "AKY/VDqroC56S5zYqI2FH+pDtMm2XXjvzWe8rGJiybS03yo4KNBMg81pmtWbHVIPiTA81zIuGQJqb5vOIzimr/z+D85S4Jjtk9u3+kDOlkJUsrbYjDeARoR1d2Gy20nZHckh8FGW+dSF0ir+jochMyts2Y//A4WlmCaB7gD83g5rkI4jT1ldDhtPnUUhGKawcEehCEezQ12Toa+YG3kf1PWegnVnp6lxL1nZ0P1Qzo/2VVoHrjfAyJoHsncro14R2vd31JIWO+Z94abqmAirnIpNEPS10juFWRe53BW6E29lvESqHMQn/ceawdqiBZb+a2UFw12CTlf8MQvZlqcLy+QODHsSEmuuHBQoQn48VyMqh6g7j8qMDFzP69qCbYMVK+JIfpPNCI46mGOqqhv171NBG1Qa/nUB8widXWAoTDaxoUjdT/DQZSA66+6O1p6yB2Ymt5atjnD+Y0YzMe4UbBCSzO+m0ZMQuunr/8jn+EgcgtDy9Wd0PIhH94wWkWkqdyRa6dwNLxu1g1QIOT4KU/ZNIceB1H+MJSsblI0FO/6TKrfICN8D1JDwEiZAqw/PvRauU729m4RmIDmgv/weFYiosxBFzrxyQAKQEu/omcZZaZWRi/97VDmh2H4WxXmHOPjHbnhNqIWQzHtHsbfYEhbLvryrXS0m9C29O4ovAdhDtnMuEXaicwSXGLFnhZzkcRFhFsuGNo4j8Ea0DSJuM1vzPWSrI6lhDOs2A1prbQaeOrYr3/GZjmGwRZUF4sZxxPFHA5ypyC858lz2nvNpTBpj8UiciZ/unBhVGHHdZpyKWw53MOMG0+w65hN4kXcn8I+C+MUvLNmMfIKKG3ypJvzxhJL9Ww2vxpbnVE0TE1DjDePfN1eL2mTX7jU4mj5LvzE2fge0w8LLkcAyvWARgdjHtPTUglZxYhoGo6kPhFjF4rEH43R8H5T7ZTkXcDmSrs6RQjoIXRM8I+bXqyHJA5v38hDQFdlBImWLoF7+X8UEkwv76a7rr4gAzPLJe8Sf"
`endif
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
// This is an extension of the CSR.
// Certain register elements cannot be
// fully described by CSRSpec. Therefore
// the HDL implementation needs to be
// hand coded.
// This module stores all hand-coded logic
// related to the CSR.
//
`timescale 1 ps / 1 ps
module altr_uart_csrext #(
    parameter DSIZE = 8
) (
   //Clock and Reset
   input  clk,
   input  rst_n,

   //RBR_THR_DLL csr hooks
   input  rbr_thr_dll_read_access,
   input  rbr_thr_dll_write_access,
   input  [31:0] rbr_thr_dll_write_data,
   output [31:0] rbr_thr_dll_read_data,

   //Receive Buffer Register
   output rbr_read_access,
   input  [DSIZE-1:0] rbr_read_data,

   //Transmit Holding Register (THR)
   output thr_write_access,
   output [DSIZE-1:0] thr_write_data,

   //Divisor Latch Low
   input  [7:0] dll,

   output dll_write_access,
   output [7:0] dll_write_data,

   //IER_DLH csr hooks
   input  ier_dlh_read_access,
   input  ier_dlh_write_access,
   input  [31:0] ier_dlh_write_data,
   output [31:0] ier_dlh_read_data,

   //Receive Data Interrupt Enable
   output logic ier_erbfi,

   //Transmit Data Interrupt Control
   output logic ier_etbei,

   //Enable Receiver Line Status
   output logic ier_elsi,

   //Enable Modem Status Interrupt
   output logic ier_edssi,

   //Divisor Latch High
   input  [7:0] dlh,

   output dlh_write_access,
   output [7:0] dlh_write_data,

   //LCR
   input  lcr_dlab,

   //IIR FIFO Enabled
   input  glb_fifoe,
   output [1:0] iir_fifose,

   //LSR csr hooks
   input  lsr_read_access,
   output [31:0] lsr_read_data,

   //LSR inputs
   //Logic for these CSR bits are implemented
   //elsewhere
   input  lsr_rfe,
   input  lsr_thre,
   input  lsr_dr,

   //LSR source inputs - used to set LSR bits
   input  lsr_bi_source,
   input  lsr_fe_source,
   input  lsr_pe_source,
   input  lsr_oe_source,
   input  lsr_error_mask_clr,

   //LSR Outputs
   output lsr_bi,
   output lsr_fe,
   output lsr_pe,
   output logic lsr_oe,

   //LSR TEMT
   input  txstor_avail,
   input  txfsm_idle,
   output lsr_temt,

   //LCR register latching
   input  rxfsm_idle,
   input  lcr_sp,
   input  lcr_eps,
   input  lcr_pen,
   input  lcr_stop,
   input  [2:0] lcr_dls,

   output logic lcr_sp_l,
   output logic lcr_eps_l,
   output logic lcr_pen_l,
   output logic lcr_stop_l,
   output logic [2:0] lcr_dls_l
);

//------------------------------------------------------------------------------
//REG: RBR_THR_DLL Logic
//------------------------------------------------------------------------------

// THR
assign thr_write_access = rbr_thr_dll_write_access & ~lcr_dlab;
assign thr_write_data = rbr_thr_dll_write_data[DSIZE-1:0]; // Top 23 bits are unused

// RBR 
assign rbr_read_access = rbr_thr_dll_read_access & ~lcr_dlab;

// DLL - Register will be implemented in CLKGEN
// CLKGEN will need access to the *write_access signal anyway
assign dll_write_access = rbr_thr_dll_write_access & lcr_dlab;
assign dll_write_data = rbr_thr_dll_write_data[7:0]; // Top 24 bits are unused

// RBR_THR_DLL Read data
assign rbr_thr_dll_read_data = lcr_dlab ? {24'b0, dll} : {{32-DSIZE{1'b0}}, rbr_read_data}; 


//------------------------------------------------------------------------------
//REG: IER_DLH Logic
//------------------------------------------------------------------------------

//ERBFI
always_ff @(posedge clk or negedge rst_n) begin
   if (!rst_n)
      ier_erbfi <= 0;
   else if (ier_dlh_write_access & ~lcr_dlab)
      ier_erbfi <= ier_dlh_write_data[0];
end

//ETBEI
always_ff @(posedge clk or negedge rst_n) begin
   if (!rst_n)
      ier_etbei <= 0;
   else if (ier_dlh_write_access & ~lcr_dlab)
      ier_etbei <= ier_dlh_write_data[1];
end

//ELSI
always_ff @(posedge clk or negedge rst_n) begin
   if (!rst_n)
      ier_elsi <= 0;
   else if (ier_dlh_write_access & ~lcr_dlab)
      ier_elsi <= ier_dlh_write_data[2];
end

//EDSSI
always_ff @(posedge clk or negedge rst_n) begin
   if (!rst_n)
      ier_edssi <= 0;
   else if (ier_dlh_write_access & ~lcr_dlab)
      ier_edssi <= ier_dlh_write_data[3];
end

// DLH - Register will be implemented in CLKGEN
assign dlh_write_access = ier_dlh_write_access & lcr_dlab;
assign dlh_write_data = ier_dlh_write_data[7:0]; // Top 24 bits are unused

// IER_DLH Read data
assign ier_dlh_read_data = lcr_dlab ? {24'b0, dlh} : {28'b0, ier_edssi, ier_elsi, ier_etbei, ier_erbfi};

//------------------------------------------------------------------------------
//REG: IIR FIFOSE Logic
//------------------------------------------------------------------------------
assign iir_fifose = glb_fifoe ? 2'b11 : 2'b00;

//------------------------------------------------------------------------------
//REG: LSR OE
//------------------------------------------------------------------------------
logic lsr_oe_nxt;

always_ff @(posedge clk or negedge rst_n) begin
   if (!rst_n) lsr_oe <= 0;
   else        lsr_oe <= lsr_oe_nxt;
end

assign lsr_oe_nxt =  (lsr_oe_source)   ? 1'b1 : 
                     (lsr_read_access) ? 1'b0 : 
                     lsr_oe;

//------------------------------------------------------------------------------
//REG: LSR error mask (for PE/FE/BI)
//------------------------------------------------------------------------------
logic lsr_error_mask, lsr_error_mask_nxt;

always_ff @(posedge clk or negedge rst_n) begin
   if (!rst_n) lsr_error_mask <= 0;
   else        lsr_error_mask <= lsr_error_mask_nxt;
end

assign lsr_error_mask_nxt =   (lsr_error_mask_clr) ? 1'b0 :
                              (lsr_read_access & lsr_dr) ? 1'b1 :
                              lsr_error_mask;

//------------------------------------------------------------------------------
//REG: LSR PE
//------------------------------------------------------------------------------
assign lsr_pe = lsr_pe_source & ~lsr_error_mask;

//------------------------------------------------------------------------------
//REG: LSR FE
//------------------------------------------------------------------------------
assign lsr_fe = lsr_fe_source & ~lsr_error_mask;

//------------------------------------------------------------------------------
//REG: LSR BI
//------------------------------------------------------------------------------
assign lsr_bi = lsr_bi_source & ~lsr_error_mask;

//------------------------------------------------------------------------------
//REG: LSR TEMT
//------------------------------------------------------------------------------
//txstor_avail = glb_fifoe ? ~txfifo_empty : ~thr_empty;
//transmit shift register is not working if it is in IDLE state - txfsm IDLE state
//is good enough to indicate that the shift register is "empty"
assign lsr_temt = ~txstor_avail & txfsm_idle;

//------------------------------------------------------------------------------
//REG: LSR Read Data
//------------------------------------------------------------------------------

assign lsr_read_data = {24'b0, lsr_rfe, lsr_temt, lsr_thre, lsr_bi, lsr_fe, lsr_pe, lsr_oe, lsr_dr};

//------------------------------------------------------------------------------
//LCR[4:0] Latching Logic
//Allow these values to be latched only when both the Transmit and Receive
//FSM is in IDLE state
//------------------------------------------------------------------------------

//latch enable
logic l_en;

assign l_en =  txfsm_idle & rxfsm_idle;

//Stick Parity Select latch
always_ff @(posedge clk or negedge rst_n) begin
   if (!rst_n)    lcr_sp_l <= 0;
   else if (l_en) lcr_sp_l <= lcr_sp;
end

//Even Parity Select latch
always_ff @(posedge clk or negedge rst_n) begin
   if (!rst_n)    lcr_eps_l <= 0;
   else if (l_en) lcr_eps_l <= lcr_eps;
end

//Parity Enable latch
always_ff @(posedge clk or negedge rst_n) begin
   if (!rst_n)    lcr_pen_l <= 0;
   else if (l_en) lcr_pen_l <= lcr_pen;
end

//Stop Bit latch
always_ff @(posedge clk or negedge rst_n) begin
   if (!rst_n)    lcr_stop_l <= 0;
   else if (l_en) lcr_stop_l <= lcr_stop;
end

//Data Length Select latch
always_ff @(posedge clk or negedge rst_n) begin
   if (!rst_n)    lcr_dls_l <= '0;
   else if (l_en) lcr_dls_l <= lcr_dls;
end

endmodule: altr_uart_csrext
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "AKY/VDqroC56S5zYqI2FH+pDtMm2XXjvzWe8rGJiybS03yo4KNBMg81pmtWbHVIPiTA81zIuGQJqb5vOIzimr/z+D85S4Jjtk9u3+kDOlkJUsrbYjDeARoR1d2Gy20nZHckh8FGW+dSF0ir+jochMyts2Y//A4WlmCaB7gD83g5rkI4jT1ldDhtPnUUhGKawcEehCEezQ12Toa+YG3kf1PWegnVnp6lxL1nZ0P1Qzo+T3rMn3N/s4Yu9059eN5PTjapYwbsEKRAFCpRBqvftw/550cu2Jx/xloIDPbEkvhUChaX67i4aXuSvwY92czfs5Myz3UpMJtmnaULNZ9Z9jXJlgK59Q+EbwPg/G86ktaRZQhTYp34Nqtx36/PzYY2h+pd8s7CKVKlTDzzgo9nqAvtl3yRATBHNVZ5+YWOiwLiDLY/yZ4O3VyWvrWWzlDckmNJD4Jqosz6AAFJM0/ZjX9n6X4Dj+Qj2OgYsIy/JOFYy+IgGE67E9Ff/SsFhPC7+0Y68RA0HLiLIRVIL1HzTbOXtU8KA+Mx69QRO5myT+K8jkvvqpg/eaif7V6mUZiybheQx8+Ukg05RQcI9lj7FectnG8y9uhp8H5fNregheFAZ++mb7KVOuwoNNvmoq81Eow+F+94kC7F68eAtsSdRdDWJHxLyprot+0xoeR9yQn6hhozh3NkLiL+BBo6e0kwUtpFfco0K9MVF1vUIX9LqcJIYO+IyJqjFObylBXrsp9x3gVivYmVyOgdVhQRLk4eqmyttpUh8HuGMmB9Fkmei5Elszv9csC1ll5BQykP184dcPUoJvdQYZUYWQaPXnlW/SQeLeGvNaQMbXLd9Gv7Z/iQfNjmYsywObUlk6ISfgyc4Ff2hak0n5SIsMsfEhTOKN6MCt29pKYsptYB3cKDbMAdgk88qbkYlzYVMb13QLK7LGMIjr/ZaxVRf7aME7uSL2pX+5nl/5WQ1eaqfpciP6u6KQ2Ve1JuPLEyTTqYyTYTYE/TknqXkIJFpPwwFzqVD"
`endif
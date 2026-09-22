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
// This is the top level module for altera_16550_uart
// All sub-modules are instantiated at this level
//
`timescale 1 ps / 1 ps
module altera_16550_uart #(
   parameter FIFO_MODE = 1,
   parameter FIFO_DEPTH = 128,
   parameter FIFO_WATERMARK = 0,
   parameter FIFO_HWFC = 1,
   parameter FIFO_SWFC = 0,
   parameter FAMILY = "ARRIA V",
   parameter MEM_BLOCK_TYPE = "AUTO",
   parameter DMA_EXTRA = 1
) (
   //Clock and Reset
   input  clk,
   input  rst_n,

   //Avalon-MM Slave Interface
   input  [8:0]    addr,
   input           read,
   output [31:0]   readdata,
   input           write,
   input  [31:0]   writedata,

   //Interrupt Interface
   output intr,

   //RS-232 Serial Interface
   input  sin,
   output sout,
   output sout_oe,

   //Flow Control Interface
   input  cts_n,
   output rts_n,

   //Modem Control and Status
   input  dsr_n,
   input  dcd_n,
   input  ri_n,
   output dtr_n,
   output out1_n,
   output out2_n,

   //DMA Interface
   input  dma_tx_ack_n,
   input  dma_rx_ack_n,
   output dma_tx_req_n,
   output dma_rx_req_n,
   output dma_tx_single_n,
   output dma_rx_single_n

);

localparam ACTUAL_DSIZE =  9;
localparam EXPAND_DSIZE =  12;
localparam ASIZE = $clog2(FIFO_DEPTH);
localparam PARITY_ERROR = 11;
localparam FRAME_ERROR  = 10;
localparam BREAK        =  9;

//------------------------------------------------------------------------------
//Internal Signals
//------------------------------------------------------------------------------
logic glb_fifoe;
logic glb_fifoe_r;
logic glb_fifoe_c;
logic glb_hwfce;
logic glb_swfce;
logic glb_tx_low_en;

//------------------------------------------------------------------------------
//CSR Internal Signals
//------------------------------------------------------------------------------
logic rbr_thr_dll_read_access;
logic rbr_thr_dll_write_access;
logic [31:0] rbr_thr_dll_write_data;
logic ier_dlh_read_access;
logic ier_dlh_write_access;
logic [31:0] ier_dlh_write_data;
logic iir_was_read;
logic [1:0] fcr_rt;
logic [1:0] fcr_tet;
logic fcr_xfifor;
logic fcr_rfifor;
logic fcr_fifoe;
logic fcr_dmam;
logic lcr_dlab;
logic lcr_break;
logic lcr_sp;
logic lcr_eps;
logic lcr_pen;
logic lcr_stop;
logic [2:0] lcr_dls;
logic mcr_afce;
logic mcr_loopback;   //This MCR bit is not used anywhere - loopback not implemented
logic mcr_out2;
logic mcr_out1;
logic mcr_rts;
logic mcr_dtr;
logic lsr_read_access;
logic [31:0] lsr_read_data;
logic msr_ddcd;
logic msr_teri;
logic msr_ddsr;
logic msr_dcts;
logic afr_swfce;
logic afr_rx_high_en;
logic afr_rx_low_en;
logic afr_tx_low_en;
logic [8:0] tx_low_value;
logic [8:0] rx_low_value;
logic [8:0] rx_high_value;
logic [7:0] xon_char_value;
logic [7:0] xoff_char_value;
logic [7:0] esc_char_value;
logic [31:0] rbr_thr_dll_read_data;
logic [31:0] ier_dlh_read_data;
logic [1:0] iir_fifose;
logic [3:0] iir_id;
logic msr_dcd;
logic msr_ri;
logic msr_dsr;
logic msr_cts;
logic msr_ddcd_source;
logic msr_teri_source;
logic msr_ddsr_source;
logic msr_dcts_source;
logic csr_select;

//------------------------------------------------------------------------------
//CSREXT Internal Signals
//------------------------------------------------------------------------------
logic rbr_read_access;
logic [ACTUAL_DSIZE-1:0] rbr_read_data;
logic thr_write_access;
logic [ACTUAL_DSIZE-1:0] thr_write_data;
logic [7:0] dll;
logic dll_write_access;
logic [7:0] dll_write_data;
logic ier_erbfi;
logic ier_etbei;
logic ier_elsi;
logic ier_edssi;
logic [7:0] dlh;
logic dlh_write_access;
logic [7:0] dlh_write_data;
logic lcr_sp_l;
logic lcr_eps_l;
logic lcr_pen_l;
logic lcr_stop_l;
logic [2:0] lcr_dls_l;
logic lsr_bi;
logic lsr_fe;
logic lsr_pe;
logic lsr_oe;
logic lsr_rfe;
logic lsr_temt;   //This LSR bit is not used anywhere else except within CSREXT
logic lsr_thre;
logic intr_thre_source;
logic lsr_bi_source;
logic lsr_fe_source;
logic lsr_pe_source;
logic lsr_oe_source;
logic lsr_error_mask_clr;
logic lsr_dr;

//------------------------------------------------------------------------------
//Clock Generator
//------------------------------------------------------------------------------
logic baud_clken;

//------------------------------------------------------------------------------
//Interrupt Internal Signals
//------------------------------------------------------------------------------
logic iir_was_read_eq_thre;

//------------------------------------------------------------------------------
//RXFC Internal Signals
//------------------------------------------------------------------------------
logic [EXPAND_DSIZE-1:0] rxfc_data;
logic rxfc_put;
logic rxfc_xon;
logic rxin_rxfc_put;

//------------------------------------------------------------------------------
//RXIN Internal Signals
//------------------------------------------------------------------------------
logic [EXPAND_DSIZE-1:0] rx_data;
logic rxin_put;
logic rxfsm_idle;

//------------------------------------------------------------------------------
//TXSTOR Internal Signals
//------------------------------------------------------------------------------
logic txstor_get;
logic txstor_avail;
logic txfifo_full;
logic txfifo_empty;
logic thr_empty;
logic txfifo_rst;
logic [ASIZE:0] glb_tx_low_value;
logic [ASIZE:0] txfifo_navail;
logic [ACTUAL_DSIZE-1:0] txstor_data;

//------------------------------------------------------------------------------
//TXFC Internal Signals
//------------------------------------------------------------------------------
logic [ACTUAL_DSIZE-1:0] txfc_data;
logic txfc_xon_xoff;
logic rts;

//------------------------------------------------------------------------------
//TXOUT Internal Signals
//------------------------------------------------------------------------------
logic txout_avail;
logic [ACTUAL_DSIZE-1:0] tx_data;
logic txout_get;
logic txfsm_idle;

//------------------------------------------------------------------------------
//RXSYNC Internal Signals
//------------------------------------------------------------------------------
logic sin_i;
logic cts_i_n;
logic dsr_i_n;
logic dcd_i_n;
logic ri_i_n;
logic sout_pre;
logic sout_oe_pre;
logic sin_i_pre;

//------------------------------------------------------------------------------
//RXSTOR Internal Signals
//------------------------------------------------------------------------------
logic rxstor_put;
logic [EXPAND_DSIZE-1:0] rxstor_data;
logic rxstor_rxdata_avail;
logic rxstor_char_timeout;
logic rxfifo_high_watermark;
logic rxfifo_low_watermark;
logic rxfifo_empty;
logic rb_empty;
logic rxfifo_rst;

//------------------------------------------------------------------------------
//Global Enable signals (FIFO, HWFC, SWFC)
//Set all "Mode" Enable at the top and pass down into lower blocks
//Both HWFC and SWFC needs to take FIFO into account
//------------------------------------------------------------------------------
assign glb_fifoe = fcr_fifoe & (FIFO_MODE == 1);
assign glb_hwfce = glb_fifoe & mcr_afce  & (FIFO_HWFC == 1);
assign glb_swfce = glb_fifoe & afr_swfce & (FIFO_SWFC == 1);

//Combine CSR and Parameter Enable
assign glb_tx_low_en = afr_tx_low_en;

always_ff @(posedge clk or negedge rst_n) begin
   if (!rst_n) glb_fifoe_r <= 0;
   else        glb_fifoe_r <= glb_fifoe;
end

assign glb_fifoe_c = glb_fifoe ^ glb_fifoe_r;


//------------------------------------------------------------------------------
//CSRCompiler Generated CSR Block
//------------------------------------------------------------------------------

//CSR instantiation
altr_uart_csr csr (.*);

//csr_select was meant to be hooked up to a "chip-select" type input
//this is no longer required by Avalon - it is equivalent to read or write
assign csr_select = read | write; 

//------------------------------------------------------------------------------
//Hand-coded CSR Extension Block
//------------------------------------------------------------------------------
altr_uart_csrext #(
   .DSIZE(ACTUAL_DSIZE)
) csrext (.*);

//------------------------------------------------------------------------------
//Interrupt Block
//------------------------------------------------------------------------------
altr_uart_interrupt interrupt (.*);

//------------------------------------------------------------------------------
//Clock Generator
//------------------------------------------------------------------------------
altr_uart_clkgen clkgen (.*);

//------------------------------------------------------------------------------
//Modem Status and Control
//------------------------------------------------------------------------------
altr_uart_modem modem (.*);

//------------------------------------------------------------------------------
//TXSTOR 
//------------------------------------------------------------------------------
altr_uart_txstor #(
   .FIFO_MODE(FIFO_MODE),
   .FIFO_DEPTH(FIFO_DEPTH),
   .FIFO_WATERMARK(FIFO_WATERMARK),
   .DSIZE(ACTUAL_DSIZE),
   .ASIZE(ASIZE),
   .MEM_BLOCK_TYPE(MEM_BLOCK_TYPE),
   .FAMILY(FAMILY)
) txstor (.*);

//------------------------------------------------------------------------------
//TXFC
//------------------------------------------------------------------------------
altr_uart_txfc #(
   .DSIZE(ACTUAL_DSIZE)
) txfc (.*);

//------------------------------------------------------------------------------
//TXOUT
//------------------------------------------------------------------------------
altr_uart_txout #(
   .DSIZE(ACTUAL_DSIZE)
) txout (.*);

//Hook up data from TXSTOR & TXFC to TXOUT
assign tx_data = txfc_xon_xoff ? txfc_data : txstor_data;

//Hook up avail from TXSTOR & TXFC to TXOUT
assign txout_avail = txfc_xon_xoff ? 1'b1 : txstor_avail;
	  
//Hook up to txstor_get
assign txstor_get = txout_get & ~txfc_xon_xoff;

//------------------------------------------------------------------------------
//RXSYNC
//------------------------------------------------------------------------------
altr_uart_rx_sync rx_sync (.*);

//------------------------------------------------------------------------------
//RXSTOR
//------------------------------------------------------------------------------
altr_uart_rxstor #(
   .FIFO_MODE(FIFO_MODE),
   .FIFO_DEPTH(FIFO_DEPTH),
   .FIFO_WATERMARK(FIFO_WATERMARK),
   .ACTUAL_DSIZE(ACTUAL_DSIZE),
   .EXPAND_DSIZE(EXPAND_DSIZE),
   .ASIZE(ASIZE),
   .PARITY_ERROR(PARITY_ERROR),
   .FRAME_ERROR(FRAME_ERROR),
   .BREAK(BREAK),
   .MEM_BLOCK_TYPE(MEM_BLOCK_TYPE),
   .FAMILY(FAMILY)
) rxstor (.*);

//Hook up data from RXIN/RXFC to RXSTOR
assign rxstor_data = glb_swfce ? rxfc_data : rx_data;

//When SW Flow Control is enabled  - rxin_put signal is routed to RXFC
assign rxin_rxfc_put =   glb_swfce & rxin_put;

//When SW Flow Control is disabled - rxin_put signal is routed to RXSTOR
//A mux was not implemented between rxin_put and rxfc_put. Currently, when glb_swfce
//is low - rxfc_put can actually assert. There's a good reason for this:
//  1. rxfc_put should only assert when glb_swfce is high (normal case)
//  2. there is a possibility that glb_swfce is cleared while RXSWFC FSM is not
//     in IDLE. What happens here depends on what character was received.
//  3. If the character is one of ESC/XON/XOFF - various flags associated with them
//     may still trigger. Character will not be sent to RXSTOR
//  4. If the character is not ESC/XON/XOFF - it should be sent to RXSTOR. Not using
//     a mux here helps whatever character was received by RXSWFC to be sent to RSTOR.
assign rxstor_put    = (~glb_swfce & rxin_put) | rxfc_put;

//------------------------------------------------------------------------------
//RXFC
//------------------------------------------------------------------------------
altr_uart_rxfc #(
   .DSIZE(EXPAND_DSIZE),
   .PARITY_ERROR(PARITY_ERROR),
   .FRAME_ERROR(FRAME_ERROR),
   .BREAK(BREAK)
) rxfc (.*);

//------------------------------------------------------------------------------
//RXIN
//------------------------------------------------------------------------------
altr_uart_rxin #(
   .ACTUAL_DSIZE(ACTUAL_DSIZE),
   .EXPAND_DSIZE(EXPAND_DSIZE)
) rxin (.*);


//------------------------------------------------------------------------------
//DMAINTF
//------------------------------------------------------------------------------
altr_uart_dmaintf #(
   .DMA_EXTRA(DMA_EXTRA),
   .ASIZE(ASIZE)
) dmaintf (.*);


endmodule: altera_16550_uart
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "AKY/VDqroC56S5zYqI2FH+pDtMm2XXjvzWe8rGJiybS03yo4KNBMg81pmtWbHVIPiTA81zIuGQJqb5vOIzimr/z+D85S4Jjtk9u3+kDOlkJUsrbYjDeARoR1d2Gy20nZHckh8FGW+dSF0ir+jochMyts2Y//A4WlmCaB7gD83g5rkI4jT1ldDhtPnUUhGKawcEehCEezQ12Toa+YG3kf1PWegnVnp6lxL1nZ0P1Qzo/IdgPqe5WPs+Hufia2+SpV6Mco5S0epXaFHX6prv/wojwBo0ZH/TWhnoSEXmhYp1HQa3IHOhFcyqwVuWeb7RFZhAL+CECr5ufIx/om29hcwdPab8pEzYMVTBH0ZPvC/0nexouXwDzcuMVLIbmqaadL6HBViP8ddNcn6ta+rFxA0j7mI7C9g7vs/7OAtP/Wx6liQ1SarFHJ49A8ZyXANJv2CLOI6oBzqu7H6D+6pDK435BDjgNiMS0xAAcCJObbLK9Tqjlwm7umOS3kny+8mMx9kPuDsuLa+g7GWoFTdZhswGjyeK581Rr1cPHZaX/h+3xZDG5ajypQjOVov6FQCJBD0RtfPa6Kyiai9SzdvhMGsezaPdBDAGE86VMSfjjmeVNRz/uQEhsVgzoM2hm1KUzfUOBHcpiPcn7casU11TVhOgF+YMDDxFT2/1qY90UKXNHz+4DAOwjqV1gXvSJbpf64G4y80YENJAH+75l97p74h7HXeDtYE5yRMUZRRxUWhyqa7NunkkeXwcOET0xQVE11d6eIGuydH2WhfpvdUE/hG5DhP8/V5UTzAuCtThs9cbm71p4KNSxYROPbuNBo9mhPOH/kZ+SpdwTH5VHqtXb8DJgzPFcAErlYMpuv3m9fNL7fcgHzuL4vNj3nLJSNHOrjgGGD4kiVdPrsM1DiKunYdbBF83062TtHzlagVDdrMFt/8/XlrqazyNj0oY975hb3BTQBzq8yk9XSDmpcHpKEwRUxzIHqYQCxHzLnuScrQRFlsRhhhE1qrUYY8OycG3xY"
`endif
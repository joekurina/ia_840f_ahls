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
//TXSTOR
//Contains both the FIFO and non-FIFO storage elements
//
`timescale 1 ps / 1 ps
module altr_uart_txstor #(
   parameter FIFO_MODE = 1,
   parameter FIFO_DEPTH = 32,
   parameter FIFO_WATERMARK = 0,
   parameter DSIZE = 8,
   parameter ASIZE = 4,
   parameter MEM_BLOCK_TYPE = "AUTO",
   parameter FAMILY = "ARRIA V"
) (
   //Clock and Reset
   input  clk,
   input  rst_n,

   //RBR_THR_DLL CSR Interface
   input  thr_write_access,
   input  [DSIZE-1:0] thr_write_data,

   //Global FIFO Enable
   input  glb_fifoe,
   input  fcr_xfifor,
   input  glb_fifoe_c,

   //TXSTOR Control Interface
   input  txstor_get,
   output txstor_avail,
   output [ASIZE:0] txfifo_navail,
   output txfifo_full,
   output txfifo_empty,
   output thr_empty,
   output txfifo_rst,
    
   //TXSTOR Read Data output
   output [DSIZE-1:0] txstor_data,

   //Interrupt Logic (All used for THRE Interrupt)
   input  iir_was_read_eq_thre,     //IIR read for THRE Interrupt
   input  ier_etbei,
   output logic lsr_thre,           //LSR[5] Output
   output logic intr_thre_source,   //THRE Interrupt output
   input  [1:0] fcr_tet,            //Transmit Empty Trigger Level
   input  glb_tx_low_en,            //Transmit FIFO Low Watermark Enable Register
   input  [8:0] tx_low_value,        //Transmit FIFO Low Watermark Register

   //TXSTOR low value
   output [ASIZE:0] glb_tx_low_value

);

logic txfifo_put, thr_put;
logic txfifo_get, thr_get;
logic [DSIZE-1:0] txfifo_rdata, thr_rdata;

//FIFO reset should be triggered only when FIFOs are enabled
assign txfifo_rst = (glb_fifoe & fcr_xfifor) | glb_fifoe_c;

//TXFIFO
generate 
if (FIFO_MODE == 1) begin: gen_txfifo
   altr_uart_fifo #(
      .DSIZE(DSIZE),
      .ASIZE(ASIZE),
	  .FIFO_DEPTH(FIFO_DEPTH),
	  .MEM_BLOCK_TYPE(MEM_BLOCK_TYPE),
      .FAMILY(FAMILY)
   ) txfifo (
      .put(txfifo_put),
      .get(txfifo_get),
      .s_rst(txfifo_rst),
      .full(txfifo_full),
      .empty(txfifo_empty),
      .navail(txfifo_navail),
      .wdata(thr_write_data),
      .rdata(txfifo_rdata),
      .*
   );
end
endgenerate

//THR
altr_uart_databuffer #(
   .DSIZE(DSIZE)
) thr (
   .s_rst(glb_fifoe_c),
   .put(thr_put),
   .get(thr_get),
   .empty(thr_empty),
   .wdata(thr_write_data),
   .rdata(thr_rdata),
   .*
);

//PUT Input Mux
assign txfifo_put = thr_write_access &  glb_fifoe & ~txfifo_full;
assign thr_put    = thr_write_access & ~glb_fifoe;

//GET Input Mux
assign txfifo_get = txstor_get &  glb_fifoe;
assign thr_get    = txstor_get & ~glb_fifoe;

//AVAIL Output Mux
assign txstor_avail = glb_fifoe ? ~txfifo_empty : ~thr_empty;

//DATA output Mux
assign txstor_data = glb_fifoe ? txfifo_rdata : thr_rdata;

//------------------------------------------------------------------------------
// THRE Interrupt
//------------------------------------------------------------------------------

//Global TX Low Watermark Enable
logic [ASIZE:0] tet_value;

//Calculate watermark value set by FCR[5:4] TET
always_comb begin
   case(fcr_tet)
      2'b00: tet_value = 'd0;
      2'b01: tet_value = 'd2;
      2'b10: tet_value = FIFO_DEPTH/4;
      2'b11: tet_value = FIFO_DEPTH/2;
   endcase
end

//Tx FIFO Low value
assign glb_tx_low_value = tx_low_value[ASIZE:0];

//LSR THRE and INTR THRE logic
logic txstor_empty;
logic intr_thre_mask, intr_thre_mask_nxt;

//txstor_empty is the direct source for both LSR THRE and INTR THRE
assign txstor_empty = glb_fifoe ? txfifo_empty : thr_empty;

//THRE Bit - LSR[5] logic
assign lsr_thre = txstor_empty;

//THRE Interrupt Masking logic
always_ff @(posedge clk or negedge rst_n) begin
   if (!rst_n) intr_thre_mask <= 0;
   else        intr_thre_mask <= intr_thre_mask_nxt;
end

assign intr_thre_mask_nxt = ( ~(glb_tx_low_en & glb_fifoe) & iir_was_read_eq_thre )  ? 1'b1 : 
                            ( txstor_avail | ~ier_etbei )   ? 1'b0 : intr_thre_mask;

//THRE Interrupt Logic
//assign intr_thre_source = txstor_empty & ~intr_thre_mask;

assign intr_thre_source = (glb_tx_low_en & glb_fifoe) ? (txfifo_navail <= glb_tx_low_value) : (txstor_empty & ~intr_thre_mask);

endmodule: altr_uart_txstor
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "AKY/VDqroC56S5zYqI2FH+pDtMm2XXjvzWe8rGJiybS03yo4KNBMg81pmtWbHVIPiTA81zIuGQJqb5vOIzimr/z+D85S4Jjtk9u3+kDOlkJUsrbYjDeARoR1d2Gy20nZHckh8FGW+dSF0ir+jochMyts2Y//A4WlmCaB7gD83g5rkI4jT1ldDhtPnUUhGKawcEehCEezQ12Toa+YG3kf1PWegnVnp6lxL1nZ0P1Qzo/ekUsd99OBaXwUYA6URQnB18WX/1YRAa50Rl+x8l1RnooDvbcpxdoyz6nBIWKkyE06SdmmHpPmj2SiOLLvraciBtdoj3uq201z2Acsk84aGspGPEsnWOKbarYHDe2ddYW+KCYOy7CrOgdp6yTE/dYwWc8Erio27nB275/wJ1IChdgEgaM6EvRzHsTWO18gj3yxY35dt2vsOj6AFZdXlS9EOJPS2fkiO4RtxwaXEb7b5E5vIJHQV3RHYm6EILb1pujD844MRLeTdk+sgQLUN7FpHk14syP8IZiHexouZ5DMEnYpRsVMtGfFaiqh87391UXGBU7ftgItPbbzx1CpkgzAyUAdcFGFZqkGIowJLVYcKKW6K2e/GPTcbSWQ+lFX4oqaCQYoAu/og8jP6Rdu2kB+TK0yS/17cxVgxBODzj0H8PA5MxRBQj3yGgcVChHErnnVoU40KTq3yb44XHf5D0gnP+vls7Lk+bbHE/MFNsuMbQx2T6zUqskbZkxbolLxbYPlMX8ulI6LcH5zWrTNpgF/BjrgthBl3ivHW/ACFV2lICV44l4gjV78/JognfyVJmx+3dkzH5G7wVN4qJ4jEasqRzRbIJ/9tNmrn1RkFmG3B/8wMbRWKlWJxtT/JWGr2Nv9TO1tDFWDMZCABuu1zeB5/iCzsm+nS4K3VfbqiIunwMSQ00FFowUKV43Uq75olkTWrZdQ5XJQNdxHqcd8X4RK8FIQf/choyo2duOIuawOy2d9v6DkKdYJKJkqlHDXR0HMimUPchpLGtBfITrvlJ3M"
`endif
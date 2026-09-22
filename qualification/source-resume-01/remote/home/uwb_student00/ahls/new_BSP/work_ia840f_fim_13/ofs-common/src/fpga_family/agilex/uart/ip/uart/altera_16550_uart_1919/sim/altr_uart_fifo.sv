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
// Synchronous FIFO with 1 read port and 1 write port
// Parameterizable WIDTH and DEPTH
//
`timescale 1 ps / 1 ps
module altr_uart_fifo #(
   parameter DSIZE = 8,
   parameter ASIZE = 4,
   parameter FIFO_DEPTH = 128,
   parameter MEM_BLOCK_TYPE = "AUTO",
   parameter FAMILY = "ARRIA V"
) (
   input  clk,
   input  rst_n,
   input  put,
   input  get,
   input  s_rst,
   output full,
   output empty,
   output [ASIZE:0] navail,

   input  [DSIZE-1:0] wdata,
   output [DSIZE-1:0] rdata
);

logic internal_empty, empty_reg;
logic [ASIZE:0]   putptr, getptr;

// FIFO POINTER Logic
always_ff @(posedge clk or negedge rst_n) begin
   if (!rst_n) begin
      putptr   <= '0;
      getptr   <= '0;
   end
   else if (s_rst) begin
      putptr   <= '0;
      getptr   <= '0;
   end 
   else begin
      putptr   <= put ? putptr + {{(ASIZE){1'b0}}, 1'b1} : putptr;
      getptr   <= get ? getptr + {{(ASIZE){1'b0}}, 1'b1} : getptr;
   end
end

always_ff @(posedge clk or negedge rst_n) begin
   if (!rst_n) begin
	   empty_reg  <= 0;
   end
   else begin 		  
	   empty_reg  <= internal_empty;
   end
end

//FULL Indication
assign full = (putptr[ASIZE] != getptr[ASIZE]) & (putptr[ASIZE-1:0] == getptr[ASIZE-1:0]);

//EMPTY Indication
assign internal_empty = (putptr == getptr);
assign empty = internal_empty || empty_reg;

//NAVAIL Indication
assign navail = putptr - getptr;

//FIFO Storage
altr_uart_fifomem #(
   .DSIZE(DSIZE),
   .ASIZE(ASIZE),
   .FIFO_DEPTH(FIFO_DEPTH),
   .MEM_BLOCK_TYPE(MEM_BLOCK_TYPE),
   .FAMILY(FAMILY)
) i_fifomem (
   .raddr(getptr[ASIZE-1:0]),
   .waddr(putptr[ASIZE-1:0]),
   .*
);
  
endmodule: altr_uart_fifo
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "AKY/VDqroC56S5zYqI2FH+pDtMm2XXjvzWe8rGJiybS03yo4KNBMg81pmtWbHVIPiTA81zIuGQJqb5vOIzimr/z+D85S4Jjtk9u3+kDOlkJUsrbYjDeARoR1d2Gy20nZHckh8FGW+dSF0ir+jochMyts2Y//A4WlmCaB7gD83g5rkI4jT1ldDhtPnUUhGKawcEehCEezQ12Toa+YG3kf1PWegnVnp6lxL1nZ0P1Qzo/exjsxvB9cdjlqz7szJFFG4DsNyo3gRO1eJ75THF9emAnRNtuDY2/q32sUm0ljVK0beylAWIXBgKlshCnF5+YfpgrZPP5LJPEASRoUppqqjpO5Tdg/HEIvazczvxJua9OyJ5lhkY/UJQCjYEGq9rlbNWBn09dMsEgWmOio7qbTyCDrECHij8fehmkrK2aXDZj7mI3qC/XpO5t1//LB6//15SPR1FtoUMYGA+RBgTcX/zPaflMBvteJstC8tj+XX6tD6ts/xdCg2hc7NLLm32O0RTyZ3iHszLxEEcbYDoOW6ECiA6rJTapf3jWaxJaTAxTYOAo7873lsVOhZJn1nynuKuufsNu8isXjx7xkkrOAjaQAY9C5iH/i3tkKlk3jxcxDVok3Gz03GP6DKWntriPQLJ1oeo6TMS6ch5mR4VqflauGQty5mDSVI8wMOVLAVly5+rls0httFwdk7nRKnAZJ2hjALRoaEnwDMo1gTLv7peT5thrmVq3IAMJ9d2wjCJZdncOED3LZtQ05rIcQg7B0BZ71tbiZCanK7tu0EEB6nlIlxfCM4Aalc9EJtIm//hQxn+wtxvFBYw5/E+qDLbIjeQClFJjLNlQjZjdlef6tScZCMBlIR23RkuZoz50vFLuC/nqab23pe7/s9g+hXhgzWWnUcxPOUKLq/lMnYEURuys7zsVGuZCb/2zrXKxXn36CXwIueMu6/yMeqyrv/1Ix0q+v5Cgt85RCKHjLeatS6/N3LSs2l1olKqcutBSZnkmFce/wQonQvRF9Nokj9gKP"
`endif
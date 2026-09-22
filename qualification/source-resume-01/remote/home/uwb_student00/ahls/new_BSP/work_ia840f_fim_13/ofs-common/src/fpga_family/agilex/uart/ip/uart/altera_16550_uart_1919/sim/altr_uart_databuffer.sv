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
// Parameterizable width data buffer
// Meant to be used for THR & RB
// Conceptually a 1-deep FIFO
//
`timescale 1 ps / 1 ps
module altr_uart_databuffer #(
   parameter DSIZE = 8
) (
   input  clk,
   input  rst_n,
   input  s_rst,  //Sync Reset - when Mode is disabled
   input  put,
   input  get,
   output logic empty,
   input  [DSIZE-1:0] wdata,
   output logic [DSIZE-1:0] rdata
);

//BUFFER storage
always_ff @(posedge clk) begin
  if (put) rdata <= wdata; 
end

//EMPTY Indicator
always_ff @(posedge clk or negedge rst_n) begin
   if (!rst_n)
      empty <= 1;
   else begin
      empty <= s_rst ? 1 :
               put   ? 0 :
               get   ? 1 :
               empty;
   end
   
end

endmodule: altr_uart_databuffer
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "AKY/VDqroC56S5zYqI2FH+pDtMm2XXjvzWe8rGJiybS03yo4KNBMg81pmtWbHVIPiTA81zIuGQJqb5vOIzimr/z+D85S4Jjtk9u3+kDOlkJUsrbYjDeARoR1d2Gy20nZHckh8FGW+dSF0ir+jochMyts2Y//A4WlmCaB7gD83g5rkI4jT1ldDhtPnUUhGKawcEehCEezQ12Toa+YG3kf1PWegnVnp6lxL1nZ0P1Qzo/5zBUWXoG1Ilz7BZmWiIKML/DxB1+UbtP2xownMZl5SW9cNAZxgVFGjl6duQWm9HchE5U8zYSkt29QsfX0dblA5RIJP0AuHHefgomy6tOK9x/o0QYyCL6rUZQ9k9sHMM+26uW1iQbFnzGNO3fV4yx91fH3GZoi68t2F0wJe0FPFbcGvQ3TYq32pWFJklZcZN08meDg778uGOWSm1rHhMJt2rXasRSGdxJ5yEyChFm4Mqu/Jc2SMZFgTE9nM7m6Hw/OXdmGZ5L7bnFiZ+Ybx34EmfF0s3QoupOfdRHAj7WDa8OPKoWRpA+7w5C7kG/sVPFs+1Ts7s1FbgchoxOurVhWdCWpfdCq+C9ag3cPOnmoL3p3yyfDGqiSyAfICbohMpPhKu4xzxfOOtxiKRkDAftuyZaHmiB0RK0l2XerBBhaqxeiNg285ME1RgMihK3oC5MURbSnhUR8elARGuAXtkZUI6kmNndoZrS//+9RfBZLRVcWCcD6pnZvmzj3L6aS6lMCuTvpISOS9A55sTnuTVel+qtwR5CziZzUnh0/hWG4wG1OFrNkBW2E/4n44Mhbg/L5CTULZvIMBqWZUuuGxb0lKajQJJWlFOrlJqhZgw+viCd773Wr+ph2jWzttoyVwBWFEnc2BPfloMMaD+vNskJFpVlR8Hj86wW2cmltubtE4MS0DR1TKSxpNYgZr5wi/ZSiXxtMb+bGuBOb6JX9OiaTaeDpJrRFq13uVz1464JASYIPvQjPSKUj+lH9Tn57lZtlGZFP8X+bdepiYASnNHXL"
`endif
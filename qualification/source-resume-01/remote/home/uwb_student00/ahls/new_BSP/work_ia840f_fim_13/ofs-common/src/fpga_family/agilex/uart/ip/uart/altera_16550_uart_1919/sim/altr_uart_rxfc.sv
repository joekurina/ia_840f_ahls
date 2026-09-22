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
//Receive Flow Control Logic
//
`timescale 1 ps / 1 ps
module altr_uart_rxfc #(
   parameter DSIZE         = 11,
   parameter PARITY_ERROR  = 10,
   parameter FRAME_ERROR   = 9,
   parameter BREAK         = 8
) (
   //Clock and Reset
   input  clk,
   input  rst_n,

   //CSR Inputs
   input  [7:0] xon_char_value,
   input  [7:0] xoff_char_value,
   input  [7:0] esc_char_value,
   input  glb_hwfce,
   input  glb_swfce,

   //CTS_N input
   input  msr_cts,

   //Data Input from RXIN
   input  [DSIZE-1:0] rx_data,
   input  rxin_rxfc_put,

   //Data Output from RXFC
   output [DSIZE-1:0] rxfc_data,
   output rxfc_put,
   output logic rxfc_xon

);

//RXFC FSM enum
enum logic {
   XON  = 1'b0,
   XOFF = 1'b1 } state, next;

//RXCHAREVAL FSM state indicator
logic rxchar_setxon;
logic rxchar_setxoff;

//------------------------------------------------------------------------------
//RXFC FSM
//------------------------------------------------------------------------------
always_ff @(posedge clk or negedge rst_n) begin
   if (!rst_n) state <= XON;
   else        state <= next;
end

always_comb begin
   case (state)
      XON : if ( (rxchar_setxoff & glb_swfce) | (~msr_cts & glb_hwfce) ) next = XOFF;
            else                                                        next = XON;
      XOFF: if ( (rxchar_setxon & glb_swfce) | (msr_cts & glb_hwfce) | (~glb_swfce & ~glb_hwfce) ) next = XON;
            else                                                        next = XOFF;
   endcase
end

always_comb begin
   rxfc_xon = (state == XON);
end

//------------------------------------------------------------------------------
//RXSWFC Instantiation (along with RXCHAREVAL FSM)
//------------------------------------------------------------------------------
altr_uart_rxswfc #(
   .DSIZE(DSIZE),
   .PARITY_ERROR(PARITY_ERROR),
   .FRAME_ERROR(FRAME_ERROR),
   .BREAK(BREAK)
) rxswfc (.*);



endmodule: altr_uart_rxfc
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "AKY/VDqroC56S5zYqI2FH+pDtMm2XXjvzWe8rGJiybS03yo4KNBMg81pmtWbHVIPiTA81zIuGQJqb5vOIzimr/z+D85S4Jjtk9u3+kDOlkJUsrbYjDeARoR1d2Gy20nZHckh8FGW+dSF0ir+jochMyts2Y//A4WlmCaB7gD83g5rkI4jT1ldDhtPnUUhGKawcEehCEezQ12Toa+YG3kf1PWegnVnp6lxL1nZ0P1Qzo9+ZbaQd2AJSXEvV5LFEXP743aVszKRu4975mVDjRctD0bc2+jRfZojyBOKI+11nJuoaWcOSbqV27bdh3oiQdJaMktQPnb8BR1gat98DedhGPjtwc0pkn9ecPz6EaVIBPcRJseIcizr6yi+RbUkNpTT8HPCMEiMlt+5eU0j+rm6L7zgxIHzPqez0Ghg5/48kfmoR6zjCNsD1E/NYrWia+NdLKdes8gSeWxWu254oUi1Q0FkQB/cu6znfK9TWwMLgSGZzLkj+30Y9k1XWHeZe9pFp3UzYY04Uv+6bhery4vrwL2T561aTLMKF2hHorY/Z9KA3XzjMGfvZg/Gm9kdT28K5uvG3HNkylWHRD6Z0a4XchruN7jcyfP9u6voPlSWVwYReuD/Csv0i1P5akY1dGWVuvzKJKATZ2Ljdux6GY7RMm3R0OMrUaJS9IDI+bSytOH6HGWJVu/nhrPk3aHbkSYDMfRkbz5qtAvdrNM33AcD3x7H20PNr0Ur5dJnxbttPzlO2kFCCGRld0RN+r0ntpOeJWVtfiTFIz0THq7H7pITHKFywIGmDZuCh++6Ir6hMhTDY+nkDEfjKvOvh76EpR834rmuwZcbKZjTW0Np2O8Yg2jSKJRqqU876YJqPKSu3R7EqyXuYgf5R4zKvSBg0jFpqNNIeTpy8UmjgfsoJg3vTCrMEYaSZAMEQn1EuMzItTTMUBWLDUjoVLlTPDQ8raFQ9J2fcLcVmJexcfwaW9Bj2Dy32ijMkzt3F4F2URBT/qX8TqO7H+NvLtz3w5Ynngkk"
`endif
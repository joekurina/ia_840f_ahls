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
//TX Flow Control Logic
//Both Hardware and Software is handled here
//
`timescale 1 ps / 1 ps
module altr_uart_txfc #(
    parameter DSIZE = 8
) (
   //Clock and Reset
   input  clk,
   input  rst_n,

   //CSR Inputs
   input  [7:0] xon_char_value,
   input  [7:0] xoff_char_value,
   input  [7:0] esc_char_value,
   input  mcr_rts,
   input  glb_hwfce,
   input  glb_swfce,

   //For ESC detection
   input  [DSIZE-1:0] txstor_data,
   input  txout_get,

   //RX FIFO High/Low Watermark indications to TXFC
   input  rxfifo_high_watermark,
   input  rxfifo_low_watermark,

   //TXFC Data Outputs
   output logic [DSIZE-1:0] txfc_data,

   output logic txfc_xon_xoff,

   output rts
);

//------------------------------------------------------------------------------
//Flow Control Triggers from RXFIFO
//------------------------------------------------------------------------------

logic rxfifo_high_watermark_r;
logic rxfifo_low_watermark_r;
logic rxfifo_high_watermark_rise;
logic rxfifo_low_watermark_rise;

logic data_eq_esc;
logic escape_active;

//RXFIFO High Watermark Rise
always_ff @(posedge clk or negedge rst_n) begin
   if (!rst_n) rxfifo_high_watermark_r <= 0;
   else        rxfifo_high_watermark_r <= rxfifo_high_watermark;
end

assign rxfifo_high_watermark_rise = rxfifo_high_watermark & ~rxfifo_high_watermark_r;

//RXFIFO Low Watermark Rise
always_ff @(posedge clk or negedge rst_n) begin
   if (!rst_n) rxfifo_low_watermark_r <= 0;
   else        rxfifo_low_watermark_r <= rxfifo_low_watermark;
end

assign rxfifo_low_watermark_rise = rxfifo_low_watermark & ~rxfifo_low_watermark_r;

//------------------------------------------------------------------------------
//ESC character detection
//------------------------------------------------------------------------------
enum logic {
   NOESC  = 1'b0,
   ESC    = 1'b1  } esc_state, esc_next;

//Present state registers
always_ff @(posedge clk or negedge rst_n) begin
   if (!rst_n) esc_state <= NOESC;
   else        esc_state <= esc_next;
end

//Next state combi
always_comb begin
   case(esc_state)
      NOESC :  if (glb_swfce & txout_get & data_eq_esc)  esc_next = ESC;
               else                                      esc_next = NOESC;
      ESC   :  if (~glb_swfce | txout_get)               esc_next = NOESC;
               else                                      esc_next = ESC;
   endcase
end

assign data_eq_esc = (txstor_data == {1'b0, esc_char_value});
assign escape_active = (esc_state == ESC);

//------------------------------------------------------------------------------
//SW Flow Control
//------------------------------------------------------------------------------
enum logic [1:0] {
   IDLE     = 2'b00,
   SENDXOFF = 2'b01,
   SENDXON  = 2'b10,
   XX       = 'x  } sw_state, sw_next;

//Present state registers
always_ff @(posedge clk or negedge rst_n) begin
   if (!rst_n) sw_state <= IDLE;
   else        sw_state <= sw_next;
end

//Next state combi
always_comb begin
   case(sw_state)
      IDLE     :  if (glb_swfce & rxfifo_high_watermark_rise)
                     sw_next = SENDXOFF;
                  else if (glb_swfce & rxfifo_low_watermark_rise) 
                     sw_next = SENDXON;
                  else
                     sw_next = IDLE;
      SENDXOFF :  if (~glb_swfce | (txout_get & ~escape_active) | ~rxfifo_high_watermark)
                     sw_next = IDLE;
                  else
                     sw_next = SENDXOFF;
      SENDXON  :  if (~glb_swfce | (txout_get & ~escape_active) | ~rxfifo_low_watermark)
                     sw_next = IDLE;
                  else
                     sw_next = SENDXON;
      default  :  sw_next = XX;
   endcase
end

//XON & XOFF state indication
//Additional qualifier added for esc detection
always_comb begin
   txfc_xon_xoff = ~escape_active & ((sw_state == SENDXON) | (sw_state == SENDXOFF));
end

//TXFC Data Output
always_comb begin
   case (sw_state)
      IDLE     : txfc_data = '0;
      SENDXOFF : txfc_data = {1'b0, xoff_char_value};
      SENDXON  : txfc_data = {1'b0, xon_char_value};
      default  : txfc_data = 'x;
   endcase
end

//------------------------------------------------------------------------------
//HW Flow Control
//------------------------------------------------------------------------------

//Simple 2 state FSM to set RTS value for HWFC
enum logic {
   XON  = 1'b0,
   XOFF = 1'b1  } hw_state, hw_next;

always_ff @(posedge clk or negedge rst_n) begin
   if (!rst_n) hw_state <= XON;
   else        hw_state <= hw_next;
end

always_comb begin
   case (hw_state)
      XON:  if (glb_hwfce & rxfifo_high_watermark)  hw_next = XOFF;
            else                                         hw_next = XON;
      XOFF: if (~glb_hwfce | rxfifo_low_watermark)  hw_next = XON;
            else                                         hw_next = XOFF;
   endcase
end

assign rts = (hw_state == XON) & mcr_rts;

endmodule: altr_uart_txfc
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "AKY/VDqroC56S5zYqI2FH+pDtMm2XXjvzWe8rGJiybS03yo4KNBMg81pmtWbHVIPiTA81zIuGQJqb5vOIzimr/z+D85S4Jjtk9u3+kDOlkJUsrbYjDeARoR1d2Gy20nZHckh8FGW+dSF0ir+jochMyts2Y//A4WlmCaB7gD83g5rkI4jT1ldDhtPnUUhGKawcEehCEezQ12Toa+YG3kf1PWegnVnp6lxL1nZ0P1Qzo/bGijBftNlNcSr73l4EiNoI+73pzhAsZGjjIxpCYiBE4Gb2noycrmT+66gm1k2HsirKjVsT7IUpMwrXgSaC1rWs3LoQR4mACEdMKFJQI8u9kHeWsUTuppXY1aBSUD9Vs0PR6lgX2541Anz5Hb/BNKHB+qItOQ/6O0/ZAqAZ1mjS9fznbKqhcCJpIa7RW0k7oRDJDExeXMAYDcSTugjB2aogr4tUnLwgjRI1gR+h/F9D+Z27UpBwDKuieKyJ0ncIglghybEg3cdmIggYoPLUbKm290Ydn2xGsWXUsg/hiGjFMas/zieB7tVTfIpSJjBOOm2t0sdkYz0QIKMuf/wIdBkRZLfRBMddxMqczJL06OzkE0siX5Ax1HQDGbP9g4cd2N3cxdVXMfNq2aHZLA0EPHP9FpFusx7iTzW/GmhsNyu3ey7stVhXnOQU1OUKsMS5MwWepHsdVi5X5ej0gPt3lgLu5gGfF4pB86EBYwOgqSRptIFYHWM2NgKqN99LumfcQDCBqX1TWVtKEkcS4HaSe6nbu905gp4a950wfV7uIF6aumRQZJQ1KSiSkKHrwtnSQSJ3diqV9q1Qngycdwdfa5T8zhCE3sMdJU3LoczBeq6zISdCLqmlJYYdy7dnC31ifEUDgnzeirCTZ0Ce6PngsAXnExgZL2H2eyKTTXTleClu1e3RErpfIvRqg+18YSNJ9brM7Jt0FG5i0amk9Htiqp8SxzagPRxJEe2HWYcCBUh8YE79OcQROHthYoQwLRHKhjJSZWYSeBC5s3LjCyjOnBK"
`endif
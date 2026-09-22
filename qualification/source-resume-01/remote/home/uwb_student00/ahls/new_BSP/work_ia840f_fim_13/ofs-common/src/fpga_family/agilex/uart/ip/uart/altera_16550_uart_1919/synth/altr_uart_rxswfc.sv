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
//Software Flow Control
//Component of RXFC
//
`timescale 1 ps / 1 ps
module altr_uart_rxswfc #(
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
   input  glb_swfce,

   //Data Input from RXIN
   input  [DSIZE-1:0] rx_data,
   input  rxin_rxfc_put,

   //FSM state indicator
   output logic rxchar_setxon,
   output logic rxchar_setxoff,
   output logic rxfc_put,

   //Data Output from RXFC
   output [DSIZE-1:0] rxfc_data
);

localparam DATA_BIT = (DSIZE == 12) ? 9 : 8;

logic rxin_error;
logic esc_active;

enum logic [2:0] {
   IDLE     = 3'b000,
   CHECKESC = 3'b001,
   SEND     = 3'b010,
   EVAL     = 3'b011,
   SETESC   = 3'b100,
   SETXON   = 3'b101,
   SETXOFF  = 3'b110,
   XX       = 'x  } state, next;

//I name this RXCHAREVAL FSM
//Present State Registers
always_ff @(posedge clk or negedge rst_n) begin
   if (!rst_n) state <= IDLE;
   else        state <= next;
end

//Next State combi
always_comb begin
   case (state)
      IDLE     :  if (rxin_rxfc_put)
                     next = CHECKESC;
                  else
                     next = IDLE;

      CHECKESC :  if (esc_active | rxin_error)
                     next = SEND;
                  else if (~esc_active & ~rxin_error)
                     next = EVAL;
                  else
                     next = CHECKESC;

      SEND     :  next = IDLE;

      EVAL     :  if (rxfc_data[DATA_BIT-1:0] == {1'b0, esc_char_value})
                     next = SETESC;
                  else if (rxfc_data[DATA_BIT-1:0] == {1'b0, xon_char_value})
                     next = SETXON;
                  else if (rxfc_data[DATA_BIT-1:0] == {1'b0, xoff_char_value})
                     next = SETXOFF;
                  else
                     next = SEND;

      SETESC   :  next = IDLE;
      SETXON   :  next = IDLE;
      SETXOFF  :  next = IDLE;
      default  :  next = XX;
   endcase
end

//State Outputs
always_comb begin
   rxchar_setxon  = (state == SETXON);
   rxchar_setxoff = (state == SETXOFF);
   rxfc_put       = (state == SEND);
end

//------------------------------------------------------------------------------
//Indicator that there's error in the received data
//------------------------------------------------------------------------------
assign rxin_error = rxfc_data[PARITY_ERROR] | rxfc_data[FRAME_ERROR] | rxfc_data[BREAK];

//------------------------------------------------------------------------------
//ESC_ACTIVE flag
//------------------------------------------------------------------------------
always_ff @(posedge clk or negedge rst_n) begin
   if (!rst_n) 
      esc_active <= 0;
   else 
      if ((state == SETESC) & glb_swfce)
         esc_active <= 1;
      else if ((state == SEND) | ~glb_swfce)
         esc_active <= 0;
      else
         esc_active <= esc_active;
end

//------------------------------------------------------------------------------
//Storage for data from rxin
//------------------------------------------------------------------------------
altr_uart_databuffer #(
   .DSIZE(DSIZE)
) rxfcb (
   .s_rst(1'b0),
   .put(rxin_rxfc_put),
   .get(1'b0),    // get is only used by the empty indicator - which is useless here
   .empty(),      // empty indicator is not required - RXSWFCFSM generates the put signal without empty
   .wdata(rx_data),
   .rdata(rxfc_data),
   .*
);


endmodule: altr_uart_rxswfc
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "AKY/VDqroC56S5zYqI2FH+pDtMm2XXjvzWe8rGJiybS03yo4KNBMg81pmtWbHVIPiTA81zIuGQJqb5vOIzimr/z+D85S4Jjtk9u3+kDOlkJUsrbYjDeARoR1d2Gy20nZHckh8FGW+dSF0ir+jochMyts2Y//A4WlmCaB7gD83g5rkI4jT1ldDhtPnUUhGKawcEehCEezQ12Toa+YG3kf1PWegnVnp6lxL1nZ0P1Qzo87IpNuHJRuiDEKUx939UVYnbwNeA13FTiMFG0Lvk04KtE78BwSN+uPchCQ14/rbFvjEAECY/g5Ad1xNKTi+zktMAl5vEzb7l06I9Yt209x7fwEro8szf5kWWIxYQd5ma8h0gNVFP9GeaU1TNNACj0nq3tUvvxV+8m0Hx4FSLV1GX5gOM3L4oO9BB0LnBUMtgFziY0NHhKgnhYUeXX5uaRU3Rr34I5S2vibV/vpoDCb7VrD4e946Dm2FOz1gwrZJ+Clbwu4Gq64Xe7YtOn1gmAF+/fwnl0bAJzWr7TlOJzRYURAkxIiUmX7q87hLVr+bk2DlthAIyueHfUiXLgSr98FHw+Pa1OUO5udecp2I8+U+DzIxHpSpJRsrEOXqXny+FMX1fzCIjiOVsmc9Es4qzrXrrj+ywXFuHtE1sQNdfap9u8XA61MeGyfKdfmKQHTIGRd10DVjJhJ1R2uTOBCcpZeJ2M1Hm5SGZAltQCTfLrEt2ZC5sIxD8FbI9B6c3b3RbGQifBVdOlVUr5P3KJV0MFmzxAc9ELu1cezUEnwoffahM9BnOKBsTtksGbI4jJeaPsht3F3ycWOY8IGa70BOpkvXyEEoa1byRXuKn7WEns5vqH7PyvbC/e01RAoAlxiVO30pHOkHNEe5b5UP0oVzwQVj137NVkKdpuZvZoKlrqce0R3VCAmaVcVjhbH3qzw7clg/8ZxCWEPH/YsY6OYu6HxN7iZFmPQdZ82NsaFxGtnD42SLd32BoDESP7ZE+0ECbYlS4Y2lg15nQ06bBtXwin6"
`endif
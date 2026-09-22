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
//Baud clock enable generator
//
`timescale 1 ps / 1 ps
module altr_uart_clkgen (
   //Clocks and Reset
   input  clk,
   input  rst_n,

   //DLH CSR Interface
   input  dlh_write_access,
   input  [7:0] dlh_write_data,
   output logic [7:0] dlh,

   //DLL CSR Interface
   input  dll_write_access,
   input  [7:0] dll_write_data,
   output logic [7:0] dll,

   //DLAB input
   input  lcr_dlab,

   //baud_clk enable output
   output logic baud_clken
);

logic [15:0] baud_cnt, baud_cnt_p1;
logic baud_clken_nxt;
logic reset;
logic full;

//DLH Register
always_ff @(posedge clk or negedge rst_n) begin
   if (!rst_n)                dlh <= '0;
   else if(dlh_write_access)  dlh <= dlh_write_data;
end

//DLL Register
always_ff @(posedge clk or negedge rst_n) begin
   if (!rst_n)                dll <= 0;
   else if(dll_write_access)  dll <= dll_write_data;
end

//------------------------------------------------------------------------------
//Clock Counter
//------------------------------------------------------------------------------

always_ff @(posedge clk or negedge rst_n) begin
   if (!rst_n) baud_cnt <= '0;
   else 
      if (reset)
         baud_cnt <= '0;
      else if (full)
         baud_cnt <= '0;
      else
         baud_cnt <= baud_cnt_p1;
end

assign baud_cnt_p1 = baud_cnt + 16'h1;

assign reset = lcr_dlab;
assign full  = (baud_cnt_p1 == {dlh, dll});

//------------------------------------------------------------------------------
//baud clock enable output
//------------------------------------------------------------------------------

always_comb begin
   case ({dlh, dll})
      16'b00:  baud_clken_nxt  = 0;
      16'b01:  baud_clken_nxt  = 1;
      16'b10:  baud_clken_nxt  = baud_cnt[0];
      default: baud_clken_nxt  = (baud_cnt == 16'h1);
   endcase
end

//stop baud_clken once DLAB bit is set
always_ff @(posedge clk or negedge rst_n) begin
   if (!rst_n) baud_clken <= 0;
   else        baud_clken <= baud_clken_nxt & ~lcr_dlab;
end

endmodule: altr_uart_clkgen
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "AKY/VDqroC56S5zYqI2FH+pDtMm2XXjvzWe8rGJiybS03yo4KNBMg81pmtWbHVIPiTA81zIuGQJqb5vOIzimr/z+D85S4Jjtk9u3+kDOlkJUsrbYjDeARoR1d2Gy20nZHckh8FGW+dSF0ir+jochMyts2Y//A4WlmCaB7gD83g5rkI4jT1ldDhtPnUUhGKawcEehCEezQ12Toa+YG3kf1PWegnVnp6lxL1nZ0P1Qzo9HfxGdHdaN+C+TjEQXCxl/AVopy3SyeRzSJtqKQELwF5L/HWmX3LnTqTYoJTOtN8Qr6YpTInNz+PogPBjk9m83F8zZTKB3yiCaEmOfWldg7dxJHwufszSOSRdesrmb6jOSswn4yQH07xGIUrmlvXRAP98FMw9AnlqTrrOQzk0h0Qc8ZRV/KmjcNF3POXXpKQmDCmYjXh2T/P2pvlKc2scrTMJMZTjx/j63ofc2M2GNfS+QyQW3LT2Wus0Rp0EWQNWJHdyZQNO1nbDtPUdeM74TYUeH+cRlwro99eQAPe12X5l/1Q+GkVUtgIjtjoPy3pQWm1fK5ZKw2I5+9LhIXkbWfrSpXuo4+1yWfZdtH0xGTIMxUfHbsPVE3cD48fAyPS64tFoqPsEj9MRXA6mQSesik12/FFqamQLgiU9L9Wgm5mniit19+HQqUfRiDPlcpICIg+vLqKYYAdnS0O6mBuj+76aspoonSWKM0edUkXo+J4IAkcQnIyUa5I5D889V5BP5NFnIuUJNDDxs6XTWIrACwquk7OfDcoIifZ0Sekt/4tzm84jTMzrLLsHXT+dtGXpRYVj0J34z8IqAr7XCIyj+oxg2NP/KRAIPABaMOXDcUPhaFX6295NqjnDHM0LUmLaZchekkBmQ9afh8AcyX4jR3ZSNsihHis6t2ndXoTx7nbhtgPKiYQva7gcE07SKuZ2JeOlEWyCjZhJHQdsDSWLmnEiAI496PA3X90PqXLXUfd4hFVe2pPG3oJBLAEC7vPBx+NIPsjo/dROIWYn0aBs1"
`endif
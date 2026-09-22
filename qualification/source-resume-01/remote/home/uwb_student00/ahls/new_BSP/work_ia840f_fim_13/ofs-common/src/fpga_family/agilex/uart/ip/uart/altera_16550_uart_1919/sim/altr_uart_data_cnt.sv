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
//Data counter logic
//Counts 5 - 8 data phases
//Works for both tx and rx
//
`timescale 1 ps / 1 ps
module altr_uart_data_cnt (
   //Clock and Reset
   input  clk,
   input  rst_n,
   input  baud_clken,

   //Synchronous reset term
   input  s_rst,

   //Increment term
   input  inc,

   //CSR input - Data Length
   input  [2:0] lcr_dls_l,

   //data counter output
   output logic [3:0] data_cnt,

   //Count expired indicator
   output logic data_cnt_full
);

logic [3:0] data_cnt_nxt;

always_ff @(posedge clk or negedge rst_n) begin
   if (!rst_n)          data_cnt <= '0;
   else if (baud_clken) data_cnt <= data_cnt_nxt;
end

always_comb begin
   if (s_rst)     data_cnt_nxt = '0;
   else if (inc)  data_cnt_nxt = data_cnt + 4'h1;
   else           data_cnt_nxt = data_cnt;
end

//All logical comparisons need to use GREATER_OR_EQUAL
//operator to account for the fact that lcr_dls_l can be
//changed while transactions are active.
always_comb begin
   case(lcr_dls_l)
	  3'b000: data_cnt_full = (data_cnt >= 4'b0100) & inc;
	  3'b001: data_cnt_full = (data_cnt >= 4'b0101) & inc;
	  3'b010: data_cnt_full = (data_cnt >= 4'b0110) & inc;
	  3'b011: data_cnt_full = (data_cnt >= 4'b0111) & inc;
	  3'b100: data_cnt_full = (data_cnt >= 4'b1000) & inc;
	  default : data_cnt_full = 1'b0; 
   endcase
end
  
endmodule: altr_uart_data_cnt
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "AKY/VDqroC56S5zYqI2FH+pDtMm2XXjvzWe8rGJiybS03yo4KNBMg81pmtWbHVIPiTA81zIuGQJqb5vOIzimr/z+D85S4Jjtk9u3+kDOlkJUsrbYjDeARoR1d2Gy20nZHckh8FGW+dSF0ir+jochMyts2Y//A4WlmCaB7gD83g5rkI4jT1ldDhtPnUUhGKawcEehCEezQ12Toa+YG3kf1PWegnVnp6lxL1nZ0P1Qzo+GM25W3ZsrBWbVeajP5R87SenOXdrCEwRXKdoPFhSv0w1ChyrsGbY/Tw/YBv6bScwmiJtHgsWCS1YlMX7P7h0mZ9F3a7tbrpucVkjevejhrASMNIfo8qvr0VlFSSmeoX5LVoa/+snE0Y4eNoYuv2wAKRBlBgDQPi8A8eFsK2jyB2TktM1RZpRRAC/H9hICjv2EtfFy7UKsQr9FRL5wdAHI6pf7vMnuGB0Y/KRvZHIC3KI8lgix4bqR5VFqK26vaBC/FjcxPzhe/qTGsYL9V8nAiIuLyHKrdMxU9YqOo6dpXgJpNSMbiE5Mute4xwLAbo7c0pe0sNv6fG3sXqEdZoC8c9KSGKFf0LBmaQKl4Gnr4enCZUwoIe8AnEmVd6SRBamrBDqnlrpiP+GvSk+zQ2adolv1gSAzEro/6hLiHeAm5nGTqwzJ7bWJpVErMmCy/sHJ6/5ehVqlba3kajVa1k0jufLve7jMDXb0ONJsZKlWrrPAAPvxJG88XDfJhSJuRc2rfF+oY92LVkyBt3IvmvNn1upKksXADiG2w5oTWbmjuTobS2ZSmleEvoqOqyUD5ANodvOAdCQIgSH6TpzeV6EAUWBW0rYfAjSpVU94K3Nh+K5lCWKwp1ICfeuUwpyaFpZrBoURXrKFr4CUWfqq5am3ZK1EPGJzZkvwKEpDXUdR93Ab8g/H2D8ga0jxyp93jqt+t2+nqDt399zLSkuv/qxDRscw5Xwkiw4eSSArY37xLzAlgCUMtA+QLwqrL8etxoY/zKBDJgga/pCiKt2PJSlw"
`endif
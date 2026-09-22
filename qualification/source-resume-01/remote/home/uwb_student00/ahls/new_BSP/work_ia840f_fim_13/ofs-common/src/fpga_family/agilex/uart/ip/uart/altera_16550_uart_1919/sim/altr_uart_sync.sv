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
//Synchronizer block
//
`timescale 1 ps / 1 ps
module altr_uart_dsync #(
   parameter RESET = 0
) (
   //Clock and Reset
   input  clk,
   input  rst_n,
   input  datain,
   output logic dataout
);

localparam RESET_VAL = (RESET == 1) ? 1'b1 : 1'b0;

logic datain_m;

always_ff @(posedge clk or negedge rst_n) begin
   if (!rst_n) {dataout, datain_m} <= {2{RESET_VAL}};
   else        {dataout, datain_m} <= {datain_m, datain};
end

endmodule: altr_uart_dsync
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "AKY/VDqroC56S5zYqI2FH+pDtMm2XXjvzWe8rGJiybS03yo4KNBMg81pmtWbHVIPiTA81zIuGQJqb5vOIzimr/z+D85S4Jjtk9u3+kDOlkJUsrbYjDeARoR1d2Gy20nZHckh8FGW+dSF0ir+jochMyts2Y//A4WlmCaB7gD83g5rkI4jT1ldDhtPnUUhGKawcEehCEezQ12Toa+YG3kf1PWegnVnp6lxL1nZ0P1Qzo9gcZ1RrFQ/RRkkV+LEI0yyJzWCwa2K70pF3YpOWg8cJBi4RBy9+XPAKqbJkjS3p4N+3CmyqpOF+9uOJyqehu2r0Z6YaRlf5IxpSJqO1NosCDOpGUIGDRVgpzYuF0eEkxWLqZrqoCNPF4JA4qEYHUy8fn7wjTG9jK7g5Wjj88nS6//parlCV9uAPl9xzsj/PE0MsIl3oeX1F3p1z+s8Bjy+ES4sDsLhiMEPAoz/QV1f/pdHJjFApv+9x/HnOzUcac3+GavABYHqkZ6cYTXh58uwHRr0gGsGxZIXbPUAYN/4dOHymzkoYqQvC4fIv6l2U3oyFSXEm77TucDtL50G8zBP5AB+bWggDRmZUrhWoLTlNMjNO1ubRIDilAvSDuhKxEs1pmyW5nt8wpVHCoh0jkagLzA6NfRx0PjFIt50Up8831IFcNKUkLiqTB4HoGp8AWYFOequouuP97qyx4pCIxnb5swgtDB3lE9wy7kCagZ+TmpeBGUljU2MjumgxLYRMy22KgxAHvuQQBZT+pKhUpzAbW1/iGd22TCp3ChW41NGolyPlkT6I5gxEqA/5dFAfCncy2YedZmotnRgeg8i/hNnppAxxIpq/D8eZk62+OcJfn8I/E2RY7cbndjdgQJGhYE+6TP053CvB56ialt2uEMEAyw5bNBSfiGEV4XprxaizOr/d49xxJRaeqdVoFUKpP9+RRcmKiAlsbGYP+f2wnjxfWDhkkY7l/3jGa536VA6558tXKkPg7BLgRXu1F9NnnLA/Lmibjm1AvldSZiKjAna"
`endif
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
//Synchronize all signals
//coming from outside the chip
//
`timescale 1 ps / 1 ps
module altr_uart_rx_sync (
   input  clk,
   input  rst_n,

   input  sin,
   input  cts_n,
   input  dsr_n,
   input  dcd_n,
   input  ri_n,

   output sin_i_pre,
   output cts_i_n,
   output dsr_i_n,
   output dcd_i_n,
   output ri_i_n
);

altr_uart_dsync #(.RESET(1'b0)) sin_sync (
   .datain(sin),
   .dataout(sin_i_pre),
   .*
);

altr_uart_dsync #(.RESET(1'b1)) cts_sync (
   .datain(cts_n),
   .dataout(cts_i_n),
   .*
);

altr_uart_dsync #(.RESET(1'b1)) dsr_sync (
   .datain(dsr_n),
   .dataout(dsr_i_n),
   .*
);

altr_uart_dsync #(.RESET(1'b1)) dcd_sync (
   .datain(dcd_n),
   .dataout(dcd_i_n),
   .*
);

altr_uart_dsync #(.RESET(1'b1)) ri_sync (
   .datain(ri_n),
   .dataout(ri_i_n),
   .*
);

endmodule: altr_uart_rx_sync
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "AKY/VDqroC56S5zYqI2FH+pDtMm2XXjvzWe8rGJiybS03yo4KNBMg81pmtWbHVIPiTA81zIuGQJqb5vOIzimr/z+D85S4Jjtk9u3+kDOlkJUsrbYjDeARoR1d2Gy20nZHckh8FGW+dSF0ir+jochMyts2Y//A4WlmCaB7gD83g5rkI4jT1ldDhtPnUUhGKawcEehCEezQ12Toa+YG3kf1PWegnVnp6lxL1nZ0P1Qzo8c5X2qdM/jLg5tuzskOk+Ygx6rIjjorROCmQgTBzVm4g33Ar6qNzLEn1e/0QGGjUTdWAokh/RlRbeHT10vhl8wDlHfwChQMZCCnuJHZsdp9d/1MtPNJ56E3xM5zfEvI9SMiHHgBQn+CG/DGWKAnw/2neM72JL6CQ2zRfzeuF2b3SupuLTtL13DD84vEDrNqAaWJoI1xwN2yRq5PcZPSQG5Sai7BXJqUMuGtqXi4pAaJH+AM/nYEgJEkaZoVj6LtLPRc+JaWbMSZOZXmMBt954UaqFen3XNKQWWBiUgJJ6jtt/dlhYDgaNOm0wxHd2GRVfrESlLFdu9bVDPmYwgexQFrLHQTJxlOU1AD+AanA2C7PJ0OC5uzMp08sc6xAwLqgkHDx54RPdYki8Z/dvaOBCV2ThOzrxjyJoPKsb1Gqiij4pgM24d+rlfzizTiaGrf7mBLoQhyiOvlzdhzCFHKOzL3IlAULw4/3mHZrcLpRqTPQmDOpYIriatitdYAmjTzVuULmq8cdGg/+AraxLLK3SXXYFy6+H2RwVuFXYabXFr/hDOT+0ka/j8nz2wn6t44FV7O6s26i1VAU9ifYWE6mc/K90F2rgX/IwA7b+r5C310nXQJHWlb45NIVlj7k3grRQle5MvJ4BjthvJgCdEK7gCg+mxhU4yQ7LXg5qWJzCgPlwcIkpnUT3YWgnyQnOZSMCawREeLbQ2Ok+8XIwMyG4kyZVEEmIFus3lEg5OAqHIHEDGzgi2Cx/JA/oMF4YHGWKEiENIICqfwJJHn5jMU4V9"
`endif
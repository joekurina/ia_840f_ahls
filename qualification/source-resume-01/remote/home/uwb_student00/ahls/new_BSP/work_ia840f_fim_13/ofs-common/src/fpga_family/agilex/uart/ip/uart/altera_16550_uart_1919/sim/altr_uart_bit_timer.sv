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
//Generic bit timer
//Counts 16 baud clocks
//Works for both tx and rx
//
`timescale 1 ps / 1 ps
module altr_uart_bit_timer (
   //Clock and Reset
   input  clk,
   input  rst_n,
   input  baud_clken,

   //Increment control
   input  inc,
   input  s_rst,

   //Timer output
   output logic [3:0] bit_timer

);

logic [3:0] bit_timer_nxt;

always_ff @(posedge clk or negedge rst_n) begin
   if (!rst_n)          bit_timer <= '0;
   else if (baud_clken) bit_timer <= bit_timer_nxt;
end

always_comb begin
   if (s_rst)     bit_timer_nxt = '0;
   else if (inc)  bit_timer_nxt = bit_timer + 4'h1;
   else           bit_timer_nxt = bit_timer;
end
 
endmodule: altr_uart_bit_timer
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "AKY/VDqroC56S5zYqI2FH+pDtMm2XXjvzWe8rGJiybS03yo4KNBMg81pmtWbHVIPiTA81zIuGQJqb5vOIzimr/z+D85S4Jjtk9u3+kDOlkJUsrbYjDeARoR1d2Gy20nZHckh8FGW+dSF0ir+jochMyts2Y//A4WlmCaB7gD83g5rkI4jT1ldDhtPnUUhGKawcEehCEezQ12Toa+YG3kf1PWegnVnp6lxL1nZ0P1Qzo88KVcKvfI0/5oO7DExXl1LZ1Zi0UQGxnk/ix1uJPkrX8GzkLQJTe4Of7b9rm2eZGsIfCBRcG4ZkKo1bzoEkjkVbfxHolK/qfhzKZzW9OOwynNGRWsq8gI6mbVPhkvo2I4qOA8sWvXlZFsoqSug8NdtNZoKdOBP2SXMX5zBOf8FYkK3oF/8GY4TaovXwn/CQ9b4UgjdAVZxXGJE/CUPhBBJEuKd2YU6Og+85Si3D/I0vSUBY15GNchXmdSzRUQQkZNKY9iOtZ9Ls47cTCa2RoSQtePnZGG6VVflBarbNjnS2L4JGZ+v8MLeBuWekA23jRZcAubkKvAjH+Q9/jokkGAquYGVd+Y/oghubb0CHh/T/GZ6j8ZgOghSHpveL8fuMquwbRVSxJtJdocKM0m00VwD/CHDh0ifbPfrBYuXOFFXkK95fG+IbUjC3+tw4ZLWPIc76soUoVMlneKb1kQSYA6GkXe0s7J9ChrF7utYEWDF2AsOHAvSNdZsuWp/RP/Fcbv3JLo2bEXeHXmffT4IxmcYfa1AuKqKqUk6HT6OvvKB91HsiQbYepx6et+EiynnXJCswpOU0j7mJm0pEP238MwdHaz4E+ARYy164+e78ZRnCs/5bblC5e4AmOt7M1TilLPu6bgc3S+WthpEPmcsy4P1KJAU6t9wG65xJA79bgRqhBlFsRoDSMJQBmsRG2Xe+thY2Uxoex9jRuinNUuRabWk41cwcdEZdpgxSAx72IRgMmKDr9PGWeUnb1n3JU5UwaN/ZYYVEiCXslK+AMAx1ozi"
`endif
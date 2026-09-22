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
//Transmit Out State Machine
//
`timescale 1 ps / 1 ps
module altr_uart_txfsm (
   //Clock and Reset
   input  clk,
   input  rst_n,
   input  baud_clken,

   //CSR Inputs
   input  lcr_pen_l,
   input  lcr_stop_l,
   input  [2:0] lcr_dls_l,

   //Consolidated avail input from TXSTOR or TXFC
   input  txout_avail,

   //RXFC FSM - XON state
   input  rxfc_xon,

   //bit-timer counts
   input  one_bit_time,
   
   input  one_bit_time_m1,
   input  half_bit_time,
   input  half_bit_time_m1,

   //data_cnt counts
   input  data_cnt_full,

   //TXFSM state indicators
   output logic txfsm_idle,
   output logic txfsm_start,
   output logic txfsm_data,
   output logic txfsm_parity,
   output logic txfsm_stop
);

logic valid_dls;

enum logic [2:0] {
   IDLE   = 3'b000,
   START  = 3'b001,
   DATA   = 3'b010,
   PARITY = 3'b011,
   STOP1  = 3'b100,
   STOP2  = 3'b101,
   XX     = 'x  } state, next;

// when lcr_dls_l[2] is high, lcr_dls_l[1:0] has to be all zero; else it is an invalid combination
assign valid_dls = (lcr_dls_l[2] && (lcr_dls_l[1:0] != 2'b00)) ? 1'b0 : 1'b1;

//Internal signals
logic arc_stop2_idle;

//Present state registers
always_ff @(posedge clk or negedge rst_n) begin
   if (!rst_n)          state <= IDLE;
   else if (baud_clken) state <= next;
end

//Next state combi
always_comb begin
   case (state)
      IDLE  :  if (txout_avail & rxfc_xon & valid_dls)
                  next = START;
               else 
                  next = IDLE;

      START :  if (one_bit_time)
                  next = DATA;
               else
                  next = START;

      DATA  :  if (data_cnt_full & one_bit_time & lcr_pen_l)
                  next = PARITY;
               else if (data_cnt_full & one_bit_time & ~lcr_pen_l)
                  next = STOP1;
               else
                  next = DATA;

      PARITY:  if (one_bit_time)
                  next = STOP1;
               else
                  next = PARITY;

      STOP1 :  if (~lcr_stop_l & one_bit_time_m1)
                  next = IDLE;
               else if (lcr_stop_l & one_bit_time)
                  next = STOP2;
               else
                  next = STOP1;

      STOP2 :  if (arc_stop2_idle)
                  next = IDLE;
               else
                  next = STOP2;

      default: next = XX;
   endcase
end

//State Outputs
always_comb begin
   txfsm_idle   = (state == IDLE);
   txfsm_start  = (state == START);
   txfsm_data   = (state == DATA);
   txfsm_parity = (state == PARITY);
   txfsm_stop   = ((state == STOP1) || (state == STOP2));
end

//FSM arc from STOP2 to IDLE state
assign arc_stop2_idle = (lcr_dls_l == 3'b000) ? half_bit_time_m1 : one_bit_time_m1;

endmodule: altr_uart_txfsm
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "AKY/VDqroC56S5zYqI2FH+pDtMm2XXjvzWe8rGJiybS03yo4KNBMg81pmtWbHVIPiTA81zIuGQJqb5vOIzimr/z+D85S4Jjtk9u3+kDOlkJUsrbYjDeARoR1d2Gy20nZHckh8FGW+dSF0ir+jochMyts2Y//A4WlmCaB7gD83g5rkI4jT1ldDhtPnUUhGKawcEehCEezQ12Toa+YG3kf1PWegnVnp6lxL1nZ0P1Qzo8E9+o3bnUEi6qPyY7ZLlyxisFr5RvRuFXGwQDbKFKPMzbln2JdEj2be7NpSBO9TAQm8jxumze84WPaXivJ7Dcf51F4wiPYI1EVkre6ul4Rqlis7JUY2J7ZxWPUkFRGb1KT71ydd3usafE1UArSOK895oqP0dMiDKVdsGwJMdGhpe4YFcdv8RmFo/LcSSKSDvCIq9v7bfGJ+plZMmmHBY4Zhy0xSfiGAud2E6WfwHgbAyyKB3/GZ9wmyLpGAsT+NzCRHT5xoPQhiy4BlmL2QmlGshY1vW984ScRVcbcEPwv2kYY0CL+Gdy91jUkgF9jR92PGM5omQFR2c6KP5NovGR+FIcMNo4bxbJqRPVu/epi5xdcNaNd30OHObSga9zumL8SPkeSDceeRnfXhqOc5sqpYGAxyqCQXDmnznvNWzACZlV7zwWxHAhvVL6surm02Hh4XWN8q8tgtS54X+PJnFw5FQeXQ+rPdWvBAKNvl5T0W4Jp6vk2FjYYN3CZBGVrGdkkmYBuGXWks5J/crwE03D7l+BrurI9sXR6GwRcOufdDEC56FQyGfP3eZ/70sN/1/ocVhCl9XSpvJnpP4nJG1cuzhSmVJM9Y9cWlt66flq53VLgnJNJNj+acODS28ctkabgG4l3LSD0ppE+4Z61DVbdzcELSCZC2s9kujvTHProUDAKrn4TgSoAtGHp0jbF/cvUIwp5yhYZ0yxLr7+3rq5RccHkUtXTu6bGCoZ8XWLpGJyxCeEjmYubXGlxYKWg/pn6Nj8IrgPLWGsqQL7z4xpa"
`endif
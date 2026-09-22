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
//Receive In State Machine
//
`timescale 1 ps / 1 ps
module altr_uart_rxfsm (
   //Clock and Reset
   input  clk,
   input  rst_n,
   input  baud_clken,

   //CSR Interface
   input  lcr_pen_l,
   input  [2:0] lcr_dls_l,

   //Serial Input
   input  sin_i,

   //bit-timer counts
   input  half_bit_time,
   input  stop2_bit_time,

   //data_cnt counts
   input  data_cnt_full,

   //break detection
   input  p_rx_break,
   input  rx_break,
   input  rx_stop2,

   //RXFSM state indicators
   output logic rxfsm_idle,
   output logic rxfsm_start,
   output logic rxfsm_data,
   output logic rxfsm_parity,
   output logic rxfsm_stop,
   output logic rxfsm_break1,
   output logic rxfsm_break2

);

enum logic [2:0] {
   IDLE   = 3'b000,
   START  = 3'b001,
   DATA   = 3'b010,
   PARITY = 3'b011,
   STOP   = 3'b100,
   BREAK1 = 3'b101,
   BREAK2 = 3'b110,
   XX     = 'x  } state, next;

logic arc_BREAK1_IDLE;
logic arc_BREAK1_BREAK2;
logic valid_dls;

// when lcr_dls_l[2] is high, lcr_dls_l[1:0] has to be all zero; else it is an invalid combination
assign valid_dls = (lcr_dls_l[2] && (lcr_dls_l[1:0] != 2'b00)) ? 1'b0 : 1'b1;

//Present state registers
always_ff @(posedge clk or negedge rst_n) begin
   if (!rst_n)          state <= IDLE;
   else if (baud_clken) state <= next;
end

//Next state combi
always_comb begin
   case (state)
      IDLE  :  if (~sin_i & valid_dls)
                  next = START;
               else
                  next = IDLE;
      START :  if (~sin_i & half_bit_time)
                  next = DATA;
               else if (sin_i)
                  next = IDLE;
               else
                  next = START;
      DATA  :  if (data_cnt_full & half_bit_time & lcr_pen_l)
                  next = PARITY;
               else if (data_cnt_full & half_bit_time & ~lcr_pen_l)
                  next = STOP;
               else
                  next = DATA;

      PARITY:  if (half_bit_time)
                  next = STOP;
               else
                  next = PARITY;
                  
      STOP  :  if (half_bit_time)
                  next = BREAK1;
               else
                  next = STOP;

      BREAK1:  if (arc_BREAK1_IDLE)
                  next = IDLE;
               else if (arc_BREAK1_BREAK2)
                  next = BREAK2;
               else
                  next = BREAK1;

      BREAK2:  if (rx_stop2 | sin_i)
                  next = IDLE;
               else
                  next = BREAK2;

      default: next = XX;
   endcase
end

//State Outputs
always_comb begin
   rxfsm_idle  = (state == IDLE);
   rxfsm_start = (state == START);
   rxfsm_data  = (state == DATA);
   rxfsm_parity= (state == PARITY);
   rxfsm_stop  = (state == STOP);
   rxfsm_break1= (state == BREAK1);
   rxfsm_break2= (state == BREAK2);
end

assign arc_BREAK1_IDLE     = ~p_rx_break & (~rx_break | sin_i);
assign arc_BREAK1_BREAK2   = p_rx_break & stop2_bit_time;

endmodule: altr_uart_rxfsm
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "AKY/VDqroC56S5zYqI2FH+pDtMm2XXjvzWe8rGJiybS03yo4KNBMg81pmtWbHVIPiTA81zIuGQJqb5vOIzimr/z+D85S4Jjtk9u3+kDOlkJUsrbYjDeARoR1d2Gy20nZHckh8FGW+dSF0ir+jochMyts2Y//A4WlmCaB7gD83g5rkI4jT1ldDhtPnUUhGKawcEehCEezQ12Toa+YG3kf1PWegnVnp6lxL1nZ0P1Qzo/s9l/DtnLZg8lsh8K5MTuqKlQRe3sRYgb4KMmKD1fXuP26rQpCxV4zKWlifpwG1YCXEFNIWQGWCPwWjHCRQ9wG4LHBL+dd/jmDyFSoQv6zW1J+YzKuL2UThe7F9bsFashM5YGOG5m7ZfYFRE5vlfnctDTONo+O1HxjGmTehWlKb3qgLvWXRYFLzvzuODGPwbBy70wiC7YpfFh3rsxKr+RCrTP6Y9it1+dvdjg13ep2AQZK2LpolGTrUtFx1wR0JJl+tPkOZaeoNnGOcz50RNzaorn+9NUcEU45Rxmn424qhl+UFdICtawUEGgWKJpQB/ZEZ1F2KDpPzGuLsrL0rtQWYQoJUukAznc2esUSCkeBNlwws+73eWcz3o8Xdar+77bdkeVoSdSFa8vM2fptUgUW1vVDiPdbTOhWb7c23knZhpRzhWRqcjLAmt1ytbZqovGNmoF/ay8ScwwDUUAdfbvL1FhaFi6yaz26gjkx8NsFDmn9r5pStVEYpBg/sOG1fl+RuQiGxss0EN6jRDlV6NW+yLXsqsneRqEbz0Om87ne01hbDnLoXp+a1pBqfQ/0UguwoOY3FMxP0uSqzoEtQHUBMkJmvQ96UDuAwPzP/VyQWSMs106AUszQb/l98klKw09bFxVMh/KhkbY++BaDGvSEqwkNhuGGjae58VjM+xEP/1ihLYZL0lvV+bDvpmzPlB1mXWKqodPHFJGTqUngqaXJfX+TFM+OdKqM/h5telt+ybSh2PIoIm0JydN5PBavKGoe+2JD9jjVhxjr9EwCRH4k"
`endif
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


///////////////////////////////////////////////////////////////////////////////
//  Reset request sequencing state machine.
//
///////////////////////////////////////////////////////////////////////////////
module altera_emif_arch_fm_local_reset # (
   parameter PHY_CONFIG_ENUM    = "",
   parameter IS_HPS             = 0
) (
   input  logic   afi_clk,
   input  logic   afi_reset_n,
   input  logic   emif_usr_clk,
   input  logic   emif_usr_reset_n,

   input  logic   local_reset_req_int,
   output logic   core2seq_reset_req,

   output logic   local_reset_done,
   input  logic   seq2core_reset_done
);
   timeunit 1ns;
   timeprecision 1ps;

   typedef enum {
      WAIT_RESET_DONE,
      WAIT_USER_RESET_REQ_1ST_DEASSERT,
      WAIT_USER_RESET_REQ_ASSERT,
      WAIT_USER_RESET_REQ_2ND_DEASSERT,
      ASSERT_CORE2SEQ_RESET_REQ
   } state_t;

   generate
      if (IS_HPS) begin: hps
         assign core2seq_reset_req = 1'b0;
         assign local_reset_done   = 1'b0;
      end else begin : non_hps
         logic clk;
         logic reset_n;

         if (PHY_CONFIG_ENUM == "CONFIG_PHY_AND_HARD_CTRL") begin : hmc
            assign clk = emif_usr_clk;
            assign reset_n = emif_usr_reset_n;
         end else begin : non_hmc
            assign clk = afi_clk;
            assign reset_n = afi_reset_n;
         end

         ////////////////////////////////////////////////////////////////////
         // State machine
         ////////////////////////////////////////////////////////////////////
         state_t state                 /* synthesis ignore_power_up */;
         logic   core2seq_reset_req_r  /* synthesis ignore_power_up dont_merge syn_noprune syn_preserve = 1 */;
         logic   local_reset_done_r    /* synthesis ignore_power_up dont_merge syn_noprune syn_preserve = 1 */;

         always_ff @(posedge clk, negedge reset_n)
         begin
            if (!reset_n) begin
               state                <= WAIT_RESET_DONE;
               core2seq_reset_req_r <= 1'b0;
               local_reset_done_r   <= 1'b0;
            end else begin
               case (state)
                  WAIT_RESET_DONE:
                  begin
                     // Wait until sequencer signals it's ready to accept a reset request.
                     if (seq2core_reset_done) begin
                        if (local_reset_req_int == 1'b1) begin
                           state                <= WAIT_USER_RESET_REQ_1ST_DEASSERT;
                           core2seq_reset_req_r <= 1'b0;
                           local_reset_done_r   <= 1'b1;
                        end else begin
                           state                <= WAIT_USER_RESET_REQ_ASSERT;
                           core2seq_reset_req_r <= 1'b0;
                           local_reset_done_r   <= 1'b1;
                        end
                     end
                     else
                     begin
                        state                <= WAIT_RESET_DONE;
                        core2seq_reset_req_r <= 1'b0;
                        local_reset_done_r   <= 1'b0;
                     end
                  end

                  WAIT_USER_RESET_REQ_1ST_DEASSERT:
                  begin
                     if (~local_reset_req_int) begin
                        state                <= WAIT_USER_RESET_REQ_ASSERT;
                        core2seq_reset_req_r <= 1'b0;
                        local_reset_done_r   <= 1'b1;
                     end else begin
                        state                <= WAIT_USER_RESET_REQ_1ST_DEASSERT;
                        core2seq_reset_req_r <= 1'b0;
                        local_reset_done_r   <= 1'b1;
                     end
                  end

                  WAIT_USER_RESET_REQ_ASSERT:
                  begin
                     if (local_reset_req_int) begin
                        state                <= WAIT_USER_RESET_REQ_2ND_DEASSERT;
                        core2seq_reset_req_r <= 1'b0;
                        local_reset_done_r   <= 1'b1;
                     end else begin
                        state                <= WAIT_USER_RESET_REQ_ASSERT;
                        core2seq_reset_req_r <= 1'b0;
                        local_reset_done_r   <= 1'b1;
                     end

                  end

                  WAIT_USER_RESET_REQ_2ND_DEASSERT:
                  begin
                     if (~local_reset_req_int) begin
                        state                <= ASSERT_CORE2SEQ_RESET_REQ;
                        core2seq_reset_req_r <= 1'b1;
                        local_reset_done_r   <= 1'b0;
                     end else begin
                        state                <= WAIT_USER_RESET_REQ_2ND_DEASSERT;
                        core2seq_reset_req_r <= 1'b0;
                        local_reset_done_r   <= 1'b1;
                     end
                  end

                  ASSERT_CORE2SEQ_RESET_REQ:
                  begin
                     state                   <= ASSERT_CORE2SEQ_RESET_REQ;
                     core2seq_reset_req_r    <= 1'b1;
                     local_reset_done_r      <= 1'b0;
                  end
                  default:
                  begin
                     state                   <= WAIT_RESET_DONE;
                     core2seq_reset_req_r    <= 1'b0;
                     local_reset_done_r      <= 1'b0;
                  end
               endcase
            end
         end

         ////////////////////////////////////////////////////////////////////
         // Output generation
         ////////////////////////////////////////////////////////////////////
         assign core2seq_reset_req = core2seq_reset_req_r;

         // Instead of passing seq2core_reset_done directly to user, we have the ability
         // to acknowledge the reset request earlier, as soon as a local_reset_req pulse
         // is detected.
         assign local_reset_done = local_reset_done_r;
      end
   endgenerate
endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "5CuDA+N0ipkxBbEFUigHJZjgKRBExUzGn9z/NRXk7X5L9zeYM+vdBVJ1f18yt+xMvY/22tVeb7s/H98agD+jK7YsarPT8vFtti1g/cmz8hXnwEr5xu5LhqSR+2HHb+em2Q3utiK6fTAx1ALvUZepSHwtTJ/aE66X1iGtlQu5tPocyrl5DTgTR40cmiiOLVMSsyIS5Ao4CrdifHzFPIRQUTo/6nxhwZ/xBegvjthbnPHJt/elkvXjotZirdfbI5raOQqRxFaLYGtSdQgJbuvpB6GIcGrjW6k1daR438tJC4BkQV5X8WJVQ7f1m+0Srrglj4BYvQX5DinkwIq9hhzA6op2JDeCErncwNT83DRcnH2YNiBj7wV0zRsmTnUM81hPo/xGuwPkpXOHww1G7s8NSEeJp0aiRaXp76AYUWTg61cfGONp/4v+PLlSxRRH4whPCyVaZaIgzB0yK0FH3XxYIEzGuMbCFxOxCUtYoDmNF5eTdwW/5VzHoS5MFxVwg7HFtN4ul5FOMSbMu0sLZsScZuGM6gwXt1P+rWQpL6pzdKfyEQ82rq4C5vzSiv9wvi/MC191jW6rE2TPruQmlBLV85l4LWX0ZEXSfmAM0R7NDcJbdnr1L0Bl1eTiqJp8iUwnUf1hCCCDu0MxRwnKzdF21NOAwKJwYFxUYwpvfoc1akvAwWKaUhXC0JvqA5XtPO2DV/DSQYR/Z926Tu1HSMpP6Tn3eau6i8kNuD4kLWqYu8gdej635ff/fkSxV3gycYyHXADlPKjBUGBSOD+WWsnJ36bzzzaCz6NsnYXhij8g2WnwqlBPXqW0jdLVKYJxpkEPBPPh+WDq6OTbvYYDIEojbVLMO07ESGKMrNFKpfAotXQvk/PRIFQbdV9ZnjDhb5KokBE/G1CW1vZUoGD39igWCaV/H6Bvl6vkdMr9HKkl30cW7h9KyRQMkZ75xo6TGGG7oLXmyHDaUqQmR2bZgI/3uuM4/ShJErLUlCL7ou8SIYe3ICpR200zRcx+5N/u1cnM"
`endif
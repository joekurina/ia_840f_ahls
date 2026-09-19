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



module altera_emif_arch_fm_cal_counter # (
   parameter IS_HPS = 0
) (
   input logic pll_ref_clk_int,
   input logic local_reset_req_int,
   input logic afi_cal_in_progress
);
   timeunit 1ps;
   timeprecision 1ps;

   typedef enum {
      INIT,
      IDLE,
      COUNT_CAL,
      STOP
   } counter_state_t;

   logic                         done;
   logic [31:0]                  clk_counter;

   generate
      if (IS_HPS == 0) begin : non_hps
         logic                         cal_done;
         logic                         reset_req_sync;
         logic                         cal_in_progress_sync;

         altera_std_synchronizer_nocut
         inst_sync_reset_n (
            .clk     (pll_ref_clk_int),
            .reset_n (1'b1),
            .din     (local_reset_req_int),
            .dout    (reset_req_sync)
         );

         altera_std_synchronizer_nocut
         inst_sync_cal_in_progress (
            .clk     (pll_ref_clk_int),
            .reset_n (1'b1),
            .din     (afi_cal_in_progress),
            .dout    (cal_in_progress_sync)
         );

         counter_state_t counter_state /* synthesis ignore_power_up */;

         assign done = ((counter_state == STOP) ? 1'b1 : 1'b0);

         always_ff @(posedge pll_ref_clk_int) begin
            if(reset_req_sync == 1'b1) begin
               counter_state <= INIT;
            end
            else begin
               case(counter_state)
                  INIT:
                  begin
                     clk_counter <= 32'h0;
                     counter_state <= IDLE;
                  end

                  IDLE:
                  begin
                     if (cal_in_progress_sync == 1'b1)
                     begin
                        counter_state <= COUNT_CAL;
                     end
                  end

                  COUNT_CAL:
                  begin
                     clk_counter[31:0] <= clk_counter[31:0] + 32'h0000_0001;

                     if (cal_in_progress_sync == 1'b0)
                     begin
                        counter_state <= STOP;
                     end
                  end

                  STOP:
                  begin
                     counter_state <= STOP;
                  end

                  default:
                  begin
                     counter_state <= INIT;
                  end
               endcase
            end
         end
      end else begin : hps
         assign done = 1'b1;
         assign clk_counter = '0;
      end
   endgenerate

`ifdef ALTERA_EMIF_ENABLE_ISSP
   altsource_probe #(         
      .sld_auto_instance_index ("YES"),
      .sld_instance_index      (0),
      .instance_id             ("CALC"),
      .probe_width             (33),
      .source_width            (0),
      .source_initial_value    ("0"),
      .enable_metastability    ("NO")
      ) cal_counter_issp (
      .probe  ({done, clk_counter[31:0]})
   );
`endif

endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "5CuDA+N0ipkxBbEFUigHJZjgKRBExUzGn9z/NRXk7X5L9zeYM+vdBVJ1f18yt+xMvY/22tVeb7s/H98agD+jK7YsarPT8vFtti1g/cmz8hXnwEr5xu5LhqSR+2HHb+em2Q3utiK6fTAx1ALvUZepSHwtTJ/aE66X1iGtlQu5tPocyrl5DTgTR40cmiiOLVMSsyIS5Ao4CrdifHzFPIRQUTo/6nxhwZ/xBegvjthbnPF3h0yng2IQ2onfzqKmEup+DAZ8kP6QI9duR/1oRWzO3HHi/S8jM9uP83kA1+wyFRwSV2rXqW2B0JLBpHX1HEa45n8Kz9XIMP3OdrcA0j3nW+Wat732wNBGlzxSKqs9H39jct1JuLQnPtDhD4FJD9jIdH7jfQFImE37ULkOfH/R5eNOcDvWpe/OAMtOBYjFFeY/MgzZbNAC4kdZsxeBBq8k+bnLnCJP1sC1EC4VVZou9YnxUtgTzxkypIShHRX+yoeaTSuVaRUmoZ5QRTJ0xfdlCvTLzBt8sWYY5lho21bwH+HK1Y5iny303zPY0ubkid5B1A6Rq+dvUxeIONWAQFRqpgpPgaYRpG5Q1AAej4vfV2m4rp0WvuJLg61KYw+FSdHI1xL039IZY8lQaWVzv1LhFvsC0DoViu6Px9+40d6WguEEGLwPwxf7wlfM2/Lk9P6zklIsfdQ9fgINl8lKqO+foO7IrwPsG0mXgDjrFzDKU/bRZKxbvDo9AzstwenagY7Fn9K28SlU593WCiQJrrrTpBTTfED4wAIuYQ5W/chtzipdA/jELmMvatNGGjR+g8AXoq7dURgcwh2wVQzRV9Xm3FGAfLh8mYHUrgBQ47jHEtEEcGRAnXHJOrN60NNI8VFIp9keSI2HT59HTWJkhkYbS8f06MJOhfFCtdi5Iz333mJg2ayw6UITGJbLmEoqaTHQerYZP6b+gPotatDMrL3T21MjOS5+v55hdvNPWNOgEOZiLhm9aUtsNoga1yx4V2v4ijV+DICjR2P1nxojMftz"
`endif
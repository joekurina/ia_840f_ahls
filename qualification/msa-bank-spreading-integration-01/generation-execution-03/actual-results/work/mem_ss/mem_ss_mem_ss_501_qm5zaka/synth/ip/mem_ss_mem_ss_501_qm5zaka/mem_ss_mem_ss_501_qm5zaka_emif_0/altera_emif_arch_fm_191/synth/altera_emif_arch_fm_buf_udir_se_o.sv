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


module altera_emif_arch_fm_buf_udir_se_o #(
   parameter OCT_CONTROL_WIDTH = 1,
   parameter CALIBRATED_OCT = 1
) (
   input  logic i,
   output logic o,
   input  logic oe,
   input  logic oct_termin
);
   timeunit 1ns;
   timeprecision 1ps;

   generate
      if (CALIBRATED_OCT) 
      begin : cal_oct
         tennm_io_obuf obuf (
            .i(i),
            .o(o),
            .term_in(oct_termin),
            .seriesterminationcontrol(),
            .parallelterminationcontrol(),
            .obar(),
            .oe(oe),
            .dynamicterminationcontrol(),
            .devoe()
            );    
      end else 
      begin : no_oct
         tennm_io_obuf obuf (
            .i(i),
            .o(o),
            .seriesterminationcontrol(),
            .parallelterminationcontrol(),
            .obar(),
            .oe(oe),
            .dynamicterminationcontrol(),
            .devoe()
            );    
      end
   endgenerate
endmodule

`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "5CuDA+N0ipkxBbEFUigHJZjgKRBExUzGn9z/NRXk7X5L9zeYM+vdBVJ1f18yt+xMvY/22tVeb7s/H98agD+jK7YsarPT8vFtti1g/cmz8hXnwEr5xu5LhqSR+2HHb+em2Q3utiK6fTAx1ALvUZepSHwtTJ/aE66X1iGtlQu5tPocyrl5DTgTR40cmiiOLVMSsyIS5Ao4CrdifHzFPIRQUTo/6nxhwZ/xBegvjthbnPHNuN1k5t3WKZct3jAnnpWE3XcetjrKrXcC1ZiUyWYfi6PI7Aer2Y0Q50AYSbDObDHp2G55QjKsP2ZYuLbFSsAArz21HMWBkaIsehVvSGOUaQA2HaXzP4hk45Qwiv4KCSiLbyz9aJsql7sC7YoJLYlGtbhaqbvJdWjG4yqnXJPBOo4nOD4ekaIl0ki+sRf9Rx++EqS3yQoNrEJA12c5uh6bXMaaiYE+b7Wo/lpxmIYFpaOTy1v2XHHK0+8/pInhA6xxqBAeYVsgQ0A5P8Sa0GEljIF2TWtimfFHpFq4ipSTxgIGGcHeJpqFx798IM2BqaPS5PTHMaZ8iHlhnwBRl9lEFPD8ZzMTysrznYIAQfgbDetPwZ28iMMSiM/ES5tE90kTQFlqc8XzFk9m4TNhhf2B8K8vLqnj6voelRpFBFaI8iueqlaMNr+XSbBleifzskKMZBeDrJr+Tph6nMGi5M3SAjj8uIcx5NaWTj/irjTn2e54vJxU/3ZdSO/nubPn6LH+wlHmqEjx1spb8vrXnAC5rDQNwao2YtlbdclylUNTfUBzpb/tcXl/wDla56fMzxvl7cBBsBUQYzEHyf51Mhs9+Q12G4zC9gjwZbdJBVdbsLj38Li/F0Jdi1cvs3S2hnJiMc5K8HgnsGXZCMX7tmBjmaGAGKGnB8DKFHpAGu8TyyOOZqNQeWgskvhm39kJs7pCIprg2ywUGObA7N2OvkMm8FgYudhwfZ5/1P1APEEo1I3CODD47Py0wBRVo2CoBT5QWh/1epeA46Zdib4WkdN4"
`endif
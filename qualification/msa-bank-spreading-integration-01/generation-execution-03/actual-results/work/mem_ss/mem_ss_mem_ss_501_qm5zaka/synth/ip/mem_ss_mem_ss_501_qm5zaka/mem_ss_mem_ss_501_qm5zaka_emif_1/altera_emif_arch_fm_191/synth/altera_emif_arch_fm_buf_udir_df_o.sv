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


module altera_emif_arch_fm_buf_udir_df_o #(
   parameter OCT_CONTROL_WIDTH = 1,
   parameter CALIBRATED_OCT = 1
) (
   input  logic i,
   input  logic ibar,
   output logic o,
   output logic obar,
   input  logic oein,
   input  logic oeinb,
   input  logic oct_termin
);
   timeunit 1ns;
   timeprecision 1ps;

   localparam DCCEN = "true";

   logic pdiff_out_o;
   logic pdiff_out_obar;

   logic pdiff_out_oe;
   logic pdiff_out_oebar;

   tennm_pseudo_diff_out # (
      .feedthrough("true")
   ) pdiff_out (
      .i(i),
      .ibar(ibar),
      .o(pdiff_out_o),
      .obar(pdiff_out_obar),
      .oein(oein),
      .oebin(oeinb),
      .oeout(pdiff_out_oe),
      .oebout(pdiff_out_oebar),
      .dtcin(),
      .dtcbarin(),
      .dtc(),
      .dtcbar()
   );

   generate
      if (CALIBRATED_OCT)
      begin : cal_oct
         tennm_io_obuf # (
            .dccen(DCCEN)
         ) obuf (
            .i(pdiff_out_o),
            .o(o),
            .oe(pdiff_out_oe),
            .term_in(oct_termin),
            .seriesterminationcontrol(),
            .parallelterminationcontrol(),
            .dynamicterminationcontrol(),
            .obar(),
            .devoe()
         );

         tennm_io_obuf # (
            .dccen(DCCEN)
         ) obuf_bar (
            .i(pdiff_out_obar),
            .o(obar),
            .oe(pdiff_out_oebar),
            .term_in(oct_termin),
            .seriesterminationcontrol(),
            .parallelterminationcontrol(),
            .dynamicterminationcontrol(),
            .obar(),
            .devoe()
         );
      end else
      begin : no_oct
         tennm_io_obuf # (
            .dccen(DCCEN)
         ) obuf (
            .i(pdiff_out_o),
            .o(o),
            .oe(pdiff_out_oe),
            .seriesterminationcontrol(),
            .parallelterminationcontrol(),
            .dynamicterminationcontrol(),
            .obar(),
            .devoe()
         );

         tennm_io_obuf # (
            .dccen(DCCEN)
         ) obuf_bar (
            .i(pdiff_out_obar),
            .o(obar),
            .oe(pdiff_out_oebar),
            .seriesterminationcontrol(),
            .parallelterminationcontrol(),
            .dynamicterminationcontrol(),
            .obar(),
            .devoe()
         );
      end
   endgenerate

endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "5CuDA+N0ipkxBbEFUigHJZjgKRBExUzGn9z/NRXk7X5L9zeYM+vdBVJ1f18yt+xMvY/22tVeb7s/H98agD+jK7YsarPT8vFtti1g/cmz8hXnwEr5xu5LhqSR+2HHb+em2Q3utiK6fTAx1ALvUZepSHwtTJ/aE66X1iGtlQu5tPocyrl5DTgTR40cmiiOLVMSsyIS5Ao4CrdifHzFPIRQUTo/6nxhwZ/xBegvjthbnPHIGdH69sXMn3+qFgePN5AN/nN2vVkc/d6UVFKB3ig9HAcZm+1PFXo2Vzj3CxqTAyLOM9VeVP+G6N9/Hd0FlnmskXWnBTMCRol+PdyFBeJkQJEq5u80iP6p1uGZ06V9iKEg1UGvJWi2y9yec2x7mgeF223dsuXqczK5FS06cWRfLP/eFbzmZ7HnDWIPoMGhUDIWPfgnb4K6qF4yQV5PNEyzsH3mWyYYfyFJY7Vj8xtrvIUsCQKMtBT3bYXQ3fQVqbuu3VIUXT1C+tTxV2dEoKM/pdxCzmn3vcvOM4px5siJB6O8nA8BBjFPqxyaTajS2LwcmtSMfUnxUSzsO2qVBj5HFdLJbXf7M04Ro461idGFUW2A95J0ci6VYwUZuhPIgNQzkWmQ9LbmX60lMeJsqcoQo//ObJ+33bg5zjSrwFb43bssPBIMn0aZ7IHijk1vBNCaxgwkWlnt/9xeOiRHGdPPSfwbOKrCXXrsqHXWP52o5u0yazQiRN9lD2MribmtKe/ovVT3yd83SXGU0AzMSSujE4I1jDpyeHSDGgbd+tZAYBGRu+NLTwuhGPSRfm8R/cm2PEwBje1cS1TtcN9ySdJ9GBL49/2GILkxOwiN3TkU4MSVoWgW1WZtZVpdv8ADjgQTKtly7Tq9ivuStZr0DfuxFU40G2wlQi941W3Hpf2LvXAemIFvASVK4RHwUkesULsAvKUU8QOLVzSnyey7NGBvWNitV1ZEiZZ6svQCwSF24kmObUnbCUq6VJrdRxKbwc2QFPChrhYwQDUIl4sUjulC"
`endif
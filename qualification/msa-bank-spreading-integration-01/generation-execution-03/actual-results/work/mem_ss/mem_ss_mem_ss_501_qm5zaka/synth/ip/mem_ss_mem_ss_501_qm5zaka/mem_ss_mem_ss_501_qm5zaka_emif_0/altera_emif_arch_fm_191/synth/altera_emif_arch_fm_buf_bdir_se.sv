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


module altera_emif_arch_fm_buf_bdir_se #(
   parameter OCT_CONTROL_WIDTH = 1,
   parameter HPRX_CTLE_EN = "off",
   parameter HPRX_OFFSET_CAL = "false",
   parameter CALIBRATED_OCT = 1
) (
   inout  tri   io,
   output logic ibuf_o,
   input  logic obuf_i,
   input  logic obuf_oe,
   input  logic obuf_dtc,
   input  logic oct_termin
);
   timeunit 1ns;
   timeprecision 1ps;
   
   generate
      if (CALIBRATED_OCT) 
      begin : cal_oct
         tennm_io_ibuf # (
            .hprx_ctle_en (HPRX_CTLE_EN),
            .hprx_offset_cal (HPRX_OFFSET_CAL)
         ) ibuf (
            .i(io),
            .o(ibuf_o),
            .term_in(oct_termin),
            .seriesterminationcontrol(),
            .parallelterminationcontrol(),
            .dynamicterminationcontrol(),
            .ibar()
            );
            
         tennm_io_obuf obuf (
            .i(obuf_i),
            .o(io),
            .oe(obuf_oe),
            .term_in(oct_termin),
            .dynamicterminationcontrol(obuf_dtc),
            .seriesterminationcontrol(),
            .parallelterminationcontrol(),
            .obar(),
            .devoe()
            );
      end else 
      begin : no_oct
         tennm_io_ibuf # (
            .hprx_ctle_en (HPRX_CTLE_EN),
            .hprx_offset_cal (HPRX_OFFSET_CAL)
         ) ibuf (
            .i(io),
            .o(ibuf_o),
            .seriesterminationcontrol(),
            .parallelterminationcontrol(),
            .dynamicterminationcontrol(),
            .ibar()
         );
            
         tennm_io_obuf obuf (
            .i(obuf_i),
            .o(io),
            .oe(obuf_oe),
            .dynamicterminationcontrol(),
            .seriesterminationcontrol(),
            .parallelterminationcontrol(),
            .obar(),
            .devoe()
            );      
      end
   endgenerate            
endmodule

`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "5CuDA+N0ipkxBbEFUigHJZjgKRBExUzGn9z/NRXk7X5L9zeYM+vdBVJ1f18yt+xMvY/22tVeb7s/H98agD+jK7YsarPT8vFtti1g/cmz8hXnwEr5xu5LhqSR+2HHb+em2Q3utiK6fTAx1ALvUZepSHwtTJ/aE66X1iGtlQu5tPocyrl5DTgTR40cmiiOLVMSsyIS5Ao4CrdifHzFPIRQUTo/6nxhwZ/xBegvjthbnPElHpJlNhxd++GpvdlJuI+wAcBgW7kF435ZtqZo3Mos43mUxYHS/tRpzFoow6nC78/KOosHoRRd8TVdwO5dnrU3NAP9Pue5aAf19i9/lkx1ePsfGVo5XluZgarO5phBoGFiE4oAdXZlxvFa9H2Hi1m3axZZlYck8wHXGh5Pz9g6Y1vBtCgtlJuy/o39cCSE7trRs0HEPpQgy2CTO1tFlnmDTQoXCG1sBmeezzlp6TWUkhFSLWuo+qoWg0PDjScHi4bUmH+BraeTaAlRQCbZf0mFBGud8jLnvwH3oMZnOLCxYJxc9LHAL1icXwxlJE6dp1AInGTDEDWR77ElTYUJ/X3IgDfgRaSYK7N76h4aXHblUB+k9+HqJ8iS+Euo/AgeDnLy8BJIibzQFXYenSD2c7Sc1suCvNS6tXigE/zAaH0Auu77moXPF1PISoNRRZeVIO64uOa18MDtBXCEGJkN8Z7iPBUJhNzaFhj3orubH+itonjI1tWAdg1YYbbPjyrK9nALyYaG4f+X+tYjA4WGAw90ZTfkjlwT6uDfAzaBs+S5tvYUucXCvPW8APoyZ18ZZZJDoDMJku96oh43tIV9NQ55DcHW1JGrhcnWdfxUyYrBazUwEDy647rL3r+P3bl4zgYIQ96BMd9bbiL524nBbPHJoH/7FiJAlr/WfswjqgOxYqnTu/jscORxars/HA4D1JFQJ8IVlU/NvFCytF+FsfnAjToVqDgXgVH0po11Tw5FEO2pkTs7L6+wwTTLt9mVtrW2faESw95wbrzKJ4jPpxAi"
`endif
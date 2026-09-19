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


module altera_emif_arch_fm_buf_udir_se_i #(
   parameter OCT_CONTROL_WIDTH = 1,
   parameter CALIBRATED_OCT = 1
) (
   input  logic i,
   input  logic oct_termin,
   output logic o
);
   timeunit 1ns;
   timeprecision 1ps;

   generate
      if (CALIBRATED_OCT) 
      begin : cal_oct
         tennm_io_ibuf ibuf(
            .i(i),
            .o(o),
            .term_in(oct_termin),
            .seriesterminationcontrol(),
            .parallelterminationcontrol(),
            .ibar(),
            .dynamicterminationcontrol()
            );    
      end else 
      begin : no_oct
         tennm_io_ibuf ibuf(
            .i(i),
            .o(o),
            .seriesterminationcontrol(),
            .parallelterminationcontrol(),
            .ibar(),
            .dynamicterminationcontrol()
            );
      end
   endgenerate
endmodule

`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "5CuDA+N0ipkxBbEFUigHJZjgKRBExUzGn9z/NRXk7X5L9zeYM+vdBVJ1f18yt+xMvY/22tVeb7s/H98agD+jK7YsarPT8vFtti1g/cmz8hXnwEr5xu5LhqSR+2HHb+em2Q3utiK6fTAx1ALvUZepSHwtTJ/aE66X1iGtlQu5tPocyrl5DTgTR40cmiiOLVMSsyIS5Ao4CrdifHzFPIRQUTo/6nxhwZ/xBegvjthbnPH1w23v7kpMaUq5S/xORmkfQu+hYHzbS0Pz+TRWqRrg8PQ/UaX7w8fZesvq5yg5x0cULvu8tSuLNbUfNsDkkgNQUdGqptcqJNcupZB8MhE/u/IznIEvlh2Kew78HF0wExnXmbO543ci/4GKqS43pFvG0bpGOvvPo04H3kDiXFmxbg8KqajLxHkME1UVrxJSN0Lvv2HkowZz7A5Oqys68KLs7486DeoT7lcDiUN5gdr8UUgleIGkfZOt6b+3QIk2h3zcfjAzoav2nyc2Um6Lybx1hO2wepK6pq3Ipp+VJK15BosXyReVWUUjh6Scq+mKENlbrR8GFP1YTm+pvfRglqbPa0CGMTHhuFW+P685MVNntja1Ds5rNOV6+MiuXKrywZmQgGljNn8F8rE7b4yFpMK6uigBLTEe5UBbyrlnpSDCQqUS6L1ex+8qkTVaTVObSlOGHtAjNwMHQozirHHYYOuZJKEgwUyWtkvVD/MqXX8cm+WDs9ynLMXL9X/TFwvakUMjCTTuvWcS/Om/k9SeLrvYBniDd+LpK6SAKoEpE5lDGDfNZCjhOYyK6U1txyd5ereqICX1JnuIDxsWCxrZYGrETxGoirnCjQQAl60SxIdG/33A8XtIm1l6fJpr1wSqZY+8BGn+dx1h1CO/YxmUHXXwLqNI4EKZT9L3nK89h/0SEE8kh9EFOm+GBiNXEz9RHMeXbbi9b3eOp6WazyaBtA5eAjZvAq5gA/TTi2Tw2dXCW3pd+Mn+LKMyD4dXNeZZpA3RsFxvEgTU+aFGToRfkdGG"
`endif
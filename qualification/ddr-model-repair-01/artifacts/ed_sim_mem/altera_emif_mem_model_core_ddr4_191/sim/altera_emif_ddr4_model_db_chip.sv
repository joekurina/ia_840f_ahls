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
// Basic simulation model of DDR4 Data Buffer used by LRDIMM
//
///////////////////////////////////////////////////////////////////////////////
module altera_emif_ddr4_model_db_chip (
   input       BCK_t,
   input       BCK_c,
   input       BCKE,
   input       BODT,
   input       BVrefCA,
   input [3:0] BCOM,

   inout [7:0] MDQ,
   inout       MDQS0_t,
   inout       MDQS0_c,
   inout       MDQS1_t,
   inout       MDQS1_c,

   inout [7:0] DQ,
   inout       DQS0_t,
   inout       DQS0_c,
   inout       DQS1_t,
   inout       DQS1_c,

   output      ALERT_n,

   input       VDD,
   input       VSS
);

   timeunit 1ps;
   timeprecision 1ps;

   genvar i;

   generate
      for (i = 0; i < 8; i = i + 1) begin : gen_dq_delay
         altera_emif_ddrx_model_bidir_delay #(
            .DELAY                         (1.0)
         ) inst_dq_bidir_dly (
            .porta                         (MDQ[i]),
            .portb                         (DQ[i])
         );
      end
   endgenerate

   altera_emif_ddrx_model_bidir_delay #(
      .DELAY                         (1.0)
   ) dqs_p_0 (
      .porta                         (MDQS0_t),
      .portb                         (DQS0_t)
   );

   altera_emif_ddrx_model_bidir_delay #(
      .DELAY                         (1.0)
   ) dqs_n_0 (
      .porta                         (MDQS0_c),
      .portb                         (DQS0_c)
   );

   altera_emif_ddrx_model_bidir_delay #(
      .DELAY                         (1.0)
   ) dqs_p_1 (
      .porta                         (MDQS1_t),
      .portb                         (DQS1_t)
   );

   altera_emif_ddrx_model_bidir_delay #(
      .DELAY                         (1.0)
   ) dqs_n_1 (
      .porta                         (MDQS1_c),
      .portb                         (DQS1_c)
   );

endmodule

`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "uirZUgR+XhYOLlgBF3/d0L4Bfzylk2P2x/KQ8QMumQbO6ajCo4YnVaEY8lBe27qGYMYJNZxW8Ae6UCiRVZDZWFYbs14nsOPa+otdwBpQQKZAXbBPWtLJwNF5/0elsLeeaJ5MlcBgoV3xrU5XPHmrPSXVtqmlBuurE9WqcXpeYLn9HFPxa/7UBC/LBkcozWh9FF38Q3E5pl2oKEZ8+zrJcjoiv6zOLVJVZaTUmibnN0Yt8KIq5aZ+5sKXNT+kVu8QOIDnXoONgOV7Ah6+hwPyjzgs066Jb3Htr7ZGjkLuMD/SUFcrKrYZcGo/niHfz9PzSyxlesKFdopgmKzCAwrcu1QvjrBf71q02LvLhHMCvoUwtkkskj64R7qh6jKRRUI4sJ1y0zYraHrB0VNWYlKOfDkBKCGKxxXBXiVs/cAE3P2Y4U8oL4pFyO+uTY81MU4BapnZzgjeLCmOazfp6UcheETg5z8obixKp4OdsabkVkmVd2hUCN29ZLgph8k8WRoJF6bIR085EVuzBF+GfbYQd1W3pJGS7kkEsLNYo7vdGP/su/FzBuQJiJyMDLetalt/769FTojifRdaHUcJuKqRlY7jXWGn+XOh30t2fWI9HPQ7bkT0zmOxonexjQ+Pk6Fq0+2gp1ptvFAsfpl+mm5+XocmrKJcSnZlAGQUd/dzlKE9mAq7uxsFCFe3zwP30We8M/kJDGGEYdd3xcPWLUGwb18i3sIl+ODv7UErOfDlCvV8sOIj1EB7dI04MiJ/1RKWbk+PszzIQVZm2Tft3viKR6m6jX6s3JCz1Bl0ESXLCDkRDVnYMecRJ5Y+5Vc6dRXjUCbJ69tv+C3XW5mrTLjzRDMvPh+OSx9XOZFhXX+Q6/EPmYjUUeFgfNE/L+PAUoCD0PKbo7bTLp0GgZQNainD0qX37dRS/MV5+eIUgPet7c4REyx70aR/Bi3P0QFZIgsoydX5GRDrgKQGfFaXqBeGcjSossw/4lElPfQZPWR0UARV7H311OoXi11ZQg4mcJ5d"
`endif
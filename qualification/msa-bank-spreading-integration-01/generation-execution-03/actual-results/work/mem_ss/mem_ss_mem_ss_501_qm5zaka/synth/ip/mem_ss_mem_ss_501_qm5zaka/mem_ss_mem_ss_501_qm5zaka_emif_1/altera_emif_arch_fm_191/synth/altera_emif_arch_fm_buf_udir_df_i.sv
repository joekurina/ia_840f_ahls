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


module altera_emif_arch_fm_buf_udir_df_i # (
   parameter OCT_CONTROL_WIDTH = 1,
   parameter CALIBRATED_OCT = 1
) (
   input  logic i,
   input  logic ibar,
   output logic o,
   input  logic oct_termin
);
   timeunit 1ns;
   timeprecision 1ps;
   
   generate
      if (CALIBRATED_OCT) 
      begin : cal_oct   
         tennm_io_ibuf  # (
            .differential_mode ("true")
         ) ibuf (
            .i(i),
            .ibar(ibar),
            .o(o),
            .term_in(oct_termin),
            .seriesterminationcontrol(),
            .parallelterminationcontrol(),
            .dynamicterminationcontrol()
            );
      end else 
      begin : no_oct
         tennm_io_ibuf  # (
            .differential_mode ("true")
         ) ibuf (
            .i(i),
            .ibar(ibar),
            .o(o),
            .seriesterminationcontrol(),
            .parallelterminationcontrol(),
            .dynamicterminationcontrol()
            );      
      end
   endgenerate      
endmodule

`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "5CuDA+N0ipkxBbEFUigHJZjgKRBExUzGn9z/NRXk7X5L9zeYM+vdBVJ1f18yt+xMvY/22tVeb7s/H98agD+jK7YsarPT8vFtti1g/cmz8hXnwEr5xu5LhqSR+2HHb+em2Q3utiK6fTAx1ALvUZepSHwtTJ/aE66X1iGtlQu5tPocyrl5DTgTR40cmiiOLVMSsyIS5Ao4CrdifHzFPIRQUTo/6nxhwZ/xBegvjthbnPFRKclM6j1c7YXOUUyfeTm8YZWf36obLanmF6Si7XAG+c/NOAQlVj+yVuDbg7CXjCaar1FKnYWKYvDB2ar/EV8RiJ1AdNWPy5e75hvvnyxrYsT+PR1PPT4SNY+Oy4EP+no47xRyjBQId3ZOyKUaK6EaRuA1LIu12puInEsLd/kxpHX8IGvkFkJKWup2Iz5+4liEYK2HYmA5KRVOp9HAiKtag6a0dNml+QUM6YrkblENsfo97py7uVhHkP82Gr3u60WCvIwOhZOPDc2wC/bELVugX5FcYkHmvRU8MxQgLOkU7LFacq/hvJBiUUvp7Wu0dniJEBn4HBQDr+T7Ej70bgHqpC/TlCLqqWwVX1ZPW+PhzzU9nE/JhFWJsIkirzZLtxgxeKo8nfye6fqeskoSJ/yaS4hlYmgYFIX950lwgWbrMq2lJWh+L4H93fo+eLhEtlsfDFHzJ7j8l2lYAZrpMMCyztVToBnDF9G1vACqreJzyMYLTbjWLwAOlsFcqdAQgo4ZPCxHt148Cr3gO7iej9eDUBuJ6C7QVgsfBGTCnsdpteGPPr/eUEFPMS2qhbSAIHtHHlh76oHnEk1S5g8oVkuMIGRFxMIFIR+WQYx9Dm/qyoeSLpjf6te6CKER7lkoEk29Wc0hBpNjeHZoEc0sx9c3LxbMjBy5SHMq1AtlNvvwSm+4YhPOz83zGbz/ypzqZL76pokW8uAC3nk+38t1i2W8ng544nVcHy+tfRfrCk0oqp5YcWmYCWiYx9aCnPCHlaHyVHeR37V1Xv0fGksHs4eE"
`endif
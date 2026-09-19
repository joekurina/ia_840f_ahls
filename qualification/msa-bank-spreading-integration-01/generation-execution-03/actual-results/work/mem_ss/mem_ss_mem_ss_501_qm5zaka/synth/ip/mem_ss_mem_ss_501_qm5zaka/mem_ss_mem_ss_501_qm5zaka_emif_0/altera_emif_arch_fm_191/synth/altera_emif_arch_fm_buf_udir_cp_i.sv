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


module altera_emif_arch_fm_buf_udir_cp_i # (
   parameter OCT_CONTROL_WIDTH = 1,
   parameter CALIBRATED_OCT = 1
) (
   input  logic i,
   input  logic ibar,
   output logic o,
   output logic obar,
   input  logic oct_termin
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
            .ibar(),
            .seriesterminationcontrol(),
            .parallelterminationcontrol(),
            .dynamicterminationcontrol()
            );
            
         tennm_io_ibuf ibuf_bar(
            .i(ibar),
            .o(obar),
            .term_in(oct_termin),
            .ibar(),
            .seriesterminationcontrol(),
            .parallelterminationcontrol(),
            .dynamicterminationcontrol()
            );
      end else 
      begin : no_oct
         tennm_io_ibuf ibuf(
            .i(i),
            .o(o),
            .ibar(),
            .seriesterminationcontrol(),
            .parallelterminationcontrol(),
            .dynamicterminationcontrol()
            );
            
         tennm_io_ibuf ibuf_bar(
            .i(ibar),
            .o(obar),
            .ibar(),
            .seriesterminationcontrol(),
            .parallelterminationcontrol(),
            .dynamicterminationcontrol()
            );      
      end
   endgenerate
endmodule

`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "5CuDA+N0ipkxBbEFUigHJZjgKRBExUzGn9z/NRXk7X5L9zeYM+vdBVJ1f18yt+xMvY/22tVeb7s/H98agD+jK7YsarPT8vFtti1g/cmz8hXnwEr5xu5LhqSR+2HHb+em2Q3utiK6fTAx1ALvUZepSHwtTJ/aE66X1iGtlQu5tPocyrl5DTgTR40cmiiOLVMSsyIS5Ao4CrdifHzFPIRQUTo/6nxhwZ/xBegvjthbnPGrIy1PbiH+iqD98yJjWgiY76sMyuIoe6q4xI5KxBIbAr2A0gCoK5eBr6Z+Wk5eetiKjxv/P60a3X/973vGSiV/9Fxx6QNNm6m+7JN03Y1yiWfKaie5MH0ugELpx1pDBCm2sJq3qD3j41K4f72dQQUXRzrj0vFLhu1dGMYyjkE9LwSrit9si+QkBqPwO9f5bLfXoPZTL356tdBEhzRjxXwmea8s51auvtUgiKUPZmDWyFYzBPpnjQ+a1JeSj+KcGDgFvsv+9DGGJVNAZfM/xi/XT3QTM6J82rJ383JqBIjcEaPz1S68Rd8dj2EbXkhSVnA2g1wdZDvDKYPIqNNMwSTw21ZUsGKHi2SXIFvxiRzyXn9t0kjyhDeBLre47Fr8OroZ/OrDKDU7kUbxfDDBKlleZrPT3+n9U8o21GsP71N78wG1e7pPHBqQEZyAzLBhEjb3iDkTXekniEzxdh4pA6TWszr8JlNyxia0eo3H/MrNS1trd7sjulzRodBvxXBOGD9aerX9lvVQ6dZbSnwuDT0xdskm+X8bo7lmn3kd7uRyYhr8RimBg1XswGyo7jcy27JdgyozhPc25+IRMe3BTCOEbDyKZYuBzBJq5SZ8lgOMr+0D6CooXlp7hZz+isPpQ9txWjYyeMDlCVKPqz7nWvMpErCl919x54LvPke+NvB606VI8S1/K52J1jUYREnqr+Tp2iOv3/sY3qE9GwhoAndmiG+IU1XrDf+0vdeVbFRvaeiDjEJUdwbWllhvNh3M7F0xzXJ4+9Dq+nzJ51Xviejd"
`endif
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




module altera_emif_arch_fm_hmc_mmr_if #(

   parameter PORT_CTRL_MMR_SLAVE_ADDRESS_WIDTH             = 1,
   parameter PORT_CTRL_MMR_SLAVE_RDATA_WIDTH               = 1,
   parameter PORT_CTRL_MMR_SLAVE_WDATA_WIDTH               = 1,
   parameter PORT_CTRL_MMR_SLAVE_BCOUNT_WIDTH              = 1
) (
   input  logic [33:0]                                        ctl2core_mmr_0,
   output logic [50:0]                                        core2ctl_mmr_0,
   input  logic [33:0]                                        ctl2core_mmr_1,
   output logic [50:0]                                        core2ctl_mmr_1,

   input  logic                                               emif_usr_clk,
   
   output logic                                               mmr_slave_waitrequest_0,
   input  logic                                               mmr_slave_read_0,
   input  logic                                               mmr_slave_write_0,
   input  logic [PORT_CTRL_MMR_SLAVE_ADDRESS_WIDTH-1:0]       mmr_slave_address_0,
   output logic [PORT_CTRL_MMR_SLAVE_RDATA_WIDTH-1:0]         mmr_slave_readdata_0,
   input  logic [PORT_CTRL_MMR_SLAVE_WDATA_WIDTH-1:0]         mmr_slave_writedata_0,
   input  logic [PORT_CTRL_MMR_SLAVE_BCOUNT_WIDTH-1:0]        mmr_slave_burstcount_0,
   input  logic                                               mmr_slave_beginbursttransfer_0,
   output logic                                               mmr_slave_readdatavalid_0,
   
   output logic                                               mmr_slave_waitrequest_1,
   input  logic                                               mmr_slave_read_1,
   input  logic                                               mmr_slave_write_1,
   input  logic [PORT_CTRL_MMR_SLAVE_ADDRESS_WIDTH-1:0]       mmr_slave_address_1,
   output logic [PORT_CTRL_MMR_SLAVE_RDATA_WIDTH-1:0]         mmr_slave_readdata_1,
   input  logic [PORT_CTRL_MMR_SLAVE_WDATA_WIDTH-1:0]         mmr_slave_writedata_1,
   input  logic [PORT_CTRL_MMR_SLAVE_BCOUNT_WIDTH-1:0]        mmr_slave_burstcount_1,
   input  logic                                               mmr_slave_beginbursttransfer_1,
   output logic                                               mmr_slave_readdatavalid_1   
);
   timeunit 1ns;
   timeprecision 1ps;
   
   assign core2ctl_mmr_1[13:10]      = 'b0;
   assign core2ctl_mmr_0[13:10]      = 'b0;

   always_ff @(posedge emif_usr_clk) begin
      core2ctl_mmr_0[9:0]        <= mmr_slave_address_0;
      core2ctl_mmr_0[45:14]      <= mmr_slave_writedata_0;
      core2ctl_mmr_0[46]         <= mmr_slave_write_0;
      core2ctl_mmr_0[47]         <= mmr_slave_read_0;
      core2ctl_mmr_0[49:48]      <= mmr_slave_burstcount_0;
      core2ctl_mmr_0[50]         <= mmr_slave_beginbursttransfer_0;
      
      mmr_slave_readdata_0       <= ctl2core_mmr_0[31:0];
      mmr_slave_readdatavalid_0  <= ctl2core_mmr_0[32];
      mmr_slave_waitrequest_0    <= ctl2core_mmr_0[33];

      core2ctl_mmr_1[9:0]        <= mmr_slave_address_1;
      core2ctl_mmr_1[45:14]      <= mmr_slave_writedata_1;
      core2ctl_mmr_1[46]         <= mmr_slave_write_1;
      core2ctl_mmr_1[47]         <= mmr_slave_read_1;
      core2ctl_mmr_1[49:48]      <= mmr_slave_burstcount_1;
      core2ctl_mmr_1[50]         <= mmr_slave_beginbursttransfer_1;
      
      mmr_slave_readdata_1       <= ctl2core_mmr_1[31:0];
      mmr_slave_readdatavalid_1  <= ctl2core_mmr_1[32];
      mmr_slave_waitrequest_1    <= ctl2core_mmr_1[33];
   end
   
endmodule

`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "5CuDA+N0ipkxBbEFUigHJZjgKRBExUzGn9z/NRXk7X5L9zeYM+vdBVJ1f18yt+xMvY/22tVeb7s/H98agD+jK7YsarPT8vFtti1g/cmz8hXnwEr5xu5LhqSR+2HHb+em2Q3utiK6fTAx1ALvUZepSHwtTJ/aE66X1iGtlQu5tPocyrl5DTgTR40cmiiOLVMSsyIS5Ao4CrdifHzFPIRQUTo/6nxhwZ/xBegvjthbnPH7B0zT1XxW3GM+crYgPz0JGKGNx0qRQjUiN57uSgea7CjoQEeDmHsq7ujVXGjJc8S/Db6bFIfH2vfSOF4Fn1O5l0ETLeg45vcQnbrsLIcwJkbh/7deenOpmgT43qtGn6yw0noOsGlpDZa9koKc//JMLf4FH4qA/U8I1d+ANYxY7T01HwFDwcd74zcqAJN5pNGzOfnYutjUrJC9D2VoiDwSOX46ukTdhtpy1sXoFb4Ne0YwwDX5qrvk57WM6sJiMPhGaWbOG9CF7l6AXB+XqYSvZg4jhIjqmnQZZG0S3VoLP4d+OH8yMSpAtJ0Bz6MGEh/SlcCt9LmCWWDkv2nc5XxnHQAANUk5f5bn9KMMSJdvmENEK1dgNBdX9OmR34p/4R02Bz49rrIIY8kKtsmrBPZTnfZ4O/aIoV+mgyqfWlBJ71JLX8B592U3bYadUXyOD2N1Ilj3QiZHUX58VTb2miULGLHZWK1kJeTsiuYdBykMIosFJTiHpdfiOyg6TNnYBkR9t01UdHIE33Nycxin46LnQbZ55xqMUGg0v+avd6vWX8Wb0MkRGNybo7jIrvetakzaVLtPdPnmhQ4/ZTNspIXUyK/K5J5/uOTgqvkssb9soeYPZZBgOxNMDHl6IMY/uArFMxvMmMdPdjYobbXlQkNbzNm8wjJKxn0nIU6QVx+3KgeEvEq2I3ADIT6JOvoSQFHzc1IqvcqgDIYaGhZLXzX4tyKu924DxiEWaDv+OLP3lIiCugZ2WpjYKnvreMjhRUbwLM7AgioPeSVhxkPAzfnG"
`endif
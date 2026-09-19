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


module altera_emif_ddrx_model_bidir_delay
#(
   parameter DELAY = 2.0
) (
   inout porta,
   inout portb
);
   timeunit 1ps;
   timeprecision 1ps;

   reg porta_dly;
   reg portb_dly;

   initial begin
      porta_dly = 1'bz;
      portb_dly = 1'bz;
   end

   always @(porta) begin
      if (portb_dly === 1'bz || porta === 1'bz) begin
         porta_dly <= #DELAY porta;
      end
   end

   always @(portb) begin
      if (porta_dly === 1'bz || portb === 1'bz) begin
         portb_dly <= #DELAY portb;
      end
   end

   assign porta = portb_dly;
   assign portb = porta_dly;
endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "uirZUgR+XhYOLlgBF3/d0L4Bfzylk2P2x/KQ8QMumQbO6ajCo4YnVaEY8lBe27qGYMYJNZxW8Ae6UCiRVZDZWFYbs14nsOPa+otdwBpQQKZAXbBPWtLJwNF5/0elsLeeaJ5MlcBgoV3xrU5XPHmrPSXVtqmlBuurE9WqcXpeYLn9HFPxa/7UBC/LBkcozWh9FF38Q3E5pl2oKEZ8+zrJcjoiv6zOLVJVZaTUmibnN0ahfiC1NICS1VOIOabzhMmNORb0HqcrGCTsVCGuVyKTVom2ou1hzKs/wY2A/LFGlQbGJiJS6s4MrmAuX1OYzQzITQ6uIw7x/1L+CGSMDJsBvn2ETz++knFutUUNuup3/S8O63vpSSb2kNkQ3wi9gPWEPkJUUVX1Q060DgRZLznHJE8hJax54G7PcXOTQIFqF6VdI9v8m17IpVgOm8nhETx8ngkbdplk7nPWhiVk7clSMtqe9UzLbbc1Wi5VZ+NDswWoMi3hLasiDx5CgsqRCu+ik13qnfJ4PAjtcMQivtRLjT1kg4sPTNbXfGohayyytv5cgBba+IO3I3vk+VOU+03gHsRrZN4ekpn3sSy/HA6qemBfv2ZHHyOBgu3DaI8Vp+2OIlCgt1G+69jlIGHF+n0anS1N3NLrKIYjSuAmNokBcyzg6OViRRKs84FHqhhfqgFTzxtypttA0g6DRJo2xzCaEJBeQpPEzZAUTz3LNA+gseH/M99iiVgq1RcrS7lHEz6zd/nJ4YljSpbBdU/v7Hs8DqS/X2aVRwcDbv4qEBy8HyD7EQt/Jdc9TPNbuMW258LASsy8gZhHmaie/6Ajp0YeixBmZRlzINRskqRGesPSdphSQVtIiHpdaFxLn4KMZmDXB8Qtwa/dynoynExA1bGCGsqvSn9gxBtshhfwMijw19WpWhT0vsFIqk4U4RKuequp2CUe/n/3K48L1LSODk92Y0RjSQSLujKZtzwvL2cdnacvZlPqIbH7GkPLF7E/FdR57i2XT0jRvTe4JYAQF8Re"
`endif
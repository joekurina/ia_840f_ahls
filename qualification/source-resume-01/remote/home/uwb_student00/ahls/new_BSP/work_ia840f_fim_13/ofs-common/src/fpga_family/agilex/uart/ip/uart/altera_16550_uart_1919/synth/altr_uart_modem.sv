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


//
//Modem Control and Status Block
//This block will contain purely inverters
//
`timescale 1 ps / 1 ps
module altr_uart_modem (

   input  sin_i_pre,
   output sin_i,

   input  sout_pre,
   output sout,

   input  sout_oe_pre,
   output sout_oe,

   input  cts_i_n,
   output msr_cts,
   output msr_dcts_source,

   input  dsr_i_n,
   output msr_dsr,
   output msr_ddsr_source,

   input  dcd_i_n,
   output msr_dcd,
   output msr_ddcd_source,

   input  ri_i_n,
   output msr_ri,
   output msr_teri_source,

   input  rts,
   output rts_n,

   input  mcr_dtr,
   output dtr_n,

   input  mcr_out1,
   output out1_n,

   input  mcr_out2,
   output out2_n,

   input  mcr_loopback
   
);

//MSR Inputs
assign sin_i   = (mcr_loopback) ? sout_pre : sin_i_pre;

assign msr_dsr = (mcr_loopback) ? mcr_dtr  : ~dsr_i_n;

assign msr_cts = (mcr_loopback) ? rts      : ~cts_i_n;

assign msr_ri  = (mcr_loopback) ? mcr_out1 : ~ri_i_n;

assign msr_dcd = (mcr_loopback) ? mcr_out2 : ~dcd_i_n;

//Delta of various MSR bits
assign msr_dcts_source = msr_cts;
assign msr_ddsr_source = msr_dsr;
assign msr_ddcd_source = msr_dcd;
assign msr_teri_source = msr_ri;

//MCR Outputs
assign sout    = (mcr_loopback) ? 1'b1 : sout_pre;

assign sout_oe = (mcr_loopback) ? 1'b0 : sout_oe_pre;

assign dtr_n   = (mcr_loopback) ? 1'b1 : ~mcr_dtr;

assign rts_n   = (mcr_loopback) ? 1'b1 : ~rts;

assign out1_n  = (mcr_loopback) ? 1'b1 : ~mcr_out1;

assign out2_n  = (mcr_loopback) ? 1'b1 : ~mcr_out2;


endmodule: altr_uart_modem
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "AKY/VDqroC56S5zYqI2FH+pDtMm2XXjvzWe8rGJiybS03yo4KNBMg81pmtWbHVIPiTA81zIuGQJqb5vOIzimr/z+D85S4Jjtk9u3+kDOlkJUsrbYjDeARoR1d2Gy20nZHckh8FGW+dSF0ir+jochMyts2Y//A4WlmCaB7gD83g5rkI4jT1ldDhtPnUUhGKawcEehCEezQ12Toa+YG3kf1PWegnVnp6lxL1nZ0P1Qzo83d0/qv0KeEfzqtDaJt3bDIkNsztjbFnfRqB6T3T+IVMC0QIza+8nFnIfr014Wa/BFEOwBsuakJKbXEOGcQQTE8KnXF0Rnti+ClmnS2bc6R7/K+MZHDdn6KKbXQxq6C1NMMmuGa8OwRyJEWazR6i4748R+3MyCBjPEzN3qumJBjjI60pVBSIxnfNvT0Psl6tccVEB2QLDPzdNCCSr7XiCJhG6iQkdg7pDfpmWZUK8YOn5OlFAgNfPXCEnqp1KCBVSvgdtpNyV+vDtIi4jc9QoRw5FdfdSNTQlcew1xC34poj9Qg0yx0zXkiqeLBa8SYIqWo+Q6Q/IsZ4Bh+FcIAIYG06Vsfh1srXk3NK8yG07jrdexkTxp1+NskHijYWznAh/FqIQtOG8YzDSE1tff+PgHwexQpmjQa9+9op5iGxAl3eTtkI3udc6quiYYmgfDpwRaLgPNxCee1u/1qt0AKBs3k/vQC14hQOiMzO8B3K/0rQJdBRlAtEjaL+fne41rpTdEGLewAxA+s+/gcRl2alzdHY10SjEnNKjWM7VjXA8a09DTuHHLpRSQb/UbHg/JTn9Ejoj0ndxLkbOgPeiVc633qHYSvGpJXSdWAxSD6nuJWK2+Mr895TgGE4sXg4lxvhsEflPFzjGFJI78zIdYEZFNaUOB4LqS2pcYZxnOCB2CeiYecIUwr8BKl9sVeEqaog7YPypDlCLDIsma8M+/zADQ1VkrleTwpZuMO7ZesEMM2Kcao7RCmLin66kls4kcLYrn+r5zXJlSRQzAdV1z30ta"
`endif
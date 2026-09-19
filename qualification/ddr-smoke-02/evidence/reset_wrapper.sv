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
// Memory Subsystem reset controller. This is meant to be instantiated by the
// Memory Subsystem IP.
//
// The component exposes the standard subsystem reset interface (consisting of
// app_ss_rst_req, ss_app_rst_rdy, app_ss_cold_rst_n, ss_app_cold_rst_ack_n) to user logic,
// and forwards the reset requests to the individual QHIPs within the memory subsystem.
// Ex: for EMIF via the EMIF's reset interface (consisting of local_reset_req and
// local_reset_done).
//
///////////////////////////////////////////////////////////////////////////////

module mem_ss_mem_ss_501_qm5zaka_mem_reset_ctrl_mem_ss_reset_ctrl_201_pb3fzui # (
   parameter NUM_FM_EMIF = 1,
   parameter NUM_FP_HBM = 1
) (
   // Reset interface for FM EMIFs

   output logic local_reset_req_0,
   input  logic local_reset_done_0,

   output logic local_reset_req_1,
   input  logic local_reset_done_1,

   // Clk/reset for this reset controller

   input  logic clk,
   input  logic reset_n,

   // Subsystem reset interface exposed to user

   input  logic app_ss_rst_req,
   output logic ss_app_rst_rdy,

   input  logic app_ss_cold_rst_n,
   output logic ss_app_cold_rst_ack_n
);
   timeunit 1ns;
   timeprecision 1ps;

   // Pack into an array for convenience
   logic [NUM_FM_EMIF-1:0] local_reset_req;
   logic [NUM_FM_EMIF-1:0] local_reset_done;

   always_comb begin
      // FM EMIF reset interface
      local_reset_req_0 = local_reset_req[0]; local_reset_done[0] = local_reset_done_0;
      local_reset_req_1 = local_reset_req[1]; local_reset_done[1] = local_reset_done_1;
   end

   // The actual reset controller implementation
   mem_ss_reset_ctrl_impl # (
      .NUM_FM_EMIF   (2)
   ) reset_ctrl_impl (
      .clk                    (clk),
      .reset_n                (reset_n),

      .app_ss_rst_req         (app_ss_rst_req),
      .ss_app_rst_rdy         (ss_app_rst_rdy),
      .app_ss_cold_rst_n      (app_ss_cold_rst_n),
      .ss_app_cold_rst_ack_n  (ss_app_cold_rst_ack_n),

      .local_reset_req        (local_reset_req),
      .local_reset_done       (local_reset_done)
   );

endmodule



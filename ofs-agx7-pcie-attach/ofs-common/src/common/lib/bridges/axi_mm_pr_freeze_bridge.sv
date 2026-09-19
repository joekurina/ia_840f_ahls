// Copyright 2020 Intel Corporation
// SPDX-License-Identifier: MIT

// Description
//-----------------------------------------------------------------------------
//
// AXI MM PR Freeze bridge 
// should be instantiated in static region directly in front of the PR region
// 
//-----------------------------------------------------------------------------

`timescale 1 ps / 1 ps
module axi_mm_pr_freeze_bridge #(
    // Number of pipeline stage
    parameter NUM_PIPELINES = 1,
    // AW channel register type
    // 0 for skid buffer, , 1 for simple buffer, 2 to bypass
    parameter AW_REG_MODE = 1,
    // W channel register type
    // 0 for skid buffer, , 1 for simple buffer, 2 to bypass
    parameter W_REG_MODE = 2,
    // B channel register type
    // 0 for skid buffer, , 1 for simple buffer, 2 to bypass
    parameter B_REG_MODE = 1,
    // AR channel register type
    // 0 for skid buffer, , 1 for simple buffer, 2 to bypass
    parameter AR_REG_MODE = 1,
    // R channel register type
    // 0 for skid buffer, , 1 for simple buffer, 2 to bypass
    parameter R_REG_MODE = 2,

    // 0 - Uses pr_freeze signal
    // 1 - Doesn't use pr_freeze signal
    parameter PR_FREEZE_DIS = 0,
    
    // Width of ID signal
    parameter ID_WIDTH = 9,
    // Width of address signal
    parameter ADDR_WIDTH = 32,
    // Width of data signal
    parameter DATA_WIDTH = 256,
    
    // --------------------------------------
    // Derived parameters
    // --------------------------------------
    // Width of wstrb signal on write data channel
    parameter WSTRB_WIDTH = (DATA_WIDTH/8-1)
)(
   input logic afu_reset,
   input logic pr_freeze,
   ofs_fim_emif_axi_mm_if.user     m_if, 
   ofs_fim_emif_axi_mm_if.emif     s_if  
);
   // Create dummy interface to insert freeze logic on 
   // outbound valid signals
   ofs_fim_emif_axi_mm_if #(
      .AWID_WIDTH   ($bits(m_if.awid)),
      .AWADDR_WIDTH ($bits(m_if.awaddr)),
      .AWUSER_WIDTH ($bits(m_if.awuser)),
      .WDATA_WIDTH  ($bits(m_if.wdata)),
      .WUSER_WIDTH  ($bits(m_if.wuser)),
      .BUSER_WIDTH  ($bits(m_if.buser)),
      .ARID_WIDTH   ($bits(m_if.arid)),
      .ARADDR_WIDTH ($bits(m_if.araddr)),
      .ARUSER_WIDTH ($bits(m_if.aruser)),
      .RDATA_WIDTH  ($bits(m_if.rdata)),
      .RUSER_WIDTH  ($bits(m_if.ruser)) 
   ) axi_mm_if[0:NUM_PIPELINES](); 

   logic                     pr_freeze_wire; 
   logic 		     afu_mem_rst_n;

   // combine afu_reset & emif reset in afu mem if
   assign afu_mem_rst_n = m_if.rst_n & !afu_reset;

   // Reset flop
   always_ff @ (posedge s_if.clk) begin
      s_if.rst_n <= afu_mem_rst_n;
   end

   generate 
   if (PR_FREEZE_DIS == 1) begin
       assign pr_freeze_wire = 0;
   end else begin
       assign pr_freeze_wire = pr_freeze;
   end
   endgenerate

   always_comb begin
      s_if.clk      = m_if.clk;
   
      // Master interface
      // Write address channel
      // Inputs
      axi_mm_if[NUM_PIPELINES].awready   = m_if.awready;
      // Outputs
      m_if.awid           = axi_mm_if[NUM_PIPELINES].awid;
      m_if.awaddr         = axi_mm_if[NUM_PIPELINES].awaddr;
      m_if.awlen          = axi_mm_if[NUM_PIPELINES].awlen;
      m_if.awsize         = axi_mm_if[NUM_PIPELINES].awsize;
      m_if.awburst        = axi_mm_if[NUM_PIPELINES].awburst;
      m_if.awlock         = axi_mm_if[NUM_PIPELINES].awlock;
      m_if.awcache        = axi_mm_if[NUM_PIPELINES].awcache;
      m_if.awprot         = axi_mm_if[NUM_PIPELINES].awprot;
      m_if.awuser         = axi_mm_if[NUM_PIPELINES].awuser;
      m_if.awqos          = axi_mm_if[NUM_PIPELINES].awqos;
      m_if.awvalid        = axi_mm_if[NUM_PIPELINES].awvalid;
      // Disable during PR
      //m_if.awvalid        = (pr_freeze_wire) ? '0 : axi_mm_if[NUM_PIPELINES].awvalid;
                   
      // Write data channel
      // Inputs
      axi_mm_if[NUM_PIPELINES].wready   = m_if.wready;
      // Outputs
      m_if.wdata          = axi_mm_if[NUM_PIPELINES].wdata;
      m_if.wstrb          = axi_mm_if[NUM_PIPELINES].wstrb;
      m_if.wlast          = axi_mm_if[NUM_PIPELINES].wlast;
      m_if.wuser          = axi_mm_if[NUM_PIPELINES].wuser;
      m_if.wvalid         = axi_mm_if[NUM_PIPELINES].wvalid;
      // Disable during PR
      //m_if.wvalid         = (pr_freeze_wire) ? '0 : axi_mm_if[NUM_PIPELINES].wvalid;
                   
      // Write response channel
      // Outputs
      m_if.bready       = axi_mm_if[NUM_PIPELINES].bready;
      // drain responses during PR
      //m_if.bready       = (pr_freeze_wire) ? 1'b1 : axi_mm_if[NUM_PIPELINES].bready;
      // Inputs
      axi_mm_if[NUM_PIPELINES].bvalid  = m_if.bvalid;
      axi_mm_if[NUM_PIPELINES].bid     = m_if.bid;
      axi_mm_if[NUM_PIPELINES].bresp   = m_if.bresp;
      axi_mm_if[NUM_PIPELINES].buser   = m_if.buser;
                                   
      // Read address channel    
      // Inputs
      axi_mm_if[NUM_PIPELINES].arready =  m_if.arready;
      // Outputs
      m_if.arid          = axi_mm_if[NUM_PIPELINES].arid;
      m_if.araddr        = axi_mm_if[NUM_PIPELINES].araddr;
      m_if.arlen         = axi_mm_if[NUM_PIPELINES].arlen;
      m_if.arsize        = axi_mm_if[NUM_PIPELINES].arsize;
      m_if.arburst       = axi_mm_if[NUM_PIPELINES].arburst;
      m_if.arlock        = axi_mm_if[NUM_PIPELINES].arlock;
      m_if.arcache       = axi_mm_if[NUM_PIPELINES].arcache;
      m_if.arprot        = axi_mm_if[NUM_PIPELINES].arprot;
      m_if.aruser        = axi_mm_if[NUM_PIPELINES].aruser;
      m_if.arqos         = axi_mm_if[NUM_PIPELINES].arqos;
      m_if.arvalid       = axi_mm_if[NUM_PIPELINES].arvalid;
      // Disable during PR
      //m_if.arvalid       = (pr_freeze_wire) ? '0 : axi_mm_if[NUM_PIPELINES].arvalid;

      // Read response channel
      // Outputs
      m_if.rready         = axi_mm_if[NUM_PIPELINES].rready;
      // drain responses during PR
      //m_if.rready         = (pr_freeze_wire) ? 1'b1 : axi_mm_if[NUM_PIPELINES].rready;
      // Inputs
      axi_mm_if[NUM_PIPELINES].rvalid    = m_if.rvalid;
      axi_mm_if[NUM_PIPELINES].rid       = m_if.rid;
      axi_mm_if[NUM_PIPELINES].rdata     = m_if.rdata;
      axi_mm_if[NUM_PIPELINES].rresp     = m_if.rresp;
      axi_mm_if[NUM_PIPELINES].rlast     = m_if.rlast;
      axi_mm_if[NUM_PIPELINES].ruser     = m_if.ruser;
 end

   always_comb begin
      // Slave interface
      // Write address channel
      // Outputs
      s_if.awready          = axi_mm_if[0].awready;
      // Inputs
      axi_mm_if[0].awid     = s_if.awid;
      axi_mm_if[0].awaddr   = s_if.awaddr;
      axi_mm_if[0].awlen    = s_if.awlen;
      axi_mm_if[0].awsize   = s_if.awsize;
      axi_mm_if[0].awburst  = s_if.awburst;
      axi_mm_if[0].awlock   = s_if.awlock;
      axi_mm_if[0].awcache  = s_if.awcache;
      axi_mm_if[0].awprot   = s_if.awprot;
      axi_mm_if[0].awuser   = s_if.awuser;
      axi_mm_if[0].awqos    = s_if.awqos;
      // Disable during PR
      axi_mm_if[0].awvalid  = (pr_freeze_wire) ? '0 : s_if.awvalid;
                   
      // Write data channel
      // Outputs
      s_if.wready           = axi_mm_if[0].wready;
      // Inputs
      axi_mm_if[0].wdata    = s_if.wdata;
      axi_mm_if[0].wstrb    = s_if.wstrb;
      axi_mm_if[0].wlast    = s_if.wlast;
      axi_mm_if[0].wuser    = s_if.wuser;
      // Disable during PR
      axi_mm_if[0].wvalid   = (pr_freeze_wire) ? '0 : s_if.wvalid;
                   
      // Write response channel
      // Inputs
      axi_mm_if[0].bready   = (pr_freeze_wire) ? 1'b1 : s_if.bready;
      // drain responses during PR
      // Outputs
      s_if.bvalid           = axi_mm_if[0].bvalid;
      s_if.bid              = axi_mm_if[0].bid;
      s_if.bresp            = axi_mm_if[0].bresp;
      s_if.buser            = axi_mm_if[0].buser;
                                   
      // Read address channel    
      // Outputs
      s_if.arready          = axi_mm_if[0].arready;
      // Inputs
      axi_mm_if[0].arid     = s_if.arid;
      axi_mm_if[0].araddr   = s_if.araddr;
      axi_mm_if[0].arlen    = s_if.arlen;
      axi_mm_if[0].arsize   = s_if.arsize;
      axi_mm_if[0].arburst  = s_if.arburst;
      axi_mm_if[0].arlock   = s_if.arlock;
      axi_mm_if[0].arcache  = s_if.arcache;
      axi_mm_if[0].arprot   = s_if.arprot;
      axi_mm_if[0].aruser   = s_if.aruser;
      axi_mm_if[0].arqos    = s_if.arqos;
      // Disable during PR
      axi_mm_if[0].arvalid  = (pr_freeze_wire) ? '0 : s_if.arvalid;

      // Read response channel
      // Inputs
      // drain responses during PR
      axi_mm_if[0].rready   = (pr_freeze_wire) ? 1'b1 : s_if.rready;
      // Outputs
      s_if.rvalid           = axi_mm_if[0].rvalid;
      s_if.rid              = axi_mm_if[0].rid;
      s_if.rdata            = axi_mm_if[0].rdata;
      s_if.rresp            = axi_mm_if[0].rresp;
      s_if.rlast            = axi_mm_if[0].rlast;
      s_if.ruser            = axi_mm_if[0].ruser;
   end


   generate
   for (genvar i = 0; i < NUM_PIPELINES; i++) begin : axi_register
 
   axi_register #(
      .RDATA_WIDTH   (DATA_WIDTH),
      .WDATA_WIDTH   (DATA_WIDTH),
      .AWADDR_WIDTH  (ADDR_WIDTH),
      .ARADDR_WIDTH  (ADDR_WIDTH),
      .AWID_WIDTH    (ID_WIDTH),
      .ARID_WIDTH    (ID_WIDTH),
      .ENABLE_AWUSER (1),
      .AWUSER_WIDTH  ($bits(s_if.awuser)),
      .ENABLE_WUSER  (1),
      .WUSER_WIDTH   ($bits(s_if.wuser)),
      .ENABLE_BUSER  (1),
      .BUSER_WIDTH   ($bits(s_if.buser)),
      .ENABLE_ARUSER (1),
      .ARUSER_WIDTH  ($bits(s_if.aruser)),
      .ENABLE_RUSER  (1),
      .RUSER_WIDTH   ($bits(s_if.ruser)),
      .AW_REG_MODE   (AW_REG_MODE),
      .W_REG_MODE    (W_REG_MODE),
      .B_REG_MODE    (B_REG_MODE),
      .AR_REG_MODE   (AR_REG_MODE),
      .R_REG_MODE    (R_REG_MODE) 
    ) axi_axi_register_inst (
       .clk        (s_if.clk),
       .rst_n      (s_if.rst_n),
       // slave input interface
       .s_awready  (axi_mm_if[i].awready),
       .s_awvalid  (axi_mm_if[i].awvalid),
       .s_awid     (axi_mm_if[i].awid),
       .s_awaddr   (axi_mm_if[i].awaddr),
       .s_awlen    (axi_mm_if[i].awlen),
       .s_awsize   (axi_mm_if[i].awsize),
       .s_awburst  (axi_mm_if[i].awburst),
       .s_awlock   (axi_mm_if[i].awlock),
       .s_awcache  (axi_mm_if[i].awcache),
       .s_awprot   (axi_mm_if[i].awprot),
       .s_awqos    (axi_mm_if[i].awqos),
       .s_awregion ('0),
       .s_awuser   (axi_mm_if[i].awuser),
       .s_wready   (axi_mm_if[i].wready),
       .s_wvalid   (axi_mm_if[i].wvalid),
       .s_wdata    (axi_mm_if[i].wdata),
       .s_wstrb    (axi_mm_if[i].wstrb),
       .s_wlast    (axi_mm_if[i].wlast),
       .s_wuser    (axi_mm_if[i].wuser),
       .s_bready   (axi_mm_if[i].bready),
       .s_bvalid   (axi_mm_if[i].bvalid),
       .s_bid      (axi_mm_if[i].bid),
       .s_bresp    (axi_mm_if[i].bresp),
       .s_buser    (axi_mm_if[i].buser),
       .s_arready  (axi_mm_if[i].arready),
       .s_arvalid  (axi_mm_if[i].arvalid),
       .s_arid     (axi_mm_if[i].arid),
       .s_araddr   (axi_mm_if[i].araddr),
       .s_arlen    (axi_mm_if[i].arlen),
       .s_arsize   (axi_mm_if[i].arsize),
       .s_arburst  (axi_mm_if[i].arburst),
       .s_arlock   (axi_mm_if[i].arlock),
       .s_arcache  (axi_mm_if[i].arcache),
       .s_arprot   (axi_mm_if[i].arprot),
       .s_arqos    (axi_mm_if[i].arqos),
       .s_arregion ('0),
       .s_aruser   (axi_mm_if[i].aruser),
       .s_rready   (axi_mm_if[i].rready),
       .s_rvalid   (axi_mm_if[i].rvalid),
       .s_rid      (axi_mm_if[i].rid),
       .s_rdata    (axi_mm_if[i].rdata),
       .s_rresp    (axi_mm_if[i].rresp),
       .s_rlast    (axi_mm_if[i].rlast),
       .s_ruser    (axi_mm_if[i].ruser),

       // master output interface
       .m_awready  (axi_mm_if[i+1].awready),
       .m_awvalid  (axi_mm_if[i+1].awvalid),
       .m_awid     (axi_mm_if[i+1].awid),
       .m_awaddr   (axi_mm_if[i+1].awaddr),
       .m_awlen    (axi_mm_if[i+1].awlen),
       .m_awsize   (axi_mm_if[i+1].awsize),
       .m_awburst  (axi_mm_if[i+1].awburst),
       .m_awlock   (axi_mm_if[i+1].awlock),
       .m_awcache  (axi_mm_if[i+1].awcache),
       .m_awprot   (axi_mm_if[i+1].awprot),
       .m_awqos    (axi_mm_if[i+1].awqos),
       .m_awregion (),
       .m_awuser   (axi_mm_if[i+1].awuser),
       .m_wready   (axi_mm_if[i+1].wready),
       .m_wvalid   (axi_mm_if[i+1].wvalid),
       .m_wdata    (axi_mm_if[i+1].wdata),
       .m_wstrb    (axi_mm_if[i+1].wstrb),
       .m_wlast    (axi_mm_if[i+1].wlast),
       .m_wuser    (axi_mm_if[i+1].wuser),
       .m_bready   (axi_mm_if[i+1].bready),
       .m_bvalid   (axi_mm_if[i+1].bvalid),
       .m_bid      (axi_mm_if[i+1].bid),
       .m_bresp    (axi_mm_if[i+1].bresp),
       .m_buser    (axi_mm_if[i+1].buser),
       .m_arready  (axi_mm_if[i+1].arready),
       .m_arvalid  (axi_mm_if[i+1].arvalid),
       .m_arid     (axi_mm_if[i+1].arid),
       .m_araddr   (axi_mm_if[i+1].araddr),
       .m_arlen    (axi_mm_if[i+1].arlen),
       .m_arsize   (axi_mm_if[i+1].arsize),
       .m_arburst  (axi_mm_if[i+1].arburst),
       .m_arlock   (axi_mm_if[i+1].arlock),
       .m_arcache  (axi_mm_if[i+1].arcache),
       .m_arprot   (axi_mm_if[i+1].arprot),
       .m_arqos    (axi_mm_if[i+1].arqos),
       .m_arregion (),
       .m_aruser   (axi_mm_if[i+1].aruser),
       .m_rready   (axi_mm_if[i+1].rready),
       .m_rvalid   (axi_mm_if[i+1].rvalid),
       .m_rid      (axi_mm_if[i+1].rid),
       .m_rdata    (axi_mm_if[i+1].rdata),
       .m_rresp    (axi_mm_if[i+1].rresp),
       .m_rlast    (axi_mm_if[i+1].rlast),
       .m_ruser    (axi_mm_if[i+1].ruser)
   );

   end
   endgenerate

endmodule

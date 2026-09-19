// Copyright 2021 Intel Corporation
// SPDX-License-Identifier: MIT

//-----------------------------------------------------------------------------
// Description
//-----------------------------------------------------------------------------
//
// PCIe TLP <-> AXI-lite Bridge 
//
//-----------------------------------------------------------------------------

`timescale 1ps / 1ps

import pcie_ss_hdr_pkg::*;

module st2mm_rx_bridge #(
   parameter MM_ADDR_WIDTH     = 19, 
   parameter MM_DATA_WIDTH     = 64,
   parameter PMCI_BASEADDR     = 18'h20000,
   parameter VDM_OFFSET        = 16'h2000,
   parameter READ_ALLOWANCE    = 1,
   parameter WRITE_ALLOWANCE   = 6
)(
    input wire clk,
    input wire rst_n,

    pcie_ss_axis_if.sink       rx_st_if,

    ofs_fim_axi_lite_if.req    axi_m_if,
    ofs_fim_axi_lite_if.req    axi_m_pmci_vdm_if,

    output logic                                         o_tlp_rd,
    output logic [pcie_ss_hdr_pkg::PCIE_TAG_WIDTH-1:0]   o_tlp_rd_tag,
    output logic [1:0]                                   o_tlp_rd_length,
    output logic [15:0]                                  o_tlp_rd_req_id,
    output logic [pcie_ss_hdr_pkg::LOWER_ADDR_WIDTH-1:0] o_tlp_rd_lower_addr,
    output logic [2:0]                                   o_tlp_attr,
    output logic [2:0]                                   o_tlp_tc

);

//
// The packet filter expects TLP header plus MMIO data in the same cycle -- a 512 bit bus.
// If the incoming rx_st_if is wider then 512 bits it can just be truncated since headers
// are always at bit 0. If rx_st_if is too narrow then widen it to 512 bits.
//

localparam RX_DATA_W = rx_st_if.DATA_W;

localparam DATA_W = 512;
localparam USER_W = rx_st_if.USER_W;

pcie_ss_axis_if#(.DATA_W(DATA_W), .USER_W(USER_W)) rx_st (.clk(clk), .rst_n(rst_n));

if (RX_DATA_W >= DATA_W) begin : size_in
   // Truncate incoming rx_st_if to DATA_W
   assign rx_st.tvalid = rx_st_if.tvalid;
   assign rx_st.tlast = rx_st_if.tlast;
   assign rx_st.tuser_vendor = rx_st_if.tuser_vendor;
   assign rx_st.tdata = rx_st_if.tdata[DATA_W-1 : 0];
   assign rx_st.tkeep = rx_st_if.tkeep[DATA_W/8-1 : 0];
   assign rx_st_if.tready = rx_st.tready;
end else begin : size_in
   // Map narrow rx_st_if to DATA_W
   ofs_fim_pcie_bus_width rx_if_width (.i_if(rx_st_if), .o_if(rx_st));
end


pcie_ss_axis_if#(.DATA_W(DATA_W), .USER_W(USER_W)) mmio_rx_if (.clk(clk), .rst_n(rst_n));
pcie_ss_axis_if#(.DATA_W(DATA_W), .USER_W(USER_W)) umsg_rx_if (.clk(clk), .rst_n(rst_n));

//---------------------------------
// Packet filter
//---------------------------------
st2mm_packet_filter #(
  .TDATA_WIDTH(DATA_W),
  .TUSER_WIDTH(USER_W)
) st2mm_pkt_filter (
   .clk          (clk),
   .rst_n        (rst_n),

   .rx_st_if     (rx_st),

   .mmio_st_if   (mmio_rx_if),
   .umsg_st_if   (umsg_rx_if)
);

//---------------------------------
// PCIe VDM handler 
//---------------------------------
//always_comb begin
//   umsg_rx_if.tready = 1'b1;
//end

//---------------------------------
// PMCI VDM request bridge
//---------------------------------
// Sends VDM TLP to AXI memory write/read request
mctp_rx_bridge #(
  .MAX_BUF_DEPTH      (32),
  .MM_DATA_WIDTH     (MM_DATA_WIDTH),
  .PMCI_BASEADDR     (PMCI_BASEADDR),
  .VDM_OFFSET        (VDM_OFFSET),
  .MM_ADDR_WIDTH     (MM_ADDR_WIDTH), 
  .READ_ALLOWANCE    (READ_ALLOWANCE),
  .WRITE_ALLOWANCE   (WRITE_ALLOWANCE)
) mctp_rx_bridge (
   .clk           (clk),
   .rst_n         (rst_n),
   .i_vdm_req_st  (umsg_rx_if),
   .axi_m_if      (axi_m_pmci_vdm_if)
);

//---------------------------------
// MMIO request bridge
//---------------------------------
// Converts MWr/MRd TLP to AXI memory write/read request
mmio_req_bridge #(
   .MM_ADDR_WIDTH   (MM_ADDR_WIDTH),
   .MM_DATA_WIDTH   (MM_DATA_WIDTH),
   .READ_ALLOWANCE  (READ_ALLOWANCE),
   .WRITE_ALLOWANCE (WRITE_ALLOWANCE)

) mmio_req_bridge (
   .clk                  (clk),
   .rst_n                (rst_n),

   .i_mmio_req_st        (mmio_rx_if),

   .axi_m_if             (axi_m_if),

   .o_tlp_rd             (o_tlp_rd),
   .o_tlp_rd_tag         (o_tlp_rd_tag),
   .o_tlp_rd_length      (o_tlp_rd_length),
   .o_tlp_rd_req_id      (o_tlp_rd_req_id),
   .o_tlp_rd_lower_addr  (o_tlp_rd_lower_addr),
   .o_tlp_attr           (o_tlp_attr),
   .o_tlp_tc             (o_tlp_tc)
);

endmodule : st2mm_rx_bridge

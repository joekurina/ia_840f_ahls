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
import ofs_csr_pkg::*;

module bwbmc_st2mm #(
   parameter PF_NUM            = 0,
   parameter VF_NUM            = 0,
   parameter VF_ACTIVE         = 0,
   parameter MM_ADDR_WIDTH     = 19,
   parameter MM_DATA_WIDTH     = 64,
   parameter READ_ALLOWANCE    = 1,
   parameter WRITE_ALLOWANCE   = 64
)(
    input wire                  clk,
    input wire                  rst_n,

    input wire                  clk_csr,
    input wire                  rst_n_csr,

    input logic                 flr_rst_n,
    output logic                flr_ack,

    pcie_ss_axis_if.sink        axis_rx_if,
    pcie_ss_axis_if.source      axis_tx_if,

    ofs_fim_axi_lite_if         axi_m_if
);

import pcie_ss_hdr_pkg::*;

pcie_ss_axis_if st2mm_rx_if(.clk (clk_csr), .rst_n(rst_n_csr));
pcie_ss_axis_if st2mm_tx_if(.clk (clk_csr), .rst_n(rst_n_csr));

pcie_ss_axis_if    st2mm_tx_st[1:0](.clk(clk_csr), .rst_n(rst_n_csr));

logic                           msix_strb;
logic   [15:0]                  msix_num;
logic                           msix_ready;

// Legacy signals were undriven; BMC interrupt-to-MSI-X is not implemented.
assign msix_strb = 1'b0;
assign msix_num = 16'b0;


// Tx MuX
always_comb begin
   st2mm_tx_st[0].tready        = 1'b0;
   st2mm_tx_st[1].tready        = 1'b0;
   st2mm_tx_if.tvalid           = 1'b0;
   st2mm_tx_if.tlast = 1'b0;
   st2mm_tx_if.tuser_vendor = '0;
   st2mm_tx_if.tdata = '0;
   st2mm_tx_if.tkeep = '0;

   case ( { st2mm_tx_st[0].tvalid } )
      // PRIORITY #1 = MMIO
      1'b1: begin
         st2mm_tx_st[0].tready        = st2mm_tx_if.tready;
         st2mm_tx_if.tvalid           = st2mm_tx_st[0].tvalid;
         st2mm_tx_if.tlast            = st2mm_tx_st[0].tlast;
         st2mm_tx_if.tuser_vendor     = st2mm_tx_st[0].tuser_vendor;
         st2mm_tx_if.tdata            = st2mm_tx_st[0].tdata;
         st2mm_tx_if.tkeep            = st2mm_tx_st[0].tkeep;
      end

      // PRIORITY #2 = MSIX
      default: begin
         st2mm_tx_st[1].tready        = st2mm_tx_if.tready;
         st2mm_tx_if.tvalid           = st2mm_tx_st[1].tvalid;
         st2mm_tx_if.tlast            = st2mm_tx_st[1].tlast;
         st2mm_tx_if.tuser_vendor     = st2mm_tx_st[1].tuser_vendor;
         st2mm_tx_if.tdata            = st2mm_tx_st[1].tdata;
         st2mm_tx_if.tkeep            = st2mm_tx_st[1].tkeep;
      end
   endcase
end


//---------------------------------
// ST2MM FLR reset
//---------------------------------
logic flr_rst_n_q;

always_ff @(posedge clk) begin
   flr_rst_n_q <= flr_rst_n;
end

always_ff @(posedge clk) begin
   flr_ack <= 1'b0;
   if (flr_rst_n_q && ~flr_rst_n) begin
      flr_ack <= 1'b1;
   end

   if (~rst_n) begin
      flr_ack <= 1'b0;
   end
end

//---------------------------------
// Clock crossing to CSR clock domain
//---------------------------------
// Follow ofs-common/src/common/st2mm/st2mm.sv's modern CDC/TX skid
// implementation. Retain the vendor FIFO depth and almost-full threshold.
// The modern CDC takes clocks/resets from its interfaces, not explicit ports.
// mux_rx_a_if carries the global reset, so a zero-stage connection binds the
// RX FIFO's write-side reset to this endpoint's PF1 port reset instead.
// This preserves reset ownership, not a qualified FLR transaction protocol.
pcie_ss_axis_if axis_rx_cdc_if(.clk(clk), .rst_n(rst_n));
pcie_ss_axis_if axis_tx_cdc_if(.clk(clk), .rst_n(rst_n));

ofs_fim_axis_pipeline #(.PL_DEPTH(0)) axis_rx_reset_binding (
   .clk,
   .rst_n,
   .axis_s (axis_rx_if),
   .axis_m (axis_rx_cdc_if)
);

ofs_fim_axis_cdc #(
   .DEPTH_LOG2        (6),
   .ALMFULL_THRESHOLD (4)
) rx_cdc_fifo (
   .axis_s (axis_rx_cdc_if),
   .axis_m (st2mm_rx_if)
);

ofs_fim_axis_cdc #(
   .DEPTH_LOG2        (6),
   .ALMFULL_THRESHOLD (4)
) tx_cdc_fifo (
   .axis_s (st2mm_tx_if),
   .axis_m (axis_tx_cdc_if)
);

ofs_fim_axis_pipeline axis_tx_skid (
   .clk,
   .rst_n,
   .axis_s (axis_tx_cdc_if),
   .axis_m (axis_tx_if)
);

//---------------------------------
// ST2MM RX bridge
//---------------------------------
logic                                           tlp_rd;
logic [pcie_ss_hdr_pkg::PCIE_TAG_WIDTH-1:0]     tlp_rd_tag;
logic [1:0]                                     tlp_rd_length;
logic [15:0]                                    tlp_rd_req_id;
logic [pcie_ss_hdr_pkg::LOWER_ADDR_WIDTH-1:0]   tlp_rd_lower_addr;
logic [2:0]                                     tlp_attr;
logic [2:0]                                     tlp_tc;


bwbmc_st2mm_rx_bridge #(
    .MM_ADDR_WIDTH    (MM_ADDR_WIDTH),
    .MM_DATA_WIDTH    (MM_DATA_WIDTH),
    .READ_ALLOWANCE   (READ_ALLOWANCE),
    .WRITE_ALLOWANCE  (WRITE_ALLOWANCE)
)
bwbmc_st2mm_rx_bridge (
   .clk                  (clk_csr),
   .rst_n                (rst_n_csr),

   .rx_st_if             (st2mm_rx_if),
   .axi_m_if             (axi_m_if),

   .o_tlp_rd             (tlp_rd),
   .o_tlp_rd_tag         (tlp_rd_tag),
   .o_tlp_rd_length      (tlp_rd_length),
   .o_tlp_rd_req_id      (tlp_rd_req_id),
   .o_tlp_rd_lower_addr  (tlp_rd_lower_addr),
   .o_tlp_attr           (tlp_attr),
   .o_tlp_tc             (tlp_tc)
);

//---------------------------------
// ST2MM RX bridge
//---------------------------------
st2mm_tx_bridge #(
    .PF_NUM           (PF_NUM),
    .VF_NUM           (VF_NUM),
    .VF_ACTIVE        (VF_ACTIVE),
    .MM_ADDR_WIDTH    (MM_ADDR_WIDTH),
    .MM_DATA_WIDTH    (MM_DATA_WIDTH),
    .READ_ALLOWANCE   (READ_ALLOWANCE)
)
st2mm_tx_bridge (
   .clk                  (clk_csr),
   .rst_n                (rst_n_csr),

   .tx_st_if             (st2mm_tx_st[0]),

   .axi_m_if             (axi_m_if),

   .i_tlp_rd             (tlp_rd),
   .i_tlp_rd_tag         (tlp_rd_tag),
   .i_tlp_rd_length      (tlp_rd_length),
   .i_tlp_rd_req_id      (tlp_rd_req_id),
   .i_tlp_rd_lower_addr  (tlp_rd_lower_addr),
   .i_tlp_attr           (tlp_attr),
   .i_tlp_tc             (tlp_tc)
);

//--------------------------------------------
// MSIX Bridge
//---------------------------------------------
axis_tx_msix_bridge #(
    .PF_NUM             (PF_NUM),
    .VF_NUM             (VF_NUM),
    .VF_ACTIVE          (VF_ACTIVE)
)
axis_tx_msix_bridge (
    .clk                            (clk_csr),
    .rst_n                          (rst_n_csr),

    .axis_tx_if                     (st2mm_tx_st[1]),
    .axis_tx_error                  ( ),

    .msix_strb                      (msix_strb),
    .msix_num                       (msix_num),
    .msix_ready                     (msix_ready)
);

endmodule : bwbmc_st2mm

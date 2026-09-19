// Copyright 2021 Intel Corporation
// SPDX-License-Identifier: MIT

// Description
//-----------------------------------------------------------------------------
// Minimal PCIe port connector only reponds Host to Card mmio request
// - Option to chose VIRTIO GUID
//-----------------------------------------------------------------------------

module he_null #(
   parameter CSR_DATA_WIDTH = 64,
   parameter CSR_ADDR_WIDTH = 16,
   parameter CSR_DEPTH      = 4, 
   // PF/VF/VF_ACTIVE are defined here so he_null looks like a normal AFU, but
   // they are not used. Instead, he_null() responds dynamically with any
   // MMIO request received. Since he_null() only responds to commands and
   // does not initiate traffic, it doesn't need to know its address. It
   // would be acceptable to instantiate a single he_null() to respond for
   // multiple functions.
   parameter PF_ID          = 0,
   parameter VF_ID          = 0,
   parameter VF_ACTIVE      = 0,
   parameter USE_VIRTIO_GUID = 0
)(
   input  logic clk,
   input  logic rst_n,

   pcie_ss_axis_if.sink   i_rx_if,
   pcie_ss_axis_if.source o_tx_if
);

   import pcie_ss_hdr_pkg::*;

   // ----------- Parameters -------------
   localparam END_OF_LIST           = 1'h0;  // Set this to 0 if there is another DFH beyond this
   localparam NEXT_DFH_BYTE_OFFSET  = 24'h0; // Next DFH Byte offset
   localparam PCIE_TDATA_WIDTH      = ofs_fim_cfg_pkg::PCIE_TDATA_WIDTH;
   localparam PCIE_TUSER_WIDTH      = ofs_fim_cfg_pkg::PCIE_TUSER_WIDTH;

   localparam VIRTIO_GUID_L         = 64'hb9abefbd90b970c4;
   localparam VIRTIO_GUID_H         = 64'h1aae155cacc54210;
   localparam NULL_GUID_L           = 64'haa31f54a3e403501;
   localparam NULL_GUID_H           = 64'h3e7b60a0df2d4850;
   localparam HE_GUID_L             = (USE_VIRTIO_GUID == 1) ? VIRTIO_GUID_L : NULL_GUID_L;
   localparam HE_GUID_H             = (USE_VIRTIO_GUID == 1) ? VIRTIO_GUID_H : NULL_GUID_H;

   localparam bit        VIO_END_OF_LIST     = 1'b1; //DFH End of list
   localparam bit [11:0] VIO_FEAT_ID         = 12'h0; //DFH Feature ID
   localparam bit [3:0 ] VIO_FEAT_VER        = 4'h0; //DFH Feature Version
   localparam bit [23:0] VIO_NEXT_DFH_OFFSET = 24'h0000; //DFH Next DFH Offset

   localparam DEF_VIO_FEATURE_DFH = {4'h1,19'h0,VIO_END_OF_LIST,VIO_NEXT_DFH_OFFSET,VIO_FEAT_VER,VIO_FEAT_ID};

   // CSR Addresses
   localparam NULL_DFH         = 17'h0000;
   localparam NULL_GUID_L_ADDR = 17'h0008;
   localparam NULL_GUID_H_ADDR = 17'h0010;
   localparam NULL_SCRATCHPAD  = 17'h0018;

   // ---- Logic / Struct Declarations ---
   logic mmio_wr_en;
   logic mmio_rd_en;
   logic rx_sop;
   logic [CSR_ADDR_WIDTH-5:0]     rx_addr;
   logic [CSR_ADDR_WIDTH-1:0]     rx_addr_decode;
   logic [CSR_DATA_WIDTH-1:0]     mmio_wr_data;
   logic                          mmio_hdr_len;
   PCIe_PUCplHdr_t                cpl_hdr;
   PCIe_PUReqHdr_t                mmio_hdr;
   logic [CSR_DATA_WIDTH-1:0]     scratch_reg;
   logic [CSR_DATA_WIDTH-1:0]     debug_default_reg;
   logic access_upper32b;

   // Register input and output streams. Use simple buffers with a bubble since throughput
   // is unimportant for the NULL AFU.
   pcie_ss_axis_if #(.DATA_W (PCIE_TDATA_WIDTH), .USER_W (PCIE_TUSER_WIDTH)) axi_rx_reg (.clk(clk), .rst_n(rst_n));
   pcie_ss_axis_if #(.DATA_W (PCIE_TDATA_WIDTH), .USER_W (PCIE_TUSER_WIDTH)) axi_tx_reg (.clk(clk), .rst_n(rst_n));

   ofs_fim_axis_pipeline#(.MODE(2)) rx_reg(.clk, .rst_n, .axis_s(i_rx_if), .axis_m(axi_rx_reg));
   ofs_fim_axis_pipeline#(.MODE(2)) tx_reg(.clk, .rst_n, .axis_s(axi_tx_reg), .axis_m(o_tx_if));

   // Ensure that TLP headers and MMIO data are delivered together in a single cycle by checking
   // that the AXI-S data bus is wide enough for both. If the bus is already wide enough, the code
   // reduces to just wires.
   localparam TDATA_WIDTH = (PCIE_TDATA_WIDTH >= pcie_ss_hdr_pkg::HDR_WIDTH*2) ? PCIE_TDATA_WIDTH : pcie_ss_hdr_pkg::HDR_WIDTH*2;
   pcie_ss_axis_if #(.DATA_W (TDATA_WIDTH), .USER_W (PCIE_TUSER_WIDTH)) axi_rx_if (.clk(clk), .rst_n(rst_n));
   pcie_ss_axis_if #(.DATA_W (TDATA_WIDTH), .USER_W (PCIE_TUSER_WIDTH)) axi_tx_if (.clk(clk), .rst_n(rst_n));

   ofs_fim_pcie_bus_width rx_width (.i_if(axi_rx_reg), .o_if(axi_rx_if));
   ofs_fim_pcie_bus_width tx_width (.i_if(axi_tx_if), .o_if(axi_tx_reg));


   // The remainder of the logic operates on axi_rx_if/axi_tx_if, which are guaranteed to hold
   // header+MMIO data in a single cycle and are isolated by registers from the FIM for timing.

   assign mmio_hdr = PCIe_PUReqHdr_t'(axi_rx_if.tdata);

   always_comb begin
      mmio_hdr_len     = (mmio_hdr.length > 1) ? 1'b1 : 1'b0; //Length is in DW
      rx_addr          = func_is_addr32(mmio_hdr.fmt_type) ? mmio_hdr.host_addr_h[13:2] : mmio_hdr.host_addr_l[11:0]; //4B aligned
      rx_addr_decode   = {'0, rx_addr[CSR_ADDR_WIDTH-7:1], 3'b0};

      // CSR Write
      mmio_wr_en       = rx_sop & axi_rx_if.tvalid & axi_rx_if.tready & func_is_mwr_req(mmio_hdr.fmt_type);
      mmio_wr_data     = axi_rx_if.tdata[HDR_WIDTH +: CSR_DATA_WIDTH];

      // CSR Read
      mmio_rd_en       = rx_sop & axi_rx_if.tvalid & axi_rx_if.tready & func_is_mrd_req(mmio_hdr.fmt_type);
      access_upper32b  = ~mmio_hdr_len & rx_addr[0];

      // Set up completion packet
      cpl_hdr               = 'h0;
      cpl_hdr.fmt_type      = DM_CPL;

      cpl_hdr.attr[8]       = mmio_hdr.attr[8];  // Attribite bits
      cpl_hdr.attr[3:2]     = mmio_hdr.attr[3:2];// Attribite bits

      cpl_hdr.TC            = mmio_hdr.TC;       // Traffic Class
      cpl_hdr.cpl_status    = 3'h0;              // Successful Completion
      cpl_hdr.pf_num        = mmio_hdr.pf_num;
      cpl_hdr.vf_num        = mmio_hdr.vf_num;
      cpl_hdr.vf_active     = mmio_hdr.vf_active;

      cpl_hdr.length        = (mmio_hdr.length == 1) ? 10'd1 : 10'd2; //DWs

      cpl_hdr.tag_h         = mmio_hdr.tag_h;
      cpl_hdr.tag_m         = mmio_hdr.tag_m;
      cpl_hdr.tag_l         = mmio_hdr.tag_l;

      cpl_hdr.byte_count    = (mmio_hdr.length == 1) ? 10'd4 : 10'd8; //Bytes 
      cpl_hdr.comp_id       = {'0,
                               mmio_hdr.vf_num,
                               mmio_hdr.vf_active,
                               mmio_hdr.pf_num};

      cpl_hdr.low_addr      = func_is_addr32(mmio_hdr.fmt_type) ?
                                 {mmio_hdr.host_addr_h[6:2], 2'b00} :
                                 {mmio_hdr.host_addr_l[4:0], 2'b00};
      cpl_hdr.req_id        = mmio_hdr.req_id; //Response with same req_id as request
   end

   always_ff @(posedge clk) begin
      if (axi_rx_if.tvalid & axi_rx_if.tready)
         rx_sop <= axi_rx_if.tlast;

      if (~rst_n)
         rx_sop <= 1'b1;
   end

   // Because of ofs_fim_axis_pipeline in the TX path we can be sure that the axi_tx_if_.tready value
   // is independent of axi_tx_if.tvalid. There is no need to check whether axi_rx_if is a read request.
   assign axi_rx_if.tready = axi_tx_if.tready;

   // Receive MMIO Writes
   always_ff @(posedge clk) begin
      if (~rst_n) begin
         scratch_reg       <= '0;
         debug_default_reg <= 'hdeadbeef;
      end else begin
         if (mmio_wr_en) begin
            case ( {rx_addr_decode} )
               NULL_SCRATCHPAD: begin
                  if (access_upper32b)
                     scratch_reg[63:32] <= mmio_wr_data[31:0];
                  else begin
                     scratch_reg[31:0] <= mmio_wr_data[31:0];
                     if (mmio_hdr_len)
                        scratch_reg[63:32] <= mmio_wr_data[63:32];
                  end
               end
               default: begin
                  scratch_reg       <= 'haaaa_aaaa;
                  debug_default_reg <= 'hbbbb_bbbb;
               end
            endcase
         end
      end
   end

   // MMIO Completion
   logic [63:0] cpl_data;

   always_comb begin
      case ( {rx_addr_decode} )
      NULL_DFH: begin
         cpl_data = DEF_VIO_FEATURE_DFH;
      end
      NULL_GUID_L_ADDR: begin
         cpl_data = HE_GUID_L;
      end
      NULL_GUID_H_ADDR: begin
         cpl_data = HE_GUID_H;
      end
      NULL_SCRATCHPAD: begin
         cpl_data = scratch_reg;
      end
      default: begin
         cpl_data = '0;
         cpl_data[2 +: CSR_ADDR_WIDTH] = rx_addr;
         cpl_data[34 +: CSR_ADDR_WIDTH] = rx_addr;
      end
      endcase

      if (access_upper32b) begin
         cpl_data[31:0] = cpl_data[63:32];
      end
   end

   always_comb begin
      axi_tx_if.tvalid = mmio_rd_en;
      axi_tx_if.tdata = { cpl_data, cpl_hdr };
      axi_tx_if.tlast = 1'b1;
      axi_tx_if.tuser_vendor = '0;

      axi_tx_if.tkeep = { '0,
                          mmio_hdr_len ? 4'hf : 4'h0,  // High 32 bits cpl_data
                          4'hf,                        // Low 32 bits cpl_data
                          {(HDR_WIDTH/8){1'b1}}        // cpl_hdr
                        };
   end

endmodule

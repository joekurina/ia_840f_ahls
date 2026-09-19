// Copyright (C) 2024 Intel Corporation.
// SPDX-License-Identifier: MIT

//
// PCIe Page Request Interface (PRI) extended configuration, implemented in the
// PCIe SS configuration extension bus. The HIP fails to set the PASID required
// bit in the status register, which Linux requires. The HIP also forces the
// outstanding request capacity to 0.
//
// For shared virtual addressing, OFS enables the HIP's ATS and PASID capabilities
// but does not turn on the HIP's PRI. Instead, it implements PRI capability here.
//
// PRI is a capability only on PFs. VFs are controlled by the PF capability.
//

module ofs_fim_pcie_ss_ceb_pri
  #(
    parameter PRI_CAP_DW_ADDR = 0,
    parameter PRI_OUTSTANDING_CAPACITY = 1000,
    parameter NUM_PFS = 1,
    // PRI capability will be enabled only on PFs set to 1 in PF_ENABLE_PRI.
    parameter bit PF_ENABLE_PRI[NUM_PFS] = '{NUM_PFS{1'b1}}
    )
   (
    input  logic csr_clk,
    input  logic csr_rst_n,

    input  logic ceb_req_tvalid,
    output logic ceb_req_tready,
    input  pcie_ss_axis_pkg::t_pcie_ceb_req ceb_req,

    output logic ceb_rsp_tvalid,
    output pcie_ss_axis_pkg::t_pcie_ceb_rsp ceb_rsp,

    // Update the page request enable control shadow bit
    input  logic ctrlshadow_tvalid_in,
    input  logic [39:0] ctrlshadow_tdata_in,
    output logic ctrlshadow_tvalid_out,
    output logic [39:0] ctrlshadow_tdata_out
    );

    localparam ALLOCATION_WIDTH = $clog2(PRI_OUTSTANDING_CAPACITY+1);

    logic pri_enable[NUM_PFS];
    logic [31:0] pri_allocation[NUM_PFS];

    assign ceb_req_tready = 1'b1;

    // Read response
    always_ff @(posedge csr_clk) begin
        ceb_rsp_tvalid <= ceb_req_tvalid && ~|ceb_req.wr_tkeep;

        // Is PRI enabled on this function? If not, always return 0.
        if (ceb_req.vf_active || (ceb_req.pf_num > NUM_PFS) || !PF_ENABLE_PRI[ceb_req.pf_num]) begin
            ceb_rsp.rd_data <= '0;
        end
        else begin
            unique case (ceb_req.dw_addr)
                PRI_CAP_DW_ADDR:
                    ceb_rsp.rd_data <= 32'h00010013;
                PRI_CAP_DW_ADDR + 1: begin
                    ceb_rsp.rd_data <= 32'h81000000;
                    ceb_rsp.rd_data[0] <= pri_enable[ceb_req.pf_num];
                  end
                PRI_CAP_DW_ADDR + 2:
                    ceb_rsp.rd_data <= 32'(PRI_OUTSTANDING_CAPACITY);
                PRI_CAP_DW_ADDR + 3:
                    ceb_rsp.rd_data <= 32'(pri_allocation[ceb_req.pf_num][ALLOCATION_WIDTH-1:0]);
                default:
                    ceb_rsp.rd_data <= '0;
            endcase // case (ceb_req.dw_addr)
        end

        if (!csr_rst_n)
           ceb_rsp_tvalid <= 1'b0;
    end

    // Write
    always_ff @(posedge csr_clk) begin
        if (ceb_req_tvalid && !ceb_req.vf_active && (ceb_req.pf_num < NUM_PFS)) begin
            if (ceb_req.dw_addr == PRI_CAP_DW_ADDR + 1) begin
                if (ceb_req.wr_tkeep[0])
                    pri_enable[ceb_req.pf_num] <= ceb_req.wr_data[0];
            end

            if (ceb_req.dw_addr == PRI_CAP_DW_ADDR + 3) begin
                if (ceb_req.wr_tkeep[0])
                    pri_allocation[ceb_req.pf_num][7:0] <= ceb_req.wr_data[7:0];
                if (ceb_req.wr_tkeep[1])
                    pri_allocation[ceb_req.pf_num][15:8] <= ceb_req.wr_data[15:8];
                if (ceb_req.wr_tkeep[2])
                    pri_allocation[ceb_req.pf_num][23:16] <= ceb_req.wr_data[23:16];
                if (ceb_req.wr_tkeep[3])
                    pri_allocation[ceb_req.pf_num][31:24] <= ceb_req.wr_data[31:24];
            end
        end

        if (!csr_rst_n) begin
            for (int i = 0; i < NUM_PFS; i += 1) begin
                pri_enable[i] <= 1'b0;
                pri_allocation[i] <= '0;
            end
        end
    end

    always_ff @(posedge csr_clk) begin
        ctrlshadow_tvalid_out <= ctrlshadow_tvalid_in;

        ctrlshadow_tdata_out <= ctrlshadow_tdata_in;
        // Bit 39 indicates PRI enabled. VFs are enabled when PF is enabled.
        ctrlshadow_tdata_out[39] <= pri_enable[ctrlshadow_tdata_in[2:0]];
      end

endmodule // ofs_fim_pcie_ss_ceb_pri

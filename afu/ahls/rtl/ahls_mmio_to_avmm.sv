// Copyright 2022 Intel Corporation
// SPDX-License-Identifier: MIT
// Derived address/byteenable boundary: vendor BSP/modern ASP asp_logic.sv.
// Serialized tag retention is new glue for a tagless Avalon agent, not AHLS RTL.
// See ../provenance.json and ../../../docs/vendor-derived-ahls-binding.md.
`include "ofs_plat_if.vh"

module ahls_mmio_to_avmm #(
    parameter int DATA_WIDTH,
    parameter int BYTE_ADDR_WIDTH
) (
    // Must be an already-decoded, rebased aperture, not raw BAR offset zero.
    // DFH/UUID and other board CSRs belong to the upstream address decoder.
    ofs_plat_avalon_mem_if.to_source mmio,
    // Same-clock, same-width tagless Avalon agent. Byte addresses are aligned
    // to the bus beat; byteenable selects lanes. These are generic names only.
    output logic [BYTE_ADDR_WIDTH-1:0] avmm_address,
    output logic avmm_read,
    output logic avmm_write,
    output logic [DATA_WIDTH-1:0] avmm_writedata,
    output logic [DATA_WIDTH/8-1:0] avmm_byteenable,
    input logic avmm_waitrequest,
    input logic [DATA_WIDTH-1:0] avmm_readdata,
    input logic avmm_readdatavalid,
    input logic [1:0] avmm_response,
    output logic unsupported_request
);
    localparam int BYTE_SHIFT = $clog2(DATA_WIDTH/8);
    logic read_pending;
    logic [mmio.USER_WIDTH-1:0] saved_user;
    logic accepted_read;

    // One outstanding read. No FIFO sizing assumption, split destructive reads,
    // retry or fabricated completion. All traffic stalls until the read returns.
    assign unsupported_request = (mmio.read || mmio.write) &&
        ((mmio.burstcount != 1) || (mmio.read && mmio.write));
    assign mmio.waitrequest = read_pending || !mmio.reset_n ||
                             unsupported_request || avmm_waitrequest;
    assign avmm_read = mmio.read && !read_pending && mmio.reset_n && !unsupported_request;
    assign avmm_write = mmio.write && !read_pending && mmio.reset_n && !unsupported_request;
    assign avmm_address = {mmio.address, {BYTE_SHIFT{1'b0}}};
    assign avmm_writedata = mmio.writedata;
    assign avmm_byteenable = mmio.byteenable;
    assign accepted_read = mmio.read && !mmio.waitrequest;

    assign mmio.readdata = avmm_readdata;
    assign mmio.readdatavalid = mmio.reset_n && avmm_readdatavalid &&
                              (read_pending || accepted_read);
    assign mmio.response = avmm_response;
    // Also supports a same-cycle agent response to an accepted request.
    assign mmio.readresponseuser = read_pending ? saved_user : mmio.user;
    // PCIe MMIO writes are posted; this bridge has no write-response service.
    assign mmio.writeresponsevalid = 1'b0;
    assign mmio.writeresponse = '0;
    assign mmio.writeresponseuser = '0;

    always_ff @(posedge mmio.clk) begin
        if (!mmio.reset_n) begin
            read_pending <= 1'b0;
            saved_user <= '0;
        end else begin
            if (accepted_read) begin
                saved_user <= mmio.user;
                read_pending <= !avmm_readdatavalid;
            end else if (read_pending && avmm_readdatavalid) begin
                read_pending <= 1'b0;
            end
        end
    end

    initial begin
        if ((DATA_WIDTH < 8) || (DATA_WIDTH % 8 != 0) ||
            (((DATA_WIDTH/8) & ((DATA_WIDTH/8)-1)) != 0) ||
            (DATA_WIDTH != mmio.DATA_WIDTH) ||
            (BYTE_ADDR_WIDTH != mmio.ADDR_WIDTH + BYTE_SHIFT) ||
            (mmio.MASKED_SYMBOL_WIDTH != 8) || (mmio.RESPONSE_WIDTH != 2) ||
            (mmio.WAIT_REQUEST_ALLOWANCE != 0))
            $fatal(1, "AHLS MMIO bridge requires matching byte/word geometry and zero wait allowance");
    end
endmodule

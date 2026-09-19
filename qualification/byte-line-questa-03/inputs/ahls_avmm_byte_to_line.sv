// Copyright 2022 Intel Corporation
// SPDX-License-Identifier: MIT
// Address normalization derived from ASP asp_logic.sv DMA/local-memory wiring.
// See ../provenance.json. New generic adapter; not generated AHLS port names.
`include "ofs_plat_if.vh"

module ahls_avmm_byte_to_line (
    // Same-width conventional Avalon on both sides. Source addresses are
    // aligned byte addresses; sink addresses are data-word (line) indices.
    // The adapter supplies the source clock/reset from the sink; no CDC here.
    ofs_plat_avalon_mem_if.to_source_clk byte_mem,
    ofs_plat_avalon_mem_if.to_sink line_mem,
    output logic address_alignment_fault
);
    localparam int BYTE_SHIFT = $clog2(line_mem.DATA_N_BYTES);
    assign byte_mem.clk = line_mem.clk;
    assign byte_mem.reset_n = line_mem.reset_n;
    assign byte_mem.instance_number = line_mem.instance_number;

    // Do not silently discard a sub-line address. Partial writes use byteenable
    // on a line-aligned address. Width conversion/repacking is a separate job.
    assign address_alignment_fault = (byte_mem.read || byte_mem.write) &&
        ((byte_mem.address & (line_mem.DATA_N_BYTES - 1)) != 0);
    assign line_mem.address = byte_mem.address >> BYTE_SHIFT;
    assign line_mem.burstcount = byte_mem.burstcount;
    assign line_mem.writedata = byte_mem.writedata;
    assign line_mem.byteenable = byte_mem.byteenable;
    assign line_mem.user = byte_mem.user;
    assign line_mem.read = byte_mem.read && !address_alignment_fault && line_mem.reset_n;
    assign line_mem.write = byte_mem.write && !address_alignment_fault && line_mem.reset_n;
    assign byte_mem.waitrequest = line_mem.waitrequest || address_alignment_fault || !line_mem.reset_n;
    assign byte_mem.readdata = line_mem.readdata;
    assign byte_mem.readdatavalid = line_mem.readdatavalid;
    assign byte_mem.response = line_mem.response;
    assign byte_mem.readresponseuser = line_mem.readresponseuser;
    assign byte_mem.writeresponsevalid = line_mem.writeresponsevalid;
    assign byte_mem.writeresponse = line_mem.writeresponse;
    assign byte_mem.writeresponseuser = line_mem.writeresponseuser;

    initial begin
        if ((line_mem.DATA_N_BYTES < 1) ||
            ((line_mem.DATA_N_BYTES & (line_mem.DATA_N_BYTES - 1)) != 0) ||
            (line_mem.DATA_WIDTH % 8 != 0) ||
            (line_mem.MASKED_SYMBOL_WIDTH != 8) || (byte_mem.MASKED_SYMBOL_WIDTH != 8))
            $fatal(1, "AHLS address adapter requires power-of-two byte geometry");
        if ((byte_mem.ADDR_WIDTH != line_mem.ADDR_WIDTH + BYTE_SHIFT) ||
            (byte_mem.DATA_WIDTH != line_mem.DATA_WIDTH) ||
            (byte_mem.BURST_CNT_WIDTH != line_mem.BURST_CNT_WIDTH) ||
            (byte_mem.USER_WIDTH != line_mem.USER_WIDTH) ||
            (byte_mem.RESPONSE_WIDTH != line_mem.RESPONSE_WIDTH) ||
            (byte_mem.WAIT_REQUEST_ALLOWANCE != 0) || (line_mem.WAIT_REQUEST_ALLOWANCE != 0))
            $fatal(1, "AHLS byte/line adapter geometry mismatch; no implicit truncation allowed");
    end
endmodule

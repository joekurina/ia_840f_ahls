// Copyright (C) 2022 Intel Corporation
// SPDX-License-Identifier: MIT
// DFH/UUID derived from OFS hello_world_avalon.sv, without its workload.
// New bounded aperture routing; see ../provenance.json.
`include "ofs_plat_if.vh"

module ahls_mmio_aperture #(
    parameter logic [127:0] AFU_UUID,
    parameter longint unsigned CSR_BASE_BYTES,
    parameter longint unsigned CSR_SIZE_BYTES
) (
    ofs_plat_avalon_mem_if.to_source mmio,
    ofs_plat_avalon_mem_if.to_sink_clk csr
);
    // Deliberately 64-bit board MMIO, as in the IA840F BSP. This does not
    // prescribe AHLS CSR width: a narrower generated agent needs a reviewed
    // width adapter after this router, not unconditional split reads.
    logic in_csr;
    logic busy, pending_csr;
    logic local_valid;
    logic [63:0] local_data;
    logic [1:0] local_response;
    logic [mmio.USER_WIDTH-1:0] local_user;
    logic accepted_read, accepted_csr_read, csr_response_valid;
    localparam longint unsigned BASE_WORD = CSR_BASE_BYTES / 8;
    localparam longint unsigned SIZE_WORDS = CSR_SIZE_BYTES / 8;

    assign csr.clk = mmio.clk;
    assign csr.reset_n = mmio.reset_n;
    assign csr.instance_number = mmio.instance_number;
    assign in_csr = (mmio.address >= BASE_WORD) &&
                    ((mmio.address - BASE_WORD) < SIZE_WORDS);
    assign mmio.waitrequest = !mmio.reset_n || busy ||
        ((mmio.read || mmio.write) && ((mmio.burstcount != 1) || (mmio.read && mmio.write))) ||
        (in_csr && csr.waitrequest);
    assign csr.address = mmio.address - BASE_WORD;
    assign csr.burstcount = mmio.burstcount;
    assign csr.writedata = mmio.writedata;
    assign csr.byteenable = mmio.byteenable;
    assign csr.user = mmio.user;
    assign csr.read = mmio.read && !mmio.write && in_csr && !busy &&
                      mmio.reset_n && (mmio.burstcount == 1);
    assign csr.write = mmio.write && !mmio.read && in_csr && !busy &&
                       mmio.reset_n && (mmio.burstcount == 1);
    assign accepted_read = mmio.read && !mmio.waitrequest;
    assign accepted_csr_read = accepted_read && in_csr;
    assign csr_response_valid = csr.readdatavalid && (pending_csr || accepted_csr_read);
    assign mmio.readdatavalid = mmio.reset_n && (local_valid || csr_response_valid);
    assign mmio.readdata = local_valid ? local_data : csr.readdata;
    assign mmio.response = local_valid ? local_response : csr.response;
    assign mmio.readresponseuser = local_valid ? local_user : csr.readresponseuser;
    assign mmio.writeresponsevalid = 1'b0;
    assign mmio.writeresponse = '0;
    assign mmio.writeresponseuser = '0;

    always_ff @(posedge mmio.clk) begin
        if (!mmio.reset_n) begin
            busy <= 1'b0;
            pending_csr <= 1'b0;
            local_valid <= 1'b0;
            local_data <= '0;
            local_response <= '0;
            local_user <= '0;
        end else begin
            local_valid <= 1'b0;
            if (accepted_read) begin
                busy <= !csr_response_valid;
                pending_csr <= in_csr && !csr_response_valid;
                if (!in_csr) begin
                    local_valid <= 1'b1;
                    local_user <= mmio.user;
                    local_response <= 2'b00;
                    case (mmio.address)
                        0: begin
                            local_data <= '0;
                            local_data[63:60] <= 4'h1; // AFU feature
                            local_data[40] <= 1'b1;    // End of DFL
                        end
                        1: local_data <= AFU_UUID[63:0];
                        2: local_data <= AFU_UUID[127:64];
                        3, 4: local_data <= '0;
                        default: begin
                            local_data <= '0;
                            local_response <= 2'b11; // Decode error, not an AHLS CSR
                        end
                    endcase
                end
            end else if (mmio.readdatavalid) begin
                busy <= 1'b0;
                pending_csr <= 1'b0;
            end
        end
    end
    // Writes outside the selected CSR aperture are ignored (read-only DFH,
    // reserved holes). Posted-write errors cannot be returned by this service.
    initial begin
        if ((AFU_UUID == 0) || (CSR_BASE_BYTES < 40) || (CSR_BASE_BYTES % 8 != 0) ||
            (CSR_SIZE_BYTES == 0) || (CSR_SIZE_BYTES % 8 != 0) ||
            (CSR_BASE_BYTES + CSR_SIZE_BYTES < CSR_BASE_BYTES) ||
            (mmio.ADDR_WIDTH >= 61) ||
            ((CSR_BASE_BYTES + CSR_SIZE_BYTES) > (64'd1 << (mmio.ADDR_WIDTH + 3))))
            $fatal(1, "AHLS aperture needs explicit nonzero UUID and valid nonoverlapping range");
        if ((mmio.DATA_WIDTH != 64) || (csr.DATA_WIDTH != 64) ||
            (mmio.ADDR_WIDTH != csr.ADDR_WIDTH) ||
            (mmio.BURST_CNT_WIDTH != csr.BURST_CNT_WIDTH) ||
            (mmio.USER_WIDTH != csr.USER_WIDTH) ||
            (mmio.MASKED_SYMBOL_WIDTH != 8) || (csr.MASKED_SYMBOL_WIDTH != 8) ||
            (mmio.RESPONSE_WIDTH != 2) || (csr.RESPONSE_WIDTH != 2) ||
            (mmio.WAIT_REQUEST_ALLOWANCE != 0) || (csr.WAIT_REQUEST_ALLOWANCE != 0))
            $fatal(1, "AHLS aperture requires matching 64-bit PIM MMIO interfaces");
    end
endmodule

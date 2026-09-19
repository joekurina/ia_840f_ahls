// Copyright 2022 Intel Corporation
// SPDX-License-Identifier: MIT
// Connected reusable board binding, not the OFS top or generated AHLS IP.
`include "ofs_plat_if.vh"

module ahls_board_binding #(
    parameter logic [127:0] AFU_UUID,
    parameter longint unsigned CSR_BASE_BYTES,
    parameter longint unsigned CSR_SIZE_BYTES,
    parameter int NUM_LOCAL_MEM_BANKS = local_mem_cfg_pkg::LOCAL_MEM_NUM_BANKS,
    parameter int CSR_BYTE_ADDR_WIDTH = ofs_plat_host_chan_pkg::MMIO_ADDR_WIDTH_BYTES
) (
    ofs_plat_if plat_ifc,
    // Normalized byte-addressed, bus-aligned memory hosts, NOT compiler ports.
    ofs_plat_avalon_mem_if host_bytes,
    ofs_plat_avalon_mem_if local_bytes[NUM_LOCAL_MEM_BANKS],
    output logic host_address_alignment_fault,
    output logic [NUM_LOCAL_MEM_BANKS-1:0] local_address_alignment_fault,
    output wire binding_clk,
    output wire binding_reset_n,
    // Tagless, aligned-byte-addressed 64-bit Avalon agent boundary.
    output logic [CSR_BYTE_ADDR_WIDTH-1:0] csr_address,
    output logic csr_read,
    output logic csr_write,
    output logic [63:0] csr_writedata,
    output logic [7:0] csr_byteenable,
    input logic csr_waitrequest,
    input logic [63:0] csr_readdata,
    input logic csr_readdatavalid,
    input logic [1:0] csr_response,
    output logic csr_unsupported_request
);
    ofs_plat_avalon_mem_if #(`HOST_CHAN_AVALON_MMIO_PARAMS(64)) mmio();
    ofs_plat_avalon_mem_if #(`HOST_CHAN_AVALON_MMIO_PARAMS(64)) csr_mmio();
    ofs_plat_avalon_mem_if #(
        `HOST_CHAN_AVALON_MEM_RDWR_PARAMS,
        .BURST_CNT_WIDTH(host_bytes.BURST_CNT_WIDTH_),
        .USER_WIDTH(host_bytes.USER_WIDTH_)
    ) host_lines();
    ofs_plat_avalon_mem_if #(
        `LOCAL_MEM_AVALON_MEM_PARAMS,
        .BURST_CNT_WIDTH(local_bytes[0].BURST_CNT_WIDTH_),
        .USER_WIDTH(local_bytes[0].USER_WIDTH_)
    ) local_lines[NUM_LOCAL_MEM_BANKS]();

    ahls_ofs_board_services #(.NUM_LOCAL_MEM_BANKS(NUM_LOCAL_MEM_BANKS)) board (
        .plat_ifc(plat_ifc), .mmio(mmio),
        .host_mem(host_lines), .local_mem(local_lines)
    );
    assign binding_clk = mmio.clk;
    assign binding_reset_n = mmio.reset_n;

    ahls_mmio_aperture #(
        .AFU_UUID(AFU_UUID), .CSR_BASE_BYTES(CSR_BASE_BYTES),
        .CSR_SIZE_BYTES(CSR_SIZE_BYTES)
    ) aperture (.mmio(mmio), .csr(csr_mmio));
    ahls_mmio_to_avmm #(.DATA_WIDTH(64), .BYTE_ADDR_WIDTH(CSR_BYTE_ADDR_WIDTH)) control (
        .mmio(csr_mmio), .avmm_address(csr_address),
        .avmm_read(csr_read), .avmm_write(csr_write),
        .avmm_writedata(csr_writedata), .avmm_byteenable(csr_byteenable),
        .avmm_waitrequest(csr_waitrequest), .avmm_readdata(csr_readdata),
        .avmm_readdatavalid(csr_readdatavalid), .avmm_response(csr_response),
        .unsupported_request(csr_unsupported_request)
    );
    ahls_avmm_byte_to_line host_address (
        .byte_mem(host_bytes), .line_mem(host_lines),
        .address_alignment_fault(host_address_alignment_fault)
    );
    for (genvar b = 0; b < NUM_LOCAL_MEM_BANKS; b = b + 1) begin : bank_address
        ahls_avmm_byte_to_line adapter (
            .byte_mem(local_bytes[b]), .line_mem(local_lines[b]),
            .address_alignment_fault(local_address_alignment_fault[b])
        );
    end
endmodule

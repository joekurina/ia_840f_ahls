// Copyright 2022 Intel Corporation
// SPDX-License-Identifier: MIT
// Derived from the BittWare IA840F BSP and OFS ASP/PIM; see ../provenance.json.
// Board infrastructure only: not a generated AHLS component or an AFU top.
`include "ofs_plat_if.vh"

module ahls_ofs_board_services #(
    // Map the first N banks. Zero-bank builds require a different port shape;
    // this IA840F DDR service deliberately requires at least one bank.
    parameter int NUM_LOCAL_MEM_BANKS = local_mem_cfg_pkg::LOCAL_MEM_NUM_BANKS
) (
    ofs_plat_if plat_ifc,
    // PIM-native, word-addressed MMIO. The binding must implement DFH/UUID
    // and decode its AHLS aperture before using ahls_mmio_to_avmm.
    ofs_plat_avalon_mem_if mmio,
    // Conventional Avalon (shared commands), PIM line addresses, physical
    // IOVA domain. This is NOT the vendor's virtual-address USM interface.
    ofs_plat_avalon_mem_if host_mem,
    ofs_plat_avalon_mem_if local_mem[NUM_LOCAL_MEM_BANKS]
);
    ofs_plat_avalon_mem_rdwr_if #(
        `HOST_CHAN_AVALON_MEM_RDWR_PARAMS,
        .BURST_CNT_WIDTH(host_mem.BURST_CNT_WIDTH_),
        .USER_WIDTH(host_mem.USER_WIDTH_),
        .LOG_CLASS(ofs_plat_log_pkg::HOST_CHAN)
    ) host_split();

    // Vendor primary port mapping, now consistently in the AFU clock domain.
    // The old BSP placed some CDC in its generated Qsys board. That board
    // is intentionally not imported, so both CDCs below are explicitly on.
    ofs_plat_host_chan_as_avalon_mem_rdwr_with_mmio #(
        .ADD_CLOCK_CROSSING(1),
        .ADD_TIMING_REG_STAGES(1)
    ) primary_avalon (
        .to_fiu(plat_ifc.host_chan.ports[0]),
        .host_mem_to_afu(host_split),
        .mmio_to_afu(mmio),
        .afu_clk(plat_ifc.clocks.uClk_usrDiv2.clk),
        .afu_reset_n(plat_ifc.clocks.uClk_usrDiv2.reset_n)
    );

    assign host_mem.clk = host_split.clk;
    assign host_mem.reset_n = host_split.reset_n;
    assign host_mem.instance_number = host_split.instance_number;

    // Actual vendor/PIM converter, not a newly invented split-channel bridge.
    // Preserves bursts, byte enables, tags and read/write response channels.
    ofs_plat_avalon_mem_if_to_rdwr_if shared_to_split (
        .mem_source(host_mem),
        .mem_sink(host_split)
    );

    for (genvar b = 0; b < NUM_LOCAL_MEM_BANKS; b = b + 1) begin : banks
        ofs_plat_local_mem_as_avalon_mem #(
            .ADD_CLOCK_CROSSING(1),
            .ADD_TIMING_REG_STAGES(3)
        ) bank_avalon (
            .to_fiu(plat_ifc.local_mem.banks[b]),
            .to_afu(local_mem[b]),
            .afu_clk(plat_ifc.clocks.uClk_usrDiv2.clk),
            .afu_reset_n(plat_ifc.clocks.uClk_usrDiv2.reset_n)
        );
    end

    ofs_plat_if_tie_off_unused #(
        .HOST_CHAN_IN_USE_MASK(1),
        .LOCAL_MEM_IN_USE_MASK({NUM_LOCAL_MEM_BANKS{1'b1}})
    ) unused_resources(plat_ifc);

    // Source constraints only; no tool/elaboration qualification is claimed.
    initial begin
        if ((NUM_LOCAL_MEM_BANKS < 1) ||
            (NUM_LOCAL_MEM_BANKS > local_mem_cfg_pkg::LOCAL_MEM_NUM_BANKS))
            $fatal(1, "AHLS board service bank count is outside the platform");
        if ((host_mem.ADDR_WIDTH != host_split.ADDR_WIDTH) ||
            (host_mem.DATA_WIDTH != host_split.DATA_WIDTH) ||
            (host_mem.RESPONSE_WIDTH != host_split.RESPONSE_WIDTH) ||
            (host_mem.MASKED_SYMBOL_WIDTH != 8) ||
            (host_mem.WAIT_REQUEST_ALLOWANCE != 0))
            $fatal(1, "AHLS host-memory boundary must match PIM native geometry");
        if (host_mem.USER_WIDTH <= ofs_plat_host_chan_avalon_mem_pkg::HC_AVALON_UFLAG_MAX)
            $fatal(1, "AHLS host-memory user field must preserve PIM flags");
    end
endmodule

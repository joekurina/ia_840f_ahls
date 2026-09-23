// IA840F bank boundary adapter using existing PIM burst and metadata machinery.
// Preserve original PIM sources and original unfixed wrapper as separate evidence.
`include "ofs_plat_if.vh"
module ia840f_ahls_memory_bank_shim #(
    parameter ADD_CLOCK_CROSSING = 1,
    parameter ADD_TIMING_REG_STAGES = 3
)(
    input logic afu_clk,
    input logic afu_reset_n,
    ofs_plat_axi_mem_if.to_sink to_fiu,
    ofs_plat_axi_mem_if.to_source_clk to_afu
);
    ofs_plat_axi_mem_if #(
        `OFS_PLAT_AXI_MEM_IF_REPLICATE_PARAMS(to_afu)
    ) page_limited();

    ofs_plat_local_mem_as_axi_mem #(
        .ADD_CLOCK_CROSSING(ADD_CLOCK_CROSSING),
        .ADD_TIMING_REG_STAGES(ADD_TIMING_REG_STAGES)
    ) memory_shim (
        .to_fiu(to_fiu), .to_afu(page_limited),
        .afu_clk(afu_clk), .afu_reset_n(afu_reset_n)
    );
    assign to_afu.clk = page_limited.clk;
    assign to_afu.reset_n = page_limited.reset_n;
    assign to_afu.instance_number = page_limited.instance_number;

    // Existing PIM adapter splits requests/WLAST and hides intermediate
    // completions with the PIM NO_REPLY flag. The memory shim preserves
    // this flag and expanded AFU IDs through its metadata queues and CDC.
    ofs_plat_axi_mem_if_map_bursts #(
        .UFLAG_NO_REPLY(ofs_plat_local_mem_axi_mem_pkg::LM_AXI_UFLAG_NO_REPLY),
        .PAGE_SIZE(4096)
    ) page_splitter (
        .mem_source(to_afu), .mem_sink(page_limited)
    );
endmodule

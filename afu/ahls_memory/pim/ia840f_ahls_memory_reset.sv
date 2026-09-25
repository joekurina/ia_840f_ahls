// Board/HLS reset integration using the unchanged vendor reset-joining primitive.
// Losing either memory-bank reset invalidates application/completion state.
// This is reset distribution, not an active-transaction recovery protocol.
module ia840f_ahls_memory_reset (
    input wire core_clk, bank0_reset_n,
    input wire host_clk, soft_reset_n,
    input wire bank1_clk, bank1_reset_n,
    output wire core_reset_n
);
    wire bank0_and_soft_reset_n;
    ofs_plat_join_resets join_afu_reset (
        .a_clk(core_clk), .a_reset_n(bank0_reset_n),
        .b_clk(host_clk), .b_reset_n(soft_reset_n),
        .a_joined_reset_n(bank0_and_soft_reset_n));
    ofs_plat_join_resets join_bank1_reset (
        .a_clk(core_clk), .a_reset_n(bank0_and_soft_reset_n),
        .b_clk(bank1_clk), .b_reset_n(bank1_reset_n),
        .a_joined_reset_n(core_reset_n));
endmodule

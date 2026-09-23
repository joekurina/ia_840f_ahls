// Baseline is a transparent connection to the previously accepted fabric.
`include "ofs_plat_if.vh"
module ia840f_ahls_mmio_guard (
    ofs_plat_axi_mem_lite_if.to_source upstream,
    ofs_plat_axi_mem_lite_if.to_sink downstream
);
    ofs_plat_axi_mem_lite_if_connect pass_through(
        .mem_source(upstream),.mem_sink(downstream));
endmodule

// Additive IA-840F AFU-side packet cap; original FIM/PIM sources remain unchanged.
`include "ofs_plat_if.vh"

module ia840f_host_packet_cap
   (
    ofs_plat_axi_mem_if.to_source mem_source,
    ofs_plat_axi_mem_if.to_sink mem_sink
    );

    // The standard host flags occupy bits 0..3 in the bound release.
    // AFU-private bit 4 is returned by PIM metadata, not consumed by its
    // internal HC_AXI_UFLAG_NO_REPLY (bit 0). This avoids nested ownership.
    localparam PRIVATE_NO_REPLY = ofs_plat_host_chan_axi_mem_pkg::HC_AXI_UFLAG_WIDTH;

    // The public mapper splits address/length, fixup_wlast reconstructs
    // fragment WLASTs, and the private flag suppresses intermediate B and
    // intermediate RLAST while forwarding all read data. It does not merge
    // intermediate BRESP errors. Tested scope requires full-width accesses
    // and linear/aligned WRAP ranges, not a generic wrapping converter.
    ofs_plat_axi_mem_if_map_bursts
      #(
        .UFLAG_NO_REPLY(PRIVATE_NO_REPLY),
        .PAGE_SIZE(4096),
        .NATURAL_ALIGNMENT(0)
        )
      packet_mapper
       (
        .mem_source,
        .mem_sink
        );

    // synthesis translate_off
    initial begin
        if (mem_source.DATA_WIDTH != 512 || mem_sink.DATA_WIDTH != 512 ||
            mem_sink.BURST_CNT_WIDTH != 2 ||
            mem_source.USER_WIDTH <= PRIVATE_NO_REPLY ||
            mem_sink.USER_WIDTH != mem_source.USER_WIDTH ||
            mem_sink.ADDR_WIDTH != mem_source.ADDR_WIDTH ||
            mem_sink.RID_WIDTH != mem_source.RID_WIDTH ||
            mem_sink.WID_WIDTH != mem_source.WID_WIDTH ||
            mem_sink.MASKED_SYMBOL_WIDTH != mem_source.MASKED_SYMBOL_WIDTH)
            $fatal(2, "packet-cap interface binding mismatch");
    end
    always_ff @(posedge mem_sink.clk) begin
        if (mem_sink.reset_n) begin
            if (mem_source.arvalid && mem_source.arready && mem_source.ar.user[PRIVATE_NO_REPLY])
                $fatal(2, "AFU consumed the reserved packet-cap AR USER bit");
            if (mem_source.awvalid && mem_source.awready && mem_source.aw.user[PRIVATE_NO_REPLY])
                $fatal(2, "AFU consumed the reserved packet-cap AW USER bit");
        end
    end
    // synthesis translate_on
endmodule

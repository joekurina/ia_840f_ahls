// SPDX-License-Identifier: MIT
`include "ofs_plat_if.vh"
// Physical host-memory sharing. PIM owns arbitration, burst tracking and
// response routing. This admission gate additionally keeps the D2H batch's
// last-write address valid until its fence has completed: no unrelated write
// may become the PIM's remembered fence-read address during that batch.
module asp_hostchannel_share (
    ofs_plat_avalon_mem_rdwr_if.to_sink host_mem,
    ofs_plat_avalon_mem_rdwr_if.to_source legacy,
    ofs_plat_avalon_mem_rdwr_if.to_source ingress,
    ofs_plat_avalon_mem_rdwr_if.to_source egress,
    input logic egress_idle,
    output logic share_fault
);
    ofs_plat_avalon_mem_rdwr_if #(
        `OFS_PLAT_AVALON_MEM_RDWR_IF_REPLICATE_PARAMS(host_mem)
    ) sources[3]();
    ofs_plat_avalon_mem_rdwr_if_mux #(
        .NUM_SOURCE_PORTS(3), .RD_TRACKER_DEPTH(256), .WR_TRACKER_DEPTH(128)
    ) host_mux (.mem_sink(host_mem), .mem_source(sources));
    typedef enum logic [1:0] {SHARED, ACQUIRE, EXCLUSIVE, RELEASE} state_t;
    state_t state;
    logic [host_mem.BURST_CNT_WIDTH-1:0] legacy_remaining;
    logic [15:0] legacy_outstanding;
    wire legacy_allowed = (state == SHARED) || (state == RELEASE) ||
                          ((state == ACQUIRE) && (legacy_remaining != 0));
    wire legacy_fire = sources[0].wr_write && !sources[0].wr_waitrequest;
    wire legacy_start = legacy_fire && (legacy_remaining == 0);
    wire legacy_reply_expected =
        !legacy.wr_user[ofs_plat_host_chan_avalon_mem_pkg::HC_AVALON_UFLAG_NO_REPLY];
    wire legacy_response = sources[0].wr_writeresponsevalid;
    always_comb begin
        `OFS_PLAT_AVALON_MEM_RDWR_IF_FROM_SOURCE_TO_SINK_COMB(sources[0], legacy);
        `OFS_PLAT_AVALON_MEM_RDWR_IF_FROM_SINK_TO_SOURCE_COMB(legacy, sources[0]);
        sources[0].wr_write = legacy.wr_write && legacy_allowed;
        legacy.wr_waitrequest = sources[0].wr_waitrequest || !legacy_allowed;
    end
    ofs_plat_avalon_mem_rdwr_if_connect ingress_connection (
        .mem_sink(sources[1]), .mem_source(ingress)
    );
    always_comb begin
        `OFS_PLAT_AVALON_MEM_RDWR_IF_FROM_SOURCE_TO_SINK_COMB(sources[2], egress);
        `OFS_PLAT_AVALON_MEM_RDWR_IF_FROM_SINK_TO_SOURCE_COMB(egress, sources[2]);
        sources[2].wr_write = egress.wr_write && (state == EXCLUSIVE);
        egress.wr_waitrequest = sources[2].wr_waitrequest || (state != EXCLUSIVE);
    end
    always_ff @(posedge host_mem.clk) begin
        if (!host_mem.reset_n) begin
            state <= SHARED;
            legacy_remaining <= 0;
            legacy_outstanding <= 0;
            share_fault <= 0;
        end else begin
            if (legacy_fire) begin
                if (legacy_remaining == 0)
                    legacy_remaining <= legacy.wr_burstcount - 1'b1;
                else legacy_remaining <= legacy_remaining - 1'b1;
            end
            case ({legacy_start && legacy_reply_expected, legacy_response})
                2'b10: legacy_outstanding <= legacy_outstanding + 1'b1;
                2'b01: legacy_outstanding <= legacy_outstanding - 1'b1;
                default: ;
            endcase
            // NO_REPLY is an internal PIM splitter flag, not supported at this
            // AFU physical-source boundary. Without its response no finite
            // source-side tracker can prove that a posted write left the mux.
            if ((legacy_start && (!legacy_reply_expected || legacy.wr_burstcount == 0)) ||
                (legacy_response && legacy_outstanding == 0 && !legacy_start))
                share_fault <= 1;
            case (state)
                SHARED: if (egress.wr_write) state <= ACQUIRE;
                ACQUIRE: if (legacy_remaining == 0 && legacy_outstanding == 0 && !share_fault)
                    state <= EXCLUSIVE;
                EXCLUSIVE: if (egress_idle && !egress.wr_write) state <= RELEASE;
                // Give the legacy source an admission cycle between batches.
                RELEASE: state <= SHARED;
                default: state <= SHARED;
            endcase
        end
    end
endmodule

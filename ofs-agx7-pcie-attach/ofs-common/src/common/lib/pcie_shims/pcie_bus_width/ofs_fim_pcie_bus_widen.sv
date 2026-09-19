// Copyright 2024 Intel Corporation
// SPDX-License-Identifier: MIT

//
// Map a narrow bus to a wider one. The width of the wide bus must be a
// multiple of the narrow bus width.
//

module ofs_fim_pcie_bus_widen
   (
    // Inbound narrow bus
    pcie_ss_axis_if.sink i_narrow_if,

    // Outbound wide bus
    pcie_ss_axis_if.source o_wide_if
    );

    wire clk = i_narrow_if.clk;
    wire rst_n = i_narrow_if.rst_n;

    localparam WIDE_TDATA_WIDTH = o_wide_if.DATA_W;
    localparam WIDE_TUSER_WIDTH = o_wide_if.USER_W;
    localparam WIDE_TKEEP_WIDTH = WIDE_TDATA_WIDTH / 8;

    localparam NARROW_TDATA_WIDTH = i_narrow_if.DATA_W;
    localparam NARROW_TUSER_WIDTH = i_narrow_if.USER_W;
    localparam NARROW_TKEEP_WIDTH = NARROW_TDATA_WIDTH / 8;

    localparam RATIO = WIDE_TDATA_WIDTH / NARROW_TDATA_WIDTH;

    initial
    begin : error_proc
        if (NARROW_TDATA_WIDTH * RATIO != WIDE_TDATA_WIDTH)
            $fatal(2, "** ERROR ** %m: Wide bus width (%0d) must be a multiple of narrow bus width (%0d)", WIDE_TDATA_WIDTH, NARROW_TDATA_WIDTH);
        if (WIDE_TUSER_WIDTH != NARROW_TUSER_WIDTH)
            $fatal(2, "** ERROR ** %m: Wide and narrow buses must have the same user width (%0d vs. %0d)", WIDE_TUSER_WIDTH, NARROW_TUSER_WIDTH);
    end

    if (RATIO == 1)
    begin : simple
        // Same width in and out -- direct connection
        ofs_fim_axis_pipeline #(.PL_DEPTH(0)) conn (.clk, .rst_n, .axis_s(i_narrow_if), .axis_m(o_wide_if));
    end
    else
    begin : m
        // Map narrow state to a wide register
        logic [$clog2(RATIO)-1:0] next_slot;
        logic full;

        logic [RATIO-1:0][NARROW_TDATA_WIDTH-1:0] tdata;
        logic [RATIO-1:0][NARROW_TKEEP_WIDTH-1:0] tkeep;
        logic tlast;
        logic [NARROW_TUSER_WIDTH-1:0] tuser;

        assign o_wide_if.tvalid = full;
        assign o_wide_if.tlast = tlast;
        assign o_wide_if.tuser_vendor = tuser;
        assign o_wide_if.tdata = tdata;
        assign o_wide_if.tkeep = tkeep;

        // Consume new input when wide buffer space is available
        assign i_narrow_if.tready = !full || o_wide_if.tready;

        // wide_to_full is set when the wide register has a full payload,
        // either because the packet ended or all slots are valid.
        wire wide_to_full = i_narrow_if.tlast || (next_slot == RATIO-1);

        always_ff @(posedge clk)
        begin
            // Accepting input?
            if (i_narrow_if.tready)
            begin
                if (!i_narrow_if.tvalid)
                begin
                    // No new input available
                    full <= 1'b0;
                end
                else
                begin
                    next_slot <= next_slot + 1;
                    full <= wide_to_full;
                    if (wide_to_full)
                        next_slot <= '0;

                    tlast <= i_narrow_if.tlast;
                    tdata[next_slot] <= i_narrow_if.tdata;
                    tkeep[next_slot] <= i_narrow_if.tkeep;

                    // Initialize wide output registers on start of each wide flit
                    if (next_slot == 0)
                    begin
                        tuser <= i_narrow_if.tuser_vendor;
                        tdata[RATIO-1:1] <= '0;
                        tkeep[RATIO-1:1] <= '0;
                    end
                end
            end

            if (!rst_n)
            begin
                next_slot <= '0;
                full <= 1'b0;
            end
        end
    end

endmodule // ofs_fim_pcie_bus_widen

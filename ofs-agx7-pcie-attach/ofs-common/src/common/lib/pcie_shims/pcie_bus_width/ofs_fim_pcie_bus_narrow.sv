// Copyright 2024 Intel Corporation
// SPDX-License-Identifier: MIT

//
// Map a wide bus to a narrower one. The width of the wide bus must be a
// multiple of the narrow bus width.
//

module ofs_fim_pcie_bus_narrow
   (
    // Inbound wide bus
    pcie_ss_axis_if.sink i_wide_if,

    // Outbound narrow bus
    pcie_ss_axis_if.source o_narrow_if
    );

    wire clk = i_wide_if.clk;
    wire rst_n = i_wide_if.rst_n;

    localparam WIDE_TDATA_WIDTH = i_wide_if.DATA_W;
    localparam WIDE_TUSER_WIDTH = i_wide_if.USER_W;
    localparam WIDE_TKEEP_WIDTH = WIDE_TDATA_WIDTH / 8;

    localparam NARROW_TDATA_WIDTH = o_narrow_if.DATA_W;
    localparam NARROW_TUSER_WIDTH = o_narrow_if.USER_W;
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
        ofs_fim_axis_pipeline #(.PL_DEPTH(0)) conn (.clk, .rst_n, .axis_s(i_wide_if), .axis_m(o_narrow_if));
    end
    else
    begin : m
        // Record wide state that will be streamed out in multiple cycles.
        logic tvalid;
        logic [RATIO-1:0][NARROW_TDATA_WIDTH-1:0] tdata;
        logic [RATIO-1:0][NARROW_TKEEP_WIDTH-1:0] tkeep;
        logic tlast;
        logic [NARROW_TUSER_WIDTH-1:0] tuser;

        // Use tkeep as valid bits. The wide data will be shifted right as it is
        // emitted to narrow, so valid is always the low tkeep bit.
        assign o_narrow_if.tvalid = tvalid;
        // Last only if no more wide data exists
        assign o_narrow_if.tlast = tlast && !tkeep[1][0];
        assign o_narrow_if.tuser_vendor = tuser;
        assign o_narrow_if.tdata = tdata[0];
        assign o_narrow_if.tkeep = tkeep[0];

        // Consume new input when the previous wide data is done
        assign i_wide_if.tready = !tvalid || (!tkeep[1][0] && o_narrow_if.tready);

        always_ff @(posedge clk)
        begin
            if (i_wide_if.tready)
            begin
                // Previous i_wide_if data fully transmitted. Process next wide beat.
                tvalid <= i_wide_if.tvalid;
                tlast <= i_wide_if.tlast;
                tuser <= i_wide_if.tuser_vendor;
                tdata <= i_wide_if.tdata;
                tkeep <= i_wide_if.tkeep;
            end
            else if (o_narrow_if.tready)
            begin
                // Output enabled. Process next narrow beat if there is data to send.
                tvalid <= tvalid && tkeep[1][0];
                tdata[0 +: RATIO-1] <= tdata[1 +: RATIO-1];
                tkeep[0 +: RATIO-1] <= tkeep[1 +: RATIO-1];
                tkeep[RATIO-1] <= '0;
            end

            if (!rst_n)
            begin
                tvalid <= 1'b0;
            end
        end
    end

endmodule // ofs_fim_pcie_bus_narrow

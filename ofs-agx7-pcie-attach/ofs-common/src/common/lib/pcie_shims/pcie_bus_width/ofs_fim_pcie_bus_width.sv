// Copyright 2024 Intel Corporation
// SPDX-License-Identifier: MIT

//
// Map AXI-S bus width from input to output. The ratio between the two widths
// must be a multiple of the smaller bus.
//

module ofs_fim_pcie_bus_width
   (
    // Inbound
    pcie_ss_axis_if.sink i_if,

    // Outbound
    pcie_ss_axis_if.source o_if
    );

    wire clk = i_if.clk;
    wire rst_n = i_if.rst_n;

    localparam IN_TDATA_WIDTH = i_if.DATA_W;
    localparam IN_TUSER_WIDTH = i_if.USER_W;

    localparam OUT_TDATA_WIDTH = o_if.DATA_W;
    localparam OUT_TUSER_WIDTH = o_if.USER_W;

    initial
    begin : error_proc
        if (IN_TUSER_WIDTH != OUT_TUSER_WIDTH)
            $fatal(2, "** ERROR ** %m: In and out buses must have the same user width (%0d vs. %0d)", IN_TUSER_WIDTH, OUT_TUSER_WIDTH);
    end

    if (IN_TDATA_WIDTH == OUT_TDATA_WIDTH)
    begin : simple
        // Same width in and out -- direct connection
        ofs_fim_axis_pipeline #(.PL_DEPTH(0)) conn (.clk, .rst_n, .axis_s(i_if), .axis_m(o_if));
    end
    else if (IN_TDATA_WIDTH > OUT_TDATA_WIDTH)
    begin : m
        ofs_fim_pcie_bus_narrow narrow (.i_wide_if(i_if), .o_narrow_if(o_if));
    end
    else
    begin : m
        ofs_fim_pcie_bus_widen widen (.i_narrow_if(i_if), .o_wide_if(o_if));
    end

endmodule // ofs_fim_pcie_bus_width

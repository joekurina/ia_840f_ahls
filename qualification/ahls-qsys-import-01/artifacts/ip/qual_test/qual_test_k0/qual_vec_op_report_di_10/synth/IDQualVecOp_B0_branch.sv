// ------------------------------------------------------------------------- 
// High Level Design Compiler for Altera(R) FPGAs Version 2026.1 (Release Build #fbe2a3c632)
// 
// Legal Notice: Copyright 2026 Altera Corporation.  All rights reserved.
// Your use of Altera Corporation's  design tools,  logic functions and other
// software and  tools, and  its AMPP partner logic functions, and any output
// files any  of the  foregoing (including  device programming  or simulation
// files), and  any associated  documentation  or  information  are expressly
// subject to the terms and  conditions  of the  Altera FPGA Software License
// Agreement, Altera MegaCore Function License Agreement, or other applicable
// license agreement,  including,  without limitation,  that  your use is for
// the  sole  purpose of  programming  logic devices  manufactured by  Altera
// and  sold by Altera  or its authorized  distributors. Please refer  to the
// applicable agreement for further details.
// ---------------------------------------------------------------------------

// SystemVerilog created from IDQualVecOp_B0_branch
// Created for function/kernel IDQualVecOp
// SystemVerilog created on Sat Sep 19 11:42:59 2026


(* altera_attribute = "-name AUTO_SHIFT_REGISTER_RECOGNITION OFF; -name MESSAGE_DISABLE 10036; -name MESSAGE_DISABLE 10037; -name MESSAGE_DISABLE 14130; -name MESSAGE_DISABLE 14320; -name MESSAGE_DISABLE 15400; -name MESSAGE_DISABLE 14130; -name MESSAGE_DISABLE 10036; -name MESSAGE_DISABLE 12020; -name MESSAGE_DISABLE 12030; -name MESSAGE_DISABLE 12010; -name MESSAGE_DISABLE 12110; -name MESSAGE_DISABLE 14320; -name MESSAGE_DISABLE 13410; -name MESSAGE_DISABLE 113007; -name MESSAGE_DISABLE 10958" *)
module IDQualVecOp_B0_branch (
    input wire [0:0] in_almost_empty_in,
    input wire [0:0] in_empty_in,
    input wire [0:0] in_stall_in_0,
    input wire [0:0] in_valid_in,
    output wire [0:0] out_stall_out,
    output wire [0:0] out_valid_out_0,
    input wire clock,
    input wire resetn
    );

    wire [0:0] IDQualVecOp_B0_branch_branch_storage_out_o_stall;
    wire [0:0] IDQualVecOp_B0_branch_branch_storage_out_o_valid;
    wire [1:0] c_i2_0_26_1gr_q;
    reg [0:0] rst_sync_rst_sclrn;


    // c_i2_0_26_1gr(CONSTANT,3)
    assign c_i2_0_26_1gr_q = 2'b00;

    // IDQualVecOp_B0_branch_branch_storage(BLACKBOX,2)
    IDQualVecOp_B0_branch_branch_storage theIDQualVecOp_B0_branch_branch_storage (
        .in_almost_empty_in(in_almost_empty_in),
        .in_empty_in(in_empty_in),
        .in_i_data(c_i2_0_26_1gr_q),
        .in_i_stall(in_stall_in_0),
        .in_i_valid(in_valid_in),
        .out_o_almost_empty(),
        .out_o_data(),
        .out_o_empty(),
        .out_o_stall(IDQualVecOp_B0_branch_branch_storage_out_o_stall),
        .out_o_valid(IDQualVecOp_B0_branch_branch_storage_out_o_valid),
        .clock(clock),
        .resetn(resetn)
    );

    // out_stall_out(GPOUT,8)
    assign out_stall_out = IDQualVecOp_B0_branch_branch_storage_out_o_stall;

    // out_valid_out_0(GPOUT,9)
    assign out_valid_out_0 = IDQualVecOp_B0_branch_branch_storage_out_o_valid;

    // rst_sync(RESETSYNC,10)
    acl_reset_handler #(
        .ASYNC_RESET(0),
        .USE_SYNCHRONIZER(1),
        .PULSE_EXTENSION(0),
        .PIPE_DEPTH(3),
        .DUPLICATE(1)
    ) therst_sync (
        .clk(clock),
        .i_resetn(resetn),
        .o_sclrn(rst_sync_rst_sclrn)
    );

endmodule

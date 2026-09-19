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

// SystemVerilog created from bb_IDQualVecOp_B0
// Created for function/kernel IDQualVecOp
// SystemVerilog created on Sat Sep 19 11:42:59 2026


(* altera_attribute = "-name AUTO_SHIFT_REGISTER_RECOGNITION OFF; -name MESSAGE_DISABLE 10036; -name MESSAGE_DISABLE 10037; -name MESSAGE_DISABLE 14130; -name MESSAGE_DISABLE 14320; -name MESSAGE_DISABLE 15400; -name MESSAGE_DISABLE 14130; -name MESSAGE_DISABLE 10036; -name MESSAGE_DISABLE 12020; -name MESSAGE_DISABLE 12030; -name MESSAGE_DISABLE 12010; -name MESSAGE_DISABLE 12110; -name MESSAGE_DISABLE 14320; -name MESSAGE_DISABLE 13410; -name MESSAGE_DISABLE 113007; -name MESSAGE_DISABLE 10958" *)
module IDQualVecOp_bb_B0 (
    input wire [31:0] in_arg_a,
    input wire [31:0] in_arg_b,
    input wire [31:0] in_arg_mode,
    input wire [0:0] in_avst_iowr_nb_acl_c_ResultPipeID_pipe_channel_almostfull,
    input wire [0:0] in_stall_in_0,
    input wire [0:0] in_valid_in_0,
    output wire [31:0] out_iowr_nb_acl_c_ResultPipeID_pipe_channel_o_fifodata,
    output wire [0:0] out_iowr_nb_acl_c_ResultPipeID_pipe_channel_o_fifovalid,
    output wire [0:0] out_stall_out_0,
    output wire [0:0] out_valid_out_0,
    input wire clock,
    input wire resetn
    );

    wire [0:0] IDQualVecOp_B0_branch_out_stall_out;
    wire [0:0] IDQualVecOp_B0_branch_out_valid_out_0;
    wire [0:0] IDQualVecOp_B0_merge_out_almost_empty_out;
    wire [0:0] IDQualVecOp_B0_merge_out_empty_out;
    wire [0:0] IDQualVecOp_B0_merge_out_stall_out_0;
    wire [0:0] IDQualVecOp_B0_merge_out_valid_out;
    wire [0:0] bb_IDQualVecOp_B0_stall_region_out_almost_empty_out;
    wire [0:0] bb_IDQualVecOp_B0_stall_region_out_empty_out;
    wire [31:0] bb_IDQualVecOp_B0_stall_region_out_iowr_nb_acl_c_ResultPipeID_pipe_channel_o_fifodata;
    wire [0:0] bb_IDQualVecOp_B0_stall_region_out_iowr_nb_acl_c_ResultPipeID_pipe_channel_o_fifovalid;
    wire [0:0] bb_IDQualVecOp_B0_stall_region_out_stall_out;
    wire [0:0] bb_IDQualVecOp_B0_stall_region_out_valid_out;
    reg [0:0] rst_sync_rst_sclrn;


    // IDQualVecOp_B0_branch(BLACKBOX,2)
    IDQualVecOp_B0_branch theIDQualVecOp_B0_branch (
        .in_almost_empty_in(bb_IDQualVecOp_B0_stall_region_out_almost_empty_out),
        .in_empty_in(bb_IDQualVecOp_B0_stall_region_out_empty_out),
        .in_stall_in_0(in_stall_in_0),
        .in_valid_in(bb_IDQualVecOp_B0_stall_region_out_valid_out),
        .out_stall_out(IDQualVecOp_B0_branch_out_stall_out),
        .out_valid_out_0(IDQualVecOp_B0_branch_out_valid_out_0),
        .clock(clock),
        .resetn(resetn)
    );

    // IDQualVecOp_B0_merge(BLACKBOX,3)
    IDQualVecOp_B0_merge theIDQualVecOp_B0_merge (
        .in_stall_in(bb_IDQualVecOp_B0_stall_region_out_stall_out),
        .in_valid_in_0(in_valid_in_0),
        .out_almost_empty_out(IDQualVecOp_B0_merge_out_almost_empty_out),
        .out_empty_out(IDQualVecOp_B0_merge_out_empty_out),
        .out_stall_out_0(IDQualVecOp_B0_merge_out_stall_out_0),
        .out_valid_out(IDQualVecOp_B0_merge_out_valid_out),
        .clock(clock),
        .resetn(resetn)
    );

    // bb_IDQualVecOp_B0_stall_region(BLACKBOX,4)
    IDQualVecOp_bb_B0_stall_region thebb_IDQualVecOp_B0_stall_region (
        .in_almost_empty_in(IDQualVecOp_B0_merge_out_almost_empty_out),
        .in_arg_a(in_arg_a),
        .in_arg_b(in_arg_b),
        .in_arg_mode(in_arg_mode),
        .in_avst_iowr_nb_acl_c_ResultPipeID_pipe_channel_almostfull(in_avst_iowr_nb_acl_c_ResultPipeID_pipe_channel_almostfull),
        .in_empty_in(IDQualVecOp_B0_merge_out_empty_out),
        .in_stall_in(IDQualVecOp_B0_branch_out_stall_out),
        .in_valid_in(IDQualVecOp_B0_merge_out_valid_out),
        .out_almost_empty_out(bb_IDQualVecOp_B0_stall_region_out_almost_empty_out),
        .out_empty_out(bb_IDQualVecOp_B0_stall_region_out_empty_out),
        .out_iowr_nb_acl_c_ResultPipeID_pipe_channel_o_fifodata(bb_IDQualVecOp_B0_stall_region_out_iowr_nb_acl_c_ResultPipeID_pipe_channel_o_fifodata),
        .out_iowr_nb_acl_c_ResultPipeID_pipe_channel_o_fifovalid(bb_IDQualVecOp_B0_stall_region_out_iowr_nb_acl_c_ResultPipeID_pipe_channel_o_fifovalid),
        .out_stall_out(bb_IDQualVecOp_B0_stall_region_out_stall_out),
        .out_valid_out(bb_IDQualVecOp_B0_stall_region_out_valid_out),
        .clock(clock),
        .resetn(resetn)
    );

    // out_iowr_nb_acl_c_ResultPipeID_pipe_channel_o_fifodata(GPOUT,11)
    assign out_iowr_nb_acl_c_ResultPipeID_pipe_channel_o_fifodata = bb_IDQualVecOp_B0_stall_region_out_iowr_nb_acl_c_ResultPipeID_pipe_channel_o_fifodata;

    // out_iowr_nb_acl_c_ResultPipeID_pipe_channel_o_fifovalid(GPOUT,12)
    assign out_iowr_nb_acl_c_ResultPipeID_pipe_channel_o_fifovalid = bb_IDQualVecOp_B0_stall_region_out_iowr_nb_acl_c_ResultPipeID_pipe_channel_o_fifovalid;

    // out_stall_out_0(GPOUT,13)
    assign out_stall_out_0 = IDQualVecOp_B0_merge_out_stall_out_0;

    // out_valid_out_0(GPOUT,14)
    assign out_valid_out_0 = IDQualVecOp_B0_branch_out_valid_out_0;

    // rst_sync(RESETSYNC,15)
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

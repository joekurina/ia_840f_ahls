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

// SystemVerilog created from IDQualVecOp_function
// Created for function/kernel IDQualVecOp
// SystemVerilog created on Sat Sep 19 11:42:59 2026


(* altera_attribute = "-name AUTO_SHIFT_REGISTER_RECOGNITION OFF; -name MESSAGE_DISABLE 10036; -name MESSAGE_DISABLE 10037; -name MESSAGE_DISABLE 14130; -name MESSAGE_DISABLE 14320; -name MESSAGE_DISABLE 15400; -name MESSAGE_DISABLE 14130; -name MESSAGE_DISABLE 10036; -name MESSAGE_DISABLE 12020; -name MESSAGE_DISABLE 12030; -name MESSAGE_DISABLE 12010; -name MESSAGE_DISABLE 12110; -name MESSAGE_DISABLE 14320; -name MESSAGE_DISABLE 13410; -name MESSAGE_DISABLE 113007; -name MESSAGE_DISABLE 10958" *)
module IDQualVecOp_function (
    input wire [31:0] in_arg_arg_a,
    input wire [31:0] in_arg_arg_b,
    input wire [31:0] in_arg_arg_mode,
    input wire [0:0] in_avst_iowr_nb_acl_c_ResultPipeID_pipe_channel_almostfull,
    input wire [0:0] in_stall_in,
    input wire [0:0] in_start,
    input wire [0:0] in_valid_in,
    output wire [31:0] out_iowr_nb_acl_c_ResultPipeID_pipe_channel_o_fifodata,
    output wire [0:0] out_iowr_nb_acl_c_ResultPipeID_pipe_channel_o_fifovalid,
    output wire [0:0] out_stall_out,
    output wire [0:0] out_valid_out,
    input wire clock,
    input wire resetn
    );

    wire [0:0] VCC_q;
    wire [0:0] IDQualVecOp_function_i_enable;
    wire IDQualVecOp_function_i_enable_bitsignaltemp;
    wire [0:0] IDQualVecOp_function_i_end;
    wire IDQualVecOp_function_i_end_bitsignaltemp;
    wire [0:0] IDQualVecOp_function_i_start;
    wire IDQualVecOp_function_i_start_bitsignaltemp;
    wire [31:0] bb_IDQualVecOp_B0_out_iowr_nb_acl_c_ResultPipeID_pipe_channel_o_fifodata;
    wire [0:0] bb_IDQualVecOp_B0_out_iowr_nb_acl_c_ResultPipeID_pipe_channel_o_fifovalid;
    wire [0:0] bb_IDQualVecOp_B0_out_stall_out_0;
    wire [0:0] bb_IDQualVecOp_B0_out_valid_out_0;
    reg [0:0] rst_sync_rst_sclrn;


    // bb_IDQualVecOp_B0(BLACKBOX,3)
    IDQualVecOp_bb_B0 thebb_IDQualVecOp_B0 (
        .in_arg_a(in_arg_arg_a),
        .in_arg_b(in_arg_arg_b),
        .in_arg_mode(in_arg_arg_mode),
        .in_avst_iowr_nb_acl_c_ResultPipeID_pipe_channel_almostfull(in_avst_iowr_nb_acl_c_ResultPipeID_pipe_channel_almostfull),
        .in_stall_in_0(in_stall_in),
        .in_valid_in_0(in_valid_in),
        .out_iowr_nb_acl_c_ResultPipeID_pipe_channel_o_fifodata(bb_IDQualVecOp_B0_out_iowr_nb_acl_c_ResultPipeID_pipe_channel_o_fifodata),
        .out_iowr_nb_acl_c_ResultPipeID_pipe_channel_o_fifovalid(bb_IDQualVecOp_B0_out_iowr_nb_acl_c_ResultPipeID_pipe_channel_o_fifovalid),
        .out_stall_out_0(bb_IDQualVecOp_B0_out_stall_out_0),
        .out_valid_out_0(bb_IDQualVecOp_B0_out_valid_out_0),
        .clock(clock),
        .resetn(resetn)
    );

    // VCC(CONSTANT,1)
    assign VCC_q = 1'b1;

    // IDQualVecOp_function(EXTIFACE,2)
    assign IDQualVecOp_function_i_enable = VCC_q;
    assign IDQualVecOp_function_i_end = bb_IDQualVecOp_B0_out_valid_out_0;
    assign IDQualVecOp_function_i_start = in_start;
    assign IDQualVecOp_function_i_enable_bitsignaltemp = IDQualVecOp_function_i_enable[0];
    assign IDQualVecOp_function_i_end_bitsignaltemp = IDQualVecOp_function_i_end[0];
    assign IDQualVecOp_function_i_start_bitsignaltemp = IDQualVecOp_function_i_start[0];
    hld_sim_latency_tracker #(
        .ADDITIONAL_START_LATENCY(9),
        .CRA_CONTROL(1),
        .IS_COMPONENT(1),
        .NAME("IDQualVecOp")
    ) theIDQualVecOp_function (
        .i_enable(IDQualVecOp_function_i_enable_bitsignaltemp),
        .i_end(IDQualVecOp_function_i_end_bitsignaltemp),
        .i_start(IDQualVecOp_function_i_start_bitsignaltemp),
        .clock(clock),
        .resetn(rst_sync_rst_sclrn[0])
    );

    // out_iowr_nb_acl_c_ResultPipeID_pipe_channel_o_fifodata(GPOUT,12)
    assign out_iowr_nb_acl_c_ResultPipeID_pipe_channel_o_fifodata = bb_IDQualVecOp_B0_out_iowr_nb_acl_c_ResultPipeID_pipe_channel_o_fifodata;

    // out_iowr_nb_acl_c_ResultPipeID_pipe_channel_o_fifovalid(GPOUT,13)
    assign out_iowr_nb_acl_c_ResultPipeID_pipe_channel_o_fifovalid = bb_IDQualVecOp_B0_out_iowr_nb_acl_c_ResultPipeID_pipe_channel_o_fifovalid;

    // out_stall_out(GPOUT,14)
    assign out_stall_out = bb_IDQualVecOp_B0_out_stall_out_0;

    // out_valid_out(GPOUT,15)
    assign out_valid_out = bb_IDQualVecOp_B0_out_valid_out_0;

    // rst_sync(RESETSYNC,16)
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

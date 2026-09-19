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

// SystemVerilog created from i_iowr_nb_acl_c_resultpipeid_pipe_channel_unnamed_idqualvecop2_idqualvecop_168_0gr
// Created for function/kernel IDQualVecOp
// SystemVerilog created on Sat Sep 19 11:42:59 2026


(* altera_attribute = "-name AUTO_SHIFT_REGISTER_RECOGNITION OFF; -name MESSAGE_DISABLE 10036; -name MESSAGE_DISABLE 10037; -name MESSAGE_DISABLE 14130; -name MESSAGE_DISABLE 14320; -name MESSAGE_DISABLE 15400; -name MESSAGE_DISABLE 14130; -name MESSAGE_DISABLE 10036; -name MESSAGE_DISABLE 12020; -name MESSAGE_DISABLE 12030; -name MESSAGE_DISABLE 12010; -name MESSAGE_DISABLE 12110; -name MESSAGE_DISABLE 14320; -name MESSAGE_DISABLE 13410; -name MESSAGE_DISABLE 113007; -name MESSAGE_DISABLE 10958" *)
module IDQualVecOp_i_iowr_nb_acl_c_resultpipeid0000_idqualvecop_168_0gr (
    output wire [31:0] out_iowr_nb_acl_c_ResultPipeID_pipe_channel_o_fifodata,
    output wire [0:0] out_iowr_nb_acl_c_ResultPipeID_pipe_channel_o_fifovalid,
    input wire [0:0] in_i_stall,
    output wire [0:0] out_o_stall,
    output wire [0:0] out_o_ack,
    output wire [0:0] out_o_valid,
    input wire [31:0] in_i_data,
    input wire [0:0] in_i_valid,
    input wire [0:0] in_unnamed_IDQualVecOp1,
    input wire clock,
    input wire resetn
    );

    wire [0:0] VCC_q;
    wire [31:0] c32_0_q;
    wire [31:0] iowr_nb_i_data;
    wire [0:0] iowr_nb_i_fifoready;
    wire iowr_nb_i_fifoready_bitsignaltemp;
    wire [31:0] iowr_nb_i_fifosize;
    wire [0:0] iowr_nb_i_predicate;
    wire iowr_nb_i_predicate_bitsignaltemp;
    wire [0:0] iowr_nb_i_stall;
    wire iowr_nb_i_stall_bitsignaltemp;
    wire [0:0] iowr_nb_i_valid;
    wire iowr_nb_i_valid_bitsignaltemp;
    wire [0:0] iowr_nb_o_ack;
    wire iowr_nb_o_ack_bitsignaltemp;
    wire [31:0] iowr_nb_o_fifodata;
    wire [0:0] iowr_nb_o_fifovalid;
    wire iowr_nb_o_fifovalid_bitsignaltemp;
    wire [0:0] iowr_nb_o_stall;
    wire iowr_nb_o_stall_bitsignaltemp;
    wire [0:0] iowr_nb_o_valid;
    wire iowr_nb_o_valid_bitsignaltemp;
    wire [31:0] iowr_nb_profile_total_fifo_size_incr;


    // c32_0(CONSTANT,3)
    assign c32_0_q = 32'b00000000000000000000000000000000;

    // VCC(CONSTANT,1)
    assign VCC_q = 1'b1;

    // iowr_nb(EXTIFACE,5)@6
    assign iowr_nb_i_data = in_i_data;
    assign iowr_nb_i_fifoready = VCC_q;
    assign iowr_nb_i_fifosize = c32_0_q;
    assign iowr_nb_i_predicate = in_unnamed_IDQualVecOp1;
    assign iowr_nb_i_stall = in_i_stall;
    assign iowr_nb_i_valid = in_i_valid;
    assign iowr_nb_i_fifoready_bitsignaltemp = iowr_nb_i_fifoready[0];
    assign iowr_nb_i_predicate_bitsignaltemp = iowr_nb_i_predicate[0];
    assign iowr_nb_i_stall_bitsignaltemp = iowr_nb_i_stall[0];
    assign iowr_nb_i_valid_bitsignaltemp = iowr_nb_i_valid[0];
    assign iowr_nb_o_ack[0] = iowr_nb_o_ack_bitsignaltemp;
    assign iowr_nb_o_fifovalid[0] = iowr_nb_o_fifovalid_bitsignaltemp;
    assign iowr_nb_o_stall[0] = iowr_nb_o_stall_bitsignaltemp;
    assign iowr_nb_o_valid[0] = iowr_nb_o_valid_bitsignaltemp;
    hld_iowr #(
        .ALMOST_FULL_CUTOFF_SIDEPATH(0),
        .CAPACITY_FROM_CHANNEL(0),
        .DISCONNECT_DOWNSTREAM(0),
        .INTER_KERNEL_PIPELINING(0),
        .USE_STALL_LATENCY_SIDEPATH(0),
        .ALLOW_HIGH_SPEED_FIFO_USAGE(0),
        .ASYNC_RESET(0),
        .CUTPATHS(0),
        .DATA_WIDTH(32),
        .ENABLED(0),
        .NON_BLOCKING(1),
        .SYNCHRONIZE_RESET(0)
    ) theiowr_nb (
        .i_data(in_i_data),
        .i_fifoready(iowr_nb_i_fifoready_bitsignaltemp),
        .i_fifosize(c32_0_q),
        .i_predicate(iowr_nb_i_predicate_bitsignaltemp),
        .i_stall(iowr_nb_i_stall_bitsignaltemp),
        .i_valid(iowr_nb_i_valid_bitsignaltemp),
        .o_ack(iowr_nb_o_ack_bitsignaltemp),
        .o_fifodata(iowr_nb_o_fifodata),
        .o_fifovalid(iowr_nb_o_fifovalid_bitsignaltemp),
        .o_stall(iowr_nb_o_stall_bitsignaltemp),
        .o_valid(iowr_nb_o_valid_bitsignaltemp),
        .profile_total_fifo_size_incr(),
        .clock(clock),
        .resetn(resetn)
    );

    // ext_sig_sync_out(GPOUT,4)
    assign out_iowr_nb_acl_c_ResultPipeID_pipe_channel_o_fifodata = iowr_nb_o_fifodata;
    assign out_iowr_nb_acl_c_ResultPipeID_pipe_channel_o_fifovalid = iowr_nb_o_fifovalid;

    // sync_out_38(GPOUT,7)@6
    assign out_o_stall = iowr_nb_o_stall;

    // sync_out_39(GPOUT,8)@6
    assign out_o_ack = iowr_nb_o_ack;
    assign out_o_valid = iowr_nb_o_valid;

endmodule

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

// SystemVerilog created from bb_IDQualVecOp_B0_stall_region
// Created for function/kernel IDQualVecOp
// SystemVerilog created on Sat Sep 19 11:42:59 2026


(* altera_attribute = "-name AUTO_SHIFT_REGISTER_RECOGNITION OFF; -name MESSAGE_DISABLE 10036; -name MESSAGE_DISABLE 10037; -name MESSAGE_DISABLE 14130; -name MESSAGE_DISABLE 14320; -name MESSAGE_DISABLE 15400; -name MESSAGE_DISABLE 14130; -name MESSAGE_DISABLE 10036; -name MESSAGE_DISABLE 12020; -name MESSAGE_DISABLE 12030; -name MESSAGE_DISABLE 12010; -name MESSAGE_DISABLE 12110; -name MESSAGE_DISABLE 14320; -name MESSAGE_DISABLE 13410; -name MESSAGE_DISABLE 113007; -name MESSAGE_DISABLE 10958" *)
module IDQualVecOp_bb_B0_stall_region (
    input wire [0:0] in_avst_iowr_nb_acl_c_ResultPipeID_pipe_channel_almostfull,
    output wire [31:0] out_iowr_nb_acl_c_ResultPipeID_pipe_channel_o_fifodata,
    output wire [0:0] out_iowr_nb_acl_c_ResultPipeID_pipe_channel_o_fifovalid,
    input wire [31:0] in_arg_a,
    input wire [31:0] in_arg_b,
    input wire [31:0] in_arg_mode,
    input wire [0:0] in_stall_in,
    output wire [0:0] out_stall_out,
    output wire [0:0] out_almost_empty_out,
    output wire [0:0] out_empty_out,
    output wire [0:0] out_valid_out,
    input wire [0:0] in_almost_empty_in,
    input wire [0:0] in_empty_in,
    input wire [0:0] in_valid_in,
    input wire clock,
    input wire resetn
    );

    wire [0:0] GND_q;
    wire [0:0] i_sfc_s_c0_in_entry_idqualvecops_c0_enter_idqualvecop_35_0gr_aunroll_x_out_almost_empty_out;
    wire [0:0] i_sfc_s_c0_in_entry_idqualvecops_c0_enter_idqualvecop_35_0gr_aunroll_x_out_empty_out;
    wire [31:0] i_sfc_s_c0_in_entry_idqualvecops_c0_enter_idqualvecop_35_0gr_aunroll_x_out_iowr_nb_acl_c_ResultPipeID_pipe_channel_o_fifodata;
    wire [0:0] i_sfc_s_c0_in_entry_idqualvecops_c0_enter_idqualvecop_35_0gr_aunroll_x_out_iowr_nb_acl_c_ResultPipeID_pipe_channel_o_fifovalid;
    wire [0:0] i_sfc_s_c0_in_entry_idqualvecops_c0_enter_idqualvecop_35_0gr_aunroll_x_out_o_stall;
    wire [0:0] i_sfc_s_c0_in_entry_idqualvecops_c0_enter_idqualvecop_35_0gr_aunroll_x_out_o_valid;
    wire [0:0] merged_in_SE_stall_entry_backStall;
    wire [0:0] merged_in_SE_stall_entry_V0;
    wire [0:0] merged_in_SE_stall_entry_V1;
    wire [0:0] merged_in_SE_stall_entry_V2;
    wire [0:0] merged_in_SE_stall_entry_temp_back_stall;
    wire [0:0] merged_in_SE_out_i_sfc_s_c0_in_entry_idqualvecops_c0_enter_idqualvecop_35_0gr_aunroll_x_backStall;
    wire [0:0] merged_in_SE_out_i_sfc_s_c0_in_entry_idqualvecops_c0_enter_idqualvecop_35_0gr_aunroll_x_V0;
    wire [0:0] merged_in_SE_out_i_sfc_s_c0_in_entry_idqualvecops_c0_enter_idqualvecop_35_0gr_aunroll_x_V1;
    wire [0:0] merged_in_SE_out_i_sfc_s_c0_in_entry_idqualvecops_c0_enter_idqualvecop_35_0gr_aunroll_x_V2;
    wire [0:0] merged_in_SE_out_i_sfc_s_c0_in_entry_idqualvecops_c0_enter_idqualvecop_35_0gr_aunroll_x_temp_back_stall;
    reg [0:0] stall_entry_frontStall_reg0_q;
    reg [0:0] stall_entry_frontStall_reg1_q;
    reg [0:0] stall_entry_frontValid_reg1_q;
    reg [0:0] stall_entry_frontValid_reg0_q;
    reg [0:0] stall_entry_frontEmpty_reg1_q;
    reg [0:0] stall_entry_frontEmpty_reg0_q;
    reg [0:0] stall_entry_frontAlmostEmpty_reg1_q;
    reg [0:0] stall_entry_frontAlmostEmpty_reg0_q;
    reg [0:0] i_sfc_s_c0_in_entry_idqualvecops_c0_enter_idqualvecop_35_0gr_aunroll_x_in_i_stall_reg0_q;
    reg [0:0] i_sfc_s_c0_in_entry_idqualvecops_c0_enter_idqualvecop_35_0gr_aunroll_x_in_i_stall_reg1_q;
    reg [0:0] i_sfc_s_c0_in_entry_idqualvecops_c0_enter_idqualvecop_35_0gr_aunroll_x_out_almost_empty_out_reg1_q;
    reg [0:0] i_sfc_s_c0_in_entry_idqualvecops_c0_enter_idqualvecop_35_0gr_aunroll_x_out_almost_empty_out_reg0_q;
    reg [0:0] i_sfc_s_c0_in_entry_idqualvecops_c0_enter_idqualvecop_35_0gr_aunroll_x_out_empty_out_reg1_q;
    reg [0:0] i_sfc_s_c0_in_entry_idqualvecops_c0_enter_idqualvecop_35_0gr_aunroll_x_out_empty_out_reg0_q;
    reg [0:0] i_sfc_s_c0_in_entry_idqualvecops_c0_enter_idqualvecop_35_0gr_aunroll_x_out_o_valid_reg1_q;
    reg [0:0] i_sfc_s_c0_in_entry_idqualvecops_c0_enter_idqualvecop_35_0gr_aunroll_x_out_o_valid_reg0_q;
    reg [0:0] rst_sync_rst_sclrn;


    // GND(CONSTANT,0)
    assign GND_q = 1'b0;

    // i_sfc_s_c0_in_entry_idqualvecops_c0_enter_idqualvecop_35_0gr_aunroll_x_out_almost_empty_out_reg0(REG,42)
    always_ff @ (posedge clock) begin
        i_sfc_s_c0_in_entry_idqualvecops_c0_enter_idqualvecop_35_0gr_aunroll_x_out_almost_empty_out_reg0_q <= i_sfc_s_c0_in_entry_idqualvecops_c0_enter_idqualvecop_35_0gr_aunroll_x_out_almost_empty_out;
    end

    // i_sfc_s_c0_in_entry_idqualvecops_c0_enter_idqualvecop_35_0gr_aunroll_x_out_almost_empty_out_reg1(REG,41)
    always_ff @ (posedge clock) begin
        i_sfc_s_c0_in_entry_idqualvecops_c0_enter_idqualvecop_35_0gr_aunroll_x_out_almost_empty_out_reg1_q <= i_sfc_s_c0_in_entry_idqualvecops_c0_enter_idqualvecop_35_0gr_aunroll_x_out_almost_empty_out_reg0_q;
    end

    // i_sfc_s_c0_in_entry_idqualvecops_c0_enter_idqualvecop_35_0gr_aunroll_x_out_empty_out_reg0(REG,44)
    always_ff @ (posedge clock) begin
        i_sfc_s_c0_in_entry_idqualvecops_c0_enter_idqualvecop_35_0gr_aunroll_x_out_empty_out_reg0_q <= i_sfc_s_c0_in_entry_idqualvecops_c0_enter_idqualvecop_35_0gr_aunroll_x_out_empty_out;
    end

    // i_sfc_s_c0_in_entry_idqualvecops_c0_enter_idqualvecop_35_0gr_aunroll_x_out_empty_out_reg1(REG,43)
    always_ff @ (posedge clock) begin
        i_sfc_s_c0_in_entry_idqualvecops_c0_enter_idqualvecop_35_0gr_aunroll_x_out_empty_out_reg1_q <= i_sfc_s_c0_in_entry_idqualvecops_c0_enter_idqualvecop_35_0gr_aunroll_x_out_empty_out_reg0_q;
    end

    // i_sfc_s_c0_in_entry_idqualvecops_c0_enter_idqualvecop_35_0gr_aunroll_x_out_o_valid_reg0(REG,46)
    always_ff @ (posedge clock) begin
        i_sfc_s_c0_in_entry_idqualvecops_c0_enter_idqualvecop_35_0gr_aunroll_x_out_o_valid_reg0_q <= i_sfc_s_c0_in_entry_idqualvecops_c0_enter_idqualvecop_35_0gr_aunroll_x_out_o_valid;
    end

    // i_sfc_s_c0_in_entry_idqualvecops_c0_enter_idqualvecop_35_0gr_aunroll_x_out_o_valid_reg1(REG,45)
    always_ff @ (posedge clock) begin
        i_sfc_s_c0_in_entry_idqualvecops_c0_enter_idqualvecop_35_0gr_aunroll_x_out_o_valid_reg1_q <= i_sfc_s_c0_in_entry_idqualvecops_c0_enter_idqualvecop_35_0gr_aunroll_x_out_o_valid_reg0_q;
    end

    // merged_in_SE_out_i_sfc_s_c0_in_entry_idqualvecops_c0_enter_idqualvecop_35_0gr_aunroll_x(STALLENABLE,30)
    assign merged_in_SE_out_i_sfc_s_c0_in_entry_idqualvecops_c0_enter_idqualvecop_35_0gr_aunroll_x_backStall = in_stall_in;
    assign merged_in_SE_out_i_sfc_s_c0_in_entry_idqualvecops_c0_enter_idqualvecop_35_0gr_aunroll_x_V0 = i_sfc_s_c0_in_entry_idqualvecops_c0_enter_idqualvecop_35_0gr_aunroll_x_out_o_valid_reg1_q;
    assign merged_in_SE_out_i_sfc_s_c0_in_entry_idqualvecops_c0_enter_idqualvecop_35_0gr_aunroll_x_V1 = i_sfc_s_c0_in_entry_idqualvecops_c0_enter_idqualvecop_35_0gr_aunroll_x_out_empty_out_reg1_q;
    assign merged_in_SE_out_i_sfc_s_c0_in_entry_idqualvecops_c0_enter_idqualvecop_35_0gr_aunroll_x_V2 = i_sfc_s_c0_in_entry_idqualvecops_c0_enter_idqualvecop_35_0gr_aunroll_x_out_almost_empty_out_reg1_q;

    // i_sfc_s_c0_in_entry_idqualvecops_c0_enter_idqualvecop_35_0gr_aunroll_x_in_i_stall_reg0(REG,39)
    always_ff @ (posedge clock) begin
        i_sfc_s_c0_in_entry_idqualvecops_c0_enter_idqualvecop_35_0gr_aunroll_x_in_i_stall_reg0_q <= merged_in_SE_out_i_sfc_s_c0_in_entry_idqualvecops_c0_enter_idqualvecop_35_0gr_aunroll_x_backStall;
    end

    // i_sfc_s_c0_in_entry_idqualvecops_c0_enter_idqualvecop_35_0gr_aunroll_x_in_i_stall_reg1(REG,40)
    always_ff @ (posedge clock) begin
        i_sfc_s_c0_in_entry_idqualvecops_c0_enter_idqualvecop_35_0gr_aunroll_x_in_i_stall_reg1_q <= i_sfc_s_c0_in_entry_idqualvecops_c0_enter_idqualvecop_35_0gr_aunroll_x_in_i_stall_reg0_q;
    end

    // stall_entry_frontAlmostEmpty_reg0(REG,38)
    always_ff @ (posedge clock) begin
        stall_entry_frontAlmostEmpty_reg0_q <= in_almost_empty_in;
    end

    // stall_entry_frontAlmostEmpty_reg1(REG,37)
    always_ff @ (posedge clock) begin
        stall_entry_frontAlmostEmpty_reg1_q <= stall_entry_frontAlmostEmpty_reg0_q;
    end

    // stall_entry_frontEmpty_reg0(REG,36)
    always_ff @ (posedge clock) begin
        stall_entry_frontEmpty_reg0_q <= in_empty_in;
    end

    // stall_entry_frontEmpty_reg1(REG,35)
    always_ff @ (posedge clock) begin
        stall_entry_frontEmpty_reg1_q <= stall_entry_frontEmpty_reg0_q;
    end

    // stall_entry_frontValid_reg0(REG,34)
    always_ff @ (posedge clock) begin
        stall_entry_frontValid_reg0_q <= in_valid_in;
    end

    // stall_entry_frontValid_reg1(REG,33)
    always_ff @ (posedge clock) begin
        stall_entry_frontValid_reg1_q <= stall_entry_frontValid_reg0_q;
    end

    // merged_in_SE_stall_entry(STALLENABLE,29)
    assign merged_in_SE_stall_entry_backStall = i_sfc_s_c0_in_entry_idqualvecops_c0_enter_idqualvecop_35_0gr_aunroll_x_out_o_stall;
    assign merged_in_SE_stall_entry_V0 = stall_entry_frontValid_reg1_q;
    assign merged_in_SE_stall_entry_V1 = stall_entry_frontEmpty_reg1_q;
    assign merged_in_SE_stall_entry_V2 = stall_entry_frontAlmostEmpty_reg1_q;

    // i_sfc_s_c0_in_entry_idqualvecops_c0_enter_idqualvecop_35_0gr_aunroll_x(BLACKBOX,18)@0
    // in in_i_stall@20000000
    // out out_almost_empty_out@37
    // out out_empty_out@37
    // out out_iowr_nb_acl_c_ResultPipeID_pipe_channel_o_fifodata@20000000
    // out out_iowr_nb_acl_c_ResultPipeID_pipe_channel_o_fifovalid@20000000
    // out out_o_stall@20000000
    // out out_o_valid@37
    // out out_c0_exit_aggregateComponentTag_0_x_tpl@37
    IDQualVecOp_i_sfc_s_c0_in_entry_idqualve0000r_idqualvecop_35_0gr thei_sfc_s_c0_in_entry_idqualvecops_c0_enter_idqualvecop_35_0gr_aunroll_x (
        .in_almost_empty_in(merged_in_SE_stall_entry_V2),
        .in_arg_a(in_arg_a),
        .in_arg_b(in_arg_b),
        .in_arg_mode(in_arg_mode),
        .in_avst_iowr_nb_acl_c_ResultPipeID_pipe_channel_almostfull(in_avst_iowr_nb_acl_c_ResultPipeID_pipe_channel_almostfull),
        .in_empty_in(merged_in_SE_stall_entry_V1),
        .in_i_stall(i_sfc_s_c0_in_entry_idqualvecops_c0_enter_idqualvecop_35_0gr_aunroll_x_in_i_stall_reg1_q),
        .in_i_valid(merged_in_SE_stall_entry_V0),
        .in_unnamed_IDQualVecOp0_aggregateComponentTag_0_x_tpl(GND_q),
        .out_almost_empty_out(i_sfc_s_c0_in_entry_idqualvecops_c0_enter_idqualvecop_35_0gr_aunroll_x_out_almost_empty_out),
        .out_empty_out(i_sfc_s_c0_in_entry_idqualvecops_c0_enter_idqualvecop_35_0gr_aunroll_x_out_empty_out),
        .out_iowr_nb_acl_c_ResultPipeID_pipe_channel_o_fifodata(i_sfc_s_c0_in_entry_idqualvecops_c0_enter_idqualvecop_35_0gr_aunroll_x_out_iowr_nb_acl_c_ResultPipeID_pipe_channel_o_fifodata),
        .out_iowr_nb_acl_c_ResultPipeID_pipe_channel_o_fifovalid(i_sfc_s_c0_in_entry_idqualvecops_c0_enter_idqualvecop_35_0gr_aunroll_x_out_iowr_nb_acl_c_ResultPipeID_pipe_channel_o_fifovalid),
        .out_o_stall(i_sfc_s_c0_in_entry_idqualvecops_c0_enter_idqualvecop_35_0gr_aunroll_x_out_o_stall),
        .out_o_valid(i_sfc_s_c0_in_entry_idqualvecops_c0_enter_idqualvecop_35_0gr_aunroll_x_out_o_valid),
        .out_c0_exit_aggregateComponentTag_0_x_tpl(),
        .clock(clock),
        .resetn(resetn)
    );

    // ext_sig_sync_out(GPOUT,6)
    assign out_iowr_nb_acl_c_ResultPipeID_pipe_channel_o_fifodata = i_sfc_s_c0_in_entry_idqualvecops_c0_enter_idqualvecop_35_0gr_aunroll_x_out_iowr_nb_acl_c_ResultPipeID_pipe_channel_o_fifodata;
    assign out_iowr_nb_acl_c_ResultPipeID_pipe_channel_o_fifovalid = i_sfc_s_c0_in_entry_idqualvecops_c0_enter_idqualvecop_35_0gr_aunroll_x_out_iowr_nb_acl_c_ResultPipeID_pipe_channel_o_fifovalid;

    // stall_entry_frontStall_reg0(REG,31)
    always_ff @ (posedge clock) begin
        stall_entry_frontStall_reg0_q <= merged_in_SE_stall_entry_backStall;
    end

    // stall_entry_frontStall_reg1(REG,32)
    always_ff @ (posedge clock) begin
        stall_entry_frontStall_reg1_q <= stall_entry_frontStall_reg0_q;
    end

    // sync_out_47(GPOUT,15)@0
    assign out_stall_out = stall_entry_frontStall_reg1_q;

    // sync_out_48(GPOUT,16)@37
    assign out_almost_empty_out = merged_in_SE_out_i_sfc_s_c0_in_entry_idqualvecops_c0_enter_idqualvecop_35_0gr_aunroll_x_V2;
    assign out_empty_out = merged_in_SE_out_i_sfc_s_c0_in_entry_idqualvecops_c0_enter_idqualvecop_35_0gr_aunroll_x_V1;
    assign out_valid_out = merged_in_SE_out_i_sfc_s_c0_in_entry_idqualvecops_c0_enter_idqualvecop_35_0gr_aunroll_x_V0;

    // rst_sync(RESETSYNC,47)
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

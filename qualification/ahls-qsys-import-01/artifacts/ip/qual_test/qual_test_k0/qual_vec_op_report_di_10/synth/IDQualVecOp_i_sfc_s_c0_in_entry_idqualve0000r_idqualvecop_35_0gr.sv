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

// SystemVerilog created from i_sfc_s_c0_in_entry_idqualvecops_c0_enter_idqualvecop_35_0gr
// Created for function/kernel IDQualVecOp
// SystemVerilog created on Sat Sep 19 11:42:59 2026


(* altera_attribute = "-name AUTO_SHIFT_REGISTER_RECOGNITION OFF; -name MESSAGE_DISABLE 10036; -name MESSAGE_DISABLE 10037; -name MESSAGE_DISABLE 14130; -name MESSAGE_DISABLE 14320; -name MESSAGE_DISABLE 15400; -name MESSAGE_DISABLE 14130; -name MESSAGE_DISABLE 10036; -name MESSAGE_DISABLE 12020; -name MESSAGE_DISABLE 12030; -name MESSAGE_DISABLE 12010; -name MESSAGE_DISABLE 12110; -name MESSAGE_DISABLE 14320; -name MESSAGE_DISABLE 13410; -name MESSAGE_DISABLE 113007; -name MESSAGE_DISABLE 10958" *)
module IDQualVecOp_i_sfc_s_c0_in_entry_idqualve0000r_idqualvecop_35_0gr (
    input wire [31:0] in_arg_a,
    input wire [31:0] in_arg_b,
    input wire [31:0] in_arg_mode,
    input wire [0:0] in_avst_iowr_nb_acl_c_ResultPipeID_pipe_channel_almostfull,
    output wire [31:0] out_iowr_nb_acl_c_ResultPipeID_pipe_channel_o_fifodata,
    input wire [0:0] in_i_stall,
    output wire [0:0] out_o_stall,
    output wire [0:0] out_iowr_nb_acl_c_ResultPipeID_pipe_channel_o_fifovalid,
    output wire [0:0] out_almost_empty_out,
    output wire [0:0] out_c0_exit_aggregateComponentTag_0_x_tpl,
    output wire [0:0] out_empty_out,
    output wire [0:0] out_o_valid,
    input wire [0:0] in_almost_empty_in,
    input wire [0:0] in_empty_in,
    input wire [0:0] in_i_valid,
    input wire [0:0] in_unnamed_IDQualVecOp0_aggregateComponentTag_0_x_tpl,
    input wire clock,
    input wire resetn
    );

    wire [0:0] GND_q;
    wire [0:0] VCC_q;
    wire [0:0] input_accepted_and_q;
    wire [0:0] i_llvm_fpga_sfc_exit_s_c0_in_entry_idqualvecops_c0_exit_idqualvecop_40_1gr_aunroll_x_out_almost_empty_out;
    wire [0:0] i_llvm_fpga_sfc_exit_s_c0_in_entry_idqualvecops_c0_exit_idqualvecop_40_1gr_aunroll_x_out_empty_out;
    wire [0:0] i_llvm_fpga_sfc_exit_s_c0_in_entry_idqualvecops_c0_exit_idqualvecop_40_1gr_aunroll_x_out_stall_entry;
    wire [0:0] i_llvm_fpga_sfc_exit_s_c0_in_entry_idqualvecops_c0_exit_idqualvecop_40_1gr_aunroll_x_out_valid_out;
    wire [0:0] i_llvm_fpga_sfc_exit_s_c0_in_entry_idqualvecops_c0_exit_idqualvecop_40_1gr_aunroll_x_out_data_out_aggregateComponentTag_0_x_tpl;
    wire [31:0] i_sfc_logic_s_c0_in_entry_idqualvecops_c0_enter_idqualvecop_40_0gr_aunroll_x_out_iowr_nb_acl_c_ResultPipeID_pipe_channel_o_fifodata;
    wire [0:0] i_sfc_logic_s_c0_in_entry_idqualvecops_c0_enter_idqualvecop_40_0gr_aunroll_x_out_iowr_nb_acl_c_ResultPipeID_pipe_channel_o_fifovalid;
    wire [0:0] i_sfc_logic_s_c0_in_entry_idqualvecops_c0_enter_idqualvecop_40_0gr_aunroll_x_out_o_valid;
    reg [0:0] rst_sync_rst_sclrn;


    // VCC(CONSTANT,1)
    assign VCC_q = 1'b1;

    // input_accepted_and(LOGICAL,4)
    assign input_accepted_and_q = in_i_valid & VCC_q;

    // i_sfc_logic_s_c0_in_entry_idqualvecops_c0_enter_idqualvecop_40_0gr_aunroll_x(BLACKBOX,14)@0
    // out out_iowr_nb_acl_c_ResultPipeID_pipe_channel_o_fifodata@20000000
    // out out_iowr_nb_acl_c_ResultPipeID_pipe_channel_o_fifovalid@20000000
    // out out_o_valid@6
    // out out_unnamed_IDQualVecOp3@6
    // out out_unnamed_IDQualVecOp0_aggregateComponentTag_0_x_tpl@6
    IDQualVecOp_i_sfc_logic_s_c0_in_entry_id0000r_idqualvecop_40_0gr thei_sfc_logic_s_c0_in_entry_idqualvecops_c0_enter_idqualvecop_40_0gr_aunroll_x (
        .in_arg_a(in_arg_a),
        .in_arg_b(in_arg_b),
        .in_arg_mode(in_arg_mode),
        .in_avst_iowr_nb_acl_c_ResultPipeID_pipe_channel_almostfull(in_avst_iowr_nb_acl_c_ResultPipeID_pipe_channel_almostfull),
        .in_i_valid(input_accepted_and_q),
        .out_iowr_nb_acl_c_ResultPipeID_pipe_channel_o_fifodata(i_sfc_logic_s_c0_in_entry_idqualvecops_c0_enter_idqualvecop_40_0gr_aunroll_x_out_iowr_nb_acl_c_ResultPipeID_pipe_channel_o_fifodata),
        .out_iowr_nb_acl_c_ResultPipeID_pipe_channel_o_fifovalid(i_sfc_logic_s_c0_in_entry_idqualvecops_c0_enter_idqualvecop_40_0gr_aunroll_x_out_iowr_nb_acl_c_ResultPipeID_pipe_channel_o_fifovalid),
        .out_o_valid(i_sfc_logic_s_c0_in_entry_idqualvecops_c0_enter_idqualvecop_40_0gr_aunroll_x_out_o_valid),
        .out_unnamed_IDQualVecOp3(),
        .out_unnamed_IDQualVecOp0_aggregateComponentTag_0_x_tpl(),
        .clock(clock),
        .resetn(rst_sync_rst_sclrn[0])
    );

    // regfree_osync(GPOUT,9)
    assign out_iowr_nb_acl_c_ResultPipeID_pipe_channel_o_fifodata = i_sfc_logic_s_c0_in_entry_idqualvecops_c0_enter_idqualvecop_40_0gr_aunroll_x_out_iowr_nb_acl_c_ResultPipeID_pipe_channel_o_fifodata;

    // GND(CONSTANT,0)
    assign GND_q = 1'b0;

    // i_llvm_fpga_sfc_exit_s_c0_in_entry_idqualvecops_c0_exit_idqualvecop_40_1gr_aunroll_x(BLACKBOX,13)@6
    // in in_mask_valid@20000000
    // in in_stall_in@20000000
    // out out_almost_empty_out@37
    // out out_empty_out@37
    // out out_stall_entry@20000000
    // out out_valid_out@37
    // out out_data_out_aggregateComponentTag_0_x_tpl@37
    IDQualVecOp_i_llvm_fpga_sfc_exit_s_c0_in0000_idqualvecop_177_0gr thei_llvm_fpga_sfc_exit_s_c0_in_entry_idqualvecops_c0_exit_idqualvecop_40_1gr_aunroll_x (
        .in_input_accepted(input_accepted_and_q),
        .in_mask_valid(GND_q),
        .in_stall_in(in_i_stall),
        .in_valid_in(i_sfc_logic_s_c0_in_entry_idqualvecops_c0_enter_idqualvecop_40_0gr_aunroll_x_out_o_valid),
        .in_data_in_aggregateComponentTag_0_x_tpl(GND_q),
        .out_almost_empty_out(i_llvm_fpga_sfc_exit_s_c0_in_entry_idqualvecops_c0_exit_idqualvecop_40_1gr_aunroll_x_out_almost_empty_out),
        .out_empty_out(i_llvm_fpga_sfc_exit_s_c0_in_entry_idqualvecops_c0_exit_idqualvecop_40_1gr_aunroll_x_out_empty_out),
        .out_stall_entry(i_llvm_fpga_sfc_exit_s_c0_in_entry_idqualvecops_c0_exit_idqualvecop_40_1gr_aunroll_x_out_stall_entry),
        .out_valid_out(i_llvm_fpga_sfc_exit_s_c0_in_entry_idqualvecops_c0_exit_idqualvecop_40_1gr_aunroll_x_out_valid_out),
        .out_data_out_aggregateComponentTag_0_x_tpl(i_llvm_fpga_sfc_exit_s_c0_in_entry_idqualvecops_c0_exit_idqualvecop_40_1gr_aunroll_x_out_data_out_aggregateComponentTag_0_x_tpl),
        .clock(clock),
        .resetn(rst_sync_rst_sclrn[0])
    );

    // sync_out_45(GPOUT,11)@20000000
    assign out_o_stall = i_llvm_fpga_sfc_exit_s_c0_in_entry_idqualvecops_c0_exit_idqualvecop_40_1gr_aunroll_x_out_stall_entry;

    // dupName_0_regfree_osync_x(GPOUT,12)
    assign out_iowr_nb_acl_c_ResultPipeID_pipe_channel_o_fifovalid = i_sfc_logic_s_c0_in_entry_idqualvecops_c0_enter_idqualvecop_40_0gr_aunroll_x_out_iowr_nb_acl_c_ResultPipeID_pipe_channel_o_fifovalid;

    // sync_out_46_aunroll_x(GPOUT,15)@37
    assign out_almost_empty_out = i_llvm_fpga_sfc_exit_s_c0_in_entry_idqualvecops_c0_exit_idqualvecop_40_1gr_aunroll_x_out_almost_empty_out;
    assign out_c0_exit_aggregateComponentTag_0_x_tpl = i_llvm_fpga_sfc_exit_s_c0_in_entry_idqualvecops_c0_exit_idqualvecop_40_1gr_aunroll_x_out_data_out_aggregateComponentTag_0_x_tpl;
    assign out_empty_out = i_llvm_fpga_sfc_exit_s_c0_in_entry_idqualvecops_c0_exit_idqualvecop_40_1gr_aunroll_x_out_empty_out;
    assign out_o_valid = i_llvm_fpga_sfc_exit_s_c0_in_entry_idqualvecops_c0_exit_idqualvecop_40_1gr_aunroll_x_out_valid_out;

    // rst_sync(RESETSYNC,17)
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

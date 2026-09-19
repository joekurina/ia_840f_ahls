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

// SystemVerilog created from IDQualVecOp_function_wrapper
// Created for function/kernel IDQualVecOp
// SystemVerilog created on Sat Sep 19 11:42:59 2026


(* altera_attribute = "-name AUTO_SHIFT_REGISTER_RECOGNITION OFF; -name MESSAGE_DISABLE 10036; -name MESSAGE_DISABLE 10037; -name MESSAGE_DISABLE 14130; -name MESSAGE_DISABLE 14320; -name MESSAGE_DISABLE 15400; -name MESSAGE_DISABLE 14130; -name MESSAGE_DISABLE 10036; -name MESSAGE_DISABLE 12020; -name MESSAGE_DISABLE 12030; -name MESSAGE_DISABLE 12010; -name MESSAGE_DISABLE 12110; -name MESSAGE_DISABLE 14320; -name MESSAGE_DISABLE 13410; -name MESSAGE_DISABLE 113007; -name MESSAGE_DISABLE 10958" *)
module IDQualVecOp_function_wrapper (
    input wire [0:0] avst_iowr_nb_acl_c_ResultPipeID_pipe_channel_almostfull,
    input wire [95:0] kernel_arguments,
    input wire [0:0] local_router_hang,
    input wire [0:0] stall_in,
    input wire [0:0] start,
    input wire [0:0] valid_in,
    output wire [31:0] avst_iowr_nb_acl_c_ResultPipeID_pipe_channel_data,
    output wire [0:0] avst_iowr_nb_acl_c_ResultPipeID_pipe_channel_valid,
    output wire [0:0] has_a_lsu_active,
    output wire [0:0] has_a_write_pending,
    output wire [0:0] kernel_valid_in,
    output wire [0:0] kernel_valid_out,
    input wire clock,
    input wire resetn
    );

    wire [0:0] GND_q;
    wire [31:0] IDQualVecOp_function_out_iowr_nb_acl_c_ResultPipeID_pipe_channel_o_fifodata;
    wire [0:0] IDQualVecOp_function_out_iowr_nb_acl_c_ResultPipeID_pipe_channel_o_fifovalid;
    wire [0:0] IDQualVecOp_function_out_valid_out;
    wire [31:0] arg_arg_a_select_b;
    wire [31:0] arg_arg_b_select_b;
    wire [31:0] arg_arg_mode_select_b;
    wire [0:0] valid_in_pulse_q;
    reg [0:0] valid_pulse_reg1_NO_SHIFT_REG_q;
    reg [0:0] valid_pulse_reg2_NO_SHIFT_REG_q;
    reg [0:0] rst_sync_rst_sclrn;


    // valid_pulse_reg2_NO_SHIFT_REG(REG,12)
    always_ff @ (posedge clock) begin
        if (!rst_sync_rst_sclrn[0]) begin
            valid_pulse_reg2_NO_SHIFT_REG_q <= $unsigned(1'b0);
        end
        else begin
            valid_pulse_reg2_NO_SHIFT_REG_q <= valid_pulse_reg1_NO_SHIFT_REG_q;
        end
    end

    // valid_pulse_reg1_NO_SHIFT_REG(REG,11)
    always_ff @ (posedge clock) begin
        if (!rst_sync_rst_sclrn[0]) begin
            valid_pulse_reg1_NO_SHIFT_REG_q <= $unsigned(1'b0);
        end
        else begin
            valid_pulse_reg1_NO_SHIFT_REG_q <= start;
        end
    end

    // valid_in_pulse(LOGICAL,10)
    assign valid_in_pulse_q = valid_pulse_reg1_NO_SHIFT_REG_q & valid_pulse_reg2_NO_SHIFT_REG_q;

    // GND(CONSTANT,0)
    assign GND_q = 1'b0;

    // arg_arg_mode_select(BITSELECT,5)
    assign arg_arg_mode_select_b = kernel_arguments[95:64];

    // arg_arg_b_select(BITSELECT,4)
    assign arg_arg_b_select_b = kernel_arguments[63:32];

    // arg_arg_a_select(BITSELECT,3)
    assign arg_arg_a_select_b = kernel_arguments[31:0];

    // IDQualVecOp_function(BLACKBOX,2)
    IDQualVecOp_function theIDQualVecOp_function (
        .in_arg_arg_a(arg_arg_a_select_b),
        .in_arg_arg_b(arg_arg_b_select_b),
        .in_arg_arg_mode(arg_arg_mode_select_b),
        .in_avst_iowr_nb_acl_c_ResultPipeID_pipe_channel_almostfull(avst_iowr_nb_acl_c_ResultPipeID_pipe_channel_almostfull),
        .in_stall_in(GND_q),
        .in_start(start),
        .in_valid_in(valid_in_pulse_q),
        .out_iowr_nb_acl_c_ResultPipeID_pipe_channel_o_fifodata(IDQualVecOp_function_out_iowr_nb_acl_c_ResultPipeID_pipe_channel_o_fifodata),
        .out_iowr_nb_acl_c_ResultPipeID_pipe_channel_o_fifovalid(IDQualVecOp_function_out_iowr_nb_acl_c_ResultPipeID_pipe_channel_o_fifovalid),
        .out_stall_out(),
        .out_valid_out(IDQualVecOp_function_out_valid_out),
        .clock(clock),
        .resetn(resetn)
    );

    // avst_iowr_nb_acl_c_ResultPipeID_pipe_channel_data(GPOUT,20)
    assign avst_iowr_nb_acl_c_ResultPipeID_pipe_channel_data = IDQualVecOp_function_out_iowr_nb_acl_c_ResultPipeID_pipe_channel_o_fifodata;

    // avst_iowr_nb_acl_c_ResultPipeID_pipe_channel_valid(GPOUT,21)
    assign avst_iowr_nb_acl_c_ResultPipeID_pipe_channel_valid = IDQualVecOp_function_out_iowr_nb_acl_c_ResultPipeID_pipe_channel_o_fifovalid;

    // has_a_lsu_active(GPOUT,22)
    assign has_a_lsu_active = GND_q;

    // has_a_write_pending(GPOUT,23)
    assign has_a_write_pending = GND_q;

    // kernel_valid_in(GPOUT,24)
    assign kernel_valid_in = valid_in_pulse_q;

    // kernel_valid_out(GPOUT,25)
    assign kernel_valid_out = IDQualVecOp_function_out_valid_out;

    // rst_sync(RESETSYNC,26)
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

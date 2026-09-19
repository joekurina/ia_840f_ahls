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

// SystemVerilog created from i_llvm_fpga_sfc_exit_s_c0_in_entry_idqualvecops_c0_exit_idqualvecop_177_0gr
// Created for function/kernel IDQualVecOp
// SystemVerilog created on Sat Sep 19 11:42:59 2026


(* altera_attribute = "-name AUTO_SHIFT_REGISTER_RECOGNITION OFF; -name MESSAGE_DISABLE 10036; -name MESSAGE_DISABLE 10037; -name MESSAGE_DISABLE 14130; -name MESSAGE_DISABLE 14320; -name MESSAGE_DISABLE 15400; -name MESSAGE_DISABLE 14130; -name MESSAGE_DISABLE 10036; -name MESSAGE_DISABLE 12020; -name MESSAGE_DISABLE 12030; -name MESSAGE_DISABLE 12010; -name MESSAGE_DISABLE 12110; -name MESSAGE_DISABLE 14320; -name MESSAGE_DISABLE 13410; -name MESSAGE_DISABLE 113007; -name MESSAGE_DISABLE 10958" *)
module IDQualVecOp_i_llvm_fpga_sfc_exit_s_c0_in0000_idqualvecop_177_0gr (
    input wire [0:0] in_stall_in,
    output wire [0:0] out_stall_entry,
    output wire [0:0] out_almost_empty_out,
    output wire [0:0] out_data_out_aggregateComponentTag_0_x_tpl,
    output wire [0:0] out_empty_out,
    output wire [0:0] out_valid_out,
    input wire [0:0] in_data_in_aggregateComponentTag_0_x_tpl,
    input wire [0:0] in_input_accepted,
    input wire [0:0] in_valid_in,
    input wire [0:0] in_mask_valid,
    input wire clock,
    input wire resetn
    );

    wire [0:0] GND_q;
    wire [0:0] i_llvm_fpga_sfc_exit_s_c0_in_entry_idqualvecops_c0_exit_idqualvecop_40_1gr_full_detector_out_full;
    wire [0:0] stall_out_or_q;
    reg [0:0] valid_before_fifo_q;
    reg [0:0] before_fifo_0_x_q;
    wire [0:0] i_llvm_fpga_sfc_exit_s_c0_in_entry_idqualvecops_c0_exit_idqualvecop_177_1gr_data_fifo_aunroll_x_out_o_almost_empty;
    wire [0:0] i_llvm_fpga_sfc_exit_s_c0_in_entry_idqualvecops_c0_exit_idqualvecop_177_1gr_data_fifo_aunroll_x_out_o_empty;
    wire [0:0] i_llvm_fpga_sfc_exit_s_c0_in_entry_idqualvecops_c0_exit_idqualvecop_177_1gr_data_fifo_aunroll_x_out_o_stall;
    wire [0:0] i_llvm_fpga_sfc_exit_s_c0_in_entry_idqualvecops_c0_exit_idqualvecop_177_1gr_data_fifo_aunroll_x_out_o_valid;
    wire [0:0] i_llvm_fpga_sfc_exit_s_c0_in_entry_idqualvecops_c0_exit_idqualvecop_177_1gr_data_fifo_aunroll_x_out_o_data_aggregateComponentTag_0_x_tpl;


    // before_fifo_0_x(REG,10)
    always_ff @ (posedge clock) begin
        before_fifo_0_x_q <= in_data_in_aggregateComponentTag_0_x_tpl;
    end

    // valid_before_fifo(REG,9)
    always_ff @ (posedge clock) begin
        valid_before_fifo_q <= in_valid_in;
    end

    // GND(CONSTANT,0)
    assign GND_q = 1'b0;

    // i_llvm_fpga_sfc_exit_s_c0_in_entry_idqualvecops_c0_exit_idqualvecop_177_1gr_data_fifo_aunroll_x(BLACKBOX,11)@19999970
    // in in_i_stall@20000000
    // out out_o_almost_empty@20000000
    // out out_o_empty@20000000
    // out out_o_stall@20000000
    // out out_o_valid@20000000
    // out out_o_data_aggregateComponentTag_0_x_tpl@20000000
    IDQualVecOp_i_llvm_fpga_sfc_exit_s_c0_in0000op_177_1gr_data_fifo thei_llvm_fpga_sfc_exit_s_c0_in_entry_idqualvecops_c0_exit_idqualvecop_177_1gr_data_fifo_aunroll_x (
        .in_almost_empty_in(GND_q),
        .in_empty_in(GND_q),
        .in_i_stall(in_stall_in),
        .in_i_valid(valid_before_fifo_q),
        .in_i_data_aggregateComponentTag_0_x_tpl(before_fifo_0_x_q),
        .out_o_almost_empty(i_llvm_fpga_sfc_exit_s_c0_in_entry_idqualvecops_c0_exit_idqualvecop_177_1gr_data_fifo_aunroll_x_out_o_almost_empty),
        .out_o_empty(i_llvm_fpga_sfc_exit_s_c0_in_entry_idqualvecops_c0_exit_idqualvecop_177_1gr_data_fifo_aunroll_x_out_o_empty),
        .out_o_stall(i_llvm_fpga_sfc_exit_s_c0_in_entry_idqualvecops_c0_exit_idqualvecop_177_1gr_data_fifo_aunroll_x_out_o_stall),
        .out_o_valid(i_llvm_fpga_sfc_exit_s_c0_in_entry_idqualvecops_c0_exit_idqualvecop_177_1gr_data_fifo_aunroll_x_out_o_valid),
        .out_o_data_aggregateComponentTag_0_x_tpl(i_llvm_fpga_sfc_exit_s_c0_in_entry_idqualvecops_c0_exit_idqualvecop_177_1gr_data_fifo_aunroll_x_out_o_data_aggregateComponentTag_0_x_tpl),
        .clock(clock),
        .resetn(resetn)
    );

    // i_llvm_fpga_sfc_exit_s_c0_in_entry_idqualvecops_c0_exit_idqualvecop_40_1gr_full_detector(BLACKBOX,5)@20000000
    IDQualVecOp_i_llvm_fpga_sfc_exit_s_c0_in000040_1gr_full_detector thei_llvm_fpga_sfc_exit_s_c0_in_entry_idqualvecops_c0_exit_idqualvecop_40_1gr_full_detector (
        .in_dec_pipelined_thread(GND_q),
        .in_decrement(i_llvm_fpga_sfc_exit_s_c0_in_entry_idqualvecops_c0_exit_idqualvecop_177_1gr_data_fifo_aunroll_x_out_o_valid),
        .in_inc_pipelined_thread(GND_q),
        .in_increment(in_input_accepted),
        .out_full(i_llvm_fpga_sfc_exit_s_c0_in_entry_idqualvecops_c0_exit_idqualvecop_40_1gr_full_detector_out_full),
        .out_throttle(),
        .clock(clock),
        .resetn(resetn)
    );

    // stall_out_or(LOGICAL,7)
    assign stall_out_or_q = i_llvm_fpga_sfc_exit_s_c0_in_entry_idqualvecops_c0_exit_idqualvecop_40_1gr_full_detector_out_full | i_llvm_fpga_sfc_exit_s_c0_in_entry_idqualvecops_c0_exit_idqualvecop_177_1gr_data_fifo_aunroll_x_out_o_stall;

    // sync_out_43(GPOUT,8)@20000000
    assign out_stall_entry = stall_out_or_q;

    // sync_out_44_aunroll_x(GPOUT,12)@37
    assign out_almost_empty_out = i_llvm_fpga_sfc_exit_s_c0_in_entry_idqualvecops_c0_exit_idqualvecop_177_1gr_data_fifo_aunroll_x_out_o_almost_empty;
    assign out_data_out_aggregateComponentTag_0_x_tpl = i_llvm_fpga_sfc_exit_s_c0_in_entry_idqualvecops_c0_exit_idqualvecop_177_1gr_data_fifo_aunroll_x_out_o_data_aggregateComponentTag_0_x_tpl;
    assign out_empty_out = i_llvm_fpga_sfc_exit_s_c0_in_entry_idqualvecops_c0_exit_idqualvecop_177_1gr_data_fifo_aunroll_x_out_o_empty;
    assign out_valid_out = i_llvm_fpga_sfc_exit_s_c0_in_entry_idqualvecops_c0_exit_idqualvecop_177_1gr_data_fifo_aunroll_x_out_o_valid;

endmodule

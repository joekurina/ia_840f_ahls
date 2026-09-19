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

// SystemVerilog created from i_llvm_fpga_sync_buffer_i32_arg_b_sync_buffer11_idqualvecop_112_0gr
// Created for function/kernel IDQualVecOp
// SystemVerilog created on Sat Sep 19 11:42:59 2026


(* altera_attribute = "-name AUTO_SHIFT_REGISTER_RECOGNITION OFF; -name MESSAGE_DISABLE 10036; -name MESSAGE_DISABLE 10037; -name MESSAGE_DISABLE 14130; -name MESSAGE_DISABLE 14320; -name MESSAGE_DISABLE 15400; -name MESSAGE_DISABLE 14130; -name MESSAGE_DISABLE 10036; -name MESSAGE_DISABLE 12020; -name MESSAGE_DISABLE 12030; -name MESSAGE_DISABLE 12010; -name MESSAGE_DISABLE 12110; -name MESSAGE_DISABLE 14320; -name MESSAGE_DISABLE 13410; -name MESSAGE_DISABLE 113007; -name MESSAGE_DISABLE 10958" *)
module IDQualVecOp_i_llvm_fpga_sync_buffer_i32_0000_idqualvecop_112_0gr (
    input wire [31:0] in_buffer_in,
    input wire [0:0] in_stall_in,
    output wire [0:0] out_stall_out,
    output wire [31:0] out_buffer_out,
    output wire [0:0] out_valid_out,
    input wire [0:0] in_i_dependence,
    input wire [0:0] in_valid_in,
    input wire clock,
    input wire resetn
    );

    wire [31:0] i_llvm_fpga_sync_buffer_i32_arg_b_sync_buffer11_idqualvecop_112_1gr_buffer_in;
    wire [31:0] i_llvm_fpga_sync_buffer_i32_arg_b_sync_buffer11_idqualvecop_112_1gr_buffer_out;


    // sync_out_22(GPOUT,6)@0
    assign out_stall_out = in_stall_in;

    // i_llvm_fpga_sync_buffer_i32_arg_b_sync_buffer11_idqualvecop_112_1gr(EXTIFACE,2)@1
    assign i_llvm_fpga_sync_buffer_i32_arg_b_sync_buffer11_idqualvecop_112_1gr_buffer_in = in_buffer_in;
    acl_dspba_buffer #(
        .WIDTH(32)
    ) thei_llvm_fpga_sync_buffer_i32_arg_b_sync_buffer11_idqualvecop_112_1gr (
        .buffer_in(in_buffer_in),
        .buffer_out(i_llvm_fpga_sync_buffer_i32_arg_b_sync_buffer11_idqualvecop_112_1gr_buffer_out)
    );

    // sync_out_23(GPOUT,7)@1
    assign out_buffer_out = i_llvm_fpga_sync_buffer_i32_arg_b_sync_buffer11_idqualvecop_112_1gr_buffer_out;
    assign out_valid_out = in_valid_in;

endmodule

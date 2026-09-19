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

// SystemVerilog created from i_io_full_acl_c_resultpipeid_pipe_channel_unnamed_idqualvecop1_idqualvecop_164_0gr
// Created for function/kernel IDQualVecOp
// SystemVerilog created on Sat Sep 19 11:42:59 2026


(* altera_attribute = "-name AUTO_SHIFT_REGISTER_RECOGNITION OFF; -name MESSAGE_DISABLE 10036; -name MESSAGE_DISABLE 10037; -name MESSAGE_DISABLE 14130; -name MESSAGE_DISABLE 14320; -name MESSAGE_DISABLE 15400; -name MESSAGE_DISABLE 14130; -name MESSAGE_DISABLE 10036; -name MESSAGE_DISABLE 12020; -name MESSAGE_DISABLE 12030; -name MESSAGE_DISABLE 12010; -name MESSAGE_DISABLE 12110; -name MESSAGE_DISABLE 14320; -name MESSAGE_DISABLE 13410; -name MESSAGE_DISABLE 113007; -name MESSAGE_DISABLE 10958" *)
module IDQualVecOp_i_io_full_acl_c_resultpipeid0000_idqualvecop_164_0gr (
    input wire [0:0] in_avst_iowr_nb_acl_c_ResultPipeID_pipe_channel_almostfull,
    input wire [0:0] in_i_stall,
    output wire [0:0] out_o_stall,
    output wire [0:0] out_o_almostfull,
    output wire [0:0] out_o_valid,
    input wire [0:0] in_i_valid,
    input wire clock,
    input wire resetn
    );

    wire [0:0] i_io_full_acl_c_resultpipeid_pipe_channel_unnamed_idqualvecop1_idqualvecop_164_1gr_buffer_in;
    wire i_io_full_acl_c_resultpipeid_pipe_channel_unnamed_idqualvecop1_idqualvecop_164_1gr_buffer_in_bitsignaltemp;
    wire [0:0] i_io_full_acl_c_resultpipeid_pipe_channel_unnamed_idqualvecop1_idqualvecop_164_1gr_buffer_out;
    wire i_io_full_acl_c_resultpipeid_pipe_channel_unnamed_idqualvecop1_idqualvecop_164_1gr_buffer_out_bitsignaltemp;


    // sync_out_36(GPOUT,5)@6
    assign out_o_stall = in_i_stall;

    // i_io_full_acl_c_resultpipeid_pipe_channel_unnamed_idqualvecop1_idqualvecop_164_1gr(EXTIFACE,2)@6
    assign i_io_full_acl_c_resultpipeid_pipe_channel_unnamed_idqualvecop1_idqualvecop_164_1gr_buffer_in = in_avst_iowr_nb_acl_c_ResultPipeID_pipe_channel_almostfull;
    assign i_io_full_acl_c_resultpipeid_pipe_channel_unnamed_idqualvecop1_idqualvecop_164_1gr_buffer_in_bitsignaltemp = i_io_full_acl_c_resultpipeid_pipe_channel_unnamed_idqualvecop1_idqualvecop_164_1gr_buffer_in[0];
    assign i_io_full_acl_c_resultpipeid_pipe_channel_unnamed_idqualvecop1_idqualvecop_164_1gr_buffer_out[0] = i_io_full_acl_c_resultpipeid_pipe_channel_unnamed_idqualvecop1_idqualvecop_164_1gr_buffer_out_bitsignaltemp;
    acl_dspba_buffer #(
        .WIDTH(1)
    ) thei_io_full_acl_c_resultpipeid_pipe_channel_unnamed_idqualvecop1_idqualvecop_164_1gr (
        .buffer_in(i_io_full_acl_c_resultpipeid_pipe_channel_unnamed_idqualvecop1_idqualvecop_164_1gr_buffer_in_bitsignaltemp),
        .buffer_out(i_io_full_acl_c_resultpipeid_pipe_channel_unnamed_idqualvecop1_idqualvecop_164_1gr_buffer_out_bitsignaltemp)
    );

    // sync_out_37(GPOUT,6)@6
    assign out_o_almostfull = i_io_full_acl_c_resultpipeid_pipe_channel_unnamed_idqualvecop1_idqualvecop_164_1gr_buffer_out;
    assign out_o_valid = in_i_valid;

endmodule

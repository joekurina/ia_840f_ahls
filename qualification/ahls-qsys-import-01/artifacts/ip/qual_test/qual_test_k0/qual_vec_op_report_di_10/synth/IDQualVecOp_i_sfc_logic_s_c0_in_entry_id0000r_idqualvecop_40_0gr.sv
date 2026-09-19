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

// SystemVerilog created from i_sfc_logic_s_c0_in_entry_idqualvecops_c0_enter_idqualvecop_40_0gr
// Created for function/kernel IDQualVecOp
// SystemVerilog created on Sat Sep 19 11:42:59 2026


(* altera_attribute = "-name AUTO_SHIFT_REGISTER_RECOGNITION OFF; -name MESSAGE_DISABLE 10036; -name MESSAGE_DISABLE 10037; -name MESSAGE_DISABLE 14130; -name MESSAGE_DISABLE 14320; -name MESSAGE_DISABLE 15400; -name MESSAGE_DISABLE 14130; -name MESSAGE_DISABLE 10036; -name MESSAGE_DISABLE 12020; -name MESSAGE_DISABLE 12030; -name MESSAGE_DISABLE 12010; -name MESSAGE_DISABLE 12110; -name MESSAGE_DISABLE 14320; -name MESSAGE_DISABLE 13410; -name MESSAGE_DISABLE 113007; -name MESSAGE_DISABLE 10958" *)
module IDQualVecOp_i_sfc_logic_s_c0_in_entry_id0000r_idqualvecop_40_0gr (
    input wire [0:0] in_avst_iowr_nb_acl_c_ResultPipeID_pipe_channel_almostfull,
    output wire [31:0] out_iowr_nb_acl_c_ResultPipeID_pipe_channel_o_fifodata,
    output wire [0:0] out_iowr_nb_acl_c_ResultPipeID_pipe_channel_o_fifovalid,
    input wire [31:0] in_arg_a,
    input wire [31:0] in_arg_b,
    input wire [31:0] in_arg_mode,
    input wire [0:0] in_i_valid,
    output wire [0:0] out_o_valid,
    output wire [0:0] out_unnamed_IDQualVecOp0_aggregateComponentTag_0_x_tpl,
    output wire [0:0] out_unnamed_IDQualVecOp3,
    input wire clock,
    input wire resetn
    );

    wire [0:0] GND_q;
    wire [0:0] VCC_q;
    wire [31:0] c_i32_1_43_72_q;
    wire [31:0] c_i32_1_43_73_q;
    wire [31:0] c_i32_2_43_74_q;
    wire [31:0] c_i32_2_43_75_q;
    wire [31:0] c_i32_3_43_76_q;
    wire [31:0] c_i32_3_43_77_q;
    wire [31:0] c_i32_4_43_78_q;
    wire [31:0] c_i32_4_43_79_q;
    wire [31:0] c_i32_5_43_80_q;
    wire [31:0] c_i32_5_43_81_q;
    wire [31:0] c_i32_6_43_82_q;
    wire [31:0] c_i32_6_43_83_q;
    wire [31:0] c_i32_7_43_84_q;
    wire [31:0] c_i32_7_43_85_q;
    wire [32:0] i_add_i_pn_1_idqualvecop_43_9gr_a;
    wire [32:0] i_add_i_pn_1_idqualvecop_43_9gr_b;
    logic [32:0] i_add_i_pn_1_idqualvecop_43_9gr_o;
    wire [32:0] i_add_i_pn_1_idqualvecop_43_9gr_q;
    wire [32:0] i_add_i_pn_3_idqualvecop_43_19_a;
    wire [32:0] i_add_i_pn_3_idqualvecop_43_19_b;
    logic [32:0] i_add_i_pn_3_idqualvecop_43_19_o;
    wire [32:0] i_add_i_pn_3_idqualvecop_43_19_q;
    wire [32:0] i_add_i_pn_5_idqualvecop_43_29_a;
    wire [32:0] i_add_i_pn_5_idqualvecop_43_29_b;
    logic [32:0] i_add_i_pn_5_idqualvecop_43_29_o;
    wire [32:0] i_add_i_pn_5_idqualvecop_43_29_q;
    wire [32:0] i_add_i_pn_7_idqualvecop_43_39_a;
    wire [32:0] i_add_i_pn_7_idqualvecop_43_39_b;
    logic [32:0] i_add_i_pn_7_idqualvecop_43_39_o;
    wire [32:0] i_add_i_pn_7_idqualvecop_43_39_q;
    wire [0:0] i_add_i_pn_p_1_idqualvecop_43_7gr_s;
    reg [31:0] i_add_i_pn_p_1_idqualvecop_43_7gr_q;
    wire [31:0] i_add_i_pn_p_1_idqualvecop_43_7gr_vt_join_q;
    wire [30:0] i_add_i_pn_p_1_idqualvecop_43_7gr_vt_select_31_b;
    wire [0:0] i_add_i_pn_p_2_idqualvecop_43_12_s;
    reg [31:0] i_add_i_pn_p_2_idqualvecop_43_12_q;
    wire [1:0] i_add_i_pn_p_2_idqualvecop_43_12_vt_const_1_q;
    wire [31:0] i_add_i_pn_p_2_idqualvecop_43_12_vt_join_q;
    wire [29:0] i_add_i_pn_p_2_idqualvecop_43_12_vt_select_31_b;
    wire [0:0] i_add_i_pn_p_3_idqualvecop_43_17_s;
    reg [31:0] i_add_i_pn_p_3_idqualvecop_43_17_q;
    wire [31:0] i_add_i_pn_p_3_idqualvecop_43_17_vt_join_q;
    wire [30:0] i_add_i_pn_p_3_idqualvecop_43_17_vt_select_31_b;
    wire [0:0] i_add_i_pn_p_4_idqualvecop_43_22_s;
    reg [31:0] i_add_i_pn_p_4_idqualvecop_43_22_q;
    wire [2:0] i_add_i_pn_p_4_idqualvecop_43_22_vt_const_2_q;
    wire [31:0] i_add_i_pn_p_4_idqualvecop_43_22_vt_join_q;
    wire [28:0] i_add_i_pn_p_4_idqualvecop_43_22_vt_select_31_b;
    wire [0:0] i_add_i_pn_p_5_idqualvecop_43_27_s;
    reg [31:0] i_add_i_pn_p_5_idqualvecop_43_27_q;
    wire [31:0] i_add_i_pn_p_5_idqualvecop_43_27_vt_join_q;
    wire [30:0] i_add_i_pn_p_5_idqualvecop_43_27_vt_select_31_b;
    wire [0:0] i_add_i_pn_p_6_idqualvecop_43_32_s;
    reg [31:0] i_add_i_pn_p_6_idqualvecop_43_32_q;
    wire [31:0] i_add_i_pn_p_6_idqualvecop_43_32_vt_join_q;
    wire [29:0] i_add_i_pn_p_6_idqualvecop_43_32_vt_select_31_b;
    wire [0:0] i_add_i_pn_p_7_idqualvecop_43_37_s;
    reg [31:0] i_add_i_pn_p_7_idqualvecop_43_37_q;
    wire [31:0] i_add_i_pn_p_7_idqualvecop_43_37_vt_join_q;
    wire [30:0] i_add_i_pn_p_7_idqualvecop_43_37_vt_select_31_b;
    wire [0:0] i_cmp2_i_idqualvecop_43_2gr_q;
    wire [0:0] i_io_full_acl_c_resultpipeid_pipe_channel_unnamed_idqualvecop1_idqualvecop_43_49_out_o_almostfull;
    wire [31:0] i_iowr_nb_acl_c_resultpipeid_pipe_channel_unnamed_idqualvecop2_idqualvecop_43_50_out_iowr_nb_acl_c_ResultPipeID_pipe_channel_o_fifodata;
    wire [0:0] i_iowr_nb_acl_c_resultpipeid_pipe_channel_unnamed_idqualvecop2_idqualvecop_43_50_out_iowr_nb_acl_c_ResultPipeID_pipe_channel_o_fifovalid;
    wire [31:0] i_llvm_fpga_sync_buffer_i32_arg_a_sync_buffer1_idqualvecop_43_13_out_buffer_out;
    wire [31:0] i_llvm_fpga_sync_buffer_i32_arg_a_sync_buffer2_idqualvecop_43_18_out_buffer_out;
    wire [31:0] i_llvm_fpga_sync_buffer_i32_arg_a_sync_buffer3_idqualvecop_43_23_out_buffer_out;
    wire [31:0] i_llvm_fpga_sync_buffer_i32_arg_a_sync_buffer4_idqualvecop_43_28_out_buffer_out;
    wire [31:0] i_llvm_fpga_sync_buffer_i32_arg_a_sync_buffer5_idqualvecop_43_33_out_buffer_out;
    wire [31:0] i_llvm_fpga_sync_buffer_i32_arg_a_sync_buffer6_idqualvecop_43_38_out_buffer_out;
    wire [31:0] i_llvm_fpga_sync_buffer_i32_arg_a_sync_buffer7_idqualvecop_43_4gr_out_buffer_out;
    wire [31:0] i_llvm_fpga_sync_buffer_i32_arg_a_sync_buffer_idqualvecop_43_8gr_out_buffer_out;
    wire [31:0] i_llvm_fpga_sync_buffer_i32_arg_b_sync_buffer10_idqualvecop_43_20_out_buffer_out;
    wire [31:0] i_llvm_fpga_sync_buffer_i32_arg_b_sync_buffer11_idqualvecop_43_25_out_buffer_out;
    wire [31:0] i_llvm_fpga_sync_buffer_i32_arg_b_sync_buffer12_idqualvecop_43_30_out_buffer_out;
    wire [31:0] i_llvm_fpga_sync_buffer_i32_arg_b_sync_buffer13_idqualvecop_43_35_out_buffer_out;
    wire [31:0] i_llvm_fpga_sync_buffer_i32_arg_b_sync_buffer14_idqualvecop_43_40_out_buffer_out;
    wire [31:0] i_llvm_fpga_sync_buffer_i32_arg_b_sync_buffer8_idqualvecop_43_10_out_buffer_out;
    wire [31:0] i_llvm_fpga_sync_buffer_i32_arg_b_sync_buffer9_idqualvecop_43_15_out_buffer_out;
    wire [31:0] i_llvm_fpga_sync_buffer_i32_arg_b_sync_buffer_idqualvecop_43_5gr_out_buffer_out;
    wire [31:0] i_llvm_fpga_sync_buffer_i32_arg_mode_sync_buffer_idqualvecop_43_1gr_out_buffer_out;
    wire [31:0] i_reduction_idqualvecop_0_idqualvecop_43_42_q;
    wire [31:0] i_reduction_idqualvecop_1_idqualvecop_43_43_q;
    wire [31:0] i_reduction_idqualvecop_2_idqualvecop_43_44_q;
    wire [31:0] i_reduction_idqualvecop_3_idqualvecop_43_45_q;
    wire [31:0] i_reduction_idqualvecop_4_idqualvecop_43_46_q;
    wire [31:0] i_reduction_idqualvecop_5_idqualvecop_43_47_q;
    wire [31:0] i_reduction_idqualvecop_6_idqualvecop_43_48_qi;
    reg [31:0] i_reduction_idqualvecop_6_idqualvecop_43_48_q;
    wire [31:0] bgTrunc_i_add_i_pn_1_idqualvecop_43_9gr_sel_x_b;
    wire [31:0] bgTrunc_i_add_i_pn_2_idqualvecop_43_14_sel_x_b;
    wire [31:0] bgTrunc_i_add_i_pn_3_idqualvecop_43_19_sel_x_b;
    wire [31:0] bgTrunc_i_add_i_pn_4_idqualvecop_43_24_sel_x_b;
    wire [31:0] bgTrunc_i_add_i_pn_5_idqualvecop_43_29_sel_x_b;
    wire [31:0] bgTrunc_i_add_i_pn_6_idqualvecop_43_34_sel_x_b;
    wire [31:0] bgTrunc_i_add_i_pn_7_idqualvecop_43_39_sel_x_b;
    wire [63:0] bgTrunc_i_cond_i_1_idqualvecop_43_11_sel_x_in;
    wire [31:0] bgTrunc_i_cond_i_1_idqualvecop_43_11_sel_x_b;
    wire [63:0] bgTrunc_i_cond_i_2_idqualvecop_43_16_sel_x_in;
    wire [31:0] bgTrunc_i_cond_i_2_idqualvecop_43_16_sel_x_b;
    wire [63:0] bgTrunc_i_cond_i_3_idqualvecop_43_21_sel_x_in;
    wire [31:0] bgTrunc_i_cond_i_3_idqualvecop_43_21_sel_x_b;
    wire [63:0] bgTrunc_i_cond_i_4_idqualvecop_43_26_sel_x_in;
    wire [31:0] bgTrunc_i_cond_i_4_idqualvecop_43_26_sel_x_b;
    wire [63:0] bgTrunc_i_cond_i_5_idqualvecop_43_31_sel_x_in;
    wire [31:0] bgTrunc_i_cond_i_5_idqualvecop_43_31_sel_x_b;
    wire [63:0] bgTrunc_i_cond_i_6_idqualvecop_43_36_sel_x_in;
    wire [31:0] bgTrunc_i_cond_i_6_idqualvecop_43_36_sel_x_b;
    wire [63:0] bgTrunc_i_cond_i_7_idqualvecop_43_41_sel_x_in;
    wire [31:0] bgTrunc_i_cond_i_7_idqualvecop_43_41_sel_x_b;
    wire [63:0] bgTrunc_i_cond_i_idqualvecop_43_6gr_sel_x_in;
    wire [31:0] bgTrunc_i_cond_i_idqualvecop_43_6gr_sel_x_b;
    wire [31:0] c_i32_0_43_71_recast_x_q;
    (* preserve_syn_only *) reg [0:0] valid_fanout_reg0_q;
    (* preserve_syn_only *) reg [0:0] valid_fanout_reg1_q;
    (* preserve_syn_only *) reg [0:0] valid_fanout_reg2_q;
    (* preserve_syn_only *) reg [0:0] valid_fanout_reg3_q;
    (* preserve_syn_only *) reg [0:0] valid_fanout_reg4_q;
    (* preserve_syn_only *) reg [0:0] valid_fanout_reg5_q;
    (* preserve_syn_only *) reg [0:0] valid_fanout_reg6_q;
    (* preserve_syn_only *) reg [0:0] valid_fanout_reg7_q;
    (* preserve_syn_only *) reg [0:0] valid_fanout_reg8_q;
    (* preserve_syn_only *) reg [0:0] valid_fanout_reg9_q;
    (* preserve_syn_only *) reg [0:0] valid_fanout_reg10_q;
    (* preserve_syn_only *) reg [0:0] valid_fanout_reg11_q;
    (* preserve_syn_only *) reg [0:0] valid_fanout_reg12_q;
    (* preserve_syn_only *) reg [0:0] valid_fanout_reg13_q;
    (* preserve_syn_only *) reg [0:0] valid_fanout_reg14_q;
    (* preserve_syn_only *) reg [0:0] valid_fanout_reg15_q;
    (* preserve_syn_only *) reg [0:0] valid_fanout_reg16_q;
    (* preserve_syn_only *) reg [0:0] valid_fanout_reg17_q;
    (* preserve_syn_only *) reg [0:0] valid_fanout_reg18_q;
    (* preserve_syn_only *) reg [0:0] valid_fanout_reg19_q;
    wire [30:0] i_add_i_pn_2_idqualvecop_43_14_lhsMSBs_select_b;
    wire [31:0] i_add_i_pn_2_idqualvecop_43_14_MSBs_sums_a;
    wire [31:0] i_add_i_pn_2_idqualvecop_43_14_MSBs_sums_b;
    logic [31:0] i_add_i_pn_2_idqualvecop_43_14_MSBs_sums_o;
    wire [31:0] i_add_i_pn_2_idqualvecop_43_14_MSBs_sums_q;
    wire [32:0] i_add_i_pn_2_idqualvecop_43_14_split_join_q;
    wire [29:0] i_add_i_pn_4_idqualvecop_43_24_lhsMSBs_select_b;
    wire [30:0] i_add_i_pn_4_idqualvecop_43_24_MSBs_sums_a;
    wire [30:0] i_add_i_pn_4_idqualvecop_43_24_MSBs_sums_b;
    logic [30:0] i_add_i_pn_4_idqualvecop_43_24_MSBs_sums_o;
    wire [30:0] i_add_i_pn_4_idqualvecop_43_24_MSBs_sums_q;
    wire [32:0] i_add_i_pn_4_idqualvecop_43_24_split_join_q;
    wire [30:0] i_add_i_pn_6_idqualvecop_43_34_lhsMSBs_select_b;
    wire [31:0] i_add_i_pn_6_idqualvecop_43_34_MSBs_sums_a;
    wire [31:0] i_add_i_pn_6_idqualvecop_43_34_MSBs_sums_b;
    logic [31:0] i_add_i_pn_6_idqualvecop_43_34_MSBs_sums_o;
    wire [31:0] i_add_i_pn_6_idqualvecop_43_34_MSBs_sums_q;
    wire [32:0] i_add_i_pn_6_idqualvecop_43_34_split_join_q;
    wire [14:0] i_cond_i_1_idqualvecop_43_11_bjA10_q;
    wire [14:0] i_cond_i_1_idqualvecop_43_11_bjB12_q;
    wire [65:0] i_cond_i_1_idqualvecop_43_11_sums_join_0_q;
    wire [50:0] i_cond_i_1_idqualvecop_43_11_sums_align_1_q;
    wire [50:0] i_cond_i_1_idqualvecop_43_11_sums_align_1_qint;
    wire [14:0] i_cond_i_2_idqualvecop_43_16_bjA10_q;
    wire [14:0] i_cond_i_2_idqualvecop_43_16_bjB12_q;
    wire [65:0] i_cond_i_2_idqualvecop_43_16_sums_join_0_q;
    wire [50:0] i_cond_i_2_idqualvecop_43_16_sums_align_1_q;
    wire [50:0] i_cond_i_2_idqualvecop_43_16_sums_align_1_qint;
    wire [14:0] i_cond_i_3_idqualvecop_43_21_bjA10_q;
    wire [14:0] i_cond_i_3_idqualvecop_43_21_bjB12_q;
    wire [65:0] i_cond_i_3_idqualvecop_43_21_sums_join_0_q;
    wire [50:0] i_cond_i_3_idqualvecop_43_21_sums_align_1_q;
    wire [50:0] i_cond_i_3_idqualvecop_43_21_sums_align_1_qint;
    wire [14:0] i_cond_i_4_idqualvecop_43_26_bjA10_q;
    wire [14:0] i_cond_i_4_idqualvecop_43_26_bjB12_q;
    wire [65:0] i_cond_i_4_idqualvecop_43_26_sums_join_0_q;
    wire [50:0] i_cond_i_4_idqualvecop_43_26_sums_align_1_q;
    wire [50:0] i_cond_i_4_idqualvecop_43_26_sums_align_1_qint;
    wire [14:0] i_cond_i_5_idqualvecop_43_31_bjA10_q;
    wire [14:0] i_cond_i_5_idqualvecop_43_31_bjB12_q;
    wire [65:0] i_cond_i_5_idqualvecop_43_31_sums_join_0_q;
    wire [50:0] i_cond_i_5_idqualvecop_43_31_sums_align_1_q;
    wire [50:0] i_cond_i_5_idqualvecop_43_31_sums_align_1_qint;
    wire [14:0] i_cond_i_6_idqualvecop_43_36_bjA10_q;
    wire [14:0] i_cond_i_6_idqualvecop_43_36_bjB12_q;
    wire [65:0] i_cond_i_6_idqualvecop_43_36_sums_join_0_q;
    wire [50:0] i_cond_i_6_idqualvecop_43_36_sums_align_1_q;
    wire [50:0] i_cond_i_6_idqualvecop_43_36_sums_align_1_qint;
    wire [14:0] i_cond_i_7_idqualvecop_43_41_bjA10_q;
    wire [14:0] i_cond_i_7_idqualvecop_43_41_bjB12_q;
    wire [65:0] i_cond_i_7_idqualvecop_43_41_sums_join_0_q;
    wire [50:0] i_cond_i_7_idqualvecop_43_41_sums_align_1_q;
    wire [50:0] i_cond_i_7_idqualvecop_43_41_sums_align_1_qint;
    wire [14:0] i_cond_i_idqualvecop_43_6gr_bjA10_q;
    wire [14:0] i_cond_i_idqualvecop_43_6gr_bjB12_q;
    wire [65:0] i_cond_i_idqualvecop_43_6gr_sums_join_0_q;
    wire [50:0] i_cond_i_idqualvecop_43_6gr_sums_align_1_q;
    wire [50:0] i_cond_i_idqualvecop_43_6gr_sums_align_1_qint;
    wire [32:0] i_cond_i_1_idqualvecop_43_11_sums_result_add_0_0_lhsMSBs_select_b;
    wire [48:0] i_cond_i_1_idqualvecop_43_11_sums_result_add_0_0_MSBs_sums_a;
    wire [48:0] i_cond_i_1_idqualvecop_43_11_sums_result_add_0_0_MSBs_sums_b;
    logic [48:0] i_cond_i_1_idqualvecop_43_11_sums_result_add_0_0_MSBs_sums_o;
    wire [48:0] i_cond_i_1_idqualvecop_43_11_sums_result_add_0_0_MSBs_sums_q;
    wire [66:0] i_cond_i_1_idqualvecop_43_11_sums_result_add_0_0_split_join_q;
    wire [32:0] i_cond_i_2_idqualvecop_43_16_sums_result_add_0_0_lhsMSBs_select_b;
    wire [48:0] i_cond_i_2_idqualvecop_43_16_sums_result_add_0_0_MSBs_sums_a;
    wire [48:0] i_cond_i_2_idqualvecop_43_16_sums_result_add_0_0_MSBs_sums_b;
    logic [48:0] i_cond_i_2_idqualvecop_43_16_sums_result_add_0_0_MSBs_sums_o;
    wire [48:0] i_cond_i_2_idqualvecop_43_16_sums_result_add_0_0_MSBs_sums_q;
    wire [66:0] i_cond_i_2_idqualvecop_43_16_sums_result_add_0_0_split_join_q;
    wire [32:0] i_cond_i_3_idqualvecop_43_21_sums_result_add_0_0_lhsMSBs_select_b;
    wire [48:0] i_cond_i_3_idqualvecop_43_21_sums_result_add_0_0_MSBs_sums_a;
    wire [48:0] i_cond_i_3_idqualvecop_43_21_sums_result_add_0_0_MSBs_sums_b;
    logic [48:0] i_cond_i_3_idqualvecop_43_21_sums_result_add_0_0_MSBs_sums_o;
    wire [48:0] i_cond_i_3_idqualvecop_43_21_sums_result_add_0_0_MSBs_sums_q;
    wire [66:0] i_cond_i_3_idqualvecop_43_21_sums_result_add_0_0_split_join_q;
    wire [32:0] i_cond_i_4_idqualvecop_43_26_sums_result_add_0_0_lhsMSBs_select_b;
    wire [48:0] i_cond_i_4_idqualvecop_43_26_sums_result_add_0_0_MSBs_sums_a;
    wire [48:0] i_cond_i_4_idqualvecop_43_26_sums_result_add_0_0_MSBs_sums_b;
    logic [48:0] i_cond_i_4_idqualvecop_43_26_sums_result_add_0_0_MSBs_sums_o;
    wire [48:0] i_cond_i_4_idqualvecop_43_26_sums_result_add_0_0_MSBs_sums_q;
    wire [66:0] i_cond_i_4_idqualvecop_43_26_sums_result_add_0_0_split_join_q;
    wire [32:0] i_cond_i_5_idqualvecop_43_31_sums_result_add_0_0_lhsMSBs_select_b;
    wire [48:0] i_cond_i_5_idqualvecop_43_31_sums_result_add_0_0_MSBs_sums_a;
    wire [48:0] i_cond_i_5_idqualvecop_43_31_sums_result_add_0_0_MSBs_sums_b;
    logic [48:0] i_cond_i_5_idqualvecop_43_31_sums_result_add_0_0_MSBs_sums_o;
    wire [48:0] i_cond_i_5_idqualvecop_43_31_sums_result_add_0_0_MSBs_sums_q;
    wire [66:0] i_cond_i_5_idqualvecop_43_31_sums_result_add_0_0_split_join_q;
    wire [32:0] i_cond_i_6_idqualvecop_43_36_sums_result_add_0_0_lhsMSBs_select_b;
    wire [48:0] i_cond_i_6_idqualvecop_43_36_sums_result_add_0_0_MSBs_sums_a;
    wire [48:0] i_cond_i_6_idqualvecop_43_36_sums_result_add_0_0_MSBs_sums_b;
    logic [48:0] i_cond_i_6_idqualvecop_43_36_sums_result_add_0_0_MSBs_sums_o;
    wire [48:0] i_cond_i_6_idqualvecop_43_36_sums_result_add_0_0_MSBs_sums_q;
    wire [66:0] i_cond_i_6_idqualvecop_43_36_sums_result_add_0_0_split_join_q;
    wire [32:0] i_cond_i_7_idqualvecop_43_41_sums_result_add_0_0_lhsMSBs_select_b;
    wire [48:0] i_cond_i_7_idqualvecop_43_41_sums_result_add_0_0_MSBs_sums_a;
    wire [48:0] i_cond_i_7_idqualvecop_43_41_sums_result_add_0_0_MSBs_sums_b;
    logic [48:0] i_cond_i_7_idqualvecop_43_41_sums_result_add_0_0_MSBs_sums_o;
    wire [48:0] i_cond_i_7_idqualvecop_43_41_sums_result_add_0_0_MSBs_sums_q;
    wire [66:0] i_cond_i_7_idqualvecop_43_41_sums_result_add_0_0_split_join_q;
    wire [32:0] i_cond_i_idqualvecop_43_6gr_sums_result_add_0_0_lhsMSBs_select_b;
    wire [48:0] i_cond_i_idqualvecop_43_6gr_sums_result_add_0_0_MSBs_sums_a;
    wire [48:0] i_cond_i_idqualvecop_43_6gr_sums_result_add_0_0_MSBs_sums_b;
    logic [48:0] i_cond_i_idqualvecop_43_6gr_sums_result_add_0_0_MSBs_sums_o;
    wire [48:0] i_cond_i_idqualvecop_43_6gr_sums_result_add_0_0_MSBs_sums_q;
    wire [66:0] i_cond_i_idqualvecop_43_6gr_sums_result_add_0_0_split_join_q;
    wire i_cond_i_1_idqualvecop_43_11_im0_cma_reset;
    wire [17:0] i_cond_i_1_idqualvecop_43_11_im0_cma_a0;
    wire [17:0] i_cond_i_1_idqualvecop_43_11_im0_cma_c0;
    wire [35:0] i_cond_i_1_idqualvecop_43_11_im0_cma_s0;
    wire [35:0] i_cond_i_1_idqualvecop_43_11_im0_cma_qq0;
    wire [35:0] i_cond_i_1_idqualvecop_43_11_im0_cma_q;
    wire i_cond_i_1_idqualvecop_43_11_im0_cma_ena0;
    wire i_cond_i_1_idqualvecop_43_11_im0_cma_ena1;
    wire i_cond_i_1_idqualvecop_43_11_im0_cma_ena2;
    wire i_cond_i_1_idqualvecop_43_11_im8_cma_reset;
    wire [14:0] i_cond_i_1_idqualvecop_43_11_im8_cma_a0;
    wire [14:0] i_cond_i_1_idqualvecop_43_11_im8_cma_c0;
    wire [29:0] i_cond_i_1_idqualvecop_43_11_im8_cma_s0;
    wire [29:0] i_cond_i_1_idqualvecop_43_11_im8_cma_qq0;
    wire [29:0] i_cond_i_1_idqualvecop_43_11_im8_cma_q;
    wire i_cond_i_1_idqualvecop_43_11_im8_cma_ena0;
    wire i_cond_i_1_idqualvecop_43_11_im8_cma_ena1;
    wire i_cond_i_1_idqualvecop_43_11_im8_cma_ena2;
    wire i_cond_i_2_idqualvecop_43_16_im0_cma_reset;
    wire [17:0] i_cond_i_2_idqualvecop_43_16_im0_cma_a0;
    wire [17:0] i_cond_i_2_idqualvecop_43_16_im0_cma_c0;
    wire [35:0] i_cond_i_2_idqualvecop_43_16_im0_cma_s0;
    wire [35:0] i_cond_i_2_idqualvecop_43_16_im0_cma_qq0;
    wire [35:0] i_cond_i_2_idqualvecop_43_16_im0_cma_q;
    wire i_cond_i_2_idqualvecop_43_16_im0_cma_ena0;
    wire i_cond_i_2_idqualvecop_43_16_im0_cma_ena1;
    wire i_cond_i_2_idqualvecop_43_16_im0_cma_ena2;
    wire i_cond_i_2_idqualvecop_43_16_im8_cma_reset;
    wire [14:0] i_cond_i_2_idqualvecop_43_16_im8_cma_a0;
    wire [14:0] i_cond_i_2_idqualvecop_43_16_im8_cma_c0;
    wire [29:0] i_cond_i_2_idqualvecop_43_16_im8_cma_s0;
    wire [29:0] i_cond_i_2_idqualvecop_43_16_im8_cma_qq0;
    wire [29:0] i_cond_i_2_idqualvecop_43_16_im8_cma_q;
    wire i_cond_i_2_idqualvecop_43_16_im8_cma_ena0;
    wire i_cond_i_2_idqualvecop_43_16_im8_cma_ena1;
    wire i_cond_i_2_idqualvecop_43_16_im8_cma_ena2;
    wire i_cond_i_3_idqualvecop_43_21_im0_cma_reset;
    wire [17:0] i_cond_i_3_idqualvecop_43_21_im0_cma_a0;
    wire [17:0] i_cond_i_3_idqualvecop_43_21_im0_cma_c0;
    wire [35:0] i_cond_i_3_idqualvecop_43_21_im0_cma_s0;
    wire [35:0] i_cond_i_3_idqualvecop_43_21_im0_cma_qq0;
    wire [35:0] i_cond_i_3_idqualvecop_43_21_im0_cma_q;
    wire i_cond_i_3_idqualvecop_43_21_im0_cma_ena0;
    wire i_cond_i_3_idqualvecop_43_21_im0_cma_ena1;
    wire i_cond_i_3_idqualvecop_43_21_im0_cma_ena2;
    wire i_cond_i_3_idqualvecop_43_21_im8_cma_reset;
    wire [14:0] i_cond_i_3_idqualvecop_43_21_im8_cma_a0;
    wire [14:0] i_cond_i_3_idqualvecop_43_21_im8_cma_c0;
    wire [29:0] i_cond_i_3_idqualvecop_43_21_im8_cma_s0;
    wire [29:0] i_cond_i_3_idqualvecop_43_21_im8_cma_qq0;
    wire [29:0] i_cond_i_3_idqualvecop_43_21_im8_cma_q;
    wire i_cond_i_3_idqualvecop_43_21_im8_cma_ena0;
    wire i_cond_i_3_idqualvecop_43_21_im8_cma_ena1;
    wire i_cond_i_3_idqualvecop_43_21_im8_cma_ena2;
    wire i_cond_i_4_idqualvecop_43_26_im0_cma_reset;
    wire [17:0] i_cond_i_4_idqualvecop_43_26_im0_cma_a0;
    wire [17:0] i_cond_i_4_idqualvecop_43_26_im0_cma_c0;
    wire [35:0] i_cond_i_4_idqualvecop_43_26_im0_cma_s0;
    wire [35:0] i_cond_i_4_idqualvecop_43_26_im0_cma_qq0;
    wire [35:0] i_cond_i_4_idqualvecop_43_26_im0_cma_q;
    wire i_cond_i_4_idqualvecop_43_26_im0_cma_ena0;
    wire i_cond_i_4_idqualvecop_43_26_im0_cma_ena1;
    wire i_cond_i_4_idqualvecop_43_26_im0_cma_ena2;
    wire i_cond_i_4_idqualvecop_43_26_im8_cma_reset;
    wire [14:0] i_cond_i_4_idqualvecop_43_26_im8_cma_a0;
    wire [14:0] i_cond_i_4_idqualvecop_43_26_im8_cma_c0;
    wire [29:0] i_cond_i_4_idqualvecop_43_26_im8_cma_s0;
    wire [29:0] i_cond_i_4_idqualvecop_43_26_im8_cma_qq0;
    wire [29:0] i_cond_i_4_idqualvecop_43_26_im8_cma_q;
    wire i_cond_i_4_idqualvecop_43_26_im8_cma_ena0;
    wire i_cond_i_4_idqualvecop_43_26_im8_cma_ena1;
    wire i_cond_i_4_idqualvecop_43_26_im8_cma_ena2;
    wire i_cond_i_5_idqualvecop_43_31_im0_cma_reset;
    wire [17:0] i_cond_i_5_idqualvecop_43_31_im0_cma_a0;
    wire [17:0] i_cond_i_5_idqualvecop_43_31_im0_cma_c0;
    wire [35:0] i_cond_i_5_idqualvecop_43_31_im0_cma_s0;
    wire [35:0] i_cond_i_5_idqualvecop_43_31_im0_cma_qq0;
    wire [35:0] i_cond_i_5_idqualvecop_43_31_im0_cma_q;
    wire i_cond_i_5_idqualvecop_43_31_im0_cma_ena0;
    wire i_cond_i_5_idqualvecop_43_31_im0_cma_ena1;
    wire i_cond_i_5_idqualvecop_43_31_im0_cma_ena2;
    wire i_cond_i_5_idqualvecop_43_31_im8_cma_reset;
    wire [14:0] i_cond_i_5_idqualvecop_43_31_im8_cma_a0;
    wire [14:0] i_cond_i_5_idqualvecop_43_31_im8_cma_c0;
    wire [29:0] i_cond_i_5_idqualvecop_43_31_im8_cma_s0;
    wire [29:0] i_cond_i_5_idqualvecop_43_31_im8_cma_qq0;
    wire [29:0] i_cond_i_5_idqualvecop_43_31_im8_cma_q;
    wire i_cond_i_5_idqualvecop_43_31_im8_cma_ena0;
    wire i_cond_i_5_idqualvecop_43_31_im8_cma_ena1;
    wire i_cond_i_5_idqualvecop_43_31_im8_cma_ena2;
    wire i_cond_i_6_idqualvecop_43_36_im0_cma_reset;
    wire [17:0] i_cond_i_6_idqualvecop_43_36_im0_cma_a0;
    wire [17:0] i_cond_i_6_idqualvecop_43_36_im0_cma_c0;
    wire [35:0] i_cond_i_6_idqualvecop_43_36_im0_cma_s0;
    wire [35:0] i_cond_i_6_idqualvecop_43_36_im0_cma_qq0;
    wire [35:0] i_cond_i_6_idqualvecop_43_36_im0_cma_q;
    wire i_cond_i_6_idqualvecop_43_36_im0_cma_ena0;
    wire i_cond_i_6_idqualvecop_43_36_im0_cma_ena1;
    wire i_cond_i_6_idqualvecop_43_36_im0_cma_ena2;
    wire i_cond_i_6_idqualvecop_43_36_im8_cma_reset;
    wire [14:0] i_cond_i_6_idqualvecop_43_36_im8_cma_a0;
    wire [14:0] i_cond_i_6_idqualvecop_43_36_im8_cma_c0;
    wire [29:0] i_cond_i_6_idqualvecop_43_36_im8_cma_s0;
    wire [29:0] i_cond_i_6_idqualvecop_43_36_im8_cma_qq0;
    wire [29:0] i_cond_i_6_idqualvecop_43_36_im8_cma_q;
    wire i_cond_i_6_idqualvecop_43_36_im8_cma_ena0;
    wire i_cond_i_6_idqualvecop_43_36_im8_cma_ena1;
    wire i_cond_i_6_idqualvecop_43_36_im8_cma_ena2;
    wire i_cond_i_7_idqualvecop_43_41_im0_cma_reset;
    wire [17:0] i_cond_i_7_idqualvecop_43_41_im0_cma_a0;
    wire [17:0] i_cond_i_7_idqualvecop_43_41_im0_cma_c0;
    wire [35:0] i_cond_i_7_idqualvecop_43_41_im0_cma_s0;
    wire [35:0] i_cond_i_7_idqualvecop_43_41_im0_cma_qq0;
    wire [35:0] i_cond_i_7_idqualvecop_43_41_im0_cma_q;
    wire i_cond_i_7_idqualvecop_43_41_im0_cma_ena0;
    wire i_cond_i_7_idqualvecop_43_41_im0_cma_ena1;
    wire i_cond_i_7_idqualvecop_43_41_im0_cma_ena2;
    wire i_cond_i_7_idqualvecop_43_41_im8_cma_reset;
    wire [14:0] i_cond_i_7_idqualvecop_43_41_im8_cma_a0;
    wire [14:0] i_cond_i_7_idqualvecop_43_41_im8_cma_c0;
    wire [29:0] i_cond_i_7_idqualvecop_43_41_im8_cma_s0;
    wire [29:0] i_cond_i_7_idqualvecop_43_41_im8_cma_qq0;
    wire [29:0] i_cond_i_7_idqualvecop_43_41_im8_cma_q;
    wire i_cond_i_7_idqualvecop_43_41_im8_cma_ena0;
    wire i_cond_i_7_idqualvecop_43_41_im8_cma_ena1;
    wire i_cond_i_7_idqualvecop_43_41_im8_cma_ena2;
    wire i_cond_i_idqualvecop_43_6gr_im0_cma_reset;
    wire [17:0] i_cond_i_idqualvecop_43_6gr_im0_cma_a0;
    wire [17:0] i_cond_i_idqualvecop_43_6gr_im0_cma_c0;
    wire [35:0] i_cond_i_idqualvecop_43_6gr_im0_cma_s0;
    wire [35:0] i_cond_i_idqualvecop_43_6gr_im0_cma_qq0;
    wire [35:0] i_cond_i_idqualvecop_43_6gr_im0_cma_q;
    wire i_cond_i_idqualvecop_43_6gr_im0_cma_ena0;
    wire i_cond_i_idqualvecop_43_6gr_im0_cma_ena1;
    wire i_cond_i_idqualvecop_43_6gr_im0_cma_ena2;
    wire i_cond_i_idqualvecop_43_6gr_im8_cma_reset;
    wire [14:0] i_cond_i_idqualvecop_43_6gr_im8_cma_a0;
    wire [14:0] i_cond_i_idqualvecop_43_6gr_im8_cma_c0;
    wire [29:0] i_cond_i_idqualvecop_43_6gr_im8_cma_s0;
    wire [29:0] i_cond_i_idqualvecop_43_6gr_im8_cma_qq0;
    wire [29:0] i_cond_i_idqualvecop_43_6gr_im8_cma_q;
    wire i_cond_i_idqualvecop_43_6gr_im8_cma_ena0;
    wire i_cond_i_idqualvecop_43_6gr_im8_cma_ena1;
    wire i_cond_i_idqualvecop_43_6gr_im8_cma_ena2;
    wire i_cond_i_1_idqualvecop_43_11_ma3_cma_reset;
    wire [13:0] i_cond_i_1_idqualvecop_43_11_ma3_cma_a0;
    wire [17:0] i_cond_i_1_idqualvecop_43_11_ma3_cma_c0;
    wire [13:0] i_cond_i_1_idqualvecop_43_11_ma3_cma_a1;
    wire [17:0] i_cond_i_1_idqualvecop_43_11_ma3_cma_c1;
    wire [32:0] i_cond_i_1_idqualvecop_43_11_ma3_cma_s0;
    wire [32:0] i_cond_i_1_idqualvecop_43_11_ma3_cma_qq0;
    wire [32:0] i_cond_i_1_idqualvecop_43_11_ma3_cma_q;
    wire i_cond_i_1_idqualvecop_43_11_ma3_cma_ena0;
    wire i_cond_i_1_idqualvecop_43_11_ma3_cma_ena1;
    wire i_cond_i_1_idqualvecop_43_11_ma3_cma_ena2;
    wire i_cond_i_2_idqualvecop_43_16_ma3_cma_reset;
    wire [13:0] i_cond_i_2_idqualvecop_43_16_ma3_cma_a0;
    wire [17:0] i_cond_i_2_idqualvecop_43_16_ma3_cma_c0;
    wire [13:0] i_cond_i_2_idqualvecop_43_16_ma3_cma_a1;
    wire [17:0] i_cond_i_2_idqualvecop_43_16_ma3_cma_c1;
    wire [32:0] i_cond_i_2_idqualvecop_43_16_ma3_cma_s0;
    wire [32:0] i_cond_i_2_idqualvecop_43_16_ma3_cma_qq0;
    wire [32:0] i_cond_i_2_idqualvecop_43_16_ma3_cma_q;
    wire i_cond_i_2_idqualvecop_43_16_ma3_cma_ena0;
    wire i_cond_i_2_idqualvecop_43_16_ma3_cma_ena1;
    wire i_cond_i_2_idqualvecop_43_16_ma3_cma_ena2;
    wire i_cond_i_3_idqualvecop_43_21_ma3_cma_reset;
    wire [13:0] i_cond_i_3_idqualvecop_43_21_ma3_cma_a0;
    wire [17:0] i_cond_i_3_idqualvecop_43_21_ma3_cma_c0;
    wire [13:0] i_cond_i_3_idqualvecop_43_21_ma3_cma_a1;
    wire [17:0] i_cond_i_3_idqualvecop_43_21_ma3_cma_c1;
    wire [32:0] i_cond_i_3_idqualvecop_43_21_ma3_cma_s0;
    wire [32:0] i_cond_i_3_idqualvecop_43_21_ma3_cma_qq0;
    wire [32:0] i_cond_i_3_idqualvecop_43_21_ma3_cma_q;
    wire i_cond_i_3_idqualvecop_43_21_ma3_cma_ena0;
    wire i_cond_i_3_idqualvecop_43_21_ma3_cma_ena1;
    wire i_cond_i_3_idqualvecop_43_21_ma3_cma_ena2;
    wire i_cond_i_4_idqualvecop_43_26_ma3_cma_reset;
    wire [13:0] i_cond_i_4_idqualvecop_43_26_ma3_cma_a0;
    wire [17:0] i_cond_i_4_idqualvecop_43_26_ma3_cma_c0;
    wire [13:0] i_cond_i_4_idqualvecop_43_26_ma3_cma_a1;
    wire [17:0] i_cond_i_4_idqualvecop_43_26_ma3_cma_c1;
    wire [32:0] i_cond_i_4_idqualvecop_43_26_ma3_cma_s0;
    wire [32:0] i_cond_i_4_idqualvecop_43_26_ma3_cma_qq0;
    wire [32:0] i_cond_i_4_idqualvecop_43_26_ma3_cma_q;
    wire i_cond_i_4_idqualvecop_43_26_ma3_cma_ena0;
    wire i_cond_i_4_idqualvecop_43_26_ma3_cma_ena1;
    wire i_cond_i_4_idqualvecop_43_26_ma3_cma_ena2;
    wire i_cond_i_5_idqualvecop_43_31_ma3_cma_reset;
    wire [13:0] i_cond_i_5_idqualvecop_43_31_ma3_cma_a0;
    wire [17:0] i_cond_i_5_idqualvecop_43_31_ma3_cma_c0;
    wire [13:0] i_cond_i_5_idqualvecop_43_31_ma3_cma_a1;
    wire [17:0] i_cond_i_5_idqualvecop_43_31_ma3_cma_c1;
    wire [32:0] i_cond_i_5_idqualvecop_43_31_ma3_cma_s0;
    wire [32:0] i_cond_i_5_idqualvecop_43_31_ma3_cma_qq0;
    wire [32:0] i_cond_i_5_idqualvecop_43_31_ma3_cma_q;
    wire i_cond_i_5_idqualvecop_43_31_ma3_cma_ena0;
    wire i_cond_i_5_idqualvecop_43_31_ma3_cma_ena1;
    wire i_cond_i_5_idqualvecop_43_31_ma3_cma_ena2;
    wire i_cond_i_6_idqualvecop_43_36_ma3_cma_reset;
    wire [13:0] i_cond_i_6_idqualvecop_43_36_ma3_cma_a0;
    wire [17:0] i_cond_i_6_idqualvecop_43_36_ma3_cma_c0;
    wire [13:0] i_cond_i_6_idqualvecop_43_36_ma3_cma_a1;
    wire [17:0] i_cond_i_6_idqualvecop_43_36_ma3_cma_c1;
    wire [32:0] i_cond_i_6_idqualvecop_43_36_ma3_cma_s0;
    wire [32:0] i_cond_i_6_idqualvecop_43_36_ma3_cma_qq0;
    wire [32:0] i_cond_i_6_idqualvecop_43_36_ma3_cma_q;
    wire i_cond_i_6_idqualvecop_43_36_ma3_cma_ena0;
    wire i_cond_i_6_idqualvecop_43_36_ma3_cma_ena1;
    wire i_cond_i_6_idqualvecop_43_36_ma3_cma_ena2;
    wire i_cond_i_7_idqualvecop_43_41_ma3_cma_reset;
    wire [13:0] i_cond_i_7_idqualvecop_43_41_ma3_cma_a0;
    wire [17:0] i_cond_i_7_idqualvecop_43_41_ma3_cma_c0;
    wire [13:0] i_cond_i_7_idqualvecop_43_41_ma3_cma_a1;
    wire [17:0] i_cond_i_7_idqualvecop_43_41_ma3_cma_c1;
    wire [32:0] i_cond_i_7_idqualvecop_43_41_ma3_cma_s0;
    wire [32:0] i_cond_i_7_idqualvecop_43_41_ma3_cma_qq0;
    wire [32:0] i_cond_i_7_idqualvecop_43_41_ma3_cma_q;
    wire i_cond_i_7_idqualvecop_43_41_ma3_cma_ena0;
    wire i_cond_i_7_idqualvecop_43_41_ma3_cma_ena1;
    wire i_cond_i_7_idqualvecop_43_41_ma3_cma_ena2;
    wire i_cond_i_idqualvecop_43_6gr_ma3_cma_reset;
    wire [13:0] i_cond_i_idqualvecop_43_6gr_ma3_cma_a0;
    wire [17:0] i_cond_i_idqualvecop_43_6gr_ma3_cma_c0;
    wire [13:0] i_cond_i_idqualvecop_43_6gr_ma3_cma_a1;
    wire [17:0] i_cond_i_idqualvecop_43_6gr_ma3_cma_c1;
    wire [32:0] i_cond_i_idqualvecop_43_6gr_ma3_cma_s0;
    wire [32:0] i_cond_i_idqualvecop_43_6gr_ma3_cma_qq0;
    wire [32:0] i_cond_i_idqualvecop_43_6gr_ma3_cma_q;
    wire i_cond_i_idqualvecop_43_6gr_ma3_cma_ena0;
    wire i_cond_i_idqualvecop_43_6gr_ma3_cma_ena1;
    wire i_cond_i_idqualvecop_43_6gr_ma3_cma_ena2;
    wire [30:0] i_add_i_pn_2_idqualvecop_43_14_rhsMSBs_select_bit_select_merged_b;
    wire [0:0] i_add_i_pn_2_idqualvecop_43_14_rhsMSBs_select_bit_select_merged_c;
    wire [29:0] i_add_i_pn_4_idqualvecop_43_24_rhsMSBs_select_bit_select_merged_b;
    wire [1:0] i_add_i_pn_4_idqualvecop_43_24_rhsMSBs_select_bit_select_merged_c;
    wire [30:0] i_add_i_pn_6_idqualvecop_43_34_rhsMSBs_select_bit_select_merged_b;
    wire [0:0] i_add_i_pn_6_idqualvecop_43_34_rhsMSBs_select_bit_select_merged_c;
    wire [17:0] i_cond_i_idqualvecop_43_6gr_bs1_bit_select_merged_b;
    wire [13:0] i_cond_i_idqualvecop_43_6gr_bs1_bit_select_merged_c;
    wire [17:0] i_cond_i_3_idqualvecop_43_21_bs2_bit_select_merged_b;
    wire [13:0] i_cond_i_3_idqualvecop_43_21_bs2_bit_select_merged_c;
    wire [17:0] i_cond_i_4_idqualvecop_43_26_bs2_bit_select_merged_b;
    wire [13:0] i_cond_i_4_idqualvecop_43_26_bs2_bit_select_merged_c;
    wire [17:0] i_cond_i_5_idqualvecop_43_31_bs2_bit_select_merged_b;
    wire [13:0] i_cond_i_5_idqualvecop_43_31_bs2_bit_select_merged_c;
    wire [17:0] i_cond_i_6_idqualvecop_43_36_bs2_bit_select_merged_b;
    wire [13:0] i_cond_i_6_idqualvecop_43_36_bs2_bit_select_merged_c;
    wire [17:0] i_cond_i_7_idqualvecop_43_41_bs2_bit_select_merged_b;
    wire [13:0] i_cond_i_7_idqualvecop_43_41_bs2_bit_select_merged_c;
    wire [17:0] i_cond_i_1_idqualvecop_43_11_bs2_bit_select_merged_b;
    wire [13:0] i_cond_i_1_idqualvecop_43_11_bs2_bit_select_merged_c;
    wire [17:0] i_cond_i_2_idqualvecop_43_16_bs2_bit_select_merged_b;
    wire [13:0] i_cond_i_2_idqualvecop_43_16_bs2_bit_select_merged_c;
    wire [17:0] i_cond_i_idqualvecop_43_6gr_bs2_bit_select_merged_b;
    wire [13:0] i_cond_i_idqualvecop_43_6gr_bs2_bit_select_merged_c;
    wire [17:0] i_cond_i_1_idqualvecop_43_11_bs1_bit_select_merged_b;
    wire [13:0] i_cond_i_1_idqualvecop_43_11_bs1_bit_select_merged_c;
    wire [17:0] i_cond_i_2_idqualvecop_43_16_bs1_bit_select_merged_b;
    wire [13:0] i_cond_i_2_idqualvecop_43_16_bs1_bit_select_merged_c;
    wire [17:0] i_cond_i_3_idqualvecop_43_21_bs1_bit_select_merged_b;
    wire [13:0] i_cond_i_3_idqualvecop_43_21_bs1_bit_select_merged_c;
    wire [17:0] i_cond_i_4_idqualvecop_43_26_bs1_bit_select_merged_b;
    wire [13:0] i_cond_i_4_idqualvecop_43_26_bs1_bit_select_merged_c;
    wire [17:0] i_cond_i_5_idqualvecop_43_31_bs1_bit_select_merged_b;
    wire [13:0] i_cond_i_5_idqualvecop_43_31_bs1_bit_select_merged_c;
    wire [17:0] i_cond_i_6_idqualvecop_43_36_bs1_bit_select_merged_b;
    wire [13:0] i_cond_i_6_idqualvecop_43_36_bs1_bit_select_merged_c;
    wire [17:0] i_cond_i_7_idqualvecop_43_41_bs1_bit_select_merged_b;
    wire [13:0] i_cond_i_7_idqualvecop_43_41_bs1_bit_select_merged_c;
    wire [47:0] i_cond_i_1_idqualvecop_43_11_sums_result_add_0_0_rhsMSBs_select_bit_select_merged_b;
    wire [17:0] i_cond_i_1_idqualvecop_43_11_sums_result_add_0_0_rhsMSBs_select_bit_select_merged_c;
    wire [47:0] i_cond_i_2_idqualvecop_43_16_sums_result_add_0_0_rhsMSBs_select_bit_select_merged_b;
    wire [17:0] i_cond_i_2_idqualvecop_43_16_sums_result_add_0_0_rhsMSBs_select_bit_select_merged_c;
    wire [47:0] i_cond_i_3_idqualvecop_43_21_sums_result_add_0_0_rhsMSBs_select_bit_select_merged_b;
    wire [17:0] i_cond_i_3_idqualvecop_43_21_sums_result_add_0_0_rhsMSBs_select_bit_select_merged_c;
    wire [47:0] i_cond_i_4_idqualvecop_43_26_sums_result_add_0_0_rhsMSBs_select_bit_select_merged_b;
    wire [17:0] i_cond_i_4_idqualvecop_43_26_sums_result_add_0_0_rhsMSBs_select_bit_select_merged_c;
    wire [47:0] i_cond_i_5_idqualvecop_43_31_sums_result_add_0_0_rhsMSBs_select_bit_select_merged_b;
    wire [17:0] i_cond_i_5_idqualvecop_43_31_sums_result_add_0_0_rhsMSBs_select_bit_select_merged_c;
    wire [47:0] i_cond_i_6_idqualvecop_43_36_sums_result_add_0_0_rhsMSBs_select_bit_select_merged_b;
    wire [17:0] i_cond_i_6_idqualvecop_43_36_sums_result_add_0_0_rhsMSBs_select_bit_select_merged_c;
    wire [47:0] i_cond_i_7_idqualvecop_43_41_sums_result_add_0_0_rhsMSBs_select_bit_select_merged_b;
    wire [17:0] i_cond_i_7_idqualvecop_43_41_sums_result_add_0_0_rhsMSBs_select_bit_select_merged_c;
    wire [47:0] i_cond_i_idqualvecop_43_6gr_sums_result_add_0_0_rhsMSBs_select_bit_select_merged_b;
    wire [17:0] i_cond_i_idqualvecop_43_6gr_sums_result_add_0_0_rhsMSBs_select_bit_select_merged_c;
    reg [0:0] redist0_sync_together_43_89_in_i_valid_5_q;
    reg [0:0] redist0_sync_together_43_89_in_i_valid_5_delay_0;
    reg [0:0] redist0_sync_together_43_89_in_i_valid_5_delay_1;
    reg [0:0] redist0_sync_together_43_89_in_i_valid_5_delay_2;
    reg [0:0] redist0_sync_together_43_89_in_i_valid_5_delay_3;


    // VCC(CONSTANT,1)
    assign VCC_q = 1'b1;

    // redist0_sync_together_43_89_in_i_valid_5(DELAY,422)
    always_ff @ (posedge clock) begin
        if (!resetn) begin
            redist0_sync_together_43_89_in_i_valid_5_delay_0 <= '0;
        end
        else begin
            redist0_sync_together_43_89_in_i_valid_5_delay_0 <= $unsigned(in_i_valid);
        end
    end
    always_ff @ (posedge clock) begin
        redist0_sync_together_43_89_in_i_valid_5_delay_1 <= redist0_sync_together_43_89_in_i_valid_5_delay_0;
    end
    always_ff @ (posedge clock) begin
        if (!resetn) begin
            redist0_sync_together_43_89_in_i_valid_5_delay_2 <= '0;
        end
        else begin
            redist0_sync_together_43_89_in_i_valid_5_delay_2 <= redist0_sync_together_43_89_in_i_valid_5_delay_1;
        end
    end
    always_ff @ (posedge clock) begin
        redist0_sync_together_43_89_in_i_valid_5_delay_3 <= redist0_sync_together_43_89_in_i_valid_5_delay_2;
    end
    always_ff @ (posedge clock) begin
        if (!resetn) begin
            redist0_sync_together_43_89_in_i_valid_5_q <= '0;
        end
        else begin
            redist0_sync_together_43_89_in_i_valid_5_q <= $signed(redist0_sync_together_43_89_in_i_valid_5_delay_3);
        end
    end

    // valid_fanout_reg18(REG,163)@5 + 1
    always_ff @ (posedge clock) begin
        valid_fanout_reg18_q <= redist0_sync_together_43_89_in_i_valid_5_q;
    end

    // i_io_full_acl_c_resultpipeid_pipe_channel_unnamed_idqualvecop1_idqualvecop_43_49(BLACKBOX,96)@6
    IDQualVecOp_i_io_full_acl_c_resultpipeid0000_idqualvecop_164_0gr thei_io_full_acl_c_resultpipeid_pipe_channel_unnamed_idqualvecop1_idqualvecop_43_49 (
        .in_avst_iowr_nb_acl_c_ResultPipeID_pipe_channel_almostfull(in_avst_iowr_nb_acl_c_ResultPipeID_pipe_channel_almostfull),
        .in_i_stall(GND_q),
        .in_i_valid(valid_fanout_reg18_q),
        .out_o_almostfull(i_io_full_acl_c_resultpipeid_pipe_channel_unnamed_idqualvecop1_idqualvecop_43_49_out_o_almostfull),
        .out_o_stall(),
        .out_o_valid(),
        .clock(clock),
        .resetn(resetn)
    );

    // valid_fanout_reg19(REG,164)@5 + 1
    always_ff @ (posedge clock) begin
        valid_fanout_reg19_q <= redist0_sync_together_43_89_in_i_valid_5_q;
    end

    // GND(CONSTANT,0)
    assign GND_q = 1'b0;

    // valid_fanout_reg3(REG,148)@0 + 1
    always_ff @ (posedge clock) begin
        valid_fanout_reg3_q <= in_i_valid;
    end

    // i_llvm_fpga_sync_buffer_i32_arg_b_sync_buffer_idqualvecop_43_5gr(BLACKBOX,113)@0
    // in in_i_dependence@1
    // in in_valid_in@1
    // out out_buffer_out@1
    // out out_valid_out@1
    IDQualVecOp_i_llvm_fpga_sync_buffer_i32_0000r_idqualvecop_60_0gr thei_llvm_fpga_sync_buffer_i32_arg_b_sync_buffer_idqualvecop_43_5gr (
        .in_buffer_in(in_arg_b),
        .in_i_dependence(GND_q),
        .in_stall_in(GND_q),
        .in_valid_in(valid_fanout_reg3_q),
        .out_buffer_out(i_llvm_fpga_sync_buffer_i32_arg_b_sync_buffer_idqualvecop_43_5gr_out_buffer_out),
        .out_stall_out(),
        .out_valid_out(),
        .clock(clock),
        .resetn(resetn)
    );

    // i_cond_i_idqualvecop_43_6gr_bs2_bit_select_merged(BITSELECT,406)@1
    assign i_cond_i_idqualvecop_43_6gr_bs2_bit_select_merged_b = $signed(i_llvm_fpga_sync_buffer_i32_arg_b_sync_buffer_idqualvecop_43_5gr_out_buffer_out[17:0]);
    assign i_cond_i_idqualvecop_43_6gr_bs2_bit_select_merged_c = $signed(i_llvm_fpga_sync_buffer_i32_arg_b_sync_buffer_idqualvecop_43_5gr_out_buffer_out[31:18]);

    // valid_fanout_reg2(REG,147)@0 + 1
    always_ff @ (posedge clock) begin
        valid_fanout_reg2_q <= in_i_valid;
    end

    // i_llvm_fpga_sync_buffer_i32_arg_a_sync_buffer7_idqualvecop_43_4gr(BLACKBOX,104)@0
    // in in_i_dependence@1
    // in in_valid_in@1
    // out out_buffer_out@1
    // out out_valid_out@1
    IDQualVecOp_i_llvm_fpga_sync_buffer_i32_00007_idqualvecop_55_0gr thei_llvm_fpga_sync_buffer_i32_arg_a_sync_buffer7_idqualvecop_43_4gr (
        .in_buffer_in(in_arg_a),
        .in_i_dependence(GND_q),
        .in_stall_in(GND_q),
        .in_valid_in(valid_fanout_reg2_q),
        .out_buffer_out(i_llvm_fpga_sync_buffer_i32_arg_a_sync_buffer7_idqualvecop_43_4gr_out_buffer_out),
        .out_stall_out(),
        .out_valid_out(),
        .clock(clock),
        .resetn(resetn)
    );

    // i_cond_i_idqualvecop_43_6gr_bs1_bit_select_merged(BITSELECT,398)@1
    assign i_cond_i_idqualvecop_43_6gr_bs1_bit_select_merged_b = $signed(i_llvm_fpga_sync_buffer_i32_arg_a_sync_buffer7_idqualvecop_43_4gr_out_buffer_out[17:0]);
    assign i_cond_i_idqualvecop_43_6gr_bs1_bit_select_merged_c = $signed(i_llvm_fpga_sync_buffer_i32_arg_a_sync_buffer7_idqualvecop_43_4gr_out_buffer_out[31:18]);

    // i_cond_i_idqualvecop_43_6gr_ma3_cma(CHAINMULTADD,394)@1 + 4
    // in b@4
    assign i_cond_i_idqualvecop_43_6gr_ma3_cma_reset = ~ (resetn);
    assign i_cond_i_idqualvecop_43_6gr_ma3_cma_ena0 = 1'b1;
    assign i_cond_i_idqualvecop_43_6gr_ma3_cma_ena1 = i_cond_i_idqualvecop_43_6gr_ma3_cma_ena0;
    assign i_cond_i_idqualvecop_43_6gr_ma3_cma_ena2 = i_cond_i_idqualvecop_43_6gr_ma3_cma_ena0;

    assign i_cond_i_idqualvecop_43_6gr_ma3_cma_a0 = i_cond_i_idqualvecop_43_6gr_bs1_bit_select_merged_c;
    assign i_cond_i_idqualvecop_43_6gr_ma3_cma_c0 = i_cond_i_idqualvecop_43_6gr_bs2_bit_select_merged_b;
    assign i_cond_i_idqualvecop_43_6gr_ma3_cma_a1 = i_cond_i_idqualvecop_43_6gr_bs2_bit_select_merged_c;
    assign i_cond_i_idqualvecop_43_6gr_ma3_cma_c1 = i_cond_i_idqualvecop_43_6gr_bs1_bit_select_merged_b;
    tennm_mac #(
        .operation_mode("m18x18_sumof2"),
        .clear_type("none"),
        .use_chainadder("false"),
        .ay_scan_in_clken("0"),
        .ay_scan_in_width(14),
        .by_clken("0"),
        .by_width(14),
        .ax_clken("0"),
        .bx_clken("0"),
        .ax_width(18),
        .bx_width(18),
        .signed_may("false"),
        .signed_mby("false"),
        .signed_max("false"),
        .signed_mbx("false"),
        .input_pipeline_clken("2"),
        .second_pipeline_clken("2"),
        .output_clken("1"),
        .result_a_width(33)
    ) i_cond_i_idqualvecop_43_6gr_ma3_cma_DSP0 (
        .clk(clock),
        .ena({ i_cond_i_idqualvecop_43_6gr_ma3_cma_ena2, i_cond_i_idqualvecop_43_6gr_ma3_cma_ena1, i_cond_i_idqualvecop_43_6gr_ma3_cma_ena0 }),
        .clr({ 1'b0, 1'b0 }),
        .ay(i_cond_i_idqualvecop_43_6gr_ma3_cma_a1),
        .by(i_cond_i_idqualvecop_43_6gr_ma3_cma_a0),
        .ax(i_cond_i_idqualvecop_43_6gr_ma3_cma_c1),
        .bx(i_cond_i_idqualvecop_43_6gr_ma3_cma_c0),
        .resulta(i_cond_i_idqualvecop_43_6gr_ma3_cma_s0),
        .accumulate(),
        .loadconst(),
        .negate(),
        .sub(),
        .az(),
        .coefsela(),
        .bz(),
        .coefselb(),
        .cx(),
        .cy(),
        .dx(),
        .dy(),
        .scanin(),
        .scanout(),
        .chainin(),
        .chainout(),
        .disable_scanin(),
        .disable_chainout(),
        .resultb(),
        .dfxlfsrena(),
        .dfxmisrena()
    );
    dspba_delay_ver #( .width(33), .depth(0), .reset_kind("NONE"), .phase(0), .modulus(1), .reset_high(1'b0) )
    i_cond_i_idqualvecop_43_6gr_ma3_cma_delay0 ( .xin(i_cond_i_idqualvecop_43_6gr_ma3_cma_s0), .xout(i_cond_i_idqualvecop_43_6gr_ma3_cma_qq0), .clk(clock), .aclr(resetn), .ena(1'b1) );
    assign i_cond_i_idqualvecop_43_6gr_ma3_cma_q = $unsigned(i_cond_i_idqualvecop_43_6gr_ma3_cma_qq0[32:0]);

    // i_cond_i_idqualvecop_43_6gr_sums_align_1(BITSHIFT,328)@5
    assign i_cond_i_idqualvecop_43_6gr_sums_align_1_qint = { i_cond_i_idqualvecop_43_6gr_ma3_cma_q, 18'b000000000000000000 };
    assign i_cond_i_idqualvecop_43_6gr_sums_align_1_q = i_cond_i_idqualvecop_43_6gr_sums_align_1_qint[50:0];

    // i_cond_i_idqualvecop_43_6gr_sums_result_add_0_0_lhsMSBs_select(BITSELECT,368)@5
    assign i_cond_i_idqualvecop_43_6gr_sums_result_add_0_0_lhsMSBs_select_b = $signed(i_cond_i_idqualvecop_43_6gr_sums_align_1_q[50:18]);

    // i_cond_i_idqualvecop_43_6gr_sums_result_add_0_0_MSBs_sums(ADD,369)@5
    assign i_cond_i_idqualvecop_43_6gr_sums_result_add_0_0_MSBs_sums_a = {16'b0000000000000000, i_cond_i_idqualvecop_43_6gr_sums_result_add_0_0_lhsMSBs_select_b};
    assign i_cond_i_idqualvecop_43_6gr_sums_result_add_0_0_MSBs_sums_b = {1'b0, i_cond_i_idqualvecop_43_6gr_sums_result_add_0_0_rhsMSBs_select_bit_select_merged_b};
    assign i_cond_i_idqualvecop_43_6gr_sums_result_add_0_0_MSBs_sums_o = $unsigned(i_cond_i_idqualvecop_43_6gr_sums_result_add_0_0_MSBs_sums_a) + $unsigned(i_cond_i_idqualvecop_43_6gr_sums_result_add_0_0_MSBs_sums_b);
    assign i_cond_i_idqualvecop_43_6gr_sums_result_add_0_0_MSBs_sums_q = $signed(i_cond_i_idqualvecop_43_6gr_sums_result_add_0_0_MSBs_sums_o[48:0]);

    // i_cond_i_idqualvecop_43_6gr_bjB12(BITJOIN,326)@1
    assign i_cond_i_idqualvecop_43_6gr_bjB12_q = {GND_q, i_cond_i_idqualvecop_43_6gr_bs2_bit_select_merged_c};

    // i_cond_i_idqualvecop_43_6gr_bjA10(BITJOIN,324)@1
    assign i_cond_i_idqualvecop_43_6gr_bjA10_q = {GND_q, i_cond_i_idqualvecop_43_6gr_bs1_bit_select_merged_c};

    // i_cond_i_idqualvecop_43_6gr_im8_cma(CHAINMULTADD,386)@1 + 4
    // in b@4
    assign i_cond_i_idqualvecop_43_6gr_im8_cma_reset = ~ (resetn);
    assign i_cond_i_idqualvecop_43_6gr_im8_cma_ena0 = 1'b1;
    assign i_cond_i_idqualvecop_43_6gr_im8_cma_ena1 = i_cond_i_idqualvecop_43_6gr_im8_cma_ena0;
    assign i_cond_i_idqualvecop_43_6gr_im8_cma_ena2 = i_cond_i_idqualvecop_43_6gr_im8_cma_ena0;

    assign i_cond_i_idqualvecop_43_6gr_im8_cma_a0 = $unsigned(i_cond_i_idqualvecop_43_6gr_bjA10_q);
    assign i_cond_i_idqualvecop_43_6gr_im8_cma_c0 = $unsigned(i_cond_i_idqualvecop_43_6gr_bjB12_q);
    tennm_mac #(
        .operation_mode("m18x18_full"),
        .clear_type("none"),
        .ay_scan_in_clken("0"),
        .ay_scan_in_width(15),
        .ax_clken("0"),
        .ax_width(15),
        .signed_may("true"),
        .signed_max("true"),
        .input_pipeline_clken("2"),
        .second_pipeline_clken("2"),
        .output_clken("1"),
        .result_a_width(30)
    ) i_cond_i_idqualvecop_43_6gr_im8_cma_DSP0 (
        .clk(clock),
        .ena({ i_cond_i_idqualvecop_43_6gr_im8_cma_ena2, i_cond_i_idqualvecop_43_6gr_im8_cma_ena1, i_cond_i_idqualvecop_43_6gr_im8_cma_ena0 }),
        .clr({ 1'b0, 1'b0 }),
        .ay(i_cond_i_idqualvecop_43_6gr_im8_cma_a0),
        .ax(i_cond_i_idqualvecop_43_6gr_im8_cma_c0),
        .resulta(i_cond_i_idqualvecop_43_6gr_im8_cma_s0),
        .accumulate(),
        .loadconst(),
        .negate(),
        .sub(),
        .az(),
        .coefsela(),
        .bx(),
        .by(),
        .bz(),
        .coefselb(),
        .cx(),
        .cy(),
        .dx(),
        .dy(),
        .scanin(),
        .scanout(),
        .chainin(),
        .chainout(),
        .disable_scanin(),
        .disable_chainout(),
        .resultb(),
        .dfxlfsrena(),
        .dfxmisrena()
    );
    dspba_delay_ver #( .width(30), .depth(0), .reset_kind("NONE"), .phase(0), .modulus(1), .reset_high(1'b0) )
    i_cond_i_idqualvecop_43_6gr_im8_cma_delay0 ( .xin(i_cond_i_idqualvecop_43_6gr_im8_cma_s0), .xout(i_cond_i_idqualvecop_43_6gr_im8_cma_qq0), .clk(clock), .aclr(resetn), .ena(1'b1) );
    assign i_cond_i_idqualvecop_43_6gr_im8_cma_q = $unsigned(i_cond_i_idqualvecop_43_6gr_im8_cma_qq0[29:0]);

    // i_cond_i_idqualvecop_43_6gr_im0_cma(CHAINMULTADD,385)@1 + 4
    // in b@4
    assign i_cond_i_idqualvecop_43_6gr_im0_cma_reset = ~ (resetn);
    assign i_cond_i_idqualvecop_43_6gr_im0_cma_ena0 = 1'b1;
    assign i_cond_i_idqualvecop_43_6gr_im0_cma_ena1 = i_cond_i_idqualvecop_43_6gr_im0_cma_ena0;
    assign i_cond_i_idqualvecop_43_6gr_im0_cma_ena2 = i_cond_i_idqualvecop_43_6gr_im0_cma_ena0;

    assign i_cond_i_idqualvecop_43_6gr_im0_cma_a0 = i_cond_i_idqualvecop_43_6gr_bs1_bit_select_merged_b;
    assign i_cond_i_idqualvecop_43_6gr_im0_cma_c0 = i_cond_i_idqualvecop_43_6gr_bs2_bit_select_merged_b;
    tennm_mac #(
        .operation_mode("m18x18_full"),
        .clear_type("none"),
        .ay_scan_in_clken("0"),
        .ay_scan_in_width(18),
        .ax_clken("0"),
        .ax_width(18),
        .signed_may("false"),
        .signed_max("false"),
        .input_pipeline_clken("2"),
        .second_pipeline_clken("2"),
        .output_clken("1"),
        .result_a_width(36)
    ) i_cond_i_idqualvecop_43_6gr_im0_cma_DSP0 (
        .clk(clock),
        .ena({ i_cond_i_idqualvecop_43_6gr_im0_cma_ena2, i_cond_i_idqualvecop_43_6gr_im0_cma_ena1, i_cond_i_idqualvecop_43_6gr_im0_cma_ena0 }),
        .clr({ 1'b0, 1'b0 }),
        .ay(i_cond_i_idqualvecop_43_6gr_im0_cma_a0),
        .ax(i_cond_i_idqualvecop_43_6gr_im0_cma_c0),
        .resulta(i_cond_i_idqualvecop_43_6gr_im0_cma_s0),
        .accumulate(),
        .loadconst(),
        .negate(),
        .sub(),
        .az(),
        .coefsela(),
        .bx(),
        .by(),
        .bz(),
        .coefselb(),
        .cx(),
        .cy(),
        .dx(),
        .dy(),
        .scanin(),
        .scanout(),
        .chainin(),
        .chainout(),
        .disable_scanin(),
        .disable_chainout(),
        .resultb(),
        .dfxlfsrena(),
        .dfxmisrena()
    );
    dspba_delay_ver #( .width(36), .depth(0), .reset_kind("NONE"), .phase(0), .modulus(1), .reset_high(1'b0) )
    i_cond_i_idqualvecop_43_6gr_im0_cma_delay0 ( .xin(i_cond_i_idqualvecop_43_6gr_im0_cma_s0), .xout(i_cond_i_idqualvecop_43_6gr_im0_cma_qq0), .clk(clock), .aclr(resetn), .ena(1'b1) );
    assign i_cond_i_idqualvecop_43_6gr_im0_cma_q = $unsigned(i_cond_i_idqualvecop_43_6gr_im0_cma_qq0[35:0]);

    // i_cond_i_idqualvecop_43_6gr_sums_join_0(BITJOIN,327)@5
    assign i_cond_i_idqualvecop_43_6gr_sums_join_0_q = {i_cond_i_idqualvecop_43_6gr_im8_cma_q, i_cond_i_idqualvecop_43_6gr_im0_cma_q};

    // i_cond_i_idqualvecop_43_6gr_sums_result_add_0_0_rhsMSBs_select_bit_select_merged(BITSELECT,421)@5
    assign i_cond_i_idqualvecop_43_6gr_sums_result_add_0_0_rhsMSBs_select_bit_select_merged_b = $signed(i_cond_i_idqualvecop_43_6gr_sums_join_0_q[65:18]);
    assign i_cond_i_idqualvecop_43_6gr_sums_result_add_0_0_rhsMSBs_select_bit_select_merged_c = $signed(i_cond_i_idqualvecop_43_6gr_sums_join_0_q[17:0]);

    // i_cond_i_idqualvecop_43_6gr_sums_result_add_0_0_split_join(BITJOIN,370)@5
    assign i_cond_i_idqualvecop_43_6gr_sums_result_add_0_0_split_join_q = {i_cond_i_idqualvecop_43_6gr_sums_result_add_0_0_MSBs_sums_q, i_cond_i_idqualvecop_43_6gr_sums_result_add_0_0_rhsMSBs_select_bit_select_merged_c};

    // bgTrunc_i_cond_i_idqualvecop_43_6gr_sel_x(BITSELECT,142)@5
    assign bgTrunc_i_cond_i_idqualvecop_43_6gr_sel_x_in = i_cond_i_idqualvecop_43_6gr_sums_result_add_0_0_split_join_q[63:0];
    assign bgTrunc_i_cond_i_idqualvecop_43_6gr_sel_x_b = bgTrunc_i_cond_i_idqualvecop_43_6gr_sel_x_in[31:0];

    // valid_fanout_reg5(REG,150)@0 + 1
    always_ff @ (posedge clock) begin
        valid_fanout_reg5_q <= in_i_valid;
    end

    // i_llvm_fpga_sync_buffer_i32_arg_b_sync_buffer8_idqualvecop_43_10(BLACKBOX,111)@0
    // in in_i_dependence@1
    // in in_valid_in@1
    // out out_buffer_out@1
    // out out_valid_out@1
    IDQualVecOp_i_llvm_fpga_sync_buffer_i32_00008_idqualvecop_73_0gr thei_llvm_fpga_sync_buffer_i32_arg_b_sync_buffer8_idqualvecop_43_10 (
        .in_buffer_in(in_arg_b),
        .in_i_dependence(GND_q),
        .in_stall_in(GND_q),
        .in_valid_in(valid_fanout_reg5_q),
        .out_buffer_out(i_llvm_fpga_sync_buffer_i32_arg_b_sync_buffer8_idqualvecop_43_10_out_buffer_out),
        .out_stall_out(),
        .out_valid_out(),
        .clock(clock),
        .resetn(resetn)
    );

    // i_cond_i_1_idqualvecop_43_11_bs2_bit_select_merged(BITSELECT,404)@1
    assign i_cond_i_1_idqualvecop_43_11_bs2_bit_select_merged_b = $signed(i_llvm_fpga_sync_buffer_i32_arg_b_sync_buffer8_idqualvecop_43_10_out_buffer_out[17:0]);
    assign i_cond_i_1_idqualvecop_43_11_bs2_bit_select_merged_c = $signed(i_llvm_fpga_sync_buffer_i32_arg_b_sync_buffer8_idqualvecop_43_10_out_buffer_out[31:18]);

    // c_i32_1_43_73(CONSTANT,37)
    assign c_i32_1_43_73_q = 32'b00000000000000000000000000000001;

    // c_i32_1_43_72(CONSTANT,36)
    assign c_i32_1_43_72_q = 32'b11111111111111111111111111111111;

    // c_i32_0_43_71_recast_x(CONSTANT,143)
    assign c_i32_0_43_71_recast_x_q = 32'b00000000000000000000000000000000;

    // valid_fanout_reg1(REG,146)@0 + 1
    always_ff @ (posedge clock) begin
        valid_fanout_reg1_q <= in_i_valid;
    end

    // i_llvm_fpga_sync_buffer_i32_arg_mode_sync_buffer_idqualvecop_43_1gr(BLACKBOX,114)@0
    // in in_i_dependence@1
    // in in_valid_in@1
    // out out_buffer_out@1
    // out out_valid_out@1
    IDQualVecOp_i_llvm_fpga_sync_buffer_i32_0000r_idqualvecop_47_0gr thei_llvm_fpga_sync_buffer_i32_arg_mode_sync_buffer_idqualvecop_43_1gr (
        .in_buffer_in(in_arg_mode),
        .in_i_dependence(GND_q),
        .in_stall_in(GND_q),
        .in_valid_in(valid_fanout_reg1_q),
        .out_buffer_out(i_llvm_fpga_sync_buffer_i32_arg_mode_sync_buffer_idqualvecop_43_1gr_out_buffer_out),
        .out_stall_out(),
        .out_valid_out(),
        .clock(clock),
        .resetn(resetn)
    );

    // i_cmp2_i_idqualvecop_43_2gr(LOGICAL,87)@1
    assign i_cmp2_i_idqualvecop_43_2gr_q = $unsigned(i_llvm_fpga_sync_buffer_i32_arg_mode_sync_buffer_idqualvecop_43_1gr_out_buffer_out == c_i32_0_43_71_recast_x_q ? 1'b1 : 1'b0);

    // i_add_i_pn_p_1_idqualvecop_43_7gr(MUX,59)@1
    assign i_add_i_pn_p_1_idqualvecop_43_7gr_s = i_cmp2_i_idqualvecop_43_2gr_q;
    always_comb 
    begin
        unique case (i_add_i_pn_p_1_idqualvecop_43_7gr_s)
            1'b0 : i_add_i_pn_p_1_idqualvecop_43_7gr_q = c_i32_1_43_72_q;
            1'b1 : i_add_i_pn_p_1_idqualvecop_43_7gr_q = c_i32_1_43_73_q;
            default : i_add_i_pn_p_1_idqualvecop_43_7gr_q = 32'b0;
        endcase
    end

    // i_add_i_pn_p_1_idqualvecop_43_7gr_vt_select_31(BITSELECT,62)@1
    assign i_add_i_pn_p_1_idqualvecop_43_7gr_vt_select_31_b = i_add_i_pn_p_1_idqualvecop_43_7gr_q[31:1];

    // i_add_i_pn_p_1_idqualvecop_43_7gr_vt_join(BITJOIN,61)@1
    assign i_add_i_pn_p_1_idqualvecop_43_7gr_vt_join_q = {i_add_i_pn_p_1_idqualvecop_43_7gr_vt_select_31_b, VCC_q};

    // valid_fanout_reg4(REG,149)@0 + 1
    always_ff @ (posedge clock) begin
        valid_fanout_reg4_q <= in_i_valid;
    end

    // i_llvm_fpga_sync_buffer_i32_arg_a_sync_buffer_idqualvecop_43_8gr(BLACKBOX,105)@0
    // in in_i_dependence@1
    // in in_valid_in@1
    // out out_buffer_out@1
    // out out_valid_out@1
    IDQualVecOp_i_llvm_fpga_sync_buffer_i32_0000r_idqualvecop_67_0gr thei_llvm_fpga_sync_buffer_i32_arg_a_sync_buffer_idqualvecop_43_8gr (
        .in_buffer_in(in_arg_a),
        .in_i_dependence(GND_q),
        .in_stall_in(GND_q),
        .in_valid_in(valid_fanout_reg4_q),
        .out_buffer_out(i_llvm_fpga_sync_buffer_i32_arg_a_sync_buffer_idqualvecop_43_8gr_out_buffer_out),
        .out_stall_out(),
        .out_valid_out(),
        .clock(clock),
        .resetn(resetn)
    );

    // i_add_i_pn_1_idqualvecop_43_9gr(ADD,52)@1
    assign i_add_i_pn_1_idqualvecop_43_9gr_a = {1'b0, i_llvm_fpga_sync_buffer_i32_arg_a_sync_buffer_idqualvecop_43_8gr_out_buffer_out};
    assign i_add_i_pn_1_idqualvecop_43_9gr_b = {1'b0, i_add_i_pn_p_1_idqualvecop_43_7gr_vt_join_q};
    assign i_add_i_pn_1_idqualvecop_43_9gr_o = $unsigned(i_add_i_pn_1_idqualvecop_43_9gr_a) + $unsigned(i_add_i_pn_1_idqualvecop_43_9gr_b);
    assign i_add_i_pn_1_idqualvecop_43_9gr_q = i_add_i_pn_1_idqualvecop_43_9gr_o[32:0];

    // bgTrunc_i_add_i_pn_1_idqualvecop_43_9gr_sel_x(BITSELECT,128)@1
    assign bgTrunc_i_add_i_pn_1_idqualvecop_43_9gr_sel_x_b = i_add_i_pn_1_idqualvecop_43_9gr_q[31:0];

    // i_cond_i_1_idqualvecop_43_11_bs1_bit_select_merged(BITSELECT,407)@1
    assign i_cond_i_1_idqualvecop_43_11_bs1_bit_select_merged_b = $signed(bgTrunc_i_add_i_pn_1_idqualvecop_43_9gr_sel_x_b[17:0]);
    assign i_cond_i_1_idqualvecop_43_11_bs1_bit_select_merged_c = $signed(bgTrunc_i_add_i_pn_1_idqualvecop_43_9gr_sel_x_b[31:18]);

    // i_cond_i_1_idqualvecop_43_11_ma3_cma(CHAINMULTADD,387)@1 + 4
    // in b@4
    assign i_cond_i_1_idqualvecop_43_11_ma3_cma_reset = ~ (resetn);
    assign i_cond_i_1_idqualvecop_43_11_ma3_cma_ena0 = 1'b1;
    assign i_cond_i_1_idqualvecop_43_11_ma3_cma_ena1 = i_cond_i_1_idqualvecop_43_11_ma3_cma_ena0;
    assign i_cond_i_1_idqualvecop_43_11_ma3_cma_ena2 = i_cond_i_1_idqualvecop_43_11_ma3_cma_ena0;

    assign i_cond_i_1_idqualvecop_43_11_ma3_cma_a0 = i_cond_i_1_idqualvecop_43_11_bs1_bit_select_merged_c;
    assign i_cond_i_1_idqualvecop_43_11_ma3_cma_c0 = i_cond_i_1_idqualvecop_43_11_bs2_bit_select_merged_b;
    assign i_cond_i_1_idqualvecop_43_11_ma3_cma_a1 = i_cond_i_1_idqualvecop_43_11_bs2_bit_select_merged_c;
    assign i_cond_i_1_idqualvecop_43_11_ma3_cma_c1 = i_cond_i_1_idqualvecop_43_11_bs1_bit_select_merged_b;
    tennm_mac #(
        .operation_mode("m18x18_sumof2"),
        .clear_type("none"),
        .use_chainadder("false"),
        .ay_scan_in_clken("0"),
        .ay_scan_in_width(14),
        .by_clken("0"),
        .by_width(14),
        .ax_clken("0"),
        .bx_clken("0"),
        .ax_width(18),
        .bx_width(18),
        .signed_may("false"),
        .signed_mby("false"),
        .signed_max("false"),
        .signed_mbx("false"),
        .input_pipeline_clken("2"),
        .second_pipeline_clken("2"),
        .output_clken("1"),
        .result_a_width(33)
    ) i_cond_i_1_idqualvecop_43_11_ma3_cma_DSP0 (
        .clk(clock),
        .ena({ i_cond_i_1_idqualvecop_43_11_ma3_cma_ena2, i_cond_i_1_idqualvecop_43_11_ma3_cma_ena1, i_cond_i_1_idqualvecop_43_11_ma3_cma_ena0 }),
        .clr({ 1'b0, 1'b0 }),
        .ay(i_cond_i_1_idqualvecop_43_11_ma3_cma_a1),
        .by(i_cond_i_1_idqualvecop_43_11_ma3_cma_a0),
        .ax(i_cond_i_1_idqualvecop_43_11_ma3_cma_c1),
        .bx(i_cond_i_1_idqualvecop_43_11_ma3_cma_c0),
        .resulta(i_cond_i_1_idqualvecop_43_11_ma3_cma_s0),
        .accumulate(),
        .loadconst(),
        .negate(),
        .sub(),
        .az(),
        .coefsela(),
        .bz(),
        .coefselb(),
        .cx(),
        .cy(),
        .dx(),
        .dy(),
        .scanin(),
        .scanout(),
        .chainin(),
        .chainout(),
        .disable_scanin(),
        .disable_chainout(),
        .resultb(),
        .dfxlfsrena(),
        .dfxmisrena()
    );
    dspba_delay_ver #( .width(33), .depth(0), .reset_kind("NONE"), .phase(0), .modulus(1), .reset_high(1'b0) )
    i_cond_i_1_idqualvecop_43_11_ma3_cma_delay0 ( .xin(i_cond_i_1_idqualvecop_43_11_ma3_cma_s0), .xout(i_cond_i_1_idqualvecop_43_11_ma3_cma_qq0), .clk(clock), .aclr(resetn), .ena(1'b1) );
    assign i_cond_i_1_idqualvecop_43_11_ma3_cma_q = $unsigned(i_cond_i_1_idqualvecop_43_11_ma3_cma_qq0[32:0]);

    // i_cond_i_1_idqualvecop_43_11_sums_align_1(BITSHIFT,209)@5
    assign i_cond_i_1_idqualvecop_43_11_sums_align_1_qint = { i_cond_i_1_idqualvecop_43_11_ma3_cma_q, 18'b000000000000000000 };
    assign i_cond_i_1_idqualvecop_43_11_sums_align_1_q = i_cond_i_1_idqualvecop_43_11_sums_align_1_qint[50:0];

    // i_cond_i_1_idqualvecop_43_11_sums_result_add_0_0_lhsMSBs_select(BITSELECT,333)@5
    assign i_cond_i_1_idqualvecop_43_11_sums_result_add_0_0_lhsMSBs_select_b = $signed(i_cond_i_1_idqualvecop_43_11_sums_align_1_q[50:18]);

    // i_cond_i_1_idqualvecop_43_11_sums_result_add_0_0_MSBs_sums(ADD,334)@5
    assign i_cond_i_1_idqualvecop_43_11_sums_result_add_0_0_MSBs_sums_a = {16'b0000000000000000, i_cond_i_1_idqualvecop_43_11_sums_result_add_0_0_lhsMSBs_select_b};
    assign i_cond_i_1_idqualvecop_43_11_sums_result_add_0_0_MSBs_sums_b = {1'b0, i_cond_i_1_idqualvecop_43_11_sums_result_add_0_0_rhsMSBs_select_bit_select_merged_b};
    assign i_cond_i_1_idqualvecop_43_11_sums_result_add_0_0_MSBs_sums_o = $unsigned(i_cond_i_1_idqualvecop_43_11_sums_result_add_0_0_MSBs_sums_a) + $unsigned(i_cond_i_1_idqualvecop_43_11_sums_result_add_0_0_MSBs_sums_b);
    assign i_cond_i_1_idqualvecop_43_11_sums_result_add_0_0_MSBs_sums_q = $signed(i_cond_i_1_idqualvecop_43_11_sums_result_add_0_0_MSBs_sums_o[48:0]);

    // i_cond_i_1_idqualvecop_43_11_bjB12(BITJOIN,207)@1
    assign i_cond_i_1_idqualvecop_43_11_bjB12_q = {GND_q, i_cond_i_1_idqualvecop_43_11_bs2_bit_select_merged_c};

    // i_cond_i_1_idqualvecop_43_11_bjA10(BITJOIN,205)@1
    assign i_cond_i_1_idqualvecop_43_11_bjA10_q = {GND_q, i_cond_i_1_idqualvecop_43_11_bs1_bit_select_merged_c};

    // i_cond_i_1_idqualvecop_43_11_im8_cma(CHAINMULTADD,372)@1 + 4
    // in b@4
    assign i_cond_i_1_idqualvecop_43_11_im8_cma_reset = ~ (resetn);
    assign i_cond_i_1_idqualvecop_43_11_im8_cma_ena0 = 1'b1;
    assign i_cond_i_1_idqualvecop_43_11_im8_cma_ena1 = i_cond_i_1_idqualvecop_43_11_im8_cma_ena0;
    assign i_cond_i_1_idqualvecop_43_11_im8_cma_ena2 = i_cond_i_1_idqualvecop_43_11_im8_cma_ena0;

    assign i_cond_i_1_idqualvecop_43_11_im8_cma_a0 = $unsigned(i_cond_i_1_idqualvecop_43_11_bjA10_q);
    assign i_cond_i_1_idqualvecop_43_11_im8_cma_c0 = $unsigned(i_cond_i_1_idqualvecop_43_11_bjB12_q);
    tennm_mac #(
        .operation_mode("m18x18_full"),
        .clear_type("none"),
        .ay_scan_in_clken("0"),
        .ay_scan_in_width(15),
        .ax_clken("0"),
        .ax_width(15),
        .signed_may("true"),
        .signed_max("true"),
        .input_pipeline_clken("2"),
        .second_pipeline_clken("2"),
        .output_clken("1"),
        .result_a_width(30)
    ) i_cond_i_1_idqualvecop_43_11_im8_cma_DSP0 (
        .clk(clock),
        .ena({ i_cond_i_1_idqualvecop_43_11_im8_cma_ena2, i_cond_i_1_idqualvecop_43_11_im8_cma_ena1, i_cond_i_1_idqualvecop_43_11_im8_cma_ena0 }),
        .clr({ 1'b0, 1'b0 }),
        .ay(i_cond_i_1_idqualvecop_43_11_im8_cma_a0),
        .ax(i_cond_i_1_idqualvecop_43_11_im8_cma_c0),
        .resulta(i_cond_i_1_idqualvecop_43_11_im8_cma_s0),
        .accumulate(),
        .loadconst(),
        .negate(),
        .sub(),
        .az(),
        .coefsela(),
        .bx(),
        .by(),
        .bz(),
        .coefselb(),
        .cx(),
        .cy(),
        .dx(),
        .dy(),
        .scanin(),
        .scanout(),
        .chainin(),
        .chainout(),
        .disable_scanin(),
        .disable_chainout(),
        .resultb(),
        .dfxlfsrena(),
        .dfxmisrena()
    );
    dspba_delay_ver #( .width(30), .depth(0), .reset_kind("NONE"), .phase(0), .modulus(1), .reset_high(1'b0) )
    i_cond_i_1_idqualvecop_43_11_im8_cma_delay0 ( .xin(i_cond_i_1_idqualvecop_43_11_im8_cma_s0), .xout(i_cond_i_1_idqualvecop_43_11_im8_cma_qq0), .clk(clock), .aclr(resetn), .ena(1'b1) );
    assign i_cond_i_1_idqualvecop_43_11_im8_cma_q = $unsigned(i_cond_i_1_idqualvecop_43_11_im8_cma_qq0[29:0]);

    // i_cond_i_1_idqualvecop_43_11_im0_cma(CHAINMULTADD,371)@1 + 4
    // in b@4
    assign i_cond_i_1_idqualvecop_43_11_im0_cma_reset = ~ (resetn);
    assign i_cond_i_1_idqualvecop_43_11_im0_cma_ena0 = 1'b1;
    assign i_cond_i_1_idqualvecop_43_11_im0_cma_ena1 = i_cond_i_1_idqualvecop_43_11_im0_cma_ena0;
    assign i_cond_i_1_idqualvecop_43_11_im0_cma_ena2 = i_cond_i_1_idqualvecop_43_11_im0_cma_ena0;

    assign i_cond_i_1_idqualvecop_43_11_im0_cma_a0 = i_cond_i_1_idqualvecop_43_11_bs1_bit_select_merged_b;
    assign i_cond_i_1_idqualvecop_43_11_im0_cma_c0 = i_cond_i_1_idqualvecop_43_11_bs2_bit_select_merged_b;
    tennm_mac #(
        .operation_mode("m18x18_full"),
        .clear_type("none"),
        .ay_scan_in_clken("0"),
        .ay_scan_in_width(18),
        .ax_clken("0"),
        .ax_width(18),
        .signed_may("false"),
        .signed_max("false"),
        .input_pipeline_clken("2"),
        .second_pipeline_clken("2"),
        .output_clken("1"),
        .result_a_width(36)
    ) i_cond_i_1_idqualvecop_43_11_im0_cma_DSP0 (
        .clk(clock),
        .ena({ i_cond_i_1_idqualvecop_43_11_im0_cma_ena2, i_cond_i_1_idqualvecop_43_11_im0_cma_ena1, i_cond_i_1_idqualvecop_43_11_im0_cma_ena0 }),
        .clr({ 1'b0, 1'b0 }),
        .ay(i_cond_i_1_idqualvecop_43_11_im0_cma_a0),
        .ax(i_cond_i_1_idqualvecop_43_11_im0_cma_c0),
        .resulta(i_cond_i_1_idqualvecop_43_11_im0_cma_s0),
        .accumulate(),
        .loadconst(),
        .negate(),
        .sub(),
        .az(),
        .coefsela(),
        .bx(),
        .by(),
        .bz(),
        .coefselb(),
        .cx(),
        .cy(),
        .dx(),
        .dy(),
        .scanin(),
        .scanout(),
        .chainin(),
        .chainout(),
        .disable_scanin(),
        .disable_chainout(),
        .resultb(),
        .dfxlfsrena(),
        .dfxmisrena()
    );
    dspba_delay_ver #( .width(36), .depth(0), .reset_kind("NONE"), .phase(0), .modulus(1), .reset_high(1'b0) )
    i_cond_i_1_idqualvecop_43_11_im0_cma_delay0 ( .xin(i_cond_i_1_idqualvecop_43_11_im0_cma_s0), .xout(i_cond_i_1_idqualvecop_43_11_im0_cma_qq0), .clk(clock), .aclr(resetn), .ena(1'b1) );
    assign i_cond_i_1_idqualvecop_43_11_im0_cma_q = $unsigned(i_cond_i_1_idqualvecop_43_11_im0_cma_qq0[35:0]);

    // i_cond_i_1_idqualvecop_43_11_sums_join_0(BITJOIN,208)@5
    assign i_cond_i_1_idqualvecop_43_11_sums_join_0_q = {i_cond_i_1_idqualvecop_43_11_im8_cma_q, i_cond_i_1_idqualvecop_43_11_im0_cma_q};

    // i_cond_i_1_idqualvecop_43_11_sums_result_add_0_0_rhsMSBs_select_bit_select_merged(BITSELECT,414)@5
    assign i_cond_i_1_idqualvecop_43_11_sums_result_add_0_0_rhsMSBs_select_bit_select_merged_b = $signed(i_cond_i_1_idqualvecop_43_11_sums_join_0_q[65:18]);
    assign i_cond_i_1_idqualvecop_43_11_sums_result_add_0_0_rhsMSBs_select_bit_select_merged_c = $signed(i_cond_i_1_idqualvecop_43_11_sums_join_0_q[17:0]);

    // i_cond_i_1_idqualvecop_43_11_sums_result_add_0_0_split_join(BITJOIN,335)@5
    assign i_cond_i_1_idqualvecop_43_11_sums_result_add_0_0_split_join_q = {i_cond_i_1_idqualvecop_43_11_sums_result_add_0_0_MSBs_sums_q, i_cond_i_1_idqualvecop_43_11_sums_result_add_0_0_rhsMSBs_select_bit_select_merged_c};

    // bgTrunc_i_cond_i_1_idqualvecop_43_11_sel_x(BITSELECT,135)@5
    assign bgTrunc_i_cond_i_1_idqualvecop_43_11_sel_x_in = i_cond_i_1_idqualvecop_43_11_sums_result_add_0_0_split_join_q[63:0];
    assign bgTrunc_i_cond_i_1_idqualvecop_43_11_sel_x_b = bgTrunc_i_cond_i_1_idqualvecop_43_11_sel_x_in[31:0];

    // i_reduction_idqualvecop_3_idqualvecop_43_45(LOGICAL,118)@5
    assign i_reduction_idqualvecop_3_idqualvecop_43_45_q = bgTrunc_i_cond_i_1_idqualvecop_43_11_sel_x_b ^ bgTrunc_i_cond_i_idqualvecop_43_6gr_sel_x_b;

    // valid_fanout_reg7(REG,152)@0 + 1
    always_ff @ (posedge clock) begin
        valid_fanout_reg7_q <= in_i_valid;
    end

    // i_llvm_fpga_sync_buffer_i32_arg_b_sync_buffer9_idqualvecop_43_15(BLACKBOX,112)@0
    // in in_i_dependence@1
    // in in_valid_in@1
    // out out_buffer_out@1
    // out out_valid_out@1
    IDQualVecOp_i_llvm_fpga_sync_buffer_i32_00009_idqualvecop_86_0gr thei_llvm_fpga_sync_buffer_i32_arg_b_sync_buffer9_idqualvecop_43_15 (
        .in_buffer_in(in_arg_b),
        .in_i_dependence(GND_q),
        .in_stall_in(GND_q),
        .in_valid_in(valid_fanout_reg7_q),
        .out_buffer_out(i_llvm_fpga_sync_buffer_i32_arg_b_sync_buffer9_idqualvecop_43_15_out_buffer_out),
        .out_stall_out(),
        .out_valid_out(),
        .clock(clock),
        .resetn(resetn)
    );

    // i_cond_i_2_idqualvecop_43_16_bs2_bit_select_merged(BITSELECT,405)@1
    assign i_cond_i_2_idqualvecop_43_16_bs2_bit_select_merged_b = $signed(i_llvm_fpga_sync_buffer_i32_arg_b_sync_buffer9_idqualvecop_43_15_out_buffer_out[17:0]);
    assign i_cond_i_2_idqualvecop_43_16_bs2_bit_select_merged_c = $signed(i_llvm_fpga_sync_buffer_i32_arg_b_sync_buffer9_idqualvecop_43_15_out_buffer_out[31:18]);

    // c_i32_2_43_75(CONSTANT,39)
    assign c_i32_2_43_75_q = 32'b00000000000000000000000000000010;

    // c_i32_2_43_74(CONSTANT,38)
    assign c_i32_2_43_74_q = 32'b11111111111111111111111111111110;

    // i_add_i_pn_p_2_idqualvecop_43_12(MUX,63)@1
    assign i_add_i_pn_p_2_idqualvecop_43_12_s = i_cmp2_i_idqualvecop_43_2gr_q;
    always_comb 
    begin
        unique case (i_add_i_pn_p_2_idqualvecop_43_12_s)
            1'b0 : i_add_i_pn_p_2_idqualvecop_43_12_q = c_i32_2_43_74_q;
            1'b1 : i_add_i_pn_p_2_idqualvecop_43_12_q = c_i32_2_43_75_q;
            default : i_add_i_pn_p_2_idqualvecop_43_12_q = 32'b0;
        endcase
    end

    // i_add_i_pn_p_2_idqualvecop_43_12_vt_select_31(BITSELECT,66)@1
    assign i_add_i_pn_p_2_idqualvecop_43_12_vt_select_31_b = i_add_i_pn_p_2_idqualvecop_43_12_q[31:2];

    // i_add_i_pn_p_2_idqualvecop_43_12_vt_const_1(CONSTANT,64)
    assign i_add_i_pn_p_2_idqualvecop_43_12_vt_const_1_q = 2'b10;

    // i_add_i_pn_p_2_idqualvecop_43_12_vt_join(BITJOIN,65)@1
    assign i_add_i_pn_p_2_idqualvecop_43_12_vt_join_q = {i_add_i_pn_p_2_idqualvecop_43_12_vt_select_31_b, i_add_i_pn_p_2_idqualvecop_43_12_vt_const_1_q};

    // i_add_i_pn_2_idqualvecop_43_14_lhsMSBs_select(BITSELECT,182)@1
    assign i_add_i_pn_2_idqualvecop_43_14_lhsMSBs_select_b = $signed(i_add_i_pn_p_2_idqualvecop_43_12_vt_join_q[31:1]);

    // i_add_i_pn_2_idqualvecop_43_14_MSBs_sums(ADD,183)@1
    assign i_add_i_pn_2_idqualvecop_43_14_MSBs_sums_a = {1'b0, i_add_i_pn_2_idqualvecop_43_14_lhsMSBs_select_b};
    assign i_add_i_pn_2_idqualvecop_43_14_MSBs_sums_b = {1'b0, i_add_i_pn_2_idqualvecop_43_14_rhsMSBs_select_bit_select_merged_b};
    assign i_add_i_pn_2_idqualvecop_43_14_MSBs_sums_o = $unsigned(i_add_i_pn_2_idqualvecop_43_14_MSBs_sums_a) + $unsigned(i_add_i_pn_2_idqualvecop_43_14_MSBs_sums_b);
    assign i_add_i_pn_2_idqualvecop_43_14_MSBs_sums_q = $signed(i_add_i_pn_2_idqualvecop_43_14_MSBs_sums_o[31:0]);

    // valid_fanout_reg6(REG,151)@0 + 1
    always_ff @ (posedge clock) begin
        valid_fanout_reg6_q <= in_i_valid;
    end

    // i_llvm_fpga_sync_buffer_i32_arg_a_sync_buffer1_idqualvecop_43_13(BLACKBOX,98)@0
    // in in_i_dependence@1
    // in in_valid_in@1
    // out out_buffer_out@1
    // out out_valid_out@1
    IDQualVecOp_i_llvm_fpga_sync_buffer_i32_00001_idqualvecop_80_0gr thei_llvm_fpga_sync_buffer_i32_arg_a_sync_buffer1_idqualvecop_43_13 (
        .in_buffer_in(in_arg_a),
        .in_i_dependence(GND_q),
        .in_stall_in(GND_q),
        .in_valid_in(valid_fanout_reg6_q),
        .out_buffer_out(i_llvm_fpga_sync_buffer_i32_arg_a_sync_buffer1_idqualvecop_43_13_out_buffer_out),
        .out_stall_out(),
        .out_valid_out(),
        .clock(clock),
        .resetn(resetn)
    );

    // i_add_i_pn_2_idqualvecop_43_14_rhsMSBs_select_bit_select_merged(BITSELECT,395)@1
    assign i_add_i_pn_2_idqualvecop_43_14_rhsMSBs_select_bit_select_merged_b = $signed(i_llvm_fpga_sync_buffer_i32_arg_a_sync_buffer1_idqualvecop_43_13_out_buffer_out[31:1]);
    assign i_add_i_pn_2_idqualvecop_43_14_rhsMSBs_select_bit_select_merged_c = $signed(i_llvm_fpga_sync_buffer_i32_arg_a_sync_buffer1_idqualvecop_43_13_out_buffer_out[0:0]);

    // i_add_i_pn_2_idqualvecop_43_14_split_join(BITJOIN,184)@1
    assign i_add_i_pn_2_idqualvecop_43_14_split_join_q = {i_add_i_pn_2_idqualvecop_43_14_MSBs_sums_q, i_add_i_pn_2_idqualvecop_43_14_rhsMSBs_select_bit_select_merged_c};

    // bgTrunc_i_add_i_pn_2_idqualvecop_43_14_sel_x(BITSELECT,129)@1
    assign bgTrunc_i_add_i_pn_2_idqualvecop_43_14_sel_x_b = i_add_i_pn_2_idqualvecop_43_14_split_join_q[31:0];

    // i_cond_i_2_idqualvecop_43_16_bs1_bit_select_merged(BITSELECT,408)@1
    assign i_cond_i_2_idqualvecop_43_16_bs1_bit_select_merged_b = $signed(bgTrunc_i_add_i_pn_2_idqualvecop_43_14_sel_x_b[17:0]);
    assign i_cond_i_2_idqualvecop_43_16_bs1_bit_select_merged_c = $signed(bgTrunc_i_add_i_pn_2_idqualvecop_43_14_sel_x_b[31:18]);

    // i_cond_i_2_idqualvecop_43_16_ma3_cma(CHAINMULTADD,388)@1 + 4
    // in b@4
    assign i_cond_i_2_idqualvecop_43_16_ma3_cma_reset = ~ (resetn);
    assign i_cond_i_2_idqualvecop_43_16_ma3_cma_ena0 = 1'b1;
    assign i_cond_i_2_idqualvecop_43_16_ma3_cma_ena1 = i_cond_i_2_idqualvecop_43_16_ma3_cma_ena0;
    assign i_cond_i_2_idqualvecop_43_16_ma3_cma_ena2 = i_cond_i_2_idqualvecop_43_16_ma3_cma_ena0;

    assign i_cond_i_2_idqualvecop_43_16_ma3_cma_a0 = i_cond_i_2_idqualvecop_43_16_bs1_bit_select_merged_c;
    assign i_cond_i_2_idqualvecop_43_16_ma3_cma_c0 = i_cond_i_2_idqualvecop_43_16_bs2_bit_select_merged_b;
    assign i_cond_i_2_idqualvecop_43_16_ma3_cma_a1 = i_cond_i_2_idqualvecop_43_16_bs2_bit_select_merged_c;
    assign i_cond_i_2_idqualvecop_43_16_ma3_cma_c1 = i_cond_i_2_idqualvecop_43_16_bs1_bit_select_merged_b;
    tennm_mac #(
        .operation_mode("m18x18_sumof2"),
        .clear_type("none"),
        .use_chainadder("false"),
        .ay_scan_in_clken("0"),
        .ay_scan_in_width(14),
        .by_clken("0"),
        .by_width(14),
        .ax_clken("0"),
        .bx_clken("0"),
        .ax_width(18),
        .bx_width(18),
        .signed_may("false"),
        .signed_mby("false"),
        .signed_max("false"),
        .signed_mbx("false"),
        .input_pipeline_clken("2"),
        .second_pipeline_clken("2"),
        .output_clken("1"),
        .result_a_width(33)
    ) i_cond_i_2_idqualvecop_43_16_ma3_cma_DSP0 (
        .clk(clock),
        .ena({ i_cond_i_2_idqualvecop_43_16_ma3_cma_ena2, i_cond_i_2_idqualvecop_43_16_ma3_cma_ena1, i_cond_i_2_idqualvecop_43_16_ma3_cma_ena0 }),
        .clr({ 1'b0, 1'b0 }),
        .ay(i_cond_i_2_idqualvecop_43_16_ma3_cma_a1),
        .by(i_cond_i_2_idqualvecop_43_16_ma3_cma_a0),
        .ax(i_cond_i_2_idqualvecop_43_16_ma3_cma_c1),
        .bx(i_cond_i_2_idqualvecop_43_16_ma3_cma_c0),
        .resulta(i_cond_i_2_idqualvecop_43_16_ma3_cma_s0),
        .accumulate(),
        .loadconst(),
        .negate(),
        .sub(),
        .az(),
        .coefsela(),
        .bz(),
        .coefselb(),
        .cx(),
        .cy(),
        .dx(),
        .dy(),
        .scanin(),
        .scanout(),
        .chainin(),
        .chainout(),
        .disable_scanin(),
        .disable_chainout(),
        .resultb(),
        .dfxlfsrena(),
        .dfxmisrena()
    );
    dspba_delay_ver #( .width(33), .depth(0), .reset_kind("NONE"), .phase(0), .modulus(1), .reset_high(1'b0) )
    i_cond_i_2_idqualvecop_43_16_ma3_cma_delay0 ( .xin(i_cond_i_2_idqualvecop_43_16_ma3_cma_s0), .xout(i_cond_i_2_idqualvecop_43_16_ma3_cma_qq0), .clk(clock), .aclr(resetn), .ena(1'b1) );
    assign i_cond_i_2_idqualvecop_43_16_ma3_cma_q = $unsigned(i_cond_i_2_idqualvecop_43_16_ma3_cma_qq0[32:0]);

    // i_cond_i_2_idqualvecop_43_16_sums_align_1(BITSHIFT,226)@5
    assign i_cond_i_2_idqualvecop_43_16_sums_align_1_qint = { i_cond_i_2_idqualvecop_43_16_ma3_cma_q, 18'b000000000000000000 };
    assign i_cond_i_2_idqualvecop_43_16_sums_align_1_q = i_cond_i_2_idqualvecop_43_16_sums_align_1_qint[50:0];

    // i_cond_i_2_idqualvecop_43_16_sums_result_add_0_0_lhsMSBs_select(BITSELECT,338)@5
    assign i_cond_i_2_idqualvecop_43_16_sums_result_add_0_0_lhsMSBs_select_b = $signed(i_cond_i_2_idqualvecop_43_16_sums_align_1_q[50:18]);

    // i_cond_i_2_idqualvecop_43_16_sums_result_add_0_0_MSBs_sums(ADD,339)@5
    assign i_cond_i_2_idqualvecop_43_16_sums_result_add_0_0_MSBs_sums_a = {16'b0000000000000000, i_cond_i_2_idqualvecop_43_16_sums_result_add_0_0_lhsMSBs_select_b};
    assign i_cond_i_2_idqualvecop_43_16_sums_result_add_0_0_MSBs_sums_b = {1'b0, i_cond_i_2_idqualvecop_43_16_sums_result_add_0_0_rhsMSBs_select_bit_select_merged_b};
    assign i_cond_i_2_idqualvecop_43_16_sums_result_add_0_0_MSBs_sums_o = $unsigned(i_cond_i_2_idqualvecop_43_16_sums_result_add_0_0_MSBs_sums_a) + $unsigned(i_cond_i_2_idqualvecop_43_16_sums_result_add_0_0_MSBs_sums_b);
    assign i_cond_i_2_idqualvecop_43_16_sums_result_add_0_0_MSBs_sums_q = $signed(i_cond_i_2_idqualvecop_43_16_sums_result_add_0_0_MSBs_sums_o[48:0]);

    // i_cond_i_2_idqualvecop_43_16_bjB12(BITJOIN,224)@1
    assign i_cond_i_2_idqualvecop_43_16_bjB12_q = {GND_q, i_cond_i_2_idqualvecop_43_16_bs2_bit_select_merged_c};

    // i_cond_i_2_idqualvecop_43_16_bjA10(BITJOIN,222)@1
    assign i_cond_i_2_idqualvecop_43_16_bjA10_q = {GND_q, i_cond_i_2_idqualvecop_43_16_bs1_bit_select_merged_c};

    // i_cond_i_2_idqualvecop_43_16_im8_cma(CHAINMULTADD,374)@1 + 4
    // in b@4
    assign i_cond_i_2_idqualvecop_43_16_im8_cma_reset = ~ (resetn);
    assign i_cond_i_2_idqualvecop_43_16_im8_cma_ena0 = 1'b1;
    assign i_cond_i_2_idqualvecop_43_16_im8_cma_ena1 = i_cond_i_2_idqualvecop_43_16_im8_cma_ena0;
    assign i_cond_i_2_idqualvecop_43_16_im8_cma_ena2 = i_cond_i_2_idqualvecop_43_16_im8_cma_ena0;

    assign i_cond_i_2_idqualvecop_43_16_im8_cma_a0 = $unsigned(i_cond_i_2_idqualvecop_43_16_bjA10_q);
    assign i_cond_i_2_idqualvecop_43_16_im8_cma_c0 = $unsigned(i_cond_i_2_idqualvecop_43_16_bjB12_q);
    tennm_mac #(
        .operation_mode("m18x18_full"),
        .clear_type("none"),
        .ay_scan_in_clken("0"),
        .ay_scan_in_width(15),
        .ax_clken("0"),
        .ax_width(15),
        .signed_may("true"),
        .signed_max("true"),
        .input_pipeline_clken("2"),
        .second_pipeline_clken("2"),
        .output_clken("1"),
        .result_a_width(30)
    ) i_cond_i_2_idqualvecop_43_16_im8_cma_DSP0 (
        .clk(clock),
        .ena({ i_cond_i_2_idqualvecop_43_16_im8_cma_ena2, i_cond_i_2_idqualvecop_43_16_im8_cma_ena1, i_cond_i_2_idqualvecop_43_16_im8_cma_ena0 }),
        .clr({ 1'b0, 1'b0 }),
        .ay(i_cond_i_2_idqualvecop_43_16_im8_cma_a0),
        .ax(i_cond_i_2_idqualvecop_43_16_im8_cma_c0),
        .resulta(i_cond_i_2_idqualvecop_43_16_im8_cma_s0),
        .accumulate(),
        .loadconst(),
        .negate(),
        .sub(),
        .az(),
        .coefsela(),
        .bx(),
        .by(),
        .bz(),
        .coefselb(),
        .cx(),
        .cy(),
        .dx(),
        .dy(),
        .scanin(),
        .scanout(),
        .chainin(),
        .chainout(),
        .disable_scanin(),
        .disable_chainout(),
        .resultb(),
        .dfxlfsrena(),
        .dfxmisrena()
    );
    dspba_delay_ver #( .width(30), .depth(0), .reset_kind("NONE"), .phase(0), .modulus(1), .reset_high(1'b0) )
    i_cond_i_2_idqualvecop_43_16_im8_cma_delay0 ( .xin(i_cond_i_2_idqualvecop_43_16_im8_cma_s0), .xout(i_cond_i_2_idqualvecop_43_16_im8_cma_qq0), .clk(clock), .aclr(resetn), .ena(1'b1) );
    assign i_cond_i_2_idqualvecop_43_16_im8_cma_q = $unsigned(i_cond_i_2_idqualvecop_43_16_im8_cma_qq0[29:0]);

    // i_cond_i_2_idqualvecop_43_16_im0_cma(CHAINMULTADD,373)@1 + 4
    // in b@4
    assign i_cond_i_2_idqualvecop_43_16_im0_cma_reset = ~ (resetn);
    assign i_cond_i_2_idqualvecop_43_16_im0_cma_ena0 = 1'b1;
    assign i_cond_i_2_idqualvecop_43_16_im0_cma_ena1 = i_cond_i_2_idqualvecop_43_16_im0_cma_ena0;
    assign i_cond_i_2_idqualvecop_43_16_im0_cma_ena2 = i_cond_i_2_idqualvecop_43_16_im0_cma_ena0;

    assign i_cond_i_2_idqualvecop_43_16_im0_cma_a0 = i_cond_i_2_idqualvecop_43_16_bs1_bit_select_merged_b;
    assign i_cond_i_2_idqualvecop_43_16_im0_cma_c0 = i_cond_i_2_idqualvecop_43_16_bs2_bit_select_merged_b;
    tennm_mac #(
        .operation_mode("m18x18_full"),
        .clear_type("none"),
        .ay_scan_in_clken("0"),
        .ay_scan_in_width(18),
        .ax_clken("0"),
        .ax_width(18),
        .signed_may("false"),
        .signed_max("false"),
        .input_pipeline_clken("2"),
        .second_pipeline_clken("2"),
        .output_clken("1"),
        .result_a_width(36)
    ) i_cond_i_2_idqualvecop_43_16_im0_cma_DSP0 (
        .clk(clock),
        .ena({ i_cond_i_2_idqualvecop_43_16_im0_cma_ena2, i_cond_i_2_idqualvecop_43_16_im0_cma_ena1, i_cond_i_2_idqualvecop_43_16_im0_cma_ena0 }),
        .clr({ 1'b0, 1'b0 }),
        .ay(i_cond_i_2_idqualvecop_43_16_im0_cma_a0),
        .ax(i_cond_i_2_idqualvecop_43_16_im0_cma_c0),
        .resulta(i_cond_i_2_idqualvecop_43_16_im0_cma_s0),
        .accumulate(),
        .loadconst(),
        .negate(),
        .sub(),
        .az(),
        .coefsela(),
        .bx(),
        .by(),
        .bz(),
        .coefselb(),
        .cx(),
        .cy(),
        .dx(),
        .dy(),
        .scanin(),
        .scanout(),
        .chainin(),
        .chainout(),
        .disable_scanin(),
        .disable_chainout(),
        .resultb(),
        .dfxlfsrena(),
        .dfxmisrena()
    );
    dspba_delay_ver #( .width(36), .depth(0), .reset_kind("NONE"), .phase(0), .modulus(1), .reset_high(1'b0) )
    i_cond_i_2_idqualvecop_43_16_im0_cma_delay0 ( .xin(i_cond_i_2_idqualvecop_43_16_im0_cma_s0), .xout(i_cond_i_2_idqualvecop_43_16_im0_cma_qq0), .clk(clock), .aclr(resetn), .ena(1'b1) );
    assign i_cond_i_2_idqualvecop_43_16_im0_cma_q = $unsigned(i_cond_i_2_idqualvecop_43_16_im0_cma_qq0[35:0]);

    // i_cond_i_2_idqualvecop_43_16_sums_join_0(BITJOIN,225)@5
    assign i_cond_i_2_idqualvecop_43_16_sums_join_0_q = {i_cond_i_2_idqualvecop_43_16_im8_cma_q, i_cond_i_2_idqualvecop_43_16_im0_cma_q};

    // i_cond_i_2_idqualvecop_43_16_sums_result_add_0_0_rhsMSBs_select_bit_select_merged(BITSELECT,415)@5
    assign i_cond_i_2_idqualvecop_43_16_sums_result_add_0_0_rhsMSBs_select_bit_select_merged_b = $signed(i_cond_i_2_idqualvecop_43_16_sums_join_0_q[65:18]);
    assign i_cond_i_2_idqualvecop_43_16_sums_result_add_0_0_rhsMSBs_select_bit_select_merged_c = $signed(i_cond_i_2_idqualvecop_43_16_sums_join_0_q[17:0]);

    // i_cond_i_2_idqualvecop_43_16_sums_result_add_0_0_split_join(BITJOIN,340)@5
    assign i_cond_i_2_idqualvecop_43_16_sums_result_add_0_0_split_join_q = {i_cond_i_2_idqualvecop_43_16_sums_result_add_0_0_MSBs_sums_q, i_cond_i_2_idqualvecop_43_16_sums_result_add_0_0_rhsMSBs_select_bit_select_merged_c};

    // bgTrunc_i_cond_i_2_idqualvecop_43_16_sel_x(BITSELECT,136)@5
    assign bgTrunc_i_cond_i_2_idqualvecop_43_16_sel_x_in = i_cond_i_2_idqualvecop_43_16_sums_result_add_0_0_split_join_q[63:0];
    assign bgTrunc_i_cond_i_2_idqualvecop_43_16_sel_x_b = bgTrunc_i_cond_i_2_idqualvecop_43_16_sel_x_in[31:0];

    // valid_fanout_reg9(REG,154)@0 + 1
    always_ff @ (posedge clock) begin
        valid_fanout_reg9_q <= in_i_valid;
    end

    // i_llvm_fpga_sync_buffer_i32_arg_b_sync_buffer10_idqualvecop_43_20(BLACKBOX,106)@0
    // in in_i_dependence@1
    // in in_valid_in@1
    // out out_buffer_out@1
    // out out_valid_out@1
    IDQualVecOp_i_llvm_fpga_sync_buffer_i32_00000_idqualvecop_99_0gr thei_llvm_fpga_sync_buffer_i32_arg_b_sync_buffer10_idqualvecop_43_20 (
        .in_buffer_in(in_arg_b),
        .in_i_dependence(GND_q),
        .in_stall_in(GND_q),
        .in_valid_in(valid_fanout_reg9_q),
        .out_buffer_out(i_llvm_fpga_sync_buffer_i32_arg_b_sync_buffer10_idqualvecop_43_20_out_buffer_out),
        .out_stall_out(),
        .out_valid_out(),
        .clock(clock),
        .resetn(resetn)
    );

    // i_cond_i_3_idqualvecop_43_21_bs2_bit_select_merged(BITSELECT,399)@1
    assign i_cond_i_3_idqualvecop_43_21_bs2_bit_select_merged_b = $signed(i_llvm_fpga_sync_buffer_i32_arg_b_sync_buffer10_idqualvecop_43_20_out_buffer_out[17:0]);
    assign i_cond_i_3_idqualvecop_43_21_bs2_bit_select_merged_c = $signed(i_llvm_fpga_sync_buffer_i32_arg_b_sync_buffer10_idqualvecop_43_20_out_buffer_out[31:18]);

    // c_i32_3_43_77(CONSTANT,41)
    assign c_i32_3_43_77_q = 32'b00000000000000000000000000000011;

    // c_i32_3_43_76(CONSTANT,40)
    assign c_i32_3_43_76_q = 32'b11111111111111111111111111111101;

    // i_add_i_pn_p_3_idqualvecop_43_17(MUX,67)@1
    assign i_add_i_pn_p_3_idqualvecop_43_17_s = i_cmp2_i_idqualvecop_43_2gr_q;
    always_comb 
    begin
        unique case (i_add_i_pn_p_3_idqualvecop_43_17_s)
            1'b0 : i_add_i_pn_p_3_idqualvecop_43_17_q = c_i32_3_43_76_q;
            1'b1 : i_add_i_pn_p_3_idqualvecop_43_17_q = c_i32_3_43_77_q;
            default : i_add_i_pn_p_3_idqualvecop_43_17_q = 32'b0;
        endcase
    end

    // i_add_i_pn_p_3_idqualvecop_43_17_vt_select_31(BITSELECT,70)@1
    assign i_add_i_pn_p_3_idqualvecop_43_17_vt_select_31_b = i_add_i_pn_p_3_idqualvecop_43_17_q[31:1];

    // i_add_i_pn_p_3_idqualvecop_43_17_vt_join(BITJOIN,69)@1
    assign i_add_i_pn_p_3_idqualvecop_43_17_vt_join_q = {i_add_i_pn_p_3_idqualvecop_43_17_vt_select_31_b, VCC_q};

    // valid_fanout_reg8(REG,153)@0 + 1
    always_ff @ (posedge clock) begin
        valid_fanout_reg8_q <= in_i_valid;
    end

    // i_llvm_fpga_sync_buffer_i32_arg_a_sync_buffer2_idqualvecop_43_18(BLACKBOX,99)@0
    // in in_i_dependence@1
    // in in_valid_in@1
    // out out_buffer_out@1
    // out out_valid_out@1
    IDQualVecOp_i_llvm_fpga_sync_buffer_i32_00002_idqualvecop_93_0gr thei_llvm_fpga_sync_buffer_i32_arg_a_sync_buffer2_idqualvecop_43_18 (
        .in_buffer_in(in_arg_a),
        .in_i_dependence(GND_q),
        .in_stall_in(GND_q),
        .in_valid_in(valid_fanout_reg8_q),
        .out_buffer_out(i_llvm_fpga_sync_buffer_i32_arg_a_sync_buffer2_idqualvecop_43_18_out_buffer_out),
        .out_stall_out(),
        .out_valid_out(),
        .clock(clock),
        .resetn(resetn)
    );

    // i_add_i_pn_3_idqualvecop_43_19(ADD,54)@1
    assign i_add_i_pn_3_idqualvecop_43_19_a = {1'b0, i_llvm_fpga_sync_buffer_i32_arg_a_sync_buffer2_idqualvecop_43_18_out_buffer_out};
    assign i_add_i_pn_3_idqualvecop_43_19_b = {1'b0, i_add_i_pn_p_3_idqualvecop_43_17_vt_join_q};
    assign i_add_i_pn_3_idqualvecop_43_19_o = $unsigned(i_add_i_pn_3_idqualvecop_43_19_a) + $unsigned(i_add_i_pn_3_idqualvecop_43_19_b);
    assign i_add_i_pn_3_idqualvecop_43_19_q = i_add_i_pn_3_idqualvecop_43_19_o[32:0];

    // bgTrunc_i_add_i_pn_3_idqualvecop_43_19_sel_x(BITSELECT,130)@1
    assign bgTrunc_i_add_i_pn_3_idqualvecop_43_19_sel_x_b = i_add_i_pn_3_idqualvecop_43_19_q[31:0];

    // i_cond_i_3_idqualvecop_43_21_bs1_bit_select_merged(BITSELECT,409)@1
    assign i_cond_i_3_idqualvecop_43_21_bs1_bit_select_merged_b = $signed(bgTrunc_i_add_i_pn_3_idqualvecop_43_19_sel_x_b[17:0]);
    assign i_cond_i_3_idqualvecop_43_21_bs1_bit_select_merged_c = $signed(bgTrunc_i_add_i_pn_3_idqualvecop_43_19_sel_x_b[31:18]);

    // i_cond_i_3_idqualvecop_43_21_ma3_cma(CHAINMULTADD,389)@1 + 4
    // in b@4
    assign i_cond_i_3_idqualvecop_43_21_ma3_cma_reset = ~ (resetn);
    assign i_cond_i_3_idqualvecop_43_21_ma3_cma_ena0 = 1'b1;
    assign i_cond_i_3_idqualvecop_43_21_ma3_cma_ena1 = i_cond_i_3_idqualvecop_43_21_ma3_cma_ena0;
    assign i_cond_i_3_idqualvecop_43_21_ma3_cma_ena2 = i_cond_i_3_idqualvecop_43_21_ma3_cma_ena0;

    assign i_cond_i_3_idqualvecop_43_21_ma3_cma_a0 = i_cond_i_3_idqualvecop_43_21_bs1_bit_select_merged_c;
    assign i_cond_i_3_idqualvecop_43_21_ma3_cma_c0 = i_cond_i_3_idqualvecop_43_21_bs2_bit_select_merged_b;
    assign i_cond_i_3_idqualvecop_43_21_ma3_cma_a1 = i_cond_i_3_idqualvecop_43_21_bs2_bit_select_merged_c;
    assign i_cond_i_3_idqualvecop_43_21_ma3_cma_c1 = i_cond_i_3_idqualvecop_43_21_bs1_bit_select_merged_b;
    tennm_mac #(
        .operation_mode("m18x18_sumof2"),
        .clear_type("none"),
        .use_chainadder("false"),
        .ay_scan_in_clken("0"),
        .ay_scan_in_width(14),
        .by_clken("0"),
        .by_width(14),
        .ax_clken("0"),
        .bx_clken("0"),
        .ax_width(18),
        .bx_width(18),
        .signed_may("false"),
        .signed_mby("false"),
        .signed_max("false"),
        .signed_mbx("false"),
        .input_pipeline_clken("2"),
        .second_pipeline_clken("2"),
        .output_clken("1"),
        .result_a_width(33)
    ) i_cond_i_3_idqualvecop_43_21_ma3_cma_DSP0 (
        .clk(clock),
        .ena({ i_cond_i_3_idqualvecop_43_21_ma3_cma_ena2, i_cond_i_3_idqualvecop_43_21_ma3_cma_ena1, i_cond_i_3_idqualvecop_43_21_ma3_cma_ena0 }),
        .clr({ 1'b0, 1'b0 }),
        .ay(i_cond_i_3_idqualvecop_43_21_ma3_cma_a1),
        .by(i_cond_i_3_idqualvecop_43_21_ma3_cma_a0),
        .ax(i_cond_i_3_idqualvecop_43_21_ma3_cma_c1),
        .bx(i_cond_i_3_idqualvecop_43_21_ma3_cma_c0),
        .resulta(i_cond_i_3_idqualvecop_43_21_ma3_cma_s0),
        .accumulate(),
        .loadconst(),
        .negate(),
        .sub(),
        .az(),
        .coefsela(),
        .bz(),
        .coefselb(),
        .cx(),
        .cy(),
        .dx(),
        .dy(),
        .scanin(),
        .scanout(),
        .chainin(),
        .chainout(),
        .disable_scanin(),
        .disable_chainout(),
        .resultb(),
        .dfxlfsrena(),
        .dfxmisrena()
    );
    dspba_delay_ver #( .width(33), .depth(0), .reset_kind("NONE"), .phase(0), .modulus(1), .reset_high(1'b0) )
    i_cond_i_3_idqualvecop_43_21_ma3_cma_delay0 ( .xin(i_cond_i_3_idqualvecop_43_21_ma3_cma_s0), .xout(i_cond_i_3_idqualvecop_43_21_ma3_cma_qq0), .clk(clock), .aclr(resetn), .ena(1'b1) );
    assign i_cond_i_3_idqualvecop_43_21_ma3_cma_q = $unsigned(i_cond_i_3_idqualvecop_43_21_ma3_cma_qq0[32:0]);

    // i_cond_i_3_idqualvecop_43_21_sums_align_1(BITSHIFT,243)@5
    assign i_cond_i_3_idqualvecop_43_21_sums_align_1_qint = { i_cond_i_3_idqualvecop_43_21_ma3_cma_q, 18'b000000000000000000 };
    assign i_cond_i_3_idqualvecop_43_21_sums_align_1_q = i_cond_i_3_idqualvecop_43_21_sums_align_1_qint[50:0];

    // i_cond_i_3_idqualvecop_43_21_sums_result_add_0_0_lhsMSBs_select(BITSELECT,343)@5
    assign i_cond_i_3_idqualvecop_43_21_sums_result_add_0_0_lhsMSBs_select_b = $signed(i_cond_i_3_idqualvecop_43_21_sums_align_1_q[50:18]);

    // i_cond_i_3_idqualvecop_43_21_sums_result_add_0_0_MSBs_sums(ADD,344)@5
    assign i_cond_i_3_idqualvecop_43_21_sums_result_add_0_0_MSBs_sums_a = {16'b0000000000000000, i_cond_i_3_idqualvecop_43_21_sums_result_add_0_0_lhsMSBs_select_b};
    assign i_cond_i_3_idqualvecop_43_21_sums_result_add_0_0_MSBs_sums_b = {1'b0, i_cond_i_3_idqualvecop_43_21_sums_result_add_0_0_rhsMSBs_select_bit_select_merged_b};
    assign i_cond_i_3_idqualvecop_43_21_sums_result_add_0_0_MSBs_sums_o = $unsigned(i_cond_i_3_idqualvecop_43_21_sums_result_add_0_0_MSBs_sums_a) + $unsigned(i_cond_i_3_idqualvecop_43_21_sums_result_add_0_0_MSBs_sums_b);
    assign i_cond_i_3_idqualvecop_43_21_sums_result_add_0_0_MSBs_sums_q = $signed(i_cond_i_3_idqualvecop_43_21_sums_result_add_0_0_MSBs_sums_o[48:0]);

    // i_cond_i_3_idqualvecop_43_21_bjB12(BITJOIN,241)@1
    assign i_cond_i_3_idqualvecop_43_21_bjB12_q = {GND_q, i_cond_i_3_idqualvecop_43_21_bs2_bit_select_merged_c};

    // i_cond_i_3_idqualvecop_43_21_bjA10(BITJOIN,239)@1
    assign i_cond_i_3_idqualvecop_43_21_bjA10_q = {GND_q, i_cond_i_3_idqualvecop_43_21_bs1_bit_select_merged_c};

    // i_cond_i_3_idqualvecop_43_21_im8_cma(CHAINMULTADD,376)@1 + 4
    // in b@4
    assign i_cond_i_3_idqualvecop_43_21_im8_cma_reset = ~ (resetn);
    assign i_cond_i_3_idqualvecop_43_21_im8_cma_ena0 = 1'b1;
    assign i_cond_i_3_idqualvecop_43_21_im8_cma_ena1 = i_cond_i_3_idqualvecop_43_21_im8_cma_ena0;
    assign i_cond_i_3_idqualvecop_43_21_im8_cma_ena2 = i_cond_i_3_idqualvecop_43_21_im8_cma_ena0;

    assign i_cond_i_3_idqualvecop_43_21_im8_cma_a0 = $unsigned(i_cond_i_3_idqualvecop_43_21_bjA10_q);
    assign i_cond_i_3_idqualvecop_43_21_im8_cma_c0 = $unsigned(i_cond_i_3_idqualvecop_43_21_bjB12_q);
    tennm_mac #(
        .operation_mode("m18x18_full"),
        .clear_type("none"),
        .ay_scan_in_clken("0"),
        .ay_scan_in_width(15),
        .ax_clken("0"),
        .ax_width(15),
        .signed_may("true"),
        .signed_max("true"),
        .input_pipeline_clken("2"),
        .second_pipeline_clken("2"),
        .output_clken("1"),
        .result_a_width(30)
    ) i_cond_i_3_idqualvecop_43_21_im8_cma_DSP0 (
        .clk(clock),
        .ena({ i_cond_i_3_idqualvecop_43_21_im8_cma_ena2, i_cond_i_3_idqualvecop_43_21_im8_cma_ena1, i_cond_i_3_idqualvecop_43_21_im8_cma_ena0 }),
        .clr({ 1'b0, 1'b0 }),
        .ay(i_cond_i_3_idqualvecop_43_21_im8_cma_a0),
        .ax(i_cond_i_3_idqualvecop_43_21_im8_cma_c0),
        .resulta(i_cond_i_3_idqualvecop_43_21_im8_cma_s0),
        .accumulate(),
        .loadconst(),
        .negate(),
        .sub(),
        .az(),
        .coefsela(),
        .bx(),
        .by(),
        .bz(),
        .coefselb(),
        .cx(),
        .cy(),
        .dx(),
        .dy(),
        .scanin(),
        .scanout(),
        .chainin(),
        .chainout(),
        .disable_scanin(),
        .disable_chainout(),
        .resultb(),
        .dfxlfsrena(),
        .dfxmisrena()
    );
    dspba_delay_ver #( .width(30), .depth(0), .reset_kind("NONE"), .phase(0), .modulus(1), .reset_high(1'b0) )
    i_cond_i_3_idqualvecop_43_21_im8_cma_delay0 ( .xin(i_cond_i_3_idqualvecop_43_21_im8_cma_s0), .xout(i_cond_i_3_idqualvecop_43_21_im8_cma_qq0), .clk(clock), .aclr(resetn), .ena(1'b1) );
    assign i_cond_i_3_idqualvecop_43_21_im8_cma_q = $unsigned(i_cond_i_3_idqualvecop_43_21_im8_cma_qq0[29:0]);

    // i_cond_i_3_idqualvecop_43_21_im0_cma(CHAINMULTADD,375)@1 + 4
    // in b@4
    assign i_cond_i_3_idqualvecop_43_21_im0_cma_reset = ~ (resetn);
    assign i_cond_i_3_idqualvecop_43_21_im0_cma_ena0 = 1'b1;
    assign i_cond_i_3_idqualvecop_43_21_im0_cma_ena1 = i_cond_i_3_idqualvecop_43_21_im0_cma_ena0;
    assign i_cond_i_3_idqualvecop_43_21_im0_cma_ena2 = i_cond_i_3_idqualvecop_43_21_im0_cma_ena0;

    assign i_cond_i_3_idqualvecop_43_21_im0_cma_a0 = i_cond_i_3_idqualvecop_43_21_bs1_bit_select_merged_b;
    assign i_cond_i_3_idqualvecop_43_21_im0_cma_c0 = i_cond_i_3_idqualvecop_43_21_bs2_bit_select_merged_b;
    tennm_mac #(
        .operation_mode("m18x18_full"),
        .clear_type("none"),
        .ay_scan_in_clken("0"),
        .ay_scan_in_width(18),
        .ax_clken("0"),
        .ax_width(18),
        .signed_may("false"),
        .signed_max("false"),
        .input_pipeline_clken("2"),
        .second_pipeline_clken("2"),
        .output_clken("1"),
        .result_a_width(36)
    ) i_cond_i_3_idqualvecop_43_21_im0_cma_DSP0 (
        .clk(clock),
        .ena({ i_cond_i_3_idqualvecop_43_21_im0_cma_ena2, i_cond_i_3_idqualvecop_43_21_im0_cma_ena1, i_cond_i_3_idqualvecop_43_21_im0_cma_ena0 }),
        .clr({ 1'b0, 1'b0 }),
        .ay(i_cond_i_3_idqualvecop_43_21_im0_cma_a0),
        .ax(i_cond_i_3_idqualvecop_43_21_im0_cma_c0),
        .resulta(i_cond_i_3_idqualvecop_43_21_im0_cma_s0),
        .accumulate(),
        .loadconst(),
        .negate(),
        .sub(),
        .az(),
        .coefsela(),
        .bx(),
        .by(),
        .bz(),
        .coefselb(),
        .cx(),
        .cy(),
        .dx(),
        .dy(),
        .scanin(),
        .scanout(),
        .chainin(),
        .chainout(),
        .disable_scanin(),
        .disable_chainout(),
        .resultb(),
        .dfxlfsrena(),
        .dfxmisrena()
    );
    dspba_delay_ver #( .width(36), .depth(0), .reset_kind("NONE"), .phase(0), .modulus(1), .reset_high(1'b0) )
    i_cond_i_3_idqualvecop_43_21_im0_cma_delay0 ( .xin(i_cond_i_3_idqualvecop_43_21_im0_cma_s0), .xout(i_cond_i_3_idqualvecop_43_21_im0_cma_qq0), .clk(clock), .aclr(resetn), .ena(1'b1) );
    assign i_cond_i_3_idqualvecop_43_21_im0_cma_q = $unsigned(i_cond_i_3_idqualvecop_43_21_im0_cma_qq0[35:0]);

    // i_cond_i_3_idqualvecop_43_21_sums_join_0(BITJOIN,242)@5
    assign i_cond_i_3_idqualvecop_43_21_sums_join_0_q = {i_cond_i_3_idqualvecop_43_21_im8_cma_q, i_cond_i_3_idqualvecop_43_21_im0_cma_q};

    // i_cond_i_3_idqualvecop_43_21_sums_result_add_0_0_rhsMSBs_select_bit_select_merged(BITSELECT,416)@5
    assign i_cond_i_3_idqualvecop_43_21_sums_result_add_0_0_rhsMSBs_select_bit_select_merged_b = $signed(i_cond_i_3_idqualvecop_43_21_sums_join_0_q[65:18]);
    assign i_cond_i_3_idqualvecop_43_21_sums_result_add_0_0_rhsMSBs_select_bit_select_merged_c = $signed(i_cond_i_3_idqualvecop_43_21_sums_join_0_q[17:0]);

    // i_cond_i_3_idqualvecop_43_21_sums_result_add_0_0_split_join(BITJOIN,345)@5
    assign i_cond_i_3_idqualvecop_43_21_sums_result_add_0_0_split_join_q = {i_cond_i_3_idqualvecop_43_21_sums_result_add_0_0_MSBs_sums_q, i_cond_i_3_idqualvecop_43_21_sums_result_add_0_0_rhsMSBs_select_bit_select_merged_c};

    // bgTrunc_i_cond_i_3_idqualvecop_43_21_sel_x(BITSELECT,137)@5
    assign bgTrunc_i_cond_i_3_idqualvecop_43_21_sel_x_in = i_cond_i_3_idqualvecop_43_21_sums_result_add_0_0_split_join_q[63:0];
    assign bgTrunc_i_cond_i_3_idqualvecop_43_21_sel_x_b = bgTrunc_i_cond_i_3_idqualvecop_43_21_sel_x_in[31:0];

    // i_reduction_idqualvecop_2_idqualvecop_43_44(LOGICAL,117)@5
    assign i_reduction_idqualvecop_2_idqualvecop_43_44_q = bgTrunc_i_cond_i_3_idqualvecop_43_21_sel_x_b ^ bgTrunc_i_cond_i_2_idqualvecop_43_16_sel_x_b;

    // i_reduction_idqualvecop_5_idqualvecop_43_47(LOGICAL,120)@5
    assign i_reduction_idqualvecop_5_idqualvecop_43_47_q = i_reduction_idqualvecop_2_idqualvecop_43_44_q ^ i_reduction_idqualvecop_3_idqualvecop_43_45_q;

    // valid_fanout_reg11(REG,156)@0 + 1
    always_ff @ (posedge clock) begin
        valid_fanout_reg11_q <= in_i_valid;
    end

    // i_llvm_fpga_sync_buffer_i32_arg_b_sync_buffer11_idqualvecop_43_25(BLACKBOX,107)@0
    // in in_i_dependence@1
    // in in_valid_in@1
    // out out_buffer_out@1
    // out out_valid_out@1
    IDQualVecOp_i_llvm_fpga_sync_buffer_i32_0000_idqualvecop_112_0gr thei_llvm_fpga_sync_buffer_i32_arg_b_sync_buffer11_idqualvecop_43_25 (
        .in_buffer_in(in_arg_b),
        .in_i_dependence(GND_q),
        .in_stall_in(GND_q),
        .in_valid_in(valid_fanout_reg11_q),
        .out_buffer_out(i_llvm_fpga_sync_buffer_i32_arg_b_sync_buffer11_idqualvecop_43_25_out_buffer_out),
        .out_stall_out(),
        .out_valid_out(),
        .clock(clock),
        .resetn(resetn)
    );

    // i_cond_i_4_idqualvecop_43_26_bs2_bit_select_merged(BITSELECT,400)@1
    assign i_cond_i_4_idqualvecop_43_26_bs2_bit_select_merged_b = $signed(i_llvm_fpga_sync_buffer_i32_arg_b_sync_buffer11_idqualvecop_43_25_out_buffer_out[17:0]);
    assign i_cond_i_4_idqualvecop_43_26_bs2_bit_select_merged_c = $signed(i_llvm_fpga_sync_buffer_i32_arg_b_sync_buffer11_idqualvecop_43_25_out_buffer_out[31:18]);

    // c_i32_4_43_79(CONSTANT,43)
    assign c_i32_4_43_79_q = 32'b00000000000000000000000000000100;

    // c_i32_4_43_78(CONSTANT,42)
    assign c_i32_4_43_78_q = 32'b11111111111111111111111111111100;

    // i_add_i_pn_p_4_idqualvecop_43_22(MUX,71)@1
    assign i_add_i_pn_p_4_idqualvecop_43_22_s = i_cmp2_i_idqualvecop_43_2gr_q;
    always_comb 
    begin
        unique case (i_add_i_pn_p_4_idqualvecop_43_22_s)
            1'b0 : i_add_i_pn_p_4_idqualvecop_43_22_q = c_i32_4_43_78_q;
            1'b1 : i_add_i_pn_p_4_idqualvecop_43_22_q = c_i32_4_43_79_q;
            default : i_add_i_pn_p_4_idqualvecop_43_22_q = 32'b0;
        endcase
    end

    // i_add_i_pn_p_4_idqualvecop_43_22_vt_select_31(BITSELECT,74)@1
    assign i_add_i_pn_p_4_idqualvecop_43_22_vt_select_31_b = i_add_i_pn_p_4_idqualvecop_43_22_q[31:3];

    // i_add_i_pn_p_4_idqualvecop_43_22_vt_const_2(CONSTANT,72)
    assign i_add_i_pn_p_4_idqualvecop_43_22_vt_const_2_q = 3'b100;

    // i_add_i_pn_p_4_idqualvecop_43_22_vt_join(BITJOIN,73)@1
    assign i_add_i_pn_p_4_idqualvecop_43_22_vt_join_q = {i_add_i_pn_p_4_idqualvecop_43_22_vt_select_31_b, i_add_i_pn_p_4_idqualvecop_43_22_vt_const_2_q};

    // i_add_i_pn_4_idqualvecop_43_24_lhsMSBs_select(BITSELECT,187)@1
    assign i_add_i_pn_4_idqualvecop_43_24_lhsMSBs_select_b = $signed(i_add_i_pn_p_4_idqualvecop_43_22_vt_join_q[31:2]);

    // i_add_i_pn_4_idqualvecop_43_24_MSBs_sums(ADD,188)@1
    assign i_add_i_pn_4_idqualvecop_43_24_MSBs_sums_a = {1'b0, i_add_i_pn_4_idqualvecop_43_24_lhsMSBs_select_b};
    assign i_add_i_pn_4_idqualvecop_43_24_MSBs_sums_b = {1'b0, i_add_i_pn_4_idqualvecop_43_24_rhsMSBs_select_bit_select_merged_b};
    assign i_add_i_pn_4_idqualvecop_43_24_MSBs_sums_o = $unsigned(i_add_i_pn_4_idqualvecop_43_24_MSBs_sums_a) + $unsigned(i_add_i_pn_4_idqualvecop_43_24_MSBs_sums_b);
    assign i_add_i_pn_4_idqualvecop_43_24_MSBs_sums_q = $signed(i_add_i_pn_4_idqualvecop_43_24_MSBs_sums_o[30:0]);

    // valid_fanout_reg10(REG,155)@0 + 1
    always_ff @ (posedge clock) begin
        valid_fanout_reg10_q <= in_i_valid;
    end

    // i_llvm_fpga_sync_buffer_i32_arg_a_sync_buffer3_idqualvecop_43_23(BLACKBOX,100)@0
    // in in_i_dependence@1
    // in in_valid_in@1
    // out out_buffer_out@1
    // out out_valid_out@1
    IDQualVecOp_i_llvm_fpga_sync_buffer_i32_0000_idqualvecop_106_0gr thei_llvm_fpga_sync_buffer_i32_arg_a_sync_buffer3_idqualvecop_43_23 (
        .in_buffer_in(in_arg_a),
        .in_i_dependence(GND_q),
        .in_stall_in(GND_q),
        .in_valid_in(valid_fanout_reg10_q),
        .out_buffer_out(i_llvm_fpga_sync_buffer_i32_arg_a_sync_buffer3_idqualvecop_43_23_out_buffer_out),
        .out_stall_out(),
        .out_valid_out(),
        .clock(clock),
        .resetn(resetn)
    );

    // i_add_i_pn_4_idqualvecop_43_24_rhsMSBs_select_bit_select_merged(BITSELECT,396)@1
    assign i_add_i_pn_4_idqualvecop_43_24_rhsMSBs_select_bit_select_merged_b = $signed(i_llvm_fpga_sync_buffer_i32_arg_a_sync_buffer3_idqualvecop_43_23_out_buffer_out[31:2]);
    assign i_add_i_pn_4_idqualvecop_43_24_rhsMSBs_select_bit_select_merged_c = $signed(i_llvm_fpga_sync_buffer_i32_arg_a_sync_buffer3_idqualvecop_43_23_out_buffer_out[1:0]);

    // i_add_i_pn_4_idqualvecop_43_24_split_join(BITJOIN,189)@1
    assign i_add_i_pn_4_idqualvecop_43_24_split_join_q = {i_add_i_pn_4_idqualvecop_43_24_MSBs_sums_q, i_add_i_pn_4_idqualvecop_43_24_rhsMSBs_select_bit_select_merged_c};

    // bgTrunc_i_add_i_pn_4_idqualvecop_43_24_sel_x(BITSELECT,131)@1
    assign bgTrunc_i_add_i_pn_4_idqualvecop_43_24_sel_x_b = i_add_i_pn_4_idqualvecop_43_24_split_join_q[31:0];

    // i_cond_i_4_idqualvecop_43_26_bs1_bit_select_merged(BITSELECT,410)@1
    assign i_cond_i_4_idqualvecop_43_26_bs1_bit_select_merged_b = $signed(bgTrunc_i_add_i_pn_4_idqualvecop_43_24_sel_x_b[17:0]);
    assign i_cond_i_4_idqualvecop_43_26_bs1_bit_select_merged_c = $signed(bgTrunc_i_add_i_pn_4_idqualvecop_43_24_sel_x_b[31:18]);

    // i_cond_i_4_idqualvecop_43_26_ma3_cma(CHAINMULTADD,390)@1 + 4
    // in b@4
    assign i_cond_i_4_idqualvecop_43_26_ma3_cma_reset = ~ (resetn);
    assign i_cond_i_4_idqualvecop_43_26_ma3_cma_ena0 = 1'b1;
    assign i_cond_i_4_idqualvecop_43_26_ma3_cma_ena1 = i_cond_i_4_idqualvecop_43_26_ma3_cma_ena0;
    assign i_cond_i_4_idqualvecop_43_26_ma3_cma_ena2 = i_cond_i_4_idqualvecop_43_26_ma3_cma_ena0;

    assign i_cond_i_4_idqualvecop_43_26_ma3_cma_a0 = i_cond_i_4_idqualvecop_43_26_bs1_bit_select_merged_c;
    assign i_cond_i_4_idqualvecop_43_26_ma3_cma_c0 = i_cond_i_4_idqualvecop_43_26_bs2_bit_select_merged_b;
    assign i_cond_i_4_idqualvecop_43_26_ma3_cma_a1 = i_cond_i_4_idqualvecop_43_26_bs2_bit_select_merged_c;
    assign i_cond_i_4_idqualvecop_43_26_ma3_cma_c1 = i_cond_i_4_idqualvecop_43_26_bs1_bit_select_merged_b;
    tennm_mac #(
        .operation_mode("m18x18_sumof2"),
        .clear_type("none"),
        .use_chainadder("false"),
        .ay_scan_in_clken("0"),
        .ay_scan_in_width(14),
        .by_clken("0"),
        .by_width(14),
        .ax_clken("0"),
        .bx_clken("0"),
        .ax_width(18),
        .bx_width(18),
        .signed_may("false"),
        .signed_mby("false"),
        .signed_max("false"),
        .signed_mbx("false"),
        .input_pipeline_clken("2"),
        .second_pipeline_clken("2"),
        .output_clken("1"),
        .result_a_width(33)
    ) i_cond_i_4_idqualvecop_43_26_ma3_cma_DSP0 (
        .clk(clock),
        .ena({ i_cond_i_4_idqualvecop_43_26_ma3_cma_ena2, i_cond_i_4_idqualvecop_43_26_ma3_cma_ena1, i_cond_i_4_idqualvecop_43_26_ma3_cma_ena0 }),
        .clr({ 1'b0, 1'b0 }),
        .ay(i_cond_i_4_idqualvecop_43_26_ma3_cma_a1),
        .by(i_cond_i_4_idqualvecop_43_26_ma3_cma_a0),
        .ax(i_cond_i_4_idqualvecop_43_26_ma3_cma_c1),
        .bx(i_cond_i_4_idqualvecop_43_26_ma3_cma_c0),
        .resulta(i_cond_i_4_idqualvecop_43_26_ma3_cma_s0),
        .accumulate(),
        .loadconst(),
        .negate(),
        .sub(),
        .az(),
        .coefsela(),
        .bz(),
        .coefselb(),
        .cx(),
        .cy(),
        .dx(),
        .dy(),
        .scanin(),
        .scanout(),
        .chainin(),
        .chainout(),
        .disable_scanin(),
        .disable_chainout(),
        .resultb(),
        .dfxlfsrena(),
        .dfxmisrena()
    );
    dspba_delay_ver #( .width(33), .depth(0), .reset_kind("NONE"), .phase(0), .modulus(1), .reset_high(1'b0) )
    i_cond_i_4_idqualvecop_43_26_ma3_cma_delay0 ( .xin(i_cond_i_4_idqualvecop_43_26_ma3_cma_s0), .xout(i_cond_i_4_idqualvecop_43_26_ma3_cma_qq0), .clk(clock), .aclr(resetn), .ena(1'b1) );
    assign i_cond_i_4_idqualvecop_43_26_ma3_cma_q = $unsigned(i_cond_i_4_idqualvecop_43_26_ma3_cma_qq0[32:0]);

    // i_cond_i_4_idqualvecop_43_26_sums_align_1(BITSHIFT,260)@5
    assign i_cond_i_4_idqualvecop_43_26_sums_align_1_qint = { i_cond_i_4_idqualvecop_43_26_ma3_cma_q, 18'b000000000000000000 };
    assign i_cond_i_4_idqualvecop_43_26_sums_align_1_q = i_cond_i_4_idqualvecop_43_26_sums_align_1_qint[50:0];

    // i_cond_i_4_idqualvecop_43_26_sums_result_add_0_0_lhsMSBs_select(BITSELECT,348)@5
    assign i_cond_i_4_idqualvecop_43_26_sums_result_add_0_0_lhsMSBs_select_b = $signed(i_cond_i_4_idqualvecop_43_26_sums_align_1_q[50:18]);

    // i_cond_i_4_idqualvecop_43_26_sums_result_add_0_0_MSBs_sums(ADD,349)@5
    assign i_cond_i_4_idqualvecop_43_26_sums_result_add_0_0_MSBs_sums_a = {16'b0000000000000000, i_cond_i_4_idqualvecop_43_26_sums_result_add_0_0_lhsMSBs_select_b};
    assign i_cond_i_4_idqualvecop_43_26_sums_result_add_0_0_MSBs_sums_b = {1'b0, i_cond_i_4_idqualvecop_43_26_sums_result_add_0_0_rhsMSBs_select_bit_select_merged_b};
    assign i_cond_i_4_idqualvecop_43_26_sums_result_add_0_0_MSBs_sums_o = $unsigned(i_cond_i_4_idqualvecop_43_26_sums_result_add_0_0_MSBs_sums_a) + $unsigned(i_cond_i_4_idqualvecop_43_26_sums_result_add_0_0_MSBs_sums_b);
    assign i_cond_i_4_idqualvecop_43_26_sums_result_add_0_0_MSBs_sums_q = $signed(i_cond_i_4_idqualvecop_43_26_sums_result_add_0_0_MSBs_sums_o[48:0]);

    // i_cond_i_4_idqualvecop_43_26_bjB12(BITJOIN,258)@1
    assign i_cond_i_4_idqualvecop_43_26_bjB12_q = {GND_q, i_cond_i_4_idqualvecop_43_26_bs2_bit_select_merged_c};

    // i_cond_i_4_idqualvecop_43_26_bjA10(BITJOIN,256)@1
    assign i_cond_i_4_idqualvecop_43_26_bjA10_q = {GND_q, i_cond_i_4_idqualvecop_43_26_bs1_bit_select_merged_c};

    // i_cond_i_4_idqualvecop_43_26_im8_cma(CHAINMULTADD,378)@1 + 4
    // in b@4
    assign i_cond_i_4_idqualvecop_43_26_im8_cma_reset = ~ (resetn);
    assign i_cond_i_4_idqualvecop_43_26_im8_cma_ena0 = 1'b1;
    assign i_cond_i_4_idqualvecop_43_26_im8_cma_ena1 = i_cond_i_4_idqualvecop_43_26_im8_cma_ena0;
    assign i_cond_i_4_idqualvecop_43_26_im8_cma_ena2 = i_cond_i_4_idqualvecop_43_26_im8_cma_ena0;

    assign i_cond_i_4_idqualvecop_43_26_im8_cma_a0 = $unsigned(i_cond_i_4_idqualvecop_43_26_bjA10_q);
    assign i_cond_i_4_idqualvecop_43_26_im8_cma_c0 = $unsigned(i_cond_i_4_idqualvecop_43_26_bjB12_q);
    tennm_mac #(
        .operation_mode("m18x18_full"),
        .clear_type("none"),
        .ay_scan_in_clken("0"),
        .ay_scan_in_width(15),
        .ax_clken("0"),
        .ax_width(15),
        .signed_may("true"),
        .signed_max("true"),
        .input_pipeline_clken("2"),
        .second_pipeline_clken("2"),
        .output_clken("1"),
        .result_a_width(30)
    ) i_cond_i_4_idqualvecop_43_26_im8_cma_DSP0 (
        .clk(clock),
        .ena({ i_cond_i_4_idqualvecop_43_26_im8_cma_ena2, i_cond_i_4_idqualvecop_43_26_im8_cma_ena1, i_cond_i_4_idqualvecop_43_26_im8_cma_ena0 }),
        .clr({ 1'b0, 1'b0 }),
        .ay(i_cond_i_4_idqualvecop_43_26_im8_cma_a0),
        .ax(i_cond_i_4_idqualvecop_43_26_im8_cma_c0),
        .resulta(i_cond_i_4_idqualvecop_43_26_im8_cma_s0),
        .accumulate(),
        .loadconst(),
        .negate(),
        .sub(),
        .az(),
        .coefsela(),
        .bx(),
        .by(),
        .bz(),
        .coefselb(),
        .cx(),
        .cy(),
        .dx(),
        .dy(),
        .scanin(),
        .scanout(),
        .chainin(),
        .chainout(),
        .disable_scanin(),
        .disable_chainout(),
        .resultb(),
        .dfxlfsrena(),
        .dfxmisrena()
    );
    dspba_delay_ver #( .width(30), .depth(0), .reset_kind("NONE"), .phase(0), .modulus(1), .reset_high(1'b0) )
    i_cond_i_4_idqualvecop_43_26_im8_cma_delay0 ( .xin(i_cond_i_4_idqualvecop_43_26_im8_cma_s0), .xout(i_cond_i_4_idqualvecop_43_26_im8_cma_qq0), .clk(clock), .aclr(resetn), .ena(1'b1) );
    assign i_cond_i_4_idqualvecop_43_26_im8_cma_q = $unsigned(i_cond_i_4_idqualvecop_43_26_im8_cma_qq0[29:0]);

    // i_cond_i_4_idqualvecop_43_26_im0_cma(CHAINMULTADD,377)@1 + 4
    // in b@4
    assign i_cond_i_4_idqualvecop_43_26_im0_cma_reset = ~ (resetn);
    assign i_cond_i_4_idqualvecop_43_26_im0_cma_ena0 = 1'b1;
    assign i_cond_i_4_idqualvecop_43_26_im0_cma_ena1 = i_cond_i_4_idqualvecop_43_26_im0_cma_ena0;
    assign i_cond_i_4_idqualvecop_43_26_im0_cma_ena2 = i_cond_i_4_idqualvecop_43_26_im0_cma_ena0;

    assign i_cond_i_4_idqualvecop_43_26_im0_cma_a0 = i_cond_i_4_idqualvecop_43_26_bs1_bit_select_merged_b;
    assign i_cond_i_4_idqualvecop_43_26_im0_cma_c0 = i_cond_i_4_idqualvecop_43_26_bs2_bit_select_merged_b;
    tennm_mac #(
        .operation_mode("m18x18_full"),
        .clear_type("none"),
        .ay_scan_in_clken("0"),
        .ay_scan_in_width(18),
        .ax_clken("0"),
        .ax_width(18),
        .signed_may("false"),
        .signed_max("false"),
        .input_pipeline_clken("2"),
        .second_pipeline_clken("2"),
        .output_clken("1"),
        .result_a_width(36)
    ) i_cond_i_4_idqualvecop_43_26_im0_cma_DSP0 (
        .clk(clock),
        .ena({ i_cond_i_4_idqualvecop_43_26_im0_cma_ena2, i_cond_i_4_idqualvecop_43_26_im0_cma_ena1, i_cond_i_4_idqualvecop_43_26_im0_cma_ena0 }),
        .clr({ 1'b0, 1'b0 }),
        .ay(i_cond_i_4_idqualvecop_43_26_im0_cma_a0),
        .ax(i_cond_i_4_idqualvecop_43_26_im0_cma_c0),
        .resulta(i_cond_i_4_idqualvecop_43_26_im0_cma_s0),
        .accumulate(),
        .loadconst(),
        .negate(),
        .sub(),
        .az(),
        .coefsela(),
        .bx(),
        .by(),
        .bz(),
        .coefselb(),
        .cx(),
        .cy(),
        .dx(),
        .dy(),
        .scanin(),
        .scanout(),
        .chainin(),
        .chainout(),
        .disable_scanin(),
        .disable_chainout(),
        .resultb(),
        .dfxlfsrena(),
        .dfxmisrena()
    );
    dspba_delay_ver #( .width(36), .depth(0), .reset_kind("NONE"), .phase(0), .modulus(1), .reset_high(1'b0) )
    i_cond_i_4_idqualvecop_43_26_im0_cma_delay0 ( .xin(i_cond_i_4_idqualvecop_43_26_im0_cma_s0), .xout(i_cond_i_4_idqualvecop_43_26_im0_cma_qq0), .clk(clock), .aclr(resetn), .ena(1'b1) );
    assign i_cond_i_4_idqualvecop_43_26_im0_cma_q = $unsigned(i_cond_i_4_idqualvecop_43_26_im0_cma_qq0[35:0]);

    // i_cond_i_4_idqualvecop_43_26_sums_join_0(BITJOIN,259)@5
    assign i_cond_i_4_idqualvecop_43_26_sums_join_0_q = {i_cond_i_4_idqualvecop_43_26_im8_cma_q, i_cond_i_4_idqualvecop_43_26_im0_cma_q};

    // i_cond_i_4_idqualvecop_43_26_sums_result_add_0_0_rhsMSBs_select_bit_select_merged(BITSELECT,417)@5
    assign i_cond_i_4_idqualvecop_43_26_sums_result_add_0_0_rhsMSBs_select_bit_select_merged_b = $signed(i_cond_i_4_idqualvecop_43_26_sums_join_0_q[65:18]);
    assign i_cond_i_4_idqualvecop_43_26_sums_result_add_0_0_rhsMSBs_select_bit_select_merged_c = $signed(i_cond_i_4_idqualvecop_43_26_sums_join_0_q[17:0]);

    // i_cond_i_4_idqualvecop_43_26_sums_result_add_0_0_split_join(BITJOIN,350)@5
    assign i_cond_i_4_idqualvecop_43_26_sums_result_add_0_0_split_join_q = {i_cond_i_4_idqualvecop_43_26_sums_result_add_0_0_MSBs_sums_q, i_cond_i_4_idqualvecop_43_26_sums_result_add_0_0_rhsMSBs_select_bit_select_merged_c};

    // bgTrunc_i_cond_i_4_idqualvecop_43_26_sel_x(BITSELECT,138)@5
    assign bgTrunc_i_cond_i_4_idqualvecop_43_26_sel_x_in = i_cond_i_4_idqualvecop_43_26_sums_result_add_0_0_split_join_q[63:0];
    assign bgTrunc_i_cond_i_4_idqualvecop_43_26_sel_x_b = bgTrunc_i_cond_i_4_idqualvecop_43_26_sel_x_in[31:0];

    // valid_fanout_reg13(REG,158)@0 + 1
    always_ff @ (posedge clock) begin
        valid_fanout_reg13_q <= in_i_valid;
    end

    // i_llvm_fpga_sync_buffer_i32_arg_b_sync_buffer12_idqualvecop_43_30(BLACKBOX,108)@0
    // in in_i_dependence@1
    // in in_valid_in@1
    // out out_buffer_out@1
    // out out_valid_out@1
    IDQualVecOp_i_llvm_fpga_sync_buffer_i32_0000_idqualvecop_125_0gr thei_llvm_fpga_sync_buffer_i32_arg_b_sync_buffer12_idqualvecop_43_30 (
        .in_buffer_in(in_arg_b),
        .in_i_dependence(GND_q),
        .in_stall_in(GND_q),
        .in_valid_in(valid_fanout_reg13_q),
        .out_buffer_out(i_llvm_fpga_sync_buffer_i32_arg_b_sync_buffer12_idqualvecop_43_30_out_buffer_out),
        .out_stall_out(),
        .out_valid_out(),
        .clock(clock),
        .resetn(resetn)
    );

    // i_cond_i_5_idqualvecop_43_31_bs2_bit_select_merged(BITSELECT,401)@1
    assign i_cond_i_5_idqualvecop_43_31_bs2_bit_select_merged_b = $signed(i_llvm_fpga_sync_buffer_i32_arg_b_sync_buffer12_idqualvecop_43_30_out_buffer_out[17:0]);
    assign i_cond_i_5_idqualvecop_43_31_bs2_bit_select_merged_c = $signed(i_llvm_fpga_sync_buffer_i32_arg_b_sync_buffer12_idqualvecop_43_30_out_buffer_out[31:18]);

    // c_i32_5_43_81(CONSTANT,45)
    assign c_i32_5_43_81_q = 32'b00000000000000000000000000000101;

    // c_i32_5_43_80(CONSTANT,44)
    assign c_i32_5_43_80_q = 32'b11111111111111111111111111111011;

    // i_add_i_pn_p_5_idqualvecop_43_27(MUX,75)@1
    assign i_add_i_pn_p_5_idqualvecop_43_27_s = i_cmp2_i_idqualvecop_43_2gr_q;
    always_comb 
    begin
        unique case (i_add_i_pn_p_5_idqualvecop_43_27_s)
            1'b0 : i_add_i_pn_p_5_idqualvecop_43_27_q = c_i32_5_43_80_q;
            1'b1 : i_add_i_pn_p_5_idqualvecop_43_27_q = c_i32_5_43_81_q;
            default : i_add_i_pn_p_5_idqualvecop_43_27_q = 32'b0;
        endcase
    end

    // i_add_i_pn_p_5_idqualvecop_43_27_vt_select_31(BITSELECT,78)@1
    assign i_add_i_pn_p_5_idqualvecop_43_27_vt_select_31_b = i_add_i_pn_p_5_idqualvecop_43_27_q[31:1];

    // i_add_i_pn_p_5_idqualvecop_43_27_vt_join(BITJOIN,77)@1
    assign i_add_i_pn_p_5_idqualvecop_43_27_vt_join_q = {i_add_i_pn_p_5_idqualvecop_43_27_vt_select_31_b, VCC_q};

    // valid_fanout_reg12(REG,157)@0 + 1
    always_ff @ (posedge clock) begin
        valid_fanout_reg12_q <= in_i_valid;
    end

    // i_llvm_fpga_sync_buffer_i32_arg_a_sync_buffer4_idqualvecop_43_28(BLACKBOX,101)@0
    // in in_i_dependence@1
    // in in_valid_in@1
    // out out_buffer_out@1
    // out out_valid_out@1
    IDQualVecOp_i_llvm_fpga_sync_buffer_i32_0000_idqualvecop_119_0gr thei_llvm_fpga_sync_buffer_i32_arg_a_sync_buffer4_idqualvecop_43_28 (
        .in_buffer_in(in_arg_a),
        .in_i_dependence(GND_q),
        .in_stall_in(GND_q),
        .in_valid_in(valid_fanout_reg12_q),
        .out_buffer_out(i_llvm_fpga_sync_buffer_i32_arg_a_sync_buffer4_idqualvecop_43_28_out_buffer_out),
        .out_stall_out(),
        .out_valid_out(),
        .clock(clock),
        .resetn(resetn)
    );

    // i_add_i_pn_5_idqualvecop_43_29(ADD,56)@1
    assign i_add_i_pn_5_idqualvecop_43_29_a = {1'b0, i_llvm_fpga_sync_buffer_i32_arg_a_sync_buffer4_idqualvecop_43_28_out_buffer_out};
    assign i_add_i_pn_5_idqualvecop_43_29_b = {1'b0, i_add_i_pn_p_5_idqualvecop_43_27_vt_join_q};
    assign i_add_i_pn_5_idqualvecop_43_29_o = $unsigned(i_add_i_pn_5_idqualvecop_43_29_a) + $unsigned(i_add_i_pn_5_idqualvecop_43_29_b);
    assign i_add_i_pn_5_idqualvecop_43_29_q = i_add_i_pn_5_idqualvecop_43_29_o[32:0];

    // bgTrunc_i_add_i_pn_5_idqualvecop_43_29_sel_x(BITSELECT,132)@1
    assign bgTrunc_i_add_i_pn_5_idqualvecop_43_29_sel_x_b = i_add_i_pn_5_idqualvecop_43_29_q[31:0];

    // i_cond_i_5_idqualvecop_43_31_bs1_bit_select_merged(BITSELECT,411)@1
    assign i_cond_i_5_idqualvecop_43_31_bs1_bit_select_merged_b = $signed(bgTrunc_i_add_i_pn_5_idqualvecop_43_29_sel_x_b[17:0]);
    assign i_cond_i_5_idqualvecop_43_31_bs1_bit_select_merged_c = $signed(bgTrunc_i_add_i_pn_5_idqualvecop_43_29_sel_x_b[31:18]);

    // i_cond_i_5_idqualvecop_43_31_ma3_cma(CHAINMULTADD,391)@1 + 4
    // in b@4
    assign i_cond_i_5_idqualvecop_43_31_ma3_cma_reset = ~ (resetn);
    assign i_cond_i_5_idqualvecop_43_31_ma3_cma_ena0 = 1'b1;
    assign i_cond_i_5_idqualvecop_43_31_ma3_cma_ena1 = i_cond_i_5_idqualvecop_43_31_ma3_cma_ena0;
    assign i_cond_i_5_idqualvecop_43_31_ma3_cma_ena2 = i_cond_i_5_idqualvecop_43_31_ma3_cma_ena0;

    assign i_cond_i_5_idqualvecop_43_31_ma3_cma_a0 = i_cond_i_5_idqualvecop_43_31_bs1_bit_select_merged_c;
    assign i_cond_i_5_idqualvecop_43_31_ma3_cma_c0 = i_cond_i_5_idqualvecop_43_31_bs2_bit_select_merged_b;
    assign i_cond_i_5_idqualvecop_43_31_ma3_cma_a1 = i_cond_i_5_idqualvecop_43_31_bs2_bit_select_merged_c;
    assign i_cond_i_5_idqualvecop_43_31_ma3_cma_c1 = i_cond_i_5_idqualvecop_43_31_bs1_bit_select_merged_b;
    tennm_mac #(
        .operation_mode("m18x18_sumof2"),
        .clear_type("none"),
        .use_chainadder("false"),
        .ay_scan_in_clken("0"),
        .ay_scan_in_width(14),
        .by_clken("0"),
        .by_width(14),
        .ax_clken("0"),
        .bx_clken("0"),
        .ax_width(18),
        .bx_width(18),
        .signed_may("false"),
        .signed_mby("false"),
        .signed_max("false"),
        .signed_mbx("false"),
        .input_pipeline_clken("2"),
        .second_pipeline_clken("2"),
        .output_clken("1"),
        .result_a_width(33)
    ) i_cond_i_5_idqualvecop_43_31_ma3_cma_DSP0 (
        .clk(clock),
        .ena({ i_cond_i_5_idqualvecop_43_31_ma3_cma_ena2, i_cond_i_5_idqualvecop_43_31_ma3_cma_ena1, i_cond_i_5_idqualvecop_43_31_ma3_cma_ena0 }),
        .clr({ 1'b0, 1'b0 }),
        .ay(i_cond_i_5_idqualvecop_43_31_ma3_cma_a1),
        .by(i_cond_i_5_idqualvecop_43_31_ma3_cma_a0),
        .ax(i_cond_i_5_idqualvecop_43_31_ma3_cma_c1),
        .bx(i_cond_i_5_idqualvecop_43_31_ma3_cma_c0),
        .resulta(i_cond_i_5_idqualvecop_43_31_ma3_cma_s0),
        .accumulate(),
        .loadconst(),
        .negate(),
        .sub(),
        .az(),
        .coefsela(),
        .bz(),
        .coefselb(),
        .cx(),
        .cy(),
        .dx(),
        .dy(),
        .scanin(),
        .scanout(),
        .chainin(),
        .chainout(),
        .disable_scanin(),
        .disable_chainout(),
        .resultb(),
        .dfxlfsrena(),
        .dfxmisrena()
    );
    dspba_delay_ver #( .width(33), .depth(0), .reset_kind("NONE"), .phase(0), .modulus(1), .reset_high(1'b0) )
    i_cond_i_5_idqualvecop_43_31_ma3_cma_delay0 ( .xin(i_cond_i_5_idqualvecop_43_31_ma3_cma_s0), .xout(i_cond_i_5_idqualvecop_43_31_ma3_cma_qq0), .clk(clock), .aclr(resetn), .ena(1'b1) );
    assign i_cond_i_5_idqualvecop_43_31_ma3_cma_q = $unsigned(i_cond_i_5_idqualvecop_43_31_ma3_cma_qq0[32:0]);

    // i_cond_i_5_idqualvecop_43_31_sums_align_1(BITSHIFT,277)@5
    assign i_cond_i_5_idqualvecop_43_31_sums_align_1_qint = { i_cond_i_5_idqualvecop_43_31_ma3_cma_q, 18'b000000000000000000 };
    assign i_cond_i_5_idqualvecop_43_31_sums_align_1_q = i_cond_i_5_idqualvecop_43_31_sums_align_1_qint[50:0];

    // i_cond_i_5_idqualvecop_43_31_sums_result_add_0_0_lhsMSBs_select(BITSELECT,353)@5
    assign i_cond_i_5_idqualvecop_43_31_sums_result_add_0_0_lhsMSBs_select_b = $signed(i_cond_i_5_idqualvecop_43_31_sums_align_1_q[50:18]);

    // i_cond_i_5_idqualvecop_43_31_sums_result_add_0_0_MSBs_sums(ADD,354)@5
    assign i_cond_i_5_idqualvecop_43_31_sums_result_add_0_0_MSBs_sums_a = {16'b0000000000000000, i_cond_i_5_idqualvecop_43_31_sums_result_add_0_0_lhsMSBs_select_b};
    assign i_cond_i_5_idqualvecop_43_31_sums_result_add_0_0_MSBs_sums_b = {1'b0, i_cond_i_5_idqualvecop_43_31_sums_result_add_0_0_rhsMSBs_select_bit_select_merged_b};
    assign i_cond_i_5_idqualvecop_43_31_sums_result_add_0_0_MSBs_sums_o = $unsigned(i_cond_i_5_idqualvecop_43_31_sums_result_add_0_0_MSBs_sums_a) + $unsigned(i_cond_i_5_idqualvecop_43_31_sums_result_add_0_0_MSBs_sums_b);
    assign i_cond_i_5_idqualvecop_43_31_sums_result_add_0_0_MSBs_sums_q = $signed(i_cond_i_5_idqualvecop_43_31_sums_result_add_0_0_MSBs_sums_o[48:0]);

    // i_cond_i_5_idqualvecop_43_31_bjB12(BITJOIN,275)@1
    assign i_cond_i_5_idqualvecop_43_31_bjB12_q = {GND_q, i_cond_i_5_idqualvecop_43_31_bs2_bit_select_merged_c};

    // i_cond_i_5_idqualvecop_43_31_bjA10(BITJOIN,273)@1
    assign i_cond_i_5_idqualvecop_43_31_bjA10_q = {GND_q, i_cond_i_5_idqualvecop_43_31_bs1_bit_select_merged_c};

    // i_cond_i_5_idqualvecop_43_31_im8_cma(CHAINMULTADD,380)@1 + 4
    // in b@4
    assign i_cond_i_5_idqualvecop_43_31_im8_cma_reset = ~ (resetn);
    assign i_cond_i_5_idqualvecop_43_31_im8_cma_ena0 = 1'b1;
    assign i_cond_i_5_idqualvecop_43_31_im8_cma_ena1 = i_cond_i_5_idqualvecop_43_31_im8_cma_ena0;
    assign i_cond_i_5_idqualvecop_43_31_im8_cma_ena2 = i_cond_i_5_idqualvecop_43_31_im8_cma_ena0;

    assign i_cond_i_5_idqualvecop_43_31_im8_cma_a0 = $unsigned(i_cond_i_5_idqualvecop_43_31_bjA10_q);
    assign i_cond_i_5_idqualvecop_43_31_im8_cma_c0 = $unsigned(i_cond_i_5_idqualvecop_43_31_bjB12_q);
    tennm_mac #(
        .operation_mode("m18x18_full"),
        .clear_type("none"),
        .ay_scan_in_clken("0"),
        .ay_scan_in_width(15),
        .ax_clken("0"),
        .ax_width(15),
        .signed_may("true"),
        .signed_max("true"),
        .input_pipeline_clken("2"),
        .second_pipeline_clken("2"),
        .output_clken("1"),
        .result_a_width(30)
    ) i_cond_i_5_idqualvecop_43_31_im8_cma_DSP0 (
        .clk(clock),
        .ena({ i_cond_i_5_idqualvecop_43_31_im8_cma_ena2, i_cond_i_5_idqualvecop_43_31_im8_cma_ena1, i_cond_i_5_idqualvecop_43_31_im8_cma_ena0 }),
        .clr({ 1'b0, 1'b0 }),
        .ay(i_cond_i_5_idqualvecop_43_31_im8_cma_a0),
        .ax(i_cond_i_5_idqualvecop_43_31_im8_cma_c0),
        .resulta(i_cond_i_5_idqualvecop_43_31_im8_cma_s0),
        .accumulate(),
        .loadconst(),
        .negate(),
        .sub(),
        .az(),
        .coefsela(),
        .bx(),
        .by(),
        .bz(),
        .coefselb(),
        .cx(),
        .cy(),
        .dx(),
        .dy(),
        .scanin(),
        .scanout(),
        .chainin(),
        .chainout(),
        .disable_scanin(),
        .disable_chainout(),
        .resultb(),
        .dfxlfsrena(),
        .dfxmisrena()
    );
    dspba_delay_ver #( .width(30), .depth(0), .reset_kind("NONE"), .phase(0), .modulus(1), .reset_high(1'b0) )
    i_cond_i_5_idqualvecop_43_31_im8_cma_delay0 ( .xin(i_cond_i_5_idqualvecop_43_31_im8_cma_s0), .xout(i_cond_i_5_idqualvecop_43_31_im8_cma_qq0), .clk(clock), .aclr(resetn), .ena(1'b1) );
    assign i_cond_i_5_idqualvecop_43_31_im8_cma_q = $unsigned(i_cond_i_5_idqualvecop_43_31_im8_cma_qq0[29:0]);

    // i_cond_i_5_idqualvecop_43_31_im0_cma(CHAINMULTADD,379)@1 + 4
    // in b@4
    assign i_cond_i_5_idqualvecop_43_31_im0_cma_reset = ~ (resetn);
    assign i_cond_i_5_idqualvecop_43_31_im0_cma_ena0 = 1'b1;
    assign i_cond_i_5_idqualvecop_43_31_im0_cma_ena1 = i_cond_i_5_idqualvecop_43_31_im0_cma_ena0;
    assign i_cond_i_5_idqualvecop_43_31_im0_cma_ena2 = i_cond_i_5_idqualvecop_43_31_im0_cma_ena0;

    assign i_cond_i_5_idqualvecop_43_31_im0_cma_a0 = i_cond_i_5_idqualvecop_43_31_bs1_bit_select_merged_b;
    assign i_cond_i_5_idqualvecop_43_31_im0_cma_c0 = i_cond_i_5_idqualvecop_43_31_bs2_bit_select_merged_b;
    tennm_mac #(
        .operation_mode("m18x18_full"),
        .clear_type("none"),
        .ay_scan_in_clken("0"),
        .ay_scan_in_width(18),
        .ax_clken("0"),
        .ax_width(18),
        .signed_may("false"),
        .signed_max("false"),
        .input_pipeline_clken("2"),
        .second_pipeline_clken("2"),
        .output_clken("1"),
        .result_a_width(36)
    ) i_cond_i_5_idqualvecop_43_31_im0_cma_DSP0 (
        .clk(clock),
        .ena({ i_cond_i_5_idqualvecop_43_31_im0_cma_ena2, i_cond_i_5_idqualvecop_43_31_im0_cma_ena1, i_cond_i_5_idqualvecop_43_31_im0_cma_ena0 }),
        .clr({ 1'b0, 1'b0 }),
        .ay(i_cond_i_5_idqualvecop_43_31_im0_cma_a0),
        .ax(i_cond_i_5_idqualvecop_43_31_im0_cma_c0),
        .resulta(i_cond_i_5_idqualvecop_43_31_im0_cma_s0),
        .accumulate(),
        .loadconst(),
        .negate(),
        .sub(),
        .az(),
        .coefsela(),
        .bx(),
        .by(),
        .bz(),
        .coefselb(),
        .cx(),
        .cy(),
        .dx(),
        .dy(),
        .scanin(),
        .scanout(),
        .chainin(),
        .chainout(),
        .disable_scanin(),
        .disable_chainout(),
        .resultb(),
        .dfxlfsrena(),
        .dfxmisrena()
    );
    dspba_delay_ver #( .width(36), .depth(0), .reset_kind("NONE"), .phase(0), .modulus(1), .reset_high(1'b0) )
    i_cond_i_5_idqualvecop_43_31_im0_cma_delay0 ( .xin(i_cond_i_5_idqualvecop_43_31_im0_cma_s0), .xout(i_cond_i_5_idqualvecop_43_31_im0_cma_qq0), .clk(clock), .aclr(resetn), .ena(1'b1) );
    assign i_cond_i_5_idqualvecop_43_31_im0_cma_q = $unsigned(i_cond_i_5_idqualvecop_43_31_im0_cma_qq0[35:0]);

    // i_cond_i_5_idqualvecop_43_31_sums_join_0(BITJOIN,276)@5
    assign i_cond_i_5_idqualvecop_43_31_sums_join_0_q = {i_cond_i_5_idqualvecop_43_31_im8_cma_q, i_cond_i_5_idqualvecop_43_31_im0_cma_q};

    // i_cond_i_5_idqualvecop_43_31_sums_result_add_0_0_rhsMSBs_select_bit_select_merged(BITSELECT,418)@5
    assign i_cond_i_5_idqualvecop_43_31_sums_result_add_0_0_rhsMSBs_select_bit_select_merged_b = $signed(i_cond_i_5_idqualvecop_43_31_sums_join_0_q[65:18]);
    assign i_cond_i_5_idqualvecop_43_31_sums_result_add_0_0_rhsMSBs_select_bit_select_merged_c = $signed(i_cond_i_5_idqualvecop_43_31_sums_join_0_q[17:0]);

    // i_cond_i_5_idqualvecop_43_31_sums_result_add_0_0_split_join(BITJOIN,355)@5
    assign i_cond_i_5_idqualvecop_43_31_sums_result_add_0_0_split_join_q = {i_cond_i_5_idqualvecop_43_31_sums_result_add_0_0_MSBs_sums_q, i_cond_i_5_idqualvecop_43_31_sums_result_add_0_0_rhsMSBs_select_bit_select_merged_c};

    // bgTrunc_i_cond_i_5_idqualvecop_43_31_sel_x(BITSELECT,139)@5
    assign bgTrunc_i_cond_i_5_idqualvecop_43_31_sel_x_in = i_cond_i_5_idqualvecop_43_31_sums_result_add_0_0_split_join_q[63:0];
    assign bgTrunc_i_cond_i_5_idqualvecop_43_31_sel_x_b = bgTrunc_i_cond_i_5_idqualvecop_43_31_sel_x_in[31:0];

    // i_reduction_idqualvecop_1_idqualvecop_43_43(LOGICAL,116)@5
    assign i_reduction_idqualvecop_1_idqualvecop_43_43_q = bgTrunc_i_cond_i_5_idqualvecop_43_31_sel_x_b ^ bgTrunc_i_cond_i_4_idqualvecop_43_26_sel_x_b;

    // valid_fanout_reg15(REG,160)@0 + 1
    always_ff @ (posedge clock) begin
        valid_fanout_reg15_q <= in_i_valid;
    end

    // i_llvm_fpga_sync_buffer_i32_arg_b_sync_buffer13_idqualvecop_43_35(BLACKBOX,109)@0
    // in in_i_dependence@1
    // in in_valid_in@1
    // out out_buffer_out@1
    // out out_valid_out@1
    IDQualVecOp_i_llvm_fpga_sync_buffer_i32_0000_idqualvecop_138_0gr thei_llvm_fpga_sync_buffer_i32_arg_b_sync_buffer13_idqualvecop_43_35 (
        .in_buffer_in(in_arg_b),
        .in_i_dependence(GND_q),
        .in_stall_in(GND_q),
        .in_valid_in(valid_fanout_reg15_q),
        .out_buffer_out(i_llvm_fpga_sync_buffer_i32_arg_b_sync_buffer13_idqualvecop_43_35_out_buffer_out),
        .out_stall_out(),
        .out_valid_out(),
        .clock(clock),
        .resetn(resetn)
    );

    // i_cond_i_6_idqualvecop_43_36_bs2_bit_select_merged(BITSELECT,402)@1
    assign i_cond_i_6_idqualvecop_43_36_bs2_bit_select_merged_b = $signed(i_llvm_fpga_sync_buffer_i32_arg_b_sync_buffer13_idqualvecop_43_35_out_buffer_out[17:0]);
    assign i_cond_i_6_idqualvecop_43_36_bs2_bit_select_merged_c = $signed(i_llvm_fpga_sync_buffer_i32_arg_b_sync_buffer13_idqualvecop_43_35_out_buffer_out[31:18]);

    // c_i32_6_43_83(CONSTANT,47)
    assign c_i32_6_43_83_q = 32'b00000000000000000000000000000110;

    // c_i32_6_43_82(CONSTANT,46)
    assign c_i32_6_43_82_q = 32'b11111111111111111111111111111010;

    // i_add_i_pn_p_6_idqualvecop_43_32(MUX,79)@1
    assign i_add_i_pn_p_6_idqualvecop_43_32_s = i_cmp2_i_idqualvecop_43_2gr_q;
    always_comb 
    begin
        unique case (i_add_i_pn_p_6_idqualvecop_43_32_s)
            1'b0 : i_add_i_pn_p_6_idqualvecop_43_32_q = c_i32_6_43_82_q;
            1'b1 : i_add_i_pn_p_6_idqualvecop_43_32_q = c_i32_6_43_83_q;
            default : i_add_i_pn_p_6_idqualvecop_43_32_q = 32'b0;
        endcase
    end

    // i_add_i_pn_p_6_idqualvecop_43_32_vt_select_31(BITSELECT,82)@1
    assign i_add_i_pn_p_6_idqualvecop_43_32_vt_select_31_b = i_add_i_pn_p_6_idqualvecop_43_32_q[31:2];

    // i_add_i_pn_p_6_idqualvecop_43_32_vt_join(BITJOIN,81)@1
    assign i_add_i_pn_p_6_idqualvecop_43_32_vt_join_q = {i_add_i_pn_p_6_idqualvecop_43_32_vt_select_31_b, i_add_i_pn_p_2_idqualvecop_43_12_vt_const_1_q};

    // i_add_i_pn_6_idqualvecop_43_34_lhsMSBs_select(BITSELECT,192)@1
    assign i_add_i_pn_6_idqualvecop_43_34_lhsMSBs_select_b = $signed(i_add_i_pn_p_6_idqualvecop_43_32_vt_join_q[31:1]);

    // i_add_i_pn_6_idqualvecop_43_34_MSBs_sums(ADD,193)@1
    assign i_add_i_pn_6_idqualvecop_43_34_MSBs_sums_a = {1'b0, i_add_i_pn_6_idqualvecop_43_34_lhsMSBs_select_b};
    assign i_add_i_pn_6_idqualvecop_43_34_MSBs_sums_b = {1'b0, i_add_i_pn_6_idqualvecop_43_34_rhsMSBs_select_bit_select_merged_b};
    assign i_add_i_pn_6_idqualvecop_43_34_MSBs_sums_o = $unsigned(i_add_i_pn_6_idqualvecop_43_34_MSBs_sums_a) + $unsigned(i_add_i_pn_6_idqualvecop_43_34_MSBs_sums_b);
    assign i_add_i_pn_6_idqualvecop_43_34_MSBs_sums_q = $signed(i_add_i_pn_6_idqualvecop_43_34_MSBs_sums_o[31:0]);

    // valid_fanout_reg14(REG,159)@0 + 1
    always_ff @ (posedge clock) begin
        valid_fanout_reg14_q <= in_i_valid;
    end

    // i_llvm_fpga_sync_buffer_i32_arg_a_sync_buffer5_idqualvecop_43_33(BLACKBOX,102)@0
    // in in_i_dependence@1
    // in in_valid_in@1
    // out out_buffer_out@1
    // out out_valid_out@1
    IDQualVecOp_i_llvm_fpga_sync_buffer_i32_0000_idqualvecop_132_0gr thei_llvm_fpga_sync_buffer_i32_arg_a_sync_buffer5_idqualvecop_43_33 (
        .in_buffer_in(in_arg_a),
        .in_i_dependence(GND_q),
        .in_stall_in(GND_q),
        .in_valid_in(valid_fanout_reg14_q),
        .out_buffer_out(i_llvm_fpga_sync_buffer_i32_arg_a_sync_buffer5_idqualvecop_43_33_out_buffer_out),
        .out_stall_out(),
        .out_valid_out(),
        .clock(clock),
        .resetn(resetn)
    );

    // i_add_i_pn_6_idqualvecop_43_34_rhsMSBs_select_bit_select_merged(BITSELECT,397)@1
    assign i_add_i_pn_6_idqualvecop_43_34_rhsMSBs_select_bit_select_merged_b = $signed(i_llvm_fpga_sync_buffer_i32_arg_a_sync_buffer5_idqualvecop_43_33_out_buffer_out[31:1]);
    assign i_add_i_pn_6_idqualvecop_43_34_rhsMSBs_select_bit_select_merged_c = $signed(i_llvm_fpga_sync_buffer_i32_arg_a_sync_buffer5_idqualvecop_43_33_out_buffer_out[0:0]);

    // i_add_i_pn_6_idqualvecop_43_34_split_join(BITJOIN,194)@1
    assign i_add_i_pn_6_idqualvecop_43_34_split_join_q = {i_add_i_pn_6_idqualvecop_43_34_MSBs_sums_q, i_add_i_pn_6_idqualvecop_43_34_rhsMSBs_select_bit_select_merged_c};

    // bgTrunc_i_add_i_pn_6_idqualvecop_43_34_sel_x(BITSELECT,133)@1
    assign bgTrunc_i_add_i_pn_6_idqualvecop_43_34_sel_x_b = i_add_i_pn_6_idqualvecop_43_34_split_join_q[31:0];

    // i_cond_i_6_idqualvecop_43_36_bs1_bit_select_merged(BITSELECT,412)@1
    assign i_cond_i_6_idqualvecop_43_36_bs1_bit_select_merged_b = $signed(bgTrunc_i_add_i_pn_6_idqualvecop_43_34_sel_x_b[17:0]);
    assign i_cond_i_6_idqualvecop_43_36_bs1_bit_select_merged_c = $signed(bgTrunc_i_add_i_pn_6_idqualvecop_43_34_sel_x_b[31:18]);

    // i_cond_i_6_idqualvecop_43_36_ma3_cma(CHAINMULTADD,392)@1 + 4
    // in b@4
    assign i_cond_i_6_idqualvecop_43_36_ma3_cma_reset = ~ (resetn);
    assign i_cond_i_6_idqualvecop_43_36_ma3_cma_ena0 = 1'b1;
    assign i_cond_i_6_idqualvecop_43_36_ma3_cma_ena1 = i_cond_i_6_idqualvecop_43_36_ma3_cma_ena0;
    assign i_cond_i_6_idqualvecop_43_36_ma3_cma_ena2 = i_cond_i_6_idqualvecop_43_36_ma3_cma_ena0;

    assign i_cond_i_6_idqualvecop_43_36_ma3_cma_a0 = i_cond_i_6_idqualvecop_43_36_bs1_bit_select_merged_c;
    assign i_cond_i_6_idqualvecop_43_36_ma3_cma_c0 = i_cond_i_6_idqualvecop_43_36_bs2_bit_select_merged_b;
    assign i_cond_i_6_idqualvecop_43_36_ma3_cma_a1 = i_cond_i_6_idqualvecop_43_36_bs2_bit_select_merged_c;
    assign i_cond_i_6_idqualvecop_43_36_ma3_cma_c1 = i_cond_i_6_idqualvecop_43_36_bs1_bit_select_merged_b;
    tennm_mac #(
        .operation_mode("m18x18_sumof2"),
        .clear_type("none"),
        .use_chainadder("false"),
        .ay_scan_in_clken("0"),
        .ay_scan_in_width(14),
        .by_clken("0"),
        .by_width(14),
        .ax_clken("0"),
        .bx_clken("0"),
        .ax_width(18),
        .bx_width(18),
        .signed_may("false"),
        .signed_mby("false"),
        .signed_max("false"),
        .signed_mbx("false"),
        .input_pipeline_clken("2"),
        .second_pipeline_clken("2"),
        .output_clken("1"),
        .result_a_width(33)
    ) i_cond_i_6_idqualvecop_43_36_ma3_cma_DSP0 (
        .clk(clock),
        .ena({ i_cond_i_6_idqualvecop_43_36_ma3_cma_ena2, i_cond_i_6_idqualvecop_43_36_ma3_cma_ena1, i_cond_i_6_idqualvecop_43_36_ma3_cma_ena0 }),
        .clr({ 1'b0, 1'b0 }),
        .ay(i_cond_i_6_idqualvecop_43_36_ma3_cma_a1),
        .by(i_cond_i_6_idqualvecop_43_36_ma3_cma_a0),
        .ax(i_cond_i_6_idqualvecop_43_36_ma3_cma_c1),
        .bx(i_cond_i_6_idqualvecop_43_36_ma3_cma_c0),
        .resulta(i_cond_i_6_idqualvecop_43_36_ma3_cma_s0),
        .accumulate(),
        .loadconst(),
        .negate(),
        .sub(),
        .az(),
        .coefsela(),
        .bz(),
        .coefselb(),
        .cx(),
        .cy(),
        .dx(),
        .dy(),
        .scanin(),
        .scanout(),
        .chainin(),
        .chainout(),
        .disable_scanin(),
        .disable_chainout(),
        .resultb(),
        .dfxlfsrena(),
        .dfxmisrena()
    );
    dspba_delay_ver #( .width(33), .depth(0), .reset_kind("NONE"), .phase(0), .modulus(1), .reset_high(1'b0) )
    i_cond_i_6_idqualvecop_43_36_ma3_cma_delay0 ( .xin(i_cond_i_6_idqualvecop_43_36_ma3_cma_s0), .xout(i_cond_i_6_idqualvecop_43_36_ma3_cma_qq0), .clk(clock), .aclr(resetn), .ena(1'b1) );
    assign i_cond_i_6_idqualvecop_43_36_ma3_cma_q = $unsigned(i_cond_i_6_idqualvecop_43_36_ma3_cma_qq0[32:0]);

    // i_cond_i_6_idqualvecop_43_36_sums_align_1(BITSHIFT,294)@5
    assign i_cond_i_6_idqualvecop_43_36_sums_align_1_qint = { i_cond_i_6_idqualvecop_43_36_ma3_cma_q, 18'b000000000000000000 };
    assign i_cond_i_6_idqualvecop_43_36_sums_align_1_q = i_cond_i_6_idqualvecop_43_36_sums_align_1_qint[50:0];

    // i_cond_i_6_idqualvecop_43_36_sums_result_add_0_0_lhsMSBs_select(BITSELECT,358)@5
    assign i_cond_i_6_idqualvecop_43_36_sums_result_add_0_0_lhsMSBs_select_b = $signed(i_cond_i_6_idqualvecop_43_36_sums_align_1_q[50:18]);

    // i_cond_i_6_idqualvecop_43_36_sums_result_add_0_0_MSBs_sums(ADD,359)@5
    assign i_cond_i_6_idqualvecop_43_36_sums_result_add_0_0_MSBs_sums_a = {16'b0000000000000000, i_cond_i_6_idqualvecop_43_36_sums_result_add_0_0_lhsMSBs_select_b};
    assign i_cond_i_6_idqualvecop_43_36_sums_result_add_0_0_MSBs_sums_b = {1'b0, i_cond_i_6_idqualvecop_43_36_sums_result_add_0_0_rhsMSBs_select_bit_select_merged_b};
    assign i_cond_i_6_idqualvecop_43_36_sums_result_add_0_0_MSBs_sums_o = $unsigned(i_cond_i_6_idqualvecop_43_36_sums_result_add_0_0_MSBs_sums_a) + $unsigned(i_cond_i_6_idqualvecop_43_36_sums_result_add_0_0_MSBs_sums_b);
    assign i_cond_i_6_idqualvecop_43_36_sums_result_add_0_0_MSBs_sums_q = $signed(i_cond_i_6_idqualvecop_43_36_sums_result_add_0_0_MSBs_sums_o[48:0]);

    // i_cond_i_6_idqualvecop_43_36_bjB12(BITJOIN,292)@1
    assign i_cond_i_6_idqualvecop_43_36_bjB12_q = {GND_q, i_cond_i_6_idqualvecop_43_36_bs2_bit_select_merged_c};

    // i_cond_i_6_idqualvecop_43_36_bjA10(BITJOIN,290)@1
    assign i_cond_i_6_idqualvecop_43_36_bjA10_q = {GND_q, i_cond_i_6_idqualvecop_43_36_bs1_bit_select_merged_c};

    // i_cond_i_6_idqualvecop_43_36_im8_cma(CHAINMULTADD,382)@1 + 4
    // in b@4
    assign i_cond_i_6_idqualvecop_43_36_im8_cma_reset = ~ (resetn);
    assign i_cond_i_6_idqualvecop_43_36_im8_cma_ena0 = 1'b1;
    assign i_cond_i_6_idqualvecop_43_36_im8_cma_ena1 = i_cond_i_6_idqualvecop_43_36_im8_cma_ena0;
    assign i_cond_i_6_idqualvecop_43_36_im8_cma_ena2 = i_cond_i_6_idqualvecop_43_36_im8_cma_ena0;

    assign i_cond_i_6_idqualvecop_43_36_im8_cma_a0 = $unsigned(i_cond_i_6_idqualvecop_43_36_bjA10_q);
    assign i_cond_i_6_idqualvecop_43_36_im8_cma_c0 = $unsigned(i_cond_i_6_idqualvecop_43_36_bjB12_q);
    tennm_mac #(
        .operation_mode("m18x18_full"),
        .clear_type("none"),
        .ay_scan_in_clken("0"),
        .ay_scan_in_width(15),
        .ax_clken("0"),
        .ax_width(15),
        .signed_may("true"),
        .signed_max("true"),
        .input_pipeline_clken("2"),
        .second_pipeline_clken("2"),
        .output_clken("1"),
        .result_a_width(30)
    ) i_cond_i_6_idqualvecop_43_36_im8_cma_DSP0 (
        .clk(clock),
        .ena({ i_cond_i_6_idqualvecop_43_36_im8_cma_ena2, i_cond_i_6_idqualvecop_43_36_im8_cma_ena1, i_cond_i_6_idqualvecop_43_36_im8_cma_ena0 }),
        .clr({ 1'b0, 1'b0 }),
        .ay(i_cond_i_6_idqualvecop_43_36_im8_cma_a0),
        .ax(i_cond_i_6_idqualvecop_43_36_im8_cma_c0),
        .resulta(i_cond_i_6_idqualvecop_43_36_im8_cma_s0),
        .accumulate(),
        .loadconst(),
        .negate(),
        .sub(),
        .az(),
        .coefsela(),
        .bx(),
        .by(),
        .bz(),
        .coefselb(),
        .cx(),
        .cy(),
        .dx(),
        .dy(),
        .scanin(),
        .scanout(),
        .chainin(),
        .chainout(),
        .disable_scanin(),
        .disable_chainout(),
        .resultb(),
        .dfxlfsrena(),
        .dfxmisrena()
    );
    dspba_delay_ver #( .width(30), .depth(0), .reset_kind("NONE"), .phase(0), .modulus(1), .reset_high(1'b0) )
    i_cond_i_6_idqualvecop_43_36_im8_cma_delay0 ( .xin(i_cond_i_6_idqualvecop_43_36_im8_cma_s0), .xout(i_cond_i_6_idqualvecop_43_36_im8_cma_qq0), .clk(clock), .aclr(resetn), .ena(1'b1) );
    assign i_cond_i_6_idqualvecop_43_36_im8_cma_q = $unsigned(i_cond_i_6_idqualvecop_43_36_im8_cma_qq0[29:0]);

    // i_cond_i_6_idqualvecop_43_36_im0_cma(CHAINMULTADD,381)@1 + 4
    // in b@4
    assign i_cond_i_6_idqualvecop_43_36_im0_cma_reset = ~ (resetn);
    assign i_cond_i_6_idqualvecop_43_36_im0_cma_ena0 = 1'b1;
    assign i_cond_i_6_idqualvecop_43_36_im0_cma_ena1 = i_cond_i_6_idqualvecop_43_36_im0_cma_ena0;
    assign i_cond_i_6_idqualvecop_43_36_im0_cma_ena2 = i_cond_i_6_idqualvecop_43_36_im0_cma_ena0;

    assign i_cond_i_6_idqualvecop_43_36_im0_cma_a0 = i_cond_i_6_idqualvecop_43_36_bs1_bit_select_merged_b;
    assign i_cond_i_6_idqualvecop_43_36_im0_cma_c0 = i_cond_i_6_idqualvecop_43_36_bs2_bit_select_merged_b;
    tennm_mac #(
        .operation_mode("m18x18_full"),
        .clear_type("none"),
        .ay_scan_in_clken("0"),
        .ay_scan_in_width(18),
        .ax_clken("0"),
        .ax_width(18),
        .signed_may("false"),
        .signed_max("false"),
        .input_pipeline_clken("2"),
        .second_pipeline_clken("2"),
        .output_clken("1"),
        .result_a_width(36)
    ) i_cond_i_6_idqualvecop_43_36_im0_cma_DSP0 (
        .clk(clock),
        .ena({ i_cond_i_6_idqualvecop_43_36_im0_cma_ena2, i_cond_i_6_idqualvecop_43_36_im0_cma_ena1, i_cond_i_6_idqualvecop_43_36_im0_cma_ena0 }),
        .clr({ 1'b0, 1'b0 }),
        .ay(i_cond_i_6_idqualvecop_43_36_im0_cma_a0),
        .ax(i_cond_i_6_idqualvecop_43_36_im0_cma_c0),
        .resulta(i_cond_i_6_idqualvecop_43_36_im0_cma_s0),
        .accumulate(),
        .loadconst(),
        .negate(),
        .sub(),
        .az(),
        .coefsela(),
        .bx(),
        .by(),
        .bz(),
        .coefselb(),
        .cx(),
        .cy(),
        .dx(),
        .dy(),
        .scanin(),
        .scanout(),
        .chainin(),
        .chainout(),
        .disable_scanin(),
        .disable_chainout(),
        .resultb(),
        .dfxlfsrena(),
        .dfxmisrena()
    );
    dspba_delay_ver #( .width(36), .depth(0), .reset_kind("NONE"), .phase(0), .modulus(1), .reset_high(1'b0) )
    i_cond_i_6_idqualvecop_43_36_im0_cma_delay0 ( .xin(i_cond_i_6_idqualvecop_43_36_im0_cma_s0), .xout(i_cond_i_6_idqualvecop_43_36_im0_cma_qq0), .clk(clock), .aclr(resetn), .ena(1'b1) );
    assign i_cond_i_6_idqualvecop_43_36_im0_cma_q = $unsigned(i_cond_i_6_idqualvecop_43_36_im0_cma_qq0[35:0]);

    // i_cond_i_6_idqualvecop_43_36_sums_join_0(BITJOIN,293)@5
    assign i_cond_i_6_idqualvecop_43_36_sums_join_0_q = {i_cond_i_6_idqualvecop_43_36_im8_cma_q, i_cond_i_6_idqualvecop_43_36_im0_cma_q};

    // i_cond_i_6_idqualvecop_43_36_sums_result_add_0_0_rhsMSBs_select_bit_select_merged(BITSELECT,419)@5
    assign i_cond_i_6_idqualvecop_43_36_sums_result_add_0_0_rhsMSBs_select_bit_select_merged_b = $signed(i_cond_i_6_idqualvecop_43_36_sums_join_0_q[65:18]);
    assign i_cond_i_6_idqualvecop_43_36_sums_result_add_0_0_rhsMSBs_select_bit_select_merged_c = $signed(i_cond_i_6_idqualvecop_43_36_sums_join_0_q[17:0]);

    // i_cond_i_6_idqualvecop_43_36_sums_result_add_0_0_split_join(BITJOIN,360)@5
    assign i_cond_i_6_idqualvecop_43_36_sums_result_add_0_0_split_join_q = {i_cond_i_6_idqualvecop_43_36_sums_result_add_0_0_MSBs_sums_q, i_cond_i_6_idqualvecop_43_36_sums_result_add_0_0_rhsMSBs_select_bit_select_merged_c};

    // bgTrunc_i_cond_i_6_idqualvecop_43_36_sel_x(BITSELECT,140)@5
    assign bgTrunc_i_cond_i_6_idqualvecop_43_36_sel_x_in = i_cond_i_6_idqualvecop_43_36_sums_result_add_0_0_split_join_q[63:0];
    assign bgTrunc_i_cond_i_6_idqualvecop_43_36_sel_x_b = bgTrunc_i_cond_i_6_idqualvecop_43_36_sel_x_in[31:0];

    // valid_fanout_reg17(REG,162)@0 + 1
    always_ff @ (posedge clock) begin
        valid_fanout_reg17_q <= in_i_valid;
    end

    // i_llvm_fpga_sync_buffer_i32_arg_b_sync_buffer14_idqualvecop_43_40(BLACKBOX,110)@0
    // in in_i_dependence@1
    // in in_valid_in@1
    // out out_buffer_out@1
    // out out_valid_out@1
    IDQualVecOp_i_llvm_fpga_sync_buffer_i32_0000_idqualvecop_151_0gr thei_llvm_fpga_sync_buffer_i32_arg_b_sync_buffer14_idqualvecop_43_40 (
        .in_buffer_in(in_arg_b),
        .in_i_dependence(GND_q),
        .in_stall_in(GND_q),
        .in_valid_in(valid_fanout_reg17_q),
        .out_buffer_out(i_llvm_fpga_sync_buffer_i32_arg_b_sync_buffer14_idqualvecop_43_40_out_buffer_out),
        .out_stall_out(),
        .out_valid_out(),
        .clock(clock),
        .resetn(resetn)
    );

    // i_cond_i_7_idqualvecop_43_41_bs2_bit_select_merged(BITSELECT,403)@1
    assign i_cond_i_7_idqualvecop_43_41_bs2_bit_select_merged_b = $signed(i_llvm_fpga_sync_buffer_i32_arg_b_sync_buffer14_idqualvecop_43_40_out_buffer_out[17:0]);
    assign i_cond_i_7_idqualvecop_43_41_bs2_bit_select_merged_c = $signed(i_llvm_fpga_sync_buffer_i32_arg_b_sync_buffer14_idqualvecop_43_40_out_buffer_out[31:18]);

    // c_i32_7_43_85(CONSTANT,49)
    assign c_i32_7_43_85_q = 32'b00000000000000000000000000000111;

    // c_i32_7_43_84(CONSTANT,48)
    assign c_i32_7_43_84_q = 32'b11111111111111111111111111111001;

    // i_add_i_pn_p_7_idqualvecop_43_37(MUX,83)@1
    assign i_add_i_pn_p_7_idqualvecop_43_37_s = i_cmp2_i_idqualvecop_43_2gr_q;
    always_comb 
    begin
        unique case (i_add_i_pn_p_7_idqualvecop_43_37_s)
            1'b0 : i_add_i_pn_p_7_idqualvecop_43_37_q = c_i32_7_43_84_q;
            1'b1 : i_add_i_pn_p_7_idqualvecop_43_37_q = c_i32_7_43_85_q;
            default : i_add_i_pn_p_7_idqualvecop_43_37_q = 32'b0;
        endcase
    end

    // i_add_i_pn_p_7_idqualvecop_43_37_vt_select_31(BITSELECT,86)@1
    assign i_add_i_pn_p_7_idqualvecop_43_37_vt_select_31_b = i_add_i_pn_p_7_idqualvecop_43_37_q[31:1];

    // i_add_i_pn_p_7_idqualvecop_43_37_vt_join(BITJOIN,85)@1
    assign i_add_i_pn_p_7_idqualvecop_43_37_vt_join_q = {i_add_i_pn_p_7_idqualvecop_43_37_vt_select_31_b, VCC_q};

    // valid_fanout_reg16(REG,161)@0 + 1
    always_ff @ (posedge clock) begin
        valid_fanout_reg16_q <= in_i_valid;
    end

    // i_llvm_fpga_sync_buffer_i32_arg_a_sync_buffer6_idqualvecop_43_38(BLACKBOX,103)@0
    // in in_i_dependence@1
    // in in_valid_in@1
    // out out_buffer_out@1
    // out out_valid_out@1
    IDQualVecOp_i_llvm_fpga_sync_buffer_i32_0000_idqualvecop_145_0gr thei_llvm_fpga_sync_buffer_i32_arg_a_sync_buffer6_idqualvecop_43_38 (
        .in_buffer_in(in_arg_a),
        .in_i_dependence(GND_q),
        .in_stall_in(GND_q),
        .in_valid_in(valid_fanout_reg16_q),
        .out_buffer_out(i_llvm_fpga_sync_buffer_i32_arg_a_sync_buffer6_idqualvecop_43_38_out_buffer_out),
        .out_stall_out(),
        .out_valid_out(),
        .clock(clock),
        .resetn(resetn)
    );

    // i_add_i_pn_7_idqualvecop_43_39(ADD,58)@1
    assign i_add_i_pn_7_idqualvecop_43_39_a = {1'b0, i_llvm_fpga_sync_buffer_i32_arg_a_sync_buffer6_idqualvecop_43_38_out_buffer_out};
    assign i_add_i_pn_7_idqualvecop_43_39_b = {1'b0, i_add_i_pn_p_7_idqualvecop_43_37_vt_join_q};
    assign i_add_i_pn_7_idqualvecop_43_39_o = $unsigned(i_add_i_pn_7_idqualvecop_43_39_a) + $unsigned(i_add_i_pn_7_idqualvecop_43_39_b);
    assign i_add_i_pn_7_idqualvecop_43_39_q = i_add_i_pn_7_idqualvecop_43_39_o[32:0];

    // bgTrunc_i_add_i_pn_7_idqualvecop_43_39_sel_x(BITSELECT,134)@1
    assign bgTrunc_i_add_i_pn_7_idqualvecop_43_39_sel_x_b = i_add_i_pn_7_idqualvecop_43_39_q[31:0];

    // i_cond_i_7_idqualvecop_43_41_bs1_bit_select_merged(BITSELECT,413)@1
    assign i_cond_i_7_idqualvecop_43_41_bs1_bit_select_merged_b = $signed(bgTrunc_i_add_i_pn_7_idqualvecop_43_39_sel_x_b[17:0]);
    assign i_cond_i_7_idqualvecop_43_41_bs1_bit_select_merged_c = $signed(bgTrunc_i_add_i_pn_7_idqualvecop_43_39_sel_x_b[31:18]);

    // i_cond_i_7_idqualvecop_43_41_ma3_cma(CHAINMULTADD,393)@1 + 4
    // in b@4
    assign i_cond_i_7_idqualvecop_43_41_ma3_cma_reset = ~ (resetn);
    assign i_cond_i_7_idqualvecop_43_41_ma3_cma_ena0 = 1'b1;
    assign i_cond_i_7_idqualvecop_43_41_ma3_cma_ena1 = i_cond_i_7_idqualvecop_43_41_ma3_cma_ena0;
    assign i_cond_i_7_idqualvecop_43_41_ma3_cma_ena2 = i_cond_i_7_idqualvecop_43_41_ma3_cma_ena0;

    assign i_cond_i_7_idqualvecop_43_41_ma3_cma_a0 = i_cond_i_7_idqualvecop_43_41_bs1_bit_select_merged_c;
    assign i_cond_i_7_idqualvecop_43_41_ma3_cma_c0 = i_cond_i_7_idqualvecop_43_41_bs2_bit_select_merged_b;
    assign i_cond_i_7_idqualvecop_43_41_ma3_cma_a1 = i_cond_i_7_idqualvecop_43_41_bs2_bit_select_merged_c;
    assign i_cond_i_7_idqualvecop_43_41_ma3_cma_c1 = i_cond_i_7_idqualvecop_43_41_bs1_bit_select_merged_b;
    tennm_mac #(
        .operation_mode("m18x18_sumof2"),
        .clear_type("none"),
        .use_chainadder("false"),
        .ay_scan_in_clken("0"),
        .ay_scan_in_width(14),
        .by_clken("0"),
        .by_width(14),
        .ax_clken("0"),
        .bx_clken("0"),
        .ax_width(18),
        .bx_width(18),
        .signed_may("false"),
        .signed_mby("false"),
        .signed_max("false"),
        .signed_mbx("false"),
        .input_pipeline_clken("2"),
        .second_pipeline_clken("2"),
        .output_clken("1"),
        .result_a_width(33)
    ) i_cond_i_7_idqualvecop_43_41_ma3_cma_DSP0 (
        .clk(clock),
        .ena({ i_cond_i_7_idqualvecop_43_41_ma3_cma_ena2, i_cond_i_7_idqualvecop_43_41_ma3_cma_ena1, i_cond_i_7_idqualvecop_43_41_ma3_cma_ena0 }),
        .clr({ 1'b0, 1'b0 }),
        .ay(i_cond_i_7_idqualvecop_43_41_ma3_cma_a1),
        .by(i_cond_i_7_idqualvecop_43_41_ma3_cma_a0),
        .ax(i_cond_i_7_idqualvecop_43_41_ma3_cma_c1),
        .bx(i_cond_i_7_idqualvecop_43_41_ma3_cma_c0),
        .resulta(i_cond_i_7_idqualvecop_43_41_ma3_cma_s0),
        .accumulate(),
        .loadconst(),
        .negate(),
        .sub(),
        .az(),
        .coefsela(),
        .bz(),
        .coefselb(),
        .cx(),
        .cy(),
        .dx(),
        .dy(),
        .scanin(),
        .scanout(),
        .chainin(),
        .chainout(),
        .disable_scanin(),
        .disable_chainout(),
        .resultb(),
        .dfxlfsrena(),
        .dfxmisrena()
    );
    dspba_delay_ver #( .width(33), .depth(0), .reset_kind("NONE"), .phase(0), .modulus(1), .reset_high(1'b0) )
    i_cond_i_7_idqualvecop_43_41_ma3_cma_delay0 ( .xin(i_cond_i_7_idqualvecop_43_41_ma3_cma_s0), .xout(i_cond_i_7_idqualvecop_43_41_ma3_cma_qq0), .clk(clock), .aclr(resetn), .ena(1'b1) );
    assign i_cond_i_7_idqualvecop_43_41_ma3_cma_q = $unsigned(i_cond_i_7_idqualvecop_43_41_ma3_cma_qq0[32:0]);

    // i_cond_i_7_idqualvecop_43_41_sums_align_1(BITSHIFT,311)@5
    assign i_cond_i_7_idqualvecop_43_41_sums_align_1_qint = { i_cond_i_7_idqualvecop_43_41_ma3_cma_q, 18'b000000000000000000 };
    assign i_cond_i_7_idqualvecop_43_41_sums_align_1_q = i_cond_i_7_idqualvecop_43_41_sums_align_1_qint[50:0];

    // i_cond_i_7_idqualvecop_43_41_sums_result_add_0_0_lhsMSBs_select(BITSELECT,363)@5
    assign i_cond_i_7_idqualvecop_43_41_sums_result_add_0_0_lhsMSBs_select_b = $signed(i_cond_i_7_idqualvecop_43_41_sums_align_1_q[50:18]);

    // i_cond_i_7_idqualvecop_43_41_sums_result_add_0_0_MSBs_sums(ADD,364)@5
    assign i_cond_i_7_idqualvecop_43_41_sums_result_add_0_0_MSBs_sums_a = {16'b0000000000000000, i_cond_i_7_idqualvecop_43_41_sums_result_add_0_0_lhsMSBs_select_b};
    assign i_cond_i_7_idqualvecop_43_41_sums_result_add_0_0_MSBs_sums_b = {1'b0, i_cond_i_7_idqualvecop_43_41_sums_result_add_0_0_rhsMSBs_select_bit_select_merged_b};
    assign i_cond_i_7_idqualvecop_43_41_sums_result_add_0_0_MSBs_sums_o = $unsigned(i_cond_i_7_idqualvecop_43_41_sums_result_add_0_0_MSBs_sums_a) + $unsigned(i_cond_i_7_idqualvecop_43_41_sums_result_add_0_0_MSBs_sums_b);
    assign i_cond_i_7_idqualvecop_43_41_sums_result_add_0_0_MSBs_sums_q = $signed(i_cond_i_7_idqualvecop_43_41_sums_result_add_0_0_MSBs_sums_o[48:0]);

    // i_cond_i_7_idqualvecop_43_41_bjB12(BITJOIN,309)@1
    assign i_cond_i_7_idqualvecop_43_41_bjB12_q = {GND_q, i_cond_i_7_idqualvecop_43_41_bs2_bit_select_merged_c};

    // i_cond_i_7_idqualvecop_43_41_bjA10(BITJOIN,307)@1
    assign i_cond_i_7_idqualvecop_43_41_bjA10_q = {GND_q, i_cond_i_7_idqualvecop_43_41_bs1_bit_select_merged_c};

    // i_cond_i_7_idqualvecop_43_41_im8_cma(CHAINMULTADD,384)@1 + 4
    // in b@4
    assign i_cond_i_7_idqualvecop_43_41_im8_cma_reset = ~ (resetn);
    assign i_cond_i_7_idqualvecop_43_41_im8_cma_ena0 = 1'b1;
    assign i_cond_i_7_idqualvecop_43_41_im8_cma_ena1 = i_cond_i_7_idqualvecop_43_41_im8_cma_ena0;
    assign i_cond_i_7_idqualvecop_43_41_im8_cma_ena2 = i_cond_i_7_idqualvecop_43_41_im8_cma_ena0;

    assign i_cond_i_7_idqualvecop_43_41_im8_cma_a0 = $unsigned(i_cond_i_7_idqualvecop_43_41_bjA10_q);
    assign i_cond_i_7_idqualvecop_43_41_im8_cma_c0 = $unsigned(i_cond_i_7_idqualvecop_43_41_bjB12_q);
    tennm_mac #(
        .operation_mode("m18x18_full"),
        .clear_type("none"),
        .ay_scan_in_clken("0"),
        .ay_scan_in_width(15),
        .ax_clken("0"),
        .ax_width(15),
        .signed_may("true"),
        .signed_max("true"),
        .input_pipeline_clken("2"),
        .second_pipeline_clken("2"),
        .output_clken("1"),
        .result_a_width(30)
    ) i_cond_i_7_idqualvecop_43_41_im8_cma_DSP0 (
        .clk(clock),
        .ena({ i_cond_i_7_idqualvecop_43_41_im8_cma_ena2, i_cond_i_7_idqualvecop_43_41_im8_cma_ena1, i_cond_i_7_idqualvecop_43_41_im8_cma_ena0 }),
        .clr({ 1'b0, 1'b0 }),
        .ay(i_cond_i_7_idqualvecop_43_41_im8_cma_a0),
        .ax(i_cond_i_7_idqualvecop_43_41_im8_cma_c0),
        .resulta(i_cond_i_7_idqualvecop_43_41_im8_cma_s0),
        .accumulate(),
        .loadconst(),
        .negate(),
        .sub(),
        .az(),
        .coefsela(),
        .bx(),
        .by(),
        .bz(),
        .coefselb(),
        .cx(),
        .cy(),
        .dx(),
        .dy(),
        .scanin(),
        .scanout(),
        .chainin(),
        .chainout(),
        .disable_scanin(),
        .disable_chainout(),
        .resultb(),
        .dfxlfsrena(),
        .dfxmisrena()
    );
    dspba_delay_ver #( .width(30), .depth(0), .reset_kind("NONE"), .phase(0), .modulus(1), .reset_high(1'b0) )
    i_cond_i_7_idqualvecop_43_41_im8_cma_delay0 ( .xin(i_cond_i_7_idqualvecop_43_41_im8_cma_s0), .xout(i_cond_i_7_idqualvecop_43_41_im8_cma_qq0), .clk(clock), .aclr(resetn), .ena(1'b1) );
    assign i_cond_i_7_idqualvecop_43_41_im8_cma_q = $unsigned(i_cond_i_7_idqualvecop_43_41_im8_cma_qq0[29:0]);

    // i_cond_i_7_idqualvecop_43_41_im0_cma(CHAINMULTADD,383)@1 + 4
    // in b@4
    assign i_cond_i_7_idqualvecop_43_41_im0_cma_reset = ~ (resetn);
    assign i_cond_i_7_idqualvecop_43_41_im0_cma_ena0 = 1'b1;
    assign i_cond_i_7_idqualvecop_43_41_im0_cma_ena1 = i_cond_i_7_idqualvecop_43_41_im0_cma_ena0;
    assign i_cond_i_7_idqualvecop_43_41_im0_cma_ena2 = i_cond_i_7_idqualvecop_43_41_im0_cma_ena0;

    assign i_cond_i_7_idqualvecop_43_41_im0_cma_a0 = i_cond_i_7_idqualvecop_43_41_bs1_bit_select_merged_b;
    assign i_cond_i_7_idqualvecop_43_41_im0_cma_c0 = i_cond_i_7_idqualvecop_43_41_bs2_bit_select_merged_b;
    tennm_mac #(
        .operation_mode("m18x18_full"),
        .clear_type("none"),
        .ay_scan_in_clken("0"),
        .ay_scan_in_width(18),
        .ax_clken("0"),
        .ax_width(18),
        .signed_may("false"),
        .signed_max("false"),
        .input_pipeline_clken("2"),
        .second_pipeline_clken("2"),
        .output_clken("1"),
        .result_a_width(36)
    ) i_cond_i_7_idqualvecop_43_41_im0_cma_DSP0 (
        .clk(clock),
        .ena({ i_cond_i_7_idqualvecop_43_41_im0_cma_ena2, i_cond_i_7_idqualvecop_43_41_im0_cma_ena1, i_cond_i_7_idqualvecop_43_41_im0_cma_ena0 }),
        .clr({ 1'b0, 1'b0 }),
        .ay(i_cond_i_7_idqualvecop_43_41_im0_cma_a0),
        .ax(i_cond_i_7_idqualvecop_43_41_im0_cma_c0),
        .resulta(i_cond_i_7_idqualvecop_43_41_im0_cma_s0),
        .accumulate(),
        .loadconst(),
        .negate(),
        .sub(),
        .az(),
        .coefsela(),
        .bx(),
        .by(),
        .bz(),
        .coefselb(),
        .cx(),
        .cy(),
        .dx(),
        .dy(),
        .scanin(),
        .scanout(),
        .chainin(),
        .chainout(),
        .disable_scanin(),
        .disable_chainout(),
        .resultb(),
        .dfxlfsrena(),
        .dfxmisrena()
    );
    dspba_delay_ver #( .width(36), .depth(0), .reset_kind("NONE"), .phase(0), .modulus(1), .reset_high(1'b0) )
    i_cond_i_7_idqualvecop_43_41_im0_cma_delay0 ( .xin(i_cond_i_7_idqualvecop_43_41_im0_cma_s0), .xout(i_cond_i_7_idqualvecop_43_41_im0_cma_qq0), .clk(clock), .aclr(resetn), .ena(1'b1) );
    assign i_cond_i_7_idqualvecop_43_41_im0_cma_q = $unsigned(i_cond_i_7_idqualvecop_43_41_im0_cma_qq0[35:0]);

    // i_cond_i_7_idqualvecop_43_41_sums_join_0(BITJOIN,310)@5
    assign i_cond_i_7_idqualvecop_43_41_sums_join_0_q = {i_cond_i_7_idqualvecop_43_41_im8_cma_q, i_cond_i_7_idqualvecop_43_41_im0_cma_q};

    // i_cond_i_7_idqualvecop_43_41_sums_result_add_0_0_rhsMSBs_select_bit_select_merged(BITSELECT,420)@5
    assign i_cond_i_7_idqualvecop_43_41_sums_result_add_0_0_rhsMSBs_select_bit_select_merged_b = $signed(i_cond_i_7_idqualvecop_43_41_sums_join_0_q[65:18]);
    assign i_cond_i_7_idqualvecop_43_41_sums_result_add_0_0_rhsMSBs_select_bit_select_merged_c = $signed(i_cond_i_7_idqualvecop_43_41_sums_join_0_q[17:0]);

    // i_cond_i_7_idqualvecop_43_41_sums_result_add_0_0_split_join(BITJOIN,365)@5
    assign i_cond_i_7_idqualvecop_43_41_sums_result_add_0_0_split_join_q = {i_cond_i_7_idqualvecop_43_41_sums_result_add_0_0_MSBs_sums_q, i_cond_i_7_idqualvecop_43_41_sums_result_add_0_0_rhsMSBs_select_bit_select_merged_c};

    // bgTrunc_i_cond_i_7_idqualvecop_43_41_sel_x(BITSELECT,141)@5
    assign bgTrunc_i_cond_i_7_idqualvecop_43_41_sel_x_in = i_cond_i_7_idqualvecop_43_41_sums_result_add_0_0_split_join_q[63:0];
    assign bgTrunc_i_cond_i_7_idqualvecop_43_41_sel_x_b = bgTrunc_i_cond_i_7_idqualvecop_43_41_sel_x_in[31:0];

    // i_reduction_idqualvecop_0_idqualvecop_43_42(LOGICAL,115)@5
    assign i_reduction_idqualvecop_0_idqualvecop_43_42_q = bgTrunc_i_cond_i_7_idqualvecop_43_41_sel_x_b ^ bgTrunc_i_cond_i_6_idqualvecop_43_36_sel_x_b;

    // i_reduction_idqualvecop_4_idqualvecop_43_46(LOGICAL,119)@5
    assign i_reduction_idqualvecop_4_idqualvecop_43_46_q = i_reduction_idqualvecop_0_idqualvecop_43_42_q ^ i_reduction_idqualvecop_1_idqualvecop_43_43_q;

    // i_reduction_idqualvecop_6_idqualvecop_43_48(LOGICAL,121)@5 + 1
    assign i_reduction_idqualvecop_6_idqualvecop_43_48_qi = i_reduction_idqualvecop_4_idqualvecop_43_46_q ^ i_reduction_idqualvecop_5_idqualvecop_43_47_q;
    dspba_delay_ver #( .width(32), .depth(1), .reset_kind("NONE"), .phase(0), .modulus(1), .reset_high(1'b0) )
    i_reduction_idqualvecop_6_idqualvecop_43_48_delay ( .xin(i_reduction_idqualvecop_6_idqualvecop_43_48_qi), .xout(i_reduction_idqualvecop_6_idqualvecop_43_48_q), .clk(clock), .aclr(resetn), .ena(1'b1) );

    // i_iowr_nb_acl_c_resultpipeid_pipe_channel_unnamed_idqualvecop2_idqualvecop_43_50(BLACKBOX,97)@6
    // out out_iowr_nb_acl_c_ResultPipeID_pipe_channel_o_fifodata@20000000
    // out out_iowr_nb_acl_c_ResultPipeID_pipe_channel_o_fifovalid@20000000
    IDQualVecOp_i_iowr_nb_acl_c_resultpipeid0000_idqualvecop_168_0gr thei_iowr_nb_acl_c_resultpipeid_pipe_channel_unnamed_idqualvecop2_idqualvecop_43_50 (
        .in_i_data(i_reduction_idqualvecop_6_idqualvecop_43_48_q),
        .in_i_stall(GND_q),
        .in_i_valid(valid_fanout_reg19_q),
        .in_unnamed_IDQualVecOp1(i_io_full_acl_c_resultpipeid_pipe_channel_unnamed_idqualvecop1_idqualvecop_43_49_out_o_almostfull),
        .out_iowr_nb_acl_c_ResultPipeID_pipe_channel_o_fifodata(i_iowr_nb_acl_c_resultpipeid_pipe_channel_unnamed_idqualvecop2_idqualvecop_43_50_out_iowr_nb_acl_c_ResultPipeID_pipe_channel_o_fifodata),
        .out_iowr_nb_acl_c_ResultPipeID_pipe_channel_o_fifovalid(i_iowr_nb_acl_c_resultpipeid_pipe_channel_unnamed_idqualvecop2_idqualvecop_43_50_out_iowr_nb_acl_c_ResultPipeID_pipe_channel_o_fifovalid),
        .out_o_ack(),
        .out_o_stall(),
        .out_o_valid(),
        .clock(clock),
        .resetn(resetn)
    );

    // ext_sig_sync_out(GPOUT,51)
    assign out_iowr_nb_acl_c_ResultPipeID_pipe_channel_o_fifodata = i_iowr_nb_acl_c_resultpipeid_pipe_channel_unnamed_idqualvecop2_idqualvecop_43_50_out_iowr_nb_acl_c_ResultPipeID_pipe_channel_o_fifodata;
    assign out_iowr_nb_acl_c_ResultPipeID_pipe_channel_o_fifovalid = i_iowr_nb_acl_c_resultpipeid_pipe_channel_unnamed_idqualvecop2_idqualvecop_43_50_out_iowr_nb_acl_c_ResultPipeID_pipe_channel_o_fifovalid;

    // valid_fanout_reg0(REG,145)@5 + 1
    always_ff @ (posedge clock) begin
        valid_fanout_reg0_q <= redist0_sync_together_43_89_in_i_valid_5_q;
    end

    // sync_out_1_aunroll_x(GPOUT,144)@6
    assign out_o_valid = valid_fanout_reg0_q;
    assign out_unnamed_IDQualVecOp0_aggregateComponentTag_0_x_tpl = GND_q;
    assign out_unnamed_IDQualVecOp3 = GND_q;

endmodule

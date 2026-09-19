package require -exact qsys 15.0
set_module_property NAME qual_vec_op_report_di
set_module_property VERSION 1.0
set_module_property INTERNAL false
set_module_property GROUP oneAPI
set_module_property DISPLAY_NAME qual_vec_op_report_di
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property SUPPORTED_DEVICE_FAMILIES {"Agilex 7" "Agilex"}
#### Synthesis fileset
add_fileset QUARTUS_SYNTH QUARTUS_SYNTH "" ""
set_fileset_property QUARTUS_SYNTH TOP_LEVEL qual_vec_op_report_di
set_fileset_property QUARTUS_SYNTH ENABLE_RELATIVE_INCLUDE_PATHS false
add_fileset_file "qual_vec_op_report_di.sv" SYSTEM_VERILOG PATH "./qual_vec_op_report_di.sv"
add_fileset_file "dspba_library_ver.sv" SYSTEM_VERILOG PATH "./ip/linux64/lib/dspba/Libraries/sv/base/dspba_library_ver.sv"
add_fileset_file "acl_ecc_pkg.sv" SYSTEM_VERILOG PATH "./ip/acl_ecc_pkg.sv"
add_fileset_file "acl_data_fifo.sv" SYSTEM_VERILOG PATH "./ip/acl_data_fifo.sv"
add_fileset_file "acl_fifo.sv" SYSTEM_VERILOG PATH "./ip/acl_fifo.sv"
add_fileset_file "acl_altera_syncram_wrapped.sv" SYSTEM_VERILOG PATH "./ip/acl_altera_syncram_wrapped.sv"
add_fileset_file "acl_scfifo_wrapped.sv" SYSTEM_VERILOG PATH "./ip/acl_scfifo_wrapped.sv"
add_fileset_file "acl_ecc_decoder.sv" SYSTEM_VERILOG PATH "./ip/acl_ecc_decoder.sv"
add_fileset_file "acl_ecc_encoder.sv" SYSTEM_VERILOG PATH "./ip/acl_ecc_encoder.sv"
add_fileset_file "acl_ll_fifo.sv" SYSTEM_VERILOG PATH "./ip/acl_ll_fifo.sv"
add_fileset_file "acl_ll_ram_fifo.sv" SYSTEM_VERILOG PATH "./ip/acl_ll_ram_fifo.sv"
add_fileset_file "acl_valid_fifo_counter.sv" SYSTEM_VERILOG PATH "./ip/acl_valid_fifo_counter.sv"
add_fileset_file "acl_dspba_valid_fifo_counter.sv" SYSTEM_VERILOG PATH "./ip/acl_dspba_valid_fifo_counter.sv"
add_fileset_file "acl_staging_reg.sv" SYSTEM_VERILOG PATH "./ip/acl_staging_reg.sv"
add_fileset_file "hld_fifo.sv" SYSTEM_VERILOG PATH "./ip/hld_fifo.sv"
add_fileset_file "acl_mid_speed_fifo.sv" SYSTEM_VERILOG PATH "./ip/acl_mid_speed_fifo.sv"
add_fileset_file "acl_latency_one_ram_fifo.sv" SYSTEM_VERILOG PATH "./ip/acl_latency_one_ram_fifo.sv"
add_fileset_file "acl_latency_zero_ram_fifo.sv" SYSTEM_VERILOG PATH "./ip/acl_latency_zero_ram_fifo.sv"
add_fileset_file "hld_fifo_zero_width.sv" SYSTEM_VERILOG PATH "./ip/hld_fifo_zero_width.sv"
add_fileset_file "acl_high_speed_fifo.sv" SYSTEM_VERILOG PATH "./ip/acl_high_speed_fifo.sv"
add_fileset_file "acl_low_latency_fifo.sv" SYSTEM_VERILOG PATH "./ip/acl_low_latency_fifo.sv"
add_fileset_file "acl_zero_latency_fifo.sv" SYSTEM_VERILOG PATH "./ip/acl_zero_latency_fifo.sv"
add_fileset_file "acl_fanout_pipeline.sv" SYSTEM_VERILOG PATH "./ip/acl_fanout_pipeline.sv"
add_fileset_file "acl_std_synchronizer_nocut.sv" SYSTEM_VERILOG PATH "./ip/acl_std_synchronizer_nocut.sv"
add_fileset_file "acl_tessellated_incr_decr_threshold.sv" SYSTEM_VERILOG PATH "./ip/acl_tessellated_incr_decr_threshold.sv"
add_fileset_file "acl_tessellated_incr_lookahead.sv" SYSTEM_VERILOG PATH "./ip/acl_tessellated_incr_lookahead.sv"
add_fileset_file "acl_reset_handler.sv" SYSTEM_VERILOG PATH "./ip/acl_reset_handler.sv"
add_fileset_file "acl_lfsr.sv" SYSTEM_VERILOG PATH "./ip/acl_lfsr.sv"
add_fileset_file "acl_mlab_fifo.sv" SYSTEM_VERILOG PATH "./ip/acl_mlab_fifo.sv"
add_fileset_file "acl_parameter_assert.svh" SYSTEM_VERILOG PATH "./ip/acl_parameter_assert.svh"
add_fileset_file "acl_dspba_buffer.sv" SYSTEM_VERILOG PATH "./ip/acl_dspba_buffer.sv"
add_fileset_file "hld_memory_depth_quantization_pkg.sv" SYSTEM_VERILOG PATH "./ip/hld_memory_depth_quantization_pkg.sv"
add_fileset_file "acl_shift_register_no_reset.sv" SYSTEM_VERILOG PATH "./ip/acl_shift_register_no_reset.sv"
add_fileset_file "hld_iowr.sv" SYSTEM_VERILOG PATH "./ip/hld_iowr.sv"
add_fileset_file "hld_iowr_stall_latency.sv" SYSTEM_VERILOG PATH "./ip/hld_iowr_stall_latency.sv"
add_fileset_file "hld_iowr_stall_valid.sv" SYSTEM_VERILOG PATH "./ip/hld_iowr_stall_valid.sv"
add_fileset_file "acl_full_detector.sv" SYSTEM_VERILOG PATH "./ip/acl_full_detector.sv"
add_fileset_file "acl_tessellated_incr_decr_decr.sv" SYSTEM_VERILOG PATH "./ip/acl_tessellated_incr_decr_decr.sv"
add_fileset_file "acl_sync.sv" SYSTEM_VERILOG PATH "./ip/acl_sync.sv"
add_fileset_file "hld_sim_latency_tracker.sv" SYSTEM_VERILOG PATH "./ip/hld_sim_latency_tracker.sv"
add_fileset_file "IDQualVecOp_function_wrapper.sv" SYSTEM_VERILOG PATH "./kernel_hdl/IDQualVecOp/IDQualVecOp_function_wrapper.sv"
add_fileset_file "IDQualVecOp_function.sv" SYSTEM_VERILOG PATH "./kernel_hdl/IDQualVecOp/IDQualVecOp_function.sv"
add_fileset_file "IDQualVecOp_bb_B0.sv" SYSTEM_VERILOG PATH "./kernel_hdl/IDQualVecOp/IDQualVecOp_bb_B0.sv"
add_fileset_file "IDQualVecOp_B0_branch.sv" SYSTEM_VERILOG PATH "./kernel_hdl/IDQualVecOp/IDQualVecOp_B0_branch.sv"
add_fileset_file "IDQualVecOp_B0_branch_branch_storage.sv" SYSTEM_VERILOG PATH "./kernel_hdl/IDQualVecOp/IDQualVecOp_B0_branch_branch_storage.sv"
add_fileset_file "IDQualVecOp_B0_merge.sv" SYSTEM_VERILOG PATH "./kernel_hdl/IDQualVecOp/IDQualVecOp_B0_merge.sv"
add_fileset_file "IDQualVecOp_B0_merge_storage.sv" SYSTEM_VERILOG PATH "./kernel_hdl/IDQualVecOp/IDQualVecOp_B0_merge_storage.sv"
add_fileset_file "IDQualVecOp_bb_B0_stall_region.sv" SYSTEM_VERILOG PATH "./kernel_hdl/IDQualVecOp/IDQualVecOp_bb_B0_stall_region.sv"
add_fileset_file "IDQualVecOp_i_sfc_s_c0_in_entry_idqualve0000r_idqualvecop_35_0gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/IDQualVecOp/IDQualVecOp_i_sfc_s_c0_in_entry_idqualve0000r_idqualvecop_35_0gr.sv"
add_fileset_file "IDQualVecOp_i_llvm_fpga_sfc_exit_s_c0_in0000_idqualvecop_177_0gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/IDQualVecOp/IDQualVecOp_i_llvm_fpga_sfc_exit_s_c0_in0000_idqualvecop_177_0gr.sv"
add_fileset_file "IDQualVecOp_i_llvm_fpga_sfc_exit_s_c0_in000040_1gr_full_detector.sv" SYSTEM_VERILOG PATH "./kernel_hdl/IDQualVecOp/IDQualVecOp_i_llvm_fpga_sfc_exit_s_c0_in000040_1gr_full_detector.sv"
add_fileset_file "IDQualVecOp_i_llvm_fpga_sfc_exit_s_c0_in0000op_177_1gr_data_fifo.sv" SYSTEM_VERILOG PATH "./kernel_hdl/IDQualVecOp/IDQualVecOp_i_llvm_fpga_sfc_exit_s_c0_in0000op_177_1gr_data_fifo.sv"
add_fileset_file "IDQualVecOp_i_sfc_logic_s_c0_in_entry_id0000r_idqualvecop_40_0gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/IDQualVecOp/IDQualVecOp_i_sfc_logic_s_c0_in_entry_id0000r_idqualvecop_40_0gr.sv"
add_fileset_file "IDQualVecOp_i_io_full_acl_c_resultpipeid0000_idqualvecop_164_0gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/IDQualVecOp/IDQualVecOp_i_io_full_acl_c_resultpipeid0000_idqualvecop_164_0gr.sv"
add_fileset_file "IDQualVecOp_i_iowr_nb_acl_c_resultpipeid0000_idqualvecop_168_0gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/IDQualVecOp/IDQualVecOp_i_iowr_nb_acl_c_resultpipeid0000_idqualvecop_168_0gr.sv"
add_fileset_file "IDQualVecOp_i_llvm_fpga_sync_buffer_i32_00001_idqualvecop_80_0gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/IDQualVecOp/IDQualVecOp_i_llvm_fpga_sync_buffer_i32_00001_idqualvecop_80_0gr.sv"
add_fileset_file "IDQualVecOp_i_llvm_fpga_sync_buffer_i32_00002_idqualvecop_93_0gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/IDQualVecOp/IDQualVecOp_i_llvm_fpga_sync_buffer_i32_00002_idqualvecop_93_0gr.sv"
add_fileset_file "IDQualVecOp_i_llvm_fpga_sync_buffer_i32_0000_idqualvecop_106_0gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/IDQualVecOp/IDQualVecOp_i_llvm_fpga_sync_buffer_i32_0000_idqualvecop_106_0gr.sv"
add_fileset_file "IDQualVecOp_i_llvm_fpga_sync_buffer_i32_0000_idqualvecop_119_0gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/IDQualVecOp/IDQualVecOp_i_llvm_fpga_sync_buffer_i32_0000_idqualvecop_119_0gr.sv"
add_fileset_file "IDQualVecOp_i_llvm_fpga_sync_buffer_i32_0000_idqualvecop_132_0gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/IDQualVecOp/IDQualVecOp_i_llvm_fpga_sync_buffer_i32_0000_idqualvecop_132_0gr.sv"
add_fileset_file "IDQualVecOp_i_llvm_fpga_sync_buffer_i32_0000_idqualvecop_145_0gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/IDQualVecOp/IDQualVecOp_i_llvm_fpga_sync_buffer_i32_0000_idqualvecop_145_0gr.sv"
add_fileset_file "IDQualVecOp_i_llvm_fpga_sync_buffer_i32_00007_idqualvecop_55_0gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/IDQualVecOp/IDQualVecOp_i_llvm_fpga_sync_buffer_i32_00007_idqualvecop_55_0gr.sv"
add_fileset_file "IDQualVecOp_i_llvm_fpga_sync_buffer_i32_0000r_idqualvecop_67_0gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/IDQualVecOp/IDQualVecOp_i_llvm_fpga_sync_buffer_i32_0000r_idqualvecop_67_0gr.sv"
add_fileset_file "IDQualVecOp_i_llvm_fpga_sync_buffer_i32_00000_idqualvecop_99_0gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/IDQualVecOp/IDQualVecOp_i_llvm_fpga_sync_buffer_i32_00000_idqualvecop_99_0gr.sv"
add_fileset_file "IDQualVecOp_i_llvm_fpga_sync_buffer_i32_0000_idqualvecop_112_0gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/IDQualVecOp/IDQualVecOp_i_llvm_fpga_sync_buffer_i32_0000_idqualvecop_112_0gr.sv"
add_fileset_file "IDQualVecOp_i_llvm_fpga_sync_buffer_i32_0000_idqualvecop_125_0gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/IDQualVecOp/IDQualVecOp_i_llvm_fpga_sync_buffer_i32_0000_idqualvecop_125_0gr.sv"
add_fileset_file "IDQualVecOp_i_llvm_fpga_sync_buffer_i32_0000_idqualvecop_138_0gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/IDQualVecOp/IDQualVecOp_i_llvm_fpga_sync_buffer_i32_0000_idqualvecop_138_0gr.sv"
add_fileset_file "IDQualVecOp_i_llvm_fpga_sync_buffer_i32_0000_idqualvecop_151_0gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/IDQualVecOp/IDQualVecOp_i_llvm_fpga_sync_buffer_i32_0000_idqualvecop_151_0gr.sv"
add_fileset_file "IDQualVecOp_i_llvm_fpga_sync_buffer_i32_00008_idqualvecop_73_0gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/IDQualVecOp/IDQualVecOp_i_llvm_fpga_sync_buffer_i32_00008_idqualvecop_73_0gr.sv"
add_fileset_file "IDQualVecOp_i_llvm_fpga_sync_buffer_i32_00009_idqualvecop_86_0gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/IDQualVecOp/IDQualVecOp_i_llvm_fpga_sync_buffer_i32_00009_idqualvecop_86_0gr.sv"
add_fileset_file "IDQualVecOp_i_llvm_fpga_sync_buffer_i32_0000r_idqualvecop_60_0gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/IDQualVecOp/IDQualVecOp_i_llvm_fpga_sync_buffer_i32_0000r_idqualvecop_60_0gr.sv"
add_fileset_file "IDQualVecOp_i_llvm_fpga_sync_buffer_i32_0000r_idqualvecop_47_0gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/IDQualVecOp/IDQualVecOp_i_llvm_fpga_sync_buffer_i32_0000r_idqualvecop_47_0gr.sv"
add_fileset_file "IDQualVecOp_function_cra_agent.sv" SYSTEM_VERILOG PATH "./kernel_hdl/IDQualVecOp/IDQualVecOp_function_cra_agent.sv"
add_fileset_file "acl_start_signal_chain_element.sv" SYSTEM_VERILOG PATH "./ip/acl_start_signal_chain_element.sv"
add_fileset_file "acl_task_copy_finish_detector.sv" SYSTEM_VERILOG PATH "./ip/acl_task_copy_finish_detector.sv"
add_fileset_file "acl_finish_signal_chain_element.sv" SYSTEM_VERILOG PATH "./ip/acl_finish_signal_chain_element.sv"
add_fileset_file "acl_reset_handler.sv" SYSTEM_VERILOG PATH "./ip/acl_reset_handler.sv"
add_fileset_file "acl_fanout_pipeline.sv" SYSTEM_VERILOG PATH "./ip/acl_fanout_pipeline.sv"
add_fileset_file "acl_std_synchronizer_nocut.sv" SYSTEM_VERILOG PATH "./ip/acl_std_synchronizer_nocut.sv"
add_fileset_file "cra_ring_node.sv" SYSTEM_VERILOG PATH "./ip/cra_ring_node.sv"
add_fileset_file "cra_ring_root.sv" SYSTEM_VERILOG PATH "./ip/cra_ring_root.sv"
add_fileset_file "cra_ring_rom.sv" SYSTEM_VERILOG PATH "./ip/cra_ring_rom.sv"
add_fileset_file "acl_ecc_pkg.sv" SYSTEM_VERILOG PATH "./ip/acl_ecc_pkg.sv"
add_fileset_file "acl_rom_module.sv" SYSTEM_VERILOG PATH "./ip/acl_rom_module.sv"
add_fileset_file "acl_clock_enable_gating.sv" SYSTEM_VERILOG PATH "./ip/acl_clock_enable_gating.sv"
add_fileset_file "acl_altera_syncram_wrapped.sv" SYSTEM_VERILOG PATH "./ip/acl_altera_syncram_wrapped.sv"
add_fileset_file "acl_ecc_encoder.sv" SYSTEM_VERILOG PATH "./ip/acl_ecc_encoder.sv"
add_fileset_file "acl_ecc_decoder.sv" SYSTEM_VERILOG PATH "./ip/acl_ecc_decoder.sv"
#### Simulation fileset
add_fileset SIM_VERILOG SIM_VERILOG "" ""
set_fileset_property SIM_VERILOG TOP_LEVEL qual_vec_op_report_di
set_fileset_property SIM_VERILOG ENABLE_RELATIVE_INCLUDE_PATHS false
add_fileset_file "qual_vec_op_report_di.sv" SYSTEM_VERILOG PATH "./qual_vec_op_report_di.sv"
add_fileset_file "dspba_library_ver.sv" SYSTEM_VERILOG PATH "./ip/linux64/lib/dspba/Libraries/sv/base/dspba_library_ver.sv"
add_fileset_file "acl_ecc_pkg.sv" SYSTEM_VERILOG PATH "./ip/acl_ecc_pkg.sv"
add_fileset_file "acl_data_fifo.sv" SYSTEM_VERILOG PATH "./ip/acl_data_fifo.sv"
add_fileset_file "acl_fifo.sv" SYSTEM_VERILOG PATH "./ip/acl_fifo.sv"
add_fileset_file "acl_altera_syncram_wrapped.sv" SYSTEM_VERILOG PATH "./ip/acl_altera_syncram_wrapped.sv"
add_fileset_file "acl_scfifo_wrapped.sv" SYSTEM_VERILOG PATH "./ip/acl_scfifo_wrapped.sv"
add_fileset_file "acl_ecc_decoder.sv" SYSTEM_VERILOG PATH "./ip/acl_ecc_decoder.sv"
add_fileset_file "acl_ecc_encoder.sv" SYSTEM_VERILOG PATH "./ip/acl_ecc_encoder.sv"
add_fileset_file "acl_ll_fifo.sv" SYSTEM_VERILOG PATH "./ip/acl_ll_fifo.sv"
add_fileset_file "acl_ll_ram_fifo.sv" SYSTEM_VERILOG PATH "./ip/acl_ll_ram_fifo.sv"
add_fileset_file "acl_valid_fifo_counter.sv" SYSTEM_VERILOG PATH "./ip/acl_valid_fifo_counter.sv"
add_fileset_file "acl_dspba_valid_fifo_counter.sv" SYSTEM_VERILOG PATH "./ip/acl_dspba_valid_fifo_counter.sv"
add_fileset_file "acl_staging_reg.sv" SYSTEM_VERILOG PATH "./ip/acl_staging_reg.sv"
add_fileset_file "hld_fifo.sv" SYSTEM_VERILOG PATH "./ip/hld_fifo.sv"
add_fileset_file "acl_mid_speed_fifo.sv" SYSTEM_VERILOG PATH "./ip/acl_mid_speed_fifo.sv"
add_fileset_file "acl_latency_one_ram_fifo.sv" SYSTEM_VERILOG PATH "./ip/acl_latency_one_ram_fifo.sv"
add_fileset_file "acl_latency_zero_ram_fifo.sv" SYSTEM_VERILOG PATH "./ip/acl_latency_zero_ram_fifo.sv"
add_fileset_file "hld_fifo_zero_width.sv" SYSTEM_VERILOG PATH "./ip/hld_fifo_zero_width.sv"
add_fileset_file "acl_high_speed_fifo.sv" SYSTEM_VERILOG PATH "./ip/acl_high_speed_fifo.sv"
add_fileset_file "acl_low_latency_fifo.sv" SYSTEM_VERILOG PATH "./ip/acl_low_latency_fifo.sv"
add_fileset_file "acl_zero_latency_fifo.sv" SYSTEM_VERILOG PATH "./ip/acl_zero_latency_fifo.sv"
add_fileset_file "acl_fanout_pipeline.sv" SYSTEM_VERILOG PATH "./ip/acl_fanout_pipeline.sv"
add_fileset_file "acl_std_synchronizer_nocut.sv" SYSTEM_VERILOG PATH "./ip/acl_std_synchronizer_nocut.sv"
add_fileset_file "acl_tessellated_incr_decr_threshold.sv" SYSTEM_VERILOG PATH "./ip/acl_tessellated_incr_decr_threshold.sv"
add_fileset_file "acl_tessellated_incr_lookahead.sv" SYSTEM_VERILOG PATH "./ip/acl_tessellated_incr_lookahead.sv"
add_fileset_file "acl_reset_handler.sv" SYSTEM_VERILOG PATH "./ip/acl_reset_handler.sv"
add_fileset_file "acl_lfsr.sv" SYSTEM_VERILOG PATH "./ip/acl_lfsr.sv"
add_fileset_file "acl_mlab_fifo.sv" SYSTEM_VERILOG PATH "./ip/acl_mlab_fifo.sv"
add_fileset_file "acl_parameter_assert.svh" SYSTEM_VERILOG PATH "./ip/acl_parameter_assert.svh"
add_fileset_file "acl_dspba_buffer.sv" SYSTEM_VERILOG PATH "./ip/acl_dspba_buffer.sv"
add_fileset_file "hld_memory_depth_quantization_pkg.sv" SYSTEM_VERILOG PATH "./ip/hld_memory_depth_quantization_pkg.sv"
add_fileset_file "acl_shift_register_no_reset.sv" SYSTEM_VERILOG PATH "./ip/acl_shift_register_no_reset.sv"
add_fileset_file "hld_iowr.sv" SYSTEM_VERILOG PATH "./ip/hld_iowr.sv"
add_fileset_file "hld_iowr_stall_latency.sv" SYSTEM_VERILOG PATH "./ip/hld_iowr_stall_latency.sv"
add_fileset_file "hld_iowr_stall_valid.sv" SYSTEM_VERILOG PATH "./ip/hld_iowr_stall_valid.sv"
add_fileset_file "acl_full_detector.sv" SYSTEM_VERILOG PATH "./ip/acl_full_detector.sv"
add_fileset_file "acl_tessellated_incr_decr_decr.sv" SYSTEM_VERILOG PATH "./ip/acl_tessellated_incr_decr_decr.sv"
add_fileset_file "acl_sync.sv" SYSTEM_VERILOG PATH "./ip/acl_sync.sv"
add_fileset_file "hld_sim_latency_tracker.sv" SYSTEM_VERILOG PATH "./ip/hld_sim_latency_tracker.sv"
add_fileset_file "IDQualVecOp_function_wrapper.sv" SYSTEM_VERILOG PATH "./kernel_hdl/IDQualVecOp/IDQualVecOp_function_wrapper.sv"
add_fileset_file "IDQualVecOp_function.sv" SYSTEM_VERILOG PATH "./kernel_hdl/IDQualVecOp/IDQualVecOp_function.sv"
add_fileset_file "IDQualVecOp_bb_B0.sv" SYSTEM_VERILOG PATH "./kernel_hdl/IDQualVecOp/IDQualVecOp_bb_B0.sv"
add_fileset_file "IDQualVecOp_B0_branch.sv" SYSTEM_VERILOG PATH "./kernel_hdl/IDQualVecOp/IDQualVecOp_B0_branch.sv"
add_fileset_file "IDQualVecOp_B0_branch_branch_storage.sv" SYSTEM_VERILOG PATH "./kernel_hdl/IDQualVecOp/IDQualVecOp_B0_branch_branch_storage.sv"
add_fileset_file "IDQualVecOp_B0_merge.sv" SYSTEM_VERILOG PATH "./kernel_hdl/IDQualVecOp/IDQualVecOp_B0_merge.sv"
add_fileset_file "IDQualVecOp_B0_merge_storage.sv" SYSTEM_VERILOG PATH "./kernel_hdl/IDQualVecOp/IDQualVecOp_B0_merge_storage.sv"
add_fileset_file "IDQualVecOp_bb_B0_stall_region.sv" SYSTEM_VERILOG PATH "./kernel_hdl/IDQualVecOp/IDQualVecOp_bb_B0_stall_region.sv"
add_fileset_file "IDQualVecOp_i_sfc_s_c0_in_entry_idqualve0000r_idqualvecop_35_0gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/IDQualVecOp/IDQualVecOp_i_sfc_s_c0_in_entry_idqualve0000r_idqualvecop_35_0gr.sv"
add_fileset_file "IDQualVecOp_i_llvm_fpga_sfc_exit_s_c0_in0000_idqualvecop_177_0gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/IDQualVecOp/IDQualVecOp_i_llvm_fpga_sfc_exit_s_c0_in0000_idqualvecop_177_0gr.sv"
add_fileset_file "IDQualVecOp_i_llvm_fpga_sfc_exit_s_c0_in000040_1gr_full_detector.sv" SYSTEM_VERILOG PATH "./kernel_hdl/IDQualVecOp/IDQualVecOp_i_llvm_fpga_sfc_exit_s_c0_in000040_1gr_full_detector.sv"
add_fileset_file "IDQualVecOp_i_llvm_fpga_sfc_exit_s_c0_in0000op_177_1gr_data_fifo.sv" SYSTEM_VERILOG PATH "./kernel_hdl/IDQualVecOp/IDQualVecOp_i_llvm_fpga_sfc_exit_s_c0_in0000op_177_1gr_data_fifo.sv"
add_fileset_file "IDQualVecOp_i_sfc_logic_s_c0_in_entry_id0000r_idqualvecop_40_0gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/IDQualVecOp/IDQualVecOp_i_sfc_logic_s_c0_in_entry_id0000r_idqualvecop_40_0gr.sv"
add_fileset_file "IDQualVecOp_i_io_full_acl_c_resultpipeid0000_idqualvecop_164_0gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/IDQualVecOp/IDQualVecOp_i_io_full_acl_c_resultpipeid0000_idqualvecop_164_0gr.sv"
add_fileset_file "IDQualVecOp_i_iowr_nb_acl_c_resultpipeid0000_idqualvecop_168_0gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/IDQualVecOp/IDQualVecOp_i_iowr_nb_acl_c_resultpipeid0000_idqualvecop_168_0gr.sv"
add_fileset_file "IDQualVecOp_i_llvm_fpga_sync_buffer_i32_00001_idqualvecop_80_0gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/IDQualVecOp/IDQualVecOp_i_llvm_fpga_sync_buffer_i32_00001_idqualvecop_80_0gr.sv"
add_fileset_file "IDQualVecOp_i_llvm_fpga_sync_buffer_i32_00002_idqualvecop_93_0gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/IDQualVecOp/IDQualVecOp_i_llvm_fpga_sync_buffer_i32_00002_idqualvecop_93_0gr.sv"
add_fileset_file "IDQualVecOp_i_llvm_fpga_sync_buffer_i32_0000_idqualvecop_106_0gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/IDQualVecOp/IDQualVecOp_i_llvm_fpga_sync_buffer_i32_0000_idqualvecop_106_0gr.sv"
add_fileset_file "IDQualVecOp_i_llvm_fpga_sync_buffer_i32_0000_idqualvecop_119_0gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/IDQualVecOp/IDQualVecOp_i_llvm_fpga_sync_buffer_i32_0000_idqualvecop_119_0gr.sv"
add_fileset_file "IDQualVecOp_i_llvm_fpga_sync_buffer_i32_0000_idqualvecop_132_0gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/IDQualVecOp/IDQualVecOp_i_llvm_fpga_sync_buffer_i32_0000_idqualvecop_132_0gr.sv"
add_fileset_file "IDQualVecOp_i_llvm_fpga_sync_buffer_i32_0000_idqualvecop_145_0gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/IDQualVecOp/IDQualVecOp_i_llvm_fpga_sync_buffer_i32_0000_idqualvecop_145_0gr.sv"
add_fileset_file "IDQualVecOp_i_llvm_fpga_sync_buffer_i32_00007_idqualvecop_55_0gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/IDQualVecOp/IDQualVecOp_i_llvm_fpga_sync_buffer_i32_00007_idqualvecop_55_0gr.sv"
add_fileset_file "IDQualVecOp_i_llvm_fpga_sync_buffer_i32_0000r_idqualvecop_67_0gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/IDQualVecOp/IDQualVecOp_i_llvm_fpga_sync_buffer_i32_0000r_idqualvecop_67_0gr.sv"
add_fileset_file "IDQualVecOp_i_llvm_fpga_sync_buffer_i32_00000_idqualvecop_99_0gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/IDQualVecOp/IDQualVecOp_i_llvm_fpga_sync_buffer_i32_00000_idqualvecop_99_0gr.sv"
add_fileset_file "IDQualVecOp_i_llvm_fpga_sync_buffer_i32_0000_idqualvecop_112_0gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/IDQualVecOp/IDQualVecOp_i_llvm_fpga_sync_buffer_i32_0000_idqualvecop_112_0gr.sv"
add_fileset_file "IDQualVecOp_i_llvm_fpga_sync_buffer_i32_0000_idqualvecop_125_0gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/IDQualVecOp/IDQualVecOp_i_llvm_fpga_sync_buffer_i32_0000_idqualvecop_125_0gr.sv"
add_fileset_file "IDQualVecOp_i_llvm_fpga_sync_buffer_i32_0000_idqualvecop_138_0gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/IDQualVecOp/IDQualVecOp_i_llvm_fpga_sync_buffer_i32_0000_idqualvecop_138_0gr.sv"
add_fileset_file "IDQualVecOp_i_llvm_fpga_sync_buffer_i32_0000_idqualvecop_151_0gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/IDQualVecOp/IDQualVecOp_i_llvm_fpga_sync_buffer_i32_0000_idqualvecop_151_0gr.sv"
add_fileset_file "IDQualVecOp_i_llvm_fpga_sync_buffer_i32_00008_idqualvecop_73_0gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/IDQualVecOp/IDQualVecOp_i_llvm_fpga_sync_buffer_i32_00008_idqualvecop_73_0gr.sv"
add_fileset_file "IDQualVecOp_i_llvm_fpga_sync_buffer_i32_00009_idqualvecop_86_0gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/IDQualVecOp/IDQualVecOp_i_llvm_fpga_sync_buffer_i32_00009_idqualvecop_86_0gr.sv"
add_fileset_file "IDQualVecOp_i_llvm_fpga_sync_buffer_i32_0000r_idqualvecop_60_0gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/IDQualVecOp/IDQualVecOp_i_llvm_fpga_sync_buffer_i32_0000r_idqualvecop_60_0gr.sv"
add_fileset_file "IDQualVecOp_i_llvm_fpga_sync_buffer_i32_0000r_idqualvecop_47_0gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/IDQualVecOp/IDQualVecOp_i_llvm_fpga_sync_buffer_i32_0000r_idqualvecop_47_0gr.sv"
add_fileset_file "IDQualVecOp_function_cra_agent.sv" SYSTEM_VERILOG PATH "./kernel_hdl/IDQualVecOp/IDQualVecOp_function_cra_agent.sv"
add_fileset_file "acl_start_signal_chain_element.sv" SYSTEM_VERILOG PATH "./ip/acl_start_signal_chain_element.sv"
add_fileset_file "acl_task_copy_finish_detector.sv" SYSTEM_VERILOG PATH "./ip/acl_task_copy_finish_detector.sv"
add_fileset_file "acl_finish_signal_chain_element.sv" SYSTEM_VERILOG PATH "./ip/acl_finish_signal_chain_element.sv"
add_fileset_file "acl_reset_handler.sv" SYSTEM_VERILOG PATH "./ip/acl_reset_handler.sv"
add_fileset_file "acl_fanout_pipeline.sv" SYSTEM_VERILOG PATH "./ip/acl_fanout_pipeline.sv"
add_fileset_file "acl_std_synchronizer_nocut.sv" SYSTEM_VERILOG PATH "./ip/acl_std_synchronizer_nocut.sv"
add_fileset_file "cra_ring_node.sv" SYSTEM_VERILOG PATH "./ip/cra_ring_node.sv"
add_fileset_file "cra_ring_root.sv" SYSTEM_VERILOG PATH "./ip/cra_ring_root.sv"
add_fileset_file "cra_ring_rom.sv" SYSTEM_VERILOG PATH "./ip/cra_ring_rom.sv"
add_fileset_file "acl_ecc_pkg.sv" SYSTEM_VERILOG PATH "./ip/acl_ecc_pkg.sv"
add_fileset_file "acl_rom_module.sv" SYSTEM_VERILOG PATH "./ip/acl_rom_module.sv"
add_fileset_file "acl_clock_enable_gating.sv" SYSTEM_VERILOG PATH "./ip/acl_clock_enable_gating.sv"
add_fileset_file "acl_altera_syncram_wrapped.sv" SYSTEM_VERILOG PATH "./ip/acl_altera_syncram_wrapped.sv"
add_fileset_file "acl_ecc_encoder.sv" SYSTEM_VERILOG PATH "./ip/acl_ecc_encoder.sv"
add_fileset_file "acl_ecc_decoder.sv" SYSTEM_VERILOG PATH "./ip/acl_ecc_decoder.sv"
#### Primary clock for the component
add_interface clock clock end
set_interface_property clock ENABLED true
add_interface_port clock clock clk input 1

#### resetn
add_interface resetn reset end
set_interface_property resetn associatedClock clock
set_interface_property resetn synchronousEdges BOTH
add_interface_port resetn resetn reset_n input 1

####  freeze
add_interface freeze conduit end
set_interface_property freeze ENABLED true
add_interface_port freeze freeze freeze input 1

####  device_exception_bus
add_interface device_exception_bus conduit end
set_interface_property device_exception_bus ENABLED true
set_interface_property device_exception_bus associatedClock clock
set_interface_property device_exception_bus associatedReset resetn
add_interface_port device_exception_bus device_exception_bus data output 64

#### IRQ interfaces kernel_irqs
add_interface kernel_irqs interrupt end
set_interface_property kernel_irqs ENABLED true
set_interface_property kernel_irqs associatedClock clock
add_interface_port kernel_irqs kernel_irqs irq output 1

#### Agent interface csr_ring_root_avs
add_interface csr_ring_root_avs avalon end
set_interface_property csr_ring_root_avs ENABLED true
set_interface_property csr_ring_root_avs associatedClock clock
set_interface_property csr_ring_root_avs associatedReset resetn
set_interface_property csr_ring_root_avs addressAlignment DYNAMIC
set_interface_property csr_ring_root_avs burstOnBurstBoundariesOnly false
set_interface_property csr_ring_root_avs explicitAddressSpan 0
set_interface_property csr_ring_root_avs holdTime 0
set_interface_property csr_ring_root_avs isMemoryDevice false
set_interface_property csr_ring_root_avs isNonVolatileStorage false
set_interface_property csr_ring_root_avs linewrapBursts false
set_interface_property csr_ring_root_avs maximumPendingReadTransactions 1
set_interface_property csr_ring_root_avs readLatency 0
set_interface_property csr_ring_root_avs readWaitTime 0
set_interface_property csr_ring_root_avs printableDevice false
set_interface_property csr_ring_root_avs setupTime 0
set_interface_property csr_ring_root_avs timingUnits Cycles
set_interface_property csr_ring_root_avs writeWaitTime 0
set_interface_assignment csr_ring_root_avs hls.cosim.name {}
add_interface_port csr_ring_root_avs csr_ring_root_avs_read read input 1
add_interface_port csr_ring_root_avs csr_ring_root_avs_readdata readdata output 64
add_interface_port csr_ring_root_avs csr_ring_root_avs_readdatavalid readdatavalid output 1
add_interface_port csr_ring_root_avs csr_ring_root_avs_write write input 1
add_interface_port csr_ring_root_avs csr_ring_root_avs_writedata writedata input 64
add_interface_port csr_ring_root_avs csr_ring_root_avs_address address input 5
add_interface_port csr_ring_root_avs csr_ring_root_avs_byteenable byteenable input 8
add_interface_port csr_ring_root_avs csr_ring_root_avs_waitrequest waitrequest output 1

#### Quartus settings (QIP strings)
set_qip_strings { "set_instance_assignment -entity \"%entityName%\" -library \"%libraryName%\" -name AUTO_SHIFT_REGISTER_RECOGNITION OFF -to *_NO_SHIFT_REG*"  }

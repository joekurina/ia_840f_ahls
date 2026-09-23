package require -exact qsys 15.0
set_module_property NAME mmhost_ia840f_report_di
set_module_property VERSION 1.0
set_module_property INTERNAL false
set_module_property GROUP oneAPI
set_module_property DISPLAY_NAME mmhost_ia840f_report_di
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property SUPPORTED_DEVICE_FAMILIES {"Agilex 7" "Agilex"}
#### Synthesis fileset
add_fileset QUARTUS_SYNTH QUARTUS_SYNTH "" ""
set_fileset_property QUARTUS_SYNTH TOP_LEVEL mmhost_ia840f_report_di
set_fileset_property QUARTUS_SYNTH ENABLE_RELATIVE_INCLUDE_PATHS false
add_fileset_file "mmhost_ia840f_report_di.sv" SYSTEM_VERILOG PATH "./mmhost_ia840f_report_di.sv"
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
add_fileset_file "acl_ffwdsrc.sv" SYSTEM_VERILOG PATH "./ip/acl_ffwdsrc.sv"
add_fileset_file "acl_full_detector.sv" SYSTEM_VERILOG PATH "./ip/acl_full_detector.sv"
add_fileset_file "acl_tessellated_incr_decr_decr.sv" SYSTEM_VERILOG PATH "./ip/acl_tessellated_incr_decr_decr.sv"
add_fileset_file "acl_sync.sv" SYSTEM_VERILOG PATH "./ip/acl_sync.sv"
add_fileset_file "acl_fast_pipeline.sv" SYSTEM_VERILOG PATH "./ip/acl_fast_pipeline.sv"
add_fileset_file "acl_ffwddst.sv" SYSTEM_VERILOG PATH "./ip/acl_ffwddst.sv"
add_fileset_file "acl_push.sv" SYSTEM_VERILOG PATH "./ip/acl_push.sv"
add_fileset_file "acl_token_fifo_counter.sv" SYSTEM_VERILOG PATH "./ip/acl_token_fifo_counter.sv"
add_fileset_file "acl_loop_admit.sv" SYSTEM_VERILOG PATH "./ip/acl_loop_admit.sv"
add_fileset_file "acl_shift_register_no_reset_dont_merge.sv" SYSTEM_VERILOG PATH "./ip/acl_shift_register_no_reset_dont_merge.sv"
add_fileset_file "lsu_top.sv" SYSTEM_VERILOG PATH "./ip/lsu_top.sv"
add_fileset_file "acl_has_pending_write.sv" SYSTEM_VERILOG PATH "./ip/acl_has_pending_write.sv"
add_fileset_file "lsu_permute_address.sv" SYSTEM_VERILOG PATH "./ip/lsu_permute_address.sv"
add_fileset_file "lsu_pipelined.sv" SYSTEM_VERILOG PATH "./ip/lsu_pipelined.sv"
add_fileset_file "lsu_enabled.sv" SYSTEM_VERILOG PATH "./ip/lsu_enabled.sv"
add_fileset_file "lsu_basic_coalescer.sv" SYSTEM_VERILOG PATH "./ip/lsu_basic_coalescer.sv"
add_fileset_file "lsu_simple.sv" SYSTEM_VERILOG PATH "./ip/lsu_simple.sv"
add_fileset_file "lsu_burst_host.sv" SYSTEM_VERILOG PATH "./ip/lsu_burst_host.sv"
add_fileset_file "lsu_bursting_load_stores.sv" SYSTEM_VERILOG PATH "./ip/lsu_bursting_load_stores.sv"
add_fileset_file "lsu_non_aligned_write.sv" SYSTEM_VERILOG PATH "./ip/lsu_non_aligned_write.sv"
add_fileset_file "lsu_read_cache.sv" SYSTEM_VERILOG PATH "./ip/lsu_read_cache.sv"
add_fileset_file "lsu_atomic.sv" SYSTEM_VERILOG PATH "./ip/lsu_atomic.sv"
add_fileset_file "lsu_prefetch_block.sv" SYSTEM_VERILOG PATH "./ip/lsu_prefetch_block.sv"
add_fileset_file "lsu_wide_wrapper.sv" SYSTEM_VERILOG PATH "./ip/lsu_wide_wrapper.sv"
add_fileset_file "lsu_streaming_prefetch.sv" SYSTEM_VERILOG PATH "./ip/lsu_streaming_prefetch.sv"
add_fileset_file "acl_aligned_burst_coalesced_lsu.sv" SYSTEM_VERILOG PATH "./ip/acl_aligned_burst_coalesced_lsu.sv"
add_fileset_file "acl_toggle_detect.sv" SYSTEM_VERILOG PATH "./ip/acl_toggle_detect.sv"
add_fileset_file "acl_debug_mem.sv" SYSTEM_VERILOG PATH "./ip/acl_debug_mem.sv"
add_fileset_file "lsu_burst_coalesced_pipelined_write.sv" SYSTEM_VERILOG PATH "./ip/lsu_burst_coalesced_pipelined_write.sv"
add_fileset_file "lsu_burst_coalesced_pipelined_read.sv" SYSTEM_VERILOG PATH "./ip/lsu_burst_coalesced_pipelined_read.sv"
add_fileset_file "acl_fifo_stall_valid_lookahead.sv" SYSTEM_VERILOG PATH "./ip/acl_fifo_stall_valid_lookahead.sv"
add_fileset_file "hld_global_load_store.sv" SYSTEM_VERILOG PATH "./ip/hld_global_load_store.sv"
add_fileset_file "hld_lsu.sv" SYSTEM_VERILOG PATH "./ip/hld_lsu.sv"
add_fileset_file "hld_lsu_burst_coalescer.sv" SYSTEM_VERILOG PATH "./ip/hld_lsu_burst_coalescer.sv"
add_fileset_file "hld_lsu_coalescer_dynamic_timeout.sv" SYSTEM_VERILOG PATH "./ip/hld_lsu_coalescer_dynamic_timeout.sv"
add_fileset_file "hld_lsu_data_aligner.sv" SYSTEM_VERILOG PATH "./ip/hld_lsu_data_aligner.sv"
add_fileset_file "hld_lsu_read_cache.sv" SYSTEM_VERILOG PATH "./ip/hld_lsu_read_cache.sv"
add_fileset_file "hld_lsu_read_data_alignment.sv" SYSTEM_VERILOG PATH "./ip/hld_lsu_read_data_alignment.sv"
add_fileset_file "hld_lsu_unaligned_controller.sv" SYSTEM_VERILOG PATH "./ip/hld_lsu_unaligned_controller.sv"
add_fileset_file "hld_lsu_word_coalescer.sv" SYSTEM_VERILOG PATH "./ip/hld_lsu_word_coalescer.sv"
add_fileset_file "hld_lsu_write_data_alignment.sv" SYSTEM_VERILOG PATH "./ip/hld_lsu_write_data_alignment.sv"
add_fileset_file "hld_lsu_write_kernel_downstream.sv" SYSTEM_VERILOG PATH "./ip/hld_lsu_write_kernel_downstream.sv"
add_fileset_file "acl_shift_register_no_reset.sv" SYSTEM_VERILOG PATH "./ip/acl_shift_register_no_reset.sv"
add_fileset_file "hld_loop_profiler.sv" SYSTEM_VERILOG PATH "./ip/hld_loop_profiler.sv"
add_fileset_file "hld_sim_latency_tracker.sv" SYSTEM_VERILOG PATH "./ip/hld_sim_latency_tracker.sv"
add_fileset_file "DDRIP_function_wrapper.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_function_wrapper.sv"
add_fileset_file "DDRIP_function.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_function.sv"
add_fileset_file "DDRIP_bb_B0.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_bb_B0.sv"
add_fileset_file "DDRIP_B0_branch.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_B0_branch.sv"
add_fileset_file "DDRIP_B0_merge.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_B0_merge.sv"
add_fileset_file "DDRIP_B0_merge_storage.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_B0_merge_storage.sv"
add_fileset_file "DDRIP_bb_B0_stall_region.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_bb_B0_stall_region.sv"
add_fileset_file "DDRIP_i_sfc_s_c0_in_entry_ddrips_c0_enter_ddrip_31_0gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_i_sfc_s_c0_in_entry_ddrips_c0_enter_ddrip_31_0gr.sv"
add_fileset_file "DDRIP_i_llvm_fpga_sfc_exit_s_c0_in_entry0000c0_exit_ddrip_58_0gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_i_llvm_fpga_sfc_exit_s_c0_in_entry0000c0_exit_ddrip_58_0gr.sv"
add_fileset_file "DDRIP_i_llvm_fpga_sfc_exit_s_c0_in_entry000036_1gr_full_detector.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_i_llvm_fpga_sfc_exit_s_c0_in_entry000036_1gr_full_detector.sv"
add_fileset_file "DDRIP_i_llvm_fpga_sfc_exit_s_c0_in_entry0000rip_58_1gr_data_fifo.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_i_llvm_fpga_sfc_exit_s_c0_in_entry0000rip_58_1gr_data_fifo.sv"
add_fileset_file "DDRIP_i_sfc_logic_s_c0_in_entry_ddrips_c0_enter_ddrip_36_0gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_i_sfc_logic_s_c0_in_entry_ddrips_c0_enter_ddrip_36_0gr.sv"
add_fileset_file "DDRIP_i_llvm_fpga_ffwd_source_i1_unnamed_ddrip1_ddrip_51_0gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_i_llvm_fpga_ffwd_source_i1_unnamed_ddrip1_ddrip_51_0gr.sv"
add_fileset_file "DDRIP_i_llvm_fpga_sync_buffer_i32_arg_si0000ffer150_ddrip_43_0gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_i_llvm_fpga_sync_buffer_i32_arg_si0000ffer150_ddrip_43_0gr.sv"
add_fileset_file "DDRIP_bb_B1.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_bb_B1.sv"
add_fileset_file "DDRIP_B1_branch.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_B1_branch.sv"
add_fileset_file "DDRIP_B1_merge.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_B1_merge.sv"
add_fileset_file "DDRIP_B1_merge_storage.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_B1_merge_storage.sv"
add_fileset_file "DDRIP_bb_B1_stall_region.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_bb_B1_stall_region.sv"
add_fileset_file "DDRIP_i_llvm_fpga_mem_memcoalesce_load_d0000ique_0_ddrip_329_0gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_i_llvm_fpga_mem_memcoalesce_load_d0000ique_0_ddrip_329_0gr.sv"
add_fileset_file "DDRIP_i_llvm_fpga_mem_memcoalesce_load_d0000ique_1_ddrip_405_0gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_i_llvm_fpga_mem_memcoalesce_load_d0000ique_1_ddrip_405_0gr.sv"
add_fileset_file "DDRIP_i_llvm_fpga_mem_memdep_ddrip_467_0gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_i_llvm_fpga_mem_memdep_ddrip_467_0gr.sv"
add_fileset_file "DDRIP_i_sfc_s_c0_in_for_body_i_ddrips_c0_enter1591_ddrip_83_1gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_i_sfc_s_c0_in_for_body_i_ddrips_c0_enter1591_ddrip_83_1gr.sv"
add_fileset_file "DDRIP_i_llvm_fpga_sfc_exit_s_c0_out_for_0000xit160_ddrip_298_0gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_i_llvm_fpga_sfc_exit_s_c0_out_for_0000xit160_ddrip_298_0gr.sv"
add_fileset_file "DDRIP_i_llvm_fpga_sfc_exit_s_c0_out_for_000090_1gr_full_detector.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_i_llvm_fpga_sfc_exit_s_c0_out_for_000090_1gr_full_detector.sv"
add_fileset_file "DDRIP_i_llvm_fpga_sfc_exit_s_c0_out_for_0000ip_298_1gr_data_fifo.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_i_llvm_fpga_sfc_exit_s_c0_out_for_0000ip_298_1gr_data_fifo.sv"
add_fileset_file "DDRIP_i_sfc_logic_s_c0_in_for_body_i_ddr0000ter1591_ddrip_90_0gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_i_sfc_logic_s_c0_in_for_body_i_ddr0000ter1591_ddrip_90_0gr.sv"
add_fileset_file "DDRIP_i_llvm_fpga_dummy_thread_ddrip_b1_dummy_ddrip_98_0gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_i_llvm_fpga_dummy_thread_ddrip_b1_dummy_ddrip_98_0gr.sv"
add_fileset_file "DDRIP_i_llvm_fpga_ffwd_dest_i1_cmp_i4158_ddrip_135_0gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_i_llvm_fpga_ffwd_dest_i1_cmp_i4158_ddrip_135_0gr.sv"
add_fileset_file "DDRIP_i_llvm_fpga_forked_ddrip_b1_forked_ddrip_106_0gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_i_llvm_fpga_forked_ddrip_b1_forked_ddrip_106_0gr.sv"
add_fileset_file "DDRIP_i_llvm_fpga_pipeline_keep_going_ddrip_119_0gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_i_llvm_fpga_pipeline_keep_going_ddrip_119_0gr.sv"
add_fileset_file "DDRIP_i_llvm_fpga_push_i1_notexitcond_ddrip_287_0gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_i_llvm_fpga_push_i1_notexitcond_ddrip_287_0gr.sv"
add_fileset_file "DDRIP_i_llvm_fpga_sync_buffer_i32_arg_si0000fer151_ddrip_173_0gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_i_llvm_fpga_sync_buffer_i32_arg_si0000fer151_ddrip_173_0gr.sv"
add_fileset_file "DDRIP_i_llvm_fpga_sync_buffer_i32_arg_si0000fer152_ddrip_184_0gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_i_llvm_fpga_sync_buffer_i32_arg_si0000fer152_ddrip_184_0gr.sv"
add_fileset_file "DDRIP_i_llvm_fpga_sync_buffer_i32_arg_si0000fer153_ddrip_195_0gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_i_llvm_fpga_sync_buffer_i32_arg_si0000fer153_ddrip_195_0gr.sv"
add_fileset_file "DDRIP_i_llvm_fpga_sync_buffer_i32_arg_si0000fer154_ddrip_206_0gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_i_llvm_fpga_sync_buffer_i32_arg_si0000fer154_ddrip_206_0gr.sv"
add_fileset_file "DDRIP_i_llvm_fpga_sync_buffer_i32_arg_si0000fer155_ddrip_217_0gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_i_llvm_fpga_sync_buffer_i32_arg_si0000fer155_ddrip_217_0gr.sv"
add_fileset_file "DDRIP_i_llvm_fpga_sync_buffer_i32_arg_si0000fer156_ddrip_228_0gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_i_llvm_fpga_sync_buffer_i32_arg_si0000fer156_ddrip_228_0gr.sv"
add_fileset_file "DDRIP_i_llvm_fpga_sync_buffer_i32_arg_si0000fer157_ddrip_267_0gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_i_llvm_fpga_sync_buffer_i32_arg_si0000fer157_ddrip_267_0gr.sv"
add_fileset_file "DDRIP_i_llvm_fpga_sync_buffer_i32_arg_si0000buffer_ddrip_163_0gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_i_llvm_fpga_sync_buffer_i32_arg_si0000buffer_ddrip_163_0gr.sv"
add_fileset_file "DDRIP_i_llvm_fpga_sync_buffer_p1024_arg_0000buffer_ddrip_148_0gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_i_llvm_fpga_sync_buffer_p1024_arg_0000buffer_ddrip_148_0gr.sv"
add_fileset_file "DDRIP_i_llvm_fpga_sync_buffer_p1024_arg_0000buffer_ddrip_238_0gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_i_llvm_fpga_sync_buffer_p1024_arg_0000buffer_ddrip_238_0gr.sv"
add_fileset_file "DDRIP_i_llvm_fpga_sync_buffer_p1025_arg_0000buffer_ddrip_252_0gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_i_llvm_fpga_sync_buffer_p1025_arg_0000buffer_ddrip_252_0gr.sv"
add_fileset_file "DDRIP_i_sfc_s_c1_in_for_body_i_ddrips_c1_enter_ddrip_83_7gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_i_sfc_s_c1_in_for_body_i_ddrips_c1_enter_ddrip_83_7gr.sv"
add_fileset_file "DDRIP_i_llvm_fpga_sfc_exit_s_c1_out_for_00001_exit_ddrip_397_0gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_i_llvm_fpga_sfc_exit_s_c1_out_for_00001_exit_ddrip_397_0gr.sv"
add_fileset_file "DDRIP_i_llvm_fpga_sfc_exit_s_c1_out_for_000061_1gr_full_detector.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_i_llvm_fpga_sfc_exit_s_c1_out_for_000061_1gr_full_detector.sv"
add_fileset_file "DDRIP_i_llvm_fpga_sfc_exit_s_c1_out_for_0000ip_397_1gr_data_fifo.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_i_llvm_fpga_sfc_exit_s_c1_out_for_0000ip_397_1gr_data_fifo.sv"
add_fileset_file "DDRIP_i_sfc_logic_s_c1_in_for_body_i_ddr0000_enter_ddrip_361_0gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_i_sfc_logic_s_c1_in_for_body_i_ddr0000_enter_ddrip_361_0gr.sv"
add_fileset_file "DDRIP_i_sfc_s_c2_in_for_body_i_ddrips_c2_enter_ddrip_83_11.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_i_sfc_s_c2_in_for_body_i_ddrips_c2_enter_ddrip_83_11.sv"
add_fileset_file "DDRIP_i_llvm_fpga_sfc_exit_s_c2_out_for_00002_exit_ddrip_459_0gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_i_llvm_fpga_sfc_exit_s_c2_out_for_00002_exit_ddrip_459_0gr.sv"
add_fileset_file "DDRIP_i_llvm_fpga_sfc_exit_s_c2_out_for_000037_1gr_full_detector.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_i_llvm_fpga_sfc_exit_s_c2_out_for_000037_1gr_full_detector.sv"
add_fileset_file "DDRIP_i_llvm_fpga_sfc_exit_s_c2_out_for_0000ip_459_1gr_data_fifo.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_i_llvm_fpga_sfc_exit_s_c2_out_for_0000ip_459_1gr_data_fifo.sv"
add_fileset_file "DDRIP_i_sfc_logic_s_c2_in_for_body_i_ddr0000_enter_ddrip_437_0gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_i_sfc_logic_s_c2_in_for_body_i_ddr0000_enter_ddrip_437_0gr.sv"
add_fileset_file "DDRIP_bb_B2.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_bb_B2.sv"
add_fileset_file "DDRIP_B2_branch.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_B2_branch.sv"
add_fileset_file "DDRIP_B2_branch_branch_storage.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_B2_branch_branch_storage.sv"
add_fileset_file "DDRIP_B2_merge.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_B2_merge.sv"
add_fileset_file "DDRIP_B2_merge_storage.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_B2_merge_storage.sv"
add_fileset_file "DDRIP_bb_B2_stall_region.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_bb_B2_stall_region.sv"
add_fileset_file "DDRIP_function_cra_agent.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_function_cra_agent.sv"
add_fileset_file "acl_start_signal_chain_element.sv" SYSTEM_VERILOG PATH "./ip/acl_start_signal_chain_element.sv"
add_fileset_file "acl_task_copy_finish_detector.sv" SYSTEM_VERILOG PATH "./ip/acl_task_copy_finish_detector.sv"
add_fileset_file "acl_finish_signal_chain_element.sv" SYSTEM_VERILOG PATH "./ip/acl_finish_signal_chain_element.sv"
add_fileset_file "acl_reset_handler.sv" SYSTEM_VERILOG PATH "./ip/acl_reset_handler.sv"
add_fileset_file "acl_fanout_pipeline.sv" SYSTEM_VERILOG PATH "./ip/acl_fanout_pipeline.sv"
add_fileset_file "acl_std_synchronizer_nocut.sv" SYSTEM_VERILOG PATH "./ip/acl_std_synchronizer_nocut.sv"
add_fileset_file "acl_ecc_pkg.sv" SYSTEM_VERILOG PATH "./ip/acl_ecc_pkg.sv"
add_fileset_file "lsu_ic_top.sv" SYSTEM_VERILOG PATH "./ip/lsu_ic_top.sv"
add_fileset_file "lsu_ic_hybrid.sv" SYSTEM_VERILOG PATH "./ip/lsu_ic_hybrid.sv"
add_fileset_file "lsu_ic_token.sv" SYSTEM_VERILOG PATH "./ip/lsu_ic_token.sv"
add_fileset_file "lsu_ic_unbalance.sv" SYSTEM_VERILOG PATH "./ip/lsu_ic_unbalance.sv"
add_fileset_file "lsu_n_fast.sv" SYSTEM_VERILOG PATH "./ip/lsu_n_fast.sv"
add_fileset_file "lsu_n_token.sv" SYSTEM_VERILOG PATH "./ip/lsu_n_token.sv"
add_fileset_file "lsu_rd_back.sv" SYSTEM_VERILOG PATH "./ip/lsu_rd_back.sv"
add_fileset_file "lsu_rd_back_n.sv" SYSTEM_VERILOG PATH "./ip/lsu_rd_back_n.sv"
add_fileset_file "lsu_swdimm_token_ring.sv" SYSTEM_VERILOG PATH "./ip/lsu_swdimm_token_ring.sv"
add_fileset_file "lsu_token_ring.sv" SYSTEM_VERILOG PATH "./ip/lsu_token_ring.sv"
add_fileset_file "acl_scfifo_wrapped.sv" SYSTEM_VERILOG PATH "./ip/acl_scfifo_wrapped.sv"
add_fileset_file "acl_skid_buffer.sv" SYSTEM_VERILOG PATH "./ip/acl_skid_buffer.sv"
add_fileset_file "acl_high_speed_fifo.sv" SYSTEM_VERILOG PATH "./ip/acl_high_speed_fifo.sv"
add_fileset_file "acl_altera_syncram_wrapped.sv" SYSTEM_VERILOG PATH "./ip/acl_altera_syncram_wrapped.sv"
add_fileset_file "acl_ecc_encoder.sv" SYSTEM_VERILOG PATH "./ip/acl_ecc_encoder.sv"
add_fileset_file "acl_ecc_decoder.sv" SYSTEM_VERILOG PATH "./ip/acl_ecc_decoder.sv"
add_fileset_file "acl_lfsr.sv" SYSTEM_VERILOG PATH "./ip/acl_lfsr.sv"
add_fileset_file "acl_tessellated_incr_decr_threshold.sv" SYSTEM_VERILOG PATH "./ip/acl_tessellated_incr_decr_threshold.sv"
add_fileset_file "acl_tessellated_incr_lookahead.sv" SYSTEM_VERILOG PATH "./ip/acl_tessellated_incr_lookahead.sv"
add_fileset_file "cra_ring_node.sv" SYSTEM_VERILOG PATH "./ip/cra_ring_node.sv"
add_fileset_file "cra_ring_root.sv" SYSTEM_VERILOG PATH "./ip/cra_ring_root.sv"
add_fileset_file "cra_ring_rom.sv" SYSTEM_VERILOG PATH "./ip/cra_ring_rom.sv"
add_fileset_file "acl_rom_module.sv" SYSTEM_VERILOG PATH "./ip/acl_rom_module.sv"
add_fileset_file "acl_clock_enable_gating.sv" SYSTEM_VERILOG PATH "./ip/acl_clock_enable_gating.sv"
#### Simulation fileset
add_fileset SIM_VERILOG SIM_VERILOG "" ""
set_fileset_property SIM_VERILOG TOP_LEVEL mmhost_ia840f_report_di
set_fileset_property SIM_VERILOG ENABLE_RELATIVE_INCLUDE_PATHS false
add_fileset_file "mmhost_ia840f_report_di.sv" SYSTEM_VERILOG PATH "./mmhost_ia840f_report_di.sv"
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
add_fileset_file "acl_ffwdsrc.sv" SYSTEM_VERILOG PATH "./ip/acl_ffwdsrc.sv"
add_fileset_file "acl_full_detector.sv" SYSTEM_VERILOG PATH "./ip/acl_full_detector.sv"
add_fileset_file "acl_tessellated_incr_decr_decr.sv" SYSTEM_VERILOG PATH "./ip/acl_tessellated_incr_decr_decr.sv"
add_fileset_file "acl_sync.sv" SYSTEM_VERILOG PATH "./ip/acl_sync.sv"
add_fileset_file "acl_fast_pipeline.sv" SYSTEM_VERILOG PATH "./ip/acl_fast_pipeline.sv"
add_fileset_file "acl_ffwddst.sv" SYSTEM_VERILOG PATH "./ip/acl_ffwddst.sv"
add_fileset_file "acl_push.sv" SYSTEM_VERILOG PATH "./ip/acl_push.sv"
add_fileset_file "acl_token_fifo_counter.sv" SYSTEM_VERILOG PATH "./ip/acl_token_fifo_counter.sv"
add_fileset_file "acl_loop_admit.sv" SYSTEM_VERILOG PATH "./ip/acl_loop_admit.sv"
add_fileset_file "acl_shift_register_no_reset_dont_merge.sv" SYSTEM_VERILOG PATH "./ip/acl_shift_register_no_reset_dont_merge.sv"
add_fileset_file "lsu_top.sv" SYSTEM_VERILOG PATH "./ip/lsu_top.sv"
add_fileset_file "acl_has_pending_write.sv" SYSTEM_VERILOG PATH "./ip/acl_has_pending_write.sv"
add_fileset_file "lsu_permute_address.sv" SYSTEM_VERILOG PATH "./ip/lsu_permute_address.sv"
add_fileset_file "lsu_pipelined.sv" SYSTEM_VERILOG PATH "./ip/lsu_pipelined.sv"
add_fileset_file "lsu_enabled.sv" SYSTEM_VERILOG PATH "./ip/lsu_enabled.sv"
add_fileset_file "lsu_basic_coalescer.sv" SYSTEM_VERILOG PATH "./ip/lsu_basic_coalescer.sv"
add_fileset_file "lsu_simple.sv" SYSTEM_VERILOG PATH "./ip/lsu_simple.sv"
add_fileset_file "lsu_burst_host.sv" SYSTEM_VERILOG PATH "./ip/lsu_burst_host.sv"
add_fileset_file "lsu_bursting_load_stores.sv" SYSTEM_VERILOG PATH "./ip/lsu_bursting_load_stores.sv"
add_fileset_file "lsu_non_aligned_write.sv" SYSTEM_VERILOG PATH "./ip/lsu_non_aligned_write.sv"
add_fileset_file "lsu_read_cache.sv" SYSTEM_VERILOG PATH "./ip/lsu_read_cache.sv"
add_fileset_file "lsu_atomic.sv" SYSTEM_VERILOG PATH "./ip/lsu_atomic.sv"
add_fileset_file "lsu_prefetch_block.sv" SYSTEM_VERILOG PATH "./ip/lsu_prefetch_block.sv"
add_fileset_file "lsu_wide_wrapper.sv" SYSTEM_VERILOG PATH "./ip/lsu_wide_wrapper.sv"
add_fileset_file "lsu_streaming_prefetch.sv" SYSTEM_VERILOG PATH "./ip/lsu_streaming_prefetch.sv"
add_fileset_file "acl_aligned_burst_coalesced_lsu.sv" SYSTEM_VERILOG PATH "./ip/acl_aligned_burst_coalesced_lsu.sv"
add_fileset_file "acl_toggle_detect.sv" SYSTEM_VERILOG PATH "./ip/acl_toggle_detect.sv"
add_fileset_file "acl_debug_mem.sv" SYSTEM_VERILOG PATH "./ip/acl_debug_mem.sv"
add_fileset_file "lsu_burst_coalesced_pipelined_write.sv" SYSTEM_VERILOG PATH "./ip/lsu_burst_coalesced_pipelined_write.sv"
add_fileset_file "lsu_burst_coalesced_pipelined_read.sv" SYSTEM_VERILOG PATH "./ip/lsu_burst_coalesced_pipelined_read.sv"
add_fileset_file "acl_fifo_stall_valid_lookahead.sv" SYSTEM_VERILOG PATH "./ip/acl_fifo_stall_valid_lookahead.sv"
add_fileset_file "hld_global_load_store.sv" SYSTEM_VERILOG PATH "./ip/hld_global_load_store.sv"
add_fileset_file "hld_lsu.sv" SYSTEM_VERILOG PATH "./ip/hld_lsu.sv"
add_fileset_file "hld_lsu_burst_coalescer.sv" SYSTEM_VERILOG PATH "./ip/hld_lsu_burst_coalescer.sv"
add_fileset_file "hld_lsu_coalescer_dynamic_timeout.sv" SYSTEM_VERILOG PATH "./ip/hld_lsu_coalescer_dynamic_timeout.sv"
add_fileset_file "hld_lsu_data_aligner.sv" SYSTEM_VERILOG PATH "./ip/hld_lsu_data_aligner.sv"
add_fileset_file "hld_lsu_read_cache.sv" SYSTEM_VERILOG PATH "./ip/hld_lsu_read_cache.sv"
add_fileset_file "hld_lsu_read_data_alignment.sv" SYSTEM_VERILOG PATH "./ip/hld_lsu_read_data_alignment.sv"
add_fileset_file "hld_lsu_unaligned_controller.sv" SYSTEM_VERILOG PATH "./ip/hld_lsu_unaligned_controller.sv"
add_fileset_file "hld_lsu_word_coalescer.sv" SYSTEM_VERILOG PATH "./ip/hld_lsu_word_coalescer.sv"
add_fileset_file "hld_lsu_write_data_alignment.sv" SYSTEM_VERILOG PATH "./ip/hld_lsu_write_data_alignment.sv"
add_fileset_file "hld_lsu_write_kernel_downstream.sv" SYSTEM_VERILOG PATH "./ip/hld_lsu_write_kernel_downstream.sv"
add_fileset_file "acl_shift_register_no_reset.sv" SYSTEM_VERILOG PATH "./ip/acl_shift_register_no_reset.sv"
add_fileset_file "hld_loop_profiler.sv" SYSTEM_VERILOG PATH "./ip/hld_loop_profiler.sv"
add_fileset_file "hld_sim_latency_tracker.sv" SYSTEM_VERILOG PATH "./ip/hld_sim_latency_tracker.sv"
add_fileset_file "DDRIP_function_wrapper.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_function_wrapper.sv"
add_fileset_file "DDRIP_function.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_function.sv"
add_fileset_file "DDRIP_bb_B0.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_bb_B0.sv"
add_fileset_file "DDRIP_B0_branch.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_B0_branch.sv"
add_fileset_file "DDRIP_B0_merge.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_B0_merge.sv"
add_fileset_file "DDRIP_B0_merge_storage.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_B0_merge_storage.sv"
add_fileset_file "DDRIP_bb_B0_stall_region.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_bb_B0_stall_region.sv"
add_fileset_file "DDRIP_i_sfc_s_c0_in_entry_ddrips_c0_enter_ddrip_31_0gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_i_sfc_s_c0_in_entry_ddrips_c0_enter_ddrip_31_0gr.sv"
add_fileset_file "DDRIP_i_llvm_fpga_sfc_exit_s_c0_in_entry0000c0_exit_ddrip_58_0gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_i_llvm_fpga_sfc_exit_s_c0_in_entry0000c0_exit_ddrip_58_0gr.sv"
add_fileset_file "DDRIP_i_llvm_fpga_sfc_exit_s_c0_in_entry000036_1gr_full_detector.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_i_llvm_fpga_sfc_exit_s_c0_in_entry000036_1gr_full_detector.sv"
add_fileset_file "DDRIP_i_llvm_fpga_sfc_exit_s_c0_in_entry0000rip_58_1gr_data_fifo.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_i_llvm_fpga_sfc_exit_s_c0_in_entry0000rip_58_1gr_data_fifo.sv"
add_fileset_file "DDRIP_i_sfc_logic_s_c0_in_entry_ddrips_c0_enter_ddrip_36_0gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_i_sfc_logic_s_c0_in_entry_ddrips_c0_enter_ddrip_36_0gr.sv"
add_fileset_file "DDRIP_i_llvm_fpga_ffwd_source_i1_unnamed_ddrip1_ddrip_51_0gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_i_llvm_fpga_ffwd_source_i1_unnamed_ddrip1_ddrip_51_0gr.sv"
add_fileset_file "DDRIP_i_llvm_fpga_sync_buffer_i32_arg_si0000ffer150_ddrip_43_0gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_i_llvm_fpga_sync_buffer_i32_arg_si0000ffer150_ddrip_43_0gr.sv"
add_fileset_file "DDRIP_bb_B1.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_bb_B1.sv"
add_fileset_file "DDRIP_B1_branch.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_B1_branch.sv"
add_fileset_file "DDRIP_B1_merge.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_B1_merge.sv"
add_fileset_file "DDRIP_B1_merge_storage.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_B1_merge_storage.sv"
add_fileset_file "DDRIP_bb_B1_stall_region.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_bb_B1_stall_region.sv"
add_fileset_file "DDRIP_i_llvm_fpga_mem_memcoalesce_load_d0000ique_0_ddrip_329_0gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_i_llvm_fpga_mem_memcoalesce_load_d0000ique_0_ddrip_329_0gr.sv"
add_fileset_file "DDRIP_i_llvm_fpga_mem_memcoalesce_load_d0000ique_1_ddrip_405_0gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_i_llvm_fpga_mem_memcoalesce_load_d0000ique_1_ddrip_405_0gr.sv"
add_fileset_file "DDRIP_i_llvm_fpga_mem_memdep_ddrip_467_0gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_i_llvm_fpga_mem_memdep_ddrip_467_0gr.sv"
add_fileset_file "DDRIP_i_sfc_s_c0_in_for_body_i_ddrips_c0_enter1591_ddrip_83_1gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_i_sfc_s_c0_in_for_body_i_ddrips_c0_enter1591_ddrip_83_1gr.sv"
add_fileset_file "DDRIP_i_llvm_fpga_sfc_exit_s_c0_out_for_0000xit160_ddrip_298_0gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_i_llvm_fpga_sfc_exit_s_c0_out_for_0000xit160_ddrip_298_0gr.sv"
add_fileset_file "DDRIP_i_llvm_fpga_sfc_exit_s_c0_out_for_000090_1gr_full_detector.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_i_llvm_fpga_sfc_exit_s_c0_out_for_000090_1gr_full_detector.sv"
add_fileset_file "DDRIP_i_llvm_fpga_sfc_exit_s_c0_out_for_0000ip_298_1gr_data_fifo.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_i_llvm_fpga_sfc_exit_s_c0_out_for_0000ip_298_1gr_data_fifo.sv"
add_fileset_file "DDRIP_i_sfc_logic_s_c0_in_for_body_i_ddr0000ter1591_ddrip_90_0gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_i_sfc_logic_s_c0_in_for_body_i_ddr0000ter1591_ddrip_90_0gr.sv"
add_fileset_file "DDRIP_i_llvm_fpga_dummy_thread_ddrip_b1_dummy_ddrip_98_0gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_i_llvm_fpga_dummy_thread_ddrip_b1_dummy_ddrip_98_0gr.sv"
add_fileset_file "DDRIP_i_llvm_fpga_ffwd_dest_i1_cmp_i4158_ddrip_135_0gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_i_llvm_fpga_ffwd_dest_i1_cmp_i4158_ddrip_135_0gr.sv"
add_fileset_file "DDRIP_i_llvm_fpga_forked_ddrip_b1_forked_ddrip_106_0gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_i_llvm_fpga_forked_ddrip_b1_forked_ddrip_106_0gr.sv"
add_fileset_file "DDRIP_i_llvm_fpga_pipeline_keep_going_ddrip_119_0gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_i_llvm_fpga_pipeline_keep_going_ddrip_119_0gr.sv"
add_fileset_file "DDRIP_i_llvm_fpga_push_i1_notexitcond_ddrip_287_0gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_i_llvm_fpga_push_i1_notexitcond_ddrip_287_0gr.sv"
add_fileset_file "DDRIP_i_llvm_fpga_sync_buffer_i32_arg_si0000fer151_ddrip_173_0gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_i_llvm_fpga_sync_buffer_i32_arg_si0000fer151_ddrip_173_0gr.sv"
add_fileset_file "DDRIP_i_llvm_fpga_sync_buffer_i32_arg_si0000fer152_ddrip_184_0gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_i_llvm_fpga_sync_buffer_i32_arg_si0000fer152_ddrip_184_0gr.sv"
add_fileset_file "DDRIP_i_llvm_fpga_sync_buffer_i32_arg_si0000fer153_ddrip_195_0gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_i_llvm_fpga_sync_buffer_i32_arg_si0000fer153_ddrip_195_0gr.sv"
add_fileset_file "DDRIP_i_llvm_fpga_sync_buffer_i32_arg_si0000fer154_ddrip_206_0gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_i_llvm_fpga_sync_buffer_i32_arg_si0000fer154_ddrip_206_0gr.sv"
add_fileset_file "DDRIP_i_llvm_fpga_sync_buffer_i32_arg_si0000fer155_ddrip_217_0gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_i_llvm_fpga_sync_buffer_i32_arg_si0000fer155_ddrip_217_0gr.sv"
add_fileset_file "DDRIP_i_llvm_fpga_sync_buffer_i32_arg_si0000fer156_ddrip_228_0gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_i_llvm_fpga_sync_buffer_i32_arg_si0000fer156_ddrip_228_0gr.sv"
add_fileset_file "DDRIP_i_llvm_fpga_sync_buffer_i32_arg_si0000fer157_ddrip_267_0gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_i_llvm_fpga_sync_buffer_i32_arg_si0000fer157_ddrip_267_0gr.sv"
add_fileset_file "DDRIP_i_llvm_fpga_sync_buffer_i32_arg_si0000buffer_ddrip_163_0gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_i_llvm_fpga_sync_buffer_i32_arg_si0000buffer_ddrip_163_0gr.sv"
add_fileset_file "DDRIP_i_llvm_fpga_sync_buffer_p1024_arg_0000buffer_ddrip_148_0gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_i_llvm_fpga_sync_buffer_p1024_arg_0000buffer_ddrip_148_0gr.sv"
add_fileset_file "DDRIP_i_llvm_fpga_sync_buffer_p1024_arg_0000buffer_ddrip_238_0gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_i_llvm_fpga_sync_buffer_p1024_arg_0000buffer_ddrip_238_0gr.sv"
add_fileset_file "DDRIP_i_llvm_fpga_sync_buffer_p1025_arg_0000buffer_ddrip_252_0gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_i_llvm_fpga_sync_buffer_p1025_arg_0000buffer_ddrip_252_0gr.sv"
add_fileset_file "DDRIP_i_sfc_s_c1_in_for_body_i_ddrips_c1_enter_ddrip_83_7gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_i_sfc_s_c1_in_for_body_i_ddrips_c1_enter_ddrip_83_7gr.sv"
add_fileset_file "DDRIP_i_llvm_fpga_sfc_exit_s_c1_out_for_00001_exit_ddrip_397_0gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_i_llvm_fpga_sfc_exit_s_c1_out_for_00001_exit_ddrip_397_0gr.sv"
add_fileset_file "DDRIP_i_llvm_fpga_sfc_exit_s_c1_out_for_000061_1gr_full_detector.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_i_llvm_fpga_sfc_exit_s_c1_out_for_000061_1gr_full_detector.sv"
add_fileset_file "DDRIP_i_llvm_fpga_sfc_exit_s_c1_out_for_0000ip_397_1gr_data_fifo.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_i_llvm_fpga_sfc_exit_s_c1_out_for_0000ip_397_1gr_data_fifo.sv"
add_fileset_file "DDRIP_i_sfc_logic_s_c1_in_for_body_i_ddr0000_enter_ddrip_361_0gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_i_sfc_logic_s_c1_in_for_body_i_ddr0000_enter_ddrip_361_0gr.sv"
add_fileset_file "DDRIP_i_sfc_s_c2_in_for_body_i_ddrips_c2_enter_ddrip_83_11.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_i_sfc_s_c2_in_for_body_i_ddrips_c2_enter_ddrip_83_11.sv"
add_fileset_file "DDRIP_i_llvm_fpga_sfc_exit_s_c2_out_for_00002_exit_ddrip_459_0gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_i_llvm_fpga_sfc_exit_s_c2_out_for_00002_exit_ddrip_459_0gr.sv"
add_fileset_file "DDRIP_i_llvm_fpga_sfc_exit_s_c2_out_for_000037_1gr_full_detector.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_i_llvm_fpga_sfc_exit_s_c2_out_for_000037_1gr_full_detector.sv"
add_fileset_file "DDRIP_i_llvm_fpga_sfc_exit_s_c2_out_for_0000ip_459_1gr_data_fifo.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_i_llvm_fpga_sfc_exit_s_c2_out_for_0000ip_459_1gr_data_fifo.sv"
add_fileset_file "DDRIP_i_sfc_logic_s_c2_in_for_body_i_ddr0000_enter_ddrip_437_0gr.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_i_sfc_logic_s_c2_in_for_body_i_ddr0000_enter_ddrip_437_0gr.sv"
add_fileset_file "DDRIP_bb_B2.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_bb_B2.sv"
add_fileset_file "DDRIP_B2_branch.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_B2_branch.sv"
add_fileset_file "DDRIP_B2_branch_branch_storage.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_B2_branch_branch_storage.sv"
add_fileset_file "DDRIP_B2_merge.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_B2_merge.sv"
add_fileset_file "DDRIP_B2_merge_storage.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_B2_merge_storage.sv"
add_fileset_file "DDRIP_bb_B2_stall_region.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_bb_B2_stall_region.sv"
add_fileset_file "DDRIP_function_cra_agent.sv" SYSTEM_VERILOG PATH "./kernel_hdl/DDRIP/DDRIP_function_cra_agent.sv"
add_fileset_file "acl_start_signal_chain_element.sv" SYSTEM_VERILOG PATH "./ip/acl_start_signal_chain_element.sv"
add_fileset_file "acl_task_copy_finish_detector.sv" SYSTEM_VERILOG PATH "./ip/acl_task_copy_finish_detector.sv"
add_fileset_file "acl_finish_signal_chain_element.sv" SYSTEM_VERILOG PATH "./ip/acl_finish_signal_chain_element.sv"
add_fileset_file "acl_reset_handler.sv" SYSTEM_VERILOG PATH "./ip/acl_reset_handler.sv"
add_fileset_file "acl_fanout_pipeline.sv" SYSTEM_VERILOG PATH "./ip/acl_fanout_pipeline.sv"
add_fileset_file "acl_std_synchronizer_nocut.sv" SYSTEM_VERILOG PATH "./ip/acl_std_synchronizer_nocut.sv"
add_fileset_file "acl_ecc_pkg.sv" SYSTEM_VERILOG PATH "./ip/acl_ecc_pkg.sv"
add_fileset_file "lsu_ic_top.sv" SYSTEM_VERILOG PATH "./ip/lsu_ic_top.sv"
add_fileset_file "lsu_ic_hybrid.sv" SYSTEM_VERILOG PATH "./ip/lsu_ic_hybrid.sv"
add_fileset_file "lsu_ic_token.sv" SYSTEM_VERILOG PATH "./ip/lsu_ic_token.sv"
add_fileset_file "lsu_ic_unbalance.sv" SYSTEM_VERILOG PATH "./ip/lsu_ic_unbalance.sv"
add_fileset_file "lsu_n_fast.sv" SYSTEM_VERILOG PATH "./ip/lsu_n_fast.sv"
add_fileset_file "lsu_n_token.sv" SYSTEM_VERILOG PATH "./ip/lsu_n_token.sv"
add_fileset_file "lsu_rd_back.sv" SYSTEM_VERILOG PATH "./ip/lsu_rd_back.sv"
add_fileset_file "lsu_rd_back_n.sv" SYSTEM_VERILOG PATH "./ip/lsu_rd_back_n.sv"
add_fileset_file "lsu_swdimm_token_ring.sv" SYSTEM_VERILOG PATH "./ip/lsu_swdimm_token_ring.sv"
add_fileset_file "lsu_token_ring.sv" SYSTEM_VERILOG PATH "./ip/lsu_token_ring.sv"
add_fileset_file "acl_scfifo_wrapped.sv" SYSTEM_VERILOG PATH "./ip/acl_scfifo_wrapped.sv"
add_fileset_file "acl_skid_buffer.sv" SYSTEM_VERILOG PATH "./ip/acl_skid_buffer.sv"
add_fileset_file "acl_high_speed_fifo.sv" SYSTEM_VERILOG PATH "./ip/acl_high_speed_fifo.sv"
add_fileset_file "acl_altera_syncram_wrapped.sv" SYSTEM_VERILOG PATH "./ip/acl_altera_syncram_wrapped.sv"
add_fileset_file "acl_ecc_encoder.sv" SYSTEM_VERILOG PATH "./ip/acl_ecc_encoder.sv"
add_fileset_file "acl_ecc_decoder.sv" SYSTEM_VERILOG PATH "./ip/acl_ecc_decoder.sv"
add_fileset_file "acl_lfsr.sv" SYSTEM_VERILOG PATH "./ip/acl_lfsr.sv"
add_fileset_file "acl_tessellated_incr_decr_threshold.sv" SYSTEM_VERILOG PATH "./ip/acl_tessellated_incr_decr_threshold.sv"
add_fileset_file "acl_tessellated_incr_lookahead.sv" SYSTEM_VERILOG PATH "./ip/acl_tessellated_incr_lookahead.sv"
add_fileset_file "cra_ring_node.sv" SYSTEM_VERILOG PATH "./ip/cra_ring_node.sv"
add_fileset_file "cra_ring_root.sv" SYSTEM_VERILOG PATH "./ip/cra_ring_root.sv"
add_fileset_file "cra_ring_rom.sv" SYSTEM_VERILOG PATH "./ip/cra_ring_rom.sv"
add_fileset_file "acl_rom_module.sv" SYSTEM_VERILOG PATH "./ip/acl_rom_module.sv"
add_fileset_file "acl_clock_enable_gating.sv" SYSTEM_VERILOG PATH "./ip/acl_clock_enable_gating.sv"
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

#### Host interface avm_mem_gmem0_1_port_0_0_rw with base address 0
add_interface avm_mem_gmem0_1_port_0_0_rw avalon start
set_interface_property avm_mem_gmem0_1_port_0_0_rw ENABLED true
set_interface_property avm_mem_gmem0_1_port_0_0_rw associatedClock clock
set_interface_property avm_mem_gmem0_1_port_0_0_rw associatedReset resetn
set_interface_property avm_mem_gmem0_1_port_0_0_rw burstOnBurstBoundariesOnly false
set_interface_property avm_mem_gmem0_1_port_0_0_rw doStreamReads false
set_interface_property avm_mem_gmem0_1_port_0_0_rw doStreamWrites false
set_interface_property avm_mem_gmem0_1_port_0_0_rw linewrapBursts false
set_interface_property avm_mem_gmem0_1_port_0_0_rw readWaitTime 0
add_interface_port avm_mem_gmem0_1_port_0_0_rw avm_mem_gmem0_1_port_0_0_rw_address address output 34
add_interface_port avm_mem_gmem0_1_port_0_0_rw avm_mem_gmem0_1_port_0_0_rw_byteenable byteenable output 32
add_interface_port avm_mem_gmem0_1_port_0_0_rw avm_mem_gmem0_1_port_0_0_rw_readdatavalid readdatavalid input 1
add_interface_port avm_mem_gmem0_1_port_0_0_rw avm_mem_gmem0_1_port_0_0_rw_read read output 1
add_interface_port avm_mem_gmem0_1_port_0_0_rw avm_mem_gmem0_1_port_0_0_rw_readdata readdata input 256
add_interface_port avm_mem_gmem0_1_port_0_0_rw avm_mem_gmem0_1_port_0_0_rw_write write output 1
add_interface_port avm_mem_gmem0_1_port_0_0_rw avm_mem_gmem0_1_port_0_0_rw_writedata writedata output 256
add_interface_port avm_mem_gmem0_1_port_0_0_rw avm_mem_gmem0_1_port_0_0_rw_waitrequest waitrequest input 1
add_interface_port avm_mem_gmem0_1_port_0_0_rw avm_mem_gmem0_1_port_0_0_rw_burstcount burstcount output 4

#### Host interface avm_mem_gmem1_2_port_0_0_rw with base address 2199023255552
add_interface avm_mem_gmem1_2_port_0_0_rw avalon start
set_interface_property avm_mem_gmem1_2_port_0_0_rw ENABLED true
set_interface_property avm_mem_gmem1_2_port_0_0_rw associatedClock clock
set_interface_property avm_mem_gmem1_2_port_0_0_rw associatedReset resetn
set_interface_property avm_mem_gmem1_2_port_0_0_rw burstOnBurstBoundariesOnly false
set_interface_property avm_mem_gmem1_2_port_0_0_rw doStreamReads false
set_interface_property avm_mem_gmem1_2_port_0_0_rw doStreamWrites false
set_interface_property avm_mem_gmem1_2_port_0_0_rw linewrapBursts false
set_interface_property avm_mem_gmem1_2_port_0_0_rw readWaitTime 0
add_interface_port avm_mem_gmem1_2_port_0_0_rw avm_mem_gmem1_2_port_0_0_rw_address address output 34
add_interface_port avm_mem_gmem1_2_port_0_0_rw avm_mem_gmem1_2_port_0_0_rw_byteenable byteenable output 32
add_interface_port avm_mem_gmem1_2_port_0_0_rw avm_mem_gmem1_2_port_0_0_rw_readdatavalid readdatavalid input 1
add_interface_port avm_mem_gmem1_2_port_0_0_rw avm_mem_gmem1_2_port_0_0_rw_read read output 1
add_interface_port avm_mem_gmem1_2_port_0_0_rw avm_mem_gmem1_2_port_0_0_rw_readdata readdata input 256
add_interface_port avm_mem_gmem1_2_port_0_0_rw avm_mem_gmem1_2_port_0_0_rw_write write output 1
add_interface_port avm_mem_gmem1_2_port_0_0_rw avm_mem_gmem1_2_port_0_0_rw_writedata writedata output 256
add_interface_port avm_mem_gmem1_2_port_0_0_rw avm_mem_gmem1_2_port_0_0_rw_waitrequest waitrequest input 1
add_interface_port avm_mem_gmem1_2_port_0_0_rw avm_mem_gmem1_2_port_0_0_rw_burstcount burstcount output 4

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

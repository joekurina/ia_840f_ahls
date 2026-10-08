# Copyright 2022 Intel Corporation
# SPDX-License-Identifier: MIT
#
#--------------------
# IPs
#--------------------
set_global_assignment -name IP_FILE "board.ip"

#--------------------
# DMA controller
#--------------------
set_global_assignment -name SOURCE_TCL_SCRIPT_FILE  "./rtl/dma/par/dma_controller_filelist.tcl"

#--------------------
# UDP Engine
#--------------------
set_global_assignment -name SOURCE_TCL_SCRIPT_FILE  "./rtl/udp_offload_engine/par/udp_offload_engine_filelist.tcl"

#--------------------
# MPF VTP files
#--------------------
source "mpf_vtp.qsf"

#--------------------
# ASP RTL files
#--------------------
set_global_assignment -name SYSTEMVERILOG_FILE "rtl/ofs_plat_afu.sv"
set_global_assignment -name SYSTEMVERILOG_FILE "rtl/afu.sv"
set_global_assignment -name SYSTEMVERILOG_FILE "rtl/host_mem_if_vtp.sv"
set_global_assignment -name SYSTEMVERILOG_FILE "rtl/kernel_wrapper.v"
set_global_assignment -name SYSTEMVERILOG_FILE "rtl/asp_logic.sv"
set_global_assignment -name SYSTEMVERILOG_FILE "rtl/ofs_asp_interfaces.sv"
set_global_assignment -name SYSTEMVERILOG_FILE "rtl/ofs_asp_pkg.sv"
set_global_assignment -name SYSTEMVERILOG_FILE "rtl/asp_host_mem_if_mux.sv"
set_global_assignment -name SYSTEMVERILOG_FILE "rtl/avmm_wr_ack_gen.sv"
set_global_assignment -name SYSTEMVERILOG_FILE "rtl/avmm_wr_ack_burst_to_word.sv"
set_global_assignment -name SYSTEMVERILOG_FILE "rtl/avmm_wr_ack_tracker.sv"
set_global_assignment -name SYSTEMVERILOG_FILE "rtl/avmm_single_burst_partial_writes.v"
set_global_assignment -name SYSTEMVERILOG_FILE "rtl/ia840f_avmm_single_burst_partial_writes_pu_capped.v"
set_global_assignment -name SYSTEMVERILOG_FILE "rtl/ia840f_irq_source_publisher.sv"

#--------------------
# Search paths (for headers, etc)
#--------------------
set_global_assignment -name SEARCH_PATH rtl/

#--------------------
# SDC
#--------------------
set_global_assignment -name SDC_FILE "ofs_asp.sdc"

# Preserve the plain-flow publisher boundary; kclk retains direct forwarding.
set ia840f_header_fd [open "rtl/ofs_asp.vh" r]
set ia840f_header_text [read $ia840f_header_fd]
close $ia840f_header_fd
if {![regexp -line {^\s*`define USE_KERNEL_CLK_EVERYWHERE_IN_PR_REGION\s+1\s*$} $ia840f_header_text]} {
    set_instance_assignment -name ALLOW_REGISTER_RETIMING OFF -to {afu_top|pg_afu.port_gasket|pr_slot|afu_main|port_afu_instances|ofs_plat_afu|afu_inst|kernel_wrapper_inst|irq_source_publisher_inst|irq_q}
}
unset ia840f_header_text ia840f_header_fd

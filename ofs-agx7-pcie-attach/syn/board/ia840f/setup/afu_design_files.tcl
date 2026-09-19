## Copyright (C) 2023 Intel Corporation
## SPDX-License-Identifier: MIT

#--------------------
# AFU modules
#--------------------
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/src/includes/ofs_pcie_ss_plat_cfg_pkg.sv

#--------------------
# AFU Top
#-------------------- 
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/src/afu_top/dummy_csr.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/src/afu_top/apf_top.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/src/board/ia840f/afu_top.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/src/afu_top/afu_host_channel.sv

# IA840F requires PF1 board management. A generic SR_AFU override is unsafe.
if { [info exist env(OFS_BUILD_TAG_SR_AFU)] } {
    error "IA840F board management cannot be replaced by SR_AFU"
}
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/src/board/ia840f/fim_afu_instances.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/src/board/ia840f/bwbmc_st2mm.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/src/board/ia840f/bwbmc_st2mm_rx_bridge.sv
set_global_assignment -name SOURCE_TCL_SCRIPT_FILE $::env(BUILD_ROOT_REL)/syn/board/ia840f/setup/bwbmc_design_files.tcl

#--------------------
# PF/VF Mux/Demux
#--------------------
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/src/afu_top/axis_demux.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/src/afu_top/axis_mux.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/src/afu_top/mux/top_cfg_pkg.sv

#--------------------
# Common sources
#--------------------
#set_global_assignment -name SOURCE_TCL_SCRIPT_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/mem_tg/mem_tg_design_files.tcl

if { [::config_env::verilog_macro_defined CONFIG_AGILEX5] == 0 } {
    set_global_assignment -name SOURCE_TCL_SCRIPT_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/mem_tg/mem_tg_design_files.tcl
}

#--------------------
# PR Gasket modules
#--------------------
# Synthetic timing constraints on user clock to achieve user-defined frequencies.
# *** This must follow the user clock IP. ***
set_global_assignment -name SDC_FILE $::env(BUILD_ROOT_REL)/syn/shared_config/setup_user_clock_for_pr.sdc

# Copyright (C) 2022-2023 Intel Corporation
# SPDX-License-Identifier: MIT

##
## Top-level AFU sources specification.
##
## Import AFU interfaces from the FIM as well as the AFU sources.
##

##### OFS IP database

# Add the constructed IP database to the search path. It was generated during
# the base FIM build.
set_global_assignment -name SEARCH_PATH "ofs_ip_cfg_db"

# Create an empty ofs_ip_cfg_db namespace. The namespace is used by OFS IP
# during the FIM build but is not required for PR. Defining the namespace
# prevents errors in Tcl files that are shared by FIM and PR builds.
namespace eval ::ofs_ip_cfg_db {}
if { [file exists ofs_ip_cfg_db/ip_gen_sv_wrapper_inc.tcl] } {
    set_global_assignment -name SOURCE_TCL_SCRIPT_FILE ofs_ip_cfg_db/ip_gen_sv_wrapper_inc.tcl
}

##### Interfaces and definitions

# Define FIM PCIe PF/VF MUX port assignment
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/src/afu_top/mux/top_cfg_pkg.sv
# FIM/AFU interface definitions
set_global_assignment -name SOURCE_TCL_SCRIPT_FILE $::env(BUILD_ROOT_REL)/syn/shared_config/afu_if_design_files.tcl

##### AFU <- Keep this tag. The pattern is used by scripts to update AFU sources.

# Import the Platform Interface Manager
set_global_assignment -name SEARCH_PATH "../../../../platform"
set_global_assignment -name SOURCE_TCL_SCRIPT_FILE "../../../../platform/ofs_plat_if/par/ofs_plat_if_addenda.qsf"

# Map FIM interfaces to the PIM and load AFU-specific sources
set_global_assignment -name SOURCE_TCL_SCRIPT_FILE "../../../.././ofs-common/src/fpga_family/agilex/afu_main.tcl"

# AFU-specific user clock frequency
set_global_assignment -name SDC_FILE ofs_partial_reconfig/user_clocks.sdc

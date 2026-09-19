# Copyright 2020 Intel Corporation
# SPDX-License-Identifier: MIT

#
# HPS SS
#--------------------

set_global_assignment -name SEARCH_PATH "$::env(BUILD_ROOT_REL)/ofs-common/src/fpga_family/agilex/hps"

# Is HPS enabled?
set vlog_macros [get_all_global_assignments -name VERILOG_MACRO]
set include_hps 0

foreach_in_collection m $vlog_macros {
    if { [string equal "INCLUDE_HPS" [lindex $m 2]] } {
        set include_hps 1
    }
}

if {$include_hps == 1} {
    set_global_assignment -name QSYS_FILE  $::env(BUILD_ROOT_REL)/ofs-common/src/fpga_family/agilex/hps/hps_ss.qsys
    set_global_assignment -name IP_FILE    $::env(BUILD_ROOT_REL)/ofs-common/src/fpga_family/agilex/hps/ip/hps_ss/hps_ss_clock_in_0.ip
    set_global_assignment -name IP_FILE    $::env(BUILD_ROOT_REL)/ofs-common/src/fpga_family/agilex/hps/ip/hps_ss/hps_ss_intel_agilex_hps_1.ip
    set_global_assignment -name IP_FILE    $::env(BUILD_ROOT_REL)/ofs-common/src/fpga_family/agilex/hps/ip/hps_ss/hps_ss_reset_in_0.ip
}

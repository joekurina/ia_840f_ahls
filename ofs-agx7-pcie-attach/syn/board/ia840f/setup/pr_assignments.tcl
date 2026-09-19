# Copyright (C) 2020 Intel Corporation.
# SPDX-License-Identifier: MIT

#
# This file contains PR specific Quartus assignments
#------------------------------------

if { [info exist env(OFS_BUILD_TAG_FLAT) ] } {
    post_message "Compiling Flat design..."
} else {

    post_message "Compiling PR Base revision..."
    #-------------------------------
    # Specify PR Partition and turn PR ON for that partition
    #-------------------------------
    set_global_assignment -name REVISION_TYPE PR_BASE

    # M20K protection signal to PR region (required in Agilex)
#    set_instance_assignment -name M20K_CE_CONTROL_FOR_PR ON -to afu_top|pg_afu.port_gasket|pr_slot|afu_main|pr_m20k_ce_ctl_req

    #####################################################
    # Main PR Partition -- green_region
    #####################################################
    set_instance_assignment -name PARTITION green_region -to afu_top|pg_afu.port_gasket|pr_slot|afu_main
    set_instance_assignment -name CORE_ONLY_PLACE_REGION ON -to afu_top|pg_afu.port_gasket|pr_slot|afu_main
    set_instance_assignment -name RESERVE_PLACE_REGION ON -to afu_top|pg_afu.port_gasket|pr_slot|afu_main
    set_instance_assignment -name PARTIAL_RECONFIGURATION_PARTITION ON -to afu_top|pg_afu.port_gasket|pr_slot|afu_main

#    set_instance_assignment -name PLACE_REGION "X0 Y106 X390 Y333; X136 Y26 X390 Y105; X326 Y0 X390 Y25" -to afu_top|pg_afu.port_gasket|pr_slot|afu_main
#    set_instance_assignment -name PLACE_REGION "X0 Y101 X390 Y333; X121 Y21 X390 Y100; X301 Y0 X390 Y20" -to afu_top|pg_afu.port_gasket|pr_slot|afu_main
    set_instance_assignment -name PLACE_REGION "X0 Y101 X390 Y333; X101 Y21 X390 Y100; X301 Y0 X390 Y20" -to afu_top|pg_afu.port_gasket|pr_slot|afu_main
#    set_instance_assignment -name PLACE_REGION "X0 Y101 X390 Y333; X91 Y21 X390 Y100; X301 Y0 X390 Y20" -to afu_top|pg_afu.port_gasket|pr_slot|afu_main
    set_instance_assignment -name ROUTE_REGION "X0 Y0 X390 Y333" -to afu_top|pg_afu.port_gasket|pr_slot|afu_main

#    set_instance_assignment -name CORE_ONLY_PLACE_REGION ON -to afu_top|tag_remap
#    set_instance_assignment -name PLACE_REGION "X0 Y0 X135 Y105; X136 Y0 X325 Y25" -to afu_top|tag_remap
#    set_instance_assignment -name PLACE_REGION "X0 Y0 X120 Y100; X121 Y0 X300 Y20" -to afu_top|tag_remap
#    set_instance_assignment -name PLACE_REGION "X0 Y0 X100 Y100; X101 Y0 X300 Y20" -to afu_top|tag_remap
#    set_instance_assignment -name PLACE_REGION "X0 Y0 X90 Y100; X91 Y0 X300 Y20" -to afu_top|tag_remap

#    set_instance_assignment -name CORE_ONLY_PLACE_REGION ON -to afu_top|pf_vf_mux_a
#    set_instance_assignment -name PLACE_REGION "X0 Y0 X135 Y105; X136 Y0 X325 Y25" -to afu_top|pf_vf_mux_a
#    set_instance_assignment -name PLACE_REGION "X0 Y0 X120 Y100; X121 Y0 X300 Y20" -to afu_top|pf_vf_mux_a
#    set_instance_assignment -name PLACE_REGION "X0 Y0 X100 Y100; X101 Y0 X300 Y20" -to afu_top|pf_vf_mux_a
#    set_instance_assignment -name PLACE_REGION "X0 Y0 X90 Y100; X91 Y0 X300 Y20" -to afu_top|pf_vf_mux_a

#    set_instance_assignment -name CORE_ONLY_PLACE_REGION ON -to afu_top|pf_vf_mux_b
#    set_instance_assignment -name PLACE_REGION "X0 Y0 X135 Y105; X136 Y0 X325 Y25" -to afu_top|pf_vf_mux_b
#    set_instance_assignment -name PLACE_REGION "X0 Y0 X120 Y100; X121 Y0 X300 Y20" -to afu_top|pf_vf_mux_b
#    set_instance_assignment -name PLACE_REGION "X0 Y0 X100 Y100; X101 Y0 X300 Y20" -to afu_top|pf_vf_mux_b
#    set_instance_assignment -name PLACE_REGION "X0 Y0 X90 Y100; X91 Y0 X300 Y20" -to afu_top|pf_vf_mux_b

#    set_instance_assignment -name CORE_ONLY_PLACE_REGION ON -to afu_top|mx2ho_tx_ab_mux
#    set_instance_assignment -name PLACE_REGION "X0 Y0 X135 Y105; X136 Y0 X325 Y25" -to afu_top|mx2ho_tx_ab_mux
#    set_instance_assignment -name PLACE_REGION "X0 Y0 X120 Y100; X121 Y0 X300 Y20" -to afu_top|mx2ho_tx_ab_mux
#     set_instance_assignment -name PLACE_REGION "X0 Y0 X100 Y100; X101 Y0 X300 Y20" -to afu_top|mx2ho_tx_ab_mux
#    set_instance_assignment -name PLACE_REGION "X0 Y0 X90 Y100; X91 Y0 X300 Y20" -to afu_top|mx2ho_tx_ab_mux

#    set_instance_assignment -name CORE_ONLY_PLACE_REGION ON -to afu_top|afu_intf_inst
#    set_instance_assignment -name PLACE_REGION "X0 Y0 X135 Y105; X136 Y0 X325 Y25" -to afu_top|afu_intf_inst
#    set_instance_assignment -name PLACE_REGION "X0 Y0 X120 Y100; X121 Y0 X300 Y20" -to afu_top|afu_intf_inst
#    set_instance_assignment -name PLACE_REGION "X0 Y0 X100 Y100; X101 Y0 X300 Y20" -to afu_top|afu_intf_inst
#    set_instance_assignment -name PLACE_REGION "X0 Y0 X90 Y100; X91 Y0 X300 Y20" -to afu_top|afu_intf_inst

#    set_instance_assignment -name CORE_ONLY_PLACE_REGION ON -to afu_top|fim_afu_instances|st2mm
#    set_instance_assignment -name PLACE_REGION "X0 Y0 X135 Y105; X136 Y0 X325 Y25" -to afu_top|fim_afu_instances|st2mm
#    set_instance_assignment -name PLACE_REGION "X0 Y0 X120 Y100; X121 Y0 X300 Y20" -to afu_top|fim_afu_instances|st2mm
#    set_instance_assignment -name PLACE_REGION "X0 Y0 X100 Y100; X101 Y0 X300 Y20" -to afu_top|fim_afu_instances|st2mm
#   set_instance_assignment -name PLACE_REGION "X0 Y0 X90 Y100; X91 Y0 X300 Y20" -to afu_top|fim_afu_instances|st2mm

    #set_instance_assignment -name CORE_ONLY_PLACE_REGION ON -to afu_top|fim_afu_instances|he_lb_top
    #set_instance_assignment -name PLACE_REGION "X0 Y0 X120 Y100; X121 Y0 X300 Y20" -to afu_top|fim_afu_instances|he_lb_top

#    set_instance_assignment -name CORE_ONLY_PLACE_REGION ON -to afu_top|fim_afu_instances|ce_top
#    set_instance_assignment -name PLACE_REGION "X0 Y0 X135 Y105; X136 Y0 X325 Y25" -to afu_top|fim_afu_instances|ce_top
#    set_instance_assignment -name PLACE_REGION "X0 Y0 X120 Y100; X121 Y0 X300 Y20" -to afu_top|fim_afu_instances|ce_top
#    set_instance_assignment -name PLACE_REGION "X0 Y0 X100 Y100; X101 Y0 X300 Y20" -to afu_top|fim_afu_instances|ce_top
#   set_instance_assignment -name PLACE_REGION "X0 Y0 X90 Y100; X91 Y0 X300 Y20" -to afu_top|fim_afu_instances|ce_top

}

# (C) 2001-2026 Altera Corporation. All rights reserved.
# Your use of Altera Corporation's design tools, logic functions and other 
# software and tools, and its AMPP partner logic functions, and any output 
# files from any of the foregoing (including device programming or simulation 
# files), and any associated documentation or information are expressly subject 
# to the terms and conditions of the Altera Program License Subscription 
# Agreement, Altera IP License Agreement, or other applicable 
# license agreement, including, without limitation, that your use is for the 
# sole purpose of programming logic devices manufactured by Altera and sold by 
# Altera or its authorized distributors.  Please refer to the applicable 
# agreement for further details.


# (C) 2001-2024 Intel Corporation. All rights reserved.
# Your use of Intel Corporation's design tools, logic functions and other 
# software and tools, and its AMPP partner logic functions, and any output 
# files from any of the foregoing (including device programming or simulation 
# files), and any associated documentation or information are expressly subject 
# to the terms and conditions of the Intel Program License Subscription 
# Agreement, Intel FPGA IP License Agreement, or other applicable 
# license agreement, including, without limitation, that your use is for the 
# sole purpose of programming logic devices manufactured by Intel and sold by 
# Intel or its authorized distributors.  Please refer to the applicable 
# agreement for further details.


proc apply_sdc_ismce_dcfifo {} {
    # gray_rdptr
    apply_sdc_ismce_dcfifo_in_rdptr
    apply_sdc_ismce_dcfifo_out_rdptr
    # gray_wrptr
    apply_sdc_ismce_dcfifo_in_wrptr
    apply_sdc_ismce_dcfifo_out_wrptr
}

#
# common constraint setting proc
#
proc apply_sdc_dcfifo_for_ptrs {from_node_list to_node_list} {
    # control skew for bits
    set_max_skew -from $from_node_list -to $to_node_list -get_skew_value_from_clock_period src_clock_period -skew_value_multiplier 0.8
    # path delay (exception for net delay)
    if { ![string equal "quartus_syn" $::TimeQuestInfo(nameofexecutable)] } {
    set_net_delay -from $from_node_list -to $to_node_list -max -get_value_from_clock_period dst_clock_period -value_multiplier 0.8
    }
    #relax setup and hold calculation
    set_max_delay -from $from_node_list -to $to_node_list 100
    set_min_delay -from $from_node_list -to $to_node_list -100
}
#
# mstable propgation delay
#
proc apply_sdc_dcfifo_mstable_delay {from_node_list to_node_list} {
    # mstable delay
    if { ![string equal "quartus_syn" $::TimeQuestInfo(nameofexecutable)] } {
    set_net_delay -from $from_node_list -to $to_node_list -max -get_value_from_clock_period dst_clock_period -value_multiplier 0.8
}
}
#
# rdptr constraints
#
proc apply_sdc_ismce_dcfifo_in_rdptr {} {
    # get from and to list
    set from_node_list [get_keepers sld_mod_ram_rom_inst|adapter_for_s10_and_beyond.sld_adapter|dc_fifo_in|auto_generated|*rdptr_g*]
    set to_node_list [get_keepers sld_mod_ram_rom_inst|adapter_for_s10_and_beyond.sld_adapter|dc_fifo_in|auto_generated|ws_dgrp|dffpipe*|dffe*]
    if {([get_collection_size $from_node_list] == 0) || ([get_collection_size $to_node_list] == 0)} {
        post_message -type info "Unable to find rdptr nodes or dffe nodes, will not try to apply constraints"
    } else {
        apply_sdc_dcfifo_for_ptrs $from_node_list $to_node_list    
    }
    # mstable
    set from_node_mstable_list [get_keepers sld_mod_ram_rom_inst|adapter_for_s10_and_beyond.sld_adapter|dc_fifo_in|auto_generated|ws_dgrp|dffpipe*|dffe*]
    set to_node_mstable_list [get_keepers sld_mod_ram_rom_inst|adapter_for_s10_and_beyond.sld_adapter|dc_fifo_in|auto_generated|ws_dgrp|dffpipe*|dffe*]
    if {([get_collection_size $from_node_mstable_list] == 0) || ([get_collection_size $to_node_mstable_list] == 0)} {
        post_message -type info "Unable to find dffe nodes, will not try to apply constraints"
    } else {
        apply_sdc_dcfifo_mstable_delay $from_node_mstable_list $to_node_mstable_list
    }
}
proc apply_sdc_ismce_dcfifo_out_rdptr {} {
    # get from and to list
    set from_node_list [get_keepers sld_mod_ram_rom_inst|adapter_for_s10_and_beyond.sld_adapter|dc_fifo_out|auto_generated|*rdptr_g*]
    set to_node_list [get_keepers sld_mod_ram_rom_inst|adapter_for_s10_and_beyond.sld_adapter|dc_fifo_out|auto_generated|ws_dgrp|dffpipe*|dffe*]
    if {([get_collection_size $from_node_list] == 0) || ([get_collection_size $to_node_list] == 0)} {
        post_message -type info "Unable to find rdptr nodes or dffe nodes, will not try to apply constraints"
    } else {
        apply_sdc_dcfifo_for_ptrs $from_node_list $to_node_list    
    }
    # mstable
    set from_node_mstable_list [get_keepers sld_mod_ram_rom_inst|adapter_for_s10_and_beyond.sld_adapter|dc_fifo_out|auto_generated|ws_dgrp|dffpipe*|dffe*]
    set to_node_mstable_list [get_keepers sld_mod_ram_rom_inst|adapter_for_s10_and_beyond.sld_adapter|dc_fifo_out|auto_generated|ws_dgrp|dffpipe*|dffe*]
    if {([get_collection_size $from_node_mstable_list] == 0) || ([get_collection_size $to_node_mstable_list] == 0)} {
        post_message -type info "Unable to find dffe nodes, will not try to apply constraints"
    } else {
        apply_sdc_dcfifo_mstable_delay $from_node_mstable_list $to_node_mstable_list
    }
}
#
# wrptr constraints
#
proc apply_sdc_ismce_dcfifo_in_wrptr {} {
    # control skew for bits
    set from_node_list [get_keepers sld_mod_ram_rom_inst|adapter_for_s10_and_beyond.sld_adapter|dc_fifo_in|auto_generated|delayed_wrptr_g*]
    set to_node_list [get_keepers sld_mod_ram_rom_inst|adapter_for_s10_and_beyond.sld_adapter|dc_fifo_in|auto_generated|rs_dgwp|dffpipe*|dffe*]
    if {([get_collection_size $from_node_list] == 0) || ([get_collection_size $to_node_list] == 0)} {
        post_message -type info "Unable to find wrptr nodes or dffe nodes, will not try to apply constraints"
    } else {
        apply_sdc_dcfifo_for_ptrs $from_node_list $to_node_list    
    }
    # mstable
    set from_node_mstable_list [get_keepers sld_mod_ram_rom_inst|adapter_for_s10_and_beyond.sld_adapter|dc_fifo_in|auto_generated|rs_dgwp|dffpipe*|dffe*]
    set to_node_mstable_list [get_keepers sld_mod_ram_rom_inst|adapter_for_s10_and_beyond.sld_adapter|dc_fifo_in|auto_generated|rs_dgwp|dffpipe*|dffe*]
    if {([get_collection_size $from_node_mstable_list] == 0) || ([get_collection_size $to_node_mstable_list] == 0)} {
        post_message -type info "Unable to find dffe nodes, will not try to apply constraints"
    } else {
        apply_sdc_dcfifo_mstable_delay $from_node_mstable_list $to_node_mstable_list
    }
}

proc apply_sdc_ismce_dcfifo_out_wrptr {} {
    # control skew for bits
    set from_node_list [get_keepers sld_mod_ram_rom_inst|adapter_for_s10_and_beyond.sld_adapter|dc_fifo_out|auto_generated|delayed_wrptr_g*]
    set to_node_list [get_keepers sld_mod_ram_rom_inst|adapter_for_s10_and_beyond.sld_adapter|dc_fifo_out|auto_generated|rs_dgwp|dffpipe*|dffe*]
    if {([get_collection_size $from_node_list] == 0) || ([get_collection_size $to_node_list] == 0)} {
        post_message -type info "Unable to find wrptr nodes or dffe nodes, will not try to apply constraints"
    } else {
        apply_sdc_dcfifo_for_ptrs $from_node_list $to_node_list    
    }
    # mstable
    set from_node_mstable_list [get_keepers sld_mod_ram_rom_inst|adapter_for_s10_and_beyond.sld_adapter|dc_fifo_out|auto_generated|rs_dgwp|dffpipe*|dffe*]
    set to_node_mstable_list [get_keepers sld_mod_ram_rom_inst|adapter_for_s10_and_beyond.sld_adapter|dc_fifo_out|auto_generated|rs_dgwp|dffpipe*|dffe*]
    if {([get_collection_size $from_node_mstable_list] == 0) || ([get_collection_size $to_node_mstable_list] == 0)} {
        post_message -type info "Unable to find dffe nodes, will not try to apply constraints"
    } else {
        apply_sdc_dcfifo_mstable_delay $from_node_mstable_list $to_node_mstable_list
    }
}

apply_sdc_ismce_dcfifo

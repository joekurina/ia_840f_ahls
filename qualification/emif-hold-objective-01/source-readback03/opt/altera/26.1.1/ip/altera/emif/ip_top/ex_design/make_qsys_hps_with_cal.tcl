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


package require -exact qsys 17.0

if {! [info exists ip_params] || ! [info exists ed_params]} {
   source "params.tcl"
}

set ip_param_lst [list]
foreach param_name [array names ip_params] {
   lappend ip_param_lst $param_name
   lappend ip_param_lst $ip_params($param_name)
}

set cal_param_names  [list DIAG_SIM_CAL_MODE_ENUM       \
                           DIAG_EXTRA_CONFIGS           \
                           DIAG_EXPORT_VJI              \
                           DIAG_SYNTH_FOR_SIM           \
                           SHORT_QSYS_INTERFACE_NAMES   \
                           DIAG_EXPORT_SEQ_AVALON_SLAVE \
                           DIAG_ENABLE_JTAG_UART        \
                     ] 


set calbus_ifs                [list "emif_calbus_0"]
set calbus_if                 [lindex $calbus_ifs 0]

set emif $ed_params(EMIF_NAME)
set emif_module $ed_params(EMIF_MODULE_NAME)

create_system
set_project_property DEVICE_FAMILY $ip_params(SYS_INFO_DEVICE_FAMILY)
set_project_property DEVICE $ed_params(DEFAULT_DEVICE)


set_validation_property AUTOMATIC_VALIDATION false

add_instance emif_cal altera_emif_cal
set_instance_parameter_value emif_cal NUM_CALBUS_INTERFACE [llength $calbus_ifs]
foreach param_name $cal_param_names {
   set_instance_parameter_value emif_cal $param_name $ip_params($param_name)
}

add_instance $emif $emif_module

set_instance_parameter_values $emif $ip_param_lst

set reset_release_ip_inst_name "reset_release_ip"
add_instance $reset_release_ip_inst_name altera_s10_user_rst_clkgate
set_instance_parameter_value $reset_release_ip_inst_name outputType "Reset Interface"


validate_system
set_validation_property AUTOMATIC_VALIDATION true



foreach if_name [get_instance_interfaces $emif] {

   if {[string first "emif_calbus_clk" $if_name] == 0} {
      add_connection emif_cal.emif_calbus_clk ${emif}.${if_name}
   } elseif {[string first "emif_calbus" $if_name] == 0} {
      add_connection emif_cal.${calbus_if} ${emif}.${if_name}
   } else {

     if {$if_name == "hps_emif"} {
        continue
     }
     if {$if_name == "global_reset_n"} {
        set if_type "reset"
        set if_dir "sink"
     } elseif {$if_name == "pll_ref_clk"} {
        set if_type "clock"
        set if_dir "sink"
     } elseif {$if_name == "oct"} {
        set if_type "conduit"
        set if_dir "end"
     } elseif {$if_name == "mem"} {
        set if_type "conduit"
        set if_dir "end"
     } else {
        set if_type ""
        set if_dir ""
     }

     set exported_if_name "${emif}_${if_name}"
     add_interface $exported_if_name $if_type $if_dir
     set_interface_property $exported_if_name EXPORT_OF "${emif}.${if_name}"
   }
}
add_interface "${reset_release_ip_inst_name}_reset_intf" reset_source "Output"
set_interface_property "${reset_release_ip_inst_name}_reset_intf" EXPORT_OF "${reset_release_ip_inst_name}.ninit_done"


save_system $ed_params(TMP_SYNTH_QSYS_PATH)


save_system $ed_params(TMP_SIM_QSYS_PATH)




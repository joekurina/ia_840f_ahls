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



package provide altera_emif::ip_emif_cal_iossm::main 0.1

package require altera_emif::util::messaging
package require altera_emif::util::math
package require altera_emif::util::qini
package require altera_emif::util::hwtcl_utils
package require altera_emif::util::enums
package require altera_emif::util::enum_defs
package require altera_emif::util::arch_expert
package require altera_emif::util::device_family
package require altera_emif::ip_top::exports

package require altera_emif::arch_common::seq_param_tbl
package require altera_emif::ip_emif_cal_iossm::util
package require altera_emif::ip_emif_cal_iossm::enum_defs
package require altera_emif::ip_emif_cal_iossm::enum_defs_seq_param_tbl

namespace eval ::altera_emif::ip_emif_cal_iossm::main:: {
   
   namespace import ::altera_emif::util::messaging::*
   namespace import ::altera_emif::util::math::*
   namespace import ::altera_emif::util::qini::*
   namespace import ::altera_emif::util::enums::*
   namespace import ::altera_emif::util::hwtcl_utils::*
   namespace import ::altera_emif::util::device_family::*
   namespace import ::altera_emif::ip_emif_cal_iossm::util::*

}


proc ::altera_emif::ip_emif_cal_iossm::main::create_parameters {} {
   add_user_param     NUM_CALBUS_INTERFACE               string    1                              [list  1 2 3 4 5 6 7 8 9 10 11 12 13 14]       ""       ""             ""             ""
   add_user_param     DIAG_SIM_CAL_MODE_ENUM             string    SIM_CAL_MODE_SKIP              [enum_dropdown_entries SIM_CAL_MODE]           ""       ""             ""             DIAG_SIM_CAL_MODE_ENUM
   add_user_param     DIAG_EXPORT_SEQ_AVALON_SLAVE       string    CAL_DEBUG_EXPORT_MODE_DISABLED [enum_dropdown_entries CAL_DEBUG_EXPORT_MODE]  ""       ""             ""             DIAG_EXPORT_SEQ_AVALON_SLAVE
   add_user_param     DIAG_SIM_VERBOSE                   boolean   false                           ""                                            ""       ""             ""             DIAG_SIM_VERBOSE
   add_user_param     ENABLE_DDRT                        boolean   false                           ""                                            ""       ""             ""             ENABLE_DDRT

   add_derived_hdl_param  NUM_CALBUS_USED integer 1
   set_parameter_property NUM_CALBUS_USED VISIBLE false

   add_derived_hdl_param  IOSSM_USE_MODEL integer 1
   set_parameter_property IOSSM_USE_MODEL VISIBLE false
   
   add_user_param     DIAG_SYNTH_FOR_SIM          boolean  false     ""               ""
   add_user_param     DIAG_EXTRA_CONFIGS          string   ""        ""               ""
   add_user_param     DIAG_EXPORT_VJI             boolean  false     ""               ""
   add_user_param     SHORT_QSYS_INTERFACE_NAMES  boolean  true      ""               ""
   add_user_param     DIAG_ENABLE_JTAG_UART       boolean  false     ""               ""       ""             ""             DIAG_ENABLE_JTAG_UART   

   add_derived_hdl_param  USE_SYNTH_FOR_SIM integer 0 
   set_parameter_property USE_SYNTH_FOR_SIM VISIBLE false
   add_derived_hdl_param  USE_SOFT_NIOS integer 0
   set_parameter_property USE_SOFT_NIOS VISIBLE false
   add_derived_hdl_param  IOSSM_SIM_NIOS_PERIOD_PS   integer   [enum_data SEQ_IOPT_SIM_NIOS_CLK_PERIOD_PS VALUE]
   set_parameter_property IOSSM_SIM_NIOS_PERIOD_PS   VISIBLE   false

   foreach gpt_enum [enums_of_type SEQ_GPT] {
      if { $gpt_enum != "SEQ_GPT_INTERFACE_PAR_PTRS" && $gpt_enum != "SEQ_GPT_UFI_CLOCK_SOURCES" } {
         add_derived_hdl_param  $gpt_enum integer 0
         set_parameter_property $gpt_enum VISIBLE false

         if { [enum_data $gpt_enum SIM_DIFF] } {
            add_derived_hdl_param  "SIM_${gpt_enum}" integer 0
            set_parameter_property "SIM_${gpt_enum}" VISIBLE false
         }

      }
   }

   set_parameter_property DIAG_EXPORT_SEQ_AVALON_SLAVE   VISIBLE   true 

   foreach cal_emif_if_enum [enums_of_type IF_EMIF_CAL] {
      set if_enum [enum_data $cal_emif_if_enum IF_ENUM]
      set port_enum_type [enum_data $if_enum PORT_ENUM_TYPE]
      
      foreach port_enum [enums_of_type $port_enum_type] {
         set is_bus [enum_data $port_enum IS_BUS]
         if {$is_bus} {
            add_derived_hdl_param "${port_enum}_WIDTH" integer 1
            set_parameter_property "${port_enum}_WIDTH" VISIBLE false
         }
      }
   }   
   return 1
}

proc ::altera_emif::ip_emif_cal_iossm::main::validate {} {
   set internal_params [list DIAG_SYNTH_FOR_SIM DIAG_EXPORT_VJI SHORT_QSYS_INTERFACE_NAMES] 

   if {[::altera_emif::util::qini::ini_is_on "emif_enable_ddrt_gen"]} {
      set_parameter_property ENABLE_DDRT VISIBLE true
   } else {
      set_parameter_property ENABLE_DDRT VISIBLE false
   }

   if {[::altera_emif::util::qini::ini_is_on "emif_show_internal_settings"]} {
      foreach param $internal_params {
         set_parameter_property $param VISIBLE true
      }
   } else {
      foreach param $internal_params {
         set_parameter_property $param VISIBLE false
      }
   }
}

proc ::altera_emif::ip_emif_cal_iossm::main::elaboration_callback {} {
   set if_ports [dict create]
   set if_names [dict create]
   
   foreach cal_if_enum [enums_of_type IF_EMIF_CAL] {
      set if_enum           [enum_data $cal_if_enum IF_ENUM]
      set num_of_ifs_in_rtl [enum_data $cal_if_enum NUM_IN_RTL]

      dict set if_names $if_enum [dict create]
      
      if {$if_enum == "IF_CALBUS"} {
         set ports [get_interface_ports $if_enum]
         set if_dir NORMAL_DIR
      } elseif {$if_enum == "IF_CAL_DEBUG"} {
         set ports [get_interface_ports $if_enum]
         set if_dir NORMAL_DIR
      } elseif {$if_enum == "IF_CAL_DEBUG_CLK" || $if_enum == "IF_CAL_DEBUG_RESET" || $if_enum == "IF_CALBUS_CLK"} {
         set ports [::altera_emif::util::hwtcl_utils::get_default_ports $if_enum]
         set if_dir NORMAL_DIR
      } else {
         set ports [::altera_emif::util::hwtcl_utils::get_default_ports $if_enum]
         set if_dir NORMAL_DIR
      }
         
      dict set if_ports $if_enum $ports

      for {set i 0} {$i < $num_of_ifs_in_rtl} {incr i} {
         if {$if_enum == "IF_CALBUS"} {
           set if_index $i
         } else {
           set if_index [expr {$num_of_ifs_in_rtl == 1} ? -1 : $i]
         } 

         if {$i < [get_num_of_interfaces_used $if_enum]} {
            set if_enabled true
         } else {
            set if_enabled false
         }
         
         set if_name [::altera_emif::util::hwtcl_utils::add_qsys_interface $if_enabled $if_enum $if_index $if_dir $ports]
         
         dict set if_names $if_enum $i $if_name
      }
   }
   
   _set_interface_properties $if_names 
   _derive_port_width_parameters $if_ports
   _derive_hard_nios_parameters  

   set_parameter_value NUM_CALBUS_USED [get_parameter_value NUM_CALBUS_INTERFACE]
   set_parameter_value USE_SYNTH_FOR_SIM [get_parameter_value DIAG_SYNTH_FOR_SIM]

   if {[get_parameter_value "ENABLE_DDRT"] == true || [get_parameter_value DIAG_SIM_CAL_MODE_ENUM] == "SIM_CAL_MODE_FULL"} {
     set_parameter_value IOSSM_USE_MODEL 0;
   }


   set gpt_content [_derive_global_param_tbl 0]
   set_extra_configs_overrides gpt_content

   foreach gpt_enum [dict keys $gpt_content] {
     if { $gpt_enum != "SEQ_GPT_INTERFACE_PAR_PTRS" && $gpt_enum != "SEQ_GPT_UFI_CLOCK_SOURCES" } {
        set_parameter_value $gpt_enum [dict get $gpt_content $gpt_enum]
     }

     if { $gpt_enum == "SEQ_GPT_GLOBAL_SKIP_STEPS" } {
        set_parameter_value SIM_SEQ_GPT_GLOBAL_SKIP_STEPS [expr {[enum_data SEQ_CONST_GLOBAL_SKIP_RECEIVING_PARAM_TABLE VALUE] |
                                                          [enum_data SEQ_CONST_GLOBAL_SKIP_CSR_PROGRAMMING VALUE] |
                                                          [enum_data SEQ_CONST_GLOBAL_SKIP_POWERUP_SEQUENCE VALUE] |
                                                          [enum_data SEQ_CONST_GLOBAL_SKIP_OCT_CAL VALUE] |
                                                          [enum_data SEQ_CONST_GLOBAL_SKIP_OCT_RECAL VALUE] |
                                                          [enum_data SEQ_CONST_GLOBAL_SKIP_PLL_CAL VALUE] |
                                                          [enum_data SEQ_CONST_GLOBAL_SKIP_PLL_DCC_CAL VALUE] |
                                                          [enum_data SEQ_CONST_GLOBAL_SKIP_INTERP_BIAS_CAL VALUE]}]
     } elseif { $gpt_enum == "SEQ_GPT_NIOS_CLK_FREQ_KHZ" } {
        set_parameter_value SIM_SEQ_GPT_NIOS_CLK_FREQ_KHZ [expr {int(floor(1000000000.0 / [enum_data SEQ_IOPT_SIM_NIOS_CLK_PERIOD_PS VALUE]))}]
     }

   }

   validate 

   issue_pending_ipgen_e_msg_and_terminate
   
   return 1
}

proc ::altera_emif::ip_emif_cal_iossm::main::get_interface_ports {if_enum} {
   set ports [list]

   switch $if_enum {
      IF_CAL_DEBUG {
         set enabled [expr {([get_num_of_interfaces_used $if_enum] > 0) ? true : false}]
         lappend ports {*}[create_port  $enabled    PORT_CAL_DEBUG_WAITREQUEST        1                  ]
         lappend ports {*}[create_port  $enabled    PORT_CAL_DEBUG_READ               1                  ]
         lappend ports {*}[create_port  $enabled    PORT_CAL_DEBUG_WRITE              1                  ]
         lappend ports {*}[create_port  $enabled    PORT_CAL_DEBUG_ADDRESS            27                 ]
         lappend ports {*}[create_port  $enabled    PORT_CAL_DEBUG_RDATA              32                 ]
         lappend ports {*}[create_port  $enabled    PORT_CAL_DEBUG_WDATA              32                 ]
         lappend ports {*}[create_port  $enabled    PORT_CAL_DEBUG_BYTEEN             4                  ]
         lappend ports {*}[create_port  $enabled    PORT_CAL_DEBUG_RDATA_VALID        1                  ]
      }
      IF_CALBUS {
         set enabled [expr {([get_num_of_interfaces_used $if_enum] > 0) ? true : false}]
         lappend ports {*}[create_port  $enabled    PORT_CALBUS_READ                  1                  ]
         lappend ports {*}[create_port  $enabled    PORT_CALBUS_WRITE                 1                  ]
         lappend ports {*}[create_port  $enabled    PORT_CALBUS_ADDRESS               20                 ]
         lappend ports {*}[create_port  $enabled    PORT_CALBUS_WDATA                 32                 ]
         lappend ports {*}[create_port  $enabled    PORT_CALBUS_RDATA                 32                 ]
         lappend ports {*}[create_port  $enabled    PORT_CALBUS_SEQ_PARAM_TBL         4096               ]
      }
      default {
         set ports [::altera_emif::util::hwtcl_utils::get_default_ports $if_enum]
      }
   }
   return $ports
}

proc ::altera_emif::ip_emif_cal_iossm::main::_derive_port_width_parameters {if_ports} {
   foreach if_enum [dict keys $if_ports] {
      set ports [dict get $if_ports $if_enum]
      ::altera_emif::util::hwtcl_utils::derive_port_width_parameters $ports
   }
}

proc ::altera_emif::ip_emif_cal_iossm::main::_derive_hard_nios_parameters {} {
   set_parameter_value    USE_SOFT_NIOS [expr {([get_parameter_value DIAG_EXPORT_SEQ_AVALON_SLAVE] != "CAL_DEBUG_EXPORT_MODE_DISABLED") || ([get_parameter_value "ENABLE_DDRT"] == true) ? 1 : 0}]

}


proc ::altera_emif::ip_emif_cal_iossm::main::get_num_of_interfaces_used {if_enum} {
   set retval 0

   switch $if_enum {
      IF_CAL_DEBUG_CLK -
      IF_CAL_DEBUG_RESET -
      IF_CAL_DEBUG {
         set retval [expr {([get_parameter_value DIAG_EXPORT_SEQ_AVALON_SLAVE] != "CAL_DEBUG_EXPORT_MODE_DISABLED") || ([get_parameter_value "ENABLE_DDRT"] == true) ? 1 : 0}]
      }
      IF_CALBUS_CLK {
         if { [get_parameter_value NUM_CALBUS_INTERFACE] } {
            set retval 1
         } else {
            set retval 0
         }
      }
      IF_CALBUS {
         set num_calbus [get_parameter_value NUM_CALBUS_INTERFACE]
         emif_assert {$num_calbus <  17}
         set retval $num_calbus
      }
      IF_VJI {
         set retval [expr {[get_parameter_value DIAG_EXPORT_VJI] ? 1 : 0}]
      }
      default {
         set retval 0
      }
   }
   return $retval
}



proc ::altera_emif::ip_emif_cal_iossm::main::sim_vhdl_fileset_callback {top_level} {
   sim_verilog_fileset_callback $top_level 1
}

proc ::altera_emif::ip_emif_cal_iossm::main::sim_verilog_fileset_callback {top_level {is_vhd 0}} {
   set rtl_only 0
   set encrypted 0   
   
   set cal_code_hex_filename [get_cal_code_hex_filename $top_level]
   set sim_gpt_hex_filename  [get_sim_gpt_hex_filename $top_level]
   set synth_gpt_hex_filename [get_synth_gpt_hex_filename $top_level]

   set extra_params [list [list SEQ_USE_SIM_PARAMS "\"on\""] \
                          [list IOSSM_CODE_HEX_FILENAME "\"${cal_code_hex_filename}\""] \
                          [list IOSSM_SIM_GPT_HEX_FILENAME "\"${sim_gpt_hex_filename}\""]  \
                          [list IOSSM_SYNTH_GPT_HEX_FILENAME "\"${synth_gpt_hex_filename}\""]]

   set file_paths [concat [_generate_verilog_fileset $top_level] [_generate_common_fileset $top_level]]
   lappend file_paths [::altera_emif::util::hwtcl_utils::generate_dynamic_unique_name_rtl "altera_emif_cal_iossm" "${top_level}_arch" "" ""]
                         
   if {$is_vhd} {
      lappend file_paths [::altera_emif::util::hwtcl_utils::generate_top_level_vhd_wrapper $top_level "${top_level}_arch" $extra_params]
   } else {
      lappend file_paths [::altera_emif::util::hwtcl_utils::generate_top_level_sv_wrapper $top_level "${top_level}_arch" $extra_params]
   }

   foreach file_path $file_paths {
      set tmp [file split $file_path]
      set file_name [lindex $tmp end]
      add_fileset_file $file_name [::altera_emif::util::hwtcl_utils::get_file_type $file_name $rtl_only $encrypted] PATH $file_path
   }  
}

proc ::altera_emif::ip_emif_cal_iossm::main::quartus_synth_fileset_callback {top_level} {
   set rtl_only 0
   set encrypted 0

   set cal_code_hex_filename [get_cal_code_hex_filename $top_level]
   set sim_gpt_hex_filename  [get_sim_gpt_hex_filename $top_level]
   set synth_gpt_hex_filename [get_synth_gpt_hex_filename $top_level]

   set extra_params [list [list SEQ_USE_SIM_PARAMS "\"off\""] \
                          [list IOSSM_CODE_HEX_FILENAME "\"${cal_code_hex_filename}\""] \
                          [list IOSSM_SIM_GPT_HEX_FILENAME "\"${sim_gpt_hex_filename}\""] \
                          [list IOSSM_SYNTH_GPT_HEX_FILENAME "\"${synth_gpt_hex_filename}\""]]

   set file_paths [concat [_generate_verilog_fileset $top_level] [_generate_common_fileset $top_level]]
   lappend file_paths [::altera_emif::util::hwtcl_utils::generate_dynamic_unique_name_rtl "altera_emif_cal_iossm" "${top_level}_arch" "" ""]
   lappend file_paths [::altera_emif::util::hwtcl_utils::generate_top_level_sv_wrapper $top_level "${top_level}_arch" $extra_params]

   foreach file_path $file_paths {
      set tmp [file split $file_path]
      set file_name [lindex $tmp end]
      add_fileset_file $file_name [::altera_emif::util::hwtcl_utils::get_file_type $file_name $rtl_only $encrypted] PATH $file_path
   }  
}


proc ::altera_emif::ip_emif_cal_iossm::main::_set_interface_properties {if_names} {
   if { [get_num_of_interfaces_used IF_CAL_DEBUG] > 0 } {
  
       set cal_debug_clk_name   [dict get $if_names IF_CAL_DEBUG_CLK 0]
       set cal_debug_reset_name [dict get $if_names IF_CAL_DEBUG_RESET 0]
       set_interface_property $cal_debug_reset_name associatedClock $cal_debug_clk_name
  
       foreach if_index [dict keys [dict get $if_names IF_CAL_DEBUG]] {
          set if_name [dict get $if_names IF_CAL_DEBUG $if_index]
          set_interface_property $if_name associatedClock $cal_debug_clk_name
          set_interface_property $if_name associatedReset $cal_debug_reset_name
  
          set symbol_width 8
          set_interface_property $if_name bitsPerSymbol $symbol_width
  
          set_interface_property $if_name maximumPendingReadTransactions 1
  
          set_interface_property $if_name constantBurstBehavior false
  
          set_interface_property $if_name addressUnits SYMBOLS
       }
   }

   set calbus_clk_name   [dict get $if_names IF_CALBUS_CLK 0]
   foreach if_enum [list IF_CALBUS] {
      foreach if_index [dict keys [dict get $if_names $if_enum]] {
         set if_name [dict get $if_names $if_enum $if_index] 
            set_interface_property $if_name associatedClock $calbus_clk_name
      }
   }
}

proc ::altera_emif::ip_emif_cal_iossm::main::_generate_common_fileset {top_level} {
   set file_list [list]

   set sim_cal_code_hex_dst_filename   [get_cal_code_hex_filename $top_level]
   set sim_cal_code_hex_src_filename   [get_cal_code_hex_src_filename "iossm_qii_sim"]

   lappend file_list [copy_to_temp_file $sim_cal_code_hex_src_filename $sim_cal_code_hex_dst_filename]   

   set sim_gpt_hex_filename [get_sim_gpt_hex_filename $top_level]
   set sim_gpt_content      [_derive_global_param_tbl 1]
   set_extra_configs_overrides sim_gpt_content

   set pt_base_addr [enum_data SEQ_IOPT_PARAM_TABLE_BASE VALUE]
   lappend file_list {*}[altera_emif::arch_common::seq_param_tbl::generate_files_by_pt_type $sim_gpt_hex_filename $sim_gpt_content $pt_base_addr SEQ_GPT]

   set synth_gpt_hex_filename [get_synth_gpt_hex_filename $top_level]
   set synth_gpt_content      [_derive_global_param_tbl 0]
   set_extra_configs_overrides synth_gpt_content

   lappend file_list {*}[altera_emif::arch_common::seq_param_tbl::generate_files_by_pt_type $synth_gpt_hex_filename $synth_gpt_content $pt_base_addr SEQ_GPT]
   return $file_list   
}

proc ::altera_emif::ip_emif_cal_iossm::main::_generate_verilog_fileset {top_level} {
   set file_list [list \
      rtl/altera_emif_cal_iossm.sv \
      rtl/altera_emif_f2c_gearbox.sv
   ]
   return $file_list
}


proc ::altera_emif::ip_emif_cal_iossm::main::_derive_global_param_tbl {is_sim} {

   set glob_param_tbl_byte_size [enum_data SEQ_CONST_GLOBAL_PAR_SIZE VALUE]

   set param_tbl_addr           $glob_param_tbl_byte_size

   set glob_param_tbl [dict create]

   foreach gpt_enum [enums_of_type SEQ_GPT] {
      switch $gpt_enum {
         SEQ_GPT_GLOBAL_PAR_VER {
            set val [enum_data SEQ_CONST_CURR_GLOBAL_PAR_VER VALUE]
         }
         SEQ_GPT_NIOS_C_VER {
            set val [enum_data SEQ_CONST_CURR_NIOS_C_VER VALUE]
         }
         SEQ_GPT_COLUMN_ID {
            set val 1
         }
         SEQ_GPT_NUM_IOPACKS {
            set val [enum_data SEQ_GPT_INTERFACE_PAR_PTRS DEPTH]
         }
         SEQ_GPT_NIOS_CLK_FREQ_KHZ {
            if {$is_sim} {
               set val [expr {int(floor(1000000000.0 / [enum_data SEQ_IOPT_SIM_NIOS_CLK_PERIOD_PS VALUE]))}]
            } else {
               set val [enum_data SEQ_CONST_NOMINAL_NIOS_CLK_FREQ_KHZ VALUE]
            }
         }
         SEQ_GPT_PARAM_TABLE_SIZE {
            set glob_param_tbl_byte_size [enum_data SEQ_CONST_GLOBAL_PAR_SIZE VALUE]
            set max_pts_size [expr {[enum_data SEQ_IOPT_PARAM_TABLE_MAX_BYTE_SIZE] * [get_parameter_value NUM_CALBUS_INTERFACE]}]
            set val [expr {$glob_param_tbl_byte_size + $max_pts_size}]
         }
         SEQ_GPT_SLAVE_CLK_DIVIDER {
            set val [enum_data SEQ_IOPT_MAX_CAL_CLK_DIVIDE]
         }
         SEQ_GPT_INTERFACE_PAR_PTRS {
            set val [list [expr {$param_tbl_addr & 0x0000FFFF}]]
            for {set interface_id 1} {$interface_id < [enum_data SEQ_CONST_MAX_NUM_MEM_INTERFACES VALUE]} {incr interface_id} {
               if { $interface_id < [get_parameter_value NUM_CALBUS_INTERFACE] } {
                  set param_tbl_addr [expr {$param_tbl_addr + [enum_data SEQ_IOPT_PARAM_TABLE_MAX_BYTE_SIZE]}]
                  lappend val [expr {($interface_id << 16) | ($param_tbl_addr & 0x0000FFFF)}]
               } else {
                  lappend val 0
               }
            }
         }
         SEQ_GPT_UFI_CLOCK_SOURCES {
            for {set interface_id 0} {$interface_id < [enum_data SEQ_CONST_MAX_NUM_MEM_INTERFACES VALUE]} {incr interface_id} {
               lappend val 0
            }            
         }
         SEQ_GPT_GLOBAL_SKIP_STEPS {
            if {$is_sim} {
              set val [expr {[enum_data SEQ_CONST_GLOBAL_SKIP_RECEIVING_PARAM_TABLE VALUE] |
                             [enum_data SEQ_CONST_GLOBAL_SKIP_CSR_PROGRAMMING VALUE] |
                             [enum_data SEQ_CONST_GLOBAL_SKIP_POWERUP_SEQUENCE VALUE] |
                             [enum_data SEQ_CONST_GLOBAL_SKIP_PLL_CAL VALUE] |
                             [enum_data SEQ_CONST_GLOBAL_SKIP_PLL_DCC_CAL VALUE] | 
                             [enum_data SEQ_CONST_GLOBAL_SKIP_INTERP_BIAS_CAL VALUE]}]
            } else { 
              if {[get_is_es]} {
                set val [expr {[enum_data SEQ_CONST_GLOBAL_SKIP_PLL_DCC_CAL VALUE] | 
                               [enum_data SEQ_CONST_GLOBAL_SKIP_INTERP_BIAS_CAL VALUE]}]
              } else {
                set val [expr {[enum_data SEQ_CONST_GLOBAL_SKIP_PLL_DCC_CAL VALUE]}] 
              }
            }
         }
         SEQ_GPT_GLOBAL_CAL_CONFIG {
 
            set enable_dbg_port [expr {([get_parameter_value "DIAG_EXPORT_SEQ_AVALON_SLAVE"] != "CAL_DEBUG_EXPORT_MODE_DISABLED") || ([get_parameter_value "ENABLE_DDRT"] == true) ? 1 : 0}]
            set dbg_config 0

            if {$enable_dbg_port} {
               set dbg_config [expr {$dbg_config | [enum_data SEQ_CONST_DBG_ENABLED VALUE] |  [enum_data SEQ_CONST_DBG_BITS_VALID VALUE]}]
            }
            
            set enable_jtag_cal_print [get_parameter_value "DIAG_ENABLE_JTAG_UART"]
            if {$enable_jtag_cal_print} {
               set dbg_config [expr {$dbg_config | [enum_data SEQ_CONST_DBG_JTAG_UART_PRINT VALUE]}]
            }

            set val $dbg_config                                                              
         }
         default {
            emif_ie "Unknown sequencer parameter table field $gpt_enum"
         }
      }
      dict set glob_param_tbl $gpt_enum $val
   }
   return $glob_param_tbl
}

proc ::altera_emif::ip_emif_cal_iossm::main::set_extra_configs_overrides {gpt_varname} {

   upvar 1 $gpt_varname gpt_content

   set extra_configs_str [get_parameter_value "DIAG_EXTRA_CONFIGS"]
   set extra_configs [::altera_emif::util::hwtcl_utils::parse_extra_configs $extra_configs_str]

   if {[dict exists $extra_configs SEQ_GLOBAL_SKIP_STEPS_ADD]} {
      set orig [dict get $gpt_content SEQ_GPT_GLOBAL_SKIP_STEPS]
      set curr [expr {$orig | [dict get $extra_configs SEQ_GLOBAL_SKIP_STEPS_ADD]}]
      dict set gpt_content SEQ_GPT_GLOBAL_SKIP_STEPS $curr
   }
   
   if {[dict exists $extra_configs SEQ_GLOBAL_SKIP_STEPS_REMOVE]} {
      set orig [dict get $gpt_content SEQ_GPT_GLOBAL_SKIP_STEPS]
      set curr [expr {$orig & ~[dict get $extra_configs SEQ_GLOBAL_SKIP_STEPS_REMOVE]}]
      dict set gpt_content SEQ_GPT_GLOBAL_SKIP_STEPS $curr
   }
}


proc ::altera_emif::ip_emif_cal_iossm::main::_init {} {
}

::altera_emif::ip_emif_cal_iossm::main::_init


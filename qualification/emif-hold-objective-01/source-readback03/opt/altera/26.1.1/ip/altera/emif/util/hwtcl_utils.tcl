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


package provide altera_emif::util::hwtcl_utils 0.1

package require altera_emif::util::messaging
package require altera_emif::util::qini
package require altera_emif::util::enums
package require altera_emif::util::enum_defs
package require altera_emif::util::enum_defs_interfaces
package require altera_emif::util::math

namespace eval ::altera_emif::util::hwtcl_utils:: {
   namespace export create_port
   namespace export add_user_param
   namespace export add_derived_param
   namespace export add_derived_hdl_param
   namespace export set_param_default
   namespace export add_tab_to_gui
   namespace export add_group_to_gui
   namespace export add_text_to_gui
   namespace export add_table_to_gui
   namespace export add_param_to_gui
   namespace export add_param_to_table

   namespace export get_params_for_doc_gen
   namespace export get_user_displayed_param_for_doc_gen
   namespace export get_group_display_order
   namespace export get_group_full_path

   namespace export generate_qsys_interface_name
   namespace export generate_qsys_interface_name_ex

   namespace export add_long_bitvec_hdl_param
   namespace export set_long_bitvec_hdl_param_value

   namespace export parse_extra_configs
   namespace export extra_config_is_explicit_on
   namespace export extra_config_is_explicit_off
   
   namespace export resolve_pll_ref_clk_in_oct_enum

   namespace export copy_to_temp_file


   namespace import ::altera_emif::util::messaging::*
   namespace import ::altera_emif::util::enums::*
   namespace import ::altera_emif::util::math::*
   
   variable m_params_dict
   variable m_display_params_dict
   variable m_display_groups_dict
}


proc ::altera_emif::util::hwtcl_utils::set_param_default {name val} {
   set_parameter_property $name DEFAULT_VALUE $val
}

proc ::altera_emif::util::hwtcl_utils::add_user_param {\
   name \
   type \
   default_val \
   allowed_ranges \
   {units ""} \
   {display_units ""} \
   {display_hint ""} \
   {resource_name ""}
} {
   variable m_params_dict

   set derived false
   set visible true
   set affects_elab true

   _add_parameter $name $type $default_val $derived $visible $affects_elab false $allowed_ranges $units $display_units $display_hint $resource_name

   if {[info exists ::env(EMIF_HANDBOOK_EXPORT_DIR)]} {   
      if {![dict exists $m_params_dict $name]} {
         set rec [dict create]
         dict set rec ID $name
         dict set rec RESOURCE_NAME [expr {$resource_name == "" ? $name : $resource_name}]
         dict set m_params_dict $name $rec
      }
   }
}

proc ::altera_emif::util::hwtcl_utils::add_derived_param {\
   name \
   type \
   default_val \
   visible \
   {units ""} \
   {display_units ""} \
   {display_hint ""} \
   {resource_name ""}
} {
   set derived true
   set affects_elab true
   set allowed_ranges ""
   _add_parameter $name $type $default_val $derived $visible $affects_elab false $allowed_ranges $units $display_units $display_hint $resource_name
}

proc ::altera_emif::util::hwtcl_utils::add_derived_hdl_param {\
   name \
   type \
   default_val \
   {width 1} \
} {

   add_parameter $name $type $default_val
   set_parameter_property $name HDL_PARAMETER true
   set_parameter_property $name DERIVED true
   set_parameter_property $name AFFECTS_ELABORATION false

   if {$type == "std_logic_vector"} {
      emif_assert { $width <= 32 } "Use add_long_bitvec_hdl_param instead of add_derived_hdl_param for long bit vectors"
      set_parameter_property $name WIDTH $width
   }

   return 1
}

proc ::altera_emif::util::hwtcl_utils::_add_parameter {\
   name \
   type \
   default_val \
   {derived false} \
   {visible true} \
   {affects_elab true} \
   {hdl false} \
   {allowed_ranges ""} \
   {units ""} \
   {display_units ""} \
   {display_hint ""} \
   {resource_name ""}
} {
   add_parameter $name $type $default_val

   if {$derived} {
      set_parameter_property $name DERIVED true
   }

   if {!$visible} {
      set_parameter_property $name VISIBLE false
   }

   if {!$affects_elab} {
      set_parameter_property $name AFFECTS_ELABORATION false
   }

   if {$hdl} {
      set_parameter_property $name HDL_PARAMETER true
   }

   if {$allowed_ranges != ""} {
      set_parameter_property $name ALLOWED_RANGES $allowed_ranges
   }

   if {$units != ""} {
      set_parameter_property $name UNITS $units
   }

   if {$display_units != ""} {
      set_parameter_property $name DISPLAY_UNITS $display_units
   }

   if {$display_hint != ""} {
      set_parameter_property $name DISPLAY_HINT $display_hint
   }

   if {$resource_name == ""} {
      set resource_name $name
   }

   set_parameter_property $name DISPLAY_NAME [get_string PARAM_${resource_name}_NAME]
   set_parameter_property $name DESCRIPTION [get_string PARAM_${resource_name}_DESC]

   return 1
}

proc ::altera_emif::util::hwtcl_utils::add_tab_to_gui {\
   tab_name \
   doc_gen_type_name
} {
   variable m_display_groups_dict
   
   add_display_item "" $tab_name GROUP tab
   
   if {[info exists ::env(EMIF_HANDBOOK_EXPORT_DIR)]} {
      if {![dict exists $m_display_groups_dict $tab_name]} {
         set display_order [dict size $m_display_groups_dict]

         set item_dict [dict create]
         dict set item_dict DISPLAY_ORDER $display_order
         dict set item_dict FULL_PATH $tab_name
         dict set item_dict TYPE $doc_gen_type_name
         dict set m_display_groups_dict $tab_name $item_dict
      }
   }
}

proc ::altera_emif::util::hwtcl_utils::add_group_to_gui {\
   parent \
   group_name \
} {
   variable m_display_groups_dict

   add_display_item $parent $group_name GROUP
   
   if {[info exists ::env(EMIF_HANDBOOK_EXPORT_DIR)]} {
      if {![dict exists $m_display_groups_dict $group_name]} {
   
         if {[dict exists $m_display_groups_dict $parent]} {
            set display_order [dict size $m_display_groups_dict]

            set parent_dict [dict get $m_display_groups_dict $parent]
            set full_path "[dict get $parent_dict FULL_PATH] / $group_name"
            set type [dict get $parent_dict TYPE]

            set item_dict [dict create]
            dict set item_dict DISPLAY_ORDER $display_order
            dict set item_dict FULL_PATH $full_path
            dict set item_dict TYPE $type
            dict set m_display_groups_dict $group_name $item_dict
         }
      }
   }
}

proc ::altera_emif::util::hwtcl_utils::add_param_to_gui {\
   parent \
   param_name \
} {
   variable m_params_dict
   variable m_display_params_dict
   variable m_display_groups_dict

   add_display_item $parent $param_name PARAMETER
   
   if {[info exists ::env(EMIF_HANDBOOK_EXPORT_DIR)]} {
   
      if {[dict exists $m_params_dict $param_name]} {

         if {[dict exists $m_display_groups_dict $parent]} {
            set display_order [dict size $m_display_params_dict]
            dict set m_display_params_dict $param_name $display_order
            dict set m_params_dict $param_name DISPLAY_ORDER $display_order
            
            set group [dict get $m_display_groups_dict $parent]
            dict set m_params_dict $param_name GROUP $parent
            dict set m_params_dict $param_name GROUP_FULL_PATH [dict get $group FULL_PATH]
            dict set m_params_dict $param_name TYPE [dict get $group TYPE]
         }
      }
   }
   return 1
}


proc ::altera_emif::util::hwtcl_utils::get_user_displayed_param_for_doc_gen {param_name} {
   variable m_params_dict
   variable m_display_params_dict
   
   if {[dict exists $m_params_dict $param_name] && [dict exists $m_display_params_dict $param_name]} {
      return [dict get $m_params_dict $param_name]
   } else {
      return [dict create ID ""]
   }
}

proc ::altera_emif::util::hwtcl_utils::get_group_display_order {group_name} {
   variable m_display_groups_dict
   return [dict get $m_display_groups_dict $group_name DISPLAY_ORDER]
}

proc ::altera_emif::util::hwtcl_utils::get_group_full_path {group_name} {
   variable m_display_groups_dict
   return [dict get $m_display_groups_dict $group_name FULL_PATH]
}

proc ::altera_emif::util::hwtcl_utils::add_text_to_gui {\
   parent \
   param_prefix \
   text \
} {
   add_display_item $parent "TEXT_${param_prefix}" text $text
   return 1
}

proc ::altera_emif::util::hwtcl_utils::add_table_to_gui {\
   parent \
   param_prefix \
   hint \
} {
   add_display_item $parent  "TABLE_${param_prefix}" GROUP TABLE
   set_display_item_property "TABLE_${param_prefix}" DISPLAY_HINT $hint

   return 1
}

proc ::altera_emif::util::hwtcl_utils::add_param_to_table {\
   table \
   param \
} {
   add_param_to_gui "TABLE_${table}" $param

   return 1
}
proc ::altera_emif::util::hwtcl_utils::update_gui_texts_visibility {param_prefix visible} {
   foreach item_name [get_display_items] {
      if { [string first "TEXT_${param_prefix}_" $item_name] != -1 } {
         set_display_item_property $item_name VISIBLE $visible
      }
   }
}

proc ::altera_emif::util::hwtcl_utils::update_gui_tables_visibility {param_prefix visible} {
   foreach item_name [get_display_items] {
      if { [string first "TABLE_${param_prefix}_" $item_name] != -1 } {
         set_display_item_property $item_name VISIBLE $visible
      }
   }
}

proc ::altera_emif::util::hwtcl_utils::create_port { \
   enabled \
   type_enum \
   width \
   {meta ""} \
} {
   set is_bus [enum_data $type_enum IS_BUS]

   if {[string compare -nocase $width "default"] == 0} {
      set width [enum_data $type_enum DEFAULT_WIDTH]
   }

   if {$enabled} {
      if {$is_bus} {
         emif_assert {$width >= 1}
      } else {
         emif_assert {$width == 1}
      }
   } else {
      if {$width <= 0} {
         set width 1
      }
   }
   set num_of_ports $width

   set ports [list]
   for {set i 0} {$i < $num_of_ports} {incr i} {
      set port [dict create]
      dict set port ENABLED $enabled
      dict set port TYPE_ENUM $type_enum
      dict set port TILE_INDEX -1
      dict set port LANE_INDEX -1
      dict set port PIN_INDEX -1
      dict set port ABS_PIN_INDEX -1

      dict set port IS_PP_SEC_DATA_GROUP 0

      if {$is_bus} {
         dict set port BUS_INDEX $i
         dict set port BUS_WIDTH $num_of_ports
      } else {
         dict set port BUS_INDEX -1
         dict set port BUS_WIDTH -1
      }

      foreach key [dict keys $meta] {
         set val [dict get $meta $key]
         dict set port $key $val
      }

      lappend ports $port
   }
   return $ports
}

proc ::altera_emif::util::hwtcl_utils::get_default_ports {if_enum} {
   set ports [list]
   set port_enum_type [enum_data $if_enum PORT_ENUM_TYPE]
   foreach port_enum [enums_of_type $port_enum_type] {
      lappend ports {*}[create_port true $port_enum "default"]
   }
   return $ports
}

proc ::altera_emif::util::hwtcl_utils::generate_qsys_interface_name_ex {use_short_name if_enum if_index if_dir} {
   if {$use_short_name} {
      set name    [enum_data $if_enum QSYS_NAME]
   } else {
      set name    [enum_data $if_enum OLD_QSYS_NAME]
      set type    [enum_data $if_enum QSYS_TYPE]
      set dir     [enum_data $if_enum QSYS_DIR]
      set rev_dir [expr {$if_dir == "REVERSE_DIR"}]

      if {$rev_dir} {
         if {[string compare -nocase $dir "master"] == 0} {
            set dir "slave"
         } elseif {[string compare -nocase $dir "slave"] == 0} {
            set dir "master"
         } elseif {[string compare -nocase $dir "source"] == 0} {
            set dir "sink"
         } elseif {[string compare -nocase $dir "sink"] == 0} {
            set dir "source"
         }
      }
      set name "${name}_${type}_${dir}"
   }

   if {$if_index > -1} {
      set name "${name}_${if_index}"
   }
   return $name
}


proc ::altera_emif::util::hwtcl_utils::generate_qsys_interface_name {if_enum if_index if_dir} {
   set use_short_name [get_parameter_value "SHORT_QSYS_INTERFACE_NAMES"]
   return [generate_qsys_interface_name_ex $use_short_name $if_enum $if_index $if_dir]
}

proc ::altera_emif::util::hwtcl_utils::add_qsys_interface {if_enabled if_enum if_index if_dir ports {if_terminated 0} } {

   set name    [enum_data $if_enum QSYS_NAME]
   set type    [enum_data $if_enum QSYS_TYPE]
   set dir     [enum_data $if_enum QSYS_DIR]
   set rev_dir [expr {$if_dir == "REVERSE_DIR"}]

   if {$rev_dir} {
      if {[string compare -nocase $dir "master"] == 0} {
         set dir "slave"
      } elseif {[string compare -nocase $dir "slave"] == 0} {
         set dir "master"
      } elseif {[string compare -nocase $dir "source"] == 0} {
         set dir "sink"
      } elseif {[string compare -nocase $dir "sink"] == 0} {
         set dir "source"
      }
   }

   set name [generate_qsys_interface_name $if_enum $if_index $if_dir]

   add_interface $name $type $dir

   foreach port $ports {
      set port_bus_index [dict get $port BUS_INDEX]

      if {$port_bus_index == 0 || $port_bus_index == -1} {
         set enabled        [dict get $port ENABLED]
         set type_enum      [dict get $port TYPE_ENUM]
         set port_bus_width [dict get $port BUS_WIDTH]
         set port_name      [enum_data $type_enum RTL_NAME]
         set port_role      [enum_data $type_enum QSYS_ROLE]
         set port_dir       [enum_data $type_enum QSYS_DIR]

         if {$type_enum == "PORT_MEM_CK" || $type_enum == "PORT_MEM_CK_N" || $type_enum == "PORT_MEM_CK_BIDIR" || $type_enum == "PORT_MEM_CK_BIDIR_N"} {
            set is_ac_rclk     [enum_data $type_enum IS_AC_RCLK]

            if {$is_ac_rclk && [get_parameter_value PROTOCOL_ENUM] == "PROTOCOL_DDRT"} {
               set port_dir "bidir"
            }
         }
         if {$type == "conduit" && $port_role == ""} {
            set port_role $port_name
         }

         if {$if_index > -1} {
            set port_name "${port_name}_${if_index}"
         }

         if {$rev_dir} {
            if {$port_dir == "input"} {
               set port_dir "output"
            } elseif {$port_dir == "output"} {
               set port_dir "input"
            }
         }

         if {$port_bus_index == -1} {
            add_interface_port $name $port_name $port_role $port_dir 1
         } else {
            add_interface_port $name $port_name $port_role $port_dir $port_bus_width
            set_port_property $port_name VHDL_TYPE STD_LOGIC_VECTOR
         }

         if {!$enabled || $if_terminated} {
            set_port_property $port_name TERMINATION true

            set_port_property $port_name TERMINATION_VALUE 0
         }
         
         set desc [get_string "${type_enum}_DESC"]
         if {$desc != "${type_enum}_DESC"} {
            set_port_property $port_name DESCRIPTION $desc
         }
      }
   }

   set_interface_property $name ENABLED $if_enabled

   return $name
}

proc ::altera_emif::util::hwtcl_utils::rename_exported_interface_ports {instance_name interface_name exported_interface_name} {

   set port_map [list]
   foreach port_name [get_instance_interface_ports $instance_name $interface_name] {
      lappend port_map $port_name
      lappend port_map $port_name
   }
   set_interface_property $exported_interface_name PORT_NAME_MAP $port_map

   return 1
}

proc ::altera_emif::util::hwtcl_utils::derive_port_width_parameters {ports} {
   foreach port $ports {
      set bus_index [dict get $port BUS_INDEX]
      if {$bus_index == 0} {
         set bus_width [dict get $port BUS_WIDTH]
         set port_enum [dict get $port TYPE_ENUM]
         set_parameter_value "${port_enum}_WIDTH" $bus_width
      }
   }
}

proc ::altera_emif::util::hwtcl_utils::get_simulator_attributes {{nomentor 0}} {

   set sim_att_list [list \
      "CADENCE_SPECIFIC" \
      "SYNOPSYS_SPECIFIC" \
      "ALDEC_SPECIFIC" \
   ]

   if {$nomentor == 0} {
      lappend sim_att_list "MENTOR_SPECIFIC"
   }

   return $sim_att_list
}

proc ::altera_emif::util::hwtcl_utils::get_file_type {file_name {rtl_only 1} {encrypted 0} {use_sdc_entity 0}} {

   set file_ext [file extension $file_name]

   if {[regexp -nocase {^[ ]*\.iv[ ]*$} [file extension $file_name]] == 1 } {
      return "VERILOG_INCLUDE"
   } elseif {[regexp -nocase {^[ ]*\.v[ ]*$} [file extension $file_name]] == 1 } {
      if {$encrypted} {
         return "VERILOG_ENCRYPT"
      } else {
         return "VERILOG"
      }
   } elseif {[regexp -nocase {^[ ]*\.sv[ ]*$} [file extension $file_name]] == 1 } {
      if {$encrypted} {
         return "SYSTEM_VERILOG_ENCRYPT"
      } else {
         return "SYSTEM_VERILOG"
      }
   } elseif {[regexp -nocase {^[ ]*\.vho[ ]*$|^[ ]*\.vhd[ ]*$|^[ ]*\.vhdl[ ]*$} [file extension $file_name]] == 1 } {
      return "VHDL"
   } elseif {[regexp -nocase {^[ ]*\.mif[ ]*$} [file extension $file_name]] == 1 } {

         return "MIF"

   } elseif {[regexp -nocase {^[ ]*\.hex[ ]*$} [file extension $file_name]] == 1 } {
      if {$rtl_only} {
         emif_ie "Attempting to return file type $file_ext for file $file_name in RTL only fileset"
      } else {
         return "HEX"
      }
   } elseif {[regexp -nocase {^[ ]*\.dat[ ]*$} [file extension $file_name]] == 1 } {
      if {$rtl_only} {
         emif_ie "Attempting to return file type $file_ext for file $file_name in RTL only fileset"
      } else {
         return "DAT"
      }
   } elseif {[regexp -nocase {^[ ]*\.sdc[ ]*$} [file extension $file_name]] == 1 } {
      if {$rtl_only} {
         emif_ie "Attempting to return file type $file_ext for file $file_name in RTL only fileset"
      } else {
         if {$use_sdc_entity} {
            return "SDC_ENTITY_NOPROMO"
         } else {
            return "SDC"
         }
      }
   } elseif {[regexp -nocase {^[ ]*\.tcl[ ]*$} [file extension $file_name]] == 1 && $use_sdc_entity} {
      return "TCL_ENTITY"
   } elseif {[regexp -nocase {^[ ]*\.xml[ ]*$} [file extension $file_name]] == 1 } {
      if {$rtl_only} {
         emif_ie "Attempting to return file type $file_ext for file $file_name in RTL only fileset"
      } else {
         return "HPS_ISW"
      }
   } else {
      if {$rtl_only} {
         emif_ie "Attempting to return file type $file_ext for file $file_name in RTL only fileset"
      } else {
         return "OTHER"
      }
   }
}

proc ::altera_emif::util::hwtcl_utils::detect_instance_interface_type_and_direction {inst_name if_name} {

   set if_type "conduit"
   foreach if_prop [get_instance_interface_properties $inst_name $if_name] {
      if {$if_prop == "maxChannel"} {
         set if_type "avalon_streaming"
         break
      } elseif {$if_prop == "maximumPendingReadTransactions"} {
         set if_type "avalon"
         break
      } elseif {$if_prop == "clockRate"} {
         set if_type "clock"
         break
      } elseif {$if_prop == "synchronousEdges"} {
         set if_type "reset"
         break
      }
   }

   if {$if_type == "conduit"} {
      set if_dir "end"
   } else {
      set if_dir ""

      foreach port [get_instance_interface_ports $inst_name $if_name] {
         set role [get_instance_port_property $inst_name $port ROLE]
         set dir  [get_instance_port_property $inst_name $port DIRECTION]

         if {$if_type == "avalon_streaming" && $role == "ready"} {
            set if_dir [expr {$dir == "Output" ? "sink" : "source"}]
            break
         } elseif {$if_type == "avalon" && ($role == "waitrequest_n" || $role == "waitrequest")} {
            set if_dir [expr {$dir == "Output" ? "slave" : "master"}]
            break
         } elseif {$if_type == "clock" && $role == "clk"} {
            set if_dir [expr {$dir == "Output" ? "source" : "sink"}]
            break
         } elseif {$if_type == "reset" && $role == "reset_n"} {
            set if_dir [expr {$dir == "Output" ? "source" : "sink"}]
            break
         }
      }

      if {$if_dir == ""} {
         emif_ie "Unable to detect direction for interface $if_name of instance $inst_name"
      }
   }

   return [list $if_type $if_dir]
}

proc ::altera_emif::util::hwtcl_utils::export_all_interfaces_of_sub_component {inst_name} {
   set i 0
   foreach if_name [get_instance_interfaces $inst_name] {

      set data    [detect_instance_interface_type_and_direction $inst_name $if_name]
      set if_type [lindex $data 0]
      set if_dir  [lindex $data 1]

      add_interface $if_name $if_type $if_dir
      set_interface_property $if_name EXPORT_OF "${inst_name}.${if_name}"

      rename_exported_interface_ports $inst_name $if_name $if_name

      incr i
   }
   return $i
}

proc ::altera_emif::util::hwtcl_utils::export_unconnected_interfaces_of_sub_component {inst_name} {
   set connected_ifs [dict create]
   set conns [get_connections]

   foreach conn $conns {
      set sep_index [string first "/" $conn]
      set source [string range $conn 0 [expr {$sep_index - 1}]]
      set sink [string range $conn [expr {$sep_index + 1}] end]
      dict set connected_ifs $source 1
      dict set connected_ifs $sink 1
   }

   set i 0
   foreach if_name [get_instance_interfaces $inst_name] {

      set data    [detect_instance_interface_type_and_direction $inst_name $if_name]
      set if_type [lindex $data 0]
      set if_dir  [lindex $data 1]

      set sub_if "${inst_name}.${if_name}"

      if {![dict exists $connected_ifs $sub_if]} {
         add_interface $if_name $if_type $if_dir
         set_interface_property $if_name EXPORT_OF $sub_if

         rename_exported_interface_ports $inst_name $if_name $if_name

         incr i
      }
   }
   return $i
}

proc ::altera_emif::util::hwtcl_utils::add_unused_interface_ports {if_enum ports_varname} {
   upvar 1 $ports_varname ports

   set existing_ports [dict create]
   foreach port $ports {
      set type_enum [dict get $port TYPE_ENUM]
      dict set existing_ports $type_enum true
   }

   set port_type [enum_data $if_enum PORT_ENUM_TYPE]
   foreach type_enum [enums_of_type $port_type] {
      if {![dict exists $existing_ports $type_enum]} {
         lappend ports {*}[create_port false $type_enum "default"]
      }
   }
}

proc ::altera_emif::util::hwtcl_utils::set_clock_sources_rate_properties {\
   emif_usr_clk_pri_if_name \
   emif_usr_half_clk_pri_if_name \
   emif_usr_clk_sec_if_name \
   emif_usr_half_clk_sec_if_name \
   afi_clk_if_name \
   afi_half_clk_if_name \
} {

   set mem_clk_freq_mhz     [get_parameter_value PHY_MEM_CLK_FREQ_MHZ]
   set usr_clk_ratio        [enum_data [get_parameter_value PHY_RATE_ENUM] RATIO]
   set usr_clk_freq_hz      [expr {round($mem_clk_freq_mhz * 1000000.0 / $usr_clk_ratio)}]
   set usr_half_clk_freq_hz [expr {round($usr_clk_freq_hz / 2)}]

   if {$emif_usr_clk_pri_if_name != "" && [get_interface_property $emif_usr_clk_pri_if_name ENABLED]} {
      set_interface_property $emif_usr_clk_pri_if_name clockRateKnown true
      set_interface_property $emif_usr_clk_pri_if_name clockRate $usr_clk_freq_hz
   }
   if {$emif_usr_clk_sec_if_name != "" && [get_interface_property $emif_usr_clk_sec_if_name ENABLED]} {
      set_interface_property $emif_usr_clk_sec_if_name clockRateKnown true
      set_interface_property $emif_usr_clk_sec_if_name clockRate $usr_clk_freq_hz
   }
   if {$emif_usr_half_clk_pri_if_name != "" && [get_interface_property $emif_usr_half_clk_pri_if_name ENABLED]} {
      set_interface_property $emif_usr_half_clk_pri_if_name clockRateKnown true
      set_interface_property $emif_usr_half_clk_pri_if_name clockRate $usr_half_clk_freq_hz
   }
   if {$emif_usr_half_clk_sec_if_name != "" && [get_interface_property $emif_usr_half_clk_sec_if_name ENABLED]} {
      set_interface_property $emif_usr_half_clk_sec_if_name clockRateKnown true
      set_interface_property $emif_usr_half_clk_sec_if_name clockRate $usr_half_clk_freq_hz
   }
   if {$afi_clk_if_name != "" && [get_interface_property $afi_clk_if_name ENABLED]} {
      set_interface_property $afi_clk_if_name clockRateKnown true
      set_interface_property $afi_clk_if_name clockRate $usr_clk_freq_hz
   }
   if {$afi_half_clk_if_name != "" && [get_interface_property $afi_half_clk_if_name ENABLED]} {
      set_interface_property $afi_half_clk_if_name clockRateKnown true
      set_interface_property $afi_half_clk_if_name clockRate $usr_half_clk_freq_hz
   }
}

proc ::altera_emif::util::hwtcl_utils::set_ctrl_amm_if_properties {amm_if_name amm_if_props} {
   set_interface_property $amm_if_name bitsPerSymbol [dict get $amm_if_props SYMBOL_WIDTH]

   set_interface_property $amm_if_name maximumPendingReadTransactions 64

   set_interface_property $amm_if_name constantBurstBehavior false

   set_interface_assignment $amm_if_name embeddedsw.configuration.isMemoryDevice 1
   set_interface_assignment $amm_if_name embeddedsw.configuration.isNonVolatileStorage 0
}

proc ::altera_emif::util::hwtcl_utils::generate_top_level_sv_wrapper {top_level inner_entity_name {extra_params_for_inner_entity {}}} {

   set param_declrs  [list]
   set param_maps    [list]

   foreach param [get_parameters] {
      if {[get_parameter_property $param HDL_PARAMETER]} {
         set type  [string tolower [get_parameter_property $param TYPE]]
         set width [get_parameter_property $param WIDTH]

         if {$type == "integer"} {
            set init_val "0"
         } elseif {$type == "float"} {
            set init_val "0.0"
         } elseif {$type == "string"} {
            set init_val "\"\""
         } elseif {$type == "std_logic_vector"} {
            set init_val "${width}'b[string repeat "0" $width]"
         } elseif {$type == "boolean"} {
            set init_val "0"
         } else {
            emif_ie "Unsupported parameter type $type"
         }

         lappend param_maps   ".${param} ($param)"
         lappend param_declrs "parameter [format "%-50s" $param] = $init_val"
      }
   }

   foreach param_struct $extra_params_for_inner_entity {
      set param_name [lindex $param_struct 0]
      set param_val  [lindex $param_struct 1]
      lappend param_maps ".${param_name} ($param_val)"
   }

   set port_declrs  [list]
   set port_maps    [list]

   foreach if [get_interfaces] {
      foreach port [get_interface_ports $if] {
         set direction  [string tolower [get_port_property $port DIRECTION]]
         set vhdl_type  [string tolower [get_port_property $port VHDL_TYPE]]
         set width_val  [get_port_property $port WIDTH_VALUE]
         set ac_rclk    [string tolower [get_port_property $port DIRECTION]]
 

         if {$vhdl_type == "std_logic_vector"} {
            set end   [expr {$width_val - 1}]
            set range "\[$end:0\]"
         } else {
            set range ""
         }

         if {$direction == "bidir"} {
            set direction   "inout"
            set type        "tri"
         } elseif {$direction == "output"} {
            set type        "logic"
         } else {
            set type        "logic"
         }

         lappend port_maps   ".$port ($port)"
         lappend port_declrs "[format "%-6s" $direction] [format "%-5s" $type] [format "%-10s" $range] $port"
      }
   }

   set filename "${top_level}.sv"
   set file     [create_temp_file $filename]
   set fh       [open $file "w"]

   puts $fh "module $top_level #("
   puts $fh "   [join $param_declrs ",\n   "]"
   puts $fh ") ("
   puts $fh "   [join $port_declrs ",\n   "]"
   puts $fh ");"
   puts $fh "   timeunit 1ns;"
   puts $fh "   timeprecision 1ps;"
   puts $fh ""
   puts $fh "   $inner_entity_name # ("
   puts $fh "      [join $param_maps ",\n      "]"
   puts $fh "   ) arch_inst ("
   puts $fh "      [join $port_maps ",\n      "]"
   puts $fh "   );"
   puts $fh "endmodule"

   close $fh
   return $file
}

proc ::altera_emif::util::hwtcl_utils::generate_top_level_vhd_wrapper {top_level inner_entity_name {extra_params_for_inner_entity {}}} {

   set generic_declrs                  [list]
   set generic_declrs_for_inner_entity [list]
   set generic_maps                    [list]

   foreach param [get_parameters] {
      if {[get_parameter_property $param HDL_PARAMETER]} {
         set type  [string tolower [get_parameter_property $param TYPE]]
         set width [get_parameter_property $param WIDTH]

         if {$type == "integer"} {
            set init_val "0"
         }  elseif {$type == "string"} {
            set init_val "\"\""
         } elseif {$type == "std_logic_vector"} {
            set init_val "\"[string repeat "0" $width]\""
            set end      [expr {$width - 1}]
            set type     "std_logic_vector($end downto 0)"
         } elseif {$type == "boolean"} {
            set init_val "false"
         } else {
            emif_ie "Unsupported parameter type $type"
         }

         lappend generic_maps                    "$param => $param"
         lappend generic_declrs                  "[format "%-50s" $param] : [format "%-40s" $type] := $init_val"
         lappend generic_declrs_for_inner_entity "[format "%-50s" $param] : [format "%-40s" $type] := $init_val"
      }
   }

   foreach param_struct $extra_params_for_inner_entity {
      set param_name [lindex $param_struct 0]
      set param_val  [lindex $param_struct 1]

      lappend generic_maps "$param_name => $param_val"

      lappend generic_declrs_for_inner_entity "[format "%-50s" $param_name] : [format "%-40s" "string"] := \"\""
   }

   set port_declrs  [list]
   set port_maps    [list]

   foreach if [get_interfaces] {
      foreach port [get_interface_ports $if] {
         set direction  [string tolower [get_port_property $port DIRECTION]]
         set vhdl_type  [string tolower [get_port_property $port VHDL_TYPE]]
         set width_val  [get_port_property $port WIDTH_VALUE]

         if {$vhdl_type == "std_logic_vector"} {
            set end   [expr {$width_val - 1}]
            set type  "std_logic_vector($end downto 0)"
         } else {
            set type  "std_logic"
         }

         if {$direction == "bidir"} {
            set direction   "inout"
         } elseif {$direction == "output"} {
            set direction   "out"
         } else {
            set direction   "in"
         }

         lappend port_maps   "$port => $port"
         lappend port_declrs "[format "%-30s" $port] : [format "%-5s" $direction] $type"
      }
   }

   set filename "${top_level}.vhd"
   set file     [create_temp_file $filename]
   set fh       [open $file "w"]

   puts $fh "library IEEE;"
   puts $fh "use IEEE.std_logic_1164.all;"
   puts $fh "use IEEE.numeric_std.all;"
   puts $fh ""
   puts $fh "entity $top_level is"
   puts $fh "   generic ("
   puts $fh "      [join $generic_declrs ";\n      "]"
   puts $fh "   );"
   puts $fh "   port ("
   puts $fh "      [join $port_declrs ";\n      "]"
   puts $fh "   );"
   puts $fh "end entity $top_level;"
   puts $fh ""
   puts $fh "architecture rtl of $top_level is"
   puts $fh "   component $inner_entity_name is"
   puts $fh "      generic ("
   puts $fh "         [join $generic_declrs_for_inner_entity ";\n         "]"
   puts $fh "      );"
   puts $fh "      port ("
   puts $fh "         [join $port_declrs ";\n         "]"
   puts $fh "      );"
   puts $fh "   end component $inner_entity_name;"
   puts $fh ""
   puts $fh "begin"
   puts $fh "   arch_inst : component $inner_entity_name"
   puts $fh "      generic map ("
   puts $fh "         [join $generic_maps ",\n         "]"
   puts $fh "      )"
   puts $fh "      port map ("
   puts $fh "         [join $port_maps ",\n         "]"
   puts $fh "      );"
   puts $fh "end architecture rtl;"

   close $fh
   return $file
}

proc ::altera_emif::util::hwtcl_utils::generate_dynamic_unique_name_rtl {source_file dynamic_file search_str replace_str} {

   set fp [open [file join "rtl" "$source_file.sv"] r]
   set file_data [read $fp]
   close $fp

   regsub -all $source_file $file_data $dynamic_file file_data
   regsub -all $search_str $file_data $replace_str file_data

   set file     [create_temp_file "$dynamic_file.sv"]
   set fh       [open $file w+]
   puts $fh $file_data
   close $fh
   return $file
}

proc ::altera_emif::util::hwtcl_utils::add_long_bitvec_hdl_param {\
   name \
   width \
} {
   set num_of_words [expr {int(ceil($width * 1.0 / 30))}]

   for {set i 0} {$i < $num_of_words} {incr i} {
      set word_param_name "${name}_${i}"
      add_parameter $word_param_name integer 0
      set_parameter_property $word_param_name HDL_PARAMETER true
      set_parameter_property $word_param_name DERIVED true
      set_parameter_property $word_param_name AFFECTS_ELABORATION false
   }

   set num_words_param_name "${name}_AUTOGEN_WCNT"
   add_parameter $num_words_param_name integer $num_of_words
   set_parameter_property $num_words_param_name HDL_PARAMETER true
   set_parameter_property $num_words_param_name DERIVED true
   set_parameter_property $num_words_param_name AFFECTS_ELABORATION false

   return 1
}

proc ::altera_emif::util::hwtcl_utils::set_long_bitvec_hdl_param_value {\
   name \
   val
} {

   set end_pos [expr {[string length $val] - 1}]
   set word_i  0

   while {$end_pos >= 0} {
      set bgn_pos [expr {$end_pos >= 29 ? ($end_pos - 29) : 0}]
      set word    [string range $val $bgn_pos $end_pos]
      set end_pos [expr {$bgn_pos - 1}]

      set_parameter_value "${name}_${word_i}" [bin2num $word]
      incr word_i
   }
}

proc ::altera_emif::util::hwtcl_utils::parse_extra_configs {str} {
   set retval [dict create]
   foreach item [split $str ",; "] {
      set tmp [split $item "="]
      if {[llength $tmp] == 2} {
         set name [string toupper [lindex $tmp 0]]
         set val [lindex $tmp 1]
         dict set retval $name $val
      }
   }
   return $retval
}

proc ::altera_emif::util::hwtcl_utils::extra_config_is_explicit_on {extra_configs setting} {
   if {[dict exists $extra_configs $setting] && [dict get $extra_configs $setting]} {
      return 1
   } else {
      return 0
   }
}

proc ::altera_emif::util::hwtcl_utils::extra_config_is_explicit_off {extra_configs setting} {
   if {[dict exists $extra_configs $setting] && ![dict get $extra_configs $setting]} {
      return 1
   } else {
      return 0
   }
}

proc ::altera_emif::util::hwtcl_utils::copy_to_temp_file {ifn ofn} {
   set temp_ofn  [create_temp_file $ofn]
   set ifh       [open $ifn r]
   set ofh       [open $temp_ofn w]
   
   fconfigure $ifh -translation binary
   fconfigure $ofh -translation binary
   
   set blob [read $ifh]
   puts -nonewline $ofh $blob

   close $ofh
   close $ifh
   return $temp_ofn
}

proc ::altera_emif::util::hwtcl_utils::resolve_pll_ref_clk_in_oct_enum {io_std_enum} {
   if { ($io_std_enum == "IO_STD_LVDS") || ($io_std_enum == "IO_STD_TRUE_DIFF_SIGNALING")} {
      set retval "IN_OCT_DIFFERENTIAL"
   } elseif {($io_std_enum == "IO_STD_LVDS_NO_OCT") || ($io_std_enum == "IO_STD_TRUE_DIFF_SIGNALING_NO_OCT")} {
      set retval "IN_OCT_0"
   } else {
      set retval "IN_OCT_INVALID"
   }
}


proc ::altera_emif::util::hwtcl_utils::_init {} {
   variable m_params_dict
   variable m_display_params_dict
   variable m_display_groups_dict

   set m_params_dict [dict create]
   set m_display_params_dict [dict create]
   set m_display_groups_dict [dict create]

   return 1
}


::altera_emif::util::hwtcl_utils::_init

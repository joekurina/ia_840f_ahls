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


proc ::mem_ss_pkg::ip_mem_ss::serialize_arrays_to_list {args} {
   set separator "~"
   set flat_list [list]
   foreach arr $args {
      if {[llength $flat_list] == 0} {
         set flat_list [concat $flat_list                   [uplevel 1 [list array get $arr]] ]
      } else {
         set flat_list [concat $flat_list [list $separator] [uplevel 1 [list array get $arr]] ]
      }
   }

   if {0} {
      puts "***** serialize_arrays_to_list *****"
      foreach arr $args {
         uplevel 1 [list parray $arr]
         puts ""
      }
      puts "**************************************"
   }

   return $flat_list
}

proc ::mem_ss_pkg::ip_mem_ss::deserialize_list_to_arrays {flat_list args} {
   set separator "~"
   foreach sub_list [split $flat_list $separator] \
           arr      $args {
      uplevel 1 "if {\[info exists $arr\]} { array unset $arr }; array set $arr \[list $sub_list\]"
   }

   if {0} {
      puts "***** deserialize_list_to_arrays *****"
      foreach arr $args {
         uplevel 1 [list parray $arr]
         puts ""
      }
      puts "**************************************"
   }
}

proc ::mem_ss_pkg::ip_mem_ss::mem_intfs_loc_update_callback {param_name} {
   set mem_locations [table get parameters -> MEM_INTFS_LOCATION -> VALUE]
   foreach mem_idx [table get parameters -> MEM_INTFS_IDX -> VALUE] \
           mem_type [table get parameters -> MEM_INTFS_TYPE -> VALUE] \
           mem_loc $mem_locations {
      if {$mem_type == "M20K"} {
         lset mem_locations $mem_idx "M20K"
      }
      if {$mem_type != "M20K" && $mem_loc == "M20K"} {
         lset mem_locations $mem_idx "TOP"
      }
   }
   table set parameters -> MEM_INTFS_LOCATION -> VALUE $mem_locations
}

proc ::mem_ss_pkg::ip_mem_ss::one_to_one_action_callback {} {
   set total_app_ports 0
   foreach app_type [table get parameters -> APP_INTFS_TYPE -> VALUE] {
      set num_app_ports [expr { [table get range__APP_INTFS_TYPE -> $app_type -> COLLAPSE_PORTS] ? 1 : [table get range__APP_INTFS_TYPE -> $app_type -> MAX_PORTS] }]
      incr total_app_ports $num_app_ports
   }

   set i 0
   foreach param [table rows parameters {MEM_CH_[0-9]*_CONNS}] {
      if {![string is true -strict [table get parameters -> $param -> VISIBLE]]} {
         break
      }

      set conn_val [lrepeat $total_app_ports 0]
      lset conn_val $i 1

      table set parameters -> $param -> VALUE $conn_val
      incr i
   }
}

proc ::mem_ss_pkg::ip_mem_ss::all_to_all_action_callback {} {
   set total_app_ports 0
   foreach app_type [table get parameters -> APP_INTFS_TYPE -> VALUE] {
      set num_app_ports [expr { [table get range__APP_INTFS_TYPE -> $app_type -> COLLAPSE_PORTS] ? 1 : [table get range__APP_INTFS_TYPE -> $app_type -> MAX_PORTS] }]
      incr total_app_ports $num_app_ports
   }

   set conn_val [lrepeat $total_app_ports 1]

   foreach param [table rows parameters {MEM_CH_[0-9]*_CONNS}] {
      if {![string is true -strict [table get parameters -> $param -> VISIBLE]]} {
         break
      }

      table set parameters -> $param -> VALUE $conn_val
   }
}

proc ::mem_ss_pkg::ip_mem_ss::clear_action_callback {} {
   set total_app_ports 0
   foreach app_type [table get parameters -> APP_INTFS_TYPE -> VALUE] {
      set num_app_ports [expr { [table get range__APP_INTFS_TYPE -> $app_type -> COLLAPSE_PORTS] ? 1 : [table get range__APP_INTFS_TYPE -> $app_type -> MAX_PORTS] }]
      incr total_app_ports $num_app_ports
   }

   set conn_val [lrepeat $total_app_ports 0]

   foreach param [table rows parameters {MEM_CH_[0-9]*_CONNS}] {
      table set parameters -> $param -> VALUE $conn_val
   }
}

proc ::mem_ss_pkg::ip_mem_ss::remove_board_action_callback {} {
   foreach param [table rows parameters "EX_DESIGN_BOARD_*"] {
      table set parameters -> $param -> VALUE ""
   }
}

proc ::mem_ss_pkg::ip_mem_ss::validate {} {
   variable mem_conns
   variable app_conns
   variable mem_label
   variable app_label
   variable mem_ports
   variable app_ports


   if {[pval SYSINFO_DEVICE_FAMILY] == ""} {
      return 0
   }

   if {![pval RUN_COMPOSE]} {
      send_message warning "IPs within Memory Subsystem are disabled. Please enable '[table get parameters -> RUN_COMPOSE -> DISPLAY_NAME]' to enable the IPs."
   }

   set device [string trim [table get parameters -> SYSINFO_DEVICE -> VALUE]]
   if {$device == "" || [string compare -nocase $device "unknown"] == 0} {
      send_message warning "No FPGA device is selected under 'View'->'Device Family'. Fileset generation assumes a production device of the fastest device speedgrade and may skip device compatibility checks."
   }

   set curr_device_family  [table get parameters -> SYSINFO_DEVICE_FAMILY -> VALUE]
   set curr_device_part    [table get parameters -> SYSINFO_DEVICE -> VALUE]

   set ip_core             [lindex [table rows package] 0]
   set ip_display_name     [table get package -> $ip_core -> DISPLAY_NAME]
   set supported_die_types [table get package -> $ip_core -> SUPPORTED_DIE_TYPES]
   foreach die_rev [split [table get parameters -> SYSINFO_DEVICE_DIE_REVISIONS -> VALUE] { }] {
      if {[string match "MAIN_*" $die_rev]} {
         set match 0
         foreach supported_die_type $supported_die_types {
            if {[string match "${supported_die_type}_*" $die_rev]} {
               set match 1
               break
            }
         }
         if {!$match} {
            send_message error "<html>Component <b>$ip_core</b> (\"$ip_display_name\") does not support selected device <b>$curr_device_part</b> ($curr_device_family)</html>"
            return
         }
      }
   }

   send_message info "<html>Configuring IP for device <b>$curr_device_part</b> ($curr_device_family, speedgrade [pval SYSINFO_DEVICE_SPEEDGRADE])</html>"


   table unset DIAG_EXTRA_PARAMETERS
   foreach item [split [pval DIAG_EXTRA_PARAMETERS] ",; "] {
      set key_val [split $item "="]
      if {[llength $key_val] == 2} {
         lassign $key_val key val
         set key [string trim $key " "]
         set val [string trim $val " "]
         table create DIAG_EXTRA_PARAMETERS [list \
            [list @     VALUE ] \
            [list $key  $val  ] \
         ]
      }
   }


   if {[info exists mem_conns]} { array unset mem_conns; }; array set mem_conns {};
   if {[info exists app_conns]} { array unset app_conns; }; array set app_conns {};
   if {[info exists mem_label]} { array unset mem_label; }; array set mem_label {};
   if {[info exists app_label]} { array unset app_label; }; array set app_label {};
   if {[info exists mem_ports]} { array unset mem_ports; }; array set mem_ports {};
   if {[info exists app_ports]} { array unset app_ports; }; array set app_ports {};

   set mem_port_idx 0
   foreach mem_dev [pval MEM_INTFS_TYPE] \
           mem_idx [pval MEM_INTFS_IDX] {
      set max_mem_ports    [table get range__MEM_INTFS_TYPE -> $mem_dev -> MAX_PORTS]
      set is_mem_collapsed [table get range__MEM_INTFS_TYPE -> $mem_dev -> COLLAPSE_PORTS]
      foreach mem_port [range $max_mem_ports] {

         set app_port_idx 0
         foreach app_intf [pval APP_INTFS_TYPE] \
                 app_idx  [pval APP_INTFS_IDX] {
            set max_app_ports    [table get range__APP_INTFS_TYPE -> $app_intf -> MAX_PORTS]
            set is_app_collapsed [table get range__APP_INTFS_TYPE -> $app_intf -> COLLAPSE_PORTS]
            foreach app_port [range $max_app_ports] {

               set is_connected [lindex [pval MEM_CH_${mem_port_idx}_CONNS] $app_port_idx]
               if {$is_connected == 1} {
                  lappend mem_conns(m${mem_idx}_p${mem_port}) a${app_idx}_p${app_port}
                  lappend app_conns(a${app_idx}_p${app_port}) m${mem_idx}_p${mem_port}

                  set     mem_label(m${mem_idx}_p${mem_port}) $mem_dev
                  set     app_label(a${app_idx}_p${app_port}) $app_intf

                  lappend mem_ports(m${mem_idx}) $mem_port
                  lappend app_ports(a${app_idx}) $app_port
               }

               incr app_port_idx [expr {$is_app_collapsed ? 0 : 1}]
            }
            incr app_port_idx [expr {$is_app_collapsed ? 1 : 0}]
         }
         incr mem_port_idx [expr {$is_mem_collapsed ? 0 : 1}]
      }
      incr mem_port_idx [expr {$is_mem_collapsed ? 1 : 0}]
   }

   foreach {mem ports} [array get mem_ports] {
      set mem_ports($mem) [lsort -integer -unique $ports]
   }
   foreach {app ports} [array get app_ports] {
      set app_ports($app) [lsort -integer -unique $ports]
   }

   if {0} {
      puts "************* data flow *************"
      parray mem_conns
      puts ""
      parray app_conns
      puts ""
      parray app_label
      puts ""
      parray mem_label
      puts ""
      parray mem_ports
      puts ""
      parray app_ports
      puts "*************************************"
   }


   set all_subips [list {*}[get_all_enabled_instances] {*}[get_all_disabled_instances]]

   set mem_count [dict create]
   foreach mem_type [pval MEM_INTFS_TYPE] {
      set ip_inst_regexp [table get range__MEM_INTFS_TYPE -> $mem_type -> IP_INST_REGEXP]
      dict incr mem_count $ip_inst_regexp
   }
   dict for {ip_inst_regexp count} $mem_count {
      set max_count [llength [lsearch -all -regexp $all_subips $ip_inst_regexp]]
      if {$max_count > 0 && $count > $max_count} {
         set mem_types_label [list]
         foreach mem_type [table rows range__MEM_INTFS_TYPE] {
            set ip_inst_regexp_ [table get range__MEM_INTFS_TYPE -> $mem_type -> IP_INST_REGEXP]
            if {$ip_inst_regexp_ == $ip_inst_regexp} {
               lappend mem_types_label "'[get_string RANGE_MEM_INTFS_TYPE_${mem_type}_NAME]'"
            }
         }
         send_message error "Maximum number of [join $mem_types_label { + }] memory interfaces is $max_count"
      }
   }

   set app_count [dict create]
   foreach app_type [pval APP_INTFS_TYPE] {
      set ip_inst_regexp [table get range__APP_INTFS_TYPE -> $app_type -> IP_INST_REGEXP]
      dict incr app_count $ip_inst_regexp
   }
   dict for {ip_inst_regexp count} $app_count {
      set max_count [llength [lsearch -all -regexp $all_subips $ip_inst_regexp]]
      if {$max_count > 0 && $count > $max_count} {
         set app_types_label [list]
         foreach app_type [table rows range__APP_INTFS_TYPE] {
            set ip_inst_regexp_ [table get range__APP_INTFS_TYPE -> $app_type -> IP_INST_REGEXP]
            if {$ip_inst_regexp_ == $ip_inst_regexp} {
               lappend app_types_label "'[get_string RANGE_APP_INTFS_TYPE_${app_type}_NAME]'"
            }
         }
         send_message error "Maximum number of [join $app_types_label { + }] application interfaces is $max_count"
      }
   }



   set app_labels [list]
   foreach app_type [pval APP_INTFS_TYPE] \
           app_idx  [pval APP_INTFS_IDX] {
      set max_ports [table get range__APP_INTFS_TYPE -> $app_type -> MAX_PORTS]
      set collapse  [table get range__APP_INTFS_TYPE -> $app_type -> COLLAPSE_PORTS]
      if {$collapse} {
         lappend app_labels [format [get_string GUI_APP_TYPE_${app_type}_PORT_ALL_NAME] $app_idx]
      } else {
         for {set app_port 0} {$app_port < $max_ports} {incr app_port} {
            lappend app_labels [format [get_string GUI_APP_TYPE_${app_type}_PORT_${app_port}_NAME] $app_idx]
         }
      }
   }
   table set parameters -> MEM_CONNS_LABELS -> VALUE $app_labels

   foreach mem_type [pval MEM_INTFS_TYPE] \
           mem_idx  [pval MEM_INTFS_IDX] {
      set max_ports [table get range__MEM_INTFS_TYPE -> $mem_type -> MAX_PORTS]
      set collapse  [table get range__MEM_INTFS_TYPE -> $mem_type -> COLLAPSE_PORTS]
      if {$collapse} {
         lappend mem_labels [format [get_string GUI_MEM_TYPE_${mem_type}_PORT_ALL_NAME] $mem_idx]
      } else {
         for {set mem_port 0} {$mem_port < $max_ports} {incr mem_port} {
            lappend mem_labels [format [get_string GUI_MEM_TYPE_${mem_type}_PORT_${mem_port}_NAME] $mem_idx]
         }
      }
   }
   set n [llength [table rows parameters {MEM_CH_[0-9]*_CONNS}]]
   for {set col 0} {$col < $n} {incr col} {
      if {$col < [llength $mem_labels]} {
         table set parameters -> MEM_CH_${col}_CONNS -> VISIBLE      true
         table set parameters -> MEM_CH_${col}_CONNS -> DISPLAY_NAME [lindex $mem_labels $col]
      } else {
         table set parameters -> MEM_CH_${col}_CONNS -> VISIBLE      false
      }
   }

   table set display_items -> ONE_TO_ONE_CONN -> ENABLED [expr { [llength $app_labels] == [llength $mem_labels] }]
   table set display_items -> ALL_TO_ALL_CONN -> ENABLED [expr { !("ASSOC_STORAGE" in [pval APP_INTFS_TYPE]) }]


   foreach mem_idx [pval MEM_INTFS_IDX] {
      if {[llength [array names mem_conns "m${mem_idx}_*"]] == 0} {
         send_message warning "Memory interface #$mem_idx is not instantiated since it has no Data Flow connections"
      }
   }
   foreach app_idx [pval APP_INTFS_IDX] {
      if {[llength [array names app_conns "a${app_idx}_*"]] == 0} {
         send_message warning "Application interface #$app_idx is not instantiated since it has no Data Flow connections"
      }
   }

   foreach mem_idx  [pval MEM_INTFS_IDX] \
           mem_type [pval MEM_INTFS_TYPE] {
      set connected_apps [dict create]
      set unique_apps    [dict create]
      foreach {mem_port app_port_list} [array get mem_conns "m${mem_idx}_*"] {
         foreach app_port $app_port_list {
            set app_idx  [string trimleft [lindex [split $app_port "_"] 0] "a"]
            set app_type $app_label($app_port)

            if {![dict exists $unique_apps $app_idx]} {
               dict incr connected_apps $app_type
               dict set unique_apps $app_idx 1
            }
         } 
      }

      set legal_apps [table get range__MEM_INTFS_TYPE -> $mem_type -> LEGAL_APPS]
      dict for {app_type count} $connected_apps {
         set found 0
         set max_count 0
         foreach {legal_app_type max_count_} $legal_apps {
            if {[string match $legal_app_type $app_type]} {
               set found 1
               set max_count $max_count_
               break
            }
         }
         set mem_name [get_string RANGE_MEM_INTFS_TYPE_${mem_type}_NAME]
         set app_name [get_string RANGE_APP_INTFS_TYPE_${app_type}_NAME]
         if {$found == 0} {
            send_message error "Memory interface #${mem_idx} '${mem_name}' cannot connect to '${app_name}' application interfaces"
         } elseif {$max_count != -1 && $count > $max_count} {
            send_message error "Memory interface #${mem_idx} '${mem_name}' can connect to a maximum of $max_count '${app_name}' application interfaces"
         }
      }
   }

   foreach app_idx  [pval APP_INTFS_IDX] \
           app_type [pval APP_INTFS_TYPE] {
      set connected_mems [dict create]
      set unique_mems    [dict create]
      foreach {app_port mem_port_list} [array get app_conns "a${app_idx}_*"] {
         foreach mem_port $mem_port_list {
            set mem_idx  [string trimleft [lindex [split $mem_port "_"] 0] "m"]
            set mem_type $mem_label($mem_port)

            if {![dict exists $unique_mems $mem_idx]} {
               dict incr connected_mems $mem_type
               dict set unique_mems $mem_idx 1
            }
         } 
      }

      set legal_mems [table get range__APP_INTFS_TYPE -> $app_type -> LEGAL_MEMS]
      dict for {mem_type count} $connected_mems {
         set found 0
         set max_count 0
         foreach {legal_mem_type max_count_} $legal_mems {
            if {[string match $legal_mem_type $mem_type]} {
               set found 1
               set max_count $max_count_
               break
            }
         }
         set app_name [get_string RANGE_APP_INTFS_TYPE_${app_type}_NAME]
         set mem_name [get_string RANGE_MEM_INTFS_TYPE_${mem_type}_NAME]
         if {$found == 0} {
            send_message error "Application interface #${app_idx} '${app_name}' cannot connect to '${mem_name}' memory interfaces"
         } elseif {$max_count != -1 && $count > $max_count} {
            send_message error "Application interface #${app_idx} '${app_name}' can connect to a maximum of $max_count '${mem_name}' memory interfaces"
         }
      }
   }

   set family          [table get device_features -> family -> VALUE]
   set allow_xbar_expr [table get family_features -> ALLOW_XBAR_EXPR -> $family]
   set allow_xbar      [expr $allow_xbar_expr]
   if {!$allow_xbar} {
      foreach {mem_port app_port_list} [array get mem_conns] {
         if {[llength $app_port_list] > 1} {
            set mem_idx  [string trimleft [lindex [split $mem_port "_"] 0] "m"]
            set mem_type $mem_label($mem_port)
            set mem_name [get_string RANGE_MEM_INTFS_TYPE_${mem_type}_NAME]
            if {[llength $app_port_list] == 2 && [lindex [split [lindex $app_port_list 0] "_"] 0] == [lindex [split [lindex $app_port_list 1] "_"] 0]} {
            } else {
               send_message error "Memory interface #${mem_idx} '${mem_name}' is connected to multiple application interfaces, only 1-to-1 data-flow connections are permitted"
            }
         }
      }
      foreach {app_port mem_port_list} [array get app_conns] {
         if {[llength $mem_port_list] > 1} {
            set app_idx  [string trimleft [lindex [split $app_port "_"] 0] "a"]
            set app_type $app_label($app_port)
            set app_name [get_string RANGE_APP_INTFS_TYPE_${app_type}_NAME]
            send_message error "Application interface #${app_idx} '${app_name}' is connected to multiple memory interfaces, only 1-to-1 data-flow connections are permitted"
         }
      }
   }

   foreach app_idx  [pval APP_INTFS_IDX] \
           app_type [pval APP_INTFS_TYPE] {
      if {$app_type == "ASSOC_STORAGE"} {
         set app_name [get_string RANGE_APP_INTFS_TYPE_${app_type}_NAME]
         if {[llength [array names app_conns "a${app_idx}_*"]] == 0} {
            continue
         }
         if {[llength [array names app_conns "a${app_idx}_*"]] != 2} {
            send_message error "Application interface #${app_idx} '${app_name}' cannot have unconnected ports"
         } else {
            set m1 [lindex $app_conns(a${app_idx}_p0) 0]
            set m2 [lindex $app_conns(a${app_idx}_p1) 0]
            if {$mem_label($m1) != $mem_label($m2)} {
               send_message error "Application interface #${app_idx} '${app_name}' cannot use a mix of memory interface types"
            }
            if {$m1 != $m2 && $mem_label($m1) != "M20K" && $mem_label($m2) != "M20K"} {
               send_message error "Application interface #${app_idx} '${app_name}' cannot connect to multiple external memory interfaces"
            }
         }
      }
   }

   table set display_items -> ALL_TO_ALL_CONN -> VISIBLE $allow_xbar


   set board_info_text ""
   set board_preset    [table get parameters -> EX_DESIGN_BOARD_PRESET -> VALUE]
   if {$board_preset == ""} {
      set board_info_text [get_string GUI_EX_DESIGN_BOARD_INFO_NONE_TEXT]
      table set display_items -> REMOVE_BOARD_BUTTON -> ENABLED false
   } else {
      set board_name          [table get parameters -> EX_DESIGN_BOARD_NAME          -> VALUE]
      set board_vendor        [table get parameters -> EX_DESIGN_BOARD_VENDOR        -> VALUE]
      set board_url           [table get parameters -> EX_DESIGN_BOARD_PRODUCT_URL   -> VALUE]
      set board_device_family [table get parameters -> EX_DESIGN_BOARD_DEVICE_FAMILY -> VALUE]
      set board_device_part   [table get parameters -> EX_DESIGN_BOARD_DEVICE_PART   -> VALUE]

      set board_info_text [format [get_string GUI_EX_DESIGN_BOARD_INFO_VALID_TEXT] $board_name $board_vendor $board_url $board_device_family $board_device_part]
      table set display_items -> REMOVE_BOARD_BUTTON -> ENABLED true

      if {$board_device_family != $curr_device_family || $board_device_part != $curr_device_part} {
         set txt "The selected device %s (%s) does not match the %s's device %s (%s). Change device under 'View'->'Device Family'."
         send_message warning [format $txt $curr_device_part $curr_device_family $board_name $board_device_part $board_device_family]
      }

      set txt "The selected board preset is '%s'; do not modify the IP parameters. For verified board test results, the selected board preset name should be <b>bolded</b> in the 'Presets' panel."
      send_message warning [format $txt $board_preset]
   }
   table set display_items -> EX_DESIGN_BOARD_INFO_TEXT -> TEXT $board_info_text
}

proc ::mem_ss_pkg::ip_mem_ss::elaborate {} {
   variable mem_conns
   variable app_conns
   variable mem_label
   variable app_label
   variable mem_ports
   variable app_ports

   if {[table get parameters -> SYSINFO_DEVICE_FAMILY -> VALUE] == ""} {
      return 0
   }



   foreach param [table rows parameters] {
      set param_value($param) "[table get parameters -> $param -> VALUE]"
   }
   set tmp_dir ""
   if {[table get device_features -> family -> VALUE] in [list sm fp]} {
      set tmp_dir [create_temp_file ""]
   }
   set param_value(TMP_DIR) "$tmp_dir"

   set script     ""
   set script_dir "$::env(QUARTUS_ROOTDIR)/../ip/altera/subsystems/mem_ss_pkg/ip_mem_ss"
   switch -- [table get device_features -> family -> VALUE] {
      fmm -
      smp -
      sm -
      fp { set script "source ${script_dir}/edit_qsys_fp.tcl; source ${script_dir}/edit_qsys.tcl" }
      fm { set script "source ${script_dir}/edit_qsys_fm.tcl; source ${script_dir}/edit_qsys.tcl" }
   }

   set start_time [clock clicks -microseconds]
   if {[table get parameters -> RUN_COMPOSE -> VALUE]} {
      set retval [run_system_script TEXT $script [serialize_arrays_to_list param_value mem_conns app_conns mem_label app_label mem_ports app_ports]]
      deserialize_list_to_arrays $retval messages_arr hwtcl_cmds_arr

      foreach hwtcl_cmd $hwtcl_cmds_arr(cmds) {
         eval $hwtcl_cmd
      }

      foreach msg [split $messages_arr(messages) "\n"] {
         send_message error $msg
      }
   } else {
      if {[llength [get_all_enabled_instances]] > 0} {
         run_system_script TEXT {
            package require -exact qsys 24.1
            set_validation_property AUTOMATIC_VALIDATION false
            remove_dangling_connections
            remove_connections [get_connections]
            remove_interfaces [get_interfaces]
            foreach instance [get_instances] { set_instance_property $instance ENABLED false }
         }
      }
   }
   set total_time [expr {[clock clicks -microseconds] - $start_time}]
}


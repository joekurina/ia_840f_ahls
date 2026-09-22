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


package provide altera_emif::arch_common::timing 0.1

package require altera_emif::util::messaging
package require altera_emif::util::math
package require altera_emif::util::qini
package require altera_emif::util::hwtcl_utils
package require altera_emif::util::enums
package require altera_emif::util::enum_defs
package require altera_emif::util::enum_defs_interfaces
package require altera_emif::util::enum_defs_family_traits_and_features
package require altera_emif::util::device_family

namespace eval ::altera_emif::arch_common::timing:: {
   
   namespace import ::altera_emif::util::messaging::*
   namespace import ::altera_emif::util::math::*
   namespace import ::altera_emif::util::qini::*
   namespace import ::altera_emif::util::enums::*
   namespace import ::altera_emif::util::hwtcl_utils::*
   namespace import ::altera_emif::util::device_family::*


}


proc ::altera_emif::arch_common::timing::generate_ip_params_tcl {module ifile_name ofile_prefix if_ports tparams} {

   set tmp [file split $ifile_name]
   set ofile_name [lindex $tmp end]
   set ofile_name [string map "memphy $ofile_prefix" $ofile_name]
   set ofile_name [create_temp_file $ofile_name]
   
   set ifh [open $ifile_name r]
   set ofh [open $ofile_name w] 
   
   while {[gets $ifh line] != -1} {
      puts $ofh $line
   }
   
   puts $ofh "set ::GLOBAL_${module}_corename $module"
   
   puts $ofh ""
   foreach tparam_enum [dict keys $tparams] {
      set tcl_name [enum_data $tparam_enum TCL_NAME]
      set val [dict get $tparams $tparam_enum]
      if {[string compare $val "DDRT"] == 0 && [string compare $tcl_name "PROTOCOL"] == 0} {
          puts $ofh "set [format "%-60s" "var(PROTOCOL)"] DDR4"
      } else { 
          puts $ofh "set [format "%-60s" "var($tcl_name)"] $val"
      }
   }
   
   puts $ofh ""
   foreach tparam_hwtcl_enum [enums_of_type TPARAM_HWTCL] {
      set param_name [enum_data $tparam_hwtcl_enum HWTCL_PARAM]
      set val [get_parameter_value $param_name]
      if {[string first " " $val] != -1 || $val == ""} {
         set val "\"${val}\""
      }
      puts $ofh "set [format "%-60s" "var(${param_name})"] $val"
   }

   puts $ofh ""
   set extra_configs_str [get_parameter_value "DIAG_EXTRA_CONFIGS"]
   set extra_configs [parse_extra_configs $extra_configs_str]

   foreach tparam_extra_config_enum [enums_of_type TPARAM_EXTRA_CONFIG] {
      set config_name [enum_data $tparam_extra_config_enum CONFIG]
      if {[dict exists $extra_configs $config_name]} {
         set val [dict get $extra_configs $config_name]
      } else {
         set ini_name EMIF_$config_name
         set default_val [enum_data $tparam_extra_config_enum DEFAULT]
         set val [::altera_emif::util::qini::get_ini_value $ini_name $default_val]
      }
      if {[string first " " $val] != -1 || $val == ""} {
         set val "\"${val}\""
      }
      puts $ofh "set [format "%-60s" "var(${config_name})"] $val"
   }

   puts $ofh ""
   set patterns [_get_hpath_patterns_to_buffers $if_ports]
   foreach name [dict keys $patterns] {
      set var_name [string toupper $name]
      set val [join [dict get $patterns $name] " \\\n[string repeat " " 71]"]
      puts $ofh "set [format "%-60s" "var($var_name)"] \[list $val\]"
   }
   
   puts $ofh ""
   set family [get_parameter_value FAMILY_ENUM]
   if { ((![enum_same $family FAMILY_AGILEX]) && (![enum_same $family FAMILY_AGILEX_HPS])) } {
      puts $ofh "initialize_emiftcl -protocol \$var(PROTOCOL)"
   }

   puts $ofh "initialize_clock_uncertainty_data"
   
   close $ifh
   close $ofh
   
   return $ofile_name
}

proc ::altera_emif::arch_common::timing::generate_from_template {module ifile_name ofile_prefix} {

   set tmp [file split $ifile_name]
   set ofile_name [lindex $tmp end]
   set ofile_name [string map "memphy $ofile_prefix" $ofile_name]
   set ofile_name [create_temp_file $ofile_name]
   
   set ifh [open $ifile_name r]
   set ofh [open $ofile_name w] 
   
   set spaces "\[ \t\n\]"
   set notspaces "\[^ \t\n\]"   
   
   while {[gets $ifh line] != -1} {
      
      if {[regexp "memphy_${notspaces}*\.tcl" $line] } {
         set line [ string map "memphy $ofile_prefix" $line ]
      } elseif {[regexp "memphy${notspaces}*\.sdc" $line] } {
         set line [ string map "memphy $ofile_prefix" $line ]
      } elseif {[regexp "^proc${spaces}+memphy_" $line] } {
         set line [ string map "memphy $module" $line ]
      } elseif {[regexp {^memphy_\w+} $line] || [regexp {[\s\t\[]memphy_\w+} $line]} {
         set line [ string map "memphy_ ${module}_" $line ] 
      } elseif {[regexp {\$memphy_\w+} $line] } {
         set line [ string map "memphy_ ${module}_" $line ] 
      }
      
      if {[regexp {::GLOBAL_} $line]} {
         set line [ string map "::GLOBAL_ ::GLOBAL_${module}_" $line ]
      } 
      
      puts $ofh $line
   }

   close $ifh
   close $ofh
   
   return $ofile_name
}


proc ::altera_emif::arch_common::timing::_get_hpath_patterns_to_buffers {if_ports} {

   set mem_ports [dict get $if_ports IF_MEM PORTS]
   
   set ac_clk    [list]   
   set ac_clk_n  [list]   
   set ac_sync   [list]   
   set ac_async  [list]   
   set rclk      [list]   
   set rclk_n    [list]   
   set wclk      [list]   
   set wclk_n    [list]   
   set rdata     [list]   
   set wdata     [list]   
   set dm        [list]   
   set dbi       [list]   
   set alert_n   [list]   
   
   foreach mem_port $mem_ports {
      set enabled   [dict get $mem_port ENABLED]
      
      if {$enabled} {
         set is_binned   0
         set bus_index   [dict get $mem_port BUS_INDEX]
         set cal_oct     [dict get $mem_port CAL_OCT]
         set port_enum   [dict get $mem_port TYPE_ENUM]
         set rtl_name    [enum_data $port_enum RTL_NAME]
         set is_ac_clk   [enum_data $port_enum IS_AC_CLK]
         set is_ac       [enum_data $port_enum IS_AC]
         set is_rclk     [enum_data $port_enum IS_RCLK]
         set is_wclk     [enum_data $port_enum IS_WCLK]
         set is_rdata    [enum_data $port_enum IS_RDATA]
         set is_wdata    [enum_data $port_enum IS_WDATA]
         set is_dm       [enum_data $port_enum IS_DM]
         set is_dbi      [enum_data $port_enum IS_DBI]
         set is_alert_n  [expr {$port_enum == "PORT_MEM_ALERT_N"}]
         set is_neg_leg  [enum_data $port_enum IS_NEG_LEG]
         set is_async    [enum_data $port_enum IS_ASYNC]
         set direction   [enum_data $port_enum QSYS_DIR]
         set is_cp_rclk   [enum_data $port_enum IS_CP_RCLK]
         
         if {$is_neg_leg} {
            if {[regexp -lineanchor -nocase {^(.*)_n$} $rtl_name matched pos_leg]} {
               set rtl_name $pos_leg
            }
         }
         set pattern "arch|arch_inst|bufs_inst|gen_${rtl_name}.inst\[$bus_index\].b|"
         append pattern [expr {$cal_oct ? "cal_oct." : "no_oct."}]
         set output_pattern [expr {$is_neg_leg ? "${pattern}obuf_bar|o" : "${pattern}obuf|o"}]
         set input_pattern [expr {$is_neg_leg ? "${pattern}ibuf_bar|i" : "${pattern}ibuf|i"}]
         
         if {$is_ac_clk} {
            if {$is_neg_leg} {
               lappend ac_clk_n $output_pattern
               set is_binned 1
            } else {
               lappend ac_clk $output_pattern
               set is_binned 1
            }
         } 
         if {$is_ac} {
            if {$is_async} {
               if {$direction == "input"} {
                  lappend ac_async $input_pattern
               } else {
                  lappend ac_async $output_pattern
               }
               set is_binned 1
            } else {
               if {$direction == "input"} {
                  lappend ac_sync $input_pattern
               } else {
                  lappend ac_sync $output_pattern
               }
               set is_binned 1
            }
         }
         if {$is_rclk} {
            if {$is_neg_leg} {
               if {$direction == "input"} {
                  if {$is_cp_rclk} {
                     lappend rclk_n $input_pattern
                  }
               } else {
                  lappend rclk_n $output_pattern
               }
               set is_binned 1
            } else {
               if {$direction == "input"} {
                  lappend rclk $input_pattern
               } else {
                  lappend rclk $output_pattern
               }
               set is_binned 1
            }
         }
         if {$is_wclk} {
            if {$is_neg_leg} {
               lappend wclk_n $output_pattern
               set is_binned 1
            } else {
               lappend wclk $output_pattern
               set is_binned 1
            }
         }
         if {$is_rdata} {
            if {$direction == "input"} {
               lappend rdata $input_pattern
            } else {
               lappend rdata $output_pattern
            }
            set is_binned 1
         }
         if {$is_wdata} {
            lappend wdata $output_pattern
            set is_binned 1
         }
         if {$is_dm} {
            lappend dm $output_pattern
            set is_binned 1
         }
         if {$is_dbi} {
            lappend dbi $output_pattern
            set is_binned 1
         }
         if {$is_alert_n} {
            lappend alert_n $input_pattern
            set is_binned 1
         }

         if {!$is_binned} {
            emif_ie "Unhandled pin type"
         }
      }
   }
   return [dict create \
      patterns_ac_clk    $ac_clk \
      patterns_ac_clk_n  $ac_clk_n \
      patterns_ac_sync   $ac_sync \
      patterns_ac_async  $ac_async \
      patterns_rclk      $rclk \
      patterns_rclk_n    $rclk_n \
      patterns_wclk      $wclk \
      patterns_wclk_n    $wclk_n \
      patterns_rdata     $rdata \
      patterns_wdata     $wdata \
      patterns_dm        $dm \
      patterns_dbi       $dbi \
      patterns_alert_n   $alert_n]
}

proc ::altera_emif::arch_common::timing::_init {} {
}

::altera_emif::arch_common::timing::_init

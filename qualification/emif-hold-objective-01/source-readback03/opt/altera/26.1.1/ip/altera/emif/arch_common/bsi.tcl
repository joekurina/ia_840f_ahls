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


package provide altera_emif::arch_common::bsi 0.1

package require altera_emif::util::messaging
package require altera_emif::util::math
package require altera_emif::util::qini
package require altera_emif::util::hwtcl_utils
package require altera_emif::util::enums
package require altera_emif::util::enum_defs
package require altera_emif::util::enum_defs_interfaces
package require altera_emif::util::enum_defs_family_traits_and_features
package require altera_emif::util::device_family

namespace eval ::altera_emif::arch_common::bsi:: {

   namespace import ::altera_emif::util::messaging::*
   namespace import ::altera_emif::util::math::*
   namespace import ::altera_emif::util::qini::*
   namespace import ::altera_emif::util::enums::*
   namespace import ::altera_emif::util::hwtcl_utils::*
   namespace import ::altera_emif::util::device_family::*


}


proc ::altera_emif::arch_common::bsi::generate_ip_params_tcl {module ifile_name ofile_prefix if_ports bparams} {
   set tmp [file split $ifile_name]
   set ofile_name [lindex $tmp end]
   set ofile_name [string map "membsi $ofile_prefix" $ofile_name]
   set ofile_name [create_temp_file $ofile_name]

   set ifh [open $ifile_name r]
   set ofh [open $ofile_name w]

   while {[gets $ifh line] != -1} {
      puts $ofh $line
   }

   puts $ofh ".param emif_corename=str('$module')"

   puts $ofh ""
   foreach bparam_enum [dict keys $bparams] {
      set tcl_name [enum_data $bparam_enum TCL_NAME]
      set val [dict get $bparams $bparam_enum]
      puts $ofh "[format "%-60s" ".param $tcl_name"] = [_hspice_parameter $val]"
   }

   puts $ofh ""
   foreach bparam_hwtcl_enum [enums_of_type BPARAM_HWTCL] {
      set param_name [enum_data $bparam_hwtcl_enum HWTCL_PARAM]
      set val [get_parameter_value $param_name]
      if {[string first " " $val] != -1 || $val == ""} {
         set val "\"${val}\""
      }
      puts $ofh "[format "%-60s" ".param $param_name"] = [_hspice_parameter $val]"
   }

   puts $ofh ""
   set extra_configs_str [get_parameter_value "DIAG_EXTRA_CONFIGS"]
   set extra_configs [parse_extra_configs $extra_configs_str]

   foreach bparam_extra_config_enum [enums_of_type BPARAM_EXTRA_CONFIG] {
      set config_name [enum_data $bparam_extra_config_enum CONFIG]
      if {[dict exists $extra_configs $config_name]} {
         set val [dict get $extra_configs $config_name]
      } else {
         set ini_name EMIF_$config_name
         set default_val [enum_data $bparam_extra_config_enum DEFAULT]
         set val [::altera_emif::util::qini::get_ini_value $ini_name $default_val]
      }
      if {[string first " " $val] != -1 || $val == ""} {
         set val "\"${val}\""
      }
      puts $ofh "[format "%-60s" ".param $config_name"] = [_hspice_parameter $val]"
   }

   close $ifh
   close $ofh

   return $ofile_name

}


proc ::altera_emif::arch_common::bsi::generate_zip_file {module ifile_name ofile_prefix} {
   set tmp [file split $ifile_name]
   set ofile_name [lindex $tmp end]
   set ofile_name [string map "membsi $ofile_prefix" $ofile_name]
   set ofile_name [create_temp_file $ofile_name]

   file copy -force $ifile_name $ofile_name
   
   return $ofile_name
}

proc ::altera_emif::arch_common::bsi::generate_from_template {module ifile_name ofile_prefix} {

   set tmp [file split $ifile_name]
   set ofile_name [lindex $tmp end]
   set ofile_name [string map "membsi $ofile_prefix" $ofile_name]
   set ofile_name [create_temp_file $ofile_name]

   set ifh [open $ifile_name r]
   set ofh [open $ofile_name w]

   set spaces "\[ \t\n\]"
   set notspaces "\[^ \t\n\]"

   while {[gets $ifh line] != -1} {
      if {[regexp "membsi_${notspaces}*\.tcl" $line] } {
         set line [ string map "membsi $ofile_prefix" $line ]
      } elseif {[regexp "membsi${notspaces}*\.sdc" $line] } {
         set line [ string map "membsi $ofile_prefix" $line ]
      } elseif {[regexp "^proc${spaces}+membsi_" $line] } {
         set line [ string map "membsi $module" $line ]
      } elseif {[regexp {^membsi_\w+} $line] || [regexp {[\s\t\[]membsi_\w+} $line]} {
         set line [ string map "membsi_ ${module}_" $line ]
      } elseif {[regexp {\$membsi_\w+} $line] } {
         set line [ string map "membsi_ ${module}_" $line ]
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


proc ::altera_emif::arch_common::bsi::_init {} {
}

proc ::altera_emif::arch_common::bsi::_hspice_parameter {in_text} {
   set retval $in_text
   if {[regexp {^[a-zA-Z_\"]} $in_text]} {
      set retval "str('$in_text')"
   }

   return $retval
}

::altera_emif::arch_common::bsi::_init


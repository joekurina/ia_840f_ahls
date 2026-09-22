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


package provide altera_emif::ip_tg_afi::ip_rld3::main 0.1

package require altera_emif::util::messaging
package require altera_emif::util::math
package require altera_emif::util::qini
package require altera_emif::util::hwtcl_utils
package require altera_emif::util::enums
package require altera_emif::util::enum_defs
package require altera_emif::util::arch_expert
package require altera_emif::util::device_family
package require altera_emif::ip_top::exports
package require altera_emif::ip_tg_afi::util

namespace eval ::altera_emif::ip_tg_afi::ip_rld3::main:: {
   
   namespace import ::altera_emif::util::messaging::*
   namespace import ::altera_emif::util::math::*
   namespace import ::altera_emif::util::qini::*
   namespace import ::altera_emif::util::enums::*
   namespace import ::altera_emif::util::hwtcl_utils::*
   namespace import ::altera_emif::util::device_family::*

}


proc ::altera_emif::ip_tg_afi::ip_rld3::main::create_parameters {} {
     
   ::altera_emif::ip_top::exports::inherit_top_level_parameter_defs
   
   ::altera_emif::ip_tg_afi::util::define_common_hdl_parameters

   set_parameter_property MEM_DATA_MASK_EN                   HDL_PARAMETER true
   
   add_derived_hdl_param MRS_WRITE_PROTOCOL     integer       1
   add_derived_hdl_param MEM_BL                 integer       1
   add_derived_hdl_param TEST_DURATION          string        "SHORT"   

   return 1
}

proc ::altera_emif::ip_tg_afi::ip_rld3::main::elaboration_callback {} {

   if {[get_parameter_value SYS_INFO_DEVICE_FAMILY] == ""} {
      return 0
   }

   ::altera_emif::util::device_family::load_data
   
   set if_ports_names [altera_emif::ip_tg_afi::util::register_interfaces]
   set if_ports [dict get $if_ports_names IF_PORTS]
   set if_names [dict get $if_ports_names IF_NAMES]

   set ninit_done_if_name [dict get $if_names IF_NINIT_DONE 0]
   set_interface_property $ninit_done_if_name synchronousEdges NONE
   
   ::altera_emif::ip_tg_afi::util::derive_common_hdl_parameters $if_ports
   
   set write_protocol_enum       [get_parameter_value "MEM_RLD3_WRITE_PROTOCOL_ENUM"]
   set write_protocol            [enum_data $write_protocol_enum MRS]] 
   set_parameter_value MRS_WRITE_PROTOCOL  $write_protocol  
   
   set_parameter_value MEM_BL                    [get_parameter_value "MEM_RLD3_BL"]
   issue_pending_ipgen_e_msg_and_terminate
   
   set extra_configs_str [get_parameter_value "DIAG_EXTRA_CONFIGS"]
   set extra_configs [parse_extra_configs $extra_configs_str]
   if {[dict exists $extra_configs TG_TEST_DURATION]} {
      set_parameter_value TEST_DURATION [dict get $extra_configs TG_TEST_DURATION]
   } else {
      set_parameter_value TEST_DURATION "SHORT"
   }
   
   return 1
}

proc ::altera_emif::ip_tg_afi::ip_rld3::main::sim_vhdl_fileset_callback {top_level} {
   ::altera_emif::ip_tg_afi::util::sim_vhdl_fileset_callback $top_level [_generate_verilog_fileset]
}

proc ::altera_emif::ip_tg_afi::ip_rld3::main::sim_verilog_fileset_callback {top_level} {
   ::altera_emif::ip_tg_afi::util::sim_verilog_fileset_callback $top_level [_generate_verilog_fileset]
}

proc ::altera_emif::ip_tg_afi::ip_rld3::main::quartus_synth_fileset_callback {top_level} {
   ::altera_emif::ip_tg_afi::util::quartus_synth_fileset_callback $top_level [_generate_verilog_fileset]
}


proc ::altera_emif::ip_tg_afi::ip_rld3::main::_generate_verilog_fileset {} {
   
   set qdir $::env(QUARTUS_ROOTDIR)
	set common_dir "${qdir}/../ip/altera/emif/ip_tg_afi/common/rtl"
   
   set file_list [list \
      rtl/altera_emif_tg_afi_rld3_top.sv
   ]
 
   return $file_list
}

proc ::altera_emif::ip_tg_afi::ip_rld3::main::_init {} {
}

::altera_emif::ip_tg_afi::ip_rld3::main::_init

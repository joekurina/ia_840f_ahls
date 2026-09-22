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


package provide altera_emif::ip_ecc::ip_core_fm::main 0.1

package require altera_emif::util::messaging
package require altera_emif::util::math
package require altera_emif::util::qini
package require altera_emif::util::hwtcl_utils
package require altera_emif::util::enums
package require altera_emif::util::enum_defs
package require altera_emif::util::arch_expert
package require altera_emif::util::device_family
package require altera_emif::ip_top::exports
package require altera_emif::ip_ecc::ip_core_fm::util
package require altera_emif::ip_ecc::ip_core_fm::enum_defs

namespace eval ::altera_emif::ip_ecc::ip_core_fm::main:: {
   
   namespace import ::altera_emif::util::messaging::*
   namespace import ::altera_emif::util::math::*
   namespace import ::altera_emif::util::qini::*
   namespace import ::altera_emif::util::enums::*
   namespace import ::altera_emif::util::hwtcl_utils::*
   namespace import ::altera_emif::util::device_family::*
   namespace import ::altera_emif::ip_ecc::ip_core_fm::util::*

}


proc ::altera_emif::ip_ecc::ip_core_fm::main::create_parameters {} {         
   ::altera_emif::ip_top::exports::inherit_top_level_parameter_defs

   set_parameter_property CTRL_MMR_EN                  HDL_PARAMETER true
   set_parameter_property PHY_PING_PONG_EN             HDL_PARAMETER true
   set_parameter_property DIAG_USE_ABSTRACT_PHY        HDL_PARAMETER true
   set_parameter_property DIAG_SIM_MEMORY_PRELOAD      HDL_PARAMETER true
   set_parameter_property DIAG_SIM_MEMORY_PRELOAD_PRI_ECC_FILE HDL_PARAMETER true
   set_parameter_property DIAG_SIM_MEMORY_PRELOAD_PRI_MEM_FILE HDL_PARAMETER true
   set_parameter_property DIAG_SIM_MEMORY_PRELOAD_PRI_ABPHY_FILE HDL_PARAMETER true
   set_parameter_property DIAG_SIM_MEMORY_PRELOAD_SEC_ECC_FILE HDL_PARAMETER true
   set_parameter_property DIAG_SIM_MEMORY_PRELOAD_SEC_MEM_FILE HDL_PARAMETER true
   set_parameter_property DIAG_SIM_MEMORY_PRELOAD_SEC_ABPHY_FILE HDL_PARAMETER true

   add_derived_hdl_param     USER_CLK_RATIO                   integer        1             
   add_derived_hdl_param     C2P_P2C_CLK_RATIO                integer        1
   add_derived_hdl_param     PHY_HMC_CLK_RATIO                integer        1
   add_derived_hdl_param     USE_AVL_BYTEEN                   integer        1
   add_derived_hdl_param     ENABLE_ECC                       integer        1
   add_derived_hdl_param     ENABLE_ECC_AUTO_CORRECTION       integer        1
   add_derived_hdl_param     REGISTER_RDATA_PATH_NUM          integer        2
   add_derived_hdl_param     REGISTER_WDATA_PATH_NUM          integer        4
   add_derived_hdl_param     REGISTER_UFI_RDATA_PATH_NUM      integer        2
   add_derived_hdl_param     REGISTER_ST_WDATA_RDY_LAT_PATH   integer        2
   add_derived_hdl_param     REGISTER_ST_RDATA_RDY_LAT_PATH   integer        2
   add_derived_hdl_param     REGISTER_ST_CMD_RDY_LAT_PATH     integer        2
   add_derived_hdl_param     REGISTER_CORE_CMD_PIPELINE_WDATA integer        2
   add_derived_hdl_param     MEM_DQ_WIDTH                     integer        1
   add_derived_hdl_param     ECC_MMR_READ_LATENCY             integer        2

   foreach ecc_if_enum [enums_of_type ECC_IF] {
      set if_enum [enum_data $ecc_if_enum IF_ENUM]
      set port_enum_type [enum_data $if_enum PORT_ENUM_TYPE]
      
      foreach port_enum [enums_of_type $port_enum_type] {
         set is_bus [enum_data $port_enum IS_BUS]
         if {$is_bus} {
            add_derived_hdl_param "${port_enum}_WIDTH" integer 1
         }
      }
   }   
   
   return 1
}

proc ::altera_emif::ip_ecc::ip_core_fm::main::elaboration_callback {} {

   if {[get_parameter_value SYS_INFO_DEVICE_FAMILY] == ""} {
      return 0
   }
   
   ::altera_emif::util::device_family::load_data
   
   set ping_pong_en [get_parameter_value PHY_PING_PONG_EN]
   set num_ecc_insts [expr {$ping_pong_en ? 2 : 1}]

   set if_ports [dict create]
   set if_names [dict create]
   
   foreach ecc_if_enum [enums_of_type ECC_IF] {
      set if_enum           [enum_data $ecc_if_enum IF_ENUM]
      set num_of_ifs_in_rtl [enum_data $ecc_if_enum NUM_IN_RTL]

      dict set if_ports $if_enum [dict create]
      dict set if_names $if_enum [dict create]
      
      switch $if_enum {
         IF_CTRL_ECC -
         IF_CTRL_AST_CMD -
         IF_CTRL_AST_WR - 
         IF_CTRL_AST_RD {
            set num_of_ifs_used $num_ecc_insts
            set ports [_get_interface_ports $if_enum]
            set if_dir REVERSE_DIR
         }
         IF_CTRL_MMR_SLAVE -
         IF_CTRL_MMR_MASTER {
            set num_of_ifs_used [expr {[get_parameter_value CTRL_MMR_EN] ? $num_ecc_insts : 0}]
            set ports [_get_interface_ports $if_enum]
            set if_dir NORMAL_DIR
         }
         IF_EMIF_USR_RESET -
         IF_EMIF_USR_RESET_IN -
         IF_EMIF_USR_CLK -
         IF_EMIF_USR_CLK_IN {
            set num_of_ifs_used 1
            set ports [_get_interface_ports $if_enum]
            set if_dir NORMAL_DIR
         }
         IF_EMIF_USR_RESET_SEC -
         IF_EMIF_USR_RESET_SEC_IN -
         IF_EMIF_USR_CLK_SEC -
         IF_EMIF_USR_CLK_SEC_IN {
            if {$ping_pong_en} {
               set num_of_ifs_used 1
            } else {
               set num_of_ifs_used 0
            }
            set ports [_get_interface_ports $if_enum]
            set if_dir NORMAL_DIR
         }
         IF_CTRL_AMM -
         IF_CTRL_ECC_USER_INTERRUPT {
            set num_of_ifs_used $num_ecc_insts
            set ports [_get_interface_ports $if_enum]
            set if_dir NORMAL_DIR
         }
         IF_CTRL_ECC_READDATAERROR {
            set num_of_ifs_used [expr {[get_parameter_value CTRL_ECC_READDATAERROR_EN] ? $num_ecc_insts : 0}]
            set ports [_get_interface_ports $if_enum]
            set if_dir NORMAL_DIR
         }
         IF_CTRL_USER_PRIORITY {
            set num_of_ifs_used [expr {[get_parameter_value CTRL_USER_PRIORITY_EN] ? $num_ecc_insts : 0}]
            set ports [_get_interface_ports $if_enum]
            set if_dir NORMAL_DIR
         }
         IF_CTRL_AUTO_PRECHARGE {
            set num_of_ifs_used [expr {[get_parameter_value CTRL_AUTO_PRECHARGE_EN] ? $num_ecc_insts : 0}]
            set ports [_get_interface_ports $if_enum]
            set if_dir NORMAL_DIR
         }
         IF_CTRL_ECC_STATUS {
            set num_of_ifs_used [expr {[get_parameter_value CTRL_ECC_STATUS_EN] ? 1 : 0}]
            set ports [_get_interface_ports $if_enum]
            set if_dir NORMAL_DIR
         }
         default {
            emif_ie "Unhandled interface $if_name"
         }
      }
         
      dict set if_ports $if_enum PORTS $ports
      dict set if_ports $if_enum INSTS [dict create]

      for {set i 0} {$i < $num_of_ifs_in_rtl} {incr i} {
         set if_index [expr {$num_of_ifs_in_rtl == 1} ? -1 : $i]
         
         if {$i < $num_of_ifs_used} {
            set if_enabled true
         } else {
            set if_enabled false
         }
         
         set if_name [::altera_emif::util::hwtcl_utils::add_qsys_interface $if_enabled $if_enum $if_index $if_dir $ports]
         
         dict set if_names $if_enum $i $if_name

         dict set if_ports $if_enum INSTS $if_index [dict create NAME $if_name ENABLED $if_enabled]
      }
   }
   
   _set_interface_properties $if_names $if_ports

   _derive_protocol_common_parameters
   _derive_port_width_parameters $if_ports
   set ast_if_props [::altera_emif::util::arch_expert::get_interface_properties IF_CTRL_AST_WR]
   set_parameter_value USE_AVL_BYTEEN [expr {[dict get $ast_if_props USE_BYTE_ENABLE] ? 1 : 0}]
   
   _update_qip
    
   issue_pending_ipgen_e_msg_and_terminate
   
   return 1
}

proc ::altera_emif::ip_ecc::ip_core_fm::main::sim_vhdl_fileset_callback {top_level} {
   sim_verilog_fileset_callback $top_level
}

proc ::altera_emif::ip_ecc::ip_core_fm::main::sim_verilog_fileset_callback {top_level} {
   
   set rtl_only 1
   set encrypted 0   
   
   foreach file_path [_generate_verilog_fileset] {
      set tmp [file split $file_path]
      set file_name [lindex $tmp end]
      add_fileset_file $file_name [::altera_emif::util::hwtcl_utils::get_file_type $file_name $rtl_only $encrypted] PATH $file_path
   }   
}

proc ::altera_emif::ip_ecc::ip_core_fm::main::quartus_synth_fileset_callback {top_level} {
   
   set rtl_only 0
   set encrypted 0
   
   foreach file_path [_generate_verilog_fileset] {
      set tmp [file split $file_path]
      set file_name [lindex $tmp end]
      add_fileset_file $file_name [::altera_emif::util::hwtcl_utils::get_file_type $file_name $rtl_only $encrypted] PATH $file_path
   }  
   
   foreach file_path [_generate_common_fileset] {
      set tmp [file split $file_path]
      set file_name [lindex $tmp end]
      add_fileset_file $file_name [::altera_emif::util::hwtcl_utils::get_file_type $file_name $rtl_only $encrypted] PATH $file_path
   }  
}


proc ::altera_emif::ip_ecc::ip_core_fm::main::_get_interface_ports {if_enum} {
   set ports [list]

   switch $if_enum {
      IF_EMIF_USR_RESET_IN -
      IF_EMIF_USR_CLK_IN -
      IF_EMIF_USR_RESET_SEC_IN -
      IF_EMIF_USR_CLK_SEC_IN -
      IF_CTRL_ECC_USER_INTERRUPT -
      IF_CTRL_ECC_READDATAERROR -
      IF_CTRL_ECC_STATUS -
      IF_CTRL_MMR_MASTER -
      IF_CTRL_MMR_SLAVE {
         set ports [::altera_emif::util::hwtcl_utils::get_default_ports $if_enum]
      }
      default {
         set ports [::altera_emif::util::arch_expert::get_interface_ports $if_enum]
      }
   }
   
   return $ports
}

proc ::altera_emif::ip_ecc::ip_core_fm::main::_set_interface_properties {if_names if_ports} {
   
   set ping_pong_en [get_parameter_value "PHY_PING_PONG_EN"]
   
   set emif_usr_clk_pri_in_if_name [dict get $if_names IF_EMIF_USR_CLK_IN 0]
   set emif_usr_clk_sec_in_if_name [dict get $if_names IF_EMIF_USR_CLK_SEC_IN 0]
   set emif_usr_reset_pri_in_if_name [dict get $if_names IF_EMIF_USR_RESET_IN 0]
   set emif_usr_reset_sec_in_if_name [dict get $if_names IF_EMIF_USR_RESET_SEC_IN 0]
      
   set_interface_property $emif_usr_reset_pri_in_if_name synchronousEdges NONE
   set_interface_property $emif_usr_reset_sec_in_if_name synchronousEdges NONE

   set emif_usr_clk_pri_if_name [dict get $if_names IF_EMIF_USR_CLK 0]
   set emif_usr_clk_sec_if_name [dict get $if_names IF_EMIF_USR_CLK_SEC 0]
   set emif_usr_reset_pri_if_name [dict get $if_names IF_EMIF_USR_RESET 0]
   set emif_usr_reset_sec_if_name [dict get $if_names IF_EMIF_USR_RESET_SEC 0]
   
   set_interface_property $emif_usr_reset_pri_if_name synchronousEdges NONE
   set_interface_property $emif_usr_reset_pri_if_name associatedResetSinks [list $emif_usr_reset_pri_in_if_name]
   
   set_interface_property $emif_usr_reset_sec_if_name synchronousEdges NONE
   set_interface_property $emif_usr_reset_sec_if_name associatedResetSinks [list $emif_usr_reset_sec_in_if_name]
   
   altera_emif::util::hwtcl_utils::set_clock_sources_rate_properties $emif_usr_clk_pri_if_name "" $emif_usr_clk_sec_if_name "" "" ""
   
   foreach if_enum [list IF_CTRL_AMM IF_CTRL_AST_CMD IF_CTRL_AST_WR IF_CTRL_AST_RD IF_CTRL_MMR_SLAVE IF_CTRL_MMR_MASTER] {
      foreach if_index [dict keys [dict get $if_names $if_enum]] {
         set if_name [dict get $if_names $if_enum $if_index] 

         switch $if_enum {
            IF_CTRL_AST_CMD -
            IF_CTRL_AST_WR -
            IF_CTRL_AST_RD -
            IF_CTRL_MMR_MASTER {
               if {$ping_pong_en && $if_index == 1} {
                  set_interface_property $if_name associatedClock $emif_usr_clk_sec_in_if_name
                  set_interface_property $if_name associatedReset $emif_usr_reset_sec_in_if_name
               } else {
                  set_interface_property $if_name associatedClock $emif_usr_clk_pri_in_if_name
                  set_interface_property $if_name associatedReset $emif_usr_reset_pri_in_if_name
               }
            }
            default {
               if {$ping_pong_en && $if_index == 1} {
                  set_interface_property $if_name associatedClock $emif_usr_clk_sec_if_name
                  set_interface_property $if_name associatedReset $emif_usr_reset_sec_if_name
               } else {
                  set_interface_property $if_name associatedClock $emif_usr_clk_pri_if_name
                  set_interface_property $if_name associatedReset $emif_usr_reset_pri_if_name
               }
            }
         }
      }
   }
   
   set amm_if_props [::altera_emif::util::arch_expert::get_interface_properties IF_CTRL_AMM]
   foreach if_enum [list IF_CTRL_AMM] {
      foreach if_index [dict keys [dict get $if_ports $if_enum INSTS]] {
         set if_name [dict get $if_ports $if_enum INSTS $if_index NAME]
         ::altera_emif::util::hwtcl_utils::set_ctrl_amm_if_properties $if_name $amm_if_props
      }
   }

   foreach if_enum [list IF_CTRL_MMR_SLAVE IF_CTRL_MMR_MASTER] {
      foreach if_index [dict keys [dict get $if_ports $if_enum INSTS]] {
         set if_name [dict get $if_ports $if_enum INSTS $if_index NAME]
         if { $if_enum == "IF_CTRL_MMR_MASTER"} {
            set_interface_property $if_name addressUnits WORDS
         }

         set_interface_property $if_name bitsPerSymbol 8
         
         if {$if_enum == "IF_CTRL_MMR_SLAVE"} {
            set_interface_property $if_name maximumPendingReadTransactions 1
    
            set_interface_property $if_name constantBurstBehavior false
         }
      }
   }

   set ast_cmd_if_props [::altera_emif::util::arch_expert::get_interface_properties IF_CTRL_AST_CMD]
   set ast_rd_if_props  [::altera_emif::util::arch_expert::get_interface_properties IF_CTRL_AST_RD]
   set ast_wr_if_props  [::altera_emif::util::arch_expert::get_interface_properties IF_CTRL_AST_WR]
   
   foreach if_enum [list IF_CTRL_AST_CMD] {
      foreach if_index [dict keys [dict get $if_ports $if_enum INSTS]] {
         set if_name [dict get $if_ports $if_enum INSTS $if_index NAME]
         set_interface_property $if_name dataBitsPerSymbol [dict get $ast_cmd_if_props SYMBOL_WIDTH]
      }
   }   

   foreach if_enum [list IF_CTRL_AST_RD] {
      foreach if_index [dict keys [dict get $if_ports $if_enum INSTS]] {
         set if_name [dict get $if_ports $if_enum INSTS $if_index NAME]
         set_interface_property $if_name dataBitsPerSymbol [dict get $ast_rd_if_props SYMBOL_WIDTH]
      }
   }   

   foreach if_enum [list IF_CTRL_AST_WR] {
      foreach if_index [dict keys [dict get $if_ports $if_enum INSTS]] {
         set if_name [dict get $if_ports $if_enum INSTS $if_index NAME]
         set_interface_property $if_name dataBitsPerSymbol [dict get $ast_wr_if_props SYMBOL_WIDTH]
      }
   }       
}

proc ::altera_emif::ip_ecc::ip_core_fm::main::_derive_port_width_parameters {if_ports} {
   set ast_if_props   [::altera_emif::util::arch_expert::get_interface_properties IF_CTRL_AST_CMD]

   foreach if_enum [dict keys $if_ports] {
      set ports [dict get $if_ports $if_enum PORTS]
      ::altera_emif::util::hwtcl_utils::derive_port_width_parameters $ports
   }
   return 1
}

proc ::altera_emif::ip_ecc::ip_core_fm::main::_derive_protocol_common_parameters {} {

   set protocol_enum [get_parameter_value "PROTOCOL_ENUM"]

   set phy_config_enum [get_parameter_value "PHY_CONFIG_ENUM"]
   set ratios [::altera_emif::util::arch_expert::get_clk_ratios]

   set_parameter_value USER_CLK_RATIO             [dict get $ratios USER]
   set_parameter_value PHY_HMC_CLK_RATIO          [dict get $ratios PHY_HMC]
   set_parameter_value C2P_P2C_CLK_RATIO          [dict get $ratios C2P_P2C] 
   set_parameter_value ENABLE_ECC                 [get_parameter_value CTRL_ECC_EN]
   
   set mem_clk_freq_mhz  [get_parameter_value "PHY_MEM_CLK_FREQ_MHZ"]
   set c2p_p2c_freq_mhz  [expr {$mem_clk_freq_mhz * 1.0 / [dict get $ratios C2P_P2C]}]


                                                                                            




   set rdata_pipe_stages 2
   
   set wdata_pipe_stages 2
   
   if { [get_is_es] } {
      set ufi_rdata_path_num        2
   } else {
      set ufi_rdata_path_num        0
   }

   set st_wdata_rdy_lat_path     0
   set st_rdata_rdy_lat_path     0
   set st_cmd_rdy_lat_path       0
   set core_cmd_pipeline_wdata   0

   set extra_configs_str [get_parameter_value "DIAG_EXTRA_CONFIGS"]
   set extra_configs [parse_extra_configs $extra_configs_str]
   
   set ecc_extra_config_list [list \
      [list rdata_pipe_stages         ECC_REGISTER_RDATA_PATH_NUM           ] \
      [list wdata_pipe_stages         ECC_REGISTER_WDATA_PATH_NUM           ] \
      [list ufi_rdata_path_num        ECC_REGISTER_UFI_RDATA_PATH_NUM       ] \
      [list st_wdata_rdy_lat_path     ECC_REGISTER_ST_WDATA_RDY_LAT_PATH    ] \
      [list st_rdata_rdy_lat_path     ECC_REGISTER_ST_RDATA_RDY_LAT_PATH    ] \
      [list st_cmd_rdy_lat_path       ECC_REGISTER_ST_CMD_RDY_LAT_PATH      ] \
      [list core_cmd_pipeline_wdata   ECC_REGISTER_CORE_CMD_PIPELINE_WDATA  ] \
   ]

   foreach ecc_extra_config $ecc_extra_config_list {
      set var [lindex $ecc_extra_config 0]
      set val [lindex $ecc_extra_config 1]
      if {[dict exists $extra_configs $ecc_extra_config]} {
         set [set var] [dict get $extra_configs $ecc_extra_config]
      }
   }

   set_parameter_value REGISTER_RDATA_PATH_NUM           $rdata_pipe_stages
   set_parameter_value REGISTER_WDATA_PATH_NUM           $wdata_pipe_stages
   set_parameter_value REGISTER_UFI_RDATA_PATH_NUM       $ufi_rdata_path_num
   set_parameter_value REGISTER_ST_WDATA_RDY_LAT_PATH    $st_wdata_rdy_lat_path
   set_parameter_value REGISTER_ST_RDATA_RDY_LAT_PATH    $st_rdata_rdy_lat_path
   set_parameter_value REGISTER_ST_CMD_RDY_LAT_PATH      $st_cmd_rdy_lat_path
   set_parameter_value REGISTER_CORE_CMD_PIPELINE_WDATA  $core_cmd_pipeline_wdata
   
   if {$protocol_enum == "PROTOCOL_DDR4"} {
      set_parameter_value ENABLE_ECC_AUTO_CORRECTION [expr {[get_parameter_value CTRL_DDR4_ECC_AUTO_CORRECTION_EN] ? 1 : 0}]
      set_parameter_value MEM_DQ_WIDTH               [get_parameter_value MEM_DDR4_DQ_WIDTH]
      
      set hmc_clk_ratio     [dict get $ratios USER]

      if {($hmc_clk_ratio == 4)} {
         if { [get_is_production] } {
            set_parameter_value ECC_MMR_READ_LATENCY 5
         } else {
            set_parameter_value ECC_MMR_READ_LATENCY 6
         }
      } else {
         if { [expr [get_is_production] && $c2p_p2c_freq_mhz >= 400.0] } {
            set_parameter_value ECC_MMR_READ_LATENCY 10
         } else {
            set_parameter_value ECC_MMR_READ_LATENCY 6
         }
      }
   } else {
      emif_ie "Unsupported protocol enum $protocol_enum"
   }
}

proc ::altera_emif::ip_ecc::ip_core_fm::main::_update_qip {} {

   set qip_strings [list ]
   
   lappend qip_strings "set_instance_assignment -entity \"fmiohmc_fifo\" -library \"%libraryName%\" -name MESSAGE_DISABLE 14320"
   lappend qip_strings "set_instance_assignment -entity \"fmiohmc_ecc\" -library \"%libraryName%\" -name MESSAGE_DISABLE 10036"
   
   set_qip_strings $qip_strings
}


proc ::altera_emif::ip_ecc::ip_core_fm::main::_generate_common_fileset {} {
   set file_list [list]
   return $file_list   
}

proc ::altera_emif::ip_ecc::ip_core_fm::main::_generate_verilog_fileset {} {
   set file_list [list \
   rtl/altera_emif_ecc_core.v \
   rtl/altera_emif_preload_ecc_encoder.sv \
   rtl/fmiohmc_ecc.v \
   rtl/fmiohmc_ecc_amm2ast.v \
   rtl/fmiohmc_ecc_cb.v \
   rtl/fmiohmc_ecc_decoder.v \
   rtl/fmiohmc_ecc_decoder_112.v \
   rtl/fmiohmc_ecc_decoder_64.v \
   rtl/fmiohmc_ecc_decoder_64_altecc_decoder.v \
   rtl/fmiohmc_ecc_decoder_64_decode.v \
   rtl/fmiohmc_ecc_encoder.v \
   rtl/fmiohmc_ecc_encoder_112.v \
   rtl/fmiohmc_ecc_encoder_64.v \
   rtl/fmiohmc_ecc_encoder_64_altecc_encoder.v \
   rtl/fmiohmc_ecc_interface_fifo.v \
   rtl/fmiohmc_ecc_mmr.v \
   rtl/fmiohmc_ecc_pcm_112.v \
   rtl/fmiohmc_ecc_sv_112.v \
   rtl/fmiohmc_ecc_wrapper.v \
   rtl/fmiohmc_fifo.v ]

   return $file_list
}

proc ::altera_emif::ip_ecc::ip_core_fm::main::_init {} {
}

::altera_emif::ip_ecc::ip_core_fm::main::_init

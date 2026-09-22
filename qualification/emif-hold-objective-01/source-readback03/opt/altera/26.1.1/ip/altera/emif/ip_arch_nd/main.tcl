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


package provide altera_emif::ip_arch_nd::main 0.1

package require altera_emif::util::messaging
package require altera_emif::util::math
package require altera_emif::util::qini
package require altera_emif::util::hwtcl_utils
package require altera_emif::util::enums
package require altera_emif::util::enum_defs
package require altera_emif::util::enum_defs_interfaces
package require altera_emif::util::enum_defs_family_traits_and_features
package require altera_emif::util::device_family
package require altera_emif::util::doc_gen

package require altera_emif::arch_common::main

package require altera_emif::ip_top::exports

package require altera_emif::ip_arch_nd::enum_defs
package require altera_emif::ip_arch_nd::enum_defs_seq_param_tbl
package require altera_emif::ip_arch_nd::enum_defs_ac_pin_mapping
package require altera_emif::ip_arch_nd::enum_defs_hmc_cfgs
package require altera_emif::ip_arch_nd::protocol_expert
package require altera_emif::ip_arch_nd::pll
package require altera_emif::ip_arch_nd::seq_param_tbl
package require altera_emif::ip_arch_nd::util
package require altera_emif::ip_arch_nd::rtl_autogen
package require altera_emif::ip_arch_nd::doc_gen
package require altera_emif::ip_arch_nd::timing
package require altera_emif::ip_arch_nd::hps

namespace eval ::altera_emif::ip_arch_nd::main:: {

   namespace import ::altera_emif::util::messaging::*
   namespace import ::altera_emif::util::math::*
   namespace import ::altera_emif::util::qini::*
   namespace import ::altera_emif::util::enums::*
   namespace import ::altera_emif::util::hwtcl_utils::*
   namespace import ::altera_emif::util::device_family::*
   namespace import ::altera_emif::ip_arch_nd::util::*
   namespace import ::altera_emif::ip_arch_nd::protocol_expert::*


}


proc ::altera_emif::ip_arch_nd::main::create_parameters {} {

   set max_tiles_per_if 8
   set lanes_per_tile 4
   set pins_per_lane 12

   set max_lanes_per_if     [expr {$max_tiles_per_if * $lanes_per_tile}]
   set max_pins_per_if      [expr {$max_lanes_per_if * $pins_per_lane}]
   set max_dqs_buses_per_if [expr {$max_tiles_per_if * $lanes_per_tile}]

   ::altera_emif::ip_top::exports::inherit_top_level_parameter_defs

   set_parameter_property PROTOCOL_ENUM                 HDL_PARAMETER true
   set_parameter_property PHY_CONFIG_ENUM               HDL_PARAMETER true
   set_parameter_property PHY_PING_PONG_EN              HDL_PARAMETER true
   set_parameter_property PHY_TARGET_IS_ES              HDL_PARAMETER true
   set_parameter_property PHY_TARGET_IS_ES2             HDL_PARAMETER true
   set_parameter_property PHY_TARGET_IS_PRODUCTION      HDL_PARAMETER true
   set_parameter_property PHY_CORE_CLKS_SHARING_ENUM    HDL_PARAMETER true
   set_parameter_property PHY_CALIBRATED_OCT            HDL_PARAMETER true
   set_parameter_property PHY_AC_CALIBRATED_OCT         HDL_PARAMETER true
   set_parameter_property PHY_CK_CALIBRATED_OCT         HDL_PARAMETER true
   set_parameter_property PHY_DATA_CALIBRATED_OCT       HDL_PARAMETER true
   set_parameter_property MEM_FORMAT_ENUM               HDL_PARAMETER true
   set_parameter_property MEM_BURST_LENGTH              HDL_PARAMETER true
   set_parameter_property MEM_DATA_MASK_EN              HDL_PARAMETER true
   set_parameter_property MEM_TTL_DATA_WIDTH            HDL_PARAMETER true
   set_parameter_property MEM_TTL_NUM_OF_READ_GROUPS    HDL_PARAMETER true
   set_parameter_property MEM_TTL_NUM_OF_WRITE_GROUPS   HDL_PARAMETER true
   set_parameter_property DIAG_SIM_REGTEST_MODE         HDL_PARAMETER true
   set_parameter_property DIAG_SYNTH_FOR_SIM            HDL_PARAMETER true
   set_parameter_property DIAG_FAST_SIM                 HDL_PARAMETER true
   set_parameter_property DIAG_SIM_MEMORY_PRELOAD       HDL_PARAMETER true
   set_parameter_property DIAG_SIM_MEMORY_PRELOAD_PRI_EMIF_FILE HDL_PARAMETER true
   set_parameter_property DIAG_SIM_MEMORY_PRELOAD_PRI_ECC_FILE HDL_PARAMETER true
   set_parameter_property DIAG_SIM_MEMORY_PRELOAD_PRI_MEM_FILE HDL_PARAMETER true
   set_parameter_property DIAG_SIM_MEMORY_PRELOAD_PRI_ABPHY_FILE HDL_PARAMETER true
   set_parameter_property DIAG_SIM_MEMORY_PRELOAD_SEC_EMIF_FILE HDL_PARAMETER true
   set_parameter_property DIAG_SIM_MEMORY_PRELOAD_SEC_ECC_FILE HDL_PARAMETER true
   set_parameter_property DIAG_SIM_MEMORY_PRELOAD_SEC_MEM_FILE HDL_PARAMETER true
   set_parameter_property DIAG_SIM_MEMORY_PRELOAD_SEC_ABPHY_FILE HDL_PARAMETER true
   set_parameter_property DIAG_SIM_VERBOSE_LEVEL        HDL_PARAMETER true
   set_parameter_property DIAG_ECLIPSE_DEBUG            HDL_PARAMETER true
   set_parameter_property DIAG_EXPORT_VJI               HDL_PARAMETER true
   set_parameter_property DIAG_INTERFACE_ID             HDL_PARAMETER true
   set_parameter_property DIAG_SEQ_RESET_AUTO_RELEASE   HDL_PARAMETER true
   set_parameter_property DIAG_DB_RESET_AUTO_RELEASE    HDL_PARAMETER true
   set_parameter_property DIAG_USE_ABSTRACT_PHY         HDL_PARAMETER true
   set_parameter_property PLL_NUM_OF_EXTRA_CLKS         HDL_PARAMETER true
   set_parameter_property DIAG_EXPORT_SEQ_AVALON_HEAD_OF_CHAIN         HDL_PARAMETER true

   add_derived_hdl_param     SILICON_REV                    string           ""
   add_derived_hdl_param     IS_HPS                         boolean          false
   add_derived_hdl_param     USER_CLK_RATIO                 integer          1
   add_derived_hdl_param     C2P_P2C_CLK_RATIO              integer          1
   add_derived_hdl_param     PHY_HMC_CLK_RATIO              integer          1
   add_derived_hdl_param     MEM_ROW_ADDR_WIDTH             integer          0
   add_derived_hdl_param     MEM_COL_ADDR_WIDTH             integer          3
   add_derived_hdl_param     DIAG_ABSTRACT_PHY_WLAT         integer          1
   add_derived_hdl_param     DIAG_ABSTRACT_PHY_RLAT         integer          1
   add_derived_hdl_param     DIAG_CPA_OUT_1_EN              boolean          false
   add_derived_hdl_param     DIAG_USE_CPA_LOCK              boolean          true

   add_derived_hdl_param     DQS_BUS_MODE_ENUM              string           ""
   add_derived_hdl_param     AC_PIN_MAP_SCHEME              string           ""
   add_derived_hdl_param     NUM_OF_HMC_PORTS               integer          1
   add_derived_hdl_param     HMC_AVL_PROTOCOL_ENUM          string           ""
   add_derived_hdl_param     HMC_READY_LATENCY              integer          0
   add_derived_hdl_param     HMC_CTRL_DIMM_TYPE             string           ""
   add_derived_hdl_param     CTRL_AMM_ADDRESS_WIDTH         integer          1
   add_derived_hdl_param     CTRL_AMM_DATA_WIDTH            integer          1
   add_derived_hdl_param     CTRL_AMM_BYTEEN_WIDTH          integer          1

   add_derived_hdl_param     REGISTER_AFI_C2P               integer          1
   add_derived_hdl_param     REGISTER_AFI_P2C               integer          1
   add_derived_hdl_param     REGISTER_AMM_P2C               integer          1
   add_derived_hdl_param     WIRELUTS_FOR_C2P               integer          0

   add_derived_hdl_param     SEQ_SIM_CAL_CLK_DIVIDE         integer          30
   add_derived_hdl_param     SEQ_SYNTH_CAL_CLK_DIVIDE       integer          30
   add_derived_hdl_param     SEQ_SIM_NIOS_PERIOD_PS         integer          4000

   add_derived_hdl_param     NUM_OF_RTL_TILES               integer          1

   add_derived_hdl_param     PRI_RDATA_TILE_INDEX           integer          0    
   add_derived_hdl_param     PRI_RDATA_LANE_INDEX           integer          0    
   add_derived_hdl_param     PRI_WDATA_TILE_INDEX           integer          0    
   add_derived_hdl_param     PRI_WDATA_LANE_INDEX           integer          0    
   add_derived_hdl_param     PRI_AC_TILE_INDEX              integer          0    

   add_derived_hdl_param     SEC_RDATA_TILE_INDEX           integer          0    
   add_derived_hdl_param     SEC_RDATA_LANE_INDEX           integer          0    
   add_derived_hdl_param     SEC_WDATA_TILE_INDEX           integer          0    
   add_derived_hdl_param     SEC_WDATA_LANE_INDEX           integer          0    
   add_derived_hdl_param     SEC_AC_TILE_INDEX              integer          0    

   add_long_bitvec_hdl_param LANES_USAGE                    [expr {$max_lanes_per_if * [string length [enum_data LANE_USAGE_UNUSED BITSTR]]}]
   add_long_bitvec_hdl_param PINS_USAGE                     [expr {$max_pins_per_if  * [string length [enum_data PIN_USAGE_UNUSED BITSTR]]}]
   add_long_bitvec_hdl_param PINS_RATE                      [expr {$max_pins_per_if  * [string length [enum_data PIN_RATE_NOT_APPLICABLE BITSTR]]}]
   add_long_bitvec_hdl_param DB_PINS_PROC_MODE              [expr {$max_pins_per_if  * [string length [enum_data DB_PIN_PROC_MODE_NOT_APPLICABLE BITSTR]]}]
   add_long_bitvec_hdl_param PINS_DATA_IN_MODE              [expr {$max_pins_per_if  * [string length [enum_data PIN_DATA_IN_MODE_DISABLED BITSTR]]}]
   add_long_bitvec_hdl_param PINS_C2L_DRIVEN                [expr {$max_pins_per_if  * 1}]
   add_long_bitvec_hdl_param PINS_OCT_MODE                  [expr {$max_pins_per_if  * [string length [enum_data PIN_OCT_STATIC_OFF]]}]
   add_long_bitvec_hdl_param PINS_DCC_SPLIT                 [expr {$max_pins_per_if  * 1}]
   add_long_bitvec_hdl_param UNUSED_MEM_PINS_PINLOC         [expr {$max_pins_per_if      * 10 + 10}]
   add_long_bitvec_hdl_param UNUSED_DQS_BUSES_LANELOC       [expr {$max_dqs_buses_per_if * 10 + 10}]

   add_long_bitvec_hdl_param DBC_PIPE_LATS                  [expr {$max_lanes_per_if * 4}]
   add_long_bitvec_hdl_param DB_PTR_PIPELINE_DEPTHS         [expr {$max_lanes_per_if * 4}]
   add_long_bitvec_hdl_param DB_SEQ_RD_EN_FULL_PIPELINES    [expr {$max_lanes_per_if * 4}]

   add_long_bitvec_hdl_param CENTER_TIDS                    [expr {$max_tiles_per_if * 9}]
   add_long_bitvec_hdl_param HMC_TIDS                       [expr {$max_tiles_per_if * 9}]
   add_long_bitvec_hdl_param LANE_TIDS                      [expr {$max_lanes_per_if * 9}]

   add_derived_hdl_param PREAMBLE_MODE                      string ""
   add_derived_hdl_param DBI_WR_ENABLE                      string ""
   add_derived_hdl_param DBI_RD_ENABLE                      string ""
   add_derived_hdl_param SWAP_DQS_A_B                       string ""
   add_derived_hdl_param DQS_PACK_MODE                      string ""
   add_derived_hdl_param OCT_SIZE                           integer 1
   add_derived_hdl_param DQSA_LGC_MODE                      string ""
   add_derived_hdl_param DQSB_LGC_MODE                      string ""
   add_derived_hdl_param DBC_WB_RESERVED_ENTRY              integer 4
   add_derived_hdl_param DLL_MODE                           string ""
   add_derived_hdl_param DLL_CODEWORD                       integer 0

   add_derived_hdl_param ABPHY_WRITE_PROTOCOL               integer 1

   add_derived_hdl_param PHY_USERMODE_OCT                   boolean          false

   add_derived_hdl_param PHY_PERIODIC_OCT_RECAL             boolean          false

   add_derived_hdl_param GENERATE_PHYLITE                   boolean          false

   foreach hmc_inst [list "PRI" "SEC"] {
      foreach hmc_cfg_enum [enums_of_type HMC_CFG] {
         set data_type  [enum_data $hmc_cfg_enum DATA_TYPE]
         set width      [enum_data $hmc_cfg_enum WIDTH]
         set param_name "${hmc_inst}_${hmc_cfg_enum}"

         if {$data_type == "integer"} {
            add_derived_hdl_param $param_name $data_type 0
         } elseif {$data_type == "string"} {
            add_derived_hdl_param $param_name $data_type ""
         } else {
            emif_ie "Unsupported data type $data_type"
         }
      }
   }

   foreach family_trait_enum [enums_of_type FAMILY_TRAIT] {
      if {$family_trait_enum == "FAMILY_TRAIT_INVALID"} {
         continue
      }
      if {[enum_data $family_trait_enum IS_HDL_PARAM]} {
         set param_name [enum_data $family_trait_enum VERILOG_NAME]
         set param_type [enum_data $family_trait_enum TYPE]
         add_derived_hdl_param $param_name $param_type 0
      }
   }

   foreach arch_nd_if_enum [enums_of_type ARCH_ND_IF] {
      set if_enum        [enum_data $arch_nd_if_enum IF_ENUM]
      set port_enum_type [enum_data $if_enum PORT_ENUM_TYPE]

      foreach port_enum [enums_of_type $port_enum_type] {
         set is_bus [enum_data $port_enum IS_BUS]
         if {$is_bus} {
            add_derived_hdl_param "${port_enum}_WIDTH" integer 1
         }
         if {$if_enum == "IF_MEM"} {
            set max_width [enum_data $port_enum MAX_WIDTH]
            add_long_bitvec_hdl_param "${port_enum}_PINLOC" [expr {$max_width * 10 + 10}]
         }
      }
   }

   altera_emif::ip_arch_nd::pll::add_pll_parameters

   if {[info exists ::env(EMIF_AUTOGEN_CODE_ND)] && $::env(EMIF_AUTOGEN_CODE_ND)} {
      if {[altera_emif::ip_arch_nd::rtl_autogen::update_rtl]} {
         emif_ie "Successfully updated RTL - Turn off this mode, run make, and re-test IP generation"
      } else {
         emif_ie "Unable to update RTL - make sure files requiring updates are writable"
      }
   }

   return 1
}

proc ::altera_emif::ip_arch_nd::main::elaboration_callback {} {


   ::altera_emif::util::device_family::load_data

   if {[emif_utest_enabled]} {
      set data [::altera_emif::ip_arch_nd::protocol_expert::run_elab_time_utests]
   }


   set arch_legal [_validate]

   set if_ports [_generate_if_ports $arch_legal]

   foreach if_enum [dict keys $if_ports] {
      set ports [dict get $if_ports $if_enum PORTS]
      set insts [dict get $if_ports $if_enum INSTS]
      foreach if_index [dict keys $insts] {
         set if_enabled [dict get $insts $if_index ENABLED]
         set if_dir     [dict get $insts $if_index DIR]
         set if_name    [::altera_emif::util::hwtcl_utils::add_qsys_interface $if_enabled $if_enum $if_index $if_dir $ports]

         emif_assert {[string compare $if_name [dict get $insts $if_index NAME]] == 0}
      }
   }
   _set_interface_properties $if_ports

   set mem_ports      [dict get $if_ports IF_MEM PORTS]
   set mem_pins_alloc [dict get $if_ports IF_MEM PINS_ALLOC]

   altera_emif::arch_common::main::derive_family_trait_parameters
   altera_emif::arch_common::main::derive_port_width_parameters $if_ports

   _derive_protocol_common_parameters
   _derive_logical_resource_usage_parameters $mem_ports $mem_pins_alloc
   _derive_tid_parameters $mem_ports $mem_pins_alloc
   _set_abphy_wlat_rlat $mem_ports $mem_pins_alloc
   _derive_protocol_specific_hmc_cfg_parameters
   _derive_protocol_specific_ctrl_parameters
   _derive_protocol_specific_mem_parameters
   _derive_core_logic_parameters
   altera_emif::ip_arch_nd::pll::derive_pll_parameters

   _derive_iossm_parameters

   altera_emif::arch_common::main::update_qip $if_ports

   if {[has_pending_ipgen_e_msg]} {
      issue_pending_ipgen_e_msg_and_terminate
   } else {
      set phy_config_enum [get_parameter_value "PHY_CONFIG_ENUM"]
      set ratios [altera_emif::ip_arch_nd::protocol_expert::get_clk_ratios]

      if {[check_device_has_hmc_hr_limitation] && $phy_config_enum == "CONFIG_PHY_AND_HARD_CTRL"} {
         check_nd5_es_must_run_phy_hmc_at_hr 1

         set num_of_data_endpoints [get_parameter_value "MEM_NUM_OF_DATA_ENDPOINTS"]
         if {$num_of_data_endpoints > 1 && [altera_emif::ip_arch_nd::protocol_expert::is_phy_shadow_register_disabled]} {
            post_ipgen_w_msg MSG_SHADOW_REGISTER_DISABLED_FOR_MULTIRANK_ON_ND5_S1
         }

         set phy_hmc_clk_ratio [expr {[dict get $ratios PHY_HMC] * 1.0}]
         if {$phy_hmc_clk_ratio == 4} {
            post_ipgen_i_msg MSG_QR_HMC_PHY_ON_ND
         }
      }

      if {[dict get $ratios PHY_HMC] == 2 && [dict get $ratios C2P_P2C] == 4} {
         post_ipgen_i_msg MSG_USE_HMC_RC
      }

      if {$phy_config_enum == "CONFIG_PHY_AND_HARD_CTRL"} {
         set hmc_fmax_lookup   [get_family_trait FAMILY_TRAIT_HMC_FMAX_MHZ]
         set hmc_fmax_mhz      [dict get $hmc_fmax_lookup [get_speedgrade]]
         set mem_clk_freq_mhz  [get_parameter_value PHY_MEM_CLK_FREQ_MHZ]
         set phy_hmc_clk_ratio [dict get $ratios PHY_HMC]
         set hmc_freq_mhz      [expr {$mem_clk_freq_mhz * 1.0 / $phy_hmc_clk_ratio}]
         if {$hmc_freq_mhz > $hmc_fmax_mhz} {
            post_ipgen_w_msg MSG_EXCEED_HMC_FMAX [list $hmc_freq_mhz $hmc_fmax_mhz]
         }
      }

      set phy_tracking_en [altera_emif::ip_arch_nd::protocol_expert::is_phy_tracking_enabled]
      if {$phy_tracking_en} {
         post_ipgen_i_msg MSG_USE_PHY_TRACKING
      }

      set ac_pm_scheme      [altera_emif::ip_arch_nd::protocol_expert::get_ac_pin_map_scheme]
      set ac_pm_enum        [dict get $ac_pm_scheme ENUM]
      post_ipgen_i_msg MSG_ADDR_CMD_PIN_MAP_SCHEME_INFO [list [enum_data $ac_pm_enum USER_STRING]]

      set num_of_rtl_tiles [dict size $mem_pins_alloc]
      post_ipgen_i_msg MSG_RESOURCE_USAGE [list $num_of_rtl_tiles $num_of_rtl_tiles]

      set valid_mem_clk_freqs [altera_emif::ip_arch_nd::pll::get_legal_mem_clk_freqs_mhz]
      if {[llength $valid_mem_clk_freqs] > 0} {
         set valid_mem_clk_freqs [lsort -real -decreasing $valid_mem_clk_freqs]
         set msg_string [join $valid_mem_clk_freqs ", "]
         post_ipgen_i_msg MSG_LEGAL_MEM_CLK_FREQS [list $msg_string]
      }

      post_ipgen_i_msg MSG_README_INFO [list]
   }


   set write_protocol_enum       [get_parameter_value "MEM_RLD3_WRITE_PROTOCOL_ENUM"]
   set write_protocol            [enum_data $write_protocol_enum MRS]]
   set_parameter_value ABPHY_WRITE_PROTOCOL  $write_protocol

   return 1
}

proc ::altera_emif::ip_arch_nd::main::sim_fileset_callback {top_level is_vhd} {
   set rtl_only 0
   set encrypted 0

   set if_ports [_generate_if_ports true]

   set sim_cal_code_hex_filename   [get_sim_cal_code_hex_filename $top_level]
   set synth_cal_code_hex_filename [get_synth_cal_code_hex_filename $top_level]
   set sim_params_hex_filename     [get_sim_params_hex_filename $top_level]
   set synth_params_hex_filename   [get_synth_params_hex_filename $top_level]

   set extra_params [list [list SEQ_SYNTH_PARAMS_HEX_FILENAME "\"${synth_params_hex_filename}\""] \
                          [list SEQ_SIM_PARAMS_HEX_FILENAME "\"${sim_params_hex_filename}\""] \
                          [list SEQ_SYNTH_CODE_HEX_FILENAME "\"${synth_cal_code_hex_filename}\""] \
                          [list SEQ_SIM_CODE_HEX_FILENAME "\"${sim_cal_code_hex_filename}\""]]

   set file_paths [concat [::altera_emif::util::hwtcl_utils::generate_dynamic_unique_name_rtl "altera_emif_arch_nd_top" "${top_level}_top" "altera_emif_arch_nd_io_ssm" "${top_level}_io_ssm"] \
                          [::altera_emif::util::hwtcl_utils::generate_dynamic_unique_name_rtl "altera_emif_arch_nd_io_ssm" "${top_level}_io_ssm" "" ""] \
                          [_generate_verilog_fileset $top_level] \
                          [_generate_abphy_verilog_fileset $top_level] \
                          [_generate_common_fileset $top_level $if_ports]]

   if {$is_vhd} {
      lappend file_paths [::altera_emif::util::hwtcl_utils::generate_top_level_vhd_wrapper $top_level "${top_level}_top" $extra_params]
   } else {
      lappend file_paths [::altera_emif::util::hwtcl_utils::generate_top_level_sv_wrapper $top_level "${top_level}_top" $extra_params]
   }

   foreach file_path $file_paths {
      set tmp [file split $file_path]
      set file_name [lindex $tmp end]
      add_fileset_file $file_name [::altera_emif::util::hwtcl_utils::get_file_type $file_name $rtl_only $encrypted] PATH $file_path
   }
}

proc ::altera_emif::ip_arch_nd::main::sim_vhdl_fileset_callback {top_level} {
   sim_fileset_callback $top_level 1
}

proc ::altera_emif::ip_arch_nd::main::sim_verilog_fileset_callback {top_level} {

   sim_fileset_callback $top_level 0
}



proc ::altera_emif::ip_arch_nd::main::quartus_cdc_fileset_callback {top_level} {
   ::altera_emif::ip_arch_nd::main::quartus_synth_fileset_callback $top_level

   set rtl_only 0
   set encrypted 0
   set use_sdc_entity 1

   set file_paths [list \
      emif_cdc_waiver.awl \
      ]

   foreach file_path $file_paths {
      set tmp [file split $file_path]
      set file_name [lindex $tmp end]
      set file_type [::altera_emif::util::hwtcl_utils::get_file_type $file_name $rtl_only $encrypted $use_sdc_entity]
      add_fileset_file $file_name $file_type PATH $file_path
   }

}

proc ::altera_emif::ip_arch_nd::main::quartus_synth_fileset_callback {top_level} {
   set rtl_only 0
   set encrypted 0
   set use_sdc_entity 1

   set if_ports [_generate_if_ports true]

   set sim_cal_code_hex_filename   [get_sim_cal_code_hex_filename $top_level]
   set synth_cal_code_hex_filename [get_synth_cal_code_hex_filename $top_level]
   set sim_params_hex_filename     [get_sim_params_hex_filename $top_level]
   set synth_params_hex_filename   [get_synth_params_hex_filename $top_level]

   set extra_params [list [list SEQ_SYNTH_PARAMS_HEX_FILENAME "\"${synth_params_hex_filename}\""] \
                          [list SEQ_SIM_PARAMS_HEX_FILENAME "\"${sim_params_hex_filename}\""] \
                          [list SEQ_SYNTH_CODE_HEX_FILENAME "\"${synth_cal_code_hex_filename}\""] \
                          [list SEQ_SIM_CODE_HEX_FILENAME "\"${sim_cal_code_hex_filename}\""]] 

   set file_paths [concat [::altera_emif::util::hwtcl_utils::generate_dynamic_unique_name_rtl "altera_emif_arch_nd_top" "${top_level}_top" "altera_emif_arch_nd_io_ssm" "${top_level}_io_ssm"] \
                          [::altera_emif::util::hwtcl_utils::generate_dynamic_unique_name_rtl "altera_emif_arch_nd_io_ssm" "${top_level}_io_ssm" "" ""] \
                          [::altera_emif::util::hwtcl_utils::generate_top_level_sv_wrapper $top_level "${top_level}_top" $extra_params] \
                          [_generate_verilog_fileset $top_level] \
                          [_generate_timing_fileset $top_level $if_ports] \
                          [_generate_common_fileset $top_level $if_ports]]

   foreach file_path $file_paths {
      set tmp [file split $file_path]
      set file_name [lindex $tmp end]

      set file_type [::altera_emif::util::hwtcl_utils::get_file_type $file_name $rtl_only $encrypted $use_sdc_entity]
      if {[string equal $file_type "SDC_ENTITY_NOPROMO"]} {
         add_fileset_file $file_name "SDC_ENTITY" PATH $file_path {NO_AUTO_INSTANCE_DISCOVERY NO_SDC_PROMOTION}
       } else {
         add_fileset_file $file_name $file_type PATH $file_path
      }
   }
}


proc ::altera_emif::ip_arch_nd::main::_generate_common_fileset {top_level if_ports} {

   set file_list [list]

   set mem_ports       [dict get $if_ports IF_MEM PORTS]
   set mem_pins_alloc  [dict get $if_ports IF_MEM PINS_ALLOC]

   set extra_configs_str [get_parameter_value "DIAG_EXTRA_CONFIGS"]
   set extra_configs [parse_extra_configs $extra_configs_str]

   set force_firmware ""
   if {[dict exists $extra_configs FORCE_FIRMWARE]} {
      set force_firmware [dict get $extra_configs FORCE_FIRMWARE]
      puts "Forcing firmware image: $force_firmware"
   }


   set sim_pt_contents [altera_emif::ip_arch_nd::seq_param_tbl::derive_contents $mem_ports $mem_pins_alloc]

   set sim_cal_mode_enum [get_parameter_value DIAG_SIM_CAL_MODE_ENUM]
   if {$sim_cal_mode_enum == "SIM_CAL_MODE_SKIP"} {
      altera_emif::ip_arch_nd::seq_param_tbl::set_skip_cal sim_pt_contents 1
   } else {
      altera_emif::ip_arch_nd::seq_param_tbl::set_skip_cal sim_pt_contents 0
   }

   altera_emif::ip_arch_nd::seq_param_tbl::set_sim_opts sim_pt_contents

   altera_emif::ip_arch_nd::seq_param_tbl::set_max_nios_freq_and_clk_divide sim_pt_contents 1

   altera_emif::ip_arch_nd::seq_param_tbl::set_extra_configs_overrides sim_pt_contents 1

   lappend file_list {*}[altera_emif::ip_arch_nd::seq_param_tbl::generate_sim_files $top_level $sim_pt_contents]

   set sim_cal_code_hex_dst_filename   [get_sim_cal_code_hex_filename $top_level]
   set sim_cal_code_hex_src_filename   [get_sim_cal_code_hex_src_filename $force_firmware]

   lappend file_list [copy_to_temp_file $sim_cal_code_hex_src_filename $sim_cal_code_hex_dst_filename]


   set synth_pt_contents [altera_emif::ip_arch_nd::seq_param_tbl::derive_contents $mem_ports $mem_pins_alloc]

   altera_emif::ip_arch_nd::seq_param_tbl::set_skip_cal synth_pt_contents 0

   altera_emif::ip_arch_nd::seq_param_tbl::set_synth_opts synth_pt_contents

   altera_emif::ip_arch_nd::seq_param_tbl::set_max_nios_freq_and_clk_divide synth_pt_contents 0

   altera_emif::ip_arch_nd::seq_param_tbl::set_extra_configs_overrides synth_pt_contents 0

   lappend file_list {*}[altera_emif::ip_arch_nd::seq_param_tbl::generate_synth_files $top_level $synth_pt_contents]

   set synth_cal_code_hex_dst_filename   [get_synth_cal_code_hex_filename $top_level]
   set synth_cal_code_hex_src_filename   [get_synth_cal_code_hex_src_filename $force_firmware]

   lappend file_list [copy_to_temp_file $synth_cal_code_hex_src_filename $synth_cal_code_hex_dst_filename]

   set docs [dict create]
   ::altera_emif::ip_arch_nd::doc_gen::add_readme docs $if_ports
   lappend file_list {*}[altera_emif::util::doc_gen::generate_files $top_level $docs]

   if {[get_parameter_value DIAG_SOFT_NIOS_MODE] == "SOFT_NIOS_MODE_ON_CHIP_DEBUG"} {
      set src_dir [::altera_emif::ip_arch_nd::util::get_iossm_firmware_source_dir 1]
      lappend file_list "$src_dir/[enum_data SEQ_EXPORT_FILE_EMIF_EXPORT FILENAME].c"
      lappend file_list "$src_dir/[enum_data SEQ_EXPORT_FILE_EMIF_EXPORT FILENAME].h"
      lappend file_list [copy_to_temp_file "$src_dir/[enum_data SEQ_EXPORT_FILE_EMIF_EXPORT FILENAME]_[enum_data SEQ_EXPORT_FILE_MAIN FILENAME].c" "main.c"]
      lappend file_list [copy_to_temp_file "$src_dir/[enum_data SEQ_EXPORT_FILE_EMIF_EXPORT FILENAME]_makefile.txt" "Makefile"]
   }

   return $file_list
}

proc ::altera_emif::ip_arch_nd::main::_generate_timing_fileset {top_level if_ports} {

   set file_list [list]

   lappend file_list {*}[altera_emif::ip_arch_nd::timing::generate_files $top_level $if_ports]

   return $file_list
}


proc ::altera_emif::ip_arch_nd::main::_generate_verilog_fileset {top_level} {
   set file_list [list \
      rtl/altera_emif_arch_nd_bufs.sv \
      rtl/altera_emif_arch_nd_buf_udir_se_i.sv \
      rtl/altera_emif_arch_nd_buf_udir_se_o.sv \
      rtl/altera_emif_arch_nd_buf_udir_df_i.sv \
      rtl/altera_emif_arch_nd_buf_udir_df_o.sv \
      rtl/altera_emif_arch_nd_buf_udir_cp_i.sv \
      rtl/altera_emif_arch_nd_buf_bdir_df.sv \
      rtl/altera_emif_arch_nd_buf_bdir_se.sv \
      rtl/altera_emif_arch_nd_buf_unused.sv \
      rtl/altera_emif_arch_nd_cal_counter.sv \
      rtl/altera_emif_arch_nd_emif2mem.sv \
      rtl/altera_emif_arch_nd_pll.sv \
      rtl/altera_emif_arch_nd_pll_fast_sim.sv \
      rtl/altera_emif_arch_nd_pll_extra_clks.sv \
      rtl/altera_emif_arch_nd_oct.sv \
      rtl/altera_emif_arch_nd_core_clks_rsts.sv \
      rtl/altera_emif_arch_nd_hps_clks_rsts.sv \
      rtl/altera_emif_arch_nd_local_reset.sv \
      rtl/altera_emif_arch_nd_io_tiles_wrap.sv \
      rtl/altera_emif_arch_nd_io_tiles.sv \
      rtl/altera_emif_arch_nd_io_tiles_abphy.sv \
      rtl/altera_emif_arch_nd_abphy_mux.sv \
      rtl/altera_emif_arch_nd_io_lane_remap.sv \
      rtl/altera_emif_arch_nd_io_lane_remap_abphy.sv \
      rtl/altera_emif_arch_nd_hmc_avl_if.sv \
      rtl/altera_emif_arch_nd_hmc_sideband_if.sv \
      rtl/altera_emif_arch_nd_hmc_mmr_if.sv \
      rtl/altera_emif_arch_nd_hmc_amm_data_if.sv \
      rtl/altera_emif_arch_nd_phylite_if.sv \
      rtl/altera_emif_arch_nd_hmc_ast_data_if.sv \
      rtl/altera_emif_arch_nd_afi_if.sv \
      rtl/altera_emif_arch_nd_seq_if.sv \
      rtl/altera_emif_arch_nd_regs.sv \
      ../../altera_oct/altera_oct_core14/altera_oct.sv \
      ../../altera_oct/altera_oct_core14/altera_oct_um_fsm.sv \
      ../../primitives/altera_std_synchronizer/altera_std_synchronizer_nocut.v \
   ]
   return $file_list
}

proc ::altera_emif::ip_arch_nd::main::_generate_abphy_verilog_fileset {top_level} {
   set file_list [list \
      rtl/mem_array_abphy.sv \
      rtl/fourteennm_io_12_lane_abphy.sv \
      rtl/fourteennm_io_12_lane_encrypted_abphy.sv \
      rtl/fourteennm_io_12_lane_mdev40_encrypted_abphy.sv \
      rtl/io_12_lane__mdev40_abphy.sv \
   ]

   return $file_list
}


proc ::altera_emif::ip_arch_nd::main::_generate_if_ports {arch_legal} {

   set if_ports [dict create]

   ::altera_emif::util::device_family::load_data
   set is_hps [get_is_hps]

   set is_ed_slave [get_parameter_value IS_ED_SLAVE]

   foreach arch_nd_if_enum [enums_of_type ARCH_ND_IF] {
      set if_enum           [enum_data $arch_nd_if_enum IF_ENUM]
      set num_of_ifs_in_rtl [enum_data $arch_nd_if_enum NUM_IN_RTL]
      set num_of_ifs_used   [::altera_emif::ip_arch_nd::protocol_expert::get_num_of_interfaces_used $if_enum]

      dict set if_ports $if_enum [dict create]

      set ports_have_no_default_width [expr {$if_enum == "IF_CAL_DEBUG" || $if_enum == "IF_CAL_DEBUG_OUT" || $if_enum == "IF_CAL_MASTER"}]
      if {$num_of_ifs_used > 0 || $ports_have_no_default_width} {
         set ports [::altera_emif::ip_arch_nd::protocol_expert::get_interface_ports $if_enum]
      } else {
         set ports [list]
      }

      ::altera_emif::util::hwtcl_utils::add_unused_interface_ports $if_enum ports

      if {$if_enum == "IF_MEM"} {
         set mem_pins_alloc [::altera_emif::ip_arch_nd::protocol_expert::alloc_mem_pins ports]
      }

      if {$if_enum == "IF_MEM" || $if_enum == "IF_PLL_REF_CLK" || ($if_enum == "IF_OCT" && !$is_ed_slave)} {
         ::altera_emif::ip_arch_nd::protocol_expert::assign_io_settings ports
      }

      dict set if_ports $if_enum PORTS $ports
      dict set if_ports $if_enum INSTS [dict create]

      if {$if_enum == "IF_MEM"} {
         dict set if_ports $if_enum PINS_ALLOC $mem_pins_alloc
      }

      for {set i 0} {$i < $num_of_ifs_in_rtl} {incr i} {
         set if_index [expr {$num_of_ifs_in_rtl == 1} ? -1 : $i]
         set if_dir   "NORMAL_DIR"
         set if_name  [::altera_emif::util::hwtcl_utils::generate_qsys_interface_name $if_enum $if_index $if_dir]

         if {$i < $num_of_ifs_used} {
            set if_enabled true
         } else {
            set if_enabled false
         }

         if {$if_enabled && $is_hps && [_get_is_interface_disabled_in_hps_mode $if_enum]} {
            set if_enabled false
         }

         dict set if_ports $if_enum INSTS $if_index [dict create NAME $if_name ENABLED $if_enabled DIR $if_dir]
      }
   }

   return $if_ports
}

proc ::altera_emif::ip_arch_nd::main::_derive_protocol_common_parameters {} {

   set_parameter_value IS_HPS [get_is_hps]

   set die_revs [get_device_die_revisions]
   set_parameter_value SILICON_REV [get_wysiwyg_silicon_rev_string]

   set phy_config_enum [get_parameter_value "PHY_CONFIG_ENUM"]
   set ratios [altera_emif::ip_arch_nd::protocol_expert::get_clk_ratios]

   set_parameter_value USER_CLK_RATIO           [dict get $ratios USER]
   set_parameter_value PHY_HMC_CLK_RATIO        [dict get $ratios PHY_HMC]
   set_parameter_value C2P_P2C_CLK_RATIO        [dict get $ratios C2P_P2C]

   set dqs_bus_mode_enum [altera_emif::ip_arch_nd::protocol_expert::get_dqs_bus_mode]
   set_parameter_value DQS_BUS_MODE_ENUM        $dqs_bus_mode_enum

   set ac_pm_scheme [altera_emif::ip_arch_nd::protocol_expert::get_ac_pin_map_scheme]
   set hmc_ifs [altera_emif::ip_arch_nd::protocol_expert::get_num_and_type_of_hmc_ports]
   set_parameter_value NUM_OF_HMC_PORTS         [dict get $hmc_ifs NUM_OF_PORTS]
   set_parameter_value HMC_AVL_PROTOCOL_ENUM    [dict get $hmc_ifs CTRL_AVL_PROTOCOL_ENUM]
   set_parameter_value HMC_READY_LATENCY        [dict get $hmc_ifs READY_LATENCY]
   set_parameter_value HMC_CTRL_DIMM_TYPE       [dict get $ac_pm_scheme HMC_DIMM_TYPE_STR]

   set extra_configs_str [get_parameter_value "DIAG_EXTRA_CONFIGS"]
   set extra_configs [parse_extra_configs $extra_configs_str]

   if {[extra_config_is_explicit_on $extra_configs DIAG_CPA_OUT_1_EN]} {
      set_parameter_value DIAG_CPA_OUT_1_EN true
      post_ipgen_w_msg MSG_CPA_OUT_1_EN

      emif_assert {[get_parameter_value DIAG_EXPOSE_DFT_SIGNALS]}
      emif_assert {[string compare $phy_config_enum "CONFIG_PHY_AND_HARD_CTRL"] == 0}
      emif_assert {[dict get $ratios USER] != 8}

   } else {
      set_parameter_value DIAG_CPA_OUT_1_EN false
   }

   if {[get_is_hps]} {
      set_parameter_value DIAG_USE_CPA_LOCK true
   } elseif {[extra_config_is_explicit_off $extra_configs DIAG_USE_CPA_LOCK]} {
      set_parameter_value DIAG_USE_CPA_LOCK false
   } elseif {[extra_config_is_explicit_on $extra_configs DIAG_USE_CPA_LOCK]} {
      set_parameter_value DIAG_USE_CPA_LOCK true
   } else {
      set_parameter_value DIAG_USE_CPA_LOCK true
   }

   if {[::altera_emif::util::qini::ini_is_on "generate_phylite"]} {
      set_parameter_value GENERATE_PHYLITE true
   }

   set is_nd5_reva            [expr {[lsearch -nocase -regexp $die_revs {\_ND5\_REVA}] >= 0 ? 1 : 0}]
   set core_clks_sharing_enum [get_parameter_value PHY_CORE_CLKS_SHARING_ENUM]
   set phy_calibrated_oct     [get_parameter_value PHY_CALIBRATED_OCT]

   set_parameter_value        PHY_USERMODE_OCT false

   if {[dict exists $extra_configs FORCE_DLL_CODEWORD]} {
      set codeword [dict get $extra_configs FORCE_DLL_CODEWORD]
      set_parameter_value DLL_MODE     [expr {$codeword < 0 ? "ctl_dynamic" : "ctl_static"}]
      set_parameter_value DLL_CODEWORD [expr {$codeword < 0 ? 0 : $codeword}]
   } else {
      set_parameter_value DLL_MODE "ctl_dynamic"
      set_parameter_value DLL_CODEWORD 0
   }
}

proc ::altera_emif::ip_arch_nd::main::derive_pins_parameters {mem_ports mem_pins_alloc} {

   set num_of_rtl_tiles              [dict size $mem_pins_alloc]
   set lanes_per_tile                [get_family_trait FAMILY_TRAIT_LANES_PER_TILE]
   set pins_per_lane                 [get_family_trait FAMILY_TRAIT_PINS_PER_LANE]
   set pins_per_tile                 [expr {$lanes_per_tile * $pins_per_lane}]
   set rate_enum                     [get_parameter_value PHY_RATE_ENUM]
   set ecc_en                        [get_parameter_value CTRL_ECC_EN]
   set is_hps                        [get_is_hps]

   set lanes_in_if                   [expr {$num_of_rtl_tiles * $lanes_per_tile}]
   set pins_in_if                    [expr {$lanes_in_if * $pins_per_lane}]

   set pins_usage                    [string repeat [enum_data PIN_USAGE_UNUSED                 BITSTR] $pins_in_if]
   set pins_rate                     [string repeat [enum_data PIN_RATE_NOT_APPLICABLE          BITSTR] $pins_in_if]
   set db_pins_proc_mode             [string repeat [enum_data DB_PIN_PROC_MODE_GPIO            BITSTR] $pins_in_if]
   set pins_data_in_mode             [string repeat [enum_data PIN_DATA_IN_MODE_DISABLED        BITSTR] $pins_in_if]
   set pins_oct_mode                 [string repeat [enum_data PIN_OCT_STATIC_OFF               BITSTR] $pins_in_if]
   set pins_c2l_driven               [string repeat "0" $pins_in_if]
   set pins_dcc_split                [string repeat "0" $pins_in_if]
   set ac_tile_i                     [get_ac_tile_index $mem_ports]
   set hps_shadow_lane_port          [list]

   foreach port $mem_ports {
      set enabled [dict get $port ENABLED]

      if {$enabled} {
         set abs_pin_index [dict get $port ABS_PIN_INDEX]
         emif_assert {$abs_pin_index >= 0}

         set bitstr             [enum_data PIN_USAGE_USED BITSTR]
         set bitstr_len         [string length $bitstr]
         set first              [expr {($pins_in_if - $abs_pin_index - 1) * $bitstr_len}]
         set last               [expr {$first + $bitstr_len - 1}]
         set pins_usage         [string replace $pins_usage $first $last $bitstr]

         set bitstr             [enum_data [dict get $port RATE_ENUM] BITSTR]
         set bitstr_len         [string length $bitstr]
         set first              [expr {($pins_in_if - $abs_pin_index - 1) * $bitstr_len}]
         set last               [expr {$first + $bitstr_len - 1}]
         set pins_rate          [string replace $pins_rate $first $last $bitstr]

         set bitstr             [enum_data [dict get $port DB_PROC_ENUM] BITSTR]
         set bitstr_len         [string length $bitstr]
         set first              [expr {($pins_in_if - $abs_pin_index - 1) * $bitstr_len}]
         set last               [expr {$first + $bitstr_len - 1}]
         set db_pins_proc_mode  [string replace $db_pins_proc_mode $first $last $bitstr]

         set bitstr             [expr {[dict get $port C2L_DRIVEN] ? "1" : "0"}]
         set bitstr_len         [string length $bitstr]
         set first              [expr {($pins_in_if - $abs_pin_index - 1) * $bitstr_len}]
         set last               [expr {$first + $bitstr_len - 1}]
         set pins_c2l_driven    [string replace $pins_c2l_driven $first $last $bitstr]

         set type_enum          [dict get $port TYPE_ENUM]
         set port_dir           [enum_data $type_enum QSYS_DIR]
         set is_output          [expr {[string equal [string toupper $port_dir] OUTPUT] ? 1 : 0}]
         set is_calibrated      [expr [dict get $port CAL_OCT] ? 1: 0]
         set rtl_name           [enum_data $type_enum RTL_NAME]
         set is_mem_ck_bidir    [expr {([string equal $rtl_name mem_ck_bidir] || [string equal $rtl_name mem_ck_bidir_n]) ? 1 : 0}]
         set oct_mode           [expr { ($is_output || !$is_calibrated || $is_mem_ck_bidir) ? "static_off" : "dynamic"}]
         set bitstr             [enum_data "PIN_OCT_[string toupper $oct_mode]" BITSTR]
         set bitstr_len         [string length $bitstr]
         set first              [expr {($pins_in_if - $abs_pin_index - 1) * $bitstr_len}]
         set last               [expr {$first + $bitstr_len - 1}]
         set pins_oct_mode      [string replace $pins_oct_mode $first $last $bitstr]

         set bitstr             [enum_data [dict get $port DATA_IN_MODE] BITSTR]
         set bitstr_len         [string length $bitstr]
         set first              [expr {($pins_in_if - $abs_pin_index - 1) * $bitstr_len}]
         set last               [expr {$first + $bitstr_len - 1}]
         set pins_data_in_mode  [string replace $pins_data_in_mode $first $last $bitstr]

         set bitstr             [expr {[dict get $port DCC_SPLIT] ? "1" : "0"}]
         set bitstr_len         [string length $bitstr]
         set first              [expr {($pins_in_if - $abs_pin_index - 1) * $bitstr_len}]
         set last               [expr {$first + $bitstr_len - 1}]
         set pins_dcc_split     [string replace $pins_dcc_split $first $last $bitstr]

         set tile_i [dict get $port TILE_INDEX]
         set lane_i [dict get $port LANE_INDEX]

         if {($is_hps) && (!$ecc_en) && ($tile_i > $ac_tile_i) && ($lane_i == 0)} {
            lappend hps_shadow_lane_port $port
         }
      }
   }

   foreach port $hps_shadow_lane_port {
      set tile_i             $ac_tile_i
      set lane_i             3
      set pin_i              [dict get $port PIN_INDEX]
      set abs_pin_index      [expr {$tile_i * $pins_per_tile + $lane_i * $pins_per_lane + $pin_i}]

      set bitstr             [enum_data PIN_USAGE_UNUSED BITSTR]
      set bitstr_len         [string length $bitstr]
      set first              [expr {($pins_in_if - $abs_pin_index - 1) * $bitstr_len}]
      set last               [expr {$first + $bitstr_len - 1}]
      set pins_usage         [string replace $pins_usage $first $last $bitstr]

      set bitstr             [enum_data [dict get $port RATE_ENUM] BITSTR]
      set bitstr_len         [string length $bitstr]
      set first              [expr {($pins_in_if - $abs_pin_index - 1) * $bitstr_len}]
      set last               [expr {$first + $bitstr_len - 1}]
      set pins_rate          [string replace $pins_rate $first $last $bitstr]

      set bitstr             [enum_data [dict get $port DB_PROC_ENUM] BITSTR]
      set bitstr_len         [string length $bitstr]
      set first              [expr {($pins_in_if - $abs_pin_index - 1) * $bitstr_len}]
      set last               [expr {$first + $bitstr_len - 1}]
      set db_pins_proc_mode  [string replace $db_pins_proc_mode $first $last $bitstr]

      set bitstr             0
      set bitstr_len         [string length $bitstr]
      set first              [expr {($pins_in_if - $abs_pin_index - 1) * $bitstr_len}]
      set last               [expr {$first + $bitstr_len - 1}]
      set pins_c2l_driven    [string replace $pins_c2l_driven $first $last $bitstr]

      set type_enum          [dict get $port TYPE_ENUM]
      set port_dir           [enum_data $type_enum QSYS_DIR]
      set is_output          [expr {[string equal [string toupper $port_dir] OUTPUT] ? 1 : 0}]
      set is_calibrated      [expr [dict get $port CAL_OCT] ? 1: 0]
      set oct_mode           [expr { ($is_output || !$is_calibrated) ? "static_off" : "dynamic"}]
      set bitstr             [enum_data "PIN_OCT_[string toupper $oct_mode]" BITSTR]
      set bitstr_len         [string length $bitstr]
      set first              [expr {($pins_in_if - $abs_pin_index - 1) * $bitstr_len}]
      set last               [expr {$first + $bitstr_len - 1}]
      set pins_oct_mode      [string replace $pins_oct_mode $first $last $bitstr]

      set bitstr             [enum_data [dict get $port DATA_IN_MODE] BITSTR]
      set bitstr_len         [string length $bitstr]
      set first              [expr {($pins_in_if - $abs_pin_index - 1) * $bitstr_len}]
      set last               [expr {$first + $bitstr_len - 1}]
      set pins_data_in_mode  [string replace $pins_data_in_mode $first $last $bitstr]

      set bitstr             [expr {[dict get $port DCC_SPLIT] ? "1" : "0"}]
      set bitstr_len         [string length $bitstr]
      set first              [expr {($pins_in_if - $abs_pin_index - 1) * $bitstr_len}]
      set last               [expr {$first + $bitstr_len - 1}]
      set pins_dcc_split     [string replace $pins_dcc_split $first $last $bitstr]
   }

   set_long_bitvec_hdl_param_value PINS_USAGE                     $pins_usage
   set_long_bitvec_hdl_param_value PINS_RATE                      $pins_rate
   set_long_bitvec_hdl_param_value DB_PINS_PROC_MODE              $db_pins_proc_mode
   set_long_bitvec_hdl_param_value PINS_DATA_IN_MODE              $pins_data_in_mode
   set_long_bitvec_hdl_param_value PINS_C2L_DRIVEN                $pins_c2l_driven
   set_long_bitvec_hdl_param_value PINS_OCT_MODE                  $pins_oct_mode
   set_long_bitvec_hdl_param_value PINS_DCC_SPLIT                 $pins_dcc_split
}

proc ::altera_emif::ip_arch_nd::main::_set_abphy_wlat_rlat {mem_ports mem_pins_alloc} {
   set ratios [altera_emif::ip_arch_nd::protocol_expert::get_clk_ratios]
   set lar_var [dict get $ratios PHY_HMC]
   set lat_offset  [dict size $mem_pins_alloc]
   set lat_offset  [expr {int($lat_offset/3)}]

   switch $lar_var {
     "4" {
       set g_in_rate_shift 2
     }
     "2" {
       set g_in_rate_shift 1
     }
     default {
       set g_in_rate_shift 0
     }
   }
   set g_tcl_effective [get_parameter_value MEM_READ_LATENCY]
   set g_twl_effective [get_parameter_value MEM_WRITE_LATENCY]
   set g_tcl_effective [expr {int($g_tcl_effective)}]
   set g_twl_effective [expr {int($g_twl_effective)}]

   switch $g_in_rate_shift {
     "0" {
       set min_calc 18
       set const_add_calc 13
     }
     "1" {
       set min_calc 11
       set const_add_calc 9
     }
     "2" {
       set min_calc 8
       set const_add_calc 8
     }
     default {
       set min_calc 8
       set const_add_calc 8
     }
   }

   if {$g_twl_effective == 1 && $g_in_rate_shift == 0} {
     set const_add_calc [expr {$const_add_calc + 4}]
   }

   if {$g_twl_effective == 1 && $g_in_rate_shift == 1} {
     set const_add_calc [expr {$const_add_calc + 3}]
   }

   if {$g_twl_effective == 2 && $g_in_rate_shift == 0} {
     set const_add_calc [expr {$const_add_calc + 2}]
   }

   if {$g_twl_effective == 2 && $g_in_rate_shift == 1} {
     set const_add_calc [expr {$const_add_calc + 2}]
   }

   if {$g_twl_effective == 3 && $g_in_rate_shift == 0} {
     set const_add_calc [expr {$const_add_calc + 0}]
   }

   if {$g_twl_effective == 3 && $g_in_rate_shift == 1} {
     set const_add_calc [expr {$const_add_calc + 2}]
   }


   set g_rlat [expr {((($g_tcl_effective - ($g_tcl_effective & ((1 << $g_in_rate_shift) - 1)))/(2**$g_in_rate_shift))+$const_add_calc)}]
   set g_wlat [expr {($g_twl_effective >> $g_in_rate_shift)}]
   set_parameter_value DIAG_ABSTRACT_PHY_WLAT   $g_wlat
   set_parameter_value DIAG_ABSTRACT_PHY_RLAT   $g_rlat

}

proc ::altera_emif::ip_arch_nd::main::_derive_logical_resource_usage_parameters {mem_ports mem_pins_alloc} {

   set settings [::altera_emif::ip_arch_nd::protocol_expert::get_lane_cfgs]
   foreach hmc_lane_enum [dict keys $settings] {
      set val [dict get $settings $hmc_lane_enum]
      set_parameter_value $hmc_lane_enum $val
   }

   set ac_tile_i    [get_ac_tile_index $mem_ports]
   set ac_pm_scheme [altera_emif::ip_arch_nd::protocol_expert::get_ac_pin_map_scheme]

   altera_emif::arch_common::main::derive_lanes_parameters              $ac_tile_i $ac_pm_scheme $mem_ports $mem_pins_alloc
   altera_emif::ip_arch_nd::main::derive_pins_parameters                $mem_ports $mem_pins_alloc
   altera_emif::arch_common::main::derive_mem_ports_pinloc_parameters   $mem_ports $mem_pins_alloc
   altera_emif::arch_common::main::derive_unused_pins_pinloc_parameters $mem_ports $mem_pins_alloc

   _derive_pipe_lat_parameters $ac_tile_i $ac_pm_scheme $mem_ports $mem_pins_alloc
}

proc ::altera_emif::ip_arch_nd::main::_derive_tid_parameters {mem_ports mem_pins_alloc} {

   set num_of_rtl_tiles  [dict size $mem_pins_alloc]
   set lanes_per_tile    [get_family_trait FAMILY_TRAIT_LANES_PER_TILE]
   set lanes_in_if       [expr {$num_of_rtl_tiles * $lanes_per_tile}]

   set center_tids [string repeat "000000000" $num_of_rtl_tiles]
   set hmc_tids    [string repeat "000000000" $num_of_rtl_tiles]
   set lane_tids   [string repeat "000000000" $lanes_in_if]

   foreach tile_i [dict keys $mem_pins_alloc] {
      set tile [dict get $mem_pins_alloc $tile_i]

      for {set lane_i 0} {$lane_i < $lanes_per_tile} {incr lane_i} {
         set abs_lane_index  [expr {$tile_i * $lanes_per_tile + $lane_i}]
         set first           [expr {($lanes_in_if - $abs_lane_index - 1) * 9}]
         set last            [expr {$first + 8}]
         set lane_tid_binstr [num2bin [::altera_emif::ip_arch_nd::util::get_lane_tid $tile_i $lane_i] 9]
         set lane_tids       [string replace $lane_tids $first $last $lane_tid_binstr]
      }

      set first             [expr {($num_of_rtl_tiles - $tile_i - 1) * 9}]
      set last              [expr {$first + 8}]

      set center_tid_binstr [num2bin [::altera_emif::ip_arch_nd::util::get_center_tid $tile_i] 9]
      set center_tids       [string replace $center_tids $first $last $center_tid_binstr]

      set hmc_tid_binstr    [num2bin [::altera_emif::ip_arch_nd::util::get_hmc_tid $tile_i] 9]
      set hmc_tids          [string replace $hmc_tids $first $last $hmc_tid_binstr]
   }

   set_long_bitvec_hdl_param_value CENTER_TIDS $center_tids
   set_long_bitvec_hdl_param_value HMC_TIDS    $hmc_tids
   set_long_bitvec_hdl_param_value LANE_TIDS   $lane_tids
}

proc ::altera_emif::ip_arch_nd::main::_derive_pipe_lat_parameters {ac_tile_index ac_pm_scheme mem_ports mem_pins_alloc} {

   set num_of_rtl_tiles  [dict size $mem_pins_alloc]
   set lanes_per_tile    [get_family_trait FAMILY_TRAIT_LANES_PER_TILE]
   set lanes_in_if       [expr {$num_of_rtl_tiles * $lanes_per_tile}]

   set dbc_pipe_lats               [string repeat "0000" $lanes_in_if]
   set db_ptr_pipeline_depths      [string repeat "0000" $lanes_in_if]
   set db_seq_rd_en_full_pipelines [string repeat "0000" $lanes_in_if]

   set phy_config_enum           [get_parameter_value "PHY_CONFIG_ENUM"]
   set ping_pong_en              [get_parameter_value "PHY_PING_PONG_EN"]
   set num_of_tiles              [dict size $mem_pins_alloc]
   set ac_pm_enum                [dict get $ac_pm_scheme ENUM]
   set num_of_ac_lanes           [enum_data $ac_pm_enum LANES_USED]
   set sec_hmc_tile_i            [expr {$ping_pong_en ? ($ac_tile_index - 1) : $ac_tile_index}]
   set max_distance_from_ac_tile [expr {max($ac_tile_index, $num_of_tiles - $ac_tile_index - 1)}]
   set ecc_en                    [get_parameter_value CTRL_ECC_EN]
   set is_hps                    [get_is_hps]

   if {$phy_config_enum == "CONFIG_PHY_AND_HARD_CTRL"} {
      if {$ping_pong_en && $max_distance_from_ac_tile > 2} {
         emif_assert {$max_distance_from_ac_tile == 3}
         set max_distance_from_ac_tile 2
      }
      if {$max_distance_from_ac_tile == 0} {
         set max_distance_from_ac_tile 1
      }
   }

   foreach tile_i [lsort -integer -decreasing [dict keys $mem_pins_alloc]] {
      set tile [dict get $mem_pins_alloc $tile_i]

      set lane_list [lsort -integer -decreasing [dict keys $tile]]
      if {$is_hps && (!$ecc_en) && ($tile_i == $ac_tile_index)} {
         set lane_list [linsert $lane_list 0 3]
      }

      foreach lane_i $lane_list {
         set is_ac_lane [expr {$ac_tile_index == $tile_i && $lane_i < $num_of_ac_lanes ? 1 : 0}]

         set is_sec_data_group 0
         if {$ping_pong_en && !$is_ac_lane} {
            set lane [dict get $tile $lane_i]
            foreach pin_i [dict keys $lane] {
               set port       [dict get $lane $pin_i]
               set port_enum  [dict get $port TYPE_ENUM]
               if {[enum_data $port_enum IS_RCLK]} {
                  if {[dict get $port IS_PP_SEC_DATA_GROUP]} {
                     set is_sec_data_group 1
                  }
                  break
               }
            }
         }

         set hmc_tile_i [expr {$ping_pong_en && $is_sec_data_group ? $sec_hmc_tile_i : $ac_tile_index}]
         set distance_from_hmc_tile [expr {abs($tile_i - $hmc_tile_i)}]
         set distance_from_ac_tile  [expr {abs($tile_i - $ac_tile_index)}]

         set dbc_pipe_lat [expr {$distance_from_hmc_tile + 1}]

         if {$phy_config_enum == "CONFIG_PHY_AND_HARD_CTRL"} {
            set db_ptr_pipeline_depth [expr {$max_distance_from_ac_tile - $distance_from_ac_tile}]
            if {$is_ac_lane} {
               incr db_ptr_pipeline_depth -1
            }
            if {$ping_pong_en && $is_sec_data_group} {
               incr db_ptr_pipeline_depth 1
            }
         } else {
            set db_ptr_pipeline_depth [expr {$max_distance_from_ac_tile - $distance_from_ac_tile}]
         }

         if {$phy_config_enum == "CONFIG_PHY_AND_HARD_CTRL"} {
            set db_seq_rd_en_full_pipeline [expr {$max_distance_from_ac_tile + 1}]
            if {$ping_pong_en && $is_sec_data_group} {
               incr db_seq_rd_en_full_pipeline 1
            }
         } else {
            set db_seq_rd_en_full_pipeline [expr {$max_distance_from_ac_tile - $distance_from_ac_tile + 1}]
         }

         emif_assert {$dbc_pipe_lat >= 0}
         emif_assert {$dbc_pipe_lat <= 7}
         emif_assert {$db_ptr_pipeline_depth >= 0}
         emif_assert {$db_ptr_pipeline_depth <= 4}
         emif_assert {$db_seq_rd_en_full_pipeline >= 0}
         emif_assert {$db_seq_rd_en_full_pipeline <= 4}

         set abs_lane_index                    [expr {$tile_i * $lanes_per_tile + $lane_i}]
         set first                             [expr {($lanes_in_if - $abs_lane_index - 1) * 4}]
         set last                              [expr {$first + 3}]
         set dbc_pipe_lat_binstr               [num2bin $dbc_pipe_lat 4]
         set dbc_pipe_lats                     [string replace $dbc_pipe_lats $first $last $dbc_pipe_lat_binstr]
         set db_ptr_pipeline_depth_binstr      [num2bin $db_ptr_pipeline_depth 4]
         set db_ptr_pipeline_depths            [string replace $db_ptr_pipeline_depths $first $last $db_ptr_pipeline_depth_binstr]
         set db_seq_rd_en_full_pipeline_binstr [num2bin $db_seq_rd_en_full_pipeline 4]
         set db_seq_rd_en_full_pipelines       [string replace $db_seq_rd_en_full_pipelines $first $last $db_seq_rd_en_full_pipeline_binstr]

      }
   }

   set_long_bitvec_hdl_param_value DBC_PIPE_LATS               $dbc_pipe_lats
   set_long_bitvec_hdl_param_value DB_PTR_PIPELINE_DEPTHS      $db_ptr_pipeline_depths
   set_long_bitvec_hdl_param_value DB_SEQ_RD_EN_FULL_PIPELINES $db_seq_rd_en_full_pipelines
}

proc ::altera_emif::ip_arch_nd::main::_derive_protocol_specific_hmc_cfg_parameters {} {
   foreach hmc_inst [list "PRI" "SEC"] {
      set settings [::altera_emif::ip_arch_nd::protocol_expert::get_hmc_cfgs $hmc_inst]
      foreach hmc_cfg_enum [dict keys $settings] {
         set val  [dict get $settings $hmc_cfg_enum]
         set name "${hmc_inst}_${hmc_cfg_enum}"
         set_parameter_value $name $val
      }
   }
}

proc ::altera_emif::ip_arch_nd::main::_derive_protocol_specific_ctrl_parameters {} {
   set settings [::altera_emif::ip_arch_nd::protocol_expert::get_ctrl_params]
   foreach param [dict keys $settings] {
      set val [dict get $settings $param]
      set_parameter_value $param $val
   }
}

proc ::altera_emif::ip_arch_nd::main::_derive_protocol_specific_mem_parameters {} {
   set settings [::altera_emif::ip_arch_nd::protocol_expert::get_mem_params]
   foreach param [dict keys $settings] {
      set val [dict get $settings $param]
      set_parameter_value $param $val
   }
}

proc ::altera_emif::ip_arch_nd::main::_derive_iossm_parameters {} {

   set calbus_phyclk_min_ratio 8

   set mem_clk_freq_mhz  [get_parameter_value PHY_MEM_CLK_FREQ_MHZ]
   set clk_ratios        [altera_emif::ip_arch_nd::protocol_expert::get_clk_ratios]
   set phy_hmc_clk_ratio [dict get $clk_ratios PHY_HMC]
   set afi_clk_freq_mhz  [expr {$mem_clk_freq_mhz * 1.0 / $phy_hmc_clk_ratio}]

   set sim_nios_clk_period_ps 500
   set max_cal_clk_divide 30
   set cal_clk_divide [expr {int(ceil((1000000.0 / $sim_nios_clk_period_ps) * $calbus_phyclk_min_ratio / $afi_clk_freq_mhz))}]

   set cal_clk_divide [expr {($cal_clk_divide % 2 == 0) ? $cal_clk_divide : ($cal_clk_divide + 1)}]

   if {$cal_clk_divide > $max_cal_clk_divide} {
      set cal_clk_divide $max_cal_clk_divide
      set sim_nios_clk_freq_mhz   [expr {int(floor($max_cal_clk_divide * $afi_clk_freq_mhz / $calbus_phyclk_min_ratio))}]
      set sim_nios_clk_period_ps  [expr {int(ceil(1000000.0 / $sim_nios_clk_freq_mhz))}]
   }

   set_parameter_value SEQ_SIM_CAL_CLK_DIVIDE   $cal_clk_divide
   set_parameter_value SEQ_SYNTH_CAL_CLK_DIVIDE $max_cal_clk_divide
   set_parameter_value SEQ_SIM_NIOS_PERIOD_PS   $sim_nios_clk_period_ps
}

proc ::altera_emif::ip_arch_nd::main::_derive_core_logic_parameters {} {
   if {[get_is_hps]} {
      set_parameter_value REGISTER_AFI_C2P 0
      set_parameter_value REGISTER_AFI_P2C 0
      set_parameter_value REGISTER_AMM_P2C 0
      set_parameter_value WIRELUTS_FOR_C2P 0
   } else {
      set extra_configs_str   [get_parameter_value "DIAG_EXTRA_CONFIGS"]
      set extra_configs       [parse_extra_configs $extra_configs_str]
      set die_revs            [get_device_die_revisions]
      set ratios              [altera_emif::ip_arch_nd::protocol_expert::get_clk_ratios]
      set protocol_enum       [get_parameter_value PROTOCOL_ENUM]
      set mem_clk_freq_mhz    [get_parameter_value PHY_MEM_CLK_FREQ_MHZ]
      set c2p_p2c_freq_mhz    [expr {$mem_clk_freq_mhz * 1.0 / [dict get $ratios C2P_P2C]}]
      set disable_afi_p2c_reg [get_parameter_value "DIAG_DISABLE_AFI_P2C_REGISTERS"]

      if {$disable_afi_p2c_reg} {
         set_parameter_value REGISTER_AFI_C2P 1
         set_parameter_value REGISTER_AFI_P2C 0
      } else {
         set_parameter_value REGISTER_AFI_C2P 1
         set_parameter_value REGISTER_AFI_P2C 1
      }

      set_parameter_value REGISTER_AMM_P2C 1

      if {[dict exists $extra_configs WIRELUTS_FOR_C2P]} {
         set_parameter_value WIRELUTS_FOR_C2P [dict get $extra_configs WIRELUTS_FOR_C2P]
      } else {
         set is_nd5_reva [expr {[lsearch -nocase -regexp $die_revs {\_ND5\_REVA}] >= 0 ? 1 : 0}]
         if {$is_nd5_reva} {
            set_parameter_value WIRELUTS_FOR_C2P 0
         } elseif {$protocol_enum == "PROTOCOL_DDRT"} {
            set_parameter_value WIRELUTS_FOR_C2P 0
         } else {
            set_parameter_value WIRELUTS_FOR_C2P 3
         }
      }
   }
}

proc ::altera_emif::ip_arch_nd::main::_set_interface_properties {if_ports} {

   set phy_config_enum        [get_parameter_value "PHY_CONFIG_ENUM"]
   set ping_pong_en           [get_parameter_value "PHY_PING_PONG_EN"]
   set core_clks_sharing_enum [get_parameter_value PHY_CORE_CLKS_SHARING_ENUM]

   set_interface_property [dict get $if_ports IF_CTRL_MMR_SLAVE INSTS 0 NAME] IPXACT_REGISTER_MAP "nd_mmr.ipxact"   

   if {$phy_config_enum == "CONFIG_PHY_AND_HARD_CTRL"} {

      set emif_usr_reset_pri_if_name [dict get $if_ports IF_EMIF_USR_RESET INSTS -1 NAME]
      set emif_usr_reset_sec_if_name [dict get $if_ports IF_EMIF_USR_RESET_SEC INSTS -1 NAME]
      set_interface_property $emif_usr_reset_pri_if_name synchronousEdges NONE
      set_interface_property $emif_usr_reset_sec_if_name synchronousEdges NONE

      set_interface_property $emif_usr_reset_pri_if_name associatedResetSinks [list none]
      set_interface_property $emif_usr_reset_sec_if_name associatedResetSinks [list none]

      set emif_usr_half_clk_if_enabled     [dict get $if_ports IF_EMIF_USR_HALF_CLK INSTS -1 ENABLED]
      set emif_usr_half_clk_pri_if_name    [dict get $if_ports IF_EMIF_USR_HALF_CLK INSTS -1 NAME]
      set emif_usr_half_clk_sec_if_name    [dict get $if_ports IF_EMIF_USR_HALF_CLK_SEC INSTS -1 NAME]
      set emif_usr_clk_pri_if_name         [dict get $if_ports IF_EMIF_USR_CLK INSTS -1 NAME]
      set emif_usr_clk_sec_if_name         [dict get $if_ports IF_EMIF_USR_CLK_SEC INSTS -1 NAME]

      if {$emif_usr_half_clk_if_enabled} {
         set avl_if_clk_pri $emif_usr_half_clk_pri_if_name
         set avl_if_clk_sec $emif_usr_half_clk_sec_if_name
      } else {
         set avl_if_clk_pri $emif_usr_clk_pri_if_name
         set avl_if_clk_sec $emif_usr_clk_sec_if_name
      }

      foreach if_enum [list IF_CTRL_AMM IF_CTRL_AST_CMD IF_CTRL_AST_WR IF_CTRL_AST_RD IF_CTRL_MMR_SLAVE] {
         foreach if_index [dict keys [dict get $if_ports $if_enum INSTS]] {
            set if_name [dict get $if_ports $if_enum INSTS $if_index NAME]

            if {$ping_pong_en && $if_index == 1} {
               set_interface_property $if_name associatedClock $avl_if_clk_sec
               set_interface_property $if_name associatedReset $emif_usr_reset_sec_if_name
            } else {
               set_interface_property $if_name associatedClock $avl_if_clk_pri
               set_interface_property $if_name associatedReset $emif_usr_reset_pri_if_name
            }
         }
      }

      altera_emif::util::hwtcl_utils::set_clock_sources_rate_properties \
         $emif_usr_clk_pri_if_name \
         $emif_usr_half_clk_pri_if_name \
         $emif_usr_clk_sec_if_name \
         $emif_usr_half_clk_sec_if_name \
         "" \
         ""

      set amm_if_props [::altera_emif::ip_arch_nd::protocol_expert::get_interface_properties IF_CTRL_AMM]
      foreach if_index [dict keys [dict get $if_ports IF_CTRL_AMM INSTS]] {
         set if_name [dict get $if_ports IF_CTRL_AMM INSTS $if_index NAME]
         ::altera_emif::util::hwtcl_utils::set_ctrl_amm_if_properties $if_name $amm_if_props
      }

      foreach if_index [dict keys [dict get $if_ports IF_CTRL_MMR_SLAVE INSTS]] {
         set if_name [dict get $if_ports IF_CTRL_MMR_SLAVE INSTS $if_index NAME]

         set_interface_property $if_name bitsPerSymbol 8

         set_interface_property $if_name maximumPendingReadTransactions 1

         set_interface_property $if_name constantBurstBehavior false
      }

      set ast_cmd_if_props [::altera_emif::ip_arch_nd::protocol_expert::get_interface_properties IF_CTRL_AST_CMD]
      set ast_rd_if_props  [::altera_emif::ip_arch_nd::protocol_expert::get_interface_properties IF_CTRL_AST_RD]
      set ast_wr_if_props  [::altera_emif::ip_arch_nd::protocol_expert::get_interface_properties IF_CTRL_AST_WR]

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
   } else {
      set afi_clk_if_name      [dict get $if_ports IF_AFI_CLK INSTS -1 NAME]
      set afi_half_clk_if_name [dict get $if_ports IF_AFI_HALF_CLK INSTS -1 NAME]

      set afi_reset_if_name [dict get $if_ports IF_AFI_RESET INSTS -1 NAME]
      set_interface_property $afi_reset_if_name synchronousEdges NONE
      set_interface_property $afi_reset_if_name associatedResetSinks [list none]

      altera_emif::util::hwtcl_utils::set_clock_sources_rate_properties "" "" "" "" $afi_clk_if_name $afi_half_clk_if_name
   }

   set cal_master_clk_name   [dict get $if_ports IF_CAL_MASTER_CLK INSTS -1 NAME]
   set cal_master_reset_name [dict get $if_ports IF_CAL_MASTER_RESET INSTS -1 NAME]
   if {[get_interface_property $cal_master_reset_name ENABLED]} {
      set_interface_property $cal_master_reset_name associatedClock $cal_master_clk_name
      set_interface_property $cal_master_reset_name associatedResetSinks [list none]
   }

   set cal_slave_clk_name   [dict get $if_ports IF_CAL_SLAVE_CLK INSTS -1 NAME]
   set cal_slave_reset_name [dict get $if_ports IF_CAL_SLAVE_RESET INSTS -1 NAME]
   if {[get_interface_property $cal_slave_reset_name ENABLED]} {
      set_interface_property $cal_slave_reset_name associatedClock $cal_slave_clk_name
      set_interface_property $cal_slave_reset_name associatedResetSinks [list none]
   }

   set cal_debug_clk_name   [dict get $if_ports IF_CAL_DEBUG_CLK INSTS -1 NAME]
   set cal_debug_reset_name [dict get $if_ports IF_CAL_DEBUG_RESET INSTS -1 NAME]
   if {[get_interface_property $cal_debug_reset_name ENABLED]} {
      set_interface_property $cal_debug_reset_name associatedClock $cal_debug_clk_name
   }
   set cal_debug_out_clk_name   [dict get $if_ports IF_CAL_DEBUG_OUT_CLK INSTS -1 NAME]
   set cal_debug_out_reset_name [dict get $if_ports IF_CAL_DEBUG_OUT_RESET INSTS -1 NAME]
   if {[get_interface_property $cal_debug_out_reset_name ENABLED]} {
      set_interface_property $cal_debug_out_reset_name associatedClock $cal_debug_out_clk_name
      set_interface_property $cal_debug_out_reset_name associatedResetSinks [list none]
   }
   set cal_slave_clk_in_name   [dict get $if_ports IF_CAL_SLAVE_CLK_IN INSTS -1 NAME]
   set cal_slave_reset_in_name [dict get $if_ports IF_CAL_SLAVE_RESET_IN INSTS -1 NAME]
   if {[get_interface_property $cal_slave_reset_in_name ENABLED]} {
      set_interface_property $cal_slave_reset_in_name associatedClock $cal_slave_clk_in_name
   }

   foreach if_index [dict keys [dict get $if_ports IF_CAL_DEBUG INSTS]] {
      set if_name [dict get $if_ports IF_CAL_DEBUG INSTS $if_index NAME]
      set_interface_property $if_name associatedClock $cal_debug_clk_name
      set_interface_property $if_name associatedReset $cal_debug_reset_name

      set symbol_width 8
      set_interface_property $if_name bitsPerSymbol $symbol_width

      set_interface_property $if_name maximumPendingReadTransactions 1

      set_interface_property $if_name constantBurstBehavior false

      set_interface_property $if_name addressUnits SYMBOLS
   }

   foreach if_index [dict keys [dict get $if_ports IF_CAL_DEBUG_OUT INSTS]] {
      set if_name [dict get $if_ports IF_CAL_DEBUG_OUT INSTS $if_index NAME]
      set_interface_property $if_name associatedClock $cal_debug_out_clk_name
      set_interface_property $if_name associatedReset $cal_debug_out_reset_name

      set symbol_width 8
      set_interface_property $if_name bitsPerSymbol $symbol_width

      set_interface_property $if_name maximumPendingReadTransactions 1

      set_interface_property $if_name constantBurstBehavior false

      set_interface_property $if_name addressUnits SYMBOLS
   }

   foreach if_index [dict keys [dict get $if_ports IF_CAL_MASTER INSTS]] {
      set if_name [dict get $if_ports IF_CAL_MASTER INSTS $if_index NAME]
      set_interface_property $if_name associatedClock $cal_slave_clk_in_name
      set_interface_property $if_name associatedReset $cal_slave_reset_in_name

      set symbol_width 8
      set_interface_property $if_name bitsPerSymbol $symbol_width

      set_interface_property $if_name maximumPendingReadTransactions 1

      set_interface_property $if_name constantBurstBehavior false

      set_interface_property $if_name addressUnits SYMBOLS
   }
}

proc ::altera_emif::ip_arch_nd::main::_get_is_interface_disabled_in_hps_mode {if_enum} {
   switch $if_enum {
      IF_PLL_REF_CLK -
      IF_MEM -
      IF_HPS_EMIF -
      IF_CAL_DEBUG_CLK -
      IF_CAL_DEBUG_RESET -
      IF_CAL_SLAVE_CLK_IN -
      IF_CAL_SLAVE_RESET_IN -
      IF_CAL_MASTER -
      IF_OCT {
         return false
      }
      default {
         return true
      }
   }
}

proc ::altera_emif::ip_arch_nd::main::_get_number_of_unique_calibrated_oct_values {} {
   set ac_calibrated_oct      [get_parameter_value "PHY_AC_CALIBRATED_OCT"]
   set ck_calibrated_oct      [get_parameter_value "PHY_CK_CALIBRATED_OCT"]
   set data_calibrated_oct    [get_parameter_value "PHY_DATA_CALIBRATED_OCT"]
   set ac_mode_enum           [get_parameter_value "PHY_AC_MODE_ENUM"]
   set ck_mode_enum           [get_parameter_value "PHY_CK_MODE_ENUM"]
   set data_out_mode_enum     [get_parameter_value "PHY_DATA_OUT_MODE_ENUM"]

   set list_of_oct_values []
   if {$ac_calibrated_oct} {
      lappend list_of_oct_values $ac_mode_enum
   }
   if {$ck_calibrated_oct} {
      lappend list_of_oct_values $ck_mode_enum
   }
   if {$data_calibrated_oct} {
      lappend list_of_oct_values $data_out_mode_enum
   }
   set list_of_unique_oct_values [lsort -unique $list_of_oct_values]
   set num_of_unique_oct_values [llength $list_of_unique_oct_values]

   return $num_of_unique_oct_values
}

proc ::altera_emif::ip_arch_nd::main::_validate {} {
   set retval 1

   if {[get_is_hps]} {
      if {![::altera_emif::ip_arch_nd::hps::check_hps_compatibility]} {
         set retval 0
      }
   }

   set protocol_enum      [get_parameter_value "PROTOCOL_ENUM"]
   set config_enum        [get_parameter_value "PHY_CONFIG_ENUM"]
   set data_width         [get_parameter_value "MEM_TTL_DATA_WIDTH"]
   set num_of_read_groups [get_parameter_value "MEM_TTL_NUM_OF_READ_GROUPS"]
   set ac_calibrated_oct  [get_parameter_value "PHY_AC_CALIBRATED_OCT"]
   set ck_calibrated_oct  [get_parameter_value "PHY_CK_CALIBRATED_OCT"]
   set ac_io_std_enum     [get_parameter_value "PHY_AC_IO_STD_ENUM"]
   set ck_io_std_enum     [get_parameter_value "PHY_CK_IO_STD_ENUM"]
   set data_io_std_enum   [get_parameter_value "PHY_DATA_IO_STD_ENUM"]
   set ac_mode_enum       [get_parameter_value "PHY_AC_MODE_ENUM"]
   set ck_mode_enum       [get_parameter_value "PHY_CK_MODE_ENUM"]
   set group_size         [expr {$data_width / $num_of_read_groups}]

   if {$config_enum == "CONFIG_PHY_AND_HARD_CTRL"} {
      if {![altera_emif::ip_arch_nd::protocol_expert::check_hmc_legality]} {
         set retval 0
      }
   }

   if {$protocol_enum == "PROTOCOL_DDR4"} {
      if {$ac_calibrated_oct && $ck_calibrated_oct && $ac_mode_enum != $ck_mode_enum} {
         post_ipgen_e_msg MSG_EXCEED_MAX_NUM_OF_OCT_VALUES [list "CTT" 1 2]
         set retval 0
      }
   } else {
      set is_ac_using_pod [regexp {_POD_} $ac_io_std_enum]
      set is_ck_using_pod [regexp {_POD_} $ck_io_std_enum]
      set is_data_using_pod [regexp {_POD_} $data_io_std_enum]
      set num_unique_cal_oct_vals [::altera_emif::ip_arch_nd::main::_get_number_of_unique_calibrated_oct_values]
      if {!$is_ac_using_pod && !$is_ck_using_pod && !$is_data_using_pod} {
         if {$num_unique_cal_oct_vals > 2} {
            post_ipgen_e_msg MSG_EXCEED_MAX_NUM_OF_OCT_VALUES [list "CTT" 2 $num_unique_cal_oct_vals]
            set retval 0
         }
      } elseif {$is_ac_using_pod && $is_ck_using_pod && $is_data_using_pod} {
         if {$num_unique_cal_oct_vals > 1} {
            post_ipgen_e_msg MSG_EXCEED_MAX_NUM_OF_OCT_VALUES [list "POD" 1 $num_unique_cal_oct_vals]
            set retval 0
         }
      }
   }

   return $retval
}

proc ::altera_emif::ip_arch_nd::main::_update_nd_qip {qip_strings_all} {

   set is_hps [get_is_hps]
   upvar 1 $qip_strings_all qip_strings

   if {$is_hps} {
      set ecc_en     [get_parameter_value CTRL_ECC_EN]
      set dq_width   [get_parameter_value MEM_TTL_DATA_WIDTH]


      if {$ecc_en} {
         set ecc_str "on"
      } else {
         set ecc_str "off"
      }

      if {$dq_width <= 24} {
         set mode_str "x16"
      } elseif {$dq_width <= 40} {
         set mode_str "x32"
      } else {
         set mode_str "x64"
      }

      set hps_isw_str         "ECC $ecc_str MODE $mode_str"
      set hps_qip_handoff_str "set_global_assignment -entity \"%entityName%\" -library \"%libraryName%\" -name HPS_ISW_EMIF \"$hps_isw_str\""

      lappend qip_strings $hps_qip_handoff_str

   }

}

proc ::altera_emif::ip_arch_nd::main::_init {} {
}

::altera_emif::ip_arch_nd::main::_init

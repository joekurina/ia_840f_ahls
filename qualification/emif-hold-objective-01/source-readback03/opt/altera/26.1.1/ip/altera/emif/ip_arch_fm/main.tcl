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


package provide altera_emif::ip_arch_fm::main 0.1

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
package require altera_emif::ip_arch_fm::enum_defs
package require altera_emif::ip_arch_fm::enum_defs_seq_param_tbl
package require altera_emif::ip_arch_fm::enum_defs_ac_pin_mapping
package require altera_emif::ip_arch_fm::enum_defs_hmc_cfgs
package require altera_emif::ip_arch_fm::protocol_expert
package require altera_emif::ip_arch_fm::pll
package require altera_emif::ip_arch_fm::seq_param_tbl
package require altera_emif::ip_arch_fm::util
package require altera_emif::ip_arch_fm::rtl_autogen
package require altera_emif::ip_arch_fm::doc_gen
package require altera_emif::ip_arch_fm::timing
package require altera_emif::ip_arch_fm::bsi
package require altera_emif::ip_arch_fm::hps

namespace eval ::altera_emif::ip_arch_fm::main:: {

   namespace import ::altera_emif::util::messaging::*
   namespace import ::altera_emif::util::math::*
   namespace import ::altera_emif::util::qini::*
   namespace import ::altera_emif::util::enums::*
   namespace import ::altera_emif::util::hwtcl_utils::*
   namespace import ::altera_emif::util::device_family::*
   namespace import ::altera_emif::ip_arch_fm::util::*
   namespace import ::altera_emif::ip_arch_fm::protocol_expert::*


}


proc ::altera_emif::ip_arch_fm::main::create_parameters {} {
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
   set_parameter_property PHY_MIMIC_HPS_EMIF            HDL_PARAMETER true
   set_parameter_property MEM_FORMAT_ENUM               HDL_PARAMETER true
   set_parameter_property MEM_BURST_LENGTH              HDL_PARAMETER true
   set_parameter_property MEM_DATA_MASK_EN              HDL_PARAMETER true
   set_parameter_property MEM_TTL_DATA_WIDTH            HDL_PARAMETER true
   set_parameter_property MEM_TTL_NUM_OF_READ_GROUPS    HDL_PARAMETER true
   set_parameter_property MEM_TTL_NUM_OF_WRITE_GROUPS   HDL_PARAMETER true
   set_parameter_property DIAG_SIM_REGTEST_MODE         HDL_PARAMETER true
   set_parameter_property DIAG_SYNTH_FOR_SIM            HDL_PARAMETER true
   set_parameter_property DIAG_FAST_SIM                 HDL_PARAMETER true
   set_parameter_property DIAG_SIM_VERBOSE_LEVEL        HDL_PARAMETER true
   set_parameter_property DIAG_ECLIPSE_DEBUG            HDL_PARAMETER true
   set_parameter_property DIAG_SEQ_RESET_AUTO_RELEASE   HDL_PARAMETER true
   set_parameter_property DIAG_DB_RESET_AUTO_RELEASE    HDL_PARAMETER true
   set_parameter_property DIAG_USE_ABSTRACT_PHY         HDL_PARAMETER true
   set_parameter_property PLL_NUM_OF_EXTRA_CLKS         HDL_PARAMETER true

   add_derived_hdl_param     SILICON_REV                    string           ""
   add_derived_hdl_param     IS_HPS                         boolean          false
   add_derived_hdl_param     USER_CLK_RATIO                 integer          1
   add_derived_hdl_param     C2P_P2C_CLK_RATIO              integer          1
   add_derived_hdl_param     PHY_HMC_CLK_RATIO              integer          1
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

   add_derived_hdl_param     SEQ_PT_SYN_CONTENT             string           ""
   add_derived_hdl_param     SEQ_PT_SIM_CONTENT             string           ""

   add_derived_hdl_param     REGISTER_AFI_C2P               integer          1
   add_derived_hdl_param     REGISTER_AFI_P2C               integer          1
   add_derived_hdl_param     REGISTER_AMM_P2C               integer          1
   add_derived_hdl_param     REGISTER_AMM_C2P               integer          1
   set_parameter_property REGISTER_AMM_P2C AFFECTS_ELABORATION true
   set_parameter_property REGISTER_AMM_C2P AFFECTS_ELABORATION true

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
   add_long_bitvec_hdl_param LANE_PIN_USAGE                 [expr {$max_pins_per_if  * [string length [enum_data LANE_PIN_UNUSED BITSTR]]}]
   add_long_bitvec_hdl_param PINS_RATE                      [expr {$max_pins_per_if  * [string length [enum_data PIN_RATE_NOT_APPLICABLE BITSTR]]}]
   add_long_bitvec_hdl_param DB_PINS_PROC_MODE              [expr {$max_pins_per_if  * [string length [enum_data DB_PIN_PROC_MODE_NOT_APPLICABLE BITSTR]]}]
   add_long_bitvec_hdl_param PINS_DATA_IN_MODE              [expr {$max_pins_per_if  * [string length [enum_data PIN_DATA_IN_MODE_DISABLED BITSTR]]}]
   add_long_bitvec_hdl_param PINS_C2L_DRIVEN                [expr {$max_pins_per_if  * 1}]
   add_long_bitvec_hdl_param PINS_OCT_MODE                  [expr {$max_pins_per_if  * [string length [enum_data PIN_OCT_STATIC_OFF]]}]
   add_long_bitvec_hdl_param PINS_DCC_SPLIT                 [expr {$max_pins_per_if  * 1}]
   add_long_bitvec_hdl_param UNUSED_MEM_PINS_PINLOC         [expr {$max_pins_per_if      * 10 + 10}]
   add_long_bitvec_hdl_param UNUSED_DQS_BUSES_LANELOC       [expr {$max_dqs_buses_per_if * 10 + 10}]

   add_derived_hdl_param     DBC_EXTRA_PIPE_STAGE_EN        string         "disable"
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
   set_parameter_property PHY_USERMODE_OCT AFFECTS_ELABORATION true

   add_derived_hdl_param PHY_PERIODIC_OCT_RECAL             boolean          false

   add_derived_hdl_param GENERATE_PHYLITE                   boolean          false

   add_derived_hdl_param HPRX_CTLE_EN                       string           "on"
   add_derived_hdl_param HPRX_OFFSET_CAL                    string           "true"

   add_derived_hdl_param CPA_FB_MUX_1_SEL                   string           ""

   add_derived_hdl_param ENABLE_RD_TYPE                     boolean          false

   add_derived_hdl_param AMM_C2P_UFI_MODE                   string           ""
   add_derived_hdl_param AMM_P2C_UFI_MODE                   string           ""
   add_derived_hdl_param MMR_C2P_UFI_MODE                   string           ""
   add_derived_hdl_param MMR_P2C_UFI_MODE                   string           ""
   add_derived_hdl_param SIDEBAND_C2P_UFI_MODE              string           ""
   add_derived_hdl_param SIDEBAND_P2C_UFI_MODE              string           ""
   add_derived_hdl_param SEQ_C2P_UFI_MODE                   string           ""
   add_derived_hdl_param SEQ_P2C_UFI_MODE                   string           ""
   add_derived_hdl_param ECC_C2P_UFI_MODE                   string           ""
   add_derived_hdl_param ECC_P2C_UFI_MODE                   string           ""
   add_derived_hdl_param LANE_C2P_UFI_MODE                  string           ""
   add_derived_hdl_param LANE_P2C_UFI_MODE                  string           ""

   add_derived_hdl_param AMM_HIPI_DELAY                     integer          225
   add_derived_hdl_param MMR_HIPI_DELAY                     integer          225
   add_derived_hdl_param SIDEBAND_HIPI_DELAY                integer          225
   add_derived_hdl_param SEQ_HIPI_DELAY                     integer          225
   add_derived_hdl_param ECC_HIPI_DELAY                     integer          225
   add_derived_hdl_param LANE_HIPI_DELAY                    integer          225

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

   foreach arch_fm_if_enum [enums_of_type ARCH_FM_IF] {
      set if_enum        [enum_data $arch_fm_if_enum IF_ENUM]
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

   altera_emif::ip_arch_fm::pll::add_pll_parameters

   if {[info exists ::env(EMIF_AUTOGEN_CODE_FM)] && $::env(EMIF_AUTOGEN_CODE_FM)} {
      if {[altera_emif::ip_arch_fm::rtl_autogen::update_rtl]} {
         emif_ie "Successfully updated RTL - Turn off this mode, run make, and re-test IP generation"
      } else {
         emif_ie "Unable to update RTL - make sure files requiring updates are writable"
      }
   }

   return 1
}

proc ::altera_emif::ip_arch_fm::main::elaboration_callback {} {
   ::altera_emif::util::device_family::load_data

   if {[emif_utest_enabled]} {
      set data [::altera_emif::ip_arch_fm::protocol_expert::run_elab_time_utests]
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
   _derive_core_logic_parameters
   altera_emif::ip_arch_fm::pll::derive_pll_parameters

   post_ipgen_i_msg MSG_FM_REQ_CAL_IP_PORTS

   set seq_param_tbl [altera_emif::ip_arch_fm::seq_param_tbl::derive_seq_pt_content $mem_ports $mem_pins_alloc]
   altera_emif::ip_arch_fm::seq_param_tbl::set_synth_opts seq_param_tbl
   altera_emif::ip_arch_fm::seq_param_tbl::set_extra_configs_overrides seq_param_tbl
   set words         [altera_emif::arch_common::seq_param_tbl::_get_packed_words $seq_param_tbl SEQ_PT]
   set_parameter_value SEQ_PT_SYN_CONTENT [altera_emif::ip_arch_fm::util::get_padded_pt_content $words]

   altera_emif::ip_arch_fm::seq_param_tbl::set_sim_opts seq_param_tbl
   set words         [altera_emif::arch_common::seq_param_tbl::_get_packed_words $seq_param_tbl SEQ_PT]
   set_parameter_value SEQ_PT_SIM_CONTENT [altera_emif::ip_arch_fm::util::get_padded_pt_content $words]

   altera_emif::arch_common::main::update_qip $if_ports

   if {[has_pending_ipgen_e_msg]} {
      issue_pending_ipgen_e_msg_and_terminate
   } else {
      set phy_config_enum [get_parameter_value "PHY_CONFIG_ENUM"]
      set ratios [altera_emif::ip_arch_fm::protocol_expert::get_clk_ratios]

      if {[check_device_is_reva] && $phy_config_enum == "CONFIG_PHY_AND_HARD_CTRL"} {
         set num_of_data_endpoints [get_parameter_value "MEM_NUM_OF_DATA_ENDPOINTS"]
         if {$num_of_data_endpoints > 1 && [altera_emif::ip_arch_fm::protocol_expert::is_phy_shadow_register_disabled]} {
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

      set phy_tracking_en [altera_emif::ip_arch_fm::protocol_expert::is_phy_tracking_enabled]
      if {$phy_tracking_en} {
         post_ipgen_i_msg MSG_USE_PHY_TRACKING
      }

      set ac_pm_scheme      [altera_emif::ip_arch_fm::protocol_expert::get_ac_pin_map_scheme]
      set ac_pm_enum        [dict get $ac_pm_scheme ENUM]
      post_ipgen_i_msg MSG_ADDR_CMD_PIN_MAP_SCHEME_INFO [list [enum_data $ac_pm_enum USER_STRING]]

      set num_of_rtl_tiles [dict size $mem_pins_alloc]
      set num_of_io96 [expr { ($num_of_rtl_tiles / 2) + ($num_of_rtl_tiles % 2) }]
      post_ipgen_i_msg MSG_RESOURCE_USAGE [list $num_of_io96 $num_of_rtl_tiles]

      set ref_clk_freq_mhz [get_parameter_value PHY_REF_CLK_FREQ_MHZ]
      set valid_mem_clk_freqs [altera_emif::ip_arch_fm::pll::get_legal_mem_clk_freqs_mhz]
      if {[llength $valid_mem_clk_freqs] > 0} {
         set valid_mem_clk_freqs [lsort -real -decreasing $valid_mem_clk_freqs]
         set msg_string [join $valid_mem_clk_freqs ", "]
         post_ipgen_i_msg MSG_LEGAL_MEM_CLK_FREQS [list $ref_clk_freq_mhz $msg_string]
      }

      post_ipgen_i_msg MSG_README_INFO [list]
   }


   set write_protocol_enum       [get_parameter_value "MEM_RLD3_WRITE_PROTOCOL_ENUM"]
   set write_protocol            [enum_data $write_protocol_enum MRS]
   set_parameter_value ABPHY_WRITE_PROTOCOL  $write_protocol

   set NUM_IPS       [get_parameter_value "NUM_IPS"]
   set NUM_IPS_SAVED [get_parameter_value "NUM_IPS_SAVED"]
   if {$NUM_IPS > 1} {
      if { $NUM_IPS_SAVED != $NUM_IPS } {
         set retval 0
         post_ipgen_e_msg "Please configure and capture all EMIF IPs. Currently $NUM_IPS_SAVED/$NUM_IPS saved."
         issue_pending_ipgen_e_msg_and_terminate
      } else {
         post_ipgen_i_msg "All EMIF IPs are configured"
      }
   }

   return 1
}

proc ::altera_emif::ip_arch_fm::main::sim_fileset_callback {top_level is_vhd} {
   set rtl_only 0
   set encrypted 0

   set if_ports [_generate_if_ports true]

   set extra_params [list [list SEQ_USE_SIM_PARAMS "\"on\""]]

   set file_paths [concat [::altera_emif::util::hwtcl_utils::generate_dynamic_unique_name_rtl "altera_emif_arch_fm_top" "${top_level}_top" "" ""] \
                          [_generate_verilog_fileset $top_level] \
                          [_generate_abphy_verilog_fileset $top_level] \
                          [_generate_common_fileset $top_level $if_ports]]

   if {$is_vhd} {
      lappend file_paths [::altera_emif::util::hwtcl_utils::generate_top_level_vhd_wrapper $top_level "${top_level}_top" $extra_params]
   } else {
      lappend file_paths [::altera_emif::util::hwtcl_utils::generate_top_level_sv_wrapper $top_level "${top_level}_top" $extra_params]
   }

   set sim_cal_mode_enum [get_parameter_value DIAG_SIM_CAL_MODE_ENUM]
   if {$sim_cal_mode_enum == "SIM_CAL_MODE_FULL"} {
      post_ipgen_w_msg "For 'Full Calibration' simulations, compiler directive \"EMIF_DISABLE_CAL_OPTIMIZATIONS\" must be defined in the simulation script"
   }

   foreach file_path $file_paths {
      set tmp [file split $file_path]
      set file_name [lindex $tmp end]
      add_fileset_file $file_name [::altera_emif::util::hwtcl_utils::get_file_type $file_name $rtl_only $encrypted] PATH $file_path
   }
}

proc ::altera_emif::ip_arch_fm::main::sim_vhdl_fileset_callback {top_level} {
   sim_fileset_callback $top_level 1
}

proc ::altera_emif::ip_arch_fm::main::sim_verilog_fileset_callback {top_level} {
   sim_fileset_callback $top_level 0
}

proc ::altera_emif::ip_arch_fm::main::quartus_synth_fileset_callback {top_level} {
   set rtl_only 0
   set encrypted 0
   set use_sdc_entity 1

   set if_ports [_generate_if_ports true]

   set sim_params_hex_filename     [get_sim_params_hex_filename $top_level]
   set synth_params_hex_filename   [get_synth_params_hex_filename $top_level]

   set extra_params [list [list SEQ_USE_SIM_PARAMS "\"off\""]]

   set file_paths [concat [::altera_emif::util::hwtcl_utils::generate_dynamic_unique_name_rtl "altera_emif_arch_fm_top" "${top_level}_top" "" ""] \
                          [::altera_emif::util::hwtcl_utils::generate_top_level_sv_wrapper $top_level "${top_level}_top" $extra_params] \
                          [_generate_verilog_fileset $top_level] \
                          [_generate_bsi_fileset $top_level $if_ports] \
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


proc ::altera_emif::ip_arch_fm::main::_generate_common_fileset {top_level if_ports} {
   set file_list [list]

   set mem_ports       [dict get $if_ports IF_MEM PORTS]
   set mem_pins_alloc  [dict get $if_ports IF_MEM PINS_ALLOC]

   set pt_param_tbl [altera_emif::ip_arch_fm::seq_param_tbl::derive_seq_pt_content $mem_ports $mem_pins_alloc]
   set param_tbl_filename [::altera_emif::ip_arch_fm::util::get_synth_params_hex_filename $top_level]

   set pt_base_addr             [enum_data SEQ_ADDR_PARAM_TABLE_BASE ADDRESS]
   set glob_param_tbl_byte_size [enum_data SEQ_CONST_GLOBAL_PAR_SIZE VALUE]
   set param_tbl_addr           [expr {$pt_base_addr + $glob_param_tbl_byte_size}]

   altera_emif::ip_arch_fm::seq_param_tbl::set_synth_opts pt_param_tbl
   altera_emif::ip_arch_fm::seq_param_tbl::set_extra_configs_overrides pt_param_tbl
   lappend file_list {*}[altera_emif::arch_common::seq_param_tbl::generate_files_by_pt_type $param_tbl_filename $pt_param_tbl $param_tbl_addr SEQ_PT]

   altera_emif::ip_arch_fm::seq_param_tbl::set_sim_opts pt_param_tbl
   set param_tbl_filename  [get_sim_params_hex_filename $top_level]
   lappend file_list {*}[altera_emif::arch_common::seq_param_tbl::generate_files_by_pt_type $param_tbl_filename $pt_param_tbl $param_tbl_addr SEQ_PT 0]

   set docs [dict create]
   ::altera_emif::ip_arch_fm::doc_gen::add_readme docs $if_ports
   lappend file_list {*}[altera_emif::util::doc_gen::generate_files $top_level $docs]

   return $file_list
}

proc ::altera_emif::ip_arch_fm::main::_generate_timing_fileset {top_level if_ports} {

   set file_list [list]

   lappend file_list {*}[altera_emif::ip_arch_fm::timing::generate_files $top_level $if_ports]

   return $file_list
}

proc ::altera_emif::ip_arch_fm::main::_generate_bsi_fileset {top_level if_ports} {

   set file_list [list]

   lappend file_list {*}[altera_emif::ip_arch_fm::bsi::generate_files $top_level $if_ports]

   return $file_list
}


proc ::altera_emif::ip_arch_fm::main::_generate_verilog_fileset {top_level} {
   set file_list [list \
      rtl/altera_emif_arch_fm_bufs.sv \
      rtl/altera_emif_arch_fm_ufis.sv \
      rtl/altera_emif_arch_fm_ufi_wrapper.sv \
      rtl/altera_emif_arch_fm_buf_udir_se_i.sv \
      rtl/altera_emif_arch_fm_buf_udir_se_o.sv \
      rtl/altera_emif_arch_fm_buf_udir_df_i.sv \
      rtl/altera_emif_arch_fm_buf_udir_df_o.sv \
      rtl/altera_emif_arch_fm_buf_udir_cp_i.sv \
      rtl/altera_emif_arch_fm_buf_bdir_df.sv \
      rtl/altera_emif_arch_fm_buf_bdir_se.sv \
      rtl/altera_emif_arch_fm_buf_unused.sv \
      rtl/altera_emif_arch_fm_cal_counter.sv \
      rtl/altera_emif_arch_fm_pll.sv \
      rtl/altera_emif_arch_fm_pll_fast_sim.sv \
      rtl/altera_emif_arch_fm_pll_extra_clks.sv \
      rtl/altera_emif_arch_fm_oct.sv \
      rtl/altera_emif_arch_fm_core_clks_rsts.sv \
      rtl/altera_emif_arch_fm_hps_clks_rsts.sv \
      rtl/altera_emif_arch_fm_local_reset.sv \
      rtl/altera_emif_arch_fm_io_tiles_wrap.sv \
      rtl/altera_emif_arch_fm_io_tiles.sv \
      rtl/altera_emif_arch_fm_io_lane_remap.sv \
      rtl/altera_emif_arch_fm_hmc_avl_if.sv \
      rtl/altera_emif_arch_fm_hmc_sideband_if.sv \
      rtl/altera_emif_arch_fm_hmc_mmr_if.sv \
      rtl/altera_emif_arch_fm_hmc_amm_data_if.sv \
      rtl/altera_emif_arch_fm_phylite_if.sv \
      rtl/altera_emif_arch_fm_hmc_ast_data_if.sv \
      rtl/altera_emif_arch_fm_afi_if.sv \
      rtl/altera_emif_arch_fm_seq_if.sv \
      rtl/altera_emif_arch_fm_regs.sv \
      ../../primitives/altera_std_synchronizer/altera_std_synchronizer_nocut.v \
   ]
   return $file_list
}

proc ::altera_emif::ip_arch_fm::main::_generate_abphy_verilog_fileset {top_level} {
   set file_list [list]

   return $file_list
}


proc ::altera_emif::ip_arch_fm::main::_generate_if_ports {arch_legal} {

   set if_ports [dict create]

   ::altera_emif::util::device_family::load_data
   set is_hps [get_is_hps]

   set is_ed_slave [get_parameter_value IS_ED_SLAVE]

   foreach arch_fm_if_enum [enums_of_type ARCH_FM_IF] {
      set if_enum           [enum_data $arch_fm_if_enum IF_ENUM]
      set num_of_ifs_in_rtl [enum_data $arch_fm_if_enum NUM_IN_RTL]
      set num_of_ifs_used   [::altera_emif::ip_arch_fm::protocol_expert::get_num_of_interfaces_used $if_enum]

      dict set if_ports $if_enum [dict create]

      if {$num_of_ifs_used > 0} {
         set ports [::altera_emif::ip_arch_fm::protocol_expert::get_interface_ports $if_enum]
      } else {
         set ports [list]
      }

      ::altera_emif::util::hwtcl_utils::add_unused_interface_ports $if_enum ports

      if {$if_enum == "IF_MEM"} {
         set mem_pins_alloc [::altera_emif::ip_arch_fm::protocol_expert::alloc_mem_pins ports]
      }

      if {$if_enum == "IF_MEM" || $if_enum == "IF_PLL_REF_CLK" || ($if_enum == "IF_OCT" && !$is_ed_slave)} {
         ::altera_emif::ip_arch_fm::protocol_expert::assign_io_settings ports
      }

      dict set if_ports $if_enum PORTS $ports
      dict set if_ports $if_enum INSTS [dict create]

      if {$if_enum == "IF_MEM"} {
         dict set if_ports $if_enum PINS_ALLOC $mem_pins_alloc
      }

      for {set i 0} {$i < $num_of_ifs_in_rtl} {incr i} {
         set if_index [expr {$num_of_ifs_in_rtl == 1} ? -1 : $i]

         if {$if_enum == "IF_CALBUS" || $if_enum == "IF_CALBUS_CLK" }  {
           set if_dir "REVERSE_DIR"
         } else {
           set if_dir "NORMAL_DIR"
         }

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

proc ::altera_emif::ip_arch_fm::main::_derive_protocol_common_parameters {} {

   set_parameter_value IS_HPS [get_is_hps]

   set die_revs [get_device_die_revisions]
   set_parameter_value SILICON_REV [get_wysiwyg_silicon_rev_string]

   set phy_config_enum [get_parameter_value "PHY_CONFIG_ENUM"]
   set ratios [altera_emif::ip_arch_fm::protocol_expert::get_clk_ratios]

   set_parameter_value USER_CLK_RATIO           [dict get $ratios USER]
   set_parameter_value PHY_HMC_CLK_RATIO        [dict get $ratios PHY_HMC]
   set_parameter_value C2P_P2C_CLK_RATIO        [dict get $ratios C2P_P2C]

   set dqs_bus_mode_enum [altera_emif::ip_arch_fm::protocol_expert::get_dqs_bus_mode]
   set_parameter_value DQS_BUS_MODE_ENUM        $dqs_bus_mode_enum

   set ac_pm_scheme [altera_emif::ip_arch_fm::protocol_expert::get_ac_pin_map_scheme]
   set hmc_ifs [altera_emif::ip_arch_fm::protocol_expert::get_num_and_type_of_hmc_ports]
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

   set core_clks_sharing_enum [get_parameter_value PHY_CORE_CLKS_SHARING_ENUM]
   set phy_calibrated_oct     [get_parameter_value PHY_CALIBRATED_OCT]
   set_parameter_value PHY_USERMODE_OCT false

   if {[dict exists $extra_configs FORCE_DLL_CODEWORD]} {
      set codeword [dict get $extra_configs FORCE_DLL_CODEWORD]
      set_parameter_value DLL_MODE     [expr {$codeword < 0 ? "dll_ctl_dynamic" : "dll_ctl_static"}]
      set_parameter_value DLL_CODEWORD [expr {$codeword < 0 ? 0 : $codeword}]
   } else {
      set_parameter_value DLL_MODE "dll_ctl_dynamic"
      set_parameter_value DLL_CODEWORD 0
   }

   if {[dict exists $extra_configs FORCE_CTLE_CAL_OFF]} {
      set_parameter_value HPRX_CTLE_EN "off"
      set_parameter_value HPRX_OFFSET_CAL false
      post_ipgen_w_msg MSG_CTLE_CAL_OFF
   } else {
      set_parameter_value HPRX_CTLE_EN "on"
      set_parameter_value HPRX_OFFSET_CAL true
   }

   if {[check_device_is_reva]} {
      set_parameter_value CPA_FB_MUX_1_SEL      [enum_data CPA_FB0_P_CLK FB_CLK]
   } else {
      set_parameter_value CPA_FB_MUX_1_SEL      [enum_data CPA_LOCAL_P_CLK FB_CLK]
   }

}

proc ::altera_emif::ip_arch_fm::main::get_a_lane_pin_usage_bitvec { port_enum rate_enum } {
      set bitstr [enum_data LANE_PIN_UNUSED BITSTR]
      if {[enum_data $port_enum IS_DM]} {
        set bitstr [enum_data LANE_PIN_DM BITSTR]
      } elseif {[enum_data $port_enum IS_RDATA] || [enum_data $port_enum IS_WDATA] || [enum_data $port_enum IS_DBI]} {
         set bitstr [enum_data LANE_PIN_DQ BITSTR]
      } elseif {[enum_data $port_enum IS_RCLK]} {
        set bitstr [enum_data LANE_PIN_DQS BITSTR]
        if {[enum_data $port_enum IS_NEG_LEG]} {
           set bitstr [enum_data LANE_PIN_DQSB BITSTR]
        }
      } elseif {[enum_data $port_enum IS_WCLK]} {
        set bitstr [enum_data LANE_PIN_CA_DDR BITSTR]
      } elseif {[enum_data $port_enum IS_AC] || [enum_data $port_enum IS_AC_CLK]} {
        set bitstr [enum_data LANE_PIN_CA_SDR BITSTR]
        if {$rate_enum == "PIN_RATE_DDR"} {
           set bitstr [enum_data LANE_PIN_CA_DDR BITSTR]
        }
      } else {
        post_ipgen_w_msg MSG_FM_DEBUG_UNMATCHED_PIN_TYPE_ENUM [list $port_enum $rate_enum]
        puts "Warning: get_a_lane_pin_usage - NOT MATCHED PORT=$port_enum"
      }
      return $bitstr
}

proc ::altera_emif::ip_arch_fm::main::derive_pins_parameters {mem_ports mem_pins_alloc} {
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

   set lane_pin_usage                [string repeat "0000" $pins_in_if]
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

         set bitstr             [get_a_lane_pin_usage_bitvec [dict get $port TYPE_ENUM] [dict get $port RATE_ENUM]]
         set bitstr_len         [string length $bitstr]
         set first              [expr {($pins_in_if - $abs_pin_index - 1) * $bitstr_len}]
         set last               [expr {$first + $bitstr_len - 1}]
         set lane_pin_usage     [string replace $lane_pin_usage $first $last $bitstr]

         set bitstr             [expr {[dict get $port C2L_DRIVEN] ? "1" : "0"}]
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

         set tile_i [dict get $port TILE_INDEX]
         set lane_i [dict get $port LANE_INDEX]
      }
   }

   set_long_bitvec_hdl_param_value PINS_USAGE                     $pins_usage
   set_long_bitvec_hdl_param_value PINS_RATE                      $pins_rate
   set_long_bitvec_hdl_param_value DB_PINS_PROC_MODE              $db_pins_proc_mode
   set_long_bitvec_hdl_param_value LANE_PIN_USAGE                 $lane_pin_usage
   set_long_bitvec_hdl_param_value PINS_DATA_IN_MODE              $pins_data_in_mode
   set_long_bitvec_hdl_param_value PINS_C2L_DRIVEN                $pins_c2l_driven
   set_long_bitvec_hdl_param_value PINS_OCT_MODE                  $pins_oct_mode
   set_long_bitvec_hdl_param_value PINS_DCC_SPLIT                 $pins_dcc_split
}

proc ::altera_emif::ip_arch_fm::main::_set_abphy_wlat_rlat {mem_ports mem_pins_alloc} {
   set ratios [altera_emif::ip_arch_fm::protocol_expert::get_clk_ratios]
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

proc ::altera_emif::ip_arch_fm::main::_derive_logical_resource_usage_parameters {mem_ports mem_pins_alloc} {

   set settings [::altera_emif::ip_arch_fm::protocol_expert::get_lane_cfgs]
   foreach hmc_lane_enum [dict keys $settings] {
      set val [dict get $settings $hmc_lane_enum]
      set_parameter_value $hmc_lane_enum $val
   }

   set ac_tile_i    [get_ac_tile_index $mem_ports]
   set ac_pm_scheme [altera_emif::ip_arch_fm::protocol_expert::get_ac_pin_map_scheme]

   altera_emif::arch_common::main::derive_lanes_parameters              $ac_tile_i $ac_pm_scheme $mem_ports $mem_pins_alloc
   altera_emif::ip_arch_fm::main::derive_pins_parameters                $mem_ports $mem_pins_alloc
   altera_emif::arch_common::main::derive_mem_ports_pinloc_parameters   $mem_ports $mem_pins_alloc
   altera_emif::arch_common::main::derive_unused_pins_pinloc_parameters $mem_ports $mem_pins_alloc

   _derive_pipe_lat_parameters $ac_tile_i $ac_pm_scheme $mem_ports $mem_pins_alloc

   _derive_qdriv_ip_parameters $mem_pins_alloc
}

proc ::altera_emif::ip_arch_fm::main::_derive_qdriv_ip_parameters {mem_pins_alloc} {
   set protocol_enum     [get_parameter_value PROTOCOL_ENUM]
   if {$protocol_enum != "PROTOCOL_QDR4"} {
       return
   }

   set num_of_rtl_tiles  [dict size $mem_pins_alloc]
   if {$num_of_rtl_tiles == 2} {
       set_parameter_value PRI_RDATA_TILE_INDEX 0
       set_parameter_value PRI_RDATA_LANE_INDEX 0

       set_parameter_value SEC_RDATA_TILE_INDEX 0
       set_parameter_value SEC_RDATA_LANE_INDEX 2
   } else {
       set_parameter_value PRI_RDATA_TILE_INDEX 0
       set_parameter_value PRI_RDATA_LANE_INDEX 0

       set_parameter_value SEC_RDATA_TILE_INDEX 2
       set_parameter_value SEC_RDATA_LANE_INDEX 0
   }
}

proc ::altera_emif::ip_arch_fm::main::_derive_tid_parameters {mem_ports mem_pins_alloc} {

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
         set lane_tid_binstr [num2bin [::altera_emif::ip_arch_fm::util::get_lane_tid $tile_i $lane_i] 9]
         set lane_tids       [string replace $lane_tids $first $last $lane_tid_binstr]
      }

      set first             [expr {($num_of_rtl_tiles - $tile_i - 1) * 9}]
      set last              [expr {$first + 8}]

      set center_tid_binstr [num2bin [::altera_emif::ip_arch_fm::util::get_center_tid $tile_i] 9]
      set center_tids       [string replace $center_tids $first $last $center_tid_binstr]

      set hmc_tid_binstr    [num2bin [::altera_emif::ip_arch_fm::util::get_hmc_tid $tile_i] 9]
      set hmc_tids          [string replace $hmc_tids $first $last $hmc_tid_binstr]
   }

   set_long_bitvec_hdl_param_value CENTER_TIDS $center_tids
   set_long_bitvec_hdl_param_value HMC_TIDS    $hmc_tids
   set_long_bitvec_hdl_param_value LANE_TIDS   $lane_tids
}

proc ::altera_emif::ip_arch_fm::main::_derive_pipe_lat_parameters {ac_tile_index ac_pm_scheme mem_ports mem_pins_alloc} {

   set protocol_enum     [get_parameter_value "PROTOCOL_ENUM"]
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
   set ctl2dbc_io_pipeline_lat   1
   set ctl2dbc_io_pipeline_en    "disable"



   if { $protocol_enum == "PROTOCOL_DDR4" } {
      if {$max_distance_from_ac_tile == 0} {
         set max_distance_from_ac_tile 1
      }


      if {$phy_config_enum == "CONFIG_PHY_AND_HARD_CTRL"} {
         set extra_configs_str    [get_parameter_value "DIAG_EXTRA_CONFIGS"]
         set extra_configs        [parse_extra_configs $extra_configs_str]
         set force_io_pipeline_en [extra_config_is_explicit_on $extra_configs FORCE_CTL2DBC_IO_PIPELINE_EN]

         set ratios [altera_emif::ip_arch_fm::protocol_expert::get_clk_ratios]
         set hmc_fmax_lookup   [get_family_trait FAMILY_TRAIT_HMC_FMAX_MHZ]
         set hmc_fmax_mhz      [dict get $hmc_fmax_lookup [get_speedgrade]]
         set mem_clk_freq_mhz  [get_parameter_value PHY_MEM_CLK_FREQ_MHZ]
         set phy_hmc_clk_ratio [dict get $ratios PHY_HMC]
         set hmc_freq_mhz      [expr {$mem_clk_freq_mhz * 1.0 / $phy_hmc_clk_ratio}]

         if {$hmc_freq_mhz == $hmc_fmax_mhz || $force_io_pipeline_en} {
            set ctl2dbc_io_pipeline_lat 2
            set ctl2dbc_io_pipeline_en  "enable"
         }
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

         set hmc_tile_i [expr {$ping_pong_en && $is_sec_data_group ? $sec_hmc_tile_i : $ac_tile_index}]
         set distance_from_hmc_tile [expr {abs($tile_i - $hmc_tile_i)}]
         set distance_from_ac_tile  [expr {abs($tile_i - $ac_tile_index)}]

         set dbc_pipe_lat [expr {($distance_from_hmc_tile * $ctl2dbc_io_pipeline_lat) + 1}]

         if { $protocol_enum == "PROTOCOL_DDR4" } {
            set db_ptr_pipeline_depth [expr {($max_distance_from_ac_tile - $distance_from_ac_tile) * $ctl2dbc_io_pipeline_lat}]
            if {$is_ac_lane} {
               incr db_ptr_pipeline_depth -1
            }
         } else {
            set db_ptr_pipeline_depth [expr {($max_distance_from_ac_tile - $distance_from_ac_tile) * $ctl2dbc_io_pipeline_lat}]
         }

         if {$phy_config_enum == "CONFIG_PHY_AND_HARD_CTRL"} {
            set db_seq_rd_en_full_pipeline [expr {$max_distance_from_ac_tile * $ctl2dbc_io_pipeline_lat + 1}]
         } else {
            set qdr4_adjustment [expr {$protocol_enum == "PROTOCOL_QDR4" ? 1 : 0}]
            set db_seq_rd_en_full_pipeline [expr {($max_distance_from_ac_tile - $distance_from_ac_tile) * $ctl2dbc_io_pipeline_lat + $qdr4_adjustment}]
         }

         emif_assert {$dbc_pipe_lat >= 0}
         emif_assert {$dbc_pipe_lat <= 7}
         emif_assert {$db_ptr_pipeline_depth >= 0}
         emif_assert {$db_ptr_pipeline_depth <= 9}

         emif_assert {$db_seq_rd_en_full_pipeline >= 0}
         emif_assert {$db_seq_rd_en_full_pipeline <= 10}

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

   set_parameter_value             DBC_EXTRA_PIPE_STAGE_EN     $ctl2dbc_io_pipeline_en
   set_long_bitvec_hdl_param_value DBC_PIPE_LATS               $dbc_pipe_lats
   set_long_bitvec_hdl_param_value DB_PTR_PIPELINE_DEPTHS      $db_ptr_pipeline_depths
   set_long_bitvec_hdl_param_value DB_SEQ_RD_EN_FULL_PIPELINES $db_seq_rd_en_full_pipelines
}

proc ::altera_emif::ip_arch_fm::main::_derive_protocol_specific_hmc_cfg_parameters {} {
   foreach hmc_inst [list "PRI" "SEC"] {
      set settings [::altera_emif::ip_arch_fm::protocol_expert::get_hmc_cfgs $hmc_inst]
      foreach hmc_cfg_enum [dict keys $settings] {
         set val  [dict get $settings $hmc_cfg_enum]
         set name "${hmc_inst}_${hmc_cfg_enum}"
         set_parameter_value $name $val
      }
   }
}

proc ::altera_emif::ip_arch_fm::main::_derive_core_logic_parameters {} {
   set ratios            [altera_emif::ip_arch_fm::protocol_expert::get_clk_ratios]
   set in_rate           [dict get $ratios C2P_P2C]
   set mem_clk_freq_mhz  [get_parameter_value PHY_MEM_CLK_FREQ_MHZ]
   set c2p_p2c_freq_mhz  [expr {$mem_clk_freq_mhz * 1.0 / $in_rate}]
   set extra_configs_str [get_parameter_value "DIAG_EXTRA_CONFIGS"]
   set extra_configs     [parse_extra_configs $extra_configs_str]
   set die_revs          [get_device_die_revisions]

   set_parameter_value ENABLE_RD_TYPE [get_parameter_value DIAG_EXPOSE_RD_TYPE]

   set force_l2_ufi [extra_config_is_explicit_on $extra_configs FORCE_L2_UFI]

   if {[get_is_hps]} {
     set_parameter_value AMM_HIPI_DELAY        [enum_data UFI_C2P_FIFO_OREG_L2 C2P_HIPI_DELAY]
     set_parameter_value MMR_HIPI_DELAY        [enum_data UFI_C2P_FIFO_OREG_L2 C2P_HIPI_DELAY]
     set_parameter_value SIDEBAND_HIPI_DELAY   [enum_data UFI_C2P_FIFO_OREG_L2 C2P_HIPI_DELAY]
     set_parameter_value SEQ_HIPI_DELAY        [enum_data UFI_C2P_FIFO_OREG_L2 C2P_HIPI_DELAY]
     set_parameter_value ECC_HIPI_DELAY        [enum_data UFI_C2P_FIFO_OREG_L2 C2P_HIPI_DELAY]
     set_parameter_value LANE_HIPI_DELAY       [enum_data UFI_C2P_FIFO_OREG_L2 C2P_HIPI_DELAY]

     set_parameter_value AMM_C2P_UFI_MODE      [enum_data UFI_C2P_FIFO_OREG_L2 BITSTR]
     set_parameter_value AMM_P2C_UFI_MODE      [enum_data UFI_P2C_FIFO_OREG_L2 BITSTR]
     set_parameter_value MMR_C2P_UFI_MODE      [enum_data UFI_C2P_FIFO_OREG_L2 BITSTR]
     set_parameter_value MMR_P2C_UFI_MODE      [enum_data UFI_P2C_FIFO_OREG_L2 BITSTR]
     set_parameter_value SIDEBAND_C2P_UFI_MODE [enum_data UFI_C2P_FIFO_OREG_L2 BITSTR]
     set_parameter_value SIDEBAND_P2C_UFI_MODE [enum_data UFI_P2C_FIFO_OREG_L2 BITSTR]
     set_parameter_value SEQ_C2P_UFI_MODE      [enum_data UFI_C2P_FIFO_OREG_L2 BITSTR]
     set_parameter_value SEQ_P2C_UFI_MODE      [enum_data UFI_P2C_FIFO_OREG_L2 BITSTR]
     set_parameter_value ECC_C2P_UFI_MODE      [enum_data UFI_C2P_FIFO_OREG_L2 BITSTR]
     set_parameter_value ECC_P2C_UFI_MODE      [enum_data UFI_P2C_FIFO_OREG_L2 BITSTR]
     set_parameter_value LANE_C2P_UFI_MODE     [enum_data UFI_C2P_FIFO_OREG_L2 BITSTR]
     set_parameter_value LANE_P2C_UFI_MODE     [enum_data UFI_P2C_FIFO_OREG_L2 BITSTR]

   } else {
     set_parameter_value AMM_HIPI_DELAY         [enum_data UFI_IN_OUT_DIRECT_L0 C2P_HIPI_DELAY]
     set_parameter_value MMR_HIPI_DELAY         [enum_data UFI_IN_OUT_DIRECT_L0 C2P_HIPI_DELAY]
     set_parameter_value SIDEBAND_HIPI_DELAY    [enum_data UFI_IN_OUT_DIRECT_L0 C2P_HIPI_DELAY]
     set_parameter_value SEQ_HIPI_DELAY         [enum_data UFI_IN_OUT_DIRECT_L0 C2P_HIPI_DELAY]
     set_parameter_value ECC_HIPI_DELAY         [enum_data UFI_IN_OUT_DIRECT_L0 C2P_HIPI_DELAY]
     set_parameter_value LANE_HIPI_DELAY        [enum_data UFI_IN_OUT_DIRECT_L0 C2P_HIPI_DELAY]

     set_parameter_value AMM_C2P_UFI_MODE       [enum_data UFI_IN_OUT_DIRECT_L0 BITSTR]
     set_parameter_value AMM_P2C_UFI_MODE       [enum_data UFI_IN_OUT_DIRECT_L0 BITSTR]
     set_parameter_value MMR_C2P_UFI_MODE       [enum_data UFI_IN_OUT_DIRECT_L0 BITSTR]
     set_parameter_value MMR_P2C_UFI_MODE       [enum_data UFI_IN_OUT_DIRECT_L0 BITSTR]
     set_parameter_value SIDEBAND_C2P_UFI_MODE  [enum_data UFI_IN_OUT_DIRECT_L0 BITSTR]
     set_parameter_value SIDEBAND_P2C_UFI_MODE  [enum_data UFI_IN_OUT_DIRECT_L0 BITSTR]
     set_parameter_value SEQ_C2P_UFI_MODE       [enum_data UFI_IN_OUT_DIRECT_L0 BITSTR]
     set_parameter_value SEQ_P2C_UFI_MODE       [enum_data UFI_IN_OUT_DIRECT_L0 BITSTR]
     set_parameter_value ECC_C2P_UFI_MODE       [enum_data UFI_IN_OUT_DIRECT_L0 BITSTR]
     set_parameter_value ECC_P2C_UFI_MODE       [enum_data UFI_IN_OUT_DIRECT_L0 BITSTR]
     set_parameter_value LANE_C2P_UFI_MODE      [enum_data UFI_IN_OUT_DIRECT_L0 BITSTR]
     set_parameter_value LANE_P2C_UFI_MODE      [enum_data UFI_IN_OUT_DIRECT_L0 BITSTR]

     if { [check_device_is_reva] } {
       set_parameter_value AMM_HIPI_DELAY        [enum_data UFI_C2P_FIFO_OREG_L2 C2P_HIPI_DELAY]
       set_parameter_value SIDEBAND_HIPI_DELAY   [enum_data UFI_C2P_FIFO_OREG_L2 C2P_HIPI_DELAY]
       set_parameter_value SEQ_HIPI_DELAY        [enum_data UFI_C2P_FIFO_OREG_L2 C2P_HIPI_DELAY]
       set_parameter_value ECC_HIPI_DELAY        [enum_data UFI_C2P_FIFO_OREG_L2 C2P_HIPI_DELAY]
       set_parameter_value LANE_HIPI_DELAY       [enum_data UFI_C2P_FIFO_OREG_L2 C2P_HIPI_DELAY]

       set_parameter_value SEQ_C2P_UFI_MODE      [enum_data UFI_C2P_FIFO_OREG_L2 BITSTR]
       set_parameter_value SEQ_P2C_UFI_MODE      [enum_data UFI_P2C_FIFO_OREG_L2 BITSTR]
       set_parameter_value LANE_C2P_UFI_MODE     [enum_data UFI_C2P_FIFO_OREG_L2 BITSTR]
       set_parameter_value LANE_P2C_UFI_MODE     [enum_data UFI_P2C_FIFO_OREG_L2 BITSTR]

       if { [get_parameter_value "PHY_CONFIG_ENUM"] ==  "CONFIG_PHY_AND_HARD_CTRL"} {
          set_parameter_value AMM_C2P_UFI_MODE      [enum_data UFI_C2P_FIFO_OREG_L2 BITSTR]
          set_parameter_value AMM_P2C_UFI_MODE      [enum_data UFI_P2C_FIFO_OREG_L2 BITSTR]
       }
       if { [get_parameter_value "CTRL_ECC_EN"] } {
          set_parameter_value ECC_C2P_UFI_MODE      [enum_data UFI_C2P_FIFO_OREG_L2 BITSTR]
          set_parameter_value ECC_P2C_UFI_MODE      [enum_data UFI_P2C_FIFO_OREG_L2 BITSTR]
       }
     } elseif { $force_l2_ufi || [expr $in_rate == 2 && $c2p_p2c_freq_mhz >= 400.0] } {

       set_parameter_value AMM_HIPI_DELAY        [enum_data UFI_C2P_FIFO_OREG_L2 C2P_HIPI_DELAY]
       set_parameter_value MMR_HIPI_DELAY        [enum_data UFI_C2P_FIFO_OREG_L2 C2P_HIPI_DELAY]
       set_parameter_value SIDEBAND_HIPI_DELAY   [enum_data UFI_C2P_FIFO_OREG_L2 C2P_HIPI_DELAY]
       set_parameter_value SEQ_HIPI_DELAY        [enum_data UFI_C2P_FIFO_OREG_L2 C2P_HIPI_DELAY]
       set_parameter_value ECC_HIPI_DELAY        [enum_data UFI_C2P_FIFO_OREG_L2 C2P_HIPI_DELAY]
       set_parameter_value LANE_HIPI_DELAY       [enum_data UFI_C2P_FIFO_OREG_L2 C2P_HIPI_DELAY]

       set_parameter_value AMM_C2P_UFI_MODE      [enum_data UFI_C2P_FIFO_OREG_L2 BITSTR]
       set_parameter_value AMM_P2C_UFI_MODE      [enum_data UFI_P2C_FIFO_OREG_L2 BITSTR]
       set_parameter_value MMR_C2P_UFI_MODE      [enum_data UFI_C2P_FIFO_OREG_L2 BITSTR]
       set_parameter_value MMR_P2C_UFI_MODE      [enum_data UFI_P2C_FIFO_OREG_L2 BITSTR]
       set_parameter_value SIDEBAND_C2P_UFI_MODE [enum_data UFI_C2P_FIFO_OREG_L2 BITSTR]
       set_parameter_value SIDEBAND_P2C_UFI_MODE [enum_data UFI_P2C_FIFO_OREG_L2 BITSTR]
       set_parameter_value SEQ_C2P_UFI_MODE      [enum_data UFI_C2P_FIFO_OREG_L2 BITSTR]
       set_parameter_value SEQ_P2C_UFI_MODE      [enum_data UFI_P2C_FIFO_OREG_L2 BITSTR]
       set_parameter_value ECC_C2P_UFI_MODE      [enum_data UFI_C2P_FIFO_OREG_L2 BITSTR]
       set_parameter_value ECC_P2C_UFI_MODE      [enum_data UFI_P2C_FIFO_OREG_L2 BITSTR]
       set_parameter_value LANE_C2P_UFI_MODE     [enum_data UFI_C2P_FIFO_OREG_L2 BITSTR]
       set_parameter_value LANE_P2C_UFI_MODE     [enum_data UFI_P2C_FIFO_OREG_L2 BITSTR]
     }
   }

   if {[dict exists $extra_configs "FORCE_UFI_HIPI_DELAY"]} {
      set hipi_delay [dict get $extra_configs "FORCE_UFI_HIPI_DELAY"]
      emif_assert {$hipi_delay == 225 || $hipi_delay == 350 || $hipi_delay == 100}
      set_parameter_value AMM_HIPI_DELAY        $hipi_delay
      set_parameter_value MMR_HIPI_DELAY        $hipi_delay
      set_parameter_value SIDEBAND_HIPI_DELAY   $hipi_delay
      set_parameter_value SEQ_HIPI_DELAY        $hipi_delay
      set_parameter_value ECC_HIPI_DELAY        $hipi_delay
      set_parameter_value LANE_HIPI_DELAY       $hipi_delay
   }

   if {[get_is_hps]} {
      set_parameter_value REGISTER_AFI_C2P 0
      set_parameter_value REGISTER_AFI_P2C 0
      set_parameter_value REGISTER_AMM_P2C 0
   } else {
      set extra_configs_str [get_parameter_value "DIAG_EXTRA_CONFIGS"]
      set extra_configs     [parse_extra_configs $extra_configs_str]
      set die_revs          [get_device_die_revisions]
      set ratios            [altera_emif::ip_arch_fm::protocol_expert::get_clk_ratios]
      set mem_clk_freq_mhz  [get_parameter_value PHY_MEM_CLK_FREQ_MHZ]
      set c2p_p2c_freq_mhz  [expr {$mem_clk_freq_mhz * 1.0 / [dict get $ratios C2P_P2C]}]
      set hmc_ifs           [altera_emif::ip_arch_fm::protocol_expert::get_num_and_type_of_hmc_ports]

      set_parameter_value REGISTER_AFI_C2P 1

      set_parameter_value REGISTER_AFI_P2C 1

      set_parameter_value REGISTER_AMM_P2C 1

      if {[get_parameter_value "DIAG_ADD_READY_PIPELINE"] && [dict get $hmc_ifs CTRL_AVL_PROTOCOL_ENUM]=="CTRL_AVL_PROTOCOL_MM"} {
          set_parameter_value REGISTER_AMM_P2C 2
      }

      set_parameter_value REGISTER_AMM_C2P 1
  }
}

proc ::altera_emif::ip_arch_fm::main::_set_interface_properties {if_ports} {
   set phy_config_enum        [get_parameter_value "PHY_CONFIG_ENUM"]
   set ping_pong_en           [get_parameter_value "PHY_PING_PONG_EN"]
   set core_clks_sharing_enum [get_parameter_value PHY_CORE_CLKS_SHARING_ENUM]

   set calbus_clk_name   [dict get $if_ports IF_CALBUS_CLK INSTS -1 NAME]
   foreach if_index [dict keys [dict get $if_ports IF_CALBUS INSTS]] {
      set if_name [dict get $if_ports IF_CALBUS INSTS $if_index NAME]
      set_interface_property $if_name associatedClock $calbus_clk_name
   }

   set_interface_property [dict get $if_ports IF_CTRL_MMR_SLAVE INSTS 0 NAME] IPXACT_REGISTER_MAP "fm_mmr.ipxact"

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

      set amm_if_props [::altera_emif::ip_arch_fm::protocol_expert::get_interface_properties IF_CTRL_AMM]
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

      set ast_cmd_if_props [::altera_emif::ip_arch_fm::protocol_expert::get_interface_properties IF_CTRL_AST_CMD]
      set ast_rd_if_props  [::altera_emif::ip_arch_fm::protocol_expert::get_interface_properties IF_CTRL_AST_RD]
      set ast_wr_if_props  [::altera_emif::ip_arch_fm::protocol_expert::get_interface_properties IF_CTRL_AST_WR]

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
}

proc ::altera_emif::ip_arch_fm::main::_get_is_interface_disabled_in_hps_mode {if_enum} {
   switch $if_enum {
      IF_PLL_REF_CLK -
      IF_MEM -
      IF_HPS_EMIF -
      IF_OCT -
      IF_CALBUS_CLK -
      IF_CALBUS {
         return false
      }
      default {
         return true
      }
   }
}

proc ::altera_emif::ip_arch_fm::main::_get_number_of_unique_calibrated_oct_values {} {
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

proc ::altera_emif::ip_arch_fm::main::_validate {} {
   set retval 1

   set mimic_hps_emif            [get_parameter_value "PHY_MIMIC_HPS_EMIF"]
   set internal_testing_mode     [get_parameter_value "INTERNAL_TESTING_MODE"]
   set rate                      [get_parameter_value PHY_RATE_ENUM]

   if {[get_is_hps] || ($mimic_hps_emif && !$internal_testing_mode)} {
      if {![::altera_emif::ip_arch_fm::hps::check_hps_compatibility]} {
         set retval 0
      }
   }

   if {![ini_is_on "emif_show_internal_settings"] && !$internal_testing_mode && ![get_is_production] && ($rate == "RATE_HALF")} {
      post_ipgen_e_msg MSG_FM_NO_HALF_RATE_SUPPORT
      set retval 0
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
      if {![altera_emif::ip_arch_fm::protocol_expert::check_hmc_legality]} {
         set retval 0
      }
   } else {
     if { [check_device_is_reva] && $protocol_enum == "PROTOCOL_DDR4" } {
        post_ipgen_e_msg MSG_NO_PHY_ONLY_SUPPORT
     }
   }

   if {[check_device_is_reva]} {
      foreach param_prefix [list PHY_DDR4] {
          if { [get_parameter_value ${param_prefix}_DATA_IO_STD_ENUM]== "IO_STD_POD_12" &&  \
               [get_parameter_value ${param_prefix}_USER_DATA_IN_MODE_ENUM] == "IN_OCT_50_CAL" } {
            post_ipgen_e_msg MSG_DATA_IN_POD_50_OHM_REVA
            set retval 0
         }
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
      set num_unique_cal_oct_vals [::altera_emif::ip_arch_fm::main::_get_number_of_unique_calibrated_oct_values]
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

   if {$protocol_enum == "PROTOCOL_QDR4"} {
      set ac_odt_mode   [get_parameter_value "MEM_QDR4_AC_ODT_MODE_ENUM"] 
      set ck_odt_mode   [get_parameter_value "MEM_QDR4_CK_ODT_MODE_ENUM"] 
      set data_odt_mode [get_parameter_value "MEM_QDR4_DATA_ODT_MODE_ENUM"]
      set pu_outdr_mode [get_parameter_value "MEM_QDR4_PU_OUTPUT_DRIVE_MODE_ENUM"]
      set pd_outdr_mode [get_parameter_value "MEM_QDR4_PD_OUTPUT_DRIVE_MODE_ENUM"]
  
      if {![enum_data $ac_odt_mode AC_VALID_AT_POD]} {
         post_ipgen_w_msg MSG_QDRIV_UNSUPPORTED_ODT [list "AC" [enum_data $ac_odt_mode UI_NAME]]
         set retval 0
      }
 
      if {![enum_data $ck_odt_mode CK_VALID_AT_POD]} {
         post_ipgen_w_msg MSG_QDRIV_UNSUPPORTED_ODT [list "CK" [enum_data $ck_odt_mode UI_NAME]]
         set retval 0
      }
 
      if {![enum_data $data_odt_mode DATA_VALID_AT_POD]} {
         post_ipgen_w_msg MSG_QDRIV_UNSUPPORTED_ODT [list "DATA" [enum_data $data_odt_mode UI_NAME]]
         set retval 0
      }

      if {!([enum_data $pu_outdr_mode VALID_AT_POD_180] && [enum_data $pu_outdr_mode VALID_AT_POD_220])} {
         post_ipgen_w_msg MSG_QDRIV_UNSUPPORTED_OUTPUT_DRIVE [list "pull-up" [enum_data $pu_outdr_mode UI_NAME]]
         set retval 0
      }

      if {!([enum_data $pd_outdr_mode VALID_AT_POD_180] && [enum_data $pd_outdr_mode VALID_AT_POD_220])} {
         post_ipgen_w_msg MSG_QDRIV_UNSUPPORTED_OUTPUT_DRIVE [list "pull-down" [enum_data $pd_outdr_mode UI_NAME]]
         set retval 0
      }


      if {![get_is_production]} {
        post_ipgen_w_msg MSG_FM_QDR4_NO_HW_SUPPORT
        set retval 0
      }

   }

   return $retval
}

proc ::altera_emif::ip_arch_fm::main::_init {} {
}

::altera_emif::ip_arch_fm::main::_init

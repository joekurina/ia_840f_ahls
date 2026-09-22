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


package provide altera_emif::ip_arch_nf::seq_param_tbl 0.1

package require altera_emif::util::messaging
package require altera_emif::util::math
package require altera_emif::util::qini
package require altera_emif::util::hwtcl_utils
package require altera_emif::util::enums
package require altera_emif::util::enum_defs
package require altera_emif::util::enum_defs_interfaces
package require altera_emif::util::enum_defs_family_traits_and_features
package require altera_emif::util::device_family

package require altera_emif::arch_common::seq_param_tbl

package require altera_emif::ip_arch_nf::enum_defs
package require altera_emif::ip_arch_nf::enum_defs_seq_param_tbl
package require altera_emif::ip_arch_nf::protocol_expert
package require altera_emif::ip_arch_nf::util


namespace eval ::altera_emif::ip_arch_nf::seq_param_tbl:: {

   namespace import ::altera_emif::util::messaging::*
   namespace import ::altera_emif::util::math::*
   namespace import ::altera_emif::util::qini::*
   namespace import ::altera_emif::util::enums::*
   namespace import ::altera_emif::util::hwtcl_utils::*
   namespace import ::altera_emif::util::device_family::*
   namespace import ::altera_emif::ip_arch_nf::util::*
   namespace import ::altera_emif::ip_arch_nf::protocol_expert::*


}


proc ::altera_emif::ip_arch_nf::seq_param_tbl::derive_contents {mem_ports mem_pins_alloc} {


   set glob_param_tbl_byte_size [enum_data SEQ_CONST_GLOBAL_PAR_SIZE VALUE]
   set param_tbl_byte_size      [enum_data SEQ_CONST_INTERFACE_PAR_SIZE VALUE]

   set param_tbl_addr           $glob_param_tbl_byte_size
   set extra_data_addr          [expr {$param_tbl_addr + $param_tbl_byte_size}]

   set seq_glob_param_tbl       [_derive_seq_glob_param_tbl $param_tbl_addr]

   set seq_param_tbl            [_derive_seq_param_tbl $extra_data_addr $mem_ports $mem_pins_alloc]

   set extra_data_byte_size     [altera_emif::arch_common::seq_param_tbl::cal_extra_data_byte_size $seq_glob_param_tbl $seq_param_tbl]
   set everything_byte_size     [expr {$glob_param_tbl_byte_size + $param_tbl_byte_size + $extra_data_byte_size}]
   dict set seq_glob_param_tbl SEQ_GPT_PARAM_TABLE_SIZE $everything_byte_size


   set retval [dict create]
   dict set retval SEQ_GPT $seq_glob_param_tbl
   dict set retval SEQ_PT $seq_param_tbl
   return $retval
}

proc ::altera_emif::ip_arch_nf::seq_param_tbl::set_skip_cal {contents_varname skip_cal_on} {

   upvar 1 $contents_varname contents

   set cal_config_val [dict get $contents SEQ_PT SEQ_PT_CAL_CONFIG]
   set skip_cal_val   [enum_data SEQ_CONST_CAL_PERFORM_SKIP_CAL_CONFIG VALUE]

   if {$skip_cal_on} {
      set cal_config_val [expr {$cal_config_val | $skip_cal_val}]
   } else {
      set cal_config_val [expr {$cal_config_val & ~$skip_cal_val}]
   }
   dict set contents SEQ_PT SEQ_PT_CAL_CONFIG $cal_config_val
}

proc ::altera_emif::ip_arch_nf::seq_param_tbl::set_sim_opts {contents_varname} {

   upvar 1 $contents_varname contents

   set skip_steps_val   [dict get $contents SEQ_PT SEQ_PT_DBG_SKIP_STEPS]
   set skip_delay_val   [enum_data SEQ_CONST_CALIB_SKIP_DELAY_LOOPS VALUE]
   set fast_step_val    [enum_data SEQ_CONST_CALIB_FAST_DELAY_STEPPING VALUE]

   set skip_failed_val  [enum_data SEQ_CONST_CALIB_SKIP_FAILED_STEPS VALUE]

   set skip_vref_val    [expr {[enum_data SEQ_CONST_CALIB_SKIP_VREFIN_CAL VALUE] | [enum_data SEQ_CONST_CALIB_SKIP_VREFOUT_CAL VALUE]}]

   set skip_dcd_cal_val [enum_data SEQ_CONST_CALIB_SKIP_DCD_CAL VALUE]

   set skip_steps_val [expr {$skip_steps_val | $skip_failed_val}]
   set skip_steps_val [expr {$skip_steps_val | $skip_delay_val}]
   set skip_steps_val [expr {$skip_steps_val | $fast_step_val}]
   set skip_steps_val [expr {$skip_steps_val | $skip_vref_val}]
   set skip_steps_val [expr {$skip_steps_val | $skip_dcd_cal_val}]

   dict set contents SEQ_PT SEQ_PT_DBG_SKIP_STEPS $skip_steps_val

   set cal_config    [dict get $contents SEQ_PT SEQ_PT_CAL_CONFIG]
   set cal_config    [expr {$cal_config | [enum_data SEQ_CONST_CAL_FAST_SIM VALUE]}]

   dict set contents SEQ_PT SEQ_PT_CAL_CONFIG $cal_config

}

proc ::altera_emif::ip_arch_nf::seq_param_tbl::set_max_nios_freq {contents_varname is_sim} {
   upvar 1 $contents_varname contents
   if {$is_sim} {
      set val [expr {1000 * [get_parameter_value SEQ_SIM_OSC_FREQ_MHZ]}]
      dict set contents SEQ_GPT SEQ_GPT_NIOS_CLK_FREQ_KHZ $val
   } else {
      set val [expr {1000 * [enum_data IOAUX_NIOS_HW_FREQ_MHZ_MAX VALUE]}]
      dict set contents SEQ_GPT SEQ_GPT_NIOS_CLK_FREQ_KHZ $val
   }
}

proc ::altera_emif::ip_arch_nf::seq_param_tbl::set_extra_configs_overrides {contents_varname is_sim} {

   upvar 1 $contents_varname contents

   set extra_configs_str [get_parameter_value "DIAG_EXTRA_CONFIGS"]
   set extra_configs [parse_extra_configs $extra_configs_str]

   if {[dict exists $extra_configs SEQ_DBG_SKIP_STEPS_ADD]} {
      set orig [dict get $contents SEQ_PT SEQ_PT_DBG_SKIP_STEPS]
      set curr [expr {$orig | [dict get $extra_configs SEQ_DBG_SKIP_STEPS_ADD]}]
      dict set contents SEQ_PT SEQ_PT_DBG_SKIP_STEPS $curr
   }
   
   if {[dict exists $extra_configs SEQ_DBG_SKIP_STEPS_REMOVE]} {
      set orig [dict get $contents SEQ_PT SEQ_PT_DBG_SKIP_STEPS]
      set curr [expr {$orig & ~[dict get $extra_configs SEQ_DBG_SKIP_STEPS_REMOVE]}]
      dict set contents SEQ_PT SEQ_PT_DBG_SKIP_STEPS $curr
   }

   set skip_dcd_cal_val [enum_data SEQ_CONST_CALIB_SKIP_DCD_CAL VALUE]
   if {[extra_config_is_explicit_on $extra_configs FORCE_DCD_CAL_ON]} {
      set orig [dict get $contents SEQ_PT SEQ_PT_DBG_SKIP_STEPS]
      set curr [expr {$orig & ~($skip_dcd_cal_val)}]
      dict set contents SEQ_PT SEQ_PT_DBG_SKIP_STEPS $curr
   } elseif {[extra_config_is_explicit_on $extra_configs FORCE_DCD_CAL_OFF]} {
      set orig [dict get $contents SEQ_PT SEQ_PT_DBG_SKIP_STEPS]
      set curr [expr {$orig | $skip_dcd_cal_val}]
      dict set contents SEQ_PT SEQ_PT_DBG_SKIP_STEPS $curr
   } else {
      set orig [dict get $contents SEQ_PT SEQ_PT_DBG_SKIP_STEPS]
      set curr [expr {$orig | $skip_dcd_cal_val}]
      dict set contents SEQ_PT SEQ_PT_DBG_SKIP_STEPS $curr
   }
}

proc ::altera_emif::ip_arch_nf::seq_param_tbl::generate_sim_files {top_level contents} {
   set sim_params_filename [::altera_emif::ip_arch_nf::util::get_sim_params_hex_filename $top_level]
   return [altera_emif::arch_common::seq_param_tbl::generate_files $sim_params_filename $contents]
}

proc ::altera_emif::ip_arch_nf::seq_param_tbl::generate_synth_files {top_level contents} {
   set synth_params_filename [::altera_emif::ip_arch_nf::util::get_synth_params_hex_filename $top_level]
   return [altera_emif::arch_common::seq_param_tbl::generate_files $synth_params_filename $contents]
}

proc ::altera_emif::ip_arch_nf::seq_param_tbl::get_cal_data_common_section {} {

   set cal_data [list]


   set val [dict create]
   dict set val PTR                0
   dict set val CONTENT            $cal_data
   dict set val ITEM_BYTE_SIZE     4
   dict set val BYTE_SIZE          [expr {4 * [llength $cal_data]}]

   return $val
}


proc ::altera_emif::ip_arch_nf::seq_param_tbl::_derive_seq_glob_param_tbl {param_tbl_addr} {

   set seq_glob_param_tbl [dict create]

   foreach seq_gpt_enum [enums_of_type SEQ_GPT] {
      switch $seq_gpt_enum {
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
            set val 0
         }
         SEQ_GPT_PARAM_TABLE_SIZE {
            set val 0
         }
         SEQ_GPT_INTERFACE_PAR_PTRS {
            set user_specified_interface_id [get_parameter_value DIAG_INTERFACE_ID]
            set max_allowed_interface_id_nf [enum_data SEQ_CONST_MAX_NUM_MEM_INTERFACES VALUE]
            emif_assert {$user_specified_interface_id < $max_allowed_interface_id_nf}
            set val [list [expr {($user_specified_interface_id << 16) | ($param_tbl_addr & 0x0000FFFF)}]]
            for {set i 1} {$i < $max_allowed_interface_id_nf} {incr i} {
               lappend val 0
            }
         }
         default {
            emif_ie "Unknown sequencer parameter table field $seq_gpt_enum"
         }
      }
      dict set seq_glob_param_tbl $seq_gpt_enum $val
   }
   return $seq_glob_param_tbl
}

proc ::altera_emif::ip_arch_nf::seq_param_tbl::_derive_seq_param_tbl {extra_data_addr mem_ports mem_pins_alloc} {

   set seq_param_tbl [dict create]

   set protocol_enum     [get_parameter_value PROTOCOL_ENUM]
   set ping_pong_en      [get_parameter_value PHY_PING_PONG_EN]
   set clamshell_en      [get_parameter_value PHY_CLAMSHELL_EN]
   set ac_tile_i         [get_ac_tile_index $mem_ports]
   set mem_clk_freq_mhz  [get_parameter_value PHY_MEM_CLK_FREQ_MHZ]

   set resources         [::altera_emif::ip_arch_nf::protocol_expert::get_resource_consumption]
   set ac_pin_map_enum   [dict get $resources AC_PM_ENUM]
   set num_of_ac_lanes   [dict get $resources NUM_AC_LANES]

   set ac_lanes [list]
   for {set lane_i 0} {$lane_i < $num_of_ac_lanes} {incr lane_i} {
      lappend ac_lanes [list $ac_tile_i $lane_i]
   }

   set data_lanes [list]
   foreach tile_i [dict keys $mem_pins_alloc] {
      set tile_dict [dict get $mem_pins_alloc $tile_i]
      foreach lane_i [dict keys $tile_dict] {
         if {$tile_i != $ac_tile_i || $lane_i >= $num_of_ac_lanes} {
            lappend data_lanes [list $tile_i $lane_i]
         }
      }
   }

   set protocol_seq_params [list]

   foreach seq_pt_enum [enums_of_type SEQ_PT] {
      set is_protocol_specific 0

      switch $seq_pt_enum {
         SEQ_PT_IP_VER {
            set val [altera_emif::arch_common::seq_param_tbl::get_acds_version_num "19.1"]
         }
         SEQ_PT_INTERFACE_PAR_VER {
            set val [enum_data SEQ_CONST_CURR_INTERFACE_PAR_VER VALUE]
         }
         SEQ_PT_DEBUG_DATA_PTR -
         SEQ_PT_USER_COMMAND_PTR {
            set val [dict create]
            dict set val PTR            0
            dict set val CONTENT        [list]
            dict set val ITEM_BYTE_SIZE 0
            dict set val BYTE_SIZE      0
         }
         SEQ_PT_MEMORY_TYPE {
            set val [altera_emif::arch_common::seq_param_tbl::get_memory_type $protocol_enum]
         }
         SEQ_PT_DIMM_TYPE {
            set val [altera_emif::arch_common::seq_param_tbl::get_dimm_type [get_parameter_value MEM_FORMAT_ENUM] $ping_pong_en $clamshell_en]
         }
         SEQ_PT_CONTROLLER_TYPE {
            set hmc_ifs       [::altera_emif::ip_arch_nf::protocol_expert::get_num_and_type_of_hmc_ports]
            set num_hmc_ports [dict get $hmc_ifs NUM_OF_PORTS]
            set enum          [expr {($num_hmc_ports > 0) ? "SEQ_CONST_CONTROLLER_HARD" : "SEQ_CONST_CONTROLLER_SOFT"}]
            set val           [enum_data $enum VALUE]
         }
         SEQ_PT_BURST_LEN {
            set val [get_parameter_value MEM_BURST_LENGTH]
         }
         SEQ_PT_RESERVED -
         SEQ_PT_RESERVED_1 {
            set val 0
         }
         SEQ_PT_AFI_CLK_FREQ_KHZ {
            set clk_ratios        [altera_emif::ip_arch_nf::protocol_expert::get_clk_ratios]
            set phy_hmc_clk_ratio [dict get $clk_ratios PHY_HMC]
            set afi_clk_freq_mhz  [expr {$mem_clk_freq_mhz * 1.0 / $phy_hmc_clk_ratio}]
            set val               [expr {round($afi_clk_freq_mhz * 1000)}]
         }
         SEQ_PT_CAL_CONFIG {
            set val [expr { [enum_data SEQ_CONST_CAL_ENABLE_POWERUP_CAL VALUE] | \
                            [enum_data SEQ_CONST_CAL_ENABLE_DYNAMIC_FULL_RECAL VALUE] | \
                            [enum_data SEQ_CONST_CAL_POST_CAL_DESKEW VALUE] }]
            
            if {$protocol_enum != "PROTOCOL_QDR2" && ![get_parameter_value DIAG_DDR3_CAL_ENABLE_MICRON_AP]} {
               set val [expr {$val | [enum_data SEQ_CONST_CAL_USE_STRESS_PATTERN VALUE]}]
            }

            if {([get_is_es] && ([get_die_string] == "20nm5")) || ($mem_clk_freq_mhz < 800)} {
               set val [expr {$val | [enum_data SEQ_CONST_CAL_MULTIRANK_DELAY_AVERAGING VALUE]}]
            }
            
            if {[::altera_emif::ip_arch_nf::protocol_expert::is_phy_shadow_register_disabled]} {
                set val [expr {$val | [enum_data SEQ_CONST_CAL_MULTIRANK_DELAY_AVERAGING VALUE] }]
            }

            if {[get_parameter_value PHY_DLL_CORE_UPDN_EN]} {
               set val [expr {$val | [enum_data SEQ_CONST_CAL_ENABLE_PHY_DLL_CORE_UPDN VALUE]}]
            }

            if {[get_parameter_value PHY_USERMODE_OCT]} {
               set val [expr {$val | [enum_data SEQ_CONST_CAL_USERMODE_OCT VALUE]}]
            }

            if {[get_parameter_value PHY_PERIODIC_OCT_RECAL]} {
               set val [expr {$val | [enum_data SEQ_CONST_CAL_PERIODIC_OCT_RECAL VALUE]}]
            }

            if {[get_is_hps]} {
               set val [expr {$val | [enum_data SEQ_CONST_CAL_IS_HPS_EMIF]}]

               set val [expr {$val | [enum_data SEQ_CONST_CAL_WARM_RESET_ENABLE]}]
            }
	    
            if {$protocol_enum == "PROTOCOL_DDR3" && [get_parameter_value DIAG_DDR3_CAL_ENABLE_MICRON_AP]} {
               set val [expr {$val | [enum_data SEQ_CONST_CAL_ENABLE_MICRON_AP VALUE]}]
            }
	    
            if {$protocol_enum == "PROTOCOL_DDR3"} {
               if {[get_parameter_value DIAG_DDR3_CAL_ENABLE_NON_DES]} {
                  set val [expr {$val | [enum_data SEQ_CONST_CAL_ENABLE_NON_DESTRUCTIVE_RECAL VALUE]}]
                  if {[get_parameter_value DIAG_DDR3_CAL_FULL_CAL_ON_RESET]} {
                     set val [expr {$val | [enum_data SEQ_CONST_CAL_FULL_CAL_ON_RESET VALUE]}]
                  }
               }
            }
            if {$protocol_enum == "PROTOCOL_DDR4"} {
               if {[get_parameter_value DIAG_DDR4_CAL_ENABLE_NON_DES]} {
                  set val [expr {$val | [enum_data SEQ_CONST_CAL_ENABLE_NON_DESTRUCTIVE_RECAL VALUE]}]

                  if {[get_parameter_value DIAG_DDR4_CAL_FULL_CAL_ON_RESET]} {
                     set val [expr {$val | [enum_data SEQ_CONST_CAL_FULL_CAL_ON_RESET VALUE]}]
                  }
               }
            }

            if {[::altera_emif::ip_arch_nf::protocol_expert::is_phy_tracking_enabled]} {
                set val [expr {$val | [enum_data SEQ_CONST_CAL_ENABLE_PHY_TRACKING VALUE] }]
            }

            set val    [expr {$val | ([::altera_emif::ip_arch_nf::util::get_cal_config_silicon_rev] << [enum_data SEQ_SILICON_REV_SHIFT_NF VALUE])}]
         }
         SEQ_PT_DBG_CONFIG {
            set val  [expr {[get_parameter_value DIAG_EXPORT_SEQ_AVALON_SLAVE] == "CAL_DEBUG_EXPORT_MODE_DISABLED" ? 0 : 1}]
         }
         SEQ_PT_DBG_SKIP_RANKS {
            set val 0
         }
         SEQ_PT_DBG_SKIP_GROUPS {
            set val 0
         }
         SEQ_PT_NUM_CENTERS {
            set val [dict size $mem_pins_alloc]
         }
         SEQ_PT_NUM_CA_LANES {
            set val [llength $ac_lanes]
         }
         SEQ_PT_NUM_DATA_LANES {
            set val [llength $data_lanes]
         }
         SEQ_PT_NUM_AC_ROM_ENUMS {
            set val [altera_emif::arch_common::seq_param_tbl::get_num_of_ac_rom_pins $protocol_enum]
         }
         SEQ_PT_TILE_ID_PTR {
            set tids [_get_tids $mem_pins_alloc $ac_lanes $data_lanes $ping_pong_en]

            set val [dict create]
            dict set val PTR            0
            dict set val CONTENT        $tids
            dict set val ITEM_BYTE_SIZE 1
            dict set val BYTE_SIZE      [llength $tids]
         }
         SEQ_PT_PIN_ADDR_PTR {
            set pin_addrs [_get_pin_addresses $protocol_enum $mem_pins_alloc $ac_pin_map_enum $ac_lanes $data_lanes]

            set val [dict create]
            dict set val PTR            0
            dict set val CONTENT        $pin_addrs
            dict set val ITEM_BYTE_SIZE 1
            dict set val BYTE_SIZE      [llength $pin_addrs]
         }
         default {
            lappend protocol_seq_params $seq_pt_enum
            set is_protocol_specific 1
         }
      }

      if {! $is_protocol_specific} {
         dict set seq_param_tbl $seq_pt_enum $val
      }
   }

   set protocol_seq_param_tbl [::altera_emif::ip_arch_nf::protocol_expert::derive_seq_param_tbl $protocol_seq_params]
   set seq_param_tbl [dict merge $seq_param_tbl $protocol_seq_param_tbl]

   set start_addr $extra_data_addr
   foreach seq_pt_enum [enums_of_type SEQ_PT] {
      set is_ptr [enum_data $seq_pt_enum IS_PTR]
      if {$is_ptr} {
         set byte_size [dict get $seq_param_tbl $seq_pt_enum BYTE_SIZE]
         if {$byte_size > 0} {
            dict set seq_param_tbl $seq_pt_enum PTR $start_addr
            incr start_addr $byte_size
         }
      }
   }
   return $seq_param_tbl
}

proc ::altera_emif::ip_arch_nf::seq_param_tbl::_get_tids {mem_pins_alloc ac_lanes data_lanes ping_pong_en} {

   set retval [list]

   set ac_tile_i [lindex [lindex $ac_lanes 0] 0]

   set tile_arr_index 0
   lappend retval [dict create \
      DBG_NAME  "TILE \[$tile_arr_index\]" \
      DBG_VALUE [format "(T) = (%d)" $ac_tile_i] \
      VALUE     [::altera_emif::ip_arch_nf::util::get_center_tid $ac_tile_i] \
      ]
   incr tile_arr_index

   if {$ping_pong_en} {
      set sec_ac_tile_i [expr {$ac_tile_i - 1}]

      lappend retval [dict create \
         DBG_NAME  "TILE \[$tile_arr_index\]" \
         DBG_VALUE [format "(T) = (%d)" $sec_ac_tile_i] \
         VALUE     [::altera_emif::ip_arch_nf::util::get_center_tid $sec_ac_tile_i] \
         ]
      incr tile_arr_index

   } else {
      set sec_ac_tile_i $ac_tile_i
   }

   foreach tile_i [dict keys $mem_pins_alloc] {
      if {$tile_i != $ac_tile_i && $tile_i != $sec_ac_tile_i} {

         lappend retval [dict create \
            DBG_NAME  "TILE \[$tile_arr_index\]" \
            DBG_VALUE [format "(T) = (%d)" $tile_i] \
            VALUE     [::altera_emif::ip_arch_nf::util::get_center_tid $tile_i] \
            ]
         incr tile_arr_index
      }
   }

   set ac_lane_arr_index 0
   foreach ac_lane $ac_lanes {
      set tile_i [lindex $ac_lane 0]
      set lane_i [lindex $ac_lane 1]

      lappend retval [dict create \
         DBG_NAME  "AC_LANE \[$ac_lane_arr_index\]" \
         DBG_VALUE [format "(T L) = (%d %d)" $tile_i $lane_i] \
         VALUE     [::altera_emif::ip_arch_nf::util::get_lane_tid $tile_i $lane_i] \
         ]
      incr ac_lane_arr_index
   }

   set data_lane_arr_index 0
   foreach data_lane $data_lanes {
      set tile_i [lindex $data_lane 0]
      set lane_i [lindex $data_lane 1]

      lappend retval [dict create \
         DBG_NAME  "DATA_LANE \[$data_lane_arr_index\]" \
         DBG_VALUE [format "(T L) = (%d %d)" $tile_i $lane_i] \
         VALUE     [::altera_emif::ip_arch_nf::util::get_lane_tid $tile_i $lane_i] \
         ]
      incr data_lane_arr_index
   }

   while {[expr {[llength $retval] % 4}] != 0} {
      lappend retval [dict create \
         DBG_NAME  "ALIGN_PAD" \
         DBG_VALUE "" \
         VALUE     0 \
         ]
   }

   return $retval
}

proc ::altera_emif::ip_arch_nf::seq_param_tbl::_get_pin_addresses {protocol_enum mem_pins_alloc ac_pin_map_enum ac_lanes data_lanes} {

   set lanes_per_tile   [get_family_trait FAMILY_TRAIT_LANES_PER_TILE]
   set ac_pmr_enum_type [enum_data $ac_pin_map_enum RULES_ENUM_TYPE]

   set SEQ_PT_ORDER_AC_PINS        0
   set SEQ_PT_ORDER_STROBE_PINS    1
   set SEQ_PT_ORDER_STROBE_N_PINS  2
   set SEQ_PT_ORDER_RCLK_PINS      3
   set SEQ_PT_ORDER_RCLK_N_PINS    4
   set SEQ_PT_ORDER_WCLK_PINS      5
   set SEQ_PT_ORDER_WCLK_N_PINS    6
   set SEQ_PT_ORDER_DBI_PINS       7
   set SEQ_PT_ORDER_DM_PINS        8
   set SEQ_PT_ORDER_RWDATA_PINS    9
   set SEQ_PT_ORDER_RDATA_PINS     10
   set SEQ_PT_ORDER_WDATA_PINS     11

   set pins [list]

   set ac_pin_used [dict create]

   set pin_category $SEQ_PT_ORDER_AC_PINS

   for {set lane_arr_index 0} {$lane_arr_index < [llength $ac_lanes]} {incr lane_arr_index} {
      set lane      [lindex $ac_lanes $lane_arr_index]
      set tile_i    [lindex $lane 0]
      set lane_i    [lindex $lane 1]

      if {![dict exists $mem_pins_alloc $tile_i $lane_i]} {
         set is_hps [get_is_hps]
         emif_assert {$is_hps && $lane_i == 3}

      } else {
         set lane_dict [dict get $mem_pins_alloc $tile_i $lane_i]

         foreach pin_i [dict keys $lane_dict] {

            set port           [dict get $lane_dict $pin_i]
            set port_enum      [dict get $port TYPE_ENUM]
            set bus_index      [dict get $port BUS_INDEX]

            set seq_const_enum [altera_emif::arch_common::seq_param_tbl::get_ac_rom_enum $protocol_enum $port_enum $bus_index]
            set pin_order      [enum_data $seq_const_enum VALUE]

            emif_assert { ! [dict exists $ac_pin_used $pin_order]}
            dict set ac_pin_used $pin_order 1

            emif_assert { [expr {$pin_category & ((2 << 8 ) - 1)}] == $pin_category }
            emif_assert { [expr {$pin_order    & ((2 << 24) - 1)}] == $pin_order }
            set order [expr {($pin_category << 24) | $pin_order}]

            lappend pins [list $order "AC" $lane_arr_index $tile_i $lane_i $pin_i $port_enum $bus_index]
         }
      }
   }

   for {set lane_arr_index 0} {$lane_arr_index < [llength $data_lanes]} {incr lane_arr_index} {
      set lane      [lindex $data_lanes $lane_arr_index]
      set tile_i    [lindex $lane 0]
      set lane_i    [lindex $lane 1]
      set lane_dict [dict get $mem_pins_alloc $tile_i $lane_i]

      foreach pin_i [dict keys $lane_dict] {

         set port           [dict get $lane_dict $pin_i]
         set port_enum      [dict get $port TYPE_ENUM]
         set bus_index      [dict get $port BUS_INDEX]

         set port_order     [enum_data $port_enum PORT_INDEX]

         if {[enum_data $port_enum IS_RCLK] && [enum_data $port_enum IS_WCLK]} {
            set is_neg_leg   [enum_data $port_enum IS_NEG_LEG]
            if {$is_neg_leg} {
               set pin_category $SEQ_PT_ORDER_STROBE_N_PINS
            } else {
               set pin_category $SEQ_PT_ORDER_STROBE_PINS
            }
            set pin_order [expr {($port_order << 16) | $bus_index}]

         } elseif {[enum_data $port_enum IS_RCLK]} {
            set is_neg_leg   [enum_data $port_enum IS_NEG_LEG]
            if {$is_neg_leg} {
               set pin_category $SEQ_PT_ORDER_RCLK_N_PINS
            } else {
               set pin_category $SEQ_PT_ORDER_RCLK_PINS
            }
            set pin_order [expr {($port_order << 16) | $bus_index}]

         } elseif {[enum_data $port_enum IS_WCLK]} {
            set is_neg_leg   [enum_data $port_enum IS_NEG_LEG]
            if {$is_neg_leg} {
               set pin_category $SEQ_PT_ORDER_WCLK_N_PINS
            } else {
               set pin_category $SEQ_PT_ORDER_WCLK_PINS
            }
            set pin_order [expr {($port_order << 16) | $bus_index}]

         } elseif {[enum_data $port_enum IS_RDATA] && [enum_data $port_enum IS_WDATA]} {
            set pin_category $SEQ_PT_ORDER_RWDATA_PINS
            set pin_order [expr {($port_order << 16) | $bus_index}]

         } elseif {[enum_data $port_enum IS_RDATA]} {
            set pin_category $SEQ_PT_ORDER_RDATA_PINS
            set pin_order [expr {($port_order << 16) | $bus_index}]

         } elseif {[enum_data $port_enum IS_WDATA]} {
            set pin_category $SEQ_PT_ORDER_WDATA_PINS
            set pin_order [expr {($port_order << 16) | $bus_index}]

         } elseif {[enum_data $port_enum IS_DM]} {
            set pin_category $SEQ_PT_ORDER_DM_PINS
            set pin_order [expr {($port_order << 16) | $bus_index}]

         } elseif {[enum_data $port_enum IS_DBI]} {
            set pin_category $SEQ_PT_ORDER_DBI_PINS
            set pin_order [expr {($port_order << 16) | $bus_index}]

         } elseif {[enum_data $port_enum IS_AC]} {
            emif_assert {[_ac_pin_can_be_in_ac_lane_or_data_lane $protocol_enum $port_enum]}
            set pin_category   $SEQ_PT_ORDER_AC_PINS
            set seq_const_enum [altera_emif::arch_common::seq_param_tbl::get_ac_rom_enum $protocol_enum $port_enum $bus_index]
            set pin_order      [enum_data $seq_const_enum VALUE]

            emif_assert { ! [dict exists $ac_pin_used $pin_order]}
            dict set ac_pin_used $pin_order 1

         } else {
            emif_ie "Unsupported port enum $port_enum"
         }

         emif_assert { [expr {$pin_category & ((2 << 8 ) - 1)}] == $pin_category }
         emif_assert { [expr {$pin_order    & ((2 << 24) - 1)}] == $pin_order }
         set order [expr {($pin_category << 24) | $pin_order}]

         lappend pins [list $order "DATA" $lane_arr_index $tile_i $lane_i $pin_i $port_enum $bus_index]
      }
   }

   set num_of_ac_rom_pins [altera_emif::arch_common::seq_param_tbl::get_num_of_ac_rom_pins $protocol_enum]
   for {set ac_rom_i 0} {$ac_rom_i < $num_of_ac_rom_pins} {incr ac_rom_i} {
      if {! [dict exists $ac_pin_used $ac_rom_i]} {
         set order [expr {($SEQ_PT_ORDER_AC_PINS << 24) | $ac_rom_i}]
         lappend pins [list $order "AC" 0 0 0 0 "" 0]
      }
   }

   set retval [list]
   foreach pin [lsort -integer -index 0 $pins] {
      set lane_type      [lindex $pin 1]
      set lane_arr_index [lindex $pin 2]
      set tile_i         [lindex $pin 3]
      set lane_i         [lindex $pin 4]
      set pin_i          [lindex $pin 5]
      set port_enum      [lindex $pin 6]
      set bus_index      [lindex $pin 7]

      if {$port_enum == ""} {
         set port_dbg_name ""
         set dbg_val       "UNUSED_AC_PORT"
      } else {
         set port_dbg_name "$port_enum \[$bus_index\]"
         set dbg_val       [format "(T L P) = (%d %d %-2d)  %s_LANE \[%d\]" $tile_i $lane_i $pin_i $lane_type $lane_arr_index]
      }


      if {$lane_arr_index >= 16 || ([_ac_pin_can_be_in_ac_lane_or_data_lane $protocol_enum $port_enum] && $lane_type == "DATA")} {
         lappend retval [dict create \
            DBG_NAME   $port_dbg_name \
            DBG_VALUE  $dbg_val \
            VALUE      [expr {$pin_i << 4 | ((1 << 4) - 1)}] \
            ]

         lappend retval [dict create \
            DBG_NAME   "" \
            DBG_VALUE  "" \
            VALUE      $lane_arr_index \
            ]
      } else {
         lappend retval [dict create \
            DBG_NAME   $port_dbg_name \
            DBG_VALUE  $dbg_val \
            VALUE      [expr {$lane_arr_index << 4 | $pin_i}] \
            ]
      }
   }

   while {[expr {[llength $retval] % 4}] != 0} {
      lappend retval [dict create \
         DBG_NAME  "ALIGN_PAD" \
         DBG_VALUE "" \
         VALUE     0 \
         ]
   }

   return $retval
}

proc ::altera_emif::ip_arch_nf::seq_param_tbl::_ac_pin_can_be_in_ac_lane_or_data_lane {protocol_enum port_enum} {
   set retval 0
   if {$port_enum == "PORT_MEM_ALERT_N"} {
      if {$protocol_enum == "PROTOCOL_DDR3" || $protocol_enum == "PROTOCOL_DDR4"} {
         set retval 1
      }
   }
   return $retval
}

proc ::altera_emif::ip_arch_nf::seq_param_tbl::_init {} {

   if {[emif_utest_enabled]} {

      emif_utest_start "::altera_emif::ip_arch_nf::seq_param_tbl"

      set glob_param_tbl_byte_size [altera_emif::arch_common::seq_param_tbl::cal_static_tbl_byte_size SEQ_GPT]
      set param_tbl_byte_size      [altera_emif::arch_common::seq_param_tbl::cal_static_tbl_byte_size SEQ_PT]

      emif_assert {[enum_data SEQ_CONST_GLOBAL_PAR_SIZE VALUE]    == $glob_param_tbl_byte_size}
      emif_assert {[enum_data SEQ_CONST_INTERFACE_PAR_SIZE VALUE] == $param_tbl_byte_size}

      emif_utest_pass
   }
}

::altera_emif::ip_arch_nf::seq_param_tbl::_init

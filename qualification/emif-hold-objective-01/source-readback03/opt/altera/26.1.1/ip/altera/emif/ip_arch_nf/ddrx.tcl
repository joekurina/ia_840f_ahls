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


package provide altera_emif::ip_arch_nf::ddrx 0.1

package require altera_emif::util::messaging
package require altera_emif::util::qini
package require altera_emif::util::hwtcl_utils
package require altera_emif::util::enums
package require altera_emif::util::math
package require altera_emif::util::device_family
package require altera_emif::ip_arch_nf::util

namespace eval ::altera_emif::ip_arch_nf::ddrx:: {
   
   namespace import ::altera_emif::util::messaging::*
   namespace import ::altera_emif::util::qini::*
   namespace import ::altera_emif::util::enums::*
   namespace import ::altera_emif::util::math::*
   namespace import ::altera_emif::util::device_family::*
   namespace import ::altera_emif::util::hwtcl_utils::*
   namespace import ::altera_emif::ip_arch_nf::util::*

   namespace export hmc_div_ceil
   namespace export get_tile_and_lane_index_of_dqs_group
   
}


proc ::altera_emif::ip_arch_nf::ddrx::get_dqs_bus_mode {} {

   set dq_width   [get_parameter_value MEM_TTL_DATA_WIDTH]
   set dqs_width  [get_parameter_value MEM_TTL_NUM_OF_READ_GROUPS]
   set group_size [expr {$dq_width / $dqs_width}]
   
   if {$group_size == 4} {
      set extra_configs_str [get_parameter_value "DIAG_EXTRA_CONFIGS"]
      set extra_configs [parse_extra_configs $extra_configs_str]
      
      if {[extra_config_is_explicit_on $extra_configs FORCE_DENSE_X4_ON]} {
         return "DQS_BUS_MODE_X4"
      } elseif {[extra_config_is_explicit_on $extra_configs FORCE_DENSE_X4_OFF]} {
         return "DQS_BUS_MODE_X8_X9"
      } elseif {[get_is_es] && [get_die_string] == "20nm5"} {
         return "DQS_BUS_MODE_X8_X9"
      } else {
         return "DQS_BUS_MODE_X4"
      }
   } elseif {$group_size == 8} {
      return "DQS_BUS_MODE_X8_X9"
   } else {
      emif_ie {"Unsupported DDRx group size $group_size"}
   }
}

proc ::altera_emif::ip_arch_nf::ddrx::get_tile_and_lane_index_of_dqs_group {dqs_group dqs_width num_ac_lanes ac_tile_i sec_ac_tile_i is_dense_x4 ping_pong_en} {

   set lanes_per_tile [::altera_emif::util::device_family::get_family_trait FAMILY_TRAIT_LANES_PER_TILE]
   
   set dqs_per_lane    [expr {$is_dense_x4 ? 2 : 1}]
   
   set use_dqs_b       [expr {(($dqs_group % 2) == 1 && $is_dense_x4) ? 1 : 0}]
   
   if {!$ping_pong_en} {
   
      set tile_i          [expr {int(($dqs_group / $dqs_per_lane) / $lanes_per_tile)}]
      set lane_i          [expr {    ($dqs_group / $dqs_per_lane) % $lanes_per_tile}]
      
      if {$tile_i >= $ac_tile_i} {
         set tile_i [expr { int(($tile_i * $lanes_per_tile + $lane_i + $num_ac_lanes) / $lanes_per_tile) }]
         set lane_i [expr {    (($tile_i * $lanes_per_tile + $lane_i + $num_ac_lanes) % $lanes_per_tile) }]
      }
      
      set is_secondary 0
      
   } else {
      set single_if_dqs_width [expr {$dqs_width / 2}]
      
      if {$dqs_group < $single_if_dqs_width} {
         set is_secondary 0
         set single_if_dqs_group $dqs_group
      } else {
         set is_secondary 1
         set single_if_dqs_group [expr {$dqs_group - $single_if_dqs_width}]
      }
      
      set tmp_lane_i [expr {$single_if_dqs_group / $dqs_per_lane}]
      if {$tmp_lane_i < 2} {
         set tile_i $sec_ac_tile_i
         set lane_i [expr {$is_secondary ? $tmp_lane_i : ($tmp_lane_i + 2)}]
      } else {
         set tmp_lane_i [expr {$tmp_lane_i - 2}]
         if {$is_secondary} {
            set tile_i [expr {$sec_ac_tile_i - 1 - int($tmp_lane_i / $lanes_per_tile)}]
            set lane_i [expr {$tmp_lane_i % $lanes_per_tile}]
         } else {
            set tile_i [expr {$ac_tile_i + 1 + int($tmp_lane_i / $lanes_per_tile)}]
            set lane_i [expr {$tmp_lane_i % $lanes_per_tile}]
         }
      }
   }
   
   return [list $tile_i $lane_i $use_dqs_b $is_secondary]
}

proc ::altera_emif::ip_arch_nf::ddrx::get_clk_ratios {config_enum rate_enum mem_clk_freq_mhz} {

   set user_clk_ratio [enum_data $rate_enum RATIO]
   
   set ratios [dict create]
   
   if {$config_enum == "CONFIG_PHY_AND_HARD_CTRL"} {

   
      if {$user_clk_ratio == 2} {
         dict set ratios PHY_HMC 2
      } else {
         emif_assert {$user_clk_ratio == 4}
         
         set ping_pong_en      [get_parameter_value "PHY_PING_PONG_EN"]
         set extra_configs_str [get_parameter_value "DIAG_EXTRA_CONFIGS"]
         set extra_configs     [parse_extra_configs $extra_configs_str]
         
         set diag_hmc_hrc      [get_parameter_value "DIAG_HMC_HRC"]
         set force_hmc_hrc_on  [expr {[string compare -nocase $diag_hmc_hrc "ON"] == 0  || [extra_config_is_explicit_on $extra_configs FORCE_HMC_HRC_ON] ? 1 : 0}]
         set force_hmc_hrc_off [expr {[string compare -nocase $diag_hmc_hrc "OFF"] == 0 || [extra_config_is_explicit_on $extra_configs FORCE_HMC_HRC_OFF] ? 1 : 0}]
         
         if {$force_hmc_hrc_on} {
            dict set ratios PHY_HMC 2
            
         } elseif {$force_hmc_hrc_off} {
            dict set ratios PHY_HMC 4
            
         } elseif {[get_is_es] && [get_die_string] == "20nm5"} {
            dict set ratios PHY_HMC 4
            
         } elseif {$ping_pong_en} {
            dict set ratios PHY_HMC 2
            
         } elseif {[extra_config_is_explicit_on $extra_configs DIAG_CPA_OUT_1_EN]} {
            dict set ratios PHY_HMC 4
            
         } elseif { ([get_is_es2] && [get_die_string] == "20nm5") || ([get_is_es] && [get_die_string] == "20nm4") } {
            set hmc_fmax_lookup [dict create  ""  534  E1  534  I1  534  E2  400  I2  400  E3  367  I3  367]]
            set hmc_fmax_mhz    [dict get $hmc_fmax_lookup [get_speedgrade]]
            dict set ratios PHY_HMC [expr {(($mem_clk_freq_mhz / 2.0) <= $hmc_fmax_mhz) ? 2 : 4}]

         } else {
            dict set ratios PHY_HMC 2
         }
      }
   } else {
      dict set ratios PHY_HMC $user_clk_ratio
   }
   
   dict set ratios C2P_P2C $user_clk_ratio
   dict set ratios USER    $user_clk_ratio
   
   return $ratios
}

proc ::altera_emif::ip_arch_nf::ddrx::get_num_and_type_of_hmc_ports {config_enum ping_pong_en ctrl_avl_protocol_enum} {
   
   if {$config_enum == "CONFIG_PHY_AND_HARD_CTRL"} {
      set num_of_ports [expr {$ping_pong_en ? 2 : 1}]
      
      set enable_ecc              [get_parameter_value "CTRL_ECC_EN"]
      set ctrl_avl_protocol_enum  [expr {$enable_ecc ? "CTRL_AVL_PROTOCOL_ST" : $ctrl_avl_protocol_enum}]
      
   } else {
      set num_of_ports 0
      set ctrl_avl_protocol_enum CTRL_AVL_PROTOCOL_INVALID
   }

   set hmc_ifs [dict create]
   dict set hmc_ifs NUM_OF_PORTS $num_of_ports
   dict set hmc_ifs CTRL_AVL_PROTOCOL_ENUM $ctrl_avl_protocol_enum
   return $hmc_ifs   
}

proc ::altera_emif::ip_arch_nf::ddrx::get_common_hmc_cfgs {in_params} {
   
   set is_hps            [dict get $in_params IS_HPS]
   set ecc_en            [dict get $in_params ECC_EN]
   set phy_hmc_clk_ratio [dict get $in_params PHY_HMC_CLK_RATIO]
   set rc_en             [dict get $in_params RC_EN]
   set slot_rotate_en    [dict get $in_params SLOT_ROTATE_EN]
   set ping_pong_en      [dict get $in_params PING_PONG_EN]
   set ping_pong_master0 [dict get $in_params PING_PONG_MASTER0]
   set ping_pong_master1 [dict get $in_params PING_PONG_MASTER1]

   set retval [dict create]
   
   dict set retval COL_TO_COL_OFFSET 0
   
   if {$phy_hmc_clk_ratio == 4} {
      dict set retval SIDEBAND_OFFSET 3
   } else {
      dict set retval SIDEBAND_OFFSET 1
   }
   
   if {$slot_rotate_en} {
      dict set retval ROW_TO_ROW_OFFSET      [expr {$phy_hmc_clk_ratio == 4 ? 3 : 1}]
      dict set retval COL_TO_DIFF_COL_OFFSET [expr {$phy_hmc_clk_ratio == 4 ? 3 : 1}]
   } else {
      dict set retval ROW_TO_ROW_OFFSET      0
      dict set retval COL_TO_DIFF_COL_OFFSET 0
   }
   
   if {$ping_pong_en} {
      if {$slot_rotate_en} {
         dict set retval COL_TO_ROW_OFFSET   [expr {$phy_hmc_clk_ratio == 4 ? 3 : 1}]
         dict set retval ROW_TO_COL_OFFSET   [expr {$phy_hmc_clk_ratio == 4 ? 3 : 1}]
      } else {
         dict set retval COL_TO_ROW_OFFSET   0
         dict set retval ROW_TO_COL_OFFSET   0
      }
   } else {
      if {$slot_rotate_en} {
         dict set retval COL_TO_ROW_OFFSET   [expr {$phy_hmc_clk_ratio == 4 ? 3 : 1}]
         dict set retval ROW_TO_COL_OFFSET   [expr {$phy_hmc_clk_ratio == 4 ? 3 : 1}]
      } else {
         dict set retval COL_TO_ROW_OFFSET   [expr {$phy_hmc_clk_ratio == 4 ?  2 :  1}]
         dict set retval ROW_TO_COL_OFFSET   [expr {$phy_hmc_clk_ratio == 4 ? -2 : -1}]
      }
   }
   
   if {!$ping_pong_en} {
      dict set retval ARBITER_TYPE "twot"  
      dict set retval SLOT_OFFSET  [expr {$phy_hmc_clk_ratio == 4 ? 3 : 2}]
      dict set retval COL_CMD_SLOT [expr {$phy_hmc_clk_ratio == 4 ? 8 : 2}]
      dict set retval ROW_CMD_SLOT [expr {$phy_hmc_clk_ratio == 4 ? 2 : 1}]
      
   } else {
      if {$ping_pong_master0} {
         dict set retval ARBITER_TYPE "onet"  
         dict set retval SLOT_OFFSET  [expr {$phy_hmc_clk_ratio == 4 ? 1 : 0}]
         dict set retval COL_CMD_SLOT [expr {$phy_hmc_clk_ratio == 4 ? 2 : 1}]
         dict set retval ROW_CMD_SLOT [expr {$phy_hmc_clk_ratio == 4 ? 2 : 1}]
      } else {
         dict set retval ARBITER_TYPE "onet"  
         dict set retval SLOT_OFFSET  [expr {$phy_hmc_clk_ratio == 4 ? 3 : 2}]
         dict set retval COL_CMD_SLOT [expr {$phy_hmc_clk_ratio == 4 ? 8 : 2}]
         dict set retval ROW_CMD_SLOT [expr {$phy_hmc_clk_ratio == 4 ? 8 : 2}]
      }
   }

   return $retval
}

proc ::altera_emif::ip_arch_nf::ddrx::get_common_hmc_db_cfgs {in_params} {
   set is_hps            [dict get $in_params IS_HPS]
   set ecc_en            [dict get $in_params ECC_EN]
   set rc_en             [dict get $in_params RC_EN]
   
   if {$is_hps} {
      set val 8
   } else {
      if {$ecc_en} {
         set val [expr {$rc_en ? 16 : 8}]
      } else {
         set val [expr {$rc_en ? 8 : 4}]
      }
   }
   dict set retval RB_RESERVED_ENTRY $val
   dict set retval WB_RESERVED_ENTRY $val
   
   if {$is_hps || $ecc_en} {
      set val [set_bits $val 5 1 1]
   }
   dict set retval DBC_WB_RESERVED_ENTRY $val
   return $retval
}

proc ::altera_emif::ip_arch_nf::ddrx::hmc_div_ceil {val divisor} {
   return [expr {int(ceil($val * 1.0 / $divisor))}]
}

proc ::altera_emif::ip_arch_nf::ddrx::is_phy_tracking_enabled {} {
   if {[get_is_es] && ([get_die_string] == "20nm5")} {
      return 0
   } else {
      if {[get_dqs_bus_mode] == "DQS_BUS_MODE_X4" && [get_parameter_value MEM_NUM_OF_LOGICAL_RANKS] > 1} {
         return 0
      } else {
         return 0
      }
   }
}

proc ::altera_emif::ip_arch_nf::ddrx::get_oct_size {mem_clk_freq_mhz} {
   if {$mem_clk_freq_mhz <= 667} {
      set retval 1
   } elseif {$mem_clk_freq_mhz <= 1150} {
      set retval 2
   } else {
      set retval 3
   }
   return $retval
}

proc ::altera_emif::ip_arch_nf::ddrx::get_base_wr_to_rd_turnaround_mem_cycs {mem_clk_freq_mhz} {
   if {$mem_clk_freq_mhz <= 667} {
      set retval 4
   } elseif {$mem_clk_freq_mhz <= 1150} {
      set retval 5
   } else {
      set retval 6
   }
   return $retval
}

proc ::altera_emif::ip_arch_nf::ddrx::get_base_rd_to_wr_turnaround_mem_cycs {mem_clk_freq_mhz} {
   return 4
}


proc ::altera_emif::ip_arch_nf::ddrx::_init {} {
}

::altera_emif::ip_arch_nf::ddrx::_init

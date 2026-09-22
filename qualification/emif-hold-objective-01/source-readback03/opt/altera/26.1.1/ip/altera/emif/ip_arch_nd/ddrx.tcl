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


package provide altera_emif::ip_arch_nd::ddrx 0.1

package require altera_emif::util::messaging
package require altera_emif::util::qini
package require altera_emif::util::hwtcl_utils
package require altera_emif::util::enums
package require altera_emif::util::math
package require altera_emif::util::device_family
package require altera_emif::ip_arch_nd::util

namespace eval ::altera_emif::ip_arch_nd::ddrx:: {
   
   namespace import ::altera_emif::util::messaging::*
   namespace import ::altera_emif::util::qini::*
   namespace import ::altera_emif::util::enums::*
   namespace import ::altera_emif::util::math::*
   namespace import ::altera_emif::util::device_family::*
   namespace import ::altera_emif::util::hwtcl_utils::*
   namespace import ::altera_emif::ip_arch_nd::util::*

   namespace export hmc_div_ceil
   namespace export get_tile_and_lane_index_of_dqs_group
   
}


proc ::altera_emif::ip_arch_nd::ddrx::get_dqs_bus_mode {} {

   set dq_width   [get_parameter_value MEM_TTL_DATA_WIDTH]
   set dqs_width  [get_parameter_value MEM_TTL_NUM_OF_READ_GROUPS]
   set group_size [expr {$dq_width / $dqs_width}]
   
   if {$group_size == 4} {
      return "DQS_BUS_MODE_X4"
   } elseif {$group_size == 8} {
      return "DQS_BUS_MODE_X8_X9"
   } else {
      emif_ie {"Unsupported DDRx group size $group_size"}
   }
}

proc ::altera_emif::ip_arch_nd::ddrx::get_tile_and_lane_index_of_dqs_group {dqs_group dqs_width num_ac_lanes ac_tile_i sec_ac_tile_i is_dense_x4 ping_pong_en} {

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

proc ::altera_emif::ip_arch_nd::ddrx::get_clk_ratios {config_enum rate_enum mem_clk_freq_mhz} {

   set user_clk_ratio [enum_data $rate_enum RATIO]
   
   set ratios [dict create]
   
   if {$config_enum == "CONFIG_PHY_AND_HARD_CTRL"} {


   
      if {($user_clk_ratio == 2) || [get_is_hps]} {
         dict set ratios PHY_HMC 2
      } else {
         emif_assert {$user_clk_ratio == 4}
         
         set extra_configs_str [get_parameter_value "DIAG_EXTRA_CONFIGS"]
         set extra_configs     [parse_extra_configs $extra_configs_str]
         
         set diag_hmc_hrc      [get_parameter_value "DIAG_HMC_HRC"]
         set force_hmc_hrc_on  [expr {[string compare -nocase $diag_hmc_hrc "ON"] == 0  || [extra_config_is_explicit_on $extra_configs FORCE_HMC_HRC_ON] ? 1 : 0}]
         set force_hmc_hrc_off [expr {[string compare -nocase $diag_hmc_hrc "OFF"] == 0 || [extra_config_is_explicit_on $extra_configs FORCE_HMC_HRC_OFF] ? 1 : 0}]
         
         if {$force_hmc_hrc_on} {
            dict set ratios PHY_HMC 2
            
         } elseif {$force_hmc_hrc_off} {
            dict set ratios PHY_HMC 4
            
         } elseif {[check_device_has_hmc_hr_limitation]} {
            if {[check_nd5_es_must_run_phy_hmc_at_hr 0]} {
               dict set ratios PHY_HMC 2
            } else {
               dict set ratios PHY_HMC 4
            }
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

proc ::altera_emif::ip_arch_nd::ddrx::get_common_hmc_cfgs {in_params} {
   
   set is_hps            [dict get $in_params IS_HPS]
   set ecc_en            [dict get $in_params ECC_EN]
   set phy_hmc_clk_ratio [dict get $in_params PHY_HMC_CLK_RATIO]
   set rc_en             [dict get $in_params RC_EN]
   set slot_rotate_en    [dict get $in_params SLOT_ROTATE_EN]
   set ping_pong_en      [dict get $in_params PING_PONG_EN]
   set ping_pong_master0 [dict get $in_params PING_PONG_MASTER0]
   set ping_pong_master1 [dict get $in_params PING_PONG_MASTER1]
   set ready_latency     [dict get $in_params READY_LATENCY]
   set geardown_en       [dict get $in_params GEARDOWN_EN]

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
   
   if {$geardown_en} {
      dict set retval COL_TO_ROW_OFFSET   0
      dict set retval ROW_TO_COL_OFFSET   0
   } else {
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
   }
   
   if {$geardown_en} {
      dict set retval ARBITER_TYPE [expr {$phy_hmc_clk_ratio == 4 ? "arbiter_type_2t" : "arbiter_type_1t"}]
      dict set retval SLOT_OFFSET  [expr {$phy_hmc_clk_ratio == 4 ? 2 : 0}]
      dict set retval COL_CMD_SLOT [expr {$phy_hmc_clk_ratio == 4 ? 12 : 3}]
      dict set retval ROW_CMD_SLOT [expr {$phy_hmc_clk_ratio == 4 ? 3 : 3}]
   } else {
      if {!$ping_pong_en} {
         dict set retval ARBITER_TYPE "arbiter_type_2t"  
         dict set retval SLOT_OFFSET  [expr {$phy_hmc_clk_ratio == 4 ? 3 : 2}]
         dict set retval COL_CMD_SLOT [expr {$phy_hmc_clk_ratio == 4 ? 8 : 2}]
         dict set retval ROW_CMD_SLOT [expr {$phy_hmc_clk_ratio == 4 ? 2 : 1}]
         
      } else {
         dict set retval ARBITER_TYPE "arbiter_type_1t"  
         if {$ping_pong_master0} {
            dict set retval SLOT_OFFSET  [expr {$phy_hmc_clk_ratio == 4 ? 1 : 0}]
            dict set retval COL_CMD_SLOT [expr {$phy_hmc_clk_ratio == 4 ? 2 : 1}]
            dict set retval ROW_CMD_SLOT [expr {$phy_hmc_clk_ratio == 4 ? 2 : 1}]
         } else {
            dict set retval SLOT_OFFSET  [expr {$phy_hmc_clk_ratio == 4 ? 3 : 2}]
            dict set retval COL_CMD_SLOT [expr {$phy_hmc_clk_ratio == 4 ? 8 : 2}]
            dict set retval ROW_CMD_SLOT [expr {$phy_hmc_clk_ratio == 4 ? 8 : 2}]
         }
      }
   }
   
   if {$ready_latency == 0} {
      dict set retval CMD_FIFO_RESERVE_EN "disable"
   } else {
      dict set retval CMD_FIFO_RESERVE_EN "enable"
   }

   return $retval
}

proc ::altera_emif::ip_arch_nd::ddrx::get_common_hmc_db_cfgs {in_params} {
   set is_hps            [dict get $in_params IS_HPS]
   set ecc_en            [dict get $in_params ECC_EN]
   set rc_en             [dict get $in_params RC_EN]
   set ready_latency     [dict get $in_params READY_LATENCY]
   
   if {$is_hps} {
      dict set retval WB_RESERVED_ENTRY 40
      dict set retval RB_RESERVED_ENTRY 8
      dict set retval DBC_WB_RESERVED_ENTRY 40
   } else {
      if {$ecc_en} {
         if {$rc_en} {
            dict set retval WB_RESERVED_ENTRY 48
            dict set retval RB_RESERVED_ENTRY 16
            dict set retval DBC_WB_RESERVED_ENTRY 48
         } else {
            dict set retval WB_RESERVED_ENTRY 40
            dict set retval RB_RESERVED_ENTRY 8
            dict set retval DBC_WB_RESERVED_ENTRY 40
         }
      } else {
         if {$rc_en} {
            dict set retval WB_RESERVED_ENTRY 16
            dict set retval RB_RESERVED_ENTRY 16
            dict set retval DBC_WB_RESERVED_ENTRY 16
         } else {
            dict set retval WB_RESERVED_ENTRY 8
            dict set retval RB_RESERVED_ENTRY 8
            dict set retval DBC_WB_RESERVED_ENTRY 8
         }
      }
   }
   
   set cfg_rb_readylat_en [expr {[dict get $retval DBC_WB_RESERVED_ENTRY] & 64}]
   emif_assert {$cfg_rb_readylat_en == 0}

   return $retval
}

proc ::altera_emif::ip_arch_nd::ddrx::hmc_div_ceil {val divisor} {
   return [expr {int(ceil($val * 1.0 / $divisor))}]
}

proc ::altera_emif::ip_arch_nd::ddrx::is_phy_tracking_enabled {} {
   return 0
}

proc ::altera_emif::ip_arch_nd::ddrx::get_oct_size {mem_clk_freq_mhz} {
   if {$mem_clk_freq_mhz <= 444} {
      set retval 1
   } elseif {$mem_clk_freq_mhz <= 888} {
      set retval 2
   } else {
      set retval 3
   }
   return $retval
}

proc ::altera_emif::ip_arch_nd::ddrx::get_base_wr_to_rd_turnaround_mem_cycs {mem_clk_freq_mhz} {
   if {$mem_clk_freq_mhz <= 444} {
      set retval 6
   } elseif {$mem_clk_freq_mhz <= 888} {
      set retval 7
   } else {
      set retval 8
   }
   return $retval
}

proc ::altera_emif::ip_arch_nd::ddrx::get_base_rd_to_wr_turnaround_mem_cycs {mem_clk_freq_mhz} {
   if {$mem_clk_freq_mhz <= 444} {
      set retval 6
   } elseif {$mem_clk_freq_mhz <= 888} {
      set retval 7
   } elseif {$mem_clk_freq_mhz <= 1200} {
      set retval 8
   } else {
      set retval 10
   }
   return $retval
}


proc ::altera_emif::ip_arch_nd::ddrx::_init {} {
}

::altera_emif::ip_arch_nd::ddrx::_init

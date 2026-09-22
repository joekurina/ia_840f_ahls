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


package provide altera_emif::ip_arch_nf::ddr3 0.1

package require altera_emif::util::messaging
package require altera_emif::util::qini
package require altera_emif::util::hwtcl_utils
package require altera_emif::util::math
package require altera_emif::util::enums
package require altera_emif::util::device_family

package require altera_emif::arch_common::util

package require altera_emif::ip_arch_nf::enum_defs_ac_pin_mapping
package require altera_emif::ip_arch_nf::util
package require altera_emif::ip_arch_nf::ddrx

namespace eval ::altera_emif::ip_arch_nf::ddr3:: {

   namespace import ::altera_emif::util::messaging::*
   namespace import ::altera_emif::util::qini::*
   namespace import ::altera_emif::util::math::*
   namespace import ::altera_emif::util::enums::*
   namespace import ::altera_emif::util::hwtcl_utils::*
   namespace import ::altera_emif::util::device_family::*
   namespace import ::altera_emif::ip_arch_nf::util::*
   namespace import ::altera_emif::ip_arch_nf::ddrx::*


}


proc ::altera_emif::ip_arch_nf::ddr3::get_dqs_bus_mode {} {
   return [::altera_emif::ip_arch_nf::ddrx::get_dqs_bus_mode]
}

proc ::altera_emif::ip_arch_nf::ddr3::get_interface_ports {if_enum} {
   switch $if_enum {
      IF_MEM {
         return [_get_mem_ports]
      }
      IF_AFI {
         return [_get_afi_ports]
      }
      IF_CTRL_AST_CMD {
         return [_get_ctrl_ast_cmd_ports]
      }
      IF_CTRL_AST_WR {
         return [_get_ctrl_ast_wr_ports]
      }
      IF_CTRL_AST_RD {
         return [_get_ctrl_ast_rd_ports]
      }
      IF_CTRL_AMM {
         return [_get_ctrl_amm_ports]
      }
      IF_CTRL_USER_REFRESH {
         return [_get_ctrl_user_refresh_ports]
      }
      default {
         emif_ie "Unknown interface type $if_enum"
      }
   }
}

proc ::altera_emif::ip_arch_nf::ddr3::get_interface_properties {if_enum} {
   switch $if_enum {
      IF_CTRL_AMM {
         return [_get_ctrl_amm_properties]
      }
      IF_CTRL_AST_CMD {
         return [_get_ctrl_ast_cmd_properties]
      }
      IF_CTRL_AST_RD {
         return [_get_ctrl_ast_properties false]
      }
      IF_CTRL_AST_WR {
         return [_get_ctrl_ast_properties true]
      }
      default {
         emif_ie "Interface type $if_enum not supported"
      }
   }
}

proc ::altera_emif::ip_arch_nf::ddr3::is_ctrl_sideband_interface_enabled {if_enum} {
   set hmc_ifs [get_num_and_type_of_hmc_ports]
   if {[dict get $hmc_ifs NUM_OF_PORTS] == 0} {
      return 0
   } else {
      switch $if_enum {
         IF_CTRL_USER_PRIORITY {
            return [get_parameter_value CTRL_DDR3_USER_PRIORITY_EN]
         }
         IF_CTRL_AUTO_PRECHARGE {
            return [get_parameter_value CTRL_DDR3_AUTO_PRECHARGE_EN]
         }
         IF_CTRL_USER_REFRESH {
            if {[get_parameter_value DIAG_EXPOSE_DFT_SIGNALS]} {
               return [get_parameter_value CTRL_DDR3_USER_REFRESH_EN]
            } else {
               return 0
            }
         }
         IF_CTRL_SELF_REFRESH {
            return [get_parameter_value CTRL_DDR3_SELF_REFRESH_EN]
         }
         IF_CTRL_WILL_REFRESH {
            return 0
         }
         IF_CTRL_DEEP_POWER_DOWN {
            return 0
         }
         IF_CTRL_POWER_DOWN {
            return [get_parameter_value CTRL_DDR3_AUTO_POWER_DOWN_EN]
         }
         IF_CTRL_ZQ_CAL {
            return 0
         }
         IF_CTRL_ECC {
            return [get_parameter_value CTRL_ECC_EN]
         }
         IF_CTRL_MMR_SLAVE {
            return [get_parameter_value CTRL_DDR3_MMR_EN]
         }
         default {
            return 0
         }
      }
   }
}

proc ::altera_emif::ip_arch_nf::ddr3::get_ac_pin_map_scheme {} {

   set retval [dict create]

   set format_enum    [get_parameter_value MEM_DDR3_FORMAT_ENUM]
   set ping_pong_en   [get_parameter_value PHY_DDR3_PING_PONG_EN]
   set ck_width       [get_parameter_value MEM_DDR3_TTL_CK_WIDTH]

   if {$ping_pong_en} {
      set cke_width 4
      set cs_width 4
      set odt_width 4
   } else {
      set cke_width      [get_parameter_value MEM_DDR3_TTL_CKE_WIDTH]
      set cs_width       [get_parameter_value MEM_DDR3_TTL_CS_WIDTH]
      set odt_width      [get_parameter_value MEM_DDR3_TTL_ODT_WIDTH]
   }

   if {$format_enum == "MEM_FORMAT_RDIMM"} {
      dict set retval HMC_DIMM_TYPE_STR "rdimm"
      if {$ck_width > 1 || $cke_width > 2 || $cs_width > 2 || $odt_width > 2} {
         dict set retval ENUM "DDR3_AC_PM_0_1_2_3_R"
      } else {
         dict set retval ENUM "DDR3_AC_PM_0_1_2_R"
      }

   } elseif {$format_enum == "MEM_FORMAT_LRDIMM"} {
      dict set retval HMC_DIMM_TYPE_STR "lrdimm"
      dict set retval ENUM "DDR3_AC_PM_0_1_2_3_LR"

   } else {
      if {$format_enum == "MEM_FORMAT_DISCRETE"} {
         dict set retval HMC_DIMM_TYPE_STR "component"
      } elseif {$format_enum == "MEM_FORMAT_UDIMM"} {
         dict set retval HMC_DIMM_TYPE_STR "udimm"
      } elseif {$format_enum == "MEM_FORMAT_SODIMM"} {
         dict set retval HMC_DIMM_TYPE_STR "sodimm"
      } else {
         emif_ie "Unsupported format $format_enum"
      }

      if {$ck_width > 2 || $cke_width > 2 || $cs_width > 2 || $odt_width > 2} {
         dict set retval ENUM "DDR3_AC_PM_0_1_2_3_NR"
      } else {
         dict set retval ENUM "DDR3_AC_PM_0_1_2_NR"
      }
   }
   return $retval
}

proc ::altera_emif::ip_arch_nf::ddr3::get_resource_consumption {} {
   set lanes_per_tile [::altera_emif::util::device_family::get_family_trait FAMILY_TRAIT_LANES_PER_TILE]

   set dqs_width       [get_parameter_value MEM_DDR3_TTL_DQS_WIDTH]
   set ping_pong_en    [get_parameter_value PHY_DDR3_PING_PONG_EN]
   set is_dense_x4     [expr {[get_dqs_bus_mode] == "DQS_BUS_MODE_X4" ? 1 : 0}]

   set is_hps                     [get_is_hps]
   set ecc_en                     [get_parameter_value CTRL_ECC_EN]
   set ac_pm_scheme               [get_ac_pin_map_scheme]
   set ac_pm_enum                 [dict get $ac_pm_scheme ENUM]
   set num_ac_lanes               [enum_data $ac_pm_enum LANES_USED]

   set num_lanes_reserved_for_ac  [expr {($is_hps && !$ecc_en) ? 4 : $num_ac_lanes}]

   set num_data_lanes             [expr {$dqs_width / ($is_dense_x4 ? 2 : 1)}]
   set num_lanes                  [expr {$num_lanes_reserved_for_ac + $num_data_lanes}]

   if {$ping_pong_en && ($num_data_lanes > 4)} {
      set num_tiles [expr {int(ceil(($num_lanes_reserved_for_ac + 4) * 1.0 / $lanes_per_tile) + 2*ceil((double($num_data_lanes - 4) / 2) / $lanes_per_tile))}]
   } else {
      set num_tiles [expr {int(ceil(($num_data_lanes + $num_lanes_reserved_for_ac) * 1.0 / $lanes_per_tile))}]
   }

   if {$ping_pong_en} {
      emif_assert {[expr {$num_tiles % 2 == 0}]}
   }

   if {$is_dense_x4} {
      emif_assert {[expr {$dqs_width % 2 == 0}]}
   }

   set retval [dict create]
   dict set retval AC_PM_ENUM      $ac_pm_enum
   dict set retval NUM_AC_LANES    $num_lanes_reserved_for_ac
   dict set retval NUM_DATA_LANES  $num_data_lanes
   dict set retval NUM_LANES       $num_lanes
   dict set retval NUM_TILES       $num_tiles

   return $retval
}

proc ::altera_emif::ip_arch_nf::ddr3::_get_alert_n_placement_scheme {} {

   set extra_configs_str    [get_parameter_value DIAG_EXTRA_CONFIGS]
   set extra_configs        [parse_extra_configs $extra_configs_str]

   set place_in_ac_lane     false
   set place_in_dqs_group   false
   set dqs_group            -1
   set ac_lane_idx          -1
   set ac_lane_pin_idx      -1

   if {[dict exists $extra_configs FORCE_ALERT_N_TO_AC_LANE]} {
      set place_in_ac_lane true

      set tmp [split [dict get $extra_configs FORCE_ALERT_N_TO_AC_LANE] ":"]
      set ac_lane_idx       [lindex $tmp 0]
      set ac_lane_pin_idx   [lindex $tmp 1]

   } elseif {[dict exists $extra_configs FORCE_ALERT_N_TO_DQS_GROUP]} {
      set place_in_dqs_group true
      set dqs_group [dict get $extra_configs FORCE_ALERT_N_TO_DQS_GROUP]

   } elseif {[get_parameter_value "MEM_DDR3_ALERT_N_PLACEMENT_ENUM"] == "DDR3_ALERT_N_PLACEMENT_AC_LANES"} {
      set place_in_ac_lane true

   } else {
      set place_in_dqs_group true
      set dqs_group [get_parameter_value "MEM_DDR3_ALERT_N_DQS_GROUP"]
   }

   set retval [dict create]
   dict set retval PLACE_IN_AC_LANE   $place_in_ac_lane
   dict set retval PLACE_IN_DQS_GROUP $place_in_dqs_group
   dict set retval DQS_GROUP          $dqs_group
   dict set retval AC_LANE_IDX        $ac_lane_idx
   dict set retval AC_LANE_PIN_IDX    $ac_lane_pin_idx

   return $retval
}

proc ::altera_emif::ip_arch_nf::ddr3::alloc_mem_pins {mem_ports_name} {

   upvar 1 $mem_ports_name mem_ports
   set tiles [dict create]

   set lanes_per_tile [::altera_emif::util::device_family::get_family_trait FAMILY_TRAIT_LANES_PER_TILE]
   set pins_per_lane  [::altera_emif::util::device_family::get_family_trait FAMILY_TRAIT_PINS_PER_LANE]
   set pins_per_tile  [expr {$lanes_per_tile * $pins_per_lane}]

   set ping_pong_en      [get_parameter_value PHY_DDR3_PING_PONG_EN]
   set dqs_width         [get_parameter_value MEM_DDR3_TTL_DQS_WIDTH]
   set dq_per_dqs        [get_parameter_value MEM_DDR3_DQ_PER_DQS]
   set is_dense_x4       [expr {[get_dqs_bus_mode] == "DQS_BUS_MODE_X4" ? 1 : 0}]

   set resources       [get_resource_consumption]
   set ac_pm_enum      [dict get $resources AC_PM_ENUM]
   set num_ac_lanes    [dict get $resources NUM_AC_LANES]
   set num_data_lanes  [dict get $resources NUM_DATA_LANES]
   set num_lanes       [dict get $resources NUM_LANES]
   set num_tiles       [dict get $resources NUM_TILES]

   if {$ping_pong_en} {
      set ac_tile_i     [expr {int($num_tiles / 2)}]
      set sec_ac_tile_i [expr {$ac_tile_i - 1}]
   } else {
      set ac_tile_i     [expr {int(($num_tiles - 1) / 2)}]
      set sec_ac_tile_i -1
   }

   set alert_n_port_indices [list]
   set alert_n_placement    [_get_alert_n_placement_scheme]

   for {set i 0} {$i < [llength $mem_ports]} {incr i} {
      set port      [lindex $mem_ports $i]
      set enabled   [dict get $port ENABLED]
      set type_enum [dict get $port TYPE_ENUM]
      set bus_i     [dict get $port BUS_INDEX]

      if {!$enabled} {
         continue
      }

      if {$type_enum == "PORT_MEM_ALERT_N"} {
         lappend alert_n_port_indices $i
         continue
      }

      if {$type_enum == "PORT_MEM_CK" || \
          $type_enum == "PORT_MEM_CK_N" || \
          $type_enum == "PORT_MEM_A" || \
          $type_enum == "PORT_MEM_BA" || \
          $type_enum == "PORT_MEM_CKE" || \
          $type_enum == "PORT_MEM_ODT" || \
          $type_enum == "PORT_MEM_CS_N" || \
          $type_enum == "PORT_MEM_RM" || \
          $type_enum == "PORT_MEM_RAS_N" || \
          $type_enum == "PORT_MEM_CAS_N" || \
          $type_enum == "PORT_MEM_WE_N" || \
          $type_enum == "PORT_MEM_PAR" || \
          $type_enum == "PORT_MEM_RESET_N"} {

         set remapped_bus_i $bus_i
         if {$ping_pong_en} {
            if {$bus_i == 1 && [dict get $port BUS_WIDTH] == 2} {
               if {$type_enum == "PORT_MEM_CS_N" || $type_enum == "PORT_MEM_ODT" || $type_enum == "PORT_MEM_CKE"} {
                  set remapped_bus_i 2
               }
            }
         }

         set tile_i          $ac_tile_i
         set abs_pin_i       [get_ac_pin_index $ac_pm_enum $type_enum $remapped_bus_i]
         set lane_i          [expr {int($abs_pin_i / $pins_per_lane)}]
         set pin_i           [expr {$abs_pin_i % $pins_per_lane}]
         set is_pp_sec_data  0

      } elseif {$type_enum == "PORT_MEM_DQ" || \
                $type_enum == "PORT_MEM_DM" || \
                $type_enum == "PORT_MEM_DQS" || \
                $type_enum == "PORT_MEM_DQS_N"} {

         if {$type_enum == "PORT_MEM_DQ"} {
            set dqs_group [expr {int($bus_i / $dq_per_dqs)}]
         } else {
            set dqs_group $bus_i
         }

         set tmp_lst        [get_tile_and_lane_index_of_dqs_group $dqs_group $dqs_width $num_ac_lanes $ac_tile_i $sec_ac_tile_i $is_dense_x4 $ping_pong_en]
         set tile_i         [lindex $tmp_lst 0]
         set lane_i         [lindex $tmp_lst 1]
         set use_dqs_b      [lindex $tmp_lst 2]
         set is_pp_sec_data [lindex $tmp_lst 3]

         if {$type_enum == "PORT_MEM_DQ"} {
            if {$is_dense_x4} {
               if {$use_dqs_b} {
                  if {([expr {($bus_i % $dq_per_dqs)}] >= 2)} {
                     set pin_i [expr {($bus_i % $dq_per_dqs) + 8}]
                  } else {
                     set pin_i [expr {($bus_i % $dq_per_dqs) + 6}]
                  }
               } else {
                  set pin_i [expr {$bus_i % $dq_per_dqs}]
               }
            } else {
               if {([expr {($bus_i % $dq_per_dqs)}] >= 3)} {
                  set pin_i [expr {($bus_i % $dq_per_dqs) + 3}]
               } else {
                  set pin_i [expr {($bus_i % $dq_per_dqs + 1)}]
               }
            }
         } elseif {$type_enum == "PORT_MEM_DM"} {
            emif_assert {!$is_dense_x4}
            set pin_i 11
         } elseif {$type_enum == "PORT_MEM_DQS"} {
            set pin_i [expr {$use_dqs_b ? 8 : 4}]
         } else {
            set pin_i [expr {$use_dqs_b ? 9 : 5}]
         }
      } else {
         emif_ie "Unknown port type $type_enum"
      }

      set abs_pin_i [expr {$tile_i * $pins_per_tile + $lane_i * $pins_per_lane + $pin_i}]
      dict set port ABS_PIN_INDEX $abs_pin_i
      dict set port TILE_INDEX $tile_i
      dict set port LANE_INDEX $lane_i
      dict set port PIN_INDEX $pin_i
      dict set port IS_PP_SEC_DATA_GROUP $is_pp_sec_data
      lset mem_ports $i $port

      ::altera_emif::arch_common::util::alloc_pin $port tiles $tile_i $lane_i $pin_i
   }

   foreach alert_n_port_index $alert_n_port_indices {

      set port      [lindex $mem_ports $alert_n_port_index]
      set type_enum "PORT_MEM_ALERT_N"
      set bus_i     [dict get $port BUS_INDEX]

      if {[dict get $alert_n_placement PLACE_IN_AC_LANE]} {
         if {[dict get $alert_n_placement AC_LANE_IDX] != -1} {
            set tile_i $ac_tile_i
            set lane_i [dict get $alert_n_placement AC_LANE_IDX]
            set pin_i  [dict get $alert_n_placement AC_LANE_PIN_IDX]

            if {$lane_i >= $num_ac_lanes} {
               post_ipgen_e_msg MSG_INVALID_ALERT_N_AC_LANE [list $lane_i [expr {$num_ac_lanes-1}]]
            }

            if {[dict exists $tiles $tile_i $lane_i $pin_i]} {
               post_ipgen_e_msg MSG_ALERT_N_AC_PIN_OCCUPIED [list $pin_i $lane_i]
            }
         } else {
            set tile_i    $ac_tile_i
            set abs_pin_i [get_ac_pin_index $ac_pm_enum $type_enum $bus_i]
            set lane_i    [expr {int($abs_pin_i / $pins_per_lane)}]
            set pin_i     [expr {$abs_pin_i % $pins_per_lane}]
         }
      } else {
         set dqs_group [dict get $alert_n_placement DQS_GROUP]

         set tmp_lst   [get_tile_and_lane_index_of_dqs_group $dqs_group $dqs_width $num_ac_lanes $ac_tile_i $sec_ac_tile_i $is_dense_x4 $ping_pong_en]
         set tile_i    [lindex $tmp_lst 0]
         set lane_i    [lindex $tmp_lst 1]

         set pin_i 0

         if {$dqs_group < 0 || $dqs_group >= $dqs_width} {
            post_ipgen_e_msg MSG_INVALID_ALERT_N_DQS_GROUP [list $dqs_group]
         }

         if {[dict exists $tiles $tile_i $lane_i $pin_i]} {
            post_ipgen_e_msg MSG_ALERT_N_DQS_GROUP_FULL [list $dqs_group]
         }
      }

      set abs_pin_i [expr {$tile_i * $pins_per_tile + $lane_i * $pins_per_lane + $pin_i}]
      dict set port ABS_PIN_INDEX $abs_pin_i
      dict set port TILE_INDEX $tile_i
      dict set port LANE_INDEX $lane_i
      dict set port PIN_INDEX $pin_i
      lset mem_ports $alert_n_port_index $port

      if {[has_pending_ipgen_e_msg]} {
         issue_pending_ipgen_e_msg_and_terminate
      } else {
         ::altera_emif::arch_common::util::alloc_pin $port tiles $tile_i $lane_i $pin_i
      }
   }

   return $tiles
}

proc ::altera_emif::ip_arch_nf::ddr3::assign_io_settings {ports_name} {
   upvar 1 $ports_name ports

   set io_voltage          [get_parameter_value PHY_DDR3_IO_VOLTAGE]
   set ac_io_std_enum      [get_parameter_value PHY_DDR3_AC_IO_STD_ENUM]
   set ac_mode_enum        [get_parameter_value PHY_DDR3_AC_MODE_ENUM]
   set ac_slew_rate_enum   [get_parameter_value PHY_DDR3_AC_SLEW_RATE_ENUM]
   set ck_io_std_enum      [get_parameter_value PHY_DDR3_CK_IO_STD_ENUM]
   set ck_mode_enum        [get_parameter_value PHY_DDR3_CK_MODE_ENUM]
   set ck_slew_rate_enum   [get_parameter_value PHY_DDR3_CK_SLEW_RATE_ENUM]
   set data_io_std_enum    [get_parameter_value PHY_DDR3_DATA_IO_STD_ENUM]
   set data_in_mode_enum   [get_parameter_value PHY_DDR3_DATA_IN_MODE_ENUM]
   set data_out_mode_enum  [get_parameter_value PHY_DDR3_DATA_OUT_MODE_ENUM]
   set ref_clk_io_std_enum [get_parameter_value PHY_DDR3_PLL_REF_CLK_IO_STD_ENUM]
   set rzq_io_std_enum     [get_parameter_value PHY_DDR3_RZQ_IO_STD_ENUM]

   set ac_cal_oct          [get_parameter_value PHY_AC_CALIBRATED_OCT]
   set ck_cal_oct          [get_parameter_value PHY_CK_CALIBRATED_OCT]
   set data_cal_oct        [get_parameter_value PHY_DATA_CALIBRATED_OCT]
   set dqs_pkg_deskew      [get_parameter_value BOARD_DDR3_IS_SKEW_WITHIN_DQS_DESKEWED]
   set ac_pkg_deskew       [get_parameter_value BOARD_DDR3_IS_SKEW_WITHIN_AC_DESKEWED]

   for {set i 0} {$i < [llength $ports]} {incr i} {
      set port      [lindex $ports $i]
      set enabled   [dict get $port ENABLED]
      set type_enum [dict get $port TYPE_ENUM]

      if {!$enabled} {
         continue
      }

      set cal_oct            0
      set io_std_enum        IO_STD_INVALID
      set out_oct_enum       OUT_OCT_INVALID
      set in_oct_enum        IN_OCT_INVALID
      set current_st_enum    CURRENT_ST_INVALID
      set slew_rate_enum     SLEW_RATE_INVALID
      set aiot_sim_open      false
      set pkg_deskew         false

      switch $type_enum {
         PORT_MEM_CK -
         PORT_MEM_CK_N {
            set cal_oct $ck_cal_oct
            set io_std_enum [enum_data $ck_io_std_enum DF_IO_STD]
            if {[enum_type $ck_mode_enum] == "OUT_OCT"} {
               set out_oct_enum $ck_mode_enum
            } else {
               set current_st_enum $ck_mode_enum
            }
            set slew_rate_enum $ck_slew_rate_enum
            set pkg_deskew $ac_pkg_deskew
         }
         PORT_MEM_A -
         PORT_MEM_ACT_N -
         PORT_MEM_BA -
         PORT_MEM_BG -
         PORT_MEM_C -
         PORT_MEM_CKE -
         PORT_MEM_ODT -
         PORT_MEM_CS_N -
         PORT_MEM_RM -
         PORT_MEM_RAS_N -
         PORT_MEM_CAS_N -
         PORT_MEM_WE_N -
         PORT_MEM_PAR {
            set cal_oct $ac_cal_oct
            set io_std_enum $ac_io_std_enum
            if {[enum_type $ac_mode_enum] == "OUT_OCT"} {
               set out_oct_enum $ac_mode_enum
            } else {
               set current_st_enum $ac_mode_enum
            }
            set slew_rate_enum $ac_slew_rate_enum
            set pkg_deskew $ac_pkg_deskew
         }
         PORT_MEM_ALERT_N {
            set cal_oct $data_cal_oct
            set io_std_enum $data_io_std_enum
            set in_oct_enum $data_in_mode_enum
            set pkg_deskew $dqs_pkg_deskew
         }
         PORT_MEM_RESET_N {
            set cal_oct 0
            if {$io_voltage == 1.35} {
               set aiot_sim_open true
               set io_std_enum IO_STD_SSTL_135_C1
               set current_st_enum CURRENT_ST_12
            } else {
               set io_std_enum IO_STD_CMOS_15
               set out_oct_enum OUT_OCT_0
            }
            set slew_rate_enum $ac_slew_rate_enum
            set pkg_deskew $ac_pkg_deskew
         }
         PORT_MEM_DM {
            set cal_oct $data_cal_oct
            set io_std_enum $data_io_std_enum
            if {[enum_type $data_out_mode_enum] == "OUT_OCT"} {
               set out_oct_enum $data_out_mode_enum
            } else {
               set current_st_enum $data_out_mode_enum
            }
            set pkg_deskew $dqs_pkg_deskew
         }
         PORT_MEM_DQ {
            set cal_oct $data_cal_oct
            set io_std_enum $data_io_std_enum
            set in_oct_enum $data_in_mode_enum
            if {[enum_type $data_out_mode_enum] == "OUT_OCT"} {
               set out_oct_enum $data_out_mode_enum
            } else {
               set current_st_enum $data_out_mode_enum
            }
            set pkg_deskew $dqs_pkg_deskew
         }
         PORT_MEM_DQS -
         PORT_MEM_DQS_N {
            set cal_oct $data_cal_oct
            set io_std_enum [enum_data $data_io_std_enum DF_IO_STD]
            set in_oct_enum $data_in_mode_enum
            if {[enum_type $data_out_mode_enum] == "OUT_OCT"} {
               set out_oct_enum $data_out_mode_enum
            } else {
               set current_st_enum $data_out_mode_enum
            }
            set pkg_deskew $dqs_pkg_deskew
         }
         PORT_OCT_RZQIN {
            set cal_oct 0
            set io_std_enum $rzq_io_std_enum
         }
         PORT_PLL_REF_CLK {
            set cal_oct 0
            set io_std_enum $ref_clk_io_std_enum
            set in_oct_enum [resolve_pll_ref_clk_in_oct_enum $ref_clk_io_std_enum]
         }
         default {
            emif_ie "Unknown port type $type_enum"
         }
      }

      dict set port CAL_OCT        $cal_oct
      dict set port IO_STD         $io_std_enum
      dict set port OUT_OCT        $out_oct_enum
      dict set port IN_OCT         $in_oct_enum
      dict set port CURRENT_ST     $current_st_enum
      dict set port SLEW_RATE      $slew_rate_enum
      dict set port AIOT_SIM_OPEN  $aiot_sim_open
      dict set port PKG_DESKEW     $pkg_deskew
      lset ports $i $port
   }
   return 1
}

proc ::altera_emif::ip_arch_nf::ddr3::get_clk_ratios {} {

   set config_enum      [get_parameter_value PHY_DDR3_CONFIG_ENUM]
   set rate_enum        [get_parameter_value PHY_DDR3_RATE_ENUM]
   set mem_clk_freq_mhz [get_parameter_value PHY_DDR3_MEM_CLK_FREQ_MHZ]

   return [::altera_emif::ip_arch_nf::ddrx::get_clk_ratios $config_enum $rate_enum $mem_clk_freq_mhz]
}

proc :::altera_emif::ip_arch_nf::ddr3::check_hmc_legality {} {
   return 1
}

proc ::altera_emif::ip_arch_nf::ddr3::get_num_and_type_of_hmc_ports {} {
   set config_enum             [get_parameter_value PHY_DDR3_CONFIG_ENUM]
   set ping_pong_en            [get_parameter_value PHY_DDR3_PING_PONG_EN]
   set ctrl_avl_protocol_enum  [get_parameter_value CTRL_DDR3_AVL_PROTOCOL_ENUM]

   return [::altera_emif::ip_arch_nf::ddrx::get_num_and_type_of_hmc_ports $config_enum $ping_pong_en $ctrl_avl_protocol_enum]
}

proc ::altera_emif::ip_arch_nf::ddr3::get_lane_cfgs {} {

   set is_hps             [get_is_hps]
   set clk_ratios         [get_clk_ratios]
   set phy_hmc_clk_ratio  [expr {[dict get $clk_ratios PHY_HMC] * 1.0}]
   set c2p_p2c_clk_ratio  [expr {[dict get $clk_ratios C2P_P2C] * 1.0}]
   set rc_en              [expr {$phy_hmc_clk_ratio == 2 && $c2p_p2c_clk_ratio == 4 ? 1 : 0}]
   set ecc_en             [get_parameter_value CTRL_ECC_EN]
   set mem_clk_freq_mhz   [get_parameter_value PHY_DDR3_MEM_CLK_FREQ_MHZ]

   set retval [dict create]
   dict set retval "PREAMBLE_MODE" "preamble_one_cycle"
   dict set retval "DBI_WR_ENABLE" "false"
   dict set retval "DBI_RD_ENABLE" "false"
   dict set retval "CRC_EN"        "crc_disable"
   dict set retval "SWAP_DQS_A_B"  "false"
   dict set retval "DQS_PACK_MODE" "packed"
   dict set retval "OCT_SIZE"      [::altera_emif::ip_arch_nf::ddrx::get_oct_size $mem_clk_freq_mhz]

   set in_params [dict create]
   dict set in_params IS_HPS        $is_hps
   dict set in_params ECC_EN        $ecc_en
   dict set in_params RC_EN         $rc_en
   set common_hmc_db_params [::altera_emif::ip_arch_nf::ddrx::get_common_hmc_db_cfgs $in_params]
   dict set retval "DBC_WB_RESERVED_ENTRY" [dict get $common_hmc_db_params DBC_WB_RESERVED_ENTRY]

   return $retval
}

proc ::altera_emif::ip_arch_nf::ddr3::get_hmc_cfgs {hmc_inst} {

   set clk_ratios         [get_clk_ratios]
   set phy_hmc_clk_ratio  [expr {[dict get $clk_ratios PHY_HMC] * 1.0}]
   set c2p_p2c_clk_ratio  [expr {[dict get $clk_ratios C2P_P2C] * 1.0}]

   set rc_en              [expr {$phy_hmc_clk_ratio == 2 && $c2p_p2c_clk_ratio == 4 ? 1 : 0}]

   set is_hps                               [get_is_hps]
   set phy_config_enum                      [get_parameter_value "PHY_CONFIG_ENUM"]
   set is_hmc                               [expr {$phy_config_enum == "CONFIG_PHY_AND_HARD_CTRL" ? 1 : 0}]
   set ecc_en                               [get_parameter_value CTRL_ECC_EN]
   set dm_en                                [get_parameter_value MEM_DDR3_DM_EN]
   set reorder_en                           [get_parameter_value CTRL_DDR3_REORDER_EN]
   set pdn_en                               [get_parameter_value CTRL_DDR3_AUTO_POWER_DOWN_EN]
   set trcd_cyc                             [get_parameter_value MEM_DDR3_TRCD_CYC]
   set tras_cyc                             [get_parameter_value MEM_DDR3_TRAS_CYC]
   set trp_cyc                              [get_parameter_value MEM_DDR3_TRP_CYC]
   set trrd_cyc                             [get_parameter_value MEM_DDR3_TRRD_CYC]
   set tcl_cyc                              [get_parameter_value MEM_DDR3_TCL]
   set tcwl_cyc                             [get_parameter_value MEM_DDR3_WTCL]
   set tal_cyc                              [expr {([enum_data [get_parameter_value MEM_DDR3_ATCL_ENUM] VALUE] == 0) ? 0 : ($tcl_cyc - [enum_data [get_parameter_value MEM_DDR3_ATCL_ENUM] VALUE])}]
   set trtp_cyc                             [get_parameter_value MEM_DDR3_TRTP_CYC]
   set twtr_cyc                             [get_parameter_value MEM_DDR3_TWTR_CYC]
   set twr_cyc                              [get_parameter_value MEM_DDR3_TWR_CYC]
   set trfc_cyc                             [get_parameter_value MEM_DDR3_TRFC_CYC]
   set trefi_cyc                            [get_parameter_value MEM_DDR3_TREFI_CYC]
   set tfaw_cyc                             [get_parameter_value MEM_DDR3_TFAW_CYC]
   set tmrd_cyc                             [get_parameter_value MEM_DDR3_TMRD_CK_CYC]
   set format_enum                          [get_parameter_value MEM_DDR3_FORMAT_ENUM]
   set pd_enum                              [get_parameter_value MEM_DDR3_PD_ENUM]
   set ranks_per_dimm                       [get_parameter_value MEM_DDR3_RANKS_PER_DIMM]
   set user_rd_to_wr_same_chip_delta_cyc    [get_parameter_value CTRL_DDR3_RD_TO_WR_SAME_CHIP_DELTA_CYCS]
   set user_wr_to_rd_same_chip_delta_cyc    [get_parameter_value CTRL_DDR3_WR_TO_RD_SAME_CHIP_DELTA_CYCS]
   set user_rd_to_rd_diff_chip_delta_cyc    [get_parameter_value CTRL_DDR3_RD_TO_RD_DIFF_CHIP_DELTA_CYCS]
   set user_rd_to_wr_diff_chip_delta_cyc    [get_parameter_value CTRL_DDR3_RD_TO_WR_DIFF_CHIP_DELTA_CYCS]
   set user_wr_to_wr_diff_chip_delta_cyc    [get_parameter_value CTRL_DDR3_WR_TO_WR_DIFF_CHIP_DELTA_CYCS]
   set user_wr_to_rd_diff_chip_delta_cyc    [get_parameter_value CTRL_DDR3_WR_TO_RD_DIFF_CHIP_DELTA_CYCS]
   set mem_clk_freq                         [get_parameter_value PHY_DDR3_MEM_CLK_FREQ_MHZ]
   set mem_clk_ns                           [expr {(1000000.0 / $mem_clk_freq) / 1000.0}]

   set ping_pong_en                         [get_parameter_value PHY_DDR3_PING_PONG_EN]
   set ping_pong_master0                    [expr {($ping_pong_en && $hmc_inst == "PRI") ? 1 : 0}]
   set ping_pong_master1                    [expr {($ping_pong_en && $hmc_inst == "SEC") ? 1 : 0}]

   set bl 8

   set trc_cyc  [expr {$tras_cyc + $trp_cyc}]

   set tcksrx_cyc [expr {int(ceil(max(5 * $mem_clk_ns, 10) / $mem_clk_ns))}]

   set txp_cyc [expr {int(ceil(max(3 * $mem_clk_ns, 6) / $mem_clk_ns))}]

   set txpdll_cyc [expr {int(ceil(max(10 * $mem_clk_ns, 24) / $mem_clk_ns))}]

   set tzqcs_cyc [expr {int(ceil(max(64 * $mem_clk_ns, 80) / $mem_clk_ns))}]

   set tzqoper_cyc [expr {int(ceil(max(256 * $mem_clk_ns, 320) / $mem_clk_ns))}]

   set tmod_cyc [expr {int(ceil(max(12 * $mem_clk_ns, 15) / $mem_clk_ns))}]

   set hmc_phy_delay_mismatch 14

   set rd_to_wr_extra_turnaround [::altera_emif::ip_arch_nf::ddrx::get_base_rd_to_wr_turnaround_mem_cycs $mem_clk_freq]
   set wr_to_rd_extra_turnaround [::altera_emif::ip_arch_nf::ddrx::get_base_wr_to_rd_turnaround_mem_cycs $mem_clk_freq]

   set tswitch 2

   set slot_rotate_en 0

   set in_params [dict create]
   dict set in_params IS_HPS              $is_hps
   dict set in_params ECC_EN              $ecc_en
   dict set in_params PHY_HMC_CLK_RATIO   $phy_hmc_clk_ratio
   dict set in_params RC_EN               $rc_en
   dict set in_params SLOT_ROTATE_EN      $slot_rotate_en
   dict set in_params PING_PONG_EN        $ping_pong_en
   dict set in_params PING_PONG_MASTER0   $ping_pong_master0
   dict set in_params PING_PONG_MASTER1   $ping_pong_master1

   set common_hmc_params    [::altera_emif::ip_arch_nf::ddrx::get_common_hmc_cfgs $in_params]
   set common_hmc_db_params [::altera_emif::ip_arch_nf::ddrx::get_common_hmc_db_cfgs $in_params]

   set col_to_col_offset      [dict get $common_hmc_params COL_TO_COL_OFFSET]
   set sideband_offset        [dict get $common_hmc_params SIDEBAND_OFFSET]
   set row_to_row_offset      [dict get $common_hmc_params ROW_TO_ROW_OFFSET]
   set col_to_diff_col_offset [dict get $common_hmc_params COL_TO_DIFF_COL_OFFSET]
   set col_to_row_offset      [dict get $common_hmc_params COL_TO_ROW_OFFSET]
   set row_to_col_offset      [dict get $common_hmc_params ROW_TO_COL_OFFSET]
   set arbiter_type           [dict get $common_hmc_params ARBITER_TYPE]
   set slot_offset            [dict get $common_hmc_params SLOT_OFFSET]
   set col_cmd_slot           [dict get $common_hmc_params COL_CMD_SLOT]
   set row_cmd_slot           [dict get $common_hmc_params ROW_CMD_SLOT]
   set rb_reserved_entry      [dict get $common_hmc_db_params RB_RESERVED_ENTRY]
   set wb_reserved_entry      [dict get $common_hmc_db_params WB_RESERVED_ENTRY]

   set act_to_act         [hmc_div_ceil [expr {$tras_cyc + $trp_cyc + $row_to_row_offset}] $phy_hmc_clk_ratio]
   set rd_ap_to_valid     [hmc_div_ceil [expr {$tal_cyc + max($trtp_cyc, 4) + $trp_cyc + $col_to_row_offset}] $phy_hmc_clk_ratio]
   set rd_to_rd_diff_chip [expr {[hmc_div_ceil [expr { int(($bl / 2) + 2 + $col_to_col_offset) }] $phy_hmc_clk_ratio] + $user_rd_to_rd_diff_chip_delta_cyc}]

   if {$tal_cyc >= ($trcd_cyc + $row_to_col_offset)} {
      set act_to_rdwr 0
   } else {
      set act_to_rdwr [hmc_div_ceil [expr {$trcd_cyc - $tal_cyc + $row_to_col_offset}] $phy_hmc_clk_ratio]
   }

   set retval [dict create]

   foreach hmc_cfg_enum [enums_of_type HMC_CFG] {

      set val 0

      switch $hmc_cfg_enum {
         HMC_CFG_ENABLE_ECC {
            set val [expr {$ecc_en ? "enable" : "disable"}]
         }
         HMC_CFG_REORDER_DATA {
            set val [expr {($reorder_en || ($is_hps && $ecc_en) || !$is_hmc) ? "enable" : "disable"}]
         }
         HMC_CFG_REORDER_READ {
            set val [expr {(($reorder_en && !$ecc_en) || !$is_hmc) ? "enable" : "disable"}]
         }
         HMC_CFG_REORDER_RDATA {
            set val [expr {(($reorder_en && !$ecc_en) || ($is_hps && $ecc_en) || !$is_hmc) ? "enable" : "disable"}]
         }
         HMC_CFG_STARVE_LIMIT {
            set val [get_parameter_value CTRL_DDR3_STARVE_LIMIT]
         }
         HMC_CFG_DQS_TRACKING_EN {
            set val "disable"
         }
         HMC_CFG_ARBITER_TYPE {
            set val $arbiter_type
         }
         HMC_CFG_PING_PONG_MODE {
            if {!$ping_pong_en} {
               set val "pingpong_off"
            } elseif {$ping_pong_master0} {
               set val "pingpong_master0"
            } else {
               set val "pingpong_master1"
            }
         }
         HMC_CFG_SLOT_ROTATE_EN {
            set val $slot_rotate_en
         }
         HMC_CFG_SLOT_OFFSET {
            set val $slot_offset
         }
         HMC_CFG_COL_CMD_SLOT {
            set val $col_cmd_slot
         }
         HMC_CFG_ROW_CMD_SLOT {
            set val $row_cmd_slot
         }
         HMC_CFG_ENABLE_RC {
            set val [expr {$rc_en ? "enable" : "disable"}]
         }
         HMC_CFG_CS_TO_CHIP_MAPPING {
            if {$format_enum == "MEM_FORMAT_RDIMM" && $ranks_per_dimm == 1} {
               set val [bin2num "0000_0000_0100_0001"]
            } else {
               set val [bin2num "1000_0100_0010_0001"]
            }
         }
         HMC_CFG_RB_RESERVED_ENTRY {
            set val $rb_reserved_entry
         }
         HMC_CFG_WB_RESERVED_ENTRY {
            set val $wb_reserved_entry
         }
         HMC_CFG_TCL {
            set val [expr {int($tcl_cyc)}]
         }
         HMC_CFG_POWER_SAVING_EXIT_CYC {
            set val [hmc_div_ceil [expr {4 + $sideband_offset}] $phy_hmc_clk_ratio]
         }
         HMC_CFG_MEM_CLK_DISABLE_ENTRY_CYC {
            set val [hmc_div_ceil [expr {$tcksrx_cyc + $hmc_phy_delay_mismatch + $sideband_offset}] $phy_hmc_clk_ratio]
         }
         HMC_CFG_WRITE_ODT_CHIP {
            set val [get_parameter_value MEM_DDR3_CTRL_CFG_WRITE_ODT_CHIP]
         }
         HMC_CFG_READ_ODT_CHIP {
            set val [get_parameter_value MEM_DDR3_CTRL_CFG_READ_ODT_CHIP]
         }
         HMC_CFG_WR_ODT_ON {
            set val 0
         }
         HMC_CFG_RD_ODT_ON {
            set val [expr {int($tcl_cyc - $tcwl_cyc)}]

            emif_assert {$val >= 0}
         }
         HMC_CFG_WR_ODT_PERIOD {
            set val 6
         }
         HMC_CFG_RD_ODT_PERIOD {
            set val 6
         }
         HMC_CFG_SRF_ZQCAL_DISABLE {
            set val "disable"
         }
         HMC_CFG_MPS_ZQCAL_DISABLE {
            set val "disable"
         }
         HMC_CFG_MPS_DQSTRK_DISABLE {
            set val "disable"
         }
         HMC_CFG_DQSTRK_TO_VALID_LAST {
            set val [expr {max($rd_ap_to_valid, $act_to_act - $act_to_rdwr) + 6}]
         }
         HMC_CFG_DQSTRK_TO_VALID {
            set val $rd_to_rd_diff_chip
         }
         HMC_CFG_SB_CG_DISABLE {
            set val [expr {$ping_pong_en ? "enable" : "disable"}]
         }
         HMC_CFG_USER_RFSH_EN {
            set val [expr {[get_parameter_value CTRL_DDR3_USER_REFRESH_EN] ? "enable" : "disable"}]
         }
         HMC_CFG_SRF_AUTOEXIT_EN {
            set val [expr {$is_hps ? "enable" : "disable"}]
         }
         HMC_CFG_SRF_ENTRY_EXIT_BLOCK {
            set val "presrfexit"
         }
         HMC_CFG_MEM_IF_COLADDR_WIDTH {
            set val "col_width_[get_parameter_value MEM_DDR3_COL_ADDR_WIDTH]"
         }
         HMC_CFG_MEM_IF_ROWADDR_WIDTH {
            set row_addr_width [get_parameter_value MEM_DDR3_ROW_ADDR_WIDTH]
            set rm_width       [get_parameter_value MEM_DDR3_RM_WIDTH]
            set ttl_width      [expr {$row_addr_width + $rm_width}]
            set val "row_width_${ttl_width}"
         }
         HMC_CFG_MEM_IF_BANKADDR_WIDTH {
            set val "bank_width_[get_parameter_value MEM_DDR3_BANK_ADDR_WIDTH]"
         }
         HMC_CFG_LOCAL_IF_CS_WIDTH {
            set cs_width [get_parameter_value MEM_DDR3_CS_WIDTH]
            set cs_addr_width [expr {int(ceil(log($cs_width)/log(2)))}]
            set val "cs_width_$cs_addr_width"
         }
         HMC_CFG_ADDR_ORDER {
            set addr_order_enum [get_parameter_value CTRL_DDR3_ADDR_ORDER_ENUM]

            set mapping [dict create DDR3_CTRL_ADDR_ORDER_CS_B_R_C   HMC_CFG_ADDR_ORDER_CS_B_R_C \
                                     DDR3_CTRL_ADDR_ORDER_CS_R_B_C   HMC_CFG_ADDR_ORDER_CS_R_B_C \
                                     DDR3_CTRL_ADDR_ORDER_R_CS_B_C   HMC_CFG_ADDR_ORDER_R_CS_B_C ]

            emif_assert {[dict exists $mapping $addr_order_enum]}
            set val [enum_data [dict get $mapping $addr_order_enum] WYSIWYG_NAME]
         }
         HMC_CFG_ACT_TO_RDWR {
            set val $act_to_rdwr
         }
         HMC_CFG_ACT_TO_PCH {
            set val [hmc_div_ceil [expr {$tras_cyc + $row_to_row_offset}] $phy_hmc_clk_ratio]
         }
         HMC_CFG_ACT_TO_ACT {
            set val $act_to_act
         }
         HMC_CFG_ACT_TO_ACT_DIFF_BANK {
            set val [hmc_div_ceil [expr {$trrd_cyc + $row_to_row_offset}] $phy_hmc_clk_ratio]
         }
         HMC_CFG_RD_TO_RD {
            set val [hmc_div_ceil [expr { int(($bl / 2) + $col_to_col_offset) }] $phy_hmc_clk_ratio]
         }
         HMC_CFG_RD_TO_RD_DIFF_CHIP {
            set val $rd_to_rd_diff_chip
         }
         HMC_CFG_RD_TO_WR {
            set val [expr {[hmc_div_ceil [expr {$tcl_cyc - $tcwl_cyc + ($bl / 2) + 2 + $rd_to_wr_extra_turnaround + $col_to_diff_col_offset}] $phy_hmc_clk_ratio] + $user_rd_to_wr_same_chip_delta_cyc}]
         }
         HMC_CFG_RD_TO_WR_DIFF_CHIP {
            set val [expr {[hmc_div_ceil [expr {$tcl_cyc - $tcwl_cyc + ($bl / 2) + 2 + $rd_to_wr_extra_turnaround + $col_to_diff_col_offset}] $phy_hmc_clk_ratio] + $user_rd_to_wr_diff_chip_delta_cyc}]
         }
         HMC_CFG_RD_TO_PCH {
            set val [hmc_div_ceil [expr {$tal_cyc + max($trtp_cyc, 4) + $col_to_row_offset}] $phy_hmc_clk_ratio]
         }
         HMC_CFG_RD_AP_TO_VALID {
            set val $rd_ap_to_valid
         }
         HMC_CFG_WR_TO_WR {
            set val [hmc_div_ceil [expr { int(($bl / 2) + $col_to_col_offset) }] $phy_hmc_clk_ratio]
         }
         HMC_CFG_WR_TO_WR_DIFF_CHIP {
            set val [expr {[hmc_div_ceil [expr { int(($bl / 2) + 2 + $col_to_col_offset) }] $phy_hmc_clk_ratio] + $user_wr_to_wr_diff_chip_delta_cyc}]
         }
         HMC_CFG_WR_TO_RD {
            set val [expr {[hmc_div_ceil [expr {$tcwl_cyc + ($bl / 2) + max($twtr_cyc, 4) + $wr_to_rd_extra_turnaround + $col_to_diff_col_offset}] $phy_hmc_clk_ratio] + $user_wr_to_rd_same_chip_delta_cyc}]
         }
         HMC_CFG_WR_TO_RD_DIFF_CHIP {
            set tmp_wr_to_rd_diff_chip [expr {max(int($tcwl_cyc - $tcl_cyc + ($bl / 2)), 0)}]
            set val [expr {[hmc_div_ceil [expr {max($tmp_wr_to_rd_diff_chip, 1) + 2 + $wr_to_rd_extra_turnaround + $col_to_diff_col_offset}] $phy_hmc_clk_ratio] + $user_wr_to_rd_diff_chip_delta_cyc}]
         }
         HMC_CFG_WR_TO_PCH {
            set val [hmc_div_ceil [expr {$tal_cyc + $tcwl_cyc + ($bl / 2) + $twr_cyc + $col_to_row_offset}] $phy_hmc_clk_ratio]
         }
         HMC_CFG_WR_AP_TO_VALID {
            set val [hmc_div_ceil [expr {$tal_cyc + $tcwl_cyc + ($bl / 2) + $twr_cyc + $trp_cyc + $col_to_row_offset}] $phy_hmc_clk_ratio]
         }
         HMC_CFG_PCH_TO_VALID {
            set val [hmc_div_ceil [expr {max($trc_cyc - $tras_cyc, $trp_cyc) + $row_to_row_offset}] $phy_hmc_clk_ratio]
         }
         HMC_CFG_PCH_ALL_TO_VALID {
            set val [hmc_div_ceil [expr {$trp_cyc + $row_to_row_offset}] $phy_hmc_clk_ratio]
         }
         HMC_CFG_ARF_TO_VALID {
            set val [hmc_div_ceil [expr {$trfc_cyc + $sideband_offset}] $phy_hmc_clk_ratio]
         }
         HMC_CFG_PDN_TO_VALID {
            set val [hmc_div_ceil [expr {($pd_enum == "DDR3_PD_OFF" ? $txpdll_cyc : $txp_cyc) + $sideband_offset}] $phy_hmc_clk_ratio]
         }
         HMC_CFG_SRF_TO_VALID {
            set val [hmc_div_ceil [expr {512 + $sideband_offset}] $phy_hmc_clk_ratio]
         }
         HMC_CFG_SRF_TO_ZQ_CAL {
            set val [hmc_div_ceil [expr {256 + $sideband_offset}] $phy_hmc_clk_ratio]
         }
         HMC_CFG_ARF_PERIOD {
            set val [hmc_div_ceil [expr {$trefi_cyc + $sideband_offset}] $phy_hmc_clk_ratio]
         }
         HMC_CFG_PDN_PERIOD {
            set val [expr {$pdn_en ? [get_parameter_value CTRL_DDR3_AUTO_POWER_DOWN_CYCS] : 0}]
         }
         HMC_CFG_ZQCL_TO_VALID {
            set val [hmc_div_ceil [expr {$tzqoper_cyc + $sideband_offset}] $phy_hmc_clk_ratio]
         }
         HMC_CFG_ZQCS_TO_VALID {
            set val [hmc_div_ceil [expr {$tzqcs_cyc + $sideband_offset}] $phy_hmc_clk_ratio]
         }
         HMC_CFG_MRS_TO_VALID {
            set val [expr {($tmod_cyc - 1)/int($phy_hmc_clk_ratio)/2 + 1}]
         }
         HMC_CFG_MPS_TO_VALID {
            set val 0
         }
         HMC_CFG_MRR_TO_VALID {
            set val 0
         }
         HMC_CFG_MPR_TO_VALID {
            set val 0
         }
         HMC_CFG_MPS_EXIT_CS_TO_CKE {
            set val 0
         }
         HMC_CFG_MPS_EXIT_CKE_TO_CS {
            set val 0
         }
         HMC_CFG_MMR_CMD_TO_VALID {
            set val 16
         }
         HMC_CFG_4_ACT_TO_ACT {
            set val [hmc_div_ceil [expr {$tfaw_cyc + $row_to_row_offset}] $phy_hmc_clk_ratio]
            set val [expr {($val == 5) ? $val : $val - 1}]
         }
         default {
            set val [enum_data $hmc_cfg_enum DEFAULT]
         }
      }
      dict set retval $hmc_cfg_enum $val
   }
   return $retval
}

proc ::altera_emif::ip_arch_nf::ddr3::derive_seq_param_tbl {seq_pt_enums} {

   set retval [dict create]

   foreach seq_pt_enum $seq_pt_enums {
      switch $seq_pt_enum {
         SEQ_PT_READ_LATENCY {
            set val [expr {int([get_parameter_value MEM_READ_LATENCY])}]
         }
         SEQ_PT_WRITE_LATENCY {
            set val [get_parameter_value MEM_WRITE_LATENCY]
         }
         SEQ_PT_NUM_RANKS {
            set val [get_parameter_value MEM_DDR3_TTL_NUM_OF_LOGICAL_RANKS]
         }
         SEQ_PT_NUM_DIMMS {
            set val [get_parameter_value MEM_DDR3_TTL_NUM_OF_DIMMS]
         }
         SEQ_PT_NUM_DQS_WR {
            set val [get_parameter_value MEM_DDR3_TTL_DQS_WIDTH]
         }
         SEQ_PT_NUM_DQS_RD {
            set val [get_parameter_value MEM_DDR3_TTL_DQS_WIDTH]
         }
         SEQ_PT_NUM_DQ {
            set val [get_parameter_value MEM_DDR3_TTL_DQ_WIDTH]
         }
         SEQ_PT_NUM_DM {
            if {[get_parameter_value MEM_DDR3_DM_EN]} {
               set val [get_parameter_value MEM_DDR3_TTL_DM_WIDTH]
            } else {
               set val 0
            }
         }
         SEQ_PT_CK_WIDTH {
            set val [get_parameter_value MEM_DDR3_TTL_CK_WIDTH]
         }
         SEQ_PT_ADDR_WIDTH {
            set val [get_parameter_value MEM_DDR3_TTL_ADDR_WIDTH]
         }
         SEQ_PT_BANK_WIDTH {
            set val [get_parameter_value MEM_DDR3_TTL_BANK_ADDR_WIDTH]
         }
         SEQ_PT_CS_WIDTH {
            set val [get_parameter_value MEM_DDR3_TTL_CS_WIDTH]
         }
         SEQ_PT_CKE_WIDTH {
            set val [get_parameter_value MEM_DDR3_TTL_CKE_WIDTH]
         }
         SEQ_PT_ODT_WIDTH {
            set val [get_parameter_value MEM_DDR3_TTL_ODT_WIDTH]
         }
         SEQ_PT_C_WIDTH { 
            set val [get_parameter_value MEM_DDR3_TTL_RM_WIDTH]
         }
         SEQ_PT_BANK_GROUP_WIDTH {
            set val 0
         }
         SEQ_PT_ADDR_MIRROR {
            set val [get_parameter_value MEM_DDR3_ADDRESS_MIRROR_BITVEC]
         }
         SEQ_PT_ODT_TABLE_LO {
            set val [get_parameter_value MEM_DDR3_SEQ_ODT_TABLE_LO]
         }
         SEQ_PT_ODT_TABLE_HI {
            set val [get_parameter_value MEM_DDR3_SEQ_ODT_TABLE_HI]
         }
         SEQ_PT_NUM_MR {
            continue
         }
         SEQ_PT_NUM_DIMM_MR {
            continue
         }
         SEQ_PT_NUM_LRDIMM_CFG {
            continue
         }
         SEQ_PT_MR_PTR {
            set format_enum [get_parameter_value MEM_DDR3_FORMAT_ENUM]
            set is_rdimm    [expr {$format_enum == "MEM_FORMAT_RDIMM"}]
            set is_lrdimm   [expr {$format_enum == "MEM_FORMAT_LRDIMM"}]
            
            set num_basic_config_words 0
            set num_rdimm_config_words 0
            set num_lrdimm_config_words 0
         
            set mr0 [get_parameter_value MEM_DDR3_MR0]
            set mr1 [get_parameter_value MEM_DDR3_MR1]
            set mr2 [get_parameter_value MEM_DDR3_MR2]
            set mr3 [get_parameter_value MEM_DDR3_MR3]

            if {$is_lrdimm} {
               set lrdimm_ext_config_str [get_parameter_value MEM_DDR3_LRDIMM_EXTENDED_CONFIG]
               set lrdimm_ext_config_str [ string map {0x ""} $lrdimm_ext_config_str]
               set lrdimm_spd_mr  "0x[ string range $lrdimm_ext_config_str end-17 end-16 ]"
               set mr1 [set_bits $mr1 1 1   [expr {$lrdimm_spd_mr & 1}]]           
               set mr1 [set_bits $mr1 2 1   [expr {($lrdimm_spd_mr  >> 2) & 1}]]   
               set mr1 [set_bits $mr1 5 1   [expr {($lrdimm_spd_mr  >> 1) & 1}]]   
               set mr1 [set_bits $mr1 6 1   [expr {($lrdimm_spd_mr  >> 3) & 1}]]   
               set mr1 [set_bits $mr1 9 1   [expr {($lrdimm_spd_mr  >> 4) & 1}]]   
               set mr2 [set_bits $mr2 9 2  [expr {($lrdimm_spd_mr  >> 6) & 3}]]    
            }
            set mrs [list \
               [dict create DBG_NAME "MR0" DBG_VALUE [num2bin $mr0 20] VALUE $mr0] \
               [dict create DBG_NAME "MR1" DBG_VALUE [num2bin $mr1 20] VALUE $mr1] \
               [dict create DBG_NAME "MR2" DBG_VALUE [num2bin $mr2 20] VALUE $mr2] \
               [dict create DBG_NAME "MR3" DBG_VALUE [num2bin $mr3 20] VALUE $mr3] \
               ]

            set num_basic_config_words [llength $mrs]               

            if {$is_rdimm || $is_lrdimm} {
               set rdimm_config [get_parameter_value MEM_DDR3_RDIMM_CONFIG]
               set rdimm_config_length [string length $rdimm_config]

               set rdimm_config_bytes ""
               for {set x 0} {$x < $rdimm_config_length} {incr x 2} {
                  set rdimm_config_byte [string range $rdimm_config $x [expr {$x + 1}]]
                  if {($rdimm_config_byte == "0x") || ($rdimm_config_byte == "0X")} {
                     continue
                  } else {
                     lappend rdimm_config_bytes $rdimm_config_byte
                  }
               }

               set rdimm_config_words ""
               for {set x [expr {[llength $rdimm_config_bytes] - 1}]} {$x >= 0} {incr x -4} {
                  lappend rdimm_config_words [join [lrange $rdimm_config_bytes [expr {$x-3}] $x] ""]
               }

               foreach word $rdimm_config_words {
                  set rdimm_entry_dec [hex2num $word]
                  lappend mrs [dict create DBG_NAME "RDIMM CONTROL WORD" DBG_VALUE [num2bin $rdimm_entry_dec 32] VALUE $rdimm_entry_dec]
               }
               
               set num_rdimm_config_words [llength $rdimm_config_words]
            }

            if {$is_lrdimm} {

               set lrdimm_config_words ""
               for {set idx 0} {$idx < 9} {incr idx} {
                  set ch_idx [expr {$idx * 2}]
                  set ch0 [string index $lrdimm_ext_config_str end-$ch_idx]
                  incr ch_idx
                  set ch1 [string index $lrdimm_ext_config_str end-$ch_idx]

                  if {([string length $ch0] != 1)} {
                     set ch0 "0"
                  }
                  if {([string length $ch1] != 1)} {
                     set ch1 "0"
                  }

                  set ch0_num [hex2num $ch0]
                  set ch1_num [hex2num $ch1]
                  set ch_b76 [expr {($ch1_num >> 2) & 0x3}]
                  set ch_b54 [expr {($ch1_num     ) & 0x3}]
                  set ch_b32 [expr {($ch0_num >> 2) & 0x3}]
                  set ch_b10 [expr {($ch0_num     ) & 0x3}]

                  switch -exact $idx {
                     0 { lappend lrdimm_config_words "01b[format %x $ch1]018[format %x $ch0]"
                     }
                     1 { lappend lrdimm_config_words "01d[format %x $ch1]01c[format %x $ch0]"
                     }
                     2 { lappend lrdimm_config_words "01f[format %x $ch1]01e[format %x $ch0]"
                     }
                     3 { lappend lrdimm_config_words "039[format %x $ch1]038[format %x $ch0]"
                     }
                     4 { lappend lrdimm_config_words "04b[format %x $ch_b76]03b[format %x $ch_b54]" "04a[format %x $ch_b32]03a[format %x $ch_b10]"
                     }
                     5 { lappend lrdimm_config_words "06b[format %x $ch_b76]05b[format %x $ch_b54]" "06a[format %x $ch_b32]05a[format %x $ch_b10]"
                     }
                     6 { lappend lrdimm_config_words "08b[format %x $ch_b76]07b[format %x $ch_b54]" "08a[format %x $ch_b32]07a[format %x $ch_b10]"
                     }
                     7 { lappend lrdimm_config_words "0ab[format %x $ch_b76]09b[format %x $ch_b54]" "0aa[format %x $ch_b32]09a[format %x $ch_b10]"
                     }
                     8 {					}
                  }
               }
               set rtt_nom  [get_parameter_value MEM_DDR3_RTT_NOM_ENUM]
               switch -exact $rtt_nom {
                  "DDR3_RTT_NOM_ODT_DISABLED" { lappend lrdimm_config_words "0300"}
                  "DDR3_RTT_NOM_RZQ_4"        { lappend lrdimm_config_words "0301"}
                  "DDR3_RTT_NOM_RZQ_2"        { lappend lrdimm_config_words "0302"}
                  "DDR3_RTT_NOM_RZQ_6"        { lappend lrdimm_config_words "0303"}
               }

               set rtt_wr  [get_parameter_value MEM_DDR3_RTT_WR_ENUM]
               switch -exact $rtt_wr {
                  "DDR3_RTT_WR_ODT_DISABLED"    { append lrdimm_config_words "0310"}
                  "DDR3_RTT_WR_RZQ_4"           { append lrdimm_config_words "0311"}
                  "DDR3_RTT_WR_RZQ_2"           { append lrdimm_config_words "0312"}
               }


               set rtt_drv  [get_parameter_value MEM_DDR3_DRV_STR_ENUM]
               switch -exact $rtt_drv {
                  "DDR3_DRV_STR_RZQ_6"           { lappend lrdimm_config_words "03200320"}
                  "DDR3_DRV_STR_RZQ_7"           { lappend lrdimm_config_words "03210321"}
               }

               foreach word $lrdimm_config_words {
                  set lrdimm_entry_dec [hex2num $word]
                  lappend mrs [dict create DBG_NAME "LRDIMM CONTROL WORD" DBG_VALUE [num2bin $lrdimm_entry_dec 32] VALUE $lrdimm_entry_dec]
               }
               
               set num_lrdimm_config_words [llength $lrdimm_config_words]
            }

            set val [dict create]
            dict set val PTR                0
            dict set val CONTENT            $mrs
            dict set val ITEM_BYTE_SIZE     4
            dict set val BYTE_SIZE          [expr {4 * [llength $mrs]}]
            
            dict set retval SEQ_PT_NUM_MR [llength $mrs]
            dict set retval SEQ_PT_NUM_DIMM_MR $num_basic_config_words
            
            dict set retval SEQ_PT_NUM_LRDIMM_CFG $num_rdimm_config_words            
         }
         SEQ_PT_DBG_SKIP_STEPS {
            set val 0

            if {![get_parameter_value DIAG_DDR3_CA_LEVEL_EN]} {
               set val [expr {$val | [enum_data SEQ_CONST_CALIB_SKIP_CA_LEVEL]}]
            }
         }
         SEQ_PT_CAL_DATA_PTR {
            set val [::altera_emif::ip_arch_nf::seq_param_tbl::get_cal_data_common_section]

            set cal_trefi [expr {int(ceil([get_parameter_value MEM_DDR3_TREFI_US] * 1000))}]
            set cal_trfc  [expr {int(ceil([get_parameter_value MEM_DDR3_TRFC_NS]))}]
            set cal_addr0 [get_parameter_value DIAG_DDR3_CAL_ADDR0]
            set cal_addr1 [get_parameter_value DIAG_DDR3_CAL_ADDR1]

            dict lappend val CONTENT   [dict create DBG_NAME "CAL_TREFI" DBG_VALUE $cal_trefi VALUE $cal_trefi]
            dict lappend val CONTENT   [dict create DBG_NAME "CAL_TRFC" DBG_VALUE $cal_trfc VALUE $cal_trfc]
            dict lappend val CONTENT   [dict create DBG_NAME "CAL_ADDR0" DBG_VALUE $cal_addr0 VALUE $cal_addr0]
            dict lappend val CONTENT   [dict create DBG_NAME "CAL_ADDR1" DBG_VALUE $cal_addr1 VALUE $cal_addr1]

            set byte_size              [expr {[dict get $val ITEM_BYTE_SIZE] * [llength [dict get $val CONTENT]]}]
            dict set val BYTE_SIZE     $byte_size

            dict set retval SEQ_PT_CAL_DATA_SIZE $byte_size
         }
         SEQ_PT_CAL_DATA_SIZE {
            continue
         }
         default {
            emif_ie "Unknown sequencer parameter table field $seq_pt_enum"
         }
      }
      dict set retval $seq_pt_enum $val
   }
   return $retval
}

proc ::altera_emif::ip_arch_nf::ddr3::get_timing_params {} {

   set retval [dict create]

   set tck_ns [expr {1000.0 / [get_parameter_value PHY_DDR3_MEM_CLK_FREQ_MHZ]}]

   foreach tparam_enum [enums_of_type TPARAM] {

      set val 0

      switch $tparam_enum {
         TPARAM_PROTOCOL {
            set val "DDR3"
         }
         TPARAM_NUM_RANKS {
            set val [get_parameter_value "MEM_DDR3_NUM_OF_LOGICAL_RANKS"]
         }
         TPARAM_SLEW_RATE_DRAM {
            set val [get_parameter_value BOARD_DDR3_RDATA_SLEW_RATE]
         }
         TPARAM_SLEW_RATE_DRAM_CLOCK {
            set val [get_parameter_value BOARD_DDR3_RCLK_SLEW_RATE]
         }
         TPARAM_VIN_MS {
            set val [expr {[get_parameter_value MEM_DDR3_TDS_AC_MV] / 1000.0}]
         }
         TPARAM_VIN_MH {
            set val [expr {[get_parameter_value MEM_DDR3_TDH_DC_MV] / 1000.0}]
         }
         TPARAM_SLEW_RATE_PHY {
            set val [get_parameter_value BOARD_DDR3_WDATA_SLEW_RATE]
         }
         TPARAM_SLEW_RATE_PHY_CLOCK {
            set val [get_parameter_value BOARD_DDR3_WCLK_SLEW_RATE]
         }
         TPARAM_SLEW_RATE_CA {
            set val [get_parameter_value BOARD_DDR3_AC_SLEW_RATE]
         }
         TPARAM_SLEW_RATE_CLOCK {
            set val [get_parameter_value BOARD_DDR3_CK_SLEW_RATE]
         }
         TPARAM_UI {
            set val [round_num $tck_ns 3]
         }
         TPARAM_TCK {
            set speedbin_enum      [get_parameter_value "MEM_DDR3_SPEEDBIN_ENUM"]
            set mem_fmax           [enum_data $speedbin_enum FMAX_MHZ]
            set val                [round_num [expr 1.0/$mem_fmax*1000.0] 3]
         }
         TPARAM_TDQSQ {
            set val [expr {[get_parameter_value MEM_DDR3_TDQSQ_PS] / 1000.0}]
         }
         TPARAM_TQH {
            set val [get_parameter_value MEM_DDR3_TQH_CYC]
         }
         TPARAM_TDS {
            set val [expr {([get_parameter_value BOARD_DDR3_TDS_DERATING_PS] + [get_parameter_value MEM_DDR3_TDS_PS]) / 1000.0}]
         }
         TPARAM_TDH {
            set val [expr {([get_parameter_value BOARD_DDR3_TDH_DERATING_PS] + [get_parameter_value MEM_DDR3_TDH_PS]) / 1000.0}]
         }
         TPARAM_TIS {
            set val [expr {([get_parameter_value BOARD_DDR3_TIS_DERATING_PS] + [get_parameter_value MEM_DDR3_TIS_PS]) / 1000.0}]
         }
         TPARAM_TIH {
            set val [expr {([get_parameter_value BOARD_DDR3_TIH_DERATING_PS] + [get_parameter_value MEM_DDR3_TIH_PS]) / 1000.0}]
         }
         TPARAM_TDQSCK {
            set val [expr {[get_parameter_value MEM_DDR3_TDQSCK_PS] / 1000.0}]
         }
         TPARAM_TDQSS {
            set val [get_parameter_value MEM_DDR3_TDQSS_CYC]
         }
         TPARAM_TWLS {
            set val [expr {[get_parameter_value MEM_DDR3_TWLS_PS] / 1000.0}]
         }
         TPARAM_TWLH {
            set val [expr {[get_parameter_value MEM_DDR3_TWLH_PS] / 1000.0}]
         }
         TPARAM_TDSS {
            set val [get_parameter_value MEM_DDR3_TDSS_CYC]
         }
         TPARAM_TDSH {
            set val [get_parameter_value MEM_DDR3_TDSH_CYC]
         }
         TPARAM_BD_PKG_SKEW {
            set val [get_parameter_value BOARD_DDR3_SKEW_WITHIN_DQS_NS]
         }
         TPARAM_CA_BD_PKG_SKEW {
            set val [get_parameter_value BOARD_DDR3_SKEW_WITHIN_AC_NS]
         }
         TPARAM_CA_TO_CK_BD_PKG_SKEW {
            set val [get_parameter_value BOARD_DDR3_AC_TO_CK_SKEW_NS]
         }
         TPARAM_RD_ISI {
            set val [get_parameter_value BOARD_DDR3_RDATA_ISI_NS]
         }
         TPARAM_WR_ISI {
            set val [get_parameter_value BOARD_DDR3_WDATA_ISI_NS]
         }
         TPARAM_CA_ISI {
            set val [get_parameter_value BOARD_DDR3_AC_ISI_NS]
         }
         TPARAM_DQSG_ISI {
            set val [get_parameter_value BOARD_DDR3_RCLK_ISI_NS]
         }
         TPARAM_WL_ISI {
            set val [get_parameter_value BOARD_DDR3_WCLK_ISI_NS]
         }
         TPARAM_DQS_BOARD_SKEW {
            set val [get_parameter_value BOARD_DDR3_SKEW_BETWEEN_DQS_NS]
         }
         TPARAM_DQS_TO_CK_BOARD_SKEW {
            set val [get_parameter_value BOARD_DDR3_DQS_TO_CK_SKEW_NS]
         }
         TPARAM_X4 {
            set val [expr {[get_dqs_bus_mode] == "DQS_BUS_MODE_X4" ? 1 : 0}]
         }
         TPARAM_IS_DLL_ON {
            set val [expr {[get_parameter_value DLL_MODE] == "ctl_dynamic" ? 1 : 0}]
         }
         TPARAM_OCT_RECAL {
            if {[get_parameter_value PHY_PERIODIC_OCT_RECAL]} {
               set val 1
            } else {
               set val 0
            }
         }
         TPARAM_RDBI {
            set val 0
         }
         TPARAM_WDBI {
            set val 0
         }
         TPARAM_TERMINATION_LESS_THAN_120 {
            set data_in_ohm   [enum_data [get_parameter_value PHY_DDR3_DATA_IN_MODE_ENUM] OHM]
            set val [expr {$data_in_ohm < 120 ? 1 : 0}]
         }
         TPARAM_IS_COMPONENT {
            set format_enum    [get_parameter_value MEM_DDR3_FORMAT_ENUM]
            if {$format_enum == "MEM_FORMAT_DISCRETE"} {
               set val 1
            } else {
               set val 0
            }
         }
         default {
            emif_ie "Unrecognized timing param $tparam_enum"
         }
      }
      dict set retval $tparam_enum $val
   }
   return $retval
}

proc ::altera_emif::ip_arch_nf::ddr3::is_phy_tracking_enabled {} {
   return [::altera_emif::ip_arch_nf::ddrx::is_phy_tracking_enabled]
}

proc ::altera_emif::ip_arch_nf::ddr3::is_phy_shadow_register_disabled {} {
   return 0
}


proc ::altera_emif::ip_arch_nf::ddr3::_get_mem_ports {} {
   set ports [list]

   set ac_par_en       [get_parameter_value MEM_DDR3_AC_PAR_EN]
   set ck_width        [get_parameter_value MEM_DDR3_TTL_CK_WIDTH]
   set addr_width      [get_parameter_value MEM_DDR3_TTL_ADDR_WIDTH]
   set bank_addr_width [get_parameter_value MEM_DDR3_TTL_BANK_ADDR_WIDTH]
   set cke_width       [get_parameter_value MEM_DDR3_TTL_CKE_WIDTH]
   set cs_width        [get_parameter_value MEM_DDR3_TTL_CS_WIDTH]
   set rm_width        [get_parameter_value MEM_DDR3_TTL_RM_WIDTH]
   set odt_width       [get_parameter_value MEM_DDR3_TTL_ODT_WIDTH]
   set dqs_width       [get_parameter_value MEM_DDR3_TTL_DQS_WIDTH]
   set dq_width        [get_parameter_value MEM_DDR3_TTL_DQ_WIDTH]
   set dm_en           [get_parameter_value MEM_DDR3_DM_EN]
   set dm_width        [get_parameter_value MEM_DDR3_TTL_DM_WIDTH]
   set config_enum     [get_parameter_value PHY_DDR3_CONFIG_ENUM]
   set rm_en           [expr {$rm_width > 0 ? 1: 0}]

   lappend ports {*}[create_port  true        PORT_MEM_CK         $ck_width           [get_db_configs   PIN_RATE_DDR  $config_enum  DB_PIN_TYPE_CK       ]]
   lappend ports {*}[create_port  true        PORT_MEM_CK_N       $ck_width           [get_db_configs   PIN_RATE_DDR  $config_enum  DB_PIN_TYPE_CK_N     ]]
   lappend ports {*}[create_port  true        PORT_MEM_A          $addr_width         [get_db_configs   PIN_RATE_SDR  $config_enum  DB_PIN_TYPE_AC       ]]
   lappend ports {*}[create_port  true        PORT_MEM_BA         $bank_addr_width    [get_db_configs   PIN_RATE_SDR  $config_enum  DB_PIN_TYPE_AC       ]]
   lappend ports {*}[create_port  true        PORT_MEM_CKE        $cke_width          [get_db_configs   PIN_RATE_SDR  $config_enum  DB_PIN_TYPE_AC       ]]
   lappend ports {*}[create_port  true        PORT_MEM_CS_N       $cs_width           [get_db_configs   PIN_RATE_SDR  $config_enum  DB_PIN_TYPE_AC       ]]
   lappend ports {*}[create_port  $rm_en      PORT_MEM_RM         $rm_width           [get_db_configs   PIN_RATE_SDR  $config_enum  DB_PIN_TYPE_AC       ]]
   lappend ports {*}[create_port  true        PORT_MEM_ODT        $odt_width          [get_db_configs   PIN_RATE_SDR  $config_enum  DB_PIN_TYPE_AC       ]]
   lappend ports {*}[create_port  true        PORT_MEM_RESET_N    1                   [get_db_configs   PIN_RATE_SDR  $config_enum  DB_PIN_TYPE_AC       ]]
   lappend ports {*}[create_port  true        PORT_MEM_WE_N       1                   [get_db_configs   PIN_RATE_SDR  $config_enum  DB_PIN_TYPE_AC       ]]
   lappend ports {*}[create_port  true        PORT_MEM_RAS_N      1                   [get_db_configs   PIN_RATE_SDR  $config_enum  DB_PIN_TYPE_AC       ]]
   lappend ports {*}[create_port  true        PORT_MEM_CAS_N      1                   [get_db_configs   PIN_RATE_SDR  $config_enum  DB_PIN_TYPE_AC       ]]
   lappend ports {*}[create_port  $ac_par_en  PORT_MEM_PAR        1                   [get_db_configs   PIN_RATE_SDR  $config_enum  DB_PIN_TYPE_AC       ]]
   lappend ports {*}[create_port  $ac_par_en  PORT_MEM_ALERT_N    1                   [get_db_configs   PIN_RATE_SDR  $config_enum  DB_PIN_TYPE_ALERT_N  ]]
   lappend ports {*}[create_port  true        PORT_MEM_DQS        $dqs_width          [get_db_configs   PIN_RATE_DDR  $config_enum  DB_PIN_TYPE_DQS      ]]
   lappend ports {*}[create_port  true        PORT_MEM_DQS_N      $dqs_width          [get_db_configs   PIN_RATE_DDR  $config_enum  DB_PIN_TYPE_DQS_N    ]]
   lappend ports {*}[create_port  true        PORT_MEM_DQ         $dq_width           [get_db_configs   PIN_RATE_DDR  $config_enum  DB_PIN_TYPE_DQ       ]]
   lappend ports {*}[create_port  $dm_en      PORT_MEM_DM         $dm_width           [get_db_configs   PIN_RATE_DDR  $config_enum  DB_PIN_TYPE_DM       ]]

   return $ports
}

proc ::altera_emif::ip_arch_nf::ddr3::_get_afi_ports {} {

   set ports [altera_emif::ip_arch_nf::util::get_common_afi_ports]

   set clk_ratios        [get_clk_ratios]
   set sdr_ratio         [dict get $clk_ratios C2P_P2C]
   set ddr_ratio         [expr {$sdr_ratio * 2}]

   set addr_width        [expr {[get_parameter_value MEM_DDR3_TTL_ADDR_WIDTH]      * $sdr_ratio}]
   set bank_addr_width   [expr {[get_parameter_value MEM_DDR3_TTL_BANK_ADDR_WIDTH] * $sdr_ratio}]
   set cke_width         [expr {[get_parameter_value MEM_DDR3_TTL_CKE_WIDTH]       * $sdr_ratio}]
   set cs_width          [expr {[get_parameter_value MEM_DDR3_TTL_CS_WIDTH]        * $sdr_ratio}]
   set rm_width          [expr {[get_parameter_value MEM_DDR3_TTL_RM_WIDTH]        * $sdr_ratio}]
   set odt_width         [expr {[get_parameter_value MEM_DDR3_TTL_ODT_WIDTH]       * $sdr_ratio}]
   set data_width        [expr {[get_parameter_value MEM_DDR3_TTL_DQ_WIDTH]        * $ddr_ratio}]
   set dm_width          [expr {[get_parameter_value MEM_DDR3_TTL_DM_WIDTH]        * $ddr_ratio}]

   set ac_par_en         [get_parameter_value MEM_DDR3_AC_PAR_EN]
   set dm_en             [get_parameter_value MEM_DDR3_DM_EN]
   set rm_en             [expr {$rm_width > 0 ? 1: 0}]

   set logical_ranks     [get_parameter_value MEM_DDR3_TTL_NUM_OF_LOGICAL_RANKS]
   emif_assert {$logical_ranks >= 1 && $logical_ranks <= 4}
   set rank_en           [expr {$logical_ranks > 1 ? 1 : 0}]
   set rank_width        [expr {$logical_ranks * $sdr_ratio}]

   lappend ports {*}[create_port  true        PORT_AFI_ADDR                     $addr_width          ]
   lappend ports {*}[create_port  true        PORT_AFI_BA                       $bank_addr_width     ]
   lappend ports {*}[create_port  true        PORT_AFI_CKE                      $cke_width           ]
   lappend ports {*}[create_port  true        PORT_AFI_CS_N                     $cs_width            ]
   lappend ports {*}[create_port  $rm_en      PORT_AFI_RM                       $rm_width            ]
   lappend ports {*}[create_port  true        PORT_AFI_ODT                      $odt_width           ]
   lappend ports {*}[create_port  true        PORT_AFI_RAS_N                    $sdr_ratio           ]
   lappend ports {*}[create_port  true        PORT_AFI_CAS_N                    $sdr_ratio           ]
   lappend ports {*}[create_port  true        PORT_AFI_WE_N                     $sdr_ratio           ]
   lappend ports {*}[create_port  true        PORT_AFI_RST_N                    $sdr_ratio           ]
   lappend ports {*}[create_port  $ac_par_en  PORT_AFI_PAR                      $sdr_ratio           ]
   lappend ports {*}[create_port  $dm_en      PORT_AFI_DM                       $dm_width            ]
   lappend ports {*}[create_port  true        PORT_AFI_DQS_BURST                $sdr_ratio           ]
   lappend ports {*}[create_port  true        PORT_AFI_WDATA_VALID              $sdr_ratio           ]
   lappend ports {*}[create_port  true        PORT_AFI_WDATA                    $data_width          ]
   lappend ports {*}[create_port  true        PORT_AFI_RDATA_EN_FULL            $sdr_ratio           ]
   lappend ports {*}[create_port  true        PORT_AFI_RDATA                    $data_width          ]
   lappend ports {*}[create_port  true        PORT_AFI_RDATA_VALID              $sdr_ratio           ]
   lappend ports {*}[create_port  $rank_en    PORT_AFI_RRANK                    $rank_width          ]
   lappend ports {*}[create_port  $rank_en    PORT_AFI_WRANK                    $rank_width          ]

   lappend ports {*}[create_port  false       PORT_AFI_ALERT_N                  $sdr_ratio           ]

   return $ports
}

proc ::altera_emif::ip_arch_nf::ddr3::_get_ctrl_ast_properties {is_write} {
   set props [dict create]

   set clk_ratios         [get_clk_ratios]
   set c2p_p2c_clk_ratio  [dict get $clk_ratios C2P_P2C]
   set ecc_en             [get_parameter_value CTRL_ECC_EN]
   set burst_length       [get_parameter_value MEM_BURST_LENGTH]
   set dm_en              [get_parameter_value MEM_DDR3_DM_EN]

   set dq_width           [get_parameter_value MEM_DDR3_DQ_WIDTH]
   set dm_width           [get_parameter_value MEM_DDR3_DM_WIDTH]

   set avl_to_dq_width_ratio   [expr {2 * $c2p_p2c_clk_ratio}]
   set data_width              [expr {$dq_width * $avl_to_dq_width_ratio}]
   set be_width                [expr {$dm_width * $avl_to_dq_width_ratio}]

   if {$is_write && $ecc_en && $dm_en} {
      set data_width [expr {$data_width + $be_width}]
   }

   set symbol_width            $data_width
   set symbols_per_word        [expr {$data_width / $symbol_width}]

   dict set props WORD_WIDTH            $data_width
   dict set props SYMBOL_WIDTH          $symbol_width
   dict set props SYMBOLS_PER_WORD      $symbols_per_word
   dict set props BYTE_ENABLE_WIDTH     $be_width
   dict set props USE_BYTE_ENABLE       $dm_en

   return $props
}

proc ::altera_emif::ip_arch_nf::ddr3::_get_ctrl_ast_cmd_properties {} {
   set props [dict create]

   dict set props WORD_WIDTH            58
   dict set props SYMBOL_WIDTH          1
   dict set props SYMBOLS_PER_WORD      58
   dict set props BYTE_ENABLE_WIDTH     0
   dict set props USE_BYTE_ENABLE       false

   return $props
}

proc ::altera_emif::ip_arch_nf::ddr3::_get_ctrl_ast_cmd_ports {} {
   set ports [list]

   set props             [_get_ctrl_ast_cmd_properties]
   set data_width        [dict get $props WORD_WIDTH]

   lappend ports {*}[create_port  true        PORT_CTRL_AST_CMD_VALID     1                 ]
   lappend ports {*}[create_port  true        PORT_CTRL_AST_CMD_READY     1                 ]
   lappend ports {*}[create_port  true        PORT_CTRL_AST_CMD_DATA      $data_width       ]

   return $ports
}

proc ::altera_emif::ip_arch_nf::ddr3::_get_ctrl_ast_wr_ports {} {
   set ports [list]

   set props             [_get_ctrl_ast_properties true]
   set data_width        [dict get $props WORD_WIDTH]

   lappend ports {*}[create_port  true        PORT_CTRL_AST_WR_VALID      1                  ]
   lappend ports {*}[create_port  true        PORT_CTRL_AST_WR_READY      1                  ]
   lappend ports {*}[create_port  true        PORT_CTRL_AST_WR_DATA       $data_width        ]

   return $ports
}

proc ::altera_emif::ip_arch_nf::ddr3::_get_ctrl_ast_rd_ports {} {
   set ports [list]
   set props          [_get_ctrl_ast_properties false]
   set data_width     [dict get $props WORD_WIDTH]

   lappend ports {*}[create_port  true        PORT_CTRL_AST_RD_VALID      1                ]
   lappend ports {*}[create_port  true        PORT_CTRL_AST_RD_READY      1                ]
   lappend ports {*}[create_port  true        PORT_CTRL_AST_RD_DATA       $data_width      ]

   return $ports
}

proc ::altera_emif::ip_arch_nf::ddr3::_get_ctrl_amm_properties {} {
   set props [dict create]

   set clk_ratios            [get_clk_ratios]
   set c2p_p2c_clk_ratio     [dict get $clk_ratios C2P_P2C]
   set enable_ecc            [get_parameter_value CTRL_ECC_EN]
   set dq_per_dqs            [get_parameter_value MEM_DDR3_DQ_PER_DQS]
   set dm_en                 [get_parameter_value MEM_DDR3_DM_EN]

   set dq_width              [get_parameter_value MEM_DDR3_DQ_WIDTH]
   set dm_width              [get_parameter_value MEM_DDR3_DM_WIDTH]
   set row_addr_width        [get_parameter_value MEM_DDR3_ROW_ADDR_WIDTH]
   set col_addr_width        [get_parameter_value MEM_DDR3_COL_ADDR_WIDTH]
   set bank_addr_width       [get_parameter_value MEM_DDR3_BANK_ADDR_WIDTH]
   set num_of_physical_ranks [get_parameter_value MEM_DDR3_NUM_OF_PHYSICAL_RANKS]

   set avl_to_dq_width_ratio   [expr {2 * $c2p_p2c_clk_ratio}]
   set data_width              [expr {$dq_width * $avl_to_dq_width_ratio}]
   set be_width                [expr {$dm_width * $avl_to_dq_width_ratio}]

   if {$enable_ecc} {
      set ecc_extra_dq_width      [expr {int(ceil($dq_width * 1.0 / 72)) * 8}]
      set ecc_extra_dm_width      [expr {$ecc_extra_dq_width / $dq_per_dqs}]
      set ecc_extra_data_width    [expr {$ecc_extra_dq_width * $c2p_p2c_clk_ratio * 2}]
      set ecc_extra_be_width      [expr {$ecc_extra_dm_width * $c2p_p2c_clk_ratio * 2}]
      set data_width              [expr {$data_width - $ecc_extra_data_width}]
      set be_width                [expr {$be_width - $ecc_extra_be_width}]
   }

   set symbol_width            8

   set symbols_per_word        [expr {$data_width / $symbol_width}]
   set word_address_width      [expr {$row_addr_width + $col_addr_width + $bank_addr_width + int(ceil([log2 $num_of_physical_ranks])) - int(ceil([log2 $avl_to_dq_width_ratio])) }]
   set symbol_address_width    [expr {$word_address_width + int(ceil([log2 $symbols_per_word])) }]

   set burst_count_width       7


   if {$c2p_p2c_clk_ratio == 4} {
      set word_address_divisible_by 1
      set burst_count_divisible_by 1

   } elseif {$c2p_p2c_clk_ratio == 2} {
      if {$dm_en} {
         set word_address_divisible_by 1
         set burst_count_divisible_by 1
      } else {
         set word_address_divisible_by 2
         set burst_count_divisible_by 2
      }
   } else {
      emif_ie "Code path does not support c2p_p2c_clk_ratio == $c2p_p2c_clk_ratio"
   }

   dict set props WORD_WIDTH                   $data_width
   dict set props SYMBOL_WIDTH                 $symbol_width
   dict set props SYMBOLS_PER_WORD             $symbols_per_word
   dict set props BYTE_ENABLE_WIDTH            $be_width
   dict set props USE_BYTE_ENABLE              $dm_en
   dict set props WORD_ADDRESS_WIDTH           $word_address_width
   dict set props SYMBOL_ADDRESS_WIDTH         $symbol_address_width
   dict set props BURST_COUNT_WIDTH            $burst_count_width
   dict set props WORD_ADDRESS_DIVISIBLE_BY    $word_address_divisible_by
   dict set props BURST_COUNT_DIVISIBLE_BY     $burst_count_divisible_by

   return $props
}

proc ::altera_emif::ip_arch_nf::ddr3::_get_ctrl_amm_ports {} {
   set ports [list]

   set props [_get_ctrl_amm_properties]

   set data_width    [dict get $props WORD_WIDTH]
   set be_width      [dict get $props BYTE_ENABLE_WIDTH]
   set use_be        [dict get $props USE_BYTE_ENABLE]
   set bcount_width  [dict get $props BURST_COUNT_WIDTH]

   set address_width [dict get $props WORD_ADDRESS_WIDTH]

   lappend ports {*}[create_port  true        PORT_CTRL_AMM_READY         1                ]
   lappend ports {*}[create_port  true        PORT_CTRL_AMM_READ          1                ]
   lappend ports {*}[create_port  true        PORT_CTRL_AMM_WRITE         1                ]
   lappend ports {*}[create_port  true        PORT_CTRL_AMM_ADDRESS       $address_width   ]
   lappend ports {*}[create_port  true        PORT_CTRL_AMM_RDATA         $data_width      ]
   lappend ports {*}[create_port  true        PORT_CTRL_AMM_WDATA         $data_width      ]
   lappend ports {*}[create_port  true        PORT_CTRL_AMM_BCOUNT        $bcount_width    ]
   lappend ports {*}[create_port  $use_be     PORT_CTRL_AMM_BYTEEN        $be_width        ]
   lappend ports {*}[create_port  false       PORT_CTRL_AMM_BEGINXFER     1                ]
   lappend ports {*}[create_port  true        PORT_CTRL_AMM_RDATA_VALID   1                ]

   return $ports
}

proc ::altera_emif::ip_arch_nf::ddr3::_get_ctrl_user_refresh_ports {} {
   set ports [list]

   set bank [get_parameter_value DIAG_EXPOSE_DFT_SIGNALS]

   lappend ports {*}[create_port  true        PORT_CTRL_USER_REFRESH_REQ  "default"        ]
   lappend ports {*}[create_port  true        PORT_CTRL_USER_REFRESH_ACK  "default"        ]
   lappend ports {*}[create_port  $bank       PORT_CTRL_USER_REFRESH_BANK "default"        ]

   return $ports
}

proc ::altera_emif::ip_arch_nf::ddr3::_init {} {
}

::altera_emif::ip_arch_nf::ddr3::_init

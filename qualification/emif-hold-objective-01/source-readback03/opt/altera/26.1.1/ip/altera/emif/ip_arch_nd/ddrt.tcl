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


package provide altera_emif::ip_arch_nd::ddrt 0.1

package require altera_emif::util::messaging
package require altera_emif::util::qini
package require altera_emif::util::hwtcl_utils
package require altera_emif::util::math
package require altera_emif::util::enums
package require altera_emif::util::device_family

package require altera_emif::arch_common::util

package require altera_emif::ip_arch_nd::enum_defs_ac_pin_mapping
package require altera_emif::ip_arch_nd::util
package require altera_emif::ip_arch_nd::ddrx

namespace eval ::altera_emif::ip_arch_nd::ddrt:: {

   namespace import ::altera_emif::util::messaging::*
   namespace import ::altera_emif::util::qini::*
   namespace import ::altera_emif::util::math::*
   namespace import ::altera_emif::util::enums::*
   namespace import ::altera_emif::util::hwtcl_utils::*
   namespace import ::altera_emif::util::device_family::*
   namespace import ::altera_emif::ip_arch_nd::util::*
   namespace import ::altera_emif::ip_arch_nd::ddrx::*


}


proc ::altera_emif::ip_arch_nd::ddrt::get_dqs_bus_mode {} {
   return [::altera_emif::ip_arch_nd::ddrx::get_dqs_bus_mode]
}

proc ::altera_emif::ip_arch_nd::ddrt::get_interface_ports {if_enum} {
   switch $if_enum {
      IF_MEM {
         return [_get_mem_ports]
      }
      IF_AFI {
         return [_get_afi_ports]
      }
      IF_AFI_MEM_CLK_DISABLE {
         return [_get_afi_mem_clk_disable_ports]
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

proc ::altera_emif::ip_arch_nd::ddrt::is_ctrl_sideband_interface_enabled {if_enum} {
   return 0
}

proc ::altera_emif::ip_arch_nd::ddrt::get_interface_properties {if_enum} {
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

proc ::altera_emif::ip_arch_nd::ddrt::get_ac_pin_map_scheme {} {

   set retval [dict create]

   set format_enum    [get_parameter_value MEM_DDRT_FORMAT_ENUM]
   set ping_pong_en   [get_parameter_value PHY_DDRT_PING_PONG_EN]
   set ck_width       [get_parameter_value MEM_DDRT_TTL_CK_WIDTH]
   set chip_id_width  [get_parameter_value MEM_DDRT_TTL_CHIP_ID_WIDTH]
   set row_width      [get_parameter_value MEM_DDRT_ROW_ADDR_WIDTH]
   set num_of_dimms   [get_parameter_value MEM_DDRT_NUM_OF_DIMMS]

   if {$ping_pong_en} {
      set cke_width 4
      set cs_width 4
      set odt_width 4
      set gnt_n_width 4
      set req_n_width 4
      set err_n_width 4
      set erid_width 4
   } else {
      set cke_width      [get_parameter_value MEM_DDRT_TTL_CKE_WIDTH]
      set cs_width       [get_parameter_value MEM_DDRT_TTL_CS_WIDTH]
      set odt_width      [get_parameter_value MEM_DDRT_TTL_ODT_WIDTH]
      set gnt_n_width    [get_parameter_value MEM_DDRT_TTL_GNT_N_WIDTH]
      set req_n_width    [get_parameter_value MEM_DDRT_TTL_REQ_N_WIDTH]
      set err_n_width    [get_parameter_value MEM_DDRT_TTL_ERR_N_WIDTH]
   }

   dict set retval ENUM "DDRT_AC_PM_0_1_2_3_${num_of_dimms}DIMM"
   dict set retval HMC_DIMM_TYPE_STR "dimm_type_udimm"
   return $retval
}

proc ::altera_emif::ip_arch_nd::ddrt::get_resource_consumption {} {
   set lanes_per_tile [::altera_emif::util::device_family::get_family_trait FAMILY_TRAIT_LANES_PER_TILE]

   set is_hps          [get_is_hps]
   set ecc_en          [get_parameter_value CTRL_ECC_EN]
   set dqs_width       [get_parameter_value MEM_DDRT_TTL_DQS_WIDTH]
   set ping_pong_en    [get_parameter_value PHY_DDRT_PING_PONG_EN]
   set is_dense_x4     [expr {[get_dqs_bus_mode] == "DQS_BUS_MODE_X4" ? 1 : 0}]

   set ac_pm_scheme    [get_ac_pin_map_scheme]
   set ac_pm_enum      [dict get $ac_pm_scheme ENUM]
   set num_ac_lanes    [enum_data $ac_pm_enum LANES_USED]

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

proc ::altera_emif::ip_arch_nd::ddrt::_get_alert_n_placement_scheme {} {

   set extra_configs_str    [get_parameter_value DIAG_EXTRA_CONFIGS]
   set extra_configs        [parse_extra_configs $extra_configs_str]

   set is_dense_x4          [expr {[get_dqs_bus_mode] == "DQS_BUS_MODE_X4" ? 1 : 0}]

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

   } elseif {[get_parameter_value "MEM_DDRT_ALERT_N_PLACEMENT_ENUM"] == "DDRT_ALERT_N_PLACEMENT_AC_LANES"} {
      set place_in_ac_lane true
      set ac_lane_idx [get_parameter_value "MEM_DDRT_ALERT_N_AC_LANE"]
      set ac_lane_pin_idx  [get_parameter_value "MEM_DDRT_ALERT_N_AC_PIN"]

   } elseif {[get_parameter_value "MEM_DDRT_ALERT_N_PLACEMENT_ENUM"] == "DDRT_ALERT_N_PLACEMENT_DATA_LANES"} {
      set place_in_dqs_group true
      set dqs_group [get_parameter_value "MEM_DDRT_ALERT_N_DQS_GROUP"]

   } else {
      if {$is_dense_x4} {
         set place_in_ac_lane true
   } else {
      set place_in_dqs_group true
         set dqs_group 0
      }
   }

   set retval [dict create]
   dict set retval PLACE_IN_AC_LANE   $place_in_ac_lane
   dict set retval PLACE_IN_DQS_GROUP $place_in_dqs_group
   dict set retval DQS_GROUP          $dqs_group
   dict set retval AC_LANE_IDX        $ac_lane_idx
   dict set retval AC_LANE_PIN_IDX    $ac_lane_pin_idx

   return $retval
}

proc ::altera_emif::ip_arch_nd::ddrt::alloc_mem_pins {mem_ports_name} {

   upvar 1 $mem_ports_name mem_ports
   set tiles [dict create]

   set lanes_per_tile [::altera_emif::util::device_family::get_family_trait FAMILY_TRAIT_LANES_PER_TILE]
   set pins_per_lane  [::altera_emif::util::device_family::get_family_trait FAMILY_TRAIT_PINS_PER_LANE]
   set pins_per_tile  [expr {$lanes_per_tile * $pins_per_lane}]

   set ping_pong_en      [get_parameter_value PHY_DDRT_PING_PONG_EN]
   set dqs_width         [get_parameter_value MEM_DDRT_TTL_DQS_WIDTH]
   set dq_per_dqs        [get_parameter_value MEM_DDRT_DQ_PER_DQS]
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
   set ac_tile_i       [expr {int(($num_tiles - 1) / 2)}]
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

      if {$type_enum == "PORT_MEM_CK_BIDIR" || \
          $type_enum == "PORT_MEM_CK_BIDIR_N" || \
          $type_enum == "PORT_MEM_A" || \
          $type_enum == "PORT_MEM_ACT_N" || \
          $type_enum == "PORT_MEM_BA" || \
          $type_enum == "PORT_MEM_BG" || \
          $type_enum == "PORT_MEM_C" || \
          $type_enum == "PORT_MEM_CKE" || \
          $type_enum == "PORT_MEM_ODT" || \
          $type_enum == "PORT_MEM_GNT_N" || \
          $type_enum == "PORT_MEM_REQ_N" || \
          $type_enum == "PORT_MEM_ERR_N" || \
          $type_enum == "PORT_MEM_CS_N" || \
          $type_enum == "PORT_MEM_RM" || \
          $type_enum == "PORT_MEM_PAR" || \
          $type_enum == "PORT_MEM_RESET_N"} {

         set remapped_bus_i $bus_i
         if {$ping_pong_en} {
            if {$bus_i == 1 && [dict get $port BUS_WIDTH] == 2} {
               if {$type_enum == "PORT_MEM_CS_N" || $type_enum == "PORT_MEM_ODT" || $type_enum == "PORT_MEM_CKE" ||  $type_enum == "PORT_MEM_GNT_N"|| $type_enum == "PORT_MEM_REQ_N"|| $type_enum == "PORT_MEM_ERR_N" } {
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
                $type_enum == "PORT_MEM_DBI_N" || \
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
         } elseif {$type_enum == "PORT_MEM_DBI_N"} {
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

         } else {
            set tile_i $ac_tile_i

            set found 0
            for {set lane_i 0} {$lane_i < $num_ac_lanes} {incr lane_i} {
               for {set pin_i 0} {$pin_i < $pins_per_lane} {incr pin_i} {
                  if {$lane_i != 2 || $pin_i > 2} {
                     if {![dict exists $tiles $tile_i $lane_i $pin_i]} {
                        set found 1
                     }
                  }
                  if {$found} break
               }
               if {$found} break
            }

            if {!$found} {
               set lane_i 2
               set pin_i 2
            }
         }

         if {$lane_i >= $num_ac_lanes} {
            post_ipgen_e_msg MSG_INVALID_ALERT_N_AC_LANE [list $lane_i [expr {$num_ac_lanes-1}]]
         }

         if {[dict exists $tiles $tile_i $lane_i $pin_i]} {
            post_ipgen_e_msg MSG_ALERT_N_AC_PIN_OCCUPIED [list $pin_i $lane_i]
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

proc ::altera_emif::ip_arch_nd::ddrt::assign_io_settings {ports_name} {
   upvar 1 $ports_name ports

   set io_voltage          [get_parameter_value PHY_DDRT_IO_VOLTAGE]
   set ac_io_std_enum      [get_parameter_value PHY_DDRT_AC_IO_STD_ENUM]
   set ac_mode_enum        [get_parameter_value PHY_DDRT_AC_MODE_ENUM]
   set ac_in_mode_enum     [get_parameter_value PHY_DDRT_AC_IN_MODE_ENUM]
   set ac_slew_rate_enum   [get_parameter_value PHY_DDRT_AC_SLEW_RATE_ENUM]
   set ck_io_std_enum      [get_parameter_value PHY_DDRT_CK_IO_STD_ENUM]
   set ck_mode_enum        [get_parameter_value PHY_DDRT_CK_MODE_ENUM]
   set ck_slew_rate_enum   [get_parameter_value PHY_DDRT_CK_SLEW_RATE_ENUM]
   set data_io_std_enum    [get_parameter_value PHY_DDRT_DATA_IO_STD_ENUM]
   set data_in_mode_enum   [get_parameter_value PHY_DDRT_DATA_IN_MODE_ENUM]
   set data_out_mode_enum  [get_parameter_value PHY_DDRT_DATA_OUT_MODE_ENUM]
   set ref_clk_io_std_enum [get_parameter_value PHY_DDRT_PLL_REF_CLK_IO_STD_ENUM]
   set rzq_io_std_enum     [get_parameter_value PHY_DDRT_RZQ_IO_STD_ENUM]

   set ac_cal_oct          [get_parameter_value PHY_AC_CALIBRATED_OCT]
   set ck_cal_oct          [get_parameter_value PHY_CK_CALIBRATED_OCT]
   set data_cal_oct        [get_parameter_value PHY_DATA_CALIBRATED_OCT]

   set alert_n_placement   [_get_alert_n_placement_scheme]
   set dqs_pkg_deskew      [get_parameter_value BOARD_DDRT_IS_SKEW_WITHIN_DQS_DESKEWED]
   set ac_pkg_deskew       [get_parameter_value BOARD_DDRT_IS_SKEW_WITHIN_AC_DESKEWED]
   
   set vrefin_pct          [get_parameter_value PHY_DDRT_STARTING_VREFIN]
   set vrefin_settings     [get_starting_vrefin_settings $vrefin_pct]
   set vrefin_cal_range    [dict get $vrefin_settings RANGE_ENUM]
   
   for {set i 0} {$i < [llength $ports]} {incr i} {
      set port      [lindex $ports $i]
      set enabled   [dict get $port ENABLED]
      set type_enum [dict get $port TYPE_ENUM]

      if {!$enabled} {
         continue
      }

      set cal_oct          0
      set io_std_enum      IO_STD_INVALID
      set out_oct_enum     OUT_OCT_INVALID
      set in_oct_enum      IN_OCT_INVALID
      set current_st_enum  CURRENT_ST_INVALID
      set slew_rate_enum   SLEW_RATE_INVALID
      set vref_mode_enum   VREF_MODE_INVALID
      set pkg_deskew       false
      set preemphasis_mode_enum  PREEMPHASIS_MODE_INVALID

      switch $type_enum {
         PORT_MEM_CK_BIDIR -
         PORT_MEM_CK_BIDIR_N {
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
         PORT_MEM_GNT_N -
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
            set cal_oct 0
            set io_std_enum IO_STD_CMOS_12
            set in_oct_enum IN_OCT_0
            if {![dict get $alert_n_placement PLACE_IN_AC_LANE]} {
               set vref_mode_enum $vrefin_cal_range
            }
            set pkg_deskew $ac_pkg_deskew
         }
         PORT_MEM_REQ_N -
         PORT_MEM_ERR_N {
            set cal_oct $ac_cal_oct
            set io_std_enum $ac_io_std_enum
            set in_oct_enum $ac_in_mode_enum
            set pkg_deskew $ac_pkg_deskew
         }
         PORT_MEM_RESET_N {
            set cal_oct 0
            set io_std_enum IO_STD_CMOS_12
            set out_oct_enum OUT_OCT_0
            set slew_rate_enum $ac_slew_rate_enum
            set pkg_deskew $ac_pkg_deskew
         }
         PORT_MEM_DBI_N -
         PORT_MEM_DQ {
            set cal_oct $data_cal_oct
            set io_std_enum $data_io_std_enum
            set in_oct_enum $data_in_mode_enum
            if {[enum_type $data_out_mode_enum] == "OUT_OCT"} {
               set out_oct_enum $data_out_mode_enum
            } else {
               set current_st_enum $data_out_mode_enum
            }
            set vref_mode_enum $vrefin_cal_range
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
            set vref_mode_enum $vrefin_cal_range
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

      if {[enum_same $slew_rate_enum "SLEW_RATE_SLOW"]} {
         set preemphasis_mode_enum "PREEMPHASIS_MODE_0"
      }
      dict set port CAL_OCT    $cal_oct
      dict set port IO_STD     $io_std_enum
      dict set port OUT_OCT    $out_oct_enum
      dict set port IN_OCT     $in_oct_enum
      dict set port CURRENT_ST $current_st_enum
      dict set port VREF_MODE  $vref_mode_enum
      dict set port SLEW_RATE  $slew_rate_enum
      dict set port PKG_DESKEW $pkg_deskew
      dict set port PREEMPHASIS_MODE $preemphasis_mode_enum
      lset ports $i $port
   }

   return 1
}

proc ::altera_emif::ip_arch_nd::ddrt::get_clk_ratios {} {

   set config_enum      [get_parameter_value PHY_DDRT_CONFIG_ENUM]
   set rate_enum        [get_parameter_value PHY_DDRT_RATE_ENUM]
   set mem_clk_freq_mhz [get_parameter_value PHY_DDRT_MEM_CLK_FREQ_MHZ]

   return [::altera_emif::ip_arch_nd::ddrx::get_clk_ratios $config_enum $rate_enum $mem_clk_freq_mhz]
}

proc :::altera_emif::ip_arch_nd::ddrt::check_hmc_legality {} {
   return 1
}

proc ::altera_emif::ip_arch_nd::ddrt::get_num_and_type_of_hmc_ports {} {
 
    set hmc_ifs [dict create]
    dict set hmc_ifs NUM_OF_PORTS 0
    dict set hmc_ifs CTRL_AVL_PROTOCOL_ENUM CTRL_AVL_PROTOCOL_INVALID
      dict set hmc_ifs READY_LATENCY 2


    return $hmc_ifs
}

proc ::altera_emif::ip_arch_nd::ddrt::get_lane_cfgs {} {
   set retval [dict create]

   set is_hps             [get_is_hps]
   set clk_ratios         [get_clk_ratios]
   set phy_hmc_clk_ratio  [expr {[dict get $clk_ratios PHY_HMC] * 1.0}]
   set c2p_p2c_clk_ratio  [expr {[dict get $clk_ratios C2P_P2C] * 1.0}]
   set rc_en              [expr {$phy_hmc_clk_ratio == 2 && $c2p_p2c_clk_ratio == 4 ? 1 : 0}]
   set ecc_en             [get_parameter_value CTRL_ECC_EN]
   set hmc_ifs            [get_num_and_type_of_hmc_ports]
   set ready_latency      [dict get $hmc_ifs READY_LATENCY]
   set write_preamble     [get_parameter_value MEM_DDRT_WRITE_PREAMBLE]
   set read_dbi_en        [get_parameter_value MEM_DDRT_READ_DBI]
   set write_dbi_en       [get_parameter_value MEM_DDRT_WRITE_DBI]
   set mem_clk_freq_mhz   [get_parameter_value PHY_DDRT_MEM_CLK_FREQ_MHZ]
   set is_dense_x4        [expr {[get_dqs_bus_mode] == "DQS_BUS_MODE_X4" ? 1 : 0}]

   if {$write_preamble == 2} {
      dict set retval "PREAMBLE_MODE" "preamble_two_cycle"
   } else {
      dict set retval "PREAMBLE_MODE" "preamble_one_cycle"
   }

   if {$read_dbi_en} {
      dict set retval "DBI_RD_ENABLE" "true"
   } else {
      dict set retval "DBI_RD_ENABLE" "false"
   }

   if {$write_dbi_en} {
      dict set retval "DBI_WR_ENABLE" "true"
   } else {
      dict set retval "DBI_WR_ENABLE" "false"
   }

   dict set retval "SWAP_DQS_A_B" "false"
   dict set retval "OCT_SIZE"      [::altera_emif::ip_arch_nd::ddrx::get_oct_size $mem_clk_freq_mhz]
   dict set retval "DQS_PACK_MODE" "packed"
   
   dict set retval "DQSA_LGC_MODE" "dqsa_diff_in_1"
   if {$is_dense_x4} {
      dict set retval "DQSB_LGC_MODE" "dqsb_diff_in_1"
   } else {
      dict set retval "DQSB_LGC_MODE" "dqsb_constant"
   }
   
   set in_params [dict create]
   dict set in_params IS_HPS        $is_hps
   dict set in_params ECC_EN        $ecc_en
   dict set in_params RC_EN         $rc_en
   dict set in_params READY_LATENCY $ready_latency
   set common_hmc_db_params [::altera_emif::ip_arch_nd::ddrx::get_common_hmc_db_cfgs $in_params]
   dict set retval "DBC_WB_RESERVED_ENTRY" [dict get $common_hmc_db_params DBC_WB_RESERVED_ENTRY]

   return $retval
}

proc ::altera_emif::ip_arch_nd::ddrt::get_hmc_cfgs {hmc_inst} {

   set clk_ratios         [get_clk_ratios]
   set phy_hmc_clk_ratio  [expr {[dict get $clk_ratios PHY_HMC] * 1.0}]
   set c2p_p2c_clk_ratio  [expr {[dict get $clk_ratios C2P_P2C] * 1.0}]

   set rc_en              [expr {$phy_hmc_clk_ratio == 2 && $c2p_p2c_clk_ratio == 4 ? 1 : 0}]
   set qr                 [expr {$phy_hmc_clk_ratio == 4}]

   set is_hps                               [get_is_hps]
   set phy_config_enum                      [get_parameter_value PHY_CONFIG_ENUM]
   set is_hmc                               [expr {$phy_config_enum == "CONFIG_PHY_AND_HARD_CTRL" ? 1 : 0}]
   set hmc_ifs                              [get_num_and_type_of_hmc_ports]
   set chip_id_width                        [get_parameter_value MEM_DDRT_CHIP_ID_WIDTH]
   set ecc_en                               [get_parameter_value CTRL_ECC_EN]
   set reorder_en                           [get_parameter_value CTRL_DDRT_REORDER_EN]
   set pdn_en                               [get_parameter_value CTRL_DDRT_AUTO_POWER_DOWN_EN]
   set geardown                             [get_parameter_value MEM_DDRT_GEARDOWN]
   set trcd_cyc                             [get_parameter_value MEM_DDRT_TRCD_CYC]
   set tras_cyc                             [get_parameter_value MEM_DDRT_TRAS_CYC]
   set trp_cyc                              [get_parameter_value MEM_DDRT_TRP_CYC]
   set trrd_l_cyc                           [get_parameter_value MEM_DDRT_TRRD_L_CYC]
   set trrd_s_cyc                           [get_parameter_value MEM_DDRT_TRRD_S_CYC]
   set tccd_l_cyc                           [get_parameter_value MEM_DDRT_TCCD_L_CYC]
   set tccd_s_cyc                           [get_parameter_value MEM_DDRT_TCCD_S_CYC]
   set tcl_cyc                              [get_parameter_value MEM_DDRT_TCL]
   set tcwl_cyc                             [get_parameter_value MEM_DDRT_WTCL]
   set tal_cyc                              [expr {([enum_data [get_parameter_value MEM_DDRT_ATCL_ENUM] VALUE] == 0) ? 0 : ($tcl_cyc - [enum_data [get_parameter_value MEM_DDRT_ATCL_ENUM] VALUE])}]
   set trtp_cyc                             [get_parameter_value MEM_DDRT_TRTP_CYC]
   set twtr_l_cyc                           [get_parameter_value MEM_DDRT_TWTR_L_CYC]
   set twtr_s_cyc                           [get_parameter_value MEM_DDRT_TWTR_S_CYC]
   set twr_cyc                              [get_parameter_value MEM_DDRT_TWR_CYC]
   set trfc_cyc                             [get_parameter_value MEM_DDRT_TRFC_CYC]
   set trefi_cyc                            [get_parameter_value MEM_DDRT_TREFI_CYC]
   set tfaw_cyc                             [get_parameter_value MEM_DDRT_TFAW_CYC]
   set tmrd_cyc                             [get_parameter_value MEM_DDRT_TMRD_CK_CYC]
   set twrpre_cyc                           [get_parameter_value MEM_DDRT_WRITE_PREAMBLE]
   set trdpre_cyc                           [get_parameter_value MEM_DDRT_READ_PREAMBLE]
   set odt_width                            [get_parameter_value MEM_DDRT_ODT_WIDTH]
   set gnt_n_width                          [get_parameter_value MEM_DDRT_GNT_N_WIDTH]
   set req_n_width                          [get_parameter_value MEM_DDRT_REQ_N_WIDTH]
   set err_n_width                          [get_parameter_value MEM_DDRT_ERR_N_WIDTH]
   set dm_en                                [get_parameter_value MEM_DDRT_DM_EN]
   set write_cmd_latency_cyc                [get_parameter_value MEM_DDRT_WRITE_CMD_LATENCY]
   set tpl_cyc                              [enum_data [get_parameter_value MEM_DDRT_AC_PARITY_LATENCY] VALUE]
   set user_rd_to_wr_same_chip_delta_cyc    [get_parameter_value CTRL_DDRT_RD_TO_WR_SAME_CHIP_DELTA_CYCS]
   set user_wr_to_rd_same_chip_delta_cyc    [get_parameter_value CTRL_DDRT_WR_TO_RD_SAME_CHIP_DELTA_CYCS]
   set user_rd_to_rd_diff_chip_delta_cyc    [get_parameter_value CTRL_DDRT_RD_TO_RD_DIFF_CHIP_DELTA_CYCS]
   set user_rd_to_wr_diff_chip_delta_cyc    [get_parameter_value CTRL_DDRT_RD_TO_WR_DIFF_CHIP_DELTA_CYCS]
   set user_wr_to_wr_diff_chip_delta_cyc    [get_parameter_value CTRL_DDRT_WR_TO_WR_DIFF_CHIP_DELTA_CYCS]
   set user_wr_to_rd_diff_chip_delta_cyc    [get_parameter_value CTRL_DDRT_WR_TO_RD_DIFF_CHIP_DELTA_CYCS]
   set speedbin_val                         [enum_data [get_parameter_value MEM_DDRT_SPEEDBIN_ENUM] VALUE]
   set mem_clk_freq                         [get_parameter_value PHY_DDRT_MEM_CLK_FREQ_MHZ]
   set mem_clk_ns                           [expr {(1000000.0 / $mem_clk_freq) / 1000.0}]
   set format_enum                          [get_parameter_value MEM_DDRT_FORMAT_ENUM]
   set is_lrdimm                            [expr {$format_enum == "MEM_FORMAT_LRDIMM"}]
   set num_of_physical_ranks                [get_parameter_value MEM_DDRT_NUM_OF_PHYSICAL_RANKS]   

   set ping_pong_en                         [get_parameter_value PHY_DDRT_PING_PONG_EN]
   set ping_pong_master0                    [expr {($ping_pong_en && $hmc_inst == "PRI") ? 1 : 0}]
   set ping_pong_master1                    [expr {($ping_pong_en && $hmc_inst == "SEC") ? 1 : 0}]

   set cs_width [get_parameter_value MEM_DDRT_CS_WIDTH]
   set cs_addr_width [expr {int(ceil(log($cs_width)/log(2)))}]

   set trc_cyc        [expr {$tras_cyc + $trp_cyc}]

   set tcksrx_cyc [expr {int(ceil(max(5 * $mem_clk_ns, 10) / $mem_clk_ns))}]

   set txp_cyc [expr {int(ceil(max(4 * $mem_clk_ns, 6) / $mem_clk_ns))}]

   set twtr_l_crc_dm_cyc  [expr {$twtr_l_cyc + int(ceil(max($write_cmd_latency_cyc * $mem_clk_ns, 3.75) / $mem_clk_ns))}]
   set twtr_s_crc_dm_cyc  [expr {$twtr_s_cyc + int(ceil(max($write_cmd_latency_cyc * $mem_clk_ns, 3.75) / $mem_clk_ns))}]

   set twr_crc_dm_cyc [expr {$twr_cyc + int(ceil(max($write_cmd_latency_cyc * $mem_clk_ns, 3.75) / $mem_clk_ns))}]

   set tmod_cyc [expr {int(ceil(max(24 * $mem_clk_ns, 15) / $mem_clk_ns))}]

   set tzqcs_cyc      256
   
   set tzqoper_cyc    512

   set tswitch 2

   set bl 8

   set hmc_phy_delay_mismatch 16

   set rd_to_wr_extra_turnaround [::altera_emif::ip_arch_nd::ddrx::get_base_rd_to_wr_turnaround_mem_cycs $mem_clk_freq]
   set wr_to_rd_extra_turnaround [::altera_emif::ip_arch_nd::ddrx::get_base_wr_to_rd_turnaround_mem_cycs $mem_clk_freq]
   
   set rd_to_wr_extra_turnaround [expr {$rd_to_wr_extra_turnaround + ($is_lrdimm ? 4 : 0)}]

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
   dict set in_params READY_LATENCY       [dict get $hmc_ifs READY_LATENCY]
   dict set in_params GEARDOWN_EN         [expr {$geardown == "DDRT_GEARDOWN_QR" ? 1 : 0}]

   set common_hmc_params    [::altera_emif::ip_arch_nd::ddrx::get_common_hmc_cfgs $in_params]
   set common_hmc_db_params [::altera_emif::ip_arch_nd::ddrx::get_common_hmc_db_cfgs $in_params]

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
   set cmd_fifo_reserve_en    [dict get $common_hmc_params CMD_FIFO_RESERVE_EN]
   set rb_reserved_entry      [dict get $common_hmc_db_params RB_RESERVED_ENTRY]
   set wb_reserved_entry      [dict get $common_hmc_db_params WB_RESERVED_ENTRY]

   set tmp_wr_to_rd_diff_chip [expr {max($tcwl_cyc - $tcl_cyc + ($bl / 2), 0)}]

   set wr_to_rd_diff_chip [hmc_div_ceil [expr {max($tmp_wr_to_rd_diff_chip, 1) + 1 + $trdpre_cyc + $wr_to_rd_extra_turnaround + $col_to_diff_col_offset}] $phy_hmc_clk_ratio]

   set tmp_wr_to_rd         [expr {$tal_cyc + $tcwl_cyc + ($bl / 2) + max($twtr_l_cyc, 4) + $col_to_diff_col_offset}]
   set tmp_wr_to_rd_diff_bg [expr {$tal_cyc + $tcwl_cyc + ($bl / 2) + max($twtr_s_cyc, 4) + $col_to_diff_col_offset}]

   set wr_to_pch            [hmc_div_ceil [expr {$tal_cyc + $tcwl_cyc + ($bl / 2) + $twr_cyc + $col_to_row_offset}] $phy_hmc_clk_ratio]
   set wr_ap_to_valid       [hmc_div_ceil [expr {$tal_cyc + $tcwl_cyc + ($bl / 2) + $twr_cyc + $trp_cyc + $col_to_row_offset}] $phy_hmc_clk_ratio]

   set wr_to_rd [hmc_div_ceil [expr {$tmp_wr_to_rd + $wr_to_rd_extra_turnaround}] $phy_hmc_clk_ratio]

   set tmp_wr_to_wr_diff_bg   [expr {$tccd_s_cyc + $col_to_col_offset}]
   set wr_to_wr [hmc_div_ceil [expr {$tccd_l_cyc + $col_to_col_offset}] $phy_hmc_clk_ratio]

   set wr_to_wr_diff_bg [hmc_div_ceil $tmp_wr_to_wr_diff_bg $phy_hmc_clk_ratio]

   if {$ping_pong_en} {
      set tmp_rd_to_rd_diff_bg $tmp_wr_to_wr_diff_bg
      set rd_to_rd             $wr_to_wr
      set rd_to_rd_diff_bg     $wr_to_wr_diff_bg
   } else {
      set tmp_rd_to_rd_diff_bg [expr {$tccd_s_cyc + $col_to_col_offset}]
      set rd_to_rd             [hmc_div_ceil [expr {$tccd_l_cyc + $col_to_col_offset}] $phy_hmc_clk_ratio]
      set rd_to_rd_diff_bg     [hmc_div_ceil $tmp_rd_to_rd_diff_bg $phy_hmc_clk_ratio]
   }

   if {$tmp_wr_to_rd >= ($tmp_wr_to_rd_diff_bg + $tmp_rd_to_rd_diff_bg)} {
      set wr_to_rd_diff_bg [hmc_div_ceil [expr {$tmp_wr_to_rd - $tmp_rd_to_rd_diff_bg + $wr_to_rd_extra_turnaround}] $phy_hmc_clk_ratio]
   } else {
      set wr_to_rd_diff_bg [hmc_div_ceil [expr {$tmp_wr_to_rd_diff_bg + $wr_to_rd_extra_turnaround}] $phy_hmc_clk_ratio]
   }

   set rd_to_rd_diff_chip [expr {[hmc_div_ceil [expr {($bl / 2) + 2 + ($trdpre_cyc - 1) + $col_to_col_offset}] $phy_hmc_clk_ratio] + $user_rd_to_rd_diff_chip_delta_cyc}]
   set rd_ap_to_valid     [hmc_div_ceil [expr {$tal_cyc + max($trtp_cyc, 4) + $trp_cyc + $col_to_row_offset}] $phy_hmc_clk_ratio]
   set act_to_act         [hmc_div_ceil [expr {$tras_cyc + $trp_cyc + $row_to_row_offset}] $phy_hmc_clk_ratio]

   if {$tal_cyc >= ($trcd_cyc + $row_to_col_offset)} {
      set act_to_rdwr 0
   } else {
      set act_to_rdwr [hmc_div_ceil [expr {$trcd_cyc - $tal_cyc + $row_to_col_offset}] $phy_hmc_clk_ratio]
   }

   set retval [dict create]

   foreach hmc_cfg_enum [enums_of_type HMC_CFG] {

      set val 0

      switch $hmc_cfg_enum {
         HMC_CFG_CTRL_ENABLE_ECC -
         HMC_CFG_DBC0_ENABLE_ECC -
         HMC_CFG_DBC1_ENABLE_ECC -
         HMC_CFG_DBC2_ENABLE_ECC -
         HMC_CFG_DBC3_ENABLE_ECC {
            set val [expr {$ecc_en ? "enable" : "disable"}]
         }
         HMC_CFG_REORDER_DATA {
            set val [expr {($reorder_en || !$is_hmc) ? "enable" : "disable"}]
         }
         HMC_CFG_REORDER_READ -
         HMC_CFG_CTRL_REORDER_RDATA -
         HMC_CFG_DBC0_REORDER_RDATA -
         HMC_CFG_DBC1_REORDER_RDATA -
         HMC_CFG_DBC2_REORDER_RDATA -
         HMC_CFG_DBC3_REORDER_RDATA {
            set val [expr {(($reorder_en && !$ecc_en) || !$is_hmc) ? "enable" : "disable"}]
         }
         HMC_CFG_STARVE_LIMIT {
            set val [get_parameter_value CTRL_DDRT_STARVE_LIMIT]
         }
         HMC_CFG_DQSTRK_EN {
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
         HMC_CFG_CTRL_SLOT_ROTATE_EN {
            set val "ctrl_disable"
         }
         HMC_CFG_DBC0_SLOT_ROTATE_EN {
            set val "dbc0_disable"
         }
         HMC_CFG_DBC1_SLOT_ROTATE_EN {
            set val "dbc1_disable"
         }
         HMC_CFG_DBC2_SLOT_ROTATE_EN {
            set val "dbc2_disable"
         }
         HMC_CFG_DBC3_SLOT_ROTATE_EN {
            set val "dbc3_disable"
         }
         HMC_CFG_CTRL_SLOT_OFFSET -
         HMC_CFG_DBC0_SLOT_OFFSET -
         HMC_CFG_DBC1_SLOT_OFFSET -
         HMC_CFG_DBC2_SLOT_OFFSET -
         HMC_CFG_DBC3_SLOT_OFFSET {
            set val $slot_offset
         }
         HMC_CFG_COL_TO_COL_OFFSET {
            set val $col_to_col_offset
         }
         HMC_CFG_COL_TO_DIFF_COL_OFFSET {
            set val $col_to_diff_col_offset
         }
         HMC_CFG_COL_TO_ROW_OFFSET {
            set val $col_to_row_offset
         }
         HMC_CFG_ROW_TO_COL_OFFSET {
            set val $row_to_col_offset
         }
         HMC_CFG_ROW_TO_ROW_OFFSET {
            set val $row_to_row_offset
         }
         HMC_CFG_SIDEBAND_OFFSET {
            set val $sideband_offset
         }
         HMC_CFG_COL_CMD_SLOT {
            set val $col_cmd_slot
         }
         HMC_CFG_ROW_CMD_SLOT {
            set val $row_cmd_slot
         }
         HMC_CFG_CTRL_ENABLE_RC -
         HMC_CFG_DBC0_ENABLE_RC -
         HMC_CFG_DBC1_ENABLE_RC -
         HMC_CFG_DBC2_ENABLE_RC -
         HMC_CFG_DBC3_ENABLE_RC {
            set val [expr {$rc_en ? "enable" : "disable"}]
         }
         HMC_CFG_CS_TO_CHIP_MAPPING {
            set val [bin2num "1000_0100_0010_0001"]
         }
         HMC_CFG_CMD_FIFO_RESERVE_EN {
            set val $cmd_fifo_reserve_en
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
            set val [hmc_div_ceil [expr {$tcksrx_cyc + $tpl_cyc + $hmc_phy_delay_mismatch + $sideband_offset}] $phy_hmc_clk_ratio]
         }
         HMC_CFG_WRITE_ODT_CHIP {
            set val [get_parameter_value MEM_DDRT_CTRL_CFG_WRITE_ODT_RANK]
         }
         HMC_CFG_READ_ODT_CHIP {
            set val [get_parameter_value MEM_DDRT_CTRL_CFG_READ_ODT_RANK]
         }
         HMC_CFG_WR_ODT_ON {
            set val 0
         }
         HMC_CFG_RD_ODT_ON {
            set val 0
         }
         HMC_CFG_WR_ODT_PERIOD {
            set val [expr {int(5 + $twrpre_cyc)}]
         }
         HMC_CFG_RD_ODT_PERIOD {
            set val [expr {int(5 + max($twrpre_cyc, $trdpre_cyc))}]
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
            if {$act_to_act > $act_to_rdwr} {
               set val [expr {max($rd_ap_to_valid, $act_to_act - $act_to_rdwr) + 6}]
            } else {
               set val $rd_ap_to_valid
            }
         }
         HMC_CFG_DQSTRK_TO_VALID {
            set val $rd_to_rd_diff_chip
         }
         HMC_CFG_SB_CG_DISABLE {
            set val "disable"
         }
         HMC_CFG_USER_RFSH_EN {
            set val [expr {[get_parameter_value CTRL_DDRT_USER_REFRESH_EN] ? "enable" : "disable"}]
         }
         HMC_CFG_SRF_AUTOEXIT_EN {
            set val [expr {$is_hps ? "enable" : "disable"}]
         }
         HMC_CFG_SRF_ENTRY_EXIT_BLOCK {
            set val "presrfexit"
         }
         HMC_CFG_COL_ADDR_WIDTH {
            set val "col_width_[get_parameter_value MEM_DDRT_COL_ADDR_WIDTH]"
         }
         HMC_CFG_ROW_ADDR_WIDTH {
            set eff_row_addr_width [expr {[get_parameter_value MEM_DDRT_ROW_ADDR_WIDTH] + $chip_id_width}]
            set val "row_width_$eff_row_addr_width"
         }
         HMC_CFG_BANK_ADDR_WIDTH {
            set val "bank_width_[get_parameter_value MEM_DDRT_BANK_ADDR_WIDTH]"
         }
         HMC_CFG_BANK_GROUP_ADDR_WIDTH {
            set val "bank_group_width_[get_parameter_value MEM_DDRT_BANK_GROUP_WIDTH]"
         }
         HMC_CFG_CS_ADDR_WIDTH {
            set val "cs_width_$cs_addr_width"
         }
         HMC_CFG_ADDR_ORDER {
            set addr_order_enum [get_parameter_value "CTRL_DDRT_ADDR_ORDER_ENUM"]

            set mapping [dict create DDRT_CTRL_ADDR_ORDER_CS_BG_B_R_C   HMC_CFG_ADDR_ORDER_CS_B_R_C \
                                     DDRT_CTRL_ADDR_ORDER_CS_R_B_C_BG   HMC_CFG_ADDR_ORDER_CS_R_B_C \
                                     DDRT_CTRL_ADDR_ORDER_R_CS_B_C_BG   HMC_CFG_ADDR_ORDER_R_CS_B_C \
                                     DDRT_CTRL_ADDR_ORDER_CS_R_BG_B_C   HMC_CFG_ADDR_ORDER_CS_R_B_C \
                                     DDRT_CTRL_ADDR_ORDER_R_CS_BG_B_C   HMC_CFG_ADDR_ORDER_R_CS_B_C ]

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
            set val [hmc_div_ceil [expr {$trrd_l_cyc + $row_to_row_offset}] $phy_hmc_clk_ratio]
         }
         HMC_CFG_ACT_TO_ACT_DIFF_BG {
            set val [hmc_div_ceil [expr {$trrd_s_cyc + $row_to_row_offset}] $phy_hmc_clk_ratio]
         }
         HMC_CFG_RD_TO_RD {
            set val $rd_to_rd
         }
         HMC_CFG_RD_TO_RD_DIFF_CHIP {
            set val $rd_to_rd_diff_chip
         }
         HMC_CFG_RD_TO_RD_DIFF_BG {
            set val $rd_to_rd_diff_bg
         }
         HMC_CFG_RD_TO_WR {
            set val [expr {[hmc_div_ceil [expr {$tcl_cyc - $tcwl_cyc + ($bl / 2) + 1 + $twrpre_cyc + $rd_to_wr_extra_turnaround + $col_to_diff_col_offset}] $phy_hmc_clk_ratio] + $user_rd_to_wr_same_chip_delta_cyc}]
         }
         HMC_CFG_RD_TO_WR_DIFF_CHIP {
            set val [expr {[hmc_div_ceil [expr {$tcl_cyc - $tcwl_cyc + ($bl / 2) + 1 + $twrpre_cyc + $rd_to_wr_extra_turnaround + $col_to_diff_col_offset}] $phy_hmc_clk_ratio] + $user_rd_to_wr_diff_chip_delta_cyc}]
         }
         HMC_CFG_RD_TO_WR_DIFF_BG {
            set val [expr {[hmc_div_ceil [expr {$tcl_cyc - $tcwl_cyc + ($bl / 2) + 1 + $twrpre_cyc + $rd_to_wr_extra_turnaround + $col_to_diff_col_offset}] $phy_hmc_clk_ratio] + $user_rd_to_wr_same_chip_delta_cyc}]
         }
         HMC_CFG_RD_TO_PCH {
            set val [hmc_div_ceil [expr {$tal_cyc + max($trtp_cyc, 4) + $col_to_row_offset}] $phy_hmc_clk_ratio]
         }
         HMC_CFG_RD_AP_TO_VALID {
            set val $rd_ap_to_valid
         }
         HMC_CFG_WR_TO_WR {
            set val $wr_to_wr
         }
         HMC_CFG_WR_TO_WR_DIFF_CHIP {
            set val [expr {[hmc_div_ceil [expr {($bl / 2) + 1 + $twrpre_cyc + $col_to_diff_col_offset}] $phy_hmc_clk_ratio] + $user_wr_to_wr_diff_chip_delta_cyc}]
         }
         HMC_CFG_WR_TO_WR_DIFF_BG {
            set val $wr_to_wr_diff_bg
         }
         HMC_CFG_WR_TO_RD {
            set val [expr {$wr_to_rd + $user_wr_to_rd_same_chip_delta_cyc}]
         }
         HMC_CFG_WR_TO_RD_DIFF_CHIP {
            set val [expr {$wr_to_rd_diff_chip + $user_wr_to_rd_diff_chip_delta_cyc}]
         }
         HMC_CFG_WR_TO_RD_DIFF_BG {
            set val [expr {$wr_to_rd_diff_bg + $user_wr_to_rd_same_chip_delta_cyc}]
         }
         HMC_CFG_WR_TO_PCH {
            set val $wr_to_pch
         }
         HMC_CFG_WR_AP_TO_VALID {
            set val $wr_ap_to_valid
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
            set val [hmc_div_ceil [expr {$txp_cyc + $sideband_offset}] $phy_hmc_clk_ratio]
         }
         HMC_CFG_SRF_TO_VALID {
            set val [hmc_div_ceil [expr {1024 + $sideband_offset}] $phy_hmc_clk_ratio]
         }
         HMC_CFG_SRF_TO_ZQ_CAL {
            set val [hmc_div_ceil [expr {1024 - $tzqcs_cyc + $sideband_offset}] $phy_hmc_clk_ratio]
         }
         HMC_CFG_ARF_PERIOD {
            set val [hmc_div_ceil [expr {$trefi_cyc + $sideband_offset}] $phy_hmc_clk_ratio]
         }
         HMC_CFG_MEM_AUTO_PD_CYCLES -
         HMC_CFG_PDN_PERIOD {
            set val [expr {$pdn_en ? [get_parameter_value CTRL_DDRT_AUTO_POWER_DOWN_CYCS] : 0}]
         }
         HMC_CFG_ZQCL_TO_VALID {
            set val [hmc_div_ceil [expr {$tzqoper_cyc + $sideband_offset}] $phy_hmc_clk_ratio]
         }
         HMC_CFG_ZQCS_TO_VALID {
            set val [hmc_div_ceil [expr {$tzqcs_cyc + $sideband_offset}] $phy_hmc_clk_ratio]
            if {$val >= 127} {
               set val 127
            }
         }
         HMC_CFG_MPS_TO_VALID {
            set val [hmc_div_ceil 1536 $phy_hmc_clk_ratio]
         }
         HMC_CFG_MRR_TO_VALID {
            set val 0
         }
         HMC_CFG_MPR_TO_VALID {
            set val [hmc_div_ceil 31 $phy_hmc_clk_ratio]
         }
         HMC_CFG_MPS_EXIT_CS_TO_CKE {
            set val [hmc_div_ceil 10 $phy_hmc_clk_ratio]
         }
         HMC_CFG_MPS_EXIT_CKE_TO_CS {
            set val [hmc_div_ceil 11 $phy_hmc_clk_ratio]
         }
         HMC_CFG_MRS_TO_VALID {
            set val [expr {int(($tmod_cyc - 1) / ($phy_hmc_clk_ratio / 2) / 2 + 1)}]
         }
         HMC_CFG_MMR_CMD_TO_VALID {
            set val 16
         }
         HMC_CFG_4_ACT_TO_ACT {
            set val [hmc_div_ceil [expr {$tfaw_cyc + $row_to_row_offset}] $phy_hmc_clk_ratio]
            set val [expr {($val == 5) ? $val : $val - 1}]
         }
         HMC_CFG_SB_DDRT_MR3 {
            set val [expr {[get_parameter_value MEM_DDRT_MR3] & 1048575}]
         }
         HMC_CFG_SB_DDRT_MR4 {
            set val [expr {[get_parameter_value MEM_DDRT_MR4] & 1048575}]
         }
         HMC_CFG_SB_DDRT_MR5 {
            set val [expr {[get_parameter_value MEM_DDRT_MR5] & 65535}]
         }
         HMC_CFG_DDRT_MPS_ADDRMIRROR {
            set val [enum_data $hmc_cfg_enum DEFAULT]
         }
         HMC_CID_ADDR_WIDTH {
            set val $chip_id_width
         }
         HMC_CHIP_ID {
            set val [bin2num "100_010_001"]
         }
         HMC_3DS_EN {
            set val [expr {$chip_id_width > 0 ? "enable" : "disable"}]
         }
         HMC_3DS_REF2REF_DLR {
            if {$chip_id_width > 0} {
               set mem_if_3ds_trfc_dlr [get_parameter_value MEM_DDRT_TRFC_DLR_CYC]
            } else {
               set mem_if_3ds_trfc_dlr 0
            }
            set val [hmc_div_ceil [expr {$mem_if_3ds_trfc_dlr + $sideband_offset}] $phy_hmc_clk_ratio]
         }
         HMC_3DS_LR_NUM0 {
            if {$chip_id_width > 0 && $num_of_physical_ranks >= 1} {
               set val [expr {pow(2, $chip_id_width)}]
            } else {
               set val 0
            }
         }
         HMC_3DS_LR_NUM1 {
            if {$chip_id_width > 0 && $num_of_physical_ranks >= 2} {
               set val [expr {pow(2, $chip_id_width)}]
            } else {
               set val 0
            }
         }
         HMC_3DS_LR_NUM2 {
            if {$chip_id_width > 0 && $num_of_physical_ranks >= 3} {
               set val [expr {pow(2, $chip_id_width)}]
            } else {
               set val 0
            }
         }
         HMC_3DS_LR_NUM3 {
            if {$chip_id_width > 0 && $num_of_physical_ranks >= 4} {
               set val [expr {pow(2, $chip_id_width)}]
            } else {
               set val 0
            }
         }
         HMC_3DS_PR_STAG_ENABLE {
            if {$chip_id_width > 0} {
               set val "enable"
            } else {
               set val "disable"
            }
         }
         HMC_3DSREF_ACK_ON_DONE {
            set val "disable"
         }         
         default {
            set val [enum_data $hmc_cfg_enum DEFAULT]
         }
      }
      dict set retval $hmc_cfg_enum $val
   }
   return $retval
}

proc ::altera_emif::ip_arch_nd::ddrt::derive_seq_param_tbl {seq_pt_enums} {

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
            set val [get_parameter_value MEM_DDRT_TTL_NUM_OF_PHYSICAL_RANKS]
         }
         SEQ_PT_NUM_DIMMS {
            set val [get_parameter_value MEM_DDRT_TTL_NUM_OF_DIMMS]
         }
         SEQ_PT_NUM_DQS_WR {
            set val [get_parameter_value MEM_DDRT_TTL_DQS_WIDTH]
         }
         SEQ_PT_NUM_DQS_RD {
            set val [get_parameter_value MEM_DDRT_TTL_DQS_WIDTH]
         }
         SEQ_PT_NUM_DQ {
            set val [get_parameter_value MEM_DDRT_TTL_DQ_WIDTH]

         }
         SEQ_PT_NUM_DM {
            if {[get_parameter_value MEM_DDRT_DM_EN] || [get_parameter_value MEM_DDRT_READ_DBI] || [get_parameter_value MEM_DDRT_WRITE_DBI]} {
               set val [get_parameter_value MEM_DDRT_TTL_DQS_WIDTH]
            } else {
               set val 0
            }
         }
         SEQ_PT_CK_WIDTH {
            set val [get_parameter_value MEM_DDRT_TTL_CK_WIDTH]
         }
         SEQ_PT_ADDR_WIDTH {
            set val [get_parameter_value MEM_DDRT_TTL_ADDR_WIDTH]
         }
         SEQ_PT_BANK_WIDTH {
            set val [get_parameter_value MEM_DDRT_TTL_BANK_ADDR_WIDTH]
         }
         SEQ_PT_CS_WIDTH {
            set val [get_parameter_value MEM_DDRT_TTL_CS_WIDTH]
         }
         SEQ_PT_CKE_WIDTH {
            set val [get_parameter_value MEM_DDRT_TTL_CKE_WIDTH]
         }
         SEQ_PT_ODT_WIDTH {
            set val [get_parameter_value MEM_DDRT_TTL_ODT_WIDTH]
         }
         SEQ_PT_C_WIDTH {
            set val [get_parameter_value MEM_DDRT_TTL_CHIP_ID_WIDTH]
         }
         SEQ_PT_BANK_GROUP_WIDTH {
            set val [get_parameter_value MEM_DDRT_TTL_BANK_GROUP_WIDTH]
         }
         SEQ_PT_ADDR_MIRROR {
            set val [get_parameter_value MEM_DDRT_ADDRESS_MIRROR_BITVEC]
         }
         SEQ_PT_ODT_TABLE_LO {
            set val [get_parameter_value MEM_DDRT_SEQ_ODT_TABLE_LO]
         }
         SEQ_PT_ODT_TABLE_HI {
            set val [get_parameter_value MEM_DDRT_SEQ_ODT_TABLE_HI]
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
            set format_enum [get_parameter_value MEM_DDRT_FORMAT_ENUM]
            set is_rdimm    [expr {$format_enum == "MEM_FORMAT_RDIMM"}]
            set is_lrdimm   [expr {$format_enum == "MEM_FORMAT_LRDIMM"}]

            set num_basic_config_words 0
            set num_rdimm_config_words 0
            set num_lrdimm_config_words 0

            set mr0 [get_parameter_value MEM_DDRT_MR0]
            set mr1 [get_parameter_value MEM_DDRT_MR1]
            set mr2 [get_parameter_value MEM_DDRT_MR2]
            set mr3 [get_parameter_value MEM_DDRT_MR3]
            set mr4 [get_parameter_value MEM_DDRT_MR4]
            set mr5 [get_parameter_value MEM_DDRT_MR5]
            set mr6 [get_parameter_value MEM_DDRT_MR6]

            set mrs [list \
               [dict create DBG_NAME "MR0" DBG_VALUE [num2bin $mr0 20] VALUE $mr0] \
               [dict create DBG_NAME "MR1" DBG_VALUE [num2bin $mr1 20] VALUE $mr1] \
               [dict create DBG_NAME "MR2" DBG_VALUE [num2bin $mr2 20] VALUE $mr2] \
               [dict create DBG_NAME "MR3" DBG_VALUE [num2bin $mr3 20] VALUE $mr3] \
               [dict create DBG_NAME "MR4" DBG_VALUE [num2bin $mr4 20] VALUE $mr4] \
               [dict create DBG_NAME "MR5" DBG_VALUE [num2bin $mr5 20] VALUE $mr5] \
               [dict create DBG_NAME "MR6" DBG_VALUE [num2bin $mr6 20] VALUE $mr6] \
               ]

            set num_basic_config_words [llength $mrs]

            if {$is_rdimm || $is_lrdimm} {
               set rdimm_config [get_parameter_value MEM_DDRT_RDIMM_CONFIG]
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
               set lrdimm_config [get_parameter_value MEM_DDRT_LRDIMM_EXTENDED_CONFIG]
               set lrdimm_config_length [string length $lrdimm_config]

               set lrdimm_config_bytes ""
               for {set x 0} {$x < $lrdimm_config_length} {incr x 2} {
                  set lrdimm_config_byte [string range $lrdimm_config $x [expr {$x + 1}]]
                  if {($lrdimm_config_byte == "0x") || ($lrdimm_config_byte == "0X")} {
                     continue
                  } else {
                     lappend lrdimm_config_bytes $lrdimm_config_byte
                  }
               }

               set lrdimm_config_words ""
               for {set x [expr {[llength $lrdimm_config_bytes] - 1}]} {$x >= 0} {incr x -4} {
                  lappend lrdimm_config_words [join [lrange $lrdimm_config_bytes [expr {$x-3}] $x] ""]
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
            set skip_dcd_cal_val [expr {[enum_data SEQ_CONST_CALIB_SKIP_PIN_DCD_CK]}]

            set skip_ca_level  [expr {[get_parameter_value "DIAG_DDRT_SKIP_CA_LEVEL"]  ? [enum_data SEQ_CONST_CALIB_SKIP_CA_LEVEL]  : 0}]
            set skip_ca_deskew [expr {[get_parameter_value "DIAG_DDRT_SKIP_CA_DESKEW"] ? [enum_data SEQ_CONST_CALIB_SKIP_CA_DESKEW] : 0}]
            set skip_vref_cal  [expr {[get_parameter_value "DIAG_DDRT_SKIP_VREF_CAL"]  ? [expr {[enum_data SEQ_CONST_CALIB_SKIP_VREFIN_CAL] | [enum_data SEQ_CONST_CALIB_SKIP_VREFOUT_CAL]}] : 0}]
            set val            [expr {$skip_dcd_cal_val | $skip_ca_level | $skip_ca_deskew | $skip_vref_cal}]

            if {[get_parameter_value MEM_DDRT_BANK_GROUP_WIDTH] == 1} {
               set val [expr {$val | [enum_data SEQ_CONST_CALIB_SKIP_CA_LEVEL]}]
            }
            if {![get_parameter_value MEM_DDRT_ALERT_PAR_EN]} {
               set val [expr {$val | [enum_data SEQ_CONST_CALIB_SKIP_CA_DESKEW]}]
            }
         }
         SEQ_PT_CAL_DATA_PTR {
            set val [::altera_emif::ip_arch_nd::seq_param_tbl::get_cal_data_common_section]

            set vrefin_pct [get_parameter_value PHY_DDRT_STARTING_VREFIN]
            set vrefin_settings [get_starting_vrefin_settings $vrefin_pct]
            set vrefin_encoded [dict get $vrefin_settings VAL]
            dict lappend val CONTENT   [dict create DBG_NAME "STARTING_VREFIN" DBG_VALUE $vrefin_encoded VALUE $vrefin_encoded]
            

            set db_dq_nibble_map [expr 0b100001111]
            dict lappend val CONTENT   [dict create DBG_NAME "DB_DQ_NIBBLE_MAP" DBG_VALUE $db_dq_nibble_map VALUE $db_dq_nibble_map]

            set i2c_dimm_0_sa   [get_parameter_value "MEM_DDRT_I2C_DIMM_0_SA"]
            set i2c_dimm_1_sa   [get_parameter_value "MEM_DDRT_I2C_DIMM_1_SA"]
            set i2c_addrs       [expr {0x5858 | ($i2c_dimm_0_sa << 0) | ($i2c_dimm_1_sa << 8)}]
            dict lappend val CONTENT   [dict create DBG_NAME "I2C_ADDRS" DBG_VALUE $i2c_addrs VALUE $i2c_addrs]

            set tcl_add  4
            set tcwl_add 7
            set rcmd_add 3
            set ddrt_bcom_cw_base [expr {(0x0063c000 | (($tcl_add & 0x7) << 2) | (($tcwl_add & 0xf) << 5) | (($rcmd_add & 0xf) << 9))}]
            dict lappend val CONTENT   [dict create DBG_NAME "DDRT_BCOM_CW_BASE" DBG_VALUE $ddrt_bcom_cw_base VALUE $ddrt_bcom_cw_base]

            set driver_margining_en  [get_parameter_value "CTRL_DDRT_DRIVER_MARGINING_EN"]
            dict lappend val CONTENT [dict create DBG_NAME "DRIVER_MARGINING_EN" DBG_VALUE $driver_margining_en VALUE $driver_margining_en]

            set persistent_mode [get_parameter_value "MEM_DDRT_PERSISTENT_MODE"]
            dict lappend val CONTENT   [dict create DBG_NAME "DDRT_PERSISTENT_MODE" DBG_VALUE $persistent_mode VALUE $persistent_mode]

            set pwr_mode [get_parameter_value "MEM_DDRT_PWR_MODE"]
            set pwr_mode_val [enum_data $pwr_mode VALUE]
            dict lappend val CONTENT   [dict create DBG_NAME "DDRT_PWR_MODE" DBG_VALUE $pwr_mode_val VALUE $pwr_mode_val]

            set cfg_lockdown [expr {[ini_is_on "ddrt_cfg_unlock"] ? 0 : 1}]
            dict lappend val CONTENT   [dict create DBG_NAME "DDRT_CONFIG_LOCKDOWN" DBG_VALUE $cfg_lockdown VALUE $cfg_lockdown]

            set clk_stp_val [expr {[get_parameter_value "PHY_DDRT_IC_EN"] ? 1 : 2}]
            dict lappend val CONTENT   [dict create DBG_NAME "CLK_STP_VAL" DBG_VALUE $clk_stp_val VALUE $clk_stp_val]

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

proc ::altera_emif::ip_arch_nd::ddrt::get_timing_params {} {

   set retval [dict create]

   set tck_ns [expr {1000.0 / [get_parameter_value PHY_DDRT_MEM_CLK_FREQ_MHZ]}]
   set speedbin_enum      [get_parameter_value "MEM_DDRT_SPEEDBIN_ENUM"]
   set mem_fmax           [enum_data $speedbin_enum FMAX_MHZ]
   set mem_tck_ns         [round_num [expr 1.0/$mem_fmax*1000.0] 3]  

   foreach tparam_enum [enums_of_type TPARAM] {

      set val 0

      switch $tparam_enum {
         TPARAM_PROTOCOL {
            set val "DDRT"
         }
         TPARAM_NUM_RANKS {
            set val [get_parameter_value "MEM_DDRT_NUM_OF_PHYSICAL_RANKS"]
         }
         TPARAM_SLEW_RATE_DRAM {
            set val [get_parameter_value BOARD_DDRT_RDATA_SLEW_RATE]
         }
         TPARAM_SLEW_RATE_DRAM_CLOCK {
            set val [get_parameter_value BOARD_DDRT_RCLK_SLEW_RATE]
         }
         TPARAM_VIN_MS {
            set val [expr {[get_parameter_value MEM_DDRT_VDIVW_TOTAL] / 1000.0}]
         }
         TPARAM_VIN_MH {
            set val [expr {[get_parameter_value MEM_DDRT_VDIVW_TOTAL] /2 / 1000.0}]
         }
         TPARAM_SLEW_RATE_PHY {
            set val [get_parameter_value BOARD_DDRT_WDATA_SLEW_RATE]
         }
         TPARAM_SLEW_RATE_PHY_CLOCK {
            set val [get_parameter_value BOARD_DDRT_WCLK_SLEW_RATE]
         }
         TPARAM_SLEW_RATE_CA {
            set val [get_parameter_value BOARD_DDRT_AC_SLEW_RATE]
         }
         TPARAM_SLEW_RATE_CLOCK {
            set val [get_parameter_value BOARD_DDRT_CK_SLEW_RATE]
         }
         TPARAM_UI {
            set val [round_num $tck_ns 3]
         }
         TPARAM_TCK {
            set val                $mem_tck_ns
         }
         TPARAM_TDQSQ {
            set val [expr {(1-[get_parameter_value MEM_DDRT_TDVWP_UI])*$mem_tck_ns/2/2}]
         }
         TPARAM_TQH {
            set val [expr {0.5-((1-[get_parameter_value MEM_DDRT_TDVWP_UI])/2/2)}]
         }
         TPARAM_TDS {
            set val [expr {([get_parameter_value MEM_DDRT_TDIVW_TOTAL_UI] * $tck_ns / 4)}]
         }
         TPARAM_TDH {
            set val [expr {([get_parameter_value MEM_DDRT_TDIVW_TOTAL_UI] * $tck_ns / 4)}]
         }
         TPARAM_TIS {
            set val [expr {([get_parameter_value BOARD_DDRT_TIS_DERATING_PS] + [get_parameter_value MEM_DDRT_TIS_PS]) / 1000.0}]
         }
         TPARAM_TIH {
            set val [expr {([get_parameter_value BOARD_DDRT_TIH_DERATING_PS] + [get_parameter_value MEM_DDRT_TIH_PS]) / 1000.0}]
         }
         TPARAM_TDQSCK {
            set val [expr {[get_parameter_value MEM_DDRT_TDQSCK_PS] / 1000.0}]
         }
         TPARAM_TDQSS {
            set val [get_parameter_value MEM_DDRT_TDQSS_CYC]
         }
         TPARAM_TWLS {
            set val [expr {int([get_parameter_value MEM_DDRT_TWLS_CYC] * $tck_ns * 1000.0) / 1000.0}]
         }
         TPARAM_TWLH {
            set val [expr {int([get_parameter_value MEM_DDRT_TWLH_CYC] * $tck_ns * 1000.0) / 1000.0}]
         }         
         TPARAM_TDSS {
            set val [get_parameter_value MEM_DDRT_TDSS_CYC]
         }
         TPARAM_TDSH {
            set val [get_parameter_value MEM_DDRT_TDSH_CYC]
         }
         TPARAM_BD_PKG_SKEW {
            set val [get_parameter_value BOARD_DDRT_SKEW_WITHIN_DQS_NS]
         }
         TPARAM_CA_BD_PKG_SKEW {
            set val [get_parameter_value BOARD_DDRT_SKEW_WITHIN_AC_NS]
         }
         TPARAM_CA_TO_CK_BD_PKG_SKEW {
            set val [get_parameter_value BOARD_DDRT_AC_TO_CK_SKEW_NS]
         }
         TPARAM_RD_ISI {
            set val [get_parameter_value BOARD_DDRT_RDATA_ISI_NS]
         }
         TPARAM_WR_ISI {
            set val [get_parameter_value BOARD_DDRT_WDATA_ISI_NS]
         }
         TPARAM_CA_ISI {
            set val [get_parameter_value BOARD_DDRT_AC_ISI_NS]
         }
         TPARAM_DQSG_ISI {
            set val [get_parameter_value BOARD_DDRT_RCLK_ISI_NS]
         }
         TPARAM_WL_ISI {
            set val [get_parameter_value BOARD_DDRT_WCLK_ISI_NS]
         }
         TPARAM_DQS_BOARD_SKEW {
            set val [get_parameter_value BOARD_DDRT_SKEW_BETWEEN_DQS_NS]
         }
         TPARAM_DQS_TO_CK_BOARD_SKEW {
            set val [get_parameter_value BOARD_DDRT_DQS_TO_CK_SKEW_NS]
         }
         TPARAM_X4 {
            set val [expr {[get_dqs_bus_mode] == "DQS_BUS_MODE_X4" ? 1 : 0}]
         }
         TPARAM_IS_DLL_ON {
            set val [expr {[get_parameter_value DLL_MODE] == "ctl_dynamic" ? 1 : 0}]
         }
         TPARAM_OCT_RECAL {
           set val 0
         }
         TPARAM_CUT_PATHS {

            set val 0
         }
         TPARAM_RDBI {
            if {[get_parameter_value MEM_DDR4_READ_DBI]} {
               set val 1
            } else {
               set val 0
            }
         }
         TPARAM_WDBI {
            if {[get_parameter_value MEM_DDR4_WRITE_DBI]} {
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
proc ::altera_emif::ip_arch_nd::ddrt::get_ctrl_params {} {
   set retval [dict create]

   set props         [_get_ctrl_amm_properties]
   set address_width [dict get $props WORD_ADDRESS_WIDTH]
   set data_width    [dict get $props WORD_WIDTH]
   set be_width      [dict get $props BYTE_ENABLE_WIDTH]
   set use_be        [dict get $props USE_BYTE_ENABLE]

   dict set retval CTRL_AMM_ADDRESS_WIDTH    $address_width
   dict set retval CTRL_AMM_DATA_WIDTH       $data_width
   dict set retval CTRL_AMM_BYTEEN_WIDTH     [expr {$use_be ? $be_width : 1}]

   return $retval
}

proc ::altera_emif::ip_arch_nd::ddrt::get_mem_params {} {
   set retval [dict create]

   dict set retval MEM_ROW_ADDR_WIDTH [get_parameter_value MEM_DDRT_ROW_ADDR_WIDTH]
   dict set retval MEM_COL_ADDR_WIDTH [get_parameter_value MEM_DDRT_COL_ADDR_WIDTH]

   return $retval
}

proc ::altera_emif::ip_arch_nd::ddrt::is_phy_tracking_enabled {} {
   return [::altera_emif::ip_arch_nd::ddrx::is_phy_tracking_enabled]
}

proc ::altera_emif::ip_arch_nd::ddrt::is_phy_shadow_register_disabled {} {
   set format_enum        [get_parameter_value MEM_DDRT_FORMAT_ENUM]
   set num_of_dimms       [get_parameter_value MEM_DDRT_NUM_OF_DIMMS]
   set write_lat          [get_parameter_value MEM_WRITE_LATENCY]
   set phy_config_enum    [get_parameter_value PHY_CONFIG_ENUM]
   set clk_ratios         [get_clk_ratios]
   set phy_hmc_clk_ratio  [expr {[dict get $clk_ratios PHY_HMC] * 1.0}]

   if {$format_enum == "MEM_FORMAT_LRDIMM" && $num_of_dimms == 1} {
      return 1
   } elseif {$phy_config_enum == "CONFIG_PHY_AND_HARD_CTRL" && $phy_hmc_clk_ratio == 4} {
      if {$write_lat < 18} {
         return 1
      } else {
         return 0
      }
   } else {
      return 0
   }
}


proc ::altera_emif::ip_arch_nd::ddrt::_get_mem_ports {} {
   set ports [list]

   set alert_en         [get_parameter_value MEM_DDRT_ALERT_PAR_EN]
   set ck_width         [get_parameter_value MEM_DDRT_TTL_CK_WIDTH]
   set addr_width       [get_parameter_value MEM_DDRT_TTL_ADDR_WIDTH]
   set bank_addr_width  [get_parameter_value MEM_DDRT_TTL_BANK_ADDR_WIDTH]
   set bank_group_width [get_parameter_value MEM_DDRT_TTL_BANK_GROUP_WIDTH]
   set chip_id_width    [get_parameter_value MEM_DDRT_TTL_CHIP_ID_WIDTH]
   set cke_width        [get_parameter_value MEM_DDRT_TTL_CKE_WIDTH]
   set cs_width         [get_parameter_value MEM_DDRT_TTL_CS_WIDTH]
   set rm_width         [get_parameter_value MEM_DDRT_TTL_RM_WIDTH]
   set odt_width        [get_parameter_value MEM_DDRT_TTL_ODT_WIDTH]
   set gnt_n_width      [get_parameter_value MEM_DDRT_TTL_GNT_N_WIDTH]
   set req_n_width      [get_parameter_value MEM_DDRT_TTL_REQ_N_WIDTH]
   set err_n_width      [get_parameter_value MEM_DDRT_TTL_ERR_N_WIDTH]
   set dqs_width        [get_parameter_value MEM_DDRT_TTL_DQS_WIDTH]
   set dq_width         [get_parameter_value MEM_DDRT_TTL_DQ_WIDTH]
   set config_enum      [get_parameter_value PHY_DDRT_CONFIG_ENUM]
   set use_dbi_port     [expr [get_parameter_value MEM_DDRT_DM_EN] || [get_parameter_value MEM_DDRT_READ_DBI] || [get_parameter_value MEM_DDRT_WRITE_DBI]]
   set dbi_n_width      [expr {$use_dbi_port ? $dqs_width : 1}]
   set chip_id_en       [expr {$chip_id_width > 0 ? 1: 0}]
   set rm_en            [expr {$rm_width > 0 ? 1: 0}]

   lappend ports {*}[create_port  true          PORT_MEM_CK_BIDIR     $ck_width           [get_db_configs  PIN_RATE_DDR  $config_enum  DB_PIN_TYPE_DDR4_DQS         ]]
   lappend ports {*}[create_port  true          PORT_MEM_CK_BIDIR_N   $ck_width           [get_db_configs  PIN_RATE_DDR  $config_enum  DB_PIN_TYPE_DDR4_DQS_N       ]]
   lappend ports {*}[create_port  true          PORT_MEM_A            $addr_width         [get_db_configs  PIN_RATE_SDR  $config_enum  DB_PIN_TYPE_AC               ]]
   lappend ports {*}[create_port  true          PORT_MEM_ACT_N        1                   [get_db_configs  PIN_RATE_SDR  $config_enum  DB_PIN_TYPE_AC               ]]
   lappend ports {*}[create_port  true          PORT_MEM_BA           $bank_addr_width    [get_db_configs  PIN_RATE_SDR  $config_enum  DB_PIN_TYPE_AC               ]]
   lappend ports {*}[create_port  true          PORT_MEM_BG           $bank_group_width   [get_db_configs  PIN_RATE_SDR  $config_enum  DB_PIN_TYPE_AC               ]]
   lappend ports {*}[create_port  true          PORT_MEM_C            $chip_id_width      [get_db_configs  PIN_RATE_SDR  $config_enum  DB_PIN_TYPE_AC               ]]
   lappend ports {*}[create_port  true          PORT_MEM_CKE          $cke_width          [get_db_configs  PIN_RATE_SDR  $config_enum  DB_PIN_TYPE_AC               ]]
   lappend ports {*}[create_port  true          PORT_MEM_CS_N         $cs_width           [get_db_configs  PIN_RATE_SDR  $config_enum  DB_PIN_TYPE_AC               ]]
   lappend ports {*}[create_port  $rm_en        PORT_MEM_RM           $rm_width           [get_db_configs  PIN_RATE_SDR  $config_enum  DB_PIN_TYPE_AC               ]]
   lappend ports {*}[create_port  true          PORT_MEM_ODT          $odt_width          [get_db_configs  PIN_RATE_SDR  $config_enum  DB_PIN_TYPE_AC               ]]
   lappend ports {*}[create_port  true          PORT_MEM_GNT_N        $gnt_n_width        [get_db_configs  PIN_RATE_SDR  $config_enum  DB_PIN_TYPE_AC               ]]
   lappend ports {*}[create_port  true          PORT_MEM_REQ_N        $req_n_width        [get_db_configs  PIN_RATE_SDR  $config_enum  DB_PIN_TYPE_DQ               ]]
   lappend ports {*}[create_port  true          PORT_MEM_ERR_N        $err_n_width        [get_db_configs  PIN_RATE_SDR  $config_enum  DB_PIN_TYPE_DQ               ]]
   lappend ports {*}[create_port  true          PORT_MEM_RESET_N      1                   [get_db_configs  PIN_RATE_SDR  $config_enum  DB_PIN_TYPE_AC               ]]
   lappend ports {*}[create_port  true          PORT_MEM_PAR          1                   [get_db_configs  PIN_RATE_SDR  $config_enum  DB_PIN_TYPE_AC               ]]
   lappend ports {*}[create_port  true          PORT_MEM_ALERT_N      1                   [get_db_configs  PIN_RATE_SDR  $config_enum  DB_PIN_TYPE_ALERT_N          ]]
   lappend ports {*}[create_port  true          PORT_MEM_DQS          $dqs_width          [get_db_configs  PIN_RATE_DDR  $config_enum  DB_PIN_TYPE_DDR4_DQS         ]]
   lappend ports {*}[create_port  true          PORT_MEM_DQS_N        $dqs_width          [get_db_configs  PIN_RATE_DDR  $config_enum  DB_PIN_TYPE_DDR4_DQS_N       ]]
   lappend ports {*}[create_port  true          PORT_MEM_DQ           $dq_width           [get_db_configs  PIN_RATE_DDR  $config_enum  DB_PIN_TYPE_DQ_WITH_DBI_CRC  ]]

   lappend ports {*}[create_port  $use_dbi_port PORT_MEM_DBI_N        $dbi_n_width        [get_db_configs  PIN_RATE_DDR  $config_enum  DB_PIN_TYPE_DQ_WITH_DBI_CRC  ]]

   return $ports
}

proc ::altera_emif::ip_arch_nd::ddrt::_get_afi_ports {} {
   set ports [list]

   set ports [altera_emif::ip_arch_nd::util::get_common_afi_ports]

   set clk_ratios        [get_clk_ratios]
   set sdr_ratio         [dict get $clk_ratios C2P_P2C]
   set ddr_ratio         [expr {$sdr_ratio * 2}]

   set addr_width        [expr {[get_parameter_value MEM_DDRT_TTL_ADDR_WIDTH]       * $sdr_ratio}]
   set bank_addr_width   [expr {[get_parameter_value MEM_DDRT_TTL_BANK_ADDR_WIDTH]  * $sdr_ratio}]
   set bank_group_width  [expr {[get_parameter_value MEM_DDRT_TTL_BANK_GROUP_WIDTH] * $sdr_ratio}]
   set chip_id_width     [expr {[get_parameter_value MEM_DDRT_TTL_CHIP_ID_WIDTH]    * $sdr_ratio}]
   set cke_width         [expr {[get_parameter_value MEM_DDRT_TTL_CKE_WIDTH]        * $sdr_ratio}]
   set cs_width          [expr {[get_parameter_value MEM_DDRT_TTL_CS_WIDTH]         * $sdr_ratio}]
   set rm_width          [expr {[get_parameter_value MEM_DDRT_TTL_RM_WIDTH]         * $sdr_ratio}]
   set odt_width         [expr {[get_parameter_value MEM_DDRT_TTL_ODT_WIDTH]        * $sdr_ratio}]
   set gnt_n_width       [expr {[get_parameter_value MEM_DDRT_TTL_GNT_N_WIDTH]      * $sdr_ratio}]
   set req_n_width       [expr {[get_parameter_value MEM_DDRT_TTL_REQ_N_WIDTH]      * $sdr_ratio}]
   set err_n_width       [expr {[get_parameter_value MEM_DDRT_TTL_ERR_N_WIDTH]      * $sdr_ratio}]
   set data_width        [expr {[get_parameter_value MEM_DDRT_TTL_DQ_WIDTH]         * $ddr_ratio}]
   set dm_width          [expr {[get_parameter_value MEM_DDRT_TTL_DQS_WIDTH]        * $ddr_ratio}]

   set dm_en            [get_parameter_value MEM_DDRT_DM_EN]
   set chip_id_en       [expr {$chip_id_width > 0 ? 1: 0}]
   set rm_en            [expr {$rm_width > 0 ? 1: 0}]
   
   set format_enum      [get_parameter_value MEM_DDRT_FORMAT_ENUM]
   set tpl_cyc          [enum_data [get_parameter_value MEM_DDRT_AC_PARITY_LATENCY] VALUE]
   set par_en           [expr {($tpl_cyc > 0) || ($format_enum == "MEM_FORMAT_LRDIMM") || ($format_enum == "MEM_FORMAT_RDIMM")}]

   set physical_ranks     [get_parameter_value MEM_DDRT_TTL_NUM_OF_PHYSICAL_RANKS]
   emif_assert {$physical_ranks >= 1 && $physical_ranks <= 4}
   set rank_en           [expr {$physical_ranks > 1 ? 1 : 0}]
   set rank_width        [expr {$physical_ranks * $sdr_ratio}]

   lappend ports {*}[create_port  true        PORT_AFI_ADDR                     $addr_width          ]
   lappend ports {*}[create_port  true        PORT_AFI_BA                       $bank_addr_width     ]
   lappend ports {*}[create_port  true        PORT_AFI_BG                       $bank_group_width    ]
   lappend ports {*}[create_port  true        PORT_AFI_C                        $chip_id_width       ]
   lappend ports {*}[create_port  true        PORT_AFI_CKE                      $cke_width           ]
   lappend ports {*}[create_port  true        PORT_AFI_CS_N                     $cs_width            ]
   lappend ports {*}[create_port  true        PORT_AFI_ACT_N                    $sdr_ratio           ]
   lappend ports {*}[create_port  $rm_en      PORT_AFI_RM                       $rm_width            ]
   lappend ports {*}[create_port  true        PORT_AFI_ODT                      $odt_width           ]
   lappend ports {*}[create_port  true        PORT_AFI_GNT_N                      $gnt_n_width           ]
   lappend ports {*}[create_port  true        PORT_AFI_REQ_N                      $req_n_width           ]
   lappend ports {*}[create_port  true        PORT_AFI_ERR_N                      $err_n_width           ]
   lappend ports {*}[create_port  true        PORT_AFI_RST_N                    $sdr_ratio           ]
   lappend ports {*}[create_port  true        PORT_AFI_PAR                      $sdr_ratio           ]
   lappend ports {*}[create_port  $dm_en      PORT_AFI_DM_N                     $dm_width            ]
   lappend ports {*}[create_port  true        PORT_AFI_DQS_BURST                $sdr_ratio           ]
   lappend ports {*}[create_port  true        PORT_AFI_WDATA_VALID              $sdr_ratio           ]
   lappend ports {*}[create_port  true        PORT_AFI_WDATA                    $data_width          ]
   lappend ports {*}[create_port  true        PORT_AFI_RDATA_EN_FULL            $sdr_ratio           ]
   lappend ports {*}[create_port  true        PORT_AFI_RDATA                    $data_width          ]
   lappend ports {*}[create_port  true        PORT_AFI_RDATA_VALID              $sdr_ratio           ]
   lappend ports {*}[create_port  $rank_en    PORT_AFI_RRANK                    $rank_width          ]
   lappend ports {*}[create_port  $rank_en    PORT_AFI_WRANK                    $rank_width          ]

   lappend ports {*}[create_port  true        PORT_AFI_ALERT_N                  $sdr_ratio           ]

   return $ports
}

proc ::altera_emif::ip_arch_nd::ddrt::_get_afi_mem_clk_disable_ports {} {
   set ports [list]

   lappend ports {*}[create_port  true        PORT_AFI_MEM_CLK_DISABLE     1]

   return $ports
}

proc ::altera_emif::ip_arch_nd::ddrt::_get_ctrl_ast_properties {is_write} {
   set props [dict create]

   set clk_ratios         [get_clk_ratios]
   set c2p_p2c_clk_ratio  [dict get $clk_ratios C2P_P2C]
   set ecc_en             [get_parameter_value CTRL_ECC_EN]
   set dm_en              [get_parameter_value MEM_DDRT_DM_EN]

   set dq_width           [get_parameter_value MEM_DDRT_DQ_WIDTH]
   set dm_width           [expr {$dm_en ? [get_parameter_value MEM_DDRT_DQS_WIDTH] : 0}]

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

proc ::altera_emif::ip_arch_nd::ddrt::_get_ctrl_ast_cmd_properties {} {
   set props [dict create]

   dict set props WORD_WIDTH            61
   dict set props SYMBOL_WIDTH          1
   dict set props SYMBOLS_PER_WORD      61
   dict set props BYTE_ENABLE_WIDTH     0
   dict set props USE_BYTE_ENABLE       false

   return $props
}

proc ::altera_emif::ip_arch_nd::ddrt::_get_ctrl_ast_cmd_ports {} {
   set ports [list]

   set props             [_get_ctrl_ast_cmd_properties]
   set data_width        [dict get $props WORD_WIDTH]

   lappend ports {*}[create_port  true        PORT_CTRL_AST_CMD_VALID     1                 ]
   lappend ports {*}[create_port  true        PORT_CTRL_AST_CMD_READY     1                 ]
   lappend ports {*}[create_port  true        PORT_CTRL_AST_CMD_DATA      $data_width       ]

   return $ports
}

proc ::altera_emif::ip_arch_nd::ddrt::_get_ctrl_ast_wr_ports {} {
   set ports [list]

   set props             [_get_ctrl_ast_properties true]
   set data_width        [dict get $props WORD_WIDTH]

   lappend ports {*}[create_port  true        PORT_CTRL_AST_WR_VALID      1                 ]
   lappend ports {*}[create_port  true        PORT_CTRL_AST_WR_READY      1                 ]
   lappend ports {*}[create_port  true        PORT_CTRL_AST_WR_DATA       $data_width       ]

   return $ports
}

proc ::altera_emif::ip_arch_nd::ddrt::_get_ctrl_ast_rd_ports {} {
   set ports [list]
   set props          [_get_ctrl_ast_properties false]
   set data_width     [dict get $props WORD_WIDTH]

   lappend ports {*}[create_port  true        PORT_CTRL_AST_RD_VALID      1                ]
   lappend ports {*}[create_port  true        PORT_CTRL_AST_RD_READY      1                ]
   lappend ports {*}[create_port  true        PORT_CTRL_AST_RD_DATA       $data_width      ]

   return $ports
}

proc ::altera_emif::ip_arch_nd::ddrt::_get_ctrl_amm_properties {} {
   set props [dict create]

   set clk_ratios            [get_clk_ratios]
   set c2p_p2c_clk_ratio     [dict get $clk_ratios C2P_P2C]
   set enable_ecc            [get_parameter_value CTRL_ECC_EN]
   set dq_per_dqs            [get_parameter_value MEM_DDRT_DQ_PER_DQS]
   set dm_en                 [get_parameter_value MEM_DDRT_DM_EN]

   set dq_width              [get_parameter_value MEM_DDRT_DQ_WIDTH]
   set dm_width              [expr {$dm_en ? [get_parameter_value MEM_DDRT_DQS_WIDTH] : 0}]
   set row_addr_width        [get_parameter_value MEM_DDRT_ROW_ADDR_WIDTH]
   set col_addr_width        [get_parameter_value MEM_DDRT_COL_ADDR_WIDTH]
   set bank_addr_width       [get_parameter_value MEM_DDRT_BANK_ADDR_WIDTH]
   set bank_group_width      [get_parameter_value MEM_DDRT_BANK_GROUP_WIDTH]
   set chip_id_width         [get_parameter_value MEM_DDRT_CHIP_ID_WIDTH]
   set num_of_physical_ranks [get_parameter_value MEM_DDRT_NUM_OF_PHYSICAL_RANKS]

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
   set word_address_width      [expr {$row_addr_width + $col_addr_width + $bank_addr_width + $bank_group_width + $chip_id_width + int(ceil([log2 $num_of_physical_ranks])) - int(ceil([log2 $avl_to_dq_width_ratio])) }]
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

proc ::altera_emif::ip_arch_nd::ddrt::_get_ctrl_amm_ports {} {
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

proc ::altera_emif::ip_arch_nd::ddrt::_get_ctrl_user_refresh_ports {} {
   set ports [list]

   set bank [get_parameter_value DIAG_EXPOSE_DFT_SIGNALS]

   lappend ports {*}[create_port  true        PORT_CTRL_USER_REFRESH_ACK  "default"        ]
   lappend ports {*}[create_port  true        PORT_CTRL_USER_REFRESH_REQ  "default"        ]
   lappend ports {*}[create_port  $bank       PORT_CTRL_USER_REFRESH_BANK "default"        ]

   return $ports
}

proc ::altera_emif::ip_arch_nd::ddrt::_init {} {
}

::altera_emif::ip_arch_nd::ddrt::_init

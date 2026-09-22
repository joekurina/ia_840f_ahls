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


package provide altera_emif::ip_arch_fm::protocol_expert 0.1

package require altera_emif::util::messaging
package require altera_emif::util::qini
package require altera_emif::util::hwtcl_utils
package require altera_emif::util::enums
package require altera_emif::util::enum_defs
package require altera_emif::util::device_family
package require altera_emif::ip_arch_fm::util

foreach protocol_enum [::altera_emif::util::enums::enums_of_type PROTOCOL] {
   if {$protocol_enum == "PROTOCOL_INVALID"} {
      continue
   }

   set protocol_module [::altera_emif::util::enums::enum_data $protocol_enum MODULE_NAME]
   set package_name "altera_emif::ip_arch_fm::${protocol_module}"
   set rc [catch {set version [package require $package_name]} result options]
}

set rc [catch {set version [package require altera_emif::ip_arch_fm::phylite]} result options]

namespace eval ::altera_emif::ip_arch_fm::protocol_expert:: {

   namespace import ::altera_emif::util::messaging::*
   namespace import ::altera_emif::util::qini::*
   namespace import ::altera_emif::util::enums::*
   namespace import ::altera_emif::util::hwtcl_utils::*
   namespace import ::altera_emif::util::device_family::*
   namespace import ::altera_emif::ip_arch_fm::util::*


}



proc ::altera_emif::ip_arch_fm::protocol_expert::run_elab_time_utests {} {

   set protocol_enum [get_parameter_value PROTOCOL_ENUM]

   set fname [_get_func_name "get_num_and_type_of_hmc_ports" $protocol_enum]
   emif_utest_start $fname
   set hmc_is_used   [expr {[dict get [$fname] CTRL_AVL_PROTOCOL_ENUM] == "CTRL_AVL_PROTOCOL_INVALID" ? 0 : 1}]
   emif_utest_pass

   if {$hmc_is_used} {
      set fname [_get_func_name "get_interface_properties" $protocol_enum]
      emif_utest_start $fname
      $fname IF_CTRL_AMM
      $fname IF_CTRL_AST_CMD
      $fname IF_CTRL_AST_RD
      $fname IF_CTRL_AST_WR
      emif_utest_pass
   }

   set fname [_get_func_name "get_ac_pin_map_scheme" $protocol_enum]
   emif_utest_start $fname
   $fname
   emif_utest_pass

   set fname [_get_func_name "get_resource_consumption" $protocol_enum]
   emif_utest_start $fname
   $fname
   emif_utest_pass

   set fname_gip [_get_func_name "get_interface_ports" $protocol_enum]
   set fname_amp [_get_func_name "alloc_mem_pins" $protocol_enum]
   set fname_ais [_get_func_name "assign_io_settings" $protocol_enum]
   emif_utest_start $fname_gip
   set mem_ports [$fname_gip IF_MEM]
   emif_utest_pass

   emif_utest_start $fname_amp
   set mem_pins_alloc [$fname_amp mem_ports]
   emif_utest_pass

   emif_utest_start $fname_ais
   $fname_ais mem_ports
   emif_utest_pass

   set fname [_get_func_name "get_dqs_bus_mode" $protocol_enum]
   emif_utest_start $fname
   $fname
   emif_utest_pass

   set fname [_get_func_name "get_clk_ratios" $protocol_enum]
   emif_utest_start $fname
   $fname
   emif_utest_pass

   set fname [_get_func_name "get_lane_cfgs" $protocol_enum]
   emif_utest_start $fname
   $fname
   emif_utest_pass

   set fname [_get_func_name "get_hmc_cfgs" $protocol_enum]
   emif_utest_start $fname
   $fname "PRI"
   emif_utest_pass

   set fname [_get_func_name "get_timing_params" $protocol_enum]
   emif_utest_start $fname
   $fname
   emif_utest_pass

}

proc ::altera_emif::ip_arch_fm::protocol_expert::get_num_of_interfaces_used {if_enum} {
   set retval 0

   switch $if_enum {
      IF_LOCAL_RESET_REQ -
      IF_PLL_REF_CLK {
         set core_clks_sharing_enum [get_parameter_value PHY_CORE_CLKS_SHARING_ENUM]
         set retval [expr {$core_clks_sharing_enum != "CORE_CLKS_SHARING_SLAVE" ? 1 : 0}]
      }
      IF_PLL_REF_CLK_OUT {
         set export_pll_ref_clk_out [get_parameter_value DIAG_EXPORT_PLL_REF_CLK_OUT]
         set retval [expr {$export_pll_ref_clk_out ? 1 : 0}]
      }
      IF_PLL_LOCKED {
         set export_pll_locked [get_parameter_value DIAG_EXPORT_PLL_LOCKED]

         set num_of_extra_clks [get_parameter_value PLL_NUM_OF_EXTRA_CLKS]
         set has_extra_clocks  [expr {$num_of_extra_clks > 0 ? 1 : 0}]

         set retval [expr {($export_pll_locked || $has_extra_clocks) ? 1 : 0}]
      }
      IF_PLL_EXTRA_CLK_0 -
      IF_PLL_EXTRA_CLK_1 -
      IF_PLL_EXTRA_CLK_2 -
      IF_PLL_EXTRA_CLK_3 {
         set num_of_extra_clks [get_parameter_value PLL_NUM_OF_EXTRA_CLKS]
         if {[regexp {^IF_PLL_EXTRA_CLK_([0-9]+)$} $if_enum matched clk_num] == 1} {
            if {$clk_num < $num_of_extra_clks} {
               set retval 1
            } else {
               set retval 0
            }
         } else {
            emif_ie "Unable to parse $if_enum to extra clk_num"
         }
      }
      IF_CLKS_SHARING_MASTER_OUT {
         set core_clks_sharing_enum [get_parameter_value PHY_CORE_CLKS_SHARING_ENUM]
         set retval [expr {$core_clks_sharing_enum == "CORE_CLKS_SHARING_MASTER" ? 1 : 0}]
      }
      IF_CLKS_SHARING_SLAVE_IN {
         set core_clks_sharing_enum [get_parameter_value PHY_CORE_CLKS_SHARING_ENUM]
         set retval [expr {$core_clks_sharing_enum == "CORE_CLKS_SHARING_SLAVE" ? 1 : 0}]
      }
      IF_CLKS_SHARING_SLAVE_OUT {
         set core_clks_sharing_enum [get_parameter_value PHY_CORE_CLKS_SHARING_ENUM]
         set expose_clks_sharing_slave_out [get_parameter_value PHY_CORE_CLKS_SHARING_EXPOSE_SLAVE_OUT]
         set retval [expr {($core_clks_sharing_enum == "CORE_CLKS_SHARING_SLAVE" && $expose_clks_sharing_slave_out) ? 1 : 0}]
      }
      IF_OCT {
         set use_cal_oct [get_parameter_value PHY_CALIBRATED_OCT]
         set retval [expr {$use_cal_oct ? 1 : 0}]
      }
      IF_LOCAL_RESET_STATUS -
      IF_STATUS {
         set retval 1
      }
      IF_AC_PARITY_ERR {
         set protocol_enum [get_parameter_value PROTOCOL_ENUM]
         set export_ac_parity_err [get_parameter_value DIAG_DDR4_AC_PARITY_ERR]
         set retval [expr {($protocol_enum == "PROTOCOL_DDR4" && $export_ac_parity_err) ? 1 : 0}]
      }
      IF_AFI -
      IF_AFI_RESET -
      IF_AFI_CLK -
      IF_AFI_HALF_CLK {
         set hmc_ifs [get_num_and_type_of_hmc_ports]
         set retval [expr {[dict get $hmc_ifs NUM_OF_PORTS] == 0 ? 1 : 0}]
      }
      IF_EMIF_USR_RESET -
      IF_EMIF_USR_CLK -
      IF_EMIF_USR_HALF_CLK {
         set hmc_ifs [get_num_and_type_of_hmc_ports]
         if {[dict get $hmc_ifs NUM_OF_PORTS] == 0} {
            set retval 0
         } else {
            if {$if_enum == "IF_EMIF_USR_HALF_CLK"} {
               set retval [expr {[needs_emif_usr_half_clk] ? 1 : 0}]
            } else {
               set retval 1
            }
         }
      }
      IF_EMIF_USR_RESET_SEC -
      IF_EMIF_USR_CLK_SEC -
      IF_EMIF_USR_HALF_CLK_SEC {
         set ping_pong_en [get_parameter_value PHY_PING_PONG_EN]
         if {$ping_pong_en} {
            set hmc_ifs [get_num_and_type_of_hmc_ports]
            if {[dict get $hmc_ifs NUM_OF_PORTS] == 0} {
               set retval 0
            } else {
               if {$if_enum == "IF_EMIF_USR_HALF_CLK_SEC"} {
                  set retval [expr {[needs_emif_usr_half_clk] ? 1 : 0}]
               } else {
                  set retval 1
               }
            }
         } else {
            set retval 0
         }
      }
      IF_MEM {
         set retval 1
      }
      IF_PHYLITE {
         set phylite [::altera_emif::util::qini::ini_is_on "generate_phylite"]
         set retval $phylite
      }
      IF_CTRL_AST_CMD -
      IF_CTRL_AST_WR -
      IF_CTRL_AST_RD {
         set hmc_ifs [get_num_and_type_of_hmc_ports]
         if {[dict get $hmc_ifs CTRL_AVL_PROTOCOL_ENUM] == "CTRL_AVL_PROTOCOL_ST"} {
            set retval [dict get $hmc_ifs NUM_OF_PORTS]
         } else {
            set retval 0
         }
      }
      IF_CTRL_AMM {
         set hmc_ifs [get_num_and_type_of_hmc_ports]
         if {[dict get $hmc_ifs CTRL_AVL_PROTOCOL_ENUM] == "CTRL_AVL_PROTOCOL_MM"} {
            set retval [dict get $hmc_ifs NUM_OF_PORTS]
         } else {
            set retval 0
         }
      }
      IF_CTRL_AMM_AUX {
         set hmc_ifs [get_num_and_type_of_hmc_ports]
         if {[dict get $hmc_ifs CTRL_AVL_PROTOCOL_ENUM] == "CTRL_AVL_PROTOCOL_MM" && [get_parameter_value DIAG_EXPOSE_EARLY_READY] && [get_parameter_value DIAG_ADD_READY_PIPELINE] } {
            set retval [dict get $hmc_ifs NUM_OF_PORTS]
         } else {
            set retval 0
         }
      }
      IF_CTRL_AMM_RD_TYPE {
         set hmc_ifs [get_num_and_type_of_hmc_ports]
         if {[dict get $hmc_ifs CTRL_AVL_PROTOCOL_ENUM] == "CTRL_AVL_PROTOCOL_MM" && [get_parameter_value DIAG_EXPOSE_RD_TYPE]} {
            set retval [dict get $hmc_ifs NUM_OF_PORTS]
         } else {
            set retval 0
         }
      }
      IF_CTRL_AUTO_PRECHARGE {
         if {[is_ctrl_sideband_interface_enabled "IF_CTRL_AUTO_PRECHARGE"]} {
            set hmc_ifs [get_num_and_type_of_hmc_ports]
            if {[dict get $hmc_ifs CTRL_AVL_PROTOCOL_ENUM] == "CTRL_AVL_PROTOCOL_MM"} {
               set retval [dict get $hmc_ifs NUM_OF_PORTS]
            } else {
               set retval 0
            }
         } else {
            set retval 0
         }
      }
      IF_CTRL_USER_PRIORITY {
         if {[is_ctrl_sideband_interface_enabled "IF_CTRL_USER_PRIORITY"]} {
            set hmc_ifs [get_num_and_type_of_hmc_ports]
            if {[dict get $hmc_ifs CTRL_AVL_PROTOCOL_ENUM] == "CTRL_AVL_PROTOCOL_MM"} {
               set retval [dict get $hmc_ifs NUM_OF_PORTS]
            } else {
               set retval 0
            }
         } else {
            set retval 0
         }
      }
      IF_CTRL_ECC {
         if {[is_ctrl_sideband_interface_enabled $if_enum]} {
            set ping_pong_en [get_parameter_value PHY_PING_PONG_EN]
            set retval [expr {$ping_pong_en ? 2 : 1}]
         } elseif {[get_parameter_value "DIAG_EXPOSE_DFT_SIGNALS"]} {
            set extra_configs_str [get_parameter_value "DIAG_EXTRA_CONFIGS"]
            set extra_configs [parse_extra_configs $extra_configs_str]
            set retval [expr {[extra_config_is_explicit_on $extra_configs DIAG_FORCE_EXPOSE_ECC] ? 1 : 0}]
         } else {
            set retval 0
         }
      }
      IF_CTRL_USER_REFRESH -
      IF_CTRL_SELF_REFRESH -
      IF_CTRL_WILL_REFRESH -
      IF_CTRL_DEEP_POWER_DOWN -
      IF_CTRL_POWER_DOWN -
      IF_CTRL_ZQ_CAL {
         if {[is_ctrl_sideband_interface_enabled $if_enum] && [get_parameter_value "DIAG_EXPOSE_DFT_SIGNALS"]} {
            set retval 1
         } else {
            set retval 0
         }
      }
      IF_CTRL_MMR_SLAVE {
         if {[is_ctrl_sideband_interface_enabled $if_enum]} {
            set ping_pong_en [get_parameter_value PHY_PING_PONG_EN]
            set retval [expr {$ping_pong_en ? 2 : 1}]
         } else {
            set retval 0
         }
      }
      IF_HPS_EMIF {
         set retval [expr {[get_is_hps] ? 1 : 0}]
      }
      IF_DFT_ND {
         set retval [expr {[get_parameter_value "DIAG_EXPOSE_DFT_SIGNALS"] ? 1 : 0}]
      }
      IF_CALBUS_CLK -
      IF_CALBUS {
         set retval 1
      }
      default {
         set retval 0
      }
   }
   return $retval
}

proc ::altera_emif::ip_arch_fm::protocol_expert::get_interface_ports {if_enum} {
   set ports [list]

   switch $if_enum {
      IF_LOCAL_RESET_REQ -
      IF_LOCAL_RESET_STATUS -
      IF_PLL_REF_CLK -
      IF_PLL_REF_CLK_OUT -
      IF_PLL_LOCKED -
      IF_PLL_EXTRA_CLK_0 -
      IF_PLL_EXTRA_CLK_1 -
      IF_PLL_EXTRA_CLK_2 -
      IF_PLL_EXTRA_CLK_3 -
      IF_CLKS_SHARING_MASTER_OUT -
      IF_CLKS_SHARING_SLAVE_IN -
      IF_CLKS_SHARING_SLAVE_OUT -
      IF_VJI -
      IF_AC_PARITY_ERR -
      IF_OCT -
      IF_CTRL_AMM_AUX -
      IF_STATUS -
      IF_AFI_RESET -
      IF_AFI_CLK -
      IF_AFI_HALF_CLK -
      IF_EMIF_USR_RESET -
      IF_EMIF_USR_CLK -
      IF_EMIF_USR_HALF_CLK -
      IF_EMIF_USR_RESET_SEC -
      IF_EMIF_USR_CLK_SEC -
      IF_EMIF_USR_HALF_CLK_SEC -
      IF_CTRL_ECC -
      IF_CTRL_AUTO_PRECHARGE -
      IF_CTRL_USER_PRIORITY -
      IF_CTRL_SELF_REFRESH -
      IF_CTRL_WILL_REFRESH -
      IF_CTRL_DEEP_POWER_DOWN -
      IF_CTRL_POWER_DOWN -
      IF_CTRL_ZQ_CAL -
      IF_CTRL_MMR_SLAVE -
      IF_DFT_ND -
      IF_CALBUS -
      IF_CALBUS_CLK -
      IF_CTRL_AMM_RD_TYPE -
      IF_HPS_EMIF {
         set ports [::altera_emif::util::hwtcl_utils::get_default_ports $if_enum]
      }
      default {
         set func_name [_get_func_name "get_interface_ports"]
         set ports [$func_name $if_enum]
      }
   }

   return $ports
}

proc ::altera_emif::ip_arch_fm::protocol_expert::get_interface_properties {if_enum} {
   set func_name [_get_func_name "get_interface_properties"]
   return [$func_name $if_enum]
}

proc ::altera_emif::ip_arch_fm::protocol_expert::get_ac_pin_map_scheme {} {
   set func_name [_get_func_name "get_ac_pin_map_scheme"]
   return [$func_name]
}

proc ::altera_emif::ip_arch_fm::protocol_expert::get_resource_consumption {} {
   set func_name [_get_func_name "get_resource_consumption"]
   return [$func_name]
}

proc ::altera_emif::ip_arch_fm::protocol_expert::alloc_mem_pins {mem_ports_name} {
   upvar 1 $mem_ports_name mem_ports
   set func_name [_get_func_name "alloc_mem_pins"]
   return [$func_name mem_ports]
}

proc ::altera_emif::ip_arch_fm::protocol_expert::assign_io_settings {ports_name} {
   upvar 1 $ports_name ports
   set func_name [_get_func_name "assign_io_settings"]
   return [$func_name ports]
}

proc ::altera_emif::ip_arch_fm::protocol_expert::get_dqs_bus_mode {} {
   set func_name [_get_func_name "get_dqs_bus_mode"]
   return [$func_name]
}

proc ::altera_emif::ip_arch_fm::protocol_expert::get_clk_ratios {} {
   set func_name [_get_func_name "get_clk_ratios"]
   return [$func_name]
}

proc :::altera_emif::ip_arch_fm::protocol_expert::check_hmc_legality {} {
   set func_name [_get_func_name "check_hmc_legality"]
   return [$func_name]
}

proc ::altera_emif::ip_arch_fm::protocol_expert::get_num_and_type_of_hmc_ports {} {
   set func_name [_get_func_name "get_num_and_type_of_hmc_ports"]
   return [$func_name]
}

proc ::altera_emif::ip_arch_fm::protocol_expert::get_hmc_cfgs {hmc_inst} {
   set func_name [_get_func_name "get_hmc_cfgs"]
   return [$func_name $hmc_inst]
}

proc ::altera_emif::ip_arch_fm::protocol_expert::is_ctrl_sideband_interface_enabled {if_enum} {
   set func_name [_get_func_name "is_ctrl_sideband_interface_enabled"]
   return [$func_name $if_enum]
}

proc ::altera_emif::ip_arch_fm::protocol_expert::get_lane_cfgs {} {
   set func_name [_get_func_name "get_lane_cfgs"]
   return [$func_name]
}

proc ::altera_emif::ip_arch_fm::protocol_expert::derive_seq_param_tbl {seq_pt_enums} {
   set func_name [_get_func_name "derive_seq_param_tbl"]
   return [$func_name $seq_pt_enums]
}

proc ::altera_emif::ip_arch_fm::protocol_expert::get_timing_params {} {
   set func_name [_get_func_name "get_timing_params"]
   return [$func_name]
}

proc ::altera_emif::ip_arch_fm::protocol_expert::get_bsi_params { if_ports } {
   set func_name [_get_func_name "get_bsi_params"]
   return [$func_name $if_ports]
}

proc ::altera_emif::ip_arch_fm::protocol_expert::is_phy_tracking_enabled {} {
   set extra_configs_str [get_parameter_value "DIAG_EXTRA_CONFIGS"]
   set extra_configs     [parse_extra_configs $extra_configs_str]

   if {[extra_config_is_explicit_on $extra_configs FORCE_PHY_TRACKING_ON]} {
      return 1
   } elseif {[extra_config_is_explicit_on $extra_configs FORCE_PHY_TRACKING_OFF]} {
      return 0
   } else {
      set func_name [_get_func_name "is_phy_tracking_enabled"]
      return [$func_name]
   }
}

proc ::altera_emif::ip_arch_fm::protocol_expert::is_phy_shadow_register_disabled {} {
   set extra_configs_str [get_parameter_value "DIAG_EXTRA_CONFIGS"]
   set extra_configs     [parse_extra_configs $extra_configs_str]

   if {[extra_config_is_explicit_on $extra_configs FORCE_SHADOW_REGISTER_OFF]} {
      return 1
   } else {
      set func_name [_get_func_name "is_phy_shadow_register_disabled"]
      return [$func_name]
   }
}

proc ::altera_emif::ip_arch_fm::protocol_expert::needs_emif_usr_half_clk {} {
   set ratios              [altera_emif::ip_arch_fm::protocol_expert::get_clk_ratios]
   set user_clk_ratio      [dict get $ratios USER]
   set c2p_p2c_clk_ratio   [dict get $ratios C2P_P2C]
   return [expr {$user_clk_ratio == 2 && $c2p_p2c_clk_ratio == 4 ? 1 : 0}]
}


proc ::altera_emif::ip_arch_fm::protocol_expert::_get_func_name {base_name {forced_protocol_enum ""}} {

   if {$forced_protocol_enum == ""} {
      set protocol_enum [get_parameter_value PROTOCOL_ENUM]
   } else {
      emif_assert {[emif_utest_enabled]}
      set protocol_enum $forced_protocol_enum
   }

   set protocol_module [::altera_emif::util::enums::enum_data $protocol_enum MODULE_NAME]

   set phylite [::altera_emif::util::qini::ini_is_on "generate_phylite"]
   if {$phylite == 1 && $protocol_module == "ddr4"} {
      set full_module "::altera_emif::ip_arch_fm::phylite"
   } else {
      set full_module "::altera_emif::ip_arch_fm::${protocol_module}"
   }

   set func_name "${full_module}::${base_name}"

   if {[llength [info proc $func_name]] != 1} {
      emif_ie "Function $func_name not implemented!"
   }
   return $func_name
}

proc ::altera_emif::ip_arch_fm::protocol_expert::_init {} {
}

::altera_emif::ip_arch_fm::protocol_expert::_init

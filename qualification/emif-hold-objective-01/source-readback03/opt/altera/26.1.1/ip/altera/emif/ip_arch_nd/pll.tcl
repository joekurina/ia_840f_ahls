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


package provide altera_emif::ip_arch_nd::pll 0.1

package require altera_emif::util::messaging
package require altera_emif::util::qini
package require altera_emif::util::hwtcl_utils
package require altera_emif::util::enums
package require altera_emif::util::device_family
package require altera_emif::ip_arch_nd::util
package require altera_emif::ip_arch_nd::protocol_expert

lappend auto_path $env(QUARTUS_ROOTDIR)/common/tcl/packages/pll
package require ::quartus::pll::legality

namespace eval ::altera_emif::ip_arch_nd::pll:: {
   
   namespace import ::altera_emif::util::messaging::*
   namespace import ::altera_emif::util::qini::*
   namespace import ::altera_emif::util::math::*
   namespace import ::altera_emif::util::enums::*
   namespace import ::altera_emif::util::hwtcl_utils::*
   namespace import ::altera_emif::util::device_family::*
   namespace import ::altera_emif::ip_arch_nd::util::*
   namespace import ::altera_emif::ip_arch_nd::protocol_expert::*

}


proc ::altera_emif::ip_arch_nd::pll::add_pll_parameters {} {

   add_derived_hdl_param PLL_VCO_FREQ_MHZ_INT             integer          0
   add_derived_hdl_param PLL_VCO_TO_MEM_CLK_FREQ_RATIO    integer          1
   add_derived_hdl_param PLL_PHY_CLK_VCO_PHASE            integer          0
   
   add_derived_hdl_param PLL_VCO_FREQ_PS_STR              string           ""
   add_derived_hdl_param PLL_REF_CLK_FREQ_PS_STR          string           ""
   
   add_derived_hdl_param PLL_REF_CLK_FREQ_PS              integer          0
   add_derived_hdl_param PLL_SIM_VCO_FREQ_PS              integer          0
   add_derived_hdl_param PLL_SIM_PHYCLK_0_FREQ_PS         integer          0
   add_derived_hdl_param PLL_SIM_PHYCLK_1_FREQ_PS         integer          0
   add_derived_hdl_param PLL_SIM_PHYCLK_FB_FREQ_PS        integer          0
   add_derived_hdl_param PLL_SIM_PHY_CLK_VCO_PHASE_PS     integer          0
   add_derived_hdl_param PLL_SIM_CAL_SLAVE_CLK_FREQ_PS    integer          0
   add_derived_hdl_param PLL_SIM_CAL_MASTER_CLK_FREQ_PS   integer          0
   
   add_derived_hdl_param PLL_M_CNT_HIGH                   integer          0
   add_derived_hdl_param PLL_M_CNT_LOW                    integer          0
   add_derived_hdl_param PLL_N_CNT_HIGH                   integer          256
   add_derived_hdl_param PLL_N_CNT_LOW                    integer          256
   add_derived_hdl_param PLL_M_CNT_BYPASS_EN              string           "false"
   add_derived_hdl_param PLL_N_CNT_BYPASS_EN              string           "true"
   add_derived_hdl_param PLL_M_CNT_EVEN_DUTY_EN           string           "false"
   add_derived_hdl_param PLL_N_CNT_EVEN_DUTY_EN           string           "false"
   add_derived_hdl_param PLL_FBCLK_MUX_1                  string           "pll_fbclk_mux_1_glb"
   add_derived_hdl_param PLL_FBCLK_MUX_2                  string           "pll_fbclk_mux_2_m_cnt"
   add_derived_hdl_param PLL_M_CNT_IN_SRC                 string           "c_m_cnt_in_src_ph_mux_clk"
   add_derived_hdl_param PLL_CP_SETTING                   string           "pll_cp_settingX"
   add_derived_hdl_param PLL_BW_CTRL                      string           "pll_bw_res_settingX"
   add_derived_hdl_param PLL_RIPPLECAP_SETTING            string           "pll_ripplecap_settingX"
   add_derived_hdl_param PLL_BW_SEL                       string           "high"
   
   for {set i 0} {$i <= 8} {incr i} {
      add_derived_hdl_param "PLL_C_CNT_HIGH_$i"           integer          256
      add_derived_hdl_param "PLL_C_CNT_LOW_$i"            integer          256
      add_derived_hdl_param "PLL_C_CNT_PRST_$i"           integer          1
      add_derived_hdl_param "PLL_C_CNT_PH_MUX_PRST_$i"    integer          0
      add_derived_hdl_param "PLL_C_CNT_BYPASS_EN_$i"      string           "true"
      add_derived_hdl_param "PLL_C_CNT_EVEN_DUTY_EN_$i"   string           "false"
      add_derived_hdl_param "PLL_C_CNT_FREQ_PS_STR_$i"    string           ""
      add_derived_hdl_param "PLL_C_CNT_PHASE_PS_STR_$i"   string           ""
      add_derived_hdl_param "PLL_C_CNT_DUTY_CYCLE_$i"     integer          50
      add_derived_hdl_param "PLL_C_CNT_OUT_EN_$i"         string           "false"
   }   
}

proc ::altera_emif::ip_arch_nd::pll::get_legal_pll_ref_clk_freqs_mhz {max_entries} {
   set retval [list]

   set pfd_fmax_mhz              [get_family_trait FAMILY_TRAIT_PLL_PFD_FMAX_MHZ]
   set pfd_fmin_mhz              [get_family_trait FAMILY_TRAIT_PLL_PFD_FMIN_MHZ]
   set mem_clk_freq_mhz          [get_parameter_value PHY_MEM_CLK_FREQ_MHZ]
   set vco_to_mem_clk_freq_ratio [get_pll_vco_to_mem_clk_freq_ratio]
   set clk_ratios                [altera_emif::ip_arch_nd::protocol_expert::get_clk_ratios]   
   
   
   set vco_freq_mhz [expr {$mem_clk_freq_mhz * $vco_to_mem_clk_freq_ratio}]
      
   set slowest_clk_ratio [_get_mem_clk_to_slowest_phy_clk_freq_ratio $clk_ratios]
   
   for {set i 1} {[llength $retval] < $max_entries} {incr i} {
      set divisor          [expr {$vco_to_mem_clk_freq_ratio * $slowest_clk_ratio * $i}]
      set ref_clk_freq_mhz [expr {$vco_freq_mhz / $divisor}]
      
      set divisor_is_valid [_is_pll_m_counter_valid $divisor]
      
      if {$divisor > [get_family_trait FAMILY_TRAIT_PLL_MAX_VCO_DIV]} {
         break
      } elseif {$ref_clk_freq_mhz <= $pfd_fmin_mhz} {
         break
      } elseif {$ref_clk_freq_mhz >= $pfd_fmax_mhz} {
      } elseif {!$divisor_is_valid} {
      } else {
         set ref_clk_freq_mhz [expr {round($ref_clk_freq_mhz * 1000.0) / 1000.0}]
         lappend retval $ref_clk_freq_mhz
      }
   }
   
   return $retval
}

proc ::altera_emif::ip_arch_nd::pll::get_legal_extra_clk_freqs_mhz {max_entries} {

   set retval [list]

   set mem_clk_freq_mhz          [get_parameter_value PHY_MEM_CLK_FREQ_MHZ]
   set vco_to_mem_clk_freq_ratio [get_pll_vco_to_mem_clk_freq_ratio]
   set vco_freq_mhz              [expr {$mem_clk_freq_mhz * $vco_to_mem_clk_freq_ratio}]
   
   set min_c_cnt                 [get_family_trait FAMILY_TRAIT_PLL_MIN_C_CNT]
   set max_c_cnt                 [get_family_trait FAMILY_TRAIT_PLL_MAX_C_CNT]
   
   for {set c $min_c_cnt} {$c <= $max_c_cnt && [llength $retval] < $max_entries} {incr c} {
      set freq_mhz [expr {$vco_freq_mhz / $c}]
      
      set freq_mhz [expr {round($freq_mhz * 1000.0) / 1000.0}]
      lappend retval $freq_mhz
   }
   return $retval
}

proc ::altera_emif::ip_arch_nd::pll::get_legal_extra_clk_phases_ps {extra_clk_freq_mhz vco_freq_ps} {

   set phase_shift_inc_ps [expr {$vco_freq_ps / 8.0}]

   set mem_clk_freq_mhz          [get_parameter_value PHY_MEM_CLK_FREQ_MHZ]
   set vco_to_mem_clk_freq_ratio [get_pll_vco_to_mem_clk_freq_ratio]
   set vco_freq_mhz              [expr {$mem_clk_freq_mhz * $vco_to_mem_clk_freq_ratio}]
   
   set c_cnt     [expr {$vco_freq_mhz * 1.0 / $extra_clk_freq_mhz}]

   set c_cnt     [expr {int(ceil(round($c_cnt * 100.0) / 100.0))}]
   
   set num_valid_phases [expr {8 * $c_cnt}]
   set curr_phase_ps 0.0
   
   set retval [list]
   for {set i 0} {$i < $num_valid_phases} {incr i} {
      lappend retval $curr_phase_ps
      set curr_phase_ps [expr {$curr_phase_ps + $phase_shift_inc_ps}]
   }
   return $retval
}

proc ::altera_emif::ip_arch_nd::pll::get_legal_mem_clk_freqs_mhz {} {
   set retval [list]

   set ref_clk_freq_mhz          [get_parameter_value PHY_REF_CLK_FREQ_MHZ]
   set vco_to_mem_clk_freq_ratio [get_pll_vco_to_mem_clk_freq_ratio]
   set clk_ratios                [altera_emif::ip_arch_nd::protocol_expert::get_clk_ratios]
   
   set slowest_clk_ratio [_get_mem_clk_to_slowest_phy_clk_freq_ratio $clk_ratios]
   set protocol_enum     [get_parameter_value PROTOCOL_ENUM]
   set rate_enum         [get_parameter_value PHY_RATE_ENUM]
   set mem_clk_fmax_mhz  [get_feature_support_level FEATURE_FMAX_MHZ $protocol_enum $rate_enum]
   set mem_clk_fmin_mhz  [get_feature_support_level FEATURE_FMIN_MHZ $protocol_enum $rate_enum]
   
   for {set i 1} {$i < 50} {incr i} {
      set slowest_clk_freq_mhz [expr {$ref_clk_freq_mhz * $i}]
      set mem_clk_freq_mhz     [expr {$slowest_clk_freq_mhz * $slowest_clk_ratio}]
      set vco_freq_mhz         [expr {$mem_clk_freq_mhz * $vco_to_mem_clk_freq_ratio}]
      set pll_m                [expr {$vco_to_mem_clk_freq_ratio * $slowest_clk_ratio * $i}]
      
      if {[_is_pll_m_counter_valid $pll_m]} {
         if {$mem_clk_freq_mhz < $mem_clk_fmin_mhz} {
         } elseif {$mem_clk_freq_mhz > $mem_clk_fmax_mhz} {
            break
         } else {
            set rounded_mem_clk_freq_mhz [expr {round($mem_clk_freq_mhz * 100.0) / 100.0}]
            lappend retval $rounded_mem_clk_freq_mhz
         }
      }
   }
   return $retval
}

proc ::altera_emif::ip_arch_nd::pll::get_pll_vco_to_mem_clk_freq_ratio {} {

   set extra_configs_str [get_parameter_value "DIAG_EXTRA_CONFIGS"]
   set extra_configs [parse_extra_configs $extra_configs_str]
   
   if {[dict exists $extra_configs "FORCE_VCO_TO_MEM_CLK_FREQ_RATIO"]} {
      set ratio [dict get $extra_configs "FORCE_VCO_TO_MEM_CLK_FREQ_RATIO"]

   } else {
      set family             [enum_data [get_device_family_enum] MEGAFUNC_NAME]
      set compensation_mode  direct
      set prot_mode          EMIF
      set type               IOPLL
      set is_fractional      0
      
      set speedgrade [get_speedgrade]
      if {$speedgrade == ""} {
         set speedgrade 1
      } else {
         set speedgrade [string range $speedgrade 1 1]
      }
      
      set pll_api_params [list \
            -family $family \
            -type $type \
            -speedgrade $speedgrade \
            -prot_mode $prot_mode \
            -is_fractional $is_fractional \
            -compensation_mode $compensation_mode]

      if {[catch {::quartus::pll::legality::get_legal_vco_range $pll_api_params} pll_api_result]} {
         emif_ie "Error executing PLL legality API to determine legal VCO range"
      }
      
      array set pll_afi_result_array $pll_api_result
      set vco_min $pll_afi_result_array(vco_min)
      set vco_max $pll_afi_result_array(vco_max)


      set mem_clk_freq_mhz [get_parameter_value "PHY_MEM_CLK_FREQ_MHZ"]

      if {$mem_clk_freq_mhz >= $vco_min} {
         set ratio 1
      } elseif {[expr {$mem_clk_freq_mhz * 2}] >= $vco_min} {
         set ratio 2
      } elseif {[expr {$mem_clk_freq_mhz * 4}] >= $vco_min} {
         set ratio 4
      } elseif {[expr {$mem_clk_freq_mhz * 8}] >= $vco_min} {
         set ratio 8
      } else {
         emif_ie "Memory clock frequency $mem_clk_freq_mhz is too low to be supported"
      }
      
      emif_assert {[expr {$mem_clk_freq_mhz * $ratio}] <= $vco_max}
   }
   
   return $ratio
}

proc ::altera_emif::ip_arch_nd::pll::get_pll_phy_clk_phase_setting {vco_freq_mhz} {

   set extra_configs_str [get_parameter_value "DIAG_EXTRA_CONFIGS"]
   set extra_configs [parse_extra_configs $extra_configs_str]
   
   if {[dict exists $extra_configs "FORCE_PHY_CLK_PHASE_SETTING"]} {
      set retval [dict get $extra_configs "FORCE_PHY_CLK_PHASE_SETTING"]
   } else {
      if {$vco_freq_mhz > 933} {
         set retval 1
      } else {
         set retval 0
      }
   }
   return $retval
}

proc ::altera_emif::ip_arch_nd::pll::derive_pll_parameters {} {

   set settings [get_pll_settings]   
   
   set param_names [list \
      PLL_VCO_FREQ_MHZ_INT \
      PLL_VCO_TO_MEM_CLK_FREQ_RATIO \
      PLL_VCO_FREQ_PS_STR \
      PLL_PHY_CLK_VCO_PHASE \
      PLL_REF_CLK_FREQ_PS_STR \
      PLL_REF_CLK_FREQ_PS \
      PLL_SIM_VCO_FREQ_PS \
      PLL_SIM_PHYCLK_0_FREQ_PS \
      PLL_SIM_PHYCLK_1_FREQ_PS \
      PLL_SIM_PHYCLK_FB_FREQ_PS \
      PLL_SIM_PHY_CLK_VCO_PHASE_PS \
      PLL_SIM_CAL_SLAVE_CLK_FREQ_PS \
      PLL_SIM_CAL_MASTER_CLK_FREQ_PS]

   foreach param_name $param_names {
      set param_val [dict get $settings $param_name]
      set_parameter_value $param_name $param_val      
   }
   
   set m_counter [dict get $settings PLL_M_COUNTER]
   set cnt_settings [_get_counter_settings $m_counter]
   set_parameter_value PLL_M_CNT_HIGH         [dict get $cnt_settings HIGH]
   set_parameter_value PLL_M_CNT_LOW          [dict get $cnt_settings LOW]
   set_parameter_value PLL_M_CNT_BYPASS_EN    [dict get $cnt_settings BYPASS_EN]
   set_parameter_value PLL_M_CNT_EVEN_DUTY_EN [dict get $cnt_settings EVEN_DUTY_EN]   
   
   for {set i 0} {$i <= 4} {incr i} {
      set cnt_settings [_get_counter_settings [dict get $settings "PLL_C_COUNTER_$i"]]
      set_parameter_value "PLL_C_CNT_HIGH_$i"         [dict get $cnt_settings HIGH]
      set_parameter_value "PLL_C_CNT_LOW_$i"          [dict get $cnt_settings LOW]
      set_parameter_value "PLL_C_CNT_BYPASS_EN_$i"    [dict get $cnt_settings BYPASS_EN]
      set_parameter_value "PLL_C_CNT_EVEN_DUTY_EN_$i" [dict get $cnt_settings EVEN_DUTY_EN]
      set_parameter_value "PLL_C_CNT_PRST_$i"         1
      set_parameter_value "PLL_C_CNT_OUT_EN_$i"       "true"
      set_parameter_value "PLL_C_CNT_FREQ_PS_STR_$i"  "[dict get $settings PLL_C_COUNTER_FREQ_PS_$i] ps"

      if {$i <= 2} {
         set_parameter_value "PLL_C_CNT_PH_MUX_PRST_$i"  [dict get $settings PLL_PHY_CLK_VCO_PHASE]
         set_parameter_value "PLL_C_CNT_PHASE_PS_STR_$i" "[dict get $settings PLL_PHY_CLK_VCO_PHASE_PS] ps"
      } else {
         set_parameter_value "PLL_C_CNT_PH_MUX_PRST_$i"  0
         set_parameter_value "PLL_C_CNT_PHASE_PS_STR_$i" "0 ps" 
      }
   }

   set num_of_extra_clks  [get_parameter_value PLL_NUM_OF_EXTRA_CLKS]
   set vco_freq_mhz       [dict get $settings PLL_VCO_FREQ_MHZ]
   set vco_freq_ps        [dict get $settings PLL_VCO_FREQ_PS]
   set phase_shift_inc_ps [expr {$vco_freq_ps / 8.0}]
   
   for {set i 5} {$i <= 8} {incr i} {
      set clk_i [expr {$i - 5}]
      set clk_active [expr {$clk_i < $num_of_extra_clks ? true : false}]
      
      if {$clk_active} {
         set freq_mhz [get_parameter_value "PLL_EXTRA_CLK_ACTUAL_FREQ_MHZ_$i"]
         set phase_ps [get_parameter_value "PLL_EXTRA_CLK_ACTUAL_PHASE_PS_$i"]

         set c_cnt     [expr {$vco_freq_mhz * 1.0 / $freq_mhz}]
         set phase     [expr {$phase_ps / $phase_shift_inc_ps}]
      
         set c_cnt     [expr {int(ceil(round($c_cnt * 100.0) / 100.0))}]
         set phase     [expr {int(ceil(round($phase * 100.0) / 100.0))}]
         
         set prst      [expr {1 + int($phase / 8)}]
         set mux_prst  [expr {$phase % 8}]
         
         set freq_ps_int  [expr {int($vco_freq_ps * $c_cnt)}]
         set phase_ps_int [expr {int($phase_ps)}]

         set cnt_settings [_get_counter_settings $c_cnt]
         set_parameter_value "PLL_C_CNT_HIGH_$i"         [dict get $cnt_settings HIGH]
         set_parameter_value "PLL_C_CNT_LOW_$i"          [dict get $cnt_settings LOW]
         set_parameter_value "PLL_C_CNT_BYPASS_EN_$i"    [dict get $cnt_settings BYPASS_EN]
         set_parameter_value "PLL_C_CNT_EVEN_DUTY_EN_$i" [dict get $cnt_settings EVEN_DUTY_EN]
         set_parameter_value "PLL_C_CNT_OUT_EN_$i"       "true"
         set_parameter_value "PLL_C_CNT_FREQ_PS_STR_$i"  "$freq_ps_int ps"
         set_parameter_value "PLL_C_CNT_PRST_$i"         $prst
         set_parameter_value "PLL_C_CNT_PH_MUX_PRST_$i"  $mux_prst
         set_parameter_value "PLL_C_CNT_PHASE_PS_STR_$i" "$phase_ps_int ps"
      } else {
         set_parameter_value "PLL_C_CNT_HIGH_$i"         256
         set_parameter_value "PLL_C_CNT_LOW_$i"          256
         set_parameter_value "PLL_C_CNT_BYPASS_EN_$i"    "true"
         set_parameter_value "PLL_C_CNT_EVEN_DUTY_EN_$i" "false"
         set_parameter_value "PLL_C_CNT_OUT_EN_$i"       "false"
         set_parameter_value "PLL_C_CNT_FREQ_PS_STR_$i"  "0.0 MHz"
         set_parameter_value "PLL_C_CNT_PRST_$i"         1
         set_parameter_value "PLL_C_CNT_PH_MUX_PRST_$i"  0
         set_parameter_value "PLL_C_CNT_PHASE_PS_STR_$i" "0 ps"
      }
   }

   if { $m_counter < 4 } {
      emif_ie "Illegal m_counter value $m_counter"
   } elseif { $m_counter <= 5} {
      set_parameter_value PLL_CP_SETTING "pll_cp_setting5"
   } elseif { $m_counter <= 15}  {
      set_parameter_value PLL_CP_SETTING "pll_cp_setting10"
   } elseif { $m_counter <= 160}  {
      set_parameter_value PLL_CP_SETTING "pll_cp_setting12"
   } else {
      emif_ie "Illegal m_counter value $m_counter"
   }     

   if { $m_counter < 4 } {
      emif_ie "Illegal m_counter value $m_counter"
   } elseif { $m_counter <= 23} {
      set_parameter_value PLL_BW_CTRL "pll_bw_res_setting3"
   } elseif { $m_counter <= 64}  {
      set_parameter_value PLL_BW_CTRL "pll_bw_res_setting4"
   } elseif { $m_counter <= 160}  {
      set_parameter_value PLL_BW_CTRL "pll_bw_res_setting5"
   } else {
      emif_ie "Illegal m_counter value $m_counter"
   }

   if { $m_counter < 4 } {
      emif_ie "Illegal m_counter value $m_counter"
   } elseif { $m_counter <= 15} {
      set_parameter_value PLL_RIPPLECAP_SETTING "pll_ripplecap_setting0"
   } elseif { $m_counter <= 23}  {
      set_parameter_value PLL_RIPPLECAP_SETTING "pll_ripplecap_setting2"
   } elseif { $m_counter <= 43}  {
      set_parameter_value PLL_RIPPLECAP_SETTING "pll_ripplecap_setting0"
   } elseif { $m_counter <= 160}  {
      set_parameter_value PLL_RIPPLECAP_SETTING "pll_ripplecap_setting2"
   } else {
      emif_ie "Illegal m_counter value $m_counter"
   }
}

proc ::altera_emif::ip_arch_nd::pll::get_pll_settings {} {
   set retval [dict create]

   set mem_clk_freq_mhz          [get_parameter_value PHY_MEM_CLK_FREQ_MHZ]
   set ref_clk_freq_mhz          [get_parameter_value PHY_REF_CLK_FREQ_MHZ]
   set clk_ratios                [altera_emif::ip_arch_nd::protocol_expert::get_clk_ratios]
   set vco_to_mem_clk_freq_ratio [get_pll_vco_to_mem_clk_freq_ratio]
   set vco_freq_mhz              [expr {$mem_clk_freq_mhz * $vco_to_mem_clk_freq_ratio}]
   set phy_clk_phase_setting     [get_pll_phy_clk_phase_setting $vco_freq_mhz]   
   
   set vco_freq_mhz              [expr {$mem_clk_freq_mhz * $vco_to_mem_clk_freq_ratio}]
   set user_clk_ratio            [dict get $clk_ratios USER]
   set c2p_p2c_clk_ratio         [dict get $clk_ratios C2P_P2C]
   set phy_hmc_clk_ratio         [dict get $clk_ratios PHY_HMC]
   set slowest_clk_ratio         [_get_mem_clk_to_slowest_phy_clk_freq_ratio $clk_ratios]

   set n_counter         1
   set m_counter         [expr { int(round($vco_freq_mhz / $ref_clk_freq_mhz)) }]
   
   set vco_to_slowest_clk_ratio [expr {$vco_to_mem_clk_freq_ratio * $slowest_clk_ratio}]
   emif_assert { [expr {$m_counter % $vco_to_slowest_clk_ratio}] == 0 }   
      
   set vco_freq_ps  [expr {int(1000000.0 / $vco_freq_mhz)}]
   if {[expr {$vco_freq_ps % 2}] != 0} {
      incr vco_freq_ps
   }
   set mem_clk_freq_ps [expr {$vco_freq_ps * $vco_to_mem_clk_freq_ratio}]
   set ref_clk_freq_ps [expr {$vco_freq_ps * $m_counter}]

   dict set retval PLL_M_COUNTER                    $m_counter   
   dict set retval PLL_REF_CLK_FREQ_PS              $ref_clk_freq_ps
   dict set retval PLL_REF_CLK_FREQ_PS_STR          "$ref_clk_freq_ps ps"
   dict set retval PLL_VCO_FREQ_PS                  $vco_freq_ps
   dict set retval PLL_VCO_FREQ_PS_STR              "$vco_freq_ps ps"
   dict set retval PLL_VCO_FREQ_MHZ                 $vco_freq_mhz
   dict set retval PLL_VCO_FREQ_MHZ_INT             [expr {round($vco_freq_mhz)}]
   dict set retval PLL_VCO_TO_MEM_CLK_FREQ_RATIO    $vco_to_mem_clk_freq_ratio
   dict set retval PLL_MEM_CLK_FREQ_PS              $mem_clk_freq_ps
   
   set fast_sim_vco_freq_ps_factor 8
   set fast_sim_vco_freq_ps_error  [expr {$vco_freq_ps % $fast_sim_vco_freq_ps_factor}]
   if {$fast_sim_vco_freq_ps_error != 0} {
      set fast_sim_vco_freq_ps [expr {$vco_freq_ps + ($fast_sim_vco_freq_ps_factor - $fast_sim_vco_freq_ps_error)}]
   } else {
      set fast_sim_vco_freq_ps $vco_freq_ps
   }
   dict set retval PLL_SIM_VCO_FREQ_PS $fast_sim_vco_freq_ps
   
   set phy_clk_vco_phase_ps          [expr {int(round($vco_freq_ps          * 1.0 * $phy_clk_phase_setting / 8))}]
   set fast_sim_phy_clk_vco_phase_ps [expr {int(round($fast_sim_vco_freq_ps * 1.0 * $phy_clk_phase_setting / 8))}]
   
   dict set retval PLL_PHY_CLK_VCO_PHASE         $phy_clk_phase_setting
   dict set retval PLL_PHY_CLK_VCO_PHASE_PS      $phy_clk_vco_phase_ps
   dict set retval PLL_SIM_PHY_CLK_VCO_PHASE_PS  $fast_sim_phy_clk_vco_phase_ps
   
   set phyclk_fb_counter           [expr {$vco_to_mem_clk_freq_ratio * $slowest_clk_ratio}]
   set phyclk_fb_freq_mhz          [expr {$vco_freq_mhz / $phyclk_fb_counter}]
   set phyclk_fb_freq_ps           [expr {$vco_freq_ps  * $phyclk_fb_counter}]
   set fast_sim_phyclk_fb_freq_ps  [expr {$fast_sim_vco_freq_ps * $phyclk_fb_counter}]
   
   dict set retval PLL_C_COUNTER_2                  $phyclk_fb_counter
   dict set retval PLL_C_COUNTER_FREQ_PS_2          $phyclk_fb_freq_ps
   dict set retval PLL_SIM_PHYCLK_FB_FREQ_PS        $fast_sim_phyclk_fb_freq_ps
      
   set phyclk_0_counter            [expr {$vco_to_mem_clk_freq_ratio * $phy_hmc_clk_ratio}]
   set phyclk_0_freq_mhz           [expr {$vco_freq_mhz / $phyclk_0_counter}]
   set phyclk_0_freq_ps            [expr {$vco_freq_ps  * $phyclk_0_counter}]
   set fast_sim_phyclk_0_freq_ps   [expr {$fast_sim_vco_freq_ps * $phyclk_0_counter}]
   
   dict set retval PLL_C_COUNTER_1                  $phyclk_0_counter
   dict set retval PLL_C_COUNTER_FREQ_PS_1          $phyclk_0_freq_ps
   dict set retval PLL_SIM_PHYCLK_0_FREQ_PS         $fast_sim_phyclk_0_freq_ps
      
   set phyclk_1_counter            [expr {$vco_to_mem_clk_freq_ratio * $c2p_p2c_clk_ratio}]
   set phyclk_1_freq_mhz           [expr {$vco_freq_mhz / $phyclk_1_counter}]
   set phyclk_1_freq_ps            [expr {$vco_freq_ps  * $phyclk_1_counter}]
   set fast_sim_phyclk_1_freq_ps   [expr {$fast_sim_vco_freq_ps * $phyclk_1_counter}]

   dict set retval PLL_C_COUNTER_0                  $phyclk_1_counter
   dict set retval PLL_C_COUNTER_FREQ_PS_0          $phyclk_1_freq_ps
   dict set retval PLL_SIM_PHYCLK_1_FREQ_PS         $fast_sim_phyclk_1_freq_ps
   
   set cal_slave_clk_counter           [expr {$vco_freq_mhz / 166.6667}]
   
   set cal_slave_clk_counter           [expr {int(ceil(round($cal_slave_clk_counter * 100.0) / 100.0))}]
   set cal_slave_clk_freq_mhz          [expr {$vco_freq_mhz / $cal_slave_clk_counter}]
   set cal_slave_clk_freq_ps           [expr {$vco_freq_ps  * $cal_slave_clk_counter}]
   set fast_sim_cal_slave_clk_freq_ps  [expr {$fast_sim_vco_freq_ps * $cal_slave_clk_counter}]
   
   dict set retval PLL_C_COUNTER_3                $cal_slave_clk_counter
   dict set retval PLL_C_COUNTER_FREQ_PS_3        $cal_slave_clk_freq_ps
   dict set retval PLL_SIM_CAL_SLAVE_CLK_FREQ_PS  $fast_sim_cal_slave_clk_freq_ps
   
   set cal_master_clk_counter           [expr {$vco_freq_mhz / 166.6667}]
   
   set cal_master_clk_counter           [expr {int(ceil(round($cal_master_clk_counter * 100.0) / 100.0))}]
   set cal_master_clk_freq_mhz          [expr {$vco_freq_mhz / $cal_master_clk_counter}]
   set cal_master_clk_freq_ps           [expr {$vco_freq_ps  * $cal_master_clk_counter}]
   set fast_sim_cal_master_clk_freq_ps  [expr {$fast_sim_vco_freq_ps * $cal_master_clk_counter}]
   
   dict set retval PLL_C_COUNTER_4                 $cal_master_clk_counter
   dict set retval PLL_C_COUNTER_FREQ_PS_4         $cal_master_clk_freq_ps
   dict set retval PLL_SIM_CAL_MASTER_CLK_FREQ_PS  $fast_sim_cal_master_clk_freq_ps

   
   
   dict set retval PLL_COMPENSATION_MODE "direct"
   
   return $retval
}


proc ::altera_emif::ip_arch_nd::pll::_is_pll_m_counter_valid { pll_m } {
   if {$pll_m < [get_family_trait FAMILY_TRAIT_PLL_MIN_VCO_DIV]} {
      return 0
   } elseif {$pll_m > [get_family_trait FAMILY_TRAIT_PLL_MAX_VCO_DIV]} {
      return 0
   } else {
      return 1
   }
}

proc ::altera_emif::ip_arch_nd::pll::_get_mem_clk_to_slowest_phy_clk_freq_ratio {clk_ratios} {
   return [dict get $clk_ratios C2P_P2C]
}

proc ::altera_emif::ip_arch_nd::pll::_get_counter_settings {counter_val} {
   set retval [dict create]

   if {$counter_val == 1} {
      dict set retval BYPASS_EN     "true"
      dict set retval HIGH          256
      dict set retval LOW           256
      dict set retval EVEN_DUTY_EN  "false"
      
   } elseif {[expr {$counter_val % 2}] == 0} {
      dict set retval BYPASS_EN     "false"
      dict set retval HIGH          [expr {$counter_val / 2}]
      dict set retval LOW           [dict get $retval HIGH]
      dict set retval EVEN_DUTY_EN  "false"
      
   } else {
      dict set retval BYPASS_EN     "false"
      dict set retval HIGH          [expr {($counter_val + 1) / 2}]
      dict set retval LOW           [expr {[dict get $retval HIGH] - 1}]
      dict set retval EVEN_DUTY_EN  "true"
   }
   
   return $retval
}

proc ::altera_emif::ip_arch_nd::pll::_init {} {
}

::altera_emif::ip_arch_nd::pll::_init

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












package require -exact qsys 23.1

if {! [info exists ip_params] || ! [info exists ed_params]} {
   source "params.tcl"
}

set ip_param_lst [list]
foreach param_name [array names ip_params] {
   lappend ip_param_lst $param_name
   lappend ip_param_lst $ip_params($param_name)
}

set mem_param_lst [list]
foreach p [array names mem_model_params] {
   lappend mem_param_lst $p
   lappend mem_param_lst $mem_model_params($p)
}

set_project_property DEVICE_FAMILY $ip_params(SYSINFO_DEVICE_FAMILY)
set_project_property DEVICE        $ip_params(SYSINFO_DEVICE)

set module_prefix ""

proc gen_sys {design_type} {
   upvar ip_params            ip_params
   upvar ed_params            ed_params
   upvar ip_param_lst         ip_param_lst
   upvar mem_param_lst        mem_param_lst
   upvar family_traits        family_traits

   set TECH                  $ed_params(tech_features.protocol) 
   set tech                  [string tolower $TECH]
   set num_channels          $ip_params(MEM_NUM_CHANNELS)
   set num_channels_per_io96 $ip_params(MEM_NUM_CHANNELS_PER_IO96)
   set num_io96              $ip_params(MEM_NUM_IO96)
   set num_refclks           1 

   set emif            $ed_params(EMIF_NAME)
   set tg              traffic_generator
   set rrip            rrip
   set rrip2           rrip2
   set user_pll        user_pll
   set noc_init        $ed_params(NOC_INIT_NAME)
   set noc_init_lite_0 $ed_params(NOC_INIT_LITE_NAME)_0
   set noc_init_lite_1 $ed_params(NOC_INIT_LITE_NAME)_1 
   set noc_ctrl        $ed_params(NOC_CTRL_NAME)
   set axil_driver_0   axil_driver_0
   set axil_driver_1   axil_driver_1
   set reset_handler   reset_handler
   set pmon            perf_mon
   set ddr4dimm_rh     ddr4dimm_reset_handler
   set wide_tg_rh_0    wide_tg_reset_handler_0
   set wide_tg_rh_1    wide_tg_reset_handler_1
   set noc_rh          noc_reset_handler


   set extra_config_str        $ip_params(DIAG_EXTRA_PARAMETERS)
   array set extra_config_arr  [parse_extra_configs $extra_config_str]

   set user_access_mode "fabric_sync"
   if {$ip_params(PHY_MAINBAND_ACCESS_MODE) == "ASYNC" } {
      set user_access_mode "fabric_async"
   } elseif {$ip_params(PHY_MAINBAND_ACCESS_MODE) == "NOC" } {
      set user_access_mode "noc"
   }

   if {[info exists extra_config_arr(USR_CLK_FREQ_OVRD)]} {
      set usr_reference_clock_frequency 100 
      set usr_clock_frequency $extra_config_arr(USR_CLK_FREQ_OVRD)
   } else {
      set usr_reference_clock_frequency $ip_params(EX_DESIGN_USER_PLL_REFCLK_FREQ_MHZ) 
      set usr_clock_frequency $ip_params(EX_DESIGN_USER_PLL_OUTPUT_FREQ_MHZ)
   }

   if {$user_access_mode == "fabric_sync"} {
      set mem_core_div $ed_params(tech_features.clk_div_mem_core)
      set hydra_jtag_clock_freq_mhz [expr {$ip_params(MEM_OPERATING_FREQ_MHZ) / $mem_core_div}]
   } else {
      set hydra_jtag_clock_freq_mhz $usr_clock_frequency
   }

   set module_prefix "ed_${design_type}_"

   if { $design_type == "sim" &&
        ($ed_params(EMIF_MODULE_NAME) == "emif_io96b_ddr4dimm" || $ed_params(EMIF_MODULE_NAME) == "emif_io96b_ddr4comp") && 
        [lindex $ip_params(PLACEMENT_SCHEMES) 0] == "DDR4_X32_4AC_TOP" &&
        $ip_params(PHY_ALERT_N_PLACEMENT) == "AC3" &&
        ($ip_params(MEM_CHANNEL_CS_WIDTH) == 1 || ($ip_params(MEM_CHANNEL_CS_WIDTH) == 2 && $ip_params(MEM_RANKS_SHARE_CK_EN) == "true")) &&
        $ip_params(MEM_3DS_EN) == "false" } {

      set ac_place_idx [lsearch -exact $ip_param_lst "PHY_AC_PLACEMENT"]
      if {$ac_place_idx != -1} {
         set val_idx [expr {$ac_place_idx+1}]
         set curr_val [lindex $ip_param_lst $val_idx]
         set new_val [expr {[regexp -- "_" $curr_val] ? "BOT_BOT" : "BOT"}]
         set ip_param_lst [lreplace $ip_param_lst $val_idx $val_idx $new_val]
      }
      set swizz_idx [lsearch -exact $ip_param_lst "PHY_SWIZZLE_MAP"]
      if {$swizz_idx != -1} {
         set val_idx [expr {$swizz_idx+1}]
         set ip_param_lst [lreplace $ip_param_lst $val_idx $val_idx ""]
      }
   }

   add_component_helper  $emif           $ed_params(EMIF_MODULE_NAME)
   load_component $emif
   set_component_parameter_values $ip_param_lst
   set emif_interfaces_list [get_component_interfaces]
   save_component; 

   if {[info exists extra_config_arr(ENABLE_BCM_SIM)] && [expr {$design_type == "synth"}]} {
      set use_hydra_status_if $extra_config_arr(ENABLE_BCM_SIM)
   } else {
      set use_hydra_status_if "false"
   }

   set user_dq_width    $ip_params(MEM_CHANNEL_DATA_DQ_WIDTH)
   set extra_dq_width 0
   set is_lockstep    $ed_params(tech_features.is_lockstep)
   set sideband_in_use [expr {$ip_params(PHY_SIDEBAND_ACCESS_MODE) != "OFF"}]
   set sideband_is_noc [expr {$ip_params(PHY_SIDEBAND_ACCESS_MODE) == "NOC"}]
   set debug_tools_en [expr {[info exists extra_config_arr(EN_CAL_RB_DPRINT)]  ||
                              $ip_params(DEBUG_TOOLS_EN) }]

   if {$sideband_in_use} {
      add_component_helper $axil_driver_0 emif_ph2_axil_driver
      load_component $axil_driver_0
         if {$sideband_is_noc} {
            set_component_parameter_value AXIL_DRIVER_ADDRESS_WIDTH    44
         } else {
            set_component_parameter_value AXIL_DRIVER_ADDRESS_WIDTH    27
         }
      save_component; 

      if {$num_io96 != 1 && ![string is true $is_lockstep]} {
         add_component_helper $axil_driver_1 emif_ph2_axil_driver
         load_component $axil_driver_1
            if {$sideband_is_noc} {
               set_component_parameter_value AXIL_DRIVER_ADDRESS_WIDTH    44
            } else {
               set_component_parameter_value AXIL_DRIVER_ADDRESS_WIDTH    27
            }
         save_component; 
      }
   }
   set axi4_data_width [expr {$is_lockstep ? 512 : 256}]

   set has_user_bits [expr {![is_pow_2 $user_dq_width]}]
   if {$has_user_bits} {
      set extra_dq_width [expr { $user_access_mode == "noc" ? 4 : 8 } ] 
   } 
   set dq_ratio [expr {$axi4_data_width / (!$has_user_bits ? $user_dq_width : $user_dq_width - $extra_dq_width)}]
   set axi_user_width [expr {$axi4_data_width + $dq_ratio * $extra_dq_width} ]
   set use_wide_tg [expr {[info exists ip_params(EX_DESIGN_TG_WIDE_IF)] && $ip_params(EX_DESIGN_TG_WIDE_IF)}]
   set use_unoc [expr {[info exists extra_config_arr(USE_UNOC)] && $extra_config_arr(USE_UNOC)=="ON" && $user_access_mode == "noc"}]
   if {$use_wide_tg || $use_unoc} {
      set axi_user_width 512
   }

   set axi_addr_width [expr {$ip_params(PHY_MAINBAND_ACCESS_MODE) == "NOC"? 40 : $ip_params(AXI4_ADDR_WIDTH)}]

   set reduced_max_axisize [expr {$ip_params(AXI4_ADDR_WIDTH) - (int(floor(log($axi4_data_width)/log(2)))-3)}] ;
    
   switch $ip_params(EX_DESIGN_TG_CSR_ACCESS_MODE) {
      "JTAG"   {set hydra_config_intf "CONFIG_INTF_MODE_REMOTE_JTAG"}
      "EXPORT" {set hydra_config_intf "CONFIG_INTF_MODE_EXPORT"}
   }
   add_component_helper $tg hydra
   load_component $tg
      set_component_parameter_value  IS_SIMULATION                     [expr {$design_type == "sim"}]
      set_component_parameter_value  CONFIG_INTF_MODE                  $hydra_config_intf
      set_component_parameter_value  REMOTE_INTF_PRODUCE_CLK_RESET     "false";
      set_component_parameter_value  REMOTE_INTF_CLK_FREQ_MHZ          $hydra_jtag_clock_freq_mhz;
      set_component_parameter_value  EXPORT_STATUS_INTF                $use_hydra_status_if

      set_component_parameter_value  NUM_DRIVERS                       $num_channels

      for {set ch_idx 0} {$ch_idx < $num_channels} {incr ch_idx} {
         set_component_parameter_value  DRIVER_${ch_idx}_TYPE_ENUM                     DRIVER_TYPE_MEM_AXI4
         set_component_parameter_value  DRIVER_${ch_idx}_MEM_AXI4_DATA_DQ_RATIO        $dq_ratio
         set_component_parameter_value  DRIVER_${ch_idx}_MEM_AXI4_ADDR_ALU_ARG_WIDTH   $reduced_max_axisize 
         set_component_parameter_value  DRIVER_${ch_idx}_MEM_AXI4_AWID_WIDTH           $ip_params(S${ch_idx}_AXID_WIDTH)
         set_component_parameter_value  DRIVER_${ch_idx}_MEM_AXI4_AWADDR_WIDTH         $axi_addr_width
         set_component_parameter_value  DRIVER_${ch_idx}_MEM_AXI4_USE_AWLOCK           1
         set_component_parameter_value  DRIVER_${ch_idx}_MEM_AXI4_USE_AWCACHE          0
         set_component_parameter_value  DRIVER_${ch_idx}_MEM_AXI4_USE_AWPROT           1
         set_component_parameter_value  DRIVER_${ch_idx}_MEM_AXI4_USE_AWQOS            1
         set_component_parameter_value  DRIVER_${ch_idx}_MEM_AXI4_USE_AWREGION         0
         set_component_parameter_value  DRIVER_${ch_idx}_MEM_AXI4_USE_AWUSER           1
         set_component_parameter_value  DRIVER_${ch_idx}_MEM_AXI4_AWUSER_WIDTH         14

         set_component_parameter_value  DRIVER_${ch_idx}_MEM_AXI4_ARID_WIDTH           $ip_params(S${ch_idx}_AXID_WIDTH)
         set_component_parameter_value  DRIVER_${ch_idx}_MEM_AXI4_ARADDR_WIDTH         $axi_addr_width
         set_component_parameter_value  DRIVER_${ch_idx}_MEM_AXI4_USE_ARLOCK           1
         set_component_parameter_value  DRIVER_${ch_idx}_MEM_AXI4_USE_ARCACHE          0
         set_component_parameter_value  DRIVER_${ch_idx}_MEM_AXI4_USE_ARPROT           1
         set_component_parameter_value  DRIVER_${ch_idx}_MEM_AXI4_USE_ARQOS            1
         set_component_parameter_value  DRIVER_${ch_idx}_MEM_AXI4_USE_ARREGION         0
         set_component_parameter_value  DRIVER_${ch_idx}_MEM_AXI4_USE_ARUSER           1
         set_component_parameter_value  DRIVER_${ch_idx}_MEM_AXI4_ARUSER_WIDTH         14


         set_component_parameter_value  DRIVER_${ch_idx}_MEM_AXI4_WDATA_WIDTH          $axi_user_width
         set_component_parameter_value  DRIVER_${ch_idx}_MEM_AXI4_RDATA_WIDTH          $axi_user_width

         set_component_parameter_value  DRIVER_${ch_idx}_MEM_AXI4_USE_BUSER            0

         set_component_parameter_value  DRIVER_${ch_idx}_ENABLE_CLOCK_SOURCE           "false";
         set_component_parameter_value  DRIVER_${ch_idx}_ENABLE_RESET_SOURCE           "false";
      }

      if {$ip_params(EX_DESIGN_TG_PROGRAM) == "INFINITE"} {
         set_component_parameter_value RUN_ON_RESET 0
      }

   save_component; 

   add_component_helper $rrip altera_s10_user_rst_clkgate
   load_component $rrip
      set_component_parameter_value  outputType "Reset Interface"
   save_component; 


   set pmon_enabled_drivers {}
   for {set i 0} {$i < $num_channels} {incr i} {
      if {$ip_params(EX_DESIGN_PMON_CH${i}_EN)} {
         lappend pmon_enabled_drivers $i
      }
   }

   set num_pmon [llength $pmon_enabled_drivers]

   if {$num_pmon} {
      set use_pmon 1
   } else {
      set use_pmon 0
   }

   set pmon_internal_jamb $ip_params(EX_DESIGN_PMON_INTERNAL_JAMB_EN)
   if {$use_pmon} {

      if {$pmon_internal_jamb == "false"} {
         set jamb_inst "pmon_jamb"
         lappend inst_names $jamb_inst
         add_instance $jamb_inst altera_jtag_avalon_master "19.1"
         set_instance_parameter_values $jamb_inst [list \
            FAST_VER    0     \
            FIFO_DEPTHS 2     \
            USE_PLI     1     \
            PLI_PORT    50000 \
         ]

         set csr_bus_if ${jamb_inst}.master
      }


      set pmon_inst_list {}
      for {set i 0} {$i < $num_pmon} {incr i} {
         set driver_num [lindex $pmon_enabled_drivers $i]
         set ch_index $driver_num
         set perf_mon_inst "${pmon}ch${ch_index}"

         add_instance $perf_mon_inst pmon
         set_instance_parameter_value $perf_mon_inst MONITOR_0_ADVANCED_LAT "false"
         set_instance_parameter_value $perf_mon_inst EXPORT_JTAG $pmon_internal_jamb
         lappend pmon_inst_list $perf_mon_inst

         if {$pmon_internal_jamb == "false"} {
            set pmon_address [expr {$i * 0x100000}]

            add_connection                 ${csr_bus_if}/${perf_mon_inst}.sink_axi4lite
            set_connection_parameter_value ${csr_bus_if}/${perf_mon_inst}.sink_axi4lite baseAddress $pmon_address
         }
      }
   }

   set pmon_idx -1
   for {set ch_idx 0} {$ch_idx < $num_channels} {incr ch_idx} {
      set pmon_enabled [expr {[lsearch -exact $pmon_enabled_drivers $ch_idx] >= 0}]
      if {$use_pmon && $pmon_enabled} {
         
         incr pmon_idx
         set perf_mon_inst [lindex $pmon_inst_list $pmon_idx]

         set_instance_parameter_value  $perf_mon_inst MONITOR_0_UNIT_ID                     $pmon_idx
         set_instance_parameter_value  $perf_mon_inst MONITOR_INDEX                         0
         set_instance_parameter_value  $perf_mon_inst MONITOR_0_MEM_AXI4_AWID_WIDTH         $ip_params(S${ch_idx}_AXID_WIDTH)
         set_instance_parameter_value  $perf_mon_inst MONITOR_0_MEM_AXI4_AWADDR_WIDTH       $axi_addr_width
         set_instance_parameter_value  $perf_mon_inst MONITOR_0_MEM_AXI4_USE_AWLOCK         1
         set_instance_parameter_value  $perf_mon_inst MONITOR_0_MEM_AXI4_USE_AWCACHE        0
         set_instance_parameter_value  $perf_mon_inst MONITOR_0_MEM_AXI4_USE_AWQOS          1
         set_instance_parameter_value  $perf_mon_inst MONITOR_0_MEM_AXI4_USE_AWREGION       0
         set_instance_parameter_value  $perf_mon_inst MONITOR_0_MEM_AXI4_USE_AWUSER         1
         set_instance_parameter_value  $perf_mon_inst MONITOR_0_MEM_AXI4_AWUSER_WIDTH       14

         set_instance_parameter_value  $perf_mon_inst MONITOR_0_MEM_AXI4_ARID_WIDTH         $ip_params(S${ch_idx}_AXID_WIDTH)
         set_instance_parameter_value  $perf_mon_inst MONITOR_0_MEM_AXI4_ARADDR_WIDTH       $axi_addr_width
         set_instance_parameter_value  $perf_mon_inst MONITOR_0_MEM_AXI4_USE_ARLOCK         1
         set_instance_parameter_value  $perf_mon_inst MONITOR_0_MEM_AXI4_USE_ARCACHE        0
         set_instance_parameter_value  $perf_mon_inst MONITOR_0_MEM_AXI4_USE_ARQOS          1
         set_instance_parameter_value  $perf_mon_inst MONITOR_0_MEM_AXI4_USE_ARREGION       0
         set_instance_parameter_value  $perf_mon_inst MONITOR_0_MEM_AXI4_USE_ARUSER         1
         set_instance_parameter_value  $perf_mon_inst MONITOR_0_MEM_AXI4_ARUSER_WIDTH       14

         set_instance_parameter_value  $perf_mon_inst MONITOR_0_MEM_AXI4_WDATA_WIDTH        $axi_user_width
         set_instance_parameter_value  $perf_mon_inst MONITOR_0_MEM_AXI4_RDATA_WIDTH        $axi_user_width

         set_instance_parameter_value  $perf_mon_inst MONITOR_0_MEM_AXI4_USE_BUSER          0
      }
   }
 
   set use_pll_for_mainband [expr {$user_access_mode == "fabric_async" ||
                                    $user_access_mode == "noc"        }]
   set use_pll_for_sideband 1
   set num_user_pll_clocks [expr {$use_pll_for_mainband + $use_pll_for_sideband}]
   if {$use_wide_tg || $use_unoc} {
      set num_user_pll_clocks [expr {$num_user_pll_clocks + 1}]
   }  


   add_component_helper $reset_handler mem_reset_handler
   load_component $reset_handler
      set_component_parameter_value  NUM_RESETS   1
   save_component; 
   add_connection  $rrip.ninit_done    $reset_handler.reset_n_0

   if {$num_user_pll_clocks > 0} {
      load_component $reset_handler 
         set_component_parameter_value  SYNC_TO_CLK  true
         set_component_parameter_value  CONDUIT_TYPE_0 "export"
         set_component_parameter_value  NUM_CONDUITS 1
      save_component; 
   } elseif {$user_access_mode == "fabric_sync"} {
      load_component $reset_handler
         set_component_parameter_value  NUM_CONDUITS 0
      save_component; 
   }

   set side_clock_frequency [expr {$usr_clock_frequency/2}]
   if {$num_user_pll_clocks > 0} {
      add_component_helper $user_pll altera_iopll
      load_component $user_pll
         set_component_parameter_value  gui_use_coreclk                 true
         set_component_parameter_value  gui_use_locked                  true
         set_component_parameter_value  gui_location_type               "Fabric-Feeding"
         set_component_parameter_value  gui_pll_bandwidth_preset        "Medium"
         set_component_parameter_value  gui_reference_clock_frequency   $usr_reference_clock_frequency
         set_component_parameter_value  gui_number_of_clocks            $num_user_pll_clocks
         if {$num_user_pll_clocks == 3} {
            set_component_parameter_value gui_output_clock_frequency0   $usr_clock_frequency
            set_component_parameter_value gui_output_clock_frequency2   $side_clock_frequency
            set hydra_clk "$user_pll.outclk0"
            set sideband_clk "$user_pll.outclk2"
            if {$use_wide_tg} {
               set_component_parameter_value gui_output_clock_frequency1 [expr {$usr_clock_frequency*2}]
               set emif_clk "$user_pll.outclk1"
            } elseif {$use_unoc} {
               switch $ip_params(SYSINFO_DEVICE_SPEEDGRADE) {
                  1       {set def_unoc_freq 440}
                  2       {set def_unoc_freq 420}
                  3       {set def_unoc_freq 350}
                  default {set def_unoc_freq 350}
               }
               set_component_parameter_value gui_output_clock_frequency1 [expr {[info exists extra_config_arr(UNOC_FREQ_MHZ)] ? $extra_config_arr(UNOC_FREQ_MHZ) : $def_unoc_freq}]
               set emif_clk "$user_pll.outclk0"
               set noc_bridge_clk "$user_pll.outclk1"
            }
         } elseif {$num_user_pll_clocks == 2} {
            set_component_parameter_value  gui_output_clock_frequency0  $usr_clock_frequency
            set_component_parameter_value  gui_output_clock_frequency1  $side_clock_frequency
            set hydra_clk "$user_pll.outclk0"
            set emif_clk "$user_pll.outclk0"
            set sideband_clk "$user_pll.outclk1"
         } elseif {$use_pll_for_mainband} {
            set_component_parameter_value  gui_output_clock_frequency0  $usr_clock_frequency
            set hydra_clk "$user_pll.outclk0"
            set emif_clk "$user_pll.outclk0"
            set sideband_clk "$emif.s0_axi4_clock_out"
         } elseif {$use_pll_for_sideband} {
            set_component_parameter_value  gui_output_clock_frequency0  $side_clock_frequency
            set sideband_clk "$user_pll.outclk0"
         }
      save_component; 

      add_connection  $rrip.ninit_done    $user_pll.reset
      add_connection  $user_pll.locked    $reset_handler.conduit_0
      add_connection  $user_pll.outclk0   $reset_handler.clk
   }

   set pmon_idx -1
   if {$user_access_mode == "fabric_sync"} {
      if {$ip_params(EX_DESIGN_TG_CSR_ACCESS_MODE) == "JTAG"} {
         add_connection $sideband_clk               $tg.remote_intf_clk
         add_connection $reset_handler.reset_n_out  $tg.remote_intf_reset
      }

      if {$use_pmon} {
         if {$pmon_internal_jamb == "false"} {
            add_connection $sideband_clk             ${jamb_inst}.clk
            add_connection $emif.s0_axi4_ctrl_ready  ${jamb_inst}.clk_reset
         }

         for {set ch_idx 0} {$ch_idx < $num_channels} {incr ch_idx} {
            set pmon_enabled [expr {[lsearch -exact $pmon_enabled_drivers $ch_idx] >= 0}]    
            if {$pmon_enabled} {
               incr pmon_idx
               set perf_mon_inst [lindex $pmon_inst_list $pmon_idx]
               
               add_connection $sideband_clk               ${perf_mon_inst}.csr_clk
               add_connection $reset_handler.reset_n_out  ${perf_mon_inst}.csr_reset_n
            }
         }
      }
   }

   if {$user_access_mode == "fabric_async" ||
      $user_access_mode == "noc" } {

      if {$ip_params(EX_DESIGN_TG_CSR_ACCESS_MODE) == "JTAG"} {
         add_connection $sideband_clk                   $tg.remote_intf_clk
         add_connection $reset_handler.reset_n_out      $tg.remote_intf_reset
      }

      if {$use_pmon} {
         if {$pmon_internal_jamb == "false"} {
            add_connection $sideband_clk               ${jamb_inst}.clk
            add_connection $reset_handler.reset_n_out  ${jamb_inst}.clk_reset
         }

         for {set ch_idx 0} {$ch_idx < $num_channels} {incr ch_idx} {
            set pmon_enabled [expr {[lsearch -exact $pmon_enabled_drivers $ch_idx] >= 0}]    
            if {$pmon_enabled} {
               incr pmon_idx
               set perf_mon_inst [lindex $pmon_inst_list $pmon_idx]

               add_connection $sideband_clk               ${perf_mon_inst}.csr_clk
               add_connection $reset_handler.reset_n_out          ${perf_mon_inst}.csr_reset_n   
            }
         }
      }
   }
   set is_ddr4dimm [expr {$ed_params(EMIF_MODULE_NAME) == "emif_io96b_ddr4dimm"}]
   if {$is_ddr4dimm && $sideband_in_use} {
      add_component_helper $ddr4dimm_rh mem_reset_handler
      load_component $ddr4dimm_rh
         set_component_parameter_value  NUM_RESETS   2
         set_component_parameter_value  NUM_CONDUITS 0
         set_component_parameter_value  SYNC_TO_CLK  true
      save_component; 
      add_connection  $axil_driver_0.cal_done_rst_n   $ddr4dimm_rh.reset_n_0
      add_connection  $emif.s0_axi4_ctrl_ready        $ddr4dimm_rh.reset_n_1
      add_connection  $emif.s0_axi4_clock_out         $ddr4dimm_rh.clk
   }


   if {$use_wide_tg && $sideband_in_use} {
      add_component_helper $wide_tg_rh_0 mem_reset_handler
      load_component $wide_tg_rh_0
         set_component_parameter_value  NUM_RESETS   2
         set_component_parameter_value  NUM_CONDUITS 0
      save_component; 
      add_connection  $axil_driver_0.cal_done_rst_n   $wide_tg_rh_0.reset_n_0
      add_connection  $emif.s0_axi4_ctrl_ready        $wide_tg_rh_0.reset_n_1

      if {$num_io96 != 1 && ![string is true $is_lockstep]} {
         add_component_helper $wide_tg_rh_1 mem_reset_handler
         load_component $wide_tg_rh_1
            set_component_parameter_value  NUM_RESETS   2
            set_component_parameter_value  NUM_CONDUITS 0
         save_component; 
         add_connection  $axil_driver_1.cal_done_rst_n   $wide_tg_rh_1.reset_n_0
         add_connection  $emif.s0_axi4_ctrl_ready        $wide_tg_rh_1.reset_n_1
      }
   }

   set ch_idx 0
   set pmon_idx -1
   
   for {set ip_idx 0} {$ip_idx < [expr {[string is true $is_lockstep] ? 1 : $num_io96}]} {incr ip_idx} {
      set driver_clock ""
      if {$user_access_mode == "fabric_sync"} {
         set driver_clock "$emif.s${ip_idx}_axi4_clock_out"
      } else {
         set driver_clock $hydra_clk
      }

      set driver_reset "" 
      if {$sideband_in_use} {
         if {$ip_idx == 0} {
            if {$is_ddr4dimm} {
               set driver_reset $ddr4dimm_rh.reset_n_out
            } elseif {$use_wide_tg} {
               set driver_reset $wide_tg_rh_0.reset_n_out
            } else {
               set driver_reset $axil_driver_0.cal_done_rst_n
            }
         } else {
            if {$use_wide_tg} {
               set driver_reset $wide_tg_rh_1.reset_n_out
            } else {
               set driver_reset $axil_driver_1.cal_done_rst_n
            }
         }
      } else {
         if {$user_access_mode == "fabric_sync"} {
            set driver_reset "$emif.s${ip_idx}_axi4_ctrl_ready"
         } else {
            set driver_reset "$reset_handler.reset_n_out" 
         }
      }

      for {set intf_idx 0} {$intf_idx < $num_channels_per_io96} {incr intf_idx} {
         add_connection    $driver_reset  $tg.driver${ch_idx}_reset
         add_connection    $driver_clock  $tg.driver${ch_idx}_clk

         set pmon_enabled [expr {[lsearch -exact $pmon_enabled_drivers $ch_idx] >= 0}]
         if {$use_pmon && $pmon_enabled} {
            incr pmon_idx
            set perf_mon_inst [lindex $pmon_inst_list $pmon_idx]

            add_connection $driver_reset  ${perf_mon_inst}.reset_n
            add_connection $driver_clock  ${perf_mon_inst}.clk
         }
         incr ch_idx
      }
   }
    
   set axil_driver_clk_0 ""
   set axil_driver_clk_1 ""
   if {$use_pll_for_sideband} {
      set axil_driver_clk_0 "$sideband_clk"
      set axil_driver_clk_1 "$axil_driver_clk_0"
   } else {
      set axil_driver_clk_0 "$emif.s0_axi4_clock_out"
      set axil_driver_clk_1 "$emif.s1_axi4_clock_out"
   }
   if {$sideband_in_use} {
      add_connection $axil_driver_clk_0           $axil_driver_0.axil_driver_clk
      add_connection $reset_handler.reset_n_out   $axil_driver_0.axil_driver_rst_n
      if {$num_io96 != 1 && ![string is true $is_lockstep]} {
         add_connection $axil_driver_clk_1            $axil_driver_1.axil_driver_clk
         add_connection $reset_handler.reset_n_out    $axil_driver_1.axil_driver_rst_n
      }
   }


   if {$user_access_mode == "fabric_sync"} {
      set pmon_idx -1
      for {set ch_idx 0} {$ch_idx < $num_channels} {incr ch_idx} {
         set pmon_enabled [expr {[lsearch -exact $pmon_enabled_drivers $ch_idx] >= 0}]
         if {$use_pmon && $pmon_enabled} {
            incr pmon_idx
            set perf_mon_inst [lindex $pmon_inst_list $pmon_idx]

            add_connection $tg.driver${ch_idx}_axi4 ${perf_mon_inst}.sink_axi4
            add_connection ${perf_mon_inst}.src_axi4 $emif.s${ch_idx}_axi4
         } else {
            add_connection $tg.driver${ch_idx}_axi4     $emif.s${ch_idx}_axi4
         }
      }
       
      add_connection $rrip.ninit_done          $emif.core_init_n
 
   }

   if {$user_access_mode == "fabric_async"} {
      set pmon_idx -1
      for {set ch_idx 0} {$ch_idx < $num_channels} {incr ch_idx} {
         set pmon_enabled [expr {[lsearch -exact $pmon_enabled_drivers $ch_idx] >= 0}]
         if {$use_pmon && $pmon_enabled} {
            incr pmon_idx
            set perf_mon_inst [lindex $pmon_inst_list $pmon_idx]

            add_connection $tg.driver${ch_idx}_axi4 ${perf_mon_inst}.sink_axi4
            add_connection ${perf_mon_inst}.src_axi4 $emif.s${ch_idx}_axi4
         } else {
            add_connection $tg.driver${ch_idx}_axi4     $emif.s${ch_idx}_axi4
         }
      }
      add_connection $emif_clk                          $emif.s0_axi4_clock_in
      add_connection $reset_handler.reset_n_out         $emif.core_init_n
   }

   if {$user_access_mode == "noc" || ($sideband_in_use && $sideband_is_noc)} {
      add_component_helper $noc_ctrl intel_noc_clock_ctrl
      load_component $noc_ctrl
         set_component_parameter_value REFCLK_FREQ "NOC_PLL_REFCLK_FREQ_$ip_params(EX_DESIGN_NOC_PLL_REFCLK_FREQ_MHZ)_MHZ"
      save_component; 
      add_interface noc_ctrl_refclk clock source
      set_interface_property noc_ctrl_refclk EXPORT_OF ${noc_ctrl}.refclk
   } 
   
   if {$user_access_mode == "noc"} {
      add_component_helper $noc_init intel_noc_initiator
      load_component $noc_init
         set_component_parameter_value  INDIVIDUAL_AXI_CLKRESET  false
         set_component_parameter_value  NUM_AXI4_IF              $num_channels
         set_component_parameter_value  AXI4_DATA_MODE           "AXI4_DATA_MODE_$axi4_data_width"
         set_component_parameter_value  NUM_AXI4LITE_IF          0
         set_component_parameter_value  AXI4_HANDSHAKE           AXI4_HANDSHAKE_STANDARD
         set_component_parameter_value  NOC_QOS_MODE             NOC_QOS_MODE_SOCKET
         set_component_parameter_value  NOC_QOS_READ_PRIORITY    0
         set_component_parameter_value  NOC_QOS_WRITE_PRIORITY   0
         set_component_parameter_value  ENABLE_SECURITY          OFF
      save_component; 

      add_connection $emif_clk                    $noc_init.s_axi4_aclk
      add_connection $reset_handler.reset_n_out   $noc_init.s_axi4_aresetn

      set pmon_idx -1
      for {set ch_idx 0} {$ch_idx < $num_channels} {incr ch_idx} {
         set addr_width_for_noc_override 44
         set user_addr_width_for_noc_override 11
         load_component $tg
            set_component_parameter_value DRIVER_${ch_idx}_MEM_AXI4_AWADDR_WIDTH   $addr_width_for_noc_override
            set_component_parameter_value DRIVER_${ch_idx}_MEM_AXI4_ARADDR_WIDTH   $addr_width_for_noc_override

            set_component_parameter_value DRIVER_${ch_idx}_MEM_AXI4_AWUSER_WIDTH   $user_addr_width_for_noc_override
            set_component_parameter_value DRIVER_${ch_idx}_MEM_AXI4_ARUSER_WIDTH   $user_addr_width_for_noc_override
         save_component; 

         set pmon_enabled [expr {[lsearch -exact $pmon_enabled_drivers $ch_idx] >= 0}]
         if {$use_pmon && $pmon_enabled} {
            incr pmon_idx
            set perf_mon_inst [lindex $pmon_inst_list $pmon_idx]

            set_instance_parameter_value  $perf_mon_inst MONITOR_0_MEM_AXI4_AWADDR_WIDTH       $addr_width_for_noc_override
            set_instance_parameter_value  $perf_mon_inst MONITOR_0_MEM_AXI4_ARADDR_WIDTH       $addr_width_for_noc_override
            
            set_instance_parameter_value  $perf_mon_inst MONITOR_0_MEM_AXI4_AWUSER_WIDTH       $user_addr_width_for_noc_override
            set_instance_parameter_value  $perf_mon_inst MONITOR_0_MEM_AXI4_ARUSER_WIDTH       $user_addr_width_for_noc_override

            add_connection $tg.driver${ch_idx}_axi4 ${perf_mon_inst}.sink_axi4
            add_connection ${perf_mon_inst}.src_axi4 $noc_init.s${ch_idx}_axi4
         } else {
            add_connection $tg.driver${ch_idx}_axi4     $noc_init.s${ch_idx}_axi4
         }

         add_connection $noc_init.i${ch_idx}_axi4noc $emif.s${ch_idx}_noc_axi4noc
         set_connection_parameter_value $noc_init.i${ch_idx}_axi4noc/$emif.s${ch_idx}_noc_axi4noc baseAddress 0x0

         if {!$sideband_in_use} {
            add_connection $reset_handler.reset_n_out         $tg.driver${ch_idx}_reset
         }
      }
   }


   if {$sideband_in_use || $debug_tools_en} {
      if {$use_pll_for_sideband} {
         set clock_source_0 $sideband_clk
      } else {
         puts "Internal Error: expecting to always use standalone PLL for sideband because otherwise can't close timing on the sideband (on tg/iossm). Please make sure this is intentional..." 
         exit 
      }
      set clock_source_1 $clock_source_0
      set reset_source_0 $reset_handler.reset_n_out
      set reset_source_1 $reset_source_0
      if {$sideband_is_noc} {
         add_component_helper $noc_init_lite_0 intel_noc_initiator
         load_component $noc_init_lite_0
            set_component_parameter_value  INDIVIDUAL_AXI_CLKRESET  false
            set_component_parameter_value  NUM_AXI4_IF              0
            set_component_parameter_value  AXI4_DATA_MODE           AXI4_DATA_MODE_256
            set_component_parameter_value  NUM_AXI4LITE_IF          1
            set_component_parameter_value  AXI4_HANDSHAKE           AXI4_HANDSHAKE_STANDARD
            set_component_parameter_value  NOC_QOS_MODE             NOC_QOS_MODE_SOCKET
            set_component_parameter_value  NOC_QOS_READ_PRIORITY    0
            set_component_parameter_value  NOC_QOS_WRITE_PRIORITY   0
            set_component_parameter_value  ENABLE_SECURITY          OFF
         save_component; 
 
         add_connection $noc_init_lite_0.i0_axi4noc $emif.s0_noc_axi4litenoc
         set_connection_parameter_value $noc_init_lite_0.i0_axi4noc/$emif.s0_noc_axi4litenoc baseAddress 0x0

         if { $num_io96 != 1 } {
            add_component_helper $noc_init_lite_1 intel_noc_initiator
            load_component $noc_init_lite_1
               set_component_parameter_value  INDIVIDUAL_AXI_CLKRESET  false
               set_component_parameter_value  NUM_AXI4_IF              0
               set_component_parameter_value  AXI4_DATA_MODE           AXI4_DATA_MODE_256
               set_component_parameter_value  NUM_AXI4LITE_IF          1
               set_component_parameter_value  AXI4_HANDSHAKE           AXI4_HANDSHAKE_STANDARD
               set_component_parameter_value  NOC_QOS_MODE             NOC_QOS_MODE_SOCKET
               set_component_parameter_value  NOC_QOS_READ_PRIORITY    0
               set_component_parameter_value  NOC_QOS_WRITE_PRIORITY   0
               set_component_parameter_value  ENABLE_SECURITY          OFF
            save_component; 
 
            add_connection $noc_init_lite_1.i0_axi4noc $emif.s1_noc_axi4litenoc
            set_connection_parameter_value $noc_init_lite_1.i0_axi4noc/$emif.s1_noc_axi4litenoc baseAddress 0x0
         }
           
         add_connection $axil_driver_0.axil_driver_axi4_lite $noc_init_lite_0.s0_axi4lite
         add_connection $clock_source_0  $noc_init_lite_0.s_axi4lite_aclk
         add_connection $reset_source_0  $noc_init_lite_0.s_axi4lite_aresetn 
         if { $num_io96 != 1 && ![string is true $is_lockstep] } {
            add_connection $axil_driver_1.axil_driver_axi4_lite $noc_init_lite_1.s0_axi4lite
            add_connection $clock_source_1  $noc_init_lite_1.s_axi4lite_aclk
            add_connection $reset_source_1  $noc_init_lite_1.s_axi4lite_aresetn 
         }
      } elseif {$sideband_in_use} { 
         add_connection $axil_driver_0.axil_driver_axi4_lite  $emif.s0_axi4lite
         if { $num_io96 != 1 && ![string is true $is_lockstep] } {
            add_connection $axil_driver_1.axil_driver_axi4_lite  $emif.s1_axi4lite
         }
      }
      if {($sideband_in_use&&!$sideband_is_noc) || $debug_tools_en} {
         add_connection $clock_source_0 $emif.s0_axi4lite_clock
         add_connection $reset_source_0 $emif.s0_axi4lite_reset_n
         if { $num_io96 != 1 && ![string is true $is_lockstep] } {
            add_connection $clock_source_1 $emif.s1_axi4lite_clock
            add_connection $reset_source_1 $emif.s1_axi4lite_reset_n
         }
      }
   }


   if {$use_unoc} {

      load_component $noc_init
         set_component_parameter_value  AXI4_DATA_MODE   "AXI4_DATA_MODE_512"
      save_component; 

      if {$design_type == "sim"} {
         add_component_helper $noc_rh mem_reset_handler
         load_component $noc_rh
            set_component_parameter_value  NUM_CONDUITS 1
            set_component_parameter_value  NUM_RESETS   0
            set_component_parameter_value  SYNC_TO_CLK  true
            set_component_parameter_value  CONDUIT_TYPE_0 "pll_lock_o"
         save_component; 
         add_connection    $hydra_clk                   $noc_rh.clk
         add_connection    $noc_ctrl.pll_lock_o         $noc_rh.conduit_0
         remove_connection $reset_handler.reset_n_out/$noc_init.s_axi4_aresetn
         add_connection    $noc_rh.reset_n_out        $noc_init.s_axi4_aresetn
         if {$sideband_in_use && $sideband_is_noc} {
            remove_connection $reset_handler.reset_n_out/$noc_init_lite_0.s_axi4lite_aresetn
            add_connection    $noc_rh.reset_n_out        $noc_init_lite_0.s_axi4lite_aresetn
            if {$num_io96 != 1 && ![string is true $is_lockstep]} {
               remove_connection $reset_handler.reset_n_out/$noc_init_lite_1.s_axi4lite_aresetn
               add_connection    $noc_rh.reset_n_out        $noc_init_lite_1.s_axi4lite_aresetn
            }
         }
      }

      add_connection $noc_bridge_clk   $noc_init.noc_bridge_fabric_clk
   }

   if {[string is true $use_hydra_status_if]} {
      add_interface ${tg}_tg_status conduit end
      set_interface_property ${tg}_tg_status EXPORT_OF $tg.status
   }
   if {$ip_params(EX_DESIGN_TG_CSR_ACCESS_MODE) == "EXPORT"} {
      add_interface          global_csr_clk clock     end
      set_interface_property global_csr_clk EXPORT_OF $tg.global_csr_clk

      add_interface          global_csr_reset reset     sink 
      set_interface_property global_csr_reset EXPORT_OF $tg.global_csr_reset

      add_interface          global_csr_axi4l conduit   end
      set_interface_property global_csr_axi4l EXPORT_OF $tg.global_csr_axi4l

      for {set ch_idx 0} {$ch_idx < $num_channels} {incr ch_idx} {
         set intf_name driver${ch_idx}_csr_clk
         add_interface          $intf_name clock     end
         set_interface_property $intf_name EXPORT_OF $tg.$intf_name

         set intf_name driver${ch_idx}_csr_reset
         add_interface          $intf_name reset     sink 
         set_interface_property $intf_name EXPORT_OF $tg.$intf_name

         set intf_name driver${ch_idx}_csr_axi4l
         add_interface          $intf_name conduit   end
         set_interface_property $intf_name EXPORT_OF $tg.$intf_name
      }
   }


   if {$use_wide_tg} {
      set pmon_idx -1
      for {set ch_idx 0} {$ch_idx < $num_channels} {incr ch_idx} {
         set pmon_enabled [expr {[lsearch -exact $pmon_enabled_drivers $ch_idx] >= 0}]
         if {$use_pmon && $pmon_enabled} {
            incr pmon_idx
            set domain_inst "[lindex $pmon_inst_list $ch_idx].src_axi4"
         } else {
            set domain_inst "$tg.driver${ch_idx}_axi4"
         }
         set_domain_assignment $domain_inst qsys_mm.clockCrossingAdapter         "FIFO"
         set_domain_assignment $domain_inst qsys_mm.enableAllPipelines           "TRUE"
         set_domain_assignment $domain_inst qsys_mm.burstAdapterImplementation   "PER_BURST_TYPE_CONVERTER"
         set_domain_assignment $domain_inst qsys_mm.syncResets                   "FALSE"
         set_domain_assignment $domain_inst qsys_mm.responseFifoType             "EMBEDDED_MEMORY_BASED"
         set_domain_assignment $domain_inst qsys_mm.fifoDepth                    "16"
      }
   }

   set is_mem_reset_per_channel [expr [lsearch $emif_interfaces_list "mem_reset_n_0"] >= 0] 
   set is_mem_ck_per_channel [expr [lsearch $emif_interfaces_list "mem_ck_0"] >= 0] 
    
   set is_i3c_used [expr [lsearch $emif_interfaces_list "mem_i3c"] >= 0]
    
   set is_lbd_used [expr [lsearch $emif_interfaces_list "mem_lb_dq"] >= 0]

   if {$design_type == "synth"} {

      for {set ch_idx 0} {$ch_idx < $num_channels} {incr ch_idx} {
         add_interface          ${emif}_mem_${ch_idx}      conduit end
         set_interface_property ${emif}_mem_${ch_idx}      EXPORT_OF $emif.mem_${ch_idx}

         add_interface          ${emif}_oct_${ch_idx}      conduit end
         set_interface_property ${emif}_oct_${ch_idx}      EXPORT_OF $emif.oct_${ch_idx}
      }        

      if {$is_mem_reset_per_channel} {
         for {set ch_idx 0} {$ch_idx < $num_channels} {incr ch_idx} {
            add_interface          ${emif}_mem_reset_n_${ch_idx}      conduit end
            set_interface_property ${emif}_mem_reset_n_${ch_idx}      EXPORT_OF $emif.mem_reset_n_${ch_idx}
         }
      } else {
            add_interface          ${emif}_mem_reset_n                conduit end
            set_interface_property ${emif}_mem_reset_n                EXPORT_OF $emif.mem_reset_n          
      }

      if {$is_mem_ck_per_channel} {
         for {set ch_idx 0} {$ch_idx < $num_channels} {incr ch_idx} {
            add_interface          ${emif}_mem_ck_${ch_idx}      conduit end
            set_interface_property ${emif}_mem_ck_${ch_idx}      EXPORT_OF $emif.mem_ck_${ch_idx}
         }
      } else {
            add_interface          ${emif}_mem_ck                conduit end
            set_interface_property ${emif}_mem_ck                EXPORT_OF $emif.mem_ck          
      }


      if {$is_i3c_used} {
         add_interface          ${emif}_i3c conduit end
         set_interface_property ${emif}_i3c EXPORT_OF $emif.mem_i3c
      }
      if {$is_lbd_used} {
         add_interface          ${emif}_lbd conduit end
         set_interface_property ${emif}_lbd EXPORT_OF $emif.mem_lb_dq
         add_interface          ${emif}_lbs conduit end
         set_interface_property ${emif}_lbs EXPORT_OF $emif.mem_lb_dqs
      }

      add_interface ref_clk clock end
         set_interface_property ref_clk EXPORT_OF $emif.ref_clk

      if {$use_pll_for_sideband || $use_pll_for_mainband} {
         add_interface               ref_clk_usr_pll clock   end
         set_interface_property      ref_clk_usr_pll EXPORT_OF $user_pll.refclk
      }

      return
   }

   for {set ch_idx 0} {$ch_idx < $num_channels} {incr ch_idx} {
      remove_interface  ${emif}_mem_${ch_idx}
      remove_interface  ${emif}_oct_${ch_idx}
   }
   if {$is_mem_ck_per_channel} {
      for {set ch_idx 0} {$ch_idx < $num_channels} {incr ch_idx} {
         remove_interface  ${emif}_mem_ck_${ch_idx}
      }
   } else {
         remove_interface  ${emif}_mem_ck
   }
   if {$is_mem_reset_per_channel} {
      for {set ch_idx 0} {$ch_idx < $num_channels} {incr ch_idx} {
         remove_interface  ${emif}_mem_reset_n_${ch_idx}
      }
   } else {
         remove_interface  ${emif}_mem_reset_n
   }

   remove_interface  ${emif}_i3c
   remove_interface  ${emif}_lbd
   remove_interface  ${emif}_lbs
   remove_interface  ref_clk_usr_pll
   remove_interface  rst_n

   set mem mem
   add_component_helper $mem emif_io96b_mem_model_$tech
   load_component $mem
      set_component_parameter_values $mem_param_lst
   save_component; 

   for {set ch_idx 0} {$ch_idx < $num_channels} {incr ch_idx} {
      add_connection $mem.mem_${ch_idx}          $emif.mem_${ch_idx}
   }
   if {$is_mem_ck_per_channel} {
      for {set ch_idx 0} {$ch_idx < $num_channels} {incr ch_idx} {
         add_connection $mem.mem_ck_${ch_idx}       $emif.mem_ck_${ch_idx}
      }
   } else {
         add_connection $mem.mem_ck_0               $emif.mem_ck
   }

   if {$is_mem_reset_per_channel} {
      for {set ch_idx 0} {$ch_idx < $num_channels} {incr ch_idx} {
         add_connection $mem.mem_reset_n_${ch_idx}  $emif.mem_reset_n_${ch_idx}
      }
   } else {
      if {$tech == "ddr5"} {
         add_connection $mem.mem_reset_n_0          $emif.mem_reset_n
      } else {
         add_connection $mem.mem_reset_n            $emif.mem_reset_n
      }
   }

   for {set ch_idx 0} {$ch_idx < $num_channels} {incr ch_idx} {
      add_connection $mem.oct_${ch_idx}       $emif.oct_${ch_idx}
   }

   if {$is_i3c_used} {
      add_connection $mem.i3c                 $emif.mem_i3c
   }
   if {$is_lbd_used} {
      add_connection $mem.mem_lbd             $emif.mem_lb_dq
      add_connection $mem.mem_lbs             $emif.mem_lb_dqs
   }

   set ref_clock_src ref_clk_source

   for {set ch_idx 0} {$ch_idx < $num_refclks} {incr ch_idx} {
      add_component_helper ${ref_clock_src}_${ch_idx} altera_avalon_clock_source
      load_component ${ref_clock_src}_${ch_idx}
         set_component_parameter_value  CLOCK_RATE [expr {round($ip_params(PHY_REFCLK_FREQ_MHZ) * 1000000.0)}]
         set_component_parameter_value  CLOCK_UNIT 1
      save_component; 
         add_connection ${ref_clock_src}_${ch_idx}.clk      $emif.ref_clk
   }

   if {$use_pll_for_sideband || $use_pll_for_mainband} {
      set async_clock_src async_clk_source
      add_component_helper $async_clock_src altera_avalon_clock_source
      load_component $async_clock_src
         set_component_parameter_value  CLOCK_RATE [expr {round($usr_reference_clock_frequency * 1000000.0)}]
         set_component_parameter_value  CLOCK_UNIT 1
      save_component; 
      add_connection $async_clock_src.clk        $user_pll.refclk
   }

}

proc validate { } {
   set_validation_property AUTOMATIC_VALIDATION true
   set_validation_property AUTOMATIC_VALIDATION false
}

proc parse_extra_configs {str} {
   foreach item [split $str ",; "] {
      set tmp [split $item "="]
      if {[llength $tmp] == 2} {
         set name [string toupper [lindex $tmp 0]]
         set val [lindex $tmp 1]
         set retval($name) $val
      }
   }
   return [array get retval]
}

proc add_component_helper {ip_inst ip_type} {
   upvar module_prefix module_prefix
   add_component $ip_inst ${module_prefix}${ip_inst}.ip $ip_type
}

proc port_to_param { port_name } {
   regsub {_[0-9]} $port_name _width pname
   regsub {mem_ba} $pname mem_bank_addr pname 
   regsub {mem_bg} $pname mem_bank_group_addr pname
   set pname [string toupper $pname]
   return $pname   
}

proc is_pow_2 { num } {
   return [expr {[lsearch [list 16 32 64] $num] != -1}]
}

set print_profile_flag 1 

set time_start [clock clicks -milliseconds]
set qsys_filepath $ed_params(TMP_SYNTH_QSYS_PATH)
create_system
save_system $qsys_filepath
load_system $qsys_filepath
gen_sys "synth"
sync_sysinfo_parameters
validate
save_system $qsys_filepath
set time_end [clock clicks -milliseconds]
if {$print_profile_flag} {
   puts "EMIF Make Qsys: configuring the synthesis ex-design took [expr {$time_end - $time_start}]ms."
}

set time_start [clock clicks -milliseconds]
set qsys_filepath $ed_params(TMP_SIM_QSYS_PATH)
create_system
save_system $qsys_filepath
load_system $qsys_filepath
gen_sys "sim"
sync_sysinfo_parameters
validate
save_system $qsys_filepath
set time_end [clock clicks -milliseconds]
if {$print_profile_flag} {
   puts "EMIF Make Qsys: configuring the simulation ex-design took [expr {$time_end - $time_start}]ms."
}


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


package require -exact qsys 20.1

if {! [info exists ip_params] || ! [info exists ed_params]} {
   source "params.tcl"
}

switch -regexp $ip_params(FAMILY_ENUM) {
   AGILEX* {
      set family_traits(DFT_IF)           "dft_fm"
      set family_traits(HAS_GLOBAL_RESET) 0
      set family_traits(HAS_LOCAL_RESET)  1
   }
   default {
      puts stderr "Error: make_qsys.tcl encounters unsupported family $ip_params(FAMILY_ENUM)"
      exit
   }
}

set ip_param_lst [list]
foreach param_name [array names ip_params] {
   lappend ip_param_lst $param_name
   lappend ip_param_lst $ip_params($param_name)
}

proc gen_sys {design_type} {
   upvar ip_params ip_params
   upvar ed_params ed_params
   upvar ip_param_lst ip_param_lst
   upvar family_traits family_traits

   set dft_if              $family_traits(DFT_IF)
   set has_global_reset    $family_traits(HAS_GLOBAL_RESET)
   set has_local_reset     $family_traits(HAS_LOCAL_RESET)
   
   set emif_module         $ed_params(EMIF_MODULE_NAME)
   set protocol_enum       $ip_params(PROTOCOL_ENUM)
   set protocol            [lindex [split $protocol_enum "_"] 1]
   set config_enum         $ip_params(PHY_CONFIG_ENUM)
   set ping_pong_en        $ip_params(PHY_PING_PONG_EN)
   set num_slaves          $ip_params(DIAG_EX_DESIGN_NUM_OF_SLAVES)
   set main_emif           $ed_params(EMIF_NAME)
   set use_tg_avl_2        [expr {$ip_params(DIAG_USE_TG_AVL_2) && ($ip_params(PHY_CONFIG_ENUM) != "CONFIG_PHY_ONLY")}]

   set cal_param_names  [list DIAG_SIM_CAL_MODE_ENUM       \
                              DIAG_EXTRA_CONFIGS           \
                              DIAG_EXPORT_VJI              \
                              DIAG_SYNTH_FOR_SIM           \
                              SHORT_QSYS_INTERFACE_NAMES   \
                              DIAG_EXPORT_SEQ_AVALON_SLAVE \
                              DIAG_ENABLE_JTAG_UART        \
                         ] 

   if {$ip_params(PHY_CORE_CLKS_SHARING_ENUM) == "CORE_CLKS_SHARING_DISABLED"} {
      set emifs                     [list $main_emif]
      set sharing_enums             [list "CORE_CLKS_SHARING_DISABLED"]
      set sharing_expose_slave_outs [list 0]
      set calbus_ifs                [list "emif_calbus_0"]
      set tgs                       [list "tg"]
      set mems                      [list "mem"]
      set emif_master               [lindex $emifs 0]
      set tg_cfg_bfms               [list "tg_cfg_bfm0"]

   } elseif {$ip_params(PHY_CORE_CLKS_SHARING_ENUM) == "CORE_CLKS_SHARING_MASTER"} {
      set emifs                     [list $main_emif]
      set sharing_enums             [list "CORE_CLKS_SHARING_MASTER"]
      set sharing_expose_slave_outs [list 0]
      set calbus_ifs                [list "emif_calbus_0"]
      set tgs                       [list "tg_0"]
      set mems                      [list "mem_0"]
      set tg_cfg_bfms               [list "tg_cfg_bfm0"]

      for {set i 0} {$i < $num_slaves} {incr i} {
         set index [expr {$i + 1}]
         lappend emifs                     "emif_slave_$index"
         lappend sharing_enums             "CORE_CLKS_SHARING_SLAVE"
         lappend sharing_expose_slave_outs [list [expr {$i < ($num_slaves - 1) ? 1 : 0}]]
         lappend calbus_ifs                "emif_calbus_$index"
         lappend tgs                       "tg_$index"
         lappend mems                      "mem_$index"
         lappend tg_cfg_bfms               "tg_cfg_bfm$index"
      }
      set emif_master   [lindex $emifs 0]

   } elseif {$ip_params(PHY_CORE_CLKS_SHARING_ENUM) == "CORE_CLKS_SHARING_SLAVE"} {
      set emifs                     [list "emif_master" $main_emif]
      set sharing_enums             [list "CORE_CLKS_SHARING_MASTER" "CORE_CLKS_SHARING_SLAVE"]
      set sharing_expose_slave_outs [list 0 [expr {$num_slaves > 1 ? 1 : 0}]]
      set calbus_ifs                [list "emif_calbus_0" "emif_calbus_1"]
      set tgs                       [list "tg_0" "tg_1"]
      set mems                      [list "mem_0" "mem_1"]
      set tg_cfg_bfms               [list "tg_cfg_bfm0" "tg_cfg_bfm1"]

      for {set i 1} {$i < $num_slaves} {incr i} {
         set index [expr {$i + 1}]
         lappend emifs                     "emif_slave_$index"
         lappend sharing_enums             "CORE_CLKS_SHARING_SLAVE"
         lappend sharing_expose_slave_outs [expr {$i < ($num_slaves - 1) ? 1 : 0}]
         lappend calbus_ifs                "emif_calbus_$index"
         lappend tgs                       "tg_$index"
         lappend mems                      "mem_$index"
         lappend tg_cfg_bfms               "tg_cfg_bfm$index"
      }
      set emif_master   [lindex $emifs 0]

   } else {
      puts "Unrecognized PHY_CORE_CLKS_SHARING_ENUM value: $ip_params(PHY_CORE_CLKS_SHARING_ENUM)"
      exit
   }

   set_project_property DEVICE_FAMILY $ip_params(SYS_INFO_DEVICE_FAMILY)
   set_project_property DEVICE $ed_params(DEFAULT_DEVICE)


   set_validation_property AUTOMATIC_VALIDATION false

   set emif_cal_wrapper "emif_cal"
   add_instance $emif_cal_wrapper altera_emif_cal
   set_instance_parameter_value $emif_cal_wrapper NUM_CALBUS_INTERFACE [llength $calbus_ifs]
   foreach param_name $cal_param_names {
      set_instance_parameter_value $emif_cal_wrapper $param_name $ip_params($param_name)
   }
   add_interface calbus_clk clock sink
   set_interface_property calbus_clk EXPORT_OF ${emif_cal_wrapper}.emif_calbus_clk
   
   foreach emif $emifs {
      add_instance $emif $emif_module
   }

   foreach tg $tgs {
      if {$config_enum == "CONFIG_PHY_ONLY"} {
         add_instance $tg altera_emif_tg_afi_[string tolower $protocol]
      } elseif {$use_tg_avl_2} {
         add_instance $tg altera_emif_tg_avl_2
      } else {
         add_instance $tg altera_emif_tg_avl
      }
   }

   foreach inst $emifs {
      set_instance_parameter_values $inst $ip_param_lst

      if {$inst != $emif_master} {
         set_instance_parameter_value $inst IS_ED_SLAVE true
      }
      if {$has_local_reset} {
         set_instance_parameter_value $inst DIAG_EXPORT_PLL_REF_CLK_OUT true
         set_instance_parameter_value $inst DIAG_EXPORT_PLL_LOCKED true
      }
   }
   foreach inst $tgs {
      set_instance_parameter_values $inst $ip_param_lst
   }

   if {$use_tg_avl_2} {
      set tg_cfg_amm_export_mode [get_instance_parameter_value $inst DIAG_EXPORT_TG_CFG_AVALON_SLAVE]
      set_instance_parameter_value $tg DIAG_EXPORT_TG_CFG_AVALON_SLAVE $tg_cfg_amm_export_mode
      if {$tg_cfg_amm_export_mode == "TG_CFG_AMM_EXPORT_MODE_EXPORT"} {
         set tg_cfg_interface tg_cfg
         add_interface $tg_cfg_interface avalon slave
         set_interface_property $tg_cfg_interface EXPORT_OF $tg.tg_cfg_0
      } 
   }

   set ninit_done_if "ninit_done"
   add_instance $ninit_done_if altera_s10_user_rst_clkgate
   set_instance_parameter_value $ninit_done_if outputType "Reset Interface"

   validate_system
   set_validation_property AUTOMATIC_VALIDATION true

   set cal_oct $ip_params(PHY_CALIBRATED_OCT)

   if {$has_global_reset} {
      set grst_splitter "global_reset_n_splitter"
      add_instance $grst_splitter altera_emif_sig_splitter
      set_instance_parameter_value $grst_splitter NUM_OF_FANOUTS [llength $emifs]
      set_instance_parameter_value $grst_splitter INTERFACE_TYPE "reset"
      set_instance_parameter_value $grst_splitter PORT_ROLE "reset_n"
      
      add_interface global_reset reset sink
      set_interface_property global_reset EXPORT_OF ${grst_splitter}.sig_input_if
   }
   
   if {$has_local_reset} {
      set lrst_combiner "local_reset_combiner"
      add_instance $lrst_combiner altera_emif_local_reset_combiner
      set_instance_parameter_value $lrst_combiner NUM_OF_RESET_REQ_IFS 1
      set_instance_parameter_value $lrst_combiner NUM_OF_RESET_STATUS_IFS [llength $emifs]
      
      set_instance_parameter_value $lrst_combiner EXPOSE_RESET_AS_CONDUIT true
      set_instance_parameter_value $lrst_combiner RESET_CONDUIT_ROLE pll_locked
      
      add_interface local_reset_req conduit end
      set_interface_property local_reset_req EXPORT_OF ${lrst_combiner}.local_reset_req
      set_interface_port_property local_reset_req local_reset_req_local_reset_req NAME local_reset_req
      
      add_interface local_reset_status conduit end
      set_interface_property local_reset_status EXPORT_OF ${lrst_combiner}.local_reset_status
      set_interface_port_property local_reset_status local_reset_status_local_reset_done NAME local_reset_done
   }

   if {$ip_params(DIAG_EXPOSE_DFT_SIGNALS)} {
      foreach inst $emifs {
         set if_name "${inst}_dft"
         add_interface $if_name conduit end
         set_interface_property $if_name EXPORT_OF ${inst}.${dft_if}
      }
   }

   set num_tg_status_ifs 0

   set emif_index 0

   set invalid_interface_id 15
   set main_interface_id [get_instance_parameter_value $main_emif "DIAG_INTERFACE_ID"]
   set curr_interface_id [expr {($main_interface_id + 1) % $invalid_interface_id}]
   
   set last_emif_slave ""

   foreach emif $emifs tg $tgs sharing_enum $sharing_enums sharing_expose_slave_out $sharing_expose_slave_outs calbus_if $calbus_ifs {

      set_instance_parameter_value $emif "PHY_${protocol}_CORE_CLKS_SHARING_ENUM" $sharing_enum
      set_instance_parameter_value $emif "PHY_${protocol}_CORE_CLKS_SHARING_EXPOSE_SLAVE_OUT" $sharing_expose_slave_out

      if {$sharing_enum != "CORE_CLKS_SHARING_SLAVE"} {
         add_interface ${emif}_pll_ref_clk clock end
         set_interface_property ${emif}_pll_ref_clk EXPORT_OF ${emif}.pll_ref_clk

         if {$has_global_reset} {
            add_connection ${grst_splitter}.sig_output_if_${emif_index} ${emif}.global_reset_n
         }
         if {$has_local_reset} {
            add_connection ${lrst_combiner}.local_reset_req_out_${emif_index} ${emif}.local_reset_req
            
            add_connection ${emif}.pll_ref_clk_out ${lrst_combiner}.generic_clk
            add_connection ${emif}.pll_locked ${lrst_combiner}.generic_conduit_reset_n
         }
      }
      
      if {$has_local_reset} {
         add_connection ${emif}.local_reset_status ${lrst_combiner}.local_reset_status_in_${emif_index} 
      }

      add_interface ${emif}_mem conduit end
      set_interface_property ${emif}_mem EXPORT_OF ${emif}.mem

      add_interface ${emif}_status conduit end
      set_interface_property ${emif}_status EXPORT_OF ${emif}.status
 
      if { $ip_params(DIAG_AC_PARITY_ERR) }  {
         add_interface ${emif}_ac_parity_err conduit end
         set_interface_property ${emif}_ac_parity_err EXPORT_OF ${emif}.ac_parity_err 
      }

      add_interface $calbus_if conduit end
      set_interface_property $calbus_if EXPORT_OF ${emif_cal_wrapper}.${calbus_if}
       
      if {[get_instance_parameter_value ${emif_cal_wrapper} DIAG_EXPORT_SEQ_AVALON_SLAVE] != "CAL_DEBUG_EXPORT_MODE_DISABLED"} {

         if {$config_enum == "CONFIG_PHY_ONLY"} {
           add_connection ${emif}.afi_clk       ${emif_cal_wrapper}.cal_debug_clk
           add_connection ${emif}.afi_reset_n   ${emif_cal_wrapper}.cal_debug_reset_n
         } else {
           add_connection ${emif}.emif_usr_clk       ${emif_cal_wrapper}.cal_debug_clk
           add_connection ${emif}.emif_usr_reset_n   ${emif_cal_wrapper}.cal_debug_reset_n
         }
        
      } elseif {[get_instance_parameter_value ${emif_cal_wrapper} DIAG_EXPORT_SEQ_AVALON_SLAVE] == "CAL_DEBUG_EXPORT_MODE_EXPORT"} {
         add_interface cal_debug avalon slave
         set_interface_property cal_debug EXPORT_OF ${emif_cal_wrapper}.cal_debug
         add_interface cal_debug_clk clock sink
         set_interface_property cal_debug_clk EXPORT_OF ${emif_cal_wrapper}.cal_debug_clk
         add_interface cal_debug_reset_n reset sink
         set_interface_property cal_debug_reset_n EXPORT_OF ${emif_cal_wrapper}.cal_debug_reset_n
      }

      if {$cal_oct} {
         add_interface ${emif}_oct conduit end
         set_interface_property ${emif}_oct EXPORT_OF ${emif}.oct
      }

      if {$config_enum == "CONFIG_PHY_ONLY"} {
         add_connection ${emif}.afi_reset_n ${tg}.afi_reset_n
         add_connection ${emif}.afi_clk ${tg}.afi_clk
         add_connection ${emif}.afi_half_clk ${tg}.afi_half_clk
      } else {
         add_connection ${emif}.emif_usr_reset_n ${tg}.emif_usr_reset_n
         add_connection ${emif}.emif_usr_clk ${tg}.emif_usr_clk

         if {$ping_pong_en} {
            add_connection ${emif}.emif_usr_reset_n_sec ${tg}.emif_usr_reset_n_sec
            add_connection ${emif}.emif_usr_clk_sec ${tg}.emif_usr_clk_sec
         }
      }

      if {$sharing_enum == "CORE_CLKS_SHARING_SLAVE"} {
         if {$last_emif_slave == ""} {
            add_connection ${emif_master}.clks_sharing_master_out ${emif}.clks_sharing_slave_in
         } else {
            add_connection ${last_emif_slave}.clks_sharing_slave_out ${emif}.clks_sharing_slave_in
         }
         set last_emif_slave $emif
      }

      set tg_conns 0

      foreach if [get_instance_interfaces $emif] {
         if {[string first "ctrl_amm" $if] == 0} {
            add_connection ${tg}.${if} ${emif}.${if}
            incr tg_conns
         }

         if {[string first "emif_calbus_clk" $if] == 0} {
            add_connection ${emif_cal_wrapper}.emif_calbus_clk ${emif}.${if} 
         } elseif {[string first "emif_calbus" $if] == 0} {
            add_connection ${emif_cal_wrapper}.${calbus_if} ${emif}.${if} 
         }
 
         if {[string first "ctrl_auto_precharge" $if] == 0 ||
             [string first "ctrl_user_priority" $if] == 0 ||
             [string first "ctrl_ecc_user_interrupt" $if] == 0 ||
             [string first "ctrl_ecc_readdataerror" $if] == 0} {

            add_connection ${tg}.${if} ${emif}.${if}

         } elseif {[string first "ctrl_mmr_slave" $if] == 0} {
             set from_if [string map {slave master} $if]
             add_connection ${tg}.${from_if} ${emif}.${if}
         }

         if {$if == "afi"} {
            add_connection ${emif}.${if} ${tg}.${if}
            incr tg_conns
         }
      }

      if {$tg_conns <= 0} {
         puts stderr "Error: Unable to connect example traffic generator to memory interface."
         exit
      }

      add_connection $ninit_done_if.$ninit_done_if $tg.$ninit_done_if 

      set tg_status_if_i 0

      foreach if [get_instance_interfaces $tg] {
         if {[string first "tg_status" $if] == 0} {
            set ifname "${emif}_tg_${tg_status_if_i}"
            add_interface $ifname conduit end
            set_interface_property $ifname EXPORT_OF ${tg}.${if}
            incr tg_status_if_i
            incr num_tg_status_ifs
         }
      }

      if {$tg_status_if_i <= 0} {
         puts stderr "Error: Unable to export example traffic generator status interface."
         exit
      }

      if {$emif == $main_emif} {
         if { [get_instance_parameter_value $emif "DIAG_EXPORT_SEQ_AVALON_SLAVE"] == "CAL_DEBUG_EXPORT_MODE_EXPORT"} {
            add_interface cal_debug_clk clock sink
            set_interface_property cal_debug_clk export_of "${emif}.cal_debug_clk"

            add_interface cal_debug_reset_n reset sink
            set_interface_property cal_debug_reset_n export_of "${emif}.cal_debug_reset_n"
         }

         if {[get_instance_parameter_value $emif "DIAG_EXPORT_SEQ_AVALON_SLAVE"] == "CAL_DEBUG_EXPORT_MODE_EXPORT"} {
            add_interface cal_debug avalon end
            set_interface_property cal_debug export_of "${emif}.cal_debug"
         }
         if {[get_instance_parameter_value $emif "DIAG_EXPORT_VJI"]} {
            add_interface vji conduit end
            set_interface_property vji export_of "${emif}.vji"
         }

         if {[get_instance_parameter_value $emif "DIAG_EXPORT_SEQ_AVALON_SLAVE"] != "CAL_DEBUG_EXPORT_MODE_DISABLED"} {
            set_instance_parameter_value $emif "DIAG_${protocol}_INTERFACE_ID" $main_interface_id
         }

         set_instance_parameter_value $emif "DIAG_${protocol}_EXPORT_SEQ_AVALON_HEAD_OF_CHAIN" "true"

      } else {
         if {[get_instance_parameter_value $emif "DIAG_EXPORT_SEQ_AVALON_SLAVE"] != "CAL_DEBUG_EXPORT_MODE_DISABLED"} {
            set_instance_parameter_value $emif "DIAG_${protocol}_EXPORT_SEQ_AVALON_SLAVE" "CAL_DEBUG_EXPORT_MODE_EXPORT"
            set_instance_parameter_value $emif "DIAG_${protocol}_EXPORT_SEQ_AVALON_MASTER" true
         }
         if {[get_instance_parameter_value $emif "DIAG_EXPORT_VJI"]} {
            set_instance_parameter_value $emif "DIAG_EXPORT_VJI" "false"
         }

         if {[get_instance_parameter_value $emif "DIAG_EXPORT_SEQ_AVALON_SLAVE"] != "CAL_DEBUG_EXPORT_MODE_DISABLED"} {
            set_instance_parameter_value $emif "DIAG_${protocol}_INTERFACE_ID" $curr_interface_id
            set curr_interface_id [expr {($curr_interface_id + 1) % $invalid_interface_id}]
         }

         if {[get_instance_parameter_value $emif "DIAG_ENABLE_JTAG_UART"]} {
            set_instance_parameter_value $emif "DIAG_ENABLE_JTAG_UART" "false"
         }

         if {[get_instance_parameter_value $emif "DIAG_SOFT_NIOS_MODE"] != "SOFT_NIOS_MODE_DISABLED"} {
            set_instance_parameter_value $emif "DIAG_SOFT_NIOS_MODE" "SOFT_NIOS_MODE_DISABLED"
         }

         set_instance_parameter_value $emif "DIAG_${protocol}_EXPORT_SEQ_AVALON_HEAD_OF_CHAIN" "false"
      }

      incr emif_index
   }


   if {$design_type == "sim"} {

      set ref_clk_freq_mhz  [get_instance_parameter_value $main_emif "PHY_${protocol}_REF_CLK_FREQ_MHZ"]

      set clock_src "pll_ref_clk_source"
      add_instance $clock_src altera_avalon_clock_source
      set_instance_parameter_value $clock_src CLOCK_RATE [expr {round($ref_clk_freq_mhz * 1000000.0)}]
      set_instance_parameter_value $clock_src CLOCK_UNIT 1

      if {$has_global_reset} {
         set global_reset_n_src "global_reset_n_source"
         add_instance $global_reset_n_src altera_avalon_reset_source
         set_instance_parameter_value $global_reset_n_src ASSERT_HIGH_RESET 0
         set_instance_parameter_value $global_reset_n_src INITIAL_RESET_CYCLES 5

         add_connection ${clock_src}.clk ${global_reset_n_src}.clk
         add_connection ${global_reset_n_src}.reset ${grst_splitter}.sig_input_if
      }
      
      if {$has_local_reset} {
         set local_reset_src "local_reset_source"
         add_instance $local_reset_src altera_emif_local_reset_sim_source
         
         add_connection ${local_reset_src}.local_reset_req ${lrst_combiner}.local_reset_req
         add_connection ${lrst_combiner}.local_reset_status ${local_reset_src}.local_reset_status
      }

      foreach emif $emifs {
         if {$emif == $main_emif} {
            if {[get_instance_parameter_value $emif "DIAG_EXPORT_SEQ_AVALON_SLAVE"] == "CAL_DEBUG_EXPORT_MODE_EXPORT"} {
               set cal_debug_clk_src "cal_debug_clk_source"
               add_instance $cal_debug_clk_src altera_avalon_clock_source
               set_instance_parameter_value $cal_debug_clk_src CLOCK_RATE [expr {round($ref_clk_freq_mhz * 1000000.0)}]
               set_instance_parameter_value $cal_debug_clk_src CLOCK_UNIT 1

               set cal_debug_reset_n_src "cal_debug_reset_n_source"
               add_instance $cal_debug_reset_n_src altera_avalon_reset_source
               set_instance_parameter_value $cal_debug_reset_n_src ASSERT_HIGH_RESET 0
               set_instance_parameter_value $cal_debug_reset_n_src INITIAL_RESET_CYCLES 5

               add_connection ${cal_debug_clk_src}.clk ${cal_debug_reset_n_src}.clk
               add_connection ${cal_debug_reset_n_src}.reset ${emif}.cal_debug_reset_n
               add_connection ${cal_debug_clk_src}.clk ${emif}.cal_debug_clk

               set cal_debug_bfm "cal_debug_bfm"
               add_instance $cal_debug_bfm altera_avalon_mm_master_bfm
               add_connection ${cal_debug_clk_src}.clk ${cal_debug_bfm}.clk
               add_connection ${cal_debug_reset_n_src}.reset ${cal_debug_bfm}.clk_reset
               add_connection ${cal_debug_bfm}.m0 ${emif}.cal_debug
            }
         }
         if {$cal_oct} {
            remove_interface ${emif}_oct
         }
      }
      
      if {$has_local_reset} {
         remove_interface local_reset_req
      }

      foreach emif $emifs mem $mems sharing_enum $sharing_enums tg $tgs tg_cfg_bfm $tg_cfg_bfms {

         set_validation_property AUTOMATIC_VALIDATION false

         add_instance $mem altera_emif_mem_model

         set_instance_parameter_values $mem $ip_param_lst

         set board "${mem}_board"
         if {[get_instance_parameter_value $emif "DIAG_USE_BOARD_DELAY_MODEL"]} {
            add_instance $board altera_emif_board_delay_model
            set_instance_parameter_values $board $ip_param_lst
         }

         validate_system
         set_validation_property AUTOMATIC_VALIDATION true

         if {[get_instance_parameter_value $emif "DIAG_USE_BOARD_DELAY_MODEL"]} {
            add_connection ${emif}.mem ${board}.mem_0
            add_connection ${board}.mem_1 ${mem}.mem
         } else {
            add_connection ${emif}.mem ${mem}.mem
         }

         if {$sharing_enum != "CORE_CLKS_SHARING_SLAVE"} {
            add_connection ${clock_src}.clk ${emif}.pll_ref_clk
         }

      }

      add_instance sim_checker altera_emif_sim_checker
      set_instance_parameter_value sim_checker NUM_OF_TG_IFS $num_tg_status_ifs
      set_instance_parameter_value sim_checker NUM_OF_EMIF_IFS [llength $emifs]
      set_instance_parameter_value sim_checker SKIP_TG [get_instance_parameter_value $main_emif "DIAG_SIM_CHECKER_SKIP_TG"]

      set tg_status_if_i 0
      foreach tg $tgs {
         foreach if [get_instance_interfaces $tg] {
            if {[string first "tg_status" $if] == 0} {
               add_connection ${tg}.${if} sim_checker.tg_status_${tg_status_if_i}
               incr tg_status_if_i
            }
         }
      }
      set emif_if_i 0
      foreach emif $emifs {
         foreach if [get_instance_interfaces $emif] {
            if {[string first "status" $if] == 0} {
               add_connection ${emif}.${if} sim_checker.status_${emif_if_i}
               incr emif_if_i
            }
         }
      }

      add_interface sim_checker conduit end
      set_interface_property sim_checker EXPORT_OF sim_checker.tg_status
      add_interface cal_status_checker conduit end
      set_interface_property cal_status_checker EXPORT_OF sim_checker.status
   }
}

proc add_extra_ifs {design_type} {
   upvar ip_params ip_params
   upvar ed_params ed_params
   upvar ip_param_lst ip_param_lst
   upvar family_traits family_traits

   set dft_if              $family_traits(DFT_IF)
   set has_global_reset    $family_traits(HAS_GLOBAL_RESET)
   set has_local_reset     $family_traits(HAS_LOCAL_RESET)
   
   set emif_module         $ed_params(EMIF_MODULE_NAME)
   set use_tg_avl_2        [expr {$ip_params(DIAG_USE_TG_AVL_2) && ($ip_params(PHY_CONFIG_ENUM) != "CONFIG_PHY_ONLY")}]

   set protocols  [list]
   set emifs      [list]
   set tgs        [list]
   set mems       [list]
   set clks       [list]
   
   foreach item [split $ip_params(DIAG_EX_DESIGN_ADD_TEST_EMIFS) ",; "] {
      set tmp [split $item "="]
      set protocol_enum [lindex $tmp 0]
      set num_of_ifs [lindex $tmp 1]

      if {$protocol_enum == "PROTOCOL_ALL"} {
         foreach protocol_enum $ed_params(SUPPORTED_PROTOCOL_ENUMS) {
            if {[llength [array get num_of_ifs_per_protocol $protocol_enum]] == 0} {
               set num_of_ifs_per_protocol($protocol_enum) $num_of_ifs
            }
         }
      } else {
         set num_of_ifs_per_protocol($protocol_enum) $num_of_ifs
      }
   }

   foreach protocol_enum [array names num_of_ifs_per_protocol] {
      if {$protocol_enum != $ip_params(PROTOCOL_ENUM)} {
         set num_of_ifs $num_of_ifs_per_protocol($protocol_enum)
         set protocol [string tolower [lindex [split $protocol_enum "_"] 1]]

         for {set i 0} {$i < $num_of_ifs} {incr i} {
            lappend protocols  $protocol
            lappend emifs      "test_${protocol}_${i}_emif"
            lappend tgs        "test_${protocol}_${i}_tg"
            lappend mems       "test_${protocol}_${i}_mem"
            lappend clks       "test_${protocol}_${i}_pll_ref_clk"
         }
      }
   }

   if {$has_global_reset} {
      set use_separate_resets [expr {$ip_params(DIAG_EX_DESIGN_SEPARATE_RESETS) ? 1 : 0}]
      if {!$use_separate_resets} {
         set emif_index [get_instance_parameter_value global_reset_n_splitter NUM_OF_FANOUTS]
         set num_of_ifs [llength $emifs]
         incr num_of_ifs $emif_index
         set_instance_parameter_value global_reset_n_splitter NUM_OF_FANOUTS $num_of_ifs   
      }
   }
   
   if {$has_local_reset} {
      set num_of_reset_req_ifs    [get_instance_parameter_value local_reset_combiner NUM_OF_RESET_REQ_IFS]
      set num_of_reset_status_ifs [get_instance_parameter_value local_reset_combiner NUM_OF_RESET_STATUS_IFS]

      set master_emif_index $num_of_reset_req_ifs
      set all_emif_index $num_of_reset_status_ifs
      incr num_of_reset_req_ifs    [llength $emifs]
      incr num_of_reset_status_ifs [llength $emifs]
      
      set_instance_parameter_value local_reset_combiner NUM_OF_RESET_REQ_IFS $num_of_reset_req_ifs   
      set_instance_parameter_value local_reset_combiner NUM_OF_RESET_STATUS_IFS $num_of_reset_status_ifs   
   }
   

   foreach protocol $protocols emif $emifs tg $tgs {
      set protocol_enum "PROTOCOL_[string toupper $protocol]"
      
      set tmp "PHY_[string toupper $protocol]_CONFIG_ENUM"
      set config_enum $ip_params($tmp)

      set_validation_property AUTOMATIC_VALIDATION false

      add_instance $emif $emif_module
      
      if {$config_enum == "CONFIG_PHY_ONLY"} {
         add_instance $tg altera_emif_tg_afi_[string tolower $protocol]
      } elseif {$use_tg_avl_2} {
         add_instance $tg altera_emif_tg_avl_2
      } else {
         add_instance $tg altera_emif_tg_avl
      }
      
      set_instance_parameter_value $emif PROTOCOL_ENUM $protocol_enum
      foreach param_name [array names ip_params] {
         if {$param_name != "PROTOCOL_ENUM"} {
            set param_val $ip_params($param_name)
            
            if {$param_name == "DIAG_ENABLE_JTAG_UART" && $ip_params($param_name)} {
               set param_val "false"
            }
            if {$param_name == "DIAG_SOFT_NIOS_MODE" && $ip_params($param_name) != "SOFT_NIOS_MODE_DISABLED"} {
               set param_val "SOFT_NIOS_MODE_DISABLED"
            }
            set_instance_parameter_value $emif $param_name $param_val
         }
      }
      
      validate_system
      foreach param_name [get_instance_parameters $emif] {
         set param_val [get_instance_parameter_value $emif $param_name]
         set_instance_parameter_value $tg $param_name $param_val
      }      
   
      if {$use_tg_avl_2} {
         set tg_cfg_amm_export_mode [get_instance_parameter_value $inst DIAG_EXPORT_TG_CFG_AVALON_SLAVE]
         set_instance_parameter_value $tg DIAG_EXPORT_TG_CFG_AVALON_SLAVE $tg_cfg_amm_export_mode
         if {$tg_cfg_amm_export_mode == "TG_CFG_AMM_EXPORT_MODE_EXPORT"} {
            set tg_cfg_interface tg_cfg
            add_interface $tg_cfg_interface avalon slave
            set_interface_property $tg_cfg_interface EXPORT_OF $tg.tg_cfg_0
         } 
      }

      validate_system
      set_validation_property AUTOMATIC_VALIDATION true

      if {$has_global_reset} {
         if {$use_separate_resets} {
            add_interface ${emif}_global_reset_n conduit end
            set_interface_property ${emif}_global_reset_n EXPORT_OF ${emif}.global_reset_n
         } else {
            add_connection global_reset_n_splitter.sig_output_if_${emif_index} ${emif}.global_reset_n
            incr emif_index
         }
      }
      
      if {$has_local_reset} {
         add_connection local_reset_combiner.local_reset_req_out_${master_emif_index} ${emif}.local_reset_req
         incr master_emif_index
         
         add_connection ${emif}.local_reset_status local_reset_combiner.local_reset_status_in_${all_emif_index} 
         incr all_emif_index
      }
   }

   set num_tg_status_ifs 0

   foreach emif $emifs tg $tgs {

      add_interface ${emif}_pll_ref_clk clock end
      set_interface_property ${emif}_pll_ref_clk EXPORT_OF ${emif}.pll_ref_clk

      add_interface ${emif}_mem conduit end
      set_interface_property ${emif}_mem EXPORT_OF ${emif}.mem

      add_interface ${emif}_status conduit end
      set_interface_property ${emif}_status EXPORT_OF ${emif}.status

      set cal_oct [get_instance_parameter_value $emif PHY_CALIBRATED_OCT]
      if {$cal_oct} {
         add_interface ${emif}_oct conduit end
         set_interface_property ${emif}_oct EXPORT_OF ${emif}.oct
      }

      set config_enum [get_instance_parameter_value $emif PHY_${protocol}_CONFIG_ENUM]
      set ping_pong_en [get_instance_parameter_value $emif PHY_PING_PONG_EN]
      if {$config_enum == "CONFIG_PHY_ONLY"} {
         add_connection ${emif}.afi_reset_n ${tg}.afi_reset_n
         add_connection ${emif}.afi_clk ${tg}.afi_clk
         add_connection ${emif}.afi_half_clk ${tg}.afi_half_clk
      } else {
         add_connection ${emif}.emif_usr_reset_n ${tg}.emif_usr_reset_n
         add_connection ${emif}.emif_usr_clk ${tg}.emif_usr_clk

         if {$ping_pong_en} {
            add_connection ${emif}.emif_usr_reset_n_sec ${tg}.emif_usr_reset_n_sec
            add_connection ${emif}.emif_usr_clk_sec ${tg}.emif_usr_clk_sec
         }
      }

      set tg_conns 0

      foreach if [get_instance_interfaces $emif] {
         if {[string first "ctrl_amm" $if] == 0} {
            add_connection ${tg}.${if} ${emif}.${if}
            incr tg_conns
         }

         if {[string first "ctrl_auto_precharge" $if] == 0 ||
             [string first "ctrl_user_priority" $if] == 0 ||
             [string first "ctrl_ecc_user_interrupt" $if] == 0 ||
             [string first "ctrl_ecc_readdataerror" $if] == 0} {

            add_connection ${tg}.${if} ${emif}.${if}

         } elseif {[string first "ctrl_mmr_slave" $if] == 0} {
            set from_if [string map {slave master} $if]
            add_connection ${tg}.${from_if} ${emif}.${if}
         }

         if {[string first "afi" $if] == 0} {
            add_connection ${emif}.${if} ${tg}.${if}
            incr tg_conns
         }
      }

      if {$tg_conns <= 0} {
         puts stderr "Error: Unable to connect example traffic generator to memory interface."
         exit
      }

      set tg_status_if_i 0

      foreach if [get_instance_interfaces $tg] {
         if {[string first "tg_status" $if] == 0} {
            set ifname "${emif}_tg_${tg_status_if_i}"
            add_interface $ifname conduit end
            set_interface_property $ifname EXPORT_OF ${tg}.${if}
            incr tg_status_if_i
            incr num_tg_status_ifs
         }
      }

      if {$tg_status_if_i <= 0} {
         puts stderr "Error: Unable to export example traffic generator status interface."
         exit
      }
   }

   if {$design_type == "sim"} {
      foreach protocol $protocols emif $emifs mem $mems clk $clks {

         set ref_clk_freq_mhz  [get_instance_parameter_value $emif "PHY_${protocol}_REF_CLK_FREQ_MHZ"]

         set_validation_property AUTOMATIC_VALIDATION false

         set clock_src "${clk}_source"
         add_instance $clock_src altera_avalon_clock_source
         set_instance_parameter_value $clock_src CLOCK_RATE [expr {round($ref_clk_freq_mhz * 1000000.0)}]
         set_instance_parameter_value $clock_src CLOCK_UNIT 1

         add_instance $mem altera_emif_mem_model
         foreach param_name [get_instance_parameters $emif] {
            set param_val [get_instance_parameter_value $emif $param_name]
            set_instance_parameter_value $mem $param_name $param_val
         }
         
         if {$has_global_reset} {
            if {$use_separate_resets} {
               set global_reset_n_src "global_reset_n_source_$emif"
               add_instance $global_reset_n_src altera_avalon_reset_source
               set_instance_parameter_value $global_reset_n_src ASSERT_HIGH_RESET 0
               set_instance_parameter_value $global_reset_n_src INITIAL_RESET_CYCLES 5
            }
         }

         validate_system
         set_validation_property AUTOMATIC_VALIDATION true

         add_connection ${emif}.mem ${mem}.mem

         add_connection ${clock_src}.clk ${emif}.pll_ref_clk
         
         if {$has_global_reset} {
            if {$use_separate_resets} {
               add_connection ${clock_src}.clk ${global_reset_n_src}.clk
               add_connection ${global_reset_n_src}.reset ${emif}.global_reset_n
            }
         }

         set cal_oct [get_instance_parameter_value $emif PHY_CALIBRATED_OCT]
         if {$cal_oct} {
            remove_interface ${emif}_oct
         }
      }

      set orig_num_cal_status_ifs [get_instance_parameter_value sim_checker NUM_OF_EMIF_IFS]
      set orig_num_tg_status_ifs [get_instance_parameter_value sim_checker NUM_OF_TG_IFS]
      set num_cal_status_ifs [expr {$orig_num_cal_status_ifs + [llength $emifs]}]
      incr num_tg_status_ifs $orig_num_tg_status_ifs
      set_instance_parameter_value sim_checker NUM_OF_TG_IFS $num_tg_status_ifs
      set_instance_parameter_value sim_checker NUM_OF_EMIF_IFS $num_cal_status_ifs
      
      set tg_status_if_i $orig_num_tg_status_ifs
      foreach tg $tgs {
         foreach if [get_instance_interfaces $tg] {
            if {[string first "tg_status" $if] == 0} {
               add_connection ${tg}.${if} sim_checker.tg_status_${tg_status_if_i}
               incr tg_status_if_i
            }
         }
      }
      set emif_if_i $orig_num_cal_status_ifs
      foreach emif $emifs {
         foreach if [get_instance_interfaces $emif] {
            if {[string first "status" $if] == 0} {
               add_connection ${emif}.${if} sim_checker.status_${emif_if_i}
               incr emif_if_i
            }
         }
      }
   }
}


create_system
set_design_id $ed_params(SYSTEM_CONSOLE_DESIGN_ID) 
gen_sys "synth"
add_extra_ifs "synth"
save_system $ed_params(TMP_SYNTH_QSYS_PATH)

create_system
gen_sys "sim"
add_extra_ifs "sim"
save_system $ed_params(TMP_SIM_QSYS_PATH)

sync_sysinfo_parameters

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
set NUM_IPS        $ed_params(NUM_IPS)
set NUM_IPS_WO_HPS $ed_params(NUM_IPS)
set num_conn_to_calip(0) 0
set num_conn_to_calip(1) 0
set hps_emif_id          $NUM_IPS
set first_emif_id_conn_to_calip(0) -1
set first_emif_id_conn_to_calip(1) -1
for {set id 0} {$id < $NUM_IPS} {incr id} {
    if {$ed_params(EMIF_${id}_CONN_TO_CALIP)==0} {
        if {$num_conn_to_calip(0)==0} {
            set first_emif_id_conn_to_calip(0) $id
        }
        incr num_conn_to_calip(0) 
    }
    if {$ed_params(EMIF_${id}_CONN_TO_CALIP)==1} { 
        if {$num_conn_to_calip(1)==0} {
            set first_emif_id_conn_to_calip(1) $id
        }
        incr num_conn_to_calip(1) 
    }
    set ip_param_lst($id) [list]
    
    if {[string first hps $ip_params(EMIF_${id}_TYPE)] >= 0} {
        set hps_emif_id $id
        set NUM_IPS_WO_HPS [expr $NUM_IPS -1]
    }
    set process_params($id) 0
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

proc gen_sys {design_type {wb_params_file 0} } {
    upvar ip_params ip_params
    upvar ed_params ed_params
    upvar ip_param_lst ip_param_lst
    upvar family_traits family_traits
    upvar num_conn_to_calip num_conn_to_calip
    upvar first_emif_id_conn_to_calip first_emif_id_conn_to_calip
    upvar NUM_IPS_WO_HPS NUM_IPS_WO_HPS
    upvar NUM_IPS        NUM_IPS
    upvar hps_emif_id    hps_emif_id
    upvar process_params process_params

    set dft_if              $family_traits(DFT_IF)

    set cal_param_names  [list DIAG_SIM_CAL_MODE_ENUM       \
                               DIAG_EXTRA_CONFIGS           \
                               DIAG_EXPORT_VJI              \
                               DIAG_SYNTH_FOR_SIM           \
                               SHORT_QSYS_INTERFACE_NAMES   \
                               DIAG_EXPORT_SEQ_AVALON_SLAVE \
                               DIAG_ENABLE_JTAG_UART        ]

    set_project_property DEVICE_FAMILY $ip_params(SYS_INFO_DEVICE_FAMILY)
    set_project_property DEVICE        $ed_params(DEFAULT_DEVICE)

    set_validation_property AUTOMATIC_VALIDATION false

        
    set cal0_next_free_if 0
    set cal1_next_free_if 0
    for {set id 0} {$id < $NUM_IPS && $ed_params(GUI)==0} {incr id} {
        set protocol_enum       $ip_params(EMIF_${id}_PROTOCOL_ENUM)
        set protocol            [lindex [split $protocol_enum "_"] 1]

        set emif emif_fm_$id

        add_component $emif "ip/ed_${design_type}/ed_${design_type}_${emif}.ip" $ip_params(EMIF_${id}_TYPE)
        load_component $emif
        if {$ip_params(EMIF_${id}_PRESET) != ""} {
            apply_component_preset $ip_params(EMIF_${id}_PRESET)
        }

        foreach param_name_wp [array names ip_params "EMIF_${id}_*"] {
            set param_name [string map [list "EMIF_${id}_" ""] $param_name_wp]
            if {$param_name == "PRESET" ||  $param_name == "TYPE"} {continue}
            set_component_parameter_value $param_name $ip_params($param_name_wp)
        }

        set_component_parameter_value DIAG_EXPORT_PLL_REF_CLK_OUT true
        set_component_parameter_value DIAG_EXPORT_PLL_LOCKED true
        set_component_parameter_value "PHY_${protocol}_CORE_CLKS_SHARING_ENUM"             CORE_CLKS_SHARING_DISABLED
        set_component_parameter_value "PHY_${protocol}_CORE_CLKS_SHARING_EXPOSE_SLAVE_OUT" 0

        if {$ed_params(EMIF_${id}_CONN_TO_CALIP) == 0} { 
            set_component_parameter_value "DIAG_${protocol}_INTERFACE_ID" $cal0_next_free_if
            incr cal0_next_free_if
        } else {
            set_component_parameter_value "DIAG_${protocol}_INTERFACE_ID" $cal1_next_free_if
            incr cal1_next_free_if
        }
        set_component_parameter_value "NUM_IPS" 1
        save_component

        if {$process_params($id) == 0} {
            set process_params($id) 1
            load_component $emif
            set expanded_params_fh [open "params.tcl" a+]
            foreach param_name [get_component_parameters] {
                set param_name_wp "EMIF_${id}_$param_name"
                if {[info exists ip_params($param_name_wp)]} {
                } else {
                    if {[string first "CONN_TO_CALIP" $param_name] != -1  || [string first "REF_CLK_SHARING" $param_name] != -1  || [string first "STORED_PARAM" $param_name] != -1} {continue}
                    set ip_params($param_name_wp)  [get_component_parameter_value $param_name]
                }
                if {$wb_params_file} {puts $expanded_params_fh "set ip_params($param_name_wp) \"$ip_params($param_name_wp)\""}
                lappend ip_param_lst($id) $param_name
                lappend ip_param_lst($id) $ip_params($param_name_wp)
                if {$id==0 && $wb_params_file} {
                    puts $expanded_params_fh "set ip_params($param_name) \"$ip_params($param_name_wp)\""
                }
            }
            close $expanded_params_fh
            save_component
        }
    }

    for {set id 0} {$id < $NUM_IPS && $ed_params(GUI)==1} {incr id} {
        set protocol_enum       $ip_params(EMIF_${id}_PROTOCOL_ENUM)
        set protocol            [lindex [split $protocol_enum "_"] 1]
        set emif emif_fm_$id

        add_instance $emif $ip_params(EMIF_${id}_TYPE)
        foreach param_name_wp [array names ip_params "EMIF_${id}_*"] {
            set param_name [string map [list "EMIF_${id}_" ""] $param_name_wp]
            if {$param_name == "PRESET" ||  $param_name == "TYPE"} {continue}
            lappend ip_param_lst($id) $param_name
            lappend ip_param_lst($id) $ip_params($param_name_wp)
        }
        set_instance_parameter_values $emif $ip_param_lst($id)
        set_instance_parameter_value  $emif NUM_IPS                              1
        set_instance_parameter_value  $emif DIAG_EXPORT_PLL_REF_CLK_OUT          true
        set_instance_parameter_value  $emif DIAG_EXPORT_PLL_LOCKED               true
        set_instance_parameter_value  $emif "PHY_${protocol}_CORE_CLKS_SHARING_ENUM"             CORE_CLKS_SHARING_DISABLED
        set_instance_parameter_value  $emif "PHY_${protocol}_CORE_CLKS_SHARING_EXPOSE_SLAVE_OUT" 0

        if {$ed_params(EMIF_${id}_CONN_TO_CALIP) == 0} { 
            set_instance_parameter_value  $emif "DIAG_${protocol}_INTERFACE_ID" $cal0_next_free_if
            incr cal0_next_free_if
        } else {
            set_instance_parameter_value  $emif "DIAG_${protocol}_INTERFACE_ID" $cal1_next_free_if
            incr cal1_next_free_if
        }
    }

    set id 0
    set cal0_next_free_if 0
    set cal1_next_free_if 0
    for {set calip 0} {$calip < 2} {incr calip} {
        if {$num_conn_to_calip($calip)} {
            set emif_cal_wrapper "emif_cal_$calip"
            add_instance $emif_cal_wrapper altera_emif_cal
            set_instance_parameter_value $emif_cal_wrapper NUM_CALBUS_INTERFACE $num_conn_to_calip($calip)
            foreach param_name $cal_param_names {
                set_instance_parameter_value $emif_cal_wrapper $param_name $ip_params(EMIF_${id}_$param_name)
            }
            add_interface calbus_clk clock sink
            set_interface_property calbus_clk EXPORT_OF ${emif_cal_wrapper}.emif_calbus_clk
        }
    }

    for {set id 0} {$id < $NUM_IPS} {incr id} {
        set emif           emif_fm_$id
        set config_enum    $ip_params(EMIF_${id}_PHY_CONFIG_ENUM)
        if {$ed_params(EMIF_${id}_CONN_TO_CALIP) == 0} { 
            set calbus_if emif_calbus_$cal0_next_free_if
            set emif_cal_wrapper "emif_cal_0"
            incr cal0_next_free_if
        } else {
            set calbus_if emif_calbus_$cal1_next_free_if
            set emif_cal_wrapper "emif_cal_1"
            incr cal1_next_free_if
        }
        if {$id == $hps_emif_id} {
            add_interface  ${emif}_hps_emif             conduit end  ; set_interface_property  ${emif}_hps_emif                    EXPORT_OF  ${emif}.hps_emif
        }
        add_connection ${emif_cal_wrapper}.emif_calbus_clk ${emif}.emif_calbus_clk
        add_connection ${emif_cal_wrapper}.${calbus_if} ${emif}.emif_calbus

        if {$config_enum == "CONFIG_PHY_ONLY" ||
            [get_instance_parameter_value  ${emif_cal_wrapper}  "DIAG_EXPORT_SEQ_AVALON_SLAVE"] == "CAL_DEBUG_EXPORT_MODE_EXPORT"} {
            add_interface cal_debug_clk clock sink
            set_interface_property cal_debug_clk EXPORT_OF "${emif}.cal_debug_clk"

            add_interface cal_debug_reset_n reset sink
            set_interface_property cal_debug_reset_n EXPORT_OF "${emif}.cal_debug_reset_n"
        }

        if {[get_instance_parameter_value  ${emif_cal_wrapper}  "DIAG_EXPORT_SEQ_AVALON_SLAVE"] == "CAL_DEBUG_EXPORT_MODE_EXPORT"} {
            add_interface cal_debug avalon end
            set_interface_property cal_debug EXPORT_OF "${emif}.cal_debug"
        }
        if {[get_instance_parameter_value ${emif_cal_wrapper} "DIAG_EXPORT_VJI"]} {
            add_interface vji conduit end
            set_interface_property vji EXPORT_OF "${emif}.vji"
        }


        
        if {$ed_params(EMIF_${id}_REF_CLK_SHARING) != "EXPORTED"} {
            set src_emif $ed_params(EMIF_${id}_REF_CLK_SHARING)
            add_connection emif_fm_$src_emif.pll_ref_clk_out ${emif}.pll_ref_clk

            if {$ed_params(EMIF_${src_emif}_REF_CLK_SHARING) != "EXPORTED"} {
                puts stderr "Error: make_qsys.tcl ref_clk for EMIF $id is sourced from EMIF $src_emif. But ref_clk for EMIF $src_emif is not exported."
                exit
            }
        }

    }

    for {set calip 0} {$calip < 2} {incr calip} {
        if {$num_conn_to_calip($calip)} {
            set emif             "emif_fm_$first_emif_id_conn_to_calip($calip)"
            set emif_cal_wrapper "emif_cal_$calip"
            set first_emif_id    $first_emif_id_conn_to_calip($calip)
            set config_enum      $ip_params(EMIF_${first_emif_id}_PHY_CONFIG_ENUM)

            if {[get_instance_parameter_value ${emif_cal_wrapper} DIAG_EXPORT_SEQ_AVALON_SLAVE] != "CAL_DEBUG_EXPORT_MODE_DISABLED"} {
                if {$design_type == "synth_bcm"} {
                    add_interface  ${emif_cal_wrapper}.cal_debug_clk      clock sink ; set_interface_property ${emif_cal_wrapper}_cal_debug_clk     EXPORT_OF    ${emif_cal_wrapper}.cal_debug_clk    
                    add_interface  ${emif_cal_wrapper}.cal_debug_reset_n  reset sink ; set_interface_property ${emif_cal_wrapper}_cal_debug_reset_n EXPORT_OF    ${emif_cal_wrapper}.cal_debug_reset_n
                } else {
                   if {$config_enum == "CONFIG_PHY_ONLY"} {
                      add_connection ${emif}.afi_clk       ${emif_cal_wrapper}.cal_debug_clk
                      add_connection ${emif}.afi_reset_n   ${emif_cal_wrapper}.cal_debug_reset_n
                   } else {
                      add_connection ${emif}.emif_usr_clk       ${emif_cal_wrapper}.cal_debug_clk
                      add_connection ${emif}.emif_usr_reset_n   ${emif_cal_wrapper}.cal_debug_reset_n
                   }
                }

            } elseif {[get_instance_parameter_value ${emif_cal_wrapper} DIAG_EXPORT_SEQ_AVALON_SLAVE] == "CAL_DEBUG_EXPORT_MODE_EXPORT"} {
                add_interface          cal_debug avalon slave
                set_interface_property cal_debug         EXPORT_OF ${emif_cal_wrapper}.cal_debug
                add_interface          cal_debug_clk clock sink
                set_interface_property cal_debug_clk     EXPORT_OF ${emif_cal_wrapper}.cal_debug_clk
                add_interface          cal_debug_reset_n reset sink
                set_interface_property cal_debug_reset_n EXPORT_OF ${emif_cal_wrapper}.cal_debug_reset_n
            }
        }
    }
    
    if {$design_type == "synth_bcm"} { 
        for {set id 0} {$id < $NUM_IPS} {incr id} {
            set emif emif_fm_$id
            if {$ed_params(EMIF_${id}_REF_CLK_SHARING) == "EXPORTED"} {
                add_interface  ${emif}_pll_ref_clk              clock end    ; set_interface_property  ${emif}_pll_ref_clk                 EXPORT_OF  ${emif}.pll_ref_clk
            }
            add_interface  ${emif}_mem                      conduit end  ; set_interface_property  ${emif}_mem                         EXPORT_OF  ${emif}.mem
            foreach intf [get_instance_interfaces $emif] {
                if {[string first "ctrl_ecc_user_interrupt" $intf] == 0 ||
                    [string first "oct" $intf] == 0 } {
                    add_interface  ${emif}_$intf  conduit end  ; set_interface_property  ${emif}_$intf     EXPORT_OF  ${emif}.$intf
                }
            }
            if {$id == $hps_emif_id} {
                continue
            }
            add_interface  ${emif}_local_reset_req          conduit end  ; set_interface_property  ${emif}_local_reset_req             EXPORT_OF  ${emif}.local_reset_req         
            add_interface  ${emif}_local_reset_status       conduit end  ; set_interface_property  ${emif}_local_reset_status          EXPORT_OF  ${emif}.local_reset_status      
            add_interface  ${emif}_pll_ref_clk_out          clock source ; set_interface_property  ${emif}_pll_ref_clk_out             EXPORT_OF  ${emif}.pll_ref_clk_out         
            add_interface  ${emif}_pll_locked               conduit end  ; set_interface_property  ${emif}_pll_locked                  EXPORT_OF  ${emif}.pll_locked              
            add_interface  ${emif}_emif_usr_clk             clock source ; set_interface_property  ${emif}_emif_usr_clk                EXPORT_OF  ${emif}.emif_usr_clk            
            add_interface  ${emif}_emif_usr_reset_n         reset sink   ; set_interface_property  ${emif}_emif_usr_reset_n            EXPORT_OF  ${emif}.emif_usr_reset_n        
            add_interface  ${emif}_ctrl_amm_0               avalon slave ; set_interface_property  ${emif}_ctrl_amm_0                  EXPORT_OF  ${emif}.ctrl_amm_0              
        }
        set_validation_property AUTOMATIC_VALIDATION true
        set qsys_messages [validate_system]
        foreach msg $qsys_messages {
            puts $msg
        }
        return
    }

    for {set id 0} {$id < $NUM_IPS} {incr id} {
        if {$id == $hps_emif_id} { continue }
        set protocol_enum       $ip_params(EMIF_${id}_PROTOCOL_ENUM)
        set protocol            [lindex [split $protocol_enum "_"] 1]

        set emif emif_fm_$id
        set tg   tg_$id

        set config_enum         $ip_params(EMIF_${id}_PHY_CONFIG_ENUM)
        set use_tg_avl_2        [expr {$ip_params(EMIF_${id}_DIAG_USE_TG_AVL_2) && ($ip_params(EMIF_${id}_PHY_CONFIG_ENUM) != "CONFIG_PHY_ONLY")}]

        if {$config_enum == "CONFIG_PHY_ONLY"} {
            set tg_type altera_emif_tg_afi_[string tolower $protocol]
        } elseif {$use_tg_avl_2} {
            set tg_type altera_emif_tg_avl_2
        } else {
            set tg_type altera_emif_tg_avl
        }

        set search_idx [lsearch $ip_param_lst($id) "AUTO_BOARD"]
        if {$search_idx >= 0} {
            set ip_param_lst($id) [lreplace $ip_param_lst($id) $search_idx [expr $search_idx+1]]
        }

        add_instance $tg $tg_type
        set_instance_parameter_values $tg $ip_param_lst($id)
        if {$design_type == "sim"} {
            set prev_val [get_instance_parameter_value $tg "DIAG_EXTRA_CONFIGS"]
            set new_val "$prev_val ; TG_TEST_DURATION=SHORT"
            set_instance_parameter_value $tg DIAG_EXTRA_CONFIGS $new_val
        }
        if {$use_tg_avl_2} {
            set tg_cfg_amm_export_mode [get_instance_parameter_value $tg DIAG_EXPORT_TG_CFG_AVALON_SLAVE]
            set_instance_parameter_value $tg DIAG_EXPORT_TG_CFG_AVALON_SLAVE $tg_cfg_amm_export_mode
            if {$tg_cfg_amm_export_mode == "TG_CFG_AMM_EXPORT_MODE_EXPORT"} {
                set tg_cfg_interface tg_cfg_$id
                add_interface $tg_cfg_interface avalon slave
                set_interface_property $tg_cfg_interface EXPORT_OF $tg.tg_cfg_0
            }
        }

    }


    set id 0

    set lrst_combiner "local_reset_combiner"
    add_instance $lrst_combiner altera_emif_local_reset_combiner
    set_instance_parameter_value $lrst_combiner NUM_OF_RESET_REQ_IFS    $NUM_IPS_WO_HPS
    set_instance_parameter_value $lrst_combiner NUM_OF_RESET_STATUS_IFS $NUM_IPS_WO_HPS
    
    set_instance_parameter_value $lrst_combiner EXPOSE_RESET_AS_CONDUIT true
    set_instance_parameter_value $lrst_combiner RESET_CONDUIT_ROLE pll_locked
    
    set ninit_done_if "ninit_done"
    add_instance $ninit_done_if altera_s10_user_rst_clkgate
    set_instance_parameter_value $ninit_done_if outputType "Reset Interface"
    
    for {set id 0} {$id < $NUM_IPS} {incr id} {
        set protocol_enum       $ip_params(EMIF_${id}_PROTOCOL_ENUM)
        set protocol            [lindex [split $protocol_enum "_"] 1]
        
        set emif emif_fm_$id
        set tg   tg_$id
        set calbus_if emif_calbus_$id

        set config_enum         $ip_params(EMIF_${id}_PHY_CONFIG_ENUM)
        set use_tg_avl_2        [expr {$ip_params(EMIF_${id}_DIAG_USE_TG_AVL_2) && ($ip_params(EMIF_${id}_PHY_CONFIG_ENUM) != "CONFIG_PHY_ONLY")}]

        if {$ed_params(EMIF_${id}_REF_CLK_SHARING) == "EXPORTED"} {
            add_interface ${emif}_pll_ref_clk clock end
            set_interface_property ${emif}_pll_ref_clk EXPORT_OF ${emif}.pll_ref_clk
        }

        add_interface ${emif}_mem conduit end
        set_interface_property ${emif}_mem EXPORT_OF ${emif}.mem

        if {$ip_params(EMIF_${id}_PHY_CALIBRATED_OCT) || $hps_emif_id == $id}  {
            add_interface ${emif}_oct conduit end
            set_interface_property ${emif}_oct EXPORT_OF ${emif}.oct
        }

        if {$hps_emif_id == $id} {
            continue
        }

        add_interface local_reset_req conduit end
        set_interface_property local_reset_req EXPORT_OF ${lrst_combiner}.local_reset_req
        set_interface_port_property local_reset_req local_reset_req_local_reset_req NAME local_reset_req
        
        add_interface local_reset_status conduit end
        set_interface_property local_reset_status EXPORT_OF ${lrst_combiner}.local_reset_status
        set_interface_port_property local_reset_status local_reset_status_local_reset_done NAME local_reset_done

        if {$ip_params(EMIF_${id}_DIAG_EXPOSE_DFT_SIGNALS)} {
            set if_name "${inst}_dft"
            add_interface $if_name conduit end
            set_interface_property $if_name EXPORT_OF ${inst}.${dft_if}
        }

        set id_alternative $id
        if {$id > $hps_emif_id} {
            incr id_alternative -1
        }

        add_connection ${lrst_combiner}.local_reset_req_out_${id_alternative} ${emif}.local_reset_req
        
        add_connection ${emif}.pll_ref_clk_out ${lrst_combiner}.generic_clk
        add_connection ${emif}.pll_locked      ${lrst_combiner}.generic_conduit_reset_n

        add_connection ${emif}.local_reset_status ${lrst_combiner}.local_reset_status_in_${id_alternative} 

        add_interface ${emif}_status conduit end
        set_interface_property ${emif}_status EXPORT_OF ${emif}.status


        if {$config_enum == "CONFIG_PHY_ONLY"} {
            add_connection ${emif}.afi_reset_n ${tg}.afi_reset_n
            add_connection ${emif}.afi_clk ${tg}.afi_clk
            add_connection ${emif}.afi_half_clk ${tg}.afi_half_clk
        } else {
            add_connection ${emif}.emif_usr_reset_n ${tg}.emif_usr_reset_n
            add_connection ${emif}.emif_usr_clk ${tg}.emif_usr_clk
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

            if {$if == "afi"} {
                add_connection ${emif}.${if} ${tg}.${if}
                incr tg_conns
            }
        }

        if {$tg_conns <= 0} {
            puts stderr "Error: Unable to connect example traffic generator to memory interface."
            exit
        }

        foreach if [get_instance_interfaces $tg] {
            if {[string first "tg_status" $if] == 0} {
                set ifname "${emif}_tg_status"
                add_interface $ifname conduit end
                set_interface_property $ifname EXPORT_OF ${tg}.${if}
            }
        }

        add_connection $ninit_done_if.$ninit_done_if $tg.$ninit_done_if 
    }

    set id 0

    if {$design_type == "synth"} {
        set_validation_property AUTOMATIC_VALIDATION true
        set qsys_messages [validate_system]
        foreach msg $qsys_messages {
            puts $msg
        }
        return
    }


    set local_reset_src "local_reset_source"
    add_instance $local_reset_src altera_emif_local_reset_sim_source
    add_connection ${local_reset_src}.local_reset_req ${lrst_combiner}.local_reset_req
    add_connection ${lrst_combiner}.local_reset_status ${local_reset_src}.local_reset_status

    add_instance sim_checker altera_emif_sim_checker
    set_instance_parameter_value sim_checker NUM_OF_TG_IFS     $NUM_IPS_WO_HPS
    set_instance_parameter_value sim_checker NUM_OF_EMIF_IFS   $NUM_IPS_WO_HPS
    set_instance_parameter_value sim_checker SKIP_TG           $ip_params(EMIF_${id}_DIAG_SIM_CHECKER_SKIP_TG)
    add_interface          sim_checker conduit end
    set_interface_property sim_checker EXPORT_OF sim_checker.tg_status
    add_interface          cal_status_checker conduit end
    set_interface_property cal_status_checker EXPORT_OF sim_checker.status

    for {set id 0} {$id < $NUM_IPS} {incr id} {
        set protocol_enum       $ip_params(EMIF_${id}_PROTOCOL_ENUM)
        set protocol            [lindex [split $protocol_enum "_"] 1]
        
        set emif      emif_fm_$id
        set tg        tg_$id
        set calbus_if emif_calbus_$id
        set mem        mem_$id


        add_instance $mem altera_emif_mem_model
        set_instance_parameter_values $mem $ip_param_lst($id)

        set board "${mem}_board"
        if {$ip_params(EMIF_${id}_DIAG_USE_BOARD_DELAY_MODEL)} {
            add_instance $board altera_emif_board_delay_model
            set_instance_parameter_values $board $ip_param_lst($id)
        }

        if {$ip_params(EMIF_${id}_DIAG_USE_BOARD_DELAY_MODEL)} {
            add_connection ${emif}.mem ${board}.mem_0
            add_connection ${board}.mem_1 ${mem}.mem
        } else {
            add_connection ${emif}.mem ${mem}.mem
        }

        if {$id == $hps_emif_id} { 
            continue
        }

        set config_enum         $ip_params(EMIF_${id}_PHY_CONFIG_ENUM)
        set use_tg_avl_2        [expr {$ip_params(EMIF_${id}_DIAG_USE_TG_AVL_2) && ($ip_params(EMIF_${id}_PHY_CONFIG_ENUM) != "CONFIG_PHY_ONLY")}]

        set tg_cfg_bfm tg_cfg_bfms_$id

        set ref_clk_freq_mhz  $ip_params(EMIF_${id}_PHY_${protocol}_REF_CLK_FREQ_MHZ)
        if {$ed_params(EMIF_${id}_REF_CLK_SHARING) == "EXPORTED"} {
            set clock_src "pll_ref_clk_source_$id"
            add_instance $clock_src altera_avalon_clock_source
            set_instance_parameter_value $clock_src CLOCK_RATE [expr {round($ref_clk_freq_mhz * 1000000.0)}]
            set_instance_parameter_value $clock_src CLOCK_UNIT 1
        }

        if {[get_instance_parameter_value $emif_cal_wrapper "DIAG_EXPORT_SEQ_AVALON_SLAVE"] == "CAL_DEBUG_EXPORT_MODE_EXPORT"} {
            set cal_debug_clk_src "cal_debug_clk_source_$id"
            add_instance $cal_debug_clk_src altera_avalon_clock_source
            set_instance_parameter_value $cal_debug_clk_src CLOCK_RATE [expr {round($ref_clk_freq_mhz * 1000000.0)}]
            set_instance_parameter_value $cal_debug_clk_src CLOCK_UNIT 1

            set cal_debug_reset_n_src "cal_debug_reset_n_source_$id"
            add_instance $cal_debug_reset_n_src altera_avalon_reset_source
            set_instance_parameter_value $cal_debug_reset_n_src ASSERT_HIGH_RESET 0
            set_instance_parameter_value $cal_debug_reset_n_src INITIAL_RESET_CYCLES 5

            add_connection ${cal_debug_clk_src}.clk ${cal_debug_reset_n_src}.clk
            add_connection ${cal_debug_reset_n_src}.reset ${emif}.cal_debug_reset_n
            add_connection ${cal_debug_clk_src}.clk ${emif}.cal_debug_clk

            set cal_debug_bfm "cal_debug_bfm_$id"
            add_instance $cal_debug_bfm altera_avalon_mm_master_bfm
            add_connection ${cal_debug_clk_src}.clk ${cal_debug_bfm}.clk
            add_connection ${cal_debug_reset_n_src}.reset ${cal_debug_bfm}.clk_reset
            add_connection ${cal_debug_bfm}.m0 ${emif}.cal_debug
        }


        remove_interface local_reset_req

        if {$ed_params(EMIF_${id}_REF_CLK_SHARING) == "EXPORTED"} {
            add_connection ${clock_src}.clk ${emif}.pll_ref_clk
        }

        set id_alternative $id
        if {$id > $hps_emif_id} {
            incr id_alternative -1
        }


        foreach if [get_instance_interfaces $tg] {
            if {[string first "tg_status" $if] == 0} {
                add_connection ${tg}.${if} sim_checker.tg_status_$id_alternative
            }
        }

        foreach if [get_instance_interfaces $emif] {
            if {[string first "status" $if] == 0} {
                add_connection ${emif}.${if} sim_checker.status_$id_alternative
            }
        }
    }

    set_validation_property AUTOMATIC_VALIDATION true
    set qsys_messages [validate_system]
    foreach msg $qsys_messages {
        puts $msg
    }
}

set wb_params_file 1
if {[info exists ed_params(GUI)]} {
    if {$ed_params(GUI)==1} {
        set wb_params_file 0
    }
} else {
    set ed_params(GUI) 0
}

create_system
set_design_id $ed_params(SYSTEM_CONSOLE_DESIGN_ID) 
gen_sys "synth" $wb_params_file
sync_sysinfo_parameters
save_system "$ed_params(TMP_SYNTH_QSYS_PATH)"


create_system
set_design_id $ed_params(SYSTEM_CONSOLE_DESIGN_ID) 
gen_sys "sim" 
sync_sysinfo_parameters
save_system "$ed_params(TMP_SIM_QSYS_PATH)"

                   # IA840F EMIF hold diagnostic: no setter/exception changes.
                   set __e1_hold_P {local_mem_wrapper|mem_ss_top|mem_ss_sv|mem_ss|mem_ss|emif_1}
                   if {$fit_flow == 1 &&
                       $local_core_clock eq "${__e1_hold_P}|emif_1_core_usr_clk" &&
                       [set local_phy_clk_l_${i_phy_clock}] eq "${__e1_hold_P}|emif_1_phy_clk_l_0"} {
                       post_message -type info [list EMIF1_HOLD_ISSUED \
                           app $::TimeQuestInfo(nameofexecutable) from $local_core_clock \
                           to [set local_phy_clk_l_${i_phy_clock}] phy_index $i_phy_clock \
                           same_tile_index $same_tile_index add_mode $add_to_derived \
                           C2P_HOLD_OC_NS $var(C2P_HOLD_OC_NS) issued_ns $c2p_h \
                           multi_tile_base $p2c_c2p_multi_tile_clock_uncertainty \
                           periphery_uncertainty $periphery_clock_uncertainty \
                           overconstraints_st $periphery_overconstraints_st overconstraints_mt $periphery_overconstraints_mt \
                           from_count [get_collection_size [get_clocks $local_core_clock]] \
                           to_count [get_collection_size [get_clocks [set local_phy_clk_l_${i_phy_clock}]]]]
                       if {[llength [info commands ::ia840f_emif_plan03::arm]] == 0} {
                           namespace eval ::ia840f_emif_plan03 {
                               variable armed 0
                               variable callback_count 0
                           }
                           proc ::ia840f_emif_plan03::before_delete {} {
                               variable armed
                               variable callback_count
                               set armed 0
                               incr callback_count
                               post_message -type info [list EMIF_PLAN_CALLBACK_ENTER $callback_count app $::TimeQuestInfo(nameofexecutable)]
                               if {$callback_count > 8} {
                                   post_message -type info [list EMIF_PLAN_CALLBACK_CAP $callback_count]
                                   return
                               }
                               set __ep_report [format {/home/uwb_student00/ahls/new_BSP/qualification/emif-hold-objective-01/plan-diagnostic03/reports/predelete-%02d-sdc.rpt} $callback_count]
                               set __ep_rc [catch {report_sdc -ignored -file $__ep_report} __ep_msg]
                               post_message -type info [list EMIF_PLAN_CALLBACK_RESULT $callback_count rc $__ep_rc message $__ep_msg file $__ep_report]
                           }
                           proc ::ia840f_emif_plan03::arm {} {
                               variable armed
                               if {!$armed} {
                                   set __ep_rc [catch {register_delete_timing_netlist_callback ::ia840f_emif_plan03::before_delete} __ep_msg]
                                   post_message -type info [list EMIF_PLAN_CALLBACK_REGISTER rc $__ep_rc message $__ep_msg]
                                   if {$__ep_rc == 0} {set armed 1}
                               }
                           }
                       }
                       ::ia840f_emif_plan03::arm
                   }
                   unset __e1_hold_P

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
                       if {[llength [info commands ::ia840f_emif_plan02::arm]] == 0} {
                           source {/home/uwb_student00/ahls/new_BSP/qualification/emif-hold-objective-01/plan-diagnostic02/diagnostic.tcl}
                       }
                       ::ia840f_emif_plan02::arm
                   }
                   unset __e1_hold_P

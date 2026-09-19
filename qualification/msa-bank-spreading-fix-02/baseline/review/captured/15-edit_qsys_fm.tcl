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



proc compose_ip {} {
   upvar param_value param_value
   upvar mem_conns   mem_conns
   upvar app_conns   app_conns
   upvar mem_label   mem_label
   upvar app_label   app_label
   upvar mem_ports   mem_ports
   upvar app_ports   app_ports


   set rename_rules(emif_*.pll_ref_clk)               { "mem<MEM_ID>_pll_ref_clk"                  "*"               "mem<MEM_ID>_*"                     "mem<MEM_ID>_*"                     }
   set rename_rules(emif_*.pll_extra_clk_0)           { "mem<MEM_ID>_pll_clk_0"                    "*"               "mem<MEM_ID>_pll_clk_0"             "mem<MEM_ID>_pll_clk_0"             }
   set rename_rules(emif_*.pll_extra_clk_1)           { "mem<MEM_ID>_pll_clk_1"                    "*"               "mem<MEM_ID>_pll_clk_1"             "mem<MEM_ID>_pll_clk_1"             }
   set rename_rules(emif_*.pll_extra_clk_2)           { "mem<MEM_ID>_pll_clk_2"                    "*"               "mem<MEM_ID>_pll_clk_2"             "mem<MEM_ID>_pll_clk_2"             }
   set rename_rules(emif_*.pll_extra_clk_3)           { "mem<MEM_ID>_pll_clk_3"                    "*"               "mem<MEM_ID>_pll_clk_3"             "mem<MEM_ID>_pll_clk_3"             }
   set rename_rules(emif_*.mem)                       { "mem<MEM_ID>_<PROTOCOL>"                   "mem_*"           "mem<MEM_ID>_<PROTOCOL>_*"          "mem<MEM_ID>_<PROTOCOL>_*"          }
   set rename_rules(emif_*.oct)                       { "mem<MEM_ID>_oct"                          "oct_*"           "mem<MEM_ID>_oct_*"                 "mem<MEM_ID>_oct_*"                 }
   set rename_rules(emif_*.ctrl_ecc_status)           { "mem<MEM_ID>_ecc_status"                   "ctrl_*"          "mem<MEM_ID>_*"                     "mem<MEM_ID>_*"                     }
   set rename_rules(emif_*.ac_parity_err)             { "mem<MEM_ID>_ac_parity_err"                "*"               "mem<MEM_ID>_*"                     "mem<MEM_ID>_*"                     }
   set rename_rules(hps_emif.pll_ref_clk)             { "mem<MEM_ID>_pll_ref_clk"                  "*"               "mem<MEM_ID>_*"                     "mem<MEM_ID>_*"                     }
   set rename_rules(hps_emif.mem)                     { "mem<MEM_ID>_<PROTOCOL>"                   "mem_*"           "mem<MEM_ID>_<PROTOCOL>_*"          "mem<MEM_ID>_<PROTOCOL>_*"          }
   set rename_rules(hps_emif.oct)                     { "mem<MEM_ID>_oct"                          "oct_*"           "mem<MEM_ID>_oct_*"                 "mem<MEM_ID>_oct_*"                 }
   set rename_rules(hps_emif.hps_emif)                { "mem<MEM_ID>_hps_emif"                     "*"               "mem<MEM_ID>_*"                     "mem<MEM_ID>_*"                     }
   set rename_rules(emif_*_clk_bridge.out_clk)        { "mem<MEM_ID>_usr_clk"                      "*"               "mem<MEM_ID>_app_ss_usr_clk"        "mem<MEM_ID>_ss_app_usr_clk"        }
   set rename_rules(emif_*_reset_bridge.out_reset)    { "mem<MEM_ID>_usr_reset_n"                  "*"               "mem<MEM_ID>_app_ss_usr_reset_n"    "mem<MEM_ID>_ss_app_usr_reset_n"    }
   set rename_rules(csr_clk_bridge.in_clk)            { "csr_axi_lite_aclk"                        "*"               "csr_app_ss_lite_aclk"              "csr_ss_app_lite_aclk"              }
   set rename_rules(csr_reset_bridge.in_reset)        { "csr_axi_lite_areset_n"                    "*"               "csr_app_ss_lite_areset_n"          "csr_ss_app_lite_areset_n"          }
   set rename_rules(global_csr.s_axi4l)               { "csr_axi_lite"                             "s_axi4l_*"       "csr_app_ss_lite_*"                 "csr_ss_app_lite_*"                 }
   set rename_rules(global_csr.status_<ID>)           { "mem<MEM_ID>_status"                       "*_<ID>"          "mem<MEM_ID>_*"                     "mem<MEM_ID>_*"                     }
   set rename_rules(mem_reset_ctrl.subsystem_reset)   { "subsystem_reset"                          "*"               "*"                                 "*"                                 }
   set rename_rules(msa_*.s_clk)                      { "i<APP_ID>_axi_mm_aclk"                    "*"               "i<APP_ID>_app_ss_mm_aclk"          "i<APP_ID>_ss_app_mm_aclk"          }
   set rename_rules(msa_*.s_reset)                    { "i<APP_ID>_axi_mm_areset_n"                "*"               "i<APP_ID>_app_ss_mm_areset_n"      "i<APP_ID>_ss_app_mm_areset_n"      }
   set rename_rules(msa_*.s_axi4)                     { "i<APP_ID>_axi_mm"                         "s_axi4_*"        "i<APP_ID>_app_ss_mm_*"             "i<APP_ID>_ss_app_mm_*"             }
   set rename_rules(msa_*.status)                     { "mem<MEM_ID>_status"                       "*"               "mem<MEM_ID>_*"                     "mem<MEM_ID>_*"                     }
   set rename_rules(cam_*.graceful_reset)             { "<CAMTYPE><APP_ID>_graceful_reset"         "*"               "<CAMTYPE><APP_ID>_*"               "<CAMTYPE><APP_ID>_*"               }
   set rename_rules(cam_*.axi_st_aclk)                { "<CAMTYPE><APP_ID>_axi_st_aclk"            "*"               "<CAMTYPE><APP_ID>_*"               "<CAMTYPE><APP_ID>_*"               }
   set rename_rules(cam_*.axi_st_areset_n)            { "<CAMTYPE><APP_ID>_axi_st_areset_n"        "*"               "<CAMTYPE><APP_ID>_*"               "<CAMTYPE><APP_ID>_*"               }
   set rename_rules(cam_*.axi_st_req)                 { "<CAMTYPE><APP_ID>_axi_st_req"             "*"               "<CAMTYPE><APP_ID>_*"               "<CAMTYPE><APP_ID>_*"               }
   set rename_rules(cam_*.axi_st_req_tuser)           { "<CAMTYPE><APP_ID>_axi_st_req_tuser"       "*"               "<CAMTYPE><APP_ID>_*"               "<CAMTYPE><APP_ID>_*"               }
   set rename_rules(cam_*.axi_st_resp)                { "<CAMTYPE><APP_ID>_axi_st_resp"            "*"               "<CAMTYPE><APP_ID>_*"               "<CAMTYPE><APP_ID>_*"               }
   set rename_rules(cam_*.axi_st_resp_tuser)          { "<CAMTYPE><APP_ID>_axi_st_resp_tuser"      "*"               "<CAMTYPE><APP_ID>_*"               "<CAMTYPE><APP_ID>_*"               }
   set rename_rules(cam_*.axi_lite_aclk)              { "csr_<CAMTYPE><APP_ID>_axi_lite_aclk"      "*"               "<CAMTYPE><APP_ID>_*"               "<CAMTYPE><APP_ID>_*"               }
   set rename_rules(cam_*.axi_lite_areset_n)          { "csr_<CAMTYPE><APP_ID>_axi_lite_areset_n"  "*"               "<CAMTYPE><APP_ID>_*"               "<CAMTYPE><APP_ID>_*"               }
   set rename_rules(cam_*.axi_lite)                   { "csr_<CAMTYPE><APP_ID>_axi_lite"           "*"               "<CAMTYPE><APP_ID>_*"               "<CAMTYPE><APP_ID>_*"               }


   set csr_map(global_csr.s_apb3)         { 0x00000000        0x00000000                  0 }
   set csr_map(emif_*.effmon_csr_0)       { 0x00001000        0x00001000                  1 }
   set csr_map(emif_*.ctrl_mmr_slave_0)   { 0x00100000        0x00010000                  1 }
   set csr_map(emif_cal_top.cal_debug)    { 0x08000000        0x08000000                  1 }
   set csr_map(emif_cal_bot.cal_debug)    { 0x10000000        0x08000000                  1 }


   if {$param_value(ENABLE_MEM_CSR_INTF) != "DISABLED"} {
      enable_without_load_component csr_clk_bridge false
      enable_without_load_component csr_reset_bridge false
      enable_without_load_component csr_reset_ctrl false
      enable_without_load_component global_csr false

      add_connection csr_clk_bridge.out_clk     csr_reset_ctrl.clk
      add_connection csr_reset_bridge.out_reset csr_reset_ctrl.reset_in0

      add_connection csr_clk_bridge.out_clk     global_csr.axi4l_clk
      add_connection csr_reset_ctrl.reset_out   global_csr.axi4l_reset
      add_connection csr_clk_bridge.out_clk     global_csr.s_apb3_clk
      add_connection csr_reset_ctrl.reset_out   global_csr.s_apb3_reset
   }

   set num_hpsemif  0
   set num_regemif  0
   set num_top_emif 0
   set num_bot_emif 0
   set num_msa      0
   set num_cam      0

   array set mem_port__clk {}
   array set mem_port__rst {}
   array set mem_port__bus {}
   array set app_port__clk {}
   array set app_port__rst {}
   array set app_port__bus {}

   set cal_top_emifs [list]
   set cal_bot_emifs [list]

   set global_csr_qhip_info [list]
   set global_csr_msa_info  [list]

   set reset_ctrl_clk_reset_source_not_found 1

   foreach mem_dev $param_value(MEM_INTFS_TYPE) \
           mem_idx $param_value(MEM_INTFS_IDX) \
           mem_loc $param_value(MEM_INTFS_LOCATION) {

      set not_connected [expr { [llength [array names mem_conns "m${mem_idx}_*"]] == 0 }]
      if {$not_connected} {
         lappend global_csr_qhip_info "NOVAL"
         continue
      }

      set connected_to_hps 0
      set connected_to_storage 0
      set one_to_one 1

      foreach {mem_port app_port_list} [array get mem_conns "m${mem_idx}_*"] {
         foreach app_port $app_port_list {
            if {$app_label($app_port) == "HPS"} {
               set connected_to_hps 1
               set one_to_one 0
            } elseif {$app_label($app_port) == "STORAGE"} {
               set connected_to_storage 1
            }
         }
         if {[llength $app_port_list] > 1 || [llength $app_conns([lindex $app_port_list 0])] > 1} {
            set one_to_one 0
         }
      }

      switch -- $mem_dev {
         DDR4 {
            if {$connected_to_hps} {
               lappend global_csr_qhip_info "HPS_EMIF"

            } else {
               lappend global_csr_qhip_info "EMIF"

               set emif_name       "emif_${num_regemif}"
               set clk_bridge_name "emif_${num_regemif}_clk_bridge"
               set rst_bridge_name "emif_${num_regemif}_reset_bridge"
               incr num_regemif

               enable_and_load_component $emif_name
                  gets_helper get_component_parameter_values [list \
                     row_width   MEM_${mem_dev}_ROW_ADDR_WIDTH \
                     col_width   MEM_${mem_dev}_COL_ADDR_WIDTH \
                     ba_width    MEM_${mem_dev}_BANK_ADDR_WIDTH \
                     bg_width    MEM_${mem_dev}_BANK_GROUP_WIDTH \
                     cs_width    MEM_${mem_dev}_CS_WIDTH \
                     cid_width   MEM_${mem_dev}_CHIP_ID_WIDTH \
                     dm_en       MEM_${mem_dev}_DM_EN \
                     ecc_en      CTRL_${mem_dev}_ECC_EN \
                     priority_en CTRL_${mem_dev}_USER_PRIORITY_EN \
                  ]

                  set_component_parameter_values [list \
                     PROTOCOL_ENUM                          "PROTOCOL_${mem_dev}" \
                     CTRL_${mem_dev}_MMR_EN                 [expr {$param_value(ENABLE_MEM_CSR_INTF) != "DISABLED"}] \
                     CTRL_${mem_dev}_ECC_READDATAERROR_EN   $ecc_en \
                     DIAG_${mem_dev}_EFFICIENCY_MONITOR     [expr {$param_value(ENABLE_MEM_PMON) == "DISABLED" ? "EFFMON_MODE_DISABLED" : $param_value(ENABLE_MEM_PMON) == "EXPORT" ? "EFFMON_MODE_EXPORT" : "EFFMON_MODE_JTAG"}] \
                     DIAG_EXPORT_PLL_REF_CLK_OUT            $reset_ctrl_clk_reset_source_not_found \
                     DIAG_EXPORT_PLL_LOCKED                 $reset_ctrl_clk_reset_source_not_found \
                  ]
               save_component_helper $emif_name

               set reset_ctrl_clk_reset_source_not_found 0

               set wr_data_width [get_instance_interface_port_property $emif_name ctrl_amm_0 amm_writedata_0 WIDTH]
               set rd_data_width [get_instance_interface_port_property $emif_name ctrl_amm_0 amm_readdata_0  WIDTH]
               set awaddr_width  [get_instance_interface_port_property $emif_name ctrl_amm_0 amm_address_0   WIDTH]
               set awaddr_width  [expr {$awaddr_width + int(ceil(log(${wr_data_width}/8)/log(2)))}]   ;
               set araddr_width  $awaddr_width

               if {$mem_loc == "TOP"} {
                  lappend cal_top_emifs $emif_name
               } else {
                  lappend cal_bot_emifs $emif_name
               }



               enable_without_load_component $clk_bridge_name false
               enable_without_load_component $rst_bridge_name false

               add_connection ${emif_name}.emif_usr_clk     ${clk_bridge_name}.in_clk
               add_connection ${emif_name}.emif_usr_reset_n ${rst_bridge_name}.in_reset

               set msa_name "msa_${num_msa}"
               incr num_msa

               enable_and_load_component $msa_name
                  set_hwtcl_parameter_property $msa_name MBL_TRAFFIC_EN       DISABLED false
                  set_hwtcl_parameter_property $msa_name AUTO_PRECHARGE       DISABLED false
                  set_hwtcl_parameter_property $msa_name NUM_COPIES           DISABLED false
                  set_hwtcl_parameter_property $msa_name NUM_BANK_FIFOS       DISABLED false
                  set_hwtcl_parameter_property $msa_name SCHEDULER_NUM_READ   DISABLED false
                  set_hwtcl_parameter_property $msa_name SCHEDULER_NUM_WRITE  DISABLED false
                  set_hwtcl_parameter_property $msa_name RESP_USE_WSTRB       DISABLED false
                  set_hwtcl_parameter_property $msa_name RESP_WR_DATA_WIDTH   DISABLED false
                  set_hwtcl_parameter_property $msa_name RESP_RD_DATA_WIDTH   DISABLED false

                  if {$one_to_one && $connected_to_storage} {
                     set_hwtcl_parameter_property $msa_name ASYNC_EN DISABLED false
                  } else {
                     set_hwtcl_parameter_property $msa_name ASYNC_EN DISABLED true
                     set_component_parameter_value ASYNC_EN true
                  }

                  gets_helper get_component_parameter_values [list \
                     prev_wr_data_width   INIT_WR_DATA_WIDTH \
                     prev_rd_data_width   INIT_RD_DATA_WIDTH \
                     resp_wr_data_width   RESP_WR_DATA_WIDTH \
                     resp_rd_data_width   RESP_RD_DATA_WIDTH \
                     \
                     auto_precharge       AUTO_PRECHARGE \
                     async_en             ASYNC_EN \
                  ]

                  set_component_parameter_values [list \
                     CSR_EN               [expr {$param_value(ENABLE_MEM_CSR_INTF) != "DISABLED"}] \
                     ECC_EN               $ecc_en \
                     PRIORITY_EN          $priority_en \
                     \
                     INIT_BUS_PROTOCOL    "AVMM" \
                     INIT_AWADDR_WIDTH    $awaddr_width \
                     INIT_ARADDR_WIDTH    $araddr_width \
                     INIT_WR_DATA_WIDTH   $wr_data_width \
                     INIT_RD_DATA_WIDTH   $rd_data_width \
                     \
                     RESP_BUS_PROTOCOL    "AXI4" \
                     RESP_USE_WSTRB       $dm_en \
                     \
                     ROW_ADDR_WIDTH       $row_width \
                     COL_ADDR_WIDTH       $col_width \
                     BANK_ADDR_WIDTH      $ba_width \
                     BANK_GROUP_WIDTH     $bg_width \
                     CHIP_ID_WIDTH        $cid_width \
                     CHIP_SELECT_WIDTH    $cs_width \
                     \
                     MBL_TRAFFIC_EN       false \
                  ]

                  set t [expr {log(1.0 * $resp_wr_data_width / $wr_data_width) / log(2)}]
                  if {$wr_data_width != $prev_wr_data_width && ($wr_data_width > $resp_wr_data_width || int($t) != $t)} {
                     set_component_parameter_value RESP_WR_DATA_WIDTH $wr_data_width
                  }
                  set t [expr {log(1.0 * $resp_rd_data_width / $rd_data_width) / log(2)}]
                  if {$rd_data_width != $prev_rd_data_width && ($rd_data_width > $resp_rd_data_width || int($t) != $t)} {
                     set_component_parameter_value RESP_RD_DATA_WIDTH $rd_data_width
                  }
               save_component_helper $msa_name

               load_component $emif_name
                  set_component_parameter_values [list \
                     CTRL_${mem_dev}_AUTO_PRECHARGE_EN   [expr {$auto_precharge != "DISABLED"}] \
                  ]
               save_component_helper $emif_name

               if {$async_en == "false"} {
                  add_connection ${emif_name}.emif_usr_clk     ${msa_name}.s_clk
                  add_connection ${emif_name}.emif_usr_reset_n ${msa_name}.s_reset
               }
               add_connection ${emif_name}.emif_usr_clk     ${msa_name}.m_clk
               add_connection ${emif_name}.emif_usr_reset_n ${msa_name}.m_reset
               add_connection ${msa_name}.m_avmm            ${emif_name}.ctrl_amm_0
               add_connection ${emif_name}.status           ${msa_name}.status_in
               if {$auto_precharge != "DISABLED"} {
                  add_connection ${msa_name}.ctrl_auto_precharge ${emif_name}.ctrl_auto_precharge_0
               }
               if {$ecc_en} {
                  add_connection ${emif_name}.ctrl_ecc_user_interrupt_0 ${msa_name}.ctrl_ecc_user_interrupt
                  add_connection ${emif_name}.ctrl_ecc_readdataerror_0  ${msa_name}.ctrl_ecc_readdataerror
               }
               if {$priority_en} {
                  add_connection ${emif_name}.ctrl_user_priority_0 ${msa_name}.ctrl_user_priority
               }

               lappend global_csr_msa_info $mem_idx $msa_name

               foreach mem_port [lsort [array names mem_conns "m${mem_idx}_*"]] {
                  set mem_port__clk($mem_port) "${msa_name}.s_clk"
                  set mem_port__rst($mem_port) "${msa_name}.s_reset"
                  set mem_port__bus($mem_port) "${msa_name}.s_axi4"

                  lappend rename_vars($emif_name)       [list "<MEM_ID>" $mem_idx "<PROTOCOL>" [string tolower $mem_dev]]
                  lappend rename_vars($clk_bridge_name) [list "<MEM_ID>" $mem_idx]
                  lappend rename_vars($rst_bridge_name) [list "<MEM_ID>" $mem_idx]
                  set app_port [lindex $mem_conns(m${mem_idx}_p0) 0]
                  set app_idx  [string trimleft [lindex [split $app_port "_"] 0] "a"]
                  lappend rename_vars($msa_name)        [list "<MEM_ID>" $mem_idx "<APP_ID>" $app_idx]
               }
            }
         }

         M20K {
            lappend global_csr_qhip_info "CAM"
         }
      }
   }

   set all_emifs [lsort [concat $cal_top_emifs $cal_bot_emifs]]
   if {[llength $all_emifs] > 0} {
      if {$reset_ctrl_clk_reset_source_not_found} {
         error "Internal Error: Failed to find a clk/reset source for MemSS Reset Controller"
      }

      enable_and_load_component mem_reset_ctrl
         set_component_parameter_values [list \
            RESET_PORT_ROLE   "pll_locked" \
            NUM_FM_EMIF       [llength $all_emifs] \
         ]
      save_component_helper mem_reset_ctrl

      set i 0
      foreach emif_name $all_emifs {
         if {$i == 0} {
            add_connection ${emif_name}.pll_ref_clk_out  mem_reset_ctrl.clk
            add_connection ${emif_name}.pll_locked       mem_reset_ctrl.reset
         }
         add_connection mem_reset_ctrl.fm_emif_reset_req_${i}    ${emif_name}.local_reset_req
         add_connection mem_reset_ctrl.fm_emif_reset_status_${i} ${emif_name}.local_reset_status
         incr i
      }

   }


   set num_cam 0

   foreach app_intf $param_value(APP_INTFS_TYPE) \
           app_idx  $param_value(APP_INTFS_IDX) {

      set one_to_one 1

      foreach {app_port mem_port_list} [array get app_conns "a${app_idx}_*"] {
         if {$app_label($app_port) == "HPS"} {
            set connected_to_hps 1
            set one_to_one 0
         }
         if {[llength $mem_port_list] > 1 || [llength $mem_conns([lindex $mem_port_list 0])] > 1} {
            set one_to_one 0
         }
      }

      switch -- $app_intf {
         STORAGE {
            if {!$one_to_one} {


            } else {

               set app_port__clk(a${app_idx}_p0) ""
               set app_port__rst(a${app_idx}_p0) ""
               set app_port__bus(a${app_idx}_p0) ""
            }
         }

         ASSOC_STORAGE {
            set mem_port [lindex $app_conns(a${app_idx}_p0) 0]
            if {$mem_label($mem_port) == "M20K"} {
               set use_external_mem 0
            } else {
               set use_external_mem 1
            }


            if {$use_external_mem} {
               set msa_name [lindex [split $mem_port__bus($mem_port) "."] 0]

               load_component $msa_name
                  set_hwtcl_parameter_property $msa_name MBL_TRAFFIC_EN       DISABLED true
                  set_hwtcl_parameter_property $msa_name AUTO_PRECHARGE       DISABLED true
                  set_hwtcl_parameter_property $msa_name NUM_COPIES           DISABLED true
                  set_hwtcl_parameter_property $msa_name NUM_BANK_FIFOS       DISABLED true
                  set_hwtcl_parameter_property $msa_name SCHEDULER_NUM_READ   DISABLED true
                  set_hwtcl_parameter_property $msa_name SCHEDULER_NUM_WRITE  DISABLED true
                  set_hwtcl_parameter_property $msa_name RESP_USE_WSTRB       DISABLED true
                  set_hwtcl_parameter_property $msa_name RESP_WR_DATA_WIDTH   DISABLED true
                  set_hwtcl_parameter_property $msa_name RESP_RD_DATA_WIDTH   DISABLED true

                  set_component_parameter_values [list \
                     MBL_TRAFFIC_EN       true \
                     AUTO_PRECHARGE       SS_CONTROLLED \
                     NUM_COPIES           4 \
                     NUM_BANK_FIFOS       0 \
                     SCHEDULER_NUM_READ   16 \
                     SCHEDULER_NUM_WRITE  16 \
                  ]
                  validate_component

                  gets_helper get_component_parameter_values [list \
                     axi_mm_addr_width       RESP_AWADDR_WIDTH \
                     axi_mm_data_width       RESP_WDATA_WIDTH \
                     axi_mm_user_width       RESP_WUSER_WIDTH \
                     \
                     c_width                 CHIP_ID_WIDTH \
                     cs_width                CHIP_SELECT_WIDTH \
                     bg_width                BANK_GROUP_WIDTH \
                     resp_wr_data_width      RESP_WR_DATA_WIDTH \
                     resp_rd_data_width      RESP_RD_DATA_WIDTH \
                     init_wr_data_width      INIT_WR_DATA_WIDTH \
                     init_rd_data_width      INIT_RD_DATA_WIDTH \
                  ]
                  set_component_parameter_values [list \
                     RESP_WR_DATA_WIDTH   $init_wr_data_width \
                     RESP_RD_DATA_WIDTH   $init_rd_data_width \
                  ]
               save_component_helper $msa_name
            }

            set cam_name "cam_${num_cam}"
            incr num_cam

            enable_and_load_component $cam_name
               gets_helper get_component_parameter_values [list \
                  prev_traffic_type       TRAFFIC_TYPE \
                  prev_use_external_mem   USE_EXTERNAL_MEM \
               ]

               set_component_parameter_values [list \
                  USE_EXTERNAL_MEM        $use_external_mem \
               ]

               if {$use_external_mem} {
                  set_component_parameter_values [list \
                     AXI_MM_ADDR_WIDTH $axi_mm_addr_width \
                     AXI_MM_DATA_WIDTH $axi_mm_data_width \
                     AXI_MM_USER_WIDTH $axi_mm_user_width \
                  ]
               }

               if {$prev_use_external_mem == 0 && $use_external_mem == 1 && $prev_traffic_type == "WILDCARD_MATCH"} {
                  set_component_parameter_value TRAFFIC_TYPE "EXACT_MATCH"
               }

               validate_component
               gets_helper get_component_parameter_values [list \
                  cam_algo                CAM_ALGO \
               ]
            save_component_helper $cam_name

            if {$use_external_mem} {
               set emif_name "emif_[lindex [split $msa_name _] 1]"
               set cam_msa_messages ""
               if {$cam_msa_messages != ""} {
               }
            }

            if {!$use_external_mem} {
               set app_port__clk(a${app_idx}_p0) ""
               set app_port__rst(a${app_idx}_p0) ""
               set app_port__bus(a${app_idx}_p0) ""
               set app_port__clk(a${app_idx}_p1) ""
               set app_port__rst(a${app_idx}_p1) ""
               set app_port__bus(a${app_idx}_p1) ""
            } else {
               set app_port__clk(a${app_idx}_p0) "${cam_name}.axi_mm_clk"
               set app_port__rst(a${app_idx}_p0) "${cam_name}.axi_mm_reset_n"
               set app_port__bus(a${app_idx}_p0) "${cam_name}.axi_mm"
               set app_port__clk(a${app_idx}_p1) ""
               set app_port__rst(a${app_idx}_p1) ""
               set app_port__bus(a${app_idx}_p1) ""
            }

            switch -- $cam_algo {
               BCAM { set cam_type "em" }
               TCAM { set cam_type "tcam" }
               MBL  { set cam_type "mbl" }
            }
            lappend rename_vars($cam_name) [list "<APP_ID>" $app_idx "<CAMTYPE>" $cam_type]
         }

         HPS {
            set mem_port_list $app_conns(a${app_idx}_p0)
            set mem_port [lindex $mem_port_list 0]
            set mem_idx  [string trimleft [lindex [split $mem_port "_"] 0] "m"]
            set mem_dev  [lindex $param_value(MEM_INTFS_TYPE)     $mem_idx]
            set mem_loc  [lindex $param_value(MEM_INTFS_LOCATION) $mem_idx]


            enable_and_load_component hps_emif
               set_component_parameter_values [list \
                  PROTOCOL_ENUM  "PROTOCOL_${mem_dev}" \
               ]
            save_component_helper hps_emif

            if {$mem_loc == "TOP"} {
               lappend cal_top_emifs hps_emif
            } else {
               lappend cal_bot_emifs hps_emif
            }

            set app_port__clk(a${app_idx}_p0) ""
            set app_port__rst(a${app_idx}_p0) ""
            set app_port__bus(a${app_idx}_p0) ""

            lappend rename_vars(hps_emif) [list "<MEM_ID>" $mem_idx "<PROTOCOL>" [string tolower $mem_dev]]
         }
      }
   }

   set top_emif_toolkit_mode ""
   if {[llength $cal_top_emifs] > 0} {
      enable_and_load_component emif_cal_top
         if {$param_value(ENABLE_MEM_CSR_INTF) == "DISABLED"} {
            set_hwtcl_parameter_property emif_cal_top DIAG_EXPORT_SEQ_AVALON_SLAVE DISABLED true
            set_component_parameter_value DIAG_EXPORT_SEQ_AVALON_SLAVE "CAL_DEBUG_EXPORT_MODE_DISABLED"
         } else {
            set_hwtcl_parameter_property emif_cal_top DIAG_EXPORT_SEQ_AVALON_SLAVE DISABLED false
         }

         gets_helper get_component_parameter_values [list \
            top_emif_toolkit_mode   DIAG_EXPORT_SEQ_AVALON_SLAVE \
            top_emif_cal_mode       DIAG_SIM_CAL_MODE_ENUM \
            top_emif_sim_verbose    DIAG_SIM_VERBOSE \
         ]

         set_component_parameter_values [list \
            NUM_CALBUS_INTERFACE    [llength $cal_top_emifs] \
         ]
      save_component_helper emif_cal_top

      foreach emif_name $cal_top_emifs {
         load_component $emif_name
            set_component_parameter_values [list \
               DIAG_DDR4_EXPORT_SEQ_AVALON_SLAVE   $top_emif_toolkit_mode \
               DIAG_DDR4_SIM_CAL_MODE_ENUM         $top_emif_cal_mode \
               DIAG_DDR4_SIM_VERBOSE               $top_emif_sim_verbose \
            ]
         save_component_helper $emif_name
      }

      set i 0
      foreach emif_name $cal_top_emifs {
         add_connection emif_cal_top.emif_calbus_clk  ${emif_name}.emif_calbus_clk
         add_connection emif_cal_top.emif_calbus_${i} ${emif_name}.emif_calbus
         incr i
      }
      if {$top_emif_toolkit_mode != "CAL_DEBUG_EXPORT_MODE_DISABLED"} {
         add_connection csr_clk_bridge.out_clk   emif_cal_top.cal_debug_clk
         add_connection csr_reset_ctrl.reset_out emif_cal_top.cal_debug_reset_n
      }
   }

   set bot_emif_toolkit_mode ""
   if {[llength $cal_bot_emifs] > 0} {
      enable_and_load_component emif_cal_bot
         if {$param_value(ENABLE_MEM_CSR_INTF) == "DISABLED"} {
            set_hwtcl_parameter_property emif_cal_bot DIAG_EXPORT_SEQ_AVALON_SLAVE DISABLED true
            set_component_parameter_value DIAG_EXPORT_SEQ_AVALON_SLAVE "CAL_DEBUG_EXPORT_MODE_DISABLED"
         } else {
            set_hwtcl_parameter_property emif_cal_bot DIAG_EXPORT_SEQ_AVALON_SLAVE DISABLED false
         }

         gets_helper get_component_parameter_values [list \
            bot_emif_toolkit_mode   DIAG_EXPORT_SEQ_AVALON_SLAVE \
            bot_emif_cal_mode       DIAG_SIM_CAL_MODE_ENUM \
            bot_emif_sim_verbose    DIAG_SIM_VERBOSE \
         ]

         set_component_parameter_values [list \
            NUM_CALBUS_INTERFACE    [llength $cal_bot_emifs] \
         ]
      save_component_helper emif_cal_bot

      foreach emif_name $cal_bot_emifs {
         load_component $emif_name
            set_component_parameter_values [list \
               DIAG_DDR4_EXPORT_SEQ_AVALON_SLAVE   $bot_emif_toolkit_mode \
               DIAG_DDR4_SIM_CAL_MODE_ENUM         $bot_emif_cal_mode \
               DIAG_DDR4_SIM_VERBOSE               $bot_emif_sim_verbose \
            ]
         save_component_helper $emif_name
      }

      set i 0
      foreach emif_name $cal_bot_emifs {
         add_connection emif_cal_bot.emif_calbus_clk  ${emif_name}.emif_calbus_clk
         add_connection emif_cal_bot.emif_calbus_${i} ${emif_name}.emif_calbus
         incr i
      }
      if {$bot_emif_toolkit_mode != "CAL_DEBUG_EXPORT_MODE_DISABLED"} {
         add_connection csr_clk_bridge.out_clk   emif_cal_bot.cal_debug_clk
         add_connection csr_reset_ctrl.reset_out emif_cal_bot.cal_debug_reset_n
      }
   }

   if {$param_value(ENABLE_MEM_CSR_INTF) != "DISABLED"} {
      connect_csr_interfaces global_csr.m_axi4l

      set_connection_parameter_value global_csr.m_axi4l/global_csr.s_apb3 defaultConnection 1

      load_component global_csr
         set param_vals [list]

         lappend param_vals \
            MEM_INTFS_TYPE          $param_value(MEM_INTFS_TYPE) \
            MEM_INTFS_QHIP          $global_csr_qhip_info \
            EMIF_CAL_DEBUG_ENABLED  [expr {$top_emif_toolkit_mode == "CAL_DEBUG_EXPORT_MODE_EXPORT" || $bot_emif_toolkit_mode == "CAL_DEBUG_EXPORT_MODE_EXPORT"}] \
            MEM_PMON_ENABLED        [expr {$param_value(ENABLE_MEM_PMON) == "EXPORT"}]

         set_component_parameter_values $param_vals
      save_component_helper global_csr

      set i 0
      foreach {mem_idx msa_name} $global_csr_msa_info {
         add_connection ${msa_name}.status  global_csr.status_in_${i}
         add_connection ${msa_name}.msa_csr global_csr.msa_csr_${i}

         lappend rename_vars(global_csr) [list "<ID>" $i "<MEM_ID>" $mem_idx]

         incr i
      }
   }


   foreach {mem_port app_port_list} [array get mem_conns] {
      foreach app_port $app_port_list {
         if {$app_port__bus($app_port) != ""} {
            add_connection $app_port__clk($app_port) $mem_port__clk($mem_port)
            add_connection $app_port__rst($app_port) $mem_port__rst($mem_port)
            add_connection $app_port__bus($app_port) $mem_port__bus($mem_port)
         }
      }
   }


   auto_assign_system_base_addresses

   export_interfaces
}

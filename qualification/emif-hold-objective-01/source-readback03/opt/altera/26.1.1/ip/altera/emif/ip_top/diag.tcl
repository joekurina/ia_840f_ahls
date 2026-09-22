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


package provide altera_emif::ip_top::diag 0.1

package require altera_emif::util::messaging
package require altera_emif::util::qini
package require altera_emif::util::hwtcl_utils
package require altera_emif::util::enums
package require altera_emif::util::device_family
package require altera_emif::ip_top::protocol_expert

namespace eval ::altera_emif::ip_top::diag:: {

   namespace import ::altera_emif::util::messaging::*
   namespace import ::altera_emif::util::qini::*
   namespace import ::altera_emif::util::enums::*
   namespace import ::altera_emif::util::hwtcl_utils::*
   namespace import ::altera_emif::util::device_family::*


   variable m_param_prefix "DIAG"
}


proc ::altera_emif::ip_top::diag::create_parameters {is_top_level_component} {


   add_user_param     "DIAG_SIM_REGTEST_MODE"              boolean   false                        ""                                        ""
   add_user_param     "DIAG_TIMING_REGTEST_MODE"           boolean   false                        ""                                        ""
   add_user_param     "DIAG_SYNTH_FOR_SIM"                 boolean   false                        ""                                        ""
   add_user_param     "DIAG_FAST_SIM_OVERRIDE"             string    FAST_SIM_OVERRIDE_DEFAULT    [enum_dropdown_entries FAST_SIM_OVERRIDE] ""

   add_user_param     "DIAG_SEQ_RESET_AUTO_RELEASE"        string    "avl"                        ""                                        ""
   add_user_param     "DIAG_DB_RESET_AUTO_RELEASE"         string    "avl_release"                ""                                        ""
   set_parameter_property "DIAG_SEQ_RESET_AUTO_RELEASE" VISIBLE false   
   set_parameter_property "DIAG_DB_RESET_AUTO_RELEASE" VISIBLE false

   add_user_param     "DIAG_ADD_READY_PIPELINE"            boolean   "true"                       ""                                        ""
   add_user_param     "DIAG_EXPOSE_EARLY_READY"            boolean   "false"                      ""                                        ""
   add_user_param     "DIAG_EXPOSE_RD_TYPE"                boolean   "false"                      ""                                        ""

   add_user_param     "DIAG_VERBOSE_IOAUX"                 boolean   false     ""               ""

   add_user_param     "DIAG_ECLIPSE_DEBUG"                 boolean   false     ""               ""
   add_user_param     "DIAG_EXPORT_VJI"                    boolean   false     ""               ""
   add_user_param     "DIAG_ENABLE_JTAG_UART"              boolean   false     ""               ""
   add_user_param     "DIAG_ENABLE_JTAG_UART_HEX"          boolean   false     ""               ""
   add_user_param     "DIAG_ENABLE_HPS_EMIF_DEBUG"         boolean   false     ""               ""

   add_user_param     "DIAG_SOFT_NIOS_MODE"                string    SOFT_NIOS_MODE_DISABLED    "" ""
   set_parameter_property "DIAG_SOFT_NIOS_MODE" VISIBLE false
   add_user_param     "DIAG_SOFT_NIOS_CLOCK_FREQUENCY"     integer   100       ""               MegaHertz
   set_parameter_property "DIAG_SOFT_NIOS_CLOCK_FREQUENCY" VISIBLE false
   add_user_param     "DIAG_USE_RS232_UART"                boolean   false     ""               ""
   add_user_param     "DIAG_RS232_UART_BAUDRATE"           integer   57600     [list 9600 19200 38400 57600 115200]  BitsPerSecond

   add_user_param     "DIAG_EX_DESIGN_ADD_TEST_EMIFS"      string    ""         ""              ""
   add_user_param     "DIAG_EX_DESIGN_SEPARATE_RESETS"     boolean   false      ""

   add_user_param     "DIAG_EXPOSE_DFT_SIGNALS"            boolean   false      ""

   add_user_param     "DIAG_EXTRA_CONFIGS"                 string    ""         ""

   add_user_param     "DIAG_USE_BOARD_DELAY_MODEL"         boolean   false      ""               ""
   add_user_param     "DIAG_BOARD_DELAY_CONFIG_STR"        string    ""         ""               ""

   add_user_param     "DIAG_TG_AVL_2_NUM_CFG_INTERFACES"   integer   0          [list 0 1]       ""
   set_parameter_property "DIAG_TG_AVL_2_NUM_CFG_INTERFACES" VISIBLE false
   
   add_user_param     "DIAG_EXPORT_PLL_REF_CLK_OUT"        boolean   false      ""               ""
   set_parameter_property "DIAG_EXPORT_PLL_REF_CLK_OUT" VISIBLE false   

   add_user_param     "DIAG_EXPORT_PLL_LOCKED"             boolean   false      ""               ""
   
   add_user_param     "DIAG_HMC_HRC"                       string    "auto"      ""               ""
   set_parameter_property "DIAG_HMC_HRC" VISIBLE false   
   
   add_user_param     "SHORT_QSYS_INTERFACE_NAMES"         boolean   true       ""               ""
   set_parameter_property "SHORT_QSYS_INTERFACE_NAMES" VISIBLE false

   add_user_param     "DIAG_EXT_DOCS"                      boolean   false      ""               ""
   set_parameter_property "DIAG_EXT_DOCS" VISIBLE false

   add_derived_param  "DIAG_SIM_CAL_MODE_ENUM"                string     ""       false     ""
   add_derived_param  "DIAG_EXPORT_SEQ_AVALON_SLAVE"          string     ""       false     ""
   add_derived_param  "DIAG_EXPORT_SEQ_AVALON_MASTER"         boolean    false    false     ""
   add_derived_param  "DIAG_EXPORT_SEQ_AVALON_HEAD_OF_CHAIN"  boolean    false    false     ""
   add_derived_param  "DIAG_EX_DESIGN_NUM_OF_SLAVES"          integer    1        false     ""
   add_derived_param  "DIAG_EX_DESIGN_ISSP_EN"                boolean    true     false     ""
   add_derived_param  "DIAG_INTERFACE_ID"                     integer    0        false     ""
   add_derived_param  "DIAG_EFFICIENCY_MONITOR"               string     ""       false     ""
   add_derived_param  "DIAG_USE_NEW_EFFMON_S10"               boolean    false    false     ""
   add_derived_param  "DIAG_USE_ABSTRACT_PHY"                 boolean    false    false     ""
   add_derived_param  "DIAG_SIM_MEMORY_PRELOAD"               boolean    false    false     ""
   add_derived_param  "DIAG_SIM_MEMORY_PRELOAD_PRI_EMIF_FILE" string     ""       false     ""
   add_derived_param  "DIAG_SIM_MEMORY_PRELOAD_PRI_ECC_FILE"  string     ""       false     ""
   add_derived_param  "DIAG_SIM_MEMORY_PRELOAD_PRI_MEM_FILE"  string     ""       false     ""
   add_derived_param  "DIAG_SIM_MEMORY_PRELOAD_PRI_ABPHY_FILE" string     ""       false     ""
   add_derived_param  "DIAG_SIM_MEMORY_PRELOAD_SEC_EMIF_FILE" string     ""       false     ""
   add_derived_param  "DIAG_SIM_MEMORY_PRELOAD_SEC_ECC_FILE"  string     ""       false     ""
   add_derived_param  "DIAG_SIM_MEMORY_PRELOAD_SEC_MEM_FILE"  string     ""       false     ""
   add_derived_param  "DIAG_SIM_MEMORY_PRELOAD_SEC_ABPHY_FILE" string     ""       false     ""
   add_derived_param  "DIAG_USE_SIM_MEMORY_VALIDATION_TG"     boolean    false    false     ""
   add_derived_param  "DIAG_SIM_VERBOSE_LEVEL"                integer    2        false     ""

   add_derived_param  "DIAG_FAST_SIM"                         boolean   true      false     ""

   add_derived_param  "DIAG_USE_TG_AVL_2"                     boolean   false     false     ""
   add_derived_param  "DIAG_TG2_TEST_DURATION"                string    ""        false     ""
   add_derived_param  "DIAG_USE_TG_HBM"                       boolean   false     false     ""
   add_derived_param  "DIAG_EXPORT_TG_CFG_AVALON_SLAVE"       string    ""        false     ""
   add_derived_param  "DIAG_ENABLE_DEFAULT_MODE"              boolean   false     false     ""
   add_derived_param  "DIAG_ENABLE_USER_MODE"                 boolean   true      false     ""

   add_derived_param  "DIAG_ENABLE_SOFT_M20K"                 boolean   false     false     ""
   add_derived_param  "DIAG_SIM_CHECKER_SKIP_TG"              boolean   false     false     ""

   add_derived_param  "DIAG_AC_PARITY_ERR"                    boolean   false     false     ""
   add_derived_param  "DIAG_DISABLE_AFI_P2C_REGISTERS"        boolean   false     false     ""
   
   add_derived_param  "DIAG_EX_DESIGN_SEPARATE_RZQS"          boolean   true      false     ""

   ::altera_emif::ip_top::protocol_expert::create_parameters FUNC_DIAG $is_top_level_component

   return 1
}

proc ::altera_emif::ip_top::diag::set_family_specific_defaults {family_enum base_family_enum is_hps} {

   if {$base_family_enum == "FAMILY_ARRIA10"} {
      set_parameter_property SHORT_QSYS_INTERFACE_NAMES DEFAULT_VALUE false
      set_parameter_property SHORT_QSYS_INTERFACE_NAMES NEW_INSTANCE_VALUE true
      set_parameter_property SHORT_QSYS_INTERFACE_NAMES VISIBLE true
   } elseif {$base_family_enum == "FAMILY_AGILEX"} {
     set_parameter_property "DIAG_SOFT_NIOS_MODE" VISIBLE false
     set_display_item_property TEXT_AVL_CHAIN_WARN   VISIBLE false
   }

   ::altera_emif::ip_top::protocol_expert::set_family_specific_defaults FUNC_DIAG $family_enum $base_family_enum $is_hps
   return 1
}

proc ::altera_emif::ip_top::diag::create_protocol_specifc_common_parameters {param_prefix} {

   set use_tg_avl_2_default false
   set enable_default_mode false
   set enable_user_mode true
   if {$param_prefix == "DIAG_DDRT"} {
      set use_tg_avl_2_default true
      set enable_user_mode false
      set enable_default_mode true
   } 
   add_user_param     "${param_prefix}_SIM_CAL_MODE_ENUM"                      string    SIM_CAL_MODE_SKIP                [enum_dropdown_entries SIM_CAL_MODE]           ""       ""             ""             DIAG_SIM_CAL_MODE_ENUM
   add_user_param     "${param_prefix}_EXPORT_SEQ_AVALON_SLAVE"                string    CAL_DEBUG_EXPORT_MODE_DISABLED   [enum_dropdown_entries CAL_DEBUG_EXPORT_MODE]  ""       ""             ""             DIAG_EXPORT_SEQ_AVALON_SLAVE
   add_user_param     "${param_prefix}_EXPORT_SEQ_AVALON_MASTER"               boolean   false                            ""                                             ""       ""             ""             DIAG_EXPORT_SEQ_AVALON_MASTER
   add_user_param     "${param_prefix}_EXPORT_SEQ_AVALON_HEAD_OF_CHAIN"        boolean   true                             ""                                             ""       ""             ""             DIAG_EXPORT_SEQ_AVALON_HEAD_OF_CHAIN
   add_user_param     "${param_prefix}_EX_DESIGN_NUM_OF_SLAVES"                integer   1                                [list 1 2 3 4 5 6 7 8]                         ""       ""             ""             DIAG_EX_DESIGN_NUM_OF_SLAVES
   add_user_param     "${param_prefix}_EX_DESIGN_ISSP_EN"                      boolean   true                             ""                                             ""       ""             ""             DIAG_EX_DESIGN_ISSP_EN
   add_user_param     "${param_prefix}_INTERFACE_ID"                           integer   0                                [list 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15]   ""       ""             ""             DIAG_INTERFACE_ID
   add_user_param     "${param_prefix}_EFFICIENCY_MONITOR"                     string    EFFMON_MODE_DISABLED             [enum_dropdown_entries EFFMON_MODE]            ""       ""             ""             DIAG_EFFICIENCY_MONITOR
   add_user_param     "${param_prefix}_USE_NEW_EFFMON_S10"                     boolean   false                            ""                                             ""       ""             ""             DIAG_USE_NEW_EFFMON_S10
   add_user_param     "${param_prefix}_USER_SIM_MEMORY_PRELOAD"                boolean   false                            ""                                             ""       ""             ""             DIAG_SIM_MEMORY_PRELOAD
   add_user_param     "${param_prefix}_USER_SIM_MEMORY_PRELOAD_PRI_EMIF_FILE"  string    "EMIF_PRI_PRELOAD.txt"           ""                                             ""       ""             ""             DIAG_SIM_MEMORY_PRELOAD_PRI_EMIF_FILE
   add_user_param     "${param_prefix}_USER_SIM_MEMORY_PRELOAD_SEC_EMIF_FILE"  string    "EMIF_SEC_PRELOAD.txt"           ""                                             ""       ""             ""             DIAG_SIM_MEMORY_PRELOAD_SEC_EMIF_FILE
   add_user_param     "${param_prefix}_USER_USE_SIM_MEMORY_VALIDATION_TG"      boolean   true                             ""                                             ""       ""             ""             DIAG_USE_SIM_MEMORY_VALIDATION_TG
   add_user_param     "${param_prefix}_USE_TG_AVL_2"                           boolean   $use_tg_avl_2_default            ""                                             ""       ""             ""             DIAG_USE_TG_AVL_2
   add_user_param     "${param_prefix}_USE_TG_HBM"                             boolean   false                            ""                                             ""       ""             ""             DIAG_USE_TG_HBM
   add_user_param     "${param_prefix}_ABSTRACT_PHY"                           boolean   false                            ""                                             ""       ""             ""             DIAG_ABSTRACT_PHY
   add_user_param     "${param_prefix}_ENABLE_DEFAULT_MODE"                    boolean   $enable_default_mode             ""                                             ""       ""             ""             DIAG_ENABLE_DEFAULT_MODE
   add_user_param     "${param_prefix}_ENABLE_USER_MODE"                       boolean   $enable_user_mode                ""                                             ""       ""             ""             DIAG_ENABLE_USER_MODE
   add_user_param     "${param_prefix}_EXPORT_TG_CFG_AVALON_SLAVE"             string    TG_CFG_AMM_EXPORT_MODE_JTAG      [enum_dropdown_entries TG_CFG_AMM_EXPORT_MODE] ""       ""             ""             DIAG_EXPORT_TG_CFG_AVALON_SLAVE
   add_user_param     "${param_prefix}_TG2_TEST_DURATION"                      string    SHORT                            [enum_dropdown_entries TG2_TEST_DURATION]      ""       ""             ""             DIAG_TG2_TEST_DURATION
   add_user_param     "${param_prefix}_SEPARATE_READ_WRITE_ITFS"               boolean   false                            ""                                             ""       ""             ""             DIAG_SEPARATE_READ_WRITE_ITFS
   add_user_param     "${param_prefix}_DISABLE_AFI_P2C_REGISTERS"              boolean   false                            ""                                             ""       ""             ""             DIAG_DISABLE_AFI_P2C_REGISTERS
   add_user_param     "${param_prefix}_AC_PARITY_ERR"                          boolean   false                            ""                                             ""       ""             ""             DIAG_AC_PARITY_ERR    

   add_derived_param  "${param_prefix}_SIM_MEMORY_PRELOAD"            boolean   false         true        ""           ""            ""            DIAG_SIM_MEMORY_PRELOAD
   add_derived_param  "${param_prefix}_SIM_MEMORY_PRELOAD_PRI_EMIF_FILE" string    ""            true        ""           ""            ""            DIAG_SIM_MEMORY_PRELOAD_PRI_EMIF_FILE
   add_derived_param  "${param_prefix}_SIM_MEMORY_PRELOAD_SEC_EMIF_FILE" string    ""            true        ""           ""            ""            DIAG_SIM_MEMORY_PRELOAD_SEC_EMIF_FILE
   add_derived_param  "${param_prefix}_USE_SIM_MEMORY_VALIDATION_TG"  boolean   false         true        ""           ""            ""            DIAG_USE_SIM_MEMORY_VALIDATION_TG
   
   add_user_param         "${param_prefix}_EX_DESIGN_SEPARATE_RZQS" boolean   true                           ""                                            ""       ""             ""             ""
   set_parameter_property "${param_prefix}_EX_DESIGN_SEPARATE_RZQS" VISIBLE   false
   add_user_param         "${param_prefix}_SIM_VERBOSE"             boolean   true                           ""                                            ""       ""             ""             DIAG_SIM_VERBOSE
   set_parameter_property "${param_prefix}_SIM_VERBOSE"             VISIBLE   false
}

proc ::altera_emif::ip_top::diag::add_display_items {tabs} {

   set diag_tab [lindex $tabs 0]

   set family_enum [get_device_family_enum]
   set base_family_enum [enum_data $family_enum BASE_FAMILY_ENUM]

   set sim_grp [get_string GRP_DIAGNOSTICS_SIM_NAME]
   set cal_debug_grp [get_string GRP_DIAGNOSTICS_CAL_DEBUG_NAME]
   set ex_design_grp [get_string GRP_DIAGNOSTICS_EX_DESIGN_NAME]
   set traffic_gen_grp [get_string GRP_DIAGNOSTICS_TRAFFIC_GENERATOR_NAME]
   set performance_grp [get_string GRP_DIAGNOSTICS_PERFORMANCE_NAME]
   set misc_grp [get_string GRP_DIAGNOSTICS_MISC_NAME]
   set internal_grp [get_string GRP_DIAGNOSTICS_INTERNAL_NAME]

   add_group_to_gui $diag_tab $sim_grp
   add_group_to_gui $diag_tab $cal_debug_grp
   add_group_to_gui $diag_tab $ex_design_grp
   add_group_to_gui $diag_tab $traffic_gen_grp
   add_group_to_gui $diag_tab $performance_grp
   add_group_to_gui $diag_tab $misc_grp
   add_group_to_gui $diag_tab $internal_grp

   set internal_params [list \
    DIAG_EXPOSE_RD_TYPE \
    DIAG_SIM_REGTEST_MODE \
    DIAG_TIMING_REGTEST_MODE \
    DIAG_SYNTH_FOR_SIM \
    DIAG_FAST_SIM_OVERRIDE \
    DIAG_VERBOSE_IOAUX \
    DIAG_USE_BOARD_DELAY_MODEL \
    DIAG_BOARD_DELAY_CONFIG_STR \
    DIAG_EXPOSE_DFT_SIGNALS \
    DIAG_ECLIPSE_DEBUG \
    DIAG_EXPORT_VJI \
    DIAG_ENABLE_JTAG_UART \
    DIAG_ENABLE_JTAG_UART_HEX \
    DIAG_ENABLE_HPS_EMIF_DEBUG \
    DIAG_SOFT_NIOS_CLOCK_FREQUENCY \
    DIAG_USE_RS232_UART \
    DIAG_RS232_UART_BAUDRATE \
    DIAG_ECLIPSE_DEBUG \
    DIAG_EXTRA_CONFIGS \
    DIAG_EX_DESIGN_ADD_TEST_EMIFS \
    DIAG_EX_DESIGN_SEPARATE_RESETS]

   foreach param $internal_params {
      add_param_to_gui $internal_grp $param
   }

   if {[::altera_emif::util::qini::ini_is_on "emif_show_internal_settings"]} {
      set_display_item_property $internal_grp               VISIBLE true
      foreach param $internal_params {
         set_parameter_property $param VISIBLE true
      }
   } else {
      set_display_item_property $internal_grp               VISIBLE false
      foreach param $internal_params {
         set_parameter_property $param VISIBLE false
      }
   }
   
   if {[::altera_emif::util::qini::ini_is_on "emif_show_jtag_uart_settings"]} {
      set_display_item_property $internal_grp               VISIBLE true
      set_parameter_property DIAG_ENABLE_JTAG_UART VISIBLE true
      set_parameter_property DIAG_ENABLE_JTAG_UART_HEX VISIBLE true
   }

   if {[::altera_emif::util::qini::ini_is_on "emif_show_early_ready_settings"]} {
       set_parameter_property DIAG_EXPOSE_EARLY_READY  VISIBLE true
       set_parameter_property DIAG_ADD_READY_PIPELINE  VISIBLE true
   } else {
       set_parameter_property DIAG_EXPOSE_EARLY_READY  VISIBLE false
       set_parameter_property DIAG_ADD_READY_PIPELINE  VISIBLE false
   }

   add_param_to_gui $misc_grp SHORT_QSYS_INTERFACE_NAMES
   
   add_param_to_gui $misc_grp DIAG_EXPORT_PLL_LOCKED

   ::altera_emif::ip_top::protocol_expert::add_display_items FUNC_DIAG $tabs

   return 1
}

proc ::altera_emif::ip_top::diag::add_display_items_for_protocol_specific_common_parameters {tabs param_prefix} {

   set diag_tab [lindex $tabs 0]

   set family_enum [get_device_family_enum]
   set base_family_enum [enum_data $family_enum BASE_FAMILY_ENUM]

   set sim_grp [get_string GRP_DIAGNOSTICS_SIM_NAME]
   set cal_debug_grp [get_string GRP_DIAGNOSTICS_CAL_DEBUG_NAME]
   set ex_design_grp [get_string GRP_DIAGNOSTICS_EX_DESIGN_NAME]
   set traffic_gen_grp [get_string GRP_DIAGNOSTICS_TRAFFIC_GENERATOR_NAME]
   set performance_grp [get_string GRP_DIAGNOSTICS_PERFORMANCE_NAME]

   add_param_to_gui $sim_grp "${param_prefix}_SIM_CAL_MODE_ENUM"
   add_param_to_gui $sim_grp "${param_prefix}_ABSTRACT_PHY"
   add_param_to_gui $sim_grp "${param_prefix}_USER_SIM_MEMORY_PRELOAD"
   add_param_to_gui $sim_grp "${param_prefix}_SIM_MEMORY_PRELOAD"
   add_param_to_gui $sim_grp "${param_prefix}_USER_SIM_MEMORY_PRELOAD_PRI_EMIF_FILE"
   add_param_to_gui $sim_grp "${param_prefix}_SIM_MEMORY_PRELOAD_PRI_EMIF_FILE"
   add_param_to_gui $sim_grp "${param_prefix}_USER_SIM_MEMORY_PRELOAD_SEC_EMIF_FILE"
   add_param_to_gui $sim_grp "${param_prefix}_SIM_MEMORY_PRELOAD_SEC_EMIF_FILE"
   add_param_to_gui $sim_grp "${param_prefix}_USER_USE_SIM_MEMORY_VALIDATION_TG"
   add_param_to_gui $sim_grp "${param_prefix}_USE_SIM_MEMORY_VALIDATION_TG"
   add_param_to_gui $sim_grp "${param_prefix}_SIM_VERBOSE"
   
   if {$base_family_enum == "FAMILY_AGILEX"} {
      add_text_to_gui  $ex_design_grp "CAL_DEGUG_MOVED" [get_string TXT_CAL_DEBUG_MOVED_TO_CAL_IP]
      add_param_to_gui $ex_design_grp "${param_prefix}_EXPORT_SEQ_AVALON_SLAVE"
      add_param_to_gui $ex_design_grp "${param_prefix}_INTERFACE_ID"      
   } else {
      add_param_to_gui $cal_debug_grp "${param_prefix}_EXPORT_SEQ_AVALON_SLAVE"
      add_param_to_gui $cal_debug_grp "${param_prefix}_INTERFACE_ID"
   }
   add_param_to_gui $cal_debug_grp "DIAG_SOFT_NIOS_MODE"
   add_param_to_gui $cal_debug_grp "${param_prefix}_EXPORT_SEQ_AVALON_MASTER"
   add_param_to_gui $cal_debug_grp "${param_prefix}_EXPORT_SEQ_AVALON_HEAD_OF_CHAIN"
   add_text_to_gui  $cal_debug_grp "AVL_CHAIN_WARN" [get_string TXT_WARN_AVALON_DAISY_CHAIN]

   add_param_to_gui $ex_design_grp "${param_prefix}_EX_DESIGN_NUM_OF_SLAVES"
   add_param_to_gui $ex_design_grp "${param_prefix}_EX_DESIGN_ISSP_EN"
   add_param_to_gui $performance_grp "${param_prefix}_EFFICIENCY_MONITOR"
   add_param_to_gui $performance_grp "${param_prefix}_USE_NEW_EFFMON_S10"
   add_param_to_gui $performance_grp "${param_prefix}_DISABLE_AFI_P2C_REGISTERS"
   add_param_to_gui $performance_grp "DIAG_EXPOSE_EARLY_READY"
   add_param_to_gui $performance_grp "DIAG_ADD_READY_PIPELINE"
   add_param_to_gui $traffic_gen_grp "${param_prefix}_USE_TG_AVL_2"
   add_param_to_gui $traffic_gen_grp "${param_prefix}_USE_TG_HBM"
   add_param_to_gui $traffic_gen_grp "${param_prefix}_ENABLE_DEFAULT_MODE"
   add_param_to_gui $traffic_gen_grp "${param_prefix}_ENABLE_USER_MODE"
   add_param_to_gui $traffic_gen_grp "${param_prefix}_TG2_TEST_DURATION"
   add_param_to_gui $traffic_gen_grp "${param_prefix}_EXPORT_TG_CFG_AVALON_SLAVE"
   
   return 1
}

proc ::altera_emif::ip_top::diag::validate {} {

   ::altera_emif::ip_top::protocol_expert::validate FUNC_DIAG

   set diag_param_prefix [_get_protocol_specific_param_prefix "DIAG"]
   set phy_param_prefix [_get_protocol_specific_param_prefix "PHY"]
   set mem_param_prefix [_get_protocol_specific_param_prefix "MEM"]


   set sim_cal_mode_enum                [ get_parameter_value "${diag_param_prefix}_SIM_CAL_MODE_ENUM"]
   set sim_memory_preload               [ get_parameter_value "${diag_param_prefix}_USER_SIM_MEMORY_PRELOAD"]
   set sim_memory_preload_pri_emif_file [ get_parameter_value "${diag_param_prefix}_USER_SIM_MEMORY_PRELOAD_PRI_EMIF_FILE"]
   set sim_memory_preload_sec_emif_file [ get_parameter_value "${diag_param_prefix}_USER_SIM_MEMORY_PRELOAD_SEC_EMIF_FILE"]
   set use_sim_memory_validation_tg     [ get_parameter_value "${diag_param_prefix}_USER_USE_SIM_MEMORY_VALIDATION_TG"]
   set sim_verbose                      [ get_parameter_value "${diag_param_prefix}_SIM_VERBOSE"]
   set use_abstract_phy                 [ get_parameter_value "${diag_param_prefix}_ABSTRACT_PHY"]
   set export_seq_avalon_slave          [ get_parameter_value "${diag_param_prefix}_EXPORT_SEQ_AVALON_SLAVE"]
   set export_tg_cfg_avalon_slave       [ get_parameter_value "${diag_param_prefix}_EXPORT_TG_CFG_AVALON_SLAVE"]
   set export_seq_avalon_master         [ get_parameter_value "${diag_param_prefix}_EXPORT_SEQ_AVALON_MASTER"]
   set head_of_chain                    [ get_parameter_value "${diag_param_prefix}_EXPORT_SEQ_AVALON_HEAD_OF_CHAIN"]
   set ex_design_num_of_slaves          [ get_parameter_value "${diag_param_prefix}_EX_DESIGN_NUM_OF_SLAVES"]
   set ex_design_issp_en                [ get_parameter_value "${diag_param_prefix}_EX_DESIGN_ISSP_EN"]
   set efficiency_monitor               [ get_parameter_value "${diag_param_prefix}_EFFICIENCY_MONITOR"]
   set interface_id                     [ get_parameter_value "${diag_param_prefix}_INTERFACE_ID"]
   set use_new_effmon_s10               [ get_parameter_value "${diag_param_prefix}_USE_NEW_EFFMON_S10"]
   set en_default_mode                  [ get_parameter_value "${diag_param_prefix}_ENABLE_DEFAULT_MODE"]
   set en_user_mode                     [ get_parameter_value "${diag_param_prefix}_ENABLE_USER_MODE"]
   set disable_afi_p2c_reg              [ get_parameter_value "${diag_param_prefix}_DISABLE_AFI_P2C_REGISTERS"]
   set core_clks_sharing_enum           [ get_parameter_value "${phy_param_prefix}_CORE_CLKS_SHARING_ENUM"]
   set use_tg_avl_2                     [ get_parameter_value "${diag_param_prefix}_USE_TG_AVL_2"]
   set tg2_test_duration                [ get_parameter_value "${diag_param_prefix}_TG2_TEST_DURATION"]
   set use_tg_hbm                       [ get_parameter_value "${diag_param_prefix}_USE_TG_HBM"]
   set use_ac_err                       [ get_parameter_value "${diag_param_prefix}_AC_PARITY_ERR"]
   set use_soft_nios                    [ expr {[ get_parameter_value "DIAG_SOFT_NIOS_MODE"] != "SOFT_NIOS_MODE_DISABLED"}]
   
   set protocol_enum  [get_parameter_value "PROTOCOL_ENUM"]
   set config_enum [get_parameter_value "PHY_CONFIG_ENUM"]
   set ping_pong_en [get_parameter_value "PHY_PING_PONG_EN"]
   set ecc_en [get_parameter_value "CTRL_ECC_EN"]

   set support_sim_memory_preload [get_feature_support_level FEATURE_SIM_MEMORY_PRELOAD $protocol_enum]
   set support_abstract_phy [get_feature_support_level FEATURE_ABSTRACT_PHY $protocol_enum]
   set support_ac_err [expr [get_feature_support_level FEATURE_AC_PARITY_ERR $protocol_enum]]

   set family [get_parameter_value SYS_INFO_DEVICE_FAMILY]
   set ioaux_verbose [get_parameter_value "DIAG_VERBOSE_IOAUX"]
   set family_enum [get_device_family_enum]
   set base_family_enum [enum_data $family_enum BASE_FAMILY_ENUM]
   
   set show_tg_avl_2 [expr {((($base_family_enum == "FAMILY_AGILEX" || $family=="Stratix 10") && $protocol_enum == "PROTOCOL_DDR4" && !$ping_pong_en && $config_enum != "CONFIG_PHY_ONLY") || [::altera_emif::util::qini::ini_is_on "enable_tg_avl_2"] || $protocol_enum == "PROTOCOL_DDRT")?"true":"false"}]
   
   set show_use_new_effmon_s10 [expr {($family=="Stratix 10" && $protocol_enum == "PROTOCOL_DDR4" && $efficiency_monitor != "EFFMON_MODE_DISABLED" && !$ping_pong_en)? "true":"false"}]
 
   if {[get_parameter_value "DIAG_ADD_READY_PIPELINE"] == "false"} {
       set_parameter_property "DIAG_EXPOSE_EARLY_READY" ENABLED false
   } else {
       set_parameter_property "DIAG_EXPOSE_EARLY_READY" ENABLED true
   }

   set_parameter_property "${diag_param_prefix}_EX_DESIGN_NUM_OF_SLAVES" ENABLED [expr {$core_clks_sharing_enum != "CORE_CLKS_SHARING_DISABLED"}]
   if {$export_seq_avalon_slave == "CAL_DEBUG_EXPORT_MODE_DISABLED"} {
      set_parameter_property "${diag_param_prefix}_EXPORT_SEQ_AVALON_MASTER" ENABLED false
      set export_seq_avalon_master 0
      set_parameter_property "${diag_param_prefix}_EXPORT_SEQ_AVALON_HEAD_OF_CHAIN" VISIBLE false
      set_display_item_property TEXT_AVL_CHAIN_WARN   VISIBLE false

       if {$protocol_enum != "PROTOCOL_DDRT"} { 
	   set_parameter_property "${diag_param_prefix}_INTERFACE_ID" ENABLED false
       }
  
   } else {
      set_parameter_property "${diag_param_prefix}_EXPORT_SEQ_AVALON_MASTER" ENABLED true
      if { $family == "Stratix 10" } {
         set_parameter_property "${diag_param_prefix}_EXPORT_SEQ_AVALON_HEAD_OF_CHAIN" VISIBLE true
         set_display_item_property TEXT_AVL_CHAIN_WARN   VISIBLE true
      }
      set_parameter_property "${diag_param_prefix}_INTERFACE_ID" ENABLED true
   }
   
   if {($base_family_enum == "FAMILY_AGILEX" && $protocol_enum == "PROTOCOL_DDR4" && $config_enum != "CONFIG_PHY_ONLY") || $family=="Arria 10" || $family=="Stratix 10" || $family=="Cyclone 10 GX"} {
      set_parameter_property  "${diag_param_prefix}_EFFICIENCY_MONITOR" ENABLED true
   } else {
      set_parameter_property  "${diag_param_prefix}_EFFICIENCY_MONITOR" ENABLED false
      set efficiency_monitor  "EFFMON_MODE_DISABLED"
   }
   
   if {$show_use_new_effmon_s10} {
      set_parameter_property "${diag_param_prefix}_USE_NEW_EFFMON_S10" VISIBLE true
   } else {
      set_parameter_property "${diag_param_prefix}_USE_NEW_EFFMON_S10" VISIBLE false
      set use_new_effmon_s10 "false"
   }

   if {$show_tg_avl_2} { 
       set_parameter_property "${diag_param_prefix}_USE_TG_AVL_2" ENABLED true
   } else {
       set_parameter_property "${diag_param_prefix}_USE_TG_AVL_2" ENABLED false
       set use_tg_avl_2 "false"
   }
   set enable_user_mode $show_tg_avl_2
   set ddrt_beta [ini_is_on "ddrt_beta"]
   if {$protocol_enum == "PROTOCOL_DDRT"} {
      set enable_user_mode false
   }
   set_parameter_property   "${diag_param_prefix}_ENABLE_DEFAULT_MODE"          ENABLED   $use_tg_avl_2
   set_parameter_property   "${diag_param_prefix}_ENABLE_USER_MODE"             ENABLED   $use_tg_avl_2
   set_parameter_property   "${diag_param_prefix}_TG2_TEST_DURATION"            ENABLED   $use_tg_avl_2
   set_parameter_property   "${diag_param_prefix}_EXPORT_TG_CFG_AVALON_SLAVE"   ENABLED   $use_tg_avl_2

   set_parameter_property   "${diag_param_prefix}_USE_TG_AVL_2"                 VISIBLE   $show_tg_avl_2
   set_parameter_property   "${diag_param_prefix}_ENABLE_DEFAULT_MODE"          VISIBLE   $show_tg_avl_2
   set_parameter_property   "${diag_param_prefix}_ENABLE_USER_MODE"             VISIBLE   [expr {$enable_user_mode || $ddrt_beta}]
   set_parameter_property   "${diag_param_prefix}_TG2_TEST_DURATION"            VISIBLE   $show_tg_avl_2
   set_parameter_property   "${diag_param_prefix}_EXPORT_TG_CFG_AVALON_SLAVE"   VISIBLE   $show_tg_avl_2

   if {$show_tg_avl_2 && [::altera_emif::util::qini::ini_is_on "emif_show_internal_settings"]} {
      set_parameter_property "${diag_param_prefix}_DISABLE_AFI_P2C_REGISTERS" VISIBLE true
   } else {
      set_parameter_property "${diag_param_prefix}_DISABLE_AFI_P2C_REGISTERS" VISIBLE false
   }

   set_parameter_property   "${diag_param_prefix}_USE_TG_HBM"                   VISIBLE   false
   set $use_tg_hbm false

   if {[get_is_hps] && ![::altera_emif::util::qini::ini_is_on "emif_enable_dynamic_reconfig_hps"] } {
      post_ipgen_i_msg MSG_DEBUG_NOT_SUPPORTED_FOR_HPS
      set_parameter_property "${diag_param_prefix}_EXPORT_SEQ_AVALON_SLAVE" ENABLED false
      set_parameter_property "${diag_param_prefix}_EXPORT_SEQ_AVALON_MASTER" ENABLED false
      set_parameter_property "${diag_param_prefix}_INTERFACE_ID" ENABLED false
      set_parameter_property "DIAG_SOFT_NIOS_MODE" ENABLED false
      set_parameter_property "${diag_param_prefix}_EXPORT_TG_CFG_AVALON_SLAVE" ENABLED false
   }

   if {[get_is_hps]} {
      set_parameter_property "${diag_param_prefix}_EX_DESIGN_ISSP_EN" ENABLED false
      if {$base_family_enum == "FAMILY_AGILEX"} {
         set_parameter_property "${diag_param_prefix}_EFFICIENCY_MONITOR" ENABLED false
      }
   }

   if {[get_is_hps]} {
      if {$base_family_enum == "FAMILY_ARRIA10"} {
         set_display_item_property DIAG_EXPORT_PLL_LOCKED   VISIBLE false
      } else {
         set misc_grp [get_string GRP_DIAGNOSTICS_MISC_NAME]
         set_display_item_property $misc_grp   VISIBLE false
      }
   }

   if {$config_enum == "CONFIG_PHY_ONLY" && $efficiency_monitor != "EFFMON_MODE_DISABLED"} {
      post_ipgen_e_msg MSG_EFFICIENCY_MONITOR_NOT_SUPPORTED_FOR_PHY_ONLY
   }
   
   if {$config_enum == "CONFIG_PHY_AND_SOFT_CTRL"} {
      set_parameter_property "${diag_param_prefix}_EFFICIENCY_MONITOR" ENABLED false
   }

   if {$en_default_mode == "false" && $en_user_mode == "false"} {
      post_ipgen_e_msg MSG_TG_AVL_2_CANNOT_DISABLE_ALL_MODES
   }

   if {[get_parameter_value DIAG_ENABLE_JTAG_UART] == "false" && [get_parameter_value DIAG_ENABLE_JTAG_UART_HEX] == "true"} {
      post_ipgen_w_msg MSG_JTAG_UART_PARAMETER_MISMATCH
   }

   if {[get_parameter_value DIAG_ENABLE_JTAG_UART] == "true" && [get_parameter_value DIAG_ENABLE_HPS_EMIF_DEBUG] == "true"} {
      post_ipgen_e_msg MSG_HPS_ILLEGAL_DEBUG_CONFIGURATION
   }
   
   if {$tg2_test_duration == "INFINITE" && $en_default_mode == "true"} {
      post_ipgen_w_msg MSG_TG_AVL_2_CAN_NOT_ENTER_USER_MODE_FOR_INFINITE_TEST_DURATION 
   }
   
   if {$en_default_mode == "false"} {
      set_parameter_property "${diag_param_prefix}_TG2_TEST_DURATION" ENABLED false
   }

   if {$use_soft_nios && $export_seq_avalon_slave == "CAL_DEBUG_EXPORT_MODE_DISABLED"} {
      post_ipgen_e_msg MSG_SOFT_NIOS_REQUIRES_ON_CHIP_DEBUG_PORT
   }

   if {!$support_abstract_phy} {
      set_parameter_property "${diag_param_prefix}_ABSTRACT_PHY" VISIBLE false
   } else {
      set_parameter_property "${diag_param_prefix}_ABSTRACT_PHY" VISIBLE true
   }
   if {$use_abstract_phy} {
      if {$sim_cal_mode_enum != "SIM_CAL_MODE_SKIP"} {
         post_ipgen_e_msg MSG_ABSTRACT_PHY_SUPPORTED_ONLY_FOR_SKIP_CAL
      }
   }

   if {[get_family_trait FAMILY_TRAIT_SUPPORT_DISABLE_SIM_VERBOSE]} {
      set_parameter_property "${diag_param_prefix}_SIM_VERBOSE" VISIBLE true
   }

   if {$base_family_enum == "FAMILY_AGILEX" && [get_parameter_value DIAG_SIM_CAL_MODE_ENUM] == "SIM_CAL_MODE_FULL"} {
      post_ipgen_w_msg "For 'Full Calibration' simulations, compiler directive \"EMIF_DISABLE_CAL_OPTIMIZATIONS\" must be defined in the simulation script"
   }

   if {!$support_ac_err} {
      set_parameter_property "${diag_param_prefix}_AC_PARITY_ERR" VISIBLE false 
      set use_ac_err false
   } else {
      set_parameter_property "${diag_param_prefix}_AC_PARITY_ERR" VISIBLE true 
      set use_ac_parity_latency            [ expr {[ get_parameter_value "${mem_param_prefix}_AC_PARITY_LATENCY" ] != "DDR4_AC_PARITY_LATENCY_DISABLE"}]
      if {!$use_ac_parity_latency && $use_ac_err} {
         post_ipgen_e_msg  MSG_AC_PARITY_LATENCY_MUST_BE_ENABLED_TO_EXPORT_AC_ERR_PORT
      }
   }


   set sim_memory_preload_pri_ecc_file ""
   set sim_memory_preload_sec_ecc_file ""
   set sim_memory_preload_pri_mem_file ""
   set sim_memory_preload_sec_mem_file ""
   set sim_memory_preload_pri_abphy_file ""
   set sim_memory_preload_sec_abphy_file ""
   set sim_memory_preload_emif_config_supported [expr {$config_enum == "CONFIG_PHY_AND_HARD_CTRL"}]
   set show_sim_memory_preload                  [::altera_emif::util::qini::ini_is_on "emif_enable_sim_memory_preload"]
   set show_sim_memory_validation_tg            [::altera_emif::util::qini::ini_is_on "emif_enable_sim_memory_preload"]
   if {$support_sim_memory_preload && $sim_memory_preload_emif_config_supported} {
      set_parameter_property "${diag_param_prefix}_USER_SIM_MEMORY_PRELOAD" VISIBLE $show_sim_memory_preload
      set_parameter_property "${diag_param_prefix}_SIM_MEMORY_PRELOAD" VISIBLE false
      set sim_memory_preload [get_parameter_value "${diag_param_prefix}_USER_SIM_MEMORY_PRELOAD"]

      set enable_sim_memory_preload_pri_emif_file $sim_memory_preload
      set_parameter_property "${diag_param_prefix}_USER_SIM_MEMORY_PRELOAD_PRI_EMIF_FILE" VISIBLE [expr {$show_sim_memory_preload && $enable_sim_memory_preload_pri_emif_file}]
      set_parameter_property "${diag_param_prefix}_SIM_MEMORY_PRELOAD_PRI_EMIF_FILE"      VISIBLE [expr {$show_sim_memory_preload && !$enable_sim_memory_preload_pri_emif_file}]
      set sim_memory_preload_pri_emif_file  [get_parameter_value "${diag_param_prefix}_USER_SIM_MEMORY_PRELOAD_PRI_EMIF_FILE"]
      set sim_memory_preload_pri_ecc_file   "ECC_${sim_memory_preload_pri_emif_file}"
      set sim_memory_preload_pri_mem_file   "MEM_${sim_memory_preload_pri_emif_file}"
      set sim_memory_preload_pri_abphy_file "ABPHY_${sim_memory_preload_pri_emif_file}"

      set enable_sim_memory_preload_sec_emif_file [expr {$sim_memory_preload && $ping_pong_en}]
      set_parameter_property "${diag_param_prefix}_USER_SIM_MEMORY_PRELOAD_SEC_EMIF_FILE" VISIBLE [expr {$show_sim_memory_preload && $enable_sim_memory_preload_sec_emif_file}]
      set_parameter_property "${diag_param_prefix}_SIM_MEMORY_PRELOAD_SEC_EMIF_FILE"      VISIBLE [expr {$show_sim_memory_preload && !$enable_sim_memory_preload_sec_emif_file}]
      set sim_memory_preload_sec_emif_file  [get_parameter_value "${diag_param_prefix}_USER_SIM_MEMORY_PRELOAD_SEC_EMIF_FILE"]
      set sim_memory_preload_sec_ecc_file   "ECC_${sim_memory_preload_sec_emif_file}"
      set sim_memory_preload_sec_mem_file   "MEM_${sim_memory_preload_sec_emif_file}"
      set sim_memory_preload_sec_abphy_file "ABPHY_${sim_memory_preload_sec_emif_file}"

      set enable_use_sim_memory_validation_tg [expr {$sim_memory_preload && !$use_tg_avl_2}]
      set_parameter_property "${diag_param_prefix}_USER_USE_SIM_MEMORY_VALIDATION_TG" VISIBLE [expr {$show_sim_memory_preload && $show_sim_memory_validation_tg && $enable_use_sim_memory_validation_tg}]
      set_parameter_property "${diag_param_prefix}_USE_SIM_MEMORY_VALIDATION_TG"      VISIBLE [expr {$show_sim_memory_preload && $show_sim_memory_validation_tg && !$enable_use_sim_memory_validation_tg}]
      set use_sim_memory_validation_tg [expr {($show_sim_memory_preload && $show_sim_memory_validation_tg && $enable_use_sim_memory_validation_tg) ? [get_parameter_value "${diag_param_prefix}_USER_USE_SIM_MEMORY_VALIDATION_TG"] : false}]

      if {$sim_memory_preload && $ecc_en} {
         post_ipgen_i_msg MSG_PRELOAD_ECC_MUST_ENABLE_ALL_BYTEENABLE
      }
   } else {
      set sim_memory_preload_visibility [expr {$support_sim_memory_preload && $show_sim_memory_preload}]

      set_parameter_property "${diag_param_prefix}_USER_SIM_MEMORY_PRELOAD"               VISIBLE false
      set_parameter_property "${diag_param_prefix}_USER_SIM_MEMORY_PRELOAD_PRI_EMIF_FILE" VISIBLE false
      set_parameter_property "${diag_param_prefix}_USER_SIM_MEMORY_PRELOAD_SEC_EMIF_FILE" VISIBLE false
      set_parameter_property "${diag_param_prefix}_USER_USE_SIM_MEMORY_VALIDATION_TG"     VISIBLE false

      set_parameter_property "${diag_param_prefix}_SIM_MEMORY_PRELOAD"               VISIBLE $sim_memory_preload_visibility
      set_parameter_property "${diag_param_prefix}_SIM_MEMORY_PRELOAD_PRI_EMIF_FILE" VISIBLE $sim_memory_preload_visibility
      set_parameter_property "${diag_param_prefix}_SIM_MEMORY_PRELOAD_SEC_EMIF_FILE" VISIBLE $sim_memory_preload_visibility
      set_parameter_property "${diag_param_prefix}_USE_SIM_MEMORY_VALIDATION_TG"     VISIBLE $sim_memory_preload_visibility

      set sim_memory_preload false
      set sim_memory_preload_pri_emif_file ""
      set sim_memory_preload_sec_emif_file ""
      set use_sim_memory_validation_tg false
   }

   set_parameter_value DIAG_SIM_CAL_MODE_ENUM $sim_cal_mode_enum
   set_parameter_value DIAG_EXPORT_SEQ_AVALON_SLAVE $export_seq_avalon_slave
   set_parameter_value DIAG_EXPORT_SEQ_AVALON_MASTER $export_seq_avalon_master
   set_parameter_value DIAG_EX_DESIGN_NUM_OF_SLAVES $ex_design_num_of_slaves
   set_parameter_value DIAG_EX_DESIGN_ISSP_EN $ex_design_issp_en
   set_parameter_value DIAG_EXPORT_SEQ_AVALON_HEAD_OF_CHAIN $head_of_chain
   set_parameter_value DIAG_INTERFACE_ID $interface_id
   set_parameter_value DIAG_EFFICIENCY_MONITOR $efficiency_monitor
   set_parameter_value DIAG_USE_NEW_EFFMON_S10 $use_new_effmon_s10
   set_parameter_value DIAG_USE_TG_AVL_2 $use_tg_avl_2
   set_parameter_value DIAG_USE_TG_HBM $use_tg_hbm
   set_parameter_value DIAG_AC_PARITY_ERR $use_ac_err 
   set_parameter_value DIAG_ENABLE_DEFAULT_MODE $en_default_mode
   set_parameter_value DIAG_ENABLE_USER_MODE $en_user_mode
   set_parameter_value DIAG_EXPORT_TG_CFG_AVALON_SLAVE $export_tg_cfg_avalon_slave
   set_parameter_value DIAG_TG2_TEST_DURATION $tg2_test_duration
   set_parameter_value DIAG_DISABLE_AFI_P2C_REGISTERS $disable_afi_p2c_reg
   set_parameter_value DIAG_USE_ABSTRACT_PHY [expr {$use_abstract_phy && $support_abstract_phy}]
   set_parameter_value DIAG_SIM_MEMORY_PRELOAD $sim_memory_preload
   set_parameter_value DIAG_SIM_MEMORY_PRELOAD_PRI_EMIF_FILE $sim_memory_preload_pri_emif_file
   set_parameter_value DIAG_SIM_MEMORY_PRELOAD_SEC_EMIF_FILE $sim_memory_preload_sec_emif_file
   set_parameter_value DIAG_SIM_MEMORY_PRELOAD_PRI_ECC_FILE $sim_memory_preload_pri_ecc_file
   set_parameter_value DIAG_SIM_MEMORY_PRELOAD_SEC_ECC_FILE $sim_memory_preload_sec_ecc_file
   set_parameter_value DIAG_SIM_MEMORY_PRELOAD_PRI_MEM_FILE $sim_memory_preload_pri_mem_file
   set_parameter_value DIAG_SIM_MEMORY_PRELOAD_SEC_MEM_FILE $sim_memory_preload_sec_mem_file
   set_parameter_value DIAG_SIM_MEMORY_PRELOAD_PRI_ABPHY_FILE $sim_memory_preload_pri_abphy_file
   set_parameter_value DIAG_SIM_MEMORY_PRELOAD_SEC_ABPHY_FILE $sim_memory_preload_sec_abphy_file
   set_parameter_value DIAG_USE_SIM_MEMORY_VALIDATION_TG $use_sim_memory_validation_tg

   set force_no_soft_m20k [::altera_emif::util::qini::ini_is_on "emif_force_no_soft_m20k"]
   set device_supports_soft_m20k [get_feature_support_level FEATURE_SEQ_SOFT_M20K PROTOCOL_INVALID]
   set_parameter_value DIAG_ENABLE_SOFT_M20K [expr {$device_supports_soft_m20k && !$force_no_soft_m20k}]

   if {[string compare -nocase [get_parameter_value DIAG_FAST_SIM_OVERRIDE] "FAST_SIM_OVERRIDE_ENABLED"] == 0} {
      set_parameter_value DIAG_FAST_SIM true
   } elseif {[string compare -nocase [get_parameter_value DIAG_FAST_SIM_OVERRIDE] "FAST_SIM_OVERRIDE_DISABLED"] == 0} {
      set_parameter_value DIAG_FAST_SIM false
   } else {

      if {[get_parameter_value PLL_NUM_OF_EXTRA_CLKS] > 0 } {

         set_parameter_value DIAG_FAST_SIM false
         post_ipgen_i_msg MSG_FAST_SIM_DISABLED_BY_EXTRA_CORE_CLKS

      } elseif {$sim_cal_mode_enum != "SIM_CAL_MODE_SKIP"} {

         set_parameter_value DIAG_FAST_SIM false
         post_ipgen_i_msg MSG_FAST_SIM_DISABLED_BY_NON_SKIP_CAL

      } else {
         set_parameter_value DIAG_FAST_SIM true
      }
   }
   
   if {$ioaux_verbose} {
      set_parameter_value DIAG_SIM_VERBOSE_LEVEL 5
   } else {
      if {$sim_verbose} {
         set_parameter_value DIAG_SIM_VERBOSE_LEVEL 5
      } else {
         set_parameter_value DIAG_SIM_VERBOSE_LEVEL 0
      }
   }

   set_parameter_property "${diag_param_prefix}_SEPARATE_READ_WRITE_ITFS" VISIBLE false

   set_parameter_value DIAG_SIM_CHECKER_SKIP_TG [get_parameter_value DIAG_DDR3_CAL_ENABLE_MICRON_AP]


   return 1

}


proc ::altera_emif::ip_top::diag::_get_protocol_specific_param_prefix {package_prefix} {
   set protocol_enum  [get_parameter_value "PROTOCOL_ENUM"]
   set module_name    [string toupper [enum_data $protocol_enum MODULE_NAME]]
   return "${package_prefix}_${module_name}"
}

proc ::altera_emif::ip_top::diag::_init {} {
}

::altera_emif::ip_top::diag::_init

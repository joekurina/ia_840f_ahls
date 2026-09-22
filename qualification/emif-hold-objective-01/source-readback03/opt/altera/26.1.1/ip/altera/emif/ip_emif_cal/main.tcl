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


package provide altera_emif::ip_emif_cal::main 0.1

package require altera_emif::util::messaging
package require altera_emif::util::qini
package require altera_emif::util::hwtcl_utils
package require altera_emif::util::enums
package require altera_emif::util::enum_defs
package require altera_emif::util::arch_expert
package require altera_emif::util::device_family

namespace eval ::altera_emif::ip_emif_cal::main:: {

   namespace import ::altera_emif::util::messaging::*
   namespace import ::altera_emif::util::qini::*
   namespace import ::altera_emif::util::enums::*
   namespace import ::altera_emif::util::hwtcl_utils::*
   namespace import ::altera_emif::util::device_family::*

}

proc ::altera_emif::ip_emif_cal::main::composition_callback {} {
   _compose
}

proc ::altera_emif::ip_emif_cal::main::create_parameters {} {
   add_user_param     AXM_ID_NUM                         integer   0                                 {0:63}                                        ""    ""           ""             ""
   add_user_param     NUM_CALBUS_INTERFACE               string    1                              [list  1 2 3 4 5 6 7 8 9 10 11 12 13 14 15]    ""       ""             ""             ""
   add_user_param     DIAG_SIM_CAL_MODE_ENUM             string    SIM_CAL_MODE_SKIP              [enum_dropdown_entries SIM_CAL_MODE]           ""       ""             ""             DIAG_SIM_CAL_MODE_ENUM
   add_user_param     DIAG_EXPORT_SEQ_AVALON_SLAVE       string    CAL_DEBUG_EXPORT_MODE_DISABLED [enum_dropdown_entries CAL_DEBUG_EXPORT_MODE]  ""       ""             ""             DIAG_EXPORT_SEQ_AVALON_SLAVE
   add_user_param     DIAG_SIM_VERBOSE                   boolean   false                           ""                                            ""       ""             ""             DIAG_SIM_VERBOSE

   add_user_param     ENABLE_DDRT                        boolean   false                           ""                                            ""       ""             ""             ENABLE_DDRT

   add_user_param     DIAG_SYNTH_FOR_SIM          boolean  false     ""               ""
   add_user_param     DIAG_EXTRA_CONFIGS          string   ""        ""               ""
   add_user_param     DIAG_EXPORT_VJI             boolean  false     ""               ""
   add_user_param     SHORT_QSYS_INTERFACE_NAMES  boolean  true      ""               ""
   add_user_param     DIAG_ENABLE_JTAG_UART       boolean  false     ""               ""       ""             ""             DIAG_ENABLE_JTAG_UART
   add_user_param     PHY_DDRT_EXPORT_CLK_STP_IF  boolean  false     ""               ""

   add_display_items
   validate 
}

proc ::altera_emif::ip_emif_cal::main::validate {} {
   set internal_params [list DIAG_SYNTH_FOR_SIM DIAG_EXPORT_VJI  SHORT_QSYS_INTERFACE_NAMES] 

   if {[::altera_emif::util::qini::ini_is_on "emif_enable_ddrt_gen"]} {
      set_parameter_property AXM_ID_NUM VISIBLE true
      set_parameter_property PHY_DDRT_EXPORT_CLK_STP_IF VISIBLE true
      set_parameter_property ENABLE_DDRT VISIBLE true
   } else {
      set_parameter_property AXM_ID_NUM VISIBLE false
      set_parameter_property PHY_DDRT_EXPORT_CLK_STP_IF VISIBLE false
      set_parameter_property ENABLE_DDRT VISIBLE false
   }

   if {[::altera_emif::util::qini::ini_is_on "emif_show_internal_settings"]} {
      foreach param $internal_params {
         set_parameter_property $param VISIBLE true
      }
   } else {
      foreach param $internal_params {
         set_parameter_property $param VISIBLE false
      }
   }
}


proc ::altera_emif::ip_emif_cal::main::add_display_items {} {
   

   set cal_grp         "Calibration and Debug"
   add_display_item    ""     $cal_grp        GROUP
   set cal_params      [list  NUM_CALBUS_INTERFACE \
                              DIAG_EXPORT_SEQ_AVALON_SLAVE \
                       ]   
   foreach param $cal_params {
      add_param_to_gui $cal_grp $param
   }
   
   set sim_grp         "Simulation"
   add_display_item    ""     $sim_grp        GROUP
   set sim_params      [list  DIAG_SYNTH_FOR_SIM \
                              DIAG_SIM_CAL_MODE_ENUM \
                              DIAG_SIM_VERBOSE \
                       ] 
   foreach param $sim_params {
      add_param_to_gui $sim_grp $param
   }


   set internal_grp    "Internal"
   add_display_item    ""    $internal_grp   GROUP
   set internal_params [list DIAG_EXTRA_CONFIGS \
                             DIAG_EXPORT_VJI \
                             SHORT_QSYS_INTERFACE_NAMES \
                             DIAG_ENABLE_JTAG_UART \
                       ] 
   foreach param $internal_params {
      add_param_to_gui $internal_grp $param
   }

   if {[::altera_emif::util::qini::ini_is_on "emif_show_internal_settings"]} {
      set_display_item_property $internal_grp               VISIBLE true
   } else {
      set_display_item_property $internal_grp               VISIBLE false
   }
   return 1
}

proc ::altera_emif::ip_emif_cal::main::_compose {} {
   set cal_param_names  [list DIAG_SIM_CAL_MODE_ENUM       \
                              DIAG_EXTRA_CONFIGS           \
                              DIAG_EXPORT_VJI              \
                              DIAG_SYNTH_FOR_SIM           \
                              SHORT_QSYS_INTERFACE_NAMES   \
                              DIAG_EXPORT_SEQ_AVALON_SLAVE \
                              DIAG_ENABLE_JTAG_UART        \
                         ] 
						 
   set emif_cal "emif_cal"
   add_instance $emif_cal altera_emif_cal_iossm
   set_instance_parameter_value $emif_cal NUM_CALBUS_INTERFACE [get_parameter_value NUM_CALBUS_INTERFACE]
   foreach param_name $cal_param_names {
      set_instance_parameter_value $emif_cal $param_name [get_parameter_value $param_name]
   }

   if {[get_parameter_value "ENABLE_DDRT"] == true} {
      set_instance_parameter_value $emif_cal ENABLE_DDRT true


      set clk_bridge "clk_bridge"
      add_instance $clk_bridge altera_clock_bridge
      set_instance_parameter_value $clk_bridge NUM_CLOCK_OUTPUTS 1

      add_interface cal_debug_clk clock sink
      set_interface_property cal_debug_clk EXPORT_OF clk_bridge.in_clk

      set rst_bridge "rst_bridge"
      add_instance $rst_bridge altera_reset_bridge
      set_instance_parameter_value $rst_bridge NUM_RESET_OUTPUTS 1
      add_connection ${clk_bridge}.out_clk   ${rst_bridge}.clk

      add_interface cal_debug_reset_n reset sink
      set_interface_property cal_debug_reset_n EXPORT_OF ${rst_bridge}.in_reset

      set ddrt_clk_stopper "ddrt_clk_stopper"
      add_instance $ddrt_clk_stopper altera_emif_ddrt_clk_stopper_fm
      add_connection ${clk_bridge}.out_clk ${ddrt_clk_stopper}.clock
      add_connection ${rst_bridge}.out_reset ${ddrt_clk_stopper}.reset_n

      add_interface afi_mem_clk_disable conduit end
      set_interface_property afi_mem_clk_disable EXPORT_OF "${ddrt_clk_stopper}.afi_mem_clk_disable"
      if {[get_parameter_value "PHY_DDRT_EXPORT_CLK_STP_IF"] == true} {
         set_instance_parameter_value $ddrt_clk_stopper "EXPORT_CLK_STP_IF" 1
         add_interface afi_mem_clk_disable_out conduit end
         set_interface_property afi_mem_clk_disable_out EXPORT_OF "${ddrt_clk_stopper}.afi_mem_clk_disable_out"
      } else {
         set_instance_parameter_value $ddrt_clk_stopper "EXPORT_CLK_STP_IF" 0
      }

      add_connection ${clk_bridge}.out_clk ${emif_cal}.cal_debug_clk
      add_connection ${rst_bridge}.out_reset ${emif_cal}.cal_debug_reset_n

      if {[get_parameter_value DIAG_EXPORT_SEQ_AVALON_SLAVE] == "CAL_DEBUG_EXPORT_MODE_JTAG"} {
         set JTAG_MASTER "jtag_master"

	 add_instance $JTAG_MASTER alt_mem_if_jtag_master
	 set_instance_parameter_value $JTAG_MASTER USE_PLI "0"
	 set_instance_parameter_value $JTAG_MASTER PLI_PORT "50000"

	 add_connection ${clk_bridge}.out_clk ${JTAG_MASTER}.clk
	 add_connection ${rst_bridge}.out_reset ${JTAG_MASTER}.clk_reset
      }


      set ddrt_arbiter "ddrt_arbiter"
      add_instance $ddrt_arbiter altera_emif_ddrt_arbiter
      add_connection ${clk_bridge}.out_clk ${ddrt_arbiter}.clock
      add_connection ${rst_bridge}.out_reset ${ddrt_arbiter}.reset_n
      add_connection ${ddrt_clk_stopper}.avl_to_iossm ${ddrt_arbiter}.arbiter_clk_stopper
      add_connection ${ddrt_arbiter}.arbiter_cal_debug ${emif_cal}.cal_debug

      if {[get_parameter_value DIAG_EXPORT_SEQ_AVALON_SLAVE] == "CAL_DEBUG_EXPORT_MODE_JTAG"} {
	 add_connection ${JTAG_MASTER}.master   ${ddrt_arbiter}.arbiter_jtag
	 set_connection_parameter_value "${JTAG_MASTER}.master/${ddrt_arbiter}.arbiter_jtag" arbitrationPriority "1"
	 set_connection_parameter_value "${JTAG_MASTER}.master/${ddrt_arbiter}.arbiter_jtag" baseAddress "0x0000"

         set_instance_parameter_value $ddrt_arbiter JTAG_EN 1
      }


      set axm_id_num [get_parameter_value AXM_ID_NUM]
      set smc_conn "altera_ddrt_ddrt_smc_cal_master_avl_to_axi"
      add_instance $smc_conn altera_ddrt_ddrt_smc_cal_master_avl_to_axi
      set_instance_parameter_value $smc_conn AXM_ID_NUM $axm_id_num

      add_connection ${clk_bridge}.out_clk "${smc_conn}.clock"
      add_connection ${rst_bridge}.out_reset "${smc_conn}.reset"

      add_connection ${smc_conn}.avl_to_iossm ${ddrt_arbiter}.arbiter_smc

      set smc_axi_if "axi4_to_smc_core"
      add_interface $smc_axi_if axi4 start
      set_interface_property $smc_axi_if EXPORT_OF "${smc_conn}.${smc_axi_if}"

      add_interface axi_clk clock Output
      set_interface_property axi_clk EXPORT_OF "${smc_conn}.axi_clk"
      add_interface axi_rst reset Output
      set_interface_property axi_rst EXPORT_OF "${smc_conn}.axi_rst"


   } elseif {[get_parameter_value DIAG_EXPORT_SEQ_AVALON_SLAVE] == "CAL_DEBUG_EXPORT_MODE_JTAG"} {
      set JTAG_MASTER "jtag_master"
      add_instance $JTAG_MASTER alt_mem_if_jtag_master
      set_instance_parameter_value $JTAG_MASTER USE_PLI "0"
      set_instance_parameter_value $JTAG_MASTER PLI_PORT "50000"
           
      set clk_bridge "clk_bridge"
      add_instance $clk_bridge altera_clock_bridge
      set_instance_parameter_value $clk_bridge NUM_CLOCK_OUTPUTS 1
            
      add_interface cal_debug_clk clock sink
      set_interface_property cal_debug_clk EXPORT_OF clk_bridge.in_clk
            
      set rst_bridge "rst_bridge"
      add_instance $rst_bridge altera_reset_bridge
      set_instance_parameter_value $rst_bridge NUM_RESET_OUTPUTS 1
      add_connection ${clk_bridge}.out_clk   ${rst_bridge}.clk
            
      add_interface cal_debug_reset_n reset sink
      set_interface_property cal_debug_reset_n EXPORT_OF ${rst_bridge}.in_reset
           
      add_connection ${clk_bridge}.out_clk ${emif_cal}.cal_debug_clk
      add_connection ${clk_bridge}.out_clk ${JTAG_MASTER}.clk
           
      add_connection ${rst_bridge}.out_reset ${emif_cal}.cal_debug_reset_n
      add_connection ${rst_bridge}.out_reset ${JTAG_MASTER}.clk_reset
           
      add_connection ${JTAG_MASTER}.master   ${emif_cal}.cal_debug
      set_connection_parameter_value "${JTAG_MASTER}.master/${emif_cal}.cal_debug" arbitrationPriority "1"
      set_connection_parameter_value "${JTAG_MASTER}.master/${emif_cal}.cal_debug" baseAddress "0x0000"
   }
   
   altera_emif::util::hwtcl_utils::export_unconnected_interfaces_of_sub_component $emif_cal

}



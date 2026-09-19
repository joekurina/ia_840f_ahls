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


package provide intel_pcie_ss_axi::interfaces 19.1
package require alt_xcvr::ip_tcl::ip_module
package require alt_xcvr::ip_tcl::ip_interfaces
package require alt_xcvr::ip_tcl::messages

namespace eval ::intel_pcie_ss_axi::interfaces:: {

    namespace import ::alt_xcvr::ip_tcl::ip_module::*
    namespace import ::alt_xcvr::ip_tcl::ip_interfaces::*
    namespace import ::alt_xcvr::ip_tcl::messages::*

    namespace export \
    declare_interfaces \
    elaborate 

    # TODO - Declare all PCIe SS interface
    variable intel_pcie_ss_axi_interfaces
    variable ftile_interfaces_pipemode
    variable rtile_interfaces_pipemode
    
    set intel_pcie_ss_axi_interfaces {\
        { NAME                                  DIRECTION       WIDTH_EXPR                                  ROLE                                IFACE_NAME                 	IFACE_TYPE              IFACE_DIRECTION     TERMINATION                                     TERMINATION_VALUE       ELABORATION_CALLBACK                                                DESCRIPTION                         }\
    \
        { pcie_systempll_clk                    input           1               			                clk                 	            pcie_systempll_clk          ftile_hssi_system_clock         sink       "tile_integer!=1 || syspll_enabled_hwtcl==1"                                                NOVAL                   NOVAL                                                                       "System PLL for PCIe IP. Connect \"out_systempll_clk_0\" from the \"F-Tile Reference and SystemPLL Clocks\" IP to this port."   }\
        { pin_perst_n                           input           1                                           reset_n							    pin_perst_n              	reset                 sink                 false                                         	0                       ::intel_pcie_ss_axi::interfaces::elaborate_pin_perst_n                         								"Check User Guide for details"                               }\
        { coreclkout_hip_toapp                  output          1                                           clk                					coreclkout_hip_toapp      	clock                 	source				false											NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_hip_port_clks				"Check User Guide for details"                               }\
        { p0_pin_perst_n                        output          1                                           reset_n                             p0_pin_perst_n             	reset                 start               false                                           NOVAL                     ::intel_pcie_ss_axi::interfaces::elaborate_pin_perst_n                   									"Check User Guide for details"                               }\
        { p1_pin_perst_n                        output          1                                           reset_n                             p1_pin_perst_n             	reset                 start               "pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || (top_topology_integer_hwtcl == 4)"					NOVAL                  	::intel_pcie_ss_axi::interfaces::elaborate_pin_perst_n                     									"Check User Guide for details"                               }\
        { p2_pin_perst_n                        output          1                                           reset_n                             p2_pin_perst_n              reset                 start               "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2"					NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_pin_perst_n                     									"Check User Guide for details"                               }\
        { p3_pin_perst_n                        output          1                                           reset_n                             p3_pin_perst_n             	reset                 start               "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || (top_topology_integer_hwtcl == 4)"					NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_pin_perst_n                     									"Check User Guide for details"                               }\
    \
        { ninit_done                            input           1                                           reset						    	ninit_done                 	reset				 sink                 false                                           0                      ::intel_pcie_ss_axi::interfaces::elaborate_ninit_done  														"Its a Init_done signal should be connected to Reset release IP"	}\
    \
        { p0_reset_status_n						output          1                                           reset_n                             p0_reset_status_n			reset                   start               false                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_reset_status_n				"Check User Guide for details"                               }\
        { p1_reset_status_n						output          1                                           reset_n                             p1_reset_status_n			reset                   start               "pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || (top_topology_integer_hwtcl == 4)"					NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_reset_status_n				"Check User Guide for details"                               }\
        { p2_reset_status_n						output          1                                           reset_n                             p2_reset_status_n			reset                   start               "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2"					NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_reset_status_n				"Check User Guide for details"                               }\
        { p3_reset_status_n						output          1                                           reset_n                             p3_reset_status_n			reset                   start               "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || (top_topology_integer_hwtcl == 4)"					NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_reset_status_n				"Check User Guide for details"                               }\
    \
    	{ dummy_user_avmm_rst               	input           1               							reset               				dummy_user_avmm_rst     	reset           		end                 "!xcvr_reconfig_hwtcl && !core16_hip_reconfig_hwtcl && !core8_hip_reconfig_hwtcl && !core4_0_hip_reconfig_hwtcl && !core4_1_hip_reconfig_hwtcl && !(rtile_enable_pciess_register_access_hwtcl||ftile_enable_pciess_register_access_hwtcl || ptile_enable_pciess_register_access_hwtcl) && !core16_enable_cpl_timeout_hwtcl && !core8_enable_cpl_timeout_hwtcl && !core4_0_enable_cpl_timeout_hwtcl && !core4_1_enable_cpl_timeout_hwtcl"        0                       ::intel_pcie_ss_axi::interfaces::elaborate_dummy_user_avmm_rst        "Check User Guide for details"      }\
    \
        { p0_axi_st_clk							input           1                                           clk                                 p0_axi_st_clk				clock                   end                 false                                           0                   	NOVAL                    									"Check User Guide for details"                                }\
        { p1_axi_st_clk							input           1                                           clk                                 p1_axi_st_clk				clock                   end                 "pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || (top_topology_integer_hwtcl == 4)"					0                   	NOVAL                    									"Check User Guide for details"                                }\
        { p2_axi_st_clk							input           1                                           clk                                 p2_axi_st_clk				clock                   end                 "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2"					0                   	NOVAL                    									"Check User Guide for details"                                }\
        { p3_axi_st_clk							input           1                                           clk                                 p3_axi_st_clk				clock                   end                 "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || (top_topology_integer_hwtcl == 4)"					0                   	NOVAL                    									"Check User Guide for details"                                }\
    \
        { p0_axi_lite_clk						input           1                                           clk                                 p0_axi_lite_clk				clock                   end                 false                                           0                   	NOVAL                    									"Check User Guide for details"                                }\
        { p1_axi_lite_clk						input           1                                           clk                                 p1_axi_lite_clk				clock                   end                 "pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || (top_topology_integer_hwtcl == 4)"					0                   	NOVAL                    									"Check User Guide for details"                                }\
        { p2_axi_lite_clk						input           1                                           clk                                 p2_axi_lite_clk				clock                   end                 "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2"					0                   	NOVAL                    									"Check User Guide for details"                                }\
        { p3_axi_lite_clk						input           1                                           clk                                 p3_axi_lite_clk				clock                   end                 "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || (top_topology_integer_hwtcl == 4)"					0                   	NOVAL                    									"Check User Guide for details"                                }\
    \
        { p0_axi_st_areset_n					input           1                                           reset_n                             p0_axi_st_areset_n			reset                   end                 false                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_axi_st_areset              "Check User Guide for details"                                }\
        { p1_axi_st_areset_n					input           1                                           reset_n                             p1_axi_st_areset_n			reset                   end                 "pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || (top_topology_integer_hwtcl == 4)"					NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_axi_st_areset              "Check User Guide for details"                                }\
        { p2_axi_st_areset_n					input           1                                           reset_n                             p2_axi_st_areset_n			reset                   end                 "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2"					NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_axi_st_areset              "Check User Guide for details"                                }\
        { p3_axi_st_areset_n					input           1                                           reset_n                             p3_axi_st_areset_n			reset                   end                 "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || (top_topology_integer_hwtcl == 4)"					NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_axi_st_areset              "Check User Guide for details"                                }\
    \
        { p0_axi_lite_areset_n					input           1                                           reset_n                             p0_axi_lite_areset_n		reset                   end                 false                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_axi_lite_areset_n          "Check User Guide for details"                                }\
        { p1_axi_lite_areset_n					input           1                                           reset_n                             p1_axi_lite_areset_n		reset                   end                 "pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || (top_topology_integer_hwtcl == 4)"					NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_axi_lite_areset_n          "Check User Guide for details"                                }\
        { p2_axi_lite_areset_n					input           1                                           reset_n                             p2_axi_lite_areset_n		reset                   end                 "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2"					NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_axi_lite_areset_n          "Check User Guide for details"                                }\
        { p3_axi_lite_areset_n					input           1                                           reset_n                             p3_axi_lite_areset_n		reset                   end                 "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || (top_topology_integer_hwtcl == 4)"					NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_axi_lite_areset_n          "Check User Guide for details"                                }\
    \
        { p0_subsystem_cold_rst_n				input           1                                           reset_n								p0_subsystem_cold_rst_n		reset                   end                 false                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_subsystem_cold_rst_n                    									"Check User Guide for details"                                }\
        { p0_subsystem_warm_rst_n				input           1                                           reset_n                             p0_subsystem_warm_rst_n		reset                   end                 false                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_subsystem_cold_rst_n                    									"Check User Guide for details"                                }\
        { p0_subsystem_cold_rst_ack_n           output          1                                           subsystem_cold_rst_ack_n			p0_subsystem_cold_rst_ack_n	conduit                 start               false                                           NOVAL                   NOVAL                    									"Check User Guide for details"                                }\
        { p0_subsystem_warm_rst_ack_n           output          1                                           subsystem_warm_rst_ack_n			p0_subsystem_warm_rst_ack_n	conduit                 start               false                                           NOVAL                   NOVAL                    									"Check User Guide for details"                                }\
        { p0_subsystem_rst_req                  input           1                                           subsystem_rst_req					p0_subsystem_rst_req		conduit                 end                 false                                           NOVAL                   NOVAL                    									"Check User Guide for details"                                }\
        { p0_subsystem_rst_rdy                  output          1                                           subsystem_rst_rdy					p0_subsystem_rst_rdy		conduit                 start               false                                           NOVAL                   NOVAL                    									"Check User Guide for details"                                }\
        { p0_initiate_warmrst_req				output          1                                           initiate_warmrst_req				p0_initiate_warmrst_req		conduit                 start               false                                           NOVAL                   NOVAL                    									"Check User Guide for details"                                }\
        { p0_initiate_rst_req_rdy               input           1                                           initiate_rst_req_rdy				p0_initiate_rst_req_rdy		conduit                 end                 false                                           NOVAL                   NOVAL                    									"Check User Guide for details"                                }\
    \
        { p1_subsystem_cold_rst_n				input           1                                           reset_n                             p1_subsystem_cold_rst_n		reset                   end                 "pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || (top_topology_integer_hwtcl == 4)"					NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_subsystem_cold_rst_n                    									"Check User Guide for details"                                }\
        { p1_subsystem_warm_rst_n				input           1                                           reset_n                             p1_subsystem_warm_rst_n		reset                   end                 "pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || (top_topology_integer_hwtcl == 4)"					NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_subsystem_cold_rst_n                    									"Check User Guide for details"                                }\
        { p1_subsystem_cold_rst_ack_n			output          1                                           subsystem_cold_rst_ack_n			p1_subsystem_cold_rst_ack_n	conduit                 start               "pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || (top_topology_integer_hwtcl == 4)"					NOVAL                   NOVAL                    									"Check User Guide for details"                                }\
        { p1_subsystem_warm_rst_ack_n			output          1                                           subsystem_warm_rst_ack_n			p1_subsystem_warm_rst_ack_n	conduit                 start               "pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || (top_topology_integer_hwtcl == 4)"					NOVAL                   NOVAL                    									"Check User Guide for details"                                }\
        { p1_subsystem_rst_req					input           1                                           subsystem_rst_req					p1_subsystem_rst_req		conduit                 end                 "pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || (top_topology_integer_hwtcl == 4)"					NOVAL                   NOVAL                    									"Check User Guide for details"                                }\
        { p1_subsystem_rst_rdy					output          1                                           subsystem_rst_rdy					p1_subsystem_rst_rdy		conduit                 start               "pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || (top_topology_integer_hwtcl == 4)"					NOVAL                   NOVAL                    									"Check User Guide for details"                                }\
        { p1_initiate_warmrst_req				output          1                                           initiate_warmrst_req				p1_initiate_warmrst_req		conduit                 start               "pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || (top_topology_integer_hwtcl == 4)"					NOVAL                   NOVAL                    									"Check User Guide for details"                                }\
        { p1_initiate_rst_req_rdy				input           1                                           initiate_rst_req_rdy				p1_initiate_rst_req_rdy		conduit                 end                 "pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || (top_topology_integer_hwtcl == 4)"					1                   NOVAL                    									"Check User Guide for details"                                }\
    \
        { p2_subsystem_cold_rst_n				input           1                                           reset_n                             p2_subsystem_cold_rst_n		reset                   end                 "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2"					NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_subsystem_cold_rst_n                    									"Check User Guide for details"                                }\
        { p2_subsystem_warm_rst_n				input           1                                           reset_n                             p2_subsystem_warm_rst_n		reset                   end                 "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2"					NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_subsystem_cold_rst_n                    									"Check User Guide for details"                                }\
        { p2_subsystem_cold_rst_ack_n			output          1                                           subsystem_cold_rst_ack_n			p2_subsystem_cold_rst_ack_n	conduit                 start               "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2"					NOVAL                   NOVAL                    									"Check User Guide for details"                                }\
        { p2_subsystem_warm_rst_ack_n			output          1                                           subsystem_warm_rst_ack_n			p2_subsystem_warm_rst_ack_n	conduit                 start               "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2"					NOVAL                   NOVAL                    									"Check User Guide for details"                                }\
        { p2_subsystem_rst_req					input           1                                           subsystem_rst_req					p2_subsystem_rst_req		conduit                 end                 "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2"					NOVAL                   NOVAL                    									"Check User Guide for details"                                }\
        { p2_subsystem_rst_rdy					output          1                                           subsystem_rst_rdy					p2_subsystem_rst_rdy		conduit                 start               "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2"					NOVAL                   NOVAL                    									"Check User Guide for details"                                }\
        { p2_initiate_warmrst_req				output          1                                           initiate_warmrst_req				p2_initiate_warmrst_req		conduit                 start               "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2"					NOVAL                   NOVAL                    									"Check User Guide for details"                                }\
        { p2_initiate_rst_req_rdy				input           1                                           initiate_rst_req_rdy				p2_initiate_rst_req_rdy		conduit                 end                 "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2"					NOVAL                   NOVAL                    									"Check User Guide for details"                                }\
    \        
        { p3_subsystem_cold_rst_n				input           1                                           reset_n                             p3_subsystem_cold_rst_n		reset                   end                 "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || (top_topology_integer_hwtcl == 4)"					NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_subsystem_cold_rst_n                    									"Check User Guide for details"                                }\
        { p3_subsystem_warm_rst_n				input           1                                           reset_n                             p3_subsystem_warm_rst_n		reset                   end                 "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || (top_topology_integer_hwtcl == 4)"					NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_subsystem_cold_rst_n                    									"Check User Guide for details"                                }\
        { p3_subsystem_cold_rst_ack_n			output          1                                           subsystem_cold_rst_ack_n			p3_subsystem_cold_rst_ack_n	conduit                 start               "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || (top_topology_integer_hwtcl == 4)"					NOVAL                   NOVAL                    									"Check User Guide for details"                                }\
        { p3_subsystem_warm_rst_ack_n			output          1                                           subsystem_warm_rst_ack_n			p3_subsystem_warm_rst_ack_n	conduit                 start               "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || (top_topology_integer_hwtcl == 4)"					NOVAL                   NOVAL                    									"Check User Guide for details"                                }\
        { p3_subsystem_rst_req					input           1                                           subsystem_rst_req					p3_subsystem_rst_req		conduit                 end                 "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || (top_topology_integer_hwtcl == 4)"					NOVAL                   NOVAL                    									"Check User Guide for details"                                }\
        { p3_subsystem_rst_rdy					output          1                                           subsystem_rst_rdy					p3_subsystem_rst_rdy		conduit                 start               "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || (top_topology_integer_hwtcl == 4)"					NOVAL                   NOVAL                    									"Check User Guide for details"                                }\
        { p3_initiate_warmrst_req				output          1                                           initiate_warmrst_req				p3_initiate_warmrst_req		conduit                 start               "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || (top_topology_integer_hwtcl == 4)"					NOVAL                   NOVAL                    									"Check User Guide for details"                                }\
        { p3_initiate_rst_req_rdy				input           1                                           initiate_rst_req_rdy				p3_initiate_rst_req_rdy		conduit                 end                 "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || (top_topology_integer_hwtcl == 4)"					NOVAL                   NOVAL                    									"Check User Guide for details"                                }\
    \
        { p0_axi_mm_clk							input           1                                           clk                                 p0_axi_mm_clk				clock                   end                 "pcie_ss_func_mode_integer_hwtcl < 2"                                           0                   	NOVAL														"Check User Guide for details"                                }\
        { p1_axi_mm_clk							input           1                                           clk                                 p1_axi_mm_clk				clock                   end                 "pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || pcie_ss_func_mode_integer_hwtcl < 2 || (top_topology_integer_hwtcl == 4)"					0                   	NOVAL														"Check User Guide for details"                                }\
        { p2_axi_mm_clk							input           1                                           clk                                 p2_axi_mm_clk				clock                   end                 "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || pcie_ss_func_mode_integer_hwtcl < 2"					0                   	NOVAL														"Check User Guide for details"                                }\
        { p3_axi_mm_clk							input           1                                           clk                                 p3_axi_mm_clk				clock                   end                 "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || pcie_ss_func_mode_integer_hwtcl < 2 || (top_topology_integer_hwtcl == 4)"					0                   	NOVAL														"Check User Guide for details"                                }\
    \        
        { p0_axi_mm_areset_n					input           1                                           reset_n                             p0_axi_mm_areset_n			reset                   end                 "pcie_ss_func_mode_integer_hwtcl < 2"                                           NOVAL					::intel_pcie_ss_axi::interfaces::elaborate_axi_mm_areset_n            "Check User Guide for details"                                }\
        { p1_axi_mm_areset_n					input           1                                           reset_n                             p1_axi_mm_areset_n			reset                   end                 "pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || pcie_ss_func_mode_integer_hwtcl < 2 || (top_topology_integer_hwtcl == 4)"					NOVAL					::intel_pcie_ss_axi::interfaces::elaborate_axi_mm_areset_n            "Check User Guide for details"                                }\
        { p2_axi_mm_areset_n					input           1                                           reset_n                             p2_axi_mm_areset_n			reset                   end                 "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || pcie_ss_func_mode_integer_hwtcl < 2"					NOVAL					::intel_pcie_ss_axi::interfaces::elaborate_axi_mm_areset_n            "Check User Guide for details"                                }\
        { p3_axi_mm_areset_n					input           1                                           reset_n                             p3_axi_mm_areset_n			reset                   end                 "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || pcie_ss_func_mode_integer_hwtcl < 2 || (top_topology_integer_hwtcl == 4)"					NOVAL					::intel_pcie_ss_axi::interfaces::elaborate_axi_mm_areset_n            "Check User Guide for details"                                }\
    \
    	{ p0_ss_app_st_rx_tvalid                output          1                                           tvalid                              p0_st_rx		            axi4stream              start               false                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_rx_interfaces                                                       "Check User Guide for details"                               }\
        { p0_app_ss_st_rx_tready                input          	1                                           tready                              p0_st_rx		            axi4stream              end		    	    "tile_integer==2 &&core16_hip_native_mode_user_hwtcl==1"                                     1                   ::intel_pcie_ss_axi::interfaces::elaborate_st_rx_interfaces                                                       "Check User Guide for details"                               }\
        { p0_ss_app_st_rx_tdata                 output          core16_DWIDTH                               tdata                               p0_st_rx		            axi4stream              start               false                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_rx_interfaces                                                       "Check User Guide for details"                               }\
        { p0_ss_app_st_rx_tkeep                 output          core16_DWIDTH/8				    			tkeep                               p0_st_rx		            axi4stream              start               false                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_rx_interfaces                                                       "Check User Guide for details"                               }\
        { p0_ss_app_st_rx_tlast                 output          1                                           tlast                               p0_st_rx		            axi4stream              start               false                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_rx_interfaces                                                       "Check User Guide for details"                               }\
        { p0_ss_app_st_rx_tuser_vendor          output          core16_NUM_OF_SEG                                          	ss_app_st_rx_tuser_vendor        p0_ss_app_st_rx_tuser_vendor		            conduit                 start               false                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_rx_tuser_vendor_interfaces                                                      "Check User Guide for details"                               }\
        { p0_ss_app_st_rx_tuser_last_segment          		output          core16_NUM_OF_SEG                               ss_app_st_rx_tuser_last_segment      p0_ss_app_st_rx_tuser_last_segment    		conduit                start               false                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_rx_tuser_last_segment_interfaces                                                       "Check User Guide for details"                               }\
        { p0_ss_app_st_rx_tuser_hvalid          output          core16_NUM_OF_SEG                           ss_app_st_rx_tuser_hvalid        p0_ss_app_st_rx_tuser_hvalid                      conduit              start             "core16_header_scheme_integer_hwtcl <1"                                          NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_rx_tuser_hvalid_interfaces                                                      "Check User Guide for details"                               }\
        { p0_ss_app_st_rx_tuser_transaction_abort    output     core16_NUM_OF_SEG                    ss_app_st_rx_tuser_transaction_abort    p0_ss_app_st_rx_tuser_transaction_abort           conduit              start             true                                            NOVAL                    ::intel_pcie_ss_axi::interfaces::elaborate_st_rx_tuser_transaction_abort_interfaces                                                      "Check User Guide for details"                               }\
        { p0_ss_app_st_rx_tuser_hdr               output      256*core16_NUM_OF_SEG                  ss_app_st_rx_tuser_hdr          p0_ss_app_st_rx_tuser_hdr                         conduit              start             "core16_header_scheme_integer_hwtcl <1"                                            NOVAL                    ::intel_pcie_ss_axi::interfaces::elaborate_st_rx_tuser_hdr_interfaces                                                      "Check User Guide for details"                               }\
                              
                
    \
       
        { p1_ss_app_st_rx_tvalid                output          1                                           tvalid                              p1_st_rx		            axi4stream              start               "pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || (top_topology_integer_hwtcl == 4)"                 NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_rx_interfaces                                                       "Check User Guide for details"                               }\
        { p1_app_ss_st_rx_tready                input          	1                                           tready                              p1_st_rx		            axi4stream              end		    	    "(tile_integer==2 &&core8_hip_native_mode_user_hwtcl==1)||pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || (top_topology_integer_hwtcl == 4)"                 1                   ::intel_pcie_ss_axi::interfaces::elaborate_st_rx_interfaces                                                       "Check User Guide for details"                               }\
        { p1_ss_app_st_rx_tdata                 output          core8_DWIDTH                                tdata                               p1_st_rx		            axi4stream              start               "pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || (top_topology_integer_hwtcl == 4)"                 NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_rx_interfaces                                                       "Check User Guide for details"                               }\
        { p1_ss_app_st_rx_tkeep                 output          core8_DWIDTH/8				    			tkeep                               p1_st_rx		            axi4stream              start               "pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || (top_topology_integer_hwtcl == 4)"                 NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_rx_interfaces                                                       "Check User Guide for details"                               }\
        { p1_ss_app_st_rx_tlast                 output          1                                           tlast                               p1_st_rx		            axi4stream              start               "pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || (top_topology_integer_hwtcl == 4)"                 NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_rx_interfaces                                                       "Check User Guide for details"                               }\
        { p1_ss_app_st_rx_tuser_vendor          output          core8_NUM_OF_SEG                                          	ss_app_st_rx_tuser_vendor        p1_ss_app_st_rx_tuser_vendor		            conduit                 start               "pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || (top_topology_integer_hwtcl == 4)"                 NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_rx_tuser_vendor_interfaces                                                      "Check User Guide for details"                               }\
        { p1_ss_app_st_rx_tuser_last_segment         		output          core8_NUM_OF_SEG                                ss_app_st_rx_tuser_last_segment       p1_ss_app_st_rx_tuser_last_segment		    conduit              start               "pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || (top_topology_integer_hwtcl == 4)"                 NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_rx_tuser_last_segment_interfaces                                                       "Check User Guide for details"                               }\
        { p1_ss_app_st_rx_tuser_hvalid          output          core8_NUM_OF_SEG                           ss_app_st_rx_tuser_hvalid        p1_ss_app_st_rx_tuser_hvalid                      conduit              start              "pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || (top_topology_integer_hwtcl == 4)"                                             NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_rx_tuser_hvalid_interfaces                                                      "Check User Guide for details"                               }\
        { p1_ss_app_st_rx_tuser_transaction_abort    output     core8_NUM_OF_SEG                    ss_app_st_rx_tuser_transaction_abort    p1_ss_app_st_rx_tuser_transaction_abort           conduit              start              true                                             NOVAL                    ::intel_pcie_ss_axi::interfaces::elaborate_st_rx_tuser_transaction_abort_interfaces                                                      "Check User Guide for details"                               }\
        { p1_ss_app_st_rx_tuser_hdr               output      256*core8_NUM_OF_SEG                  ss_app_st_rx_tuser_hdr          p1_ss_app_st_rx_tuser_hdr                         conduit              start              "pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || (top_topology_integer_hwtcl == 4)"                                            NOVAL                    ::intel_pcie_ss_axi::interfaces::elaborate_st_rx_tuser_hdr_interfaces                                                      "Check User Guide for details"                               }\

    \
       
        { p2_ss_app_st_rx_tvalid                output          1                                           tvalid                              p2_st_rx		            axi4stream              start               "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2"                 NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_rx_interfaces                                                       "Check User Guide for details"                               }\
        { p2_app_ss_st_rx_tready                input          	1                                           tready                              p2_st_rx		            axi4stream              end		    	    "(tile_integer==2 &&core4_0_hip_native_mode_user_hwtcl==1)||pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2"                 1                  ::intel_pcie_ss_axi::interfaces::elaborate_st_rx_interfaces                                                       "Check User Guide for details"                               }\
        { p2_ss_app_st_rx_tdata                 output          core4_0_DWIDTH                              tdata                               p2_st_rx		            axi4stream              start               "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2"                 NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_rx_interfaces                                                       "Check User Guide for details"                               }\
        { p2_ss_app_st_rx_tkeep                 output          core4_0_DWIDTH/8			    			tkeep                               p2_st_rx		            axi4stream              start               "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2"                 NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_rx_interfaces                                                       "Check User Guide for details"                               }\
        { p2_ss_app_st_rx_tlast                 output          1                                           tlast                               p2_st_rx		            axi4stream              start               "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2"                 NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_rx_interfaces                                                       "Check User Guide for details"                               }\
        { p2_ss_app_st_rx_tuser_vendor          output          core4_0_NUM_OF_SEG                                           ss_app_st_rx_tuser_vendor        p2_ss_app_st_rx_tuser_vendor		            conduit                 start               "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2"                 NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_rx_tuser_vendor_interfaces                                                       "Check User Guide for details"                               }\
        { p2_ss_app_st_rx_tuser_last_segment                 output          core4_0_NUM_OF_SEG                              ss_app_st_rx_tuser_last_segment          p2_ss_app_st_rx_tuser_last_segment		conduit              start               "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2"                 NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_rx_tuser_last_segment_interfaces                                                       "Check User Guide for details"                               }\
        { p2_ss_app_st_rx_tuser_hvalid          output          core4_0_NUM_OF_SEG                           ss_app_st_rx_tuser_hvalid        p2_ss_app_st_rx_tuser_hvalid                      conduit              start              "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2"                                             NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_rx_tuser_hvalid_interfaces                                                      "Check User Guide for details"                               }\
        { p2_ss_app_st_rx_tuser_transaction_abort    output     core4_0_NUM_OF_SEG                    ss_app_st_rx_tuser_transaction_abort    p2_ss_app_st_rx_tuser_transaction_abort           conduit              start              true                                             NOVAL                    ::intel_pcie_ss_axi::interfaces::elaborate_st_rx_tuser_transaction_abort_interfaces                                                      "Check User Guide for details"                               }\
        { p2_ss_app_st_rx_tuser_hdr               output      256*core4_0_NUM_OF_SEG                          ss_app_st_rx_tuser_hdr          p2_ss_app_st_rx_tuser_hdr                         conduit              start              "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2"                                            NOVAL                    ::intel_pcie_ss_axi::interfaces::elaborate_st_rx_tuser_hdr_interfaces                                                      "Check User Guide for details"                               }\

    \
       
        { p3_ss_app_st_rx_tvalid                output          1                                           tvalid                              p3_st_rx		            axi4stream              start               "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || (top_topology_integer_hwtcl == 4)"                 NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_rx_interfaces                                                       "Check User Guide for details"                               }\
        { p3_app_ss_st_rx_tready                input          	1                                           tready                              p3_st_rx		            axi4stream              end		    	    "(tile_integer==2 &&core4_1_hip_native_mode_user_hwtcl==1)||pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || (top_topology_integer_hwtcl == 4)"                 1                   ::intel_pcie_ss_axi::interfaces::elaborate_st_rx_interfaces                                                       "Check User Guide for details"                               }\
        { p3_ss_app_st_rx_tdata                 output          core4_1_DWIDTH                              tdata                               p3_st_rx		            axi4stream              start               "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || (top_topology_integer_hwtcl == 4)"                 NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_rx_interfaces                                                       "Check User Guide for details"                               }\
        { p3_ss_app_st_rx_tkeep                 output          core4_1_DWIDTH/8			    			tkeep                               p3_st_rx		            axi4stream              start               "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || (top_topology_integer_hwtcl == 4)"                 NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_rx_interfaces                                                       "Check User Guide for details"                               }\
        { p3_ss_app_st_rx_tlast                 output          1                                           tlast                               p3_st_rx		            axi4stream              start               "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || (top_topology_integer_hwtcl == 4)"                 NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_rx_interfaces                                                       "Check User Guide for details"                               }\
        { p3_ss_app_st_rx_tuser_vendor          output          core4_1_NUM_OF_SEG                                           ss_app_st_rx_tuser_vendor        p3_ss_app_st_rx_tuser_vendor		            conduit                 start               "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || (top_topology_integer_hwtcl == 4)"                 NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_rx_tuser_vendor_interfaces                                                       "Check User Guide for details"                               }\
        { p3_ss_app_st_rx_tuser_last_segment                 output          core4_1_NUM_OF_SEG                             ss_app_st_rx_tuser_last_segment               p3_ss_app_st_rx_tuser_last_segment		       conduit              start               "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || (top_topology_integer_hwtcl == 4)"                 NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_rx_tuser_last_segment_interfaces                                                       "Check User Guide for details"                               }\
        { p3_ss_app_st_rx_tuser_hvalid          output          core4_1_NUM_OF_SEG                           ss_app_st_rx_tuser_hvalid        p3_ss_app_st_rx_tuser_hvalid                      conduit              start              "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || (top_topology_integer_hwtcl == 4)"                                             NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_rx_tuser_hvalid_interfaces                                                      "Check User Guide for details"                               }\
        { p3_ss_app_st_rx_tuser_transaction_abort    output     core4_1_NUM_OF_SEG                    ss_app_st_rx_tuser_transaction_abort    p3_ss_app_st_rx_tuser_transaction_abort           conduit              start              true                                            NOVAL                    ::intel_pcie_ss_axi::interfaces::elaborate_st_rx_tuser_transaction_abort_interfaces                                                      "Check User Guide for details"                               }\
        { p3_ss_app_st_rx_tuser_hdr               output      256*core4_1_NUM_OF_SEG                  ss_app_st_rx_tuser_hdr          p3_ss_app_st_rx_tuser_hdr                         conduit              start              "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || (top_topology_integer_hwtcl == 4)"                                            NOVAL                    ::intel_pcie_ss_axi::interfaces::elaborate_st_rx_tuser_hdr_interfaces                                                      "Check User Guide for details"                               }\

    \
    	{ p0_app_ss_st_tx_tvalid                input          1                                            tvalid                              p0_st_tx		            axi4stream              end		    		false                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_tx_interfaces                                                       "Check User Guide for details"                               }\
        { p0_ss_app_st_tx_tready                output         1                                            tready                              p0_st_tx		            axi4stream              start		    	false                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_tx_interfaces                                                       "Check User Guide for details"                               }\
        { p0_app_ss_st_tx_tdata                 input          core16_DWIDTH                                tdata				                p0_st_tx		            axi4stream              end                 false                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_tx_interfaces                                                       "Check User Guide for details"                               }\
        { p0_app_ss_st_tx_tkeep                 input          core16_DWIDTH/8				    			tkeep                               p0_st_tx		            axi4stream              end                 false                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_tx_interfaces                                                       "Check User Guide for details"                               }\
        { p0_app_ss_st_tx_tlast                 input          1                                            tlast                               p0_st_tx		            axi4stream              end                 false                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_tx_interfaces                                                       "Check User Guide for details"                               }\
        { p0_app_ss_st_tx_tuser_vendor          input          core16_NUM_OF_SEG                            app_ss_st_tx_tuser_vendor        p0_app_ss_st_tx_tuser_vendor		             conduit               end               "pcie_ss_func_mode_integer_hwtcl ==0"                                              NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_tx_tuser_vendor_interfaces                                                      "Check User Guide for details"                               }\
        { p0_app_ss_st_tx_tuser_last_segment    input          core16_NUM_OF_SEG                            app_ss_st_tx_tuser_last_segment           p0_app_ss_st_tx_tuser_last_segment		 conduit              end                false                                          NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_tx_tuser_last_segment_interfaces                                                       "Check User Guide for details"                               }\
        { p0_app_ss_st_tx_tuser_hvalid          input          core16_NUM_OF_SEG                           app_ss_st_tx_tuser_hvalid        p0_app_ss_st_tx_tuser_hvalid                      conduit              start             "core16_header_scheme_integer_hwtcl <1"                                          NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_tx_tuser_hvalid_interfaces                                                      "Check User Guide for details"                               }\
        { p0_app_ss_st_tx_tuser_transaction_abort    input     core16_NUM_OF_SEG                           app_ss_st_tx_tuser_transaction_abort    p0_app_ss_st_tx_tuser_transaction_abort           conduit              start             true                                             NOVAL                    ::intel_pcie_ss_axi::interfaces::elaborate_st_tx_tuser_transaction_abort_interfaces                                                      "Check User Guide for details"                               }\
        { p0_app_ss_st_tx_tuser_hdr               input      256*core16_NUM_OF_SEG                          app_ss_st_tx_tuser_hdr          p0_app_ss_st_tx_tuser_hdr                         conduit              start             "core16_header_scheme_integer_hwtcl <1"                                            NOVAL                    ::intel_pcie_ss_axi::interfaces::elaborate_st_tx_tuser_hdr_interfaces                                                      "Check User Guide for details"                               }\
                 
    \
    	{ p1_app_ss_st_tx_tvalid                input          1                                            tvalid                              p1_st_tx		            axi4stream              end		    		"pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || (top_topology_integer_hwtcl == 4)"                 NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_tx_interfaces                                                       "Check User Guide for details"                                }\
        { p1_ss_app_st_tx_tready                output         1                                            tready                              p1_st_tx		            axi4stream              start		    	"pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || (top_topology_integer_hwtcl == 4)"                 NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_tx_interfaces                                                       "Check User Guide for details"                                }\
        { p1_app_ss_st_tx_tdata                 input          core8_DWIDTH                                 tdata				                p1_st_tx		            axi4stream              end                 "pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || (top_topology_integer_hwtcl == 4)"                 NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_tx_interfaces                                                       "Check User Guide for details"                                }\
        { p1_app_ss_st_tx_tkeep                 input          core8_DWIDTH/8				    			tkeep                               p1_st_tx		            axi4stream              end                 "pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || (top_topology_integer_hwtcl == 4)"                 NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_tx_interfaces                                                       "Check User Guide for details"                                }\
        { p1_app_ss_st_tx_tlast                 input          1                                            tlast                               p1_st_tx		            axi4stream              end                 "pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || (top_topology_integer_hwtcl == 4)"                 NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_tx_interfaces                                                       "Check User Guide for details"                                }\
        { p1_app_ss_st_tx_tuser_vendor          input          core8_NUM_OF_SEG                                            app_ss_st_tx_tuser_vendor        p1_app_ss_st_tx_tuser_vendor		            conduit                 end                 "pcie_ss_func_mode_integer_hwtcl ==0 || pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || (top_topology_integer_hwtcl == 4)"                 NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_tx_tuser_vendor_interfaces                                                      "Check User Guide for details"                                }\
        { p1_app_ss_st_tx_tuser_last_segment                 input          core8_NUM_OF_SEG                              app_ss_st_tx_tuser_last_segment      p1_app_ss_st_tx_tuser_last_segment	    conduit              end                 "pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || (top_topology_integer_hwtcl == 4)"                 NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_tx_tuser_last_segment_interfaces                                                       "Check User Guide for details"                                }\
        { p1_app_ss_st_tx_tuser_hvalid          input          core8_NUM_OF_SEG                           app_ss_st_tx_tuser_hvalid        p1_app_ss_st_tx_tuser_hvalid                      conduit              start             "pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || (top_topology_integer_hwtcl == 4)"                                          NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_tx_tuser_hvalid_interfaces                                                      "Check User Guide for details"                               }\
        { p1_app_ss_st_tx_tuser_transaction_abort    input     core8_NUM_OF_SEG                    app_ss_st_tx_tuser_transaction_abort    p1_app_ss_st_tx_tuser_transaction_abort           conduit              start             true                                            NOVAL                    ::intel_pcie_ss_axi::interfaces::elaborate_st_tx_tuser_transaction_abort_interfaces                                                      "Check User Guide for details"                               }\
        { p1_app_ss_st_tx_tuser_hdr               input      256*core8_NUM_OF_SEG                          app_ss_st_tx_tuser_hdr          p1_app_ss_st_tx_tuser_hdr                         conduit              start             "pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || (top_topology_integer_hwtcl == 4)"                                            NOVAL                    ::intel_pcie_ss_axi::interfaces::elaborate_st_tx_tuser_hdr_interfaces                                                      "Check User Guide for details"                               }\

    \
    	{ p2_app_ss_st_tx_tvalid                input          1                                            tvalid                              p2_st_tx		            axi4stream              end		    		"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2"                 NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_tx_interfaces                                                       "Check User Guide for details"                                }\
        { p2_ss_app_st_tx_tready                output         1                                            tready                              p2_st_tx		            axi4stream              start		    	"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2"                 NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_tx_interfaces                                                       "Check User Guide for details"                                }\
        { p2_app_ss_st_tx_tdata                 input          core4_0_DWIDTH                               tdata				                p2_st_tx		            axi4stream              end                 "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2"                 NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_tx_interfaces                                                       "Check User Guide for details"                                }\
        { p2_app_ss_st_tx_tkeep                 input          core4_0_DWIDTH/8				    			tkeep                               p2_st_tx		            axi4stream              end                 "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2"                 NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_tx_interfaces                                                       "Check User Guide for details"                                }\
        { p2_app_ss_st_tx_tlast                 input          1                                            tlast                               p2_st_tx		            axi4stream              end                 "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2"                 NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_tx_interfaces                                                       "Check User Guide for details"                                }\
        { p2_app_ss_st_tx_tuser_vendor          input          core4_0_NUM_OF_SEG                                            app_ss_st_tx_tuser_vendor        p2_app_ss_st_tx_tuser_vendor	                conduit                 end                 "pcie_ss_func_mode_integer_hwtcl ==0 ||pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2"                 NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_tx_tuser_vendor_interfaces                                                      "Check User Guide for details"                                }\
        { p2_app_ss_st_tx_tuser_last_segment                 input          core4_0_NUM_OF_SEG                               app_ss_st_tx_tuser_last_segment     p2_app_ss_st_tx_tuser_last_segment          conduit              end                 "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2"                 NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_tx_tuser_last_segment_interfaces                                                       "Check User Guide for details"                                }\
        { p2_app_ss_st_tx_tuser_hvalid          input          core4_0_NUM_OF_SEG                           app_ss_st_tx_tuser_hvalid        p2_app_ss_st_tx_tuser_hvalid                      conduit              start             "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2"                                          NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_tx_tuser_hvalid_interfaces                                                      "Check User Guide for details"                               }\
        { p2_app_ss_st_tx_tuser_transaction_abort    input     core4_0_NUM_OF_SEG                    app_ss_st_tx_tuser_transaction_abort    p2_app_ss_st_tx_tuser_transaction_abort           conduit              start             true                                            NOVAL                    ::intel_pcie_ss_axi::interfaces::elaborate_st_tx_tuser_transaction_abort_interfaces                                                      "Check User Guide for details"                               }\
        { p2_app_ss_st_tx_tuser_hdr               input      256*core4_0_NUM_OF_SEG                          app_ss_st_tx_tuser_hdr          p2_app_ss_st_tx_tuser_hdr                         conduit              start             "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2"                                            NOVAL                    ::intel_pcie_ss_axi::interfaces::elaborate_st_tx_tuser_hdr_interfaces                                                      "Check User Guide for details"                               }\

    \
     	{ p3_app_ss_st_tx_tvalid                input          1                                            tvalid                              p3_st_tx		            axi4stream              end		    		"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || (top_topology_integer_hwtcl == 4)"                 NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_tx_interfaces                                                       "Check User Guide for details"                                }\
        { p3_ss_app_st_tx_tready                output         1                                            tready                              p3_st_tx		            axi4stream              start		    	"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || (top_topology_integer_hwtcl == 4)"                 NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_tx_interfaces                                                       "Check User Guide for details"                                }\
        { p3_app_ss_st_tx_tdata                 input          core4_1_DWIDTH                               tdata				                p3_st_tx		            axi4stream              end                 "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || (top_topology_integer_hwtcl == 4)"                 NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_tx_interfaces                                                       "Check User Guide for details"                                }\
        { p3_app_ss_st_tx_tkeep                 input          core4_1_DWIDTH/8				    			tkeep                               p3_st_tx		            axi4stream              end                 "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || (top_topology_integer_hwtcl == 4)"                 NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_tx_interfaces                                                       "Check User Guide for details"                                }\
        { p3_app_ss_st_tx_tlast                 input          1                                            tlast                               p3_st_tx		            axi4stream              end                 "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || (top_topology_integer_hwtcl == 4)"                 NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_tx_interfaces                                                       "Check User Guide for details"                                }\
        { p3_app_ss_st_tx_tuser_vendor          input          core4_1_NUM_OF_SEG                                           app_ss_st_tx_tuser_vendor        p3_app_ss_st_tx_tuser_vendor	                conduit                 end                 "pcie_ss_func_mode_integer_hwtcl ==0 ||pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || (top_topology_integer_hwtcl == 4)"                 NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_tx_tuser_vendor_interfaces                                                     "Check User Guide for details"                                }\
        { p3_app_ss_st_tx_tuser_last_segment                 input          core4_1_NUM_OF_SEG                              app_ss_st_tx_tuser_last_segment           p3_app_ss_st_tx_tuser_last_segment	    conduit              end                 "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || (top_topology_integer_hwtcl == 4)"                 NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_tx_tuser_last_segment_interfaces                                                       "Check User Guide for details"                                }\
        { p3_app_ss_st_tx_tuser_hvalid          input          core4_1_NUM_OF_SEG                           app_ss_st_tx_tuser_hvalid        p3_app_ss_st_tx_tuser_hvalid                      conduit              start             "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || (top_topology_integer_hwtcl == 4)"                                          NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_tx_tuser_hvalid_interfaces                                                      "Check User Guide for details"                               }\
        { p3_app_ss_st_tx_tuser_transaction_abort    input     core4_1_NUM_OF_SEG                    app_ss_st_tx_tuser_transaction_abort    p3_app_ss_st_tx_tuser_transaction_abort           conduit              start             true                                             NOVAL                    ::intel_pcie_ss_axi::interfaces::elaborate_st_tx_tuser_transaction_abort_interfaces                                                      "Check User Guide for details"                               }\
        { p3_app_ss_st_tx_tuser_hdr               input      256*core4_1_NUM_OF_SEG                  app_ss_st_tx_tuser_hdr          p3_app_ss_st_tx_tuser_hdr                         conduit              start             "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || (top_topology_integer_hwtcl == 4)"                                            NOVAL                    ::intel_pcie_ss_axi::interfaces::elaborate_st_tx_tuser_hdr_interfaces                                                      "Check User Guide for details"                               }\

    \
        { p0_ss_app_st_ciireq_tvalid            output         1							    			tvalid                              p0_st_ciireq		axi4stream                 start		   "!core16_cii_en_hwtcl ||core16_virtual_rp_ep_mode_integer_hwtcl"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_ciireq_interfaces                                                       "Check User Guide for details"                                }\
        { p0_app_ss_st_ciireq_tready            input          1                                	    	tready                              p0_st_ciireq		axi4stream                 end             "!core16_cii_en_hwtcl ||core16_virtual_rp_ep_mode_integer_hwtcl"                                             NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_ciireq_interfaces                                                       "Check User Guide for details"                                }\
        { p0_ss_app_st_ciireq_tdata             output         72				    	    				tdata                               p0_st_ciireq		axi4stream                 start           "!core16_cii_en_hwtcl ||core16_virtual_rp_ep_mode_integer_hwtcl"                                             NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_ciireq_interfaces                                                       "Check User Guide for details"                                }\
        { p0_app_ss_st_ciiresp_tvalid           input          1							    			tvalid                              p0_st_ciiresp		axi4stream                 end		       "!core16_cii_en_hwtcl ||core16_virtual_rp_ep_mode_integer_hwtcl||core16_enable_config_monitoring_hwtcl"                                            NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_ciiresp_interfaces                                                       "Check User Guide for details"                                }\
        { p0_app_ss_st_ciiresp_tdata            input          33                                	    	tdata                               p0_st_ciiresp		axi4stream                 end             "!core16_cii_en_hwtcl ||core16_virtual_rp_ep_mode_integer_hwtcl||core16_enable_config_monitoring_hwtcl"                                            NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_ciiresp_interfaces                                                       "Check User Guide for details"                                }\
    \
        { p1_ss_app_st_ciireq_tvalid            output         1							    			tvalid                              p1_st_ciireq		axi4stream                 start		   "pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || !core8_cii_en_hwtcl ||core8_virtual_rp_ep_mode_integer_hwtcl || (top_topology_integer_hwtcl == 4)"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_ciireq_interfaces                                                       "Check User Guide for details"                                }\
        { p1_app_ss_st_ciireq_tready            input          1                                	    	tready                              p1_st_ciireq		axi4stream                 end             "pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || !core8_cii_en_hwtcl ||core8_virtual_rp_ep_mode_integer_hwtcl || (top_topology_integer_hwtcl == 4)"                                             NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_ciireq_interfaces                                                       "Check User Guide for details"                                }\
        { p1_ss_app_st_ciireq_tdata             output         72				    	    				tdata                               p1_st_ciireq		axi4stream                 start           "pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || !core8_cii_en_hwtcl ||core8_virtual_rp_ep_mode_integer_hwtcl || (top_topology_integer_hwtcl == 4)"                                             NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_ciireq_interfaces                                                       "Check User Guide for details"                                }\
        { p1_app_ss_st_ciiresp_tvalid           input          1							    			tvalid                              p1_st_ciiresp		axi4stream                 end		       "pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || !core8_cii_en_hwtcl ||core8_virtual_rp_ep_mode_integer_hwtcl||core8_enable_config_monitoring_hwtcl || (top_topology_integer_hwtcl == 4)"                                            NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_ciiresp_interfaces                                                       "Check User Guide for details"                                }\
        { p1_app_ss_st_ciiresp_tdata            input          33                                	    	tdata                               p1_st_ciiresp		axi4stream                 end             "pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || !core8_cii_en_hwtcl ||core8_virtual_rp_ep_mode_integer_hwtcl||core8_enable_config_monitoring_hwtcl || (top_topology_integer_hwtcl == 4)"                                            NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_ciiresp_interfaces                                                       "Check User Guide for details"                                }\
    \
        { p2_ss_app_st_ciireq_tvalid            output         1							    			tvalid                              p2_st_ciireq		axi4stream                 start		   "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || !core4_0_cii_en_hwtcl ||core4_0_virtual_rp_ep_mode_integer_hwtcl"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_ciireq_interfaces                                                       "Check User Guide for details"                                }\
        { p2_app_ss_st_ciireq_tready            input          1                                	    	tready                              p2_st_ciireq		axi4stream                 end             "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || !core4_0_cii_en_hwtcl ||core4_0_virtual_rp_ep_mode_integer_hwtcl"                                             NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_ciireq_interfaces                                                       "Check User Guide for details"                                }\
        { p2_ss_app_st_ciireq_tdata             output         72				    	    				tdata                               p2_st_ciireq		axi4stream                 start           "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || !core4_0_cii_en_hwtcl ||core4_0_virtual_rp_ep_mode_integer_hwtcl"                                             NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_ciireq_interfaces                                                       "Check User Guide for details"                                }\
        { p2_app_ss_st_ciiresp_tvalid           input          1							    			tvalid                              p2_st_ciiresp		axi4stream                 end		       "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || !core4_0_cii_en_hwtcl ||core4_0_virtual_rp_ep_mode_integer_hwtcl||core4_0_enable_config_monitoring_hwtcl"                                            NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_ciiresp_interfaces                                                       "Check User Guide for details"                                }\
        { p2_app_ss_st_ciiresp_tdata            input          33                                	    	tdata                               p2_st_ciiresp		axi4stream                 end             "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || !core4_0_cii_en_hwtcl ||core4_0_virtual_rp_ep_mode_integer_hwtcl||core4_0_enable_config_monitoring_hwtcl"                                            NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_ciiresp_interfaces                                                       "Check User Guide for details"                                }\
    \
        { p3_ss_app_st_ciireq_tvalid            output         1							    			tvalid                              p3_st_ciireq		axi4stream                 start		   "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || !core4_1_cii_en_hwtcl ||core4_1_virtual_rp_ep_mode_integer_hwtcl || (top_topology_integer_hwtcl == 4)"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_ciireq_interfaces                                                       "Check User Guide for details"                                }\
        { p3_app_ss_st_ciireq_tready            input          1                                	    	tready                              p3_st_ciireq		axi4stream                 end             "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || !core4_1_cii_en_hwtcl ||core4_1_virtual_rp_ep_mode_integer_hwtcl || (top_topology_integer_hwtcl == 4)"                                             NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_ciireq_interfaces                                                       "Check User Guide for details"                                }\
        { p3_ss_app_st_ciireq_tdata             output         72				    	    				tdata                               p3_st_ciireq		axi4stream                 start           "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || !core4_1_cii_en_hwtcl ||core4_1_virtual_rp_ep_mode_integer_hwtcl || (top_topology_integer_hwtcl == 4)"                                             NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_ciireq_interfaces                                                       "Check User Guide for details"                                }\
        { p3_app_ss_st_ciiresp_tvalid           input          1							    			tvalid                              p3_st_ciiresp		axi4stream                 end		       "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || !core4_1_cii_en_hwtcl ||core4_1_virtual_rp_ep_mode_integer_hwtcl ||core4_1_enable_config_monitoring_hwtcl || (top_topology_integer_hwtcl == 4)"                                            NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_ciiresp_interfaces                                                       "Check User Guide for details"                                }\
        { p3_app_ss_st_ciiresp_tdata            input          33                                	    	tdata                               p3_st_ciiresp		axi4stream                 end             "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || !core4_1_cii_en_hwtcl ||core4_1_virtual_rp_ep_mode_integer_hwtcl ||core4_1_enable_config_monitoring_hwtcl || (top_topology_integer_hwtcl == 4)"                                            NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_ciiresp_interfaces                                                       "Check User Guide for details"                                }\
    \
        { p0_ss_app_st_cebreq_tvalid            output         1							    			tvalid                              p0_st_cebreq		axi4stream                 start		   "!core16_ceb_en_hwtcl ||core16_virtual_rp_ep_mode_integer_hwtcl"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_cebreq_interfaces                                                       "Check User Guide for details"                                }\
        { p0_app_ss_st_cebreq_tready            input          1                                	    	tready                              p0_st_cebreq		axi4stream                 end             "!core16_ceb_en_hwtcl ||core16_virtual_rp_ep_mode_integer_hwtcl"                                             NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_cebreq_interfaces                                                       "Check User Guide for details"                                }\
        { p0_ss_app_st_cebreq_tdata             output         68				    	    				tdata                               p0_st_cebreq		axi4stream                 start           "!core16_ceb_en_hwtcl ||core16_virtual_rp_ep_mode_integer_hwtcl"                                             NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_cebreq_interfaces                                                       "Check User Guide for details"                                }\
    \
        { p1_ss_app_st_cebreq_tvalid            output         1							    			tvalid                              p1_st_cebreq		axi4stream                 start		   "pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || !core8_ceb_en_hwtcl ||core8_virtual_rp_ep_mode_integer_hwtcl || (top_topology_integer_hwtcl == 4)"                                            NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_cebreq_interfaces                                                       "Check User Guide for details"                                }\
        { p1_app_ss_st_cebreq_tready            input          1                                	    	tready                              p1_st_cebreq		axi4stream                 end             "pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || !core8_ceb_en_hwtcl ||core8_virtual_rp_ep_mode_integer_hwtcl || (top_topology_integer_hwtcl == 4)"                                            NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_cebreq_interfaces                                                       "Check User Guide for details"                                }\
        { p1_ss_app_st_cebreq_tdata             output         68				    	    				tdata                               p1_st_cebreq		axi4stream                 start           "pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || !core8_ceb_en_hwtcl ||core8_virtual_rp_ep_mode_integer_hwtcl || (top_topology_integer_hwtcl == 4)"                                            NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_cebreq_interfaces                                                       "Check User Guide for details"                                }\
    \
        { p2_ss_app_st_cebreq_tvalid            output         1							    			tvalid                              p2_st_cebreq		axi4stream                 start		   "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || !core4_0_ceb_en_hwtcl ||core4_0_virtual_rp_ep_mode_integer_hwtcl"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_cebreq_interfaces                                                       "Check User Guide for details"                                }\
        { p2_app_ss_st_cebreq_tready            input          1                                	    	tready                              p2_st_cebreq		axi4stream                 end             "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || !core4_0_ceb_en_hwtcl ||core4_0_virtual_rp_ep_mode_integer_hwtcl"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_cebreq_interfaces                                                       "Check User Guide for details"                                }\
        { p2_ss_app_st_cebreq_tdata             output         68				    	    				tdata                               p2_st_cebreq		axi4stream                 start           "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || !core4_0_ceb_en_hwtcl ||core4_0_virtual_rp_ep_mode_integer_hwtcl"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_cebreq_interfaces                                                       "Check User Guide for details"                                }\
    \
        { p3_ss_app_st_cebreq_tvalid            output         1							    			tvalid                              p3_st_cebreq		axi4stream                 start		   "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || !core4_1_ceb_en_hwtcl ||core4_1_virtual_rp_ep_mode_integer_hwtcl || (top_topology_integer_hwtcl == 4)"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_cebreq_interfaces                                                       "Check User Guide for details"                                }\
        { p3_app_ss_st_cebreq_tready            input          1                                	    	tready                              p3_st_cebreq		axi4stream                 end             "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || !core4_1_ceb_en_hwtcl ||core4_1_virtual_rp_ep_mode_integer_hwtcl || (top_topology_integer_hwtcl == 4)"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_cebreq_interfaces                                                       "Check User Guide for details"                                }\
        { p3_ss_app_st_cebreq_tdata             output         68				    	    				tdata                               p3_st_cebreq		axi4stream                 start           "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || !core4_1_ceb_en_hwtcl ||core4_1_virtual_rp_ep_mode_integer_hwtcl || (top_topology_integer_hwtcl == 4)"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_cebreq_interfaces                                                       "Check User Guide for details"                                }\
    \
        { p0_app_ss_st_cebresp_tvalid           input          1							    			tvalid                              p0_st_cebresp		axi4stream                 end		       "!core16_ceb_en_hwtcl ||core16_virtual_rp_ep_mode_integer_hwtcl"                                             NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_cebresp_interfaces                                                       "Check User Guide for details"                                }\
        { p0_app_ss_st_cebresp_tdata            input          32                                	    	tdata                               p0_st_cebresp		axi4stream                 end             "!core16_ceb_en_hwtcl ||core16_virtual_rp_ep_mode_integer_hwtcl"                                            NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_cebresp_interfaces                                                       "Check User Guide for details"                                }\
    \
        { p1_app_ss_st_cebresp_tvalid           input          1							    			tvalid                              p1_st_cebresp		axi4stream                 end		       "pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || !core8_ceb_en_hwtcl ||core8_virtual_rp_ep_mode_integer_hwtcl || (top_topology_integer_hwtcl == 4)"                                            NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_cebresp_interfaces                                                       "Check User Guide for details"                                }\
        { p1_app_ss_st_cebresp_tdata            input          32                                	    	tdata                               p1_st_cebresp		axi4stream                 end             "pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || !core8_ceb_en_hwtcl ||core8_virtual_rp_ep_mode_integer_hwtcl || (top_topology_integer_hwtcl == 4)"                                            NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_cebresp_interfaces                                                       "Check User Guide for details"                                }\
    \
        { p2_app_ss_st_cebresp_tvalid           input          1							    			tvalid                              p2_st_cebresp		axi4stream                 end		       "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || !core4_0_ceb_en_hwtcl ||core4_0_virtual_rp_ep_mode_integer_hwtcl"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_cebresp_interfaces                                                       "Check User Guide for details"                                }\
        { p2_app_ss_st_cebresp_tdata            input          32                                	    	tdata                               p2_st_cebresp		axi4stream                 end             "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || !core4_0_ceb_en_hwtcl ||core4_0_virtual_rp_ep_mode_integer_hwtcl"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_cebresp_interfaces                                                       "Check User Guide for details"                                }\
    \
        { p3_app_ss_st_cebresp_tvalid           input          1							    			tvalid                              p3_st_cebresp		axi4stream                 end		       "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || !core4_1_ceb_en_hwtcl ||core4_1_virtual_rp_ep_mode_integer_hwtcl || (top_topology_integer_hwtcl == 4)"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_cebresp_interfaces                                                       "Check User Guide for details"                                }\
        { p3_app_ss_st_cebresp_tdata            input          32                                	    	tdata                               p3_st_cebresp		axi4stream                 end             "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || !core4_1_ceb_en_hwtcl ||core4_1_virtual_rp_ep_mode_integer_hwtcl || (top_topology_integer_hwtcl == 4)"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_cebresp_interfaces                                                       "Check User Guide for details"                                }\
    \
        { p0_ss_app_st_flrrcvd_tvalid           output         1							    			tvalid                              p0_st_flrrcvd	    axi4stream                 start	       "core16_virtual_rp_ep_mode_integer_hwtcl"                                            NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_flrrcvd_interfaces                                                       "Check User Guide for details"                                }\
        { p0_ss_app_st_flrrcvd_tdata            output         20                                	    	tdata		                        p0_st_flrrcvd		axi4stream                 start           "core16_virtual_rp_ep_mode_integer_hwtcl"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_flrrcvd_interfaces                                                       "Check User Guide for details"                                }\
    \
        { p1_ss_app_st_flrrcvd_tvalid           output         1							    			tvalid                              p1_st_flrrcvd		axi4stream                 start	    	"pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || core8_virtual_rp_ep_mode_integer_hwtcl || (top_topology_integer_hwtcl == 4)"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_flrrcvd_interfaces                                                       "Check User Guide for details"                                }\
        { p1_ss_app_st_flrrcvd_tdata            output         20                                	    	tdata		                        p1_st_flrrcvd		axi4stream                 start           " pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || core8_virtual_rp_ep_mode_integer_hwtcl || (top_topology_integer_hwtcl == 4)"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_flrrcvd_interfaces                                                       "Check User Guide for details"                                }\
    \
        { p2_ss_app_st_flrrcvd_tvalid           output         1							    			tvalid                              p2_st_flrrcvd		axi4stream                 start	    	"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || core4_0_virtual_rp_ep_mode_integer_hwtcl"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_flrrcvd_interfaces                                                       "Check User Guide for details"                                }\
        { p2_ss_app_st_flrrcvd_tdata            output         20                                	    	tdata		                        p2_st_flrrcvd		axi4stream                 start           "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || core4_0_virtual_rp_ep_mode_integer_hwtcl "                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_flrrcvd_interfaces                                                       "Check User Guide for details"                                }\
    \
        { p3_ss_app_st_flrrcvd_tvalid           output         1							    			tvalid                              p3_st_flrrcvd		axi4stream                 start	    	"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 ||core4_1_virtual_rp_ep_mode_integer_hwtcl || (top_topology_integer_hwtcl == 4)"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_flrrcvd_interfaces                                                       "Check User Guide for details"                                }\
        { p3_ss_app_st_flrrcvd_tdata            output         20                                	    	tdata		                        p3_st_flrrcvd		axi4stream                 start           "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2  ||core4_1_virtual_rp_ep_mode_integer_hwtcl || (top_topology_integer_hwtcl == 4)"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_flrrcvd_interfaces                                                       "Check User Guide for details"                                }\
    \
        { p0_app_ss_st_flrcmpl_tvalid           input          1							    			tvalid                              p0_st_flrcmpl		axi4stream                 end				"core16_virtual_rp_ep_mode_integer_hwtcl"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_flrcmpl_interfaces                                                       "Check User Guide for details"                                }\
        { p0_app_ss_st_flrcmpl_tdata            input          20                                	    	tdata		                        p0_st_flrcmpl		axi4stream                 end				"core16_virtual_rp_ep_mode_integer_hwtcl"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_flrcmpl_interfaces                                                       "Check User Guide for details"                                }\
        { p0_ss_app_st_flrcmpl_tready           output         1                                 	    	tready		                        p0_st_flrcmpl		axi4stream                 start		    "core16_virtual_rp_ep_mode_integer_hwtcl"                                          NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_flrcmpl_interfaces                                                       "Check User Guide for details"                                }\
        
    \
        { p1_app_ss_st_flrcmpl_tvalid           input          1							    			tvalid                              p1_st_flrcmpl		axi4stream                 end				"pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 ||core8_virtual_rp_ep_mode_integer_hwtcl || (top_topology_integer_hwtcl == 4)"                                            NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_flrcmpl_interfaces                                                       "Check User Guide for details"                                }\
        { p1_app_ss_st_flrcmpl_tdata            input          20                                	    	tdata		                        p1_st_flrcmpl		axi4stream                 end				"pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 ||core8_virtual_rp_ep_mode_integer_hwtcl || (top_topology_integer_hwtcl == 4)"                                            NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_flrcmpl_interfaces                                                       "Check User Guide for details"                                }\
        { p1_ss_app_st_flrcmpl_tready           output         1                                 	    	tready		                        p1_st_flrcmpl		axi4stream                 start			"pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 ||core8_virtual_rp_ep_mode_integer_hwtcl || (top_topology_integer_hwtcl == 4)"                               NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_flrcmpl_interfaces                                                       "Check User Guide for details"                                }\
        
    \
        { p2_app_ss_st_flrcmpl_tvalid           input          1							    			tvalid                              p2_st_flrcmpl		axi4stream                 end				"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 ||core4_0_virtual_rp_ep_mode_integer_hwtcl"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_flrcmpl_interfaces                                                       "Check User Guide for details"                                }\
        { p2_app_ss_st_flrcmpl_tdata            input          20                                	    	tdata		                        p2_st_flrcmpl		axi4stream                 end				"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 ||core4_0_virtual_rp_ep_mode_integer_hwtcl"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_flrcmpl_interfaces                                                       "Check User Guide for details"                                }\
        { p2_ss_app_st_flrcmpl_tready           output         1                                 	    	tready		                        p2_st_flrcmpl		axi4stream                 start			"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 ||core4_0_virtual_rp_ep_mode_integer_hwtcl"                               NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_flrcmpl_interfaces                                                       "Check User Guide for details"                                }\
        
    \
        { p3_app_ss_st_flrcmpl_tvalid           input          1							    			tvalid                              p3_st_flrcmpl		axi4stream                 end				"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 ||core4_1_virtual_rp_ep_mode_integer_hwtcl || (top_topology_integer_hwtcl == 4)"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_flrcmpl_interfaces                                                       "Check User Guide for details"                                }\
        { p3_app_ss_st_flrcmpl_tdata            input          20                                	    	tdata		                        p3_st_flrcmpl		axi4stream                 end				"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 ||core4_1_virtual_rp_ep_mode_integer_hwtcl || (top_topology_integer_hwtcl == 4)"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_flrcmpl_interfaces                                                       "Check User Guide for details"                                }\
        { p3_ss_app_st_flrcmpl_tready           output         1                                 	    	tready		                        p3_st_flrcmpl		axi4stream                 start			"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 ||core4_1_virtual_rp_ep_mode_integer_hwtcl || (top_topology_integer_hwtcl == 4)"                               NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_flrcmpl_interfaces                                                       "Check User Guide for details"                                }\
        
    \
        { p0_ss_app_st_ctrlshadow_tvalid        output         1							    			tvalid                              p0_st_ctrlshadow	axi4stream                 start	    	"!core16_ctrl_shadow_en_hwtcl ||core16_virtual_rp_ep_mode_integer_hwtcl"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_ctrlshadow_interfaces                                                       "Check User Guide for details"                                }\
        { p0_ss_app_st_ctrlshadow_tdata         output         40                                	    	tdata		                        p0_st_ctrlshadow	axi4stream                 start            "!core16_ctrl_shadow_en_hwtcl ||core16_virtual_rp_ep_mode_integer_hwtcl"                                            NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_ctrlshadow_interfaces                                                       "Check User Guide for details"                                }\
    \
        { p1_ss_app_st_ctrlshadow_tvalid        output         1							    			tvalid                              p1_st_ctrlshadow	axi4stream                 start	    	"pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || !core8_ctrl_shadow_en_hwtcl || core8_virtual_rp_ep_mode_integer_hwtcl || (top_topology_integer_hwtcl == 4)"					NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_ctrlshadow_interfaces                                                       "Check User Guide for details"                                }\
        { p1_ss_app_st_ctrlshadow_tdata         output         40                                	    	tdata		                        p1_st_ctrlshadow	axi4stream                 start            "pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || !core8_ctrl_shadow_en_hwtcl || core8_virtual_rp_ep_mode_integer_hwtcl || (top_topology_integer_hwtcl == 4)"					NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_ctrlshadow_interfaces                                                       "Check User Guide for details"                                }\
    \
        { p2_ss_app_st_ctrlshadow_tvalid        output         1							    			tvalid                              p2_st_ctrlshadow	axi4stream                 start	    	"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || !core4_0_ctrl_shadow_en_hwtcl || core4_0_virtual_rp_ep_mode_integer_hwtcl"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_ctrlshadow_interfaces                                                       "Check User Guide for details"                                }\
        { p2_ss_app_st_ctrlshadow_tdata         output         40                                	    	tdata		                        p2_st_ctrlshadow	axi4stream                 start            "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || !core4_0_ctrl_shadow_en_hwtcl || core4_0_virtual_rp_ep_mode_integer_hwtcl"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_ctrlshadow_interfaces                                                       "Check User Guide for details"                                }\
    \
        { p3_ss_app_st_ctrlshadow_tvalid        output         1							    			tvalid                              p3_st_ctrlshadow	axi4stream                 start	    	"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || !core4_1_ctrl_shadow_en_hwtcl || core4_1_virtual_rp_ep_mode_integer_hwtcl || (top_topology_integer_hwtcl == 4)"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_ctrlshadow_interfaces                                                       "Check User Guide for details"                                }\
        { p3_ss_app_st_ctrlshadow_tdata         output         40                                	    	tdata		                        p3_st_ctrlshadow	axi4stream                 start            "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || !core4_1_ctrl_shadow_en_hwtcl || core4_1_virtual_rp_ep_mode_integer_hwtcl || (top_topology_integer_hwtcl == 4)"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_ctrlshadow_interfaces                                                       "Check User Guide for details"                                }\
    \
        { p0_ss_app_st_txcrdt_tvalid        	output         1							    			tvalid                              p0_st_txcrdt		axi4stream                 start	    	false                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_txcrdt_interfaces                                                       "Check User Guide for details"                                }\
        { p0_ss_app_st_txcrdt_tdata         	output         19                                	    	tdata		                        p0_st_txcrdt		axi4stream                 start            false                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_txcrdt_interfaces                                                       "Check User Guide for details"                                }\
    \
        { p1_ss_app_st_txcrdt_tvalid        	output         1							    			tvalid                              p1_st_txcrdt		axi4stream                 start	    	"pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || (top_topology_integer_hwtcl == 4)"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_txcrdt_interfaces                                                       "Check User Guide for details"                                }\
        { p1_ss_app_st_txcrdt_tdata         	output         19                                	    	tdata		                        p1_st_txcrdt		axi4stream                 start            "pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || (top_topology_integer_hwtcl == 4)"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_txcrdt_interfaces                                                       "Check User Guide for details"                                }\
    \
        { p2_ss_app_st_txcrdt_tvalid        	output         1							    			tvalid                              p2_st_txcrdt		axi4stream                 start	    	"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_txcrdt_interfaces                                                       "Check User Guide for details"                                }\
        { p2_ss_app_st_txcrdt_tdata         	output         19                                	    	tdata		                        p2_st_txcrdt		axi4stream                 start            "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_txcrdt_interfaces                                                       "Check User Guide for details"                                }\
    \
        { p3_ss_app_st_txcrdt_tvalid        	output         1							    			tvalid                              p3_st_txcrdt		axi4stream                 start	    	"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || (top_topology_integer_hwtcl == 4)"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_txcrdt_interfaces                                                       "Check User Guide for details"                                }\
        { p3_ss_app_st_txcrdt_tdata         	output         19                                	    	tdata		                        p3_st_txcrdt		axi4stream                 start            "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || (top_topology_integer_hwtcl == 4)"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_txcrdt_interfaces                                                       "Check User Guide for details"                                }\

    \
        { p0_ss_app_st_rxcrdt_tvalid        	input         1							    		 	tvalid                              p0_st_rxcrdt		axi4stream                 end	       "tile_integer <2 ||core16_hip_native_mode_user_hwtcl==0"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_rxcrdt_interfaces                                                       "Check User Guide for details"                                }\
        { p0_ss_app_st_rxcrdt_tdata         	input         19                                	    tdata		                        p0_st_rxcrdt		axi4stream                 end         "tile_integer <2 ||core16_hip_native_mode_user_hwtcl==0"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_rxcrdt_interfaces                                                       "Check User Guide for details"                                }\
    \
        { p1_ss_app_st_rxcrdt_tvalid        	input         1							    			tvalid                              p1_st_rxcrdt		axi4stream                 end	    	"tile_integer <2 ||core8_hip_native_mode_user_hwtcl==0 ||pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || (top_topology_integer_hwtcl == 4)"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_rxcrdt_interfaces                                                       "Check User Guide for details"                                }\
        { p1_ss_app_st_rxcrdt_tdata         	input         19                                	    tdata		                        p1_st_rxcrdt		axi4stream                 end          "tile_integer <2 ||core8_hip_native_mode_user_hwtcl==0 ||pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || (top_topology_integer_hwtcl == 4)"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_rxcrdt_interfaces                                                       "Check User Guide for details"                                }\
    \
        { p2_ss_app_st_rxcrdt_tvalid        	input         1							    			tvalid                              p2_st_rxcrdt		axi4stream                 end	    	"tile_integer <2 ||core4_0_hip_native_mode_user_hwtcl==0||pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_rxcrdt_interfaces                                                       "Check User Guide for details"                                }\
        { p2_ss_app_st_rxcrdt_tdata         	input         19                                	    tdata		                        p2_st_rxcrdt		axi4stream                 end          "tile_integer <2 ||core4_0_hip_native_mode_user_hwtcl==0||pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_rxcrdt_interfaces                                                       "Check User Guide for details"                                }\
    \
        { p3_ss_app_st_rxcrdt_tvalid        	input         1							    			tvalid                              p3_st_rxcrdt		axi4stream                 end	    	"tile_integer <2 ||core4_1_hip_native_mode_user_hwtcl==0||pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || (top_topology_integer_hwtcl == 4)"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_rxcrdt_interfaces                                                       "Check User Guide for details"                                }\
        { p3_ss_app_st_rxcrdt_tdata         	input         19                                	    tdata		                        p3_st_rxcrdt		axi4stream                 end          "tile_integer <2 ||core4_1_hip_native_mode_user_hwtcl==0||pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || (top_topology_integer_hwtcl == 4)"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_rxcrdt_interfaces                                                       "Check User Guide for details"                                }\

    \
        { p0_ss_app_st_cplto_tvalid        		output         1							    			tvalid                              p0_st_cplto		    axi4stream                 start	    	"!core16_comp_timeout_en_hwtcl"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_cplto_interfaces                                                       "Check User Guide for details"                                }\
        { p0_ss_app_st_cplto_tdata         		output         30                                	    	tdata		                        p0_st_cplto		    axi4stream                 start            "!core16_comp_timeout_en_hwtcl"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_cplto_interfaces                                                       "Check User Guide for details"                                }\
    \
        { p1_ss_app_st_cplto_tvalid        		output         1							    			tvalid                              p1_st_cplto		    axi4stream                 start	    	"pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || !core8_comp_timeout_en_hwtcl || (top_topology_integer_hwtcl == 4)"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_cplto_interfaces                                                       "Check User Guide for details"                                }\
        { p1_ss_app_st_cplto_tdata         		output         30                                	    	tdata		                        p1_st_cplto		    axi4stream                 start            "pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || !core8_comp_timeout_en_hwtcl || (top_topology_integer_hwtcl == 4)"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_cplto_interfaces                                                       "Check User Guide for details"                                }\
    \
        { p2_ss_app_st_cplto_tvalid        		output         1							    			tvalid                              p2_st_cplto		    axi4stream                 start	    	"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || !core4_0_comp_timeout_en_hwtcl"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_cplto_interfaces                                                       "Check User Guide for details"                                }\
        { p2_ss_app_st_cplto_tdata         		output         30                                	    	tdata		                        p2_st_cplto		    axi4stream                 start            "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || !core4_0_comp_timeout_en_hwtcl"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_cplto_interfaces                                                       "Check User Guide for details"                                }\
    \
        { p3_ss_app_st_cplto_tvalid        		output         1							    			tvalid                              p3_st_cplto		    axi4stream                 start	    	"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || !core4_1_comp_timeout_en_hwtcl || (top_topology_integer_hwtcl == 4)"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_cplto_interfaces                                                       "Check User Guide for details"                                }\
        { p3_ss_app_st_cplto_tdata         		output         30                                	    	tdata		                        p3_st_cplto		    axi4stream                 start            "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || !core4_1_comp_timeout_en_hwtcl || (top_topology_integer_hwtcl == 4)"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_cplto_interfaces                                                       "Check User Guide for details"                                }\
    \
        { p0_app_ss_lite_csr_awvalid        	input          1							    			awvalid      	p0_lite_csr		axi4lite                 end	    		"rtile_debug_toolkit_hwtcl ||ftile_debug_toolkit_hwtcl || ptile_debug_toolkit_hwtcl"                                           NOVAL                  ::intel_pcie_ss_axi::interfaces::elaborate_lite_csr_interfaces                                                               NOVAL                               }\
        { p0_ss_app_lite_csr_awready         	output         1                                	    	awready			p0_lite_csr		axi4lite                 start           "rtile_debug_toolkit_hwtcl ||ftile_debug_toolkit_hwtcl || ptile_debug_toolkit_hwtcl"                                           NOVAL                     ::intel_pcie_ss_axi::interfaces::elaborate_lite_csr_interfaces                                                               NOVAL                               }\
        { p0_app_ss_lite_csr_awaddr        		input          core16_LiteSlvAWD			    			awaddr			p0_lite_csr		axi4lite                 end	    		"rtile_debug_toolkit_hwtcl ||ftile_debug_toolkit_hwtcl || ptile_debug_toolkit_hwtcl"                                           NOVAL                  ::intel_pcie_ss_axi::interfaces::elaborate_lite_csr_interfaces                                                               NOVAL                               }\
        { p0_app_ss_lite_csr_awprot        		input          3                			    			awprot			p0_lite_csr		axi4lite                 end	    		"rtile_debug_toolkit_hwtcl ||ftile_debug_toolkit_hwtcl || ptile_debug_toolkit_hwtcl"                                           NOVAL                  ::intel_pcie_ss_axi::interfaces::elaborate_lite_csr_interfaces                                                               NOVAL                               }\
    \
        { p0_app_ss_lite_csr_wvalid        		input          1							    			wvalid			p0_lite_csr		axi4lite                 end	    		"rtile_debug_toolkit_hwtcl ||ftile_debug_toolkit_hwtcl || ptile_debug_toolkit_hwtcl"                                           NOVAL                 ::intel_pcie_ss_axi::interfaces::elaborate_lite_csr_interfaces                                                                 NOVAL                               }\
        { p0_ss_app_lite_csr_wready         	output         1                                	    	wready			p0_lite_csr		axi4lite                 start           "rtile_debug_toolkit_hwtcl ||ftile_debug_toolkit_hwtcl || ptile_debug_toolkit_hwtcl"                                           NOVAL                    ::intel_pcie_ss_axi::interfaces::elaborate_lite_csr_interfaces                                                               NOVAL                               }\
        { p0_app_ss_lite_csr_wdata        		input          core16_LiteSlvDWD			    			wdata			p0_lite_csr		axi4lite                 end	    		"rtile_debug_toolkit_hwtcl ||ftile_debug_toolkit_hwtcl || ptile_debug_toolkit_hwtcl"                                           NOVAL                 ::intel_pcie_ss_axi::interfaces::elaborate_lite_csr_interfaces                                                               NOVAL                               }\
        { p0_app_ss_lite_csr_wstrb        		input          core16_LiteSlvDWD/8							wstrb			p0_lite_csr		axi4lite                 end	    		"rtile_debug_toolkit_hwtcl ||ftile_debug_toolkit_hwtcl || ptile_debug_toolkit_hwtcl"                                           NOVAL                 ::intel_pcie_ss_axi::interfaces::elaborate_lite_csr_interfaces                                                               NOVAL                               }\
    \
        { p0_ss_app_lite_csr_bvalid         	output         1                                	    	bvalid			p0_lite_csr		axi4lite                 start           "rtile_debug_toolkit_hwtcl ||ftile_debug_toolkit_hwtcl || ptile_debug_toolkit_hwtcl"                                           NOVAL                     ::intel_pcie_ss_axi::interfaces::elaborate_lite_csr_interfaces                                                               NOVAL                               }\
        { p0_app_ss_lite_csr_bready        		input          1										    bready			p0_lite_csr		axi4lite                 end	    		"rtile_debug_toolkit_hwtcl ||ftile_debug_toolkit_hwtcl || ptile_debug_toolkit_hwtcl"                                           NOVAL                  ::intel_pcie_ss_axi::interfaces::elaborate_lite_csr_interfaces                                                               NOVAL                               }\
        { p0_ss_app_lite_csr_bresp        		output         2							    			bresp			p0_lite_csr	    axi4lite                 start	    	"rtile_debug_toolkit_hwtcl ||ftile_debug_toolkit_hwtcl || ptile_debug_toolkit_hwtcl"                                           NOVAL                      ::intel_pcie_ss_axi::interfaces::elaborate_lite_csr_interfaces                                                               NOVAL                               }\
    \
        { p0_app_ss_lite_csr_arvalid         	input          1                                	    	arvalid			p0_lite_csr		axi4lite                 end           	"rtile_debug_toolkit_hwtcl ||ftile_debug_toolkit_hwtcl || ptile_debug_toolkit_hwtcl"                                           NOVAL                      ::intel_pcie_ss_axi::interfaces::elaborate_lite_csr_interfaces                                                            NOVAL                               }\
        { p0_ss_app_lite_csr_arready        	output         1											arready      	p0_lite_csr	    axi4lite                 start	    	"rtile_debug_toolkit_hwtcl ||ftile_debug_toolkit_hwtcl || ptile_debug_toolkit_hwtcl"                                           NOVAL                      ::intel_pcie_ss_axi::interfaces::elaborate_lite_csr_interfaces                                                            NOVAL                               }\
        { p0_app_ss_lite_csr_araddr        		input          core16_LiteSlvAWD			    			araddr			p0_lite_csr		axi4lite                 end	    		"rtile_debug_toolkit_hwtcl ||ftile_debug_toolkit_hwtcl || ptile_debug_toolkit_hwtcl"                                           NOVAL                  ::intel_pcie_ss_axi::interfaces::elaborate_lite_csr_interfaces                                                               NOVAL                               }\
        { p0_app_ss_lite_csr_arprot        		input          3                			    			arprot			p0_lite_csr		axi4lite                 end	    		"rtile_debug_toolkit_hwtcl ||ftile_debug_toolkit_hwtcl || ptile_debug_toolkit_hwtcl"                                           NOVAL                  ::intel_pcie_ss_axi::interfaces::elaborate_lite_csr_interfaces                                                               NOVAL                               }\
    \
        { p0_ss_app_lite_csr_rvalid        		output         1							    			rvalid			p0_lite_csr		axi4lite                 start	    	"rtile_debug_toolkit_hwtcl ||ftile_debug_toolkit_hwtcl || ptile_debug_toolkit_hwtcl"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_lite_csr_interfaces                                                               NOVAL                               }\
        { p0_app_ss_lite_csr_rready         	input          1                                	    	rready			p0_lite_csr		axi4lite                 end           	"rtile_debug_toolkit_hwtcl ||ftile_debug_toolkit_hwtcl || ptile_debug_toolkit_hwtcl"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_lite_csr_interfaces                                                               NOVAL                               }\
        { p0_ss_app_lite_csr_rdata        		output         core16_LiteSlvDWD			    		    rdata			p0_lite_csr		axi4lite                 start	    	"rtile_debug_toolkit_hwtcl ||ftile_debug_toolkit_hwtcl || ptile_debug_toolkit_hwtcl"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_lite_csr_interfaces                                                               NOVAL                               }\
        { p0_ss_app_lite_csr_rresp        		output         2											rresp			p0_lite_csr		axi4lite                 start	    	"rtile_debug_toolkit_hwtcl ||ftile_debug_toolkit_hwtcl || ptile_debug_toolkit_hwtcl"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_lite_csr_interfaces                                                               NOVAL                               }\
    \
        { p1_app_ss_lite_csr_awvalid        	input          1							    			awvalid      	p1_lite_csr		axi4lite                 end	    		"pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 ||rtile_debug_toolkit_hwtcl || ftile_debug_toolkit_hwtcl || ptile_debug_toolkit_hwtcl || (top_topology_integer_hwtcl == 4)"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_lite_csr_interfaces                                                               NOVAL                               }\
        { p1_ss_app_lite_csr_awready         	output         1                                	    	awready			p1_lite_csr		axi4lite                  start           "pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 ||rtile_debug_toolkit_hwtcl || ftile_debug_toolkit_hwtcl || ptile_debug_toolkit_hwtcl || (top_topology_integer_hwtcl == 4)"                                           NOVAL                     ::intel_pcie_ss_axi::interfaces::elaborate_lite_csr_interfaces                                                               NOVAL                               }\
        { p1_app_ss_lite_csr_awaddr        		input          core8_LiteSlvAWD			    				awaddr			p1_lite_csr		axi4lite                  end	    		"pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 ||rtile_debug_toolkit_hwtcl || ftile_debug_toolkit_hwtcl || ptile_debug_toolkit_hwtcl || (top_topology_integer_hwtcl == 4)"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_lite_csr_interfaces                                                               NOVAL                               }\
        { p1_app_ss_lite_csr_awprot        		input          3                			    			awprot			p1_lite_csr		axi4lite                 end	    		"pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 ||rtile_debug_toolkit_hwtcl ||ftile_debug_toolkit_hwtcl || ptile_debug_toolkit_hwtcl || (top_topology_integer_hwtcl == 4)"                                           NOVAL                  ::intel_pcie_ss_axi::interfaces::elaborate_lite_csr_interfaces                                                               NOVAL                               }\
    \
        { p1_app_ss_lite_csr_wvalid        		input          1							    			wvalid			p1_lite_csr	    axi4lite              end	    		"pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 ||rtile_debug_toolkit_hwtcl || ftile_debug_toolkit_hwtcl || ptile_debug_toolkit_hwtcl || (top_topology_integer_hwtcl == 4)"                                           NOVAL                    ::intel_pcie_ss_axi::interfaces::elaborate_lite_csr_interfaces                                                               NOVAL                               }\
        { p1_ss_app_lite_csr_wready         	output         1                                	        wready			p1_lite_csr		axi4lite                  start           "pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 ||rtile_debug_toolkit_hwtcl || ftile_debug_toolkit_hwtcl || ptile_debug_toolkit_hwtcl || (top_topology_integer_hwtcl == 4)"                                           NOVAL                  ::intel_pcie_ss_axi::interfaces::elaborate_lite_csr_interfaces                                                               NOVAL                               }\
        { p1_app_ss_lite_csr_wdata        		input          core8_LiteSlvDWD			    				wdata			p1_lite_csr		axi4lite                  end	    		"pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 ||rtile_debug_toolkit_hwtcl || ftile_debug_toolkit_hwtcl || ptile_debug_toolkit_hwtcl || (top_topology_integer_hwtcl == 4)"                                           NOVAL                ::intel_pcie_ss_axi::interfaces::elaborate_lite_csr_interfaces                                                               NOVAL                               }\
        { p1_app_ss_lite_csr_wstrb        		input          core8_LiteSlvDWD/8							wstrb			p1_lite_csr		axi4lite                  end	    		"pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 ||rtile_debug_toolkit_hwtcl || ftile_debug_toolkit_hwtcl || ptile_debug_toolkit_hwtcl || (top_topology_integer_hwtcl == 4)"                                           NOVAL                ::intel_pcie_ss_axi::interfaces::elaborate_lite_csr_interfaces                                                               NOVAL                               }\
    \
        { p1_ss_app_lite_csr_bvalid         	output         1                                	    	bvalid			p1_lite_csr		axi4lite                  start           "pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 ||rtile_debug_toolkit_hwtcl || ftile_debug_toolkit_hwtcl || ptile_debug_toolkit_hwtcl || (top_topology_integer_hwtcl == 4)"                                           NOVAL                  ::intel_pcie_ss_axi::interfaces::elaborate_lite_csr_interfaces                                                               NOVAL                               }\
        { p1_app_ss_lite_csr_bready        		input          1											bready			p1_lite_csr		axi4lite                  end	    		"pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 ||rtile_debug_toolkit_hwtcl || ftile_debug_toolkit_hwtcl || ptile_debug_toolkit_hwtcl || (top_topology_integer_hwtcl == 4)"                                           NOVAL                ::intel_pcie_ss_axi::interfaces::elaborate_lite_csr_interfaces                                                               NOVAL                               }\
        { p1_ss_app_lite_csr_bresp        		output         2							    		    bresp			p1_lite_csr	    axi4lite              start	    	"pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 ||rtile_debug_toolkit_hwtcl || ftile_debug_toolkit_hwtcl || ptile_debug_toolkit_hwtcl || (top_topology_integer_hwtcl == 4)"                                           NOVAL                        ::intel_pcie_ss_axi::interfaces::elaborate_lite_csr_interfaces                                                                NOVAL                               }\
    \
        { p1_app_ss_lite_csr_arvalid         	input          1                                	    	arvalid			p1_lite_csr		axi4lite                 end           	"pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 ||rtile_debug_toolkit_hwtcl || ftile_debug_toolkit_hwtcl || ptile_debug_toolkit_hwtcl || (top_topology_integer_hwtcl == 4)"                                           NOVAL                    ::intel_pcie_ss_axi::interfaces::elaborate_lite_csr_interfaces                                                              NOVAL                               }\
        { p1_ss_app_lite_csr_arready        	output         1										    arready      	p1_lite_csr		axi4lite                 start	    	"pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 ||rtile_debug_toolkit_hwtcl || ftile_debug_toolkit_hwtcl || ptile_debug_toolkit_hwtcl || (top_topology_integer_hwtcl == 4)"                                           NOVAL                    ::intel_pcie_ss_axi::interfaces::elaborate_lite_csr_interfaces                                                               NOVAL                               }\
        { p1_app_ss_lite_csr_araddr        		input          core8_LiteSlvAWD			    				araddr			p1_lite_csr		axi4lite                 end	    		"pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 ||rtile_debug_toolkit_hwtcl || ftile_debug_toolkit_hwtcl || ptile_debug_toolkit_hwtcl || (top_topology_integer_hwtcl == 4)"                                           NOVAL                ::intel_pcie_ss_axi::interfaces::elaborate_lite_csr_interfaces                                                               NOVAL                               }\
        { p1_app_ss_lite_csr_arprot        		input          3                			    			arprot			p1_lite_csr		axi4lite                 end	    		"pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 ||rtile_debug_toolkit_hwtcl ||ftile_debug_toolkit_hwtcl || ptile_debug_toolkit_hwtcl || (top_topology_integer_hwtcl == 4)"                                           NOVAL                  ::intel_pcie_ss_axi::interfaces::elaborate_lite_csr_interfaces                                                               NOVAL                               }\
    \
        { p1_ss_app_lite_csr_rvalid        		output         1							    			rvalid			p1_lite_csr		axi4lite                  start	    	"pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 ||rtile_debug_toolkit_hwtcl || ftile_debug_toolkit_hwtcl || ptile_debug_toolkit_hwtcl || (top_topology_integer_hwtcl == 4)"                                           NOVAL                    ::intel_pcie_ss_axi::interfaces::elaborate_lite_csr_interfaces                                                              NOVAL                               }\
        { p1_app_ss_lite_csr_rready         	input          1                                	    	rready			p1_lite_csr	    axi4lite                  end           	"pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 ||rtile_debug_toolkit_hwtcl || ftile_debug_toolkit_hwtcl || ptile_debug_toolkit_hwtcl || (top_topology_integer_hwtcl == 4)"                                           NOVAL                ::intel_pcie_ss_axi::interfaces::elaborate_lite_csr_interfaces                                                               NOVAL                               }\
        { p1_ss_app_lite_csr_rdata        		output         core8_LiteSlvDWD			    				rdata			p1_lite_csr	    axi4lite                  start	    	"pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 ||rtile_debug_toolkit_hwtcl || ftile_debug_toolkit_hwtcl || ptile_debug_toolkit_hwtcl || (top_topology_integer_hwtcl == 4)"                                           NOVAL                    ::intel_pcie_ss_axi::interfaces::elaborate_lite_csr_interfaces                                                               NOVAL                               }\
        { p1_ss_app_lite_csr_rresp        		output         2											rresp			p1_lite_csr		axi4lite                  start	    	"pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 ||rtile_debug_toolkit_hwtcl || ftile_debug_toolkit_hwtcl || ptile_debug_toolkit_hwtcl || (top_topology_integer_hwtcl == 4)"                                           NOVAL                    ::intel_pcie_ss_axi::interfaces::elaborate_lite_csr_interfaces                                                               NOVAL                               }\
    \
        { p2_app_ss_lite_csr_awvalid        	input          1							    			awvalid      	p2_lite_csr		axi4lite                  end	    		"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 ||rtile_debug_toolkit_hwtcl || ftile_debug_toolkit_hwtcl || ptile_debug_toolkit_hwtcl"                                           NOVAL                ::intel_pcie_ss_axi::interfaces::elaborate_lite_csr_interfaces                                                               NOVAL                               }\
        { p2_ss_app_lite_csr_awready         	output         1                                	    	awready			p2_lite_csr		axi4lite                  start           "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 ||rtile_debug_toolkit_hwtcl || ftile_debug_toolkit_hwtcl || ptile_debug_toolkit_hwtcl"                                           NOVAL                  ::intel_pcie_ss_axi::interfaces::elaborate_lite_csr_interfaces                                                              NOVAL                               }\
        { p2_app_ss_lite_csr_awaddr        		input          core4_0_LiteSlvAWD			    		    awaddr			p2_lite_csr		axi4lite                  end	    		"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 ||rtile_debug_toolkit_hwtcl || ftile_debug_toolkit_hwtcl || ptile_debug_toolkit_hwtcl"                                           NOVAL                ::intel_pcie_ss_axi::interfaces::elaborate_lite_csr_interfaces                                                               NOVAL                               }\
        { p2_app_ss_lite_csr_awprot        		input          3                			    			awprot			p2_lite_csr		axi4lite                 end	    		"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 ||rtile_debug_toolkit_hwtcl ||ftile_debug_toolkit_hwtcl || ptile_debug_toolkit_hwtcl"                                           NOVAL                  ::intel_pcie_ss_axi::interfaces::elaborate_lite_csr_interfaces                                                               NOVAL                               }\
    \
        { p2_app_ss_lite_csr_wvalid        		input          1							    			wvalid			p2_lite_csr  	axi4lite                  end	    		"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 ||rtile_debug_toolkit_hwtcl || ftile_debug_toolkit_hwtcl || ptile_debug_toolkit_hwtcl"                                           NOVAL                ::intel_pcie_ss_axi::interfaces::elaborate_lite_csr_interfaces                                                               NOVAL                               }\
        { p2_ss_app_lite_csr_wready         	output         1                                	    	wready			p2_lite_csr		axi4lite                  start           "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 ||rtile_debug_toolkit_hwtcl || ftile_debug_toolkit_hwtcl || ptile_debug_toolkit_hwtcl"                                           NOVAL                  ::intel_pcie_ss_axi::interfaces::elaborate_lite_csr_interfaces                                                               NOVAL                               }\
        { p2_app_ss_lite_csr_wdata        		input          core4_0_LiteSlvDWD			    			wdata			p2_lite_csr		axi4lite                  end	    		"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 ||rtile_debug_toolkit_hwtcl || ftile_debug_toolkit_hwtcl || ptile_debug_toolkit_hwtcl"                                           NOVAL                ::intel_pcie_ss_axi::interfaces::elaborate_lite_csr_interfaces                                                               NOVAL                               }\
        { p2_app_ss_lite_csr_wstrb        		input          core4_0_LiteSlvDWD/8							wstrb			p2_lite_csr 	axi4lite                 end	    		"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 ||rtile_debug_toolkit_hwtcl || ftile_debug_toolkit_hwtcl || ptile_debug_toolkit_hwtcl"                                           NOVAL                ::intel_pcie_ss_axi::interfaces::elaborate_lite_csr_interfaces                                                               NOVAL                               }\
    \
        { p2_ss_app_lite_csr_bvalid         	output         1                                	    	bvalid			p2_lite_csr		axi4lite                  start           "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 ||rtile_debug_toolkit_hwtcl || ftile_debug_toolkit_hwtcl || ptile_debug_toolkit_hwtcl"                                           NOVAL                  ::intel_pcie_ss_axi::interfaces::elaborate_lite_csr_interfaces                                                               NOVAL                               }\
        { p2_app_ss_lite_csr_bready        		input          1											bready			p2_lite_csr		axi4lite                  end	    		"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 ||rtile_debug_toolkit_hwtcl || ftile_debug_toolkit_hwtcl || ptile_debug_toolkit_hwtcl"                                           NOVAL                ::intel_pcie_ss_axi::interfaces::elaborate_lite_csr_interfaces                                                               NOVAL                               }\
        { p2_ss_app_lite_csr_bresp        		output         2							    			bresp			p2_lite_csr		axi4lite                  start	    	"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 ||rtile_debug_toolkit_hwtcl || ftile_debug_toolkit_hwtcl || ptile_debug_toolkit_hwtcl"                                           NOVAL                    ::intel_pcie_ss_axi::interfaces::elaborate_lite_csr_interfaces                                                               NOVAL                               }\
    \
        { p2_app_ss_lite_csr_arvalid         	input          1                                	    	arvalid			p2_lite_csr		axi4lite                  end           	"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 ||rtile_debug_toolkit_hwtcl || ftile_debug_toolkit_hwtcl || ptile_debug_toolkit_hwtcl"                                           NOVAL                ::intel_pcie_ss_axi::interfaces::elaborate_lite_csr_interfaces                                                               NOVAL                               }\
        { p2_ss_app_lite_csr_arready        	output         1											arready      	p2_lite_csr	    axi4lite                  start	    	"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 ||rtile_debug_toolkit_hwtcl || ftile_debug_toolkit_hwtcl || ptile_debug_toolkit_hwtcl"                                           NOVAL                    ::intel_pcie_ss_axi::interfaces::elaborate_lite_csr_interfaces                                                               NOVAL                               }\
        { p2_app_ss_lite_csr_araddr        		input          core4_0_LiteSlvAWD			    			araddr			p2_lite_csr		axi4lite                  end	    		"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 ||rtile_debug_toolkit_hwtcl || ftile_debug_toolkit_hwtcl || ptile_debug_toolkit_hwtcl"                                           NOVAL                ::intel_pcie_ss_axi::interfaces::elaborate_lite_csr_interfaces                                                               NOVAL                               }\
        { p2_app_ss_lite_csr_arprot        		input          3                			    			arprot			p2_lite_csr		axi4lite                 end	    		"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 ||rtile_debug_toolkit_hwtcl ||ftile_debug_toolkit_hwtcl || ptile_debug_toolkit_hwtcl"                                           NOVAL                  ::intel_pcie_ss_axi::interfaces::elaborate_lite_csr_interfaces                                                               NOVAL                               }\
    \
        { p2_ss_app_lite_csr_rvalid        		output         1							    		    rvalid			p2_lite_csr		axi4lite                  start	    	"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 ||rtile_debug_toolkit_hwtcl || ftile_debug_toolkit_hwtcl || ptile_debug_toolkit_hwtcl"                                           NOVAL                    ::intel_pcie_ss_axi::interfaces::elaborate_lite_csr_interfaces                                                               NOVAL                               }\
        { p2_app_ss_lite_csr_rready         	input          1                                	        rready			p2_lite_csr 	axi4lite                  end           	"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 ||rtile_debug_toolkit_hwtcl || ftile_debug_toolkit_hwtcl || ptile_debug_toolkit_hwtcl"                                           NOVAL                ::intel_pcie_ss_axi::interfaces::elaborate_lite_csr_interfaces                                                              NOVAL                               }\
        { p2_ss_app_lite_csr_rdata        		output         core4_0_LiteSlvDWD			    			rdata			p2_lite_csr		axi4lite                  start	    	"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 ||rtile_debug_toolkit_hwtcl || ftile_debug_toolkit_hwtcl || ptile_debug_toolkit_hwtcl"                                           NOVAL                    ::intel_pcie_ss_axi::interfaces::elaborate_lite_csr_interfaces                                                               NOVAL                               }\
        { p2_ss_app_lite_csr_rresp        		output         2										    rresp			p2_lite_csr		axi4lite                  start	    	"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 ||rtile_debug_toolkit_hwtcl || ftile_debug_toolkit_hwtcl || ptile_debug_toolkit_hwtcl"                                           NOVAL                    ::intel_pcie_ss_axi::interfaces::elaborate_lite_csr_interfaces                                                               NOVAL                               }\
    \
        { p3_app_ss_lite_csr_awvalid        	input          1							    			awvalid      	p3_lite_csr	    axi4lite 	                 end	    		"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 ||rtile_debug_toolkit_hwtcl || ftile_debug_toolkit_hwtcl || ptile_debug_toolkit_hwtcl || (top_topology_integer_hwtcl == 4)"                                           NOVAL            ::intel_pcie_ss_axi::interfaces::elaborate_lite_csr_interfaces                                                               NOVAL                               }\
        { p3_ss_app_lite_csr_awready         	output         1                                	    	awready			p3_lite_csr		axi4lite                  start           "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 ||rtile_debug_toolkit_hwtcl || ftile_debug_toolkit_hwtcl || ptile_debug_toolkit_hwtcl || (top_topology_integer_hwtcl == 4)"                                           NOVAL                  ::intel_pcie_ss_axi::interfaces::elaborate_lite_csr_interfaces                                                               NOVAL                               }\
        { p3_app_ss_lite_csr_awaddr        		input          core4_1_LiteSlvAWD			    			awaddr			p3_lite_csr		axi4lite                 end	    		"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 ||rtile_debug_toolkit_hwtcl || ftile_debug_toolkit_hwtcl || ptile_debug_toolkit_hwtcl || (top_topology_integer_hwtcl == 4)"                                           NOVAL                ::intel_pcie_ss_axi::interfaces::elaborate_lite_csr_interfaces                                                               NOVAL                               }\
        { p3_app_ss_lite_csr_awprot        		input          3                			    			awprot			p3_lite_csr		axi4lite                 end	    		"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 ||rtile_debug_toolkit_hwtcl ||ftile_debug_toolkit_hwtcl || ptile_debug_toolkit_hwtcl || (top_topology_integer_hwtcl == 4)"                                           NOVAL                  ::intel_pcie_ss_axi::interfaces::elaborate_lite_csr_interfaces                                                               NOVAL                               }\
    \
        { p3_app_ss_lite_csr_wvalid        		input          1							    			wvalid			p3_lite_csr		axi4lite                  end	    		"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 ||rtile_debug_toolkit_hwtcl || ftile_debug_toolkit_hwtcl || ptile_debug_toolkit_hwtcl || (top_topology_integer_hwtcl == 4)"                                           NOVAL                ::intel_pcie_ss_axi::interfaces::elaborate_lite_csr_interfaces                                                               NOVAL                               }\
        { p3_ss_app_lite_csr_wready         	output         1                                	    	wready			p3_lite_csr		axi4lite                  start           "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 ||rtile_debug_toolkit_hwtcl || ftile_debug_toolkit_hwtcl || ptile_debug_toolkit_hwtcl || (top_topology_integer_hwtcl == 4)"                                           NOVAL                  ::intel_pcie_ss_axi::interfaces::elaborate_lite_csr_interfaces                                                               NOVAL                               }\
        { p3_app_ss_lite_csr_wdata        		input          core4_1_LiteSlvDWD			    			wdata			p3_lite_csr		axi4lite                  end	    		"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 ||rtile_debug_toolkit_hwtcl || ftile_debug_toolkit_hwtcl || ptile_debug_toolkit_hwtcl || (top_topology_integer_hwtcl == 4)"                                           NOVAL                ::intel_pcie_ss_axi::interfaces::elaborate_lite_csr_interfaces                                                               NOVAL                               }\
        { p3_app_ss_lite_csr_wstrb        		input          core4_1_LiteSlvDWD/8							wstrb			p3_lite_csr		axi4lite                  end	    		"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 ||rtile_debug_toolkit_hwtcl || ftile_debug_toolkit_hwtcl || ptile_debug_toolkit_hwtcl || (top_topology_integer_hwtcl == 4)"                                           NOVAL                ::intel_pcie_ss_axi::interfaces::elaborate_lite_csr_interfaces                                                              NOVAL                               }\
    \
        { p3_ss_app_lite_csr_bvalid         	output         1                                	    	bvalid			p3_lite_csr		axi4lite                  start           "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 ||rtile_debug_toolkit_hwtcl || ftile_debug_toolkit_hwtcl || ptile_debug_toolkit_hwtcl || (top_topology_integer_hwtcl == 4)"                                           NOVAL                  ::intel_pcie_ss_axi::interfaces::elaborate_lite_csr_interfaces                                                               NOVAL                               }\
        { p3_app_ss_lite_csr_bready        		input          1											bready			p3_lite_csr		axi4lite                  end	    		"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 ||rtile_debug_toolkit_hwtcl || ftile_debug_toolkit_hwtcl || ptile_debug_toolkit_hwtcl || (top_topology_integer_hwtcl == 4)"                                           NOVAL                ::intel_pcie_ss_axi::interfaces::elaborate_lite_csr_interfaces                                                               NOVAL                               }\
        { p3_ss_app_lite_csr_bresp        		output         2							    		    bresp			p3_lite_csr 	axi4lite                  start	    	"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 ||rtile_debug_toolkit_hwtcl || ftile_debug_toolkit_hwtcl || ptile_debug_toolkit_hwtcl || (top_topology_integer_hwtcl == 4)"                                           NOVAL                    ::intel_pcie_ss_axi::interfaces::elaborate_lite_csr_interfaces                                                               NOVAL                               }\
    \
        { p3_app_ss_lite_csr_arvalid         	input          1                                	    	arvalid			p3_lite_csr		axi4lite                  end           	"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 ||rtile_debug_toolkit_hwtcl || ftile_debug_toolkit_hwtcl || ptile_debug_toolkit_hwtcl || (top_topology_integer_hwtcl == 4)"                                           NOVAL                ::intel_pcie_ss_axi::interfaces::elaborate_lite_csr_interfaces                                                               NOVAL                               }\
        { p3_ss_app_lite_csr_arready        	output         1											arready      	p3_lite_csr		axi4lite                  start	    	"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 ||rtile_debug_toolkit_hwtcl || ftile_debug_toolkit_hwtcl || ptile_debug_toolkit_hwtcl || (top_topology_integer_hwtcl == 4)"                                           NOVAL                    ::intel_pcie_ss_axi::interfaces::elaborate_lite_csr_interfaces                                                              NOVAL                               }\
        { p3_app_ss_lite_csr_araddr        		input          core4_1_LiteSlvAWD			    			araddr			p3_lite_csr		axi4lite                  end	    		"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 ||rtile_debug_toolkit_hwtcl || ftile_debug_toolkit_hwtcl || ptile_debug_toolkit_hwtcl || (top_topology_integer_hwtcl == 4)"                                           NOVAL                ::intel_pcie_ss_axi::interfaces::elaborate_lite_csr_interfaces                                                               NOVAL                               }\
        { p3_app_ss_lite_csr_arprot        		input          3                			    			arprot			p3_lite_csr		axi4lite                 end	    		"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 ||rtile_debug_toolkit_hwtcl ||ftile_debug_toolkit_hwtcl || ptile_debug_toolkit_hwtcl || (top_topology_integer_hwtcl == 4)"                                           NOVAL                  ::intel_pcie_ss_axi::interfaces::elaborate_lite_csr_interfaces                                                               NOVAL                               }\
        
    \
        { p3_ss_app_lite_csr_rvalid        		output         1							    			rvalid			p3_lite_csr		axi4lite                  start	    	"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 ||rtile_debug_toolkit_hwtcl || ftile_debug_toolkit_hwtcl || ptile_debug_toolkit_hwtcl || (top_topology_integer_hwtcl == 4)"                                           NOVAL                    ::intel_pcie_ss_axi::interfaces::elaborate_lite_csr_interfaces                                                               NOVAL                               }\
        { p3_app_ss_lite_csr_rready         	input          1                                	    	rready			p3_lite_csr		axi4lite                  end           	"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 ||rtile_debug_toolkit_hwtcl || ftile_debug_toolkit_hwtcl || ptile_debug_toolkit_hwtcl || (top_topology_integer_hwtcl == 4)"                                           NOVAL                ::intel_pcie_ss_axi::interfaces::elaborate_lite_csr_interfaces                                                               NOVAL                               }\
        { p3_ss_app_lite_csr_rdata        		output         core4_1_LiteSlvDWD			    			rdata			p3_lite_csr	    axi4lite                  start	    	"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 ||rtile_debug_toolkit_hwtcl || ftile_debug_toolkit_hwtcl || ptile_debug_toolkit_hwtcl || (top_topology_integer_hwtcl == 4)"                                           NOVAL                    ::intel_pcie_ss_axi::interfaces::elaborate_lite_csr_interfaces                                                               NOVAL                               }\
        { p3_ss_app_lite_csr_rresp        		output         2											rresp			p3_lite_csr		axi4lite                  start	    	"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 ||rtile_debug_toolkit_hwtcl || ftile_debug_toolkit_hwtcl || ptile_debug_toolkit_hwtcl || (top_topology_integer_hwtcl == 4)"                                           NOVAL                    ::intel_pcie_ss_axi::interfaces::elaborate_lite_csr_interfaces                                                              NOVAL                               }\
    \
        { p0_ss_app_lite_initatr_awvalid        output         1							    			p0_ss_app_lite_initatr_awvalid      p0_ss_app_lite_initatr_awvalid	conduit                 start	    	true                                           NOVAL                   NOVAL                                                               NOVAL                               }\
        { p0_app_ss_lite_initatr_awready        input          1                                	    	p0_app_ss_lite_initatr_awready		p0_app_ss_lite_initatr_awready	conduit                 end           	true                                            0                       NOVAL                                                               NOVAL                               }\
        { p0_ss_app_lite_initatr_awaddr        	output         core16_LiteMstrAWD			    			p0_ss_app_lite_initatr_awaddr		p0_ss_app_lite_initatr_awaddr	conduit                 start	    	true                                           NOVAL                   NOVAL                                                               NOVAL                               }\
    \
        { p0_ss_app_lite_initatr_wvalid        	output         1							    			p0_ss_app_lite_initatr_wvalid		p0_ss_app_lite_initatr_wvalid	conduit                 start	    	true                                           NOVAL                   NOVAL                                                               NOVAL                               }\
        { p0_app_ss_lite_initatr_wready         input          1                                	    	p0_app_ss_lite_initatr_wready		p0_app_ss_lite_initatr_wready	conduit                 end           	true                                            0                       NOVAL                                                               NOVAL                               }\
        { p0_ss_app_lite_initatr_wdata        	output         core16_LiteMstrDWD			    			p0_ss_app_lite_initatr_wdata		p0_ss_app_lite_initatr_wdata	conduit                 start	    	true                                           NOVAL                   NOVAL                                                               NOVAL                               }\
        { p0_ss_app_lite_initatr_wstrb        	output         core16_LiteMstrDWD/8							p0_ss_app_lite_initatr_wstrb		p0_ss_app_lite_initatr_wstrb	conduit                 start	    	true                                           NOVAL                   NOVAL                                                               NOVAL                               }\
    \
        { p0_app_ss_lite_initatr_bvalid         input          1                                	    	p0_app_ss_lite_initatr_bvalid		p0_app_ss_lite_initatr_bvalid	conduit                 end           	true                                            0                       NOVAL                                                               NOVAL                               }\
        { p0_ss_app_lite_initatr_bready        	output         1											p0_ss_app_lite_initatr_bready		p0_ss_app_lite_initatr_bready	conduit                 start	    	true                                           NOVAL                   NOVAL                                                               NOVAL                               }\
        { p0_app_ss_lite_initatr_bresp        	input          2							    			p0_app_ss_lite_initatr_bresp		p0_app_ss_lite_initatr_bresp	conduit                 end	    		true                                            0                       NOVAL                                                               NOVAL                               }\
    \
        { p0_ss_app_lite_initatr_arvalid        output         1                                	    	p0_ss_app_lite_initatr_arvalid		p0_ss_app_lite_initatr_arvalid	conduit                 start           true                                           NOVAL                   NOVAL                                                               NOVAL                               }\
        { p0_app_ss_lite_initatr_arready        input          1											p0_app_ss_lite_initatr_arready      p0_app_ss_lite_initatr_arready	conduit                 end	    		true                                            0                       NOVAL                                                               NOVAL                               }\
        { p0_ss_app_lite_initatr_araddr        	output         core16_LiteMstrAWD			    			p0_ss_app_lite_initatr_araddr		p0_ss_app_lite_initatr_araddr	conduit                 start	    	true                                           NOVAL                   NOVAL                                                               NOVAL                               }\
    \
        { p0_app_ss_lite_initatr_rvalid        	input          1							    			p0_app_ss_lite_initatr_rvalid		p0_app_ss_lite_initatr_rvalid	conduit                 end	    		true                                            0                       NOVAL                                                               NOVAL                               }\
        { p0_ss_app_lite_initatr_rready         output         1                                	    	p0_ss_app_lite_initatr_rready		p0_ss_app_lite_initatr_rready	conduit                 start           true                                           NOVAL                   NOVAL                                                               NOVAL                               }\
        { p0_app_ss_lite_initatr_rdata        	input          core16_LiteMstrDWD			    			p0_app_ss_lite_initatr_rdata		p0_app_ss_lite_initatr_rdata	conduit                 end	    		true                                            0                       NOVAL                                                               NOVAL                               }\
        { p0_app_ss_lite_initatr_rresp        	input          2											p0_app_ss_lite_initatr_rresp		p0_app_ss_lite_initatr_rresp	conduit                 end	    		true                                            0                       NOVAL                                                               NOVAL                               }\
    \
        { p1_ss_app_lite_initatr_awvalid        output         1							    			p1_ss_app_lite_initatr_awvalid      p1_ss_app_lite_initatr_awvalid	conduit                 start	    	true                                            NOVAL                    NOVAL                                                               NOVAL                               }\
        { p1_app_ss_lite_initatr_awready        input          1                                	    	p1_app_ss_lite_initatr_awready		p1_app_ss_lite_initatr_awready	conduit                 end           	true                                             0                        NOVAL                                                               NOVAL                               }\
        { p1_ss_app_lite_initatr_awaddr        	output         core8_LiteMstrAWD			    			p1_ss_app_lite_initatr_awaddr		p1_ss_app_lite_initatr_awaddr	conduit                 start	    	true                                            NOVAL                    NOVAL                                                               NOVAL                               }\
    \                                                                                                                                                                                                                                                                   
        { p1_ss_app_lite_initatr_wvalid        	output         1							    			p1_ss_app_lite_initatr_wvalid		p1_ss_app_lite_initatr_wvalid	conduit                 start	    	true                                            NOVAL                    NOVAL                                                               NOVAL                               }\
        { p1_app_ss_lite_initatr_wready         input          1                                	    	p1_app_ss_lite_initatr_wready		p1_app_ss_lite_initatr_wready	conduit                 end           	true                                             0                        NOVAL                                                               NOVAL                               }\
        { p1_ss_app_lite_initatr_wdata        	output         core8_LiteMstrDWD			    			p1_ss_app_lite_initatr_wdata		p1_ss_app_lite_initatr_wdata	conduit                 start	    	true                                            NOVAL                    NOVAL                                                               NOVAL                               }\
        { p1_ss_app_lite_initatr_wstrb        	output         core8_LiteMstrDWD/8							p1_ss_app_lite_initatr_wstrb		p1_ss_app_lite_initatr_wstrb	conduit                 start	    	true                                            NOVAL                    NOVAL                                                               NOVAL                               }\
    \                                                                                                                                                                                                                                                                   
        { p1_app_ss_lite_initatr_bvalid         input          1                                	    	p1_app_ss_lite_initatr_bvalid		p1_app_ss_lite_initatr_bvalid	conduit                 end           	true                                             0                        NOVAL                                                               NOVAL                               }\
        { p1_ss_app_lite_initatr_bready        	output         1											p1_ss_app_lite_initatr_bready		p1_ss_app_lite_initatr_bready	conduit                 start	    	true                                            NOVAL                    NOVAL                                                               NOVAL                               }\
        { p1_app_ss_lite_initatr_bresp        	input          2							    			p1_app_ss_lite_initatr_bresp		p1_app_ss_lite_initatr_bresp	conduit                 end	    		true                                             0                        NOVAL                                                               NOVAL                               }\
    \                                                                                                                                                                                                                                                                   
        { p1_ss_app_lite_initatr_arvalid        output         1                                	    	p1_ss_app_lite_initatr_arvalid		p1_ss_app_lite_initatr_arvalid	conduit                 start           true                                            NOVAL                    NOVAL                                                               NOVAL                               }\
        { p1_app_ss_lite_initatr_arready        input          1											p1_app_ss_lite_initatr_arready      p1_app_ss_lite_initatr_arready	conduit                 end	    		true                                             0                        NOVAL                                                               NOVAL                               }\
        { p1_ss_app_lite_initatr_araddr        	output         core8_LiteMstrAWD			    			p1_ss_app_lite_initatr_araddr		p1_ss_app_lite_initatr_araddr	conduit                 start	    	true                                            NOVAL                    NOVAL                                                               NOVAL                               }\
    \                                                                                                                                                                                                                                                                   
        { p1_app_ss_lite_initatr_rvalid        	input          1							    			p1_app_ss_lite_initatr_rvalid		p1_app_ss_lite_initatr_rvalid	conduit                 end	    		true                                             0                        NOVAL                                                               NOVAL                               }\
        { p1_ss_app_lite_initatr_rready         output         1                                	    	p1_ss_app_lite_initatr_rready		p1_ss_app_lite_initatr_rready	conduit                 start           true                                            NOVAL                    NOVAL                                                               NOVAL                               }\
        { p1_app_ss_lite_initatr_rdata        	input          core8_LiteMstrDWD			    			p1_app_ss_lite_initatr_rdata		p1_app_ss_lite_initatr_rdata	conduit                 end	    		true                                             0                        NOVAL                                                               NOVAL                               }\
        { p1_app_ss_lite_initatr_rresp        	input          2											p1_app_ss_lite_initatr_rresp		p1_app_ss_lite_initatr_rresp	conduit                 end	    		true                                             0                        NOVAL                                                               NOVAL                               }\
    \
        { p2_ss_app_lite_initatr_awvalid        output         1							    			p2_ss_app_lite_initatr_awvalid      p2_ss_app_lite_initatr_awvalid	conduit                 start	    	true                                            NOVAL                    NOVAL                                                               NOVAL                               }\
        { p2_app_ss_lite_initatr_awready        input          1                                	    	p2_app_ss_lite_initatr_awready		p2_app_ss_lite_initatr_awready	conduit                 end           	true                                             0                        NOVAL                                                               NOVAL                               }\
        { p2_ss_app_lite_initatr_awaddr        	output         core4_0_LiteMstrAWD			    			p2_ss_app_lite_initatr_awaddr		p2_ss_app_lite_initatr_awaddr	conduit                 start	    	true                                            NOVAL                    NOVAL                                                               NOVAL                               }\
    \                                                                                                                                                                                                                                                                   
        { p2_ss_app_lite_initatr_wvalid        	output         1							    			p2_ss_app_lite_initatr_wvalid		p2_ss_app_lite_initatr_wvalid	conduit                 start	    	true                                            NOVAL                    NOVAL                                                               NOVAL                               }\
        { p2_app_ss_lite_initatr_wready         input          1                                	    	p2_app_ss_lite_initatr_wready		p2_app_ss_lite_initatr_wready	conduit                 end           	true                                             0                        NOVAL                                                               NOVAL                               }\
        { p2_ss_app_lite_initatr_wdata        	output         core4_0_LiteMstrDWD			    			p2_ss_app_lite_initatr_wdata		p2_ss_app_lite_initatr_wdata	conduit                 start	    	true                                            NOVAL                    NOVAL                                                               NOVAL                               }\
        { p2_ss_app_lite_initatr_wstrb        	output         core4_0_LiteMstrDWD/8						p2_ss_app_lite_initatr_wstrb		p2_ss_app_lite_initatr_wstrb	conduit                 start	        true                                            NOVAL                    NOVAL                                                               NOVAL                               }\
    \                                                                                                                                                                                                                                                                   
        { p2_app_ss_lite_initatr_bvalid         input          1                                	    	p2_app_ss_lite_initatr_bvalid		p2_app_ss_lite_initatr_bvalid	conduit                 end           	true                                             0                        NOVAL                                                               NOVAL                               }\
        { p2_ss_app_lite_initatr_bready        	output         1											p2_ss_app_lite_initatr_bready		p2_ss_app_lite_initatr_bready	conduit                 start	    	true                                            NOVAL                    NOVAL                                                               NOVAL                               }\
        { p2_app_ss_lite_initatr_bresp        	input          2							    			p2_app_ss_lite_initatr_bresp		p2_app_ss_lite_initatr_bresp	conduit                 end	    		true                                             0                        NOVAL                                                               NOVAL                               }\
    \                                                                                                                                                                                                                                                                   
        { p2_ss_app_lite_initatr_arvalid        output         1                                	    	p2_ss_app_lite_initatr_arvalid		p2_ss_app_lite_initatr_arvalid	conduit                 start           true                                            NOVAL                    NOVAL                                                               NOVAL                               }\
        { p2_app_ss_lite_initatr_arready        input          1											p2_app_ss_lite_initatr_arready      p2_app_ss_lite_initatr_arready	conduit                 end	    		true                                             0                        NOVAL                                                               NOVAL                               }\
        { p2_ss_app_lite_initatr_araddr        	output         core4_0_LiteMstrAWD			    			p2_ss_app_lite_initatr_araddr		p2_ss_app_lite_initatr_araddr	conduit                 start	    	true                                            NOVAL                    NOVAL                                                               NOVAL                               }\
    \                                                                                                                                                                                                                                                                   
        { p2_app_ss_lite_initatr_rvalid        	input          1							    			p2_app_ss_lite_initatr_rvalid		p2_app_ss_lite_initatr_rvalid	conduit                 end	    		true                                             0                        NOVAL                                                               NOVAL                               }\
        { p2_ss_app_lite_initatr_rready         output         1                                	    	p2_ss_app_lite_initatr_rready		p2_ss_app_lite_initatr_rready	conduit                 start           true                                            NOVAL                    NOVAL                                                               NOVAL                               }\
        { p2_app_ss_lite_initatr_rdata        	input          core4_0_LiteMstrDWD			    			p2_app_ss_lite_initatr_rdata		p2_app_ss_lite_initatr_rdata	conduit                 end	    		true                                             0                        NOVAL                                                               NOVAL                               }\
        { p2_app_ss_lite_initatr_rresp        	input          2											p2_app_ss_lite_initatr_rresp		p2_app_ss_lite_initatr_rresp	conduit                 end	    		true                                             0                        NOVAL                                                               NOVAL                               }\
    \
        { p3_ss_app_lite_initatr_awvalid        output         1							    			p3_ss_app_lite_initatr_awvalid      p3_ss_app_lite_initatr_awvalid	conduit                 start	    	true                                           NOVAL                    NOVAL                                                               NOVAL                               }\
        { p3_app_ss_lite_initatr_awready        input          1                                	    	p3_app_ss_lite_initatr_awready		p3_app_ss_lite_initatr_awready	conduit                 end           	true                                            0                        NOVAL                                                               NOVAL                               }\
        { p3_ss_app_lite_initatr_awaddr        	output         core4_1_LiteMstrAWD			    			p3_ss_app_lite_initatr_awaddr		p3_ss_app_lite_initatr_awaddr	conduit                 start	    	true                                           NOVAL                    NOVAL                                                               NOVAL                               }\
    \                                                                                                                                                                                                                                                                  
        { p3_ss_app_lite_initatr_wvalid        	output         1							    			p3_ss_app_lite_initatr_wvalid		p3_ss_app_lite_initatr_wvalid	conduit                 start	        true                                           NOVAL                    NOVAL                                                               NOVAL                               }\
        { p3_app_ss_lite_initatr_wready         input          1                                	    	p3_app_ss_lite_initatr_wready		p3_app_ss_lite_initatr_wready	conduit                 end           	true                                            0                        NOVAL                                                               NOVAL                               }\
        { p3_ss_app_lite_initatr_wdata        	output         core4_1_LiteMstrDWD			    			p3_ss_app_lite_initatr_wdata		p3_ss_app_lite_initatr_wdata	conduit                 start	    	true                                           NOVAL                    NOVAL                                                               NOVAL                               }\
        { p3_ss_app_lite_initatr_wstrb        	output         core4_1_LiteMstrDWD/8						p3_ss_app_lite_initatr_wstrb		p3_ss_app_lite_initatr_wstrb	conduit                 start	    	true                                           NOVAL                    NOVAL                                                               NOVAL                               }\
    \                                                                                                                                                                                                                                                                  
        { p3_app_ss_lite_initatr_bvalid         input          1                                	    	p3_app_ss_lite_initatr_bvalid		p3_app_ss_lite_initatr_bvalid	conduit                 end           	true                                            0                        NOVAL                                                               NOVAL                               }\
        { p3_ss_app_lite_initatr_bready        	output         1											p3_ss_app_lite_initatr_bready		p3_ss_app_lite_initatr_bready	conduit                 start	    	true                                           NOVAL                    NOVAL                                                               NOVAL                               }\
        { p3_app_ss_lite_initatr_bresp        	input          2							    			p3_app_ss_lite_initatr_bresp		p3_app_ss_lite_initatr_bresp	conduit                 end	    		true                                            0                        NOVAL                                                               NOVAL                               }\
    \                                                                                                                                                                                                                                                                  
        { p3_ss_app_lite_initatr_arvalid        output         1                                	    	p3_ss_app_lite_initatr_arvalid		p3_ss_app_lite_initatr_arvalid	conduit                 start           true                                           NOVAL                    NOVAL                                                               NOVAL                               }\
        { p3_app_ss_lite_initatr_arready        input          1											p3_app_ss_lite_initatr_arready      p3_app_ss_lite_initatr_arready	conduit                 end	    		true                                            0                        NOVAL                                                               NOVAL                               }\
        { p3_ss_app_lite_initatr_araddr        	output         core4_1_LiteMstrAWD			    			p3_ss_app_lite_initatr_araddr		p3_ss_app_lite_initatr_araddr	conduit                 start	    	true                                           NOVAL                    NOVAL                                                               NOVAL                               }\
    \                                                                                                                                                                                                                                                                  
        { p3_app_ss_lite_initatr_rvalid        	input          1							    			p3_app_ss_lite_initatr_rvalid		p3_app_ss_lite_initatr_rvalid	conduit                 end	    		true                                            0                        NOVAL                                                               NOVAL                               }\
        { p3_ss_app_lite_initatr_rready         output         1                                	    	p3_ss_app_lite_initatr_rready		p3_ss_app_lite_initatr_rready	conduit                 start           true                                           NOVAL                    NOVAL                                                               NOVAL                               }\
        { p3_app_ss_lite_initatr_rdata        	input          core4_1_LiteMstrDWD			    			p3_app_ss_lite_initatr_rdata		p3_app_ss_lite_initatr_rdata	conduit                 end	    		true                                            0                        NOVAL                                                               NOVAL                               }\
        { p3_app_ss_lite_initatr_rresp        	input          2											p3_app_ss_lite_initatr_rresp		p3_app_ss_lite_initatr_rresp	conduit                 end	    		true                                            0                        NOVAL                                                               NOVAL                               }\
    \
        { p0_ss_app_mm_initatr_awvalid        	output         1							    			awvalid      	p0_mm_initatr	    axi4                 start	    	"pcie_ss_func_mode_integer_hwtcl < 2"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_mm_initatr_interfaces                                                       "Check User Guide for details"                                }\
        { p0_app_ss_mm_initatr_awready        	input          1                                	    	awready		    p0_mm_initatr	    axi4                 end           	"pcie_ss_func_mode_integer_hwtcl < 2"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_mm_initatr_interfaces                                                       "Check User Guide for details"                                }\
        { p0_ss_app_mm_initatr_awaddr        	output         core16_MMAWD			    					awaddr			p0_mm_initatr		axi4                 start	    	"pcie_ss_func_mode_integer_hwtcl < 2"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_mm_initatr_interfaces                                                       "Check User Guide for details"                                }\
        { p0_ss_app_mm_initatr_awlen        	output         core16_MMBLWD								awlen			p0_mm_initatr		axi4                 start	    	"pcie_ss_func_mode_integer_hwtcl < 2"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_mm_initatr_interfaces                                                       "Check User Guide for details"                                }\
        { p0_ss_app_mm_initatr_awsize         	output         3                                	    	awsize			p0_mm_initatr		axi4                 start         	"pcie_ss_func_mode_integer_hwtcl < 2"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_mm_initatr_interfaces                                                       "Check User Guide for details"                                }\
        { p0_ss_app_mm_initatr_awprot        	output         3											awprot			p0_mm_initatr		axi4                 start	    	"pcie_ss_func_mode_integer_hwtcl < 2"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_mm_initatr_interfaces                                                       "Check User Guide for details"                                }\
        { p0_ss_app_mm_initatr_wvalid        	output         1											wvalid			p0_mm_initatr		axi4                 start	    	"pcie_ss_func_mode_integer_hwtcl < 2"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_mm_initatr_interfaces                                                       "Check User Guide for details"                                }\
        { p0_ss_app_mm_initatr_wlast         	output         1                                	    	wlast			p0_mm_initatr		axi4                 start          	"pcie_ss_func_mode_integer_hwtcl < 2"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_mm_initatr_interfaces                                                       "Check User Guide for details"                                }\
        { p0_app_ss_mm_initatr_wready        	input 	       1											wready			p0_mm_initatr		axi4                 end	 	   		"pcie_ss_func_mode_integer_hwtcl < 2"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_mm_initatr_interfaces                                                       "Check User Guide for details"                                }\
        { p0_ss_app_mm_initatr_wdata        	output         core16_MMDWD									wdata			p0_mm_initatr		axi4                 start    		"pcie_ss_func_mode_integer_hwtcl < 2"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_mm_initatr_interfaces                                                       "Check User Guide for details"                                }\
        { p0_ss_app_mm_initatr_wstrb        	output         core16_MMDWD/8								wstrb			p0_mm_initatr		axi4                 start           "pcie_ss_func_mode_integer_hwtcl < 2"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_mm_initatr_interfaces                                                       "Check User Guide for details"                                }\
        { p0_app_ss_mm_initatr_bvalid        	input          1											bvalid      	p0_mm_initatr		axi4                 end	    		"pcie_ss_func_mode_integer_hwtcl < 2"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_mm_initatr_interfaces                                                       "Check User Guide for details"                                }\
        { p0_ss_app_mm_initatr_bready        	output         1			    							bready			p0_mm_initatr		axi4                 start	    	"pcie_ss_func_mode_integer_hwtcl < 2"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_mm_initatr_interfaces                                                       "Check User Guide for details"                                }\
        { p0_app_ss_mm_initatr_bresp        	input          2							    			bresp			p0_mm_initatr		axi4                 end	    		"pcie_ss_func_mode_integer_hwtcl < 2"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_mm_initatr_interfaces                                                       "Check User Guide for details"                                }\
        { p0_ss_app_mm_initatr_arvalid        	output         1							    			arvalid      	p0_mm_initatr	    axi4                 start	    	"pcie_ss_func_mode_integer_hwtcl < 2"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_mm_initatr_interfaces                                                       "Check User Guide for details"                                }\
        { p0_app_ss_mm_initatr_arready        	input          1                                	    	arready		    p0_mm_initatr	    axi4                 end           	"pcie_ss_func_mode_integer_hwtcl < 2"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_mm_initatr_interfaces                                                       "Check User Guide for details"                                }\
        { p0_ss_app_mm_initatr_araddr        	output         core16_MMAWD									araddr			p0_mm_initatr		axi4                 start	    	"pcie_ss_func_mode_integer_hwtcl < 2"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_mm_initatr_interfaces                                                       "Check User Guide for details"                                }\
        { p0_ss_app_mm_initatr_arlen        	output         core16_MMBLWD                                arlen			p0_mm_initatr		axi4                 start	    	"pcie_ss_func_mode_integer_hwtcl < 2"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_mm_initatr_interfaces                                                       "Check User Guide for details"                                }\
        { p0_ss_app_mm_initatr_arsize         	output         3											arsize			p0_mm_initatr		axi4                 start         	"pcie_ss_func_mode_integer_hwtcl < 2"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_mm_initatr_interfaces                                                       "Check User Guide for details"                                }\
        { p0_ss_app_mm_initatr_arprot        	output         3											arprot			p0_mm_initatr		axi4                 start	    	"pcie_ss_func_mode_integer_hwtcl < 2"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_mm_initatr_interfaces                                                       "Check User Guide for details"                                }\
        { p0_app_ss_mm_initatr_rvalid        	input          1							    			rvalid      	p0_mm_initatr		axi4                 end	    		"pcie_ss_func_mode_integer_hwtcl < 2"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_mm_initatr_interfaces                                                       "Check User Guide for details"                                }\
        { p0_app_ss_mm_initatr_rlast        	input          1                                	    	rlast			p0_mm_initatr		axi4                 end           	"pcie_ss_func_mode_integer_hwtcl < 2"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_mm_initatr_interfaces                                                       "Check User Guide for details"                                }\
        { p0_ss_app_mm_initatr_rready        	output         1											rready			p0_mm_initatr		axi4                 start	    	"pcie_ss_func_mode_integer_hwtcl < 2"                                          NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_mm_initatr_interfaces                                                       "Check User Guide for details"                                }\
        { p0_app_ss_mm_initatr_rdata        	input          core16_MMDWD									rdata			p0_mm_initatr		axi4                 end	    		"pcie_ss_func_mode_integer_hwtcl < 2"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_mm_initatr_interfaces                                                       "Check User Guide for details"                                }\
        { p0_app_ss_mm_initatr_rresp         	input          2											rresp			p0_mm_initatr		axi4                 end         	"pcie_ss_func_mode_integer_hwtcl < 2"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_mm_initatr_interfaces                                                       "Check User Guide for details"                                }\
    \
        { p1_ss_app_mm_initatr_awvalid        	output         1							    			awvalid      	p1_mm_initatr	    axi4                 start	    	"pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || pcie_ss_func_mode_integer_hwtcl < 2 || (top_topology_integer_hwtcl == 4)"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_mm_initatr_interfaces                                                       "Check User Guide for details"                                }\
        { p1_app_ss_mm_initatr_awready        	input          1                                	    	awready		    p1_mm_initatr	    axi4                 end           	"pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || pcie_ss_func_mode_integer_hwtcl < 2 || (top_topology_integer_hwtcl == 4)"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_mm_initatr_interfaces                                                       "Check User Guide for details"                                }\
        { p1_ss_app_mm_initatr_awaddr        	output         core8_MMAWD			    					awaddr			p1_mm_initatr		axi4                 start	    	"pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || pcie_ss_func_mode_integer_hwtcl < 2 || (top_topology_integer_hwtcl == 4)"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_mm_initatr_interfaces                                                       "Check User Guide for details"                                }\
        { p1_ss_app_mm_initatr_awlen        	output         core8_MMBLWD									awlen			p1_mm_initatr		axi4                 start	    	"pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || pcie_ss_func_mode_integer_hwtcl < 2 || (top_topology_integer_hwtcl == 4)"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_mm_initatr_interfaces                                                       "Check User Guide for details"                                }\
        { p1_ss_app_mm_initatr_awsize         	output         3                                	    	awsize			p1_mm_initatr		axi4                 start         	"pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || pcie_ss_func_mode_integer_hwtcl < 2 || (top_topology_integer_hwtcl == 4)"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_mm_initatr_interfaces                                                       "Check User Guide for details"                                }\
        { p1_ss_app_mm_initatr_awprot        	output         3											awprot			p1_mm_initatr		axi4                 start	    	"pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || pcie_ss_func_mode_integer_hwtcl < 2 || (top_topology_integer_hwtcl == 4)"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_mm_initatr_interfaces                                                       "Check User Guide for details"                                }\
        { p1_ss_app_mm_initatr_wvalid        	output         1											wvalid			p1_mm_initatr		axi4                 start	    	"pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || pcie_ss_func_mode_integer_hwtcl < 2 || (top_topology_integer_hwtcl == 4)"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_mm_initatr_interfaces                                                       "Check User Guide for details"                                }\
        { p1_ss_app_mm_initatr_wlast         	output         1                                	    	wlast			p1_mm_initatr		axi4                 start          "pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || pcie_ss_func_mode_integer_hwtcl < 2 || (top_topology_integer_hwtcl == 4)"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_mm_initatr_interfaces                                                       "Check User Guide for details"                                }\
        { p1_app_ss_mm_initatr_wready        	input 	       1											wready			p1_mm_initatr		axi4                 end	 	    "pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || pcie_ss_func_mode_integer_hwtcl < 2 || (top_topology_integer_hwtcl == 4)"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_mm_initatr_interfaces                                                       "Check User Guide for details"                                }\
        { p1_ss_app_mm_initatr_wdata        	output         core8_MMDWD									wdata			p1_mm_initatr		axi4                 start    		"pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || pcie_ss_func_mode_integer_hwtcl < 2 || (top_topology_integer_hwtcl == 4)"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_mm_initatr_interfaces                                                       "Check User Guide for details"                                }\
        { p1_ss_app_mm_initatr_wstrb        	output         core8_MMDWD/8								wstrb			p1_mm_initatr		axi4                 start          "pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || pcie_ss_func_mode_integer_hwtcl < 2 || (top_topology_integer_hwtcl == 4)"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_mm_initatr_interfaces                                                       "Check User Guide for details"                                }\
        { p1_app_ss_mm_initatr_bvalid        	input          1											bvalid      	p1_mm_initatr		axi4                 end	        "pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || pcie_ss_func_mode_integer_hwtcl < 2 || (top_topology_integer_hwtcl == 4)"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_mm_initatr_interfaces                                                       "Check User Guide for details"                                }\
        { p1_ss_app_mm_initatr_bready        	output         1			    							bready			p1_mm_initatr		axi4                 start	    	"pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || pcie_ss_func_mode_integer_hwtcl < 2 || (top_topology_integer_hwtcl == 4)"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_mm_initatr_interfaces                                                       "Check User Guide for details"                                }\
        { p1_app_ss_mm_initatr_bresp        	input          2							    			bresp			p1_mm_initatr		axi4                 end	        "pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || pcie_ss_func_mode_integer_hwtcl < 2 || (top_topology_integer_hwtcl == 4)"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_mm_initatr_interfaces                                                       "Check User Guide for details"                                }\
        { p1_ss_app_mm_initatr_arvalid        	output         1							    			arvalid      	p1_mm_initatr	    axi4                 start	    	"pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || pcie_ss_func_mode_integer_hwtcl < 2 || (top_topology_integer_hwtcl == 4)"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_mm_initatr_interfaces                                                       "Check User Guide for details"                                }\
        { p1_app_ss_mm_initatr_arready        	input          1                                	    	arready		    p1_mm_initatr	    axi4                 end           	"pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || pcie_ss_func_mode_integer_hwtcl < 2 || (top_topology_integer_hwtcl == 4)"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_mm_initatr_interfaces                                                       "Check User Guide for details"                                }\
        { p1_ss_app_mm_initatr_araddr        	output         core8_MMAWD									araddr			p1_mm_initatr		axi4                 start	    	"pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || pcie_ss_func_mode_integer_hwtcl < 2 || (top_topology_integer_hwtcl == 4)"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_mm_initatr_interfaces                                                       "Check User Guide for details"                                }\
        { p1_ss_app_mm_initatr_arlen        	output         core8_MMBLWD									arlen			p1_mm_initatr		axi4                 start	    	"pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || pcie_ss_func_mode_integer_hwtcl < 2 || (top_topology_integer_hwtcl == 4)"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_mm_initatr_interfaces                                                       "Check User Guide for details"                                }\
        { p1_ss_app_mm_initatr_arsize         	output         3											arsize			p1_mm_initatr		axi4                 start         	"pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || pcie_ss_func_mode_integer_hwtcl < 2 || (top_topology_integer_hwtcl == 4)"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_mm_initatr_interfaces                                                       "Check User Guide for details"                                }\
        { p1_ss_app_mm_initatr_arprot        	output         3											arprot			p1_mm_initatr		axi4                 start	    	"pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || pcie_ss_func_mode_integer_hwtcl < 2 || (top_topology_integer_hwtcl == 4)"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_mm_initatr_interfaces                                                       "Check User Guide for details"                                }\
        { p1_app_ss_mm_initatr_rvalid        	input          1							    			rvalid      	p1_mm_initatr		axi4                 end	        "pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || pcie_ss_func_mode_integer_hwtcl < 2 || (top_topology_integer_hwtcl == 4)"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_mm_initatr_interfaces                                                       "Check User Guide for details"                                }\
        { p1_app_ss_mm_initatr_rlast        	input          1                                	    	rlast			p1_mm_initatr		axi4                 end           	"pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || pcie_ss_func_mode_integer_hwtcl < 2 || (top_topology_integer_hwtcl == 4)"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_mm_initatr_interfaces                                                       "Check User Guide for details"                                }\
        { p1_ss_app_mm_initatr_rready        	output         1											rready			p1_mm_initatr		axi4                 start	    	"pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || pcie_ss_func_mode_integer_hwtcl < 2 || (top_topology_integer_hwtcl == 4)"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_mm_initatr_interfaces                                                       "Check User Guide for details"                                }\
        { p1_app_ss_mm_initatr_rdata        	input          core8_MMDWD									rdata			p1_mm_initatr		axi4                 end	        "pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || pcie_ss_func_mode_integer_hwtcl < 2 || (top_topology_integer_hwtcl == 4)"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_mm_initatr_interfaces                                                       "Check User Guide for details"                                }\
        { p1_app_ss_mm_initatr_rresp         	input          2											rresp			p1_mm_initatr		axi4                 end         	"pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || pcie_ss_func_mode_integer_hwtcl < 2 || (top_topology_integer_hwtcl == 4)"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_mm_initatr_interfaces                                                       "Check User Guide for details"                                }\
    \
        { p2_ss_app_mm_initatr_awvalid        	output         1							    			awvalid      	p2_mm_initatr	    axi4                 start	    	"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || pcie_ss_func_mode_integer_hwtcl < 2"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_mm_initatr_interfaces                                                       "Check User Guide for details"                                }\
        { p2_app_ss_mm_initatr_awready        	input          1                                	    	awready		    p2_mm_initatr	    axi4                 end           	"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || pcie_ss_func_mode_integer_hwtcl < 2"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_mm_initatr_interfaces                                                       "Check User Guide for details"                                }\
        { p2_ss_app_mm_initatr_awaddr        	output         core4_0_MMAWD		    					awaddr			p2_mm_initatr		axi4                 start	    	"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || pcie_ss_func_mode_integer_hwtcl < 2"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_mm_initatr_interfaces                                                       "Check User Guide for details"                                }\
        { p2_ss_app_mm_initatr_awlen        	output         core4_0_MMBLWD								awlen			p2_mm_initatr		axi4                 start	    	"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || pcie_ss_func_mode_integer_hwtcl < 2"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_mm_initatr_interfaces                                                       "Check User Guide for details"                                }\
        { p2_ss_app_mm_initatr_awsize         	output         3                                	    	awsize			p2_mm_initatr		axi4                 start         	"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || pcie_ss_func_mode_integer_hwtcl < 2"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_mm_initatr_interfaces                                                       "Check User Guide for details"                                }\
        { p2_ss_app_mm_initatr_awprot        	output         3											awprot			p2_mm_initatr		axi4                 start	    	"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || pcie_ss_func_mode_integer_hwtcl < 2"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_mm_initatr_interfaces                                                       "Check User Guide for details"                                }\
        { p2_ss_app_mm_initatr_wvalid        	output         1											wvalid			p2_mm_initatr		axi4                 start	    	"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || pcie_ss_func_mode_integer_hwtcl < 2"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_mm_initatr_interfaces                                                       "Check User Guide for details"                                }\
        { p2_ss_app_mm_initatr_wlast         	output         1                                	    	wlast			p2_mm_initatr		axi4                 start          	"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || pcie_ss_func_mode_integer_hwtcl < 2"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_mm_initatr_interfaces                                                       "Check User Guide for details"                                }\
        { p2_app_ss_mm_initatr_wready        	input 	       1											wready			p2_mm_initatr		axi4                 end	 	   		"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || pcie_ss_func_mode_integer_hwtcl < 2"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_mm_initatr_interfaces                                                       "Check User Guide for details"                                }\
        { p2_ss_app_mm_initatr_wdata        	output         core4_0_MMDWD								wdata			p2_mm_initatr		axi4                 start    		"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || pcie_ss_func_mode_integer_hwtcl < 2"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_mm_initatr_interfaces                                                       "Check User Guide for details"                                }\
        { p2_ss_app_mm_initatr_wstrb        	output         core4_0_MMDWD/8								wstrb			p2_mm_initatr		axi4                 start           "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || pcie_ss_func_mode_integer_hwtcl < 2"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_mm_initatr_interfaces                                                       "Check User Guide for details"                                }\
        { p2_app_ss_mm_initatr_bvalid        	input          1											bvalid      	p2_mm_initatr		axi4                 end	    		"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || pcie_ss_func_mode_integer_hwtcl < 2"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_mm_initatr_interfaces                                                       "Check User Guide for details"                                }\
        { p2_ss_app_mm_initatr_bready        	output         1			    							bready			p2_mm_initatr		axi4                 start	    	"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || pcie_ss_func_mode_integer_hwtcl < 2"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_mm_initatr_interfaces                                                       "Check User Guide for details"                                }\
        { p2_app_ss_mm_initatr_bresp        	input          2							    			bresp			p2_mm_initatr		axi4                 end	    		"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || pcie_ss_func_mode_integer_hwtcl < 2"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_mm_initatr_interfaces                                                       "Check User Guide for details"                                }\
        { p2_ss_app_mm_initatr_arvalid        	output         1							    			arvalid      	p2_mm_initatr	    axi4                 start	    	"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || pcie_ss_func_mode_integer_hwtcl < 2"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_mm_initatr_interfaces                                                       "Check User Guide for details"                                }\
        { p2_app_ss_mm_initatr_arready        	input          1                                	    	arready		    p2_mm_initatr	    axi4                 end           	"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || pcie_ss_func_mode_integer_hwtcl < 2"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_mm_initatr_interfaces                                                       "Check User Guide for details"                                }\
        { p2_ss_app_mm_initatr_araddr        	output         core4_0_MMAWD								araddr			p2_mm_initatr		axi4                 start	    	"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || pcie_ss_func_mode_integer_hwtcl < 2"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_mm_initatr_interfaces                                                       "Check User Guide for details"                                }\
        { p2_ss_app_mm_initatr_arlen        	output         core4_0_MMBLWD								arlen			p2_mm_initatr		axi4                 start	    	"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || pcie_ss_func_mode_integer_hwtcl < 2"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_mm_initatr_interfaces                                                       "Check User Guide for details"                                }\
        { p2_ss_app_mm_initatr_arsize         	output         3											arsize			p2_mm_initatr		axi4                 start         	"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || pcie_ss_func_mode_integer_hwtcl < 2"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_mm_initatr_interfaces                                                       "Check User Guide for details"                                }\
        { p2_ss_app_mm_initatr_arprot        	output         3											arprot			p2_mm_initatr		axi4                 start	    	"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || pcie_ss_func_mode_integer_hwtcl < 2"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_mm_initatr_interfaces                                                       "Check User Guide for details"                                }\
        { p2_app_ss_mm_initatr_rvalid        	input          1							    			rvalid      	p2_mm_initatr		axi4                 end	    		"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || pcie_ss_func_mode_integer_hwtcl < 2"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_mm_initatr_interfaces                                                       "Check User Guide for details"                                }\
        { p2_app_ss_mm_initatr_rlast        	input          1                                	    	rlast			p2_mm_initatr		axi4                 end           	"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || pcie_ss_func_mode_integer_hwtcl < 2"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_mm_initatr_interfaces                                                       "Check User Guide for details"                                }\
        { p2_ss_app_mm_initatr_rready        	output         1											rready			p2_mm_initatr		axi4                 start	    	"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || pcie_ss_func_mode_integer_hwtcl < 2"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_mm_initatr_interfaces                                                       "Check User Guide for details"                                }\
        { p2_app_ss_mm_initatr_rdata        	input          core4_0_MMDWD								rdata			p2_mm_initatr		axi4                 end	    		"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || pcie_ss_func_mode_integer_hwtcl < 2"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_mm_initatr_interfaces                                                       "Check User Guide for details"                                }\
        { p2_app_ss_mm_initatr_rresp         	input          2											rresp			p2_mm_initatr		axi4                 end         	"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || pcie_ss_func_mode_integer_hwtcl < 2"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_mm_initatr_interfaces                                                       "Check User Guide for details"                                }\
    \
        { p3_ss_app_mm_initatr_awvalid        	output         1							    			awvalid      	p3_mm_initatr	    axi4                 start	    	"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || pcie_ss_func_mode_integer_hwtcl < 2 || (top_topology_integer_hwtcl == 4)"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_mm_initatr_interfaces                                                       "Check User Guide for details"                                }\
        { p3_app_ss_mm_initatr_awready        	input          1                                	    	awready		    p3_mm_initatr	    axi4                 end           	"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || pcie_ss_func_mode_integer_hwtcl < 2 || (top_topology_integer_hwtcl == 4)"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_mm_initatr_interfaces                                                       "Check User Guide for details"                                }\
        { p3_ss_app_mm_initatr_awaddr        	output         core4_1_MMAWD		    					awaddr			p3_mm_initatr		axi4                 start	    	"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || pcie_ss_func_mode_integer_hwtcl < 2 || (top_topology_integer_hwtcl == 4)"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_mm_initatr_interfaces                                                       "Check User Guide for details"                                }\
        { p3_ss_app_mm_initatr_awlen        	output         core4_1_MMBLWD								awlen			p3_mm_initatr		axi4                 start	    	"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || pcie_ss_func_mode_integer_hwtcl < 2 || (top_topology_integer_hwtcl == 4)"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_mm_initatr_interfaces                                                       "Check User Guide for details"                                }\
        { p3_ss_app_mm_initatr_awsize         	output         3                                	    	awsize			p3_mm_initatr		axi4                 start         	"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || pcie_ss_func_mode_integer_hwtcl < 2 || (top_topology_integer_hwtcl == 4)"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_mm_initatr_interfaces                                                       "Check User Guide for details"                                }\
        { p3_ss_app_mm_initatr_awprot        	output         3											awprot			p3_mm_initatr		axi4                 start	    	"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || pcie_ss_func_mode_integer_hwtcl < 2 || (top_topology_integer_hwtcl == 4)"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_mm_initatr_interfaces                                                       "Check User Guide for details"                                }\
        { p3_ss_app_mm_initatr_wvalid        	output         1											wvalid			p3_mm_initatr		axi4                 start	    	"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || pcie_ss_func_mode_integer_hwtcl < 2 || (top_topology_integer_hwtcl == 4)"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_mm_initatr_interfaces                                                       "Check User Guide for details"                                }\
        { p3_ss_app_mm_initatr_wlast         	output         1                                	    	wlast			p3_mm_initatr		axi4                 start          "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || pcie_ss_func_mode_integer_hwtcl < 2 || (top_topology_integer_hwtcl == 4)"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_mm_initatr_interfaces                                                       "Check User Guide for details"                                }\
        { p3_app_ss_mm_initatr_wready        	input 	       1											wready			p3_mm_initatr		axi4                 end	 	    "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || pcie_ss_func_mode_integer_hwtcl < 2 || (top_topology_integer_hwtcl == 4)"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_mm_initatr_interfaces                                                       "Check User Guide for details"                                }\
        { p3_ss_app_mm_initatr_wdata        	output         core4_1_MMDWD								wdata			p3_mm_initatr		axi4                 start    		"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || pcie_ss_func_mode_integer_hwtcl < 2 || (top_topology_integer_hwtcl == 4)"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_mm_initatr_interfaces                                                       "Check User Guide for details"                                }\
        { p3_ss_app_mm_initatr_wstrb        	output         core4_1_MMDWD/8								wstrb			p3_mm_initatr		axi4                 start          "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || pcie_ss_func_mode_integer_hwtcl < 2 || (top_topology_integer_hwtcl == 4)"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_mm_initatr_interfaces                                                       "Check User Guide for details"                                }\
        { p3_app_ss_mm_initatr_bvalid        	input          1											bvalid      	p3_mm_initatr		axi4                 end	    	"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || pcie_ss_func_mode_integer_hwtcl < 2 || (top_topology_integer_hwtcl == 4)"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_mm_initatr_interfaces                                                       "Check User Guide for details"                                }\
        { p3_ss_app_mm_initatr_bready        	output         1			    							bready			p3_mm_initatr		axi4                 start	    	"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || pcie_ss_func_mode_integer_hwtcl < 2 || (top_topology_integer_hwtcl == 4)"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_mm_initatr_interfaces                                                       "Check User Guide for details"                                }\
        { p3_app_ss_mm_initatr_bresp        	input          2							    			bresp			p3_mm_initatr		axi4                 end	    	"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || pcie_ss_func_mode_integer_hwtcl < 2 || (top_topology_integer_hwtcl == 4)"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_mm_initatr_interfaces                                                       "Check User Guide for details"                                }\
        { p3_ss_app_mm_initatr_arvalid        	output         1							    			arvalid      	p3_mm_initatr	    axi4                 start	    	"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || pcie_ss_func_mode_integer_hwtcl < 2 || (top_topology_integer_hwtcl == 4)"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_mm_initatr_interfaces                                                       "Check User Guide for details"                                }\
        { p3_app_ss_mm_initatr_arready        	input          1                                	    	arready		    p3_mm_initatr	    axi4                 end           	"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || pcie_ss_func_mode_integer_hwtcl < 2 || (top_topology_integer_hwtcl == 4)"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_mm_initatr_interfaces                                                       "Check User Guide for details"                                }\
        { p3_ss_app_mm_initatr_araddr        	output         core4_1_MMAWD								araddr			p3_mm_initatr		axi4                 start	    	"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || pcie_ss_func_mode_integer_hwtcl < 2 || (top_topology_integer_hwtcl == 4)"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_mm_initatr_interfaces                                                       "Check User Guide for details"                                }\
        { p3_ss_app_mm_initatr_arlen        	output         core4_1_MMBLWD								arlen			p3_mm_initatr		axi4                 start	    	"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || pcie_ss_func_mode_integer_hwtcl < 2 || (top_topology_integer_hwtcl == 4)"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_mm_initatr_interfaces                                                       "Check User Guide for details"                                }\
        { p3_ss_app_mm_initatr_arsize         	output         3											arsize			p3_mm_initatr		axi4                 start         	"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || pcie_ss_func_mode_integer_hwtcl < 2 || (top_topology_integer_hwtcl == 4)"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_mm_initatr_interfaces                                                       "Check User Guide for details"                                }\
        { p3_ss_app_mm_initatr_arprot        	output         3											arprot			p3_mm_initatr		axi4                 start	    	"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || pcie_ss_func_mode_integer_hwtcl < 2 || (top_topology_integer_hwtcl == 4)"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_mm_initatr_interfaces                                                       "Check User Guide for details"                                }\
        { p3_app_ss_mm_initatr_rvalid        	input          1							    			rvalid      	p3_mm_initatr		axi4                 end	    	"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || pcie_ss_func_mode_integer_hwtcl < 2 || (top_topology_integer_hwtcl == 4)"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_mm_initatr_interfaces                                                       "Check User Guide for details"                                }\
        { p3_app_ss_mm_initatr_rlast        	input          1                                	    	rlast			p3_mm_initatr		axi4                 end           	"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || pcie_ss_func_mode_integer_hwtcl < 2 || (top_topology_integer_hwtcl == 4)"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_mm_initatr_interfaces                                                       "Check User Guide for details"                                }\
        { p3_ss_app_mm_initatr_rready        	output         1											rready			p3_mm_initatr		axi4                 start	    	"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || pcie_ss_func_mode_integer_hwtcl < 2 || (top_topology_integer_hwtcl == 4)"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_mm_initatr_interfaces                                                       "Check User Guide for details"                                }\
        { p3_app_ss_mm_initatr_rdata        	input          core4_1_MMDWD								rdata			p3_mm_initatr		axi4                 end	    	"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || pcie_ss_func_mode_integer_hwtcl < 2 || (top_topology_integer_hwtcl == 4)"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_mm_initatr_interfaces                                                       "Check User Guide for details"                                }\
        { p3_app_ss_mm_initatr_rresp         	input          2											rresp			p3_mm_initatr		axi4                 end         	"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || pcie_ss_func_mode_integer_hwtcl < 2 || (top_topology_integer_hwtcl == 4)"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_mm_initatr_interfaces                                                       "Check User Guide for details"                                }\
     \
        { p0_app_ss_st_err_tvalid               input         1											    tvalid						p0_st_err	                        axi4stream              end	       false                NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_err_interfaces                                                      "Check User Guide for details"                                }\
        { p0_app_ss_st_err_tdata                input         32											tdata						p0_st_err	                        axi4stream              end	       false	            NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_err_interfaces                                                      "Check User Guide for details"                                }\
        { p0_app_ss_st_err_tuser_error_type     input         14                                    app_ss_st_err_tuser_error_type   p0_app_ss_st_err_tuser_error_type      conduit                 end        false                NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_app_ss_st_err_tuser_error_type_interfaces                                                      "Check User Guide for details"                                }\
        { p0_app_ss_st_err_tlast                input         1                                             tlast                       p0_st_err	                        axi4stream              end        false                NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_err_interfaces                                                      "Check User Guide for details"                                }\
        { p0_ss_app_st_err_tready               output        1                                             tready                      p0_st_err	                        axi4stream              start      false                NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_err_interfaces                                                      "Check User Guide for details"                                }\

        { p1_app_ss_st_err_tvalid               input         1											    tvalid						p1_st_err	                        axi4stream              end	       "pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || (top_topology_integer_hwtcl == 4)"               NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_err_interfaces                                                      "Check User Guide for details"                                }\
        { p1_app_ss_st_err_tdata                input         32											tdata						p1_st_err	                        axi4stream              end	       "pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || (top_topology_integer_hwtcl == 4)"	            NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_err_interfaces                                                      "Check User Guide for details"                                }\
        { p1_app_ss_st_err_tuser_error_type     input         14                                    app_ss_st_err_tuser_error_type   p1_app_ss_st_err_tuser_error_type      conduit                 end        "pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || (top_topology_integer_hwtcl == 4)"                NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_app_ss_st_err_tuser_error_type_interfaces                                                      "Check User Guide for details"                                }\
        { p1_app_ss_st_err_tlast                input         1                                             tlast                       p1_st_err	                        axi4stream              end        "pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || (top_topology_integer_hwtcl == 4)"                NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_err_interfaces                                                      "Check User Guide for details"                                }\
        { p1_ss_app_st_err_tready               output        1                                             tready                      p1_st_err	                        axi4stream              start      "pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || (top_topology_integer_hwtcl == 4)"                NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_err_interfaces                                                      "Check User Guide for details"                                }\

        { p2_app_ss_st_err_tvalid               input         1											    tvalid						p2_st_err	                        axi4stream              end	       "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2"               NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_err_interfaces                                                      "Check User Guide for details"                                }\
        { p2_app_ss_st_err_tdata                input         32											tdata						p2_st_err	                        axi4stream              end	       "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2" 	            NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_err_interfaces                                                      "Check User Guide for details"                                }\
        { p2_app_ss_st_err_tuser_error_type     input         14                                    app_ss_st_err_tuser_error_type   p2_app_ss_st_err_tuser_error_type      conduit                 end        "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2"                 NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_app_ss_st_err_tuser_error_type_interfaces                                                      "Check User Guide for details"                                }\
        { p2_app_ss_st_err_tlast                input         1                                             tlast                       p2_st_err	                        axi4stream              end        "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2"                 NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_err_interfaces                                                      "Check User Guide for details"                                }\
        { p2_ss_app_st_err_tready               output        1                                             tready                      p2_st_err	                        axi4stream              start      "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2"                 NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_err_interfaces                                                      "Check User Guide for details"                                }\

        { p3_app_ss_st_err_tvalid               input         1											    tvalid						p3_st_err	                        axi4stream              end	       "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || (top_topology_integer_hwtcl == 4)"                NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_err_interfaces                                                      "Check User Guide for details"                                }\
        { p3_app_ss_st_err_tdata                input         32											tdata						p3_st_err	                        axi4stream              end	       "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || (top_topology_integer_hwtcl == 4)" 	            NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_err_interfaces                                                      "Check User Guide for details"                                }\
        { p3_app_ss_st_err_tuser_error_type     input         14                                    app_ss_st_err_tuser_error_type   p3_app_ss_st_err_tuser_error_type      conduit                 end        "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || (top_topology_integer_hwtcl == 4)"                 NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_app_ss_st_err_tuser_error_type_interfaces                                                      "Check User Guide for details"                                }\
        { p3_app_ss_st_err_tlast                input         1                                             tlast                       p3_st_err	                        axi4stream              end        "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || (top_topology_integer_hwtcl == 4)"                NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_err_interfaces                                                      "Check User Guide for details"                                }\
        { p3_ss_app_st_err_tready               output        1                                             tready                      p3_st_err	                        axi4stream              start      "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || (top_topology_integer_hwtcl == 4)"                NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_st_err_interfaces                                                      "Check User Guide for details"                                }\

        { p0_ss_app_virtio_pcicfgreq_tvalid     output         1											tvalid						p0_ss_app_virtio_pcicfgreq	        axi4stream              start	    	"!core16_enable_virtio_hwtcl || !core16_virtio_pci_cfg_acc_intf_en_hwtcl"             NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_virtio_interfaces                                                       "Check User Guide for details"                                }\
        { p0_ss_app_virtio_pcicfgreq_tdata      output         96											tdata						p0_ss_app_virtio_pcicfgreq	        axi4stream              start	    	"!core16_enable_virtio_hwtcl || !core16_virtio_pci_cfg_acc_intf_en_hwtcl"             NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_virtio_interfaces                                                       "Check User Guide for details"                                }\
        { p0_app_ss_virtio_pcicfgcmpl_tvalid    input          1											tvalid						p0_app_ss_virtio_pcicfgcmpl	        axi4stream              end	    	    "!core16_enable_virtio_hwtcl || !core16_virtio_pci_cfg_acc_intf_en_hwtcl"             NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_app_ss_virtio_interfaces                                                       "Check User Guide for details"                                }\
        { p0_app_ss_virtio_pcicfgcmpl_tdata     input          32											tdata						p0_app_ss_virtio_pcicfgcmpl	        axi4stream              end	    	    "!core16_enable_virtio_hwtcl || !core16_virtio_pci_cfg_acc_intf_en_hwtcl"             NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_app_ss_virtio_interfaces                                                       "Check User Guide for details"                                }\

        { p1_ss_app_virtio_pcicfgreq_tvalid     output         1											tvalid						p1_ss_app_virtio_pcicfgreq	        axi4stream              start	    	"pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || !core8_enable_virtio_hwtcl || !core8_virtio_pci_cfg_acc_intf_en_hwtcl || (top_topology_integer_hwtcl == 4)"                 NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_virtio_interfaces                                                       "Check User Guide for details"                                }\
        { p1_ss_app_virtio_pcicfgreq_tdata      output         96											tdata						p1_ss_app_virtio_pcicfgreq	        axi4stream              start	    	"pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || !core8_enable_virtio_hwtcl || !core8_virtio_pci_cfg_acc_intf_en_hwtcl || (top_topology_integer_hwtcl == 4)"                 NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_virtio_interfaces                                                       "Check User Guide for details"                                }\
        { p1_app_ss_virtio_pcicfgcmpl_tvalid    input          1											tvalid						p1_app_ss_virtio_pcicfgcmpl	        axi4stream              end	    	    "pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || !core8_enable_virtio_hwtcl || !core8_virtio_pci_cfg_acc_intf_en_hwtcl || (top_topology_integer_hwtcl == 4)"                 NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_app_ss_virtio_interfaces                                                       "Check User Guide for details"                                }\
        { p1_app_ss_virtio_pcicfgcmpl_tdata     input          32											tdata						p1_app_ss_virtio_pcicfgcmpl	        axi4stream              end	    	    "pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || !core8_enable_virtio_hwtcl || !core8_virtio_pci_cfg_acc_intf_en_hwtcl || (top_topology_integer_hwtcl == 4)"                 NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_app_ss_virtio_interfaces                                                       "Check User Guide for details"                                }\

        { p2_ss_app_virtio_pcicfgreq_tvalid     output         1											tvalid						p2_ss_app_virtio_pcicfgreq	        axi4stream              start	    	"tile_integer <2 || pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || !core4_0_enable_virtio_hwtcl || !core4_0_virtio_pci_cfg_acc_intf_en_hwtcl"                 NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_virtio_interfaces                                                       "Check User Guide for details"                                }\
        { p2_ss_app_virtio_pcicfgreq_tdata      output         96											tdata						p2_ss_app_virtio_pcicfgreq	        axi4stream              start	    	"tile_integer <2 || pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || !core4_0_enable_virtio_hwtcl || !core4_0_virtio_pci_cfg_acc_intf_en_hwtcl"                 NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_virtio_interfaces                                                       "Check User Guide for details"                                }\
        { p2_app_ss_virtio_pcicfgcmpl_tvalid    input          1											tvalid						p2_app_ss_virtio_pcicfgcmpl	        axi4stream              end	    	    "tile_integer <2 || pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || !core4_0_enable_virtio_hwtcl || !core4_0_virtio_pci_cfg_acc_intf_en_hwtcl"                 NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_app_ss_virtio_interfaces                                                       "Check User Guide for details"                                }\
        { p2_app_ss_virtio_pcicfgcmpl_tdata     input          32											tdata						p2_app_ss_virtio_pcicfgcmpl	        axi4stream              end	    	    "tile_integer <2 || pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || !core4_0_enable_virtio_hwtcl || !core4_0_virtio_pci_cfg_acc_intf_en_hwtcl"                 NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_app_ss_virtio_interfaces                                                       "Check User Guide for details"                                }\

        { p3_ss_app_virtio_pcicfgreq_tvalid     output         1											tvalid						p3_ss_app_virtio_pcicfgreq	        axi4stream              start	    	"tile_integer <2 || pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || !core4_1_enable_virtio_hwtcl || !core4_1_virtio_pci_cfg_acc_intf_en_hwtcl || top_topology_integer_hwtcl == 4"                 NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_virtio_interfaces                                                       "Check User Guide for details"                                }\
        { p3_ss_app_virtio_pcicfgreq_tdata      output         96											tdata						p3_ss_app_virtio_pcicfgreq	        axi4stream              start	    	"tile_integer <2 || pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || !core4_1_enable_virtio_hwtcl || !core4_1_virtio_pci_cfg_acc_intf_en_hwtcl || top_topology_integer_hwtcl == 4"                 NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_virtio_interfaces                                                       "Check User Guide for details"                                }\
        { p3_app_ss_virtio_pcicfgcmpl_tvalid    input          1											tvalid						p3_app_ss_virtio_pcicfgcmpl	        axi4stream              end	    	    "tile_integer <2 || pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || !core4_1_enable_virtio_hwtcl || !core4_1_virtio_pci_cfg_acc_intf_en_hwtcl || top_topology_integer_hwtcl == 4"                 NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_app_ss_virtio_interfaces                                                       "Check User Guide for details"                                }\
        { p3_app_ss_virtio_pcicfgcmpl_tdata     input          32											tdata						p3_app_ss_virtio_pcicfgcmpl	        axi4stream              end	    	    "tile_integer <2 || pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || !core4_1_enable_virtio_hwtcl || !core4_1_virtio_pci_cfg_acc_intf_en_hwtcl || top_topology_integer_hwtcl == 4"                 NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_app_ss_virtio_interfaces                                                       "Check User Guide for details"                                }\
    
        { p0_ss_app_serr        				output         1											ss_app_serr						p0_ss_app_serr					conduit                 start	    	false                                                                                                          NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_serr                                                       "Check User Guide for details"                                }\
        { p1_ss_app_serr        				output         1											ss_app_serr						p1_ss_app_serr					conduit                 start	    	"pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || (top_topology_integer_hwtcl == 4)"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_serr                                                       "Check User Guide for details"                                }\
        { p2_ss_app_serr        				output         1											ss_app_serr						p2_ss_app_serr					conduit                 start	    	"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_serr                                                       "Check User Guide for details"                                }\
        { p3_ss_app_serr        				output         1											ss_app_serr						p3_ss_app_serr					conduit                 start	    	"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || (top_topology_integer_hwtcl == 4)"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_serr                                                       "Check User Guide for details"                                }\
      \
        { p0_ss_app_linkup        				output         1											ss_app_linkup						p0_ss_app_linkup					conduit                 start	    	 true                                                                                                         NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_linkup                                                      "Check User Guide for details"                                }\
        { p1_ss_app_linkup        				output         1											ss_app_linkup						p1_ss_app_linkup					conduit                 start	    	 true                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_linkup                                                       "Check User Guide for details"                                }\
        { p2_ss_app_linkup       				output         1											ss_app_linkup						p2_ss_app_linkup					conduit                 start	    	 true                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_linkup                                                       "Check User Guide for details"                                }\
        { p3_ss_app_linkup        				output         1											ss_app_linkup						p3_ss_app_linkup					conduit                 start	    	 true                                          NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_linkup                                                       "Check User Guide for details"                                }\

     \
        { p0_ss_app_dlup        				output         1											ss_app_dlup						p0_ss_app_dlup					conduit                 start	    	false                                                                                                          NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_dlup                                                       "Check User Guide for details"                                }\
        { p1_ss_app_dlup        				output         1											ss_app_dlup						p1_ss_app_dlup					conduit                 start	    	"pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || (top_topology_integer_hwtcl == 4)"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_dlup                                                       "Check User Guide for details"                                }\
        { p2_ss_app_dlup        				output         1											ss_app_dlup						p2_ss_app_dlup					conduit                 start	    	"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_dlup                                                       "Check User Guide for details"                                }\
        { p3_ss_app_dlup        				output         1											ss_app_dlup						p3_ss_app_dlup					conduit                 start	    	"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || (top_topology_integer_hwtcl == 4)"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_dlup                                                       "Check User Guide for details"                                }\
     \
        { p0_ss_app_int_status    				output         1											ss_app_int_status				p0_ss_app_int_status     		conduit                 start	    	"!device_type_integer==1"                                                                                                                 NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_int_status                                                       "Check User Guide for details"                                }\
        { p1_ss_app_int_status         			output         1											ss_app_int_status				p1_ss_app_int_status			conduit                 start	        "pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || !device_type_integer==1 || (top_topology_integer_hwtcl == 4)"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_int_status                                                       "Check User Guide for details"                                }\
        { p2_ss_app_int_status     				output         1											ss_app_int_status				p2_ss_app_int_status			conduit                 start	    	"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || !device_type_integer==1"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_int_status                                                       "Check User Guide for details"                                }\
        { p3_ss_app_int_status     				output         1											ss_app_int_status				p3_ss_app_int_status			conduit                 start	    	"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || !device_type_integer==1 || (top_topology_integer_hwtcl == 4)"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_int_status                                                       "Check User Guide for details"                                }\
     \
        { p0_ss_app_surprise_down_err  			output         1											ss_app_surprise_down_err		p0_ss_app_surprise_down_err 	conduit                 start	    	false                                                                                                          NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_surprise_down_err                                                       "Check User Guide for details"                                }\
        { p1_ss_app_surprise_down_err  			output         1											ss_app_surprise_down_err		p1_ss_app_surprise_down_err		conduit                 start	        "pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || (top_topology_integer_hwtcl == 4)"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_surprise_down_err                                                       "Check User Guide for details"                                }\
        { p2_ss_app_surprise_down_err   		output         1											ss_app_surprise_down_err		p2_ss_app_surprise_down_err		conduit                 start	    	"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_surprise_down_err                                                       "Check User Guide for details"                                }\
        { p3_ss_app_surprise_down_err 			output         1											ss_app_surprise_down_err		p3_ss_app_surprise_down_err		conduit                 start	    	"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || (top_topology_integer_hwtcl == 4)"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_surprise_down_err                                                       "Check User Guide for details"                                }\
     \
        { p0_ss_app_ltssmstate        				output         6											ss_app_ltssmstate						p0_ss_app_ltssmstate					conduit                 start	    	true                                                                                                         NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_ltssmstate                                                      "Check User Guide for details"                                }\
        { p1_ss_app_ltssmstate        				output         6											ss_app_ltssmstate						p1_ss_app_ltssmstate					conduit                 start	        true                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_ltssmstate                                                       "Check User Guide for details"                                }\
        { p2_ss_app_ltssmstate       				output         6											ss_app_ltssmstate						p2_ss_app_ltssmstate					conduit                 start	    	true                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_ltssmstate                                                       "Check User Guide for details"                                }\
        { p3_ss_app_ltssmstate        				output         6											ss_app_ltssmstate						p3_ss_app_ltssmstate					conduit                 start	    	true                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_ltssmstate                                                       "Check User Guide for details"                                }\

     \
        { p0_ss_app_rx_par_err  			    output         1											ss_app_rx_par_err	        	p0_ss_app_rx_par_err            conduit                 start	    	false                                                                                                          NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_rx_par_err                                                       "Check User Guide for details"                                }\
        { p1_ss_app_rx_par_err   		    	output         1											ss_app_rx_par_err	        	p1_ss_app_rx_par_err            conduit                 start	        "pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || (top_topology_integer_hwtcl == 4)"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_rx_par_err                                                       "Check User Guide for details"                                }\
        { p2_ss_app_rx_par_err         	    	output         1											ss_app_rx_par_err   	    	p2_ss_app_rx_par_err    		conduit                 start	    	"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_rx_par_err                                                       "Check User Guide for details"                                }\
        { p3_ss_app_rx_par_err  		    	output         1											ss_app_rx_par_err	        	p3_ss_app_rx_par_err    		conduit                 start	    	"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || (top_topology_integer_hwtcl == 4)"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_rx_par_err                                                       "Check User Guide for details"                                }\
     \
        { p0_ss_app_tx_par_err  			    output         1											ss_app_tx_par_err	        	p0_ss_app_tx_par_err            conduit                 start	    	false                                                                                                          NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_tx_par_err                                                       "Check User Guide for details"                                }\
        { p1_ss_app_tx_par_err   		    	output         1											ss_app_tx_par_err	        	p1_ss_app_tx_par_err            conduit                 start	        "pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || (top_topology_integer_hwtcl == 4)"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_tx_par_err                                                       "Check User Guide for details"                                }\
        { p2_ss_app_tx_par_err         	    	output         1											ss_app_tx_par_err   	    	p2_ss_app_tx_par_err    		conduit                 start	    	"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_tx_par_err                                                       "Check User Guide for details"                                }\
        { p3_ss_app_tx_par_err  		    	output         1											ss_app_tx_par_err	        	p3_ss_app_tx_par_err    		conduit                 start	    	"pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || (top_topology_integer_hwtcl == 4)"                                           NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_tx_par_err                                                       "Check User Guide for details"                                }\
     \
        { xcvr_reconfig_clk                     input           1                                           clk                 xcvr_reconfig_clk       clock           end                 "xcvr_reconfig_hwtcl != 1"  NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_xcvr_reconfig              "Check User Guide for details"      }\
        { xcvr_reconfig_address                 input           26                                          address             xcvr_reconfig           avalon          slave               "xcvr_reconfig_hwtcl != 1"  NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_xcvr_reconfig              "Check User Guide for details"      }\
        { xcvr_reconfig_read                    input           1                                           read                xcvr_reconfig           avalon          slave               "xcvr_reconfig_hwtcl != 1"  NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_xcvr_reconfig              "Check User Guide for details"      }\
        { xcvr_reconfig_readdata                output          8                                           readdata            xcvr_reconfig           avalon          slave               "xcvr_reconfig_hwtcl != 1"  NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_xcvr_reconfig              "Check User Guide for details"      }\
        { xcvr_reconfig_readdatavalid           output          1                                           readdatavalid       xcvr_reconfig           avalon          slave               "xcvr_reconfig_hwtcl != 1"  NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_xcvr_reconfig              "Check User Guide for details"      }\
        { xcvr_reconfig_write                   input           1                                           write               xcvr_reconfig           avalon          slave               "xcvr_reconfig_hwtcl != 1"  NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_xcvr_reconfig              "Check User Guide for details"      }\
        { xcvr_reconfig_writedata               input           8                                           writedata           xcvr_reconfig           avalon          slave               "xcvr_reconfig_hwtcl != 1"  NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_xcvr_reconfig              "Check User Guide for details"      }\
        { xcvr_reconfig_waitrequest             output          1                                           waitrequest         xcvr_reconfig           avalon          slave               "xcvr_reconfig_hwtcl != 1"  NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_xcvr_reconfig              "Check User Guide for details"      }\
     \
        { tx_n_out0                             output          1                                           tx_n_out0                           hip_serial                   conduit                 start               false                                           NOVAL                   NOVAL                                                       "Check User Guide for details"                                }\
        { tx_n_out1                             output          1                                           tx_n_out1                           hip_serial                   conduit                 start               false                                           NOVAL                   NOVAL                                                       "Check User Guide for details"                                }\
        { tx_n_out2                             output          1                                           tx_n_out2                           hip_serial                   conduit                 start               false                                           NOVAL                   NOVAL                                                       "Check User Guide for details"                                }\
        { tx_n_out3                             output          1                                           tx_n_out3                           hip_serial                   conduit                 start               false                                           NOVAL                   NOVAL                                                       "Check User Guide for details"                                }\
        { tx_n_out4                             output          1                                           tx_n_out4                           hip_serial                   conduit                 start               "(top_topology_integer_hwtcl == 3) && hip_serial_standard_interface_selection_hwtcl"                                           NOVAL                   NOVAL                                                       "Check User Guide for details"                                }\
        { tx_n_out5                             output          1                                           tx_n_out5                           hip_serial                   conduit                 start               "(top_topology_integer_hwtcl == 3) && hip_serial_standard_interface_selection_hwtcl"                                           NOVAL                   NOVAL                                                       "Check User Guide for details"                                }\
        { tx_n_out6                             output          1                                           tx_n_out6                           hip_serial                   conduit                 start               "(top_topology_integer_hwtcl == 3) && hip_serial_standard_interface_selection_hwtcl"                                           NOVAL                   NOVAL                                                       "Check User Guide for details"                                }\
        { tx_n_out7                             output          1                                           tx_n_out7                           hip_serial                   conduit                 start               "(top_topology_integer_hwtcl == 3) && hip_serial_standard_interface_selection_hwtcl"                                           NOVAL                   NOVAL                                                       "Check User Guide for details"                                }\
        { tx_n_out8                             output          1                                           tx_n_out8                           hip_serial                   conduit                 start               "((top_topology_integer_hwtcl == 5) || (top_topology_integer_hwtcl == 4) || (top_topology_integer_hwtcl == 3)) && hip_serial_standard_interface_selection_hwtcl"                                           NOVAL                   NOVAL                                                       "Check User Guide for details"                                }\
        { tx_n_out9                             output          1                                           tx_n_out9                           hip_serial                   conduit                 start               "((top_topology_integer_hwtcl == 5) || (top_topology_integer_hwtcl == 4) || (top_topology_integer_hwtcl == 3)) && hip_serial_standard_interface_selection_hwtcl"                                           NOVAL                   NOVAL                                                       "Check User Guide for details"                                }\
        { tx_n_out10                            output          1                                           tx_n_out10                          hip_serial                   conduit                 start               "((top_topology_integer_hwtcl == 5) || (top_topology_integer_hwtcl == 4) || (top_topology_integer_hwtcl == 3)) && hip_serial_standard_interface_selection_hwtcl"                                           NOVAL                   NOVAL                                                       "Check User Guide for details"                                }\
        { tx_n_out11                            output          1                                           tx_n_out11                          hip_serial                   conduit                 start               "((top_topology_integer_hwtcl == 5) || (top_topology_integer_hwtcl == 4) || (top_topology_integer_hwtcl == 3)) && hip_serial_standard_interface_selection_hwtcl"                                           NOVAL                   NOVAL                                                       "Check User Guide for details"                                }\
        { tx_n_out12                            output          1                                           tx_n_out12                          hip_serial                   conduit                 start               "((top_topology_integer_hwtcl == 5) || (top_topology_integer_hwtcl == 4) || (top_topology_integer_hwtcl == 3)) && hip_serial_standard_interface_selection_hwtcl"                                           NOVAL                   NOVAL                                                       "Check User Guide for details"                                }\
        { tx_n_out13                            output          1                                           tx_n_out13                          hip_serial                   conduit                 start               "((top_topology_integer_hwtcl == 5) || (top_topology_integer_hwtcl == 4) || (top_topology_integer_hwtcl == 3)) && hip_serial_standard_interface_selection_hwtcl"                                           NOVAL                   NOVAL                                                       "Check User Guide for details"                                }\
        { tx_n_out14                            output          1                                           tx_n_out14                          hip_serial                   conduit                 start               "((top_topology_integer_hwtcl == 5) || (top_topology_integer_hwtcl == 4) || (top_topology_integer_hwtcl == 3)) && hip_serial_standard_interface_selection_hwtcl"                                           NOVAL                   NOVAL                                                       "Check User Guide for details"                                }\
        { tx_n_out15                            output          1                                           tx_n_out15                          hip_serial                   conduit                 start               "((top_topology_integer_hwtcl == 5) || (top_topology_integer_hwtcl == 4) || (top_topology_integer_hwtcl == 3)) && hip_serial_standard_interface_selection_hwtcl"                                           NOVAL                   NOVAL                                                       "Check User Guide for details"                                }\
    \
        { tx_p_out0                             output          1                                           tx_p_out0                           hip_serial                   conduit                 start               false                                           NOVAL                   NOVAL                                                       "Check User Guide for details"                                }\
        { tx_p_out1                             output          1                                           tx_p_out1                           hip_serial                   conduit                 start               false                                           NOVAL                   NOVAL                                                       "Check User Guide for details"                                }\
        { tx_p_out2                             output          1                                           tx_p_out2                           hip_serial                   conduit                 start               false                                           NOVAL                   NOVAL                                                       "Check User Guide for details"                                }\
        { tx_p_out3                             output          1                                           tx_p_out3                           hip_serial                   conduit                 start               false                                           NOVAL                   NOVAL                                                       "Check User Guide for details"                                }\
        { tx_p_out4                             output          1                                           tx_p_out4                           hip_serial                   conduit                 start               "(top_topology_integer_hwtcl == 3) && hip_serial_standard_interface_selection_hwtcl"                                           NOVAL                   NOVAL                                                       "Check User Guide for details"                                }\
        { tx_p_out5                             output          1                                           tx_p_out5                           hip_serial                   conduit                 start               "(top_topology_integer_hwtcl == 3) && hip_serial_standard_interface_selection_hwtcl"                                           NOVAL                   NOVAL                                                       "Check User Guide for details"                                }\
        { tx_p_out6                             output          1                                           tx_p_out6                           hip_serial                   conduit                 start               "(top_topology_integer_hwtcl == 3) && hip_serial_standard_interface_selection_hwtcl"                                           NOVAL                   NOVAL                                                       "Check User Guide for details"                                }\
        { tx_p_out7                             output          1                                           tx_p_out7                           hip_serial                   conduit                 start               "(top_topology_integer_hwtcl == 3) && hip_serial_standard_interface_selection_hwtcl"                                           NOVAL                   NOVAL                                                       "Check User Guide for details"                                }\
        { tx_p_out8                             output          1                                           tx_p_out8                           hip_serial                   conduit                 start               "((top_topology_integer_hwtcl == 5) || (top_topology_integer_hwtcl == 4) || (top_topology_integer_hwtcl == 3)) && hip_serial_standard_interface_selection_hwtcl"                                           NOVAL                   NOVAL                                                       "Check User Guide for details"                                }\
        { tx_p_out9                             output          1                                           tx_p_out9                           hip_serial                   conduit                 start               "((top_topology_integer_hwtcl == 5) || (top_topology_integer_hwtcl == 4) || (top_topology_integer_hwtcl == 3)) && hip_serial_standard_interface_selection_hwtcl"                                           NOVAL                   NOVAL                                                       "Check User Guide for details"                                }\
        { tx_p_out10                            output          1                                           tx_p_out10                          hip_serial                   conduit                 start               "((top_topology_integer_hwtcl == 5) || (top_topology_integer_hwtcl == 4) || (top_topology_integer_hwtcl == 3)) && hip_serial_standard_interface_selection_hwtcl"                                           NOVAL                   NOVAL                                                       "Check User Guide for details"                                }\
        { tx_p_out11                            output          1                                           tx_p_out11                          hip_serial                   conduit                 start               "((top_topology_integer_hwtcl == 5) || (top_topology_integer_hwtcl == 4) || (top_topology_integer_hwtcl == 3)) && hip_serial_standard_interface_selection_hwtcl"                                           NOVAL                   NOVAL                                                       "Check User Guide for details"                                }\
        { tx_p_out12                            output          1                                           tx_p_out12                          hip_serial                   conduit                 start               "((top_topology_integer_hwtcl == 5) || (top_topology_integer_hwtcl == 4) || (top_topology_integer_hwtcl == 3)) && hip_serial_standard_interface_selection_hwtcl"                                           NOVAL                   NOVAL                                                       "Check User Guide for details"                                }\
        { tx_p_out13                            output          1                                           tx_p_out13                          hip_serial                   conduit                 start               "((top_topology_integer_hwtcl == 5) || (top_topology_integer_hwtcl == 4) || (top_topology_integer_hwtcl == 3)) && hip_serial_standard_interface_selection_hwtcl"                                           NOVAL                   NOVAL                                                       "Check User Guide for details"                                }\
        { tx_p_out14                            output          1                                           tx_p_out14                          hip_serial                   conduit                 start               "((top_topology_integer_hwtcl == 5) || (top_topology_integer_hwtcl == 4) || (top_topology_integer_hwtcl == 3)) && hip_serial_standard_interface_selection_hwtcl"                                           NOVAL                   NOVAL                                                       "Check User Guide for details"                                }\
        { tx_p_out15                            output          1                                           tx_p_out15                          hip_serial                   conduit                 start               "((top_topology_integer_hwtcl == 5) || (top_topology_integer_hwtcl == 4) || (top_topology_integer_hwtcl == 3)) && hip_serial_standard_interface_selection_hwtcl"                                           NOVAL                   NOVAL                                                       "Check User Guide for details"                                }\
    \
        { rx_n_in0                              input           1                                           rx_n_in0                            hip_serial                    conduit                 end                 false                                           NOVAL                   NOVAL                                                       "Check User Guide for details"                                }\
        { rx_n_in1                              input           1                                           rx_n_in1                            hip_serial                    conduit                 end                 false                                           NOVAL                   NOVAL                                                       "Check User Guide for details"                                }\
        { rx_n_in2                              input           1                                           rx_n_in2                            hip_serial                    conduit                 end                 false                                           NOVAL                   NOVAL                                                       "Check User Guide for details"                                }\
        { rx_n_in3                              input           1                                           rx_n_in3                            hip_serial                    conduit                 end                 false                                           NOVAL                   NOVAL                                                       "Check User Guide for details"                                }\
        { rx_n_in4                              input           1                                           rx_n_in4                            hip_serial                    conduit                 end                 "(top_topology_integer_hwtcl == 3) && hip_serial_standard_interface_selection_hwtcl"                                           NOVAL                   NOVAL                                                       "Check User Guide for details"                                }\
        { rx_n_in5                              input           1                                           rx_n_in5                            hip_serial                    conduit                 end                 "(top_topology_integer_hwtcl == 3) && hip_serial_standard_interface_selection_hwtcl"                                           NOVAL                   NOVAL                                                       "Check User Guide for details"                                }\
        { rx_n_in6                              input           1                                           rx_n_in6                            hip_serial                    conduit                 end                 "(top_topology_integer_hwtcl == 3) && hip_serial_standard_interface_selection_hwtcl"                                           NOVAL                   NOVAL                                                       "Check User Guide for details"                                }\
        { rx_n_in7                              input           1                                           rx_n_in7                            hip_serial                    conduit                 end                 "(top_topology_integer_hwtcl == 3) && hip_serial_standard_interface_selection_hwtcl"                                           NOVAL                   NOVAL                                                       "Check User Guide for details"                                }\
        { rx_n_in8                              input           1                                           rx_n_in8                            hip_serial                    conduit                 end                 "((top_topology_integer_hwtcl == 5) || (top_topology_integer_hwtcl == 4) || (top_topology_integer_hwtcl == 3)) && hip_serial_standard_interface_selection_hwtcl"                                           NOVAL                   NOVAL                                                       "Check User Guide for details"                                }\
        { rx_n_in9                              input           1                                           rx_n_in9                            hip_serial                    conduit                 end                 "((top_topology_integer_hwtcl == 5) || (top_topology_integer_hwtcl == 4) || (top_topology_integer_hwtcl == 3)) && hip_serial_standard_interface_selection_hwtcl"                                           NOVAL                   NOVAL                                                       "Check User Guide for details"                                }\
        { rx_n_in10                             input           1                                           rx_n_in10                           hip_serial                    conduit                 end                 "((top_topology_integer_hwtcl == 5) || (top_topology_integer_hwtcl == 4) || (top_topology_integer_hwtcl == 3)) && hip_serial_standard_interface_selection_hwtcl"                                           NOVAL                   NOVAL                                                       "Check User Guide for details"                                }\
        { rx_n_in11                             input           1                                           rx_n_in11                           hip_serial                    conduit                 end                 "((top_topology_integer_hwtcl == 5) || (top_topology_integer_hwtcl == 4) || (top_topology_integer_hwtcl == 3)) && hip_serial_standard_interface_selection_hwtcl"                                           NOVAL                   NOVAL                                                       "Check User Guide for details"                                }\
        { rx_n_in12                             input           1                                           rx_n_in12                           hip_serial                    conduit                 end                 "((top_topology_integer_hwtcl == 5) || (top_topology_integer_hwtcl == 4) || (top_topology_integer_hwtcl == 3)) && hip_serial_standard_interface_selection_hwtcl"                                           NOVAL                   NOVAL                                                       "Check User Guide for details"                                }\
        { rx_n_in13                             input           1                                           rx_n_in13                           hip_serial                    conduit                 end                 "((top_topology_integer_hwtcl == 5) || (top_topology_integer_hwtcl == 4) || (top_topology_integer_hwtcl == 3)) && hip_serial_standard_interface_selection_hwtcl"                                           NOVAL                   NOVAL                                                       "Check User Guide for details"                                }\
        { rx_n_in14                             input           1                                           rx_n_in14                           hip_serial                    conduit                 end                 "((top_topology_integer_hwtcl == 5) || (top_topology_integer_hwtcl == 4) || (top_topology_integer_hwtcl == 3)) && hip_serial_standard_interface_selection_hwtcl"                                           NOVAL                   NOVAL                                                       "Check User Guide for details"                                }\
        { rx_n_in15                             input           1                                           rx_n_in15                           hip_serial                    conduit                 end                 "((top_topology_integer_hwtcl == 5) || (top_topology_integer_hwtcl == 4) || (top_topology_integer_hwtcl == 3)) && hip_serial_standard_interface_selection_hwtcl"                                           NOVAL                   NOVAL                                                       "Check User Guide for details"                                }\
    \
        { rx_p_in0                              input           1                                           rx_p_in0                            hip_serial                    conduit                 end                 false                                           NOVAL                   NOVAL                                                       "Check User Guide for details"                                }\
        { rx_p_in1                              input           1                                           rx_p_in1                            hip_serial                    conduit                 end                 false                                           NOVAL                   NOVAL                                                       "Check User Guide for details"                                }\
        { rx_p_in2                              input           1                                           rx_p_in2                            hip_serial                    conduit                 end                 false                                           NOVAL                   NOVAL                                                       "Check User Guide for details"                                }\
        { rx_p_in3                              input           1                                           rx_p_in3                            hip_serial                    conduit                 end                 false                                           NOVAL                   NOVAL                                                       "Check User Guide for details"                                }\
        { rx_p_in4                              input           1                                           rx_p_in4                            hip_serial                    conduit                 end                 "(top_topology_integer_hwtcl == 3) && hip_serial_standard_interface_selection_hwtcl"                                           NOVAL                   NOVAL                                                       "Check User Guide for details"                                }\
        { rx_p_in5                              input           1                                           rx_p_in5                            hip_serial                    conduit                 end                 "(top_topology_integer_hwtcl == 3) && hip_serial_standard_interface_selection_hwtcl"                                           NOVAL                   NOVAL                                                       "Check User Guide for details"                                }\
        { rx_p_in6                              input           1                                           rx_p_in6                            hip_serial                    conduit                 end                 "(top_topology_integer_hwtcl == 3) && hip_serial_standard_interface_selection_hwtcl"                                           NOVAL                   NOVAL                                                       "Check User Guide for details"                                }\
        { rx_p_in7                              input           1                                           rx_p_in7                            hip_serial                    conduit                 end                 "(top_topology_integer_hwtcl == 3) && hip_serial_standard_interface_selection_hwtcl"                                           NOVAL                   NOVAL                                                       "Check User Guide for details"                                }\
        { rx_p_in8                              input           1                                           rx_p_in8                            hip_serial                    conduit                 end                 "((top_topology_integer_hwtcl == 5) || (top_topology_integer_hwtcl == 4) || (top_topology_integer_hwtcl == 3)) && hip_serial_standard_interface_selection_hwtcl"                                           NOVAL                   NOVAL                                                       "Check User Guide for details"                                }\
        { rx_p_in9                              input           1                                           rx_p_in9                            hip_serial                    conduit                 end                 "((top_topology_integer_hwtcl == 5) || (top_topology_integer_hwtcl == 4) || (top_topology_integer_hwtcl == 3)) && hip_serial_standard_interface_selection_hwtcl"                                           NOVAL                   NOVAL                                                       "Check User Guide for details"                                }\
        { rx_p_in10                             input           1                                           rx_p_in10                           hip_serial                    conduit                 end                 "((top_topology_integer_hwtcl == 5) || (top_topology_integer_hwtcl == 4) || (top_topology_integer_hwtcl == 3)) && hip_serial_standard_interface_selection_hwtcl"                                           NOVAL                   NOVAL                                                       "Check User Guide for details"                                }\
        { rx_p_in11                             input           1                                           rx_p_in11                           hip_serial                    conduit                 end                 "((top_topology_integer_hwtcl == 5) || (top_topology_integer_hwtcl == 4) || (top_topology_integer_hwtcl == 3)) && hip_serial_standard_interface_selection_hwtcl"                                           NOVAL                   NOVAL                                                       "Check User Guide for details"                                }\
        { rx_p_in12                             input           1                                           rx_p_in12                           hip_serial                    conduit                 end                 "((top_topology_integer_hwtcl == 5) || (top_topology_integer_hwtcl == 4) || (top_topology_integer_hwtcl == 3)) && hip_serial_standard_interface_selection_hwtcl"                                           NOVAL                   NOVAL                                                       "Check User Guide for details"                                }\
        { rx_p_in13                             input           1                                           rx_p_in13                           hip_serial                    conduit                 end                 "((top_topology_integer_hwtcl == 5) || (top_topology_integer_hwtcl == 4) || (top_topology_integer_hwtcl == 3)) && hip_serial_standard_interface_selection_hwtcl"                                           NOVAL                   NOVAL                                                       "Check User Guide for details"                                }\
        { rx_p_in14                             input           1                                           rx_p_in14                           hip_serial                    conduit                 end                 "((top_topology_integer_hwtcl == 5) || (top_topology_integer_hwtcl == 4) || (top_topology_integer_hwtcl == 3)) && hip_serial_standard_interface_selection_hwtcl"                                           NOVAL                   NOVAL                                                       "Check User Guide for details"                                }\
        { rx_p_in15                             input           1                                           rx_p_in15                           hip_serial                    conduit                 end                 "((top_topology_integer_hwtcl == 5) || (top_topology_integer_hwtcl == 4) || (top_topology_integer_hwtcl == 3)) && hip_serial_standard_interface_selection_hwtcl"                                           NOVAL                   NOVAL                                                       "Check User Guide for details"                                }\
    \
        { p0_test_in_i				            input           2                                           p0_test_in_i                            p0_test_in_i                    conduit                 end                 true                                           NOVAL                   NOVAL                                                       "Check User Guide for details"                                }\
        { p0_test_out_o				            output          140                                         tx_n_out0                           	tx_n_out                   		conduit                 start               true                                           NOVAL                   NOVAL                                                       "Check User Guide for details"                                }\
        { p1_test_in_i				            input           1                                           p1_test_in_i                            p1_test_in_i                    conduit                 end                 true                                           NOVAL                   NOVAL                                                       "Check User Guide for details"                                }\
        { p1_test_out_o				            output          70                                          tx_n_out0                           	tx_n_out                   		conduit                 start               true                                           NOVAL                   NOVAL                                                       "Check User Guide for details"                                }\
        { p2_test_in_i				            input           1                                           p2_test_in_i                            p2_test_in_i                    conduit                 end                 true                                           NOVAL                   NOVAL                                                       "Check User Guide for details"                                }\
        { p2_test_out_o				            output          35                                          tx_n_out0                           	tx_n_out                   		conduit                 start               true                                           NOVAL                   NOVAL                                                       "Check User Guide for details"                                }\
        { p3_test_in_i				            input           1                                           p3_test_in_i                            p3_test_in_i                    conduit                 end                 true                                           NOVAL                   NOVAL                                                       "Check User Guide for details"                                }\
        { p3_test_out_o				            output          35                                          tx_n_out0                           	tx_n_out                   		conduit                 start               true                                           NOVAL                   NOVAL                                                       "Check User Guide for details"                                }\
    
   \
        { p0_ss_app_vf_err_poisonedwrreq_s0        output          1                                           ss_app_vf_err_poisonedwrreq                           	p0_ss_app_vf_err_poisonedwrreq_s0                   		conduit                 start               "pcie_ss_func_mode_integer_hwtcl > 0 ||core16_virtual_rp_ep_mode_integer_hwtcl ||!core16_enable_sriov_hwtcl"                                              NOVAL                 ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_vf_err_poisonedwrreq_s0                                                        "Check User Guide for details"                                }\
        { p0_ss_app_vf_err_poisonedwrreq_s1        output          1                                           ss_app_vf_err_poisonedwrreq                           	p0_ss_app_vf_err_poisonedwrreq_s1                   		conduit                 start               "pcie_ss_func_mode_integer_hwtcl > 0 ||core16_virtual_rp_ep_mode_integer_hwtcl||!core16_enable_sriov_hwtcl"                                              NOVAL                 ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_vf_err_poisonedwrreq_s1                                                         "Check User Guide for details"                                }\
        { p0_ss_app_vf_err_poisonedwrreq_s2        output          1                                           ss_app_vf_err_poisonedwrreq                           	p0_ss_app_vf_err_poisonedwrreq_s2                   		conduit                 start               "tile_integer == 2 || pcie_ss_func_mode_integer_hwtcl > 0 ||core16_virtual_rp_ep_mode_integer_hwtcl||!core16_enable_sriov_hwtcl"                         NOVAL                 ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_vf_err_poisonedwrreq_s2                                                       "Check User Guide for details"                                }\
        { p0_ss_app_vf_err_poisonedwrreq_s3        output          1                                           ss_app_vf_err_poisonedwrreq                           	p0_ss_app_vf_err_poisonedwrreq_s3                   		conduit                 start               "tile_integer == 2 || pcie_ss_func_mode_integer_hwtcl > 0 ||core16_virtual_rp_ep_mode_integer_hwtcl||!core16_enable_sriov_hwtcl"                         NOVAL                 ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_vf_err_poisonedwrreq_s3                                                         "Check User Guide for details"                                }\
        { p0_ss_app_vf_err_poisonedcompl_s0        output          1                                           ss_app_vf_err_poisonedcompl                           	p0_ss_app_vf_err_poisonedcompl_s0                   		conduit                 start               "pcie_ss_func_mode_integer_hwtcl > 0 ||core16_virtual_rp_ep_mode_integer_hwtcl||!core16_enable_sriov_hwtcl"                                              NOVAL                 ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_vf_err_poisonedcompl_s0                                                       "Check User Guide for details"                                }\
        { p0_ss_app_vf_err_poisonedcompl_s1        output          1                                           ss_app_vf_err_poisonedcompl                           	p0_ss_app_vf_err_poisonedcompl_s1                   		conduit                 start               "pcie_ss_func_mode_integer_hwtcl > 0 ||core16_virtual_rp_ep_mode_integer_hwtcl||!core16_enable_sriov_hwtcl"                                              NOVAL                 ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_vf_err_poisonedcompl_s1                                                        "Check User Guide for details"                                }\
        { p0_ss_app_vf_err_poisonedcompl_s2        output          1                                           ss_app_vf_err_poisonedcompl                           	p0_ss_app_vf_err_poisonedcompl_s2                   		conduit                 start               "tile_integer == 2 || pcie_ss_func_mode_integer_hwtcl > 0 ||core16_virtual_rp_ep_mode_integer_hwtcl||!core16_enable_sriov_hwtcl"                         NOVAL                 ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_vf_err_poisonedcompl_s2                                                        "Check User Guide for details"                                }\
        { p0_ss_app_vf_err_poisonedcompl_s3        output          1                                           ss_app_vf_err_poisonedcompl                           	p0_ss_app_vf_err_poisonedcompl_s3                   		conduit                 start               "tile_integer == 2 || pcie_ss_func_mode_integer_hwtcl > 0 ||core16_virtual_rp_ep_mode_integer_hwtcl||!core16_enable_sriov_hwtcl"                         NOVAL                 ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_vf_err_poisonedcompl_s3                                                        "Check User Guide for details"                                }\
        { p0_ss_app_vf_err_ur_postedreq_s0         output          1                                           ss_app_vf_err_ur_postedreq                           	p0_ss_app_vf_err_ur_postedreq_s0                       		conduit                 start               "pcie_ss_func_mode_integer_hwtcl > 0 ||core16_virtual_rp_ep_mode_integer_hwtcl||!core16_enable_sriov_hwtcl"                                              NOVAL                 ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_vf_err_ur_postedreq_s0                                                       "Check User Guide for details"                                }\
        { p0_ss_app_vf_err_ur_postedreq_s1         output          1                                           ss_app_vf_err_ur_postedreq                           	p0_ss_app_vf_err_ur_postedreq_s1                       		conduit                 start               "pcie_ss_func_mode_integer_hwtcl > 0||core16_virtual_rp_ep_mode_integer_hwtcl||!core16_enable_sriov_hwtcl"                                              NOVAL                 ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_vf_err_ur_postedreq_s1                                                       "Check User Guide for details"                                }\
        { p0_ss_app_vf_err_ur_postedreq_s2         output          1                                           ss_app_vf_err_ur_postedreq                           	p0_ss_app_vf_err_ur_postedreq_s2                       		conduit                 start               "tile_integer == 2 || pcie_ss_func_mode_integer_hwtcl > 0||core16_virtual_rp_ep_mode_integer_hwtcl||!core16_enable_sriov_hwtcl"                         NOVAL                 ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_vf_err_ur_postedreq_s2                                                       "Check User Guide for details"                                }\
        { p0_ss_app_vf_err_ur_postedreq_s3         output          1                                           ss_app_vf_err_ur_postedreq                           	p0_ss_app_vf_err_ur_postedreq_s3                       		conduit                 start               "tile_integer == 2 || pcie_ss_func_mode_integer_hwtcl > 0||core16_virtual_rp_ep_mode_integer_hwtcl||!core16_enable_sriov_hwtcl"                         NOVAL                 ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_vf_err_ur_postedreq_s3                                                        "Check User Guide for details"                                }\
        { p0_ss_app_vf_err_ca_postedreq_s0         output          1                                           ss_app_vf_err_ca_postedreq                           	p0_ss_app_vf_err_ca_postedreq_s0                    		conduit                 start               "pcie_ss_func_mode_integer_hwtcl > 0||core16_virtual_rp_ep_mode_integer_hwtcl||!core16_enable_sriov_hwtcl"                                              NOVAL                 ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_vf_err_ca_postedreq_s0                                                       "Check User Guide for details"                                }\
        { p0_ss_app_vf_err_ca_postedreq_s1         output          1                                           ss_app_vf_err_ca_postedreq                           	p0_ss_app_vf_err_ca_postedreq_s1                    		conduit                 start               "pcie_ss_func_mode_integer_hwtcl > 0||core16_virtual_rp_ep_mode_integer_hwtcl||!core16_enable_sriov_hwtcl"                                              NOVAL                 ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_vf_err_ca_postedreq_s1                                                       "Check User Guide for details"                                }\
        { p0_ss_app_vf_err_ca_postedreq_s2         output          1                                           ss_app_vf_err_ca_postedreq                           	p0_ss_app_vf_err_ca_postedreq_s2                    		conduit                 start               "tile_integer == 2 || pcie_ss_func_mode_integer_hwtcl > 0||core16_virtual_rp_ep_mode_integer_hwtcl||!core16_enable_sriov_hwtcl"                         NOVAL                 ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_vf_err_ca_postedreq_s2                                                        "Check User Guide for details"                                }\
        { p0_ss_app_vf_err_ca_postedreq_s3         output          1                                           ss_app_vf_err_ca_postedreq                           	p0_ss_app_vf_err_ca_postedreq_s3                       		conduit                 start               "tile_integer == 2 || pcie_ss_func_mode_integer_hwtcl > 0||core16_virtual_rp_ep_mode_integer_hwtcl||!core16_enable_sriov_hwtcl"                         NOVAL                 ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_vf_err_ca_postedreq_s3                                                       "Check User Guide for details"                                }\
        { p0_ss_app_vf_err_vf_num_s0               output          11                                          ss_app_vf_err_vf_num                           	        p0_ss_app_vf_err_vf_num_s0                   		        conduit                 start               "pcie_ss_func_mode_integer_hwtcl > 0||core16_virtual_rp_ep_mode_integer_hwtcl||!core16_enable_sriov_hwtcl"                                              NOVAL                 ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_vf_err_vf_num_s0                                                       "Check User Guide for details"                                }\
        { p0_ss_app_vf_err_vf_num_s1               output          11                                          ss_app_vf_err_vf_num                           	        p0_ss_app_vf_err_vf_num_s1                   		        conduit                 start               "pcie_ss_func_mode_integer_hwtcl > 0||core16_virtual_rp_ep_mode_integer_hwtcl||!core16_enable_sriov_hwtcl"                                              NOVAL                 ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_vf_err_vf_num_s1                                                       "Check User Guide for details"                                }\
        { p0_ss_app_vf_err_vf_num_s2               output          11                                          ss_app_vf_err_vf_num                           	        p0_ss_app_vf_err_vf_num_s2                   		        conduit                 start               "tile_integer == 2 || pcie_ss_func_mode_integer_hwtcl > 0||core16_virtual_rp_ep_mode_integer_hwtcl||!core16_enable_sriov_hwtcl"                         NOVAL                 ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_vf_err_vf_num_s2                                                       "Check User Guide for details"                                }\
        { p0_ss_app_vf_err_vf_num_s3               output          11                                          ss_app_vf_err_vf_num                           	        p0_ss_app_vf_err_vf_num_s3                   		        conduit                 start               "tile_integer == 2 || pcie_ss_func_mode_integer_hwtcl > 0||core16_virtual_rp_ep_mode_integer_hwtcl||!core16_enable_sriov_hwtcl"                         NOVAL                 ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_vf_err_vf_num_s3                                                       "Check User Guide for details"                                }\
        { p0_ss_app_vf_err_func_num_s0             output          3                                           ss_app_vf_err_func_num                           	    p0_ss_app_vf_err_func_num_s0                     		    conduit                 start               "pcie_ss_func_mode_integer_hwtcl > 0||core16_virtual_rp_ep_mode_integer_hwtcl||!core16_enable_sriov_hwtcl"                                              NOVAL                 ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_vf_err_func_num_s0                                                       "Check User Guide for details"                                }\
        { p0_ss_app_vf_err_func_num_s1             output          3                                           ss_app_vf_err_func_num                           	    p0_ss_app_vf_err_func_num_s1                   		        conduit                 start               "pcie_ss_func_mode_integer_hwtcl > 0||core16_virtual_rp_ep_mode_integer_hwtcl||!core16_enable_sriov_hwtcl"                                              NOVAL                 ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_vf_err_func_num_s1                                                      "Check User Guide for details"                                }\
        { p0_ss_app_vf_err_func_num_s2             output          3                                           ss_app_vf_err_func_num                           	    p0_ss_app_vf_err_func_num_s2                   		        conduit                 start               "tile_integer == 2 || pcie_ss_func_mode_integer_hwtcl > 0||core16_virtual_rp_ep_mode_integer_hwtcl||!core16_enable_sriov_hwtcl"                         NOVAL                 ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_vf_err_func_num_s2                                                       "Check User Guide for details"                                }\
        { p0_ss_app_vf_err_func_num_s3             output          3                                           ss_app_vf_err_func_num                           	    p0_ss_app_vf_err_func_num_s3                   		        conduit                 start               "tile_integer == 2 || pcie_ss_func_mode_integer_hwtcl > 0||core16_virtual_rp_ep_mode_integer_hwtcl||!core16_enable_sriov_hwtcl"                         NOVAL                 ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_vf_err_func_num_s3                                                    "Check User Guide for details"                                }\
        { p0_ss_app_vf_err_overflow                output          1                                           ss_app_vf_err_overflow                           	    p0_ss_app_vf_err_overflow                   		        conduit                 start               "pcie_ss_func_mode_integer_hwtcl > 0||core16_virtual_rp_ep_mode_integer_hwtcl||!core16_enable_sriov_hwtcl"                                              NOVAL                 ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_vf_err_overflow                                                       "Check User Guide for details"                                }\
        { p0_ss_app_vfnonfatalmsg_ready            output          1                                           ss_app_vfnonfatalmsg_ready                               p0_ss_app_vfnonfatalmsg_ready                   		        conduit                 start               "pcie_ss_func_mode_integer_hwtcl > 0||core16_virtual_rp_ep_mode_integer_hwtcl||!core16_enable_sriov_hwtcl"                                          NOVAL                 ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_vfnonfatalmsg_ready                                                       "Check User Guide for details"                                }\
        { p0_app_ss_sent_vfnonfatalmsg             input           1                                           app_ss_sent_vfnonfatalmsg                                p0_app_ss_sent_vfnonfatalmsg                                conduit                 end                 "pcie_ss_func_mode_integer_hwtcl > 0||core16_virtual_rp_ep_mode_integer_hwtcl||!core16_enable_sriov_hwtcl"                                              NOVAL                 ::intel_pcie_ss_axi::interfaces::elaborate_app_ss_sent_vfnonfatalmsg                                                       "Check User Guide for details"                                }\
        { p0_app_ss_vfnonfatalmsg_vf_num           input           11                                          app_ss_vfnonfatalmsg_vf_num                              p0_app_ss_vfnonfatalmsg_vf_num                              conduit                 end                 "pcie_ss_func_mode_integer_hwtcl > 0||core16_virtual_rp_ep_mode_integer_hwtcl||!core16_enable_sriov_hwtcl"                                              NOVAL                 ::intel_pcie_ss_axi::interfaces::elaborate_app_ss_vfnonfatalmsg_vf_num                                                       "Check User Guide for details"                                }\
        { p0_app_ss_vfnonfatalmsg_func_num         input           3                                           app_ss_vfnonfatalmsg_func_num                            p0_app_ss_vfnonfatalmsg_func_num                            conduit                 end                 "pcie_ss_func_mode_integer_hwtcl > 0||core16_virtual_rp_ep_mode_integer_hwtcl||!core16_enable_sriov_hwtcl"                                              NOVAL                 ::intel_pcie_ss_axi::interfaces::elaborate_app_ss_vfnonfatalmsg_func_num                                                  "Check User Guide for details"                                }\
    \
        { p1_ss_app_vf_err_poisonedwrreq_s0        output          1                                           ss_app_vf_err_poisonedwrreq                           	p1_ss_app_vf_err_poisonedwrreq_s0                   		conduit                 start               "pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || (top_topology_integer_hwtcl == 4) || pcie_ss_func_mode_integer_hwtcl > 0 ||core8_virtual_rp_ep_mode_integer_hwtcl||!core8_enable_sriov_hwtcl"                 NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_vf_err_poisonedwrreq_s0                                                       "Check User Guide for details"                                }\
        { p1_ss_app_vf_err_poisonedwrreq_s1        output          1                                           ss_app_vf_err_poisonedwrreq                           	p1_ss_app_vf_err_poisonedwrreq_s1                   		conduit                 start               "pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || (top_topology_integer_hwtcl == 1 && tile_integer == 2) || (top_topology_integer_hwtcl == 4) || pcie_ss_func_mode_integer_hwtcl > 0 ||core8_virtual_rp_ep_mode_integer_hwtcl||!core8_enable_sriov_hwtcl "                 NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_vf_err_poisonedwrreq_s1                                                       "Check User Guide for details"                                }\
        { p1_ss_app_vf_err_poisonedcompl_s0        output          1                                           ss_app_vf_err_poisonedcompl                           	p1_ss_app_vf_err_poisonedcompl_s0                   		conduit                 start               "pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || (top_topology_integer_hwtcl == 4) || pcie_ss_func_mode_integer_hwtcl > 0 ||core8_virtual_rp_ep_mode_integer_hwtcl||!core8_enable_sriov_hwtcl"                 NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_vf_err_poisonedcompl_s0                                                       "Check User Guide for details"                                }\
        { p1_ss_app_vf_err_poisonedcompl_s1        output          1                                           ss_app_vf_err_poisonedcompl                           	p1_ss_app_vf_err_poisonedcompl_s1                   		conduit                 start               "pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || (top_topology_integer_hwtcl == 1 && tile_integer == 2) || (top_topology_integer_hwtcl == 4) || pcie_ss_func_mode_integer_hwtcl > 0 ||core8_virtual_rp_ep_mode_integer_hwtcl||!core8_enable_sriov_hwtcl"                 NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_vf_err_poisonedcompl_s1                                                        "Check User Guide for details"                                }\
        { p1_ss_app_vf_err_ur_postedreq_s0         output          1                                           ss_app_vf_err_ur_postedreq                             	p1_ss_app_vf_err_ur_postedreq_s0                     		conduit                 start               "pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || (top_topology_integer_hwtcl == 4) || pcie_ss_func_mode_integer_hwtcl > 0 ||core8_virtual_rp_ep_mode_integer_hwtcl||!core8_enable_sriov_hwtcl"                 NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_vf_err_ur_postedreq_s0                                                       "Check User Guide for details"                                }\
        { p1_ss_app_vf_err_ur_postedreq_s1         output          1                                           ss_app_vf_err_ur_postedreq                           	p1_ss_app_vf_err_ur_postedreq_s1                   	       	conduit                 start               "pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || (top_topology_integer_hwtcl == 1 && tile_integer == 2) || (top_topology_integer_hwtcl == 4) || pcie_ss_func_mode_integer_hwtcl > 0 ||core8_virtual_rp_ep_mode_integer_hwtcl||!core8_enable_sriov_hwtcl"                 NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_vf_err_ur_postedreq_s1                                                       "Check User Guide for details"                                }\
        { p1_ss_app_vf_err_ca_postedreq_s0         output          1                                           ss_app_vf_err_ca_postedreq                           	p1_ss_app_vf_err_ca_postedreq_s0                   	       	conduit                 start               "pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || (top_topology_integer_hwtcl == 4) || pcie_ss_func_mode_integer_hwtcl > 0 ||core8_virtual_rp_ep_mode_integer_hwtcl||!core8_enable_sriov_hwtcl"                 NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_vf_err_ca_postedreq_s0                                                       "Check User Guide for details"                                }\
        { p1_ss_app_vf_err_ca_postedreq_s1         output          1                                           ss_app_vf_err_ca_postedreq                           	p1_ss_app_vf_err_ca_postedreq_s1                   	       	conduit                 start               "pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || (top_topology_integer_hwtcl == 1 && tile_integer == 2) || (top_topology_integer_hwtcl == 4) || pcie_ss_func_mode_integer_hwtcl > 0 ||core8_virtual_rp_ep_mode_integer_hwtcl||!core8_enable_sriov_hwtcl"                 NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_vf_err_ca_postedreq_s1                                                        "Check User Guide for details"                                }\
        { p1_ss_app_vf_err_vf_num_s0               output          11                                          ss_app_vf_err_vf_num                           	        p1_ss_app_vf_err_vf_num_s0                   		        conduit                 start               "pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || (top_topology_integer_hwtcl == 4) || pcie_ss_func_mode_integer_hwtcl > 0 ||core8_virtual_rp_ep_mode_integer_hwtcl||!core8_enable_sriov_hwtcl"                 NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_vf_err_vf_num_s0                                                       "Check User Guide for details"                                }\
        { p1_ss_app_vf_err_vf_num_s1               output          11                                          ss_app_vf_err_vf_num                           	        p1_ss_app_vf_err_vf_num_s1                   		        conduit                 start               "pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || (top_topology_integer_hwtcl == 1 && tile_integer == 2) || (top_topology_integer_hwtcl == 4) || pcie_ss_func_mode_integer_hwtcl > 0 ||core8_virtual_rp_ep_mode_integer_hwtcl||!core8_enable_sriov_hwtcl"                 NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_vf_err_vf_num_s1                                                      "Check User Guide for details"                                }\
        { p1_ss_app_vf_err_func_num_s0             output          3                                           ss_app_vf_err_func_num                           	    p1_ss_app_vf_err_func_num_s0                   		        conduit                 start               "pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || (top_topology_integer_hwtcl == 4) || pcie_ss_func_mode_integer_hwtcl > 0 ||core8_virtual_rp_ep_mode_integer_hwtcl||!core8_enable_sriov_hwtcl"                 NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_vf_err_func_num_s0                                                       "Check User Guide for details"                                }\
        { p1_ss_app_vf_err_func_num_s1             output          3                                           ss_app_vf_err_func_num                           	    p1_ss_app_vf_err_func_num_s1                   		        conduit                 start               "pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || (top_topology_integer_hwtcl == 1 && tile_integer == 2) || (top_topology_integer_hwtcl == 4) || pcie_ss_func_mode_integer_hwtcl > 0 ||core8_virtual_rp_ep_mode_integer_hwtcl||!core8_enable_sriov_hwtcl"                 NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_vf_err_func_num_s1                                                       "Check User Guide for details"                                }\
        { p1_ss_app_vf_err_overflow                output          1                                           ss_app_vf_err_overflow                         	        p1_ss_app_vf_err_overflow                   	     	    conduit                 start               "pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || (top_topology_integer_hwtcl == 4) || pcie_ss_func_mode_integer_hwtcl > 0 ||core8_virtual_rp_ep_mode_integer_hwtcl||!core8_enable_sriov_hwtcl"                 NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_vf_err_overflow                                                     "Check User Guide for details"                                }\
        { p1_ss_app_vfnonfatalmsg_ready            output          1                                           ss_app_vfnonfatalmsg_ready                               p1_ss_app_vfnonfatalmsg_ready                               conduit                 start               "pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || (top_topology_integer_hwtcl == 4) || pcie_ss_func_mode_integer_hwtcl > 0 ||core8_virtual_rp_ep_mode_integer_hwtcl||!core8_enable_sriov_hwtcl"         NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_vfnonfatalmsg_ready                                                        "Check User Guide for details"                                }\
        { p1_app_ss_sent_vfnonfatalmsg             input           1                                           app_ss_sent_vfnonfatalmsg                                p1_app_ss_sent_vfnonfatalmsg                                conduit                 end                 "pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || (top_topology_integer_hwtcl == 4) || pcie_ss_func_mode_integer_hwtcl > 0 ||core8_virtual_rp_ep_mode_integer_hwtcl||!core8_enable_sriov_hwtcl"                 NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_app_ss_sent_vfnonfatalmsg                                                        "Check User Guide for details"                                }\
        { p1_app_ss_vfnonfatalmsg_vf_num           input           11                                          app_ss_vfnonfatalmsg_vf_num                              p1_app_ss_vfnonfatalmsg_vf_num                              conduit                 end                 "pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || (top_topology_integer_hwtcl == 4) || pcie_ss_func_mode_integer_hwtcl > 0 ||core8_virtual_rp_ep_mode_integer_hwtcl||!core8_enable_sriov_hwtcl"                 NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_app_ss_vfnonfatalmsg_vf_num                                                       "Check User Guide for details"                                }\
        { p1_app_ss_vfnonfatalmsg_func_num         input           3                                           app_ss_vfnonfatalmsg_func_num                            p1_app_ss_vfnonfatalmsg_func_num                            conduit                 end                 "pciess_topology_integer_hwtcl < 1 || top_topology_integer_hwtcl <1 || (top_topology_integer_hwtcl == 4) || pcie_ss_func_mode_integer_hwtcl > 0 ||core8_virtual_rp_ep_mode_integer_hwtcl||!core8_enable_sriov_hwtcl"                 NOVAL                   ::intel_pcie_ss_axi::interfaces::elaborate_app_ss_vfnonfatalmsg_func_num                                                       "Check User Guide for details"                                }\

        { p2_ss_app_vf_err_poisonedwrreq_s0        output          1                                           ss_app_vf_err_poisonedwrreq                           	p2_ss_app_vf_err_poisonedwrreq_s0                   		conduit                 start               "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || pcie_ss_func_mode_integer_hwtcl > 0||tile_integer >1||core4_0_virtual_rp_ep_mode_integer_hwtcl||!core4_0_enable_sriov_hwtcl"                 NOVAL                  ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_vf_err_poisonedwrreq_s0                                                        "Check User Guide for details"                                }\
        { p2_ss_app_vf_err_poisonedcompl_s0        output          1                                           ss_app_vf_err_poisonedcompl                           	p2_ss_app_vf_err_poisonedcompl_s0                   		conduit                 start               "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || pcie_ss_func_mode_integer_hwtcl > 0||tile_integer >1||core4_0_virtual_rp_ep_mode_integer_hwtcl||!core4_0_enable_sriov_hwtcl"                 NOVAL                  ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_vf_err_poisonedcompl_s0                                                      "Check User Guide for details"                                }\
        { p2_ss_app_vf_err_ur_postedreq_s0         output          1                                           ss_app_vf_err_ur_postedreq                             	p2_ss_app_vf_err_ur_postedreq_s0                     		conduit                 start               "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || pcie_ss_func_mode_integer_hwtcl > 0||tile_integer >1||core4_0_virtual_rp_ep_mode_integer_hwtcl||!core4_0_enable_sriov_hwtcl"                 NOVAL                  ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_vf_err_ur_postedreq_s0                                                       "Check User Guide for details"                                }\
        { p2_ss_app_vf_err_ca_postedreq_s0         output          1                                           ss_app_vf_err_ca_postedreq                           	p2_ss_app_vf_err_ca_postedreq_s0                   	       	conduit                 start               "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || pcie_ss_func_mode_integer_hwtcl > 0||tile_integer >1||core4_0_virtual_rp_ep_mode_integer_hwtcl||!core4_0_enable_sriov_hwtcl"                 NOVAL                  ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_vf_err_ca_postedreq_s0                                                       "Check User Guide for details"                                }\
        { p2_ss_app_vf_err_vf_num_s0               output          11                                          ss_app_vf_err_vf_num                           	        p2_ss_app_vf_err_vf_num_s0                   		        conduit                 start               "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || pcie_ss_func_mode_integer_hwtcl > 0||tile_integer >1||core4_0_virtual_rp_ep_mode_integer_hwtcl||!core4_0_enable_sriov_hwtcl"                 NOVAL                  ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_vf_err_vf_num_s0                                                       "Check User Guide for details"                                }\
        { p2_ss_app_vf_err_func_num_s0             output          3                                           ss_app_vf_err_func_num                           	    p2_ss_app_vf_err_func_num_s0                   		        conduit                 start               "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || pcie_ss_func_mode_integer_hwtcl > 0||tile_integer >1||core4_0_virtual_rp_ep_mode_integer_hwtcl||!core4_0_enable_sriov_hwtcl"                 NOVAL                  ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_vf_err_func_num_s0                                                        "Check User Guide for details"                                }\
        { p2_ss_app_vf_err_overflow                output          1                                           ss_app_vf_err_overflow                         	        p2_ss_app_vf_err_overflow                   	     	    conduit                 start               "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || pcie_ss_func_mode_integer_hwtcl > 0||tile_integer >1||core4_0_virtual_rp_ep_mode_integer_hwtcl||!core4_0_enable_sriov_hwtcl"                 NOVAL                  ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_vf_err_overflow                                                       "Check User Guide for details"                                }\
        { p2_ss_app_vfnonfatalmsg_ready            output          1                                           ss_app_vfnonfatalmsg_ready                           	p2_ss_app_vfnonfatalmsg_ready                   		        conduit                 start               "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2|| pcie_ss_func_mode_integer_hwtcl > 0||tile_integer >1||core4_0_virtual_rp_ep_mode_integer_hwtcl||!core4_0_enable_sriov_hwtcl"              NOVAL                  ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_vfnonfatalmsg_ready                                                        "Check User Guide for details"                                }\
        { p2_app_ss_sent_vfnonfatalmsg             input           1                                           app_ss_sent_vfnonfatalmsg                                p2_app_ss_sent_vfnonfatalmsg                                conduit                 end                 "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || pcie_ss_func_mode_integer_hwtcl > 0||tile_integer >1||core4_0_virtual_rp_ep_mode_integer_hwtcl||!core4_0_enable_sriov_hwtcl"                 NOVAL                  ::intel_pcie_ss_axi::interfaces::elaborate_app_ss_sent_vfnonfatalmsg                                                        "Check User Guide for details"                                }\
        { p2_app_ss_vfnonfatalmsg_vf_num           input           11                                          app_ss_vfnonfatalmsg_vf_num                              p2_app_ss_vfnonfatalmsg_vf_num                              conduit                 end                 "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || pcie_ss_func_mode_integer_hwtcl > 0||tile_integer >1||core4_0_virtual_rp_ep_mode_integer_hwtcl||!core4_0_enable_sriov_hwtcl"                 NOVAL                  ::intel_pcie_ss_axi::interfaces::elaborate_app_ss_vfnonfatalmsg_vf_num                                                         "Check User Guide for details"                                }\
        { p2_app_ss_vfnonfatalmsg_func_num         input           3                                           app_ss_vfnonfatalmsg_func_num                            p2_app_ss_vfnonfatalmsg_func_num                            conduit                 end                 "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || pcie_ss_func_mode_integer_hwtcl > 0||tile_integer >1||core4_0_virtual_rp_ep_mode_integer_hwtcl||!core4_0_enable_sriov_hwtcl"                 NOVAL                  ::intel_pcie_ss_axi::interfaces::elaborate_app_ss_vfnonfatalmsg_func_num                                                     "Check User Guide for details"                                }\
        
        { p3_ss_app_vf_err_poisonedwrreq_s0        output          1                                           ss_app_vf_err_poisonedwrreq                           	p3_ss_app_vf_err_poisonedwrreq_s0                   		conduit                 start               "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || (top_topology_integer_hwtcl == 4) || pcie_ss_func_mode_integer_hwtcl > 0||tile_integer >1||core4_1_virtual_rp_ep_mode_integer_hwtcl||!core4_1_enable_sriov_hwtcl"                 NOVAL                  ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_vf_err_poisonedwrreq_s0                                                       "Check User Guide for details"                                }\
        { p3_ss_app_vf_err_poisonedcompl_s0        output          1                                           ss_app_vf_err_poisonedcompl                           	p3_ss_app_vf_err_poisonedcompl_s0                   		conduit                 start               "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || (top_topology_integer_hwtcl == 4) || pcie_ss_func_mode_integer_hwtcl > 0||tile_integer >1||core4_1_virtual_rp_ep_mode_integer_hwtcl||!core4_1_enable_sriov_hwtcl"                 NOVAL                  ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_vf_err_poisonedcompl_s0                                                           "Check User Guide for details"                                }\
        { p3_ss_app_vf_err_ur_postedreq_s0         output          1                                           ss_app_vf_err_ur_postedreq                             	p3_ss_app_vf_err_ur_postedreq_s0                     		conduit                 start               "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || (top_topology_integer_hwtcl == 4) || pcie_ss_func_mode_integer_hwtcl > 0||tile_integer >1||core4_1_virtual_rp_ep_mode_integer_hwtcl||!core4_1_enable_sriov_hwtcl"                 NOVAL                  ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_vf_err_ur_postedreq_s0                                                        "Check User Guide for details"                                }\
        { p3_ss_app_vf_err_ca_postedreq_s0         output          1                                           ss_app_vf_err_ca_postedreq                           	p3_ss_app_vf_err_ca_postedreq_s0                   	       	conduit                 start               "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || (top_topology_integer_hwtcl == 4) || pcie_ss_func_mode_integer_hwtcl > 0||tile_integer >1||core4_1_virtual_rp_ep_mode_integer_hwtcl||!core4_1_enable_sriov_hwtcl"                 NOVAL                  ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_vf_err_ca_postedreq_s0                                                        "Check User Guide for details"                                }\
        { p3_ss_app_vf_err_vf_num_s0               output          11                                          ss_app_vf_err_vf_num                           	        p3_ss_app_vf_err_vf_num_s0                   		        conduit                 start               "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || (top_topology_integer_hwtcl == 4) || pcie_ss_func_mode_integer_hwtcl > 0||tile_integer >1||core4_1_virtual_rp_ep_mode_integer_hwtcl||!core4_1_enable_sriov_hwtcl"                 NOVAL                  ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_vf_err_vf_num_s0                                                        "Check User Guide for details"                                }\
        { p3_ss_app_vf_err_func_num_s0             output          3                                           ss_app_vf_err_func_num                           	    p3_ss_app_vf_err_func_num_s0                   		        conduit                 start               "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || (top_topology_integer_hwtcl == 4) || pcie_ss_func_mode_integer_hwtcl > 0||tile_integer >1||core4_1_virtual_rp_ep_mode_integer_hwtcl||!core4_1_enable_sriov_hwtcl"                 NOVAL                  ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_vf_err_func_num_s0                                                       "Check User Guide for details"                                }\
        { p3_ss_app_vf_err_overflow                output          1                                           ss_app_vf_err_overflow                         	        p3_ss_app_vf_err_overflow                   	     	    conduit                 start               "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || (top_topology_integer_hwtcl == 4) || pcie_ss_func_mode_integer_hwtcl > 0||tile_integer >1||core4_1_virtual_rp_ep_mode_integer_hwtcl||!core4_1_enable_sriov_hwtcl"                 NOVAL                  ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_vf_err_overflow                                                         "Check User Guide for details"                                }\
        { p3_ss_app_vfnonfatalmsg_ready            output          1                                           ss_app_vfnonfatalmsg_ready                           	p3_ss_app_vfnonfatalmsg_ready                   		    conduit                 start               "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || (top_topology_integer_hwtcl == 4) || pcie_ss_func_mode_integer_hwtcl > 0||tile_integer >1||core4_1_virtual_rp_ep_mode_integer_hwtcl||!core4_1_enable_sriov_hwtcl"              NOVAL                  ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_vfnonfatalmsg_ready                                                        "Check User Guide for details"                                }\
        { p3_app_ss_sent_vfnonfatalmsg             input           1                                           app_ss_sent_vfnonfatalmsg                                p3_app_ss_sent_vfnonfatalmsg                                conduit                 end                 "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || (top_topology_integer_hwtcl == 4) || pcie_ss_func_mode_integer_hwtcl > 0||tile_integer >1||core4_1_virtual_rp_ep_mode_integer_hwtcl||!core4_1_enable_sriov_hwtcl"                 NOVAL                  ::intel_pcie_ss_axi::interfaces::elaborate_app_ss_sent_vfnonfatalmsg                                                       "Check User Guide for details"                                }\
        { p3_app_ss_vfnonfatalmsg_vf_num           input           11                                          app_ss_vfnonfatalmsg_vf_num                              p3_app_ss_vfnonfatalmsg_vf_num                              conduit                 end                 "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || (top_topology_integer_hwtcl == 4) || pcie_ss_func_mode_integer_hwtcl > 0||tile_integer >1||core4_1_virtual_rp_ep_mode_integer_hwtcl||!core4_1_enable_sriov_hwtcl"                 NOVAL                  ::intel_pcie_ss_axi::interfaces::elaborate_app_ss_vfnonfatalmsg_vf_num                                                         "Check User Guide for details"                                }\
        { p3_app_ss_vfnonfatalmsg_func_num         input           3                                           app_ss_vfnonfatalmsg_func_num                            p3_app_ss_vfnonfatalmsg_func_num                            conduit                 end                 "pciess_topology_integer_hwtcl < 2 || top_topology_integer_hwtcl <2 || (top_topology_integer_hwtcl == 4) || pcie_ss_func_mode_integer_hwtcl > 0||tile_integer >1||core4_1_virtual_rp_ep_mode_integer_hwtcl||!core4_1_enable_sriov_hwtcl"                 NOVAL                  ::intel_pcie_ss_axi::interfaces::elaborate_app_ss_vfnonfatalmsg_func_num                                                        "Check User Guide for details"                                }\
        
    \
	{ p0_ptm_manual_update_i               input           1               ptm_manual_update   p0_ptm                     conduit                          end                 "!core16_func_mode_integer_hwtcl || !core16_virtual_ptm_hwtcl"              0              NOVAL              "Check User Guide for details"      }\
        { p0_ptm_clk_updated_o                 output          1               ptm_clk_updated     p0_ptm                     conduit                          end                 "!core16_func_mode_integer_hwtcl || !core16_virtual_ptm_hwtcl"                                                                                                       0              NOVAL              "Check User Guide for details"      }\
        { p0_ptm_local_clock_o                 output          64              ptm_local_clock     p0_ptm                     conduit                          end                 "!core16_func_mode_integer_hwtcl || !core16_virtual_ptm_hwtcl"                                                                                                       0              NOVAL              "Check User Guide for details"      }\
        { p0_ptm_context_valid_o               output          1               ptm_context_valid   p0_ptm                     conduit                          end                 "!core16_func_mode_integer_hwtcl || !core16_virtual_ptm_hwtcl"                                                                                                       0              NOVAL              "Check User Guide for details"      }\
	{ p1_ptm_manual_update_i               input           1               ptm_manual_update   p1_ptm                     conduit                          end                 "!core8_func_mode_integer_hwtcl || !core8_virtual_ptm_hwtcl"              0              NOVAL              "Check User Guide for details"      }\
        { p1_ptm_clk_updated_o                 output          1               ptm_clk_updated     p1_ptm                     conduit                          end                 "!core8_func_mode_integer_hwtcl || !core8_virtual_ptm_hwtcl"                                                                                                       0              NOVAL              "Check User Guide for details"      }\
        { p1_ptm_local_clock_o                 output          64              ptm_local_clock     p1_ptm                     conduit                          end                 "!core8_func_mode_integer_hwtcl || !core8_virtual_ptm_hwtcl"                                                                                                       0              NOVAL              "Check User Guide for details"      }\
        { p1_ptm_context_valid_o               output          1               ptm_context_valid   p1_ptm                     conduit                          end                 "!core8_func_mode_integer_hwtcl || !core8_virtual_ptm_hwtcl"                                                                                                       0              NOVAL              "Check User Guide for details"      }\
        
    }      
    set ftile_interfaces_pipemode {\
        { NAME                            DIRECTION       WIDTH_EXPR      ROLE            IFACE_NAME      IFACE_TYPE      IFACE_DIRECTION     TERMINATION     			TERMINATION_VALUE       ELABORATION_CALLBACK        DESCRIPTION                         }\
    \
        { i_rxpipe0_dirfeedback          input           6               dirfeedback     i_rxpipe0_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe0_linkevaluationfeedbackfiguremerit  input             8               linkevaluationfeedbackfiguremerit     i_rxpipe0_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe0_localfs              input           6               localfs         i_rxpipe0_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe0_locallf              input           6               locallf         i_rxpipe0_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe0_localtxcoefficientsvalid           input             1               localtxcoefficientsvalid              i_rxpipe0_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe0_localtxpresetcoefficients          input             18              localtxpresetcoefficients             i_rxpipe0_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe0_p2m_bus              input           8               p2m_bus         i_rxpipe0_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe0_pclkchangeok         input           1               pclkchangeok    i_rxpipe0_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe0_phystatus            input           1               phystatus       i_rxpipe0_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe0_rxdata               input           40              rxdata          i_rxpipe0_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe0_rxdatak              input           4               rxdatak         i_rxpipe0_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe0_rxdatavalid          input           1               rxdatavalid     i_rxpipe0_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe0_rxelecidlea          input           1               rxelecidlea     i_rxpipe0_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe0_rxstandbystatus      input           1               rxstandbystatus i_rxpipe0_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe0_rxstartblock         input           1               rxstartblock    i_rxpipe0_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe0_rxstatus             input           3               rxstatus        i_rxpipe0_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe0_rxsyncheader         input           4               rxsyncheader    i_rxpipe0_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe0_rxvalid              input           1               rxvalid         i_rxpipe0_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
    \
        { i_rxpipe1_dirfeedback          input           6               dirfeedback     i_rxpipe1_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe1_linkevaluationfeedbackfiguremerit  input             8               linkevaluationfeedbackfiguremerit     i_rxpipe1_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe1_localfs              input           6               localfs         i_rxpipe1_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe1_locallf              input           6               locallf         i_rxpipe1_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe1_localtxcoefficientsvalid           input             1               localtxcoefficientsvalid              i_rxpipe1_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe1_localtxpresetcoefficients          input             18              localtxpresetcoefficients             i_rxpipe1_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe1_p2m_bus              input           8               p2m_bus         i_rxpipe1_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe1_pclkchangeok         input           1               pclkchangeok    i_rxpipe1_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe1_phystatus            input           1               phystatus       i_rxpipe1_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe1_rxdata               input           40              rxdata          i_rxpipe1_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe1_rxdatak              input           4               rxdatak         i_rxpipe1_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe1_rxdatavalid          input           1               rxdatavalid     i_rxpipe1_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe1_rxelecidlea          input           1               rxelecidlea     i_rxpipe1_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe1_rxstandbystatus      input           1               rxstandbystatus i_rxpipe1_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe1_rxstartblock         input           1               rxstartblock    i_rxpipe1_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe1_rxstatus             input           3               rxstatus        i_rxpipe1_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe1_rxsyncheader         input           4               rxsyncheader    i_rxpipe1_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe1_rxvalid              input           1               rxvalid         i_rxpipe1_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
    \
        { i_rxpipe2_dirfeedback          input           6               dirfeedback     i_rxpipe2_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe2_linkevaluationfeedbackfiguremerit  input             8               linkevaluationfeedbackfiguremerit     i_rxpipe2_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe2_localfs              input           6               localfs         i_rxpipe2_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe2_locallf              input           6               locallf         i_rxpipe2_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe2_localtxcoefficientsvalid           input             1               localtxcoefficientsvalid              i_rxpipe2_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe2_localtxpresetcoefficients          input             18              localtxpresetcoefficients             i_rxpipe2_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe2_p2m_bus              input           8               p2m_bus         i_rxpipe2_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe2_pclkchangeok         input           1               pclkchangeok    i_rxpipe2_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe2_phystatus            input           1               phystatus       i_rxpipe2_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe2_rxdata               input           40              rxdata          i_rxpipe2_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe2_rxdatak              input           4               rxdatak         i_rxpipe2_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe2_rxdatavalid          input           1               rxdatavalid     i_rxpipe2_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe2_rxelecidlea          input           1               rxelecidlea     i_rxpipe2_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe2_rxstandbystatus      input           1               rxstandbystatus i_rxpipe2_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe2_rxstartblock         input           1               rxstartblock    i_rxpipe2_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe2_rxstatus             input           3               rxstatus        i_rxpipe2_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe2_rxsyncheader         input           4               rxsyncheader    i_rxpipe2_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe2_rxvalid              input           1               rxvalid         i_rxpipe2_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
    \
        { i_rxpipe3_dirfeedback          input           6               dirfeedback     i_rxpipe3_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe3_linkevaluationfeedbackfiguremerit  input             8               linkevaluationfeedbackfiguremerit     i_rxpipe3_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe3_localfs              input           6               localfs         i_rxpipe3_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe3_locallf              input           6               locallf         i_rxpipe3_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe3_localtxcoefficientsvalid           input             1               localtxcoefficientsvalid              i_rxpipe3_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe3_localtxpresetcoefficients          input             18              localtxpresetcoefficients             i_rxpipe3_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe3_p2m_bus              input           8               p2m_bus         i_rxpipe3_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe3_pclkchangeok         input           1               pclkchangeok    i_rxpipe3_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe3_phystatus            input           1               phystatus       i_rxpipe3_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe3_rxdata               input           40              rxdata          i_rxpipe3_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe3_rxdatak              input           4               rxdatak         i_rxpipe3_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe3_rxdatavalid          input           1               rxdatavalid     i_rxpipe3_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe3_rxelecidlea          input           1               rxelecidlea     i_rxpipe3_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe3_rxstandbystatus      input           1               rxstandbystatus i_rxpipe3_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe3_rxstartblock         input           1               rxstartblock    i_rxpipe3_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe3_rxstatus             input           3               rxstatus        i_rxpipe3_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe3_rxsyncheader         input           4               rxsyncheader    i_rxpipe3_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe3_rxvalid              input           1               rxvalid         i_rxpipe3_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
    \
        { i_rxpipe4_dirfeedback          input           6               dirfeedback     i_rxpipe4_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe4_linkevaluationfeedbackfiguremerit  input             8               linkevaluationfeedbackfiguremerit     i_rxpipe4_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe4_localfs              input           6               localfs         i_rxpipe4_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe4_locallf              input           6               locallf         i_rxpipe4_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe4_localtxcoefficientsvalid           input             1               localtxcoefficientsvalid              i_rxpipe4_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe4_localtxpresetcoefficients          input             18              localtxpresetcoefficients             i_rxpipe4_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe4_p2m_bus              input           8               p2m_bus         i_rxpipe4_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe4_pclkchangeok         input           1               pclkchangeok    i_rxpipe4_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe4_phystatus            input           1               phystatus       i_rxpipe4_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe4_rxdata               input           40              rxdata          i_rxpipe4_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe4_rxdatak              input           4               rxdatak         i_rxpipe4_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe4_rxdatavalid          input           1               rxdatavalid     i_rxpipe4_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe4_rxelecidlea          input           1               rxelecidlea     i_rxpipe4_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe4_rxstandbystatus      input           1               rxstandbystatus i_rxpipe4_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe4_rxstartblock         input           1               rxstartblock    i_rxpipe4_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe4_rxstatus             input           3               rxstatus        i_rxpipe4_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe4_rxsyncheader         input           4               rxsyncheader    i_rxpipe4_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe4_rxvalid              input           1               rxvalid         i_rxpipe4_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
    \
        { i_rxpipe5_dirfeedback          input           6               dirfeedback     i_rxpipe5_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe5_linkevaluationfeedbackfiguremerit  input             8               linkevaluationfeedbackfiguremerit     i_rxpipe5_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe5_localfs              input           6               localfs         i_rxpipe5_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe5_locallf              input           6               locallf         i_rxpipe5_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe5_localtxcoefficientsvalid           input             1               localtxcoefficientsvalid              i_rxpipe5_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe5_localtxpresetcoefficients          input             18              localtxpresetcoefficients             i_rxpipe5_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe5_p2m_bus              input           8               p2m_bus         i_rxpipe5_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe5_pclkchangeok         input           1               pclkchangeok    i_rxpipe5_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe5_phystatus            input           1               phystatus       i_rxpipe5_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe5_rxdata               input           40              rxdata          i_rxpipe5_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe5_rxdatak              input           4               rxdatak         i_rxpipe5_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe5_rxdatavalid          input           1               rxdatavalid     i_rxpipe5_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe5_rxelecidlea          input           1               rxelecidlea     i_rxpipe5_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe5_rxstandbystatus      input           1               rxstandbystatus i_rxpipe5_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe5_rxstartblock         input           1               rxstartblock    i_rxpipe5_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe5_rxstatus             input           3               rxstatus        i_rxpipe5_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe5_rxsyncheader         input           4               rxsyncheader    i_rxpipe5_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe5_rxvalid              input           1               rxvalid         i_rxpipe5_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
    \
        { i_rxpipe6_dirfeedback          input           6               dirfeedback     i_rxpipe6_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe6_linkevaluationfeedbackfiguremerit  input             8               linkevaluationfeedbackfiguremerit     i_rxpipe6_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe6_localfs              input           6               localfs         i_rxpipe6_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe6_locallf              input           6               locallf         i_rxpipe6_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe6_localtxcoefficientsvalid           input             1               localtxcoefficientsvalid              i_rxpipe6_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe6_localtxpresetcoefficients          input             18              localtxpresetcoefficients             i_rxpipe6_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe6_p2m_bus              input           8               p2m_bus         i_rxpipe6_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe6_pclkchangeok         input           1               pclkchangeok    i_rxpipe6_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe6_phystatus            input           1               phystatus       i_rxpipe6_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe6_rxdata               input           40              rxdata          i_rxpipe6_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe6_rxdatak              input           4               rxdatak         i_rxpipe6_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe6_rxdatavalid          input           1               rxdatavalid     i_rxpipe6_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe6_rxelecidlea          input           1               rxelecidlea     i_rxpipe6_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe6_rxstandbystatus      input           1               rxstandbystatus i_rxpipe6_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe6_rxstartblock         input           1               rxstartblock    i_rxpipe6_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe6_rxstatus             input           3               rxstatus        i_rxpipe6_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe6_rxsyncheader         input           4               rxsyncheader    i_rxpipe6_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe6_rxvalid              input           1               rxvalid         i_rxpipe6_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
    \
        { i_rxpipe7_dirfeedback          input           6               dirfeedback     i_rxpipe7_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe7_linkevaluationfeedbackfiguremerit  input             8               linkevaluationfeedbackfiguremerit     i_rxpipe7_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe7_localfs              input           6               localfs         i_rxpipe7_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe7_locallf              input           6               locallf         i_rxpipe7_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe7_localtxcoefficientsvalid           input             1               localtxcoefficientsvalid              i_rxpipe7_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe7_localtxpresetcoefficients          input             18              localtxpresetcoefficients             i_rxpipe7_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe7_p2m_bus              input           8               p2m_bus         i_rxpipe7_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe7_pclkchangeok         input           1               pclkchangeok    i_rxpipe7_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe7_phystatus            input           1               phystatus       i_rxpipe7_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe7_rxdata               input           40              rxdata          i_rxpipe7_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe7_rxdatak              input           4               rxdatak         i_rxpipe7_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe7_rxdatavalid          input           1               rxdatavalid     i_rxpipe7_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe7_rxelecidlea          input           1               rxelecidlea     i_rxpipe7_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe7_rxstandbystatus      input           1               rxstandbystatus i_rxpipe7_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe7_rxstartblock         input           1               rxstartblock    i_rxpipe7_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe7_rxstatus             input           3               rxstatus        i_rxpipe7_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe7_rxsyncheader         input           4               rxsyncheader    i_rxpipe7_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe7_rxvalid              input           1               rxvalid         i_rxpipe7_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
    \
        { i_rxpipe8_dirfeedback          input           6               dirfeedback     i_rxpipe8_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe8_linkevaluationfeedbackfiguremerit  input             8               linkevaluationfeedbackfiguremerit     i_rxpipe8_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe8_localfs              input           6               localfs         i_rxpipe8_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe8_locallf              input           6               locallf         i_rxpipe8_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe8_localtxcoefficientsvalid           input             1               localtxcoefficientsvalid              i_rxpipe8_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe8_localtxpresetcoefficients          input             18              localtxpresetcoefficients             i_rxpipe8_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe8_p2m_bus              input           8               p2m_bus         i_rxpipe8_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe8_pclkchangeok         input           1               pclkchangeok    i_rxpipe8_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe8_phystatus            input           1               phystatus       i_rxpipe8_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe8_rxdata               input           40              rxdata          i_rxpipe8_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe8_rxdatak              input           4               rxdatak         i_rxpipe8_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe8_rxdatavalid          input           1               rxdatavalid     i_rxpipe8_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe8_rxelecidlea          input           1               rxelecidlea     i_rxpipe8_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe8_rxstandbystatus      input           1               rxstandbystatus i_rxpipe8_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe8_rxstartblock         input           1               rxstartblock    i_rxpipe8_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe8_rxstatus             input           3               rxstatus        i_rxpipe8_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe8_rxsyncheader         input           4               rxsyncheader    i_rxpipe8_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe8_rxvalid              input           1               rxvalid         i_rxpipe8_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
    \
        { i_rxpipe9_dirfeedback          input           6               dirfeedback     i_rxpipe9_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe9_linkevaluationfeedbackfiguremerit  input             8               linkevaluationfeedbackfiguremerit     i_rxpipe9_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe9_localfs              input           6               localfs         i_rxpipe9_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe9_locallf              input           6               locallf         i_rxpipe9_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe9_localtxcoefficientsvalid           input             1               localtxcoefficientsvalid              i_rxpipe9_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe9_localtxpresetcoefficients          input             18              localtxpresetcoefficients             i_rxpipe9_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe9_p2m_bus              input           8               p2m_bus         i_rxpipe9_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe9_pclkchangeok         input           1               pclkchangeok    i_rxpipe9_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe9_phystatus            input           1               phystatus       i_rxpipe9_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe9_rxdata               input           40              rxdata          i_rxpipe9_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe9_rxdatak              input           4               rxdatak         i_rxpipe9_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe9_rxdatavalid          input           1               rxdatavalid     i_rxpipe9_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe9_rxelecidlea          input           1               rxelecidlea     i_rxpipe9_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe9_rxstandbystatus      input           1               rxstandbystatus i_rxpipe9_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe9_rxstartblock         input           1               rxstartblock    i_rxpipe9_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe9_rxstatus             input           3               rxstatus        i_rxpipe9_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe9_rxsyncheader         input           4               rxsyncheader    i_rxpipe9_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe9_rxvalid              input           1               rxvalid         i_rxpipe9_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
    \
        { i_rxpipe10_dirfeedback          input           6               dirfeedback     i_rxpipe10_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe10_linkevaluationfeedbackfiguremerit  input             8               linkevaluationfeedbackfiguremerit     i_rxpipe10_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe10_localfs              input           6               localfs         i_rxpipe10_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe10_locallf              input           6               locallf         i_rxpipe10_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe10_localtxcoefficientsvalid           input             1               localtxcoefficientsvalid              i_rxpipe10_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe10_localtxpresetcoefficients          input             18              localtxpresetcoefficients             i_rxpipe10_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe10_p2m_bus              input           8               p2m_bus         i_rxpipe10_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe10_pclkchangeok         input           1               pclkchangeok    i_rxpipe10_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe10_phystatus            input           1               phystatus       i_rxpipe10_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe10_rxdata               input           40              rxdata          i_rxpipe10_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe10_rxdatak              input           4               rxdatak         i_rxpipe10_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe10_rxdatavalid          input           1               rxdatavalid     i_rxpipe10_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe10_rxelecidlea          input           1               rxelecidlea     i_rxpipe10_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe10_rxstandbystatus      input           1               rxstandbystatus i_rxpipe10_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe10_rxstartblock         input           1               rxstartblock    i_rxpipe10_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe10_rxstatus             input           3               rxstatus        i_rxpipe10_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe10_rxsyncheader         input           4               rxsyncheader    i_rxpipe10_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe10_rxvalid              input           1               rxvalid         i_rxpipe10_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
    \
        { i_rxpipe11_dirfeedback          input           6               dirfeedback     i_rxpipe11_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe11_linkevaluationfeedbackfiguremerit  input             8               linkevaluationfeedbackfiguremerit     i_rxpipe11_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe11_localfs              input           6               localfs         i_rxpipe11_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe11_locallf              input           6               locallf         i_rxpipe11_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe11_localtxcoefficientsvalid           input             1               localtxcoefficientsvalid              i_rxpipe11_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe11_localtxpresetcoefficients          input             18              localtxpresetcoefficients             i_rxpipe11_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe11_p2m_bus              input           8               p2m_bus         i_rxpipe11_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe11_pclkchangeok         input           1               pclkchangeok    i_rxpipe11_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe11_phystatus            input           1               phystatus       i_rxpipe11_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe11_rxdata               input           40              rxdata          i_rxpipe11_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe11_rxdatak              input           4               rxdatak         i_rxpipe11_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe11_rxdatavalid          input           1               rxdatavalid     i_rxpipe11_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe11_rxelecidlea          input           1               rxelecidlea     i_rxpipe11_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe11_rxstandbystatus      input           1               rxstandbystatus i_rxpipe11_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe11_rxstartblock         input           1               rxstartblock    i_rxpipe11_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe11_rxstatus             input           3               rxstatus        i_rxpipe11_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe11_rxsyncheader         input           4               rxsyncheader    i_rxpipe11_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe11_rxvalid              input           1               rxvalid         i_rxpipe11_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
    \
        { i_rxpipe12_dirfeedback          input           6               dirfeedback     i_rxpipe12_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe12_linkevaluationfeedbackfiguremerit  input             8               linkevaluationfeedbackfiguremerit     i_rxpipe12_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe12_localfs              input           6               localfs         i_rxpipe12_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe12_locallf              input           6               locallf         i_rxpipe12_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe12_localtxcoefficientsvalid           input             1               localtxcoefficientsvalid              i_rxpipe12_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe12_localtxpresetcoefficients          input             18              localtxpresetcoefficients             i_rxpipe12_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe12_p2m_bus              input           8               p2m_bus         i_rxpipe12_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe12_pclkchangeok         input           1               pclkchangeok    i_rxpipe12_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe12_phystatus            input           1               phystatus       i_rxpipe12_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe12_rxdata               input           40              rxdata          i_rxpipe12_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe12_rxdatak              input           4               rxdatak         i_rxpipe12_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe12_rxdatavalid          input           1               rxdatavalid     i_rxpipe12_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe12_rxelecidlea          input           1               rxelecidlea     i_rxpipe12_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe12_rxstandbystatus      input           1               rxstandbystatus i_rxpipe12_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe12_rxstartblock         input           1               rxstartblock    i_rxpipe12_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe12_rxstatus             input           3               rxstatus        i_rxpipe12_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe12_rxsyncheader         input           4               rxsyncheader    i_rxpipe12_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe12_rxvalid              input           1               rxvalid         i_rxpipe12_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
    \
        { i_rxpipe13_dirfeedback          input           6               dirfeedback     i_rxpipe13_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe13_linkevaluationfeedbackfiguremerit  input             8               linkevaluationfeedbackfiguremerit     i_rxpipe13_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe13_localfs              input           6               localfs         i_rxpipe13_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe13_locallf              input           6               locallf         i_rxpipe13_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe13_localtxcoefficientsvalid           input             1               localtxcoefficientsvalid              i_rxpipe13_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe13_localtxpresetcoefficients          input             18              localtxpresetcoefficients             i_rxpipe13_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe13_p2m_bus              input           8               p2m_bus         i_rxpipe13_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe13_pclkchangeok         input           1               pclkchangeok    i_rxpipe13_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe13_phystatus            input           1               phystatus       i_rxpipe13_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe13_rxdata               input           40              rxdata          i_rxpipe13_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe13_rxdatak              input           4               rxdatak         i_rxpipe13_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe13_rxdatavalid          input           1               rxdatavalid     i_rxpipe13_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe13_rxelecidlea          input           1               rxelecidlea     i_rxpipe13_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe13_rxstandbystatus      input           1               rxstandbystatus i_rxpipe13_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe13_rxstartblock         input           1               rxstartblock    i_rxpipe13_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe13_rxstatus             input           3               rxstatus        i_rxpipe13_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe13_rxsyncheader         input           4               rxsyncheader    i_rxpipe13_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe13_rxvalid              input           1               rxvalid         i_rxpipe13_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
    \
        { i_rxpipe14_dirfeedback          input           6               dirfeedback     i_rxpipe14_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe14_linkevaluationfeedbackfiguremerit  input             8               linkevaluationfeedbackfiguremerit     i_rxpipe14_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe14_localfs              input           6               localfs         i_rxpipe14_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe14_locallf              input           6               locallf         i_rxpipe14_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe14_localtxcoefficientsvalid           input             1               localtxcoefficientsvalid              i_rxpipe14_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe14_localtxpresetcoefficients          input             18              localtxpresetcoefficients             i_rxpipe14_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe14_p2m_bus              input           8               p2m_bus         i_rxpipe14_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe14_pclkchangeok         input           1               pclkchangeok    i_rxpipe14_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe14_phystatus            input           1               phystatus       i_rxpipe14_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe14_rxdata               input           40              rxdata          i_rxpipe14_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe14_rxdatak              input           4               rxdatak         i_rxpipe14_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe14_rxdatavalid          input           1               rxdatavalid     i_rxpipe14_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe14_rxelecidlea          input           1               rxelecidlea     i_rxpipe14_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe14_rxstandbystatus      input           1               rxstandbystatus i_rxpipe14_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe14_rxstartblock         input           1               rxstartblock    i_rxpipe14_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe14_rxstatus             input           3               rxstatus        i_rxpipe14_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe14_rxsyncheader         input           4               rxsyncheader    i_rxpipe14_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe14_rxvalid              input           1               rxvalid         i_rxpipe14_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
    \
        { i_rxpipe15_dirfeedback          input           6               dirfeedback     i_rxpipe15_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe15_linkevaluationfeedbackfiguremerit  input             8               linkevaluationfeedbackfiguremerit     i_rxpipe15_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe15_localfs              input           6               localfs         i_rxpipe15_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe15_locallf              input           6               locallf         i_rxpipe15_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe15_localtxcoefficientsvalid           input             1               localtxcoefficientsvalid              i_rxpipe15_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe15_localtxpresetcoefficients          input             18              localtxpresetcoefficients             i_rxpipe15_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe15_p2m_bus              input           8               p2m_bus         i_rxpipe15_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe15_pclkchangeok         input           1               pclkchangeok    i_rxpipe15_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe15_phystatus            input           1               phystatus       i_rxpipe15_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe15_rxdata               input           40              rxdata          i_rxpipe15_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe15_rxdatak              input           4               rxdatak         i_rxpipe15_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe15_rxdatavalid          input           1               rxdatavalid     i_rxpipe15_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe15_rxelecidlea          input           1               rxelecidlea     i_rxpipe15_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe15_rxstandbystatus      input           1               rxstandbystatus i_rxpipe15_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe15_rxstartblock         input           1               rxstartblock    i_rxpipe15_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe15_rxstatus             input           3               rxstatus        i_rxpipe15_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe15_rxsyncheader         input           4               rxsyncheader    i_rxpipe15_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
        { i_rxpipe15_rxvalid              input           1               rxvalid         i_rxpipe15_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      0                   NOVAL                       "Check User Guide for details"      }\
    \
        { o_txpipe0_asyncpowerchangeack          output           1               asyncpowerchangeack     o_txpipe0_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe0_blockaligncontrol            output           1               blockaligncontrol       o_txpipe0_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe0_cfg_hw_auto_sp_dis           output           1               cfg_hw_auto_sp_dis      o_txpipe0_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe0_dirchange                    output           1               dirchange               o_txpipe0_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe0_ebuf_mode                    output           1               ebuf_mode               o_txpipe0_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe0_encodedecodebypass           output           1               encodedecodebypass      o_txpipe0_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe0_fs                           output           6               fs                      o_txpipe0_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe0_getlocalpresetcoefficients   output           1        getlocalpresetcoefficients     o_txpipe0_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe0_invalidrequest               output           1               invalidrequest          o_txpipe0_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe0_lf                           output           6               lf                      o_txpipe0_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe0_localpresetindex             output           5               localpresetindex        o_txpipe0_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe0_m2p_bus                      output           8               m2p_bus                 o_txpipe0_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe0_pclk_rate                    output           3               pclk_rate               o_txpipe0_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe0_pclkchangeack                output           1               pclkchangeack           o_txpipe0_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe0_powerdown                    output           4               powerdown               o_txpipe0_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe0_rate                         output           3               rate                    o_txpipe0_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe0_rxelecidle_disable_a         output           1               rxelecidle_disable_a    o_txpipe0_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe0_rxeqeval                     output           1               rxeqeval                o_txpipe0_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe0_rxeqinprogress               output           1               rxeqinprogress          o_txpipe0_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe0_rxeqtraining                 output           1               rxeqtraining            o_txpipe0_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe0_rxpolarity                   output           1               rxpolarity              o_txpipe0_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe0_rxpresethint                 output           3               rxpresethint            o_txpipe0_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe0_rxstandby                    output           1               rxstandby               o_txpipe0_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe0_rxtermination                output           1               rxtermination           o_txpipe0_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe0_srisenable                   output           1               srisenable              o_txpipe0_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe0_txcmnmode_disable_a          output           1               txcmnmode_disable_a     o_txpipe0_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe0_txcompliance                 output           1               txcompliance            o_txpipe0_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe0_txdata                       output           40              txdata                  o_txpipe0_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe0_txdatak                      output           4               txdatak                 o_txpipe0_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe0_txdatavalid                  output           1               txdatavalid             o_txpipe0_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe0_txdeemph                     output           18              txdeemph                o_txpipe0_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe0_txdtctrx_lb                  output           1               txdtctrx_lb             o_txpipe0_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe0_txelecidle                   output           1               txelecidle              o_txpipe0_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe0_txmargin                     output           3               txmargin                o_txpipe0_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe0_txoneszeros                  output           1               txoneszeros             o_txpipe0_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe0_txstartblock                 output           1               txstartblock            o_txpipe0_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe0_txswing                      output           1               txswing                 o_txpipe0_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe0_txsyncheader                 output           4               txsyncheader            o_txpipe0_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe0_width                        output           3               width                   o_txpipe0_        conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
    \
        { o_txpipe1_asyncpowerchangeack          output           1               asyncpowerchangeack     o_txpipe1_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe1_blockaligncontrol            output           1               blockaligncontrol       o_txpipe1_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe1_cfg_hw_auto_sp_dis           output           1               cfg_hw_auto_sp_dis      o_txpipe1_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe1_dirchange                    output           1               dirchange               o_txpipe1_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe1_ebuf_mode                    output           1               ebuf_mode               o_txpipe1_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe1_encodedecodebypass           output           1               encodedecodebypass      o_txpipe1_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe1_fs                           output           6               fs                      o_txpipe1_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe1_getlocalpresetcoefficients   output           1        getlocalpresetcoefficients     o_txpipe1_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe1_invalidrequest               output           1               invalidrequest          o_txpipe1_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe1_lf                           output           6               lf                      o_txpipe1_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe1_localpresetindex             output           5               localpresetindex        o_txpipe1_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe1_m2p_bus                      output           8               m2p_bus                 o_txpipe1_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe1_pclk_rate                    output           3               pclk_rate               o_txpipe1_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe1_pclkchangeack                output           1               pclkchangeack           o_txpipe1_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe1_powerdown                    output           4               powerdown               o_txpipe1_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe1_rate                         output           3               rate                    o_txpipe1_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe1_rxelecidle_disable_a         output           1               rxelecidle_disable_a    o_txpipe1_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe1_rxeqeval                     output           1               rxeqeval                o_txpipe1_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe1_rxeqinprogress               output           1               rxeqinprogress          o_txpipe1_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe1_rxeqtraining                 output           1               rxeqtraining            o_txpipe1_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe1_rxpolarity                   output           1               rxpolarity              o_txpipe1_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe1_rxpresethint                 output           3               rxpresethint            o_txpipe1_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe1_rxstandby                    output           1               rxstandby               o_txpipe1_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe1_rxtermination                output           1               rxtermination           o_txpipe1_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe1_srisenable                   output           1               srisenable              o_txpipe1_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe1_txcmnmode_disable_a          output           1               txcmnmode_disable_a     o_txpipe1_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe1_txcompliance                 output           1               txcompliance            o_txpipe1_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe1_txdata                       output           40              txdata                  o_txpipe1_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe1_txdatak                      output           4               txdatak                 o_txpipe1_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe1_txdatavalid                  output           1               txdatavalid             o_txpipe1_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe1_txdeemph                     output           18              txdeemph                o_txpipe1_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe1_txdtctrx_lb                  output           1               txdtctrx_lb             o_txpipe1_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe1_txelecidle                   output           1               txelecidle              o_txpipe1_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe1_txmargin                     output           3               txmargin                o_txpipe1_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe1_txoneszeros                  output           1               txoneszeros             o_txpipe1_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe1_txstartblock                 output           1               txstartblock            o_txpipe1_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe1_txswing                      output           1               txswing                 o_txpipe1_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe1_txsyncheader                 output           4               txsyncheader            o_txpipe1_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe1_width                        output           3               width                   o_txpipe1_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
    \
        { o_txpipe2_asyncpowerchangeack          output           1               asyncpowerchangeack     o_txpipe2_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe2_blockaligncontrol            output           1               blockaligncontrol       o_txpipe2_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe2_cfg_hw_auto_sp_dis           output           1               cfg_hw_auto_sp_dis      o_txpipe2_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe2_dirchange                    output           1               dirchange               o_txpipe2_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe2_ebuf_mode                    output           1               ebuf_mode               o_txpipe2_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe2_encodedecodebypass           output           1               encodedecodebypass      o_txpipe2_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe2_fs                           output           6               fs                      o_txpipe2_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe2_getlocalpresetcoefficients   output           1        getlocalpresetcoefficients     o_txpipe2_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe2_invalidrequest               output           1               invalidrequest          o_txpipe2_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe2_lf                           output           6               lf                      o_txpipe2_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe2_localpresetindex             output           5               localpresetindex        o_txpipe2_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe2_m2p_bus                      output           8               m2p_bus                 o_txpipe2_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe2_pclk_rate                    output           3               pclk_rate               o_txpipe2_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe2_pclkchangeack                output           1               pclkchangeack           o_txpipe2_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe2_powerdown                    output           4               powerdown               o_txpipe2_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe2_rate                         output           3               rate                    o_txpipe2_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe2_rxelecidle_disable_a         output           1               rxelecidle_disable_a    o_txpipe2_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe2_rxeqeval                     output           1               rxeqeval                o_txpipe2_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe2_rxeqinprogress               output           1               rxeqinprogress          o_txpipe2_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe2_rxeqtraining                 output           1               rxeqtraining            o_txpipe2_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe2_rxpolarity                   output           1               rxpolarity              o_txpipe2_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe2_rxpresethint                 output           3               rxpresethint            o_txpipe2_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe2_rxstandby                    output           1               rxstandby               o_txpipe2_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe2_rxtermination                output           1               rxtermination           o_txpipe2_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe2_srisenable                   output           1               srisenable              o_txpipe2_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe2_txcmnmode_disable_a          output           1               txcmnmode_disable_a     o_txpipe2_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe2_txcompliance                 output           1               txcompliance            o_txpipe2_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe2_txdata                       output           40              txdata                  o_txpipe2_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe2_txdatak                      output           4               txdatak                 o_txpipe2_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe2_txdatavalid                  output           1               txdatavalid             o_txpipe2_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe2_txdeemph                     output           18              txdeemph                o_txpipe2_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe2_txdtctrx_lb                  output           1               txdtctrx_lb             o_txpipe2_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe2_txelecidle                   output           1               txelecidle              o_txpipe2_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe2_txmargin                     output           3               txmargin                o_txpipe2_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe2_txoneszeros                  output           1               txoneszeros             o_txpipe2_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe2_txstartblock                 output           1               txstartblock            o_txpipe2_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe2_txswing                      output           1               txswing                 o_txpipe2_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe2_txsyncheader                 output           4               txsyncheader            o_txpipe2_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe2_width                        output           3               width                   o_txpipe2_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
    \
        { o_txpipe3_asyncpowerchangeack          output           1               asyncpowerchangeack     o_txpipe3_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe3_blockaligncontrol            output           1               blockaligncontrol       o_txpipe3_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe3_cfg_hw_auto_sp_dis           output           1               cfg_hw_auto_sp_dis      o_txpipe3_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe3_dirchange                    output           1               dirchange               o_txpipe3_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe3_ebuf_mode                    output           1               ebuf_mode               o_txpipe3_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe3_encodedecodebypass           output           1               encodedecodebypass      o_txpipe3_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe3_fs                           output           6               fs                      o_txpipe3_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe3_getlocalpresetcoefficients   output           1        getlocalpresetcoefficients     o_txpipe3_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe3_invalidrequest               output           1               invalidrequest          o_txpipe3_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe3_lf                           output           6               lf                      o_txpipe3_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe3_localpresetindex             output           5               localpresetindex        o_txpipe3_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe3_m2p_bus                      output           8               m2p_bus                 o_txpipe3_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe3_pclk_rate                    output           3               pclk_rate               o_txpipe3_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe3_pclkchangeack                output           1               pclkchangeack           o_txpipe3_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe3_powerdown                    output           4               powerdown               o_txpipe3_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe3_rate                         output           3               rate                    o_txpipe3_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe3_rxelecidle_disable_a         output           1               rxelecidle_disable_a    o_txpipe3_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe3_rxeqeval                     output           1               rxeqeval                o_txpipe3_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe3_rxeqinprogress               output           1               rxeqinprogress          o_txpipe3_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe3_rxeqtraining                 output           1               rxeqtraining            o_txpipe3_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe3_rxpolarity                   output           1               rxpolarity              o_txpipe3_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe3_rxpresethint                 output           3               rxpresethint            o_txpipe3_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe3_rxstandby                    output           1               rxstandby               o_txpipe3_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe3_rxtermination                output           1               rxtermination           o_txpipe3_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe3_srisenable                   output           1               srisenable              o_txpipe3_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe3_txcmnmode_disable_a          output           1               txcmnmode_disable_a     o_txpipe3_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe3_txcompliance                 output           1               txcompliance            o_txpipe3_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe3_txdata                       output           40              txdata                  o_txpipe3_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe3_txdatak                      output           4               txdatak                 o_txpipe3_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe3_txdatavalid                  output           1               txdatavalid             o_txpipe3_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe3_txdeemph                     output           18              txdeemph                o_txpipe3_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe3_txdtctrx_lb                  output           1               txdtctrx_lb             o_txpipe3_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe3_txelecidle                   output           1               txelecidle              o_txpipe3_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe3_txmargin                     output           3               txmargin                o_txpipe3_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe3_txoneszeros                  output           1               txoneszeros             o_txpipe3_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe3_txstartblock                 output           1               txstartblock            o_txpipe3_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe3_txswing                      output           1               txswing                 o_txpipe3_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe3_txsyncheader                 output           4               txsyncheader            o_txpipe3_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe3_width                        output           3               width                   o_txpipe3_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
    \
        { o_txpipe4_asyncpowerchangeack          output           1               asyncpowerchangeack     o_txpipe4_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe4_blockaligncontrol            output           1               blockaligncontrol       o_txpipe4_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe4_cfg_hw_auto_sp_dis           output           1               cfg_hw_auto_sp_dis      o_txpipe4_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe4_dirchange                    output           1               dirchange               o_txpipe4_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe4_ebuf_mode                    output           1               ebuf_mode               o_txpipe4_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe4_encodedecodebypass           output           1               encodedecodebypass      o_txpipe4_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe4_fs                           output           6               fs                      o_txpipe4_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe4_getlocalpresetcoefficients   output           1        getlocalpresetcoefficients     o_txpipe4_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe4_invalidrequest               output           1               invalidrequest          o_txpipe4_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe4_lf                           output           6               lf                      o_txpipe4_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe4_localpresetindex             output           5               localpresetindex        o_txpipe4_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe4_m2p_bus                      output           8               m2p_bus                 o_txpipe4_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe4_pclk_rate                    output           3               pclk_rate               o_txpipe4_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe4_pclkchangeack                output           1               pclkchangeack           o_txpipe4_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe4_powerdown                    output           4               powerdown               o_txpipe4_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe4_rate                         output           3               rate                    o_txpipe4_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe4_rxelecidle_disable_a         output           1               rxelecidle_disable_a    o_txpipe4_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe4_rxeqeval                     output           1               rxeqeval                o_txpipe4_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe4_rxeqinprogress               output           1               rxeqinprogress          o_txpipe4_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe4_rxeqtraining                 output           1               rxeqtraining            o_txpipe4_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe4_rxpolarity                   output           1               rxpolarity              o_txpipe4_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe4_rxpresethint                 output           3               rxpresethint            o_txpipe4_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe4_rxstandby                    output           1               rxstandby               o_txpipe4_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe4_rxtermination                output           1               rxtermination           o_txpipe4_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe4_srisenable                   output           1               srisenable              o_txpipe4_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe4_txcmnmode_disable_a          output           1               txcmnmode_disable_a     o_txpipe4_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe4_txcompliance                 output           1               txcompliance            o_txpipe4_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe4_txdata                       output           40              txdata                  o_txpipe4_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe4_txdatak                      output           4               txdatak                 o_txpipe4_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe4_txdatavalid                  output           1               txdatavalid             o_txpipe4_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe4_txdeemph                     output           18              txdeemph                o_txpipe4_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe4_txdtctrx_lb                  output           1               txdtctrx_lb             o_txpipe4_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe4_txelecidle                   output           1               txelecidle              o_txpipe4_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe4_txmargin                     output           3               txmargin                o_txpipe4_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe4_txoneszeros                  output           1               txoneszeros             o_txpipe4_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe4_txstartblock                 output           1               txstartblock            o_txpipe4_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe4_txswing                      output           1               txswing                 o_txpipe4_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe4_txsyncheader                 output           4               txsyncheader            o_txpipe4_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe4_width                        output           3               width                   o_txpipe4_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
    \
        { o_txpipe5_asyncpowerchangeack          output           1               asyncpowerchangeack     o_txpipe5_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe5_blockaligncontrol            output           1               blockaligncontrol       o_txpipe5_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe5_cfg_hw_auto_sp_dis           output           1               cfg_hw_auto_sp_dis      o_txpipe5_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe5_dirchange                    output           1               dirchange               o_txpipe5_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe5_ebuf_mode                    output           1               ebuf_mode               o_txpipe5_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe5_encodedecodebypass           output           1               encodedecodebypass      o_txpipe5_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe5_fs                           output           6               fs                      o_txpipe5_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe5_getlocalpresetcoefficients   output           1        getlocalpresetcoefficients     o_txpipe5_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe5_invalidrequest               output           1               invalidrequest          o_txpipe5_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe5_lf                           output           6               lf                      o_txpipe5_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe5_localpresetindex             output           5               localpresetindex        o_txpipe5_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe5_m2p_bus                      output           8               m2p_bus                 o_txpipe5_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe5_pclk_rate                    output           3               pclk_rate               o_txpipe5_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe5_pclkchangeack                output           1               pclkchangeack           o_txpipe5_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe5_powerdown                    output           4               powerdown               o_txpipe5_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe5_rate                         output           3               rate                    o_txpipe5_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe5_rxelecidle_disable_a         output           1               rxelecidle_disable_a    o_txpipe5_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe5_rxeqeval                     output           1               rxeqeval                o_txpipe5_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe5_rxeqinprogress               output           1               rxeqinprogress          o_txpipe5_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe5_rxeqtraining                 output           1               rxeqtraining            o_txpipe5_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe5_rxpolarity                   output           1               rxpolarity              o_txpipe5_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe5_rxpresethint                 output           3               rxpresethint            o_txpipe5_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe5_rxstandby                    output           1               rxstandby               o_txpipe5_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe5_rxtermination                output           1               rxtermination           o_txpipe5_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe5_srisenable                   output           1               srisenable              o_txpipe5_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe5_txcmnmode_disable_a          output           1               txcmnmode_disable_a     o_txpipe5_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe5_txcompliance                 output           1               txcompliance            o_txpipe5_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe5_txdata                       output           40              txdata                  o_txpipe5_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe5_txdatak                      output           4               txdatak                 o_txpipe5_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe5_txdatavalid                  output           1               txdatavalid             o_txpipe5_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe5_txdeemph                     output           18              txdeemph                o_txpipe5_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe5_txdtctrx_lb                  output           1               txdtctrx_lb             o_txpipe5_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe5_txelecidle                   output           1               txelecidle              o_txpipe5_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe5_txmargin                     output           3               txmargin                o_txpipe5_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe5_txoneszeros                  output           1               txoneszeros             o_txpipe5_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe5_txstartblock                 output           1               txstartblock            o_txpipe5_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe5_txswing                      output           1               txswing                 o_txpipe5_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe5_txsyncheader                 output           4               txsyncheader            o_txpipe5_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe5_width                        output           3               width                   o_txpipe5_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
    \
        { o_txpipe6_asyncpowerchangeack          output           1               asyncpowerchangeack     o_txpipe6_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe6_blockaligncontrol            output           1               blockaligncontrol       o_txpipe6_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe6_cfg_hw_auto_sp_dis           output           1               cfg_hw_auto_sp_dis      o_txpipe6_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe6_dirchange                    output           1               dirchange               o_txpipe6_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe6_ebuf_mode                    output           1               ebuf_mode               o_txpipe6_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe6_encodedecodebypass           output           1               encodedecodebypass      o_txpipe6_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe6_fs                           output           6               fs                      o_txpipe6_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe6_getlocalpresetcoefficients   output           1        getlocalpresetcoefficients     o_txpipe6_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe6_invalidrequest               output           1               invalidrequest          o_txpipe6_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe6_lf                           output           6               lf                      o_txpipe6_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe6_localpresetindex             output           5               localpresetindex        o_txpipe6_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe6_m2p_bus                      output           8               m2p_bus                 o_txpipe6_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe6_pclk_rate                    output           3               pclk_rate               o_txpipe6_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe6_pclkchangeack                output           1               pclkchangeack           o_txpipe6_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe6_powerdown                    output           4               powerdown               o_txpipe6_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe6_rate                         output           3               rate                    o_txpipe6_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe6_rxelecidle_disable_a         output           1               rxelecidle_disable_a    o_txpipe6_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe6_rxeqeval                     output           1               rxeqeval                o_txpipe6_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe6_rxeqinprogress               output           1               rxeqinprogress          o_txpipe6_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe6_rxeqtraining                 output           1               rxeqtraining            o_txpipe6_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe6_rxpolarity                   output           1               rxpolarity              o_txpipe6_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe6_rxpresethint                 output           3               rxpresethint            o_txpipe6_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe6_rxstandby                    output           1               rxstandby               o_txpipe6_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe6_rxtermination                output           1               rxtermination           o_txpipe6_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe6_srisenable                   output           1               srisenable              o_txpipe6_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe6_txcmnmode_disable_a          output           1               txcmnmode_disable_a     o_txpipe6_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe6_txcompliance                 output           1               txcompliance            o_txpipe6_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe6_txdata                       output           40              txdata                  o_txpipe6_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe6_txdatak                      output           4               txdatak                 o_txpipe6_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe6_txdatavalid                  output           1               txdatavalid             o_txpipe6_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe6_txdeemph                     output           18              txdeemph                o_txpipe6_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe6_txdtctrx_lb                  output           1               txdtctrx_lb             o_txpipe6_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe6_txelecidle                   output           1               txelecidle              o_txpipe6_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe6_txmargin                     output           3               txmargin                o_txpipe6_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe6_txoneszeros                  output           1               txoneszeros             o_txpipe6_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe6_txstartblock                 output           1               txstartblock            o_txpipe6_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe6_txswing                      output           1               txswing                 o_txpipe6_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe6_txsyncheader                 output           4               txsyncheader            o_txpipe6_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe6_width                        output           3               width                   o_txpipe6_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
    \
        { o_txpipe7_asyncpowerchangeack          output           1               asyncpowerchangeack     o_txpipe7_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe7_blockaligncontrol            output           1               blockaligncontrol       o_txpipe7_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe7_cfg_hw_auto_sp_dis           output           1               cfg_hw_auto_sp_dis      o_txpipe7_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe7_dirchange                    output           1               dirchange               o_txpipe7_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe7_ebuf_mode                    output           1               ebuf_mode               o_txpipe7_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe7_encodedecodebypass           output           1               encodedecodebypass      o_txpipe7_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe7_fs                           output           6               fs                      o_txpipe7_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe7_getlocalpresetcoefficients   output           1        getlocalpresetcoefficients     o_txpipe7_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe7_invalidrequest               output           1               invalidrequest          o_txpipe7_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe7_lf                           output           6               lf                      o_txpipe7_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe7_localpresetindex             output           5               localpresetindex        o_txpipe7_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe7_m2p_bus                      output           8               m2p_bus                 o_txpipe7_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe7_pclk_rate                    output           3               pclk_rate               o_txpipe7_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe7_pclkchangeack                output           1               pclkchangeack           o_txpipe7_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe7_powerdown                    output           4               powerdown               o_txpipe7_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe7_rate                         output           3               rate                    o_txpipe7_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe7_rxelecidle_disable_a         output           1               rxelecidle_disable_a    o_txpipe7_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe7_rxeqeval                     output           1               rxeqeval                o_txpipe7_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe7_rxeqinprogress               output           1               rxeqinprogress          o_txpipe7_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe7_rxeqtraining                 output           1               rxeqtraining            o_txpipe7_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe7_rxpolarity                   output           1               rxpolarity              o_txpipe7_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe7_rxpresethint                 output           3               rxpresethint            o_txpipe7_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe7_rxstandby                    output           1               rxstandby               o_txpipe7_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe7_rxtermination                output           1               rxtermination           o_txpipe7_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe7_srisenable                   output           1               srisenable              o_txpipe7_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe7_txcmnmode_disable_a          output           1               txcmnmode_disable_a     o_txpipe7_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe7_txcompliance                 output           1               txcompliance            o_txpipe7_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe7_txdata                       output           40              txdata                  o_txpipe7_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe7_txdatak                      output           4               txdatak                 o_txpipe7_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe7_txdatavalid                  output           1               txdatavalid             o_txpipe7_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe7_txdeemph                     output           18              txdeemph                o_txpipe7_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe7_txdtctrx_lb                  output           1               txdtctrx_lb             o_txpipe7_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe7_txelecidle                   output           1               txelecidle              o_txpipe7_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe7_txmargin                     output           3               txmargin                o_txpipe7_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe7_txoneszeros                  output           1               txoneszeros             o_txpipe7_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe7_txstartblock                 output           1               txstartblock            o_txpipe7_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe7_txswing                      output           1               txswing                 o_txpipe7_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe7_txsyncheader                 output           4               txsyncheader            o_txpipe7_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe7_width                        output           3               width                   o_txpipe7_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
    \
        { o_txpipe8_asyncpowerchangeack          output           1               asyncpowerchangeack     o_txpipe8_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe8_blockaligncontrol            output           1               blockaligncontrol       o_txpipe8_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe8_cfg_hw_auto_sp_dis           output           1               cfg_hw_auto_sp_dis      o_txpipe8_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe8_dirchange                    output           1               dirchange               o_txpipe8_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe8_ebuf_mode                    output           1               ebuf_mode               o_txpipe8_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe8_encodedecodebypass           output           1               encodedecodebypass      o_txpipe8_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe8_fs                           output           6               fs                      o_txpipe8_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe8_getlocalpresetcoefficients   output           1        getlocalpresetcoefficients     o_txpipe8_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe8_invalidrequest               output           1               invalidrequest          o_txpipe8_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe8_lf                           output           6               lf                      o_txpipe8_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe8_localpresetindex             output           5               localpresetindex        o_txpipe8_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe8_m2p_bus                      output           8               m2p_bus                 o_txpipe8_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe8_pclk_rate                    output           3               pclk_rate               o_txpipe8_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe8_pclkchangeack                output           1               pclkchangeack           o_txpipe8_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe8_powerdown                    output           4               powerdown               o_txpipe8_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe8_rate                         output           3               rate                    o_txpipe8_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe8_rxelecidle_disable_a         output           1               rxelecidle_disable_a    o_txpipe8_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe8_rxeqeval                     output           1               rxeqeval                o_txpipe8_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe8_rxeqinprogress               output           1               rxeqinprogress          o_txpipe8_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe8_rxeqtraining                 output           1               rxeqtraining            o_txpipe8_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe8_rxpolarity                   output           1               rxpolarity              o_txpipe8_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe8_rxpresethint                 output           3               rxpresethint            o_txpipe8_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe8_rxstandby                    output           1               rxstandby               o_txpipe8_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe8_rxtermination                output           1               rxtermination           o_txpipe8_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe8_srisenable                   output           1               srisenable              o_txpipe8_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe8_txcmnmode_disable_a          output           1               txcmnmode_disable_a     o_txpipe8_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe8_txcompliance                 output           1               txcompliance            o_txpipe8_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe8_txdata                       output           40              txdata                  o_txpipe8_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe8_txdatak                      output           4               txdatak                 o_txpipe8_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe8_txdatavalid                  output           1               txdatavalid             o_txpipe8_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe8_txdeemph                     output           18              txdeemph                o_txpipe8_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe8_txdtctrx_lb                  output           1               txdtctrx_lb             o_txpipe8_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe8_txelecidle                   output           1               txelecidle              o_txpipe8_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe8_txmargin                     output           3               txmargin                o_txpipe8_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe8_txoneszeros                  output           1               txoneszeros             o_txpipe8_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe8_txstartblock                 output           1               txstartblock            o_txpipe8_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe8_txswing                      output           1               txswing                 o_txpipe8_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe8_txsyncheader                 output           4               txsyncheader            o_txpipe8_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe8_width                        output           3               width                   o_txpipe8_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
    \
        { o_txpipe9_asyncpowerchangeack          output           1               asyncpowerchangeack     o_txpipe9_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe9_blockaligncontrol            output           1               blockaligncontrol       o_txpipe9_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe9_cfg_hw_auto_sp_dis           output           1               cfg_hw_auto_sp_dis      o_txpipe9_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe9_dirchange                    output           1               dirchange               o_txpipe9_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe9_ebuf_mode                    output           1               ebuf_mode               o_txpipe9_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe9_encodedecodebypass           output           1               encodedecodebypass      o_txpipe9_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe9_fs                           output           6               fs                      o_txpipe9_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe9_getlocalpresetcoefficients   output           1        getlocalpresetcoefficients     o_txpipe9_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe9_invalidrequest               output           1               invalidrequest          o_txpipe9_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe9_lf                           output           6               lf                      o_txpipe9_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe9_localpresetindex             output           5               localpresetindex        o_txpipe9_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe9_m2p_bus                      output           8               m2p_bus                 o_txpipe9_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe9_pclk_rate                    output           3               pclk_rate               o_txpipe9_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe9_pclkchangeack                output           1               pclkchangeack           o_txpipe9_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe9_powerdown                    output           4               powerdown               o_txpipe9_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe9_rate                         output           3               rate                    o_txpipe9_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe9_rxelecidle_disable_a         output           1               rxelecidle_disable_a    o_txpipe9_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe9_rxeqeval                     output           1               rxeqeval                o_txpipe9_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe9_rxeqinprogress               output           1               rxeqinprogress          o_txpipe9_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe9_rxeqtraining                 output           1               rxeqtraining            o_txpipe9_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe9_rxpolarity                   output           1               rxpolarity              o_txpipe9_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe9_rxpresethint                 output           3               rxpresethint            o_txpipe9_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe9_rxstandby                    output           1               rxstandby               o_txpipe9_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe9_rxtermination                output           1               rxtermination           o_txpipe9_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe9_srisenable                   output           1               srisenable              o_txpipe9_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe9_txcmnmode_disable_a          output           1               txcmnmode_disable_a     o_txpipe9_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe9_txcompliance                 output           1               txcompliance            o_txpipe9_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe9_txdata                       output           40              txdata                  o_txpipe9_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe9_txdatak                      output           4               txdatak                 o_txpipe9_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe9_txdatavalid                  output           1               txdatavalid             o_txpipe9_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe9_txdeemph                     output           18              txdeemph                o_txpipe9_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe9_txdtctrx_lb                  output           1               txdtctrx_lb             o_txpipe9_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe9_txelecidle                   output           1               txelecidle              o_txpipe9_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe9_txmargin                     output           3               txmargin                o_txpipe9_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe9_txoneszeros                  output           1               txoneszeros             o_txpipe9_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe9_txstartblock                 output           1               txstartblock            o_txpipe9_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe9_txswing                      output           1               txswing                 o_txpipe9_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe9_txsyncheader                 output           4               txsyncheader            o_txpipe9_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe9_width                        output           3               width                   o_txpipe9_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
    \
        { o_txpipe10_asyncpowerchangeack          output           1               asyncpowerchangeack     o_txpipe10_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe10_blockaligncontrol            output           1               blockaligncontrol       o_txpipe10_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe10_cfg_hw_auto_sp_dis           output           1               cfg_hw_auto_sp_dis      o_txpipe10_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe10_dirchange                    output           1               dirchange               o_txpipe10_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe10_ebuf_mode                    output           1               ebuf_mode               o_txpipe10_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe10_encodedecodebypass           output           1               encodedecodebypass      o_txpipe10_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe10_fs                           output           6               fs                      o_txpipe10_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe10_getlocalpresetcoefficients   output           1        getlocalpresetcoefficients     o_txpipe10_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe10_invalidrequest               output           1               invalidrequest          o_txpipe10_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe10_lf                           output           6               lf                      o_txpipe10_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe10_localpresetindex             output           5               localpresetindex        o_txpipe10_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe10_m2p_bus                      output           8               m2p_bus                 o_txpipe10_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe10_pclk_rate                    output           3               pclk_rate               o_txpipe10_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe10_pclkchangeack                output           1               pclkchangeack           o_txpipe10_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe10_powerdown                    output           4               powerdown               o_txpipe10_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe10_rate                         output           3               rate                    o_txpipe10_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe10_rxelecidle_disable_a         output           1               rxelecidle_disable_a    o_txpipe10_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe10_rxeqeval                     output           1               rxeqeval                o_txpipe10_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe10_rxeqinprogress               output           1               rxeqinprogress          o_txpipe10_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe10_rxeqtraining                 output           1               rxeqtraining            o_txpipe10_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe10_rxpolarity                   output           1               rxpolarity              o_txpipe10_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe10_rxpresethint                 output           3               rxpresethint            o_txpipe10_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe10_rxstandby                    output           1               rxstandby               o_txpipe10_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe10_rxtermination                output           1               rxtermination           o_txpipe10_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe10_srisenable                   output           1               srisenable              o_txpipe10_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe10_txcmnmode_disable_a          output           1               txcmnmode_disable_a     o_txpipe10_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe10_txcompliance                 output           1               txcompliance            o_txpipe10_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe10_txdata                       output           40              txdata                  o_txpipe10_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe10_txdatak                      output           4               txdatak                 o_txpipe10_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe10_txdatavalid                  output           1               txdatavalid             o_txpipe10_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe10_txdeemph                     output           18              txdeemph                o_txpipe10_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe10_txdtctrx_lb                  output           1               txdtctrx_lb             o_txpipe10_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe10_txelecidle                   output           1               txelecidle              o_txpipe10_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe10_txmargin                     output           3               txmargin                o_txpipe10_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe10_txoneszeros                  output           1               txoneszeros             o_txpipe10_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe10_txstartblock                 output           1               txstartblock            o_txpipe10_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe10_txswing                      output           1               txswing                 o_txpipe10_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe10_txsyncheader                 output           4               txsyncheader            o_txpipe10_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe10_width                        output           3               width                   o_txpipe10_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
    \
        { o_txpipe11_asyncpowerchangeack          output           1               asyncpowerchangeack     o_txpipe11_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe11_blockaligncontrol            output           1               blockaligncontrol       o_txpipe11_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe11_cfg_hw_auto_sp_dis           output           1               cfg_hw_auto_sp_dis      o_txpipe11_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe11_dirchange                    output           1               dirchange               o_txpipe11_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe11_ebuf_mode                    output           1               ebuf_mode               o_txpipe11_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe11_encodedecodebypass           output           1               encodedecodebypass      o_txpipe11_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe11_fs                           output           6               fs                      o_txpipe11_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe11_getlocalpresetcoefficients   output           1        getlocalpresetcoefficients     o_txpipe11_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe11_invalidrequest               output           1               invalidrequest          o_txpipe11_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe11_lf                           output           6               lf                      o_txpipe11_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe11_localpresetindex             output           5               localpresetindex        o_txpipe11_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe11_m2p_bus                      output           8               m2p_bus                 o_txpipe11_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe11_pclk_rate                    output           3               pclk_rate               o_txpipe11_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe11_pclkchangeack                output           1               pclkchangeack           o_txpipe11_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe11_powerdown                    output           4               powerdown               o_txpipe11_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe11_rate                         output           3               rate                    o_txpipe11_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe11_rxelecidle_disable_a         output           1               rxelecidle_disable_a    o_txpipe11_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe11_rxeqeval                     output           1               rxeqeval                o_txpipe11_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe11_rxeqinprogress               output           1               rxeqinprogress          o_txpipe11_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe11_rxeqtraining                 output           1               rxeqtraining            o_txpipe11_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe11_rxpolarity                   output           1               rxpolarity              o_txpipe11_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe11_rxpresethint                 output           3               rxpresethint            o_txpipe11_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe11_rxstandby                    output           1               rxstandby               o_txpipe11_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe11_rxtermination                output           1               rxtermination           o_txpipe11_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe11_srisenable                   output           1               srisenable              o_txpipe11_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe11_txcmnmode_disable_a          output           1               txcmnmode_disable_a     o_txpipe11_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe11_txcompliance                 output           1               txcompliance            o_txpipe11_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe11_txdata                       output           40              txdata                  o_txpipe11_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe11_txdatak                      output           4               txdatak                 o_txpipe11_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe11_txdatavalid                  output           1               txdatavalid             o_txpipe11_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe11_txdeemph                     output           18              txdeemph                o_txpipe11_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe11_txdtctrx_lb                  output           1               txdtctrx_lb             o_txpipe11_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe11_txelecidle                   output           1               txelecidle              o_txpipe11_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe11_txmargin                     output           3               txmargin                o_txpipe11_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe11_txoneszeros                  output           1               txoneszeros             o_txpipe11_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe11_txstartblock                 output           1               txstartblock            o_txpipe11_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe11_txswing                      output           1               txswing                 o_txpipe11_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe11_txsyncheader                 output           4               txsyncheader            o_txpipe11_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe11_width                        output           3               width                   o_txpipe11_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
    \
        { o_txpipe12_asyncpowerchangeack          output           1               asyncpowerchangeack     o_txpipe12_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe12_blockaligncontrol            output           1               blockaligncontrol       o_txpipe12_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe12_cfg_hw_auto_sp_dis           output           1               cfg_hw_auto_sp_dis      o_txpipe12_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe12_dirchange                    output           1               dirchange               o_txpipe12_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe12_ebuf_mode                    output           1               ebuf_mode               o_txpipe12_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe12_encodedecodebypass           output           1               encodedecodebypass      o_txpipe12_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe12_fs                           output           6               fs                      o_txpipe12_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe12_getlocalpresetcoefficients   output           1        getlocalpresetcoefficients     o_txpipe12_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe12_invalidrequest               output           1               invalidrequest          o_txpipe12_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe12_lf                           output           6               lf                      o_txpipe12_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe12_localpresetindex             output           5               localpresetindex        o_txpipe12_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe12_m2p_bus                      output           8               m2p_bus                 o_txpipe12_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe12_pclk_rate                    output           3               pclk_rate               o_txpipe12_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe12_pclkchangeack                output           1               pclkchangeack           o_txpipe12_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe12_powerdown                    output           4               powerdown               o_txpipe12_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe12_rate                         output           3               rate                    o_txpipe12_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe12_rxelecidle_disable_a         output           1               rxelecidle_disable_a    o_txpipe12_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe12_rxeqeval                     output           1               rxeqeval                o_txpipe12_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe12_rxeqinprogress               output           1               rxeqinprogress          o_txpipe12_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe12_rxeqtraining                 output           1               rxeqtraining            o_txpipe12_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe12_rxpolarity                   output           1               rxpolarity              o_txpipe12_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe12_rxpresethint                 output           3               rxpresethint            o_txpipe12_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe12_rxstandby                    output           1               rxstandby               o_txpipe12_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe12_rxtermination                output           1               rxtermination           o_txpipe12_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe12_srisenable                   output           1               srisenable              o_txpipe12_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe12_txcmnmode_disable_a          output           1               txcmnmode_disable_a     o_txpipe12_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe12_txcompliance                 output           1               txcompliance            o_txpipe12_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe12_txdata                       output           40              txdata                  o_txpipe12_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe12_txdatak                      output           4               txdatak                 o_txpipe12_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe12_txdatavalid                  output           1               txdatavalid             o_txpipe12_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe12_txdeemph                     output           18              txdeemph                o_txpipe12_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe12_txdtctrx_lb                  output           1               txdtctrx_lb             o_txpipe12_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe12_txelecidle                   output           1               txelecidle              o_txpipe12_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe12_txmargin                     output           3               txmargin                o_txpipe12_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe12_txoneszeros                  output           1               txoneszeros             o_txpipe12_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe12_txstartblock                 output           1               txstartblock            o_txpipe12_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe12_txswing                      output           1               txswing                 o_txpipe12_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe12_txsyncheader                 output           4               txsyncheader            o_txpipe12_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe12_width                        output           3               width                   o_txpipe12_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
    \
        { o_txpipe13_asyncpowerchangeack          output           1               asyncpowerchangeack     o_txpipe13_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe13_blockaligncontrol            output           1               blockaligncontrol       o_txpipe13_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe13_cfg_hw_auto_sp_dis           output           1               cfg_hw_auto_sp_dis      o_txpipe13_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe13_dirchange                    output           1               dirchange               o_txpipe13_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe13_ebuf_mode                    output           1               ebuf_mode               o_txpipe13_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe13_encodedecodebypass           output           1               encodedecodebypass      o_txpipe13_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe13_fs                           output           6               fs                      o_txpipe13_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe13_getlocalpresetcoefficients   output           1        getlocalpresetcoefficients     o_txpipe13_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe13_invalidrequest               output           1               invalidrequest          o_txpipe13_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe13_lf                           output           6               lf                      o_txpipe13_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe13_localpresetindex             output           5               localpresetindex        o_txpipe13_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe13_m2p_bus                      output           8               m2p_bus                 o_txpipe13_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe13_pclk_rate                    output           3               pclk_rate               o_txpipe13_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe13_pclkchangeack                output           1               pclkchangeack           o_txpipe13_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe13_powerdown                    output           4               powerdown               o_txpipe13_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe13_rate                         output           3               rate                    o_txpipe13_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe13_rxelecidle_disable_a         output           1               rxelecidle_disable_a    o_txpipe13_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe13_rxeqeval                     output           1               rxeqeval                o_txpipe13_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe13_rxeqinprogress               output           1               rxeqinprogress          o_txpipe13_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe13_rxeqtraining                 output           1               rxeqtraining            o_txpipe13_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe13_rxpolarity                   output           1               rxpolarity              o_txpipe13_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe13_rxpresethint                 output           3               rxpresethint            o_txpipe13_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe13_rxstandby                    output           1               rxstandby               o_txpipe13_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe13_rxtermination                output           1               rxtermination           o_txpipe13_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe13_srisenable                   output           1               srisenable              o_txpipe13_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe13_txcmnmode_disable_a          output           1               txcmnmode_disable_a     o_txpipe13_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe13_txcompliance                 output           1               txcompliance            o_txpipe13_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe13_txdata                       output           40              txdata                  o_txpipe13_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe13_txdatak                      output           4               txdatak                 o_txpipe13_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe13_txdatavalid                  output           1               txdatavalid             o_txpipe13_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe13_txdeemph                     output           18              txdeemph                o_txpipe13_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe13_txdtctrx_lb                  output           1               txdtctrx_lb             o_txpipe13_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe13_txelecidle                   output           1               txelecidle              o_txpipe13_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe13_txmargin                     output           3               txmargin                o_txpipe13_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe13_txoneszeros                  output           1               txoneszeros             o_txpipe13_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe13_txstartblock                 output           1               txstartblock            o_txpipe13_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe13_txswing                      output           1               txswing                 o_txpipe13_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe13_txsyncheader                 output           4               txsyncheader            o_txpipe13_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe13_width                        output           3               width                   o_txpipe13_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
    \
        { o_txpipe14_asyncpowerchangeack          output           1               asyncpowerchangeack     o_txpipe14_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe14_blockaligncontrol            output           1               blockaligncontrol       o_txpipe14_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe14_cfg_hw_auto_sp_dis           output           1               cfg_hw_auto_sp_dis      o_txpipe14_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe14_dirchange                    output           1               dirchange               o_txpipe14_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe14_ebuf_mode                    output           1               ebuf_mode               o_txpipe14_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe14_encodedecodebypass           output           1               encodedecodebypass      o_txpipe14_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe14_fs                           output           6               fs                      o_txpipe14_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe14_getlocalpresetcoefficients   output           1        getlocalpresetcoefficients     o_txpipe14_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe14_invalidrequest               output           1               invalidrequest          o_txpipe14_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe14_lf                           output           6               lf                      o_txpipe14_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe14_localpresetindex             output           5               localpresetindex        o_txpipe14_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe14_m2p_bus                      output           8               m2p_bus                 o_txpipe14_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe14_pclk_rate                    output           3               pclk_rate               o_txpipe14_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe14_pclkchangeack                output           1               pclkchangeack           o_txpipe14_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe14_powerdown                    output           4               powerdown               o_txpipe14_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe14_rate                         output           3               rate                    o_txpipe14_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe14_rxelecidle_disable_a         output           1               rxelecidle_disable_a    o_txpipe14_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe14_rxeqeval                     output           1               rxeqeval                o_txpipe14_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe14_rxeqinprogress               output           1               rxeqinprogress          o_txpipe14_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe14_rxeqtraining                 output           1               rxeqtraining            o_txpipe14_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe14_rxpolarity                   output           1               rxpolarity              o_txpipe14_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe14_rxpresethint                 output           3               rxpresethint            o_txpipe14_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe14_rxstandby                    output           1               rxstandby               o_txpipe14_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe14_rxtermination                output           1               rxtermination           o_txpipe14_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe14_srisenable                   output           1               srisenable              o_txpipe14_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe14_txcmnmode_disable_a          output           1               txcmnmode_disable_a     o_txpipe14_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe14_txcompliance                 output           1               txcompliance            o_txpipe14_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe14_txdata                       output           40              txdata                  o_txpipe14_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe14_txdatak                      output           4               txdatak                 o_txpipe14_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe14_txdatavalid                  output           1               txdatavalid             o_txpipe14_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe14_txdeemph                     output           18              txdeemph                o_txpipe14_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe14_txdtctrx_lb                  output           1               txdtctrx_lb             o_txpipe14_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe14_txelecidle                   output           1               txelecidle              o_txpipe14_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe14_txmargin                     output           3               txmargin                o_txpipe14_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe14_txoneszeros                  output           1               txoneszeros             o_txpipe14_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe14_txstartblock                 output           1               txstartblock            o_txpipe14_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe14_txswing                      output           1               txswing                 o_txpipe14_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe14_txsyncheader                 output           4               txsyncheader            o_txpipe14_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe14_width                        output           3               width                   o_txpipe14_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
    \
        { o_txpipe15_asyncpowerchangeack          output           1               asyncpowerchangeack     o_txpipe15_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe15_blockaligncontrol            output           1               blockaligncontrol       o_txpipe15_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe15_cfg_hw_auto_sp_dis           output           1               cfg_hw_auto_sp_dis      o_txpipe15_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe15_dirchange                    output           1               dirchange               o_txpipe15_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe15_ebuf_mode                    output           1               ebuf_mode               o_txpipe15_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe15_encodedecodebypass           output           1               encodedecodebypass      o_txpipe15_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe15_fs                           output           6               fs                      o_txpipe15_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe15_getlocalpresetcoefficients   output           1        getlocalpresetcoefficients     o_txpipe15_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe15_invalidrequest               output           1               invalidrequest          o_txpipe15_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe15_lf                           output           6               lf                      o_txpipe15_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe15_localpresetindex             output           5               localpresetindex        o_txpipe15_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe15_m2p_bus                      output           8               m2p_bus                 o_txpipe15_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe15_pclk_rate                    output           3               pclk_rate               o_txpipe15_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe15_pclkchangeack                output           1               pclkchangeack           o_txpipe15_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe15_powerdown                    output           4               powerdown               o_txpipe15_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe15_rate                         output           3               rate                    o_txpipe15_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe15_rxelecidle_disable_a         output           1               rxelecidle_disable_a    o_txpipe15_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe15_rxeqeval                     output           1               rxeqeval                o_txpipe15_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe15_rxeqinprogress               output           1               rxeqinprogress          o_txpipe15_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe15_rxeqtraining                 output           1               rxeqtraining            o_txpipe15_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe15_rxpolarity                   output           1               rxpolarity              o_txpipe15_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe15_rxpresethint                 output           3               rxpresethint            o_txpipe15_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe15_rxstandby                    output           1               rxstandby               o_txpipe15_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe15_rxtermination                output           1               rxtermination           o_txpipe15_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe15_srisenable                   output           1               srisenable              o_txpipe15_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe15_txcmnmode_disable_a          output           1               txcmnmode_disable_a     o_txpipe15_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe15_txcompliance                 output           1               txcompliance            o_txpipe15_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe15_txdata                       output           40              txdata                  o_txpipe15_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe15_txdatak                      output           4               txdatak                 o_txpipe15_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe15_txdatavalid                  output           1               txdatavalid             o_txpipe15_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe15_txdeemph                     output           18              txdeemph                o_txpipe15_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe15_txdtctrx_lb                  output           1               txdtctrx_lb             o_txpipe15_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe15_txelecidle                   output           1               txelecidle              o_txpipe15_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe15_txmargin                     output           3               txmargin                o_txpipe15_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe15_txoneszeros                  output           1               txoneszeros             o_txpipe15_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe15_txstartblock                 output           1               txstartblock            o_txpipe15_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe15_txswing                      output           1               txswing                 o_txpipe15_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe15_txsyncheader                 output           4               txsyncheader            o_txpipe15_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { o_txpipe15_width                        output           3               width                   o_txpipe15_       conduit         end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
    \
        { i_pclk_x4_l4                            input            1               clk                   i_pclk_x4_l4           clock           end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { i_pclk_x4_l12                           input            1               clk                   i_pclk_x4_l12          clock           end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { i_pclk_x8_l8                            input            1               clk                   i_pclk_x8_l8           clock           end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
        { i_pclk_x16_l0                           input            1               clk                   i_pclk_x16_l0          clock           end                 "!pipemode_sim_ed_hwtcl || tile_integer != 1"      NOVAL                   NOVAL                       "Check User Guide for details"      }\
    \
    }

       set rtile_interfaces_pipemode {\
	{ NAME                                              DIRECTION WIDTH_EXPR                     ROLE                         IFACE_NAME             IFACE_TYPE IFACE_DIRECTION TERMINATION                                                                                               TERMINATION_VALUE ELABORATION_CALLBACK                                                             DESCRIPTION                    }\
	{ fastp_pcie_pipe_p0_lane_rst_n                 output      1         p0_lane_rst_n              fastp_pcie_              conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
    { fastp_pcie_pipe_p1_lane_rst_n                 output      1         p1_lane_rst_n              fastp_pcie_              conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
    { fastp_pcie_pipe_p2_lane_rst_n                 output      1         p2_lane_rst_n              fastp_pcie_              conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
    { fastp_pcie_pipe_p3_lane_rst_n                 output      1         p3_lane_rst_n              fastp_pcie_              conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
    { fastp_pcie_l0_pipe_clk                        output     1         l0_pipe_clk                fastp_pcie_              conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_l1_pipe_clk                        output     1         l1_pipe_clk                fastp_pcie_              conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_l2_pipe_clk                        output     1         l2_pipe_clk                fastp_pcie_              conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_l3_pipe_clk                        output     1         l3_pipe_clk                fastp_pcie_              conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_l4_pipe_clk                        output     1         l4_pipe_clk                fastp_pcie_              conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_l5_pipe_clk                        output     1         l5_pipe_clk                fastp_pcie_              conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_l6_pipe_clk                        output     1         l6_pipe_clk                fastp_pcie_              conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_l7_pipe_clk                        output     1         l7_pipe_clk                fastp_pcie_              conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_l8_pipe_clk                        output     1         l8_pipe_clk                fastp_pcie_              conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_l9_pipe_clk                        output     1         l9_pipe_clk                fastp_pcie_              conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_l10_pipe_clk                       output     1         l10_pipe_clk               fastp_pcie_              conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_l11_pipe_clk                       output     1         l11_pipe_clk               fastp_pcie_              conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_l12_pipe_clk                       output     1         l12_pipe_clk               fastp_pcie_              conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_l13_pipe_clk                       output     1         l13_pipe_clk               fastp_pcie_              conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_l14_pipe_clk                       output     1         l14_pipe_clk               fastp_pcie_              conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_l15_pipe_clk                       output     1         l15_pipe_clk               fastp_pcie_              conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch0_messagebus_o           output     8         ch0_messagebus_o           fastp_pcie_mac_phy_ch0_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch0_pclk_rate_o            output     3         ch0_pclk_rate_o            fastp_pcie_mac_phy_ch0_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch0_powerdown_o            output     4         ch0_powerdown_o            fastp_pcie_mac_phy_ch0_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch0_rate_o                 output     3         ch0_rate_o                 fastp_pcie_mac_phy_ch0_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch0_rxstandby_o            output     1         ch0_rxstandby_o            fastp_pcie_mac_phy_ch0_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch0_rxwidth_o              output     2         ch0_rxwidth_o              fastp_pcie_mac_phy_ch0_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch0_txdata_o               output    40         ch0_txdata_o               fastp_pcie_mac_phy_ch0_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch0_txdatavalid_o          output     1         ch0_txdatavalid_o          fastp_pcie_mac_phy_ch0_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch0_txdetectrx_loopback_o  output     1         ch0_txdetectrx_loopback_o  fastp_pcie_mac_phy_ch0_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch0_txelecidle_o           output     4         ch0_txelecidle_o           fastp_pcie_mac_phy_ch0_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch0_width_o                output     2         ch0_width_o                fastp_pcie_mac_phy_ch0_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch0_rxelecidle_disable_o   output     1         ch0_rxelecidle_disable_o   fastp_pcie_mac_phy_ch0_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch0_txcmnmode_disable_o    output     1         ch0_txcmnmode_disable_o    fastp_pcie_mac_phy_ch0_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch0_rxtermination_o        output     1         ch0_rxtermination_o        fastp_pcie_mac_phy_ch0_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch0_srisenable_o           output     1         ch0_srisenable_o           fastp_pcie_mac_phy_ch0_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch0_pclkchangeack_o        output     1         ch0_pclkchangeack_o        fastp_pcie_mac_phy_ch0_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch0_messagebus_i           input      8         ch0_messagebus_i           fastp_pcie_mac_phy_ch0_  conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch0_phystatus_i            input      1         ch0_phystatus_i            fastp_pcie_mac_phy_ch0_  conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch0_rxdata_i               input     40         ch0_rxdata_i               fastp_pcie_mac_phy_ch0_  conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch0_rxelecidle_i           input      1         ch0_rxelecidle_i           fastp_pcie_mac_phy_ch0_  conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch0_rxstandbystatus_i      input      1         ch0_rxstandbystatus_i      fastp_pcie_mac_phy_ch0_  conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch0_rxstatus_i             input      3         ch0_rxstatus_i             fastp_pcie_mac_phy_ch0_  conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch0_rxvalid_i              input      1         ch0_rxvalid_i              fastp_pcie_mac_phy_ch0_  conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch0_pclkchangeok_i         input      1         ch0_pclkchangeok_i         fastp_pcie_mac_phy_ch0_  conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch1_messagebus_o           output     8         ch1_messagebus_o           fastp_pcie_mac_phy_ch1_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch1_pclk_rate_o            output     3         ch1_pclk_rate_o            fastp_pcie_mac_phy_ch1_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch1_powerdown_o            output     4         ch1_powerdown_o            fastp_pcie_mac_phy_ch1_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch1_rate_o                 output     3         ch1_rate_o                 fastp_pcie_mac_phy_ch1_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch1_rxstandby_o            output     1         ch1_rxstandby_o            fastp_pcie_mac_phy_ch1_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch1_rxwidth_o              output     2         ch1_rxwidth_o              fastp_pcie_mac_phy_ch1_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch1_txdata_o               output    40         ch1_txdata_o               fastp_pcie_mac_phy_ch1_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch1_txdatavalid_o          output     1         ch1_txdatavalid_o          fastp_pcie_mac_phy_ch1_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch1_txdetectrx_loopback_o  output     1         ch1_txdetectrx_loopback_o  fastp_pcie_mac_phy_ch1_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch1_txelecidle_o           output     4         ch1_txelecidle_o           fastp_pcie_mac_phy_ch1_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch1_width_o                output     2         ch1_width_o                fastp_pcie_mac_phy_ch1_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch1_rxelecidle_disable_o   output     1         ch1_rxelecidle_disable_o   fastp_pcie_mac_phy_ch1_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch1_txcmnmode_disable_o    output     1         ch1_txcmnmode_disable_o    fastp_pcie_mac_phy_ch1_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch1_rxtermination_o        output     1         ch1_rxtermination_o        fastp_pcie_mac_phy_ch1_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch1_srisenable_o           output     1         ch1_srisenable_o           fastp_pcie_mac_phy_ch1_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch1_pclkchangeack_o        output     1         ch1_pclkchangeack_o        fastp_pcie_mac_phy_ch1_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch1_messagebus_i           input      8         ch1_messagebus_i           fastp_pcie_mac_phy_ch1_  conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch1_phystatus_i            input      1         ch1_phystatus_i            fastp_pcie_mac_phy_ch1_  conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch1_rxdata_i               input     40         ch1_rxdata_i               fastp_pcie_mac_phy_ch1_  conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch1_rxelecidle_i           input      1         ch1_rxelecidle_i           fastp_pcie_mac_phy_ch1_  conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch1_rxstandbystatus_i      input      1         ch1_rxstandbystatus_i      fastp_pcie_mac_phy_ch1_  conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch1_rxstatus_i             input      3         ch1_rxstatus_i             fastp_pcie_mac_phy_ch1_  conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch1_rxvalid_i              input      1         ch1_rxvalid_i              fastp_pcie_mac_phy_ch1_  conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch1_pclkchangeok_i         input      1         ch1_pclkchangeok_i         fastp_pcie_mac_phy_ch1_  conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch2_messagebus_o           output     8         ch2_messagebus_o           fastp_pcie_mac_phy_ch2_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch2_pclk_rate_o            output     3         ch2_pclk_rate_o            fastp_pcie_mac_phy_ch2_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch2_powerdown_o            output     4         ch2_powerdown_o            fastp_pcie_mac_phy_ch2_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch2_rate_o                 output     3         ch2_rate_o                 fastp_pcie_mac_phy_ch2_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch2_rxstandby_o            output     1         ch2_rxstandby_o            fastp_pcie_mac_phy_ch2_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch2_rxwidth_o              output     2         ch2_rxwidth_o              fastp_pcie_mac_phy_ch2_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch2_txdata_o               output    40         ch2_txdata_o               fastp_pcie_mac_phy_ch2_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch2_txdatavalid_o          output     1         ch2_txdatavalid_o          fastp_pcie_mac_phy_ch2_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch2_txdetectrx_loopback_o  output     1         ch2_txdetectrx_loopback_o  fastp_pcie_mac_phy_ch2_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch2_txelecidle_o           output     4         ch2_txelecidle_o           fastp_pcie_mac_phy_ch2_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch2_width_o                output     2         ch2_width_o                fastp_pcie_mac_phy_ch2_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch2_rxelecidle_disable_o   output     1         ch2_rxelecidle_disable_o   fastp_pcie_mac_phy_ch2_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch2_txcmnmode_disable_o    output     1         ch2_txcmnmode_disable_o    fastp_pcie_mac_phy_ch2_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch2_rxtermination_o        output     1         ch2_rxtermination_o        fastp_pcie_mac_phy_ch2_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch2_srisenable_o           output     1         ch2_srisenable_o           fastp_pcie_mac_phy_ch2_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch2_pclkchangeack_o        output     1         ch2_pclkchangeack_o        fastp_pcie_mac_phy_ch2_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch2_messagebus_i           input      8         ch2_messagebus_i           fastp_pcie_mac_phy_ch2_  conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch2_phystatus_i            input      1         ch2_phystatus_i            fastp_pcie_mac_phy_ch2_  conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch2_rxdata_i               input     40         ch2_rxdata_i               fastp_pcie_mac_phy_ch2_  conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch2_rxelecidle_i           input      1         ch2_rxelecidle_i           fastp_pcie_mac_phy_ch2_  conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch2_rxstandbystatus_i      input      1         ch2_rxstandbystatus_i      fastp_pcie_mac_phy_ch2_  conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch2_rxstatus_i             input      3         ch2_rxstatus_i             fastp_pcie_mac_phy_ch2_  conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch2_rxvalid_i              input      1         ch2_rxvalid_i              fastp_pcie_mac_phy_ch2_  conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch2_pclkchangeok_i         input      1         ch2_pclkchangeok_i         fastp_pcie_mac_phy_ch2_  conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch3_messagebus_o           output     8         ch3_messagebus_o           fastp_pcie_mac_phy_ch3_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch3_pclk_rate_o            output     3         ch3_pclk_rate_o            fastp_pcie_mac_phy_ch3_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch3_powerdown_o            output     4         ch3_powerdown_o            fastp_pcie_mac_phy_ch3_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch3_rate_o                 output     3         ch3_rate_o                 fastp_pcie_mac_phy_ch3_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch3_rxstandby_o            output     1         ch3_rxstandby_o            fastp_pcie_mac_phy_ch3_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch3_rxwidth_o              output     2         ch3_rxwidth_o              fastp_pcie_mac_phy_ch3_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch3_txdata_o               output    40         ch3_txdata_o               fastp_pcie_mac_phy_ch3_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch3_txdatavalid_o          output     1         ch3_txdatavalid_o          fastp_pcie_mac_phy_ch3_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch3_txdetectrx_loopback_o  output     1         ch3_txdetectrx_loopback_o  fastp_pcie_mac_phy_ch3_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch3_txelecidle_o           output     4         ch3_txelecidle_o           fastp_pcie_mac_phy_ch3_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch3_width_o                output     2         ch3_width_o                fastp_pcie_mac_phy_ch3_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch3_rxelecidle_disable_o   output     1         ch3_rxelecidle_disable_o   fastp_pcie_mac_phy_ch3_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch3_txcmnmode_disable_o    output     1         ch3_txcmnmode_disable_o    fastp_pcie_mac_phy_ch3_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch3_rxtermination_o        output     1         ch3_rxtermination_o        fastp_pcie_mac_phy_ch3_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch3_srisenable_o           output     1         ch3_srisenable_o           fastp_pcie_mac_phy_ch3_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch3_pclkchangeack_o        output     1         ch3_pclkchangeack_o        fastp_pcie_mac_phy_ch3_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch3_messagebus_i           input      8         ch3_messagebus_i           fastp_pcie_mac_phy_ch3_  conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch3_phystatus_i            input      1         ch3_phystatus_i            fastp_pcie_mac_phy_ch3_  conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch3_rxdata_i               input     40         ch3_rxdata_i               fastp_pcie_mac_phy_ch3_  conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch3_rxelecidle_i           input      1         ch3_rxelecidle_i           fastp_pcie_mac_phy_ch3_  conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch3_rxstandbystatus_i      input      1         ch3_rxstandbystatus_i      fastp_pcie_mac_phy_ch3_  conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch3_rxstatus_i             input      3         ch3_rxstatus_i             fastp_pcie_mac_phy_ch3_  conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch3_rxvalid_i              input      1         ch3_rxvalid_i              fastp_pcie_mac_phy_ch3_  conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch3_pclkchangeok_i         input      1         ch3_pclkchangeok_i         fastp_pcie_mac_phy_ch3_  conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch4_messagebus_o           output     8         ch4_messagebus_o           fastp_pcie_mac_phy_ch4_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch4_pclk_rate_o            output     3         ch4_pclk_rate_o            fastp_pcie_mac_phy_ch4_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch4_powerdown_o            output     4         ch4_powerdown_o            fastp_pcie_mac_phy_ch4_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch4_rate_o                 output     3         ch4_rate_o                 fastp_pcie_mac_phy_ch4_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch4_rxstandby_o            output     1         ch4_rxstandby_o            fastp_pcie_mac_phy_ch4_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch4_rxwidth_o              output     2         ch4_rxwidth_o              fastp_pcie_mac_phy_ch4_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch4_txdata_o               output    40         ch4_txdata_o               fastp_pcie_mac_phy_ch4_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch4_txdatavalid_o          output     1         ch4_txdatavalid_o          fastp_pcie_mac_phy_ch4_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch4_txdetectrx_loopback_o  output     1         ch4_txdetectrx_loopback_o  fastp_pcie_mac_phy_ch4_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch4_txelecidle_o           output     4         ch4_txelecidle_o           fastp_pcie_mac_phy_ch4_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch4_width_o                output     2         ch4_width_o                fastp_pcie_mac_phy_ch4_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch4_rxelecidle_disable_o   output     1         ch4_rxelecidle_disable_o   fastp_pcie_mac_phy_ch4_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch4_txcmnmode_disable_o    output     1         ch4_txcmnmode_disable_o    fastp_pcie_mac_phy_ch4_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch4_rxtermination_o        output     1         ch4_rxtermination_o        fastp_pcie_mac_phy_ch4_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch4_srisenable_o           output     1         ch4_srisenable_o           fastp_pcie_mac_phy_ch4_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch4_pclkchangeack_o        output     1         ch4_pclkchangeack_o        fastp_pcie_mac_phy_ch4_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch4_messagebus_i           input      8         ch4_messagebus_i           fastp_pcie_mac_phy_ch4_  conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch4_phystatus_i            input      1         ch4_phystatus_i            fastp_pcie_mac_phy_ch4_  conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch4_rxdata_i               input     40         ch4_rxdata_i               fastp_pcie_mac_phy_ch4_  conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch4_rxelecidle_i           input      1         ch4_rxelecidle_i           fastp_pcie_mac_phy_ch4_  conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch4_rxstandbystatus_i      input      1         ch4_rxstandbystatus_i      fastp_pcie_mac_phy_ch4_  conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch4_rxstatus_i             input      3         ch4_rxstatus_i             fastp_pcie_mac_phy_ch4_  conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch4_rxvalid_i              input      1         ch4_rxvalid_i              fastp_pcie_mac_phy_ch4_  conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch4_pclkchangeok_i         input      1         ch4_pclkchangeok_i         fastp_pcie_mac_phy_ch4_  conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch5_messagebus_o           output     8         ch5_messagebus_o           fastp_pcie_mac_phy_ch5_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch5_pclk_rate_o            output     3         ch5_pclk_rate_o            fastp_pcie_mac_phy_ch5_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch5_powerdown_o            output     4         ch5_powerdown_o            fastp_pcie_mac_phy_ch5_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch5_rate_o                 output     3         ch5_rate_o                 fastp_pcie_mac_phy_ch5_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch5_rxstandby_o            output     1         ch5_rxstandby_o            fastp_pcie_mac_phy_ch5_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch5_rxwidth_o              output     2         ch5_rxwidth_o              fastp_pcie_mac_phy_ch5_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch5_txdata_o               output    40         ch5_txdata_o               fastp_pcie_mac_phy_ch5_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch5_txdatavalid_o          output     1         ch5_txdatavalid_o          fastp_pcie_mac_phy_ch5_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch5_txdetectrx_loopback_o  output     1         ch5_txdetectrx_loopback_o  fastp_pcie_mac_phy_ch5_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch5_txelecidle_o           output     4         ch5_txelecidle_o           fastp_pcie_mac_phy_ch5_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch5_width_o                output     2         ch5_width_o                fastp_pcie_mac_phy_ch5_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch5_rxelecidle_disable_o   output     1         ch5_rxelecidle_disable_o   fastp_pcie_mac_phy_ch5_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch5_txcmnmode_disable_o    output     1         ch5_txcmnmode_disable_o    fastp_pcie_mac_phy_ch5_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch5_rxtermination_o        output     1         ch5_rxtermination_o        fastp_pcie_mac_phy_ch5_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch5_srisenable_o           output     1         ch5_srisenable_o           fastp_pcie_mac_phy_ch5_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch5_pclkchangeack_o        output     1         ch5_pclkchangeack_o        fastp_pcie_mac_phy_ch5_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch5_messagebus_i           input      8         ch5_messagebus_i           fastp_pcie_mac_phy_ch5_  conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch5_phystatus_i            input      1         ch5_phystatus_i            fastp_pcie_mac_phy_ch5_  conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch5_rxdata_i               input     40         ch5_rxdata_i               fastp_pcie_mac_phy_ch5_  conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch5_rxelecidle_i           input      1         ch5_rxelecidle_i           fastp_pcie_mac_phy_ch5_  conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch5_rxstandbystatus_i      input      1         ch5_rxstandbystatus_i      fastp_pcie_mac_phy_ch5_  conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch5_rxstatus_i             input      3         ch5_rxstatus_i             fastp_pcie_mac_phy_ch5_  conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch5_rxvalid_i              input      1         ch5_rxvalid_i              fastp_pcie_mac_phy_ch5_  conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch5_pclkchangeok_i         input      1         ch5_pclkchangeok_i         fastp_pcie_mac_phy_ch5_  conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch6_messagebus_o           output     8         ch6_messagebus_o           fastp_pcie_mac_phy_ch6_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch6_pclk_rate_o            output     3         ch6_pclk_rate_o            fastp_pcie_mac_phy_ch6_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch6_powerdown_o            output     4         ch6_powerdown_o            fastp_pcie_mac_phy_ch6_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch6_rate_o                 output     3         ch6_rate_o                 fastp_pcie_mac_phy_ch6_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch6_rxstandby_o            output     1         ch6_rxstandby_o            fastp_pcie_mac_phy_ch6_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch6_rxwidth_o              output     2         ch6_rxwidth_o              fastp_pcie_mac_phy_ch6_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch6_txdata_o               output    40         ch6_txdata_o               fastp_pcie_mac_phy_ch6_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch6_txdatavalid_o          output     1         ch6_txdatavalid_o          fastp_pcie_mac_phy_ch6_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch6_txdetectrx_loopback_o  output     1         ch6_txdetectrx_loopback_o  fastp_pcie_mac_phy_ch6_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch6_txelecidle_o           output     4         ch6_txelecidle_o           fastp_pcie_mac_phy_ch6_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch6_width_o                output     2         ch6_width_o                fastp_pcie_mac_phy_ch6_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch6_rxelecidle_disable_o   output     1         ch6_rxelecidle_disable_o   fastp_pcie_mac_phy_ch6_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch6_txcmnmode_disable_o    output     1         ch6_txcmnmode_disable_o    fastp_pcie_mac_phy_ch6_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch6_rxtermination_o        output     1         ch6_rxtermination_o        fastp_pcie_mac_phy_ch6_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch6_srisenable_o           output     1         ch6_srisenable_o           fastp_pcie_mac_phy_ch6_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch6_pclkchangeack_o        output     1         ch6_pclkchangeack_o        fastp_pcie_mac_phy_ch6_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch6_messagebus_i           input      8         ch6_messagebus_i           fastp_pcie_mac_phy_ch6_  conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch6_phystatus_i            input      1         ch6_phystatus_i            fastp_pcie_mac_phy_ch6_  conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch6_rxdata_i               input     40         ch6_rxdata_i               fastp_pcie_mac_phy_ch6_  conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch6_rxelecidle_i           input      1         ch6_rxelecidle_i           fastp_pcie_mac_phy_ch6_  conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch6_rxstandbystatus_i      input      1         ch6_rxstandbystatus_i      fastp_pcie_mac_phy_ch6_  conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch6_rxstatus_i             input      3         ch6_rxstatus_i             fastp_pcie_mac_phy_ch6_  conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch6_rxvalid_i              input      1         ch6_rxvalid_i              fastp_pcie_mac_phy_ch6_  conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch6_pclkchangeok_i         input      1         ch6_pclkchangeok_i         fastp_pcie_mac_phy_ch6_  conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch7_messagebus_o           output     8         ch7_messagebus_o           fastp_pcie_mac_phy_ch7_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch7_pclk_rate_o            output     3         ch7_pclk_rate_o            fastp_pcie_mac_phy_ch7_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch7_powerdown_o            output     4         ch7_powerdown_o            fastp_pcie_mac_phy_ch7_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch7_rate_o                 output     3         ch7_rate_o                 fastp_pcie_mac_phy_ch7_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch7_rxstandby_o            output     1         ch7_rxstandby_o            fastp_pcie_mac_phy_ch7_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch7_rxwidth_o              output     2         ch7_rxwidth_o              fastp_pcie_mac_phy_ch7_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch7_txdata_o               output    40         ch7_txdata_o               fastp_pcie_mac_phy_ch7_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch7_txdatavalid_o          output     1         ch7_txdatavalid_o          fastp_pcie_mac_phy_ch7_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch7_txdetectrx_loopback_o  output     1         ch7_txdetectrx_loopback_o  fastp_pcie_mac_phy_ch7_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch7_txelecidle_o           output     4         ch7_txelecidle_o           fastp_pcie_mac_phy_ch7_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch7_width_o                output     2         ch7_width_o                fastp_pcie_mac_phy_ch7_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch7_rxelecidle_disable_o   output     1         ch7_rxelecidle_disable_o   fastp_pcie_mac_phy_ch7_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch7_txcmnmode_disable_o    output     1         ch7_txcmnmode_disable_o    fastp_pcie_mac_phy_ch7_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch7_rxtermination_o        output     1         ch7_rxtermination_o        fastp_pcie_mac_phy_ch7_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch7_srisenable_o           output     1         ch7_srisenable_o           fastp_pcie_mac_phy_ch7_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch7_pclkchangeack_o        output     1         ch7_pclkchangeack_o        fastp_pcie_mac_phy_ch7_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch7_messagebus_i           input      8         ch7_messagebus_i           fastp_pcie_mac_phy_ch7_  conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch7_phystatus_i            input      1         ch7_phystatus_i            fastp_pcie_mac_phy_ch7_  conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch7_rxdata_i               input     40         ch7_rxdata_i               fastp_pcie_mac_phy_ch7_  conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch7_rxelecidle_i           input      1         ch7_rxelecidle_i           fastp_pcie_mac_phy_ch7_  conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch7_rxstandbystatus_i      input      1         ch7_rxstandbystatus_i      fastp_pcie_mac_phy_ch7_  conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch7_rxstatus_i             input      3         ch7_rxstatus_i             fastp_pcie_mac_phy_ch7_  conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch7_rxvalid_i              input      1         ch7_rxvalid_i              fastp_pcie_mac_phy_ch7_  conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch7_pclkchangeok_i         input      1         ch7_pclkchangeok_i         fastp_pcie_mac_phy_ch7_  conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch8_messagebus_o           output     8         ch8_messagebus_o           fastp_pcie_mac_phy_ch8_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch8_pclk_rate_o            output     3         ch8_pclk_rate_o            fastp_pcie_mac_phy_ch8_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch8_powerdown_o            output     4         ch8_powerdown_o            fastp_pcie_mac_phy_ch8_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch8_rate_o                 output     3         ch8_rate_o                 fastp_pcie_mac_phy_ch8_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch8_rxstandby_o            output     1         ch8_rxstandby_o            fastp_pcie_mac_phy_ch8_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch8_rxwidth_o              output     2         ch8_rxwidth_o              fastp_pcie_mac_phy_ch8_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch8_txdata_o               output    40         ch8_txdata_o               fastp_pcie_mac_phy_ch8_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch8_txdatavalid_o          output     1         ch8_txdatavalid_o          fastp_pcie_mac_phy_ch8_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch8_txdetectrx_loopback_o  output     1         ch8_txdetectrx_loopback_o  fastp_pcie_mac_phy_ch8_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch8_txelecidle_o           output     4         ch8_txelecidle_o           fastp_pcie_mac_phy_ch8_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch8_width_o                output     2         ch8_width_o                fastp_pcie_mac_phy_ch8_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch8_rxelecidle_disable_o   output     1         ch8_rxelecidle_disable_o   fastp_pcie_mac_phy_ch8_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch8_txcmnmode_disable_o    output     1         ch8_txcmnmode_disable_o    fastp_pcie_mac_phy_ch8_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch8_rxtermination_o        output     1         ch8_rxtermination_o        fastp_pcie_mac_phy_ch8_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch8_srisenable_o           output     1         ch8_srisenable_o           fastp_pcie_mac_phy_ch8_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch8_pclkchangeack_o        output     1         ch8_pclkchangeack_o        fastp_pcie_mac_phy_ch8_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch8_messagebus_i           input      8         ch8_messagebus_i           fastp_pcie_phy_mac_ch8_  conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch8_phystatus_i            input      1         ch8_phystatus_i            fastp_pcie_phy_mac_ch8_  conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch8_rxdata_i               input     40         ch8_rxdata_i               fastp_pcie_phy_mac_ch8_  conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch8_rxelecidle_i           input      1         ch8_rxelecidle_i           fastp_pcie_phy_mac_ch8_  conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch8_rxstandbystatus_i      input      1         ch8_rxstandbystatus_i      fastp_pcie_phy_mac_ch8_  conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch8_rxstatus_i             input      3         ch8_rxstatus_i             fastp_pcie_phy_mac_ch8_  conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch8_rxvalid_i              input      1         ch8_rxvalid_i              fastp_pcie_phy_mac_ch8_  conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch8_pclkchangeok_i         input      1         ch8_pclkchangeok_i         fastp_pcie_phy_mac_ch8_  conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch9_messagebus_o           output     8         ch9_messagebus_o           fastp_pcie_mac_phy_ch9_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch9_pclk_rate_o            output     3         ch9_pclk_rate_o            fastp_pcie_mac_phy_ch9_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch9_powerdown_o            output     4         ch9_powerdown_o            fastp_pcie_mac_phy_ch9_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch9_rate_o                 output     3         ch9_rate_o                 fastp_pcie_mac_phy_ch9_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch9_rxstandby_o            output     1         ch9_rxstandby_o            fastp_pcie_mac_phy_ch9_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch9_rxwidth_o              output     2         ch9_rxwidth_o              fastp_pcie_mac_phy_ch9_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch9_txdata_o               output    40         ch9_txdata_o               fastp_pcie_mac_phy_ch9_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch9_txdatavalid_o          output     1         ch9_txdatavalid_o          fastp_pcie_mac_phy_ch9_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch9_txdetectrx_loopback_o  output     1         ch9_txdetectrx_loopback_o  fastp_pcie_mac_phy_ch9_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch9_txelecidle_o           output     4         ch9_txelecidle_o           fastp_pcie_mac_phy_ch9_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch9_width_o                output     2         ch9_width_o                fastp_pcie_mac_phy_ch9_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch9_rxelecidle_disable_o   output     1         ch9_rxelecidle_disable_o   fastp_pcie_mac_phy_ch9_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch9_txcmnmode_disable_o    output     1         ch9_txcmnmode_disable_o    fastp_pcie_mac_phy_ch9_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch9_rxtermination_o        output     1         ch9_rxtermination_o        fastp_pcie_mac_phy_ch9_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch9_srisenable_o           output     1         ch9_srisenable_o           fastp_pcie_mac_phy_ch9_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch9_pclkchangeack_o        output     1         ch9_pclkchangeack_o        fastp_pcie_mac_phy_ch9_  conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch9_messagebus_i           input      8         ch9_messagebus_i           fastp_pcie_phy_mac_ch9_  conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch9_phystatus_i            input      1         ch9_phystatus_i            fastp_pcie_phy_mac_ch9_  conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch9_rxdata_i               input     40         ch9_rxdata_i               fastp_pcie_phy_mac_ch9_  conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch9_rxelecidle_i           input      1         ch9_rxelecidle_i           fastp_pcie_phy_mac_ch9_  conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch9_rxstandbystatus_i      input      1         ch9_rxstandbystatus_i      fastp_pcie_phy_mac_ch9_  conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch9_rxstatus_i             input      3         ch9_rxstatus_i             fastp_pcie_phy_mac_ch9_  conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch9_rxvalid_i              input      1         ch9_rxvalid_i              fastp_pcie_phy_mac_ch9_  conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch9_pclkchangeok_i         input      1         ch9_pclkchangeok_i         fastp_pcie_phy_mac_ch9_  conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch10_messagebus_o          output     8         ch10_messagebus_o          fastp_pcie_mac_phy_ch10_ conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch10_pclk_rate_o           output     3         ch10_pclk_rate_o           fastp_pcie_mac_phy_ch10_ conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch10_powerdown_o           output     4         ch10_powerdown_o           fastp_pcie_mac_phy_ch10_ conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch10_rate_o                output     3         ch10_rate_o                fastp_pcie_mac_phy_ch10_ conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch10_rxstandby_o           output     1         ch10_rxstandby_o           fastp_pcie_mac_phy_ch10_ conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch10_rxwidth_o             output     2         ch10_rxwidth_o             fastp_pcie_mac_phy_ch10_ conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch10_txdata_o              output    40         ch10_txdata_o              fastp_pcie_mac_phy_ch10_ conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch10_txdatavalid_o         output     1         ch10_txdatavalid_o         fastp_pcie_mac_phy_ch10_ conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch10_txdetectrx_loopback_o output     1         ch10_txdetectrx_loopback_o fastp_pcie_mac_phy_ch10_ conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch10_txelecidle_o          output     4         ch10_txelecidle_o          fastp_pcie_mac_phy_ch10_ conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch10_width_o               output     2         ch10_width_o               fastp_pcie_mac_phy_ch10_ conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch10_rxelecidle_disable_o  output     1         ch10_rxelecidle_disable_o  fastp_pcie_mac_phy_ch10_ conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch10_txcmnmode_disable_o   output     1         ch10_txcmnmode_disable_o   fastp_pcie_mac_phy_ch10_ conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch10_rxtermination_o       output     1         ch10_rxtermination_o       fastp_pcie_mac_phy_ch10_ conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch10_srisenable_o          output     1         ch10_srisenable_o          fastp_pcie_mac_phy_ch10_ conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch10_pclkchangeack_o       output     1         ch10_pclkchangeack_o       fastp_pcie_mac_phy_ch10_ conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch10_messagebus_i          input      8         ch10_messagebus_i          fastp_pcie_phy_mac_ch10_ conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch10_phystatus_i           input      1         ch10_phystatus_i           fastp_pcie_phy_mac_ch10_ conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch10_rxdata_i              input     40         ch10_rxdata_i              fastp_pcie_phy_mac_ch10_ conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch10_rxelecidle_i          input      1         ch10_rxelecidle_i          fastp_pcie_phy_mac_ch10_ conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch10_rxstandbystatus_i     input      1         ch10_rxstandbystatus_i     fastp_pcie_phy_mac_ch10_ conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch10_rxstatus_i            input      3         ch10_rxstatus_i            fastp_pcie_phy_mac_ch10_ conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch10_rxvalid_i             input      1         ch10_rxvalid_i             fastp_pcie_phy_mac_ch10_ conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch10_pclkchangeok_i        input      1         ch10_pclkchangeok_i        fastp_pcie_phy_mac_ch10_ conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch11_messagebus_o          output     8         ch11_messagebus_o          fastp_pcie_mac_phy_ch11_ conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch11_pclk_rate_o           output     3         ch11_pclk_rate_o           fastp_pcie_mac_phy_ch11_ conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch11_powerdown_o           output     4         ch11_powerdown_o           fastp_pcie_mac_phy_ch11_ conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch11_rate_o                output     3         ch11_rate_o                fastp_pcie_mac_phy_ch11_ conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch11_rxstandby_o           output     1         ch11_rxstandby_o           fastp_pcie_mac_phy_ch11_ conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch11_rxwidth_o             output     2         ch11_rxwidth_o             fastp_pcie_mac_phy_ch11_ conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch11_txdata_o              output    40         ch11_txdata_o              fastp_pcie_mac_phy_ch11_ conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch11_txdatavalid_o         output     1         ch11_txdatavalid_o         fastp_pcie_mac_phy_ch11_ conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch11_txdetectrx_loopback_o output     1         ch11_txdetectrx_loopback_o fastp_pcie_mac_phy_ch11_ conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch11_txelecidle_o          output     4         ch11_txelecidle_o          fastp_pcie_mac_phy_ch11_ conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch11_width_o               output     2         ch11_width_o               fastp_pcie_mac_phy_ch11_ conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch11_rxelecidle_disable_o  output     1         ch11_rxelecidle_disable_o  fastp_pcie_mac_phy_ch11_ conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch11_txcmnmode_disable_o   output     1         ch11_txcmnmode_disable_o   fastp_pcie_mac_phy_ch11_ conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch11_rxtermination_o       output     1         ch11_rxtermination_o       fastp_pcie_mac_phy_ch11_ conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch11_srisenable_o          output     1         ch11_srisenable_o          fastp_pcie_mac_phy_ch11_ conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch11_pclkchangeack_o       output     1         ch11_pclkchangeack_o       fastp_pcie_mac_phy_ch11_ conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch11_messagebus_i          input      8         ch11_messagebus_i          fastp_pcie_phy_mac_ch11_ conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch11_phystatus_i           input      1         ch11_phystatus_i           fastp_pcie_phy_mac_ch11_ conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch11_rxdata_i              input     40         ch11_rxdata_i              fastp_pcie_phy_mac_ch11_ conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch11_rxelecidle_i          input      1         ch11_rxelecidle_i          fastp_pcie_phy_mac_ch11_ conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch11_rxstandbystatus_i     input      1         ch11_rxstandbystatus_i     fastp_pcie_phy_mac_ch11_ conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch11_rxstatus_i            input      3         ch11_rxstatus_i            fastp_pcie_phy_mac_ch11_ conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch11_rxvalid_i             input      1         ch11_rxvalid_i             fastp_pcie_phy_mac_ch11_ conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch11_pclkchangeok_i        input      1         ch11_pclkchangeok_i        fastp_pcie_phy_mac_ch11_ conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch12_messagebus_o          output     8         ch12_messagebus_o          fastp_pcie_mac_phy_ch12_ conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch12_pclk_rate_o           output     3         ch12_pclk_rate_o           fastp_pcie_mac_phy_ch12_ conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch12_powerdown_o           output     4         ch12_powerdown_o           fastp_pcie_mac_phy_ch12_ conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch12_rate_o                output     3         ch12_rate_o                fastp_pcie_mac_phy_ch12_ conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch12_rxstandby_o           output     1         ch12_rxstandby_o           fastp_pcie_mac_phy_ch12_ conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch12_rxwidth_o             output     2         ch12_rxwidth_o             fastp_pcie_mac_phy_ch12_ conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch12_txdata_o              output    40         ch12_txdata_o              fastp_pcie_mac_phy_ch12_ conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch12_txdatavalid_o         output     1         ch12_txdatavalid_o         fastp_pcie_mac_phy_ch12_ conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch12_txdetectrx_loopback_o output     1         ch12_txdetectrx_loopback_o fastp_pcie_mac_phy_ch12_ conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch12_txelecidle_o          output     4         ch12_txelecidle_o          fastp_pcie_mac_phy_ch12_ conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch12_width_o               output     2         ch12_width_o               fastp_pcie_mac_phy_ch12_ conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch12_rxelecidle_disable_o  output     1         ch12_rxelecidle_disable_o  fastp_pcie_mac_phy_ch12_ conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch12_txcmnmode_disable_o   output     1         ch12_txcmnmode_disable_o   fastp_pcie_mac_phy_ch12_ conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch12_rxtermination_o       output     1         ch12_rxtermination_o       fastp_pcie_mac_phy_ch12_ conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch12_srisenable_o          output     1         ch12_srisenable_o          fastp_pcie_mac_phy_ch12_ conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch12_pclkchangeack_o       output     1         ch12_pclkchangeack_o       fastp_pcie_mac_phy_ch12_ conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch12_messagebus_i          input      8         ch12_messagebus_i          fastp_pcie_phy_mac_ch12_ conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch12_phystatus_i           input      1         ch12_phystatus_i           fastp_pcie_phy_mac_ch12_ conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch12_rxdata_i              input     40         ch12_rxdata_i              fastp_pcie_phy_mac_ch12_ conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch12_rxelecidle_i          input      1         ch12_rxelecidle_i          fastp_pcie_phy_mac_ch12_ conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch12_rxstandbystatus_i     input      1         ch12_rxstandbystatus_i     fastp_pcie_phy_mac_ch12_ conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch12_rxstatus_i            input      3         ch12_rxstatus_i            fastp_pcie_phy_mac_ch12_ conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch12_rxvalid_i             input      1         ch12_rxvalid_i             fastp_pcie_phy_mac_ch12_ conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch12_pclkchangeok_i        input      1         ch12_pclkchangeok_i        fastp_pcie_phy_mac_ch12_ conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch13_messagebus_o          output     8         ch13_messagebus_o          fastp_pcie_mac_phy_ch13_ conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch13_pclk_rate_o           output     3         ch13_pclk_rate_o           fastp_pcie_mac_phy_ch13_ conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch13_powerdown_o           output     4         ch13_powerdown_o           fastp_pcie_mac_phy_ch13_ conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch13_rate_o                output     3         ch13_rate_o                fastp_pcie_mac_phy_ch13_ conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch13_rxstandby_o           output     1         ch13_rxstandby_o           fastp_pcie_mac_phy_ch13_ conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch13_rxwidth_o             output     2         ch13_rxwidth_o             fastp_pcie_mac_phy_ch13_ conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch13_txdata_o              output    40         ch13_txdata_o              fastp_pcie_mac_phy_ch13_ conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch13_txdatavalid_o         output     1         ch13_txdatavalid_o         fastp_pcie_mac_phy_ch13_ conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch13_txdetectrx_loopback_o output     1         ch13_txdetectrx_loopback_o fastp_pcie_mac_phy_ch13_ conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch13_txelecidle_o          output     4         ch13_txelecidle_o          fastp_pcie_mac_phy_ch13_ conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch13_width_o               output     2         ch13_width_o               fastp_pcie_mac_phy_ch13_ conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch13_rxelecidle_disable_o  output     1         ch13_rxelecidle_disable_o  fastp_pcie_mac_phy_ch13_ conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch13_txcmnmode_disable_o   output     1         ch13_txcmnmode_disable_o   fastp_pcie_mac_phy_ch13_ conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch13_rxtermination_o       output     1         ch13_rxtermination_o       fastp_pcie_mac_phy_ch13_ conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch13_srisenable_o          output     1         ch13_srisenable_o          fastp_pcie_mac_phy_ch13_ conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch13_pclkchangeack_o       output     1         ch13_pclkchangeack_o       fastp_pcie_mac_phy_ch13_ conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch13_messagebus_i          input      8         ch13_messagebus_i          fastp_pcie_phy_mac_ch13_ conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch13_phystatus_i           input      1         ch13_phystatus_i           fastp_pcie_phy_mac_ch13_ conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch13_rxdata_i              input     40         ch13_rxdata_i              fastp_pcie_phy_mac_ch13_ conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch13_rxelecidle_i          input      1         ch13_rxelecidle_i          fastp_pcie_phy_mac_ch13_ conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch13_rxstandbystatus_i     input      1         ch13_rxstandbystatus_i     fastp_pcie_phy_mac_ch13_ conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch13_rxstatus_i            input      3         ch13_rxstatus_i            fastp_pcie_phy_mac_ch13_ conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch13_rxvalid_i             input      1         ch13_rxvalid_i             fastp_pcie_phy_mac_ch13_ conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch13_pclkchangeok_i        input      1         ch13_pclkchangeok_i        fastp_pcie_phy_mac_ch13_ conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch14_messagebus_o          output     8         ch14_messagebus_o          fastp_pcie_mac_phy_ch14_ conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch14_pclk_rate_o           output     3         ch14_pclk_rate_o           fastp_pcie_mac_phy_ch14_ conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch14_powerdown_o           output     4         ch14_powerdown_o           fastp_pcie_mac_phy_ch14_ conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch14_rate_o                output     3         ch14_rate_o                fastp_pcie_mac_phy_ch14_ conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch14_rxstandby_o           output     1         ch14_rxstandby_o           fastp_pcie_mac_phy_ch14_ conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch14_rxwidth_o             output     2         ch14_rxwidth_o             fastp_pcie_mac_phy_ch14_ conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch14_txdata_o              output    40         ch14_txdata_o              fastp_pcie_mac_phy_ch14_ conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch14_txdatavalid_o         output     1         ch14_txdatavalid_o         fastp_pcie_mac_phy_ch14_ conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch14_txdetectrx_loopback_o output     1         ch14_txdetectrx_loopback_o fastp_pcie_mac_phy_ch14_ conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch14_txelecidle_o          output     4         ch14_txelecidle_o          fastp_pcie_mac_phy_ch14_ conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch14_width_o               output     2         ch14_width_o               fastp_pcie_mac_phy_ch14_ conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch14_rxelecidle_disable_o  output     1         ch14_rxelecidle_disable_o  fastp_pcie_mac_phy_ch14_ conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch14_txcmnmode_disable_o   output     1         ch14_txcmnmode_disable_o   fastp_pcie_mac_phy_ch14_ conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch14_rxtermination_o       output     1         ch14_rxtermination_o       fastp_pcie_mac_phy_ch14_ conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch14_srisenable_o          output     1         ch14_srisenable_o          fastp_pcie_mac_phy_ch14_ conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch14_pclkchangeack_o       output     1         ch14_pclkchangeack_o       fastp_pcie_mac_phy_ch14_ conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch14_messagebus_i          input      8         ch14_messagebus_i          fastp_pcie_phy_mac_ch14_ conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch14_phystatus_i           input      1         ch14_phystatus_i           fastp_pcie_phy_mac_ch14_ conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch14_rxdata_i              input     40         ch14_rxdata_i              fastp_pcie_phy_mac_ch14_ conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch14_rxelecidle_i          input      1         ch14_rxelecidle_i          fastp_pcie_phy_mac_ch14_ conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch14_rxstandbystatus_i     input      1         ch14_rxstandbystatus_i     fastp_pcie_phy_mac_ch14_ conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch14_rxstatus_i            input      3         ch14_rxstatus_i            fastp_pcie_phy_mac_ch14_ conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch14_rxvalid_i             input      1         ch14_rxvalid_i             fastp_pcie_phy_mac_ch14_ conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch14_pclkchangeok_i        input      1         ch14_pclkchangeok_i        fastp_pcie_phy_mac_ch14_ conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch15_messagebus_o          output     8         ch15_messagebus_o          fastp_pcie_mac_phy_ch15_ conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch15_pclk_rate_o           output     3         ch15_pclk_rate_o           fastp_pcie_mac_phy_ch15_ conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch15_powerdown_o           output     4         ch15_powerdown_o           fastp_pcie_mac_phy_ch15_ conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch15_rate_o                output     3         ch15_rate_o                fastp_pcie_mac_phy_ch15_ conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch15_rxstandby_o           output     1         ch15_rxstandby_o           fastp_pcie_mac_phy_ch15_ conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch15_rxwidth_o             output     2         ch15_rxwidth_o             fastp_pcie_mac_phy_ch15_ conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch15_txdata_o              output    40         ch15_txdata_o              fastp_pcie_mac_phy_ch15_ conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch15_txdatavalid_o         output     1         ch15_txdatavalid_o         fastp_pcie_mac_phy_ch15_ conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch15_txdetectrx_loopback_o output     1         ch15_txdetectrx_loopback_o fastp_pcie_mac_phy_ch15_ conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch15_txelecidle_o          output     4         ch15_txelecidle_o          fastp_pcie_mac_phy_ch15_ conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch15_width_o               output     2         ch15_width_o               fastp_pcie_mac_phy_ch15_ conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch15_rxelecidle_disable_o  output     1         ch15_rxelecidle_disable_o  fastp_pcie_mac_phy_ch15_ conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch15_txcmnmode_disable_o   output     1         ch15_txcmnmode_disable_o   fastp_pcie_mac_phy_ch15_ conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch15_rxtermination_o       output     1         ch15_rxtermination_o       fastp_pcie_mac_phy_ch15_ conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch15_srisenable_o          output     1         ch15_srisenable_o          fastp_pcie_mac_phy_ch15_ conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_mac_phy_ch15_pclkchangeack_o       output     1         ch15_pclkchangeack_o       fastp_pcie_mac_phy_ch15_ conduit    source          "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch15_pclkchangeok_i        input      1         ch15_pclkchangeok_i        fastp_pcie_phy_mac_ch15_ conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch15_messagebus_i          input      8         ch15_messagebus_i          fastp_pcie_phy_mac_ch15_ conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch15_phystatus_i           input      1         ch15_phystatus_i           fastp_pcie_phy_mac_ch15_ conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch15_rxdata_i              input     40         ch15_rxdata_i              fastp_pcie_phy_mac_ch15_ conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch15_rxelecidle_i          input      1         ch15_rxelecidle_i          fastp_pcie_phy_mac_ch15_ conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch15_rxstandbystatus_i     input      1         ch15_rxstandbystatus_i     fastp_pcie_phy_mac_ch15_ conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch15_rxstatus_i            input      3         ch15_rxstatus_i            fastp_pcie_phy_mac_ch15_ conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_ch15_rxvalid_i             input      1         ch15_rxvalid_i             fastp_pcie_phy_mac_ch15_ conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_rx0_clk_i                  input      1         rx0_clk_i                  fastp_pcie_phy_mac_      conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_rx1_clk_i                  input      1         rx1_clk_i                  fastp_pcie_phy_mac_      conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_rx2_clk_i                  input      1         rx2_clk_i                  fastp_pcie_phy_mac_      conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_rx3_clk_i                  input      1         rx3_clk_i                  fastp_pcie_phy_mac_      conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_rx4_clk_i                  input      1         rx4_clk_i                  fastp_pcie_phy_mac_      conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_rx5_clk_i                  input      1         rx5_clk_i                  fastp_pcie_phy_mac_      conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_rx6_clk_i                  input      1         rx6_clk_i                  fastp_pcie_phy_mac_      conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_rx7_clk_i                  input      1         rx7_clk_i                  fastp_pcie_phy_mac_      conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_rx8_clk_i                  input      1         rx8_clk_i                  fastp_pcie_phy_mac_      conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_rx9_clk_i                  input      1         rx9_clk_i                  fastp_pcie_phy_mac_      conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_rx10_clk_i                 input      1         rx10_clk_i                 fastp_pcie_phy_mac_      conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_rx11_clk_i                 input      1         rx11_clk_i                 fastp_pcie_phy_mac_      conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_rx12_clk_i                 input      1         rx12_clk_i                 fastp_pcie_phy_mac_      conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_rx13_clk_i                 input      1         rx13_clk_i                 fastp_pcie_phy_mac_      conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_rx14_clk_i                 input      1         rx14_clk_i                 fastp_pcie_phy_mac_      conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
	{ fastp_pcie_phy_mac_rx15_clk_i                 input      1         rx15_clk_i                 fastp_pcie_phy_mac_      conduit    sink            "!pipemode_sim_ed_hwtcl || tile_integer != 2"                                                                                    0                 NOVAL                                                            "Check User Guide for details"                                   }\
   }

    proc ::intel_pcie_ss_axi::interfaces::declare_interfaces {} {
        variable intel_pcie_ss_axi_interfaces
        variable ftile_interfaces_pipemode
        variable rtile_interfaces_pipemode
        
        ip_declare_interfaces $intel_pcie_ss_axi_interfaces
        ip_declare_interfaces $ftile_interfaces_pipemode
        ip_declare_interfaces $rtile_interfaces_pipemode
    }

    # TODO - define complete interface elaboration
    proc ::intel_pcie_ss_axi::interfaces::elaborate {} {
        variable intel_pcie_ss_axi_interfaces

        ip_declare_interfaces $intel_pcie_ss_axi_interfaces

        ip_elaborate_interfaces

	set syspll_en [get_parameter_value syspll_enabled_hwtcl]
	set tile [get_parameter_value TILE]
    set true_independent_support_mode_hwtcl [get_parameter_value true_independent_support_mode_hwtcl]
    set silicon_revc_fm41_hwtcl [get_parameter_value silicon_revc_fm41_hwtcl]
        set core16_func_mode_integer_hwtcl [get_parameter_value core16_func_mode_integer_hwtcl]
        set core8_func_mode_integer_hwtcl [get_parameter_value core8_func_mode_integer_hwtcl]
        set independent_perst_int_hwtcl [get_parameter_value independent_perst_int_hwtcl]
        
    if {$tile == "R-TILE"} {
        #vww27 added 
		add_interface refclk0 clock sink
		add_interface_port refclk0 refclk0 clock input 1	
		add_interface refclk1 clock sink
		add_interface_port refclk1 refclk1 clock input 1

		
		set_interface_property refclk0         clockRate 100000000
        set_interface_property refclk1         clockRate 100000000
        
		set_port_property refclk0 ROLE clk
		set_port_property refclk1 ROLE clk

		set_port_property refclk0 TERMINATION false
		set_port_property refclk1 TERMINATION false

        set_port_property refclk0 DESCRIPTION "Check User Guide for details"
        set_port_property refclk1 DESCRIPTION "Check User Guide for details"
        
        add_interface refclk2 clock sink
		add_interface_port refclk2 refclk2 clock input 1
		set_interface_property refclk2         clockRate 100000000
		set_port_property refclk2 ROLE clk
		set_port_property refclk2 DESCRIPTION "Check User Guide for details"

		if {$true_independent_support_mode_hwtcl == 1} {
            set_port_property refclk2 TERMINATION false
        } else {
            set_port_property refclk2 TERMINATION true
        }
        
            add_interface pin_perst0_n reset sink
            add_interface_port pin_perst0_n pin_perst0_n reset input 1
            set_port_property pin_perst0_n ROLE reset
            set_port_property pin_perst0_n DESCRIPTION "Check User Guide for details"
            set_port_property pin_perst0_n TERMINATION_VALUE 1
            
            add_interface pin_perst1_n reset sink
            add_interface_port pin_perst1_n pin_perst1_n reset input 1
            set_port_property pin_perst1_n ROLE reset
            set_port_property pin_perst1_n DESCRIPTION "Check User Guide for details"
            set_port_property pin_perst1_n TERMINATION_VALUE 1
            
            add_interface p0_warm_perst_n reset sink
            add_interface_port p0_warm_perst_n p0_warm_perst_n_i reset_n input 1
            set_port_property p0_warm_perst_n_i ROLE reset
            set_port_property p0_warm_perst_n_i DESCRIPTION "Check User Guide for details"
            set_port_property p0_warm_perst_n_i TERMINATION_VALUE 1
            
            add_interface p1_warm_perst_n reset sink
            add_interface_port p1_warm_perst_n p1_warm_perst_n_i reset_n input 1
            set_port_property p1_warm_perst_n_i ROLE reset
            set_port_property p1_warm_perst_n_i DESCRIPTION "Check User Guide for details"
            set_port_property p1_warm_perst_n_i TERMINATION_VALUE 1
            
            add_interface p0_ip_rst_n_o reset source
            add_interface_port p0_ip_rst_n_o p0_ip_rst_n_o reset_n output 1
            set_port_property p0_ip_rst_n_o ROLE reset
            set_port_property p0_ip_rst_n_o DESCRIPTION "Check User Guide for details"
            set_port_property p0_ip_rst_n_o TERMINATION_VALUE 1
            
            add_interface p1_ip_rst_n_o reset source
            add_interface_port p1_ip_rst_n_o p1_ip_rst_n_o reset_n output 1
            set_port_property p1_ip_rst_n_o ROLE reset
            set_port_property p1_ip_rst_n_o DESCRIPTION "Check User Guide for details"
            set_port_property p1_ip_rst_n_o TERMINATION_VALUE 1
            
            if {$true_independent_support_mode_hwtcl == 1 && $silicon_revc_fm41_hwtcl == 1} {
                set_port_property pin_perst0_n TERMINATION false
                set_port_property pin_perst1_n TERMINATION false
            } else {
                set_port_property pin_perst0_n TERMINATION true
                set_port_property pin_perst1_n TERMINATION true
            }
            
            if {$core16_func_mode_integer_hwtcl == 1 && $independent_perst_int_hwtcl == 1} {
                set_port_property p0_warm_perst_n_i TERMINATION false
                set_port_property p0_ip_rst_n_o TERMINATION false
                
            } else {
                set_port_property p0_warm_perst_n_i TERMINATION true
                set_port_property p0_ip_rst_n_o TERMINATION true
            }
            
            if {$core8_func_mode_integer_hwtcl == 1 && $independent_perst_int_hwtcl == 1} {
                set_port_property p1_warm_perst_n_i TERMINATION false
                set_port_property p1_ip_rst_n_o TERMINATION false
            } else {
                set_port_property p1_warm_perst_n_i TERMINATION true
                set_port_property p1_ip_rst_n_o TERMINATION true
            }
            
            set_interface_property pin_perst0_n synchronousEdges none
            set_interface_property pin_perst1_n synchronousEdges none
            set_interface_property p0_warm_perst_n synchronousEdges none
            set_interface_property p1_warm_perst_n synchronousEdges none
            set_interface_property p0_ip_rst_n_o synchronousEdges none
            set_interface_property p1_ip_rst_n_o synchronousEdges none
            
            set_interface_property p0_ip_rst_n_o associatedResetSinks pin_perst0_n
            set_interface_property p1_ip_rst_n_o associatedResetSinks pin_perst1_n
            
    } elseif {$tile == "P-TILE"} {

		#vww27 added 
		add_interface refclk0 clock sink
		add_interface_port refclk0 refclk0 clock input 1	
		add_interface refclk1 clock sink
		add_interface_port refclk1 refclk1 clock input 1
		
		set_interface_property refclk0         clockRate 100000000
        set_interface_property refclk1         clockRate 100000000
		set_port_property refclk0 ROLE clk
		set_port_property refclk1 ROLE clk
		set_port_property refclk0 TERMINATION false
		set_port_property refclk1 TERMINATION false
            	set_port_property refclk0 DESCRIPTION "Check User Guide for details"
            	set_port_property refclk1 DESCRIPTION "Check User Guide for details"

	} elseif {$tile == "F-TILE"} {

	    if {$syspll_en == 1} {
	   	#vww27 added
	   	add_interface refclk0 conduit sink
		add_interface_port refclk0 refclk0 conduit input 1	
		add_interface refclk1 conduit sink
		add_interface_port refclk1 refclk1 conduit input 1		
	
		#set_interface_property refclk0         clockRate 100000000
       	 	#set_interface_property refclk1         clockRate 100000000
		set_port_property refclk0 ROLE clk
		set_port_property refclk1 ROLE clk
		set_port_property refclk0 TERMINATION false
		set_port_property refclk1 TERMINATION false
		#set_port_property refclk0 DESCRIPTION "<html>Refclk for SystemPLL and PCIe PHY. Connect a refclk output \"out_refclk_fgt_<i>i</i>\" from the \"F-Tile Reference and SystemPLL Clocks\" IP to this port.</html>"
            	#set_port_property refclk1 DESCRIPTION "<html>Refclk for PCIe1 PHY in 2x8 topology. Drive this input with the same clock for refclk0 input port, if:<br>- Your design does not need a separate refclk, or<br>- You are not using 2x8 topology.</html>"
		
            } elseif {$syspll_en == 0} {
		
		#vww27 added
	   	add_interface refclk0 ftile_hssi_reference_clock sink
		add_interface_port refclk0 refclk0 ftile_hssi_reference_clock input 1	
		add_interface refclk1 ftile_hssi_reference_clock sink
		add_interface_port refclk1 refclk1 ftile_hssi_reference_clock input 1		
	
		#set_interface_property refclk0         clockRate 100000000
       	 	#set_interface_property refclk1         clockRate 100000000
		set_port_property refclk0 ROLE clk
		set_port_property refclk1 ROLE clk
		set_port_property refclk0 TERMINATION false
		set_port_property refclk1 TERMINATION false
		#set_port_property refclk0 DESCRIPTION "<html>Refclk for SystemPLL and PCIe PHY. Connect a refclk output \"out_refclk_fgt_<i>i</i>\" from the \"F-Tile Reference and SystemPLL Clocks\" IP to this port.</html>"
            	#set_port_property refclk1 DESCRIPTION "<html>Refclk for PCIe1 PHY in 2x8 topology. Drive this input with the same clock for refclk0 input port, if:<br>- Your design does not need a separate refclk, or<br>- You are not using 2x8 topology.</html>"			

          }
	}
    }
    proc ::intel_pcie_ss_axi::interfaces::elaborate_hip_port_clks {} {
        # set top_topology_hwtcl                      [ip_get "parameter.top_topology_hwtcl.value"]
         set pld_clkfreq_integer_hwtcl               [ip_get "parameter.pld_clkfreq_integer_hwtcl.value"]
        # if { [regexp "x16" $top_topology_hwtcl] } {
            # set core_num 1
        # } elseif { [regexp "x8" $top_topology_hwtcl] } {
            # set core_num 2
        # } elseif { [regexp "x4" $top_topology_hwtcl] } {
            # set core_num 4
        # }
        
        set_interface_property coreclkout_hip_toapp clockRate [expr {$pld_clkfreq_integer_hwtcl * 1000000}]
        set_interface_property coreclkout_hip_toapp clockRateKnown 1
        
        
    }

    #vww16 added, ww19 removed
    proc ::intel_pcie_ss_axi::interfaces::elaborate_txrx_ports {} {
        set tile [ip_get "parameter.TILE.value"]
        if {$tile == "F-TILE"} { 
            set txrxports {{tx_n_out} {tx_p_out} {rx_n_in} {rx_p_in}}
            foreach ports $txrxports {
            for { set a 4}  {$a < 8} {incr a} {
                set port "$ports$a"
                set_port_property $port TERMINATION "!(top_topology_integer_hwtcl != 3)"
            }
            
            for { set b 8}  {$b < 16} {incr b} {
                set port "$ports$b"
                set_port_property $port TERMINATION "!(top_topology_integer_hwtcl < 3)"
            }
            }

        } elseif {$tile == "P-TILE"} {
            set txrxports {{tx_n_out} {tx_p_out} {rx_n_in} {rx_p_in}}
            foreach ports $txrxports {
            for { set a 4}  {$a < 16} {incr a} {
                set port "$ports$a"
                set_port_property $port TERMINATION "false"
            }

            }
        }
    }



    
    proc ::intel_pcie_ss_axi::interfaces::elaborate_refclk {} {
        set_interface_property refclk0         clockRate 100000000
        set_interface_property refclk1         clockRate 100000000

        #vww16 added
	#vww17 commented 
        set tile [ip_get "parameter.TILE.value"]
	set syspll_en [ip_get "parameter.syspll_enabled_hwtcl.value"]

        if {$tile == "F-TILE"} {
            #set_port_property refclk0 IFACE_TYPE "ftile_hssi_reference_clock"
            set_port_property refclk0 DESCRIPTION "<html>Refclk for SystemPLL and PCIe PHY. Connect a refclk output \"out_refclk_fgt_<i>i</i>\" from the \"F-Tile Reference and SystemPLL Clocks\" IP to this port.</html>"
            #set_port_property refclk1 IFACE_TYPE "ftile_hssi_reference_clock"
            set_port_property refclk1 DESCRIPTION "<html>Refclk for PCIe1 PHY in 2x8 topology. Drive this input with the same clock for refclk0 input port, if:<br>- Your design does not need a separate refclk, or<br>- You are not using 2x8 topology.</html>"
		
		if {$syspll_en == 0} {
						
			add_interface refclk0 ftile_hssi_reference_clock sink
			add_interface_port refclk0 refclk0 ftile_hssi_reference_clock input 1	
			add_interface refclk1 ftile_hssi_reference_clock sink
			add_interface_port refclk1 refclk1 ftile_hssi_reference_clock input 1		

		} elseif {$syspll_en == 1} {
			
			add_interface refclk0 clock sink
			add_interface_port refclk0 refclk0 clock input 1	
			add_interface refclk1 clock sink
			add_interface_port refclk1 refclk1 clock input 1

		}

        } elseif {$tile == "P-TILE" || $tile == "R-TILE"} {
            #set_port_property refclk0 IFACE_TYPE "clock"
            set_port_property refclk0 DESCRIPTION "Check User Guide for details"
            #set_port_property refclk1 IFACE_TYPE "clock"
            set_port_property refclk1 DESCRIPTION "Check User Guide for details"
       
        }


    }

    proc ::intel_pcie_ss_axi::interfaces::elaborate_ninit_done {} {
	set_interface_property ninit_done synchronousEdges none
    }

    proc ::intel_pcie_ss_axi::interfaces::elaborate_pin_perst_n {} {
    set_interface_property pin_perst_n synchronousEdges none
     #C0
    #set_interface_property pin_perst0_n synchronousEdges none
    #set_interface_property pin_perst1_n synchronousEdges none
            set top_topology_hwtcl                      [ip_get "parameter.top_topology_hwtcl.value"]         
            if { [regexp "x16" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "x8" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "x4" $top_topology_hwtcl] } {
                set core_num 4
            }            
            for { set i 0 } { $i < [expr $core_num] } { incr i } {
                  set_interface_property p${i}_pin_perst_n synchronousEdges none
                  set_interface_property p${i}_pin_perst_n associatedResetSinks none                  
            }
    }
    
    proc ::intel_pcie_ss_axi::interfaces::elaborate_reset_status_n {} {
        set tile [ip_get "parameter.TILE.value"]
        if {$tile == "P-TILE" || $tile == "R-TILE"} {

            set top_topology_hwtcl                      [ip_get "parameter.top_topology_hwtcl.value"]
            set xcvr_reconfig_hwtcl                     [ip_get "parameter.xcvr_reconfig_hwtcl.value"]
            set core16_hip_reconfig_hwtcl               [ip_get "parameter.core16_hip_reconfig_hwtcl.value"] 
            set core8_hip_reconfig_hwtcl                [ip_get "parameter.core8_hip_reconfig_hwtcl.value"]
            set core4_0_hip_reconfig_hwtcl              [ip_get "parameter.core4_0_hip_reconfig_hwtcl.value"] 
            set core4_1_hip_reconfig_hwtcl              [ip_get "parameter.core4_1_hip_reconfig_hwtcl.value"]
            set core16_enable_cpl_timeout_hwtcl         [ip_get "parameter.core16_enable_cpl_timeout_hwtcl.value"]
            set core8_enable_cpl_timeout_hwtcl          [ip_get "parameter.core8_enable_cpl_timeout_hwtcl.value"]
            set core4_0_enable_cpl_timeout_hwtcl        [ip_get "parameter.core4_0_enable_cpl_timeout_hwtcl.value"]
            set core4_1_enable_cpl_timeout_hwtcl        [ip_get "parameter.core4_1_enable_cpl_timeout_hwtcl.value"]

            if { [regexp "x16" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "x8" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "x4" $top_topology_hwtcl] } {
                set core_num 4
            }
            
            for { set i 0 } { $i < [expr $core_num] } { incr i } {
                set_interface_property p${i}_reset_status_n associatedClock coreclkout_hip_toapp
                set_interface_property p${i}_reset_status_n synchronousEdges both
                set_interface_property p${i}_reset_status_n associatedResetSinks none
                #if {$xcvr_reconfig_hwtcl || $core16_hip_reconfig_hwtcl || $core8_hip_reconfig_hwtcl || $core4_0_hip_reconfig_hwtcl || $core4_1_hip_reconfig_hwtcl || \
                #    $core16_enable_cpl_timeout_hwtcl || $core8_enable_cpl_timeout_hwtcl || $core4_0_enable_cpl_timeout_hwtcl || $core4_1_enable_cpl_timeout_hwtcl} {
                #    set_interface_property p${i}_reset_status_n associatedResetSinks none
                #}
            }
         } elseif {$tile == "F-TILE"} {

            	set top_topology_hwtcl                      [ip_get "parameter.top_topology_hwtcl.value"]
                set xcvr_reconfig_hwtcl                     [ip_get "parameter.xcvr_reconfig_hwtcl.value"]
                set core16_hip_reconfig_hwtcl               [ip_get "parameter.core16_hip_reconfig_hwtcl.value"] 
                set core8_hip_reconfig_hwtcl                [ip_get "parameter.core8_hip_reconfig_hwtcl.value"]
                set core4_0_hip_reconfig_hwtcl              [ip_get "parameter.core4_0_hip_reconfig_hwtcl.value"] 
                set core4_1_hip_reconfig_hwtcl              [ip_get "parameter.core4_1_hip_reconfig_hwtcl.value"]

                if { [regexp "1x16" $top_topology_hwtcl] } {
                    set core_num 1
                } elseif { [regexp "2x8" $top_topology_hwtcl] } {
                    set core_num 2
                } elseif { [regexp "4x4" $top_topology_hwtcl] } {
                    set core_num 4
                } elseif { [regexp "1x4" $top_topology_hwtcl] } {
                    set core_num 1
                } elseif { [regexp "2x4" $top_topology_hwtcl] } {
                    set core_num 2
                } elseif { [regexp "1x8" $top_topology_hwtcl] } {
                    set core_num 1
                }

                if { [regexp "2x4" $top_topology_hwtcl] } {
                set_interface_property p0_reset_status_n associatedClock coreclkout_hip_toapp
                set_interface_property p0_reset_status_n synchronousEdges both
                set_interface_property p2_reset_status_n associatedClock coreclkout_hip_toapp
                set_interface_property p2_reset_status_n synchronousEdges both
                #   if {$xcvr_reconfig_hwtcl || $core16_hip_reconfig_hwtcl || $core8_hip_reconfig_hwtcl || $core4_0_hip_reconfig_hwtcl || $core4_1_hip_reconfig_hwtcl } {
                    set_interface_property p0_reset_status_n associatedResetSinks none
                    set_interface_property p2_reset_status_n associatedResetSinks none
                #    }
                } else {
                for { set i 0 } { $i < [expr $core_num] } { incr i } {
                    set_interface_property p${i}_reset_status_n associatedClock coreclkout_hip_toapp
                    set_interface_property p${i}_reset_status_n synchronousEdges both
                #    if {$xcvr_reconfig_hwtcl || $core16_hip_reconfig_hwtcl || $core8_hip_reconfig_hwtcl || $core4_0_hip_reconfig_hwtcl || $core4_1_hip_reconfig_hwtcl } {
                    set_interface_property p${i}_reset_status_n associatedResetSinks none
                #    }
                }
                }

         }
    }

    proc ::intel_pcie_ss_axi::interfaces::elaborate_axi_st_areset {} {
        set tile                    [ip_get "parameter.TILE.value"]
        set top_topology_hwtcl      [ip_get "parameter.top_topology_hwtcl.value"]


        if {$tile == "P-TILE" || $tile == "R-TILE"} {
            if { [regexp "x16" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "x8" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "x4" $top_topology_hwtcl] } {
                set core_num 4
            }
            
            for { set i 0 } { $i < [expr $core_num] } { incr i } {
                set_interface_property p${i}_axi_st_areset_n associatedClock p${i}_axi_st_clk
            }

        } elseif {$tile == "F-TILE"} {
            if { [regexp "1x16" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "2x8" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "4x4" $top_topology_hwtcl] } {
                set core_num 4
            } elseif { [regexp "1x4" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "2x4" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "1x8" $top_topology_hwtcl] } {
                set core_num 1
            }


            if { [regexp "2x4" $top_topology_hwtcl] } {
                set_interface_property p0_axi_st_areset_n associatedClock p0_axi_st_clk
                set_interface_property p2_axi_st_areset_n associatedClock p2_axi_st_clk

            } else {
                for { set i 0 } { $i < [expr $core_num] } { incr i } {
                    set_interface_property p${i}_axi_st_areset_n associatedClock p${i}_axi_st_clk

                }
            }
        }
    }

    proc ::intel_pcie_ss_axi::interfaces::elaborate_axi_lite_areset_n {} {
        set tile                    [ip_get "parameter.TILE.value"]
        set top_topology_hwtcl      [ip_get "parameter.top_topology_hwtcl.value"]

        if {$tile == "P-TILE" || $tile == "R-TILE"} {
            if { [regexp "x16" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "x8" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "x4" $top_topology_hwtcl] } {
                set core_num 4
            }
            
            for { set i 0 } { $i < [expr $core_num] } { incr i } {
                set_interface_property p${i}_axi_lite_areset_n associatedClock p${i}_axi_lite_clk
            }

        } elseif {$tile == "F-TILE"} {
            if { [regexp "1x16" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "2x8" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "4x4" $top_topology_hwtcl] } {
                set core_num 4
            } elseif { [regexp "1x4" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "2x4" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "1x8" $top_topology_hwtcl] } {
                set core_num 1
            }

            if { [regexp "2x4" $top_topology_hwtcl] } {
                set_interface_property p0_axi_lite_areset_n associatedClock p0_axi_lite_clk
                set_interface_property p2_axi_lite_areset_n associatedClock p2_axi_lite_clk

            } else {
                for { set i 0 } { $i < [expr $core_num] } { incr i } {
                    set_interface_property p${i}_axi_lite_areset_n associatedClock p${i}_axi_lite_clk

                }
            }
        }
    }

    proc ::intel_pcie_ss_axi::interfaces::elaborate_subsystem_cold_rst_n {} {
        set tile                    [ip_get "parameter.TILE.value"]
        set top_topology_hwtcl      [ip_get "parameter.top_topology_hwtcl.value"]

        if {$tile == "P-TILE" || $tile == "R-TILE"} {
            if { [regexp "x16" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "x8" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "x4" $top_topology_hwtcl] } {
                set core_num 4
            }
            
            for { set i 0 } { $i < [expr $core_num] } { incr i } {
                set_interface_property p${i}_subsystem_cold_rst_n synchronousEdges None
                set_interface_property p${i}_subsystem_warm_rst_n synchronousEdges None
            }

        } elseif {$tile == "F-TILE"} {
            if { [regexp "1x16" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "2x8" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "4x4" $top_topology_hwtcl] } {
                set core_num 4
            } elseif { [regexp "1x4" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "2x4" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "1x8" $top_topology_hwtcl] } {
                set core_num 1
            }

            if { [regexp "2x4" $top_topology_hwtcl] } {
                set_interface_property p0_subsystem_cold_rst_n synchronousEdges None
                set_interface_property p2_subsystem_cold_rst_n synchronousEdges None
                set_interface_property p0_subsystem_warm_rst_n synchronousEdges None
                set_interface_property p2_subsystem_warm_rst_n synchronousEdges None

            } else {
                for { set i 0 } { $i < [expr $core_num] } { incr i } {
                    set_interface_property p${i}_subsystem_cold_rst_n synchronousEdges None
                    set_interface_property p${i}_subsystem_warm_rst_n synchronousEdges None

                }
            }
        }
    }
    
    proc ::intel_pcie_ss_axi::interfaces::elaborate_axi_mm_areset_n {} {
        set tile                    [ip_get "parameter.TILE.value"]
        set top_topology_hwtcl      [ip_get "parameter.top_topology_hwtcl.value"]

        if {$tile == "P-TILE" || $tile == "R-TILE"} {
            if { [regexp "x16" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "x8" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "x4" $top_topology_hwtcl] } {
                set core_num 4
            }
            
            for { set i 0 } { $i < [expr $core_num] } { incr i } {
                set_interface_property p${i}_axi_mm_areset_n associatedClock p${i}_axi_mm_clk
            }

        } elseif {$tile == "F-TILE"} {
            if { [regexp "1x16" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "2x8" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "4x4" $top_topology_hwtcl] } {
                set core_num 4
            } elseif { [regexp "1x4" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "2x4" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "1x8" $top_topology_hwtcl] } {
                set core_num 1
            }


            if { [regexp "2x4" $top_topology_hwtcl] } {
                set_interface_property p0_axi_mm_areset_n associatedClock p0_axi_mm_clk
                set_interface_property p2_axi_mm_areset_n associatedClock p2_axi_mm_clk

            } else {
                for { set i 0 } { $i < [expr $core_num] } { incr i } {
                    set_interface_property p${i}_axi_mm_areset_n associatedClock p${i}_axi_mm_clk

                }
            }
        }
    }

    proc ::intel_pcie_ss_axi::interfaces::elaborate_st_rx_interfaces {} {
        set tile                    [ip_get "parameter.TILE.value"]
        set top_topology_hwtcl      [ip_get "parameter.top_topology_hwtcl.value"]

        if {$tile == "P-TILE" || $tile == "R-TILE"} {
            if { [regexp "x16" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "x8" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "x4" $top_topology_hwtcl] } {
                set core_num 4
            }
            
            for { set i 0 } { $i < [expr $core_num] } { incr i } {
                set_interface_property p${i}_st_rx associatedClock p${i}_axi_st_clk
            }

        } elseif {$tile == "F-TILE"} {
            if { [regexp "1x16" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "2x8" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "4x4" $top_topology_hwtcl] } {
                set core_num 4
            } elseif { [regexp "1x4" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "2x4" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "1x8" $top_topology_hwtcl] } {
                set core_num 1
            }


            if { [regexp "2x4" $top_topology_hwtcl] } {
                set_interface_property p0_st_rx associatedClock p0_axi_st_clk
                set_interface_property p2_st_rx associatedClock p2_axi_st_clk

            } else {
                for { set i 0 } { $i < [expr $core_num] } { incr i } {
                    set_interface_property p${i}_st_rx associatedClock p${i}_axi_st_clk

                }
            }
        }
    }

     proc ::intel_pcie_ss_axi::interfaces::elaborate_st_rx_tuser_hvalid_interfaces {} {
        set top_topology_hwtcl                      [ip_get "parameter.top_topology_hwtcl.value"]

        if { [regexp "x16" $top_topology_hwtcl] } {
            set core_num 1
        } elseif { [regexp "x8" $top_topology_hwtcl] } {
            set core_num 2
        } elseif { [regexp "x4" $top_topology_hwtcl] } {
            set core_num 4
        }
        
        for { set i 0 } { $i < [expr $core_num] } { incr i } {
            set_interface_property p${i}_ss_app_st_rx_tuser_hvalid associatedClock p${i}_axi_st_clk
        }
    }
 proc ::intel_pcie_ss_axi::interfaces::elaborate_st_rx_tuser_transaction_abort_interfaces {} {
        set top_topology_hwtcl                      [ip_get "parameter.top_topology_hwtcl.value"]

        if { [regexp "x16" $top_topology_hwtcl] } {
            set core_num 1
        } elseif { [regexp "x8" $top_topology_hwtcl] } {
            set core_num 2
        } elseif { [regexp "x4" $top_topology_hwtcl] } {
            set core_num 4
        }
        
        for { set i 0 } { $i < [expr $core_num] } { incr i } {
            set_interface_property p${i}_ss_app_st_rx_tuser_transaction_abort associatedClock p${i}_axi_st_clk
        }
    }
 proc ::intel_pcie_ss_axi::interfaces::elaborate_st_rx_tuser_hdr_interfaces {} {
        set top_topology_hwtcl                      [ip_get "parameter.top_topology_hwtcl.value"]

        if { [regexp "x16" $top_topology_hwtcl] } {
            set core_num 1
        } elseif { [regexp "x8" $top_topology_hwtcl] } {
            set core_num 2
        } elseif { [regexp "x4" $top_topology_hwtcl] } {
            set core_num 4
        }
        
        for { set i 0 } { $i < [expr $core_num] } { incr i } {
            set_interface_property p${i}_ss_app_st_rx_tuser_hdr associatedClock p${i}_axi_st_clk
        }
    }


    
    proc ::intel_pcie_ss_axi::interfaces::elaborate_st_rx_tuser_vendor_interfaces {} {
        set top_topology_hwtcl                      [ip_get "parameter.top_topology_hwtcl.value"]

        if { [regexp "x16" $top_topology_hwtcl] } {
            set core_num 1
        } elseif { [regexp "x8" $top_topology_hwtcl] } {
            set core_num 2
        } elseif { [regexp "x4" $top_topology_hwtcl] } {
            set core_num 4
        }
        
        for { set i 0 } { $i < [expr $core_num] } { incr i } {
            set_interface_property p${i}_ss_app_st_rx_tuser_vendor associatedClock p${i}_axi_st_clk
        }
    }
     proc ::intel_pcie_ss_axi::interfaces::elaborate_st_rx_tuser_last_segment_interfaces {} {
        set top_topology_hwtcl                      [ip_get "parameter.top_topology_hwtcl.value"]

        if { [regexp "x16" $top_topology_hwtcl] } {
            set core_num 1
        } elseif { [regexp "x8" $top_topology_hwtcl] } {
            set core_num 2
        } elseif { [regexp "x4" $top_topology_hwtcl] } {
            set core_num 4
        }
        
        for { set i 0 } { $i < [expr $core_num] } { incr i } {
            set_interface_property p${i}_ss_app_st_rx_tuser_last_segment associatedClock p${i}_axi_st_clk
        }
    }

    
   
    proc ::intel_pcie_ss_axi::interfaces::elaborate_st_tx_tuser_vendor_interfaces {} {
        set top_topology_hwtcl                      [ip_get "parameter.top_topology_hwtcl.value"]

        if { [regexp "x16" $top_topology_hwtcl] } {
            set core_num 1
        } elseif { [regexp "x8" $top_topology_hwtcl] } {
            set core_num 2
        } elseif { [regexp "x4" $top_topology_hwtcl] } {
            set core_num 4
        }
        
        for { set i 0 } { $i < [expr $core_num] } { incr i } {
            set_interface_property p${i}_app_ss_st_tx_tuser_vendor associatedClock p${i}_axi_st_clk
        }
    }
    proc ::intel_pcie_ss_axi::interfaces::elaborate_st_tx_tuser_last_segment_interfaces {} {
        set top_topology_hwtcl                      [ip_get "parameter.top_topology_hwtcl.value"]

        if { [regexp "x16" $top_topology_hwtcl] } {
            set core_num 1
        } elseif { [regexp "x8" $top_topology_hwtcl] } {
            set core_num 2
        } elseif { [regexp "x4" $top_topology_hwtcl] } {
            set core_num 4
        }
        
        for { set i 0 } { $i < [expr $core_num] } { incr i } {
            set_interface_property p${i}_app_ss_st_tx_tuser_last_segment associatedClock p${i}_axi_st_clk
        }
    }

    proc ::intel_pcie_ss_axi::interfaces::elaborate_st_tx_interfaces {} {
        set tile                    [ip_get "parameter.TILE.value"]
        set top_topology_hwtcl      [ip_get "parameter.top_topology_hwtcl.value"]

        if {$tile == "P-TILE" || $tile == "R-TILE"} {
            if { [regexp "x16" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "x8" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "x4" $top_topology_hwtcl] } {
                set core_num 4
            }
            
            for { set i 0 } { $i < [expr $core_num] } { incr i } {
                set_interface_property p${i}_st_tx associatedClock p${i}_axi_st_clk
            }

        } elseif {$tile == "F-TILE"} {
            if { [regexp "1x16" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "2x8" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "4x4" $top_topology_hwtcl] } {
                set core_num 4
            } elseif { [regexp "1x4" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "2x4" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "1x8" $top_topology_hwtcl] } {
                set core_num 1
            }

            if { [regexp "2x4" $top_topology_hwtcl] } {
                set_interface_property p0_st_tx associatedClock p0_axi_st_clk
                set_interface_property p2_st_tx associatedClock p2_axi_st_clk

            } else {
                for { set i 0 } { $i < [expr $core_num] } { incr i } {
                    set_interface_property p${i}_st_tx associatedClock p${i}_axi_st_clk

                }
            }
        }
    }

     proc ::intel_pcie_ss_axi::interfaces::elaborate_st_tx_tuser_hvalid_interfaces {} {
        set top_topology_hwtcl                      [ip_get "parameter.top_topology_hwtcl.value"]

        if { [regexp "x16" $top_topology_hwtcl] } {
            set core_num 1
        } elseif { [regexp "x8" $top_topology_hwtcl] } {
            set core_num 2
        } elseif { [regexp "x4" $top_topology_hwtcl] } {
            set core_num 4
        }
        
        for { set i 0 } { $i < [expr $core_num] } { incr i } {
            set_interface_property p${i}_app_ss_st_tx_tuser_hvalid associatedClock p${i}_axi_st_clk
        }
    }
 proc ::intel_pcie_ss_axi::interfaces::elaborate_st_tx_tuser_transaction_abort_interfaces {} {
        set top_topology_hwtcl                      [ip_get "parameter.top_topology_hwtcl.value"]

        if { [regexp "x16" $top_topology_hwtcl] } {
            set core_num 1
        } elseif { [regexp "x8" $top_topology_hwtcl] } {
            set core_num 2
        } elseif { [regexp "x4" $top_topology_hwtcl] } {
            set core_num 4
        }
        
        for { set i 0 } { $i < [expr $core_num] } { incr i } {
            set_interface_property p${i}_app_ss_st_tx_tuser_transaction_abort associatedClock p${i}_axi_st_clk
        }
    }
 proc ::intel_pcie_ss_axi::interfaces::elaborate_st_tx_tuser_hdr_interfaces {} {
        set top_topology_hwtcl                      [ip_get "parameter.top_topology_hwtcl.value"]

        if { [regexp "x16" $top_topology_hwtcl] } {
            set core_num 1
        } elseif { [regexp "x8" $top_topology_hwtcl] } {
            set core_num 2
        } elseif { [regexp "x4" $top_topology_hwtcl] } {
            set core_num 4
        }
        
        for { set i 0 } { $i < [expr $core_num] } { incr i } {
            set_interface_property p${i}_app_ss_st_tx_tuser_hdr associatedClock p${i}_axi_st_clk
        }
    }


    proc ::intel_pcie_ss_axi::interfaces::elaborate_st_ciireq_interfaces {} {
        set tile                    [ip_get "parameter.TILE.value"]
        set top_topology_hwtcl      [ip_get "parameter.top_topology_hwtcl.value"]

        if {$tile == "P-TILE" || $tile == "R-TILE"} {
            if { [regexp "x16" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "x8" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "x4" $top_topology_hwtcl] } {
                set core_num 4
            }
            
            for { set i 0 } { $i < [expr $core_num] } { incr i } {
                set_interface_property p${i}_st_ciireq associatedClock p${i}_axi_lite_clk
            }

        } elseif {$tile == "F-TILE"} {
            if { [regexp "1x16" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "2x8" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "4x4" $top_topology_hwtcl] } {
                set core_num 4
            } elseif { [regexp "1x4" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "2x4" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "1x8" $top_topology_hwtcl] } {
                set core_num 1
            }

            if { [regexp "2x4" $top_topology_hwtcl] } {
                set_interface_property p0_st_ciireq associatedClock p0_axi_lite_clk
                set_interface_property p2_st_ciireq associatedClock p2_axi_lite_clk

            } else {
                for { set i 0 } { $i < [expr $core_num] } { incr i } {
                    set_interface_property p${i}_st_ciireq associatedClock p${i}_axi_lite_clk

                }
            }
        }
    } 

    proc ::intel_pcie_ss_axi::interfaces::elaborate_st_ciiresp_interfaces {} {
        set tile                    [ip_get "parameter.TILE.value"]
        set top_topology_hwtcl      [ip_get "parameter.top_topology_hwtcl.value"]

        if {$tile == "P-TILE" || $tile == "R-TILE"} {
            if { [regexp "x16" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "x8" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "x4" $top_topology_hwtcl] } {
                set core_num 4
            }
            
            for { set i 0 } { $i < [expr $core_num] } { incr i } {
                set_interface_property p${i}_st_ciiresp associatedClock p${i}_axi_lite_clk
            }

        } elseif {$tile == "F-TILE"} {
            if { [regexp "1x16" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "2x8" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "4x4" $top_topology_hwtcl] } {
                set core_num 4
            } elseif { [regexp "1x4" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "2x4" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "1x8" $top_topology_hwtcl] } {
                set core_num 1
            }

            if { [regexp "2x4" $top_topology_hwtcl] } {
                set_interface_property p0_st_ciiresp associatedClock p0_axi_lite_clk
                set_interface_property p2_st_ciiresp associatedClock p2_axi_lite_clk

            } else {
                for { set i 0 } { $i < [expr $core_num] } { incr i } {
                    set_interface_property p${i}_st_ciiresp associatedClock p${i}_axi_lite_clk

                }
            }
        }
    }

    proc ::intel_pcie_ss_axi::interfaces::elaborate_st_cebreq_interfaces {} {
        set top_topology_hwtcl                      [ip_get "parameter.top_topology_hwtcl.value"]

        if { [regexp "x16" $top_topology_hwtcl] } {
            set core_num 1
        } elseif { [regexp "x8" $top_topology_hwtcl] } {
            set core_num 2
        } elseif { [regexp "x4" $top_topology_hwtcl] } {
            set core_num 4
        }
        
        for { set i 0 } { $i < [expr $core_num] } { incr i } {
            set_interface_property p${i}_st_cebreq associatedClock p${i}_axi_lite_clk
        }
    } 

    proc ::intel_pcie_ss_axi::interfaces::elaborate_st_cebresp_interfaces {} {
        set top_topology_hwtcl                      [ip_get "parameter.top_topology_hwtcl.value"]

        if { [regexp "x16" $top_topology_hwtcl] } {
            set core_num 1
        } elseif { [regexp "x8" $top_topology_hwtcl] } {
            set core_num 2
        } elseif { [regexp "x4" $top_topology_hwtcl] } {
            set core_num 4
        }
        
        for { set i 0 } { $i < [expr $core_num] } { incr i } {
            set_interface_property p${i}_st_cebresp associatedClock p${i}_axi_lite_clk
        }
    } 

    proc ::intel_pcie_ss_axi::interfaces::elaborate_st_flrrcvd_interfaces {} {
        set tile                    [ip_get "parameter.TILE.value"]
        set top_topology_hwtcl      [ip_get "parameter.top_topology_hwtcl.value"]

        if {$tile == "P-TILE" || $tile == "R-TILE"} {
            if { [regexp "x16" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "x8" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "x4" $top_topology_hwtcl] } {
                set core_num 4
            }
            
            for { set i 0 } { $i < [expr $core_num] } { incr i } {
                set_interface_property p${i}_st_flrrcvd associatedClock p${i}_axi_lite_clk
            }

        } elseif {$tile == "F-TILE"} {
            if { [regexp "1x16" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "2x8" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "4x4" $top_topology_hwtcl] } {
                set core_num 4
            } elseif { [regexp "1x4" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "2x4" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "1x8" $top_topology_hwtcl] } {
                set core_num 1
            }

            if { [regexp "2x4" $top_topology_hwtcl] } {
                set_interface_property p0_st_flrrcvd associatedClock p0_axi_lite_clk
                set_interface_property p2_st_flrrcvd associatedClock p2_axi_lite_clk

            } else {
                for { set i 0 } { $i < [expr $core_num] } { incr i } {
                    set_interface_property p${i}_st_flrrcvd associatedClock p${i}_axi_lite_clk

                }
            }
        }
    } 


    proc ::intel_pcie_ss_axi::interfaces::elaborate_st_flrcmpl_interfaces {} {
        set tile                    [ip_get "parameter.TILE.value"]
        set top_topology_hwtcl      [ip_get "parameter.top_topology_hwtcl.value"]

        if {$tile == "P-TILE" || $tile == "R-TILE"} {
            if { [regexp "x16" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "x8" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "x4" $top_topology_hwtcl] } {
                set core_num 4
            }
            
            for { set i 0 } { $i < [expr $core_num] } { incr i } {
                set_interface_property p${i}_st_flrcmpl associatedClock p${i}_axi_lite_clk
            }

        } elseif {$tile == "F-TILE"} {
            if { [regexp "1x16" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "2x8" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "4x4" $top_topology_hwtcl] } {
                set core_num 4
            } elseif { [regexp "1x4" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "2x4" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "1x8" $top_topology_hwtcl] } {
                set core_num 1
            }

            if { [regexp "2x4" $top_topology_hwtcl] } {
                set_interface_property p0_st_flrcmpl associatedClock p0_axi_lite_clk
                set_interface_property p2_st_flrcmpl associatedClock p2_axi_lite_clk

            } else {
                for { set i 0 } { $i < [expr $core_num] } { incr i } {
                    set_interface_property p${i}_st_flrcmpl associatedClock p${i}_axi_lite_clk

                }
            }
        }
    }

    proc ::intel_pcie_ss_axi::interfaces::elaborate_st_ctrlshadow_interfaces {} {
        set tile                    [ip_get "parameter.TILE.value"]
        set top_topology_hwtcl      [ip_get "parameter.top_topology_hwtcl.value"]

        if {$tile == "P-TILE" || $tile == "R-TILE"} {
            if { [regexp "x16" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "x8" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "x4" $top_topology_hwtcl] } {
                set core_num 4
            }
            
            for { set i 0 } { $i < [expr $core_num] } { incr i } {
                set_interface_property p${i}_st_ctrlshadow associatedClock p${i}_axi_lite_clk
            }

        } elseif {$tile == "F-TILE"} {
            if { [regexp "1x16" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "2x8" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "4x4" $top_topology_hwtcl] } {
                set core_num 4
            } elseif { [regexp "1x4" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "2x4" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "1x8" $top_topology_hwtcl] } {
                set core_num 1
            }

            if { [regexp "2x4" $top_topology_hwtcl] } {
                set_interface_property p0_st_ctrlshadow associatedClock p0_axi_lite_clk
                set_interface_property p2_st_ctrlshadow associatedClock p2_axi_lite_clk

            } else {
                for { set i 0 } { $i < [expr $core_num] } { incr i } {
                    set_interface_property p${i}_st_ctrlshadow associatedClock p${i}_axi_lite_clk

                }
            }
        }
    }


    proc ::intel_pcie_ss_axi::interfaces::elaborate_st_txcrdt_interfaces {} {
        set tile                    [ip_get "parameter.TILE.value"]
        set top_topology_hwtcl      [ip_get "parameter.top_topology_hwtcl.value"]

        if {$tile == "P-TILE" || $tile == "R-TILE"} {
            if { [regexp "x16" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "x8" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "x4" $top_topology_hwtcl] } {
                set core_num 4
            }
            
            for { set i 0 } { $i < [expr $core_num] } { incr i } {
                set_interface_property p${i}_st_txcrdt associatedClock p${i}_axi_st_clk
            }

        } elseif {$tile == "F-TILE"} {
            if { [regexp "1x16" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "2x8" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "4x4" $top_topology_hwtcl] } {
                set core_num 4
            } elseif { [regexp "1x4" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "2x4" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "1x8" $top_topology_hwtcl] } {
                set core_num 1
            }

            if { [regexp "2x4" $top_topology_hwtcl] } {
                set_interface_property p0_st_txcrdt associatedClock p0_axi_st_clk
                set_interface_property p2_st_txcrdt associatedClock p2_axi_st_clk

            } else {
                for { set i 0 } { $i < [expr $core_num] } { incr i } {
                    set_interface_property p${i}_st_txcrdt associatedClock p${i}_axi_st_clk

                }
            }
        }
    } 

    proc ::intel_pcie_ss_axi::interfaces::elaborate_st_rxcrdt_interfaces {} {
        set tile                    [ip_get "parameter.TILE.value"]
        set top_topology_hwtcl      [ip_get "parameter.top_topology_hwtcl.value"]

        if {$tile == "P-TILE" || $tile == "R-TILE"} {
            if { [regexp "x16" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "x8" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "x4" $top_topology_hwtcl] } {
                set core_num 4
            }
            
            for { set i 0 } { $i < [expr $core_num] } { incr i } {
                set_interface_property p${i}_st_rxcrdt associatedClock p${i}_axi_st_clk
            }

        } elseif {$tile == "F-TILE"} {
            if { [regexp "1x16" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "2x8" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "4x4" $top_topology_hwtcl] } {
                set core_num 4
            } elseif { [regexp "1x4" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "2x4" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "1x8" $top_topology_hwtcl] } {
                set core_num 1
            }

            if { [regexp "2x4" $top_topology_hwtcl] } {
                set_interface_property p0_st_rxcrdt associatedClock p0_axi_st_clk
                set_interface_property p2_st_rxcrdt associatedClock p2_axi_st_clk

            } else {
                for { set i 0 } { $i < [expr $core_num] } { incr i } {
                    set_interface_property p${i}_st_rxcrdt associatedClock p${i}_axi_st_clk

                }
            }
        }
    }   

    proc ::intel_pcie_ss_axi::interfaces::elaborate_st_cplto_interfaces {} {
        set tile                    [ip_get "parameter.TILE.value"]
        set top_topology_hwtcl      [ip_get "parameter.top_topology_hwtcl.value"]

        if {$tile == "P-TILE" || $tile == "R-TILE"} {
            if { [regexp "x16" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "x8" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "x4" $top_topology_hwtcl] } {
                set core_num 4
            }
            
            for { set i 0 } { $i < [expr $core_num] } { incr i } {
                set_interface_property p${i}_st_cplto associatedClock p${i}_axi_lite_clk
            }

        } elseif {$tile == "F-TILE"} {
            if { [regexp "1x16" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "2x8" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "4x4" $top_topology_hwtcl] } {
                set core_num 4
            } elseif { [regexp "1x4" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "2x4" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "1x8" $top_topology_hwtcl] } {
                set core_num 1
            }

            if { [regexp "2x4" $top_topology_hwtcl] } {
                set_interface_property p0_st_cplto associatedClock p0_axi_lite_clk
                set_interface_property p2_st_cplto associatedClock p2_axi_lite_clk


            } else {
                for { set i 0 } { $i < [expr $core_num] } { incr i } {
                    set_interface_property p${i}_st_cplto associatedClock p${i}_axi_lite_clk

                }
            }
        }
    }  

    proc ::intel_pcie_ss_axi::interfaces::elaborate_lite_csr_interfaces {} {
        set tile                    [ip_get "parameter.TILE.value"]
        set top_topology_hwtcl      [ip_get "parameter.top_topology_hwtcl.value"]

        if {$tile == "P-TILE" || $tile == "R-TILE"} {
            if { [regexp "x16" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "x8" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "x4" $top_topology_hwtcl] } {
                set core_num 4
            }
            
            for { set i 0 } { $i < [expr $core_num] } { incr i } {
                set_interface_property p${i}_lite_csr associatedClock p${i}_axi_lite_clk
            }

        } elseif {$tile == "F-TILE"} {
            if { [regexp "1x16" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "2x8" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "4x4" $top_topology_hwtcl] } {
                set core_num 4
            } elseif { [regexp "1x4" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "2x4" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "1x8" $top_topology_hwtcl] } {
                set core_num 1
            }


            if { [regexp "2x4" $top_topology_hwtcl] } {
                set_interface_property p0_lite_csr associatedClock p0_axi_lite_clk
                set_interface_property p2_lite_csr associatedClock p2_axi_lite_clk

            } else {
                for { set i 0 } { $i < [expr $core_num] } { incr i } {
                    set_interface_property p${i}_lite_csr associatedClock p${i}_axi_lite_clk

                }
            }
        }
    } 


    proc ::intel_pcie_ss_axi::interfaces::elaborate_lite_initatr_interfaces {} {
        set top_topology_hwtcl                      [ip_get "parameter.top_topology_hwtcl.value"]

        if { [regexp "x16" $top_topology_hwtcl] } {
            set core_num 1
        } elseif { [regexp "x8" $top_topology_hwtcl] } {
            set core_num 2
        } elseif { [regexp "x4" $top_topology_hwtcl] } {
            set core_num 4
        }
        
        for { set i 0 } { $i < [expr $core_num] } { incr i } {
            set_interface_property p${i}_lite_initatr associatedClock p${i}_axi_lite_clk
        }
    } 

    proc ::intel_pcie_ss_axi::interfaces::elaborate_mm_initatr_interfaces {} {
        set tile                    [ip_get "parameter.TILE.value"]
        set top_topology_hwtcl      [ip_get "parameter.top_topology_hwtcl.value"]

        if {$tile == "P-TILE" || $tile == "R-TILE"} {
            if { [regexp "x16" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "x8" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "x4" $top_topology_hwtcl] } {
                set core_num 4
            }
            
            for { set i 0 } { $i < [expr $core_num] } { incr i } {
                set_interface_property p${i}_mm_initatr associatedClock p${i}_axi_mm_clk
            }

        } elseif {$tile == "F-TILE"} {
            if { [regexp "1x16" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "2x8" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "4x4" $top_topology_hwtcl] } {
                set core_num 4
            } elseif { [regexp "1x4" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "2x4" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "1x8" $top_topology_hwtcl] } {
                set core_num 1
            }


            if { [regexp "2x4" $top_topology_hwtcl] } {
                set_interface_property p0_mm_initatr associatedClock p0_axi_mm_clk
                set_interface_property p2_mm_initatr associatedClock p2_axi_mm_clk


            } else {
                for { set i 0 } { $i < [expr $core_num] } { incr i } {
                    set_interface_property p${i}_mm_initatr associatedClock p${i}_axi_mm_clk

                }
            }
        }
    }
    
    proc ::intel_pcie_ss_axi::interfaces::elaborate_dummy_user_avmm_rst {} {


        #set core16_hip_reconfig_hwtcl           [ip_get "parameter.core16_hip_reconfig_hwtcl.value"]
        #set core8_hip_reconfig_hwtcl            [ip_get "parameter.core8_hip_reconfig_hwtcl.value"]
        #set core4_0_hip_reconfig_hwtcl          [ip_get "parameter.core4_0_hip_reconfig_hwtcl.value"]
        #set core4_1_hip_reconfig_hwtcl          [ip_get "parameter.core4_1_hip_reconfig_hwtcl.value"]
        set xcvr_reconfig_hwtcl                 [ip_get "parameter.xcvr_reconfig_hwtcl.value"]
        #set ptile_enable_pciess_register_access_hwtcl          [ip_get "parameter.ptile_enable_pciess_register_access_hwtcl.value"]
        #set core16_enable_cpl_timeout_hwtcl     [ip_get "parameter.core16_enable_cpl_timeout_hwtcl.value"]
        #set core8_enable_cpl_timeout_hwtcl      [ip_get "parameter.core8_enable_cpl_timeout_hwtcl.value"]
        #set core4_0_enable_cpl_timeout_hwtcl    [ip_get "parameter.core4_0_enable_cpl_timeout_hwtcl.value"]
        #set core4_1_enable_cpl_timeout_hwtcl    [ip_get "parameter.core4_1_enable_cpl_timeout_hwtcl.value"]

        if { $xcvr_reconfig_hwtcl } {
            set_interface_property dummy_user_avmm_rst associatedClock xcvr_reconfig_clk
        } else {
            set_interface_property dummy_user_avmm_rst associatedClock coreclkout_hip_toapp
    	}
        #if { $core16_hip_reconfig_hwtcl } {
        #    set_interface_property dummy_user_avmm_rst associatedClock p0_hip_reconfig_clk
        #} elseif { $core8_hip_reconfig_hwtcl } {
        #    set_interface_property dummy_user_avmm_rst associatedClock p1_hip_reconfig_clk
        #} elseif { $core4_0_hip_reconfig_hwtcl } {
        #    set_interface_property dummy_user_avmm_rst associatedClock p2_hip_reconfig_clk
        #} elseif { $core4_1_hip_reconfig_hwtcl } {
        #    set_interface_property dummy_user_avmm_rst associatedClock p3_hip_reconfig_clk
        #} elseif { $xcvr_reconfig_hwtcl } {
        #    set_interface_property dummy_user_avmm_rst associatedClock xcvr_reconfig_clk
        #} elseif { $core16_enable_cpl_timeout_hwtcl } {
        #    set_interface_property dummy_user_avmm_rst associatedClock p0_cpl_timeout_clk
        #} elseif { $core8_enable_cpl_timeout_hwtcl } {
        #    set_interface_property dummy_user_avmm_rst associatedClock p1_cpl_timeout_clk
        #} elseif { $core4_0_enable_cpl_timeout_hwtcl } {
        #    set_interface_property dummy_user_avmm_rst associatedClock p2_cpl_timeout_clk
        #} elseif { $core4_1_enable_cpl_timeout_hwtcl } {
        #    set_interface_property dummy_user_avmm_rst associatedClock p3_cpl_timeout_clk
        #}

        #vww16 added, ww19 removed 
#        set tile [ip_get "parameter.TILE.value"]
#        if {$tile == "F-TILE"} {
#            
#            set_port_property dummy_user_avmm_rst TERMINATION "!xcvr_reconfig_hwtcl && !core16_hip_reconfig_hwtcl && !core8_hip_reconfig_hwtcl && !core4_0_hip_reconfig_hwtcl && !core4_1_hip_reconfig_hwtcl && !(ftile_enable_pciess_register_access_hwtcl || ptile_enable_pciess_register_access_hwtcl)"
#
#        } elseif {$tile == "P-TILE"} {
#
#            set_port_property dummy_user_avmm_rst TERMINATION "!xcvr_reconfig_hwtcl && !core16_hip_reconfig_hwtcl && !core8_hip_reconfig_hwtcl && !core4_0_hip_reconfig_hwtcl && !core4_1_hip_reconfig_hwtcl && !(ftile_enable_pciess_register_access_hwtcl || ptile_enable_pciess_register_access_hwtcl) && !core16_enable_cpl_timeout_hwtcl && !core8_enable_cpl_timeout_hwtcl && !core4_0_enable_cpl_timeout_hwtcl && !core4_1_enable_cpl_timeout_hwtcl"
#
#        }


	}
	
    proc ::intel_pcie_ss_axi::interfaces::elaborate_xcvr_reconfig {} {
        #clock always use core16 clock
        set_interface_property xcvr_reconfig associatedClock xcvr_reconfig_clk
        set_interface_property xcvr_reconfig maximumPendingReadTransactions 1
        set_interface_property xcvr_reconfig associatedReset dummy_user_avmm_rst
        
        #vww16 added
        set tile [ip_get "parameter.TILE.value"]
        if {$tile == "F-TILE"} {
            set_port_property xcvr_reconfig_address WIDTH_EXPR 25
        } elseif {$tile == "P-TILE"} {
            set_port_property xcvr_reconfig_address WIDTH_EXPR 26
        } elseif {$tile == "R-TILE"} {
            set_port_property xcvr_reconfig_address WIDTH_EXPR 21
        }


    }

    proc ::intel_pcie_ss_axi::interfaces::elaborate_st_err_interfaces {} {
        set tile                    [ip_get "parameter.TILE.value"]
        set top_topology_hwtcl      [ip_get "parameter.top_topology_hwtcl.value"]

        if {$tile == "P-TILE" || $tile == "R-TILE"} {
            if { [regexp "x16" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "x8" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "x4" $top_topology_hwtcl] } {
                set core_num 4
            }
            
            for { set i 0 } { $i < [expr $core_num] } { incr i } {
                set_interface_property p${i}_st_err associatedClock p${i}_axi_lite_clk
            }

        } elseif {$tile == "F-TILE"} {
            if { [regexp "1x16" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "2x8" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "4x4" $top_topology_hwtcl] } {
                set core_num 4
            } elseif { [regexp "1x4" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "2x4" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "1x8" $top_topology_hwtcl] } {
                set core_num 1
            }


            if { [regexp "2x4" $top_topology_hwtcl] } {
                set_interface_property p0_st_err associatedClock p0_axi_lite_clk
                set_interface_property p2_st_err associatedClock p2_axi_lite_clk

            } else {
                for { set i 0 } { $i < [expr $core_num] } { incr i } {
                    set_interface_property p${i}_st_err associatedClock p${i}_axi_lite_clk

                }
            }
        }
    }

     proc ::intel_pcie_ss_axi::interfaces::elaborate_app_ss_st_err_tuser_error_type_interfaces {} {
        set top_topology_hwtcl                      [ip_get "parameter.top_topology_hwtcl.value"]

        if { [regexp "x16" $top_topology_hwtcl] } {
            set core_num 1
        } elseif { [regexp "x8" $top_topology_hwtcl] } {
            set core_num 2
        } elseif { [regexp "x4" $top_topology_hwtcl] } {
            set core_num 4
        }
        
        for { set i 0 } { $i < [expr $core_num] } { incr i } {
            set_interface_property p${i}_app_ss_st_err_tuser_error_type associatedClock p${i}_axi_lite_clk
        }
    }
    
    proc ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_virtio_interfaces {} {
        set tile                    [ip_get "parameter.TILE.value"]
        set top_topology_hwtcl      [ip_get "parameter.top_topology_hwtcl.value"]

        if {$tile == "P-TILE"} {
            if { [regexp "x16" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "x8" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "x4" $top_topology_hwtcl] } {
                set core_num 2
            }
            
            for { set i 0 } { $i < [expr $core_num] } { incr i } {
                set_interface_property p${i}_ss_app_virtio_pcicfgreq associatedClock p${i}_axi_lite_clk
            }

        } elseif {$tile == "F-TILE"} {
            if { [regexp "1x16" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "2x8" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "4x4" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "1x4" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "2x4" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "1x8" $top_topology_hwtcl] } {
                set core_num 1
            }


            if { [regexp "2x4" $top_topology_hwtcl] } {
                set_interface_property p0_ss_app_virtio_pcicfgreq associatedClock p0_axi_lite_clk

            } else {
                for { set i 0 } { $i < [expr $core_num] } { incr i } {
                    set_interface_property p${i}_ss_app_virtio_pcicfgreq associatedClock p${i}_axi_lite_clk

                }
            }
        } elseif {$tile == "R-TILE"} {
            if { [regexp "x16" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "x8" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "x4" $top_topology_hwtcl] } {
                set core_num 4
            }
            
            for { set i 0 } { $i < [expr $core_num] } { incr i } {
                set_interface_property p${i}_ss_app_virtio_pcicfgreq associatedClock p${i}_axi_lite_clk
            }
        }
    }

    proc ::intel_pcie_ss_axi::interfaces::elaborate_app_ss_virtio_interfaces {} {
        set tile                    [ip_get "parameter.TILE.value"]
        set top_topology_hwtcl      [ip_get "parameter.top_topology_hwtcl.value"]

        if {$tile == "P-TILE"} {
            if { [regexp "x16" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "x8" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "x4" $top_topology_hwtcl] } {
                set core_num 2
            }
            
            for { set i 0 } { $i < [expr $core_num] } { incr i } {
                set_interface_property p${i}_app_ss_virtio_pcicfgcmpl associatedClock p${i}_axi_lite_clk
            }

        } elseif {$tile == "F-TILE"} {
            if { [regexp "1x16" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "2x8" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "4x4" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "1x4" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "2x4" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "1x8" $top_topology_hwtcl] } {
                set core_num 1
            }


            if { [regexp "2x4" $top_topology_hwtcl] } {
                set_interface_property p0_app_ss_virtio_pcicfgcmpl associatedClock p0_axi_lite_clk
                
            } else {
                for { set i 0 } { $i < [expr $core_num] } { incr i } {
                    set_interface_property p${i}_app_ss_virtio_pcicfgcmpl associatedClock p${i}_axi_lite_clk

                }
            }
        } elseif {$tile == "R-TILE"} {
            if { [regexp "x16" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "x8" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "x4" $top_topology_hwtcl] } {
                set core_num 4
            }
            
            for { set i 0 } { $i < [expr $core_num] } { incr i } {
                set_interface_property p${i}_app_ss_virtio_pcicfgcmpl associatedClock p${i}_axi_lite_clk
            }
        }
    }

    proc ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_serr {} {
        set tile                    [ip_get "parameter.TILE.value"]
        set top_topology_hwtcl      [ip_get "parameter.top_topology_hwtcl.value"]

        if {$tile == "P-TILE" || $tile == "R-TILE"} {
            if { [regexp "x16" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "x8" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "x4" $top_topology_hwtcl] } {
                set core_num 4
            }
            
            for { set i 0 } { $i < [expr $core_num] } { incr i } {
                set_interface_property p${i}_ss_app_serr associatedClock p${i}_axi_st_clk
            }

        } elseif {$tile == "F-TILE"} {
            if { [regexp "1x16" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "2x8" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "4x4" $top_topology_hwtcl] } {
                set core_num 4
            } elseif { [regexp "1x4" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "2x4" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "1x8" $top_topology_hwtcl] } {
                set core_num 1
            }


            if { [regexp "2x4" $top_topology_hwtcl] } {
                set_interface_property p0_ss_app_serr associatedClock p0_axi_st_clk
                set_interface_property p2_ss_app_serr associatedClock p2_axi_st_clk

            } else {
                for { set i 0 } { $i < [expr $core_num] } { incr i } {
                    set_interface_property p${i}_ss_app_serr associatedClock p${i}_axi_st_clk

                }
            }
        }
    }
    
    proc ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_linkup {} {
        set top_topology_hwtcl                      [ip_get "parameter.top_topology_hwtcl.value"]

        if { [regexp "x16" $top_topology_hwtcl] } {
            set core_num 1
        } elseif { [regexp "x8" $top_topology_hwtcl] } {
            set core_num 2
        } elseif { [regexp "x4" $top_topology_hwtcl] } {
            set core_num 4
        }
        
        for { set i 0 } { $i < [expr $core_num] } { incr i } {
            set_interface_property p${i}_ss_app_linkup associatedClock p${i}_axi_st_clk
        }
    }

    proc ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_dlup {} {
        set tile                    [ip_get "parameter.TILE.value"]
        set top_topology_hwtcl      [ip_get "parameter.top_topology_hwtcl.value"]

        if {$tile == "P-TILE" || $tile == "R-TILE"} {
            if { [regexp "x16" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "x8" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "x4" $top_topology_hwtcl] } {
                set core_num 4
            }
            
            for { set i 0 } { $i < [expr $core_num] } { incr i } {
                set_interface_property p${i}_ss_app_dlup associatedClock p${i}_axi_st_clk
            }

        } elseif {$tile == "F-TILE"} {
            if { [regexp "1x16" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "2x8" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "4x4" $top_topology_hwtcl] } {
                set core_num 4
            } elseif { [regexp "1x4" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "2x4" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "1x8" $top_topology_hwtcl] } {
                set core_num 1
            }


            if { [regexp "2x4" $top_topology_hwtcl] } {
                set_interface_property p0_ss_app_dlup associatedClock p0_axi_st_clk
                set_interface_property p2_ss_app_dlup associatedClock p2_axi_st_clk

            } else {
                for { set i 0 } { $i < [expr $core_num] } { incr i } {
                    set_interface_property p${i}_ss_app_dlup associatedClock p${i}_axi_st_clk

                }
            }
        }
    }

    proc ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_int_status {} {
        set tile                    [ip_get "parameter.TILE.value"]
        set top_topology_hwtcl      [ip_get "parameter.top_topology_hwtcl.value"]

        if {$tile == "P-TILE" || $tile == "R-TILE"} {
            if { [regexp "x16" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "x8" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "x4" $top_topology_hwtcl] } {
                set core_num 4
            }
            
            for { set i 0 } { $i < [expr $core_num] } { incr i } {
                set_interface_property p${i}_ss_app_int_status associatedClock p${i}_axi_st_clk
            }

        } elseif {$tile == "F-TILE"} {
            if { [regexp "1x16" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "2x8" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "4x4" $top_topology_hwtcl] } {
                set core_num 4
            } elseif { [regexp "1x4" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "2x4" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "1x8" $top_topology_hwtcl] } {
                set core_num 1
            }


            if { [regexp "2x4" $top_topology_hwtcl] } {
                set_interface_property p0_ss_app_int_status associatedClock p0_axi_st_clk
                set_interface_property p2_ss_app_int_status associatedClock p2_axi_st_clk

            } else {
                for { set i 0 } { $i < [expr $core_num] } { incr i } {
                    set_interface_property p${i}_ss_app_int_status associatedClock p${i}_axi_st_clk

                }
            }
        }
    }

    proc ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_surprise_down_err {} {
        set tile                    [ip_get "parameter.TILE.value"]
        set top_topology_hwtcl      [ip_get "parameter.top_topology_hwtcl.value"]

        if {$tile == "P-TILE" || $tile == "R-TILE"} {
            if { [regexp "x16" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "x8" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "x4" $top_topology_hwtcl] } {
                set core_num 4
            }
            
            for { set i 0 } { $i < [expr $core_num] } { incr i } {
                set_interface_property p${i}_ss_app_surprise_down_err associatedClock p${i}_axi_st_clk
            }

        } elseif {$tile == "F-TILE"} {
            if { [regexp "1x16" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "2x8" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "4x4" $top_topology_hwtcl] } {
                set core_num 4
            } elseif { [regexp "1x4" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "2x4" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "1x8" $top_topology_hwtcl] } {
                set core_num 1
            }


            if { [regexp "2x4" $top_topology_hwtcl] } {
                set_interface_property p0_ss_app_surprise_down_err associatedClock p0_axi_st_clk
                set_interface_property p2_ss_app_surprise_down_err associatedClock p2_axi_st_clk

            } else {
                for { set i 0 } { $i < [expr $core_num] } { incr i } {
                    set_interface_property p${i}_ss_app_surprise_down_err associatedClock p${i}_axi_st_clk

                }
            }
        }
    }

    proc ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_ltssmstate {} {
        set top_topology_hwtcl                      [ip_get "parameter.top_topology_hwtcl.value"]

        if { [regexp "x16" $top_topology_hwtcl] } {
            set core_num 1
        } elseif { [regexp "x8" $top_topology_hwtcl] } {
            set core_num 2
        } elseif { [regexp "x4" $top_topology_hwtcl] } {
            set core_num 4
        }
        
        for { set i 0 } { $i < [expr $core_num] } { incr i } {
            set_interface_property p${i}_ss_app_ltssmstate associatedClock p${i}_axi_st_clk
        }
    }

    proc ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_rx_par_err {} {
        set tile                    [ip_get "parameter.TILE.value"]
        set top_topology_hwtcl      [ip_get "parameter.top_topology_hwtcl.value"]

        if {$tile == "P-TILE" || $tile == "R-TILE"} {
            if { [regexp "x16" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "x8" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "x4" $top_topology_hwtcl] } {
                set core_num 4
            }
            
            for { set i 0 } { $i < [expr $core_num] } { incr i } {
                set_interface_property p${i}_ss_app_rx_par_err associatedClock p${i}_axi_st_clk
            }

        } elseif {$tile == "F-TILE"} {
            if { [regexp "1x16" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "2x8" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "4x4" $top_topology_hwtcl] } {
                set core_num 4
            } elseif { [regexp "1x4" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "2x4" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "1x8" $top_topology_hwtcl] } {
                set core_num 1
            }


            if { [regexp "2x4" $top_topology_hwtcl] } {
                set_interface_property p0_ss_app_rx_par_err associatedClock p0_axi_st_clk
                set_interface_property p2_ss_app_rx_par_err associatedClock p2_axi_st_clk

            } else {
                for { set i 0 } { $i < [expr $core_num] } { incr i } {
                    set_interface_property p${i}_ss_app_rx_par_err associatedClock p${i}_axi_st_clk

                }
            }
        }
    }

    proc ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_tx_par_err {} {
        set tile                    [ip_get "parameter.TILE.value"]
        set top_topology_hwtcl      [ip_get "parameter.top_topology_hwtcl.value"]

        if {$tile == "P-TILE" || $tile == "R-TILE"} {
            if { [regexp "x16" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "x8" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "x4" $top_topology_hwtcl] } {
                set core_num 4
            }
            
            for { set i 0 } { $i < [expr $core_num] } { incr i } {
                set_interface_property p${i}_ss_app_tx_par_err associatedClock p${i}_axi_st_clk
            }

        } elseif {$tile == "F-TILE"} {
            if { [regexp "1x16" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "2x8" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "4x4" $top_topology_hwtcl] } {
                set core_num 4
            } elseif { [regexp "1x4" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "2x4" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "1x8" $top_topology_hwtcl] } {
                set core_num 1
            }


            if { [regexp "2x4" $top_topology_hwtcl] } {
                set_interface_property p0_ss_app_tx_par_err associatedClock p0_axi_st_clk
                set_interface_property p2_ss_app_tx_par_err associatedClock p2_axi_st_clk

            } else {
                for { set i 0 } { $i < [expr $core_num] } { incr i } {
                    set_interface_property p${i}_ss_app_tx_par_err associatedClock p${i}_axi_st_clk

                }
            }
        }
    }

    proc ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_vf_err_poisonedwrreq_s0 {} {
        set tile                    [ip_get "parameter.TILE.value"]
        set top_topology_hwtcl      [ip_get "parameter.top_topology_hwtcl.value"]

        if {$tile == "P-TILE" || $tile == "R-TILE"} {
            if { [regexp "x16" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "x8" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "x4" $top_topology_hwtcl] } {
                set core_num 4
            }
            
            for { set i 0 } { $i < [expr $core_num] } { incr i } {
                set_interface_property p${i}_ss_app_vf_err_poisonedwrreq_s0 associatedClock p${i}_axi_lite_clk
            }

        } elseif {$tile == "F-TILE"} {
            if { [regexp "1x16" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "2x8" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "4x4" $top_topology_hwtcl] } {
                set core_num 4
            } elseif { [regexp "1x4" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "2x4" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "1x8" $top_topology_hwtcl] } {
                set core_num 1
            }


            if { [regexp "2x4" $top_topology_hwtcl] } {
                set_interface_property p0_ss_app_vf_err_poisonedwrreq_s0 associatedClock p0_axi_lite_clk
                set_interface_property p2_ss_app_vf_err_poisonedwrreq_s0 associatedClock p2_axi_lite_clk

            } else {
                for { set i 0 } { $i < [expr $core_num] } { incr i } {
                    set_interface_property p${i}_ss_app_vf_err_poisonedwrreq_s0 associatedClock p${i}_axi_lite_clk

                }
            }
        }
    }

    proc ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_vf_err_poisonedwrreq_s1 {} {
        set tile                    [ip_get "parameter.TILE.value"]
        set top_topology_hwtcl      [ip_get "parameter.top_topology_hwtcl.value"]

        if {$tile == "P-TILE" || $tile == "R-TILE"} {
            if { [regexp "x16" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "x8" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "x4" $top_topology_hwtcl] } {
                set core_num 2
            }
            
            for { set i 0 } { $i < [expr $core_num] } { incr i } {
                set_interface_property p${i}_ss_app_vf_err_poisonedwrreq_s1 associatedClock p${i}_axi_lite_clk
            }

        } elseif {$tile == "F-TILE"} {
            if { [regexp "1x16" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "2x8" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "4x4" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "1x4" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "2x4" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "1x8" $top_topology_hwtcl] } {
                set core_num 1
            }


            if { [regexp "2x4" $top_topology_hwtcl] } {
                set_interface_property p0_ss_app_vf_err_poisonedwrreq_s1 associatedClock p0_axi_lite_clk

            } else {
                for { set i 0 } { $i < [expr $core_num] } { incr i } {
                    set_interface_property p${i}_ss_app_vf_err_poisonedwrreq_s1 associatedClock p${i}_axi_lite_clk

                }
            }
        }
    }
  
    proc ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_vf_err_poisonedwrreq_s2 {} {
        set top_topology_hwtcl                      [ip_get "parameter.top_topology_hwtcl.value"]

        for { set i 0 } { $i < 1} { incr i } {
            set_interface_property p0_ss_app_vf_err_poisonedwrreq_s2 associatedClock p0_axi_lite_clk
        }
    }

    proc ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_vf_err_poisonedwrreq_s3 {} {
        set top_topology_hwtcl                      [ip_get "parameter.top_topology_hwtcl.value"]

        set_interface_property p0_ss_app_vf_err_poisonedwrreq_s3 associatedClock p0_axi_lite_clk        
    }

    proc ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_vf_err_poisonedcompl_s0 {} {
        set tile                    [ip_get "parameter.TILE.value"]
        set top_topology_hwtcl      [ip_get "parameter.top_topology_hwtcl.value"]

        if {$tile == "P-TILE" || $tile == "R-TILE"} {
            if { [regexp "x16" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "x8" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "x4" $top_topology_hwtcl] } {
                set core_num 4
            }
            
            for { set i 0 } { $i < [expr $core_num] } { incr i } {
                set_interface_property p${i}_ss_app_vf_err_poisonedcompl_s0 associatedClock p${i}_axi_lite_clk
            }

        } elseif {$tile == "F-TILE"} {
            if { [regexp "1x16" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "2x8" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "4x4" $top_topology_hwtcl] } {
                set core_num 4
            } elseif { [regexp "1x4" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "2x4" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "1x8" $top_topology_hwtcl] } {
                set core_num 1
            }


            if { [regexp "2x4" $top_topology_hwtcl] } {
                set_interface_property p0_ss_app_vf_err_poisonedcompl_s0 associatedClock p0_axi_lite_clk
                set_interface_property p2_ss_app_vf_err_poisonedcompl_s0 associatedClock p2_axi_lite_clk

            } else {
                for { set i 0 } { $i < [expr $core_num] } { incr i } {
                    set_interface_property p${i}_ss_app_vf_err_poisonedcompl_s0 associatedClock p${i}_axi_lite_clk

                }
            }
        }
    }

    proc ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_vf_err_poisonedcompl_s1 {} {
        set tile                    [ip_get "parameter.TILE.value"]
        set top_topology_hwtcl      [ip_get "parameter.top_topology_hwtcl.value"]

        if {$tile == "P-TILE" || $tile == "R-TILE"} {
            if { [regexp "x16" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "x8" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "x4" $top_topology_hwtcl] } {
                set core_num 2
            }
            
            for { set i 0 } { $i < [expr $core_num] } { incr i } {
                set_interface_property p${i}_ss_app_vf_err_poisonedcompl_s1 associatedClock p${i}_axi_lite_clk
            }

        } elseif {$tile == "F-TILE"} {
            if { [regexp "1x16" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "2x8" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "4x4" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "1x4" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "2x4" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "1x8" $top_topology_hwtcl] } {
                set core_num 1
            }


            if { [regexp "2x4" $top_topology_hwtcl] } {
                set_interface_property p0_ss_app_vf_err_poisonedcompl_s1 associatedClock p0_axi_lite_clk

            } else {
                for { set i 0 } { $i < [expr $core_num] } { incr i } {
                    set_interface_property p${i}_ss_app_vf_err_poisonedcompl_s1 associatedClock p${i}_axi_lite_clk

                }
            }
        }
    }

    proc ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_vf_err_poisonedcompl_s2 {} {
        set top_topology_hwtcl                      [ip_get "parameter.top_topology_hwtcl.value"]

         set_interface_property p0_ss_app_vf_err_poisonedcompl_s2 associatedClock p0_axi_lite_clk        
    }
    proc ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_vf_err_poisonedcompl_s3 {} {
        set top_topology_hwtcl                      [ip_get "parameter.top_topology_hwtcl.value"]

        set_interface_property p0_ss_app_vf_err_poisonedcompl_s3 associatedClock p0_axi_lite_clk        
    }

    proc ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_vf_err_ur_postedreq_s0 {} {
        set tile                    [ip_get "parameter.TILE.value"]
        set top_topology_hwtcl      [ip_get "parameter.top_topology_hwtcl.value"]

        if {$tile == "P-TILE" || $tile == "R-TILE"} {
            if { [regexp "x16" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "x8" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "x4" $top_topology_hwtcl] } {
                set core_num 4
            }
            
            for { set i 0 } { $i < [expr $core_num] } { incr i } {
                set_interface_property p${i}_ss_app_vf_err_ur_postedreq_s0 associatedClock p${i}_axi_lite_clk
            }

        } elseif {$tile == "F-TILE"} {
            if { [regexp "1x16" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "2x8" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "4x4" $top_topology_hwtcl] } {
                set core_num 4
            } elseif { [regexp "1x4" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "2x4" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "1x8" $top_topology_hwtcl] } {
                set core_num 1
            }


            if { [regexp "2x4" $top_topology_hwtcl] } {
                set_interface_property p0_ss_app_vf_err_ur_postedreq_s0 associatedClock p0_axi_lite_clk
                set_interface_property p2_ss_app_vf_err_ur_postedreq_s0 associatedClock p2_axi_lite_clk

            } else {
                for { set i 0 } { $i < [expr $core_num] } { incr i } {
                    set_interface_property p${i}_ss_app_vf_err_ur_postedreq_s0 associatedClock p${i}_axi_lite_clk

                }
            }
        }
    }

    proc ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_vf_err_ur_postedreq_s1 {} {
        set tile                    [ip_get "parameter.TILE.value"]
        set top_topology_hwtcl      [ip_get "parameter.top_topology_hwtcl.value"]

        if {$tile == "P-TILE" || $tile == "R-TILE"} {
            if { [regexp "x16" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "x8" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "x4" $top_topology_hwtcl] } {
                set core_num 2
            }
            
            for { set i 0 } { $i < [expr $core_num] } { incr i } {
                set_interface_property p${i}_ss_app_vf_err_ur_postedreq_s1 associatedClock p${i}_axi_lite_clk
            }

        } elseif {$tile == "F-TILE"} {
            if { [regexp "1x16" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "2x8" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "4x4" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "1x4" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "2x4" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "1x8" $top_topology_hwtcl] } {
                set core_num 1
            }


            if { [regexp "2x4" $top_topology_hwtcl] } {
                set_interface_property p0_ss_app_vf_err_ur_postedreq_s1 associatedClock p0_axi_lite_clk

            } else {
                for { set i 0 } { $i < [expr $core_num] } { incr i } {
                    set_interface_property p${i}_ss_app_vf_err_ur_postedreq_s1 associatedClock p${i}_axi_lite_clk

                }
            }
        }
    }

    proc ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_vf_err_ur_postedreq_s2 {} {
        set top_topology_hwtcl                      [ip_get "parameter.top_topology_hwtcl.value"]
        set_interface_property p0_ss_app_vf_err_ur_postedreq_s2 associatedClock p0_axi_lite_clk
    }
    proc ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_vf_err_ur_postedreq_s3 {} {
        set top_topology_hwtcl                      [ip_get "parameter.top_topology_hwtcl.value"]

        set_interface_property p0_ss_app_vf_err_ur_postedreq_s3 associatedClock p0_axi_lite_clk
        
    }

    proc ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_vf_err_ca_postedreq_s0 {} {
        set tile                    [ip_get "parameter.TILE.value"]
        set top_topology_hwtcl      [ip_get "parameter.top_topology_hwtcl.value"]

        if {$tile == "P-TILE" || $tile == "R-TILE"} {
            if { [regexp "x16" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "x8" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "x4" $top_topology_hwtcl] } {
                set core_num 4
            }
            
            for { set i 0 } { $i < [expr $core_num] } { incr i } {
                set_interface_property p${i}_ss_app_vf_err_ca_postedreq_s0 associatedClock p${i}_axi_lite_clk
            }

        } elseif {$tile == "F-TILE"} {
            if { [regexp "1x16" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "2x8" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "4x4" $top_topology_hwtcl] } {
                set core_num 4
            } elseif { [regexp "1x4" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "2x4" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "1x8" $top_topology_hwtcl] } {
                set core_num 1
            }


            if { [regexp "2x4" $top_topology_hwtcl] } {
                set_interface_property p0_ss_app_vf_err_ca_postedreq_s0 associatedClock p0_axi_lite_clk
                set_interface_property p2_ss_app_vf_err_ca_postedreq_s0 associatedClock p2_axi_lite_clk

            } else {
                for { set i 0 } { $i < [expr $core_num] } { incr i } {
                    set_interface_property p${i}_ss_app_vf_err_ca_postedreq_s0 associatedClock p${i}_axi_lite_clk

                }
            }
        }
    }

    proc ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_vf_err_ca_postedreq_s1 {} {
        set tile                    [ip_get "parameter.TILE.value"]
        set top_topology_hwtcl      [ip_get "parameter.top_topology_hwtcl.value"]

        if {$tile == "P-TILE" || $tile == "R-TILE"} {
            if { [regexp "x16" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "x8" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "x4" $top_topology_hwtcl] } {
                set core_num 2
            }
            
            for { set i 0 } { $i < [expr $core_num] } { incr i } {
                set_interface_property p${i}_ss_app_vf_err_ca_postedreq_s1 associatedClock p${i}_axi_lite_clk
            }

        } elseif {$tile == "F-TILE"} {
            if { [regexp "1x16" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "2x8" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "4x4" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "1x4" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "2x4" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "1x8" $top_topology_hwtcl] } {
                set core_num 1
            }


            if { [regexp "2x4" $top_topology_hwtcl] } {
                set_interface_property p0_ss_app_vf_err_ca_postedreq_s1 associatedClock p0_axi_lite_clk

            } else {
                for { set i 0 } { $i < [expr $core_num] } { incr i } {
                    set_interface_property p${i}_ss_app_vf_err_ca_postedreq_s1 associatedClock p${i}_axi_lite_clk

                }
            }
        }
    }
     
    proc ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_vf_err_ca_postedreq_s2 {} {
        set top_topology_hwtcl                      [ip_get "parameter.top_topology_hwtcl.value"]
        
        set_interface_property p0_ss_app_vf_err_ca_postedreq_s2 associatedClock p0_axi_lite_clk
        
    }
     
    proc ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_vf_err_ca_postedreq_s3 {} {
        set top_topology_hwtcl                      [ip_get "parameter.top_topology_hwtcl.value"]

        set_interface_property p0_ss_app_vf_err_ca_postedreq_s3 associatedClock p0_axi_lite_clk        
    }
     
    proc ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_vf_err_vf_num_s0 {} {
        set tile                    [ip_get "parameter.TILE.value"]
        set top_topology_hwtcl      [ip_get "parameter.top_topology_hwtcl.value"]

        if {$tile == "P-TILE" || $tile == "R-TILE"} {
            if { [regexp "x16" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "x8" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "x4" $top_topology_hwtcl] } {
                set core_num 4
            }
            
            for { set i 0 } { $i < [expr $core_num] } { incr i } {
                set_interface_property p${i}_ss_app_vf_err_vf_num_s0 associatedClock p${i}_axi_lite_clk
            }

        } elseif {$tile == "F-TILE"} {
            if { [regexp "1x16" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "2x8" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "4x4" $top_topology_hwtcl] } {
                set core_num 4
            } elseif { [regexp "1x4" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "2x4" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "1x8" $top_topology_hwtcl] } {
                set core_num 1
            }


            if { [regexp "2x4" $top_topology_hwtcl] } {
                set_interface_property p0_ss_app_vf_err_vf_num_s0 associatedClock p0_axi_lite_clk
                set_interface_property p2_ss_app_vf_err_vf_num_s0 associatedClock p2_axi_lite_clk

            } else {
                for { set i 0 } { $i < [expr $core_num] } { incr i } {
                    set_interface_property p${i}_ss_app_vf_err_vf_num_s0 associatedClock p${i}_axi_lite_clk

                }
            }
        }
    }

    proc ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_vf_err_vf_num_s1 {} {
        set tile                    [ip_get "parameter.TILE.value"]
        set top_topology_hwtcl      [ip_get "parameter.top_topology_hwtcl.value"]

        if {$tile == "P-TILE" || $tile == "R-TILE"} {
            if { [regexp "x16" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "x8" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "x4" $top_topology_hwtcl] } {
                set core_num 2
            }
            
            for { set i 0 } { $i < [expr $core_num] } { incr i } {
                set_interface_property p${i}_ss_app_vf_err_vf_num_s1 associatedClock p${i}_axi_lite_clk
            }

        } elseif {$tile == "F-TILE"} {
            if { [regexp "1x16" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "2x8" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "4x4" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "1x4" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "2x4" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "1x8" $top_topology_hwtcl] } {
                set core_num 1
            }

            if { [regexp "2x4" $top_topology_hwtcl] } {
                set_interface_property p0_ss_app_vf_err_vf_num_s1 associatedClock p0_axi_lite_clk

            } else {
                for { set i 0 } { $i < [expr $core_num] } { incr i } {
                    set_interface_property p${i}_ss_app_vf_err_vf_num_s1 associatedClock p${i}_axi_lite_clk

                }
            }
        }
    }

    proc ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_vf_err_vf_num_s2 {} {
        set top_topology_hwtcl                      [ip_get "parameter.top_topology_hwtcl.value"]
        set_interface_property p0_ss_app_vf_err_vf_num_s2 associatedClock p0_axi_lite_clk
        
    }
    proc ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_vf_err_vf_num_s3 {} {
        set top_topology_hwtcl                      [ip_get "parameter.top_topology_hwtcl.value"]
        set_interface_property p0_ss_app_vf_err_vf_num_s3 associatedClock p0_axi_lite_clk
        
    }

    proc ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_vf_err_func_num_s0 {} {
        set tile                    [ip_get "parameter.TILE.value"]
        set top_topology_hwtcl      [ip_get "parameter.top_topology_hwtcl.value"]

        if {$tile == "P-TILE" || $tile == "R-TILE"} {
            if { [regexp "x16" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "x8" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "x4" $top_topology_hwtcl] } {
                set core_num 4
            }
            
            for { set i 0 } { $i < [expr $core_num] } { incr i } {
                set_interface_property p${i}_ss_app_vf_err_func_num_s0 associatedClock p${i}_axi_lite_clk
            }

        } elseif {$tile == "F-TILE"} {
            if { [regexp "1x16" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "2x8" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "4x4" $top_topology_hwtcl] } {
                set core_num 4
            } elseif { [regexp "1x4" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "2x4" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "1x8" $top_topology_hwtcl] } {
                set core_num 1
            }


            if { [regexp "2x4" $top_topology_hwtcl] } {
                set_interface_property p0_ss_app_vf_err_func_num_s0 associatedClock p0_axi_lite_clk
                set_interface_property p2_ss_app_vf_err_func_num_s0 associatedClock p2_axi_lite_clk

            } else {
                for { set i 0 } { $i < [expr $core_num] } { incr i } {
                    set_interface_property p${i}_ss_app_vf_err_func_num_s0 associatedClock p${i}_axi_lite_clk

                }
            }
        }
    }

    proc ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_vf_err_func_num_s1 {} {
        set tile                    [ip_get "parameter.TILE.value"]
        set top_topology_hwtcl      [ip_get "parameter.top_topology_hwtcl.value"]

        if {$tile == "P-TILE" || $tile == "R-TILE"} {
            if { [regexp "x16" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "x8" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "x4" $top_topology_hwtcl] } {
                set core_num 2
            }
            
            for { set i 0 } { $i < [expr $core_num] } { incr i } {
                set_interface_property p${i}_ss_app_vf_err_func_num_s1 associatedClock p${i}_axi_lite_clk
            }

        } elseif {$tile == "F-TILE"} {
            if { [regexp "1x16" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "2x8" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "4x4" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "1x4" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "2x4" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "1x8" $top_topology_hwtcl] } {
                set core_num 1
            }

            if { [regexp "2x4" $top_topology_hwtcl] } {
                set_interface_property p0_ss_app_vf_err_func_num_s1 associatedClock p0_axi_lite_clk

            } else {
                for { set i 0 } { $i < [expr $core_num] } { incr i } {
                    set_interface_property p${i}_ss_app_vf_err_func_num_s1 associatedClock p${i}_axi_lite_clk

                }
            }
        }
    }

    proc ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_vf_err_func_num_s2 {} {
        set top_topology_hwtcl                      [ip_get "parameter.top_topology_hwtcl.value"]
        set_interface_property p0_ss_app_vf_err_func_num_s2 associatedClock p0_axi_lite_clk
        
    }

    proc ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_vf_err_func_num_s3 {} {
        set top_topology_hwtcl                      [ip_get "parameter.top_topology_hwtcl.value"]

        set_interface_property p0_ss_app_vf_err_func_num_s3 associatedClock p0_axi_lite_clk
       
    }

    proc ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_vf_err_overflow  {} {
        set tile                    [ip_get "parameter.TILE.value"]
        set top_topology_hwtcl      [ip_get "parameter.top_topology_hwtcl.value"]

        if {$tile == "P-TILE" || $tile == "R-TILE"} {
            if { [regexp "x16" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "x8" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "x4" $top_topology_hwtcl] } {
                set core_num 4
            }
            
            for { set i 0 } { $i < [expr $core_num] } { incr i } {
                set_interface_property p${i}_ss_app_vf_err_overflow associatedClock p${i}_axi_lite_clk
            }

        } elseif {$tile == "F-TILE"} {
            if { [regexp "1x16" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "2x8" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "4x4" $top_topology_hwtcl] } {
                set core_num 4
            } elseif { [regexp "1x4" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "2x4" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "1x8" $top_topology_hwtcl] } {
                set core_num 1
            }


            if { [regexp "2x4" $top_topology_hwtcl] } {
                set_interface_property p0_ss_app_vf_err_overflow associatedClock p0_axi_lite_clk
                set_interface_property p2_ss_app_vf_err_overflow associatedClock p2_axi_lite_clk

            } else {
                for { set i 0 } { $i < [expr $core_num] } { incr i } {
                    set_interface_property p${i}_ss_app_vf_err_overflow associatedClock p${i}_axi_lite_clk

                }
            }
        }
    }

    proc ::intel_pcie_ss_axi::interfaces::elaborate_ss_app_vfnonfatalmsg_ready {} {
        set tile                    [ip_get "parameter.TILE.value"]
        set top_topology_hwtcl      [ip_get "parameter.top_topology_hwtcl.value"]

        if {$tile == "P-TILE" || $tile == "R-TILE"} {
            if { [regexp "x16" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "x8" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "x4" $top_topology_hwtcl] } {
                set core_num 4
            }
            
            for { set i 0 } { $i < [expr $core_num] } { incr i } {
                set_interface_property p${i}_ss_app_vfnonfatalmsg_ready associatedClock p${i}_axi_lite_clk
            }

        } elseif {$tile == "F-TILE"} {
            if { [regexp "1x16" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "2x8" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "4x4" $top_topology_hwtcl] } {
                set core_num 4
            } elseif { [regexp "1x4" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "2x4" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "1x8" $top_topology_hwtcl] } {
                set core_num 1
            }


            if { [regexp "2x4" $top_topology_hwtcl] } {
                set_interface_property p0_ss_app_vfnonfatalmsg_ready associatedClock p0_axi_lite_clk
                set_interface_property p2_ss_app_vfnonfatalmsg_ready associatedClock p2_axi_lite_clk

            } else {
                for { set i 0 } { $i < [expr $core_num] } { incr i } {
                    set_interface_property p${i}_ss_app_vfnonfatalmsg_ready associatedClock p${i}_axi_lite_clk

                }
            }
        }
    }

    proc ::intel_pcie_ss_axi::interfaces::elaborate_app_ss_sent_vfnonfatalmsg {} {
        set tile                    [ip_get "parameter.TILE.value"]
        set top_topology_hwtcl      [ip_get "parameter.top_topology_hwtcl.value"]

        if {$tile == "P-TILE" || $tile == "R-TILE"} {
            if { [regexp "x16" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "x8" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "x4" $top_topology_hwtcl] } {
                set core_num 4
            }
            
            for { set i 0 } { $i < [expr $core_num] } { incr i } {
                set_interface_property p${i}_app_ss_sent_vfnonfatalmsg associatedClock p${i}_axi_lite_clk
            }

        } elseif {$tile == "F-TILE"} {
            if { [regexp "1x16" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "2x8" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "4x4" $top_topology_hwtcl] } {
                set core_num 4
            } elseif { [regexp "1x4" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "2x4" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "1x8" $top_topology_hwtcl] } {
                set core_num 1
            }


            if { [regexp "2x4" $top_topology_hwtcl] } {
                set_interface_property p0_app_ss_sent_vfnonfatalmsg associatedClock p0_axi_lite_clk
                set_interface_property p2_app_ss_sent_vfnonfatalmsg associatedClock p2_axi_lite_clk

            } else {
                for { set i 0 } { $i < [expr $core_num] } { incr i } {
                    set_interface_property p${i}_app_ss_sent_vfnonfatalmsg associatedClock p${i}_axi_lite_clk

                }
            }
        }
    }

    proc ::intel_pcie_ss_axi::interfaces::elaborate_app_ss_vfnonfatalmsg_vf_num {} {
        set tile                    [ip_get "parameter.TILE.value"]
        set top_topology_hwtcl      [ip_get "parameter.top_topology_hwtcl.value"]

        if {$tile == "P-TILE" || $tile == "R-TILE"} {
            if { [regexp "x16" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "x8" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "x4" $top_topology_hwtcl] } {
                set core_num 4
            }
            
            for { set i 0 } { $i < [expr $core_num] } { incr i } {
                set_interface_property p${i}_app_ss_vfnonfatalmsg_vf_num associatedClock p${i}_axi_lite_clk
            }

        } elseif {$tile == "F-TILE"} {
            if { [regexp "1x16" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "2x8" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "4x4" $top_topology_hwtcl] } {
                set core_num 4
            } elseif { [regexp "1x4" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "2x4" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "1x8" $top_topology_hwtcl] } {
                set core_num 1
            }


            if { [regexp "2x4" $top_topology_hwtcl] } {
                set_interface_property p0_app_ss_vfnonfatalmsg_vf_num associatedClock p0_axi_lite_clk
                set_interface_property p2_app_ss_vfnonfatalmsg_vf_num associatedClock p2_axi_lite_clk

            } else {
                for { set i 0 } { $i < [expr $core_num] } { incr i } {
                    set_interface_property p${i}_app_ss_vfnonfatalmsg_vf_num associatedClock p${i}_axi_lite_clk

                }
            }
        }
    }

    proc ::intel_pcie_ss_axi::interfaces::elaborate_app_ss_vfnonfatalmsg_func_num {} {
        set tile                    [ip_get "parameter.TILE.value"]
        set top_topology_hwtcl      [ip_get "parameter.top_topology_hwtcl.value"]

        if {$tile == "P-TILE" || $tile == "R-TILE"} {
            if { [regexp "x16" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "x8" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "x4" $top_topology_hwtcl] } {
                set core_num 4
            }
            
            for { set i 0 } { $i < [expr $core_num] } { incr i } {
                set_interface_property p${i}_app_ss_vfnonfatalmsg_func_num associatedClock p${i}_axi_lite_clk
            }

        } elseif {$tile == "F-TILE"} {
            if { [regexp "1x16" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "2x8" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "4x4" $top_topology_hwtcl] } {
                set core_num 4
            } elseif { [regexp "1x4" $top_topology_hwtcl] } {
                set core_num 1
            } elseif { [regexp "2x4" $top_topology_hwtcl] } {
                set core_num 2
            } elseif { [regexp "1x8" $top_topology_hwtcl] } {
                set core_num 1
            }


            if { [regexp "2x4" $top_topology_hwtcl] } {
                set_interface_property p0_app_ss_vfnonfatalmsg_func_num associatedClock p0_axi_lite_clk
                set_interface_property p2_app_ss_vfnonfatalmsg_func_num associatedClock p2_axi_lite_clk

            } else {
                for { set i 0 } { $i < [expr $core_num] } { incr i } {
                    set_interface_property p${i}_app_ss_vfnonfatalmsg_func_num associatedClock p${i}_axi_lite_clk

                }
            }
        }
    }

}
#end of namespace



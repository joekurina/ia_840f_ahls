# Copyright (c) 2020 Intel Corporation. All rights reserved.

# Your use of Intel Corporation's design tools, logic functions
# and other software and tools, and any partner logic 
# functions, and any output files from any of the foregoing 
# (including device programming or simulation files), and any 
# associated documentation or information are expressly subject 
# to the terms and conditions of the Intel Program License 
# Subscription Agreement, the Intel Quartus Prime License Agreement,
# the Intel FPGA IP License Agreement, or other applicable license
# agreement, including, without limitation, that your use is for
# the sole purpose of programming logic devices manufactured by
# Intel and sold by Intel or its authorized distributors.  Please
# refer to the applicable agreement for further details, at
# https://fpgasoftware.intel.com/eula.


namespace eval dni_ipgenerate_task {
	variable id [flng::get_next_available_id -type task_definition]
	variable task1 [flng::add_object -type task_definition -number $id -name "dni_ipgenerate"]
	
    flng::set_property -object $task1 -name identifier -value "IP Generation"
    flng::set_property -object $task1 -name internal_identifier -value "IP Generation Tool"
	flng::set_property -object $task1 -name description -value "Run IP Generate"
	flng::set_property -object $task1 -name smart_action -value "IP_GEN"
	flng::set_property -object $task1 -name msgdb_file -value [list "ipg"]
	flng::set_property -object $task1 -name part_trait -value [list "!REQUIRE_DS_TOOL"]
	flng::set_property -object $task1 -name shell_command_template -value "quartus_ipgenerate \"@project\" -c @revision --run_default_mode_op"
	
	flng::add_property -object $task1 -name parameters:project -value "please specify project name"
	flng::add_property -object $task1 -name parameters:revision -value "please specify revision name"

    variable task_param
	variable tool_2_list {}
	variable task_identifier [flng::get_property -name identifier -object $task1]
	variable settings_dialog [flng::get_objects -type tool_definition -name "settings_dialog"]
	if {$settings_dialog == ""} {
		error "Error: unable to find Settings Dialog tool definition"
	} else {
		set task_param [flng::get_property -name task_to_param -object $settings_dialog]
		dict set task_param $task_identifier "ip_settings"
		flng::set_property -object $settings_dialog -name task_to_param -value $task_param

		lappend tool_2_list $settings_dialog
	}
    
    flng::set_property -object $task1 -name enable_quartus_ini_name -value "disable_flow_ipgen"
    flng::set_property -object $task1 -name enable_quartus_ini_value -value "off"

    flng::set_property -object $task1 -name storage_engine -value "qhd"
	flng::set_property -object $task1 -name tools_2 -value $tool_2_list
}

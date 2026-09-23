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


namespace eval fitter_retime_task {
	variable id [flng::get_next_available_id -type task_definition]
	variable task1 [flng::add_object -type task_definition -number $id -name "fitter_retime"]
	
	flng::set_property -object $task1 -name identifier -value "Retime"
	flng::set_property -object $task1 -name description -value "Run Fitter Retime"
	flng::set_property -object $task1 -name smart_action -value "FIT_ROUTE"
	flng::set_property -object $task1 -name checkpoint -value "retimed"
	flng::set_property -object $task1 -name msgdb_file -value [list "fit.retime.header" "fit.retime"]

    variable family_traits [list "HAS_CORE_HIPI_SUPPORT"]
	flng::set_property -object $task1 -name family_trait -value $family_traits
	
	
	flng::set_property -object $task1 -name shell_command_template -value "quartus_fit --read_settings_files=on --write_settings_files=off \"@project\" -c @revision --retime"
	flng::set_property -object $task1 -name shell_command_subtask_arg -value "--retime"
	
	flng::add_property -object $task1 -name parameters:project -value "please specify project name"
	flng::add_property -object $task1 -name parameters:revision -value "please specify revision name"

    variable task_param
    variable task_help
	variable tool_list {}
	variable task_identifier [flng::get_property -name identifier -object $task1]
	variable report_tool [flng::get_objects -type tool_definition -name "report_viewer"]
	if {$report_tool == ""} {
		error "Error: unable to find Report Viewer"
	} else {
		set task_param [flng::get_property -name task_to_param -object $report_tool]
		dict set task_param $task_identifier "Fitter||Retime Stage"
		flng::set_property -object $report_tool -name task_to_param -value $task_param

		lappend tool_list $report_tool
	}

	variable timing_tool [flng::get_objects -type tool_definition -name "timing_analyzer"]
	if {$timing_tool == ""} {
		error "Error: unable to find Timing Analyzer"
	} else {
		set task_param [flng::get_property -name task_to_param -object $timing_tool]
		dict set task_param $task_identifier "retimed"
		flng::set_property -object $timing_tool -name task_to_param -value $task_param

		set task_help [flng::get_property -name task_to_help -object $timing_tool]
		dict set task_help $task_identifier "information"
		flng::set_property -object $timing_tool -name task_to_help -value $task_help

		lappend tool_list $timing_tool
	}

	variable tech_map_tool [flng::get_objects -type tool_definition -name "tech_map_viewer"]
	if {$tech_map_tool == ""} {
		error "Error: unable to find Technology Map Viewer"
	} else {
		set task_param [flng::get_property -name task_to_param -object $tech_map_tool]
		dict set task_param $task_identifier "retimed"
		flng::set_property -object $tech_map_tool -name task_to_param -value $task_param

		set task_help [flng::get_property -name task_to_help -object $tech_map_tool]
		dict set task_help $task_identifier "information"
		flng::set_property -object $tech_map_tool -name task_to_help -value $task_help

		lappend tool_list $tech_map_tool
	}

    flng::set_property -object $task1 -name storage_engine -value "qhd"
	flng::set_property -object $task1 -name tools -value $tool_list
    flng::set_property -object $task1 -name enable_quartus_ini_name -value "force_disable_hyper_retimer"
    flng::set_property -object $task1 -name enable_quartus_ini_value -value "off"
}

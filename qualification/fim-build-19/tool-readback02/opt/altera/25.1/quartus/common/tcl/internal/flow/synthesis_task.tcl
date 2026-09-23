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


namespace eval synthesis_task {
	if {[catch {flng::get_next_available_id -type task_definition} id]} {
        return 0    
    }

    if {[catch {flng::add_object -type task_definition -number $id -name "synthesis"} task1]} {
        post_message -type error "Fail to create the synthesis task definition."
        return 0
    }
	
	flng::set_property -object $task1 -name identifier -value "Analysis & Synthesis"
	flng::set_property -object $task1 -name description -value "Run Synthesis"
	flng::set_property -object $task1 -name smart_action -value "SOURCE SIGNALTAP INCR_TAP TLG MIF"
	flng::set_property -object $task1 -name checkpoint -value "synthesized"
	flng::set_property -object $task1 -name msgdb_file -value [list "syn"]

	flng::set_property -object $task1 -name shell_command_template -value "quartus_syn --classic --read_settings_files=on --write_settings_files=off \"@project\" -c @revision @rapid_recompile@optimization_mode"
	
	flng::add_property -object $task1 -name parameters:project -value "please specify project name"
	flng::add_property -object $task1 -name parameters:revision -value "please specify revision name"
	flng::add_property -object $task1 -name parameters:rapid_recompile -value ""
	flng::add_property -object $task1 -name parameters:optimization_mode -value ""
    
    variable task_param
	variable tool_list {}
	variable task_identifier [flng::get_property -name identifier -object $task1]
	variable report_tool [flng::get_objects -type tool_definition -name "report_viewer"]
	if {$report_tool == ""} {
		error "Error: unable to find Report Viewer"
	} else {
		set task_param [flng::get_property -name task_to_param -object $report_tool]
		dict set task_param $task_identifier "Synthesis"
		flng::set_property -object $report_tool -name task_to_param -value $task_param

		lappend tool_list $report_tool
	}

	variable rtl_tool [flng::get_objects -type tool_definition -name "rtl_viewer"]
	if {$rtl_tool == ""} {
		error "Error: unable to find RTL Viewer"
	} else {
		lappend tool_list $rtl_tool
	}

	variable tech_map_pm_tool [flng::get_objects -type tool_definition -name "tech_map_pm_viewer"]
	if {$tech_map_pm_tool == ""} {
		error "Error: unable to find Technology Map Viewer (Post-Mapping)"
	} else {
		lappend tool_list $tech_map_pm_tool
	}

	flng::set_property -object $task1 -name tools -value $tool_list

	variable tool_2_list {}
	variable settings_dialog [flng::get_objects -type tool_definition -name "settings_dialog"]
	if {$settings_dialog == ""} {
		error "Error: unable to find Settings Dialog tool definition"
	} else {
		set task_param [flng::get_property -name task_to_param -object $settings_dialog]
		dict set task_param $task_identifier "compiler"
		flng::set_property -object $settings_dialog -name task_to_param -value $task_param

		lappend tool_2_list $settings_dialog
	}
    
    flng::set_property -object $task1 -name storage_engine -value "qhd"
	flng::set_property -object $task1 -name tools_2 -value $tool_2_list
}

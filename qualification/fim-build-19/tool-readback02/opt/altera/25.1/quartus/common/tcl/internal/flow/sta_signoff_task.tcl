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


namespace eval sta_signoff_task {
	variable id [flng::get_next_available_id -type task_definition]
	variable task1 [flng::add_object -type task_definition -number $id -name "sta_signoff"]

    flng::set_property -object $task1 -name identifier -value "Timing Analysis (Signoff)"
	flng::set_property -object $task1 -name internal_identifier -value "Timing Analysis (Finalize)"
	flng::set_property -object $task1 -name description -value "Run timing analysis"
	flng::set_property -object $task1 -name smart_action -value "TAN"
	flng::set_property -object $task1 -name msgdb_file -value [list "sta"]
	flng::set_property -object $task1 -name shell_command_template -value "quartus_sta \"@project\" -c @revision --mode=finalize"
	flng::set_property -object $task1 -name input -value "TBD"
	flng::set_property -object $task1 -name output -value "TBD"
    flng::set_property -object $task1 -name presentation -value "AFCQ_START_STA_ICON"
	flng::add_property -object $task1 -name parameters:project -value "please specify project name"
	flng::add_property -object $task1 -name parameters:revision -value "please specify revision name"
    flng::set_property -object $task1 -name part_trait -value [list "!WHITEBOARD_SUPPORT"]
	
    variable task_param
	variable tool_list {}
	variable task_identifier [flng::get_property -name identifier -object $task1]
	variable report_tool [flng::get_objects -type tool_definition -name "report_viewer"]
	if {$report_tool == ""} {
		error "Error: unable to find Report Viewer"
	} else {
		set task_param [flng::get_property -name task_to_param -object $report_tool]
		dict set task_param $task_identifier "Timing Analyzer||Timing Analyzer Summary"
		flng::set_property -object $report_tool -name task_to_param -value $task_param

		lappend tool_list $report_tool
	}

    variable timing_tool [flng::get_objects -type tool_definition -name "signoff_timing_analyzer"]
    if {$timing_tool == ""} {
        error "Error: unable to find Timing Analyzer"
    } else {
        lappend tool_list $timing_tool
    }

	flng::set_property -object $task1 -name tools -value $tool_list

	variable tool_2_list {}
    variable settings_dialog [flng::get_objects -type tool_definition -name "settings_dialog"]
    if {$settings_dialog == ""} {
        error "Error: unable to find Settings Dialog tool definition"
    } else {
        set task_param [flng::get_property -name task_to_param -object $settings_dialog]
        dict set task_param $task_identifier "sta"
        flng::set_property -object $settings_dialog -name task_to_param -value $task_param

        lappend tool_2_list $settings_dialog
    }
    
    flng::set_property -object $task1 -name storage_engine -value "qhd"
	flng::set_property -object $task1 -name tools_2 -value $tool_2_list
    flng::set_property -object $task1 -name no_fitter_implement_progress_bar -value "1"
}

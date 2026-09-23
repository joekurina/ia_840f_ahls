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


namespace eval compile_flow {
    variable flow_id [flng::get_next_available_id -type flow]
    variable flow [flng::add_object -type flow_definition -number $flow_id -name classic_compile]
    flng::set_property -object $flow -name identifier -value "Full Compilation"
    flng::set_property -object $flow -name gui_display -value "Compile Design"
    flng::set_property -object $flow -name description -value "Run Full Compilation (Classic)"
    flng::set_property -object $flow -name storage_engine -value "qhd"
    flng::set_property -object $flow -name enable_pre_post_flow_script -value 1

    variable ipgen [flng::get_objects -type task_definition -name "ipgenerate"]
    if {$ipgen == ""} {
        error "Error: unable to find ipgenerate task"
    } else {
        lappend task_list $ipgen
    }

    variable tileip_generation [flng::get_objects -type task_definition -name "tileip_generation"]
    if {$tileip_generation == ""} {
        error "Error: unable to find Plan Interface task"
    } else {
        lappend task_list $tileip_generation
    }

    variable qsyn [flng::get_objects -type task_definition -name "synthesis"]
    if {$qsyn == ""} {
        error "Error: unable to find synthesis task"
    } else {
        lappend task_list $qsyn
    }

    variable qfit [flng::get_objects -type task_definition -name "fitter"]
    if {$qfit == ""} {
        error "Error: unable to find fitter task"
    } else {
        lappend task_list $qfit
    }

    variable fit_fastforward_timing [flng::get_objects -type task_definition -name "fitter_fastforward_timing"]
    if {$fit_fastforward_timing == ""} {
        error "Error: unable to find fit_fastforward_timing task."
    } else {
        lappend task_list $fit_fastforward_timing
    }

    variable qsta [flng::get_objects -type task_definition -name "sta_signoff"]
    if {$qsta == ""} {
        error "Error: unable to find sta_signoff task"
    } else {
        lappend task_list $qsta
    }

	variable qpow [flng::get_objects -type task_definition -name "power"]
    if {$qpow == ""} {
        error "Error: unable to find power analysis task."
    } else {
        lappend task_list $qpow
    }

    variable qasm [flng::get_objects -type task_definition -name "assembler"]
    if {$qasm == ""} {
        error "Error: unable to find assembler task."
    } else {
        lappend task_list $qasm
    }

    variable qeda [flng::get_objects -type task_definition -name "eda_netlist_writer"]
    if {$qeda == ""} {
        error "Error: unable to find netlist writer task."
    } else {
        lappend task_list $qeda
    }

    variable npp_preprocess [flng::get_objects -type task_definition -name "npp_preprocess"]
    if {$npp_preprocess == ""} {
        error "Error: unable to find npp_preprocess task."
    } else {
        lappend task_list $npp_preprocess
    }

    
    flng::set_property -object $flow -name tasks -value $task_list
    flng::set_property -object $flow -name prerequisite -value [list "task:eda_netlist_writer,task:fitter_plan" "task:fitter_fastforward_timing,task:fitter_route"]
    
    flng::add_property -object $flow -name depends_on:$ipgen -value [list $tileip_generation $qsyn]
    flng::add_property -object $flow -name depends_on:$tileip_generation -value $qsyn
    flng::add_property -object $flow -name depends_on:$qsyn -value [list $qfit $qeda]    
    flng::add_property -object $flow -name depends_on:$qfit -value [list $fit_fastforward_timing $qeda $qasm $qpow $qsta $npp_preprocess]

    flng::add_property -object $flow -name parameters:rapid_recompile -value ""
    flng::add_property -object $flow -name parameters:optimization_mode -value ""



    flng::set_property -object $flow -name config_dependency_function -value "compile_flow::config_dependency"

    proc config_dependency {flow_id start_task end_task} {
        variable eda_inst ""
        variable qsyn ""
        variable fitter ""
        variable fitter_status ""
	    if {[catch {flng::get_objects -type task -name "eda_netlist_writer" -properties "flow=$flow_id"} eda_inst]} {
            return "0"
        }
        if {[catch {flng::get_objects -type task -name "fitter" -properties "flow=$flow_id"} fitter]} {
            return "0"
        }
        if {[catch {flng::get_objects -type task -name "synthesis" -properties "flow=$flow_id"} qsyn]} {
           return "0"
        }
        if {[catch {flng::get_property -object $fitter -name "status"} fitter_status]} {
            return "0"
        }
        variable fitter_percent 0
        if {$fitter_status != ""} {
            if {[catch {flng::get_property -object $fitter_status -name "percent"} fitter_percent]} {
                set percent 0
            }
        }

        if {$end_task == "task_definition:eda_netlist_writer" && $fitter_percent == 0} {
            flng::set_property -object $flow_id -name prerequisite -value [list "task:eda_netlist_writer,task:synthesis" "task:fitter_fastforward_timing,task:fitter_route"]
        } else {
            flng::set_property -object $flow_id -name prerequisite -value [] 
        }
        return "1"
    }
}



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


###############################################################################
#
#
# File:	    dni_compile_flow	
#           Compile flow definition using DNI
#
# @copyright Intel Corporation, 2020
#
#
###############################################################################

namespace eval dni_design_setup_debug_flow {
    variable flow_id [flng::get_next_available_id -type flow]
    variable flow [flng::add_object -type flow_definition -number $flow_id -name "dni_debug_design_setup"]
    flng::set_property -object $flow -name identifier -value "Debug Design Setup"
    flng::set_property -object $flow -name description -value "Run debug design setup"
    flng::set_property -object $flow -name storage_engine -value "dni"
    flng::add_property -object $flow -name parameters:sdc_file_path -value ""
    flng::add_property -object $flow -name parameters:annotate_sweep_hint -value ""

    variable task_list [list]

    variable setup_assignment_task [flng::get_objects -type task_definition -name "dni_setup_assignment"]
    if {$setup_assignment_task == ""} {
        error "Error: unable to find setup assignment task"
    } else {
        lappend task_list $setup_assignment_task
    }

    variable analysis_elaborate_task [flng::get_objects -type task_definition -name "dni_analysis_and_elaboration"]
    if {$analysis_elaborate_task == ""} {
        error "Error: unable to find analyze files task"
    } else {
        lappend task_list $analysis_elaborate_task
    }

    variable partition_task [flng::get_objects -type task_definition -name "dni_partition"]
    if {$partition_task == ""} {
        error "Error: unable to find partition task"
    } else {
        lappend task_list $partition_task
    }

    variable read_sdc_task [flng::get_objects -type task_definition -name "dni_read_sdc"]
    if {$read_sdc_task == ""} {
        error "Error: unable to find 'dni_read_sdc' task."
    } else {
        lappend task_list $read_sdc_task
    }

    variable sweep_task [flng::get_objects -type task_definition -name "dni_sweep"]
    if {$sweep_task == ""} {
        error "Error: unable to find sweep task"
    } else {
        lappend task_list $sweep_task
    }

    variable export_to_qdb_task [flng::get_objects -type task_definition -name "dni_export_to_qdb"]
    if {$export_to_qdb_task == ""} {
        error "Error: unable to export to qdb task"
    } else {
        lappend task_list $export_to_qdb_task
    }

    flng::set_property -object $flow -name tasks -value $task_list

    flng::add_property -object $flow -name depends_on:$setup_assignment_task -value $analysis_elaborate_task
    flng::add_property -object $flow -name depends_on:$analysis_elaborate_task -value $partition_task
    flng::add_property -object $flow -name depends_on:$partition_task -value $read_sdc_task
    flng::add_property -object $flow -name depends_on:$read_sdc_task -value $sweep_task
    flng::add_property -object $flow -name depends_on:$sweep_task -value $export_to_qdb_task
    flng::add_property -object $flow -name use_dms -value true -value_type bool
}

namespace eval dni_straight_design_setup_flow {
    variable flow_id [flng::get_next_available_id -type flow]
    variable flow [flng::add_object -type flow_definition -number $flow_id -name "dni_straight_design_setup"]
    flng::set_property -object $flow -name identifier -value "Straight Design Setup"
    flng::set_property -object $flow -name description -value "Run design setup without intermediate checkpoints"
    flng::add_property -object $flow -name parameters:sdc_file_path -value ""    

    variable task_list [list]

    variable straight_setup_design_task [flng::get_objects -type task_definition -name "dni_straight_setup_design"]
    if {$straight_setup_design_task == ""} {
        error "Error: unable to find straight setup design task"
    } else {
        lappend task_list $straight_setup_design_task
    }

    variable export_to_qdb_task [flng::get_objects -type task_definition -name "dni_export_to_qdb"]
    if {$export_to_qdb_task == ""} {
        error "Error: unable to export to qdb task"
    } else {
        lappend task_list $export_to_qdb_task
    }

    flng::set_property -object $flow -name tasks -value $task_list
    flng::add_property -object $flow -name depends_on:$straight_setup_design_task -value $export_to_qdb_task
    flng::add_property -object $flow -name use_dms -value true -value_type bool
}

namespace eval dni_straight_elaborate_to_qdb_flow {
    variable flow_id [flng::get_next_available_id -type flow]
    variable flow [flng::add_object -type flow_definition -number $flow_id -name "dni_straight_elaborate_to_qdb"]
    flng::set_property -object $flow -name identifier -value "Straight Elaborate Design to QDB"
    flng::set_property -object $flow -name description -value "Run eloabrate design to QDB without intermediate checkpoints"
    flng::add_property -object $flow -name parameters:sdc_file_path -value ""


    variable task_list [list]

    variable straight_elaborate_to_qdb_task [flng::get_objects -type task_definition -name "dni_straight_elaborate_to_qdb"]
    if {$straight_elaborate_to_qdb_task == ""} {
        error "Error: unable to find setup design task"
    } else {
        lappend task_list $straight_elaborate_to_qdb_task
    }

    flng::set_property -object $flow -name tasks -value $task_list
    flng::add_property -object $flow -name use_dms -value true -value_type bool
}

namespace eval dni_analysis_and_synthesis_flow {
    variable flow_id [flng::get_next_available_id -type flow]
    variable flow [flng::add_object -type flow_definition -number $flow_id -name dni_analysis_and_synthesis]
    flng::set_property -object $flow -name identifier -value "Analysis & Synthesis"
    flng::set_property -object $flow -name description -value " Analysis and Synthesis"
    flng::set_property -object $flow -name storage_engine -value "qhd"

    variable dni_elaboration [flng::get_objects -type task_definition -name "dni_elaboration"]
    if {$dni_elaboration == ""} {
        error "Error: unable to find elaboration task"
    } else {
        lappend task_list $dni_elaboration
    }


    variable dni_synthesis [flng::get_objects -type task_definition -name "dni_synthesis"]
    if {$dni_synthesis == ""} {
        error "Error: unable to find synthesis task"
    } else {
        lappend task_list $dni_synthesis
    }


    flng::set_property -object $flow -name tasks -value $task_list
    flng::add_property -object $flow -name depends_on:$dni_elaboration -value [list $dni_synthesis]
}


namespace eval dni_compile_flow {
    variable flow_id [flng::get_next_available_id -type flow]
    variable flow [flng::add_object -type flow_definition -number $flow_id -name compile]
    flng::set_property -object $flow -name identifier -value "Full Compilation"
    flng::set_property -object $flow -name gui_display -value "Compile Design"
    flng::set_property -object $flow -name description -value "Run Full Compilation"
    flng::set_property -object $flow -name storage_engine -value "qhd"
    flng::set_property -object $flow -name enable_pre_post_flow_script -value 1
    
    # Declare flow parameters.  These can be passed in when running the flow in commandline.
    #
    # optimization mode: 
    #     Optimization mode is set with commandline argument when
    #         running quartus_sh --flow <flowname> 
    #     -fast_functional_test
    #     -aggressive_compile_time.
    #
    # rapid_recompile:
    #     quartus_sh --flow recompile activates rapid_recompile.
    #
    flng::add_property -object $flow -name parameters:rapid_recompile -value ""
    flng::add_property -object $flow -name parameters:optimization_mode -value ""

    # This is only for the PCC flow. We can specify the entities we want to cache
    # The format is a comma-delimited list of entity names 
    #
    # entities:
    #     quartus_sh --flow pcc -parameters entities="ip_entity1,ip_entity2"
    #
    
    flng::add_property -object $flow -name parameters:entities -value ""

    variable ipgen [flng::get_objects -type task_definition -name "dni_ipgenerate"]
    if {$ipgen == ""} {
        error "Error: unable to find dni_ipgenerate task"
    } else {
        lappend task_list $ipgen
    }


    variable ds_ip_generation [flng::get_objects -type task_definition -name "ds_ip_generation"]
    if {$ds_ip_generation == ""} {
        error "Error: unable to find IP Generation with DS/DR task"
    } else {
        lappend task_list $ds_ip_generation
    }

    variable dni_tileip_generation [flng::get_objects -type task_definition -name "dni_tileip_generation"]
    if {$dni_tileip_generation == ""} {
        error "Error: unable to find Plan Interface task"
    } else {
        lappend task_list $dni_tileip_generation
    }
    
    variable dni_design_analysis [flng::get_objects -type task_definition -name "dni_design_analysis"]
    if {$dni_design_analysis == ""} {
        error "Error: unable to find design analysis task"
    } else {
        lappend task_list $dni_design_analysis
    }
   
    variable qsyn_lint [flng::get_objects -type task_definition -name "dni_elaboration_lint"]
    if {$qsyn_lint == ""} {
        error "Error: unable to find dni elaboration linter task"
    } else {
	    lappend task_list $qsyn_lint
    }

    variable qsyn [flng::get_objects -type task_definition -name "dni_analysis_and_synthesis"]
    if {$qsyn == ""} {
        error "Error: unable to find analysis and synthesis task"
    } else {
        lappend task_list $qsyn
    }

   
    variable sta_early [flng::get_objects -type task_definition -name "sta_early"]
    if {$sta_early == ""} {
        error "Error: unable to find Early Timing Analysis task."
    } else {
        lappend task_list $sta_early
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

    set include_assembler 0
    set dni_mode_for_regtest 0
    if { [info exists ::env(DNI_MODE_FOR_REGTEST)] } {
        set dni_mode_for_regtest [string eq -nocase "ON" $env(DNI_MODE_FOR_REGTEST)]
    }
    if {[cfg_is_on "dni_include_assembler_in_flow"] || $dni_mode_for_regtest } {
        set include_assembler 1
    }
    if { $include_assembler } {
        variable qasm [flng::get_objects -type task_definition -name "assembler"]
        if {$qasm == ""} {
            error "Error: unable to find assembler task."
        } else {
            lappend task_list $qasm
        }
    }

    # EDA Netlist Writer
    variable qeda [flng::get_objects -type task_definition -name "eda_netlist_writer"]
    if {$qeda == ""} {
        error "Error: unable to find netlist writer task."
    } else {
        lappend task_list $qeda
    }
           
    # These tasks are not run as part of the flow. User can launch them
    # manually. 
    set user_initiated_tasks [list $qsyn_lint]
    # Simulation
    if {[cfg_is_on "eda_tool_enable_simulation"]} {
        variable simulation [flng::get_objects -type task_definition -name "nativelink"]
        if {$simulation == ""} {
            error "Error: unable to find Simulation task."
        } else {
            lappend task_list $simulation
            lappend user_initiated_tasks $simulation
            flng::add_property -object $flow -name asgn_generate_depends_on:$qsyn -value [list $simulation "EDA_SIMULATION_TYPE" "RTL"]
            flng::add_property -object $flow -name asgn_generate_depends_on:$qeda -value [list $simulation "EDA_SIMULATION_TYPE" "GATE" "EDA_SIMULATION_STAGE_FOR_GATE_LEVEL" "MOST_RECENT"]
        }
    }

    flng::set_property -object $flow -name tasks -value $task_list
    flng::set_property -object $flow -name user_initiated_tasks -value $user_initiated_tasks 
   
    set base_ipgen_dependents [list $qsyn $qsyn_lint]

    # {*} splits a list into individual words 
    set ipgen_dependents [list $ds_ip_generation $dni_tileip_generation {*}$base_ipgen_dependents]
    
    flng::set_property -object $flow -name prerequisite -value [list "task:eda_netlist_writer,task:fitter_plan" "task:fitter_fastforward_timing,task:fitter_route"]

    flng::add_property -object $flow -name depends_on:$ipgen -value $ipgen_dependents
    flng::add_property -object $flow -name depends_on:$ds_ip_generation -value $base_ipgen_dependents 
    flng::add_property -object $flow -name depends_on:$dni_tileip_generation -value [list $qsyn $dni_design_analysis]
    set qsyn_dependents [list $qfit $qeda $sta_early]
    flng::add_property -object $flow -name depends_on:$qsyn -value $qsyn_dependents
 
    if { $include_assembler } {
        flng::add_property -object $flow -name depends_on:$qfit -value [list $fit_fastforward_timing $qeda $qasm $qpow $qsta]
    } else {
        flng::add_property -object $flow -name depends_on:$qfit -value [list $fit_fastforward_timing $qeda $qpow $qsta]
    }

    flng::add_property -object $flow -name parameters:rapid_recompile -value ""
    flng::add_property -object $flow -name use_dms -value true -value_type bool
        
    

    # Specify call function to dynamically configure dependencies. Function needs to be prefixed
    # by the namespace.
    flng::set_property -object $flow -name config_dependency_function -value "dni_compile_flow::config_dependency"

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
        if {[catch {flng::get_objects -type task -name "dni_analysis_and_synthesis" -properties "flow=$flow_id"} qsyn]} {
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
            flng::set_property -object $flow_id -name prerequisite -value [list "task:eda_netlist_writer,task:dni_analysis_and_synthesis" "task:fitter_fastforward_timing,task:fitter_route"]
        } else {
            flng::set_property -object $flow_id -name prerequisite -value [] 
        }
        return "1"
    }
}






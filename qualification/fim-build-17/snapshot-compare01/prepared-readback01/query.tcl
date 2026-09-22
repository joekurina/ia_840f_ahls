# Work17: exact routed/final hold-path observation, original signoff.
load_package sta
load_package report
namespace eval ::ia840f_w17snapshot01 {
    variable E {/home/uwb_student00/ahls/new_BSP/qualification/fim-build-17/snapshot-compare01}
    variable audit
    proc emit {args} {
        variable audit
        puts $audit $args
        flush $audit
        puts "W17_SNAPSHOT_AUDIT $args"
        flush stdout
    }
    proc require {ok why} {if {!$ok} {error "W17_SNAPSHOT_INCOMPLETE $why"}}
    proc main {} {
        variable E
        variable audit
        require [expr {[pwd] eq "$E/scratch/syn/board/ia840f/syn_top"}] "wrong project"
        require [expr {![file exists "$E/reports"]}] "spent output"
        file mkdir "$E/reports"
        set audit [open "$E/reports/audit.tcllist" {WRONLY CREAT EXCL}]
        emit BEGIN snapshots {routed final} unchanged_signoff no_fit no_hardware
        project_open -revision ofs_top ofs_top
        if {[info exists ::ia840f_gate_result]} {error SOURCE_BOUND_GATE_REJECTION_STOP}
        foreach w17s_stage {routed final} {
            emit SNAPSHOT_BEGIN $w17s_stage
            create_timing_netlist -snapshot $w17s_stage
            read_sdc
            set w17s_conditions [get_available_operating_conditions]
            set w17s_count [get_collection_size $w17s_conditions]
            emit CORNER_COUNT $w17s_stage $w17s_count cap 16
            require [expr {$w17s_count > 0 && $w17s_count <= 16}] "corner count"
            set w17s_selected {}
            foreach_in_collection w17s_corner $w17s_conditions {
                emit CORNER $w17s_stage $w17s_corner
                if {$w17s_corner eq "MIN_fast_vid2_100c"} {lappend w17s_selected $w17s_corner}
            }
            require [expr {[llength $w17s_selected] == 1}] "exact Fast vid2 100C unavailable"
            set_operating_conditions [lindex $w17s_selected 0]
            update_timing_netlist
            set w17s_through_name {local_mem_wrapper|mem_ss_top|mem_ss_sv|mem_ss|mem_ss|emif_1|emif_1|arch|arch_inst|fm_ufis|tile_gen[2].lane_gen[1].pin_gen[3].phase_gen[3].data_lane_c2p_ufi_i|c2p_350_ufi.ufi_inst|d}
            set w17s_endpoint_name {local_mem_wrapper|mem_ss_top|mem_ss_sv|mem_ss|mem_ss|emif_1|emif_1|arch|arch_inst|io_tiles_wrap_inst|io_tiles_inst|tile_gen[2].lane_gen[1].lane_inst|lane_inst~phy_reg1}
            set w17s_through [get_pins [list $w17s_through_name]]
            set w17s_endpoint [get_keepers [list $w17s_endpoint_name]]
            emit OBJECT_COUNTS $w17s_stage through [get_collection_size $w17s_through] endpoint [get_collection_size $w17s_endpoint]
            require [expr {[get_collection_size $w17s_through]==1 && [get_collection_size $w17s_endpoint]==1}] "exact path objects unresolved"
            foreach_in_collection w17s_pin $w17s_through {require [expr {[get_pin_info -name $w17s_pin] eq $w17s_through_name}] "wrong through pin"}
            foreach_in_collection w17s_keeper $w17s_endpoint {require [expr {[get_node_info -name $w17s_keeper] eq $w17s_endpoint_name}] "wrong endpoint"}
            report_timing -hold -through $w17s_through -to $w17s_endpoint -npaths 1 -detail full_path -show_routing -file "$E/reports/$w17s_stage-hold.rpt"
            set w17s_paths [get_timing_paths -hold -through $w17s_through -to $w17s_endpoint -npaths 1 -detail full_path]
            emit PATH_COUNT $w17s_stage [get_collection_size $w17s_paths]
            require [expr {[get_collection_size $w17s_paths]==1}] "no exact hold path"
            foreach_in_collection w17s_path $w17s_paths {
                foreach w17s_prop {slack arrival_time required_time data_delay clock_skew operating_conditions corner type} {
                    emit PATH_PROPERTY $w17s_stage $w17s_prop [get_path_info -$w17s_prop $w17s_path]
                }
                foreach w17s_prop {from to} {emit PATH_NODE $w17s_stage $w17s_prop [get_node_info -name [get_path_info -$w17s_prop $w17s_path]]}
                foreach w17s_prop {from_clock to_clock} {emit PATH_CLOCK $w17s_stage $w17s_prop [get_clock_info -name [get_path_info -$w17s_prop $w17s_path]]}
            }
            emit SNAPSHOT_COMPLETE $w17s_stage diagnostic_only no_timing_acceptance
            delete_timing_netlist
        }
        project_close
        emit COMPLETE diagnostic_only no_timing_acceptance no_hardware_qualification
        close $audit
        puts IA840F_W17_SNAPSHOT_COMPLETE
        flush stdout
    }
}
::ia840f_w17snapshot01::main

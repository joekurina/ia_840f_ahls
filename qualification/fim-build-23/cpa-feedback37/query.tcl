# Bounded CPA feedback observation on a preserved final netlist; no setters.
load_package sta
load_package report
namespace eval ::ia840f_cpa37 {
    variable E {/home/uwb_student00/ahls/new_BSP/qualification/fim-build-23/cpa-feedback37}
    variable audit
    proc emit {args} {variable audit; puts $audit $args; flush $audit; puts "CPA37_AUDIT $args"; flush stdout}
    proc require {ok why} {if {!$ok} {error "CPA37_INCOMPLETE $why"}}
    proc object {role name kind} {
        if {$kind eq "port"} {set cpa37_coll [get_ports [list $name]]} else {set cpa37_coll [get_pins [list $name]]}
        set cpa37_n [get_collection_size $cpa37_coll]
        emit LOOKUP $role kind $kind expected $name count $cpa37_n cap 8
        require [expr {$cpa37_n <= 8}] "object count above cap"
        if {$cpa37_n == 0} {
            set cpa37_coll [get_nodes [list $name]]
            set cpa37_n [get_collection_size $cpa37_coll]
            emit LOOKUP $role kind node expected $name count $cpa37_n cap 8
            require [expr {$cpa37_n <= 8}] "node count above cap"
        }
        if {$cpa37_n != 1} {emit UNAVAILABLE $role count $cpa37_n; return [dict create available 0]}
        foreach_in_collection cpa37_obj $cpa37_coll {
            set cpa37_actual [get_node_info -name $cpa37_obj]
            emit OBJECT_NAME $role $cpa37_actual
            if {$cpa37_actual ne $name} {emit UNAVAILABLE $role reason name_mismatch; return [dict create available 0]}
        }
        return [dict create available 1 collection $cpa37_coll]
    }
    proc main {} {
        variable E
        variable audit
        require [expr {[pwd] eq "$E/scratch/syn/board/ia840f/syn_top"}] "wrong project"
        require [expr {![file exists "$E/reports"]}] "spent output"
        file mkdir "$E/reports"
        set audit [open "$E/reports/audit.tcllist" {WRONLY CREAT EXCL}]
        emit BEGIN final_snapshot original_signoff no_fit no_hardware no_CPA_equation_claim
        project_open -revision ofs_top ofs_top
        if {[info exists ::ia840f_cpa37_gate_failed]} {error CPA37_REJECTED_PROJECT_OPEN}
        create_timing_netlist -snapshot final
        read_sdc
        set cpa37_conditions [get_available_operating_conditions]
        set cpa37_count [get_collection_size $cpa37_conditions]
        emit CORNER_COUNT $cpa37_count cap 16
        require [expr {$cpa37_count > 0 && $cpa37_count <= 16}] "corner count"
        set cpa37_selected {}
        foreach_in_collection cpa37_corner $cpa37_conditions {
            emit CORNER $cpa37_corner
            if {$cpa37_corner eq "MIN_fast_vid2_100c"} {lappend cpa37_selected $cpa37_corner}
        }
        require [expr {[llength $cpa37_selected] == 1}] "required Fast vid2 100C unavailable"
        set_operating_conditions [lindex $cpa37_selected 0]
        update_timing_netlist
        # Reproduce the already measured failure to bind the loaded snapshot.
        set cpa37_through_name {local_mem_wrapper|mem_ss_top|mem_ss_sv|mem_ss|mem_ss|emif_1|emif_1|arch|arch_inst|fm_ufis|tile_gen[2].lane_gen[1].pin_gen[3].phase_gen[3].data_lane_c2p_ufi_i|c2p_350_ufi.ufi_inst|d}
        set cpa37_endpoint_name {local_mem_wrapper|mem_ss_top|mem_ss_sv|mem_ss|mem_ss|emif_1|emif_1|arch|arch_inst|io_tiles_wrap_inst|io_tiles_inst|tile_gen[2].lane_gen[1].lane_inst|lane_inst~phy_reg1}
        set cpa37_through [get_pins [list $cpa37_through_name]]
        set cpa37_endpoint [get_keepers [list $cpa37_endpoint_name]]
        emit ANCHOR_COUNTS through [get_collection_size $cpa37_through] endpoint [get_collection_size $cpa37_endpoint]
        require [expr {[get_collection_size $cpa37_through]==1 && [get_collection_size $cpa37_endpoint]==1}] "anchor objects unresolved"
        foreach_in_collection cpa37_pin $cpa37_through {require [expr {[get_pin_info -name $cpa37_pin] eq $cpa37_through_name}] "wrong anchor pin"}
        foreach_in_collection cpa37_keeper $cpa37_endpoint {require [expr {[get_node_info -name $cpa37_keeper] eq $cpa37_endpoint_name}] "wrong anchor endpoint"}
        report_timing -hold -through $cpa37_through -to $cpa37_endpoint -npaths 1 -detail full_path -show_routing -file "$E/reports/anchor-hold.rpt"
        set cpa37_paths [get_timing_paths -hold -through $cpa37_through -to $cpa37_endpoint -npaths 1 -detail full_path]
        emit ANCHOR_PATH_COUNT [get_collection_size $cpa37_paths]
        require [expr {[get_collection_size $cpa37_paths]==1}] "anchor path unavailable"
        foreach_in_collection cpa37_path $cpa37_paths {
            set cpa37_slack [get_path_info -slack $cpa37_path]
            emit ANCHOR_SLACK raw $cpa37_slack printed_ns [format %.3f $cpa37_slack]
            require [expr {[format %.3f $cpa37_slack] eq "-0.004"}] "known final failure not reproduced"
        }
        set cpa37_stem {local_mem_wrapper|mem_ss_top|mem_ss_sv|mem_ss|mem_ss|emif_1|emif_1|arch|arch_inst|io_tiles_wrap_inst|io_tiles_inst|tile_gen[1].tile_ctrl_inst}
        set cpa37_objects [dict create]
        foreach {cpa37_role cpa37_suffix} {core_out {pa_core_clk_out[0]} core_return {pa_core_clk_in[0]} phy0 {pa_fbclk_in[0]} phy1 {pa_fbclk_in[1]} phy2 {pa_fbclk_in[2]}} {
            dict set cpa37_objects $cpa37_role [object $cpa37_role "$cpa37_stem|$cpa37_suffix" pin]
        }
        dict set cpa37_objects refclk [object refclk {ddr4_mem_ref_clk[1].clk} port]
        set cpa37_reported 0
        foreach {cpa37_label cpa37_from cpa37_to} {core_feedback core_out core_return phy0_reference refclk phy0 phy1_reference refclk phy1 phy2_reference refclk phy2} {
            if {![dict get $cpa37_objects $cpa37_from available] || ![dict get $cpa37_objects $cpa37_to available]} {
                emit PAIR_UNAVAILABLE $cpa37_label
                continue
            }
            foreach cpa37_mode {maximum minimum} {
                set cpa37_command [list report_path -from [dict get $cpa37_objects $cpa37_from collection] -to [dict get $cpa37_objects $cpa37_to collection] -npaths 1 -nworst 1 -show_routing -file "$E/reports/$cpa37_label-$cpa37_mode.rpt"]
                if {$cpa37_mode eq "minimum"} {lappend cpa37_command -min_path}
                set cpa37_result [{*}$cpa37_command]
                emit PATH_RESULT $cpa37_label $cpa37_mode $cpa37_result
                require [expr {[llength $cpa37_result]==2}] "raw report return shape"
                set cpa37_found [lindex $cpa37_result 0]
                require [expr {$cpa37_found>=0 && $cpa37_found<=1}] "raw path count"
                if {$cpa37_found==0} {emit PATH_UNAVAILABLE $cpa37_label $cpa37_mode} else {incr cpa37_reported}
            }
        }
        emit FEEDBACK_REPORT_COUNT $cpa37_reported expected_at_most 8 zero_is_unavailable_not_zero_delay
        delete_timing_netlist
        project_close
        emit COMPLETE observations_only no_CPA_equation no_timing_acceptance no_hardware
        close $audit
        puts IA840F_CPA_FEEDBACK37_COMPLETE
        flush stdout
    }
}
::ia840f_cpa37::main

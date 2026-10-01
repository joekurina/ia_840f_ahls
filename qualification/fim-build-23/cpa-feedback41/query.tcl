# Bounded CPA feedback observation on a preserved final netlist; no setters.
load_package sta
load_package report
namespace eval ::ia840f_cpa41 {
    variable E {/home/uwb_student00/ahls/new_BSP/qualification/fim-build-23/cpa-feedback41}
    variable audit
    proc emit {args} {variable audit; puts $audit $args; flush $audit; puts "CPA41_AUDIT $args"; flush stdout}
    proc require {ok why} {if {!$ok} {error "CPA41_INCOMPLETE $why"}}
    proc object {role name kind} {
        if {$kind eq "port"} {set cpa41_coll [get_ports [list $name]]} else {set cpa41_coll [get_pins [list $name]]}
        set cpa41_n [get_collection_size $cpa41_coll]
        emit LOOKUP $role kind $kind expected $name count $cpa41_n cap 8
        require [expr {$cpa41_n <= 8}] "object count above cap"
        if {$cpa41_n == 0} {
            set cpa41_coll [get_nodes [list $name]]
            set cpa41_n [get_collection_size $cpa41_coll]
            emit LOOKUP $role kind node expected $name count $cpa41_n cap 8
            require [expr {$cpa41_n <= 8}] "node count above cap"
        }
        if {$cpa41_n != 1} {emit UNAVAILABLE $role count $cpa41_n; return [dict create available 0]}
        foreach_in_collection cpa41_obj $cpa41_coll {
            set cpa41_actual [get_node_info -name $cpa41_obj]
            emit OBJECT_NAME $role $cpa41_actual
            if {$cpa41_actual ne $name} {emit UNAVAILABLE $role reason name_mismatch; return [dict create available 0]}
        }
        return [dict create available 1 collection $cpa41_coll]
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
        if {[info exists ::ia840f_cpa41_gate_failed]} {error CPA41_REJECTED_PROJECT_OPEN}
        create_timing_netlist -snapshot final
        read_sdc
        set cpa41_conditions [get_available_operating_conditions]
        set cpa41_count [get_collection_size $cpa41_conditions]
        emit CORNER_COUNT $cpa41_count cap 16
        require [expr {$cpa41_count > 0 && $cpa41_count <= 16}] "corner count"
        set cpa41_selected {}
        foreach_in_collection cpa41_corner $cpa41_conditions {
            emit CORNER $cpa41_corner
            if {$cpa41_corner eq "MIN_fast_vid2_100c"} {lappend cpa41_selected $cpa41_corner}
        }
        require [expr {[llength $cpa41_selected] == 1}] "required Fast vid2 100C unavailable"
        set_operating_conditions [lindex $cpa41_selected 0]
        update_timing_netlist
        # Reproduce the already measured failure to bind the loaded snapshot.
        set cpa41_through_name {local_mem_wrapper|mem_ss_top|mem_ss_sv|mem_ss|mem_ss|emif_1|emif_1|arch|arch_inst|fm_ufis|tile_gen[2].lane_gen[1].pin_gen[3].phase_gen[3].data_lane_c2p_ufi_i|c2p_350_ufi.ufi_inst|d}
        set cpa41_endpoint_name {local_mem_wrapper|mem_ss_top|mem_ss_sv|mem_ss|mem_ss|emif_1|emif_1|arch|arch_inst|io_tiles_wrap_inst|io_tiles_inst|tile_gen[2].lane_gen[1].lane_inst|lane_inst~phy_reg1}
        set cpa41_through [get_pins [list $cpa41_through_name]]
        set cpa41_endpoint [get_keepers [list $cpa41_endpoint_name]]
        emit ANCHOR_COUNTS through [get_collection_size $cpa41_through] endpoint [get_collection_size $cpa41_endpoint]
        require [expr {[get_collection_size $cpa41_through]==1 && [get_collection_size $cpa41_endpoint]==1}] "anchor objects unresolved"
        foreach_in_collection cpa41_pin $cpa41_through {require [expr {[get_pin_info -name $cpa41_pin] eq $cpa41_through_name}] "wrong anchor pin"}
        foreach_in_collection cpa41_keeper $cpa41_endpoint {require [expr {[get_node_info -name $cpa41_keeper] eq $cpa41_endpoint_name}] "wrong anchor endpoint"}
        report_timing -hold -through $cpa41_through -to $cpa41_endpoint -npaths 1 -detail full_path -show_routing -file "$E/reports/anchor-hold.rpt"
        set cpa41_paths [get_timing_paths -hold -through $cpa41_through -to $cpa41_endpoint -npaths 1 -detail full_path]
        emit ANCHOR_PATH_COUNT [get_collection_size $cpa41_paths]
        require [expr {[get_collection_size $cpa41_paths]==1}] "anchor path unavailable"
        foreach_in_collection cpa41_path $cpa41_paths {
            set cpa41_slack [get_path_info -slack $cpa41_path]
            emit ANCHOR_SLACK raw $cpa41_slack printed_ns [format %.3f $cpa41_slack]
            require [expr {[format %.3f $cpa41_slack] eq "-0.004"}] "known final failure not reproduced"
        }
        set cpa41_stem {local_mem_wrapper|mem_ss_top|mem_ss_sv|mem_ss|mem_ss|emif_1|emif_1|arch|arch_inst|io_tiles_wrap_inst|io_tiles_inst|tile_gen[1].tile_ctrl_inst}
        set cpa41_objects [dict create]
        foreach {cpa41_role cpa41_suffix} {core_out {pa_core_clk_out[0]} core_return {pa_core_clk_in[0]} phy0 {pa_fbclk_in[0]} phy1 {pa_fbclk_in[1]} phy2 {pa_fbclk_in[2]}} {
            dict set cpa41_objects $cpa41_role [object $cpa41_role "$cpa41_stem|$cpa41_suffix" pin]
        }
        dict set cpa41_objects refclk [object refclk {ddr4_mem_ref_clk[1].clk} port]
        set cpa41_reported 0
        foreach {cpa41_label cpa41_from cpa41_to} {core_feedback core_out core_return phy1_upstream automatic phy1} {
            if {![dict get $cpa41_objects $cpa41_to available] || ($cpa41_from ne "automatic" && ![dict get $cpa41_objects $cpa41_from available])} {
                emit PAIR_UNAVAILABLE $cpa41_label
                continue
            }
            foreach cpa41_polarity {rise fall} {
                foreach cpa41_mode {maximum minimum} {
                    set cpa41_command [list report_path -npaths 1 -nworst 1 -show_routing -file "$E/reports/$cpa41_label-$cpa41_polarity-$cpa41_mode.rpt"]
                    lappend cpa41_command -${cpa41_polarity}_to [dict get $cpa41_objects $cpa41_to collection]
                    if {$cpa41_from ne "automatic"} {lappend cpa41_command -${cpa41_polarity}_from [dict get $cpa41_objects $cpa41_from collection]}
                    if {$cpa41_mode eq "minimum"} {lappend cpa41_command -min_path}
                    set cpa41_result [{*}$cpa41_command]
                    emit PATH_RESULT $cpa41_label $cpa41_polarity $cpa41_mode $cpa41_result
                    require [expr {[llength $cpa41_result]==2}] "raw report return shape"
                    set cpa41_found [lindex $cpa41_result 0]
                    require [expr {$cpa41_found>=0 && $cpa41_found<=1}] "raw path count"
                    if {$cpa41_found==0} {emit PATH_UNAVAILABLE $cpa41_label $cpa41_polarity $cpa41_mode} else {incr cpa41_reported}
                }
            }
        }
        emit FEEDBACK_REPORT_COUNT $cpa41_reported expected_at_most 8 zero_is_unavailable_not_zero_delay
        delete_timing_netlist
        project_close
        emit COMPLETE observations_only no_CPA_equation no_timing_acceptance no_hardware
        close $audit
        puts IA840F_CPA_FEEDBACK41_COMPLETE
        flush stdout
    }
}
::ia840f_cpa41::main

# Bounded CPA feedback observation on a preserved final netlist; no setters.
load_package sta
load_package report
namespace eval ::ia840f_cpa46 {
    variable E {/home/uwb_student00/ahls/new_BSP/qualification/fim-build-23/cpa-work21-46}
    variable audit
    proc emit {args} {variable audit; puts $audit $args; flush $audit; puts "CPA46_AUDIT $args"; flush stdout}
    proc require {ok why} {if {!$ok} {error "CPA46_INCOMPLETE $why"}}
    proc object {role name kind} {
        if {$kind eq "port"} {set cpa46_coll [get_ports [list $name]]} else {set cpa46_coll [get_pins [list $name]]}
        set cpa46_n [get_collection_size $cpa46_coll]
        emit LOOKUP $role kind $kind expected $name count $cpa46_n cap 8
        require [expr {$cpa46_n <= 8}] "object count above cap"
        if {$cpa46_n == 0} {
            set cpa46_coll [get_nodes [list $name]]
            set cpa46_n [get_collection_size $cpa46_coll]
            emit LOOKUP $role kind node expected $name count $cpa46_n cap 8
            require [expr {$cpa46_n <= 8}] "node count above cap"
        }
        if {$cpa46_n != 1} {emit UNAVAILABLE $role count $cpa46_n; return [dict create available 0]}
        foreach_in_collection cpa46_obj $cpa46_coll {
            set cpa46_actual [get_node_info -name $cpa46_obj]
            emit OBJECT_NAME $role $cpa46_actual
            if {$cpa46_actual ne $name} {emit UNAVAILABLE $role reason name_mismatch; return [dict create available 0]}
        }
        return [dict create available 1 collection $cpa46_coll]
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
        if {[info exists ::ia840f_cpa46_gate_failed]} {error CPA46_REJECTED_PROJECT_OPEN}
        create_timing_netlist -snapshot final
        read_sdc
        set cpa46_conditions [get_available_operating_conditions]
        set cpa46_count [get_collection_size $cpa46_conditions]
        emit CORNER_COUNT $cpa46_count cap 16
        require [expr {$cpa46_count > 0 && $cpa46_count <= 16}] "corner count"
        set cpa46_selected {}
        foreach_in_collection cpa46_corner $cpa46_conditions {
            emit CORNER $cpa46_corner
            if {$cpa46_corner eq "MIN_fast_vid2_100c"} {lappend cpa46_selected $cpa46_corner}
        }
        require [expr {[llength $cpa46_selected] == 1}] "required Fast vid2 100C unavailable"
        set_operating_conditions [lindex $cpa46_selected 0]
        update_timing_netlist
        # Reproduce the already measured passing baseline to bind the loaded snapshot.
        set cpa46_through_name {local_mem_wrapper|mem_ss_top|mem_ss_sv|mem_ss|mem_ss|emif_1|emif_1|arch|arch_inst|fm_ufis|tile_gen[2].lane_gen[1].pin_gen[3].phase_gen[3].data_lane_c2p_ufi_i|c2p_350_ufi.ufi_inst|d}
        set cpa46_endpoint_name {local_mem_wrapper|mem_ss_top|mem_ss_sv|mem_ss|mem_ss|emif_1|emif_1|arch|arch_inst|io_tiles_wrap_inst|io_tiles_inst|tile_gen[2].lane_gen[1].lane_inst|lane_inst~phy_reg1}
        set cpa46_through [get_pins [list $cpa46_through_name]]
        set cpa46_endpoint [get_keepers [list $cpa46_endpoint_name]]
        emit ANCHOR_COUNTS through [get_collection_size $cpa46_through] endpoint [get_collection_size $cpa46_endpoint]
        require [expr {[get_collection_size $cpa46_through]==1 && [get_collection_size $cpa46_endpoint]==1}] "anchor objects unresolved"
        foreach_in_collection cpa46_pin $cpa46_through {require [expr {[get_pin_info -name $cpa46_pin] eq $cpa46_through_name}] "wrong anchor pin"}
        foreach_in_collection cpa46_keeper $cpa46_endpoint {require [expr {[get_node_info -name $cpa46_keeper] eq $cpa46_endpoint_name}] "wrong anchor endpoint"}
        report_timing -hold -through $cpa46_through -to $cpa46_endpoint -npaths 1 -detail full_path -show_routing -file "$E/reports/anchor-hold.rpt"
        set cpa46_paths [get_timing_paths -hold -through $cpa46_through -to $cpa46_endpoint -npaths 1 -detail full_path]
        emit ANCHOR_PATH_COUNT [get_collection_size $cpa46_paths]
        require [expr {[get_collection_size $cpa46_paths]==1}] "anchor path unavailable"
        foreach_in_collection cpa46_path $cpa46_paths {
            set cpa46_slack [get_path_info -slack $cpa46_path]
            emit ANCHOR_SLACK raw $cpa46_slack printed_ns [format %.3f $cpa46_slack]
            require [expr {[format %.3f $cpa46_slack] eq "0.082"}] "known passing baseline not reproduced"
        }
        set cpa46_stem {local_mem_wrapper|mem_ss_top|mem_ss_sv|mem_ss|mem_ss|emif_1|emif_1|arch|arch_inst|io_tiles_wrap_inst|io_tiles_inst|tile_gen[1].tile_ctrl_inst}
        set cpa46_objects [dict create]
        foreach {cpa46_role cpa46_suffix} {core_out {pa_core_clk_out[0]} core_return {pa_core_clk_in[0]} phy0 {pa_fbclk_in[0]} phy1 {pa_fbclk_in[1]} phy2 {pa_fbclk_in[2]}} {
            dict set cpa46_objects $cpa46_role [object $cpa46_role "$cpa46_stem|$cpa46_suffix" pin]
        }
        dict set cpa46_objects refclk [object refclk {ddr4_mem_ref_clk[1].clk} port]
        set cpa46_reported 0
        foreach {cpa46_label cpa46_from cpa46_to} {core_feedback core_out core_return phy1_upstream automatic phy1} {
            if {![dict get $cpa46_objects $cpa46_to available] || ($cpa46_from ne "automatic" && ![dict get $cpa46_objects $cpa46_from available])} {
                emit PAIR_UNAVAILABLE $cpa46_label
                continue
            }
            foreach cpa46_polarity {rise fall} {
                foreach cpa46_mode {maximum minimum} {
                    set cpa46_command [list report_path -npaths 1 -nworst 1 -show_routing -file "$E/reports/$cpa46_label-$cpa46_polarity-$cpa46_mode.rpt"]
                    lappend cpa46_command -${cpa46_polarity}_to [dict get $cpa46_objects $cpa46_to collection]
                    if {$cpa46_from ne "automatic"} {lappend cpa46_command -${cpa46_polarity}_from [dict get $cpa46_objects $cpa46_from collection]}
                    if {$cpa46_mode eq "minimum"} {lappend cpa46_command -min_path}
                    set cpa46_result [{*}$cpa46_command]
                    emit PATH_RESULT $cpa46_label $cpa46_polarity $cpa46_mode $cpa46_result
                    require [expr {[llength $cpa46_result]==2}] "raw report return shape"
                    set cpa46_found [lindex $cpa46_result 0]
                    require [expr {$cpa46_found>=0 && $cpa46_found<=1}] "raw path count"
                    if {$cpa46_found==0} {emit PATH_UNAVAILABLE $cpa46_label $cpa46_polarity $cpa46_mode} else {incr cpa46_reported}
                }
            }
        }
        emit FEEDBACK_REPORT_COUNT $cpa46_reported expected_at_most 8 zero_is_unavailable_not_zero_delay
        delete_timing_netlist
        project_close
        emit COMPLETE observations_only no_CPA_equation no_timing_acceptance no_hardware
        close $audit
        puts IA840F_CPA_WORK21_46_COMPLETE
        flush stdout
    }
}
::ia840f_cpa46::main

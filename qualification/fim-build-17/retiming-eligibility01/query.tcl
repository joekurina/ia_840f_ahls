# Work17: exact pre-fit launch and native retiming-assignment eligibility.
load_package sta
namespace eval ::ia840f_w17retimeelig01 {
    variable E {/home/uwb_student00/ahls/new_BSP/qualification/fim-build-17/retiming-eligibility01}
    variable audit
    proc emit {args} {
        variable audit
        puts $audit $args
        flush $audit
        puts "W17_RETIME_ELIG_AUDIT $args"
        flush stdout
    }
    proc require {ok why} {if {!$ok} {error "W17_RETIME_ELIG_INCOMPLETE $why"}}
    proc main {} {
        variable E
        variable audit
        require [expr {[pwd] eq "$E/scratch/syn/board/ia840f/syn_top"}] "wrong project"
        require [expr {![file exists "$E/reports"]}] "spent output"
        file mkdir "$E/reports"
        set audit [open "$E/reports/audit.tcllist" {WRONLY CREAT EXCL}]
        emit BEGIN assignment ALLOW_REGISTER_RETIMING post_synthesis no_assignment_write no_fit no_hardware
        project_open -revision ofs_top ofs_top
        if {[info exists ::ia840f_gate_result]} {error SOURCE_BOUND_GATE_REJECTION_STOP}
        set w17re_info [get_assignment_name_info ALLOW_REGISTER_RETIMING]
        emit METADATA_LENGTH [string length $w17re_info] cap 65536
        require [expr {[string length $w17re_info] <= 65536}] "metadata bound"
        set w17re_file [open "$E/reports/assignment-info.txt" {WRONLY CREAT EXCL}]
        puts $w17re_file $w17re_info
        close $w17re_file
        emit ASSIGNMENT_INFO $w17re_info
        set w17re_names [get_all_assignment_names -family {Agilex 7} -module fit -type instance]
        emit FAMILY_FIT_INSTANCE_COUNT [llength $w17re_names]
        set w17re_member [expr {[lsearch -exact $w17re_names ALLOW_REGISTER_RETIMING] >= 0}]
        emit INSTANCE_MEMBERSHIP ALLOW_REGISTER_RETIMING $w17re_member
        emit NETLIST_BEGIN post_syn
        create_timing_netlist -post_syn
        set w17re_launch {local_mem_wrapper|mem_ss_top|mem_ss_sv|mem_ss|mem_ss|emif_1|emif_1|arch|arch_inst|hmc.amm.amm.data_if_inst|amm_writedata_0_r[0][243]}
        set w17re_registers [get_registers [list $w17re_launch]]
        set w17re_count [get_collection_size $w17re_registers]
        emit REGISTER_RAW_COUNT $w17re_count cap 64 selector $w17re_launch
        require [expr {$w17re_count <= 64}] "register count exceeds diagnostic bound"
        set w17re_exact 0
        foreach_in_collection w17re_register $w17re_registers {
            set w17re_name [get_register_info -name $w17re_register]
            emit REGISTER_NAME $w17re_name
            if {$w17re_name eq $w17re_launch} {incr w17re_exact}
        }
        emit ELIGIBILITY_INPUTS instance_membership $w17re_member register_raw_count $w17re_count exact_name_count $w17re_exact applicability_and_legal_OFF_require_parent_review
        delete_timing_netlist
        project_close
        emit COMPLETE diagnostic_only no_assignment_changed no_timing_acceptance no_hardware_qualification
        close $audit
        puts IA840F_W17_RETIME_ELIG_COMPLETE
        flush stdout
    }
}
::ia840f_w17retimeelig01::main

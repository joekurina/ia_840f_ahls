# Fresh candidate-only native clock trial; accepted original-SDC baseline reused.
load_package sta
load_package report
foreach ct_source {scope-collections.tcl receiver-mapping.tcl clock-inventory.tcl expected-baseline.tcl known-receivers.tcl} {
    source [file join [file dirname [info script]] $ct_source]
}
namespace eval ::ia840f_clock_trial01 {
    variable E /home/uwb_student00/ahls/new_BSP/qualification/pcie-clock-repair-01/clock-trial01
    proc main {} {
        variable E
        ::ia840f_compare04::require [expr {[pwd] eq "$E/scratch/syn/board/ia840f/syn_top"}] "unexpected trial project path"
        set ct_reports "$E/reports"
        ::ia840f_compare04::require [expr {![file exists $ct_reports]}] "spent reports directory"
        file mkdir $ct_reports
        set ::ia840f_compare04::audit [open "$ct_reports/audit.tcllist" {WRONLY CREAT EXCL}]
        ::ia840f_compare04::emit BEGIN candidate_clock_trial original_baseline_reused no_fit no_hardware no_timing_acceptance
        project_open -revision ofs_top ofs_top
        if {[info exists ::ia840f_gate_result]} {error SOURCE_BOUND_GATE_REJECTION_STOP}
        create_timing_netlist
        # Normal order. top.sdc alone sources the guard and calls apply_v2.
        read_sdc
        update_timing_netlist
        ::ia840f_clock_repair::verify_created_v2
        set ct_H $::ia840f_clock_repair::H
        set ct_D $::ia840f_clock_repair::D
        set ct_C $::ia840f_clock_repair::C
        ::ia840f_compare04::verify_clock_inventory candidate [::ia840f_clock_repair::snapshot_v2] $::ia840f_compare04_expect::clocks $ct_C
        set ct_scope [::ia840f_compare04::capture_scope candidate $ct_D $::ia840f_compare04_expect::nodes]
        ::ia840f_compare04::capture_receivers candidate $ct_H $ct_D $ct_C [dict get $ct_scope union_names] $::ia840f_known_receivers
        ::ia840f_compare04::emit CLOCK_BINDING_CHECKS_COMPLETE required_independent_result_review no_full_domain_coverage_claim
        report_sdc -file "$ct_reports/sdc.rpt"
        report_sdc -ignored -file "$ct_reports/sdc-ignored.rpt"
        check_timing -include {no_clock multiple_clock generated_clock uncertainty partial_multicycle multicycle_consistency partial_min_max_delay} -file "$ct_reports/check-timing.rpt"
        set ct_corners [get_available_operating_conditions]
        set ct_count [get_collection_size $ct_corners]
        ::ia840f_compare04::emit CORNER_COUNT $ct_count cap 16
        ::ia840f_compare04::require [expr {$ct_count > 0 && $ct_count <= 16}] "native corner cardinality/cap actual=$ct_count"
        set ct_index 0
        foreach_in_collection ct_corner $ct_corners {
            ::ia840f_compare04::emit CORNER_BEGIN $ct_index session_object $ct_corner
            set_operating_conditions $ct_corner
            update_timing_netlist
            foreach ct_kind {setup hold recovery removal mpw} {
                ::ia840f_compare04::emit DOMAIN_SUMMARY $ct_index $ct_kind [get_clock_domain_info -$ct_kind]
                if {$ct_kind eq "mpw"} {continue}
                report_clock_transfers -$ct_kind -file "$ct_reports/c${ct_index}-${ct_kind}-transfers.rpt"
                # Explicit samples; not exhaustive endpoint/exception coverage.
                report_timing -$ct_kind -npaths 20 -detail path_and_clock -file "$ct_reports/c${ct_index}-${ct_kind}-sample20.rpt"
                report_exceptions -$ct_kind -report_clock_groups -detail summary -num_exceptions 20001 -npaths 1 -file "$ct_reports/c${ct_index}-${ct_kind}-exceptions-sample1.rpt"
            }
            # Limits are per assignment; offline review checks actual saturation.
            report_net_delay -nworst 20001 -file "$ct_reports/c${ct_index}-net-delay.rpt"
            ::ia840f_compare04::emit SKEW_RETURN $ct_index [report_max_skew -npaths 20001 -detail summary -file "$ct_reports/c${ct_index}-max-skew.rpt"] per_assignment_limit 20001
            report_ucp -file "$ct_reports/c${ct_index}-unconstrained.rpt"
            ::ia840f_compare04::emit CORNER_COMPLETE $ct_index no_timing_acceptance
            incr ct_index
        }
        ::ia840f_compare04::require [expr {$ct_index == $ct_count}] "corner enumeration mismatch"
        ::ia840f_compare04::emit TRIAL_COMPLETE no_comparison_acceptance no_timing_acceptance no_hardware_qualification
        close $::ia840f_compare04::audit
        delete_timing_netlist
        project_close
        puts IA840F_CLOCK_TRIAL_COMPLETE
        flush stdout
    }
}
::ia840f_clock_trial01::main

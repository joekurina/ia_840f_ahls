# Definitions-only component for experiment04. No project or vendor entry here.
namespace eval ::ia840f_compare04 {
    variable E /home/uwb_student00/ahls/new_BSP/qualification/pcie-clock-repair-01/experiment04
    variable audit
    proc require {ia4s_value ia4s_reason} {
        if {!$ia4s_value} {error "COMPARE04_REJECT $ia4s_reason"}
    }
    proc emit {args} {
        variable audit
        puts $audit $args
        flush $audit
    }
    proc select_variant {ia4s_cwd} {
        variable E
        foreach ia4s_variant {baseline candidate} {
            if {$ia4s_cwd eq "$E/$ia4s_variant/scratch/syn/board/ia840f/syn_top"} {return $ia4s_variant}
        }
        error "COMPARE04_REJECT unexpected project path {$ia4s_cwd}"
    }
    proc observe {ia4s_label ia4s_collection ia4s_cap {ia4s_kind node}} {
        set ia4s_count [get_collection_size $ia4s_collection]
        emit COUNT $ia4s_label $ia4s_count cap $ia4s_cap
        require [expr {$ia4s_count >= 0 && $ia4s_count <= $ia4s_cap}] "collection count {$ia4s_label} actual=$ia4s_count cap=$ia4s_cap"
        set ia4s_raw {}
        foreach_in_collection ia4s_object $ia4s_collection {
            switch -- $ia4s_kind {
                pin {set ia4s_name [get_pin_info -name $ia4s_object]}
                cell {set ia4s_name [get_cell_info -name $ia4s_object]}
                clock {set ia4s_name [get_clock_info -name $ia4s_object]}
                node {set ia4s_name [get_node_info -name $ia4s_object]}
                default {error "COMPARE04_REJECT unsupported object class {$ia4s_kind}"}
            }
            lappend ia4s_raw $ia4s_name
        }
        emit SET $ia4s_label $ia4s_raw
        require [expr {[llength $ia4s_raw] == $ia4s_count && [llength [lsort -unique $ia4s_raw]] == $ia4s_count}] "enumeration or duplicate identity {$ia4s_label} actual=$ia4s_count enumerated=[llength $ia4s_raw] unique=[llength [lsort -unique $ia4s_raw]]"
        return [lsort $ia4s_raw]
    }
    proc exact_root {ia4s_command ia4s_name ia4s_kind ia4s_label} {
        set ia4s_collection [$ia4s_command -nowarn [list $ia4s_name]]
        set ia4s_names [observe $ia4s_label $ia4s_collection 32 $ia4s_kind]
        require [expr {$ia4s_names eq [list $ia4s_name]}] "root identity {$ia4s_label} actual=[llength $ia4s_names] expected=1 names={$ia4s_names}"
        return $ia4s_collection
    }
    proc set_delta {ia4s_baseline ia4s_observed} {
        set ia4s_left {};set ia4s_right {};set ia4s_common {}
        foreach ia4s_name $ia4s_baseline {
            if {[lsearch -exact $ia4s_observed $ia4s_name] < 0} {lappend ia4s_left $ia4s_name} else {lappend ia4s_common $ia4s_name}
        }
        foreach ia4s_name $ia4s_observed {
            if {[lsearch -exact $ia4s_baseline $ia4s_name] < 0} {lappend ia4s_right $ia4s_name}
        }
        return [dict create baseline_only [lsort $ia4s_left] observed_only [lsort $ia4s_right] intersection [lsort $ia4s_common]]
    }
    proc capture_scope {ia4s_variant ia4s_D ia4s_expected} {
        require [expr {$ia4s_variant in {baseline candidate}}] "unknown variant {$ia4s_variant}"
        require [expr {[llength $ia4s_expected] == 459 && [llength [lsort -unique $ia4s_expected]] == 459}] "invalid captured baseline reference"
        set ia4s_expected [lsort $ia4s_expected]
        set ia4s_output [exact_root get_pins "$ia4s_D|clock_div2" pin output_root]
        set ia4s_keeper [exact_root get_keepers "${ia4s_D}~div_reg" node keeper_root]
        # These are unfiltered native collections, not a claimed clock-only domain.
        set ia4s_pin_all [get_fanouts $ia4s_output]
        set ia4s_pin_names [observe pin_all $ia4s_pin_all 4096]
        require [expr {[llength $ia4s_pin_names] > 0}] "empty pin fanouts actual=0 cap=4096"
        set ia4s_keeper_all [get_fanouts $ia4s_keeper]
        set ia4s_keeper_names [observe keeper_all $ia4s_keeper_all 4096]
        require [expr {[llength $ia4s_keeper_names] > 0}] "empty keeper fanouts actual=0 cap=4096"
        set ia4s_union [add_to_collection $ia4s_pin_all $ia4s_keeper_all]
        set ia4s_union_names [observe union $ia4s_union 4096]
        require [expr {$ia4s_union_names eq [lsort -unique [concat $ia4s_pin_names $ia4s_keeper_names]]}] "native union identity mismatch"
        set ia4s_pin_delta [set_delta $ia4s_expected $ia4s_pin_names]
        set ia4s_keeper_delta [set_delta $ia4s_expected $ia4s_keeper_names]
        emit BASELINE_RELATION pin_all $ia4s_pin_delta
        emit BASELINE_RELATION keeper_all $ia4s_keeper_delta
        emit ROOT_RELATION [set_delta $ia4s_pin_names $ia4s_keeper_names]
        if {$ia4s_variant eq "baseline"} {
            require [expr {$ia4s_pin_names eq $ia4s_expected && $ia4s_keeper_names eq $ia4s_expected}] "baseline full-name set differs from accepted diagnostic"
        }
        # Do not reconstruct singleton keepers from each returned string. Native
        # duplicate matching can add objects. This is explicitly aggregate only;
        # per-receiver mapping and path/clock coverage are separate query stages.
        set ia4s_clocks [get_clocks -nowarn -of_objects $ia4s_union]
        set ia4s_clock_names [observe aggregate_driving_clocks $ia4s_clocks 256 clock]
        emit AGGREGATE_ASSOCIATIONS $ia4s_clock_names aggregate_only_not_per_node
        emit SCOPE_COMPLETE $ia4s_variant conservative_nodes [llength $ia4s_union_names] no_collector_acceptance no_comparison_acceptance
        return [dict create pin_collection $ia4s_pin_all keeper_collection $ia4s_keeper_all union_collection $ia4s_union pin_names $ia4s_pin_names keeper_names $ia4s_keeper_names union_names $ia4s_union_names pin_delta $ia4s_pin_delta keeper_delta $ia4s_keeper_delta aggregate_clocks $ia4s_clock_names association_scope aggregate_only_not_per_node]
    }
}

# Definitions-only full-SDC inventory comparison. The caller supplies the native
# snapshot_v2 result; its raw collection-count and generated-type checks remain
# required. This comparison is against captured post-full-SDC data, never a
# surrogate for candidate insertion-time observation.
namespace eval ::ia840f_compare04 {
    proc canonical_clock_definition {ia4c_value} {
        set ia4c_keys {generated period targets type waveform}
        require [expr {[lsort [dict keys $ia4c_value]] eq $ia4c_keys}] "unexpected clock definition fields"
        set ia4c_type [dict get $ia4c_value type]
        require [expr {$ia4c_type in {base virtual_base generated virtual_generated}}] "unexpected clock definition type"
        set ia4c_period [dict get $ia4c_value period]
        require [expr {[string is double -strict $ia4c_period] && $ia4c_period > 0}] "invalid clock period"
        set ia4c_wave [dict get $ia4c_value waveform]
        require [expr {[llength $ia4c_wave] == 2}] "unexpected waveform length"
        foreach ia4c_edge $ia4c_wave {
            require [string is double -strict $ia4c_edge] "invalid waveform value"
        }
        set ia4c_targets [dict get $ia4c_value targets]
        require [expr {[llength $ia4c_targets] <= 4096 && [llength [lsort -unique $ia4c_targets]] == [llength $ia4c_targets]}] "target identity/count"
        set ia4c_generated [dict get $ia4c_value generated]
        if {$ia4c_type in {generated virtual_generated}} {
            require [expr {[llength $ia4c_generated] == 4}] "generated metadata width"
            set ia4c_generated [lrange $ia4c_generated 0 end]
        } else {require [expr {$ia4c_generated eq "not_applicable"}] "base clock generated properties"}
        # Canonical Tcl list serialization, not numeric rounding/renaming.
        return [dict create type $ia4c_type period $ia4c_period waveform [lrange $ia4c_wave 0 end] targets [lsort $ia4c_targets] generated $ia4c_generated]
    }
    proc verify_clock_inventory {ia4c_variant ia4c_state ia4c_expected ia4c_C} {
        require [expr {$ia4c_variant in {baseline candidate}}] "unknown inventory variant"
        emit CLOCK_INVENTORY_COUNT [dict size $ia4c_state] cap 256 expected_baseline [dict size $ia4c_expected]
        require [expr {[dict size $ia4c_state] <= 256 && [dict size $ia4c_expected] == 80 && ![dict exists $ia4c_expected $ia4c_C]}] "global inventory count/reference"
        emit CLOCK_INVENTORY_DEFINITIONS $ia4c_variant $ia4c_state
        set ia4c_want [lsort [dict keys $ia4c_expected]]
        if {$ia4c_variant eq "candidate"} {set ia4c_want [lsort [concat $ia4c_want [list $ia4c_C]]]}
        emit CLOCK_INVENTORY_DELTA [set_delta $ia4c_want [lsort [dict keys $ia4c_state]]]
        require [expr {[lsort [dict keys $ia4c_state]] eq $ia4c_want}] "global clock identity addition/removal"
        dict for {ia4c_name ia4c_definition} $ia4c_expected {
            set ia4c_observed [canonical_clock_definition [dict get $ia4c_state $ia4c_name]]
            set ia4c_reference [canonical_clock_definition $ia4c_definition]
            require [expr {$ia4c_observed eq $ia4c_reference}] "changed baseline clock definition {$ia4c_name}"
        }
        if {$ia4c_variant eq "candidate"} {
            canonical_clock_definition [dict get $ia4c_state $ia4c_C]
            # Exact new-C source/target/master/ratio/waveform and propagation are
            # separately checked by guard02 verify_created_v2 after full SDC.
        }
        emit CLOCK_INVENTORY_MATCH $ia4c_variant post_full_sdc_reference no_timing_acceptance
        return $ia4c_state
    }
}

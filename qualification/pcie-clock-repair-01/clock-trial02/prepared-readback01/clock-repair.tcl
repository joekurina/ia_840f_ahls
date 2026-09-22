# Isolated Work14 integration candidate. No nominal clock/exception changes.
namespace eval ::ia840f_clock_repair {
    variable H {pcie_wrapper|pcie_ss.top|host_pcie.pcie_ss|pcie_ss}
    variable D "$H|EP_PFTILE_WRAPPER.gen_pciess.u_pciess_p0|u_pciess|gen_sub.u_hipif|u_pciess_clock_divider|clkdiv_inst"
    variable M {sys_pll|iopll_0_clk_100m}
    variable C "$H|avmm_clock0"
    variable created 0
    proc require {condition message} {
        if {!$condition} {error "CLOCK_REPAIR_REJECT $message"}
    }
    proc names {collection kind} {
        set result {}
        foreach_in_collection object $collection {
            if {$kind eq "clock"} {lappend result [get_clock_info -name $object]} else {lappend result [get_node_info -name $object]}
        }
        return [lsort -unique $result]
    }
    proc one_pin {name input} {
        set collection [get_pins -nowarn [list $name]]
        require [expr {[get_collection_size $collection] == 1}] "pin cardinality {$name}"
        foreach_in_collection pin $collection {
            require [expr {[get_pin_info -name $pin] eq $name}] "pin identity {$name}"
            require [expr {[get_pin_info -is_clock_pin $pin] && [get_pin_info -is_in_pin $pin] == $input && [get_pin_info -is_out_pin $pin] == !$input}] "pin direction/type {$name}"
        }
        return $collection
    }
    proc apply {} {
        variable D; variable M; variable C; variable created
        require [expr {!$created}] "second invocation"
        set input [one_pin "$D|inclk" 1]
        set output [one_pin "$D|clock_div2" 0]
        set dividers [get_cells -nowarn [list $D]]
        require [expr {[get_collection_size $dividers] == 1}] "divider cardinality"
        foreach_in_collection cell $dividers {
            require [expr {[get_cell_info -name $cell] eq $D && [get_cell_info -wysiwyg_type $cell] eq "tennm_clk_divider"}] "divider identity/type"
        }
        set master [get_clocks -nowarn [list $M]]
        require [expr {[get_collection_size $master] == 1 && [names $master clock] eq [list $M]}] "master cardinality/name"
        set fanins [get_fanins -clock -stop_at_clocks $input]
        require [expr {[get_collection_size $fanins] == 1 && [names $fanins node] eq [list {sys_pll|iopll_0|tennm_pll|outclk[2]}]}] "physical master fanin"
        set incoming [get_clocks -nowarn -of_objects $input]
        require [expr {[get_collection_size $incoming] == 1 && [names $incoming clock] eq [list $M]}] "incoming master association"
        # Bound Work14 requires an absent starting assignment. Changed vendor
        # baselines require review, never overwrite/delete or blindly use -add.
        set named [get_clocks -nowarn [list $C]]
        set driven [get_clocks -nowarn -of_objects $output]
        set targets {}
        foreach_in_collection clock [get_clocks *] {
            foreach_in_collection target [get_clock_info -targets $clock] {
                set n [get_node_info -name $target]
                if {$n eq "$D|clock_div2" || $n eq "$D~div_reg"} {lappend targets [get_clock_info -name $clock]}
            }
        }
        puts [list CLOCK_REPAIR_PRECHECK name_count [get_collection_size $named] output_clocks [names $driven clock] target_clocks $targets]
        require [expr {[get_collection_size $named] == 0 && [get_collection_size $driven] == 0 && [llength $targets] == 0}] "preexisting output clock"
        create_generated_clock -name $C -source $input -master_clock $M -divide_by 2 $output
        set created 1
        puts [list CLOCK_REPAIR_CREATED name $C source "$D|inclk" target "$D|clock_div2" master $M divide_by 2]
    }
    proc verify_created {} {
        variable D; variable M; variable C; variable created
        require $created "candidate SDC was not executed"
        set clocks [get_clocks -nowarn [list $C]]
        require [expr {[get_collection_size $clocks] == 1}] "created clock cardinality"
        foreach_in_collection clock $clocks {
            require [expr {[get_clock_info -name $clock] eq $C && [get_clock_info -type $clock] eq "generated" && [get_clock_info -master_clock $clock] eq $M}] "created clock name/type/master"
            puts [list CLOCK_REPAIR_DEFINITION name $C targets [names [get_clock_info -targets $clock] node] source [get_clock_info -master_clock_pin $clock] period [get_clock_info -period $clock] waveform [get_clock_info -waveform $clock] divide_by [get_clock_info -divide_by $clock] multiply_by [get_clock_info -multiply_by $clock]]
            require [expr {[get_collection_size [get_clock_info -targets $clock]] == 1}] "created target cardinality"
        }
        set output [one_pin "$D|clock_div2" 0]
        set association [get_clocks -nowarn -of_objects $output]
        require [expr {[get_collection_size $association] == 1 && [names $association clock] eq [list $C]}] "output propagation"
    }
}


# Additive experiment04 entries. Original helper procedures above stay intact.
namespace eval ::ia840f_clock_repair {
    variable before_v2 {}
    proc raw_names_v2 {ia4_collection ia4_kind ia4_label ia4_limit} {
        set ia4_count [get_collection_size $ia4_collection]
        puts [list CLOCK_REPAIR_COUNT_V2 $ia4_label $ia4_count cap $ia4_limit];flush stdout
        require [expr {$ia4_count >= 0 && $ia4_count <= $ia4_limit}] "collection cap {$ia4_label} actual=$ia4_count cap=$ia4_limit"
        set ia4_names {}
        foreach_in_collection ia4_object $ia4_collection {
            if {$ia4_kind eq "clock"} {lappend ia4_names [get_clock_info -name $ia4_object]} else {lappend ia4_names [get_node_info -name $ia4_object]}
        }
        require [expr {[llength $ia4_names] == $ia4_count && [llength [lsort -unique $ia4_names]] == $ia4_count}] "enumeration/duplicate identity {$ia4_label}"
        return [lsort $ia4_names]
    }
    proc snapshot_v2 {} {
        set ia4_all [get_clocks *]
        raw_names_v2 $ia4_all clock global_clock_inventory 256
        set ia4_state [dict create]
        foreach_in_collection ia4_clock $ia4_all {
            set ia4_name [get_clock_info -name $ia4_clock]
            set ia4_type [get_clock_info -type $ia4_clock]
            set ia4_properties not_applicable
            if {$ia4_type in {generated virtual_generated}} {
                set ia4_properties [list [get_clock_info -master_clock $ia4_clock] [get_clock_info -master_clock_pin $ia4_clock] [get_clock_info -divide_by $ia4_clock] [get_clock_info -multiply_by $ia4_clock]]
            } else {require [expr {$ia4_type in {base virtual_base}}] "unexpected clock type {$ia4_type}"}
            set ia4_targets [raw_names_v2 [get_clock_info -targets $ia4_clock] node "targets:$ia4_name" 4096]
            dict set ia4_state $ia4_name [dict create type $ia4_type period [get_clock_info -period $ia4_clock] waveform [get_clock_info -waveform $ia4_clock] targets $ia4_targets generated $ia4_properties]
        }
        return $ia4_state
    }
    proc unchanged_except_c_v2 {ia4_after} {
        variable before_v2; variable C
        puts [list CLOCK_REPAIR_GLOBAL_DELTA_V2 before [dict keys $before_v2] after [dict keys $ia4_after]];flush stdout
        require [expr {![dict exists $before_v2 $C] && [dict exists $ia4_after $C] && [dict size $ia4_after] == [dict size $before_v2]+1}] "unexpected global clock addition/removal"
        dict for {ia4_name ia4_definition} $before_v2 {
            require [expr {[dict exists $ia4_after $ia4_name] && [dict get $ia4_after $ia4_name] eq $ia4_definition}] "changed other clock definition {$ia4_name}"
        }
    }
    proc apply_v2 {} {
        variable D;variable M;variable C;variable created;variable before_v2
        require [expr {!$created}] "second invocation"
        set ia4_input [get_pins -nowarn [list "$D|inclk"]]
        set ia4_output [get_pins -nowarn [list "$D|clock_div2"]]
        foreach {ia4_collection ia4_name ia4_in} [list $ia4_input "$D|inclk" 1 $ia4_output "$D|clock_div2" 0] {
            set ia4_names [raw_names_v2 $ia4_collection node $ia4_name 32]
            require [expr {$ia4_names eq [list $ia4_name]}] "pin cardinality/identity {$ia4_name}"
            foreach_in_collection ia4_pin $ia4_collection {
                require [expr {[get_pin_info -is_clock_pin $ia4_pin] && [get_pin_info -is_in_pin $ia4_pin] == $ia4_in && [get_pin_info -is_out_pin $ia4_pin] == !$ia4_in}] "pin direction/type {$ia4_name}"
            }
        }
        set ia4_dividers [get_cells -nowarn [list $D]]
        set ia4_nd [get_collection_size $ia4_dividers]
        puts [list CLOCK_REPAIR_COUNT_V2 divider $ia4_nd expected 1];flush stdout
        require [expr {$ia4_nd == 1}] "divider cardinality actual=$ia4_nd"
        foreach_in_collection ia4_cell $ia4_dividers {
            require [expr {[get_cell_info -name $ia4_cell] eq $D && [get_cell_info -wysiwyg_type $ia4_cell] eq "tennm_clk_divider"}] "divider identity/type"
        }
        require [expr {[raw_names_v2 [get_clocks -nowarn [list $M]] clock master 256] eq [list $M]}] "master cardinality/name"
        require [expr {[raw_names_v2 [get_fanins -clock -stop_at_clocks $ia4_input] node physical_master 32] eq [list {sys_pll|iopll_0|tennm_pll|outclk[2]}]}] "physical master fanin"
        require [expr {[raw_names_v2 [get_clocks -nowarn -of_objects $ia4_input] clock incoming 256] eq [list $M]}] "incoming master association"
        set ia4_named [raw_names_v2 [get_clocks -nowarn [list $C]] clock candidate_name 256]
        set ia4_driven [raw_names_v2 [get_clocks -nowarn -of_objects $ia4_output] clock output_driving 256]
        set before_v2 [snapshot_v2]
        set ia4_definitions {}
        dict for {ia4_name ia4_definition} $before_v2 {
            foreach ia4_target [dict get $ia4_definition targets] {
                if {$ia4_target eq "$D|clock_div2" || $ia4_target eq "$D~div_reg"} {lappend ia4_definitions $ia4_name}
            }
        }
        puts [list CLOCK_REPAIR_PRECHECK_V2 named $ia4_named output_driving $ia4_driven explicit_output_definitions $ia4_definitions definitions $before_v2];flush stdout
        require [expr {$ia4_named eq {} && $ia4_definitions eq {}}] "preexisting output clock definition/name"
        require [expr {$ia4_driven eq [list $M]}] "unexpected output driving association"
        require [expr {[dict get $before_v2 $M targets] eq [list {sys_pll|iopll_0|tennm_pll|outclk[2]}]}] "master definition target"
        create_generated_clock -name $C -source $ia4_input -master_clock $M -divide_by 2 $ia4_output
        set created 1
        unchanged_except_c_v2 [snapshot_v2]
        puts [list CLOCK_REPAIR_CREATED_V2 name $C source "$D|inclk" target "$D|clock_div2" master $M divide_by 2];flush stdout
    }
    proc half_quantum_v2 {ia4_value} {
        require [regexp {^-?[0-9]+\.([0-9]{3,})$} $ia4_value ia4_match ia4_fraction] "unsupported returned timing precision {$ia4_value}"
        return [expr {0.5*pow(10.0,-[string length $ia4_fraction])}]
    }
    proc verify_created_v2 {} {
        variable D;variable M;variable C;variable created
        require $created "candidate SDC was not executed"
        set ia4_after [snapshot_v2];unchanged_except_c_v2 $ia4_after
        set ia4_clocks [get_clocks -nowarn [list $C]]
        require [expr {[raw_names_v2 $ia4_clocks clock created_name 256] eq [list $C]}] "created name/cardinality"
        set ia4_md [dict get $ia4_after $M]
        foreach_in_collection ia4_clock $ia4_clocks {
            set ia4_cd [dict get $ia4_after $C]
            require [expr {[dict get $ia4_cd type] eq "generated" && [dict get $ia4_cd targets] eq [list "$D|clock_div2"]}] "created type/target"
            lassign [dict get $ia4_cd generated] ia4_master ia4_source ia4_divide ia4_multiply
            require [expr {$ia4_master eq $M && $ia4_source eq "$D|inclk"}] "created source/master"
            require [expr {[string is integer -strict $ia4_divide] && [string is integer -strict $ia4_multiply] && $ia4_divide == 2 && $ia4_multiply == 1}] "unexpected generated ratio representation"
            set ia4_inverted [get_clock_info -is_inverted $ia4_clock]
            set ia4_edges [get_clock_info -edges $ia4_clock]
            set ia4_shifts [get_clock_info -edge_shifts $ia4_clock]
            puts [list CLOCK_REPAIR_DEFINITION_V2 name $C definition $ia4_cd master_definition $ia4_md inverted $ia4_inverted edges $ia4_edges edge_shifts $ia4_shifts];flush stdout
            require [expr {!$ia4_inverted}] "unexpected inversion"
            set ia4_mp [dict get $ia4_md period];set ia4_cp [dict get $ia4_cd period]
            set ia4_mq [half_quantum_v2 $ia4_mp];set ia4_cq [half_quantum_v2 $ia4_cp]
            require [expr {$ia4_mp > 0 && $ia4_cp > 0 && abs(double($ia4_cp)-2.0*double($ia4_mp)) <= $ia4_cq+2.0*$ia4_mq+1e-12}] "generated period relation"
            set ia4_mw [dict get $ia4_md waveform];set ia4_cw [dict get $ia4_cd waveform]
            require [expr {[llength $ia4_mw] == 2 && [llength $ia4_cw] == 2}] "waveform cardinality"
            lassign $ia4_mw ia4_mrise ia4_mfall;lassign $ia4_cw ia4_crise ia4_cfall
            set ia4_mrq [half_quantum_v2 $ia4_mrise];set ia4_crq [half_quantum_v2 $ia4_crise];set ia4_cfq [half_quantum_v2 $ia4_cfall]
            require [expr {abs(double($ia4_crise)-double($ia4_mrise)) <= $ia4_crq+$ia4_mrq+1e-12 && abs(double($ia4_cfall)-double($ia4_mrise)-double($ia4_mp)) <= $ia4_cfq+$ia4_mrq+$ia4_mq+1e-12}] "generated waveform relation"
        }
        set ia4_output [post_output_pin_v2]
        require [expr {[raw_names_v2 [get_clocks -nowarn -of_objects $ia4_output] clock output_propagation 256] eq [list $C]}] "output propagation"
        puts [list CLOCK_REPAIR_VERIFIED_V2 $C no_timing_acceptance];flush stdout
    }
}


namespace eval ::ia840f_clock_repair {
    proc post_output_pin_v2 {} {
        variable D
        set ia4_name "$D|clock_div2"
        set ia4_collection [get_pins -nowarn [list $ia4_name]]
        set ia4_names [raw_names_v2 $ia4_collection node post-output-pin 32]
        require [expr {$ia4_names eq [list $ia4_name]}] "post output pin identity/cardinality actual=[llength $ia4_names] expected=1"
        foreach_in_collection ia4_pin $ia4_collection {
            require [expr {[get_pin_info -name $ia4_pin] eq $ia4_name && [get_pin_info -is_clock_pin $ia4_pin] && ![get_pin_info -is_in_pin $ia4_pin] && [get_pin_info -is_out_pin $ia4_pin]}] "post output pin direction/type/name"
        }
        return $ia4_collection
    }
}


# Final-SDC boundary uses the pinned final baseline, not insertion-time state.
# apply_v2 and its immediate C-only delta check remain unchanged above.
namespace eval ::ia840f_clock_repair {
    proc verify_created_final_v3 {ia4_final_baseline} {
        variable D;variable M;variable C;variable created
        require $created "candidate SDC was not executed"
        set ia4_after [snapshot_v2]
        ::ia840f_compare04::verify_clock_inventory candidate $ia4_after $ia4_final_baseline $C
        set ia4_clocks [get_clocks -nowarn [list $C]]
        require [expr {[raw_names_v2 $ia4_clocks clock created_name 256] eq [list $C]}] "created name/cardinality"
        set ia4_md [dict get $ia4_after $M]
        foreach_in_collection ia4_clock $ia4_clocks {
            set ia4_cd [dict get $ia4_after $C]
            require [expr {[dict get $ia4_cd type] eq "generated" && [dict get $ia4_cd targets] eq [list "$D|clock_div2"]}] "created type/target"
            lassign [dict get $ia4_cd generated] ia4_master ia4_source ia4_divide ia4_multiply
            require [expr {$ia4_master eq $M && $ia4_source eq "$D|inclk"}] "created source/master"
            require [expr {[string is integer -strict $ia4_divide] && [string is integer -strict $ia4_multiply] && $ia4_divide == 2 && $ia4_multiply == 1}] "unexpected generated ratio representation"
            set ia4_inverted [get_clock_info -is_inverted $ia4_clock]
            set ia4_edges [get_clock_info -edges $ia4_clock]
            set ia4_shifts [get_clock_info -edge_shifts $ia4_clock]
            puts [list CLOCK_REPAIR_DEFINITION_V2 name $C definition $ia4_cd master_definition $ia4_md inverted $ia4_inverted edges $ia4_edges edge_shifts $ia4_shifts];flush stdout
            require [expr {!$ia4_inverted}] "unexpected inversion"
            set ia4_mp [dict get $ia4_md period];set ia4_cp [dict get $ia4_cd period]
            set ia4_mq [half_quantum_v2 $ia4_mp];set ia4_cq [half_quantum_v2 $ia4_cp]
            require [expr {$ia4_mp > 0 && $ia4_cp > 0 && abs(double($ia4_cp)-2.0*double($ia4_mp)) <= $ia4_cq+2.0*$ia4_mq+1e-12}] "generated period relation"
            set ia4_mw [dict get $ia4_md waveform];set ia4_cw [dict get $ia4_cd waveform]
            require [expr {[llength $ia4_mw] == 2 && [llength $ia4_cw] == 2}] "waveform cardinality"
            lassign $ia4_mw ia4_mrise ia4_mfall;lassign $ia4_cw ia4_crise ia4_cfall
            set ia4_mrq [half_quantum_v2 $ia4_mrise];set ia4_crq [half_quantum_v2 $ia4_crise];set ia4_cfq [half_quantum_v2 $ia4_cfall]
            require [expr {abs(double($ia4_crise)-double($ia4_mrise)) <= $ia4_crq+$ia4_mrq+1e-12 && abs(double($ia4_cfall)-double($ia4_mrise)-double($ia4_mp)) <= $ia4_cfq+$ia4_mrq+$ia4_mq+1e-12}] "generated waveform relation"
        }
        set ia4_output [post_output_pin_v2]
        require [expr {[raw_names_v2 [get_clocks -nowarn -of_objects $ia4_output] clock output_propagation 256] eq [list $C]}] "output propagation"
        puts [list CLOCK_REPAIR_VERIFIED_FINAL_V3 $C no_timing_acceptance];flush stdout
    }
}

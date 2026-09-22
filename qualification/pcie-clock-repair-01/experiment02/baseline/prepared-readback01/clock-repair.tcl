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

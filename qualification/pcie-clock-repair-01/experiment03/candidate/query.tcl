# Fresh A/B analysis of the unchanged Work14 fit; never a fit or FPGA run.
load_package sta
load_package report
source [file join [file dirname [info script]] clock-repair.tcl]
namespace eval ::ia840f_constraint_compare {
    variable audit
    variable E /home/uwb_student00/ahls/new_BSP/qualification/pcie-clock-repair-01/experiment03
    variable limit 20001
    proc emit {args} {variable audit; puts $audit $args; flush $audit}
    proc require {value why} {::ia840f_clock_repair::require $value $why}
    proc names {collection kind} {return [::ia840f_clock_repair::names $collection $kind]}
    proc literal {name} {
        require [expr {[string first [format %c 92] $name] < 0}] "unsupported backslash in exact keeper name"
        return [string map [list {[} {[[]} {*} {[*]} {?} {[?]}] $name]
    }
    proc keeper {name} {
        set found [get_keepers -nowarn [list [literal $name]]]
        require [expr {[get_collection_size $found] == 1 && [names $found node] eq [list $name]}] "exact keeper {$name}"
        return $found
    }
    proc clock_names {collection} {return [names [get_clocks -nowarn -of_objects $collection] clock]}
    proc clock_id_name {id} {if {$id eq ""} {return {}}; return [get_clock_info -name $id]}
    proc node_id_name {id} {if {$id eq ""} {return {}}; return [get_node_info -name $id]}
    proc paths {corner kind direction collection category} {
        variable limit
        set cmd [list get_timing_paths -$kind -$direction $collection -npaths $limit -pairs_only]
        if {$category eq "cut"} {lappend cmd -false_path}
        if {$category eq "data_delay"} {lappend cmd -data_delay}
        set found [{*}$cmd]
        set count [get_collection_size $found]
        emit PATH_SET $corner $kind $direction $category $count $limit
        require [expr {$count < $limit}] "path output cap reached"
        foreach_in_collection path $found {
            emit PATH $corner $kind $direction $category [node_id_name [get_path_info -from $path]] [node_id_name [get_path_info -to $path]] [clock_id_name [get_path_info -from_clock $path]] [clock_id_name [get_path_info -to_clock $path]] [get_path_info -slack $path] [get_path_info -data_delay $path] [get_path_info -setup_start_multicycle $path] [get_path_info -setup_end_multicycle $path] [get_path_info -hold_start_multicycle $path] [get_path_info -hold_end_multicycle $path]
        }
    }
    proc main {} {
        variable E; variable audit; variable limit
        set variant {}
        foreach name {baseline candidate} {
            if {[pwd] eq "$E/$name/scratch/syn/board/ia840f/syn_top"} {set variant $name}
        }
        require [expr {$variant ne ""}] "unexpected project path"
        set reports "$E/$variant/reports"
        require [expr {![file exists $reports]}] "spent reports directory"
        file mkdir $reports
        set audit [open "$reports/audit.tcllist" {WRONLY CREAT EXCL}]
        emit BEGIN $variant no_fit no_hardware no_timing_acceptance
        project_open -revision ofs_top ofs_top
        if {[info exists ::ia840f_gate_result]} {error "SOURCE_BOUND_GATE_REJECTION_STOP"}
        create_timing_netlist
        read_sdc
        update_timing_netlist
        set C $::ia840f_clock_repair::C
        set M $::ia840f_clock_repair::M
        set D $::ia840f_clock_repair::D
        set H $::ia840f_clock_repair::H
        if {$variant eq "candidate"} {::ia840f_clock_repair::verify_created} else {
            require [expr {!$::ia840f_clock_repair::created && [get_collection_size [get_clocks -nowarn [list $C]]] == 0}] "baseline changed"
        }
        set all_clocks [get_clocks *]
        require [expr {[get_collection_size $all_clocks] <= 256}] "clock inventory cap"
        foreach_in_collection c $all_clocks {
            emit CLOCK [get_clock_info -name $c] [get_clock_info -type $c] [get_clock_info -master_clock $c] [get_clock_info -master_clock_pin $c] [get_clock_info -period $c] [get_clock_info -waveform $c] [names [get_clock_info -targets $c] node] [get_clock_info -divide_by $c] [get_clock_info -multiply_by $c]
        }
        foreach pattern [list {*avmm_clock0} {pcie_wrapper|pcie_ss.top|*|pcie_ss|avmm_clock0} $M {pcie_wrapper|pcie_ss.top|*|pcie_ss|*|inst|inst|maib_and_tile|xcvr_hip_native|rx_ch15} {sys_pll|iopll_0_clk_sys} {altera_reserved_tck}] {
            emit MEMBERSHIP $pattern [names [get_clocks -nowarn [list $pattern]] clock]
        }
        set output [::ia840f_clock_repair::one_pin "$D|clock_div2" 0]
        set loads [get_fanouts -clock $output]
        set load_count [get_collection_size $loads]
        require [expr {$load_count > 0 && $load_count <= 4096}] "clock load cardinality/cap"
        emit LOAD_COUNT $load_count
        set edges 0
        foreach_in_collection load $loads {
            set name [get_node_info -name $load]
            set exact [keeper $name]
            set clocks [clock_names $exact]
            emit LOAD $name $clocks
            if {$variant eq "candidate"} {require [expr {$clocks eq [list $C]}] "load propagation {$name}"}
            # Structural adjacency also records paths unclocked in the baseline.
            foreach direction {get_fanins get_fanouts} {
                set connected [$direction -synch -asynch $exact]
                require [expr {[get_collection_size $connected] <= 4096}] "adjacency per-load cap"
                foreach_in_collection node $connected {
                    incr edges
                    require [expr {$edges <= 50000}] "adjacency total cap"
                    set other [get_node_info -name $node]
                    emit ADJACENCY $direction $name $other [clock_names [keeper $other]]
                }
            }
        }
        emit ADJACENCY_COUNT $edges
        set P "$H|EP_PFTILE_WRAPPER.gen_pciess.u_pciess_p0|u_pciess|gen_sub.u_hipif"
        set groups [list [list u_pciess_cplto_if|cplto_fifo_avmm_inst rs_dgwp delayed_wrptr_g*] [list u_pciess_cplto_if|cplto_fifo_lite_inst ws_dgrp *rdptr_g*] [list EP_CFG_IF.u_pciess_cfg_if|u_axi_lite_clk_to_user_avmm_clk_fifo rs_dgwp delayed_wrptr_g*] [list EP_CFG_IF.u_pciess_cfg_if|u_user_avmm_clk_to_axi_lite_clk_fifo ws_dgrp *rdptr_g*]]
        set i 0
        foreach group $groups {
            lassign $group fifo chain source
            set receivers [get_keepers -nowarn [list "$P|$fifo|auto_generated|$chain|dffpipe*|dffe*"]]
            require [expr {[get_collection_size $receivers] == 8}] "FIFO receiver cardinality $i"
            set senders [get_keepers -nowarn [list "$P|$fifo|auto_generated|$source"]]
            require [expr {[get_collection_size $senders] > 0 && [get_collection_size $senders] <= 128}] "FIFO sender cardinality $i"
            emit FIFO_SOURCE $i [names $senders node] [clock_names $senders]
            foreach_in_collection node $receivers {
                set n [get_node_info -name $node]; set clocks [clock_names [keeper $n]]
                emit FIFO_RECEIVER $i $n $clocks
                if {$variant eq "candidate"} {require [expr {$clocks eq [list $C]}] "FIFO clock propagation $i {$n}"}
            }
            incr i
        }
        report_clocks -file "$reports/clocks.rpt"
        report_sdc -file "$reports/sdc.rpt"
        report_sdc -ignored -file "$reports/sdc-ignored.rpt"
        check_timing -include {no_clock multiple_clock generated_clock uncertainty partial_multicycle multicycle_consistency partial_min_max_delay} -file "$reports/check-timing.rpt"
        set corners [get_available_operating_conditions]
        require [expr {[llength $corners] > 0 && [llength $corners] <= 16}] "analysis corner cardinality/cap"
        emit CORNERS $corners
        set i 0
        foreach corner $corners {
            set_operating_conditions $corner
            update_timing_netlist -dynamic_borrow
            emit CORNER $i $corner
            foreach kind {setup hold recovery removal mpw} {
                emit GLOBAL_DOMAIN_SUMMARY $i $kind [get_clock_domain_info -$kind]
                if {$kind eq "mpw"} {continue}
                report_clock_transfers -$kind -file "$reports/c${i}-$kind-transfers.rpt"
                report_exceptions -$kind -report_clock_groups -detail summary -file "$reports/c${i}-$kind-exceptions.rpt"
                report_timing -$kind -npaths 20 -detail path_and_clock -file "$reports/c${i}-$kind-global-worst.rpt"
                foreach direction {from to} {
                    foreach category {timed cut} {paths $i $kind $direction $loads $category}
                    if {$kind eq "setup" || $kind eq "recovery"} {paths $i $kind $direction $loads data_delay}
                    report_exceptions -$kind -$direction $loads -report_clock_groups -npaths $limit -pairs_only -detail path_summary -file "$reports/c${i}-$kind-$direction-exceptions.rpt"
                }
            }
            report_min_pulse_width -nworst 20 -file "$reports/c${i}-mpw.rpt" $loads
            report_net_delay -file "$reports/c${i}-net-delay.rpt"
            set skew [report_max_skew -npaths $limit -detail summary -file "$reports/c${i}-max-skew.rpt"]
            emit SKEW_RETURN $i $skew
            require [expr {[lindex $skew 0] < $limit}] "skew output potentially capped"
            report_ucp -file "$reports/c${i}-unconstrained.rpt"
            incr i
        }
        emit COMPLETE $variant $i $load_count $edges no_timing_acceptance
        close $audit
        delete_timing_netlist
        project_close
        puts "IA840F_CONSTRAINT_COMPARE_COMPLETE $variant"
    }
}
::ia840f_constraint_compare::main

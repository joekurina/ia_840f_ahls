# Baseline-only collector diagnosis. No clock creation, exception edit or fit.
load_package sta
load_package report
source [file join [file dirname [info script]] clock-repair.tcl]
source [file join [file dirname [info script]] known-receivers.tcl]
namespace eval ::ia840f_fanout_diagnostic {
    variable E /home/uwb_student00/ahls/new_BSP/qualification/pcie-clock-repair-01/fanout-diagnostic01
    variable cap 4096
    variable audit
    proc emit {args} {variable audit; puts $audit $args; flush $audit}
    proc require {value why} {::ia840f_clock_repair::require $value $why}
    proc names {collection kind} {return [::ia840f_clock_repair::names $collection $kind]}
    proc literal {name} {
        require [expr {[string first [format %c 92] $name] < 0}] "unsupported backslash in exact name"
        return [string map [list {[} {[[]} {*} {[*]} {?} {[?]}] $name]
    }
    proc exact {command name label} {
        set collection [$command -nowarn [list [literal $name]]]
        set n [get_collection_size $collection]
        emit IDENTITY_COUNT $label $name $n 1
        require [expr {$n == 1}] "identity count {$label} actual=$n expected=1"
        set resolved [names $collection node]
        emit IDENTITY $label $resolved
        require [expr {$resolved eq [list $name]}] "identity mismatch {$label}"
        return $collection
    }
    proc clock_names {collection} {return [names [get_clocks -nowarn -of_objects $collection] clock]}
    proc inventory_clocks {} {
        set clocks [get_clocks *]
        set n [get_collection_size $clocks]
        emit CLOCK_COUNT $n 256
        require [expr {$n <= 256}] "clock inventory actual=$n cap=256"
        foreach_in_collection c $clocks {
            set type [get_clock_info -type $c]
            set extra {not_applicable}
            if {$type in {generated virtual_generated}} {
                set extra [list generated_properties [get_clock_info -master_clock $c] [get_clock_info -master_clock_pin $c] [get_clock_info -divide_by $c] [get_clock_info -multiply_by $c]]
            } else {require [expr {$type in {base virtual_base}}] "unknown clock type {$type}"}
            emit CLOCK [get_clock_info -name $c] $type [get_clock_info -period $c] [get_clock_info -waveform $c] [names [get_clock_info -targets $c] node] $extra
        }
    }
    proc enumerate_loads {label collection count} {
        variable cap
        if {$count > $cap} {
            emit SET_STATUS $label incomplete cap_exceeded $count $cap
            return [dict create complete 0 names {} unique unavailable]
        }
        set raw {}
        foreach_in_collection node $collection {
            set name [get_node_info -name $node]
            lappend raw $name
            set keeper [exact get_keepers $name "load:$label"]
            emit LOAD $label $name [clock_names $keeper]
        }
        set unique [lsort -unique $raw]
        set valid [expr {[llength $raw] == $count && [llength $unique] == $count}]
        emit SET_STATUS $label $valid raw $count enumerated [llength $raw] unique [llength $unique]
        return [dict create complete $valid names $unique unique [llength $unique]]
    }
    proc member {set_info name} {
        if {![dict get $set_info complete]} {return unavailable}
        return [expr {[lsearch -exact [dict get $set_info names] $name] >= 0}]
    }
    proc main {} {
        variable E; variable audit; variable cap
        require [expr {[pwd] eq "$E/scratch/syn/board/ia840f/syn_top"}] "unexpected project path"
        set reports "$E/reports"
        require [expr {![file exists $reports]}] "spent reports directory"
        file mkdir $reports
        set audit [open "$reports/audit.tcllist" {WRONLY CREAT EXCL}]
        emit BEGIN diagnostic_only unchanged_sdc no_fit no_hardware no_timing_acceptance
        project_open -revision ofs_top ofs_top
        if {[info exists ::ia840f_gate_result]} {error "SOURCE_BOUND_GATE_REJECTION_STOP"}
        create_timing_netlist
        read_sdc
        update_timing_netlist
        set D $::ia840f_clock_repair::D
        set H $::ia840f_clock_repair::H
        set C $::ia840f_clock_repair::C
        set K "${D}~div_reg"
        set target_clocks [get_clocks -nowarn [list $C]]
        set n [get_collection_size $target_clocks]
        emit BASELINE_GENERATED_NAME_COUNT $C $n
        require [expr {!$::ia840f_clock_repair::created && $n == 0}] "baseline clock changed"
        inventory_clocks
        set output [::ia840f_clock_repair::one_pin "$D|clock_div2" 0]
        foreach_in_collection pin $output {
            emit ROOT pin [get_pin_info -name $pin] [get_collection_size $output] [get_pin_info -is_in_pin $pin] [get_pin_info -is_out_pin $pin] [get_pin_info -is_clock_pin $pin] [clock_names $output]
        }
        set pin_loads [get_fanouts -clock $output]
        set pin_count [get_collection_size $pin_loads]
        emit FANOUT_COUNT pin $pin_count cap $cap
        # Resolve only the separately observed exact keeper; never a fallback.
        set root [exact get_keepers $K keeper_root]
        set register [exact get_registers $K register_root]
        emit ROOT keeper $K [clock_names $root] register [names $register node]
        set keeper_loads [get_fanouts -clock $root]
        set keeper_count [get_collection_size $keeper_loads]
        emit FANOUT_COUNT keeper $keeper_count cap $cap
        # Both counts precede either range decision. Zero is recorded, not hidden.
        set pin_set [enumerate_loads pin $pin_loads $pin_count]
        set keeper_set [enumerate_loads keeper $keeper_loads $keeper_count]
        set complete [expr {[dict get $pin_set complete] && [dict get $keeper_set complete]}]
        if {$complete} {
            set pin_only {}; set keeper_only {}; set intersection {}
            foreach name [dict get $pin_set names] {
                if {[member $keeper_set $name]} {lappend intersection $name} else {lappend pin_only $name}
            }
            foreach name [dict get $keeper_set names] {if {![member $pin_set $name]} {lappend keeper_only $name}}
            emit SET_RELATION pin_only [llength $pin_only] $pin_only keeper_only [llength $keeper_only] $keeper_only intersection [llength $intersection]
        } else {emit SET_RELATION unavailable incomplete_enumeration}
        set P "$H|EP_PFTILE_WRAPPER.gen_pciess.u_pciess_p0|u_pciess|gen_sub.u_hipif"
        set groups [list [list u_pciess_cplto_if|cplto_fifo_avmm_inst rs_dgwp] [list u_pciess_cplto_if|cplto_fifo_lite_inst ws_dgrp] [list EP_CFG_IF.u_pciess_cfg_if|u_axi_lite_clk_to_user_avmm_clk_fifo rs_dgwp] [list EP_CFG_IF.u_pciess_cfg_if|u_user_avmm_clk_to_axi_lite_clk_fifo ws_dgrp]]
        set all_known {};set counts [dict create 0 0 1 0 2 0 3 0]
        set missing_pin {};set missing_keeper {}
        emit KNOWN_MANIFEST_COUNT [llength $::ia840f_known_receivers] 32
        require [expr {[llength $::ia840f_known_receivers] == 32}] "known receiver manifest count"
        foreach entry $::ia840f_known_receivers {
            lassign $entry group cell clock_pin
            require [dict exists $counts $group] "unexpected known group"
            dict incr counts $group
            lappend all_known $cell
            set receiver [exact get_keepers $cell known_receiver]
            set input [exact get_pins $clock_pin known_clock_pin]
            foreach_in_collection pin $input {
                require [expr {[get_pin_info -is_in_pin $pin] && [get_pin_info -is_clock_pin $pin]}] "known receiver clock input {$clock_pin}"
            }
            set fanin [get_fanins -clock -stop_at_clocks $input]
            set fc [get_collection_size $fanin]
            emit KNOWN_FANIN_COUNT $group $cell $fc 32
            require [expr {$fc <= 32}] "known fanin actual=$fc cap=32"
            set fn [names $fanin node]
            emit KNOWN_FANIN $group $clock_pin $fn
            require [expr {$fc == 1 && $fn eq [list $K]}] "known reverse clock changed {$cell}"
            set mp [member $pin_set $cell];set mk [member $keeper_set $cell]
            emit KNOWN_RECEIVER $group $cell pin $mp keeper $mk clocks [clock_names $receiver]
            if {$mp ne "1"} {lappend missing_pin $cell}
            if {$mk ne "1"} {lappend missing_keeper $cell}
        }
        require [expr {[llength [lsort -unique $all_known]] == 32}] "duplicate known receiver"
        for {set i 0} {$i < 4} {incr i} {
            lassign [lindex $groups $i] fifo chain
            set current [get_keepers -nowarn [list "$P|$fifo|auto_generated|$chain|dffpipe*|dffe*"]]
            set count [get_collection_size $current]
            emit KNOWN_GROUP_COUNT $i $count expected 8
            require [expr {$count == 8 && [dict get $counts $i] == 8}] "known group cardinality $i actual=$count expected=8"
            set expected {}
            foreach entry $::ia840f_known_receivers {if {[lindex $entry 0] == $i} {lappend expected [lindex $entry 1]}}
            set actual [names $current node]
            emit KNOWN_GROUP $i $actual
            require [expr {$actual eq [lsort $expected]}] "known group identity changed $i"
        }
        set T "$H|gen_ptile.u_ptile|intel_pcie_ptile_ast_qhip|inst|inst|maib_and_tile|avmm2_3~maib_ss_lib/x0/u5_2/pld_avmm2_clk_rowclk.reg"
        set tile [exact get_keepers $T named_tile]
        set mp [member $pin_set $T];set mk [member $keeper_set $T]
        emit NAMED_TILE_LOAD $T pin $mp keeper $mk clocks [clock_names $tile]
        if {$mp ne "1"} {lappend missing_pin $T}
        if {$mk ne "1"} {lappend missing_keeper $T}
        emit MISSING_KNOWN pin $missing_pin keeper $missing_keeper
        set pin_supported [expr {$complete && $pin_count > 0 && [llength $missing_pin] == 0}]
        set keeper_supported [expr {$complete && $keeper_count > 0 && [llength $missing_keeper] == 0}]
        emit DIAGNOSTIC_STATUS complete $complete pin_supported_by_known $pin_supported keeper_supported_by_known $keeper_supported no_collector_acceptance no_comparison_acceptance
        require $complete "fanout enumeration incomplete pin=$pin_count keeper=$keeper_count cap=$cap"
        emit COMPLETE diagnostic_only no_clock_created no_timing_acceptance
        close $audit
        delete_timing_netlist
        project_close
        puts "IA840F_FANOUT_DIAGNOSTIC_COMPLETE"
    }
}
::ia840f_fanout_diagnostic::main

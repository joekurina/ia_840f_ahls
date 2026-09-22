# Unchanged-SDC representation/edge-filter contrast. No clock creation or fit.
load_package sta
load_package report
source [file join [file dirname [info script]] clock-repair.tcl]
source [file join [file dirname [info script]] known-receivers.tcl]
namespace eval ::ia840f_fanout_contrast {
    variable E /home/uwb_student00/ahls/new_BSP/qualification/pcie-clock-repair-01/fanout-diagnostic03
    variable audit
    variable complete 1
    variable mapping_supported 1
    variable cap 4096
    proc emit {args} {variable audit; puts $audit $args; flush $audit}
    proc require {value why} {::ia840f_clock_repair::require $value $why}
    proc problem {args} {variable complete; set complete 0; emit INCOMPLETE {*}$args}
    proc literal {name} {
        require [expr {[string first [format %c 92] $name] < 0}] "unsupported backslash in exact name"
        return [string map [list {[} {[[]} {*} {[*]} {?} {[?]}] $name]
    }
    proc object_name {object kind} {
        if {$kind eq "cell"} {return [get_cell_info -name $object]}
        if {$kind eq "clock"} {return [get_clock_info -name $object]}
        if {$kind eq "pin"} {return [get_pin_info -name $object]}
        return [get_node_info -name $object]
    }
    # Enumeration uses actual collection handles; individual object IDs stay IDs.
    proc observe {label collection limit {kind node}} {
        set count [get_collection_size $collection]
        emit COUNT $label $count cap $limit
        if {$count > $limit} {
            problem $label cap_exceeded $count $limit
            return [dict create complete 0 count $count names {}]
        }
        set raw {}
        foreach_in_collection object $collection {lappend raw [object_name $object $kind]}
        emit SET $label $raw
        if {[llength $raw] != $count || [llength [lsort -unique $raw]] != $count} {
            problem $label enumeration_or_duplicates
            return [dict create complete 0 count $count names $raw]
        }
        return [dict create complete 1 count $count names $raw]
    }
    proc clock_names {collection} {
        return [dict get [observe clocks [get_clocks -nowarn -of_objects $collection] 256 clock] names]
    }
    proc root {command name label} {
        set collection [$command -nowarn [list $name]]
        set info [observe $label $collection 32]
        require [expr {[dict get $info complete] && [dict get $info count] == 1 && [dict get $info names] eq [list $name]}] "root identity {$label}"
        return $collection
    }
    proc membership {info name} {
        if {![dict get $info complete]} {return unavailable}
        return [expr {[lsearch -exact [dict get $info names] $name] >= 0}]
    }
    proc memberships {sets name} {
        set result {}
        dict for {label info} $sets {lappend result $label [membership $info $name]}
        return $result
    }
    proc inventory {} {
        set clocks [get_clocks *]
        set n [get_collection_size $clocks]
        emit CLOCK_COUNT $n 256
        require [expr {$n <= 256}] "clock inventory actual=$n cap=256"
        foreach_in_collection clock $clocks {
            set type [get_clock_info -type $clock];set extra not_applicable
            if {$type in {generated virtual_generated}} {
                set extra [list generated_properties [get_clock_info -master_clock $clock] [get_clock_info -master_clock_pin $clock] [get_clock_info -divide_by $clock] [get_clock_info -multiply_by $clock]]
            } else {require [expr {$type in {base virtual_base}}] "unknown clock type {$type}"}
            emit CLOCK [get_clock_info -name $clock] $type [get_clock_info -period $clock] [get_clock_info -waveform $clock] [::ia840f_clock_repair::names [get_clock_info -targets $clock] node] $extra
        }
    }
    proc main {} {
        variable E; variable audit; variable complete; variable mapping_supported; variable cap
        require [expr {[pwd] eq "$E/scratch/syn/board/ia840f/syn_top"}] "unexpected project path"
        set reports "$E/reports"
        require [expr {![file exists $reports]}] "spent reports directory"
        file mkdir $reports
        set audit [open "$reports/audit.tcllist" {WRONLY CREAT EXCL}]
        emit BEGIN diagnostic_only unchanged_sdc no_fit no_hardware no_timing_acceptance
        project_open -revision ofs_top ofs_top
        if {[info exists ::ia840f_gate_result]} {error SOURCE_BOUND_GATE_REJECTION_STOP}
        create_timing_netlist
        read_sdc
        update_timing_netlist
        set D $::ia840f_clock_repair::D;set H $::ia840f_clock_repair::H
        set C $::ia840f_clock_repair::C;set K "${D}~div_reg"
        set nc [get_collection_size [get_clocks -nowarn [list $C]]]
        emit BASELINE_GENERATED_NAME_COUNT $C $nc
        require [expr {!$::ia840f_clock_repair::created && $nc == 0}] "baseline clock changed"
        inventory
        set output [::ia840f_clock_repair::one_pin "$D|clock_div2" 0]
        set keeper [root get_keepers $K keeper_root]
        set register [root get_registers $K register_root]
        emit ROOT pin "$D|clock_div2" driving_clocks [clock_names $output]
        emit ROOT keeper $K driving_clocks [clock_names $keeper]
        # Four predeclared queries; no fallback/root change and no early zero assertion.
        set collections [dict create]
        dict set collections pin_clock [get_fanouts -clock $output]
        emit FANOUT_COUNT pin_clock [get_collection_size [dict get $collections pin_clock]] cap $cap
        dict set collections pin_all [get_fanouts $output]
        emit FANOUT_COUNT pin_all [get_collection_size [dict get $collections pin_all]] cap $cap
        dict set collections keeper_clock [get_fanouts -clock $keeper]
        emit FANOUT_COUNT keeper_clock [get_collection_size [dict get $collections keeper_clock]] cap $cap
        dict set collections keeper_all [get_fanouts $keeper]
        emit FANOUT_COUNT keeper_all [get_collection_size [dict get $collections keeper_all]] cap $cap
        set sets [dict create]
        dict for {label collection} $collections {dict set sets $label [observe "forward:$label" $collection $cap]}
        foreach {a b} {pin_clock pin_all keeper_clock keeper_all pin_all keeper_all} {
            set ai [dict get $sets $a];set bi [dict get $sets $b]
            if {[dict get $ai complete] && [dict get $bi complete]} {
                set ao {};set bo {};set common {}
                foreach n [dict get $ai names] {if {[membership $bi $n]} {lappend common $n} else {lappend ao $n}}
                foreach n [dict get $bi names] {if {![membership $ai $n]} {lappend bo $n}}
                emit RELATION $a $b a_only $ao b_only $bo intersection $common
            } else {emit RELATION $a $b unavailable}
        }
        # Named tile and selector matrix precede any receiver-identity decisions.
        set T "$H|gen_ptile.u_ptile|intel_pcie_ptile_ast_qhip|inst|inst|maib_and_tile|avmm2_3~maib_ss_lib/x0/u5_2/pld_avmm2_clk_rowclk.reg"
        set tile [get_keepers -nowarn [list $T]]
        set ti [observe named_tile $tile 32]
        if {[dict get $ti complete] && [dict get $ti count] == 1 && [dict get $ti names] eq [list $T]} {
            emit TILE $T memberships [memberships $sets $T] driving_clocks [clock_names $tile]
        } else {problem named_tile_identity}
        emit KNOWN_MANIFEST_COUNT [llength $::ia840f_known_receivers] 32
        require [expr {[llength $::ia840f_known_receivers] == 32}] "known manifest cardinality"
        set first [lindex [lindex $::ia840f_known_receivers 0] 1]
        foreach command {get_cells get_keepers get_registers} {
            foreach mode {raw transformed} {
                set pattern $first
                if {$mode eq "transformed"} {set pattern [literal $first]}
                emit LOOKUP_INPUT $command $mode $pattern
                set kind node;if {$command eq "get_cells"} {set kind cell}
                observe "lookup:$command:$mode" [$command -nowarn [list $pattern]] 32 $kind
            }
        }
        set P "$H|EP_PFTILE_WRAPPER.gen_pciess.u_pciess_p0|u_pciess|gen_sub.u_hipif"
        set groups [list [list u_pciess_cplto_if|cplto_fifo_avmm_inst rs_dgwp] [list u_pciess_cplto_if|cplto_fifo_lite_inst ws_dgrp] [list EP_CFG_IF.u_pciess_cfg_if|u_axi_lite_clk_to_user_avmm_clk_fifo rs_dgwp] [list EP_CFG_IF.u_pciess_cfg_if|u_user_avmm_clk_to_axi_lite_clk_fifo ws_dgrp]]
        set visited {}
        for {set group 0} {$group < 4} {incr group} {
            lassign [lindex $groups $group] fifo chain
            set expected {};set pinmap [dict create]
            foreach row $::ia840f_known_receivers {
                lassign $row g cell pin
                if {$g == $group} {lappend expected $cell;dict set pinmap $cell $pin}
            }
            require [expr {[llength $expected] == 8 && [dict size $pinmap] == 8}] "known group manifest identity"
            set cells [get_cells -nowarn [list "$P|$fifo|auto_generated|$chain|dffpipe*|dffe*"]]
            set ci [observe "physical_group:$group" $cells 128 cell]
            if {![dict get $ci complete] || [lsort [dict get $ci names]] ne [lsort $expected]} {
                problem physical_group_identity $group
                continue
            }
            foreach_in_collection cell $cells {
                set name [get_cell_info -name $cell];lappend visited $name
                set type [get_cell_info -wysiwyg_type $cell]
                emit CELL $group $name $type
                if {$type ne "tennm_ff"} {problem physical_cell_type $name;continue}
                set ia840f_fc_cell_pin_collection [get_cell_info -pins $cell]
                set pi [observe "pins:$name" $ia840f_fc_cell_pin_collection 32 pin]
                if {![dict get $pi complete]} {continue}
                set inputs {}
                foreach_in_collection pin $ia840f_fc_cell_pin_collection {
                    if {[get_pin_info -is_in_pin $pin] && [get_pin_info -is_clock_pin $pin]} {
                        set pn [get_pin_info -name $pin];lappend inputs $pn
                        # Same single-pin-ID get_fanins call already exercised in Q2.
                        set fi [observe "reverse:$pn" [get_fanins -clock -stop_at_clocks $pin] 32]
                        emit CLOCK_INPUT $group $name $pn reverse [dict get $fi names]
                        if {![dict get $fi complete] || [dict get $fi names] ne [list $K]} {problem reverse_clock_identity $pn}
                    }
                }
                emit CLOCK_INPUT_COUNT $name [llength $inputs] expected 1
                if {$inputs ne [list [dict get $pinmap $name]]} {problem clock_pin_identity $name}
                set buried [get_cell_info -buried_regs $cell]
                set bi [observe "buried:$name" $buried 32]
                if {![dict get $bi complete]} {set mapping_supported 0;continue}
                if {[dict get $bi count] != 1} {set mapping_supported 0}
                set clocks unavailable
                if {[dict get $bi count] > 0} {set clocks [clock_names $buried]}
                emit CELL_REGISTER_MAP $group $name registers [dict get $bi names] driving_clocks $clocks
                foreach_in_collection reg $buried {
                    set rn [get_register_info -name $reg]
                    emit REGISTER $name $rn type [get_register_info -type $reg] memberships [memberships $sets $rn]
                }
            }
        }
        emit VISITED_COUNT [llength $visited] unique [llength [lsort -unique $visited]] expected 32
        if {[llength $visited] != 32 || [llength [lsort -unique $visited]] != 32} {problem visited_identity}
        emit DIAGNOSTIC_STATUS complete $complete mapping_single_register_each $mapping_supported no_collector_acceptance no_comparison_acceptance
        require $complete "contrast observation incomplete; inspect retained counts and records"
        emit COMPLETE diagnostic_only no_clock_created no_timing_acceptance
        close $audit
        delete_timing_netlist
        project_close
        puts IA840F_FANOUT_CONTRAST_COMPLETE
    }
}
::ia840f_fanout_contrast::main

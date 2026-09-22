# Definitions-only known32/T stage. Uses scope-collections.tcl emit/observe.
# Cell-derived collections follow accepted diagnostic03, without raw-name
# keeper reconstruction or a claim that every conservative node is a clock load.
namespace eval ::ia840f_compare04 {
    proc capture_receivers {ia4m_variant ia4m_H ia4m_D ia4m_C ia4m_conservative ia4m_rows} {
        require [expr {$ia4m_variant in {baseline candidate}}] "unknown receiver variant"
        emit KNOWN_MANIFEST_COUNT [llength $ia4m_rows] expected 32
        require [expr {[llength $ia4m_rows] == 32}] "known manifest cardinality"
        set ia4m_P "$ia4m_H|EP_PFTILE_WRAPPER.gen_pciess.u_pciess_p0|u_pciess|gen_sub.u_hipif"
        set ia4m_K "${ia4m_D}~div_reg"
        set ia4m_O "$ia4m_D|clock_div2"
        set ia4m_groups [list [list u_pciess_cplto_if|cplto_fifo_avmm_inst rs_dgwp] [list u_pciess_cplto_if|cplto_fifo_lite_inst ws_dgrp] [list EP_CFG_IF.u_pciess_cfg_if|u_axi_lite_clk_to_user_avmm_clk_fifo rs_dgwp] [list EP_CFG_IF.u_pciess_cfg_if|u_user_avmm_clk_to_axi_lite_clk_fifo ws_dgrp]]
        set ia4m_want_clocks {}
        if {$ia4m_variant eq "candidate"} {set ia4m_want_clocks [list $ia4m_C]}
        set ia4m_mapping [dict create];set ia4m_visited {};set ia4m_group_counts {}
        for {set ia4m_group 0} {$ia4m_group < 4} {incr ia4m_group} {
            lassign [lindex $ia4m_groups $ia4m_group] ia4m_fifo ia4m_chain
            set ia4m_expected {};set ia4m_pinmap [dict create]
            foreach ia4m_row $ia4m_rows {
                require [expr {[llength $ia4m_row] == 3}] "known manifest row width"
                lassign $ia4m_row ia4m_g ia4m_cn ia4m_pn
                require [expr {[string is integer -strict $ia4m_g] && $ia4m_g >= 0 && $ia4m_g < 4}] "known manifest group"
                if {$ia4m_g == $ia4m_group} {lappend ia4m_expected $ia4m_cn;dict set ia4m_pinmap $ia4m_cn $ia4m_pn}
            }
            emit KNOWN_GROUP_COUNT $ia4m_group [llength $ia4m_expected] unique [dict size $ia4m_pinmap] expected 8
            require [expr {[llength $ia4m_expected] == 8 && [dict size $ia4m_pinmap] == 8}] "known group manifest identity"
            set ia4m_cells [get_cells -nowarn [list "$ia4m_P|$ia4m_fifo|auto_generated|$ia4m_chain|dffpipe*|dffe*"]]
            set ia4m_cell_names [observe "physical_group:$ia4m_group" $ia4m_cells 128 cell]
            require [expr {$ia4m_cell_names eq [lsort $ia4m_expected]}] "physical group identity {$ia4m_group}"
            lappend ia4m_group_counts [llength $ia4m_cell_names]
            foreach_in_collection ia4m_cell $ia4m_cells {
                set ia4m_name [get_cell_info -name $ia4m_cell]
                lappend ia4m_visited $ia4m_name
                set ia4m_type [get_cell_info -wysiwyg_type $ia4m_cell]
                emit CELL $ia4m_group $ia4m_name $ia4m_type
                require [expr {$ia4m_type eq "tennm_ff"}] "physical receiver type {$ia4m_name}"
                set ia4m_pin_collection [get_cell_info -pins $ia4m_cell]
                observe "pins:$ia4m_name" $ia4m_pin_collection 32 pin
                set ia4m_inputs {};set ia4m_reverse {}
                foreach_in_collection ia4m_pin $ia4m_pin_collection {
                    if {[get_pin_info -is_in_pin $ia4m_pin] && [get_pin_info -is_clock_pin $ia4m_pin]} {
                        set ia4m_pn [get_pin_info -name $ia4m_pin]
                        lappend ia4m_inputs $ia4m_pn
                        # Individual pin ID here, as exercised natively in Q2/H;
                        # it is never fed to foreach_in_collection.
                        set ia4m_reverse [observe "reverse:$ia4m_pn" [get_fanins -clock -stop_at_clocks $ia4m_pin] 32]
                        emit CLOCK_INPUT $ia4m_group $ia4m_name $ia4m_pn reverse $ia4m_reverse
                        if {$ia4m_variant eq "baseline"} {
                            require [expr {$ia4m_reverse eq [list $ia4m_K]}] "baseline reverse clock identity {$ia4m_pn}"
                        } else {
                            # -stop_at_clocks may stop at newly defined O instead
                            # of the prior keeper K; no other root is acceptable.
                            require [expr {$ia4m_reverse eq [list $ia4m_K] || $ia4m_reverse eq [list $ia4m_O]}] "candidate reverse clock identity {$ia4m_pn}"
                        }
                    }
                }
                emit CLOCK_INPUT_COUNT $ia4m_name [llength $ia4m_inputs] expected 1
                require [expr {$ia4m_inputs eq [list [dict get $ia4m_pinmap $ia4m_name]]}] "clock pin identity {$ia4m_name}"
                set ia4m_buried [get_cell_info -buried_regs $ia4m_cell]
                set ia4m_reg_names [observe "buried:$ia4m_name" $ia4m_buried 32]
                require [expr {$ia4m_reg_names eq [list $ia4m_name]}] "cell-derived singleton register identity {$ia4m_name}"
                foreach_in_collection ia4m_reg $ia4m_buried {
                    require [expr {[get_register_info -name $ia4m_reg] eq $ia4m_name && [get_register_info -type $ia4m_reg] eq "reg"}] "receiver timing object type/name {$ia4m_name}"
                }
                require [expr {[lsearch -exact $ia4m_conservative $ia4m_name] >= 0}] "known receiver missing from conservative union {$ia4m_name}"
                set ia4m_clocks [observe "receiver_clocks:$ia4m_name" [get_clocks -nowarn -of_objects $ia4m_buried] 256 clock]
                emit CELL_REGISTER_MAP $ia4m_group $ia4m_name registers $ia4m_reg_names driving_clocks $ia4m_clocks
                require [expr {$ia4m_clocks eq $ia4m_want_clocks}] "unexpected known receiver association {$ia4m_name} clocks={$ia4m_clocks}"
                dict set ia4m_mapping $ia4m_name [dict create group $ia4m_group clock_pin [lindex $ia4m_inputs 0] reverse $ia4m_reverse clocks $ia4m_clocks collection $ia4m_buried]
            }
        }
        emit VISITED_COUNT [llength $ia4m_visited] unique [llength [lsort -unique $ia4m_visited]] expected 32
        require [expr {[llength $ia4m_visited] == 32 && [llength [lsort -unique $ia4m_visited]] == 32}] "visited receiver identity"
        set ia4m_T "$ia4m_H|gen_ptile.u_ptile|intel_pcie_ptile_ast_qhip|inst|inst|maib_and_tile|avmm2_3~maib_ss_lib/x0/u5_2/pld_avmm2_clk_rowclk.reg"
        set ia4m_tile [exact_root get_keepers $ia4m_T node named_tile]
        require [expr {[lsearch -exact $ia4m_conservative $ia4m_T] >= 0}] "named tile missing from conservative union"
        set ia4m_tile_clocks [observe tile_clocks [get_clocks -nowarn -of_objects $ia4m_tile] 256 clock]
        emit TILE $ia4m_T driving_clocks $ia4m_tile_clocks
        require [expr {$ia4m_tile_clocks eq $ia4m_want_clocks}] "unexpected named tile association"
        emit RECEIVERS_COMPLETE $ia4m_variant [dict size $ia4m_mapping] no_domain_or_timing_acceptance
        return [dict create receivers $ia4m_mapping group_counts $ia4m_group_counts tile [dict create name $ia4m_T clocks $ia4m_tile_clocks collection $ia4m_tile]]
    }
}

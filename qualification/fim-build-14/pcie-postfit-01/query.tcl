# Read-only fitted-netlist query. All temporaries are procedure-local.
# API forms: captured Quartus 26.1.1 api-help2.log from query01.
load_package sta
project_open -revision ofs_top ofs_top
if {[info exists ia840f_gate_result]} {error "SOURCE_BOUND_GATE_REJECTION_STOP"}
create_timing_netlist
read_sdc
update_timing_netlist
namespace eval ::ia840f_w14_query {
    proc targets {nodes label} {
        set names {}
        foreach_in_collection n $nodes {lappend names [get_node_info -name $n]}
        set count 0
        foreach_in_collection c [get_clocks *] {
            foreach_in_collection t [get_clock_info -targets $c] {
                if {[lsearch -exact $names [get_node_info -name $t]] >= 0} {
                    incr count
                    puts "$label CLOCK {[get_clock_info -name $c]} PERIOD [get_clock_info -period $c] MASTER {[get_clock_info -master_clock $c]} SOURCE {[get_clock_info -master_clock_pin $c]}"
                    break
                }
            }
        }
        puts "$label CLOCK_TARGET_COUNT $count"
    }
    proc clock_fanins {pin label} {
        set ns [get_fanins -clock -stop_at_clocks $pin]
        set count 0
        foreach_in_collection n $ns {
            incr count
            if {$count > 32} {error "FANIN_OUTPUT_BOUND_EXCEEDED"}
            puts "$label FANIN {[get_node_info -name $n]}"
        }
        puts "$label FANIN_COUNT $count"
        targets $ns $label
    }
    proc inspect_cell {cell label all_pins} {
        puts "$label CELL {[get_cell_info -name $cell]} TYPE {[get_cell_info -wysiwyg_type $cell]}"
        set pin_collection [get_cell_info -pins $cell]
        set clock_inputs 0
        foreach_in_collection p $pin_collection {
            set input [get_pin_info -is_in_pin $p]
            set clock [get_pin_info -is_clock_pin $p]
            if {$all_pins || ($input && $clock)} {
                set pn [get_pin_info -name $p]
                puts "$label PIN {$pn} INPUT $input OUTPUT [get_pin_info -is_out_pin $p] CLOCK_PIN $clock NET_ID {[get_pin_info -net $p]}"
                if {[get_pin_info -is_out_pin $p]} {targets $p "$label OUTPUT {$pn}"}
                if {$input && $clock} {
                    incr clock_inputs
                    clock_fanins $p "$label INPUT {$pn}"
                }
            }
        }
        puts "$label CLOCK_INPUT_COUNT $clock_inputs"
    }
    proc main {} {
        set H {pcie_wrapper|pcie_ss.top|host_pcie.pcie_ss|pcie_ss}
        set P "$H|EP_PFTILE_WRAPPER.gen_pciess.u_pciess_p0|u_pciess|gen_sub.u_hipif"
        set D "$P|u_pciess_clock_divider"
        foreach suffix {inclk clock_div2 clock_div2x} {
            set ps [get_pins -nowarn "$D|clkdiv_inst|$suffix"]
            puts "EXACT_DIVIDER_SELECTOR {$D|clkdiv_inst|$suffix} COUNT [get_collection_size $ps]"
            foreach_in_collection p $ps {puts "EXACT_DIVIDER_PIN {[get_pin_info -name $p]}"}
        }
        set ports [get_ports -nowarn *axi_lite_clk*]
        puts "TOP_AXI_LITE_PORT_COUNT [get_collection_size $ports]; top_context_not_entity_scope"
        foreach_in_collection c [get_clocks *] {
            set n [get_clock_info -name $c]
            if {[regexp {100m|avmm|axi_lite|rx_ch15} $n]} {
                puts "RELEVANT_CLOCK {$n} PERIOD [get_clock_info -period $c] MASTER {[get_clock_info -master_clock $c]}"
            }
        }
        set groups [list \
            [list "$P|u_pciess_cplto_if|cplto_fifo_avmm_inst|" {rs_dgwp|dffpipe}] \
            [list "$P|u_pciess_cplto_if|cplto_fifo_lite_inst|" {ws_dgrp|dffpipe}] \
            [list "$P|EP_CFG_IF.u_pciess_cfg_if|u_axi_lite_clk_to_user_avmm_clk_fifo|" {rs_dgwp|dffpipe}] \
            [list "$P|EP_CFG_IF.u_pciess_cfg_if|u_user_avmm_clk_to_axi_lite_clk_fifo|" {ws_dgrp|dffpipe}]]
        set counts [dict create 0 0 1 0 2 0 3 0]
        set dividers 0
        foreach_in_collection c [get_cells -hierarchical *] {
            set n [get_cell_info -name $c]
            if {$n eq "$D|clkdiv_inst"} {
                incr dividers
                inspect_cell $c DIVIDER 1
            }
            set i 0
            foreach group $groups {
                lassign $group prefix chain
                if {[string first $prefix $n] == 0 && [string first $chain $n] >= 0 && [string first {dffe} $n] >= 0} {
                    dict incr counts $i
                    if {[dict get $counts $i] > 128} {error "FIFO_OUTPUT_BOUND_EXCEEDED $i"}
                    inspect_cell $c "FIFO_GROUP_$i" 0
                }
                incr i
            }
        }
        puts "DIVIDER_CELL_COUNT $dividers"
        dict for {i count} $counts {puts "FIFO_GROUP_$i CELL_COUNT $count"}
        puts "QUERY_INVENTORY_END; read_only; no_clock_or_exception_created; no_timing_acceptance"
        if {$dividers != 1} {error "DIVIDER_CARDINALITY_NOT_ONE"}
        dict for {i count} $counts {if {$count == 0} {error "FIFO_GROUP_NOT_RESOLVED $i"}}
    }
}
::ia840f_w14_query::main
delete_timing_netlist
project_close
puts "W14_POSTFIT_QUERY_COMPLETE"

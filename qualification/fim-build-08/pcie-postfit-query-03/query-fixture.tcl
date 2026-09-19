
proc load_package args {}
proc project_open args {}
proc create_timing_netlist args {}
proc read_sdc args {}
proc update_timing_netlist args {}
proc delete_timing_netlist args {}
proc project_close args {}
proc foreach_in_collection {var coll body} {uplevel 1 [list foreach $var $coll $body]}
proc get_cells args {return {d osc}}
proc get_cell_info {opt c} {
 if {$opt eq "-name"} {if {$c eq "d"} {return {x|u_pciess_clock_divider|clkdiv_inst~div_reg}};return {altera_int_osc_clk}}
 if {$opt eq "-wysiwyg_type"} {if {$c eq "d"} {return clock_div2x};return intosc}
 if {$opt eq "-pins"} {return {in out}}
 error "unknown cell option $opt"
}
proc get_pin_info {opt p} {
 switch -- $opt {-name {return $p} -is_in_pin {expr {$p eq "in"}} -is_out_pin {expr {$p eq "out"}} -is_clock_pin {expr {$p eq "in"}} default {error $opt}}
}
proc get_clocks args {return csr}
proc get_node_info {opt n} {return $n}
proc get_fanins args {return csr_pll_pin}
proc get_clock_info {opt c} {
 switch -- $opt {-targets {return csr_pll_pin} -name {return csr_100m} -period {return 9.92950054612253} -master_clock {return csr_ref} -master_clock_pin {return refclk} default {error $opt}}
}

source /home/joe/Projects/Thesis/AHLS/new_bsp/new/qualification/fim-build-08/pcie-postfit-query-03/query.tcl

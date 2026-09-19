load_package sta
project_open -revision ofs_top ofs_top
if {[info exists ia840f_gate_result]} {error "SOURCE_BOUND_GATE_REJECTION_STOP"}
create_timing_netlist
read_sdc
update_timing_netlist
# Existing installed 26.1.1 help: api-help2.log, get_cell_info/get_pin_info/get_fanins.
# No supported fitted-mode accessor in this STA API; atoms help explicitly failed.
puts "DIVIDER_FITTED_MODE UNAVAILABLE_STA_API; vendor_SDC_divide_by_2_is_separate_evidence"
set clocks [get_clocks *]
proc clock_targets {nodes label} {
 global clocks
 set names {}
 foreach_in_collection node $nodes {lappend names [get_node_info -name $node]}
 set count 0
 set periods {}
 foreach_in_collection c $clocks {
  foreach_in_collection target [get_clock_info -targets $c] {
   if {[lsearch -exact $names [get_node_info -name $target]] >= 0} {
    incr count
    set n [get_clock_info -name $c]
    set p [get_clock_info -period $c]
    puts "$label CLOCK $n PERIOD $p MASTER [get_clock_info -master_clock $c] MASTER_PIN [get_clock_info -master_clock_pin $c]"
    lappend periods [list $n $p]
    break
   }
  }
 }
 puts "$label CLOCK_COUNT $count"
 return $periods
}
set trs_exact_resource 0; set trs_hier_resource 0; set osc_type_count 0
set divider_count 0
array set aliases {clock_div2 0 clock_div2x 0 ~div_reg 0}
foreach_in_collection c [get_cells -hierarchical *] {
 set n [get_cell_info -name $c];set type [get_cell_info -wysiwyg_type $c]
 if {$n eq "ALTERA_INSERTED_INTOSC_FOR_TRS|divided_osc_clk"} {incr trs_exact_resource}
 if {[regexp {(^|\|)ALTERA_INSERTED_INTOSC_FOR_TRS(\||$)} $n]} {incr trs_hier_resource;puts "TRS_RESOURCE $n TYPE $type"}
 if {[regexp -nocase {osc} $type]} {incr osc_type_count;puts "OSCILLATOR_TYPE_RESOURCE $n TYPE $type"}
 if {[regexp -nocase {osc|TRS} $n]} {puts "OSCILLATOR_NAME_RESOURCE $n TYPE $type"}
 if {[string first "u_pciess_clock_divider|clkdiv_inst" $n]<0} {continue}
 incr divider_count
 puts "DIVIDER CELL $n TYPE $type"
 foreach alias {clock_div2 clock_div2x ~div_reg} {if {$type eq $alias || [string match "*|$alias" $n] || ($alias eq "~div_reg" && [string match "*~div_reg" $n])} {incr aliases($alias);puts "ALIAS $alias CELL $n TYPE $type"}}
 set pins [get_cell_info -pins $c];set pincount 0
 foreach_in_collection pin $pins {
  incr pincount
  set pn [get_pin_info -name $pin]
  set input [get_pin_info -is_in_pin $pin];set output [get_pin_info -is_out_pin $pin]
  puts "DIVIDER_PIN $pn INPUT $input OUTPUT $output CLOCK_PIN [get_pin_info -is_clock_pin $pin]"
  if {$output} {clock_targets $pin "OUTPUT $pn"}
  if {$input && [get_pin_info -is_clock_pin $pin]} {
   # Traverse combinational routing/mux edges, stopping at actual clock targets.
   set fanins [get_fanins -clock -stop_at_clocks $pin];set fc 0;set pll 0
   foreach_in_collection src $fanins {
    incr fc
    set sn [get_node_info -name $src]
    puts "INPUT_FANIN $pn SOURCE $sn"
    if {[regexp -nocase {pll} $sn]} {incr pll;puts "DRIVING_PLL_PIN $sn"}
   }
   puts "INPUT_FANIN_COUNT $pn $fc PLL_COUNT $pll"
   set periods [clock_targets $fanins "INPUT $pn"]
   if {$pll!=1 || [llength $periods]!=1} {error "DIVIDER_INPUT_AMBIGUOUS_OR_UNAVAILABLE"}
   lassign [lindex $periods 0] master period
   if {![regexp -nocase {100m|avmm|csr} $master]} {error "DIVIDER_INPUT_NOT_EXPECTED_CSR $master"}
   puts "PROPOSED_ONLY MASTER $master INPUT_PERIOD $period OUTPUT_PERIOD [expr {2.0*$period}] OUTPUT_MHZ [expr {500.0/$period}]"
  }
 }
 puts "DIVIDER_PIN_COUNT $n $pincount"
}
puts "DIVIDER_CELL_COUNT $divider_count"
foreach alias {clock_div2 clock_div2x ~div_reg} {puts "ALIAS_COUNT $alias $aliases($alias) ZERO_MEANS_UNAVAILABLE; correspondence_not_inferred_from_spelling"}
set trs_exact_clock 0;set trs_hier_clock 0
foreach_in_collection c $clocks {
 set n [get_clock_info -name $c]
 if {$n eq "ALTERA_INSERTED_INTOSC_FOR_TRS|divided_osc_clk"} {incr trs_exact_clock}
 if {[regexp {(^|\|)ALTERA_INSERTED_INTOSC_FOR_TRS(\||$)} $n]} {incr trs_hier_clock;puts "TRS_CLOCK $n"}
 if {[regexp -nocase {100m|avmm|osc|TRS} $n]} {puts "CLOCK $n PERIOD [get_clock_info -period $c] MASTER [get_clock_info -master_clock $c]"}
}
puts "TRS_COUNTS EXACT_RESOURCE $trs_exact_resource HIER_RESOURCE $trs_hier_resource EXACT_CLOCK $trs_exact_clock HIER_CLOCK $trs_hier_clock OSCILLATOR_TYPES $osc_type_count"
puts "TRS_INVENTORY_END SUCCESS; altera_int_osc_clk_is_not_TRS_by_name; absence_bounded_to_loaded_fitted_netlist"
delete_timing_netlist
project_close

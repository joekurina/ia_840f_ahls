load_package project
project_open capability
set n TDC_AGGRESSIVE_HOLD_CLOSURE_EFFORT
foreach_in_collection a [get_all_assignments -type default -name $n] {puts "DEFAULT [get_assignment_info $a -name]=[get_assignment_info $a -value]"}
puts "GLOBAL-ALL ROUTER_PRESENT=[expr {[lsearch -exact [get_all_assignment_names] ROUTER_LCELL_INSERTION_AND_LOGIC_DUPLICATION]>=0}]"
puts "GLOBAL-AGILEX7 ROUTER_PRESENT=[expr {[lsearch -exact [get_all_assignment_names -family {Agilex 7} -type global] ROUTER_LCELL_INSERTION_AND_LOGIC_DUPLICATION]>=0}]"
set_global_assignment -name TDC_AGGRESSIVE_HOLD_CLOSURE_EFFORT ON
project_close
project_open capability
puts "READBACK TDC_AGGRESSIVE_HOLD_CLOSURE_EFFORT=[get_global_assignment -name TDC_AGGRESSIVE_HOLD_CLOSURE_EFFORT]"
project_close

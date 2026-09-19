load_package project
load_package device
puts "PART_FAMILY=[get_part_info -family AGFB027R25A2E2V]"
project_new -family "Agilex 7" -part AGFB027R25A2E2V capability
puts "FAMILY=[get_global_assignment -name FAMILY] DEVICE=[get_global_assignment -name DEVICE]"
set allnames [get_all_assignment_names -family "Agilex 7"]
set fitnames [get_all_assignment_names -family "Agilex 7" -module fit]
set f [open agilex7-assignment-names.txt w]; puts $f [join $allnames "\n"]; close $f
set f [open agilex7-fit-names.txt w]; puts $f [join $fitnames "\n"]; close $f
foreach n {ROUTER_LCELL_INSERTION_AND_LOGIC_DUPLICATION ROUTER_REGISTER_DUPLICATION POST_ROUTE_PHYSICAL_SYNTHESIS TDC_AGGRESSIVE_HOLD_CLOSURE_EFFORT SEED ROUTER_TIMING_OPTIMIZATION_LEVEL DUPLICATE_ATOM DUPLICATE_REGISTER MAX_FANOUT} {
puts "===NAME $n AGILEX7=[expr {[lsearch -exact $allnames $n]>=0}] FIT=[expr {[lsearch -exact $fitnames $n]>=0}] ==="
puts [get_assignment_name_info $n]
}
puts "===FAMILY LIST===";puts [get_family_list]
project_close

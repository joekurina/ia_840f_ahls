load_package sta
project_open -revision ofs_top ofs_top
# Never continue if Quartus downgrades the source-bound rejection.
if {[info exists ia840f_gate_result]} {error "SOURCE_BOUND_GATE_REJECTION_STOP"}
create_timing_netlist
read_sdc
update_timing_netlist
foreach_in_collection c [get_cells -hierarchical *] {
 set n [get_cell_info -name $c]
 if {[string match *clkdiv_inst* $n] || [regexp -nocase {osc|TRS} $n]} {
 puts "RESOURCE $n TYPE [get_cell_info -wysiwyg_type $c] INPUT [get_cell_info -in_pin_names $c] OUTPUT [get_cell_info -out_pin_names $c]"
 }
}
foreach_in_collection c [get_clocks *] {
 set n [get_clock_info -name $c]
 if {[regexp -nocase {100m|avmm|osc|TRS} $n]} {puts "CLOCK $n PERIOD [get_clock_info -period $c] MASTER [get_clock_info -master_clock $c] DIV [get_clock_info -divide_by $c]"}
}
delete_timing_netlist
project_close

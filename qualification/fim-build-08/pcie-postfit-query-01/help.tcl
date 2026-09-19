foreach cmd {project_open create_timing_netlist read_sdc get_pins get_pin_info get_cell_info get_cells get_clock_info get_fanins read_atom_netlist get_atom_node_info get_atom_nodes} {
 puts "HELP_BEGIN $cmd"
 catch {help -long $cmd} result
 puts $result
}

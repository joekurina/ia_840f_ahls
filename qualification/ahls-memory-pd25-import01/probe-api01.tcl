puts "PD_PACKAGE [package present qsys]"
foreach name {create_system set_project_property add_instance set_instance_parameter_value add_interface set_interface_property add_connection validate_system save_system get_instance_interfaces get_instance_interface_property get_instance_interface_properties get_instance_interface_ports get_instance_port_property get_instance_properties get_instance_property load_component load_instance get_interfaces get_interface_property get_interface_ports get_port_property} {
    puts "PD_API $name [llength [info commands $name]]"
}
puts "PD_API_PROBE_COMPLETE"

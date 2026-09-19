package require -exact qsys 26.1
create_system model_repair
set_project_property DEVICE_FAMILY {Agilex 7}
set_project_property DEVICE AGFB027R25A2E2V
foreach name {ed_sim_mem ed_sim_mem_group1} {
 add_component $name ${name}.ip
 if {![load_component $name]} {error "Cannot load $name"}
 puts "BEFORE $name [get_component_parameter_value SYS_INFO_DEVICE_FAMILY]"
 set_component_parameter_value SYS_INFO_DEVICE_FAMILY {Agilex 7}
 save_component
 puts "AFTER $name [get_component_parameter_value SYS_INFO_DEVICE_FAMILY]"
}
save_system model_repair.qsys

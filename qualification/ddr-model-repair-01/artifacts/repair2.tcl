package require -exact qsys 26.1
load_system model_repair.qsys
foreach name {ed_sim_mem ed_sim_mem_group1} {
 if {![load_component $name]} {error "Cannot load $name"}
 puts "READBACK $name [get_component_parameter_value SYS_INFO_DEVICE_FAMILY]"
 if {[get_component_parameter_value SYS_INFO_DEVICE_FAMILY] ne "Agilex 7"} {error "Bad family"}
 save_component
 reload_component_footprint $name
}
save_system model_repair.qsys

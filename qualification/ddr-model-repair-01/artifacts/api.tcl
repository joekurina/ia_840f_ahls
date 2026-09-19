package require -exact qsys 26.1
foreach c {load_component save_component set_component_parameter_value get_component_parameters get_component_parameter_value} { puts "API $c"; catch {help $c} msg; puts $msg }

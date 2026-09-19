package require -exact qsys 26.1
puts "HELP [info commands *help*]"
foreach c {load_component save_component set_component_parameter_value add_component set_component_project_property} { puts "API $c"; catch {$c} msg; puts $msg }

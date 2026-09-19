load_package project
load_package device
foreach c {get_assignment_name_info get_all_assignment_names test_assignment_trait get_part_info project_new get_global_assignment} {puts "=== $c ==="; puts [help -cmd $c]}

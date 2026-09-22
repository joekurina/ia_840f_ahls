# Finite installed command documentation only: no project or netlist.
load_package sta
load_package report
foreach command {
    read_sdc create_generated_clock get_clocks get_clock_info
    get_registers get_register_info get_keepers get_fanouts get_fanins
    report_clocks report_clock_transfers report_exceptions report_sdc
    report_net_delay report_max_skew report_timing report_ucp
    get_timing_paths get_path_info get_clock_domain_info
    get_available_operating_conditions set_operating_conditions
    report_min_pulse_width report_design_assistant
    get_report_panel_names get_report_panel_id get_number_of_rows
    get_report_panel_row get_report_panel_data
} {
    puts "HELP_BEGIN $command"
    if {[catch {help -cmd $command} answer]} {
        puts "HELP_UNAVAILABLE $command {$answer}"
    } else {
        puts $answer
    }
    puts "HELP_END $command"
}
puts "IA840F_CLOCK_REPAIR_API_HELP01_COMPLETE"

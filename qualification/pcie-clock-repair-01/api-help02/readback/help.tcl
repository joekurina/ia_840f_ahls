# Additional exact collection/constraint-check API help only.
load_package sta
load_package report
foreach command {get_collection index_collection add_to_collection use_timing_analyzer_style_escaping get_pins check_timing report_drc} {
    puts "HELP_BEGIN $command"
    if {[catch {help -cmd $command} answer]} {puts "HELP_UNAVAILABLE $command {$answer}"} else {puts $answer}
    puts "HELP_END $command"
}
puts "IA840F_CLOCK_REPAIR_API_HELP02_COMPLETE"

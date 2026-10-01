# Two command-help requests only: no project, netlist or setters.
puts [list EXECUTABLE [info nameofexecutable]]
load_package sta
foreach cmd {report_delay_calculation report_path} {
    puts [list COMMAND_PRESENT $cmd [llength [info commands $cmd]]]
    set rc [catch {help -cmd $cmd} text]
    if {[string length $text] > 300000} {error command_help_size_cap}
    puts [list COMMAND_HELP $cmd RETURN $rc VALUE $text]
    flush stdout
}
puts IA840F_CPA_HELP35_COMPLETE
flush stdout

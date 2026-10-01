# Two command-help requests only: no project, netlist or setters.
puts [list EXECUTABLE [info nameofexecutable]]
load_package sta
foreach cmd {report_path get_pins get_nodes get_node_info} {
    puts [list COMMAND_PRESENT $cmd [llength [info commands $cmd]]]
    set rc [catch {help -cmd $cmd} text]
    if {[string length $text] > 300000} {error command_help_size_cap}
    puts [list COMMAND_HELP $cmd RETURN $rc VALUE $text]
    flush stdout
}
puts IA840F_CPA_HELP45_COMPLETE
flush stdout

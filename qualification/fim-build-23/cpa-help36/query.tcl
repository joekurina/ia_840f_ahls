# Bounded imported-command discovery and help only; no project/netlist.
puts [list EXECUTABLE [info nameofexecutable]]
load_package sta
set discovered {}
foreach pattern {*cpa* *CPA* *compens* report_clock*} {
    set matches [lsort -unique [info commands $pattern]]
    puts [list COMMAND_DISCOVERY $pattern COUNT [llength $matches] NAMES $matches]
    set discovered [concat $discovered $matches]
}
set discovered [lsort -unique $discovered]
if {[llength $discovered] > 20} {error command_discovery_cap}
foreach cmd $discovered {
    set rc [catch {help -cmd $cmd} text]
    if {[string length $text] > 300000} {error command_help_size_cap}
    puts [list COMMAND_HELP $cmd RETURN $rc VALUE $text]
    flush stdout
}
puts IA840F_CPA_HELP36_COMPLETE
flush stdout

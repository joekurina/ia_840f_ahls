# Parser-only check: never source/evaluate the vendor query.
set fp [open [lindex $argv 0] r]
set text [read $fp]
close $fp
if {![info complete $text]} {error "incomplete Tcl script"}
puts "TCL_PARSE_COMPLETE; query NOT executed; no vendor APIs loaded"

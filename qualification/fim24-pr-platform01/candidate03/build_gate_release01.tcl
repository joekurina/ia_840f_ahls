# Release-only callback in the owned PR-export copy; original gate is retained.
set ia840f_release_gate [file join [file dirname [info script]] ia840f_release_gate01.py]
if {[catch {exec /usr/bin/env -u LD_LIBRARY_PATH -u PYTHONOPTIMIZE /usr/bin/python3 -I -B $ia840f_release_gate quartus 2>@1} ia840f_release_result]} {
    puts stderr "IA840F_GATE_REJECTED: $ia840f_release_result"
    error "PR export invocation rejected: $ia840f_release_result"
}

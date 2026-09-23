# Persona synthesis-only copied-project callback; hardware/build readiness remains false.
set ia840f_ready_for_build false
set ia840f_release_gate [file join [file dirname [info script]] ia840f_persona_gate01.py]
if {[catch {exec /usr/bin/env -u LD_LIBRARY_PATH python3 $ia840f_release_gate quartus 2>@1} ia840f_release_result]} {
    puts stderr "IA840F_GATE_REJECTED: $ia840f_release_result"
    error "Persona synthesis-only invocation rejected: $ia840f_release_result"
}
unset ia840f_release_gate ia840f_release_result

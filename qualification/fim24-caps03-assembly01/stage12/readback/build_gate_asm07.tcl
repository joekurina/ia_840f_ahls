# Copied-project assembly callback registration.
set ia840f_ready_for_build false
set ia840f_persona_gate [file join [file dirname [info script]] ia840f_asm_gate07.py]
if {[catch {exec /usr/bin/env -u LD_LIBRARY_PATH -u PYTHONOPTIMIZE /usr/bin/python3 -I -B $ia840f_persona_gate quartus 2>@1} ia840f_persona_result]} {
    puts stderr "IA840F_ASM_GATE_REJECTED: $ia840f_persona_result"
    error "Persona assembly invocation rejected: $ia840f_persona_result"
}
unset ia840f_persona_gate ia840f_persona_result

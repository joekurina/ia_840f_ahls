# Experimental project management / RTL generation is not build readiness.
# The validator inspects the actual Linux parent executable and argv, not a
# stage environment variable or a mutable Quartus Tcl executable-name label.
set ia840f_ready_for_build false
set ia840f_gate [file normalize [file join [file dirname [info script]] ../../../../ofs-common/tools/ofss_config/ia840f_experimental_gate.py]]
if {[catch {exec python3 $ia840f_gate quartus 2>@1} ia840f_gate_result]} {
    # Quartus may downgrade the error below to warning 125091 and exit 0.
    # Native setup monitors this stable stderr marker and fails before its next
    # stage. This is deliberately not an unverified vendor qexit invocation.
    puts stderr "IA840F_GATE_REJECTED: $ia840f_gate_result"
    error "IA840F NOT READY: $ia840f_gate_result. Child-IP/generated-interface, memory and BMC/FLR qualification remain unperformed."
}
unset ia840f_gate ia840f_gate_result

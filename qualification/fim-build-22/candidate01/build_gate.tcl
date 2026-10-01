# Copied migration-project callback; not hardware/build readiness.
set ia840f_ready_for_build false
set ia840f_migration_gate [file join [file dirname [info script]] ia840f_migration_gate.py]
if {[catch {exec /usr/bin/env -u LD_LIBRARY_PATH python3 $ia840f_migration_gate quartus 2>@1} ia840f_migration_result]} {
    puts stderr "IA840F_GATE_REJECTED: $ia840f_migration_result"
    error "Migration native invocation rejected: $ia840f_migration_result"
}
unset ia840f_migration_gate ia840f_migration_result

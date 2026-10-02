set ::calls {}
proc set_instance_assignment {args} {lappend ::calls $args}

# Work24: documented EMIF1 SCLK selection; retain full PR clock coverage.
set_instance_assignment -name CLOCK_SPINE 2 -to {local_mem_wrapper|mem_ss_top|mem_ss_sv|mem_ss|mem_ss|emif_1|emif_1|arch|arch_inst|io_tiles_wrap_inst|io_tiles_inst|core_clks_from_cpa_pri_nonabphy[0]}
set_instance_assignment -name CLOCK_REGION "SX0 SY0 SX6 SY7" -to {local_mem_wrapper|mem_ss_top|mem_ss_sv|mem_ss|mem_ss|emif_1|emif_1|arch|arch_inst|io_tiles_wrap_inst|io_tiles_inst|core_clks_from_cpa_pri_nonabphy[0]}
if {[llength $::calls] != 2} {error "wrong assignment count"}
set want0 [list -name CLOCK_SPINE 2 -to {local_mem_wrapper|mem_ss_top|mem_ss_sv|mem_ss|mem_ss|emif_1|emif_1|arch|arch_inst|io_tiles_wrap_inst|io_tiles_inst|core_clks_from_cpa_pri_nonabphy[0]}]
set want1 [list -name CLOCK_REGION "SX0 SY0 SX6 SY7" -to {local_mem_wrapper|mem_ss_top|mem_ss_sv|mem_ss|mem_ss|emif_1|emif_1|arch|arch_inst|io_tiles_wrap_inst|io_tiles_inst|core_clks_from_cpa_pri_nonabphy[0]}]
if {[lindex $::calls 0] ne $want0 || [lindex $::calls 1] ne $want1} {error "literal target/value mismatch"}
puts "CLOCK_ASSIGNMENT_INERT_PASS exact two calls"

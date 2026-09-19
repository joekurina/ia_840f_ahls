# make_system.tcl - ahls-qsys-import-01
# Create a minimal Platform Designer system instantiating the AHLS-generated
# qual_vec_op_report_di component (HLS IP Gen 2026.1.0) under Quartus 26.1.1.
set COMP qual_vec_op_report_di
set INST k0

proc have {p} { return [expr {[llength [info commands $p]] > 0}] }

if {![have create_system]} { error "MKSYS-FATAL: create_system proc not available" }
puts "MKSYS: create_system qual_test"
create_system qual_test

puts "MKSYS: add clock bridge"
add_instance clk_1x altera_clock_bridge
set_instance_parameter_value clk_1x "EXPLICIT_CLOCK_RATE" "0"
set_instance_parameter_value clk_1x "NUM_CLOCK_OUTPUTS" "1"
add_interface clock_reset clock sink
set_interface_property clock_reset EXPORT_OF clk_1x.in_clk

puts "MKSYS: add reset bridge"
add_instance rst altera_reset_bridge
set_instance_parameter_value rst "ACTIVE_LOW_RESET" "1"
set_instance_parameter_value rst "SYNCHRONOUS_EDGES" "deassert"
set_instance_parameter_value rst "NUM_RESET_OUTPUTS" "1"
add_interface clock_reset_reset reset sink
set_interface_property clock_reset_reset EXPORT_OF rst.in_reset
add_connection clk_1x.out_clk rst.clk

puts "MKSYS: add_instance $INST $COMP"
add_instance $INST $COMP
add_connection clk_1x.out_clk $INST.clock
add_connection rst.out_reset $INST.resetn

puts "MKSYS: export csr slave / irq / freeze / exception"
add_interface avs_csr avalon end
set_interface_property avs_csr EXPORT_OF $INST.csr_ring_root_avs
add_interface kernel_irqs irq sender
set_interface_property kernel_irqs EXPORT_OF $INST.kernel_irqs
add_interface freeze conduit end
set_interface_property freeze EXPORT_OF $INST.freeze
add_interface device_exception_bus conduit end
set_interface_property device_exception_bus EXPORT_OF $INST.device_exception_bus

if {[have validate_system]} {
  puts "MKSYS: validate"
  if {[catch {validate_system} verr]} { puts "MKSYS-VALIDATE-ERROR: $verr" } else { puts "MKSYS: validate_system OK" }
} else {
  puts "MKSYS-WARN: no validate_system proc"
}

puts "MKSYS: save_system qual_test.qsys"
save_system qual_test.qsys
puts "MKSYS: DONE"

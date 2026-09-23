# Native Quartus25.1 import of the source-bound AHLS2026.1.0 DDRIP.
create_system ahls_memory_import
add_instance clk_1x altera_clock_bridge
set_instance_parameter_value clk_1x EXPLICIT_CLOCK_RATE 0
set_instance_parameter_value clk_1x NUM_CLOCK_OUTPUTS 1
add_interface clock_reset clock sink
set_interface_property clock_reset EXPORT_OF clk_1x.in_clk
add_instance rst altera_reset_bridge
set_instance_parameter_value rst ACTIVE_LOW_RESET 1
set_instance_parameter_value rst SYNCHRONOUS_EDGES deassert
set_instance_parameter_value rst NUM_RESET_OUTPUTS 1
add_interface clock_reset_reset reset sink
set_interface_property clock_reset_reset EXPORT_OF rst.in_reset
add_connection clk_1x.out_clk rst.clk
add_instance k0 mmhost_ia840f_report_di
add_connection clk_1x.out_clk k0.clock
add_connection rst.out_reset k0.resetn
foreach {external internal kind direction} {
    avs_csr csr_ring_root_avs avalon end
    mem0 avm_mem_gmem0_1_port_0_0_rw avalon start
    mem1 avm_mem_gmem1_2_port_0_0_rw avalon start
    kernel_irqs kernel_irqs irq sender
    freeze freeze conduit end
    device_exception_bus device_exception_bus conduit end
} {
    add_interface $external $kind $direction
    set_interface_property $external EXPORT_OF k0.$internal
}
puts "PD_INTERFACES [get_instance_interfaces k0]"
foreach interface {csr_ring_root_avs avm_mem_gmem0_1_port_0_0_rw avm_mem_gmem1_2_port_0_0_rw} {
    set available [get_instance_interface_properties k0 $interface]
    foreach property {addressUnits burstcountUnits bitsPerSymbol waitrequestAllowance readLatency maximumPendingReadTransactions readWaitTime writeWaitTime associatedClock associatedReset} {
        if {[lsearch -exact $available $property] >= 0} {
            puts "PD_PROPERTY $interface.$property=[get_instance_interface_property k0 $interface $property]"
        } else {
            puts "PD_PROPERTY_UNAVAILABLE $interface.$property"
        }
    }
    set units [get_instance_interface_property k0 $interface addressUnits]
    if {$interface eq "csr_ring_root_avs"} {set required WORDS} else {set required SYMBOLS}
    if {$units ne $required} {error "PD_ABI_MISMATCH $interface addressUnits=$units required=$required"}
}
validate_system
puts "PD_VALIDATE_OK"
save_system ahls_memory_import.qsys
puts "PD_IMPORT_COMPLETE"

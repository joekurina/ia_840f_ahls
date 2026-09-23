# Native top-level system script; fabric composition uses the component API.
create_system ahls_memory_fabric
add_instance fabric ia840f_ahls_memory_fabric 1.0
foreach {external kind direction} {
    clock_reset clock sink
    clock_reset_reset reset sink
    mmio_control axi4 slave
    dma_csr axi4 master
    dma_ddr_in0 axi4 slave
    dma_ddr_in1 axi4 slave
    bank_out0 axi4 master
    bank_out1 axi4 master
    kernel_irqs irq sender
    freeze conduit end
    device_exception_bus conduit end
} {
    add_interface $external $kind $direction
    set_interface_property $external EXPORT_OF fabric.$external
}
puts "FABRIC_INTERFACES=[get_instance_interfaces fabric]"
validate_system
puts "PD_VALIDATE_OK"
save_system ahls_memory_fabric.qsys
puts "PD_IMPORT_COMPLETE"

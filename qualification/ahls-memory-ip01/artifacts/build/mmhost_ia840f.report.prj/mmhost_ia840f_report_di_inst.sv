// Example instance of the top level module for: 
//     mmhost_ia840f_report_di
// To include this component in your design, include: 
//     mmhost_ia840f_report_di.qsys
// in your Quartus project and follow the template 
// below to instantiate the IP.  Alternatively, the IP core 
// can be generated from a Qsys system.

mmhost_ia840f_report_di mmhost_ia840f_report_di_inst (
  // Interface: clock (clock end)
  .clock                                    ( ), // 1-bit clk input
  // Interface: resetn (reset end)
  .resetn                                   ( ), // 1-bit reset_n input
  // Interface: freeze (conduit end)
  .freeze                                   ( ), // 1-bit freeze input
  // Interface: device_exception_bus (conduit end)
  .device_exception_bus                     ( ), // 64-bit data output
  // Interface: kernel_irqs (interrupt end)
  .kernel_irqs                              ( ), // 1-bit irq output
  // Interface: avm_mem_gmem0_1_port_0_0_rw (avalon start)
  .avm_mem_gmem0_1_port_0_0_rw_address      ( ), // 34-bit address output
  .avm_mem_gmem0_1_port_0_0_rw_byteenable   ( ), // 32-bit byteenable output
  .avm_mem_gmem0_1_port_0_0_rw_readdatavalid( ), // 1-bit readdatavalid input
  .avm_mem_gmem0_1_port_0_0_rw_read         ( ), // 1-bit read output
  .avm_mem_gmem0_1_port_0_0_rw_readdata     ( ), // 256-bit readdata input
  .avm_mem_gmem0_1_port_0_0_rw_write        ( ), // 1-bit write output
  .avm_mem_gmem0_1_port_0_0_rw_writedata    ( ), // 256-bit writedata output
  .avm_mem_gmem0_1_port_0_0_rw_waitrequest  ( ), // 1-bit waitrequest input
  .avm_mem_gmem0_1_port_0_0_rw_burstcount   ( ), // 4-bit burstcount output
  // Interface: avm_mem_gmem1_2_port_0_0_rw (avalon start)
  .avm_mem_gmem1_2_port_0_0_rw_address      ( ), // 34-bit address output
  .avm_mem_gmem1_2_port_0_0_rw_byteenable   ( ), // 32-bit byteenable output
  .avm_mem_gmem1_2_port_0_0_rw_readdatavalid( ), // 1-bit readdatavalid input
  .avm_mem_gmem1_2_port_0_0_rw_read         ( ), // 1-bit read output
  .avm_mem_gmem1_2_port_0_0_rw_readdata     ( ), // 256-bit readdata input
  .avm_mem_gmem1_2_port_0_0_rw_write        ( ), // 1-bit write output
  .avm_mem_gmem1_2_port_0_0_rw_writedata    ( ), // 256-bit writedata output
  .avm_mem_gmem1_2_port_0_0_rw_waitrequest  ( ), // 1-bit waitrequest input
  .avm_mem_gmem1_2_port_0_0_rw_burstcount   ( ), // 4-bit burstcount output
  // Interface: csr_ring_root_avs (avalon end)
  .csr_ring_root_avs_read                   ( ), // 1-bit read input
  .csr_ring_root_avs_readdata               ( ), // 64-bit readdata output
  .csr_ring_root_avs_readdatavalid          ( ), // 1-bit readdatavalid output
  .csr_ring_root_avs_write                  ( ), // 1-bit write input
  .csr_ring_root_avs_writedata              ( ), // 64-bit writedata input
  .csr_ring_root_avs_address                ( ), // 5-bit address input
  .csr_ring_root_avs_byteenable             ( ), // 8-bit byteenable input
  .csr_ring_root_avs_waitrequest            ( )  // 1-bit waitrequest output
);

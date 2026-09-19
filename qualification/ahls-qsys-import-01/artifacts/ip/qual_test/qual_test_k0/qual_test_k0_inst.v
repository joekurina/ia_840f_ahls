	qual_test_k0 u0 (
		.clock                           (_connected_to_clock_),                           //   input,   width = 1,                clock.clk
		.resetn                          (_connected_to_resetn_),                          //   input,   width = 1,               resetn.reset_n
		.freeze                          (_connected_to_freeze_),                          //   input,   width = 1,               freeze.freeze
		.device_exception_bus            (_connected_to_device_exception_bus_),            //  output,  width = 64, device_exception_bus.data
		.kernel_irqs                     (_connected_to_kernel_irqs_),                     //  output,   width = 1,          kernel_irqs.irq
		.csr_ring_root_avs_read          (_connected_to_csr_ring_root_avs_read_),          //   input,   width = 1,    csr_ring_root_avs.read
		.csr_ring_root_avs_readdata      (_connected_to_csr_ring_root_avs_readdata_),      //  output,  width = 64,                     .readdata
		.csr_ring_root_avs_readdatavalid (_connected_to_csr_ring_root_avs_readdatavalid_), //  output,   width = 1,                     .readdatavalid
		.csr_ring_root_avs_write         (_connected_to_csr_ring_root_avs_write_),         //   input,   width = 1,                     .write
		.csr_ring_root_avs_writedata     (_connected_to_csr_ring_root_avs_writedata_),     //   input,  width = 64,                     .writedata
		.csr_ring_root_avs_address       (_connected_to_csr_ring_root_avs_address_),       //   input,   width = 5,                     .address
		.csr_ring_root_avs_byteenable    (_connected_to_csr_ring_root_avs_byteenable_),    //   input,   width = 8,                     .byteenable
		.csr_ring_root_avs_waitrequest   (_connected_to_csr_ring_root_avs_waitrequest_)    //  output,   width = 1,                     .waitrequest
	);


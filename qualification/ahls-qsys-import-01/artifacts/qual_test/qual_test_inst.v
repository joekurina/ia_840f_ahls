	qual_test u0 (
		.clock_reset_clk           (_connected_to_clock_reset_clk_),           //   input,   width = 1,          clock_reset.clk
		.freeze_freeze             (_connected_to_freeze_freeze_),             //   input,   width = 1,               freeze.freeze
		.device_exception_bus_data (_connected_to_device_exception_bus_data_), //  output,  width = 64, device_exception_bus.data
		.kernel_irqs_irq           (_connected_to_kernel_irqs_irq_),           //  output,   width = 1,          kernel_irqs.irq
		.avs_csr_read              (_connected_to_avs_csr_read_),              //   input,   width = 1,              avs_csr.read
		.avs_csr_readdata          (_connected_to_avs_csr_readdata_),          //  output,  width = 64,                     .readdata
		.avs_csr_readdatavalid     (_connected_to_avs_csr_readdatavalid_),     //  output,   width = 1,                     .readdatavalid
		.avs_csr_write             (_connected_to_avs_csr_write_),             //   input,   width = 1,                     .write
		.avs_csr_writedata         (_connected_to_avs_csr_writedata_),         //   input,  width = 64,                     .writedata
		.avs_csr_address           (_connected_to_avs_csr_address_),           //   input,   width = 5,                     .address
		.avs_csr_byteenable        (_connected_to_avs_csr_byteenable_),        //   input,   width = 8,                     .byteenable
		.avs_csr_waitrequest       (_connected_to_avs_csr_waitrequest_),       //  output,   width = 1,                     .waitrequest
		.clock_reset_reset_reset_n (_connected_to_clock_reset_reset_reset_n_)  //   input,   width = 1,    clock_reset_reset.reset_n
	);


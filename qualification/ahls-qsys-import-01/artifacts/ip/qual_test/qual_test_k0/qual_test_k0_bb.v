module qual_test_k0 (
		input  wire        clock,                           //                clock.clk
		input  wire        resetn,                          //               resetn.reset_n
		input  wire        freeze,                          //               freeze.freeze
		output wire [63:0] device_exception_bus,            // device_exception_bus.data
		output wire        kernel_irqs,                     //          kernel_irqs.irq
		input  wire        csr_ring_root_avs_read,          //    csr_ring_root_avs.read
		output wire [63:0] csr_ring_root_avs_readdata,      //                     .readdata
		output wire        csr_ring_root_avs_readdatavalid, //                     .readdatavalid
		input  wire        csr_ring_root_avs_write,         //                     .write
		input  wire [63:0] csr_ring_root_avs_writedata,     //                     .writedata
		input  wire [4:0]  csr_ring_root_avs_address,       //                     .address
		input  wire [7:0]  csr_ring_root_avs_byteenable,    //                     .byteenable
		output wire        csr_ring_root_avs_waitrequest    //                     .waitrequest
	);
endmodule


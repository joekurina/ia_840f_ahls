module qual_test (
		input  wire        clock_reset_clk,           //          clock_reset.clk
		input  wire        freeze_freeze,             //               freeze.freeze
		output wire [63:0] device_exception_bus_data, // device_exception_bus.data
		output wire        kernel_irqs_irq,           //          kernel_irqs.irq
		input  wire        avs_csr_read,              //              avs_csr.read
		output wire [63:0] avs_csr_readdata,          //                     .readdata
		output wire        avs_csr_readdatavalid,     //                     .readdatavalid
		input  wire        avs_csr_write,             //                     .write
		input  wire [63:0] avs_csr_writedata,         //                     .writedata
		input  wire [4:0]  avs_csr_address,           //                     .address
		input  wire [7:0]  avs_csr_byteenable,        //                     .byteenable
		output wire        avs_csr_waitrequest,       //                     .waitrequest
		input  wire        clock_reset_reset_reset_n  //    clock_reset_reset.reset_n
	);
endmodule


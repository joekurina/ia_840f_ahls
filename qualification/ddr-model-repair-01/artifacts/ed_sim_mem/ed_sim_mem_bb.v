module ed_sim_mem (
		input  wire [0:0]  mem_ck,      // mem.mem_ck,      CK clock
		input  wire [0:0]  mem_ck_n,    //    .mem_ck_n,    CK clock (negative leg)
		input  wire [16:0] mem_a,       //    .mem_a,       Address
		input  wire [0:0]  mem_act_n,   //    .mem_act_n,   Activation command
		input  wire [1:0]  mem_ba,      //    .mem_ba,      Bank address
		input  wire [1:0]  mem_bg,      //    .mem_bg,      Bank group
		input  wire [0:0]  mem_cke,     //    .mem_cke,     Clock enable
		input  wire [0:0]  mem_cs_n,    //    .mem_cs_n,    Chip select
		input  wire [0:0]  mem_odt,     //    .mem_odt,     On-die termination
		input  wire [0:0]  mem_reset_n, //    .mem_reset_n, Asynchronous reset
		input  wire [0:0]  mem_par,     //    .mem_par,     Command and address parity
		output wire [0:0]  mem_alert_n, //    .mem_alert_n, Alert flag
		inout  wire [7:0]  mem_dqs,     //    .mem_dqs,     Data strobe
		inout  wire [7:0]  mem_dqs_n,   //    .mem_dqs_n,   Data strobe (negative leg)
		inout  wire [63:0] mem_dq,      //    .mem_dq,      Read/write data
		inout  wire [7:0]  mem_dbi_n    //    .mem_dbi_n,   Acts as either the data bus inversion pin, or the data mask pin, depending on configuration.
	);
endmodule


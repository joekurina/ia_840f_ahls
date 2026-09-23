module scjio_agilex #(
		parameter CONTROL = "host"
	) (
		input  wire  jtag_clock_clk,       //   jtag_clock.clk,    Clock Input
		input  wire  jtag_signals_tms,     // jtag_signals.tms
		input  wire  jtag_signals_tdi,     //             .tdi
		output wire  jtag_signals_tdo,     //             .tdo
		input  wire  jtag_signals_tck_ena  //             .tck_ena
	);
endmodule


	scjio_agilex #(
		.CONTROL (STRING_VALUE_FOR_CONTROL)
	) u0 (
		.jtag_clock_clk       (_connected_to_jtag_clock_clk_),       //   input,  width = 1,   jtag_clock.clk
		.jtag_signals_tms     (_connected_to_jtag_signals_tms_),     //   input,  width = 1, jtag_signals.tms
		.jtag_signals_tdi     (_connected_to_jtag_signals_tdi_),     //   input,  width = 1,             .tdi
		.jtag_signals_tdo     (_connected_to_jtag_signals_tdo_),     //  output,  width = 1,             .tdo
		.jtag_signals_tck_ena (_connected_to_jtag_signals_tck_ena_)  //   input,  width = 1,             .tck_ena
	);


	component scjio_agilex is
		generic (
			CONTROL : string := "host"
		);
		port (
			jtag_clock_clk       : in  std_logic := 'X'; -- clk
			jtag_signals_tms     : in  std_logic := 'X'; -- tms
			jtag_signals_tdi     : in  std_logic := 'X'; -- tdi
			jtag_signals_tdo     : out std_logic;        -- tdo
			jtag_signals_tck_ena : in  std_logic := 'X'  -- tck_ena
		);
	end component scjio_agilex;

	u0 : component scjio_agilex
		generic map (
			CONTROL => STRING_VALUE_FOR_CONTROL
		)
		port map (
			jtag_clock_clk       => CONNECTED_TO_jtag_clock_clk,       --   jtag_clock.clk
			jtag_signals_tms     => CONNECTED_TO_jtag_signals_tms,     -- jtag_signals.tms
			jtag_signals_tdi     => CONNECTED_TO_jtag_signals_tdi,     --             .tdi
			jtag_signals_tdo     => CONNECTED_TO_jtag_signals_tdo,     --             .tdo
			jtag_signals_tck_ena => CONNECTED_TO_jtag_signals_tck_ena  --             .tck_ena
		);


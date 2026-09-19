	component mem_ss_mem_ss_501_qm5zaka_emif_0_clk_bridge is
		port (
			in_clk  : in  std_logic := 'X'; -- clk
			out_clk : out std_logic         -- clk
		);
	end component mem_ss_mem_ss_501_qm5zaka_emif_0_clk_bridge;

	u0 : component mem_ss_mem_ss_501_qm5zaka_emif_0_clk_bridge
		port map (
			in_clk  => CONNECTED_TO_in_clk,  --  in_clk.clk
			out_clk => CONNECTED_TO_out_clk  -- out_clk.clk
		);


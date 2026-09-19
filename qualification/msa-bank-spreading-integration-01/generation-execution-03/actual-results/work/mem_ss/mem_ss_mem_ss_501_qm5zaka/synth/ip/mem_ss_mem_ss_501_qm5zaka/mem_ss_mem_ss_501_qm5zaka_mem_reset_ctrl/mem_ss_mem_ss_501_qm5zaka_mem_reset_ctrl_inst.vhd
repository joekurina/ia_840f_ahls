	component mem_ss_mem_ss_501_qm5zaka_mem_reset_ctrl is
		port (
			clk                   : in  std_logic := 'X'; -- clk
			reset_n               : in  std_logic := 'X'; -- pll_locked
			app_ss_rst_req        : in  std_logic := 'X'; -- app_ss_rst_req
			ss_app_rst_rdy        : out std_logic;        -- ss_app_rst_rdy
			app_ss_cold_rst_n     : in  std_logic := 'X'; -- app_ss_cold_rst_n
			ss_app_cold_rst_ack_n : out std_logic;        -- ss_app_cold_rst_ack_n
			local_reset_req_0     : out std_logic;        -- local_reset_req
			local_reset_done_0    : in  std_logic := 'X'; -- local_reset_done
			local_reset_req_1     : out std_logic;        -- local_reset_req
			local_reset_done_1    : in  std_logic := 'X'  -- local_reset_done
		);
	end component mem_ss_mem_ss_501_qm5zaka_mem_reset_ctrl;

	u0 : component mem_ss_mem_ss_501_qm5zaka_mem_reset_ctrl
		port map (
			clk                   => CONNECTED_TO_clk,                   --                    clk.clk
			reset_n               => CONNECTED_TO_reset_n,               --                  reset.pll_locked
			app_ss_rst_req        => CONNECTED_TO_app_ss_rst_req,        --        subsystem_reset.app_ss_rst_req
			ss_app_rst_rdy        => CONNECTED_TO_ss_app_rst_rdy,        --                       .ss_app_rst_rdy
			app_ss_cold_rst_n     => CONNECTED_TO_app_ss_cold_rst_n,     --                       .app_ss_cold_rst_n
			ss_app_cold_rst_ack_n => CONNECTED_TO_ss_app_cold_rst_ack_n, --                       .ss_app_cold_rst_ack_n
			local_reset_req_0     => CONNECTED_TO_local_reset_req_0,     --    fm_emif_reset_req_0.local_reset_req
			local_reset_done_0    => CONNECTED_TO_local_reset_done_0,    -- fm_emif_reset_status_0.local_reset_done
			local_reset_req_1     => CONNECTED_TO_local_reset_req_1,     --    fm_emif_reset_req_1.local_reset_req
			local_reset_done_1    => CONNECTED_TO_local_reset_done_1     -- fm_emif_reset_status_1.local_reset_done
		);


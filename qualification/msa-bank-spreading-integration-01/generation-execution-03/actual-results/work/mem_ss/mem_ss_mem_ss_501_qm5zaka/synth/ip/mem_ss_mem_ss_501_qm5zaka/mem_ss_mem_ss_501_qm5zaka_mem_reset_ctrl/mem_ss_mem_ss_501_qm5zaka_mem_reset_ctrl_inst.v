	mem_ss_mem_ss_501_qm5zaka_mem_reset_ctrl u0 (
		.clk                   (_connected_to_clk_),                   //   input,  width = 1,                    clk.clk
		.reset_n               (_connected_to_reset_n_),               //   input,  width = 1,                  reset.pll_locked
		.app_ss_rst_req        (_connected_to_app_ss_rst_req_),        //   input,  width = 1,        subsystem_reset.app_ss_rst_req
		.ss_app_rst_rdy        (_connected_to_ss_app_rst_rdy_),        //  output,  width = 1,                       .ss_app_rst_rdy
		.app_ss_cold_rst_n     (_connected_to_app_ss_cold_rst_n_),     //   input,  width = 1,                       .app_ss_cold_rst_n
		.ss_app_cold_rst_ack_n (_connected_to_ss_app_cold_rst_ack_n_), //  output,  width = 1,                       .ss_app_cold_rst_ack_n
		.local_reset_req_0     (_connected_to_local_reset_req_0_),     //  output,  width = 1,    fm_emif_reset_req_0.local_reset_req
		.local_reset_done_0    (_connected_to_local_reset_done_0_),    //   input,  width = 1, fm_emif_reset_status_0.local_reset_done
		.local_reset_req_1     (_connected_to_local_reset_req_1_),     //  output,  width = 1,    fm_emif_reset_req_1.local_reset_req
		.local_reset_done_1    (_connected_to_local_reset_done_1_)     //   input,  width = 1, fm_emif_reset_status_1.local_reset_done
	);


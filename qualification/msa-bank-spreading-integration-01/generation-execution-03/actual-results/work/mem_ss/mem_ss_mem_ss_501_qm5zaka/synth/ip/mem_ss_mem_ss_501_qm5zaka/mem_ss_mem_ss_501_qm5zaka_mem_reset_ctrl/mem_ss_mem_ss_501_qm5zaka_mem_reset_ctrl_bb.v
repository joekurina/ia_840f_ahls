module mem_ss_mem_ss_501_qm5zaka_mem_reset_ctrl (
		input  wire  clk,                   //                    clk.clk
		input  wire  reset_n,               //                  reset.pll_locked
		input  wire  app_ss_rst_req,        //        subsystem_reset.app_ss_rst_req
		output wire  ss_app_rst_rdy,        //                       .ss_app_rst_rdy
		input  wire  app_ss_cold_rst_n,     //                       .app_ss_cold_rst_n
		output wire  ss_app_cold_rst_ack_n, //                       .ss_app_cold_rst_ack_n
		output wire  local_reset_req_0,     //    fm_emif_reset_req_0.local_reset_req
		input  wire  local_reset_done_0,    // fm_emif_reset_status_0.local_reset_done
		output wire  local_reset_req_1,     //    fm_emif_reset_req_1.local_reset_req
		input  wire  local_reset_done_1     // fm_emif_reset_status_1.local_reset_done
	);
endmodule


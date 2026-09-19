	ed_sim_mem u0 (
		.mem_ck      (_connected_to_mem_ck_),      //   input,   width = 1, mem.mem_ck
		.mem_ck_n    (_connected_to_mem_ck_n_),    //   input,   width = 1,    .mem_ck_n
		.mem_a       (_connected_to_mem_a_),       //   input,  width = 17,    .mem_a
		.mem_act_n   (_connected_to_mem_act_n_),   //   input,   width = 1,    .mem_act_n
		.mem_ba      (_connected_to_mem_ba_),      //   input,   width = 2,    .mem_ba
		.mem_bg      (_connected_to_mem_bg_),      //   input,   width = 2,    .mem_bg
		.mem_cke     (_connected_to_mem_cke_),     //   input,   width = 1,    .mem_cke
		.mem_cs_n    (_connected_to_mem_cs_n_),    //   input,   width = 1,    .mem_cs_n
		.mem_odt     (_connected_to_mem_odt_),     //   input,   width = 1,    .mem_odt
		.mem_reset_n (_connected_to_mem_reset_n_), //   input,   width = 1,    .mem_reset_n
		.mem_par     (_connected_to_mem_par_),     //   input,   width = 1,    .mem_par
		.mem_alert_n (_connected_to_mem_alert_n_), //  output,   width = 1,    .mem_alert_n
		.mem_dqs     (_connected_to_mem_dqs_),     //   inout,   width = 8,    .mem_dqs
		.mem_dqs_n   (_connected_to_mem_dqs_n_),   //   inout,   width = 8,    .mem_dqs_n
		.mem_dq      (_connected_to_mem_dq_),      //   inout,  width = 64,    .mem_dq
		.mem_dbi_n   (_connected_to_mem_dbi_n_)    //   inout,   width = 8,    .mem_dbi_n
	);


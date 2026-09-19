module mem_ss_mem_ss_501_qm5zaka (
		input  wire         mem0_pll_ref_clk,        // mem0_pll_ref_clk.clk
		input  wire         mem0_oct_rzqin,          //         mem0_oct.oct_rzqin
		output wire [0:0]   mem0_ddr4_ck,            //        mem0_ddr4.mem_ck
		output wire [0:0]   mem0_ddr4_ck_n,          //                 .mem_ck_n
		output wire [16:0]  mem0_ddr4_a,             //                 .mem_a
		output wire [0:0]   mem0_ddr4_act_n,         //                 .mem_act_n
		output wire [1:0]   mem0_ddr4_ba,            //                 .mem_ba
		output wire [1:0]   mem0_ddr4_bg,            //                 .mem_bg
		output wire [0:0]   mem0_ddr4_cke,           //                 .mem_cke
		output wire [0:0]   mem0_ddr4_cs_n,          //                 .mem_cs_n
		output wire [0:0]   mem0_ddr4_odt,           //                 .mem_odt
		output wire [0:0]   mem0_ddr4_reset_n,       //                 .mem_reset_n
		output wire [0:0]   mem0_ddr4_par,           //                 .mem_par
		input  wire [0:0]   mem0_ddr4_alert_n,       //                 .mem_alert_n
		inout  wire [7:0]   mem0_ddr4_dqs,           //                 .mem_dqs
		inout  wire [7:0]   mem0_ddr4_dqs_n,         //                 .mem_dqs_n
		inout  wire [63:0]  mem0_ddr4_dq,            //                 .mem_dq
		inout  wire [7:0]   mem0_ddr4_dbi_n,         //                 .mem_dbi_n
		output wire         mem0_ss_app_usr_clk,     //     mem0_usr_clk.clk
		output wire         mem0_ss_app_usr_reset_n, // mem0_usr_reset_n.reset_n
		input  wire         mem1_pll_ref_clk,        // mem1_pll_ref_clk.clk
		input  wire         mem1_oct_rzqin,          //         mem1_oct.oct_rzqin
		output wire [0:0]   mem1_ddr4_ck,            //        mem1_ddr4.mem_ck
		output wire [0:0]   mem1_ddr4_ck_n,          //                 .mem_ck_n
		output wire [16:0]  mem1_ddr4_a,             //                 .mem_a
		output wire [0:0]   mem1_ddr4_act_n,         //                 .mem_act_n
		output wire [1:0]   mem1_ddr4_ba,            //                 .mem_ba
		output wire [1:0]   mem1_ddr4_bg,            //                 .mem_bg
		output wire [0:0]   mem1_ddr4_cke,           //                 .mem_cke
		output wire [0:0]   mem1_ddr4_cs_n,          //                 .mem_cs_n
		output wire [0:0]   mem1_ddr4_odt,           //                 .mem_odt
		output wire [0:0]   mem1_ddr4_reset_n,       //                 .mem_reset_n
		output wire [0:0]   mem1_ddr4_par,           //                 .mem_par
		input  wire [0:0]   mem1_ddr4_alert_n,       //                 .mem_alert_n
		inout  wire [7:0]   mem1_ddr4_dqs,           //                 .mem_dqs
		inout  wire [7:0]   mem1_ddr4_dqs_n,         //                 .mem_dqs_n
		inout  wire [63:0]  mem1_ddr4_dq,            //                 .mem_dq
		inout  wire [7:0]   mem1_ddr4_dbi_n,         //                 .mem_dbi_n
		output wire         mem1_ss_app_usr_clk,     //     mem1_usr_clk.clk
		output wire         mem1_ss_app_usr_reset_n, // mem1_usr_reset_n.reset_n
		input  wire         app_ss_rst_req,          //  subsystem_reset.app_ss_rst_req
		output wire         ss_app_rst_rdy,          //                 .ss_app_rst_rdy
		input  wire         app_ss_cold_rst_n,       //                 .app_ss_cold_rst_n
		output wire         ss_app_cold_rst_ack_n,   //                 .ss_app_cold_rst_ack_n
		output wire         i0_ss_app_mm_awready,    //        i0_axi_mm.awready
		input  wire         i0_app_ss_mm_awvalid,    //                 .awvalid
		input  wire [8:0]   i0_app_ss_mm_awid,       //                 .awid
		input  wire [33:0]  i0_app_ss_mm_awaddr,     //                 .awaddr
		input  wire [7:0]   i0_app_ss_mm_awlen,      //                 .awlen
		input  wire [2:0]   i0_app_ss_mm_awsize,     //                 .awsize
		input  wire [1:0]   i0_app_ss_mm_awburst,    //                 .awburst
		input  wire         i0_app_ss_mm_awlock,     //                 .awlock
		input  wire [3:0]   i0_app_ss_mm_awcache,    //                 .awcache
		input  wire [2:0]   i0_app_ss_mm_awprot,     //                 .awprot
		input  wire [3:0]   i0_app_ss_mm_awqos,      //                 .awqos
		input  wire [13:0]  i0_app_ss_mm_awuser,     //                 .awuser
		output wire         i0_ss_app_mm_arready,    //                 .arready
		input  wire         i0_app_ss_mm_arvalid,    //                 .arvalid
		input  wire [8:0]   i0_app_ss_mm_arid,       //                 .arid
		input  wire [33:0]  i0_app_ss_mm_araddr,     //                 .araddr
		input  wire [7:0]   i0_app_ss_mm_arlen,      //                 .arlen
		input  wire [2:0]   i0_app_ss_mm_arsize,     //                 .arsize
		input  wire [1:0]   i0_app_ss_mm_arburst,    //                 .arburst
		input  wire         i0_app_ss_mm_arlock,     //                 .arlock
		input  wire [3:0]   i0_app_ss_mm_arcache,    //                 .arcache
		input  wire [2:0]   i0_app_ss_mm_arprot,     //                 .arprot
		input  wire [3:0]   i0_app_ss_mm_arqos,      //                 .arqos
		input  wire [13:0]  i0_app_ss_mm_aruser,     //                 .aruser
		output wire         i0_ss_app_mm_wready,     //                 .wready
		input  wire         i0_app_ss_mm_wvalid,     //                 .wvalid
		input  wire [511:0] i0_app_ss_mm_wdata,      //                 .wdata
		input  wire [63:0]  i0_app_ss_mm_wstrb,      //                 .wstrb
		input  wire         i0_app_ss_mm_wlast,      //                 .wlast
		input  wire         i0_app_ss_mm_bready,     //                 .bready
		output wire         i0_ss_app_mm_bvalid,     //                 .bvalid
		output wire [8:0]   i0_ss_app_mm_bid,        //                 .bid
		output wire [1:0]   i0_ss_app_mm_bresp,      //                 .bresp
		output wire         i0_ss_app_mm_buser,      //                 .buser
		input  wire         i0_app_ss_mm_rready,     //                 .rready
		output wire         i0_ss_app_mm_rvalid,     //                 .rvalid
		output wire [8:0]   i0_ss_app_mm_rid,        //                 .rid
		output wire [1:0]   i0_ss_app_mm_rresp,      //                 .rresp
		output wire [511:0] i0_ss_app_mm_rdata,      //                 .rdata
		output wire         i0_ss_app_mm_rlast,      //                 .rlast
		output wire         mem0_local_cal_success,  //      mem0_status.local_cal_success
		output wire         mem0_local_cal_fail,     //                 .local_cal_fail
		output wire         i1_ss_app_mm_awready,    //        i1_axi_mm.awready
		input  wire         i1_app_ss_mm_awvalid,    //                 .awvalid
		input  wire [8:0]   i1_app_ss_mm_awid,       //                 .awid
		input  wire [33:0]  i1_app_ss_mm_awaddr,     //                 .awaddr
		input  wire [7:0]   i1_app_ss_mm_awlen,      //                 .awlen
		input  wire [2:0]   i1_app_ss_mm_awsize,     //                 .awsize
		input  wire [1:0]   i1_app_ss_mm_awburst,    //                 .awburst
		input  wire         i1_app_ss_mm_awlock,     //                 .awlock
		input  wire [3:0]   i1_app_ss_mm_awcache,    //                 .awcache
		input  wire [2:0]   i1_app_ss_mm_awprot,     //                 .awprot
		input  wire [3:0]   i1_app_ss_mm_awqos,      //                 .awqos
		input  wire [13:0]  i1_app_ss_mm_awuser,     //                 .awuser
		output wire         i1_ss_app_mm_arready,    //                 .arready
		input  wire         i1_app_ss_mm_arvalid,    //                 .arvalid
		input  wire [8:0]   i1_app_ss_mm_arid,       //                 .arid
		input  wire [33:0]  i1_app_ss_mm_araddr,     //                 .araddr
		input  wire [7:0]   i1_app_ss_mm_arlen,      //                 .arlen
		input  wire [2:0]   i1_app_ss_mm_arsize,     //                 .arsize
		input  wire [1:0]   i1_app_ss_mm_arburst,    //                 .arburst
		input  wire         i1_app_ss_mm_arlock,     //                 .arlock
		input  wire [3:0]   i1_app_ss_mm_arcache,    //                 .arcache
		input  wire [2:0]   i1_app_ss_mm_arprot,     //                 .arprot
		input  wire [3:0]   i1_app_ss_mm_arqos,      //                 .arqos
		input  wire [13:0]  i1_app_ss_mm_aruser,     //                 .aruser
		output wire         i1_ss_app_mm_wready,     //                 .wready
		input  wire         i1_app_ss_mm_wvalid,     //                 .wvalid
		input  wire [511:0] i1_app_ss_mm_wdata,      //                 .wdata
		input  wire [63:0]  i1_app_ss_mm_wstrb,      //                 .wstrb
		input  wire         i1_app_ss_mm_wlast,      //                 .wlast
		input  wire         i1_app_ss_mm_bready,     //                 .bready
		output wire         i1_ss_app_mm_bvalid,     //                 .bvalid
		output wire [8:0]   i1_ss_app_mm_bid,        //                 .bid
		output wire [1:0]   i1_ss_app_mm_bresp,      //                 .bresp
		output wire         i1_ss_app_mm_buser,      //                 .buser
		input  wire         i1_app_ss_mm_rready,     //                 .rready
		output wire         i1_ss_app_mm_rvalid,     //                 .rvalid
		output wire [8:0]   i1_ss_app_mm_rid,        //                 .rid
		output wire [1:0]   i1_ss_app_mm_rresp,      //                 .rresp
		output wire [511:0] i1_ss_app_mm_rdata,      //                 .rdata
		output wire         i1_ss_app_mm_rlast,      //                 .rlast
		output wire         mem1_local_cal_success,  //      mem1_status.local_cal_success
		output wire         mem1_local_cal_fail      //                 .local_cal_fail
	);
endmodule


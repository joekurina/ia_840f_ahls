module mem_ss_mem_ss_501_qm5zaka_msa_1 (
		input  wire         s_clk,                   //               s_clk.clk
		input  wire         s_reset_n,               //             s_reset.reset_n
		input  wire         m_clk,                   //               m_clk.clk
		input  wire         m_reset_n,               //             m_reset.reset_n
		output wire         s_axi4_awready,          //              s_axi4.awready
		input  wire         s_axi4_awvalid,          //                    .awvalid
		input  wire [8:0]   s_axi4_awid,             //                    .awid
		input  wire [33:0]  s_axi4_awaddr,           //                    .awaddr
		input  wire [7:0]   s_axi4_awlen,            //                    .awlen
		input  wire [2:0]   s_axi4_awsize,           //                    .awsize
		input  wire [1:0]   s_axi4_awburst,          //                    .awburst
		input  wire         s_axi4_awlock,           //                    .awlock
		input  wire [3:0]   s_axi4_awcache,          //                    .awcache
		input  wire [2:0]   s_axi4_awprot,           //                    .awprot
		input  wire [3:0]   s_axi4_awqos,            //                    .awqos
		input  wire [13:0]  s_axi4_awuser,           //                    .awuser
		output wire         s_axi4_arready,          //                    .arready
		input  wire         s_axi4_arvalid,          //                    .arvalid
		input  wire [8:0]   s_axi4_arid,             //                    .arid
		input  wire [33:0]  s_axi4_araddr,           //                    .araddr
		input  wire [7:0]   s_axi4_arlen,            //                    .arlen
		input  wire [2:0]   s_axi4_arsize,           //                    .arsize
		input  wire [1:0]   s_axi4_arburst,          //                    .arburst
		input  wire         s_axi4_arlock,           //                    .arlock
		input  wire [3:0]   s_axi4_arcache,          //                    .arcache
		input  wire [2:0]   s_axi4_arprot,           //                    .arprot
		input  wire [3:0]   s_axi4_arqos,            //                    .arqos
		input  wire [13:0]  s_axi4_aruser,           //                    .aruser
		output wire         s_axi4_wready,           //                    .wready
		input  wire         s_axi4_wvalid,           //                    .wvalid
		input  wire [511:0] s_axi4_wdata,            //                    .wdata
		input  wire [63:0]  s_axi4_wstrb,            //                    .wstrb
		input  wire         s_axi4_wlast,            //                    .wlast
		input  wire         s_axi4_bready,           //                    .bready
		output wire         s_axi4_bvalid,           //                    .bvalid
		output wire [8:0]   s_axi4_bid,              //                    .bid
		output wire [1:0]   s_axi4_bresp,            //                    .bresp
		output wire         s_axi4_buser,            //                    .buser
		input  wire         s_axi4_rready,           //                    .rready
		output wire         s_axi4_rvalid,           //                    .rvalid
		output wire [8:0]   s_axi4_rid,              //                    .rid
		output wire [1:0]   s_axi4_rresp,            //                    .rresp
		output wire [511:0] s_axi4_rdata,            //                    .rdata
		output wire         s_axi4_rlast,            //                    .rlast
		input  wire         m_avmm_ready,            //              m_avmm.waitrequest_n,          Deasserted by the responder when it is unable to respond to a read or write request
		output wire         m_avmm_read,             //                    .read,                   Read request signal
		output wire         m_avmm_write,            //                    .write,                  Write request signal
		output wire [33:0]  m_avmm_address,          //                    .address,                Word address for the read/write request
		output wire [6:0]   m_avmm_burstcount,       //                    .burstcount,             During the first cycle of a burst, burstcount indicates the number of transfers the read/write burst contains. The minimum burstcount is 1
		output wire [511:0] m_avmm_writedata,        //                    .writedata,              Data signal from the initiator for write transfers
		output wire [63:0]  m_avmm_byteenable,       //                    .byteenable,             Enables specific byte lane(s) during transfers. Each bit in byteenable corresponds to a byte in writedata. The host bit <n> of byteenable indicates whether byte <n> is being written to. During writes, byteenables specify which bytes to write. Other bytes are ignored by the responder.
		input  wire [511:0] m_avmm_readdata,         //                    .readdata,               The readdata provided by the responder in response to a read transfer
		input  wire         m_avmm_readdatavalid,    //                    .readdatavalid,          Asserted by the responder to indicate that the readdata signal contains valid data in response to a previous read request
		output wire         local_cal_success,       //              status.local_cal_success
		output wire         local_cal_fail,          //                    .local_cal_fail
		input  wire         local_cal_success_in,    //           status_in.local_cal_success
		input  wire         local_cal_fail_in,       //                    .local_cal_fail
		output wire         ctrl_auto_precharge_req  // ctrl_auto_precharge.ctrl_auto_precharge_req
	);
endmodule


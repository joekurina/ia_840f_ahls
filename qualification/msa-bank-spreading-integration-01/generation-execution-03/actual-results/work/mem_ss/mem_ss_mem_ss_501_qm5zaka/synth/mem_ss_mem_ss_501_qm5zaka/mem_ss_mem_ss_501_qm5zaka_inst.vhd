	component mem_ss_mem_ss_501_qm5zaka is
		port (
			mem0_pll_ref_clk        : in    std_logic                      := 'X';             -- clk
			mem0_oct_rzqin          : in    std_logic                      := 'X';             -- oct_rzqin
			mem0_ddr4_ck            : out   std_logic_vector(0 downto 0);                      -- mem_ck
			mem0_ddr4_ck_n          : out   std_logic_vector(0 downto 0);                      -- mem_ck_n
			mem0_ddr4_a             : out   std_logic_vector(16 downto 0);                     -- mem_a
			mem0_ddr4_act_n         : out   std_logic_vector(0 downto 0);                      -- mem_act_n
			mem0_ddr4_ba            : out   std_logic_vector(1 downto 0);                      -- mem_ba
			mem0_ddr4_bg            : out   std_logic_vector(1 downto 0);                      -- mem_bg
			mem0_ddr4_cke           : out   std_logic_vector(0 downto 0);                      -- mem_cke
			mem0_ddr4_cs_n          : out   std_logic_vector(0 downto 0);                      -- mem_cs_n
			mem0_ddr4_odt           : out   std_logic_vector(0 downto 0);                      -- mem_odt
			mem0_ddr4_reset_n       : out   std_logic_vector(0 downto 0);                      -- mem_reset_n
			mem0_ddr4_par           : out   std_logic_vector(0 downto 0);                      -- mem_par
			mem0_ddr4_alert_n       : in    std_logic_vector(0 downto 0)   := (others => 'X'); -- mem_alert_n
			mem0_ddr4_dqs           : inout std_logic_vector(7 downto 0)   := (others => 'X'); -- mem_dqs
			mem0_ddr4_dqs_n         : inout std_logic_vector(7 downto 0)   := (others => 'X'); -- mem_dqs_n
			mem0_ddr4_dq            : inout std_logic_vector(63 downto 0)  := (others => 'X'); -- mem_dq
			mem0_ddr4_dbi_n         : inout std_logic_vector(7 downto 0)   := (others => 'X'); -- mem_dbi_n
			mem0_ss_app_usr_clk     : out   std_logic;                                         -- clk
			mem0_ss_app_usr_reset_n : out   std_logic;                                         -- reset_n
			mem1_pll_ref_clk        : in    std_logic                      := 'X';             -- clk
			mem1_oct_rzqin          : in    std_logic                      := 'X';             -- oct_rzqin
			mem1_ddr4_ck            : out   std_logic_vector(0 downto 0);                      -- mem_ck
			mem1_ddr4_ck_n          : out   std_logic_vector(0 downto 0);                      -- mem_ck_n
			mem1_ddr4_a             : out   std_logic_vector(16 downto 0);                     -- mem_a
			mem1_ddr4_act_n         : out   std_logic_vector(0 downto 0);                      -- mem_act_n
			mem1_ddr4_ba            : out   std_logic_vector(1 downto 0);                      -- mem_ba
			mem1_ddr4_bg            : out   std_logic_vector(1 downto 0);                      -- mem_bg
			mem1_ddr4_cke           : out   std_logic_vector(0 downto 0);                      -- mem_cke
			mem1_ddr4_cs_n          : out   std_logic_vector(0 downto 0);                      -- mem_cs_n
			mem1_ddr4_odt           : out   std_logic_vector(0 downto 0);                      -- mem_odt
			mem1_ddr4_reset_n       : out   std_logic_vector(0 downto 0);                      -- mem_reset_n
			mem1_ddr4_par           : out   std_logic_vector(0 downto 0);                      -- mem_par
			mem1_ddr4_alert_n       : in    std_logic_vector(0 downto 0)   := (others => 'X'); -- mem_alert_n
			mem1_ddr4_dqs           : inout std_logic_vector(7 downto 0)   := (others => 'X'); -- mem_dqs
			mem1_ddr4_dqs_n         : inout std_logic_vector(7 downto 0)   := (others => 'X'); -- mem_dqs_n
			mem1_ddr4_dq            : inout std_logic_vector(63 downto 0)  := (others => 'X'); -- mem_dq
			mem1_ddr4_dbi_n         : inout std_logic_vector(7 downto 0)   := (others => 'X'); -- mem_dbi_n
			mem1_ss_app_usr_clk     : out   std_logic;                                         -- clk
			mem1_ss_app_usr_reset_n : out   std_logic;                                         -- reset_n
			app_ss_rst_req          : in    std_logic                      := 'X';             -- app_ss_rst_req
			ss_app_rst_rdy          : out   std_logic;                                         -- ss_app_rst_rdy
			app_ss_cold_rst_n       : in    std_logic                      := 'X';             -- app_ss_cold_rst_n
			ss_app_cold_rst_ack_n   : out   std_logic;                                         -- ss_app_cold_rst_ack_n
			i0_ss_app_mm_awready    : out   std_logic;                                         -- awready
			i0_app_ss_mm_awvalid    : in    std_logic                      := 'X';             -- awvalid
			i0_app_ss_mm_awid       : in    std_logic_vector(8 downto 0)   := (others => 'X'); -- awid
			i0_app_ss_mm_awaddr     : in    std_logic_vector(33 downto 0)  := (others => 'X'); -- awaddr
			i0_app_ss_mm_awlen      : in    std_logic_vector(7 downto 0)   := (others => 'X'); -- awlen
			i0_app_ss_mm_awsize     : in    std_logic_vector(2 downto 0)   := (others => 'X'); -- awsize
			i0_app_ss_mm_awburst    : in    std_logic_vector(1 downto 0)   := (others => 'X'); -- awburst
			i0_app_ss_mm_awlock     : in    std_logic                      := 'X';             -- awlock
			i0_app_ss_mm_awcache    : in    std_logic_vector(3 downto 0)   := (others => 'X'); -- awcache
			i0_app_ss_mm_awprot     : in    std_logic_vector(2 downto 0)   := (others => 'X'); -- awprot
			i0_app_ss_mm_awqos      : in    std_logic_vector(3 downto 0)   := (others => 'X'); -- awqos
			i0_app_ss_mm_awuser     : in    std_logic_vector(13 downto 0)  := (others => 'X'); -- awuser
			i0_ss_app_mm_arready    : out   std_logic;                                         -- arready
			i0_app_ss_mm_arvalid    : in    std_logic                      := 'X';             -- arvalid
			i0_app_ss_mm_arid       : in    std_logic_vector(8 downto 0)   := (others => 'X'); -- arid
			i0_app_ss_mm_araddr     : in    std_logic_vector(33 downto 0)  := (others => 'X'); -- araddr
			i0_app_ss_mm_arlen      : in    std_logic_vector(7 downto 0)   := (others => 'X'); -- arlen
			i0_app_ss_mm_arsize     : in    std_logic_vector(2 downto 0)   := (others => 'X'); -- arsize
			i0_app_ss_mm_arburst    : in    std_logic_vector(1 downto 0)   := (others => 'X'); -- arburst
			i0_app_ss_mm_arlock     : in    std_logic                      := 'X';             -- arlock
			i0_app_ss_mm_arcache    : in    std_logic_vector(3 downto 0)   := (others => 'X'); -- arcache
			i0_app_ss_mm_arprot     : in    std_logic_vector(2 downto 0)   := (others => 'X'); -- arprot
			i0_app_ss_mm_arqos      : in    std_logic_vector(3 downto 0)   := (others => 'X'); -- arqos
			i0_app_ss_mm_aruser     : in    std_logic_vector(13 downto 0)  := (others => 'X'); -- aruser
			i0_ss_app_mm_wready     : out   std_logic;                                         -- wready
			i0_app_ss_mm_wvalid     : in    std_logic                      := 'X';             -- wvalid
			i0_app_ss_mm_wdata      : in    std_logic_vector(511 downto 0) := (others => 'X'); -- wdata
			i0_app_ss_mm_wstrb      : in    std_logic_vector(63 downto 0)  := (others => 'X'); -- wstrb
			i0_app_ss_mm_wlast      : in    std_logic                      := 'X';             -- wlast
			i0_app_ss_mm_bready     : in    std_logic                      := 'X';             -- bready
			i0_ss_app_mm_bvalid     : out   std_logic;                                         -- bvalid
			i0_ss_app_mm_bid        : out   std_logic_vector(8 downto 0);                      -- bid
			i0_ss_app_mm_bresp      : out   std_logic_vector(1 downto 0);                      -- bresp
			i0_ss_app_mm_buser      : out   std_logic;                                         -- buser
			i0_app_ss_mm_rready     : in    std_logic                      := 'X';             -- rready
			i0_ss_app_mm_rvalid     : out   std_logic;                                         -- rvalid
			i0_ss_app_mm_rid        : out   std_logic_vector(8 downto 0);                      -- rid
			i0_ss_app_mm_rresp      : out   std_logic_vector(1 downto 0);                      -- rresp
			i0_ss_app_mm_rdata      : out   std_logic_vector(511 downto 0);                    -- rdata
			i0_ss_app_mm_rlast      : out   std_logic;                                         -- rlast
			mem0_local_cal_success  : out   std_logic;                                         -- local_cal_success
			mem0_local_cal_fail     : out   std_logic;                                         -- local_cal_fail
			i1_ss_app_mm_awready    : out   std_logic;                                         -- awready
			i1_app_ss_mm_awvalid    : in    std_logic                      := 'X';             -- awvalid
			i1_app_ss_mm_awid       : in    std_logic_vector(8 downto 0)   := (others => 'X'); -- awid
			i1_app_ss_mm_awaddr     : in    std_logic_vector(33 downto 0)  := (others => 'X'); -- awaddr
			i1_app_ss_mm_awlen      : in    std_logic_vector(7 downto 0)   := (others => 'X'); -- awlen
			i1_app_ss_mm_awsize     : in    std_logic_vector(2 downto 0)   := (others => 'X'); -- awsize
			i1_app_ss_mm_awburst    : in    std_logic_vector(1 downto 0)   := (others => 'X'); -- awburst
			i1_app_ss_mm_awlock     : in    std_logic                      := 'X';             -- awlock
			i1_app_ss_mm_awcache    : in    std_logic_vector(3 downto 0)   := (others => 'X'); -- awcache
			i1_app_ss_mm_awprot     : in    std_logic_vector(2 downto 0)   := (others => 'X'); -- awprot
			i1_app_ss_mm_awqos      : in    std_logic_vector(3 downto 0)   := (others => 'X'); -- awqos
			i1_app_ss_mm_awuser     : in    std_logic_vector(13 downto 0)  := (others => 'X'); -- awuser
			i1_ss_app_mm_arready    : out   std_logic;                                         -- arready
			i1_app_ss_mm_arvalid    : in    std_logic                      := 'X';             -- arvalid
			i1_app_ss_mm_arid       : in    std_logic_vector(8 downto 0)   := (others => 'X'); -- arid
			i1_app_ss_mm_araddr     : in    std_logic_vector(33 downto 0)  := (others => 'X'); -- araddr
			i1_app_ss_mm_arlen      : in    std_logic_vector(7 downto 0)   := (others => 'X'); -- arlen
			i1_app_ss_mm_arsize     : in    std_logic_vector(2 downto 0)   := (others => 'X'); -- arsize
			i1_app_ss_mm_arburst    : in    std_logic_vector(1 downto 0)   := (others => 'X'); -- arburst
			i1_app_ss_mm_arlock     : in    std_logic                      := 'X';             -- arlock
			i1_app_ss_mm_arcache    : in    std_logic_vector(3 downto 0)   := (others => 'X'); -- arcache
			i1_app_ss_mm_arprot     : in    std_logic_vector(2 downto 0)   := (others => 'X'); -- arprot
			i1_app_ss_mm_arqos      : in    std_logic_vector(3 downto 0)   := (others => 'X'); -- arqos
			i1_app_ss_mm_aruser     : in    std_logic_vector(13 downto 0)  := (others => 'X'); -- aruser
			i1_ss_app_mm_wready     : out   std_logic;                                         -- wready
			i1_app_ss_mm_wvalid     : in    std_logic                      := 'X';             -- wvalid
			i1_app_ss_mm_wdata      : in    std_logic_vector(511 downto 0) := (others => 'X'); -- wdata
			i1_app_ss_mm_wstrb      : in    std_logic_vector(63 downto 0)  := (others => 'X'); -- wstrb
			i1_app_ss_mm_wlast      : in    std_logic                      := 'X';             -- wlast
			i1_app_ss_mm_bready     : in    std_logic                      := 'X';             -- bready
			i1_ss_app_mm_bvalid     : out   std_logic;                                         -- bvalid
			i1_ss_app_mm_bid        : out   std_logic_vector(8 downto 0);                      -- bid
			i1_ss_app_mm_bresp      : out   std_logic_vector(1 downto 0);                      -- bresp
			i1_ss_app_mm_buser      : out   std_logic;                                         -- buser
			i1_app_ss_mm_rready     : in    std_logic                      := 'X';             -- rready
			i1_ss_app_mm_rvalid     : out   std_logic;                                         -- rvalid
			i1_ss_app_mm_rid        : out   std_logic_vector(8 downto 0);                      -- rid
			i1_ss_app_mm_rresp      : out   std_logic_vector(1 downto 0);                      -- rresp
			i1_ss_app_mm_rdata      : out   std_logic_vector(511 downto 0);                    -- rdata
			i1_ss_app_mm_rlast      : out   std_logic;                                         -- rlast
			mem1_local_cal_success  : out   std_logic;                                         -- local_cal_success
			mem1_local_cal_fail     : out   std_logic                                          -- local_cal_fail
		);
	end component mem_ss_mem_ss_501_qm5zaka;

	u0 : component mem_ss_mem_ss_501_qm5zaka
		port map (
			mem0_pll_ref_clk        => CONNECTED_TO_mem0_pll_ref_clk,        -- mem0_pll_ref_clk.clk
			mem0_oct_rzqin          => CONNECTED_TO_mem0_oct_rzqin,          --         mem0_oct.oct_rzqin
			mem0_ddr4_ck            => CONNECTED_TO_mem0_ddr4_ck,            --        mem0_ddr4.mem_ck
			mem0_ddr4_ck_n          => CONNECTED_TO_mem0_ddr4_ck_n,          --                 .mem_ck_n
			mem0_ddr4_a             => CONNECTED_TO_mem0_ddr4_a,             --                 .mem_a
			mem0_ddr4_act_n         => CONNECTED_TO_mem0_ddr4_act_n,         --                 .mem_act_n
			mem0_ddr4_ba            => CONNECTED_TO_mem0_ddr4_ba,            --                 .mem_ba
			mem0_ddr4_bg            => CONNECTED_TO_mem0_ddr4_bg,            --                 .mem_bg
			mem0_ddr4_cke           => CONNECTED_TO_mem0_ddr4_cke,           --                 .mem_cke
			mem0_ddr4_cs_n          => CONNECTED_TO_mem0_ddr4_cs_n,          --                 .mem_cs_n
			mem0_ddr4_odt           => CONNECTED_TO_mem0_ddr4_odt,           --                 .mem_odt
			mem0_ddr4_reset_n       => CONNECTED_TO_mem0_ddr4_reset_n,       --                 .mem_reset_n
			mem0_ddr4_par           => CONNECTED_TO_mem0_ddr4_par,           --                 .mem_par
			mem0_ddr4_alert_n       => CONNECTED_TO_mem0_ddr4_alert_n,       --                 .mem_alert_n
			mem0_ddr4_dqs           => CONNECTED_TO_mem0_ddr4_dqs,           --                 .mem_dqs
			mem0_ddr4_dqs_n         => CONNECTED_TO_mem0_ddr4_dqs_n,         --                 .mem_dqs_n
			mem0_ddr4_dq            => CONNECTED_TO_mem0_ddr4_dq,            --                 .mem_dq
			mem0_ddr4_dbi_n         => CONNECTED_TO_mem0_ddr4_dbi_n,         --                 .mem_dbi_n
			mem0_ss_app_usr_clk     => CONNECTED_TO_mem0_ss_app_usr_clk,     --     mem0_usr_clk.clk
			mem0_ss_app_usr_reset_n => CONNECTED_TO_mem0_ss_app_usr_reset_n, -- mem0_usr_reset_n.reset_n
			mem1_pll_ref_clk        => CONNECTED_TO_mem1_pll_ref_clk,        -- mem1_pll_ref_clk.clk
			mem1_oct_rzqin          => CONNECTED_TO_mem1_oct_rzqin,          --         mem1_oct.oct_rzqin
			mem1_ddr4_ck            => CONNECTED_TO_mem1_ddr4_ck,            --        mem1_ddr4.mem_ck
			mem1_ddr4_ck_n          => CONNECTED_TO_mem1_ddr4_ck_n,          --                 .mem_ck_n
			mem1_ddr4_a             => CONNECTED_TO_mem1_ddr4_a,             --                 .mem_a
			mem1_ddr4_act_n         => CONNECTED_TO_mem1_ddr4_act_n,         --                 .mem_act_n
			mem1_ddr4_ba            => CONNECTED_TO_mem1_ddr4_ba,            --                 .mem_ba
			mem1_ddr4_bg            => CONNECTED_TO_mem1_ddr4_bg,            --                 .mem_bg
			mem1_ddr4_cke           => CONNECTED_TO_mem1_ddr4_cke,           --                 .mem_cke
			mem1_ddr4_cs_n          => CONNECTED_TO_mem1_ddr4_cs_n,          --                 .mem_cs_n
			mem1_ddr4_odt           => CONNECTED_TO_mem1_ddr4_odt,           --                 .mem_odt
			mem1_ddr4_reset_n       => CONNECTED_TO_mem1_ddr4_reset_n,       --                 .mem_reset_n
			mem1_ddr4_par           => CONNECTED_TO_mem1_ddr4_par,           --                 .mem_par
			mem1_ddr4_alert_n       => CONNECTED_TO_mem1_ddr4_alert_n,       --                 .mem_alert_n
			mem1_ddr4_dqs           => CONNECTED_TO_mem1_ddr4_dqs,           --                 .mem_dqs
			mem1_ddr4_dqs_n         => CONNECTED_TO_mem1_ddr4_dqs_n,         --                 .mem_dqs_n
			mem1_ddr4_dq            => CONNECTED_TO_mem1_ddr4_dq,            --                 .mem_dq
			mem1_ddr4_dbi_n         => CONNECTED_TO_mem1_ddr4_dbi_n,         --                 .mem_dbi_n
			mem1_ss_app_usr_clk     => CONNECTED_TO_mem1_ss_app_usr_clk,     --     mem1_usr_clk.clk
			mem1_ss_app_usr_reset_n => CONNECTED_TO_mem1_ss_app_usr_reset_n, -- mem1_usr_reset_n.reset_n
			app_ss_rst_req          => CONNECTED_TO_app_ss_rst_req,          --  subsystem_reset.app_ss_rst_req
			ss_app_rst_rdy          => CONNECTED_TO_ss_app_rst_rdy,          --                 .ss_app_rst_rdy
			app_ss_cold_rst_n       => CONNECTED_TO_app_ss_cold_rst_n,       --                 .app_ss_cold_rst_n
			ss_app_cold_rst_ack_n   => CONNECTED_TO_ss_app_cold_rst_ack_n,   --                 .ss_app_cold_rst_ack_n
			i0_ss_app_mm_awready    => CONNECTED_TO_i0_ss_app_mm_awready,    --        i0_axi_mm.awready
			i0_app_ss_mm_awvalid    => CONNECTED_TO_i0_app_ss_mm_awvalid,    --                 .awvalid
			i0_app_ss_mm_awid       => CONNECTED_TO_i0_app_ss_mm_awid,       --                 .awid
			i0_app_ss_mm_awaddr     => CONNECTED_TO_i0_app_ss_mm_awaddr,     --                 .awaddr
			i0_app_ss_mm_awlen      => CONNECTED_TO_i0_app_ss_mm_awlen,      --                 .awlen
			i0_app_ss_mm_awsize     => CONNECTED_TO_i0_app_ss_mm_awsize,     --                 .awsize
			i0_app_ss_mm_awburst    => CONNECTED_TO_i0_app_ss_mm_awburst,    --                 .awburst
			i0_app_ss_mm_awlock     => CONNECTED_TO_i0_app_ss_mm_awlock,     --                 .awlock
			i0_app_ss_mm_awcache    => CONNECTED_TO_i0_app_ss_mm_awcache,    --                 .awcache
			i0_app_ss_mm_awprot     => CONNECTED_TO_i0_app_ss_mm_awprot,     --                 .awprot
			i0_app_ss_mm_awqos      => CONNECTED_TO_i0_app_ss_mm_awqos,      --                 .awqos
			i0_app_ss_mm_awuser     => CONNECTED_TO_i0_app_ss_mm_awuser,     --                 .awuser
			i0_ss_app_mm_arready    => CONNECTED_TO_i0_ss_app_mm_arready,    --                 .arready
			i0_app_ss_mm_arvalid    => CONNECTED_TO_i0_app_ss_mm_arvalid,    --                 .arvalid
			i0_app_ss_mm_arid       => CONNECTED_TO_i0_app_ss_mm_arid,       --                 .arid
			i0_app_ss_mm_araddr     => CONNECTED_TO_i0_app_ss_mm_araddr,     --                 .araddr
			i0_app_ss_mm_arlen      => CONNECTED_TO_i0_app_ss_mm_arlen,      --                 .arlen
			i0_app_ss_mm_arsize     => CONNECTED_TO_i0_app_ss_mm_arsize,     --                 .arsize
			i0_app_ss_mm_arburst    => CONNECTED_TO_i0_app_ss_mm_arburst,    --                 .arburst
			i0_app_ss_mm_arlock     => CONNECTED_TO_i0_app_ss_mm_arlock,     --                 .arlock
			i0_app_ss_mm_arcache    => CONNECTED_TO_i0_app_ss_mm_arcache,    --                 .arcache
			i0_app_ss_mm_arprot     => CONNECTED_TO_i0_app_ss_mm_arprot,     --                 .arprot
			i0_app_ss_mm_arqos      => CONNECTED_TO_i0_app_ss_mm_arqos,      --                 .arqos
			i0_app_ss_mm_aruser     => CONNECTED_TO_i0_app_ss_mm_aruser,     --                 .aruser
			i0_ss_app_mm_wready     => CONNECTED_TO_i0_ss_app_mm_wready,     --                 .wready
			i0_app_ss_mm_wvalid     => CONNECTED_TO_i0_app_ss_mm_wvalid,     --                 .wvalid
			i0_app_ss_mm_wdata      => CONNECTED_TO_i0_app_ss_mm_wdata,      --                 .wdata
			i0_app_ss_mm_wstrb      => CONNECTED_TO_i0_app_ss_mm_wstrb,      --                 .wstrb
			i0_app_ss_mm_wlast      => CONNECTED_TO_i0_app_ss_mm_wlast,      --                 .wlast
			i0_app_ss_mm_bready     => CONNECTED_TO_i0_app_ss_mm_bready,     --                 .bready
			i0_ss_app_mm_bvalid     => CONNECTED_TO_i0_ss_app_mm_bvalid,     --                 .bvalid
			i0_ss_app_mm_bid        => CONNECTED_TO_i0_ss_app_mm_bid,        --                 .bid
			i0_ss_app_mm_bresp      => CONNECTED_TO_i0_ss_app_mm_bresp,      --                 .bresp
			i0_ss_app_mm_buser      => CONNECTED_TO_i0_ss_app_mm_buser,      --                 .buser
			i0_app_ss_mm_rready     => CONNECTED_TO_i0_app_ss_mm_rready,     --                 .rready
			i0_ss_app_mm_rvalid     => CONNECTED_TO_i0_ss_app_mm_rvalid,     --                 .rvalid
			i0_ss_app_mm_rid        => CONNECTED_TO_i0_ss_app_mm_rid,        --                 .rid
			i0_ss_app_mm_rresp      => CONNECTED_TO_i0_ss_app_mm_rresp,      --                 .rresp
			i0_ss_app_mm_rdata      => CONNECTED_TO_i0_ss_app_mm_rdata,      --                 .rdata
			i0_ss_app_mm_rlast      => CONNECTED_TO_i0_ss_app_mm_rlast,      --                 .rlast
			mem0_local_cal_success  => CONNECTED_TO_mem0_local_cal_success,  --      mem0_status.local_cal_success
			mem0_local_cal_fail     => CONNECTED_TO_mem0_local_cal_fail,     --                 .local_cal_fail
			i1_ss_app_mm_awready    => CONNECTED_TO_i1_ss_app_mm_awready,    --        i1_axi_mm.awready
			i1_app_ss_mm_awvalid    => CONNECTED_TO_i1_app_ss_mm_awvalid,    --                 .awvalid
			i1_app_ss_mm_awid       => CONNECTED_TO_i1_app_ss_mm_awid,       --                 .awid
			i1_app_ss_mm_awaddr     => CONNECTED_TO_i1_app_ss_mm_awaddr,     --                 .awaddr
			i1_app_ss_mm_awlen      => CONNECTED_TO_i1_app_ss_mm_awlen,      --                 .awlen
			i1_app_ss_mm_awsize     => CONNECTED_TO_i1_app_ss_mm_awsize,     --                 .awsize
			i1_app_ss_mm_awburst    => CONNECTED_TO_i1_app_ss_mm_awburst,    --                 .awburst
			i1_app_ss_mm_awlock     => CONNECTED_TO_i1_app_ss_mm_awlock,     --                 .awlock
			i1_app_ss_mm_awcache    => CONNECTED_TO_i1_app_ss_mm_awcache,    --                 .awcache
			i1_app_ss_mm_awprot     => CONNECTED_TO_i1_app_ss_mm_awprot,     --                 .awprot
			i1_app_ss_mm_awqos      => CONNECTED_TO_i1_app_ss_mm_awqos,      --                 .awqos
			i1_app_ss_mm_awuser     => CONNECTED_TO_i1_app_ss_mm_awuser,     --                 .awuser
			i1_ss_app_mm_arready    => CONNECTED_TO_i1_ss_app_mm_arready,    --                 .arready
			i1_app_ss_mm_arvalid    => CONNECTED_TO_i1_app_ss_mm_arvalid,    --                 .arvalid
			i1_app_ss_mm_arid       => CONNECTED_TO_i1_app_ss_mm_arid,       --                 .arid
			i1_app_ss_mm_araddr     => CONNECTED_TO_i1_app_ss_mm_araddr,     --                 .araddr
			i1_app_ss_mm_arlen      => CONNECTED_TO_i1_app_ss_mm_arlen,      --                 .arlen
			i1_app_ss_mm_arsize     => CONNECTED_TO_i1_app_ss_mm_arsize,     --                 .arsize
			i1_app_ss_mm_arburst    => CONNECTED_TO_i1_app_ss_mm_arburst,    --                 .arburst
			i1_app_ss_mm_arlock     => CONNECTED_TO_i1_app_ss_mm_arlock,     --                 .arlock
			i1_app_ss_mm_arcache    => CONNECTED_TO_i1_app_ss_mm_arcache,    --                 .arcache
			i1_app_ss_mm_arprot     => CONNECTED_TO_i1_app_ss_mm_arprot,     --                 .arprot
			i1_app_ss_mm_arqos      => CONNECTED_TO_i1_app_ss_mm_arqos,      --                 .arqos
			i1_app_ss_mm_aruser     => CONNECTED_TO_i1_app_ss_mm_aruser,     --                 .aruser
			i1_ss_app_mm_wready     => CONNECTED_TO_i1_ss_app_mm_wready,     --                 .wready
			i1_app_ss_mm_wvalid     => CONNECTED_TO_i1_app_ss_mm_wvalid,     --                 .wvalid
			i1_app_ss_mm_wdata      => CONNECTED_TO_i1_app_ss_mm_wdata,      --                 .wdata
			i1_app_ss_mm_wstrb      => CONNECTED_TO_i1_app_ss_mm_wstrb,      --                 .wstrb
			i1_app_ss_mm_wlast      => CONNECTED_TO_i1_app_ss_mm_wlast,      --                 .wlast
			i1_app_ss_mm_bready     => CONNECTED_TO_i1_app_ss_mm_bready,     --                 .bready
			i1_ss_app_mm_bvalid     => CONNECTED_TO_i1_ss_app_mm_bvalid,     --                 .bvalid
			i1_ss_app_mm_bid        => CONNECTED_TO_i1_ss_app_mm_bid,        --                 .bid
			i1_ss_app_mm_bresp      => CONNECTED_TO_i1_ss_app_mm_bresp,      --                 .bresp
			i1_ss_app_mm_buser      => CONNECTED_TO_i1_ss_app_mm_buser,      --                 .buser
			i1_app_ss_mm_rready     => CONNECTED_TO_i1_app_ss_mm_rready,     --                 .rready
			i1_ss_app_mm_rvalid     => CONNECTED_TO_i1_ss_app_mm_rvalid,     --                 .rvalid
			i1_ss_app_mm_rid        => CONNECTED_TO_i1_ss_app_mm_rid,        --                 .rid
			i1_ss_app_mm_rresp      => CONNECTED_TO_i1_ss_app_mm_rresp,      --                 .rresp
			i1_ss_app_mm_rdata      => CONNECTED_TO_i1_ss_app_mm_rdata,      --                 .rdata
			i1_ss_app_mm_rlast      => CONNECTED_TO_i1_ss_app_mm_rlast,      --                 .rlast
			mem1_local_cal_success  => CONNECTED_TO_mem1_local_cal_success,  --      mem1_status.local_cal_success
			mem1_local_cal_fail     => CONNECTED_TO_mem1_local_cal_fail      --                 .local_cal_fail
		);


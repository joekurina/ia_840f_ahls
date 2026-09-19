	component mem_ss_mem_ss_501_qm5zaka_msa_1 is
		port (
			s_clk                   : in  std_logic                      := 'X';             -- clk
			s_reset_n               : in  std_logic                      := 'X';             -- reset_n
			m_clk                   : in  std_logic                      := 'X';             -- clk
			m_reset_n               : in  std_logic                      := 'X';             -- reset_n
			s_axi4_awready          : out std_logic;                                         -- awready
			s_axi4_awvalid          : in  std_logic                      := 'X';             -- awvalid
			s_axi4_awid             : in  std_logic_vector(8 downto 0)   := (others => 'X'); -- awid
			s_axi4_awaddr           : in  std_logic_vector(33 downto 0)  := (others => 'X'); -- awaddr
			s_axi4_awlen            : in  std_logic_vector(7 downto 0)   := (others => 'X'); -- awlen
			s_axi4_awsize           : in  std_logic_vector(2 downto 0)   := (others => 'X'); -- awsize
			s_axi4_awburst          : in  std_logic_vector(1 downto 0)   := (others => 'X'); -- awburst
			s_axi4_awlock           : in  std_logic                      := 'X';             -- awlock
			s_axi4_awcache          : in  std_logic_vector(3 downto 0)   := (others => 'X'); -- awcache
			s_axi4_awprot           : in  std_logic_vector(2 downto 0)   := (others => 'X'); -- awprot
			s_axi4_awqos            : in  std_logic_vector(3 downto 0)   := (others => 'X'); -- awqos
			s_axi4_awuser           : in  std_logic_vector(13 downto 0)  := (others => 'X'); -- awuser
			s_axi4_arready          : out std_logic;                                         -- arready
			s_axi4_arvalid          : in  std_logic                      := 'X';             -- arvalid
			s_axi4_arid             : in  std_logic_vector(8 downto 0)   := (others => 'X'); -- arid
			s_axi4_araddr           : in  std_logic_vector(33 downto 0)  := (others => 'X'); -- araddr
			s_axi4_arlen            : in  std_logic_vector(7 downto 0)   := (others => 'X'); -- arlen
			s_axi4_arsize           : in  std_logic_vector(2 downto 0)   := (others => 'X'); -- arsize
			s_axi4_arburst          : in  std_logic_vector(1 downto 0)   := (others => 'X'); -- arburst
			s_axi4_arlock           : in  std_logic                      := 'X';             -- arlock
			s_axi4_arcache          : in  std_logic_vector(3 downto 0)   := (others => 'X'); -- arcache
			s_axi4_arprot           : in  std_logic_vector(2 downto 0)   := (others => 'X'); -- arprot
			s_axi4_arqos            : in  std_logic_vector(3 downto 0)   := (others => 'X'); -- arqos
			s_axi4_aruser           : in  std_logic_vector(13 downto 0)  := (others => 'X'); -- aruser
			s_axi4_wready           : out std_logic;                                         -- wready
			s_axi4_wvalid           : in  std_logic                      := 'X';             -- wvalid
			s_axi4_wdata            : in  std_logic_vector(511 downto 0) := (others => 'X'); -- wdata
			s_axi4_wstrb            : in  std_logic_vector(63 downto 0)  := (others => 'X'); -- wstrb
			s_axi4_wlast            : in  std_logic                      := 'X';             -- wlast
			s_axi4_bready           : in  std_logic                      := 'X';             -- bready
			s_axi4_bvalid           : out std_logic;                                         -- bvalid
			s_axi4_bid              : out std_logic_vector(8 downto 0);                      -- bid
			s_axi4_bresp            : out std_logic_vector(1 downto 0);                      -- bresp
			s_axi4_buser            : out std_logic;                                         -- buser
			s_axi4_rready           : in  std_logic                      := 'X';             -- rready
			s_axi4_rvalid           : out std_logic;                                         -- rvalid
			s_axi4_rid              : out std_logic_vector(8 downto 0);                      -- rid
			s_axi4_rresp            : out std_logic_vector(1 downto 0);                      -- rresp
			s_axi4_rdata            : out std_logic_vector(511 downto 0);                    -- rdata
			s_axi4_rlast            : out std_logic;                                         -- rlast
			m_avmm_ready            : in  std_logic                      := 'X';             -- waitrequest_n
			m_avmm_read             : out std_logic;                                         -- read
			m_avmm_write            : out std_logic;                                         -- write
			m_avmm_address          : out std_logic_vector(33 downto 0);                     -- address
			m_avmm_burstcount       : out std_logic_vector(6 downto 0);                      -- burstcount
			m_avmm_writedata        : out std_logic_vector(511 downto 0);                    -- writedata
			m_avmm_byteenable       : out std_logic_vector(63 downto 0);                     -- byteenable
			m_avmm_readdata         : in  std_logic_vector(511 downto 0) := (others => 'X'); -- readdata
			m_avmm_readdatavalid    : in  std_logic                      := 'X';             -- readdatavalid
			local_cal_success       : out std_logic;                                         -- local_cal_success
			local_cal_fail          : out std_logic;                                         -- local_cal_fail
			local_cal_success_in    : in  std_logic                      := 'X';             -- local_cal_success
			local_cal_fail_in       : in  std_logic                      := 'X';             -- local_cal_fail
			ctrl_auto_precharge_req : out std_logic                                          -- ctrl_auto_precharge_req
		);
	end component mem_ss_mem_ss_501_qm5zaka_msa_1;

	u0 : component mem_ss_mem_ss_501_qm5zaka_msa_1
		port map (
			s_clk                   => CONNECTED_TO_s_clk,                   --               s_clk.clk
			s_reset_n               => CONNECTED_TO_s_reset_n,               --             s_reset.reset_n
			m_clk                   => CONNECTED_TO_m_clk,                   --               m_clk.clk
			m_reset_n               => CONNECTED_TO_m_reset_n,               --             m_reset.reset_n
			s_axi4_awready          => CONNECTED_TO_s_axi4_awready,          --              s_axi4.awready
			s_axi4_awvalid          => CONNECTED_TO_s_axi4_awvalid,          --                    .awvalid
			s_axi4_awid             => CONNECTED_TO_s_axi4_awid,             --                    .awid
			s_axi4_awaddr           => CONNECTED_TO_s_axi4_awaddr,           --                    .awaddr
			s_axi4_awlen            => CONNECTED_TO_s_axi4_awlen,            --                    .awlen
			s_axi4_awsize           => CONNECTED_TO_s_axi4_awsize,           --                    .awsize
			s_axi4_awburst          => CONNECTED_TO_s_axi4_awburst,          --                    .awburst
			s_axi4_awlock           => CONNECTED_TO_s_axi4_awlock,           --                    .awlock
			s_axi4_awcache          => CONNECTED_TO_s_axi4_awcache,          --                    .awcache
			s_axi4_awprot           => CONNECTED_TO_s_axi4_awprot,           --                    .awprot
			s_axi4_awqos            => CONNECTED_TO_s_axi4_awqos,            --                    .awqos
			s_axi4_awuser           => CONNECTED_TO_s_axi4_awuser,           --                    .awuser
			s_axi4_arready          => CONNECTED_TO_s_axi4_arready,          --                    .arready
			s_axi4_arvalid          => CONNECTED_TO_s_axi4_arvalid,          --                    .arvalid
			s_axi4_arid             => CONNECTED_TO_s_axi4_arid,             --                    .arid
			s_axi4_araddr           => CONNECTED_TO_s_axi4_araddr,           --                    .araddr
			s_axi4_arlen            => CONNECTED_TO_s_axi4_arlen,            --                    .arlen
			s_axi4_arsize           => CONNECTED_TO_s_axi4_arsize,           --                    .arsize
			s_axi4_arburst          => CONNECTED_TO_s_axi4_arburst,          --                    .arburst
			s_axi4_arlock           => CONNECTED_TO_s_axi4_arlock,           --                    .arlock
			s_axi4_arcache          => CONNECTED_TO_s_axi4_arcache,          --                    .arcache
			s_axi4_arprot           => CONNECTED_TO_s_axi4_arprot,           --                    .arprot
			s_axi4_arqos            => CONNECTED_TO_s_axi4_arqos,            --                    .arqos
			s_axi4_aruser           => CONNECTED_TO_s_axi4_aruser,           --                    .aruser
			s_axi4_wready           => CONNECTED_TO_s_axi4_wready,           --                    .wready
			s_axi4_wvalid           => CONNECTED_TO_s_axi4_wvalid,           --                    .wvalid
			s_axi4_wdata            => CONNECTED_TO_s_axi4_wdata,            --                    .wdata
			s_axi4_wstrb            => CONNECTED_TO_s_axi4_wstrb,            --                    .wstrb
			s_axi4_wlast            => CONNECTED_TO_s_axi4_wlast,            --                    .wlast
			s_axi4_bready           => CONNECTED_TO_s_axi4_bready,           --                    .bready
			s_axi4_bvalid           => CONNECTED_TO_s_axi4_bvalid,           --                    .bvalid
			s_axi4_bid              => CONNECTED_TO_s_axi4_bid,              --                    .bid
			s_axi4_bresp            => CONNECTED_TO_s_axi4_bresp,            --                    .bresp
			s_axi4_buser            => CONNECTED_TO_s_axi4_buser,            --                    .buser
			s_axi4_rready           => CONNECTED_TO_s_axi4_rready,           --                    .rready
			s_axi4_rvalid           => CONNECTED_TO_s_axi4_rvalid,           --                    .rvalid
			s_axi4_rid              => CONNECTED_TO_s_axi4_rid,              --                    .rid
			s_axi4_rresp            => CONNECTED_TO_s_axi4_rresp,            --                    .rresp
			s_axi4_rdata            => CONNECTED_TO_s_axi4_rdata,            --                    .rdata
			s_axi4_rlast            => CONNECTED_TO_s_axi4_rlast,            --                    .rlast
			m_avmm_ready            => CONNECTED_TO_m_avmm_ready,            --              m_avmm.waitrequest_n
			m_avmm_read             => CONNECTED_TO_m_avmm_read,             --                    .read
			m_avmm_write            => CONNECTED_TO_m_avmm_write,            --                    .write
			m_avmm_address          => CONNECTED_TO_m_avmm_address,          --                    .address
			m_avmm_burstcount       => CONNECTED_TO_m_avmm_burstcount,       --                    .burstcount
			m_avmm_writedata        => CONNECTED_TO_m_avmm_writedata,        --                    .writedata
			m_avmm_byteenable       => CONNECTED_TO_m_avmm_byteenable,       --                    .byteenable
			m_avmm_readdata         => CONNECTED_TO_m_avmm_readdata,         --                    .readdata
			m_avmm_readdatavalid    => CONNECTED_TO_m_avmm_readdatavalid,    --                    .readdatavalid
			local_cal_success       => CONNECTED_TO_local_cal_success,       --              status.local_cal_success
			local_cal_fail          => CONNECTED_TO_local_cal_fail,          --                    .local_cal_fail
			local_cal_success_in    => CONNECTED_TO_local_cal_success_in,    --           status_in.local_cal_success
			local_cal_fail_in       => CONNECTED_TO_local_cal_fail_in,       --                    .local_cal_fail
			ctrl_auto_precharge_req => CONNECTED_TO_ctrl_auto_precharge_req  -- ctrl_auto_precharge.ctrl_auto_precharge_req
		);


	component qual_test_k0 is
		port (
			clock                           : in  std_logic                     := 'X';             -- clk
			resetn                          : in  std_logic                     := 'X';             -- reset_n
			freeze                          : in  std_logic                     := 'X';             -- freeze
			device_exception_bus            : out std_logic_vector(63 downto 0);                    -- data
			kernel_irqs                     : out std_logic;                                        -- irq
			csr_ring_root_avs_read          : in  std_logic                     := 'X';             -- read
			csr_ring_root_avs_readdata      : out std_logic_vector(63 downto 0);                    -- readdata
			csr_ring_root_avs_readdatavalid : out std_logic;                                        -- readdatavalid
			csr_ring_root_avs_write         : in  std_logic                     := 'X';             -- write
			csr_ring_root_avs_writedata     : in  std_logic_vector(63 downto 0) := (others => 'X'); -- writedata
			csr_ring_root_avs_address       : in  std_logic_vector(4 downto 0)  := (others => 'X'); -- address
			csr_ring_root_avs_byteenable    : in  std_logic_vector(7 downto 0)  := (others => 'X'); -- byteenable
			csr_ring_root_avs_waitrequest   : out std_logic                                         -- waitrequest
		);
	end component qual_test_k0;

	u0 : component qual_test_k0
		port map (
			clock                           => CONNECTED_TO_clock,                           --                clock.clk
			resetn                          => CONNECTED_TO_resetn,                          --               resetn.reset_n
			freeze                          => CONNECTED_TO_freeze,                          --               freeze.freeze
			device_exception_bus            => CONNECTED_TO_device_exception_bus,            -- device_exception_bus.data
			kernel_irqs                     => CONNECTED_TO_kernel_irqs,                     --          kernel_irqs.irq
			csr_ring_root_avs_read          => CONNECTED_TO_csr_ring_root_avs_read,          --    csr_ring_root_avs.read
			csr_ring_root_avs_readdata      => CONNECTED_TO_csr_ring_root_avs_readdata,      --                     .readdata
			csr_ring_root_avs_readdatavalid => CONNECTED_TO_csr_ring_root_avs_readdatavalid, --                     .readdatavalid
			csr_ring_root_avs_write         => CONNECTED_TO_csr_ring_root_avs_write,         --                     .write
			csr_ring_root_avs_writedata     => CONNECTED_TO_csr_ring_root_avs_writedata,     --                     .writedata
			csr_ring_root_avs_address       => CONNECTED_TO_csr_ring_root_avs_address,       --                     .address
			csr_ring_root_avs_byteenable    => CONNECTED_TO_csr_ring_root_avs_byteenable,    --                     .byteenable
			csr_ring_root_avs_waitrequest   => CONNECTED_TO_csr_ring_root_avs_waitrequest    --                     .waitrequest
		);


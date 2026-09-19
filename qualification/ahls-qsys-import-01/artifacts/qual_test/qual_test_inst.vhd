	component qual_test is
		port (
			clock_reset_clk           : in  std_logic                     := 'X';             -- clk
			freeze_freeze             : in  std_logic                     := 'X';             -- freeze
			device_exception_bus_data : out std_logic_vector(63 downto 0);                    -- data
			kernel_irqs_irq           : out std_logic;                                        -- irq
			avs_csr_read              : in  std_logic                     := 'X';             -- read
			avs_csr_readdata          : out std_logic_vector(63 downto 0);                    -- readdata
			avs_csr_readdatavalid     : out std_logic;                                        -- readdatavalid
			avs_csr_write             : in  std_logic                     := 'X';             -- write
			avs_csr_writedata         : in  std_logic_vector(63 downto 0) := (others => 'X'); -- writedata
			avs_csr_address           : in  std_logic_vector(4 downto 0)  := (others => 'X'); -- address
			avs_csr_byteenable        : in  std_logic_vector(7 downto 0)  := (others => 'X'); -- byteenable
			avs_csr_waitrequest       : out std_logic;                                        -- waitrequest
			clock_reset_reset_reset_n : in  std_logic                     := 'X'              -- reset_n
		);
	end component qual_test;

	u0 : component qual_test
		port map (
			clock_reset_clk           => CONNECTED_TO_clock_reset_clk,           --          clock_reset.clk
			freeze_freeze             => CONNECTED_TO_freeze_freeze,             --               freeze.freeze
			device_exception_bus_data => CONNECTED_TO_device_exception_bus_data, -- device_exception_bus.data
			kernel_irqs_irq           => CONNECTED_TO_kernel_irqs_irq,           --          kernel_irqs.irq
			avs_csr_read              => CONNECTED_TO_avs_csr_read,              --              avs_csr.read
			avs_csr_readdata          => CONNECTED_TO_avs_csr_readdata,          --                     .readdata
			avs_csr_readdatavalid     => CONNECTED_TO_avs_csr_readdatavalid,     --                     .readdatavalid
			avs_csr_write             => CONNECTED_TO_avs_csr_write,             --                     .write
			avs_csr_writedata         => CONNECTED_TO_avs_csr_writedata,         --                     .writedata
			avs_csr_address           => CONNECTED_TO_avs_csr_address,           --                     .address
			avs_csr_byteenable        => CONNECTED_TO_avs_csr_byteenable,        --                     .byteenable
			avs_csr_waitrequest       => CONNECTED_TO_avs_csr_waitrequest,       --                     .waitrequest
			clock_reset_reset_reset_n => CONNECTED_TO_clock_reset_reset_reset_n  --    clock_reset_reset.reset_n
		);


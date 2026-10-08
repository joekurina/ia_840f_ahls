# IA840F domain intent from BittWare opencl_bsp.sdc; current native clock identities.
# No frequency, period, latency, uncertainty or new domain exemption is introduced.
set asp26_domain_0 [get_clocks {sys_pll|iopll_0_clk_sys}]
set asp26_count_0 [get_collection_size $asp26_domain_0]
puts "ASP26_CLOCK_DOMAIN_0 count=$asp26_count_0 expected=1"
if {$asp26_count_0 != 1} {puts stderr {ASP26_CLOCK_GROUP_REJECTED}; qexit -error}
set asp26_domain_1 [get_clocks {afu_top|pg_afu.port_gasket|user_clock|qph_user_clk|pll.qph_user_clk_iopll|iopll_0_outclk1 afu_top|pg_afu.port_gasket|user_clock|qph_user_clk|pll.qph_user_clk_iopll|iopll_0_outclk0}]
set asp26_count_1 [get_collection_size $asp26_domain_1]
puts "ASP26_CLOCK_DOMAIN_1 count=$asp26_count_1 expected=2"
if {$asp26_count_1 != 2} {puts stderr {ASP26_CLOCK_GROUP_REJECTED}; qexit -error}
set asp26_domain_2 [get_clocks {local_mem_wrapper|mem_ss_top|mem_ss_sv|mem_ss|mem_ss|emif_0|emif_0_core_usr_clk local_mem_wrapper|mem_ss_top|mem_ss_sv|mem_ss|mem_ss|emif_1|emif_1_core_usr_clk}]
set asp26_count_2 [get_collection_size $asp26_domain_2]
puts "ASP26_CLOCK_DOMAIN_2 count=$asp26_count_2 expected=2"
if {$asp26_count_2 != 2} {puts stderr {ASP26_CLOCK_GROUP_REJECTED}; qexit -error}
set_clock_groups -asynchronous -group $asp26_domain_0 -group $asp26_domain_1 -group $asp26_domain_2

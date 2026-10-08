# IA840F domain intent from BittWare opencl_bsp.sdc; current native clock identities.
# No frequency, period, latency, uncertainty or new domain exemption is introduced.
set asp26_domain_0 [get_clocks {sys_pll|iopll_0_clk_sys}]
set asp26_domain_1 [get_clocks {afu_top|pg_afu.port_gasket|user_clock|qph_user_clk|pll.qph_user_clk_iopll|iopll_0_outclk1 afu_top|pg_afu.port_gasket|user_clock|qph_user_clk|pll.qph_user_clk_iopll|iopll_0_outclk0}]
set asp26_domain_2 [get_clocks {local_mem_wrapper|mem_ss_top|mem_ss_sv|mem_ss|mem_ss|emif_0|emif_0_core_usr_clk local_mem_wrapper|mem_ss_top|mem_ss_sv|mem_ss|mem_ss|emif_1|emif_1_core_usr_clk}]
set_clock_groups -asynchronous -group $asp26_domain_0 -group $asp26_domain_1 -group $asp26_domain_2

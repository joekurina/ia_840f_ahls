#
# BittWare BMC SPI subsystem
#--------------------

set_global_assignment -name SEARCH_PATH "$::env(BUILD_ROOT_REL)/ipss"

# Append to the IP search path. Quartus has only a single instance
# of IP_SEARCH_PATHS.
set cur_ip_search_path ""
foreach_in_collection obj [get_all_assignments -type global -name IP_SEARCH_PATHS] {
    set cur_ip_search_path [get_assignment_info -value $obj]
}
set_global_assignment -name IP_SEARCH_PATHS "${cur_ip_search_path};$::env(BUILD_ROOT_REL)/ipss/ia840f/bwbmc/**/*;$::env(BUILD_ROOT_REL)/ipss/ia840f/bwbmc/ip/**/*"

set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ipss/ia840f/bwbmc/bwbmc_wrapper.sv

set_global_assignment -name QSYS_FILE          $::env(BUILD_ROOT_REL)/ipss/ia840f/bwbmc/bw_840_support.qsys
set_global_assignment -name IP_FILE            $::env(BUILD_ROOT_REL)/ipss/ia840f/bwbmc/ip/bw_840_support/bw_840_support_axi_bridge_0.ip
set_global_assignment -name IP_FILE            $::env(BUILD_ROOT_REL)/ipss/ia840f/bwbmc/ip/bw_840_support/bw_840_support_mm_bridge_0.ip
set_global_assignment -name IP_FILE            $::env(BUILD_ROOT_REL)/ipss/ia840f/bwbmc/ip/bw_840_support/bw_840_support_sysid_qsys_0.ip
set_global_assignment -name IP_FILE            $::env(BUILD_ROOT_REL)/ipss/ia840f/bwbmc/ip/bw_840_support/host_bmc_support_pipeline.ip
set_global_assignment -name IP_FILE            $::env(BUILD_ROOT_REL)/ipss/ia840f/bwbmc/ip/bw_840_support/host_sdm_pipeline.ip
set_global_assignment -name IP_FILE            $::env(BUILD_ROOT_REL)/ipss/ia840f/bwbmc/ip/bw_840_support/sysclk_bridge.ip
set_global_assignment -name IP_FILE            $::env(BUILD_ROOT_REL)/ipss/ia840f/bwbmc/ip/bw_840_support/sysrst_bridge.ip

set_global_assignment -name QSYS_FILE          $::env(BUILD_ROOT_REL)/ipss/ia840f/bwbmc/bmc_spi_sub.qsys
set_global_assignment -name IP_FILE            $::env(BUILD_ROOT_REL)/ipss/ia840f/bwbmc/ip/bmc_spi_sub/bmc_spi_cardtest_pipe.ip
set_global_assignment -name IP_FILE            $::env(BUILD_ROOT_REL)/ipss/ia840f/bwbmc/ip/bmc_spi_sub/bmc_spi_pipe0.ip
set_global_assignment -name IP_FILE            $::env(BUILD_ROOT_REL)/ipss/ia840f/bwbmc/ip/bmc_spi_sub/bmc_spi_sdm_pipe.ip
set_global_assignment -name IP_FILE            $::env(BUILD_ROOT_REL)/ipss/ia840f/bwbmc/ip/bmc_spi_sub/bmc_spi_support_pipe.ip
set_global_assignment -name IP_FILE            $::env(BUILD_ROOT_REL)/ipss/ia840f/bwbmc/ip/bmc_spi_sub/bmc_spi_to_avmm.ip
set_global_assignment -name IP_FILE            $::env(BUILD_ROOT_REL)/ipss/ia840f/bwbmc/ip/bmc_spi_sub/bmc_spi_xcvr_pipe.ip
set_global_assignment -name IP_FILE            $::env(BUILD_ROOT_REL)/ipss/ia840f/bwbmc/ip/bmc_spi_sub/bmc_to_pcie_irq_gen.ip
set_global_assignment -name IP_FILE            $::env(BUILD_ROOT_REL)/ipss/ia840f/bwbmc/ip/bmc_spi_sub/host_sdm_pipe.ip
set_global_assignment -name IP_FILE            $::env(BUILD_ROOT_REL)/ipss/ia840f/bwbmc/ip/bmc_spi_sub/host_support_pipe.ip
set_global_assignment -name IP_FILE            $::env(BUILD_ROOT_REL)/ipss/ia840f/bwbmc/ip/bmc_spi_sub/ocmem.ip
set_global_assignment -name IP_FILE            $::env(BUILD_ROOT_REL)/ipss/ia840f/bwbmc/ip/bmc_spi_sub/pci_to_bmc_irq_gen.ip
set_global_assignment -name IP_FILE            $::env(BUILD_ROOT_REL)/ipss/ia840f/bwbmc/ip/bmc_spi_sub/sdm_mailbox.ip
set_global_assignment -name IP_FILE            $::env(BUILD_ROOT_REL)/ipss/ia840f/bwbmc/ip/bmc_spi_sub/sdm_pipeline.ip
set_global_assignment -name IP_FILE            $::env(BUILD_ROOT_REL)/ipss/ia840f/bwbmc/ip/bmc_spi_sub/sdm_reset.ip
set_global_assignment -name IP_FILE            $::env(BUILD_ROOT_REL)/ipss/ia840f/bwbmc/ip/bmc_spi_sub/system_arbiter.ip
set_global_assignment -name IP_FILE            $::env(BUILD_ROOT_REL)/ipss/ia840f/bwbmc/ip/bmc_spi_sub/system_clk_bridge.ip
set_global_assignment -name IP_FILE            $::env(BUILD_ROOT_REL)/ipss/ia840f/bwbmc/ip/bmc_spi_sub/system_rst_bridge.ip

# BittWare BMC
#Top level timing constraints for BMC subsystem:
create_clock -name {bwbmc_fpga_max_sclk} -period 200.000 [get_ports {bwbmc_fpga_max_sclk}]
# Set Input Delay
set_input_delay -clock bwbmc_fpga_max_sclk -max 10.0 [get_ports {bwbmc_fpga_max_mosi}]
set_input_delay -clock bwbmc_fpga_max_sclk -min 0.0 [get_ports {bwbmc_fpga_max_mosi}]
set_input_delay -clock bwbmc_fpga_max_sclk -max 10.0 [get_ports {bwbmc_fpga_spi_cs}]
set_input_delay -clock bwbmc_fpga_max_sclk -min 0.0 [get_ports {bwbmc_fpga_spi_cs}]
# Set Output Delay
set_output_delay -clock bwbmc_fpga_max_sclk -max 12.0 [get_ports {bwbmc_fpga_max_miso}]
set_output_delay -clock bwbmc_fpga_max_sclk -min 1.0 [get_ports {bwbmc_fpga_max_miso}]

#Async clock group
set_clock_groups -asynchronous -group {sys_pll|iopll_0_clk_100m} -group {bwbmc_fpga_max_sclk}


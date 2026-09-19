# IA840F PCIe/system/BMC and standalone bank9A BTI pins; HSSI/HPS/PMCI are disabled.
# Source: legacy syn/setup/top_loc.tcl; full original is retained in src/board/ia840f/legacy/.
set_instance_assignment -name IO_STANDARD 1.8V -to PCIE_RESET_N
set_location_assignment PIN_GJ56 -to PCIE_RESET_N
set_instance_assignment -name IO_STANDARD HCSL -to PCIE_REFCLK0
set_instance_assignment -name IO_STANDARD HCSL -to PCIE_REFCLK1
set_location_assignment PIN_CV57 -to PCIE_REFCLK1
set_location_assignment PIN_CT56 -to "PCIE_REFCLK1(n)"
set_location_assignment PIN_DF57 -to PCIE_REFCLK0
set_location_assignment PIN_DD56 -to "PCIE_REFCLK0(n)"
set_instance_assignment -name IO_STANDARD "HIGH SPEED DIFFERENTIAL I/O" -to PCIE_TX_P[*]
set_instance_assignment -name IO_STANDARD "HIGH SPEED DIFFERENTIAL I/O" -to PCIE_TX_N[*]
set_instance_assignment -name IO_STANDARD "HIGH SPEED DIFFERENTIAL I/O" -to PCIE_RX_P[*]
set_instance_assignment -name IO_STANDARD "HIGH SPEED DIFFERENTIAL I/O" -to PCIE_RX_N[*]
set_location_assignment PIN_EF59 -to PCIE_TX_P[9]
set_location_assignment PIN_ED60 -to PCIE_TX_N[9]
set_location_assignment PIN_EH62 -to PCIE_TX_P[8]
set_location_assignment PIN_EK63 -to PCIE_TX_N[8]
set_location_assignment PIN_EP59 -to PCIE_TX_P[7]
set_location_assignment PIN_EM60 -to PCIE_TX_N[7]
set_location_assignment PIN_ET62 -to PCIE_TX_P[6]
set_location_assignment PIN_EV63 -to PCIE_TX_N[6]
set_location_assignment PIN_FC59 -to PCIE_TX_P[5]
set_location_assignment PIN_FA60 -to PCIE_TX_N[5]
set_location_assignment PIN_FE62 -to PCIE_TX_P[4]
set_location_assignment PIN_FG63 -to PCIE_TX_N[4]
set_location_assignment PIN_FL59 -to PCIE_TX_P[3]
set_location_assignment PIN_FJ60 -to PCIE_TX_N[3]
set_location_assignment PIN_FN62 -to PCIE_TX_P[2]
set_location_assignment PIN_FR63 -to PCIE_TX_N[2]
set_location_assignment PIN_FW59 -to PCIE_TX_P[1]
set_location_assignment PIN_FU60 -to PCIE_TX_N[1]
set_location_assignment PIN_DA59 -to PCIE_TX_P[15]
set_location_assignment PIN_CW60 -to PCIE_TX_N[15]
set_location_assignment PIN_DC62 -to PCIE_TX_P[14]
set_location_assignment PIN_DE63 -to PCIE_TX_N[14]
set_location_assignment PIN_DJ59 -to PCIE_TX_P[13]
set_location_assignment PIN_DG60 -to PCIE_TX_N[13]
set_location_assignment PIN_DL62 -to PCIE_TX_P[12]
set_location_assignment PIN_DN63 -to PCIE_TX_N[12]
set_location_assignment PIN_DV59 -to PCIE_TX_P[11]
set_location_assignment PIN_DT60 -to PCIE_TX_N[11]
set_location_assignment PIN_DY62 -to PCIE_TX_P[10]
set_location_assignment PIN_EB63 -to PCIE_TX_N[10]
set_location_assignment PIN_GA62 -to PCIE_TX_P[0]
set_location_assignment PIN_GD63 -to PCIE_TX_N[0]
set_location_assignment PIN_EF65 -to PCIE_RX_P[9]
set_location_assignment PIN_ED66 -to PCIE_RX_N[9]
set_location_assignment PIN_EH68 -to PCIE_RX_P[8]
set_location_assignment PIN_EK69 -to PCIE_RX_N[8]
set_location_assignment PIN_EP65 -to PCIE_RX_P[7]
set_location_assignment PIN_EM66 -to PCIE_RX_N[7]
set_location_assignment PIN_ET68 -to PCIE_RX_P[6]
set_location_assignment PIN_EV69 -to PCIE_RX_N[6]
set_location_assignment PIN_FC65 -to PCIE_RX_P[5]
set_location_assignment PIN_FA66 -to PCIE_RX_N[5]
set_location_assignment PIN_FE68 -to PCIE_RX_P[4]
set_location_assignment PIN_FG69 -to PCIE_RX_N[4]
set_location_assignment PIN_FL65 -to PCIE_RX_P[3]
set_location_assignment PIN_FJ66 -to PCIE_RX_N[3]
set_location_assignment PIN_FN68 -to PCIE_RX_P[2]
set_location_assignment PIN_FR69 -to PCIE_RX_N[2]
set_location_assignment PIN_FW65 -to PCIE_RX_P[1]
set_location_assignment PIN_FU66 -to PCIE_RX_N[1]
set_location_assignment PIN_DA65 -to PCIE_RX_P[15]
set_location_assignment PIN_CW66 -to PCIE_RX_N[15]
set_location_assignment PIN_DC68 -to PCIE_RX_P[14]
set_location_assignment PIN_DE69 -to PCIE_RX_N[14]
set_location_assignment PIN_DJ65 -to PCIE_RX_P[13]
set_location_assignment PIN_DG66 -to PCIE_RX_N[13]
set_location_assignment PIN_DL68 -to PCIE_RX_P[12]
set_location_assignment PIN_DN69 -to PCIE_RX_N[12]
set_location_assignment PIN_DV65 -to PCIE_RX_P[11]
set_location_assignment PIN_DT66 -to PCIE_RX_N[11]
set_location_assignment PIN_DY68 -to PCIE_RX_P[10]
set_location_assignment PIN_EB69 -to PCIE_RX_N[10]
set_location_assignment PIN_GA68 -to PCIE_RX_P[0]
set_location_assignment PIN_GD69 -to PCIE_RX_N[0]
set_location_assignment PIN_A53 -to "SYS_REFCLK(n)"
set_location_assignment PIN_C52 -to SYS_REFCLK
set_instance_assignment -name IO_STANDARD "TRUE DIFFERENTIAL SIGNALING" -to SYS_REFCLK
set_location_assignment PIN_L56 -to bwbmc_bmc_irq
set_location_assignment PIN_N57 -to bwbmc_bmc_mst_en_n
set_location_assignment PIN_W52 -to bwbmc_fpga_max_sclk
set_location_assignment PIN_U53 -to bwbmc_fpga_max_miso
set_location_assignment PIN_G56 -to bwbmc_fpga_max_mosi
set_location_assignment PIN_J57 -to bwbmc_fpga_spi_cs
set_instance_assignment -name IO_STANDARD "1.2V" -to bwbmc_bmc_irq
set_instance_assignment -name IO_STANDARD "1.2V" -to bwbmc_bmc_mst_en_n
set_instance_assignment -name IO_STANDARD "1.2V" -to bwbmc_fpga_max_sclk
set_instance_assignment -name IO_STANDARD "1.2V" -to bwbmc_fpga_max_miso
set_instance_assignment -name IO_STANDARD "1.2V" -to bwbmc_fpga_max_mosi
set_instance_assignment -name IO_STANDARD "1.2V" -to bwbmc_fpga_spi_cs

# Vendor IA840F top_loc.tcl:105-106,254-262; see qualification/fim-bti-clock-01.
# BTI key spelling follows Quartus 26.1.1 Error (21636), not assumed case equivalence.
set_location_assignment PIN_CC19 -to qsfp_ref_clk
set_location_assignment PIN_BW19 -to "qsfp_ref_clk(n)"
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL LVPECL" -to qsfp_ref_clk
set_instance_assignment -name HSSI_PARAMETER "refclk_divider_enable_termination=enable_term" -to qsfp_ref_clk
set_instance_assignment -name HSSI_PARAMETER "refclk_divider_enable_3p3v=disable_3p3v_tol" -to qsfp_ref_clk
set_instance_assignment -name HSSI_PARAMETER "refclk_divider_disable_hysteresis=enable_hyst" -to qsfp_ref_clk
set_instance_assignment -name HSSI_PARAMETER "refclk_divider_input_freq=156250000" -to qsfp_ref_clk
set_instance_assignment -name HSSI_PARAMETER "refclk_divider_powerdown_mode=false" -to qsfp_ref_clk
set_instance_assignment -name HSSI_PARAMETER "refclk_divider_use_as_BTI_clock=TRUE" -to qsfp_ref_clk

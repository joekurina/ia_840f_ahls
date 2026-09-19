# Copyright (C) 2020 Intel Corporation.
# SPDX-License-Identifier: MIT

#
# Description
#-----------------------------------------------------------------------------
#
# Pin and location assignments
#
#-----------------------------------------------------------------------------
set_location_assignment PIN_W48 -to hssi_rec_clk[0]
set_location_assignment PIN_U49 -to "hssi_rec_clk[0](n)"
set_location_assignment PIN_G54 -to hssi_rec_clk[1]
set_location_assignment PIN_J55 -to "hssi_rec_clk[1](n)"
set_location_assignment PIN_C54 -to hssi_rec_clk[2]
set_location_assignment PIN_A55 -to "hssi_rec_clk[2](n)"

#The QSFP sideband signals are not directly accessible to Agilex FPGA on IA-840F as they are via I2C GPIO expander only.
#So the following pins from N6000 are commented out.
#set_location_assignment PIN_CF17 -to qsfpa_resetn
#set_location_assignment PIN_CH17 -to qsfpa_lpmode
#set_location_assignment PIN_CE18 -to qsfpa_modeseln
#set_location_assignment PIN_CG18 -to qsfpa_intn
#set_location_assignment PIN_CF19 -to qsfpa_modprsln
#set_location_assignment PIN_CE22 -to qsfpa_power_good
#set_location_assignment PIN_CH19 -to qsfpb_resetn
#set_location_assignment PIN_CE20 -to qsfpb_lpmode
#set_location_assignment PIN_CG20 -to qsfpb_modeseln
#set_location_assignment PIN_CF21 -to qsfpb_intn
#set_location_assignment PIN_CH21 -to qsfpb_modprsln
#set_location_assignment PIN_CG22 -to qsfpb_power_good
#set_location_assignment PIN_CK17 -to qsfpa_i2c_scl
#set_location_assignment PIN_CM17 -to qsfpa_i2c_sda

#set_location_assignment PIN_CE24 -to "tod_fpga_clk(n)"
#set_location_assignment PIN_CG24 -to tod_fpga_clk
#set_location_assignment PIN_CH25 -to b_1pps_fpga_clk
#set_location_assignment PIN_CL18 -to qsfpb_i2c_scl
#set_location_assignment PIN_CM19 -to qsfpb_i2c_sda
#set_location_assignment PIN_V19  -to b_sel_1pps_inout
#set_location_assignment PIN_CH27 -to b_shdn_1pps_to_10mhz
#set_location_assignment PIN_CG28 -to b_shdn_10mhz_in
#set_location_assignment PIN_CH29 -to b_shdn_10mhz_out
#set_location_assignment PIN_CR20 -to rmii_crs_dv
#set_location_assignment PIN_CU18 -to rmii_rxd[0]
#set_location_assignment PIN_CV17 -to rmii_rxd[1]
#set_location_assignment PIN_CR18 -to rmii_txd[0]
#set_location_assignment PIN_CU20 -to rmii_txd[1]
#set_location_assignment PIN_CV19 -to rmii_tx_en
#set_location_assignment PIN_CV21 -to rmii_rxer
#set_location_assignment PIN_CN24 -to arb_in
#set_location_assignment PIN_CK25 -to arb_out
#set_location_assignment PIN_CM25 -to fm61_testio_d[0]
#set_location_assignment PIN_CL26 -to fm61_testio_d[1]
#set_location_assignment PIN_CN26 -to fm61_testio_d[2]
#set_location_assignment PIN_CK27 -to fm61_testio_d[3]
#set_location_assignment PIN_CM27 -to fm61_testio_d[4]
#set_location_assignment PIN_CL28 -to fm61_testio_d[5]
#set_location_assignment PIN_CN28 -to fm61_testio_d[6]
#set_location_assignment PIN_CK29 -to fm61_testio_d[7]
#set_location_assignment PIN_CM29 -to fm61_testio_clkout
#set_location_assignment PIN_DA22 -to "fpga_pcie_refclk3_100m(n)"
#set_location_assignment PIN_DC22 -to fpga_pcie_refclk3_100m
#set_location_assignment PIN_CN22 -to rmii_ref_clk
#set_location_assignment PIN_CV27 -to fpga_fabric_reset_n
#set_location_assignment PIN_CU28 -to m10_conf_done
#set_location_assignment PIN_DC24 -to b_fpga_hps_zl_gpout[0]
#set_location_assignment PIN_DA26 -to qsfpa_act_r
#set_location_assignment PIN_DC26 -to qsfpa_act_g
#set_location_assignment PIN_CY27 -to qsfpb_act_r
#set_location_assignment PIN_DB27 -to qsfpb_act_g
#set_location_assignment PIN_DA28 -to qsfpa_speed_y
#set_location_assignment PIN_DC28 -to qsfpa_speed_g
#set_location_assignment PIN_CY29 -to qsfpb_speed_y
#set_location_assignment PIN_DB29 -to qsfpb_speed_g
# set_location_assignment PIN_AG6 -to hps_uart_tx
# set_location_assignment PIN_AB1 -to hps_uart_rx
# set_location_assignment PIN_V1 -to b_fpga_hps_zl_ho
# set_location_assignment PIN_AD11 -to fpga_hps_clkin
# set_location_assignment PIN_AC12 -to b_zl_spi_sck
# set_location_assignment PIN_H3 -to b_zl_spi_si
# set_location_assignment PIN_AD13 -to b_zl_spi_so
# set_location_assignment PIN_F3 -to b_zl_spi_cs

#set_location_assignment PIN_AK7  -to cvl_serial_rx_p[0]
#set_location_assignment PIN_AL10 -to cvl_serial_rx_p[1]
#set_location_assignment PIN_AP7  -to cvl_serial_rx_p[2]
#set_location_assignment PIN_AR10 -to cvl_serial_rx_p[3]
#set_location_assignment PIN_AV7  -to cvl_serial_rx_p[4]
#set_location_assignment PIN_AW10 -to cvl_serial_rx_p[5]
#set_location_assignment PIN_BB7  -to cvl_serial_rx_p[6]
#set_location_assignment PIN_BC10 -to cvl_serial_rx_p[7]

#The following QSFP pin assignments are mapped to QSFP-DD-1 on IA-840F
set_location_assignment PIN_DL8  -to qsfp_serial[0].rx_p[0]
set_location_assignment PIN_DN13 -to qsfp_serial[0].rx_p[1]
set_location_assignment PIN_DY8  -to qsfp_serial[0].rx_p[2]
set_location_assignment PIN_EB13 -to qsfp_serial[0].rx_p[3]
set_location_assignment PIN_EH8  -to qsfp_serial[1].rx_p[0]
set_location_assignment PIN_EK13 -to qsfp_serial[1].rx_p[1]
set_location_assignment PIN_ET8  -to qsfp_serial[1].rx_p[2]
set_location_assignment PIN_EV13 -to qsfp_serial[1].rx_p[3]

#QSFPDD1_REFCLK ON IA-840F
set_location_assignment PIN_CC19 -to qsfp_ref_clk
set_location_assignment PIN_BW19 -to "qsfp_ref_clk(n)"

#cpri clocks not present on IA-840 commented out.
#set_location_assignment PIN_AR14 -to cr3_cpri_refclk_clk[1]
#set_location_assignment PIN_AN14 -to "cr3_cpri_refclk_clk[1](n)"
#set_location_assignment PIN_AJ12 -to cr3_cpri_refclk_clk[2]
#set_location_assignment PIN_AH11 -to "cr3_cpri_refclk_clk[2](n)"
#set_location_assignment PIN_AT13 -to cr3_cpri_reflclk_clk[0]
#set_location_assignment PIN_AP13 -to "cr3_cpri_reflclk_clk[0](n)"

#Note these clocks are defined in top.sv
#set_location_assignment PIN_AJ14 -to cr3_cpri_reflclk_clk_184_32m
#set_location_assignment PIN_AL14 -to "cr3_cpri_reflclk_clk_184_32m(n)"
#set_location_assignment PIN_AR16 -to cr3_cpri_reflclk_clk_153_6m
#set_location_assignment PIN_AN16 -to "cr3_cpri_reflclk_clk_153_6m(n)"

#set_location_assignment PIN_AK1 -to cvl_serial_tx_p[0]
#set_location_assignment PIN_AL4 -to cvl_serial_tx_p[1]
#set_location_assignment PIN_AP1 -to cvl_serial_tx_p[2]
#set_location_assignment PIN_AR4 -to cvl_serial_tx_p[3]
#set_location_assignment PIN_AV1 -to cvl_serial_tx_p[4]
#set_location_assignment PIN_AW4 -to cvl_serial_tx_p[5]
#set_location_assignment PIN_BB1 -to cvl_serial_tx_p[6]
#set_location_assignment PIN_BC4 -to cvl_serial_tx_p[7]

set_location_assignment PIN_DL1 -to qsfp_serial[0].tx_p[0]
set_location_assignment PIN_DN4 -to qsfp_serial[0].tx_p[1]
set_location_assignment PIN_DY1 -to qsfp_serial[0].tx_p[2]
set_location_assignment PIN_EB4 -to qsfp_serial[0].tx_p[3]
set_location_assignment PIN_EH1 -to qsfp_serial[1].tx_p[0]
set_location_assignment PIN_EK4 -to qsfp_serial[1].tx_p[1]
set_location_assignment PIN_ET1 -to qsfp_serial[1].tx_p[2]
set_location_assignment PIN_EV4 -to qsfp_serial[1].tx_p[3]

#IA-840F Primary PCIe Interface
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

#set_location_assignment PIN_DB21 -to rzq_2c
#set_location_assignment PIN_D29 -to fpga_cvl_sdp20
#set_location_assignment PIN_L22 -to fpga_cvl_sdp21
#set_location_assignment PIN_N24 -to fpga_cvl_clk_out_n
#set_location_assignment PIN_L24 -to fpga_cvl_clk_out_p
#set_location_assignment PIN_G28 -to fpga_cvl_rmii_clkin
#set_location_assignment PIN_M31 -to fpga_cvl_rmii_txen
#set_location_assignment PIN_G30 -to fpga_cvl_rmii_txd[0]
#set_location_assignment PIN_P31 -to fpga_cvl_rmii_txd[1]
#set_location_assignment PIN_H29 -to fpga_cvl_rmii_rxd[0]
#set_location_assignment PIN_J30 -to fpga_cvl_rmii_rxd[1]
#set_location_assignment PIN_L30 -to fpga_cvl_rmii_crsdv
#set_location_assignment PIN_N30 -to fpga_cvl_rmii_arb_in
#set_location_assignment PIN_F29 -to fpga_cvl_rmii_arb_out
#set_location_assignment PIN_T19 -to fm61_smclk
#set_location_assignment PIN_P19 -to fm61_smdat
#set_location_assignment PIN_H19 -to fpga_cvl_sdp0
#set_location_assignment PIN_F19 -to fpga_cvl_sdp1
#set_location_assignment PIN_J20 -to fpga_cvl_sdp2
#set_location_assignment PIN_G20 -to fpga_cvl_sdp3
#set_location_assignment PIN_H21 -to fpga_cvl_sdp4
#set_location_assignment PIN_F21 -to fpga_cvl_sdp5
#set_location_assignment PIN_J22 -to fpga_cvl_sdp6
#set_location_assignment PIN_G22 -to fpga_cvl_sdp7
#set_location_assignment PIN_C28 -to fpga_cvl_i2cclk[1]
#set_location_assignment PIN_B29 -to fpga_cvl_i2cdat[1]

#On IA-840F we are using USER_CLK for this source as it is a 100Mhz LVDS clock source.
set_location_assignment PIN_A53 -to "SYS_REFCLK(n)"
set_location_assignment PIN_C52 -to SYS_REFCLK

#set_location_assignment PIN_F31 -to fm61_scl
#set_location_assignment PIN_H31 -to fm61_sda

set_instance_assignment -name IO_STANDARD "DIFFERENTIAL LVPECL" -to qsfp_ref_clk
#The following HSSI_PARAMETER settings are from N6000 original source. In the IA-840F cardtest they are not
#included. For now, these are left in as look valid.
set_instance_assignment -name HSSI_PARAMETER "refclk_divider_enable_termination=enable_term" -to qsfp_ref_clk
set_instance_assignment -name HSSI_PARAMETER "refclk_divider_enable_3p3v=disable_3p3v_tol" -to qsfp_ref_clk
set_instance_assignment -name HSSI_PARAMETER "refclk_divider_disable_hysteresis=enable_hyst" -to qsfp_ref_clk
set_instance_assignment -name HSSI_PARAMETER "refclk_divider_input_freq=156250000" -to qsfp_ref_clk
set_instance_assignment -name HSSI_PARAMETER "refclk_divider_powerdown_mode=false" -to qsfp_ref_clk
set_instance_assignment -name HSSI_PARAMETER "refclk_divider_use_as_bti_clock=TRUE" -to qsfp_ref_clk

#set_instance_assignment -name IO_STANDARD "DIFFERENTIAL LVPECL" -to cr3_cpri_refclk_clk[1]
#set_instance_assignment -name HSSI_PARAMETER "refclk_divider_enable_termination=enable_term" -to cr3_cpri_refclk_clk[1]
#set_instance_assignment -name HSSI_PARAMETER "refclk_divider_enable_3p3v=disable_3p3v_tol" -to cr3_cpri_refclk_clk[1]
#set_instance_assignment -name HSSI_PARAMETER "refclk_divider_disable_hysteresis=enable_hyst" -to cr3_cpri_refclk_clk[1]
#set_instance_assignment -name HSSI_PARAMETER "refclk_divider_input_freq=184320000" -to cr3_cpri_refclk_clk[1]
#set_instance_assignment -name HSSI_PARAMETER "refclk_divider_powerdown_mode=false" -to cr3_cpri_refclk_clk[1]
#set_instance_assignment -name HSSI_PARAMETER "refclk_divider_use_as_bti_clock=FALSE" -to cr3_cpri_refclk_clk[1]
#set_instance_assignment -name IO_STANDARD "DIFFERENTIAL LVPECL" -to cr3_cpri_refclk_clk[2]
#set_instance_assignment -name HSSI_PARAMETER "refclk_divider_enable_termination=enable_term" -to cr3_cpri_refclk_clk[2]
#set_instance_assignment -name HSSI_PARAMETER "refclk_divider_enable_3p3v=disable_3p3v_tol" -to cr3_cpri_refclk_clk[2]
#set_instance_assignment -name HSSI_PARAMETER "refclk_divider_disable_hysteresis=enable_hyst" -to cr3_cpri_refclk_clk[2]
#set_instance_assignment -name HSSI_PARAMETER "refclk_divider_input_freq=153600000" -to cr3_cpri_refclk_clk[2]
#set_instance_assignment -name HSSI_PARAMETER "refclk_divider_powerdown_mode=false" -to cr3_cpri_refclk_clk[2]
#set_instance_assignment -name HSSI_PARAMETER "refclk_divider_use_as_bti_clock=FALSE" -to cr3_cpri_refclk_clk[2]
#set_instance_assignment -name IO_STANDARD "DIFFERENTIAL LVPECL" -to cr3_cpri_reflclk_clk[0]
#set_instance_assignment -name HSSI_PARAMETER "refclk_divider_enable_termination=enable_term" -to cr3_cpri_reflclk_clk[0]
#set_instance_assignment -name HSSI_PARAMETER "refclk_divider_enable_3p3v=disable_3p3v_tol" -to cr3_cpri_reflclk_clk[0]
#set_instance_assignment -name HSSI_PARAMETER "refclk_divider_disable_hysteresis=enable_hyst" -to cr3_cpri_reflclk_clk[0]
#set_instance_assignment -name HSSI_PARAMETER "refclk_divider_input_freq=245760000" -to cr3_cpri_reflclk_clk[0]
#set_instance_assignment -name HSSI_PARAMETER "refclk_divider_powerdown_mode=false" -to cr3_cpri_reflclk_clk[0]
#set_instance_assignment -name HSSI_PARAMETER "refclk_divider_use_as_bti_clock=FALSE" -to cr3_cpri_reflclk_clk[0]
#set_instance_assignment -name IO_STANDARD "DIFFERENTIAL LVPECL" -to cr3_cpri_reflclk_clk_184_32m
#set_instance_assignment -name HSSI_PARAMETER "refclk_divider_enable_termination=enable_term" -to cr3_cpri_reflclk_clk_184_32m
#set_instance_assignment -name HSSI_PARAMETER "refclk_divider_enable_3p3v=enable_3p3v_tol" -to cr3_cpri_reflclk_clk_184_32m
#set_instance_assignment -name HSSI_PARAMETER "refclk_divider_disable_hysteresis=enable_hyst" -to cr3_cpri_reflclk_clk_184_32m
#set_instance_assignment -name HSSI_PARAMETER "refclk_divider_input_freq=184320000" -to cr3_cpri_reflclk_clk_184_32m
#set_instance_assignment -name HSSI_PARAMETER "refclk_divider_powerdown_mode=false" -to cr3_cpri_reflclk_clk_184_32m
#set_instance_assignment -name HSSI_PARAMETER "refclk_divider_use_as_bti_clock=FALSE" -to cr3_cpri_reflclk_clk_184_32m
#set_instance_assignment -name IO_STANDARD "DIFFERENTIAL LVPECL" -to cr3_cpri_reflclk_clk_153_6m
#set_instance_assignment -name HSSI_PARAMETER "refclk_divider_enable_termination=enable_term" -to cr3_cpri_reflclk_clk_153_6m
#set_instance_assignment -name HSSI_PARAMETER "refclk_divider_enable_3p3v=enable_3p3v_tol" -to cr3_cpri_reflclk_clk_153_6m
#set_instance_assignment -name HSSI_PARAMETER "refclk_divider_disable_hysteresis=enable_hyst" -to cr3_cpri_reflclk_clk_153_6m
#set_instance_assignment -name HSSI_PARAMETER "refclk_divider_input_freq=153600000" -to cr3_cpri_reflclk_clk_153_6m
#set_instance_assignment -name HSSI_PARAMETER "refclk_divider_powerdown_mode=false" -to cr3_cpri_reflclk_clk_153_6m
#set_instance_assignment -name HSSI_PARAMETER "refclk_divider_use_as_bti_clock=FALSE" -to cr3_cpri_reflclk_clk_153_6m

set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.2-V SSTL" -to hssi_rec_clk[0]
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.2-V SSTL" -to hssi_rec_clk[0](n)
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.2-V SSTL" -to hssi_rec_clk[1]
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.2-V SSTL" -to hssi_rec_clk[1](n)
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.2-V SSTL" -to hssi_rec_clk[2]
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.2-V SSTL" -to hssi_rec_clk[2](n)
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 40 OHM WITH CALIBRATION" -to hssi_rec_clk[0]
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 40 OHM WITH CALIBRATION" -to hssi_rec_clk[0](n)
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 40 OHM WITH CALIBRATION" -to hssi_rec_clk[1]
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 40 OHM WITH CALIBRATION" -to hssi_rec_clk[1](n)
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 40 OHM WITH CALIBRATION" -to hssi_rec_clk[2]
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 40 OHM WITH CALIBRATION" -to hssi_rec_clk[2](n)

#From the IA-840F also need to add
#Note that OCT_3A is now named RZQ_3A. Used for recovered clocks.
set_location_assignment PIN_G52 -to RZQ_3A
set_instance_assignment -name IO_STANDARD "1.2V" -to RZQ_3A
set_instance_assignment -name RZQ_GROUP RZQ_3A -to hssi_rec_clk[0]
set_instance_assignment -name RZQ_GROUP RZQ_3A -to hssi_rec_clk[1]
set_instance_assignment -name RZQ_GROUP RZQ_3A -to hssi_rec_clk[2]
set_instance_assignment -name RZQ_GROUP RZQ_3A -to "hssi_rec_clk[0](n)"
set_instance_assignment -name RZQ_GROUP RZQ_3A -to "hssi_rec_clk[1](n)"
set_instance_assignment -name RZQ_GROUP RZQ_3A -to "hssi_rec_clk[2](n)"
# Agilex only supports the fastest Slew Rate for GPIO with this voltage-referenced standard [UG-20214 2.2.1]
#set_instance_assignment -name SLEW_RATE 2 -to hssi_rec_clk[0]
#set_instance_assignment -name SLEW_RATE 2 -to hssi_rec_clk[1]
#set_instance_assignment -name SLEW_RATE 2 -to hssi_rec_clk[2]
# Select de-emphasis as requested by hardware team:
#set_instance_assignment -name PROGRAMMABLE_DEEMPHASIS LOW_LP -to hssi_rec_clk[0]
#set_instance_assignment -name PROGRAMMABLE_DEEMPHASIS LOW_LP -to hssi_rec_clk[1]
#set_instance_assignment -name PROGRAMMABLE_DEEMPHASIS LOW_LP -to hssi_rec_clk[2]

#set_instance_assignment -name IO_STANDARD "1.2 V" -to b_sel_1pps_inout
#set_instance_assignment -name IO_STANDARD "1.2 V" -to b_shdn_1pps_to_10mhz
#set_instance_assignment -name IO_STANDARD "1.2 V" -to b_shdn_10mhz_in
#set_instance_assignment -name IO_STANDARD "1.2 V" -to b_shdn_10mhz_out
#set_instance_assignment -name SLEW_RATE 0 -to b_sel_1pps_inout
#set_instance_assignment -name SLEW_RATE 0 -to b_shdn_1pps_to_10mhz
#set_instance_assignment -name SLEW_RATE 0 -to b_shdn_10mhz_in
#set_instance_assignment -name SLEW_RATE 0 -to b_shdn_10mhz_out
#set_instance_assignment -name IO_STANDARD "HSSI DIFFERENTIAL I/O" -to cvl_serial_rx_p[*]
#set_instance_assignment -name IO_STANDARD "HSSI DIFFERENTIAL I/O" -to cvl_serial_tx_p[*]
set_instance_assignment -name IO_STANDARD "HSSI DIFFERENTIAL I/O" -to qsfp_serial[*].tx_p[*]
set_instance_assignment -name IO_STANDARD "HSSI DIFFERENTIAL I/O" -to qsfp_serial[*].rx_p[*]
#set_instance_assignment -name IO_STANDARD "1.2 V" -to qsfpa_resetn -entity top
#set_instance_assignment -name IO_STANDARD "1.2 V" -to qsfpa_lpmode -entity top
#set_instance_assignment -name IO_STANDARD "1.2 V" -to qsfpa_modeseln -entity top
#set_instance_assignment -name IO_STANDARD "1.2 V" -to qsfpa_intn -entity top
#set_instance_assignment -name IO_STANDARD "1.2 V" -to qsfpa_modprsln -entity top
#set_instance_assignment -name IO_STANDARD "1.2 V" -to qsfpa_power_good -entity top
#set_instance_assignment -name IO_STANDARD "1.2 V" -to qsfpb_resetn -entity top
#set_instance_assignment -name IO_STANDARD "1.2 V" -to qsfpb_lpmode -entity top
#set_instance_assignment -name IO_STANDARD "1.2 V" -to qsfpb_modeseln -entity top
#set_instance_assignment -name IO_STANDARD "1.2 V" -to qsfpb_intn -entity top
#set_instance_assignment -name IO_STANDARD "1.2 V" -to qsfpb_modprsln -entity top
#set_instance_assignment -name IO_STANDARD "1.2 V" -to qsfpb_power_good -entity top
#set_instance_assignment -name IO_STANDARD "1.2 V" -to qsfpa_i2c_scl -entity top
#set_instance_assignment -name IO_STANDARD "1.2 V" -to qsfpa_i2c_sda -entity top
#set_instance_assignment -name IO_STANDARD "1.2 V" -to qsfpb_i2c_scl -entity top
#set_instance_assignment -name IO_STANDARD "1.2 V" -to qsfpb_i2c_sda -entity top
#set_instance_assignment -name SLEW_RATE 0 -to qsfpa_resetn -entity top
#set_instance_assignment -name SLEW_RATE 0 -to qsfpa_lpmode -entity top
#set_instance_assignment -name SLEW_RATE 0 -to qsfpa_modeseln -entity top
#set_instance_assignment -name SLEW_RATE 0 -to qsfpb_resetn -entity top
#set_instance_assignment -name SLEW_RATE 0 -to qsfpb_lpmode -entity top
#set_instance_assignment -name SLEW_RATE 0 -to qsfpb_modeseln -entity top
#set_instance_assignment -name SLEW_RATE 0 -to qsfpa_i2c_scl -entity top
#set_instance_assignment -name SLEW_RATE 0 -to qsfpa_i2c_sda -entity top
#set_instance_assignment -name SLEW_RATE 0 -to qsfpb_i2c_scl -entity top
#set_instance_assignment -name SLEW_RATE 0 -to qsfpb_i2c_sda -entity top
#set_instance_assignment -name IO_STANDARD "1.2 V" -to qsfpa_act_g -entity top
#set_instance_assignment -name IO_STANDARD "1.2 V" -to qsfpa_act_r -entity top
#set_instance_assignment -name IO_STANDARD "1.2 V" -to qsfpb_act_g -entity top
#set_instance_assignment -name IO_STANDARD "1.2 V" -to qsfpb_act_r -entity top
#set_instance_assignment -name IO_STANDARD "1.2 V" -to qsfpa_speed_g -entity top
#set_instance_assignment -name IO_STANDARD "1.2 V" -to qsfpa_speed_y -entity top
#set_instance_assignment -name IO_STANDARD "1.2 V" -to qsfpb_speed_g -entity top
#set_instance_assignment -name IO_STANDARD "1.2 V" -to qsfpb_speed_y -entity top
#set_instance_assignment -name SLEW_RATE 0 -to qsfpa_act_g -entity top
#set_instance_assignment -name SLEW_RATE 0 -to qsfpa_act_r -entity top
#set_instance_assignment -name SLEW_RATE 0 -to qsfpb_act_g -entity top
#set_instance_assignment -name SLEW_RATE 0 -to qsfpb_act_r -entity top
#set_instance_assignment -name SLEW_RATE 0 -to qsfpa_speed_g -entity top
#set_instance_assignment -name SLEW_RATE 0 -to qsfpa_speed_y -entity top
#set_instance_assignment -name SLEW_RATE 0 -to qsfpb_speed_g -entity top
#set_instance_assignment -name SLEW_RATE 0 -to qsfpb_speed_y -entity top
#set_instance_assignment -name IO_STANDARD "TRUE DIFFERENTIAL SIGNALING" -to fpga_pcie_refclk3_100m
#set_instance_assignment -name IO_STANDARD "HIGH SPEED DIFFERENTIAL I/O" -to PCIE_RX_P
#set_instance_assignment -name IO_STANDARD "HIGH SPEED DIFFERENTIAL I/O" -to PCIE_TX_P

set_instance_assignment -name IO_STANDARD "TRUE DIFFERENTIAL SIGNALING" -to SYS_REFCLK
#Not used on IA-840F ref
#set_instance_assignment -name INPUT_TERMINATION DIFFERENTIAL -to SYS_REFCLK

#set_instance_assignment -name IO_STANDARD "1.2 V" -to fpga_qspi_cs_n
#set_instance_assignment -name IO_STANDARD "1.2 V" -to fpga_qspi_d
#set_instance_assignment -name IO_STANDARD "1.2 V" -to fpga_qspi_oe
#set_instance_assignment -name IO_STANDARD "1.2 V" -to fpga_qspi_clk
#set_instance_assignment -name SLEW_RATE 0 -to fpga_qspi_cs_n
#set_instance_assignment -name SLEW_RATE 0 -to fpga_qspi_d
#set_instance_assignment -name SLEW_RATE 0 -to fpga_qspi_oe
#set_instance_assignment -name SLEW_RATE 0 -to fpga_qspi_clk
#set_instance_assignment -name IO_STANDARD "1.2 V" -to fpga_m10_ibus
#set_instance_assignment -name SLEW_RATE 0 -to fpga_m10_ibus
#set_instance_assignment -name IO_STANDARD "1.2 V" -to fpga_fabric_reset_n
#set_instance_assignment -name IO_STANDARD "1.2 V" -to fpga_seu_error
#set_instance_assignment -name SLEW_RATE 0 -to fpga_seu_error
#set_instance_assignment -name IO_STANDARD "1.2 V" -to fpga_cvl_sdp20
#set_instance_assignment -name IO_STANDARD "1.2 V" -to fpga_cvl_sdp21
#set_instance_assignment -name IO_STANDARD "1.2 V" -to fpga_cvl_clk_out_n
#set_instance_assignment -name IO_STANDARD "1.2 V" -to fpga_cvl_clk_out_p
#set_instance_assignment -name IO_STANDARD "1.2 V" -to fpga_cvl_rmii_clkin
#set_instance_assignment -name IO_STANDARD "1.2 V" -to fpga_cvl_rmii_txen
#set_instance_assignment -name IO_STANDARD "1.2 V" -to fpga_cvl_rmii_txd
#set_instance_assignment -name IO_STANDARD "1.2 V" -to fpga_cvl_rmii_rxd
#set_instance_assignment -name IO_STANDARD "1.2 V" -to fpga_cvl_rmii_crsdv
#set_instance_assignment -name IO_STANDARD "1.2 V" -to fpga_cvl_rmii_arb_in
#set_instance_assignment -name IO_STANDARD "1.2 V" -to fpga_cvl_rmii_arb_out
#set_instance_assignment -name IO_STANDARD "1.2 V" -to rmii_en
#set_instance_assignment -name IO_STANDARD "1.2 V" -to fpga_cvl_sdp0
#set_instance_assignment -name IO_STANDARD "1.2 V" -to fpga_cvl_sdp1
#set_instance_assignment -name IO_STANDARD "1.2 V" -to fpga_cvl_sdp2
#set_instance_assignment -name IO_STANDARD "1.2 V" -to fpga_cvl_sdp3
#set_instance_assignment -name IO_STANDARD "1.2 V" -to fpga_cvl_sdp4
#set_instance_assignment -name IO_STANDARD "1.2 V" -to fpga_cvl_sdp5
#set_instance_assignment -name IO_STANDARD "1.2 V" -to fpga_cvl_sdp6
#set_instance_assignment -name IO_STANDARD "1.2 V" -to fpga_cvl_sdp7
#set_instance_assignment -name IO_STANDARD "1.2 V" -to fpga_cvl_i2cclk[1]
#set_instance_assignment -name IO_STANDARD "1.2 V" -to fpga_cvl_i2cdat[1]
#set_instance_assignment -name SLEW_RATE 0 -to fpga_cvl_sdp20
#set_instance_assignment -name SLEW_RATE 0 -to fpga_cvl_sdp21
#set_instance_assignment -name SLEW_RATE 0 -to fpga_cvl_rmii_txen
#set_instance_assignment -name SLEW_RATE 0 -to fpga_cvl_rmii_txd
#set_instance_assignment -name SLEW_RATE 0 -to fpga_cvl_rmii_arb_in
#set_instance_assignment -name SLEW_RATE 0 -to rmii_en
#set_instance_assignment -name SLEW_RATE 0 -to fpga_cvl_sdp0
#set_instance_assignment -name SLEW_RATE 0 -to fpga_cvl_sdp1
#set_instance_assignment -name SLEW_RATE 0 -to fpga_cvl_sdp2
#set_instance_assignment -name SLEW_RATE 0 -to fpga_cvl_sdp3
#set_instance_assignment -name SLEW_RATE 0 -to fpga_cvl_sdp4
#set_instance_assignment -name SLEW_RATE 0 -to fpga_cvl_sdp5
#set_instance_assignment -name SLEW_RATE 0 -to fpga_cvl_sdp6
#set_instance_assignment -name SLEW_RATE 0 -to fpga_cvl_sdp7
#set_instance_assignment -name SLEW_RATE 0 -to fpga_cvl_i2cclk[1]
#set_instance_assignment -name SLEW_RATE 0 -to fpga_cvl_i2cdat[1]
#set_instance_assignment -name IO_STANDARD "1.2 V" -to rmii_crs_dv
#set_instance_assignment -name IO_STANDARD "1.2 V" -to rmii_ref_clk
#set_instance_assignment -name IO_STANDARD "1.2 V" -to rmii_rxd
#set_instance_assignment -name IO_STANDARD "1.2 V" -to rmii_rxer
#set_instance_assignment -name IO_STANDARD "1.2 V" -to rmii_txd
#set_instance_assignment -name IO_STANDARD "1.2 V" -to rmii_tx_en
#set_instance_assignment -name IO_STANDARD "1.2 V" -to arb_in
#set_instance_assignment -name IO_STANDARD "1.2 V" -to arb_out
#set_instance_assignment -name SLEW_RATE 0 -to rmii_txd
#set_instance_assignment -name SLEW_RATE 0 -to arb_in
#set_instance_assignment -name IO_STANDARD "1.2 V" -to b_1pps_fpga_clk
#set_instance_assignment -name IO_STANDARD "TRUE DIFFERENTIAL SIGNALING" -to tod_fpga_clk
#set_instance_assignment -name IO_STANDARD "1.2 V" -to fm61_testio_d
#set_instance_assignment -name IO_STANDARD "1.2 V" -to fm61_testio_clkout
#set_instance_assignment -name IO_STANDARD "1.2 V" -to fm61_testio_clkin
#set_instance_assignment -name SLEW_RATE 0 -to fm61_testio_d
#set_instance_assignment -name SLEW_RATE 0 -to fm61_testio_clkout
#set_instance_assignment -name IO_STANDARD "1.2 V" -to b_m10_crc_error
#set_instance_assignment -name IO_STANDARD "1.2 V" -to m10_conf_done
#set_instance_assignment -name IO_STANDARD "1.2 V" -to b_fpga_hps_zl_gpout
#set_instance_assignment -name IO_STANDARD "1.2 V" -to fm61_smclk
#set_instance_assignment -name IO_STANDARD "1.2 V" -to fm61_smdat
#set_instance_assignment -name SLEW_RATE 0 -to fm61_smdat
#set_instance_assignment -name IO_STANDARD "1.2 V" -to fm61_scl
#set_instance_assignment -name IO_STANDARD "1.2 V" -to fm61_sda
#set_instance_assignment -name SLEW_RATE 0 -to fm61_scl
#set_instance_assignment -name SLEW_RATE 0 -to fm61_sda

# BittWare BMC top level pins.
# BMC Interface
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


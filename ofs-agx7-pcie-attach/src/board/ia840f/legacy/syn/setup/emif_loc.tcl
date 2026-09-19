# Copyright (C) 2020 Intel Corporation.
# SPDX-License-Identifier: MIT

#
# Description
#-----------------------------------------------------------------------------
#
# Memory pin and location assignments
#
#-----------------------------------------------------------------------------

# YC 3/29/2024
# Add 2nd bank of DDR (RDIMM)
##################################################
# DDR4 SDRAM Bank0 Pins to support x8 16GB DIMM
##################################################

#set_location_assignment PIN_GJ52 -to ddr4_mem[1].dq[68]
#set_location_assignment PIN_GG53 -to ddr4_mem[1].dq[69]
#set_location_assignment PIN_GP52 -to ddr4_mem[1].dq[70]
#set_location_assignment PIN_GU53 -to ddr4_mem[1].dq[71]
#set_location_assignment PIN_GJ50 -to ddr4_mem[1].dbi_n[8]	  
#set_location_assignment PIN_GP50 -to ddr4_mem[1].dqs[8]	  
#set_location_assignment PIN_GU51 -to ddr4_mem[1].dqs_n[8]	  
#set_location_assignment PIN_GJ48 -to ddr4_mem[1].dq[64]
#set_location_assignment PIN_GG49 -to ddr4_mem[1].dq[65]
#set_location_assignment PIN_GP48 -to ddr4_mem[1].dq[66]
#set_location_assignment PIN_GU49 -to ddr4_mem[1].dq[67]
set_location_assignment PIN_GW52 -to ddr4_mem[1].ba[1]
set_location_assignment PIN_HB53 -to ddr4_mem[1].bg[0]
set_location_assignment PIN_HH52 -to ddr4_mem[1].alert_n[0]
set_location_assignment PIN_HF53 -to ddr4_mem[1].ba[0]
set_location_assignment PIN_GW50 -to ddr4_mem[1].a[15]
set_location_assignment PIN_HB51 -to ddr4_mem[1].a[16]
set_location_assignment PIN_HH50 -to ddr4_mem[1].a[13]
set_location_assignment PIN_HF51 -to ddr4_mem[1].a[14]
set_location_assignment PIN_GW48 -to ddr4_mem[1].oct_rzqin
set_location_assignment PIN_HB49 -to ddr4_mem[1].a[12]
set_location_assignment PIN_HH48 -to ddr4_mem[1].ref_clk
set_location_assignment PIN_GJ46 -to ddr4_mem[1].a[10]
set_location_assignment PIN_GG47 -to ddr4_mem[1].a[11]
set_location_assignment PIN_GP46 -to ddr4_mem[1].a[8]
set_location_assignment PIN_GU47 -to ddr4_mem[1].a[9]
set_location_assignment PIN_GJ44 -to ddr4_mem[1].a[6]
set_location_assignment PIN_GG45 -to ddr4_mem[1].a[7]
set_location_assignment PIN_GP44 -to ddr4_mem[1].a[4]
set_location_assignment PIN_GU45 -to ddr4_mem[1].a[5]
set_location_assignment PIN_GJ42 -to ddr4_mem[1].a[2]
set_location_assignment PIN_GG43 -to ddr4_mem[1].a[3]
set_location_assignment PIN_GP42 -to ddr4_mem[1].a[0]
set_location_assignment PIN_GU43 -to ddr4_mem[1].a[1]
set_location_assignment PIN_HB47 -to ddr4_mem[1].par
set_location_assignment PIN_HH46 -to ddr4_mem[1].ck
set_location_assignment PIN_HF47 -to ddr4_mem[1].ck_n
set_location_assignment PIN_GW44 -to ddr4_mem[1].cke
set_location_assignment PIN_HH44 -to ddr4_mem[1].odt
set_location_assignment PIN_GW42 -to ddr4_mem[1].cs_n
set_location_assignment PIN_HB43 -to ddr4_mem[1].act_n
set_location_assignment PIN_HH42 -to ddr4_mem[1].bg[1]
set_location_assignment PIN_HF43 -to ddr4_mem[1].reset_n
set_location_assignment PIN_FK52 -to ddr4_mem[1].dq[63]
set_location_assignment PIN_FH53 -to ddr4_mem[1].dq[62]
set_location_assignment PIN_FP52 -to ddr4_mem[1].dq[61]
set_location_assignment PIN_FT53 -to ddr4_mem[1].dq[60]
set_location_assignment PIN_FK50 -to ddr4_mem[1].dbi_n[7]
set_location_assignment PIN_FP50 -to ddr4_mem[1].dqs[7]
set_location_assignment PIN_FT51 -to ddr4_mem[1].dqs_n[7]
set_location_assignment PIN_FK48 -to ddr4_mem[1].dq[59]
set_location_assignment PIN_FH49 -to ddr4_mem[1].dq[58]
set_location_assignment PIN_FP48 -to ddr4_mem[1].dq[57]
set_location_assignment PIN_FT49 -to ddr4_mem[1].dq[56]
set_location_assignment PIN_FV52 -to ddr4_mem[1].dq[55]
set_location_assignment PIN_FY53 -to ddr4_mem[1].dq[54]
set_location_assignment PIN_GE52 -to ddr4_mem[1].dq[53]
set_location_assignment PIN_GC53 -to ddr4_mem[1].dq[52]
set_location_assignment PIN_FV50 -to ddr4_mem[1].dbi_n[6]
set_location_assignment PIN_GE50 -to ddr4_mem[1].dqs[6]
set_location_assignment PIN_GC51 -to ddr4_mem[1].dqs_n[6]
set_location_assignment PIN_FV48 -to ddr4_mem[1].dq[51]
set_location_assignment PIN_FY49 -to ddr4_mem[1].dq[50]
set_location_assignment PIN_GE48 -to ddr4_mem[1].dq[49]
set_location_assignment PIN_GC49 -to ddr4_mem[1].dq[48]
set_location_assignment PIN_FK46 -to ddr4_mem[1].dq[47]
set_location_assignment PIN_FH47 -to ddr4_mem[1].dq[46]
set_location_assignment PIN_FP46 -to ddr4_mem[1].dq[45]
set_location_assignment PIN_FT47 -to ddr4_mem[1].dq[44]
set_location_assignment PIN_FK44 -to ddr4_mem[1].dbi_n[5]
set_location_assignment PIN_FP44 -to ddr4_mem[1].dqs[5]
set_location_assignment PIN_FT45 -to ddr4_mem[1].dqs_n[5]
set_location_assignment PIN_FK42 -to ddr4_mem[1].dq[43]
set_location_assignment PIN_FH43 -to ddr4_mem[1].dq[42]
set_location_assignment PIN_FP42 -to ddr4_mem[1].dq[41]
set_location_assignment PIN_FT43 -to ddr4_mem[1].dq[40]
set_location_assignment PIN_FV46 -to ddr4_mem[1].dq[39]
set_location_assignment PIN_FY47 -to ddr4_mem[1].dq[38]
set_location_assignment PIN_GE46 -to ddr4_mem[1].dq[37]
set_location_assignment PIN_GC47 -to ddr4_mem[1].dq[36]
set_location_assignment PIN_FV44 -to ddr4_mem[1].dbi_n[4]
set_location_assignment PIN_GE44 -to ddr4_mem[1].dqs[4]
set_location_assignment PIN_GC45 -to ddr4_mem[1].dqs_n[4]
set_location_assignment PIN_FV42 -to ddr4_mem[1].dq[35]
set_location_assignment PIN_FY43 -to ddr4_mem[1].dq[34]
set_location_assignment PIN_GE42 -to ddr4_mem[1].dq[33]
set_location_assignment PIN_GC43 -to ddr4_mem[1].dq[32]
set_location_assignment PIN_GG31 -to ddr4_mem[1].dq[4]
set_location_assignment PIN_GJ30 -to ddr4_mem[1].dq[5]
set_location_assignment PIN_GU31 -to ddr4_mem[1].dq[6]
set_location_assignment PIN_GP30 -to ddr4_mem[1].dq[7]
set_location_assignment PIN_GG33 -to ddr4_mem[1].dbi_n[0]	
set_location_assignment PIN_GU33 -to ddr4_mem[1].dqs[0]	
set_location_assignment PIN_GP32 -to ddr4_mem[1].dqs_n[0]	
set_location_assignment PIN_GG35 -to ddr4_mem[1].dq[0]
set_location_assignment PIN_GJ34 -to ddr4_mem[1].dq[1]
set_location_assignment PIN_GU35 -to ddr4_mem[1].dq[2]
set_location_assignment PIN_GP34 -to ddr4_mem[1].dq[3]
set_location_assignment PIN_HB31 -to ddr4_mem[1].dq[12]
set_location_assignment PIN_GW30 -to ddr4_mem[1].dq[13]
set_location_assignment PIN_HF31 -to ddr4_mem[1].dq[14]
set_location_assignment PIN_HH30 -to ddr4_mem[1].dq[15]
set_location_assignment PIN_HB33 -to ddr4_mem[1].dbi_n[1] 
set_location_assignment PIN_HF33 -to ddr4_mem[1].dqs[1] 
set_location_assignment PIN_HH32 -to ddr4_mem[1].dqs_n[1] 
set_location_assignment PIN_HB35 -to ddr4_mem[1].dq[8]
set_location_assignment PIN_GW34 -to ddr4_mem[1].dq[9]
set_location_assignment PIN_HF35 -to ddr4_mem[1].dq[10]
set_location_assignment PIN_HH34 -to ddr4_mem[1].dq[11]
set_location_assignment PIN_GG37 -to ddr4_mem[1].dq[20]
set_location_assignment PIN_GJ36 -to ddr4_mem[1].dq[21]
set_location_assignment PIN_GU37 -to ddr4_mem[1].dq[22]
set_location_assignment PIN_GP36 -to ddr4_mem[1].dq[23]
set_location_assignment PIN_GG39 -to ddr4_mem[1].dbi_n[2]	
set_location_assignment PIN_GU39 -to ddr4_mem[1].dqs[2]	
set_location_assignment PIN_GP38 -to ddr4_mem[1].dqs_n[2]	
set_location_assignment PIN_GG41 -to ddr4_mem[1].dq[16]
set_location_assignment PIN_GJ40 -to ddr4_mem[1].dq[17]
set_location_assignment PIN_GU41 -to ddr4_mem[1].dq[18]
set_location_assignment PIN_GP40 -to ddr4_mem[1].dq[19]
set_location_assignment PIN_HB37 -to ddr4_mem[1].dq[28]
set_location_assignment PIN_GW36 -to ddr4_mem[1].dq[29]
set_location_assignment PIN_HF37 -to ddr4_mem[1].dq[30]
set_location_assignment PIN_HH36 -to ddr4_mem[1].dq[31]
set_location_assignment PIN_HB39 -to ddr4_mem[1].dbi_n[3]	
set_location_assignment PIN_HF39 -to ddr4_mem[1].dqs[3]	
set_location_assignment PIN_HH38 -to ddr4_mem[1].dqs_n[3]	
set_location_assignment PIN_HB41 -to ddr4_mem[1].dq[24]
set_location_assignment PIN_GW40 -to ddr4_mem[1].dq[25]
set_location_assignment PIN_HF41 -to ddr4_mem[1].dq[26]
set_location_assignment PIN_HH40 -to ddr4_mem[1].dq[27]

# For the IA-840F port, on the EAU cards we are limited to banks that support
# x8 only which is the component banks only. One of these is used for the HPS.
# P1 (component bank) is going to be mapped to ddr4_mem[0].
# Other banks will be commented out.
# P3 bank is the component bank used for the HPS.

#-----------------------------------------------------------------------------
# EMIF CH0, now mapped to P1 component memory bank
#-----------------------------------------------------------------------------
set_location_assignment PIN_HH22 -to "ddr4_mem[0].ref_clk(n)"
set_location_assignment PIN_HF23 -to ddr4_mem[0].ref_clk
set_location_assignment PIN_GW18 -to ddr4_mem[0].bg[0]
#Addition of bg[1] for ia-840f pinmap
set_location_assignment PIN_HF29 -to ddr4_mem[0].bg[1]
set_location_assignment PIN_HB19 -to ddr4_mem[0].ba[1]
set_location_assignment PIN_HH18 -to ddr4_mem[0].ba[0]
set_location_assignment PIN_HF19 -to ddr4_mem[0].alert_n
set_location_assignment PIN_GW20 -to ddr4_mem[0].a[16]
set_location_assignment PIN_HB21 -to ddr4_mem[0].a[15]
set_location_assignment PIN_HH20 -to ddr4_mem[0].a[14]
set_location_assignment PIN_HF21 -to ddr4_mem[0].a[13]
set_location_assignment PIN_GW22 -to ddr4_mem[0].a[12]
set_location_assignment PIN_HB23 -to ddr4_mem[0].oct_rzqin
set_location_assignment PIN_GJ24 -to ddr4_mem[0].a[11]
set_location_assignment PIN_GG25 -to ddr4_mem[0].a[10]
set_location_assignment PIN_GP24 -to ddr4_mem[0].a[9]
set_location_assignment PIN_GU25 -to ddr4_mem[0].a[8]
set_location_assignment PIN_GJ26 -to ddr4_mem[0].a[7]
set_location_assignment PIN_GG27 -to ddr4_mem[0].a[6]
set_location_assignment PIN_GP26 -to ddr4_mem[0].a[5]
set_location_assignment PIN_GU27 -to ddr4_mem[0].a[4]
set_location_assignment PIN_GJ28 -to ddr4_mem[0].a[3]
set_location_assignment PIN_GG29 -to ddr4_mem[0].a[2]
set_location_assignment PIN_GP28 -to ddr4_mem[0].a[1]
set_location_assignment PIN_GU29 -to ddr4_mem[0].a[0]
set_location_assignment PIN_GW24 -to ddr4_mem[0].par
#set_location_assignment PIN_HB25 -to ddr4_mem[0].cs_n[1]
set_location_assignment PIN_HH24 -to ddr4_mem[0].ck_n
set_location_assignment PIN_HF25 -to ddr4_mem[0].ck
set_location_assignment PIN_HB27 -to ddr4_mem[0].cke
set_location_assignment PIN_HF27 -to ddr4_mem[0].odt
set_location_assignment PIN_GW28 -to ddr4_mem[0].act_n
set_location_assignment PIN_HB29 -to ddr4_mem[0].cs_n[0]
set_location_assignment PIN_HH28 -to ddr4_mem[0].reset_n

# CH0 DQS0
set_location_assignment PIN_FH21 -to ddr4_mem[0].dbi_n[0]
set_location_assignment PIN_FP20 -to ddr4_mem[0].dqs_n[0]
set_location_assignment PIN_FT21 -to ddr4_mem[0].dqs[0]
set_location_assignment PIN_FH19 -to ddr4_mem[0].dq[0]
set_location_assignment PIN_FK22 -to ddr4_mem[0].dq[1]
set_location_assignment PIN_FK18 -to ddr4_mem[0].dq[2]
set_location_assignment PIN_FT19 -to ddr4_mem[0].dq[3]
set_location_assignment PIN_FH23 -to ddr4_mem[0].dq[4]
set_location_assignment PIN_FP22 -to ddr4_mem[0].dq[5]
set_location_assignment PIN_FP18 -to ddr4_mem[0].dq[6]
set_location_assignment PIN_FT23 -to ddr4_mem[0].dq[7]

# CH0 DQS1
set_location_assignment PIN_FY21 -to ddr4_mem[0].dbi_n[1]
set_location_assignment PIN_GE20 -to ddr4_mem[0].dqs_n[1]
set_location_assignment PIN_GC21 -to ddr4_mem[0].dqs[1]
set_location_assignment PIN_GC19 -to ddr4_mem[0].dq[8]
set_location_assignment PIN_FV22 -to ddr4_mem[0].dq[9]
set_location_assignment PIN_GE18 -to ddr4_mem[0].dq[10]
set_location_assignment PIN_GE22 -to ddr4_mem[0].dq[11]
set_location_assignment PIN_FY19 -to ddr4_mem[0].dq[12]
set_location_assignment PIN_FY23 -to ddr4_mem[0].dq[13]
set_location_assignment PIN_FV18 -to ddr4_mem[0].dq[14]
set_location_assignment PIN_GC23 -to ddr4_mem[0].dq[15]

# CH0 DQS2
set_location_assignment PIN_FH27 -to ddr4_mem[0].dbi_n[2]
set_location_assignment PIN_FP26 -to ddr4_mem[0].dqs_n[2]
set_location_assignment PIN_FT27 -to ddr4_mem[0].dqs[2]
set_location_assignment PIN_FH25 -to ddr4_mem[0].dq[16]
set_location_assignment PIN_FP28 -to ddr4_mem[0].dq[17]
set_location_assignment PIN_FT25 -to ddr4_mem[0].dq[18]
set_location_assignment PIN_FK28 -to ddr4_mem[0].dq[19]
set_location_assignment PIN_FK24 -to ddr4_mem[0].dq[20]
set_location_assignment PIN_FT29 -to ddr4_mem[0].dq[21]
set_location_assignment PIN_FP24 -to ddr4_mem[0].dq[22]
set_location_assignment PIN_FH29 -to ddr4_mem[0].dq[23]

# CH0 DQS3
set_location_assignment PIN_FY27 -to ddr4_mem[0].dbi_n[3]
set_location_assignment PIN_GE26 -to ddr4_mem[0].dqs_n[3]
set_location_assignment PIN_GC27 -to ddr4_mem[0].dqs[3]
set_location_assignment PIN_FY25 -to ddr4_mem[0].dq[24]
set_location_assignment PIN_GC29 -to ddr4_mem[0].dq[25]
set_location_assignment PIN_GC25 -to ddr4_mem[0].dq[26]
set_location_assignment PIN_FY29 -to ddr4_mem[0].dq[27]
set_location_assignment PIN_FV24 -to ddr4_mem[0].dq[28]
set_location_assignment PIN_FV28 -to ddr4_mem[0].dq[29]
set_location_assignment PIN_GE24 -to ddr4_mem[0].dq[30]
set_location_assignment PIN_GE28 -to ddr4_mem[0].dq[31]

# New groups as ia-840f is x72 bank
# CH0  DQS4
set_location_assignment PIN_FH33 -to ddr4_mem[0].dbi_n[4]
set_location_assignment PIN_FP32 -to ddr4_mem[0].dqs_n[4]
set_location_assignment PIN_FT33 -to ddr4_mem[0].dqs[4]
set_location_assignment PIN_FT31 -to ddr4_mem[0].dq[32]
set_location_assignment PIN_FH35 -to ddr4_mem[0].dq[33]
set_location_assignment PIN_FH31 -to ddr4_mem[0].dq[34]
set_location_assignment PIN_FP34 -to ddr4_mem[0].dq[35]
set_location_assignment PIN_FK30 -to ddr4_mem[0].dq[36]
set_location_assignment PIN_FT35 -to ddr4_mem[0].dq[37]
set_location_assignment PIN_FP30 -to ddr4_mem[0].dq[38]
set_location_assignment PIN_FK34 -to ddr4_mem[0].dq[39]

# New groups as ia-840f is x72 bank
# CH0  DQS5
set_location_assignment PIN_FY33 -to ddr4_mem[0].dbi_n[5]
set_location_assignment PIN_GE32 -to ddr4_mem[0].dqs_n[5]
set_location_assignment PIN_GC33 -to ddr4_mem[0].dqs[5]
set_location_assignment PIN_FY31 -to ddr4_mem[0].dq[40]
set_location_assignment PIN_FV34 -to ddr4_mem[0].dq[41]
set_location_assignment PIN_GC31 -to ddr4_mem[0].dq[42]
set_location_assignment PIN_GC35 -to ddr4_mem[0].dq[43]
set_location_assignment PIN_FV30 -to ddr4_mem[0].dq[44]
set_location_assignment PIN_FY35 -to ddr4_mem[0].dq[45]
set_location_assignment PIN_GE30 -to ddr4_mem[0].dq[46]
set_location_assignment PIN_GE34 -to ddr4_mem[0].dq[47]

# New groups as ia-840f is x72 bank
# CH0  DQS6
set_location_assignment PIN_FH39 -to ddr4_mem[0].dbi_n[6]
set_location_assignment PIN_FP38 -to ddr4_mem[0].dqs_n[6]
set_location_assignment PIN_FT39 -to ddr4_mem[0].dqs[6]
set_location_assignment PIN_FT41 -to ddr4_mem[0].dq[48]
set_location_assignment PIN_FH37 -to ddr4_mem[0].dq[49]
set_location_assignment PIN_FP40 -to ddr4_mem[0].dq[50]
set_location_assignment PIN_FK40 -to ddr4_mem[0].dq[51]
set_location_assignment PIN_FP36 -to ddr4_mem[0].dq[52]
set_location_assignment PIN_FK36 -to ddr4_mem[0].dq[53]
set_location_assignment PIN_FT37 -to ddr4_mem[0].dq[54]
set_location_assignment PIN_FH41 -to ddr4_mem[0].dq[55]

# New groups as ia-840f is x72 bank
# CH0  DQS7
set_location_assignment PIN_FV38 -to ddr4_mem[0].dbi_n[7]
set_location_assignment PIN_GC39 -to ddr4_mem[0].dqs_n[7]
set_location_assignment PIN_GE38 -to ddr4_mem[0].dqs[7]
set_location_assignment PIN_GC37 -to ddr4_mem[0].dq[56]
set_location_assignment PIN_FY41 -to ddr4_mem[0].dq[57]
set_location_assignment PIN_FY37 -to ddr4_mem[0].dq[58]
set_location_assignment PIN_GC41 -to ddr4_mem[0].dq[59]
set_location_assignment PIN_FV36 -to ddr4_mem[0].dq[60]
set_location_assignment PIN_FV40 -to ddr4_mem[0].dq[61]
set_location_assignment PIN_GE36 -to ddr4_mem[0].dq[62]
set_location_assignment PIN_GE40 -to ddr4_mem[0].dq[63]

# New groups as ia-840f is x72 bank
# CH0  DQS8
#set_location_assignment PIN_GG21 -to ddr4_ecc_mem[0].dbi_n[8]
#set_location_assignment PIN_GP20 -to ddr4_ecc_mem[0].dqs_n[8]
#set_location_assignment PIN_GU21 -to ddr4_ecc_mem[0].dqs[8]
#set_location_assignment PIN_GP18 -to ddr4_ecc_mem[0].dq[64]
#set_location_assignment PIN_GP22 -to ddr4_ecc_mem[0].dq[65]
#set_location_assignment PIN_GU19 -to ddr4_ecc_mem[0].dq[66]
#set_location_assignment PIN_GJ22 -to ddr4_ecc_mem[0].dq[67]
#set_location_assignment PIN_GJ18 -to ddr4_ecc_mem[0].dq[68]
#set_location_assignment PIN_GU23 -to ddr4_ecc_mem[0].dq[69]
#set_location_assignment PIN_GG19 -to ddr4_ecc_mem[0].dq[70]
#set_location_assignment PIN_GG23 -to ddr4_ecc_mem[0].dq[71]


#-----------------------------------------------------------------------------
# EMIF CH1, NOT USED ON IA-840F EAU REV0 BOARD PORTING
#-----------------------------------------------------------------------------
#set_location_assignment PIN_CL38 -to "ddr4_mem[1].ref_clk(n)"
#set_location_assignment PIN_CN38 -to ddr4_mem[1].ref_clk
#set_location_assignment PIN_CK43 -to ddr4_mem[1].bg[0]
#set_location_assignment PIN_CM43 -to ddr4_mem[1].ba[1]
#set_location_assignment PIN_CL42 -to ddr4_mem[1].ba[0]
#set_location_assignment PIN_CN42 -to ddr4_mem[1].alert_n
#set_location_assignment PIN_CK41 -to ddr4_mem[1].a[16]
#set_location_assignment PIN_CM41 -to ddr4_mem[1].a[15]
#set_location_assignment PIN_CL40 -to ddr4_mem[1].a[14]
#set_location_assignment PIN_CN40 -to ddr4_mem[1].a[13]
#set_location_assignment PIN_CK39 -to ddr4_mem[1].a[12]
#set_location_assignment PIN_CM39 -to ddr4_mem[1].oct_rzqin
#set_location_assignment PIN_CE36 -to ddr4_mem[1].a[11]
#set_location_assignment PIN_CG36 -to ddr4_mem[1].a[10]
#set_location_assignment PIN_CF35 -to ddr4_mem[1].a[9]
#set_location_assignment PIN_CH35 -to ddr4_mem[1].a[8]
#set_location_assignment PIN_CE34 -to ddr4_mem[1].a[7]
#set_location_assignment PIN_CG34 -to ddr4_mem[1].a[6]
#set_location_assignment PIN_CF33 -to ddr4_mem[1].a[5]
#set_location_assignment PIN_CH33 -to ddr4_mem[1].a[4]
#set_location_assignment PIN_CE32 -to ddr4_mem[1].a[3]
#set_location_assignment PIN_CG32 -to ddr4_mem[1].a[2]
#set_location_assignment PIN_CF31 -to ddr4_mem[1].a[1]
#set_location_assignment PIN_CH31 -to ddr4_mem[1].a[0]
#set_location_assignment PIN_CL36 -to ddr4_mem[1].par
#set_location_assignment PIN_CN36 -to ddr4_mem[1].cs_n[1]
#set_location_assignment PIN_CK35 -to ddr4_mem[1].ck_n
#set_location_assignment PIN_CM35 -to ddr4_mem[1].ck
#set_location_assignment PIN_CN34 -to ddr4_mem[1].cke
#set_location_assignment PIN_CM33 -to ddr4_mem[1].odt
#set_location_assignment PIN_CL32 -to ddr4_mem[1].act_n
#set_location_assignment PIN_CN32 -to ddr4_mem[1].cs_n[0]
#set_location_assignment PIN_CK31 -to ddr4_mem[1].reset_n
#
# CH1 DQS0
#set_location_assignment PIN_CH41 -to ddr4_mem[1].dbi_n[0]
#set_location_assignment PIN_CE40 -to ddr4_mem[1].dqs_n[0]
#set_location_assignment PIN_CG40 -to ddr4_mem[1].dqs[0]
#set_location_assignment PIN_CF43 -to ddr4_mem[1].dq[3]
#set_location_assignment PIN_CH43 -to ddr4_mem[1].dq[5]
#set_location_assignment PIN_CE42 -to ddr4_mem[1].dq[2]
#set_location_assignment PIN_CG42 -to ddr4_mem[1].dq[1]
#set_location_assignment PIN_CF39 -to ddr4_mem[1].dq[4]
#set_location_assignment PIN_CH39 -to ddr4_mem[1].dq[7]
#set_location_assignment PIN_CE38 -to ddr4_mem[1].dq[6]
#set_location_assignment PIN_CG38 -to ddr4_mem[1].dq[0]
#
# CH1 DQS1
#set_location_assignment PIN_CU34 -to ddr4_mem[1].dbi_n[1]
#set_location_assignment PIN_CT33 -to ddr4_mem[1].dqs_n[1]
#set_location_assignment PIN_CV33 -to ddr4_mem[1].dqs[1]
#set_location_assignment PIN_CU32 -to ddr4_mem[1].dq[8]
#set_location_assignment PIN_CU36 -to ddr4_mem[1].dq[9]
#set_location_assignment PIN_CV31 -to ddr4_mem[1].dq[10]
#set_location_assignment PIN_CR32 -to ddr4_mem[1].dq[11]
#set_location_assignment PIN_CV35 -to ddr4_mem[1].dq[12]
#set_location_assignment PIN_CR36 -to ddr4_mem[1].dq[13]
#set_location_assignment PIN_CT35 -to ddr4_mem[1].dq[14]
#set_location_assignment PIN_CT31 -to ddr4_mem[1].dq[15]
#
# CH1 DQS2
#set_location_assignment PIN_DB41 -to ddr4_mem[1].dbi_n[2]
#set_location_assignment PIN_DA40 -to ddr4_mem[1].dqs_n[2]
#set_location_assignment PIN_DC40 -to ddr4_mem[1].dqs[2]
#set_location_assignment PIN_DC42 -to ddr4_mem[1].dq[16]
#set_location_assignment PIN_DB43 -to ddr4_mem[1].dq[18]
#set_location_assignment PIN_DA38 -to ddr4_mem[1].dq[17]
#set_location_assignment PIN_CY39 -to ddr4_mem[1].dq[19]
#set_location_assignment PIN_DA42 -to ddr4_mem[1].dq[20]
#set_location_assignment PIN_DC38 -to ddr4_mem[1].dq[21]
#set_location_assignment PIN_CY43 -to ddr4_mem[1].dq[22]
#set_location_assignment PIN_DB39 -to ddr4_mem[1].dq[23]
#
# CH1 DQS3
#set_location_assignment PIN_CV41 -to ddr4_mem[1].dbi_n[3]
#set_location_assignment PIN_CR40 -to ddr4_mem[1].dqs_n[3]
#set_location_assignment PIN_CU40 -to ddr4_mem[1].dqs[3]
#set_location_assignment PIN_CR42 -to ddr4_mem[1].dq[24]
#set_location_assignment PIN_CU38 -to ddr4_mem[1].dq[25]
#set_location_assignment PIN_CV43 -to ddr4_mem[1].dq[26]
#set_location_assignment PIN_CT39 -to ddr4_mem[1].dq[27]
#set_location_assignment PIN_CT43 -to ddr4_mem[1].dq[28]
#set_location_assignment PIN_CV39 -to ddr4_mem[1].dq[29]
#set_location_assignment PIN_CU42 -to ddr4_mem[1].dq[30]
#set_location_assignment PIN_CR38 -to ddr4_mem[1].dq[31]


#-----------------------------------------------------------------------------
# EMIF CH2, NOT USED ON IA-840F EAU REV0 BOARD PORTING
#-----------------------------------------------------------------------------
#set_location_assignment PIN_P45 -to ddr4_mem[2].bg[0]
#set_location_assignment PIN_M45 -to ddr4_mem[2].ba[1]
#set_location_assignment PIN_N44 -to ddr4_mem[2].ba[0]
#set_location_assignment PIN_L44 -to ddr4_mem[2].alert_n
#set_location_assignment PIN_P43 -to ddr4_mem[2].a[16]
#set_location_assignment PIN_M43 -to ddr4_mem[2].a[15]
#set_location_assignment PIN_N42 -to ddr4_mem[2].a[14]
#set_location_assignment PIN_L42 -to ddr4_mem[2].a[13]
#set_location_assignment PIN_P41 -to ddr4_mem[2].a[12]
#set_location_assignment PIN_M41 -to ddr4_mem[2].oct_rzqin
#set_location_assignment PIN_N40 -to "ddr4_mem[2].ref_clk(n)"
#set_location_assignment PIN_L40 -to ddr4_mem[2].ref_clk
#set_location_assignment PIN_W38 -to ddr4_mem[2].a[11]
#set_location_assignment PIN_U38 -to ddr4_mem[2].a[10]
#set_location_assignment PIN_V37 -to ddr4_mem[2].a[9]
#set_location_assignment PIN_T37 -to ddr4_mem[2].a[8]
#set_location_assignment PIN_W36 -to ddr4_mem[2].a[7]
#set_location_assignment PIN_U36 -to ddr4_mem[2].a[6]
#set_location_assignment PIN_V35 -to ddr4_mem[2].a[5]
#set_location_assignment PIN_T35 -to ddr4_mem[2].a[4]
#set_location_assignment PIN_W34 -to ddr4_mem[2].a[3]
#set_location_assignment PIN_U34 -to ddr4_mem[2].a[2]
#set_location_assignment PIN_V33 -to ddr4_mem[2].a[1]
#set_location_assignment PIN_T33 -to ddr4_mem[2].a[0]
#set_location_assignment PIN_N38 -to ddr4_mem[2].par
#set_location_assignment PIN_L38 -to ddr4_mem[2].cs_n[1]
#set_location_assignment PIN_P37 -to ddr4_mem[2].ck_n
#set_location_assignment PIN_M37 -to ddr4_mem[2].ck
#set_location_assignment PIN_L36 -to ddr4_mem[2].cke
#set_location_assignment PIN_M35 -to ddr4_mem[2].odt
#set_location_assignment PIN_N34 -to ddr4_mem[2].act_n
#set_location_assignment PIN_L34 -to ddr4_mem[2].cs_n[0]
#set_location_assignment PIN_P33 -to ddr4_mem[2].reset_n
#
# CH2 DQS0
#set_location_assignment PIN_J42 -to ddr4_mem[2].dqs_n[0]
#set_location_assignment PIN_F43 -to ddr4_mem[2].dbi_n[0]
#set_location_assignment PIN_G42 -to ddr4_mem[2].dqs[0]
#set_location_assignment PIN_G44 -to ddr4_mem[2].dq[0]
#set_location_assignment PIN_F41 -to ddr4_mem[2].dq[1]
#set_location_assignment PIN_H45 -to ddr4_mem[2].dq[2]
#set_location_assignment PIN_J44 -to ddr4_mem[2].dq[3]
#set_location_assignment PIN_H41 -to ddr4_mem[2].dq[4]
#set_location_assignment PIN_F45 -to ddr4_mem[2].dq[5]
#set_location_assignment PIN_J40 -to ddr4_mem[2].dq[6]
#set_location_assignment PIN_G40 -to ddr4_mem[2].dq[7]
#
# CH2 DQS1
#set_location_assignment PIN_C42 -to ddr4_mem[2].dqs_n[1]
#set_location_assignment PIN_B43 -to ddr4_mem[2].dbi_n[1]
#set_location_assignment PIN_A42 -to ddr4_mem[2].dqs[1]
#set_location_assignment PIN_C44 -to ddr4_mem[2].dq[8]
#set_location_assignment PIN_A40 -to ddr4_mem[2].dq[9]
#set_location_assignment PIN_B45 -to ddr4_mem[2].dq[10]
#set_location_assignment PIN_B41 -to ddr4_mem[2].dq[11]
#set_location_assignment PIN_A44 -to ddr4_mem[2].dq[12]
#set_location_assignment PIN_C40 -to ddr4_mem[2].dq[13]
#set_location_assignment PIN_D45 -to ddr4_mem[2].dq[14]
#set_location_assignment PIN_D41 -to ddr4_mem[2].dq[15]
#
# CH2 DQS2
#set_location_assignment PIN_T43 -to ddr4_mem[2].dbi_n[2]
#set_location_assignment PIN_W42 -to ddr4_mem[2].dqs_n[2]
#set_location_assignment PIN_U42 -to ddr4_mem[2].dqs[2]
#set_location_assignment PIN_U44 -to ddr4_mem[2].dq[16]
#set_location_assignment PIN_U40 -to ddr4_mem[2].dq[17]
#set_location_assignment PIN_T41 -to ddr4_mem[2].dq[18]
#set_location_assignment PIN_V45 -to ddr4_mem[2].dq[19]
#set_location_assignment PIN_W44 -to ddr4_mem[2].dq[20]
#set_location_assignment PIN_V41 -to ddr4_mem[2].dq[21]
#set_location_assignment PIN_W40 -to ddr4_mem[2].dq[22]
#set_location_assignment PIN_T45 -to ddr4_mem[2].dq[23]
#
# CH2 DQS3
#set_location_assignment PIN_A36 -to ddr4_mem[2].dbi_n[3]
#set_location_assignment PIN_D35 -to ddr4_mem[2].dqs_n[3]
#set_location_assignment PIN_B35 -to ddr4_mem[2].dqs[3]
#set_location_assignment PIN_C34 -to ddr4_mem[2].dq[24]
#set_location_assignment PIN_D33 -to ddr4_mem[2].dq[25]
#set_location_assignment PIN_A38 -to ddr4_mem[2].dq[26]
#set_location_assignment PIN_A34 -to ddr4_mem[2].dq[27]
#set_location_assignment PIN_B37 -to ddr4_mem[2].dq[28]
#set_location_assignment PIN_D37 -to ddr4_mem[2].dq[29]
#set_location_assignment PIN_B33 -to ddr4_mem[2].dq[30]
#set_location_assignment PIN_C38 -to ddr4_mem[2].dq[31]
#
# CH2 DQS4 (ECC)
# set_location_assignment PIN_G36 -to ddr4_ecc_mem[0].dbi_n[4]
# set_location_assignment PIN_H35 -to ddr4_ecc_mem[0].dqs_n[4]
# set_location_assignment PIN_F35 -to ddr4_ecc_mem[0].dqs[4]
# set_location_assignment PIN_G38 -to ddr4_ecc_mem[0].dq[32]
# set_location_assignment PIN_J38 -to ddr4_ecc_mem[0].dq[33]
# set_location_assignment PIN_H33 -to ddr4_ecc_mem[0].dq[34]
# set_location_assignment PIN_J34 -to ddr4_ecc_mem[0].dq[35]
# set_location_assignment PIN_F33 -to ddr4_ecc_mem[0].dq[36]
# set_location_assignment PIN_H37 -to ddr4_ecc_mem[0].dq[37]
# set_location_assignment PIN_F37 -to ddr4_ecc_mem[0].dq[38]
# set_location_assignment PIN_G34 -to ddr4_ecc_mem[0].dq[39]


#-----------------------------------------------------------------------------
# EMIF CH3, NOT USED ON IA-840F EAU REV0 BOARD PORTING
#-----------------------------------------------------------------------------
#set_location_assignment PIN_A54 -to ddr4_mem[3].ref_clk
#set_location_assignment PIN_C54 -to "ddr4_mem[3].ref_clk(n)"
#set_location_assignment PIN_H61 -to ddr4_mem[3].bg[0]
#set_location_assignment PIN_F61 -to ddr4_mem[3].ba[1]
#set_location_assignment PIN_D59 -to ddr4_mem[3].ba[0]
#set_location_assignment PIN_C58 -to ddr4_mem[3].alert_n
#set_location_assignment PIN_D57 -to ddr4_mem[3].a[16]
#set_location_assignment PIN_B57 -to ddr4_mem[3].a[15]
#set_location_assignment PIN_C56 -to ddr4_mem[3].a[14]
#set_location_assignment PIN_A56 -to ddr4_mem[3].a[13]
#set_location_assignment PIN_D55 -to ddr4_mem[3].a[12]
#set_location_assignment PIN_B55 -to ddr4_mem[3].oct_rzqin
#set_location_assignment PIN_J52 -to ddr4_mem[3].a[11]
#set_location_assignment PIN_G52 -to ddr4_mem[3].a[10]
#set_location_assignment PIN_H51 -to ddr4_mem[3].a[9]
#set_location_assignment PIN_F51 -to ddr4_mem[3].a[8]
#set_location_assignment PIN_J50 -to ddr4_mem[3].a[7]
#set_location_assignment PIN_G50 -to ddr4_mem[3].a[6]
#set_location_assignment PIN_H49 -to ddr4_mem[3].a[5]
#set_location_assignment PIN_F49 -to ddr4_mem[3].a[4]
#set_location_assignment PIN_J48 -to ddr4_mem[3].a[3]
#set_location_assignment PIN_G48 -to ddr4_mem[3].a[2]
#set_location_assignment PIN_H47 -to ddr4_mem[3].a[1]
#set_location_assignment PIN_F47 -to ddr4_mem[3].a[0]
#set_location_assignment PIN_C52 -to ddr4_mem[3].par
#set_location_assignment PIN_A52 -to ddr4_mem[3].cs_n[1]
#set_location_assignment PIN_D51 -to ddr4_mem[3].ck_n
#set_location_assignment PIN_B51 -to ddr4_mem[3].ck
#set_location_assignment PIN_A50 -to ddr4_mem[3].cke
#set_location_assignment PIN_B49 -to ddr4_mem[3].odt
#set_location_assignment PIN_C48 -to ddr4_mem[3].act_n
#set_location_assignment PIN_A48 -to ddr4_mem[3].cs_n[0]
#set_location_assignment PIN_D47 -to ddr4_mem[3].reset_n
#
# CH3 DQS0
#set_location_assignment PIN_F57 -to ddr4_mem[3].dbi_n[0]
#set_location_assignment PIN_J56 -to ddr4_mem[3].dqs_n[0]
#set_location_assignment PIN_G56 -to ddr4_mem[3].dqs[0]
#set_location_assignment PIN_G54 -to ddr4_mem[3].dq[0]
#set_location_assignment PIN_H55 -to ddr4_mem[3].dq[1]
#set_location_assignment PIN_J54 -to ddr4_mem[3].dq[2]
#set_location_assignment PIN_F55 -to ddr4_mem[3].dq[3]
#set_location_assignment PIN_G58 -to ddr4_mem[3].dq[4]
#set_location_assignment PIN_J58 -to ddr4_mem[3].dq[5]
#set_location_assignment PIN_F59 -to ddr4_mem[3].dq[6]
#set_location_assignment PIN_H59 -to ddr4_mem[3].dq[7]
#
# CH3 DQS1
#set_location_assignment PIN_M57 -to ddr4_mem[3].dbi_n[1]
#set_location_assignment PIN_N56 -to ddr4_mem[3].dqs_n[1]
#set_location_assignment PIN_L56 -to ddr4_mem[3].dqs[1]
#set_location_assignment PIN_P59 -to ddr4_mem[3].dq[8]
#set_location_assignment PIN_P55 -to ddr4_mem[3].dq[9]
#set_location_assignment PIN_N58 -to ddr4_mem[3].dq[10]
#set_location_assignment PIN_M55 -to ddr4_mem[3].dq[11]
#set_location_assignment PIN_M59 -to ddr4_mem[3].dq[12]
#set_location_assignment PIN_N54 -to ddr4_mem[3].dq[13]
#set_location_assignment PIN_L58 -to ddr4_mem[3].dq[14]
#set_location_assignment PIN_L54 -to ddr4_mem[3].dq[15]
#
# CH3 DQS2
#set_location_assignment PIN_U50 -to ddr4_mem[3].dbi_n[2]
#set_location_assignment PIN_V49 -to ddr4_mem[3].dqs_n[2]
#set_location_assignment PIN_T49 -to ddr4_mem[3].dqs[2]
#set_location_assignment PIN_U52 -to ddr4_mem[3].dq[16]
#set_location_assignment PIN_W52 -to ddr4_mem[3].dq[17]
#set_location_assignment PIN_V47 -to ddr4_mem[3].dq[18]
#set_location_assignment PIN_W48 -to ddr4_mem[3].dq[19]
#set_location_assignment PIN_T51 -to ddr4_mem[3].dq[20]
#set_location_assignment PIN_V51 -to ddr4_mem[3].dq[21]
#set_location_assignment PIN_T47 -to ddr4_mem[3].dq[22]
#set_location_assignment PIN_U48 -to ddr4_mem[3].dq[23]
#
# CH3 DQS3
#set_location_assignment PIN_T57 -to ddr4_mem[3].dbi_n[3]
#set_location_assignment PIN_W56 -to ddr4_mem[3].dqs_n[3]
#set_location_assignment PIN_U56 -to ddr4_mem[3].dqs[3]
#set_location_assignment PIN_V59 -to ddr4_mem[3].dq[24]
#set_location_assignment PIN_V55 -to ddr4_mem[3].dq[25]
#set_location_assignment PIN_T55 -to ddr4_mem[3].dq[26]
#set_location_assignment PIN_W54 -to ddr4_mem[3].dq[27]
#set_location_assignment PIN_T59 -to ddr4_mem[3].dq[28]
#set_location_assignment PIN_W58 -to ddr4_mem[3].dq[29]
#set_location_assignment PIN_U54 -to ddr4_mem[3].dq[30]
#set_location_assignment PIN_U58 -to ddr4_mem[3].dq[31]
#
# CH3 DQS4 (ECC)
# set_location_assignment PIN_L50 -to ddr4_ecc_mem[1].dbi_n[4]
# set_location_assignment PIN_P49 -to ddr4_ecc_mem[1].dqs_n[4]
# set_location_assignment PIN_M49 -to ddr4_ecc_mem[1].dqs[4]
# set_location_assignment PIN_M51 -to ddr4_ecc_mem[1].dq[32]
# set_location_assignment PIN_N48 -to ddr4_ecc_mem[1].dq[33]
# set_location_assignment PIN_M47 -to ddr4_ecc_mem[1].dq[34]
# set_location_assignment PIN_L48 -to ddr4_ecc_mem[1].dq[35]
# set_location_assignment PIN_P47 -to ddr4_ecc_mem[1].dq[36]
# set_location_assignment PIN_P51 -to ddr4_ecc_mem[1].dq[37]
# set_location_assignment PIN_N52 -to ddr4_ecc_mem[1].dq[38]
# set_location_assignment PIN_L52 -to ddr4_ecc_mem[1].dq[39]


#-----------------------------------------------------------------------------
# EMIF HPS, ON IA-840F EAU REV0 BOARD HPS IS MAPPED TO P3 BANK
#-----------------------------------------------------------------------------
set_location_assignment PIN_AA14 -to "ddr4_hps.ref_clk(n)"
set_location_assignment PIN_AC12 -to ddr4_hps.ref_clk
set_location_assignment PIN_AH7 -to ddr4_hps.bg[0]
set_location_assignment PIN_AC20 -to ddr4_hps.bg[1]
set_location_assignment PIN_AF6 -to ddr4_hps.ba[1]
set_location_assignment PIN_AA7 -to ddr4_hps.ba[0]
set_location_assignment PIN_AC6 -to ddr4_hps.alert_n
set_location_assignment PIN_AF12 -to ddr4_hps.oct_rzqin
set_location_assignment PIN_AF9 -to ddr4_hps.a[15]
set_location_assignment PIN_AH10 -to ddr4_hps.a[16]
set_location_assignment PIN_AC9 -to ddr4_hps.a[13]
set_location_assignment PIN_AA10 -to ddr4_hps.a[14]
set_location_assignment PIN_AH14 -to ddr4_hps.a[12]
set_location_assignment PIN_AV15 -to ddr4_hps.a[10]
set_location_assignment PIN_AT17 -to ddr4_hps.a[11]
set_location_assignment PIN_AK15 -to ddr4_hps.a[8]
set_location_assignment PIN_AM17 -to ddr4_hps.a[9]
set_location_assignment PIN_AV18 -to ddr4_hps.a[6]
set_location_assignment PIN_AT19 -to ddr4_hps.a[7]
set_location_assignment PIN_AK18 -to ddr4_hps.a[4]
set_location_assignment PIN_AM19 -to ddr4_hps.a[5]
set_location_assignment PIN_AV20 -to ddr4_hps.a[2]
set_location_assignment PIN_AT21 -to ddr4_hps.a[3]
set_location_assignment PIN_AK20 -to ddr4_hps.a[0]
set_location_assignment PIN_AM21 -to ddr4_hps.a[1]
#set_location_assignment PIN_AF15 -to ddr4_hps.cs_n[1]
set_location_assignment PIN_AF20 -to ddr4_hps.cs_n[0]
set_location_assignment PIN_AH17 -to ddr4_hps.par
set_location_assignment PIN_AC15 -to ddr4_hps.ck
set_location_assignment PIN_AA17 -to ddr4_hps.ck_n
set_location_assignment PIN_AF18 -to ddr4_hps.cke
#set_location_assignment PIN_AH19 -to ddr4_hps.cke[1]
set_location_assignment PIN_AC18 -to ddr4_hps.odt
#set_location_assignment PIN_AA19 -to ddr4_hps.odt[1]
set_location_assignment PIN_AH21 -to ddr4_hps.act_n
set_location_assignment PIN_AA21 -to reset_n

# New groups as ia-840f is x72 bank  (mapped to P3 bank, component based)
# HPS DQS0
set_location_assignment PIN_AF30 -to ddr4_hps.dbi_n[0]
set_location_assignment PIN_AA31 -to ddr4_hps.dqs_n[0]
set_location_assignment PIN_AC30 -to ddr4_hps.dqs[0]
set_location_assignment PIN_AH33 -to ddr4_hps.dq[0]
set_location_assignment PIN_AH29 -to ddr4_hps.dq[1]
set_location_assignment PIN_AA33 -to ddr4_hps.dq[2]
set_location_assignment PIN_AA29 -to ddr4_hps.dq[3]
set_location_assignment PIN_AF32 -to ddr4_hps.dq[4]
set_location_assignment PIN_AC28 -to ddr4_hps.dq[5]
set_location_assignment PIN_AC32 -to ddr4_hps.dq[6]
set_location_assignment PIN_AF28 -to ddr4_hps.dq[7]

# New groups as ia-840f is x72 bank  (mapped to P3 bank, component based)
# HPS DQS1
set_location_assignment PIN_AV30 -to ddr4_hps.dbi_n[1]
set_location_assignment PIN_AM31 -to ddr4_hps.dqs_n[1]
set_location_assignment PIN_AK30 -to ddr4_hps.dqs[1]
set_location_assignment PIN_AV32 -to ddr4_hps.dq[8]
set_location_assignment PIN_AT29 -to ddr4_hps.dq[9]
set_location_assignment PIN_AM33 -to ddr4_hps.dq[10]
set_location_assignment PIN_AM29 -to ddr4_hps.dq[11]
set_location_assignment PIN_AT33 -to ddr4_hps.dq[12]
set_location_assignment PIN_AV28 -to ddr4_hps.dq[13]
set_location_assignment PIN_AK32 -to ddr4_hps.dq[14]
set_location_assignment PIN_AK28 -to ddr4_hps.dq[15]

# New groups as ia-840f is x72 bank  (mapped to P3 bank, component based)
# HPS DQS2
set_location_assignment PIN_AF24 -to ddr4_hps.dbi_n[2]
set_location_assignment PIN_AA25 -to ddr4_hps.dqs_n[2]
set_location_assignment PIN_AC24 -to ddr4_hps.dqs[2]
set_location_assignment PIN_AH27 -to ddr4_hps.dq[16]
set_location_assignment PIN_AA23 -to ddr4_hps.dq[17]
set_location_assignment PIN_AC26 -to ddr4_hps.dq[18]
set_location_assignment PIN_AH23 -to ddr4_hps.dq[19]
set_location_assignment PIN_AA27 -to ddr4_hps.dq[20]
set_location_assignment PIN_AC22 -to ddr4_hps.dq[21]
set_location_assignment PIN_AF26 -to ddr4_hps.dq[22]
set_location_assignment PIN_AF22 -to ddr4_hps.dq[23]

# New groups as ia-840f is x72 bank  (mapped to P3 bank, component based)
# HPS DQS3
set_location_assignment PIN_AV24 -to ddr4_hps.dbi_n[3]
set_location_assignment PIN_AM25 -to ddr4_hps.dqs_n[3]
set_location_assignment PIN_AK24 -to ddr4_hps.dqs[3]
set_location_assignment PIN_AT23 -to ddr4_hps.dq[24]
set_location_assignment PIN_AM27 -to ddr4_hps.dq[25]
set_location_assignment PIN_AV26 -to ddr4_hps.dq[26]
set_location_assignment PIN_AK26 -to ddr4_hps.dq[27]
set_location_assignment PIN_AV22 -to ddr4_hps.dq[28]
set_location_assignment PIN_AM23 -to ddr4_hps.dq[29]
set_location_assignment PIN_AT27 -to ddr4_hps.dq[30]
set_location_assignment PIN_AK22 -to ddr4_hps.dq[31]

# New groups as ia-840f is x72 bank  (mapped to P3 bank, component based)
# HPS DQS4
set_location_assignment PIN_G18 -to ddr4_hps.dbi_n[4]
set_location_assignment PIN_A19 -to ddr4_hps.dqs_n[4]
set_location_assignment PIN_C18 -to ddr4_hps.dqs[4]
set_location_assignment PIN_J21 -to ddr4_hps.dq[32]
set_location_assignment PIN_J17 -to ddr4_hps.dq[33]
set_location_assignment PIN_G20 -to ddr4_hps.dq[34]
set_location_assignment PIN_A17 -to ddr4_hps.dq[35]
set_location_assignment PIN_A21 -to ddr4_hps.dq[36]
set_location_assignment PIN_G15 -to ddr4_hps.dq[37]
set_location_assignment PIN_C20 -to ddr4_hps.dq[38]
set_location_assignment PIN_C15 -to ddr4_hps.dq[39]

# New groups as ia-840f is x72 bank  (mapped to P3 bank, component based)
# HPS DQS5
set_location_assignment PIN_W18 -to ddr4_hps.dbi_n[5]
set_location_assignment PIN_N19 -to ddr4_hps.dqs_n[5]
set_location_assignment PIN_L18 -to ddr4_hps.dqs[5]
set_location_assignment PIN_U21 -to ddr4_hps.dq[40]
set_location_assignment PIN_U17 -to ddr4_hps.dq[41]
set_location_assignment PIN_W20 -to ddr4_hps.dq[42]
set_location_assignment PIN_N17 -to ddr4_hps.dq[43]
set_location_assignment PIN_N21 -to ddr4_hps.dq[44]
set_location_assignment PIN_W15 -to ddr4_hps.dq[45]
set_location_assignment PIN_L20 -to ddr4_hps.dq[46]
set_location_assignment PIN_L15 -to ddr4_hps.dq[47]

# New groups as ia-840f is x72 bank  (mapped to P3 bank, component based)
# HPS DQS6
set_location_assignment PIN_G9 -to ddr4_hps.dbi_n[6]
set_location_assignment PIN_A10 -to ddr4_hps.dqs_n[6]
set_location_assignment PIN_C9 -to ddr4_hps.dqs[6]
set_location_assignment PIN_G12 -to ddr4_hps.dq[48]
set_location_assignment PIN_J7 -to ddr4_hps.dq[49]
set_location_assignment PIN_C12 -to ddr4_hps.dq[50]
set_location_assignment PIN_G6 -to ddr4_hps.dq[51]
set_location_assignment PIN_A14 -to ddr4_hps.dq[52]
set_location_assignment PIN_E5 -to ddr4_hps.dq[53]
set_location_assignment PIN_J14 -to ddr4_hps.dq[54]
set_location_assignment PIN_G3 -to ddr4_hps.dq[55]

# New groups as ia-840f is x72 bank  (mapped to P3 bank, component based)
# HPS DQS7
set_location_assignment PIN_W9 -to ddr4_hps.dbi_n[7]
set_location_assignment PIN_N10 -to ddr4_hps.dqs_n[7]
set_location_assignment PIN_L9 -to ddr4_hps.dqs[7]
set_location_assignment PIN_N7 -to ddr4_hps.dq[56]
set_location_assignment PIN_U14 -to ddr4_hps.dq[57]
set_location_assignment PIN_L6 -to ddr4_hps.dq[58]
set_location_assignment PIN_W6 -to ddr4_hps.dq[59]
set_location_assignment PIN_L12 -to ddr4_hps.dq[60]
set_location_assignment PIN_W12 -to ddr4_hps.dq[61]
set_location_assignment PIN_N14 -to ddr4_hps.dq[62]
set_location_assignment PIN_U7 -to ddr4_hps.dq[63]

# New groups as ia-840f is x72 bank  (mapped to P3 bank, component based)
# HPS DQS8 (ECC)
set_location_assignment PIN_AV9 -to ddr4_hps.dbi_n[8]
set_location_assignment PIN_AM10 -to ddr4_hps.dqs_n[8]
set_location_assignment PIN_AK9 -to ddr4_hps.dqs[8]
set_location_assignment PIN_AK12 -to ddr4_hps.dq[64]
set_location_assignment PIN_AV6 -to ddr4_hps.dq[65]
set_location_assignment PIN_AM14 -to ddr4_hps.dq[66]
set_location_assignment PIN_AM7 -to ddr4_hps.dq[67]
set_location_assignment PIN_AT14 -to ddr4_hps.dq[68]
set_location_assignment PIN_AT7 -to ddr4_hps.dq[69]
set_location_assignment PIN_AV12 -to ddr4_hps.dq[70]
set_location_assignment PIN_AK6 -to ddr4_hps.dq[71]


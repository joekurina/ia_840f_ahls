# (C) 2001-2026 Altera Corporation. All rights reserved.
# Your use of Altera Corporation's design tools, logic functions and other 
# software and tools, and its AMPP partner logic functions, and any output 
# files from any of the foregoing (including device programming or simulation 
# files), and any associated documentation or information are expressly subject 
# to the terms and conditions of the Altera Program License Subscription 
# Agreement, Altera IP License Agreement, or other applicable 
# license agreement, including, without limitation, that your use is for the 
# sole purpose of programming logic devices manufactured by Altera and sold by 
# Altera or its authorized distributors.  Please refer to the applicable 
# agreement for further details.


proc ::mem_ss_pkg::ip_msa::sim_verilog_fileset_callback {top_level_name} {
   _common_fileset $top_level_name "sim"
}

proc ::mem_ss_pkg::ip_msa::sim_vhdl_fileset_callback {top_level_name} {
   sim_verilog_fileset_callback $top_level_name
}

proc ::mem_ss_pkg::ip_msa::quartus_synth_fileset_callback {top_level_name} {
   _common_fileset $top_level_name "synth"
}

proc ::mem_ss_pkg::ip_msa::cdc_fileset_callback {top_level_name} {
   _common_fileset $top_level_name "cdc"
}

proc ::mem_ss_pkg::ip_msa::cdc_vhdl_fileset_callback {top_level_name} {
   cdc_fileset_callback $top_level_name
}


proc ::mem_ss_pkg::ip_msa::_common_fileset {top_level_name fileset_type} {

   table create files [list \
      [list @                          PATH_OR_TEXT   SOURCE                        TYPE                    COMMON_SYSTEMVERILOG_PACKAGE  ] \
      [list mem_ss_msa_top.sv          PATH           rtl/mem_ss_msa_top.sv         SYSTEM_VERILOG_ENCRYPT  NOVAL                         ] \
      \
      [list drc_pkg.sv                 PATH           rtl/drc_pkg.sv                SYSTEM_VERILOG_ENCRYPT  drc_pkg                       ] \
      \
      [list drc_dc_sync.sv             PATH           rtl/drc_dc_sync.sv            SYSTEM_VERILOG_ENCRYPT  NOVAL                         ] \
      [list drc_dcfifo_mw.sv           PATH           rtl/drc_dcfifo_mw.sv          SYSTEM_VERILOG_ENCRYPT  NOVAL                         ] \
      [list drc_insert_delay_reg.sv    PATH           rtl/drc_insert_delay_reg.sv   SYSTEM_VERILOG_ENCRYPT  NOVAL                         ] \
      [list drc_ram_2port.sv           PATH           rtl/drc_ram_2port.sv          SYSTEM_VERILOG_ENCRYPT  NOVAL                         ] \
      [list drc_reset_sync.sv          PATH           rtl/drc_reset_sync.sv         SYSTEM_VERILOG_ENCRYPT  NOVAL                         ] \
      [list drc_bank_spreading.sv      PATH           rtl/drc_bank_spreading.sv     SYSTEM_VERILOG_ENCRYPT  NOVAL                         ] \
      [list drc_dcfifo.sv              PATH           rtl/drc_dcfifo.sv             SYSTEM_VERILOG_ENCRYPT  NOVAL                         ] \
      [list drc_demux.sv               PATH           rtl/drc_demux.sv              SYSTEM_VERILOG_ENCRYPT  NOVAL                         ] \
      [list drc_lkup_rdcmd_reorder.sv  PATH           rtl/drc_lkup_rdcmd_reorder.sv SYSTEM_VERILOG_ENCRYPT  NOVAL                         ] \
      [list drc_pulse_sync.sv          PATH           rtl/drc_pulse_sync.sv         SYSTEM_VERILOG_ENCRYPT  NOVAL                         ] \
      [list drc_reset_gen.sv           PATH           rtl/drc_reset_gen.sv          SYSTEM_VERILOG_ENCRYPT  NOVAL                         ] \
      [list drc_scfifo.sv              PATH           rtl/drc_scfifo.sv             SYSTEM_VERILOG_ENCRYPT  NOVAL                         ] \
      [list ddrx_ropt_ctrl.sv          PATH           rtl/ddrx_ropt_ctrl.sv         SYSTEM_VERILOG_ENCRYPT  NOVAL                         ] \
   ]

   if {$fileset_type in [list "synth" "cdc"]} {
      table create files [list \
         [list @                       PATH_OR_TEXT   SOURCE                        TYPE       ] \
         [list mem_ss_msa.sdc          PATH           timing/mem_ss_msa.sdc         SDC_ENTITY ] \
      ]
   }
}


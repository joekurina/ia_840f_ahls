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


set script_path [file dirname [file normalize [info script]]]

# Source in parameters
source "$script_path/params.tcl"

# Retrieve values from the ip_param array while taking into consideration that
# usr_auto params actual value can be in one of two parameters
proc get_ip_param {param_name} {
   global ip_params
   if {[info exists ip_params(${param_name}_AUTO_BOOL)]} {
      # Param is usr_auto
      if {$ip_params(${param_name}_AUTO_BOOL)} {
         set val $ip_params(${param_name}_AUTO)
      } else {
         set val $ip_params($param_name)
      }
   } else {
      # Param is not usr_auto
      set val $ip_params($param_name)
   }
   return $val
}

# Globals
set ed_synth         $ed_params(SYNTH_QSYS_NAME)
set emif_name        $ed_params(EMIF_NAME)
set noc_init         $ed_params(NOC_INIT_NAME)
set noc_init_lite    $ed_params(NOC_INIT_LITE_NAME)
set noc_ctrl         $ed_params(NOC_CTRL_NAME)
set noc_group        $ed_params(NOC_GROUP_NAME)

proc iniu_inst {suffix} {
   global noc_init
   return ${noc_init}|intel_noc_initiator_inst|iniu${suffix}|initiator_inst_0
}
proc iniu_inst_lite {suffix} {
   global noc_init_lite
   return ${noc_init_lite}${suffix}|intel_noc_initiator_inst|iniu_0|initiator_inst_0
}
proc tniu_inst {suffix} {
   global emif_name
   return ${emif_name}|emif_ph2_inst|tniu${suffix}|target_0.target_inst_0
}
proc tniu_inst_lite {suffix} {
   global emif_name
   return ${emif_name}|emif_ph2_inst|calip${suffix}|tniu|target_0.target_lite_inst_0
}

proc get_noc_qsf_assgn {} {
   global noc_group noc_ctrl ed_synth

   set num_channels     [get_ip_param MEM_NUM_CHANNELS]
   set sideband_access  [get_ip_param AXI_SIDEBAND_ACCESS_MODE]
   set noc_enable       [get_ip_param PHY_NOC_EN]
   set sideband_used    [expr {$sideband_access == "NOC"}]
   set mainband_used    [string is true $noc_enable]
   set mem_tech         [get_ip_param MEM_TECHNOLOGY]
   
   set txt ""
   append txt "\n# Add NoC Clock Control\n"
   append txt "set_instance_assignment -name NOC_GROUP ${noc_group} -to ${noc_ctrl}|intel_noc_clock_ctrl_inst|pll_inst -entity $ed_synth\n"
   append txt "set_instance_assignment -name NOC_GROUP ${noc_group} -to ${noc_ctrl}|intel_noc_clock_ctrl_inst|ssm_inst -entity $ed_synth\n"
   
   append txt "\n# Add target(s)\n"
   for {set ch_idx 0} {$ch_idx < $num_channels} {incr ch_idx} {
      if {$mainband_used} {
         append txt "set_instance_assignment -name NOC_GROUP ${noc_group} -to [tniu_inst "_${ch_idx}"] -entity $ed_synth\n"
      }
      if {$sideband_used} {
         append txt "set_instance_assignment -name NOC_GROUP ${noc_group} -to [tniu_inst_lite "_${ch_idx}"] -entity $ed_synth\n"
      }
   }
   
   append txt "\n# Add initiator(s)\n"
   for {set ch_idx 0} {$ch_idx < $num_channels} {incr ch_idx} {
      if {$mainband_used} {
         append txt "set_instance_assignment -name NOC_GROUP ${noc_group} -to [iniu_inst "_${ch_idx}"] -entity $ed_synth\n"
      }
      if {$sideband_used} {
         append txt "set_instance_assignment -name NOC_GROUP ${noc_group} -to [iniu_inst_lite "_${ch_idx}"] -entity $ed_synth\n"
      }
   }

   append txt "\n# Add average bandwidth and average transaction size for connection(s)\n"
   if {$mainband_used} {
      set extra_config_str        [get_ip_param DIAG_EXTRA_PARAMETERS]
      array set extra_config_arr  [parse_extra_configs $extra_config_str]
      if {[info exists extra_config_arr(USR_CLK_FREQ_OVRD)]} {
         set iniu_freq_MHz $extra_config_arr(USR_CLK_FREQ_OVRD)
      } else {
         set iniu_freq_MHz [get_ip_param EX_DESIGN_CORE_CLK_FREQ_MHZ]
      }
      # This calculation is reverse engineering the bandwidth to set off of the 
      # bandwidth that the INIU will actually be able to support
      # INIU Operating Freq * INIU Data Bus Size (In bytes) * A Fudge Factor
      set Mbytes_per_sec [expr {double($iniu_freq_MHz) * 32.0 * 0.9}]
      set Gbytes_per_sec [expr {$Mbytes_per_sec / 1000.0}]
      # Split the bandwidth across read and write
      set bw_mb [expr {$Gbytes_per_sec / 2.0}]

      # Set average transaction size (in bytes) based off of the burst length
      # used by the traffic pattern for each protocol
      # From: ip/hydra/ip_software/sw/traffic_patterns.py
      set tr_size_mb 32
      if {$mem_tech == "MEM_TECHNOLOGY_DDR4"} {
         set tr_size_mb 32
         # DDR4 has it's BW halved another time as it's 32Byte transfers will never fully
         # saturate the NOCs internal 64Byte transfers
         set bw_mb [expr {$bw_mb / 2.0}]
      } elseif {$mem_tech == "MEM_TECHNOLOGY_DDR5" || $mem_tech == "MEM_TECHNOLOGY_LPDDR5"} {
         set tr_size_mb 64
      } elseif {$mem_tech == "MEM_TECHNOLOGY_LPDDR4"} {
         set tr_size_mb 128
      }
   }

   if {$sideband_used} {
      # Average bandwidth is zero for the sideband as it is not a sustained connection
      set bw_sb 0
      # Average transaction size is set to the smallest legal value (bytes)
      set tr_size_sb 32
   }

   for {set ch_idx 0} {$ch_idx < $num_channels} {incr ch_idx} {
      if {$mainband_used} {
         append txt "set_instance_assignment -name NOC_READ_BANDWIDTH ${bw_mb} -from [iniu_inst "_${ch_idx}"] -to [tniu_inst "_${ch_idx}"] -entity $ed_synth\n"
         append txt "set_instance_assignment -name NOC_WRITE_BANDWIDTH ${bw_mb} -from [iniu_inst "_${ch_idx}"] -to [tniu_inst "_${ch_idx}"] -entity $ed_synth\n"
         append txt "set_instance_assignment -name NOC_READ_TRANSACTION_SIZE ${tr_size_mb} -from [iniu_inst "_${ch_idx}"] -to [tniu_inst "_${ch_idx}"] -entity $ed_synth\n"
         append txt "set_instance_assignment -name NOC_WRITE_TRANSACTION_SIZE ${tr_size_mb} -from [iniu_inst "_${ch_idx}"] -to [tniu_inst "_${ch_idx}"] -entity $ed_synth\n"
      }
      if {$sideband_used} {
         append txt "set_instance_assignment -name NOC_READ_BANDWIDTH ${bw_sb} -from [iniu_inst_lite "_${ch_idx}"] -to [tniu_inst_lite "_${ch_idx}"] -entity $ed_synth\n"
         append txt "set_instance_assignment -name NOC_WRITE_BANDWIDTH ${bw_sb} -from [iniu_inst_lite "_${ch_idx}"] -to [tniu_inst_lite "_${ch_idx}"] -entity $ed_synth\n"
         append txt "set_instance_assignment -name NOC_READ_TRANSACTION_SIZE ${tr_size_sb} -from [iniu_inst_lite "_${ch_idx}"] -to [tniu_inst_lite "_${ch_idx}"] -entity $ed_synth\n"
         append txt "set_instance_assignment -name NOC_WRITE_TRANSACTION_SIZE ${tr_size_sb} -from [iniu_inst_lite "_${ch_idx}"] -to [tniu_inst_lite "_${ch_idx}"] -entity $ed_synth\n"
      }
   }

   return $txt
}

proc parse_extra_configs {str} {
   foreach item [split $str ",; "] {
      set tmp [split $item "="]
      if {[llength $tmp] == 2} {
         set name [string toupper [lindex $tmp 0]]
         set val [lindex $tmp 1]
         set retval($name) $val
      }
   }
   return [array get retval]
}

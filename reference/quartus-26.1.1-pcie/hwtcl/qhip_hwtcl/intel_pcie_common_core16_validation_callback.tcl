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


proc ::intel_pcie_ss_axi::parameters::validate_core16_topology_hwtcl { PROP_NAME PROP_VALUE core16_func_mode_hwtcl } {
    set tile [ip_get "parameter.TILE.value"]

    if { $tile == "P-TILE" } {
        set core16_func [ip_get "parameter.core16_func_mode_hwtcl.value"]
    
        if {  [regexp "Gen4" $PROP_VALUE] } {
            set core16_virtual_link_rate_hwtcl "Gen4 (16.0 Gbps)"
        } elseif { [regexp "Gen3" $PROP_VALUE] } {
            # "Gen3 (8.0 Gbps)"
            set core16_virtual_link_rate_hwtcl "Gen3 (8.0 Gbps)"
        } else {
            send_message error "Topology is not set"
        }
        ip_set_param "parameter.core16_virtual_link_rate_hwtcl.value" $core16_virtual_link_rate_hwtcl
        
        if { [regexp "x16" $PROP_VALUE] } {
            set core16_virtual_link_width_hwtcl "x16"
            send_message info "One x16 PCIe port will be instantiated."
        } elseif { [regexp "2x8" $PROP_VALUE] } {
            set core16_virtual_link_width_hwtcl "x8"
            send_message info "Two x8 PCIe ports will be instantiated."
        } elseif { [regexp "1x8" $PROP_VALUE] } {
            set core16_virtual_link_width_hwtcl "x8"
            send_message info "One x8 PCIe port will be instantiated."
        } elseif { [regexp "x4" $PROP_VALUE] } {
            set core16_virtual_link_width_hwtcl "x4"
            send_message info "Four x4 PCIe ports will be instantiated."
        } elseif { [regexp "1x4" $PROP_VALUE] } {
            set core16_virtual_link_width_hwtcl "x4"
            send_message info "One x4 PCIe ports will be instantiated."
        } elseif { [regexp "2x4" $PROP_VALUE] } {
            set core16_virtual_link_width_hwtcl "x4"
            send_message info "Two x4 PCIe ports will be instantiated."
        } else {
            send_message error "Topology is not set"
        }
        ip_set_param "parameter.core16_virtual_link_width_hwtcl.value" $core16_virtual_link_width_hwtcl
        
        if { ${core16_func} == "Disable" } {
            ip_set_param "parameter.core16_virtual_link_rate_hwtcl.value" "Gen1 (2.5 Gbps)"
            ip_set_param "parameter.core16_virtual_link_width_hwtcl.value" "x1"
            ip_set_param "parameter.core16_pf0_auto_lane_flip_ctrl_en_hwtcl.value" 0
        } else {
            ip_set_param "parameter.core16_pf0_auto_lane_flip_ctrl_en_hwtcl.value" 1
        }

    
    } elseif { $tile == "F-TILE" } {
        set core16_func [ip_get "parameter.core16_func_mode_hwtcl.value"]
        set ed_generating_rp [ip_get "parameter.ed_generating_rp_hwtcl.value"]
        
        if {  [regexp "Gen4" $PROP_VALUE] } {
            set core16_virtual_link_rate_hwtcl "Gen4 (16.0 Gbps)"
        } elseif { [regexp "Gen3" $PROP_VALUE] } {
            # "Gen3 (8.0 Gbps)"
            set core16_virtual_link_rate_hwtcl "Gen3 (8.0 Gbps)"
        } else {
            send_message error "Topology is not set"
        }
        ip_set_param "parameter.core16_virtual_link_rate_hwtcl.value" $core16_virtual_link_rate_hwtcl
        
        #TODO: Decode more topo
        if { [regexp "1x16" $PROP_VALUE] } {
            set core16_virtual_link_width_hwtcl "x16"
            send_message info "One x16 PCIe port will be instantiated."            
        } elseif { [regexp "2x8" $PROP_VALUE] } {
            set core16_virtual_link_width_hwtcl "x8"
            send_message info "Two x8 PCIe ports will be instantiated."
        } elseif { [regexp "4x4" $PROP_VALUE] } {
            set core16_virtual_link_width_hwtcl "x4"
            send_message info "Four x4 PCIe ports will be instantiated."
        } elseif { [regexp "1x4" $PROP_VALUE] } {
            set core16_virtual_link_width_hwtcl "x4"
        } elseif { [regexp "2x4" $PROP_VALUE] } {
            set core16_virtual_link_width_hwtcl "x4"
    	send_message info "Two x4 PCIe ports will be instantiated."
        } elseif { [regexp "1x8" $PROP_VALUE] } {
            set core16_virtual_link_width_hwtcl "x8"
        }  else {
            send_message error "Topology is not set"
        }
        ip_set_param "parameter.core16_virtual_link_width_hwtcl.value" $core16_virtual_link_width_hwtcl
        
        if { ${core16_func} == "Disable" } {
            ip_set_param "parameter.core16_virtual_link_rate_hwtcl.value" "Gen1 (2.5 Gbps)"
            ip_set_param "parameter.core16_virtual_link_width_hwtcl.value" "x1"
            ip_set_param "parameter.core16_pf0_auto_lane_flip_ctrl_en_hwtcl.value" 0
        } else {
            ip_set_param "parameter.core16_pf0_auto_lane_flip_ctrl_en_hwtcl.value" 1
        }
        # jkoe - trying to disable AUTO_LANE_FLIP_CTRL_EN for RP for 2x8 ed simulation
        if { $ed_generating_rp } {
            ip_set_param "parameter.core16_pf0_auto_lane_flip_ctrl_en_hwtcl.value" 0
        }
        #send_message info [ip_get "parameter.core16_enable_msi_interface_hwtcl.value"] ;
        #send_message info [ip_get "parameter.core16_virtual_pf0_msi_enable_hwtcl.value"] ;
   
   } elseif { $tile == "R-TILE" } {
   if { ${core16_func_mode_hwtcl} == "Disable" } {
        ip_set_param "parameter.core16_virtual_link_rate_hwtcl.value" "Gen1 (2.5 Gbps)"
        ip_set_param "parameter.core16_virtual_link_width_hwtcl.value" "x1"
        ip_set_param "parameter.core16_pf0_auto_lane_flip_ctrl_en_hwtcl.value" 0
    } else {
		if {  [regexp "Gen5" $PROP_VALUE] } {
			set core16_virtual_link_rate_hwtcl "Gen5 (32.0 Gbps)"
		} elseif {  [regexp "Gen4" $PROP_VALUE] } {
			set core16_virtual_link_rate_hwtcl "Gen4 (16.0 Gbps)"
		} elseif { [regexp "Gen3" $PROP_VALUE] } {
			# "Gen3 (8.0 Gbps)"
			set core16_virtual_link_rate_hwtcl "Gen3 (8.0 Gbps)"
		} else {
			send_message error "Topology is not set"
		}
		ip_set_param "parameter.core16_virtual_link_rate_hwtcl.value" $core16_virtual_link_rate_hwtcl
		
		if { [regexp "1x16" $PROP_VALUE] } {
			set core16_virtual_link_width_hwtcl "x16"
			send_message info "One x16 PCIe ports will be instantiated."
		} elseif { [regexp "2x8" $PROP_VALUE] } {
			set core16_virtual_link_width_hwtcl "x8"
			send_message info "Two x8 PCIe ports will be instantiated."
        } elseif { [regexp "1x8" $PROP_VALUE] } {
			set core16_virtual_link_width_hwtcl "x8"
			send_message info "One x8 PCIe ports will be instantiated."
		} elseif { [regexp "4x4" $PROP_VALUE] } {
			set core16_virtual_link_width_hwtcl "x4"
			send_message info "Four x4 PCIe ports will be instantiated."
		} elseif { [regexp "1x4" $PROP_VALUE] } {
			set core16_virtual_link_width_hwtcl "x4"
			send_message info "One x4 PCIe ports will be instantiated."  
		} elseif { [regexp "2x4" $PROP_VALUE] } {
			set core16_virtual_link_width_hwtcl "x4"
			send_message info "Two x4 PCIe ports will be instantiated."        
		} elseif { [regexp "Pipe Direct 8-channel" $PROP_VALUE] && [regexp "2x4" $PROP_VALUE] } { #topology 8a
			set core16_virtual_link_width_hwtcl "x4"
			send_message info "Two x4 PCIe ports will be instantiated."
		} elseif { [regexp "1x8" $PROP_VALUE] && [regexp "2x4" $PROP_VALUE] } { #topology 3
			set core16_virtual_link_width_hwtcl "x8"
			send_message info "One x8 and two x4 PCIe ports will be instantiated."
		} elseif { [regexp "Pipe Direct 8-channel" $PROP_VALUE] && [regexp "1x8" $PROP_VALUE] } { #topology 7a
			set core16_virtual_link_width_hwtcl "x8"
			send_message info "One x8 PCIe ports will be instantiated."
		} else {
			send_message error "Topology is not set"
		}
		ip_set_param "parameter.core16_virtual_link_width_hwtcl.value" $core16_virtual_link_width_hwtcl
		ip_set_param "parameter.core16_pf0_auto_lane_flip_ctrl_en_hwtcl.value" 1
      } 
   }
}

proc ::intel_pcie_ss_axi::parameters::validate_core16_virtual_cvp_mode_hwtcl { PROP_NAME PROP_VALUE core16_func_mode_hwtcl qhip_silicon_reva_revb_hwtcl hssi_ctr_is_cvp_enable_hwtcl core16_enable_power_mgnt_intf_hwtcl core16_virtual_rp_ep_mode_hwtcl core16_virtual_tlp_bypass_en_hwtcl} {
	#1409800040 1508297559 1508323145 1508912543 1508933505
	if { $core16_func_mode_hwtcl == "Disable" || $hssi_ctr_is_cvp_enable_hwtcl == 0} {
		ip_set_param "parameter.core16_virtual_cvp_mode_hwtcl.value" "cvp_disabled"
	} else {
		ip_set_param "parameter.core16_virtual_cvp_mode_hwtcl.value" "cvp_legacy"
		#send_message info "Enabling CVP automatically disables PCIe 0 Configuration Intercept Interface (CII), VIRTIO and Vendor Specific Extended capability."
		if {$core16_enable_power_mgnt_intf_hwtcl == 1 &&  $core16_virtual_rp_ep_mode_hwtcl == "Native Endpoint" && $core16_virtual_tlp_bypass_en_hwtcl == 0} {
			send_message info "p0_app_req_retry_en_i must be tied off to zero when enabling CVP."
		}
	}
}

proc ::intel_pcie_ss_axi::parameters::validate_core16_virtual_rp_ep_mode_hwtcl { PROP_NAME PROP_VALUE core16_topology_hwtcl } {
    set core4_0_tlp_bypass_en [ip_get "parameter.core4_0_virtual_tlp_bypass_en_hwtcl.value"]
    set core4_1_tlp_bypass_en [ip_get "parameter.core4_1_virtual_tlp_bypass_en_hwtcl.value"]
}

proc ::intel_pcie_ss_axi::parameters::validate_core16_enable_hotplug_hwtcl { PROP_NAME PROP_VALUE } {
    if { ($PROP_VALUE == 1 ) } {
	ip_set_param "parameter.core16_pf0_pcie_cap_power_indicator_hwtcl.value" 1
        ip_set_param "parameter.core16_pf0_pcie_cap_attention_indicator_button_hwtcl.value" 1
        ip_set_param "parameter.core16_pf0_pcie_cap_power_controller_hwtcl.value" 1      
        ip_set_param "parameter.core16_pf0_pcie_cap_mrl_sensor_hwtcl.value" 1
        ip_set_param "parameter.core16_pf0_pcie_cap_attention_indicator_hwtcl.value" 1
        ip_set_param "parameter.core16_pf0_pcie_cap_hot_plug_surprise_hwtcl.value" 1   
        ip_set_param "parameter.core16_pf0_pcie_cap_electromech_interlock_hwtcl.value" 1  
  
    } else {
	ip_set_param "parameter.core16_pf0_pcie_cap_power_indicator_hwtcl.value" 0
        ip_set_param "parameter.core16_pf0_pcie_cap_attention_indicator_button_hwtcl.value" 0
        ip_set_param "parameter.core16_pf0_pcie_cap_power_controller_hwtcl.value" 0      
        ip_set_param "parameter.core16_pf0_pcie_cap_mrl_sensor_hwtcl.value" 0
        ip_set_param "parameter.core16_pf0_pcie_cap_attention_indicator_hwtcl.value" 0
        ip_set_param "parameter.core16_pf0_pcie_cap_hot_plug_surprise_hwtcl.value" 0   
        ip_set_param "parameter.core16_pf0_pcie_cap_electromech_interlock_hwtcl.value" 0
     
    }
}
proc ::intel_pcie_ss_axi::parameters::validate_core16_crs_en_default_hwtcl { PROP_NAME PROP_VALUE } {
        switch $PROP_VALUE {
           0            { set idw_value 0 }
           1            { set idw_value 1 }
        }
        if { $PROP_NAME == "core16_crs_en_default_hwtcl"} {
            ip_set_param "parameter.core16_CRS_EN_DEFAULT.value" $idw_value
        }
        
}

proc ::intel_pcie_ss_axi::parameters::validate_core16_enable_rx_buffer_limit_ports_hwtcl   { PROP_NAME PROP_VALUE avmm_enabled_hwtcl} {

    set pcie_ss_func_mode_value         [ip_get "parameter.pcie_ss_func_mode_hwtcl.value"]
    if { $pcie_ss_func_mode_value == "Power User"} {   
        ip_set_param "parameter.core16_enable_rx_buffer_limit_ports_hwtcl.value" 0
        ip_set_param "parameter.core16_rxbuf_limit_posted_bypass_hwtcl.value"    0
        ip_set_param "parameter.core16_rxbuf_limit_nonposted_bypass_hwtcl.value" 0
        ip_set_param "parameter.core16_rxbuf_limit_cpl_bypass_hwtcl.value" 0
        
    if { $avmm_enabled_hwtcl } {
        ip_set_param "parameter.core16_rxbuf_limit_bypass_hwtcl.value" 0
    } else {    
      if { ($PROP_VALUE == 1) } {
        ip_set_param "parameter.core16_rxbuf_limit_bypass_hwtcl.value" 0
      } else {
        ip_set_param "parameter.core16_rxbuf_limit_bypass_hwtcl.value" 1
      }
     } 
    } else {
        ip_set_param "parameter.core16_enable_rx_buffer_limit_ports_hwtcl.value" 1 
        ip_set_param "parameter.core16_rxbuf_limit_posted_bypass_hwtcl.value" 0
        ip_set_param "parameter.core16_rxbuf_limit_nonposted_bypass_hwtcl.value" 0
        ip_set_param "parameter.core16_rxbuf_limit_cpl_bypass_hwtcl.value" 1        
      if { $avmm_enabled_hwtcl } {
        ip_set_param "parameter.core16_rxbuf_limit_bypass_hwtcl.value" 0
    } else {    
      if { ($PROP_VALUE == 1) } {
        ip_set_param "parameter.core16_rxbuf_limit_bypass_hwtcl.value" 0
      } else {
        ip_set_param "parameter.core16_rxbuf_limit_bypass_hwtcl.value" 1
      }
    }
  }
}
proc ::intel_pcie_ss_axi::parameters::validate_core16_rxbuf_limit_bypass_hwtcl { PROP_NAME PROP_VALUE core16_enable_rx_buffer_limit_ports_hwtcl avmm_enabled_hwtcl core16_rxbuf_limit_posted_bypass_hwtcl core16_rxbuf_limit_nonposted_bypass_hwtcl core16_rxbuf_limit_cpl_bypass_hwtcl } {
    set rxbuf_features_enablement [ip_get "parameter.rxbuf_features_enablement_full.value"]
    if { $avmm_enabled_hwtcl } {
        ip_set_param "parameter.core16_rxbuf_limit_bypass_hwtcl.value" "disable bypass"
    } else {
        if { ($rxbuf_features_enablement == 1) } {
            if { ($core16_enable_rx_buffer_limit_ports_hwtcl == 1 ) } {
                if {$core16_rxbuf_limit_posted_bypass_hwtcl==0 && $core16_rxbuf_limit_nonposted_bypass_hwtcl==0 && $core16_rxbuf_limit_cpl_bypass_hwtcl==0} {
                    ip_set_param "parameter.core16_rxbuf_limit_bypass_hwtcl.value" "disable bypass"
                } elseif {$core16_rxbuf_limit_posted_bypass_hwtcl==1 && $core16_rxbuf_limit_nonposted_bypass_hwtcl==0 && $core16_rxbuf_limit_cpl_bypass_hwtcl==0} {
                    ip_set_param "parameter.core16_rxbuf_limit_bypass_hwtcl.value" "posted bypass"
                } elseif {$core16_rxbuf_limit_posted_bypass_hwtcl==0 && $core16_rxbuf_limit_nonposted_bypass_hwtcl==1 && $core16_rxbuf_limit_cpl_bypass_hwtcl==0} {
                    ip_set_param "parameter.core16_rxbuf_limit_bypass_hwtcl.value" "nonposted bypass"
                } elseif {$core16_rxbuf_limit_posted_bypass_hwtcl==1 && $core16_rxbuf_limit_nonposted_bypass_hwtcl==1 && $core16_rxbuf_limit_cpl_bypass_hwtcl==0} {
                    ip_set_param "parameter.core16_rxbuf_limit_bypass_hwtcl.value" "posted / nonposted bypass"
                } elseif {$core16_rxbuf_limit_posted_bypass_hwtcl==0 && $core16_rxbuf_limit_nonposted_bypass_hwtcl==0 && $core16_rxbuf_limit_cpl_bypass_hwtcl==1} {
                    ip_set_param "parameter.core16_rxbuf_limit_bypass_hwtcl.value" "cpl bypass"
                } elseif {$core16_rxbuf_limit_posted_bypass_hwtcl==1 && $core16_rxbuf_limit_nonposted_bypass_hwtcl==0 && $core16_rxbuf_limit_cpl_bypass_hwtcl==1} {
                    ip_set_param "parameter.core16_rxbuf_limit_bypass_hwtcl.value" "posted / cpl bypass"
                } elseif {$core16_rxbuf_limit_posted_bypass_hwtcl==0 && $core16_rxbuf_limit_nonposted_bypass_hwtcl==1 && $core16_rxbuf_limit_cpl_bypass_hwtcl==1} {
                    ip_set_param "parameter.core16_rxbuf_limit_bypass_hwtcl.value" "nonposted / cpl bypass"
                } else {
                    send_message error "Disabling PCIe0 Rx Buffer Limit Ports will automatically bypass Posted, Non-Posted and CplD Packets."
                    #ip_set_param "parameter.core16_rxbuf_limit_bypass_hwtcl.value" "posted / nonposted / cpl bypass"
                }
            } else {
                ip_set_param "parameter.core16_rxbuf_limit_bypass_hwtcl.value" "posted / nonposted / cpl bypass"
            }
        } else {
            if { ($core16_enable_rx_buffer_limit_ports_hwtcl == 1 ) } {
                ip_set_param "parameter.core16_rxbuf_limit_bypass_hwtcl.value" "disable bypass"
            } else {
                ip_set_param "parameter.core16_rxbuf_limit_bypass_hwtcl.value" "posted / nonposted / cpl bypass"
            }
        }
    }
}

proc ::intel_pcie_ss_axi::parameters::validate_core16_virtual_tlp_bypass_en_hwtcl { PROP_NAME PROP_VALUE  } {
}

proc ::intel_pcie_ss_axi::parameters::validate_core16_total_pf_count_hwtcl {PROP_NAME PROP_VALUE core16_func_mode_hwtcl core16_total_pf_count_hwtcl } {
    set tile [ip_get "parameter.TILE.value"]

    if { $tile == "P-TILE" } {
        set core16_total_pf_count_hwtcl $PROP_VALUE
        set core16_func [ip_get "parameter.core16_func_mode_hwtcl.value"]
        if { ${core16_func} == "Enable" } {
            for {set i 0} {$i < [expr {$core16_total_pf_count_hwtcl} ]} {incr i} {
                ip_set_param "parameter.core16_virtual_pf${i}_enable_hwtcl.value" 1
            }
            for {set i 8} {$i >= [expr {$core16_total_pf_count_hwtcl} ]} {incr i -1} {
                ip_set_param "parameter.core16_virtual_pf${i}_enable_hwtcl.value" 0
            }
        }
    } elseif { $tile == "R-TILE" } {
       if { $core16_func_mode_hwtcl == "Enable" } {
        for {set i 0} {$i < [expr {$core16_total_pf_count_hwtcl} ]} {incr i} {
            ip_set_param "parameter.core16_virtual_pf${i}_enable_hwtcl.value" 1
        }
        for {set i 8} {$i >= [expr {$core16_total_pf_count_hwtcl} ]} {incr i -1} {
            ip_set_param "parameter.core16_virtual_pf${i}_enable_hwtcl.value" 0
        }
    } else {
		for {set i 0} {$i < 8} {incr i} {
            ip_set_param "parameter.core16_virtual_pf${i}_enable_hwtcl.value" 0
        }
	 }
     
    } elseif { $tile == "F-TILE" } {
        set core16_total_pf_count_hwtcl $PROP_VALUE
        set core16_func [ip_get "parameter.core16_func_mode_hwtcl.value"]
        set topology    [ip_get "parameter.core16_topology_hwtcl.value"]
        if { ${core16_func} == "Enable" } {
            if { [regexp "1x4" $topology] } {
                ip_set "parameter.core16_total_pf_count_hwtcl.ALLOWED_RANGES" {1:4}
            } else {
                ip_set "parameter.core16_total_pf_count_hwtcl.ALLOWED_RANGES" {1:8}
            } 
            for {set i 0} {$i < [expr {$core16_total_pf_count_hwtcl} ]} {incr i} {
                ip_set_param "parameter.core16_virtual_pf${i}_enable_hwtcl.value" 1
            }
            for {set i 8} {$i >= [expr {$core16_total_pf_count_hwtcl} ]} {incr i -1} {
                ip_set_param "parameter.core16_virtual_pf${i}_enable_hwtcl.value" 0
            }
        }
    }
}

proc ::intel_pcie_ss_axi::parameters::validate_core16_total_pf_count_width_hwtcl  { PROP_NAME PROP_VALUE core16_total_pf_count_hwtcl } {
    set num_pfcount [expr $core16_total_pf_count_hwtcl]
    if { $num_pfcount > 0 } {
        set num_pfcount [expr $num_pfcount - 1]
        set width  [expr $num_pfcount == 0 ? 1 : 0]
        while {$num_pfcount != 0} {
            set num_pfcount [expr $num_pfcount >> 1]
            set width  [expr $width + 1]
        }
    } else {
        set width 1
    }
    ip_set_param "parameter.${PROP_NAME}.value" $width
}
proc ::intel_pcie_ss_axi::parameters::validate_core16_vf_bar_type_VISIBLE_hwtcl {PROP_NAME PROP_VALUE} {
	regexp {pf.} $PROP_NAME pf_num
	set core16_virtual_pfi_enable_hwtcl [ip_get "parameter.core16_virtual_${pf_num}_enable_hwtcl.value"]
    if { $core16_virtual_pfi_enable_hwtcl == 1} {
		set core16_pf_bar_val  [ip_get "parameter.core16_${pf_num}_sriov_vf_bar0_type_hwtcl_r.value"]
        set core16_pf_bar2_val [ip_get "parameter.core16_${pf_num}_sriov_vf_bar2_type_hwtcl_r.value"]
        set core16_pf_bar4_val [ip_get "parameter.core16_${pf_num}_sriov_vf_bar4_type_hwtcl_r.value"]
        
        if { [regexp "64-bit" $core16_pf_bar_val] }  {
			ip_set_param "parameter.core16_${pf_num}_sriov_vf_bar1_type_hwtcl_r.value" "Disabled"
            ip_set_param "parameter.core16_${pf_num}_sriov_vf_bar1_type_user_hwtcl.ENABLED" false
        } else {
            ip_set_param "parameter.core16_${pf_num}_sriov_vf_bar1_type_user_hwtcl.ENABLED" true
        }
        if { [regexp "64-bit" $core16_pf_bar2_val] }  {
			ip_set_param "parameter.core16_${pf_num}_sriov_vf_bar3_type_hwtcl_r.value" "Disabled"
            ip_set_param "parameter.core16_${pf_num}_sriov_vf_bar3_type_user_hwtcl.ENABLED" false
        } else {
            ip_set_param "parameter.core16_${pf_num}_sriov_vf_bar3_type_user_hwtcl.ENABLED" true
        } 
        if { [regexp "64-bit" $core16_pf_bar4_val] }  {
			ip_set_param "parameter.core16_${pf_num}_sriov_vf_bar5_type_hwtcl_r.value" "Disabled"
            ip_set_param "parameter.core16_${pf_num}_sriov_vf_bar5_type_user_hwtcl.ENABLED" false
        } else {
            ip_set_param "parameter.core16_${pf_num}_sriov_vf_bar5_type_user_hwtcl.ENABLED" true
        } 
	}
}
proc ::intel_pcie_ss_axi::parameters::validate_core16_vf_bar_type_hwtcl {PROP_NAME PROP_VALUE core16_func_mode_hwtcl core16_virtual_rp_ep_mode_hwtcl} {	 #ARG: core16_virtual_pf${pf}_enable_hwtcl core16_pf${pf}_sriov_vf_bar${i}_type_user_hwtcl core16_pf${pf}_sriov_vf_bar${i}_address_width_hwtcl
    if { $core16_func_mode_hwtcl == "Disable" || $core16_virtual_rp_ep_mode_hwtcl == "Root Port"} {
        # if in rootport or core 16 is disabled set all BAR types to disabled and size to N/A

        # loop through all pf 0-7
        for {set pf 0} {$pf < 8} {incr pf 1} {
            # loop through all bars 0-5
            for {set i 0} {$i <= 5} {incr i 1} {
                #ip_set_param "parameter.core16_pf${pf}_sriov_vf_bar${i}_type_hwtcl.value" "Disabled"
                #ip_set_param "parameter.core16_pf${pf}_bar${i}_address_width_hwtcl.value" 0
                ip_set_param "parameter.core16_pf${pf}_sriov_vf_bar${i}_mask_integer_hwtcl.value" "0"
				ip_set_param "parameter.core16_pf${pf}_sriov_vf_bar${i}_type_hwtcl_r.value" "Disabled"
                    ip_set_param "parameter.core16_pf${pf}_sriov_vf_bar${i}_address_width_int_hwtcl.value" 0

            }
        }
    } else {
        # else set them to user_hwtcl values

        # loop through all pf 0-7
        for {set pf 0} {$pf < 8} {incr pf 1} {
            set core16_virtual_pfi_enable_hwtcl [ip_get "parameter.core16_virtual_pf${pf}_enable_hwtcl.value"]
            if { $core16_virtual_pfi_enable_hwtcl == 1} {
                # loop through all bars 0-5
                set core16_prev_bar_type "Disable"
                set core16_prev_bar_addr_width 0
                for {set i 0} {$i <= 5} {incr i 1} {
                    set core16_vf_bar_type_user_hwtcl [get_parameter_value core16_pf${pf}_sriov_vf_bar${i}_type_user_hwtcl]
                    set core16_vf_bar_address_width_user_hwtcl [get_parameter_value core16_pf${pf}_sriov_vf_bar${i}_address_width_hwtcl]
					#ALLOWED_RANGES
					if {[regexp "64-bit" $core16_vf_bar_type_user_hwtcl]} {
						ip_set_param "parameter.core16_pf${pf}_sriov_vf_bar${i}_address_width_hwtcl.ALLOWED_RANGES" {"0:N/A" "8: 256 Bytes - 8 bits" "9: 512 Bytes - 9 bits" "10: 1 KByte - 10 bits" "11: 2 KBytes - 11 bits" "12: 4 KBytes - 12 bits" "13: 8 KBytes - 13 bits" "14: 16 KBytes - 14 bits" "15: 32 KBytes - 15 bits" "16: 64 KBytes - 16 bits" "17: 128 KBytes - 17 bits" "18: 256 KBytes - 18 bits" "19: 512 KBytes - 19 bits" "20: 1 MByte - 20 bits" "21: 2 MBytes - 21 bits" "22: 4 MBytes - 22 bits" "23: 8 MBytes - 23 bits" "24: 16 MBytes - 24 bits" "25: 32 MBytes - 25 bits" "26: 64 MBytes - 26 bits" "27: 128 MBytes - 27 bits" "28: 256 MBytes - 28 bits" "29: 512 MBytes - 29 bits" "30: 1 GByte - 30 bits" "31: 2 GBytes - 31 bits" "32: 4 GBytes - 32 bits" "33: 8 GBytes - 33 bits" "34: 16 GBytes - 34 bits" "35: 32 GBytes - 35 bits" "36: 64 GBytes - 36 bits" "37: 128 GBytes - 37 bits" "38: 256 GBytes - 38 bits" "39: 512 GBytes - 39 bits" "40: 1 TByte - 40 bits" "41: 2 TBytes - 41 bits" "42: 4 TBytes - 42 bits" "43: 8 TBytes - 43 bits" "44: 16 TBytes - 44 bits" "45: 32 TBytes - 45 bits" "46: 64 TBytes - 46 bits" "47: 128 TBytes - 47 bits" "48: 256 TBytes - 48 bits" "49: 512 TBytes - 49 bits" "50: 1 PByte - 50 bits" "51: 2 PBytes - 51 bits" "52: 4 PBytes - 52 bits" "53: 8 PBytes - 53 bits" "54: 16 PBytes - 54 bits" "55: 32 PBytes - 55 bits" "56: 64 PBytes - 56 bits" "57: 128 PBytes - 57 bits" "58: 256 PBytes - 58 bits" "59: 512 PBytes - 59 bits" "60: 1 EByte - 60 bits" "61: 2 EBytes - 61 bits" "62: 4 EBytes - 62 bits" "63: 8 EBytes - 63 bits" "64: 16 EBytes - 64 bits"}
					} elseif {[regexp "32-bit" $core16_vf_bar_type_user_hwtcl]} {
						ip_set_param "parameter.core16_pf${pf}_sriov_vf_bar${i}_address_width_hwtcl.ALLOWED_RANGES" {"0:N/A" "8: 256 Bytes - 8 bits" "9: 512 Bytes - 9 bits" "10: 1 KByte - 10 bits" "11: 2 KBytes - 11 bits" "12: 4 KBytes - 12 bits" "13: 8 KBytes - 13 bits" "14: 16 KBytes - 14 bits" "15: 32 KBytes - 15 bits" "16: 64 KBytes - 16 bits" "17: 128 KBytes - 17 bits" "18: 256 KBytes - 18 bits" "19: 512 KBytes - 19 bits" "20: 1 MByte - 20 bits" "21: 2 MBytes - 21 bits" "22: 4 MBytes - 22 bits" "23: 8 MBytes - 23 bits" "24: 16 MBytes - 24 bits" "25: 32 MBytes - 25 bits" "26: 64 MBytes - 26 bits" "27: 128 MBytes - 27 bits" "28: 256 MBytes - 28 bits" "29: 512 MBytes - 29 bits" "30: 1 GByte - 30 bits" "31: 2 GBytes - 31 bits" "32: 4 GBytes - 32 bits"}
					}

                    # Need to update to support full 64bit address width					
                    if { $i == 0 || $i == 2 || $i == 4} {
                        if { $core16_vf_bar_address_width_user_hwtcl >= 32 } {
							set core16_vf_bar_mask "32"
                        } elseif { $core16_vf_bar_address_width_user_hwtcl == 0 } {
							set core16_vf_bar_mask "0"
                        } else {
							set core16_vf_bar_mask [format %d $core16_vf_bar_address_width_user_hwtcl]
                        }
                        # no actual 
                        set core16_prev_bar_type $core16_vf_bar_type_user_hwtcl
                        set core16_prev_bar_addr_width $core16_vf_bar_address_width_user_hwtcl 
                    }
                    
                    if { $i == 1 || $i == 3 || $i == 5} {
                        if { [regexp "64-bit" $core16_prev_bar_type] } { 
                            if { $core16_prev_bar_addr_width > 32 } {
								set core16_vf_bar_mask [format %d [expr int($core16_prev_bar_addr_width) - 32] ]
                            } else {
								set core16_vf_bar_mask "0"
                            }
                        } elseif { $core16_vf_bar_address_width_user_hwtcl == 0 } {
							set core16_vf_bar_mask "0"							                       
                        } else  {
                            set core16_vf_bar_mask [format %d $core16_vf_bar_address_width_user_hwtcl]
                        }
                    }
                    ip_set_param "parameter.core16_pf${pf}_sriov_vf_bar${i}_type_hwtcl_r.value" $core16_vf_bar_type_user_hwtcl
                    ip_set_param "parameter.core16_pf${pf}_sriov_vf_bar${i}_mask_integer_hwtcl.value" $core16_vf_bar_mask
                    ip_set_param "parameter.core16_pf${pf}_sriov_vf_bar${i}_address_width_int_hwtcl.value" $core16_vf_bar_address_width_user_hwtcl
                }
            } else {
                for {set i 0} {$i <= 5} {incr i 1} {
                    ip_set_param "parameter.core16_pf${pf}_sriov_vf_bar${i}_type_hwtcl_r.value" "Disabled"
                    ip_set_param "parameter.core16_pf${pf}_sriov_vf_bar${i}_mask_integer_hwtcl.value" "0"
                    ip_set_param "parameter.core16_pf${pf}_sriov_vf_bar${i}_address_width_int_hwtcl.value" 0
                }
            }
        }
    }
}

proc ::intel_pcie_ss_axi::parameters::validate_core16_total_vf_count_hwtcl { PROP_NAME PROP_VALUE core16_enable_sriov_hwtcl  core16_total_pf_count_hwtcl  } {
    set tile [ip_get "parameter.TILE.value"]

    if { $tile == "P-TILE" ||$tile == "R-TILE" } {
        set core16_total_vf_count 0
        if { $core16_enable_sriov_hwtcl == 1 } {
            set core16_pf0_vf_count_hwtcl [ip_get "parameter.core16_pf0_vf_count_hwtcl.value"]
            set core16_total_vf_count [ expr {$core16_total_vf_count} + {$core16_pf0_vf_count_hwtcl} ]
            #get vf count for all pfs
            for { set i 1 } { $i < [expr {$core16_total_pf_count_hwtcl}] } { incr i} {
                set core16_virtual_pfi_sriov_enable_hwtcl [ip_get "parameter.core16_virtual_pf${i}_sriov_enable_hwtcl.value"]
                if { $core16_virtual_pfi_sriov_enable_hwtcl} {
                    set core16_pfi_vf_count_hwtcl [ip_get "parameter.core16_pf${i}_vf_count_hwtcl.value"]
                    set core16_total_vf_count [ expr {$core16_total_vf_count} + {$core16_pfi_vf_count_hwtcl} ]
                }
            }
        }
        ip_set_param "parameter.core16_total_vf_count_hwtcl.value" $core16_total_vf_count
        if {$core16_total_vf_count > 2048} {
            send_message error "Total number of core16_virtual functions cannot exceed 2048."
        }
        
       if {($core16_enable_sriov_hwtcl == 1) && ($core16_total_pf_count_hwtcl > 0)} {
          if {($core16_total_vf_count == 0)} {
             ip_message warning "When SRIOV is enabled, the total number of VFs across all enabled PFs must be greater than 0"
          }
       }
    } elseif { $tile == "F-TILE" } {
        set core16_total_vf_count 0
        if { $core16_enable_sriov_hwtcl == 1 } {
            set core16_pf0_vf_count_hwtcl [ip_get "parameter.core16_pf0_vf_count_hwtcl.value"]
            set core16_total_vf_count [ expr {$core16_total_vf_count} + {$core16_pf0_vf_count_hwtcl} ]
            #get vf count for all pfs
            for { set i 1 } { $i < [expr {$core16_total_pf_count_hwtcl}] } { incr i} {
                set core16_virtual_pfi_sriov_enable_hwtcl [ip_get "parameter.core16_virtual_pf${i}_sriov_enable_hwtcl.value"]
                if { $core16_virtual_pfi_sriov_enable_hwtcl} {
                    set core16_pfi_vf_count_hwtcl [ip_get "parameter.core16_pf${i}_vf_count_hwtcl.value"]
                    set core16_total_vf_count [ expr {$core16_total_vf_count} + {$core16_pfi_vf_count_hwtcl} ]
                }
            }
        }
    
        set topology    [ip_get "parameter.core16_topology_hwtcl.value"]
        ip_set_param "parameter.core16_total_vf_count_hwtcl.value" $core16_total_vf_count
        if { [regexp "1x4" $topology] } {
            if {$core16_total_vf_count > 16} {
                send_message error "Total number of core16_virtual functions cannot exceed 16."
            }
        } else {
            if {$core16_total_vf_count > 2048} {
            send_message error "Total number of core16_virtual functions cannot exceed 2048."
            }
        }
        
       if {($core16_enable_sriov_hwtcl == 1) && ($core16_total_pf_count_hwtcl > 0)} {
          if {($core16_total_vf_count == 0)} {
            ip_message warning "SRIOV is enabled and the total number of VFs across all enabled PFs is 0"
          }
       }
    }
}

proc ::intel_pcie_ss_axi::parameters::validate_core16_total_vf_count_width_hwtcl { PROP_NAME PROP_VALUE core16_total_vf_count_hwtcl } {
    set num_vfcount [expr $core16_total_vf_count_hwtcl]
    if { $num_vfcount > 0 } {
        set num_vfcount [expr $num_vfcount - 1]
        set width [expr $num_vfcount == 0 ? 1 : 0]
        while {$num_vfcount != 0} {
            set num_vfcount [expr $num_vfcount >> 1]
            set width  [expr $width + 1]
        }
    } else {
        set width 1
    }
    ip_set_param "parameter.${PROP_NAME}.value" $width
}

proc ::intel_pcie_ss_axi::parameters::validate_core16_virtual_pfi_sriov_enable_hwtcl {PROP_NAME PROP_VALUE core16_enable_sriov_hwtcl core16_total_pf_count_hwtcl core16_virtual_pf1_sriov_enable_hwtcl } {
    for {set i 0} { $i < 8 } {incr i} {
        set core16_virtual_pfi_enable_hwtcl [ip_get "parameter.core16_virtual_pf${i}_enable_hwtcl.value"]
        if { $core16_virtual_pfi_enable_hwtcl == 1 && $core16_enable_sriov_hwtcl == 1} {
            ip_set_param "parameter.core16_virtual_pf${i}_sriov_enable_hwtcl.value" 1
        } else {
            ip_set_param "parameter.core16_virtual_pf${i}_sriov_enable_hwtcl.value" 0
        }
    }
}
proc ::intel_pcie_ss_axi::parameters::validate_core16_pfi_sriov_sup_page_size_hwtcl { PROP_NAME PROP_VALUE core16_enable_sriov_hwtcl core16_virtual_pf1_sriov_enable_hwtcl} {
    if {$core16_enable_sriov_hwtcl == 0 } {
        ip_set_param "parameter.$PROP_NAME.value" "0KB"
    } else {
        for {set i 0} { $i < 8 } {incr i} {
            set core16_virtual_pfi_enable_hwtcl [ip_get "parameter.core16_virtual_pf${i}_enable_hwtcl.value"]
            if { $core16_virtual_pfi_enable_hwtcl == 1 } {
                ip_set_param "parameter.core16_pf${i}_sriov_sup_page_size_hwtcl.value" "4KB, 8KB, 64KB, 256KB, 1MB, 4MB"
            } else {
                ip_set_param "parameter.core16_pf${i}_sriov_sup_page_size_hwtcl.value" "0KB"
            }
        }
    }
}


proc ::intel_pcie_ss_axi::parameters::validate_core16_pfi_rom_bar_enabled_hwtcl {PROP_NAME PROP_VALUE } {
    for {set i 0} {$i < 8} {incr i} {
        set core16_pfi_expansion_base_address_register_hwtcl      [ip_get "parameter.core16_pf${i}_expansion_base_address_register_hwtcl.value"]
        if { ${core16_pfi_expansion_base_address_register_hwtcl} ==0  }  {
            ip_set_param "parameter.core16_pf${i}_rom_bar_enabled_hwtcl.value" "disable"
        } else {
            ip_set_param "parameter.core16_pf${i}_rom_bar_enabled_hwtcl.value" "enable"
        }
    }
}
proc ::intel_pcie_ss_axi::parameters::validate_core16_pfi_sriov_vf_offset_ari_cs2_hwtcl { PROP_NAME PROP_VALUE core16_total_pf_count_hwtcl core16_enable_sriov_hwtcl } {
    set total_vf_count_temp 0
     for {set i 0} { $i < [expr ${core16_total_pf_count_hwtcl} ] } {incr i} {
          if { $core16_enable_sriov_hwtcl == 1 } {
            ip_set_param "parameter.core16_pf${i}_sriov_vf_offset_ari_cs2_hwtcl.value" [expr ${core16_total_pf_count_hwtcl} +  ${total_vf_count_temp} - ${i} ]
            ip_set_param "parameter.core16_pf${i}_sriov_vf_offset_position_nonari_hwtcl.value" [expr ${core16_total_pf_count_hwtcl} +  ${total_vf_count_temp} - ${i} ]
            ip_set_param "parameter.core16_pf${i}_shadow_sriov_vf_stride_ari_cs2_hwtcl.value" 1
            ip_set_param "parameter.core16_pf${i}_sriov_vf_stride_nonari_hwtcl.value" 1
            set core16_pfi_vf_count_hwtcl [ip_get "parameter.core16_pf${i}_vf_count_hwtcl.value"]
            set total_vf_count_temp [expr ${total_vf_count_temp} + ${core16_pfi_vf_count_hwtcl} ]
          } else {
            ip_set_param "parameter.core16_pf${i}_sriov_vf_offset_ari_cs2_hwtcl.value" 0
            ip_set_param "parameter.core16_pf${i}_sriov_vf_offset_position_nonari_hwtcl.value" 0
            ip_set_param "parameter.core16_pf${i}_shadow_sriov_vf_stride_ari_cs2_hwtcl.value" 0
            ip_set_param "parameter.core16_pf${i}_sriov_vf_stride_nonari_hwtcl.value" 0
          }
      }
}



######cap parameter validation callbacks
proc ::intel_pcie_ss_axi::parameters::validate_core16_virtual_pf0_dlink_cap_enable_hwtcl { PROP_NAME PROP_VALUE } {
     set core16_func [ip_get "parameter.core16_func_mode_hwtcl.value"]
     if { ${core16_func} == "Enable" } {
         ip_set_param "parameter.core16_virtual_pf0_dlink_cap_enable_hwtcl.value" 1
     } else {
         ip_set_param "parameter.core16_virtual_pf0_dlink_cap_enable_hwtcl.value" 0
     }
}
proc ::intel_pcie_ss_axi::parameters::validate_core16_pf_pme_support_hwtcl { PROP_NAME PROP_VALUE core16_total_pf_count_hwtcl } {
    set core16_pf_count [ip_get "parameter.core16_total_pf_count_hwtcl.value"]
    for {set i 1} { $i < ${core16_pf_count} } {incr i} {
        ip_set_param "parameter.core16_pf${i}_pme_support_hwtcl.value" 15
    }
    for {set i ${core16_pf_count}} { $i < 8 } {incr i} {
        ip_set_param "parameter.core16_pf${i}_pme_support_hwtcl.value" 0
    }
}
proc ::intel_pcie_ss_axi::parameters::validate_core16_virtual_maxpayload_size_hwtcl { PROP_NAME PROP_VALUE core16_func_mode_hwtcl } {
    set core16_func [ip_get "parameter.core16_func_mode_hwtcl.value"]
    if { ${core16_func} == "Enable" } {
        ip_set_param "parameter.core16_maxpayload_size_hwtcl.value" $PROP_VALUE
    } else {
        ip_set_param "parameter.core16_maxpayload_size_hwtcl.value" 128
    }
}
proc ::intel_pcie_ss_axi::parameters::validate_core16_cap_ext_tag_supp_user_hwtcl { PROP_NAME PROP_VALUE core16_total_pf_count_hwtcl core16_enable_sriov_hwtcl } {
    for {set i 0} { $i < 8 } {incr i} {
        set core16_virtual_pfi_enable_hwtcl [ip_get "parameter.core16_virtual_pf${i}_enable_hwtcl.value"]
        if { ${core16_virtual_pfi_enable_hwtcl} == 1 } {
            ip_set_param "parameter.core16_pf${i}_pcie_cap_ext_tag_supp_hwtcl.value" $PROP_VALUE
        } else {
            ip_set_param "parameter.core16_pf${i}_pcie_cap_ext_tag_supp_hwtcl.value" 0
        }
    }
}
proc ::intel_pcie_ss_axi::parameters::validate_core16_flr_cap_user_hwtcl { PROP_NAME PROP_VALUE core16_enable_sriov_hwtcl core16_virtual_rp_ep_mode_integer_hwtcl core16_virtual_tlp_bypass_en_hwtcl } {
    if { $core16_virtual_rp_ep_mode_integer_hwtcl == 1 || $core16_virtual_tlp_bypass_en_hwtcl == 1} {
        ip_set_param "parameter.core16_flr_cap_hwtcl.value" 0
    } elseif { $core16_enable_sriov_hwtcl == 1 } {
        send_message info "PCIe0: Enabling SR-IOV automatically enables FLR."
        ip_set_param "parameter.core16_flr_cap_hwtcl.value" 1
    } else {
        ip_set_param "parameter.core16_flr_cap_hwtcl.value" $PROP_VALUE
    }
    
    set core16_flr_cap_hwtcl [ip_get "parameter.core16_flr_cap_hwtcl.value"]
    for {set i 0} { $i < 8 } {incr i} {
        set core16_virtual_pfi_enable_hwtcl [ip_get "parameter.core16_virtual_pf${i}_enable_hwtcl.value"]
        if { ${core16_virtual_pfi_enable_hwtcl} == 1 } {
            ip_set_param "parameter.core16_pf${i}_pcie_cap_flr_cap_hwtcl.value" $core16_flr_cap_hwtcl
        } else {
            ip_set_param "parameter.core16_pf${i}_pcie_cap_flr_cap_hwtcl.value" 0
        }
    }
}
proc ::intel_pcie_ss_axi::parameters::validate_core16_user_vsec_cap_enable_hwtcl { PROP_NAME PROP_VALUE core16_total_pf_count_hwtcl  } {
    for {set i 0} { $i < 8 } {incr i} {
        set core16_virtual_pfi_enable_hwtcl [ip_get "parameter.core16_virtual_pf${i}_enable_hwtcl.value"]
        if { ${core16_virtual_pfi_enable_hwtcl} == 1 } {
            ip_set_param "parameter.core16_virtual_pf${i}_user_vsec_cap_enable_hwtcl.value" $PROP_VALUE
        } else {
            ip_set_param "parameter.core16_virtual_pf${i}_user_vsec_cap_enable_hwtcl.value" 0
        }
    }
}
proc ::intel_pcie_ss_axi::parameters::validate_core16_user_vsec_cap_enable_hwtcl_r { PROP_NAME PROP_VALUE core16_total_pf_count_hwtcl  } {
    for {set i 0} { $i < 8 } {incr i} {
        set core16_virtual_pfi_enable_hwtcl [ip_get "parameter.core16_virtual_pf${i}_enable_hwtcl.value"]
        if { ${core16_virtual_pfi_enable_hwtcl} == 1 } {
            ip_set_param "parameter.core16_virtual_pf${i}_user_vsec_cap_enable_hwtcl.value" $PROP_VALUE
        } else {
            ip_set_param "parameter.core16_virtual_pf${i}_user_vsec_cap_enable_hwtcl.value" 0
        }
    }
}

proc ::intel_pcie_ss_axi::parameters::validate_core16_pf0_pcie_cap_port_num_hwtcl { PROP_NAME PROP_VALUE core16_func_mode_hwtcl } {
    set core16_func [ip_get "parameter.core16_func_mode_hwtcl.value"]
    if { ${core16_func} == "Enable" } {
        ip_set_param "parameter.core16_cap_port_num_hwtcl.value" $PROP_VALUE
    } else {
        ip_set_param "parameter.core16_cap_port_num_hwtcl.value" 0
    }
}
proc ::intel_pcie_ss_axi::parameters::validate_core16_pf0_user_pcie_cap_slot_clk_config_hwtcl { PROP_NAME PROP_VALUE core16_total_pf_count_hwtcl core16_func_mode_hwtcl } {
    set total_pf_count [ip_get "parameter.core16_total_pf_count_hwtcl.value"]
    set core16_func [ip_get "parameter.core16_func_mode_hwtcl.value"]
    set virtual_sris_enable_en_hwtcl [ip_get "parameter.virtual_sris_enable_en_hwtcl.value"]
    
    for {set i 0} { $i < 8 } {incr i} {
        if { $i < $total_pf_count} {
            if { ${core16_func} == "Enable" && $virtual_sris_enable_en_hwtcl == 0 } {
                ip_set_param "parameter.core16_pf${i}_user_pcie_cap_slot_clk_config_hwtcl.value" $PROP_VALUE
            } else {
                ip_set_param "parameter.core16_pf${i}_user_pcie_cap_slot_clk_config_hwtcl.value" 0
            }
        } else {
            ip_set_param "parameter.core16_pf${i}_user_pcie_cap_slot_clk_config_hwtcl.value" 0
        }
    }
}
proc ::intel_pcie_ss_axi::parameters::validate_core16_virtual_pfi_msi_enable_hwtcl { PROP_NAME PROP_VALUE core16_total_pf_count_hwtcl core16_virtual_rp_ep_mode_hwtcl core16_virtual_tlp_bypass_en_hwtcl } {
    set tile [ip_get "parameter.TILE.value"]
    #variable pf_num
    if { $tile == "P-TILE" } {
        set msi_interface_enable 0
        for {set i 0} { $i < 8 } {incr i} {
            set core16_virtual_pfi_enable_hwtcl [ip_get "parameter.core16_virtual_pf${i}_enable_hwtcl.value"]
            if { $core16_virtual_pfi_enable_hwtcl == 1 } {
                if { [get_parameter_value core16_pf${i}_virtio_capability_present_hwtcl] || [get_parameter_value core16_pf${i}vf_virtio_capability_present_hwtcl] } {
                    if { [get_parameter_value core16_virtual_pf${i}_msi_enable_hwtcl] } {
                        send_message info "Enabling VIRTIO automatically disables MSI. (PCIe0 PF{$i})"
                        ip_set_param "parameter.core16_virtual_pf${i}_msi_enable_hwtcl.value" 0
                    }
                } else {
                    set core16_virtual_pfi_msi_enable_user_hwtcl [get_parameter_value core16_virtual_pf${i}_msi_enable_user_hwtcl]
                    ip_set_param "parameter.core16_virtual_pf${i}_msi_enable_hwtcl.value" $core16_virtual_pfi_msi_enable_user_hwtcl
                    if { $core16_virtual_pfi_msi_enable_user_hwtcl == 1} {
                        set msi_interface_enable 1
                    }
                }
            } else {
                ip_set_param "parameter.core16_virtual_pf${i}_msi_enable_hwtcl.value" 0
            }
        }
        #disable MSI in Root Port Mode
        if { $core16_virtual_rp_ep_mode_hwtcl == "Root Port" || $core16_virtual_tlp_bypass_en_hwtcl == 1} {
            ip_set_param "parameter.core16_enable_msi_interface_hwtcl.value" 0
        } else {
            ip_set_param "parameter.core16_enable_msi_interface_hwtcl.value" $msi_interface_enable
        }
    } elseif {$tile == "F-TILE" ||$tile =="R-TILE"} {
        #vww19 added, skip if param is core16_enable_msi_interface_hwtcl for ftile ss
        if {$PROP_NAME != "core16_enable_msi_interface_hwtcl"} {
            regexp {pf.} $PROP_NAME pf_num
            set i [regexp -all -inline -- {[0-9]+} $pf_num]
            set msi_interface_enable 0

            set core16_virtual_pfi_enable_hwtcl [ip_get "parameter.core16_virtual_pf${i}_enable_hwtcl.value"]
            if { $core16_virtual_pfi_enable_hwtcl == 1 } {
            if { [get_parameter_value core16_pf${i}_virtio_capability_present_hwtcl] || [get_parameter_value core16_pf${i}vf_virtio_capability_present_hwtcl] } {
                if { [get_parameter_value core16_virtual_pf${i}_msi_enable_hwtcl] } {
                ip_set_param "parameter.core16_virtual_pf${i}_msi_enable_hwtcl.value" 0
                }
                if { [get_parameter_value core16_virtual_pf${i}_msi_enable_user_hwtcl]} {
                send_message info "Enabling VIRTIO automatically disables MSI. (PCIe0 PF{$i})"
                }
            } else {
                set core16_virtual_pfi_msi_enable_user_hwtcl [get_parameter_value core16_virtual_pf${i}_msi_enable_user_hwtcl]
                ip_set_param "parameter.core16_virtual_pf${i}_msi_enable_hwtcl.value" $core16_virtual_pfi_msi_enable_user_hwtcl
                if { $core16_virtual_pfi_msi_enable_user_hwtcl == 1} {
                set msi_interface_enable 1
                }
            }
            } else {
            ip_set_param "parameter.core16_virtual_pf${i}_msi_enable_hwtcl.value" 0
            }
            
            for {set i 0} { $i < 8 } {incr i} {
                set core16_virtual_pfi_enable_hwtcl [ip_get "parameter.core16_virtual_pf${i}_enable_hwtcl.value"]
                if { $core16_virtual_pfi_enable_hwtcl == 1 } {
                    if { ![get_parameter_value core16_pf${i}_virtio_capability_present_hwtcl] && ![get_parameter_value core16_pf${i}vf_virtio_capability_present_hwtcl] } {
                        set core16_virtual_pfi_msi_enable_user_hwtcl [get_parameter_value core16_virtual_pf${i}_msi_enable_user_hwtcl]
                        if { $core16_virtual_pfi_msi_enable_user_hwtcl == 1} {
                            set msi_interface_enable 1
                        }
                    }
                }
            }
            #disable MSI in Root Port Mode
            if { $core16_virtual_rp_ep_mode_hwtcl == "Root Port" || $core16_virtual_tlp_bypass_en_hwtcl == 1} {
                ip_set_param "parameter.core16_enable_msi_interface_hwtcl.value" 0
            } else {
                ip_set_param "parameter.core16_enable_msi_interface_hwtcl.value" $msi_interface_enable
            }
        }
    

    }   
}

proc ::intel_pcie_ss_axi::parameters::validate_core16_virtual_pfi_msix_enable_hwtcl { PROP_NAME PROP_VALUE core16_total_pf_count_hwtcl core16_virtual_rp_ep_mode_hwtcl } {
    set tile [ip_get "parameter.TILE.value"]

    if { $tile == "P-TILE" } {
        for { set i 0 } { $i < 8 } { incr i } {
            if { [get_parameter_value core16_virtual_pf${i}_enable_hwtcl] } {
                if { [get_parameter_value core16_pf${i}_virtio_capability_present_hwtcl] || [get_parameter_value core16_pf${i}vf_virtio_capability_present_hwtcl] } {
                    if { ![get_parameter_value core16_virtual_pf${i}_msix_enable_hwtcl] } {
                        send_message info "Enabling VIRTIO automatically enables MSI-X. (PCIe0 PF{$i})"
                        ip_set_param "parameter.core16_virtual_pf${i}_msix_enable_hwtcl.value" 1
                    }
                } else {
                    ip_set_param "parameter.core16_virtual_pf${i}_msix_enable_hwtcl.value" [get_parameter_value core16_virtual_pf${i}_msix_enable_user_hwtcl]
                }
            } else {
                ip_set_param "parameter.core16_virtual_pf${i}_msix_enable_hwtcl.value" 0
            }
        }
    } elseif { $tile == "F-TILE" || $tile == "R-TILE" } {
        regexp {pf.} $PROP_NAME i
        set pf_num [regexp -all -inline -- {[0-9]+} $i]
        
            if { [get_parameter_value core16_virtual_pf${pf_num}_enable_hwtcl] } {
                if { [get_parameter_value core16_pf${pf_num}_virtio_capability_present_hwtcl] || [get_parameter_value core16_pf${pf_num}vf_virtio_capability_present_hwtcl] } {
                    if { ![get_parameter_value core16_virtual_pf${pf_num}_msix_enable_hwtcl] } {
                        ip_set_param "parameter.core16_virtual_pf${pf_num}_msix_enable_hwtcl.value" 1
                    }
    		if { ![get_parameter_value core16_virtual_pf${pf_num}_msix_enable_user_hwtcl]} {
                        send_message info "Enabling VIRTIO automatically enables MSI-X. (PCIe0 PF{${pf_num}})"
                    }
                } else {
                    ip_set_param "parameter.core16_virtual_pf${pf_num}_msix_enable_hwtcl.value" [get_parameter_value core16_virtual_pf${pf_num}_msix_enable_user_hwtcl]
                }
            } else {
                ip_set_param "parameter.core16_virtual_pf${pf_num}_msix_enable_hwtcl.value" 0
            }
     
    }
}
########soft_ip parameter call backs###########
proc ::intel_pcie_ss_axi::parameters::validate_core16_hip_reconfig_hwtcl { PROP_NAME PROP_VALUE core16_virtual_rp_ep_mode_integer_hwtcl core16_virtual_tlp_bypass_en_hwtcl } {
    set tile [ip_get "parameter.TILE.value"]

    if { $tile == "P-TILE" } {
    
        set core16_hip_reconfig_user_hwtcl [get_parameter_value core16_hip_reconfig_user_hwtcl]
        if {$core16_hip_reconfig_user_hwtcl == 0 && $core16_virtual_tlp_bypass_en_hwtcl == 1} {
            send_message info "PCIe 0: HIP reconfiguration automatically enabled in TLP Bypass mode."
            ip_set_param "parameter.core16_hip_reconfig_user_hwtcl.ENABLED" false
            ip_set_param "parameter.core16_hip_reconfig_user_hwtcl.VISIBLE" false
            ip_set_param "parameter.core16_hip_reconfig_hwtcl.value" 1
        } elseif {$core16_hip_reconfig_user_hwtcl == 0 && $core16_virtual_rp_ep_mode_integer_hwtcl == 1} {
            send_message info "PCIe 0: HIP reconfiguration automatically enabled in Root Port mode."
            ip_set_param "parameter.core16_hip_reconfig_user_hwtcl.ENABLED" false
            ip_set_param "parameter.core16_hip_reconfig_user_hwtcl.VISIBLE" false
            ip_set_param "parameter.core16_hip_reconfig_hwtcl.value" 1
        } else {
            # else set param from user hwtcl
            ip_set_param "parameter.core16_hip_reconfig_hwtcl.value" $core16_hip_reconfig_user_hwtcl
        }
    } elseif { $tile == "R-TILE"} {
        set core16_hip_reconfig_user_hwtcl [get_parameter_value core16_hip_reconfig_user_hwtcl]        
        if {$core16_hip_reconfig_user_hwtcl == 0 && $core16_virtual_tlp_bypass_en_hwtcl == 1} {
		send_message info "PCIe 0: HIP reconfiguration automatically enabled in TLP Bypass mode."
		ip_set_param "parameter.core16_hip_reconfig_hwtcl.value" 1
        } elseif {$core16_hip_reconfig_user_hwtcl == 0 && $core16_virtual_rp_ep_mode_integer_hwtcl == 1} {
		send_message info "PCIe 0: HIP reconfiguration automatically enabled in Root Port mode."
		ip_set_param "parameter.core16_hip_reconfig_hwtcl.value" 1
        } else {
		# else set param from user hwtcl
		ip_set_param "parameter.core16_hip_reconfig_hwtcl.value" $core16_hip_reconfig_user_hwtcl
        }

   } elseif { $tile == "F-TILE" } {
        set core16_hip_reconfig_user_hwtcl [get_parameter_value core16_hip_reconfig_user_hwtcl]
        set pcs_config_en        [get_parameter_value PCS_CONFIG_EN]
    	
        set top_topology_hwtcl   [ip_get "parameter.top_topology_hwtcl.value"]
        set pld_clrpcs           [ip_get "parameter.pld_clrpcs_hwtcl.value"]
    
        if {$pcs_config_en} {
            ip_set_param "parameter.core16_hip_reconfig_hwtcl.value" 1
            ip_set_param "parameter.core16_hip_reconfig_user_hwtcl.ENABLED" false
            ip_set_param "parameter.core16_hip_reconfig_user_hwtcl.VISIBLE" false
        } elseif {$core16_hip_reconfig_user_hwtcl == 0 && $core16_virtual_tlp_bypass_en_hwtcl == 1} {
            send_message info "PCIe 0: HIP reconfiguration automatically enabled in TLP Bypass mode."
            ip_set_param "parameter.core16_hip_reconfig_user_hwtcl.ENABLED" false
            ip_set_param "parameter.core16_hip_reconfig_user_hwtcl.VISIBLE" false
            ip_set_param "parameter.core16_hip_reconfig_hwtcl.value" 1
        } elseif {$core16_hip_reconfig_user_hwtcl == 0 && $core16_virtual_rp_ep_mode_integer_hwtcl == 1} {
            send_message info "PCIe 0: HIP reconfiguration automatically enabled in Root Port mode."
            ip_set_param "parameter.core16_hip_reconfig_user_hwtcl.ENABLED" false
            ip_set_param "parameter.core16_hip_reconfig_user_hwtcl.VISIBLE" false
            ip_set_param "parameter.core16_hip_reconfig_hwtcl.value" 1
    	
    	} elseif {[regexp "2x8" $top_topology_hwtcl] && $pld_clrpcs} {
    	    ip_set_param "parameter.core16_hip_reconfig_hwtcl.value" 1
    		
    		
        } else {
            # else set param from user hwtcl
            ip_set_param "parameter.core16_hip_reconfig_hwtcl.value" $core16_hip_reconfig_user_hwtcl
        }
    }
}
########identification parameters call back##########
proc ::intel_pcie_ss_axi::parameters::validate_core16_pfi_pci_type0_vendor_id_info_hwtcl { PROP_NAME PROP_VALUE } {

    regexp {pf.} $PROP_NAME pf_num
    set core16_virtual_pfi_enable_hwtcl [ip_get "parameter.core16_virtual_${pf_num}_enable_hwtcl.value"]
        if { $core16_virtual_pfi_enable_hwtcl == 1 } {
            set core16_pfi_pci_type0_vendor_id_hwtcl [ip_get "parameter.core16_${pf_num}_pci_type0_vendor_id_hwtcl.value"]
            send_message info "PCIe0 ${pf_num} IDs: Vendor ID is set to 0x[format %x $core16_pfi_pci_type0_vendor_id_hwtcl]. Please set proper value according to user application."
        }
}
proc ::intel_pcie_ss_axi::parameters::validate_core16_pfi_pci_type0_device_id_info_hwtcl { PROP_NAME PROP_VALUE } {
    regexp {pf.} $PROP_NAME pf_num
    set core16_virtual_pfi_enable_hwtcl [ip_get "parameter.core16_virtual_${pf_num}_enable_hwtcl.value"]
        if { $core16_virtual_pfi_enable_hwtcl == 1 } {
            set core16_pfi_pci_type0_device_id_hwtcl [ip_get "parameter.core16_${pf_num}_pci_type0_device_id_hwtcl.value"]
            send_message info "PCIe0 ${pf_num} IDs: Device ID is set to 0x[format %x $core16_pfi_pci_type0_device_id_hwtcl]. Please set proper value according to user application."
        }
}
proc ::intel_pcie_ss_axi::parameters::validate_core16_pfi_revision_id_info_hwtcl { PROP_NAME PROP_VALUE } {
    regexp {pf.} $PROP_NAME pf_num
    set core16_virtual_pfi_enable_hwtcl [ip_get "parameter.core16_virtual_${pf_num}_enable_hwtcl.value"]
        if { $core16_virtual_pfi_enable_hwtcl == 1 } {
            set core16_pfi_revision_id_hwtcl [ip_get "parameter.core16_${pf_num}_revision_id_hwtcl.value"]
            send_message info "PCIe0 ${pf_num} IDs: Revision ID is set to 0x[format %x $core16_pfi_revision_id_hwtcl]. Please set proper value according to user application."
        }
}

proc ::intel_pcie_ss_axi::parameters::validate_core16_pfi_class_code_info_hwtcl { PROP_NAME PROP_VALUE } {
    regexp {pf.} $PROP_NAME pf_num
    set core16_virtual_pfi_enable_hwtcl [ip_get "parameter.core16_virtual_${pf_num}_enable_hwtcl.value"]
        if { $core16_virtual_pfi_enable_hwtcl == 1 } {
            set core16_pfi_class_code_hwtcl [ip_get "parameter.core16_${pf_num}_class_code_hwtcl.value"]
            send_message info "PCIe0 ${pf_num} IDs: Class code is set to 0x[format %x $core16_pfi_class_code_hwtcl]. Please set proper value according to user application."
        }
}

proc ::intel_pcie_ss_axi::parameters::validate_core16_pfi_base_class_code_hwtcl { PROP_NAME PROP_VALUE } {
    # get which pf
    regexp {pf.} $PROP_NAME pf_num
    set core16_virtual_pfi_enable_hwtcl [ip_get "parameter.core16_virtual_${pf_num}_enable_hwtcl.value"]

    set core16_pfi_class_code_hwtcl [ip_get "parameter.core16_${pf_num}_class_code_hwtcl.value"]
    set core16_pfi_base_class_code_hwtcl [expr [expr $core16_pfi_class_code_hwtcl & 16711680] >> 16]
    if { $core16_virtual_pfi_enable_hwtcl == 1 } {
    	ip_set_param "parameter.core16_${pf_num}_base_class_code_hwtcl.value" $core16_pfi_base_class_code_hwtcl
    } else {
    	ip_set_param "parameter.core16_${pf_num}_base_class_code_hwtcl.value" 0
    }
}

proc ::intel_pcie_ss_axi::parameters::validate_core16_pfi_subclass_code_hwtcl { PROP_NAME PROP_VALUE } {
    # get which pf
    regexp {pf.} $PROP_NAME pf_num
    set core16_pfi_class_code_hwtcl [ip_get "parameter.core16_${pf_num}_class_code_hwtcl.value"]
    set core16_pfi_subclass_code_hwtcl [expr [expr $core16_pfi_class_code_hwtcl & 65280] >> 8]
    ip_set_param "parameter.core16_${pf_num}_subclass_code_hwtcl.value" $core16_pfi_subclass_code_hwtcl
}
proc ::intel_pcie_ss_axi::parameters::validate_core16_pfi_sriov_vf_device_id_info { PROP_NAME PROP_VALUE } {
    regexp {pf.} $PROP_NAME pf_num
    set core16_enable_sriov_hwtcl [ip_get "parameter.core16_enable_sriov_hwtcl.value"]
    set core16_virtual_pfi_sriov_enable_hwtcl [ip_get "parameter.core16_virtual_${pf_num}_sriov_enable_hwtcl.value"]
        if { $core16_enable_sriov_hwtcl == 1 && $core16_virtual_pfi_sriov_enable_hwtcl == 1} {
            set core16_pfi_sriov_vf_device_id [ip_get "parameter.core16_${pf_num}_sriov_vf_device_id.value"]
            send_message info "PCIe0 ${pf_num} VF IDs: Device ID is set to 0x[format %x $core16_pfi_sriov_vf_device_id]. Please set proper value according to user application."
        }
}
proc ::intel_pcie_ss_axi::parameters::validate_core16_pfi_program_interface_hwtcl { PROP_NAME PROP_VALUE } {
    # get which pf
    regexp {pf.} $PROP_NAME pf_num
    set core16_pfi_class_code_hwtcl [ip_get "parameter.core16_${pf_num}_class_code_hwtcl.value"]
    set core16_pfi_program_interface_hwtcl [expr $core16_pfi_class_code_hwtcl & 255]
    ip_set_param "parameter.core16_${pf_num}_program_interface_hwtcl.value" $core16_pfi_program_interface_hwtcl
}
proc ::intel_pcie_ss_axi::parameters::set_core16_parameter_value {parameter_name value} {
    ip_set_param "parameter.$parameter_name.value" $value
}
# Rootport PF BAR disable validation callback
proc ::intel_pcie_ss_axi::parameters::validate_core16_pf_bar_type_hwtcl { PROP_NAME PROP_VALUE core16_func_mode_hwtcl core16_virtual_rp_ep_mode_hwtcl } {
    set tile [ip_get "parameter.TILE.value"]

    if { $tile == "P-TILE" } {
        if { $core16_func_mode_hwtcl == "Disable" || $core16_virtual_rp_ep_mode_hwtcl == "Root Port" } {
            # if in rootport or core 16 is disabled set all BAR types to disabled and size to N/A
    
            # loop through all pf 0-7
            for {set pf 0} {$pf < 8} {incr pf 1} {
                # loop through all bars 0-5
                for {set i 0} {$i <= 5} {incr i 1} {
                    ip_set_param "parameter.core16_pf${pf}_bar${i}_type_hwtcl.value" "Disabled"
                    ip_set_param "parameter.core16_pf${pf}_bar${i}_address_width_hwtcl.value" 0
                }
            }
        } else {
            # else set them to user_hwtcl values
    
            # loop through all pf 0-7
            for {set pf 0} {$pf < 8} {incr pf 1} {
                set core16_virtual_pfi_enable_hwtcl [ip_get "parameter.core16_virtual_pf${pf}_enable_hwtcl.value"]
                if { $core16_virtual_pfi_enable_hwtcl == 1} {
                   # loop through all bars 0-5
                   for {set i 0} {$i <= 5} {incr i 1} {
                       set core16_pf_bar_type_user_hwtcl($pf,$i) [get_parameter_value core16_pf${pf}_bar${i}_type_user_hwtcl]
                       set core16_pf_bar_address_width_user_hwtcl($pf,$i) [get_parameter_value core16_pf${pf}_bar${i}_address_width_user_hwtcl]
                    			
    		    #ALLOWED_RANGES
    		    if {[regexp "64-bit" $core16_pf_bar_type_user_hwtcl($pf,$i)]} {
    			    ip_set_param "parameter.core16_pf${pf}_bar${i}_address_width_user_hwtcl.ALLOWED_RANGES" {"0:N/A" "7: 128 Bytes - 7 bits" "8: 256 Bytes - 8 bits" "9: 512 Bytes - 9 bits" "10: 1 KByte - 10 bits" "11: 2 KBytes - 11 bits" "12: 4 KBytes - 12 bits" "13: 8 KBytes - 13 bits" "14: 16 KBytes - 14 bits" "15: 32 KBytes - 15 bits" "16: 64 KBytes - 16 bits" "17: 128 KBytes - 17 bits" "18: 256 KBytes - 18 bits" "19: 512 KBytes - 19 bits" "20: 1 MByte - 20 bits" "21: 2 MBytes - 21 bits" "22: 4 MBytes - 22 bits" "23: 8 MBytes - 23 bits" "24: 16 MBytes - 24 bits" "25: 32 MBytes - 25 bits" "26: 64 MBytes - 26 bits" "27: 128 MBytes - 27 bits" "28: 256 MBytes - 28 bits" "29: 512 MBytes - 29 bits" "30: 1 GByte - 30 bits" "31: 2 GBytes - 31 bits" "32: 4 GBytes - 32 bits" "33: 8 GBytes - 33 bits" "34: 16 GBytes - 34 bits" "35: 32 GBytes - 35 bits" "36: 64 GBytes - 36 bits" "37: 128 GBytes - 37 bits" "38: 256 GBytes - 38 bits" "39: 512 GBytes - 39 bits" "40: 1 TByte - 40 bits" "41: 2 TBytes - 41 bits" "42: 4 TBytes - 42 bits" "43: 8 TBytes - 43 bits" "44: 16 TBytes - 44 bits" "45: 32 TBytes - 45 bits" "46: 64 TBytes - 46 bits" "47: 128 TBytes - 47 bits" "48: 256 TBytes - 48 bits" "49: 512 TBytes - 49 bits" "50: 1 PByte - 50 bits" "51: 2 PBytes - 51 bits" "52: 4 PBytes - 52 bits" "53: 8 PBytes - 53 bits" "54: 16 PBytes - 54 bits" "55: 32 PBytes - 55 bits" "56: 64 PBytes - 56 bits" "57: 128 PBytes - 57 bits" "58: 256 PBytes - 58 bits" "59: 512 PBytes - 59 bits" "60: 1 EByte - 60 bits" "61: 2 EBytes - 61 bits" "62: 4 EBytes - 62 bits" "63: 8 EBytes - 63 bits" "64: 16 EBytes - 64 bits"}
    		    } elseif {[regexp "32-bit" $core16_pf_bar_type_user_hwtcl($pf,$i)]} {
    			    ip_set_param "parameter.core16_pf${pf}_bar${i}_address_width_user_hwtcl.ALLOWED_RANGES" {"0:N/A" "7: 128 Bytes - 7 bits" "8: 256 Bytes - 8 bits" "9: 512 Bytes - 9 bits" "10: 1 KByte - 10 bits" "11: 2 KBytes - 11 bits" "12: 4 KBytes - 12 bits" "13: 8 KBytes - 13 bits" "14: 16 KBytes - 14 bits" "15: 32 KBytes - 15 bits" "16: 64 KBytes - 16 bits" "17: 128 KBytes - 17 bits" "18: 256 KBytes - 18 bits" "19: 512 KBytes - 19 bits" "20: 1 MByte - 20 bits" "21: 2 MBytes - 21 bits" "22: 4 MBytes - 22 bits" "23: 8 MBytes - 23 bits" "24: 16 MBytes - 24 bits" "25: 32 MBytes - 25 bits" "26: 64 MBytes - 26 bits" "27: 128 MBytes - 27 bits" "28: 256 MBytes - 28 bits" "29: 512 MBytes - 29 bits" "30: 1 GByte - 30 bits" "31: 2 GBytes - 31 bits" "32: 4 GBytes - 32 bits"}
    		    }
                       ip_set_param "parameter.core16_pf${pf}_bar${i}_type_hwtcl.value" $core16_pf_bar_type_user_hwtcl($pf,$i)
                       ip_set_param "parameter.core16_pf${pf}_bar${i}_address_width_hwtcl.value" $core16_pf_bar_address_width_user_hwtcl($pf,$i)
    				   
                   }
    
                   # if bar0/2/4 are 64 bit ; bar1/3/5 should be disabled to user
    
                   set core16_pf_bar_val  [ip_get "parameter.core16_pf${pf}_bar0_type_hwtcl.value"]
                   set core16_pf_bar2_val [ip_get "parameter.core16_pf${pf}_bar2_type_hwtcl.value"]
                   set core16_pf_bar4_val [ip_get "parameter.core16_pf${pf}_bar4_type_hwtcl.value"]
                   
                   if { [regexp "64-bit" $core16_pf_bar_val] }  {
                       ip_set_param "parameter.core16_pf${pf}_bar1_type_hwtcl.value" "Disabled"
                       ip_set_param "parameter.core16_pf${pf}_bar1_type_user_hwtcl.ENABLED" false
                   } else {
                       ip_set_param "parameter.core16_pf${pf}_bar1_type_user_hwtcl.ENABLED" true
                   }
                   if { [regexp "64-bit" $core16_pf_bar2_val] }  {
                       ip_set_param "parameter.core16_pf${pf}_bar3_type_hwtcl.value" "Disabled"
                       ip_set_param "parameter.core16_pf${pf}_bar3_type_user_hwtcl.ENABLED" false
                   } else {
                       ip_set_param "parameter.core16_pf${pf}_bar3_type_user_hwtcl.ENABLED" true
                   } 
                   if { [regexp "64-bit" $core16_pf_bar4_val] }  {
                       ip_set_param "parameter.core16_pf${pf}_bar5_type_hwtcl.value" "Disabled"
                       ip_set_param "parameter.core16_pf${pf}_bar5_type_user_hwtcl.ENABLED" false
                   } else {
                       ip_set_param "parameter.core16_pf${pf}_bar5_type_user_hwtcl.ENABLED" true
                   } 
    
    
                } else {
                   for {set i 0} {$i <= 5} {incr i 1} {
                    ip_set_param "parameter.core16_pf${pf}_bar${i}_type_hwtcl.value" "Disabled"
                    ip_set_param "parameter.core16_pf${pf}_bar${i}_address_width_hwtcl.value" 0
                   }
                }
            }
        }

    } elseif { $tile == "R-TILE" } {
    if { $core16_func_mode_hwtcl == "Disable" || $core16_virtual_rp_ep_mode_hwtcl == "Root Port"} {
        # if in rootport or core 16 is disabled set all BAR types to disabled and size to N/A
        # loop through all pf 0-7
        for {set pf 0} {$pf < 8} {incr pf 1} {
            # loop through all bars 0-5
            for {set i 0} {$i <= 5} {incr i 1} {
                ip_set_param "parameter.core16_pf${pf}_bar${i}_type_hwtcl.value" "Disabled"
                ip_set_param "parameter.core16_pf${pf}_bar${i}_address_width_hwtcl.value" 0
                ip_set_param "parameter.core16_pf${pf}_bar${i}_mask_integer_hwtcl.value" 0
            }
        }
    } else {
        # else set them to user_hwtcl values

        # loop through all pf 0-7
        for {set pf 0} {$pf < 8} {incr pf 1} {
            set core16_virtual_pfi_enable_hwtcl [ip_get "parameter.core16_virtual_pf${pf}_enable_hwtcl.value"]
            if { $core16_virtual_pfi_enable_hwtcl == 1} {
			
			
                # loop through all bars 0-5
                set core16_prev_bar_type "Disable"
                set core16_prev_bar_addr_width 0
                for {set i 0} {$i <= 5} {incr i 1} {
                    set core16_pf_bar_type_user_hwtcl [get_parameter_value core16_pf${pf}_bar${i}_type_user_hwtcl]
                    set core16_pf_bar_address_width_user_hwtcl [get_parameter_value core16_pf${pf}_bar${i}_address_width_user_hwtcl]	
					
					#ALLOWED_RANGES
					if {[regexp "64-bit" $core16_pf_bar_type_user_hwtcl]} {
						ip_set_param "parameter.core16_pf${pf}_bar${i}_address_width_user_hwtcl.ALLOWED_RANGES" {"0:N/A" "8: 256 Bytes - 8 bits" "9: 512 Bytes - 9 bits" "10: 1 KByte - 10 bits" "11: 2 KBytes - 11 bits" "12: 4 KBytes - 12 bits" "13: 8 KBytes - 13 bits" "14: 16 KBytes - 14 bits" "15: 32 KBytes - 15 bits" "16: 64 KBytes - 16 bits" "17: 128 KBytes - 17 bits" "18: 256 KBytes - 18 bits" "19: 512 KBytes - 19 bits" "20: 1 MByte - 20 bits" "21: 2 MBytes - 21 bits" "22: 4 MBytes - 22 bits" "23: 8 MBytes - 23 bits" "24: 16 MBytes - 24 bits" "25: 32 MBytes - 25 bits" "26: 64 MBytes - 26 bits" "27: 128 MBytes - 27 bits" "28: 256 MBytes - 28 bits" "29: 512 MBytes - 29 bits" "30: 1 GByte - 30 bits" "31: 2 GBytes - 31 bits" "32: 4 GBytes - 32 bits" "33: 8 GBytes - 33 bits" "34: 16 GBytes - 34 bits" "35: 32 GBytes - 35 bits" "36: 64 GBytes - 36 bits" "37: 128 GBytes - 37 bits" "38: 256 GBytes - 38 bits" "39: 512 GBytes - 39 bits" "40: 1 TByte - 40 bits" "41: 2 TBytes - 41 bits" "42: 4 TBytes - 42 bits" "43: 8 TBytes - 43 bits" "44: 16 TBytes - 44 bits" "45: 32 TBytes - 45 bits" "46: 64 TBytes - 46 bits" "47: 128 TBytes - 47 bits" "48: 256 TBytes - 48 bits" "49: 512 TBytes - 49 bits" "50: 1 PByte - 50 bits" "51: 2 PBytes - 51 bits" "52: 4 PBytes - 52 bits" "53: 8 PBytes - 53 bits" "54: 16 PBytes - 54 bits" "55: 32 PBytes - 55 bits" "56: 64 PBytes - 56 bits" "57: 128 PBytes - 57 bits" "58: 256 PBytes - 58 bits" "59: 512 PBytes - 59 bits" "60: 1 EByte - 60 bits" "61: 2 EBytes - 61 bits" "62: 4 EBytes - 62 bits" "63: 8 EBytes - 63 bits" "64: 16 EBytes - 64 bits"}
					} elseif {[regexp "32-bit" $core16_pf_bar_type_user_hwtcl]} {
						ip_set_param "parameter.core16_pf${pf}_bar${i}_address_width_user_hwtcl.ALLOWED_RANGES" {"0:N/A" "8: 256 Bytes - 8 bits" "9: 512 Bytes - 9 bits" "10: 1 KByte - 10 bits" "11: 2 KBytes - 11 bits" "12: 4 KBytes - 12 bits" "13: 8 KBytes - 13 bits" "14: 16 KBytes - 14 bits" "15: 32 KBytes - 15 bits" "16: 64 KBytes - 16 bits" "17: 128 KBytes - 17 bits" "18: 256 KBytes - 18 bits" "19: 512 KBytes - 19 bits" "20: 1 MByte - 20 bits" "21: 2 MBytes - 21 bits" "22: 4 MBytes - 22 bits" "23: 8 MBytes - 23 bits" "24: 16 MBytes - 24 bits" "25: 32 MBytes - 25 bits" "26: 64 MBytes - 26 bits" "27: 128 MBytes - 27 bits" "28: 256 MBytes - 28 bits" "29: 512 MBytes - 29 bits" "30: 1 GByte - 30 bits" "31: 2 GBytes - 31 bits" "32: 4 GBytes - 32 bits"}
					}
	
                    # Need to update to support full 64bit address width
                    if { $i == 0 || $i == 2 || $i == 4} {
                        if { $core16_pf_bar_address_width_user_hwtcl >= 32 } {
                            set core16_pf_bar_mask 2147483647
                        } elseif { $core16_pf_bar_address_width_user_hwtcl == 0 } {
                            set core16_pf_bar_mask 0
                        } else {
                            #set core16_pf_bar_mask($pf,$i) [expr int(~(0xffffffff << $core16_pf_bar_address_width_user_hwtcl($pf,$i)) >> 1 )]
                            set core16_pf_bar_mask [expr int( 0x1 << [expr $core16_pf_bar_address_width_user_hwtcl -1] ) -1 ]
                        }
                        # no actual 
                        set core16_virtual_pf_bar_mask_bit0  "false"
                        set core16_prev_bar_type $core16_pf_bar_type_user_hwtcl
                        set core16_prev_bar_addr_width $core16_pf_bar_address_width_user_hwtcl 
                    }
                    
                    if { $i == 1 || $i == 3 || $i == 5} {
                        if { [regexp "64-bit" $core16_prev_bar_type] } { 
                            if { $core16_prev_bar_addr_width > 33 } {
                                set core16_pf_bar_mask [expr int( 0x1 << [expr $core16_prev_bar_addr_width - 33] ) -1 ]
                                set core16_virtual_pf_bar_mask_bit0  "true"
                            } else {
                                set core16_pf_bar_mask 0
                                set core16_virtual_pf_bar_mask_bit0  "false"
                            }
                        } elseif { $core16_pf_bar_address_width_user_hwtcl == 0 } {
                            set core16_pf_bar_mask 0                    
                            set core16_virtual_pf_bar_mask_bit0  "false"           
                        } else  {
                            set core16_pf_bar_mask [expr int( 0x1 << [expr $core16_pf_bar_address_width_user_hwtcl -1] ) -1 ]
                            set core16_virtual_pf_bar_mask_bit0  "false"
                        }
						ip_set_param "parameter.core16_virtual_pf${pf}_bar${i}_mask_bit0_hwtcl.value" $core16_virtual_pf_bar_mask_bit0
                    }

                    ip_set_param "parameter.core16_pf${pf}_bar${i}_type_hwtcl.value" $core16_pf_bar_type_user_hwtcl
                    ip_set_param "parameter.core16_pf${pf}_bar${i}_address_width_hwtcl.value" $core16_pf_bar_address_width_user_hwtcl
                    ip_set_param "parameter.core16_pf${pf}_bar${i}_mask_integer_hwtcl.value" $core16_pf_bar_mask
                }




			} else {
                for {set i 0} {$i <= 5} {incr i 1} {
                    ip_set_param "parameter.core16_pf${pf}_bar${i}_type_hwtcl.value" "Disabled"
                    ip_set_param "parameter.core16_pf${pf}_bar${i}_address_width_hwtcl.value" 0
                    ip_set_param "parameter.core16_pf${pf}_bar${i}_mask_integer_hwtcl.value" 0
                    ip_set_param "parameter.core16_virtual_pf${pf}_bar${i}_mask_bit0_hwtcl.value" "false"
                }
            }
        }
     }
    
    } elseif { $tile == "F-TILE" } {
        if { $core16_func_mode_hwtcl == "Disable" || $core16_virtual_rp_ep_mode_hwtcl == "Root Port" } {
            # if in rootport or core 16 is disabled set all BAR types to disabled and size to N/A
    
            # loop through all pf 0-7
            for {set pf 0} {$pf < 8} {incr pf 1} {
                # loop through all bars 0-5
                for {set i 0} {$i <= 5} {incr i 1} {
                    ip_set_param "parameter.core16_pf${pf}_bar${i}_type_hwtcl.value" "Disabled"
                    ip_set_param "parameter.core16_pf${pf}_bar${i}_address_width_hwtcl.value" 0
                }
            }
        } else {
            # else set them to user_hwtcl values
    
            # loop through all pf 0-7
            for {set pf 0} {$pf < 8} {incr pf 1} {
                set core16_virtual_pfi_enable_hwtcl [ip_get "parameter.core16_virtual_pf${pf}_enable_hwtcl.value"]
                if { $core16_virtual_pfi_enable_hwtcl == 1} {
                   # loop through all bars 0-5
                   for {set i 0} {$i <= 5} {incr i 1} {
                       set core16_pf_bar_type_user_hwtcl($pf,$i) [get_parameter_value core16_pf${pf}_bar${i}_type_user_hwtcl]
                       set core16_pf_bar_address_width_user_hwtcl($pf,$i) [get_parameter_value core16_pf${pf}_bar${i}_address_width_user_hwtcl]
    		   			
    		    #ALLOWED_RANGES
    		    if {[regexp "64-bit" $core16_pf_bar_type_user_hwtcl($pf,$i)]} {
    			    ip_set_param "parameter.core16_pf${pf}_bar${i}_address_width_user_hwtcl.ALLOWED_RANGES" {"0:N/A" "8: 256 Bytes - 8 bits" "9: 512 Bytes - 9 bits" "10: 1 KByte - 10 bits" "11: 2 KBytes - 11 bits" "12: 4 KBytes - 12 bits" "13: 8 KBytes - 13 bits" "14: 16 KBytes - 14 bits" "15: 32 KBytes - 15 bits" "16: 64 KBytes - 16 bits" "17: 128 KBytes - 17 bits" "18: 256 KBytes - 18 bits" "19: 512 KBytes - 19 bits" "20: 1 MByte - 20 bits" "21: 2 MBytes - 21 bits" "22: 4 MBytes - 22 bits" "23: 8 MBytes - 23 bits" "24: 16 MBytes - 24 bits" "25: 32 MBytes - 25 bits" "26: 64 MBytes - 26 bits" "27: 128 MBytes - 27 bits" "28: 256 MBytes - 28 bits" "29: 512 MBytes - 29 bits" "30: 1 GByte - 30 bits" "31: 2 GBytes - 31 bits" "32: 4 GBytes - 32 bits" "33: 8 GBytes - 33 bits" "34: 16 GBytes - 34 bits" "35: 32 GBytes - 35 bits" "36: 64 GBytes - 36 bits" "37: 128 GBytes - 37 bits" "38: 256 GBytes - 38 bits" "39: 512 GBytes - 39 bits" "40: 1 TByte - 40 bits" "41: 2 TBytes - 41 bits" "42: 4 TBytes - 42 bits" "43: 8 TBytes - 43 bits" "44: 16 TBytes - 44 bits" "45: 32 TBytes - 45 bits" "46: 64 TBytes - 46 bits" "47: 128 TBytes - 47 bits" "48: 256 TBytes - 48 bits" "49: 512 TBytes - 49 bits" "50: 1 PByte - 50 bits" "51: 2 PBytes - 51 bits" "52: 4 PBytes - 52 bits" "53: 8 PBytes - 53 bits" "54: 16 PBytes - 54 bits" "55: 32 PBytes - 55 bits" "56: 64 PBytes - 56 bits" "57: 128 PBytes - 57 bits" "58: 256 PBytes - 58 bits" "59: 512 PBytes - 59 bits" "60: 1 EByte - 60 bits" "61: 2 EBytes - 61 bits" "62: 4 EBytes - 62 bits" "63: 8 EBytes - 63 bits" "64: 16 EBytes - 64 bits"}
    		    } elseif {[regexp "32-bit" $core16_pf_bar_type_user_hwtcl($pf,$i)]} {
    			    ip_set_param "parameter.core16_pf${pf}_bar${i}_address_width_user_hwtcl.ALLOWED_RANGES" {"0:N/A" "8: 256 Bytes - 8 bits" "9: 512 Bytes - 9 bits" "10: 1 KByte - 10 bits" "11: 2 KBytes - 11 bits" "12: 4 KBytes - 12 bits" "13: 8 KBytes - 13 bits" "14: 16 KBytes - 14 bits" "15: 32 KBytes - 15 bits" "16: 64 KBytes - 16 bits" "17: 128 KBytes - 17 bits" "18: 256 KBytes - 18 bits" "19: 512 KBytes - 19 bits" "20: 1 MByte - 20 bits" "21: 2 MBytes - 21 bits" "22: 4 MBytes - 22 bits" "23: 8 MBytes - 23 bits" "24: 16 MBytes - 24 bits" "25: 32 MBytes - 25 bits" "26: 64 MBytes - 26 bits" "27: 128 MBytes - 27 bits" "28: 256 MBytes - 28 bits" "29: 512 MBytes - 29 bits" "30: 1 GByte - 30 bits" "31: 2 GBytes - 31 bits" "32: 4 GBytes - 32 bits"}
    		    }
    	
                       ip_set_param "parameter.core16_pf${pf}_bar${i}_type_hwtcl.value" $core16_pf_bar_type_user_hwtcl($pf,$i)
                       ip_set_param "parameter.core16_pf${pf}_bar${i}_address_width_hwtcl.value" $core16_pf_bar_address_width_user_hwtcl($pf,$i)
                   }
    
                   # if bar0/2/4 are 64 bit ; bar1/3/5 should be disabled to user
    
                   set core16_pf_bar_val  [ip_get "parameter.core16_pf${pf}_bar0_type_hwtcl.value"]
                   set core16_pf_bar2_val [ip_get "parameter.core16_pf${pf}_bar2_type_hwtcl.value"]
                   set core16_pf_bar4_val [ip_get "parameter.core16_pf${pf}_bar4_type_hwtcl.value"]
                   
                   if { [regexp "64-bit" $core16_pf_bar_val] }  {
                       ip_set_param "parameter.core16_pf${pf}_bar1_type_hwtcl.value" "Disabled"
                       ip_set_param "parameter.core16_pf${pf}_bar1_type_user_hwtcl.ENABLED" false
                   } else {
                       ip_set_param "parameter.core16_pf${pf}_bar1_type_user_hwtcl.ENABLED" true
                   }
                   if { [regexp "64-bit" $core16_pf_bar2_val] }  {
                       ip_set_param "parameter.core16_pf${pf}_bar3_type_hwtcl.value" "Disabled"
                       ip_set_param "parameter.core16_pf${pf}_bar3_type_user_hwtcl.ENABLED" false
                   } else {
                       ip_set_param "parameter.core16_pf${pf}_bar3_type_user_hwtcl.ENABLED" true
                   } 
                   if { [regexp "64-bit" $core16_pf_bar4_val] }  {
                       ip_set_param "parameter.core16_pf${pf}_bar5_type_hwtcl.value" "Disabled"
                       ip_set_param "parameter.core16_pf${pf}_bar5_type_user_hwtcl.ENABLED" false
                   } else {
                       ip_set_param "parameter.core16_pf${pf}_bar5_type_user_hwtcl.ENABLED" true
                   } 
    
    
                } else {
                   for {set i 0} {$i <= 5} {incr i 1} {
                    ip_set_param "parameter.core16_pf${pf}_bar${i}_type_hwtcl.value" "Disabled"
                    ip_set_param "parameter.core16_pf${pf}_bar${i}_address_width_hwtcl.value" 0
                   }
                }
            }
        }
    }
}
proc ::intel_pcie_ss_axi::parameters::validate_core16_pf_sriov_vf_bar_type_hwtcl { PROP_NAME PROP_VALUE core16_func_mode_hwtcl core16_virtual_rp_ep_mode_hwtcl } {
    set tile [ip_get "parameter.TILE.value"]

    if { $tile == "P-TILE" } {
        if { $core16_func_mode_hwtcl == "Disable" || $core16_virtual_rp_ep_mode_hwtcl == "Root Port" } {
            # if in rootport or core 16 is disabled set all BAR types to disabled and size to N/A
    
            # loop through all pf 0-7
            for {set pf 0} {$pf < 8} {incr pf 1} {
                # loop through all bars 0-5
                for {set i 0} {$i <= 5} {incr i 1} {
                    ip_set_param "parameter.core16_pf${pf}_sriov_vf_bar${i}_type_int_hwtcl.value" "Disabled"
                    ip_set_param "parameter.core16_pf${pf}_sriov_vf_bar${i}_address_width_int_hwtcl.value" 0
                }
            }
        } else {
            # else set them to user_hwtcl values
    
            # loop through all pf 0-7
            for {set pf 0} {$pf < 8} {incr pf 1} {
                set core16_virtual_pfi_enable_hwtcl [ip_get "parameter.core16_virtual_pf${pf}_enable_hwtcl.value"]
                if { $core16_virtual_pfi_enable_hwtcl == 1} {
                   # loop through all bars 0-5
                   for {set i 0} {$i <= 5} {incr i 1} {
                       set core16_pf_sriov_vf_bar_type_user_hwtcl($pf,$i) [get_parameter_value core16_pf${pf}_sriov_vf_bar${i}_type_hwtcl]
                       set core16_pf_sriov_vf_bar_address_width_user_hwtcl($pf,$i) [get_parameter_value core16_pf${pf}_sriov_vf_bar${i}_address_width_hwtcl]
    		    #ALLOWED_RANGES
    		    if {[regexp "64-bit" $core16_pf_sriov_vf_bar_type_user_hwtcl($pf,$i)]} {
    			    ip_set_param "parameter.core16_pf${pf}_sriov_vf_bar${i}_address_width_hwtcl.ALLOWED_RANGES" {"0:N/A" "7: 128 Bytes - 7 bits" "8: 256 Bytes - 8 bits" "9: 512 Bytes - 9 bits" "10: 1 KByte - 10 bits" "11: 2 KBytes - 11 bits" "12: 4 KBytes - 12 bits" "13: 8 KBytes - 13 bits" "14: 16 KBytes - 14 bits" "15: 32 KBytes - 15 bits" "16: 64 KBytes - 16 bits" "17: 128 KBytes - 17 bits" "18: 256 KBytes - 18 bits" "19: 512 KBytes - 19 bits" "20: 1 MByte - 20 bits" "21: 2 MBytes - 21 bits" "22: 4 MBytes - 22 bits" "23: 8 MBytes - 23 bits" "24: 16 MBytes - 24 bits" "25: 32 MBytes - 25 bits" "26: 64 MBytes - 26 bits" "27: 128 MBytes - 27 bits" "28: 256 MBytes - 28 bits" "29: 512 MBytes - 29 bits" "30: 1 GByte - 30 bits" "31: 2 GBytes - 31 bits" "32: 4 GBytes - 32 bits" "33: 8 GBytes - 33 bits" "34: 16 GBytes - 34 bits" "35: 32 GBytes - 35 bits" "36: 64 GBytes - 36 bits" "37: 128 GBytes - 37 bits" "38: 256 GBytes - 38 bits" "39: 512 GBytes - 39 bits" "40: 1 TByte - 40 bits" "41: 2 TBytes - 41 bits" "42: 4 TBytes - 42 bits" "43: 8 TBytes - 43 bits" "44: 16 TBytes - 44 bits" "45: 32 TBytes - 45 bits" "46: 64 TBytes - 46 bits" "47: 128 TBytes - 47 bits" "48: 256 TBytes - 48 bits" "49: 512 TBytes - 49 bits" "50: 1 PByte - 50 bits" "51: 2 PBytes - 51 bits" "52: 4 PBytes - 52 bits" "53: 8 PBytes - 53 bits" "54: 16 PBytes - 54 bits" "55: 32 PBytes - 55 bits" "56: 64 PBytes - 56 bits" "57: 128 PBytes - 57 bits" "58: 256 PBytes - 58 bits" "59: 512 PBytes - 59 bits" "60: 1 EByte - 60 bits" "61: 2 EBytes - 61 bits" "62: 4 EBytes - 62 bits" "63: 8 EBytes - 63 bits" "64: 16 EBytes - 64 bits"}
    		    } elseif {[regexp "32-bit" $core16_pf_sriov_vf_bar_type_user_hwtcl($pf,$i)]} {
    			    ip_set_param "parameter.core16_pf${pf}_sriov_vf_bar${i}_address_width_hwtcl.ALLOWED_RANGES" {"0:N/A" "7: 128 Bytes - 7 bits" "8: 256 Bytes - 8 bits" "9: 512 Bytes - 9 bits" "10: 1 KByte - 10 bits" "11: 2 KBytes - 11 bits" "12: 4 KBytes - 12 bits" "13: 8 KBytes - 13 bits" "14: 16 KBytes - 14 bits" "15: 32 KBytes - 15 bits" "16: 64 KBytes - 16 bits" "17: 128 KBytes - 17 bits" "18: 256 KBytes - 18 bits" "19: 512 KBytes - 19 bits" "20: 1 MByte - 20 bits" "21: 2 MBytes - 21 bits" "22: 4 MBytes - 22 bits" "23: 8 MBytes - 23 bits" "24: 16 MBytes - 24 bits" "25: 32 MBytes - 25 bits" "26: 64 MBytes - 26 bits" "27: 128 MBytes - 27 bits" "28: 256 MBytes - 28 bits" "29: 512 MBytes - 29 bits" "30: 1 GByte - 30 bits" "31: 2 GBytes - 31 bits" "32: 4 GBytes - 32 bits"}
    		    }
                       ip_set_param "parameter.core16_pf${pf}_sriov_vf_bar${i}_type_int_hwtcl.value" $core16_pf_sriov_vf_bar_type_user_hwtcl($pf,$i)
                       ip_set_param "parameter.core16_pf${pf}_sriov_vf_bar${i}_address_width_int_hwtcl.value" $core16_pf_sriov_vf_bar_address_width_user_hwtcl($pf,$i)
    				   
                   }
    
                   # if bar0/2/4 are 64 bit ; bar1/3/5 should be disabled to user
    
                   set core16_pf_sriov_vf_bar_val  [ip_get "parameter.core16_pf${pf}_sriov_vf_bar0_type_int_hwtcl.value"]
                   set core16_pf_sriov_vf_bar2_val [ip_get "parameter.core16_pf${pf}_sriov_vf_bar2_type_int_hwtcl.value"]
                   set core16_pf_sriov_vf_bar4_val [ip_get "parameter.core16_pf${pf}_sriov_vf_bar4_type_int_hwtcl.value"]
                    
                   if { [regexp "64-bit" $core16_pf_sriov_vf_bar_val] }  {
    				   ip_set_param "parameter.core16_pf${pf}_sriov_vf_bar1_type_int_hwtcl.value" "Disabled"
    				   ip_set_param "parameter.core16_pf${pf}_sriov_vf_bar1_type_hwtcl.ENABLED" false
    			   } else {
                       ip_set_param "parameter.core16_pf${pf}_sriov_vf_bar1_type_hwtcl.ENABLED" true
                   }
                   if { [regexp "64-bit" $core16_pf_sriov_vf_bar2_val] }  {
    				   ip_set_param "parameter.core16_pf${pf}_sriov_vf_bar3_type_int_hwtcl.value" "Disabled"
    				   ip_set_param "parameter.core16_pf${pf}_sriov_vf_bar3_type_hwtcl.ENABLED" false
    			   } else {
                       ip_set_param "parameter.core16_pf${pf}_sriov_vf_bar3_type_hwtcl.ENABLED" true
    			   } 
                   if { [regexp "64-bit" $core16_pf_sriov_vf_bar4_val] }  {
    				   ip_set_param "parameter.core16_pf${pf}_sriov_vf_bar5_type_int_hwtcl.value" "Disabled"
    				   ip_set_param "parameter.core16_pf${pf}_sriov_vf_bar5_type_hwtcl.ENABLED" false
    			   } else {
                       ip_set_param "parameter.core16_pf${pf}_sriov_vf_bar5_type_hwtcl.ENABLED" true
    			   } 
    
    
                } else {
                   for {set i 0} {$i <= 5} {incr i 1} {
                    ip_set_param "parameter.core16_pf${pf}_sriov_vf_bar${i}_type_int_hwtcl.value" "Disabled"
                    ip_set_param "parameter.core16_pf${pf}_sriov_vf_bar${i}_address_width_int_hwtcl.value" 0
                   }
                }
            }
        }
    } elseif { $tile == "F-TILE" } {
        if { $core16_func_mode_hwtcl == "Disable" || $core16_virtual_rp_ep_mode_hwtcl == "Root Port" } {
            # if in rootport or core 16 is disabled set all BAR types to disabled and size to N/A
    
            # loop through all pf 0-7
            for {set pf 0} {$pf < 8} {incr pf 1} {
                # loop through all bars 0-5
                for {set i 0} {$i <= 5} {incr i 1} {
                    ip_set_param "parameter.core16_pf${pf}_sriov_vf_bar${i}_type_int_hwtcl.value" "Disabled"
                    ip_set_param "parameter.core16_pf${pf}_sriov_vf_bar${i}_address_width_int_hwtcl.value" 0
                }
            }
        } else {
            # else set them to user_hwtcl values
    
            # loop through all pf 0-7
            for {set pf 0} {$pf < 8} {incr pf 1} {
                set core16_virtual_pfi_enable_hwtcl [ip_get "parameter.core16_virtual_pf${pf}_enable_hwtcl.value"]
                if { $core16_virtual_pfi_enable_hwtcl == 1} {
                   # loop through all bars 0-5
                   for {set i 0} {$i <= 5} {incr i 1} {
                       set core16_pf_sriov_vf_bar_type_user_hwtcl($pf,$i) [get_parameter_value core16_pf${pf}_sriov_vf_bar${i}_type_hwtcl]
                       set core16_pf_sriov_vf_bar_address_width_user_hwtcl($pf,$i) [get_parameter_value core16_pf${pf}_sriov_vf_bar${i}_address_width_hwtcl]
    		   			
    		    #ALLOWED_RANGES
    		    if {[regexp "64-bit" $core16_pf_sriov_vf_bar_type_user_hwtcl($pf,$i)]} {
    			    ip_set_param "parameter.core16_pf${pf}_sriov_vf_bar${i}_address_width_hwtcl.ALLOWED_RANGES" {"0:N/A" "8: 256 Bytes - 8 bits" "9: 512 Bytes - 9 bits" "10: 1 KByte - 10 bits" "11: 2 KBytes - 11 bits" "12: 4 KBytes - 12 bits" "13: 8 KBytes - 13 bits" "14: 16 KBytes - 14 bits" "15: 32 KBytes - 15 bits" "16: 64 KBytes - 16 bits" "17: 128 KBytes - 17 bits" "18: 256 KBytes - 18 bits" "19: 512 KBytes - 19 bits" "20: 1 MByte - 20 bits" "21: 2 MBytes - 21 bits" "22: 4 MBytes - 22 bits" "23: 8 MBytes - 23 bits" "24: 16 MBytes - 24 bits" "25: 32 MBytes - 25 bits" "26: 64 MBytes - 26 bits" "27: 128 MBytes - 27 bits" "28: 256 MBytes - 28 bits" "29: 512 MBytes - 29 bits" "30: 1 GByte - 30 bits" "31: 2 GBytes - 31 bits" "32: 4 GBytes - 32 bits" "33: 8 GBytes - 33 bits" "34: 16 GBytes - 34 bits" "35: 32 GBytes - 35 bits" "36: 64 GBytes - 36 bits" "37: 128 GBytes - 37 bits" "38: 256 GBytes - 38 bits" "39: 512 GBytes - 39 bits" "40: 1 TByte - 40 bits" "41: 2 TBytes - 41 bits" "42: 4 TBytes - 42 bits" "43: 8 TBytes - 43 bits" "44: 16 TBytes - 44 bits" "45: 32 TBytes - 45 bits" "46: 64 TBytes - 46 bits" "47: 128 TBytes - 47 bits" "48: 256 TBytes - 48 bits" "49: 512 TBytes - 49 bits" "50: 1 PByte - 50 bits" "51: 2 PBytes - 51 bits" "52: 4 PBytes - 52 bits" "53: 8 PBytes - 53 bits" "54: 16 PBytes - 54 bits" "55: 32 PBytes - 55 bits" "56: 64 PBytes - 56 bits" "57: 128 PBytes - 57 bits" "58: 256 PBytes - 58 bits" "59: 512 PBytes - 59 bits" "60: 1 EByte - 60 bits" "61: 2 EBytes - 61 bits" "62: 4 EBytes - 62 bits" "63: 8 EBytes - 63 bits" "64: 16 EBytes - 64 bits"}
    		    } elseif {[regexp "32-bit" $core16_pf_sriov_vf_bar_type_user_hwtcl($pf,$i)]} {
    			    ip_set_param "parameter.core16_pf${pf}_sriov_vf_bar${i}_address_width_hwtcl.ALLOWED_RANGES" {"0:N/A" "8: 256 Bytes - 8 bits" "9: 512 Bytes - 9 bits" "10: 1 KByte - 10 bits" "11: 2 KBytes - 11 bits" "12: 4 KBytes - 12 bits" "13: 8 KBytes - 13 bits" "14: 16 KBytes - 14 bits" "15: 32 KBytes - 15 bits" "16: 64 KBytes - 16 bits" "17: 128 KBytes - 17 bits" "18: 256 KBytes - 18 bits" "19: 512 KBytes - 19 bits" "20: 1 MByte - 20 bits" "21: 2 MBytes - 21 bits" "22: 4 MBytes - 22 bits" "23: 8 MBytes - 23 bits" "24: 16 MBytes - 24 bits" "25: 32 MBytes - 25 bits" "26: 64 MBytes - 26 bits" "27: 128 MBytes - 27 bits" "28: 256 MBytes - 28 bits" "29: 512 MBytes - 29 bits" "30: 1 GByte - 30 bits" "31: 2 GBytes - 31 bits" "32: 4 GBytes - 32 bits"}
    		    }
                    
                       ip_set_param "parameter.core16_pf${pf}_sriov_vf_bar${i}_type_int_hwtcl.value" $core16_pf_sriov_vf_bar_type_user_hwtcl($pf,$i)
                       ip_set_param "parameter.core16_pf${pf}_sriov_vf_bar${i}_address_width_int_hwtcl.value" $core16_pf_sriov_vf_bar_address_width_user_hwtcl($pf,$i)
    				   
                   }
    
                   # if bar0/2/4 are 64 bit ; bar1/3/5 should be disabled to user
    
                   set core16_pf_sriov_vf_bar_val  [ip_get "parameter.core16_pf${pf}_sriov_vf_bar0_type_int_hwtcl.value"]
                   set core16_pf_sriov_vf_bar2_val [ip_get "parameter.core16_pf${pf}_sriov_vf_bar2_type_int_hwtcl.value"]
                   set core16_pf_sriov_vf_bar4_val [ip_get "parameter.core16_pf${pf}_sriov_vf_bar4_type_int_hwtcl.value"]
                    
                   if { [regexp "64-bit" $core16_pf_sriov_vf_bar_val] }  {
    				   ip_set_param "parameter.core16_pf${pf}_sriov_vf_bar1_type_int_hwtcl.value" "Disabled"
    				   ip_set_param "parameter.core16_pf${pf}_sriov_vf_bar1_type_hwtcl.ENABLED" false
    			   } else {
                       ip_set_param "parameter.core16_pf${pf}_sriov_vf_bar1_type_hwtcl.ENABLED" true
                   }
                   if { [regexp "64-bit" $core16_pf_sriov_vf_bar2_val] }  {
    				   ip_set_param "parameter.core16_pf${pf}_sriov_vf_bar3_type_int_hwtcl.value" "Disabled"
    				   ip_set_param "parameter.core16_pf${pf}_sriov_vf_bar3_type_hwtcl.ENABLED" false
    			   } else {
                       ip_set_param "parameter.core16_pf${pf}_sriov_vf_bar3_type_hwtcl.ENABLED" true
    			   } 
                   if { [regexp "64-bit" $core16_pf_sriov_vf_bar4_val] }  {
    				   ip_set_param "parameter.core16_pf${pf}_sriov_vf_bar5_type_int_hwtcl.value" "Disabled"
    				   ip_set_param "parameter.core16_pf${pf}_sriov_vf_bar5_type_hwtcl.ENABLED" false
    			   } else {
                       ip_set_param "parameter.core16_pf${pf}_sriov_vf_bar5_type_hwtcl.ENABLED" true
    			   } 
    
    
                } else {
                   for {set i 0} {$i <= 5} {incr i 1} {
                    ip_set_param "parameter.core16_pf${pf}_sriov_vf_bar${i}_type_int_hwtcl.value" "Disabled"
                    ip_set_param "parameter.core16_pf${pf}_sriov_vf_bar${i}_address_width_int_hwtcl.value" 0
                   }
                }
            }
        }
    } 
}
proc ::intel_pcie_ss_axi::parameters::validate_core16_virtual_pf0_margin_cap_enable_hwtcl {PROP_NAME PROP_VALUE} {
    set core16_func_mode [ip_get "parameter.core16_func_mode_hwtcl.value"]
    set core16_link_rate [ip_get "parameter.core16_virtual_link_rate_hwtcl.value"]

    if { $core16_func_mode == "Disable" } {
        ip_set_param "parameter.core16_virtual_pf0_margin_cap_enable_hwtcl.value" 0
    } elseif { $core16_link_rate == "Gen4 (16.0 Gbps)" } {
        ip_set_param "parameter.core16_virtual_pf0_margin_cap_enable_hwtcl.value" 1
    } else {
        ip_set_param "parameter.core16_virtual_pf0_margin_cap_enable_hwtcl.value" 0
    }
}

proc ::intel_pcie_ss_axi::parameters::validate_core16_virtual_pf0_pl16g_cap_enable_hwtcl {PROP_NAME PROP_VALUE} {
    set core16_func_mode [ip_get "parameter.core16_func_mode_hwtcl.value"]
    set core16_link_rate [ip_get "parameter.core16_virtual_link_rate_hwtcl.value"]

    if { $core16_func_mode == "Disable" } {
        ip_set_param "parameter.core16_virtual_pf0_pl16g_cap_enable_hwtcl.value" 0
    } elseif { $core16_link_rate == "Gen4 (16.0 Gbps)" } {
        ip_set_param "parameter.core16_virtual_pf0_pl16g_cap_enable_hwtcl.value" 1
    } else {
        ip_set_param "parameter.core16_virtual_pf0_pl16g_cap_enable_hwtcl.value" 0
    }
}
proc ::intel_pcie_ss_axi::parameters::validate_core16_enable_multi_func_hwtcl {PROP_NAME PROP_VALUE} {
    set core16_func_mode [ip_get "parameter.core16_func_mode_hwtcl.value"]
    set core16_enable_multi_func_hwtcl [ip_get "parameter.core16_enable_multi_func_hwtcl.value"]
    set core16_enable_sriov_hwtcl [ip_get "parameter.core16_enable_sriov_hwtcl.value"]
    set core16_total_pf_count_hwtcl [ip_get "parameter.core16_total_pf_count_hwtcl.value"]
    
    if { $core16_func_mode == "Enable" && $core16_enable_multi_func_hwtcl == 1 && $core16_enable_sriov_hwtcl == 0 && $core16_total_pf_count_hwtcl < 2 } {
        send_message error "When PCIe0 Multifunction is enabled, the PF count must be greater than 1 or SRIOV must be enabled"
    }
}
proc ::intel_pcie_ss_axi::parameters::validate_core16_virtual_ecrc_strip_hwtcl {core16_func_mode_hwtcl core16_virtual_tlp_bypass_en_hwtcl core16_virtual_ecrc_strip_user_hwtcl} {
    set tile [ip_get "parameter.TILE.value"]

    if { $tile == "P-TILE" || $tile == "R-TILE" } {
    	if { $core16_func_mode_hwtcl == "Disable" } {
    		ip_set_param "parameter.core16_virtual_ecrc_strip_hwtcl.value" 0
    	} elseif {$core16_virtual_tlp_bypass_en_hwtcl} {
    		ip_set_param "parameter.core16_virtual_ecrc_strip_hwtcl.value" $core16_virtual_ecrc_strip_user_hwtcl
    	} else {
    		ip_set_param "parameter.core16_virtual_ecrc_strip_hwtcl.value" 1
    	}
    } elseif { $tile == "F-TILE" } {
    	if { $core16_func_mode_hwtcl == "Disable" } {
    		ip_set_param "parameter.core16_virtual_ecrc_strip_hwtcl.value" 0
    	} elseif {$core16_virtual_tlp_bypass_en_hwtcl} {
    		ip_set_param "parameter.core16_virtual_ecrc_strip_hwtcl.value" $core16_virtual_ecrc_strip_user_hwtcl
    	} else {
    		ip_set_param "parameter.core16_virtual_ecrc_strip_hwtcl.value" 1
    	}
    
    	set silicon_rev_b0 [get_parameter_value device_revision]
    	if { ![regexp "gdrb" $silicon_rev_b0 ]} {
    	    ip_set_param "parameter.core16_virtual_ecrc_strip_user_hwtcl.VISIBLE" false
    	}
    }
}
proc ::intel_pcie_ss_axi::parameters::validate_core16_pfi_int_pin_hwtcl {PROP_NAME PROP_VALUE core16_enable_multi_func_hwtcl core16_total_pf_count_hwtcl  } {
    regexp {pf.} $PROP_NAME pf_num
    set core16_virtual_msi_enable_hwtcl [ip_get "parameter.core16_virtual_${pf_num}_msi_enable_hwtcl.value"]
    set core16_virtual_msix_enable_hwtcl [ip_get "parameter.core16_virtual_${pf_num}_msix_enable_hwtcl.value"]
    set core16_int_pin_hwtcl [ip_get "parameter.core16_${pf_num}_int_pin_hwtcl.value"]

    if {$core16_enable_multi_func_hwtcl == 1 && $core16_total_pf_count_hwtcl > 1} {
        ip_set "parameter.core16_${pf_num}_int_pin_hwtcl.ALLOWED_RANGES" {"NO INT" "INTA" "INTB" "INTC" "INTD"}
    } else {
        ip_set "parameter.core16_${pf_num}_int_pin_hwtcl.ALLOWED_RANGES" {"NO INT" "INTA"}
    }

    #Rule: Enable Legacy Interrupt must enable MSI or MSIX
    if {[expr {$core16_int_pin_hwtcl != "NO INT"} ] && $core16_virtual_msi_enable_hwtcl ==0 && $core16_virtual_msix_enable_hwtcl == 0} {
        send_message error "When Legacy interrupts are enabled for PCIe0 ${pf_num}, either MSI or MISX or both must be enabled for ${pf_num}"
    }
}
# ACS Cap validation calls
proc ::intel_pcie_ss_axi::parameters::validate_core16_pf_acs_cap_acs_src_valid_hwtcl {PROP_NAME PROP_VALUE} {
    set core16_func_mode [ip_get "parameter.core16_func_mode_hwtcl.value"]
    set core16_virtual_rp_ep_mode_integer_hwtcl [ip_get "parameter.core16_virtual_rp_ep_mode_integer_hwtcl.value"]

    regexp {pf.} $PROP_NAME pf_num
    set core16_virtual_pf_acs_cap_enable_hwtcl [ip_get "parameter.core16_virtual_${pf_num}_acs_cap_enable_hwtcl.value"]

    # enable for root port
    if { $core16_func_mode == "Enable" && $core16_virtual_rp_ep_mode_integer_hwtcl == 1 && $core16_virtual_pf_acs_cap_enable_hwtcl == 1} {
        ip_set_param "parameter.${PROP_NAME}.value" 1
    } else {
        ip_set_param "parameter.${PROP_NAME}.value" 0
    }
}

proc ::intel_pcie_ss_axi::parameters::validate_core16_pf_acs_cap_acs_at_block_hwtcl {PROP_NAME PROP_VALUE} {
    set core16_func_mode [ip_get "parameter.core16_func_mode_hwtcl.value"]
    set core16_virtual_rp_ep_mode_integer_hwtcl [ip_get "parameter.core16_virtual_rp_ep_mode_integer_hwtcl.value"]

    regexp {pf.} $PROP_NAME pf_num
    set core16_virtual_pf_acs_cap_enable_hwtcl [ip_get "parameter.core16_virtual_${pf_num}_acs_cap_enable_hwtcl.value"]

    # enable for root port
    if { $core16_func_mode == "Enable" && $core16_virtual_rp_ep_mode_integer_hwtcl == 1 && $core16_virtual_pf_acs_cap_enable_hwtcl == 1} {
        ip_set_param "parameter.${PROP_NAME}.value" 1
    } else {
        ip_set_param "parameter.${PROP_NAME}.value" 0
    }
}
proc ::intel_pcie_ss_axi::parameters::validate_core16_pf_acs_cap_acs_p2p_req_redirect_hwtcl {PROP_NAME PROP_VALUE} {
    set core16_func_mode [ip_get "parameter.core16_func_mode_hwtcl.value"]
    set core16_enable_multi_func_hwtcl [ip_get "parameter.core16_enable_multi_func_hwtcl.value"]
    set core16_virtual_rp_ep_mode_integer_hwtcl [ip_get "parameter.core16_virtual_rp_ep_mode_integer_hwtcl.value"]

    regexp {pf.} $PROP_NAME pf_num
    set core16_pf_acs_cap_peer_to_peer_traffic_supp_hwtcl [ip_get "parameter.core16_${pf_num}_acs_cap_peer_to_peer_traffic_supp_hwtcl.value"]
    set core16_virtual_pf_acs_cap_enable_hwtcl [ip_get "parameter.core16_virtual_${pf_num}_acs_cap_enable_hwtcl.value"]
    set core16_virtual_pf_enable_hwtcl [ip_get "parameter.core16_virtual_${pf_num}_enable_hwtcl.value"]

    # set to same as request redirect if core enabled and acs is enabled
    if { $core16_func_mode == "Enable" && $core16_virtual_pf_acs_cap_enable_hwtcl == 1 && ( ($core16_enable_multi_func_hwtcl && $core16_virtual_pf_enable_hwtcl) || $core16_virtual_rp_ep_mode_integer_hwtcl ) } {
        ip_set_param "parameter.${PROP_NAME}.value" $core16_pf_acs_cap_peer_to_peer_traffic_supp_hwtcl
    } else {
        ip_set_param "parameter.${PROP_NAME}.value" 0
    }
}

proc ::intel_pcie_ss_axi::parameters::validate_core16_pf_acs_cap_acs_p2p_cpl_redirect_hwtcl {PROP_NAME PROP_VALUE} {
    set core16_func_mode [ip_get "parameter.core16_func_mode_hwtcl.value"]
    set core16_enable_multi_func_hwtcl [ip_get "parameter.core16_enable_multi_func_hwtcl.value"]
    set core16_virtual_rp_ep_mode_integer_hwtcl [ip_get "parameter.core16_virtual_rp_ep_mode_integer_hwtcl.value"]

    regexp {pf.} $PROP_NAME pf_num
    set core16_pf_acs_cap_peer_to_peer_traffic_supp_hwtcl [ip_get "parameter.core16_${pf_num}_acs_cap_peer_to_peer_traffic_supp_hwtcl.value"]
    set core16_virtual_pf_acs_cap_enable_hwtcl [ip_get "parameter.core16_virtual_${pf_num}_acs_cap_enable_hwtcl.value"]
    set core16_virtual_pf_enable_hwtcl [ip_get "parameter.core16_virtual_${pf_num}_enable_hwtcl.value"]

    # set to same as request redirect if core enabled and acs is enabled
    if { $core16_func_mode == "Enable" && $core16_virtual_pf_acs_cap_enable_hwtcl == 1 && ( ($core16_enable_multi_func_hwtcl && $core16_virtual_pf_enable_hwtcl) || $core16_virtual_rp_ep_mode_integer_hwtcl ) } {
        ip_set_param "parameter.${PROP_NAME}.value" $core16_pf_acs_cap_peer_to_peer_traffic_supp_hwtcl
    } else {
        ip_set_param "parameter.${PROP_NAME}.value" 0
    }
}
proc ::intel_pcie_ss_axi::parameters::validate_core16_pf_acs_cap_acs_usp_forwarding_hwtcl {PROP_NAME PROP_VALUE} {
    set core16_func_mode [ip_get "parameter.core16_func_mode_hwtcl.value"]
    set core16_virtual_rp_ep_mode_integer_hwtcl [ip_get "parameter.core16_virtual_rp_ep_mode_integer_hwtcl.value"]

    regexp {pf.} $PROP_NAME pf_num
    set core16_pf_acs_cap_peer_to_peer_traffic_supp_hwtcl [ip_get "parameter.core16_${pf_num}_acs_cap_peer_to_peer_traffic_supp_hwtcl.value"]
    set core16_virtual_pf_acs_cap_enable_hwtcl [ip_get "parameter.core16_virtual_${pf_num}_acs_cap_enable_hwtcl.value"]

    # if root port mode then set to same value as req redirect, otherwise disable
    if { $core16_func_mode == "Enable" && $core16_virtual_rp_ep_mode_integer_hwtcl == 1 && $core16_virtual_pf_acs_cap_enable_hwtcl == 1} {
        ip_set_param "parameter.${PROP_NAME}.value" $core16_pf_acs_cap_peer_to_peer_traffic_supp_hwtcl
    } else {
        ip_set_param "parameter.${PROP_NAME}.value" 0
    }
}

proc ::intel_pcie_ss_axi::parameters::validate_core16_pf_acs_cap_acs_direct_translated_p2p_hwtcl {PROP_NAME PROP_VALUE} {
    set core16_func_mode [ip_get "parameter.core16_func_mode_hwtcl.value"]
    set core16_enable_multi_func_hwtcl [ip_get "parameter.core16_enable_multi_func_hwtcl.value"]
    set core16_virtual_rp_ep_mode_integer_hwtcl [ip_get "parameter.core16_virtual_rp_ep_mode_integer_hwtcl.value"]

    regexp {pf.} $PROP_NAME pf_num
    set core16_pf_acs_cap_peer_to_peer_traffic_supp_hwtcl [ip_get "parameter.core16_${pf_num}_acs_cap_peer_to_peer_traffic_supp_hwtcl.value"]
    set core16_virtual_pf_ats_cap_enable_hwtcl [ip_get "parameter.core16_virtual_${pf_num}_ats_cap_enable_hwtcl.value"]
    set core16_virtual_pf_acs_cap_enable_hwtcl [ip_get "parameter.core16_virtual_${pf_num}_acs_cap_enable_hwtcl.value"]
    set core16_virtual_pf_enable_hwtcl [ip_get "parameter.core16_virtual_${pf_num}_enable_hwtcl.value"]

    # if core enabled and req redirect enabled and ats enabled, set to enable
    if {$core16_func_mode == "Enable" && $core16_enable_multi_func_hwtcl && $core16_virtual_pf_enable_hwtcl && $core16_virtual_pf_ats_cap_enable_hwtcl == 1 && $core16_virtual_pf_acs_cap_enable_hwtcl && $core16_pf_acs_cap_peer_to_peer_traffic_supp_hwtcl} {
        # EP with Multifunction
        ip_set_param "parameter.${PROP_NAME}.value" 1
    } elseif { $core16_func_mode == "Enable" && $core16_virtual_rp_ep_mode_integer_hwtcl && $core16_virtual_pf_acs_cap_enable_hwtcl && $core16_pf_acs_cap_peer_to_peer_traffic_supp_hwtcl } {
        # rootport
        ip_set_param "parameter.${PROP_NAME}.value" 1
    } else {
        ip_set_param "parameter.${PROP_NAME}.value" 0
    }
}
# End ACS validation
proc ::intel_pcie_ss_axi::parameters::validate_core16_pcie_cap_rcb_hwtcl { PROP_NAME PROP_VALUE } {
    set tile [ip_get "parameter.TILE.value"]

    if { $tile == "P-TILE" } {
        set core16_func [ip_get "parameter.core16_func_mode_hwtcl.value"]
        set core16_virtual_rp_ep_mode_integer [ip_get "parameter.core16_virtual_rp_ep_mode_integer_hwtcl.value"]

        # get which pf
        regexp {pf.} $PROP_NAME pf_num

        if { $core16_func == "Disable" || $core16_virtual_rp_ep_mode_integer == 0} {
            ip_set_param "parameter.${PROP_NAME}.value" "${pf_num}_rcb_64"
        } else {
            ip_set_param "parameter.${PROP_NAME}.value" "${pf_num}_rcb_128"
        }
    } 
    #param not in Ftile SS
    
}

proc ::intel_pcie_ss_axi::parameters::validate_core16_pcie_cap_sel_deemphasis_hwtcl { PROP_NAME PROP_VALUE } {
    set tile [ip_get "parameter.TILE.value"]
    # get pf num
        regexp {pf.} $PROP_NAME pfnum

        set core16_func [ip_get "parameter.core16_func_mode_hwtcl.value"]
        set core16_virtual_rp_ep_mode_integer [ip_get "parameter.core16_virtual_rp_ep_mode_integer_hwtcl.value"]
    
        # get which pf
        regexp {pf.} $PROP_NAME pf_num
    
        if { $core16_func == "Disable" || $core16_virtual_rp_ep_mode_integer == 0} {
            ip_set_param "parameter.${PROP_NAME}.value" "${pf_num}_minus_6db"
        } else {
            ip_set_param "parameter.${PROP_NAME}.value" "${pf_num}_minus_3db"
        }
    
}

proc ::intel_pcie_ss_axi::parameters::validate_core16_pcie_cap_sel_deemphasis_hwtcl_f { PROP_NAME PROP_VALUE } {
    set tile [ip_get "parameter.TILE.value"]
    # get pf num
        regexp {pf.} $PROP_NAME pfnum

    
        if {$pfnum == 0} {
            set core16_func [ip_get "parameter.core16_func_mode_hwtcl.value"]
            set core16_virtual_rp_ep_mode_integer [ip_get "parameter.core16_virtual_rp_ep_mode_integer_hwtcl.value"]
        
            if { $core16_func == "Disable" || $core16_virtual_rp_ep_mode_integer == 0} {
                ip_set_param "parameter.${PROP_NAME}.value" "CTOP_CORE16_PF0_MINUS_6DB"
            } else {
                ip_set_param "parameter.${PROP_NAME}.value" "CTOP_CORE16_PF0_MINUS_3DB"
            }
        } 
        #pf1-pf7 param do not exist in Ftile SS 
    
}

proc  ::intel_pcie_ss_axi::parameters::validate_core16_pf0_ari_acs_fun_grp_cap_hwtcl { PROP_NAME PROP_VALUE core16_pf0_acs_cap_acs_p2p_egress_control_hwtcl core16_pf1_acs_cap_acs_p2p_egress_control_hwtcl core16_pf2_acs_cap_acs_p2p_egress_control_hwtcl core16_pf3_acs_cap_acs_p2p_egress_control_hwtcl core16_pf4_acs_cap_acs_p2p_egress_control_hwtcl core16_pf5_acs_cap_acs_p2p_egress_control_hwtcl core16_pf6_acs_cap_acs_p2p_egress_control_hwtcl core16_pf7_acs_cap_acs_p2p_egress_control_hwtcl} {
    set tile [ip_get "parameter.TILE.value"]

     if { $tile == "P-TILE" } {
     
         if { $core16_pf0_acs_cap_acs_p2p_egress_control_hwtcl || $core16_pf1_acs_cap_acs_p2p_egress_control_hwtcl || $core16_pf2_acs_cap_acs_p2p_egress_control_hwtcl || $core16_pf3_acs_cap_acs_p2p_egress_control_hwtcl || $core16_pf4_acs_cap_acs_p2p_egress_control_hwtcl || $core16_pf5_acs_cap_acs_p2p_egress_control_hwtcl || $core16_pf6_acs_cap_acs_p2p_egress_control_hwtcl || $core16_pf7_acs_cap_acs_p2p_egress_control_hwtcl} {
             ip_set_param "parameter.${PROP_NAME}.value" 1
         } else {
             ip_set_param "parameter.${PROP_NAME}.value" 0
         }
     } elseif { $tile == "F-TILE" } {
         set core16_pf0_acs_cap_acs_p2p_egress_control_hwtcl [ip_get "parameter.core16_pf0_acs_cap_acs_p2p_egress_control_hwtcl.value"]
         set core16_pf1_acs_cap_acs_p2p_egress_control_hwtcl [ip_get "parameter.core16_pf1_acs_cap_acs_p2p_egress_control_hwtcl.value"]
         set core16_pf2_acs_cap_acs_p2p_egress_control_hwtcl [ip_get "parameter.core16_pf2_acs_cap_acs_p2p_egress_control_hwtcl.value"]
         set core16_pf3_acs_cap_acs_p2p_egress_control_hwtcl [ip_get "parameter.core16_pf3_acs_cap_acs_p2p_egress_control_hwtcl.value"]
         set core16_pf4_acs_cap_acs_p2p_egress_control_hwtcl [ip_get "parameter.core16_pf4_acs_cap_acs_p2p_egress_control_hwtcl.value"]
         set core16_pf5_acs_cap_acs_p2p_egress_control_hwtcl [ip_get "parameter.core16_pf5_acs_cap_acs_p2p_egress_control_hwtcl.value"]
         set core16_pf6_acs_cap_acs_p2p_egress_control_hwtcl [ip_get "parameter.core16_pf6_acs_cap_acs_p2p_egress_control_hwtcl.value"]
         set core16_pf7_acs_cap_acs_p2p_egress_control_hwtcl [ip_get "parameter.core16_pf7_acs_cap_acs_p2p_egress_control_hwtcl.value"]
         if { $core16_pf0_acs_cap_acs_p2p_egress_control_hwtcl || $core16_pf1_acs_cap_acs_p2p_egress_control_hwtcl || $core16_pf2_acs_cap_acs_p2p_egress_control_hwtcl|| $core16_pf3_acs_cap_acs_p2p_egress_control_hwtcl || $core16_pf4_acs_cap_acs_p2p_egress_control_hwtcl  || $core16_pf5_acs_cap_acs_p2p_egress_control_hwtcl  || $core16_pf6_acs_cap_acs_p2p_egress_control_hwtcl  || $core16_pf7_acs_cap_acs_p2p_egress_control_hwtcl  } {
             ip_set_param "parameter.${PROP_NAME}.value" 1
         } else {
             ip_set_param "parameter.${PROP_NAME}.value" 0
         }
     }
}
proc ::intel_pcie_ss_axi::parameters::validate_core16_pfi_vf_count_hwtcl {PROP_NAME PROP_VALUE} {
	
	for { set i 0 } { $i < 8 } { incr i } {
	set core16_virtual_pfi_sriov_enable_hwtcl 		[ip_get "parameter.core16_virtual_pf${i}_sriov_enable_hwtcl.value"]
	set core16_pfi_vf_count_hwtcl 					[ip_get "parameter.core16_pf${i}_vf_count_hwtcl.value"]
	set core16_virtual_pfi_msix_enable_hwtcl 		[ip_get "parameter.core16_virtual_pf${i}_msix_enable_hwtcl.value"]
		if {$core16_virtual_pfi_msix_enable_hwtcl == 0} {
			#send_message info "$core16_pfi_vf_count_hwtcl"
			if { (($core16_virtual_pfi_sriov_enable_hwtcl==1)&&($core16_pfi_vf_count_hwtcl>0))} {
			 send_message error  "When VF count is greater than 0 for PF${i} VF PCIe0, PF${i} MSI-X should be enabled "
			}
		}
	}
}
proc ::intel_pcie_ss_axi::parameters::validate_core16_pf0_eq_redo_hwtcl { PROP_NAME PROP_VALUE core16_virtual_rp_ep_mode_integer_hwtcl} {
    
        if { $core16_virtual_rp_ep_mode_integer_hwtcl == 0 } {
            # EP mode
            ip_set_param "parameter.${PROP_NAME}.value" "disable"
        } else {
            ip_set_param "parameter.${PROP_NAME}.value" "enable"
        }
    
}

#vww18added 
proc ::intel_pcie_ss_axi::parameters::validate_core16_pf0_eq_redo_hwtcl_f { PROP_NAME PROP_VALUE core16_virtual_rp_ep_mode_integer_hwtcl} {
    set tile [ip_get "parameter.TILE.value"]

    
        if { $core16_virtual_rp_ep_mode_integer_hwtcl == 0 } {
            # EP mode
            ip_set_param "parameter.${PROP_NAME}.value" "DISABLE"
        } else {
            ip_set_param "parameter.${PROP_NAME}.value" "ENABLE"
        }
    
    
}

proc ::intel_pcie_ss_axi::parameters::validate_core16_pf0_eq_redo_atg4_hwtcl { PROP_NAME PROP_VALUE core16_virtual_rp_ep_mode_integer_hwtcl} {
    set tile [ip_get "parameter.TILE.value"]

    
        if { $core16_virtual_rp_ep_mode_integer_hwtcl == 0 } {
            # EP mode
            ip_set_param "parameter.${PROP_NAME}.value" "disable"
        } else {
            ip_set_param "parameter.${PROP_NAME}.value" "enable"
        }
    
}

#vww18 added
proc ::intel_pcie_ss_axi::parameters::validate_core16_pf0_eq_redo_atg4_hwtcl_f { PROP_NAME PROP_VALUE core16_virtual_rp_ep_mode_integer_hwtcl} {
    set tile [ip_get "parameter.TILE.value"]

   
        if { $core16_virtual_rp_ep_mode_integer_hwtcl == 0 } {
            # EP mode
            ip_set_param "parameter.${PROP_NAME}.value" "DISABLE"
        } else {
            ip_set_param "parameter.${PROP_NAME}.value" "ENABLE"
        }
    
}

proc ::intel_pcie_ss_axi::parameters::validate_core16_debug_features { } {
        # Debug Features for Internal and External Customer
        # This callback must put at the last parameter of the list, or else the VISIBLE will not take effect
        #VISIBLE default set to false
        ip_set_param "parameter.core16_user_mode_to_pld_in_use_hwtcl.VISIBLE" false
        ip_set_param "parameter.core16_user_mode_to_pld_in_use_hwtcl.ENABLED" false
        ip_set_param "parameter.core16_enable_pld_warm_rst_rdy_hwtcl.VISIBLE" false
        ip_set_param "parameter.core16_enable_pld_warm_rst_rdy_hwtcl.ENABLED" false
        ip_set_param "parameter.core16_rxbuf_limit_posted_bypass_hwtcl.VISIBLE" false
        ip_set_param "parameter.core16_rxbuf_limit_posted_bypass_hwtcl.ENABLED" false
        ip_set_param "parameter.core16_rxbuf_limit_nonposted_bypass_hwtcl.VISIBLE" false
        ip_set_param "parameter.core16_rxbuf_limit_nonposted_bypass_hwtcl.ENABLED" false
        ip_set_param "parameter.core16_rxbuf_limit_cpl_bypass_hwtcl.VISIBLE" false
        ip_set_param "parameter.core16_rxbuf_limit_cpl_bypass_hwtcl.ENABLED" false
        set core16_enable_rx_buffer_limit_ports_hwtcl [ip_get "parameter.core16_enable_rx_buffer_limit_ports_hwtcl.value"]
        set avmm_enabled_hwtcl                        [ip_get "parameter.avmm_enabled_hwtcl.value"]
        set rxbuf_features_enablement                 [ip_get "parameter.rxbuf_features_enablement_full.value"]
        if {$rxbuf_features_enablement == 1} {
            ip_set_param "parameter.core16_user_mode_to_pld_in_use_hwtcl.VISIBLE" true
            ip_set_param "parameter.core16_user_mode_to_pld_in_use_hwtcl.ENABLED" true
            ip_set_param "parameter.core16_enable_pld_warm_rst_rdy_hwtcl.VISIBLE" true
            ip_set_param "parameter.core16_enable_pld_warm_rst_rdy_hwtcl.ENABLED" true
            if {$core16_enable_rx_buffer_limit_ports_hwtcl ==1 && $avmm_enabled_hwtcl ==0} {
                ip_set_param "parameter.core16_rxbuf_limit_posted_bypass_hwtcl.VISIBLE" true
                ip_set_param "parameter.core16_rxbuf_limit_posted_bypass_hwtcl.ENABLED" true
                ip_set_param "parameter.core16_rxbuf_limit_nonposted_bypass_hwtcl.VISIBLE" true
                ip_set_param "parameter.core16_rxbuf_limit_nonposted_bypass_hwtcl.ENABLED" true
                ip_set_param "parameter.core16_rxbuf_limit_cpl_bypass_hwtcl.VISIBLE" true
                ip_set_param "parameter.core16_rxbuf_limit_cpl_bypass_hwtcl.ENABLED" true
            }
        }
}
proc ::intel_pcie_ss_axi::parameters::validate_core16_debug_features_r {top_topology_hwtcl} {
	# Debug Features for Internal and External Customer
	# This callback must put at the last parameter of the list, or else the VISIBLE will not take effect
	#VISIBLE default set to false	
	ip_set_param "parameter.core16_user_mode_to_pld_in_use_hwtcl.VISIBLE" false
	ip_set_param "parameter.core16_user_mode_to_pld_in_use_hwtcl.ENABLED" false
	ip_set_param "parameter.core16_enable_pld_warm_rst_rdy_hwtcl.VISIBLE" false
	ip_set_param "parameter.core16_enable_pld_warm_rst_rdy_hwtcl.ENABLED" false
	ip_set_param "parameter.core16_rx_dsk_enable_hwtcl.VISIBLE" false
	ip_set_param "parameter.core16_rx_dsk_enable_hwtcl.ENABLED" false
	ip_set_param "parameter.core16_tx_precode_req_hwtcl.VISIBLE" false
	ip_set_param "parameter.core16_tx_precode_req_hwtcl.ENABLED" false
	ip_set_param "parameter.core16_l1sub_control1_reg_l1_1_aspm_support_hwtcl.VISIBLE" false
	ip_set_param "parameter.core16_l1sub_control1_reg_l1_1_aspm_support_hwtcl.ENABLED" false
	ip_set_param "parameter.core16_l1sub_control1_reg_l1_2_aspm_support_hwtcl.VISIBLE" false
	ip_set_param "parameter.core16_l1sub_control1_reg_l1_2_aspm_support_hwtcl.ENABLED" false
	ip_set_param "parameter.core16_l1sub_control1_reg_l1_1_pcipm_support_hwtcl.VISIBLE" false
	ip_set_param "parameter.core16_l1sub_control1_reg_l1_1_pcipm_support_hwtcl.ENABLED" false
	ip_set_param "parameter.core16_l1sub_control1_reg_l1_2_pcipm_support_hwtcl.VISIBLE" false
	ip_set_param "parameter.core16_l1sub_control1_reg_l1_2_pcipm_support_hwtcl.ENABLED" false
	ip_set_param "parameter.core16_multi_lane_upconfigure_support_user_hwtcl.VISIBLE" false
	ip_set_param "parameter.core16_multi_lane_upconfigure_support_user_hwtcl.ENABLED" false

	set debug_features_enablement [get_quartus_ini "debug_features_enablement_full" ENABLED]
	if {$debug_features_enablement == 1} {
		if {[regexp "Pipe Direct 16-channel" $top_topology_hwtcl]} {
		} else {
			ip_set_param "parameter.core16_user_mode_to_pld_in_use_hwtcl.VISIBLE" true
			ip_set_param "parameter.core16_user_mode_to_pld_in_use_hwtcl.ENABLED" true
			ip_set_param "parameter.core16_enable_pld_warm_rst_rdy_hwtcl.VISIBLE" true
			ip_set_param "parameter.core16_enable_pld_warm_rst_rdy_hwtcl.ENABLED" true
			ip_set_param "parameter.core16_rx_dsk_enable_hwtcl.VISIBLE" true
			ip_set_param "parameter.core16_rx_dsk_enable_hwtcl.ENABLED" true
			ip_set_param "parameter.core16_tx_precode_req_hwtcl.VISIBLE" true
			ip_set_param "parameter.core16_tx_precode_req_hwtcl.ENABLED" true
			
			ip_set_param "parameter.core16_l1sub_control1_reg_l1_1_aspm_support_hwtcl.VISIBLE" true
			ip_set_param "parameter.core16_l1sub_control1_reg_l1_1_aspm_support_hwtcl.ENABLED" true
			ip_set_param "parameter.core16_l1sub_control1_reg_l1_2_aspm_support_hwtcl.VISIBLE" true
			ip_set_param "parameter.core16_l1sub_control1_reg_l1_2_aspm_support_hwtcl.ENABLED" true
			ip_set_param "parameter.core16_l1sub_control1_reg_l1_1_pcipm_support_hwtcl.VISIBLE" true
			ip_set_param "parameter.core16_l1sub_control1_reg_l1_1_pcipm_support_hwtcl.ENABLED" true
			ip_set_param "parameter.core16_l1sub_control1_reg_l1_2_pcipm_support_hwtcl.VISIBLE" true
			ip_set_param "parameter.core16_l1sub_control1_reg_l1_2_pcipm_support_hwtcl.ENABLED" true
			ip_set_param "parameter.core16_multi_lane_upconfigure_support_user_hwtcl.VISIBLE" true
			ip_set_param "parameter.core16_multi_lane_upconfigure_support_user_hwtcl.ENABLED" true
		}
	}
}
proc ::intel_pcie_ss_axi::parameters::validate_core16_dwc_ctrl0_k_pld_crs_en_hwtcl {core16_func_mode_hwtcl core16_virtual_cvp_mode_hwtcl core16_enable_power_mgnt_intf_hwtcl core16_virtual_rp_ep_mode_hwtcl core16_virtual_tlp_bypass_en_hwtcl} {
	#HSD 1508444156
	#Description: core16_dwc_ctrl0_k_pld_crs_en_hwtcl set to true when EP mode only (no UP DN RP)
	if {$core16_func_mode_hwtcl == "Disable" || $core16_virtual_cvp_mode_hwtcl == "cvp_legacy"} {
		ip_set_param "parameter.core16_dwc_ctrl0_k_pld_crs_en_hwtcl.value" 0
	} else {
		ip_set_param "parameter.core16_dwc_ctrl0_k_pld_crs_en_hwtcl.value" 1
	}
}
proc ::intel_pcie_ss_axi::parameters::validate_core16_nparityecc_csbmmioaccess_csbopcode_hwtcl {qhip_mmio_enable_hwtcl core16_func_mode_hwtcl core16_use_ast_parity_hwtcl core8_use_ast_parity_hwtcl core4_0_use_ast_parity_hwtcl core4_1_use_ast_parity_hwtcl} {
	if { $core16_func_mode_hwtcl == "Disable" } {
		ip_set_param "parameter.core16_ecc_ctrl_k_nparity_ecc_attr_hwtcl.value" "true"
		ip_set_param "parameter.core16_csb_mmio_access_ctrl_grant_attr_hwtcl.value" 0
		ip_set_param "parameter.core16_csb_opcode_ctrl_lock_attr_hwtcl.value" false
	} else {
		ip_set_param "parameter.core16_ecc_ctrl_k_nparity_ecc_attr_hwtcl.value" "false"
		ip_set_param "parameter.core16_csb_mmio_access_ctrl_grant_attr_hwtcl.value" 0
		ip_set_param "parameter.core16_csb_opcode_ctrl_lock_attr_hwtcl.value" true
	}
}
proc ::intel_pcie_ss_axi::parameters::validate_core16_ehp_ctrl0_k_ehp_ctrl_hwtcl {core16_func_mode_hwtcl core16_ehp_ctrl0_header_format_hwtcl core16_ehp_ctrl0_address_based_data_packing_hwtcl core16_use_ast_parity_hwtcl qhip_silicon_reva_revb_hwtcl hssi_ctr_pcie_pld_data_width_integer_hwtcl} {
	#HSD 1509835146
	if {!$qhip_silicon_reva_revb_hwtcl} {
		#A0
		if {$core16_func_mode_hwtcl == "Disable" || !$core16_ehp_ctrl0_header_format_hwtcl} {
			ip_set_param "parameter.core16_ehp_ctrl0_k_ehp_ctrl_hwtcl.value" 0
		} else {
			ip_set_param "parameter.core16_ehp_ctrl0_k_ehp_ctrl_hwtcl.value" 1024
		}	
	} else {
		#B0
		set ehp_ctrl0_k_ehp_ctrl 0
		if {$core16_func_mode_hwtcl == "Disable"} {
			set ehp_ctrl0_k_ehp_ctrl 0
		} else {
			if {$core16_ehp_ctrl0_header_format_hwtcl == 1} {
				#ehp_ctrl0 [10] equal 0x400 = 1024
				set ehp_ctrl0_k_ehp_ctrl [expr $ehp_ctrl0_k_ehp_ctrl + 1024]
			}
			if {$core16_ehp_ctrl0_address_based_data_packing_hwtcl == 1} {
				#ehp_ctrl0 [0 13] equal 0x2001 = 8193
				set ehp_ctrl0_k_ehp_ctrl [expr $ehp_ctrl0_k_ehp_ctrl + 8193]
			}
			if {$core16_use_ast_parity_hwtcl == 1} {
				#ehp_ctrl0 [1 4 5 8] equal 0x0132 = 306
				set ehp_ctrl0_k_ehp_ctrl [expr $ehp_ctrl0_k_ehp_ctrl + 306]
			}
			if {$hssi_ctr_pcie_pld_data_width_integer_hwtcl == 1} {
				#Set to one when single width is selected
				#ehp_ctrl0 [9] equal 0x200 = 512
				set ehp_ctrl0_k_ehp_ctrl [expr $ehp_ctrl0_k_ehp_ctrl + 512]
			}
		}
		ip_set_param "parameter.core16_ehp_ctrl0_k_ehp_ctrl_hwtcl.value" $ehp_ctrl0_k_ehp_ctrl
	}
	
}
proc ::intel_pcie_ss_axi::parameters::validate_core16_ehp_ctrl1_k_tx_rd_th_hwtcl { core16_topology_hwtcl hssi_ctr_pcie_pld_data_width_hwtcl core16_ehp_ctrl0_address_based_data_packing_hwtcl qhip_silicon_reva_revb_hwtcl} { 
	#HSD 1508436767 1508435790 14015969556 15010833424
	if {!$qhip_silicon_reva_revb_hwtcl} {
		if { [regexp "Pipe Direct 16-channel" $core16_topology_hwtcl] } { #topology 6
			ip_set_param "parameter.core16_ehp_ctrl1_k_tx_rd_th_hwtcl.value" 0
		} elseif { [regexp "1x16" $core16_topology_hwtcl] } { #topology 1
			if {$hssi_ctr_pcie_pld_data_width_hwtcl == "Double"} { #Double Width
				ip_set_param "parameter.core16_ehp_ctrl1_k_tx_rd_th_hwtcl.value" 25
			} elseif {$hssi_ctr_pcie_pld_data_width_hwtcl == "Single"} { #Single Width
				ip_set_param "parameter.core16_ehp_ctrl1_k_tx_rd_th_hwtcl.value" 29
			}
		} elseif { [regexp "2x8" $core16_topology_hwtcl] } { #topology 2
			if {$hssi_ctr_pcie_pld_data_width_hwtcl == "Double"} { #Double Width
				ip_set_param "parameter.core16_ehp_ctrl1_k_tx_rd_th_hwtcl.value" 29
			} elseif {$hssi_ctr_pcie_pld_data_width_hwtcl == "Single"} { #Single Width
				ip_set_param "parameter.core16_ehp_ctrl1_k_tx_rd_th_hwtcl.value" 31
			}
		} elseif { [regexp "4x4" $core16_topology_hwtcl] } { #topology 4
			if {$hssi_ctr_pcie_pld_data_width_hwtcl == "Double"} { #Double Width
				ip_set_param "parameter.core16_ehp_ctrl1_k_tx_rd_th_hwtcl.value" 31
			} elseif {$hssi_ctr_pcie_pld_data_width_hwtcl == "Single"} { #Single Width
				ip_set_param "parameter.core16_ehp_ctrl1_k_tx_rd_th_hwtcl.value" 32
			}
		} elseif {  [regexp "Pipe Direct 8-channel" $core16_topology_hwtcl] && [regexp "2x4" $core16_topology_hwtcl]  } { #topology 8a - p0 p2
			if {$hssi_ctr_pcie_pld_data_width_hwtcl == "Double"} { #Double Width
				ip_set_param "parameter.core16_ehp_ctrl1_k_tx_rd_th_hwtcl.value" 31
			} elseif {$hssi_ctr_pcie_pld_data_width_hwtcl == "Single"} { #Single Width
				ip_set_param "parameter.core16_ehp_ctrl1_k_tx_rd_th_hwtcl.value" 32
			}
		} elseif {  [regexp "1x8" $core16_topology_hwtcl] && [regexp "2x4" $core16_topology_hwtcl] } { #topology 3 p0/p1/p3
			if {$hssi_ctr_pcie_pld_data_width_hwtcl == "Double"} { #Double Width
				ip_set_param "parameter.core16_ehp_ctrl1_k_tx_rd_th_hwtcl.value" 29
			} elseif {$hssi_ctr_pcie_pld_data_width_hwtcl == "Single"} { #Single Width
				ip_set_param "parameter.core16_ehp_ctrl1_k_tx_rd_th_hwtcl.value" 31
			}
		} elseif { [regexp "Pipe Direct 8-channel" $core16_topology_hwtcl] && [regexp "1x8" $core16_topology_hwtcl] } { #topology 7a p0
			if {$hssi_ctr_pcie_pld_data_width_hwtcl == "Double"} { #Double Width
				ip_set_param "parameter.core16_ehp_ctrl1_k_tx_rd_th_hwtcl.value" 29
			} elseif {$hssi_ctr_pcie_pld_data_width_hwtcl == "Single"} { #Single Width
				ip_set_param "parameter.core16_ehp_ctrl1_k_tx_rd_th_hwtcl.value" 31
			}
		} 
	} else {
		if { [regexp "Pipe Direct 16-channel" $core16_topology_hwtcl] } {
			ip_set_param "parameter.core16_ehp_ctrl1_k_tx_rd_th_hwtcl.value" 0
		} elseif { [regexp "1x16" $core16_topology_hwtcl] } { #topology 1
			if {$hssi_ctr_pcie_pld_data_width_hwtcl == "Double"} { #Double Width
				ip_set_param "parameter.core16_ehp_ctrl1_k_tx_rd_th_hwtcl.value" 25
			} elseif {$hssi_ctr_pcie_pld_data_width_hwtcl == "Single"} { #Single Width
				ip_set_param "parameter.core16_ehp_ctrl1_k_tx_rd_th_hwtcl.value" 29
			}
		} else {
			ip_set_param "parameter.core16_ehp_ctrl1_k_tx_rd_th_hwtcl.value" 33
		}
	}
}
proc ::intel_pcie_ss_axi::parameters::validate_core16_pf0_usp_dsp_rx_tx_preset_hwtcl {core16_func_mode_hwtcl core16_virtual_rp_ep_mode_hwtcl core16_virtual_link_rate_integer_hwtcl qhip_silicon_reva_revb_hwtcl} {
	#HSD: 22011555390,1508489608,22012843280,22012990568
	
	#tx_preset
	if {$core16_func_mode_hwtcl == "Disable"} {
		ip_set_param "parameter.core16_pf0_usp_tx_preset_hwtcl_r.value" 0
		ip_set_param "parameter.core16_pf0_usp_16g_tx_preset_hwtcl_r.value" 0
		ip_set_param "parameter.core16_pf0_usp_32g_tx_preset_hwtcl.value" 0
		ip_set_param "parameter.core16_pf0_dsp_tx_preset_hwtcl.value" 0
		ip_set_param "parameter.core16_pf0_dsp_16g_tx_preset_hwtcl_r.value" 0
		ip_set_param "parameter.core16_pf0_dsp_32g_tx_preset_hwtcl.value" 0	
	} elseif {$core16_virtual_link_rate_integer_hwtcl == 5 } { 
		ip_set_param "parameter.core16_pf0_usp_tx_preset_hwtcl_r.value" 9
		ip_set_param "parameter.core16_pf0_usp_16g_tx_preset_hwtcl_r.value" 3
		ip_set_param "parameter.core16_pf0_usp_32g_tx_preset_hwtcl.value" 9
		if {$core16_virtual_rp_ep_mode_hwtcl == "Native Endpoint"} {
			ip_set_param "parameter.core16_pf0_dsp_tx_preset_hwtcl_r.value" 0
		} else {
			ip_set_param "parameter.core16_pf0_dsp_tx_preset_hwtcl_r.value" 7
		}
		ip_set_param "parameter.core16_pf0_dsp_16g_tx_preset_hwtcl_r.value" 7
		ip_set_param "parameter.core16_pf0_dsp_32g_tx_preset_hwtcl.value" 5
	} elseif {$core16_virtual_link_rate_integer_hwtcl == 4 } { 
		ip_set_param "parameter.core16_pf0_usp_tx_preset_hwtcl_r.value" 9
		ip_set_param "parameter.core16_pf0_usp_16g_tx_preset_hwtcl_r.value" 3
		ip_set_param "parameter.core16_pf0_usp_32g_tx_preset_hwtcl.value" 0
		if {$core16_virtual_rp_ep_mode_hwtcl == "Native Endpoint"} {
			ip_set_param "parameter.core16_pf0_dsp_tx_preset_hwtcl_r.value" 0
		} else {
			ip_set_param "parameter.core16_pf0_dsp_tx_preset_hwtcl_r.value" 7
		}
		ip_set_param "parameter.core16_pf0_dsp_16g_tx_preset_hwtcl_r.value" 7
		ip_set_param "parameter.core16_pf0_dsp_32g_tx_preset_hwtcl.value" 0
	} elseif {$core16_virtual_link_rate_integer_hwtcl == 3 } { 
		ip_set_param "parameter.core16_pf0_usp_tx_preset_hwtcl_r.value" 9
		ip_set_param "parameter.core16_pf0_usp_16g_tx_preset_hwtcl_r.value" 0
		ip_set_param "parameter.core16_pf0_usp_32g_tx_preset_hwtcl.value" 0
		if {$core16_virtual_rp_ep_mode_hwtcl == "Native Endpoint"} {
			ip_set_param "parameter.core16_pf0_dsp_tx_preset_hwtcl_r.value" 0
		} else {
			ip_set_param "parameter.core16_pf0_dsp_tx_preset_hwtcl_r.value" 7
		}
		ip_set_param "parameter.core16_pf0_dsp_16g_tx_preset_hwtcl_r.value" 0
		ip_set_param "parameter.core16_pf0_dsp_32g_tx_preset_hwtcl.value" 0
	} else { 
		ip_set_param "parameter.core16_pf0_usp_tx_preset_hwtcl_r.value" 0
		ip_set_param "parameter.core16_pf0_usp_16g_tx_preset_hwtcl_r.value" 0
		ip_set_param "parameter.core16_pf0_usp_32g_tx_preset_hwtcl.value" 0
		ip_set_param "parameter.core16_pf0_dsp_tx_preset_hwtcl_r.value" 0
		ip_set_param "parameter.core16_pf0_dsp_16g_tx_preset_hwtcl_r.value" 0
		ip_set_param "parameter.core16_pf0_dsp_32g_tx_preset_hwtcl.value" 0
	}

	
	#rx_preset
	if {$core16_func_mode_hwtcl == "Disable" || $core16_virtual_rp_ep_mode_hwtcl == "Native Endpoint"} {
		ip_set_param "parameter.core16_pf0_usp_rx_preset0_hwtcl.value" 0
		ip_set_param "parameter.core16_pf0_usp_rx_preset_hwtcl.value"  7		
	} else {
		ip_set_param "parameter.core16_pf0_usp_rx_preset0_hwtcl.value" 6
		ip_set_param "parameter.core16_pf0_usp_rx_preset_hwtcl.value" 6	
	}		
	if {!$qhip_silicon_reva_revb_hwtcl} {
		#A0
		if {$core16_func_mode_hwtcl == "Disable" || $core16_virtual_rp_ep_mode_hwtcl == "Native Endpoint"} {
			ip_set_param "parameter.core16_pf0_dsp_rx_preset_hwtcl.value"  0
		} else {
			ip_set_param "parameter.core16_pf0_dsp_rx_preset_hwtcl.value"  6
		}
	} else {
		#B0
		if {$core16_func_mode_hwtcl == "Disable" || $core16_virtual_rp_ep_mode_hwtcl == "Native Endpoint"} {
			ip_set_param "parameter.core16_pf0_dsp_rx_preset_hwtcl.value"  0
		} else {
			ip_set_param "parameter.core16_pf0_dsp_rx_preset_hwtcl.value"  7
		}
	}	
}
proc ::intel_pcie_ss_axi::parameters::validate_core16_tlb_err_en_k_cfg_hwtcl {PROP_NAME PROP_VALUE core16_func_mode_hwtcl core16_virtual_tlp_bypass_en_hwtcl} {
	if {$core16_func_mode_hwtcl == "Disable"} {
		ip_set_param "parameter.${PROP_NAME}.value" false
	} elseif {$core16_virtual_tlp_bypass_en_hwtcl == 1} {
		ip_set_param "parameter.${PROP_NAME}.value" true
	}
}
proc ::intel_pcie_ss_axi::parameters::validate_core16_pfvf_sel_vsec_enable_hwtcl {PROP_NAME PROP_VALUE core16_func_mode_hwtcl} {
	if {$core16_func_mode_hwtcl == "Disable"} {
		ip_set_param "parameter.core16_pfvf_sel_vsec_enable_hwtcl.value" false
	} else {
		ip_set_param "parameter.core16_pfvf_sel_vsec_enable_hwtcl.value" true
	}
}
proc ::intel_pcie_ss_axi::parameters::validate_core16_pf0_bar3_reg_bar3_mem_io_hwtcl {PROP_NAME PROP_VALUE core16_func_mode_hwtcl core16_virtual_rp_ep_mode_hwtcl core16_virtual_pf0_io_decode_hwtcl} {
	if {$core16_func_mode_hwtcl == "Disable"} {
		ip_set_param "parameter.core16_pf0_bar3_reg_bar3_mem_io_hwtcl.value" "pf0_bar3_mem"
	} else {
		if {$core16_virtual_rp_ep_mode_hwtcl == "Root Port"} {
			if {$core16_virtual_pf0_io_decode_hwtcl == "io16"} {
					ip_set_param "parameter.core16_pf0_bar3_reg_bar3_mem_io_hwtcl.value" "pf0_bar3_mem"
			} else {
				ip_set_param "parameter.core16_pf0_bar3_reg_bar3_mem_io_hwtcl.value" "pf0_bar3_io"
			}
		} else {
			ip_set_param "parameter.core16_pf0_bar3_reg_bar3_mem_io_hwtcl.value" "pf0_bar3_mem"
		}
	}
}
proc ::intel_pcie_ss_axi::parameters::validate_core16_link_capabilities_reg_pcie_cap_surprise_down_err_rep_cap_hwtcl {PROP_NAME PROP_VALUE core16_virtual_tlp_bypass_en_hwtcl core16_virtual_rp_ep_mode_hwtcl} {
	if {$core16_virtual_tlp_bypass_en_hwtcl == 1 && $core16_virtual_rp_ep_mode_hwtcl == "Root Port"} {
		ip_set_param "parameter.core16_pf0_link_capabilities_reg_pcie_cap_surprise_down_err_rep_cap_hwtcl.value" true
	} else {
		ip_set_param "parameter.core16_pf0_link_capabilities_reg_pcie_cap_surprise_down_err_rep_cap_hwtcl.value" false
	}
}
proc ::intel_pcie_ss_axi::parameters::validate_core16_k_clrhip_not_rst_sticky_hwtcl {qhip_silicon_reva_revb_hwtcl core16_func_mode_hwtcl independent_perst_int_hwtcl} {
	if {!$qhip_silicon_reva_revb_hwtcl} {
	#A0
		ip_set_param "parameter.core16_k_clrhip_not_rst_sticky_hwtcl.value" 0
	} else {
	#B0
		if {$core16_func_mode_hwtcl == "Enable" && $independent_perst_int_hwtcl} {
			ip_set_param "parameter.core16_k_clrhip_not_rst_sticky_hwtcl.value" 1
		} else {
			ip_set_param "parameter.core16_k_clrhip_not_rst_sticky_hwtcl.value" 0
		}
	}
}
proc ::intel_pcie_ss_axi::parameters::validate_core16_multi_lane_upconfigure_support_hwtcl {core16_func_mode_hwtcl core16_multi_lane_upconfigure_support_user_hwtcl} {
	set dlw_enable [get_quartus_ini "dlw_enable" ENABLED]

	if {$core16_func_mode_hwtcl == "Disable"} {
		ip_set_param "parameter.core16_multi_lane_upconfigure_support_hwtcl.value" 1
	} elseif {$core16_multi_lane_upconfigure_support_user_hwtcl==1} {
		ip_set_param "parameter.core16_multi_lane_upconfigure_support_hwtcl.value" 1
	} elseif {$dlw_enable} {
		send_message info "INI detected, enabling Dynamic Link Width."
		ip_set_param "parameter.core16_multi_lane_upconfigure_support_hwtcl.value" 1
	} else {
		ip_set_param "parameter.core16_multi_lane_upconfigure_support_hwtcl.value" 0
	}
}
proc ::intel_pcie_ss_axi::parameters::validate_core16_pf0_gen2_ctrl_off_support_mod_ts_hwtcl {PROP_NAME PROP_VALUE core16_func_mode_hwtcl core16_pf0_gen2_ctrl_off_support_mod_ts_hwtcl} {
	if {$core16_func_mode_hwtcl == "Disable"} {
		ip_set_param "parameter.core16_pf0_gen2_ctrl_off_support_mod_ts_int_hwtcl.value" 0
	} else {
		ip_set_param "parameter.core16_pf0_gen2_ctrl_off_support_mod_ts_int_hwtcl.value" $core16_pf0_gen2_ctrl_off_support_mod_ts_hwtcl
	}
}
proc ::intel_pcie_ss_axi::parameters::validate_core16_pcie_cap_bw_int_en_hwtcl {PROP_NAME PROP_VALUE core16_func_mode_hwtcl core16_virtual_rp_ep_mode_integer_hwtcl} {
	if {$core16_func_mode_hwtcl == "Disable" || $core16_virtual_rp_ep_mode_integer_hwtcl == 0} {
		ip_set_param "parameter.core16_pf0_pcie_cap_auto_bw_int_en_hwtcl.value" 0
		ip_set_param "parameter.core16_pf0_pcie_cap_bw_man_int_en_hwtcl.value" 0
	} else {
		ip_set_param "parameter.core16_pf0_pcie_cap_auto_bw_int_en_hwtcl.value" 1
		ip_set_param "parameter.core16_pf0_pcie_cap_bw_man_int_en_hwtcl.value" 1
	}
}
proc ::intel_pcie_ss_axi::parameters::validate_core16_virtual_pf0_l1sub_cap_enable_hwtcl {core16_func_mode_hwtcl virtual_aspm_control_user_hwtcl core16_l1sub_control1_reg_l1_1_aspm_support_hwtcl core16_l1sub_control1_reg_l1_2_aspm_support_hwtcl core16_l1sub_control1_reg_l1_1_pcipm_support_hwtcl core16_l1sub_control1_reg_l1_2_pcipm_support_hwtcl qhip_silicon_reva_revb_hwtcl qhip_silicon_revc_hwtcl} {
	#HSD15010817673 15010819247
	if {$core16_func_mode_hwtcl == "Enable" && ($core16_l1sub_control1_reg_l1_1_aspm_support_hwtcl || $core16_l1sub_control1_reg_l1_2_aspm_support_hwtcl || $core16_l1sub_control1_reg_l1_1_pcipm_support_hwtcl || $core16_l1sub_control1_reg_l1_2_pcipm_support_hwtcl)  } {
		ip_set_param "parameter.core16_virtual_l1sub_support_hwtcl.value" 1
	} else {
		ip_set_param "parameter.core16_virtual_l1sub_support_hwtcl.value" 0
	}	
	
	if {($core16_l1sub_control1_reg_l1_1_aspm_support_hwtcl || $core16_l1sub_control1_reg_l1_2_aspm_support_hwtcl) && ($virtual_aspm_control_user_hwtcl == "No ASPM Support" || $virtual_aspm_control_user_hwtcl == "L0s Supported")} {
		send_message error "Enable ASPM L1.1 or ASPM L1.2 were supported when Enable ASPM control is L0s and L1 Supported or L1 Supported"
	} 
}
proc ::intel_pcie_ss_axi::parameters::validate_core16_virtual_pf0_ltr_cap_enable_hwtcl {PROP_NAME PROP_VALUE core16_virtual_pf0_ltr_cap_enable_hwtcl core16_func_mode_hwtcl core16_virtual_rp_ep_mode_integer_hwtcl core16_l1sub_control1_reg_l1_2_aspm_support_hwtcl} {
	#HSD: 1509968193
	if {$core16_func_mode_hwtcl == "Disable"} {
		ip_set_param "parameter.core16_virtual_pf0_ltr_cap_enable_int_hwtcl.value" 0
	} elseif {$core16_virtual_pf0_ltr_cap_enable_hwtcl == 1 || ($core16_virtual_rp_ep_mode_integer_hwtcl == 0 && $core16_l1sub_control1_reg_l1_2_aspm_support_hwtcl) } {
		ip_set_param "parameter.core16_virtual_pf0_ltr_cap_enable_int_hwtcl.value" 1	
	} else {
		ip_set_param "parameter.core16_virtual_pf0_ltr_cap_enable_int_hwtcl.value" 0
	}
	
	if {$core16_func_mode_hwtcl == "Enable" && $core16_l1sub_control1_reg_l1_2_aspm_support_hwtcl } {
		send_message info "Enable ASPM L1.2 Substate automatically enable PCIe0 Latency Tolerance Reporting (LTR)."
	}
}
proc ::intel_pcie_ss_axi::parameters::validate_core16_pf0_pcie_cap_hot_plug_surprise_hwtcl {PROP_NAME PROP_VALUE core16_virtual_rp_ep_mode_integer_hwtcl core16_enable_hotplug_hwtcl} {
	if { $core16_virtual_rp_ep_mode_integer_hwtcl == 1 && $core16_enable_hotplug_hwtcl == 1} {
        # RP mode
        ip_set_param "parameter.${PROP_NAME}.value" 1
    } else {
        ip_set_param "parameter.${PROP_NAME}.value" 0
    }
}
proc ::intel_pcie_ss_axi::parameters::validate_core16_virtual_pf0_margin_cap_enable_hwtcl {PROP_NAME PROP_VALUE core16_func_mode_hwtcl core16_virtual_link_rate_hwtcl} {
    if { $core16_func_mode_hwtcl == "Disable" } {
        ip_set_param "parameter.core16_virtual_pf0_margin_cap_enable_hwtcl.value" 0
    } elseif { $core16_virtual_link_rate_hwtcl == "Gen4 (16.0 Gbps)" } {
        ip_set_param "parameter.core16_virtual_pf0_margin_cap_enable_hwtcl.value" 1
    } else {
        ip_set_param "parameter.core16_virtual_pf0_margin_cap_enable_hwtcl.value" 0
    }
}
proc ::intel_pcie_ss_axi::parameters::validate_core16_virtual_pf0_dlink_cap_enable_hwtcl {PROP_NAME PROP_VALUE core16_func_mode_hwtcl} {
    if { ${core16_func_mode_hwtcl} == "Enable" } {
        ip_set_param "parameter.core16_virtual_pf0_dlink_cap_enable_hwtcl.value" 1
    } else {
        ip_set_param "parameter.core16_virtual_pf0_dlink_cap_enable_hwtcl.value" 0
    }
}
proc ::intel_pcie_ss_axi::parameters::validate_core16_pf_device_control_device_status_pcie_cap_ext_tag_en_hwtcl {PROP_NAME PROP_VALUE core16_func_mode_hwtcl} { #ARG: core16_virtual_${pf_num}_enable_hwtcl
	regexp {pf.} $PROP_NAME pf_num
	set virtual_pf_enable_hwtcl         [ip_get "parameter.core16_virtual_${pf_num}_enable_hwtcl.value"]
	
	if {$core16_func_mode_hwtcl == "Disable" || $virtual_pf_enable_hwtcl == 0} {
		ip_set_param "parameter.core16_${pf_num}_device_control_device_status_pcie_cap_ext_tag_en_hwtcl.value" false
	} else {
		ip_set_param "parameter.core16_${pf_num}_device_control_device_status_pcie_cap_ext_tag_en_hwtcl.value" true
	}
}
proc ::intel_pcie_ss_axi::parameters::validate_core16_virtual_dmwr_egress_blk_hwtcl {PROP_NAME PROP_VALUE core16_func_mode_hwtcl core16_virtual_dmwr_egress_blk_hwtcl} {
	#HSD: 1509436374 1509869360 
	#Egress Blocking Hide due to HIP cannot enabled it VISIBLE: "virtual_dmwr_support_hwtcl && core16_virtual_rp_ep_mode_integer_hwtcl && !core16_virtual_tlp_bypass_en_hwtcl"
	regexp {pf.} $PROP_NAME pf_num
	set virtual_pf_enable_hwtcl         [ip_get "parameter.core16_virtual_${pf_num}_enable_hwtcl.value"]
	
	if {$core16_func_mode_hwtcl == "Disable" || $virtual_pf_enable_hwtcl == 0 || $core16_virtual_dmwr_egress_blk_hwtcl == 0} {
		ip_set_param "parameter.core16_${pf_num}_device_control3_reg_dev3_cap_dmwr_egress_blk_hwtcl.value" false
	} else {
		ip_set_param "parameter.core16_${pf_num}_device_control3_reg_dev3_cap_dmwr_egress_blk_hwtcl.value" true
	}
}
proc ::intel_pcie_ss_axi::parameters::validate_core16_sriov_misc_ctrl_k_nonsriov_mode_hwtcl {PROP_NAME PROP_VALUE core16_func_mode_hwtcl core16_virtual_pf0_sriov_enable_hwtcl} {
	if {$core16_func_mode_hwtcl == "Disable"|| $core16_virtual_pf0_sriov_enable_hwtcl == 0} {
		ip_set_param "parameter.core16_sriov_misc_ctrl_k_nonsriov_mode_hwtcl.value" 255
	} else {
		ip_set_param "parameter.core16_sriov_misc_ctrl_k_nonsriov_mode_hwtcl.value" 0
	}
}
proc ::intel_pcie_ss_axi::parameters::validate_core16_pfi_no_soft_rst_hwtcl {core16_func_mode_hwtcl core16_virtual_rp_ep_mode_integer_hwtcl} {
	for {set i 0} { $i < 8 } {incr i} {
		set core16_virtual_pfi_enable_hwtcl [ip_get "parameter.core16_virtual_pf${i}_enable_hwtcl.value"]
		if {$core16_func_mode_hwtcl == "Disable" || $core16_virtual_pfi_enable_hwtcl == 0} {
			ip_set_param "parameter.core16_pf${i}_no_soft_rst_hwtcl.value" "pf${i}_internally_reset"
		} elseif {$core16_virtual_rp_ep_mode_integer_hwtcl == 1} {
			ip_set_param "parameter.core16_pf${i}_no_soft_rst_hwtcl.value" "pf${i}_internally_reset"
		} else {
			ip_set_param "parameter.core16_pf${i}_no_soft_rst_hwtcl.value" "pf${i}_not_internally_reset"
		}
	}
}
proc ::intel_pcie_ss_axi::parameters::validate_core16_pf_ats_capabilities_ctrl_reg_page_aligned_req_hwtcl {PROP_NAME PROP_VALUE core16_func_mode_hwtcl} {
	#HSD: 1508895744
	regexp {pf.} $PROP_NAME pf_num
	set core16_virtual_pf_ats_cap_enable [ip_get "parameter.core16_virtual_${pf_num}_ats_cap_enable_hwtcl.value"]
		
	if {$core16_func_mode_hwtcl == "Enable" && $core16_virtual_pf_ats_cap_enable == 1} {
		ip_set_param "parameter.core16_${pf_num}_ats_capabilities_ctrl_reg_page_aligned_req_hwtcl.value" 1
	} else {
		ip_set_param "parameter.core16_${pf_num}_ats_capabilities_ctrl_reg_page_aligned_req_hwtcl.value" 0
	}
}
proc ::intel_pcie_ss_axi::parameters::validate_core16_pf0_ari_acs_fun_grp_cap_hwtcl_r { PROP_NAME PROP_VALUE qhip_silicon_reva_revb_hwtcl} {
	#HSD 1509328794
    set core16_pf0_acs_cap_acs_p2p_egress_control_hwtcl [ip_get "parameter.core16_pf0_acs_cap_acs_p2p_egress_control_hwtcl.value"]
    set core16_pf1_acs_cap_acs_p2p_egress_control_hwtcl [ip_get "parameter.core16_pf1_acs_cap_acs_p2p_egress_control_hwtcl.value"]
    set core16_pf2_acs_cap_acs_p2p_egress_control_hwtcl [ip_get "parameter.core16_pf2_acs_cap_acs_p2p_egress_control_hwtcl.value"]
    set core16_pf3_acs_cap_acs_p2p_egress_control_hwtcl [ip_get "parameter.core16_pf3_acs_cap_acs_p2p_egress_control_hwtcl.value"]
    set core16_pf4_acs_cap_acs_p2p_egress_control_hwtcl [ip_get "parameter.core16_pf4_acs_cap_acs_p2p_egress_control_hwtcl.value"]
    set core16_pf5_acs_cap_acs_p2p_egress_control_hwtcl [ip_get "parameter.core16_pf5_acs_cap_acs_p2p_egress_control_hwtcl.value"]
    set core16_pf6_acs_cap_acs_p2p_egress_control_hwtcl [ip_get "parameter.core16_pf6_acs_cap_acs_p2p_egress_control_hwtcl.value"]
    set core16_pf7_acs_cap_acs_p2p_egress_control_hwtcl [ip_get "parameter.core16_pf7_acs_cap_acs_p2p_egress_control_hwtcl.value"]

	if { $core16_pf0_acs_cap_acs_p2p_egress_control_hwtcl || $core16_pf1_acs_cap_acs_p2p_egress_control_hwtcl || $core16_pf2_acs_cap_acs_p2p_egress_control_hwtcl|| $core16_pf3_acs_cap_acs_p2p_egress_control_hwtcl || $core16_pf4_acs_cap_acs_p2p_egress_control_hwtcl  || $core16_pf5_acs_cap_acs_p2p_egress_control_hwtcl  || $core16_pf6_acs_cap_acs_p2p_egress_control_hwtcl  || $core16_pf7_acs_cap_acs_p2p_egress_control_hwtcl  } {
		ip_set_param "parameter.${PROP_NAME}.value" true
	} else {
		ip_set_param "parameter.${PROP_NAME}.value" false
	}

}
proc ::intel_pcie_ss_axi::parameters::validate_core16_pf0_eq_redo_hwtcl {PROP_NAME PROP_VALUE core16_func_mode_hwtcl core16_virtual_rp_ep_mode_integer_hwtcl} {
	#HSD 18020315379: WHR/GDR BCM mapping Disable = 1 and Enable = 0, which reverse compare to RNR
	#Expectation -> EP/UP eq_redo=1, where RP/DN eq_redo=0
	if { $core16_func_mode_hwtcl == "Disable"|| $core16_virtual_rp_ep_mode_integer_hwtcl == 1} {
        # RP mode
        ip_set_param "parameter.${PROP_NAME}.value" false
    } else {
        ip_set_param "parameter.${PROP_NAME}.value" true
    }
}
proc ::intel_pcie_ss_axi::parameters::validate_core16_pf0_eq_phase_2_3_user_hwtcl {core16_func_mode_hwtcl core16_virtual_rp_ep_mode_integer_hwtcl core16_pf0_eq_phase_2_3_user_hwtcl} {
	if { $core16_func_mode_hwtcl == "Disable"|| $core16_virtual_rp_ep_mode_integer_hwtcl == 0} {
		# EP mode
		ip_set_param "parameter.core16_pf0_eq_phase_2_3_hwtcl.value"		false
		ip_set_param "parameter.core16_pf0_eq_phase_2_3_atg4_hwtcl.value"	false
		ip_set_param "parameter.core16_pf0_eq_phase_2_3_atg5_hwtcl.value"	false
	} else {
		ip_set_param "parameter.core16_pf0_eq_phase_2_3_hwtcl.value"		$core16_pf0_eq_phase_2_3_user_hwtcl
		ip_set_param "parameter.core16_pf0_eq_phase_2_3_atg4_hwtcl.value"	$core16_pf0_eq_phase_2_3_user_hwtcl
		ip_set_param "parameter.core16_pf0_eq_phase_2_3_atg5_hwtcl.value"	$core16_pf0_eq_phase_2_3_user_hwtcl
	}
}
proc ::intel_pcie_ss_axi::parameters::validate_core16_pfi_eval_interval_time_hwtcl {core16_func_mode_hwtcl core16_total_pf_count_hwtcl} {
	 if { $core16_func_mode_hwtcl == "Enable" } {
        for {set i 0} {$i < [expr {$core16_total_pf_count_hwtcl} ]} {incr i} {
            ip_set_param "parameter.core16_pf${i}_eval_interval_time_hwtcl.value" 3
			
        }
        for {set i 8} {$i >= [expr {$core16_total_pf_count_hwtcl} ]} {incr i -1} {
            ip_set_param "parameter.core16_pf${i}_eval_interval_time_hwtcl.value" 0
        }
    } else {
		for {set i 0} {$i < 8} {incr i} {
            ip_set_param "parameter.core16_pf${i}_eval_interval_time_hwtcl.value" 0
        }
	}
}
proc ::intel_pcie_ss_axi::parameters::validate_core16_virtual_num_of_lanes_hwtcl {core16_func_mode_hwtcl core16_topology_hwtcl} {
	set virtual_num_of_lanes_16 [ip_get "parameter.core16_virtual_num_of_lanes_16_hwtcl.value"] 
    set virtual_num_of_lanes_8  [ip_get "parameter.core16_virtual_num_of_lanes_8_hwtcl.value"]
    set virtual_num_of_lanes_4  [ip_get "parameter.core16_virtual_num_of_lanes_4_hwtcl.value"]
	
    if { $core16_func_mode_hwtcl == "Disable" } {
        ip_set_param "parameter.core16_virtual_num_of_lanes_hwtcl.value" "1"
    } else {
        #TODO: Decode more topology
        if { [regexp "1x16" $core16_topology_hwtcl] } {
            ip_set_param "parameter.core16_virtual_num_of_lanes_16_hwtcl.VISIBLE" true
            ip_set_param "parameter.core16_virtual_num_of_lanes_8_hwtcl.VISIBLE"  false
            ip_set_param "parameter.core16_virtual_num_of_lanes_4_hwtcl.VISIBLE"  false
            ip_set_param "parameter.core16_virtual_num_of_lanes_hwtcl.value" $virtual_num_of_lanes_16
        } elseif { [regexp "2x8" $core16_topology_hwtcl] } {
            ip_set_param "parameter.core16_virtual_num_of_lanes_16_hwtcl.VISIBLE" false
            ip_set_param "parameter.core16_virtual_num_of_lanes_8_hwtcl.VISIBLE"  true
            ip_set_param "parameter.core16_virtual_num_of_lanes_4_hwtcl.VISIBLE"  false
            ip_set_param "parameter.core16_virtual_num_of_lanes_hwtcl.value" $virtual_num_of_lanes_8
        } elseif { [regexp "4x4" $core16_topology_hwtcl] } {
            ip_set_param "parameter.core16_virtual_num_of_lanes_16_hwtcl.VISIBLE" false
            ip_set_param "parameter.core16_virtual_num_of_lanes_8_hwtcl.VISIBLE"  false
            ip_set_param "parameter.core16_virtual_num_of_lanes_4_hwtcl.VISIBLE"  true
            ip_set_param "parameter.core16_virtual_num_of_lanes_hwtcl.value" $virtual_num_of_lanes_4
        } elseif { [regexp "Pipe Direct 8-channel" $core16_topology_hwtcl] && [regexp "2x4" $core16_topology_hwtcl] } {
            ip_set_param "parameter.core16_virtual_num_of_lanes_16_hwtcl.VISIBLE" false
            ip_set_param "parameter.core16_virtual_num_of_lanes_8_hwtcl.VISIBLE"  false
            ip_set_param "parameter.core16_virtual_num_of_lanes_4_hwtcl.VISIBLE"  true
            ip_set_param "parameter.core16_virtual_num_of_lanes_hwtcl.value" $virtual_num_of_lanes_4
        } elseif { [regexp "Pipe Direct 8-channel" $core16_topology_hwtcl] && [regexp "1x8" $core16_topology_hwtcl] } {
            ip_set_param "parameter.core16_virtual_num_of_lanes_16_hwtcl.VISIBLE" false
            ip_set_param "parameter.core16_virtual_num_of_lanes_8_hwtcl.VISIBLE"  true
            ip_set_param "parameter.core16_virtual_num_of_lanes_4_hwtcl.VISIBLE"  false
            ip_set_param "parameter.core16_virtual_num_of_lanes_hwtcl.value" $virtual_num_of_lanes_8
        } elseif { [regexp "1x8" $core16_topology_hwtcl] && [regexp "2x4" $core16_topology_hwtcl] } {
            ip_set_param "parameter.core16_virtual_num_of_lanes_16_hwtcl.VISIBLE" false
            ip_set_param "parameter.core16_virtual_num_of_lanes_8_hwtcl.VISIBLE"  true
            ip_set_param "parameter.core16_virtual_num_of_lanes_4_hwtcl.VISIBLE"  false
            ip_set_param "parameter.core16_virtual_num_of_lanes_hwtcl.value" $virtual_num_of_lanes_8
        } elseif { [regexp "Pipe Direct 16-channel" $core16_topology_hwtcl] } {
			ip_set_param "parameter.core16_virtual_num_of_lanes_16_hwtcl.VISIBLE" false
            ip_set_param "parameter.core16_virtual_num_of_lanes_8_hwtcl.VISIBLE"  false
            ip_set_param "parameter.core16_virtual_num_of_lanes_4_hwtcl.VISIBLE"  false
			ip_set_param "parameter.core16_virtual_num_of_lanes_hwtcl.value"	"1"
		}
    }
}
proc ::intel_pcie_ss_axi::parameters::validate_core16_virtio_cii_ctrl_k_cii_en_hwtcl {core16_func_mode_hwtcl core16_virtual_cvp_mode_hwtcl core16_dwc_ctrl0_k_pld_crs_en_hwtcl core16_virtio_cii_ctrl_k_cfg_update_en_attr_hwtcl core16_virtual_rp_ep_mode_integer_hwtcl qhip_silicon_reva_revb_hwtcl} {
	#HSD: 1508927048 
	set core16_pf0_enable_virtio_hwtcl [ip_get "parameter.core16_pf0_virtio_capability_present_hwtcl.value"]
	set core16_pf1_enable_virtio_hwtcl [ip_get "parameter.core16_pf1_virtio_capability_present_hwtcl.value"]
	set core16_pf2_enable_virtio_hwtcl [ip_get "parameter.core16_pf2_virtio_capability_present_hwtcl.value"]
	set core16_pf3_enable_virtio_hwtcl [ip_get "parameter.core16_pf3_virtio_capability_present_hwtcl.value"]
	set core16_pf4_enable_virtio_hwtcl [ip_get "parameter.core16_pf4_virtio_capability_present_hwtcl.value"]
	set core16_pf5_enable_virtio_hwtcl [ip_get "parameter.core16_pf5_virtio_capability_present_hwtcl.value"]
	set core16_pf6_enable_virtio_hwtcl [ip_get "parameter.core16_pf6_virtio_capability_present_hwtcl.value"]
	set core16_pf7_enable_virtio_hwtcl [ip_get "parameter.core16_pf7_virtio_capability_present_hwtcl.value"]
	
	set core16_vf0_enable_virtio_hwtcl [ip_get "parameter.core16_pf0vf_virtio_capability_present_hwtcl.value"]
	set core16_vf1_enable_virtio_hwtcl [ip_get "parameter.core16_pf1vf_virtio_capability_present_hwtcl.value"]
	set core16_vf2_enable_virtio_hwtcl [ip_get "parameter.core16_pf2vf_virtio_capability_present_hwtcl.value"]
	set core16_vf3_enable_virtio_hwtcl [ip_get "parameter.core16_pf3vf_virtio_capability_present_hwtcl.value"]
	set core16_vf4_enable_virtio_hwtcl [ip_get "parameter.core16_pf4vf_virtio_capability_present_hwtcl.value"]
	set core16_vf5_enable_virtio_hwtcl [ip_get "parameter.core16_pf5vf_virtio_capability_present_hwtcl.value"]
	set core16_vf6_enable_virtio_hwtcl [ip_get "parameter.core16_pf6vf_virtio_capability_present_hwtcl.value"]
	set core16_vf7_enable_virtio_hwtcl [ip_get "parameter.core16_pf7vf_virtio_capability_present_hwtcl.value"]

	#cfg_update
	if {$core16_func_mode_hwtcl == "Disable" || $core16_virtual_cvp_mode_hwtcl == "cvp_legacy" || $core16_dwc_ctrl0_k_pld_crs_en_hwtcl == 0} {
		ip_set_param "parameter.core16_virtio_cii_ctrl_k_cfg_update_en_attr_hwtcl.value" 0
	} elseif {!$core16_virtual_rp_ep_mode_integer_hwtcl} { #EP
		ip_set_param "parameter.core16_virtio_cii_ctrl_k_cfg_update_en_attr_hwtcl.value" 1
	} else {
		ip_set_param "parameter.core16_virtio_cii_ctrl_k_cfg_update_en_attr_hwtcl.value" 0
	}

	#VIRTIO PF 
	if {$core16_func_mode_hwtcl == "Disable" || $core16_virtual_cvp_mode_hwtcl == "cvp_legacy"  || $core16_dwc_ctrl0_k_pld_crs_en_hwtcl == 0} {
		ip_set_param "parameter.core16_virtio_cii_ctrl_k_cii_en_hwtcl.value" 0
	} elseif {$core16_virtio_cii_ctrl_k_cfg_update_en_attr_hwtcl == 1} {
		ip_set_param "parameter.core16_virtio_cii_ctrl_k_cii_en_hwtcl.value" 1
	} elseif {$core16_pf0_enable_virtio_hwtcl == 1} {
		ip_set_param "parameter.core16_virtio_cii_ctrl_k_cii_en_hwtcl.value" 1
	} elseif {$core16_pf1_enable_virtio_hwtcl == 1} {
		ip_set_param "parameter.core16_virtio_cii_ctrl_k_cii_en_hwtcl.value" 1
	} elseif {$core16_pf2_enable_virtio_hwtcl == 1} {
		ip_set_param "parameter.core16_virtio_cii_ctrl_k_cii_en_hwtcl.value" 1
	} elseif {$core16_pf3_enable_virtio_hwtcl == 1} {
		ip_set_param "parameter.core16_virtio_cii_ctrl_k_cii_en_hwtcl.value" 1
	} elseif {$core16_pf4_enable_virtio_hwtcl == 1} {
		ip_set_param "parameter.core16_virtio_cii_ctrl_k_cii_en_hwtcl.value" 1
	} elseif {$core16_pf5_enable_virtio_hwtcl == 1} {
		ip_set_param "parameter.core16_virtio_cii_ctrl_k_cii_en_hwtcl.value" 1
	} elseif {$core16_pf6_enable_virtio_hwtcl == 1} {
		ip_set_param "parameter.core16_virtio_cii_ctrl_k_cii_en_hwtcl.value" 1
	} elseif {$core16_pf7_enable_virtio_hwtcl == 1} {
		ip_set_param "parameter.core16_virtio_cii_ctrl_k_cii_en_hwtcl.value" 1
	} 
	
	#VIRTIO Enable #1508927048 1508932599 1509397718
	if {!$qhip_silicon_reva_revb_hwtcl} {
		#A0
		if {$core16_pf0_enable_virtio_hwtcl == 1 || $core16_pf1_enable_virtio_hwtcl == 1 || $core16_pf2_enable_virtio_hwtcl == 1 || $core16_pf3_enable_virtio_hwtcl == 1 || $core16_pf4_enable_virtio_hwtcl == 1 || $core16_pf5_enable_virtio_hwtcl == 1 || $core16_pf6_enable_virtio_hwtcl == 1 || $core16_pf7_enable_virtio_hwtcl == 1 || $core16_vf0_enable_virtio_hwtcl == 1 || $core16_vf1_enable_virtio_hwtcl == 1 || $core16_vf2_enable_virtio_hwtcl == 1 || $core16_vf3_enable_virtio_hwtcl == 1 || $core16_vf4_enable_virtio_hwtcl == 1 || $core16_vf5_enable_virtio_hwtcl == 1 || $core16_vf6_enable_virtio_hwtcl == 1 || $core16_vf7_enable_virtio_hwtcl == 1} {
			ip_set_param "parameter.core16_cii_range_1_k_cii_pf_en1_attr_hwtcl.value" 255
			ip_set_param "parameter.core16_cii_range_1_k_cii_start_addr1_attr_hwtcl.value" 80
			ip_set_param "parameter.core16_cii_range_1_k_cii_addr_size1_attr_hwtcl.value" 30
			
			ip_set_param "parameter.core16_cii_range_2_k_cii_pf_en2_attr_hwtcl.value" 255
			ip_set_param "parameter.core16_cii_range_2_k_cii_start_addr2_attr_hwtcl.value" 192
			ip_set_param "parameter.core16_cii_range_2_k_cii_addr_size2_attr_hwtcl.value" 55
			
			ip_set_param "parameter.core16_cii_range_virtio_en_hwtcl.value" false
			send_message info "Enable PCIe 0 VIRTIO will occupied CII Range 1 and CII Range 2."
		} else {
			ip_set_param "parameter.core16_cii_range_virtio_en_hwtcl.value" true
		}	
	} else {
		#B0
		if {$core16_pf0_enable_virtio_hwtcl == 1 || $core16_pf1_enable_virtio_hwtcl == 1 || $core16_pf2_enable_virtio_hwtcl == 1 || $core16_pf3_enable_virtio_hwtcl == 1 || $core16_pf4_enable_virtio_hwtcl == 1 || $core16_pf5_enable_virtio_hwtcl == 1 || $core16_pf6_enable_virtio_hwtcl == 1 || $core16_pf7_enable_virtio_hwtcl == 1 || $core16_vf0_enable_virtio_hwtcl == 1 || $core16_vf1_enable_virtio_hwtcl == 1 || $core16_vf2_enable_virtio_hwtcl == 1 || $core16_vf3_enable_virtio_hwtcl == 1 || $core16_vf4_enable_virtio_hwtcl == 1 || $core16_vf5_enable_virtio_hwtcl == 1 || $core16_vf6_enable_virtio_hwtcl == 1 || $core16_vf7_enable_virtio_hwtcl == 1} {
			ip_set_param "parameter.core16_cii_range_5_k_cii_pf_en5_attr_hwtcl.value" 255
			ip_set_param "parameter.core16_cii_range_5_k_cii_start_addr5_attr_hwtcl.value" 80
			ip_set_param "parameter.core16_cii_range_5_k_cii_addr_size5_attr_hwtcl.value" 30
			
			ip_set_param "parameter.core16_cii_range_6_k_cii_pf_en6_attr_hwtcl.value" 255
			ip_set_param "parameter.core16_cii_range_6_k_cii_start_addr6_attr_hwtcl.value" 192
			ip_set_param "parameter.core16_cii_range_6_k_cii_addr_size6_attr_hwtcl.value" 55
			
			
					
			ip_set_param "parameter.core16_cii_range_virtio_en_hwtcl.value" false
			send_message info "Enable PCIe 0 VIRTIO will occupied CII Range 5 and CII Range 6."
		} else {
			ip_set_param "parameter.core16_cii_range_virtio_en_hwtcl.value" true
		}		
	}
}
proc ::intel_pcie_ss_axi::parameters::validate_core16_cii_range_k_cii_pf_en_attr_hwtcl {PROP_NAME PROP_VALUE core16_func_mode_hwtcl core16_virtual_rp_ep_mode_integer_hwtcl core16_virtio_cii_ctrl_k_cfg_update_en_attr_hwtcl core16_cii_range_virtio_en_hwtcl qhip_silicon_reva_revb_hwtcl} {
	#HSD 1507868838 1508289318 16010875166 14013108890
	regexp {range_.} $PROP_NAME range_num
	regexp {en.} $PROP_NAME en_num
	set core16_cii_pf_en [ip_get "parameter.core16_cii_${range_num}_k_cii_pf_${en_num}_attr_user_hwtcl.value"]
	if {!$qhip_silicon_reva_revb_hwtcl} {
		#A0
		if { $core16_func_mode_hwtcl == "Disable" || $core16_virtual_rp_ep_mode_integer_hwtcl == 1 } {
			ip_set_param "parameter.core16_cii_${range_num}_k_cii_pf_${en_num}_attr_hwtcl.value" 0
		} elseif { ${en_num} == "en3" } { #1509585156 ARI Next Func
			ip_set_param "parameter.core16_cii_range_3_k_cii_pf_en3_attr_hwtcl.value" 255 
		} elseif { ${core16_virtio_cii_ctrl_k_cfg_update_en_attr_hwtcl} == 1 && ${en_num} == "en4" } {
			ip_set_param "parameter.core16_cii_range_4_k_cii_pf_en4_attr_hwtcl.value" 255
		} elseif { ${core16_virtio_cii_ctrl_k_cfg_update_en_attr_hwtcl} == 1 && ${en_num} == "en5" } {
			ip_set_param "parameter.core16_cii_range_5_k_cii_pf_en5_attr_hwtcl.value" 255
		} elseif { ${core16_virtio_cii_ctrl_k_cfg_update_en_attr_hwtcl} == 1 && ${en_num} == "en6" } {
			ip_set_param "parameter.core16_cii_range_6_k_cii_pf_en6_attr_hwtcl.value" 255
		} elseif { ${core16_virtio_cii_ctrl_k_cfg_update_en_attr_hwtcl} == 1 && ${en_num} == "en7" } {
			ip_set_param "parameter.core16_cii_range_7_k_cii_pf_en7_attr_hwtcl.value" 255
		} elseif { $core16_cii_range_virtio_en_hwtcl == "false" && ($en_num == "en1" || $en_num == "en2" || $en_num == "en3") } {
			#When VIRTIO is enable, CII Range 1,2 will be set in ::intel_pcie_ss_axi::parameters::validate_core16_virtio_cii_ctrl_k_cii_en_hwtcl
		} elseif { ${core16_cii_pf_en} == 1 } {
			ip_set_param "parameter.core16_virtio_cii_ctrl_k_cii_en_hwtcl.value" 1
			ip_set_param "parameter.core16_cii_${range_num}_k_cii_pf_${en_num}_attr_hwtcl.value" 255
		} else {
			ip_set_param "parameter.core16_cii_${range_num}_k_cii_pf_${en_num}_attr_hwtcl.value" 0
		}
	} else {
		#B0
		if { $core16_func_mode_hwtcl == "Disable" || $core16_virtual_rp_ep_mode_integer_hwtcl == 1 } {
			ip_set_param "parameter.core16_cii_${range_num}_k_cii_pf_${en_num}_attr_hwtcl.value" 0
		} elseif { $en_num == "en7" } { #1509585156 ARI Next Func
			ip_set_param "parameter.core16_cii_range_7_k_cii_pf_en7_attr_hwtcl.value" 255
		} elseif { $core16_cii_range_virtio_en_hwtcl == "false" && ($en_num == "en5" || $en_num == "en6") } {
			#When VIRTIO is enable, CII Range 5,6 will be set in ::intel_pcie_ss_axi::parameters::validate_core16_virtio_cii_ctrl_k_cii_en_hwtcl
		} elseif { ${core16_cii_pf_en} == 1 } {
			ip_set_param "parameter.core16_virtio_cii_ctrl_k_cii_en_hwtcl.value" 1
			ip_set_param "parameter.core16_cii_${range_num}_k_cii_pf_${en_num}_attr_hwtcl.value" 255
		} else {
			ip_set_param "parameter.core16_cii_${range_num}_k_cii_pf_${en_num}_attr_hwtcl.value" 0
		}
	}
}
proc ::intel_pcie_ss_axi::parameters::validate_core16_cii_range_k_cii_start_addr_attr_hwtcl {PROP_NAME PROP_VALUE core16_func_mode_hwtcl core16_virtual_rp_ep_mode_integer_hwtcl core16_virtio_cii_ctrl_k_cfg_update_en_attr_hwtcl core16_cii_range_virtio_en_hwtcl qhip_silicon_reva_revb_hwtcl} {
	regexp {range_.} $PROP_NAME range_num
	regexp {addr.} $PROP_NAME addr_num
	
	set core16_cii_start_addr4_user [ip_get "parameter.core16_cii_range_4_k_cii_start_addr4_attr_user_hwtcl.value"]
	set core16_cii_start_addr5_user [ip_get "parameter.core16_cii_range_5_k_cii_start_addr5_attr_user_hwtcl.value"]
	set core16_cii_start_addr6_user [ip_get "parameter.core16_cii_range_6_k_cii_start_addr6_attr_user_hwtcl.value"]
	set core16_cii_start_addr7_user [ip_get "parameter.core16_cii_range_7_k_cii_start_addr7_attr_user_hwtcl.value"]
	set core16_cii_start_addr_user [ip_get "parameter.core16_cii_${range_num}_k_cii_start_${addr_num}_attr_user_hwtcl.value"]
	if {!$qhip_silicon_reva_revb_hwtcl} {
		#A0
		if { $core16_func_mode_hwtcl == "Disable" || $core16_virtual_rp_ep_mode_integer_hwtcl == 1 } {
			ip_set_param "parameter.core16_cii_${range_num}_k_cii_start_${addr_num}_attr_hwtcl.value" 0
		} elseif { $addr_num == "addr3" } { #1509585156 ARI Next Func
			ip_set_param "parameter.core16_cii_range_3_k_cii_start_addr3_attr_hwtcl.value" 376
		} elseif { ${core16_virtio_cii_ctrl_k_cfg_update_en_attr_hwtcl} == 1 && $addr_num == "addr4" } { #14013108890
			ip_set_param "parameter.core16_cii_range_4_k_cii_start_addr4_attr_hwtcl.value" 416
		} elseif { ${core16_virtio_cii_ctrl_k_cfg_update_en_attr_hwtcl} == 1 && $addr_num == "addr5" } { #16010875166
			ip_set_param "parameter.core16_cii_range_5_k_cii_start_addr5_attr_hwtcl.value" 176
		} elseif { ${core16_virtio_cii_ctrl_k_cfg_update_en_attr_hwtcl} == 1 && $addr_num == "addr6" } {
			ip_set_param "parameter.core16_cii_range_6_k_cii_start_addr6_attr_hwtcl.value" 636
		} elseif { ${core16_virtio_cii_ctrl_k_cfg_update_en_attr_hwtcl} == 1 && $addr_num == "addr7" } {
			ip_set_param "parameter.core16_cii_range_7_k_cii_start_addr7_attr_hwtcl.value" 128
		} elseif { $addr_num == "addr4" } {
			ip_set_param "parameter.core16_cii_range_4_k_cii_start_addr4_attr_hwtcl.value" $core16_cii_start_addr4_user
		} elseif { $addr_num == "addr5" } {
			ip_set_param "parameter.core16_cii_range_5_k_cii_start_addr5_attr_hwtcl.value" $core16_cii_start_addr5_user
		} elseif { $addr_num == "addr6" } {
			ip_set_param "parameter.core16_cii_range_6_k_cii_start_addr6_attr_hwtcl.value" $core16_cii_start_addr6_user
		} elseif { $addr_num == "addr7" } {
			ip_set_param "parameter.core16_cii_range_7_k_cii_start_addr7_attr_hwtcl.value" $core16_cii_start_addr7_user	
		} elseif { $core16_cii_range_virtio_en_hwtcl == "false" && ($addr_num == "addr1" || $addr_num == "addr2" || $addr_num == "addr3") } {
			#When VIRTIO is enable, CII Range 1,2 will be set in ::intel_pcie_ss_axi::parameters::validate_core16_virtio_cii_ctrl_k_cii_en_hwtcl
		} else {
			ip_set_param "parameter.core16_cii_${range_num}_k_cii_start_${addr_num}_attr_hwtcl.value" $core16_cii_start_addr_user
		} 
	} else {
		#B0
		if { $core16_func_mode_hwtcl == "Disable" || $core16_virtual_rp_ep_mode_integer_hwtcl == 1 } {
			ip_set_param "parameter.core16_cii_${range_num}_k_cii_start_${addr_num}_attr_hwtcl.value" 0
		} elseif { $addr_num == "addr7" } { #1509585156 ARI Next Func
			ip_set_param "parameter.core16_cii_range_7_k_cii_start_addr7_attr_hwtcl.value" 376
		} elseif { $core16_cii_range_virtio_en_hwtcl == "false" && ($addr_num == "addr5" || $addr_num == "addr6") } {
			#When VIRTIO is enable, CII Range 5,6 will be set in ::intel_pcie_ss_axi::parameters::validate_core16_virtio_cii_ctrl_k_cii_en_hwtcl
		} else {
			ip_set_param "parameter.core16_cii_${range_num}_k_cii_start_${addr_num}_attr_hwtcl.value" $core16_cii_start_addr_user
		}
	}
}
proc ::intel_pcie_ss_axi::parameters::validate_core16_cii_range_k_cii_addr_size_attr_hwtcl {PROP_NAME PROP_VALUE core16_func_mode_hwtcl core16_virtual_rp_ep_mode_integer_hwtcl core16_virtio_cii_ctrl_k_cfg_update_en_attr_hwtcl core16_cii_range_virtio_en_hwtcl qhip_silicon_reva_revb_hwtcl} {
	#HSD: 1508598149
	regexp {range_.} $PROP_NAME range_num
	regexp {size.} $PROP_NAME size_num
	regexp {._attr} $PROP_NAME addr_num
	
	set core16_cii_addr_size4_user [ip_get "parameter.core16_cii_range_4_k_cii_addr_size4_attr_user_hwtcl.value"]
	set core16_cii_addr_size5_user [ip_get "parameter.core16_cii_range_5_k_cii_addr_size5_attr_user_hwtcl.value"]
	set core16_cii_addr_size6_user [ip_get "parameter.core16_cii_range_6_k_cii_addr_size6_attr_user_hwtcl.value"]
	set core16_cii_addr_size7_user [ip_get "parameter.core16_cii_range_7_k_cii_addr_size7_attr_user_hwtcl.value"]
	set core16_cii_start_addr_user [ip_get "parameter.core16_cii_${range_num}_k_cii_start_addr${addr_num}_user_hwtcl.value"]
	set core16_cii_addr_size_user [ip_get "parameter.core16_cii_${range_num}_k_cii_addr_${size_num}_attr_user_hwtcl.value"]
	if {!$qhip_silicon_reva_revb_hwtcl} {
		#A0
		if { $core16_func_mode_hwtcl == "Disable" || $core16_virtual_rp_ep_mode_integer_hwtcl == 1 } {
			ip_set_param "parameter.core16_cii_${range_num}_k_cii_addr_${size_num}_attr_hwtcl.value" 0
		} elseif { $size_num == "size3" } {#1509585156 ARI Next Func
			ip_set_param "parameter.core16_cii_range_3_k_cii_addr_size3_attr_hwtcl.value" 15
		} elseif { ${core16_virtio_cii_ctrl_k_cfg_update_en_attr_hwtcl} == 1 && $size_num == "size4" } {
			ip_set_param "parameter.core16_cii_range_4_k_cii_addr_size4_attr_hwtcl.value" 3
		} elseif { ${core16_virtio_cii_ctrl_k_cfg_update_en_attr_hwtcl} == 1 && $size_num == "size5" } {
			ip_set_param "parameter.core16_cii_range_5_k_cii_addr_size5_attr_hwtcl.value" 3
		} elseif { ${core16_virtio_cii_ctrl_k_cfg_update_en_attr_hwtcl} == 1 && $size_num == "size6" } {
			ip_set_param "parameter.core16_cii_range_6_k_cii_addr_size6_attr_hwtcl.value" 3
		} elseif { ${core16_virtio_cii_ctrl_k_cfg_update_en_attr_hwtcl} == 1 && $size_num == "size7" } {
			ip_set_param "parameter.core16_cii_range_7_k_cii_addr_size7_attr_hwtcl.value" 3
		} elseif { $size_num == "size4" } {
			ip_set_param "parameter.core16_cii_range_4_k_cii_addr_size4_attr_hwtcl.value" $core16_cii_addr_size4_user
		} elseif { $size_num == "size5" } {
			ip_set_param "parameter.core16_cii_range_5_k_cii_addr_size5_attr_hwtcl.value" $core16_cii_addr_size5_user
		} elseif { $size_num == "size6" } {
			ip_set_param "parameter.core16_cii_range_6_k_cii_addr_size6_attr_hwtcl.value" $core16_cii_addr_size6_user
		} elseif { $size_num == "size7" } {
			ip_set_param "parameter.core16_cii_range_7_k_cii_addr_size7_attr_hwtcl.value" $core16_cii_addr_size7_user	
		} elseif { $core16_cii_range_virtio_en_hwtcl == "false" && ($size_num == "size1" || $size_num == "size2" || $size_num == "size3") } {
			#When VIRTIO is enable, CII Range 1,2 will be set in ::intel_pcie_ss_axi::parameters::validate_core16_virtio_cii_ctrl_k_cii_en_hwtcl
		} else {
			set core16_cii_allowed_addr_size [expr int(4095 - $core16_cii_start_addr_user) ]
			if { $core16_cii_addr_size_user > $core16_cii_allowed_addr_size} {
				send_message error "The total of start address and address size must not be greater than 0xFFF!"
			} else {
				ip_set_param "parameter.core16_cii_${range_num}_k_cii_addr_${size_num}_attr_hwtcl.value" $core16_cii_addr_size_user
			}
		}
	} else {
		#B0
		if { $core16_func_mode_hwtcl == "Disable" || $core16_virtual_rp_ep_mode_integer_hwtcl == 1 } {
			ip_set_param "parameter.core16_cii_${range_num}_k_cii_addr_${size_num}_attr_hwtcl.value" 0
		} elseif { $size_num == "size7" } {#1509585156 ARI Next Func
			ip_set_param "parameter.core16_cii_range_7_k_cii_addr_size7_attr_hwtcl.value" 15
		} elseif { $core16_cii_range_virtio_en_hwtcl == "false" && ($size_num == "size5" || $size_num == "size6") } {
			#When VIRTIO is enable, CII Range 5,6 will be set in ::intel_pcie_ss_axi::parameters::validate_core16_virtio_cii_ctrl_k_cii_en_hwtcl
		} else {
			set core16_cii_allowed_addr_size [expr int(4095 - $core16_cii_start_addr_user) ]
			if { $core16_cii_addr_size_user > $core16_cii_allowed_addr_size} {
				send_message error "The total of start address and address size must not be greater than 0xFFF!"
			} else {
				ip_set_param "parameter.core16_cii_${range_num}_k_cii_addr_${size_num}_attr_hwtcl.value" $core16_cii_addr_size_user
			}
		}
	}
}


#----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
#Ptile SS only Param Validation Callback
proc ::intel_pcie_ss_axi::parameters::validate_core16_pld_crs_en_hwtcl { PROP_NAME PROP_VALUE is_cvp_enable_hwtcl core16_func_mode_hwtcl core16_virtual_rp_ep_mode_integer_hwtcl core16_virtual_tlp_bypass_en_hwtcl core16_enable_power_mgnt_intf_hwtcl } {
##    if {$core16_func_mode_hwtcl == "Enable"} {
##        if {$core16_virtual_rp_ep_mode_integer_hwtcl == 0 && $core16_virtual_tlp_bypass_en_hwtcl == 0 && $core16_enable_power_mgnt_intf_hwtcl == 1 && $is_cvp_enable_hwtcl == 0 } {
##            ip_set_param "parameter.core16_pld_crs_en_hwtcl.value" 1
##        } else {
##            ip_set_param "parameter.core16_pld_crs_en_hwtcl.value" 0
##        }
##    } else {
##        ip_set_param "parameter.core16_pld_crs_en_hwtcl.value" 0
##    }
}

proc ::intel_pcie_ss_axi::parameters::validate_core16_dbi_ro_wr_disable_hwtcl { PROP_NAME PROP_VALUE core16_virtual_dbi_ro_wr_disable_hwtcl core16_func_mode_hwtcl } {
    set tile [ip_get "parameter.TILE.value"]
    if {$tile == "R-TILE"} {
        if { $core16_func_mode_hwtcl == "Disable" } {
            ip_set_param "parameter.${PROP_NAME}.value" 1
        } else {
            if { $core16_virtual_dbi_ro_wr_disable_hwtcl == 0 } {
                #set to 1 means not writable
                ip_set_param "parameter.${PROP_NAME}.value" 1
            } else {
                ip_set_param "parameter.${PROP_NAME}.value" 0
            }
        }
    } elseif {$tile == "P-TILE"} {
        #P-Tile needs to set to 0 due to BCMRBC rulings
        if { $core16_func_mode_hwtcl == "Disable" } {
            ip_set_param "parameter.${PROP_NAME}.value" 0
            set_qhip_param "hssi_ctp_u_wrpcie_top_u_core16_dbi_ro_wr_disable" false
        } else {
            if { $core16_virtual_dbi_ro_wr_disable_hwtcl == 0 } {
                #set to 1 means not writable
                ip_set_param "parameter.${PROP_NAME}.value" 1
                set_qhip_param "hssi_ctp_u_wrpcie_top_u_core16_dbi_ro_wr_disable" true
            } else {
                ip_set_param "parameter.${PROP_NAME}.value" 0
                set_qhip_param "hssi_ctp_u_wrpcie_top_u_core16_dbi_ro_wr_disable" false
            }
        }
    } else {
        #F-Tile dbi_ro_wr_disable handling is done in hip_top terp file, passing parameter directly straight through
        if { $core16_virtual_dbi_ro_wr_disable_hwtcl == 0 } {
            #set to 1 means not writable
            ip_set_param "parameter.${PROP_NAME}.value" 0
        } else {
            ip_set_param "parameter.${PROP_NAME}.value" 1
        }
    }
}

proc ::intel_pcie_ss_axi::parameters::validate_core16_sn_ser_num_reg_i_dw_hwtcl {PROP_NAME PROP_VALUE core16_func_mode_hwtcl core16_sn_ser_num_reg_1_dw_hwtcl core16_sn_ser_num_reg_2_dw_hwtcl} {
#vww15 both ftile and ptile ss has this param, bt only ptile ss has this callback
    set tile [ip_get "parameter.TILE.value"]
    if {$tile == "P-TILE" ||$tile == "R-TILE"} {
        for {set i 0} { $i < 8 } {incr i} {
        set core16_virtual_pfi_enable_hwtcl [ip_get "parameter.core16_virtual_pf${i}_enable_hwtcl.value"]
            if {$core16_func_mode_hwtcl == "Disable" || $core16_virtual_pfi_enable_hwtcl == 0} {
                ip_set_param "parameter.core16_pf${i}_sn_ser_num_reg_1_dw_hwtcl.value" 0
                ip_set_param "parameter.core16_pf${i}_sn_ser_num_reg_2_dw_hwtcl.value" 0
            } else {
                ip_set_param "parameter.core16_pf${i}_sn_ser_num_reg_1_dw_hwtcl.value" $core16_sn_ser_num_reg_1_dw_hwtcl
                ip_set_param "parameter.core16_pf${i}_sn_ser_num_reg_2_dw_hwtcl.value" $core16_sn_ser_num_reg_2_dw_hwtcl
            }
        }
    }
}

proc ::intel_pcie_ss_axi::parameters::validate_core16_pfi_pcie_cap_ep_l0s_accpt_latency_hwtcl { PROP_NAME PROP_VALUE core16_user_pcie_cap_ep_l0s_accpt_latency_hwtcl } {
    set tile [ip_get "parameter.TILE.value"]
    if {$tile == "P-TILE"} {
        regexp {pf.} $PROP_NAME pf_num
        set core16_virtual_pfi_enable_hwtcl [ip_get "parameter.core16_virtual_${pf_num}_enable_hwtcl.value"]
        if { ${core16_virtual_pfi_enable_hwtcl} == 1 } {
            ip_set_param "parameter.${PROP_NAME}.value" $core16_user_pcie_cap_ep_l0s_accpt_latency_hwtcl
        } else {
            ip_set_param "parameter.${PROP_NAME}.value" 0
        }
    }
     #param not in Ftile SS
}

proc ::intel_pcie_ss_axi::parameters::validate_core16_pfi_pcie_cap_ep_l1_accpt_latency_hwtcl { PROP_NAME PROP_VALUE core16_user_pcie_cap_ep_l1_accpt_latency_hwtcl } {
    set tile [ip_get "parameter.TILE.value"]
    if {$tile == "P-TILE"} {
        regexp {pf.} $PROP_NAME pf_num
        set core16_virtual_pfi_enable_hwtcl [ip_get "parameter.core16_virtual_${pf_num}_enable_hwtcl.value"]
        if { ${core16_virtual_pfi_enable_hwtcl} == 1 } {
            ip_set_param "parameter.${PROP_NAME}.value" $core16_user_pcie_cap_ep_l1_accpt_latency_hwtcl
        } else {
            ip_set_param "parameter.${PROP_NAME}.value" 0
        }
    }

}

proc ::intel_pcie_ss_axi::parameters::validate_core16_pf_ceb_pointer_addr_user_hwtcl {PROP_NAME PROP_VALUE} {
    set tile [ip_get "parameter.TILE.value"]
    if {$tile == "P-TILE"} {
        set core16_ceb_enable [ip_get "parameter.core16_ceb_enable_hwtcl.value"]

        if { $core16_ceb_enable == 0 } {
            ip_set_param "parameter.core16_pf_ceb_pointer_addr_hwtcl.value" 0
        } else {
            ip_set_param "parameter.core16_pf_ceb_pointer_addr_hwtcl.value" $PROP_VALUE
        }
    }
}

proc ::intel_pcie_ss_axi::parameters::validate_core16_vf_ceb_pointer_addr_user_hwtcl {PROP_NAME PROP_VALUE} {
    set tile [ip_get "parameter.TILE.value"]
    if {$tile == "P-TILE"} {
        set core16_ceb_enable [ip_get "parameter.core16_ceb_enable_hwtcl.value"]

        if { $core16_ceb_enable == 0 } {
            ip_set_param "parameter.core16_vf_ceb_pointer_addr_hwtcl.value" 0
        } else {
            ip_set_param "parameter.core16_vf_ceb_pointer_addr_hwtcl.value" $PROP_VALUE
        }
    }
}







#----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
#Ftile SS only Param Validation Callback
proc ::intel_pcie_ss_axi::parameters::validate_core16_pld_clrpcs_hwtcl { PROP_NAME PROP_VALUE } {
    set tile [ip_get "parameter.TILE.value"]
    if {$tile == "F-TILE"} {

        set core16_func_mode_integer              [ip_get "parameter.core16_func_mode_integer_hwtcl.value"]
        set core16_pcie_cvp_attr                  [ip_get "parameter.core16_pcie_cvp_attr_hwtcl.value"]
        set pld_clrpcs                            [ip_get "parameter.pld_clrpcs_hwtcl.value"]
        set core16_virtual_rp_ep_mode_integer     [ip_get "parameter.core16_virtual_rp_ep_mode_integer_hwtcl.value"]
        set core16_tlp_bypass_isDownstream        [ip_get "parameter.core16_tlp_bypass_isDownstream_hwtcl.value"]
        set core16_virtual_tlp_bypass_en          [ip_get "parameter.core16_virtual_tlp_bypass_en_hwtcl.value"]
        set core16_pld_clrpcs_user                [ip_get "parameter.core16_pld_clrpcs_user_hwtcl.value"]
        set pld_clrpcs_user_features              [get_quartus_ini "pld_clrpcs_user_features" ENABLED]

            if { $core16_func_mode_integer == 1} {
                if { $core16_virtual_rp_ep_mode_integer == 0 || ($core16_virtual_tlp_bypass_en == 1 && $core16_tlp_bypass_isDownstream == 0) } {
                    if {$core16_pcie_cvp_attr == 1} {
                        ip_set_param "parameter.core16_pld_clrpcs_hwtcl.value" 0
                    } elseif {$pld_clrpcs_user_features ==1} {
                        if {$pld_clrpcs == 1} {
                            if {$core16_pld_clrpcs_user == "GPIO Perst"} {
                                ip_set_param "parameter.core16_pld_clrpcs_hwtcl.value" 1
                            } else {
                                ip_set_param "parameter.core16_pld_clrpcs_hwtcl.value" 0
                            }
                        } else {
                            ip_set_param "parameter.core16_pld_clrpcs_hwtcl.value" 0
                        }
                    } elseif {$pld_clrpcs == 1} {
                        ip_set_param "parameter.core16_pld_clrpcs_hwtcl.value" 1
                    } else {
                        ip_set_param "parameter.core16_pld_clrpcs_hwtcl.value" 0
                    }
                } else {
                    ip_set_param "parameter.core16_pld_clrpcs_hwtcl.value" 0
                }
            } else {
                ip_set_param "parameter.core16_pld_clrpcs_hwtcl.value" 0
            }
    }
}


proc ::intel_pcie_ss_axi::parameters::validate_core16_enable_virtio_hwtcl { } {
    set topology    [ip_get "parameter.core16_topology_hwtcl.value"]
    if { [regexp "1x4" $topology] } {
       ip_set_param "parameter.core16_enable_virtio_hwtcl.VISIBLE" false
    }
}

proc ::intel_pcie_ss_axi::parameters::validate_core16_pcie_cvp_attr_hwtcl { PROP_NAME PROP_VALUE  } {
    set tile [ip_get "parameter.TILE.value"]
    if {$tile == "F-TILE"} {

        set core16_enable_power_mgnt_intf_hwtcl [ip_get "parameter.core16_enable_power_mgnt_intf_hwtcl.value"]
        if { $PROP_VALUE && $core16_enable_power_mgnt_intf_hwtcl } {
            send_message info "p0_app_req_retry_en_i must be tied off to zero when enabling CVP."
        }
    }
}

proc ::intel_pcie_ss_axi::parameters::validate_core16_pf0_pci_type0_vendor_id_hwtcl { PROP_NAME PROP_VALUE core16_func_mode_hwtcl } {
    set core16_func [ip_get "parameter.core16_func_mode_hwtcl.value"]
    if { ${core16_func} == "Enable" } {
        ip_set_param "parameter.core16_vendor_id_hwtcl.value" $PROP_VALUE
        send_message info "PCIe0 pf0 IDs: Vendor ID is set to 0x[format %x $PROP_VALUE]. Please set proper value according to user application."
    } else {
        ip_set_param "parameter.core16_vendor_id_hwtcl.value" 0
        send_message info "PCIe0 pf0 IDs: Vendor ID set to 0x[format %x $PROP_VALUE]. Please set proper value according to user application."
    }
}

proc ::intel_pcie_ss_axi::parameters::validate_core16_pf0_revision_id_hwtcl  { PROP_NAME PROP_VALUE core16_func_mode_hwtcl } {
    set core16_func [ip_get "parameter.core16_func_mode_hwtcl.value"]
    if { ${core16_func} == "Enable" } {
        ip_set_param "parameter.core16_revision_id_hwtcl.value" $PROP_VALUE
        send_message info "PCIe0 pf0 IDs: Revision ID is set to 0x[format %x $PROP_VALUE]. Please set proper value according to user application."
    } else {
        ip_set_param "parameter.core16_revision_id_hwtcl.value" 0
        send_message info "PCIe0 pf0 IDs: Vendor ID is set to 0x[format %x $PROP_VALUE]. Please set proper value according to user application."
    }
}

#vww18_proc_not_used
proc ::intel_pcie_ss_axi::parameters::validate_core16_pf0_dsp_16g_tx_preset_hwtcl {PROP_NAME PROP_VALUE} {
    set core16_func_mode [ip_get "parameter.core16_func_mode_hwtcl.value"]
    set core16_virtual_rp_ep_mode_integer_hwtcl [ip_get "parameter.core16_virtual_rp_ep_mode_integer_hwtcl.value"]
    set core16_virtual_link_rate_hwtcl [ip_get "parameter.core16_virtual_link_rate_hwtcl.value"]

    if { $core16_func_mode == "Disable" || $core16_virtual_rp_ep_mode_integer_hwtcl == 0 || $core16_virtual_link_rate_hwtcl == "Gen3 (8.0 Gbps)"} {
        ip_set_param "parameter.${PROP_NAME}.value" 0
    } else {
        ip_set_param "parameter.${PROP_NAME}.value" 8
    }
}

#vww18_proc_not_used
proc ::intel_pcie_ss_axi::parameters::validate_core16_pf0_dsp_tx_preset_hwtcl {PROP_NAME PROP_VALUE} {
    set core16_func_mode [ip_get "parameter.core16_func_mode_hwtcl.value"]
    set core16_virtual_rp_ep_mode_integer_hwtcl [ip_get "parameter.core16_virtual_rp_ep_mode_integer_hwtcl.value"]

    if { $core16_func_mode == "Disable" || $core16_virtual_rp_ep_mode_integer_hwtcl == 0} {
        ip_set_param "parameter.${PROP_NAME}.value" 0
    } else {
        ip_set_param "parameter.${PROP_NAME}.value" 8
    }
}

## ATS Validation Callback
proc ::intel_pcie_ss_axi::parameters::validate_core16_vf_ats_pagealignreq_hwtcl {PROP_NAME PROP_VALUE} {
    set tile [ip_get "parameter.TILE.value"]
    if {$tile == "F-TILE" ||$tile =="R-TILE"} {

        #HSD: 15011482182
        set core16_func_mode [ip_get "parameter.core16_func_mode_hwtcl.value"]

        regexp {pf.} $PROP_NAME pf_num
        set core16_vf_ats_cap_enable_hwtcl [ip_get "parameter.core16_${pf_num}_vf_ats_cap_enable_hwtcl.value"]
        if {$core16_func_mode == "Enable" && $core16_vf_ats_cap_enable_hwtcl == 1} {
            ip_set_param "parameter.core16_${pf_num}_vf_ats_pagealignreq_hwtcl.value" 1
        } else {
            ip_set_param "parameter.core16_${pf_num}_vf_ats_pagealignreq_hwtcl.value" 0
        }
    }
}

proc ::intel_pcie_ss_axi::parameters::validate_core16_pf0_gen_eq_pset_req_vec_hwtcl {PROP_NAME PROP_VALUE core16_func_mode_hwtcl core16_pf0_gen3_eq_pset_req_vec_a0_user_hwtcl core16_pf0_gen4_eq_pset_req_vec_a0_user_hwtcl core16_pf0_gen5_eq_pset_req_vec_a0_user_hwtcl core16_pf0_gen3_eq_pset_req_vec_user_hwtcl core16_pf0_gen4_eq_pset_req_vec_user_hwtcl core16_pf0_gen5_eq_pset_req_vec_user_hwtcl qhip_silicon_reva_revb_hwtcl} {

    set tile [ip_get "parameter.TILE.value"]
    if {$tile == "R-TILE"} {

    	#HSD: 1508467024 14015862132 1509806751
    	if {!$qhip_silicon_reva_revb_hwtcl} {
    		#A0	
    		ip_set_param "parameter.core16_pf0_gen3_eq_pset_req_vec_a0_user_hwtcl.ALLOWED_RANGES" {0:65535}
    		ip_set_param "parameter.core16_pf0_gen4_eq_pset_req_vec_a0_user_hwtcl.ALLOWED_RANGES" {0:65535}
    		ip_set_param "parameter.core16_pf0_gen5_eq_pset_req_vec_a0_user_hwtcl.ALLOWED_RANGES" {0:65535}
    	} else {
    		#B0
    		ip_set_param "parameter.core16_pf0_gen3_eq_pset_req_vec_user_hwtcl.ALLOWED_RANGES" {0:2047}
    		ip_set_param "parameter.core16_pf0_gen4_eq_pset_req_vec_user_hwtcl.ALLOWED_RANGES" {0:2047}
    		ip_set_param "parameter.core16_pf0_gen5_eq_pset_req_vec_user_hwtcl.ALLOWED_RANGES" {0:2047}
    	}
    		
    	if {$core16_func_mode_hwtcl == "Disable"} {
    		ip_set_param "parameter.core16_pf0_gen3_eq_pset_req_vec_hwtcl.value" 2047
    		ip_set_param "parameter.core16_pf0_gen4_eq_pset_req_vec_hwtcl.value" 927
    		ip_set_param "parameter.core16_pf0_gen5_eq_pset_req_vec_hwtcl.value" 927
    	} else {
    		if {!$qhip_silicon_reva_revb_hwtcl} {
    			#A0 
    			ip_set_param "parameter.core16_pf0_gen3_eq_pset_req_vec_hwtcl.value" $core16_pf0_gen3_eq_pset_req_vec_a0_user_hwtcl
    			ip_set_param "parameter.core16_pf0_gen4_eq_pset_req_vec_hwtcl.value" $core16_pf0_gen4_eq_pset_req_vec_a0_user_hwtcl
    			ip_set_param "parameter.core16_pf0_gen5_eq_pset_req_vec_hwtcl.value" $core16_pf0_gen5_eq_pset_req_vec_a0_user_hwtcl
    		} else {
    			#B0
    			ip_set_param "parameter.core16_pf0_gen3_eq_pset_req_vec_hwtcl.value" $core16_pf0_gen3_eq_pset_req_vec_user_hwtcl
    			ip_set_param "parameter.core16_pf0_gen4_eq_pset_req_vec_hwtcl.value" $core16_pf0_gen4_eq_pset_req_vec_user_hwtcl
    			ip_set_param "parameter.core16_pf0_gen5_eq_pset_req_vec_hwtcl.value" $core16_pf0_gen5_eq_pset_req_vec_user_hwtcl
    		}
    	}
    }
}

proc ::intel_pcie_ss_axi::parameters::validate_core16_pf0_gen_eq_pset_req_vec_b0_hwtcl {PROP_NAME PROP_VALUE core16_func_mode_hwtcl core16_pf0_gen3_eq_pset_req_vec_atg4_b0_user_hwtcl core16_pf0_gen3_eq_pset_req_vec_b0_user_hwtcl generating_b0_hwtcl} {
    set tile [ip_get "parameter.TILE.value"]
    if {$tile == "F-TILE"} {

        if { $core16_func_mode_hwtcl == "Disable" } {
    		ip_set_param "parameter.core16_pf0_gen3_eq_pset_req_vec_hwtcl_f.value" 32
    		ip_set_param "parameter.core16_pf0_gen3_eq_pset_req_vec_atg4_hwtcl_f.value" 1023
    	} else { 
                if { $generating_b0_hwtcl } {
                    #B0 
                    ip_set_param "parameter.core16_pf0_gen3_eq_pset_req_vec_hwtcl_f.value" $core16_pf0_gen3_eq_pset_req_vec_b0_user_hwtcl
                    ip_set_param "parameter.core16_pf0_gen3_eq_pset_req_vec_atg4_hwtcl_f.value" $core16_pf0_gen3_eq_pset_req_vec_atg4_b0_user_hwtcl
    		#A0 INVISBLE AND DISABLED
    		ip_set_param "parameter.core16_pf0_gen3_eq_pset_req_vec_a0_user_hwtcl.VISIBLE" false
    		ip_set_param "parameter.core16_pf0_gen3_eq_pset_req_vec_atg4_a0_user_hwtcl.VISIBLE" false
    
    	        ip_set_param "parameter.core16_pf0_gen3_eq_pset_req_vec_a0_user_hwtcl.ENABLED" false
    		ip_set_param "parameter.core16_pf0_gen3_eq_pset_req_vec_atg4_a0_user_hwtcl.ENABLED" false          		
    		#C0 INVISBLE AND DISABLED
    		ip_set_param "parameter.core16_pf0_gen3_eq_pset_req_vec_c0_user_hwtcl.VISIBLE" false
    		ip_set_param "parameter.core16_pf0_gen3_eq_pset_req_vec_atg4_c0_user_hwtcl.VISIBLE" false
    
    		ip_set_param "parameter.core16_pf0_gen3_eq_pset_req_vec_c0_user_hwtcl.ENABLED" false
    		ip_set_param "parameter.core16_pf0_gen3_eq_pset_req_vec_atg4_c0_user_hwtcl.ENABLED" false 
    
    		#ip_message info "16-2-A0: parameter.core16_pf0_gen3_eq_pset_req_vec_a0_user_hwtcl = $core16_pf0_gen3_eq_pset_req_vec_a0_user_hwtcl"
    		#ip_message info "16-2-B0: parameter.core16_pf0_gen3_eq_pset_req_vec_b0_user_hwtcl = $core16_pf0_gen3_eq_pset_req_vec_b0_user_hwtcl"
    		#ip_message info "16-2-C0: parameter.core16_pf0_gen3_eq_pset_req_vec_c0_user_hwtcl = $core16_pf0_gen3_eq_pset_req_vec_c0_user_hwtcl"
    		
    	    } 
        }
   }
}

proc ::intel_pcie_ss_axi::parameters::validate_core16_pf0_gen_eq_pset_req_vec_c0_hwtcl {PROP_NAME PROP_VALUE core16_func_mode_hwtcl core16_pf0_gen3_eq_pset_req_vec_atg4_c0_user_hwtcl core16_pf0_gen3_eq_pset_req_vec_c0_user_hwtcl generating_c0_hwtcl} {
    set tile [ip_get "parameter.TILE.value"]
    if {$tile == "F-TILE"} {

        if { $core16_func_mode_hwtcl == "Disable" } {
    		ip_set_param "parameter.core16_pf0_gen3_eq_pset_req_vec_hwtcl_f.value" 32
    		ip_set_param "parameter.core16_pf0_gen3_eq_pset_req_vec_atg4_hwtcl_f.value" 1023
    	} else { 
                if { $generating_c0_hwtcl } {
                    #C0 
                    ip_set_param "parameter.core16_pf0_gen3_eq_pset_req_vec_hwtcl_f.value" $core16_pf0_gen3_eq_pset_req_vec_c0_user_hwtcl
                    ip_set_param "parameter.core16_pf0_gen3_eq_pset_req_vec_atg4_hwtcl_f.value" $core16_pf0_gen3_eq_pset_req_vec_atg4_c0_user_hwtcl
        		#A0 INVISBLE AND DISABLED
        		ip_set_param "parameter.core16_pf0_gen3_eq_pset_req_vec_a0_user_hwtcl.VISIBLE" false
        		ip_set_param "parameter.core16_pf0_gen3_eq_pset_req_vec_atg4_a0_user_hwtcl.VISIBLE" false
        
        		ip_set_param "parameter.core16_pf0_gen3_eq_pset_req_vec_a0_user_hwtcl.ENABLED" false
        		ip_set_param "parameter.core16_pf0_gen3_eq_pset_req_vec_atg4_a0_user_hwtcl.ENABLED" false   
        		#B0 INVISBLE AND DISABLED
        		ip_set_param "parameter.core16_pf0_gen3_eq_pset_req_vec_b0_user_hwtcl.VISIBLE" false
        		ip_set_param "parameter.core16_pf0_gen3_eq_pset_req_vec_atg4_b0_user_hwtcl.VISIBLE" false
        
                	ip_set_param "parameter.core16_pf0_gen3_eq_pset_req_vec_b0_user_hwtcl.ENABLED" false
        		ip_set_param "parameter.core16_pf0_gen3_eq_pset_req_vec_atg4_b0_user_hwtcl.ENABLED" false 
        	
        		#ip_message info "16-3-A0: parameter.core16_pf0_gen3_eq_pset_req_vec_a0_user_hwtcl = $core16_pf0_gen3_eq_pset_req_vec_a0_user_hwtcl"
        		#ip_message info "16-3-B0: parameter.core16_pf0_gen3_eq_pset_req_vec_b0_user_hwtcl = $core16_pf0_gen3_eq_pset_req_vec_b0_user_hwtcl"
        		#ip_message info "16-3-C0: parameter.core16_pf0_gen3_eq_pset_req_vec_c0_user_hwtcl = $core16_pf0_gen3_eq_pset_req_vec_c0_user_hwtcl"
    	    } 
    	}
    }
}

proc ::intel_pcie_ss_axi::parameters::validate_core16_virtual_ptm_hwtcl { PROP_NAME PROP_VALUE} {
    set tile [ip_get "parameter.TILE.value"]
    if {$tile == "F-TILE" ||$tile=="R-TILE"} {
  
        if { $PROP_VALUE } {
        send_message info "When PTM is enabled, it automatically enabled PTM manual update"
        }
    }

}

proc ::intel_pcie_ss_axi::parameters::validate_core16_cfg_ptm_local_clock_adj_lsb_hwtcl {} {
    set tile [ip_get "parameter.TILE.value"]
    if {$tile == "F-TILE"} {

        set pld_clkfreq_integer_hwtcl    [ip_get "parameter.pld_clkfreq_integer_hwtcl.value"]
        set adapter_type                 [ip_get "parameter.adapter_type_hwtcl.value"]
        if { [ip_get "parameter.core16_func_mode_hwtcl.value"] == "Disable" || [ip_get "parameter.core16_virtual_ptm_hwtcl.value"] == 0 || [ip_get "parameter.core16_virtual_rp_ep_mode_integer_hwtcl.value"] == 1 } {
            ip_set_param "parameter.core16_cfg_ptm_local_clock_adj_lsb_hwtcl.value" 0
        } elseif {$adapter_type == "A" || $adapter_type == "B" || $adapter_type == "C"} {
        if { $pld_clkfreq_integer_hwtcl == 250 } {
            ip_set_param "parameter.core16_cfg_ptm_local_clock_adj_lsb_hwtcl.value" 178
            } elseif { $pld_clkfreq_integer_hwtcl == 225 } {
                    ip_set_param "parameter.core16_cfg_ptm_local_clock_adj_lsb_hwtcl.value" 198
            } elseif { $pld_clkfreq_integer_hwtcl == 200 } {
                    ip_set_param "parameter.core16_cfg_ptm_local_clock_adj_lsb_hwtcl.value" 223
            } elseif { $pld_clkfreq_integer_hwtcl == 175 } {
                    ip_set_param "parameter.core16_cfg_ptm_local_clock_adj_lsb_hwtcl.value" 254
            }
        } else {
        if { $pld_clkfreq_integer_hwtcl == 500 } {
            ip_set_param "parameter.core16_cfg_ptm_local_clock_adj_lsb_hwtcl.value" 151
        } elseif { $pld_clkfreq_integer_hwtcl == 450 } {
            ip_set_param "parameter.core16_cfg_ptm_local_clock_adj_lsb_hwtcl.value" 168
        } elseif { $pld_clkfreq_integer_hwtcl == 400 } {
            ip_set_param "parameter.core16_cfg_ptm_local_clock_adj_lsb_hwtcl.value" 189
        } elseif { $pld_clkfreq_integer_hwtcl == 350 } {
            ip_set_param "parameter.core16_cfg_ptm_local_clock_adj_lsb_hwtcl.value" 216
        } elseif { $pld_clkfreq_integer_hwtcl == 250 } {
            ip_set_param "parameter.core16_cfg_ptm_local_clock_adj_lsb_hwtcl.value" 302
        }
        }
    }
}


proc ::intel_pcie_ss_axi::parameters::validate_core16_virtual_ptm_autoupdate_hwtcl {core16_func_mode_hwtcl core16_virtual_rp_ep_mode_hwtcl core16_virtual_ptm_hwtcl core16_cfg_ptm_auto_update_period_hwtcl pld_clkfreq_integer_hwtcl } {
    set tile [ip_get "parameter.TILE.value"]
    if {$tile == "F-TILE"} {

        if { [ip_get "parameter.core16_virtual_ptm_hwtcl.value"]  == 0 || [ip_get "parameter.core16_cfg_ptm_auto_update_period_hwtcl.value"] == "Disable"} {
            ip_set_param "parameter.core16_virtual_ptm_autoupdate_hwtcl.value" 0
        } else {
            if { [ip_get "parameter.core16_cfg_ptm_auto_update_period_hwtcl.value"] == "1"} {
                ip_set_param "parameter.core16_virtual_ptm_autoupdate_hwtcl.value" 1
            } elseif { [ip_get "parameter.core16_cfg_ptm_auto_update_period_hwtcl.value"] == "2"} {
                ip_set_param "parameter.core16_virtual_ptm_autoupdate_hwtcl.value" 2
            } elseif { [ip_get "parameter.core16_cfg_ptm_auto_update_period_hwtcl.value"] == "3"} {
                ip_set_param "parameter.core16_virtual_ptm_autoupdate_hwtcl.value" 3
            } elseif { [ip_get "parameter.core16_cfg_ptm_auto_update_period_hwtcl.value"] == "4"} {
                ip_set_param "parameter.core16_virtual_ptm_autoupdate_hwtcl.value" 4
            } elseif { [ip_get "parameter.core16_cfg_ptm_auto_update_period_hwtcl.value"] == "5"} {
                ip_set_param "parameter.core16_virtual_ptm_autoupdate_hwtcl.value" 5
            } elseif { [ip_get "parameter.core16_cfg_ptm_auto_update_period_hwtcl.value"] == "6"} {
                ip_set_param "parameter.core16_virtual_ptm_autoupdate_hwtcl.value" 6
            } elseif { [ip_get "parameter.core16_cfg_ptm_auto_update_period_hwtcl.value"] == "7"} {
                ip_set_param "parameter.core16_virtual_ptm_autoupdate_hwtcl.value" 7
            } elseif { [ip_get "parameter.core16_cfg_ptm_auto_update_period_hwtcl.value"] == "8"} {
                ip_set_param "parameter.core16_virtual_ptm_autoupdate_hwtcl.value" 8
            } elseif { [ip_get "parameter.core16_cfg_ptm_auto_update_period_hwtcl.value"] == "9"} {
                ip_set_param "parameter.core16_virtual_ptm_autoupdate_hwtcl.value" 9
            } elseif { [ip_get "parameter.core16_cfg_ptm_auto_update_period_hwtcl.value"] == "10"} {
                ip_set_param "parameter.core16_virtual_ptm_autoupdate_hwtcl.value" 10
            }
        }
    } elseif {$tile =="R-TILE"} {
     if { $core16_func_mode_hwtcl == "Disable" } {
        ip_set_param "parameter.core16_virtual_ptm_autoupdate_hwtcl.value" "10"
    } elseif {$core16_virtual_ptm_hwtcl  == 0} {
		ip_set_param "parameter.core16_virtual_ptm_autoupdate_hwtcl.value" "0"
    } else {
        if { $core16_cfg_ptm_auto_update_period_hwtcl == "1"} {
            ip_set_param "parameter.core16_virtual_ptm_autoupdate_hwtcl.value" "1"
        } elseif { $core16_cfg_ptm_auto_update_period_hwtcl == "2"} {
            ip_set_param "parameter.core16_virtual_ptm_autoupdate_hwtcl.value" "2"
        } elseif { $core16_cfg_ptm_auto_update_period_hwtcl == "3"} {
            ip_set_param "parameter.core16_virtual_ptm_autoupdate_hwtcl.value" "3"
        } elseif { $core16_cfg_ptm_auto_update_period_hwtcl == "4"} {
            ip_set_param "parameter.core16_virtual_ptm_autoupdate_hwtcl.value" "4"
        } elseif { $core16_cfg_ptm_auto_update_period_hwtcl == "5"} {
            ip_set_param "parameter.core16_virtual_ptm_autoupdate_hwtcl.value" "5"
        } elseif { $core16_cfg_ptm_auto_update_period_hwtcl == "6"} {
            ip_set_param "parameter.core16_virtual_ptm_autoupdate_hwtcl.value" "6"
        } elseif { $core16_cfg_ptm_auto_update_period_hwtcl == "7"} {
            ip_set_param "parameter.core16_virtual_ptm_autoupdate_hwtcl.value" "7"
        } elseif { $core16_cfg_ptm_auto_update_period_hwtcl == "8"} {
            ip_set_param "parameter.core16_virtual_ptm_autoupdate_hwtcl.value" "8"
        } elseif { $core16_cfg_ptm_auto_update_period_hwtcl == "9"} {
            ip_set_param "parameter.core16_virtual_ptm_autoupdate_hwtcl.value" "9"
        } elseif { $core16_cfg_ptm_auto_update_period_hwtcl == "10"} {
            ip_set_param "parameter.core16_virtual_ptm_autoupdate_hwtcl.value" "10"
        } elseif { $core16_cfg_ptm_auto_update_period_hwtcl == "Disable"} {
            ip_set_param "parameter.core16_virtual_ptm_autoupdate_hwtcl.value" "0"
        }
        send_message info "When PTM is enabled, it automatically enabled PTM manual update."
    }
	
	
	#PTM adjustment
	if { $core16_func_mode_hwtcl == "Disable" || $core16_virtual_ptm_hwtcl  == 0 || $core16_virtual_rp_ep_mode_hwtcl == "Root Port" } {
		ip_set_param "parameter.core16_virtual_ptm_adj_lsb_hwtcl.value" "0"
		ip_set_param "parameter.core16_virtual_ptm_adj_msb_hwtcl.value" "0"
	} else {
		if {$pld_clkfreq_integer_hwtcl == 500} {
			ip_set_param "parameter.core16_virtual_ptm_adj_lsb_hwtcl.value" "157"
			ip_set_param "parameter.core16_virtual_ptm_adj_msb_hwtcl.value" "0"
		} elseif {$pld_clkfreq_integer_hwtcl == 475} {
			ip_set_param "parameter.core16_virtual_ptm_adj_lsb_hwtcl.value" "165"
			ip_set_param "parameter.core16_virtual_ptm_adj_msb_hwtcl.value" "0"
		} elseif {$pld_clkfreq_integer_hwtcl == 450} {
			ip_set_param "parameter.core16_virtual_ptm_adj_lsb_hwtcl.value" "174"
			ip_set_param "parameter.core16_virtual_ptm_adj_msb_hwtcl.value" "0"
		} elseif {$pld_clkfreq_integer_hwtcl == 425} {
			ip_set_param "parameter.core16_virtual_ptm_adj_lsb_hwtcl.value" "185"
			ip_set_param "parameter.core16_virtual_ptm_adj_msb_hwtcl.value" "0"
		} elseif {$pld_clkfreq_integer_hwtcl == 400} {
			ip_set_param "parameter.core16_virtual_ptm_adj_lsb_hwtcl.value" "196"
			ip_set_param "parameter.core16_virtual_ptm_adj_msb_hwtcl.value" "0"
		} elseif {$pld_clkfreq_integer_hwtcl == 300} {
			ip_set_param "parameter.core16_virtual_ptm_adj_lsb_hwtcl.value" "262"
			ip_set_param "parameter.core16_virtual_ptm_adj_msb_hwtcl.value" "0"
		} elseif {$pld_clkfreq_integer_hwtcl == 275} {
			ip_set_param "parameter.core16_virtual_ptm_adj_lsb_hwtcl.value" "285"
			ip_set_param "parameter.core16_virtual_ptm_adj_msb_hwtcl.value" "0"
		} elseif {$pld_clkfreq_integer_hwtcl == 250} {
			ip_set_param "parameter.core16_virtual_ptm_adj_lsb_hwtcl.value" "314"
			ip_set_param "parameter.core16_virtual_ptm_adj_msb_hwtcl.value" "0"
		} else {
			ip_set_param "parameter.core16_virtual_ptm_adj_lsb_hwtcl.value" "0"
			ip_set_param "parameter.core16_virtual_ptm_adj_msb_hwtcl.value" "0"
		}
	}
   }
}

proc ::intel_pcie_ss_axi::parameters::validate_core16_virtual_num_of_lanes_hwtcl {core16_func_mode_hwtcl core16_topology_hwtcl } {
    set tile [ip_get "parameter.TILE.value"]
    if {$tile == "F-TILE"} {

        set virtual_num_of_lanes_16 [ip_get "parameter.core16_virtual_num_of_lanes_16_hwtcl.value"] 
        set virtual_num_of_lanes_8  [ip_get "parameter.core16_virtual_num_of_lanes_8_hwtcl.value"]
        set virtual_num_of_lanes_4  [ip_get "parameter.core16_virtual_num_of_lanes_4_hwtcl.value"]
        set core16_func [ip_get "parameter.core16_func_mode_hwtcl.value"]
        set topology    [ip_get "parameter.core16_topology_hwtcl.value"]
    
        if { $core16_func == "Disable" } {
            ip_set_param "parameter.core16_virtual_num_of_lanes_hwtcl_f.value" 1
        } else {
            #TODO: Decode more topology
            if { [regexp "1x16" $topology] } {
                ip_set_param "parameter.core16_virtual_num_of_lanes_16_hwtcl.VISIBLE" true
                ip_set_param "parameter.core16_virtual_num_of_lanes_8_hwtcl.VISIBLE"  false
                ip_set_param "parameter.core16_virtual_num_of_lanes_4_hwtcl.VISIBLE"  false
                ip_set_param "parameter.core16_virtual_num_of_lanes_hwtcl_f.value" $virtual_num_of_lanes_16
            } elseif { [regexp "2x8" $topology] } {
                ip_set_param "parameter.core16_virtual_num_of_lanes_16_hwtcl.VISIBLE" false
                ip_set_param "parameter.core16_virtual_num_of_lanes_8_hwtcl.VISIBLE"  true
                ip_set_param "parameter.core16_virtual_num_of_lanes_4_hwtcl.VISIBLE"  false
                ip_set_param "parameter.core16_virtual_num_of_lanes_hwtcl_f.value" $virtual_num_of_lanes_8
            } elseif { [regexp "4x4" $topology] } {
                ip_set_param "parameter.core16_virtual_num_of_lanes_16_hwtcl.VISIBLE" false
                ip_set_param "parameter.core16_virtual_num_of_lanes_8_hwtcl.VISIBLE"  false
                ip_set_param "parameter.core16_virtual_num_of_lanes_4_hwtcl.VISIBLE"  true
                ip_set_param "parameter.core16_virtual_num_of_lanes_hwtcl_f.value" $virtual_num_of_lanes_4
            } elseif { [regexp "1x4" $topology] } {
                ip_set_param "parameter.core16_virtual_num_of_lanes_16_hwtcl.VISIBLE" false
                ip_set_param "parameter.core16_virtual_num_of_lanes_8_hwtcl.VISIBLE"  false
                ip_set_param "parameter.core16_virtual_num_of_lanes_4_hwtcl.VISIBLE"  true
                ip_set_param "parameter.core16_virtual_num_of_lanes_hwtcl_f.value" $virtual_num_of_lanes_4
            } elseif { [regexp "2x4" $topology] } {
                ip_set_param "parameter.core16_virtual_num_of_lanes_16_hwtcl.VISIBLE" false
                ip_set_param "parameter.core16_virtual_num_of_lanes_8_hwtcl.VISIBLE"  false
                ip_set_param "parameter.core16_virtual_num_of_lanes_4_hwtcl.VISIBLE"  true
                ip_set_param "parameter.core16_virtual_num_of_lanes_hwtcl_f.value" $virtual_num_of_lanes_4
            } elseif { [regexp "1x8" $topology] } {
                ip_set_param "parameter.core16_virtual_num_of_lanes_16_hwtcl.VISIBLE" false
                ip_set_param "parameter.core16_virtual_num_of_lanes_8_hwtcl.VISIBLE"  true
                ip_set_param "parameter.core16_virtual_num_of_lanes_4_hwtcl.VISIBLE"  false
                ip_set_param "parameter.core16_virtual_num_of_lanes_hwtcl_f.value" $virtual_num_of_lanes_8
            }
        }
    } elseif {$tile =="R-TILE"} {
         set virtual_num_of_lanes_16 [ip_get "parameter.core16_virtual_num_of_lanes_16_hwtcl.value"] 
    set virtual_num_of_lanes_8  [ip_get "parameter.core16_virtual_num_of_lanes_8_hwtcl.value"]
    set virtual_num_of_lanes_4  [ip_get "parameter.core16_virtual_num_of_lanes_4_hwtcl.value"]
	
    if { $core16_func_mode_hwtcl == "Disable" } {
        ip_set_param "parameter.core16_virtual_num_of_lanes_hwtcl_.value" "1"
    } else {
        #TODO: Decode more topology
        if { [regexp "1x16" $core16_topology_hwtcl] } {
            ip_set_param "parameter.core16_virtual_num_of_lanes_16_hwtcl.VISIBLE" true
            ip_set_param "parameter.core16_virtual_num_of_lanes_8_hwtcl.VISIBLE"  false
            ip_set_param "parameter.core16_virtual_num_of_lanes_4_hwtcl.VISIBLE"  false
            ip_set_param "parameter.core16_virtual_num_of_lanes_hwtcl_r.value" $virtual_num_of_lanes_16
        } elseif { [regexp "2x8" $core16_topology_hwtcl] } {
            ip_set_param "parameter.core16_virtual_num_of_lanes_16_hwtcl.VISIBLE" false
            ip_set_param "parameter.core16_virtual_num_of_lanes_8_hwtcl.VISIBLE"  true
            ip_set_param "parameter.core16_virtual_num_of_lanes_4_hwtcl.VISIBLE"  false
            ip_set_param "parameter.core16_virtual_num_of_lanes_hwtcl_r.value" $virtual_num_of_lanes_8
        } elseif { [regexp "4x4" $core16_topology_hwtcl] } {
            ip_set_param "parameter.core16_virtual_num_of_lanes_16_hwtcl.VISIBLE" false
            ip_set_param "parameter.core16_virtual_num_of_lanes_8_hwtcl.VISIBLE"  false
            ip_set_param "parameter.core16_virtual_num_of_lanes_4_hwtcl.VISIBLE"  true
            ip_set_param "parameter.core16_virtual_num_of_lanes_hwtcl_r.value" $virtual_num_of_lanes_4
        } elseif { [regexp "Pipe Direct 8-channel" $core16_topology_hwtcl] && [regexp "2x4" $core16_topology_hwtcl] } {
            ip_set_param "parameter.core16_virtual_num_of_lanes_16_hwtcl.VISIBLE" false
            ip_set_param "parameter.core16_virtual_num_of_lanes_8_hwtcl.VISIBLE"  false
            ip_set_param "parameter.core16_virtual_num_of_lanes_4_hwtcl.VISIBLE"  true
            ip_set_param "parameter.core16_virtual_num_of_lanes_hwtcl_r.value" $virtual_num_of_lanes_4
        } elseif { [regexp "Pipe Direct 8-channel" $core16_topology_hwtcl] && [regexp "1x8" $core16_topology_hwtcl] } {
            ip_set_param "parameter.core16_virtual_num_of_lanes_16_hwtcl.VISIBLE" false
            ip_set_param "parameter.core16_virtual_num_of_lanes_8_hwtcl.VISIBLE"  true
            ip_set_param "parameter.core16_virtual_num_of_lanes_4_hwtcl.VISIBLE"  false
            ip_set_param "parameter.core16_virtual_num_of_lanes_hwtcl_r.value" $virtual_num_of_lanes_8
        } elseif { [regexp "1x8" $core16_topology_hwtcl] && [regexp "2x4" $core16_topology_hwtcl] } {
            ip_set_param "parameter.core16_virtual_num_of_lanes_16_hwtcl.VISIBLE" false
            ip_set_param "parameter.core16_virtual_num_of_lanes_8_hwtcl.VISIBLE"  true
            ip_set_param "parameter.core16_virtual_num_of_lanes_4_hwtcl.VISIBLE"  false
            ip_set_param "parameter.core16_virtual_num_of_lanes_hwtcl_r.value" $virtual_num_of_lanes_8
        } elseif { [regexp "Pipe Direct 16-channel" $core16_topology_hwtcl] } {
			ip_set_param "parameter.core16_virtual_num_of_lanes_16_hwtcl.VISIBLE" false
            ip_set_param "parameter.core16_virtual_num_of_lanes_8_hwtcl.VISIBLE"  false
            ip_set_param "parameter.core16_virtual_num_of_lanes_4_hwtcl.VISIBLE"  false
			ip_set_param "parameter.core16_virtual_num_of_lanes_hwtcl_r.value"	"1"
		}
    }
  }
}

proc ::intel_pcie_ss_axi::parameters::validate_core16_pld_clrpcs_user_features {} {
    set tile [ip_get "parameter.TILE.value"]
    if {$tile == "F-TILE"} {

            # Debug Features for Internal and External Customer
            # This callback must put at the last parameter of the list, or else the VISIBLE will not take effect
            #VISIBLE default set to false

            ip_set_param "parameter.core16_pld_clrpcs_user_hwtcl.ENABLED" false
            ip_set_param "parameter.core16_pld_clrpcs_user_hwtcl.VISIBLE" false

            set pld_clrpcs_user_features              [get_quartus_ini "pld_clrpcs_user_features" ENABLED]
            set pld_clrpcs                            [ip_get "parameter.pld_clrpcs_hwtcl.value"]
            set core16_pcie_cvp_attr                  [ip_get "parameter.core16_pcie_cvp_attr_hwtcl.value"]
            set core16_func_mode_integer              [ip_get "parameter.core16_func_mode_integer_hwtcl.value"]
            set core16_virtual_rp_ep_mode_integer     [ip_get "parameter.core16_virtual_rp_ep_mode_integer_hwtcl.value"]
            set core16_tlp_bypass_isDownstream        [ip_get "parameter.core16_tlp_bypass_isDownstream_hwtcl.value"]
            set core16_virtual_tlp_bypass_en          [ip_get "parameter.core16_virtual_tlp_bypass_en_hwtcl.value"]

            if {$pld_clrpcs_user_features == 1} {
                if { $core16_func_mode_integer == 1} {
                    if { $core16_virtual_rp_ep_mode_integer == 0 || ($core16_virtual_tlp_bypass_en == 1 && $core16_tlp_bypass_isDownstream == 0) } {
                        if {$core16_pcie_cvp_attr ==1} {
                            ip_set_param "parameter.core16_pld_clrpcs_user_hwtcl.VISIBLE" false
                            ip_set_param "parameter.core16_pld_clrpcs_user_hwtcl.ENABLED" false
                        } elseif {$pld_clrpcs == 1} {
                            ip_set_param "parameter.core16_pld_clrpcs_user_hwtcl.VISIBLE" true
                            ip_set_param "parameter.core16_pld_clrpcs_user_hwtcl.ENABLED" true
                        } else {
                            ip_set_param "parameter.core16_pld_clrpcs_user_hwtcl.VISIBLE" false
                            ip_set_param "parameter.core16_pld_clrpcs_user_hwtcl.ENABLED" false
                        }
                    } else {
                        ip_set_param "parameter.core16_pld_clrpcs_user_hwtcl.VISIBLE" false
                        ip_set_param "parameter.core16_pld_clrpcs_user_hwtcl.ENABLED" false
                    }
                } else {
                    ip_set_param "parameter.core16_pld_clrpcs_user_hwtcl.VISIBLE" false
                    ip_set_param "parameter.core16_pld_clrpcs_user_hwtcl.ENABLED" false
                }
            } else {
                ip_set_param "parameter.core16_pld_clrpcs_user_hwtcl.VISIBLE" false
                ip_set_param "parameter.core16_pld_clrpcs_user_hwtcl.ENABLED" false
            }
     }
}


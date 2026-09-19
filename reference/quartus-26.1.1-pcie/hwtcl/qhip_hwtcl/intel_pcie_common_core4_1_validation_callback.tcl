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


proc ::intel_pcie_ss_axi::parameters::validate_core4_1_base_device { PROP_NAME PROP_VALUE } {
    if { [string compare -nocase $PROP_VALUE "unknown"] == 0 } {
        send_message error "The current selected base_device \"$PROP_VALUE\" is invalid, please select a valid device to generate the IP."
    }
}
proc ::intel_pcie_ss_axi::parameters::validate_core4_1_topology_hwtcl { PROP_NAME PROP_VALUE core4_1_func_mode_hwtcl core4_1_func_mode_integer_hwtcl} {
    set tile [ip_get "parameter.TILE.value"]

    if { $tile == "P-TILE" } {
    
        set core4_1_topology_integer_hwtcl [ip_get "parameter.core4_1_topology_integer_hwtcl.value"]
        set core4_1_func [ip_get "parameter.core4_1_func_mode_hwtcl.value"]
        
        if {  [regexp "Gen4" $PROP_VALUE] } {
            set core4_1_virtual_link_rate_hwtcl "Gen4 (16.0 Gbps)"
        } elseif { [regexp "Gen3" $PROP_VALUE] } {
            # "Gen3 (8.0 Gbps)"
            set core4_1_virtual_link_rate_hwtcl "Gen3 (8.0 Gbps)"
        } else {
            send_message error "Topology is not set"
        }
        
        
        if { [regexp "x4" $PROP_VALUE] } {
            set core4_1_virtual_link_width_hwtcl "x4"
            #send_message info "Four x4 PCIe ports will be instantiated."
        } else {
            #send_message error "Topology is not set"
        }
        if {$core4_1_topology_integer_hwtcl > 1 } {
            ip_set_param "parameter.core4_1_virtual_link_rate_hwtcl.value" $core4_1_virtual_link_rate_hwtcl
            ip_set_param "parameter.core4_1_virtual_link_width_hwtcl.value" $core4_1_virtual_link_width_hwtcl
        }
        
        if { ${core4_1_func} == "Disable" } {
            ip_set_param "parameter.core4_1_virtual_link_rate_hwtcl.value" "Gen1 (2.5 Gbps)"
            ip_set_param "parameter.core4_1_virtual_link_width_hwtcl.value" "x1"
            ip_set_param "parameter.core4_1_pf0_auto_lane_flip_ctrl_en_hwtcl.value" 0
        } else {
            ip_set_param "parameter.core4_1_pf0_auto_lane_flip_ctrl_en_hwtcl.value" 1
        }
    } elseif { $tile == "F-TILE" } {
        set core4_1_topology_integer_hwtcl [ip_get "parameter.core4_1_topology_integer_hwtcl.value"]
        set core4_1_func [ip_get "parameter.core4_1_func_mode_hwtcl.value"]
        
        if {  [regexp "Gen4" $PROP_VALUE] } {
            set core4_1_virtual_link_rate_hwtcl "Gen4 (16.0 Gbps)"
        } elseif { [regexp "Gen3" $PROP_VALUE] } {
            # "Gen3 (8.0 Gbps)"
            set core4_1_virtual_link_rate_hwtcl "Gen3 (8.0 Gbps)"
        } else {
            send_message error "Topology is not set"
        }
        
        
        if { [regexp "4x4" $PROP_VALUE] } {
            set core4_1_virtual_link_width_hwtcl "x4"
            #send_message info "Four x4 PCIe ports will be instantiated."
        } else {
            #send_message error "Topology is not set"
        }
        if {$core4_1_func_mode_integer_hwtcl == 1 } {
            ip_set_param "parameter.core4_1_virtual_link_rate_hwtcl.value" $core4_1_virtual_link_rate_hwtcl
            ip_set_param "parameter.core4_1_virtual_link_width_hwtcl.value" $core4_1_virtual_link_width_hwtcl
        }
        
        if { ${core4_1_func} == "Disable" } {
            ip_set_param "parameter.core4_1_virtual_link_rate_hwtcl.value" "Gen1 (2.5 Gbps)"
            ip_set_param "parameter.core4_1_virtual_link_width_hwtcl.value" "x1"
            ip_set_param "parameter.core4_1_pf0_auto_lane_flip_ctrl_en_hwtcl.value" 0
        } else {
            ip_set_param "parameter.core4_1_pf0_auto_lane_flip_ctrl_en_hwtcl.value" 1
        }
    } elseif { $tile == "R-TILE" } {
   if { ${core4_1_func_mode_hwtcl} == "Disable" } {
        ip_set_param "parameter.core4_1_virtual_link_rate_hwtcl.value" "Gen1 (2.5 Gbps)"
        ip_set_param "parameter.core4_1_virtual_link_width_hwtcl.value" "x1"
        ip_set_param "parameter.core4_1_pf0_auto_lane_flip_ctrl_en_hwtcl.value" 0
    } else {
		if {  [regexp "Gen5" $PROP_VALUE] } {
			set core4_1_virtual_link_rate_hwtcl "Gen5 (32.0 Gbps)"
		} elseif {  [regexp "Gen4" $PROP_VALUE] } {
			set core4_1_virtual_link_rate_hwtcl "Gen4 (16.0 Gbps)"
		} elseif { [regexp "Gen3" $PROP_VALUE] } {
			# "Gen3 (8.0 Gbps)"
			set core4_1_virtual_link_rate_hwtcl "Gen3 (8.0 Gbps)"
		} else {
			send_message error "Topology is not set"
		}
		ip_set_param "parameter.core4_1_virtual_link_rate_hwtcl.value" $core4_1_virtual_link_rate_hwtcl
		
		if { [regexp "1x16" $PROP_VALUE] } {
			set core4_1_virtual_link_width_hwtcl "x16"
			send_message info "One x16 PCIe ports will be instantiated."
		} elseif { [regexp "2x8" $PROP_VALUE] } {
			set core4_1_virtual_link_width_hwtcl "x8"
			send_message info "Two x8 PCIe ports will be instantiated."
		} elseif { [regexp "4x4" $PROP_VALUE] } {
			set core4_1_virtual_link_width_hwtcl "x4"
			send_message info "Four x4 PCIe ports will be instantiated."
		} elseif { [regexp "Pipe Direct 8-channel" $PROP_VALUE] && [regexp "2x4" $PROP_VALUE] } { #topology 8a
			set core4_1_virtual_link_width_hwtcl "x4"
			send_message info "Two x4 PCIe ports will be instantiated."
		} elseif { [regexp "1x8" $PROP_VALUE] && [regexp "2x4" $PROP_VALUE] } { #topology 3
			set core4_1_virtual_link_width_hwtcl "x8"
			send_message info "One x8 and two x4 PCIe ports will be instantiated."
		} elseif { [regexp "Pipe Direct 8-channel" $PROP_VALUE] && [regexp "1x8" $PROP_VALUE] } { #topology 7a
			set core4_1_virtual_link_width_hwtcl "x8"
			send_message info "One x8 PCIe ports will be instantiated."
		} else {
			send_message error "Topology is not set"
		}
		ip_set_param "parameter.core4_1_virtual_link_width_hwtcl.value" $core4_1_virtual_link_width_hwtcl
		ip_set_param "parameter.core4_1_pf0_auto_lane_flip_ctrl_en_hwtcl.value" 1
      } 
   }

}
proc ::intel_pcie_ss_axi::parameters::validate_core4_1_virtual_cvp_mode_hwtcl { PROP_NAME PROP_VALUE core4_1_func_mode_hwtcl qhip_silicon_reva_revb_hwtcl hssi_ctr_is_cvp_enable_hwtcl core4_1_enable_power_mgnt_intf_hwtcl core4_1_virtual_rp_ep_mode_hwtcl core4_1_virtual_tlp_bypass_en_hwtcl} {
	#1409800040 1508297559 1508323145 1508912543 1508933505
	if { $core4_1_func_mode_hwtcl == "Disable" || $hssi_ctr_is_cvp_enable_hwtcl == 0} {
		ip_set_param "parameter.core4_1_virtual_cvp_mode_hwtcl.value" "cvp_disabled"
	} else {
		ip_set_param "parameter.core4_1_virtual_cvp_mode_hwtcl.value" "cvp_legacy"
		#send_message info "Enabling CVP automatically disables PCIe 0 Configuration Intercept Interface (CII), VIRTIO and Vendor Specific Extended capability."
		if {$core4_1_enable_power_mgnt_intf_hwtcl == 1 &&  $core4_1_virtual_rp_ep_mode_hwtcl == "Native Endpoint" && $core4_1_virtual_tlp_bypass_en_hwtcl == 0} {
			send_message info "p0_app_req_retry_en_i must be tied off to zero when enabling CVP."
		}
	}
}

proc ::intel_pcie_ss_axi::parameters::validate_core4_1_virtual_rp_ep_mode_hwtcl { PROP_NAME PROP_VALUE core4_1_topology_hwtcl } {
    # if { $PROP_VALUE == "Root Port"  } {
    #     if { [regexp "x8" $core4_1_topology_hwtcl] || [regexp "x16" $core4_1_topology_hwtcl] } {
    #         send_message error "Root Port mode is only supported with x4 PCIe IP. To use Root Port mode with other link width, please add adapters accordingly."
    #     }
    # }
    set core4_1_tlp_bypass_en [ip_get "parameter.core4_1_virtual_tlp_bypass_en_hwtcl.value"]
    if { $PROP_VALUE == "Native Endpoint"  } {
        if { [regexp "x4" $core4_1_topology_hwtcl]  } {
            if { ${core4_1_tlp_bypass_en} == "Disable" } {
                send_message error "Endpoint mode is only supported with x8/x16 PCIe IP. Endpoint x4 configuration is only supported when TLP Bypass is enabled."
            }
        }
    }
}
proc ::intel_pcie_ss_axi::parameters::validate_core4_1_crs_en_default_hwtcl { PROP_NAME PROP_VALUE } {
        switch $PROP_VALUE {
           0            { set idw_value 0 }
           1            { set idw_value 1 }
        }
        if { $PROP_NAME == "core4_1_crs_en_default_hwtcl"} {
            ip_set_param "parameter.core4_1_CRS_EN_DEFAULT.value" $idw_value
        }
        
}

proc ::intel_pcie_ss_axi::parameters::validate_core4_1_enable_rx_buffer_limit_ports_hwtcl   { PROP_NAME PROP_VALUE core4_1_func_mode_hwtcl avmm_enabled_hwtcl} {
  
  set pcie_ss_func_mode_value         [ip_get "parameter.pcie_ss_func_mode_hwtcl.value"]
    if { $pcie_ss_func_mode_value == "Power User"} {   
        ip_set_param "parameter.core4_1_enable_rx_buffer_limit_ports_hwtcl.value" 0
        ip_set_param "parameter.core4_1_rxbuf_limit_posted_bypass_hwtcl.value"    0
        ip_set_param "parameter.core4_1_rxbuf_limit_nonposted_bypass_hwtcl.value" 0
        ip_set_param "parameter.core4_1_rxbuf_limit_cpl_bypass_hwtcl.value" 0

    if { $avmm_enabled_hwtcl } {
        ip_set_param "parameter.core4_1_rxbuf_limit_bypass_hwtcl.value" 0
    } else {    
      if { ($PROP_VALUE == 1) } {
        ip_set_param "parameter.core4_1_rxbuf_limit_bypass_hwtcl.value" 0
      } else {
        ip_set_param "parameter.core4_1_rxbuf_limit_bypass_hwtcl.value" 1
      }
     } 
    } else {
        ip_set_param "parameter.core4_1_enable_rx_buffer_limit_ports_hwtcl.value" 1
        ip_set_param "parameter.core4_1_rxbuf_limit_posted_bypass_hwtcl.value"    0
        ip_set_param "parameter.core4_1_rxbuf_limit_nonposted_bypass_hwtcl.value" 0
        ip_set_param "parameter.core4_1_rxbuf_limit_cpl_bypass_hwtcl.value" 1

      if { $avmm_enabled_hwtcl } {
        ip_set_param "parameter.core4_1_rxbuf_limit_bypass_hwtcl.value" 0
    } else {    
      if { ($PROP_VALUE == 1) } {
        ip_set_param "parameter.core4_1_rxbuf_limit_bypass_hwtcl.value" 0
      } else {
        ip_set_param "parameter.core4_1_rxbuf_limit_bypass_hwtcl.value" 1
      }
    }
  }
}

proc ::intel_pcie_ss_axi::parameters::validate_core4_1_rxbuf_limit_bypass_hwtcl { PROP_NAME PROP_VALUE core4_1_enable_rx_buffer_limit_ports_hwtcl avmm_enabled_hwtcl core4_1_rxbuf_limit_posted_bypass_hwtcl core4_1_rxbuf_limit_nonposted_bypass_hwtcl core4_1_rxbuf_limit_cpl_bypass_hwtcl } {
    set core4_1_func [ip_get "parameter.core4_1_func_mode_hwtcl.value"]
    set rxbuf_features_enablement [ip_get "parameter.rxbuf_features_enablement_full.value"]
    if { $avmm_enabled_hwtcl } {
        ip_set_param "parameter.core4_1_rxbuf_limit_bypass_hwtcl.value" "disable bypass"
    } else {
        if { ($rxbuf_features_enablement == 1) } {
            if { ($core4_1_enable_rx_buffer_limit_ports_hwtcl == 1 ) } {
                if {$core4_1_rxbuf_limit_posted_bypass_hwtcl==0 && $core4_1_rxbuf_limit_nonposted_bypass_hwtcl==0 && $core4_1_rxbuf_limit_cpl_bypass_hwtcl==0} {
                    ip_set_param "parameter.core4_1_rxbuf_limit_bypass_hwtcl.value" "disable bypass"
                } elseif {$core4_1_rxbuf_limit_posted_bypass_hwtcl==1 && $core4_1_rxbuf_limit_nonposted_bypass_hwtcl==0 && $core4_1_rxbuf_limit_cpl_bypass_hwtcl==0} {
                    ip_set_param "parameter.core4_1_rxbuf_limit_bypass_hwtcl.value" "posted bypass"
                } elseif {$core4_1_rxbuf_limit_posted_bypass_hwtcl==0 && $core4_1_rxbuf_limit_nonposted_bypass_hwtcl==1 && $core4_1_rxbuf_limit_cpl_bypass_hwtcl==0} {
                    ip_set_param "parameter.core4_1_rxbuf_limit_bypass_hwtcl.value" "nonposted bypass"
                } elseif {$core4_1_rxbuf_limit_posted_bypass_hwtcl==1 && $core4_1_rxbuf_limit_nonposted_bypass_hwtcl==1 && $core4_1_rxbuf_limit_cpl_bypass_hwtcl==0} {
                    ip_set_param "parameter.core4_1_rxbuf_limit_bypass_hwtcl.value" "posted / nonposted bypass"
                } elseif {$core4_1_rxbuf_limit_posted_bypass_hwtcl==0 && $core4_1_rxbuf_limit_nonposted_bypass_hwtcl==0 && $core4_1_rxbuf_limit_cpl_bypass_hwtcl==1} {
                    ip_set_param "parameter.core4_1_rxbuf_limit_bypass_hwtcl.value" "cpl bypass"
                } elseif {$core4_1_rxbuf_limit_posted_bypass_hwtcl==1 && $core4_1_rxbuf_limit_nonposted_bypass_hwtcl==0 && $core4_1_rxbuf_limit_cpl_bypass_hwtcl==1} {
                    ip_set_param "parameter.core4_1_rxbuf_limit_bypass_hwtcl.value" "posted / cpl bypass"
                } elseif {$core4_1_rxbuf_limit_posted_bypass_hwtcl==0 && $core4_1_rxbuf_limit_nonposted_bypass_hwtcl==1 && $core4_1_rxbuf_limit_cpl_bypass_hwtcl==1} {
                    ip_set_param "parameter.core4_1_rxbuf_limit_bypass_hwtcl.value" "nonposted / cpl bypass"
                } else {
                    send_message error "Disabling PCIe3 Rx Buffer Limit Ports will automatically bypass Posted, Non-Posted and CplD Packets."
                    #ip_set_param "parameter.core4_1_rxbuf_limit_bypass_hwtcl.value" "posted / nonposted / cpl bypass"
                }
            } elseif {$core4_1_func == "Disable"} {
                ip_set_param "parameter.core4_1_rxbuf_limit_bypass_hwtcl.value" "disable bypass"
            } else {
                ip_set_param "parameter.core4_1_rxbuf_limit_bypass_hwtcl.value" "posted / nonposted / cpl bypass"
            }
        } else {
            if { ($core4_1_enable_rx_buffer_limit_ports_hwtcl == 1 ) } {
                ip_set_param "parameter.core4_1_rxbuf_limit_bypass_hwtcl.value" "disable bypass"
            } elseif {$core4_1_func == "Disable"} {
                ip_set_param "parameter.core4_1_rxbuf_limit_bypass_hwtcl.value" "disable bypass"
            } else {
                ip_set_param "parameter.core4_1_rxbuf_limit_bypass_hwtcl.value" "posted / nonposted / cpl bypass"
            }
        }
    }
}
######cap parameter validation callbacks
proc ::intel_pcie_ss_axi::parameters::validate_core4_1_virtual_pf0_dlink_cap_enable_hwtcl { PROP_NAME PROP_VALUE } {
    set core4_1_func [ip_get "parameter.core4_1_func_mode_hwtcl.value"]
    if { ${core4_1_func} == "Enable" } {
        ip_set_param "parameter.core4_1_virtual_pf0_dlink_cap_enable_hwtcl.value" 1
    } else {
        ip_set_param "parameter.core4_1_virtual_pf0_dlink_cap_enable_hwtcl.value" 0
    }
}
proc ::intel_pcie_ss_axi::parameters::validate_core4_1_virtual_maxpayload_size_hwtcl { PROP_NAME PROP_VALUE core4_1_func_mode_hwtcl } {
    set core4_1_func [ip_get "parameter.core4_1_func_mode_hwtcl.value"]
    if { ${core4_1_func} == "Enable" } {
        ip_set_param "parameter.core4_1_maxpayload_size_hwtcl.value" $PROP_VALUE
    } else {
        ip_set_param "parameter.core4_1_maxpayload_size_hwtcl.value" 128
    }
}
proc ::intel_pcie_ss_axi::parameters::validate_core4_1_cap_ext_tag_supp_user_hwtcl { PROP_NAME PROP_VALUE  } {
    set core4_1_func_mode [ip_get "parameter.core4_1_func_mode_hwtcl.value"]
    if { $core4_1_func_mode == "Disable" } {
        ip_set_param "parameter.core4_1_pf0_pcie_cap_ext_tag_supp_hwtcl.value" 0
    } else {
        ip_set_param "parameter.core4_1_pf0_pcie_cap_ext_tag_supp_hwtcl.value" $PROP_VALUE
    }
}
proc ::intel_pcie_ss_axi::parameters::validate_core4_1_flr_cap_user_hwtcl { PROP_NAME PROP_VALUE core4_1_virtual_rp_ep_mode_integer_hwtcl core4_1_virtual_tlp_bypass_en_hwtcl } {
    if { $core4_1_virtual_rp_ep_mode_integer_hwtcl || $core4_1_virtual_tlp_bypass_en_hwtcl == 1 } {
        ip_set_param "parameter.core4_1_flr_cap_hwtcl.value" 0
    }
    set core4_1_flr_cap_hwtcl [ip_get "parameter.core4_1_flr_cap_hwtcl.value"]
    for {set i 0} { $i < 1 } {incr i} {
        set core4_1_virtual_pfi_enable_hwtcl [ip_get "parameter.core4_1_virtual_pf${i}_enable_hwtcl.value"]
        if { $core4_1_virtual_pfi_enable_hwtcl == 1 } {
            ip_set_param "parameter.core4_1_pf${i}_pcie_cap_flr_cap_hwtcl.value" $core4_1_flr_cap_hwtcl
        } else {
            ip_set_param "parameter.core4_1_pf${i}_pcie_cap_flr_cap_hwtcl.value" 0
        }
    }
}
proc ::intel_pcie_ss_axi::parameters::validate_core4_1_user_vsec_cap_enable_hwtcl { PROP_NAME PROP_VALUE   } {
    set tile [ip_get "parameter.TILE.value"]

    if { $tile == "P-TILE" ||$tile=="R-TILE" } {
        for {set i 0} { $i < 1 } {incr i} {
            set core4_1_func_mode [ip_get "parameter.core4_1_func_mode_hwtcl.value"]
            if { $core4_1_func_mode == "Enable" } {
                ip_set_param "parameter.core4_1_virtual_pf${i}_user_vsec_cap_enable_hwtcl.value" $PROP_VALUE
            } else {
                ip_set_param "parameter.core4_1_virtual_pf${i}_user_vsec_cap_enable_hwtcl.value" 0
            }
        }
    } elseif { $tile == "F-TILE" } {
        for {set i 0} { $i < 1 } {incr i} {
            set core4_1_virtual_pfi_enable_hwtcl [ip_get "parameter.core4_1_virtual_pf${i}_enable_hwtcl.value"]
            if { $core4_1_virtual_pfi_enable_hwtcl == 1 } {
                ip_set_param "parameter.core4_1_virtual_pf${i}_user_vsec_cap_enable_hwtcl.value" $PROP_VALUE
            } else {
                ip_set_param "parameter.core4_1_virtual_pf${i}_user_vsec_cap_enable_hwtcl.value" 0
            }
        }
    }
}
proc ::intel_pcie_ss_axi::parameters::validate_core4_1_user_vsec_cap_enable_offset_hwtcl {core4_1_user_vsec_cap_enable_hwtcl  core4_1_virtual_pf0_enable_hwtcl } { #ARG: core4_1_virtual_pf0_enable_hwtcl
    if { ${core4_1_virtual_pf0_enable_hwtcl} == 1 } {
        ip_set_param "parameter.core4_1_virtual_pf0_user_vsec_cap_enable_hwtcl.value" $core4_1_user_vsec_cap_enable_hwtcl
				
    } else {
        ip_set_param "parameter.core4_1_virtual_pf0_user_vsec_cap_enable_hwtcl.value" 0
    }
	if {$core4_1_user_vsec_cap_enable_hwtcl == 1} {
		ip_set_param "parameter.core4_1_virtio_cii_ctrl_k_cii_en_hwtcl.value" 1
	}
}

proc ::intel_pcie_ss_axi::parameters::validate_core4_1_pf0_pcie_cap_port_num_hwtcl { PROP_NAME PROP_VALUE core4_1_func_mode_hwtcl } {
    set core4_1_func [ip_get "parameter.core4_1_func_mode_hwtcl.value"]
    if { ${core4_1_func} == "Enable" } {
        ip_set_param "parameter.core4_1_cap_port_num_hwtcl.value" $PROP_VALUE
    } else {
        ip_set_param "parameter.core4_1_cap_port_num_hwtcl.value" 0
    }
}
proc ::intel_pcie_ss_axi::parameters::validate_core4_1_user_pcie_cap_slot_clk_config_hwtcl { PROP_NAME PROP_VALUE core4_1_func_mode_hwtcl } {
    set core4_1_func [ip_get "parameter.core4_1_func_mode_hwtcl.value"]
    set virtual_sris_enable_en_hwtcl [ip_get "parameter.virtual_sris_enable_en_hwtcl.value"]
    if { ${core4_1_func} == "Enable" && $virtual_sris_enable_en_hwtcl == 0 } {
        ip_set_param "parameter.core4_1_user_pcie_cap_slot_clk_config_hwtcl.value" $PROP_VALUE
    } else {
        ip_set_param "parameter.core4_1_user_pcie_cap_slot_clk_config_hwtcl.value" 0
    }
}
proc ::intel_pcie_ss_axi::parameters::validate_core4_1_virtual_pfi_msi_enable_hwtcl { PROP_NAME PROP_VALUE  core4_1_virtual_rp_ep_mode_hwtcl } {
     set tile [ip_get "parameter.TILE.value"]
      if { $tile == "P-TILE" ||$tile =="F-TILE" } {
        for {set i 0} { $i < 1 } {incr i} {
        set core4_1_virtual_pfi_enable_hwtcl [ip_get "parameter.core4_1_virtual_pf${i}_enable_hwtcl.value"]
        if { $core4_1_virtual_pfi_enable_hwtcl == 1 } {
            set core4_1_virtual_pfi_msi_enable_user_hwtcl "parameter.core4_1_virtual_pf${i}_msi_enable_user_hwtcl"
            ip_set_param "parameter.core4_1_virtual_pf${i}_user_vsec_cap_enable_hwtcl.value" $core4_1_virtual_pfi_msi_enable_user_hwtcl
        } else {
            ip_set_param "parameter.core4_1_virtual_pf${i}_user_vsec_cap_enable_hwtcl.value" 0
        }
    }
    } elseif {$tile =="R-TILE" } {
     
    set msi_interface_enable 0

    set core4_1_virtual_pfi_enable_hwtcl [ip_get "parameter.core4_1_virtual_pf0_enable_hwtcl.value"]
    if { $core4_1_virtual_pfi_enable_hwtcl == 1 } {
		if { [get_parameter_value core4_1_pf0_virtio_capability_present_hwtcl] } {
			if { [get_parameter_value core4_1_virtual_pf0_msi_enable_hwtcl] } {
				ip_set_param "parameter.core4_1_virtual_pf0_msi_enable_hwtcl.value" 0
			}
			if { [get_parameter_value core4_1_virtual_pf0_msi_enable_user_hwtcl]} {
				send_message info "Enabling VIRTIO automatically disables MSI. (PCIe3 PF0)"
			}
		} else {
			set core4_1_virtual_pfi_msi_enable_user_hwtcl [get_parameter_value core4_1_virtual_pf0_msi_enable_user_hwtcl]
			ip_set_param "parameter.core4_1_virtual_pf0_msi_enable_hwtcl.value" $core4_1_virtual_pfi_msi_enable_user_hwtcl
			if { $core4_1_virtual_pfi_msi_enable_user_hwtcl == 1} {
				set msi_interface_enable 1
			}
		}
    } else {
		ip_set_param "parameter.core4_1_virtual_pf0_msi_enable_hwtcl.value" 0
    }
       
    #disable MSI in Root Port Mode
    if { $core4_1_virtual_rp_ep_mode_hwtcl == "Root Port" } {
        ip_set_param "parameter.core4_1_enable_msi_interface_hwtcl.value" 0
    } else {
        ip_set_param "parameter.core4_1_enable_msi_interface_hwtcl.value" $msi_interface_enable
    }
  }

}
proc ::intel_pcie_ss_axi::parameters::validate_core4_1_virtual_pfi_msix_enable_hwtcl { PROP_NAME PROP_VALUE core4_1_total_pf_count_hwtcl core4_1_virtual_rp_ep_mode_hwtcl } {
    set tile [ip_get "parameter.TILE.value"]

    if { $tile == "P-TILE" } {
        for { set i 0 } { $i < 8 } { incr i } {
            if { [get_parameter_value core4_1_virtual_pf${i}_enable_hwtcl] } {
                if { [get_parameter_value core4_1_pf${i}_virtio_capability_present_hwtcl] || [get_parameter_value core4_1_pf${i}vf_virtio_capability_present_hwtcl] } {
                    if { ![get_parameter_value core4_1_virtual_pf${i}_msix_enable_hwtcl] } {
                        send_message info "Enabling VIRTIO automatically enables MSI-X. (PCIe3 PF{$i})"
                        ip_set_param "parameter.core4_1_virtual_pf${i}_msix_enable_hwtcl.value" 1
                    }
                } else {
                    ip_set_param "parameter.core4_1_virtual_pf${i}_msix_enable_hwtcl.value" [get_parameter_value core4_1_virtual_pf${i}_msix_enable_user_hwtcl]
                }
            } else {
                ip_set_param "parameter.core4_1_virtual_pf${i}_msix_enable_hwtcl.value" 0
            }
        }
    } elseif { $tile == "F-TILE" || $tile == "R-TILE" } {
        regexp {pf.} $PROP_NAME i
        set pf_num [regexp -all -inline -- {[0-9]+} $i]
        
            if { [get_parameter_value core4_1_virtual_pf${pf_num}_enable_hwtcl] } {
                if { [get_parameter_value core4_1_pf${pf_num}_virtio_capability_present_hwtcl] || [get_parameter_value core4_1_pf${pf_num}vf_virtio_capability_present_hwtcl] } {
                    if { ![get_parameter_value core4_1_virtual_pf${pf_num}_msix_enable_hwtcl] } {
                        ip_set_param "parameter.core4_1_virtual_pf${pf_num}_msix_enable_hwtcl.value" 1
                    }
    		if { ![get_parameter_value core4_1_virtual_pf${pf_num}_msix_enable_user_hwtcl]} {
                        send_message info "Enabling VIRTIO automatically enables MSI-X. (PCIe3 PF{${pf_num}})"
                    }
                } else {
                    ip_set_param "parameter.core4_1_virtual_pf${pf_num}_msix_enable_hwtcl.value" [get_parameter_value core4_1_virtual_pf${pf_num}_msix_enable_user_hwtcl]
                }
            } else {
                ip_set_param "parameter.core4_1_virtual_pf${pf_num}_msix_enable_hwtcl.value" 0
            }
     
    }
}


########soft_ip parameter call backs###########
proc ::intel_pcie_ss_axi::parameters::validate_core4_1_hip_reconfig_hwtcl { PROP_NAME PROP_VALUE core4_1_virtual_rp_ep_mode_integer_hwtcl core4_1_topology_integer_hwtcl total_core_num_hwtcl core4_1_virtual_tlp_bypass_en_hwtcl} {
    set tile [ip_get "parameter.TILE.value"]

    if { $tile == "P-TILE" } {
    
        set core4_1_hip_reconfig_user_hwtcl [get_parameter_value core4_1_hip_reconfig_user_hwtcl]
        if {$core4_1_hip_reconfig_user_hwtcl == 0 && $core4_1_topology_integer_hwtcl > 1 && $total_core_num_hwtcl > 3 && $core4_1_virtual_tlp_bypass_en_hwtcl == 1} {
            send_message info "PCIe 3: HIP reconfiguration automatically enabled in TLP Bypass mode."
            ip_set_param "parameter.core4_1_hip_reconfig_user_hwtcl.ENABLED" false
            ip_set_param "parameter.core4_1_hip_reconfig_user_hwtcl.VISIBLE" false
            ip_set_param "parameter.core4_1_hip_reconfig_hwtcl.value" 1
        } elseif {$core4_1_hip_reconfig_user_hwtcl == 0 && $core4_1_topology_integer_hwtcl > 1 && $total_core_num_hwtcl > 3 && $core4_1_virtual_rp_ep_mode_integer_hwtcl == 1} {
            send_message info "PCIe 3: HIP reconfiguration automatically enabled in Root Port mode."
            ip_set_param "parameter.core4_1_hip_reconfig_user_hwtcl.ENABLED" false
            ip_set_param "parameter.core4_1_hip_reconfig_user_hwtcl.VISIBLE" false
            ip_set_param "parameter.core4_1_hip_reconfig_hwtcl.value" 1
        } else {
            ip_set_param "parameter.core4_1_hip_reconfig_hwtcl.value" $core4_1_hip_reconfig_user_hwtcl
        }
    }  elseif { $tile =="R-TILE" } {
        set core4_1_hip_reconfig_user_hwtcl [get_parameter_value core4_1_hip_reconfig_user_hwtcl]
    if {$core4_1_hip_reconfig_user_hwtcl == 0 && $core4_1_virtual_tlp_bypass_en_hwtcl == 1} {
		send_message info "PCIe 2: HIP reconfiguration automatically enabled in TLP Bypass mode."
		ip_set_param "parameter.core4_1_hip_reconfig_hwtcl.value" 1
    } elseif {$core4_1_hip_reconfig_user_hwtcl == 0 && $core4_1_virtual_rp_ep_mode_integer_hwtcl == 1} {
		send_message info "PCIe 2: HIP reconfiguration automatically enabled in Root Port mode."
		ip_set_param "parameter.core4_1_hip_reconfig_hwtcl.value" 1
    } else {
		# else set param from user hwtcl
		ip_set_param "parameter.core4_1_hip_reconfig_hwtcl.value" $core4_1_hip_reconfig_user_hwtcl
    }
    }  elseif { $tile == "F-TILE" } {
        set core4_1_hip_reconfig_user_hwtcl [get_parameter_value core4_1_hip_reconfig_user_hwtcl]
        set debug_toolkit_en    [get_parameter_value ftile_debug_toolkit_hwtcl]
        set pcs_config_en       [get_parameter_value PCS_CONFIG_EN]
    
        if {$pcs_config_en} {
            ip_set_param "parameter.core4_1_hip_reconfig_hwtcl.value" 1
            ip_set_param "parameter.core4_1_hip_reconfig_user_hwtcl.ENABLED" false
            ip_set_param "parameter.core4_1_hip_reconfig_user_hwtcl.VISIBLE" false
        } elseif {$core4_1_hip_reconfig_user_hwtcl == 0 && $core4_1_func_mode_integer_hwtcl == 1 && $core4_1_virtual_tlp_bypass_en_hwtcl == 1} {
            send_message info "PCIe 3: HIP reconfiguration automatically enabled in TLP Bypass mode."
            ip_set_param "parameter.core4_1_hip_reconfig_user_hwtcl.ENABLED" false
            ip_set_param "parameter.core4_1_hip_reconfig_user_hwtcl.VISIBLE" false
            ip_set_param "parameter.core4_1_hip_reconfig_hwtcl.value" 1
        } elseif {$core4_1_hip_reconfig_user_hwtcl == 0 && $core4_1_func_mode_integer_hwtcl == 1 && $core4_1_virtual_rp_ep_mode_integer_hwtcl == 1} {
            send_message info "PCIe 3: HIP reconfiguration automatically enabled in Root Port mode."
            ip_set_param "parameter.core4_1_hip_reconfig_user_hwtcl.ENABLED" false
            ip_set_param "parameter.core4_1_hip_reconfig_user_hwtcl.VISIBLE" false
            ip_set_param "parameter.core4_1_hip_reconfig_hwtcl.value" 1
        } else {
            ip_set_param "parameter.core4_1_hip_reconfig_hwtcl.value" $core4_1_hip_reconfig_user_hwtcl
        }
    }
}
########identification parameters call back##########
proc ::intel_pcie_ss_axi::parameters::validate_core4_1_pf0_pci_type0_vendor_id_hwtcl { PROP_NAME PROP_VALUE core4_1_func_mode_hwtcl } {
    set core4_1_func [ip_get "parameter.core4_1_func_mode_hwtcl.value"]
    if { ${core4_1_func} == "Enable" } {
        ip_set_param "parameter.core4_1_vendor_id_hwtcl.value" $PROP_VALUE
        send_message info "PCIe3 pf0 IDs: Vendor ID is set to 0x[format %x $PROP_VALUE]. Please set proper value according to user application."
    } else {
        ip_set_param "parameter.core4_1_vendor_id_hwtcl.value" 0
        send_message info "PCIe3 pf0 IDs: Vendor ID is set to 0x[format %x $PROP_VALUE]. Please set proper value according to user application."
    }
}

proc ::intel_pcie_ss_axi::parameters::validate_core4_1_pf0_pci_type0_device_id_info_hwtcl { PROP_NAME PROP_VALUE core4_1_func_mode_hwtcl } {
    set core4_1_func [ip_get "parameter.core4_1_func_mode_hwtcl.value"]
    if { ${core4_1_func} == "Enable" } {
        set core4_1_pf0_pci_type0_device_id_hwtcl [ip_get "parameter.core4_1_pf0_pci_type0_device_id_hwtcl.value"]
        send_message info "PCIe3 pf0 IDs: Device ID is set to 0x[format %x $core4_1_pf0_pci_type0_device_id_hwtcl]. Please set proper value according to user application."
    }
}
proc ::intel_pcie_ss_axi::parameters::validate_core4_1_pf0_revision_id_hwtcl  { PROP_NAME PROP_VALUE core4_1_func_mode_hwtcl } {
    set core4_1_func [ip_get "parameter.core4_1_func_mode_hwtcl.value"]
    if { ${core4_1_func} == "Enable" } {
        ip_set_param "parameter.core4_1_revision_id_hwtcl.value" $PROP_VALUE
        send_message info "PCIe3 pf0 IDs: Revision ID is set to 0x[format %x $PROP_VALUE]. Please set proper value according to user application."
    } else {
        ip_set_param "parameter.core4_1_revision_id_hwtcl.value" 0
        send_message info "PCIe3 pf0 IDs: Revision ID is set to 0x[format %x $PROP_VALUE]. Please set proper value according to user application."
    }
}

proc ::intel_pcie_ss_axi::parameters::validate_core4_1_pf0_class_code_info_hwtcl { PROP_NAME PROP_VALUE core4_1_func_mode_hwtcl } {
    set tile [ip_get "parameter.TILE.value"]

        set core4_1_func [ip_get "parameter.core4_1_func_mode_hwtcl.value"]
        if { ${core4_1_func} == "Enable" } {
            set core4_1_pf0_class_code_hwtcl [ip_get "parameter.core4_1_pf0_class_code_hwtcl.value"]
            send_message info "PCIe3 pf0 IDs: Class code is set to 0x[format %x $core4_1_pf0_class_code_hwtcl]. Please set proper value according to user application."
        }
    
}

proc ::intel_pcie_ss_axi::parameters::validate_core4_1_pfi_base_class_code_hwtcl { PROP_NAME PROP_VALUE core4_1_pf0_class_code_hwtcl core4_1_func_mode_hwtcl} {
    set tile [ip_get "parameter.TILE.value"]
        set core4_1_func [ip_get "parameter.core4_1_func_mode_hwtcl.value"]

        for {set i 0} { $i < 1 } {incr i} {
            set core4_1_pfi_class_code_hwtcl [ip_get "parameter.core4_1_pf${i}_class_code_hwtcl.value"]
            set core4_1_pfi_base_class_code_hwtcl [expr [expr $core4_1_pfi_class_code_hwtcl & 16711680] >> 16]

	    if { $core4_1_func == "Enable" } {
            	ip_set_param "parameter.core4_1_pf${i}_base_class_code_hwtcl.value" $core4_1_pfi_base_class_code_hwtcl
	    } else {
                ip_set_param "parameter.core4_1_pf${i}_base_class_code_hwtcl.value" 0
	    }
        }

}

proc ::intel_pcie_ss_axi::parameters::validate_core4_1_pfi_subclass_code_hwtcl { PROP_NAME PROP_VALUE core4_1_pf0_class_code_hwtcl core4_1_func_mode_hwtcl} {
    set tile [ip_get "parameter.TILE.value"]

        for {set i 0} { $i < 1 } {incr i} {
            set core4_1_pfi_class_code_hwtcl [ip_get "parameter.core4_1_pf${i}_class_code_hwtcl.value"]
            set core4_1_pfi_subclass_code_hwtcl [expr [expr $core4_1_pfi_class_code_hwtcl & 65280] >> 8]
	    if { $core4_1_func_mode_hwtcl == "Enable" } {	    
            	ip_set_param "parameter.core4_1_pf${i}_subclass_code_hwtcl.value" $core4_1_pfi_subclass_code_hwtcl
            } else {
                ip_set_param "parameter.core4_1_pf${i}_subclass_code_hwtcl.value" 0
	    }
        }
}

proc ::intel_pcie_ss_axi::parameters::validate_core4_1_pfi_program_interface_hwtcl { PROP_NAME PROP_VALUE core4_1_pf0_class_code_hwtcl core4_1_func_mode_hwtcl} {
    set tile [ip_get "parameter.TILE.value"]

        for {set i 0} { $i < 1 } {incr i} {
            set core4_1_pfi_class_code_hwtcl [ip_get "parameter.core4_1_pf${i}_class_code_hwtcl.value"]
            set core4_1_pfi_program_interface_hwtcl [expr $core4_1_pfi_class_code_hwtcl & 255]
	    if { $core4_1_func_mode_hwtcl == "Enable" } {	    	    
            	ip_set_param "parameter.core4_1_pf${i}_program_interface_hwtcl.value" $core4_1_pfi_program_interface_hwtcl
	    } else {
	        ip_set_param "parameter.core4_1_pf${i}_program_interface_hwtcl.value" 0
	    }
        }
}
proc ::intel_pcie_ss_axi::parameters::validate_core4_1_pf_bar_type_hwtcl {PROP_NAME PROP_VALUE core4_1_func_mode_hwtcl core4_1_virtual_rp_ep_mode_hwtcl} { #ARG: core4_1_virtual_pf${pf}_enable_hwtcl core4_1_pf${pf}_bar${i}_type_user_hwtcl core4_1_pf${pf}_bar${i}_address_width_user_hwtcl
    set tile [ip_get "parameter.TILE.value"]

    if { $tile == "R-TILE" } {

    if { $core4_1_func_mode_hwtcl == "Disable" || $core4_1_virtual_rp_ep_mode_hwtcl == "Root Port"} {
        # if in rootport or core 16 is disabled set all BAR types to disabled and size to N/A
        # loop through all pf 0-7
        for {set pf 0} {$pf < 1} {incr pf 1} {
            # loop through all bars 0-5
            for {set i 0} {$i <= 5} {incr i 1} {
                ip_set_param "parameter.core4_1_pf${pf}_bar${i}_type_hwtcl.value" "Disabled"
                ip_set_param "parameter.core4_1_pf${pf}_bar${i}_address_width_hwtcl.value" 0
                ip_set_param "parameter.core4_1_pf${pf}_bar${i}_mask_integer_hwtcl.value" 0
            }
        }
    } else {
        # else set them to user_hwtcl values

        # loop through all pf 0-7
        for {set pf 0} {$pf < 1} {incr pf 1} {
            set core4_1_virtual_pfi_enable_hwtcl [ip_get "parameter.core4_1_virtual_pf${pf}_enable_hwtcl.value"]
            if { $core4_1_virtual_pfi_enable_hwtcl == 1} {
			
			
                # loop through all bars 0-5
                set core4_1_prev_bar_type "Disable"
                set core4_1_prev_bar_addr_width 0
                for {set i 0} {$i <= 5} {incr i 1} {
                    set core4_1_pf_bar_type_user_hwtcl [get_parameter_value core4_1_pf${pf}_bar${i}_type_user_hwtcl]
                    set core4_1_pf_bar_address_width_user_hwtcl [get_parameter_value core4_1_pf${pf}_bar${i}_address_width_user_hwtcl]	
					
					#ALLOWED_RANGES
					if {[regexp "64-bit" $core4_1_pf_bar_type_user_hwtcl]} {
						ip_set_param "parameter.core4_1_pf${pf}_bar${i}_address_width_user_hwtcl.ALLOWED_RANGES" {"0:N/A" "8: 256 Bytes - 8 bits" "9: 512 Bytes - 9 bits" "10: 1 KByte - 10 bits" "11: 2 KBytes - 11 bits" "12: 4 KBytes - 12 bits" "13: 8 KBytes - 13 bits" "14: 16 KBytes - 14 bits" "15: 32 KBytes - 15 bits" "16: 64 KBytes - 16 bits" "17: 128 KBytes - 17 bits" "18: 256 KBytes - 18 bits" "19: 512 KBytes - 19 bits" "20: 1 MByte - 20 bits" "21: 2 MBytes - 21 bits" "22: 4 MBytes - 22 bits" "23: 8 MBytes - 23 bits" "24: 16 MBytes - 24 bits" "25: 32 MBytes - 25 bits" "26: 64 MBytes - 26 bits" "27: 128 MBytes - 27 bits" "28: 256 MBytes - 28 bits" "29: 512 MBytes - 29 bits" "30: 1 GByte - 30 bits" "31: 2 GBytes - 31 bits" "32: 4 GBytes - 32 bits" "33: 8 GBytes - 33 bits" "34: 16 GBytes - 34 bits" "35: 32 GBytes - 35 bits" "36: 64 GBytes - 36 bits" "37: 128 GBytes - 37 bits" "38: 256 GBytes - 38 bits" "39: 512 GBytes - 39 bits" "40: 1 TByte - 40 bits" "41: 2 TBytes - 41 bits" "42: 4 TBytes - 42 bits" "43: 8 TBytes - 43 bits" "44: 16 TBytes - 44 bits" "45: 32 TBytes - 45 bits" "46: 64 TBytes - 46 bits" "47: 128 TBytes - 47 bits" "48: 256 TBytes - 48 bits" "49: 512 TBytes - 49 bits" "50: 1 PByte - 50 bits" "51: 2 PBytes - 51 bits" "52: 4 PBytes - 52 bits" "53: 8 PBytes - 53 bits" "54: 16 PBytes - 54 bits" "55: 32 PBytes - 55 bits" "56: 64 PBytes - 56 bits" "57: 128 PBytes - 57 bits" "58: 256 PBytes - 58 bits" "59: 512 PBytes - 59 bits" "60: 1 EByte - 60 bits" "61: 2 EBytes - 61 bits" "62: 4 EBytes - 62 bits" "63: 8 EBytes - 63 bits" "64: 16 EBytes - 64 bits"}
					} elseif {[regexp "32-bit" $core4_1_pf_bar_type_user_hwtcl]} {
						ip_set_param "parameter.core4_1_pf${pf}_bar${i}_address_width_user_hwtcl.ALLOWED_RANGES" {"0:N/A" "8: 256 Bytes - 8 bits" "9: 512 Bytes - 9 bits" "10: 1 KByte - 10 bits" "11: 2 KBytes - 11 bits" "12: 4 KBytes - 12 bits" "13: 8 KBytes - 13 bits" "14: 16 KBytes - 14 bits" "15: 32 KBytes - 15 bits" "16: 64 KBytes - 16 bits" "17: 128 KBytes - 17 bits" "18: 256 KBytes - 18 bits" "19: 512 KBytes - 19 bits" "20: 1 MByte - 20 bits" "21: 2 MBytes - 21 bits" "22: 4 MBytes - 22 bits" "23: 8 MBytes - 23 bits" "24: 16 MBytes - 24 bits" "25: 32 MBytes - 25 bits" "26: 64 MBytes - 26 bits" "27: 128 MBytes - 27 bits" "28: 256 MBytes - 28 bits" "29: 512 MBytes - 29 bits" "30: 1 GByte - 30 bits" "31: 2 GBytes - 31 bits" "32: 4 GBytes - 32 bits"}
					}
	
                    # Need to update to support full 64bit address width
                    if { $i == 0 || $i == 2 || $i == 4} {
                        if { $core4_1_pf_bar_address_width_user_hwtcl >= 32 } {
                            set core4_1_pf_bar_mask 2147483647
                        } elseif { $core4_1_pf_bar_address_width_user_hwtcl == 0 } {
                            set core4_1_pf_bar_mask 0
                        } else {
                            #set core4_1_pf_bar_mask($pf,$i) [expr int(~(0xffffffff << $core4_1_pf_bar_address_width_user_hwtcl($pf,$i)) >> 1 )]
                            set core4_1_pf_bar_mask [expr int( 0x1 << [expr $core4_1_pf_bar_address_width_user_hwtcl -1] ) -1 ]
                        }
                        # no actual 
                        set core4_1_virtual_pf_bar_mask_bit0  "false"
                        set core4_1_prev_bar_type $core4_1_pf_bar_type_user_hwtcl
                        set core4_1_prev_bar_addr_width $core4_1_pf_bar_address_width_user_hwtcl 
                    }
                    
                    if { $i == 1 || $i == 3 || $i == 5} {
                        if { [regexp "64-bit" $core4_1_prev_bar_type] } { 
                            if { $core4_1_prev_bar_addr_width > 33 } {
                                set core4_1_pf_bar_mask [expr int( 0x1 << [expr $core4_1_prev_bar_addr_width - 33] ) -1 ]
                                set core4_1_virtual_pf_bar_mask_bit0  "true"
                            } else {
                                set core4_1_pf_bar_mask 0
                                set core4_1_virtual_pf_bar_mask_bit0  "false"
                            }
                        } elseif { $core4_1_pf_bar_address_width_user_hwtcl == 0 } {
                            set core4_1_pf_bar_mask 0                    
                            set core4_1_virtual_pf_bar_mask_bit0  "false"           
                        } else  {
                            set core4_1_pf_bar_mask [expr int( 0x1 << [expr $core4_1_pf_bar_address_width_user_hwtcl -1] ) -1 ]
                            set core4_1_virtual_pf_bar_mask_bit0  "false"
                        }
						ip_set_param "parameter.core4_1_virtual_pf${pf}_bar${i}_mask_bit0_hwtcl.value" $core4_1_virtual_pf_bar_mask_bit0
                    }

                    ip_set_param "parameter.core4_1_pf${pf}_bar${i}_type_hwtcl.value" $core4_1_pf_bar_type_user_hwtcl
                    ip_set_param "parameter.core4_1_pf${pf}_bar${i}_address_width_hwtcl.value" $core4_1_pf_bar_address_width_user_hwtcl
                    ip_set_param "parameter.core4_1_pf${pf}_bar${i}_mask_integer_hwtcl.value" $core4_1_pf_bar_mask
                }




			} else {
                for {set i 0} {$i <= 5} {incr i 1} {
                    ip_set_param "parameter.core4_1_pf${pf}_bar${i}_type_hwtcl.value" "Disabled"
                    ip_set_param "parameter.core4_1_pf${pf}_bar${i}_address_width_hwtcl.value" 0
                    ip_set_param "parameter.core4_1_pf${pf}_bar${i}_mask_integer_hwtcl.value" 0
                    ip_set_param "parameter.core4_1_virtual_pf${pf}_bar${i}_mask_bit0_hwtcl.value" "false"
                }
            }
        }
    }
  }
}

proc ::intel_pcie_ss_axi::parameters::set_core4_1_parameter_value {parameter_name value} {
    ip_set_param "parameter.$parameter_name.value" $value
}
proc ::intel_pcie_ss_axi::parameters::get_core4_1_parameter_set {parameter_set} {
    return $parameter_set
}
proc ::intel_pcie_ss_axi::parameters::validate_core4_1_virtual_pf0_margin_cap_enable_hwtcl {PROP_NAME PROP_VALUE} {
    set core4_1_func_mode [ip_get "parameter.core4_1_func_mode_hwtcl.value"]
    set core4_1_link_rate [ip_get "parameter.core4_1_virtual_link_rate_hwtcl.value"]

    if { $core4_1_func_mode == "Disable" } {
        ip_set_param "parameter.core4_1_virtual_pf0_margin_cap_enable_hwtcl.value" 0
    } elseif { $core4_1_link_rate == "Gen4 (16.0 Gbps)" } {
        ip_set_param "parameter.core4_1_virtual_pf0_margin_cap_enable_hwtcl.value" 1
    } else {
        ip_set_param "parameter.core4_1_virtual_pf0_margin_cap_enable_hwtcl.value" 0
    }
}

proc ::intel_pcie_ss_axi::parameters::validate_core4_1_virtual_pf0_pl16g_cap_enable_hwtcl {PROP_NAME PROP_VALUE} {
    set core4_1_func_mode [ip_get "parameter.core4_1_func_mode_hwtcl.value"]
    set core4_1_link_rate [ip_get "parameter.core4_1_virtual_link_rate_hwtcl.value"]

    if { $core4_1_func_mode == "Disable" } {
        ip_set_param "parameter.core4_1_virtual_pf0_pl16g_cap_enable_hwtcl.value" 0
    } elseif { $core4_1_link_rate == "Gen4 (16.0 Gbps)" } {
        ip_set_param "parameter.core4_1_virtual_pf0_pl16g_cap_enable_hwtcl.value" 1
    } else {
        ip_set_param "parameter.core4_1_virtual_pf0_pl16g_cap_enable_hwtcl.value" 0
    }
}
proc ::intel_pcie_ss_axi::parameters::validate_core4_1_virtual_ecrc_strip_hwtcl {core4_1_func_mode_hwtcl core4_1_virtual_tlp_bypass_en_hwtcl core4_1_virtual_ecrc_strip_user_hwtcl} {
    set tile [ip_get "parameter.TILE.value"]

    if { $tile == "P-TILE" ||$tile=="R-TILE"} {
        if { $core4_1_func_mode_hwtcl == "Disable" } {
                ip_set_param "parameter.core4_1_virtual_ecrc_strip_hwtcl.value" 0
        } elseif {$core4_1_virtual_tlp_bypass_en_hwtcl} {
                ip_set_param "parameter.core4_1_virtual_ecrc_strip_hwtcl.value" $core4_1_virtual_ecrc_strip_user_hwtcl
        } else {
                ip_set_param "parameter.core4_1_virtual_ecrc_strip_hwtcl.value" 1
        }
    } elseif { $tile == "F-TILE" } {
	if { $core4_1_func_mode_hwtcl == "Disable" } {
		ip_set_param "parameter.core4_1_virtual_ecrc_strip_hwtcl.value" 0
	} elseif {$core4_1_virtual_tlp_bypass_en_hwtcl} {
		ip_set_param "parameter.core4_1_virtual_ecrc_strip_hwtcl.value" $core4_1_virtual_ecrc_strip_user_hwtcl
	} else {
		ip_set_param "parameter.core4_1_virtual_ecrc_strip_hwtcl.value" 1
	}

	set silicon_rev_b0 [get_parameter_value device_revision]
	if { ![regexp "gdrb" $silicon_rev_b0 ]} {
	    ip_set_param "parameter.core4_1_virtual_ecrc_strip_user_hwtcl.VISIBLE" false
	}
    }
}
proc ::intel_pcie_ss_axi::parameters::validate_core4_1_pfi_int_pin_hwtcl {PROP_NAME PROP_VALUE core4_1_enable_multi_func_hwtcl core4_1_total_pf_count_hwtcl  } {
    regexp {pf.} $PROP_NAME pf_num
    set core4_1_virtual_msi_enable_hwtcl [ip_get "parameter.core4_1_virtual_${pf_num}_msi_enable_hwtcl.value"]
    set core4_1_virtual_msix_enable_hwtcl [ip_get "parameter.core4_1_virtual_${pf_num}_msix_enable_hwtcl.value"]
    set core4_1_int_pin_hwtcl [ip_get "parameter.core4_1_${pf_num}_int_pin_hwtcl.value"]

    if {$core4_1_enable_multi_func_hwtcl == 1 && $core4_1_total_pf_count_hwtcl > 1} {
        ip_set "parameter.core4_1_${pf_num}_int_pin_hwtcl.ALLOWED_RANGES" {"NO INT" "INTA" "INTB" "INTC" "INTD"}
    } else {
        ip_set "parameter.core4_1_${pf_num}_int_pin_hwtcl.ALLOWED_RANGES" {"NO INT" "INTA"}
    }

    #Rule: Enable Legacy Interrupt must enable MSI or MSIX
    if {[expr {$core4_1_int_pin_hwtcl != "NO INT"} ] && $core4_1_virtual_msi_enable_hwtcl ==0 && $core4_1_virtual_msix_enable_hwtcl == 0} {
        send_message error "When Legacy interrupts are enabled for PCIe3 ${pf_num}, either MSI or MISX or both must be enabled for ${pf_num}"
    }
}

proc ::intel_pcie_ss_axi::parameters::validate_core4_1_pf_pme_support_hwtcl {PROP_NAME PROP_VALUE core4_1_func_mode_hwtcl } {
   set core4_1_func_mode [ip_get "parameter.core4_1_func_mode_hwtcl.value"]
   if { $core4_1_func_mode == "Enable" } {
      ip_set_param "parameter.${PROP_NAME}.value" 15
   }
}
#  ACS cap validation start
proc ::intel_pcie_ss_axi::parameters::validate_core4_1_pf0_acs_cap_acs_src_valid_hwtcl {PROP_NAME PROP_VALUE} {
    set core4_1_func_mode [ip_get "parameter.core4_1_func_mode_hwtcl.value"]
    set core4_1_virtual_rp_ep_mode_integer_hwtcl [ip_get "parameter.core4_1_virtual_rp_ep_mode_integer_hwtcl.value"]
    set core4_1_virtual_pf0_acs_cap_enable_hwtcl [ip_get "parameter.core4_1_virtual_pf0_acs_cap_enable_hwtcl.value"]

    # enable for root port
    if { $core4_1_func_mode == "Enable" && $core4_1_virtual_rp_ep_mode_integer_hwtcl == 1 && $core4_1_virtual_pf0_acs_cap_enable_hwtcl == 1} {
        ip_set_param "parameter.${PROP_NAME}.value" 1
    } else {
        ip_set_param "parameter.${PROP_NAME}.value" 0
    }
}

proc ::intel_pcie_ss_axi::parameters::validate_core4_1_pf0_acs_cap_acs_at_block_hwtcl {PROP_NAME PROP_VALUE} {
    set core4_1_func_mode [ip_get "parameter.core4_1_func_mode_hwtcl.value"]
    set core4_1_virtual_rp_ep_mode_integer_hwtcl [ip_get "parameter.core4_1_virtual_rp_ep_mode_integer_hwtcl.value"]
    set core4_1_virtual_pf0_acs_cap_enable_hwtcl [ip_get "parameter.core4_1_virtual_pf0_acs_cap_enable_hwtcl.value"]

    # enable for root port
    if { $core4_1_func_mode == "Enable" && $core4_1_virtual_rp_ep_mode_integer_hwtcl == 1 && $core4_1_virtual_pf0_acs_cap_enable_hwtcl == 1} {
        ip_set_param "parameter.${PROP_NAME}.value" 1
    } else {
        ip_set_param "parameter.${PROP_NAME}.value" 0
    }
}

proc ::intel_pcie_ss_axi::parameters::validate_core4_1_pf0_acs_cap_acs_p2p_req_redirect_hwtcl {PROP_NAME PROP_VALUE} {
    set core4_1_func_mode [ip_get "parameter.core4_1_func_mode_hwtcl.value"]
    set core4_1_virtual_rp_ep_mode_integer_hwtcl [ip_get "parameter.core4_1_virtual_rp_ep_mode_integer_hwtcl.value"]

    set core4_1_pf0_acs_cap_peer_to_peer_traffic_supp_hwtcl [ip_get "parameter.core4_1_pf0_acs_cap_peer_to_peer_traffic_supp_hwtcl.value"]
    set core4_1_virtual_pf0_acs_cap_enable_hwtcl [ip_get "parameter.core4_1_virtual_pf0_acs_cap_enable_hwtcl.value"]

    # set to same as peer to peer traffic if core enabled and acs is enabled
    if { $core4_1_func_mode == "Enable" && $core4_1_virtual_pf0_acs_cap_enable_hwtcl == 1 && $core4_1_virtual_rp_ep_mode_integer_hwtcl } {
        ip_set_param "parameter.${PROP_NAME}.value" $core4_1_pf0_acs_cap_peer_to_peer_traffic_supp_hwtcl
    } else {
        ip_set_param "parameter.${PROP_NAME}.value" 0
    }
}
proc ::intel_pcie_ss_axi::parameters::validate_core4_1_pf0_acs_cap_acs_p2p_req_redirect_hwtcl {PROP_NAME PROP_VALUE} {
    set core4_1_func_mode [ip_get "parameter.core4_1_func_mode_hwtcl.value"]
    set core4_1_virtual_rp_ep_mode_integer_hwtcl [ip_get "parameter.core4_1_virtual_rp_ep_mode_integer_hwtcl.value"]

    set core4_1_pf0_acs_cap_peer_to_peer_traffic_supp_hwtcl [ip_get "parameter.core4_1_pf0_acs_cap_peer_to_peer_traffic_supp_hwtcl.value"]
    set core4_1_virtual_pf0_acs_cap_enable_hwtcl [ip_get "parameter.core4_1_virtual_pf0_acs_cap_enable_hwtcl.value"]

    # set to same as peer to peer traffic if core enabled and acs is enabled
    if { $core4_1_func_mode == "Enable" && $core4_1_virtual_pf0_acs_cap_enable_hwtcl == 1 && $core4_1_virtual_rp_ep_mode_integer_hwtcl } {
        ip_set_param "parameter.${PROP_NAME}.value" $core4_1_pf0_acs_cap_peer_to_peer_traffic_supp_hwtcl
    } else {
        ip_set_param "parameter.${PROP_NAME}.value" 0
    }
}


proc ::intel_pcie_ss_axi::parameters::validate_core4_1_pf0_acs_cap_acs_p2p_cpl_redirect_hwtcl {PROP_NAME PROP_VALUE} {
    set core4_1_func_mode [ip_get "parameter.core4_1_func_mode_hwtcl.value"]
    set core4_1_virtual_rp_ep_mode_integer_hwtcl [ip_get "parameter.core4_1_virtual_rp_ep_mode_integer_hwtcl.value"]

    set core4_1_pf0_acs_cap_peer_to_peer_traffic_supp_hwtcl [ip_get "parameter.core4_1_pf0_acs_cap_peer_to_peer_traffic_supp_hwtcl.value"]
    set core4_1_virtual_pf0_acs_cap_enable_hwtcl [ip_get "parameter.core4_1_virtual_pf0_acs_cap_enable_hwtcl.value"]

    # set to same as peer to peer traffic if core enabled and acs is enabled
    if { $core4_1_func_mode == "Enable" && $core4_1_virtual_pf0_acs_cap_enable_hwtcl == 1 && $core4_1_virtual_rp_ep_mode_integer_hwtcl } {
        ip_set_param "parameter.${PROP_NAME}.value" $core4_1_pf0_acs_cap_peer_to_peer_traffic_supp_hwtcl
    } else {
        ip_set_param "parameter.${PROP_NAME}.value" 0
    }
}


proc ::intel_pcie_ss_axi::parameters::validate_core4_1_pf0_acs_cap_acs_usp_forwarding_hwtcl {PROP_NAME PROP_VALUE} {
    set core4_1_func_mode [ip_get "parameter.core4_1_func_mode_hwtcl.value"]
    set core4_1_virtual_rp_ep_mode_integer_hwtcl [ip_get "parameter.core4_1_virtual_rp_ep_mode_integer_hwtcl.value"]

    set core4_1_pf0_acs_cap_peer_to_peer_traffic_supp_hwtcl [ip_get "parameter.core4_1_pf0_acs_cap_peer_to_peer_traffic_supp_hwtcl.value"]
    set core4_1_virtual_pf0_acs_cap_enable_hwtcl [ip_get "parameter.core4_1_virtual_pf0_acs_cap_enable_hwtcl.value"]

    # if root port mode then set to same value as peer to peer traffic, otherwise disable
    if { $core4_1_func_mode == "Enable" && $core4_1_virtual_rp_ep_mode_integer_hwtcl == 1 && $core4_1_virtual_pf0_acs_cap_enable_hwtcl == 1} {
        ip_set_param "parameter.${PROP_NAME}.value" $core4_1_pf0_acs_cap_peer_to_peer_traffic_supp_hwtcl
    } else {
        ip_set_param "parameter.${PROP_NAME}.value" 0
    }
}
proc ::intel_pcie_ss_axi::parameters::validate_core4_1_pf0_acs_cap_acs_direct_translated_p2p_hwtcl {PROP_NAME PROP_VALUE} {
    set core4_1_func_mode [ip_get "parameter.core4_1_func_mode_hwtcl.value"]
    set core4_1_virtual_rp_ep_mode_integer_hwtcl [ip_get "parameter.core4_1_virtual_rp_ep_mode_integer_hwtcl.value"]
    set core4_1_pf0_acs_cap_peer_to_peer_traffic_supp_hwtcl [ip_get "parameter.core4_1_pf0_acs_cap_peer_to_peer_traffic_supp_hwtcl.value"]
    set core4_1_virtual_pf0_acs_cap_enable_hwtcl [ip_get "parameter.core4_1_virtual_pf0_acs_cap_enable_hwtcl.value"]

    # For rp, when ACS is enabled and peer to peer traffic enabled, enable direct translated p2p
    if { $core4_1_func_mode == "Enable" && $core4_1_pf0_acs_cap_peer_to_peer_traffic_supp_hwtcl == 1 && $core4_1_virtual_pf0_acs_cap_enable_hwtcl == 1 && $core4_1_virtual_rp_ep_mode_integer_hwtcl } {
        ip_set_param "parameter.${PROP_NAME}.value" 1
    } else {
        ip_set_param "parameter.${PROP_NAME}.value" 0
    }
}
#  ACS cap validation end
proc ::intel_pcie_ss_axi::parameters::validate_core4_1_pf0_pcie_cap_sel_deemphasis_hwtcl { PROP_NAME PROP_VALUE } {
        set core4_1_func [ip_get "parameter.core4_1_func_mode_hwtcl.value"]
        set core4_1_virtual_rp_ep_mode_integer [ip_get "parameter.core4_1_virtual_rp_ep_mode_integer_hwtcl.value"]
    
        if { $core4_1_func == "Disable" || $core4_1_virtual_rp_ep_mode_integer == 0} {
            ip_set_param "parameter.${PROP_NAME}.value" "pf0_minus_6db"
        } else {
            ip_set_param "parameter.${PROP_NAME}.value" "pf0_minus_3db"
        }
}

proc ::intel_pcie_ss_axi::parameters::validate_core4_1_pf0_pcie_cap_sel_deemphasis_hwtcl_f { PROP_NAME PROP_VALUE } {
        set core4_1_func [ip_get "parameter.core4_1_func_mode_hwtcl.value"]
        set core4_1_virtual_rp_ep_mode_integer [ip_get "parameter.core4_1_virtual_rp_ep_mode_integer_hwtcl.value"]
    
        if { $core4_1_func == "Disable" || $core4_1_virtual_rp_ep_mode_integer == 0} {
            ip_set_param "parameter.${PROP_NAME}.value" "CTOP_CORE4_1_PF0_MINUS_6DB"
        } else {
            ip_set_param "parameter.${PROP_NAME}.value" "CTOP_CORE4_1_PF0_MINUS_3DB"
        }
    
}
proc  ::intel_pcie_ss_axi::parameters::validate_core4_1_pf0_ari_acs_fun_grp_cap_hwtcl { PROP_NAME PROP_VALUE core4_1_pf0_acs_cap_acs_p2p_egress_control_hwtcl} {
    if { $core4_1_pf0_acs_cap_acs_p2p_egress_control_hwtcl} {
        ip_set_param "parameter.${PROP_NAME}.value" 1
    } else {
        ip_set_param "parameter.${PROP_NAME}.value" 0
    }
}
proc ::intel_pcie_ss_axi::parameters::validate_core4_1_pfi_vf_count_hwtcl {PROP_NAME PROP_VALUE} {
	
	for { set i 0 } { $i < 8 } { incr i } {
	set core4_1_virtual_pfi_sriov_enable_hwtcl 		[ip_get "parameter.core4_1_virtual_pf${i}_sriov_enable_hwtcl.value"]
	set core4_1_pfi_vf_count_hwtcl 					[ip_get "parameter.core4_1_pf${i}_vf_count_hwtcl.value"]
	set core4_1_virtual_pfi_msix_enable_hwtcl 		[ip_get "parameter.core4_1_virtual_pf${i}_msix_enable_hwtcl.value"]
		if {$core4_1_virtual_pfi_msix_enable_hwtcl == 0} {
			#send_message info "$core16_pfi_vf_count_hwtcl"
			if { (($core4_1_virtual_pfi_sriov_enable_hwtcl==1)&&($core4_1_pfi_vf_count_hwtcl>0))} {
			 send_message error  "When VF count is greater than 0 for PF${i} VF PCIe3, PF${i} MSI-X should be enabled "
			}
		}
	}
}

proc  ::intel_pcie_ss_axi::parameters::validate_core4_1_pf0_ari_acs_fun_grp_cap_hwtcl_r { PROP_NAME PROP_VALUE core4_1_pf0_acs_cap_acs_p2p_egress_control_hwtcl} {
    if { $core4_1_pf0_acs_cap_acs_p2p_egress_control_hwtcl} {
        ip_set_param "parameter.${PROP_NAME}.value" 1
    } else {
        ip_set_param "parameter.${PROP_NAME}.value" 0
    }
}

proc ::intel_pcie_ss_axi::parameters::validate_core4_1_pf0_eq_redo_hwtcl { PROP_NAME PROP_VALUE top_topology_integer_hwtcl core4_1_virtual_rp_ep_mode_integer_hwtcl} {
    
        if { $core4_1_virtual_rp_ep_mode_integer_hwtcl == 0 && $top_topology_integer_hwtcl >= 2} {
            # EP mode
            ip_set_param "parameter.${PROP_NAME}.value" "disable"
        } else {
            ip_set_param "parameter.${PROP_NAME}.value" "enable"
        }
}
proc ::intel_pcie_ss_axi::parameters::validate_core4_1_pf0_eq_redo_hwtcl_f { PROP_NAME PROP_VALUE core4_1_func_mode_integer_hwtcl core4_1_virtual_rp_ep_mode_integer_hwtcl} {
        if { $core4_1_virtual_rp_ep_mode_integer_hwtcl == 0 && $core4_1_func_mode_integer_hwtcl == 1} {
            # EP mode
            ip_set_param "parameter.${PROP_NAME}.value" "DISABLE"
        } else {
            ip_set_param "parameter.${PROP_NAME}.value" "ENABLE"
        }
}

proc ::intel_pcie_ss_axi::parameters::validate_core4_1_pf0_eq_redo_atg4_hwtcl { PROP_NAME PROP_VALUE top_topology_integer_hwtcl core4_1_virtual_rp_ep_mode_integer_hwtcl} {


        if { $core4_1_virtual_rp_ep_mode_integer_hwtcl == 0 && $top_topology_integer_hwtcl >= 2} {
            # EP mode8
            ip_set_param "parameter.${PROP_NAME}.value" "disable"
        } else {
            ip_set_param "parameter.${PROP_NAME}.value" "enable"
        }
}
proc ::intel_pcie_ss_axi::parameters::validate_core4_1_pf0_eq_redo_atg4_hwtcl_f { PROP_NAME PROP_VALUE core4_1_func_mode_integer_hwtcl core4_1_virtual_rp_ep_mode_integer_hwtcl} {
        if { $core4_1_virtual_rp_ep_mode_integer_hwtcl == 0 && $core4_1_func_mode_integer_hwtcl == 1} {
            # EP mode8
            ip_set_param "parameter.${PROP_NAME}.value" "DISABLE"
        } else {
            ip_set_param "parameter.${PROP_NAME}.value" "ENABLE"
        }
}
proc ::intel_pcie_ss_axi::parameters::validate_core4_1_enable_hotplug_hwtcl { PROP_NAME PROP_VALUE } {
    if { ($PROP_VALUE == 1 ) } {
	ip_set_param "parameter.core4_1_pf0_pcie_cap_power_indicator_hwtcl.value" 1
        ip_set_param "parameter.core4_1_pf0_pcie_cap_attention_indicator_button_hwtcl.value" 1
        ip_set_param "parameter.core4_1_pf0_pcie_cap_power_controller_hwtcl.value" 1      
        ip_set_param "parameter.core4_1_pf0_pcie_cap_mrl_sensor_hwtcl.value" 1
        ip_set_param "parameter.core4_1_pf0_pcie_cap_attention_indicator_hwtcl.value" 1
        ip_set_param "parameter.core4_1_pf0_pcie_cap_hot_plug_surprise_hwtcl.value" 1   
        ip_set_param "parameter.core4_1_pf0_pcie_cap_electromech_interlock_hwtcl.value" 1   
  
    } else {
	ip_set_param "parameter.core4_1_pf0_pcie_cap_power_indicator_hwtcl.value" 0
        ip_set_param "parameter.core4_1_pf0_pcie_cap_attention_indicator_button_hwtcl.value" 0
        ip_set_param "parameter.core4_1_pf0_pcie_cap_power_controller_hwtcl.value" 0      
        ip_set_param "parameter.core4_1_pf0_pcie_cap_mrl_sensor_hwtcl.value" 0
        ip_set_param "parameter.core4_1_pf0_pcie_cap_attention_indicator_hwtcl.value" 0
        ip_set_param "parameter.core4_1_pf0_pcie_cap_hot_plug_surprise_hwtcl.value" 0   
        ip_set_param "parameter.core4_1_pf0_pcie_cap_electromech_interlock_hwtcl.value" 0
     
    }
}
proc ::intel_pcie_ss_axi::parameters::validate_core4_1_debug_features { } {
        # Debug Features for Internal and External Customer
        # This callback must put at the last parameter of the list, or else the VISIBLE will not take effect
        #VISIBLE default set to false
        ip_set_param "parameter.core4_1_user_mode_to_pld_in_use_hwtcl.VISIBLE" false
        ip_set_param "parameter.core4_1_user_mode_to_pld_in_use_hwtcl.ENABLED" false
        ip_set_param "parameter.core4_1_enable_pld_warm_rst_rdy_hwtcl.VISIBLE" false
        ip_set_param "parameter.core4_1_enable_pld_warm_rst_rdy_hwtcl.ENABLED" false
        ip_set_param "parameter.core4_1_rxbuf_limit_posted_bypass_hwtcl.VISIBLE" false
        ip_set_param "parameter.core4_1_rxbuf_limit_posted_bypass_hwtcl.ENABLED" false
        ip_set_param "parameter.core4_1_rxbuf_limit_nonposted_bypass_hwtcl.VISIBLE" false
        ip_set_param "parameter.core4_1_rxbuf_limit_nonposted_bypass_hwtcl.ENABLED" false
        ip_set_param "parameter.core4_1_rxbuf_limit_cpl_bypass_hwtcl.VISIBLE" false
        ip_set_param "parameter.core4_1_rxbuf_limit_cpl_bypass_hwtcl.ENABLED" false
        set core4_1_enable_rx_buffer_limit_ports_hwtcl [ip_get "parameter.core4_1_enable_rx_buffer_limit_ports_hwtcl.value"]
        set avmm_enabled_hwtcl                         [ip_get "parameter.avmm_enabled_hwtcl.value"]
        set rxbuf_features_enablement [ip_get "rxbuf_features_enablement_full.value"]
        if {$rxbuf_features_enablement == 1} {
            ip_set_param "parameter.core4_1_user_mode_to_pld_in_use_hwtcl.VISIBLE" true
            ip_set_param "parameter.core4_1_user_mode_to_pld_in_use_hwtcl.ENABLED" true
            ip_set_param "parameter.core4_1_enable_pld_warm_rst_rdy_hwtcl.VISIBLE" true
            ip_set_param "parameter.core4_1_enable_pld_warm_rst_rdy_hwtcl.ENABLED" true
            if {$core4_1_enable_rx_buffer_limit_ports_hwtcl == 1 && $avmm_enabled_hwtcl ==0} {
                ip_set_param "parameter.core4_1_rxbuf_limit_posted_bypass_hwtcl.VISIBLE" true
                ip_set_param "parameter.core4_1_rxbuf_limit_posted_bypass_hwtcl.ENABLED" true
                ip_set_param "parameter.core4_1_rxbuf_limit_nonposted_bypass_hwtcl.VISIBLE" true
                ip_set_param "parameter.core4_1_rxbuf_limit_nonposted_bypass_hwtcl.ENABLED" true
                ip_set_param "parameter.core4_1_rxbuf_limit_cpl_bypass_hwtcl.VISIBLE" true
                ip_set_param "parameter.core4_1_rxbuf_limit_cpl_bypass_hwtcl.ENABLED" true
            }
        }
}
proc ::intel_pcie_ss_axi::parameters::validate_core4_1_debug_features_r {top_topology_hwtcl} {
	# Debug Features for Internal and External Customer
	# This callback must put at the last parameter of the list, or else the VISIBLE will not take effect
	#VISIBLE default set to false	
	ip_set_param "parameter.core4_1_user_mode_to_pld_in_use_hwtcl.VISIBLE" false
	ip_set_param "parameter.core4_1_user_mode_to_pld_in_use_hwtcl.ENABLED" false
	ip_set_param "parameter.core4_1_enable_pld_warm_rst_rdy_hwtcl.VISIBLE" false
	ip_set_param "parameter.core4_1_enable_pld_warm_rst_rdy_hwtcl.ENABLED" false
	ip_set_param "parameter.core4_1_rx_dsk_enable_hwtcl.VISIBLE" false
	ip_set_param "parameter.core4_1_rx_dsk_enable_hwtcl.ENABLED" false
	ip_set_param "parameter.core4_1_tx_precode_req_hwtcl.VISIBLE" false
	ip_set_param "parameter.core4_1_tx_precode_req_hwtcl.ENABLED" false
	ip_set_param "parameter.core4_1_l1sub_control1_reg_l1_1_aspm_support_hwtcl.VISIBLE" false
	ip_set_param "parameter.core4_1_l1sub_control1_reg_l1_1_aspm_support_hwtcl.ENABLED" false
	ip_set_param "parameter.core4_1_l1sub_control1_reg_l1_2_aspm_support_hwtcl.VISIBLE" false
	ip_set_param "parameter.core4_1_l1sub_control1_reg_l1_2_aspm_support_hwtcl.ENABLED" false
	ip_set_param "parameter.core4_1_l1sub_control1_reg_l1_1_pcipm_support_hwtcl.VISIBLE" false
	ip_set_param "parameter.core4_1_l1sub_control1_reg_l1_1_pcipm_support_hwtcl.ENABLED" false
	ip_set_param "parameter.core4_1_l1sub_control1_reg_l1_2_pcipm_support_hwtcl.VISIBLE" false
	ip_set_param "parameter.core4_1_l1sub_control1_reg_l1_2_pcipm_support_hwtcl.ENABLED" false
	ip_set_param "parameter.core4_1_multi_lane_upconfigure_support_user_hwtcl.VISIBLE" false
	ip_set_param "parameter.core4_1_multi_lane_upconfigure_support_user_hwtcl.ENABLED" false

	set debug_features_enablement [get_quartus_ini "debug_features_enablement_full" ENABLED]
	if {$debug_features_enablement == 1} {
		if {[regexp "Pipe Direct 16-channel" $top_topology_hwtcl]} {
		} else {
			ip_set_param "parameter.core4_1_user_mode_to_pld_in_use_hwtcl.VISIBLE" true
			ip_set_param "parameter.core4_1_user_mode_to_pld_in_use_hwtcl.ENABLED" true
			ip_set_param "parameter.core4_1_enable_pld_warm_rst_rdy_hwtcl.VISIBLE" true
			ip_set_param "parameter.core4_1_enable_pld_warm_rst_rdy_hwtcl.ENABLED" true
			ip_set_param "parameter.core4_1_rx_dsk_enable_hwtcl.VISIBLE" true
			ip_set_param "parameter.core4_1_rx_dsk_enable_hwtcl.ENABLED" true
			ip_set_param "parameter.core4_1_tx_precode_req_hwtcl.VISIBLE" true
			ip_set_param "parameter.core4_1_tx_precode_req_hwtcl.ENABLED" true
			
			ip_set_param "parameter.core4_1_l1sub_control1_reg_l1_1_aspm_support_hwtcl.VISIBLE" true
			ip_set_param "parameter.core4_1_l1sub_control1_reg_l1_1_aspm_support_hwtcl.ENABLED" true
			ip_set_param "parameter.core4_1_l1sub_control1_reg_l1_2_aspm_support_hwtcl.VISIBLE" true
			ip_set_param "parameter.core4_1_l1sub_control1_reg_l1_2_aspm_support_hwtcl.ENABLED" true
			ip_set_param "parameter.core4_1_l1sub_control1_reg_l1_1_pcipm_support_hwtcl.VISIBLE" true
			ip_set_param "parameter.core4_1_l1sub_control1_reg_l1_1_pcipm_support_hwtcl.ENABLED" true
			ip_set_param "parameter.core4_1_l1sub_control1_reg_l1_2_pcipm_support_hwtcl.VISIBLE" true
			ip_set_param "parameter.core4_1_l1sub_control1_reg_l1_2_pcipm_support_hwtcl.ENABLED" true
			ip_set_param "parameter.core4_1_multi_lane_upconfigure_support_user_hwtcl.VISIBLE" true
			ip_set_param "parameter.core4_1_multi_lane_upconfigure_support_user_hwtcl.ENABLED" true
		}
	}
}
proc ::intel_pcie_ss_axi::parameters::validate_core4_1_dwc_ctrl0_k_pld_crs_en_hwtcl {core4_1_func_mode_hwtcl core4_1_virtual_cvp_mode_hwtcl core4_1_enable_power_mgnt_intf_hwtcl core4_1_virtual_rp_ep_mode_hwtcl core4_1_virtual_tlp_bypass_en_hwtcl} {
	#HSD 1508444156
	#Description: core4_1_dwc_ctrl0_k_pld_crs_en_hwtcl set to true when EP mode only (no UP DN RP)
	if {$core4_1_func_mode_hwtcl == "Disable" || $core4_1_virtual_cvp_mode_hwtcl == "cvp_legacy"} {
		ip_set_param "parameter.core4_1_dwc_ctrl0_k_pld_crs_en_hwtcl.value" 0
	} else {
		ip_set_param "parameter.core4_1_dwc_ctrl0_k_pld_crs_en_hwtcl.value" 1
	}
}
proc ::intel_pcie_ss_axi::parameters::validate_core4_1_nparityecc_csbmmioaccess_csbopcode_hwtcl {qhip_mmio_enable_hwtcl core4_1_func_mode_hwtcl core4_1_use_ast_parity_hwtcl core8_use_ast_parity_hwtcl core4_0_use_ast_parity_hwtcl core4_1_use_ast_parity_hwtcl} {
	if { $core4_1_func_mode_hwtcl == "Disable" } {
		ip_set_param "parameter.core4_1_ecc_ctrl_k_nparity_ecc_attr_hwtcl.value" "true"
		ip_set_param "parameter.core4_1_csb_mmio_access_ctrl_grant_attr_hwtcl.value" 0
		ip_set_param "parameter.core4_1_csb_opcode_ctrl_lock_attr_hwtcl.value" false
	} else {
		ip_set_param "parameter.core4_1_ecc_ctrl_k_nparity_ecc_attr_hwtcl.value" "false"
		ip_set_param "parameter.core4_1_csb_mmio_access_ctrl_grant_attr_hwtcl.value" 0
		ip_set_param "parameter.core4_1_csb_opcode_ctrl_lock_attr_hwtcl.value" true
	}
}
proc ::intel_pcie_ss_axi::parameters::validate_core4_1_ehp_ctrl0_k_ehp_ctrl_hwtcl {core4_1_func_mode_hwtcl core4_1_ehp_ctrl0_header_format_hwtcl core4_1_ehp_ctrl0_address_based_data_packing_hwtcl core4_1_use_ast_parity_hwtcl qhip_silicon_reva_revb_hwtcl hssi_ctr_pcie_pld_data_width_integer_hwtcl} {
	#HSD 1509835146
	if {!$qhip_silicon_reva_revb_hwtcl} {
		#A0
		if {$core4_1_func_mode_hwtcl == "Disable" || !$core4_1_ehp_ctrl0_header_format_hwtcl} {
			ip_set_param "parameter.core4_1_ehp_ctrl0_k_ehp_ctrl_hwtcl.value" 0
		} else {
			ip_set_param "parameter.core4_1_ehp_ctrl0_k_ehp_ctrl_hwtcl.value" 1024
		}	
	} else {
		#B0
		set ehp_ctrl0_k_ehp_ctrl 0
		if {$core4_1_func_mode_hwtcl == "Disable"} {
			set ehp_ctrl0_k_ehp_ctrl 0
		} else {
			if {$core4_1_ehp_ctrl0_header_format_hwtcl == 1} {
				#ehp_ctrl0 [10] equal 0x400 = 1024
				set ehp_ctrl0_k_ehp_ctrl [expr $ehp_ctrl0_k_ehp_ctrl + 1024]
			}
			if {$core4_1_ehp_ctrl0_address_based_data_packing_hwtcl == 1} {
				#ehp_ctrl0 [0 13] equal 0x2001 = 8193
				set ehp_ctrl0_k_ehp_ctrl [expr $ehp_ctrl0_k_ehp_ctrl + 8193]
			}
			if {$core4_1_use_ast_parity_hwtcl == 1} {
				#ehp_ctrl0 [1 4 5 8] equal 0x0132 = 306
				set ehp_ctrl0_k_ehp_ctrl [expr $ehp_ctrl0_k_ehp_ctrl + 306]
			}
			if {$hssi_ctr_pcie_pld_data_width_integer_hwtcl == 1} {
				#Set to one when single width is selected
				#ehp_ctrl0 [9] equal 0x200 = 512
				set ehp_ctrl0_k_ehp_ctrl [expr $ehp_ctrl0_k_ehp_ctrl + 512]
			}
		}
		ip_set_param "parameter.core4_1_ehp_ctrl0_k_ehp_ctrl_hwtcl.value" $ehp_ctrl0_k_ehp_ctrl
	}
	
}
proc ::intel_pcie_ss_axi::parameters::validate_core4_1_ehp_ctrl1_k_tx_rd_th_hwtcl { core4_1_topology_hwtcl hssi_ctr_pcie_pld_data_width_hwtcl core4_1_ehp_ctrl0_address_based_data_packing_hwtcl qhip_silicon_reva_revb_hwtcl} { 
	#HSD 1508436767 1508435790 14015969556 15010833424
	if {!$qhip_silicon_reva_revb_hwtcl} {
		if { [regexp "Pipe Direct 16-channel" $core4_1_topology_hwtcl] } { #topology 6
			ip_set_param "parameter.core4_1_ehp_ctrl1_k_tx_rd_th_hwtcl.value" 0
		} elseif { [regexp "1x16" $core4_1_topology_hwtcl] } { #topology 1
			if {$hssi_ctr_pcie_pld_data_width_hwtcl == "Double"} { #Double Width
				ip_set_param "parameter.core4_1_ehp_ctrl1_k_tx_rd_th_hwtcl.value" 25
			} elseif {$hssi_ctr_pcie_pld_data_width_hwtcl == "Single"} { #Single Width
				ip_set_param "parameter.core4_1_ehp_ctrl1_k_tx_rd_th_hwtcl.value" 29
			}
		} elseif { [regexp "2x8" $core4_1_topology_hwtcl] } { #topology 2
			if {$hssi_ctr_pcie_pld_data_width_hwtcl == "Double"} { #Double Width
				ip_set_param "parameter.core4_1_ehp_ctrl1_k_tx_rd_th_hwtcl.value" 29
			} elseif {$hssi_ctr_pcie_pld_data_width_hwtcl == "Single"} { #Single Width
				ip_set_param "parameter.core4_1_ehp_ctrl1_k_tx_rd_th_hwtcl.value" 31
			}
		} elseif { [regexp "4x4" $core4_1_topology_hwtcl] } { #topology 4
			if {$hssi_ctr_pcie_pld_data_width_hwtcl == "Double"} { #Double Width
				ip_set_param "parameter.core4_1_ehp_ctrl1_k_tx_rd_th_hwtcl.value" 31
			} elseif {$hssi_ctr_pcie_pld_data_width_hwtcl == "Single"} { #Single Width
				ip_set_param "parameter.core4_1_ehp_ctrl1_k_tx_rd_th_hwtcl.value" 32
			}
		} elseif {  [regexp "Pipe Direct 8-channel" $core4_1_topology_hwtcl] && [regexp "2x4" $core4_1_topology_hwtcl]  } { #topology 8a - p0 p2
			if {$hssi_ctr_pcie_pld_data_width_hwtcl == "Double"} { #Double Width
				ip_set_param "parameter.core4_1_ehp_ctrl1_k_tx_rd_th_hwtcl.value" 31
			} elseif {$hssi_ctr_pcie_pld_data_width_hwtcl == "Single"} { #Single Width
				ip_set_param "parameter.core4_1_ehp_ctrl1_k_tx_rd_th_hwtcl.value" 32
			}
		} elseif {  [regexp "1x8" $core4_1_topology_hwtcl] && [regexp "2x4" $core4_1_topology_hwtcl] } { #topology 3 p0/p1/p3
			if {$hssi_ctr_pcie_pld_data_width_hwtcl == "Double"} { #Double Width
				ip_set_param "parameter.core4_1_ehp_ctrl1_k_tx_rd_th_hwtcl.value" 29
			} elseif {$hssi_ctr_pcie_pld_data_width_hwtcl == "Single"} { #Single Width
				ip_set_param "parameter.core4_1_ehp_ctrl1_k_tx_rd_th_hwtcl.value" 31
			}
		} elseif { [regexp "Pipe Direct 8-channel" $core4_1_topology_hwtcl] && [regexp "1x8" $core4_1_topology_hwtcl] } { #topology 7a p0
			if {$hssi_ctr_pcie_pld_data_width_hwtcl == "Double"} { #Double Width
				ip_set_param "parameter.core4_1_ehp_ctrl1_k_tx_rd_th_hwtcl.value" 29
			} elseif {$hssi_ctr_pcie_pld_data_width_hwtcl == "Single"} { #Single Width
				ip_set_param "parameter.core4_1_ehp_ctrl1_k_tx_rd_th_hwtcl.value" 31
			}
		} 
	} else {
		if { [regexp "Pipe Direct 16-channel" $core4_1_topology_hwtcl] } {
			ip_set_param "parameter.core4_1_ehp_ctrl1_k_tx_rd_th_hwtcl.value" 0
		} elseif { [regexp "1x16" $core4_1_topology_hwtcl] } { #topology 1
			if {$hssi_ctr_pcie_pld_data_width_hwtcl == "Double"} { #Double Width
				ip_set_param "parameter.core4_1_ehp_ctrl1_k_tx_rd_th_hwtcl.value" 25
			} elseif {$hssi_ctr_pcie_pld_data_width_hwtcl == "Single"} { #Single Width
				ip_set_param "parameter.core4_1_ehp_ctrl1_k_tx_rd_th_hwtcl.value" 29
			}
		} else {
			ip_set_param "parameter.core4_1_ehp_ctrl1_k_tx_rd_th_hwtcl.value" 33
		}
	}
}
proc ::intel_pcie_ss_axi::parameters::validate_core4_1_pf0_usp_dsp_rx_tx_preset_hwtcl {core4_1_func_mode_hwtcl core4_1_virtual_rp_ep_mode_hwtcl core4_1_virtual_link_rate_integer_hwtcl qhip_silicon_reva_revb_hwtcl} {
	#HSD: 22011555390,1508489608,22012843280,22012990568
	
	#tx_preset
	if {$core4_1_func_mode_hwtcl == "Disable"} {
		ip_set_param "parameter.core4_1_pf0_usp_tx_preset_hwtcl_r.value" 0
		ip_set_param "parameter.core4_1_pf0_usp_16g_tx_preset_hwtcl_r.value" 0
		ip_set_param "parameter.core4_1_pf0_usp_32g_tx_preset_hwtcl.value" 0
		ip_set_param "parameter.core4_1_pf0_dsp_tx_preset_hwtcl_r.value" 0
		ip_set_param "parameter.core4_1_pf0_dsp_16g_tx_preset_hwtcl_r.value" 0
		ip_set_param "parameter.core4_1_pf0_dsp_32g_tx_preset_hwtcl.value" 0	
	} elseif {$core4_1_virtual_link_rate_integer_hwtcl == 5 } { 
		ip_set_param "parameter.core4_1_pf0_usp_tx_preset_hwtcl_r.value" 9
		ip_set_param "parameter.core4_1_pf0_usp_16g_tx_preset_hwtcl_r.value" 3
		ip_set_param "parameter.core4_1_pf0_usp_32g_tx_preset_hwtcl.value" 9
		if {$core4_1_virtual_rp_ep_mode_hwtcl == "Native Endpoint"} {
			ip_set_param "parameter.core4_1_pf0_dsp_tx_preset_hwtcl_r.value" 0
		} else {
			ip_set_param "parameter.core4_1_pf0_dsp_tx_preset_hwtcl_r.value" 7
		}
		ip_set_param "parameter.core4_1_pf0_dsp_16g_tx_preset_hwtcl_r.value" 7
		ip_set_param "parameter.core4_1_pf0_dsp_32g_tx_preset_hwtcl.value" 5
	} elseif {$core4_1_virtual_link_rate_integer_hwtcl == 4 } { 
		ip_set_param "parameter.core4_1_pf0_usp_tx_preset_hwtcl_r.value" 9
		ip_set_param "parameter.core4_1_pf0_usp_16g_tx_preset_hwtcl_r.value" 3
		ip_set_param "parameter.core4_1_pf0_usp_32g_tx_preset_hwtcl.value" 0
		if {$core4_1_virtual_rp_ep_mode_hwtcl == "Native Endpoint"} {
			ip_set_param "parameter.core4_1_pf0_dsp_tx_preset_hwtcl_r.value" 0
		} else {
			ip_set_param "parameter.core4_1_pf0_dsp_tx_preset_hwtcl_r.value" 7
		}
		ip_set_param "parameter.core4_1_pf0_dsp_16g_tx_preset_hwtcl_r.value" 7
		ip_set_param "parameter.core4_1_pf0_dsp_32g_tx_preset_hwtcl.value" 0
	} elseif {$core4_1_virtual_link_rate_integer_hwtcl == 3 } { 
		ip_set_param "parameter.core4_1_pf0_usp_tx_preset_hwtcl_r.value" 9
		ip_set_param "parameter.core4_1_pf0_usp_16g_tx_preset_hwtcl_r.value" 0
		ip_set_param "parameter.core4_1_pf0_usp_32g_tx_preset_hwtcl.value" 0
		if {$core4_1_virtual_rp_ep_mode_hwtcl == "Native Endpoint"} {
			ip_set_param "parameter.core4_1_pf0_dsp_tx_preset_hwtcl_r.value" 0
		} else {
			ip_set_param "parameter.core4_1_pf0_dsp_tx_preset_hwtcl_r.value" 7
		}
		ip_set_param "parameter.core4_1_pf0_dsp_16g_tx_preset_hwtcl_r.value" 0
		ip_set_param "parameter.core4_1_pf0_dsp_32g_tx_preset_hwtcl.value" 0
	} else { 
		ip_set_param "parameter.core4_1_pf0_usp_tx_preset_hwtcl_r.value" 0
		ip_set_param "parameter.core4_1_pf0_usp_16g_tx_preset_hwtcl_r.value" 0
		ip_set_param "parameter.core4_1_pf0_usp_32g_tx_preset_hwtcl.value" 0
		ip_set_param "parameter.core4_1_pf0_dsp_tx_preset_hwtcl_r.value" 0
		ip_set_param "parameter.core4_1_pf0_dsp_16g_tx_preset_hwtcl_r.value" 0
		ip_set_param "parameter.core4_1_pf0_dsp_32g_tx_preset_hwtcl.value" 0
	}

	
	#rx_preset
	if {$core4_1_func_mode_hwtcl == "Disable" || $core4_1_virtual_rp_ep_mode_hwtcl == "Native Endpoint"} {
		ip_set_param "parameter.core4_1_pf0_usp_rx_preset0_hwtcl.value" 0
		ip_set_param "parameter.core4_1_pf0_usp_rx_preset_hwtcl.value"  0		
	} else {
		ip_set_param "parameter.core4_1_pf0_usp_rx_preset0_hwtcl.value" 6
		ip_set_param "parameter.core4_1_pf0_usp_rx_preset_hwtcl.value" 6	
	}		
	if {!$qhip_silicon_reva_revb_hwtcl} {
		#A0
		if {$core4_1_func_mode_hwtcl == "Disable" || $core4_1_virtual_rp_ep_mode_hwtcl == "Native Endpoint"} {
			ip_set_param "parameter.core4_1_pf0_dsp_rx_preset_hwtcl.value"  0
		} else {
			ip_set_param "parameter.core4_1_pf0_dsp_rx_preset_hwtcl.value"  6
		}
	} else {
		#B0
		if {$core4_1_func_mode_hwtcl == "Disable" || $core4_1_virtual_rp_ep_mode_hwtcl == "Native Endpoint"} {
			ip_set_param "parameter.core4_1_pf0_dsp_rx_preset_hwtcl.value"  0
		} else {
			ip_set_param "parameter.core4_1_pf0_dsp_rx_preset_hwtcl.value"  7
		}
	}	
}
proc ::intel_pcie_ss_axi::parameters::validate_core4_1_tlb_err_en_k_cfg_hwtcl {PROP_NAME PROP_VALUE core4_1_func_mode_hwtcl core4_1_virtual_tlp_bypass_en_hwtcl} {
	if {$core4_1_func_mode_hwtcl == "Disable"} {
		ip_set_param "parameter.${PROP_NAME}.value" false
	} elseif {$core4_1_virtual_tlp_bypass_en_hwtcl == 1} {
		ip_set_param "parameter.${PROP_NAME}.value" true
	}
}
proc ::intel_pcie_ss_axi::parameters::validate_core4_1_pfvf_sel_vsec_enable_hwtcl {PROP_NAME PROP_VALUE core4_1_func_mode_hwtcl} {
	if {$core4_1_func_mode_hwtcl == "Disable"} {
		ip_set_param "parameter.core4_1_pfvf_sel_vsec_enable_hwtcl.value" false
	} else {
		ip_set_param "parameter.core4_1_pfvf_sel_vsec_enable_hwtcl.value" true
	}
}
proc ::intel_pcie_ss_axi::parameters::validate_core4_1_pf0_bar3_reg_bar3_mem_io_hwtcl {PROP_NAME PROP_VALUE core4_1_func_mode_hwtcl core4_1_virtual_rp_ep_mode_hwtcl core4_1_virtual_pf0_io_decode_hwtcl} {
	if {$core4_1_func_mode_hwtcl == "Disable"} {
		ip_set_param "parameter.core4_1_pf0_bar3_reg_bar3_mem_io_hwtcl.value" "pf0_bar3_mem"
	} else {
		if {$core4_1_virtual_rp_ep_mode_hwtcl == "Root Port"} {
			if {$core4_1_virtual_pf0_io_decode_hwtcl == "io16"} {
					ip_set_param "parameter.core4_1_pf0_bar3_reg_bar3_mem_io_hwtcl.value" "pf0_bar3_mem"
			} else {
				ip_set_param "parameter.core4_1_pf0_bar3_reg_bar3_mem_io_hwtcl.value" "pf0_bar3_io"
			}
		} else {
			ip_set_param "parameter.core4_1_pf0_bar3_reg_bar3_mem_io_hwtcl.value" "pf0_bar3_mem"
		}
	}
}
proc ::intel_pcie_ss_axi::parameters::validate_core4_1_link_capabilities_reg_pcie_cap_surprise_down_err_rep_cap_hwtcl {PROP_NAME PROP_VALUE core4_1_virtual_tlp_bypass_en_hwtcl core4_1_virtual_rp_ep_mode_hwtcl} {
	if {$core4_1_virtual_tlp_bypass_en_hwtcl == 1 && $core4_1_virtual_rp_ep_mode_hwtcl == "Root Port"} {
		ip_set_param "parameter.core4_1_pf0_link_capabilities_reg_pcie_cap_surprise_down_err_rep_cap_hwtcl.value" true
	} else {
		ip_set_param "parameter.core4_1_pf0_link_capabilities_reg_pcie_cap_surprise_down_err_rep_cap_hwtcl.value" false
	}
}

proc ::intel_pcie_ss_axi::parameters::validate_core4_1_k_clrhip_not_rst_sticky_hwtcl {qhip_silicon_reva_revb_hwtcl core4_1_func_mode_hwtcl independent_perst_int_hwtcl} {
	if {!$qhip_silicon_reva_revb_hwtcl} {
	#A0
		ip_set_param "parameter.core4_1_k_clrhip_not_rst_sticky_hwtcl.value" 0
	} else {
	#B0
		if {$core4_1_func_mode_hwtcl == "Enable" && $independent_perst_int_hwtcl} {
			ip_set_param "parameter.core4_1_k_clrhip_not_rst_sticky_hwtcl.value" 1
		} else {
			ip_set_param "parameter.core4_1_k_clrhip_not_rst_sticky_hwtcl.value" 0
		}
	}
}
proc ::intel_pcie_ss_axi::parameters::validate_core4_1_multi_lane_upconfigure_support_hwtcl {core4_1_func_mode_hwtcl core4_1_multi_lane_upconfigure_support_user_hwtcl} {
	set dlw_enable [get_quartus_ini "dlw_enable" ENABLED]

	if {$core4_1_func_mode_hwtcl == "Disable"} {
		ip_set_param "parameter.core4_1_multi_lane_upconfigure_support_hwtcl.value" 1
	} elseif {$core4_1_multi_lane_upconfigure_support_user_hwtcl==1} {
		ip_set_param "parameter.core4_1_multi_lane_upconfigure_support_hwtcl.value" 1
	} elseif {$dlw_enable} {
		ip_set_param "parameter.core4_1_multi_lane_upconfigure_support_hwtcl.value" 1
	} else {
		ip_set_param "parameter.core4_1_multi_lane_upconfigure_support_hwtcl.value" 0
	}
}
proc ::intel_pcie_ss_axi::parameters::validate_core4_1_pf0_gen_eq_pset_req_vec_a0_hwtcl {PROP_NAME PROP_VALUE core4_1_func_mode_hwtcl core4_1_pf0_gen3_eq_pset_req_vec_a0_user_hwtcl core4_1_pf0_gen3_eq_pset_req_vec_atg4_a0_user_hwtcl generating_a0_hwtcl} {
    set tile [ip_get "parameter.TILE.value"]
    if {$tile == "F-TILE"} {
    
    if { $core4_1_func_mode_hwtcl == "Disable" } {
		ip_set_param "parameter.core4_1_pf0_gen3_eq_pset_req_vec_hwtcl_f.value" 32
		ip_set_param "parameter.core4_1_pf0_gen3_eq_pset_req_vec_atg4_hwtcl_f.value" 1023
	} else { 
            if { $generating_a0_hwtcl } {
                #A0 
                ip_set_param "parameter.core4_1_pf0_gen3_eq_pset_req_vec_hwtcl_f.value" $core4_1_pf0_gen3_eq_pset_req_vec_a0_user_hwtcl
                ip_set_param "parameter.core4_1_pf0_gen3_eq_pset_req_vec_atg4_hwtcl_f.value" $core4_1_pf0_gen3_eq_pset_req_vec_atg4_a0_user_hwtcl
            	#B0 INVISBLE AND DISABLED
		ip_set_param "parameter.core4_1_pf0_gen3_eq_pset_req_vec_b0_user_hwtcl.VISIBLE" false
		ip_set_param "parameter.core4_1_pf0_gen3_eq_pset_req_vec_atg4_b0_user_hwtcl.VISIBLE" false

		ip_set_param "parameter.core4_1_pf0_gen3_eq_pset_req_vec_b0_user_hwtcl.ENABLED" false
		ip_set_param "parameter.core4_1_pf0_gen3_eq_pset_req_vec_atg4_b0_user_hwtcl.ENABLED" false          		
		#C0 INVISBLE AND DISABLED
		ip_set_param "parameter.core4_1_pf0_gen3_eq_pset_req_vec_c0_user_hwtcl.VISIBLE" false
		ip_set_param "parameter.core4_1_pf0_gen3_eq_pset_req_vec_atg4_c0_user_hwtcl.VISIBLE" false

		ip_set_param "parameter.core4_1_pf0_gen3_eq_pset_req_vec_c0_user_hwtcl.ENABLED" false
		ip_set_param "parameter.core4_1_pf0_gen3_eq_pset_req_vec_atg4_c0_user_hwtcl.ENABLED" false 
		
		ip_message info "4-0-1-A0: parameter.core4_1_pf0_gen3_eq_pset_req_vec_a0_user_hwtcl = $core4_1_pf0_gen3_eq_pset_req_vec_a0_user_hwtcl"
		#ip_message info "4-0-1-B0: parameter.core16_pf0_gen3_eq_pset_req_vec_b0_user_hwtcl = $core16//_pf0_gen3_eq_pset_req_vec_b0_user_hwtcl"
		#ip_message info "4-0-1-C0: parameter.core16_pf0_gen3_eq_pset_req_vec_c0_user_hwtcl = $core16_pf0_gen3_eq_pset_req_vec_c0_user_hwtcl"
		}            
   	 }
   }
}
#	 ip_message info "core4_1 -A0: parameter.core4_1_pf0_gen3_eq_pset_req_vec_hwtcl.value= $core4_1_pf0_gen3_eq_pset_req_vec_hwtcl"
#     }

proc ::intel_pcie_ss_axi::parameters::validate_core4_1_pf0_gen_eq_pset_req_vec_b0_hwtcl {PROP_NAME PROP_VALUE core4_1_func_mode_hwtcl core4_1_pf0_gen3_eq_pset_req_vec_atg4_b0_user_hwtcl core4_1_pf0_gen3_eq_pset_req_vec_b0_user_hwtcl generating_b0_hwtcl} {
    set tile [ip_get "parameter.TILE.value"]
    if {$tile == "F-TILE"} {
      if { $core4_0_func_mode_hwtcl == "Disable" } {
		ip_set_param "parameter.core4_1_pf0_gen3_eq_pset_req_vec_hwtcl_f.value" 32
		ip_set_param "parameter.core4_1_pf0_gen3_eq_pset_req_vec_atg4_hwtcl_f.value" 1023
	} else { 
            if { $generating_b0_hwtcl } {
                #B0 
                ip_set_param "parameter.core4_1_pf0_gen3_eq_pset_req_vec_hwtcl_f.value" $core4_1_pf0_gen3_eq_pset_req_vec_b0_user_hwtcl
                ip_set_param "parameter.core4_1_pf0_gen3_eq_pset_req_vec_atg4_hwtcl_f.value" $core4_1_pf0_gen3_eq_pset_req_vec_atg4_b0_user_hwtcl
		#A0 INVISBLE AND DISABLED
		ip_set_param "parameter.core4_1_pf0_gen3_eq_pset_req_vec_a0_user_hwtcl.VISIBLE" false
		ip_set_param "parameter.core4_1_pf0_gen3_eq_pset_req_vec_atg4_a0_user_hwtcl.VISIBLE" false

		ip_set_param "parameter.core4_1_pf0_gen3_eq_pset_req_vec_a0_user_hwtcl.ENABLED" false
		ip_set_param "parameter.core4_1_pf0_gen3_eq_pset_req_vec_atg4_a0_user_hwtcl.ENABLED" false          		
		#C0 INVISBLE AND DISABLED
		ip_set_param "parameter.core4_1_pf0_gen3_eq_pset_req_vec_c0_user_hwtcl.VISIBLE" false
		ip_set_param "parameter.core4_1_pf0_gen3_eq_pset_req_vec_atg4_c0_user_hwtcl.VISIBLE" false

		ip_set_param "parameter.core4_1_pf0_gen3_eq_pset_req_vec_c0_user_hwtcl.ENABLED" false
		ip_set_param "parameter.core4_1_pf0_gen3_eq_pset_req_vec_atg4_c0_user_hwtcl.ENABLED" false 

		#ip_message info "4-0-2-A0: parameter.core16_pf0_gen3_eq_pset_req_vec_a0_user_hwtcl = $core16_pf0_gen3_eq_pset_req_vec_a0_user_hwtcl"
		ip_message info "4-0-2-B0: parameter.core4_1_pf0_gen3_eq_pset_req_vec_b0_user_hwtcl = $core4_1_pf0_gen3_eq_pset_req_vec_b0_user_hwtcl"
		#ip_message info "4-0-2-C0: parameter.core16_pf0_gen3_eq_pset_req_vec_c0_user_hwtcl = $core16_pf0_gen3_eq_pset_req_vec_c0_user_hwtcl"
	} 
		}
    }
}
	#	ip_message info "Core4_0 -B0: parameter.core4_1_pf0_gen3_eq_pset_req_vec_hwtcl.value= $core4_1_pf0_gen3_eq_pset_req_vec_hwtcl"

#}

proc ::intel_pcie_ss_axi::parameters::validate_core4_1_pf0_gen_eq_pset_req_vec_c0_hwtcl {PROP_NAME PROP_VALUE core4_1_func_mode_hwtcl core4_1_pf0_gen3_eq_pset_req_vec_atg4_c0_user_hwtcl core4_1_pf0_gen3_eq_pset_req_vec_c0_user_hwtcl generating_c0_hwtcl} {
    set tile [ip_get "parameter.TILE.value"]
    if {$tile == "F-TILE"} {

        if { $core4_1_func_mode_hwtcl == "Disable" } {
    		ip_set_param "parameter.core4_1_pf0_gen3_eq_pset_req_vec_hwtcl_f.value" 32
    		ip_set_param "parameter.core4_1_pf0_gen3_eq_pset_req_vec_atg4_hwtcl_f.value" 1023
    	} else { 
                if { $generating_c0_hwtcl } {
                    #C0 
                    ip_set_param "parameter.core4_1_pf0_gen3_eq_pset_req_vec_hwtcl_f.value" $core4_1_pf0_gen3_eq_pset_req_vec_c0_user_hwtcl
                    ip_set_param "parameter.core4_1_pf0_gen3_eq_pset_req_vec_atg4_hwtcl_f.value" $core4_1_pf0_gen3_eq_pset_req_vec_atg4_c0_user_hwtcl
        		#A0 INVISBLE AND DISABLED
        		ip_set_param "parameter.core4_1_pf0_gen3_eq_pset_req_vec_a0_user_hwtcl.VISIBLE" false
        		ip_set_param "parameter.core4_1_pf0_gen3_eq_pset_req_vec_atg4_a0_user_hwtcl.VISIBLE" false
        
        		ip_set_param "parameter.core4_1_pf0_gen3_eq_pset_req_vec_a0_user_hwtcl.ENABLED" false
        		ip_set_param "parameter.core4_1_pf0_gen3_eq_pset_req_vec_atg4_a0_user_hwtcl.ENABLED" false   
        		#B0 INVISBLE AND DISABLED
        		ip_set_param "parameter.core4_1_pf0_gen3_eq_pset_req_vec_b0_user_hwtcl.VISIBLE" false
        		ip_set_param "parameter.core4_1_pf0_gen3_eq_pset_req_vec_atg4_b0_user_hwtcl.VISIBLE" false
        
                ip_set_param "parameter.core4_1_pf0_gen3_eq_pset_req_vec_b0_user_hwtcl.ENABLED" false
        		ip_set_param "parameter.core4_1_pf0_gen3_eq_pset_req_vec_atg4_b0_user_hwtcl.ENABLED" false 
        	
        		#ip_message info "16-3-A0: parameter.core4_1_pf0_gen3_eq_pset_req_vec_a0_user_hwtcl = $core4_1_pf0_gen3_eq_pset_req_vec_a0_user_hwtcl"
        		#ip_message info "16-3-B0: parameter.core4_1_pf0_gen3_eq_pset_req_vec_b0_user_hwtcl = $core4_1_pf0_gen3_eq_pset_req_vec_b0_user_hwtcl"
        		#ip_message info "16-3-C0: parameter.core4_1_pf0_gen3_eq_pset_req_vec_c0_user_hwtcl = $core4_1_pf0_gen3_eq_pset_req_vec_c0_user_hwtcl"
    	    } 
    	}
    }
}





proc ::intel_pcie_ss_axi::parameters::validate_core4_1_pf0_gen2_ctrl_off_support_mod_ts_hwtcl {PROP_NAME PROP_VALUE core4_1_func_mode_hwtcl core4_1_pf0_gen2_ctrl_off_support_mod_ts_hwtcl} {
	if {$core4_1_func_mode_hwtcl == "Disable"} {
		ip_set_param "parameter.core4_1_pf0_gen2_ctrl_off_support_mod_ts_int_hwtcl.value" 0
	} else {
		ip_set_param "parameter.core4_1_pf0_gen2_ctrl_off_support_mod_ts_int_hwtcl.value" $core4_1_pf0_gen2_ctrl_off_support_mod_ts_hwtcl
	}
}
proc ::intel_pcie_ss_axi::parameters::validate_core4_1_pcie_cap_bw_int_en_hwtcl {PROP_NAME PROP_VALUE core4_1_func_mode_hwtcl core4_1_virtual_rp_ep_mode_integer_hwtcl} {
	if {$core4_1_func_mode_hwtcl == "Disable" || $core4_1_virtual_rp_ep_mode_integer_hwtcl == 0} {
		ip_set_param "parameter.core4_1_pf0_pcie_cap_auto_bw_int_en_hwtcl.value" 0
		ip_set_param "parameter.core4_1_pf0_pcie_cap_bw_man_int_en_hwtcl.value" 0
	} else {
		ip_set_param "parameter.core4_1_pf0_pcie_cap_auto_bw_int_en_hwtcl.value" 1
		ip_set_param "parameter.core4_1_pf0_pcie_cap_bw_man_int_en_hwtcl.value" 1
	}
}
proc ::intel_pcie_ss_axi::parameters::validate_core4_1_virtual_pf0_l1sub_cap_enable_hwtcl {core4_1_func_mode_hwtcl virtual_aspm_control_user_hwtcl core4_1_l1sub_control1_reg_l1_1_aspm_support_hwtcl core4_1_l1sub_control1_reg_l1_2_aspm_support_hwtcl core4_1_l1sub_control1_reg_l1_1_pcipm_support_hwtcl core4_1_l1sub_control1_reg_l1_2_pcipm_support_hwtcl qhip_silicon_reva_revb_hwtcl qhip_silicon_revc_hwtcl} {
	#HSD15010817673 15010819247
	if {$core4_1_func_mode_hwtcl == "Enable" && ($core4_1_l1sub_control1_reg_l1_1_aspm_support_hwtcl || $core4_1_l1sub_control1_reg_l1_2_aspm_support_hwtcl || $core4_1_l1sub_control1_reg_l1_1_pcipm_support_hwtcl || $core4_1_l1sub_control1_reg_l1_2_pcipm_support_hwtcl)  } {
		ip_set_param "parameter.core4_1_virtual_l1sub_support_hwtcl.value" 1
	} else {
		ip_set_param "parameter.core4_1_virtual_l1sub_support_hwtcl.value" 0
	}	
	
	if {($core4_1_l1sub_control1_reg_l1_1_aspm_support_hwtcl || $core4_1_l1sub_control1_reg_l1_2_aspm_support_hwtcl) && ($virtual_aspm_control_user_hwtcl == "No ASPM Support" || $virtual_aspm_control_user_hwtcl == "L0s Supported")} {
		send_message error "Enable ASPM L1.1 or ASPM L1.2 were supported when Enable ASPM control is L0s and L1 Supported or L1 Supported"
	} 
}
proc ::intel_pcie_ss_axi::parameters::validate_core4_1_virtual_pf0_ltr_cap_enable_hwtcl {PROP_NAME PROP_VALUE core4_1_virtual_pf0_ltr_cap_enable_hwtcl core4_1_func_mode_hwtcl core4_1_virtual_rp_ep_mode_integer_hwtcl core4_1_l1sub_control1_reg_l1_2_aspm_support_hwtcl} {
	#HSD: 1509968193
	if {$core4_1_func_mode_hwtcl == "Disable"} {
		ip_set_param "parameter.core4_1_virtual_pf0_ltr_cap_enable_int_hwtcl.value" 0
	} elseif {$core4_1_virtual_pf0_ltr_cap_enable_hwtcl == 1 || ($core4_1_virtual_rp_ep_mode_integer_hwtcl == 0 && $core4_1_l1sub_control1_reg_l1_2_aspm_support_hwtcl) } {
		ip_set_param "parameter.core4_1_virtual_pf0_ltr_cap_enable_int_hwtcl.value" 1	
	} else {
		ip_set_param "parameter.core4_1_virtual_pf0_ltr_cap_enable_int_hwtcl.value" 0
	}
	
	if {$core4_1_func_mode_hwtcl == "Enable" && $core4_1_l1sub_control1_reg_l1_2_aspm_support_hwtcl } {
		send_message info "Enable ASPM L1.2 Substate automatically enable PCIe0 Latency Tolerance Reporting (LTR)."
	}
}
proc ::intel_pcie_ss_axi::parameters::validate_core4_1_pf0_pcie_cap_hot_plug_surprise_hwtcl {PROP_NAME PROP_VALUE core4_1_virtual_rp_ep_mode_integer_hwtcl core4_1_enable_hotplug_hwtcl} {
	if { $core4_1_virtual_rp_ep_mode_integer_hwtcl == 1 && $core4_1_enable_hotplug_hwtcl == 1} {
        # RP mode
        ip_set_param "parameter.${PROP_NAME}.value" 1
    } else {
        ip_set_param "parameter.${PROP_NAME}.value" 0
    }
}
proc ::intel_pcie_ss_axi::parameters::validate_core4_1_virtual_pf0_margin_cap_enable_hwtcl {PROP_NAME PROP_VALUE core4_1_func_mode_hwtcl core4_1_virtual_link_rate_hwtcl} {
    if { $core4_1_func_mode_hwtcl == "Disable" } {
        ip_set_param "parameter.core4_1_virtual_pf0_margin_cap_enable_hwtcl.value" 0
    } elseif { $core4_1_virtual_link_rate_hwtcl == "Gen4 (16.0 Gbps)" } {
        ip_set_param "parameter.core4_1_virtual_pf0_margin_cap_enable_hwtcl.value" 1
    } else {
        ip_set_param "parameter.core4_1_virtual_pf0_margin_cap_enable_hwtcl.value" 0
    }
}
proc ::intel_pcie_ss_axi::parameters::validate_core4_1_virtual_pf0_dlink_cap_enable_hwtcl {PROP_NAME PROP_VALUE core4_1_func_mode_hwtcl} {
    if { ${core4_1_func_mode_hwtcl} == "Enable" } {
        ip_set_param "parameter.core4_1_virtual_pf0_dlink_cap_enable_hwtcl.value" 1
    } else {
        ip_set_param "parameter.core4_1_virtual_pf0_dlink_cap_enable_hwtcl.value" 0
    }
}
proc ::intel_pcie_ss_axi::parameters::validate_core4_1_pf_device_control_device_status_pcie_cap_ext_tag_en_hwtcl {PROP_NAME PROP_VALUE core4_1_func_mode_hwtcl} { #ARG: core4_1_virtual_${pf_num}_enable_hwtcl
	regexp {pf.} $PROP_NAME pf_num
	set virtual_pf_enable_hwtcl         [ip_get "parameter.core4_1_virtual_${pf_num}_enable_hwtcl.value"]
	
	if {$core4_1_func_mode_hwtcl == "Disable" || $virtual_pf_enable_hwtcl == 0} {
		ip_set_param "parameter.core4_1_${pf_num}_device_control_device_status_pcie_cap_ext_tag_en_hwtcl.value" false
	} else {
		ip_set_param "parameter.core4_1_${pf_num}_device_control_device_status_pcie_cap_ext_tag_en_hwtcl.value" true
	}
}
proc ::intel_pcie_ss_axi::parameters::validate_core4_1_virtual_dmwr_egress_blk_hwtcl {PROP_NAME PROP_VALUE core4_1_func_mode_hwtcl core4_1_virtual_dmwr_egress_blk_hwtcl} {
	#HSD: 1509436374 1509869360 
	#Egress Blocking Hide due to HIP cannot enabled it VISIBLE: "virtual_dmwr_support_hwtcl && core4_1_virtual_rp_ep_mode_integer_hwtcl && !core4_1_virtual_tlp_bypass_en_hwtcl"
	regexp {pf.} $PROP_NAME pf_num
	set virtual_pf_enable_hwtcl         [ip_get "parameter.core4_1_virtual_${pf_num}_enable_hwtcl.value"]
	
	if {$core4_1_func_mode_hwtcl == "Disable" || $virtual_pf_enable_hwtcl == 0 || $core4_1_virtual_dmwr_egress_blk_hwtcl == 0} {
		ip_set_param "parameter.core4_1_${pf_num}_device_control3_reg_dev3_cap_dmwr_egress_blk_hwtcl.value" false
	} else {
		ip_set_param "parameter.core4_1_${pf_num}_device_control3_reg_dev3_cap_dmwr_egress_blk_hwtcl.value" true
	}
}
proc ::intel_pcie_ss_axi::parameters::validate_core4_1_sriov_misc_ctrl_k_nonsriov_mode_hwtcl {PROP_NAME PROP_VALUE core4_1_func_mode_hwtcl core4_1_virtual_pf0_sriov_enable_hwtcl} {
	if {$core4_1_func_mode_hwtcl == "Disable"|| $core4_1_virtual_pf0_sriov_enable_hwtcl == 0} {
		ip_set_param "parameter.core4_1_sriov_misc_ctrl_k_nonsriov_mode_hwtcl.value" 255
	} else {
		ip_set_param "parameter.core4_1_sriov_misc_ctrl_k_nonsriov_mode_hwtcl.value" 0
	}
}
proc ::intel_pcie_ss_axi::parameters::validate_core4_1_pfi_no_soft_rst_hwtcl {core4_1_func_mode_hwtcl core4_1_virtual_rp_ep_mode_integer_hwtcl} {
	for {set i 0} { $i < 8 } {incr i} {
		set core4_1_virtual_pfi_enable_hwtcl [ip_get "parameter.core4_1_virtual_pf${i}_enable_hwtcl.value"]
		if {$core4_1_func_mode_hwtcl == "Disable" || $core4_1_virtual_pfi_enable_hwtcl == 0} {
			ip_set_param "parameter.core4_1_pf${i}_no_soft_rst_hwtcl.value" "pf${i}_internally_reset"
		} elseif {$core4_1_virtual_rp_ep_mode_integer_hwtcl == 1} {
			ip_set_param "parameter.core4_1_pf${i}_no_soft_rst_hwtcl.value" "pf${i}_internally_reset"
		} else {
			ip_set_param "parameter.core4_1_pf${i}_no_soft_rst_hwtcl.value" "pf${i}_not_internally_reset"
		}
	}
}
proc ::intel_pcie_ss_axi::parameters::validate_core4_1_virtual_ptm_autoupdate_hwtcl {core4_1_func_mode_hwtcl core4_1_virtual_rp_ep_mode_hwtcl core4_1_virtual_ptm_hwtcl core4_1_cfg_ptm_auto_update_period_hwtcl pld_clkfreq_integer_hwtcl} {
	#HSD 14015367091 14015367092
    if { $core4_1_func_mode_hwtcl == "Disable" } {
        ip_set_param "parameter.core4_1_virtual_ptm_autoupdate_hwtcl.value" "10"
    } elseif {$core4_1_virtual_ptm_hwtcl  == 0} {
		ip_set_param "parameter.core4_1_virtual_ptm_autoupdate_hwtcl.value" "0"
    } else {
        if { $core4_1_cfg_ptm_auto_update_period_hwtcl == "1"} {
            ip_set_param "parameter.core4_1_virtual_ptm_autoupdate_hwtcl.value" "1"
        } elseif { $core4_1_cfg_ptm_auto_update_period_hwtcl == "2"} {
            ip_set_param "parameter.core4_1_virtual_ptm_autoupdate_hwtcl.value" "2"
        } elseif { $core4_1_cfg_ptm_auto_update_period_hwtcl == "3"} {
            ip_set_param "parameter.core4_1_virtual_ptm_autoupdate_hwtcl.value" "3"
        } elseif { $core4_1_cfg_ptm_auto_update_period_hwtcl == "4"} {
            ip_set_param "parameter.core4_1_virtual_ptm_autoupdate_hwtcl.value" "4"
        } elseif { $core4_1_cfg_ptm_auto_update_period_hwtcl == "5"} {
            ip_set_param "parameter.core4_1_virtual_ptm_autoupdate_hwtcl.value" "5"
        } elseif { $core4_1_cfg_ptm_auto_update_period_hwtcl == "6"} {
            ip_set_param "parameter.core4_1_virtual_ptm_autoupdate_hwtcl.value" "6"
        } elseif { $core4_1_cfg_ptm_auto_update_period_hwtcl == "7"} {
            ip_set_param "parameter.core4_1_virtual_ptm_autoupdate_hwtcl.value" "7"
        } elseif { $core4_1_cfg_ptm_auto_update_period_hwtcl == "8"} {
            ip_set_param "parameter.core4_1_virtual_ptm_autoupdate_hwtcl.value" "8"
        } elseif { $core4_1_cfg_ptm_auto_update_period_hwtcl == "9"} {
            ip_set_param "parameter.core4_1_virtual_ptm_autoupdate_hwtcl.value" "9"
        } elseif { $core4_1_cfg_ptm_auto_update_period_hwtcl == "10"} {
            ip_set_param "parameter.core4_1_virtual_ptm_autoupdate_hwtcl.value" "10"
        } elseif { $core4_1_cfg_ptm_auto_update_period_hwtcl == "Disable"} {
            ip_set_param "parameter.core4_1_virtual_ptm_autoupdate_hwtcl.value" "0"
        }
        send_message info "When PTM is enabled, it automatically enabled PTM manual update."
    }
	
	
	#PTM adjustment
	if { $core4_1_func_mode_hwtcl == "Disable" || $core4_1_virtual_ptm_hwtcl  == 0 || $core4_1_virtual_rp_ep_mode_hwtcl == "Root Port" } {
		ip_set_param "parameter.core4_1_virtual_ptm_adj_lsb_hwtcl.value" "0"
		ip_set_param "parameter.core4_1_virtual_ptm_adj_msb_hwtcl.value" "0"
	} else {
		if {$pld_clkfreq_integer_hwtcl == 500} {
			ip_set_param "parameter.core4_1_virtual_ptm_adj_lsb_hwtcl.value" "157"
			ip_set_param "parameter.core4_1_virtual_ptm_adj_msb_hwtcl.value" "0"
		} elseif {$pld_clkfreq_integer_hwtcl == 475} {
			ip_set_param "parameter.core4_1_virtual_ptm_adj_lsb_hwtcl.value" "165"
			ip_set_param "parameter.core4_1_virtual_ptm_adj_msb_hwtcl.value" "0"
		} elseif {$pld_clkfreq_integer_hwtcl == 450} {
			ip_set_param "parameter.core4_1_virtual_ptm_adj_lsb_hwtcl.value" "174"
			ip_set_param "parameter.core4_1_virtual_ptm_adj_msb_hwtcl.value" "0"
		} elseif {$pld_clkfreq_integer_hwtcl == 425} {
			ip_set_param "parameter.core4_1_virtual_ptm_adj_lsb_hwtcl.value" "185"
			ip_set_param "parameter.core4_1_virtual_ptm_adj_msb_hwtcl.value" "0"
		} elseif {$pld_clkfreq_integer_hwtcl == 400} {
			ip_set_param "parameter.core4_1_virtual_ptm_adj_lsb_hwtcl.value" "196"
			ip_set_param "parameter.core4_1_virtual_ptm_adj_msb_hwtcl.value" "0"
		} elseif {$pld_clkfreq_integer_hwtcl == 300} {
			ip_set_param "parameter.core4_1_virtual_ptm_adj_lsb_hwtcl.value" "262"
			ip_set_param "parameter.core4_1_virtual_ptm_adj_msb_hwtcl.value" "0"
		} elseif {$pld_clkfreq_integer_hwtcl == 275} {
			ip_set_param "parameter.core4_1_virtual_ptm_adj_lsb_hwtcl.value" "285"
			ip_set_param "parameter.core4_1_virtual_ptm_adj_msb_hwtcl.value" "0"
		} elseif {$pld_clkfreq_integer_hwtcl == 250} {
			ip_set_param "parameter.core4_1_virtual_ptm_adj_lsb_hwtcl.value" "314"
			ip_set_param "parameter.core4_1_virtual_ptm_adj_msb_hwtcl.value" "0"
		} else {
			ip_set_param "parameter.core4_1_virtual_ptm_adj_lsb_hwtcl.value" "0"
			ip_set_param "parameter.core4_1_virtual_ptm_adj_msb_hwtcl.value" "0"
		}
	}
}
proc ::intel_pcie_ss_axi::parameters::validate_core4_1_pf_ats_capabilities_ctrl_reg_page_aligned_req_hwtcl {PROP_NAME PROP_VALUE core4_1_func_mode_hwtcl} {
	#HSD: 1508895744
	regexp {pf.} $PROP_NAME pf_num
	set core4_1_virtual_pf_ats_cap_enable [ip_get "parameter.core4_1_virtual_${pf_num}_ats_cap_enable_hwtcl.value"]
		
	if {$core4_1_func_mode_hwtcl == "Enable" && $core4_1_virtual_pf_ats_cap_enable == 1} {
		ip_set_param "parameter.core4_1_${pf_num}_ats_capabilities_ctrl_reg_page_aligned_req_hwtcl.value" 1
	} else {
		ip_set_param "parameter.core4_1_${pf_num}_ats_capabilities_ctrl_reg_page_aligned_req_hwtcl.value" 0
	}
}
proc ::intel_pcie_ss_axi::parameters::validate_core4_1_virtual_pfi_sriov_enable_hwtcl {PROP_NAME PROP_VALUE core4_1_enable_sriov_hwtcl core4_1_total_pf_count_hwtcl core4_1_virtual_pf1_sriov_enable_hwtcl } {
    for {set i 0} { $i < 8 } {incr i} {
        set core4_1_virtual_pfi_enable_hwtcl [ip_get "parameter.core4_1_virtual_pf${i}_enable_hwtcl.value"]
        if { $core4_1_virtual_pfi_enable_hwtcl == 1 && $core4_1_enable_sriov_hwtcl == 1} {
            ip_set_param "parameter.core4_1_virtual_pf${i}_sriov_enable_hwtcl.value" 1
        } else {
            ip_set_param "parameter.core4_1_virtual_pf${i}_sriov_enable_hwtcl.value" 0
        }
    }
}
proc ::intel_pcie_ss_axi::parameters::validate_core4_1_enable_multi_func_hwtcl {PROP_NAME PROP_VALUE} {
    set core4_1_func_mode [ip_get "parameter.core4_1_func_mode_hwtcl.value"]
    set core4_1_enable_multi_func_hwtcl [ip_get "parameter.core4_1_enable_multi_func_hwtcl.value"]
    set core4_1_enable_sriov_hwtcl [ip_get "parameter.core4_1_enable_sriov_hwtcl.value"]
    set core4_1_total_pf_count_hwtcl [ip_get "parameter.core4_1_total_pf_count_hwtcl.value"]
    
    if { $core4_1_func_mode == "Enable" && $core4_1_enable_multi_func_hwtcl == 1 && $core4_1_enable_sriov_hwtcl == 0 && $core4_1_total_pf_count_hwtcl < 2 } {
        send_message error "When PCIe3 Multifunction is enabled, the PF count must be greater than 1 or SRIOV must be enabled"
    }
}
proc ::intel_pcie_ss_axi::parameters::validate_core4_1_total_pf_count_hwtcl {PROP_NAME PROP_VALUE core4_1_func_mode_hwtcl core4_1_total_pf_count_hwtcl } {
    set tile [ip_get "parameter.TILE.value"]

    if { $tile == "P-TILE" } {
        set core4_1_total_pf_count_hwtcl $PROP_VALUE
        set core4_1_func [ip_get "parameter.core4_1_func_mode_hwtcl.value"]
        if { ${core4_1_func} == "Enable" } {
            for {set i 0} {$i < [expr {$core4_1_total_pf_count_hwtcl} ]} {incr i} {
                ip_set_param "parameter.core4_1_virtual_pf${i}_enable_hwtcl.value" 1
            }
            for {set i 8} {$i >= [expr {$core4_1_total_pf_count_hwtcl} ]} {incr i -1} {
                ip_set_param "parameter.core4_1_virtual_pf${i}_enable_hwtcl.value" 0
            }
        }
    } elseif { $tile == "R-TILE" } {
       if { $core4_1_func_mode_hwtcl == "Enable" } {
        for {set i 0} {$i < [expr {$core4_1_total_pf_count_hwtcl} ]} {incr i} {
            ip_set_param "parameter.core4_1_virtual_pf${i}_enable_hwtcl.value" 1
        }
        for {set i 8} {$i >= [expr {$core4_1_total_pf_count_hwtcl} ]} {incr i -1} {
            ip_set_param "parameter.core4_1_virtual_pf${i}_enable_hwtcl.value" 0
        }
    } else {
		for {set i 0} {$i < 8} {incr i} {
            ip_set_param "parameter.core4_1_virtual_pf${i}_enable_hwtcl.value" 0
        }
	 }
     
    } elseif { $tile == "F-TILE" } {
        set core4_1_total_pf_count_hwtcl $PROP_VALUE
        set core4_1_func [ip_get "parameter.core4_1_func_mode_hwtcl.value"]
        set topology    [ip_get "parameter.core4_1_topology_hwtcl.value"]
        if { ${core4_1_func} == "Enable" } {
            if { [regexp "1x4" $topology] } {
                ip_set "parameter.core4_1_total_pf_count_hwtcl.ALLOWED_RANGES" {1:4}
            } else {
                ip_set "parameter.core4_1_total_pf_count_hwtcl.ALLOWED_RANGES" {1:8}
            } 
            for {set i 0} {$i < [expr {$core4_1_total_pf_count_hwtcl} ]} {incr i} {
                ip_set_param "parameter.core4_1_virtual_pf${i}_enable_hwtcl.value" 1
            }
            for {set i 8} {$i >= [expr {$core4_1_total_pf_count_hwtcl} ]} {incr i -1} {
                ip_set_param "parameter.core4_1_virtual_pf${i}_enable_hwtcl.value" 0
            }
        }
    }
}



proc ::intel_pcie_ss_axi::parameters::validate_core4_1_pf0_ari_acs_fun_grp_cap_hwtcl { PROP_NAME PROP_VALUE qhip_silicon_reva_revb_hwtcl} {
	#HSD 1509328794
    set core4_1_pf0_acs_cap_acs_p2p_egress_control_hwtcl [ip_get "parameter.core4_1_pf0_acs_cap_acs_p2p_egress_control_hwtcl.value"]
    set core4_1_pf1_acs_cap_acs_p2p_egress_control_hwtcl [ip_get "parameter.core4_1_pf1_acs_cap_acs_p2p_egress_control_hwtcl.value"]
    set core4_1_pf2_acs_cap_acs_p2p_egress_control_hwtcl [ip_get "parameter.core4_1_pf2_acs_cap_acs_p2p_egress_control_hwtcl.value"]
    set core4_1_pf3_acs_cap_acs_p2p_egress_control_hwtcl [ip_get "parameter.core4_1_pf3_acs_cap_acs_p2p_egress_control_hwtcl.value"]
    set core4_1_pf4_acs_cap_acs_p2p_egress_control_hwtcl [ip_get "parameter.core4_1_pf4_acs_cap_acs_p2p_egress_control_hwtcl.value"]
    set core4_1_pf5_acs_cap_acs_p2p_egress_control_hwtcl [ip_get "parameter.core4_1_pf5_acs_cap_acs_p2p_egress_control_hwtcl.value"]
    set core4_1_pf6_acs_cap_acs_p2p_egress_control_hwtcl [ip_get "parameter.core4_1_pf6_acs_cap_acs_p2p_egress_control_hwtcl.value"]
    set core4_1_pf7_acs_cap_acs_p2p_egress_control_hwtcl [ip_get "parameter.core4_1_pf7_acs_cap_acs_p2p_egress_control_hwtcl.value"]

	if { $core4_1_pf0_acs_cap_acs_p2p_egress_control_hwtcl || $core4_1_pf1_acs_cap_acs_p2p_egress_control_hwtcl || $core4_1_pf2_acs_cap_acs_p2p_egress_control_hwtcl|| $core4_1_pf3_acs_cap_acs_p2p_egress_control_hwtcl || $core4_1_pf4_acs_cap_acs_p2p_egress_control_hwtcl  || $core4_1_pf5_acs_cap_acs_p2p_egress_control_hwtcl  || $core4_1_pf6_acs_cap_acs_p2p_egress_control_hwtcl  || $core4_1_pf7_acs_cap_acs_p2p_egress_control_hwtcl  } {
		ip_set_param "parameter.${PROP_NAME}.value" true
	} else {
		ip_set_param "parameter.${PROP_NAME}.value" false
	}

}
proc ::intel_pcie_ss_axi::parameters::validate_core4_1_pf0_eq_redo_hwtcl {PROP_NAME PROP_VALUE core4_1_func_mode_hwtcl core4_1_virtual_rp_ep_mode_integer_hwtcl} {
	#HSD 18020315379: WHR/GDR BCM mapping Disable = 1 and Enable = 0, which reverse compare to RNR
	#Expectation -> EP/UP eq_redo=1, where RP/DN eq_redo=0
	if { $core4_1_func_mode_hwtcl == "Disable"|| $core4_1_virtual_rp_ep_mode_integer_hwtcl == 1} {
        # RP mode
        ip_set_param "parameter.${PROP_NAME}.value" false
    } else {
        ip_set_param "parameter.${PROP_NAME}.value" true
    }
}
proc ::intel_pcie_ss_axi::parameters::validate_core4_1_pf0_eq_phase_2_3_user_hwtcl {core4_1_func_mode_hwtcl core4_1_virtual_rp_ep_mode_integer_hwtcl core4_1_pf0_eq_phase_2_3_user_hwtcl} {
	if { $core4_1_func_mode_hwtcl == "Disable"|| $core4_1_virtual_rp_ep_mode_integer_hwtcl == 0} {
		# EP mode
		ip_set_param "parameter.core4_1_pf0_eq_phase_2_3_hwtcl.value"		false
		ip_set_param "parameter.core4_1_pf0_eq_phase_2_3_atg4_hwtcl.value"	false
		ip_set_param "parameter.core4_1_pf0_eq_phase_2_3_atg5_hwtcl.value"	false
	} else {
		ip_set_param "parameter.core4_1_pf0_eq_phase_2_3_hwtcl.value"		$core4_1_pf0_eq_phase_2_3_user_hwtcl
		ip_set_param "parameter.core4_1_pf0_eq_phase_2_3_atg4_hwtcl.value"	$core4_1_pf0_eq_phase_2_3_user_hwtcl
		ip_set_param "parameter.core4_1_pf0_eq_phase_2_3_atg5_hwtcl.value"	$core4_1_pf0_eq_phase_2_3_user_hwtcl
	}
}
proc ::intel_pcie_ss_axi::parameters::validate_core4_1_pfi_eval_interval_time_hwtcl {core4_1_func_mode_hwtcl core4_1_total_pf_count_hwtcl} {
	 if { $core4_1_func_mode_hwtcl == "Enable" } {
        for {set i 0} {$i < [expr {$core4_1_total_pf_count_hwtcl} ]} {incr i} {
            ip_set_param "parameter.core4_1_pf${i}_eval_interval_time_hwtcl.value" 3
			
        }
        for {set i 8} {$i >= [expr {$core4_1_total_pf_count_hwtcl} ]} {incr i -1} {
            ip_set_param "parameter.core4_1_pf${i}_eval_interval_time_hwtcl.value" 0
        }
    } else {
		for {set i 0} {$i < 8} {incr i} {
            ip_set_param "parameter.core4_1_pf${i}_eval_interval_time_hwtcl.value" 0
        }
	}
}
proc ::intel_pcie_ss_axi::parameters::validate_core4_1_virtual_num_of_lanes_hwtcl {core4_1_func_mode_hwtcl core4_1_topology_hwtcl} {
	 set tile [ip_get "parameter.TILE.value"]
     if {$tile == "F-TILE"} {

    set virtual_num_of_lanes_16 [ip_get "parameter.core4_1_virtual_num_of_lanes_16_hwtcl.value"] 
    set virtual_num_of_lanes_8  [ip_get "parameter.core4_1_virtual_num_of_lanes_8_hwtcl.value"]
    set virtual_num_of_lanes_4  [ip_get "parameter.core4_1_virtual_num_of_lanes_4_hwtcl.value"]
	
    if { $core4_1_func_mode_hwtcl == "Disable" } {
        ip_set_param "parameter.core4_1_virtual_num_of_lanes_hwtcl_f.value" "1"
    } else {
        #TODO: Decode more topology
        if { [regexp "1x16" $core4_1_topology_hwtcl] } {
            ip_set_param "parameter.core4_1_virtual_num_of_lanes_16_hwtcl.VISIBLE" true
            ip_set_param "parameter.core4_1_virtual_num_of_lanes_8_hwtcl.VISIBLE"  false
            ip_set_param "parameter.core4_1_virtual_num_of_lanes_4_hwtcl.VISIBLE"  false
            ip_set_param "parameter.core4_1_virtual_num_of_lanes_hwtcl_f.value" $virtual_num_of_lanes_16
        } elseif { [regexp "2x8" $core4_1_topology_hwtcl] } {
            ip_set_param "parameter.core4_1_virtual_num_of_lanes_16_hwtcl.VISIBLE" false
            ip_set_param "parameter.core4_1_virtual_num_of_lanes_8_hwtcl.VISIBLE"  true
            ip_set_param "parameter.core4_1_virtual_num_of_lanes_4_hwtcl.VISIBLE"  false
            ip_set_param "parameter.core4_1_virtual_num_of_lanes_hwtcl_f.value" $virtual_num_of_lanes_8
        } elseif { [regexp "4x4" $core4_1_topology_hwtcl] } {
            ip_set_param "parameter.core4_1_virtual_num_of_lanes_16_hwtcl.VISIBLE" false
            ip_set_param "parameter.core4_1_virtual_num_of_lanes_8_hwtcl.VISIBLE"  false
            ip_set_param "parameter.core4_1_virtual_num_of_lanes_4_hwtcl.VISIBLE"  true
            ip_set_param "parameter.core4_1_virtual_num_of_lanes_hwtcl_f.value" $virtual_num_of_lanes_4
        } elseif { [regexp "Pipe Direct 8-channel" $core4_1_topology_hwtcl] && [regexp "2x4" $core4_1_topology_hwtcl] } {
            ip_set_param "parameter.core4_1_virtual_num_of_lanes_16_hwtcl.VISIBLE" false
            ip_set_param "parameter.core4_1_virtual_num_of_lanes_8_hwtcl.VISIBLE"  false
            ip_set_param "parameter.core4_1_virtual_num_of_lanes_4_hwtcl.VISIBLE"  true
            ip_set_param "parameter.core4_1_virtual_num_of_lanes_hwtcl_f.value" $virtual_num_of_lanes_4
        } elseif { [regexp "Pipe Direct 8-channel" $core4_1_topology_hwtcl] && [regexp "1x8" $core4_1_topology_hwtcl] } {
            ip_set_param "parameter.core4_1_virtual_num_of_lanes_16_hwtcl.VISIBLE" false
            ip_set_param "parameter.core4_1_virtual_num_of_lanes_8_hwtcl.VISIBLE"  true
            ip_set_param "parameter.core4_1_virtual_num_of_lanes_4_hwtcl.VISIBLE"  false
            ip_set_param "parameter.core4_1_virtual_num_of_lanes_hwtcl_f.value" $virtual_num_of_lanes_8
        } elseif { [regexp "1x8" $core4_1_topology_hwtcl] && [regexp "2x4" $core4_1_topology_hwtcl] } {
            ip_set_param "parameter.core4_1_virtual_num_of_lanes_16_hwtcl.VISIBLE" false
            ip_set_param "parameter.core4_1_virtual_num_of_lanes_8_hwtcl.VISIBLE"  true
            ip_set_param "parameter.core4_1_virtual_num_of_lanes_4_hwtcl.VISIBLE"  false
            ip_set_param "parameter.core4_1_virtual_num_of_lanes_hwtcl_f.value" $virtual_num_of_lanes_8
        } elseif { [regexp "Pipe Direct 16-channel" $core4_1_topology_hwtcl] } {
			ip_set_param "parameter.core4_1_virtual_num_of_lanes_16_hwtcl.VISIBLE" false
            ip_set_param "parameter.core4_1_virtual_num_of_lanes_8_hwtcl.VISIBLE"  false
            ip_set_param "parameter.core4_1_virtual_num_of_lanes_4_hwtcl.VISIBLE"  false
			ip_set_param "parameter.core4_1_virtual_num_of_lanes_hwtcl_f.value"	"1"
		}
    }
  } elseif {$tile =="R-TILE" } {
       set virtual_num_of_lanes_4  [ip_get "parameter.core4_1_virtual_num_of_lanes_4_hwtcl.value"]
	
    if { $core4_1_func_mode_hwtcl == "Disable" } {
		ip_set_param "parameter.core4_1_virtual_num_of_lanes_4_hwtcl.VISIBLE"  false
        ip_set_param "parameter.core4_1_virtual_num_of_lanes_hwtcl_r.value" "1"
    } else {
		ip_set_param "parameter.core4_1_virtual_num_of_lanes_4_hwtcl.VISIBLE"  true
		ip_set_param "parameter.core4_1_virtual_num_of_lanes_hwtcl_r.value" $virtual_num_of_lanes_4
    }
  }

}
proc ::intel_pcie_ss_axi::parameters::validate_core4_1_virtio_cii_ctrl_k_cii_en_hwtcl {core4_1_func_mode_hwtcl core4_1_virtual_cvp_mode_hwtcl core4_1_dwc_ctrl0_k_pld_crs_en_hwtcl core4_1_virtio_cii_ctrl_k_cfg_update_en_attr_hwtcl core4_1_virtual_rp_ep_mode_integer_hwtcl qhip_silicon_reva_revb_hwtcl} {
	#HSD: 1508927048 
	set core4_1_pf0_enable_virtio_hwtcl [ip_get "parameter.core4_1_pf0_virtio_capability_present_hwtcl.value"]
	set core4_1_pf1_enable_virtio_hwtcl [ip_get "parameter.core4_1_pf1_virtio_capability_present_hwtcl.value"]
	set core4_1_pf2_enable_virtio_hwtcl [ip_get "parameter.core4_1_pf2_virtio_capability_present_hwtcl.value"]
	set core4_1_pf3_enable_virtio_hwtcl [ip_get "parameter.core4_1_pf3_virtio_capability_present_hwtcl.value"]
	set core4_1_pf4_enable_virtio_hwtcl [ip_get "parameter.core4_1_pf4_virtio_capability_present_hwtcl.value"]
	set core4_1_pf5_enable_virtio_hwtcl [ip_get "parameter.core4_1_pf5_virtio_capability_present_hwtcl.value"]
	set core4_1_pf6_enable_virtio_hwtcl [ip_get "parameter.core4_1_pf6_virtio_capability_present_hwtcl.value"]
	set core4_1_pf7_enable_virtio_hwtcl [ip_get "parameter.core4_1_pf7_virtio_capability_present_hwtcl.value"]
	
	set core4_1_vf0_enable_virtio_hwtcl [ip_get "parameter.core4_1_pf0vf_virtio_capability_present_hwtcl.value"]
	set core4_1_vf1_enable_virtio_hwtcl [ip_get "parameter.core4_1_pf1vf_virtio_capability_present_hwtcl.value"]
	set core4_1_vf2_enable_virtio_hwtcl [ip_get "parameter.core4_1_pf2vf_virtio_capability_present_hwtcl.value"]
	set core4_1_vf3_enable_virtio_hwtcl [ip_get "parameter.core4_1_pf3vf_virtio_capability_present_hwtcl.value"]
	set core4_1_vf4_enable_virtio_hwtcl [ip_get "parameter.core4_1_pf4vf_virtio_capability_present_hwtcl.value"]
	set core4_1_vf5_enable_virtio_hwtcl [ip_get "parameter.core4_1_pf5vf_virtio_capability_present_hwtcl.value"]
	set core4_1_vf6_enable_virtio_hwtcl [ip_get "parameter.core4_1_pf6vf_virtio_capability_present_hwtcl.value"]
	set core4_1_vf7_enable_virtio_hwtcl [ip_get "parameter.core4_1_pf7vf_virtio_capability_present_hwtcl.value"]

	#cfg_update
	if {$core4_1_func_mode_hwtcl == "Disable" || $core4_1_virtual_cvp_mode_hwtcl == "cvp_legacy" || $core4_1_dwc_ctrl0_k_pld_crs_en_hwtcl == 0} {
		ip_set_param "parameter.core4_1_virtio_cii_ctrl_k_cfg_update_en_attr_hwtcl.value" 0
	} elseif {!$core4_1_virtual_rp_ep_mode_integer_hwtcl} { #EP
		ip_set_param "parameter.core4_1_virtio_cii_ctrl_k_cfg_update_en_attr_hwtcl.value" 1
	} else {
		ip_set_param "parameter.core4_1_virtio_cii_ctrl_k_cfg_update_en_attr_hwtcl.value" 0
	}

	#VIRTIO PF 
	if {$core4_1_func_mode_hwtcl == "Disable" || $core4_1_virtual_cvp_mode_hwtcl == "cvp_legacy"  || $core4_1_dwc_ctrl0_k_pld_crs_en_hwtcl == 0} {
		ip_set_param "parameter.core4_1_virtio_cii_ctrl_k_cii_en_hwtcl.value" 0
	} elseif {$core4_1_virtio_cii_ctrl_k_cfg_update_en_attr_hwtcl == 1} {
		ip_set_param "parameter.core4_1_virtio_cii_ctrl_k_cii_en_hwtcl.value" 1
	} elseif {$core4_1_pf0_enable_virtio_hwtcl == 1} {
		ip_set_param "parameter.core4_1_virtio_cii_ctrl_k_cii_en_hwtcl.value" 1
	} elseif {$core4_1_pf1_enable_virtio_hwtcl == 1} {
		ip_set_param "parameter.core4_1_virtio_cii_ctrl_k_cii_en_hwtcl.value" 1
	} elseif {$core4_1_pf2_enable_virtio_hwtcl == 1} {
		ip_set_param "parameter.core4_1_virtio_cii_ctrl_k_cii_en_hwtcl.value" 1
	} elseif {$core4_1_pf3_enable_virtio_hwtcl == 1} {
		ip_set_param "parameter.core4_1_virtio_cii_ctrl_k_cii_en_hwtcl.value" 1
	} elseif {$core4_1_pf4_enable_virtio_hwtcl == 1} {
		ip_set_param "parameter.core4_1_virtio_cii_ctrl_k_cii_en_hwtcl.value" 1
	} elseif {$core4_1_pf5_enable_virtio_hwtcl == 1} {
		ip_set_param "parameter.core4_1_virtio_cii_ctrl_k_cii_en_hwtcl.value" 1
	} elseif {$core4_1_pf6_enable_virtio_hwtcl == 1} {
		ip_set_param "parameter.core4_1_virtio_cii_ctrl_k_cii_en_hwtcl.value" 1
	} elseif {$core4_1_pf7_enable_virtio_hwtcl == 1} {
		ip_set_param "parameter.core4_1_virtio_cii_ctrl_k_cii_en_hwtcl.value" 1
	} 
	
	#VIRTIO Enable #1508927048 1508932599 1509397718
	if {!$qhip_silicon_reva_revb_hwtcl} {
		#A0
		if {$core4_1_pf0_enable_virtio_hwtcl == 1 || $core4_1_pf1_enable_virtio_hwtcl == 1 || $core4_1_pf2_enable_virtio_hwtcl == 1 || $core4_1_pf3_enable_virtio_hwtcl == 1 || $core4_1_pf4_enable_virtio_hwtcl == 1 || $core4_1_pf5_enable_virtio_hwtcl == 1 || $core4_1_pf6_enable_virtio_hwtcl == 1 || $core4_1_pf7_enable_virtio_hwtcl == 1 || $core4_1_vf0_enable_virtio_hwtcl == 1 || $core4_1_vf1_enable_virtio_hwtcl == 1 || $core4_1_vf2_enable_virtio_hwtcl == 1 || $core4_1_vf3_enable_virtio_hwtcl == 1 || $core4_1_vf4_enable_virtio_hwtcl == 1 || $core4_1_vf5_enable_virtio_hwtcl == 1 || $core4_1_vf6_enable_virtio_hwtcl == 1 || $core4_1_vf7_enable_virtio_hwtcl == 1} {
			ip_set_param "parameter.core4_1_cii_range_1_k_cii_pf_en1_attr_hwtcl.value" 255
			ip_set_param "parameter.core4_1_cii_range_1_k_cii_start_addr1_attr_hwtcl.value" 80
			ip_set_param "parameter.core4_1_cii_range_1_k_cii_addr_size1_attr_hwtcl.value" 30
			
			ip_set_param "parameter.core4_1_cii_range_2_k_cii_pf_en2_attr_hwtcl.value" 255
			ip_set_param "parameter.core4_1_cii_range_2_k_cii_start_addr2_attr_hwtcl.value" 192
			ip_set_param "parameter.core4_1_cii_range_2_k_cii_addr_size2_attr_hwtcl.value" 55
			
			ip_set_param "parameter.core4_1_cii_range_virtio_en_hwtcl.value" false
			send_message info "Enable PCIe 0 VIRTIO will occupied CII Range 1 and CII Range 2."
		} else {
			ip_set_param "parameter.core4_1_cii_range_virtio_en_hwtcl.value" true
		}	
	} else {
		#B0
		if {$core4_1_pf0_enable_virtio_hwtcl == 1 || $core4_1_pf1_enable_virtio_hwtcl == 1 || $core4_1_pf2_enable_virtio_hwtcl == 1 || $core4_1_pf3_enable_virtio_hwtcl == 1 || $core4_1_pf4_enable_virtio_hwtcl == 1 || $core4_1_pf5_enable_virtio_hwtcl == 1 || $core4_1_pf6_enable_virtio_hwtcl == 1 || $core4_1_pf7_enable_virtio_hwtcl == 1 || $core4_1_vf0_enable_virtio_hwtcl == 1 || $core4_1_vf1_enable_virtio_hwtcl == 1 || $core4_1_vf2_enable_virtio_hwtcl == 1 || $core4_1_vf3_enable_virtio_hwtcl == 1 || $core4_1_vf4_enable_virtio_hwtcl == 1 || $core4_1_vf5_enable_virtio_hwtcl == 1 || $core4_1_vf6_enable_virtio_hwtcl == 1 || $core4_1_vf7_enable_virtio_hwtcl == 1} {
			ip_set_param "parameter.core4_1_cii_range_5_k_cii_pf_en5_attr_hwtcl.value" 255
			ip_set_param "parameter.core4_1_cii_range_5_k_cii_start_addr5_attr_hwtcl.value" 80
			ip_set_param "parameter.core4_1_cii_range_5_k_cii_addr_size5_attr_hwtcl.value" 30
			
			ip_set_param "parameter.core4_1_cii_range_6_k_cii_pf_en6_attr_hwtcl.value" 255
			ip_set_param "parameter.core4_1_cii_range_6_k_cii_start_addr6_attr_hwtcl.value" 192
			ip_set_param "parameter.core4_1_cii_range_6_k_cii_addr_size6_attr_hwtcl.value" 55
			
			
					
			ip_set_param "parameter.core4_1_cii_range_virtio_en_hwtcl.value" false
			send_message info "Enable PCIe 0 VIRTIO will occupied CII Range 5 and CII Range 6."
		} else {
			ip_set_param "parameter.core4_1_cii_range_virtio_en_hwtcl.value" true
		}		
	}
}
proc ::intel_pcie_ss_axi::parameters::validate_core4_1_cii_range_k_cii_pf_en_attr_hwtcl {PROP_NAME PROP_VALUE core4_1_func_mode_hwtcl core4_1_virtual_rp_ep_mode_integer_hwtcl core4_1_virtio_cii_ctrl_k_cfg_update_en_attr_hwtcl core4_1_cii_range_virtio_en_hwtcl qhip_silicon_reva_revb_hwtcl} {
	#HSD 1507868838 1508289318 16010875166 14013108890
	regexp {range_.} $PROP_NAME range_num
	regexp {en.} $PROP_NAME en_num
	set core4_1_cii_pf_en [ip_get "parameter.core4_1_cii_${range_num}_k_cii_pf_${en_num}_attr_user_hwtcl.value"]
	if {!$qhip_silicon_reva_revb_hwtcl} {
		#A0
		if { $core4_1_func_mode_hwtcl == "Disable" || $core4_1_virtual_rp_ep_mode_integer_hwtcl == 1 } {
			ip_set_param "parameter.core4_1_cii_${range_num}_k_cii_pf_${en_num}_attr_hwtcl.value" 0
		} elseif { ${en_num} == "en3" } { #1509585156 ARI Next Func
			ip_set_param "parameter.core4_1_cii_range_3_k_cii_pf_en3_attr_hwtcl.value" 255 
		} elseif { ${core4_1_virtio_cii_ctrl_k_cfg_update_en_attr_hwtcl} == 1 && ${en_num} == "en4" } {
			ip_set_param "parameter.core4_1_cii_range_4_k_cii_pf_en4_attr_hwtcl.value" 255
		} elseif { ${core4_1_virtio_cii_ctrl_k_cfg_update_en_attr_hwtcl} == 1 && ${en_num} == "en5" } {
			ip_set_param "parameter.core4_1_cii_range_5_k_cii_pf_en5_attr_hwtcl.value" 255
		} elseif { ${core4_1_virtio_cii_ctrl_k_cfg_update_en_attr_hwtcl} == 1 && ${en_num} == "en6" } {
			ip_set_param "parameter.core4_1_cii_range_6_k_cii_pf_en6_attr_hwtcl.value" 255
		} elseif { ${core4_1_virtio_cii_ctrl_k_cfg_update_en_attr_hwtcl} == 1 && ${en_num} == "en7" } {
			ip_set_param "parameter.core4_1_cii_range_7_k_cii_pf_en7_attr_hwtcl.value" 255
		} elseif { $core4_1_cii_range_virtio_en_hwtcl == "false" && ($en_num == "en1" || $en_num == "en2" || $en_num == "en3") } {
			#When VIRTIO is enable, CII Range 1,2 will be set in ::intel_pcie_ss_axi::parameters::validate_core4_1_virtio_cii_ctrl_k_cii_en_hwtcl
		} elseif { ${core4_1_cii_pf_en} == 1 } {
			ip_set_param "parameter.core4_1_virtio_cii_ctrl_k_cii_en_hwtcl.value" 1
			ip_set_param "parameter.core4_1_cii_${range_num}_k_cii_pf_${en_num}_attr_hwtcl.value" 255
		} else {
			ip_set_param "parameter.core4_1_cii_${range_num}_k_cii_pf_${en_num}_attr_hwtcl.value" 0
		}
	} else {
		#B0
		if { $core4_1_func_mode_hwtcl == "Disable" || $core4_1_virtual_rp_ep_mode_integer_hwtcl == 1 } {
			ip_set_param "parameter.core4_1_cii_${range_num}_k_cii_pf_${en_num}_attr_hwtcl.value" 0
		} elseif { $en_num == "en7" } { #1509585156 ARI Next Func
			ip_set_param "parameter.core4_1_cii_range_7_k_cii_pf_en7_attr_hwtcl.value" 255
		} elseif { $core4_1_cii_range_virtio_en_hwtcl == "false" && ($en_num == "en5" || $en_num == "en6") } {
			#When VIRTIO is enable, CII Range 5,6 will be set in ::intel_pcie_ss_axi::parameters::validate_core4_1_virtio_cii_ctrl_k_cii_en_hwtcl
		} elseif { ${core4_1_cii_pf_en} == 1 } {
			ip_set_param "parameter.core4_1_virtio_cii_ctrl_k_cii_en_hwtcl.value" 1
			ip_set_param "parameter.core4_1_cii_${range_num}_k_cii_pf_${en_num}_attr_hwtcl.value" 255
		} else {
			ip_set_param "parameter.core4_1_cii_${range_num}_k_cii_pf_${en_num}_attr_hwtcl.value" 0
		}
	}
}
proc ::intel_pcie_ss_axi::parameters::validate_core4_1_cii_range_k_cii_start_addr_attr_hwtcl {PROP_NAME PROP_VALUE core4_1_func_mode_hwtcl core4_1_virtual_rp_ep_mode_integer_hwtcl core4_1_virtio_cii_ctrl_k_cfg_update_en_attr_hwtcl core4_1_cii_range_virtio_en_hwtcl qhip_silicon_reva_revb_hwtcl} {
	regexp {range_.} $PROP_NAME range_num
	regexp {addr.} $PROP_NAME addr_num
	
	set core4_1_cii_start_addr4_user [ip_get "parameter.core4_1_cii_range_4_k_cii_start_addr4_attr_user_hwtcl.value"]
	set core4_1_cii_start_addr5_user [ip_get "parameter.core4_1_cii_range_5_k_cii_start_addr5_attr_user_hwtcl.value"]
	set core4_1_cii_start_addr6_user [ip_get "parameter.core4_1_cii_range_6_k_cii_start_addr6_attr_user_hwtcl.value"]
	set core4_1_cii_start_addr7_user [ip_get "parameter.core4_1_cii_range_7_k_cii_start_addr7_attr_user_hwtcl.value"]
	set core4_1_cii_start_addr_user [ip_get "parameter.core4_1_cii_${range_num}_k_cii_start_${addr_num}_attr_user_hwtcl.value"]
	if {!$qhip_silicon_reva_revb_hwtcl} {
		#A0
		if { $core4_1_func_mode_hwtcl == "Disable" || $core4_1_virtual_rp_ep_mode_integer_hwtcl == 1 } {
			ip_set_param "parameter.core4_1_cii_${range_num}_k_cii_start_${addr_num}_attr_hwtcl.value" 0
		} elseif { $addr_num == "addr3" } { #1509585156 ARI Next Func
			ip_set_param "parameter.core4_1_cii_range_3_k_cii_start_addr3_attr_hwtcl.value" 376
		} elseif { ${core4_1_virtio_cii_ctrl_k_cfg_update_en_attr_hwtcl} == 1 && $addr_num == "addr4" } { #14013108890
			ip_set_param "parameter.core4_1_cii_range_4_k_cii_start_addr4_attr_hwtcl.value" 416
		} elseif { ${core4_1_virtio_cii_ctrl_k_cfg_update_en_attr_hwtcl} == 1 && $addr_num == "addr5" } { #16010875166
			ip_set_param "parameter.core4_1_cii_range_5_k_cii_start_addr5_attr_hwtcl.value" 176
		} elseif { ${core4_1_virtio_cii_ctrl_k_cfg_update_en_attr_hwtcl} == 1 && $addr_num == "addr6" } {
			ip_set_param "parameter.core4_1_cii_range_6_k_cii_start_addr6_attr_hwtcl.value" 636
		} elseif { ${core4_1_virtio_cii_ctrl_k_cfg_update_en_attr_hwtcl} == 1 && $addr_num == "addr7" } {
			ip_set_param "parameter.core4_1_cii_range_7_k_cii_start_addr7_attr_hwtcl.value" 128
		} elseif { $addr_num == "addr4" } {
			ip_set_param "parameter.core4_1_cii_range_4_k_cii_start_addr4_attr_hwtcl.value" $core4_1_cii_start_addr4_user
		} elseif { $addr_num == "addr5" } {
			ip_set_param "parameter.core4_1_cii_range_5_k_cii_start_addr5_attr_hwtcl.value" $core4_1_cii_start_addr5_user
		} elseif { $addr_num == "addr6" } {
			ip_set_param "parameter.core4_1_cii_range_6_k_cii_start_addr6_attr_hwtcl.value" $core4_1_cii_start_addr6_user
		} elseif { $addr_num == "addr7" } {
			ip_set_param "parameter.core4_1_cii_range_7_k_cii_start_addr7_attr_hwtcl.value" $core4_1_cii_start_addr7_user	
		} elseif { $core4_1_cii_range_virtio_en_hwtcl == "false" && ($addr_num == "addr1" || $addr_num == "addr2" || $addr_num == "addr3") } {
			#When VIRTIO is enable, CII Range 1,2 will be set in ::intel_pcie_ss_axi::parameters::validate_core4_1_virtio_cii_ctrl_k_cii_en_hwtcl
		} else {
			ip_set_param "parameter.core4_1_cii_${range_num}_k_cii_start_${addr_num}_attr_hwtcl.value" $core4_1_cii_start_addr_user
		} 
	} else {
		#B0
		if { $core4_1_func_mode_hwtcl == "Disable" || $core4_1_virtual_rp_ep_mode_integer_hwtcl == 1 } {
			ip_set_param "parameter.core4_1_cii_${range_num}_k_cii_start_${addr_num}_attr_hwtcl.value" 0
		} elseif { $addr_num == "addr7" } { #1509585156 ARI Next Func
			ip_set_param "parameter.core4_1_cii_range_7_k_cii_start_addr7_attr_hwtcl.value" 376
		} elseif { $core4_1_cii_range_virtio_en_hwtcl == "false" && ($addr_num == "addr5" || $addr_num == "addr6") } {
			#When VIRTIO is enable, CII Range 5,6 will be set in ::intel_pcie_ss_axi::parameters::validate_core4_1_virtio_cii_ctrl_k_cii_en_hwtcl
		} else {
			ip_set_param "parameter.core4_1_cii_${range_num}_k_cii_start_${addr_num}_attr_hwtcl.value" $core4_1_cii_start_addr_user
		}
	}
}
proc ::intel_pcie_ss_axi::parameters::validate_core4_1_cii_range_k_cii_addr_size_attr_hwtcl {PROP_NAME PROP_VALUE core4_1_func_mode_hwtcl core4_1_virtual_rp_ep_mode_integer_hwtcl core4_1_virtio_cii_ctrl_k_cfg_update_en_attr_hwtcl core4_1_cii_range_virtio_en_hwtcl qhip_silicon_reva_revb_hwtcl} {
	#HSD: 1508598149
	regexp {range_.} $PROP_NAME range_num
	regexp {size.} $PROP_NAME size_num
	regexp {._attr} $PROP_NAME addr_num
	
	set core4_1_cii_addr_size4_user [ip_get "parameter.core4_1_cii_range_4_k_cii_addr_size4_attr_user_hwtcl.value"]
	set core4_1_cii_addr_size5_user [ip_get "parameter.core4_1_cii_range_5_k_cii_addr_size5_attr_user_hwtcl.value"]
	set core4_1_cii_addr_size6_user [ip_get "parameter.core4_1_cii_range_6_k_cii_addr_size6_attr_user_hwtcl.value"]
	set core4_1_cii_addr_size7_user [ip_get "parameter.core4_1_cii_range_7_k_cii_addr_size7_attr_user_hwtcl.value"]
	set core4_1_cii_start_addr_user [ip_get "parameter.core4_1_cii_${range_num}_k_cii_start_addr${addr_num}_user_hwtcl.value"]
	set core4_1_cii_addr_size_user [ip_get "parameter.core4_1_cii_${range_num}_k_cii_addr_${size_num}_attr_user_hwtcl.value"]
	if {!$qhip_silicon_reva_revb_hwtcl} {
		#A0
		if { $core4_1_func_mode_hwtcl == "Disable" || $core4_1_virtual_rp_ep_mode_integer_hwtcl == 1 } {
			ip_set_param "parameter.core4_1_cii_${range_num}_k_cii_addr_${size_num}_attr_hwtcl.value" 0
		} elseif { $size_num == "size3" } {#1509585156 ARI Next Func
			ip_set_param "parameter.core4_1_cii_range_3_k_cii_addr_size3_attr_hwtcl.value" 15
		} elseif { ${core4_1_virtio_cii_ctrl_k_cfg_update_en_attr_hwtcl} == 1 && $size_num == "size4" } {
			ip_set_param "parameter.core4_1_cii_range_4_k_cii_addr_size4_attr_hwtcl.value" 3
		} elseif { ${core4_1_virtio_cii_ctrl_k_cfg_update_en_attr_hwtcl} == 1 && $size_num == "size5" } {
			ip_set_param "parameter.core4_1_cii_range_5_k_cii_addr_size5_attr_hwtcl.value" 3
		} elseif { ${core4_1_virtio_cii_ctrl_k_cfg_update_en_attr_hwtcl} == 1 && $size_num == "size6" } {
			ip_set_param "parameter.core4_1_cii_range_6_k_cii_addr_size6_attr_hwtcl.value" 3
		} elseif { ${core4_1_virtio_cii_ctrl_k_cfg_update_en_attr_hwtcl} == 1 && $size_num == "size7" } {
			ip_set_param "parameter.core4_1_cii_range_7_k_cii_addr_size7_attr_hwtcl.value" 3
		} elseif { $size_num == "size4" } {
			ip_set_param "parameter.core4_1_cii_range_4_k_cii_addr_size4_attr_hwtcl.value" $core4_1_cii_addr_size4_user
		} elseif { $size_num == "size5" } {
			ip_set_param "parameter.core4_1_cii_range_5_k_cii_addr_size5_attr_hwtcl.value" $core4_1_cii_addr_size5_user
		} elseif { $size_num == "size6" } {
			ip_set_param "parameter.core4_1_cii_range_6_k_cii_addr_size6_attr_hwtcl.value" $core4_1_cii_addr_size6_user
		} elseif { $size_num == "size7" } {
			ip_set_param "parameter.core4_1_cii_range_7_k_cii_addr_size7_attr_hwtcl.value" $core4_1_cii_addr_size7_user	
		} elseif { $core4_1_cii_range_virtio_en_hwtcl == "false" && ($size_num == "size1" || $size_num == "size2" || $size_num == "size3") } {
			#When VIRTIO is enable, CII Range 1,2 will be set in ::intel_pcie_ss_axi::parameters::validate_core4_1_virtio_cii_ctrl_k_cii_en_hwtcl
		} else {
			set core4_1_cii_allowed_addr_size [expr int(4095 - $core4_1_cii_start_addr_user) ]
			if { $core4_1_cii_addr_size_user > $core4_1_cii_allowed_addr_size} {
				send_message error "The total of start address and address size must not be greater than 0xFFF!"
			} else {
				ip_set_param "parameter.core4_1_cii_${range_num}_k_cii_addr_${size_num}_attr_hwtcl.value" $core4_1_cii_addr_size_user
			}
		}
	} else {
		#B0
		if { $core4_1_func_mode_hwtcl == "Disable" || $core4_1_virtual_rp_ep_mode_integer_hwtcl == 1 } {
			ip_set_param "parameter.core4_1_cii_${range_num}_k_cii_addr_${size_num}_attr_hwtcl.value" 0
		} elseif { $size_num == "size7" } {#1509585156 ARI Next Func
			ip_set_param "parameter.core4_1_cii_range_7_k_cii_addr_size7_attr_hwtcl.value" 15
		} elseif { $core4_1_cii_range_virtio_en_hwtcl == "false" && ($size_num == "size5" || $size_num == "size6") } {
			#When VIRTIO is enable, CII Range 5,6 will be set in ::intel_pcie_ss_axi::parameters::validate_core4_1_virtio_cii_ctrl_k_cii_en_hwtcl
		} else {
			set core4_1_cii_allowed_addr_size [expr int(4095 - $core4_1_cii_start_addr_user) ]
			if { $core4_1_cii_addr_size_user > $core4_1_cii_allowed_addr_size} {
				send_message error "The total of start address and address size must not be greater than 0xFFF!"
			} else {
				ip_set_param "parameter.core4_1_cii_${range_num}_k_cii_addr_${size_num}_attr_hwtcl.value" $core4_1_cii_addr_size_user
			}
		}
	}
}
#####BAR validation callback
proc ::intel_pcie_ss_axi::parameters::validate_core4_1_pf_bar_type_hwtcl {PROP_NAME PROP_VALUE core4_1_func_mode_hwtcl core4_1_virtual_rp_ep_mode_hwtcl} { #ARG: core4_1_virtual_pf${pf}_enable_hwtcl core4_1_pf${pf}_bar${i}_type_user_hwtcl core4_1_pf${pf}_bar${i}_address_width_user_hwtcl
    if { $core4_1_func_mode_hwtcl == "Disable" || $core4_1_virtual_rp_ep_mode_hwtcl == "Root Port"} {
        # if in rootport or core 16 is disabled set all BAR types to disabled and size to N/A
        # loop through all pf 0-7
        for {set pf 0} {$pf < 1} {incr pf 1} {
            # loop through all bars 0-5
            for {set i 0} {$i <= 5} {incr i 1} {
                ip_set_param "parameter.core4_1_pf${pf}_bar${i}_type_hwtcl.value" "Disabled"
                ip_set_param "parameter.core4_1_pf${pf}_bar${i}_address_width_hwtcl.value" 0
                ip_set_param "parameter.core4_1_pf${pf}_bar${i}_mask_integer_hwtcl.value" 0
            }
        }
    } else {
        # else set them to user_hwtcl values

        # loop through all pf 0-7
        for {set pf 0} {$pf < 1} {incr pf 1} {
            set core4_1_virtual_pfi_enable_hwtcl [ip_get "parameter.core4_1_virtual_pf${pf}_enable_hwtcl.value"]
            if { $core4_1_virtual_pfi_enable_hwtcl == 1} {
			
			
                # loop through all bars 0-5
                set core4_1_prev_bar_type "Disable"
                set core4_1_prev_bar_addr_width 0
                for {set i 0} {$i <= 5} {incr i 1} {
                    set core4_1_pf_bar_type_user_hwtcl [get_parameter_value core4_1_pf${pf}_bar${i}_type_user_hwtcl]
                    set core4_1_pf_bar_address_width_user_hwtcl [get_parameter_value core4_1_pf${pf}_bar${i}_address_width_user_hwtcl]	
					
					#ALLOWED_RANGES
					if {[regexp "64-bit" $core4_1_pf_bar_type_user_hwtcl]} {
						ip_set_param "parameter.core4_1_pf${pf}_bar${i}_address_width_user_hwtcl.ALLOWED_RANGES" {"0:N/A" "8: 256 Bytes - 8 bits" "9: 512 Bytes - 9 bits" "10: 1 KByte - 10 bits" "11: 2 KBytes - 11 bits" "12: 4 KBytes - 12 bits" "13: 8 KBytes - 13 bits" "14: 16 KBytes - 14 bits" "15: 32 KBytes - 15 bits" "16: 64 KBytes - 16 bits" "17: 128 KBytes - 17 bits" "18: 256 KBytes - 18 bits" "19: 512 KBytes - 19 bits" "20: 1 MByte - 20 bits" "21: 2 MBytes - 21 bits" "22: 4 MBytes - 22 bits" "23: 8 MBytes - 23 bits" "24: 16 MBytes - 24 bits" "25: 32 MBytes - 25 bits" "26: 64 MBytes - 26 bits" "27: 128 MBytes - 27 bits" "28: 256 MBytes - 28 bits" "29: 512 MBytes - 29 bits" "30: 1 GByte - 30 bits" "31: 2 GBytes - 31 bits" "32: 4 GBytes - 32 bits" "33: 8 GBytes - 33 bits" "34: 16 GBytes - 34 bits" "35: 32 GBytes - 35 bits" "36: 64 GBytes - 36 bits" "37: 128 GBytes - 37 bits" "38: 256 GBytes - 38 bits" "39: 512 GBytes - 39 bits" "40: 1 TByte - 40 bits" "41: 2 TBytes - 41 bits" "42: 4 TBytes - 42 bits" "43: 8 TBytes - 43 bits" "44: 16 TBytes - 44 bits" "45: 32 TBytes - 45 bits" "46: 64 TBytes - 46 bits" "47: 128 TBytes - 47 bits" "48: 256 TBytes - 48 bits" "49: 512 TBytes - 49 bits" "50: 1 PByte - 50 bits" "51: 2 PBytes - 51 bits" "52: 4 PBytes - 52 bits" "53: 8 PBytes - 53 bits" "54: 16 PBytes - 54 bits" "55: 32 PBytes - 55 bits" "56: 64 PBytes - 56 bits" "57: 128 PBytes - 57 bits" "58: 256 PBytes - 58 bits" "59: 512 PBytes - 59 bits" "60: 1 EByte - 60 bits" "61: 2 EBytes - 61 bits" "62: 4 EBytes - 62 bits" "63: 8 EBytes - 63 bits" "64: 16 EBytes - 64 bits"}
					} elseif {[regexp "32-bit" $core4_1_pf_bar_type_user_hwtcl]} {
						ip_set_param "parameter.core4_1_pf${pf}_bar${i}_address_width_user_hwtcl.ALLOWED_RANGES" {"0:N/A" "8: 256 Bytes - 8 bits" "9: 512 Bytes - 9 bits" "10: 1 KByte - 10 bits" "11: 2 KBytes - 11 bits" "12: 4 KBytes - 12 bits" "13: 8 KBytes - 13 bits" "14: 16 KBytes - 14 bits" "15: 32 KBytes - 15 bits" "16: 64 KBytes - 16 bits" "17: 128 KBytes - 17 bits" "18: 256 KBytes - 18 bits" "19: 512 KBytes - 19 bits" "20: 1 MByte - 20 bits" "21: 2 MBytes - 21 bits" "22: 4 MBytes - 22 bits" "23: 8 MBytes - 23 bits" "24: 16 MBytes - 24 bits" "25: 32 MBytes - 25 bits" "26: 64 MBytes - 26 bits" "27: 128 MBytes - 27 bits" "28: 256 MBytes - 28 bits" "29: 512 MBytes - 29 bits" "30: 1 GByte - 30 bits" "31: 2 GBytes - 31 bits" "32: 4 GBytes - 32 bits"}
					}
	
                    # Need to update to support full 64bit address width
                    if { $i == 0 || $i == 2 || $i == 4} {
                        if { $core4_1_pf_bar_address_width_user_hwtcl >= 32 } {
                            set core4_1_pf_bar_mask 2147483647
                        } elseif { $core4_1_pf_bar_address_width_user_hwtcl == 0 } {
                            set core4_1_pf_bar_mask 0
                        } else {
                            #set core4_1_pf_bar_mask($pf,$i) [expr int(~(0xffffffff << $core4_1_pf_bar_address_width_user_hwtcl($pf,$i)) >> 1 )]
                            set core4_1_pf_bar_mask [expr int( 0x1 << [expr $core4_1_pf_bar_address_width_user_hwtcl -1] ) -1 ]
                        }
                        # no actual 
                        set core4_1_virtual_pf_bar_mask_bit0  "false"
                        set core4_1_prev_bar_type $core4_1_pf_bar_type_user_hwtcl
                        set core4_1_prev_bar_addr_width $core4_1_pf_bar_address_width_user_hwtcl 
                    }
                    
                    if { $i == 1 || $i == 3 || $i == 5} {
                        if { [regexp "64-bit" $core4_1_prev_bar_type] } { 
                            if { $core4_1_prev_bar_addr_width > 33 } {
                                set core4_1_pf_bar_mask [expr int( 0x1 << [expr $core4_1_prev_bar_addr_width - 33] ) -1 ]
                                set core4_1_virtual_pf_bar_mask_bit0  "true"
                            } else {
                                set core4_1_pf_bar_mask 0
                                set core4_1_virtual_pf_bar_mask_bit0  "false"
                            }
                        } elseif { $core4_1_pf_bar_address_width_user_hwtcl == 0 } {
                            set core4_1_pf_bar_mask 0                    
                            set core4_1_virtual_pf_bar_mask_bit0  "false"           
                        } else  {
                            set core4_1_pf_bar_mask [expr int( 0x1 << [expr $core4_1_pf_bar_address_width_user_hwtcl -1] ) -1 ]
                            set core4_1_virtual_pf_bar_mask_bit0  "false"
                        }
						ip_set_param "parameter.core4_1_virtual_pf${pf}_bar${i}_mask_bit0_hwtcl.value" $core4_1_virtual_pf_bar_mask_bit0
                    }

                    ip_set_param "parameter.core4_1_pf${pf}_bar${i}_type_hwtcl.value" $core4_1_pf_bar_type_user_hwtcl
                    ip_set_param "parameter.core4_1_pf${pf}_bar${i}_address_width_hwtcl.value" $core4_1_pf_bar_address_width_user_hwtcl
                    ip_set_param "parameter.core4_1_pf${pf}_bar${i}_mask_integer_hwtcl.value" $core4_1_pf_bar_mask
                }




			} else {
                for {set i 0} {$i <= 5} {incr i 1} {
                    ip_set_param "parameter.core4_1_pf${pf}_bar${i}_type_hwtcl.value" "Disabled"
                    ip_set_param "parameter.core4_1_pf${pf}_bar${i}_address_width_hwtcl.value" 0
                    ip_set_param "parameter.core4_1_pf${pf}_bar${i}_mask_integer_hwtcl.value" 0
                    ip_set_param "parameter.core4_1_virtual_pf${pf}_bar${i}_mask_bit0_hwtcl.value" "false"
                }
            }
        }
    }
}
proc ::intel_pcie_ss_axi::parameters::validate_core4_1_pf_bar_type_VISIBLE_hwtcl {PROP_NAME PROP_VALUE} {
	regexp {pf.} $PROP_NAME pf_num
	set core4_1_virtual_pfi_enable_hwtcl [ip_get "parameter.core4_1_virtual_${pf_num}_enable_hwtcl.value"]
    if { $core4_1_virtual_pfi_enable_hwtcl == 1} {
		set core4_1_pf_bar_val  [ip_get "parameter.core4_1_${pf_num}_bar0_type_hwtcl.value"]
        set core4_1_pf_bar2_val [ip_get "parameter.core4_1_${pf_num}_bar2_type_hwtcl.value"]
        set core4_1_pf_bar4_val [ip_get "parameter.core4_1_${pf_num}_bar4_type_hwtcl.value"]
        
        if { [regexp "64-bit" $core4_1_pf_bar_val] }  {
			ip_set_param "parameter.core4_1_${pf_num}_bar1_type_hwtcl.value" "Disabled"
            ip_set_param "parameter.core4_1_${pf_num}_bar1_type_user_hwtcl.ENABLED" false
        } else {
            ip_set_param "parameter.core4_1_${pf_num}_bar1_type_user_hwtcl.ENABLED" true
        }
        if { [regexp "64-bit" $core4_1_pf_bar2_val] }  {
			ip_set_param "parameter.core4_1_${pf_num}_bar3_type_hwtcl.value" "Disabled"
            ip_set_param "parameter.core4_1_${pf_num}_bar3_type_user_hwtcl.ENABLED" false
        } else {
            ip_set_param "parameter.core4_1_${pf_num}_bar3_type_user_hwtcl.ENABLED" true
        } 
        if { [regexp "64-bit" $core4_1_pf_bar4_val] }  {
			ip_set_param "parameter.core4_1_${pf_num}_bar5_type_hwtcl.value" "Disabled"
            ip_set_param "parameter.core4_1_${pf_num}_bar5_type_user_hwtcl.ENABLED" false
        } else {
            ip_set_param "parameter.core4_1_${pf_num}_bar5_type_user_hwtcl.ENABLED" true
        } 
	}
}
proc ::intel_pcie_ss_axi::parameters::validate_core4_1_pfi_rombarenabled_expansionbase_hwtcl {PROP_NAME PROP_VALUE} {  #ARG: core4_1_pf${i}_expansion_base_address_register_hwtcl
    set core4_1_pfi_expansion_base_address_register_hwtcl      [ip_get "parameter.core4_1_pf0_expansion_base_address_register_hwtcl.value"]
    if { ${core4_1_pfi_expansion_base_address_register_hwtcl} ==0  }  {
        ip_set_param "parameter.core4_1_pf0_rom_bar_enabled_hwtcl.value" "disable"
		set rom_bar_mask 0
    } else {
        ip_set_param "parameter.core4_1_pf0_rom_bar_enabled_hwtcl.value" "enable"
		set rom_bar_mask [expr [expr int( 0x1 << [expr $core4_1_pfi_expansion_base_address_register_hwtcl ] ) -1 ] >> 11]
    }
	ip_set_param "parameter.core4_1_pf0_rom_bar_mask_integer_hwtcl.value" $rom_bar_mask

}



proc ::intel_pcie_ss_axi::parameters::validate_core4_1_pf0_ari_acs_fun_grp_cap_hwtcl_r { PROP_NAME PROP_VALUE qhip_silicon_reva_revb_hwtcl } {
	#HSD 1509328794
    set core4_1_pf0_acs_cap_acs_p2p_egress_control_hwtcl [ip_get "parameter.core4_1_pf0_acs_cap_acs_p2p_egress_control_hwtcl.value"]

	if { $core4_1_pf0_acs_cap_acs_p2p_egress_control_hwtcl } {
		ip_set_param "parameter.${PROP_NAME}.value" true
	} else {
		ip_set_param "parameter.${PROP_NAME}.value" false
	}
}



#----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
#Ptile SS only Param Validation Callback

proc ::intel_pcie_ss_axi::parameters::validate_core4_1_pld_crs_en_hwtcl { PROP_NAME PROP_VALUE core4_1_func_mode_hwtcl core4_1_virtual_rp_ep_mode_integer_hwtcl core4_1_virtual_tlp_bypass_en_hwtcl core4_1_enable_power_mgnt_intf_hwtcl} {
##    if {$core4_1_func_mode_hwtcl == "Enable"} {
##        if {$core4_1_virtual_rp_ep_mode_integer_hwtcl == 0 && $core4_1_virtual_tlp_bypass_en_hwtcl == 0 && $core4_1_enable_power_mgnt_intf_hwtcl == 1} {
##            ip_set_param "parameter.core4_1_pld_crs_en_hwtcl.value" 1
##        } else {
##            ip_set_param "parameter.core4_1_pld_crs_en_hwtcl.value" 0
##        }
##    } else {
##        ip_set_param "parameter.core4_1_pld_crs_en_hwtcl.value" 0
##    }
}

proc ::intel_pcie_ss_axi::parameters::validate_core4_1_dbi_ro_wr_disable_hwtcl { PROP_NAME PROP_VALUE core4_1_virtual_dbi_ro_wr_disable_hwtcl core4_1_func_mode_hwtcl } {
    set tile [ip_get "parameter.TILE.value"]
    #Below is for R-Tile
	if {$tile == "R-TILE"} {
        if { $core4_1_func_mode_hwtcl == "Disable" } {
            ip_set_param "parameter.${PROP_NAME}.value" 1
        } else {
            if { $core4_1_virtual_dbi_ro_wr_disable_hwtcl == 0 } {
                #set to 1 means not writable
                ip_set_param "parameter.${PROP_NAME}.value" 1
            } else {
                ip_set_param "parameter.${PROP_NAME}.value" 0
            }
        }
    } elseif {$tile == "P-TILE"} {
        #P-Tile needs to set to 0 due to BCMRBC rulings
        if { $core4_1_func_mode_hwtcl == "Disable" } {
            ip_set_param "parameter.${PROP_NAME}.value" 0
            set_qhip_param "hssi_ctp_u_wrpcie_top_u_core4_1_dbi_ro_wr_disable" false
        } else {
            if { $core4_1_virtual_dbi_ro_wr_disable_hwtcl == 0 } {
                #set to 1 means not writable
                ip_set_param "parameter.${PROP_NAME}.value" 1
                set_qhip_param "hssi_ctp_u_wrpcie_top_u_core4_1_dbi_ro_wr_disable" true
            } else {
                ip_set_param "parameter.${PROP_NAME}.value" 0
                set_qhip_param "hssi_ctp_u_wrpcie_top_u_core4_1_dbi_ro_wr_disable" false
            }
        }
    } else {
        #F-Tile dbi_ro_wr_disable handling is done in hip_top terp file, passing parameter directly straight through
        if { $core4_1_virtual_dbi_ro_wr_disable_hwtcl == 0 } {
            #set to 1 means not writable
            ip_set_param "parameter.${PROP_NAME}.value" 0
        } else {
            ip_set_param "parameter.${PROP_NAME}.value" 1
        }
    }
}

proc ::intel_pcie_ss_axi::parameters::validate_core4_1_sn_ser_num_reg_i_dw_hwtcl {PROP_NAME PROP_VALUE core4_1_func_mode_hwtcl core4_1_sn_ser_num_reg_1_dw_hwtcl core4_1_sn_ser_num_reg_2_dw_hwtcl} {
	set core4_1_virtual_pfi_enable_hwtcl [ip_get "parameter.core4_1_virtual_pf0_enable_hwtcl.value"]
	if {$core4_1_func_mode_hwtcl == "Disable" || $core4_1_virtual_pfi_enable_hwtcl == 0} {
		ip_set_param "parameter.core4_1_pf0_sn_ser_num_reg_1_dw_hwtcl.value" 0
		ip_set_param "parameter.core4_1_pf0_sn_ser_num_reg_2_dw_hwtcl.value" 0
	} else {
		ip_set_param "parameter.core4_1_pf0_sn_ser_num_reg_1_dw_hwtcl.value" $core4_1_sn_ser_num_reg_1_dw_hwtcl
		ip_set_param "parameter.core4_1_pf0_sn_ser_num_reg_2_dw_hwtcl.value" $core4_1_sn_ser_num_reg_2_dw_hwtcl
	}
}

proc ::intel_pcie_ss_axi::parameters::validate_core4_1_pf0_pcie_cap_rcb_hwtcl { PROP_NAME PROP_VALUE } {
    set core4_1_func [ip_get "parameter.core4_1_func_mode_hwtcl.value"]
    set core4_1_virtual_rp_ep_mode_integer [ip_get "parameter.core4_1_virtual_rp_ep_mode_integer_hwtcl.value"]

    if { $core4_1_func == "Disable" || $core4_1_virtual_rp_ep_mode_integer == 0} {
        ip_set_param "parameter.${PROP_NAME}.value" "pf0_rcb_64"
    } else {
        ip_set_param "parameter.${PROP_NAME}.value" "pf0_rcb_128"
    }
}

proc ::intel_pcie_ss_axi::parameters::validate_core4_1_pf0_tph_req_cap_st_table_loc_1_derived_hwtcl { PROP_NAME PROP_VALUE } {
    set tile [ip_get "parameter.TILE.value"]
    if {$tile == "P-TILE"} {
        set core4_1_func [ip_get "parameter.core4_1_func_mode_hwtcl.value"]
        set core4_1_pf0_tph_req_cap_st_table_loc_1_hwtcl [ip_get "parameter.core4_1_pf0_tph_req_cap_st_table_loc_1_hwtcl.value"]

        if { $core4_1_func == "Disable" } {
            ip_set_param "parameter.${PROP_NAME}.value" "pf0_not_in_msix_table"
        } else {
            ip_set_param "parameter.${PROP_NAME}.value" $core4_1_pf0_tph_req_cap_st_table_loc_1_hwtcl
        }
    }
}

proc ::intel_pcie_ss_axi::parameters::validate_core4_1_pf0_tph_req_cap_st_table_loc_1_vfcomm_cs2_hwtcl { PROP_NAME PROP_VALUE } {
    set tile [ip_get "parameter.TILE.value"]
    if {$tile == "P-TILE"} {

        set core4_1_func [ip_get "parameter.core4_1_func_mode_hwtcl.value"]

        if { $core4_1_func == "Disable" } {
            ip_set_param "parameter.${PROP_NAME}.value" "pf0_not_in_msix_table_vf"
        } else {
            ip_set_param "parameter.${PROP_NAME}.value" "pf0_in_msix_table_vf"
        }
    }
}







#----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
#Ftile SS only Param Validation Callback
proc ::intel_pcie_ss_axi::parameters::validate_core4_1_pld_clrpcs_hwtcl { PROP_NAME PROP_VALUE } {
    set tile [ip_get "parameter.TILE.value"]
    if {$tile == "F-TILE"} {

        set core4_1_func_mode_integer              [ip_get "parameter.core4_1_func_mode_integer_hwtcl.value"]
        set pld_clrpcs                             [ip_get "parameter.pld_clrpcs_hwtcl.value"]
        set core4_1_virtual_rp_ep_mode_integer     [ip_get "parameter.core4_1_virtual_rp_ep_mode_integer_hwtcl.value"]
        set core4_1_tlp_bypass_isDownstream        [ip_get "parameter.core4_1_tlp_bypass_isDownstream_hwtcl.value"]
        set core4_1_virtual_tlp_bypass_en          [ip_get "parameter.core4_1_virtual_tlp_bypass_en_hwtcl.value"]
        set core4_1_pld_clrpcs_user                [ip_get "parameter.core4_1_pld_clrpcs_user_hwtcl.value"]
        set pld_clrpcs_user_features               [get_quartus_ini "pld_clrpcs_user_features" ENABLED]

            if { $core4_1_func_mode_integer == 1} {
                if { $core4_1_virtual_rp_ep_mode_integer == 0 || ($core4_1_virtual_tlp_bypass_en == 1 && $core4_1_tlp_bypass_isDownstream == 0) } {
                    if { $pld_clrpcs_user_features == 1} {
                        if { $pld_clrpcs == 1} {
                            if {$core4_1_pld_clrpcs_user =="GPIO Perst"} {
                                ip_set_param "parameter.core4_1_pld_clrpcs_hwtcl.value" 1
                            } else {
                                ip_set_param "parameter.core4_1_pld_clrpcs_hwtcl.value" 0
                            }
                        } else {
                            ip_set_param "parameter.core4_1_pld_clrpcs_hwtcl.value" 0
                        }
                    } elseif { $pld_clrpcs == 1} {
                        ip_set_param "parameter.core4_1_pld_clrpcs_hwtcl.value" 1
                    } else {
                        ip_set_param "parameter.core4_1_pld_clrpcs_hwtcl.value" 0
                    }
                } else {
                    ip_set_param "parameter.core4_1_pld_clrpcs_hwtcl.value" 0
                }
            } else {
                ip_set_param "parameter.core4_1_pld_clrpcs_hwtcl.value" 0
            }
    }
}

proc ::intel_pcie_ss_axi::parameters::validate_core4_1_pf0_dsp_16g_tx_preset_hwtcl {PROP_NAME PROP_VALUE} {
    set core4_1_func_mode [ip_get "parameter.core4_1_func_mode_hwtcl.value"]
    set core4_1_virtual_rp_ep_mode_integer_hwtcl [ip_get "parameter.core4_1_virtual_rp_ep_mode_integer_hwtcl.value"]
    set core4_1_virtual_link_rate_hwtcl [ip_get "parameter.core4_1_virtual_link_rate_hwtcl.value"]

    if { $core4_1_func_mode == "Disable" || $core4_1_virtual_rp_ep_mode_integer_hwtcl == 0 || $core4_1_virtual_link_rate_hwtcl == "Gen3 (8.0 Gbps)"} {
        ip_set_param "parameter.${PROP_NAME}.value" 0
    } else {
        ip_set_param "parameter.${PROP_NAME}.value" 8
    }
}

proc ::intel_pcie_ss_axi::parameters::validate_core4_1_pf0_dsp_tx_preset_hwtcl {PROP_NAME PROP_VALUE} {
    set core4_1_func_mode [ip_get "parameter.core4_1_func_mode_hwtcl.value"]
    set core4_1_virtual_rp_ep_mode_integer_hwtcl [ip_get "parameter.core4_1_virtual_rp_ep_mode_integer_hwtcl.value"]

    if { $core4_1_func_mode == "Disable" || $core4_1_virtual_rp_ep_mode_integer_hwtcl == 0} {
        ip_set_param "parameter.${PROP_NAME}.value" 0
    } else {
        ip_set_param "parameter.${PROP_NAME}.value" 8
    }
}

proc ::intel_pcie_ss_axi::parameters::validate_core4_1_pf0_gen_eq_pset_req_vec_hwtcl {PROP_NAME PROP_VALUE core4_1_func_mode_hwtcl core4_1_pf0_gen3_eq_pset_req_vec_a0_user_hwtcl core4_1_pf0_gen3_eq_pset_req_vec_atg4_a0_user_hwtcl core4_1_pf0_gen3_eq_pset_req_vec_b0_user_hwtcl core4_1_pf0_gen3_eq_pset_req_vec_atg4_b0_user_hwtcl generating_b0_hwtcl qhip_silicon_reva_revb_hwtcl} {
    set tile [ip_get "parameter.TILE.value"]
    if {$tile == "F-TILE"} {

        if { $core4_1_func_mode_hwtcl == "Disable" } {
            ip_set_param "parameter.core4_1_pf0_gen3_eq_pset_req_vec_hwtcl_f.value" 32
            ip_set_param "parameter.core4_1_pf0_gen3_eq_pset_req_vec_atg4_hwtcl_f.value" 1023
        } else {
            if { !$generating_b0_hwtcl } {
                #A0 
                ip_set_param "parameter.core4_1_pf0_gen3_eq_pset_req_vec_hwtcl_f.value" $core4_1_pf0_gen3_eq_pset_req_vec_a0_user_hwtcl
                ip_set_param "parameter.core4_1_pf0_gen3_eq_pset_req_vec_atg4_hwtcl_f.value" $core4_1_pf0_gen3_eq_pset_req_vec_atg4_a0_user_hwtcl
            } else {
                #B0
                ip_set_param "parameter.core4_1_pf0_gen3_eq_pset_req_vec_hwtcl_f.value" $core4_1_pf0_gen3_eq_pset_req_vec_b0_user_hwtcl
                ip_set_param "parameter.core4_1_pf0_gen3_eq_pset_req_vec_atg4_hwtcl_f.value" $core4_1_pf0_gen3_eq_pset_req_vec_atg4_b0_user_hwtcl
            }
        }
    }
      
}

proc ::intel_pcie_ss_axi::parameters::validate_core4_1_virtual_num_of_lanes_hwtcl {core4_1_func_mode_hwtcl core4_1_topology_hwtcl } {
    set tile [ip_get "parameter.TILE.value"]
    if {$tile == "F-TILE"} {    
        set virtual_num_of_lanes  [ip_get "parameter.core4_1_virtual_num_of_lanes_4_hwtcl.value"]
        set core4_1_func [ip_get "parameter.core4_1_func_mode_hwtcl.value"]

        if { $core4_1_func == "Disable" } {
            ip_set_param "parameter.core4_1_virtual_num_of_lanes_hwtcl_f.value" 1
        } else {
            ip_set_param "parameter.core4_1_virtual_num_of_lanes_hwtcl_f.value" $virtual_num_of_lanes
        }
   } elseif {$tile =="R-TILE" } {
       set virtual_num_of_lanes_4  [ip_get "parameter.core4_1_virtual_num_of_lanes_4_hwtcl.value"]
	
    if { $core4_1_func_mode_hwtcl == "Disable" } {
		ip_set_param "parameter.core4_1_virtual_num_of_lanes_4_hwtcl.VISIBLE"  false
        ip_set_param "parameter.core4_1_virtual_num_of_lanes_hwtcl_r.value" "1"
    } else {
		ip_set_param "parameter.core4_1_virtual_num_of_lanes_4_hwtcl.VISIBLE"  true
		ip_set_param "parameter.core4_1_virtual_num_of_lanes_hwtcl_r.value" $virtual_num_of_lanes_4
    }
  }

}

proc ::intel_pcie_ss_axi::parameters::validate_core4_1_pld_clrpcs_user_features {} {
    set tile [ip_get "parameter.TILE.value"]
    if {$tile == "F-TILE"} {
            # Debug Features for Internal and External Customer
            # This callback must put at the last parameter of the list, or else the VISIBLE will not take effect
            #VISIBLE default set to false

            ip_set_param "parameter.core4_1_pld_clrpcs_user_hwtcl.ENABLED" false
            ip_set_param "parameter.core4_1_pld_clrpcs_user_hwtcl.VISIBLE" false

            set pld_clrpcs_user_features               [get_quartus_ini "pld_clrpcs_user_features" ENABLED]
            set pld_clrpcs                             [ip_get "parameter.pld_clrpcs_hwtcl.value"]
            set core4_1_func_mode_integer              [ip_get "parameter.core4_1_func_mode_integer_hwtcl.value"]
            set core4_1_virtual_rp_ep_mode_integer     [ip_get "parameter.core4_1_virtual_rp_ep_mode_integer_hwtcl.value"]
            set core4_1_tlp_bypass_isDownstream        [ip_get "parameter.core4_1_tlp_bypass_isDownstream_hwtcl.value"]
            set core4_1_virtual_tlp_bypass_en          [ip_get "parameter.core4_1_virtual_tlp_bypass_en_hwtcl.value"]

            if {$pld_clrpcs_user_features == 1} {
                if { $core4_1_func_mode_integer == 1} {
                    if { $core4_1_virtual_rp_ep_mode_integer == 0 || ($core4_1_virtual_tlp_bypass_en == 1 && $core4_1_tlp_bypass_isDownstream == 0) } {
                        if {$pld_clrpcs == 1} {
                            ip_set_param "parameter.core4_1_pld_clrpcs_user_hwtcl.VISIBLE" true
                            ip_set_param "parameter.core4_1_pld_clrpcs_user_hwtcl.ENABLED" true
                        } else {
                            ip_set_param "parameter.core4_1_pld_clrpcs_user_hwtcl.VISIBLE" false
                            ip_set_param "parameter.core4_1_pld_clrpcs_user_hwtcl.ENABLED" false
                        }
                    } else {
                        ip_set_param "parameter.core4_1_pld_clrpcs_user_hwtcl.VISIBLE" false
                        ip_set_param "parameter.core4_1_pld_clrpcs_user_hwtcl.ENABLED" false
                    }
                } else {
                    ip_set_param "parameter.core4_1_pld_clrpcs_user_hwtcl.VISIBLE" false
                    ip_set_param "parameter.core4_1_pld_clrpcs_user_hwtcl.ENABLED" false
                }
            } else {
                ip_set_param "parameter.core4_1_pld_clrpcs_user_hwtcl.VISIBLE" false
                ip_set_param "parameter.core4_1_pld_clrpcs_user_hwtcl.ENABLED" false
            }
    }
}


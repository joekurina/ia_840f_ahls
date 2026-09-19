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


package provide intel_pcie_ss_axi::example 19.1
package require intel_pcie_ss_axi::parameters

package require altera_terp
package require alt_xcvr::ip_tcl::ip_module

namespace eval ::intel_pcie_ss_axi::example:: {
    namespace import ::alt_xcvr::ip_tcl::ip_module::*
    namespace export \
    variable generated_name
    set generated_name "ftile_s20_v0__pcie__tile_0"
    variable rp_generated_name
    set rp_generated_name "ftile_s20_v0__pcie__tile_0"

    # Main entry point proc when the user clicks the generate example design button in GUI 
    proc ::intel_pcie_ss_axi::dynamic_example_design {} {
        send_message info "Auto-generation of QSYS example design beginning..."
        set valid_design_example [ ::intel_pcie_ss_axi::validate_design_example ]
        if { $valid_design_example != 1 } {
            send_message error "$valid_design_example"
        } else {
            ::intel_pcie_ss_axi::generate_dynamic_qsys
        }
    }

    # Making sure that the parameter settings are valid for example design 
    proc ::intel_pcie_ss_axi::validate_design_example {} {
        
        send_message info "Validating example design parameters and selection..."

        set top_topology_hwtcl                      [ip_get "parameter.top_topology_hwtcl.value"]
        set func_mode_int                           [ip_get "parameter.pcie_ss_func_mode_integer_hwtcl.value"]
        set tile_name                               [ip_get "parameter.TILE.value"]
        set hdr_schme                               [ip_get "parameter.core16_header_scheme_hwtcl.value"]
        set hdr_pck_schme                           [ip_get "parameter.core16_hip_native_mode_user_hwtcl.value"]
        set enable_multi_func_hwtcl_16              [ip_get "parameter.core16_enable_multi_func_hwtcl.value"]
        set enable_multi_func_hwtcl_8               [ip_get "parameter.core8_enable_multi_func_hwtcl.value"]
        set enable_multi_func_hwtcl_4_0             [ip_get "parameter.core4_0_enable_multi_func_hwtcl.value"]
        set enable_multi_func_hwtcl_4_1             [ip_get "parameter.core4_1_enable_multi_func_hwtcl.value"]
        set enable_sriov_hwtcl_16                   [ip_get "parameter.core16_enable_sriov_hwtcl.value"]
        set enable_sriov_hwtcl_8                    [ip_get "parameter.core8_enable_sriov_hwtcl.value"]
        set enable_sriov_hwtcl_4_0                  [ip_get "parameter.core4_0_enable_sriov_hwtcl.value"]
        set enable_sriov_hwtcl_4_1                  [ip_get "parameter.core4_1_enable_sriov_hwtcl.value"]
        set rp_ep_mode                              [ip_get "parameter.core16_virtual_rp_ep_mode_hwtcl.value"]
        set example_design_mode_hwtcl               [ip_get "parameter.example_design_mode_hwtcl.value"]
        set pld_freq_MHz                            [ip_get "parameter.pld_clkfreq_hwtcl.value"]
        set pld_clk_freq_hwtcl                      [scan $pld_freq_MHz %d]
        
        # Validating parameters for Example Design
        if {$tile_name == "F-TILE"} {
            #1 F-Tile Supported Example Design checking
            if { $rp_ep_mode != "Native Endpoint" } {
                return "Please change the Port Type to Native Endpoint. ${rp_ep_mode} is currently not supported for example design."
            }
            
            if { ($enable_multi_func_hwtcl_16 && [ regexp "PERFORMANCE_DESIGN" $example_design_mode_hwtcl]) || ($enable_sriov_hwtcl_16 && [ regexp "PERFORMANCE_DESIGN" $example_design_mode_hwtcl]) ||  (![regexp "Gen4 1x16" $top_topology_hwtcl] && [ regexp "PERFORMANCE_DESIGN" $example_design_mode_hwtcl]) } {
                return "Performance example design is only supported for Gen4 1x16 non-SRIOV only." 
            } 
            
            if { ![regexp "x16" $top_topology_hwtcl] && $enable_multi_func_hwtcl_16 == 1} {
                return "SRIOV Example Design is not provided for ${top_topology_hwtcl}. At this moment, SRIOV Example Design is only provided for 1x16 (Gen3/Gen4) Endpoint."
            }
            
            if { [regexp "x16" $top_topology_hwtcl] || [regexp "x8" $top_topology_hwtcl]} {
                send_message info "Parametrization is valid."
                return 1
            } else {
                return "Design Example is not provided for ${top_topology_hwtcl}. At this moment, only 1x16, 1x8 and 2x8 Endpoint PIO Example Design is supported"
            }
            
        } elseif {$tile_name == "R-TILE"} {
        #2 R-Tile Supported Example Design checking
            if { $rp_ep_mode == "Root Port" } {
                return "Please change the Port Type to Native Endpoint. Root Port is currently not supported for example design."
            }
            
            if { ($pld_clk_freq_hwtcl < 350 ) && [ regexp "PERFORMANCE_DESIGN" $example_design_mode_hwtcl] } {
                return "For performance Design select the PLD CLOCK FREQUENCY greater than or equals to 350 MHz"
            }
 
            if { ([ regexp "PERFORMANCE_DESIGN" $example_design_mode_hwtcl]) && (!([regexp "Gen5 1x16" $top_topology_hwtcl])) && (!([regexp "Gen5 2x8" $top_topology_hwtcl])) && (!([regexp "Gen5 4x4" $top_topology_hwtcl]))} {
                return "Performance example design is only supported for Gen5 1x16 non-SRIOV, Gen5 2x8 non-SRIOV and Gen5 4x4 non-SRIOV" 
            } 
            
            if { [regexp "1x16" $top_topology_hwtcl] || [regexp "2x8" $top_topology_hwtcl] || ([ regexp "PERFORMANCE_DESIGN" $example_design_mode_hwtcl] && [regexp "Gen5 4x4" $top_topology_hwtcl])} {
                send_message info "Parametrization is valid."
                return 1
            } else {
                return "Design Example is not provided for ${top_topology_hwtcl}. At this moment, only 1x16 and 2x8 Endpoint PIO Example Design is supported"
            }
        } else {
        #3 P-Tile Supported Example Design checking
            if { $rp_ep_mode != "Native Endpoint" } {
                return "Please change the Port Type to Native Endpoint. ${rp_ep_mode} is currently not supported for example design."
            }

            if { ($enable_multi_func_hwtcl_16 && [ regexp "PERFORMANCE_DESIGN" $example_design_mode_hwtcl]) || ($enable_sriov_hwtcl_16 && [ regexp "PERFORMANCE_DESIGN" $example_design_mode_hwtcl]) || (![regexp "Gen4 1x16" $top_topology_hwtcl] && [ regexp "PERFORMANCE_DESIGN" $example_design_mode_hwtcl]) } {
                return "Performance example design is only supported for Gen4 1x16 non-SRIOV only." 
            } 
        
            if { (![regexp "x16" $top_topology_hwtcl] ||![regexp "2x8" $top_topology_hwtcl]) && $enable_multi_func_hwtcl_16 == 1} {
                return "SRIOV Example Deisgn is not provided for ${top_topology_hwtcl}. At this moment, SRIOV Example Design is only provided for 1x16 (Gen3/Gen4) Endpoint & 2x8 (Gen3/Gen4) Endpoint."
            }
            
            if { [regexp "x16" $top_topology_hwtcl] || [regexp "x8" $top_topology_hwtcl] } {
                send_message info "Parametrization is valid."
                return 1
            } else {
                return "Design Example is not provided for P-tile Avalon-ST for PCI Express ${top_topology_hwtcl}"
            }
        }
    }
        
    # create the tcl script to create a platform designer system
    proc ::intel_pcie_ss_axi::generate_dynamic_qsys {} {
        
        send_message info "Auto-generation of QSYS example design in progress based on variant parameter settings"

        set DeviceQSF [ip_get "parameter.chosen_devkit_opn_hwtcl.value"]

       # JW: Potential tunable parameter at HELPBK IP
       # Functional Mode
       set func_mode_int [ip_get "parameter.pcie_ss_func_mode_integer_hwtcl.value"]
       set func_mode     [ip_get "parameter.pcie_ss_func_mode_hwtcl.value"]
       set ctrl_shadow_en                          [ip_get "parameter.core16_ctrl_shadow_en_hwtcl.value"]
       set ceb_en                          [ip_get "parameter.core16_ceb_en_hwtcl.value"]
       set xcvr_reconfig                          [ip_get "parameter.xcvr_reconfig_hwtcl.value"]


        # QSYS script to auto-generate QSYS system
        set ORIDIR [pwd]
        set TEMPPATH [create_temp_file ""]

        set QSYSTemName "pcie_ss_ed"
        set QSYSTem "${QSYSTemName}.qsys"
        set QSYSTemPath "${TEMPPATH}${QSYSTem}"
        set QSYSScript "pcie_ss_ed.tcl"
        set QSYSScriptLog "pcie_ss_ed_tcl_log.txt"
        set QSYSScriptPath "${TEMPPATH}${QSYSScript}"
        set QSYSScriptLogPath "${TEMPPATH}${QSYSScriptLog}"
        set instance_name "dut"
        
        # Cleaning up old files and setting up Script File pcie_ed.tcl
        if { [ file exist $QSYSScriptPath ] == 1 } {
            file delete $QSYSScriptPath
        }
        
        set ScriptFile [open $QSYSScriptPath "w"]
        catch {cd $TEMPPATH}
        
        set device_family                           [ip_get "parameter.device_family.value"]
        set pf_cnt				                    {}
        set pf0_vf_cnt                              {}
        set pf1_vf_cnt                              {}
        set pf2_vf_cnt                              {}
        set pf3_vf_cnt                              {}
        set pf4_vf_cnt                              {}
        set pf5_vf_cnt                              {}
        set pf6_vf_cnt                              {}
        set pf7_vf_cnt                              {}
        set die_types                               [ip_get "parameter.device_die_types.value"]
        set pld_clkfreq_hwtcl                       [ip_get "parameter.pld_clkfreq_hwtcl.value"]
        set example_design_mode_hwtcl               [ip_get "parameter.example_design_mode_hwtcl.value"]
        set topology                                [ip_get "parameter.top_topology_hwtcl.value"]
        set core_num                                [ip_get "parameter.total_core_num_hwtcl.value"]
        set top_topology_hwtcl                      [ip_get "parameter.top_topology_hwtcl.value"]
        set hdr_pck_schme                           [ip_get "parameter.core16_hip_native_mode_user_hwtcl.value"]
        set dwidth_byte                             [ip_get "parameter.core16_dwidth_byte_user_hwtcl.value"]
        set tile_name                               [ip_get "parameter.TILE.value"]
        
        set core_name                               [list "16" "8" "4_0" "4_1"]
        set dwidth_byte_list                        {}
        set hdr_pck_schme_list                      {}
        set axi_num_seg                             {}
        set avst_num_seg                            {}
        set enable_multi_func_hwtcl_list            {}
        set sriov_en_list                           {}
        set perf_pio                                ""
        set pf0_vend_id                             [ip_get "parameter.core16_pf0_pci_type0_vendor_id_hwtcl.value"]
        set pf1_vend_id                             [ip_get "parameter.core16_pf1_pci_type0_vendor_id_hwtcl.value"]
        set pf0_rev_id                             [ip_get "parameter.core16_pf0_revision_id_hwtcl.value"]
        set pf1_rev_id                             [ip_get "parameter.core16_pf1_revision_id_hwtcl.value"]


        if {$tile_name != "R-TILE"} { set hdr_pck_schme 0}

        for {set i 0} {$i < $core_num} {incr i} {
            lappend dwidth_byte_list                [ip_get "parameter.core[lindex $core_name $i]_dwidth_byte_user_hwtcl.value"]
            lappend axi_num_seg                     [ip_get "parameter.core[lindex $core_name $i]_num_seg_user_hwtcl.value"]
            if {[lindex $dwidth_byte_list $i] == 128}        { lappend avst_num_seg 4
            } elseif {[lindex $dwidth_byte_list $i] == 64}   { lappend avst_num_seg 2
            } else { lappend avst_num_seg [lindex $axi_num_seg $i]}

            if {$tile_name == "R-TILE"} {
                lappend hdr_pck_schme_list          [ip_get "parameter.core[lindex $core_name $i]_hip_native_mode_user_hwtcl.value"]
            } else {
                lappend hdr_pck_schme_list          0
            }
            
            if {$i < 2} {
                if {[ip_get "parameter.core[lindex $core_name $i]_enable_multi_func_hwtcl.value"] == 1} {
                    lappend enable_multi_func_hwtcl_list    1
                } else {
                    lappend enable_multi_func_hwtcl_list    0
                }
                if {$core_num == 1} { lappend enable_multi_func_hwtcl_list 0}
                if {[ip_get "parameter.core[lindex $core_name $i]_enable_sriov_hwtcl.value"] == 1} {
                    lappend sriov_en_list                   1
                } else {
                    lappend sriov_en_list                   0
                }
                if {$core_num == 1} { lappend sriov_en_list 0}
                lappend pf_cnt				            [ip_get "parameter.core[lindex $core_name $i]_total_pf_count_hwtcl.value"]
                for {set j 0} {$j < 8} {incr j} {
                    lappend pf${j}_vf_cnt               [ip_get "parameter.core[lindex $core_name $i]_pf${j}_vf_count_hwtcl.value"]
                }
            } elseif {$i >= 2} {
                lappend pf_cnt                          1
                lappend enable_multi_func_hwtcl_list    1
                lappend sriov_en_list                   0
                for {set j 0} {$j < 8} {incr j} {
                    lappend pf${j}_vf_cnt               0
                }
            }
        }


        if {[lindex $enable_multi_func_hwtcl_list 0] || [lindex $enable_multi_func_hwtcl_list 1] } {
            set enable_multi_func_hwtcl 1
        } else {set enable_multi_func_hwtcl 0}

        if {[lindex $sriov_en_list 0] || [lindex $sriov_en_list 1]} {
            set sriov_en 1
        } else {set sriov_en 0}

        send_message info "Device Family is ${device_family}"
        puts $ScriptFile "package require -exact qsys 23.1"
        puts $ScriptFile "set qsys_system ${QSYSTem}"
        puts $ScriptFile "set_project_property DEVICE_FAMILY \"${device_family}\""
        puts $ScriptFile "set_project_property DEVICE ${DeviceQSF}"

        # if { [ regexp "PERFORMANCE_DESIGN" $example_design_mode_hwtcl] && ([regexp "x16" $topology] || [regexp "Gen5 2x8" $topology] || [regexp "Gen5 4x4" $topology]) && !$enable_multi_func_hwtcl && !$sriov_en  } {
        # }
        if { [ regexp "PERFORMANCE_DESIGN" $example_design_mode_hwtcl] && !$enable_multi_func_hwtcl && !$sriov_en  } {
            set enable_perf 1
            send_message info "example_design_mode $example_design_mode_hwtcl"
        } else {
  
            set enable_perf 0
            # enable_perf is 0 for only pio mode generation	
            if { !$sriov_en && !$enable_multi_func_hwtcl} {
                set QSYSWaiver "da_drc.dawf"
                set waiverfile [open $QSYSWaiver "w"]
                if { [regexp "Stratix" $device_family] } {
                    puts $waiverfile "::drc::add_waiver \\\n -description {stratix10_waiver} \\\n -rule_id {RDC-50001} \\\n -query_string { \"Reset Chain Register Heads\" == 'dut|dut|soft_logics|rst_ctrl|pld_clk_ninit_done_sync_inst|din_s1   dut|dut|soft_logics|rst_ctrl|core_pll_lock_reset_n_synchronizer|din_s1' || \"Reset Chain Register Heads\" == 'dut|dut|soft_logics|rst_ctrl|core_pll_lock_reset_n_synchronizer|din_s1   dut|dut|soft_logics|rst_ctrl|pld_clk_ninit_done_sync_inst|din_s1' && \"Reset Sources\" == 'resetip|resetip|lsm_gpo_out_user_reset~internal_clock.reg   resetip|resetip|lsm_gpo_out_user_reset~internal_clock.reg__nff' || \"Reset Sources\" == 'resetip|resetip|lsm_gpo_out_user_reset~internal_clock.reg__nff   resetip|resetip|lsm_gpo_out_user_reset~internal_clock.reg' && \"Data Clock Domain\" == 'dut|dut|inst|inst|maib_and_tile|rx_pcs_x2_clk|ch15' && \"Reset Clock Domain\" == 'Unconstrained domain   internal_clk   internal_clk (INVERTED)'} \\\n -stages {{Timing Signoff}} \\\n -owner {} \\\n -tag {} \\\n -no_warn"
                } else {
                    puts $waiverfile "::drc::add_waiver \\\n -description {agilex_waiver} \\\n -rule_id {RDC-50002} \\\n -query_string { \"Reset Chain Register Heads\" == 'dut|dut|soft_logics|rst_ctrl|pld_clk_ninit_done_sync_inst|din_s1   dut|dut|soft_logics|rst_ctrl|core_pll_lock_reset_n_synchronizer|din_s1' || \"Reset Chain Register Heads\" == 'dut|dut|soft_logics|rst_ctrl|core_pll_lock_reset_n_synchronizer|din_s1   dut|dut|soft_logics|rst_ctrl|pld_clk_ninit_done_sync_inst|din_s1' && \"Reset Sources\" == 'auto_fab_0|alt_sld_fab_0|alt_sld_fab_0|agilexconfigreset|user_reset|sdm_gpo_out_user_reset~internal_ctrl_clock.reg' && \"Data Clock Domain\" == 'dut|dut|inst|inst|maib_and_tile|xcvr_hip_native|rx_ch15' && \"Reset Clock Domain\" == 'Unconstrained domain   internal_clk'} \\\n -stages {{Timing Signoff}} \\\n -owner {} \\\n -tag {} \\\n -no_warn"
                }
                close $waiverfile
                send_message info "example_design_mode PIO_MODE"
            } else {
                send_message info "example_design_mode SRIOV_MODE"
            }
        }

        ################################ 1. PCIe SS IP ###################################################################

        puts $ScriptFile "# Adding Altera PCIe Subsystem IP"
        puts $ScriptFile "add_component dut ip/pcie_ss_ed/pcie_ss_ed_dut.ip intel_pcie_ss_axi dut"
        puts $ScriptFile "load_component dut"
        puts $ScriptFile "# Setting Parameters to Avalon-ST 512-bit PCIe IP"
        puts $ScriptFile "set_component_parameter_value generating_ed_hwtcl 1"
        puts $ScriptFile "set_component_parameter_value pciess_ed_preset 1"
        puts $ScriptFile "set_component_parameter_value core16_pf0_bar0_type_hwtcl {64-bit prefetchable memory}"
        set pipemode_sim_ed_hwtcl                      [ip_get "parameter.pipemode_sim_ed_hwtcl.value"]
        set pipemode_sim_for_ed_hwtcl                  [ip_get "parameter.pipemode_sim_for_ed_hwtcl.value"]
      	#puts $ScriptFile "set_component_parameter_value pipemode_sim_ed_hwtcl $pipemode_sim_ed_hwtcl"
        # Setting all visible and non-derived parameters in Script File
        set nf_hip_parameters [ip_get_matching_parameters [dict set criteria Visible 1]]
        foreach param $nf_hip_parameters {
            set derived [ ip_get "parameter.${param}.DERIVED" ]
            if { $derived == 0 && ![regexp "pipemode_sim_ed_hwtcl" ${param}] } {
                set value [ip_get "parameter.${param}.value"]
                puts $ScriptFile "set_component_parameter_value ${param} {${value}}"
            }
        }

        if {$sriov_en == 1} {
            puts $ScriptFile "set_component_parameter_value apps_type_hwtcl 13"
            # Set all VID to be the same.
            for { set i 0 } { $i < $core_num } { incr i } {
                for { set j 0 } { $j < [lindex $pf_cnt $i] } { incr j } {
                    puts $ScriptFile "set_component_parameter_value core[lindex $core_name $i]_pf${j}_pci_type0_vendor_id_hwtcl 4466"
                }
            }
        }
        
        puts $ScriptFile "set_component_parameter_value pipemode_sim_ed_hwtcl 0"
        puts $ScriptFile "save_component"


        # Export interfaces
        puts $ScriptFile "set_interface_property refclk0 EXPORT_OF dut.refclk0"
        puts $ScriptFile "set_interface_property refclk1 EXPORT_OF dut.refclk1"


        ################################ 2. Reset IP ###################################################################
        puts $ScriptFile "# Adding Reset Release IP"
        puts $ScriptFile "add_component resetIP ip/pcie_ss_ed/pcie_ss_ed_resetIP.ip altera_s10_user_rst_clkgate resetIP"
	    puts $ScriptFile "load_component resetIP"
        puts $ScriptFile "set_component_parameter_value outputType       {Reset Interface}"
        puts $ScriptFile "save_component"


        ################################ Perf IP ###########################################################
        if { $enable_perf } {      
            set perf_pio "PERF"     
            for {set i 0} {$i < $core_num} {incr i} {
                puts $ScriptFile "add_instance                 perf${i} intel_pcie_axi_perf_ed"
                puts $ScriptFile "set_instance_parameter_value perf${i} DEVICE_FAMILY       \"${device_family}\""
                puts $ScriptFile "set_instance_parameter_value perf${i} DATA_WIDTH          {[expr {[lindex $dwidth_byte_list $i]*8}]}"
                puts $ScriptFile "set_instance_parameter_value perf${i} NUM_SEG             {[lindex $avst_num_seg $i]}"
                puts $ScriptFile "set_instance_parameter_value perf${i} DEVICE_DIE_TYPES    {${die_types}}"
                puts $ScriptFile "set_instance_parameter_value perf${i} PLD_CLK_FREQ        {${pld_clkfreq_hwtcl}}"
                puts $ScriptFile "set_instance_parameter_value perf${i} TILE_NAME           {${tile_name}}"
            }
         ################################ 3.PIO ###########################################################
         # A1. Adding PIO
	    } elseif { $enable_multi_func_hwtcl == 0  && $sriov_en == 0} {
            set perf_pio "PIO"
            puts $ScriptFile "# Adding PIO"
            for {set i 0} {$i < $core_num} {incr i} {
                puts $ScriptFile "add_instance pio${i} intel_pcie_axi_pio_ed"
                puts $ScriptFile "set_instance_parameter_value pio${i} DATA_WIDTH       {[expr {[lindex $dwidth_byte_list $i]*8}]}"
                puts $ScriptFile "set_instance_parameter_value pio${i} NUM_SEG          {[lindex $avst_num_seg $i]}"
                puts $ScriptFile "set_instance_parameter_value pio${i} VFNUM_WIDTH       {12}"
                puts $ScriptFile "set_instance_parameter_value pio${i} PFNUM_WIDTH       {2}"
                puts $ScriptFile "set_instance_parameter_value pio${i} DEVICE_FAMILY    \"${device_family}\""
                puts $ScriptFile "set_instance_parameter_value pio${i} DEVICE_DIE_TYPES   {${die_types}}"
                puts $ScriptFile "set_instance_parameter_value pio${i} PLD_FREQ           {${pld_clkfreq_hwtcl}}"
						}

            # A2. Adding on-chip memory
            puts $ScriptFile "# Adding Avalon on-chip Memory"
            for {set i 0} {$i < $core_num } {incr i} {
                puts $ScriptFile "add_instance MEM${i} altera_avalon_onchip_memory2"
                if {[lindex $dwidth_byte_list $i] == 128 } {
                    puts $ScriptFile "set_instance_parameter_value MEM${i} dataWidth                  {1024}"
                    puts $ScriptFile "set_instance_parameter_value MEM${i} memorySize                 {32768}"
                } else {
                    puts $ScriptFile "set_instance_parameter_value MEM${i} dataWidth                  {512}"
                    puts $ScriptFile "set_instance_parameter_value MEM${i} memorySize                 {16384}"
                }

                puts $ScriptFile "set_instance_parameter_value MEM${i} deviceFamily               {Stratix 10}"
                puts $ScriptFile "set_instance_parameter_value MEM${i} dualPort                   {false}"
                puts $ScriptFile "set_instance_parameter_value MEM${i} ecc_enabled                {false}"
                puts $ScriptFile "set_instance_parameter_value MEM${i} initMemContent             {true}"
                puts $ScriptFile "set_instance_parameter_value MEM${i} initializationFileName     {onchip_mem.hex}"
                puts $ScriptFile "set_instance_parameter_value MEM${i} readDuringWriteMode        {DONT_CARE}"
                puts $ScriptFile "set_instance_parameter_value MEM${i} resetrequest_enabled       {false}"
                puts $ScriptFile "set_instance_parameter_value MEM${i} singleClockOperation       {false}"
                puts $ScriptFile "set_instance_parameter_value MEM${i} slave1Latency              {2}"
                puts $ScriptFile "set_instance_parameter_value MEM${i} slave2Latency              {1}"
                puts $ScriptFile "set_instance_parameter_value MEM${i} useNonDefaultInitFile      {false}"
                puts $ScriptFile "set_instance_parameter_value MEM${i} useShallowMemBlocks        {false}"
                puts $ScriptFile "set_instance_parameter_value MEM${i} writable                   {true}"
            }
            
        } else {
            set perf_pio "PIO"
            puts $ScriptFile "# Adding SRIOV"
            for {set i 0} {$i < $core_num } {incr i} {
                puts $ScriptFile "add_instance sriov_apps${i} intel_pcie_axi_sriov_ed"
                puts $ScriptFile "set_instance_parameter_value sriov_apps${i} DATA_WIDTH       {[expr {[lindex $dwidth_byte_list $i]*8}]}"
                puts $ScriptFile "set_instance_parameter_value sriov_apps${i} INTENDED_DEVICE_FAMILY    \"${device_family}\""
                puts $ScriptFile "set_instance_parameter_value sriov_apps${i} PF_CNT           {[lindex $pf_cnt $i]}"
                puts $ScriptFile "set_instance_parameter_value sriov_apps${i} NUM_SEG          {[lindex $avst_num_seg $i]}"
                puts $ScriptFile "set_instance_parameter_value sriov_apps${i} PF0_VF_CNT       {[lindex $pf0_vf_cnt $i]}"
                puts $ScriptFile "set_instance_parameter_value sriov_apps${i} PF1_VF_CNT       {[lindex $pf1_vf_cnt $i]}"
                puts $ScriptFile "set_instance_parameter_value sriov_apps${i} PF2_VF_CNT       {[lindex $pf2_vf_cnt $i]}"
                puts $ScriptFile "set_instance_parameter_value sriov_apps${i} PF3_VF_CNT       {[lindex $pf3_vf_cnt $i]}"
                puts $ScriptFile "set_instance_parameter_value sriov_apps${i} PF4_VF_CNT       {[lindex $pf4_vf_cnt $i]}"
                puts $ScriptFile "set_instance_parameter_value sriov_apps${i} PF5_VF_CNT       {[lindex $pf5_vf_cnt $i]}"
                puts $ScriptFile "set_instance_parameter_value sriov_apps${i} PF6_VF_CNT       {[lindex $pf6_vf_cnt $i]}"
                puts $ScriptFile "set_instance_parameter_value sriov_apps${i} PF7_VF_CNT       {[lindex $pf7_vf_cnt $i]}"
            }
        }	

        if {[lsearch $hdr_pck_schme_list 1] != -1} {
            # Clk div for HIP Native Mode
            ################################ 4. Clkdiv - Intel Clock Controller IP  #######################################################################
            puts $ScriptFile "# Adding Altera Clock Controller IP"
            puts $ScriptFile "add_component clk_div_inst ip/pcie_ss_ed/pcie_ss_ed_clk_div_inst.ip intelclkctrl clk_div_inst"
            puts $ScriptFile "load_component clk_div_inst"
            puts $ScriptFile "set_component_parameter_value CLOCK_DIVIDER           1"
            puts $ScriptFile "set_component_parameter_value CLOCK_DIVIDER_OUTPUTS   3"
            puts $ScriptFile "save_component"
        } 
        if {[lsearch $hdr_pck_schme_list 0] != -1} {
         # IOPLL For Compact Mode
            ################################ 4. IOPLL  #######################################################################
            set frequency [string map -nocase {"mhz" ""} $pld_clkfreq_hwtcl]
            set axi_st_clk_freq  [ip_get "parameter.core16_axi_st_clk_freq_user_integer_hwtcl.value"]
            puts $ScriptFile "# Adding IOPLL"
            puts $ScriptFile "add_component iopll_0 ip/pcie_ss_ed/pcie_ss_ed_iopll_0.ip altera_iopll iopll_0"
            puts $ScriptFile "load_component iopll_0"
            puts $ScriptFile "set_component_parameter_value gui_location_type              {Fabric-Feeding}"
            puts $ScriptFile "set_component_parameter_value gui_reference_clock_frequency  $frequency"
            puts $ScriptFile "set_component_parameter_value gui_use_coreclk                1"
            puts $ScriptFile "set_component_parameter_value gui_use_locked                 1"
            puts $ScriptFile "set_component_parameter_value gui_number_of_clocks           2"
            puts $ScriptFile "set_component_parameter_value gui_pll_bandwidth_preset       {Medium}"
             puts $ScriptFile "set_component_parameter_value gui_output_clock_frequency0    $axi_st_clk_freq"
            puts $ScriptFile "set_component_parameter_value gui_output_clock_frequency1    100"
            puts $ScriptFile "save_component"
        }


        ################################################################################################################################################

        global env
        set IP_ROOTDIR      $env(QUARTUS_ROOTDIR)
        set IP_ROOTDIR      "${IP_ROOTDIR}/../ip"
        
        set tile_name       [ip_get "parameter.TILE.value"]

        set hdl_path_av     "${IP_ROOTDIR}/altera/subsystems/intel_pcie_ss_axi/ed/rtl/avst_axis_conv.sv"
        set hdl_path_ax     "${IP_ROOTDIR}/altera/subsystems/intel_pcie_ss_axi/ed/rtl/axis_avst_conv.sv"

        set div_val_list    {}
        set tkeep_w_list    {}
        set axi_dwidth      {}
        set axi_seg_width   {}
        set avst_seg_width  {}
        set emp_seg_out     {}
        set pcie_hdr_w      {}
        set tuser_hdr_w     {}


        for {set i 0} {$i < $core_num} {incr i} {
            lappend axi_dwidth           [expr {[ip_get "parameter.core[lindex $core_name $i]_dwidth_byte_user_hwtcl.value"]*8}]
            lappend axi_seg_width        [expr {[lindex $axi_dwidth $i]/[lindex $axi_num_seg $i] }]
            lappend tkeep_w_list         [ip_get "parameter.core[lindex $core_name $i]_dwidth_byte_user_hwtcl.value"] 
            lappend div_val_list         [expr {[ip_get "parameter.core[lindex $core_name $i]_segment_size_hwtcl.value"]*8}]
            lappend avst_seg_width       [expr {[lindex $axi_dwidth $i]/[lindex $avst_num_seg $i]}]

            if {[lindex $avst_seg_width $i] == 128} { lappend emp_seg_out 2
            } else { lappend emp_seg_out 3 }

            lappend pcie_hdr_w  [expr {[lindex $avst_num_seg $i] * 128}]
            lappend tuser_hdr_w [expr {[lindex $axi_num_seg $i] * 256}]
        }

        set dwidth_seg_out   $avst_seg_width
        set axi_num_seg_list $avst_num_seg
        set avst_dwidth      $axi_dwidth


        for {set ip_num 0} {$ip_num < $core_num} {incr ip_num} {
        
            ################################ 5. Reset Control  #######################################################################
            puts $ScriptFile "add_instance rst_ctrl_${ip_num} altera_generic_component"
            puts $ScriptFile "load_instantiation rst_ctrl_${ip_num}"
            puts $ScriptFile "set_instantiation_property HDL_COMPILATION_LIBRARY {rst_ctrl_${ip_num}}"
            puts $ScriptFile "set_instantiation_property HDL_ENTITY_NAME {rst_ctrl}"
            puts $ScriptFile "set_instantiation_property IP_FILE {}"
            puts $ScriptFile "add_instantiation_hdl_file {${IP_ROOTDIR}/altera/subsystems/intel_pcie_ss_axi/ed/rtl/rst_ctrl.sv}"
            puts $ScriptFile "set_instantiation_hdl_file_property rst_ctrl.sv CONTAINS_INLINE_CONFIGURATION {false}"
            puts $ScriptFile "set_instantiation_hdl_file_property rst_ctrl.sv IS_CONFIGURATION_PACKAGE {false}"
            puts $ScriptFile "set_instantiation_hdl_file_property rst_ctrl.sv IS_TOP_LEVEL {true}"
            puts $ScriptFile "set_instantiation_hdl_file_property rst_ctrl.sv TYPE {SYSTEM_VERILOG}"
            puts $ScriptFile "set_instantiation_hdl_file_property rst_ctrl.sv PATH {rst_ctrl.sv}"
            
            puts $ScriptFile "add_instantiation_hdl_file {${IP_ROOTDIR}/altera/subsystems/intel_pcie_ss_axi/ed/rtl/fim_resync.sv}"
            puts $ScriptFile "set_instantiation_hdl_file_property fim_resync.sv CONTAINS_INLINE_CONFIGURATION {false}"
            puts $ScriptFile "set_instantiation_hdl_file_property fim_resync.sv IS_CONFIGURATION_PACKAGE {false}"
            puts $ScriptFile "set_instantiation_hdl_file_property fim_resync.sv IS_TOP_LEVEL {false}"
            puts $ScriptFile "set_instantiation_hdl_file_property fim_resync.sv TYPE {SYSTEM_VERILOG}"
            puts $ScriptFile "set_instantiation_hdl_file_property fim_resync.sv PATH {fim_resync.sv}"
            
            if {[lindex $hdr_pck_schme_list $ip_num]} {
                puts $ScriptFile "add_instantiation_hdl_parameter HIP_COM STRING {HIP_NATIVE} {}"
            } else {
                puts $ScriptFile "add_instantiation_hdl_parameter HIP_COM STRING {COMPACT} {}"
            }

            puts $ScriptFile "add_instantiation_interface clk_sys clock INPUT"
            puts $ScriptFile "set_instantiation_interface_parameter_value clk_sys clockRate {0}"
            puts $ScriptFile "set_instantiation_interface_parameter_value clk_sys externallyDriven {false}"
            puts $ScriptFile "set_instantiation_interface_parameter_value clk_sys ptfSchematicName {}"
            puts $ScriptFile "add_instantiation_interface_port clk_sys    clk_sys clk 1 STD_LOGIC Input"
            
            puts $ScriptFile "add_instantiation_interface clk_100m clock INPUT"
            puts $ScriptFile "set_instantiation_interface_parameter_value clk_100m clockRate {0}"
            puts $ScriptFile "set_instantiation_interface_parameter_value clk_100m externallyDriven {false}"
            puts $ScriptFile "set_instantiation_interface_parameter_value clk_100m ptfSchematicName {}"
            puts $ScriptFile "add_instantiation_interface_port clk_100m   clk_100m clk 1 STD_LOGIC Input"

            puts $ScriptFile "add_instantiation_interface pcie_reset_status reset INPUT"
            puts $ScriptFile "set_instantiation_interface_parameter_value pcie_reset_status associatedClock {}"
            puts $ScriptFile "set_instantiation_interface_parameter_value pcie_reset_status synchronousEdges {NONE}"
            puts $ScriptFile "add_instantiation_interface_port pcie_reset_status pcie_reset_status reset 1 STD_LOGIC Input"

            if {[lindex $hdr_pck_schme_list $ip_num] == 0} {
                puts $ScriptFile "add_instantiation_interface pll_locked conduit INPUT"
                puts $ScriptFile "set_instantiation_interface_parameter_value pll_locked associatedClock {}"
                puts $ScriptFile "set_instantiation_interface_parameter_value pll_locked associatedReset {}"
                puts $ScriptFile "set_instantiation_interface_parameter_value pll_locked prSafe {false}"
                puts $ScriptFile "add_instantiation_interface_port pll_locked pll_locked_i export 1 STD_LOGIC Input"

                puts $ScriptFile "add_instantiation_interface pll_locked_o conduit OUTPUT"
                puts $ScriptFile "set_instantiation_interface_parameter_value pll_locked_o associatedClock {}"
                puts $ScriptFile "set_instantiation_interface_parameter_value pll_locked_o associatedReset {}"
                puts $ScriptFile "set_instantiation_interface_parameter_value pll_locked_o prSafe {false}"
                puts $ScriptFile "add_instantiation_interface_port pll_locked_o pll_locked_o export 1 STD_LOGIC Output"
            }

            puts $ScriptFile "add_instantiation_interface pcie_cold_rst_ack_n conduit INPUT"
            puts $ScriptFile "set_instantiation_interface_parameter_value pcie_cold_rst_ack_n associatedClock {}"
            puts $ScriptFile "set_instantiation_interface_parameter_value pcie_cold_rst_ack_n associatedReset {}"
            puts $ScriptFile "set_instantiation_interface_parameter_value pcie_cold_rst_ack_n prSafe {false}"
            puts $ScriptFile "add_instantiation_interface_port pcie_cold_rst_ack_n pcie_cold_rst_ack_n subsystem_cold_rst_ack_n 1 STD_LOGIC Input"

            puts $ScriptFile "add_instantiation_interface pcie_warm_rst_ack_n conduit INPUT"
            puts $ScriptFile "set_instantiation_interface_parameter_value pcie_warm_rst_ack_n associatedClock {}"
            puts $ScriptFile "set_instantiation_interface_parameter_value pcie_warm_rst_ack_n associatedReset {}"
            puts $ScriptFile "set_instantiation_interface_parameter_value pcie_warm_rst_ack_n prSafe {false}"
            puts $ScriptFile "add_instantiation_interface_port pcie_warm_rst_ack_n pcie_warm_rst_ack_n subsystem_warm_rst_ack_n 1 STD_LOGIC Input"
            
            puts $ScriptFile "add_instantiation_interface initiate_warmrst_req conduit INPUT"
            puts $ScriptFile "set_instantiation_interface_parameter_value initiate_warmrst_req associatedClock {}"
            puts $ScriptFile "set_instantiation_interface_parameter_value initiate_warmrst_req associatedReset {}"
            puts $ScriptFile "set_instantiation_interface_parameter_value initiate_warmrst_req prSafe {false}"
            puts $ScriptFile "add_instantiation_interface_port initiate_warmrst_req initiate_warmrst_req initiate_warmrst_req 1 STD_LOGIC Input"

            puts $ScriptFile "add_instantiation_interface initiate_rst_req_rdy conduit OUTPUT"
            puts $ScriptFile "set_instantiation_interface_parameter_value initiate_rst_req_rdy associatedClock {}"
            puts $ScriptFile "set_instantiation_interface_parameter_value initiate_rst_req_rdy associatedReset {}"
            puts $ScriptFile "set_instantiation_interface_parameter_value initiate_rst_req_rdy prSafe {false}"
            puts $ScriptFile "add_instantiation_interface_port initiate_rst_req_rdy initiate_rst_req_rdy initiate_rst_req_rdy 1 STD_LOGIC Output"
            
            puts $ScriptFile "add_instantiation_interface subsystem_rst_rdy conduit INPUT"
            puts $ScriptFile "set_instantiation_interface_parameter_value subsystem_rst_rdy associatedClock {}"
            puts $ScriptFile "set_instantiation_interface_parameter_value subsystem_rst_rdy associatedReset {}"
            puts $ScriptFile "set_instantiation_interface_parameter_value subsystem_rst_rdy prSafe {false}"
            puts $ScriptFile "add_instantiation_interface_port subsystem_rst_rdy subsystem_rst_rdy subsystem_rst_rdy 1 STD_LOGIC Input"

            puts $ScriptFile "add_instantiation_interface subsystem_rst_req conduit OUTPUT"
            puts $ScriptFile "set_instantiation_interface_parameter_value subsystem_rst_req associatedClock {}"
            puts $ScriptFile "set_instantiation_interface_parameter_value subsystem_rst_req associatedReset {}"
            puts $ScriptFile "set_instantiation_interface_parameter_value subsystem_rst_req prSafe {false}"
            puts $ScriptFile "add_instantiation_interface_port subsystem_rst_req subsystem_rst_req subsystem_rst_req 1 STD_LOGIC Output"

            puts $ScriptFile "add_instantiation_interface ninit_done reset INPUT"
            puts $ScriptFile "set_instantiation_interface_parameter_value ninit_done associatedClock {}"
            puts $ScriptFile "set_instantiation_interface_parameter_value ninit_done synchronousEdges {NONE}"
            puts $ScriptFile "add_instantiation_interface_port ninit_done ninit_done reset 1 STD_LOGIC Input"

            puts $ScriptFile "add_instantiation_interface rst_n_sys reset OUTPUT"
            puts $ScriptFile "set_instantiation_interface_parameter_value rst_n_sys associatedClock {clk_sys}"
            puts $ScriptFile "set_instantiation_interface_parameter_value rst_n_sys associatedDirectReset {}"
            puts $ScriptFile "set_instantiation_interface_parameter_value rst_n_sys associatedResetSinks {none}"
            puts $ScriptFile "set_instantiation_interface_parameter_value rst_n_sys synchronousEdges {DEASSERT}"
            puts $ScriptFile "add_instantiation_interface_port rst_n_sys rst_n_sys reset_n 1 STD_LOGIC Output"
            
            puts $ScriptFile "add_instantiation_interface rst_n_100m reset OUTPUT"
            puts $ScriptFile "set_instantiation_interface_parameter_value rst_n_100m associatedClock {clk_100m}"
            puts $ScriptFile "set_instantiation_interface_parameter_value rst_n_100m associatedDirectReset {}"
            puts $ScriptFile "set_instantiation_interface_parameter_value rst_n_100m associatedResetSinks {none}"
            puts $ScriptFile "set_instantiation_interface_parameter_value rst_n_100m synchronousEdges {DEASSERT}"
            puts $ScriptFile "add_instantiation_interface_port rst_n_100m rst_n_100m reset_n 1 STD_LOGIC Output"

            puts $ScriptFile "add_instantiation_interface pwr_good_n reset OUTPUT"
            puts $ScriptFile "set_instantiation_interface_parameter_value pwr_good_n associatedClock {clk_sys}"
            puts $ScriptFile "set_instantiation_interface_parameter_value pwr_good_n associatedDirectReset {}"
            puts $ScriptFile "set_instantiation_interface_parameter_value pwr_good_n associatedResetSinks {none}"
            puts $ScriptFile "set_instantiation_interface_parameter_value pwr_good_n synchronousEdges {DEASSERT}"
            puts $ScriptFile "add_instantiation_interface_port pwr_good_n pwr_good_n reset_n 1 STD_LOGIC Output"

            puts $ScriptFile "add_instantiation_interface pcie_cold_rst_n reset OUTPUT"
            puts $ScriptFile "set_instantiation_interface_parameter_value pcie_cold_rst_n associatedClock {clk_sys}"
            puts $ScriptFile "set_instantiation_interface_parameter_value pcie_cold_rst_n associatedDirectReset {}"
            puts $ScriptFile "set_instantiation_interface_parameter_value pcie_cold_rst_n associatedResetSinks {none}"
            puts $ScriptFile "set_instantiation_interface_parameter_value pcie_cold_rst_n synchronousEdges {DEASSERT}"
            puts $ScriptFile "add_instantiation_interface_port pcie_cold_rst_n pcie_cold_rst_n reset_n 1 STD_LOGIC Output"

            puts $ScriptFile "add_instantiation_interface pcie_warm_rst_n reset OUTPUT"
            puts $ScriptFile "set_instantiation_interface_parameter_value pcie_warm_rst_n associatedClock {clk_sys}"
            puts $ScriptFile "set_instantiation_interface_parameter_value pcie_warm_rst_n associatedDirectReset {}"
            puts $ScriptFile "set_instantiation_interface_parameter_value pcie_warm_rst_n associatedResetSinks {none}"
            puts $ScriptFile "set_instantiation_interface_parameter_value pcie_warm_rst_n synchronousEdges {DEASSERT}"
            puts $ScriptFile "add_instantiation_interface_port pcie_warm_rst_n pcie_warm_rst_n reset_n 1 STD_LOGIC Output"
            puts $ScriptFile "save_instantiation"


            ################################ 6. AVST 2 AXI Converter  #######################################################################

            puts $ScriptFile "add_instance avst2axis_conv_${ip_num} altera_generic_component"
            puts $ScriptFile "load_instantiation avst2axis_conv_${ip_num}"
            puts $ScriptFile "set_instantiation_property HDL_COMPILATION_LIBRARY {avst2axis_conv_${ip_num}}"
            puts $ScriptFile "set_instantiation_property HDL_ENTITY_NAME {avst_axis_conv}"
            puts $ScriptFile "set_instantiation_property IP_FILE {}"
            puts $ScriptFile "add_instantiation_hdl_file {${hdl_path_av}}"
            puts $ScriptFile "set_instantiation_hdl_file_property avst_axis_conv.sv CONTAINS_INLINE_CONFIGURATION {false}"
            puts $ScriptFile "set_instantiation_hdl_file_property avst_axis_conv.sv IS_CONFIGURATION_PACKAGE {false}"
            puts $ScriptFile "set_instantiation_hdl_file_property avst_axis_conv.sv IS_TOP_LEVEL {true}"
            puts $ScriptFile "set_instantiation_hdl_file_property avst_axis_conv.sv TYPE {SYSTEM_VERILOG}"
            puts $ScriptFile "set_instantiation_hdl_file_property avst_axis_conv.sv PATH {avst_axis_conv.sv}"

            puts $ScriptFile "add_instantiation_hdl_file {${IP_ROOTDIR}/altera/subsystems/intel_pcie_ss_axi/ed/rtl/crdt_int_ack.sv}"
            puts $ScriptFile "set_instantiation_hdl_file_property crdt_int_ack.sv CONTAINS_INLINE_CONFIGURATION {false}"
            puts $ScriptFile "set_instantiation_hdl_file_property crdt_int_ack.sv IS_CONFIGURATION_PACKAGE {false}"
            puts $ScriptFile "set_instantiation_hdl_file_property crdt_int_ack.sv IS_TOP_LEVEL {false}"
            puts $ScriptFile "set_instantiation_hdl_file_property crdt_int_ack.sv TYPE {SYSTEM_VERILOG}"
            puts $ScriptFile "set_instantiation_hdl_file_property crdt_int_ack.sv PATH {crdt_int_ack.sv}"

            puts $ScriptFile "add_instantiation_hdl_parameter payload_width INTEGER {[lindex $axi_dwidth $ip_num]} {}"
            puts $ScriptFile "add_instantiation_hdl_parameter hdr_width INTEGER {[lindex $pcie_hdr_w $ip_num]} {}"
            puts $ScriptFile "add_instantiation_hdl_parameter DWIDTH_SEG INTEGER {[lindex $avst_seg_width $ip_num]} {}"
            puts $ScriptFile "add_instantiation_hdl_parameter NUM_OF_SEG INTEGER {[lindex $avst_num_seg $ip_num]} {}"
            puts $ScriptFile "add_instantiation_hdl_parameter PERF_PIO STRING {${perf_pio}} {}"
            puts $ScriptFile "add_instantiation_hdl_parameter TILE STRING {${tile_name}} {}"
            puts $ScriptFile "add_instantiation_hdl_parameter DWIDTH_SEG_OUT INTEGER {[lindex $dwidth_seg_out $ip_num]} {}"
            puts $ScriptFile "add_instantiation_hdl_parameter AXI_DWIDTH_OUT INTEGER {[lindex $axi_seg_width $ip_num]} {}"
            puts $ScriptFile "add_instantiation_hdl_parameter AXI_SEG_OUT INTEGER {[lindex $axi_num_seg $ip_num]} {}"

            puts $ScriptFile "add_instantiation_interface axi_st_tx_tuser_hvalid conduit OUTPUT"
            puts $ScriptFile "set_instantiation_interface_parameter_value axi_st_tx_tuser_hvalid associatedClock {axi_st_clk}"
            puts $ScriptFile "set_instantiation_interface_parameter_value axi_st_tx_tuser_hvalid associatedReset {rst_n}"
            puts $ScriptFile "set_instantiation_interface_parameter_value axi_st_tx_tuser_hvalid prSafe {false}"
            puts $ScriptFile "add_instantiation_interface_port axi_st_tx_tuser_hvalid axi_st_tx_tuser_hvalid app_ss_st_tx_tuser_hvalid [lindex $axi_num_seg $ip_num] STD_LOGIC_VECTOR Output"

            puts $ScriptFile "add_instantiation_interface axi_st_tx_tuser_last_segment conduit OUTPUT"
            puts $ScriptFile "set_instantiation_interface_parameter_value axi_st_tx_tuser_last_segment associatedClock {axi_st_clk}"
            puts $ScriptFile "set_instantiation_interface_parameter_value axi_st_tx_tuser_last_segment associatedReset {rst_n}"
            puts $ScriptFile "set_instantiation_interface_parameter_value axi_st_tx_tuser_last_segment prSafe {false}"
            puts $ScriptFile "add_instantiation_interface_port axi_st_tx_tuser_last_segment axi_st_tx_tuser_last_segment app_ss_st_tx_tuser_last_segment [lindex $axi_num_seg $ip_num] STD_LOGIC_VECTOR Output"
            
            puts $ScriptFile "add_instantiation_interface axi_st_tx_tuser_hdr conduit OUTPUT"
            puts $ScriptFile "set_instantiation_interface_parameter_value axi_st_tx_tuser_hdr associatedClock {axi_st_clk}"
            puts $ScriptFile "set_instantiation_interface_parameter_value axi_st_tx_tuser_hdr associatedReset {rst_n}"
            puts $ScriptFile "set_instantiation_interface_parameter_value axi_st_tx_tuser_hdr prSafe {false}"
            puts $ScriptFile "add_instantiation_interface_port axi_st_tx_tuser_hdr axi_st_tx_tuser_hdr app_ss_st_tx_tuser_hdr [lindex $tuser_hdr_w $ip_num] STD_LOGIC_VECTOR Output"

            for { set i 0} {$i < [lindex $avst_num_seg $ip_num]} {incr i} {
                puts $ScriptFile "add_instantiation_interface tx_st${i} avalon_streaming INPUT"
                puts $ScriptFile "set_instantiation_interface_parameter_value tx_st${i} associatedClock {axi_st_clk}"
                puts $ScriptFile "set_instantiation_interface_parameter_value tx_st${i} associatedReset {rst_n}"
                puts $ScriptFile "set_instantiation_interface_parameter_value tx_st${i} beatsPerCycle {1}"
                puts $ScriptFile "set_instantiation_interface_parameter_value tx_st${i} dataBitsPerSymbol {32}"
                puts $ScriptFile "set_instantiation_interface_parameter_value tx_st${i} emptyWithinPacket {false}"
                puts $ScriptFile "set_instantiation_interface_parameter_value tx_st${i} errorDescriptor {}"
                puts $ScriptFile "set_instantiation_interface_parameter_value tx_st${i} firstSymbolInHighOrderBits {true}"
                puts $ScriptFile "set_instantiation_interface_parameter_value tx_st${i} highOrderSymbolAtMSB {false}"
                puts $ScriptFile "set_instantiation_interface_parameter_value tx_st${i} maxChannel {0}"
                puts $ScriptFile "set_instantiation_interface_parameter_value tx_st${i} packetDescription {}"
                puts $ScriptFile "set_instantiation_interface_parameter_value tx_st${i} prSafe {false}"
                puts $ScriptFile "set_instantiation_interface_parameter_value tx_st${i} readyAllowance {0}"
                puts $ScriptFile "set_instantiation_interface_parameter_value tx_st${i} readyLatency {3}"
                puts $ScriptFile "set_instantiation_interface_parameter_value tx_st${i} symbolsPerBeat {1}"
                puts $ScriptFile "add_instantiation_interface_port tx_st${i} tx_st${i}_valid valid 1 STD_LOGIC Input"
                puts $ScriptFile "add_instantiation_interface_port tx_st${i} tx_st${i}_data data [lindex $dwidth_seg_out $ip_num] STD_LOGIC_VECTOR Input"
                puts $ScriptFile "add_instantiation_interface_port tx_st${i} tx_st${i}_startofpacket startofpacket 1 STD_LOGIC Input"
                puts $ScriptFile "add_instantiation_interface_port tx_st${i} tx_st${i}_endofpacket endofpacket 1 STD_LOGIC Input"
                if {$i == 0} {
                    puts $ScriptFile "add_instantiation_interface_port tx_st${i} tx_st${i}_ready ready 1 STD_LOGIC Output"
                }
            }
            puts $ScriptFile "add_instantiation_interface axi_st_clk clock INPUT"
            puts $ScriptFile "set_instantiation_interface_parameter_value axi_st_clk clockRate {0}"
            puts $ScriptFile "set_instantiation_interface_parameter_value axi_st_clk externallyDriven {false}"
            puts $ScriptFile "set_instantiation_interface_parameter_value axi_st_clk ptfSchematicName {}"
            puts $ScriptFile "add_instantiation_interface_port axi_st_clk axi_st_clk clk 1 STD_LOGIC Input"

            puts $ScriptFile "add_instantiation_interface rst_n reset INPUT"
            puts $ScriptFile "set_instantiation_interface_parameter_value rst_n associatedClock {axi_st_clk}"
            puts $ScriptFile "set_instantiation_interface_parameter_value rst_n synchronousEdges {DEASSERT}"
            puts $ScriptFile "add_instantiation_interface_port rst_n rst_n reset_n 1 STD_LOGIC Input"

            puts $ScriptFile "add_instantiation_interface axi_lite_clk clock INPUT"
            puts $ScriptFile "set_instantiation_interface_parameter_value axi_lite_clk clockRate {0}"
            puts $ScriptFile "set_instantiation_interface_parameter_value axi_lite_clk externallyDriven {false}"
            puts $ScriptFile "set_instantiation_interface_parameter_value axi_lite_clk ptfSchematicName {}"
            puts $ScriptFile "add_instantiation_interface_port axi_lite_clk axi_lite_clk clk 1 STD_LOGIC Input"

            puts $ScriptFile "add_instantiation_interface rst_lite_n reset INPUT"
            puts $ScriptFile "set_instantiation_interface_parameter_value rst_lite_n associatedClock {axi_lite_clk}"
            puts $ScriptFile "set_instantiation_interface_parameter_value rst_lite_n synchronousEdges {DEASSERT}"
            puts $ScriptFile "add_instantiation_interface_port rst_lite_n rst_lite_n reset_n 1 STD_LOGIC Input"

            puts $ScriptFile "add_instantiation_interface p0_st_tx axi4stream OUTPUT"
            puts $ScriptFile "set_instantiation_interface_parameter_value p0_st_tx associatedClock {axi_st_clk}"
            puts $ScriptFile "set_instantiation_interface_parameter_value p0_st_tx associatedReset {rst_n}"
            puts $ScriptFile "add_instantiation_interface_port p0_st_tx axi_st_tx_data tdata [lindex $axi_dwidth $ip_num] STD_LOGIC_VECTOR Output"
            puts $ScriptFile "add_instantiation_interface_port p0_st_tx axi_st_tx_last tlast 1 STD_LOGIC Output"
            puts $ScriptFile "add_instantiation_interface_port p0_st_tx axi_st_tx_valid tvalid 1 STD_LOGIC Output"
            puts $ScriptFile "add_instantiation_interface_port p0_st_tx axi_st_tx_ready tready 1 STD_LOGIC Input"
            puts $ScriptFile "add_instantiation_interface_port p0_st_tx axi_st_tx_keep tkeep [lindex $tkeep_w_list $ip_num] STD_LOGIC_VECTOR Output"

            puts $ScriptFile "add_instantiation_interface p0_st_err axi4stream OUTPUT"
            puts $ScriptFile "set_instantiation_interface_parameter_value p0_st_err associatedClock {axi_lite_clk}"
            puts $ScriptFile "set_instantiation_interface_parameter_value p0_st_err associatedReset {rst_lite_n}"
            puts $ScriptFile "add_instantiation_interface_port p0_st_err p0_app_ss_st_err_tvalid tvalid 1 STD_LOGIC Output"
            puts $ScriptFile "add_instantiation_interface_port p0_st_err p0_app_ss_st_err_tdata tdata 32 STD_LOGIC_VECTOR Output"
            puts $ScriptFile "add_instantiation_interface_port p0_st_err p0_app_ss_st_err_tlast tlast 1 STD_LOGIC Output"
            puts $ScriptFile "add_instantiation_interface_port p0_st_err p0_ss_app_st_err_tready tready 1 STD_LOGIC Input"

            puts $ScriptFile "add_instantiation_interface p0_app_ss_st_err_tuser_error_type conduit OUTPUT"
            puts $ScriptFile "set_instantiation_interface_parameter_value p0_app_ss_st_err_tuser_error_type associatedClock {axi_lite_clk}"
            puts $ScriptFile "set_instantiation_interface_parameter_value p0_app_ss_st_err_tuser_error_type associatedReset {rst_lite_n}"
            puts $ScriptFile "add_instantiation_interface_port p0_app_ss_st_err_tuser_error_type p0_app_ss_st_err_tuser_error_type app_ss_st_err_tuser_error_type 14 STD_LOGIC_VECTOR Output"            
            
            if {$enable_perf == 0 || ($enable_perf == 1 && $tile_name == "R-TILE")} {
                puts $ScriptFile "add_instantiation_interface ss_app_txcrdt axi4stream INPUT"
                puts $ScriptFile "set_instantiation_interface_parameter_value ss_app_txcrdt associatedClock {axi_st_clk}"
                puts $ScriptFile "set_instantiation_interface_parameter_value ss_app_txcrdt associatedReset {rst_n}"
                puts $ScriptFile "add_instantiation_interface_port ss_app_txcrdt ss_app_txcrdt_tvalid tvalid 1 STD_LOGIC Input"
                puts $ScriptFile "add_instantiation_interface_port ss_app_txcrdt ss_app_txcrdt_tdata tdata 19 STD_LOGIC_VECTOR Input"
            }
            
            puts $ScriptFile "add_instantiation_interface tx_st0_misc conduit INPUT"
            puts $ScriptFile "set_instantiation_interface_parameter_value tx_st0_misc associatedClock {}"
            puts $ScriptFile "set_instantiation_interface_parameter_value tx_st0_misc associatedReset {}"
            puts $ScriptFile "set_instantiation_interface_parameter_value tx_st0_misc prSafe {false}"
            
            for {set i 0} {$i < [lindex $avst_num_seg $ip_num]} {incr i} {
                puts $ScriptFile "add_instantiation_interface_port tx_st0_misc tx_st0_misc_tx_st${i}_hdr tx_st${i}_hdr 128 STD_LOGIC_VECTOR Input"
                puts $ScriptFile "add_instantiation_interface_port tx_st0_misc tx_st0_misc_tx_st${i}_hvalid tx_st${i}_hvalid 1 STD_LOGIC Input"
                puts $ScriptFile "add_instantiation_interface_port tx_st0_misc tx_st0_misc_tx_st${i}_pvalid tx_st${i}_pvalid 1 STD_LOGIC Input"
                puts $ScriptFile "add_instantiation_interface_port tx_st0_misc tx_st0_misc_tx_st${i}_prefix tx_st${i}_prefix 32 STD_LOGIC_VECTOR Input"
            }
            if {$enable_perf == 0 || ($enable_perf == 1 && $tile_name == "R-TILE")} {
                puts $ScriptFile "add_instantiation_interface_port tx_st0_misc tx_st0_misc_tx_st_hcrdt_init tx_st_Hcrdt_init 3 STD_LOGIC_VECTOR Output"
                puts $ScriptFile "add_instantiation_interface_port tx_st0_misc tx_st0_misc_tx_st_hcrdt_update tx_st_Hcrdt_update 3 STD_LOGIC_VECTOR Output"
                puts $ScriptFile "add_instantiation_interface_port tx_st0_misc tx_st0_misc_tx_st_hcrdt_update_cnt tx_st_Hcrdt_update_cnt 6 STD_LOGIC_VECTOR Output"
                puts $ScriptFile "add_instantiation_interface_port tx_st0_misc tx_st0_misc_tx_st_hcrdt_init_ack tx_st_Hcrdtt_init_ack 3 STD_LOGIC_VECTOR Input"
                puts $ScriptFile "add_instantiation_interface_port tx_st0_misc tx_st0_misc_tx_st_dcrdt_init tx_st_Dcrdt_init 3 STD_LOGIC_VECTOR Output"
                puts $ScriptFile "add_instantiation_interface_port tx_st0_misc tx_st0_misc_tx_st_dcrdt_update tx_st_Dcrdt_update 3 STD_LOGIC_VECTOR Output"
                puts $ScriptFile "add_instantiation_interface_port tx_st0_misc tx_st0_misc_tx_st_dcrdt_update_cnt tx_st_Dcrdt_update_cnt 12 STD_LOGIC_VECTOR Output"
                puts $ScriptFile "add_instantiation_interface_port tx_st0_misc tx_st0_misc_tx_st_dcrdt_init_ack tx_st_Dcrdt_init_ack 3 STD_LOGIC_VECTOR Input"
            }
            puts $ScriptFile "save_instantiation"
    

            ################################ 7. AXI 2 AVST Converter  #######################################################################


            puts $ScriptFile "add_instance axis2avst_conv_${ip_num} altera_generic_component"
            puts $ScriptFile "load_instantiation axis2avst_conv_${ip_num}"
            puts $ScriptFile "set_instantiation_property HDL_COMPILATION_LIBRARY {axis2avst_conv_${ip_num}}"
            puts $ScriptFile "set_instantiation_property HDL_ENTITY_NAME {axis_avst_conv}"
            puts $ScriptFile "set_instantiation_property IP_FILE {}"
            puts $ScriptFile "add_instantiation_hdl_file {${hdl_path_ax}}"
            puts $ScriptFile "set_instantiation_hdl_file_property axis_avst_conv.sv CONTAINS_INLINE_CONFIGURATION {false}"
            puts $ScriptFile "set_instantiation_hdl_file_property axis_avst_conv.sv IS_CONFIGURATION_PACKAGE {false}"
            puts $ScriptFile "set_instantiation_hdl_file_property axis_avst_conv.sv IS_TOP_LEVEL {true}"
            puts $ScriptFile "set_instantiation_hdl_file_property axis_avst_conv.sv TYPE {SYSTEM_VERILOG}"
            puts $ScriptFile "set_instantiation_hdl_file_property axis_avst_conv.sv PATH {axis_avst_conv.sv}"

            puts $ScriptFile "add_instantiation_hdl_parameter payload_width INTEGER {[lindex $axi_dwidth $ip_num]} {}"
            puts $ScriptFile "add_instantiation_hdl_parameter hdr_width INTEGER {[lindex $pcie_hdr_w $ip_num]} {}"
            puts $ScriptFile "add_instantiation_hdl_parameter NUM_OF_SEG INTEGER {[lindex $avst_num_seg $ip_num]} {}"
            puts $ScriptFile "add_instantiation_hdl_parameter DWIDTH_SEG INTEGER {[lindex $avst_seg_width $ip_num]} {}"
            puts $ScriptFile "add_instantiation_hdl_parameter DWIDTH_SEG_OUT INTEGER {[lindex $dwidth_seg_out $ip_num]} {}"
            puts $ScriptFile "add_instantiation_hdl_parameter EMP_SEG_OUT INTEGER {[lindex $emp_seg_out $ip_num]} {}"
            puts $ScriptFile "add_instantiation_hdl_parameter AXI_DWIDTH_IN INTEGER {[lindex $axi_seg_width $ip_num]} {}"
            puts $ScriptFile "add_instantiation_hdl_parameter AXI_SEG_IN INTEGER {[lindex $axi_num_seg $ip_num]} {}"
            puts $ScriptFile "add_instantiation_hdl_parameter PERF_PIO STRING {${perf_pio}} {}"


            for { set i 0} {$i < [lindex $axi_num_seg_list $ip_num]} {incr i} {
                puts $ScriptFile "add_instantiation_interface rx_st${i} avalon_streaming OUTPUT"
                puts $ScriptFile "set_instantiation_interface_parameter_value rx_st${i} associatedClock {axi_st_clk}"
                puts $ScriptFile "set_instantiation_interface_parameter_value rx_st${i} associatedReset {warm_rst_n}"
                puts $ScriptFile "set_instantiation_interface_parameter_value rx_st${i} beatsPerCycle {1}"
                puts $ScriptFile "set_instantiation_interface_parameter_value rx_st${i} dataBitsPerSymbol {32}"
                puts $ScriptFile "set_instantiation_interface_parameter_value rx_st${i} emptyWithinPacket {false}"
                puts $ScriptFile "set_instantiation_interface_parameter_value rx_st${i} errorDescriptor {}"
                puts $ScriptFile "set_instantiation_interface_parameter_value rx_st${i} firstSymbolInHighOrderBits {true}"
                puts $ScriptFile "set_instantiation_interface_parameter_value rx_st${i} highOrderSymbolAtMSB {false}"
                puts $ScriptFile "set_instantiation_interface_parameter_value rx_st${i} maxChannel {0}"
                puts $ScriptFile "set_instantiation_interface_parameter_value rx_st${i} packetDescription {}"
                puts $ScriptFile "set_instantiation_interface_parameter_value rx_st${i} prSafe {false}"
                puts $ScriptFile "set_instantiation_interface_parameter_value rx_st${i} readyAllowance {0}"
                puts $ScriptFile "set_instantiation_interface_parameter_value rx_st${i} readyLatency {27}"
                puts $ScriptFile "set_instantiation_interface_parameter_value rx_st${i} symbolsPerBeat {1}"
                puts $ScriptFile "add_instantiation_interface_port rx_st${i} rx_st_data_st${i} data [lindex $dwidth_seg_out $ip_num] STD_LOGIC_VECTOR Output"
                if {$i == 0} {
                    puts $ScriptFile "add_instantiation_interface_port rx_st${i} rx_st_ready_st${i} ready 1 STD_LOGIC Input"
                }
                puts $ScriptFile "add_instantiation_interface_port rx_st${i} rx_st_valid_st${i} valid 1 STD_LOGIC Output"
                puts $ScriptFile "add_instantiation_interface_port rx_st${i} rx_st_sop_st${i} startofpacket 1 STD_LOGIC Output"
                puts $ScriptFile "add_instantiation_interface_port rx_st${i} rx_st_eop_st${i} endofpacket 1 STD_LOGIC Output"
                puts $ScriptFile "add_instantiation_interface_port rx_st${i} rx_st_emp_st${i} empty [lindex $emp_seg_out $ip_num] STD_LOGIC_VECTOR Output"
            }

            puts $ScriptFile "add_instantiation_interface axi_st_clk clock INPUT"
            puts $ScriptFile "set_instantiation_interface_parameter_value axi_st_clk clockRate {0}"
            puts $ScriptFile "set_instantiation_interface_parameter_value axi_st_clk externallyDriven {false}"
            puts $ScriptFile "set_instantiation_interface_parameter_value axi_st_clk ptfSchematicName {}"
            puts $ScriptFile "add_instantiation_interface_port axi_st_clk axi_st_clk clk 1 STD_LOGIC Input"

            puts $ScriptFile "add_instantiation_interface warm_rst_n reset INPUT"
            puts $ScriptFile "set_instantiation_interface_parameter_value warm_rst_n associatedClock {axi_st_clk}"
            puts $ScriptFile "set_instantiation_interface_parameter_value warm_rst_n synchronousEdges {DEASSERT}"
            puts $ScriptFile "add_instantiation_interface_port warm_rst_n warm_rst_n reset_n 1 STD_LOGIC Input"

            puts $ScriptFile "add_instantiation_interface p0_st_rx axi4stream INPUT"
            puts $ScriptFile "set_instantiation_interface_parameter_value p0_st_rx associatedClock {axi_st_clk}"
            puts $ScriptFile "set_instantiation_interface_parameter_value p0_st_rx associatedReset {warm_rst_n}"
            puts $ScriptFile "add_instantiation_interface_port p0_st_rx app_ss_st_rx_tvalid tvalid 1 STD_LOGIC Input"
            puts $ScriptFile "add_instantiation_interface_port p0_st_rx app_ss_st_rx_tdata tdata [lindex $axi_dwidth $ip_num] STD_LOGIC_VECTOR Input"
            puts $ScriptFile "add_instantiation_interface_port p0_st_rx app_ss_st_rx_tkeep tkeep [lindex $tkeep_w_list $ip_num] STD_LOGIC_VECTOR Input"
            puts $ScriptFile "add_instantiation_interface_port p0_st_rx app_ss_st_rx_tlast tlast 1 STD_LOGIC Input"
            if {$tile_name == "P-TILE" || $tile_name == "F-TILE" || ($tile_name == "R-TILE" && ![lindex $hdr_pck_schme_list $ip_num]) } {
                puts $ScriptFile "add_instantiation_interface_port p0_st_rx ss_app_st_rx_tready tready 1 STD_LOGIC Output"
            }

            puts $ScriptFile "add_instantiation_interface app_ss_st_rx_tuser_hvalid conduit INPUT"
            puts $ScriptFile "set_instantiation_interface_parameter_value app_ss_st_rx_tuser_hvalid associatedClock {axi_st_clk}"
            puts $ScriptFile "set_instantiation_interface_parameter_value app_ss_st_rx_tuser_hvalid associatedReset {warm_rst_n}"
            puts $ScriptFile "set_instantiation_interface_parameter_value app_ss_st_rx_tuser_hvalid prSafe {false}"
            puts $ScriptFile "add_instantiation_interface_port app_ss_st_rx_tuser_hvalid app_ss_st_rx_tuser_hvalid ss_app_st_rx_tuser_hvalid [lindex $axi_num_seg $ip_num] STD_LOGIC_VECTOR Input"

            puts $ScriptFile "add_instantiation_interface app_ss_st_rx_tuser_last_segment conduit INPUT"
            puts $ScriptFile "set_instantiation_interface_parameter_value app_ss_st_rx_tuser_last_segment associatedClock {axi_st_clk}"
            puts $ScriptFile "set_instantiation_interface_parameter_value app_ss_st_rx_tuser_last_segment associatedReset {warm_rst_n}"
            puts $ScriptFile "set_instantiation_interface_parameter_value app_ss_st_rx_tuser_last_segment prSafe {false}"
            puts $ScriptFile "add_instantiation_interface_port app_ss_st_rx_tuser_last_segment app_ss_st_rx_tuser_last_segment ss_app_st_rx_tuser_last_segment [lindex $axi_num_seg $ip_num] STD_LOGIC_VECTOR Input"

            puts $ScriptFile "add_instantiation_interface app_ss_st_rx_tuser_vendor conduit INPUT"
            puts $ScriptFile "set_instantiation_interface_parameter_value app_ss_st_rx_tuser_vendor associatedClock {axi_st_clk}"
            puts $ScriptFile "set_instantiation_interface_parameter_value app_ss_st_rx_tuser_vendor associatedReset {warm_rst_n}"
            puts $ScriptFile "set_instantiation_interface_parameter_value app_ss_st_rx_tuser_vendor prSafe {false}"
            puts $ScriptFile "add_instantiation_interface_port app_ss_st_rx_tuser_vendor app_ss_st_rx_tuser_vendor ss_app_st_rx_tuser_vendor [lindex $axi_num_seg $ip_num] STD_LOGIC_VECTOR Input"

            puts $ScriptFile "add_instantiation_interface app_ss_st_rx_tuser_hdr conduit INPUT"
            puts $ScriptFile "set_instantiation_interface_parameter_value app_ss_st_rx_tuser_hdr associatedClock {axi_st_clk}"
            puts $ScriptFile "set_instantiation_interface_parameter_value app_ss_st_rx_tuser_hdr associatedReset {warm_rst_n}"
            puts $ScriptFile "set_instantiation_interface_parameter_value app_ss_st_rx_tuser_hdr prSafe {false}"
            puts $ScriptFile "add_instantiation_interface_port app_ss_st_rx_tuser_hdr app_ss_st_rx_tuser_hdr ss_app_st_rx_tuser_hdr [lindex $tuser_hdr_w $ip_num] STD_LOGIC_VECTOR Input"

            puts $ScriptFile "add_instantiation_interface rx_st0_misc conduit INPUT"
            puts $ScriptFile "set_instantiation_interface_parameter_value rx_st0_misc associatedClock {}"
            puts $ScriptFile "set_instantiation_interface_parameter_value rx_st0_misc associatedReset {}"
            puts $ScriptFile "set_instantiation_interface_parameter_value rx_st0_misc prSafe {false}"
                         
            for {set i 0} {$i < [lindex $axi_num_seg_list $ip_num]} {incr i} {
                puts $ScriptFile "add_instantiation_interface_port rx_st0_misc rx_st_misc_st${i}_hdr rx_st${i}_hdr 128 STD_LOGIC_VECTOR Output"
                puts $ScriptFile "add_instantiation_interface_port rx_st0_misc rx_st_misc_st${i}_bar rx_st${i}_bar 3 STD_LOGIC_VECTOR Output"
                puts $ScriptFile "add_instantiation_interface_port rx_st0_misc rx_st_misc_st${i}_hvalid rx_st${i}_hvalid 1 STD_LOGIC Output"
                if {$enable_multi_func_hwtcl || $sriov_en} {
                    puts $ScriptFile "add_instantiation_interface_port rx_st0_misc rx_st_misc_st${i}_pf_num rx_st${i}_pfnum 3 STD_LOGIC_VECTOR Output"
                } else {
                    puts $ScriptFile "add_instantiation_interface_port rx_st0_misc rx_st_misc_st${i}_prefix rx_st${i}_prefix 32 STD_LOGIC_VECTOR Output"
                    puts $ScriptFile "add_instantiation_interface_port rx_st0_misc rx_st_misc_st${i}_pvalid rx_st${i}_pvalid 1 STD_LOGIC Output"
                }
                if {[lindex $sriov_en_list $ip_num]} {
                    puts $ScriptFile "add_instantiation_interface_port rx_st0_misc rx_st_misc_st${i}_vf_num rx_st${i}_vfnum 11 STD_LOGIC_VECTOR Output"
                    puts $ScriptFile "add_instantiation_interface_port rx_st0_misc rx_st_misc_st${i}_vf_active rx_st${i}_vfactive 1 STD_LOGIC_VECTOR Output"
                }
            }
            if {$enable_perf == 0 || ($enable_perf == 1 && $tile_name == "R-TILE")} {
                puts $ScriptFile "add_instantiation_interface_port rx_st0_misc rx_st_misc_rx_st_hcrdt_init_i rx_st_Hcrdt_init 3 STD_LOGIC_VECTOR Input"
                puts $ScriptFile "add_instantiation_interface_port rx_st0_misc rx_st_misc_rx_st_hcrdt_update_i rx_st_Hcrdt_update 3 STD_LOGIC_VECTOR Input"
                puts $ScriptFile "add_instantiation_interface_port rx_st0_misc rx_st_misc_rx_st_hcrdt_update_cnt_i rx_st_Hcrdt_update_cnt 6 STD_LOGIC_VECTOR Input"
                puts $ScriptFile "add_instantiation_interface_port rx_st0_misc rx_st_misc_rx_st_hcrdt_init_ack_o rx_st_Hcrdt_init_ack 3 STD_LOGIC_VECTOR Output"
                puts $ScriptFile "add_instantiation_interface_port rx_st0_misc rx_st_misc_rx_st_dcrdt_init_i rx_st_Dcrdt_init 3 STD_LOGIC_VECTOR Input"
                puts $ScriptFile "add_instantiation_interface_port rx_st0_misc rx_st_misc_rx_st_dcrdt_update_i rx_st_Dcrdt_update 3 STD_LOGIC_VECTOR Input"
                puts $ScriptFile "add_instantiation_interface_port rx_st0_misc rx_st_misc_rx_st_dcrdt_update_cnt_i rx_st_Dcrdt_update_cnt 12 STD_LOGIC_VECTOR Input"
                puts $ScriptFile "add_instantiation_interface_port rx_st0_misc rx_st_misc_rx_st_dcrdt_init_ack_o rx_st_Dcrdt_init_ack 3 STD_LOGIC_VECTOR Output"
            }

            if {$tile_name == "R-TILE" && [lindex $hdr_pck_schme_list $ip_num]} {
                puts $ScriptFile "add_instantiation_interface ss_app_rxcrdt axi4stream OUTPUT"
                puts $ScriptFile "set_instantiation_interface_parameter_value ss_app_rxcrdt associatedClock {axi_st_clk}"
                puts $ScriptFile "set_instantiation_interface_parameter_value ss_app_rxcrdt associatedReset {warm_rst_n}"
                puts $ScriptFile "add_instantiation_interface_port ss_app_rxcrdt ss_app_rxcrdt_tvalid_o tvalid 1 STD_LOGIC Output"
                puts $ScriptFile "add_instantiation_interface_port ss_app_rxcrdt ss_app_rxcrdt_tdata_o tdata 19 STD_LOGIC_VECTOR Output"
            }

            puts $ScriptFile "save_instantiation"


            ################################ 8. FLR Loopback  #######################################################################

            puts $ScriptFile "add_instance flr_lpbk_inst_${ip_num} altera_generic_component"
            puts $ScriptFile "load_instantiation flr_lpbk_inst_${ip_num}"
            puts $ScriptFile "set_instantiation_property HDL_COMPILATION_LIBRARY {flr_lpbk_inst_${ip_num}}"
            puts $ScriptFile "set_instantiation_property HDL_ENTITY_NAME {handle_flr}"
            puts $ScriptFile "set_instantiation_property IP_FILE {}"
            puts $ScriptFile "add_instantiation_hdl_file {${IP_ROOTDIR}/altera/subsystems/intel_pcie_ss_axi/ed/rtl/handle_flr.sv}"
            puts $ScriptFile "set_instantiation_hdl_file_property handle_flr.sv CONTAINS_INLINE_CONFIGURATION {false}"
            puts $ScriptFile "set_instantiation_hdl_file_property handle_flr.sv IS_CONFIGURATION_PACKAGE {false}"
            puts $ScriptFile "set_instantiation_hdl_file_property handle_flr.sv IS_TOP_LEVEL {true}"
            puts $ScriptFile "set_instantiation_hdl_file_property handle_flr.sv TYPE {SYSTEM_VERILOG}"
            puts $ScriptFile "set_instantiation_hdl_file_property handle_flr.sv PATH {handle_flr.sv}"

            puts $ScriptFile "add_instantiation_hdl_parameter TILE_NAME STRING {${tile_name}} {}"

            puts $ScriptFile "add_instantiation_interface axilite_clk clock INPUT"
            puts $ScriptFile "set_instantiation_interface_parameter_value axilite_clk clockRate {0}"
            puts $ScriptFile "set_instantiation_interface_parameter_value axilite_clk externallyDriven {false}"
            puts $ScriptFile "set_instantiation_interface_parameter_value axilite_clk ptfSchematicName {}"
            puts $ScriptFile "add_instantiation_interface_port axilite_clk axilite_clk clk 1 STD_LOGIC Input"

            puts $ScriptFile "add_instantiation_interface rstn reset INPUT"
            puts $ScriptFile "set_instantiation_interface_parameter_value rstn associatedClock {axilite_clk}"
            puts $ScriptFile "set_instantiation_interface_parameter_value rstn synchronousEdges {DEASSERT}"
            puts $ScriptFile "add_instantiation_interface_port rstn rstn reset_n 1 STD_LOGIC Input"

            puts $ScriptFile "add_instantiation_interface ss_app_flr_rcvd axi4stream INPUT"
            puts $ScriptFile "set_instantiation_interface_parameter_value ss_app_flr_rcvd associatedClock {axilite_clk}"
            puts $ScriptFile "set_instantiation_interface_parameter_value ss_app_flr_rcvd associatedReset {rstn}"
            puts $ScriptFile "add_instantiation_interface_port ss_app_flr_rcvd ss_app_flr_rcvd_tdata tdata 20 STD_LOGIC_VECTOR Input"
            puts $ScriptFile "add_instantiation_interface_port ss_app_flr_rcvd ss_app_flr_rcvd_tvalid tvalid 1 STD_LOGIC Input"

            puts $ScriptFile "add_instantiation_interface app_ss_flr_cmpl axi4stream OUTPUT"
            puts $ScriptFile "set_instantiation_interface_parameter_value app_ss_flr_cmpl associatedClock {axilite_clk}"
            puts $ScriptFile "set_instantiation_interface_parameter_value app_ss_flr_cmpl associatedReset {rstn}"
            puts $ScriptFile "add_instantiation_interface_port app_ss_flr_cmpl app_ss_flr_cmpl_tdata tdata 20 STD_LOGIC_VECTOR Output"
            puts $ScriptFile "add_instantiation_interface_port app_ss_flr_cmpl app_ss_flr_cmpl_tvalid tvalid 1 STD_LOGIC Output"
            puts $ScriptFile "add_instantiation_interface_port app_ss_flr_cmpl ss_app_flr_cmpl_tready tready 1 STD_LOGIC Input"
            puts $ScriptFile "save_instantiation"
        }


        ################### Connecting Modules for the Example Design  #########################
        
        puts $ScriptFile "save_system ${QSYSTemPath}"
        puts $ScriptFile "load_system ${QSYSTemPath}"



        ######################################## Connections between IPs ##################################################

        # Change pciess DUT ninit_done interface type
        puts $ScriptFile "load_instantiation dut"
        
        # dummy AVMM reset, terminated when xcvr_reconfig, cpl_timeout, hip_reconfig are disabled, associated reset for xcvr_reconfig interface 
        if { $xcvr_reconfig != 1 } { 
            puts $ScriptFile "remove_instantiation_interface dummy_user_avmm_rst"
            puts $ScriptFile "add_instantiation_interface                    dummy_user_avmm_rst conduit INPUT"
            puts $ScriptFile "add_instantiation_interface_port               dummy_user_avmm_rst dummy_user_avmm_rst rst 1 STD_LOGIC Input"
            puts $ScriptFile "set_interface_property                         dummy_user_avmm_rst EXPORT_OF dut.dummy_user_avmm_rst"

        }


        puts $ScriptFile "save_instantiation"

        # B0. Exporting ports on DUT and PIO and MM_BRIDGE
        puts $ScriptFile "# Exporting ports on DUT"
        puts $ScriptFile "set_interface_property pin_perst_n EXPORT_OF dut.pin_perst_n"
        puts $ScriptFile "set_interface_property hip_serial EXPORT_OF dut.hip_serial"

       #Pipemode 

        #set pipemode_sim_hwtcl                      [ip_get "parameter.pipemode_sim_ed_hwtcl.value"]				
        if { $tile_name == "R-TILE"} {
            puts $ScriptFile "#pipe_intf add_interface fastp_pcie_ conduit INPUT"
	          puts $ScriptFile "#pipe_intf set_interface_property               fastp_pcie_ EXPORT_OF ${instance_name}.fastp_pcie_"
        
	          for { set i 0 } { $i < 16 } { incr i } {        
	 	             puts $ScriptFile "#pipe_intf add_interface                 fastp_pcie_mac_phy_ch${i}_ conduit INPUT"
	               puts $ScriptFile "#pipe_intf set_interface_property        fastp_pcie_mac_phy_ch${i}_ EXPORT_OF ${instance_name}.fastp_pcie_mac_phy_ch${i}_"
   	        } 
    	      for {set j 8 } { $j < 16 } { incr j } {	      
		             puts $ScriptFile "#pipe_intf add_interface                 fastp_pcie_phy_mac_ch${j}_ conduit INPUT"
		             puts $ScriptFile "#pipe_intf set_interface_property        fastp_pcie_phy_mac_ch${j}_ EXPORT_OF ${instance_name}.fastp_pcie_phy_mac_ch${j}_"
   	        }
	          puts $ScriptFile "#pipe_intf add_interface          fastp_pcie_phy_mac_              conduit INPUT"
            puts $ScriptFile "#pipe_intf set_interface_property               fastp_pcie_phy_mac_ EXPORT_OF ${instance_name}.fastp_pcie_phy_mac_"

         } elseif { $tile_name == "F-TILE"} {

           puts $ScriptFile "#pipe_intf load_instantiation dut"

	         puts $ScriptFile "#pipe_intf add_instantiation_interface          i_pclk_x4_l4 clock INPUT"
           puts $ScriptFile "#pipe_intf add_instantiation_interface_port     i_pclk_x4_l4 i_pclk_x4_l4 clk 1 STD_LOGIC Input"
           puts $ScriptFile "#pipe_intf set_interface_property               i_pclk_x4_l4 EXPORT_OF dut.i_pclk_x4_l4"
           
           
           
           puts $ScriptFile "#pipe_intf add_instantiation_interface          i_pclk_x4_l12 clock INPUT"
           puts $ScriptFile "#pipe_intf add_instantiation_interface_port i_pclk_x4_l12 i_pclk_x4_l12 clk 1 STD_LOGIC Input"
           puts $ScriptFile "#pipe_intf set_interface_property i_pclk_x4_l12 EXPORT_OF dut.i_pclk_x4_l12"
           
           
           puts $ScriptFile "#pipe_intf add_instantiation_interface          i_pclk_x8_l8 clock INPUT"
           puts $ScriptFile "#pipe_intf add_instantiation_interface_port i_pclk_x8_l8 i_pclk_x8_l8 clk 1 STD_LOGIC Input"
           puts $ScriptFile "#pipe_intf set_interface_property i_pclk_x8_l8 EXPORT_OF dut.i_pclk_x8_l8"
           
           
           puts $ScriptFile "#pipe_intf add_instantiation_interface          i_pclk_x16_l0 clock INPUT"
           puts $ScriptFile "#pipe_intf add_instantiation_interface_port i_pclk_x16_l0 i_pclk_x16_l0 clk 1 STD_LOGIC Input"
           puts $ScriptFile "#pipe_intf set_interface_property i_pclk_x16_l0 EXPORT_OF dut.i_pclk_x16_l0"

           
            

	   for { set i 0 } { $i < 16 } { incr i } {
          
                 puts $ScriptFile "#pipe_intf add_instantiation_interface                 i_rxpipe${i}_ conduit INPUT"
                 puts $ScriptFile "#pipe_intf set_instantiation_interface_parameter_value i_rxpipe${i}_ associatedClock {}"
                 puts $ScriptFile "#pipe_intf set_instantiation_interface_parameter_value i_rxpipe${i}_ associatedReset {}"
                 puts $ScriptFile "#pipe_intf set_instantiation_interface_parameter_value i_rxpipe${i}_ prSafe {false}"
                 
                 puts $ScriptFile "#pipe_intf add_instantiation_interface_port  i_rxpipe${i}_  i_rxpipe${i}_dirfeedback                        dirfeedback                           6  STD_LOGIC_VECTOR Input"
                 puts $ScriptFile "#pipe_intf add_instantiation_interface_port  i_rxpipe${i}_  i_rxpipe${i}_linkevaluationfeedbackfiguremerit  linkevaluationfeedbackfiguremerit     8  STD_LOGIC_VECTOR Input"
                 puts $ScriptFile "#pipe_intf add_instantiation_interface_port  i_rxpipe${i}_  i_rxpipe${i}_localfs                            localfs                               6  STD_LOGIC_VECTOR Input"
                 puts $ScriptFile "#pipe_intf add_instantiation_interface_port  i_rxpipe${i}_  i_rxpipe${i}_locallf                            locallf                               6  STD_LOGIC_VECTOR Input"
                 puts $ScriptFile "#pipe_intf add_instantiation_interface_port  i_rxpipe${i}_  i_rxpipe${i}_localtxcoefficientsvalid           localtxcoefficientsvalid              1  STD_LOGIC Input"
                 puts $ScriptFile "#pipe_intf add_instantiation_interface_port  i_rxpipe${i}_  i_rxpipe${i}_localtxpresetcoefficients          localtxpresetcoefficients             18 STD_LOGIC_VECTOR Input"
                 puts $ScriptFile "#pipe_intf add_instantiation_interface_port  i_rxpipe${i}_  i_rxpipe${i}_p2m_bus                            p2m_bus                               8  STD_LOGIC_VECTOR Input"
                 puts $ScriptFile "#pipe_intf add_instantiation_interface_port  i_rxpipe${i}_  i_rxpipe${i}_pclkchangeok                       pclkchangeok                          1  STD_LOGIC Input"
                 puts $ScriptFile "#pipe_intf add_instantiation_interface_port  i_rxpipe${i}_  i_rxpipe${i}_phystatus                          phystatus                             1  STD_LOGIC Input"
                 puts $ScriptFile "#pipe_intf add_instantiation_interface_port  i_rxpipe${i}_  i_rxpipe${i}_rxdata                             rxdata                                40 STD_LOGIC_VECTOR Input"
                 puts $ScriptFile "#pipe_intf add_instantiation_interface_port  i_rxpipe${i}_  i_rxpipe${i}_rxdatak                            rxdatak                               4  STD_LOGIC_VECTOR Input"
                 puts $ScriptFile "#pipe_intf add_instantiation_interface_port  i_rxpipe${i}_  i_rxpipe${i}_rxdatavalid                        rxdatavalid                           1  STD_LOGIC Input"
                 puts $ScriptFile "#pipe_intf add_instantiation_interface_port  i_rxpipe${i}_  i_rxpipe${i}_rxelecidlea                        rxelecidlea                           1  STD_LOGIC Input"
                 puts $ScriptFile "#pipe_intf add_instantiation_interface_port  i_rxpipe${i}_  i_rxpipe${i}_rxstandbystatus                    rxstandbystatus                       1  STD_LOGIC Input"
                 puts $ScriptFile "#pipe_intf add_instantiation_interface_port  i_rxpipe${i}_  i_rxpipe${i}_rxstartblock                       rxstartblock                          1  STD_LOGIC Input"
                 puts $ScriptFile "#pipe_intf add_instantiation_interface_port  i_rxpipe${i}_  i_rxpipe${i}_rxstatus                           rxstatus                              3  STD_LOGIC_VECTOR Input"
                 puts $ScriptFile "#pipe_intf add_instantiation_interface_port  i_rxpipe${i}_  i_rxpipe${i}_rxsyncheader                       rxsyncheader                          4  STD_LOGIC_VECTOR Input"
                 puts $ScriptFile "#pipe_intf add_instantiation_interface_port  i_rxpipe${i}_  i_rxpipe${i}_rxvalid                            rxvalid                               1  STD_LOGIC Input"
                 puts $ScriptFile "#pipe_intf set_interface_property    i_rxpipe${i}_ EXPORT_OF dut.i_rxpipe${i}_"
                 puts $ScriptFile "#pipe_intf add_instantiation_interface                 o_txpipe${i}_  conduit INPUT"
                 puts $ScriptFile "#pipe_intf set_instantiation_interface_parameter_value o_txpipe${i}_  associatedClock {}"
                 puts $ScriptFile "#pipe_intf set_instantiation_interface_parameter_value o_txpipe${i}_ associatedReset {}"
                 puts $ScriptFile "#pipe_intf set_instantiation_interface_parameter_value o_txpipe${i}_ prSafe {false}"
                 
                 puts $ScriptFile "#pipe_intf add_instantiation_interface_port o_txpipe${i}_ o_txpipe${i}_asyncpowerchangeack                asyncpowerchangeack                          1  STD_LOGIC        Output"
                 puts $ScriptFile "#pipe_intf add_instantiation_interface_port o_txpipe${i}_ o_txpipe${i}_blockaligncontrol                  blockaligncontrol                            1  STD_LOGIC        Output"
                 puts $ScriptFile "#pipe_intf add_instantiation_interface_port o_txpipe${i}_ o_txpipe${i}_cfg_hw_auto_sp_dis                 cfg_hw_auto_sp_dis                           1  STD_LOGIC        Output"
                 puts $ScriptFile "#pipe_intf add_instantiation_interface_port o_txpipe${i}_ o_txpipe${i}_dirchange                          dirchange                                    1  STD_LOGIC        Output"
                 puts $ScriptFile "#pipe_intf add_instantiation_interface_port o_txpipe${i}_ o_txpipe${i}_ebuf_mode                          ebuf_mode                                    1  STD_LOGIC        Output"
                 puts $ScriptFile "#pipe_intf add_instantiation_interface_port o_txpipe${i}_ o_txpipe${i}_encodedecodebypass                 encodedecodebypass                           1  STD_LOGIC        Output"
                 puts $ScriptFile "#pipe_intf add_instantiation_interface_port o_txpipe${i}_ o_txpipe${i}_fs                                 fs                                           6  STD_LOGIC_VECTOR Output"
                 puts $ScriptFile "#pipe_intf add_instantiation_interface_port o_txpipe${i}_ o_txpipe${i}_getlocalpresetcoefficients         getlocalpresetcoefficients                   1  STD_LOGIC        Output"
                 puts $ScriptFile "#pipe_intf add_instantiation_interface_port o_txpipe${i}_ o_txpipe${i}_invalidrequest                     invalidrequest                               1  STD_LOGIC        Output"
                 puts $ScriptFile "#pipe_intf add_instantiation_interface_port o_txpipe${i}_ o_txpipe${i}_lf                                 lf                                           6  STD_LOGIC_VECTOR Output"
                 puts $ScriptFile "#pipe_intf add_instantiation_interface_port o_txpipe${i}_ o_txpipe${i}_localpresetindex                   localpresetindex                             5  STD_LOGIC_VECTOR Output"
                 puts $ScriptFile "#pipe_intf add_instantiation_interface_port o_txpipe${i}_ o_txpipe${i}_m2p_bus                            m2p_bus                                      8  STD_LOGIC_VECTOR Output"
                 puts $ScriptFile "#pipe_intf add_instantiation_interface_port o_txpipe${i}_ o_txpipe${i}_pclk_rate                          pclk_rate                                    3  STD_LOGIC_VECTOR Output"
                 puts $ScriptFile "#pipe_intf add_instantiation_interface_port o_txpipe${i}_ o_txpipe${i}_pclkchangeack                      pclkchangeack                                1  STD_LOGIC        Output"
                 puts $ScriptFile "#pipe_intf add_instantiation_interface_port o_txpipe${i}_ o_txpipe${i}_powerdown                          powerdown                                    4  STD_LOGIC_VECTOR Output"
                 puts $ScriptFile "#pipe_intf add_instantiation_interface_port o_txpipe${i}_ o_txpipe${i}_rate                               rate                                         3  STD_LOGIC_VECTOR Output"
                 puts $ScriptFile "#pipe_intf add_instantiation_interface_port o_txpipe${i}_ o_txpipe${i}_rxelecidle_disable_a               rxelecidle_disable_a                         1  STD_LOGIC        Output"
                 puts $ScriptFile "#pipe_intf add_instantiation_interface_port o_txpipe${i}_ o_txpipe${i}_rxeqeval                           rxeqeval                                     1  STD_LOGIC        Output"
                 puts $ScriptFile "#pipe_intf add_instantiation_interface_port o_txpipe${i}_ o_txpipe${i}_rxeqinprogress                     rxeqinprogress                               1  STD_LOGIC        Output"
                 puts $ScriptFile "#pipe_intf add_instantiation_interface_port o_txpipe${i}_ o_txpipe${i}_rxeqtraining                       rxeqtraining                                 1  STD_LOGIC        Output"
                 puts $ScriptFile "#pipe_intf add_instantiation_interface_port o_txpipe${i}_ o_txpipe${i}_rxpolarity                         rxpolarity                                   1  STD_LOGIC        Output"
                 puts $ScriptFile "#pipe_intf add_instantiation_interface_port o_txpipe${i}_ o_txpipe${i}_rxpresethint                       rxpresethint                                 3  STD_LOGIC_VECTOR Output"
                 puts $ScriptFile "#pipe_intf add_instantiation_interface_port o_txpipe${i}_ o_txpipe${i}_rxstandby                          rxstandby                                    1  STD_LOGIC        Output"
                 puts $ScriptFile "#pipe_intf add_instantiation_interface_port o_txpipe${i}_ o_txpipe${i}_rxtermination                      rxtermination                                1  STD_LOGIC        Output"
                 puts $ScriptFile "#pipe_intf add_instantiation_interface_port o_txpipe${i}_ o_txpipe${i}_srisenable                         srisenable                                   1  STD_LOGIC        Output"
                 puts $ScriptFile "#pipe_intf add_instantiation_interface_port o_txpipe${i}_ o_txpipe${i}_txcmnmode_disable_a                txcmnmode_disable_a                          1  STD_LOGIC        Output"
                 puts $ScriptFile "#pipe_intf add_instantiation_interface_port o_txpipe${i}_ o_txpipe${i}_txcompliance                       txcompliance                                 1  STD_LOGIC        Output"
                 puts $ScriptFile "#pipe_intf add_instantiation_interface_port o_txpipe${i}_ o_txpipe${i}_txdata                             txdata                                       40 STD_LOGIC_VECTOR Output"
                 puts $ScriptFile "#pipe_intf add_instantiation_interface_port o_txpipe${i}_ o_txpipe${i}_txdatak                            txdatak                                      4  STD_LOGIC_VECTOR Output"
                 puts $ScriptFile "#pipe_intf add_instantiation_interface_port o_txpipe${i}_ o_txpipe${i}_txdatavalid                        txdatavalid                                  1  STD_LOGIC        Output"
                 puts $ScriptFile "#pipe_intf add_instantiation_interface_port o_txpipe${i}_ o_txpipe${i}_txdeemph                           txdeemph                                     18 STD_LOGIC_VECTOR Output"
                 puts $ScriptFile "#pipe_intf add_instantiation_interface_port o_txpipe${i}_ o_txpipe${i}_txdtctrx_lb                        txdtctrx_lb                                  1  STD_LOGIC        Output"
                 puts $ScriptFile "#pipe_intf add_instantiation_interface_port o_txpipe${i}_ o_txpipe${i}_txelecidle                         txelecidle                                   1  STD_LOGIC        Output"
                 puts $ScriptFile "#pipe_intf add_instantiation_interface_port o_txpipe${i}_ o_txpipe${i}_txmargin                           txmargin                                     3  STD_LOGIC_VECTOR Output"
                 puts $ScriptFile "#pipe_intf add_instantiation_interface_port o_txpipe${i}_ o_txpipe${i}_txoneszeros                        txoneszeros                                  1  STD_LOGIC        Output"
                 puts $ScriptFile "#pipe_intf add_instantiation_interface_port o_txpipe${i}_ o_txpipe${i}_txstartblock                       txstartblock                                 1  STD_LOGIC        Output"
                 puts $ScriptFile "#pipe_intf add_instantiation_interface_port o_txpipe${i}_ o_txpipe${i}_txswing                            txswing                                      1  STD_LOGIC        Output"
                 puts $ScriptFile "#pipe_intf add_instantiation_interface_port o_txpipe${i}_ o_txpipe${i}_txsyncheader                       txsyncheader                                 4  STD_LOGIC_VECTOR Output"
                 puts $ScriptFile "#pipe_intf add_instantiation_interface_port o_txpipe${i}_ o_txpipe${i}_width                              width                                        3  STD_LOGIC_VECTOR Output"
                 
                 puts $ScriptFile "#pipe_intf set_interface_property o_txpipe${i}_ EXPORT_OF dut.o_txpipe${i}_"
                 }
                 puts $ScriptFile  "#pipe_intf save_instantiation"
                }



        if { $xcvr_reconfig == 1 } {
            puts $ScriptFile "set_interface_property dummy_user_avmm_rst EXPORT_OF dut.dummy_user_avmm_rst"
            if {[lsearch $hdr_pck_schme_list 1] != -1} { 
                puts $ScriptFile "add_connection clk_div_inst.clock_div4x dut.xcvr_reconfig_clk"
            } else {
                puts $ScriptFile "add_connection iopll_0.outclk1 dut.xcvr_reconfig_clk"
            }
            puts $ScriptFile "set_interface_property xcvr_reconfig EXPORT_OF dut.xcvr_reconfig"
        }
        
        if { $enable_perf} {        
            for {set ip_num 0} {$ip_num < $core_num} {incr ip_num} {

                for {set i 0} {$i < [lindex $axi_num_seg_list $ip_num]} {incr i} {
                    puts $ScriptFile "add_connection axis2avst_conv_${ip_num}.rx_st${i} perf${ip_num}.p0_rx_st${i}"
                }
                for {set i 0} {$i < [lindex $avst_num_seg $ip_num]} {incr i} {
                    puts $ScriptFile "add_connection perf${ip_num}.p0_tx_st${i} avst2axis_conv_${ip_num}.tx_st${i} "
                }
                puts $ScriptFile "add_connection axis2avst_conv_${ip_num}.rx_st0_misc perf${ip_num}.p0_rx_st_misc "
                puts $ScriptFile "add_connection perf${ip_num}.p0_tx_st_misc avst2axis_conv_${ip_num}.tx_st0_misc "
                puts $ScriptFile "add_connection rst_ctrl_${ip_num}.rst_n_sys perf${ip_num}.p0_reset_status_n"

                if {[lindex $hdr_pck_schme_list $ip_num]} { 
                    puts $ScriptFile "add_connection dut.coreclkout_hip_toapp perf${ip_num}.coreclkout_hip"
                } else {
                    puts $ScriptFile "add_connection iopll_0.outclk0 perf${ip_num}.coreclkout_hip"
                }

                if {$tile_name != "R-TILE"} {
                    puts $ScriptFile "add_connection dut.p${ip_num}_st_txcrdt perf${ip_num}.p0_tx_cred_dut"
                }
            }
        }  elseif { $enable_multi_func_hwtcl == 0 && $sriov_en == 0} {

            for {set ip_num 0} {$ip_num < $core_num} {incr ip_num} {
                # Adaptor Connections
                for {set i 0} {$i < [lindex $axi_num_seg_list $ip_num]} {incr i} {
                    puts $ScriptFile "add_connection axis2avst_conv_${ip_num}.rx_st${i} pio${ip_num}.rx_st${i}_pio "
                }
                for {set i 0} {$i < [lindex $avst_num_seg $ip_num]} {incr i} {
                    puts $ScriptFile "add_connection pio${ip_num}.tx_st${i}_pio avst2axis_conv_${ip_num}.tx_st${i} "
                }
                puts $ScriptFile "add_connection axis2avst_conv_${ip_num}.rx_st0_misc pio${ip_num}.rx_st0_pio_misc "
                puts $ScriptFile "add_connection pio${ip_num}.tx_st0_pio_misc avst2axis_conv_${ip_num}.tx_st0_misc "

                # B1. Connecting MEM
                puts $ScriptFile "# Connecting MEM"
                puts $ScriptFile "add_connection pio${ip_num}.pio_master_reset MEM${ip_num}.reset1"
                puts $ScriptFile "add_connection pio${ip_num}.pio_master_clk MEM${ip_num}.clk1"
                puts $ScriptFile "add_connection pio${ip_num}.pio_master MEM${ip_num}.s1"

                # B2. Connecting PIO
                puts $ScriptFile "# Connecting PIO"
                puts $ScriptFile "add_connection rst_ctrl_${ip_num}.rst_n_sys pio${ip_num}.reset"
                if {[lindex $hdr_pck_schme_list $ip_num]} { 
                    puts $ScriptFile "add_connection dut.coreclkout_hip_toapp pio${ip_num}.clk"
                } else {
                    puts $ScriptFile "add_connection iopll_0.outclk0 pio${ip_num}.clk"
                }
            }
          
		} else {

            set core16_enable_error_intf_hwtcl    [ip_get "parameter.core16_enable_error_intf_hwtcl.value"]
            set core16_enable_rx_buffer_limit_ports_hwtcl    [ip_get "parameter.core16_enable_rx_buffer_limit_ports_hwtcl.value"]
                    
            puts $ScriptFile "# Connecting SRIOV"
            for {set ip_num 0} {$ip_num < $core_num} {incr ip_num} {
                for {set i 0} {$i < [lindex $axi_num_seg_list $ip_num]} {incr i} {
                    puts $ScriptFile "add_connection axis2avst_conv_${ip_num}.rx_st${i} sriov_apps${ip_num}.rx_st${i} "
                }                    
                for {set i 0} {$i < [lindex $avst_num_seg $ip_num]} {incr i} {
                    puts $ScriptFile "add_connection sriov_apps${ip_num}.tx_st${i} avst2axis_conv_${ip_num}.tx_st${i} "
                }
                puts $ScriptFile "add_connection rst_ctrl_${ip_num}.rst_n_sys sriov_apps${ip_num}.clr_st"
                if {[lindex $hdr_pck_schme_list $ip_num]} { 
                    puts $ScriptFile "add_connection dut.coreclkout_hip_toapp sriov_apps${ip_num}.clk"
                } else {
                    puts $ScriptFile "add_connection iopll_0.outclk0 sriov_apps${ip_num}.clk"
                }
                puts $ScriptFile "add_connection axis2avst_conv_${ip_num}.rx_st0_misc sriov_apps${ip_num}.sriov_apps "
                puts $ScriptFile "add_connection sriov_apps${ip_num}.p0_tx_st_misc avst2axis_conv_${ip_num}.tx_st0_misc "
            } 
        }

        for {set ip_num 0} {$ip_num < $core_num} {incr ip_num} {

            puts $ScriptFile "add_connection dut.p${ip_num}_st_rx axis2avst_conv_${ip_num}.p0_st_rx "
            puts $ScriptFile "add_connection avst2axis_conv_${ip_num}.p0_st_tx dut.p${ip_num}_st_tx "

            puts $ScriptFile "add_connection dut.p${ip_num}_ss_app_st_rx_tuser_vendor axis2avst_conv_${ip_num}.app_ss_st_rx_tuser_vendor "
            puts $ScriptFile "add_connection dut.p${ip_num}_ss_app_st_rx_tuser_last_segment axis2avst_conv_${ip_num}.app_ss_st_rx_tuser_last_segment "
            puts $ScriptFile "add_connection dut.p${ip_num}_ss_app_st_rx_tuser_hvalid axis2avst_conv_${ip_num}.app_ss_st_rx_tuser_hvalid "
            puts $ScriptFile "add_connection dut.p${ip_num}_ss_app_st_rx_tuser_hdr axis2avst_conv_${ip_num}.app_ss_st_rx_tuser_hdr "
            if {$tile_name == "R-TILE" && [lindex $hdr_pck_schme_list $ip_num]} {
                puts $ScriptFile "add_connection axis2avst_conv_${ip_num}.ss_app_rxcrdt dut.p${ip_num}_st_rxcrdt"
            }
            
            if {$enable_perf == 0 || ($enable_perf == 1 && $tile_name == "R-TILE")} {
                puts $ScriptFile "add_connection dut.p${ip_num}_st_txcrdt avst2axis_conv_${ip_num}.ss_app_txcrdt"
            }

            puts $ScriptFile "add_connection avst2axis_conv_${ip_num}.axi_st_tx_tuser_last_segment  dut.p${ip_num}_app_ss_st_tx_tuser_last_segment"
            puts $ScriptFile "add_connection avst2axis_conv_${ip_num}.axi_st_tx_tuser_hvalid  dut.p${ip_num}_app_ss_st_tx_tuser_hvalid"
            puts $ScriptFile "add_connection avst2axis_conv_${ip_num}.axi_st_tx_tuser_hdr dut.p${ip_num}_app_ss_st_tx_tuser_hdr"
            
            # puts $ScriptFile "add_connection dut.p${ip_num}_reset_status_n axis2avst_conv_${ip_num}.axi_st_areset_n"
            puts $ScriptFile "add_connection rst_ctrl_${ip_num}.rst_n_sys axis2avst_conv_${ip_num}.warm_rst_n"
            # puts $ScriptFile "add_connection dut.p${ip_num}_reset_status_n avst2axis_conv_${ip_num}.rst_n"
            puts $ScriptFile "add_connection rst_ctrl_${ip_num}.rst_n_sys avst2axis_conv_${ip_num}.rst_n"
            
            if {[lindex $hdr_pck_schme_list $ip_num]} { 
                puts $ScriptFile "add_connection dut.coreclkout_hip_toapp axis2avst_conv_${ip_num}.axi_st_clk"
                puts $ScriptFile "add_connection dut.coreclkout_hip_toapp avst2axis_conv_${ip_num}.axi_st_clk"
                puts $ScriptFile "add_connection dut.coreclkout_hip_toapp dut.p${ip_num}_axi_st_clk"
                puts $ScriptFile "add_connection dut.coreclkout_hip_toapp rst_ctrl_${ip_num}.clk_sys"
                
                puts $ScriptFile "add_connection clk_div_inst.clock_div4x dut.p${ip_num}_axi_lite_clk"
                puts $ScriptFile "add_connection clk_div_inst.clock_div4x rst_ctrl_${ip_num}.clk_100m"
                puts $ScriptFile "add_connection clk_div_inst.clock_div4x flr_lpbk_inst_${ip_num}.axilite_clk"
                puts $ScriptFile "add_connection clk_div_inst.clock_div4x avst2axis_conv_${ip_num}.axi_lite_clk"
            } else {
                puts $ScriptFile "add_connection iopll_0.outclk0 axis2avst_conv_${ip_num}.axi_st_clk"
                puts $ScriptFile "add_connection iopll_0.outclk0 avst2axis_conv_${ip_num}.axi_st_clk"
                puts $ScriptFile "add_connection iopll_0.outclk0 dut.p${ip_num}_axi_st_clk"
                puts $ScriptFile "add_connection iopll_0.outclk0 rst_ctrl_${ip_num}.clk_sys"
                puts $ScriptFile "add_connection iopll_0.outclk1 dut.p${ip_num}_axi_lite_clk"
                puts $ScriptFile "add_connection iopll_0.outclk1 rst_ctrl_${ip_num}.clk_100m"
                puts $ScriptFile "add_connection iopll_0.outclk1 flr_lpbk_inst_${ip_num}.axilite_clk"
                puts $ScriptFile "add_connection iopll_0.outclk1 avst2axis_conv_${ip_num}.axi_lite_clk"
                
                if {$ip_num < ($core_num -1)} {
                    puts $ScriptFile "add_connection rst_ctrl_${ip_num}.pll_locked_o rst_ctrl_[expr {$ip_num +1}].pll_locked"
                } 
            }

            # Flr loopback module connections
            puts $ScriptFile "add_connection rst_ctrl_${ip_num}.rst_n_100m flr_lpbk_inst_${ip_num}.rstn"
            puts $ScriptFile "add_connection dut.p${ip_num}_st_flrrcvd flr_lpbk_inst_${ip_num}.ss_app_flr_rcvd"
            puts $ScriptFile "add_connection flr_lpbk_inst_${ip_num}.app_ss_flr_cmpl dut.p${ip_num}_st_flrcmpl"


            puts $ScriptFile "# Connecting Reset Control ${ip_num}"
            puts $ScriptFile "add_connection dut.p${ip_num}_reset_status_n rst_ctrl_${ip_num}.pcie_reset_status"
            puts $ScriptFile "add_connection dut.p${ip_num}_subsystem_cold_rst_ack_n rst_ctrl_${ip_num}.pcie_cold_rst_ack_n"
            puts $ScriptFile "add_connection dut.p${ip_num}_subsystem_warm_rst_ack_n rst_ctrl_${ip_num}.pcie_warm_rst_ack_n"
            puts $ScriptFile "add_connection dut.p${ip_num}_initiate_warmrst_req rst_ctrl_${ip_num}.initiate_warmrst_req"
            puts $ScriptFile "add_connection rst_ctrl_${ip_num}.initiate_rst_req_rdy dut.p${ip_num}_initiate_rst_req_rdy"
            puts $ScriptFile "add_connection dut.p${ip_num}_subsystem_rst_rdy rst_ctrl_${ip_num}.subsystem_rst_rdy"
            puts $ScriptFile "add_connection rst_ctrl_${ip_num}.subsystem_rst_req dut.p${ip_num}_subsystem_rst_req"
            puts $ScriptFile "add_connection resetIP.ninit_done rst_ctrl_${ip_num}.ninit_done"
            puts $ScriptFile "add_connection rst_ctrl_${ip_num}.rst_n_sys dut.p${ip_num}_axi_st_areset_n"
            puts $ScriptFile "add_connection rst_ctrl_${ip_num}.rst_n_100m dut.p${ip_num}_axi_lite_areset_n"
            puts $ScriptFile "add_connection dut.p${ip_num}_reset_status_n dut.p${ip_num}_subsystem_cold_rst_n"
            puts $ScriptFile "add_connection dut.p${ip_num}_reset_status_n dut.p${ip_num}_subsystem_warm_rst_n"
            
            puts $ScriptFile "# Connecting Error Gen Interface Control ${ip_num}"
            puts $ScriptFile "add_connection avst2axis_conv_${ip_num}.p0_st_err dut.p${ip_num}_st_err"
            puts $ScriptFile "add_connection avst2axis_conv_${ip_num}.p0_app_ss_st_err_tuser_error_type dut.p${ip_num}_app_ss_st_err_tuser_error_type"
            puts $ScriptFile "add_connection rst_ctrl_${ip_num}.rst_n_100m avst2axis_conv_${ip_num}.rst_lite_n"

        }


        ###################  AUTOMATE PIPELINE ###################

        puts $ScriptFile "set_domain_assignment {\$system} qsys_mm.enableAllPipelines TRUE"

        # ###################                    ###################

        puts $ScriptFile "add_connection resetIP.ninit_done dut.ninit_done"
        if {[lsearch $hdr_pck_schme_list 1] != -1} { 
            puts $ScriptFile "add_connection dut.coreclkout_hip_toapp clk_div_inst.inclk"
        } 

        if {[lsearch $hdr_pck_schme_list 0] != -1} {
            puts $ScriptFile "add_connection iopll_0.locked rst_ctrl_0.pll_locked"
            puts $ScriptFile "add_connection dut.coreclkout_hip_toapp iopll_0.refclk"
            puts $ScriptFile "add_connection resetIP.ninit_done iopll_0.reset"
        }

  
        puts $ScriptFile "sync_sysinfo_parameters"

        puts $ScriptFile "save_system ${QSYSTemPath}"

        puts $ScriptFile "load_system ${QSYSTemPath}"

        puts $ScriptFile "sync_sysinfo_parameters"

        puts $ScriptFile "save_system ${QSYSTemPath}"
	    close $ScriptFile
	    
	    
        #HSD: 15016743369
        # PY edit
        #Copy pcie_ss_ed.tcl to pcie_ss_ed_sim.tcl and set pipemode_sim_ed_hwtcl value from GUI
        file copy -force "${TEMPPATH}/pcie_ss_ed.tcl" "${TEMPPATH}/pcie_ss_ed_sim.tcl"
        set pcie_ss_ed_sim_rd [open ${TEMPPATH}/pcie_ss_ed.tcl "r"]
        set pcie_ss_ed_sim_wr [open ${TEMPPATH}/pcie_ss_ed_sim.tcl "w"]
        set pcie_ss_ed_sim_content [read $pcie_ss_ed_sim_rd]
    
        set pipemode_sim_for_ed_hwtcl                      [ip_get "parameter.pipemode_sim_for_ed_hwtcl.value"]
        
        regsub -all "pipemode_sim_ed_hwtcl 0" $pcie_ss_ed_sim_content "pipemode_sim_ed_hwtcl ${pipemode_sim_for_ed_hwtcl}" pcie_ss_ed_sim_content
        #regsub -all "pcie_ss_ed" $pcie_ss_ed_sim_content "pcie_ss_ed_sim" pcie_ss_ed_sim_content

        if {$pipemode_sim_for_ed_hwtcl == 1} {
        regsub -all "#pipe_intf " $pcie_ss_ed_sim_content "" pcie_ss_ed_sim_content}
        
        set pcie_ss_ed_sim_content [split $pcie_ss_ed_sim_content "\n"]
        foreach line $pcie_ss_ed_sim_content {
            
            if {[regexp "load_system" $line] || [regexp "save_system" $line] } {
                regsub -all "pcie_ss_ed.qsys" $line "pcie_ss_ed_sim.qsys" line
                puts $pcie_ss_ed_sim_wr "$line"
            } else {
                regsub -all "pcie_ss_ed" $line "pcie_ss_ed_sim" line
                puts $pcie_ss_ed_sim_wr "$line"
            }
        }
        
        #puts $pcie_ss_ed_sim_wr $pcie_ss_ed_sim_content
        
        close $pcie_ss_ed_sim_wr
        close $pcie_ss_ed_sim_rd
        #PY edit end        

        ###########################################################################################################

        # Now going to run pcie_ss_ed.tcl to create qsys, qpf and qsf files.
        global env
        set QSYS_ROOTDIR $env(QUARTUS_ROOTDIR)
        set QSYS_ROOTDIR "${QSYS_ROOTDIR}/sopc_builder/bin/"
        
        if { [ file exist $QSYSScriptPath ] == 1 } {
            # Run pcie_ss_ed.tcl
            send_message info "Generating QSYS system ${QSYSTem}"
            send_message info "Running: qsys-script --pro --script=${QSYSScript}"
            set foo [catch "exec ${QSYS_ROOTDIR}qsys-script --pro --script=${QSYSScriptPath}" msg]
            set foo [catch "exec ${QSYS_ROOTDIR}qsys-script --pro --script=pcie_ss_ed_sim.tcl" msg]
            
            if {[string match "*Error:*" $msg]} {
                send_message ERROR "Error when executing: qsys-script"
                send_message ERROR "Error message: $msg"
            }

            # Store printout as pcie_ed_tcl_log.txt
            set logFile [open $QSYSScriptLogPath "w"]
            puts $logFile $msg
            close $logFile

            # Now going to generate HDL files
            catch {cd $ORIDIR}
            if { [ file exist $QSYSTemPath ] == 1 } {
                # If qsys file exists, time to generate files
                ::intel_pcie_ss_axi::generate_design_example_files  ${QSYSTemPath} ${QSYSTemName} ${TEMPPATH} ${hdr_pck_schme_list}
            } else {
                # Otherwise fail and prompt user to read qsys script log
                add_fileset_file ${QSYSScript} OTHER PATH ${QSYSScriptPath}
                add_fileset_file ${QSYSScriptLog} OTHER PATH ${QSYSScriptLogPath}
                # send_message error "Unable to create ${QSYSTem}, read ${QSYSScriptLog} for log"
                send_message info "Copied ${QSYSScript} and ${QSYSScriptLog} to the example design directory."
            }

             # Generate software files.
            ::intel_pcie_ss_axi::software_fileset

        } else {
            # Script file does not exist
            send_message error "Unable to locate ${QSYSScriptPath}"
        }
    }


        # entry point proc to generate the RTL files, will call s10_pcie_devkit_prj to generate files based on settings for syn, sim
    proc ::intel_pcie_ss_axi::generate_design_example_files { qsys_design_example_fullpath exdes_prj_name ORI_TEMP_PATH hdr_pck_schme_list} {
        
        global env
        set IP_ROOTDIR $env(QUARTUS_ROOTDIR)
        set IP_ROOTDIR "${IP_ROOTDIR}/../ip"
        set tile_name   [ip_get "parameter.TILE.value"]
        set topology [ip_get "parameter.top_topology_hwtcl.value"]
        set dtk_enable [ip_get "parameter.xcvr_reconfig_hwtcl.value"]
        
        send_message info "Example design generation"
        
        # JW temp comment and set
        #  set ed_synth_hwtcl 1
        #  set ed_sim_hwtcl 0
        set ed_synth_hwtcl         [ip_get "parameter.enable_example_design_synth_hwtcl.value"]
        set ed_sim_hwtcl           [ip_get "parameter.enable_example_design_sim_hwtcl_ed.value"  ]

        if {($tile_name == "R-TILE" && [regexp "4x4" $topology]) || $dtk_enable } {
            set ed_sim_hwtcl 0
        }
        
        if { $ed_synth_hwtcl > 0 } {
            send_message info "The example design synthesis files will be generated"
        } else {
            send_message info "Skip the generation of the example synthesis simulation files"
        }
        
        if { $ed_sim_hwtcl > 0 } {
            send_message info "The example design simulation files will be generated"
            set ed_tb_hwtcl  1
        } else {
            send_message info "Skip the generation of the example design simulation files"
            set ed_tb_hwtcl  0
        }
        
        set ORIDIR [pwd]
        set TEMPPATH [create_temp_file ""]

        
        # Copy QSYS system and qshell/qsys script to temp directory
        if { [ file exist $qsys_design_example_fullpath ] == 0 } {
            file copy "${qsys_design_example_fullpath}" "${TEMPPATH}/${exdes_prj_name}.qsys"
        }
        send_message info "Targeting FPGA Development kit ...."
    
        catch {cd $TEMPPATH}

        # Generate required files in Temp directory
        ::intel_pcie_ss_axi::s10_pcie_devkit_prj ${exdes_prj_name} ${ed_synth_hwtcl} ${ed_sim_hwtcl} ${TEMPPATH} ${ORI_TEMP_PATH}

        # ------ ED SDC generation ------
        if {[lsearch $hdr_pck_schme_list 1] != -1} {
            set hip_com "HIP_NATIVE"
        } else {set hip_com "COMPACT"}

        set template_path "${IP_ROOTDIR}/altera/subsystems/intel_pcie_ss_axi/ed/pcie_ss_ed.sdc.terp"
        set template_fd   [open $template_path] ;# file handle for template
        set template      [read $template_fd]   ;# template contents
        set replacement [list "AABBCCDD" ${hip_com} "TILE_NAME" ${tile_name}]
        set modified_content [string map {-nocase} $replacement $template] 
        close $template_fd ;# we are done with the file so we should close it

        set contents $template

        add_fileset_file pcie_ss_ed.sdc SDC TEXT ${modified_content}
        # ------ End of SDC generation ------

          # ------ create quartus.ini ------

        if {$tile_name == "R-TILE"}  {
            set QINIPath   "${TEMPPATH}/quartus.ini"
            set create_ini [open $QINIPath "w"]
            puts $create_ini "asm_enable_advanced_devices=on"
            puts $create_ini "force_vid_off=on"
            close $create_ini
        }

        # jkoe ------ runnin ip-setup-simulation to compile all filelists ------
	    # HSD: 1508772506 - ip-setup-simulation flow is not working for PCIe ED, so we do not use the vcs_files.tcl generated in sim output directory
        if { $ed_sim_hwtcl > 0 } {
            set QSYS_ROOTDIR $env(QUARTUS_ROOTDIR)
            set QSYS_ROOTDIR "${QSYS_ROOTDIR}/sopc_builder/bin/"
            set SetupSimulationLogPath "${TEMPPATH}/output_setup_simulation.log"
        
            send_message info "Running ip-setup-simulation"
            catch {cd $TEMPPATH}
            set enable_multi_func_hwtcl                 [ip_get "parameter.core16_enable_multi_func_hwtcl.value"]
            set foo [catch "exec ${QSYS_ROOTDIR}/ip-setup-simulation --quartus-project=pcie_ss_ed_sim.qpf --output-directory=pcie_ss_ed_sim_tb/pcie_ss_ed_sim_tb/sim --use-relative-paths" msg]	

            catch {cd $TEMPPATH}

            if {[string match "*Error:*" $msg]} {
                send_message ERROR "Error when executing: ip-setup-simulation"
                send_message ERROR "Error message: $msg"
            }
            #HSD:15017583023 Post-processing to replace ld -> ld_debug for +acc
            set ed_tb_path_msim     "${TEMPPATH}/pcie_ss_ed_sim_tb/pcie_ss_ed_sim_tb/sim/mentor"
            if { [ file exist $ed_tb_path_msim ] == 1 } {
                # Define the file name
                set filename "${ed_tb_path_msim}/run_msim_setup.tcl"
                # Check if the file exists
                if {[file exists $filename]} {
                    send_message info "File $filename exists."
                    file copy -force "${ed_tb_path_msim}/run_msim_setup.tcl" "${ed_tb_path_msim}/run_msim_setup.tcl.ori"
                    set pcie_top_syn_rd [open ${ed_tb_path_msim}/run_msim_setup.tcl.ori "r"] 
                    set pcie_top_syn_wr [open ${ed_tb_path_msim}/run_msim_setup.tcl "w"] 
                    set pcie_top_content [read $pcie_top_syn_rd]
                    regsub -all "ld" $pcie_top_content "ld_debug" pcie_top_content
                    regsub -all "sold_debug" $pcie_top_content "sold" pcie_top_content
                    puts $pcie_top_syn_wr $pcie_top_content
                    close $pcie_top_syn_wr
                    close $pcie_top_syn_rd
                    file delete -force "${ed_tb_path_msim}/run_msim_setup.tcl.ori"
                } else {
                    puts "File $filename does not exist."
                    send_message error "File $filename does not exist."
                    
                }
            }
            #ww after ip-setup-simulation
            set logFile [open $SetupSimulationLogPath "w"]
            puts $logFile $msg
            close $logFile
	    }
        
        # Checking to see if it worked
        set FAILGEN "${TEMPPATH}/${exdes_prj_name}_fail.txt"
        if { [ file exist $FAILGEN ] == 1 } {
            # A fail file was created
            send_message error "Unable to generate HDL files for the system ${exdes_prj_name}.qsys"
        }
        

        # Copy all generated files to the example design user directory regardless of pass/fail
        ::intel_pcie_ss_axi::example::add_files_recursive [ pwd ]
        catch {cd $ORIDIR}


    }



    proc ::intel_pcie_ss_axi::s10_pcie_devkit_prj {project_name GenerateSynth GenerateSimTb TEMPPATH ORI_TEMP_PATH} {
        #--------------------------------------------------------------#
        # s10-pcie-devkit-prj:  Generating simulation, synthesis and pin assignments.
        #
        # Arguments
        # $project_name : Qsys and QPF file name
        # $GenerateSynth : Generate DUT RTL Files. 0 --> No Synth, 1 --> Verilog, 2 --> VHDL
        # $GenerateSimTb : Generate TB Sim
        
        global env
        set IP_ROOTDIR $env(QUARTUS_ROOTDIR)
        set IP_ROOTDIR "${IP_ROOTDIR}/../ip"
        
        set QSYS_ROOTDIR $env(QUARTUS_ROOTDIR)
        set QSYS_ROOTDIR "${QSYS_ROOTDIR}/sopc_builder/bin/"

        #--------------------------------------------------------------#
        # Input Arguments
        
        switch $GenerateSynth {
            "1"         { set qsys_gen_synth "--synthesis=VERILOG" }
            "2"         { set qsys_gen_synth "--synthesis=VHDL" }
            default     { set qsys_gen_synth "--synthesis=VERILOG" }
        }

        #--------------------------------------------------------------#
        # Setting up flags
        
        set DeviceQSF [ip_get "parameter.chosen_devkit_opn_hwtcl.value"]
        
        send_message info "Now generating HDL files..."
        send_message info "Project name                    : $project_name"
        send_message info "Generate QSYS synthesis example : $GenerateSynth"
        send_message info "Generate simulation testbench   : $GenerateSimTb"
        send_message info "Device                          : $DeviceQSF"
        
        set PassSynthGeneration 1
        set PassSimGeneration 1
        set PassPinoutGeneration 1
        
        #--------------------------------------------------------------#
        # Setting up filenames
        
        set s10_devkit_tcl "${project_name}_s10_revd_devkit_qsf.tcl"
        set qsys_filename "${project_name}.qsys"
        set failgen "${project_name}_fail.txt"
        set sim_msg_filename "${project_name}_simulation_report.txt"
        set synth_msg_filename "${project_name}_synthesis_report.txt"
        set pinout_msg_filename "${project_name}_pinout_report.txt"
        set recommended_pinassignments_s10 "recommended_pinassignments_s10.txt"
        set example_design_mode_hwtcl [ip_get "parameter.example_design_mode_hwtcl.value"]
        set top_topology_hwtcl [ip_get "parameter.top_topology_hwtcl.value"]
        set dwidth_byte [ip_get "parameter.core16_dwidth_byte_user_hwtcl.value"]
        
        #--------------------------------------------------------------#
        # Cleanup previous dir
        
        file delete -force -- ${project_name}
        if { [ file exist $failgen ] == 1 } {
            file delete -force -- ${failgen}
        }

        #--------------------------------------------------------------#
        # Generating simulation testbench
        
        if { $GenerateSimTb > 0 } {
            send_message info "Generating simulation testbench..."
            send_message info "Running: qsys-generate ${project_name}.qsys --simulation=VERILOG --testbench=STANDARD --testbench-simulation=VERILOG --part=${DeviceQSF}"
            
            if {[ catch {exec  ${QSYS_ROOTDIR}qsys-generate pcie_ss_ed_sim.qsys --simulation=VERILOG --testbench=STANDARD --testbench-simulation=VERILOG --part=${DeviceQSF}} msg ] && [ catch {exec  ${QSYS_ROOTDIR}qsys-generate ${project_name}.qsys --simulation=VERILOG --part=${DeviceQSF}} msg ]} {
                set SIM_MSG [ open $sim_msg_filename "w" ]
                puts $SIM_MSG $msg
                close $SIM_MSG
            }
            if {[string match "*Error:*" $msg]} {
                send_message ERROR "Error when executing: qsys-generate"
                send_message ERROR "Error message: $msg"
            }
            
            set TBQSYS "${project_name}_sim_tb/${project_name}_sim_tb.qsys"
            if { [ file exist ${TEMPPATH}/${TBQSYS} ] == 1 } {
                send_message info "Passed ${project_name}.qsys simulation generation"
                if {[ip_get "parameter.TILE.value"] == "R-TILE" && [regexp "PERFORMANCE_DESIGN" $example_design_mode_hwtcl] && [regexp "Gen5 1x16" $top_topology_hwtcl]} {
                    set perf_crdt [searchFiles ${TEMPPATH}/ip/pcie_ss_ed_sim/ *sim/perf_gen5_ed_bam_crdt_intf.sv]
                    set f [open $perf_crdt  r+] ; puts -nonewline $f [string map {85*5 \(85*5\)+470} [read $f]][seek $f 0;list] ; close $f
                    set f [open $perf_crdt  r+] ; puts -nonewline $f [string map {11*5 \(11*5\)+500} [read $f]][seek $f 0;list] ; close $f
                    set f [open $perf_crdt  r+] ; puts -nonewline $f [string map {10*5 \(10*5\)+500} [read $f]][seek $f 0;list] ; close $f
                    
                    set perf_crdt1 [searchFiles ${TEMPPATH}/ip/pcie_ss_ed/ *sim/perf_gen5_ed_bam_crdt_intf.sv]
                    set f [open $perf_crdt1  r+] ; puts -nonewline $f [string map {85*5 \(85*5\)+470} [read $f]][seek $f 0;list] ; close $f
                    set f [open $perf_crdt1  r+] ; puts -nonewline $f [string map {11*5 \(11*5\)+500} [read $f]][seek $f 0;list] ; close $f
                    set f [open $perf_crdt1  r+] ; puts -nonewline $f [string map {10*5 \(10*5\)+500} [read $f]][seek $f 0;list] ; close $f
                } 

                if { [ regexp "PERFORMANCE_DESIGN" $example_design_mode_hwtcl]} {
                    set bfm [searchFiles ${TEMPPATH}/ *altpcietb_bfm_rp_gen*sv]
                    set f [open $bfm  r+] ; puts -nonewline $f [string map {pcie_ed_sim pcie_ss_ed_sim} [read $f]][seek $f 0;list] ; close $f
                }
                
                #pipemode
                set pipemode_sim_for_ed_hwtcl   [ip_get "parameter.pipemode_sim_for_ed_hwtcl.value"]
                if {$pipemode_sim_for_ed_hwtcl && [ip_get "parameter.TILE.value"] == "R-TILE"} {
                    set tbed_hwtcl_pipe [searchFiles ${TEMPPATH}/ *intel_rtile_pcie_tbed_hwtcl.sv]
                    set tbed_hwtcl_altbfm [searchFiles ${TEMPPATH}/ *altpcietb_bfm_rp_gen*.sv]
                    set f [open $tbed_hwtcl_pipe  r+] ; puts -nonewline $f [string map {pcie_ed_sim_tb pcie_ss_ed_sim_tb} [read $f]][seek $f 0;list] ; close $f
                    set f [open $tbed_hwtcl_pipe  r+] ; puts -nonewline $f [string map {pcie_ed_sim_inst pcie_ss_ed_sim_inst} [read $f]][seek $f 0;list] ; close $f
                    set f [open $tbed_hwtcl_pipe  r+] ; puts -nonewline $f [string map {dut.dut.maib_and_tile.z1578a dut.dut.u_rtile.intel_pcie_rtile_ast_qhip.maib_and_tile.z1578a} [read $f]][seek $f 0;list] ; close $f
                    set g [open $tbed_hwtcl_altbfm  r+] ; puts -nonewline $g [string map {pcie_ed_sim_resetIP pcie_ss_ed_sim_resetIP} [read $g]][seek $g 0;list] ; close $g
                    set g [open $tbed_hwtcl_altbfm  r+] ; puts -nonewline $g [string map {pcie_ed_sim_tb pcie_ss_ed_sim_tb} [read $g]][seek $g 0;list] ; close $g
                    set g [open $tbed_hwtcl_altbfm  r+] ; puts -nonewline $g [string map {pcie_ed_sim_inst pcie_ss_ed_sim_inst} [read $g]][seek $g 0;list] ; close $g
                    set g [open $tbed_hwtcl_altbfm  r+] ; puts -nonewline $g [string map {dut.dut.maib_and_tile.z1578a dut.dut.u_rtile.intel_pcie_rtile_ast_qhip.maib_and_tile.z1578a} [read $g]][seek $g 0;list] ; close $g 
                } else {
                    set tbed_hwtcl_altbfm [searchFiles ${TEMPPATH}/ *altpcietb_bfm_rp_gen*.sv]
                    set g [open $tbed_hwtcl_altbfm  r+] ; puts -nonewline $g [string map {pcie_ed_sim_resetIP pcie_ss_ed_sim_resetIP} [read $g]][seek $g 0;list] ; close $g
                }
                
                if {[ip_get "parameter.core16_enable_sriov_hwtcl.value"] || [ip_get "parameter.core8_enable_sriov_hwtcl.value"] || [ip_get "parameter.core4_0_enable_sriov_hwtcl.value"] || [ip_get "parameter.core4_1_enable_sriov_hwtcl.value"]} {
                    set sriov_enable 1
                } else {
                    set sriov_enable 0
                }
                
                if {$sriov_enable  && [ip_get "parameter.TILE.value"] == "R-TILE"} {
                    set tbed_bfm [searchFiles ${TEMPPATH}/ *altpcietb_bfm_cfbp.v]
                    set f [open $tbed_bfm  r+] ; puts -nonewline $f [string map {pcie_ed_sim_tb.pcie_ed_sim_inst.dut.dut pcie_ss_ed_sim_tb.pcie_ss_ed_sim_inst.dut.dut.u_rtile.intel_pcie_rtile_ast_qhip} [read $f]][seek $f 0;list] ; close $f
                    set f [open $tbed_bfm  r+] ; puts -nonewline $f [string map {pcie_ed_sim_tb pcie_ss_ed_sim_tb} [read $f]][seek $f 0;list] ; close $f
                    set f [open $tbed_bfm  r+] ; puts -nonewline $f [string map {pcie_ed_sim_inst pcie_ss_ed_sim_inst} [read $f]][seek $f 0;list] ; close $f
                    set tbed_bfm_cfbp [searchFiles ${TEMPPATH}/ *altpcietb_bfm_rp_*_cfbp.sv]
                    set f [open $tbed_bfm_cfbp  r+] ; puts -nonewline $f [string map {pcie_ed_sim_tb pcie_ss_ed_sim_tb} [read $f]][seek $f 0;list] ; close $f
                    set f [open $tbed_bfm_cfbp  r+] ; puts -nonewline $f [string map {pcie_ed_sim_inst pcie_ss_ed_sim_inst} [read $f]][seek $f 0;list] ; close $f
                    set f [open $tbed_bfm_cfbp  r+] ; puts -nonewline $f [string map {pcie_ed_sim_resetIP pcie_ss_ed_sim_resetIP} [read $f]][seek $f 0;list] ; close $f
                }
        
                if {[ip_get "parameter.TILE.value"] == "F-TILE"} {
                    set tbed_hwtcl [searchFiles ${TEMPPATH}/ *intel_pcie_ftile_tbed_hwtcl.sv]
                    set f [open $tbed_hwtcl  r+] ; puts -nonewline $f [string map {pcie_ed_sim_auto_tiles pcie_ss_ed_sim_auto_tiles} [read $f]][seek $f 0;list] ; close $f
                    if {$pipemode_sim_for_ed_hwtcl} {
                        set f [open $tbed_hwtcl  r+] ; puts -nonewline $f [string map {pcie_ed_sim_tb pcie_ss_ed_sim_tb} [read $f]][seek $f 0;list] ; close $f
                        set f [open $tbed_hwtcl  r+] ; puts -nonewline $f [string map {pcie_ed_sim pcie_ss_ed_sim} [read $f]][seek $f 0;list] ; close $f
                    }

                    if {$sriov_enable ==0} {
                        set bfm [searchFiles ${TEMPPATH}/ *altpcietb_bfm_rp_gen4_x16.sv]
                        set f [open $bfm  r+] ; puts -nonewline $f [string map {pcie_ed_sim pcie_ss_ed_sim} [read $f]][seek $f 0;list] ; close $f
                    } else {
                        set bfm [searchFiles ${TEMPPATH}/ *altpcietb_bfm_rp_gen*_cfbp.sv]
                        set f [open $bfm  r+] ; puts -nonewline $f [string map {pcie_ed_sim_resetIP pcie_ss_ed_sim_resetIP} [read $f]][seek $f 0;list] ; close $f
                        set f [open $bfm  r+] ; puts -nonewline $f [string map {pcie_ed_sim pcie_ss_ed_sim} [read $f]][seek $f 0;list] ; close $f
                        set tbed_bfm [searchFiles ${TEMPPATH}/ *altpcietb_bfm_cfbp.v]
                        set f [open $tbed_bfm  r+] ; puts -nonewline $f [string map {pcie_ed_sim_tb pcie_ss_ed_sim_tb} [read $f]][seek $f 0;list] ; close $f
                        set f [open $tbed_bfm  r+] ; puts -nonewline $f [string map {pcie_ed_sim pcie_ss_ed_sim} [read $f]][seek $f 0;list] ; close $f
                        set f [open $tbed_bfm  r+] ; puts -nonewline $f [string map {pcie_ed_sim_tb.pcie_ed_sim.dut.dut pcie_ss_ed_sim_tb.pcie_ss_ed_sim.dut.dut.gen_ftile.gen_u_ftile.u_ftile.intel_pcie_ftile_ast_qhip} [read $f]][seek $f 0;list] ; close $f
                    }
                }
                
                if {[ip_get "parameter.TILE.value"] == "P-TILE"} {
                    if {$sriov_enable ==0} {
                        set bfm [searchFiles ${TEMPPATH}/ *altpcietb_bfm_rp_gen4_x16.sv]
                        set f [open $bfm  r+] ; puts -nonewline $f [string map {pcie_ed pcie_ss_ed_sim} [read $f]][seek $f 0;list] ; close $f
                        set f [open $bfm  r+] ; puts -nonewline $f [string map {dut.dut.inst.inst.maib_and_tile.z1565a dut.dut.gen_ptile.u_ptile.intel_pcie_ptile_ast_qhip.inst.inst.maib_and_tile.z1565a} [read $f]][seek $f 0;list] ; close $f
                    } else {
                        set bfm [searchFiles ${TEMPPATH}/ *altpcietb_bfm_rp_gen*_cfbp.sv]
                        set f [open $bfm  r+] ; puts -nonewline $f [string map {pcie_ed_resetIP pcie_ss_ed_sim_resetIP} [read $f]][seek $f 0;list] ; close $f
                        set f [open $bfm  r+] ; puts -nonewline $f [string map {pcie_ed pcie_ss_ed_sim} [read $f]][seek $f 0;list] ; close $f
                        set tbed_bfm [searchFiles ${TEMPPATH}/ *altpcietb_bfm_cfbp.v]
                        set f [open $tbed_bfm  r+] ; puts -nonewline $f [string map {pcie_ed_tb pcie_ss_ed_sim_tb} [read $f]][seek $f 0;list] ; close $f
                        set f [open $tbed_bfm  r+] ; puts -nonewline $f [string map {pcie_ed pcie_ss_ed_sim} [read $f]][seek $f 0;list] ; close $f
                        set f [open $bfm  r+] ; puts -nonewline $f [string map {dut.dut.inst.inst.maib_and_tile dut.dut.gen_ptile.u_ptile.intel_pcie_ptile_ast_qhip.inst.inst.maib_and_tile} [read $f]][seek $f 0;list] ; close $f
                        set f [open $tbed_bfm  r+] ; puts -nonewline $f [string map {pcie_ss_ed_sim_tb.pcie_ss_ed_sim_inst.dut.dut pcie_ss_ed_tb.pcie_ss_ed_inst.dut.dut.gen_ptile.u_ptile.intel_pcie_ptile_ast_qhip} [read $f]][seek $f 0;list] ; close $f
                    }
                }
            } else {
                set PassSimGeneration 0
                send_message error "Failed ${project_name}.qsys simulation generation"
                send_message info "Read $sim_msg_filename"
            }
        } else {
            send_message info "Not generating simulation testbench."
        }
        

        #--------------------------------------------------------------#
        # Generating synthesis

        set tile_name  [ip_get "parameter.TILE.value"] 
       
        if { $GenerateSynth > 0 && $PassSimGeneration > 0 || ($tile_name == "F-TILE" && $GenerateSimTb > 0 && $PassSimGeneration > 0)} {
            send_message info "Generating synthesis files..."
            send_message info "Running: qsys-generate ${project_name}.qsys ${qsys_gen_synth} --part=${DeviceQSF}"
            
            if {[ catch { exec ${QSYS_ROOTDIR}qsys-generate ${project_name}.qsys ${qsys_gen_synth} --part=${DeviceQSF}} msg ] && [ catch { exec ${QSYS_ROOTDIR}qsys-generate pcie_ss_ed_sim.qsys ${qsys_gen_synth} --part=${DeviceQSF}} msg ]} {
                set SYNTH_MSG [ open $synth_msg_filename "w" ]
                puts $SYNTH_MSG $msg
                close $SYNTH_MSG
            }
            
            if {[string match "*Error:*" $msg]} {
                send_message ERROR "Error when executing: ip-setup-simulation"
                send_message ERROR "Error message: $msg"
            }

            
            set QIPFILE "${project_name}/${project_name}.qip"

            if { [ file exist ${TEMPPATH}/${QIPFILE} ] == 1 } {
                send_message info "Passed ${project_name}.qsys synthesis generation"

                if {$tile_name == "F-TILE" } {
                    # ------ running quartus_tlg ------
                    # TODO: add full path for quartus_tlg executable
                    set QTLGLogPath "${TEMPPATH}/output_qtlg.log"

                    send_message info "Running QTLG: quartus_tlg ${project_name} --verbose --tiles=ftile_s20_v0__pcie__tile_0"
                    catch {cd $TEMPPATH}
                    set foo [catch "exec quartus_tlg ${project_name} --verbose --tiles=ftile_s20_v0__pcie__tile_0" msg]
                    set foo [catch "exec quartus_tlg pcie_ss_ed_sim --verbose --tiles=ftile_s20_v0__pcie__tile_0" msg]
                    catch {cd $TEMPPATH}

                    if {[string match "*Error:*" $msg]} {
                        send_message ERROR "Error when executing: quartus_tlg"
                        send_message ERROR "Error message: $msg"
                    }

                    set logFile [open $QTLGLogPath "w"]
                    puts $logFile $msg
                    close $logFile
                }

                if {[ip_get "parameter.TILE.value"] == "R-TILE" && [regexp "PERFORMANCE_DESIGN" $example_design_mode_hwtcl] } {
                    if {[regexp "Gen5 1x16" $top_topology_hwtcl]} {
                        set perf_crdt [searchFiles ${TEMPPATH}/ip/pcie_ss_ed_sim/ *synth/perf_gen5_ed_bam_crdt_intf.sv]
                        set f [open $perf_crdt  r+] ; puts -nonewline $f [string map {85*5 \(85*5\)+470} [read $f]][seek $f 0;list] ; close $f
                        set f [open $perf_crdt  r+] ; puts -nonewline $f [string map {11*5 \(11*5\)+500} [read $f]][seek $f 0;list] ; close $f
                        set f [open $perf_crdt  r+] ; puts -nonewline $f [string map {10*5 \(10*5\)+500} [read $f]][seek $f 0;list] ; close $f
                        
                        set perf_crdt1 [searchFiles ${TEMPPATH}/ip/pcie_ss_ed/ *synth/perf_gen5_ed_bam_crdt_intf.sv]
                        set f [open $perf_crdt1  r+] ; puts -nonewline $f [string map {85*5 \(85*5\)+470} [read $f]][seek $f 0;list] ; close $f
                        set f [open $perf_crdt1  r+] ; puts -nonewline $f [string map {11*5 \(11*5\)+500} [read $f]][seek $f 0;list] ; close $f
                        set f [open $perf_crdt1  r+] ; puts -nonewline $f [string map {10*5 \(10*5\)+500} [read $f]][seek $f 0;list] ; close $f
                    } 
                    # if {[regexp "1x16" $top_topology_hwtcl] && ($dwidth_byte == 32 || $dwidth_byte == 64)} {
                    #     set perf_top [searchFiles ${TEMPPATH}/ *synth/perf_gen5_ed_top.sv]
                    #     set f [open $perf_top r]
                    #     if { $f != -1 } {
                    #         set content [read $f]
                    #         set replacement [list "NUM_SEG = 4" "NUM_SEG = 2" "p0_rx_st3_sop_i,p0_rx_st2_sop_i," "" "p0_rx_st3_eop_i,p0_rx_st2_eop_i," "" "p0_rx_st3_data_i,p0_rx_st2_data_i," "" \
                    #                                "p0_rx_st3_hdr_i,p0_rx_st2_hdr_i," "" "p0_rx_st3_dvalid_i,p0_rx_st2_dvalid_i," "" "p0_rx_st3_bar_i,p0_rx_st2_bar_i," "" "p0_rx_st3_prefix_i,p0_rx_st2_prefix_i," "" \
                    #                                "p0_rx_st3_hvalid_i,p0_rx_st2_hvalid_i," "" "p0_rx_st3_pvalid_i,p0_rx_st2_pvalid_i," "" "p0_tx_st3_sop_o,p0_tx_st2_sop_o," "" "p0_tx_st3_eop_o,p0_tx_st2_eop_o," "" \
                    #                                "p0_tx_st3_data_o,p0_tx_st2_data_o," "" "p0_tx_st3_hdr_o,p0_tx_st2_hdr_o," "" "p0_tx_st3_dvalid_o,p0_tx_st2_dvalid_o," "" "p0_tx_st3_prefix_o,p0_tx_st2_prefix_o," "" \
                    #                                "p0_tx_st3_hvalid_o,p0_tx_st2_hvalid_o," "" "p0_tx_st3_pvalid_o,p0_tx_st2_pvalid_o," ""]
                    #         set modified_content [string map {-nocase} $replacement $content] 
                    #         close $f
                    #         file delete -force -- $perf_top
                    #         set f1 [open $perf_top w]
                    #         seek $f1 0
                    #         puts $f1 $modified_content
                    #         close $f1

                    #     } else {
                    #         send_message info "Error opening ed top file"
                    #     }
                    # }
                } 

            } else {
                set PassSynthGeneration 0
                send_message error "Fail ${project_name}.qsys synthesis generation"
                send_message info "Read $synth_msg_filename"
            }
        } else {
            send_message info "Not generating synthesis testbench."
        }

        # Instantiate RP        
        if { $GenerateSimTb > 0 && ($tile_name== "R-TILE" || $tile_name == "F-TILE")} {
            if {$tile_name == "F-TILE"} {

                # ------ runnin ip-mak-simscript to compile all filelists ------
                # write tile_wrapper.spd
                if { $GenerateSimTb > 0 } {	
                    set TileWrapperSPD "${TEMPPATH}/tile_wrapper.spd"
                    set SPDFile [open $TileWrapperSPD "w"]
                    puts $SPDFile "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
                    puts $SPDFile "<simPackage>"
                    #puts $SPDFile "<file path=\"${project_name}_auto_tiles.v\" type=\"VERILOG\" />"
                    puts $SPDFile "<file path=\"pcie_ed_rp/support_logic/pcie_auto_tiles.sv\" library=\"pcie_top\" type=\"VERILOG\" />"
                    puts $SPDFile "<file path=\"pcie_ed_rp/pcie_top/sim/pcie_top.v\" library=\"pcie_top\" type=\"VERILOG\" />"
                    puts $SPDFile "<file path=\"pcie_ed_rp/ip/pcie_top/pcie/sim/pcie.v\" library=\"pcie_auto_tiles\" type=\"VERILOG\" />"
                    puts $SPDFile "</simPackage>"
                    close $SPDFile
                }
            
                # jkoe - Post Processing
                # Connect refclk from TB to Sys PLL during TB generation
                set pcie_ss_ed_sim_tb_path "${ORI_TEMP_PATH}/pcie_ss_ed_sim_tb/pcie_ss_ed_sim_tb/sim/"

                file copy -force "${pcie_ss_ed_sim_tb_path}/pcie_ss_ed_sim_tb.v" "${pcie_ss_ed_sim_tb_path}/pcie_ss_ed_sim_tb.v.ori"
                #set pipemode_sim_ed_hwtcl   [ip_get "parameter.pipemode_sim_ed_hwtcl.value"]
                set end_flag 0
                set pcie_ss_ed_sim_tb_rd [open $pcie_ss_ed_sim_tb_path/pcie_ss_ed_sim_tb.v.ori "r"]
                set pcie_ss_ed_sim_tb_wr [open $pcie_ss_ed_sim_tb_path/pcie_ss_ed_sim_tb.v "w"]
	    
                set pcie_ss_ed_sim_tb_content [split [read $pcie_ss_ed_sim_tb_rd] "\n"]
                regsub -all {dut_pcie_tb_ip dut_pcie_tb} $pcie_ss_ed_sim_tb_content {dut_pcie_tb_ip dut_pcie_tb_ip} pcie_ss_ed_sim_tb_content
                regsub -all {pcie_ss_ed_sim pcie_ss_ed_sim_inst} $pcie_ss_ed_sim_tb_content {pcie_ss_ed_sim pcie_ss_ed_sim} pcie_ss_ed_sim_tb_content
                foreach line $pcie_ss_ed_sim_tb_content {
                    if {[regexp "pcie_ss_ed_sim_inst_refclk" $line]} {
                        # add new wire declaration
                        if {[regexp "wire" $line]} {
                            puts $pcie_ss_ed_sim_tb_wr "\/\/$line"
                            if {[regexp "refclk0" $line]} {
                                puts $pcie_ss_ed_sim_tb_wr "	wire   \[0:0\] pcie_ed_sim_inst_in_refclk_fgt_3; \/\/ pcie_ed_sim_inst_refclk_fgt_bfm:sig_in_refclk_fgt_5 -> pcie_ed_sim_inst:refclk_fgt_in_refclk_fgt_5"
                            } elseif {[regexp "refclk1" $line] } {
                                puts $pcie_ss_ed_sim_tb_wr "	wire   \[0:0\] pcie_ed_sim_inst_in_refclk_fgt_5; \/\/ pcie_ed_sim_inst_refclk_fgt_bfm:sig_in_refclk_fgt_3 -> pcie_ed_sim_inst:refclk_fgt_in_refclk_fgt_3"
                            }
                            # comment out the proc
                        } elseif {[regexp {\.sig_clk} $line] } {
                            set end_flag 1
                            puts $pcie_ss_ed_sim_tb_wr "\/\/$line"
                            # link to new wire declared
                        } elseif {[regexp {\.refclk0} $line]} {
                            regsub -all {pcie_ss_ed_sim_inst_refclk0_bfm_conduit_clk} $line {pcie_ed_sim_inst_in_refclk_fgt_3} line
                            puts $pcie_ss_ed_sim_tb_wr "$line"
                        } elseif {[regexp {\.refclk1} $line]} {
                            regsub -all {pcie_ss_ed_sim_inst_refclk1_bfm_conduit_clk} $line {pcie_ed_sim_inst_in_refclk_fgt_5} line
                            puts $pcie_ss_ed_sim_tb_wr "$line"
                        } else {
                            puts $pcie_ss_ed_sim_tb_wr "\/\/$line"
                        }
                        # comment out the proc
                    } elseif {[regexp "\\);" $line] && $end_flag == 1 } {
                        puts $pcie_ss_ed_sim_tb_wr "\/\/$line"
                        set end_flag 0 
                        # link to new wire declared
                    } elseif {[regexp "\.refclk0" $line]} {
                        regsub -all {\(\)} $line {(pcie_ed_sim_inst_in_refclk_fgt_3)} line
                        puts $pcie_ss_ed_sim_tb_wr "$line"
                    } elseif {[regexp "\.refclk1" $line]} {
                        regsub -all {\(\)} $line {(pcie_ed_sim_inst_in_refclk_fgt_5)} line
                        puts $pcie_ss_ed_sim_tb_wr "$line"
                    } else {
                        puts $pcie_ss_ed_sim_tb_wr "$line"
                    }

                }

                close $pcie_ss_ed_sim_tb_wr
                close $pcie_ss_ed_sim_tb_rd
                file delete -force -- "${pcie_ss_ed_sim_tb_path}/pcie_ss_ed_sim_tb.v.ori"
                  set pipemode_sim_for_ed_hwtcl   [ip_get "parameter.pipemode_sim_for_ed_hwtcl.value"]
                 if {$pipemode_sim_for_ed_hwtcl} {
                 	# Post Processing for PIPEMODE TB 
                 	
                 	set pcie_ed_sim_tb_path "${ORI_TEMP_PATH}/pcie_ss_ed_sim_tb/pcie_ss_ed_sim_tb/sim/"
                  file copy -force "${pcie_ed_sim_tb_path}/pcie_ss_ed_sim_tb.v" "${pcie_ed_sim_tb_path}/pcie_ss_ed_sim_tb.v.ori"
                 	set end_flag 0
                 	set counter 0
                 	set pcie_ed_sim_tb_rd [open $pcie_ed_sim_tb_path/pcie_ss_ed_sim_tb.v.ori "r"]
                 	set pcie_ed_sim_tb_wr [open $pcie_ed_sim_tb_path/pcie_ss_ed_sim_tb.v "w"]
                 	set pcie_ed_sim_tb_content [split [read $pcie_ed_sim_tb_rd] "\n"]
                 	foreach line $pcie_ed_sim_tb_content {
                 	  if {[regexp "pcie_ss_ed_sim_inst_i_pclk_x16_l0_bfm_ip pcie_ss_ed_sim_inst_i_pclk_x16_l0_bfm" $line] } {
                 		puts $pcie_ed_sim_tb_wr "\/\/$line"
                 		incr counter
                 		set end_flag 1
                 	  } elseif { $end_flag == 1 && $counter < 15} {
                 	    puts $pcie_ed_sim_tb_wr "\/\/$line"
                 	    incr counter
                    	  } elseif {[regexp "endmodule" $line]} {
			                   puts $pcie_ed_sim_tb_wr   "assign pcie_ss_ed_sim_inst_i_pclk_x4_l4_bfm_clk_clk = dut_pcie_tb_ip.dut_pcie_tb.i_pclk_x4_l4;"
                         puts $pcie_ed_sim_tb_wr   "assign pcie_ss_ed_sim_inst_i_pclk_x4_l12_bfm_clk_clk = dut_pcie_tb_ip.dut_pcie_tb.i_pclk_x4_l12;"
                         puts $pcie_ed_sim_tb_wr   "assign pcie_ss_ed_sim_inst_i_pclk_x8_l8_bfm_clk_clk = dut_pcie_tb_ip.dut_pcie_tb.i_pclk_x8_l8;"
                         puts $pcie_ed_sim_tb_wr   "assign pcie_ss_ed_sim_inst_i_pclk_x16_l0_bfm_clk_clk = dut_pcie_tb_ip.dut_pcie_tb.i_pclk_x16_l0;"
                         puts $pcie_ed_sim_tb_wr   "endmodule"  	      
                 	  } else {puts $pcie_ed_sim_tb_wr "$line"}
                     }
                 	close $pcie_ed_sim_tb_wr
                 	close $pcie_ed_sim_tb_rd
                 	file delete -force -- "${pcie_ed_sim_tb_path}/pcie_ss_ed_sim_tb.v.ori"
                 # set tb_top "${ORI_TEMP_PATH}/pcie_ss_ed_tb/pcie_ss_ed_tb/sim/pcie_ss_ed_tb.v"
                  #set f [open $tb_top  r+] ; puts -nonewline $f [string map {pcie_ss_ed_inst_i_pclk_x16_l0_bfm_ip \/\*pcie_ss_ed_inst_i_pclk_x16_l0_bfm_ip } [read $f]][seek $f 0;list] ; close $f
                  #set f [open $tb_top  r+] ; puts -nonewline $f [string map {pcie_ss_ed\spcie_ss_ed  \*\/pcie_ss_ed\spcie_ss_ed } [read $f]][seek $f 0;list] ; close $f
									
				       	}					
            }

            ::intel_pcie_ss_axi::pcie_syspll_ed $ORI_TEMP_PATH

            set enable_multi_func_hwtcl                 [ip_get "parameter.core16_enable_multi_func_hwtcl.value"]

            if {$tile_name == "F-TILE"} {
                set pcie_auto_tiles_path "${ORI_TEMP_PATH}/pcie_ed_rp/support_logic/"
                file copy -force "${ORI_TEMP_PATH}/pcie_ed_rp/support_logic/pcie_auto_tiles.sv" "${ORI_TEMP_PATH}/pcie_ed_rp/support_logic/pcie_auto_tiles.sv.ori"

                set pcie_auto_tiles_rd [open $pcie_auto_tiles_path/pcie_auto_tiles.sv.ori "r"]
                set pcie_auto_tiles_wr [open $pcie_auto_tiles_path/pcie_auto_tiles.sv "w"]
                set pcie_auto_tiles_content [read $pcie_auto_tiles_rd]

                regsub -all {define QUARTUS_TLG__TOP_LEVEL_ENTITY_INSTANCE_PATH pcie_top} $pcie_auto_tiles_content {define QUARTUS_TLG__TOP_LEVEL_ENTITY_INSTANCE_PATH dut_pcie_tb_ip.dut_pcie_tb.g_bfm.p_dut_ep.altpcietb_bfm_top_rp.g_bfm.u1.rp.inst.dut} pcie_auto_tiles_content
                #regsub -all {ftile_s20_v0__pcie__tile_0} $pcie_auto_tiles_content {ftile_s20_v0__pcie__tile_rp_0} pcie_auto_tiles_content
                #regsub -all {QUARTUS_TLG__TOP_LEVEL_ENTITY_INSTANCE_PATH} $pcie_auto_tiles_content {QUARTUS_TLG__TOP_LEVEL_ENTITY_INSTANCE_PATH_RP} pcie_auto_tiles_content
                puts $pcie_auto_tiles_wr $pcie_auto_tiles_content
                close $pcie_auto_tiles_wr
                close $pcie_auto_tiles_rd
            }
            #delete qsf file inside rp folder to get hammer qtlg pass
            #regtest Error if not delete: ITF: qtlg: helper_488: 0: More than 1 QSF file was found in pcie_1x16a_ed_max_gen3_ed_example_design! Please specify the correct project name in flow.txt (project = <project>) so that the correct QSF file can be selected.
            file copy -force "${ORI_TEMP_PATH}/pcie_ed_rp/pcie.qsf" "${ORI_TEMP_PATH}/pcie_ed_rp/pcie.qsf.ori"
            file copy -force "${ORI_TEMP_PATH}/pcie_ed_rp/pcie.qpf" "${ORI_TEMP_PATH}/pcie_ed_rp/pcie.qpf.ori"
            file delete -force -- "${ORI_TEMP_PATH}/pcie_ed_rp/pcie.qsf"
            file delete -force -- "${ORI_TEMP_PATH}/pcie_ed_rp/pcie.qpf"

            if {$tile_name == "F-TILE"} {
                # workarond for AGFB022R24C2E1V ed simulation error

                set mif_path "${ORI_TEMP_PATH}/pcie_ed_rp/support_logic/"
                set rp_generated_file_names [searchFiles ${mif_path}  *mif]
                send_message info "rp_generated_file_names ${rp_generated_file_names} "
                regexp {pcie__(.*).mif} [lindex $rp_generated_file_names 0] matched sub1
                variable rp_generated_name
                set rp_generated_name $sub1
                send_message info "rp_generated_name ${rp_generated_name} "
                puts $SPDFile "<file path=\"../pcie_ed_rp/support_logic/pcie__${rp_generated_name}.mif\" type=\"MIF\"/>"

                if { ! [regexp "ftile_s20_v0__pcie__tile_0" $rp_generated_name ]} {
                    if { $enable_multi_func_hwtcl == 0 } {
                        set altpcietb_bfm_rp_gen4_x16_path "${ORI_TEMP_PATH}/pcie_ss_ed_sim_tb/ip/pcie_ss_ed_sim_tb/dut_pcie_tb_ip/intel_pcie_ftile_tbed_100/sim"
                        file copy -force "${ORI_TEMP_PATH}/pcie_ss_ed_sim_tb/ip/pcie_ss_ed_sim_tb/dut_pcie_tb_ip/intel_pcie_ftile_tbed_100/sim/altpcietb_bfm_rp_gen4_x16.sv" "${ORI_TEMP_PATH}/pcie_ss_ed_sim_tb/ip/pcie_ss_ed_sim_tb/dut_pcie_tb_ip/intel_pcie_ftile_tbed_100/sim/altpcietb_bfm_rp_gen4_x16.sv.ori"

                        set altpcietb_bfm_rp_gen4_x16_rd [open $altpcietb_bfm_rp_gen4_x16_path/altpcietb_bfm_rp_gen4_x16.sv.ori "r"]
                        set altpcietb_bfm_rp_gen4_x16_wr [open $altpcietb_bfm_rp_gen4_x16_path/altpcietb_bfm_rp_gen4_x16.sv "w"]
                        set altpcietb_bfm_rp_gen4_x16_content [read $altpcietb_bfm_rp_gen4_x16_rd]

                        regsub -all {tile_bfm\.ftile_s20_v0__pcie__tile_0} $altpcietb_bfm_rp_gen4_x16_content "tile_bfm\.${rp_generated_name}" altpcietb_bfm_rp_gen4_x16_content
                        puts $altpcietb_bfm_rp_gen4_x16_wr $altpcietb_bfm_rp_gen4_x16_content
                        close $altpcietb_bfm_rp_gen4_x16_wr
                        close $altpcietb_bfm_rp_gen4_x16_rd
                    } else {
                        set altpcietb_bfm_rp_gen4_x16_cfbp_path "${ORI_TEMP_PATH}/pcie_ss_ed_sim_tb/ip/pcie_ss_ed_sim_tb/dut_pcie_tb_ip/intel_pcie_ftile_tbed_100/sim"
                        file copy -force "${ORI_TEMP_PATH}/pcie_ss_ed_sim_tb/ip/pcie_ss_ed_sim_tb/dut_pcie_tb_ip/intel_pcie_ftile_tbed_100/sim/altpcietb_bfm_rp_gen4_x16_cfbp.sv" "${ORI_TEMP_PATH}/pcie_ss_ed_sim_tb/ip/pcie_ss_ed_sim_tb/dut_pcie_tb_ip/intel_pcie_ftile_tbed_100/sim/altpcietb_bfm_rp_gen4_x16_cfbp.sv.ori"

                        set altpcietb_bfm_rp_gen4_x16_cfbp_rd [open $altpcietb_bfm_rp_gen4_x16_cfbp_path/altpcietb_bfm_rp_gen4_x16_cfbp.sv.ori "r"]
                        set altpcietb_bfm_rp_gen4_x16_cfbp_wr [open $altpcietb_bfm_rp_gen4_x16_cfbp_path/altpcietb_bfm_rp_gen4_x16_cfbp.sv "w"]
                        set altpcietb_bfm_rp_gen4_x16_cfbp_content [read $altpcietb_bfm_rp_gen4_x16_cfbp_rd]

                        regsub -all {tile_bfm\.ftile_s20_v0__pcie__tile_0} $altpcietb_bfm_rp_gen4_x16_cfbp_content "tile_bfm\.${rp_generated_name}" altpcietb_bfm_rp_gen4_x16_cfbp_content
                        puts $altpcietb_bfm_rp_gen4_x16_cfbp_wr $altpcietb_bfm_rp_gen4_x16_cfbp_content
                        close $altpcietb_bfm_rp_gen4_x16_cfbp_wr
                        close $altpcietb_bfm_rp_gen4_x16_cfbp_rd
                    }
                }

                set generated_file_names [searchFiles ${TEMPPATH}/support_logic/   pcie_ss_ed_sim*mif]
                regexp {pcie_ss_ed_sim__(.*).mif} [lindex $generated_file_names 0] matched sub1
                variable generated_name
                # set generated_name "ftile_s20_v0__pcie__tile_0"
                set generated_name $sub1

                send_message info "generated_name2 $sub1"
                send_message info "generated_name3 $generated_name"

                if { ! [regexp "ftile_s20_v0__pcie__tile_0" $generated_name ]} {
                    if { $enable_multi_func_hwtcl == 0 } {
                        set altpcietb_bfm_rp_gen4_x16_path "${ORI_TEMP_PATH}/pcie_ss_ed_sim_tb/ip/pcie_ss_ed_sim_tb/dut_pcie_tb_ip/intel_pcie_ftile_tbed_100/sim"
                        file copy -force "${ORI_TEMP_PATH}/pcie_ss_ed_sim_tb/ip/pcie_ss_ed_sim_tb/dut_pcie_tb_ip/intel_pcie_ftile_tbed_100/sim/altpcietb_bfm_rp_gen4_x16.sv" "${ORI_TEMP_PATH}/pcie_ss_ed_sim_tb/ip/pcie_ss_ed_sim_tb/dut_pcie_tb_ip/intel_pcie_ftile_tbed_100/sim/altpcietb_bfm_rp_gen4_x16.sv.ori"

                        set altpcietb_bfm_rp_gen4_x16_rd [open $altpcietb_bfm_rp_gen4_x16_path/altpcietb_bfm_rp_gen4_x16.sv.ori "r"]
                        set altpcietb_bfm_rp_gen4_x16_wr [open $altpcietb_bfm_rp_gen4_x16_path/altpcietb_bfm_rp_gen4_x16.sv "w"]
                        set altpcietb_bfm_rp_gen4_x16_content [read $altpcietb_bfm_rp_gen4_x16_rd]

                        regsub -all "dut_pcie_tb\.tile\.ftile_s20_v0__pcie__tile_0" $altpcietb_bfm_rp_gen4_x16_content "dut_pcie_tb\.tile\.${generated_name}" altpcietb_bfm_rp_gen4_x16_content
                        puts $altpcietb_bfm_rp_gen4_x16_wr $altpcietb_bfm_rp_gen4_x16_content
                        close $altpcietb_bfm_rp_gen4_x16_wr
                        close $altpcietb_bfm_rp_gen4_x16_rd

                    } else {
                        set altpcietb_bfm_rp_gen4_x16_cfbp_path "${ORI_TEMP_PATH}/pcie_ss_ed_sim_tb/ip/pcie_ss_ed_sim_tb/dut_pcie_tb_ip/intel_pcie_ftile_tbed_100/sim"
                        file copy -force "${ORI_TEMP_PATH}/pcie_ss_ed_sim_tb/ip/pcie_ss_ed_sim_tb/dut_pcie_tb_ip/intel_pcie_ftile_tbed_100/sim/altpcietb_bfm_rp_gen4_x16_cfbp.sv" "${ORI_TEMP_PATH}/pcie_ss_ed_sim_tb/ip/pcie_ss_ed_sim_tb/dut_pcie_tb_ip/intel_pcie_ftile_tbed_100/sim/altpcietb_bfm_rp_gen4_x16_cfbp.sv.ori"
                        set altpcietb_bfm_rp_gen4_x16_cfbp_rd [open $altpcietb_bfm_rp_gen4_x16_cfbp_path/altpcietb_bfm_rp_gen4_x16_cfbp.sv.ori "r"]
                        set altpcietb_bfm_rp_gen4_x16_cfbp_wr [open $altpcietb_bfm_rp_gen4_x16_cfbp_path/altpcietb_bfm_rp_gen4_x16_cfbp.sv "w"]
                        set altpcietb_bfm_rp_gen4_x16_cfbp_content [read $altpcietb_bfm_rp_gen4_x16_cfbp_rd]

                        regsub -all "dut_pcie_tb\.tile\.ftile_s20_v0__pcie__tile_0" $altpcietb_bfm_rp_gen4_x16_cfbp_content "dut_pcie_tb\.tile\.${generated_name}" altpcietb_bfm_rp_gen4_x16_cfbp_content
                        puts $altpcietb_bfm_rp_gen4_x16_cfbp_wr $altpcietb_bfm_rp_gen4_x16_cfbp_content
                        close $altpcietb_bfm_rp_gen4_x16_cfbp_wr
                        close $altpcietb_bfm_rp_gen4_x16_cfbp_rd
                    }
                }
            }
        }

        #--------------------------------------------------------------#
        # Generating pin assignments
        
        if { $PassSimGeneration > 0 && $PassSynthGeneration > 0 } {
            # Generate the pinout tcl based on parameters
            ::intel_pcie_ss_axi::s10_pcie_devkit_pinout ${project_name} ${s10_devkit_tcl} ${TEMPPATH}
            if {[ file exist ${TEMPPATH}/${s10_devkit_tcl} ] == 1} {
                # Pinout tcl file was generated properly

                # Now create a file to open project and run the pinout tcl
                set QUARTUSFILE "${project_name}_quartusfile.tcl"
                set quartus_file [open $QUARTUSFILE "w"]
                puts $quartus_file "project_open $project_name"
                puts $quartus_file "source $s10_devkit_tcl"
                puts $quartus_file "set_global_assignment -name SDC_FILE pcie_ss_ed.sdc"
                
                if { $GenerateSimTb > 0 } {
                # Now create a file to open project and run the pinout tcl
                set SIM_QUARTUSFILE "pcie_ss_ed_sim_quartusfile.tcl"
                set sim_quartus_file [open $SIM_QUARTUSFILE "w"]
                puts $sim_quartus_file "project_open pcie_ss_ed_sim"
                puts $sim_quartus_file "set_global_assignment -name SDC_FILE pcie_ss_ed.sdc"
                
                    set spd_fileList [searchFiles ${TEMPPATH}/  *.spd]
                    set tb_spd_fileList ""	
                    foreach spd $spd_fileList {
                        if {[regexp "pcie_ss_ed_sim_tb" $spd]} {
                            lappend tb_spd_fileList $spd 
                        } else {
                            regsub -all "${TEMPPATH}" $spd {./} spd                          
                            puts $sim_quartus_file "set_global_assignment -name SPD_FILE $spd"
                        }
                    }
                    foreach spd $tb_spd_fileList {
                        if { $spd != ""} {
                            regsub -all "${TEMPPATH}" $spd {./}  spd                          
                            puts $sim_quartus_file "set_global_assignment -name SPD_FILE $spd"
                        }
                    }
                    puts $sim_quartus_file "set_global_assignment -name SPD_FILE ./pcie_ss_ed_sim_tb/pcie_ss_ed_sim_tb/pcie_ss_ed_tb.spd"
                    
                    #HSD: 14022985966
                    if {$tile_name == "F-TILE"} {
                        puts $sim_quartus_file "set_global_assignment -name EDA_EXDES_CUSTOM_SIM_SCRIPT_VCS ./pcie_ss_ed_sim_tb/pcie_ss_ed_sim_tb/sim/synopsys/vcs/run_vcs.sh -section_id eda_simulation"
                        puts $sim_quartus_file "set_global_assignment -name EDA_EXDES_CUSTOM_SIM_SCRIPT_VCSMX ./pcie_ss_ed_sim_tb/pcie_ss_ed_sim_tb/sim/synopsys/vcsmx/run_vcsmx.sh -section_id eda_simulation"
                        puts $sim_quartus_file "set_global_assignment -name EDA_EXDES_CUSTOM_SIM_SCRIPT_XCELIUM ./pcie_ss_ed_sim_tb/pcie_ss_ed_sim_tb/sim/xcelium/run_xcelium.sh -section_id eda_simulation"
                        puts $sim_quartus_file "set_global_assignment -name EDA_EXDES_CUSTOM_SIM_SCRIPT_QUESTA ./pcie_ss_ed_sim_tb/pcie_ss_ed_sim_tb/sim/mentor/run_msim.tcl -section_id eda_simulation"
                        puts $sim_quartus_file "set_global_assignment -name EDA_EXDES_CUSTOM_SIM_SCRIPT_RIVIERAPRO ./pcie_ss_ed_sim_tb/pcie_ss_ed_sim_tb/sim/aldec/run_riviera.tcl -section_id eda_simulation"
                        puts $sim_quartus_file ""
                    } elseif {$tile_name == "R-TILE"} {
                        puts $sim_quartus_file "set_global_assignment -name EDA_EXDES_CUSTOM_SIM_SCRIPT_VCS ./pcie_ss_ed_sim_tb/pcie_ss_ed_sim_tb/sim/synopsys/vcs/run_vcs.sh -section_id eda_simulation"
                        puts $sim_quartus_file "set_global_assignment -name EDA_EXDES_CUSTOM_SIM_SCRIPT_VCSMX ./pcie_ss_ed_sim_tb/pcie_ss_ed_sim_tb/sim/synopsys/vcsmx/run_vcsmx.sh -section_id eda_simulation"
                        puts $sim_quartus_file "set_global_assignment -name EDA_EXDES_CUSTOM_SIM_SCRIPT_XCELIUM ./pcie_ss_ed_sim_tb/pcie_ss_ed_sim_tb/sim/xcelium/run_xcelium.sh -section_id eda_simulation"
                        puts $sim_quartus_file "set_global_assignment -name EDA_EXDES_CUSTOM_SIM_SCRIPT_QUESTA ./pcie_ss_ed_sim_tb/pcie_ss_ed_sim_tb/sim/mentor/run_msim.tcl -section_id eda_simulation"
                        puts $sim_quartus_file "set_global_assignment -name EDA_EXDES_CUSTOM_SIM_SCRIPT_RIVIERAPRO ./pcie_ss_ed_sim_tb/pcie_ss_ed_sim_tb/sim/aldec/run_riviera.tcl -section_id eda_simulation"
                    } else { 
                        #P-Tile
                        puts $sim_quartus_file "set_global_assignment -name EDA_EXDES_CUSTOM_SIM_SCRIPT_VCS ./pcie_ss_ed_sim_tb/pcie_ss_ed_sim_tb/sim/synopsys/vcs/run_vcs.sh -section_id eda_simulation"
                        puts $sim_quartus_file "set_global_assignment -name EDA_EXDES_CUSTOM_SIM_SCRIPT_VCSMX ./pcie_ss_ed_sim_tb/pcie_ss_ed_sim_tb/sim/synopsys/vcsmx/run_vcsmx.sh -section_id eda_simulation"
                        puts $sim_quartus_file "set_global_assignment -name EDA_EXDES_CUSTOM_SIM_SCRIPT_QUESTA ./pcie_ss_ed_sim_tb/pcie_ss_ed_sim_tb/sim/mentor/run_msim.tcl -section_id eda_simulation"
                        puts $sim_quartus_file "set_global_assignment -name EDA_EXDES_CUSTOM_SIM_SCRIPT_RIVIERAPRO ./pcie_ss_ed_sim_tb/pcie_ss_ed_sim_tb/sim/aldec/run_riviera.tcl -section_id eda_simulation"
                    }
                    
                    puts $sim_quartus_file "project_close"
                    close $sim_quartus_file
                    
                    if {[catch "exec quartus_sh -t ${SIM_QUARTUSFILE}" msg] } {
                        send_message info "Successfully generated : pcie_ss_ed_sim.qpf, pcie_ss_ed_sim.qsf"
                    }
                    
                    #HSD:15016743369
                    if {$tile_name == "F-TILE"} {
                        set ed_tb_path_vcs      "${TEMPPATH}/pcie_ss_ed_sim_tb/pcie_ss_ed_sim_tb/sim/synopsys/vcs"
                        set ed_tb_path_vcsmx    "${TEMPPATH}/pcie_ss_ed_sim_tb/pcie_ss_ed_sim_tb/sim/synopsys/vcsmx"
                        set ed_tb_patth_xcelium "${TEMPPATH}/pcie_ss_ed_sim_tb/pcie_ss_ed_sim_tb/sim/xcelium"
                        set ed_tb_path_msim     "${TEMPPATH}/pcie_ss_ed_sim_tb/pcie_ss_ed_sim_tb/sim/mentor"
                        set ed_tb_path_aldec    "${TEMPPATH}/pcie_ss_ed_sim_tb/pcie_ss_ed_sim_tb/sim/aldec"
                        set pipemode_sim_for_ed_hwtcl                      [ip_get "parameter.pipemode_sim_for_ed_hwtcl.value"]
                        
                        if {$pipemode_sim_for_ed_hwtcl} {
                            if { [ file exist $ed_tb_path_vcs ] == 1 } {
                                file copy -force "${IP_ROOTDIR}/altera/subsystems/intel_pcie_ss_axi/ed/sim_scripts/ftile/run_vcs.sh" "${ed_tb_path_vcs}/run_vcs.sh"
                            }
                            if { [ file exist $ed_tb_path_vcsmx ] == 1 } {
                                file copy -force "${IP_ROOTDIR}/altera/subsystems/intel_pcie_ss_axi/ed/sim_scripts/ftile/run_vcsmx.sh" "${ed_tb_path_vcsmx}/run_vcsmx.sh"
                            }
                            if { [ file exist $ed_tb_patth_xcelium ] == 1 } {
                                file copy -force "${IP_ROOTDIR}/altera/subsystems/intel_pcie_ss_axi/ed/sim_scripts/ftile/run_xcelium.sh" "${ed_tb_patth_xcelium}/run_xcelium.sh"
                            }
                            if { [ file exist $ed_tb_path_msim ] == 1 } {
                                file copy -force "${IP_ROOTDIR}/altera/subsystems/intel_pcie_ss_axi/ed/sim_scripts/ftile/run_msim.tcl" "${ed_tb_path_msim}/run_msim.tcl"
                            }
                            if { [ file exist $ed_tb_path_aldec ] == 1 } {
                                file copy -force "${IP_ROOTDIR}/altera/subsystems/intel_pcie_ss_axi/ed/sim_scripts/ftile/run_riviera.tcl" "${ed_tb_path_aldec}/run_riviera.tcl"
                            }
                        } else {
                            if { [ file exist $ed_tb_path_vcs ] == 1 } {
                                file copy -force "${IP_ROOTDIR}/altera/subsystems/intel_pcie_ss_axi/ed/sim_scripts/ftile/run_vcs_no_pipemode.sh" "${ed_tb_path_vcs}/run_vcs.sh"
                            }
                            if { [ file exist $ed_tb_path_vcsmx ] == 1 } {
                                file copy -force "${IP_ROOTDIR}/altera/subsystems/intel_pcie_ss_axi/ed/sim_scripts/ftile/run_vcsmx_no_pipemode.sh" "${ed_tb_path_vcsmx}/run_vcsmx.sh"
                            }
                            if { [ file exist $ed_tb_patth_xcelium ] == 1 } {
                                file copy -force "${IP_ROOTDIR}/altera/subsystems/intel_pcie_ss_axi/ed/sim_scripts/ftile/run_xcelium_no_pipemode.sh" "${ed_tb_patth_xcelium}/run_xcelium.sh"
                            }
                            if { [ file exist $ed_tb_path_msim ] == 1 } {
                                file copy -force "${IP_ROOTDIR}/altera/subsystems/intel_pcie_ss_axi/ed/sim_scripts/ftile/run_msim_no_pipemode.tcl" "${ed_tb_path_msim}/run_msim.tcl"
                            }
                            if { [ file exist $ed_tb_path_aldec ] == 1 } {
                                file copy -force "${IP_ROOTDIR}/altera/subsystems/intel_pcie_ss_axi/ed/sim_scripts/ftile/run_riviera_no_pipemode.tcl" "${ed_tb_path_aldec}/run_riviera.tcl"
                            }
                        }
                    } elseif {$tile_name == "R-TILE"} {
                        set ed_tb_path_vcs      "${TEMPPATH}/pcie_ss_ed_sim_tb/pcie_ss_ed_sim_tb/sim/synopsys/vcs"
                        set ed_tb_path_vcsmx    "${TEMPPATH}/pcie_ss_ed_sim_tb/pcie_ss_ed_sim_tb/sim/synopsys/vcsmx"
                        set ed_tb_patth_xcelium "${TEMPPATH}/pcie_ss_ed_sim_tb/pcie_ss_ed_sim_tb/sim/xcelium"
                        set ed_tb_path_msim     "${TEMPPATH}/pcie_ss_ed_sim_tb/pcie_ss_ed_sim_tb/sim/mentor"
                        set ed_tb_path_aldec    "${TEMPPATH}/pcie_ss_ed_sim_tb/pcie_ss_ed_sim_tb/sim/aldec"
                        set pipemode_sim_for_ed_hwtcl                      [ip_get "parameter.pipemode_sim_for_ed_hwtcl.value"]

                        if { [ file exist $ed_tb_path_vcs ] == 1 && $pipemode_sim_for_ed_hwtcl == 1} {
                            file copy -force "${IP_ROOTDIR}/altera/subsystems/intel_pcie_ss_axi/ed/sim_scripts/rtile/run_vcs.sh" "${ed_tb_path_vcs}/run_vcs.sh"
                        } elseif { [ file exist $ed_tb_path_vcs ] == 1 && $pipemode_sim_for_ed_hwtcl == 0} {
				 file copy -force "${IP_ROOTDIR}/altera/subsystems/intel_pcie_ss_axi/ed/sim_scripts/rtile/run_vcs_no_pipemode.sh" "${ed_tb_path_vcs}/run_vcs.sh"
			} else {
			}
                        if { [ file exist $ed_tb_path_vcsmx ] == 1  && $pipemode_sim_for_ed_hwtcl == 1} {
                            file copy -force "${IP_ROOTDIR}/altera/subsystems/intel_pcie_ss_axi/ed/sim_scripts/rtile/run_vcsmx.sh" "${ed_tb_path_vcsmx}/run_vcsmx.sh"
                        } elseif { [ file exist $ed_tb_path_vcsmx ] == 1  && $pipemode_sim_for_ed_hwtcl == 0} {
                            file copy -force "${IP_ROOTDIR}/altera/subsystems/intel_pcie_ss_axi/ed/sim_scripts/rtile/run_vcsmx_no_pipemode.sh" "${ed_tb_path_vcsmx}/run_vcsmx.sh"
                        } else {
			}
                        if { [ file exist $ed_tb_patth_xcelium ] == 1  && $pipemode_sim_for_ed_hwtcl == 1} {
                            file copy -force "${IP_ROOTDIR}/altera/subsystems/intel_pcie_ss_axi/ed/sim_scripts/rtile/run_xcelium.sh" "${ed_tb_patth_xcelium}/run_xcelium.sh"
                        } elseif { [ file exist $ed_tb_patth_xcelium ] == 1  && $pipemode_sim_for_ed_hwtcl == 0} {
                            file copy -force "${IP_ROOTDIR}/altera/subsystems/intel_pcie_ss_axi/ed/sim_scripts/rtile/run_xcelium_no_pipemode.sh" "${ed_tb_patth_xcelium}/run_xcelium.sh"
                        } else {
			}
                        if { [ file exist $ed_tb_path_msim ] == 1  && $pipemode_sim_for_ed_hwtcl == 1} {
                            file copy -force "${IP_ROOTDIR}/altera/subsystems/intel_pcie_ss_axi/ed/sim_scripts/rtile/run_msim.tcl" "${ed_tb_path_msim}/run_msim.tcl"
                        } elseif { [ file exist $ed_tb_path_msim ] == 1  && $pipemode_sim_for_ed_hwtcl == 0} {
                            file copy -force "${IP_ROOTDIR}/altera/subsystems/intel_pcie_ss_axi/ed/sim_scripts/rtile/run_msim_no_pipemode.tcl" "${ed_tb_path_msim}/run_msim.tcl"
                        } else {
			}
                        if { [ file exist $ed_tb_path_aldec ] == 1  && $pipemode_sim_for_ed_hwtcl == 1} {
                            file copy -force "${IP_ROOTDIR}/altera/subsystems/intel_pcie_ss_axi/ed/sim_scripts/rtile/run_riviera.tcl" "${ed_tb_path_aldec}/run_riviera.tcl"
                        } elseif { [ file exist $ed_tb_path_aldec ] == 1  && $pipemode_sim_for_ed_hwtcl == 0} {
                            file copy -force "${IP_ROOTDIR}/altera/subsystems/intel_pcie_ss_axi/ed/sim_scripts/rtile/run_riviera_no_pipemode.tcl" "${ed_tb_path_aldec}/run_riviera.tcl"
                        } else {
			}

                    } else { 
                        #P-Tile
                        set ed_tb_path_vcs     "${TEMPPATH}/pcie_ss_ed_sim_tb/pcie_ss_ed_sim_tb/sim/synopsys/vcs"
                        set ed_tb_path_vcsmx   "${TEMPPATH}/pcie_ss_ed_sim_tb/pcie_ss_ed_sim_tb/sim/synopsys/vcsmx"
                        set ed_tb_path_msim    "${TEMPPATH}/pcie_ss_ed_sim_tb/pcie_ss_ed_sim_tb/sim/mentor"
                        set ed_tb_path_aldec   "${TEMPPATH}/pcie_ss_ed_sim_tb/pcie_ss_ed_sim_tb/sim/aldec"
                        if { [ file exist $ed_tb_path_vcs ] == 1 } {
                            file copy -force "${IP_ROOTDIR}/altera/subsystems/intel_pcie_ss_axi/ed/sim_scripts/ptile/run_vcs.sh" "${ed_tb_path_vcs}/run_vcs.sh"
                        }
                        if { [ file exist $ed_tb_path_vcsmx ] == 1 } {
                            file copy -force "${IP_ROOTDIR}/altera/subsystems/intel_pcie_ss_axi/ed/sim_scripts/ptile/run_vcsmx.sh" "${ed_tb_path_vcsmx}/run_vcsmx.sh"
                        }
                        if { [ file exist $ed_tb_path_msim ] == 1 } {
                            file copy -force "${IP_ROOTDIR}/altera/subsystems/intel_pcie_ss_axi/ed/sim_scripts/ptile/run_msim.tcl" "${ed_tb_path_msim}/run_msim.tcl"
                        }
                        if { [ file exist $ed_tb_path_aldec ] == 1 } {
                            file copy -force "${IP_ROOTDIR}/altera/subsystems/intel_pcie_ss_axi/ed/sim_scripts/ptile/run_riviera.tcl" "${ed_tb_path_aldec}/run_riviera.tcl"
                        }
                    }
                    
                }
                puts $quartus_file "project_close"
                close $quartus_file

               
                # Running quartus file and parsing the log for errors
                send_message info "Running: quartus_sh -t ${QUARTUSFILE}"
                set found_error -1
                if {[catch "exec quartus_sh -t ${QUARTUSFILE}" msg]} {
                    set PINOUT_MSG [ open $pinout_msg_filename "w" ]
                    puts $PINOUT_MSG $msg
                    close $PINOUT_MSG
                    set found_error [lsearch $msg "Error:"]
                }

                if {$found_error < 0} {
                    # file copy $s10_devkit_tcl $recommended_pinassignments_s10
                    send_message info "Successfully generated : ${project_name}.qpf, ${project_name}.qsf"

                } else {
                    send_message error "Pin assignments file ${s10_devkit_tcl} could not be run."
                    send_message error "Read $pinout_msg_filename"
                    set PassPinoutGeneration 0
                }
            } else {
                # File could not be generated properly.
                send_message error "Could not generate pin assignments file ${s10_devkit_tcl}"
                set PassPinoutGeneration 0
            }
        }
        
        if { $PassSimGeneration==0 || $PassSynthGeneration==0 || $PassPinoutGeneration==0 } {
            set FAILG [ open $failgen "w" ]
            puts $FAILG "synth:${PassSynthGeneration} tb:${PassSimGeneration} pinout:${PassPinoutGeneration}"
            close $FAILG
        }
    }


    proc ::intel_pcie_ss_axi::pcie_syspll_ed {tempDir} {
        # Quartus command
        global env
        set qbindir     $env(QUARTUS_BINDIR)
        set qrootdir    $env(QUARTUS_ROOTDIR)
        set qsys_cmd    "${qrootdir}/sopc_builder/bin/"
        set tile_name   [ip_get "parameter.TILE.value"]

        
        # directory handling
        set pwd_dir     [pwd]

        # jkoe
        set info_head   "RP Generation:"
        send_message info "${info_head} Creating folder for Root Port generated files $tempDir"
        set temp_dir    $tempDir
        set enable_multi_func_hwtcl                 [ip_get "parameter.core16_enable_multi_func_hwtcl.value"]
        set rp_path    "pcie_ed_rp/"

        catch {cd $tempDir}

        #set foo [catch "exec mkdir -p -- ${tempDir}${rp_path}" msg]
        if { [ file exist "${tempDir}${rp_path}" ] != 1 } {
            file mkdir "${tempDir}${rp_path}"
        }
        set temp_dir    "${tempDir}${rp_path}"
            # jkoe end ------------------------- #

        send_message INFO "${info_head} temp_dir: $temp_dir"

        # device
        set devkit [ ip_get "parameter.chosen_devkit_hwtcl.value" ]
        if { [regexp "NONE" $devkit] } {
            set qpf_dev	[ip_get "parameter.device.value"]
        } else {
            set qpf_dev     [ip_get "parameter.chosen_devkit_opn_hwtcl.value"]
        }
        set qpf_devf    [ip_get "parameter.device_family.value"]
        set top_topology_hwtcl  [ip_get "parameter.top_topology_hwtcl.value"]
        set pipemode_sim_hwtcl                      [ip_get "parameter.pipemode_sim_ed_hwtcl.value"]
        # ------ create project ------
        set QPFTcl     "${temp_dir}/create_quartus_project.tcl"
        set QPFLogPath "${temp_dir}/output_create_qpf.log"
        set create_prj [open $QPFTcl "w"]
        puts $create_prj "project_new pcie -overwrite"
        puts $create_prj "set_global_assignment -name DEVICE $qpf_dev"
        puts $create_prj "set_global_assignment -name FAMILY \"{$qpf_devf}\""
        puts $create_prj "set_global_assignment -name TOP_LEVEL_ENTITY pcie_top"
        puts $create_prj ""
        puts $create_prj "project_close"
        close $create_prj

        # running quartus_sh (TODO: add full path for quartus_sh executable)
        send_message info "${info_head} Creating Quartus project file"
        catch {cd $temp_dir}
        set foo [catch "exec quartus_sh -t $QPFTcl" msg]
        catch {cd $pwd_dir}

        if {[string match "*Error:*" $msg]} {
            send_message ERROR "${info_head} Error when executing: quartus_sh"
            send_message ERROR "${info_head} Error message: $msg"
        }

        set logFile [open $QPFLogPath "w"]
        puts $logFile $msg
        close $logFile

        # ------ create QSYS system ------
        set QSYSScript          "ip_gen.tcl"
        set QSYSScriptPath      "${temp_dir}/${QSYSScript}"
        set QSYSScriptLogPath   "${temp_dir}/output_qsys_script.log"
        set QSYSGenerateLogPath "${temp_dir}/output_qsys_generate.log"

        # tcl script creation
        set ScriptFile [open $QSYSScriptPath "w"]
        puts $ScriptFile "package require -exact qsys 20.1"
        puts $ScriptFile ""
        if {$tile_name == "F-TILE"} {
            puts $ScriptFile "set syspll_in_refclk_intf      refclk_fgt"
            puts $ScriptFile "set syspll_out_systempll_intf  out_systempll_clk_0"
            puts $ScriptFile "set syspll_out_refclk3_intf    out_refclk_fgt_3"
            puts $ScriptFile "set syspll_out_refclk5_intf    out_refclk_fgt_5"
            if { [regexp "4x4" $top_topology_hwtcl] } {
                puts $ScriptFile "set syspll_out_refclk1_intf    out_refclk_fgt_1"
                puts $ScriptFile "set syspll_out_refclk7_intf    out_refclk_fgt_7"
            }
            puts $ScriptFile ""
            puts $ScriptFile "set pcie_in_systempll_intf     pcie_systempll_clk"
            puts $ScriptFile "set pcie_in_refclk0_intf       refclk0"
            puts $ScriptFile "set pcie_in_refclk1_intf       refclk1"
            if { [regexp "4x4" $top_topology_hwtcl] } {
                puts $ScriptFile "set pcie_in_refclk2_intf       refclk2"
                puts $ScriptFile "set pcie_in_refclk3_intf       refclk3"
            }
        }
        puts $ScriptFile ""
        puts $ScriptFile "create_system"
        puts $ScriptFile ""
        puts $ScriptFile "set_project_property DEVICE_FAMILY $qpf_devf"
        puts $ScriptFile "set_project_property DEVICE \"$qpf_dev\""
        puts $ScriptFile ""
        puts $ScriptFile "#################################"
        puts $ScriptFile "# PCIe IP"
        puts $ScriptFile "#################################"
        puts $ScriptFile ""
        if {$tile_name == "R-TILE"} {
            puts $ScriptFile "add_component                 pcie_inst ip/pcie_top/pcie.ip intel_rtile_pcie_ast"
        } elseif {$tile_name == "F-TILE"} {
            puts $ScriptFile "add_component                 pcie_inst ip/pcie_top/pcie.ip pcie_avst_f"
        }
        puts $ScriptFile "load_component                pcie_inst"
      	set pipemode_sim_for_ed_hwtcl                      [ip_get "parameter.pipemode_sim_for_ed_hwtcl.value"]
        if {$tile_name == "F-TILE"} {
	          if {$pipemode_sim_for_ed_hwtcl ==1} {
	          puts $ScriptFile "set_component_parameter_value pipemode_sim_ed_hwtcl 1"
	     }
            puts $ScriptFile "set_component_parameter_value virtual_rp_ep_mode_hwtcl \"Root Port\""
            puts $ScriptFile "set_component_parameter_value top_topology_hwtcl \"Gen4 1x16, Interface - 512 bit\""
            # set value [ip_get "parameter.standard_interface_selection_hwtcl.value"]
            # puts $ScriptFile "set_component_parameter_value standard_interface_selection_hwtcl {${value}}"
            set top_topology_hwtcl                      [ip_get "parameter.top_topology_hwtcl.value"]
            if { [regexp "x8" $top_topology_hwtcl]} {
                puts $ScriptFile "set_component_parameter_value ed_generating_rp_hwtcl 1"
                puts $ScriptFile "set_component_parameter_value core16_virtual_num_of_lanes_16_hwtcl \"8\""
            }
        } else {
            if {$tile_name == "R-TILE"} {
	             if {$pipemode_sim_for_ed_hwtcl ==1} {
		               puts $ScriptFile "set_component_parameter_value pipemode_sim_hwtcl 1"
	             }
                puts $ScriptFile "set_component_parameter_value topology_1x16_mode_hwtcl \"Root Port\""
                puts $ScriptFile "set_component_parameter_value top_topology_hwtcl \"Gen5 1x16, Interface - 1024 bit\""
                puts $ScriptFile "set_component_parameter_value qhip_csb2wire_en_hwtcl 1"
            } 
            puts $ScriptFile "set_component_parameter_value core16_hip_reconfig_user_hwtcl 1"
						
            if {[regexp "x8" $top_topology_hwtcl]} {
                puts $ScriptFile "set_component_parameter_value core16_virtual_num_of_lanes_16_hwtcl {8}"
            }
        }

        
        puts $ScriptFile "save_component"
        puts $ScriptFile ""
        puts $ScriptFile "# get instance interface"
        puts $ScriptFile "set pcie_all_intf             \[get_instance_interfaces pcie_inst\]"
        puts $ScriptFile ""
        puts $ScriptFile "# add the interface & exports"
        puts $ScriptFile "foreach intf \$pcie_all_intf \{"
        if {$tile_name == "F-TILE"} {
            puts $ScriptFile "   if \{\$intf == \"\$pcie_in_refclk0_intf\"\} \{"
            puts $ScriptFile "   \} elseif \{\$intf == \"\$pcie_in_refclk1_intf\"\} \{"
            if { [regexp "4x4" $top_topology_hwtcl] } {
                puts $ScriptFile "   \} elseif \{\$intf == \"\$pcie_in_refclk2_intf\"\} \{"
                puts $ScriptFile "   \} elseif \{\$intf == \"\$pcie_in_refclk3_intf\"\} \{"
            }
            puts $ScriptFile "   \} elseif \{\$intf == \"\$pcie_in_systempll_intf\"\} \{"
            puts $ScriptFile "   \} else \{"
            puts $ScriptFile "      set_interface_property \$intf EXPORT_OF pcie_inst.\$intf"
            puts $ScriptFile "   \}"
            puts $ScriptFile "\}"
            puts $ScriptFile ""
            puts $ScriptFile "#################################"
            puts $ScriptFile "# System PLL IP"
            puts $ScriptFile "#################################"
            puts $ScriptFile ""
            puts $ScriptFile "add_component                  syspll_inst ip/pcie_top/syspll.ip systemclk_f"
            puts $ScriptFile "load_component                 syspll_inst"
            puts $ScriptFile "set_component_parameter_value  syspll_refclk_src_0 \"RefClk #3\""
            set pld_clkfreq_integer_hwtcl    [ip_get "parameter.pld_clkfreq_integer_hwtcl.value"]
            set adapter_type_hwtcl           [ip_get "parameter.adapter_type_hwtcl.value"]

            if {$adapter_type_hwtcl == "A" || $adapter_type_hwtcl == "B" || $adapter_type_hwtcl == "C"} {
                if {$pld_clkfreq_integer_hwtcl == 250} {
                    puts $ScriptFile "set_component_parameter_value  syspll_mod_0 \"PCIE_FREQ_1000\""
                } elseif {$pld_clkfreq_integer_hwtcl == 225} {
                    puts $ScriptFile "set_component_parameter_value  syspll_mod_0 \"PCIE_FREQ_900\""
                } elseif {$pld_clkfreq_integer_hwtcl == 200} {
                    puts $ScriptFile "set_component_parameter_value  syspll_mod_0 \"PCIE_FREQ_800\""
                } elseif {$pld_clkfreq_integer_hwtcl == 175} {
                    puts $ScriptFile "set_component_parameter_value  syspll_mod_0 \"PCIE_FREQ_700\""
                }
            } else {
                if { $pld_clkfreq_integer_hwtcl == 500 } {
                    puts $ScriptFile "set_component_parameter_value  syspll_mod_0 \"PCIE_FREQ_1000\""
                } elseif { $pld_clkfreq_integer_hwtcl == 450 } {
                    puts $ScriptFile "set_component_parameter_value  syspll_mod_0 \"PCIE_FREQ_900\""
                } elseif { $pld_clkfreq_integer_hwtcl == 400 } {
                    puts $ScriptFile "set_component_parameter_value  syspll_mod_0 \"PCIE_FREQ_800\""
                } elseif { $pld_clkfreq_integer_hwtcl == 350 } {
                    puts $ScriptFile "set_component_parameter_value  syspll_mod_0 \"PCIE_FREQ_700\""
                } elseif { $pld_clkfreq_integer_hwtcl == 250 } {
                    puts $ScriptFile "set_component_parameter_value  syspll_mod_0 \"PCIE_FREQ_500\""
                }
            }

            #puts $ScriptFile "set_component_parameter_value  syspll_freq_mhz_0 ${syspll_freq_mhz}"
            #puts $ScriptFile "set_component_parameter_value  syspll_freq_mhz_1 1000"
            #puts $ScriptFile "set_component_parameter_value  syspll_freq_mhz_2 1000"
            #puts $ScriptFile "set_component_parameter_value  syspll_preset_0 \"User PCIE-based Configuration\""
            puts $ScriptFile "set_component_parameter_value  refclk_fgt_output_enable_3 1"
            puts $ScriptFile "set_component_parameter_value  refclk_fgt_output_enable_5 1"
            puts $ScriptFile "set_component_parameter_value  refclk_fgt_freq_mhz_3 100.000000"
            puts $ScriptFile "set_component_parameter_value  refclk_fgt_freq_mhz_5 100.000000"
            if { [regexp "4x4" $top_topology_hwtcl] } {
                puts $ScriptFile "set_component_parameter_value  refclk_fgt_output_enable_1 1"
                puts $ScriptFile "set_component_parameter_value  refclk_fgt_output_enable_7 1"
                puts $ScriptFile "set_component_parameter_value  refclk_fgt_freq_mhz_1 100.000000"
                puts $ScriptFile "set_component_parameter_value  refclk_fgt_freq_mhz_7 100.000000"
            }
            # if { $enable_pcie_independent_refclk_syspll_hwtcl ==1 } {
            #     #puts $ScriptFile "set_component_parameter_value  refclk_fgt_output_enable_0 1"
            #     puts $ScriptFile "set_component_parameter_value  refclk_fgt_freq_mhz_0 100.000000"
            # } 
            puts $ScriptFile "save_component"
            puts $ScriptFile ""
            puts $ScriptFile "# get instance interface"
            puts $ScriptFile "set syspll_all_intf             \[get_instance_interfaces syspll_inst\]"
            puts $ScriptFile ""
            puts $ScriptFile "# add the interface & exports"
            puts $ScriptFile "foreach intf \$syspll_all_intf \{"
            puts $ScriptFile "   if \{\$intf == \"\$syspll_in_refclk_intf\"\} \{"
            puts $ScriptFile "      set_interface_property \$intf EXPORT_OF syspll_inst.\$intf"
            puts $ScriptFile "   \}"
            puts $ScriptFile "\}"
            puts $ScriptFile ""
            puts $ScriptFile ""
            puts $ScriptFile "# add the connections"
            puts $ScriptFile "add_connection syspll_inst.\${syspll_out_refclk3_intf}/pcie_inst.\$pcie_in_refclk0_intf"
            puts $ScriptFile "add_connection syspll_inst.\${syspll_out_refclk5_intf}/pcie_inst.\$pcie_in_refclk1_intf"
            if { [regexp "4x4" $top_topology_hwtcl] } {
                puts $ScriptFile "add_connection syspll_inst.\${syspll_out_refclk1_intf}/pcie_inst.\$pcie_in_refclk2_intf"
                puts $ScriptFile "add_connection syspll_inst.\${syspll_out_refclk7_intf}/pcie_inst.\$pcie_in_refclk3_intf"
            }
            puts $ScriptFile "add_connection syspll_inst.\${syspll_out_systempll_intf}/pcie_inst.\$pcie_in_systempll_intf"
            puts $ScriptFile ""
            puts $ScriptFile ""
        } else {
            puts $ScriptFile "      set_interface_property \$intf EXPORT_OF pcie_inst.\$intf"
            puts $ScriptFile "\}"
        }
        puts $ScriptFile ""
        puts $ScriptFile "sync_sysinfo_parameters"
        puts $ScriptFile "save_system pcie_top"
        puts $ScriptFile ""
        close $ScriptFile

        # running qsys-script
        send_message info "${info_head} Running: qsys-script"
        catch {cd $temp_dir}
        set foo [catch "exec ${qsys_cmd}/qsys-script --script=${QSYSScript} -qpf=pcie.qpf" msg]
        catch {cd $pwd_dir}

        if {[string match "*Error:*" $msg]} {
            send_message ERROR "${info_head} Error when executing: qsys-script"
            send_message ERROR "${info_head} Error message: $msg"
        }

        set logFile [open $QSYSScriptLogPath "w"]
        puts $logFile $msg
        close $logFile

        # running qsys-generate
        set DeviceQSF [ip_get "parameter.chosen_devkit_opn_hwtcl.value"]
        send_message info "${info_head} Running: qsys-generate"
        catch {cd $temp_dir}
        set foo [catch "exec ${qsys_cmd}/qsys-generate --synthesis=verilog --simulation=verilog pcie_top.qsys --part=${DeviceQSF}" msg]
        catch {cd $pwd_dir}

        if {[string match "*Error:*" $msg]} {
            send_message ERROR "${info_head} Error when executing: qsys-generate"
            send_message ERROR "${info_head} Error message: $msg"
        }

        set logFile [open $QSYSGenerateLogPath "w"]
        puts $logFile $msg
        close $logFile


        if { $tile_name == "F-TILE" } {
            # ------ replace port name to match with RTL ------
            # Rename for regtest & DV env. Port rename is not needed for QTLG

            global env
            set IP_ROOTDIR $env(QUARTUS_ROOTDIR)
            set IP_ROOTDIR "${IP_ROOTDIR}/../ip"
            set pcie_top_path "${IP_ROOTDIR}/altera/subsystems/intel_pcie_ss_axi/ed/rtl/"

            send_message INFO "${info_head} Replacing QSYS port name"
            set pcie_top_syn_path "${temp_dir}/pcie_top/synth"
            set pcie_top_sim_path "${temp_dir}/pcie_top/sim"
            set pipemode_sim_for_ed_hwtcl                      [ip_get "parameter.pipemode_sim_for_ed_hwtcl.value"]
            if { $pipemode_sim_for_ed_hwtcl ==1} {
            file copy -force "${pcie_top_path}/ftile_pipe_ed_pcie_top.v" "${pcie_top_syn_path}/pcie_top.v"
            file copy -force "${pcie_top_syn_path}/pcie_top.v" "${pcie_top_sim_path}/pcie_top.v"
            } else {
            file copy -force "${pcie_top_path}/ftile_ed_pcie_top.v" "${pcie_top_syn_path}/pcie_top.v"
            file copy -force "${pcie_top_syn_path}/pcie_top.v" "${pcie_top_sim_path}/pcie_top.v"
           }

            # ------ create quartus.ini ------
            # TODO: NEEDED TEMPORARY, SHOULD REMOVE IN THE NEAR FUTURE
            set QINIPath   "${temp_dir}/quartus.ini"
            set create_ini [open $QINIPath "w"]
            
            set device_revision [ip_get "parameter.device_revision.value"]
            if { [regexp "6" $device_revision] } {
                puts $create_ini "constra_disable_rules=hdpldadapt_rx_chnl:rx_pld_8g_eidleinfersel_polling_bypass_rule,hdpldadapt_rx_chnl:rx_pld_pma_eye_monitor_polling_bypass_rule,hdpldadapt_rx_chnl:rx_pld_pma_pcie_switch_polling_bypass_rule,hdpldadapt_rx_chnl:rx_pld_pma_reser_out_polling_bypass_rule,hdpldadapt_tx_chnl:tx_pld_pma_fpll_num_phase_shifts_polling_bypass_rule,hdpldadapt_tx_chnl:tx_pld_8g_tx_boundary_sel_polling_bypass_rule,hdpldadapt_tx_chnl:tx_pld_10g_tx_bitslip_polling_bypass_rule,hdpldadapt_tx_chnl:tx_pld_pma_fpll_cnt_sel_polling_bypass_rule,hdpldadapt_tx_chnl:tx_hip_aib_ssr_in_polling_bypass_rule,hdpldadapt_tx_chnl:tx_hip_scg_rules"
            }
            puts $create_ini "constra_single_conflict_enabled=on"
            close $create_ini


            set QSFPath   "${temp_dir}/pcie.qsf"
            set qsf_file  [open $QSFPath "a"]
            
                # ------ running quartus_tlg ------
            # # TODO: add full path for quartus_tlg executable
            set QTLGLogPath "${temp_dir}/output_qtlg1.log"
            variable generated_name
            send_message info "${info_head} Running QTLG: quartus_tlg pcie --verbose --tiles=ftile_s20_v0__pcie__tile_0"
            catch {cd $temp_dir}
            set foo [catch "exec quartus_tlg pcie --verbose --tiles=ftile_s20_v0__pcie__tile_0" msg]
            catch {cd $pwd_dir}

            if {[string match "*Error:*" $msg]} {
                send_message ERROR "${info_head} Error when executing: quartus_tlg"
                send_message ERROR "${info_head} Error message: $msg"
            }

            set logFile [open $QTLGLogPath "w"]
            puts $logFile $msg
            close $logFile

            # ------ runnin ip-mak-simscript to compile all filelists ------
            # write tile_wrapper.spd
            set TileWrapperSPD "${temp_dir}/tile_wrapper.spd"
            set SPDFile [open $TileWrapperSPD "w"]
            puts $SPDFile "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
            puts $SPDFile "<simPackage>"
            puts $SPDFile "<file path=\"support_logic/pcie_auto_tiles.sv\" type=\"VERILOG\" />"
            # if { $syspll_enable == 0 } {

                       
            # }
            puts $SPDFile "</simPackage>"
            close $SPDFile

            set MakeSimScriptLogPath "${temp_dir}/output_make_simscript.log"
            set spd_list "./ip/pcie_top/syspll/syspll.spd,./ip/pcie_top/pcie/pcie.spd,./tile_wrapper.spd,./pcie_top/pcie_top.spd"

            send_message info "${info_head} Running ip-setup-simulation"
            catch {cd $temp_dir}
            set foo [catch "exec ${qsys_cmd}/ip-setup-simulation --quartus-project=pcie.qpf --output-directory=sim --use-relative-paths" msg]
            #set foo [catch "exec ${qsys_cmd}/ip-make-simscript --spd=$spd_list --output-directory=sim --use_relative_paths" msg]
            catch {cd $pwd_dir}

            if {[string match "*Error:*" $msg]} {
                send_message ERROR "${info_head} Error when executing: ip-setup-simulation"
                send_message ERROR "${info_head} Error message: $msg"
            }

            set logFile [open $MakeSimScriptLogPath "w"]
            puts $logFile $msg
            close $logFile

        } else {
            set MakeSimScriptLogPath "${temp_dir}/output_make_simscript.log"
            set spd_list "./ip/pcie_top/pcie/pcie.spd,./pcie_top/pcie_top.spd"

            send_message info "${info_head} Running ip-make-simscript"
            catch {cd $temp_dir}
            set foo [catch "exec ${qsys_cmd}/ip-make-simscript --spd=$spd_list --output-directory=sim --use_relative_paths" msg]
            catch {cd $pwd_dir}

            if {[string match "*Error:*" $msg]} {
                send_message ERROR "${info_head} Error when executing: ip-make-simscript"
                send_message ERROR "${info_head} Error message: $msg"
            }

            set logFile [open $MakeSimScriptLogPath "w"]
            puts $logFile $msg
            close $logFile
        }

    }

    proc ::intel_pcie_ss_axi::software_fileset { } {
        global env
        set QUARTUS_ROOTDIR $env(QUARTUS_ROOTDIR)
        
        set src_files { "kernel/linux/intel_fpga_pcie.h"
            "kernel/linux/intel_fpga_pcie_chr.c"
            "kernel/linux/intel_fpga_pcie_chr.h"
            "kernel/linux/intel_fpga_pcie_dma.c"
            "kernel/linux/intel_fpga_pcie_dma.h"
            "kernel/linux/intel_fpga_pcie_ioctl.c"
            "kernel/linux/intel_fpga_pcie_ioctl.h"
            "kernel/linux/intel_fpga_pcie_setup.c"
            "kernel/linux/intel_fpga_pcie_setup.h"
            "user/api/intel_fpga_pcie_api.hpp"
            "user/api/linux/intel_fpga_pcie_api_linux.cpp"
            "user/api/linux/intel_fpga_pcie_api_linux.hpp"
            "user/example/intel_rtile_pcie_ast.h"
        }
            # "user/example/intel_fpga_pcie_link_test.cpp"
            # "user/example/intel_fpga_pcie_link_test.hpp"

        
        foreach sf $src_files {
            add_fileset_file software/${sf} OTHER PATH ${QUARTUS_ROOTDIR}/../ip/altera/intel_pcie/intel_pcie_software/$sf
        }
        #Temp WA to replace QHIP software files to support 1x8, 2x4 and 1x4 Performance mode    
        add_fileset_file software/user/example/intel_fpga_pcie_link_test.cpp OTHER PATH ${QUARTUS_ROOTDIR}/../ip/altera/subsystems/intel_pcie_ss_axi/ed/sw/intel_fpga_pcie_link_test.cpp
        add_fileset_file software/user/example/intel_fpga_pcie_link_test.hpp OTHER PATH ${QUARTUS_ROOTDIR}/../ip/altera/subsystems/intel_pcie_ss_axi/ed/sw/intel_fpga_pcie_link_test.hpp
        
        set misc_files { "kernel/linux/Makefile"
            "kernel/linux/README"
            "kernel/linux/install"
            "kernel/linux/load"
            "kernel/linux/unload"
            "user/api/doxygen_gen_cfg"
            "user/example/Makefile"
        }
        
        foreach mf $misc_files {
            add_fileset_file software/${mf} OTHER PATH ${QUARTUS_ROOTDIR}/../ip/altera/intel_pcie/intel_pcie_software/${mf}.txt
        }
        
        set params(bar_types)      [list] ;# init the arrays describing the BARs
        
        # set core4_0_enable_sriov_hwtcl [ip_get "parameter.core4_0_enable_sriov_hwtcl.value"]
        # set core4_1_enable_sriov_hwtcl [ip_get "parameter.core4_1_enable_sriov_hwtcl.value"]
        set core8_enable_sriov_hwtcl [ip_get "parameter.core8_enable_sriov_hwtcl.value"]
        set core16_enable_sriov_hwtcl [ip_get "parameter.core16_enable_sriov_hwtcl.value"]
        
        if { ${core8_enable_sriov_hwtcl} || ${core16_enable_sriov_hwtcl} } {
        # SR-IOV example design is actually even more restrictive than just RXM;
        # However, for now, this will suffice.
            set hprxm_bar 0
        } else {
            set hprxm_bar 1
        }
        
        for { set i 0 } { $i < 6 } { incr i } {
        if { $hprxm_bar == 1 } {
            # Using HPRXM BAR.
            lappend params(bar_types) "HPRXM"
        } else {
            lappend params(bar_types) "RXM"
        }
        }
        set params(dma_supported) 0
        
                
        set file_name "kernel/intel_fpga_pcie_ip_params.h"
        set template_path "${QUARTUS_ROOTDIR}/../ip/altera/intel_pcie/intel_pcie_software/${file_name}.terp" ;# path to the TERP template
        set template_fd   [open $template_path] ;# file handle for template
        set template      [read $template_fd]   ;# template contents
        close $template_fd ;# we are done with the file so we should close it
        
        # process template with parameters
        set contents [altera_terp $template params] ;# pass parameter array in by reference
        add_fileset_file software/${file_name} OTHER TEXT ${contents}
    }

    proc ::intel_pcie_ss_axi::s10_pcie_devkit_pinout {project_name s10_devkit_tcl TEMPPATH} {

        send_message info "Generating pin assignments..."

        
        set s10_devkit_tcl_temp "${TEMPPATH}/${s10_devkit_tcl}"
        set QSF_FILE [ open $s10_devkit_tcl_temp "w" ]

        #load_component "DUT"
        # 2. Change device to match Development Kit
        set devkit [ ip_get "parameter.chosen_devkit_hwtcl.value" ]
        set device_family [ ip_get "parameter.device_family.value" ]

        # 3. check rp/ep type
        set rp_ep_mode [ ip_get "parameter.virtual_rp_ep_mode_hwtcl.value" ]
        if { [ regexp "Native Endpoint" $rp_ep_mode ] } {
            set is_rootport 0
        } else {
            set is_rootport 1
        }

        puts "--------- :: Detected development kit $devkit"
        puts "--------- :: Detected device family $device_family"

        set DeviceQSF [ip_get "parameter.chosen_devkit_opn_hwtcl.value"]
       if {[regexp {P-Tile} $devkit]} {
            set devkit_chosen 1
            set devkit_type "P-Tile"
            set device_family "Agilex 7"
            puts "--------- ::  $devkit_type Pin assignments will be added, as $devkit devkit is specified."
        } elseif {[regexp {R-Tile} $devkit]} {
            set devkit_chosen 1
            set devkit_type "R-Tile"
            set device_family "Agilex 7"
            puts "--------- ::  $devkit_type Pin assignments will be added, as $devkit devkit is specified."
        } elseif {[regexp {F-Tile} $devkit]} {
            set devkit_chosen 1
            set devkit_type "F-Tile"
            set device_family "Agilex 7"
            puts "--------- ::  $devkit_type Pin assignments will be added, as $devkit devkit is specified."
        } else {
            set devkit_chosen 0
            set devkit_type ""
            puts "--------- ::  Pin assignments will NOT be added, as no devkit is specified."
       }

        puts "--------- ::  DeviceQSF    : $DeviceQSF                                                                                      "
        puts "--------- ::  project_name : $project_name                                                                                   "
        puts "--------- ::                                                                                                                 "
        puts "--------- ::---------------------------------------------------------------------------------------------------------------- "
        puts "--------- ::                                                                                                                 "

        # 3. Define devkit-specific pins

        if {$devkit_chosen} {
            set comment ""
        } else {
            set comment "# "
            puts $QSF_FILE "# REPLACE THE FOLLOWING COMMENTED OUT LINES WITH YOUR OWN PIN ASSIGNMENTS"
        }
        set tile_name                               [ip_get "parameter.TILE.value"]
        
        if {$devkit_type == "DX"} {
            set pinid_pin_perst_reset "PIN_BB39"
            set pinid_refclk0_clk "PIN_AT45"
            set pinid_refclk0_clkn "PIN_AT44"
            set pinid_refclk1_clk "PIN_AP45"
            set pinid_refclk1_clkn "PIN_AP44"
            array set rxn {
                0 PIN_BJ51
                1 PIN_BH53
                2 PIN_BG51
                3 PIN_BF53
                4 PIN_BE51
                5 PIN_BD53
                6 PIN_BC51
                7 PIN_BB53
                8 PIN_BA51
                9 PIN_AY53
                10 PIN_AW51
                11 PIN_AV53
                12 PIN_AU51
                13 PIN_AT53
                14 PIN_AR51
                15 PIN_AP53
            }
            array set rx {
                0 PIN_BJ52
                1 PIN_BH54
                2 PIN_BG52
                3 PIN_BF54
                4 PIN_BE52
                5 PIN_BD54
                6 PIN_BC52
                7 PIN_BB54
                8 PIN_BA52
                9 PIN_AY54
                10 PIN_AW52
                11 PIN_AV54
                12 PIN_AU52
                13 PIN_AT54
                14 PIN_AR52
                15 PIN_AP54
            }
            array set txn {
                0 PIN_BJ47
                1 PIN_BH49
                2 PIN_BG47
                3 PIN_BF49
                4 PIN_BE47
                5 PIN_BD49
                6 PIN_BC47
                7 PIN_BB49
                8 PIN_BA47
                9 PIN_AY49
                10 PIN_AW47
                11 PIN_AV49
                12 PIN_AU47
                13 PIN_AT49
                14 PIN_AR47
                15 PIN_AP49
            }
            array set tx {
                0 PIN_BJ48
                1 PIN_BH50
                2 PIN_BG48
                3 PIN_BF50
                4 PIN_BE48
                5 PIN_BD50
                6 PIN_BC48
                7 PIN_BB50
                8 PIN_BA48
                9 PIN_AY50
                10 PIN_AW48
                11 PIN_AV50
                12 PIN_AU48
                13 PIN_AT50
                14 PIN_AR48
                15 PIN_AP50
            }
        } elseif {$devkit_type == "R-Tile"} {
            set pinid_pin_perst_reset "PIN_CD58"
            set pinid_refclk0_clk "PIN_DR68"
            set pinid_refclk0_clkn "PIN_DM70"
            set pinid_refclk1_clk "PIN_CU68"
            set pinid_refclk1_clkn "PIN_CR70"
            array set rxn {
                0 PIN_DB83
                1 PIN_CT79
                2 PIN_CJ83
                3 PIN_CC79
                4 PIN_BU83
                5 PIN_BL79
                6 PIN_BE83
                7 PIN_AW79
                8 PIN_AM83
                9 PIN_AF79
                10 PIN_Y83
                11 PIN_T79
                12 PIN_M83
                13 PIN_G79
                14 PIN_P76
                15 PIN_E76
            }
            array set rx {
                0 PIN_DE82
                1 PIN_CW80
                2 PIN_CM82
                3 PIN_CF80
                4 PIN_BY82
                5 PIN_BP80
                6 PIN_BH82
                7 PIN_BB80
                8 PIN_AR82
                9 PIN_AJ80
                10 PIN_AC82
                11 PIN_V80
                12 PIN_P82
                13 PIN_K80
                14 PIN_M77
                15 PIN_C77
            }
            array set txn {
                0 PIN_DH73
                1 PIN_DE76
                2 PIN_CT73
                3 PIN_CM76
                4 PIN_CC73
                5 PIN_BY76
                6 PIN_BL73
                7 PIN_BH76
                8 PIN_AW73
                9 PIN_AR76
                10 PIN_AF73
                11 PIN_AC76
                12 PIN_T73
                13 PIN_G73
                14 PIN_E69
                15 PIN_P69
            }
            array set tx {
                0 PIN_DL74
                1 PIN_DB77
                2 PIN_CW74
                3 PIN_CJ77
                4 PIN_CF74
                5 PIN_BU77
                6 PIN_BP74
                7 PIN_BE77
                8 PIN_BB74
                9 PIN_AM77
                10 PIN_AJ74
                11 PIN_Y77
                12 PIN_V74
                13 PIN_K74
                14 PIN_C71
                15 PIN_M71
            }
        } elseif {$devkit_type == "P-Tile"} {
            set pinid_pin_perst_reset "PIN_BU58"
            set pinid_refclk0_clk "PIN_AJ48"
            set pinid_refclk0_clkn "PIN_AH49"
            set pinid_refclk1_clk "PIN_AE48"
            set pinid_refclk1_clkn "PIN_AD49"
            array set rxn {
                0 PIN_BR62
                1 PIN_BM59
                2 PIN_BL62
                3 PIN_BH59
                4 PIN_BG62
                5 PIN_BD59
                6 PIN_BC62
                7 PIN_AY59
                8 PIN_AW62
                9 PIN_AT59
                10 PIN_AR62
                11 PIN_AM59
                12 PIN_AL62
                13 PIN_AH59
                14 PIN_AG62
                15 PIN_AD59
            }
            array set rx {
                0 PIN_BP61
                1 PIN_BN58
                2 PIN_BK61
                3 PIN_BJ58
                4 PIN_BF61
                5 PIN_BE58
                6 PIN_BB61
                7 PIN_BA58
                8 PIN_AV61
                9 PIN_AU58
                10 PIN_AP61
                11 PIN_AN58
                12 PIN_AK61
                13 PIN_AJ58
                14 PIN_AF61
                15 PIN_AE58
            }
            array set txn {
                0 PIN_BR56
                1 PIN_BM53
                2 PIN_BL56
                3 PIN_BH53
                4 PIN_BG56
                5 PIN_BD53
                6 PIN_BC56
                7 PIN_AY53
                8 PIN_AW56
                9 PIN_AT53
                10 PIN_AR56
                11 PIN_AM53
                12 PIN_AL56
                13 PIN_AH53
                14 PIN_AG56
                15 PIN_AD53
            }
            array set tx {
                0 PIN_BP55
                1 PIN_BN52
                2 PIN_BK55
                3 PIN_BJ52
                4 PIN_BF55
                5 PIN_BE52
                6 PIN_BB55
                7 PIN_BA52
                8 PIN_AV55
                9 PIN_AU52
                10 PIN_AP55
                11 PIN_AN52
                12 PIN_AK55
                13 PIN_AJ52
                14 PIN_AF55
                15 PIN_AE52
            }
        } elseif {$devkit_type == "F-Tile"} {
            set pinid_pin_perst_reset "PIN_CG13"
            set pinid_refclk0_clk "PIN_BR7"
            set pinid_refclk0_clkn "PIN_BU7"
            set pinid_refclk1_clk "PIN_CD8"
            set pinid_refclk1_clkn "PIN_CC7"
	        array set rxn {
                0 PIN_AG5
                1 PIN_AH2
                2 PIN_AM2
                3 PIN_AT2
                4 PIN_AY2
                5 PIN_BD2
                6 PIN_BH2
                7 PIN_BM2
                8 PIN_BT2
                9 PIN_BY2
                10 PIN_CD2
                11 PIN_CH2
                12 PIN_CM2
                13 PIN_CR5
                14 PIN_CT2
                15 PIN_CW5
            }
            array set rx {
                0 PIN_AF4
                1 PIN_AJ1
                2 PIN_AN1
                3 PIN_AU1
                4 PIN_BA1
                5 PIN_BE1
                6 PIN_BJ1
                7 PIN_BN1
                8 PIN_BU1
                9 PIN_CA1
                10 PIN_CE1
                11 PIN_CJ1
                12 PIN_CN1
                13 PIN_CP4
                14 PIN_CU1
                15 PIN_CV4
            }
            array set txn {
                0 PIN_AL5
                1 PIN_AM8
                2 PIN_AR5
                3 PIN_AT8
                4 PIN_AW5
                5 PIN_AY8
                6 PIN_BC5
                7 PIN_BG5
                8 PIN_BL5
                9 PIN_BR5
                10 PIN_BW5
                11 PIN_CC5
                12 PIN_CG5
                13 PIN_CL5
                14 PIN_CM8
                15 PIN_CT8
            }
            array set tx {
                0 PIN_AK4
                1 PIN_AN7
                2 PIN_AP4
                3 PIN_AU7
                4 PIN_AV4
                5 PIN_BA7
                6 PIN_BB4
                7 PIN_BF4
                8 PIN_BK4
                9 PIN_BP4
                10 PIN_BV4
                11 PIN_CB4
                12 PIN_CF4
                13 PIN_CK4
                14 PIN_CN7
                15 PIN_CU7
            }
        } else {
            # For NONE, same as DX Devkit
            set pinid_pin_perst_reset "PIN_BB39"
            set pinid_refclk0_clk "PIN_AT45"
            set pinid_refclk0_clkn "PIN_AT44"
            set pinid_refclk1_clk "PIN_AP45"
            set pinid_refclk1_clkn "PIN_AP44"
            array set rxn {
                0 PIN_BJ51
                1 PIN_BH53
                2 PIN_BG51
                3 PIN_BF53
                4 PIN_BE51
                5 PIN_BD53
                6 PIN_BC51
                7 PIN_BB53
                8 PIN_BA51
                9 PIN_AY53
                10 PIN_AW51
                11 PIN_AV53
                12 PIN_AU51
                13 PIN_AT53
                14 PIN_AR51
                15 PIN_AP53
            }
            array set rx {
                0 PIN_BJ52
                1 PIN_BH54
                2 PIN_BG52
                3 PIN_BF54
                4 PIN_BE52
                5 PIN_BD54
                6 PIN_BC52
                7 PIN_BB54
                8 PIN_BA52
                9 PIN_AY54
                10 PIN_AW52
                11 PIN_AV54
                12 PIN_AU52
                13 PIN_AT54
                14 PIN_AR52
                15 PIN_AP54
            }
            array set txn {
                0 PIN_BJ47
                1 PIN_BH49
                2 PIN_BG47
                3 PIN_BF49
                4 PIN_BE47
                5 PIN_BD49
                6 PIN_BC47
                7 PIN_BB49
                8 PIN_BA47
                9 PIN_AY49
                10 PIN_AW47
                11 PIN_AV49
                12 PIN_AU47
                13 PIN_AT49
                14 PIN_AR47
                15 PIN_AP49
            }
            array set tx {
                0 PIN_BJ48
                1 PIN_BH50
                2 PIN_BG48
                3 PIN_BF50
                4 PIN_BE48
                5 PIN_BD50
                6 PIN_BC48
                7 PIN_BB50
                8 PIN_BA48
                9 PIN_AY50
                10 PIN_AW48
                11 PIN_AV50
                12 PIN_AU48
                13 PIN_AT50
                14 PIN_AR48
                15 PIN_AP50
            }
        }

        # 4. Writing QSF file

        puts $QSF_FILE "# Setting top level entity and qsys file"
        puts $QSF_FILE "set_global_assignment -name TOP_LEVEL_ENTITY $project_name"
        puts $QSF_FILE "set_global_assignment -name QSYS_FILE ${project_name}.qsys"
        puts $QSF_FILE ""

        puts $QSF_FILE "# Setting family and device"
        puts $QSF_FILE "set_global_assignment -name FAMILY \"${device_family}\""
        puts $QSF_FILE "set_global_assignment -name DEVICE ${DeviceQSF}"
        puts $QSF_FILE ""

        puts $QSF_FILE "# Setting core junction temperature"
        puts $QSF_FILE "set_global_assignment -name MIN_CORE_JUNCTION_TEMP 0"
        puts $QSF_FILE "set_global_assignment -name MAX_CORE_JUNCTION_TEMP 100"
        puts $QSF_FILE ""

        if {!$devkit_chosen} {
            #Pin assignment won't be printed.
            # HSD:15017583023 For NONE, there shouldn't be any pin assignments, else the compilation would fail at fitter stage due to incorrect pin assignments.
        } else {
            puts $QSF_FILE "# perst interface"
            puts $QSF_FILE "set_location_assignment $pinid_pin_perst_reset -to pin_perst_n_reset_n"
            puts $QSF_FILE "# refclk interface"
            puts $QSF_FILE "set_location_assignment $pinid_refclk0_clk -to refclk0_clk"
            puts $QSF_FILE "set_location_assignment $pinid_refclk0_clkn -to \"refclk0_clk(n)\""
            puts $QSF_FILE "set_location_assignment $pinid_refclk1_clk -to refclk1_clk"
            puts $QSF_FILE "set_location_assignment $pinid_refclk1_clkn -to \"refclk1_clk(n)\""
            if {$devkit_type == "R-Tile"} {
                puts $QSF_FILE "set_instance_assignment -name IO_STANDARD \"1.0V\" -to pin_perst_n_reset_n -entity pcie_ss_ed"
            } elseif {$devkit_type == "P-Tile" || $devkit_type == "F-Tile" || $devkit_type == "DX"} {
                puts $QSF_FILE "set_instance_assignment -name IO_STANDARD \"1.8V\" -to pin_perst_n_reset_n -entity pcie_ss_ed"
            }
        }
        set pipemode_sim_hwtcl [ip_get "parameter.pipemode_sim_ed_hwtcl.value"]
	       if {$pipemode_sim_hwtcl==1 &&  $tile_name == "R-TILE"} {
	         puts $QSF_FILE "set_instance_assignment -name VIRTUAL_PIN ON -to fastp_pcie_* -entity pcie_ss_ed"
        } elseif {$pipemode_sim_hwtcl==1 &&  $tile_name == "F-TILE"} {
            puts $QSF_FILE "set_instance_assignment -name VIRTUAL_PIN ON -to o_txpipe* -entity pcie_ss_ed"
            puts $QSF_FILE "set_instance_assignment -name VIRTUAL_PIN ON -to i_rxpipe* -entity pcie_ss_ed"
            puts $QSF_FILE "set_instance_assignment -name VIRTUAL_PIN ON -to i_pclk_* -entity pcie_ss_ed"
	    }
        puts $QSF_FILE ""
        puts $QSF_FILE "# refclk interface"
        puts $QSF_FILE "set_instance_assignment -name IO_STANDARD HCSL -to refclk0_clk"
        puts $QSF_FILE "set_instance_assignment -name IO_STANDARD HCSL -to refclk1_clk"

        set hdr_pck_schme_list {}
        set tile_name [ip_get "parameter.TILE.value"]
        set core_num [ip_get "parameter.total_core_num_hwtcl.value"]
        set core_name [list "16" "8" "4_0" "4_1"]

        for {set i 0} {$i < $core_num} {incr i} {
            if {$tile_name == "R-TILE"} {
                lappend hdr_pck_schme_list [ip_get "parameter.core[lindex $core_name $i]_hip_native_mode_user_hwtcl.value"]
            } else {
                lappend hdr_pck_schme_list 0
            }
        }
        
        puts $QSF_FILE ""

        puts $QSF_FILE "# Pin assignments"
        set top_topology_hwtcl                  [ip_get "parameter.top_topology_hwtcl.value"]
        if { [regexp "2x8" $top_topology_hwtcl] } {
            set nlanes 16
        } elseif { [regexp "x4" $top_topology_hwtcl] } {
            set nlanes 16
        } elseif { [regexp "x16" $top_topology_hwtcl] } {
            set nlanes 16
        } elseif { [regexp "1x8" $top_topology_hwtcl] } {
            set nlanes 8
        }
        puts "--------- :: Detected $nlanes lane(s)"
        if {!$devkit_chosen} {
            #Pin assignment won't be printed.
            # HSD:15017583023 For NONE, there shouldn't be any pin assignments, else the compilation would fail at fitter stage due to incorrect pin assignments.
        } else {
            for {set i 0} {$i < $nlanes} {incr i} {
                
                set rx_n "hip_serial_rx_n_in${i}"
                set rx_p "hip_serial_rx_p_in${i}"
                set tx_n "hip_serial_tx_n_out${i}"
                set tx_p "hip_serial_tx_p_out${i}"

                puts $QSF_FILE "set_location_assignment $tx($i) -to ${tx_p}"
                puts $QSF_FILE "set_location_assignment $txn($i) -to ${tx_n}"
                puts $QSF_FILE "set_instance_assignment -name IO_STANDARD \"HIGH SPEED DIFFERENTIAL I/O\" -to $tx_p -entity pcie_ss_ed"
                puts $QSF_FILE ""
                puts $QSF_FILE "set_location_assignment $rx($i) -to ${rx_p}"
                puts $QSF_FILE "set_location_assignment $rxn($i) -to ${rx_n}"
                puts $QSF_FILE "set_instance_assignment -name IO_STANDARD \"HIGH SPEED DIFFERENTIAL I/O\" -to $rx_p -entity pcie_ss_ed"
                puts $QSF_FILE ""
                puts $QSF_FILE ""
            }
        }

        set core16_hip_reconfig   [ip_get "parameter.core16_hip_reconfig_hwtcl.value"]
        set core8_hip_reconfig    [ip_get "parameter.core8_hip_reconfig_hwtcl.value"]
        set core4_0_hip_reconfig  [ip_get "parameter.core4_0_hip_reconfig_hwtcl.value"]
        set core4_1_hip_reconfig  [ip_get "parameter.core4_1_hip_reconfig_hwtcl.value"]
        set xcvr_reconfig         [ip_get "parameter.xcvr_reconfig_hwtcl.value"]
        
        if { $core16_hip_reconfig ==1 || $core8_hip_reconfig == 1 || $core4_0_hip_reconfig == 1 || $core4_1_hip_reconfig == 1 || $xcvr_reconfig == 1 } {
           puts $QSF_FILE "set_instance_assignment -name VIRTUAL_PIN ON -to *dummy_user_avmm_rst*"
        }

        if { $core16_hip_reconfig == 1 } {
            puts $QSF_FILE "set_instance_assignment -name VIRTUAL_PIN ON -to *p0_hip_reconfig*" 
        }
        if { $core8_hip_reconfig == 1 } {
            puts $QSF_FILE "set_instance_assignment -name VIRTUAL_PIN ON -to *p1_hip_reconfig*" 
        }
 
        if { $core4_0_hip_reconfig == 1 } {
            puts $QSF_FILE "set_instance_assignment -name VIRTUAL_PIN ON -to *p2_hip_reconfig*" 
        }
 
        if { $core4_1_hip_reconfig == 1 } {
            puts $QSF_FILE "set_instance_assignment -name VIRTUAL_PIN ON -to *p3_hip_reconfig*" 
        }

        if { $xcvr_reconfig == 1 } {
            puts $QSF_FILE "set_instance_assignment -name VIRTUAL_PIN ON -to xcvr_reconfig_address"
            puts $QSF_FILE "set_instance_assignment -name VIRTUAL_PIN ON -to xcvr_reconfig_read"
            puts $QSF_FILE "set_instance_assignment -name VIRTUAL_PIN ON -to xcvr_reconfig_readdata"
            puts $QSF_FILE "set_instance_assignment -name VIRTUAL_PIN ON -to xcvr_reconfig_readdatavalid"
            puts $QSF_FILE "set_instance_assignment -name VIRTUAL_PIN ON -to xcvr_reconfig_write"
            puts $QSF_FILE "set_instance_assignment -name VIRTUAL_PIN ON -to xcvr_reconfig_writedata"
            puts $QSF_FILE "set_instance_assignment -name VIRTUAL_PIN ON -to xcvr_reconfig_waitrequest"
            # puts $QSF_FILE "set_location_assignment PIN_CU24 -to in_clk_clk"
            # puts $QSF_FILE "set_instance_assignment -name IO_STANDARD \"TRUE DIFFERENTIAL SIGNALING\" -to in_clk_clk"
        }

        set devkit_name [ip_get "parameter.chosen_devkit_hwtcl.value"]
        puts $QSF_FILE "# Assignments for VID"
            # Agilex F-Series Production devkit settings
        if {$devkit_type == "R-Tile" && [regexp "ES1" $devkit_name]} {
            puts $QSF_FILE "set_global_assignment -name USE_CONF_DONE SDM_IO16"
            puts $QSF_FILE "set_global_assignment -name VID_OPERATION_MODE \"PMBUS MASTER\""
            puts $QSF_FILE "set_global_assignment -name USE_PWRMGT_SCL SDM_IO0"
            puts $QSF_FILE "set_global_assignment -name USE_PWRMGT_SDA SDM_IO12"
            puts $QSF_FILE "set_global_assignment -name PWRMGT_BUS_SPEED_MODE \"100 KHZ\""
            puts $QSF_FILE "set_global_assignment -name PWRMGT_SLAVE_DEVICE_TYPE LTC3888"
            puts $QSF_FILE "set_global_assignment -name PWRMGT_SLAVE_DEVICE0_ADDRESS 47"
            puts $QSF_FILE "set_global_assignment -name PWRMGT_SLAVE_DEVICE1_ADDRESS 00"
            puts $QSF_FILE "set_global_assignment -name PWRMGT_SLAVE_DEVICE2_ADDRESS 00"
            puts $QSF_FILE "set_global_assignment -name PWRMGT_SLAVE_DEVICE3_ADDRESS 00"
            puts $QSF_FILE "set_global_assignment -name PWRMGT_SLAVE_DEVICE4_ADDRESS 00"
            puts $QSF_FILE "set_global_assignment -name PWRMGT_SLAVE_DEVICE5_ADDRESS 00"
            puts $QSF_FILE "set_global_assignment -name PWRMGT_SLAVE_DEVICE6_ADDRESS 00"
            puts $QSF_FILE "set_global_assignment -name PWRMGT_SLAVE_DEVICE7_ADDRESS 00"
            puts $QSF_FILE "set_global_assignment -name PWRMGT_TRANSLATED_VOLTAGE_VALUE_UNIT VOLTS"
            puts $QSF_FILE "set_global_assignment -name PWRMGT_PAGE_COMMAND_ENABLE OFF"
            puts $QSF_FILE "set_global_assignment -name PWRMGT_LINEAR_FORMAT_N \"-12\""
            puts $QSF_FILE "set_global_assignment -name PWRMGT_VOLTAGE_OUTPUT_FORMAT \"LINEAR FORMAT\""
            puts $QSF_FILE "set_global_assignment -name MESSAGE_DISABLE 14320 -entity pcie_ss_ed"
            # puts $QSF_FILE "set_global_assignment -name STRATIXV_CONFIGURATION_SCHEME \"ACTIVE SERIAL X4\""
            # puts $QSF_FILE "set_global_assignment -name DEVICE_INITIALIZATION_CLOCK OSC_CLK_1_125MHZ"
            # puts $QSF_FILE "set_global_assignment -name ERROR_CHECK_FREQUENCY_DIVISOR 1"
            puts $QSF_FILE "set_global_assignment -name POWER_APPLY_THERMAL_MARGIN ADDITIONAL"
            puts $QSF_FILE "set_global_assignment -name BOARD default"
            puts $QSF_FILE "set_global_assignment -name VERILOG_INPUT_VERSION SYSTEMVERILOG_2012"
        } elseif {$devkit_type == "R-Tile" && [regexp "ES2" $devkit_name]} {
            puts $QSF_FILE "set_global_assignment -name USE_CONF_DONE SDM_IO16"
            puts $QSF_FILE "set_global_assignment -name VID_OPERATION_MODE \"PMBUS MASTER\""
            puts $QSF_FILE "set_global_assignment -name USE_PWRMGT_SCL SDM_IO0"
            puts $QSF_FILE "set_global_assignment -name USE_PWRMGT_SDA SDM_IO12"
            puts $QSF_FILE "set_global_assignment -name PWRMGT_BUS_SPEED_MODE \"100 KHZ\""
            puts $QSF_FILE "set_global_assignment -name PWRMGT_SLAVE_DEVICE_TYPE OTHER"
            puts $QSF_FILE "set_global_assignment -name PWRMGT_SLAVE_DEVICE0_ADDRESS 47"
            puts $QSF_FILE "set_global_assignment -name PWRMGT_SLAVE_DEVICE1_ADDRESS 00"
            puts $QSF_FILE "set_global_assignment -name PWRMGT_SLAVE_DEVICE2_ADDRESS 00"
            puts $QSF_FILE "set_global_assignment -name PWRMGT_SLAVE_DEVICE3_ADDRESS 00"
            puts $QSF_FILE "set_global_assignment -name PWRMGT_SLAVE_DEVICE4_ADDRESS 00"
            puts $QSF_FILE "set_global_assignment -name PWRMGT_SLAVE_DEVICE5_ADDRESS 00"
            puts $QSF_FILE "set_global_assignment -name PWRMGT_SLAVE_DEVICE6_ADDRESS 00"
            puts $QSF_FILE "set_global_assignment -name PWRMGT_SLAVE_DEVICE7_ADDRESS 00"
            puts $QSF_FILE "set_global_assignment -name PWRMGT_TRANSLATED_VOLTAGE_VALUE_UNIT VOLTS"
            puts $QSF_FILE "set_global_assignment -name PWRMGT_PAGE_COMMAND_ENABLE OFF"
            puts $QSF_FILE "set_global_assignment -name PWRMGT_LINEAR_FORMAT_N \"-12\""
            puts $QSF_FILE "set_global_assignment -name PWRMGT_VOLTAGE_OUTPUT_FORMAT \"LINEAR FORMAT\""
            puts $QSF_FILE "set_global_assignment -name MESSAGE_DISABLE 14320 -entity pcie_ss_ed"
            # puts $QSF_FILE "set_global_assignment -name STRATIXV_CONFIGURATION_SCHEME \"ACTIVE SERIAL X4\""
            # puts $QSF_FILE "set_global_assignment -name DEVICE_INITIALIZATION_CLOCK OSC_CLK_1_125MHZ"
            # puts $QSF_FILE "set_global_assignment -name ERROR_CHECK_FREQUENCY_DIVISOR 1"
            puts $QSF_FILE "set_global_assignment -name POWER_APPLY_THERMAL_MARGIN ADDITIONAL"
            puts $QSF_FILE "set_global_assignment -name BOARD default"
            puts $QSF_FILE "set_global_assignment -name VERILOG_INPUT_VERSION SYSTEMVERILOG_2012"
        } elseif {$devkit_type == "R-Tile" && [regexp "Production" $devkit_name]} {
            puts $QSF_FILE "set_global_assignment -name USE_CONF_DONE SDM_IO16"
            puts $QSF_FILE "set_global_assignment -name VID_OPERATION_MODE \"PMBUS MASTER\""
            puts $QSF_FILE "set_global_assignment -name USE_PWRMGT_SCL SDM_IO0"
            puts $QSF_FILE "set_global_assignment -name USE_PWRMGT_SDA SDM_IO12"
            puts $QSF_FILE "set_global_assignment -name PWRMGT_BUS_SPEED_MODE \"100 KHZ\""
            puts $QSF_FILE "set_global_assignment -name PWRMGT_SLAVE_DEVICE_TYPE OTHER"
            puts $QSF_FILE "set_global_assignment -name PWRMGT_SLAVE_DEVICE0_ADDRESS 47"
            puts $QSF_FILE "set_global_assignment -name PWRMGT_SLAVE_DEVICE1_ADDRESS 00"
            puts $QSF_FILE "set_global_assignment -name PWRMGT_SLAVE_DEVICE2_ADDRESS 00"
            puts $QSF_FILE "set_global_assignment -name PWRMGT_SLAVE_DEVICE3_ADDRESS 00"
            puts $QSF_FILE "set_global_assignment -name PWRMGT_SLAVE_DEVICE4_ADDRESS 00"
            puts $QSF_FILE "set_global_assignment -name PWRMGT_SLAVE_DEVICE5_ADDRESS 00"
            puts $QSF_FILE "set_global_assignment -name PWRMGT_SLAVE_DEVICE6_ADDRESS 00"
            puts $QSF_FILE "set_global_assignment -name PWRMGT_SLAVE_DEVICE7_ADDRESS 00"
            puts $QSF_FILE "set_global_assignment -name PWRMGT_TRANSLATED_VOLTAGE_VALUE_UNIT VOLTS"
            puts $QSF_FILE "set_global_assignment -name PWRMGT_PAGE_COMMAND_ENABLE OFF"
            puts $QSF_FILE "set_global_assignment -name PWRMGT_LINEAR_FORMAT_N \"-12\""
            puts $QSF_FILE "set_global_assignment -name PWRMGT_VOLTAGE_OUTPUT_FORMAT \"LINEAR FORMAT\""
            puts $QSF_FILE "set_global_assignment -name MESSAGE_DISABLE 14320 -entity pcie_ss_ed"
            # puts $QSF_FILE "set_global_assignment -name STRATIXV_CONFIGURATION_SCHEME \"ACTIVE SERIAL X4\""
            # puts $QSF_FILE "set_global_assignment -name DEVICE_INITIALIZATION_CLOCK OSC_CLK_1_125MHZ"
            # puts $QSF_FILE "set_global_assignment -name ERROR_CHECK_FREQUENCY_DIVISOR 1"
            puts $QSF_FILE "set_global_assignment -name POWER_APPLY_THERMAL_MARGIN ADDITIONAL"
            puts $QSF_FILE "set_global_assignment -name BOARD default"
            puts $QSF_FILE "set_global_assignment -name VERILOG_INPUT_VERSION SYSTEMVERILOG_2012"
        } elseif {$devkit_type == "P-Tile"} {
            puts $QSF_FILE "set_global_assignment -name USE_CONF_DONE SDM_IO16"
            puts $QSF_FILE "set_global_assignment -name USE_INIT_DONE SDM_IO0"
            puts $QSF_FILE "set_global_assignment -name USE_CVP_CONFDONE SDM_IO10"
            puts $QSF_FILE "set_global_assignment -name VID_OPERATION_MODE \"PMBUS MASTER\""
            puts $QSF_FILE "set_global_assignment -name USE_PWRMGT_SCL SDM_IO14"
            puts $QSF_FILE "set_global_assignment -name USE_PWRMGT_SDA SDM_IO11"
            puts $QSF_FILE "set_global_assignment -name PWRMGT_BUS_SPEED_MODE \"100 KHZ\""
            puts $QSF_FILE "set_global_assignment -name PWRMGT_SLAVE_DEVICE_TYPE OTHER"
            puts $QSF_FILE "set_global_assignment -name PWRMGT_SLAVE_DEVICE0_ADDRESS 47"
            puts $QSF_FILE "set_global_assignment -name PWRMGT_SLAVE_DEVICE1_ADDRESS 00"
            puts $QSF_FILE "set_global_assignment -name PWRMGT_SLAVE_DEVICE2_ADDRESS 00"
            puts $QSF_FILE "set_global_assignment -name PWRMGT_SLAVE_DEVICE3_ADDRESS 00"
            puts $QSF_FILE "set_global_assignment -name PWRMGT_SLAVE_DEVICE4_ADDRESS 00"
            puts $QSF_FILE "set_global_assignment -name PWRMGT_SLAVE_DEVICE5_ADDRESS 00"
            puts $QSF_FILE "set_global_assignment -name PWRMGT_SLAVE_DEVICE6_ADDRESS 00"
            puts $QSF_FILE "set_global_assignment -name PWRMGT_SLAVE_DEVICE7_ADDRESS 00"
            puts $QSF_FILE "set_global_assignment -name PWRMGT_TRANSLATED_VOLTAGE_VALUE_UNIT VOLTS"
            puts $QSF_FILE "set_global_assignment -name PWRMGT_PAGE_COMMAND_ENABLE OFF"
            puts $QSF_FILE "set_global_assignment -name PWRMGT_LINEAR_FORMAT_N \"-13\""
            puts $QSF_FILE "set_global_assignment -name PWRMGT_VOLTAGE_OUTPUT_FORMAT \"LINEAR FORMAT\""
            puts $QSF_FILE "set_global_assignment -name STRATIXV_CONFIGURATION_SCHEME \"ACTIVE SERIAL X4\""
            puts $QSF_FILE "set_global_assignment -name ACTIVE_SERIAL_CLOCK AS_FREQ_115MHZ_IOSC"
            puts $QSF_FILE "set_global_assignment -name ERROR_CHECK_FREQUENCY_DIVISOR 1"
            puts $QSF_FILE "set_global_assignment -name POWER_APPLY_THERMAL_MARGIN ADDITIONAL"
            puts $QSF_FILE "set_global_assignment -name BOARD default"
            puts $QSF_FILE "set_global_assignment -name OPTIMIZATION_MODE \"SUPERIOR PERFORMANCE WITH MAXIMUM PLACEMENT EFFORT\""
            puts $QSF_FILE "set_global_assignment -name FAST_PRESERVE AUTO -entity pcie_ss_ed"
        } elseif {$devkit_type == "F-Tile"} {
            puts $QSF_FILE "set_global_assignment -name STRATIXV_CONFIGURATION_SCHEME \"ACTIVE SERIAL X4\""
            puts $QSF_FILE "set_global_assignment -name PWRMGT_SLAVE_DEVICE_TYPE LTC3888"
            puts $QSF_FILE "set_global_assignment -name PWRMGT_SLAVE_DEVICE0_ADDRESS 55"
            puts $QSF_FILE "set_global_assignment -name PWRMGT_VOLTAGE_OUTPUT_FORMAT \"LINEAR FORMAT\""
            puts $QSF_FILE "set_global_assignment -name PWRMGT_LINEAR_FORMAT_N \"-12\""
            puts $QSF_FILE "set_global_assignment -name PWRMGT_PAGE_COMMAND_ENABLE ON"
            puts $QSF_FILE "set_global_assignment -name PWRMGT_PAGE_COMMAND_PAYLOAD 0"
            puts $QSF_FILE "set_global_assignment -name USE_PWRMGT_SCL SDM_IO0"
            puts $QSF_FILE "set_global_assignment -name USE_PWRMGT_SDA SDM_IO11"
            puts $QSF_FILE "set_global_assignment -name USE_CONF_DONE SDM_IO16"
            puts $QSF_FILE "set_global_assignment -name USE_INIT_DONE SDM_IO13"
            puts $QSF_FILE "set_global_assignment -name USE_CVP_CONFDONE SDM_IO14"
            puts $QSF_FILE "set_global_assignment -name USE_NCATTRIP SDM_IO12"
            puts $QSF_FILE "set_global_assignment -name USE_HPS_COLD_RESET SDM_IO10"
            # puts $QSF_FILE "set_global_assignment -name ACTIVE_SERIAL_CLOCK AS_FREQ_115MHZ_IOSC"
            puts $QSF_FILE "set_global_assignment -name DEVICE_INITIALIZATION_CLOCK OSC_CLK_1_125MHZ"
            puts $QSF_FILE "set_global_assignment -name GENERATE_COMPRESSED_SOF ON"
            # puts $QSF_FILE "set_global_assignment -name PRESERVE_UNUSED_XCVR_CHANNEL ON"
        } else {
            puts $QSF_FILE "set_global_assignment -name USE_CONF_DONE SDM_IO16"
            puts $QSF_FILE "set_global_assignment -name USE_PWRMGT_SCL SDM_IO0"
            puts $QSF_FILE "set_global_assignment -name USE_PWRMGT_SDA SDM_IO12"
            puts $QSF_FILE "set_global_assignment -name VID_OPERATION_MODE \"PMBUS MASTER\""
            puts $QSF_FILE "set_global_assignment -name PWRMGT_BUS_SPEED_MODE \"100 KHZ\""
            puts $QSF_FILE "set_global_assignment -name PWRMGT_SLAVE_DEVICE_TYPE ED8401"
            puts $QSF_FILE "set_global_assignment -name PWRMGT_SLAVE_DEVICE0_ADDRESS 49"
            puts $QSF_FILE "set_global_assignment -name PWRMGT_SLAVE_DEVICE1_ADDRESS 00"
            puts $QSF_FILE "set_global_assignment -name PWRMGT_SLAVE_DEVICE2_ADDRESS 00"
            puts $QSF_FILE "set_global_assignment -name PWRMGT_SLAVE_DEVICE3_ADDRESS 00"
            puts $QSF_FILE "set_global_assignment -name PWRMGT_SLAVE_DEVICE4_ADDRESS 00"
            puts $QSF_FILE "set_global_assignment -name PWRMGT_SLAVE_DEVICE5_ADDRESS 00"
            puts $QSF_FILE "set_global_assignment -name PWRMGT_SLAVE_DEVICE6_ADDRESS 00"
            puts $QSF_FILE "set_global_assignment -name PWRMGT_SLAVE_DEVICE7_ADDRESS 00"
            puts $QSF_FILE "set_global_assignment -name PWRMGT_PAGE_COMMAND_ENABLE OFF"
            puts $QSF_FILE "set_global_assignment -name PWRMGT_VOLTAGE_OUTPUT_FORMAT \"LINEAR FORMAT\""
            puts $QSF_FILE "set_global_assignment -name AUTO_RESTART_CONFIGURATION OFF"
            puts $QSF_FILE "set_global_assignment -name STRATIXV_CONFIGURATION_SCHEME \"AVST X8\""
            puts $QSF_FILE "set_global_assignment -name PWRMGT_LINEAR_FORMAT_N \"-13\""
            puts $QSF_FILE "set_global_assignment -name DEVICE_INITIALIZATION_CLOCK OSC_CLK_1_125MHZ"
            puts $QSF_FILE "set_global_assignment -name PWRMGT_DIRECT_FORMAT_COEFFICIENT_M 1"
            puts $QSF_FILE "set_global_assignment -name PWRMGT_DIRECT_FORMAT_COEFFICIENT_R 0"
            puts $QSF_FILE "set_global_assignment -name PWRMGT_TRANSLATED_VOLTAGE_VALUE_UNIT VOLTS"
            puts $QSF_FILE "set_global_assignment -name OPTIMIZATION_MODE \"HIGH PERFORMANCE EFFORT\""
        }
        
        #HSD: 14022985966
        if {$tile_name == "F-TILE"} {
            puts $QSF_FILE "set_global_assignment -name EDA_EXDES_CUSTOM_SIM_SCRIPT_VCS ./pcie_ss_ed_sim_tb/pcie_ss_ed_sim_tb/sim/synopsys/vcs/run_vcs.sh -section_id eda_simulation"
            puts $QSF_FILE "set_global_assignment -name EDA_EXDES_CUSTOM_SIM_SCRIPT_VCSMX ./pcie_ss_ed_sim_tb/pcie_ss_ed_sim_tb/sim/synopsys/vcsmx/run_vcsmx.sh -section_id eda_simulation"
            puts $QSF_FILE "set_global_assignment -name EDA_EXDES_CUSTOM_SIM_SCRIPT_XCELIUM ./pcie_ss_ed_sim_tb/pcie_ss_ed_sim_tb/sim/xcelium/run_xcelium.sh -section_id eda_simulation"
            puts $QSF_FILE "set_global_assignment -name EDA_EXDES_CUSTOM_SIM_SCRIPT_QUESTA ./pcie_ss_ed_sim_tb/pcie_ss_ed_sim_tb/sim/mentor/run_msim.tcl -section_id eda_simulation"
            puts $QSF_FILE "set_global_assignment -name EDA_EXDES_CUSTOM_SIM_SCRIPT_RIVIERAPRO ./pcie_ss_ed_sim_tb/pcie_ss_ed_sim_tb/sim/aldec/run_riviera.tcl -section_id eda_simulation"
            puts $QSF_FILE ""
        } elseif {$tile_name == "R-TILE"} {
            puts $QSF_FILE "set_global_assignment -name EDA_EXDES_CUSTOM_SIM_SCRIPT_VCS ./pcie_ss_ed_sim_tb/pcie_ss_ed_sim_tb/sim/synopsys/vcs/run_vcs.sh -section_id eda_simulation"
            puts $QSF_FILE "set_global_assignment -name EDA_EXDES_CUSTOM_SIM_SCRIPT_VCSMX ./pcie_ss_ed_sim_tb/pcie_ss_ed_sim_tb/sim/synopsys/vcsmx/run_vcsmx.sh -section_id eda_simulation"
            puts $QSF_FILE "set_global_assignment -name EDA_EXDES_CUSTOM_SIM_SCRIPT_XCELIUM ./pcie_ss_ed_sim_tb/pcie_ss_ed_sim_tb/sim/xcelium/run_xcelium.sh -section_id eda_simulation"
            puts $QSF_FILE "set_global_assignment -name EDA_EXDES_CUSTOM_SIM_SCRIPT_QUESTA ./pcie_ss_ed_sim_tb/pcie_ss_ed_sim_tb/sim/mentor/run_msim.tcl -section_id eda_simulation"
            puts $QSF_FILE "set_global_assignment -name EDA_EXDES_CUSTOM_SIM_SCRIPT_RIVIERAPRO ./pcie_ss_ed_sim_tb/pcie_ss_ed_sim_tb/sim/aldec/run_riviera.tcl -section_id eda_simulation"
        } else { 
            #P-Tile
            puts $QSF_FILE "set_global_assignment -name EDA_EXDES_CUSTOM_SIM_SCRIPT_VCS ./pcie_ss_ed_sim_tb/pcie_ss_ed_sim_tb/sim/synopsys/vcs/run_vcs.sh -section_id eda_simulation"
            puts $QSF_FILE "set_global_assignment -name EDA_EXDES_CUSTOM_SIM_SCRIPT_VCSMX ./pcie_ss_ed_sim_tb/pcie_ss_ed_sim_tb/sim/synopsys/vcsmx/run_vcsmx.sh -section_id eda_simulation"
            puts $QSF_FILE "set_global_assignment -name EDA_EXDES_CUSTOM_SIM_SCRIPT_QUESTA ./pcie_ss_ed_sim_tb/pcie_ss_ed_sim_tb/sim/mentor/run_msim.tcl -section_id eda_simulation"
            puts $QSF_FILE "set_global_assignment -name EDA_EXDES_CUSTOM_SIM_SCRIPT_RIVIERAPRO ./pcie_ss_ed_sim_tb/pcie_ss_ed_sim_tb/sim/aldec/run_riviera.tcl -section_id eda_simulation"
        }

        close $QSF_FILE

        return


    }
    


    proc ::intel_pcie_ss_axi::example::filetype { file_name } {
        switch -glob $file_name {
            *.vhd {     return VHDL}
            *.v {       return VERILOG}
            *.sv {      return SYSTEM_VERILOG}
            *.svo {     return SYSTEM_VERILOG}
            *.vho {     return VHDL}
            *.vo {      return VERILOG}
            default {   return OTHER }
        }
    }

    proc ::intel_pcie_ss_axi::example::folder_worker { item } {
        foreach top_item [glob -nocomplain -directory [file join [pwd] $item] -tails *] {
            set relative_item [file join $item $top_item]
            set absolute_path [file join [pwd] $relative_item]
            if {[file isdirectory $relative_item] == 1 } {
                ::intel_pcie_ss_axi::example::folder_worker $relative_item
            } else {
                add_fileset_file $relative_item [ ::intel_pcie_ss_axi::example::filetype $absolute_path ] PATH $absolute_path
                send_message info "adding $relative_item "
            }
        }
    }


    proc ::intel_pcie_ss_axi::example::add_files_recursive { root } {
        set old_path [pwd]
        cd $root
        foreach top_item [glob -nocomplain -directory [pwd]  -tails *] {
            set absolute_path [file join [pwd] $top_item]
            if {[file isdirectory $top_item] == 1 } {
                ::intel_pcie_ss_axi::example::folder_worker $top_item
            } else {
                add_fileset_file $top_item [ ::intel_pcie_ss_axi::example::filetype $absolute_path ] PATH $absolute_path
                send_message info "adding $top_item "
            }
        }
        cd $old_path
    }
}

proc searchFiles { root pattern } {

    set root [string trimright [file join [file normalize $root] { }]]
    set fileList {}
    set fileList [concat $fileList [glob -nocomplain -type {f r} -path $root $pattern]];

    set subDir [glob -nocomplain -type {d  r} -path $root *]

    foreach dirName $subDir {
	set fileList [concat $fileList [searchFiles $dirName $pattern]];
    }
    return $fileList
 }

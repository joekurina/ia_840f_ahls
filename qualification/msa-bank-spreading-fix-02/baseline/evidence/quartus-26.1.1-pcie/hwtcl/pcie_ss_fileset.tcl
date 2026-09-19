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


package provide intel_pcie_ss_axi::fileset 19.1
package require intel_pcie_ss_axi::parameters

package require altera_terp
package require alt_xcvr::ip_tcl::ip_module

namespace eval ::intel_pcie_ss_axi::fileset:: {
    namespace import ::alt_xcvr::ip_tcl::ip_module::*
    namespace export \
    declare_filesets

    variable filesets
    variable example_design_fileset


     set filesets {\
        { NAME              TYPE                CALLBACK                                       TOP_LEVEL         }\
        { quartus_synth     QUARTUS_SYNTH       ::intel_pcie_ss_axi::fileset::callback_quartus_synth          }\
        { sim_verilog       SIM_VERILOG         ::intel_pcie_ss_axi::fileset::callback_sim_verilog            }\
        { sim_vhdl          SIM_VHDL            ::intel_pcie_ss_axi::fileset::callback_sim_vhdl               }\
      }

   
    # TODO - example design
    set example_design_fileset {\
       { NAME                  TYPE                CALLBACK                                                        }\
       { example_design        EXAMPLE_DESIGN      ::intel_pcie_ss_axi::fileset::callback_example_design        }\
    }

    proc ::intel_pcie_ss_axi::fileset::declare_filesets {} {
        variable example_design_fileset
        variable filesets
        # declare_tb_partner  - set through parameters.tcl setup_testbench proc
        ip_declare_filesets $filesets
        ip_declare_filesets $example_design_fileset
    }

    proc ::intel_pcie_ss_axi::fileset::add_qhip_ptile {} {
    variable qhip_instance_name
         
        # TODO: add conditioning when user choose avmm ptile
        # pcie_ptile_avmm instantiation
        ##### Create pcie_ptile_avmm instance #####
        
        # pcie_ptile_avst instantiation
        ##### Create pcie_ptile_avst instance #####

        #set device_family [ip_get "parameter.device_family.value"]
        #set device_die_types [ip_get "parameter.device_die_types.value"]
        #set device_die_revisions [ip_get "parameter.device_die_revisions.value"]
        set tile [ip_get "parameter.TILE.value"]
        if {$tile == "P-TILE"} {
            set qhip "intel_pcie_ptile_ast"
            set version_num "11.*.*"
	    set qhip_instance_name "intel_pcie_ptile_ast_qhip"

        } elseif {$tile == "F-TILE"} {
            set qhip "pcie_avst_f"
            set version_num "13.*.*"
	    set qhip_instance_name "intel_pcie_ftile_ast_qhip"

        
        } elseif {$tile == "R-TILE"} {
            set qhip "intel_rtile_pcie_ast"
            set version_num "13.*.*"
	    set qhip_instance_name "intel_pcie_rtile_ast_qhip"

        }

            # TODO: Instantiate systempll
	    #parse system info to qhip

        	set device_family [ip_get "parameter.device_family.value"]
       	 	set speed_grade [ip_get "parameter.speed_grade.value"]
       	 	set base_device [ip_get "parameter.base_device.value"]
        	set part_trait_device [ip_get "parameter.part_trait_device.value"]
        	set device [ip_get "parameter.device.value"]
        	set device_die_types [ip_get "parameter.device_die_types.value"]
        	set device_die_revisions [ip_get "parameter.device_die_revisions.value"]
        if {$tile == "F-TILE"} {       	  
            set enable_syspll [ip_get "parameter.syspll_enabled_hwtcl.value"]
             #if {$enable_syspll == 1} {
        	    add_hdl_instance ftile_syspll systemclk_f 4.*.*
        
        	    set_instance_parameter_value ftile_syspll "device" $device
          	    set_instance_parameter_value ftile_syspll "device_die_types" $device_die_types
          	    set_instance_parameter_value ftile_syspll "device_die_revisions" $device_die_revisions
        	    set top_topology_hwtcl [ip_get "parameter.top_topology_hwtcl.value"]
            	    set pld_clkfreq_integer_hwtcl [ip_get "parameter.pld_clkfreq_integer_hwtcl.value"]
        	    set adapter_type_hwtcl [ip_get "parameter.adapter_type_hwtcl.value"]
        		#refclk for SystemPLL enablement
                	#set enable_pcie_independent_refclk_syspll_hwtcl   [ip_get "parameter.enable_pcie_independent_refclk_syspll_hwtcl.value"]
        
        		#if { $enable_pcie_independent_refclk_syspll_hwtcl ==1 } {
        	        #set_instance_parameter_value ftile_syspll syspll_refclk_src_0 "RefClk #0"
              		#} else {
               	    set_instance_parameter_value ftile_syspll "syspll_refclk_src_0" "RefClk #3"
                	#}
        		
                    if {$pld_clkfreq_integer_hwtcl == 500} {
                      set_instance_parameter_value ftile_syspll syspll_mod_0 "PCIE_FREQ_1000"
                    } elseif {$pld_clkfreq_integer_hwtcl == 450} {
                      set_instance_parameter_value ftile_syspll syspll_mod_0 "PCIE_FREQ_900"
                    } elseif {$pld_clkfreq_integer_hwtcl == 400} {
                      set_instance_parameter_value ftile_syspll syspll_mod_0 "PCIE_FREQ_800"
                    } elseif {$pld_clkfreq_integer_hwtcl == 350} {
                      set_instance_parameter_value ftile_syspll syspll_mod_0 "PCIE_FREQ_700"
                    } elseif {$pld_clkfreq_integer_hwtcl == 250} {
                      set_instance_parameter_value ftile_syspll syspll_mod_0 "PCIE_FREQ_500"
                    }
            
            	    set_instance_parameter_value ftile_syspll refclk_fgt_output_enable_3 1 
                    set_instance_parameter_value ftile_syspll refclk_fgt_output_enable_5 1
                    set_instance_parameter_value ftile_syspll refclk_fgt_freq_mhz_3 100.000000
                    set_instance_parameter_value ftile_syspll refclk_fgt_freq_mhz_5 100.000000
                    if {[regexp "4x4" $top_topology_hwtcl]} {
                    set_instance_parameter_value ftile_syspll refclk_fgt_output_enable_1 1 
                    set_instance_parameter_value ftile_syspll refclk_fgt_output_enable_7 1
                    set_instance_parameter_value ftile_syspll refclk_fgt_freq_mhz_1 100.000000
                    set_instance_parameter_value ftile_syspll refclk_fgt_freq_mhz_7 100.000000
                    }
                
                    #if {$enable_pcie_independent_refclk_syspll_hwtcl == 1} {
                    #  set_instance_parameter_value ftile_syspll refclk_fgt_freq_mhz_0 100.000000
                    #}
                    #adding the connections between System PLL and Ftile according to mega ip formation 
    
    
            #}
        }

	
        add_hdl_instance $qhip_instance_name $qhip $version_num

               
        #parsing qhip_param dict set from the subsystem parameters
        global qhip_param
        dict_cleanup
                
        foreach {param2 val2} $qhip_param {
            set_instance_parameter_value $qhip_instance_name $param2 $val2
            
        }

        #parse system info to qhip

        set device_family [ip_get "parameter.device_family.value"]
        set speed_grade [ip_get "parameter.speed_grade.value"]
        set base_device [ip_get "parameter.base_device.value"]
        set part_trait_device [ip_get "parameter.part_trait_device.value"]
        set device [ip_get "parameter.device.value"]
        set device_die_types [ip_get "parameter.device_die_types.value"]
        set device_die_revisions [ip_get "parameter.device_die_revisions.value"]

        set_instance_parameter_value $qhip_instance_name "device_family" $device_family
        if {$tile =="P-TILE" || $tile == "F-TILE"} {
        set_instance_parameter_value $qhip_instance_name "speed_grade" $speed_grade
        }
        set_instance_parameter_value $qhip_instance_name "base_device" $base_device        
        set_instance_parameter_value $qhip_instance_name "part_trait_device" $part_trait_device
        set_instance_parameter_value $qhip_instance_name "device" $device
        set_instance_parameter_value $qhip_instance_name "device_die_types" $device_die_types
        set_instance_parameter_value $qhip_instance_name "device_die_revisions" $device_die_revisions
       
        # Uniquify instance
        set_instance_property $qhip_instance_name HDLINSTANCE_USE_GENERATED_NAME 1 
    }

    proc ::intel_pcie_ss_axi::fileset::declare_tb_partner {} {
        set_module_assignment testbench.partner.pcie_tb.class  intel_rtile_pcie_tbed
        set_module_assignment testbench.partner.pcie_tb.version "1.0.0"
        set_module_assignment testbench.partner.map.hip_serial pcie_tb.hip_serial
    }
    
    proc ::intel_pcie_ss_axi::fileset::callback_quartus_synth {output_name} {
    	set TEMPPATH [create_temp_file ""]
        ::intel_pcie_ss_axi::fileset::fileset_preprocess $output_name "synth"
		::intel_pcie_ss_axi::fileset::pcie_ss_sdc_handling
		::intel_pcie_ss_axi::fileset::generate_mif_file $TEMPPATH
    }

    proc ::intel_pcie_ss_axi::fileset::callback_sim_verilog {output_name} {
    	set TEMPPATH [create_temp_file ""]
        ::intel_pcie_ss_axi::fileset::fileset_preprocess $output_name "sim"
        ::intel_pcie_ss_axi::fileset::generate_mif_file_for_sim $TEMPPATH
    }

    proc ::intel_pcie_ss_axi::fileset::callback_sim_vhdl {output_name} {
    	set TEMPPATH [create_temp_file ""]
        ::intel_pcie_ss_axi::fileset::fileset_preprocess $output_name "sim"
        ::intel_pcie_ss_axi::fileset::generate_mif_file_for_sim $TEMPPATH
    }

    # TODO - example design
    #proc ::intel_pcie_ss_axi::fileset::callback_example_design {ip_name} {
    #    ::intel_pcie_ss_axi::dynamic_example_design
    #}

    proc ::intel_pcie_ss_axi::fileset::pcie_ss_sdc_handling {} {
        #   SDC handling
        global env
        variable ss_profile_parameters
        variable ss_mapped_integer_parameters
        variable pcie_link_parameters
        
        set QUARTUS_ROOTDIR $env(QUARTUS_ROOTDIR)
        set top_topology                        [get_parameter_value top_topology_hwtcl]
        set virtual_rp_ep_mode                  [ ip_get "parameter.virtual_rp_ep_mode_hwtcl.value" ]
        set device_family_hwtcl                 [ ip_get "parameter.device_family.value" ]
        set core16_axi_lite_clk_freq_value      [ ip_get "parameter.core16_axi_lite_clk_freq_user_hwtcl.value" ]
        set core8_axi_lite_clk_freq_value       [ ip_get "parameter.core8_axi_lite_clk_freq_user_hwtcl.value" ]
        set core4_0_axi_lite_clk_freq_value     [ ip_get "parameter.core4_0_axi_lite_clk_freq_user_hwtcl.value" ]
        set core4_1_axi_lite_clk_freq_value     [ ip_get "parameter.core4_1_axi_lite_clk_freq_user_hwtcl.value" ]
        set core16_axi_st_clk_freq_value        [ ip_get "parameter.core16_axi_st_clk_freq_user_integer_hwtcl.value" ]
        set core8_axi_st_clk_freq_value         [ ip_get "parameter.core8_axi_st_clk_freq_user_integer_hwtcl.value" ]
        set core4_0_axi_st_clk_freq_value       [ ip_get "parameter.core4_0_axi_st_clk_freq_user_integer_hwtcl.value" ]
        set core4_1_axi_st_clk_freq_value       [ ip_get "parameter.core4_1_axi_st_clk_freq_user_integer_hwtcl.value" ]
        #set ptile_debug_toolkit_hwtcl           [ ip_get "parameter.ptile_debug_toolkit_hwtcl.value" ]
	set TILE 			        [ip_get "parameter.TILE.value"]
        if {$TILE == "P-TILE"} {
		set debug_toolkit_hwtcl   [ ip_get "parameter.ptile_debug_toolkit_hwtcl.value" ]
	
	} elseif {$TILE == "F-TILE"} {
		set debug_toolkit_hwtcl   [ ip_get "parameter.ftile_debug_toolkit_hwtcl.value" ]
   
    } elseif {$TILE == "R-TILE"} {
		set debug_toolkit_hwtcl   [ ip_get "parameter.rtile_debug_toolkit_hwtcl.value" ]

	}
        set pcie_ss_func_mode                    [ip_get "parameter.pcie_ss_func_mode_hwtcl.value"]


        set params(device_family)                       [get_parameter_value device_family]
        set params(top_topology)                        $top_topology
        set params(virtual_rp_ep_mode)                  $virtual_rp_ep_mode
        set params(core16_axi_lite_source_freq_hwtcl)   $core16_axi_lite_clk_freq_value
        set params(core8_axi_lite_source_freq_hwtcl)    $core8_axi_lite_clk_freq_value
        set params(core4_0_axi_lite_source_freq_hwtcl)  $core4_0_axi_lite_clk_freq_value
        set params(core4_1_axi_lite_source_freq_hwtcl)  $core4_1_axi_lite_clk_freq_value
        set params(core16_axi_st_source_freq_hwtcl)     $core16_axi_st_clk_freq_value
        set params(core8_axi_st_source_freq_hwtcl)      $core8_axi_st_clk_freq_value
        set params(core4_0_axi_st_source_freq_hwtcl)    $core4_0_axi_st_clk_freq_value
        set params(core4_1_axi_st_source_freq_hwtcl)    $core4_1_axi_st_clk_freq_value
        set params(debug_toolkit_en)                    $debug_toolkit_hwtcl
        set params(pcie_ss_func_mode)                   $pcie_ss_func_mode
    	set params(TILE)			        $TILE

        set template_file        "${QUARTUS_ROOTDIR}/../ip/altera/subsystems/intel_pcie_ss_axi/rtl/pcie_ss.sdc.terp"
        set template [ read [ open $template_file r ] ]
        set result   [ altera_terp $template params ]
	    add_fileset_file pcie_ss.sdc SDC_ENTITY TEXT $result {NO_SDC_PROMOTION} 
    }

    proc ::intel_pcie_ss_axi::fileset::fileset_preprocess {module_name fileset_type} {   
	 

        global env

        set QUARTUS_ROOTDIR $env(QUARTUS_ROOTDIR)
	variable qhip_instance_name
        variable ss_profile_parameters
        set pcie_ss_func_mode_value [ip_get "parameter.pcie_ss_func_mode_hwtcl.value"]
        
        set QUARTUS_ROOTDIR $env(QUARTUS_ROOTDIR)
        
        if {[regexp "sim" $fileset_type]} {
            set verilog_type "VERILOG_ENCRYPT"
            set system_verilog_type "SYSTEM_VERILOG_ENCRYPT"
            set rtl_file_path {
                "rtl/intelfpga"
            }
        } else {
            set verilog_type "VERILOG"
            set system_verilog_type "SYSTEMVERILOG"               
            set rtl_file_path "rtl"
        }

        
        set output_filename $module_name
        set qhip_instance_name_name  [get_instance_property $qhip_instance_name HDLINSTANCE_GET_GENERATED_NAME]
        set tile [ip_get "parameter.TILE.value"]
        if {$tile =="P-TILE" || $tile =="F-TILE"} {
        set template_file "${QUARTUS_ROOTDIR}/../ip/altera/subsystems/intel_pcie_ss_axi/rtl/ptile_pciess_top.sv.terp"
        } elseif {$tile == "R-TILE"} {
        set template_file "${QUARTUS_ROOTDIR}/../ip/altera/subsystems/intel_pcie_ss_axi/rtl/intel_pciess_rtile.sv.terp"
        }
        set rtile_debug_toolkit_hwtcl                     [ip_get "parameter.rtile_debug_toolkit_hwtcl.value"]
        set core16_virtual_ptm_hwtcl                      [ip_get "parameter.core16_virtual_ptm_hwtcl.value"]
        set core8_virtual_ptm_hwtcl                       [ip_get "parameter.core8_virtual_ptm_hwtcl.value"]
        set device_type_hwtcl                             [ip_get "parameter.device_type.value"]
        set hssi_ctr_is_cvp_enable_hwtcl                  [ip_get "parameter.hssi_ctr_is_cvp_enable_hwtcl.value"]
        set core16_cii_en_hwtcl                           [ip_get "parameter.core16_cii_en_hwtcl.value"]
        set core8_cii_en_hwtcl                            [ip_get "parameter.core8_cii_en_hwtcl.value"]
        set core4_0_cii_en_hwtcl                          [ip_get "parameter.core4_0_cii_en_hwtcl.value"]
        set core4_1_cii_en_hwtcl                          [ip_get "parameter.core4_1_cii_en_hwtcl.value"]
        set template [ read [ open $template_file r ] ]
        set params(output_name) $output_filename   
        set params(rtile_debug_toolkit_hwtcl) $rtile_debug_toolkit_hwtcl   
        set params(core16_virtual_ptm_hwtcl) $core16_virtual_ptm_hwtcl
        set params(core8_virtual_ptm_hwtcl) $core8_virtual_ptm_hwtcl   
        set params(device_type_hwtcl) $device_type_hwtcl   
        set params(hssi_ctr_is_cvp_enable_hwtcl) $hssi_ctr_is_cvp_enable_hwtcl   
        set params(core16_cii_en_hwtcl) $core16_cii_en_hwtcl   
        set params(core8_cii_en_hwtcl) $core8_cii_en_hwtcl   
        set params(core4_0_cii_en_hwtcl) $core4_0_cii_en_hwtcl   
        set params(core4_1_cii_en_hwtcl) $core4_1_cii_en_hwtcl   
        set params(qhip_instance_name_name) $qhip_instance_name_name
        set result   [ altera_terp $template params]

        foreach file_path $rtl_file_path {
            set pciess_v_files_path [glob -directory ${QUARTUS_ROOTDIR}/../ip/altera/subsystems/intel_pcie_ss_axi/${file_path} *.v]
            set pciess_sv_files_path [glob -directory ${QUARTUS_ROOTDIR}/../ip/altera/subsystems/intel_pcie_ss_axi/${file_path} *.sv]
            set rtile_adapter_sv_files_path  [glob -directory ${QUARTUS_ROOTDIR}/../ip/altera/subsystems/intel_pcie_ss_axi/${file_path}/rtile_adapter *.sv]

            set hia_sv_files_path [glob -directory ${QUARTUS_ROOTDIR}/../ip/altera/subsystems/intel_pcie_ss_axi/${file_path}/hip_if_adaptor *.sv]
            set hia_v_files_path [glob -directory ${QUARTUS_ROOTDIR}/../ip/altera/subsystems/intel_pcie_ss_axi/${file_path}/hip_if_adaptor *.v]
            set lite_csr_path [glob -directory ${QUARTUS_ROOTDIR}/../ip/altera/subsystems/intel_pcie_ss_axi/${file_path}/lite_csr *.sv]

            set axilite2avmm_v_files_path [glob -directory ${QUARTUS_ROOTDIR}/../ip/altera/subsystems/intel_pcie_ss_axi/${file_path}/lite_csr/axilite2avmm *.v]
            set axilite2avmm_sv_files_path [glob -directory ${QUARTUS_ROOTDIR}/../ip/altera/subsystems/intel_pcie_ss_axi/${file_path}/lite_csr/axilite2avmm *.sv]

            set csr_v_files_path [glob -directory ${QUARTUS_ROOTDIR}/../ip/altera/subsystems/intel_pcie_ss_axi/${file_path}/lite_csr/csr *.v]
            
            set dm_v_files_path [glob -directory ${QUARTUS_ROOTDIR}/../ip/altera/subsystems/intel_pcie_ss_axi/${file_path}/data_mover *.v]
            set dm_sv_files_path [glob -directory ${QUARTUS_ROOTDIR}/../ip/altera/subsystems/intel_pcie_ss_axi/${file_path}/data_mover *.sv]

            set dm_cpl_reordering_v_files_path [glob -directory ${QUARTUS_ROOTDIR}/../ip/altera/subsystems/intel_pcie_ss_axi/${file_path}/data_mover/reordering *.v]
            set dm_cpl_reordering_sv_files_path [glob -directory ${QUARTUS_ROOTDIR}/../ip/altera/subsystems/intel_pcie_ss_axi/${file_path}/data_mover/reordering *.sv]

            set avmm2axi4lite_v_files_path [glob -directory ${QUARTUS_ROOTDIR}/../ip/altera/subsystems/intel_pcie_ss_axi/${file_path}/avmm2axi4lite *.v]
            set avmm2axi4lite_sv_files_path [glob -directory ${QUARTUS_ROOTDIR}/../ip/altera/subsystems/intel_pcie_ss_axi/${file_path}/avmm2axi4lite *.sv]

            switch $file_path {
                "rtl/intelfpga"  {set simulator ""
                                 set  sim_dir "intelfpga/"}
                "rtl"            {set simulator ""
                                 set  sim_dir ""}
            }
            
            add_fileset_file ${sim_dir}${output_filename}.sv  $system_verilog_type TEXT $result $simulator

            foreach path $pciess_v_files_path {
                set tmp [file split $path]
                set file_name [lindex $tmp end]
                set tile [ip_get "parameter.TILE.value"]
                if {$tile =="P-TILE" || $tile =="F-TILE"} {
                set matched [regexp "intel_pcie_ptile_ast" $file_name]
                } elseif {$tile == "R-TILE"} {
                set matched [regexp "intel_pcie_rtile_ast" $file_name]
                }
                if {!$matched} {
                    add_fileset_file ${sim_dir}${file_name} $verilog_type PATH $path $simulator
                }                
            }
            foreach path $pciess_sv_files_path {
                set tmp [file split $path]
                set file_name [lindex $tmp end]
                set matched [regexp "pciess_dm_top" $file_name]

                if {$matched} {
                    if {[regexp "Data Mover" $pcie_ss_func_mode_value]} {
                        add_fileset_file ${sim_dir}${file_name} $system_verilog_type PATH $path $simulator
                    }
                } else {
                    add_fileset_file ${sim_dir}${file_name} $system_verilog_type PATH $path $simulator
                }
            }
            ####rtile adapter  
			foreach path $rtile_adapter_sv_files_path {
                set tmp [file split $path]
                set dir_name [lindex $tmp end-1]
                set file_name [lindex $tmp end]
                add_fileset_file ${sim_dir}${dir_name}/${file_name} $system_verilog_type PATH $path $simulator
            }
            foreach path $hia_sv_files_path {
                set tmp [file split $path]
                set dir_name [lindex $tmp end-1]
                set file_name [lindex $tmp end]
                add_fileset_file ${sim_dir}${dir_name}/${file_name} $system_verilog_type PATH $path $simulator
            }
            foreach path $hia_v_files_path {
                set tmp [file split $path]
                set dir_name [lindex $tmp end-1]
                set file_name [lindex $tmp end]
                add_fileset_file ${sim_dir}${dir_name}/${file_name} $verilog_type PATH $path $simulator
            }
            foreach path $lite_csr_path {
                set tmp [file split $path]
                set dir_name [lindex $tmp end-1]
                set file_name [lindex $tmp end]
                add_fileset_file ${sim_dir}${dir_name}/${file_name} $system_verilog_type PATH $path $simulator
            }
            foreach path $axilite2avmm_v_files_path {
                set tmp [file split $path]
                set dir_name1 [lindex $tmp end-2]
                set dir_name2 [lindex $tmp end-1]
                set file_name [lindex $tmp end]
                add_fileset_file ${sim_dir}${dir_name1}/${dir_name2}/${file_name} $verilog_type PATH $path $simulator
            }
            foreach path $axilite2avmm_sv_files_path {
                set tmp [file split $path]
                set dir_name1 [lindex $tmp end-2]
                set dir_name2 [lindex $tmp end-1]
                set file_name [lindex $tmp end]
                add_fileset_file ${sim_dir}${dir_name1}/${dir_name2}/${file_name} $system_verilog_type PATH $path $simulator
            }
            foreach path $csr_v_files_path {
                set tmp [file split $path]
                set dir_name1 [lindex $tmp end-2]
                set dir_name2 [lindex $tmp end-1]
                set file_name [lindex $tmp end]
                add_fileset_file ${sim_dir}${dir_name1}/${dir_name2}/${file_name} $verilog_type PATH $path $simulator
            }

            foreach path $avmm2axi4lite_v_files_path {
                set tmp [file split $path]
                set dir_name [lindex $tmp end-1]
                set file_name [lindex $tmp end]
                add_fileset_file ${sim_dir}${dir_name}/${file_name} $verilog_type PATH $path $simulator
            }
            foreach path $avmm2axi4lite_sv_files_path {
                set tmp [file split $path]
                set dir_name [lindex $tmp end-1]
                set file_name [lindex $tmp end]
                add_fileset_file ${sim_dir}${dir_name}/${file_name} $system_verilog_type PATH $path $simulator
            }

            if {[regexp "Data Mover" $pcie_ss_func_mode_value]} {        
                foreach path $dm_v_files_path {
                    set tmp [file split $path]
                    set dir_name [lindex $tmp end-1]
                    set file_name [lindex $tmp end]
                    add_fileset_file ${sim_dir}${dir_name}/${file_name} $verilog_type PATH $path $simulator
                }
                foreach path $dm_sv_files_path {
                    set tmp [file split $path]
                    set dir_name [lindex $tmp end-1]
                    set file_name [lindex $tmp end]
                    add_fileset_file ${sim_dir}${dir_name}/${file_name} $system_verilog_type PATH $path $simulator
                }

                foreach path $dm_cpl_reordering_v_files_path {
                    set tmp [file split $path]
                    set dir_name1 [lindex $tmp end-2]
                    set dir_name2 [lindex $tmp end-1]
                    set file_name [lindex $tmp end]
                    add_fileset_file ${sim_dir}${dir_name1}/${dir_name2}/${file_name} $verilog_type PATH $path $simulator
                }
                foreach path $dm_cpl_reordering_sv_files_path {
                    set tmp [file split $path]
                    set dir_name1 [lindex $tmp end-2]
                    set dir_name2 [lindex $tmp end-1]
                    set file_name [lindex $tmp end]
                    add_fileset_file ${sim_dir}${dir_name1}/${dir_name2}/${file_name} $system_verilog_type PATH $path $simulator
                }
            }
        }
    }
    
    #MIF FILE GENERATION
	proc ::intel_pcie_ss_axi::fileset::generate_mif_file { TEMPPATH } {
	 
	  set core16_dfl_en_hwtcl_value  [ip_get "parameter.core16_dfl_en_hwtcl.value"]
	  set core8_dfl_en_hwtcl_value   [ip_get "parameter.core8_dfl_en_hwtcl.value"]

	  
	  if {$core16_dfl_en_hwtcl_value || $core8_dfl_en_hwtcl_value} {
		  send_message info "Generating Device Feature List Memory Initialization File (.mif)"
		# 
		  # set parameter_file_name "parameters.txt"
		  # set parameter_file_path "${TEMPPATH}${parameter_file_name}"
		# 
		  # set parameter_file [ open $parameter_file_path "w" ]
		  # set listOfparameter [ get_parameters ]
		  # foreach parameter $listOfparameter {
			# set param_value [ip_get "parameter.${parameter}.value"]
			# puts $parameter_file "${parameter}=${param_value}"
		  # }
		  # send_message info "parameter file at ${parameter_file_path}"
		  # close $parameter_file
		
		  generate_DFL_MIF_file $TEMPPATH
		
		  # uncomment if you would like to see the generated parameters.txt file
		  # add_fileset_file "sep/mif/${parameter_file_name}" OTHER PATH ${parameter_file_path}
		
		  #set MIF_generated_path [file join $TEMPPATH output]
		  #foreach item [glob -nocomplain -directory $MIF_generated_path  -tails *] {
			#set abs_path [file join $MIF_generated_path $item]
			#add_fileset_file "mif/${item}" OTHER PATH $abs_path
		  #}
	  	}
     
		#MIF FILE FOR ctrl shadow ram reset
		  generate_ctrl_shadow_ram_reset_MIF_file $TEMPPATH
		
		  set MIF_generated_path [file join $TEMPPATH output]
		  foreach item [glob -nocomplain -directory $MIF_generated_path  -tails *] {
			set abs_path [file join $MIF_generated_path $item]
			add_fileset_file "hip_if_adaptor/${item}" MIF PATH $abs_path
		  }

	
	  return
	}
	
	proc ::intel_pcie_ss_axi::fileset::generate_mif_file_for_sim { TEMPPATH } {
	  
	  set core16_dfl_en_hwtcl_value  [ip_get "parameter.core16_dfl_en_hwtcl.value"]
	  set core8_dfl_en_hwtcl_value   [ip_get "parameter.core8_dfl_en_hwtcl.value"]

	  if {$core16_dfl_en_hwtcl_value || $core8_dfl_en_hwtcl_value} {	  
	  	  
	  	  send_message info "Generating Device Feature List Memory Initialization File (.mif)"
	
		  # set parameter_file_name "parameters.txt"
		  # set parameter_file_path "${TEMPPATH}${parameter_file_name}"
		# 
		  # set parameter_file [ open $parameter_file_path "w" ]
		  # set listOfparameter [ get_parameters ]
		  # foreach parameter $listOfparameter {
			# set param_value [ip_get "parameter.${parameter}.value"]
			# puts $parameter_file "${parameter}=${param_value}"
		  # }
		  # send_message info "parameter file at ${parameter_file_path}"
		  # close $parameter_file
		
		  generate_DFL_MIF_file $TEMPPATH
		
		  # uncomment if you would like to see the generated parameters.txt file
		  # add_fileset_file "sep/mif/${parameter_file_name}" OTHER PATH ${parameter_file_path}
		
		  #set MIF_generated_path [file join $TEMPPATH output]
		  #foreach item [glob -nocomplain -directory $MIF_generated_path  -tails *] {
			#set abs_path [file join $MIF_generated_path $item]
			#add_fileset_file "aldec/mif/${item}" OTHER PATH $abs_path
			#add_fileset_file "cadence/mif/${item}" OTHER PATH $abs_path
			#add_fileset_file "mentor/mif/${item}" OTHER PATH $abs_path
			#add_fileset_file "synopsys/mif/${item}" OTHER PATH $abs_path
		  #}
		}
                  
  	      
	#MIF FILE FOR ctrl shadow ram reset
		  generate_ctrl_shadow_ram_reset_MIF_file $TEMPPATH
		
		  set MIF_generated_path [file join $TEMPPATH output]
		  foreach item [glob -nocomplain -directory $MIF_generated_path  -tails *] {
			set abs_path [file join $MIF_generated_path $item]
			#add_fileset_file "aldec/mif/${item}" OTHER PATH $abs_path
			add_fileset_file "intelfpga/hip_if_adaptor/${item}" MIF PATH $abs_path            
			#add_fileset_file "cadence/mif/${item}" OTHER PATH $abs_path
			#add_fileset_file "mentor/mif/${item}" OTHER PATH $abs_path
			#add_fileset_file "synopsys/mif/${item}" OTHER PATH $abs_path
		  }
	  return
	}
	
	proc ::intel_pcie_ss_axi::fileset::get_parameters {} {
	   #need check variable on pcie_ss_paramters if needed
	   variable parameters
	   return $parameters
	}

# Because we are merging QHIP parameters from 2 tiles, certain parameters that are not found in other TILES will be removed before passing the QHIP parameters into the QHIP IP
        proc ::intel_pcie_ss_axi::fileset::dict_cleanup {} {
            global qhip_param
            set tile [ip_get "parameter.TILE.value"]

            set ftile_qhip_param [list \
                ftile_debug_toolkit_hwtcl \
                ftile_enable_pciess_register_access_hwtcl \
                generating_b0_hwtcl \
                core16_func_mode_integer_hwtcl \
                core16_pld_clrpcs_user_hwtcl \
                core16_pld_clrpcs_hwtcl \
                core16_pf0_gen3_eq_pset_req_vec_a0_user_hwtcl \
                core16_pf0_gen3_eq_pset_req_vec_atg4_a0_user_hwtcl \
                core16_pf0_gen3_eq_pset_req_vec_b0_user_hwtcl \
                core16_pf0_gen3_eq_pset_req_vec_atg4_b0_user_hwtcl \
                core16_pf0_gen3_eq_pset_req_vec_c0_user_hwtcl \
                core16_pf0_gen3_eq_pset_req_vec_atg4_c0_user_hwtcl \
                core16_virtual_num_of_lanes_16_hwtcl \
                core16_virtual_num_of_lanes_8_hwtcl \
                core16_virtual_num_of_lanes_4_hwtcl \
                core16_pf0_dsp_rx_preset_hint_hwtcl \
                core16_pf0_usp_rx_preset_hint_hwtcl \
                core16_enable_pld_rst_port0_hwtcl \
                core16_pf0_expansion_base_address_register_integer_hwtcl \
                core16_pf1_expansion_base_address_register_integer_hwtcl \
                core16_pf2_expansion_base_address_register_integer_hwtcl \
                core16_pf3_expansion_base_address_register_integer_hwtcl \
                core16_pf4_expansion_base_address_register_integer_hwtcl \
                core16_pf5_expansion_base_address_register_integer_hwtcl \
                core16_pf6_expansion_base_address_register_integer_hwtcl \
                core16_pf7_expansion_base_address_register_integer_hwtcl \
                core16_pcie_cvp_attr_hwtcl \
                core16_pf0_prs_outstanding_capacity_hwtcl \
                core16_pf1_prs_outstanding_capacity_hwtcl \
                core16_pf2_prs_outstanding_capacity_hwtcl \
                core16_pf3_prs_outstanding_capacity_hwtcl \
                core16_pf4_prs_outstanding_capacity_hwtcl \
                core16_pf5_prs_outstanding_capacity_hwtcl \
                core16_pf6_prs_outstanding_capacity_hwtcl \
                core16_pf7_prs_outstanding_capacity_hwtcl \
                core16_virtual_ptm_hwtcl \
                core16_cfg_ptm_auto_update_period_hwtcl \
                core16_virtual_ptm_autoupdate_hwtcl \
                core16_cfg_ptm_local_clock_adj_lsb_hwtcl \
                core16_cfg_ptm_local_clock_adj_msb_hwtcl \
                core16_pf0_vf_ats_pagealignreq_hwtcl \
                core16_pf1_vf_ats_pagealignreq_hwtcl \
                core16_pf2_vf_ats_pagealignreq_hwtcl \
                core16_pf3_vf_ats_pagealignreq_hwtcl \
                core16_pf4_vf_ats_pagealignreq_hwtcl \
                core16_pf5_vf_ats_pagealignreq_hwtcl \
                core16_pf6_vf_ats_pagealignreq_hwtcl \
                core16_pf7_vf_ats_pagealignreq_hwtcl \
                core16_vendor_id_hwtcl \
                core16_revision_id_hwtcl \
                core16_crs_en_default_hwtcl \
                core8_crs_en_default_hwtcl \
                core4_0_crs_en_default_hwtcl \
                core4_1_crs_en_default_hwtcl \
                core16_virtual_pf0_user_vsec_offset_hwtcl \
                core8_virtual_pf0_user_vsec_offset_hwtcl \
                core4_0_virtual_pf0_user_vsec_offset_hwtcl \
                core4_1_virtual_pf0_user_vsec_offset_hwtcl \
            \
                core8_func_mode_integer_hwtcl \
                core8_pld_clrpcs_user_hwtcl \
                core8_pld_clrpcs_hwtcl \
                core8_pf0_gen3_eq_pset_req_vec_a0_user_hwtcl \
                core8_pf0_gen3_eq_pset_req_vec_atg4_a0_user_hwtcl \
                core8_pf0_gen3_eq_pset_req_vec_b0_user_hwtcl \
                core8_pf0_gen3_eq_pset_req_vec_atg4_b0_user_hwtcl \
                core8_pf0_gen3_eq_pset_req_vec_c0_user_hwtcl \
                core8_pf0_gen3_eq_pset_req_vec_atg4_c0_user_hwtcl \
                core8_virtual_num_of_lanes_8_hwtcl \
                core8_virtual_num_of_lanes_4_hwtcl \
                core8_pf0_dsp_rx_preset_hint_hwtcl \
                core8_pf0_usp_rx_preset_hint_hwtcl \
                core8_enable_pld_rst_port0_hwtcl \
                core8_enable_independent_pin_perst_hwtcl \
                core8_pf0_expansion_base_address_register_integer_hwtcl \
                core8_pf1_expansion_base_address_register_integer_hwtcl \
                core8_pf2_expansion_base_address_register_integer_hwtcl \
                core8_pf3_expansion_base_address_register_integer_hwtcl \
                core8_pf4_expansion_base_address_register_integer_hwtcl \
                core8_pf5_expansion_base_address_register_integer_hwtcl \
                core8_pf6_expansion_base_address_register_integer_hwtcl \
                core8_pf7_expansion_base_address_register_integer_hwtcl \
                core8_pf0_prs_outstanding_capacity_hwtcl \
                core8_pf1_prs_outstanding_capacity_hwtcl \
                core8_pf2_prs_outstanding_capacity_hwtcl \
                core8_pf3_prs_outstanding_capacity_hwtcl \
                core8_pf4_prs_outstanding_capacity_hwtcl \
                core8_pf5_prs_outstanding_capacity_hwtcl \
                core8_pf6_prs_outstanding_capacity_hwtcl \
                core8_pf7_prs_outstanding_capacity_hwtcl \
                core8_virtual_ptm_hwtcl \
                core8_cfg_ptm_auto_update_period_hwtcl \
                core8_virtual_ptm_autoupdate_hwtcl \
                core8_cfg_ptm_local_clock_adj_lsb_hwtcl \
                core8_cfg_ptm_local_clock_adj_msb_hwtcl \
                core8_pf0_vf_ats_pagealignreq_hwtcl \
                core8_pf1_vf_ats_pagealignreq_hwtcl \
                core8_pf2_vf_ats_pagealignreq_hwtcl \
                core8_pf3_vf_ats_pagealignreq_hwtcl \
                core8_pf4_vf_ats_pagealignreq_hwtcl \
                core8_pf5_vf_ats_pagealignreq_hwtcl \
                core8_pf6_vf_ats_pagealignreq_hwtcl \
                core8_pf7_vf_ats_pagealignreq_hwtcl \
                core8_vendor_id_hwtcl \
                core8_revision_id_hwtcl \
            \
                core4_0_func_mode_integer_hwtcl \
                core4_0_pf0_gen3_eq_pset_req_vec_a0_user_hwtcl \
                core4_0_pf0_gen3_eq_pset_req_vec_atg4_a0_user_hwtcl \
                core4_0_pf0_gen3_eq_pset_req_vec_b0_user_hwtcl \
                core4_0_pf0_gen3_eq_pset_req_vec_atg4_b0_user_hwtcl \
                core4_0_virtual_num_of_lanes_4_hwtcl \
                core4_0_pf0_dsp_rx_preset_hint_hwtcl \
                core4_0_pf0_dsp_rx_preset_hint_hwtcl \
                core4_0_pld_clrpcs_user_hwtcl \
                core4_0_pld_clrpcs_hwtcl \
                core4_0_pf0_prs_outstanding_capacity_hwtcl \
                core4_0_virtual_pf1_enable_hwtcl \
                core4_0_virtual_pf2_enable_hwtcl \
                core4_0_virtual_pf3_enable_hwtcl \
                core4_0_virtual_pf4_enable_hwtcl \
                core4_0_virtual_pf5_enable_hwtcl \
                core4_0_virtual_pf6_enable_hwtcl \
                core4_0_virtual_pf7_enable_hwtcl \
                core4_0_enable_sriov_hwtcl \
                core4_0_virtual_pf0_sriov_enable_hwtcl \
                core4_0_virtual_pf1_sriov_enable_hwtcl \
                core4_0_virtual_pf2_sriov_enable_hwtcl \
                core4_0_virtual_pf3_sriov_enable_hwtcl \
                core4_0_virtual_pf4_sriov_enable_hwtcl \
                core4_0_virtual_pf5_sriov_enable_hwtcl \
                core4_0_virtual_pf6_sriov_enable_hwtcl \
                core4_0_virtual_pf7_sriov_enable_hwtcl \
                core4_0_total_pf_count_hwtcl \
                core4_0_enable_multi_func_hwtcl \
                core4_0_pf0_vf_count_hwtcl \
                core4_0_pf1_vf_count_hwtcl \
                core4_0_pf2_vf_count_hwtcl \
                core4_0_pf3_vf_count_hwtcl \
                core4_0_pf4_vf_count_hwtcl \
                core4_0_pf5_vf_count_hwtcl \
                core4_0_pf6_vf_count_hwtcl \
                core4_0_pf7_vf_count_hwtcl \
                core4_0_enable_virtio_hwtcl \
                core4_0_pf0_virtio_device_specific_cap_present_hwtcl \
                core4_0_pf0_virtio_cmn_config_bar_indicator_hwtcl \
                core4_0_pf0_virtio_cmn_config_bar_offset_hwtcl \
                core4_0_pf0_virtio_cmn_config_structure_length_hwtcl \
                core4_0_pf0_virtio_pciconfig_access_cfg_data_hwtcl \
                core4_0_pf0_virtio_notification_bar_indicator_hwtcl \
                core4_0_pf0_virtio_notification_bar_offset_hwtcl \
                core4_0_pf0_virtio_notification_structure_length_hwtcl \
                core4_0_pf0_virtio_notify_off_multiplier_hwtcl \
                core4_0_pf0_virtio_isrstatus_bar_indicator_hwtcl \
                core4_0_pf0_virtio_isrstatus_bar_offset_hwtcl \
                core4_0_pf0_virtio_isrstatus_structure_length_hwtcl \
                core4_0_pf0_virtio_devspecific_bar_indicator_hwtcl \
                core4_0_pf0_virtio_devspecific_bar_offset_hwtcl \
                core4_0_pf0_virtio_devspecific_structure_length_hwtcl \
                core4_0_pf0_virtio_pciconfig_access_bar_indicator_hwtcl \
                core4_0_pf0_virtio_pciconfig_access_bar_offset_hwtcl \
                core4_0_pf0_virtio_pciconfig_access_structure_length_hwtcl \
                core4_0_pf0_gen3_eq_pset_req_vec_c0_user_hwtcl \
                core4_0_pf0_gen3_eq_pset_req_vec_atg4_c0_user_hwtcl \
                core4_0_enable_cii_hwtcl \
                core4_0_enable_prs_event_hwtcl \
                core4_0_rx_dsk_enable_hwtcl \
                core4_0_virtio_cii_ctrl_k_cfg_update_en_attr_hwtcl \
                core4_0_cii_range_virtio_en_hwtcl \
                core4_0_cii_range_0_k_cii_pf_en0_attr_user_hwtcl \
                core4_0_cii_range_0_k_cii_pf_en0_attr_hwtcl \
                core4_0_cii_range_0_k_cii_start_addr0_attr_user_hwtcl \
                core4_0_cii_range_0_k_cii_start_addr0_attr_hwtcl \
                core4_0_cii_range_0_k_cii_addr_size0_attr_user_hwtcl \
                core4_0_cii_range_0_k_cii_addr_size0_attr_user_hwtcl \
                core4_0_cii_range_0_k_cii_addr_size0_attr_hwtcl \
                core4_0_cii_range_1_k_cii_pf_en1_attr_user_hwtcl \
                core4_0_cii_range_1_k_cii_pf_en1_attr_hwtcl \
                core4_0_cii_range_1_k_cii_start_addr1_attr_user_hwtcl \
                core4_0_cii_range_1_k_cii_start_addr1_attr_hwtcl \
                core4_0_cii_range_1_k_cii_addr_size1_attr_user_hwtcl \
                core4_0_cii_range_1_k_cii_addr_size1_attr_user_hwtcl \
                core4_0_cii_range_1_k_cii_addr_size1_attr_hwtcl \
                core4_0_cii_range_2_k_cii_pf_en2_attr_user_hwtcl \
                core4_0_cii_range_2_k_cii_pf_en2_attr_hwtcl \
                core4_0_cii_range_2_k_cii_start_addr2_attr_user_hwtcl \
                core4_0_cii_range_2_k_cii_start_addr2_attr_hwtcl \
                core4_0_cii_range_2_k_cii_addr_size2_attr_user_hwtcl \
                core4_0_cii_range_2_k_cii_addr_size2_attr_user_hwtcl \
                core4_0_cii_range_2_k_cii_addr_size2_attr_hwtcl \
                core4_0_cii_range_3_k_cii_pf_en3_attr_user_hwtcl \
                core4_0_cii_range_3_k_cii_pf_en3_attr_hwtcl \
                core4_0_cii_range_3_k_cii_start_addr3_attr_user_hwtcl \
                core4_0_cii_range_3_k_cii_start_addr3_attr_hwtcl \
                core4_0_cii_range_3_k_cii_addr_size3_attr_user_hwtcl \
                core4_0_cii_range_3_k_cii_addr_size3_attr_user_hwtcl \
                core4_0_cii_range_3_k_cii_addr_size3_attr_hwtcl \
                core4_0_cii_range_4_k_cii_pf_en4_attr_user_hwtcl \
                core4_0_cii_range_4_k_cii_pf_en4_attr_hwtcl \
                core4_0_cii_range_4_k_cii_start_addr4_attr_user_hwtcl \
                core4_0_cii_range_4_k_cii_start_addr4_attr_hwtcl \
                core4_0_cii_range_4_k_cii_addr_size4_attr_user_hwtcl \
                core4_0_cii_range_4_k_cii_addr_size4_attr_user_hwtcl \
                core4_0_cii_range_4_k_cii_addr_size4_attr_hwtcl \
                core4_0_cii_range_5_k_cii_pf_en5_attr_user_hwtcl \
                core4_0_cii_range_5_k_cii_pf_en5_attr_hwtcl \
                core4_0_cii_range_5_k_cii_start_addr5_attr_user_hwtcl \
                core4_0_cii_range_5_k_cii_start_addr5_attr_hwtcl \
                core4_0_cii_range_5_k_cii_addr_size5_attr_user_hwtcl \
                core4_0_cii_range_5_k_cii_addr_size5_attr_user_hwtcl \
                core4_0_cii_range_5_k_cii_addr_size5_attr_hwtcl \
                core4_0_cii_range_6_k_cii_pf_en6_attr_user_hwtcl \
                core4_0_cii_range_6_k_cii_pf_en6_attr_hwtcl \
                core4_0_cii_range_6_k_cii_start_addr6_attr_user_hwtcl \
                core4_0_cii_range_6_k_cii_start_addr6_attr_hwtcl \
                core4_0_cii_range_6_k_cii_addr_size6_attr_user_hwtcl \
                core4_0_cii_range_6_k_cii_addr_size6_attr_user_hwtcl \
                core4_0_cii_range_6_k_cii_addr_size6_attr_hwtcl \
                core4_0_cii_range_7_k_cii_pf_en7_attr_user_hwtcl \
                core4_0_cii_range_7_k_cii_pf_en7_attr_hwtcl \
                core4_0_cii_range_7_k_cii_start_addr7_attr_user_hwtcl \
                core4_0_cii_range_7_k_cii_start_addr7_attr_hwtcl \
                core4_0_cii_range_7_k_cii_addr_size7_attr_user_hwtcl \
                core4_0_cii_range_7_k_cii_addr_size7_attr_user_hwtcl \
                core4_0_cii_range_7_k_cii_addr_size7_attr_hwtcl \
                core4_0_virtual_pf0_msix_enable_user_hwtcl \
                core4_0_virtual_pf1_msix_enable_user_hwtcl \
                core4_0_virtual_pf2_msix_enable_user_hwtcl \
                core4_0_virtual_pf3_msix_enable_user_hwtcl \
                core4_0_virtual_pf4_msix_enable_user_hwtcl \
                core4_0_virtual_pf5_msix_enable_user_hwtcl \
                core4_0_virtual_pf6_msix_enable_user_hwtcl \
                core4_0_virtual_pf7_msix_enable_user_hwtcl \
                core4_0_virtual_pf1_msix_enable_hwtcl \
                core4_0_virtual_pf2_msix_enable_hwtcl \
                core4_0_virtual_pf3_msix_enable_hwtcl \
                core4_0_virtual_pf4_msix_enable_hwtcl \
                core4_0_virtual_pf5_msix_enable_hwtcl \
                core4_0_virtual_pf6_msix_enable_hwtcl \
                core4_0_virtual_pf7_msix_enable_hwtcl \
                core4_0_pf1_pci_msix_table_size_hwtcl \
                core4_0_pf1_pci_msix_table_offset_hwtcl \
                core4_0_pf1_pci_msix_bir_hwtcl \
                core4_0_pf1_pci_msix_pba_offset_hwtcl \
                core4_0_pf1_pci_msix_pba_hwtcl \
                core4_0_pf1_pci_msix_table_size_vfcomm_cs2_hwtcl \
                core4_0_pf2_pci_msix_table_size_hwtcl \
                core4_0_pf2_pci_msix_table_offset_hwtcl \
                core4_0_pf2_pci_msix_bir_hwtcl \
                core4_0_pf2_pci_msix_pba_offset_hwtcl \
                core4_0_pf2_pci_msix_pba_hwtcl \
                core4_0_pf2_pci_msix_table_size_vfcomm_cs2_hwtcl \
                core4_0_pf3_pci_msix_table_size_hwtcl \
                core4_0_pf3_pci_msix_table_offset_hwtcl \
                core4_0_pf3_pci_msix_bir_hwtcl \
                core4_0_pf3_pci_msix_pba_offset_hwtcl \
                core4_0_pf3_pci_msix_pba_hwtcl \
                core4_0_pf3_pci_msix_table_size_vfcomm_cs2_hwtcl \
                core4_0_pf4_pci_msix_table_size_hwtcl \
                core4_0_pf4_pci_msix_table_offset_hwtcl \
                core4_0_pf4_pci_msix_bir_hwtcl \
                core4_0_pf4_pci_msix_pba_offset_hwtcl \
                core4_0_pf4_pci_msix_pba_hwtcl \
                core4_0_pf4_pci_msix_table_size_vfcomm_cs2_hwtcl \
                core4_0_pf5_pci_msix_table_size_hwtcl \
                core4_0_pf5_pci_msix_table_offset_hwtcl \
                core4_0_pf5_pci_msix_bir_hwtcl \
                core4_0_pf5_pci_msix_pba_offset_hwtcl \
                core4_0_pf5_pci_msix_pba_hwtcl \
                core4_0_pf5_pci_msix_table_size_vfcomm_cs2_hwtcl \
                core4_0_pf6_pci_msix_table_size_hwtcl \
                core4_0_pf6_pci_msix_table_offset_hwtcl \
                core4_0_pf6_pci_msix_bir_hwtcl \
                core4_0_pf6_pci_msix_pba_offset_hwtcl \
                core4_0_pf6_pci_msix_pba_hwtcl \
                core4_0_pf6_pci_msix_table_size_vfcomm_cs2_hwtcl \
                core4_0_pf7_pci_msix_table_size_hwtcl \
                core4_0_pf7_pci_msix_table_offset_hwtcl \
                core4_0_pf7_pci_msix_bir_hwtcl \
                core4_0_pf7_pci_msix_pba_offset_hwtcl \
                core4_0_pf7_pci_msix_pba_hwtcl \
                core4_0_pf7_pci_msix_table_size_vfcomm_cs2_hwtcl \
                core4_0_virtual_pf0_exvf_msix_cap_enable_hwtcl \
                core4_0_exvf_msix_tablesize_pf0 \
                core4_0_exvf_msixtable_offset_pf0 \
                core4_0_exvf_msixtable_bir_pf0 \
                core4_0_exvf_msixpba_offset_pf0 \
                core4_0_virtual_pf1_exvf_msix_cap_enable_hwtcl \
                core4_0_exvf_msix_tablesize_pf1 \
                core4_0_exvf_msixtable_offset_pf1 \
                core4_0_exvf_msixtable_bir_pf1 \
                core4_0_exvf_msixpba_offset_pf1 \
                 core4_0_virtual_pf2_exvf_msix_cap_enable_hwtcl \
                core4_0_exvf_msix_tablesize_pf2 \
                core4_0_exvf_msixtable_offset_pf2 \
                core4_0_exvf_msixtable_bir_pf2 \
                core4_0_exvf_msixpba_offset_pf2 \
                core4_0_virtual_pf3_exvf_msix_cap_enable_hwtcl \
                core4_0_exvf_msix_tablesize_pf3 \
                core4_0_exvf_msixtable_offset_pf3 \
                core4_0_exvf_msixtable_bir_pf3 \
                core4_0_exvf_msixpba_offset_pf3 \
                core4_0_virtual_pf4_exvf_msix_cap_enable_hwtcl \
                core4_0_exvf_msix_tablesize_pf4 \
                core4_0_exvf_msixtable_offset_pf4 \
                core4_0_exvf_msixtable_bir_pf4 \
                core4_0_exvf_msixpba_offset_pf4 \
                core4_0_virtual_pf5_exvf_msix_cap_enable_hwtcl \
                core4_0_exvf_msix_tablesize_pf5 \
                core4_0_exvf_msixtable_offset_pf5 \
                core4_0_exvf_msixtable_bir_pf5 \
                core4_0_exvf_msixpba_offset_pf5 \
                core4_0_virtual_pf6_exvf_msix_cap_enable_hwtcl \
                core4_0_exvf_msix_tablesize_pf6 \
                core4_0_exvf_msixtable_offset_pf6 \
                core4_0_exvf_msixtable_bir_pf6 \
                core4_0_exvf_msixpba_offset_pf6 \
                core4_0_virtual_pf7_exvf_msix_cap_enable_hwtcl \
                core4_0_exvf_msix_tablesize_pf7 \
                core4_0_exvf_msixtable_offset_pf7 \
                core4_0_exvf_msixtable_bir_pf7 \
                core4_0_exvf_msixpba_offset_pf7 \
                core4_0_virtual_pf0_pasid_cap_enable_hwtcl \
                core4_0_pf0_pasid_cap_execute_permission_supported \
                core4_0_pf0_pasid_cap_privileged_mode_supported \
                core4_0_pf0_pasid_cap_max_pasid_width \
                core4_0_virtual_pf1_pasid_cap_enable_hwtcl \
                core4_0_pf1_pasid_cap_execute_permission_supported \
                core4_0_pf1_pasid_cap_privileged_mode_supported \
                core4_0_pf1_pasid_cap_max_pasid_width \
                core4_0_virtual_pf2_pasid_cap_enable_hwtcl \
                core4_0_pf2_pasid_cap_execute_permission_supported \
                core4_0_pf2_pasid_cap_privileged_mode_supported \
                core4_0_pf2_pasid_cap_max_pasid_width \
                core4_0_virtual_pf3_pasid_cap_enable_hwtcl \
                core4_0_pf3_pasid_cap_execute_permission_supported \
                core4_0_pf3_pasid_cap_privileged_mode_supported \
                core4_0_pf3_pasid_cap_max_pasid_width \
                core4_0_virtual_pf4_pasid_cap_enable_hwtcl \
                core4_0_pf4_pasid_cap_execute_permission_supported \
                core4_0_pf4_pasid_cap_privileged_mode_supported \
                core4_0_pf4_pasid_cap_max_pasid_width \
                core4_0_virtual_pf5_pasid_cap_enable_hwtcl \
                core4_0_pf5_pasid_cap_execute_permission_supported \
                core4_0_pf5_pasid_cap_privileged_mode_supported \
                core4_0_pf5_pasid_cap_max_pasid_width \
-               core4_0_virtual_pf6_pasid_cap_enable_hwtcl \
                core4_0_pf6_pasid_cap_execute_permission_supported \
                core4_0_pf6_pasid_cap_privileged_mode_supported \
                core4_0_pf6_pasid_cap_max_pasid_width \
                core4_0_virtual_pf7_pasid_cap_enable_hwtcl \
                core4_0_pf7_pasid_cap_execute_permission_supported \
                core4_0_pf7_pasid_cap_privileged_mode_supported \
                core4_0_pf7_pasid_cap_max_pasid_width \
                core4_0_virtual_pf1_prs_ext_cap_enable_hwtcl \
                core4_0_virtual_pf2_prs_ext_cap_enable_hwtcl \
                core4_0_virtual_pf3_prs_ext_cap_enable_hwtcl \
                core4_0_virtual_pf4_prs_ext_cap_enable_hwtcl \
                core4_0_virtual_pf5_prs_ext_cap_enable_hwtcl \
                core4_0_virtual_pf6_prs_ext_cap_enable_hwtcl \
                core4_0_virtual_pf7_prs_ext_cap_enable_hwtcl \
                core4_0_pf1_prs_outstanding_capacity_hwtcl \
                core4_0_pf2_prs_outstanding_capacity_hwtcl \
                core4_0_pf3_prs_outstanding_capacity_hwtcl \
                core4_0_pf4_prs_outstanding_capacity_hwtcl \
                core4_0_pf5_prs_outstanding_capacity_hwtcl \
                core4_0_pf6_prs_outstanding_capacity_hwtcl \
                core4_0_pf7_prs_outstanding_capacity_hwtcl \
                core4_0_virtual_pf1_acs_cap_enable_hwtcl \
                core4_0_virtual_pf2_acs_cap_enable_hwtcl \
                core4_0_virtual_pf3_acs_cap_enable_hwtcl \
                core4_0_virtual_pf4_acs_cap_enable_hwtcl \
                core4_0_virtual_pf5_acs_cap_enable_hwtcl \
                core4_0_virtual_pf6_acs_cap_enable_hwtcl \
                core4_0_virtual_pf7_acs_cap_enable_hwtcl \
                core4_0_pf1_acs_cap_acs_p2p_egress_control_hwtcl \
                core4_0_pf2_acs_cap_acs_p2p_egress_control_hwtcl \
                core4_0_pf3_acs_cap_acs_p2p_egress_control_hwtcl \
                core4_0_pf4_acs_cap_acs_p2p_egress_control_hwtcl \
                core4_0_pf5_acs_cap_acs_p2p_egress_control_hwtcl \
                core4_0_pf6_acs_cap_acs_p2p_egress_control_hwtcl \
                core4_0_pf7_acs_cap_acs_p2p_egress_control_hwtcl \
                core4_0_pf0_int_pin_hwtcl \
                core4_0_pf1_int_pin_hwtcl \
                core4_0_pf2_int_pin_hwtcl \
                core4_0_pf3_int_pin_hwtcl \
                core4_0_pf4_int_pin_hwtcl \
                core4_0_pf5_int_pin_hwtcl \
                core4_0_pf6_int_pin_hwtcl \
                core4_0_pf7_int_pin_hwtcl \
                core4_0_virtual_pf0_msi_enable_hwtcl \
                core4_0_virtual_pf1_msi_enable_hwtcl \
                core4_0_virtual_pf2_msi_enable_hwtcl \
                core4_0_virtual_pf3_msi_enable_hwtcl \
                core4_0_virtual_pf4_msi_enable_hwtcl \
                core4_0_virtual_pf5_msi_enable_hwtcl \
                core4_0_virtual_pf6_msi_enable_hwtcl \
                core4_0_virtual_pf7_msi_enable_hwtcl \
                core4_0_enable_msi_interface_hwtcl \
                core4_0_virtual_pf0_msi_enable_user_hwtcl \
                core4_0_virtual_pf1_msi_enable_user_hwtcl \
                core4_0_virtual_pf2_msi_enable_user_hwtcl \
                core4_0_virtual_pf3_msi_enable_user_hwtcl \
                core4_0_virtual_pf4_msi_enable_user_hwtcl \
                core4_0_virtual_pf5_msi_enable_user_hwtcl \
                core4_0_virtual_pf6_msi_enable_user_hwtcl \
                core4_0_virtual_pf7_msi_enable_user_hwtcl \
                core4_0_virtual_pf0_msi_64b_addressing_user_hwtcl \
                core4_0_virtual_pf1_msi_64b_addressing_user_hwtcl \
                core4_0_virtual_pf2_msi_64b_addressing_user_hwtcl \
                core4_0_virtual_pf3_msi_64b_addressing_user_hwtcl \
                core4_0_virtual_pf4_msi_64b_addressing_user_hwtcl \
                core4_0_virtual_pf5_msi_64b_addressing_user_hwtcl \
                core4_0_virtual_pf6_msi_64b_addressing_user_hwtcl \
                core4_0_virtual_pf7_msi_64b_addressing_user_hwtcl \
                core4_0_pf0_pci_msi_ext_data_cap_hwtcl \
                core4_0_pf1_pci_msi_ext_data_cap_hwtcl \
                core4_0_pf2_pci_msi_ext_data_cap_hwtcl \
                core4_0_pf3_pci_msi_ext_data_cap_hwtcl \
                core4_0_pf4_pci_msi_ext_data_cap_hwtcl \
                core4_0_pf5_pci_msi_ext_data_cap_hwtcl \
                core4_0_pf6_pci_msi_ext_data_cap_hwtcl \
                core4_0_pf7_pci_msi_ext_data_cap_hwtcl \
                core4_0_pf0_pci_msi_multiple_msg_cap_hwtcl \
                core4_0_pf1_pci_msi_multiple_msg_cap_hwtcl \
                core4_0_pf2_pci_msi_multiple_msg_cap_hwtcl \
                core4_0_pf3_pci_msi_multiple_msg_cap_hwtcl \
                core4_0_pf4_pci_msi_multiple_msg_cap_hwtcl \
                core4_0_pf5_pci_msi_multiple_msg_cap_hwtcl \
                core4_0_pf6_pci_msi_multiple_msg_cap_hwtcl \
                core4_0_pf7_pci_msi_multiple_msg_cap_hwtcl \
                core4_0_pf0_bar0_type_user_hwtcl \
                core4_0_pf0_bar0_address_width_user_hwtcl \
                 core4_0_pf1_bar0_type_user_hwtcl \
                core4_0_pf2_bar0_type_user_hwtcl \
                core4_0_pf3_bar0_type_user_hwtcl \
                core4_0_pf1_bar0_address_width_user_hwtcl \
                core4_0_pf2_bar0_address_width_user_hwtcl \
                core4_0_pf3_bar0_address_width_user_hwtcl \
                core4_0_pf0_sriov_vf_bar0_type_user_hwtcl \
                core4_0_pf1_sriov_vf_bar0_type_user_hwtcl \
                core4_0_pf2_sriov_vf_bar0_type_user_hwtcl \
                core4_0_pf3_sriov_vf_bar0_type_user_hwtcl \
                core4_0_pf0_sriov_vf_bar0_type_hwtcl \
                core4_0_pf1_sriov_vf_bar0_type_hwtcl \
                core4_0_pf2_sriov_vf_bar0_type_hwtcl \
                core4_0_pf3_sriov_vf_bar0_type_hwtcl \
                core4_0_pf0_sriov_vf_bar0_address_width_hwtcl \
                core4_0_pf1_sriov_vf_bar0_address_width_hwtcl \
                core4_0_pf2_sriov_vf_bar0_address_width_hwtcl \
                core4_0_pf3_sriov_vf_bar0_address_width_hwtcl \
                core4_0_pf1_virtio_device_specific_cap_present_hwtcl \
                core4_0_pf2_virtio_device_specific_cap_present_hwtcl \
                core4_0_pf3_virtio_device_specific_cap_present_hwtcl \
                core4_0_pf0vf_virtio_device_specific_cap_present_hwtcl \
                core4_0_pf1vf_virtio_device_specific_cap_present_hwtcl \
                core4_0_pf2vf_virtio_device_specific_cap_present_hwtcl \
                core4_0_pf3vf_virtio_device_specific_cap_present_hwtcl \
                core4_0_exvf_msixpba_bir_pf0  \
                core4_0_exvf_msixpba_bir_pf1  \
                core4_0_exvf_msixpba_bir_pf2  \
                core4_0_exvf_msixpba_bir_pf3  \
                core4_0_virtual_pf0_user_vsec_offset_hwtcl \
                core4_1_virtual_pf0_user_vsec_offset_hwtcl \
             \
                core4_1_func_mode_integer_hwtcl \
                core4_1_pf0_dsp_rx_preset_hint_hwtcl \
                core4_1_pf0_dsp_rx_preset_hint_hwtcl \
                core4_1_pf0_gen3_eq_pset_req_vec_a0_user_hwtcl \
                core4_1_pf0_gen3_eq_pset_req_vec_atg4_a0_user_hwtcl \
                core4_1_pf0_gen3_eq_pset_req_vec_b0_user_hwtcl \
                core4_1_pf0_gen3_eq_pset_req_vec_atg4_b0_user_hwtcl \
                core4_1_virtual_num_of_lanes_4_hwtcl \
                core4_1_pld_clrpcs_user_hwtcl \
                core4_1_pld_clrpcs_hwtcl \
                core4_1_pf0_prs_outstanding_capacity_hwtcl \
                core4_1_virtual_pf1_enable_hwtcl \
                core4_1_virtual_pf2_enable_hwtcl \
                core4_1_virtual_pf3_enable_hwtcl \
                core4_1_virtual_pf4_enable_hwtcl \
                core4_1_virtual_pf5_enable_hwtcl \
                core4_1_virtual_pf6_enable_hwtcl \
                core4_1_virtual_pf7_enable_hwtcl \
                core4_1_enable_sriov_hwtcl \
                core4_1_virtual_pf0_sriov_enable_hwtcl \
                core4_1_virtual_pf1_sriov_enable_hwtcl \
                core4_1_virtual_pf2_sriov_enable_hwtcl \
                core4_1_virtual_pf3_sriov_enable_hwtcl \
                core4_1_virtual_pf4_sriov_enable_hwtcl \
                core4_1_virtual_pf5_sriov_enable_hwtcl \
                core4_1_virtual_pf6_sriov_enable_hwtcl \
                core4_1_virtual_pf7_sriov_enable_hwtcl \
                core4_1_total_pf_count_hwtcl \
                core4_1_enable_multi_func_hwtcl \
                core4_1_pf0_vf_count_hwtcl \
                core4_1_pf1_vf_count_hwtcl \
                core4_1_pf2_vf_count_hwtcl \
                core4_1_pf3_vf_count_hwtcl \
                core4_1_pf4_vf_count_hwtcl \
                core4_1_pf5_vf_count_hwtcl \
                core4_1_pf6_vf_count_hwtcl \
                core4_1_pf7_vf_count_hwtcl \
                core4_1_enable_virtio_hwtcl \
                core4_1_pf0_virtio_device_specific_cap_present_hwtcl \
                core4_1_pf0_virtio_cmn_config_bar_indicator_hwtcl \
                core4_1_pf0_virtio_cmn_config_bar_offset_hwtcl \
                core4_1_pf0_virtio_cmn_config_structure_length_hwtcl \
                core4_1_pf0_virtio_pciconfig_access_cfg_data_hwtcl \
                core4_1_pf0_virtio_notification_bar_indicator_hwtcl \
                core4_1_pf0_virtio_notification_bar_offset_hwtcl \
                core4_1_pf0_virtio_notification_structure_length_hwtcl \
                core4_1_pf0_virtio_notify_off_multiplier_hwtcl \
                core4_1_pf0_virtio_isrstatus_bar_indicator_hwtcl \
                core4_1_pf0_virtio_isrstatus_bar_offset_hwtcl \
                core4_1_pf0_virtio_isrstatus_structure_length_hwtcl \
                core4_1_pf0_virtio_devspecific_bar_indicator_hwtcl \
                core4_1_pf0_virtio_devspecific_bar_offset_hwtcl \
                core4_1_pf0_virtio_devspecific_structure_length_hwtcl \
                core4_1_pf0_virtio_pciconfig_access_bar_indicator_hwtcl \
                core4_1_pf0_virtio_pciconfig_access_bar_offset_hwtcl \
                core4_1_pf0_virtio_pciconfig_access_structure_length_hwtcl \
                core4_1_pf0_gen3_eq_pset_req_vec_c0_user_hwtcl \
                core4_1_pf0_gen3_eq_pset_req_vec_atg4_c0_user_hwtcl \
                core4_1_enable_cii_hwtcl \
                core4_1_enable_prs_event_hwtcl \
                core4_1_rx_dsk_enable_hwtcl \
                core4_1_virtio_cii_ctrl_k_cfg_update_en_attr_hwtcl \
                core4_1_cii_range_virtio_en_hwtcl \
                core4_1_cii_range_0_k_cii_pf_en0_attr_user_hwtcl \
                core4_1_cii_range_0_k_cii_pf_en0_attr_hwtcl \
                core4_1_cii_range_0_k_cii_start_addr0_attr_user_hwtcl \
                core4_1_cii_range_0_k_cii_start_addr0_attr_hwtcl \
                core4_1_cii_range_0_k_cii_addr_size0_attr_user_hwtcl \
                core4_1_cii_range_0_k_cii_addr_size0_attr_user_hwtcl \
                core4_1_cii_range_0_k_cii_addr_size0_attr_hwtcl \
                core4_1_cii_range_1_k_cii_pf_en1_attr_user_hwtcl \
                core4_1_cii_range_1_k_cii_pf_en1_attr_hwtcl \
                core4_1_cii_range_1_k_cii_start_addr1_attr_user_hwtcl \
                core4_1_cii_range_1_k_cii_start_addr1_attr_hwtcl \
                core4_1_cii_range_1_k_cii_addr_size1_attr_user_hwtcl \
                core4_1_cii_range_1_k_cii_addr_size1_attr_user_hwtcl \
                core4_1_cii_range_1_k_cii_addr_size1_attr_hwtcl \
                core4_1_cii_range_2_k_cii_pf_en2_attr_user_hwtcl \
                core4_1_cii_range_2_k_cii_pf_en2_attr_hwtcl \
                core4_1_cii_range_2_k_cii_start_addr2_attr_user_hwtcl \
                core4_1_cii_range_2_k_cii_start_addr2_attr_hwtcl \
                core4_1_cii_range_2_k_cii_addr_size2_attr_user_hwtcl \
                core4_1_cii_range_2_k_cii_addr_size2_attr_user_hwtcl \
                core4_1_cii_range_2_k_cii_addr_size2_attr_hwtcl \
                core4_1_cii_range_3_k_cii_pf_en3_attr_user_hwtcl \
                core4_1_cii_range_3_k_cii_pf_en3_attr_hwtcl \
                core4_1_cii_range_3_k_cii_start_addr3_attr_user_hwtcl \
                core4_1_cii_range_3_k_cii_start_addr3_attr_hwtcl \
                core4_1_cii_range_3_k_cii_addr_size3_attr_user_hwtcl \
                core4_1_cii_range_3_k_cii_addr_size3_attr_user_hwtcl \
                core4_1_cii_range_3_k_cii_addr_size3_attr_hwtcl \
                core4_1_cii_range_4_k_cii_pf_en4_attr_user_hwtcl \
                core4_1_cii_range_4_k_cii_pf_en4_attr_hwtcl \
                core4_1_cii_range_4_k_cii_start_addr4_attr_user_hwtcl \
                core4_1_cii_range_4_k_cii_start_addr4_attr_hwtcl \
                core4_1_cii_range_4_k_cii_addr_size4_attr_user_hwtcl \
                core4_1_cii_range_4_k_cii_addr_size4_attr_user_hwtcl \
                core4_1_cii_range_4_k_cii_addr_size4_attr_hwtcl \
                core4_1_cii_range_5_k_cii_pf_en5_attr_user_hwtcl \
                core4_1_cii_range_5_k_cii_pf_en5_attr_hwtcl \
                core4_1_cii_range_5_k_cii_start_addr5_attr_user_hwtcl \
                core4_1_cii_range_5_k_cii_start_addr5_attr_hwtcl \
                core4_1_cii_range_5_k_cii_addr_size5_attr_user_hwtcl \
                core4_1_cii_range_5_k_cii_addr_size5_attr_user_hwtcl \
                core4_1_cii_range_5_k_cii_addr_size5_attr_hwtcl \
                core4_1_cii_range_6_k_cii_pf_en6_attr_user_hwtcl \
                core4_1_cii_range_6_k_cii_pf_en6_attr_hwtcl \
                core4_1_cii_range_6_k_cii_start_addr6_attr_user_hwtcl \
                core4_1_cii_range_6_k_cii_start_addr6_attr_hwtcl \
                core4_1_cii_range_6_k_cii_addr_size6_attr_user_hwtcl \
                core4_1_cii_range_6_k_cii_addr_size6_attr_user_hwtcl \
                core4_1_cii_range_6_k_cii_addr_size6_attr_hwtcl \
                core4_1_cii_range_7_k_cii_pf_en7_attr_user_hwtcl \
                core4_1_cii_range_7_k_cii_pf_en7_attr_hwtcl \
                core4_1_cii_range_7_k_cii_start_addr7_attr_user_hwtcl \
                core4_1_cii_range_7_k_cii_start_addr7_attr_hwtcl \
                core4_1_cii_range_7_k_cii_addr_size7_attr_user_hwtcl \
                core4_1_cii_range_7_k_cii_addr_size7_attr_user_hwtcl \
                core4_1_cii_range_7_k_cii_addr_size7_attr_hwtcl \
                core4_1_virtual_pf0_msix_enable_user_hwtcl \
                core4_1_virtual_pf1_msix_enable_user_hwtcl \
                core4_1_virtual_pf2_msix_enable_user_hwtcl \
                core4_1_virtual_pf3_msix_enable_user_hwtcl \
                core4_1_virtual_pf4_msix_enable_user_hwtcl \
                core4_1_virtual_pf5_msix_enable_user_hwtcl \
                core4_1_virtual_pf6_msix_enable_user_hwtcl \
                core4_1_virtual_pf7_msix_enable_user_hwtcl \
                core4_1_virtual_pf1_msix_enable_hwtcl \
                core4_1_virtual_pf2_msix_enable_hwtcl \
                core4_1_virtual_pf3_msix_enable_hwtcl \
                core4_1_virtual_pf4_msix_enable_hwtcl \
                core4_1_virtual_pf5_msix_enable_hwtcl \
                core4_1_virtual_pf6_msix_enable_hwtcl \
                core4_1_virtual_pf7_msix_enable_hwtcl \
                core4_1_pf1_pci_msix_table_size_hwtcl \
                core4_1_pf1_pci_msix_table_offset_hwtcl \
                core4_1_pf1_pci_msix_bir_hwtcl \
                core4_1_pf1_pci_msix_pba_offset_hwtcl \
                core4_1_pf1_pci_msix_pba_hwtcl \
                core4_1_pf1_pci_msix_table_size_vfcomm_cs2_hwtcl \
                core4_1_pf2_pci_msix_table_size_hwtcl \
                core4_1_pf2_pci_msix_table_offset_hwtcl \
                core4_1_pf2_pci_msix_bir_hwtcl \
                core4_1_pf2_pci_msix_pba_offset_hwtcl \
                core4_1_pf2_pci_msix_pba_hwtcl \
                core4_1_pf2_pci_msix_table_size_vfcomm_cs2_hwtcl \
                core4_1_pf3_pci_msix_table_size_hwtcl \
                core4_1_pf3_pci_msix_table_offset_hwtcl \
                core4_1_pf3_pci_msix_bir_hwtcl \
                core4_1_pf3_pci_msix_pba_offset_hwtcl \
                core4_1_pf3_pci_msix_pba_hwtcl \
                core4_1_pf3_pci_msix_table_size_vfcomm_cs2_hwtcl \
                core4_1_pf4_pci_msix_table_size_hwtcl \
                core4_1_pf4_pci_msix_table_offset_hwtcl \
                core4_1_pf4_pci_msix_bir_hwtcl \
                core4_1_pf4_pci_msix_pba_offset_hwtcl \
                core4_1_pf4_pci_msix_pba_hwtcl \
                core4_1_pf4_pci_msix_table_size_vfcomm_cs2_hwtcl \
                core4_1_pf5_pci_msix_table_size_hwtcl \
                core4_1_pf5_pci_msix_table_offset_hwtcl \
                core4_1_pf5_pci_msix_bir_hwtcl \
                core4_1_pf5_pci_msix_pba_offset_hwtcl \
                core4_1_pf5_pci_msix_pba_hwtcl \
                core4_1_pf5_pci_msix_table_size_vfcomm_cs2_hwtcl \
                core4_1_pf6_pci_msix_table_size_hwtcl \
                core4_1_pf6_pci_msix_table_offset_hwtcl \
                core4_1_pf6_pci_msix_bir_hwtcl \
                core4_1_pf6_pci_msix_pba_offset_hwtcl \
                core4_1_pf6_pci_msix_pba_hwtcl \
                core4_1_pf6_pci_msix_table_size_vfcomm_cs2_hwtcl \
                core4_1_pf7_pci_msix_table_size_hwtcl \
                core4_1_pf7_pci_msix_table_offset_hwtcl \
                core4_1_pf7_pci_msix_bir_hwtcl \
                core4_1_pf7_pci_msix_pba_offset_hwtcl \
                core4_1_pf7_pci_msix_pba_hwtcl \
                core4_1_pf7_pci_msix_table_size_vfcomm_cs2_hwtcl \
                core4_1_virtual_pf0_exvf_msix_cap_enable_hwtcl \
                core4_1_exvf_msix_tablesize_pf0 \
                core4_1_exvf_msixtable_offset_pf0 \
                core4_1_exvf_msixtable_bir_pf0 \
                core4_1_exvf_msixpba_offset_pf0 \
                core4_1_virtual_pf1_exvf_msix_cap_enable_hwtcl \
                core4_1_exvf_msix_tablesize_pf1 \
                core4_1_exvf_msixtable_offset_pf1 \
                core4_1_exvf_msixtable_bir_pf1 \
                core4_1_exvf_msixpba_offset_pf1 \
                core4_1_virtual_pf2_exvf_msix_cap_enable_hwtcl \
                core4_1_exvf_msix_tablesize_pf2 \
                core4_1_exvf_msixtable_offset_pf2 \
                core4_1_exvf_msixtable_bir_pf2 \
                core4_1_exvf_msixpba_offset_pf2 \
                core4_1_virtual_pf3_exvf_msix_cap_enable_hwtcl \
                core4_1_exvf_msix_tablesize_pf3 \
                core4_1_exvf_msixtable_offset_pf3 \
                core4_1_exvf_msixtable_bir_pf3 \
                core4_1_exvf_msixpba_offset_pf3 \
                core4_1_virtual_pf4_exvf_msix_cap_enable_hwtcl \
                core4_1_exvf_msix_tablesize_pf4 \
                core4_1_exvf_msixtable_offset_pf4 \
                core4_1_exvf_msixtable_bir_pf4 \
                core4_1_exvf_msixpba_offset_pf4 \
                core4_1_virtual_pf5_exvf_msix_cap_enable_hwtcl \
                core4_1_exvf_msix_tablesize_pf5 \
                core4_1_exvf_msixtable_offset_pf5 \
                core4_1_exvf_msixtable_bir_pf5 \
                core4_1_exvf_msixpba_offset_pf5 \
                core4_1_virtual_pf6_exvf_msix_cap_enable_hwtcl \
                core4_1_exvf_msix_tablesize_pf6 \
                core4_1_exvf_msixtable_offset_pf6 \
                core4_1_exvf_msixtable_bir_pf6 \
                core4_1_exvf_msixpba_offset_pf6 \
                core4_1_virtual_pf7_exvf_msix_cap_enable_hwtcl \
                core4_1_exvf_msix_tablesize_pf7 \
                core4_1_exvf_msixtable_offset_pf7 \
                core4_1_exvf_msixtable_bir_pf7 \
                core4_1_exvf_msixpba_offset_pf7 \
                core4_1_virtual_pf0_pasid_cap_enable_hwtcl \
                core4_1_pf0_pasid_cap_execute_permission_supported \
                core4_1_pf0_pasid_cap_privileged_mode_supported \
                core4_1_pf0_pasid_cap_max_pasid_width \
                core4_1_virtual_pf1_pasid_cap_enable_hwtcl \
                core4_1_pf1_pasid_cap_execute_permission_supported \
                core4_1_pf1_pasid_cap_privileged_mode_supported \
                core4_1_pf1_pasid_cap_max_pasid_width \
                core4_1_virtual_pf2_pasid_cap_enable_hwtcl \
                core4_1_pf2_pasid_cap_execute_permission_supported \
                core4_1_pf2_pasid_cap_privileged_mode_supported \
                core4_1_pf2_pasid_cap_max_pasid_width \
                core4_1_virtual_pf3_pasid_cap_enable_hwtcl \
                core4_1_pf3_pasid_cap_execute_permission_supported \
                core4_1_pf3_pasid_cap_privileged_mode_supported \
                core4_1_pf3_pasid_cap_max_pasid_width \
                core4_1_virtual_pf4_pasid_cap_enable_hwtcl \
                core4_1_pf4_pasid_cap_execute_permission_supported \
                core4_1_pf4_pasid_cap_privileged_mode_supported \
                core4_1_pf4_pasid_cap_max_pasid_width \
                core4_1_virtual_pf5_pasid_cap_enable_hwtcl \
                core4_1_pf5_pasid_cap_execute_permission_supported \
                core4_1_pf5_pasid_cap_privileged_mode_supported \
                core4_1_pf5_pasid_cap_max_pasid_width \
-               core4_1_virtual_pf6_pasid_cap_enable_hwtcl \
                core4_1_pf6_pasid_cap_execute_permission_supported \
                core4_1_pf6_pasid_cap_privileged_mode_supported \
                core4_1_pf6_pasid_cap_max_pasid_width \
                core4_1_virtual_pf7_pasid_cap_enable_hwtcl \
                core4_1_pf7_pasid_cap_execute_permission_supported \
                core4_1_pf7_pasid_cap_privileged_mode_supported \
                core4_1_pf7_pasid_cap_max_pasid_width \
                core4_1_virtual_pf1_prs_ext_cap_enable_hwtcl \
                core4_1_virtual_pf2_prs_ext_cap_enable_hwtcl \
                core4_1_virtual_pf3_prs_ext_cap_enable_hwtcl \
                core4_1_virtual_pf4_prs_ext_cap_enable_hwtcl \
                core4_1_virtual_pf5_prs_ext_cap_enable_hwtcl \
                core4_1_virtual_pf6_prs_ext_cap_enable_hwtcl \
                core4_1_virtual_pf7_prs_ext_cap_enable_hwtcl \
                core4_1_pf1_prs_outstanding_capacity_hwtcl \
                core4_1_pf2_prs_outstanding_capacity_hwtcl \
                core4_1_pf3_prs_outstanding_capacity_hwtcl \
                core4_1_pf4_prs_outstanding_capacity_hwtcl \
                core4_1_pf5_prs_outstanding_capacity_hwtcl \
                core4_1_pf6_prs_outstanding_capacity_hwtcl \
                core4_1_pf7_prs_outstanding_capacity_hwtcl \
                core4_1_virtual_pf1_acs_cap_enable_hwtcl \
                core4_1_virtual_pf2_acs_cap_enable_hwtcl \
                core4_1_virtual_pf3_acs_cap_enable_hwtcl \
                core4_1_virtual_pf4_acs_cap_enable_hwtcl \
                core4_1_virtual_pf5_acs_cap_enable_hwtcl \
                core4_1_virtual_pf6_acs_cap_enable_hwtcl \
                core4_1_virtual_pf7_acs_cap_enable_hwtcl \
                core4_1_pf1_acs_cap_acs_p2p_egress_control_hwtcl \
                core4_1_pf2_acs_cap_acs_p2p_egress_control_hwtcl \
                core4_1_pf3_acs_cap_acs_p2p_egress_control_hwtcl \
                core4_1_pf4_acs_cap_acs_p2p_egress_control_hwtcl \
                core4_1_pf5_acs_cap_acs_p2p_egress_control_hwtcl \
                core4_1_pf6_acs_cap_acs_p2p_egress_control_hwtcl \
                core4_1_pf7_acs_cap_acs_p2p_egress_control_hwtcl \
                core4_1_pf0_int_pin_hwtcl \
                core4_1_pf1_int_pin_hwtcl \
                core4_1_pf2_int_pin_hwtcl \
                core4_1_pf3_int_pin_hwtcl \
                core4_1_pf4_int_pin_hwtcl \
                core4_1_pf5_int_pin_hwtcl \
                core4_1_pf6_int_pin_hwtcl \
                core4_1_pf7_int_pin_hwtcl \
                core4_1_virtual_pf0_msi_enable_hwtcl \
                core4_1_virtual_pf1_msi_enable_hwtcl \
                core4_1_virtual_pf2_msi_enable_hwtcl \
                core4_1_virtual_pf3_msi_enable_hwtcl \
                core4_1_virtual_pf4_msi_enable_hwtcl \
                core4_1_virtual_pf5_msi_enable_hwtcl \
                core4_1_virtual_pf6_msi_enable_hwtcl \
                core4_1_virtual_pf7_msi_enable_hwtcl \
                core4_1_enable_msi_interface_hwtcl \
                core4_1_virtual_pf0_msi_enable_user_hwtcl \
                core4_1_virtual_pf1_msi_enable_user_hwtcl \
                core4_1_virtual_pf2_msi_enable_user_hwtcl \
                core4_1_virtual_pf3_msi_enable_user_hwtcl \
                core4_1_virtual_pf4_msi_enable_user_hwtcl \
                core4_1_virtual_pf5_msi_enable_user_hwtcl \
                core4_1_virtual_pf6_msi_enable_user_hwtcl \
                core4_1_virtual_pf7_msi_enable_user_hwtcl \
                core4_1_virtual_pf0_msi_64b_addressing_user_hwtcl \
                core4_1_virtual_pf1_msi_64b_addressing_user_hwtcl \
                core4_1_virtual_pf2_msi_64b_addressing_user_hwtcl \
                core4_1_virtual_pf3_msi_64b_addressing_user_hwtcl \
                core4_1_virtual_pf4_msi_64b_addressing_user_hwtcl \
                core4_1_virtual_pf5_msi_64b_addressing_user_hwtcl \
                core4_1_virtual_pf6_msi_64b_addressing_user_hwtcl \
                core4_1_virtual_pf7_msi_64b_addressing_user_hwtcl \
                core4_1_pf0_pci_msi_ext_data_cap_hwtcl \
                core4_1_pf1_pci_msi_ext_data_cap_hwtcl \
                core4_1_pf2_pci_msi_ext_data_cap_hwtcl \
                core4_1_pf3_pci_msi_ext_data_cap_hwtcl \
                core4_1_pf4_pci_msi_ext_data_cap_hwtcl \
                core4_1_pf5_pci_msi_ext_data_cap_hwtcl \
                core4_1_pf6_pci_msi_ext_data_cap_hwtcl \
                core4_1_pf7_pci_msi_ext_data_cap_hwtcl \
                core4_1_pf0_pci_msi_multiple_msg_cap_hwtcl \
                core4_1_pf1_pci_msi_multiple_msg_cap_hwtcl \
                core4_1_pf2_pci_msi_multiple_msg_cap_hwtcl \
                core4_1_pf3_pci_msi_multiple_msg_cap_hwtcl \
                core4_1_pf4_pci_msi_multiple_msg_cap_hwtcl \
                core4_1_pf5_pci_msi_multiple_msg_cap_hwtcl \
                core4_1_pf6_pci_msi_multiple_msg_cap_hwtcl \
                core4_1_pf7_pci_msi_multiple_msg_cap_hwtcl \
                core4_1_pf0_bar0_type_user_hwtcl \
                core4_1_pf0_bar0_address_width_user_hwtcl \
                 core4_1_pf1_bar0_type_user_hwtcl \
                core4_1_pf2_bar0_type_user_hwtcl \
                core4_1_pf3_bar0_type_user_hwtcl \
                core4_1_pf1_bar0_address_width_user_hwtcl \
                core4_1_pf2_bar0_address_width_user_hwtcl \
                core4_1_pf3_bar0_address_width_user_hwtcl \
                core4_1_pf0_sriov_vf_bar0_type_user_hwtcl \
                core4_1_pf1_sriov_vf_bar0_type_user_hwtcl \
                core4_1_pf2_sriov_vf_bar0_type_user_hwtcl \
                core4_1_pf3_sriov_vf_bar0_type_user_hwtcl \
                core4_1_pf0_sriov_vf_bar0_type_hwtcl \
                core4_1_pf1_sriov_vf_bar0_type_hwtcl \
                core4_1_pf2_sriov_vf_bar0_type_hwtcl \
                core4_1_pf3_sriov_vf_bar0_type_hwtcl \
                core4_1_pf0_sriov_vf_bar0_address_width_hwtcl \
                core4_1_pf1_sriov_vf_bar0_address_width_hwtcl \
                core4_1_pf2_sriov_vf_bar0_address_width_hwtcl \
                core4_1_pf3_sriov_vf_bar0_address_width_hwtcl \
                core4_1_pf1_virtio_device_specific_cap_present_hwtcl \
                core4_1_pf2_virtio_device_specific_cap_present_hwtcl \
                core4_1_pf3_virtio_device_specific_cap_present_hwtcl \
                core4_1_pf0vf_virtio_device_specific_cap_present_hwtcl \
                core4_1_pf1vf_virtio_device_specific_cap_present_hwtcl \
                core4_1_pf2vf_virtio_device_specific_cap_present_hwtcl \
                core4_1_pf3vf_virtio_device_specific_cap_present_hwtcl \
                core4_1_exvf_msixpba_bir_pf0  \
                core4_1_exvf_msixpba_bir_pf1  \
                core4_1_exvf_msixpba_bir_pf2  \
                core4_1_exvf_msixpba_bir_pf3  \
            \
            ]
            set rtile_qhip_param [list \
                hssi_ctp_sim_mode \
                xcvr_reconfig_user_hwtcl \
                rxbuf_features_enablement_full \
                pld_clrpcs_hwtcl \
                core16_enable_cii_hwtcl \
                core8_enable_cii_hwtcl \
                core4_0_enable_cii_hwtcl \
                core4_1_enable_cii_hwtcl \
                core16_topology_integer_hwtcl \
                core16_enable_apps_ready_entr_l23_hwtcl \
                core16_enable_apps_pm_xmt_turnoff_hwtcl \
                core16_enable_app_xfer_pending_hwtcl  \
                core16_enable_10bit_tag_support_intf_hwtcl \
                core16_crs_en_default_hwtcl \
                hssi_ctp_u_wrpcie_top_u_core16_topology \
                core16_pld_crs_en_hwtcl \
                core16_virtual_txeq_mode_hwtcl \
                core16_pf0_gen3_eq_pset_req_vec_atg4_hwtcl \
                core16_enable_rx_buffer_limit_ports_hwtcl \
                core16_rxbuf_limit_posted_bypass_hwtcl \
                core16_rxbuf_limit_nonposted_bypass_hwtcl \
                core16_rxbuf_limit_cpl_bypass_hwtcl \
                core16_rxbuf_limit_bypass_hwtcl \
                core16_pf0_dsp_16g_tx_preset_hwtcl \
                core16_pf0_dsp_tx_preset_hwtcl \
                core16_pf0_usp_16g_tx_preset_hwtcl \
                core16_pf0_usp_tx_preset_hwtcl \
                core16_pf_no_soft_rst_hwtcl \
                core16_virtual_hrdrstctrl_en_hwtcl \
                core16_virtual_uc_calibration_en_hwtcl \
                core16_pf0_rp_rom_bar_enabled_hwtcl \
                core16_pf0_pcie_cap_rcb_hwtcl \
                core16_pf1_pcie_cap_rcb_hwtcl \
                core16_pf2_pcie_cap_rcb_hwtcl \
                core16_pf3_pcie_cap_rcb_hwtcl \
                core16_pf4_pcie_cap_rcb_hwtcl \
                core16_pf5_pcie_cap_rcb_hwtcl \
                core16_pf6_pcie_cap_rcb_hwtcl \
                core16_pf7_pcie_cap_rcb_hwtcl \
                core16_pld_clrpcs_user_hwtcl \
                core16_pld_clrpcs_hwtcl \
                core16_pf0_gen3_eq_pset_req_vec_atg4_a0_user_hwtcl \
                core16_pf0_gen3_eq_pset_req_vec_atg4_b0_user_hwtcl \
                core16_pf0_gen3_eq_pset_req_vec_b0_user_hwtcl \
                core16_pf0_gen3_eq_pset_req_vec_atg4_c0_user_hwtcl \
                core16_pf0_gen3_eq_pset_req_vec_c0_user_hwtcl \
                core16_pf0_dsp_rx_preset_hint_hwtcl \
                core16_pf0_usp_rx_preset_hint_hwtcl \
                core16_enable_pld_rst_port0_hwtcl \
                core16_pf0_sriov_vf_bar0_type_user__hwtcl\
                core8_pf0_sriov_vf_bar0_type_user__hwtcl\
                core16_pf0_sriov_vf_bar0_type_int_hwtcl \
                core16_pf0_sriov_vf_bar0_address_width_int_hwtcl \
                core16_pf0_sriov_vf_bar1_type_int_hwtcl \
                core16_pf0_sriov_vf_bar1_address_width_int_hwtcl \
                core16_pf0_sriov_vf_bar2_type_int_hwtcl \
                core16_pf0_sriov_vf_bar2_address_width_int_hwtcl \
                core16_pf0_sriov_vf_bar3_type_int_hwtcl \
                core16_pf0_sriov_vf_bar3_address_width_int_hwtcl \
                core16_pf0_sriov_vf_bar4_type_int_hwtcl \
                core16_pf0_sriov_vf_bar4_address_width_int_hwtcl \
                core16_pf0_sriov_vf_bar5_type_int_hwtcl \
                core16_pf0_sriov_vf_bar5_address_width_int_hwtcl \
                core16_pf1_sriov_vf_bar0_type_int_hwtcl \
                core16_pf1_sriov_vf_bar0_address_width_int_hwtcl \
                core16_pf1_sriov_vf_bar1_type_int_hwtcl \
                core16_pf1_sriov_vf_bar1_address_width_int_hwtcl \
                core16_pf1_sriov_vf_bar2_type_int_hwtcl \
                core16_pf1_sriov_vf_bar2_address_width_int_hwtcl \
                core16_pf1_sriov_vf_bar3_type_int_hwtcl \
                core16_pf1_sriov_vf_bar3_address_width_int_hwtcl \
                core16_pf1_sriov_vf_bar4_type_int_hwtcl \
                core16_pf1_sriov_vf_bar4_address_width_int_hwtcl \
                core16_pf1_sriov_vf_bar5_type_int_hwtcl \
                core16_pf1_sriov_vf_bar5_address_width_int_hwtcl \
                core16_pf2_sriov_vf_bar0_type_int_hwtcl \
                core16_pf2_sriov_vf_bar0_address_width_int_hwtcl \
                core16_pf2_sriov_vf_bar1_type_int_hwtcl \
                core16_pf2_sriov_vf_bar1_address_width_int_hwtcl \
                core16_pf2_sriov_vf_bar2_type_int_hwtcl \
                core16_pf2_sriov_vf_bar2_address_width_int_hwtcl \
                core16_pf2_sriov_vf_bar3_type_int_hwtcl \
                core16_pf2_sriov_vf_bar3_address_width_int_hwtcl \
                core16_pf2_sriov_vf_bar4_type_int_hwtcl \
                core16_pf2_sriov_vf_bar4_address_width_int_hwtcl \
                core16_pf2_sriov_vf_bar5_type_int_hwtcl \
                core16_pf2_sriov_vf_bar5_address_width_int_hwtcl \
                core16_pf3_sriov_vf_bar0_type_int_hwtcl \
                core16_pf3_sriov_vf_bar0_address_width_int_hwtcl \
                core16_pf3_sriov_vf_bar1_type_int_hwtcl \
                core16_pf3_sriov_vf_bar1_address_width_int_hwtcl \
                core16_pf3_sriov_vf_bar2_type_int_hwtcl \
                core16_pf3_sriov_vf_bar2_address_width_int_hwtcl \
                core16_pf3_sriov_vf_bar3_type_int_hwtcl \
                core16_pf3_sriov_vf_bar3_address_width_int_hwtcl \
                core16_pf3_sriov_vf_bar4_type_int_hwtcl \
                core16_pf3_sriov_vf_bar4_address_width_int_hwtcl \
                core16_pf3_sriov_vf_bar5_type_int_hwtcl \
                core16_pf3_sriov_vf_bar5_address_width_int_hwtcl \
                core16_pf4_sriov_vf_bar0_type_int_hwtcl \
                core16_pf4_sriov_vf_bar0_address_width_int_hwtcl \
                core16_pf4_sriov_vf_bar1_type_int_hwtcl \
                core16_pf4_sriov_vf_bar1_address_width_int_hwtcl \
                core16_pf4_sriov_vf_bar2_type_int_hwtcl \
                core16_pf4_sriov_vf_bar2_address_width_int_hwtcl \
                core16_pf4_sriov_vf_bar3_type_int_hwtcl \
                core16_pf4_sriov_vf_bar3_address_width_int_hwtcl \
                core16_pf4_sriov_vf_bar4_type_int_hwtcl \
                core16_pf4_sriov_vf_bar4_address_width_int_hwtcl \
                core16_pf4_sriov_vf_bar5_type_int_hwtcl \
                core16_pf4_sriov_vf_bar5_address_width_int_hwtcl \
                core16_pf5_sriov_vf_bar0_type_int_hwtcl \
                core16_pf5_sriov_vf_bar0_address_width_int_hwtcl \
                core16_pf5_sriov_vf_bar1_type_int_hwtcl \
                core16_pf5_sriov_vf_bar1_address_width_int_hwtcl \
                core16_pf5_sriov_vf_bar2_type_int_hwtcl \
                core16_pf5_sriov_vf_bar2_address_width_int_hwtcl \
                core16_pf5_sriov_vf_bar3_type_int_hwtcl \
                core16_pf5_sriov_vf_bar3_address_width_int_hwtcl \
                core16_pf5_sriov_vf_bar4_type_int_hwtcl \
                core16_pf5_sriov_vf_bar4_address_width_int_hwtcl \
                core16_pf5_sriov_vf_bar5_type_int_hwtcl \
                core16_pf5_sriov_vf_bar5_address_width_int_hwtcl \
                core16_pf6_sriov_vf_bar0_type_int_hwtcl \
                core16_pf6_sriov_vf_bar0_address_width_int_hwtcl \
                core16_pf6_sriov_vf_bar1_type_int_hwtcl \
                core16_pf6_sriov_vf_bar1_address_width_int_hwtcl \
                core16_pf6_sriov_vf_bar2_type_int_hwtcl \
                core16_pf6_sriov_vf_bar2_address_width_int_hwtcl \
                core16_pf6_sriov_vf_bar3_type_int_hwtcl \
                core16_pf6_sriov_vf_bar3_address_width_int_hwtcl \
                core16_pf6_sriov_vf_bar4_type_int_hwtcl \
                core16_pf6_sriov_vf_bar4_address_width_int_hwtcl \
                core16_pf6_sriov_vf_bar5_type_int_hwtcl \
                core16_pf6_sriov_vf_bar5_address_width_int_hwtcl \
                core16_pf7_sriov_vf_bar0_type_int_hwtcl \
                core16_pf7_sriov_vf_bar0_address_width_int_hwtcl \
                core16_pf7_sriov_vf_bar1_type_int_hwtcl \
                core16_pf7_sriov_vf_bar1_address_width_int_hwtcl \
                core16_pf7_sriov_vf_bar2_type_int_hwtcl \
                core16_pf7_sriov_vf_bar2_address_width_int_hwtcl \
                core16_pf7_sriov_vf_bar3_type_int_hwtcl \
                core16_pf7_sriov_vf_bar3_address_width_int_hwtcl \
                core16_pf7_sriov_vf_bar4_type_int_hwtcl \
                core16_pf7_sriov_vf_bar4_address_width_int_hwtcl \
                core16_pf7_sriov_vf_bar5_type_int_hwtcl \
                core16_pf7_sriov_vf_bar5_address_width_int_hwtcl \
                core16_pf0_expansion_base_address_register_integer_hwtcl \
                core16_pf1_expansion_base_address_register_integer_hwtcl \
                core16_pf2_expansion_base_address_register_integer_hwtcl \
                core16_pf3_expansion_base_address_register_integer_hwtcl \
                core16_pf4_expansion_base_address_register_integer_hwtcl \
                core16_pf5_expansion_base_address_register_integer_hwtcl \
                core16_pf6_expansion_base_address_register_integer_hwtcl \
                core16_pf7_expansion_base_address_register_integer_hwtcl \
                core16_cap_ext_tag_supp_user_hwtcl \
                core16_pf0_pcie_cap_ext_tag_supp_hwtcl \
                core16_pf1_pcie_cap_ext_tag_supp_hwtcl \
                core16_pf2_pcie_cap_ext_tag_supp_hwtcl \
                core16_pf3_pcie_cap_ext_tag_supp_hwtcl \
                core16_pf4_pcie_cap_ext_tag_supp_hwtcl \
                core16_pf5_pcie_cap_ext_tag_supp_hwtcl \
                core16_pf6_pcie_cap_ext_tag_supp_hwtcl \
                core16_pf7_pcie_cap_ext_tag_supp_hwtcl \
                core16_pf0_pcie_cap_ep_l0s_accpt_latency_hwtcl \
                core16_pf1_pcie_cap_ep_l0s_accpt_latency_hwtcl \
                core16_pf2_pcie_cap_ep_l0s_accpt_latency_hwtcl \
                core16_pf3_pcie_cap_ep_l0s_accpt_latency_hwtcl \
                core16_pf4_pcie_cap_ep_l0s_accpt_latency_hwtcl \
                core16_pf5_pcie_cap_ep_l0s_accpt_latency_hwtcl \
                core16_pf6_pcie_cap_ep_l0s_accpt_latency_hwtcl \
                core16_pf7_pcie_cap_ep_l0s_accpt_latency_hwtcl \
                core16_pf0_pcie_cap_ep_l1_accpt_latency_hwtcl \
                core16_pf1_pcie_cap_ep_l1_accpt_latency_hwtcl \
                core16_pf2_pcie_cap_ep_l1_accpt_latency_hwtcl \
                core16_pf3_pcie_cap_ep_l1_accpt_latency_hwtcl \
                core16_pf4_pcie_cap_ep_l1_accpt_latency_hwtcl \
                core16_pf5_pcie_cap_ep_l1_accpt_latency_hwtcl \
                core16_pf6_pcie_cap_ep_l1_accpt_latency_hwtcl \
                core16_pf7_pcie_cap_ep_l1_accpt_latency_hwtcl \
                core16_pcie_cvp_attr_hwtcl \
                core16_cfg_ptm_local_clock_adj_lsb_hwtcl \
                core16_cfg_ptm_local_clock_adj_msb_hwtcl \
                core16_pf1_pci_type0_vendor_id_hwtcl \
                core16_pf1_revision_id_hwtcl \
                core16_pf2_pci_type0_vendor_id_hwtcl \
                core16_pf2_revision_id_hwtcl \
                core16_pf3_pci_type0_vendor_id_hwtcl \
                core16_pf3_revision_id_hwtcl \
                core16_pf4_pci_type0_vendor_id_hwtcl \
                core16_pf4_revision_id_hwtcl \
                core16_pf5_pci_type0_vendor_id_hwtcl \
                core16_pf5_revision_id_hwtcl \
                core16_pf6_pci_type0_vendor_id_hwtcl \
                core16_pf6_revision_id_hwtcl \
                core16_pf7_pci_type0_vendor_id_hwtcl \
                core16_pf7_revision_id_hwtcl \
                core16_vendor_id_hwtcl \
                core16_revision_id_hwtcl \
                core16_vsec_next_offset_hwtcl \
                core16_pf0_tph_req_cap_st_table_loc_0_vfcomm_cs2_hwtcl  \
                core16_pf1_tph_req_cap_st_table_loc_0_vfcomm_cs2_hwtcl \
                core16_pf2_tph_req_cap_st_table_loc_0_vfcomm_cs2_hwtcl  \
                core16_pf3_tph_req_cap_st_table_loc_0_vfcomm_cs2_hwtcl \
                core16_pf4_tph_req_cap_st_table_loc_0_vfcomm_cs2_hwtcl  \
                core16_pf5_tph_req_cap_st_table_loc_0_vfcomm_cs2_hwtcl \
                core16_pf6_tph_req_cap_st_table_loc_0_vfcomm_cs2_hwtcl  \
                core16_pf7_tph_req_cap_st_table_loc_0_vfcomm_cs2_hwtcl \
                core16_virtio_start_byte_address_hwtcl \
                core16_avmm_enabled_virtio_hwtcl  \
                core8_topology_integer_hwtcl \
                core8_enable_apps_ready_entr_l23_hwtcl \
                core8_enable_apps_pm_xmt_turnoff_hwtcl \
                core8_enable_app_xfer_pending_hwtcl  \
                core8_enable_10bit_tag_support_intf_hwtcl \
                hssi_ctp_u_wrpcie_top_u_core8_topology \
                core8_pld_crs_en_hwtcl \
                core8_virtual_txeq_mode_hwtcl \
                core8_pf0_gen3_eq_pset_req_vec_atg4_hwtcl \
                core8_enable_rx_buffer_limit_ports_hwtcl \
                core8_rxbuf_limit_posted_bypass_hwtcl \
                core8_rxbuf_limit_nonposted_bypass_hwtcl \
                core8_rxbuf_limit_cpl_bypass_hwtcl \
                core8_rxbuf_limit_bypass_hwtcl \
                core8_pf0_dsp_16g_tx_preset_hwtcl \
                core8_pf0_dsp_tx_preset_hwtcl \
                core8_pf0_usp_16g_tx_preset_hwtcl \
                core8_pf0_usp_tx_preset_hwtcl \
                core8_pf_no_soft_rst_hwtcl \
                core8_virtual_hrdrstctrl_en_hwtcl \
                core8_virtual_uc_calibration_en_hwtcl \
                core8_pf0_rp_rom_bar_enabled_hwtcl \
                core8_pf0_pcie_cap_rcb_hwtcl \
                core8_pf1_pcie_cap_rcb_hwtcl \
                core8_pf2_pcie_cap_rcb_hwtcl \
                core8_pf3_pcie_cap_rcb_hwtcl \
                core8_pf4_pcie_cap_rcb_hwtcl \
                core8_pf5_pcie_cap_rcb_hwtcl \
                core8_pf6_pcie_cap_rcb_hwtcl \
                core8_pf7_pcie_cap_rcb_hwtcl \
                core8_pld_clrpcs_user_hwtcl \
                core8_pld_clrpcs_hwtcl \
                core8_crs_en_default_hwtcl \
                core8_pf0_gen3_eq_pset_req_vec_atg4_a0_user_hwtcl \
                core8_pf0_gen3_eq_pset_req_vec_atg4_b0_user_hwtcl \
                core8_pf0_gen3_eq_pset_req_vec_b0_user_hwtcl \
                core8_pf0_gen3_eq_pset_req_vec_atg4_c0_user_hwtcl \
                core8_pf0_gen3_eq_pset_req_vec_c0_user_hwtcl \
                core8_pf0_dsp_rx_preset_hint_hwtcl \
                core8_pf0_usp_rx_preset_hint_hwtcl \
                core8_enable_pld_rst_port0_hwtcl \
                core8_pf0_sriov_vf_bar0_type_int_hwtcl \
                core8_pf0_sriov_vf_bar0_address_width_int_hwtcl \
                core8_pf0_sriov_vf_bar1_type_int_hwtcl \
                core8_pf0_sriov_vf_bar1_address_width_int_hwtcl \
                core8_pf0_sriov_vf_bar2_type_int_hwtcl \
                core8_pf0_sriov_vf_bar2_address_width_int_hwtcl \
                core8_pf0_sriov_vf_bar3_type_int_hwtcl \
                core8_pf0_sriov_vf_bar3_address_width_int_hwtcl \
                core8_pf0_sriov_vf_bar4_type_int_hwtcl \
                core8_pf0_sriov_vf_bar4_address_width_int_hwtcl \
                core8_pf0_sriov_vf_bar5_type_int_hwtcl \
                core8_pf0_sriov_vf_bar5_address_width_int_hwtcl \
                core8_pf1_sriov_vf_bar0_type_int_hwtcl \
                core8_pf1_sriov_vf_bar0_address_width_int_hwtcl \
                core8_pf1_sriov_vf_bar1_type_int_hwtcl \
                core8_pf1_sriov_vf_bar1_address_width_int_hwtcl \
                core8_pf1_sriov_vf_bar2_type_int_hwtcl \
                core8_pf1_sriov_vf_bar2_address_width_int_hwtcl \
                core8_pf1_sriov_vf_bar3_type_int_hwtcl \
                core8_pf1_sriov_vf_bar3_address_width_int_hwtcl \
                core8_pf1_sriov_vf_bar4_type_int_hwtcl \
                core8_pf1_sriov_vf_bar4_address_width_int_hwtcl \
                core8_pf1_sriov_vf_bar5_type_int_hwtcl \
                core8_pf1_sriov_vf_bar5_address_width_int_hwtcl \
                core8_pf2_sriov_vf_bar0_type_int_hwtcl \
                core8_pf2_sriov_vf_bar0_address_width_int_hwtcl \
                core8_pf2_sriov_vf_bar1_type_int_hwtcl \
                core8_pf2_sriov_vf_bar1_address_width_int_hwtcl \
                core8_pf2_sriov_vf_bar2_type_int_hwtcl \
                core8_pf2_sriov_vf_bar2_address_width_int_hwtcl \
                core8_pf2_sriov_vf_bar3_type_int_hwtcl \
                core8_pf2_sriov_vf_bar3_address_width_int_hwtcl \
                core8_pf2_sriov_vf_bar4_type_int_hwtcl \
                core8_pf2_sriov_vf_bar4_address_width_int_hwtcl \
                core8_pf2_sriov_vf_bar5_type_int_hwtcl \
                core8_pf2_sriov_vf_bar5_address_width_int_hwtcl \
                core8_pf3_sriov_vf_bar0_type_int_hwtcl \
                core8_pf3_sriov_vf_bar0_address_width_int_hwtcl \
                core8_pf3_sriov_vf_bar1_type_int_hwtcl \
                core8_pf3_sriov_vf_bar1_address_width_int_hwtcl \
                core8_pf3_sriov_vf_bar2_type_int_hwtcl \
                core8_pf3_sriov_vf_bar2_address_width_int_hwtcl \
                core8_pf3_sriov_vf_bar3_type_int_hwtcl \
                core8_pf3_sriov_vf_bar3_address_width_int_hwtcl \
                core8_pf3_sriov_vf_bar4_type_int_hwtcl \
                core8_pf3_sriov_vf_bar4_address_width_int_hwtcl \
                core8_pf3_sriov_vf_bar5_type_int_hwtcl \
                core8_pf3_sriov_vf_bar5_address_width_int_hwtcl \
                core8_pf4_sriov_vf_bar0_type_int_hwtcl \
                core8_pf4_sriov_vf_bar0_address_width_int_hwtcl \
                core8_pf4_sriov_vf_bar1_type_int_hwtcl \
                core8_pf4_sriov_vf_bar1_address_width_int_hwtcl \
                core8_pf4_sriov_vf_bar2_type_int_hwtcl \
                core8_pf4_sriov_vf_bar2_address_width_int_hwtcl \
                core8_pf4_sriov_vf_bar3_type_int_hwtcl \
                core8_pf4_sriov_vf_bar3_address_width_int_hwtcl \
                core8_pf4_sriov_vf_bar4_type_int_hwtcl \
                core8_pf4_sriov_vf_bar4_address_width_int_hwtcl \
                core8_pf4_sriov_vf_bar5_type_int_hwtcl \
                core8_pf4_sriov_vf_bar5_address_width_int_hwtcl \
                core8_pf5_sriov_vf_bar0_type_int_hwtcl \
                core8_pf5_sriov_vf_bar0_address_width_int_hwtcl \
                core8_pf5_sriov_vf_bar1_type_int_hwtcl \
                core8_pf5_sriov_vf_bar1_address_width_int_hwtcl \
                core8_pf5_sriov_vf_bar2_type_int_hwtcl \
                core8_pf5_sriov_vf_bar2_address_width_int_hwtcl \
                core8_pf5_sriov_vf_bar3_type_int_hwtcl \
                core8_pf5_sriov_vf_bar3_address_width_int_hwtcl \
                core8_pf5_sriov_vf_bar4_type_int_hwtcl \
                core8_pf5_sriov_vf_bar4_address_width_int_hwtcl \
                core8_pf5_sriov_vf_bar5_type_int_hwtcl \
                core8_pf5_sriov_vf_bar5_address_width_int_hwtcl \
                core8_pf6_sriov_vf_bar0_type_int_hwtcl \
                core8_pf6_sriov_vf_bar0_address_width_int_hwtcl \
                core8_pf6_sriov_vf_bar1_type_int_hwtcl \
                core8_pf6_sriov_vf_bar1_address_width_int_hwtcl \
                core8_pf6_sriov_vf_bar2_type_int_hwtcl \
                core8_pf6_sriov_vf_bar2_address_width_int_hwtcl \
                core8_pf6_sriov_vf_bar3_type_int_hwtcl \
                core8_pf6_sriov_vf_bar3_address_width_int_hwtcl \
                core8_pf6_sriov_vf_bar4_type_int_hwtcl \
                core8_pf6_sriov_vf_bar4_address_width_int_hwtcl \
                core8_pf6_sriov_vf_bar5_type_int_hwtcl \
                core8_pf6_sriov_vf_bar5_address_width_int_hwtcl \
                core8_pf7_sriov_vf_bar0_type_int_hwtcl \
                core8_pf7_sriov_vf_bar0_address_width_int_hwtcl \
                core8_pf7_sriov_vf_bar1_type_int_hwtcl \
                core8_pf7_sriov_vf_bar1_address_width_int_hwtcl \
                core8_pf7_sriov_vf_bar2_type_int_hwtcl \
                core8_pf7_sriov_vf_bar2_address_width_int_hwtcl \
                core8_pf7_sriov_vf_bar3_type_int_hwtcl \
                core8_pf7_sriov_vf_bar3_address_width_int_hwtcl \
                core8_pf7_sriov_vf_bar4_type_int_hwtcl \
                core8_pf7_sriov_vf_bar4_address_width_int_hwtcl \
                core8_pf7_sriov_vf_bar5_type_int_hwtcl \
                core8_pf7_sriov_vf_bar5_address_width_int_hwtcl \
                core8_pf0_expansion_base_address_register_integer_hwtcl \
                core8_pf1_expansion_base_address_register_integer_hwtcl \
                core8_pf2_expansion_base_address_register_integer_hwtcl \
                core8_pf3_expansion_base_address_register_integer_hwtcl \
                core8_pf4_expansion_base_address_register_integer_hwtcl \
                core8_pf5_expansion_base_address_register_integer_hwtcl \
                core8_pf6_expansion_base_address_register_integer_hwtcl \
                core8_pf7_expansion_base_address_register_integer_hwtcl \
                core8_cap_ext_tag_supp_user_hwtcl \
                core8_pf0_pcie_cap_ext_tag_supp_hwtcl \
                core8_pf1_pcie_cap_ext_tag_supp_hwtcl \
                core8_pf2_pcie_cap_ext_tag_supp_hwtcl \
                core8_pf3_pcie_cap_ext_tag_supp_hwtcl \
                core8_pf4_pcie_cap_ext_tag_supp_hwtcl \
                core8_pf5_pcie_cap_ext_tag_supp_hwtcl \
                core8_pf6_pcie_cap_ext_tag_supp_hwtcl \
                core8_pf7_pcie_cap_ext_tag_supp_hwtcl \
                core8_pf0_pcie_cap_ep_l0s_accpt_latency_hwtcl \
                core8_pf1_pcie_cap_ep_l0s_accpt_latency_hwtcl \
                core8_pf2_pcie_cap_ep_l0s_accpt_latency_hwtcl \
                core8_pf3_pcie_cap_ep_l0s_accpt_latency_hwtcl \
                core8_pf4_pcie_cap_ep_l0s_accpt_latency_hwtcl \
                core8_pf5_pcie_cap_ep_l0s_accpt_latency_hwtcl \
                core8_pf6_pcie_cap_ep_l0s_accpt_latency_hwtcl \
                core8_pf7_pcie_cap_ep_l0s_accpt_latency_hwtcl \
                core8_pf0_pcie_cap_ep_l1_accpt_latency_hwtcl \
                core8_pf1_pcie_cap_ep_l1_accpt_latency_hwtcl \
                core8_pf2_pcie_cap_ep_l1_accpt_latency_hwtcl \
                core8_pf3_pcie_cap_ep_l1_accpt_latency_hwtcl \
                core8_pf4_pcie_cap_ep_l1_accpt_latency_hwtcl \
                core8_pf5_pcie_cap_ep_l1_accpt_latency_hwtcl \
                core8_pf6_pcie_cap_ep_l1_accpt_latency_hwtcl \
                core8_pf7_pcie_cap_ep_l1_accpt_latency_hwtcl \
                core8_pcie_cvp_attr_hwtcl \
                core8_cfg_ptm_local_clock_adj_lsb_hwtcl \
                core8_cfg_ptm_local_clock_adj_msb_hwtcl \
                core8_pf1_pci_type0_vendor_id_hwtcl \
                core8_pf1_revision_id_hwtcl \
                core8_pf2_pci_type0_vendor_id_hwtcl \
                core8_pf2_revision_id_hwtcl \
                core8_pf3_pci_type0_vendor_id_hwtcl \
                core8_pf3_revision_id_hwtcl \
                core8_pf4_pci_type0_vendor_id_hwtcl \
                core8_pf4_revision_id_hwtcl \
                core8_pf5_pci_type0_vendor_id_hwtcl \
                core8_pf5_revision_id_hwtcl \
                core8_pf6_pci_type0_vendor_id_hwtcl \
                core8_pf6_revision_id_hwtcl \
                core8_pf7_pci_type0_vendor_id_hwtcl \
                core8_pf7_revision_id_hwtcl \
                core8_vendor_id_hwtcl \
                core8_revision_id_hwtcl \
                core8_vsec_next_offset_hwtcl \
                core8_pf0_tph_req_cap_st_table_loc_0_vfcomm_cs2_hwtcl  \
                core8_pf1_tph_req_cap_st_table_loc_0_vfcomm_cs2_hwtcl \
                core8_pf2_tph_req_cap_st_table_loc_0_vfcomm_cs2_hwtcl  \
                core8_pf3_tph_req_cap_st_table_loc_0_vfcomm_cs2_hwtcl \
                core8_pf4_tph_req_cap_st_table_loc_0_vfcomm_cs2_hwtcl  \
                core8_pf5_tph_req_cap_st_table_loc_0_vfcomm_cs2_hwtcl \
                core8_pf6_tph_req_cap_st_table_loc_0_vfcomm_cs2_hwtcl  \
                core8_pf7_tph_req_cap_st_table_loc_0_vfcomm_cs2_hwtcl \
                core8_virtio_start_byte_address_hwtcl \
                core8_avmm_enabled_virtio_hwtcl  \
                core8_ecc_ctrl_k_nparity_ecc_attr_hwtcl \
                core8_refclk_init_active_hwtcl \
                core8_enable_independent_pin_perst_hwtcl \
                core8_txempty_enable_hwtcl \
                core8_virtual_num_of_lanes_16_hwtcl \
                core4_0_topology_integer_hwtcl \
                core4_0_enable_apps_ready_entr_l23_hwtcl \
                core4_0_enable_apps_pm_xmt_turnoff_hwtcl \
                core4_0_enable_app_xfer_pending_hwtcl  \
                core4_0_enable_10bit_tag_support_intf_hwtcl \
                hssi_ctp_u_wrpcie_top_u_core4_0_topology \
                core4_0_crs_en_default_hwtcl \
                core4_1_crs_en_default_hwtcl \
                core4_0_pld_crs_en_hwtcl \
                core4_0_virtual_txeq_mode_hwtcl \
                core4_0_pf0_gen3_eq_pset_req_vec_atg4_hwtcl \
                core4_0_enable_rx_buffer_limit_ports_hwtcl \
                core4_0_rxbuf_limit_posted_bypass_hwtcl \
                core4_0_rxbuf_limit_nonposted_bypass_hwtcl \
                core4_0_rxbuf_limit_cpl_bypass_hwtcl \
                core4_0_rxbuf_limit_bypass_hwtcl \
                core4_0_pf0_dsp_16g_tx_preset_hwtcl \
                core4_0_pf0_dsp_tx_preset_hwtcl \
                core4_0_pf0_usp_16g_tx_preset_hwtcl \
                core4_0_pf0_usp_tx_preset_hwtcl \
                core4_0_pf_no_soft_rst_hwtcl \
                core4_0_virtual_hrdrstctrl_en_hwtcl \
                core4_0_virtual_uc_calibration_en_hwtcl \
                core4_0_pf0_rp_rom_bar_enabled_hwtcl \
                core4_0_pf0_pcie_cap_rcb_hwtcl \
                core4_0_pf1_pcie_cap_rcb_hwtcl \
                core4_0_pf2_pcie_cap_rcb_hwtcl \
                core4_0_pf3_pcie_cap_rcb_hwtcl \
                core4_0_pf4_pcie_cap_rcb_hwtcl \
                core4_0_pf5_pcie_cap_rcb_hwtcl \
                core4_0_pf6_pcie_cap_rcb_hwtcl \
                core4_0_pf7_pcie_cap_rcb_hwtcl \
                core4_0_pld_clrpcs_user_hwtcl \
                core4_0_pld_clrpcs_hwtcl \
                core4_0_pf0_gen3_eq_pset_req_vec_atg4_a0_user_hwtcl \
                core4_0_pf0_gen3_eq_pset_req_vec_atg4_b0_user_hwtcl \
                core4_0_pf0_gen3_eq_pset_req_vec_b0_user_hwtcl \
                core4_0_pf0_dsp_rx_preset_hint_hwtcl \
                core4_0_pf0_usp_rx_preset_hint_hwtcl \
                core4_0_enable_pld_rst_port0_hwtcl \
                core4_0_pf0_sriov_vf_bar0_type_int_hwtcl \
                core4_0_pf0_sriov_vf_bar0_address_width_int_hwtcl \
                core4_0_pf0_sriov_vf_bar1_type_int_hwtcl \
                core4_0_pf0_sriov_vf_bar1_address_width_int_hwtcl \
                core4_0_pf0_sriov_vf_bar2_type_int_hwtcl \
                core4_0_pf0_sriov_vf_bar2_address_width_int_hwtcl \
                core4_0_pf0_sriov_vf_bar3_type_int_hwtcl \
                core4_0_pf0_sriov_vf_bar3_address_width_int_hwtcl \
                core4_0_pf0_sriov_vf_bar4_type_int_hwtcl \
                core4_0_pf0_sriov_vf_bar4_address_width_int_hwtcl \
                core4_0_pf0_sriov_vf_bar5_type_int_hwtcl \
                core4_0_pf0_sriov_vf_bar5_address_width_int_hwtcl \
                core4_0_pf1_sriov_vf_bar0_type_int_hwtcl \
                core4_0_pf1_sriov_vf_bar0_address_width_int_hwtcl \
                core4_0_pf1_sriov_vf_bar1_type_int_hwtcl \
                core4_0_pf1_sriov_vf_bar1_address_width_int_hwtcl \
                core4_0_pf1_sriov_vf_bar2_type_int_hwtcl \
                core4_0_pf1_sriov_vf_bar2_address_width_int_hwtcl \
                core4_0_pf1_sriov_vf_bar3_type_int_hwtcl \
                core4_0_pf1_sriov_vf_bar3_address_width_int_hwtcl \
                core4_0_pf1_sriov_vf_bar4_type_int_hwtcl \
                core4_0_pf1_sriov_vf_bar4_address_width_int_hwtcl \
                core4_0_pf1_sriov_vf_bar5_type_int_hwtcl \
                core4_0_pf1_sriov_vf_bar5_address_width_int_hwtcl \
                core4_0_pf2_sriov_vf_bar0_type_int_hwtcl \
                core4_0_pf2_sriov_vf_bar0_address_width_int_hwtcl \
                core4_0_pf2_sriov_vf_bar1_type_int_hwtcl \
                core4_0_pf2_sriov_vf_bar1_address_width_int_hwtcl \
                core4_0_pf2_sriov_vf_bar2_type_int_hwtcl \
                core4_0_pf2_sriov_vf_bar2_address_width_int_hwtcl \
                core4_0_pf2_sriov_vf_bar3_type_int_hwtcl \
                core4_0_pf2_sriov_vf_bar3_address_width_int_hwtcl \
                core4_0_pf2_sriov_vf_bar4_type_int_hwtcl \
                core4_0_pf2_sriov_vf_bar4_address_width_int_hwtcl \
                core4_0_pf2_sriov_vf_bar5_type_int_hwtcl \
                core4_0_pf2_sriov_vf_bar5_address_width_int_hwtcl \
                core4_0_pf3_sriov_vf_bar0_type_int_hwtcl \
                core4_0_pf3_sriov_vf_bar0_address_width_int_hwtcl \
                core4_0_pf3_sriov_vf_bar1_type_int_hwtcl \
                core4_0_pf3_sriov_vf_bar1_address_width_int_hwtcl \
                core4_0_pf3_sriov_vf_bar2_type_int_hwtcl \
                core4_0_pf3_sriov_vf_bar2_address_width_int_hwtcl \
                core4_0_pf3_sriov_vf_bar3_type_int_hwtcl \
                core4_0_pf3_sriov_vf_bar3_address_width_int_hwtcl \
                core4_0_pf3_sriov_vf_bar4_type_int_hwtcl \
                core4_0_pf3_sriov_vf_bar4_address_width_int_hwtcl \
                core4_0_pf3_sriov_vf_bar5_type_int_hwtcl \
                core4_0_pf3_sriov_vf_bar5_address_width_int_hwtcl \
                core4_0_pf4_sriov_vf_bar0_type_int_hwtcl \
                core4_0_pf4_sriov_vf_bar0_address_width_int_hwtcl \
                core4_0_pf4_sriov_vf_bar1_type_int_hwtcl \
                core4_0_pf4_sriov_vf_bar1_address_width_int_hwtcl \
                core4_0_pf4_sriov_vf_bar2_type_int_hwtcl \
                core4_0_pf4_sriov_vf_bar2_address_width_int_hwtcl \
                core4_0_pf4_sriov_vf_bar3_type_int_hwtcl \
                core4_0_pf4_sriov_vf_bar3_address_width_int_hwtcl \
                core4_0_pf4_sriov_vf_bar4_type_int_hwtcl \
                core4_0_pf4_sriov_vf_bar4_address_width_int_hwtcl \
                core4_0_pf4_sriov_vf_bar5_type_int_hwtcl \
                core4_0_pf4_sriov_vf_bar5_address_width_int_hwtcl \
                core4_0_pf5_sriov_vf_bar0_type_int_hwtcl \
                core4_0_pf5_sriov_vf_bar0_address_width_int_hwtcl \
                core4_0_pf5_sriov_vf_bar1_type_int_hwtcl \
                core4_0_pf5_sriov_vf_bar1_address_width_int_hwtcl \
                core4_0_pf5_sriov_vf_bar2_type_int_hwtcl \
                core4_0_pf5_sriov_vf_bar2_address_width_int_hwtcl \
                core4_0_pf5_sriov_vf_bar3_type_int_hwtcl \
                core4_0_pf5_sriov_vf_bar3_address_width_int_hwtcl \
                core4_0_pf5_sriov_vf_bar4_type_int_hwtcl \
                core4_0_pf5_sriov_vf_bar4_address_width_int_hwtcl \
                core4_0_pf5_sriov_vf_bar5_type_int_hwtcl \
                core4_0_pf5_sriov_vf_bar5_address_width_int_hwtcl \
                core4_0_pf6_sriov_vf_bar0_type_int_hwtcl \
                core4_0_pf6_sriov_vf_bar0_address_width_int_hwtcl \
                core4_0_pf6_sriov_vf_bar1_type_int_hwtcl \
                core4_0_pf6_sriov_vf_bar1_address_width_int_hwtcl \
                core4_0_pf6_sriov_vf_bar2_type_int_hwtcl \
                core4_0_pf6_sriov_vf_bar2_address_width_int_hwtcl \
                core4_0_pf6_sriov_vf_bar3_type_int_hwtcl \
                core4_0_pf6_sriov_vf_bar3_address_width_int_hwtcl \
                core4_0_pf6_sriov_vf_bar4_type_int_hwtcl \
                core4_0_pf6_sriov_vf_bar4_address_width_int_hwtcl \
                core4_0_pf6_sriov_vf_bar5_type_int_hwtcl \
                core4_0_pf6_sriov_vf_bar5_address_width_int_hwtcl \
                core4_0_pf7_sriov_vf_bar0_type_int_hwtcl \
                core4_0_pf7_sriov_vf_bar0_address_width_int_hwtcl \
                core4_0_pf7_sriov_vf_bar1_type_int_hwtcl \
                core4_0_pf7_sriov_vf_bar1_address_width_int_hwtcl \
                core4_0_pf7_sriov_vf_bar2_type_int_hwtcl \
                core4_0_pf7_sriov_vf_bar2_address_width_int_hwtcl \
                core4_0_pf7_sriov_vf_bar3_type_int_hwtcl \
                core4_0_pf7_sriov_vf_bar3_address_width_int_hwtcl \
                core4_0_pf7_sriov_vf_bar4_type_int_hwtcl \
                core4_0_pf7_sriov_vf_bar4_address_width_int_hwtcl \
                core4_0_pf7_sriov_vf_bar5_type_int_hwtcl \
                core4_0_pf7_sriov_vf_bar5_address_width_int_hwtcl \
                core4_0_pf0_expansion_base_address_register_integer_hwtcl \
                core4_0_pf1_expansion_base_address_register_integer_hwtcl \
                core4_0_pf2_expansion_base_address_register_integer_hwtcl \
                core4_0_pf3_expansion_base_address_register_integer_hwtcl \
                core4_0_pf4_expansion_base_address_register_integer_hwtcl \
                core4_0_pf5_expansion_base_address_register_integer_hwtcl \
                core4_0_pf6_expansion_base_address_register_integer_hwtcl \
                core4_0_pf7_expansion_base_address_register_integer_hwtcl \
                core4_0_cap_ext_tag_supp_user_hwtcl \
                core4_0_pf0_pcie_cap_ext_tag_supp_hwtcl \
                core4_0_pf1_pcie_cap_ext_tag_supp_hwtcl \
                core4_0_pf2_pcie_cap_ext_tag_supp_hwtcl \
                core4_0_pf3_pcie_cap_ext_tag_supp_hwtcl \
                core4_0_pf4_pcie_cap_ext_tag_supp_hwtcl \
                core4_0_pf5_pcie_cap_ext_tag_supp_hwtcl \
                core4_0_pf6_pcie_cap_ext_tag_supp_hwtcl \
                core4_0_pf7_pcie_cap_ext_tag_supp_hwtcl \
                core4_0_pf0_pcie_cap_ep_l0s_accpt_latency_hwtcl \
                core4_0_pf1_pcie_cap_ep_l0s_accpt_latency_hwtcl \
                core4_0_pf2_pcie_cap_ep_l0s_accpt_latency_hwtcl \
                core4_0_pf3_pcie_cap_ep_l0s_accpt_latency_hwtcl \
                core4_0_pf4_pcie_cap_ep_l0s_accpt_latency_hwtcl \
                core4_0_pf5_pcie_cap_ep_l0s_accpt_latency_hwtcl \
                core4_0_pf6_pcie_cap_ep_l0s_accpt_latency_hwtcl \
                core4_0_pf7_pcie_cap_ep_l0s_accpt_latency_hwtcl \
                core4_0_pf0_pcie_cap_ep_l1_accpt_latency_hwtcl \
                core4_0_pf1_pcie_cap_ep_l1_accpt_latency_hwtcl \
                core4_0_pf2_pcie_cap_ep_l1_accpt_latency_hwtcl \
                core4_0_pf3_pcie_cap_ep_l1_accpt_latency_hwtcl \
                core4_0_pf4_pcie_cap_ep_l1_accpt_latency_hwtcl \
                core4_0_pf5_pcie_cap_ep_l1_accpt_latency_hwtcl \
                core4_0_pf6_pcie_cap_ep_l1_accpt_latency_hwtcl \
                core4_0_pf7_pcie_cap_ep_l1_accpt_latency_hwtcl \
                core4_0_pcie_cvp_attr_hwtcl \
                core4_0_cfg_ptm_local_clock_adj_lsb_hwtcl \
                core4_0_cfg_ptm_local_clock_adj_msb_hwtcl \
                core4_0_pf1_pci_type0_vendor_id_hwtcl \
                core4_0_pf1_revision_id_hwtcl \
                core4_0_pf2_pci_type0_vendor_id_hwtcl \
                core4_0_pf2_revision_id_hwtcl \
                core4_0_pf3_pci_type0_vendor_id_hwtcl \
                core4_0_pf3_revision_id_hwtcl \
                core4_0_pf4_pci_type0_vendor_id_hwtcl \
                core4_0_pf4_revision_id_hwtcl \
                core4_0_pf5_pci_type0_vendor_id_hwtcl \
                core4_0_pf5_revision_id_hwtcl \
                core4_0_pf6_pci_type0_vendor_id_hwtcl \
                core4_0_pf6_revision_id_hwtcl \
                core4_0_pf7_pci_type0_vendor_id_hwtcl \
                core4_0_pf7_revision_id_hwtcl \
                core4_0_vendor_id_hwtcl \
                core4_0_revision_id_hwtcl \
                core4_0_vsec_next_offset_hwtcl \
                core4_0_pf0_tph_req_cap_st_table_loc_0_vfcomm_cs2_hwtcl  \
                core4_0_pf1_tph_req_cap_st_table_loc_0_vfcomm_cs2_hwtcl \
                core4_0_pf2_tph_req_cap_st_table_loc_0_vfcomm_cs2_hwtcl  \
                core4_0_pf3_tph_req_cap_st_table_loc_0_vfcomm_cs2_hwtcl \
                core4_0_pf4_tph_req_cap_st_table_loc_0_vfcomm_cs2_hwtcl  \
                core4_0_pf5_tph_req_cap_st_table_loc_0_vfcomm_cs2_hwtcl \
                core4_0_pf6_tph_req_cap_st_table_loc_0_vfcomm_cs2_hwtcl  \
                core4_0_pf7_tph_req_cap_st_table_loc_0_vfcomm_cs2_hwtcl \
                core4_0_virtio_start_byte_address_hwtcl \
                core4_0_avmm_enabled_virtio_hwtcl  \
                core4_0_ecc_ctrl_k_nparity_ecc_attr_hwtcl \
                core4_0_refclk_init_active_hwtcl \
                core4_0_enable_independent_pin_perst_hwtcl \
                core4_0_txempty_enable_hwtcl \
                core4_0_virtual_num_of_lanes_16_hwtcl \
                core4_0_pf0_pci_type0_bar5_mask_31_1_hwtcl \
                core4_0_pf0_pci_type0_bar4_mask_31_1_hwtcl \
                core4_0_pf0_pci_type0_bar3_mask_31_1_hwtcl \
                core4_0_pf0_pci_type0_bar2_mask_31_1_hwtcl \
                core4_0_pf0_pci_type0_bar1_mask_31_1_hwtcl \
                core4_0_pf0_pci_type0_bar0_mask_31_1_hwtcl \
                core4_0_pf1_virtio_capability_present_hwtcl \
                core4_0_pf2_virtio_capability_present_hwtcl \
                core4_0_pf3_virtio_capability_present_hwtcl \
                core4_0_pf4_virtio_capability_present_hwtcl \
                core4_0_pf5_virtio_capability_present_hwtcl \
                core4_0_pf6_virtio_capability_present_hwtcl \
                core4_0_pf7_virtio_capability_present_hwtcl \
                core4_0_pf0vf_virtio_capability_present_hwtcl \
                core4_0_pf1vf_virtio_capability_present_hwtcl \
                core4_0_pf2vf_virtio_capability_present_hwtcl \
                core4_0_pf3vf_virtio_capability_present_hwtcl \
                core4_0_pf4vf_virtio_capability_present_hwtcl \
                core4_0_pf5vf_virtio_capability_present_hwtcl \
                core4_0_pf6vf_virtio_capability_present_hwtcl \
                core4_0_pf7vf_virtio_capability_present_hwtcl \
                core4_0_pf1_aspm_control_hwtcl \
                core4_0_pf2_aspm_control_hwtcl \
                core4_0_pf3_aspm_control_hwtcl \
                core4_0_pf4_aspm_control_hwtcl \
                core4_0_pf5_aspm_control_hwtcl \
                core4_0_pf6_aspm_control_hwtcl \
                core4_0_pf7_aspm_control_hwtcl \
                core4_0_flr_cap_user_hwtcl \
                core4_0_flr_cap_hwtcl \
                core4_0_pf0_pcie_cap_flr_cap_hwtcl \
                core4_0_user_pcie_cap_slot_clk_config_hwtcl \
                core4_0_virtual_pf0_pl16g_cap_enable_hwtcl \
                core4_0_virtual_pf0_margin_cap_enable_hwtcl \
                core4_0_pf0_tph_req_cap_st_table_loc_1_derived_hwtcl \
                core4_0_pf1_pcie_cap_port_num_hwtcl \
                core4_0_pf2_pcie_cap_port_num_hwtcl \
                core4_0_pf3_pcie_cap_port_num_hwtcl \
                core4_0_pf4_pcie_cap_port_num_hwtcl \
                core4_0_pf5_pcie_cap_port_num_hwtcl \
                core4_0_pf6_pcie_cap_port_num_hwtcl \
                core4_0_pf7_pcie_cap_port_num_hwtcl \
                core4_0_pf1_device_control_device_status_pcie_cap_ext_tag_en_hwtcl \
                core4_0_pf2_device_control_device_status_pcie_cap_ext_tag_en_hwtcl \
                core4_0_pf3_device_control_device_status_pcie_cap_ext_tag_en_hwtcl \
                core4_0_pf4_device_control_device_status_pcie_cap_ext_tag_en_hwtcl \
                core4_0_pf5_device_control_device_status_pcie_cap_ext_tag_en_hwtcl \
                core4_0_pf6_device_control_device_status_pcie_cap_ext_tag_en_hwtcl \
                core4_0_pf7_device_control_device_status_pcie_cap_ext_tag_en_hwtcl \
                core4_0_pf1_device_control3_reg_dev3_cap_dmwr_egress_blk_hwtcl \
                core4_0_pf2_device_control3_reg_dev3_cap_dmwr_egress_blk_hwtcl \
                core4_0_pf3_device_control3_reg_dev3_cap_dmwr_egress_blk_hwtcl \
                core4_0_pf4_device_control3_reg_dev3_cap_dmwr_egress_blk_hwtcl \
                core4_0_pf5_device_control3_reg_dev3_cap_dmwr_egress_blk_hwtcl \
                core4_0_pf6_device_control3_reg_dev3_cap_dmwr_egress_blk_hwtcl \
                core4_0_pf7_device_control3_reg_dev3_cap_dmwr_egress_blk_hwtcl \
                core4_0_sriov_misc_ctrl_k_nonsriov_mode_hwtcl \
                core4_0_pf1_no_soft_rst_hwtcl \
                core4_0_pf2_no_soft_rst_hwtcl \
                core4_0_pf3_no_soft_rst_hwtcl \
                core4_0_pf4_no_soft_rst_hwtcl \
                core4_0_pf5_no_soft_rst_hwtcl \
                core4_0_pf6_no_soft_rst_hwtcl \
                core4_0_pf7_no_soft_rst_hwtcl \
                core4_0_virtual_ptm_hwtcl \
                core4_0_cfg_ptm_auto_update_period_hwtcl \
                core4_0_virtual_ptm_autoupdate_hwtcl \
                core4_0_virtual_ptm_adj_lsb_hwtcl \
                core4_0_virtual_ptm_adj_msb_hwtcl \
                core4_0_pf1_pci_type0_vendor_id_user_hwtcl \
                core4_0_pf2_pci_type0_vendor_id_user_hwtcl \
                core4_0_pf3_pci_type0_vendor_id_user_hwtcl \
                core4_0_pf4_pci_type0_vendor_id_user_hwtcl \
                core4_0_pf5_pci_type0_vendor_id_user_hwtcl \
                core4_0_pf6_pci_type0_vendor_id_user_hwtcl \
                core4_0_pf7_pci_type0_vendor_id_user_hwtcl \
                core4_0_pf1_revision_id_user_hwtcl \
                core4_0_pf2_revision_id_user_hwtcl \
                core4_0_pf3_revision_id_user_hwtcl \
                core4_0_pf4_revision_id_user_hwtcl \
                core4_0_pf5_revision_id_user_hwtcl \
                core4_0_pf6_revision_id_user_hwtcl \
                core4_0_pf7_revision_id_user_hwtcl \
                core4_0_virtual_pf1_user_vsec_cap_enable_hwtcl \
                core4_0_virtual_pf2_user_vsec_cap_enable_hwtcl \
                core4_0_virtual_pf3_user_vsec_cap_enable_hwtcl \
                core4_0_virtual_pf4_user_vsec_cap_enable_hwtcl \
                core4_0_virtual_pf5_user_vsec_cap_enable_hwtcl \
                core4_0_virtual_pf6_user_vsec_cap_enable_hwtcl \
                core4_0_virtual_pf7_user_vsec_cap_enable_hwtcl \
                core4_0_pf1_eval_interval_time_hwtcl \
                core4_0_pf2_eval_interval_time_hwtcl \
                core4_0_pf3_eval_interval_time_hwtcl \
                core4_0_pf4_eval_interval_time_hwtcl \
                core4_0_pf5_eval_interval_time_hwtcl \
                core4_0_pf6_eval_interval_time_hwtcl \
                core4_0_pf7_eval_interval_time_hwtcl \
                core4_0_virtual_num_of_lanes_8_hwtcl \
                core4_0_pf0_gen3_eq_pset_req_vec_c0_user_hwtcl \
                core4_0_pf0_gen3_eq_pset_req_vec_atg4_c0_user_hwtcl \
                core4_0_pf1_acs_cap_acs_p2p_egress_control_hwtcl \
                core4_0_pf2_acs_cap_acs_p2p_egress_control_hwtcl \
                core4_0_pf3_acs_cap_acs_p2p_egress_control_hwtcl \
                core4_0_pf4_acs_cap_acs_p2p_egress_control_hwtcl \
                core4_0_pf5_acs_cap_acs_p2p_egress_control_hwtcl \
                core4_0_pf6_acs_cap_acs_p2p_egress_control_hwtcl \
                core4_0_pf7_acs_cap_acs_p2p_egress_control_hwtcl \
                core4_1_pf1_acs_cap_acs_p2p_egress_control_hwtcl \
                core4_1_pf2_acs_cap_acs_p2p_egress_control_hwtcl \
                core4_1_pf3_acs_cap_acs_p2p_egress_control_hwtcl \
                core4_1_pf4_acs_cap_acs_p2p_egress_control_hwtcl \
                core4_1_pf5_acs_cap_acs_p2p_egress_control_hwtcl \
                core4_1_pf6_acs_cap_acs_p2p_egress_control_hwtcl \
                core4_1_pf7_acs_cap_acs_p2p_egress_control_hwtcl \
                core4_0_virtual_pf1_acs_cap_enable_hwtcl \
                core4_0_virtual_pf2_acs_cap_enable_hwtcl \
                core4_0_virtual_pf3_acs_cap_enable_hwtcl \
                core4_0_virtual_pf4_acs_cap_enable_hwtcl \
                core4_0_virtual_pf5_acs_cap_enable_hwtcl \
                core4_0_virtual_pf6_acs_cap_enable_hwtcl \
                core4_0_virtual_pf7_acs_cap_enable_hwtcl \
                core4_1_virtual_pf1_acs_cap_enable_hwtcl \
                core4_1_virtual_pf2_acs_cap_enable_hwtcl \
                core4_1_virtual_pf3_acs_cap_enable_hwtcl \
                core4_1_virtual_pf4_acs_cap_enable_hwtcl \
                core4_1_virtual_pf5_acs_cap_enable_hwtcl \
                core4_1_virtual_pf6_acs_cap_enable_hwtcl \
                core4_1_virtual_pf7_acs_cap_enable_hwtcl \
                core4_0_virtual_pf1_enable_hwtcl \
                core4_0_virtual_pf2_enable_hwtcl \
                core4_0_virtual_pf3_enable_hwtcl \
                core4_0_virtual_pf4_enable_hwtcl \
                core4_0_virtual_pf5_enable_hwtcl \
                core4_0_virtual_pf6_enable_hwtcl \
                core4_0_virtual_pf7_enable_hwtcl \
                core4_0_pf1_bar0_type_user_hwtcl \
                core4_0_pf2_bar0_type_user_hwtcl \
                core4_0_pf3_bar0_type_user_hwtcl \
                core4_0_pf1_bar0_address_width_user_hwtcl \
                core4_0_pf2_bar0_address_width_user_hwtcl \
                core4_0_pf3_bar0_address_width_user_hwtcl \
                core4_0_pf0_sriov_vf_bar0_type_user_hwtcl \
                core4_0_pf1_sriov_vf_bar0_type_user_hwtcl \
                core4_0_pf2_sriov_vf_bar0_type_user_hwtcl \
                core4_0_pf3_sriov_vf_bar0_type_user_hwtcl \
                core4_0_pf0_sriov_vf_bar0_type_hwtcl \
                core4_0_pf1_sriov_vf_bar0_type_hwtcl \
                core4_0_pf2_sriov_vf_bar0_type_hwtcl \
                core4_0_pf3_sriov_vf_bar0_type_hwtcl \
                core4_0_pf0_sriov_vf_bar0_address_width_hwtcl \
                core4_0_pf1_sriov_vf_bar0_address_width_hwtcl \
                core4_0_pf2_sriov_vf_bar0_address_width_hwtcl \
                core4_0_pf3_sriov_vf_bar0_address_width_hwtcl \
                core4_0_virtual_pf1_tph_cap_enable_hwtcl \
                core4_0_virtual_pf2_tph_cap_enable_hwtcl \
                core4_0_virtual_pf3_tph_cap_enable_hwtcl \
                core4_0_pf1_vf_tph_cap_enable_hwtcl \
                core4_0_pf2_vf_tph_cap_enable_hwtcl \
                core4_0_pf3_vf_tph_cap_enable_hwtcl \
                core4_0_pf1_virtio_device_specific_cap_present_hwtcl \
                core4_0_pf2_virtio_device_specific_cap_present_hwtcl \
                core4_0_pf3_virtio_device_specific_cap_present_hwtcl \
                core4_0_pf0vf_virtio_device_specific_cap_present_hwtcl \
                core4_0_pf1vf_virtio_device_specific_cap_present_hwtcl \
                core4_0_pf2vf_virtio_device_specific_cap_present_hwtcl \
                core4_0_pf3vf_virtio_device_specific_cap_present_hwtcl \
                core4_0_exvf_msixpba_bir_pf0  \
                core4_0_exvf_msixpba_bir_pf1  \
                core4_0_exvf_msixpba_bir_pf2  \
                core4_0_exvf_msixpba_bir_pf3  \
                core4_1_virtual_pf1_enable_hwtcl \
                core4_1_virtual_pf2_enable_hwtcl \
                core4_1_virtual_pf3_enable_hwtcl \
                core4_1_virtual_pf4_enable_hwtcl \
                core4_1_virtual_pf5_enable_hwtcl \
                core4_1_virtual_pf6_enable_hwtcl \
                core4_1_virtual_pf7_enable_hwtcl \
                core4_1_pf1_bar0_type_user_hwtcl \
                core4_1_pf2_bar0_type_user_hwtcl \
                core4_1_pf3_bar0_type_user_hwtcl \
                core4_1_pf1_bar0_address_width_user_hwtcl \
                core4_1_pf2_bar0_address_width_user_hwtcl \
                core4_1_pf3_bar0_address_width_user_hwtcl \
                core4_1_pf0_sriov_vf_bar0_type_user_hwtcl \
                core4_1_pf1_sriov_vf_bar0_type_user_hwtcl \
                core4_1_pf2_sriov_vf_bar0_type_user_hwtcl \
                core4_1_pf3_sriov_vf_bar0_type_user_hwtcl \
                core4_1_pf0_sriov_vf_bar0_type_hwtcl \
                core4_1_pf1_sriov_vf_bar0_type_hwtcl \
                core4_1_pf2_sriov_vf_bar0_type_hwtcl \
                core4_1_pf3_sriov_vf_bar0_type_hwtcl \
                core4_1_pf0_sriov_vf_bar0_address_width_hwtcl \
                core4_1_pf1_sriov_vf_bar0_address_width_hwtcl \
                core4_1_pf2_sriov_vf_bar0_address_width_hwtcl \
                core4_1_pf3_sriov_vf_bar0_address_width_hwtcl \
                core4_1_virtual_pf1_tph_cap_enable_hwtcl \
                core4_1_virtual_pf2_tph_cap_enable_hwtcl \
                core4_1_virtual_pf3_tph_cap_enable_hwtcl \
                core4_1_pf1_vf_tph_cap_enable_hwtcl \
                core4_1_pf2_vf_tph_cap_enable_hwtcl \
                core4_1_pf3_vf_tph_cap_enable_hwtcl \
                core4_1_pf1_virtio_device_specific_cap_present_hwtcl \
                core4_1_pf2_virtio_device_specific_cap_present_hwtcl \
                core4_1_pf3_virtio_device_specific_cap_present_hwtcl \
                core4_1_pf0vf_virtio_device_specific_cap_present_hwtcl \
                core4_1_pf1vf_virtio_device_specific_cap_present_hwtcl \
                core4_1_pf2vf_virtio_device_specific_cap_present_hwtcl \
                core4_1_pf3vf_virtio_device_specific_cap_present_hwtcl \
                core4_1_exvf_msixpba_bir_pf0  \
                core4_1_exvf_msixpba_bir_pf1  \
                core4_1_exvf_msixpba_bir_pf2  \
                core4_1_exvf_msixpba_bir_pf3  \
                core4_0_enable_sriov_hwtcl \
                core4_0_virtual_pf0_sriov_enable_hwtcl \
                core4_0_virtual_pf1_sriov_enable_hwtcl \
                core4_0_virtual_pf2_sriov_enable_hwtcl \
                core4_0_virtual_pf3_sriov_enable_hwtcl \
                core4_0_virtual_pf4_sriov_enable_hwtcl \
                core4_0_virtual_pf5_sriov_enable_hwtcl \
                core4_0_virtual_pf6_sriov_enable_hwtcl \
                core4_0_virtual_pf7_sriov_enable_hwtcl \
                core4_0_total_pf_count_hwtcl \
                core4_0_enable_multi_func_hwtcl \
                core4_0_pf1_int_pin_hwtcl \
                core4_0_pf2_int_pin_hwtcl \
                core4_0_pf3_int_pin_hwtcl \
                core4_0_pf4_int_pin_hwtcl \
                core4_0_pf5_int_pin_hwtcl \
                core4_0_pf6_int_pin_hwtcl \
                core4_0_pf7_int_pin_hwtcl \
                core4_0_virtual_pf1_msi_enable_hwtcl \
                core4_0_virtual_pf2_msi_enable_hwtcl \
                core4_0_virtual_pf3_msi_enable_hwtcl \
                core4_0_virtual_pf4_msi_enable_hwtcl \
                core4_0_virtual_pf5_msi_enable_hwtcl \
                core4_0_virtual_pf6_msi_enable_hwtcl \
                core4_0_virtual_pf7_msi_enable_hwtcl \
                core4_0_virtual_pf1_msix_enable_hwtcl \
                core4_0_virtual_pf2_msix_enable_hwtcl \
                core4_0_virtual_pf3_msix_enable_hwtcl \
                core4_0_virtual_pf4_msix_enable_hwtcl \
                core4_0_virtual_pf5_msix_enable_hwtcl \
                core4_0_virtual_pf6_msix_enable_hwtcl \
                core4_0_virtual_pf7_msix_enable_hwtcl \
                core4_0_pf1_pci_msix_table_size_hwtcl \
                core4_0_pf1_pci_msix_table_offset_hwtcl \
                core4_0_pf1_pci_msix_bir_hwtcl \
                core4_0_pf1_pci_msix_pba_offset_hwtcl \
                core4_0_pf1_pci_msix_pba_hwtcl \
                core4_0_pf1_pci_msix_table_size_vfcomm_cs2_hwtcl \
                core4_0_pf2_pci_msix_table_size_hwtcl \
                core4_0_pf2_pci_msix_table_offset_hwtcl \
                core4_0_pf2_pci_msix_bir_hwtcl \
                core4_0_pf2_pci_msix_pba_offset_hwtcl \
                core4_0_pf2_pci_msix_pba_hwtcl \
                core4_0_pf2_pci_msix_table_size_vfcomm_cs2_hwtcl \
                core4_0_pf3_pci_msix_table_size_hwtcl \
                core4_0_pf3_pci_msix_table_offset_hwtcl \
                core4_0_pf3_pci_msix_bir_hwtcl \
                core4_0_pf3_pci_msix_pba_offset_hwtcl \
                core4_0_pf3_pci_msix_pba_hwtcl \
                core4_0_pf3_pci_msix_table_size_vfcomm_cs2_hwtcl \
                core4_0_pf4_pci_msix_table_size_hwtcl \
                core4_0_pf4_pci_msix_table_offset_hwtcl \
                core4_0_pf4_pci_msix_bir_hwtcl \
                core4_0_pf4_pci_msix_pba_offset_hwtcl \
                core4_0_pf4_pci_msix_pba_hwtcl \
                core4_0_pf4_pci_msix_table_size_vfcomm_cs2_hwtcl \
                core4_0_pf5_pci_msix_table_size_hwtcl \
                core4_0_pf5_pci_msix_table_offset_hwtcl \
                core4_0_pf5_pci_msix_bir_hwtcl \
                core4_0_pf5_pci_msix_pba_offset_hwtcl \
                core4_0_pf5_pci_msix_pba_hwtcl \
                core4_0_pf5_pci_msix_table_size_vfcomm_cs2_hwtcl \
                core4_0_pf6_pci_msix_table_size_hwtcl \
                core4_0_pf6_pci_msix_table_offset_hwtcl \
                core4_0_pf6_pci_msix_bir_hwtcl \
                core4_0_pf6_pci_msix_pba_offset_hwtcl \
                core4_0_pf6_pci_msix_pba_hwtcl \
                core4_0_pf6_pci_msix_table_size_vfcomm_cs2_hwtcl \
                core4_0_pf7_pci_msix_table_size_hwtcl \
                core4_0_pf7_pci_msix_table_offset_hwtcl \
                core4_0_pf7_pci_msix_bir_hwtcl \
                core4_0_pf7_pci_msix_pba_offset_hwtcl \
                core4_0_pf7_pci_msix_pba_hwtcl \
                core4_0_pf7_pci_msix_table_size_vfcomm_cs2_hwtcl \
                core4_0_virtual_pf0_exvf_msix_cap_enable_hwtcl \
                core4_0_exvf_msix_tablesize_pf0 \
                core4_0_exvf_msixtable_offset_pf0 \
                core4_0_exvf_msixtable_bir_pf0 \
                core4_0_exvf_msixpba_offset_pf0 \
                core4_0_virtual_pf1_exvf_msix_cap_enable_hwtcl \
                core4_0_exvf_msix_tablesize_pf1 \
                core4_0_exvf_msixtable_offset_pf1 \
                core4_0_exvf_msixtable_bir_pf1 \
                core4_0_exvf_msixpba_offset_pf1 \
                core4_0_virtual_pf2_exvf_msix_cap_enable_hwtcl \
                core4_0_exvf_msix_tablesize_pf2 \
                core4_0_exvf_msixtable_offset_pf2 \
                core4_0_exvf_msixtable_bir_pf2 \
                core4_0_exvf_msixpba_offset_pf2 \
                core4_0_virtual_pf3_exvf_msix_cap_enable_hwtcl \
                core4_0_exvf_msix_tablesize_pf3 \
                core4_0_exvf_msixtable_offset_pf3 \
                core4_0_exvf_msixtable_bir_pf3 \
                core4_0_exvf_msixpba_offset_pf3 \
                core4_0_virtual_pf4_exvf_msix_cap_enable_hwtcl \
                core4_0_exvf_msix_tablesize_pf4 \
                core4_0_exvf_msixtable_offset_pf4 \
                core4_0_exvf_msixtable_bir_pf4 \
                core4_0_exvf_msixpba_offset_pf4 \
                core4_0_virtual_pf5_exvf_msix_cap_enable_hwtcl \
                core4_0_exvf_msix_tablesize_pf5 \
                core4_0_exvf_msixtable_offset_pf5 \
                core4_0_exvf_msixtable_bir_pf5 \
                core4_0_exvf_msixpba_offset_pf5 \
                core4_0_virtual_pf6_exvf_msix_cap_enable_hwtcl \
                core4_0_exvf_msix_tablesize_pf6 \
                core4_0_exvf_msixtable_offset_pf6 \
                core4_0_exvf_msixtable_bir_pf6 \
                core4_0_exvf_msixpba_offset_pf6 \
                core4_0_virtual_pf7_exvf_msix_cap_enable_hwtcl \
                core4_0_exvf_msix_tablesize_pf7 \
                core4_0_exvf_msixtable_offset_pf7 \
                core4_0_exvf_msixtable_bir_pf7 \
                core4_0_exvf_msixpba_offset_pf7 \
                core4_0_virtual_pf1_msi_enable_user_hwtcl \
                core4_0_virtual_pf2_msi_enable_user_hwtcl \
                core4_0_virtual_pf3_msi_enable_user_hwtcl \
                core4_0_virtual_pf4_msi_enable_user_hwtcl \
                core4_0_virtual_pf5_msi_enable_user_hwtcl \
                core4_0_virtual_pf6_msi_enable_user_hwtcl \
                core4_0_virtual_pf7_msi_enable_user_hwtcl \
                core4_0_virtual_pf1_msi_64b_addressing_user_hwtcl \
                core4_0_virtual_pf2_msi_64b_addressing_user_hwtcl \
                core4_0_virtual_pf3_msi_64b_addressing_user_hwtcl \
                core4_0_virtual_pf4_msi_64b_addressing_user_hwtcl \
                core4_0_virtual_pf5_msi_64b_addressing_user_hwtcl \
                core4_0_virtual_pf6_msi_64b_addressing_user_hwtcl \
                core4_0_virtual_pf7_msi_64b_addressing_user_hwtcl \
                core4_0_pf1_pci_msi_ext_data_cap_hwtcl \
                core4_0_pf2_pci_msi_ext_data_cap_hwtcl \
                core4_0_pf3_pci_msi_ext_data_cap_hwtcl \
                core4_0_pf4_pci_msi_ext_data_cap_hwtcl \
                core4_0_pf5_pci_msi_ext_data_cap_hwtcl \
                core4_0_pf6_pci_msi_ext_data_cap_hwtcl \
                core4_0_pf7_pci_msi_ext_data_cap_hwtcl \
                core4_0_pf1_pci_msi_multiple_msg_cap_hwtcl \
                core4_0_pf2_pci_msi_multiple_msg_cap_hwtcl \
                core4_0_pf3_pci_msi_multiple_msg_cap_hwtcl \
                core4_0_pf4_pci_msi_multiple_msg_cap_hwtcl \
                core4_0_pf5_pci_msi_multiple_msg_cap_hwtcl \
                core4_0_pf6_pci_msi_multiple_msg_cap_hwtcl \
                core4_0_pf7_pci_msi_multiple_msg_cap_hwtcl \
                core4_0_virtual_pf1_msix_enable_user_hwtcl \
                core4_0_virtual_pf2_msix_enable_user_hwtcl \
                core4_0_virtual_pf3_msix_enable_user_hwtcl \
                core4_0_virtual_pf4_msix_enable_user_hwtcl \
                core4_0_virtual_pf5_msix_enable_user_hwtcl \
                core4_0_virtual_pf6_msix_enable_user_hwtcl \
                core4_0_virtual_pf7_msix_enable_user_hwtcl \
                core4_0_pf0_vf_count_hwtcl \
                core4_0_pf1_vf_count_hwtcl \
                core4_0_pf2_vf_count_hwtcl \
                core4_0_pf3_vf_count_hwtcl \
                core4_0_pf4_vf_count_hwtcl \
                core4_0_pf5_vf_count_hwtcl \
                core4_0_pf6_vf_count_hwtcl \
                core4_0_pf7_vf_count_hwtcl \
                core4_0_virtual_pf1_pasid_cap_enable_hwtcl \
                core4_0_pf1_pasid_cap_execute_permission_supported \
                core4_0_pf1_pasid_cap_privileged_mode_supported \
                core4_0_pf1_pasid_cap_max_pasid_width \
                core4_0_virtual_pf2_pasid_cap_enable_hwtcl \
                core4_0_pf2_pasid_cap_execute_permission_supported \
                core4_0_pf2_pasid_cap_privileged_mode_supported \
                core4_0_pf2_pasid_cap_max_pasid_width \
                core4_0_virtual_pf3_pasid_cap_enable_hwtcl \
                core4_0_pf3_pasid_cap_execute_permission_supported \
                core4_0_pf3_pasid_cap_privileged_mode_supported \
                core4_0_pf3_pasid_cap_max_pasid_width \
                core4_0_virtual_pf4_pasid_cap_enable_hwtcl \
                core4_0_pf4_pasid_cap_execute_permission_supported \
                core4_0_pf4_pasid_cap_privileged_mode_supported \
                core4_0_pf4_pasid_cap_max_pasid_width \
                core4_0_virtual_pf5_pasid_cap_enable_hwtcl \
                core4_0_pf5_pasid_cap_execute_permission_supported \
                core4_0_pf5_pasid_cap_privileged_mode_supported \
                core4_0_pf5_pasid_cap_max_pasid_width \
                core4_0_virtual_pf6_pasid_cap_enable_hwtcl \
                core4_0_pf6_pasid_cap_execute_permission_supported \
                core4_0_pf6_pasid_cap_privileged_mode_supported \
                core4_0_pf6_pasid_cap_max_pasid_width \
                core4_0_virtual_pf7_pasid_cap_enable_hwtcl \
                core4_0_pf7_pasid_cap_execute_permission_supported \
                core4_0_pf7_pasid_cap_privileged_mode_supported \
                core4_0_pf7_pasid_cap_max_pasid_width \
                core4_0_virtual_pf1_prs_ext_cap_enable_hwtcl \
                core4_0_pf1_prs_outstanding_capacity_hwtcl \
                core4_0_virtual_pf2_prs_ext_cap_enable_hwtcl \
                core4_0_pf2_prs_outstanding_capacity_hwtcl \
                core4_0_virtual_pf3_prs_ext_cap_enable_hwtcl \
                core4_0_pf3_prs_outstanding_capacity_hwtcl \
                core4_0_virtual_pf4_prs_ext_cap_enable_hwtcl \
                core4_0_pf4_prs_outstanding_capacity_hwtcl \
                core4_0_virtual_pf5_prs_ext_cap_enable_hwtcl \
                core4_0_pf5_prs_outstanding_capacity_hwtcl \
                core4_0_virtual_pf6_prs_ext_cap_enable_hwtcl \
                core4_0_pf6_prs_outstanding_capacity_hwtcl \
                core4_0_virtual_pf7_prs_ext_cap_enable_hwtcl \
                core4_0_pf7_prs_outstanding_capacity_hwtcl \
                core4_1_virtual_pf1_prs_ext_cap_enable_hwtcl \
                core4_1_pf1_prs_outstanding_capacity_hwtcl \
                core4_1_virtual_pf2_prs_ext_cap_enable_hwtcl \
                core4_1_pf2_prs_outstanding_capacity_hwtcl \
                core4_1_virtual_pf3_prs_ext_cap_enable_hwtcl \
                core4_1_pf3_prs_outstanding_capacity_hwtcl \
                core4_1_virtual_pf4_prs_ext_cap_enable_hwtcl \
                core4_1_pf4_prs_outstanding_capacity_hwtcl \
                core4_1_virtual_pf5_prs_ext_cap_enable_hwtcl \
                core4_1_pf5_prs_outstanding_capacity_hwtcl \
                core4_1_virtual_pf6_prs_ext_cap_enable_hwtcl \
                core4_1_pf6_prs_outstanding_capacity_hwtcl \
                core4_1_virtual_pf7_prs_ext_cap_enable_hwtcl \
                core4_1_pf7_prs_outstanding_capacity_hwtcl \
                core4_1_virtual_pf1_pasid_cap_enable_hwtcl \
                core4_1_pf1_pasid_cap_execute_permission_supported \
                core4_1_pf1_pasid_cap_privileged_mode_supported \
                core4_1_pf1_pasid_cap_max_pasid_width \
                core4_1_virtual_pf2_pasid_cap_enable_hwtcl \
                core4_1_pf2_pasid_cap_execute_permission_supported \
                core4_1_pf2_pasid_cap_privileged_mode_supported \
                core4_1_pf2_pasid_cap_max_pasid_width \
                core4_1_virtual_pf3_pasid_cap_enable_hwtcl \
                core4_1_pf3_pasid_cap_execute_permission_supported \
                core4_1_pf3_pasid_cap_privileged_mode_supported \
                core4_1_pf3_pasid_cap_max_pasid_width \
                core4_1_virtual_pf4_pasid_cap_enable_hwtcl \
                core4_1_pf4_pasid_cap_execute_permission_supported \
                core4_1_pf4_pasid_cap_privileged_mode_supported \
                core4_1_pf4_pasid_cap_max_pasid_width \
                core4_1_virtual_pf5_pasid_cap_enable_hwtcl \
                core4_1_pf5_pasid_cap_execute_permission_supported \
                core4_1_pf5_pasid_cap_privileged_mode_supported \
                core4_1_pf5_pasid_cap_max_pasid_width \
                core4_1_virtual_pf6_pasid_cap_enable_hwtcl \
                core4_1_pf6_pasid_cap_execute_permission_supported \
                core4_1_pf6_pasid_cap_privileged_mode_supported \
                core4_1_pf6_pasid_cap_max_pasid_width \
                core4_1_virtual_pf7_pasid_cap_enable_hwtcl \
                core4_1_pf7_pasid_cap_execute_permission_supported \
                core4_1_pf7_pasid_cap_privileged_mode_supported \
                core4_1_pf7_pasid_cap_max_pasid_width \
                core4_1_pf0_vf_count_hwtcl \
                core4_1_pf1_vf_count_hwtcl \
                core4_1_pf2_vf_count_hwtcl \
                core4_1_pf3_vf_count_hwtcl \
                core4_1_pf4_vf_count_hwtcl \
                core4_1_pf5_vf_count_hwtcl \
                core4_1_pf6_vf_count_hwtcl \
                core4_1_pf7_vf_count_hwtcl \
                core4_1_enable_sriov_hwtcl \
                core4_1_virtual_pf0_sriov_enable_hwtcl \
                core4_1_virtual_pf1_sriov_enable_hwtcl \
                core4_1_virtual_pf2_sriov_enable_hwtcl \
                core4_1_virtual_pf3_sriov_enable_hwtcl \
                core4_1_virtual_pf4_sriov_enable_hwtcl \
                core4_1_virtual_pf5_sriov_enable_hwtcl \
                core4_1_virtual_pf6_sriov_enable_hwtcl \
                core4_1_virtual_pf7_sriov_enable_hwtcl \
                core4_1_total_pf_count_hwtcl \
                core4_1_enable_multi_func_hwtcl \
                core4_1_pf1_int_pin_hwtcl \
                core4_1_pf2_int_pin_hwtcl \
                core4_1_pf3_int_pin_hwtcl \
                core4_1_pf4_int_pin_hwtcl \
                core4_1_pf5_int_pin_hwtcl \
                core4_1_pf6_int_pin_hwtcl \
                core4_1_pf7_int_pin_hwtcl \
                core4_1_virtual_pf1_msi_enable_hwtcl \
                core4_1_virtual_pf2_msi_enable_hwtcl \
                core4_1_virtual_pf3_msi_enable_hwtcl \
                core4_1_virtual_pf4_msi_enable_hwtcl \
                core4_1_virtual_pf5_msi_enable_hwtcl \
                core4_1_virtual_pf6_msi_enable_hwtcl \
                core4_1_virtual_pf7_msi_enable_hwtcl \
                core4_1_virtual_pf1_msix_enable_hwtcl \
                core4_1_virtual_pf2_msix_enable_hwtcl \
                core4_1_virtual_pf3_msix_enable_hwtcl \
                core4_1_virtual_pf4_msix_enable_hwtcl \
                core4_1_virtual_pf5_msix_enable_hwtcl \
                core4_1_virtual_pf6_msix_enable_hwtcl \
                core4_1_virtual_pf7_msix_enable_hwtcl \
                core4_1_pf1_pci_msix_table_size_hwtcl \
                core4_1_virtual_pf1_msix_enable_user_hwtcl \
                core4_1_virtual_pf2_msix_enable_user_hwtcl \
                core4_1_virtual_pf3_msix_enable_user_hwtcl \
                core4_1_virtual_pf4_msix_enable_user_hwtcl \
                core4_1_virtual_pf5_msix_enable_user_hwtcl \
                core4_1_virtual_pf6_msix_enable_user_hwtcl \
                core4_1_virtual_pf7_msix_enable_user_hwtcl \
                core4_1_pf1_pci_msix_table_offset_hwtcl \
                core4_1_pf1_pci_msix_bir_hwtcl \
                core4_1_pf1_pci_msix_pba_offset_hwtcl \
                core4_1_pf1_pci_msix_pba_hwtcl \
                core4_1_pf1_pci_msix_table_size_vfcomm_cs2_hwtcl \
                core4_1_pf2_pci_msix_table_size_hwtcl \
                core4_1_pf2_pci_msix_table_offset_hwtcl \
                core4_1_pf2_pci_msix_bir_hwtcl \
                core4_1_pf2_pci_msix_pba_offset_hwtcl \
                core4_1_pf2_pci_msix_pba_hwtcl \
                core4_1_pf2_pci_msix_table_size_vfcomm_cs2_hwtcl \
                core4_1_pf3_pci_msix_table_size_hwtcl \
                core4_1_pf3_pci_msix_table_offset_hwtcl \
                core4_1_pf3_pci_msix_bir_hwtcl \
                core4_1_pf3_pci_msix_pba_offset_hwtcl \
                core4_1_pf3_pci_msix_pba_hwtcl \
                core4_1_pf3_pci_msix_table_size_vfcomm_cs2_hwtcl \
                core4_1_pf4_pci_msix_table_size_hwtcl \
                core4_1_pf4_pci_msix_table_offset_hwtcl \
                core4_1_pf4_pci_msix_bir_hwtcl \
                core4_1_pf4_pci_msix_pba_offset_hwtcl \
                core4_1_pf4_pci_msix_pba_hwtcl \
                core4_1_pf4_pci_msix_table_size_vfcomm_cs2_hwtcl \
                core4_1_pf5_pci_msix_table_size_hwtcl \
                core4_1_pf5_pci_msix_table_offset_hwtcl \
                core4_1_pf5_pci_msix_bir_hwtcl \
                core4_1_pf5_pci_msix_pba_offset_hwtcl \
                core4_1_pf5_pci_msix_pba_hwtcl \
                core4_1_pf5_pci_msix_table_size_vfcomm_cs2_hwtcl \
                core4_1_pf6_pci_msix_table_size_hwtcl \
                core4_1_pf6_pci_msix_table_offset_hwtcl \
                core4_1_pf6_pci_msix_bir_hwtcl \
                core4_1_pf6_pci_msix_pba_offset_hwtcl \
                core4_1_pf6_pci_msix_pba_hwtcl \
                core4_1_pf6_pci_msix_table_size_vfcomm_cs2_hwtcl \
                core4_1_pf7_pci_msix_table_size_hwtcl \
                core4_1_pf7_pci_msix_table_offset_hwtcl \
                core4_1_pf7_pci_msix_bir_hwtcl \
                core4_1_pf7_pci_msix_pba_offset_hwtcl \
                core4_1_pf7_pci_msix_pba_hwtcl \
                core4_1_pf7_pci_msix_table_size_vfcomm_cs2_hwtcl \
                core4_1_virtual_pf0_exvf_msix_cap_enable_hwtcl \
                core4_1_exvf_msix_tablesize_pf0 \
                core4_1_exvf_msixtable_offset_pf0 \
                core4_1_exvf_msixtable_bir_pf0 \
                core4_1_exvf_msixpba_offset_pf0 \
                core4_1_virtual_pf1_exvf_msix_cap_enable_hwtcl \
                core4_1_exvf_msix_tablesize_pf1 \
                core4_1_exvf_msixtable_offset_pf1 \
                core4_1_exvf_msixtable_bir_pf1 \
                core4_1_exvf_msixpba_offset_pf1 \
                core4_1_virtual_pf2_exvf_msix_cap_enable_hwtcl \
                core4_1_exvf_msix_tablesize_pf2 \
                core4_1_exvf_msixtable_offset_pf2 \
                core4_1_exvf_msixtable_bir_pf2 \
                core4_1_exvf_msixpba_offset_pf2 \
                core4_1_virtual_pf3_exvf_msix_cap_enable_hwtcl \
                core4_1_exvf_msix_tablesize_pf3 \
                core4_1_exvf_msixtable_offset_pf3 \
                core4_1_exvf_msixtable_bir_pf3 \
                core4_1_exvf_msixpba_offset_pf3 \
                core4_1_virtual_pf4_exvf_msix_cap_enable_hwtcl \
                core4_1_exvf_msix_tablesize_pf4 \
                core4_1_exvf_msixtable_offset_pf4 \
                core4_1_exvf_msixtable_bir_pf4 \
                core4_1_exvf_msixpba_offset_pf4 \
                core4_1_virtual_pf5_exvf_msix_cap_enable_hwtcl \
                core4_1_exvf_msix_tablesize_pf5 \
                core4_1_exvf_msixtable_offset_pf5 \
                core4_1_exvf_msixtable_bir_pf5 \
                core4_1_exvf_msixpba_offset_pf5 \
                core4_1_virtual_pf6_exvf_msix_cap_enable_hwtcl \
                core4_1_exvf_msix_tablesize_pf6 \
                core4_1_exvf_msixtable_offset_pf6 \
                core4_1_exvf_msixtable_bir_pf6 \
                core4_1_exvf_msixpba_offset_pf6 \
                core4_1_virtual_pf7_exvf_msix_cap_enable_hwtcl \
                core4_1_exvf_msix_tablesize_pf7 \
                core4_1_exvf_msixtable_offset_pf7 \
                core4_1_exvf_msixtable_bir_pf7 \
                core4_1_exvf_msixpba_offset_pf7 \
                core4_1_virtual_pf1_msi_enable_user_hwtcl \
                core4_1_virtual_pf2_msi_enable_user_hwtcl \
                core4_1_virtual_pf3_msi_enable_user_hwtcl \
                core4_1_virtual_pf4_msi_enable_user_hwtcl \
                core4_1_virtual_pf5_msi_enable_user_hwtcl \
                core4_1_virtual_pf6_msi_enable_user_hwtcl \
                core4_1_virtual_pf7_msi_enable_user_hwtcl \
                core4_1_virtual_pf1_msi_64b_addressing_user_hwtcl \
                core4_1_virtual_pf2_msi_64b_addressing_user_hwtcl \
                core4_1_virtual_pf3_msi_64b_addressing_user_hwtcl \
                core4_1_virtual_pf4_msi_64b_addressing_user_hwtcl \
                core4_1_virtual_pf5_msi_64b_addressing_user_hwtcl \
                core4_1_virtual_pf6_msi_64b_addressing_user_hwtcl \
                core4_1_virtual_pf7_msi_64b_addressing_user_hwtcl \
                core4_1_pf1_pci_msi_ext_data_cap_hwtcl \
                core4_1_pf2_pci_msi_ext_data_cap_hwtcl \
                core4_1_pf3_pci_msi_ext_data_cap_hwtcl \
                core4_1_pf4_pci_msi_ext_data_cap_hwtcl \
                core4_1_pf5_pci_msi_ext_data_cap_hwtcl \
                core4_1_pf6_pci_msi_ext_data_cap_hwtcl \
                core4_1_pf7_pci_msi_ext_data_cap_hwtcl \
                core4_1_pf1_pci_msi_multiple_msg_cap_hwtcl \
                core4_1_pf2_pci_msi_multiple_msg_cap_hwtcl \
                core4_1_pf3_pci_msi_multiple_msg_cap_hwtcl \
                core4_1_pf4_pci_msi_multiple_msg_cap_hwtcl \
                core4_1_pf5_pci_msi_multiple_msg_cap_hwtcl \
                core4_1_pf6_pci_msi_multiple_msg_cap_hwtcl \
                core4_1_pf7_pci_msi_multiple_msg_cap_hwtcl \
                core4_1_pf0_gen3_eq_pset_req_vec_c0_user_hwtcl \
                core4_1_pf0_gen3_eq_pset_req_vec_atg4_c0_user_hwtcl  \
                core4_1_topology_integer_hwtcl \
                core4_1_enable_apps_ready_entr_l23_hwtcl \
                core4_1_enable_apps_pm_xmt_turnoff_hwtcl \
                core4_1_enable_app_xfer_pending_hwtcl  \
                core4_1_enable_10bit_tag_support_intf_hwtcl \
                hssi_ctp_u_wrpcie_top_u_core4_1_topology \
                core4_1_pld_crs_en_hwtcl \
                core4_1_virtual_txeq_mode_hwtcl \
                core4_1_pf0_gen3_eq_pset_req_vec_atg4_hwtcl \
                core4_1_enable_rx_buffer_limit_ports_hwtcl \
                core4_1_rxbuf_limit_posted_bypass_hwtcl \
                core4_1_rxbuf_limit_nonposted_bypass_hwtcl \
                core4_1_rxbuf_limit_cpl_bypass_hwtcl \
                core4_1_rxbuf_limit_bypass_hwtcl \
                core4_1_pf0_dsp_16g_tx_preset_hwtcl \
                core4_1_pf0_dsp_tx_preset_hwtcl \
                core4_1_pf0_usp_16g_tx_preset_hwtcl \
                core4_1_pf0_usp_tx_preset_hwtcl \
                core4_1_pf_no_soft_rst_hwtcl \
                core4_1_virtual_hrdrstctrl_en_hwtcl \
                core4_1_virtual_uc_calibration_en_hwtcl \
                core4_1_pf0_rp_rom_bar_enabled_hwtcl \
                core4_1_pf0_pcie_cap_rcb_hwtcl \
                core4_1_pf1_pcie_cap_rcb_hwtcl \
                core4_1_pf2_pcie_cap_rcb_hwtcl \
                core4_1_pf3_pcie_cap_rcb_hwtcl \
                core4_1_pf4_pcie_cap_rcb_hwtcl \
                core4_1_pf5_pcie_cap_rcb_hwtcl \
                core4_1_pf6_pcie_cap_rcb_hwtcl \
                core4_1_pf7_pcie_cap_rcb_hwtcl \
                core4_1_pld_clrpcs_user_hwtcl \
                core4_1_pld_clrpcs_hwtcl \
                core4_1_pf0_gen3_eq_pset_req_vec_atg4_a0_user_hwtcl \
                core4_1_pf0_gen3_eq_pset_req_vec_atg4_b0_user_hwtcl \
                core4_1_pf0_gen3_eq_pset_req_vec_b0_user_hwtcl \
                core4_1_pf0_dsp_rx_preset_hint_hwtcl \
                core4_1_pf0_usp_rx_preset_hint_hwtcl \
                core4_1_enable_pld_rst_port0_hwtcl \
                core4_1_pf0_sriov_vf_bar0_type_int_hwtcl \
                core4_1_pf0_sriov_vf_bar0_address_width_int_hwtcl \
                core4_1_pf0_sriov_vf_bar1_type_int_hwtcl \
                core4_1_pf0_sriov_vf_bar1_address_width_int_hwtcl \
                core4_1_pf0_sriov_vf_bar2_type_int_hwtcl \
                core4_1_pf0_sriov_vf_bar2_address_width_int_hwtcl \
                core4_1_pf0_sriov_vf_bar3_type_int_hwtcl \
                core4_1_pf0_sriov_vf_bar3_address_width_int_hwtcl \
                core4_1_pf0_sriov_vf_bar4_type_int_hwtcl \
                core4_1_pf0_sriov_vf_bar4_address_width_int_hwtcl \
                core4_1_pf0_sriov_vf_bar5_type_int_hwtcl \
                core4_1_pf0_sriov_vf_bar5_address_width_int_hwtcl \
                core4_1_pf1_sriov_vf_bar0_type_int_hwtcl \
                core4_1_pf1_sriov_vf_bar0_address_width_int_hwtcl \
                core4_1_pf1_sriov_vf_bar1_type_int_hwtcl \
                core4_1_pf1_sriov_vf_bar1_address_width_int_hwtcl \
                core4_1_pf1_sriov_vf_bar2_type_int_hwtcl \
                core4_1_pf1_sriov_vf_bar2_address_width_int_hwtcl \
                core4_1_pf1_sriov_vf_bar3_type_int_hwtcl \
                core4_1_pf1_sriov_vf_bar3_address_width_int_hwtcl \
                core4_1_pf1_sriov_vf_bar4_type_int_hwtcl \
                core4_1_pf1_sriov_vf_bar4_address_width_int_hwtcl \
                core4_1_pf1_sriov_vf_bar5_type_int_hwtcl \
                core4_1_pf1_sriov_vf_bar5_address_width_int_hwtcl \
                core4_1_pf2_sriov_vf_bar0_type_int_hwtcl \
                core4_1_pf2_sriov_vf_bar0_address_width_int_hwtcl \
                core4_1_pf2_sriov_vf_bar1_type_int_hwtcl \
                core4_1_pf2_sriov_vf_bar1_address_width_int_hwtcl \
                core4_1_pf2_sriov_vf_bar2_type_int_hwtcl \
                core4_1_pf2_sriov_vf_bar2_address_width_int_hwtcl \
                core4_1_pf2_sriov_vf_bar3_type_int_hwtcl \
                core4_1_pf2_sriov_vf_bar3_address_width_int_hwtcl \
                core4_1_pf2_sriov_vf_bar4_type_int_hwtcl \
                core4_1_pf2_sriov_vf_bar4_address_width_int_hwtcl \
                core4_1_pf2_sriov_vf_bar5_type_int_hwtcl \
                core4_1_pf2_sriov_vf_bar5_address_width_int_hwtcl \
                core4_1_pf3_sriov_vf_bar0_type_int_hwtcl \
                core4_1_pf3_sriov_vf_bar0_address_width_int_hwtcl \
                core4_1_pf3_sriov_vf_bar1_type_int_hwtcl \
                core4_1_pf3_sriov_vf_bar1_address_width_int_hwtcl \
                core4_1_pf3_sriov_vf_bar2_type_int_hwtcl \
                core4_1_pf3_sriov_vf_bar2_address_width_int_hwtcl \
                core4_1_pf3_sriov_vf_bar3_type_int_hwtcl \
                core4_1_pf3_sriov_vf_bar3_address_width_int_hwtcl \
                core4_1_pf3_sriov_vf_bar4_type_int_hwtcl \
                core4_1_pf3_sriov_vf_bar4_address_width_int_hwtcl \
                core4_1_pf3_sriov_vf_bar5_type_int_hwtcl \
                core4_1_pf3_sriov_vf_bar5_address_width_int_hwtcl \
                core4_1_pf4_sriov_vf_bar0_type_int_hwtcl \
                core4_1_pf4_sriov_vf_bar0_address_width_int_hwtcl \
                core4_1_pf4_sriov_vf_bar1_type_int_hwtcl \
                core4_1_pf4_sriov_vf_bar1_address_width_int_hwtcl \
                core4_1_pf4_sriov_vf_bar2_type_int_hwtcl \
                core4_1_pf4_sriov_vf_bar2_address_width_int_hwtcl \
                core4_1_pf4_sriov_vf_bar3_type_int_hwtcl \
                core4_1_pf4_sriov_vf_bar3_address_width_int_hwtcl \
                core4_1_pf4_sriov_vf_bar4_type_int_hwtcl \
                core4_1_pf4_sriov_vf_bar4_address_width_int_hwtcl \
                core4_1_pf4_sriov_vf_bar5_type_int_hwtcl \
                core4_1_pf4_sriov_vf_bar5_address_width_int_hwtcl \
                core4_1_pf5_sriov_vf_bar0_type_int_hwtcl \
                core4_1_pf5_sriov_vf_bar0_address_width_int_hwtcl \
                core4_1_pf5_sriov_vf_bar1_type_int_hwtcl \
                core4_1_pf5_sriov_vf_bar1_address_width_int_hwtcl \
                core4_1_pf5_sriov_vf_bar2_type_int_hwtcl \
                core4_1_pf5_sriov_vf_bar2_address_width_int_hwtcl \
                core4_1_pf5_sriov_vf_bar3_type_int_hwtcl \
                core4_1_pf5_sriov_vf_bar3_address_width_int_hwtcl \
                core4_1_pf5_sriov_vf_bar4_type_int_hwtcl \
                core4_1_pf5_sriov_vf_bar4_address_width_int_hwtcl \
                core4_1_pf5_sriov_vf_bar5_type_int_hwtcl \
                core4_1_pf5_sriov_vf_bar5_address_width_int_hwtcl \
                core4_1_pf6_sriov_vf_bar0_type_int_hwtcl \
                core4_1_pf6_sriov_vf_bar0_address_width_int_hwtcl \
                core4_1_pf6_sriov_vf_bar1_type_int_hwtcl \
                core4_1_pf6_sriov_vf_bar1_address_width_int_hwtcl \
                core4_1_pf6_sriov_vf_bar2_type_int_hwtcl \
                core4_1_pf6_sriov_vf_bar2_address_width_int_hwtcl \
                core4_1_pf6_sriov_vf_bar3_type_int_hwtcl \
                core4_1_pf6_sriov_vf_bar3_address_width_int_hwtcl \
                core4_1_pf6_sriov_vf_bar4_type_int_hwtcl \
                core4_1_pf6_sriov_vf_bar4_address_width_int_hwtcl \
                core4_1_pf6_sriov_vf_bar5_type_int_hwtcl \
                core4_1_pf6_sriov_vf_bar5_address_width_int_hwtcl \
                core4_1_pf7_sriov_vf_bar0_type_int_hwtcl \
                core4_1_pf7_sriov_vf_bar0_address_width_int_hwtcl \
                core4_1_pf7_sriov_vf_bar1_type_int_hwtcl \
                core4_1_pf7_sriov_vf_bar1_address_width_int_hwtcl \
                core4_1_pf7_sriov_vf_bar2_type_int_hwtcl \
                core4_1_pf7_sriov_vf_bar2_address_width_int_hwtcl \
                core4_1_pf7_sriov_vf_bar3_type_int_hwtcl \
                core4_1_pf7_sriov_vf_bar3_address_width_int_hwtcl \
                core4_1_pf7_sriov_vf_bar4_type_int_hwtcl \
                core4_1_pf7_sriov_vf_bar4_address_width_int_hwtcl \
                core4_1_pf7_sriov_vf_bar5_type_int_hwtcl \
                core4_1_pf7_sriov_vf_bar5_address_width_int_hwtcl \
                core4_1_pf0_expansion_base_address_register_integer_hwtcl \
                core4_1_pf1_expansion_base_address_register_integer_hwtcl \
                core4_1_pf2_expansion_base_address_register_integer_hwtcl \
                core4_1_pf3_expansion_base_address_register_integer_hwtcl \
                core4_1_pf4_expansion_base_address_register_integer_hwtcl \
                core4_1_pf5_expansion_base_address_register_integer_hwtcl \
                core4_1_pf6_expansion_base_address_register_integer_hwtcl \
                core4_1_pf7_expansion_base_address_register_integer_hwtcl \
                core4_1_cap_ext_tag_supp_user_hwtcl \
                core4_1_pf0_pcie_cap_ext_tag_supp_hwtcl \
                core4_1_pf1_pcie_cap_ext_tag_supp_hwtcl \
                core4_1_pf2_pcie_cap_ext_tag_supp_hwtcl \
                core4_1_pf3_pcie_cap_ext_tag_supp_hwtcl \
                core4_1_pf4_pcie_cap_ext_tag_supp_hwtcl \
                core4_1_pf5_pcie_cap_ext_tag_supp_hwtcl \
                core4_1_pf6_pcie_cap_ext_tag_supp_hwtcl \
                core4_1_pf7_pcie_cap_ext_tag_supp_hwtcl \
                core4_1_pf0_pcie_cap_ep_l0s_accpt_latency_hwtcl \
                core4_1_pf1_pcie_cap_ep_l0s_accpt_latency_hwtcl \
                core4_1_pf2_pcie_cap_ep_l0s_accpt_latency_hwtcl \
                core4_1_pf3_pcie_cap_ep_l0s_accpt_latency_hwtcl \
                core4_1_pf4_pcie_cap_ep_l0s_accpt_latency_hwtcl \
                core4_1_pf5_pcie_cap_ep_l0s_accpt_latency_hwtcl \
                core4_1_pf6_pcie_cap_ep_l0s_accpt_latency_hwtcl \
                core4_1_pf7_pcie_cap_ep_l0s_accpt_latency_hwtcl \
                core4_1_pf0_pcie_cap_ep_l1_accpt_latency_hwtcl \
                core4_1_pf1_pcie_cap_ep_l1_accpt_latency_hwtcl \
                core4_1_pf2_pcie_cap_ep_l1_accpt_latency_hwtcl \
                core4_1_pf3_pcie_cap_ep_l1_accpt_latency_hwtcl \
                core4_1_pf4_pcie_cap_ep_l1_accpt_latency_hwtcl \
                core4_1_pf5_pcie_cap_ep_l1_accpt_latency_hwtcl \
                core4_1_pf6_pcie_cap_ep_l1_accpt_latency_hwtcl \
                core4_1_pf7_pcie_cap_ep_l1_accpt_latency_hwtcl \
                core4_1_pcie_cvp_attr_hwtcl \
                core4_1_cfg_ptm_local_clock_adj_lsb_hwtcl \
                core4_1_cfg_ptm_local_clock_adj_msb_hwtcl \
                core4_1_pf1_pci_type0_vendor_id_hwtcl \
                core4_1_pf1_revision_id_hwtcl \
                core4_1_pf2_pci_type0_vendor_id_hwtcl \
                core4_1_pf2_revision_id_hwtcl \
                core4_1_pf3_pci_type0_vendor_id_hwtcl \
                core4_1_pf3_revision_id_hwtcl \
                core4_1_pf4_pci_type0_vendor_id_hwtcl \
                core4_1_pf4_revision_id_hwtcl \
                core4_1_pf5_pci_type0_vendor_id_hwtcl \
                core4_1_pf5_revision_id_hwtcl \
                core4_1_pf6_pci_type0_vendor_id_hwtcl \
                core4_1_pf6_revision_id_hwtcl \
                core4_1_pf7_pci_type0_vendor_id_hwtcl \
                core4_1_pf7_revision_id_hwtcl \
                core4_1_vendor_id_hwtcl \
                core4_1_revision_id_hwtcl \
                core4_1_vsec_next_offset_hwtcl \
                core4_1_pf0_tph_req_cap_st_table_loc_0_vfcomm_cs2_hwtcl  \
                core4_1_pf1_tph_req_cap_st_table_loc_0_vfcomm_cs2_hwtcl \
                core4_1_pf2_tph_req_cap_st_table_loc_0_vfcomm_cs2_hwtcl  \
                core4_1_pf3_tph_req_cap_st_table_loc_0_vfcomm_cs2_hwtcl \
                core4_1_pf4_tph_req_cap_st_table_loc_0_vfcomm_cs2_hwtcl  \
                core4_1_pf5_tph_req_cap_st_table_loc_0_vfcomm_cs2_hwtcl \
                core4_1_pf6_tph_req_cap_st_table_loc_0_vfcomm_cs2_hwtcl  \
                core4_1_pf7_tph_req_cap_st_table_loc_0_vfcomm_cs2_hwtcl \
                core4_1_virtio_start_byte_address_hwtcl \
                core4_1_avmm_enabled_virtio_hwtcl  \
                core4_1_ecc_ctrl_k_nparity_ecc_attr_hwtcl \
                core4_1_refclk_init_active_hwtcl \
                core4_1_enable_independent_pin_perst_hwtcl \
                core4_1_txempty_enable_hwtcl \
                core4_1_virtual_num_of_lanes_16_hwtcl \
                core4_1_pf0_pci_type0_bar5_mask_31_1_hwtcl \
                core4_1_pf0_pci_type0_bar4_mask_31_1_hwtcl \
                core4_1_pf0_pci_type0_bar3_mask_31_1_hwtcl \
                core4_1_pf0_pci_type0_bar2_mask_31_1_hwtcl \
                core4_1_pf0_pci_type0_bar1_mask_31_1_hwtcl \
                core4_1_pf0_pci_type0_bar0_mask_31_1_hwtcl \
                core4_1_pf1_virtio_capability_present_hwtcl \
                core4_1_pf2_virtio_capability_present_hwtcl \
                core4_1_pf3_virtio_capability_present_hwtcl \
                core4_1_pf4_virtio_capability_present_hwtcl \
                core4_1_pf5_virtio_capability_present_hwtcl \
                core4_1_pf6_virtio_capability_present_hwtcl \
                core4_1_pf7_virtio_capability_present_hwtcl \
                core4_1_pf0vf_virtio_capability_present_hwtcl \
                core4_1_pf1vf_virtio_capability_present_hwtcl \
                core4_1_pf2vf_virtio_capability_present_hwtcl \
                core4_1_pf3vf_virtio_capability_present_hwtcl \
                core4_1_pf4vf_virtio_capability_present_hwtcl \
                core4_1_pf5vf_virtio_capability_present_hwtcl \
                core4_1_pf6vf_virtio_capability_present_hwtcl \
                core4_1_pf7vf_virtio_capability_present_hwtcl \
                core4_1_pf1_aspm_control_hwtcl \
                core4_1_pf2_aspm_control_hwtcl \
                core4_1_pf3_aspm_control_hwtcl \
                core4_1_pf4_aspm_control_hwtcl \
                core4_1_pf5_aspm_control_hwtcl \
                core4_1_pf6_aspm_control_hwtcl \
                core4_1_pf7_aspm_control_hwtcl \
                core4_1_flr_cap_user_hwtcl \
                core4_1_flr_cap_hwtcl \
                core4_1_pf0_pcie_cap_flr_cap_hwtcl \
                core4_1_user_pcie_cap_slot_clk_config_hwtcl \
                core4_1_virtual_pf0_pl16g_cap_enable_hwtcl \
                core4_1_virtual_pf0_margin_cap_enable_hwtcl \
                core4_1_pf0_tph_req_cap_st_table_loc_1_derived_hwtcl \
                core4_1_pf1_pcie_cap_port_num_hwtcl \
                core4_1_pf2_pcie_cap_port_num_hwtcl \
                core4_1_pf3_pcie_cap_port_num_hwtcl \
                core4_1_pf4_pcie_cap_port_num_hwtcl \
                core4_1_pf5_pcie_cap_port_num_hwtcl \
                core4_1_pf6_pcie_cap_port_num_hwtcl \
                core4_1_pf7_pcie_cap_port_num_hwtcl \
                core4_1_pf1_device_control_device_status_pcie_cap_ext_tag_en_hwtcl \
                core4_1_pf2_device_control_device_status_pcie_cap_ext_tag_en_hwtcl \
                core4_1_pf3_device_control_device_status_pcie_cap_ext_tag_en_hwtcl \
                core4_1_pf4_device_control_device_status_pcie_cap_ext_tag_en_hwtcl \
                core4_1_pf5_device_control_device_status_pcie_cap_ext_tag_en_hwtcl \
                core4_1_pf6_device_control_device_status_pcie_cap_ext_tag_en_hwtcl \
                core4_1_pf7_device_control_device_status_pcie_cap_ext_tag_en_hwtcl \
                core4_1_pf1_device_control3_reg_dev3_cap_dmwr_egress_blk_hwtcl \
                core4_1_pf2_device_control3_reg_dev3_cap_dmwr_egress_blk_hwtcl \
                core4_1_pf3_device_control3_reg_dev3_cap_dmwr_egress_blk_hwtcl \
                core4_1_pf4_device_control3_reg_dev3_cap_dmwr_egress_blk_hwtcl \
                core4_1_pf5_device_control3_reg_dev3_cap_dmwr_egress_blk_hwtcl \
                core4_1_pf6_device_control3_reg_dev3_cap_dmwr_egress_blk_hwtcl \
                core4_1_pf7_device_control3_reg_dev3_cap_dmwr_egress_blk_hwtcl \
                core4_1_sriov_misc_ctrl_k_nonsriov_mode_hwtcl \
                core4_1_pf1_no_soft_rst_hwtcl \
                core4_1_pf2_no_soft_rst_hwtcl \
                core4_1_pf3_no_soft_rst_hwtcl \
                core4_1_pf4_no_soft_rst_hwtcl \
                core4_1_pf5_no_soft_rst_hwtcl \
                core4_1_pf6_no_soft_rst_hwtcl \
                core4_1_pf7_no_soft_rst_hwtcl \
                core4_1_virtual_ptm_hwtcl \
                core4_1_cfg_ptm_auto_update_period_hwtcl \
                core4_1_virtual_ptm_autoupdate_hwtcl \
                core4_1_virtual_ptm_adj_lsb_hwtcl \
                core4_1_virtual_ptm_adj_msb_hwtcl \
                core4_1_pf1_pci_type0_vendor_id_user_hwtcl \
                core4_1_pf2_pci_type0_vendor_id_user_hwtcl \
                core4_1_pf3_pci_type0_vendor_id_user_hwtcl \
                core4_1_pf4_pci_type0_vendor_id_user_hwtcl \
                core4_1_pf5_pci_type0_vendor_id_user_hwtcl \
                core4_1_pf6_pci_type0_vendor_id_user_hwtcl \
                core4_1_pf7_pci_type0_vendor_id_user_hwtcl \
                core4_1_pf1_revision_id_user_hwtcl \
                core4_1_pf2_revision_id_user_hwtcl \
                core4_1_pf3_revision_id_user_hwtcl \
                core4_1_pf4_revision_id_user_hwtcl \
                core4_1_pf5_revision_id_user_hwtcl \
                core4_1_pf6_revision_id_user_hwtcl \
                core4_1_pf7_revision_id_user_hwtcl \
                core4_1_virtual_pf1_user_vsec_cap_enable_hwtcl \
                core4_1_virtual_pf2_user_vsec_cap_enable_hwtcl \
                core4_1_virtual_pf3_user_vsec_cap_enable_hwtcl \
                core4_1_virtual_pf4_user_vsec_cap_enable_hwtcl \
                core4_1_virtual_pf5_user_vsec_cap_enable_hwtcl \
                core4_1_virtual_pf6_user_vsec_cap_enable_hwtcl \
                core4_1_virtual_pf7_user_vsec_cap_enable_hwtcl \
                core4_1_pf1_eval_interval_time_hwtcl \
                core4_1_pf2_eval_interval_time_hwtcl \
                core4_1_pf3_eval_interval_time_hwtcl \
                core4_1_pf4_eval_interval_time_hwtcl \
                core4_1_pf5_eval_interval_time_hwtcl \
                core4_1_pf6_eval_interval_time_hwtcl \
                core4_1_pf7_eval_interval_time_hwtcl \
                core4_1_virtual_num_of_lanes_8_hwtcl \
               core16_en_512s_to_1024s_adp_hwtcl \
		core16_en_512s_to_256s_adp_hwtcl \
		core16_en_256s_to_64s_adp_hwtcl \
		core16_en_256s_to_128s_adp_hwtcl \
		core16_en_256s_to_512s_adp_hwtcl \
		core16_en_128s_to_64s_adp_hwtcl \
		core16_en_128s_to_256e_adp_hwtcl \
		core16_en_128s_to_256s_adp_hwtcl \
	    \
		core8_en_256s_to_64s_adp_hwtcl \
		core8_en_256s_to_128s_adp_hwtcl \
		core8_en_256s_to_512s_adp_hwtcl \
		core8_en_128s_to_64s_adp_hwtcl \
		core8_en_128s_to_256e_adp_hwtcl \
		core8_en_128s_to_256s_adp_hwtcl \
	    \
		core4_0_en_128s_to_64s_adp_hwtcl \
		core4_0_en_128s_to_256e_adp_hwtcl \
		core4_0_en_128s_to_256s_adp_hwtcl \
	    \
		core4_1_en_128s_to_64s_adp_hwtcl \
		core4_1_en_128s_to_256e_adp_hwtcl \
		core4_1_en_128s_to_256s_adp_hwtcl \
        speed_grade \

        
       ]

            set ptile_qhip_param [list \
                ptile_debug_toolkit_hwtcl \
                ptile_enable_pciess_register_access_hwtcl \
                core16_powerdown_mode_hwtcl \
                core16_enable_test_intf_hwtcl \
                hssi_ctp_sim_mode \
                hssi_ctp_u_wrpcie_top_u_core16_topology \
                core16_pld_crs_en_hwtcl \
                core16_pf_no_soft_rst_hwtcl \
                core16_virtual_hrdrstctrl_en_hwtcl \
                core16_virtual_uc_calibration_en_hwtcl \
                core16_pf0_pcie_cap_rcb_hwtcl \
                core16_pf1_pcie_cap_rcb_hwtcl \
                core16_pf2_pcie_cap_rcb_hwtcl \
                core16_pf3_pcie_cap_rcb_hwtcl \
                core16_pf4_pcie_cap_rcb_hwtcl \
                core16_pf5_pcie_cap_rcb_hwtcl \
                core16_pf6_pcie_cap_rcb_hwtcl \
                core16_pf7_pcie_cap_rcb_hwtcl \
                core16_pf1_pcie_cap_sel_deemphasis_hwtcl \
                core16_pf2_pcie_cap_sel_deemphasis_hwtcl \
                core16_pf3_pcie_cap_sel_deemphasis_hwtcl \
                core16_pf4_pcie_cap_sel_deemphasis_hwtcl \
                core16_pf5_pcie_cap_sel_deemphasis_hwtcl \
                core16_pf6_pcie_cap_sel_deemphasis_hwtcl \
                core16_pf7_pcie_cap_sel_deemphasis_hwtcl \
                core16_pf0_pcie_cap_ep_l0s_accpt_latency_hwtcl \
                core16_pf1_pcie_cap_ep_l0s_accpt_latency_hwtcl \
                core16_pf2_pcie_cap_ep_l0s_accpt_latency_hwtcl \
                core16_pf3_pcie_cap_ep_l0s_accpt_latency_hwtcl \
                core16_pf4_pcie_cap_ep_l0s_accpt_latency_hwtcl \
                core16_pf5_pcie_cap_ep_l0s_accpt_latency_hwtcl \
                core16_pf6_pcie_cap_ep_l0s_accpt_latency_hwtcl \
                core16_pf7_pcie_cap_ep_l0s_accpt_latency_hwtcl \
                core16_pf0_pcie_cap_ep_l1_accpt_latency_hwtcl \
                core16_pf1_pcie_cap_ep_l1_accpt_latency_hwtcl \
                core16_pf2_pcie_cap_ep_l1_accpt_latency_hwtcl \
                core16_pf3_pcie_cap_ep_l1_accpt_latency_hwtcl \
                core16_pf4_pcie_cap_ep_l1_accpt_latency_hwtcl \
                core16_pf5_pcie_cap_ep_l1_accpt_latency_hwtcl \
                core16_pf6_pcie_cap_ep_l1_accpt_latency_hwtcl \
                core16_pf7_pcie_cap_ep_l1_accpt_latency_hwtcl \
                core16_pf0_sn_ser_num_reg_1_dw_hwtcl \
                core16_pf1_sn_ser_num_reg_1_dw_hwtcl \
                core16_pf2_sn_ser_num_reg_1_dw_hwtcl \
                core16_pf3_sn_ser_num_reg_1_dw_hwtcl \
                core16_pf4_sn_ser_num_reg_1_dw_hwtcl \
                core16_pf5_sn_ser_num_reg_1_dw_hwtcl \
                core16_pf6_sn_ser_num_reg_1_dw_hwtcl \
                core16_pf7_sn_ser_num_reg_1_dw_hwtcl \
                core16_pf0_sn_ser_num_reg_2_dw_hwtcl \
                core16_pf1_sn_ser_num_reg_2_dw_hwtcl \
                core16_pf2_sn_ser_num_reg_2_dw_hwtcl \
                core16_pf3_sn_ser_num_reg_2_dw_hwtcl \
                core16_pf4_sn_ser_num_reg_2_dw_hwtcl \
                core16_pf5_sn_ser_num_reg_2_dw_hwtcl \
                core16_pf6_sn_ser_num_reg_2_dw_hwtcl \
                core16_pf7_sn_ser_num_reg_2_dw_hwtcl \
                core16_avmm_enabled_virtio_hwtcl \
                core16_crs_en_default_hwtcl \
                core8_crs_en_default_hwtcl \
                core4_0_crs_en_default_hwtcl \
                core4_1_crs_en_default_hwtcl \
            \
                core8_powerdown_mode_hwtcl \
                core8_enable_test_intf_hwtcl \
                hssi_ctp_u_wrpcie_top_u_core8_topology \
                core8_pld_crs_en_hwtcl \
                core8_pf_no_soft_rst_hwtcl \
                core8_virtual_hrdrstctrl_en_hwtcl \
                core8_virtual_uc_calibration_en_hwtcl \
                core8_pf0_pcie_cap_rcb_hwtcl \
                core8_pf1_pcie_cap_rcb_hwtcl \
                core8_pf2_pcie_cap_rcb_hwtcl \
                core8_pf3_pcie_cap_rcb_hwtcl \
                core8_pf4_pcie_cap_rcb_hwtcl \
                core8_pf5_pcie_cap_rcb_hwtcl \
                core8_pf6_pcie_cap_rcb_hwtcl \
                core8_pf7_pcie_cap_rcb_hwtcl \
                core8_pf1_pcie_cap_sel_deemphasis_hwtcl \
                core8_pf2_pcie_cap_sel_deemphasis_hwtcl \
                core8_pf3_pcie_cap_sel_deemphasis_hwtcl \
                core8_pf4_pcie_cap_sel_deemphasis_hwtcl \
                core8_pf5_pcie_cap_sel_deemphasis_hwtcl \
                core8_pf6_pcie_cap_sel_deemphasis_hwtcl \
                core8_pf7_pcie_cap_sel_deemphasis_hwtcl \
                core8_refclk_init_active_hwtcl \
                core8_pf0_pcie_cap_ep_l0s_accpt_latency_hwtcl \
                core8_pf1_pcie_cap_ep_l0s_accpt_latency_hwtcl \
                core8_pf2_pcie_cap_ep_l0s_accpt_latency_hwtcl \
                core8_pf3_pcie_cap_ep_l0s_accpt_latency_hwtcl \
                core8_pf4_pcie_cap_ep_l0s_accpt_latency_hwtcl \
                core8_pf5_pcie_cap_ep_l0s_accpt_latency_hwtcl \
                core8_pf6_pcie_cap_ep_l0s_accpt_latency_hwtcl \
                core8_pf7_pcie_cap_ep_l0s_accpt_latency_hwtcl \
                core8_pf0_pcie_cap_ep_l1_accpt_latency_hwtcl \
                core8_pf1_pcie_cap_ep_l1_accpt_latency_hwtcl \
                core8_pf2_pcie_cap_ep_l1_accpt_latency_hwtcl \
                core8_pf3_pcie_cap_ep_l1_accpt_latency_hwtcl \
                core8_pf4_pcie_cap_ep_l1_accpt_latency_hwtcl \
                core8_pf5_pcie_cap_ep_l1_accpt_latency_hwtcl \
                core8_pf6_pcie_cap_ep_l1_accpt_latency_hwtcl \
                core8_pf7_pcie_cap_ep_l1_accpt_latency_hwtcl \
                core8_pf0_sn_ser_num_reg_1_dw_hwtcl \
                core8_pf1_sn_ser_num_reg_1_dw_hwtcl \
                core8_pf2_sn_ser_num_reg_1_dw_hwtcl \
                core8_pf3_sn_ser_num_reg_1_dw_hwtcl \
                core8_pf4_sn_ser_num_reg_1_dw_hwtcl \
                core8_pf5_sn_ser_num_reg_1_dw_hwtcl \
                core8_pf6_sn_ser_num_reg_1_dw_hwtcl \
                core8_pf7_sn_ser_num_reg_1_dw_hwtcl \
                core8_pf0_sn_ser_num_reg_2_dw_hwtcl \
                core8_pf1_sn_ser_num_reg_2_dw_hwtcl \
                core8_pf2_sn_ser_num_reg_2_dw_hwtcl \
                core8_pf3_sn_ser_num_reg_2_dw_hwtcl \
                core8_pf4_sn_ser_num_reg_2_dw_hwtcl \
                core8_pf5_sn_ser_num_reg_2_dw_hwtcl \
                core8_pf6_sn_ser_num_reg_2_dw_hwtcl \
                core8_pf7_sn_ser_num_reg_2_dw_hwtcl \
                core8_avmm_enabled_virtio_hwtcl \
                core16_virtual_pf0_user_vsec_offset_hwtcl \
                core8_virtual_pf0_user_vsec_offset_hwtcl \
                core4_0_virtual_pf0_user_vsec_offset_hwtcl \
                core4_1_virtual_pf0_user_vsec_offset_hwtcl \
            \
                core4_0_powerdown_mode_hwtcl \
                core4_0_enable_test_intf_hwtcl \
                hssi_ctp_u_wrpcie_top_u_core4_0_topology \
                core4_0_pld_crs_en_hwtcl \
                core4_0_pf0_virtio_capability_present_hwtcl \
                core4_0_pf1_virtio_capability_present_hwtcl \
                core4_0_pf2_virtio_capability_present_hwtcl \
                core4_0_pf3_virtio_capability_present_hwtcl \
                core4_0_pf4_virtio_capability_present_hwtcl \
                core4_0_pf5_virtio_capability_present_hwtcl \
                core4_0_pf6_virtio_capability_present_hwtcl \
                core4_0_pf7_virtio_capability_present_hwtcl \
                core4_0_pf0vf_virtio_capability_present_hwtcl \
                core4_0_pf1vf_virtio_capability_present_hwtcl \
                core4_0_pf2vf_virtio_capability_present_hwtcl \
                core4_0_pf3vf_virtio_capability_present_hwtcl \
                core4_0_pf4vf_virtio_capability_present_hwtcl \
                core4_0_pf5vf_virtio_capability_present_hwtcl \
                core4_0_pf6vf_virtio_capability_present_hwtcl \
                core4_0_pf7vf_virtio_capability_present_hwtcl \
                core4_0_virtual_hrdrstctrl_en_hwtcl \
                core4_0_virtual_uc_calibration_en_hwtcl \
                core4_0_pf0_pcie_cap_rcb_hwtcl \
                core4_0_pf0_tph_req_cap_st_table_loc_1_vfcomm_cs2_hwtcl \
                core4_0_pf0_tph_req_cap_st_table_loc_1_derived_hwtcl \
                core4_0_pf0_sn_ser_num_reg_1_dw_hwtcl \
                core4_0_pf0_sn_ser_num_reg_2_dw_hwtcl \
                core4_0_virtual_pf1_enable_hwtcl \
                core4_0_virtual_pf2_enable_hwtcl \
                core4_0_virtual_pf3_enable_hwtcl \
                core4_0_virtual_pf4_enable_hwtcl \
                core4_0_virtual_pf5_enable_hwtcl \
                core4_0_virtual_pf6_enable_hwtcl \
                core4_0_virtual_pf7_enable_hwtcl \
                core4_0_enable_sriov_hwtcl \
                core4_0_virtual_pf0_sriov_enable_hwtcl \
                core4_0_virtual_pf1_sriov_enable_hwtcl \
                core4_0_virtual_pf2_sriov_enable_hwtcl \
                core4_0_virtual_pf3_sriov_enable_hwtcl \
                core4_0_virtual_pf4_sriov_enable_hwtcl \
                core4_0_virtual_pf5_sriov_enable_hwtcl \
                core4_0_virtual_pf6_sriov_enable_hwtcl \
                core4_0_virtual_pf7_sriov_enable_hwtcl \
                core4_0_total_pf_count_hwtcl \
                core4_0_enable_multi_func_hwtcl \
                core4_0_pf0_vf_count_hwtcl \
                core4_0_pf1_vf_count_hwtcl \
                core4_0_pf2_vf_count_hwtcl \
                core4_0_pf3_vf_count_hwtcl \
                core4_0_pf4_vf_count_hwtcl \
                core4_0_pf5_vf_count_hwtcl \
                core4_0_pf6_vf_count_hwtcl \
                core4_0_pf7_vf_count_hwtcl \
                core4_0_enable_virtio_hwtcl \
                core4_0_pf0_virtio_device_specific_cap_present_hwtcl \
                core4_0_pf0_virtio_cmn_config_bar_indicator_hwtcl \
                core4_0_pf0_virtio_cmn_config_bar_offset_hwtcl \
                core4_0_pf0_virtio_cmn_config_structure_length_hwtcl \
                core4_0_pf0_virtio_pciconfig_access_cfg_data_hwtcl \
                core4_0_pf0_virtio_notification_bar_indicator_hwtcl \
                core4_0_pf0_virtio_notification_bar_offset_hwtcl \
                core4_0_pf0_virtio_notification_structure_length_hwtcl \
                core4_0_pf0_virtio_notify_off_multiplier_hwtcl \
                core4_0_pf0_virtio_isrstatus_bar_indicator_hwtcl \
                core4_0_pf0_virtio_isrstatus_bar_offset_hwtcl \
                core4_0_pf0_virtio_isrstatus_structure_length_hwtcl \
                core4_0_pf0_virtio_devspecific_bar_indicator_hwtcl \
                core4_0_pf0_virtio_devspecific_bar_offset_hwtcl \
                core4_0_pf0_virtio_devspecific_structure_length_hwtcl \
                core4_0_pf0_virtio_pciconfig_access_bar_indicator_hwtcl \
                core4_0_pf0_virtio_pciconfig_access_bar_offset_hwtcl \
                core4_0_pf0_virtio_pciconfig_access_structure_length_hwtcl \
                core4_0_pf0_gen3_eq_pset_req_vec_c0_user_hwtcl \
                core4_0_pf0_gen3_eq_pset_req_vec_atg4_c0_user_hwtcl \
                core4_0_enable_cii_hwtcl \
                core4_0_enable_prs_event_hwtcl \
                core4_0_rx_dsk_enable_hwtcl \
                core4_0_virtio_cii_ctrl_k_cfg_update_en_attr_hwtcl \
                core4_0_cii_range_virtio_en_hwtcl \
                core4_0_cii_range_0_k_cii_pf_en0_attr_user_hwtcl \
                core4_0_cii_range_0_k_cii_pf_en0_attr_hwtcl \
                core4_0_cii_range_0_k_cii_start_addr0_attr_user_hwtcl \
                core4_0_cii_range_0_k_cii_start_addr0_attr_hwtcl \
                core4_0_cii_range_0_k_cii_addr_size0_attr_user_hwtcl \
                core4_0_cii_range_0_k_cii_addr_size0_attr_user_hwtcl \
                core4_0_cii_range_0_k_cii_addr_size0_attr_hwtcl \
                core4_0_cii_range_1_k_cii_pf_en1_attr_user_hwtcl \
                core4_0_cii_range_1_k_cii_pf_en1_attr_hwtcl \
                core4_0_cii_range_1_k_cii_start_addr1_attr_user_hwtcl \
                core4_0_cii_range_1_k_cii_start_addr1_attr_hwtcl \
                core4_0_cii_range_1_k_cii_addr_size1_attr_user_hwtcl \
                core4_0_cii_range_1_k_cii_addr_size1_attr_user_hwtcl \
                core4_0_cii_range_1_k_cii_addr_size1_attr_hwtcl \
                core4_0_cii_range_2_k_cii_pf_en2_attr_user_hwtcl \
                core4_0_cii_range_2_k_cii_pf_en2_attr_hwtcl \
                core4_0_cii_range_2_k_cii_start_addr2_attr_user_hwtcl \
                core4_0_cii_range_2_k_cii_start_addr2_attr_hwtcl \
                core4_0_cii_range_2_k_cii_addr_size2_attr_user_hwtcl \
                core4_0_cii_range_2_k_cii_addr_size2_attr_user_hwtcl \
                core4_0_cii_range_2_k_cii_addr_size2_attr_hwtcl \
                core4_0_cii_range_3_k_cii_pf_en3_attr_user_hwtcl \
                core4_0_cii_range_3_k_cii_pf_en3_attr_hwtcl \
                core4_0_cii_range_3_k_cii_start_addr3_attr_user_hwtcl \
                core4_0_cii_range_3_k_cii_start_addr3_attr_hwtcl \
                core4_0_cii_range_3_k_cii_addr_size3_attr_user_hwtcl \
                core4_0_cii_range_3_k_cii_addr_size3_attr_user_hwtcl \
                core4_0_cii_range_3_k_cii_addr_size3_attr_hwtcl \
                core4_0_cii_range_4_k_cii_pf_en4_attr_user_hwtcl \
                core4_0_cii_range_4_k_cii_pf_en4_attr_hwtcl \
                core4_0_cii_range_4_k_cii_start_addr4_attr_user_hwtcl \
                core4_0_cii_range_4_k_cii_start_addr4_attr_hwtcl \
                core4_0_cii_range_4_k_cii_addr_size4_attr_user_hwtcl \
                core4_0_cii_range_4_k_cii_addr_size4_attr_user_hwtcl \
                core4_0_cii_range_4_k_cii_addr_size4_attr_hwtcl \
                core4_0_cii_range_5_k_cii_pf_en5_attr_user_hwtcl \
                core4_0_cii_range_5_k_cii_pf_en5_attr_hwtcl \
                core4_0_cii_range_5_k_cii_start_addr5_attr_user_hwtcl \
                core4_0_cii_range_5_k_cii_start_addr5_attr_hwtcl \
                core4_0_cii_range_5_k_cii_addr_size5_attr_user_hwtcl \
                core4_0_cii_range_5_k_cii_addr_size5_attr_user_hwtcl \
                core4_0_cii_range_5_k_cii_addr_size5_attr_hwtcl \
                core4_0_cii_range_6_k_cii_pf_en6_attr_user_hwtcl \
                core4_0_cii_range_6_k_cii_pf_en6_attr_hwtcl \
                core4_0_cii_range_6_k_cii_start_addr6_attr_user_hwtcl \
                core4_0_cii_range_6_k_cii_start_addr6_attr_hwtcl \
                core4_0_cii_range_6_k_cii_addr_size6_attr_user_hwtcl \
                core4_0_cii_range_6_k_cii_addr_size6_attr_user_hwtcl \
                core4_0_cii_range_6_k_cii_addr_size6_attr_hwtcl \
                core4_0_cii_range_7_k_cii_pf_en7_attr_user_hwtcl \
                core4_0_cii_range_7_k_cii_pf_en7_attr_hwtcl \
                core4_0_cii_range_7_k_cii_start_addr7_attr_user_hwtcl \
                core4_0_cii_range_7_k_cii_start_addr7_attr_hwtcl \
                core4_0_cii_range_7_k_cii_addr_size7_attr_user_hwtcl \
                core4_0_cii_range_7_k_cii_addr_size7_attr_user_hwtcl \
                core4_0_cii_range_7_k_cii_addr_size7_attr_hwtcl \
                core4_0_virtual_pf0_msix_enable_user_hwtcl \
                core4_0_virtual_pf1_msix_enable_user_hwtcl \
                core4_0_virtual_pf2_msix_enable_user_hwtcl \
                core4_0_virtual_pf3_msix_enable_user_hwtcl \
                core4_0_virtual_pf4_msix_enable_user_hwtcl \
                core4_0_virtual_pf5_msix_enable_user_hwtcl \
                core4_0_virtual_pf6_msix_enable_user_hwtcl \
                core4_0_virtual_pf7_msix_enable_user_hwtcl \
                core4_0_virtual_pf1_msix_enable_hwtcl \
                core4_0_virtual_pf2_msix_enable_hwtcl \
                core4_0_virtual_pf3_msix_enable_hwtcl \
                core4_0_virtual_pf4_msix_enable_hwtcl \
                core4_0_virtual_pf5_msix_enable_hwtcl \
                core4_0_virtual_pf6_msix_enable_hwtcl \
                core4_0_virtual_pf7_msix_enable_hwtcl \
                core4_0_pf1_pci_msix_table_size_hwtcl \
                core4_0_pf1_pci_msix_table_offset_hwtcl \
                core4_0_pf1_pci_msix_bir_hwtcl \
                core4_0_pf1_pci_msix_pba_offset_hwtcl \
                core4_0_pf1_pci_msix_pba_hwtcl \
                core4_0_pf1_pci_msix_table_size_vfcomm_cs2_hwtcl \
                core4_0_pf2_pci_msix_table_size_hwtcl \
                core4_0_pf2_pci_msix_table_offset_hwtcl \
                core4_0_pf2_pci_msix_bir_hwtcl \
                core4_0_pf2_pci_msix_pba_offset_hwtcl \
                core4_0_pf2_pci_msix_pba_hwtcl \
                core4_0_pf2_pci_msix_table_size_vfcomm_cs2_hwtcl \
                core4_0_pf3_pci_msix_table_size_hwtcl \
                core4_0_pf3_pci_msix_table_offset_hwtcl \
                core4_0_pf3_pci_msix_bir_hwtcl \
                core4_0_pf3_pci_msix_pba_offset_hwtcl \
                core4_0_pf3_pci_msix_pba_hwtcl \
                core4_0_pf3_pci_msix_table_size_vfcomm_cs2_hwtcl \
                core4_0_pf4_pci_msix_table_size_hwtcl \
                core4_0_pf4_pci_msix_table_offset_hwtcl \
                core4_0_pf4_pci_msix_bir_hwtcl \
                core4_0_pf4_pci_msix_pba_offset_hwtcl \
                core4_0_pf4_pci_msix_pba_hwtcl \
                core4_0_pf4_pci_msix_table_size_vfcomm_cs2_hwtcl \
                core4_0_pf5_pci_msix_table_size_hwtcl \
                core4_0_pf5_pci_msix_table_offset_hwtcl \
                core4_0_pf5_pci_msix_bir_hwtcl \
                core4_0_pf5_pci_msix_pba_offset_hwtcl \
                core4_0_pf5_pci_msix_pba_hwtcl \
                core4_0_pf5_pci_msix_table_size_vfcomm_cs2_hwtcl \
                core4_0_pf6_pci_msix_table_size_hwtcl \
                core4_0_pf6_pci_msix_table_offset_hwtcl \
                core4_0_pf6_pci_msix_bir_hwtcl \
                core4_0_pf6_pci_msix_pba_offset_hwtcl \
                core4_0_pf6_pci_msix_pba_hwtcl \
                core4_0_pf6_pci_msix_table_size_vfcomm_cs2_hwtcl \
                core4_0_pf7_pci_msix_table_size_hwtcl \
                core4_0_pf7_pci_msix_table_offset_hwtcl \
                core4_0_pf7_pci_msix_bir_hwtcl \
                core4_0_pf7_pci_msix_pba_offset_hwtcl \
                core4_0_pf7_pci_msix_pba_hwtcl \
                core4_0_pf7_pci_msix_table_size_vfcomm_cs2_hwtcl \
                core4_0_virtual_pf0_exvf_msix_cap_enable_hwtcl \
                core4_0_exvf_msix_tablesize_pf0 \
                core4_0_exvf_msixtable_offset_pf0 \
                core4_0_exvf_msixtable_bir_pf0 \
                core4_0_exvf_msixpba_offset_pf0 \
                core4_0_virtual_pf1_exvf_msix_cap_enable_hwtcl \
                core4_0_exvf_msix_tablesize_pf1 \
                core4_0_exvf_msixtable_offset_pf1 \
                core4_0_exvf_msixtable_bir_pf1 \
                core4_0_exvf_msixpba_offset_pf1 \
                 core4_0_virtual_pf2_exvf_msix_cap_enable_hwtcl \
                core4_0_exvf_msix_tablesize_pf2 \
                core4_0_exvf_msixtable_offset_pf2 \
                core4_0_exvf_msixtable_bir_pf2 \
                core4_0_exvf_msixpba_offset_pf2 \
                core4_0_virtual_pf3_exvf_msix_cap_enable_hwtcl \
                core4_0_exvf_msix_tablesize_pf3 \
                core4_0_exvf_msixtable_offset_pf3 \
                core4_0_exvf_msixtable_bir_pf3 \
                core4_0_exvf_msixpba_offset_pf3 \
                core4_0_virtual_pf4_exvf_msix_cap_enable_hwtcl \
                core4_0_exvf_msix_tablesize_pf4 \
                core4_0_exvf_msixtable_offset_pf4 \
                core4_0_exvf_msixtable_bir_pf4 \
                core4_0_exvf_msixpba_offset_pf4 \
                core4_0_virtual_pf5_exvf_msix_cap_enable_hwtcl \
                core4_0_exvf_msix_tablesize_pf5 \
                core4_0_exvf_msixtable_offset_pf5 \
                core4_0_exvf_msixtable_bir_pf5 \
                core4_0_exvf_msixpba_offset_pf5 \
                core4_0_virtual_pf6_exvf_msix_cap_enable_hwtcl \
                core4_0_exvf_msix_tablesize_pf6 \
                core4_0_exvf_msixtable_offset_pf6 \
                core4_0_exvf_msixtable_bir_pf6 \
                core4_0_exvf_msixpba_offset_pf6 \
                core4_0_virtual_pf7_exvf_msix_cap_enable_hwtcl \
                core4_0_exvf_msix_tablesize_pf7 \
                core4_0_exvf_msixtable_offset_pf7 \
                core4_0_exvf_msixtable_bir_pf7 \
                core4_0_exvf_msixpba_offset_pf7 \
                core4_0_virtual_pf0_pasid_cap_enable_hwtcl \
                core4_0_pf0_pasid_cap_execute_permission_supported \
                core4_0_pf0_pasid_cap_privileged_mode_supported \
                core4_0_pf0_pasid_cap_max_pasid_width \
                core4_0_virtual_pf1_pasid_cap_enable_hwtcl \
                core4_0_pf1_pasid_cap_execute_permission_supported \
                core4_0_pf1_pasid_cap_privileged_mode_supported \
                core4_0_pf1_pasid_cap_max_pasid_width \
                core4_0_virtual_pf2_pasid_cap_enable_hwtcl \
                core4_0_pf2_pasid_cap_execute_permission_supported \
                core4_0_pf2_pasid_cap_privileged_mode_supported \
                core4_0_pf2_pasid_cap_max_pasid_width \
                core4_0_virtual_pf3_pasid_cap_enable_hwtcl \
                core4_0_pf3_pasid_cap_execute_permission_supported \
                core4_0_pf3_pasid_cap_privileged_mode_supported \
                core4_0_pf3_pasid_cap_max_pasid_width \
                core4_0_virtual_pf4_pasid_cap_enable_hwtcl \
                core4_0_pf4_pasid_cap_execute_permission_supported \
                core4_0_pf4_pasid_cap_privileged_mode_supported \
                core4_0_pf4_pasid_cap_max_pasid_width \
                core4_0_virtual_pf5_pasid_cap_enable_hwtcl \
                core4_0_pf5_pasid_cap_execute_permission_supported \
                core4_0_pf5_pasid_cap_privileged_mode_supported \
                core4_0_pf5_pasid_cap_max_pasid_width \
-               core4_0_virtual_pf6_pasid_cap_enable_hwtcl \
                core4_0_pf6_pasid_cap_execute_permission_supported \
                core4_0_pf6_pasid_cap_privileged_mode_supported \
                core4_0_pf6_pasid_cap_max_pasid_width \
                core4_0_virtual_pf7_pasid_cap_enable_hwtcl \
                core4_0_pf7_pasid_cap_execute_permission_supported \
                core4_0_pf7_pasid_cap_privileged_mode_supported \
                core4_0_pf7_pasid_cap_max_pasid_width \
                core4_0_virtual_pf1_prs_ext_cap_enable_hwtcl \
                core4_0_virtual_pf2_prs_ext_cap_enable_hwtcl \
                core4_0_virtual_pf3_prs_ext_cap_enable_hwtcl \
                core4_0_virtual_pf4_prs_ext_cap_enable_hwtcl \
                core4_0_virtual_pf5_prs_ext_cap_enable_hwtcl \
                core4_0_virtual_pf6_prs_ext_cap_enable_hwtcl \
                core4_0_virtual_pf7_prs_ext_cap_enable_hwtcl \
                core4_0_pf1_prs_outstanding_capacity_hwtcl \
                core4_0_pf2_prs_outstanding_capacity_hwtcl \
                core4_0_pf3_prs_outstanding_capacity_hwtcl \
                core4_0_pf4_prs_outstanding_capacity_hwtcl \
                core4_0_pf5_prs_outstanding_capacity_hwtcl \
                core4_0_pf6_prs_outstanding_capacity_hwtcl \
                core4_0_pf7_prs_outstanding_capacity_hwtcl \
                core4_0_virtual_pf1_acs_cap_enable_hwtcl \
                core4_0_virtual_pf2_acs_cap_enable_hwtcl \
                core4_0_virtual_pf3_acs_cap_enable_hwtcl \
                core4_0_virtual_pf4_acs_cap_enable_hwtcl \
                core4_0_virtual_pf5_acs_cap_enable_hwtcl \
                core4_0_virtual_pf6_acs_cap_enable_hwtcl \
                core4_0_virtual_pf7_acs_cap_enable_hwtcl \
                core4_0_pf1_acs_cap_acs_p2p_egress_control_hwtcl \
                core4_0_pf2_acs_cap_acs_p2p_egress_control_hwtcl \
                core4_0_pf3_acs_cap_acs_p2p_egress_control_hwtcl \
                core4_0_pf4_acs_cap_acs_p2p_egress_control_hwtcl \
                core4_0_pf5_acs_cap_acs_p2p_egress_control_hwtcl \
                core4_0_pf6_acs_cap_acs_p2p_egress_control_hwtcl \
                core4_0_pf7_acs_cap_acs_p2p_egress_control_hwtcl \
                core4_0_pf0_int_pin_hwtcl \
                core4_0_pf1_int_pin_hwtcl \
                core4_0_pf2_int_pin_hwtcl \
                core4_0_pf3_int_pin_hwtcl \
                core4_0_pf4_int_pin_hwtcl \
                core4_0_pf5_int_pin_hwtcl \
                core4_0_pf6_int_pin_hwtcl \
                core4_0_pf7_int_pin_hwtcl \
                core4_0_virtual_pf0_msi_enable_hwtcl \
                core4_0_virtual_pf1_msi_enable_hwtcl \
                core4_0_virtual_pf2_msi_enable_hwtcl \
                core4_0_virtual_pf3_msi_enable_hwtcl \
                core4_0_virtual_pf4_msi_enable_hwtcl \
                core4_0_virtual_pf5_msi_enable_hwtcl \
                core4_0_virtual_pf6_msi_enable_hwtcl \
                core4_0_virtual_pf7_msi_enable_hwtcl \
                core4_0_enable_msi_interface_hwtcl \
                core4_0_virtual_pf0_msi_enable_user_hwtcl \
                core4_0_virtual_pf1_msi_enable_user_hwtcl \
                core4_0_virtual_pf2_msi_enable_user_hwtcl \
                core4_0_virtual_pf3_msi_enable_user_hwtcl \
                core4_0_virtual_pf4_msi_enable_user_hwtcl \
                core4_0_virtual_pf5_msi_enable_user_hwtcl \
                core4_0_virtual_pf6_msi_enable_user_hwtcl \
                core4_0_virtual_pf7_msi_enable_user_hwtcl \
                core4_0_virtual_pf0_msi_64b_addressing_user_hwtcl \
                core4_0_virtual_pf1_msi_64b_addressing_user_hwtcl \
                core4_0_virtual_pf2_msi_64b_addressing_user_hwtcl \
                core4_0_virtual_pf3_msi_64b_addressing_user_hwtcl \
                core4_0_virtual_pf4_msi_64b_addressing_user_hwtcl \
                core4_0_virtual_pf5_msi_64b_addressing_user_hwtcl \
                core4_0_virtual_pf6_msi_64b_addressing_user_hwtcl \
                core4_0_virtual_pf7_msi_64b_addressing_user_hwtcl \
                core4_0_pf0_pci_msi_ext_data_cap_hwtcl \
                core4_0_pf1_pci_msi_ext_data_cap_hwtcl \
                core4_0_pf2_pci_msi_ext_data_cap_hwtcl \
                core4_0_pf3_pci_msi_ext_data_cap_hwtcl \
                core4_0_pf4_pci_msi_ext_data_cap_hwtcl \
                core4_0_pf5_pci_msi_ext_data_cap_hwtcl \
                core4_0_pf6_pci_msi_ext_data_cap_hwtcl \
                core4_0_pf7_pci_msi_ext_data_cap_hwtcl \
                core4_0_pf0_pci_msi_multiple_msg_cap_hwtcl \
                core4_0_pf1_pci_msi_multiple_msg_cap_hwtcl \
                core4_0_pf2_pci_msi_multiple_msg_cap_hwtcl \
                core4_0_pf3_pci_msi_multiple_msg_cap_hwtcl \
                core4_0_pf4_pci_msi_multiple_msg_cap_hwtcl \
                core4_0_pf5_pci_msi_multiple_msg_cap_hwtcl \
                core4_0_pf6_pci_msi_multiple_msg_cap_hwtcl \
                core4_0_pf7_pci_msi_multiple_msg_cap_hwtcl \
                core4_0_pf0_bar0_type_user_hwtcl \
                core4_0_pf0_bar0_address_width_user_hwtcl \
                core4_0_pf1_bar0_type_user_hwtcl \
                core4_0_pf2_bar0_type_user_hwtcl \
                core4_0_pf3_bar0_type_user_hwtcl \
                core4_0_pf1_bar0_address_width_user_hwtcl \
                core4_0_pf2_bar0_address_width_user_hwtcl \
                core4_0_pf3_bar0_address_width_user_hwtcl \
                core4_0_pf0_sriov_vf_bar0_type_user_hwtcl \
                core4_0_pf1_sriov_vf_bar0_type_user_hwtcl \
                core4_0_pf2_sriov_vf_bar0_type_user_hwtcl \
                core4_0_pf3_sriov_vf_bar0_type_user_hwtcl \
                core4_0_pf0_sriov_vf_bar0_type_hwtcl \
                core4_0_pf1_sriov_vf_bar0_type_hwtcl \
                core4_0_pf2_sriov_vf_bar0_type_hwtcl \
                core4_0_pf3_sriov_vf_bar0_type_hwtcl \
                core4_0_pf0_sriov_vf_bar0_address_width_hwtcl \
                core4_0_pf1_sriov_vf_bar0_address_width_hwtcl \
                core4_0_pf2_sriov_vf_bar0_address_width_hwtcl \
                core4_0_pf3_sriov_vf_bar0_address_width_hwtcl \
                core4_0_pf1_virtio_device_specific_cap_present_hwtcl \
                core4_0_pf2_virtio_device_specific_cap_present_hwtcl \
                core4_0_pf3_virtio_device_specific_cap_present_hwtcl \
                core4_0_pf0vf_virtio_device_specific_cap_present_hwtcl \
                core4_0_pf1vf_virtio_device_specific_cap_present_hwtcl \
                core4_0_pf2vf_virtio_device_specific_cap_present_hwtcl \
                core4_0_pf3vf_virtio_device_specific_cap_present_hwtcl \
                core4_0_exvf_msixpba_bir_pf0  \
                core4_0_exvf_msixpba_bir_pf1  \
                core4_0_exvf_msixpba_bir_pf2  \
                core4_0_exvf_msixpba_bir_pf3  \
                core4_0_virtual_pf0_user_vsec_offset_hwtcl \
                core4_1_virtual_pf0_user_vsec_offset_hwtcl \
            \
                core4_1_powerdown_mode_hwtcl \
                core4_1_enable_test_intf_hwtcl \
                hssi_ctp_u_wrpcie_top_u_core4_1_topology \
                core4_1_pld_crs_en_hwtcl \
                core4_1_pf0_virtio_capability_present_hwtcl \
                core4_1_pf1_virtio_capability_present_hwtcl \
                core4_1_pf2_virtio_capability_present_hwtcl \
                core4_1_pf3_virtio_capability_present_hwtcl \
                core4_1_pf4_virtio_capability_present_hwtcl \
                core4_1_pf5_virtio_capability_present_hwtcl \
                core4_1_pf6_virtio_capability_present_hwtcl \
                core4_1_pf7_virtio_capability_present_hwtcl \
                core4_1_pf0vf_virtio_capability_present_hwtcl \
                core4_1_pf1vf_virtio_capability_present_hwtcl \
                core4_1_pf2vf_virtio_capability_present_hwtcl \
                core4_1_pf3vf_virtio_capability_present_hwtcl \
                core4_1_pf4vf_virtio_capability_present_hwtcl \
                core4_1_pf5vf_virtio_capability_present_hwtcl \
                core4_1_pf6vf_virtio_capability_present_hwtcl \
                core4_1_pf7vf_virtio_capability_present_hwtcl \
                core4_1_virtual_hrdrstctrl_en_hwtcl \
                core4_1_virtual_uc_calibration_en_hwtcl \
                core4_1_pf0_tph_req_cap_st_table_loc_1_vfcomm_cs2_hwtcl \
                core4_1_pf0_tph_req_cap_st_table_loc_1_derived_hwtcl \
                core4_1_pf0_sn_ser_num_reg_1_dw_hwtcl \
                core4_1_pf0_sn_ser_num_reg_2_dw_hwtcl \
                 core4_1_virtual_pf1_enable_hwtcl \
                core4_1_virtual_pf2_enable_hwtcl \
                core4_1_virtual_pf3_enable_hwtcl \
                core4_1_virtual_pf4_enable_hwtcl \
                core4_1_virtual_pf5_enable_hwtcl \
                core4_1_virtual_pf6_enable_hwtcl \
                core4_1_virtual_pf7_enable_hwtcl \
                core4_1_enable_sriov_hwtcl \
                core4_1_virtual_pf0_sriov_enable_hwtcl \
                core4_1_virtual_pf1_sriov_enable_hwtcl \
                core4_1_virtual_pf2_sriov_enable_hwtcl \
                core4_1_virtual_pf3_sriov_enable_hwtcl \
                core4_1_virtual_pf4_sriov_enable_hwtcl \
                core4_1_virtual_pf5_sriov_enable_hwtcl \
                core4_1_virtual_pf6_sriov_enable_hwtcl \
                core4_1_virtual_pf7_sriov_enable_hwtcl \
                core4_1_total_pf_count_hwtcl \
                core4_1_enable_multi_func_hwtcl \
                core4_1_pf0_vf_count_hwtcl \
                core4_1_pf1_vf_count_hwtcl \
                core4_1_pf2_vf_count_hwtcl \
                core4_1_pf3_vf_count_hwtcl \
                core4_1_pf4_vf_count_hwtcl \
                core4_1_pf5_vf_count_hwtcl \
                core4_1_pf6_vf_count_hwtcl \
                core4_1_pf7_vf_count_hwtcl \
                core4_1_enable_virtio_hwtcl \
                core4_1_pf0_virtio_device_specific_cap_present_hwtcl \
                core4_1_pf0_virtio_cmn_config_bar_indicator_hwtcl \
                core4_1_pf0_virtio_cmn_config_bar_offset_hwtcl \
                core4_1_pf0_virtio_cmn_config_structure_length_hwtcl \
                core4_1_pf0_virtio_pciconfig_access_cfg_data_hwtcl \
                core4_1_pf0_virtio_notification_bar_indicator_hwtcl \
                core4_1_pf0_virtio_notification_bar_offset_hwtcl \
                core4_1_pf0_virtio_notification_structure_length_hwtcl \
                core4_1_pf0_virtio_notify_off_multiplier_hwtcl \
                core4_1_pf0_virtio_isrstatus_bar_indicator_hwtcl \
                core4_1_pf0_virtio_isrstatus_bar_offset_hwtcl \
                core4_1_pf0_virtio_isrstatus_structure_length_hwtcl \
                core4_1_pf0_virtio_devspecific_bar_indicator_hwtcl \
                core4_1_pf0_virtio_devspecific_bar_offset_hwtcl \
                core4_1_pf0_virtio_devspecific_structure_length_hwtcl \
                core4_1_pf0_virtio_pciconfig_access_bar_indicator_hwtcl \
                core4_1_pf0_virtio_pciconfig_access_bar_offset_hwtcl \
                core4_1_pf0_virtio_pciconfig_access_structure_length_hwtcl \
                core4_1_pf0_gen3_eq_pset_req_vec_c0_user_hwtcl \
                core4_1_pf0_gen3_eq_pset_req_vec_atg4_c0_user_hwtcl \
                core4_1_enable_cii_hwtcl \
                core4_1_enable_prs_event_hwtcl \
                core4_1_rx_dsk_enable_hwtcl \
                core4_1_virtio_cii_ctrl_k_cfg_update_en_attr_hwtcl \
                core4_1_cii_range_virtio_en_hwtcl \
                core4_1_cii_range_0_k_cii_pf_en0_attr_user_hwtcl \
                core4_1_cii_range_0_k_cii_pf_en0_attr_hwtcl \
                core4_1_cii_range_0_k_cii_start_addr0_attr_user_hwtcl \
                core4_1_cii_range_0_k_cii_start_addr0_attr_hwtcl \
                core4_1_cii_range_0_k_cii_addr_size0_attr_user_hwtcl \
                core4_1_cii_range_0_k_cii_addr_size0_attr_user_hwtcl \
                core4_1_cii_range_0_k_cii_addr_size0_attr_hwtcl \
                core4_1_cii_range_1_k_cii_pf_en1_attr_user_hwtcl \
                core4_1_cii_range_1_k_cii_pf_en1_attr_hwtcl \
                core4_1_cii_range_1_k_cii_start_addr1_attr_user_hwtcl \
                core4_1_cii_range_1_k_cii_start_addr1_attr_hwtcl \
                core4_1_cii_range_1_k_cii_addr_size1_attr_user_hwtcl \
                core4_1_cii_range_1_k_cii_addr_size1_attr_user_hwtcl \
                core4_1_cii_range_1_k_cii_addr_size1_attr_hwtcl \
                core4_1_cii_range_2_k_cii_pf_en2_attr_user_hwtcl \
                core4_1_cii_range_2_k_cii_pf_en2_attr_hwtcl \
                core4_1_cii_range_2_k_cii_start_addr2_attr_user_hwtcl \
                core4_1_cii_range_2_k_cii_start_addr2_attr_hwtcl \
                core4_1_cii_range_2_k_cii_addr_size2_attr_user_hwtcl \
                core4_1_cii_range_2_k_cii_addr_size2_attr_user_hwtcl \
                core4_1_cii_range_2_k_cii_addr_size2_attr_hwtcl \
                core4_1_cii_range_3_k_cii_pf_en3_attr_user_hwtcl \
                core4_1_cii_range_3_k_cii_pf_en3_attr_hwtcl \
                core4_1_cii_range_3_k_cii_start_addr3_attr_user_hwtcl \
                core4_1_cii_range_3_k_cii_start_addr3_attr_hwtcl \
                core4_1_cii_range_3_k_cii_addr_size3_attr_user_hwtcl \
                core4_1_cii_range_3_k_cii_addr_size3_attr_user_hwtcl \
                core4_1_cii_range_3_k_cii_addr_size3_attr_hwtcl \
                core4_1_cii_range_4_k_cii_pf_en4_attr_user_hwtcl \
                core4_1_cii_range_4_k_cii_pf_en4_attr_hwtcl \
                core4_1_cii_range_4_k_cii_start_addr4_attr_user_hwtcl \
                core4_1_cii_range_4_k_cii_start_addr4_attr_hwtcl \
                core4_1_cii_range_4_k_cii_addr_size4_attr_user_hwtcl \
                core4_1_cii_range_4_k_cii_addr_size4_attr_user_hwtcl \
                core4_1_cii_range_4_k_cii_addr_size4_attr_hwtcl \
                core4_1_cii_range_5_k_cii_pf_en5_attr_user_hwtcl \
                core4_1_cii_range_5_k_cii_pf_en5_attr_hwtcl \
                core4_1_cii_range_5_k_cii_start_addr5_attr_user_hwtcl \
                core4_1_cii_range_5_k_cii_start_addr5_attr_hwtcl \
                core4_1_cii_range_5_k_cii_addr_size5_attr_user_hwtcl \
                core4_1_cii_range_5_k_cii_addr_size5_attr_user_hwtcl \
                core4_1_cii_range_5_k_cii_addr_size5_attr_hwtcl \
                core4_1_cii_range_6_k_cii_pf_en6_attr_user_hwtcl \
                core4_1_cii_range_6_k_cii_pf_en6_attr_hwtcl \
                core4_1_cii_range_6_k_cii_start_addr6_attr_user_hwtcl \
                core4_1_cii_range_6_k_cii_start_addr6_attr_hwtcl \
                core4_1_cii_range_6_k_cii_addr_size6_attr_user_hwtcl \
                core4_1_cii_range_6_k_cii_addr_size6_attr_user_hwtcl \
                core4_1_cii_range_6_k_cii_addr_size6_attr_hwtcl \
                core4_1_cii_range_7_k_cii_pf_en7_attr_user_hwtcl \
                core4_1_cii_range_7_k_cii_pf_en7_attr_hwtcl \
                core4_1_cii_range_7_k_cii_start_addr7_attr_user_hwtcl \
                core4_1_cii_range_7_k_cii_start_addr7_attr_hwtcl \
                core4_1_cii_range_7_k_cii_addr_size7_attr_user_hwtcl \
                core4_1_cii_range_7_k_cii_addr_size7_attr_user_hwtcl \
                core4_1_cii_range_7_k_cii_addr_size7_attr_hwtcl \
                core4_1_virtual_pf0_msix_enable_user_hwtcl \
                core4_1_virtual_pf1_msix_enable_user_hwtcl \
                core4_1_virtual_pf2_msix_enable_user_hwtcl \
                core4_1_virtual_pf3_msix_enable_user_hwtcl \
                core4_1_virtual_pf4_msix_enable_user_hwtcl \
                core4_1_virtual_pf5_msix_enable_user_hwtcl \
                core4_1_virtual_pf6_msix_enable_user_hwtcl \
                core4_1_virtual_pf7_msix_enable_user_hwtcl \
                core4_1_virtual_pf1_msix_enable_hwtcl \
                core4_1_virtual_pf2_msix_enable_hwtcl \
                core4_1_virtual_pf3_msix_enable_hwtcl \
                core4_1_virtual_pf4_msix_enable_hwtcl \
                core4_1_virtual_pf5_msix_enable_hwtcl \
                core4_1_virtual_pf6_msix_enable_hwtcl \
                core4_1_virtual_pf7_msix_enable_hwtcl \
                core4_1_pf1_pci_msix_table_size_hwtcl \
                core4_1_pf1_pci_msix_table_offset_hwtcl \
                core4_1_pf1_pci_msix_bir_hwtcl \
                core4_1_pf1_pci_msix_pba_offset_hwtcl \
                core4_1_pf1_pci_msix_pba_hwtcl \
                core4_1_pf1_pci_msix_table_size_vfcomm_cs2_hwtcl \
                core4_1_pf2_pci_msix_table_size_hwtcl \
                core4_1_pf2_pci_msix_table_offset_hwtcl \
                core4_1_pf2_pci_msix_bir_hwtcl \
                core4_1_pf2_pci_msix_pba_offset_hwtcl \
                core4_1_pf2_pci_msix_pba_hwtcl \
                core4_1_pf2_pci_msix_table_size_vfcomm_cs2_hwtcl \
                core4_1_pf3_pci_msix_table_size_hwtcl \
                core4_1_pf3_pci_msix_table_offset_hwtcl \
                core4_1_pf3_pci_msix_bir_hwtcl \
                core4_1_pf3_pci_msix_pba_offset_hwtcl \
                core4_1_pf3_pci_msix_pba_hwtcl \
                core4_1_pf3_pci_msix_table_size_vfcomm_cs2_hwtcl \
                core4_1_pf4_pci_msix_table_size_hwtcl \
                core4_1_pf4_pci_msix_table_offset_hwtcl \
                core4_1_pf4_pci_msix_bir_hwtcl \
                core4_1_pf4_pci_msix_pba_offset_hwtcl \
                core4_1_pf4_pci_msix_pba_hwtcl \
                core4_1_pf4_pci_msix_table_size_vfcomm_cs2_hwtcl \
                core4_1_pf5_pci_msix_table_size_hwtcl \
                core4_1_pf5_pci_msix_table_offset_hwtcl \
                core4_1_pf5_pci_msix_bir_hwtcl \
                core4_1_pf5_pci_msix_pba_offset_hwtcl \
                core4_1_pf5_pci_msix_pba_hwtcl \
                core4_1_pf5_pci_msix_table_size_vfcomm_cs2_hwtcl \
                core4_1_pf6_pci_msix_table_size_hwtcl \
                core4_1_pf6_pci_msix_table_offset_hwtcl \
                core4_1_pf6_pci_msix_bir_hwtcl \
                core4_1_pf6_pci_msix_pba_offset_hwtcl \
                core4_1_pf6_pci_msix_pba_hwtcl \
                core4_1_pf6_pci_msix_table_size_vfcomm_cs2_hwtcl \
                core4_1_pf7_pci_msix_table_size_hwtcl \
                core4_1_pf7_pci_msix_table_offset_hwtcl \
                core4_1_pf7_pci_msix_bir_hwtcl \
                core4_1_pf7_pci_msix_pba_offset_hwtcl \
                core4_1_pf7_pci_msix_pba_hwtcl \
                core4_1_pf7_pci_msix_table_size_vfcomm_cs2_hwtcl \
                core4_1_virtual_pf0_exvf_msix_cap_enable_hwtcl \
                core4_1_exvf_msix_tablesize_pf0 \
                core4_1_exvf_msixtable_offset_pf0 \
                core4_1_exvf_msixtable_bir_pf0 \
                core4_1_exvf_msixpba_offset_pf0 \
                core4_1_virtual_pf1_exvf_msix_cap_enable_hwtcl \
                core4_1_exvf_msix_tablesize_pf1 \
                core4_1_exvf_msixtable_offset_pf1 \
                core4_1_exvf_msixtable_bir_pf1 \
                core4_1_exvf_msixpba_offset_pf1 \
                core4_1_virtual_pf2_exvf_msix_cap_enable_hwtcl \
                core4_1_exvf_msix_tablesize_pf2 \
                core4_1_exvf_msixtable_offset_pf2 \
                core4_1_exvf_msixtable_bir_pf2 \
                core4_1_exvf_msixpba_offset_pf2 \
                core4_1_virtual_pf3_exvf_msix_cap_enable_hwtcl \
                core4_1_exvf_msix_tablesize_pf3 \
                core4_1_exvf_msixtable_offset_pf3 \
                core4_1_exvf_msixtable_bir_pf3 \
                core4_1_exvf_msixpba_offset_pf3 \
                core4_1_virtual_pf4_exvf_msix_cap_enable_hwtcl \
                core4_1_exvf_msix_tablesize_pf4 \
                core4_1_exvf_msixtable_offset_pf4 \
                core4_1_exvf_msixtable_bir_pf4 \
                core4_1_exvf_msixpba_offset_pf4 \
                core4_1_virtual_pf5_exvf_msix_cap_enable_hwtcl \
                core4_1_exvf_msix_tablesize_pf5 \
                core4_1_exvf_msixtable_offset_pf5 \
                core4_1_exvf_msixtable_bir_pf5 \
                core4_1_exvf_msixpba_offset_pf5 \
                core4_1_virtual_pf6_exvf_msix_cap_enable_hwtcl \
                core4_1_exvf_msix_tablesize_pf6 \
                core4_1_exvf_msixtable_offset_pf6 \
                core4_1_exvf_msixtable_bir_pf6 \
                core4_1_exvf_msixpba_offset_pf6 \
                core4_1_virtual_pf7_exvf_msix_cap_enable_hwtcl \
                core4_1_exvf_msix_tablesize_pf7 \
                core4_1_exvf_msixtable_offset_pf7 \
                core4_1_exvf_msixtable_bir_pf7 \
                core4_1_exvf_msixpba_offset_pf7 \
                core4_1_virtual_pf0_pasid_cap_enable_hwtcl \
                core4_1_pf0_pasid_cap_execute_permission_supported \
                core4_1_pf0_pasid_cap_privileged_mode_supported \
                core4_1_pf0_pasid_cap_max_pasid_width \
                core4_1_virtual_pf1_pasid_cap_enable_hwtcl \
                core4_1_pf1_pasid_cap_execute_permission_supported \
                core4_1_pf1_pasid_cap_privileged_mode_supported \
                core4_1_pf1_pasid_cap_max_pasid_width \
                core4_1_virtual_pf2_pasid_cap_enable_hwtcl \
                core4_1_pf2_pasid_cap_execute_permission_supported \
                core4_1_pf2_pasid_cap_privileged_mode_supported \
                core4_1_pf2_pasid_cap_max_pasid_width \
                core4_1_virtual_pf3_pasid_cap_enable_hwtcl \
                core4_1_pf3_pasid_cap_execute_permission_supported \
                core4_1_pf3_pasid_cap_privileged_mode_supported \
                core4_1_pf3_pasid_cap_max_pasid_width \
                core4_1_virtual_pf4_pasid_cap_enable_hwtcl \
                core4_1_pf4_pasid_cap_execute_permission_supported \
                core4_1_pf4_pasid_cap_privileged_mode_supported \
                core4_1_pf4_pasid_cap_max_pasid_width \
                core4_1_virtual_pf5_pasid_cap_enable_hwtcl \
                core4_1_pf5_pasid_cap_execute_permission_supported \
                core4_1_pf5_pasid_cap_privileged_mode_supported \
                core4_1_pf5_pasid_cap_max_pasid_width \
-               core4_1_virtual_pf6_pasid_cap_enable_hwtcl \
                core4_1_pf6_pasid_cap_execute_permission_supported \
                core4_1_pf6_pasid_cap_privileged_mode_supported \
                core4_1_pf6_pasid_cap_max_pasid_width \
                core4_1_virtual_pf7_pasid_cap_enable_hwtcl \
                core4_1_pf7_pasid_cap_execute_permission_supported \
                core4_1_pf7_pasid_cap_privileged_mode_supported \
                core4_1_pf7_pasid_cap_max_pasid_width \
                core4_1_virtual_pf1_prs_ext_cap_enable_hwtcl \
                core4_1_virtual_pf2_prs_ext_cap_enable_hwtcl \
                core4_1_virtual_pf3_prs_ext_cap_enable_hwtcl \
                core4_1_virtual_pf4_prs_ext_cap_enable_hwtcl \
                core4_1_virtual_pf5_prs_ext_cap_enable_hwtcl \
                core4_1_virtual_pf6_prs_ext_cap_enable_hwtcl \
                core4_1_virtual_pf7_prs_ext_cap_enable_hwtcl \
                core4_1_pf1_prs_outstanding_capacity_hwtcl \
                core4_1_pf2_prs_outstanding_capacity_hwtcl \
                core4_1_pf3_prs_outstanding_capacity_hwtcl \
                core4_1_pf4_prs_outstanding_capacity_hwtcl \
                core4_1_pf5_prs_outstanding_capacity_hwtcl \
                core4_1_pf6_prs_outstanding_capacity_hwtcl \
                core4_1_pf7_prs_outstanding_capacity_hwtcl \
                core4_1_virtual_pf1_acs_cap_enable_hwtcl \
                core4_1_virtual_pf2_acs_cap_enable_hwtcl \
                core4_1_virtual_pf3_acs_cap_enable_hwtcl \
                core4_1_virtual_pf4_acs_cap_enable_hwtcl \
                core4_1_virtual_pf5_acs_cap_enable_hwtcl \
                core4_1_virtual_pf6_acs_cap_enable_hwtcl \
                core4_1_virtual_pf7_acs_cap_enable_hwtcl \
                core4_1_pf1_acs_cap_acs_p2p_egress_control_hwtcl \
                core4_1_pf2_acs_cap_acs_p2p_egress_control_hwtcl \
                core4_1_pf3_acs_cap_acs_p2p_egress_control_hwtcl \
                core4_1_pf4_acs_cap_acs_p2p_egress_control_hwtcl \
                core4_1_pf5_acs_cap_acs_p2p_egress_control_hwtcl \
                core4_1_pf6_acs_cap_acs_p2p_egress_control_hwtcl \
                core4_1_pf7_acs_cap_acs_p2p_egress_control_hwtcl \
                core4_1_pf0_int_pin_hwtcl \
                core4_1_pf1_int_pin_hwtcl \
                core4_1_pf2_int_pin_hwtcl \
                core4_1_pf3_int_pin_hwtcl \
                core4_1_pf4_int_pin_hwtcl \
                core4_1_pf5_int_pin_hwtcl \
                core4_1_pf6_int_pin_hwtcl \
                core4_1_pf7_int_pin_hwtcl \
                core4_1_virtual_pf0_msi_enable_hwtcl \
                core4_1_virtual_pf1_msi_enable_hwtcl \
                core4_1_virtual_pf2_msi_enable_hwtcl \
                core4_1_virtual_pf3_msi_enable_hwtcl \
                core4_1_virtual_pf4_msi_enable_hwtcl \
                core4_1_virtual_pf5_msi_enable_hwtcl \
                core4_1_virtual_pf6_msi_enable_hwtcl \
                core4_1_virtual_pf7_msi_enable_hwtcl \
                core4_1_enable_msi_interface_hwtcl \
                core4_1_virtual_pf0_msi_enable_user_hwtcl \
                core4_1_virtual_pf1_msi_enable_user_hwtcl \
                core4_1_virtual_pf2_msi_enable_user_hwtcl \
                core4_1_virtual_pf3_msi_enable_user_hwtcl \
                core4_1_virtual_pf4_msi_enable_user_hwtcl \
                core4_1_virtual_pf5_msi_enable_user_hwtcl \
                core4_1_virtual_pf6_msi_enable_user_hwtcl \
                core4_1_virtual_pf7_msi_enable_user_hwtcl \
                core4_1_virtual_pf0_msi_64b_addressing_user_hwtcl \
                core4_1_virtual_pf1_msi_64b_addressing_user_hwtcl \
                core4_1_virtual_pf2_msi_64b_addressing_user_hwtcl \
                core4_1_virtual_pf3_msi_64b_addressing_user_hwtcl \
                core4_1_virtual_pf4_msi_64b_addressing_user_hwtcl \
                core4_1_virtual_pf5_msi_64b_addressing_user_hwtcl \
                core4_1_virtual_pf6_msi_64b_addressing_user_hwtcl \
                core4_1_virtual_pf7_msi_64b_addressing_user_hwtcl \
                core4_1_pf0_pci_msi_ext_data_cap_hwtcl \
                core4_1_pf1_pci_msi_ext_data_cap_hwtcl \
                core4_1_pf2_pci_msi_ext_data_cap_hwtcl \
                core4_1_pf3_pci_msi_ext_data_cap_hwtcl \
                core4_1_pf4_pci_msi_ext_data_cap_hwtcl \
                core4_1_pf5_pci_msi_ext_data_cap_hwtcl \
                core4_1_pf6_pci_msi_ext_data_cap_hwtcl \
                core4_1_pf7_pci_msi_ext_data_cap_hwtcl \
                core4_1_pf0_pci_msi_multiple_msg_cap_hwtcl \
                core4_1_pf1_pci_msi_multiple_msg_cap_hwtcl \
                core4_1_pf2_pci_msi_multiple_msg_cap_hwtcl \
                core4_1_pf3_pci_msi_multiple_msg_cap_hwtcl \
                core4_1_pf4_pci_msi_multiple_msg_cap_hwtcl \
                core4_1_pf5_pci_msi_multiple_msg_cap_hwtcl \
                core4_1_pf6_pci_msi_multiple_msg_cap_hwtcl \
                core4_1_pf7_pci_msi_multiple_msg_cap_hwtcl \
                core4_1_pf0_bar0_type_user_hwtcl \
                core4_1_pf0_bar0_address_width_user_hwtcl \
                core4_1_pf1_bar0_type_user_hwtcl \
                core4_1_pf2_bar0_type_user_hwtcl \
                core4_1_pf3_bar0_type_user_hwtcl \
                core4_1_pf1_bar0_address_width_user_hwtcl \
                core4_1_pf2_bar0_address_width_user_hwtcl \
                core4_1_pf3_bar0_address_width_user_hwtcl \
                core4_1_pf0_sriov_vf_bar0_type_user_hwtcl \
                core4_1_pf1_sriov_vf_bar0_type_user_hwtcl \
                core4_1_pf2_sriov_vf_bar0_type_user_hwtcl \
                core4_1_pf3_sriov_vf_bar0_type_user_hwtcl \
                core4_1_pf0_sriov_vf_bar0_type_hwtcl \
                core4_1_pf1_sriov_vf_bar0_type_hwtcl \
                core4_1_pf2_sriov_vf_bar0_type_hwtcl \
                core4_1_pf3_sriov_vf_bar0_type_hwtcl \
                core4_1_pf0_sriov_vf_bar0_address_width_hwtcl \
                core4_1_pf1_sriov_vf_bar0_address_width_hwtcl \
                core4_1_pf2_sriov_vf_bar0_address_width_hwtcl \
                core4_1_pf3_sriov_vf_bar0_address_width_hwtcl \
                core4_1_pf1_virtio_device_specific_cap_present_hwtcl \
                core4_1_pf2_virtio_device_specific_cap_present_hwtcl \
                core4_1_pf3_virtio_device_specific_cap_present_hwtcl \
                core4_1_pf0vf_virtio_device_specific_cap_present_hwtcl \
                core4_1_pf1vf_virtio_device_specific_cap_present_hwtcl \
                core4_1_pf2vf_virtio_device_specific_cap_present_hwtcl \
                core4_1_pf3vf_virtio_device_specific_cap_present_hwtcl \
                core4_1_exvf_msixpba_bir_pf0  \
                core4_1_exvf_msixpba_bir_pf1  \
                core4_1_exvf_msixpba_bir_pf2  \
                core4_1_exvf_msixpba_bir_pf3  \
            \
		core16_en_512s_to_1024s_adp_hwtcl \
		core16_en_512s_to_256s_adp_hwtcl \
		core16_en_256s_to_64s_adp_hwtcl \
		core16_en_256s_to_128s_adp_hwtcl \
		core16_en_256s_to_512s_adp_hwtcl \
		core16_en_128s_to_64s_adp_hwtcl \
		core16_en_128s_to_256e_adp_hwtcl \
		core16_en_128s_to_256s_adp_hwtcl \
	    \
		core8_en_256s_to_64s_adp_hwtcl \
		core8_en_256s_to_128s_adp_hwtcl \
		core8_en_256s_to_512s_adp_hwtcl \
		core8_en_128s_to_64s_adp_hwtcl \
		core8_en_128s_to_256e_adp_hwtcl \
		core8_en_128s_to_256s_adp_hwtcl \
	    \
		core4_0_en_128s_to_64s_adp_hwtcl \
		core4_0_en_128s_to_256e_adp_hwtcl \
		core4_0_en_128s_to_256s_adp_hwtcl \
	    \
		core4_1_en_128s_to_64s_adp_hwtcl \
		core4_1_en_128s_to_256e_adp_hwtcl \
		core4_1_en_128s_to_256s_adp_hwtcl \
	    \
            ]
            
            if {[regexp "R-TILE" $tile]} {
               dict set qhip_param core16_enable_cii_user_hwtcl                         [ dict get $qhip_param core16_enable_cii_hwtcl ]
               dict set qhip_param core8_enable_cii_user_hwtcl                          [ dict get $qhip_param core8_enable_cii_hwtcl ]
               dict set qhip_param core4_0_enable_cii_user_hwtcl                        [ dict get $qhip_param core4_0_enable_cii_hwtcl ]
               dict set qhip_param core4_1_enable_cii_user_hwtcl                        [ dict get $qhip_param core4_1_enable_cii_hwtcl ]

                # Remove R-tile parameters from dictionary
                foreach {param} $rtile_qhip_param {
                    dict unset qhip_param "$param"
                }

                foreach core [list "16" "8" "4_0" "4_1"] {
                    dict set qhip_param core${core}_virtual_ep_native_hwtcl             [ dict get $qhip_param  core${core}_virtual_ep_native_hwtcl_r  ]       
                    #dict set qhip_param core${core}_enable_power_mgnt_intf_hwtcl        [ dict get $qhip_param core${core}_enable_power_mgnt_intf_hwtcl_r  ]
                    #dict set qhip_param core${core}_enable_legacy_int_hwtcl             [ dict get $qhip_param core${core}_enable_legacy_int_hwtcl_r  ]
                    #dict set qhip_param core${core}_enable_cpl_timeout_hwtcl            [ dict get $qhip_param core${core}_enable_cpl_timeout_hwtcl_r ]
                    #dict set qhip_param core${core}_enable_prs_event_hwtcl              [ dict get $qhip_param core${core}_enable_prs_event_hwtcl_r ]
                    #dict set qhip_param core${core}_enable_pld_warm_rst_rdy_hwtcl       [ dict get $qhip_param core${core}_enable_pld_warm_rst_rdy_hwtcl_r ]
                    #dict set qhip_param core${core}_enable_cii_hwtcl                    [ dict get $qhip_param core${core}_enable_cii_hwtcl_r   ]
                    #dict set qhip_param core${core}_user_mode_to_pld_in_use_hwtcl       [ dict get $qhip_param core${core}_user_mode_to_pld_in_use_hwtcl_r ] 
                    dict set qhip_param core${core}_pf0_dsp_16g_tx_preset_hwtcl         [ dict get $qhip_param core${core}_pf0_dsp_16g_tx_preset_hwtcl_r ]
                    dict set qhip_param core${core}_pf0_dsp_tx_preset_hwtcl             [ dict get $qhip_param core${core}_pf0_dsp_tx_preset_hwtcl_r  ]
                    dict set qhip_param core${core}_pf0_usp_16g_tx_preset_hwtcl         [ dict get $qhip_param core${core}_pf0_usp_16g_tx_preset_hwtcl_r ]
                    dict set qhip_param core${core}_pf0_usp_tx_preset_hwtcl             [ dict get $qhip_param core${core}_pf0_usp_tx_preset_hwtcl_r ]
                    dict set qhip_param core${core}_virtual_pf0_prefetch_decode_hwtcl   [ dict get $qhip_param core${core}_virtual_pf0_prefetch_decode_hwtcl_r ]
                    #dict set qhip_param core${core}_enable_error_intf_hwtcl             [ dict get $qhip_param core${core}_enable_error_intf_hwtcl_r ]
                    dict set qhip_param core${core}_virtual_pf0_io_decode_hwtcl         [ dict get $qhip_param core${core}_virtual_pf0_io_decode_hwtcl_r ]
                    dict set qhip_param core${core}_virtual_num_of_lanes_hwtcl         [ dict get $qhip_param core${core}_virtual_num_of_lanes_hwtcl_r ]
                    

                    if {($core == "16")} {
                     #dict set qhip_param core${core}_pf0_sriov_vf_bar_type_hwtcl      [ dict get $qhip_param core${core}_pf0_sriov_vf_bar_type_hwtcl_r]
                     #dict set qhip_param core${core}_pf0_sriov_vf_bar_type_hwtcl      [ dict get $qhip_param core${core}_pf0_sriov_vf_bar_type_hwtcl]
                    
                    }

                    if {($core == "4_0") || ($core == "4_1") } {
                    dict set qhip_param core${core}_pf0_tph_req_cap_st_table_loc_1_hwtcl             [ dict get $qhip_param core${core}_pf0_tph_req_cap_st_table_loc_1_hwtcl_r ]
                    dict set qhip_param core${core}_pf0_ari_acs_fun_grp_cap_hwtcl                    [ dict get $qhip_param core${core}_pf0_ari_acs_fun_grp_cap_hwtcl_r ]
                    dict set qhip_param core${core}_pf0_tph_req_cap_st_table_loc_1_vfcomm_cs2_hwtcl       [ dict get $qhip_param core${core}_pf0_tph_req_cap_st_table_loc_1_vfcomm_cs2_hwtcl_r ]
                    dict set qhip_param core${core}_virtual_pf0_io_decode_hwtcl         [ dict get $qhip_param core${core}_virtual_pf0_io_decode_hwtcl_r ]
                    #dict set qhip_param core${core}_pf0_eq_redo_hwtcl         [ dict get $qhip_param core${core}_pf0_eq_redo_hwtcl_r ]
                    #dict set qhip_param core${core}_pf0_eq_redo_atg4_hwtcl         [ dict get $qhip_param core${core}_pf0_eq_redo_atg4_hwtcl_r ]
                    
                    }
                                       
                    if {($core == "16") || ($core == "8") } {
                      dict set qhip_param core${core}_pf0_ari_acs_fun_grp_cap_hwtcl       [ dict get $qhip_param core${core}_pf0_ari_acs_fun_grp_cap_hwtcl_r ]
                      
                     for {set i 0} {$i < 8} {incr i} {
                      
                      dict set qhip_param core${core}_pf${i}_sriov_sup_page_size_hwtcl     [ dict get $qhip_param core${core}_pf${i}_sriov_sup_page_size_hwtcl_r ]
                      dict set qhip_param core${core}_pf${i}_sriov_vf_bar0_type_hwtcl       [ dict get $qhip_param core${core}_pf${i}_sriov_vf_bar0_type_hwtcl_r ]
                      dict set qhip_param core${core}_pf${i}_sriov_vf_bar1_type_hwtcl       [ dict get $qhip_param core${core}_pf${i}_sriov_vf_bar1_type_hwtcl_r ]
                      dict set qhip_param core${core}_pf${i}_sriov_vf_bar2_type_hwtcl       [ dict get $qhip_param core${core}_pf${i}_sriov_vf_bar2_type_hwtcl_r ]
                      dict set qhip_param core${core}_pf${i}_sriov_vf_bar3_type_hwtcl       [ dict get $qhip_param core${core}_pf${i}_sriov_vf_bar3_type_hwtcl_r ]
                      dict set qhip_param core${core}_pf${i}_sriov_vf_bar4_type_hwtcl       [ dict get $qhip_param core${core}_pf${i}_sriov_vf_bar4_type_hwtcl_r ]
                      dict set qhip_param core${core}_pf${i}_sriov_vf_bar5_type_hwtcl       [ dict get $qhip_param core${core}_pf${i}_sriov_vf_bar5_type_hwtcl_r ]
                      dict set qhip_param core${core}_pf${i}_sriov_vf_bar0_type_integer_hwtcl [ dict get $qhip_param core${core}_pf${i}_sriov_vf_bar5_type_hwtcl_r ]
                      
  
                      dict set qhip_param core${core}_pf${i}_sriov_vf_bar1_type_integer_hwtcl  [ dict get $qhip_param core${core}_pf${i}_sriov_vf_bar1_type_integer_hwtcl_r ]

                      dict set qhip_param core${core}_pf${i}_sriov_vf_bar2_type_integer_hwtcl  [ dict get $qhip_param core${core}_pf${i}_sriov_vf_bar2_type_integer_hwtcl_r ]
                      dict set qhip_param core${core}_pf${i}_sriov_vf_bar3_type_integer_hwtcl  [ dict get $qhip_param core${core}_pf${i}_sriov_vf_bar3_type_integer_hwtcl_r ]

                      dict set qhip_param core${core}_pf${i}_sriov_vf_bar4_type_integer_hwtcl  [ dict get $qhip_param core${core}_pf${i}_sriov_vf_bar4_type_integer_hwtcl_r ]

                      dict set qhip_param core${core}_pf${i}_sriov_vf_bar5_type_integer_hwtcl  [ dict get $qhip_param core${core}_pf${i}_sriov_vf_bar5_type_integer_hwtcl_r ]

                     }                                                                
                   }                
                                    
                }
                foreach core [list "16" "8" "4_0" "4_1"] {
                    dict unset qhip_param core${core}_virtual_ep_native_hwtcl_r            
                    dict unset qhip_param core${core}_enable_power_mgnt_intf_hwtcl_r
                    dict unset qhip_param core${core}_enable_legacy_int_hwtcl_r
                    dict unset qhip_param core${core}_enable_cpl_timeout_hwtcl_r
                    dict unset qhip_param core${core}_enable_prs_event_hwtcl_r
                    dict unset qhip_param core${core}_enable_pld_warm_rst_rdy_hwtcl_r
                    dict unset qhip_param core${core}_enable_cii_hwtcl_r
                    dict unset qhip_param core${core}_user_mode_to_pld_in_use_hwtcl_r
                    dict unset qhip_param core${core}_pf0_dsp_16g_tx_preset_hwtcl_r 
                    dict unset qhip_param core${core}_pf0_dsp_tx_preset_hwtcl_r 
                    dict unset qhip_param core${core}_pf0_usp_16g_tx_preset_hwtcl_r 
                    dict unset qhip_param core${core}_pf0_usp_tx_preset_hwtcl_r 
                    dict unset qhip_param core${core}_pf0_ari_acs_fun_grp_cap_hwtcl_r 
                    dict unset qhip_param core${core}_virtual_pf0_prefetch_decode_hwtcl_r 
                    dict unset qhip_param core${core}_enable_error_intf_hwtcl_r 
                    dict unset qhip_param core${core}_pf0_tph_req_cap_st_table_loc_1_hwtcl_r
                    dict unset qhip_param core${core}_virtual_pf0_io_decode_hwtcl_r
                    dict unset qhip_param core${core}_virtual_num_of_lanes_hwtcl_r
                   

                    if {($core == "4_0") || ($core == "4_1") } {
                    dict unset qhip_param core${core}_pf0_tph_req_cap_st_table_loc_1_hwtcl_r
                    dict unset qhip_param core${core}_pf0_ari_acs_fun_grp_cap_hwtcl_r
                    dict unset qhip_param core${core}_pf0_tph_req_cap_st_table_loc_1_vfcomm_cs2_hwtcl_r
                    dict unset qhip_param core${core}_virtual_pf0_io_decode_hwtcl_r 
                    #dict unset qhip_param core${core}_pf0_eq_redo_hwtcl_r
                    #dict unset qhip_param core${core}_pf0_eq_redo_atg4_hwtcl_r 
                    
                    
                                        
                    }
                    if {($core == "16")} {
                     dict unset qhip_param core${core}_pf0_sriov_vf_bar_type_hwtcl_r 
                     dict unset qhip_param core${core}_pf0_sriov_vf_bar_type_hwtcl     
                     
                    }
 
                   if {($core == "16") || ($core == "8") } {
                      dict unset qhip_param core${core}_pf0_ari_acs_fun_grp_cap_hwtcl_r                                                  
                   
                     for {set i 0} {$i < 8} {incr i} {
                     
                      dict unset qhip_param core${core}_pf${i}_sriov_sup_page_size_hwtcl_r                                             
                      dict unset qhip_param core${core}_pf${i}_sriov_vf_bar0_type_hwtcl_r                       
                      dict unset qhip_param core${core}_pf${i}_sriov_vf_bar1_type_hwtcl_r                                             
                      dict unset qhip_param core${core}_pf${i}_sriov_vf_bar2_type_hwtcl_r                       
                      dict unset qhip_param core${core}_pf${i}_sriov_vf_bar3_type_hwtcl_r                       
                      dict unset qhip_param core${core}_pf${i}_sriov_vf_bar4_type_hwtcl_r                                              
                      dict unset qhip_param core${core}_pf${i}_sriov_vf_bar5_type_hwtcl_r 
                      dict unset qhip_param core${core}_pf${i}_sriov_vf_bar0_type_integer_hwtcl_r 
                      dict unset qhip_param core${core}_pf${i}_sriov_vf_bar1_type_integer_hwtcl_r 
                      dict unset qhip_param core${core}_pf${i}_sriov_vf_bar2_type_integer_hwtcl_r 
                      dict unset qhip_param core${core}_pf${i}_sriov_vf_bar3_type_integer_hwtcl_r 
                      dict unset qhip_param core${core}_pf${i}_sriov_vf_bar4_type_integer_hwtcl_r
                      dict unset qhip_param core${core}_pf${i}_sriov_vf_bar5_type_integer_hwtcl_r 
                     }
                 }                
               }

            } elseif {[regexp "P-TILE" $tile]} {
                # Remove F-tile parameters from dictionary
                foreach {param} $ftile_qhip_param {
                    dict unset qhip_param "$param"
                }
                     
                foreach core [list "16" "8" "4_0" "4_1"] {
                    dict unset   qhip_param core16_enable_cii_user_hwtcl
                    dict unset   qhip_param core${core}_fast_link_mode_hwtcl               
                    dict unset   qhip_param core${core}_virtual_cvp_mode_hwtcl
                    dict unset   qhip_param core${core}_virtual_ep_native_hwtcl_r
                    dict unset   qhip_param core${core}_enable_power_mgnt_intf_hwtcl_r
                    dict unset   qhip_param core${core}_enable_legacy_int_hwtcl_r 
                    #dict unset   qhip_param core${core}_rx_dsk_enable_hwtcl
                    dict unset   qhip_param core${core}_enable_cpl_timeout_hwtcl_r
                    dict unset   qhip_param core${core}_enable_prs_event_hwtcl_r
                    dict unset   qhip_param core${core}_enable_error_intf_hwtcl_r 
                    dict unset   qhip_param core${core}_enable_pld_warm_rst_rdy_hwtcl_r 
                    dict unset   qhip_param core${core}_enable_cii_hwtcl_r 
                    dict unset   qhip_param core${core}_user_mode_to_pld_in_use_hwtcl_r 
                    dict unset   qhip_param core${core}_dwc_ctrl0_k_pld_crs_en_hwtcl
                    dict unset   qhip_param core${core}_ecc_ctrl_k_nparity_ecc_attr_hwtcl
                    dict unset   qhip_param core${core}_ehp_ctrl0_header_format_hwtcl
                    dict unset   qhip_param core${core}_ehp_ctrl0_address_based_data_packing_hwtcl
                    dict unset   qhip_param core${core}_ehp_ctrl0_k_ehp_ctrl_hwtcl
                    dict unset   qhip_param core${core}_ehp_ctrl1_k_outstanding_crd_hwtcl 
                    dict unset   qhip_param core${core}_ehp_ctrl1_k_tx_rd_th_hwtcl
                    dict unset   qhip_param core${core}_csb_ctrl0_k_cfg_sys_serr_dis_attr_hwtcl
                    dict unset   qhip_param core${core}_csb_ctrl0_k_fixedcred_attr_hwtcl
                    dict unset   qhip_param core${core}_csb_ctrl0_k_mcred_attr_hwtcl
                    dict unset   qhip_param core${core}_csb_ctrl0_k_reloadcred_attr_hwtcl 
                    dict unset   qhip_param core${core}_csb_ctrl0_k_tlp_serr_dis_attr_hwtcl 
                    dict unset   qhip_param core${core}_csb_mmio_access_ctrl_grant_attr_hwtcl
                    dict unset   qhip_param core${core}_csb_opcode_ctrl_lock_attr_hwtcl
                    dict unset   qhip_param core${core}_pf0_usp_rx_preset0_hwtcl 
                    dict unset   qhip_param core${core}_pf0_usp_rx_preset_hwtcl 
                    dict unset   qhip_param core${core}_pf0_dsp_16g_tx_preset_hwtcl_r 
                    dict unset   qhip_param core${core}_pf0_dsp_tx_preset_hwtcl_r 
                    dict unset   qhip_param core${core}_pf0_usp_16g_tx_preset_hwtcl_r
                    dict unset   qhip_param core${core}_pf0_usp_tx_preset_hwtcl_r
                    dict unset   qhip_param core${core}_pf0_dsp_32g_tx_preset_hwtcl 
                    dict unset   qhip_param core${core}_tlb_err_en_k_cfg_bad_dllp_err_sts_en_hwtcl 
                    dict unset   qhip_param core${core}_tlb_err_en_k_cfg_bad_tlp_err_sts_en_hwtcl 
                    dict unset   qhip_param core${core}_tlb_err_en_k_cfg_corrected_internal_err_sts_en_hwtcl
                    dict unset   qhip_param core${core}_tlb_err_en_k_cfg_dl_protocol_err_sts_en_hwtcl 
                    dict unset   qhip_param core${core}_tlb_err_en_k_cfg_ecrc_err_sts_en_hwtcl
                    dict unset   qhip_param core${core}_tlb_err_en_k_cfg_fc_protocol_err_sts_en_hwtcl 
                    dict unset   qhip_param core${core}_tlb_err_en_k_cfg_mlf_tlp_err_sts_en_hwtcl
                    dict unset   qhip_param core${core}_tlb_err_en_k_cfg_rcvr_err_sts_en_hwtcl 
                    dict unset   qhip_param core${core}_tlb_err_en_k_cfg_rcvr_overflow_err_sts_en_hwtcl
                    dict unset   qhip_param core${core}_tlb_err_en_k_cfg_replay_number_rollover_err_sts_en_hwtcl
                    dict unset   qhip_param core${core}_tlb_err_en_k_cfg_replay_timer_timeout_err_sts_en_hwtcl 
                    dict unset   qhip_param core${core}_tlb_err_en_k_cfg_surprise_down_err_sts_en_hwtcl 
                    dict unset   qhip_param core${core}_tlb_err_en_k_cfg_uncor_internal_err_sts_en_hwtcl
                    dict unset   qhip_param core${core}_pfvf_sel_vsec_enable_hwtcl 
                    dict unset   qhip_param core${core}_pf0_bar3_reg_bar3_mem_io_hwtcl
                    dict unset   qhip_param core${core}_pf0_link_capabilities_reg_pcie_cap_surprise_down_err_rep_cap_hwtcl
                    dict unset   qhip_param core${core}_k_clrhip_not_rst_sticky_hwtcl  
                    dict unset   qhip_param core${core}_txempty_enable_hwtcl
                    dict unset   qhip_param core${core}_multi_lane_upconfigure_support_user_hwtcl  
                    dict unset   qhip_param core${core}_multi_lane_upconfigure_support_hwtcl 
                    dict unset   qhip_param core${core}_pf0_gen2_ctrl_off_support_mod_ts_hwtcl 
                    dict unset   qhip_param core${core}_pf0_gen2_ctrl_off_support_mod_ts_int_hwtcl 
                    dict unset   qhip_param core${core}_pf0_pcie_cap_auto_bw_int_en_hwtcl
                    dict unset   qhip_param core${core}_pf0_pcie_cap_bw_man_int_en_hwtcl
                    dict unset   qhip_param core${core}_virtual_l1sub_support_hwtcl 
                    dict unset   qhip_param core${core}_l1sub_control1_reg_l1_1_aspm_support_hwtcl 
                    dict unset   qhip_param core${core}_l1sub_control1_reg_l1_2_aspm_support_hwtcl
                    dict unset   qhip_param core${core}_l1sub_control1_reg_l1_1_pcipm_support_hwtcl
                    dict unset   qhip_param core${core}_l1sub_control1_reg_l1_2_pcipm_support_hwtcl 
                    dict unset   qhip_param core${core}_l1sub_control1_reg_l1_1_pcipm_en_hwtcl
                    dict unset   qhip_param core${core}_l1sub_control1_reg_l1_2_pcipm_en_hwtcl
                    dict unset   qhip_param core${core}_l1sub_control1_reg_l1_1_aspm_en_hwtcl
                    dict unset   qhip_param core${core}_l1sub_control1_reg_l1_2_aspm_en_hwtcl
                    dict unset   qhip_param core${core}_virtual_pf0_l1_1sub_cap_enable_hwtcl 
                    dict unset   qhip_param core${core}_virtual_pf0_l1_2sub_cap_enable_hwtcl 
                    dict unset   qhip_param core${core}_l1sub_off_t_pwer_off_hwtcl
                    dict unset   qhip_param core${core}_l1sub_off_l1sub_t_l1_2_hwtcl 
                    dict unset   qhip_param core${core}_l1sub_capability_reg_pwr_on_scale_support_hwtcl
                    dict unset   qhip_param core${core}_l1sub_capability_reg_pwr_on_value_support_hwtcl
                    dict unset   qhip_param core${core}_l1sub_capability_reg_comm_mode_support_hwtcl
                    dict unset   qhip_param core${core}_l1sub_control1_reg_t_common_mode_hwtcl
                    dict unset   qhip_param core${core}_l1sub_control1_reg_l1_2_th_sca_hwtcl
                    dict unset   qhip_param core${core}_l1sub_control1_reg_l1_2_th_val_hwtcl
                    dict unset   qhip_param core${core}_virtual_pf0_ltr_cap_enable_int_hwtcl
                    dict unset   qhip_param core${core}_virtual_dmwr_egress_blk_hwtcl 
                    dict unset   qhip_param core${core}_pf0_device_control3_reg_dev3_cap_dmwr_egress_blk_hwtcl
                    dict unset   qhip_param core${core}_sriov_misc_ctrl_k_nonsriov_mode_hwtcl 
                    dict unset   qhip_param core${core}_virtual_ptm_adj_lsb_hwtcl
                    dict unset   qhip_param core${core}_virtual_ptm_adj_msb_hwtcl
                    dict unset   qhip_param core${core}_pf0_ari_acs_fun_grp_cap_hwtcl_r
                    dict unset   qhip_param core${core}_virtual_pf0_prefetch_decode_hwtcl_r 
                    dict unset   qhip_param core${core}_pf0_gen4_eq_pset_req_vec_a0_user_hwtcl
                    dict unset   qhip_param core${core}_pf0_gen5_eq_pset_req_vec_a0_user_hwtcl
                    dict unset   qhip_param core${core}_pf0_gen3_eq_pset_req_vec_user_hwtcl 
                    dict unset   qhip_param core${core}_pf0_gen4_eq_pset_req_vec_user_hwtcl 
                    dict unset   qhip_param core${core}_pf0_gen5_eq_pset_req_vec_user_hwtcl 
                    dict unset   qhip_param core${core}_pf0_gen3_eq_pset_req_vec_hwtcl
                    dict unset   qhip_param core${core}_pf0_gen4_eq_pset_req_vec_hwtcl
                    dict unset   qhip_param core${core}_pf0_gen5_eq_pset_req_vec_hwtcl
                    dict unset   qhip_param core${core}_pf0_eq_redo_atg5_hwtcl
                    dict unset   qhip_param core${core}_pf0_eq_phase_2_3_user_hwtcl
                    dict unset   qhip_param core${core}_pf0_eq_phase_2_3_hwtcl
                    dict unset   qhip_param core${core}_pf0_eq_phase_2_3_atg5_hwtcl                   
                    dict unset   qhip_param core${core}_pf0_eq_phase_2_3_atg4_hwtcl  
                    dict unset   qhip_param core${core}_tx_precode_req_hwtcl
                    dict unset   qhip_param core${core}_virtual_num_of_lanes_hwtcl_r 
                    
                    for {set i 0} {$i < 8} {incr i} {
                    dict unset   qhip_param core${core}_pf${i}_aspm_control_hwtcl
                    #dict unset   qhip_param core${core}_virtual_pf${i}_bar1_mask_bit0_hwtcl
                    #dict unset   qhip_param core${core}_virtual_pf${i}_bar3_mask_bit0_hwtcl 
                    #dict unset   qhip_param core${core}_virtual_pf${i}_bar5_mask_bit0_hwtcl 
                    dict unset   qhip_param core${core}_pf${i}_pcie_cap_port_num_hwtcl
                    dict unset   qhip_param core${core}_pf${i}_device_control_device_status_pcie_cap_ext_tag_en_hwtcl
                    dict unset   qhip_param core${core}_pf${i}_device_control3_reg_dev3_cap_dmwr_egress_blk_hwtcl
                    dict unset   qhip_param core${core}_pf${i}_no_soft_rst_hwtcl 
                    dict unset   qhip_param core${core}_pf${i}_pci_type0_vendor_id_user_hwtcl
                    dict unset   qhip_param core${core}_pf${i}_revision_id_user_hwtcl
                    dict unset   qhip_param core${core}_pf${i}_eval_interval_time_hwtcl
                    #dict unset   qhip_param core${core}_pf${i}_virtio_pciconfig_access_cfg_data_hwtcl
                    
                                                                        
                  for {set j 0} {$j <6} {incr j} {
                    #dict unset   qhip_param core${core}_pf${i}_sriov_vf_bar${j}_type_hwtcl_r
                    #dict unset   qhip_param core${core}_pf${i}_sriov_vf_bar${j}_type_user_hwtcl 
                    #dict unset   qhip_param core${core}_pf${i}_sriov_vf_bar${j}_type_integer_hwtcl_r
                    #dict unset   qhip_param core${core}_pf${i}_bar${j}_mask_integer_hwtcl                    
                   }
                 }   
                          
                if {($core == "16") || ($core == "8") } {
                    dict unset   qhip_param core${core}_rx_dsk_enable_hwtcl
                    dict unset   qhip_param core${core}_virtio_cii_ctrl_k_cii_en_hwtcl 
                    dict unset   qhip_param core${core}_virtio_cii_ctrl_k_pfdata_vf_virtio_en_hwtcl
                    dict unset   qhip_param core${core}_virtio_cii_ctrl_k_cfg_update_en_attr_hwtcl
                    dict unset   qhip_param core${core}_cii_range_virtio_en_hwtcl
                    dict unset   qhip_param core${core}_cii_range_0_k_cii_pf_en0_attr_user_hwtcl 
                    dict unset   qhip_param core${core}_cii_range_0_k_cii_pf_en0_attr_hwtcl 
                    dict unset   qhip_param core${core}_cii_range_0_k_cii_start_addr0_attr_user_hwtcl
                    dict unset   qhip_param core${core}_cii_range_0_k_cii_start_addr0_attr_hwtcl
                    dict unset   qhip_param core${core}_cii_range_0_k_cii_addr_size0_attr_user_hwtcl 
                    dict unset   qhip_param core${core}_cii_range_0_k_cii_addr_size0_attr_hwtcl
                    dict unset   qhip_param core${core}_cii_range_1_k_cii_pf_en1_attr_user_hwtcl
                    dict unset   qhip_param core${core}_cii_range_1_k_cii_pf_en1_attr_hwtcl
                    dict unset   qhip_param core${core}_cii_range_1_k_cii_start_addr1_attr_user_hwtcl
                    dict unset   qhip_param core${core}_cii_range_1_k_cii_start_addr1_attr_hwtcl
                    dict unset   qhip_param core${core}_cii_range_1_k_cii_addr_size1_attr_user_hwtcl 
                    dict unset   qhip_param core${core}_cii_range_1_k_cii_addr_size1_attr_hwtcl 
                    dict unset   qhip_param core${core}_cii_range_2_k_cii_pf_en2_attr_user_hwtcl 
                    dict unset   qhip_param core${core}_cii_range_2_k_cii_pf_en2_attr_hwtcl 
                    dict unset   qhip_param core${core}_cii_range_2_k_cii_start_addr2_attr_user_hwtcl
                    dict unset   qhip_param core${core}_cii_range_2_k_cii_start_addr2_attr_hwtcl
                    dict unset   qhip_param core${core}_cii_range_2_k_cii_addr_size2_attr_user_hwtcl 
                    dict unset   qhip_param core${core}_cii_range_2_k_cii_addr_size2_attr_hwtcl
                    dict unset   qhip_param core${core}_cii_range_3_k_cii_pf_en3_attr_user_hwtcl
                    dict unset   qhip_param core${core}_cii_range_3_k_cii_pf_en3_attr_hwtcl
                    dict unset   qhip_param core${core}_cii_range_3_k_cii_start_addr3_attr_user_hwtcl
                    dict unset   qhip_param core${core}_cii_range_3_k_cii_start_addr3_attr_hwtcl
                    dict unset   qhip_param core${core}_cii_range_3_k_cii_addr_size3_attr_user_hwtcl 
                    dict unset   qhip_param core${core}_cii_range_3_k_cii_addr_size3_attr_hwtcl 
                    dict unset   qhip_param core${core}_cii_range_4_k_cii_pf_en4_attr_user_hwtcl 
                    dict unset   qhip_param core${core}_cii_range_4_k_cii_pf_en4_attr_hwtcl 
                    dict unset   qhip_param core${core}_cii_range_4_k_cii_start_addr4_attr_user_hwtcl
                    dict unset   qhip_param core${core}_cii_range_4_k_cii_start_addr4_attr_hwtcl
                    dict unset   qhip_param core${core}_cii_range_4_k_cii_addr_size4_attr_user_hwtcl 
                    dict unset   qhip_param core${core}_cii_range_4_k_cii_addr_size4_attr_hwtcl
                    dict unset   qhip_param core${core}_cii_range_5_k_cii_pf_en5_attr_user_hwtcl
                    dict unset   qhip_param core${core}_cii_range_5_k_cii_pf_en5_attr_hwtcl
                    dict unset   qhip_param core${core}_cii_range_5_k_cii_start_addr5_attr_user_hwtcl
                    dict unset   qhip_param core${core}_cii_range_5_k_cii_start_addr5_attr_hwtcl
                    dict unset   qhip_param core${core}_cii_range_5_k_cii_addr_size5_attr_user_hwtcl 
                    dict unset   qhip_param core${core}_cii_range_5_k_cii_addr_size5_attr_hwtcl 
                    dict unset   qhip_param core${core}_cii_range_6_k_cii_pf_en6_attr_user_hwtcl 
                    dict unset   qhip_param core${core}_cii_range_6_k_cii_pf_en6_attr_hwtcl 
                    dict unset   qhip_param core${core}_cii_range_6_k_cii_start_addr6_attr_user_hwtcl
                    dict unset   qhip_param core${core}_cii_range_6_k_cii_start_addr6_attr_hwtcl
                    dict unset   qhip_param core${core}_cii_range_6_k_cii_addr_size6_attr_user_hwtcl 
                    dict unset   qhip_param core${core}_cii_range_6_k_cii_addr_size6_attr_hwtcl
                    dict unset   qhip_param core${core}_cii_range_7_k_cii_pf_en7_attr_user_hwtcl
                    dict unset   qhip_param core${core}_cii_range_7_k_cii_pf_en7_attr_hwtcl
                    dict unset   qhip_param core${core}_cii_range_7_k_cii_start_addr7_attr_user_hwtcl
                    dict unset   qhip_param core${core}_cii_range_7_k_cii_start_addr7_attr_hwtcl
                    dict unset   qhip_param core${core}_cii_range_7_k_cii_addr_size7_attr_user_hwtcl 
                    dict unset   qhip_param core${core}_cii_range_7_k_cii_addr_size7_attr_hwtcl 
                    dict unset qhip_param core${core}_virtual_pf0_io_decode_hwtcl_r
                    
                   for {set i 0} {$i < 8} {incr i} {
                    dict unset   qhip_param core${core}_pf${i}_sriov_sup_page_size_hwtcl_r  
                    dict unset   qhip_param core${core}_virtual_pf${i}_bar1_mask_bit0_hwtcl
                    dict unset   qhip_param core${core}_virtual_pf${i}_bar3_mask_bit0_hwtcl 
                    dict unset   qhip_param core${core}_virtual_pf${i}_bar5_mask_bit0_hwtcl 
                    dict unset   qhip_param core${core}_pf${i}_virtio_pciconfig_access_cfg_data_hwtcl
                   for {set j 0} {$j <6} {incr j} {
                    dict unset   qhip_param core${core}_pf${i}_sriov_vf_bar${j}_type_hwtcl_r
                    dict unset   qhip_param core${core}_pf${i}_sriov_vf_bar${j}_type_user_hwtcl 
                    dict unset   qhip_param core${core}_pf${i}_sriov_vf_bar${j}_type_integer_hwtcl_r
                    dict unset   qhip_param core${core}_pf${i}_bar${j}_mask_integer_hwtcl  
                   }
                   } 

                    
                    
                    
                }
                if {($core == "16")} {
                     dict unset qhip_param core${core}_pf0_sriov_vf_bar_type_hwtcl_r     
                     dict unset qhip_param core${core}_pf0_sriov_vf_bar_type_hwtcl    
                    
                }

                if {($core == "8")} {
                     dict unset qhip_param core${core}_pf0_eq_redo_hwtcl_r                                     
                     dict unset qhip_param core${core}_pf0_eq_redo_atg4_hwtcl_r
                     dict unset qhip_param core${core}_pf0_eq_redo_hwtcl
                     dict unset qhip_param core${core}_pf0_eq_redo_atg4_hwtcl
                     
                }

                if {($core == "8") ||($core == "4_0") || ($core =="4_1") } {                  
                     dict unset qhip_param core${core}_virtual_num_of_lanes_16_hwtcl 
                }
                if {($core == "4_0") || ($core == "4_1") } {                  
                     dict unset qhip_param core${core}_virtual_pf0_io_decode_hwtcl_r
                     dict unset qhip_param core${core}_pf0_tph_req_cap_st_table_loc_1_vfcomm_cs2_hwtcl_r
                     dict unset qhip_param core${core}_pf0_tph_req_cap_st_table_loc_1_hwtcl_r
                     dict unset qhip_param core${core}_virtual_pf0_ltr_cap_enable_hwtcl 
                     dict unset qhip_param core${core}_virtual_ptm_hwtcl 
                     dict unset qhip_param core${core}_cfg_ptm_auto_update_period_hwtcl
                     dict unset qhip_param core${core}_virtual_ptm_autoupdate_hwtcl 
                     dict unset qhip_param core${core}_virtual_pf1_user_vsec_cap_enable_hwtcl
                     dict unset qhip_param core${core}_virtual_pf2_user_vsec_cap_enable_hwtcl 
                     dict unset qhip_param core${core}_virtual_pf3_user_vsec_cap_enable_hwtcl
                     dict unset qhip_param core${core}_virtual_pf4_user_vsec_cap_enable_hwtcl 
                     dict unset qhip_param core${core}_virtual_pf5_user_vsec_cap_enable_hwtcl 
                     dict unset qhip_param core${core}_virtual_pf6_user_vsec_cap_enable_hwtcl 
                     dict unset qhip_param core${core}_virtual_pf7_user_vsec_cap_enable_hwtcl
                     dict unset qhip_param core${core}_virtual_num_of_lanes_8_hwtcl 
                     dict unset qhip_param core${core}_pf0_eq_redo_hwtcl_r
                     dict unset qhip_param core${core}_pf0_eq_redo_atg4_hwtcl_r
                     dict unset qhip_param core${core}_pf0_eq_redo_hwtcl
                     dict unset qhip_param core${core}_pf0_eq_redo_atg4_hwtcl
                     
                     
                     
                     
                     
                }

                }


            } elseif {[regexp "F-TILE" $tile]} {
                # Remove P-tile parameters from dictionary
		set top_topology_hwtcl [ip_get "parameter.top_topology_hwtcl.value"]
		set core16_virtual_rp_ep_mode_hwtcl [ip_get "parameter.core16_virtual_rp_ep_mode_hwtcl.value"]
                foreach {param} $ptile_qhip_param {
		    if {[regexp "2x4" $top_topology_hwtcl] && [regexp "Native Endpoint" $core16_virtual_rp_ep_mode_hwtcl] } {
		    	if {[regexp "core4_0_pf0_bar0_address_width_user_hwtcl" $param]} {
				continue;
			}
			if {[regexp "core4_0_pf0_bar0_type_user_hwtcl" $param]} {
				continue;
			}
			if {[regexp "core4_0_virtual_pf0_pasid_cap_enable_hwtcl" $param]} {
				continue;
			}
			if {[regexp "core4_0_virtual_pf0_msix_enable_user_hwtcl" $param]} {
				continue;
			}
		    }
                    dict unset qhip_param "$param"
                }
                if {[regexp "2x4" $top_topology_hwtcl] && [regexp "Native Endpoint" $core16_virtual_rp_ep_mode_hwtcl] } {

                    dict unset qhip_param "core4_0_pf0_bar1_type_user_hwtcl"
                    dict unset qhip_param "core4_0_pf0_bar1_address_width_user_hwtcl"
                    dict unset qhip_param "core4_0_pf0_bar1_type_hwtcl"
                    dict unset qhip_param "core4_0_pf0_bar1_type_integer_hwtcl"
                    dict unset qhip_param "core4_0_pf0_bar1_address_width_hwtcl"
                    dict unset qhip_param "core4_0_pf0_bar2_type_user_hwtcl"
                    dict unset qhip_param "core4_0_pf0_bar2_address_width_user_hwtcl"
                    dict unset qhip_param "core4_0_pf0_bar2_type_hwtcl"
                    dict unset qhip_param "core4_0_pf0_bar2_type_integer_hwtcl"
                    dict unset qhip_param "core4_0_pf0_bar2_address_width_hwtcl"
                    dict unset qhip_param "core4_0_pf0_bar3_type_user_hwtcl"
                    dict unset qhip_param "core4_0_pf0_bar3_address_width_user_hwtcl"
                    dict unset qhip_param "core4_0_pf0_bar3_type_hwtcl"
                    dict unset qhip_param "core4_0_pf0_bar3_type_integer_hwtcl"
                    dict unset qhip_param "core4_0_pf0_bar3_address_width_hwtcl"
                    dict unset qhip_param "core4_0_pf0_bar4_type_user_hwtcl"
                    dict unset qhip_param "core4_0_pf0_bar4_address_width_user_hwtcl"
                    dict unset qhip_param "core4_0_pf0_bar4_type_hwtcl"
                    dict unset qhip_param "core4_0_pf0_bar4_type_integer_hwtcl"
                    dict unset qhip_param "core4_0_pf0_bar4_address_width_hwtcl"
                    dict unset qhip_param "core4_0_pf0_bar5_type_user_hwtcl"
                    dict unset qhip_param "core4_0_pf0_bar5_address_width_user_hwtcl"
                    dict unset qhip_param "core4_0_pf0_bar5_type_hwtcl"
                    dict unset qhip_param "core4_0_pf0_bar5_type_integer_hwtcl"
                    dict unset qhip_param "core4_0_pf0_bar5_address_width_hwtcl"
                    dict unset qhip_param "core4_0_pf0_rom_bar_mask_integer_hwtcl"
                    dict unset qhip_param "core4_0_pf0_bar0_mask_integer_hwtcl"
                    dict unset qhip_param "core4_0_pf0_bar1_mask_integer_hwtcl"
                    dict unset qhip_param "core4_0_pf0_bar2_mask_integer_hwtcl"
                    dict unset qhip_param "core4_0_pf0_bar3_mask_integer_hwtcl"
                    dict unset qhip_param "core4_0_pf0_bar4_mask_integer_hwtcl"
                    dict unset qhip_param "core4_0_pf0_bar5_mask_integer_hwtcl"
                    dict unset qhip_param "core4_0_virtual_pf0_bar1_mask_bit0_hwtcl"
                    dict unset qhip_param "core4_0_virtual_pf0_bar3_mask_bit0_hwtcl"
                    dict unset qhip_param "core4_0_virtual_pf0_bar5_mask_bit0_hwtcl"
                }

                dict unset qhip_param rtile_debug_toolkit_hwtcl
                dict unset qhip_param rtile_enable_pciess_register_access_hwtcl

                     
                foreach core [list "16" "8" "4_0" "4_1"] {
                    dict unset   qhip_param core16_enable_cii_user_hwtcl
                    dict unset   qhip_param core${core}_fast_link_mode_hwtcl               
                    dict unset   qhip_param core${core}_virtual_cvp_mode_hwtcl
                    dict unset   qhip_param core${core}_virtual_ep_native_hwtcl_r
                    dict unset   qhip_param core${core}_enable_power_mgnt_intf_hwtcl_r
                    dict unset   qhip_param core${core}_enable_legacy_int_hwtcl_r 
                    #dict unset   qhip_param core${core}_rx_dsk_enable_hwtcl
                    dict unset   qhip_param core${core}_enable_cpl_timeout_hwtcl_r
                    dict unset   qhip_param core${core}_enable_prs_event_hwtcl_r
                    dict unset   qhip_param core${core}_enable_error_intf_hwtcl_r 
                    dict unset   qhip_param core${core}_enable_pld_warm_rst_rdy_hwtcl_r 
                    dict unset   qhip_param core${core}_enable_cii_hwtcl_r 
                    dict unset   qhip_param core${core}_user_mode_to_pld_in_use_hwtcl_r 
                    dict unset   qhip_param core${core}_dwc_ctrl0_k_pld_crs_en_hwtcl
                    dict unset   qhip_param core${core}_ecc_ctrl_k_nparity_ecc_attr_hwtcl
                    dict unset   qhip_param core${core}_ehp_ctrl0_header_format_hwtcl
                    dict unset   qhip_param core${core}_ehp_ctrl0_address_based_data_packing_hwtcl
                    dict unset   qhip_param core${core}_ehp_ctrl0_k_ehp_ctrl_hwtcl
                    dict unset   qhip_param core${core}_ehp_ctrl1_k_outstanding_crd_hwtcl 
                    dict unset   qhip_param core${core}_ehp_ctrl1_k_tx_rd_th_hwtcl
                    dict unset   qhip_param core${core}_csb_ctrl0_k_cfg_sys_serr_dis_attr_hwtcl
                    dict unset   qhip_param core${core}_csb_ctrl0_k_fixedcred_attr_hwtcl
                    dict unset   qhip_param core${core}_csb_ctrl0_k_mcred_attr_hwtcl
                    dict unset   qhip_param core${core}_csb_ctrl0_k_reloadcred_attr_hwtcl 
                    dict unset   qhip_param core${core}_csb_ctrl0_k_tlp_serr_dis_attr_hwtcl 
                    dict unset   qhip_param core${core}_csb_mmio_access_ctrl_grant_attr_hwtcl
                    dict unset   qhip_param core${core}_csb_opcode_ctrl_lock_attr_hwtcl
                    dict unset   qhip_param core${core}_pf0_usp_rx_preset0_hwtcl 
                    dict unset   qhip_param core${core}_pf0_usp_rx_preset_hwtcl 
                    dict unset   qhip_param core${core}_pf0_dsp_16g_tx_preset_hwtcl_r 
                    dict unset   qhip_param core${core}_pf0_dsp_tx_preset_hwtcl_r 
                    dict unset   qhip_param core${core}_pf0_usp_16g_tx_preset_hwtcl_r
                    dict unset   qhip_param core${core}_pf0_usp_tx_preset_hwtcl_r
                    dict unset   qhip_param core${core}_pf0_dsp_32g_tx_preset_hwtcl 
                    dict unset   qhip_param core${core}_tlb_err_en_k_cfg_bad_dllp_err_sts_en_hwtcl 
                    dict unset   qhip_param core${core}_tlb_err_en_k_cfg_bad_tlp_err_sts_en_hwtcl 
                    dict unset   qhip_param core${core}_tlb_err_en_k_cfg_corrected_internal_err_sts_en_hwtcl
                    dict unset   qhip_param core${core}_tlb_err_en_k_cfg_dl_protocol_err_sts_en_hwtcl 
                    dict unset   qhip_param core${core}_tlb_err_en_k_cfg_ecrc_err_sts_en_hwtcl
                    dict unset   qhip_param core${core}_tlb_err_en_k_cfg_fc_protocol_err_sts_en_hwtcl 
                    dict unset   qhip_param core${core}_tlb_err_en_k_cfg_mlf_tlp_err_sts_en_hwtcl
                    dict unset   qhip_param core${core}_tlb_err_en_k_cfg_rcvr_err_sts_en_hwtcl 
                    dict unset   qhip_param core${core}_tlb_err_en_k_cfg_rcvr_overflow_err_sts_en_hwtcl
                    dict unset   qhip_param core${core}_tlb_err_en_k_cfg_replay_number_rollover_err_sts_en_hwtcl
                    dict unset   qhip_param core${core}_tlb_err_en_k_cfg_replay_timer_timeout_err_sts_en_hwtcl 
                    dict unset   qhip_param core${core}_tlb_err_en_k_cfg_surprise_down_err_sts_en_hwtcl 
                    dict unset   qhip_param core${core}_tlb_err_en_k_cfg_uncor_internal_err_sts_en_hwtcl
                    dict unset   qhip_param core${core}_pfvf_sel_vsec_enable_hwtcl 
                    dict unset   qhip_param core${core}_pf0_bar3_reg_bar3_mem_io_hwtcl
                    dict unset   qhip_param core${core}_pf0_link_capabilities_reg_pcie_cap_surprise_down_err_rep_cap_hwtcl
                    dict unset   qhip_param core${core}_k_clrhip_not_rst_sticky_hwtcl  
                    dict unset   qhip_param core${core}_txempty_enable_hwtcl
                    dict unset   qhip_param core${core}_multi_lane_upconfigure_support_user_hwtcl  
                    dict unset   qhip_param core${core}_multi_lane_upconfigure_support_hwtcl 
                    dict unset   qhip_param core${core}_pf0_gen2_ctrl_off_support_mod_ts_hwtcl 
                    dict unset   qhip_param core${core}_pf0_gen2_ctrl_off_support_mod_ts_int_hwtcl 
                    dict unset   qhip_param core${core}_pf0_pcie_cap_auto_bw_int_en_hwtcl
                    dict unset   qhip_param core${core}_pf0_pcie_cap_bw_man_int_en_hwtcl
                    dict unset   qhip_param core${core}_virtual_l1sub_support_hwtcl 
                    dict unset   qhip_param core${core}_l1sub_control1_reg_l1_1_aspm_support_hwtcl 
                    dict unset   qhip_param core${core}_l1sub_control1_reg_l1_2_aspm_support_hwtcl
                    dict unset   qhip_param core${core}_l1sub_control1_reg_l1_1_pcipm_support_hwtcl
                    dict unset   qhip_param core${core}_l1sub_control1_reg_l1_2_pcipm_support_hwtcl 
                    dict unset   qhip_param core${core}_l1sub_control1_reg_l1_1_pcipm_en_hwtcl
                    dict unset   qhip_param core${core}_l1sub_control1_reg_l1_2_pcipm_en_hwtcl
                    dict unset   qhip_param core${core}_l1sub_control1_reg_l1_1_aspm_en_hwtcl
                    dict unset   qhip_param core${core}_l1sub_control1_reg_l1_2_aspm_en_hwtcl
                    dict unset   qhip_param core${core}_virtual_pf0_l1_1sub_cap_enable_hwtcl 
                    dict unset   qhip_param core${core}_virtual_pf0_l1_2sub_cap_enable_hwtcl 
                    dict unset   qhip_param core${core}_l1sub_off_t_pwer_off_hwtcl
                    dict unset   qhip_param core${core}_l1sub_off_l1sub_t_l1_2_hwtcl 
                    dict unset   qhip_param core${core}_l1sub_capability_reg_pwr_on_scale_support_hwtcl
                    dict unset   qhip_param core${core}_l1sub_capability_reg_pwr_on_value_support_hwtcl
                    dict unset   qhip_param core${core}_l1sub_capability_reg_comm_mode_support_hwtcl
                    dict unset   qhip_param core${core}_l1sub_control1_reg_t_common_mode_hwtcl
                    dict unset   qhip_param core${core}_l1sub_control1_reg_l1_2_th_sca_hwtcl
                    dict unset   qhip_param core${core}_l1sub_control1_reg_l1_2_th_val_hwtcl
                    dict unset   qhip_param core${core}_virtual_pf0_ltr_cap_enable_int_hwtcl
                    dict unset   qhip_param core${core}_virtual_dmwr_egress_blk_hwtcl 
                    dict unset   qhip_param core${core}_pf0_device_control3_reg_dev3_cap_dmwr_egress_blk_hwtcl
                    dict unset   qhip_param core${core}_sriov_misc_ctrl_k_nonsriov_mode_hwtcl 
                    dict unset   qhip_param core${core}_virtual_ptm_adj_lsb_hwtcl
                    dict unset   qhip_param core${core}_virtual_ptm_adj_msb_hwtcl
                    dict unset   qhip_param core${core}_pf0_ari_acs_fun_grp_cap_hwtcl_r
                    dict unset   qhip_param core${core}_virtual_pf0_prefetch_decode_hwtcl_r 
                    dict unset   qhip_param core${core}_pf0_gen4_eq_pset_req_vec_a0_user_hwtcl
                    dict unset   qhip_param core${core}_pf0_gen5_eq_pset_req_vec_a0_user_hwtcl
                    dict unset   qhip_param core${core}_pf0_gen3_eq_pset_req_vec_user_hwtcl 
                    dict unset   qhip_param core${core}_pf0_gen4_eq_pset_req_vec_user_hwtcl 
                    dict unset   qhip_param core${core}_pf0_gen5_eq_pset_req_vec_user_hwtcl 
                    dict unset   qhip_param core${core}_pf0_gen3_eq_pset_req_vec_hwtcl
                    dict unset   qhip_param core${core}_pf0_gen4_eq_pset_req_vec_hwtcl
                    dict unset   qhip_param core${core}_pf0_gen5_eq_pset_req_vec_hwtcl
                    dict unset   qhip_param core${core}_pf0_eq_redo_atg5_hwtcl
                    dict unset   qhip_param core${core}_pf0_eq_phase_2_3_user_hwtcl
                    dict unset   qhip_param core${core}_pf0_eq_phase_2_3_hwtcl
                    dict unset   qhip_param core${core}_pf0_eq_phase_2_3_atg5_hwtcl                   
                    dict unset   qhip_param core${core}_pf0_eq_phase_2_3_atg4_hwtcl  
                    dict unset   qhip_param core${core}_tx_precode_req_hwtcl
                    dict unset   qhip_param core${core}_virtual_num_of_lanes_hwtcl_r 
                    
                    for {set i 0} {$i < 8} {incr i} {
                    dict unset   qhip_param core${core}_pf${i}_aspm_control_hwtcl
                    #dict unset   qhip_param core${core}_virtual_pf${i}_bar1_mask_bit0_hwtcl
                    #dict unset   qhip_param core${core}_virtual_pf${i}_bar3_mask_bit0_hwtcl 
                    #dict unset   qhip_param core${core}_virtual_pf${i}_bar5_mask_bit0_hwtcl 
                    dict unset   qhip_param core${core}_pf${i}_pcie_cap_port_num_hwtcl
                    dict unset   qhip_param core${core}_pf${i}_device_control_device_status_pcie_cap_ext_tag_en_hwtcl
                    dict unset   qhip_param core${core}_pf${i}_device_control3_reg_dev3_cap_dmwr_egress_blk_hwtcl
                    dict unset   qhip_param core${core}_pf${i}_no_soft_rst_hwtcl 
                    dict unset   qhip_param core${core}_pf${i}_pci_type0_vendor_id_user_hwtcl
                    dict unset   qhip_param core${core}_pf${i}_revision_id_user_hwtcl
                    dict unset   qhip_param core${core}_pf${i}_eval_interval_time_hwtcl
                    #dict unset   qhip_param core${core}_pf${i}_virtio_pciconfig_access_cfg_data_hwtcl
                    
                                                                        
                  for {set j 0} {$j <6} {incr j} {
                    #dict unset   qhip_param core${core}_pf${i}_sriov_vf_bar${j}_type_hwtcl_r
                    #dict unset   qhip_param core${core}_pf${i}_sriov_vf_bar${j}_type_user_hwtcl 
                    #dict unset   qhip_param core${core}_pf${i}_sriov_vf_bar${j}_type_integer_hwtcl_r
                    #dict unset   qhip_param core${core}_pf${i}_bar${j}_mask_integer_hwtcl                    
                   }
                 }   
                          
                if {($core == "16") || ($core == "8") } {
                    dict unset   qhip_param core${core}_rx_dsk_enable_hwtcl
                    dict unset   qhip_param core${core}_virtio_cii_ctrl_k_cii_en_hwtcl 
                    dict unset   qhip_param core${core}_virtio_cii_ctrl_k_pfdata_vf_virtio_en_hwtcl
                    dict unset   qhip_param core${core}_virtio_cii_ctrl_k_cfg_update_en_attr_hwtcl
                    dict unset   qhip_param core${core}_cii_range_virtio_en_hwtcl
                    dict unset   qhip_param core${core}_cii_range_0_k_cii_pf_en0_attr_user_hwtcl 
                    dict unset   qhip_param core${core}_cii_range_0_k_cii_pf_en0_attr_hwtcl 
                    dict unset   qhip_param core${core}_cii_range_0_k_cii_start_addr0_attr_user_hwtcl
                    dict unset   qhip_param core${core}_cii_range_0_k_cii_start_addr0_attr_hwtcl
                    dict unset   qhip_param core${core}_cii_range_0_k_cii_addr_size0_attr_user_hwtcl 
                    dict unset   qhip_param core${core}_cii_range_0_k_cii_addr_size0_attr_hwtcl
                    dict unset   qhip_param core${core}_cii_range_1_k_cii_pf_en1_attr_user_hwtcl
                    dict unset   qhip_param core${core}_cii_range_1_k_cii_pf_en1_attr_hwtcl
                    dict unset   qhip_param core${core}_cii_range_1_k_cii_start_addr1_attr_user_hwtcl
                    dict unset   qhip_param core${core}_cii_range_1_k_cii_start_addr1_attr_hwtcl
                    dict unset   qhip_param core${core}_cii_range_1_k_cii_addr_size1_attr_user_hwtcl 
                    dict unset   qhip_param core${core}_cii_range_1_k_cii_addr_size1_attr_hwtcl 
                    dict unset   qhip_param core${core}_cii_range_2_k_cii_pf_en2_attr_user_hwtcl 
                    dict unset   qhip_param core${core}_cii_range_2_k_cii_pf_en2_attr_hwtcl 
                    dict unset   qhip_param core${core}_cii_range_2_k_cii_start_addr2_attr_user_hwtcl
                    dict unset   qhip_param core${core}_cii_range_2_k_cii_start_addr2_attr_hwtcl
                    dict unset   qhip_param core${core}_cii_range_2_k_cii_addr_size2_attr_user_hwtcl 
                    dict unset   qhip_param core${core}_cii_range_2_k_cii_addr_size2_attr_hwtcl
                    dict unset   qhip_param core${core}_cii_range_3_k_cii_pf_en3_attr_user_hwtcl
                    dict unset   qhip_param core${core}_cii_range_3_k_cii_pf_en3_attr_hwtcl
                    dict unset   qhip_param core${core}_cii_range_3_k_cii_start_addr3_attr_user_hwtcl
                    dict unset   qhip_param core${core}_cii_range_3_k_cii_start_addr3_attr_hwtcl
                    dict unset   qhip_param core${core}_cii_range_3_k_cii_addr_size3_attr_user_hwtcl 
                    dict unset   qhip_param core${core}_cii_range_3_k_cii_addr_size3_attr_hwtcl 
                    dict unset   qhip_param core${core}_cii_range_4_k_cii_pf_en4_attr_user_hwtcl 
                    dict unset   qhip_param core${core}_cii_range_4_k_cii_pf_en4_attr_hwtcl 
                    dict unset   qhip_param core${core}_cii_range_4_k_cii_start_addr4_attr_user_hwtcl
                    dict unset   qhip_param core${core}_cii_range_4_k_cii_start_addr4_attr_hwtcl
                    dict unset   qhip_param core${core}_cii_range_4_k_cii_addr_size4_attr_user_hwtcl 
                    dict unset   qhip_param core${core}_cii_range_4_k_cii_addr_size4_attr_hwtcl
                    dict unset   qhip_param core${core}_cii_range_5_k_cii_pf_en5_attr_user_hwtcl
                    dict unset   qhip_param core${core}_cii_range_5_k_cii_pf_en5_attr_hwtcl
                    dict unset   qhip_param core${core}_cii_range_5_k_cii_start_addr5_attr_user_hwtcl
                    dict unset   qhip_param core${core}_cii_range_5_k_cii_start_addr5_attr_hwtcl
                    dict unset   qhip_param core${core}_cii_range_5_k_cii_addr_size5_attr_user_hwtcl 
                    dict unset   qhip_param core${core}_cii_range_5_k_cii_addr_size5_attr_hwtcl 
                    dict unset   qhip_param core${core}_cii_range_6_k_cii_pf_en6_attr_user_hwtcl 
                    dict unset   qhip_param core${core}_cii_range_6_k_cii_pf_en6_attr_hwtcl 
                    dict unset   qhip_param core${core}_cii_range_6_k_cii_start_addr6_attr_user_hwtcl
                    dict unset   qhip_param core${core}_cii_range_6_k_cii_start_addr6_attr_hwtcl
                    dict unset   qhip_param core${core}_cii_range_6_k_cii_addr_size6_attr_user_hwtcl 
                    dict unset   qhip_param core${core}_cii_range_6_k_cii_addr_size6_attr_hwtcl
                    dict unset   qhip_param core${core}_cii_range_7_k_cii_pf_en7_attr_user_hwtcl
                    dict unset   qhip_param core${core}_cii_range_7_k_cii_pf_en7_attr_hwtcl
                    dict unset   qhip_param core${core}_cii_range_7_k_cii_start_addr7_attr_user_hwtcl
                    dict unset   qhip_param core${core}_cii_range_7_k_cii_start_addr7_attr_hwtcl
                    dict unset   qhip_param core${core}_cii_range_7_k_cii_addr_size7_attr_user_hwtcl 
                    dict unset   qhip_param core${core}_cii_range_7_k_cii_addr_size7_attr_hwtcl 
                    dict unset   qhip_param core${core}_virtual_pf0_io_decode_hwtcl_r

                   for {set i 0} {$i < 8} {incr i} {
                    dict unset   qhip_param core${core}_pf${i}_sriov_sup_page_size_hwtcl_r  
                    dict unset   qhip_param core${core}_virtual_pf${i}_bar1_mask_bit0_hwtcl
                    dict unset   qhip_param core${core}_virtual_pf${i}_bar3_mask_bit0_hwtcl 
                    dict unset   qhip_param core${core}_virtual_pf${i}_bar5_mask_bit0_hwtcl 
                    dict unset   qhip_param core${core}_pf${i}_virtio_pciconfig_access_cfg_data_hwtcl
                   for {set j 0} {$j <6} {incr j} {
                    dict unset   qhip_param core${core}_pf${i}_sriov_vf_bar${j}_type_hwtcl_r
                    dict unset   qhip_param core${core}_pf${i}_sriov_vf_bar${j}_type_user_hwtcl 
                    dict unset   qhip_param core${core}_pf${i}_sriov_vf_bar${j}_type_integer_hwtcl_r
                    dict unset   qhip_param core${core}_pf${i}_bar${j}_mask_integer_hwtcl  
                   }
                   } 

                    
                                       
                }
                if {($core == "16") ||($core =="8")} {
                for {set i 0} {$i < 8} {incr i} {
                     dict unset qhip_param core${core}_pf${i}_ats_capabilities_ctrl_reg_page_aligned_req_hwtcl      
                }     
               }
               if {($core == "16")} {
                     dict unset qhip_param core${core}_pf0_sriov_vf_bar_type_hwtcl_r     
                     dict unset qhip_param core${core}_pf0_sriov_vf_bar_type_hwtcl    
                    
                }

              #if {($core == "4_0")} {
                     #dict unset qhip_param core${core}_pf0_tph_req_cap_st_table_loc_1_vfcomm_cs2_hwtcl    
                      
                #}
      
               if {($core == "8") ||($core == "4_0") || ($core =="4_1") } {                  
                     dict unset qhip_param core${core}_virtual_num_of_lanes_16_hwtcl 
                }
                if {($core == "4_0") || ($core == "4_1") } {                  
                     dict unset qhip_param core${core}_virtual_pf0_io_decode_hwtcl_r
                     dict unset qhip_param core${core}_pf0_tph_req_cap_st_table_loc_1_vfcomm_cs2_hwtcl_r
                     dict unset qhip_param core${core}_pf0_tph_req_cap_st_table_loc_1_hwtcl_r
                     dict unset qhip_param core4_1_virtual_pf0_ltr_cap_enable_hwtcl 
                     dict unset qhip_param core${core}_virtual_ptm_hwtcl 
                     dict unset qhip_param core${core}_cfg_ptm_auto_update_period_hwtcl
                     dict unset qhip_param core${core}_virtual_ptm_autoupdate_hwtcl 
                     dict unset qhip_param core${core}_virtual_pf1_user_vsec_cap_enable_hwtcl
                     dict unset qhip_param core${core}_virtual_pf2_user_vsec_cap_enable_hwtcl 
                     dict unset qhip_param core${core}_virtual_pf3_user_vsec_cap_enable_hwtcl
                     dict unset qhip_param core${core}_virtual_pf4_user_vsec_cap_enable_hwtcl 
                     dict unset qhip_param core${core}_virtual_pf5_user_vsec_cap_enable_hwtcl 
                     dict unset qhip_param core${core}_virtual_pf6_user_vsec_cap_enable_hwtcl 
                     dict unset qhip_param core${core}_virtual_pf7_user_vsec_cap_enable_hwtcl
                     dict unset qhip_param core${core}_virtual_num_of_lanes_8_hwtcl 
                     
                     
                     
                }

                }

                # Replace newly added param (appended with _f) due to differences in DERIVED and DEFAULT_VALUE with their original name in QHIP param
                foreach core [list "16" "8" "4_0" "4_1"] {
                    dict set qhip_param core${core}_virtual_txeq_mode_hwtcl [ dict get $qhip_param core${core}_virtual_txeq_mode_hwtcl_f]
                    dict set qhip_param core${core}_pf0_gen3_eq_pset_req_vec_hwtcl [ dict get $qhip_param core${core}_pf0_gen3_eq_pset_req_vec_hwtcl_f]
                    dict set qhip_param core${core}_pf0_gen3_eq_pset_req_vec_atg4_hwtcl [ dict get $qhip_param core${core}_pf0_gen3_eq_pset_req_vec_atg4_hwtcl_f]
                    dict set qhip_param core${core}_virtual_num_of_lanes_hwtcl [ dict get $qhip_param core${core}_virtual_num_of_lanes_hwtcl_f]
                    dict set qhip_param core${core}_pf0_eq_redo_hwtcl [ dict get $qhip_param core${core}_pf0_eq_redo_hwtcl_f]
                    dict set qhip_param core${core}_pf0_eq_redo_atg4_hwtcl [ dict get $qhip_param core${core}_pf0_eq_redo_atg4_hwtcl_f]
                    dict set qhip_param core${core}_pf0_dsp_16g_tx_preset_hwtcl [ dict get $qhip_param core${core}_pf0_dsp_16g_tx_preset_hwtcl_f]
                    dict set qhip_param core${core}_pf0_dsp_tx_preset_hwtcl [ dict get $qhip_param core${core}_pf0_dsp_tx_preset_hwtcl_f]
                    dict set qhip_param core${core}_pf0_usp_16g_tx_preset_hwtcl [ dict get $qhip_param core${core}_pf0_usp_16g_tx_preset_hwtcl_f]
                    dict set qhip_param core${core}_pf0_usp_tx_preset_hwtcl [ dict get $qhip_param core${core}_pf0_usp_tx_preset_hwtcl_f]
                    dict set qhip_param core${core}_virtual_pf0_io_decode_hwtcl [ dict get $qhip_param core${core}_virtual_pf0_io_decode_hwtcl_f]
		    dict set qhip_param core${core}_virtual_pf0_prefetch_decode_hwtcl [dict get $qhip_param core${core}_virtual_pf0_prefetch_decode_hwtcl_f]

                    # Only core4_0 and core4_1 has duplicated rom_bar param and tph_req param
                    if {($core == "4_0") || ($core == "4_1") } {
                        dict set qhip_param core${core}_pf0_rom_bar_enabled_hwtcl [ dict get $qhip_param core${core}_pf0_rom_bar_enabled_hwtcl_f]
                        dict set qhip_param core${core}_pf0_tph_req_cap_st_table_loc_1_hwtcl [ dict get $qhip_param core${core}_pf0_tph_req_cap_st_table_loc_1_hwtcl_f]
                    }

                    dict set qhip_param core${core}_pf0_rp_rom_bar_enabled_hwtcl [ dict get $qhip_param core${core}_pf0_rp_rom_bar_enabled_hwtcl_f]
                    dict set qhip_param core${core}_pf0_pcie_cap_sel_deemphasis_hwtcl [ dict get $qhip_param core${core}_pf0_pcie_cap_sel_deemphasis_hwtcl_f]
                    dict set qhip_param core${core}_pf0_acs_cap_acs_egress_ctrl_size_hwtcl [ dict get $qhip_param core${core}_pf0_acs_cap_acs_egress_ctrl_size_hwtcl_f]
                    # Only core16 and core8 has pf1-7
                    if {($core == "16") || ($core == "8") } {
                        for {set i 1} {$i < 8} {incr i} {
                             dict set qhip_param core${core}_pf${i}_acs_cap_acs_egress_ctrl_size_hwtcl [ dict get $qhip_param core${core}_pf${i}_acs_cap_acs_egress_ctrl_size_hwtcl_f]
                        }
                    }
                    # Only core8 core4_0 and core4_1 has duplicated class_code param
                    if {($core == "8") || ($core == "4_0") || ($core == "4_1") } {
                        if {($core == "4_0") || ($core == "4_1") } {
                            dict set qhip_param core${core}_pf0_class_code_hwtcl [ dict get $qhip_param core${core}_pf0_class_code_hwtcl]
                        } else {
                            for {set i 0} {$i < 8} {incr i} {
                                dict set qhip_param core${core}_pf${i}_class_code_hwtcl [ dict get $qhip_param core${core}_pf${i}_class_code_hwtcl]
                            }
                        }
                    }
                }
            }

            # Remove the newly added param with _f appended
            foreach core [list "16" "8" "4_0" "4_1"] {
                dict unset qhip_param core${core}_virtual_txeq_mode_hwtcl_f
                dict unset qhip_param core${core}_pf0_gen3_eq_pset_req_vec_hwtcl_f 
                dict unset qhip_param core${core}_pf0_gen3_eq_pset_req_vec_atg4_hwtcl_f 
                dict unset qhip_param core${core}_virtual_num_of_lanes_hwtcl_f
                dict unset qhip_param core${core}_pf0_eq_redo_hwtcl_f
                dict unset qhip_param core${core}_pf0_eq_redo_atg4_hwtcl_f
                dict unset qhip_param core${core}_pf0_dsp_16g_tx_preset_hwtcl_f
                dict unset qhip_param core${core}_pf0_dsp_tx_preset_hwtcl_f
                dict unset qhip_param core${core}_pf0_usp_16g_tx_preset_hwtcl_f
                dict unset qhip_param core${core}_pf0_usp_tx_preset_hwtcl_f
                dict unset qhip_param core${core}_virtual_pf0_io_decode_hwtcl_f
                dict unset qhip_param core${core}_pf0_rom_bar_enabled_hwtcl_f
                dict unset qhip_param core${core}_pf0_rp_rom_bar_enabled_hwtcl_f
                dict unset qhip_param core${core}_pf0_pcie_cap_sel_deemphasis_hwtcl_f
                dict unset qhip_param core${core}_pf0_acs_cap_acs_egress_ctrl_size_hwtcl_f
                dict unset qhip_param core${core}_pf0_tph_req_cap_st_table_loc_1_hwtcl_f
	        dict unset qhip_param core${core}_virtual_pf0_prefetch_decode_hwtcl_f

                # Only core16 and core8 has pf1-7
                if {($core == "16") || ($core == "8") } {
                    for {set i 1} {$i < 8} {incr i} {
                         dict unset qhip_param core${core}_pf${i}_acs_cap_acs_egress_ctrl_size_hwtcl_f
                    }
                }
                # Only core8 core4_0 and core4_1 has duplicated class_code param
                #if {($core == "8") || ($core == "4_0") || ($core == "4_1") } {
                #    if {($core == "4_0") || ($core == "4_1") } {
                #        dict unset qhip_param core${core}_pf0_class_code_hwtcl_f
                #    }
                #    for {set i 0} {$i < 8} {incr i} {
                #         dict unset qhip_param core${core}_pf${i}_class_code_hwtcl_f
                #    }
                #}
            }
        }

        proc ::intel_pcie_ss_axi::fileset::callback_example_design { output_name } {
           ::intel_pcie_ss_axi::dynamic_example_design
        }
}

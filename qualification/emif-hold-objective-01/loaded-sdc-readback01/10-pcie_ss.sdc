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


if [info exists pcie_ss_inst] {
  unset pcie_ss_inst
  }
set pcie_ss_inst [get_current_instance]
puts "PCIE SS SDC INSTANCE: $pcie_ss_inst"


set pcie_sdc_debug 0

proc pcie_port_existence {port_name} {
   upvar 1 pcie_sdc_debug pcie_sdc_debug

   set port_collection [get_ports -nowarn $port_name]

   if {$pcie_sdc_debug} {
        post_message -type info "Port exists for $port_name : $port_collection"
	foreach_in_collection port $port_collection {
	   set detected_port_name [get_port_info -name $port]
           post_message -type info "Ports found for $port_name : $detected_port_name"
	}
   }

   if { [get_collection_size $port_collection] > 0 } {
      return 1
   } else {
      return 0
   }
}

proc pcie_clk_existence {clk_name} {
   upvar 1 pcie_sdc_debug pcie_sdc_debug

   set clk_collection [get_clocks -nowarn $clk_name]

   if {$pcie_sdc_debug} {
        post_message -type info "Clock exists for $clk_name : $clk_collection"
	foreach_in_collection clk $clk_collection {
	   set detected_clk_name [get_clock_info -name $clk]
           post_message -type info "Clock found for $clk_name : $detected_clk_name"
	}
   }

   if { [get_collection_size $clk_collection] > 0 } {
      return 1
   } else {
      return 0
   }
}

proc pcie_get_clock_target_list {} {
   upvar 1 pcie_sdc_debug pcie_sdc_debug

   set result [list]
   set clocks_collection [get_clocks -nowarn]
   foreach_in_collection clock $clocks_collection { 
      if { ![is_clock_defined $clock] } {
         continue
      }
      set clock_name       [get_clock_info -name $clock] 
      set clock_target_col [get_clock_info -targets $clock]
      lappend result       [query_collection -report -all $clock_target_col]
      if {$pcie_sdc_debug} { post_message -type info "clock_name : $clock_name" }
   }
   if {$pcie_sdc_debug} { post_message -type info "PCIe clock_target list: $result" }

   return $result
}

set FAMILY              "Agilex 7"
set top_topology        "Gen4 1x16" 
set virtual_rp_ep_mode  "Native Endpoint" 
set debug_toolkit_en    0
set TILE                "P-TILE"
set pcie_ss_func_mode   "Power User"

set core16_st_clk_freq          500
set core16_lite_clk_freq        100

set CORE_16_ST_CLK_PERIOD       [format %.3f [expr {double(1000.0/$core16_st_clk_freq)}   ] ]
set CORE_16_MM_CLK_PERIOD       [format %.3f [expr {double(1000.0/$core16_st_clk_freq)}   ] ]
set CORE_16_LITE_CLK_PERIOD     [format %.3f [expr {double(1000.0/$core16_lite_clk_freq)} ] ]

if {[regexp "2x8" $top_topology] || [regexp "4x4" $top_topology] || [regexp "1x4" $top_topology]} {
  set core8_st_clk_freq           
  set core8_lite_clk_freq         250

  set CORE_8_ST_CLK_PERIOD        [format %.3f [expr {double(1000.0/$core8_st_clk_freq)}   ] ]
  set CORE_8_MM_CLK_PERIOD        [format %.3f [expr {double(1000.0/$core8_st_clk_freq)}   ] ]
  set CORE_8_LITE_CLK_PERIOD      [format %.3f [expr {double(1000.0/$core8_lite_clk_freq)} ] ]

}

if {[regexp "x4" $top_topology]} {
  if {[regexp "4x4" $top_topology] || [regexp "1x4" $top_topology]} {
    set core4_0_st_clk_freq         
    set core4_1_st_clk_freq         
    set core4_0_lite_clk_freq       250
    set core4_1_lite_clk_freq       250

    set CORE_4_0_ST_CLK_PERIOD      [format %.3f [expr {double(1000.0/$core4_0_st_clk_freq)}   ] ]
    set CORE_4_1_ST_CLK_PERIOD      [format %.3f [expr {double(1000.0/$core4_1_st_clk_freq)}   ] ]
    set CORE_4_0_MM_CLK_PERIOD      [format %.3f [expr {double(1000.0/$core4_0_st_clk_freq)}   ] ]
    set CORE_4_1_MM_CLK_PERIOD      [format %.3f [expr {double(1000.0/$core4_1_st_clk_freq)}   ] ]
    set CORE_4_0_LITE_CLK_PERIOD    [format %.3f [expr {double(1000.0/$core4_0_lite_clk_freq)} ] ]
    set CORE_4_1_LITE_CLK_PERIOD    [format %.3f [expr {double(1000.0/$core4_1_lite_clk_freq)} ] ]

  } elseif {[regexp "2x4" $top_topology]} {
    set core4_0_st_clk_freq         
    set core4_0_lite_clk_freq       250

    set CORE_4_0_ST_CLK_PERIOD      [format %.3f [expr {double(1000.0/$core4_0_st_clk_freq)}   ] ]
    set CORE_4_0_MM_CLK_PERIOD      [format %.3f [expr {double(1000.0/$core4_0_st_clk_freq)}   ] ]
    set CORE_4_0_LITE_CLK_PERIOD    [format %.3f [expr {double(1000.0/$core4_0_lite_clk_freq)} ] ]
  
  }
}


set REFCLK_PERIOD           10.0
set pcie_clock_target_list  [pcie_get_clock_target_list]
set pcie_refclk0_port_ext   [pcie_port_existence refclk0]
set pcie_refclk0_lsrc       [lsearch -exact $pcie_clock_target_list refclk0]

if {$pcie_refclk0_port_ext && $pcie_refclk0_lsrc == -1} {
    create_clock -name refclk0          -period $REFCLK_PERIOD   [get_ports refclk0]
}

set pcie_refclk1_port_ext  [pcie_port_existence refclk1]
set pcie_refclk1_lsrc [lsearch -exact $pcie_clock_target_list refclk1]
if {$pcie_refclk1_port_ext && $pcie_refclk1_lsrc == -1} {
    create_clock -name refclk1          -period $REFCLK_PERIOD   [get_ports refclk1]
}

set pcie_axi_st_clk_port_ext  [pcie_port_existence p*_axi_st_clk]
set pcie_axi_st_clk_lsrc [lsearch -exact $pcie_clock_target_list p*_axi_st_clk]
if {$pcie_axi_st_clk_port_ext && $pcie_axi_st_clk_lsrc == -1} {

    create_clock -name p0_axi_st_clk    -period $CORE_16_ST_CLK_PERIOD   [get_ports p0_axi_st_clk]
    if {[regexp "2x8" $top_topology] || [regexp "x4" $top_topology]} {
        create_clock -name p1_axi_st_clk    -period $CORE_8_ST_CLK_PERIOD   [get_ports p1_axi_st_clk]
    }
    if {[regexp "x4" $top_topology]} {
        create_clock -name p2_axi_st_clk    -period $CORE_4_0_ST_CLK_PERIOD   [get_ports p2_axi_st_clk]
        create_clock -name p3_axi_st_clk    -period $CORE_4_1_ST_CLK_PERIOD   [get_ports p3_axi_st_clk]
    }
}

set pcie_axi_lite_clk_port_ext  [pcie_port_existence p*_axi_lite_clk]
set pcie_axi_lite_clk_lsrc [lsearch -exact $pcie_clock_target_list p*_axi_lite_clk]
if {$pcie_axi_lite_clk_port_ext && $pcie_axi_lite_clk_lsrc == -1} {
    create_clock -name p0_axi_lite_clk  -period $CORE_16_LITE_CLK_PERIOD [get_ports p0_axi_lite_clk]
    if {[regexp "2x8" $top_topology] || [regexp "x4" $top_topology]} {
        create_clock -name p1_axi_lite_clk  -period $CORE_8_LITE_CLK_PERIOD [get_ports p1_axi_lite_clk]
    }
    if {[regexp "x4" $top_topology]} {
        create_clock -name p2_axi_lite_clk  -period $CORE_4_0_LITE_CLK_PERIOD [get_ports p2_axi_lite_clk]
        create_clock -name p3_axi_lite_clk  -period $CORE_4_1_LITE_CLK_PERIOD [get_ports p3_axi_lite_clk]
    }
}

set pcie_axi_mm_clk_port_ext  [pcie_port_existence p*_axi_mm_clk]
set pcie_axi_mm_clk_lsrc [lsearch -exact $pcie_clock_target_list p*_axi_mm_clk]
if {$pcie_axi_mm_clk_port_ext && $pcie_axi_mm_clk_lsrc == -1} {
    create_clock -name p0_axi_mm_clk    -period $CORE_16_MM_CLK_PERIOD   [get_ports p0_axi_mm_clk]
    if {[regexp "2x8" $top_topology] || [regexp "x4" $top_topology]} {
        create_clock -name p1_axi_mm_clk    -period $CORE_8_MM_CLK_PERIOD   [get_ports p1_axi_mm_clk]
    }
    if {[regexp "x4" $top_topology]} {
        create_clock -name p2_axi_mm_clk    -period $CORE_4_0_MM_CLK_PERIOD   [get_ports p2_axi_mm_clk]
        create_clock -name p3_axi_mm_clk    -period $CORE_4_1_MM_CLK_PERIOD   [get_ports p3_axi_mm_clk]
    }
}

set pcie_axi_lite_clk_ext  [pcie_clk_existence p*_axi_lite_clk]
if {$pcie_axi_lite_clk_port_ext} {
   if {$TILE == "F-TILE" || $TILE == "P-TILE"} {
      if {[regexp "Native Endpoint" $virtual_rp_ep_mode]} {
         create_generated_clock -name avmm_clock0 -source p0_axi_lite_clk -master_clock p0_axi_lite_clk -divide_by 2 \
                 ${pcie_ss_inst}|EP_PFTILE_WRAPPER.gen_pciess.u_pciess_p0|u_pciess|gen_sub.u_hipif|u_pciess_clock_divider|clkdiv_inst|clock_div2 -add
         if {[regexp "2x8" $top_topology] || [regexp "x4" $top_topology]} {
                 create_generated_clock -name avmm_clock1 -source p1_axi_lite_clk -master_clock p1_axi_lite_clk -divide_by 2 \
                         ${pcie_ss_inst}|EP_PFTILE_WRAPPER.gen_pciess_p1.u_pciess_p1|u_pciess|gen_sub.u_hipif|u_pciess_clock_divider|clkdiv_inst|clock_div2 -add
         }
         if {[regexp "x4" $top_topology]} {
                 create_generated_clock -name avmm_clock2 -source p2_axi_lite_clk -master_clock p2_axi_lite_clk -divide_by 2 \
                         ${pcie_ss_inst}|EP_PFTILE_WRAPPER.gen_pciess_p2_p3.u_pciess_p2|u_pciess|gen_sub.u_hipif|u_pciess_clock_divider|clkdiv_inst|clock_div2 -add
                 create_generated_clock -name avmm_clock3 -source p3_axi_lite_clk -master_clock p3_axi_lite_clk -divide_by 2 \
                         ${pcie_ss_inst}|EP_PFTILE_WRAPPER.gen_pciess_p2_p3.u_pciess_p3|u_pciess|gen_sub.u_hipif|u_pciess_clock_divider|clkdiv_inst|clock_div2 -add
         }
      } else {  
         create_generated_clock -name avmm_clock0 -source p0_axi_lite_clk -master_clock p0_axi_lite_clk -divide_by 2 \
                 ${pcie_ss_inst}|RP_PFTILE_WRAPPER.gen_pciess_rp.u_pciess_rp_p0|u_pciess|gen_sub.u_hipif|u_pciess_clock_divider|clkdiv_inst|clock_div2 -add
         if {[regexp "2x8" $top_topology] || [regexp "x4" $top_topology]} {
                 create_generated_clock -name avmm_clock1 -source p1_axi_lite_clk -master_clock p1_axi_lite_clk -divide_by 2 \
                         ${pcie_ss_inst}|RP_PFTILE_WRAPPER.gen_pciess_rp_p1.u_pciess_rp_p1|u_pciess|gen_sub.u_hipif|u_pciess_clock_divider|clkdiv_inst|clock_div2 -add
         }
         if {[regexp "x4" $top_topology]} {
                 create_generated_clock -name avmm_clock2 -source p2_axi_lite_clk -master_clock p2_axi_lite_clk -divide_by 2 \
                         ${pcie_ss_inst}|RP_PFTILE_WRAPPER.gen_pciess_rp_p2_p3.u_pciess_rp_p2|u_pciess|gen_sub.u_hipif|u_pciess_clock_divider|clkdiv_inst|clock_div2 -add
                 create_generated_clock -name avmm_clock3 -source p3_axi_lite_clk -master_clock p3_axi_lite_clk -divide_by 2 \
                         ${pcie_ss_inst}|RP_PFTILE_WRAPPER.gen_pciess_rp_p2_p3.u_pciess_rp_p3|u_pciess|gen_sub.u_hipif|u_pciess_clock_divider|clkdiv_inst|clock_div2 -add
         }
      }

      set_clock_groups -asynchronous -group {avmm_clock0} -group {p0_axi_lite_clk}
      
      if {[regexp "2x8" $top_topology] || [regexp "x4" $top_topology]} {
      	set_clock_groups -asynchronous -group {avmm_clock1} -group {p1_axi_lite_clk}
      }
      if {[regexp "x4" $top_topology]} {
      	set_clock_groups -asynchronous -group {avmm_clock2} -group {p2_axi_lite_clk}
      	set_clock_groups -asynchronous -group {avmm_clock3} -group {p3_axi_lite_clk}
      }
      
   }
}


set pcie_axi_st_clk_ext  [pcie_clk_existence p*_axi_st_clk]
if {$debug_toolkit_en} {

        if {$TILE == "P-TILE"} {
            set_clock_groups -asynchronous -group [get_clocks {xcvr_reconfig_clk}] -group ${pcie_ss_inst}|gen_ptile.u_ptile|intel_pcie_ptile_ast_qhip|inst|inst|maib_and_tile|xcvr_hip_native|rx_ch15
        } elseif {$TILE == "F-TILE"} {
            if {[regexp "Native Endpoint" $virtual_rp_ep_mode]} {
 	       set_clock_groups -asynchronous -group [get_clocks {xcvr_reconfig_clk}] -group ${pcie_ss_inst}|gen_ftile.gen_u_ftile.u_ftile|intel_pcie_ftile_ast_qhip|rx_clkout|ch5
            } else {  
 	       set_clock_groups -asynchronous -group [get_clocks {xcvr_reconfig_clk}] -group ${pcie_ss_inst}|gen_ftile_qhip_rp.gen_u_ftile_rp_syspll_enable.gen_u_ftile.u_ftile|intel_pcie_ftile_ast_qhip|rx_clkout|ch5
            }
        } elseif {$TILE == "R-TILE"} {
 	    set_clock_groups -asynchronous -group [get_clocks {xcvr_reconfig_clk}] -group ${pcie_ss_inst}|u_rtile|intel_pcie_rtile_ast_qhip_pld_clkout
 	    set_clock_groups -asynchronous -group [get_clocks {xcvr_reconfig_clk}] -group ${pcie_ss_inst}|u_rtile|intel_pcie_rtile_ast_qhip_pld_clkout_slow
        
        }

        if {$pcie_axi_lite_clk_ext} {

            set_clock_groups -asynchronous -group [get_clocks {xcvr_reconfig_clk}] -group p0_axi_lite_clk
            if {[regexp "2x8" $top_topology] || [regexp "x4" $top_topology]} {
                set_clock_groups -asynchronous -group [get_clocks {xcvr_reconfig_clk}] -group p1_axi_lite_clk
            }
            if {[regexp "x4" $top_topology]} {
                set_clock_groups -asynchronous -group [get_clocks {xcvr_reconfig_clk}] -group p2_axi_lite_clk
                set_clock_groups -asynchronous -group [get_clocks {xcvr_reconfig_clk}] -group p3_axi_lite_clk
            }

        }

        if {$pcie_axi_st_clk_ext} {

            set_clock_groups -asynchronous -group [get_clocks {xcvr_reconfig_clk}] -group p0_axi_st_clk
            if {[regexp "2x8" $top_topology] || [regexp "x4" $top_topology]} {
                set_clock_groups -asynchronous -group [get_clocks {xcvr_reconfig_clk}] -group p1_axi_st_clk
            }
            if {[regexp "x4" $top_topology]} {
                set_clock_groups -asynchronous -group [get_clocks {xcvr_reconfig_clk}] -group p2_axi_st_clk
                set_clock_groups -asynchronous -group [get_clocks {xcvr_reconfig_clk}] -group p3_axi_st_clk
            }
        }
 }


if {$TILE == "P-TILE"} {

        if {$pcie_axi_st_clk_ext} {
		set_clock_groups -asynchronous -group {p0_axi_st_clk} -group ${pcie_ss_inst}|gen_ptile.u_ptile|intel_pcie_ptile_ast_qhip|inst|inst|maib_and_tile|xcvr_hip_native|rx_ch15
		if {[regexp "2x8" $top_topology] || [regexp "x4" $top_topology]} {        
	        	set_clock_groups -asynchronous -group {p1_axi_st_clk} -group ${pcie_ss_inst}|gen_ptile.u_ptile|intel_pcie_ptile_ast_qhip|inst|inst|maib_and_tile|xcvr_hip_native|rx_ch15
		}
		if {[regexp "x4" $top_topology]} {
		        set_clock_groups -asynchronous -group {p2_axi_st_clk} -group ${pcie_ss_inst}|gen_ptile.u_ptile|intel_pcie_ptile_ast_qhip|inst|inst|maib_and_tile|xcvr_hip_native|rx_ch15
		        set_clock_groups -asynchronous -group {p3_axi_st_clk} -group ${pcie_ss_inst}|gen_ptile.u_ptile|intel_pcie_ptile_ast_qhip|inst|inst|maib_and_tile|xcvr_hip_native|rx_ch15
		}
        }

        if {$pcie_axi_lite_clk_ext} {
        	set_clock_groups -asynchronous -group {p0_axi_lite_clk} -group ${pcie_ss_inst}|gen_ptile.u_ptile|intel_pcie_ptile_ast_qhip|inst|inst|maib_and_tile|xcvr_hip_native|rx_ch15
        	if {[regexp "2x8" $top_topology] || [regexp "x4" $top_topology]} {
        	        set_clock_groups -asynchronous -group {p1_axi_lite_clk} -group ${pcie_ss_inst}|gen_ptile.u_ptile|intel_pcie_ptile_ast_qhip|inst|inst|maib_and_tile|xcvr_hip_native|rx_ch15
        	}
        	if {[regexp "x4" $top_topology]} {
        	        set_clock_groups -asynchronous -group {p2_axi_lite_clk} -group ${pcie_ss_inst}|gen_ptile.u_ptile|intel_pcie_ptile_ast_qhip|inst|inst|maib_and_tile|xcvr_hip_native|rx_ch15
        	        set_clock_groups -asynchronous -group {p3_axi_lite_clk} -group ${pcie_ss_inst}|gen_ptile.u_ptile|intel_pcie_ptile_ast_qhip|inst|inst|maib_and_tile|xcvr_hip_native|rx_ch15
        	}
        
        	set_clock_groups -asynchronous -group {avmm_clock0} -group ${pcie_ss_inst}|gen_ptile.u_ptile|intel_pcie_ptile_ast_qhip|inst|inst|maib_and_tile|xcvr_hip_native|rx_ch15
        	if {[regexp "2x8" $top_topology] || [regexp "x4" $top_topology]} {
        	        set_clock_groups -asynchronous -group {avmm_clock1} -group ${pcie_ss_inst}|gen_ptile.u_ptile|intel_pcie_ptile_ast_qhip|inst|inst|maib_and_tile|xcvr_hip_native|rx_ch15
        	}
        	if {[regexp "x4" $top_topology]} {
        	        set_clock_groups -asynchronous -group {avmm_clock2} -group ${pcie_ss_inst}|gen_ptile.u_ptile|intel_pcie_ptile_ast_qhip|inst|inst|maib_and_tile|xcvr_hip_native|rx_ch15
        	        set_clock_groups -asynchronous -group {avmm_clock3} -group ${pcie_ss_inst}|gen_ptile.u_ptile|intel_pcie_ptile_ast_qhip|inst|inst|maib_and_tile|xcvr_hip_native|rx_ch15
        	}
        }
 } elseif {$TILE == "F-TILE"} {
    if {[regexp "Native Endpoint" $virtual_rp_ep_mode]} {
	set_clock_groups -asynchronous -group {altera_int_osc_clk} -group ${pcie_ss_inst}|gen_ftile.gen_u_ftile.u_ftile|intel_pcie_ftile_ast_qhip|rx_clkout|ch5

        if {$pcie_axi_st_clk_ext} {
 		set_clock_groups -asynchronous -group {p0_axi_st_clk} -group ${pcie_ss_inst}|gen_ftile.gen_u_ftile.u_ftile|intel_pcie_ftile_ast_qhip|rx_clkout|ch5
		if {[regexp "2x8" $top_topology] || [regexp "x4" $top_topology]} {        
		        set_clock_groups -asynchronous -group {p1_axi_st_clk} -group ${pcie_ss_inst}|gen_ftile.gen_u_ftile.u_ftile|intel_pcie_ftile_ast_qhip|rx_clkout|ch5
		}
		if {[regexp "x4" $top_topology]} {
		        set_clock_groups -asynchronous -group {p2_axi_st_clk} -group ${pcie_ss_inst}|gen_ftile.gen_u_ftile.u_ftile|intel_pcie_ftile_ast_qhip|rx_clkout|ch5
		        set_clock_groups -asynchronous -group {p3_axi_st_clk} -group ${pcie_ss_inst}|gen_ftile.gen_u_ftile.u_ftile|intel_pcie_ftile_ast_qhip|rx_clkout|ch5
		}
        }

        if {$pcie_axi_lite_clk_ext} {
        	set_clock_groups -asynchronous -group {p0_axi_lite_clk} -group ${pcie_ss_inst}|gen_ftile.gen_u_ftile.u_ftile|intel_pcie_ftile_ast_qhip|rx_clkout|ch5
        	if {[regexp "2x8" $top_topology] || [regexp "x4" $top_topology]} {
        	        set_clock_groups -asynchronous -group {p1_axi_lite_clk} -group ${pcie_ss_inst}|gen_ftile.gen_u_ftile.u_ftile|intel_pcie_ftile_ast_qhip|rx_clkout|ch5
        	}
        	if {[regexp "x4" $top_topology]} {
        	        set_clock_groups -asynchronous -group {p2_axi_lite_clk} -group ${pcie_ss_inst}|gen_ftile.gen_u_ftile.u_ftile|intel_pcie_ftile_ast_qhip|rx_clkout|ch5
        	        set_clock_groups -asynchronous -group {p3_axi_lite_clk} -group ${pcie_ss_inst}|gen_ftile.gen_u_ftile.u_ftile|intel_pcie_ftile_ast_qhip|rx_clkout|ch5
        	}
        
        	set_clock_groups -asynchronous -group {avmm_clock0} -group ${pcie_ss_inst}|gen_ftile.gen_u_ftile.u_ftile|intel_pcie_ftile_ast_qhip|rx_clkout|ch5
        	if {[regexp "2x8" $top_topology] || [regexp "x4" $top_topology]} {
        	        set_clock_groups -asynchronous -group {avmm_clock1} -group ${pcie_ss_inst}|gen_ftile.gen_u_ftile.u_ftile|intel_pcie_ftile_ast_qhip|rx_clkout|ch5
        	}
        	if {[regexp "x4" $top_topology]} {
        	        set_clock_groups -asynchronous -group {avmm_clock2} -group ${pcie_ss_inst}|gen_ftile.gen_u_ftile.u_ftile|intel_pcie_ftile_ast_qhip|rx_clkout|ch5
        	        set_clock_groups -asynchronous -group {avmm_clock3} -group ${pcie_ss_inst}|gen_ftile.gen_u_ftile.u_ftile|intel_pcie_ftile_ast_qhip|rx_clkout|ch5
        	}
        }
    } else {  
	set_clock_groups -asynchronous -group {altera_int_osc_clk} -group ${pcie_ss_inst}|gen_ftile_qhip_rp.gen_u_ftile_rp_syspll_enable.gen_u_ftile.u_ftile|intel_pcie_ftile_ast_qhip|rx_clkout|ch5

        if {$pcie_axi_st_clk_ext} {
 		set_clock_groups -asynchronous -group {p0_axi_st_clk} -group ${pcie_ss_inst}|gen_ftile_qhip_rp.gen_u_ftile_rp_syspll_enable.gen_u_ftile.u_ftile|intel_pcie_ftile_ast_qhip|rx_clkout|ch5
		if {[regexp "2x8" $top_topology] || [regexp "x4" $top_topology]} {        
		        set_clock_groups -asynchronous -group {p1_axi_st_clk} -group ${pcie_ss_inst}|gen_ftile_qhip_rp.gen_u_ftile_rp_syspll_enable.gen_u_ftile.u_ftile|intel_pcie_ftile_ast_qhip|rx_clkout|ch5
		}
		if {[regexp "x4" $top_topology]} {
		        set_clock_groups -asynchronous -group {p2_axi_st_clk} -group ${pcie_ss_inst}|gen_ftile_qhip_rp.gen_u_ftile_rp_syspll_enable.gen_u_ftile.u_ftile|intel_pcie_ftile_ast_qhip|rx_clkout|ch5
		        set_clock_groups -asynchronous -group {p3_axi_st_clk} -group ${pcie_ss_inst}|gen_ftile_qhip_rp.gen_u_ftile_rp_syspll_enable.gen_u_ftile.u_ftile|intel_pcie_ftile_ast_qhip|rx_clkout|ch5
		}
        }

        if {$pcie_axi_lite_clk_ext} {
        	set_clock_groups -asynchronous -group {p0_axi_lite_clk} -group ${pcie_ss_inst}|gen_ftile_qhip_rp.gen_u_ftile_rp_syspll_enable.gen_u_ftile.u_ftile|intel_pcie_ftile_ast_qhip|rx_clkout|ch5
        	if {[regexp "2x8" $top_topology] || [regexp "x4" $top_topology]} {
        	        set_clock_groups -asynchronous -group {p1_axi_lite_clk} -group ${pcie_ss_inst}|gen_ftile_qhip_rp.gen_u_ftile_rp_syspll_enable.gen_u_ftile.u_ftile|intel_pcie_ftile_ast_qhip|rx_clkout|ch5
        	}
        	if {[regexp "x4" $top_topology]} {
        	        set_clock_groups -asynchronous -group {p2_axi_lite_clk} -group ${pcie_ss_inst}|gen_ftile_qhip_rp.gen_u_ftile_rp_syspll_enable.gen_u_ftile.u_ftile|intel_pcie_ftile_ast_qhip|rx_clkout|ch5
        	        set_clock_groups -asynchronous -group {p3_axi_lite_clk} -group ${pcie_ss_inst}|gen_ftile_qhip_rp.gen_u_ftile_rp_syspll_enable.gen_u_ftile.u_ftile|intel_pcie_ftile_ast_qhip|rx_clkout|ch5
        	}
        
        	set_clock_groups -asynchronous -group {avmm_clock0} -group ${pcie_ss_inst}|gen_ftile_qhip_rp.gen_u_ftile_rp_syspll_enable.gen_u_ftile.u_ftile|intel_pcie_ftile_ast_qhip|rx_clkout|ch5
        	if {[regexp "2x8" $top_topology] || [regexp "x4" $top_topology]} {
        	        set_clock_groups -asynchronous -group {avmm_clock1} -group ${pcie_ss_inst}|gen_ftile_qhip_rp.gen_u_ftile_rp_syspll_enable.gen_u_ftile.u_ftile|intel_pcie_ftile_ast_qhip|rx_clkout|ch5
        	}
        	if {[regexp "x4" $top_topology]} {
        	        set_clock_groups -asynchronous -group {avmm_clock2} -group ${pcie_ss_inst}|gen_ftile_qhip_rp.gen_u_ftile_rp_syspll_enable.gen_u_ftile.u_ftile|intel_pcie_ftile_ast_qhip|rx_clkout|ch5
        	        set_clock_groups -asynchronous -group {avmm_clock3} -group ${pcie_ss_inst}|gen_ftile_qhip_rp.gen_u_ftile_rp_syspll_enable.gen_u_ftile.u_ftile|intel_pcie_ftile_ast_qhip|rx_clkout|ch5
        	}
        }
    } 
} elseif {$TILE == "R-TILE"} {

        if {$pcie_axi_st_clk_ext} {
         	set_clock_groups -asynchronous -group {p0_axi_st_clk} -group ${pcie_ss_inst}|u_rtile|intel_pcie_rtile_ast_qhip_pld_clkout
            set_clock_groups -asynchronous -group {altera_int_osc_clk} -group ${pcie_ss_inst}|u_rtile|intel_pcie_rtile_ast_qhip_pld_clkout
            set_clock_groups -asynchronous -group {p0_axi_st_clk} -group ${pcie_ss_inst}|u_rtile|intel_pcie_rtile_ast_qhip_pld_clkout_slow
            set_clock_groups -asynchronous -group {altera_int_osc_clk} -group ${pcie_ss_inst}|u_rtile|intel_pcie_rtile_ast_qhip_pld_clkout_slow
        	if {[regexp "2x8" $top_topology] || [regexp "x4" $top_topology]} {        
        	        set_clock_groups -asynchronous -group {p1_axi_st_clk} -group ${pcie_ss_inst}|u_rtile|intel_pcie_rtile_ast_qhip_pld_clkout
        	        set_clock_groups -asynchronous -group {p1_axi_st_clk} -group ${pcie_ss_inst}|u_rtile|intel_pcie_rtile_ast_qhip_pld_clkout_slow
                    
        	}
        	if {[regexp "x4" $top_topology]} {
        	        set_clock_groups -asynchronous -group {p2_axi_st_clk} -group ${pcie_ss_inst}|u_rtile|intel_pcie_rtile_ast_qhip_pld_clkout
        	        set_clock_groups -asynchronous -group {p3_axi_st_clk} -group ${pcie_ss_inst}|u_rtile|intel_pcie_rtile_ast_qhip_pld_clkout
                    set_clock_groups -asynchronous -group {p2_axi_st_clk} -group ${pcie_ss_inst}|u_rtile|intel_pcie_rtile_ast_qhip_pld_clkout_slow
        	        set_clock_groups -asynchronous -group {p3_axi_st_clk} -group ${pcie_ss_inst}|u_rtile|intel_pcie_rtile_ast_qhip_pld_clkout_slow

        	}
        }

        if {$pcie_axi_lite_clk_ext} {
        	set_clock_groups -asynchronous -group {p0_axi_lite_clk} -group ${pcie_ss_inst}|u_rtile|intel_pcie_rtile_ast_qhip_pld_clkout
        	set_clock_groups -asynchronous -group {p0_axi_lite_clk} -group ${pcie_ss_inst}|u_rtile|intel_pcie_rtile_ast_qhip_pld_clkout_slow
            
        	if {[regexp "2x8" $top_topology] || [regexp "x4" $top_topology]} {
        	        set_clock_groups -asynchronous -group {p1_axi_lite_clk} -group ${pcie_ss_inst}|u_rtile|intel_pcie_rtile_ast_qhip_pld_clkout
        	        set_clock_groups -asynchronous -group {p1_axi_lite_clk} -group ${pcie_ss_inst}|u_rtile|intel_pcie_rtile_ast_qhip_pld_clkout_slow
                    
        	}
        	if {[regexp "x4" $top_topology]} {
        	        set_clock_groups -asynchronous -group {p2_axi_lite_clk} -group ${pcie_ss_inst}|u_rtile|intel_pcie_rtile_ast_qhip_pld_clkout
        	        set_clock_groups -asynchronous -group {p3_axi_lite_clk} -group ${pcie_ss_inst}|u_rtile|intel_pcie_rtile_ast_qhip_pld_clkout
                    set_clock_groups -asynchronous -group {p2_axi_lite_clk} -group ${pcie_ss_inst}|u_rtile|intel_pcie_rtile_ast_qhip_pld_clkout_slow
        	        set_clock_groups -asynchronous -group {p3_axi_lite_clk} -group ${pcie_ss_inst}|u_rtile|intel_pcie_rtile_ast_qhip_pld_clkout_slow

        	}
        
        }
 }


if {$pcie_axi_lite_clk_ext && $pcie_axi_st_clk_ext} {
    set_clock_groups -asynchronous -group {p0_axi_lite_clk} -group {p0_axi_st_clk}
    if {[regexp "2x8" $top_topology] || [regexp "x4" $top_topology]} {
            set_clock_groups -asynchronous -group {p1_axi_lite_clk} -group {p1_axi_st_clk}
    }
    if {[regexp "x4" $top_topology]} {
            set_clock_groups -asynchronous -group {p2_axi_lite_clk} -group {p2_axi_st_clk}
            set_clock_groups -asynchronous -group {p3_axi_lite_clk} -group {p3_axi_st_clk}
    }
    
    if {$TILE == "F-TILE" || $TILE == "P-TILE"} {
       set_clock_groups -asynchronous -group {p0_axi_st_clk} -group {avmm_clock0}
       if {[regexp "2x8" $top_topology] || [regexp "x4" $top_topology]} {
               set_clock_groups -asynchronous -group {p1_axi_st_clk} -group {avmm_clock1}
       }
       if {[regexp "x4" $top_topology]} {
               set_clock_groups -asynchronous -group {p2_axi_st_clk} -group {avmm_clock2}
               set_clock_groups -asynchronous -group {p3_axi_st_clk} -group {avmm_clock3}
       }
    }
}

if {$TILE == "F-TILE" || $TILE == "P-TILE"} {
   if {[regexp "Native Endpoint" $virtual_rp_ep_mode]} {
      set_false_path -from [get_keepers ${pcie_ss_inst}|EP_PFTILE_WRAPPER.gen_pciess.u_pciess_p0|u_pciess|u_ss_rst_seq|gen_resp_rst_sync[*].resp_rst_sync|dreg*] -to ${pcie_ss_inst}|EP_PFTILE_WRAPPER.gen_pciess.u_pciess_p0|u_pciess|gen_sub.u_hipif|u_pciess*|u_pciess*|*_sync|dreg*
      set_false_path -from [get_keepers ${pcie_ss_inst}|EP_PFTILE_WRAPPER.gen_pciess.u_pciess_p0|u_pciess|u_ss_rst_seq|gen_resp_rst_sync[*].resp_rst_sync|dreg*] -to ${pcie_ss_inst}|EP_PFTILE_WRAPPER.gen_pciess.u_pciess_p0|u_pciess|gen_sub.u_hipif|u_pciess*|pciess*|*_sync|dreg*
      set_false_path -from [get_keepers ${pcie_ss_inst}|EP_PFTILE_WRAPPER.gen_pciess.u_pciess_p0|u_pciess|u_ss_rst_seq|gen_resp_rst_sync[*].resp_rst_sync|dreg*] -to ${pcie_ss_inst}|EP_PFTILE_WRAPPER.gen_pciess.u_pciess_p0|u_pciess|gen_sub.u_hipif|u_pciess*|pciess*|*_rst_n|dreg*
      set_false_path -from [get_keepers ${pcie_ss_inst}|EP_PFTILE_WRAPPER.gen_pciess.u_pciess_p0|u_pciess|u_ss_rst_seq|gen_resp_rst_sync[*].resp_rst_sync|dreg*] -to ${pcie_ss_inst}|EP_PFTILE_WRAPPER.gen_pciess.u_pciess_p0|u_pciess|gen_sub.u_hipif|u_pciess*|*_sync|dreg*
      if {[regexp "Data Mover" $pcie_ss_func_mode]} {
          set_false_path -from [get_keepers ${pcie_ss_inst}|EP_PFTILE_WRAPPER.gen_pciess.u_pciess_p0|u_pciess|u_ss_rst_seq|gen_resp_rst_sync[1].resp_rst_sync|dreg[1]] -to ${pcie_ss_inst}|EP_PFTILE_WRAPPER.gen_pciess.u_pciess_p0|u_pciess|gen_sub.u_hipif|u_pciess_cfg_if|u_warm_rst_stclk_n_sync|dreg[*]
          set_false_path -from [get_keepers ${pcie_ss_inst}|EP_PFTILE_WRAPPER.gen_pciess.u_pciess_p0|u_pciess|u_ss_rst_seq|gen_resp_rst_sync[1].resp_rst_sync|dreg[1]] -to ${pcie_ss_inst}|EP_PFTILE_WRAPPER.gen_pciess.u_pciess_p0|u_pciess|gen_sub.u_hipif|u_pciess_rx_if|u_pciess_rx_alignment|u_warm_rst_stclk_n_sync|dreg[*]
          set_false_path -from [get_keepers ${pcie_ss_inst}|EP_PFTILE_WRAPPER.gen_pciess.u_pciess_p0|u_pciess|u_ss_rst_seq|gen_resp_rst_sync[1].resp_rst_sync|dreg[1]] -to ${pcie_ss_inst}|EP_PFTILE_WRAPPER.gen_pciess.u_pciess_p0|u_pciess|gen_sub.u_hipif|u_pciess_tx_if|pciess_tx_alignment.tx_alignment_inst|axi_st_clk_warm_rst_n|dreg[*]
      } elseif {[regexp "Power User" $pcie_ss_func_mode]} {
          set_false_path -from [get_keepers ${pcie_ss_inst}|EP_PFTILE_WRAPPER.gen_pciess.u_pciess_p0|u_pciess|u_ss_rst_seq|gen_resp_rst_sync[1].resp_rst_sync|dreg[1]] -to ${pcie_ss_inst}|EP_PFTILE_WRAPPER.gen_pciess.u_pciess_p0|u_pciess|gen_sub.u_hipif|EP_VF_ERR_IF.u_pciess_vf_err_if|u_warm_rst_vferrclk_n_sync|dreg[*]
      }
      
      if {[regexp "2x8" $top_topology] || [regexp "x4" $top_topology]} {
          set_false_path -from [get_keepers ${pcie_ss_inst}|EP_PFTILE_WRAPPER.gen_pciess_p1.u_pciess_p1|u_pciess|u_ss_rst_seq|gen_resp_rst_sync[*].resp_rst_sync|dreg*] -to ${pcie_ss_inst}|EP_PFTILE_WRAPPER.gen_pciess_p1.u_pciess_p1|u_pciess|gen_sub.u_hipif|u_pciess*|u_pciess*|*_sync|dreg*
          set_false_path -from [get_keepers ${pcie_ss_inst}|EP_PFTILE_WRAPPER.gen_pciess_p1.u_pciess_p1|u_pciess|u_ss_rst_seq|gen_resp_rst_sync[*].resp_rst_sync|dreg*] -to ${pcie_ss_inst}|EP_PFTILE_WRAPPER.gen_pciess_p1.u_pciess_p1|u_pciess|gen_sub.u_hipif|u_pciess*|pciess*|*_sync|dreg*
          set_false_path -from [get_keepers ${pcie_ss_inst}|EP_PFTILE_WRAPPER.gen_pciess_p1.u_pciess_p1|u_pciess|u_ss_rst_seq|gen_resp_rst_sync[*].resp_rst_sync|dreg*] -to ${pcie_ss_inst}|EP_PFTILE_WRAPPER.gen_pciess_p1.u_pciess_p1|u_pciess|gen_sub.u_hipif|u_pciess*|pciess*|*_rst_n|dreg*
          set_false_path -from [get_keepers ${pcie_ss_inst}|EP_PFTILE_WRAPPER.gen_pciess_p1.u_pciess_p1|u_pciess|u_ss_rst_seq|gen_resp_rst_sync[*].resp_rst_sync|dreg*] -to ${pcie_ss_inst}|EP_PFTILE_WRAPPER.gen_pciess_p1.u_pciess_p1|u_pciess|gen_sub.u_hipif|u_pciess*|*_sync|dreg*
          if {[regexp "Data Mover" $pcie_ss_func_mode]} {
      	set_false_path -from [get_keepers ${pcie_ss_inst}|EP_PFTILE_WRAPPER.gen_pciess_p1.u_pciess_p1|u_pciess|u_ss_rst_seq|gen_resp_rst_sync[1].resp_rst_sync|dreg[1]] -to ${pcie_ss_inst}|EP_PFTILE_WRAPPER.gen_pciess_p1.u_pciess_p1|u_pciess|gen_sub.u_hipif|u_pciess_cfg_if|u_warm_rst_stclk_n_sync|dreg[*]
      	set_false_path -from [get_keepers ${pcie_ss_inst}|EP_PFTILE_WRAPPER.gen_pciess_p1.u_pciess_p1|u_pciess|u_ss_rst_seq|gen_resp_rst_sync[1].resp_rst_sync|dreg[1]] -to ${pcie_ss_inst}|EP_PFTILE_WRAPPER.gen_pciess_p1.u_pciess_p1|u_pciess|gen_sub.u_hipif|u_pciess_rx_if|u_pciess_rx_alignment|u_warm_rst_stclk_n_sync|dreg[*]
      	set_false_path -from [get_keepers ${pcie_ss_inst}|EP_PFTILE_WRAPPER.gen_pciess_p1.u_pciess_p1|u_pciess|u_ss_rst_seq|gen_resp_rst_sync[1].resp_rst_sync|dreg[1]] -to ${pcie_ss_inst}|EP_PFTILE_WRAPPER.gen_pciess_p1.u_pciess_p1|u_pciess|gen_sub.u_hipif|u_pciess_tx_if|pciess_tx_alignment.tx_alignment_inst|axi_st_clk_warm_rst_n|dreg[*]
          } elseif {[regexp "Power User" $pcie_ss_func_mode]} {
      	set_false_path -from [get_keepers ${pcie_ss_inst}|EP_PFTILE_WRAPPER.gen_pciess_p1.u_pciess_p1|u_pciess|u_ss_rst_seq|gen_resp_rst_sync[1].resp_rst_sync|dreg[1]] -to ${pcie_ss_inst}|EP_PFTILE_WRAPPER.gen_pciess_p1.u_pciess_p1|u_pciess|gen_sub.u_hipif|EP_VF_ERR_IF.u_pciess_vf_err_if|u_warm_rst_vferrclk_n_sync|dreg[*]
          }
      }
   } else {  
      set_false_path -from [get_keepers ${pcie_ss_inst}|RP_PFTILE_WRAPPER.gen_pciess_rp.u_pciess_rp_p0|u_pciess|u_ss_rst_seq|gen_resp_rst_sync[*].resp_rst_sync|dreg*] -to ${pcie_ss_inst}|RP_PFTILE_WRAPPER.gen_pciess_rp.u_pciess_rp_p0|u_pciess|gen_sub.u_hipif|u_pciess*|u_pciess*|*_sync|dreg*
      set_false_path -from [get_keepers ${pcie_ss_inst}|RP_PFTILE_WRAPPER.gen_pciess_rp.u_pciess_rp_p0|u_pciess|u_ss_rst_seq|gen_resp_rst_sync[*].resp_rst_sync|dreg*] -to ${pcie_ss_inst}|RP_PFTILE_WRAPPER.gen_pciess_rp.u_pciess_rp_p0|u_pciess|gen_sub.u_hipif|u_pciess*|pciess*|*_sync|dreg*
      set_false_path -from [get_keepers ${pcie_ss_inst}|RP_PFTILE_WRAPPER.gen_pciess_rp.u_pciess_rp_p0|u_pciess|u_ss_rst_seq|gen_resp_rst_sync[*].resp_rst_sync|dreg*] -to ${pcie_ss_inst}|RP_PFTILE_WRAPPER.gen_pciess_rp.u_pciess_rp_p0|u_pciess|gen_sub.u_hipif|u_pciess*|pciess*|*_rst_n|dreg*
      set_false_path -from [get_keepers ${pcie_ss_inst}|RP_PFTILE_WRAPPER.gen_pciess_rp.u_pciess_rp_p0|u_pciess|u_ss_rst_seq|gen_resp_rst_sync[*].resp_rst_sync|dreg*] -to ${pcie_ss_inst}|RP_PFTILE_WRAPPER.gen_pciess_rp.u_pciess_rp_p0|u_pciess|gen_sub.u_hipif|u_pciess*|*_sync|dreg*
      if {[regexp "Data Mover" $pcie_ss_func_mode]} {
          set_false_path -from [get_keepers ${pcie_ss_inst}|RP_PFTILE_WRAPPER.gen_pciess_rp.u_pciess_rp_p0|u_pciess|u_ss_rst_seq|gen_resp_rst_sync[1].resp_rst_sync|dreg[1]] -to ${pcie_ss_inst}|RP_PFTILE_WRAPPER.gen_pciess_rp.u_pciess_rp_p0|u_pciess|gen_sub.u_hipif|u_pciess_cfg_if|u_warm_rst_stclk_n_sync|dreg[*]
          set_false_path -from [get_keepers ${pcie_ss_inst}|RP_PFTILE_WRAPPER.gen_pciess_rp.u_pciess_rp_p0|u_pciess|u_ss_rst_seq|gen_resp_rst_sync[1].resp_rst_sync|dreg[1]] -to ${pcie_ss_inst}|RP_PFTILE_WRAPPER.gen_pciess_rp.u_pciess_rp_p0|u_pciess|gen_sub.u_hipif|u_pciess_rx_if|u_pciess_rx_alignment|u_warm_rst_stclk_n_sync|dreg[*]
          set_false_path -from [get_keepers ${pcie_ss_inst}|RP_PFTILE_WRAPPER.gen_pciess_rp.u_pciess_rp_p0|u_pciess|u_ss_rst_seq|gen_resp_rst_sync[1].resp_rst_sync|dreg[1]] -to ${pcie_ss_inst}|RP_PFTILE_WRAPPER.gen_pciess_rp.u_pciess_rp_p0|u_pciess|gen_sub.u_hipif|u_pciess_tx_if|pciess_tx_alignment.tx_alignment_inst|axi_st_clk_warm_rst_n|dreg[*]
      }   
   
      if {[regexp "2x8" $top_topology] || [regexp "x4" $top_topology]} {
          set_false_path -from [get_keepers ${pcie_ss_inst}|RP_PFTILE_WRAPPER.gen_pciess_rp_p1.u_pciess_rp_p1|u_pciess|u_ss_rst_seq|gen_resp_rst_sync[*].resp_rst_sync|dreg*] -to ${pcie_ss_inst}|RP_PFTILE_WRAPPER.gen_pciess_rp_p1.u_pciess_rp_p1|u_pciess|gen_sub.u_hipif|u_pciess*|u_pciess*|*_sync|dreg*
          set_false_path -from [get_keepers ${pcie_ss_inst}|RP_PFTILE_WRAPPER.gen_pciess_rp_p1.u_pciess_rp_p1|u_pciess|u_ss_rst_seq|gen_resp_rst_sync[*].resp_rst_sync|dreg*] -to ${pcie_ss_inst}|RP_PFTILE_WRAPPER.gen_pciess_rp_p1.u_pciess_rp_p1|u_pciess|gen_sub.u_hipif|u_pciess*|pciess*|*_sync|dreg*
          set_false_path -from [get_keepers ${pcie_ss_inst}|RP_PFTILE_WRAPPER.gen_pciess_rp_p1.u_pciess_rp_p1|u_pciess|u_ss_rst_seq|gen_resp_rst_sync[*].resp_rst_sync|dreg*] -to ${pcie_ss_inst}|RP_PFTILE_WRAPPER.gen_pciess_rp_p1.u_pciess_rp_p1|u_pciess|gen_sub.u_hipif|u_pciess*|pciess*|*_rst_n|dreg*
          set_false_path -from [get_keepers ${pcie_ss_inst}|RP_PFTILE_WRAPPER.gen_pciess_rp_p1.u_pciess_rp_p1|u_pciess|u_ss_rst_seq|gen_resp_rst_sync[*].resp_rst_sync|dreg*] -to ${pcie_ss_inst}|RP_PFTILE_WRAPPER.gen_pciess_rp_p1.u_pciess_rp_p1|u_pciess|gen_sub.u_hipif|u_pciess*|*_sync|dreg*
          if {[regexp "Data Mover" $pcie_ss_func_mode]} {
      	set_false_path -from [get_keepers ${pcie_ss_inst}|RP_PFTILE_WRAPPER.gen_pciess_rp_p1.u_pciess_rp_p1|u_pciess|u_ss_rst_seq|gen_resp_rst_sync[1].resp_rst_sync|dreg[1]] -to ${pcie_ss_inst}|RP_PFTILE_WRAPPER.gen_pciess_rp_p1.u_pciess_rp_p1|u_pciess|gen_sub.u_hipif|u_pciess_cfg_if|u_warm_rst_stclk_n_sync|dreg[*]
      	set_false_path -from [get_keepers ${pcie_ss_inst}|RP_PFTILE_WRAPPER.gen_pciess_rp_p1.u_pciess_rp_p1|u_pciess|u_ss_rst_seq|gen_resp_rst_sync[1].resp_rst_sync|dreg[1]] -to ${pcie_ss_inst}|RP_PFTILE_WRAPPER.gen_pciess_rp_p1.u_pciess_rp_p1|u_pciess|gen_sub.u_hipif|u_pciess_rx_if|u_pciess_rx_alignment|u_warm_rst_stclk_n_sync|dreg[*]
      	set_false_path -from [get_keepers ${pcie_ss_inst}|RP_PFTILE_WRAPPER.gen_pciess_rp_p1.u_pciess_rp_p1|u_pciess|u_ss_rst_seq|gen_resp_rst_sync[1].resp_rst_sync|dreg[1]] -to ${pcie_ss_inst}|RP_PFTILE_WRAPPER.gen_pciess_rp_p1.u_pciess_rp_p1|u_pciess|gen_sub.u_hipif|u_pciess_tx_if|pciess_tx_alignment.tx_alignment_inst|axi_st_clk_warm_rst_n|dreg[*]
          } 
      }
   }
} elseif {$TILE == "R-TILE"} {
   if {[regexp "Native Endpoint" $virtual_rp_ep_mode]} {
      set_false_path -from [get_keepers ${pcie_ss_inst}|EP_RTILE_WRAPPER.u_pciess_p0|u_pciess|u_ss_rst_seq|gen_resp_rst_sync[*].resp_rst_sync|dreg*] -to ${pcie_ss_inst}|EP_RTILE_WRAPPER.u_pciess_p0|u_pciess|gen_sub.u_hipif|u_pciess*|u_pciess*|*_sync|dreg*
      set_false_path -from [get_keepers ${pcie_ss_inst}|EP_RTILE_WRAPPER.u_pciess_p0|u_pciess|u_ss_rst_seq|gen_resp_rst_sync[*].resp_rst_sync|dreg*] -to ${pcie_ss_inst}|EP_RTILE_WRAPPER.u_pciess_p0|u_pciess|gen_sub.u_hipif|u_pciess*|pciess*|*_sync|dreg*
      set_false_path -from [get_keepers ${pcie_ss_inst}|EP_RTILE_WRAPPER.u_pciess_p0|u_pciess|u_ss_rst_seq|gen_resp_rst_sync[*].resp_rst_sync|dreg*] -to ${pcie_ss_inst}|EP_RTILE_WRAPPER.u_pciess_p0|u_pciess|gen_sub.u_hipif|u_pciess*|pciess*|*_rst_n|dreg*
      set_false_path -from [get_keepers ${pcie_ss_inst}|EP_RTILE_WRAPPER.u_pciess_p0|u_pciess|u_ss_rst_seq|gen_resp_rst_sync[*].resp_rst_sync|dreg*] -to ${pcie_ss_inst}|EP_RTILE_WRAPPER.u_pciess_p0|u_pciess|gen_sub.u_hipif|u_pciess*|*_sync|dreg*
      if {[regexp "Data Mover" $pcie_ss_func_mode]} {
          set_false_path -from [get_keepers ${pcie_ss_inst}|EP_RTILE_WRAPPER.u_pciess_p0|u_pciess|u_ss_rst_seq|gen_resp_rst_sync[1].resp_rst_sync|dreg[1]] -to ${pcie_ss_inst}|EP_RTILE_WRAPPER.u_pciess_p0|u_pciess|gen_sub.u_hipif|u_pciess_cfg_if|u_warm_rst_stclk_n_sync|dreg[*]
          set_false_path -from [get_keepers ${pcie_ss_inst}|EP_RTILE_WRAPPER.u_pciess_p0|u_pciess|u_ss_rst_seq|gen_resp_rst_sync[1].resp_rst_sync|dreg[1]] -to ${pcie_ss_inst}|EP_RTILE_WRAPPER.u_pciess_p0|u_pciess|gen_sub.u_hipif|u_pciess_rx_if|u_pciess_rx_alignment|u_warm_rst_stclk_n_sync|dreg[*]
          set_false_path -from [get_keepers ${pcie_ss_inst}|EP_RTILE_WRAPPER.u_pciess_p0|u_pciess|u_ss_rst_seq|gen_resp_rst_sync[1].resp_rst_sync|dreg[1]] -to ${pcie_ss_inst}|EP_RTILE_WRAPPER.u_pciess_p0|u_pciess|gen_sub.u_hipif|u_pciess_tx_if|pciess_tx_alignment.tx_alignment_inst|axi_st_clk_warm_rst_n|dreg[*]
      } elseif {[regexp "Power User" $pcie_ss_func_mode]} {
          set_false_path -from [get_keepers ${pcie_ss_inst}|EP_RTILE_WRAPPER.u_pciess_p0|u_pciess|u_ss_rst_seq|gen_resp_rst_sync[1].resp_rst_sync|dreg[1]] -to ${pcie_ss_inst}|EP_RTILE_WRAPPER.u_pciess_p0|u_pciess|gen_sub.u_hipif|EP_VF_ERR_IF.u_pciess_vf_err_if|u_warm_rst_vferrclk_n_sync|dreg[*]
      }
      
      if {[regexp "2x8" $top_topology] || [regexp "x4" $top_topology]} {
          set_false_path -from [get_keepers ${pcie_ss_inst}|EP_RTILE_WRAPPER.gen_pciess_p1.u_pciess_p1|u_pciess|u_ss_rst_seq|gen_resp_rst_sync[*].resp_rst_sync|dreg*] -to ${pcie_ss_inst}|EP_RTILE_WRAPPER.gen_pciess_p1.u_pciess_p1|u_pciess|gen_sub.u_hipif|u_pciess*|u_pciess*|*_sync|dreg*
          set_false_path -from [get_keepers ${pcie_ss_inst}|EP_RTILE_WRAPPER.gen_pciess_p1.u_pciess_p1|u_pciess|u_ss_rst_seq|gen_resp_rst_sync[*].resp_rst_sync|dreg*] -to ${pcie_ss_inst}|EP_RTILE_WRAPPER.gen_pciess_p1.u_pciess_p1|u_pciess|gen_sub.u_hipif|u_pciess*|pciess*|*_sync|dreg*
          set_false_path -from [get_keepers ${pcie_ss_inst}|EP_RTILE_WRAPPER.gen_pciess_p1.u_pciess_p1|u_pciess|u_ss_rst_seq|gen_resp_rst_sync[*].resp_rst_sync|dreg*] -to ${pcie_ss_inst}|EP_RTILE_WRAPPER.gen_pciess_p1.u_pciess_p1|u_pciess|gen_sub.u_hipif|u_pciess*|pciess*|*_rst_n|dreg*
          set_false_path -from [get_keepers ${pcie_ss_inst}|EP_RTILE_WRAPPER.gen_pciess_p1.u_pciess_p1|u_pciess|u_ss_rst_seq|gen_resp_rst_sync[*].resp_rst_sync|dreg*] -to ${pcie_ss_inst}|EP_RTILE_WRAPPER.gen_pciess_p1.u_pciess_p1|u_pciess|gen_sub.u_hipif|u_pciess*|*_sync|dreg*
          if {[regexp "Data Mover" $pcie_ss_func_mode]} {
      	set_false_path -from [get_keepers ${pcie_ss_inst}|EP_RTILE_WRAPPER.gen_pciess_p1.u_pciess_p1|u_pciess|u_ss_rst_seq|gen_resp_rst_sync[1].resp_rst_sync|dreg[1]] -to ${pcie_ss_inst}|EP_RTILE_WRAPPER.gen_pciess_p1.u_pciess_p1|u_pciess|gen_sub.u_hipif|u_pciess_cfg_if|u_warm_rst_stclk_n_sync|dreg[*]
      	set_false_path -from [get_keepers ${pcie_ss_inst}|EP_RTILE_WRAPPER.gen_pciess_p1.u_pciess_p1|u_pciess|u_ss_rst_seq|gen_resp_rst_sync[1].resp_rst_sync|dreg[1]] -to ${pcie_ss_inst}|EP_RTILE_WRAPPER.gen_pciess_p1.u_pciess_p1|u_pciess|gen_sub.u_hipif|u_pciess_rx_if|u_pciess_rx_alignment|u_warm_rst_stclk_n_sync|dreg[*]
      	set_false_path -from [get_keepers ${pcie_ss_inst}|EP_RTILE_WRAPPER.gen_pciess_p1.u_pciess_p1|u_pciess|u_ss_rst_seq|gen_resp_rst_sync[1].resp_rst_sync|dreg[1]] -to ${pcie_ss_inst}|EP_RTILE_WRAPPER.gen_pciess_p1.u_pciess_p1|u_pciess|gen_sub.u_hipif|u_pciess_tx_if|pciess_tx_alignment.tx_alignment_inst|axi_st_clk_warm_rst_n|dreg[*]
          } elseif {[regexp "Power User" $pcie_ss_func_mode]} {
      	set_false_path -from [get_keepers ${pcie_ss_inst}|EP_RTILE_WRAPPER.gen_pciess_p1.u_pciess_p1|u_pciess|u_ss_rst_seq|gen_resp_rst_sync[1].resp_rst_sync|dreg[1]] -to ${pcie_ss_inst}|EP_RTILE_WRAPPER.gen_pciess_p1.u_pciess_p1|u_pciess|gen_sub.u_hipif|EP_VF_ERR_IF.u_pciess_vf_err_if|u_warm_rst_vferrclk_n_sync|dreg[*]
          }
      }
   } else {  
      set_false_path -from [get_keepers ${pcie_ss_inst}|RP_RTILE_WRAPPER.u_pciess_rp_p0|u_pciess|u_ss_rst_seq|gen_resp_rst_sync[*].resp_rst_sync|dreg*] -to ${pcie_ss_inst}|RP_RTILE_WRAPPER.u_pciess_rp_p0|u_pciess|gen_sub.u_hipif|u_pciess*|u_pciess*|*_sync|dreg*
      set_false_path -from [get_keepers ${pcie_ss_inst}|RP_RTILE_WRAPPER.u_pciess_rp_p0|u_pciess|u_ss_rst_seq|gen_resp_rst_sync[*].resp_rst_sync|dreg*] -to ${pcie_ss_inst}|RP_RTILE_WRAPPER.u_pciess_rp_p0|u_pciess|gen_sub.u_hipif|u_pciess*|pciess*|*_sync|dreg*
      set_false_path -from [get_keepers ${pcie_ss_inst}|RP_RTILE_WRAPPER.u_pciess_rp_p0|u_pciess|u_ss_rst_seq|gen_resp_rst_sync[*].resp_rst_sync|dreg*] -to ${pcie_ss_inst}|RP_RTILE_WRAPPER.u_pciess_rp_p0|u_pciess|gen_sub.u_hipif|u_pciess*|pciess*|*_rst_n|dreg*
      set_false_path -from [get_keepers ${pcie_ss_inst}|RP_RTILE_WRAPPER.u_pciess_rp_p0|u_pciess|u_ss_rst_seq|gen_resp_rst_sync[*].resp_rst_sync|dreg*] -to ${pcie_ss_inst}|RP_RTILE_WRAPPER.u_pciess_rp_p0|u_pciess|gen_sub.u_hipif|u_pciess*|*_sync|dreg*
      if {[regexp "Data Mover" $pcie_ss_func_mode]} {
          set_false_path -from [get_keepers ${pcie_ss_inst}|RP_RTILE_WRAPPER.u_pciess_rp_p0|u_pciess|u_ss_rst_seq|gen_resp_rst_sync[1].resp_rst_sync|dreg[1]] -to ${pcie_ss_inst}|RP_RTILE_WRAPPER.u_pciess_rp_p0|u_pciess|gen_sub.u_hipif|u_pciess_cfg_if|u_warm_rst_stclk_n_sync|dreg[*]
          set_false_path -from [get_keepers ${pcie_ss_inst}|RP_RTILE_WRAPPER.u_pciess_rp_p0|u_pciess|u_ss_rst_seq|gen_resp_rst_sync[1].resp_rst_sync|dreg[1]] -to ${pcie_ss_inst}|RP_RTILE_WRAPPER.u_pciess_rp_p0|u_pciess|gen_sub.u_hipif|u_pciess_rx_if|u_pciess_rx_alignment|u_warm_rst_stclk_n_sync|dreg[*]
          set_false_path -from [get_keepers ${pcie_ss_inst}|RP_RTILE_WRAPPER.u_pciess_rp_p0|u_pciess|u_ss_rst_seq|gen_resp_rst_sync[1].resp_rst_sync|dreg[1]] -to ${pcie_ss_inst}|RP_RTILE_WRAPPER.u_pciess_rp_p0|u_pciess|gen_sub.u_hipif|u_pciess_tx_if|pciess_tx_alignment.tx_alignment_inst|axi_st_clk_warm_rst_n|dreg[*]
      }   
   
      if {[regexp "2x8" $top_topology] || [regexp "x4" $top_topology]} {
          set_false_path -from [get_keepers ${pcie_ss_inst}|RP_RTILE_WRAPPER.gen_pciess_rp_p1.u_pciess_rp_p1|u_pciess|u_ss_rst_seq|gen_resp_rst_sync[*].resp_rst_sync|dreg*] -to ${pcie_ss_inst}|RP_RTILE_WRAPPER.gen_pciess_rp_p1.u_pciess_rp_p1|u_pciess|gen_sub.u_hipif|u_pciess*|u_pciess*|*_sync|dreg*
          set_false_path -from [get_keepers ${pcie_ss_inst}|RP_RTILE_WRAPPER.gen_pciess_rp_p1.u_pciess_rp_p1|u_pciess|u_ss_rst_seq|gen_resp_rst_sync[*].resp_rst_sync|dreg*] -to ${pcie_ss_inst}|RP_RTILE_WRAPPER.gen_pciess_rp_p1.u_pciess_rp_p1|u_pciess|gen_sub.u_hipif|u_pciess*|pciess*|*_sync|dreg*
          set_false_path -from [get_keepers ${pcie_ss_inst}|RP_RTILE_WRAPPER.gen_pciess_rp_p1.u_pciess_rp_p1|u_pciess|u_ss_rst_seq|gen_resp_rst_sync[*].resp_rst_sync|dreg*] -to ${pcie_ss_inst}|RP_RTILE_WRAPPER.gen_pciess_rp_p1.u_pciess_rp_p1|u_pciess|gen_sub.u_hipif|u_pciess*|pciess*|*_rst_n|dreg*
          set_false_path -from [get_keepers ${pcie_ss_inst}|RP_RTILE_WRAPPER.gen_pciess_rp_p1.u_pciess_rp_p1|u_pciess|u_ss_rst_seq|gen_resp_rst_sync[*].resp_rst_sync|dreg*] -to ${pcie_ss_inst}|RP_RTILE_WRAPPER.gen_pciess_rp_p1.u_pciess_rp_p1|u_pciess|gen_sub.u_hipif|u_pciess*|*_sync|dreg*
          if {[regexp "Data Mover" $pcie_ss_func_mode]} {
      	set_false_path -from [get_keepers ${pcie_ss_inst}|RP_RTILE_WRAPPER.gen_pciess_rp_p1.u_pciess_rp_p1|u_pciess|u_ss_rst_seq|gen_resp_rst_sync[1].resp_rst_sync|dreg[1]] -to ${pcie_ss_inst}|RP_RTILE_WRAPPER.gen_pciess_rp_p1.u_pciess_rp_p1|u_pciess|gen_sub.u_hipif|u_pciess_cfg_if|u_warm_rst_stclk_n_sync|dreg[*]
      	set_false_path -from [get_keepers ${pcie_ss_inst}|RP_RTILE_WRAPPER.gen_pciess_rp_p1.u_pciess_rp_p1|u_pciess|u_ss_rst_seq|gen_resp_rst_sync[1].resp_rst_sync|dreg[1]] -to ${pcie_ss_inst}|RP_RTILE_WRAPPER.gen_pciess_rp_p1.u_pciess_rp_p1|u_pciess|gen_sub.u_hipif|u_pciess_rx_if|u_pciess_rx_alignment|u_warm_rst_stclk_n_sync|dreg[*]
      	set_false_path -from [get_keepers ${pcie_ss_inst}|RP_RTILE_WRAPPER.gen_pciess_rp_p1.u_pciess_rp_p1|u_pciess|u_ss_rst_seq|gen_resp_rst_sync[1].resp_rst_sync|dreg[1]] -to ${pcie_ss_inst}|RP_RTILE_WRAPPER.gen_pciess_rp_p1.u_pciess_rp_p1|u_pciess|gen_sub.u_hipif|u_pciess_tx_if|pciess_tx_alignment.tx_alignment_inst|axi_st_clk_warm_rst_n|dreg[*]
          } 
      }
   }
}

set current_exe $::TimeQuestInfo(nameofexecutable)

if {$current_exe == "quartus_sta" } {
   if {$TILE == "F-TILE" || $TILE == "P-TILE"} {
      if {[regexp "Native Endpoint" $virtual_rp_ep_mode]} {
         if {[regexp "Data Mover" $pcie_ss_func_mode]} {	
             set_multicycle_path -start -from [get_keepers ${pcie_ss_inst}|EP_PFTILE_WRAPPER.gen_pciess.u_pciess_p0|u_pciess|gen_sub.u_hipif|u_pciess_tx_if|pciess_tx_alignment.tx_alignment_inst|tx_st_rst_st.TX_ST_RST_RDY*] -hold 1
             set_multicycle_path -start -from [get_keepers ${pcie_ss_inst}|EP_PFTILE_WRAPPER.gen_pciess.u_pciess_p0|u_pciess|gen_sub.u_hipif|u_pciess_tx_if|pciess_tx_alignment.tx_alignment_inst|tx_st_rst_st.TX_ST_RST_RDY*] -setup 2
             if {[regexp "2x8" $top_topology] || [regexp "x4" $top_topology]} {
                 set_multicycle_path -start -from [get_keepers ${pcie_ss_inst}|EP_PFTILE_WRAPPER.gen_pciess_p1.u_pciess_p1|u_pciess|gen_sub.u_hipif|u_pciess_tx_if|pciess_tx_alignment.tx_alignment_inst|tx_st_rst_st.TX_ST_RST_RDY*] -hold 1
                 set_multicycle_path -start -from [get_keepers ${pcie_ss_inst}|EP_PFTILE_WRAPPER.gen_pciess_p1.u_pciess_p1|u_pciess|gen_sub.u_hipif|u_pciess_tx_if|pciess_tx_alignment.tx_alignment_inst|tx_st_rst_st.TX_ST_RST_RDY*] -setup 2
             }
         }
      } else {  
         if {[regexp "Data Mover" $pcie_ss_func_mode]} {	
             set_multicycle_path -start -from [get_keepers ${pcie_ss_inst}|RP_PFTILE_WRAPPER.gen_pciess_rp.u_pciess_rp_p0|u_pciess|gen_sub.u_hipif|u_pciess_tx_if|pciess_tx_alignment.tx_alignment_inst|tx_st_rst_st.TX_ST_RST_RDY*] -hold 1
             set_multicycle_path -start -from [get_keepers ${pcie_ss_inst}|RP_PFTILE_WRAPPER.gen_pciess_rp.u_pciess_rp_p0|u_pciess|gen_sub.u_hipif|u_pciess_tx_if|pciess_tx_alignment.tx_alignment_inst|tx_st_rst_st.TX_ST_RST_RDY*] -setup 2
             if {[regexp "2x8" $top_topology] || [regexp "x4" $top_topology]} {
                 set_multicycle_path -start -from [get_keepers ${pcie_ss_inst}|RP_PFTILE_WRAPPER.gen_pciess_rp_p1.u_pciess_rp_p1|u_pciess|gen_sub.u_hipif|u_pciess_tx_if|pciess_tx_alignment.tx_alignment_inst|tx_st_rst_st.TX_ST_RST_RDY*] -hold 1
                 set_multicycle_path -start -from [get_keepers ${pcie_ss_inst}|RP_PFTILE_WRAPPER.gen_pciess_rp_p1.u_pciess_rp_p1|u_pciess|gen_sub.u_hipif|u_pciess_tx_if|pciess_tx_alignment.tx_alignment_inst|tx_st_rst_st.TX_ST_RST_RDY*] -setup 2
             }
         }
      }
   } elseif {$TILE == "R-TILE"} {
      if {[regexp "Native Endpoint" $virtual_rp_ep_mode]} {
         if {[regexp "Data Mover" $pcie_ss_func_mode]} {	
             set_multicycle_path -start -from [get_keepers ${pcie_ss_inst}|EP_RTILE_WRAPPER.u_pciess_p0|u_pciess|gen_sub.u_hipif|u_pciess_tx_if|pciess_tx_alignment.tx_alignment_inst|tx_st_rst_st.TX_ST_RST_RDY*] -hold 1
             set_multicycle_path -start -from [get_keepers ${pcie_ss_inst}|EP_RTILE_WRAPPER.u_pciess_p0|u_pciess|gen_sub.u_hipif|u_pciess_tx_if|pciess_tx_alignment.tx_alignment_inst|tx_st_rst_st.TX_ST_RST_RDY*] -setup 2
             if {[regexp "2x8" $top_topology] || [regexp "x4" $top_topology]} {
                 set_multicycle_path -start -from [get_keepers ${pcie_ss_inst}|EP_RTILE_WRAPPER.gen_pciess_p1.u_pciess_p1|u_pciess|gen_sub.u_hipif|u_pciess_tx_if|pciess_tx_alignment.tx_alignment_inst|tx_st_rst_st.TX_ST_RST_RDY*] -hold 1
                 set_multicycle_path -start -from [get_keepers ${pcie_ss_inst}|EP_RTILE_WRAPPER.gen_pciess_p1.u_pciess_p1|u_pciess|gen_sub.u_hipif|u_pciess_tx_if|pciess_tx_alignment.tx_alignment_inst|tx_st_rst_st.TX_ST_RST_RDY*] -setup 2
             }
         }
      } else {  
         if {[regexp "Data Mover" $pcie_ss_func_mode]} {	
             set_multicycle_path -start -from [get_keepers ${pcie_ss_inst}|RP_RTILE_WRAPPER.u_pciess_rp_p0|u_pciess|gen_sub.u_hipif|u_pciess_tx_if|pciess_tx_alignment.tx_alignment_inst|tx_st_rst_st.TX_ST_RST_RDY*] -hold 1
             set_multicycle_path -start -from [get_keepers ${pcie_ss_inst}|RP_RTILE_WRAPPER.u_pciess_rp_p0|u_pciess|gen_sub.u_hipif|u_pciess_tx_if|pciess_tx_alignment.tx_alignment_inst|tx_st_rst_st.TX_ST_RST_RDY*] -setup 2
             if {[regexp "2x8" $top_topology] || [regexp "x4" $top_topology]} {
                 set_multicycle_path -start -from [get_keepers ${pcie_ss_inst}|RP_RTILE_WRAPPER.gen_pciess_rp_p1.u_pciess_rp_p1|u_pciess|gen_sub.u_hipif|u_pciess_tx_if|pciess_tx_alignment.tx_alignment_inst|tx_st_rst_st.TX_ST_RST_RDY*] -hold 1
                 set_multicycle_path -start -from [get_keepers ${pcie_ss_inst}|RP_RTILE_WRAPPER.gen_pciess_rp_p1.u_pciess_rp_p1|u_pciess|gen_sub.u_hipif|u_pciess_tx_if|pciess_tx_alignment.tx_alignment_inst|tx_st_rst_st.TX_ST_RST_RDY*] -setup 2
             }
         }
      }
   }
}

if {$TILE == "P-TILE"} {
    set_false_path -through ${pcie_ss_inst}|gen_ptile.u_ptile|intel_pcie_ptile_ast_qhip|inst|inst|maib_and_tile|hdpldadapt_tx_chnl_4|rx_pld_rate[*] -to ${pcie_ss_inst}|EP_PFTILE_WRAPPER.gen_pciess.u_pciess_p0|u_pciess|gen_sub.u_hipif|u_pciess_cfg_if|u_pm_dstate_sync|req_wr_clk
    set_false_path -through ${pcie_ss_inst}|gen_ptile.u_ptile|intel_pcie_ptile_ast_qhip|inst|inst|maib_and_tile|hdpldadapt_tx_chnl_4|rx_pld_rate[*] -to ${pcie_ss_inst}|EP_PFTILE_WRAPPER.gen_pciess.u_pciess_p0|u_pciess|gen_sub.u_hipif|u_pciess_cfg_if|u_pm_dstate_sync|data_in_d1[*] 
    set_false_path -from ${pcie_ss_inst}|gen_ptile.u_ptile|intel_pcie_ptile_ast_qhip|inst|inst|maib_and_tile|hdpldadapt_tx_chnl_4~pld_tx_clk1_dcm.reg -to ${pcie_ss_inst}|EP_PFTILE_WRAPPER.gen_pciess.u_pciess_p0|u_pciess|gen_sub.u_hipif|u_pciess_cfg_if|u_pm_dstate_sync|req_wr_clk
    
    set_false_path -from ${pcie_ss_inst}|gen_ptile.u_ptile|intel_pcie_ptile_ast_qhip|inst|inst|maib_and_tile|hdpldadapt_tx_chnl_8~pld_tx_clk1_dcm.reg -to ${pcie_ss_inst}|EP_PFTILE_WRAPPER.gen_pciess.u_pciess_p0|u_pciess|gen_sub.u_hipif|u_pciess_cfg_if|u_pm_dstate_sync|req_wr_clk
    
    if {[regexp "2x8" $top_topology] || [regexp "x4" $top_topology]} {
        set_false_path -through ${pcie_ss_inst}|gen_ptile.u_ptile|intel_pcie_ptile_ast_qhip|inst|inst|maib_and_tile|hdpldadapt_tx_chnl_8|rx_pld_rate[*] -to ${pcie_ss_inst}|EP_PFTILE_WRAPPER.gen_pciess_p1.u_pciess_p1|u_pciess|gen_sub.u_hipif|u_pciess_cfg_if|u_pm_dstate_sync|req_wr_clk
        set_false_path -through ${pcie_ss_inst}|gen_ptile.u_ptile|intel_pcie_ptile_ast_qhip|inst|inst|maib_and_tile|hdpldadapt_tx_chnl_8|rx_pld_rate[*] -to ${pcie_ss_inst}|EP_PFTILE_WRAPPER.gen_pciess_p1.u_pciess_p1|u_pciess|gen_sub.u_hipif|u_pciess_cfg_if|u_pm_dstate_sync|data_in_d1[*]
        set_false_path -from ${pcie_ss_inst}|gen_ptile.u_ptile|intel_pcie_ptile_ast_qhip|inst|inst|maib_and_tile|hdpldadapt_tx_chnl_4~pld_tx_clk1_dcm.reg -to ${pcie_ss_inst}|EP_PFTILE_WRAPPER.gen_pciess_p1.u_pciess_p1|u_pciess|gen_sub.u_hipif|u_pciess_cfg_if|u_pm_dstate_sync|req_wr_clk
    
        set_false_path -from ${pcie_ss_inst}|gen_ptile.u_ptile|intel_pcie_ptile_ast_qhip|inst|inst|maib_and_tile|hdpldadapt_tx_chnl_8~pld_tx_clk1_dcm.reg -to ${pcie_ss_inst}|EP_PFTILE_WRAPPER.gen_pciess_p1.u_pciess_p1|u_pciess|gen_sub.u_hipif|u_pciess_cfg_if|u_pm_dstate_sync|req_wr_clk
    
    }
    
    set_multicycle_path -setup 2  -from ${pcie_ss_inst}|gen_ptile.u_ptile|intel_pcie_ptile_ast_qhip|inst|inst|maib_and_tile|hdpldadapt_rx_chnl_4~pld_rx_clk1_dcm.reg -to ${pcie_ss_inst}|EP_PFTILE_WRAPPER.gen_pciess.u_pciess_p0|u_pciess|gen_sub.u_hipif|u_pciess_cfg_if|u_pm_dstate_sync|req_wr_clk
    set_multicycle_path -hold 1  -from ${pcie_ss_inst}|gen_ptile.u_ptile|intel_pcie_ptile_ast_qhip|inst|inst|maib_and_tile|hdpldadapt_rx_chnl_4~pld_rx_clk1_dcm.reg -to ${pcie_ss_inst}|EP_PFTILE_WRAPPER.gen_pciess.u_pciess_p0|u_pciess|gen_sub.u_hipif|u_pciess_cfg_if|u_pm_dstate_sync|req_wr_clk
    
    set_multicycle_path -setup 2 -from ${pcie_ss_inst}|gen_ptile.u_ptile|intel_pcie_ptile_ast_qhip|inst|inst|maib_and_tile|hdpldadapt_rx_chnl_8~pld_rx_clk1_dcm.reg -to ${pcie_ss_inst}|EP_PFTILE_WRAPPER.gen_pciess.u_pciess_p0|u_pciess|gen_sub.u_hipif|u_pciess_cfg_if|u_pm_dstate_sync|req_wr_clk
    set_multicycle_path -hold 1 -from ${pcie_ss_inst}|gen_ptile.u_ptile|intel_pcie_ptile_ast_qhip|inst|inst|maib_and_tile|hdpldadapt_rx_chnl_8~pld_rx_clk1_dcm.reg -to ${pcie_ss_inst}|EP_PFTILE_WRAPPER.gen_pciess.u_pciess_p0|u_pciess|gen_sub.u_hipif|u_pciess_cfg_if|u_pm_dstate_sync|req_wr_clk
    
    if {[regexp "2x8" $top_topology] || [regexp "x4" $top_topology]} {
            set_multicycle_path -setup 2  -from ${pcie_ss_inst}|gen_ptile.u_ptile|intel_pcie_ptile_ast_qhip|inst|inst|maib_and_tile|hdpldadapt_rx_chnl_4~pld_rx_clk1_dcm.reg -to ${pcie_ss_inst}|EP_PFTILE_WRAPPER.gen_pciess_p1.u_pciess_p1|u_pciess|gen_sub.u_hipif|u_pciess_cfg_if|u_pm_dstate_sync|req_wr_clk
            set_multicycle_path -hold 1  -from ${pcie_ss_inst}|gen_ptile.u_ptile|intel_pcie_ptile_ast_qhip|inst|inst|maib_and_tile|hdpldadapt_rx_chnl_4~pld_rx_clk1_dcm.reg -to ${pcie_ss_inst}|EP_PFTILE_WRAPPER.gen_pciess_p1.u_pciess_p1|u_pciess|gen_sub.u_hipif|u_pciess_cfg_if|u_pm_dstate_sync|req_wr_clk
    
            set_multicycle_path -setup 2 -from ${pcie_ss_inst}|gen_ptile.u_ptile|intel_pcie_ptile_ast_qhip|inst|inst|maib_and_tile|hdpldadapt_rx_chnl_8~pld_rx_clk1_dcm.reg -to ${pcie_ss_inst}|EP_PFTILE_WRAPPER.gen_pciess_p1.u_pciess_p1|u_pciess|gen_sub.u_hipif|u_pciess_cfg_if|u_pm_dstate_sync|req_wr_clk
    	set_multicycle_path -hold 1 -from ${pcie_ss_inst}|gen_ptile.u_ptile|intel_pcie_ptile_ast_qhip|inst|inst|maib_and_tile|hdpldadapt_rx_chnl_8~pld_rx_clk1_dcm.reg -to ${pcie_ss_inst}|EP_PFTILE_WRAPPER.gen_pciess_p1.u_pciess_p1|u_pciess|gen_sub.u_hipif|u_pciess_cfg_if|u_pm_dstate_sync|req_wr_clk
    
    }
} elseif {$TILE == "F-TILE"} {

}


proc apply_sdc_dcfifo {pcie_ss_inst} {
    apply_sdc_dcfifo_rdptr ${pcie_ss_inst}
    apply_sdc_dcfifo_wrptr ${pcie_ss_inst}
}

proc apply_sdc_dcfifo_for_ptrs {from_node_list to_node_list} {
    set_max_skew -from ${from_node_list} -to ${to_node_list} -get_skew_value_from_clock_period src_clock_period -skew_value_multiplier 0.8
    if { ![string equal "quartus_syn" $::TimeQuestInfo(nameofexecutable)] } {
        set_net_delay -from ${from_node_list} -to ${to_node_list} -max -get_value_from_clock_period dst_clock_period -value_multiplier 0.8
    }
    set_max_delay -from ${from_node_list} -to ${to_node_list} 100
    set_min_delay -from ${from_node_list} -to ${to_node_list} -100
}

proc apply_sdc_dcfifo_mstable_delay {from_node_list to_node_list} {
    if { ![string equal "quartus_syn" $::TimeQuestInfo(nameofexecutable)] } {
        set_net_delay -from ${from_node_list} -to ${to_node_list} -max -get_value_from_clock_period dst_clock_period -value_multiplier 0.8
    }
}

proc apply_sdc_dcfifo_rdptr {pcie_ss_inst} {
    set rdptr_from 0
    set rdptr_to 0
    set ws_dgrp_from 0
    set ws_dgrp_to 0

    set rdptr_from_collection [get_keepers -nowarn ${pcie_ss_inst}|auto_generated|*rdptr_g*]
    if {[get_collection_size $rdptr_from_collection] == 0} {
    } else {
        set from_node_list [get_keepers ${pcie_ss_inst}|auto_generated|*rdptr_g*]
        set rdptr_from 1
    }

    set rdptr_to_collection [get_keepers -nowarn ${pcie_ss_inst}|auto_generated|ws_dgrp|dffpipe*|dffe*]
    if {[get_collection_size $rdptr_to_collection] > 0} {
        set to_node_list [get_keepers ${pcie_ss_inst}|auto_generated|ws_dgrp|dffpipe*|dffe*]
        set rdptr_to 1
    }

    if { ${rdptr_from} == 1 && ${rdptr_to} == 1} {
        apply_sdc_dcfifo_for_ptrs ${from_node_list} ${to_node_list}
    }


    set ws_dgrp_from_collection  [get_keepers -nowarn ${pcie_ss_inst}|auto_generated|ws_dgrp|dffpipe*|dffe*]
    if {[get_collection_size $ws_dgrp_from_collection] > 0} {
        set from_node_mstable_list [get_keepers ${pcie_ss_inst}|auto_generated|ws_dgrp|dffpipe*|dffe*]
        set ws_dgrp_from 1
    }

    set ws_dgrp_to_collection [get_keepers -nowarn ${pcie_ss_inst}|auto_generated|ws_dgrp|dffpipe*|dffe*] 
    if {[get_collection_size $ws_dgrp_to_collection] > 0} {
        set to_node_mstable_list [get_keepers ${pcie_ss_inst}|auto_generated|ws_dgrp|dffpipe*|dffe*]
        set ws_dgrp_to 1
    }

    if {${ws_dgrp_from} == 1 && ${ws_dgrp_to} == 1} {
        apply_sdc_dcfifo_mstable_delay ${from_node_mstable_list} ${to_node_mstable_list}
    }

}

proc apply_sdc_dcfifo_wrptr {pcie_ss_inst} {
    set dffe_from 0
    set dffe_to 0
    set delayed_wrptr_g_from 0

    set delayed_wrptr_g_from_collection [get_keepers -nowarn ${pcie_ss_inst}|auto_generated|delayed_wrptr_g*]
    if {[get_collection_size $delayed_wrptr_g_from_collection] > 0} {
        set from_node_list [get_keepers ${pcie_ss_inst}|auto_generated|delayed_wrptr_g*]
        set delayed_wrptr_g_from 1
    }

    set dffe_to_collection [get_keepers -nowarn ${pcie_ss_inst}|auto_generated|rs_dgwp|dffpipe*|dffe*]
    if {[get_collection_size $dffe_to_collection] > 0} {
        set to_node_list [get_keepers ${pcie_ss_inst}|auto_generated|rs_dgwp|dffpipe*|dffe*]
        set dffe_to 1
    }

    if {${delayed_wrptr_g_from} == 1 && ${dffe_to} == 1} {
        apply_sdc_dcfifo_for_ptrs ${from_node_list} ${to_node_list}
    }

    set dffe_to 0

    set from_node_mstable_list_collection [get_keepers -nowarn ${pcie_ss_inst}|auto_generated|rs_dgwp|dffpipe*|dffe*] 
    if {[get_collection_size $from_node_mstable_list_collection] > 0} {
        set from_node_mstable_list [get_keepers ${pcie_ss_inst}|auto_generated|rs_dgwp|dffpipe*|dffe*]
        set dffe_from 1
    }

    set to_node_mstable_list_collection [get_keepers -nowarn ${pcie_ss_inst}|auto_generated|rs_dgwp|dffpipe*|dffe*]
    if {[get_collection_size $to_node_mstable_list_collection] > 0} {
        set to_node_mstable_list [get_keepers ${pcie_ss_inst}|auto_generated|rs_dgwp|dffpipe*|dffe*]
        set dffe_to 1
    }

    if { ${dffe_from} == 1 && ${dffe_to} == 1} {
        apply_sdc_dcfifo_mstable_delay ${from_node_mstable_list} ${to_node_mstable_list}
    }

}


    set inst_list [get_entity_instances dcfifo]

    foreach each_inst ${inst_list} {
        if {$pcie_sdc_debug} {
            post_message -type info "Each dcfifo instance name: ${each_inst}"
        }
        apply_sdc_dcfifo ${each_inst} 

    }


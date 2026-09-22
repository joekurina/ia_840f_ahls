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




##########################################################################################################################################
##  Utility procedures
##########################################################################################################################################
set pcie_sdc_debug 0

# Check if port exists
proc pcie_port_existence {port_name} {
   set port_collection [get_ports -nowarn $port_name]
   if { [get_collection_size $port_collection] > 0 } {
      return 1
   } else {
      return 0
   }
}

# Return existing clock target list
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

proc apply_cdc {from_keep to_keep} {
  if {[llength [query_collection -report -all $from_keep]] > 0 && [llength [query_collection -report -all $to_keep]] > 0} {
    set_max_skew -from $from_keep -to $to_keep -get_skew_value_from_clock_period src_clock_period -skew_value_multiplier 0.8
    if { ![string equal "quartus_syn" $::TimeQuestInfo(nameofexecutable)] } {
      set_net_delay -from $from_keep -to $to_keep -max -get_value_from_clock_period dst_clock_period -value_multiplier 0.8
    }
    set_max_delay -from $from_keep -to $to_keep 50
    set_min_delay -from $from_keep -to $to_keep -50
  }
}

proc apply_cdc_from_to_bit {from_keep to_keep} {
  if {[llength [query_collection -report -all $from_keep]] > 0 && [llength [query_collection -report -all $to_keep]] > 0} {
    set_max_delay -from $from_keep -to $to_keep 50
    set_min_delay -from $from_keep -to $to_keep -50
    if { ![string equal "quartus_syn" $::TimeQuestInfo(nameofexecutable)] } {
      set_net_delay -from $from_keep -to $to_keep -max -get_value_from_clock_period dst_clock_period -value_multiplier 0.8
    }
  }
}

proc apply_cdc_to_bit {to_keep} {
  if {[llength [query_collection -report -all $to_keep]] == 1} {
    set_max_delay -to [get_object_info -name $to_keep] 50
    set_min_delay -to [get_object_info -name $to_keep] -50
    set fanins [get_fanins -no_logic $to_keep]
    foreach_in_collection fanin $fanins {
      if {[llength [query_collection -report -all $fanins]] > 0} {
        if { ![string equal "quartus_syn" $::TimeQuestInfo(nameofexecutable)] } {
           set_net_delay -from [get_object_info -name $fanin] -to [get_object_info -name $to_keep] -max -get_value_from_clock_period dst_clock_period -value_multiplier 0.8
        }
      }
    }
  }
}

#proc apply_cdc_from_to_bit {from_keep to_keep} {
#  if {[llength [query_collection -report -all $from_keep]] > 0 && [llength [query_collection -report -all $to_keep]] > 0} {
#    set_net_delay -from $from_keep -to $to_keep -max -get_value_from_clock_period dst_clock_period -value_multiplier 0.8
#    set_max_delay -from $from_keep -to $to_keep 50
#    set_min_delay -from $from_keep -to $to_keep -50
#  }
#}

proc apply_cdc_sync_vec {from_keep to_keep} {
if {[llength [query_collection -report -all $from_keep]] > 0 && [llength [query_collection -report -all $to_keep]] > 0} {
  if { ![string equal "quartus_syn" $::TimeQuestInfo(nameofexecutable)] } {
    set_net_delay -from $from_keep -to $to_keep -max -get_value_from_clock_period dst_clock_period -value_multiplier 1.5
  }
  set_max_delay -from $from_keep -to $to_keep 50
  set_min_delay -from $from_keep -to $to_keep -50
 }
}

proc apply_cdc_mstable_delay {from_keep to_keep} {
# mstable delay    
  if {[llength [query_collection -report -all $from_keep]] > 0 && [llength [query_collection -report -all $to_keep]] > 0} { 
    set_net_delay -from $from_keep -to $to_keep -max -get_value_from_clock_period dst_clock_period -value_multiplier 0.8 
  }
}


##########################################################################################################################################
##  Main
##########################################################################################################################################
set FAMILY              "Agilex 7"
set clk_source_period    1
set top_topology        "Gen4x16, Interface - 512 bit"

dict set multiply_factor_dict aib_internal_div 1
dict set divide_factor_dict   aib_internal_div 2
dict set multiply_factor_dict clkout 1
dict set divide_factor_dict   clkout 2

if [info exists inst] {
  unset inst
  }
# Get the current Native PCIe IP instance
set inst [get_current_instance]

# Check the tile type
# set native_phy_tile_nodes ""
# set pcie_tile_type H-Tile
#if {$pcie_tile_type == "L-Tile"} {
#  set native_phy_tile_nodes "ct1_xcvr_native_inst|ct1_xcvr_native_inst|inst_ct1_xcvr_channel"
#} else {
#  set native_phy_tile_nodes "ct2_xcvr_native_inst|inst_ct2_xcvr_channel_multi|gen_rev.ct2_xcvr_channel_inst"
#}

# Delete the clock names array if it exists 
if [info exists all_clocks_names] {
  unset all_clocks_names
}
set all_clocks_names [dict create]
#--------------------------------------------- #
#---                                       --- #
#--- CREATE PCIe CLOCKS                    --- #
#---                                       --- #
#--------------------------------------------- #

### Get hierarchical path to handle multiple instance of PCIE ports 
set channel 15
if {[string match $FAMILY "Stratix 10"] == 1 } {
   set aib_rx_clk_source_nodes  [get_nodes     -nowarn   ${inst}*|maib_and_tile|hdpldadapt_rx_chnl_${channel}~aib_rx_clk_source]
   set aib_rx_internal_div_regs [get_registers -nowarn   ${inst}*|maib_and_tile|hdpldadapt_rx_chnl_${channel}~aib_rx_internal_div.reg]
} elseif {[string match $FAMILY "Agilex 7"] == 1 } {
   set aib_rx_clk_source_nodes  [get_nodes     -nowarn ${inst}*|maib_and_tile|*pld_pcs_rx_clk_out_ch${channel}_ref]
   set aib_rx_internal_div_regs [get_registers -nowarn ${inst}*|maib_and_tile|*pld_pcs_rx_clk_out_ch${channel}.reg]
}
  
##### if {[string match $FAMILY "Stratix 10"] == 1 } {
#####    set aib_tx_clk_source_nodes  [get_nodes     -nowarn  ${inst}*|maib_and_tile|hdpldadapt_tx_chnl_0~aib_tx_clk_source]
##### } elseif {[string match $FAMILY "Agilex 7"] == 1 } {
#####    set aib_tx_clk_source_nodes  [get_nodes     -nowarn ${inst}*|maib_and_tile|*pld_pcs_tx_clk_out_ch0_ref]
##### }

if [info exists all_instance_list] {
   unset all_instance_list
}

if {[get_collection_size $aib_rx_clk_source_nodes] >= 1} { 									;# multiple instances
   set source_node_list [query_collection $aib_rx_clk_source_nodes -list_format]
   if {$pcie_sdc_debug == 1} {
      post_message -type info "Source Node: $source_node_list"   	
   }
   foreach node $source_node_list { 											;# store each unique parent to all_clk_parent_list
      set instance_item [join [lrange [split $node {|}] 0 {end-1}] {|}]
      lappend all_instance_list $instance_item
      }
   set instance_list        [lsort -unique $all_instance_list]			;# only unique elements in list
   set instance_list_length [llength $all_instance_list]
}
 

foreach clk_prefix $instance_list {
for { set channel 15 } { $channel < 16 } { incr channel } {

  # ----------------------------------------------------------------------------- #
  # --- Create RX mode clocks and clock frequencies                           --- #
  # ----------------------------------------------------------------------------- #
  ## set aib_rx_clk_source_nodes  [get_nodes -nowarn     altera_xcvr_hip_channel_s10_ch${channel}|altera_xcvr_pcie_hip_channel_s10_ch${channel}|g_xcvr_native_insts[0].${native_phy_tile_nodes}|gen_ct1_hssi_pldadapt_rx.inst_ct1_hssi_pldadapt_rx~aib_rx_clk_source]
  ## set aib_rx_internal_div_regs [get_registers -nowarn altera_xcvr_hip_channel_s10_ch${channel}|altera_xcvr_pcie_hip_channel_s10_ch${channel}|g_xcvr_native_insts[0].${native_phy_tile_nodes}|gen_ct1_hssi_pldadapt_rx.inst_ct1_hssi_pldadapt_rx~aib_rx_internal_div.reg]
  
  if {[string match $FAMILY "Stratix 10"] == 1 } {
     set aib_rx_clk_source_nodes  [get_nodes     -nowarn ${clk_prefix}|hdpldadapt_rx_chnl_${channel}~aib_rx_clk_source]
     set aib_rx_internal_div_regs [get_registers -nowarn ${clk_prefix}|hdpldadapt_rx_chnl_${channel}~aib_rx_internal_div.reg]
  } elseif {[string match $FAMILY "Agilex 7"] == 1 } {
     set aib_rx_clk_source_nodes  [get_nodes     -nowarn ${clk_prefix}|*pld_pcs_rx_clk_out_ch${channel}_ref]
     set aib_rx_internal_div_regs [get_registers -nowarn ${clk_prefix}|*pld_pcs_rx_clk_out_ch${channel}.reg]
  }
  
  if {[get_collection_size $aib_rx_clk_source_nodes] > 0 } {

    # -------------------------------------------------------------------------------
    # AIB RX CLK SOURCE - PMA parallel clock
    # -------------------------------------------------------------------------------
    foreach_in_collection rx_clk_source $aib_rx_clk_source_nodes {

      # Remove the instance name from the clock source node due to auto promotion in SDC_ENTITY
      # set no_inst_rx_clk_source [string replace [get_node_info -name $rx_clk_source] 0 [string length $inst]]
      set no_inst_rx_clk_source [get_node_info -name $rx_clk_source]

      # set clk_prefix [join [lrange [split $no_inst_rx_clk_source {|}] 0 {end-1}] {|}]
	  set rx_clk_source_name ${clk_prefix}|rx_pma_parallel_clk|ch${channel}
	  
	  
	  if {$pcie_sdc_debug == 1} {
 	     post_message -type info "Clock Prefix: $clk_prefix"
	     post_message -type info "RX Clock Source: $rx_clk_source"
	     post_message -type info "RX Clock Source (No Instance Name): $no_inst_rx_clk_source"
	      
	     post_message -type info "RX Clock Source Name: $rx_clk_source_name "
      }

      if {[get_collection_size [get_clocks -nowarn $rx_clk_source_name]] == 0} {

      # Create the RX PMA parallel clock name
#      set rx_clk_source_name $inst|rx_pma_parallel_clk|ch${channel}
#      set rx_clk_source_name_bonded $inst|rx_pma_parallel_clk|ch15

      create_clock \
        -name $rx_clk_source_name \
        -period $clk_source_period \
        $no_inst_rx_clk_source -add

      dict lappend all_clocks_names rx_source_clks $rx_clk_source_name

      # -------------------------------------------------------------------------------
      # AIB RX INTERNAL DIV REG - transfer clock
      # -------------------------------------------------------------------------------

      foreach_in_collection rx_internal_div_reg $aib_rx_internal_div_regs {

        # Remove the instance name from the internal div reg node due to auto promotion in SDC_ENTITY
        # set no_inst_rx_internal_div_reg [string replace [get_node_info -name $rx_internal_div_reg] 0 [string length $inst]]
	    set no_inst_rx_internal_div_reg [get_node_info -name $rx_internal_div_reg]
	    

        # Create the rX PCS x2 clock name
        # set rx_internal_div_reg_name $inst|rx_pcs_x2_clk|ch${channel}
        set rx_internal_div_reg_name ${clk_prefix}|rx_pcs_x2_clk|ch${channel}
        if {$pcie_sdc_debug == 1} {
           post_message -type info "RX Internal Div Reg Name: $rx_internal_div_reg_name "
        }

        create_generated_clock \
          -name $rx_internal_div_reg_name \
          -source $no_inst_rx_clk_source \
          -master_clock $rx_clk_source_name \
          -multiply_by [dict get $multiply_factor_dict aib_internal_div] \
          -divide_by   [dict get $divide_factor_dict   aib_internal_div] \
          $no_inst_rx_internal_div_reg -add

        # -------------------------------------------------------------------------------
        # RX CLKOUT
        # -------------------------------------------------------------------------------
		
        #set pld_pcs_rx_clkout_pins [get_pins -nowarn -compat altera_xcvr_hip_channel_s10_ch${channel}|altera_xcvr_pcie_hip_channel_s10_ch${channel}|g_xcvr_native_insts[0].${native_phy_tile_nodes}|gen_ct1_hssi_pldadapt_rx.inst_ct1_hssi_pldadapt_rx|pld_pcs_rx_clk_out1_dcm]
    
	   if {[string match $FAMILY "Agilex 7"] == 1 } {
	    set pld_pcs_rx_clkout_pins [get_pins -nowarn -compat ${clk_prefix}|hdpldadapt_rx_chnl_${channel}|pld_pcs_rx_clk_out1_dcm]

        if {[get_collection_size $pld_pcs_rx_clkout_pins] > 0} {

          foreach_in_collection rx_clkout $pld_pcs_rx_clkout_pins {

            # Remove the instance name from the output clock node due to auto promotion in SDC_ENTITY
            # set no_inst_rx_clkout [string replace [get_node_info -name $rx_clkout] 0 [string length $inst]]
	        set no_inst_rx_clkout [get_node_info -name $rx_clkout]
            set rx_xcvr_hip_native_name ${clk_prefix}|xcvr_hip_native|rx_ch${channel}
            if {$pcie_sdc_debug == 1} {
	           post_message -type info "RX XCVR HIP Native Name: $rx_xcvr_hip_native_name "
	        }

            #TimeQuest has issue with the below	    
            create_generated_clock \
              -name  $rx_xcvr_hip_native_name \
              -source $no_inst_rx_internal_div_reg \
              -master_clock $rx_internal_div_reg_name \
              -multiply_by 1 \
              -divide_by   1 \
              $no_inst_rx_clkout -add	    
	   
            if {$pcie_sdc_debug == 1} {
               post_message -type info "RX Clock Source: $no_inst_rx_clk_source"
	           post_message -type info "RX Internal Div Reg: $no_inst_rx_internal_div_reg"
	           post_message -type info "RX Clockout: $no_inst_rx_clkout"
            }
###             create_generated_clock 
###               -name  $inst|xcvr_hip_native|ch${channel} 
### 	      -source $no_inst_rx_internal_div_reg 
###               -master_clock $rx_internal_div_reg_name 
###               -multiply_by 1 
###               -divide_by   1 
###               $no_inst_rx_clkout -add
###           create_generated_clock 
###             -name  $inst|xcvr_hip_native|ch${channel} 
###	          -source $no_inst_rx_clk_source 
###             -master_clock $rx_clk_source_name 
###             -multiply_by [dict get $multiply_factor_dict clkout] 
###             -divide_by   [dict get $divide_factor_dict   clkout] 
###             $no_inst_rx_clkout -add
###
          }
        }
        };  #if {[string match $FAMILY "Agilex 7"] == 1 }

###  set clk_prefix "dut|dut|ast|inst|inst|maib_and_tile"
         set ast_hier_prefix [join [lrange [split $clk_prefix {|}] 0 {end-3}] {|}]
         #   dut|dut|ast
         ## puts $ast_hier_prefix  
         set dcoren_prefix [join [lrange [split $ast_hier_prefix {|}] 0 {end-1}] {|}]
         #   dut|dut 
         ## puts $dcoren_prefix  

##########################################################################################################################################
# warm reset delay clock
# to be handled later
##########################################################################################################################################
####     set warm_rst_dly_col   [get_registers $ast_hier_prefix|soft_logics|rst_ctrl|p*_warm_rst_delay|count[7]]
####   
####     if { [get_collection_size $warm_rst_dly_col] >= 1 } {
####       set name "div_256_clk"
####       set warm_rst_dly_list  [query_collection $warm_rst_dly_col -list_format]
####       foreach myreg $warm_rst_dly_list {
####         ## puts "Inside foreach $myreg"
####         set div_256_hier [join [lrange [split $myreg {|}] 0 {end-1}] {|}]
####         set div_256_clk_name $div_256_hier$name
####         ## puts "Before create generated clock"
####         create_generated_clock \
####         -name $div_256_clk_name \
####         -source $hip_coreclk_node \
####         -divide_by 256 \
####         $myreg 
####       }
####     } 

        ########################################################################################################################
        ##  G4x4 - 128 bit (AVMM)
        ########################################################################################################################
        if {[string match $top_topology "Gen4x4, Interface - 128 bit"] == 1 } {
        
        ########################################################################################################################
        ## synchronization of pll lock to clk and clk250 domain
        ## Lock source name below is for Agilex only
        ########################################################################################################################
          set lock_source_name "$dcoren_prefix*ennm_pll~pll_e_reg__nff"
          set e_reg__nff_col [get_keepers -nowarn $lock_source_name]
          foreach_in_collection my $e_reg__nff_col {
            set from_keep [get_keepers [get_object_info -name $my]]
            set nff_fanout_col [get_fanouts $from_keep]
            if {[get_collection_size $nff_fanout_col] >= 1 } {
              foreach_in_collection fnout $nff_fanout_col {
                set to_keep [get_keepers [get_object_info -name $fnout]]
                apply_cdc_from_to_bit $from_keep $to_keep
          
                set to_keep_fan_col [get_fanouts $to_keep]
                if {[get_collection_size $to_keep_fan_col] >= 1} {
                  foreach_in_collection to_keep_fan $to_keep_fan_col {
                    set to_keep_r2 [get_keepers [get_object_info -name $to_keep_fan]]
                    apply_cdc_mstable_delay $to_keep $to_keep_r2
                  }
                }
              }
            }
          }
        ########################################################################################################################
        ## adapter_cfg clock crossing
        ########################################################################################################################
          for { set di 0 } { $di < 4 } { incr di } {
              # set from_keep_src [get_keepers "$dcoren_prefix|dcore${di}|temp_name|adapter_cfg|free_run_valid*"]
              # set from_keep_dup [get_keepers "$dcoren_prefix|dcore${di}|temp_name|adapter_cfg|free_run_valid*DUP*"]
              # set from_keep_ss  [get_keepers "$dcoren_prefix|dcore${di}|temp_name|adapter_cfg|free_run_valid*ss*"]
              # set from_keep_no_dup [remove_from_collection $from_keep_src $from_keep_dup]
              # set from_keep   [remove_from_collection $from_keep_no_dup $from_keep_ss]
              set from_keep     [get_keepers -nowarn "$dcoren_prefix|dcore${di}|temp_name|adapter_cfg|free_run_valid*"]
              set keep_r1       [get_keepers -nowarn "$dcoren_prefix|dcore${di}|temp_name|adapter_cfg|u_free_valid_sync|sync_regs_s1*"]
              if {[get_collection_size $from_keep] > 0  && [get_collection_size $keep_r1] > 0} {
                apply_cdc $from_keep $keep_r1
              }
              
              set keep_r2 [get_keepers -nowarn "$dcoren_prefix|dcore${di}|temp_name|adapter_cfg|u_free_valid_sync|sync_regs_s2*"]
              if {[get_collection_size $keep_r1] > 0  && [get_collection_size $keep_r2] > 0} {
                apply_cdc_mstable_delay $keep_r1 $keep_r2
              }
        
            ## puts "Done free_!! for dcore: $di"
            for { set i 0 } { $i < 4 } { incr i } {
              set from_keep [get_keepers -nowarn "$dcoren_prefix|dcore${di}|temp_name|adapter_cfg|fifo_wdata${i}*"]
              set keep_r1   [get_keepers -nowarn "$dcoren_prefix|dcore${di}|temp_name|adapter_cfg|fifo_rdata${i}*"]
              if {[get_collection_size $from_keep] > 0  && [get_collection_size $keep_r1] > 0} {
                apply_cdc $from_keep $keep_r1
                ## puts "Done _cdc for dcore $di, data index $i"      
              }

              if {[get_collection_size $keep_r1] > 0} {
                set keep_r2 [get_fanouts -no_logic "$dcoren_prefix|dcore${di}|temp_name|adapter_cfg|fifo_rdata${i}*"]
                if {[get_collection_size $keep_r2] > 0} {
                  apply_cdc_mstable_delay $keep_r1 $keep_r2
                  ## puts "Done _cdc_mstable for dcore $di, data index $i"
                } 
              }
            }
          }
        
        ########################################################################################################################
        ## Recovery handling due to reset status used a async reset
        ########################################################################################################################
          for { set di 0 } { $di < 4 } { incr di } {     
            set from_keep [get_keepers -nowarn "${inst}*|soft_logics|rst_ctrl|p${di}_rst_tree|reset_status_tree[0]"]
            set to_keep   [get_keepers -nowarn "*|dcore${di}|reset_sync|din_s1"]
            if {[get_collection_size $from_keep] > 0  && [get_collection_size $to_keep] > 0}  {
              apply_cdc_from_to_bit $from_keep $to_keep
            }
        
            set to_keep1   [get_keepers -nowarn "*|dcore${di}|reset_sync|dreg[0]"]
            if {[get_collection_size $from_keep] > 0  && [get_collection_size $to_keep1] > 0}  {
              apply_cdc_from_to_bit $from_keep $to_keep1
            }  
            if {[get_collection_size $to_keep] > 0 && [get_collection_size $to_keep1] > 0}  {
              apply_cdc_mstable_delay $to_keep $to_keep1
            }
        
            set to_keep2   [get_keepers -nowarn "*|dcore${di}|reset_sync|dreg[1]"]
            if {[get_collection_size $from_keep] > 0  && [get_collection_size $to_keep2] > 0}  {
              apply_cdc_from_to_bit $from_keep $to_keep2
            }
          }
        
        }

      }; #foreach in collection aib_rx_internal_div_regs
    }; # foreach in collection aib_rx_clk_source_nodes
  }; # if get_collection_size aib_rx_clk_source_nodes && aib_rx_internal_div_regs
}


###   Cannot find aib_reset_out_stage so ignore for now
###   #--------------------------------------------- #
###   #---                                       --- #
###   #--- MIN & MAX DELAYS FOR RESETS           --- #
###   #---                                       --- #
###   #--------------------------------------------- #
###   set rx_digital_aib_reset_reg   [get_registers -nowarn    altera_xcvr_pcie_hip_native_rx_aib_reset_seq|aib_reset_out_stage*]
###   set rx_pld_adapter_reset_atom  [get_pins -compat -nowarn altera_xcvr_hip_channel_s10_ch${channel}|altera_xcvr_pcie_hip_channel_s10_ch${channel}|g_xcvr_native_insts[0].${native_phy_tile_nodes}|gen_ct1_hssi_pldadapt_rx.inst_ct1_hssi_pldadapt_rx|pld_adapter_rx_pld_rst_n]
###   set rx_pld_adapter_reset_pins  [get_pins -compat -nowarn altera_xcvr_hip_channel_s10_ch${channel}|altera_xcvr_pcie_hip_channel_s10_ch${channel}|g_xcvr_native_insts[0].${native_phy_tile_nodes}|gen_ct1_hssi_pldadapt_rx.inst_ct1_hssi_pldadapt_rx|pld_adapter_rx_pld_rst_n*]
###   set rx_pld_dll_lock_req_atom   [get_pins -compat -nowarn altera_xcvr_hip_channel_s10_ch${channel}|altera_xcvr_pcie_hip_channel_s10_ch${channel}|g_xcvr_native_insts[0].${native_phy_tile_nodes}|gen_ct1_hssi_pldadapt_rx.inst_ct1_hssi_pldadapt_rx|pld_rx_dll_lock_req]
###   set rx_pld_dll_lock_req_pins   [get_pins -compat -nowarn altera_xcvr_hip_channel_s10_ch${channel}|altera_xcvr_pcie_hip_channel_s10_ch${channel}|g_xcvr_native_insts[0].${native_phy_tile_nodes}|gen_ct1_hssi_pldadapt_rx.inst_ct1_hssi_pldadapt_rx|pld_rx_dll_lock_req*]
### 
###   if {[get_collection_size $rx_digital_aib_reset_reg] > 0 && [get_collection_size $rx_pld_adapter_reset_atom] > 0 && [get_collection_size $rx_pld_adapter_reset_pins] > 0} {
###     set_max_delay -from $rx_digital_aib_reset_reg -through $rx_pld_adapter_reset_atom -to $rx_pld_adapter_reset_pins 200
###     set_min_delay -from $rx_digital_aib_reset_reg -through $rx_pld_adapter_reset_atom -to $rx_pld_adapter_reset_pins -5
###   }
### 
###   if {[get_collection_size $rx_digital_aib_reset_reg] > 0 && [get_collection_size $rx_pld_dll_lock_req_atom] > 0 && [get_collection_size $rx_pld_dll_lock_req_pins] > 0} {
###     set_max_delay -from $rx_digital_aib_reset_reg -through $rx_pld_dll_lock_req_atom -to $rx_pld_dll_lock_req_pins 200
###     set_min_delay -from $rx_digital_aib_reset_reg -through $rx_pld_dll_lock_req_atom -to $rx_pld_dll_lock_req_pins -5
###   }
### 
###   set tx_digital_aib_reset_reg   [get_registers -nowarn    altera_xcvr_pcie_hip_native_tx_aib_reset_seq|aib_reset_out_stage*]
###   set tx_pld_adapter_reset_atom  [get_pins -compat -nowarn altera_xcvr_hip_channel_s10_ch${channel}|altera_xcvr_pcie_hip_channel_s10_ch${channel}|g_xcvr_native_insts[0].${native_phy_tile_nodes}|gen_ct1_hssi_pldadapt_tx.inst_ct1_hssi_pldadapt_tx|pld_adapter_tx_pld_rst_n]
###   set tx_pld_adapter_reset_pins  [get_pins -compat -nowarn altera_xcvr_hip_channel_s10_ch${channel}|altera_xcvr_pcie_hip_channel_s10_ch${channel}|g_xcvr_native_insts[0].${native_phy_tile_nodes}|gen_ct1_hssi_pldadapt_tx.inst_ct1_hssi_pldadapt_tx|pld_adapter_tx_pld_rst_n*]
###   set tx_pld_dll_lock_req_atom   [get_pins -compat -nowarn altera_xcvr_hip_channel_s10_ch${channel}|altera_xcvr_pcie_hip_channel_s10_ch${channel}|g_xcvr_native_insts[0].${native_phy_tile_nodes}|gen_ct1_hssi_pldadapt_tx.inst_ct1_hssi_pldadapt_tx|pld_tx_dll_lock_req]
###   set tx_pld_dll_lock_req_pins   [get_pins -compat -nowarn altera_xcvr_hip_channel_s10_ch${channel}|altera_xcvr_pcie_hip_channel_s10_ch${channel}|g_xcvr_native_insts[0].${native_phy_tile_nodes}|gen_ct1_hssi_pldadapt_tx.inst_ct1_hssi_pldadapt_tx|pld_tx_dll_lock_req*]
### 
###   if {[get_collection_size $tx_digital_aib_reset_reg] > 0 && [get_collection_size $tx_pld_adapter_reset_atom] > 0 && [get_collection_size $tx_pld_adapter_reset_pins] > 0} {
###     set_max_delay -from $tx_digital_aib_reset_reg -through $tx_pld_adapter_reset_atom -to $tx_pld_adapter_reset_pins 200
###     set_min_delay -from $tx_digital_aib_reset_reg -through $tx_pld_adapter_reset_atom -to $tx_pld_adapter_reset_pins -5
###   }
### 
###   if {[get_collection_size $tx_digital_aib_reset_reg] > 0 && [get_collection_size $tx_pld_dll_lock_req_atom] > 0 && [get_collection_size $tx_pld_dll_lock_req_pins] > 0} {
###     set_max_delay -from $tx_digital_aib_reset_reg -through $tx_pld_dll_lock_req_atom -to $tx_pld_dll_lock_req_pins 200
###     set_min_delay -from $tx_digital_aib_reset_reg -through $tx_pld_dll_lock_req_atom -to $tx_pld_dll_lock_req_pins -5
###   }
 
   #-------------------------------------------------- #
   #---                                            --- #
   #--- Internal loopback path                     --- #
   #---                                            --- #
   #-------------------------------------------------- #
   #  Below is for WHR
   set pld_tx_clk2_dcm_reg_col        [get_registers    -nowarn ${clk_prefix}|hdpldadapt_rx_chnl_${channel}~pld_tx_clk2_dcm.reg]
   set aib_fabric_tx_data_lpbk_col    [get_pins -compat -nowarn ${clk_prefix}|hdpldadapt_rx_chnl_${channel}|aib_fabric_tx_data_lpbk*] 
   set aib_fabric_rx_transfer_clk_col [get_registers    -nowarn ${clk_prefix}|hdpldadapt_rx_chnl_${channel}~aib_fabric_rx_transfer_clk.reg]
   set aib_fabric_pma_aib_tx_clk_col  [get_registers    -nowarn ${clk_prefix}|hdpldadapt_tx_chnl_${channel}~aib_fabric_pma_aib_tx_clk.reg]
   set pld_tx_clk1_dcm_reg_col        [get_registers    -nowarn ${clk_prefix}|hdpldadapt_tx_chnl_${channel}~pld_tx_clk1_dcm.reg]
   set pcie_src_tx_pld_rst_n_r15      [get_registers -nowarn *|inst|inst|hip_aib_ch15_pld_adapter_tx_pld_rst_n]
   set aib_fabric_rx_transfer_clk_col2   [get_registers -nowarn *|maib_and_tile|hdpldadapt_rx_chnl_15~aib_fabric_rx_transfer_clk.reg]
 
   # Cut paths for internal loopback paths when bonding is enabled
   if {[get_collection_size $pld_tx_clk2_dcm_reg_col] > 0 && [get_collection_size $aib_fabric_tx_data_lpbk_col] > 0 && [get_collection_size $aib_fabric_rx_transfer_clk_col] > 0} {
     set_false_path -from $pld_tx_clk2_dcm_reg_col -through $aib_fabric_tx_data_lpbk_col -to $aib_fabric_rx_transfer_clk_col
   }
 
   # Cut the paths for the internal loopback paths
   if {[get_collection_size $aib_fabric_pma_aib_tx_clk_col] > 0 && [get_collection_size $aib_fabric_tx_data_lpbk_col] > 0 && [get_collection_size $aib_fabric_rx_transfer_clk_col] > 0} {
     set_false_path -from $aib_fabric_pma_aib_tx_clk_col -through $aib_fabric_tx_data_lpbk_col -to $aib_fabric_rx_transfer_clk_col
   }
   if {[get_collection_size $pld_tx_clk1_dcm_reg_col] > 0 && [get_collection_size $aib_fabric_tx_data_lpbk_col] > 0 && [get_collection_size $aib_fabric_rx_transfer_clk_col] > 0} {
     set_false_path -from $pld_tx_clk1_dcm_reg_col -through $aib_fabric_tx_data_lpbk_col -to $aib_fabric_rx_transfer_clk_col
   }
 # this is not a register, confirm with PSWE team
# set_false_path -from [get_keepers ${inst}*|soft_logics|rst_ctrl|pld_adapter_rx_pld_rst_n_r_ch[15]] -to [get_keepers ${inst}*|maib_and_tile|hdpldadapt_rx_chnl_15~aib_fabric_rx_transfer_clk.reg]
   if {[get_collection_size $pcie_src_tx_pld_rst_n_r15] > 0 && [get_collection_size $aib_fabric_rx_transfer_clk_col2] > 0} {
		set_false_path -from [get_keepers *|inst|inst|hip_aib_ch15_pld_adapter_tx_pld_rst_n] -to [get_keepers *|maib_and_tile|hdpldadapt_rx_chnl_15~aib_fabric_rx_transfer_clk.reg]
   }

}; # for channel


###  Cut path between rx_pcs_x2_clk and its neighbor channels
###  Cut path between tx_transfer_clkX and its neighbor channels
###   for { set channels 15 } { $channels < 16 } { incr channels } {
###      if {$channels == 0} { 
###         set channels_up [expr $channels + 1]
###         set_false_path -from ${clk_prefix}|rx_pcs_x2_clk|ch${channels} -to ${clk_prefix}|rx_pcs_x2_clk|ch${channels_up} 
###         set_false_path -from ${clk_prefix}|tx_pcs_x2_clk|ch${channels} -to ${clk_prefix}|tx_pcs_x2_clk|ch${channels_up}
###      }  elseif { $channels == 23 } {
###         set channels_down [expr $channels - 1]
###         set_false_path -from ${clk_prefix}|rx_pcs_x2_clk|ch${channels} -to ${clk_prefix}|rx_pcs_x2_clk|ch${channels_down}
###         set_false_path -from ${clk_prefix}|tx_pcs_x2_clk|ch${channels} -to ${clk_prefix}|tx_pcs_x2_clk|ch${channels_down}
###      }  else {
###         set channels_up [expr $channels + 1]
###         set channels_down [expr $channels - 1]
###         set_false_path -from ${clk_prefix}|rx_pcs_x2_clk|ch${channels} -to ${clk_prefix}|rx_pcs_x2_clk|ch${channels_down}
###         set_false_path -from ${clk_prefix}|rx_pcs_x2_clk|ch${channels} -to ${clk_prefix}|rx_pcs_x2_clk|ch${channels_up} 
###         set_false_path -from ${clk_prefix}|tx_pcs_x2_clk|ch${channels} -to ${clk_prefix}|tx_pcs_x2_clk|ch${channels_down}
###         set_false_path -from ${clk_prefix}|tx_pcs_x2_clk|ch${channels} -to ${clk_prefix}|tx_pcs_x2_clk|ch${channels_up} 
###      }
###	  
###	  if {$channels !=15} {
###	     set_false_path -from ${clk_prefix}|xcvr_hip_native|rx_ch15 -to ${clk_prefix}|rx_pcs_x2_clk|ch${channels}
###	     set_false_path -from ${clk_prefix}|xcvr_hip_native|rx_ch15 -to ${clk_prefix}|tx_pcs_x2_clk|ch${channels}
###	  }	  
###   }

#   for { set channels 15 } { $channels < 16 } { incr channels } {
#      if {[string match $FAMILY "Stratix 10"] == 1 } {
#         set rx_modeled_clock_node_name [get_node_info -name [get_nodes ${clk_prefix}|hdpldadapt_rx_chnl_${channels}~aib_rx_internal_div]]
#         # set hclk_internal_div_col [get_nodes ${clk_prefix}|hdpldadapt_rx_chnl_${channels}~aib_hclk_internal_div]
#         # if {[get_collection_size $hclk_internal_div_col] >0 } {
#         #   set rx_hclk_internal_div_node  [get_node_info -name $hclk_internal_div_col]
#         #   disable_min_pulse_width $rx_hclk_internal_div_node
#         #}
	 
#      } elseif {[string match $FAMILY "Agilex 7"] == 1 } { 
#        set rx_modeled_clock_node_name [get_node_info -name [get_nodes ${clk_prefix}|*pld_pcs_rx_clk_out_ch${channels}]]
#      }
#     
#   }
   disable_min_pulse_width $rx_clk_source_name

} ;# for instance_list

### 
### 
### #-------------------------------------------------- #
### #---                                            --- #
### #--- Adjusting the min pulse width for          --- #
### #--- coreclkin2 requirement to be               --- #
### #--- frequency-dependent                        --- #
### #---                                            --- #
### #-------------------------------------------------- #
###   
### # Create dictionary of all the clocks and their nodes
### set min_pulse_all_clocks_list [get_clock_list]
### set min_pulse_all_clocks_nodes_dict [dict create]
### 
### foreach clk_name $min_pulse_all_clocks_list {
###   set clk_node_col [get_clock_info -targets $clk_name]
###       
###   foreach_in_collection clk_node $clk_node_col {
###     set clk_node_name [get_node_info -name $clk_node]
###     dict set min_pulse_all_clocks_nodes_dict $clk_node_name $clk_name
###   }
### }

### Comment this out for now
## for { set channel 0 } { $channel < 24 } { incr channel } {
##    if {[string match $FAMILY "Stratix 10"] == 1 } {
##       set rx_modeled_clock_node_name [get_node_info -name [get_nodes ${inst}*|maib_and_tile|hdpldadapt_rx_chnl_${channel}~aib_rx_internal_div]]
##       set tx_modeled_clock_node_name [get_node_info -name [get_nodes ${inst}*|maib_and_tile|hdpldadapt_tx_chnl_${channel}~aib_tx_internal_div]]
##    } elseif {[string match $FAMILY "Agilex 7"] == 1 } { 
##      set rx_modeled_clock_node_name [get_node_info -name [get_nodes ${inst}*|maib_and_tile|*pld_pcs_rx_clk_out_ch${channel}]]
##      set tx_modeled_clock_node_name [get_node_info -name [get_nodes ${inst}*|maib_and_tile|*pld_pcs_tx_clk_out_ch${channel}]]
##    }
## 
##    # RX pld_pcs_rx_clk_out_ch 15 is coreclkout_hip
##    # The same clock on other channel are not used      
##    if { $channel !=15 } {
##        disable_min_pulse_width $rx_modeled_clock_node_name
##    }
##    # None of the TX pld_pcs_rx_clk_out_ch are used 
##    disable_min_pulse_width $tx_modeled_clock_node_name
## }

set pcie_clock_target_list [pcie_get_clock_target_list]

set pcie_refclk0_ext  [pcie_port_existence refclk0]
set pcie_refclk0_lsrc [lsearch -exact $pcie_clock_target_list refclk0]
set pcie_refclk0_clk_ext  [pcie_port_existence refclk0_clk]
set pcie_refclk0_clk_lsrc [lsearch -exact $pcie_clock_target_list refclk0_clk]
if {$pcie_refclk0_ext && $pcie_refclk0_lsrc == -1} {
   create_clock -period 10 -name refclk0 refclk0
} elseif {$pcie_refclk0_clk_ext && $pcie_refclk0_clk_lsrc == -1} {
   create_clock -period 10 -name refclk0 refclk0_clk
}

set pcie_refclk1_ext  [pcie_port_existence refclk1]
set pcie_refclk1_lsrc [lsearch -exact $pcie_clock_target_list refclk1]
set pcie_refclk1_clk_ext  [pcie_port_existence refclk1_clk]
set pcie_refclk1_clk_lsrc [lsearch -exact $pcie_clock_target_list refclk1_clk]
if {$pcie_refclk1_ext && $pcie_refclk1_lsrc == -1} {
   create_clock -period 10 -name refclk1 refclk1
} elseif {$pcie_refclk1_clk_ext && $pcie_refclk1_clk_lsrc == -1} {
   create_clock -period 10 -name refclk1 refclk1_clk
}

# create refclk for reconfig interface
set pcie_p0_hip_reconfig_clk_ext  [pcie_port_existence p0_hip_reconfig_clk]
set pcie_p0_hip_reconfig_clk_lsrc [lsearch -exact $pcie_clock_target_list p0_hip_reconfig_clk]
if {$pcie_p0_hip_reconfig_clk_ext && $pcie_p0_hip_reconfig_clk_lsrc == -1} {
   create_clock -period 10 -name p0_hip_reconfig_clk p0_hip_reconfig_clk
}


# create AVMM clock for completion timeout interface
# create completion timeout clock
set pcie_p0_cpl_to_clk_ext  [pcie_port_existence p0_cpl_timeout_avmm_clk_i]
set pcie_p0_cpl_to_clk_lsrc [lsearch -exact $pcie_clock_target_list p0_cpl_timeout_avmm_clk_i]
if {$pcie_p0_cpl_to_clk_ext && $pcie_p0_cpl_to_clk_lsrc == -1} {
   create_clock -period 10 -name p0_cpl_timeout_avmm_clk_i p0_cpl_timeout_avmm_clk_i
}
# create completion timeout clock
set pcie_p1_cpl_to_clk_ext  [pcie_port_existence p1_cpl_timeout_avmm_clk_i]
set pcie_p1_cpl_to_clk_lsrc [lsearch -exact $pcie_clock_target_list p1_cpl_timeout_avmm_clk_i]
if {$pcie_p1_cpl_to_clk_ext && $pcie_p1_cpl_to_clk_lsrc == -1} {
   create_clock -period 10 -name p1_cpl_timeout_avmm_clk_i p1_cpl_timeout_avmm_clk_i
}
# create completion timeout clock
set pcie_p2_cpl_to_clk_ext  [pcie_port_existence p2_cpl_timeout_avmm_clk_i]
set pcie_p2_cpl_to_clk_lsrc [lsearch -exact $pcie_clock_target_list p2_cpl_timeout_avmm_clk_i]
if {$pcie_p2_cpl_to_clk_ext && $pcie_p2_cpl_to_clk_lsrc == -1} {
   create_clock -period 10 -name p2_cpl_timeout_avmm_clk_i p2_cpl_timeout_avmm_clk_i
}
# create completion timeout clock
set pcie_p3_cpl_to_clk_ext  [pcie_port_existence p3_cpl_timeout_avmm_clk_i]
set pcie_p3_cpl_to_clk_lsrc [lsearch -exact $pcie_clock_target_list p3_cpl_timeout_avmm_clk_i]
if {$pcie_p3_cpl_to_clk_ext && $pcie_p3_cpl_to_clk_lsrc == -1} {
   create_clock -period 10 -name p3_cpl_timeout_avmm_clk_i p3_cpl_timeout_avmm_clk_i
}



#######################################################################
################# Set false path for synchronizer #####################


# core16_hip_reconfig
# Sync reset_status_n to AVMM clock
set_false_path -to [get_registers -nowarn ${inst}*|soft_logics|g_p0_hip_rcfg_avmm_reset_status_n_sync.p0_avmm_reset_status_n_sync_inst|din_s1]
set_false_path -through [get_pins -nowarn ${inst}*|soft_logics|g_p0_hip_rcfg_avmm_reset_status_n_sync.p0_avmm_reset_status_n_sync_inst|dreg[*]|clrn] -to [get_registers -nowarn ${inst}*|soft_logics|g_p0_hip_rcfg_avmm_reset_status_n_sync.p0_avmm_reset_status_n_sync_inst|dreg[*]]

# Sync link_req_rst to AVMM clock
set_false_path -to [get_registers -nowarn ${inst}*|soft_logics|pcie0_user_avmm_adpt|p0_link_req_rst_sync|din_s1]
set_false_path -through [get_pins -nowarn ${inst}*|soft_logics|pcie0_user_avmm_adpt|p0_link_req_rst_sync|dreg[*]|clrn] -to [get_registers -nowarn ${inst}*|soft_logics|pcie0_user_avmm_adpt|p0_link_req_rst_sync|dreg[*]]



# core16_cpl_timeout
# Sync reset_status_n to AVMM clock
set_false_path -to [get_registers -nowarn ${inst}*|soft_logics|g_p0_cplto_avmm_reset_status_n_sync.p0_avmm_reset_status_n_sync_inst|din_s1]
set_false_path -through [get_pins -nowarn ${inst}*|soft_logics|g_p0_cplto_avmm_reset_status_n_sync.p0_avmm_reset_status_n_sync_inst|dreg[*]|clrn] -to [get_registers -nowarn ${inst}*|soft_logics|g_p0_cplto_avmm_reset_status_n_sync.p0_avmm_reset_status_n_sync_inst|dreg[*]]

# Sync link_req_rst to AVMM clock
set_false_path -to [get_registers -nowarn ${inst}*|soft_logics|pcie0_cpl_to_avmm_adpt|p0_link_req_rst_sync|din_s1]
set_false_path -through [get_pins -nowarn ${inst}*|soft_logics|pcie0_cpl_to_avmm_adpt|p0_link_req_rst_sync|dreg[*]|clrn] -to [get_registers -nowarn ${inst}*|soft_logics|pcie0_cpl_to_avmm_adpt|p0_link_req_rst_sync|dreg[*]]

# core8_cpl_timeout
# Sync reset_status_n to AVMM clock
set_false_path -to [get_registers -nowarn ${inst}*|soft_logics|g_p1_cplto_avmm_reset_status_n_sync.p1_avmm_reset_status_n_sync_inst|din_s1]
set_false_path -through [get_pins -nowarn ${inst}*|soft_logics|g_p1_cplto_avmm_reset_status_n_sync.p1_avmm_reset_status_n_sync_inst|dreg[*]|clrn] -to [get_registers -nowarn ${inst}*|soft_logics|g_p1_cplto_avmm_reset_status_n_sync.p1_avmm_reset_status_n_sync_inst|dreg[*]]

# Sync link_req_rst to AVMM clock
set_false_path -to [get_registers -nowarn ${inst}*|soft_logics|pcie1_cpl_to_avmm_adpt|p0_link_req_rst_sync|din_s1]
set_false_path -through [get_pins -nowarn ${inst}*|soft_logics|pcie1_cpl_to_avmm_adpt|p0_link_req_rst_sync|dreg[*]|clrn] -to [get_registers -nowarn ${inst}*|soft_logics|pcie1_cpl_to_avmm_adpt|p0_link_req_rst_sync|dreg[*]]

# core4_1_cpl_timeout
# Sync reset_status_n to AVMM clock
set_false_path -to [get_registers -nowarn ${inst}*|soft_logics|g_p2_cplto_avmm_reset_status_n_sync.p2_avmm_reset_status_n_sync_inst|din_s1]
set_false_path -through [get_pins -nowarn ${inst}*|soft_logics|g_p2_cplto_avmm_reset_status_n_sync.p2_avmm_reset_status_n_sync_inst|dreg[*]|clrn] -to [get_registers -nowarn ${inst}*|soft_logics|g_p2_cplto_avmm_reset_status_n_sync.p2_avmm_reset_status_n_sync_inst|dreg[*]]

# Sync link_req_rst to AVMM clock
set_false_path -to [get_registers -nowarn ${inst}*|soft_logics|pcie2_cpl_to_avmm_adpt|p0_link_req_rst_sync|din_s1]
set_false_path -through [get_pins -nowarn ${inst}*|soft_logics|pcie2_cpl_to_avmm_adpt|p0_link_req_rst_sync|dreg[*]|clrn] -to [get_registers -nowarn ${inst}*|soft_logics|pcie2_cpl_to_avmm_adpt|p0_link_req_rst_sync|dreg[*]]

# core4_1_cpl_timeout
# Sync reset_status_n to AVMM clock
set_false_path -to [get_registers -nowarn ${inst}*|soft_logics|g_p3_cplto_avmm_reset_status_n_sync.p3_avmm_reset_status_n_sync_inst|din_s1]
set_false_path -through [get_pins -nowarn ${inst}*|soft_logics|g_p3_cplto_avmm_reset_status_n_sync.p3_avmm_reset_status_n_sync_inst|dreg[*]|clrn] -to [get_registers -nowarn ${inst}*|soft_logics|g_p3_cplto_avmm_reset_status_n_sync.p3_avmm_reset_status_n_sync_inst|dreg[*]]

# Sync link_req_rst to AVMM clock
set_false_path -to [get_registers -nowarn ${inst}*|soft_logics|pcie3_cpl_to_avmm_adpt|p0_link_req_rst_sync|din_s1]
set_false_path -through [get_pins -nowarn ${inst}*|soft_logics|pcie3_cpl_to_avmm_adpt|p0_link_req_rst_sync|dreg[*]|clrn] -to [get_registers -nowarn ${inst}*|soft_logics|pcie3_cpl_to_avmm_adpt|p0_link_req_rst_sync|dreg[*]]

# Sync ninit_done to coreclkout_hip
# Removed set false to dreg. The set false only on the cross clock register. HSD15012967369
set_false_path -to [get_registers -nowarn ${inst}*|soft_logics|rst_ctrl|pld_clk_ninit_done_sync_inst|din_s1]
set_false_path -through [get_pins -nowarn ${inst}*|soft_logics|rst_ctrl|pld_clk_ninit_done_sync_inst|dreg[*]|clrn] -to [get_registers -nowarn ${inst}*|soft_logics|rst_ctrl|pld_clk_ninit_done_sync_inst|dreg[*]]

# Sync warm_rst_rdy to respective AVMM clock
set_false_path -to [get_registers -nowarn ${inst}*|soft_logics|rst_ctrl|p*_user_avmm_warm_rst_rdy_sync_inst|din_s1]
set_false_path -through [get_pins -nowarn ${inst}*|soft_logics|rst_ctrl|p*_user_avmm_warm_rst_rdy_sync_inst|dreg[*]|clrn] -to [get_registers -nowarn ${inst}*|soft_logics|rst_ctrl|p*_user_avmm_warm_rst_rdy_sync_inst|dreg[*]]

set_false_path -to [get_registers -nowarn ${inst}*|soft_logics|rst_ctrl|p*_cplto_avmm_warm_rst_rdy_sync_inst|din_s1]
set_false_path -through [get_pins -nowarn ${inst}*|soft_logics|rst_ctrl|p*_cplto_avmm_warm_rst_rdy_sync_inst|dreg[*]|clrn] -to [get_registers -nowarn ${inst}*|soft_logics|rst_ctrl|p*_cplto_avmm_warm_rst_rdy_sync_inst|dreg[*]]

set_false_path -to [get_registers -nowarn ${inst}*|soft_logics|rst_ctrl|xcvr_avmm_warm_rst_rdy_sync_inst|din_s1]
set_false_path -through [get_pins -nowarn ${inst}*|soft_logics|rst_ctrl|xcvr_avmm_warm_rst_rdy_sync_inst|dreg[*]|clrn] -to [get_registers -nowarn ${inst}*|soft_logics|rst_ctrl|xcvr_avmm_warm_rst_rdy_sync_inst|dreg[*]]

# Sync pin_perst to coreclkout_hip 
set_false_path -to [get_registers -nowarn ${inst}*|soft_logics|rst_ctrl|pin_perst_n_sync|din_s1]
set_false_path -through [get_pins -nowarn ${inst}*|soft_logics|rst_ctrl|pin_perst_n_sync|dreg[*]|clrn] -to [get_registers -nowarn ${inst}*|soft_logics|rst_ctrl|pin_perst_n_sync|dreg[*]]




#######################################################################







##########################################################################################################################################
#SDC FOR GEN4X4 - 128s_to_256s ADAPTER
##########################################################################################################################################
if {[string match $top_topology "Gen4x4, Interface - 256 bit"] == 1 } {
    set from_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_rx_st_if|rxfifo|gx0|din_gry*]
    set to_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_rx_st_if|rxfifo|gx0|u_din_gry_sync|sync_regs_s1*]
    apply_cdc $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_rx_st_if|rxfifo|gx0|u_din_gry_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_rx_st_if|rxfifo|gx0|u_din_gry_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_rx_st_if|rx_st_ready_i_q*]
    set to_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_rx_st_if|rx_ready_sync|sync_regs_s1*]
    set_false_path -from $from_keep -to $to_keep

    set from_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_rx_st_if|rx_ready_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_rx_st_if|rx_ready_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep
    
    set from_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_rx_st_if|rx_par_err_sync|req_rd_clk_d0*]
    set to_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_rx_st_if|rx_par_err_sync|ack_wr_clk_sync|sync_regs_s1*]
    apply_cdc_from_to_bit $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_rx_st_if|rx_par_err_sync|ack_wr_clk_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_rx_st_if|rx_par_err_sync|ack_wr_clk_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep
    
    set from_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_rx_st_if|rx_par_err_sync|req_wr_clk*]
    set to_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_rx_st_if|rx_par_err_sync|req_rd_clk_sync|sync_regs_s1*]
    apply_cdc_from_to_bit $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_rx_st_if|rx_par_err_sync|req_rd_clk_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_rx_st_if|rx_par_err_sync|req_rd_clk_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

#   #for dcore1
    set from_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_rx_st_if|rxfifo|gx0|din_gry*]
    set to_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_rx_st_if|rxfifo|gx0|u_din_gry_sync|sync_regs_s1*]
    apply_cdc $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_rx_st_if|rxfifo|gx0|u_din_gry_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_rx_st_if|rxfifo|gx0|u_din_gry_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_rx_st_if|rx_st_ready_i_q*]
    set to_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_rx_st_if|rx_ready_sync|sync_regs_s1*]
    set_false_path -from $from_keep -to $to_keep

    set from_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_rx_st_if|rx_ready_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_rx_st_if|rx_ready_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep
    
   set from_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_rx_st_if|rx_par_err_sync|req_rd_clk_d0*]
    set to_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_rx_st_if|rx_par_err_sync|ack_wr_clk_sync|sync_regs_s1*]
    apply_cdc_from_to_bit $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_rx_st_if|rx_par_err_sync|ack_wr_clk_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_rx_st_if|rx_par_err_sync|ack_wr_clk_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep
    
    set from_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_rx_st_if|rx_par_err_sync|req_wr_clk*]
    set to_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_rx_st_if|rx_par_err_sync|req_rd_clk_sync|sync_regs_s1*]
    apply_cdc_from_to_bit $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_rx_st_if|rx_par_err_sync|req_rd_clk_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_rx_st_if|rx_par_err_sync|req_rd_clk_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

#for dcore2
    set from_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_rx_st_if|rxfifo|gx0|din_gry*]
    set to_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_rx_st_if|rxfifo|gx0|u_din_gry_sync|sync_regs_s1*]
    apply_cdc $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_rx_st_if|rxfifo|gx0|u_din_gry_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_rx_st_if|rxfifo|gx0|u_din_gry_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_rx_st_if|rx_st_ready_i_q*]
    set to_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_rx_st_if|rx_ready_sync|sync_regs_s1*]
    set_false_path -from $from_keep -to $to_keep

    set from_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_rx_st_if|rx_ready_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_rx_st_if|rx_ready_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep
    
    set from_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_rx_st_if|rx_par_err_sync|req_rd_clk_d0*]
    set to_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_rx_st_if|rx_par_err_sync|ack_wr_clk_sync|sync_regs_s1*]
    apply_cdc_from_to_bit $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_rx_st_if|rx_par_err_sync|ack_wr_clk_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_rx_st_if|rx_par_err_sync|ack_wr_clk_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep
    
    set from_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_rx_st_if|rx_par_err_sync|req_wr_clk*]
    set to_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_rx_st_if|rx_par_err_sync|req_rd_clk_sync|sync_regs_s1*]
    apply_cdc_from_to_bit $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_rx_st_if|rx_par_err_sync|req_rd_clk_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_rx_st_if|rx_par_err_sync|req_rd_clk_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

#core3
    set from_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_rx_st_if|rxfifo|gx0|din_gry*]
    set to_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_rx_st_if|rxfifo|gx0|u_din_gry_sync|sync_regs_s1*]
    apply_cdc $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_rx_st_if|rxfifo|gx0|u_din_gry_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_rx_st_if|rxfifo|gx0|u_din_gry_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_rx_st_if|rx_st_ready_i_q*]
    set to_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_rx_st_if|rx_ready_sync|sync_regs_s1*]
    set_false_path -from $from_keep -to $to_keep

    set from_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_rx_st_if|rx_ready_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_rx_st_if|rx_ready_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep
    
    set from_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_rx_st_if|rx_par_err_sync|req_rd_clk_d0*]
    set to_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_rx_st_if|rx_par_err_sync|ack_wr_clk_sync|sync_regs_s1*]
    apply_cdc_from_to_bit $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_rx_st_if|rx_par_err_sync|ack_wr_clk_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_rx_st_if|rx_par_err_sync|ack_wr_clk_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep
    
    set from_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_rx_st_if|rx_par_err_sync|req_wr_clk*]
    set to_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_rx_st_if|rx_par_err_sync|req_rd_clk_sync|sync_regs_s1*]
    apply_cdc_from_to_bit $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_rx_st_if|rx_par_err_sync|req_rd_clk_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_rx_st_if|rx_par_err_sync|req_rd_clk_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

#   ##########################################################################################################################################
#
#   ##########################################################################################################################################
    set from_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_tx_st_if|tx_fifo_lo|gx0|din_gry*]
    set to_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_tx_st_if|tx_fifo_lo|gx0|u_din_gry_sync|sync_regs_s1*]
    apply_cdc $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_tx_st_if|tx_fifo_lo|gx0|u_din_gry_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_tx_st_if|tx_fifo_lo|gx0|u_din_gry_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_tx_st_if|tx_fifo_lo|gx1|din_gry*]
    set to_keep [get_keepers  -nowarn *|core16_x8_x4_adapter|u_tx_st_if|tx_fifo_lo|gx1|u_din_gry_sync|sync_regs_s1*]
    apply_cdc $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_tx_st_if|tx_fifo_lo|gx1|u_din_gry_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_tx_st_if|tx_fifo_lo|gx1|u_din_gry_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_tx_st_if|tx_fifo_hi|gx0|din_gry*]
    set to_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_tx_st_if|tx_fifo_hi|gx0|u_din_gry_sync|sync_regs_s1*]
    apply_cdc $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_tx_st_if|tx_fifo_hi|gx0|u_din_gry_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_tx_st_if|tx_fifo_hi|gx0|u_din_gry_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_tx_st_if|tx_par_err_sync|req_rd_clk_d0*]
    set to_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_tx_st_if|tx_par_err_sync|ack_wr_clk_sync|sync_regs_s1*]
    apply_cdc_from_to_bit $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_tx_st_if|tx_par_err_sync|ack_wr_clk_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_tx_st_if|tx_par_err_sync|ack_wr_clk_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_tx_st_if|tx_par_err_sync|req_wr_clk*]   
    set to_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_tx_st_if|tx_par_err_sync|req_rd_clk_sync|sync_regs_s1*]
    apply_cdc_from_to_bit $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_tx_st_if|tx_par_err_sync|req_rd_clk_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_tx_st_if|tx_par_err_sync|req_rd_clk_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep
#   #for dcore1
    set from_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_tx_st_if|tx_fifo_lo|gx0|din_gry*]
    set to_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_tx_st_if|tx_fifo_lo|gx0|u_din_gry_sync|sync_regs_s1*]
    apply_cdc $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_tx_st_if|tx_fifo_lo|gx0|u_din_gry_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_tx_st_if|tx_fifo_lo|gx0|u_din_gry_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_tx_st_if|tx_fifo_lo|gx1|din_gry*]
    set to_keep [get_keepers  -nowarn *|core8_x8_x4_adapter|u_tx_st_if|tx_fifo_lo|gx1|u_din_gry_sync|sync_regs_s1*]
    apply_cdc $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_tx_st_if|tx_fifo_lo|gx1|u_din_gry_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_tx_st_if|tx_fifo_lo|gx1|u_din_gry_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_tx_st_if|tx_fifo_hi|gx0|din_gry*]
    set to_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_tx_st_if|tx_fifo_hi|gx0|u_din_gry_sync|sync_regs_s1*]
    apply_cdc $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_tx_st_if|tx_fifo_hi|gx0|u_din_gry_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_tx_st_if|tx_fifo_hi|gx0|u_din_gry_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_tx_st_if|tx_par_err_sync|req_rd_clk_d0*]
    set to_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_tx_st_if|tx_par_err_sync|ack_wr_clk_sync|sync_regs_s1*]
    apply_cdc_from_to_bit $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_tx_st_if|tx_par_err_sync|ack_wr_clk_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_tx_st_if|tx_par_err_sync|ack_wr_clk_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_tx_st_if|tx_par_err_sync|req_wr_clk*]    
    set to_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_tx_st_if|tx_par_err_sync|req_rd_clk_sync|sync_regs_s1*]
    apply_cdc_from_to_bit $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_tx_st_if|tx_par_err_sync|req_rd_clk_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_tx_st_if|tx_par_err_sync|req_rd_clk_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

#For dcore2
    set from_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_tx_st_if|tx_fifo_lo|gx0|din_gry*]
    set to_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_tx_st_if|tx_fifo_lo|gx0|u_din_gry_sync|sync_regs_s1*]
    apply_cdc $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_tx_st_if|tx_fifo_lo|gx0|u_din_gry_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_tx_st_if|tx_fifo_lo|gx0|u_din_gry_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_tx_st_if|tx_fifo_lo|gx1|din_gry*]
    set to_keep [get_keepers  -nowarn *|core4_0_x8_x4_adapter|u_tx_st_if|tx_fifo_lo|gx1|u_din_gry_sync|sync_regs_s1*]
    apply_cdc $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_tx_st_if|tx_fifo_lo|gx1|u_din_gry_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_tx_st_if|tx_fifo_lo|gx1|u_din_gry_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_tx_st_if|tx_fifo_hi|gx0|din_gry*]
    set to_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_tx_st_if|tx_fifo_hi|gx0|u_din_gry_sync|sync_regs_s1*]
    apply_cdc $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_tx_st_if|tx_fifo_hi|gx0|u_din_gry_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_tx_st_if|tx_fifo_hi|gx0|u_din_gry_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_tx_st_if|tx_par_err_sync|req_rd_clk_d0*]
    set to_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_tx_st_if|tx_par_err_sync|ack_wr_clk_sync|sync_regs_s1*]
    apply_cdc_from_to_bit $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_tx_st_if|tx_par_err_sync|ack_wr_clk_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_tx_st_if|tx_par_err_sync|ack_wr_clk_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_tx_st_if|tx_par_err_sync|req_wr_clk*]  
    set to_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_tx_st_if|tx_par_err_sync|req_rd_clk_sync|sync_regs_s1*]
    apply_cdc_from_to_bit $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_tx_st_if|tx_par_err_sync|req_rd_clk_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_tx_st_if|tx_par_err_sync|req_rd_clk_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

#for dcore3
    set from_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_tx_st_if|tx_fifo_lo|gx0|din_gry*]
    set to_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_tx_st_if|tx_fifo_lo|gx0|u_din_gry_sync|sync_regs_s1*]
    apply_cdc $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_tx_st_if|tx_fifo_lo|gx0|u_din_gry_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_tx_st_if|tx_fifo_lo|gx0|u_din_gry_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_tx_st_if|tx_fifo_lo|gx1|din_gry*]
    set to_keep [get_keepers  -nowarn *|core4_1_x8_x4_adapter|u_tx_st_if|tx_fifo_lo|gx1|u_din_gry_sync|sync_regs_s1*]
    apply_cdc $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_tx_st_if|tx_fifo_lo|gx1|u_din_gry_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_tx_st_if|tx_fifo_lo|gx1|u_din_gry_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_tx_st_if|tx_fifo_hi|gx0|din_gry*]
    set to_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_tx_st_if|tx_fifo_hi|gx0|u_din_gry_sync|sync_regs_s1*]
    apply_cdc $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_tx_st_if|tx_fifo_hi|gx0|u_din_gry_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_tx_st_if|tx_fifo_hi|gx0|u_din_gry_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_tx_st_if|tx_par_err_sync|req_rd_clk_d0*]
    set to_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_tx_st_if|tx_par_err_sync|ack_wr_clk_sync|sync_regs_s1*]
    apply_cdc_from_to_bit $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_tx_st_if|tx_par_err_sync|ack_wr_clk_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_tx_st_if|tx_par_err_sync|ack_wr_clk_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_tx_st_if|tx_par_err_sync|req_wr_clk*]  
    set to_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_tx_st_if|tx_par_err_sync|req_rd_clk_sync|sync_regs_s1*]
    apply_cdc_from_to_bit $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_tx_st_if|tx_par_err_sync|req_rd_clk_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_tx_st_if|tx_par_err_sync|req_rd_clk_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep
#   ##########################################################################################################################################
#   ##########################################################################################################################################
    set from_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_credit_if|tx_credit_data_fifo|gx0|din_gry*]
    set to_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_credit_if|tx_credit_data_fifo|gx0|u_din_gry_sync|sync_regs_s1*]
    apply_cdc $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_credit_if|tx_credit_data_fifo|gx0|u_din_gry_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_credit_if|tx_credit_data_fifo|gx0|u_din_gry_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_credit_if|rx_credit_data_fifo|gx0|din_gry*]
    set to_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_credit_if|rx_credit_data_fifo|gx0|u_din_gry_sync|sync_regs_s1*]
    apply_cdc $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_credit_if|rx_credit_data_fifo|gx0|u_din_gry_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_credit_if|rx_credit_data_fifo|gx0|u_din_gry_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

#dcore1
    set from_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_credit_if|tx_credit_data_fifo|gx0|din_gry*]
    set to_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_credit_if|tx_credit_data_fifo|gx0|u_din_gry_sync|sync_regs_s1*]
    apply_cdc $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_credit_if|tx_credit_data_fifo|gx0|u_din_gry_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_credit_if|tx_credit_data_fifo|gx0|u_din_gry_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep
    
    set from_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_credit_if|rx_credit_data_fifo|gx0|din_gry*]
    set to_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_credit_if|rx_credit_data_fifo|gx0|u_din_gry_sync|sync_regs_s1*]
    apply_cdc $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_credit_if|rx_credit_data_fifo|gx0|u_din_gry_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_credit_if|rx_credit_data_fifo|gx0|u_din_gry_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

#dcore2
    set from_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_credit_if|tx_credit_data_fifo|gx0|din_gry*]
    set to_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_credit_if|tx_credit_data_fifo|gx0|u_din_gry_sync|sync_regs_s1*]
    apply_cdc $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_credit_if|tx_credit_data_fifo|gx0|u_din_gry_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_credit_if|tx_credit_data_fifo|gx0|u_din_gry_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_credit_if|rx_credit_data_fifo|gx0|din_gry*]
    set to_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_credit_if|rx_credit_data_fifo|gx0|u_din_gry_sync|sync_regs_s1*]
    apply_cdc $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_credit_if|rx_credit_data_fifo|gx0|u_din_gry_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_credit_if|rx_credit_data_fifo|gx0|u_din_gry_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

#dcore3
    set from_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_credit_if|tx_credit_data_fifo|gx0|din_gry*]
    set to_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_credit_if|tx_credit_data_fifo|gx0|u_din_gry_sync|sync_regs_s1*]
    apply_cdc $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_credit_if|tx_credit_data_fifo|gx0|u_din_gry_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_credit_if|tx_credit_data_fifo|gx0|u_din_gry_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_credit_if|rx_credit_data_fifo|gx0|din_gry*]
    set to_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_credit_if|rx_credit_data_fifo|gx0|u_din_gry_sync|sync_regs_s1*]
    apply_cdc $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_credit_if|rx_credit_data_fifo|gx0|u_din_gry_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_credit_if|rx_credit_data_fifo|gx0|u_din_gry_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

#   ##########################################################################################################################################
#   ##########################################################################################################################################

    set from_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_cfg_if|tl_cfg_data_fifo|gx0|din_gry*]
    set to_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_cfg_if|tl_cfg_data_fifo|gx0|u_din_gry_sync|sync_regs_s1*]
    apply_cdc $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_cfg_if|tl_cfg_data_fifo|gx0|u_din_gry_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_cfg_if|tl_cfg_data_fifo|gx0|u_din_gry_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

#   dcore1
    set from_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_cfg_if|tl_cfg_data_fifo|gx0|din_gry*]
    set to_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_cfg_if|tl_cfg_data_fifo|gx0|u_din_gry_sync|sync_regs_s1*]
    apply_cdc $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_cfg_if|tl_cfg_data_fifo|gx0|u_din_gry_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_cfg_if|tl_cfg_data_fifo|gx0|u_din_gry_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

#dcore2
    set from_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_cfg_if|tl_cfg_data_fifo|gx0|din_gry*]
    set to_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_cfg_if|tl_cfg_data_fifo|gx0|u_din_gry_sync|sync_regs_s1*]
    apply_cdc $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_cfg_if|tl_cfg_data_fifo|gx0|u_din_gry_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_cfg_if|tl_cfg_data_fifo|gx0|u_din_gry_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

#dcore3
    set from_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_cfg_if|tl_cfg_data_fifo|gx0|din_gry*]
    set to_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_cfg_if|tl_cfg_data_fifo|gx0|u_din_gry_sync|sync_regs_s1*]
    apply_cdc $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_cfg_if|tl_cfg_data_fifo|gx0|u_din_gry_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_cfg_if|tl_cfg_data_fifo|gx0|u_din_gry_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

#   ##########################################################################################################################################
#   ##########################################################################################################################################


    ##########################################################################################################################################
    ##########################################################################################################################################
    set from_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_prs_if|prsfifo|gx0|din_gry*]
    set to_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_prs_if|prsfifo|gx0|u_din_gry_sync|sync_regs_s1*]
    apply_cdc $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_prs_if|prsfifo|gx0|u_din_gry_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_prs_if|prsfifo|gx0|u_din_gry_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

#   dcore1
    set from_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_prs_if|prsfifo|gx0|din_gry*]
    set to_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_prs_if|prsfifo|gx0|u_din_gry_sync|sync_regs_s1*]
    apply_cdc $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_prs_if|prsfifo|gx0|u_din_gry_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_prs_if|prsfifo|gx0|u_din_gry_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

#dcore2
    set from_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_prs_if|prsfifo|gx0|din_gry*]
    set to_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_prs_if|prsfifo|gx0|u_din_gry_sync|sync_regs_s1*]
    apply_cdc $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_prs_if|prsfifo|gx0|u_din_gry_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_prs_if|prsfifo|gx0|u_din_gry_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

#dcore3
    set from_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_prs_if|prsfifo|gx0|din_gry*]
    set to_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_prs_if|prsfifo|gx0|u_din_gry_sync|sync_regs_s1*]
    apply_cdc $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_prs_if|prsfifo|gx0|u_din_gry_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_prs_if|prsfifo|gx0|u_din_gry_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

    ##########################################################################################################################################
    ##########################################################################################################################################

    set from_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_pm_if|pm_state_sync|req_rd_clk_d0*]
    set to_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_pm_if|pm_state_sync|ack_wr_clk_sync|sync_regs_s1*]
    apply_cdc_from_to_bit $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_pm_if|pm_state_sync|ack_wr_clk_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_pm_if|pm_state_sync|ack_wr_clk_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_pm_if|pm_state_sync|req_wr_clk*]
    set to_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_pm_if|pm_state_sync|u_req_rd_clk_sync|sync_regs_s1*]
    apply_cdc_from_to_bit $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_pm_if|pm_state_sync|u_req_rd_clk_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_pm_if|pm_state_sync|u_req_rd_clk_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_pm_if|pm_state_sync|data_in_d0*]
    set to_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_pm_if|pm_state_sync|dout*]
    apply_cdc_sync_vec $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_pm_if|apps_pm_xmt_pme_sync|req_rd_clk_d0*]
    set to_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_pm_if|apps_pm_xmt_pme_sync|ack_wr_clk_sync|sync_regs_s1*]
    apply_cdc_from_to_bit $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_pm_if|apps_pm_xmt_pme_sync|ack_wr_clk_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_pm_if|apps_pm_xmt_pme_sync|ack_wr_clk_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep
    
    set from_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_pm_if|apps_pm_xmt_pme_sync|req_wr_clk*]
    set to_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_pm_if|apps_pm_xmt_pme_sync|u_req_rd_clk_sync|sync_regs_s1*]
    apply_cdc_from_to_bit $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_pm_if|apps_pm_xmt_pme_sync|u_req_rd_clk_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_pm_if|apps_pm_xmt_pme_sync|u_req_rd_clk_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_pm_if|apps_pm_xmt_pme_sync|data_in_d0*]
    set to_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_pm_if|apps_pm_xmt_pme_sync|dout*]
    apply_cdc_sync_vec $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_pm_if|apps_pm_xmt_turnoff_sync|req_rd_clk_d0*]
    set to_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_pm_if|apps_pm_xmt_turnoff_sync|ack_wr_clk_sync|sync_regs_s1*]
    apply_cdc_from_to_bit $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_pm_if|apps_pm_xmt_turnoff_sync|ack_wr_clk_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_pm_if|apps_pm_xmt_turnoff_sync|ack_wr_clk_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_pm_if|apps_pm_xmt_turnoff_sync|req_wr_clk*] 
    set to_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_pm_if|apps_pm_xmt_turnoff_sync|req_rd_clk_sync|sync_regs_s1*]
    apply_cdc_from_to_bit $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_pm_if|apps_pm_xmt_turnoff_sync|req_rd_clk_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_pm_if|apps_pm_xmt_turnoff_sync|req_rd_clk_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_pm_if|app_init_rst_sync|req_rd_clk_d0*]
    set to_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_pm_if|app_init_rst_sync|ack_wr_clk_sync|sync_regs_s1*]
    apply_cdc_from_to_bit $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_pm_if|app_init_rst_sync|ack_wr_clk_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_pm_if|app_init_rst_sync|ack_wr_clk_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_pm_if|app_init_rst_sync|req_wr_clk*]
    set to_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_pm_if|app_init_rst_sync|req_rd_clk_sync|sync_regs_s1*]
    apply_cdc_from_to_bit $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_pm_if|app_init_rst_sync|req_rd_clk_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_pm_if|app_init_rst_sync|req_rd_clk_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_pm_if|app_ready_entr_l23_q]
    set to_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_pm_if|app_ready_entr_l23_sync|sync_regs_s1*]
    apply_cdc_from_to_bit $from_keep $to_keep
    
    set from_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_pm_if|app_ready_entr_l23_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_pm_if|app_ready_entr_l23_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_pm_if|app_xfer_pending_q*]
    set to_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_pm_if|app_xfer_pending_sync|sync_regs_s1*]
    apply_cdc_from_to_bit $from_keep $to_keep
    
    set from_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_pm_if|app_xfer_pending_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_pm_if|app_xfer_pending_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

#   dcore 1

    set from_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_pm_if|pm_state_sync|req_rd_clk_d0*]
    set to_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_pm_if|pm_state_sync|ack_wr_clk_sync|sync_regs_s1*]
    apply_cdc_from_to_bit $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_pm_if|pm_state_sync|ack_wr_clk_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_pm_if|pm_state_sync|ack_wr_clk_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_pm_if|pm_state_sync|req_wr_clk*]
    set to_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_pm_if|pm_state_sync|u_req_rd_clk_sync|sync_regs_s1*]
    apply_cdc_from_to_bit $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_pm_if|pm_state_sync|u_req_rd_clk_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_pm_if|pm_state_sync|u_req_rd_clk_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_pm_if|pm_state_sync|data_in_d0*]
    set to_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_pm_if|pm_state_sync|dout*]
    apply_cdc_sync_vec $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_pm_if|apps_pm_xmt_pme_sync|req_rd_clk_d0*]
    set to_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_pm_if|apps_pm_xmt_pme_sync|ack_wr_clk_sync|sync_regs_s1*]
    apply_cdc_from_to_bit $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_pm_if|apps_pm_xmt_pme_sync|ack_wr_clk_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_pm_if|apps_pm_xmt_pme_sync|ack_wr_clk_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep
    
    set from_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_pm_if|apps_pm_xmt_pme_sync|req_wr_clk*]
    set to_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_pm_if|apps_pm_xmt_pme_sync|u_req_rd_clk_sync|sync_regs_s1*]
    apply_cdc_from_to_bit $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_pm_if|apps_pm_xmt_pme_sync|u_req_rd_clk_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_pm_if|apps_pm_xmt_pme_sync|u_req_rd_clk_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_pm_if|apps_pm_xmt_pme_sync|data_in_d0*]
    set to_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_pm_if|apps_pm_xmt_pme_sync|dout*]
    apply_cdc_sync_vec $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_pm_if|apps_pm_xmt_turnoff_sync|req_rd_clk_d0*]
    set to_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_pm_if|apps_pm_xmt_turnoff_sync|ack_wr_clk_sync|sync_regs_s1*]
    apply_cdc_from_to_bit $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_pm_if|apps_pm_xmt_turnoff_sync|ack_wr_clk_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_pm_if|apps_pm_xmt_turnoff_sync|ack_wr_clk_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_pm_if|apps_pm_xmt_turnoff_sync|req_wr_clk*]  
    set to_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_pm_if|apps_pm_xmt_turnoff_sync|req_rd_clk_sync|sync_regs_s1*]
    apply_cdc_from_to_bit $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_pm_if|apps_pm_xmt_turnoff_sync|req_rd_clk_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_pm_if|apps_pm_xmt_turnoff_sync|req_rd_clk_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_pm_if|app_init_rst_sync|req_rd_clk_d0*]
    set to_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_pm_if|app_init_rst_sync|ack_wr_clk_sync|sync_regs_s1*]
    apply_cdc_from_to_bit $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_pm_if|app_init_rst_sync|ack_wr_clk_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_pm_if|app_init_rst_sync|ack_wr_clk_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_pm_if|app_init_rst_sync|req_wr_clk*]
    set to_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_pm_if|app_init_rst_sync|req_rd_clk_sync|sync_regs_s1*]
    apply_cdc_from_to_bit $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_pm_if|app_init_rst_sync|req_rd_clk_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_pm_if|app_init_rst_sync|req_rd_clk_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_pm_if|app_ready_entr_l23_q]
    set to_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_pm_if|app_ready_entr_l23_sync|sync_regs_s1*]
    apply_cdc_from_to_bit $from_keep $to_keep
    
    set from_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_pm_if|app_ready_entr_l23_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_pm_if|app_ready_entr_l23_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_pm_if|app_xfer_pending_q*]
    set to_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_pm_if|app_xfer_pending_sync|sync_regs_s1*]
    apply_cdc_from_to_bit $from_keep $to_keep
    
    set from_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_pm_if|app_xfer_pending_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_pm_if|app_xfer_pending_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

#dcore2
    set from_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_pm_if|pm_state_sync|req_rd_clk_d0*]
    set to_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_pm_if|pm_state_sync|ack_wr_clk_sync|sync_regs_s1*]
    apply_cdc_from_to_bit $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_pm_if|pm_state_sync|ack_wr_clk_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_pm_if|pm_state_sync|ack_wr_clk_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_pm_if|pm_state_sync|req_wr_clk*]
    set to_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_pm_if|pm_state_sync|u_req_rd_clk_sync|sync_regs_s1*]
    apply_cdc_from_to_bit $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_pm_if|pm_state_sync|u_req_rd_clk_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_pm_if|pm_state_sync|u_req_rd_clk_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_pm_if|pm_state_sync|data_in_d0*]
    set to_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_pm_if|pm_state_sync|dout*]
    apply_cdc_sync_vec $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_pm_if|apps_pm_xmt_pme_sync|req_rd_clk_d0*]
    set to_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_pm_if|apps_pm_xmt_pme_sync|ack_wr_clk_sync|sync_regs_s1*]
    apply_cdc_from_to_bit $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_pm_if|apps_pm_xmt_pme_sync|ack_wr_clk_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_pm_if|apps_pm_xmt_pme_sync|ack_wr_clk_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep
    
    set from_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_pm_if|apps_pm_xmt_pme_sync|req_wr_clk*]
    set to_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_pm_if|apps_pm_xmt_pme_sync|u_req_rd_clk_sync|sync_regs_s1*]
    apply_cdc_from_to_bit $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_pm_if|apps_pm_xmt_pme_sync|u_req_rd_clk_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_pm_if|apps_pm_xmt_pme_sync|u_req_rd_clk_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_pm_if|apps_pm_xmt_pme_sync|data_in_d0*]
    set to_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_pm_if|apps_pm_xmt_pme_sync|dout*]
    apply_cdc_sync_vec $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_pm_if|apps_pm_xmt_turnoff_sync|req_rd_clk_d0*]
    set to_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_pm_if|apps_pm_xmt_turnoff_sync|ack_wr_clk_sync|sync_regs_s1*]
    apply_cdc_from_to_bit $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_pm_if|apps_pm_xmt_turnoff_sync|ack_wr_clk_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_pm_if|apps_pm_xmt_turnoff_sync|ack_wr_clk_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_pm_if|apps_pm_xmt_turnoff_sync|req_wr_clk*]    
    set to_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_pm_if|apps_pm_xmt_turnoff_sync|req_rd_clk_sync|sync_regs_s1*]
    apply_cdc_from_to_bit $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_pm_if|apps_pm_xmt_turnoff_sync|req_rd_clk_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_pm_if|apps_pm_xmt_turnoff_sync|req_rd_clk_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_pm_if|app_init_rst_sync|req_rd_clk_d0*]
    set to_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_pm_if|app_init_rst_sync|ack_wr_clk_sync|sync_regs_s1*]
    apply_cdc_from_to_bit $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_pm_if|app_init_rst_sync|ack_wr_clk_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_pm_if|app_init_rst_sync|ack_wr_clk_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_pm_if|app_init_rst_sync|req_wr_clk*]
    set to_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_pm_if|app_init_rst_sync|req_rd_clk_sync|sync_regs_s1*]
    apply_cdc_from_to_bit $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_pm_if|app_init_rst_sync|req_rd_clk_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_pm_if|app_init_rst_sync|req_rd_clk_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_pm_if|app_ready_entr_l23_q]
    set to_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_pm_if|app_ready_entr_l23_sync|sync_regs_s1*]
    apply_cdc_from_to_bit $from_keep $to_keep
    
    set from_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_pm_if|app_ready_entr_l23_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_pm_if|app_ready_entr_l23_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_pm_if|app_xfer_pending_q*]
    set to_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_pm_if|app_xfer_pending_sync|sync_regs_s1*]
    apply_cdc_from_to_bit $from_keep $to_keep
    
    set from_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_pm_if|app_xfer_pending_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_pm_if|app_xfer_pending_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

#dcore3
    set from_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_pm_if|pm_state_sync|req_rd_clk_d0*]
    set to_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_pm_if|pm_state_sync|ack_wr_clk_sync|sync_regs_s1*]
    apply_cdc_from_to_bit $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_pm_if|pm_state_sync|ack_wr_clk_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_pm_if|pm_state_sync|ack_wr_clk_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_pm_if|pm_state_sync|req_wr_clk*]
    set to_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_pm_if|pm_state_sync|u_req_rd_clk_sync|sync_regs_s1*]
    apply_cdc_from_to_bit $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_pm_if|pm_state_sync|u_req_rd_clk_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_pm_if|pm_state_sync|u_req_rd_clk_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_pm_if|pm_state_sync|data_in_d0*]
    set to_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_pm_if|pm_state_sync|dout*]
    apply_cdc_sync_vec $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_pm_if|apps_pm_xmt_pme_sync|req_rd_clk_d0*]
    set to_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_pm_if|apps_pm_xmt_pme_sync|ack_wr_clk_sync|sync_regs_s1*]
    apply_cdc_from_to_bit $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_pm_if|apps_pm_xmt_pme_sync|ack_wr_clk_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_pm_if|apps_pm_xmt_pme_sync|ack_wr_clk_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep
    
    set from_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_pm_if|apps_pm_xmt_pme_sync|req_wr_clk*]
    set to_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_pm_if|apps_pm_xmt_pme_sync|u_req_rd_clk_sync|sync_regs_s1*]
    apply_cdc_from_to_bit $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_pm_if|apps_pm_xmt_pme_sync|u_req_rd_clk_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_pm_if|apps_pm_xmt_pme_sync|u_req_rd_clk_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_pm_if|apps_pm_xmt_pme_sync|data_in_d0*]
    set to_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_pm_if|apps_pm_xmt_pme_sync|dout*]
    apply_cdc_sync_vec $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_pm_if|apps_pm_xmt_turnoff_sync|req_rd_clk_d0*]
    set to_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_pm_if|apps_pm_xmt_turnoff_sync|ack_wr_clk_sync|sync_regs_s1*]
    apply_cdc_from_to_bit $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_pm_if|apps_pm_xmt_turnoff_sync|ack_wr_clk_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_pm_if|apps_pm_xmt_turnoff_sync|ack_wr_clk_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_pm_if|apps_pm_xmt_turnoff_sync|req_wr_clk*]    
    set to_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_pm_if|apps_pm_xmt_turnoff_sync|req_rd_clk_sync|sync_regs_s1*]
    apply_cdc_from_to_bit $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_pm_if|apps_pm_xmt_turnoff_sync|req_rd_clk_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_pm_if|apps_pm_xmt_turnoff_sync|req_rd_clk_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_pm_if|app_init_rst_sync|req_rd_clk_d0*]
    set to_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_pm_if|app_init_rst_sync|ack_wr_clk_sync|sync_regs_s1*]
    apply_cdc_from_to_bit $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_pm_if|app_init_rst_sync|ack_wr_clk_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_pm_if|app_init_rst_sync|ack_wr_clk_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_pm_if|app_init_rst_sync|req_wr_clk*]
    set to_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_pm_if|app_init_rst_sync|req_rd_clk_sync|sync_regs_s1*]
    apply_cdc_from_to_bit $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_pm_if|app_init_rst_sync|req_rd_clk_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_pm_if|app_init_rst_sync|req_rd_clk_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_pm_if|app_ready_entr_l23_q]
    set to_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_pm_if|app_ready_entr_l23_sync|sync_regs_s1*]
    apply_cdc_from_to_bit $from_keep $to_keep
    
    set from_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_pm_if|app_ready_entr_l23_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_pm_if|app_ready_entr_l23_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_pm_if|app_xfer_pending_q*]
    set to_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_pm_if|app_xfer_pending_sync|sync_regs_s1*]
    apply_cdc_from_to_bit $from_keep $to_keep
    
    set from_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_pm_if|app_xfer_pending_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_pm_if|app_xfer_pending_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

    ##########################################################################################################################################
    ##########################################################################################################################################
    set from_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_hard_ip_status_if|ltssm_fifo|gx0|din_gry*]
    set to_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_hard_ip_status_if|ltssm_fifo|gx0|u_din_gry_sync|sync_regs_s1*]
    apply_cdc $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_hard_ip_status_if|ltssm_fifo|gx0|u_din_gry_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_hard_ip_status_if|ltssm_fifo|gx0|u_din_gry_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_hard_ip_status_if|link_up_q*]
    set to_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_hard_ip_status_if|link_up_sync|sync_regs_s1*]
    apply_cdc_from_to_bit $from_keep $to_keep
    
    set from_keep [get_keepers -nowarn  *|core16_x8_x4_adapter|u_hard_ip_status_if|link_up_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn  *|core16_x8_x4_adapter|u_hard_ip_status_if|link_up_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_hard_ip_status_if|dl_up_q*]
    set to_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_hard_ip_status_if|dl_up_sync|sync_regs_s1*]
    apply_cdc_from_to_bit $from_keep $to_keep
    
    set from_keep [get_keepers -nowarn  *|core16_x8_x4_adapter|u_hard_ip_status_if|dl_up_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn  *|core16_x8_x4_adapter|u_hard_ip_status_if|dl_up_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

#   dcore1
    set from_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_hard_ip_status_if|ltssm_fifo|gx0|din_gry*]
    set to_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_hard_ip_status_if|ltssm_fifo|gx0|u_din_gry_sync|sync_regs_s1*]
    apply_cdc $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_hard_ip_status_if|ltssm_fifo|gx0|u_din_gry_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_hard_ip_status_if|ltssm_fifo|gx0|u_din_gry_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_hard_ip_status_if|link_up_q*]
    set to_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_hard_ip_status_if|link_up_sync|sync_regs_s1*]
    apply_cdc_from_to_bit $from_keep $to_keep
    
    set from_keep [get_keepers -nowarn  *|core8_x8_x4_adapter|u_hard_ip_status_if|link_up_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn  *|core8_x8_x4_adapter|u_hard_ip_status_if|link_up_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_hard_ip_status_if|dl_up_q*]
    set to_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_hard_ip_status_if|dl_up_sync|sync_regs_s1*]
    apply_cdc_from_to_bit $from_keep $to_keep
    
    set from_keep [get_keepers -nowarn  *|core8_x8_x4_adapter|u_hard_ip_status_if|dl_up_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn  *|core8_x8_x4_adapter|u_hard_ip_status_if|dl_up_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

#dcore2
    set from_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_hard_ip_status_if|ltssm_fifo|gx0|din_gry*]
    set to_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_hard_ip_status_if|ltssm_fifo|gx0|u_din_gry_sync|sync_regs_s1*]
    apply_cdc $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_hard_ip_status_if|ltssm_fifo|gx0|u_din_gry_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_hard_ip_status_if|ltssm_fifo|gx0|u_din_gry_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_hard_ip_status_if|link_up_q*]
    set to_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_hard_ip_status_if|link_up_sync|sync_regs_s1*]
    apply_cdc_from_to_bit $from_keep $to_keep
    
    set from_keep [get_keepers -nowarn  *|core4_0_x8_x4_adapter|u_hard_ip_status_if|link_up_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn  *|core4_0_x8_x4_adapter|u_hard_ip_status_if|link_up_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_hard_ip_status_if|dl_up_q*]
    set to_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_hard_ip_status_if|dl_up_sync|sync_regs_s1*]
    apply_cdc_from_to_bit $from_keep $to_keep
    
    set from_keep [get_keepers -nowarn  *|core4_0_x8_x4_adapter|u_hard_ip_status_if|dl_up_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn  *|core4_0_x8_x4_adapter|u_hard_ip_status_if|dl_up_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep
    
#dcore3
    set from_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_hard_ip_status_if|ltssm_fifo|gx0|din_gry*]
    set to_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_hard_ip_status_if|ltssm_fifo|gx0|u_din_gry_sync|sync_regs_s1*]
    apply_cdc $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_hard_ip_status_if|ltssm_fifo|gx0|u_din_gry_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_hard_ip_status_if|ltssm_fifo|gx0|u_din_gry_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_hard_ip_status_if|link_up_q*]
    set to_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_hard_ip_status_if|link_up_sync|sync_regs_s1*]
    apply_cdc_from_to_bit $from_keep $to_keep
    
    set from_keep [get_keepers -nowarn  *|core4_1_x8_x4_adapter|u_hard_ip_status_if|link_up_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn  *|core4_1_x8_x4_adapter|u_hard_ip_status_if|link_up_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_hard_ip_status_if|dl_up_q*]
    set to_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_hard_ip_status_if|dl_up_sync|sync_regs_s1*]
    apply_cdc_from_to_bit $from_keep $to_keep
    
    set from_keep [get_keepers -nowarn  *|core4_1_x8_x4_adapter|u_hard_ip_status_if|dl_up_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn  *|core4_1_x8_x4_adapter|u_hard_ip_status_if|dl_up_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep
    ##########################################################################################################################################
    ##########################################################################################################################################

    set from_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_flr_if|flr_rcvd_pf_q*]
    set to_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_flr_if|flr_rcvd_pf_loop*|sync_regs_s1*]
    apply_cdc_from_to_bit $from_keep $to_keep
    
    set from_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_flr_if|flr_rcvd_pf_loop*|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_flr_if|flr_rcvd_pf_loop*|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep
    
    set from_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_flr_if|flr_rcvd_vf_fifo|gx0|din_gry*]
    set to_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_flr_if|flr_rcvd_vf_fifo|gx0|u_din_gry_sync|sync_regs_s1*]
    apply_cdc $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_flr_if|flr_rcvd_vf_fifo|gx0|u_din_gry_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_flr_if|flr_rcvd_vf_fifo|gx0|u_din_gry_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_flr_if|flr_completed_pf_loop*|req_rd_clk_d0*]
    set to_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_flr_if|flr_completed_pf_loop*|ack_wr_clk_sync|sync_regs_s1*]
    apply_cdc_from_to_bit $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_flr_if|flr_completed_pf_loop*|ack_wr_clk_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_flr_if|flr_completed_pf_loop*|ack_wr_clk_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_flr_if|flr_completed_pf_loop*|req_wr_clk*]
    set to_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_flr_if|flr_completed_pf_loop*|req_rd_clk_sync|sync_regs_s1*]
    apply_cdc_from_to_bit $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_flr_if|flr_completed_pf_loop*|req_rd_clk_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_flr_if|flr_completed_pf_loop*|req_rd_clk_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_flr_if|flr_completed_vf_fifo|gx0|din_gry*]
    set to_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_flr_if|flr_completed_vf_fifo|gx0|u_din_gry_sync|sync_regs_s1*]
    apply_cdc $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_flr_if|flr_completed_vf_fifo|gx0|u_din_gry_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_flr_if|flr_completed_vf_fifo|gx0|u_din_gry_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

#   dcore1

    set from_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_flr_if|flr_rcvd_pf_q*]
    set to_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_flr_if|flr_rcvd_pf_loop*|sync_regs_s1*]
    apply_cdc_from_to_bit $from_keep $to_keep
    
    set from_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_flr_if|flr_rcvd_pf_loop*|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_flr_if|flr_rcvd_pf_loop*|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep
    
    set from_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_flr_if|flr_rcvd_vf_fifo|gx0|din_gry*]
    set to_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_flr_if|flr_rcvd_vf_fifo|gx0|u_din_gry_sync|sync_regs_s1*]
    apply_cdc $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_flr_if|flr_rcvd_vf_fifo|gx0|u_din_gry_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_flr_if|flr_rcvd_vf_fifo|gx0|u_din_gry_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_flr_if|flr_completed_pf_loop*|req_rd_clk_d0*]
    set to_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_flr_if|flr_completed_pf_loop*|ack_wr_clk_sync|sync_regs_s1*]
    apply_cdc_from_to_bit $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_flr_if|flr_completed_pf_loop*|ack_wr_clk_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_flr_if|flr_completed_pf_loop*|ack_wr_clk_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_flr_if|flr_completed_pf_loop*|req_wr_clk*]
    set to_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_flr_if|flr_completed_pf_loop*|req_rd_clk_sync|sync_regs_s1*]
    apply_cdc_from_to_bit $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_flr_if|flr_completed_pf_loop*|req_rd_clk_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_flr_if|flr_completed_pf_loop*|req_rd_clk_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_flr_if|flr_completed_vf_fifo|gx0|din_gry*]
    set to_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_flr_if|flr_completed_vf_fifo|gx0|u_din_gry_sync|sync_regs_s1*]
    apply_cdc $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_flr_if|flr_completed_vf_fifo|gx0|u_din_gry_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_flr_if|flr_completed_vf_fifo|gx0|u_din_gry_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

#dcore2
    set from_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_flr_if|flr_rcvd_pf_q*]
    set to_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_flr_if|flr_rcvd_pf_loop*|sync_regs_s1*]
    apply_cdc_from_to_bit $from_keep $to_keep
    
    set from_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_flr_if|flr_rcvd_pf_loop*|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_flr_if|flr_rcvd_pf_loop*|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep
    
    set from_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_flr_if|flr_rcvd_vf_fifo|gx0|din_gry*]
    set to_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_flr_if|flr_rcvd_vf_fifo|gx0|u_din_gry_sync|sync_regs_s1*]
    apply_cdc $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_flr_if|flr_rcvd_vf_fifo|gx0|u_din_gry_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_flr_if|flr_rcvd_vf_fifo|gx0|u_din_gry_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_flr_if|flr_completed_pf_loop*|req_rd_clk_d0*]
    set to_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_flr_if|flr_completed_pf_loop*|ack_wr_clk_sync|sync_regs_s1*]
    apply_cdc_from_to_bit $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_flr_if|flr_completed_pf_loop*|ack_wr_clk_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_flr_if|flr_completed_pf_loop*|ack_wr_clk_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_flr_if|flr_completed_pf_loop*|req_wr_clk*]
    set to_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_flr_if|flr_completed_pf_loop*|req_rd_clk_sync|sync_regs_s1*]
    apply_cdc_from_to_bit $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_flr_if|flr_completed_pf_loop*|req_rd_clk_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_flr_if|flr_completed_pf_loop*|req_rd_clk_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_flr_if|flr_completed_vf_fifo|gx0|din_gry*]
    set to_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_flr_if|flr_completed_vf_fifo|gx0|u_din_gry_sync|sync_regs_s1*]
    apply_cdc $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_flr_if|flr_completed_vf_fifo|gx0|u_din_gry_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_flr_if|flr_completed_vf_fifo|gx0|u_din_gry_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

#dcore3
    set from_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_flr_if|flr_rcvd_pf_q*]
    set to_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_flr_if|flr_rcvd_pf_loop*|sync_regs_s1*]
    apply_cdc_from_to_bit $from_keep $to_keep
    
    set from_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_flr_if|flr_rcvd_pf_loop*|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_flr_if|flr_rcvd_pf_loop*|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep
    
    set from_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_flr_if|flr_rcvd_vf_fifo|gx0|din_gry*]
    set to_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_flr_if|flr_rcvd_vf_fifo|gx0|u_din_gry_sync|sync_regs_s1*]
    apply_cdc $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_flr_if|flr_rcvd_vf_fifo|gx0|u_din_gry_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_flr_if|flr_rcvd_vf_fifo|gx0|u_din_gry_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_flr_if|flr_completed_pf_loop*|req_rd_clk_d0*]
    set to_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_flr_if|flr_completed_pf_loop*|ack_wr_clk_sync|sync_regs_s1*]
    apply_cdc_from_to_bit $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_flr_if|flr_completed_pf_loop*|ack_wr_clk_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_flr_if|flr_completed_pf_loop*|ack_wr_clk_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_flr_if|flr_completed_pf_loop*|req_wr_clk*]
    set to_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_flr_if|flr_completed_pf_loop*|req_rd_clk_sync|sync_regs_s1*]
    apply_cdc_from_to_bit $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_flr_if|flr_completed_pf_loop*|req_rd_clk_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_flr_if|flr_completed_pf_loop*|req_rd_clk_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_flr_if|flr_completed_vf_fifo|gx0|din_gry*]
    set to_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_flr_if|flr_completed_vf_fifo|gx0|u_din_gry_sync|sync_regs_s1*]
    apply_cdc $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_flr_if|flr_completed_vf_fifo|gx0|u_din_gry_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_flr_if|flr_completed_vf_fifo|gx0|u_din_gry_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep
    ##########################################################################################################################################
    ##########################################################################################################################################
    set from_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_int_if|app_int_q*]
    set to_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_int_if|app_int_loop*|sync_regs_s1*]
    apply_cdc_from_to_bit $from_keep $to_keep
    
    set from_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_int_if|app_int_loop*|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_int_if|app_int_loop*|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep
    
    set from_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_int_if|int_status_sync|req_rd_clk_d0*]
    set to_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_int_if|int_status_sync|ack_wr_clk_sync|sync_regs_s1*]
    apply_cdc_from_to_bit $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_int_if|int_status_sync|ack_wr_clk_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_int_if|int_status_sync|ack_wr_clk_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_int_if|int_status_sync|req_wr_clk*]
    set to_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_int_if|int_status_sync|req_rd_clk_sync|sync_regs_s1*]
    apply_cdc_from_to_bit $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_int_if|int_status_sync|req_rd_clk_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_int_if|int_status_sync|req_rd_clk_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_int_if|msififo|gx0|din_gry*]
    set to_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_int_if|msififo|gx0|u_din_gry_sync|sync_regs_s1*]
    apply_cdc $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_int_if|msififo|gx0|u_din_gry_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_int_if|msififo|gx0|u_din_gry_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

#   dcore1
    set from_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_int_if|app_int_q*]
    set to_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_int_if|app_int_loop*|sync_regs_s1*]
    apply_cdc_from_to_bit $from_keep $to_keep
    
    set from_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_int_if|app_int_loop*|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_int_if|app_int_loop*|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep
    
    set from_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_int_if|int_status_sync|req_rd_clk_d0*]
    set to_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_int_if|int_status_sync|ack_wr_clk_sync|sync_regs_s1*]
    apply_cdc_from_to_bit $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_int_if|int_status_sync|ack_wr_clk_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_int_if|int_status_sync|ack_wr_clk_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_int_if|int_status_sync|req_wr_clk*]
    set to_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_int_if|int_status_sync|req_rd_clk_sync|sync_regs_s1*]
    apply_cdc_from_to_bit $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_int_if|int_status_sync|req_rd_clk_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_int_if|int_status_sync|req_rd_clk_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_int_if|msififo|gx0|din_gry*]
    set to_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_int_if|msififo|gx0|u_din_gry_sync|sync_regs_s1*]
    apply_cdc $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_int_if|msififo|gx0|u_din_gry_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_int_if|msififo|gx0|u_din_gry_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

#dcore2
    set from_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_int_if|app_int_q*]
    set to_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_int_if|app_int_loop*|sync_regs_s1*]
    apply_cdc_from_to_bit $from_keep $to_keep
    
    set from_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_int_if|app_int_loop*|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_int_if|app_int_loop*|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep
    
    set from_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_int_if|int_status_sync|req_rd_clk_d0*]
    set to_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_int_if|int_status_sync|ack_wr_clk_sync|sync_regs_s1*]
    apply_cdc_from_to_bit $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_int_if|int_status_sync|ack_wr_clk_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_int_if|int_status_sync|ack_wr_clk_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_int_if|int_status_sync|req_wr_clk*]
    set to_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_int_if|int_status_sync|req_rd_clk_sync|sync_regs_s1*]
    apply_cdc_from_to_bit $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_int_if|int_status_sync|req_rd_clk_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_int_if|int_status_sync|req_rd_clk_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_int_if|msififo|gx0|din_gry*]
    set to_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_int_if|msififo|gx0|u_din_gry_sync|sync_regs_s1*]
    apply_cdc $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_int_if|msififo|gx0|u_din_gry_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_int_if|msififo|gx0|u_din_gry_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep
    
#dcore3
    set from_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_int_if|app_int_q*]
    set to_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_int_if|app_int_loop*|sync_regs_s1*]
    apply_cdc_from_to_bit $from_keep $to_keep
    
    set from_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_int_if|app_int_loop*|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_int_if|app_int_loop*|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep
    
    set from_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_int_if|int_status_sync|req_rd_clk_d0*]
    set to_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_int_if|int_status_sync|ack_wr_clk_sync|sync_regs_s1*]
    apply_cdc_from_to_bit $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_int_if|int_status_sync|ack_wr_clk_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_int_if|int_status_sync|ack_wr_clk_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_int_if|int_status_sync|req_wr_clk*]
    set to_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_int_if|int_status_sync|req_rd_clk_sync|sync_regs_s1*]
    apply_cdc_from_to_bit $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_int_if|int_status_sync|req_rd_clk_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_int_if|int_status_sync|req_rd_clk_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_int_if|msififo|gx0|din_gry*]
    set to_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_int_if|msififo|gx0|u_din_gry_sync|sync_regs_s1*]
    apply_cdc $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_int_if|msififo|gx0|u_din_gry_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_int_if|msififo|gx0|u_din_gry_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

    ##########################################################################################################################################
    ##########################################################################################################################################

    set from_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_err_if|serr_out_sync|req_rd_clk_d0*]
    set to_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_err_if|serr_out_sync|ack_wr_clk_sync|sync_regs_s1*]
    apply_cdc_from_to_bit $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_err_if|serr_out_sync|ack_wr_clk_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_err_if|serr_out_sync|ack_wr_clk_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_err_if|serr_out_sync|req_wr_clk*]
    set to_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_err_if|serr_out_sync|req_rd_clk_sync|sync_regs_s1*]
    apply_cdc_from_to_bit $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_err_if|serr_out_sync|req_rd_clk_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_err_if|serr_out_sync|req_rd_clk_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep
    
    set from_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_err_if|hip_enter_err_mode_sync|req_rd_clk_d0*]
    set to_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_err_if|hip_enter_err_mode_sync|ack_wr_clk_sync|sync_regs_s1*]
    apply_cdc_from_to_bit $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_err_if|hip_enter_err_mode_sync|ack_wr_clk_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_err_if|hip_enter_err_mode_sync|ack_wr_clk_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_err_if|hip_enter_err_mode_sync|req_wr_clk*]
    set to_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_err_if|hip_enter_err_mode_sync|req_rd_clk_sync|sync_regs_s1*]
    apply_cdc_from_to_bit $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_err_if|hip_enter_err_mode_sync|req_rd_clk_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_err_if|hip_enter_err_mode_sync|req_rd_clk_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep
    
    set from_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_err_if|app_err_data_fifo|gx0|din_gry*]
    set to_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_err_if|app_err_data_fifo|gx0|u_din_gry_sync|sync_regs_s1*]
    apply_cdc $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_err_if|app_err_data_fifo|gx0|u_din_gry_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core16_x8_x4_adapter|u_err_if|app_err_data_fifo|gx0|u_din_gry_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep
    
    set from_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_err_if|serr_out_sync|req_rd_clk_d0*]
    set to_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_err_if|serr_out_sync|ack_wr_clk_sync|sync_regs_s1*]
    apply_cdc_from_to_bit $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_err_if|serr_out_sync|ack_wr_clk_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_err_if|serr_out_sync|ack_wr_clk_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_err_if|serr_out_sync|req_wr_clk*]
    set to_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_err_if|serr_out_sync|req_rd_clk_sync|sync_regs_s1*]
    apply_cdc_from_to_bit $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_err_if|serr_out_sync|req_rd_clk_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_err_if|serr_out_sync|req_rd_clk_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep
    
    set from_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_err_if|hip_enter_err_mode_sync|req_rd_clk_d0*]
    set to_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_err_if|hip_enter_err_mode_sync|ack_wr_clk_sync|sync_regs_s1*]
    apply_cdc_from_to_bit $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_err_if|hip_enter_err_mode_sync|ack_wr_clk_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_err_if|hip_enter_err_mode_sync|ack_wr_clk_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_err_if|hip_enter_err_mode_sync|req_wr_clk*]
    set to_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_err_if|hip_enter_err_mode_sync|req_rd_clk_sync|sync_regs_s1*]
    apply_cdc_from_to_bit $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_err_if|hip_enter_err_mode_sync|req_rd_clk_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_err_if|hip_enter_err_mode_sync|req_rd_clk_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep
    
    set from_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_err_if|app_err_data_fifo|gx0|din_gry*]
    set to_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_err_if|app_err_data_fifo|gx0|u_din_gry_sync|sync_regs_s1*]
    apply_cdc $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_err_if|app_err_data_fifo|gx0|u_din_gry_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core8_x8_x4_adapter|u_err_if|app_err_data_fifo|gx0|u_din_gry_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

#dcore2
   set from_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_err_if|serr_out_sync|req_rd_clk_d0*]
    set to_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_err_if|serr_out_sync|ack_wr_clk_sync|sync_regs_s1*]
    apply_cdc_from_to_bit $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_err_if|serr_out_sync|ack_wr_clk_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_err_if|serr_out_sync|ack_wr_clk_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_err_if|serr_out_sync|req_wr_clk*]
    set to_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_err_if|serr_out_sync|req_rd_clk_sync|sync_regs_s1*]
    apply_cdc_from_to_bit $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_err_if|serr_out_sync|req_rd_clk_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_err_if|serr_out_sync|req_rd_clk_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep
    
    set from_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_err_if|hip_enter_err_mode_sync|req_rd_clk_d0*]
    set to_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_err_if|hip_enter_err_mode_sync|ack_wr_clk_sync|sync_regs_s1*]
    apply_cdc_from_to_bit $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_err_if|hip_enter_err_mode_sync|ack_wr_clk_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_err_if|hip_enter_err_mode_sync|ack_wr_clk_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_err_if|hip_enter_err_mode_sync|req_wr_clk*]
    set to_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_err_if|hip_enter_err_mode_sync|req_rd_clk_sync|sync_regs_s1*]
    apply_cdc_from_to_bit $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_err_if|hip_enter_err_mode_sync|req_rd_clk_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_err_if|hip_enter_err_mode_sync|req_rd_clk_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep
    
    set from_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_err_if|app_err_data_fifo|gx0|din_gry*]
    set to_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_err_if|app_err_data_fifo|gx0|u_din_gry_sync|sync_regs_s1*]
    apply_cdc $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_err_if|app_err_data_fifo|gx0|u_din_gry_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core4_0_x8_x4_adapter|u_err_if|app_err_data_fifo|gx0|u_din_gry_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep
    
#dcore3
   set from_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_err_if|serr_out_sync|req_rd_clk_d0*]
    set to_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_err_if|serr_out_sync|ack_wr_clk_sync|sync_regs_s1*]
    apply_cdc_from_to_bit $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_err_if|serr_out_sync|ack_wr_clk_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_err_if|serr_out_sync|ack_wr_clk_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_err_if|serr_out_sync|req_wr_clk*]
    set to_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_err_if|serr_out_sync|req_rd_clk_sync|sync_regs_s1*]
    apply_cdc_from_to_bit $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_err_if|serr_out_sync|req_rd_clk_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_err_if|serr_out_sync|req_rd_clk_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep
    
    set from_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_err_if|hip_enter_err_mode_sync|req_rd_clk_d0*]
    set to_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_err_if|hip_enter_err_mode_sync|ack_wr_clk_sync|sync_regs_s1*]
    apply_cdc_from_to_bit $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_err_if|hip_enter_err_mode_sync|ack_wr_clk_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_err_if|hip_enter_err_mode_sync|ack_wr_clk_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_err_if|hip_enter_err_mode_sync|req_wr_clk*]
    set to_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_err_if|hip_enter_err_mode_sync|req_rd_clk_sync|sync_regs_s1*]
    apply_cdc_from_to_bit $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_err_if|hip_enter_err_mode_sync|req_rd_clk_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_err_if|hip_enter_err_mode_sync|req_rd_clk_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep
    
    set from_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_err_if|app_err_data_fifo|gx0|din_gry*]
    set to_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_err_if|app_err_data_fifo|gx0|u_din_gry_sync|sync_regs_s1*]
    apply_cdc $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_err_if|app_err_data_fifo|gx0|u_din_gry_sync|sync_regs_s1*]
    set to_keep [get_keepers -nowarn *|core4_1_x8_x4_adapter|u_err_if|app_err_data_fifo|gx0|u_din_gry_sync|sync_regs_s2*]
    apply_cdc_mstable_delay $from_keep $to_keep
    ##########################################################################################################################################
    ##########################################################################################################################################
    set from_keep [get_keepers -nowarn ${inst}*|soft_logics|rst_ctrl|p0_rst_tree|reset_status_tree*]
    set to_keep [get_keepers -nowarn *|inst|p0_rst_n_clk250_s*]
    apply_cdc_from_to_bit $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|inst|p0_rst_n_clk250_s]
    set to_keep [get_keepers -nowarn *|inst|p0_rst_n_clk250_ss]
    apply_cdc_mstable_delay $from_keep $to_keep

    set from_keep [get_keepers -nowarn ${inst}*|soft_logics|rst_ctrl|p1_rst_tree|reset_status_tree*]
    set to_keep [get_keepers -nowarn *|inst|p1_rst_n_clk250_s*]
    apply_cdc_from_to_bit $from_keep $to_keep

    set from_keep [get_keepers -nowarn *|inst|p1_rst_n_clk250_s]
    set to_keep [get_keepers -nowarn *|inst|p1_rst_n_clk250_ss]
    apply_cdc_mstable_delay $from_keep $to_keep

    set from_keep [get_keepers -nowarn ${inst}*|soft_logics|rst_ctrl|p2_rst_tree|reset_status_tree*]
    set to_keep [get_keepers -nowarn *|inst|p2_rst_n_clk250_s*]
    apply_cdc_from_to_bit $from_keep $to_keep
    
    set from_keep [get_keepers -nowarn *|inst|p2_rst_n_clk250_s]
    set to_keep [get_keepers -nowarn *|inst|p2_rst_n_clk250_ss]
    apply_cdc_mstable_delay $from_keep $to_keep
    
    set from_keep [get_keepers -nowarn ${inst}*|soft_logics|rst_ctrl|p3_rst_tree|reset_status_tree*]
    set to_keep [get_keepers -nowarn *|inst|p3_rst_n_clk250_s*]
    apply_cdc_from_to_bit $from_keep $to_keep
    
    set from_keep [get_keepers -nowarn *|inst|p3_rst_n_clk250_s]
    set to_keep [get_keepers -nowarn *|inst|p3_rst_n_clk250_ss]
    apply_cdc_mstable_delay $from_keep $to_keep
}


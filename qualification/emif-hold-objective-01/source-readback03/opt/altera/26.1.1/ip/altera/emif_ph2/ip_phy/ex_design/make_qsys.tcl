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


# This script is invoked during example design generation to define
# the example design system (both for synthesis and simulation) and
# saving these systems to .qsys files. The script uses the QSys System
# Scripting feature to create and define QSYS systems programmatically.
#
# Inputs and Outputs
# ==================
#
# Inputs to this script comes from a params.tcl file, which is generated
# dynamically as part of example design fileset generation, and which
# captures all the IP parameters as specified by the customer. Using these
# parameters, the script can instantiate EMIFs (and other components) using
# the same parameterization requested by users.
#
# The script is expected to be called by qsys-script in the following manner:
#
# qsys-script --cmd='source <full path to params.tcl>' --script=make_qsys.tcl
#


# ref_clk  ----------------------------------------------+
#                                                        |
#                                                        |
#                                                        |
#                  +--------+   +----+                   |
#                  |        +-->|    |------+            |
#                  |  RRIP  |   | RH |      |            |
#                  |        |   |    |      |            |
#                  +--------+   +----+      |            |
#                                        +--v------------v--+
#                                        |                  |
#                  +------------+        |                  |
#                  |            <--------+       EMIF       <------->
#                  |    TG      |        |                  |
#                  |            <-------->                  |
#                  |            <--------+                  |
#                  +------------+        +------------------+
#                                                  ^
#                                                  |
#     FABRIC SYNC MODE                       +-----+-----+
#                                            |           |
#                                            |  CALIP    |
#                                            |           |
#                                            +-----------+




# ref_clk-------------------------------------------------------------------------+
#                                                                                 |
#                                                                                 |
#                               +=======+                                         |
# ref_clk_usr_pll-------------->|       |                                         |
#                 +=====+       |  PLL  |------------+--------------+             |
#                 |RRIP +---+-->|       |            |              |             |
#                 +=====+   |   +=======+            |              |             |
#                           |       |                |              |             |
#                           |   +===v===+            |              |             |
#                           |   |       |------------u----------+   v             v
#                           +-->|  RH   |            |          v   |             |
#                               |       |            |       +=======================+
#                               +=======+            |       |                       |
#                         +===========+              |       |                       |
#                         |           |<-------------+       |                       |
#                         |           |                      |                       |
#                         |     TG    |<-------------------->|         EMIF          |<-------------->
#                         |           |                      |                       |
#                         |           |<-------------------->|                       |
#                         +===========+                      |                       |
#                                                            |                       |
#                                                            +=======================+
#                                                                        ^
#          FABRIC ASYNC MODE                                             |
#                                                                        |
#                                                                        |
#                                                                        V
#                                                                  +============+
#                                                                  |            |
#                                                                  |   CALIP    |
#                                                                  |            |
#                                                                  +============+


#   ref_clk----------------------------------------------------------------------------+
#                                                                                      |
#                              +=======+                                               |
# ref_clk_usr_pll------------->|       |                                               |
#              +=====+         |  PLL  |-------+                                       |
#              |RRIP +-----+-->|       |       |                                       |
#              +=====+     |   +=======+       |                                       |
#                          |       |           |                                       |
#                          |   +===v===+       |                                       |
#                          |   |       |---+   |                                       |
#                          +-->|  RH   |   |   |                                       v
#                              |       |   |   |                  +=======================+
#                              +=======+   |   |                  |                       |
#                        +===========+     |   |    +====+        | +====+                |
#                        |           |<----+---u--->|    |        | |    |                |
#                        |           |         |    |iniu|        | |tniu|                |
#                        |     TG    |<--------+----|    |        | |    |  EMIF          |<-------------->
#                        |           |              |    |        | |    |                |
#                        |           |<------------>|    |        | |    |                |
#                        +===========+              +====+        | +====+                |
#                                                                 |                       |
#                                                                 +=======================+
#                                                                             ^
#            NOC MODE                                                         |
#                                                                             |
#                                                                             |
#                                                                             V
#                                                                       +============+
#                                                                       |            |
#                                                                       |   CALIP    |
#                                                                       |            |
#                                                                       +============+


package require -exact qsys 23.1

if {! [info exists ip_params] || ! [info exists ed_params]} {
   source "params.tcl"
}

# create a list of param name/value pairs for use by set_instance_parameter_values
# which is much faster than calling set_instance_parameter_value one by one.
set ip_param_lst [list]
foreach param_name [array names ip_params] {
   lappend ip_param_lst $param_name
   lappend ip_param_lst $ip_params($param_name)
}

set_project_property DEVICE_FAMILY $ip_params(SYS_INFO_DEVICE_FAMILY)
set_project_property DEVICE        $ip_params(SYS_INFO_DEVICE)

set module_prefix ""

###############################################################################
# System creation
###############################################################################
proc gen_sys {design_type} {
    upvar ip_params     ip_params
    upvar ed_params     ed_params
    upvar ip_param_lst  ip_param_lst
    upvar family_traits family_traits
    upvar arch_params   arch_params

    set TECH                  [lindex [split [get_ip_param MEM_TECHNOLOGY] "_"] 2]
    set FORMAT                [lindex [split [get_ip_param MEM_FORMAT] "_"] 2]
    set tech                  [string tolower $TECH]
    set num_channels          [get_ip_param MEM_NUM_CHANNELS]
    set num_channels_per_io96 [get_ip_param MEM_NUM_CHANNELS_PER_IO96]
    set num_arch_cal_ips      [get_ip_param MEM_NUM_IO96]
    set num_refclks           1  ; # TODO: update 1 refclk/1 channel?

    # Setting all the instance names here, so that renaming is easy
    set emif            $ed_params(EMIF_NAME)
    set tg              traffic_generator
    set hydra           traffic_generator;#hydra
    set rrip            rrip
    set rrip2           rrip2
    set user_pll        user_pll
    set noc_init        $ed_params(NOC_INIT_NAME)
    set noc_init_lite_0 $ed_params(NOC_INIT_LITE_NAME)_0
    set noc_init_lite_1 $ed_params(NOC_INIT_LITE_NAME)_1
    set noc_ctrl        $ed_params(NOC_CTRL_NAME)
    set axil_driver_0   axil_driver_0
    set axil_driver_1   axil_driver_1
    set reset_handler   reset_handler
    set pmon            perf_mon

    # set fab_mode_reset_handler   fab_mode_reset_handler

    set extra_config_str        [get_ip_param DIAG_EXTRA_PARAMETERS]
    array set extra_config_arr  [parse_extra_configs $extra_config_str]
    set user_config_str         [get_ip_param USER_EXTRA_PARAMETERS]
    array set user_config_arr   [parse_extra_configs $user_config_str]

    # Hardcode the Async IOPLL reference clock rate as 50% that of the EMIF Ref clock rate during simulation,
    # and identical to the clock rate during synthesis.
    # Users should modify the PLL configuration in fabric-async and NOC mode so that is reference clock settings
    # matchs the actual async reference clock that is connected to the example design.
    set async_refclk_sim_freq       392000000
    set async_refclk_sim_freq_mhz   [expr {round($async_refclk_sim_freq / 1000000)}]

    set user_access_mode "fabric_sync"
    if {[string is true [get_ip_param PHY_ASYNC_EN]]} {
        set user_access_mode "fabric_async"
    }
    if {[string is true [get_ip_param PHY_NOC_EN]]} {
        set user_access_mode "noc"
    }

    set usr_reference_clock_frequency $async_refclk_sim_freq_mhz
    set usr_clock_frequency $usr_reference_clock_frequency
    if {$design_type == "synth"} {
       # Give priority to the DIAG_EXTRA_PARAMETERS way to set the usr_clock_frequency
       # as it existed before the GUI way
       if {[info exists extra_config_arr(USR_CLK_FREQ_OVRD)]} {
          set usr_reference_clock_frequency 100
          set usr_clock_frequency $extra_config_arr(USR_CLK_FREQ_OVRD)
       } else {
          set usr_reference_clock_frequency [get_ip_param EX_DESIGN_CORE_REFCLK_FREQ_MHZ]
          set usr_clock_frequency [get_ip_param EX_DESIGN_CORE_CLK_FREQ_MHZ]
       }
    }

    if {$user_access_mode == "fabric_sync"} {
       if {[get_ip_param PHY_C2M_RATE]=="PHY_C2M_RATE_SYNC_HR"} {
          set mem_core_div 4
       } else {
          set mem_core_div 8
       }
       if {$TECH == "LPDDR5"} {
          set hydra_jtag_clock_freq_mhz [expr {[get_ip_param PHY_MEMCLK_FSP0_FREQ_MHZ] / $mem_core_div}]
       } else {
          set hydra_jtag_clock_freq_mhz [expr {[get_ip_param PHY_MEMCLK_FREQ_MHZ] / $mem_core_div}]
       }
    } else {
       set hydra_jtag_clock_freq_mhz $usr_clock_frequency
    }

    # Set the module prefix used in add_component_helper
    if {$design_type == "synth"} {
       set module_prefix "ed_synth_"
    }
    if {$design_type == "sim"} {
       set module_prefix "ed_sim_"
    }

    ## =============  EMIF IP ======================
    #                     Component Name  Component Type
    add_component_helper  $emif           emif_ph2
    load_component $emif
    set_component_parameter_values $ip_param_lst
    save_component; # $emif

    if {[info exists extra_config_arr(ENABLE_BCM_SIM)] && [expr {$design_type == "synth"}]} {
       set use_hydra_status_if $extra_config_arr(ENABLE_BCM_SIM)
    } else {
       set use_hydra_status_if "false"
    }

    # Calculate the number of DQ bits used for user bits (not controller generated ECC)
    set is_comp          [expr {[get_ip_param MEM_FORMAT]=="MEM_FORMAT_DISCRETE"}]
    set nominal_dq_width [get_ip_param MEM_DEVICE_DQ_WIDTH]
    set comp_per_rank    [get_ip_param MEM_COMPS_PER_RANK]
    set user_dq_width    0
    if {$is_comp == 1} {
       set user_dq_width [expr {$nominal_dq_width * $comp_per_rank}]
    } else {
       set user_dq_width $nominal_dq_width
    }
    set total_dq_width [get_ip_param MEM_TOTAL_DQ_WIDTH]
    set extra_dq_width 0
    set is_lockstep    [expr { $total_dq_width > 63 && $num_channels == 1 } ]
    ## =============  AXI-Lite  Driver IP ==============================
    set sideband_in_use [expr {[get_ip_param AXI_SIDEBAND_ACCESS_MODE] != "OFF"}]
    set sideband_is_noc [expr {[get_ip_param AXI_SIDEBAND_ACCESS_MODE] == "NOC"}]
    set debug_tools_en [expr {[info exists user_config_arr(EN_CAL_RB_DPRINT)]  ||
                              [get_ip_param DEBUG_TOOLS_EN] }]

    if {$sideband_in_use} {
       add_component_helper $axil_driver_0 emif_ph2_axil_driver
       load_component $axil_driver_0
         if {$sideband_is_noc} {
           set_component_parameter_value AXIL_DRIVER_ADDRESS_WIDTH    44
         } else {
           set_component_parameter_value AXIL_DRIVER_ADDRESS_WIDTH    32
         }
       save_component; # $axil_driver_0

       if {$num_arch_cal_ips != 1 && !$is_lockstep} {
          add_component_helper $axil_driver_1 emif_ph2_axil_driver
          load_component $axil_driver_1
             if {$sideband_is_noc} {
                set_component_parameter_value AXIL_DRIVER_ADDRESS_WIDTH    44
             } else {
                set_component_parameter_value AXIL_DRIVER_ADDRESS_WIDTH    32
             }
          save_component; # $axil_driver_1
       }
    }
    #remove option to use old tg; TODO: delete this commented out code (+remove tg_axi) once we confirm nothing relies on it
    set use_hydra "true"
    ## keep TG for ISM flow for now
#    if {[info exists extra_config_arr(USE_HYDRA)]} {
#       set use_hydra $extra_config_arr(USE_HYDRA)
#    } else {
#       set use_hydra "true"
#    }
    if {$use_hydra || ( $total_dq_width > $user_dq_width)} {
       ## =============  HYDRA Traffic Generator ======================
       ## only hydra supports AXI User data
       set dq_ratio [expr {[get_ip_param AXI4_DATA_WIDTH] / $user_dq_width}]
       if {[get_ip_param AXI4_USER_DATA_ENABLE_AUTO_BOOL]} {
          set has_user_bits [get_ip_param AXI4_USER_DATA_ENABLE_AUTO]
       } else {
          set has_user_bits [get_ip_param AXI4_USER_DATA_ENABLE]
       }
       if {$has_user_bits} {
         set extra_dq_width [expr { $user_access_mode == "noc" ? 4 : 8 } ]
       }
       set axi_user_width [expr {[get_ip_param AXI4_DATA_WIDTH] + $dq_ratio * $extra_dq_width} ]

       # calculate the number of valid address bits
       set mem_capacity_bytes [expr { ( $arch_params(MEM_CAPACITY_GBITS) / 8.0) * 1073741824 } ] ;# That huge number at the end is just 1 GiB. For some reason TCL is refusing to cooperate when it comes to exponents >:(
       # the below loop implements clog2(). Cannot use log() because floating point errors can make some calculations inaccurate once the logarithm result is ceiling'd
       set value $mem_capacity_bytes
       set valid_addr_width 0
       while {$value > 1} {
         set value [expr {$value / 2}]
         incr valid_addr_width
       }

       add_component_helper $hydra hydra
       load_component $hydra
          set_component_parameter_value  IS_SIMULATION                     [expr {$design_type == "sim"}]
          set_component_parameter_value  IOPLL_REF_CLK_FREQ_MHZ            $async_refclk_sim_freq_mhz;#what should this be??
          set_component_parameter_value  CONFIG_INTF_MODE                  "CONFIG_INTF_MODE_REMOTE_JTAG";#[expr {$ed_params(DEBUG_HYDRA_ENABLE_REMOTE_ACCESS) ? "CONFIG_INTF_MODE_REMOTE_JTAG" : "CONFIG_INTF_MODE_EXPORT"}]
          set_component_parameter_value  REMOTE_INTF_PRODUCE_CLK_RESET     "false";#$ed_params(DEBUG_HYDRA_ENABLE_REMOTE_ACCESS)
          set_component_parameter_value  REMOTE_INTF_CLK_FREQ_MHZ          $hydra_jtag_clock_freq_mhz;#$ed_params(DEBUG_HYDRA_ENABLE_REMOTE_ACCESS)
          set_component_parameter_value  EXPORT_STATUS_INTF                $use_hydra_status_if

          set_component_parameter_value  NUM_DRIVERS                       $num_channels

          for {set ch_idx 0} {$ch_idx < $num_channels} {incr ch_idx} {
             set_component_parameter_value  DRIVER_${ch_idx}_TYPE_ENUM                     DRIVER_TYPE_MEM_AXI4
             set_component_parameter_value  DRIVER_${ch_idx}_MEM_AXI4_DATA_DQ_RATIO        $dq_ratio
             set_component_parameter_value  DRIVER_${ch_idx}_MEM_AXI4_ADDR_ALU_ARG_WIDTH   $valid_addr_width

             set_component_parameter_value  DRIVER_${ch_idx}_MEM_AXI4_AWID_WIDTH           7;#$msa_ddr4_params(AXI_ID_WIDTH_${intf_idx})
             set_component_parameter_value  DRIVER_${ch_idx}_MEM_AXI4_AWADDR_WIDTH         $arch_params(AXI4_ADDR_WIDTH)
             set_component_parameter_value  DRIVER_${ch_idx}_MEM_AXI4_USE_AWLOCK           1
             set_component_parameter_value  DRIVER_${ch_idx}_MEM_AXI4_USE_AWCACHE          1
             set_component_parameter_value  DRIVER_${ch_idx}_MEM_AXI4_USE_AWPROT           1
             set_component_parameter_value  DRIVER_${ch_idx}_MEM_AXI4_USE_AWQOS            0
             set_component_parameter_value  DRIVER_${ch_idx}_MEM_AXI4_USE_AWREGION         0
             set_component_parameter_value  DRIVER_${ch_idx}_MEM_AXI4_USE_AWUSER           1
             set_component_parameter_value  DRIVER_${ch_idx}_MEM_AXI4_AWUSER_WIDTH         1

             set_component_parameter_value  DRIVER_${ch_idx}_MEM_AXI4_ARID_WIDTH           7;#$msa_ddr4_params(AXI_ID_WIDTH_${intf_idx})
             set_component_parameter_value  DRIVER_${ch_idx}_MEM_AXI4_ARADDR_WIDTH         $arch_params(AXI4_ADDR_WIDTH)
             set_component_parameter_value  DRIVER_${ch_idx}_MEM_AXI4_USE_ARLOCK           1
             set_component_parameter_value  DRIVER_${ch_idx}_MEM_AXI4_USE_ARCACHE          1
             set_component_parameter_value  DRIVER_${ch_idx}_MEM_AXI4_USE_ARPROT           1
             set_component_parameter_value  DRIVER_${ch_idx}_MEM_AXI4_USE_ARQOS            0
             set_component_parameter_value  DRIVER_${ch_idx}_MEM_AXI4_USE_ARREGION         0
             set_component_parameter_value  DRIVER_${ch_idx}_MEM_AXI4_USE_ARUSER           1
             set_component_parameter_value  DRIVER_${ch_idx}_MEM_AXI4_ARUSER_WIDTH         1

             #set_component_parameter_value  DRIVER_${ch_idx}_MEM_AXI4_WDATA_WIDTH         [get_ip_param AXI4_DATA_WIDTH]
             #set_component_parameter_value  DRIVER_${ch_idx}_MEM_AXI4_RDATA_WIDTH         [get_ip_param AXI4_DATA_WIDTH]

             set_component_parameter_value  DRIVER_${ch_idx}_MEM_AXI4_WDATA_WIDTH          $axi_user_width
             set_component_parameter_value  DRIVER_${ch_idx}_MEM_AXI4_RDATA_WIDTH          $axi_user_width

             set_component_parameter_value  DRIVER_${ch_idx}_MEM_AXI4_USE_BUSER            0

             set_component_parameter_value  DRIVER_${ch_idx}_ENABLE_CLOCK_SOURCE           "false";#[expr {$use_single_clock == 0}]
             #set_component_parameter_value  DRIVER_0_CLOCK_SOURCE_FREQ_MHZ    $subsys_params(EX_DESIGN_USER_PLL_0_OUT_CLK_FREQ_MHZ)
             set_component_parameter_value  DRIVER_${ch_idx}_ENABLE_RESET_SOURCE           "false";#[expr {$use_single_clock == 0}]
          }
          # disable run on reset for infinite traffic pattern
          if {[get_ip_param EX_DESIGN_HYDRA_PROG] == "emif_tg_emulation_inf"} {
            set_component_parameter_value RUN_ON_RESET 0
          }
       save_component; # $hydra
   } else {
       ## =============  AXI Traffic Generator ======================
       # XT_NOT: Not support multi-channel
       add_component_helper $tg emif_ph2_tg_axi
       load_component $tg
          set_component_parameter_value  MEGAFUNC_DEVICE_FAMILY           FALCONMESA
          set_component_parameter_value  PROTOCOL_ENUM                    "PROTOCOL_DDR4";# keep PROTOCOL_DDR4 as DDR4 for TG2. This issue will be sorted out in TG3
          set_component_parameter_value  MEM_TTL_DATA_WIDTH               $user_dq_width
          set_component_parameter_value  DIAG_EXPORT_TG_CFG_AVALON_SLAVE  "false"
          set_component_parameter_value  SHORT_QSYS_INTERFACE_NAMES       "true"
          set_component_parameter_value  CTRL_ECC_EN                      "false"
          set_component_parameter_value  CTRL_ECC_READDATAERROR_EN        "false"
          set_component_parameter_value  CTRL_MMR_EN                      "false"
          set_component_parameter_value  BYPASS_DEFAULT_PATTERN           "false"
          set_component_parameter_value  BYPASS_USER_STAGE                "true"
          set_component_parameter_value  TEST_DURATION                    "SHORT"
          set_component_parameter_value  AVL_TO_DQ_WIDTH_RATIO            [expr { [string match "*QR*" [get_ip_param PHY_C2M_RATE]] ? 8 : 4}]
          set_component_parameter_value  CORE_CLK_FREQ_HZ                 300000000
          set_component_parameter_value  NUM_USER_POOLS                   1
          set_component_parameter_value  NUM_WRITE_COPIES                 1
          set_component_parameter_value  AXI_DATA_WIDTH                   [get_ip_param AXI4_DATA_WIDTH]
          set_component_parameter_value  AMM_DATA_WIDTH                   [get_ip_param AXI4_DATA_WIDTH]
          set_component_parameter_value  AXI_ID_WIDTH                     7
          set_component_parameter_value  AXI_ADDR_WIDTH                   $arch_params(AXI4_ADDR_WIDTH)
          set_component_parameter_value  TEST_CSR                         0
          set_component_parameter_value  DISABLE_STATUS_CHECKER           0
          set_component_parameter_value  MEM_TTL_NUM_OF_WRITE_GROUPS      $arch_params(${TECH}_MEM_DEVICE_DQ_PER_DQS)
       save_component; # $tg
    }
    ## =============  Reset Release IP ======================
    add_component_helper $rrip altera_s10_user_rst_clkgate
    load_component $rrip
       set_component_parameter_value  outputType "Reset Interface"
    save_component; # $rrip

    ## =============  AXI4 Performance Monitor ======================

   set pmon_enabled_drivers {}
   set pmon_idx -1

   set all_pmon $ip_params(EX_DESIGN_PMON_ENABLED)

   if {$all_pmon == "true"} {
      for {set i 0} {$i < $num_channels} {incr i} {
         lappend pmon_enabled_drivers $i
      }
   } else {
      for {set i 0} {$i < $num_channels} {incr i} {
         if {$ip_params(EX_DESIGN_PMON_CH${i}_EN)} {
            lappend pmon_enabled_drivers $i
         }
      }
   }

   set num_pmon [llength $pmon_enabled_drivers]

   #set pmon usage and the driver pmon is enabled on
   if {$num_pmon} {
      set use_pmon 1
   } else {
      set use_pmon 0
   }

   set pmon_internal_jamb $ip_params(EX_DESIGN_PMON_INTERNAL_JAMB)
   if {$use_pmon} {
      # Instantiate (and later parametrize) PMON

      if {$pmon_internal_jamb == "false"} {
         # Instantiate JAMB (JTAG to Avalon Master Bridge) to use PMON CSRs
         set jamb_inst "pmon_jamb"
         lappend inst_names $jamb_inst
         add_instance $jamb_inst altera_jtag_avalon_master "19.1"
         # FAST_VER: Enhanced transaction master: Increase transaction master throughput
         set_instance_parameter_values $jamb_inst [list \
            FAST_VER    0     \
            FIFO_DEPTHS 2     \
            USE_PLI     1     \
            PLI_PORT    50000 \
         ]

         set csr_bus_if ${jamb_inst}.master
      }


      # PMON CSR and JAMB requires an input clk/reset, we use EMIF's clock domain here
      # Connect JAMB to PMON CSRs to control monitors
      # add_connection ${jamb_inst}.master ${perf_mon_inst}.sink_axi4lite

      # instantiate PMON
      set pmon_inst_list {}

      for {set i 0} {$i < $num_pmon} {incr i} {
         set driver_num [lindex $pmon_enabled_drivers $i]
         set ch_index $driver_num
         set perf_mon_inst "${pmon}ch${ch_index}"

         add_instance $perf_mon_inst pmon
         set_instance_parameter_value $perf_mon_inst MONITOR_0_ADVANCED_LAT "false"
         set_instance_parameter_value $perf_mon_inst EXPORT_JTAG $pmon_internal_jamb
         lappend pmon_inst_list $perf_mon_inst

         if {$pmon_internal_jamb == "false"} {
            # Connect JAMB to PMON CSRs to control monitors
            set pmon_address [expr {$i * 0x100000}]

            add_connection                 ${csr_bus_if}/${perf_mon_inst}.sink_axi4lite
            set_connection_parameter_value ${csr_bus_if}/${perf_mon_inst}.sink_axi4lite baseAddress $pmon_address
         }
      }
   }

    # configure each PMON instance
   set pmon_idx -1
   for {set ch_idx 0} {$ch_idx < $num_channels} {incr ch_idx} {
      set pmon_enabled [expr {[lsearch -exact $pmon_enabled_drivers $ch_idx] >= 0}]
      if {$use_pmon && $pmon_enabled} {

         incr pmon_idx
         set perf_mon_inst [lindex $pmon_inst_list $pmon_idx]

         # Parameterize pmon to match the driver
         set_instance_parameter_value  $perf_mon_inst MONITOR_0_UNIT_ID                     $pmon_idx
         set_instance_parameter_value  $perf_mon_inst MONITOR_INDEX                         0
         #set_instance_parameter_value  $perf_mon_inst MONITOR_0_MEM_AXI4_DATA_DQ_RATIO      8
         set_instance_parameter_value  $perf_mon_inst MONITOR_0_MEM_AXI4_AWID_WIDTH         7
         set_instance_parameter_value  $perf_mon_inst MONITOR_0_MEM_AXI4_AWADDR_WIDTH       $arch_params(AXI4_ADDR_WIDTH)
         set_instance_parameter_value  $perf_mon_inst MONITOR_0_MEM_AXI4_USE_AWLOCK         1
         set_instance_parameter_value  $perf_mon_inst MONITOR_0_MEM_AXI4_USE_AWCACHE        1
         #set_instance_parameter_value  $perf_mon_inst MONITOR_0_MEM_AXI4_USE_AWPROT         1
         set_instance_parameter_value  $perf_mon_inst MONITOR_0_MEM_AXI4_USE_AWQOS          0
         set_instance_parameter_value  $perf_mon_inst MONITOR_0_MEM_AXI4_USE_AWREGION       0
         set_instance_parameter_value  $perf_mon_inst MONITOR_0_MEM_AXI4_USE_AWUSER         1
         set_instance_parameter_value  $perf_mon_inst MONITOR_0_MEM_AXI4_AWUSER_WIDTH       1

         set_instance_parameter_value  $perf_mon_inst MONITOR_0_MEM_AXI4_ARID_WIDTH         7
         set_instance_parameter_value  $perf_mon_inst MONITOR_0_MEM_AXI4_ARADDR_WIDTH       $arch_params(AXI4_ADDR_WIDTH)
         set_instance_parameter_value  $perf_mon_inst MONITOR_0_MEM_AXI4_USE_ARLOCK         1
         set_instance_parameter_value  $perf_mon_inst MONITOR_0_MEM_AXI4_USE_ARCACHE        1
         #set_instance_parameter_value  $perf_mon_inst MONITOR_0_MEM_AXI4_USE_ARPROT         1
         set_instance_parameter_value  $perf_mon_inst MONITOR_0_MEM_AXI4_USE_ARQOS          0
         set_instance_parameter_value  $perf_mon_inst MONITOR_0_MEM_AXI4_USE_ARREGION       0
         set_instance_parameter_value  $perf_mon_inst MONITOR_0_MEM_AXI4_USE_ARUSER         1
         set_instance_parameter_value  $perf_mon_inst MONITOR_0_MEM_AXI4_ARUSER_WIDTH       1

         set_instance_parameter_value  $perf_mon_inst MONITOR_0_MEM_AXI4_WDATA_WIDTH        $axi_user_width
         set_instance_parameter_value  $perf_mon_inst MONITOR_0_MEM_AXI4_RDATA_WIDTH        $axi_user_width

         set_instance_parameter_value  $perf_mon_inst MONITOR_0_MEM_AXI4_USE_BUSER          1
         set_instance_parameter_value  $perf_mon_inst MONITOR_0_MEM_AXI4_BUSER_WIDTH        1
       }
    }

    # figure out num_user_pll_clocks
    set use_pll_for_mainband [expr {$user_access_mode == "fabric_async" ||
                                    $user_access_mode == "noc"        }]
#    set use_pll_for_sideband [expr {$sideband_in_use || $debug_tools_en}]
    # For now, hardcode to always use PLL for sideband (this include IOSSM's axil and hydra's) BUT leaving the option to change this logic easily in the future by changing this param
    set use_pll_for_sideband 1
    set num_user_pll_clocks [expr {$use_pll_for_mainband + $use_pll_for_sideband}]


    ## ============= PLL and Reset Handler ======================
    # instantiate reset handler
    add_component_helper $reset_handler mem_reset_handler
    load_component $reset_handler
       set_component_parameter_value  NUM_RESETS   1
    save_component; # $reset_handler
    add_connection  $rrip.ninit_done    $reset_handler.reset_n_0

    if {$num_user_pll_clocks > 0} {
        load_component $reset_handler
           set_component_parameter_value  SYNC_TO_CLK  true
           set_component_parameter_value  CONDUIT_TYPE_0 "export"
           set_component_parameter_value  NUM_CONDUITS 1
        save_component; # $reset_handler
    } elseif {$user_access_mode == "fabric_sync"} {
        load_component $reset_handler
           set_component_parameter_value  NUM_CONDUITS 0
        save_component; # $reset_handler
    }

    # instantiate user pll
    set side_clock_frequency [expr {$usr_clock_frequency/2}]
    if {$num_user_pll_clocks > 0} {
        add_component_helper $user_pll altera_iopll
        load_component $user_pll
           set_component_parameter_value  gui_use_coreclk                 true
           set_component_parameter_value  gui_use_locked                  true
           set_component_parameter_value  gui_location_type               "Fabric-Feeding"
           set_component_parameter_value  gui_pll_bandwidth_preset        "Medium"
           set_component_parameter_value  gui_reference_clock_frequency   $usr_reference_clock_frequency
           set_component_parameter_value  gui_number_of_clocks            $num_user_pll_clocks
           if {$num_user_pll_clocks == 2} {
              # sideand PLL output is outclk1 if both sideband and mainband are used
              set_component_parameter_value  gui_output_clock_frequency0  $usr_clock_frequency
              set_component_parameter_value  gui_output_clock_frequency1  $side_clock_frequency
           } elseif {$use_pll_for_mainband} {
              set_component_parameter_value  gui_output_clock_frequency0  $usr_clock_frequency
           } elseif {$use_pll_for_sideband} {
              set_component_parameter_value  gui_output_clock_frequency0  $side_clock_frequency
           }
        save_component; # $user_pll

        add_connection  $rrip.ninit_done    $user_pll.reset
        add_connection  $user_pll.locked    $reset_handler.conduit_0
        add_connection  $user_pll.outclk0   $reset_handler.clk
    }
    set sideband_clk ""
    if {!$use_pll_for_sideband} {
       # hardcode this case to usr_clk_0 for now; not expecting to hit this case currently
       # but if we ever make use_pll_for_sideband "optional" then this will need to be reviewed for multi-ch cases
       set sideband_clk "$emif.usr_clk_0"
    } elseif {$use_pll_for_sideband && !$use_pll_for_mainband} {
       set sideband_clk "$user_pll.outclk0"
    } elseif {$use_pll_for_sideband && $use_pll_for_mainband} {
       set sideband_clk "$user_pll.outclk1"
    }
    puts "sideband_clk: $sideband_clk (side=$use_pll_for_sideband ; main=$use_pll_for_mainband)"

   set pmon_idx -1
   if {$user_access_mode == "fabric_sync"} {
      if {$use_hydra} {
         if {[get_ip_param EX_DESIGN_HYDRA_REMOTE] == "CONFIG_INTF_MODE_REMOTE_JTAG"} {
            #assume that use_pll_for_sideband applies to both hydra's and iossm's axil
            add_connection $sideband_clk               $hydra.remote_intf_clk
            add_connection $emif.usr_rst_n_0           $hydra.remote_intf_reset
         }
      }

      if {$use_pmon} {
         if {$pmon_internal_jamb == "false"} {
            add_connection $sideband_clk      ${jamb_inst}.clk
            add_connection $emif.usr_rst_n_0  ${jamb_inst}.clk_reset
         }

         for {set ch_idx 0} {$ch_idx < $num_channels} {incr ch_idx} {
            set pmon_enabled [expr {[lsearch -exact $pmon_enabled_drivers $ch_idx] >= 0}]
            if {$pmon_enabled} {
               incr pmon_idx
               set perf_mon_inst [lindex $pmon_inst_list $pmon_idx]

               add_connection $sideband_clk               ${perf_mon_inst}.csr_clk
               add_connection $emif.usr_rst_n_0           ${perf_mon_inst}.csr_reset_n
            }
         }
      }
   }

   if {$user_access_mode == "fabric_async" ||
      $user_access_mode == "noc" } {

      if {$use_hydra} {

         if {[get_ip_param EX_DESIGN_HYDRA_REMOTE] == "CONFIG_INTF_MODE_REMOTE_JTAG"} {
            #might need a different clk? TBD -GE
            add_connection $sideband_clk                   $hydra.remote_intf_clk
            add_connection $reset_handler.reset_n_out      $hydra.remote_intf_reset
         }

      } else {
         #TODO: remove use_hydra = false option!!
         add_connection  $user_pll.outclk0               $tg.emif_usr_clk
      }

      if {$use_pmon} {
         if {$pmon_internal_jamb == "false"} {
            add_connection $sideband_clk      ${jamb_inst}.clk
            add_connection $reset_handler.reset_n_out  ${jamb_inst}.clk_reset
         }

         for {set ch_idx 0} {$ch_idx < $num_channels} {incr ch_idx} {
            set pmon_enabled [expr {[lsearch -exact $pmon_enabled_drivers $ch_idx] >= 0}]
            if {$pmon_enabled} {
               incr pmon_idx
               set perf_mon_inst [lindex $pmon_inst_list $pmon_idx]

               add_connection $sideband_clk               ${perf_mon_inst}.csr_clk
               add_connection $reset_handler.reset_n_out          ${perf_mon_inst}.csr_reset_n
            }
         }
      }
   }

    ## =============  Driver & PMON clocks and Resets ======================
    set ch_idx 0
    set pmon_idx -1

    for {set ip_idx 0} {$ip_idx < [expr {$is_lockstep ? 1 : $num_arch_cal_ips}]} {incr ip_idx} {
       set driver_clock ""
       if {$user_access_mode == "fabric_sync"} {
            set driver_clock "$emif.usr_clk_${ip_idx}"
       } else {
         set driver_clock "$user_pll.outclk0"
       }

       set driver_reset ""
       if {$sideband_in_use} {
            if { $ip_idx == 0} {
               set driver_reset $axil_driver_0.cal_done_rst_n
            } else {
               set driver_reset $axil_driver_1.cal_done_rst_n
            }
       } else {
            if {$user_access_mode == "fabric_sync"} {
               set driver_reset "$emif.usr_rst_n_${ip_idx}"
            } else {
               ## this is not a good option -- ideally user should not get here because we
               ## cannot guarantee that controller is ready when this reset is deasserted
               set driver_reset "$reset_handler.reset_n_out"
            }
       }

       for {set intf_idx 0} {$intf_idx < $num_channels_per_io96} {incr intf_idx} {
         add_connection    $driver_reset  $hydra.driver${ch_idx}_reset
         add_connection    $driver_clock  $hydra.driver${ch_idx}_clk

         set pmon_enabled [expr {[lsearch -exact $pmon_enabled_drivers $intf_idx] >= 0}]
         if {$use_pmon && $pmon_enabled} {
            incr pmon_idx
            set perf_mon_inst [lindex $pmon_inst_list $pmon_idx]

            add_connection $driver_reset  ${perf_mon_inst}.reset_n
            add_connection $driver_clock  ${perf_mon_inst}.clk
         }
         incr ch_idx
       }
    }

    ## =============  AXI-L driver clk/rst ======================
    set axil_driver_clk_0 ""
    set axil_driver_clk_1 ""
    if {$use_pll_for_sideband} {
       set axil_driver_clk_0 "$sideband_clk"
       set axil_driver_clk_1 "$axil_driver_clk_0"
    } else {
       set axil_driver_clk_0 "$emif.usr_clk_0"
       set axil_driver_clk_1 "$emif.usr_clk_1"
    }
    if {$sideband_in_use} {
       add_connection $axil_driver_clk_0           $axil_driver_0.axil_driver_clk
       add_connection $reset_handler.reset_n_out   $axil_driver_0.axil_driver_rst_n
       if {$num_arch_cal_ips != 1 && !$is_lockstep} {
          add_connection $axil_driver_clk_1            $axil_driver_1.axil_driver_clk
          add_connection $reset_handler.reset_n_out    $axil_driver_1.axil_driver_rst_n
       }
    }


    ## =============  Fabric SYNC Mode ======================
    if {$user_access_mode == "fabric_sync"} {
       if {$use_hydra} {
          set pmon_idx -1
          for {set ch_idx 0} {$ch_idx < $num_channels} {incr ch_idx} {
             set pmon_enabled [expr {[lsearch -exact $pmon_enabled_drivers $ch_idx] >= 0}]
             if {$use_pmon && $pmon_enabled} {
               incr pmon_idx
               set perf_mon_inst [lindex $pmon_inst_list $pmon_idx]

               add_connection $hydra.driver${ch_idx}_axi4 ${perf_mon_inst}.sink_axi4
               add_connection ${perf_mon_inst}.src_axi4 $emif.s${ch_idx}_axi4
             } else {
                add_connection $hydra.driver${ch_idx}_axi4     $emif.s${ch_idx}_axi4
             }
          }

       } else {
          #TODO: remove use_hydra = false option!!
          # Don't support multi-channel
          add_connection $emif.usr_clk_0           $tg.emif_usr_clk
          add_connection $emif.usr_rst_n_0         $tg.emif_usr_reset_n

          add_connection $tg.ctrl_axi              $emif.s0_axi4
       }

       add_connection $rrip.ninit_done          $emif.core_init_n_0

    }

    ## =============  Fabric ASYNC Mode ======================
    if {$user_access_mode == "fabric_async"} {
       if {$use_hydra} {
          set pmon_idx -1
          for {set ch_idx 0} {$ch_idx < $num_channels} {incr ch_idx} {
             set pmon_enabled [expr {[lsearch -exact $pmon_enabled_drivers $ch_idx] >= 0}]
             if {$use_pmon && $pmon_enabled} {
               incr pmon_idx
               set perf_mon_inst [lindex $pmon_inst_list $pmon_idx]

               add_connection $hydra.driver${ch_idx}_axi4 ${perf_mon_inst}.sink_axi4
               add_connection ${perf_mon_inst}.src_axi4 $emif.s${ch_idx}_axi4
             } else {
                add_connection $hydra.driver${ch_idx}_axi4     $emif.s${ch_idx}_axi4
             }
          }
       } else {
          #TODO: remove use_hydra = false option!!
          # Don't support multi-channel
          add_connection $tg.ctrl_axi                    $emif.s0_axi4
          add_connection $reset_handler.reset_n_out      $tg.emif_usr_reset_n
          add_connection $user_pll.outclk0               $emif.fbr_axil_clk_0
          add_connection $reset_handler.reset_n_out      $emif.fbr_axil_rst_n_0
       }
       add_connection $user_pll.outclk0                  $emif.usr_async_clk_0
       add_connection $reset_handler.reset_n_out         $emif.core_init_n_0
    }

    ## =============  NoC Mode ======================
    if {$user_access_mode == "noc" || ($sideband_in_use && $sideband_is_noc)} {
       # Both mainband and sideband noc access modes require the NOC Clock Control IP
       # NOC Clock Control IP = noc_ssm + noc_pll
       add_component_helper $noc_ctrl intel_noc_clock_ctrl
       load_component $noc_ctrl
          set_component_parameter_value REFCLK_FREQ "NOC_PLL_REFCLK_FREQ_[get_ip_param EX_DESIGN_NOC_REFCLK_FREQ_MHZ]_MHZ"
       save_component; # $noc_ctrl
       add_interface noc_ctrl_refclk clock source
       set_interface_property noc_ctrl_refclk EXPORT_OF ${noc_ctrl}.refclk
    }

    if {$user_access_mode == "noc"} {
        # NOC Initiator IP - Main Band
        add_component_helper $noc_init intel_noc_initiator
        load_component $noc_init
           set_component_parameter_value  INDIVIDUAL_AXI_CLKRESET  false
           set_component_parameter_value  NUM_AXI4_IF              $num_channels
           set_component_parameter_value  AXI4_DATA_MODE           "AXI4_DATA_MODE_[get_ip_param AXI4_DATA_WIDTH]"
           set_component_parameter_value  NUM_AXI4LITE_IF          0
           set_component_parameter_value  AXI4_HANDSHAKE           AXI4_HANDSHAKE_STANDARD
           set_component_parameter_value  NOC_QOS_MODE             NOC_QOS_MODE_SOCKET
           set_component_parameter_value  NOC_QOS_READ_PRIORITY    0
           set_component_parameter_value  NOC_QOS_WRITE_PRIORITY   0
           set_component_parameter_value  ENABLE_SECURITY          OFF
        save_component; # $noc_init

        add_connection $user_pll.outclk0            $noc_init.s_axi4_aclk
        add_connection $reset_handler.reset_n_out   $noc_init.s_axi4_aresetn

        if {$use_hydra} {
           # TODO: once we switch to hydra, figure out where we can set the actual mem capacity (while addr width will remain 44)
            set pmon_idx -1
            for {set ch_idx 0} {$ch_idx < $num_channels} {incr ch_idx} {
               set addr_width_for_noc_override 44
               load_component $hydra
                  set_component_parameter_value DRIVER_${ch_idx}_MEM_AXI4_AWADDR_WIDTH   $addr_width_for_noc_override
                  set_component_parameter_value DRIVER_${ch_idx}_MEM_AXI4_ARADDR_WIDTH   $addr_width_for_noc_override
               save_component; # $hydra

               set pmon_enabled [expr {[lsearch -exact $pmon_enabled_drivers $ch_idx] >= 0}]
               if {$use_pmon && $pmon_enabled} {
                  incr pmon_idx
                  set perf_mon_inst [lindex $pmon_inst_list $pmon_idx]

                  set_instance_parameter_value  $perf_mon_inst MONITOR_0_MEM_AXI4_AWADDR_WIDTH       $addr_width_for_noc_override
                  set_instance_parameter_value  $perf_mon_inst MONITOR_0_MEM_AXI4_ARADDR_WIDTH       $addr_width_for_noc_override

                  add_connection $hydra.driver${ch_idx}_axi4 ${perf_mon_inst}.sink_axi4
                  add_connection ${perf_mon_inst}.src_axi4 $noc_init.s${ch_idx}_axi4
               } else {
                  add_connection $hydra.driver${ch_idx}_axi4     $noc_init.s${ch_idx}_axi4
               }

               # Make INIU -> TNIU PD connection
               add_connection $noc_init.i${ch_idx}_axi4noc $emif.t${ch_idx}_axi4noc
               set_connection_parameter_value $noc_init.i${ch_idx}_axi4noc/$emif.t${ch_idx}_axi4noc baseAddress 0x0
               # Make INIU -> NOC Clock Control PD connection
               # [OB] for now, removing this connection: this is a connection to the noc performance monitor; not clear that we want to use it/and it makes the I-T connections not 1:1...
               # if we want to target the noc perf mon in the future, we'll need to consider how to do it correctly
#               add_connection $noc_init.i${ch_idx}_axi4noc $noc_ctrl.target_inst_0
#               set_connection_parameter_value $noc_init.i${ch_idx}_axi4noc/$noc_ctrl.target_inst_0 baseAddress $noc_tgt_width

               if {!$sideband_in_use} {
                  add_connection $reset_handler.reset_n_out         $hydra.driver${ch_idx}_reset
               }
            }
        } else {
          #TODO: remove use_hydra = false option!!
           # As with TG2, temporarily set this is 44 until we figure out what this should actually be
           # Don't support multi-channel
           load_component $tg
              set_component_parameter_value  AXI_ADDR_WIDTH  44
           save_component; # $tg

           add_connection $tg.ctrl_axi                 $noc_init.s0_axi4
           add_connection $reset_handler.reset_n_out   $tg.emif_usr_reset_n
        }

    }


    ## =============  Sideband ==========================
    if {$sideband_in_use || $debug_tools_en} {
       # If sideband is fabric:
       #    1) Connect the axi-lite driver(s) to the exposed axi-lite port(s) on emif
       #    2) Set the appropriate clk/reset for the exposed axi-lite port(s)
       # If sideband is noc:
       #    1) Instantiate iniu-lite(s)
       #    2) Connect axi-lite driver(s) to iniu-lite(s)
       #    3) Set the appropriate clk/reset for the iniu-lite(s)
       # Set clock/reset sources based on mainband access mode
       if {$use_pll_for_sideband} {
          # sideand PLL output is outclk1 if both sideband and mainband are used
          if {$use_pll_for_sideband && $use_pll_for_mainband} {
            set clock_source_0 $user_pll.outclk1
          } elseif {$use_pll_for_sideband} {
            set clock_source_0 $user_pll.outclk0
          } else {
            puts "Internal Error: expecting to always use standalone PLL for sideband because otherwise can't close timing on the sideband (on hydra/iossm). Please make sure this is intentional..."
            exit
          }
          set clock_source_1 $clock_source_0
          set reset_source_0 $reset_handler.reset_n_out
          set reset_source_1 $reset_source_0
       } else {
          set clock_source_0 $emif.usr_clk_0
          set clock_source_1 $emif.usr_clk_1
          set reset_source_0 $emif.usr_rst_n_0
          set reset_source_1 $emif.usr_rst_n_1
       }
       if {$sideband_is_noc} {
           # NOC Initiator IP - Sideband (An INIU-LITE)
           add_component_helper $noc_init_lite_0 intel_noc_initiator
           load_component $noc_init_lite_0
              set_component_parameter_value  INDIVIDUAL_AXI_CLKRESET  false
              set_component_parameter_value  NUM_AXI4_IF              0
              set_component_parameter_value  AXI4_DATA_MODE           AXI4_DATA_MODE_256
              set_component_parameter_value  NUM_AXI4LITE_IF          1
              set_component_parameter_value  AXI4_HANDSHAKE           AXI4_HANDSHAKE_STANDARD
              set_component_parameter_value  NOC_QOS_MODE             NOC_QOS_MODE_SOCKET
              set_component_parameter_value  NOC_QOS_READ_PRIORITY    0
              set_component_parameter_value  NOC_QOS_WRITE_PRIORITY   0
              set_component_parameter_value  ENABLE_SECURITY          OFF
           save_component; # $noc_init_lite_0

           # Make INIU-LITE -> TNIU-LITE PD connection
           add_connection $noc_init_lite_0.i0_axi4noc $emif.t0_axilnoc
           set_connection_parameter_value $noc_init_lite_0.i0_axi4noc/$emif.t0_axilnoc baseAddress 0x0
           # Make INIU-LITE -> NOC Clock Control PD connection
               # [OB] for now, removing this connection: this is a connection to the noc performance monitor; not clear that we want to use it/and it makes the I-T connections not 1:1...
               # if we want to target the noc perf mon in the future, we'll need to consider how to do it correctly
#           add_connection $noc_init_lite_0.i0_axi4noc $noc_ctrl.target_inst_0
#           set_connection_parameter_value $noc_init_lite_0.i0_axi4noc/$noc_ctrl.target_inst_0 baseAddress $noc_tgt_width
           if { $num_arch_cal_ips != 1 } {
              add_component_helper $noc_init_lite_1 intel_noc_initiator
              load_component $noc_init_lite_1
                 set_component_parameter_value  INDIVIDUAL_AXI_CLKRESET  false
                 set_component_parameter_value  NUM_AXI4_IF              0
                 set_component_parameter_value  AXI4_DATA_MODE           AXI4_DATA_MODE_256
                 set_component_parameter_value  NUM_AXI4LITE_IF          1
                 set_component_parameter_value  AXI4_HANDSHAKE           AXI4_HANDSHAKE_STANDARD
                 set_component_parameter_value  NOC_QOS_MODE             NOC_QOS_MODE_SOCKET
                 set_component_parameter_value  NOC_QOS_READ_PRIORITY    0
                 set_component_parameter_value  NOC_QOS_WRITE_PRIORITY   0
                 set_component_parameter_value  ENABLE_SECURITY          OFF
              save_component; # $noc_init_lite_1

              # Make INIU-LITE -> TNIU-LITE PD connection
              add_connection $noc_init_lite_1.i0_axi4noc $emif.t1_axilnoc
              set_connection_parameter_value $noc_init_lite_1.i0_axi4noc/$emif.t1_axilnoc baseAddress 0x0
              # Make INIU-LITE -> NOC Clock Control PD connection
               # [OB] for now, removing this connection: this is a connection to the noc performance monitor; not clear that we want to use it/and it makes the I-T connections not 1:1...
               # if we want to target the noc perf mon in the future, we'll need to consider how to do it correctly
#              add_connection $noc_init_lite_1.i0_axi4noc $noc_ctrl.target_inst_0
#              set_connection_parameter_value $noc_init_lite_1.i0_axi4noc/$noc_ctrl.target_inst_0 baseAddress $noc_tgt_width
           }

           # Make clk/reset/axi connections for TNIU-LITE(s)
           add_connection $axil_driver_0.axil_driver_axi4_lite $noc_init_lite_0.s0_axi4lite
           add_connection $clock_source_0  $noc_init_lite_0.s_axi4lite_aclk
           add_connection $reset_source_0  $noc_init_lite_0.s_axi4lite_aresetn
           if { $num_arch_cal_ips != 1 && !$is_lockstep } {
              add_connection $axil_driver_1.axil_driver_axi4_lite $noc_init_lite_1.s0_axi4lite
              add_connection $clock_source_1  $noc_init_lite_1.s_axi4lite_aclk
              add_connection $reset_source_1  $noc_init_lite_1.s_axi4lite_aresetn
           }
       } elseif {$sideband_in_use} {
          # Fabric sideband -- connect axil driver to emif
          add_connection $axil_driver_0.axil_driver_axi4_lite  $emif.s0_axil
          if { $num_arch_cal_ips != 1 && !$is_lockstep } {
             add_connection $axil_driver_1.axil_driver_axi4_lite  $emif.s1_axil
          }
       }
       if {($sideband_in_use&&!$sideband_is_noc) || $debug_tools_en} {
          # Make the clk/reset connections to IOSSM's fabric axil
          # this interface exists any time we use sideband in fabric mode (for dtk of for user)
          add_connection $clock_source_0 $emif.s0_axil_clk
          add_connection $reset_source_0 $emif.s0_axil_rst_n
          if { $num_arch_cal_ips != 1 && !$is_lockstep } {
             add_connection $clock_source_1 $emif.s1_axil_clk
             add_connection $reset_source_1 $emif.s1_axil_rst_n
          }
       }
    }

    ## =============  Lockstep ===========================
    set use_pll_for_ls $use_pll_for_sideband
    #set use_pll_for_ls 0
    if {$is_lockstep & !$use_pll_for_ls} {
       ## for now, this code will not be used since PLL is always used for side band signal
       set ls_clk_bridge ls_clk_bridge
       add_instance $ls_clk_bridge altera_clock_bridge
       set_instance_parameter_value $ls_clk_bridge EXPLICIT_CLOCK_RATE    0
       set_instance_parameter_value $ls_clk_bridge NUM_CLOCK_OUTPUTS      1
       ## assume ref_clk can go to core & PLL, if not...
       add_connection  $ls_clk_bridge.out_clk      $emif.ref_clk_0
       add_connection  $ls_clk_bridge.out_clk      $axil_driver_0.axil_driver_clk
       add_connection  $ls_clk_bridge.out_clk      $emif.s0_axil_clk
       ## generate a reset from core_init synced to AXIL clock
       set reset_handler_ls "reset_handler_ls"
       add_instance $reset_handler_ls altera_reset_bridge
       set_instance_parameter_value $reset_handler_ls  SYNCHRONOUS_EDGES         "deassert"
       set_instance_parameter_value $reset_handler_ls  ACTIVE_LOW_RESET          1
       add_connection  $rrip.ninit_done               $reset_handler_ls.in_reset
       add_connection  $ls_clk_bridge.out_clk         $reset_handler_ls.clk
       add_connection  $reset_handler_ls.out_reset    $emif.s0_axil_rst_n
       ## generate a reset from user_rst_0 synced to AXIL clock
       set reset_handler_ls_user "reset_handler_ls_user"
       add_instance $reset_handler_ls_user altera_reset_bridge
       set_instance_parameter_value $reset_handler_ls_user  SYNCHRONOUS_EDGES         "deassert"
       set_instance_parameter_value $reset_handler_ls_user  ACTIVE_LOW_RESET          1
       add_connection  $emif.usr_rst_n_0                    $reset_handler_ls_user.in_reset
       add_connection  $ls_clk_bridge.out_clk               $reset_handler_ls_user.clk
       add_connection  $reset_handler_ls_user.out_reset     $axil_driver_0.axil_driver_rst_n
    }


    ## =============  Exports ===========================

    if {$use_hydra == "false"}  {
       add_interface ${tg}_tg_status conduit end
       set_interface_property ${tg}_tg_status EXPORT_OF $tg.tg_status
    } else {
       #TODO: remove use_hydra = false option!!
      if {[string is true $use_hydra_status_if]} {
         add_interface ${hydra}_tg_status conduit end
         set_interface_property ${hydra}_tg_status EXPORT_OF $hydra.status
      }
      if {[get_ip_param EX_DESIGN_HYDRA_REMOTE] == "CONFIG_INTF_MODE_EXPORT"} {
         add_interface          global_csr_clk clock     end
         set_interface_property global_csr_clk EXPORT_OF $hydra.global_csr_clk

         add_interface          global_csr_reset reset     sink
         set_interface_property global_csr_reset EXPORT_OF $hydra.global_csr_reset

         add_interface          global_csr_axi4l conduit   end
         set_interface_property global_csr_axi4l EXPORT_OF $hydra.global_csr_axi4l

         for {set ch_idx 0} {$ch_idx < $num_channels} {incr ch_idx} {
            set intf_name driver${ch_idx}_csr_clk
            add_interface          $intf_name clock     end
            set_interface_property $intf_name EXPORT_OF $hydra.$intf_name

            set intf_name driver${ch_idx}_csr_reset
            add_interface          $intf_name reset     sink
            set_interface_property $intf_name EXPORT_OF $hydra.$intf_name

            set intf_name driver${ch_idx}_csr_axi4l
            add_interface          $intf_name conduit   end
            set_interface_property $intf_name EXPORT_OF $hydra.$intf_name
         }
      }
    }

    ###############################################################################
    ##
    ## Synthesis Example Design
    ##
    ###############################################################################
    if {$design_type == "synth"} {
       for {set ch_idx 0} {$ch_idx < $num_channels} {incr ch_idx} {
          add_interface          ${emif}_mem_${ch_idx}      conduit end
          set_interface_property ${emif}_mem_${ch_idx}      EXPORT_OF $emif.mem_${ch_idx}

          add_interface          ${emif}_oct_${ch_idx}      conduit end
          set_interface_property ${emif}_oct_${ch_idx}      EXPORT_OF $emif.oct_${ch_idx}
       }

        if {($TECH == "DDR5") && ($FORMAT == "RDIMM")} {
           add_interface          ${emif}_i3c conduit end
           set_interface_property ${emif}_i3c EXPORT_OF $emif.i3c_0

           add_interface          ${emif}_lbd conduit end
           set_interface_property ${emif}_lbd EXPORT_OF $emif.mem_lbd_0
           add_interface          ${emif}_lbs conduit end
           set_interface_property ${emif}_lbs EXPORT_OF $emif.mem_lbs_1
        }

        for {set ch_idx 0} {$ch_idx < $num_refclks} {incr ch_idx} {
           add_interface          ref_clk_${ch_idx} clock end
           if {!$use_pll_for_ls && $is_lockstep && $ch_idx == 0} {
              set_interface_property ref_clk_0 EXPORT_OF $ls_clk_bridge.in_clk
           } else {
              set_interface_property ref_clk_${ch_idx} EXPORT_OF $emif.ref_clk_${ch_idx}
           }
        }

        if {$use_pll_for_sideband || $use_pll_for_mainband} {
            add_interface               ref_clk_usr_pll clock   end
            set_interface_property      ref_clk_usr_pll EXPORT_OF $user_pll.refclk
        }

        if { $is_lockstep } {
            add_interface          ${emif}_mem_1      conduit end
            set_interface_property ${emif}_mem_1      EXPORT_OF $emif.mem_1
        }
        return
    }

    for {set ch_idx 0} {$ch_idx < $num_channels} {incr ch_idx} {
       remove_interface  ${emif}_mem_${ch_idx}
       remove_interface  ${emif}_oct_${ch_idx}
    }
    if { $is_lockstep } {
        remove_interface   ${emif}_mem_1
    }
    for {set ch_idx 0} {$ch_idx < $num_refclks} {incr ch_idx} {
       remove_interface  ref_clk_${ch_idx}
    }
    remove_interface  ${emif}_i3c
    remove_interface  ${emif}_lbd
    remove_interface  ${emif}_lbs
    remove_interface  ref_clk_usr_pll
    remove_interface  rst_n

    ###############################################################################
    ##
    ## Simulation Example Design
    ##
    ###############################################################################
    ## =============  MEMORY MUX ======================
    if { $is_lockstep } {
      array set port_width {}
      foreach p [get_instance_interface_ports $emif mem_0] {
          set port_width($p) [get_instance_interface_port_property $emif mem_0 $p WIDTH]
      }
      foreach p [get_instance_interface_ports $emif mem_1] {
           regsub {_[0-9]} $p _0 pname
           set port_width($pname) [expr { $port_width($pname) + \
                                        [get_instance_interface_port_property $emif mem_1 $p WIDTH] } ]
      }
      set mux_params_lst [list]
      foreach p [array names port_width] {
          lappend mux_params_lst "MUX_[port_to_param $p]" $port_width($p)
      }
      set is_3ac         [expr { [get_ip_param USER_MIN_NUM_AC_LANES] == 3 } ]
      set pri_w          [expr { ( $total_dq_width == 72 && $is_3ac ) ? 40 : 32 }]
      set sec_w          [expr { $total_dq_width - $pri_w}]
      set mem_mux mem_mux
      add_component_helper $mem_mux emif_ph2_lockstep_adaptor
      load_component $mem_mux
      lappend mux_params_lst  BLOCK_FUNCTION       MEM_BUS_MUX \
                              MEM_PRIMARY_W        $pri_w \
                              MEM_SECONDARY_W      $sec_w
      set_component_parameter_values $mux_params_lst
      save_component; # $mem_mux
      add_connection $emif.mem_0 $mem_mux.p_mem
      add_connection $emif.mem_1 $mem_mux.s_mem
    }
    ## =============  MEMORY MODEL ======================
    set mem mem
    add_component_helper $mem emif_ph2_mem_model_$tech
    load_component $mem
       set mem_params_lst [list]
       foreach p [get_component_parameters] {
          if {[info exists   ip_params($p)]} { lappend mem_params_lst $p; lappend mem_params_lst   [get_ip_param $p]; continue}
          if {[info exists arch_params($p)]} { lappend mem_params_lst $p; lappend mem_params_lst $arch_params($p)}
       }
       set_component_parameter_values $mem_params_lst
    save_component; # $mem
    if { $is_lockstep } {
          add_connection $mem.mem_0       $mem_mux.mem_0
    } else {
       for {set ch_idx 0} {$ch_idx < $num_channels} {incr ch_idx} {
          add_connection $mem.mem_${ch_idx}       $emif.mem_${ch_idx}
       }
    }
    for {set ch_idx 0} {$ch_idx < $num_channels} {incr ch_idx} {
       add_connection $mem.oct_${ch_idx}       $emif.oct_${ch_idx}
    }
    if {($TECH == "DDR5") && ($FORMAT == "RDIMM")} {
       add_connection $mem.mem_lbd_0           $emif.mem_lbd_0
       add_connection $mem.mem_lbs_0           $emif.mem_lbs_1
       add_connection $mem.i3c_0               $emif.i3c_0
    }


    ## =============  EMIF Reference Clock ======================
    set ref_clock_src ref_clk_source

    for {set ch_idx 0} {$ch_idx < $num_refclks} {incr ch_idx} {
       add_component_helper ${ref_clock_src}_${ch_idx} altera_avalon_clock_source
       load_component ${ref_clock_src}_${ch_idx}
          set_component_parameter_value  CLOCK_RATE [expr {round($arch_params(PHY_REFCLK_FREQ_MHZ) * 1000000.0)}]
          set_component_parameter_value  CLOCK_UNIT 1
       save_component; # ${ref_clock_src}_${ch_idx}
       if { !$use_pll_for_ls && $is_lockstep && $ch_idx == 0 } {
          add_connection ${ref_clock_src}_0.clk      $ls_clk_bridge.in_clk
       } else {
          add_connection ${ref_clock_src}_${ch_idx}.clk      $emif.ref_clk_${ch_idx}
       }
    }

    ## =============  Async Reference Clock (for NOC and ASYNC mode) ===================
    if {$use_pll_for_sideband || $use_pll_for_mainband} {
        set async_clock_src async_clk_source
        add_component_helper $async_clock_src altera_avalon_clock_source
        load_component $async_clock_src
           set_component_parameter_value  CLOCK_RATE $async_refclk_sim_freq
           set_component_parameter_value  CLOCK_UNIT 1
        save_component; # $async_clock_src
        add_connection $async_clock_src.clk        $user_pll.refclk
    }

}

proc validate { {instance ""} } {
    set_validation_property AUTOMATIC_VALIDATION true
    if {$instance == ""} {
    set qsys_messages [validate_system]
    } else {
       set qsys_messages [validate_instance $instance]
    }
    set_validation_property AUTOMATIC_VALIDATION false
    set error_found 0
    set errors ""
    foreach msg $qsys_messages {
        puts $msg
        if {[regexp "^Error:" $msg]} {
          set error_found 1
          set errors "$errors$msg\n"
       }
    }
    if {$error_found} {
       if {$instance == ""} {
          error "Error(s) found in system validation:\n$errors"
       } else {
          error "Error(s) found in IP parameterization:\n$errors"
       }
    }
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

proc add_component_helper {ip_inst ip_type} {
   # Add_component requires a filename or filepath. We just provide
   # the filename and let Platform Designer place the .ip collateral
   # in the correct path relative to the .qsys file.
   upvar module_prefix module_prefix
   add_component $ip_inst ${module_prefix}${ip_inst}.ip $ip_type
}

proc get_ip_param {param_name} {
   # Retrieve values from the ip_param array while taking into consideration that
   # usr_auto params actual value can be in one of two parameters
   upvar ip_params ip_params
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

proc port_to_param { port_name } {
   regsub {_[0-9]} $port_name _width pname
   regsub {mem_ba} $pname mem_bank_addr pname
   regsub {mem_bg} $pname mem_bank_group_addr pname
   regsub {mem_c_} $pname "mem_chip_id_" pname
   set pname [string toupper $pname]
   return $pname
}
###############################################################################
# Main program
###############################################################################
#---------------run time profiling parameters------------
set print_profile_flag [expr {[get_quartus_ini "emif_print_timing" STRING] == "on"}]
#--------------------------------------------------------
set time_start [clock clicks -milliseconds]
# Extract arch params
add_instance emif_temp emif_ph2
set_instance_parameter_values emif_temp $ip_param_lst
validate emif_temp
foreach arch { arch_0 arch_emif_ls_0 } {
   foreach p [get_composed_instance_parameters emif_temp $arch] {
      set value [get_composed_instance_parameter_value emif_temp $arch $p]
      set arch_params($p) $value
   }
}
remove_instance emif_temp
set time_end [clock clicks -milliseconds]
if {$print_profile_flag} {
   puts "EMIF Make Qsys: extracting EMIF parameterization took [expr {$time_end - $time_start}]ms."
}
#--------------------------------------------------------

set time_start [clock clicks -milliseconds]
set qsys_filepath $ed_params(TMP_SYNTH_QSYS_PATH)
#--------------------------------------------------------
# System must be created->saved->loaded before generating
# in order for add_component to work properly
# HSD:14018178461
create_system
save_system $qsys_filepath
load_system $qsys_filepath
#--------------------------------------------------------
gen_sys "synth"
sync_sysinfo_parameters
validate
sync_sysinfo_parameters
save_system $qsys_filepath
set time_end [clock clicks -milliseconds]
if {$print_profile_flag} {
   puts "EMIF Make Qsys: configuring the synthesis ex-design took [expr {$time_end - $time_start}]ms."
}

set time_start [clock clicks -milliseconds]
set qsys_filepath $ed_params(TMP_SIM_QSYS_PATH)
#--------------------------------------------------------
# System must be created->saved->loaded before generating
# in order for add_component to work properly
# HSD:14018178461
create_system
save_system $qsys_filepath
load_system $qsys_filepath
#--------------------------------------------------------
gen_sys "sim"
sync_sysinfo_parameters
validate
sync_sysinfo_parameters
save_system $qsys_filepath
set time_end [clock clicks -milliseconds]
if {$print_profile_flag} {
   puts "EMIF Make Qsys: configuring the simulation ex-design took [expr {$time_end - $time_start}]ms."
}

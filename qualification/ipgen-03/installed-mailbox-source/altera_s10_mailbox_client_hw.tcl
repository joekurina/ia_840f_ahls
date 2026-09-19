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


# $Id: //acds/rel/26.1.1/ip/pgm/altera_s10_mailbox_client/altera_s10_mailbox_client_hw.tcl#1 $
# $Revision: #1 $
# $Date: 2026/05/07 $
# $Author: psgswbuild $


# 
# altera_s10_mailbox_client "Altera Config Debug Agent Bridge" v100.99.98.97
#  2016.04.03.15:59:28
# 
# 

# 
# request TCL package from ACDS 16.0
# 
package require -exact qsys 16.0

# 
# module altera_s10_mailbox_client
# 
set_module_property DESCRIPTION ""
set_module_property NAME altera_s10_mailbox_client
set_module_property VERSION 23.0.0
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property GROUP "Basic Functions/Configuration and Programming"
set_module_property AUTHOR "Altera"
set_module_property DISPLAY_NAME "Mailbox Client IP"
set_module_property DESCRIPTION "The Mailbox Client IP allows FPGA core to send command to SDM and receive response from SDM"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property REPORT_TO_TALKBACK false
set_module_property ALLOW_GREYBOX_GENERATION false
set_module_property REPORT_HIERARCHY false
set_module_property composition_callback compose
set_module_property OUTDATED_IP_FILE altera_s10_mailbox_client.odip
set all_supported_device_families_list {"Stratix 10" "Agilex 7" "Agilex" "Agilex 9" "eASIC N5X"}
set_module_property SUPPORTED_DEVICE_FAMILIES       $all_supported_device_families_list
add_documentation_link "User Guide" https://www.intel.com/content/www/us/en/docs/programmable/683290/current/mailbox-client-fpga-ip-user-guide.html
add_documentation_link "Release Notes" https://www.intel.com/content/www/us/en/docs/programmable/683290/current/document-revision-history-for-the-user-guide.html

# 
# parameters
# 
add_parameter DEVICE_FAMILY STRING
set_parameter_property DEVICE_FAMILY VISIBLE false
set_parameter_property DEVICE_FAMILY SYSTEM_INFO {DEVICE_FAMILY}
set_parameter_property DEVICE_FAMILY HDL_PARAMETER false

add_parameter CMD_FIFO_DEPTH INTEGER 16
set_parameter_property CMD_FIFO_DEPTH ALLOWED_RANGES 1:1024
set_parameter_property CMD_FIFO_DEPTH DISPLAY_NAME "Command FIFO Depth"
set_parameter_property CMD_FIFO_DEPTH AFFECTS_ELABORATION true
set_parameter_property CMD_FIFO_DEPTH AFFECTS_GENERATION true
set_parameter_property CMD_FIFO_DEPTH HDL_PARAMETER true
set_parameter_property CMD_FIFO_DEPTH  DESCRIPTION "Set depth of command fifo"
add_display_item "Mailbox Client Parameters" CMD_FIFO_DEPTH parameter

add_parameter CMD_USE_MEMORY_BLOCKS INTEGER 1
set_parameter_property CMD_USE_MEMORY_BLOCKS DISPLAY_NAME "Command FIFO: Use memory block"
set_parameter_property CMD_USE_MEMORY_BLOCKS AFFECTS_ELABORATION true
set_parameter_property CMD_USE_MEMORY_BLOCKS AFFECTS_GENERATION true
set_parameter_property CMD_USE_MEMORY_BLOCKS HDL_PARAMETER true
set_parameter_property CMD_USE_MEMORY_BLOCKS VISIBLE false
set_parameter_property CMD_USE_MEMORY_BLOCKS DISPLAY_HINT "boolean"
add_display_item "Mailbox Client Parameters" CMD_USE_MEMORY_BLOCKS parameter

add_parameter RSP_FIFO_DEPTH INTEGER 16
set_parameter_property RSP_FIFO_DEPTH ALLOWED_RANGES 1:1024
set_parameter_property RSP_FIFO_DEPTH DISPLAY_NAME "Response FIFO Depth"
set_parameter_property RSP_FIFO_DEPTH AFFECTS_ELABORATION true
set_parameter_property RSP_FIFO_DEPTH AFFECTS_GENERATION true
set_parameter_property RSP_FIFO_DEPTH HDL_PARAMETER true
set_parameter_property RSP_FIFO_DEPTH  DESCRIPTION "Set depth of response fifo"
add_display_item "Mailbox Client Parameters" RSP_FIFO_DEPTH parameter

add_parameter RSP_USE_MEMORY_BLOCKS INTEGER 1
set_parameter_property RSP_USE_MEMORY_BLOCKS DISPLAY_NAME "Response FIFO: Use memory block"
set_parameter_property RSP_USE_MEMORY_BLOCKS AFFECTS_ELABORATION true
set_parameter_property RSP_USE_MEMORY_BLOCKS AFFECTS_GENERATION true
set_parameter_property RSP_USE_MEMORY_BLOCKS HDL_PARAMETER true
set_parameter_property RSP_USE_MEMORY_BLOCKS VISIBLE false
set_parameter_property RSP_USE_MEMORY_BLOCKS DISPLAY_HINT "boolean"
add_display_item "Mailbox Client Parameters" RSP_USE_MEMORY_BLOCKS parameter

add_parameter URG_FIFO_DEPTH INTEGER 4
set_parameter_property URG_FIFO_DEPTH ALLOWED_RANGES 1:1024
set_parameter_property URG_FIFO_DEPTH DISPLAY_NAME "Urgent FIFO Depth"
set_parameter_property URG_FIFO_DEPTH AFFECTS_ELABORATION true
set_parameter_property URG_FIFO_DEPTH AFFECTS_GENERATION true
set_parameter_property URG_FIFO_DEPTH HDL_PARAMETER true
set_parameter_property URG_FIFO_DEPTH VISIBLE false
set_parameter_property URG_FIFO_DEPTH  DESCRIPTION "Set depth of urgent command fifo"
add_display_item "Mailbox Client Parameters" URG_FIFO_DEPTH parameter

add_parameter URG_USE_MEMORY_BLOCKS INTEGER 1
set_parameter_property URG_USE_MEMORY_BLOCKS DISPLAY_NAME "Urgent FIFO: Use memory block"
set_parameter_property URG_USE_MEMORY_BLOCKS AFFECTS_ELABORATION true
set_parameter_property URG_USE_MEMORY_BLOCKS AFFECTS_GENERATION true
set_parameter_property URG_USE_MEMORY_BLOCKS HDL_PARAMETER true
set_parameter_property URG_USE_MEMORY_BLOCKS VISIBLE false
set_parameter_property URG_USE_MEMORY_BLOCKS DISPLAY_HINT "boolean"
add_display_item "Mailbox Client Parameters" URG_USE_MEMORY_BLOCKS parameter

add_parameter DEBUG INTEGER 0
set_parameter_property DEBUG DISPLAY_NAME "Debug Simulation"
set_parameter_property DEBUG AFFECTS_ELABORATION true
set_parameter_property DEBUG AFFECTS_GENERATION true
set_parameter_property DEBUG HDL_PARAMETER true
set_parameter_property DEBUG VISIBLE false
set_parameter_property DEBUG DISPLAY_HINT "boolean"
add_display_item "Mailbox Client Parameters" DEBUG parameter

add_parameter HAS_URGENT INTEGER 0
set_parameter_property HAS_URGENT ALLOWED_RANGES {0 1}
set_parameter_property HAS_URGENT AFFECTS_ELABORATION true
set_parameter_property HAS_URGENT AFFECTS_GENERATION true
set_parameter_property HAS_URGENT HDL_PARAMETER true
set_parameter_property HAS_URGENT VISIBLE false

add_parameter HAS_STATUS INTEGER 1
set_parameter_property HAS_STATUS ALLOWED_RANGES {0 1}
set_parameter_property HAS_STATUS AFFECTS_ELABORATION true
set_parameter_property HAS_STATUS AFFECTS_GENERATION true
set_parameter_property HAS_STATUS HDL_PARAMETER true
set_parameter_property HAS_STATUS VISIBLE false

add_parameter HAS_STREAM INTEGER 0
set_parameter_property HAS_STREAM DISPLAY_NAME "Enable Stream Interface"
set_parameter_property HAS_STREAM ALLOWED_RANGES {0:Off 1:StreamActiveOnly 2:FullFunctions}
set_parameter_property HAS_STREAM AFFECTS_ELABORATION true
set_parameter_property HAS_STREAM AFFECTS_GENERATION true
set_parameter_property HAS_STREAM HDL_PARAMETER true
set_parameter_property HAS_STREAM VISIBLE false
set_parameter_property HAS_STREAM DESCRIPTION "Enable/Disable Streaming interface. StreamActiceOnly: Use this setting if you only need stream_active signal to indicate when stream operation is in progress - this is accessed via the IP CSR. FullFunctions: Use this setting if you need stream_active signal and the stream interface to send the bitstream into SDM "

add_parameter STREAM_WIDTH INTEGER 32
set_parameter_property STREAM_WIDTH DISPLAY_NAME "Stream Data Width"
set_parameter_property STREAM_WIDTH ALLOWED_RANGES {32 64}
set_parameter_property STREAM_WIDTH AFFECTS_ELABORATION true
set_parameter_property STREAM_WIDTH AFFECTS_GENERATION true
set_parameter_property STREAM_WIDTH HDL_PARAMETER true
set_parameter_property STREAM_WIDTH DERIVED false
set_parameter_property STREAM_WIDTH VISIBLE false
set_parameter_property STREAM_WIDTH DESCRIPTION "Set Data Width of the Stream interface"

add_parameter HAS_OFFLOAD INTEGER 0
set_parameter_property HAS_OFFLOAD DEFAULT_VALUE 0
set_parameter_property HAS_OFFLOAD DISPLAY_NAME "Enable Crypto Service"
set_parameter_property HAS_OFFLOAD TYPE INTEGER
set_parameter_property HAS_OFFLOAD UNITS None
set_parameter_property HAS_OFFLOAD ALLOWED_RANGES {0 1}
set_parameter_property HAS_OFFLOAD DESCRIPTION "Enable crypto service feature. Set to 1 to enable crypto AXI manager interface"
set_parameter_property HAS_OFFLOAD HDL_PARAMETER true
set_parameter_property HAS_OFFLOAD VISIBLE true

add_parameter CRYPTO_MEMORY_TIMEOUT_VALUE INTEGER 10000 ""
set_parameter_property CRYPTO_MEMORY_TIMEOUT_VALUE DEFAULT_VALUE 10000
set_parameter_property CRYPTO_MEMORY_TIMEOUT_VALUE DISPLAY_NAME "Crypto Memory Timeout Value"
set_parameter_property CRYPTO_MEMORY_TIMEOUT_VALUE DESCRIPTION "The crypto service timeout value. Maximum is 0x7FFFFFFF (2,147,483,647 clock cycles) and minimum is 0x2710 (10, 000 clock cycles)"
set_parameter_property CRYPTO_MEMORY_TIMEOUT_VALUE WIDTH ""
set_parameter_property CRYPTO_MEMORY_TIMEOUT_VALUE UNITS None
set_parameter_property CRYPTO_MEMORY_TIMEOUT_VALUE ALLOWED_RANGES {10000:2147483647}
set_parameter_property CRYPTO_MEMORY_TIMEOUT_VALUE AFFECTS_ELABORATION true
set_parameter_property CRYPTO_MEMORY_TIMEOUT_VALUE AFFECTS_GENERATION true
set_parameter_property CRYPTO_MEMORY_TIMEOUT_VALUE HDL_PARAMETER true
set_parameter_property CRYPTO_MEMORY_TIMEOUT_VALUE DISPLAY_HINT hexadecimal

add_display_item "Config Stream Parameters" HAS_STREAM parameter
add_display_item "Config Stream Parameters" STREAM_WIDTH parameter
add_display_item "Config Stream Parameters" HAS_URGENT parameter
add_display_item "Config Stream Parameters" HAS_STATUS parameter
add_display_item "Memory AXI Manager Parameters" HAS_OFFLOAD parameter
add_display_item "Memory AXI Manager Parameters" CRYPTO_MEMORY_TIMEOUT_VALUE parameter

# 
# display items
# 
add_display_item "" "Mailbox Client Parameters" GROUP ""
add_display_item "" "Config Stream Parameters" GROUP ""
add_display_item "" "Internal Parameters" GROUP ""
add_display_item "" "Memory AXI Manager Parameters" GROUP ""

proc compose { } {
   
    set HAS_STREAM                  [get_parameter_value HAS_STREAM]
    set HAS_URGENT                  [get_parameter_value HAS_URGENT]
    set HAS_STATUS                  [get_parameter_value HAS_STATUS]
    set STREAM_WIDTH                [get_parameter_value STREAM_WIDTH]
    set DEBUG                       [get_parameter_value DEBUG]
    set CMD_FIFO_DEPTH              [get_parameter_value CMD_FIFO_DEPTH] 
    set URG_FIFO_DEPTH              [get_parameter_value URG_FIFO_DEPTH] 
    set RSP_FIFO_DEPTH              [get_parameter_value RSP_FIFO_DEPTH]
    set CMD_USE_MEMORY_BLOCKS       [get_parameter_value CMD_USE_MEMORY_BLOCKS] 
    set URG_USE_MEMORY_BLOCKS       [get_parameter_value URG_USE_MEMORY_BLOCKS] 
    set RSP_USE_MEMORY_BLOCKS       [get_parameter_value RSP_USE_MEMORY_BLOCKS] 
    set CRYPTO_MEMORY_TIMEOUT_VALUE [get_parameter_value CRYPTO_MEMORY_TIMEOUT_VALUE] 
    set DEVICE_FAMILY               [get_parameter_value DEVICE_FAMILY]
        
    #disable "HAS_OFFLOAD" Feature if device is Stratix 10. Disabled the HAS_OFFLOAD and CRYPTO_MEMORY_TIMEOUT_VALUE parameter
    if {$DEVICE_FAMILY == "Stratix 10"} {
        send_message info "$DEVICE_FAMILY does not support 'Enable Crypto Service' feature, therefore it is disabled. This feature is only supported from Agilex device and above."
        set_parameter_property HAS_OFFLOAD ENABLED 0
        set HAS_OFFLOAD 0
    } else {
        set_parameter_property HAS_OFFLOAD ENABLED 1
        set HAS_OFFLOAD                 [get_parameter_value HAS_OFFLOAD]
    }
    
    #clk input to default mailbox AVMM path (command/response/urgent/stream/CSR access)
    add_instance clock_bridge altera_clock_bridge
    set_instance_parameter_value clock_bridge {EXPLICIT_CLOCK_RATE} {0.0}
    set_instance_parameter_value clock_bridge {NUM_CLOCK_OUTPUTS} {1}

    add_instance reset_bridge altera_reset_bridge
    set_instance_parameter_value reset_bridge {ACTIVE_LOW_RESET} {0}
    set_instance_parameter_value reset_bridge {SYNCHRONOUS_EDGES} {both}
    set_instance_parameter_value reset_bridge {NUM_RESET_OUTPUTS} {1}
    set_instance_parameter_value reset_bridge {USE_RESET_REQUEST} {0}

    #clk input to default mailbox AXI path (crypto) 
    if {$HAS_OFFLOAD == 1} {
        add_instance clock_bridge_1 altera_clock_bridge
        set_instance_parameter_value clock_bridge_1 {EXPLICIT_CLOCK_RATE} {0.0}
        set_instance_parameter_value clock_bridge_1 {NUM_CLOCK_OUTPUTS} {1}

        add_instance reset_bridge_1 altera_reset_bridge
        set_instance_parameter_value reset_bridge_1 {ACTIVE_LOW_RESET} {0}
        set_instance_parameter_value reset_bridge_1 {SYNCHRONOUS_EDGES} {deassert}
        set_instance_parameter_value reset_bridge_1 {NUM_RESET_OUTPUTS} {1}
        set_instance_parameter_value reset_bridge_1 {USE_RESET_REQUEST} {0}
    }

    add_instance  s10_mailbox_client_inst altera_s10_mailbox_client_core
    set_instance_parameter_value s10_mailbox_client_inst {CMD_FIFO_DEPTH} $CMD_FIFO_DEPTH
    set_instance_parameter_value s10_mailbox_client_inst {CMD_USE_MEMORY_BLOCKS} $CMD_USE_MEMORY_BLOCKS
    set_instance_parameter_value s10_mailbox_client_inst {RSP_FIFO_DEPTH} $RSP_FIFO_DEPTH
    set_instance_parameter_value s10_mailbox_client_inst {RSP_USE_MEMORY_BLOCKS} $RSP_USE_MEMORY_BLOCKS
    set_instance_parameter_value s10_mailbox_client_inst {URG_FIFO_DEPTH} $URG_FIFO_DEPTH
    set_instance_parameter_value s10_mailbox_client_inst {URG_USE_MEMORY_BLOCKS} $URG_USE_MEMORY_BLOCKS
    set_instance_parameter_value s10_mailbox_client_inst {HAS_URGENT} $HAS_URGENT
    set_instance_parameter_value s10_mailbox_client_inst {HAS_STATUS} {1}
    set_instance_parameter_value s10_mailbox_client_inst {HAS_STREAM} $HAS_STREAM
    set_instance_parameter_value s10_mailbox_client_inst {STREAM_WIDTH} $STREAM_WIDTH
    set_instance_parameter_value s10_mailbox_client_inst {HAS_OFFLOAD} $HAS_OFFLOAD

    # connections and connection parameters
    add_connection clock_bridge.out_clk reset_bridge.clk clock
    add_connection clock_bridge.out_clk s10_mailbox_client_inst.clk clock
    add_connection reset_bridge.out_reset s10_mailbox_client_inst.reset reset

    # exported interfaces
    add_interface in_clk clock sink
    set_interface_property in_clk EXPORT_OF clock_bridge.in_clk
    add_interface in_reset reset sink
    set_interface_property in_reset EXPORT_OF reset_bridge.in_reset
    add_interface avmm avalon end
    set_interface_property avmm EXPORT_OF s10_mailbox_client_inst.avmm
    add_interface irq interrupt end
    set_interface_property irq EXPORT_OF s10_mailbox_client_inst.irq

    if {$HAS_OFFLOAD == 0} {
        set_parameter_property CRYPTO_MEMORY_TIMEOUT_VALUE ENABLED 0
    }

    if {$DEBUG == 0} {
        add_instance config_stream_endpoint_0 altera_config_stream_endpoint
        set_instance_parameter_value config_stream_endpoint_0 {READY_LATENCY} {0}
        set_instance_parameter_value config_stream_endpoint_0 {HAS_URGENT} $HAS_URGENT
        set_instance_parameter_value config_stream_endpoint_0 {HAS_STATUS} {1}
        set_instance_parameter_value config_stream_endpoint_0 {HAS_STREAM} $HAS_STREAM
        set_instance_parameter_value config_stream_endpoint_0 {MAX_SIZE} {256}
        set_instance_parameter_value config_stream_endpoint_0 {STREAM_WIDTH} $STREAM_WIDTH

        add_connection clock_bridge.out_clk config_stream_endpoint_0.clk clock 
        add_connection reset_bridge.out_reset config_stream_endpoint_0.reset reset
        add_connection config_stream_endpoint_0.response s10_mailbox_client_inst.response avalon_streaming
        add_connection s10_mailbox_client_inst.command        config_stream_endpoint_0.command avalon_streaming
        
        if {$HAS_URGENT != 0} {
            add_connection s10_mailbox_client_inst.urgent         config_stream_endpoint_0.urgent avalon_streaming
        }
        
        add_connection s10_mailbox_client_inst.command_status config_stream_endpoint_0.command_status conduit

        if {$HAS_STREAM != 0} {
            add_connection s10_mailbox_client_inst.stream_active config_stream_endpoint_0.stream_active conduit
            if {$HAS_STREAM == 2} {
                add_connection s10_mailbox_client_inst.stream        config_stream_endpoint_0.stream avalon_streaming
            }
        }
        
        # instantiate memory_initiator_endpoint crypto fabric and connect to sdm clock input, and sdm reset input from mailbox client
        if {$HAS_OFFLOAD == 1} {
            add_instance intel_memory_initiator_endpoint_0 intel_memory_initiator_endpoint
            set_instance_parameter_value intel_memory_initiator_endpoint_0 {CRYPTO_MEMORY_TIMEOUT_VALUE} $CRYPTO_MEMORY_TIMEOUT_VALUE
            set_instance_parameter_value intel_memory_initiator_endpoint_0 {HAS_OFFLOAD} $HAS_OFFLOAD
            
            add_connection clock_bridge_1.out_clk intel_memory_initiator_endpoint_0.clk clock 
            add_connection reset_bridge_1.out_reset intel_memory_initiator_endpoint_0.reset reset
        
            add_connection intel_memory_initiator_endpoint_0.axi_target s10_mailbox_client_inst.crypto_axi_target axi4
            
            add_connection intel_memory_initiator_endpoint_0.crypto_error_recovery s10_mailbox_client_inst.crypto_error_recovery conduit
            add_connection intel_memory_initiator_endpoint_0.crypto_memory_timeout s10_mailbox_client_inst.crypto_memory_timeout conduit
        }
    } else {
        add_interface command avalon_streaming source
        set_interface_property command EXPORT_OF s10_mailbox_client_inst.command
        add_interface response avalon_streaming sink
        set_interface_property response EXPORT_OF s10_mailbox_client_inst.response
        
        if {$HAS_URGENT != 0} {
            add_interface urgent avalon_streaming source
            set_interface_property urgent EXPORT_OF s10_mailbox_client_inst.urgent
            add_interface urgent avalon_streaming source
            set_interface_property urgent EXPORT_OF s10_mailbox_client_inst.urgent
        }
        
        add_interface command_status conduit end
        set_interface_property command_status EXPORT_OF s10_mailbox_client_inst.command_status

        if {$HAS_STREAM != 0} {
            add_interface stream_active conduit end
            set_interface_property stream_active EXPORT_OF s10_mailbox_client_inst.stream_active
            if {$HAS_STREAM == 2} {
                add_interface stream avalon_streaming source
                set_interface_property stream EXPORT_OF s10_mailbox_client_inst.stream
            }
        }
        
        # export all signals from mailbox client to be connected to crypto fabric interface instead of connecting to memory_initiator_endpoint
        # user axi clock & reset , crypto AXI target interface
        if {$HAS_OFFLOAD == 1} {
            add_interface crypto_axi_target axi4 end
            set_interface_property crypto_axi_target EXPORT_OF s10_mailbox_client_inst.crypto_axi_target
            
            add_interface crypto_error_recovery conduit end
            set_interface_property crypto_error_recovery EXPORT_OF s10_mailbox_client_inst.crypto_error_recovery
            
            add_interface crypto_memory_timeout conduit end
            set_interface_property crypto_memory_timeout EXPORT_OF s10_mailbox_client_inst.crypto_memory_timeout
        }

    }
    # This stream interface is shared for both cases, debug on and off
    if {$HAS_STREAM == 2} {
        add_interface avst_stream avalon_streaming sink
        set_interface_property avst_stream EXPORT_OF s10_mailbox_client_inst.avst_stream
    }
    
    # This user AXI manager interface and SDM clock output is shared for both cases, debug on and off
    # As it is exporting the mailbox AXI manager interface and SDM clock to user
    if {$HAS_OFFLOAD == 1} {
        #export axi clk and reset signals to user 
        add_interface axi_in_clk clock sink
        set_interface_property axi_in_clk EXPORT_OF clock_bridge_1.in_clk
        add_interface axi_in_reset reset sink
        set_interface_property axi_in_reset EXPORT_OF reset_bridge_1.in_reset
        
        #connections of axi clock bridge and reset bridge to mailbox client axi clock in and reset in
        add_connection clock_bridge_1.out_clk reset_bridge_1.clk clock
        add_connection clock_bridge_1.out_clk s10_mailbox_client_inst.user_axi_clk_in clock
        add_connection reset_bridge_1.out_reset s10_mailbox_client_inst.user_axi_reset_in reset

        add_interface axi_target axi4 start
        set_interface_property axi_target EXPORT_OF s10_mailbox_client_inst.axi_target
    }
}

proc log2 x {expr {int(ceil(log($x) / log(2)))}}

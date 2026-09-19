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


# $Id: //acds/rel/26.1.1/ip/pgm/altera_s10_mailbox_client/altera_s10_mailbox_client_core_hw.tcl#1 $
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
set_module_property NAME altera_s10_mailbox_client_core
set_module_property VERSION 21.0.0
set_module_property INTERNAL true
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property GROUP "Basic Functions/Configuration and Programming"
set_module_property AUTHOR "Altera"
set_module_property DISPLAY_NAME "Mailbox Client Core"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property REPORT_TO_TALKBACK false
set_module_property ALLOW_GREYBOX_GENERATION false
set_module_property REPORT_HIERARCHY false
set_module_property ELABORATION_CALLBACK elaborate
# set all_supported_device_families_list {"Stratix 10"  "Falcon Mesa"}
# set_module_property SUPPORTED_DEVICE_FAMILIES       $all_supported_device_families_list

# 
# file sets
# 
add_fileset synthesis_fileset QUARTUS_SYNTH synth_callback_procedure
set_fileset_property synthesis_fileset TOP_LEVEL altera_s10_mailbox_client_core
add_fileset simulation_fileset SIM_VERILOG synth_callback_procedure
set_fileset_property simulation_fileset TOP_LEVEL altera_s10_mailbox_client_core
add_fileset vhdl_fileset SIM_VHDL synth_callback_procedure
set_fileset_property vhdl_fileset TOP_LEVEL altera_s10_mailbox_client_core

proc synth_callback_procedure { entity_name } {
    add_fileset_file intel_avst_dp_scfifo.sv   SYSTEM_VERILOG PATH "../lib/intel_avst_dp_scfifo/intel_avst_dp_scfifo.sv"
    add_fileset_file altera_s10_mailbox_client_core.sv SYSTEM_VERILOG PATH "altera_s10_mailbox_client_core.sv"
}


# 
# parameters
# 
# 
# parameters
# 
add_parameter CMD_FIFO_DEPTH INTEGER 16
set_parameter_property CMD_FIFO_DEPTH DISPLAY_NAME "Command FIFO: Depth"
set_parameter_property CMD_FIFO_DEPTH AFFECTS_ELABORATION true
set_parameter_property CMD_FIFO_DEPTH AFFECTS_GENERATION false
set_parameter_property CMD_FIFO_DEPTH HDL_PARAMETER true
add_display_item "Mailbox Client Parameters" CMD_FIFO_DEPTH parameter
add_parameter CMD_USE_MEMORY_BLOCKS INTEGER 1
set_parameter_property CMD_USE_MEMORY_BLOCKS DISPLAY_NAME "Command FIFO: Use memory block"
set_parameter_property CMD_USE_MEMORY_BLOCKS AFFECTS_ELABORATION true
set_parameter_property CMD_USE_MEMORY_BLOCKS AFFECTS_GENERATION false
set_parameter_property CMD_USE_MEMORY_BLOCKS HDL_PARAMETER true
set_parameter_property CMD_USE_MEMORY_BLOCKS VISIBLE false
set_parameter_property CMD_USE_MEMORY_BLOCKS DISPLAY_HINT "boolean"
add_display_item "Mailbox Client Parameters" CMD_USE_MEMORY_BLOCKS parameter

add_parameter RSP_FIFO_DEPTH INTEGER 16
set_parameter_property RSP_FIFO_DEPTH DISPLAY_NAME "Response FIFO: Depth"
set_parameter_property RSP_FIFO_DEPTH AFFECTS_ELABORATION true
set_parameter_property RSP_FIFO_DEPTH AFFECTS_GENERATION false
set_parameter_property RSP_FIFO_DEPTH HDL_PARAMETER true
add_display_item "Mailbox Client Parameters" RSP_FIFO_DEPTH parameter
add_parameter RSP_USE_MEMORY_BLOCKS INTEGER 1
set_parameter_property RSP_USE_MEMORY_BLOCKS DISPLAY_NAME "Response FIFO: Use memory block"
set_parameter_property RSP_USE_MEMORY_BLOCKS AFFECTS_ELABORATION true
set_parameter_property RSP_USE_MEMORY_BLOCKS AFFECTS_GENERATION false
set_parameter_property RSP_USE_MEMORY_BLOCKS HDL_PARAMETER true
set_parameter_property RSP_USE_MEMORY_BLOCKS VISIBLE false
set_parameter_property RSP_USE_MEMORY_BLOCKS DISPLAY_HINT "boolean"
add_display_item "Mailbox Client Parameters" RSP_USE_MEMORY_BLOCKS parameter

add_parameter URG_FIFO_DEPTH INTEGER 4
set_parameter_property URG_FIFO_DEPTH DISPLAY_NAME "Urgent FIFO: Depth"
set_parameter_property URG_FIFO_DEPTH AFFECTS_ELABORATION true
set_parameter_property URG_FIFO_DEPTH AFFECTS_GENERATION false
set_parameter_property URG_FIFO_DEPTH HDL_PARAMETER true
add_display_item "Mailbox Client Parameters" URG_FIFO_DEPTH parameter
add_parameter URG_USE_MEMORY_BLOCKS INTEGER 1
set_parameter_property URG_USE_MEMORY_BLOCKS DISPLAY_NAME "Urgent FIFO: Use memory block"
set_parameter_property URG_USE_MEMORY_BLOCKS AFFECTS_ELABORATION true
set_parameter_property URG_USE_MEMORY_BLOCKS AFFECTS_GENERATION false
set_parameter_property URG_USE_MEMORY_BLOCKS HDL_PARAMETER true
set_parameter_property URG_USE_MEMORY_BLOCKS VISIBLE false
set_parameter_property URG_USE_MEMORY_BLOCKS DISPLAY_HINT "boolean"
add_display_item "Mailbox Client Parameters" URG_USE_MEMORY_BLOCKS parameter

add_parameter HAS_URGENT INTEGER 0
set_parameter_property HAS_URGENT ALLOWED_RANGES {0 1}
set_parameter_property HAS_URGENT AFFECTS_ELABORATION true
set_parameter_property HAS_URGENT AFFECTS_GENERATION false
set_parameter_property HAS_URGENT HDL_PARAMETER true
set_parameter_property HAS_URGENT VISIBLE false

add_parameter HAS_STATUS INTEGER 1
set_parameter_property HAS_STATUS ALLOWED_RANGES {0 1}
set_parameter_property HAS_STATUS AFFECTS_ELABORATION true
set_parameter_property HAS_STATUS AFFECTS_GENERATION false
set_parameter_property HAS_STATUS HDL_PARAMETER true
set_parameter_property HAS_STATUS VISIBLE false

add_parameter HAS_STREAM INTEGER 0
set_parameter_property HAS_STREAM DISPLAY_NAME "Enable Stream Interface"
set_parameter_property HAS_STREAM ALLOWED_RANGES {0:Off 1:StreamActiveOnly 2:Both}
set_parameter_property HAS_STREAM AFFECTS_ELABORATION true
set_parameter_property HAS_STREAM AFFECTS_GENERATION true
set_parameter_property HAS_STREAM HDL_PARAMETER true
set_parameter_property HAS_STREAM VISIBLE true

add_parameter STREAM_WIDTH INTEGER 32
set_parameter_property STREAM_WIDTH DISPLAY_NAME "Stream Data Width"
set_parameter_property STREAM_WIDTH ALLOWED_RANGES {32 64}
set_parameter_property STREAM_WIDTH AFFECTS_ELABORATION true
set_parameter_property STREAM_WIDTH AFFECTS_GENERATION true
set_parameter_property STREAM_WIDTH HDL_PARAMETER true
set_parameter_property STREAM_WIDTH DERIVED false
set_parameter_property STREAM_WIDTH VISIBLE true

add_parameter HAS_OFFLOAD INTEGER 0
set_parameter_property HAS_OFFLOAD DEFAULT_VALUE 0
set_parameter_property HAS_OFFLOAD DISPLAY_NAME "Enable Crypto Service"
set_parameter_property HAS_OFFLOAD TYPE INTEGER
set_parameter_property HAS_OFFLOAD UNITS None
set_parameter_property HAS_OFFLOAD ALLOWED_RANGES {0 1}
set_parameter_property HAS_OFFLOAD DESCRIPTION "Enable Crypto Offloading"
set_parameter_property HAS_OFFLOAD HDL_PARAMETER true
set_parameter_property HAS_OFFLOAD VISIBLE true

add_display_item "Config Stream Parameters" HAS_STREAM parameter
add_display_item "Config Stream Parameters" STREAM_WIDTH parameter
add_display_item "Config Stream Parameters" HAS_URGENT parameter
add_display_item "Memory AXI Manager Parameters" HAS_OFFLOAD parameter

# 
# display items
# 
add_display_item "" "Mailbox Client Parameters" GROUP ""
add_display_item "" "Config Stream Parameters" GROUP ""
add_display_item "" "Memory AXI Manager Parameters" GROUP ""
add_display_item "" "Internal Parameters" GROUP ""
# 
# connection point clk
# 
add_interface clk clock end
set_interface_property clk clockRate 0
set_interface_property clk ENABLED true
set_interface_property clk EXPORT_OF ""
set_interface_property clk PORT_NAME_MAP ""
set_interface_property clk CMSIS_SVD_VARIABLES ""
set_interface_property clk SVD_ADDRESS_GROUP ""

add_interface_port clk clk clk Input 1

# 
# connection point user_axi_clk_in
# 
add_interface user_axi_clk_in clock end
set_interface_property user_axi_clk_in clockRate 0
set_interface_property user_axi_clk_in ENABLED true
set_interface_property user_axi_clk_in EXPORT_OF ""
set_interface_property user_axi_clk_in PORT_NAME_MAP ""
set_interface_property user_axi_clk_in CMSIS_SVD_VARIABLES ""
set_interface_property user_axi_clk_in SVD_ADDRESS_GROUP ""
set_interface_property user_axi_clk_in IPXACT_REGISTER_MAP_VARIABLES ""

set_interface_property user_axi_clk_in ENABLED false
add_interface_port user_axi_clk_in axi_clk_in clk Input 1
set_port_property axi_clk_in termination true

# 
# connection point reset
# 
add_interface reset reset end
set_interface_property reset associatedClock clk
set_interface_property reset synchronousEdges BOTH
set_interface_property reset ENABLED true
set_interface_property reset EXPORT_OF ""
set_interface_property reset PORT_NAME_MAP ""
set_interface_property reset CMSIS_SVD_VARIABLES ""
set_interface_property reset SVD_ADDRESS_GROUP ""

add_interface_port reset reset reset Input 1

# 
# connection point user_axi_reset_in
# 
add_interface user_axi_reset_in reset end
set_interface_property user_axi_reset_in associatedClock user_axi_clk_in
set_interface_property user_axi_reset_in synchronousEdges DEASSERT
set_interface_property user_axi_reset_in ENABLED true
set_interface_property user_axi_reset_in EXPORT_OF ""
set_interface_property user_axi_reset_in PORT_NAME_MAP ""
set_interface_property user_axi_reset_in CMSIS_SVD_VARIABLES ""
set_interface_property user_axi_reset_in SVD_ADDRESS_GROUP ""
set_interface_property user_axi_reset_in IPXACT_REGISTER_MAP_VARIABLES ""

set_interface_property user_axi_reset_in ENABLED false
add_interface_port user_axi_reset_in axi_reset_in reset Input 1
set_port_property axi_reset_in termination true


# 
# connection point command
# 
add_interface command avalon_streaming start
set_interface_property command associatedClock clk
set_interface_property command associatedReset reset
set_interface_property command dataBitsPerSymbol 32
set_interface_property command errorDescriptor ""
set_interface_property command firstSymbolInHighOrderBits true
set_interface_property command maxChannel 0
set_interface_property command readyLatency 0
set_interface_property command ENABLED true
set_interface_property command EXPORT_OF ""
set_interface_property command PORT_NAME_MAP ""
set_interface_property command CMSIS_SVD_VARIABLES ""
set_interface_property command SVD_ADDRESS_GROUP ""

add_interface_port command command_ready ready Input 1
add_interface_port command command_valid valid Output 1
add_interface_port command command_data data Output 32
add_interface_port command command_startofpacket startofpacket Output 1
add_interface_port command command_endofpacket endofpacket Output 1


# 
# connection point response
# 
add_interface response avalon_streaming end
set_interface_property response associatedClock clk
set_interface_property response associatedReset reset
set_interface_property response dataBitsPerSymbol 32
set_interface_property response errorDescriptor ""
set_interface_property response firstSymbolInHighOrderBits true
set_interface_property response maxChannel 0
set_interface_property response readyLatency 0
set_interface_property response ENABLED true
set_interface_property response EXPORT_OF ""
set_interface_property response PORT_NAME_MAP ""
set_interface_property response CMSIS_SVD_VARIABLES ""
set_interface_property response SVD_ADDRESS_GROUP ""

add_interface_port response response_ready ready Output 1
add_interface_port response response_valid valid Input 1
add_interface_port response response_data data Input 32
add_interface_port response response_startofpacket startofpacket Input 1
add_interface_port response response_endofpacket endofpacket Input 1


# 
# connection point urgent
# 
add_interface urgent avalon_streaming start
set_interface_property urgent dataBitsPerSymbol 32
set_interface_property urgent associatedClock clk
set_interface_property urgent associatedReset reset

set_interface_property urgent ENABLED false
add_interface_port  urgent urgent_ready ready Input 1
set_port_property 	urgent_ready termination true
add_interface_port  urgent urgent_valid valid Output 1
set_port_property 	urgent_valid termination true
add_interface_port  urgent urgent_data data Output 32
set_port_property 	urgent_data termination true
		
# 
# connection point stream
# 
add_interface stream avalon_streaming start
set_interface_property stream associatedClock clk
set_interface_property stream associatedReset reset
set_interface_property stream errorDescriptor ""
set_interface_property stream firstSymbolInHighOrderBits true
set_interface_property stream maxChannel 0
set_interface_property stream readyLatency 0
set_interface_property stream ENABLED false
set_interface_property stream EXPORT_OF ""
set_interface_property stream PORT_NAME_MAP ""
set_interface_property stream CMSIS_SVD_VARIABLES ""
set_interface_property stream SVD_ADDRESS_GROUP ""

set_interface_property stream ENABLED false
add_interface_port stream stream_ready ready Input 1
set_port_property stream_ready termination true
add_interface_port stream stream_valid valid Output 1
set_port_property stream_valid termination true
add_interface_port stream stream_data data Output STREAM_WIDTH
set_port_property stream_data termination true

# 
# connection point stream - connect to end user side
# 
add_interface avst_stream avalon_streaming end
set_interface_property avst_stream associatedClock clk
set_interface_property avst_stream associatedReset reset
set_interface_property avst_stream errorDescriptor ""
set_interface_property avst_stream firstSymbolInHighOrderBits true
set_interface_property avst_stream maxChannel 0
set_interface_property avst_stream readyLatency 0
set_interface_property avst_stream ENABLED false
set_interface_property avst_stream EXPORT_OF ""
set_interface_property avst_stream PORT_NAME_MAP ""
set_interface_property avst_stream CMSIS_SVD_VARIABLES ""
set_interface_property avst_stream SVD_ADDRESS_GROUP ""

set_interface_property avst_stream ENABLED false
add_interface_port avst_stream avst_stream_ready ready Output 1
set_port_property avst_stream_ready termination true
add_interface_port avst_stream avst_stream_valid valid Input 1
set_port_property avst_stream_valid termination true
add_interface_port avst_stream avst_stream_data data Input STREAM_WIDTH
set_port_property avst_stream_data termination true


# 
# connection point stream_active
# 
add_interface stream_active conduit end
set_interface_property stream_active associatedClock clk
set_interface_property stream_active associatedReset reset
set_interface_property stream_active ENABLED false
set_interface_property stream_active EXPORT_OF ""
set_interface_property stream_active PORT_NAME_MAP ""
set_interface_property stream_active CMSIS_SVD_VARIABLES ""
set_interface_property stream_active SVD_ADDRESS_GROUP ""

set_interface_property stream_active ENABLED false
add_interface_port stream_active stream_active active Input 1
set_port_property stream_active termination true

#
# connection point command_status
#
add_interface command_status conduit end
set_interface_property command_status associatedClock clk
set_interface_property command_status associatedReset reset
set_interface_property command_status ENABLED false
add_interface_port command_status command_invalid invalid Output 1
set_port_property command_invalid termination true

#
# connection point crypto_error_recovery
#
add_interface crypto_error_recovery conduit end
#set_interface_property crypto_error_recovery associatedClock user_axi_clk_in
#set_interface_property crypto_error_recovery associatedReset user_axi_reset_in
set_interface_property crypto_error_recovery ENABLED false
add_interface_port crypto_error_recovery crypto_error_recovery_in_progress progress Input 1
set_port_property crypto_error_recovery_in_progress termination true

#
# connection point crypto_memory_timeout
#
add_interface crypto_memory_timeout conduit end
#set_interface_property crypto_memory_timeout associatedClock user_axi_clk_in
#set_interface_property crypto_memory_timeout associatedReset user_axi_reset_in
set_interface_property crypto_memory_timeout ENABLED false
add_interface_port crypto_memory_timeout crypto_memory_timeout timeout Input 1
set_port_property crypto_memory_timeout termination true

# 
# connection point avmm
# 
add_interface avmm avalon end
set_interface_property avmm addressUnits WORDS
set_interface_property avmm associatedClock clk
set_interface_property avmm associatedReset reset
set_interface_property avmm bitsPerSymbol 8
set_interface_property avmm bridgedAddressOffset 0
set_interface_property avmm bridgesToMaster ""
set_interface_property avmm burstOnBurstBoundariesOnly false
set_interface_property avmm burstcountUnits WORDS
set_interface_property avmm explicitAddressSpan 0
set_interface_property avmm holdTime 0
set_interface_property avmm linewrapBursts false
set_interface_property avmm maximumPendingReadTransactions 1
set_interface_property avmm maximumPendingWriteTransactions 0
set_interface_property avmm readLatency 0
set_interface_property avmm readWaitTime 0
set_interface_property avmm setupTime 0
set_interface_property avmm timingUnits Cycles
set_interface_property avmm transparentBridge false
set_interface_property avmm writeWaitTime 0
set_interface_property avmm ENABLED true
set_interface_property avmm EXPORT_OF ""
set_interface_property avmm PORT_NAME_MAP ""
set_interface_property avmm CMSIS_SVD_VARIABLES ""
set_interface_property avmm SVD_ADDRESS_GROUP ""

add_interface_port avmm avmm_address address Input 4
add_interface_port avmm avmm_write write Input 1
add_interface_port avmm avmm_writedata writedata Input 32
add_interface_port avmm avmm_read read Input 1
add_interface_port avmm avmm_readdata readdata Output 32
add_interface_port avmm avmm_readdatavalid readdatavalid Output 1
# add waitrequest signal
add_interface_port avmm avmm_waitrequest waitrequest Output 1


# 
# connection point irq
# 
add_interface irq interrupt end
set_interface_property irq associatedAddressablePoint "avmm"
set_interface_property irq associatedClock clk
set_interface_property irq associatedReset reset
set_interface_property irq bridgedReceiverOffset ""
set_interface_property irq bridgesToReceiver ""
set_interface_property irq ENABLED true
set_interface_property irq EXPORT_OF ""
set_interface_property irq PORT_NAME_MAP ""
set_interface_property irq CMSIS_SVD_VARIABLES ""
set_interface_property irq SVD_ADDRESS_GROUP ""

add_interface_port irq irq irq Output 1

# 
# connection point crypto_axi_target - connection to crypto fabric interface
# 
add_interface crypto_axi_target axi4 end
set_interface_property crypto_axi_target associatedClock user_axi_clk_in
set_interface_property crypto_axi_target associatedReset user_axi_reset_in
set_interface_property crypto_axi_target readAcceptanceCapability 1
set_interface_property crypto_axi_target writeAcceptanceCapability 1
set_interface_property crypto_axi_target combinedAcceptanceCapability 1
set_interface_property crypto_axi_target readDataReorderingDepth 1
set_interface_property crypto_axi_target bridgesToMaster ""
set_interface_property crypto_axi_target ENABLED true
set_interface_property crypto_axi_target EXPORT_OF ""
set_interface_property crypto_axi_target PORT_NAME_MAP ""
set_interface_property crypto_axi_target CMSIS_SVD_VARIABLES ""
set_interface_property crypto_axi_target SVD_ADDRESS_GROUP ""
set_interface_property crypto_axi_target IPXACT_REGISTER_MAP_VARIABLES ""

set_interface_property crypto_axi_target ENABLED false
add_interface_port crypto_axi_target crypto_axi_target_awid awid Input 4
set_port_property crypto_axi_target_awid termination true
add_interface_port crypto_axi_target crypto_axi_target_awaddr awaddr Input 32
set_port_property crypto_axi_target_awaddr termination true
add_interface_port crypto_axi_target crypto_axi_target_awlen awlen Input 8
set_port_property crypto_axi_target_awlen termination true
add_interface_port crypto_axi_target crypto_axi_target_awsize awsize Input 3
set_port_property crypto_axi_target_awsize termination true
add_interface_port crypto_axi_target crypto_axi_target_awburst awburst Input 2
set_port_property crypto_axi_target_awburst termination true
add_interface_port crypto_axi_target crypto_axi_target_awlock awlock Input 1
set_port_property crypto_axi_target_awlock termination true
add_interface_port crypto_axi_target crypto_axi_target_awcache awcache Input 4
set_port_property crypto_axi_target_awcache termination true
add_interface_port crypto_axi_target crypto_axi_target_awprot awprot Input 3
set_port_property crypto_axi_target_awprot termination true
add_interface_port crypto_axi_target crypto_axi_target_awqos awqos Input 4
set_port_property crypto_axi_target_awqos termination true
add_interface_port crypto_axi_target crypto_axi_target_awvalid awvalid Input 1
set_port_property crypto_axi_target_awvalid termination true
add_interface_port crypto_axi_target crypto_axi_target_awuser awuser Input 5
set_port_property crypto_axi_target_awuser termination true
add_interface_port crypto_axi_target crypto_axi_target_awready awready Output 1
set_port_property crypto_axi_target_awready termination true
add_interface_port crypto_axi_target crypto_axi_target_wdata wdata Input 64
set_port_property crypto_axi_target_wdata termination true
add_interface_port crypto_axi_target crypto_axi_target_wlast wlast Input 1
set_port_property crypto_axi_target_wlast termination true
add_interface_port crypto_axi_target crypto_axi_target_wready wready Output 1
set_port_property crypto_axi_target_wready termination true
add_interface_port crypto_axi_target crypto_axi_target_wvalid wvalid Input 1
set_port_property crypto_axi_target_wvalid termination true
add_interface_port crypto_axi_target crypto_axi_target_wstrb wstrb Input 8
set_port_property crypto_axi_target_wstrb termination true
add_interface_port crypto_axi_target crypto_axi_target_bid bid Output 4
set_port_property crypto_axi_target_bid termination true
add_interface_port crypto_axi_target crypto_axi_target_bresp bresp Output 2
set_port_property crypto_axi_target_bresp termination true
add_interface_port crypto_axi_target crypto_axi_target_bvalid bvalid Output 1
set_port_property crypto_axi_target_bvalid termination true
add_interface_port crypto_axi_target crypto_axi_target_bready bready Input 1
set_port_property crypto_axi_target_bready termination true
add_interface_port crypto_axi_target crypto_axi_target_rdata rdata Output 64
set_port_property crypto_axi_target_rdata termination true
add_interface_port crypto_axi_target crypto_axi_target_rresp rresp Output 2
set_port_property crypto_axi_target_rresp termination true
add_interface_port crypto_axi_target crypto_axi_target_rlast rlast Output 1
set_port_property crypto_axi_target_rlast termination true
add_interface_port crypto_axi_target crypto_axi_target_rvalid rvalid Output 1
set_port_property crypto_axi_target_rvalid termination true
add_interface_port crypto_axi_target crypto_axi_target_rready rready Input 1
set_port_property crypto_axi_target_rready termination true
add_interface_port crypto_axi_target crypto_axi_target_arid arid Input 4
set_port_property crypto_axi_target_arid termination true
add_interface_port crypto_axi_target crypto_axi_target_araddr araddr Input 32
set_port_property crypto_axi_target_araddr termination true
add_interface_port crypto_axi_target crypto_axi_target_arlen arlen Input 8
set_port_property crypto_axi_target_arlen termination true
add_interface_port crypto_axi_target crypto_axi_target_arsize arsize Input 3
set_port_property crypto_axi_target_arsize termination true
add_interface_port crypto_axi_target crypto_axi_target_arburst arburst Input 2
set_port_property crypto_axi_target_arburst termination true
add_interface_port crypto_axi_target crypto_axi_target_arlock arlock Input 1
set_port_property crypto_axi_target_arlock termination true
add_interface_port crypto_axi_target crypto_axi_target_arcache arcache Input 4
set_port_property crypto_axi_target_arcache termination true
add_interface_port crypto_axi_target crypto_axi_target_arprot arprot Input 3
set_port_property crypto_axi_target_arprot termination true
add_interface_port crypto_axi_target crypto_axi_target_arqos arqos Input 4
set_port_property crypto_axi_target_arqos termination true
add_interface_port crypto_axi_target crypto_axi_target_arvalid arvalid Input 1
set_port_property crypto_axi_target_arvalid termination true
add_interface_port crypto_axi_target crypto_axi_target_aruser aruser Input 5
set_port_property crypto_axi_target_aruser termination true
add_interface_port crypto_axi_target crypto_axi_target_arready arready Output 1
set_port_property crypto_axi_target_arready termination true
add_interface_port crypto_axi_target crypto_axi_target_rid rid Output 4
set_port_property crypto_axi_target_rid termination true


# 
# connection point axi_target - connect to end user side
# 
add_interface axi_target axi4 start
set_interface_property axi_target associatedClock user_axi_clk_in
set_interface_property axi_target associatedReset user_axi_reset_in
set_interface_property axi_target readIssuingCapability 1
set_interface_property axi_target writeIssuingCapability 1
set_interface_property axi_target combinedIssuingCapability 1
set_interface_property axi_target issuesINCRBursts true
set_interface_property axi_target issuesWRAPBursts true
set_interface_property axi_target issuesFIXEDBursts true
set_interface_property axi_target ENABLED true
set_interface_property axi_target EXPORT_OF ""
set_interface_property axi_target PORT_NAME_MAP ""
set_interface_property axi_target CMSIS_SVD_VARIABLES ""
set_interface_property axi_target SVD_ADDRESS_GROUP ""
set_interface_property axi_target IPXACT_REGISTER_MAP_VARIABLES ""

set_interface_property axi_target ENABLED false
add_interface_port axi_target axi_target_awid awid Output 4
set_port_property axi_target_awid termination true
add_interface_port axi_target axi_target_awaddr awaddr Output 32
set_port_property axi_target_awaddr termination true
add_interface_port axi_target axi_target_awlen awlen Output 8
set_port_property axi_target_awlen termination true
add_interface_port axi_target axi_target_awsize awsize Output 3
set_port_property axi_target_awsize termination true
add_interface_port axi_target axi_target_awburst awburst Output 2
set_port_property axi_target_awburst termination true
add_interface_port axi_target axi_target_awlock awlock Output 1
set_port_property axi_target_awlock termination true
add_interface_port axi_target axi_target_awcache awcache Output 4
set_port_property axi_target_awcache termination true
add_interface_port axi_target axi_target_awprot awprot Output 3
set_port_property axi_target_awprot termination true
add_interface_port axi_target axi_target_awqos awqos Output 4
set_port_property axi_target_awqos termination true
add_interface_port axi_target axi_target_awvalid awvalid Output 1
set_port_property axi_target_awvalid termination true
add_interface_port axi_target axi_target_awuser awuser Output 5
set_port_property axi_target_awuser termination true
add_interface_port axi_target axi_target_awready awready Input 1
set_port_property axi_target_awready termination true
add_interface_port axi_target axi_target_wdata wdata Output 64
set_port_property axi_target_wdata termination true
add_interface_port axi_target axi_target_wlast wlast Output 1
set_port_property axi_target_wlast termination true
add_interface_port axi_target axi_target_wready wready Input 1
set_port_property axi_target_wready termination true
add_interface_port axi_target axi_target_wvalid wvalid Output 1
set_port_property axi_target_wvalid termination true
add_interface_port axi_target axi_target_wstrb wstrb Output 8
set_port_property axi_target_wstrb termination true
add_interface_port axi_target axi_target_bid bid Input 4
set_port_property axi_target_bid termination true
add_interface_port axi_target axi_target_bresp bresp Input 2
set_port_property axi_target_bresp termination true
add_interface_port axi_target axi_target_bvalid bvalid Input 1
set_port_property axi_target_bvalid termination true
add_interface_port axi_target axi_target_bready bready Output 1
set_port_property axi_target_bready termination true
add_interface_port axi_target axi_target_rdata rdata Input 64
set_port_property axi_target_rdata termination true
add_interface_port axi_target axi_target_rresp rresp Input 2
set_port_property axi_target_rresp termination true
add_interface_port axi_target axi_target_rlast rlast Input 1
set_port_property axi_target_rlast termination true
add_interface_port axi_target axi_target_rready rready Output 1
set_port_property axi_target_rready termination true
add_interface_port axi_target axi_target_rvalid rvalid Input 1
set_port_property axi_target_rvalid termination true
add_interface_port axi_target axi_target_arid arid Output 4
set_port_property axi_target_arid termination true
add_interface_port axi_target axi_target_araddr araddr Output 32
set_port_property axi_target_araddr termination true
add_interface_port axi_target axi_target_arlen arlen Output 8
set_port_property axi_target_arlen termination true
add_interface_port axi_target axi_target_arsize arsize Output 3
set_port_property axi_target_arsize termination true
add_interface_port axi_target axi_target_arburst arburst Output 2
set_port_property axi_target_arburst termination true
add_interface_port axi_target axi_target_arlock arlock Output 1
set_port_property axi_target_arlock termination true
add_interface_port axi_target axi_target_arcache arcache Output 4
set_port_property axi_target_arcache termination true
add_interface_port axi_target axi_target_arprot arprot Output 3
set_port_property axi_target_arprot termination true
add_interface_port axi_target axi_target_arqos arqos Output 4
set_port_property axi_target_arqos termination true
add_interface_port axi_target axi_target_arvalid arvalid Output 1
set_port_property axi_target_arvalid termination true
add_interface_port axi_target axi_target_aruser aruser Output 5
set_port_property axi_target_aruser termination true
add_interface_port axi_target axi_target_arready arready Input 1
set_port_property axi_target_arready termination true
add_interface_port axi_target axi_target_rid rid Input 4
set_port_property axi_target_rid termination true

proc elaborate {} {
    #set CMD_FIFO_DEPTH      [get_parameter_value CMD_FIFO_DEPTH]
    #set RSP_FIFO_DEPTH      [get_parameter_value RSP_FIFO_DEPTH]
    #set URG_FIFO_DEPTH      [get_parameter_value URG_FIFO_DEPTH]
    
    set HAS_STREAM          [get_parameter_value HAS_STREAM]
    set HAS_URGENT          [get_parameter_value HAS_URGENT]
    set HAS_OFFLOAD         [get_parameter_value HAS_OFFLOAD]
    set STREAM_WIDTH        [get_parameter_value STREAM_WIDTH]
    set HAS_STATUS          [get_parameter_value HAS_STATUS]

    set_interface_property avst_stream dataBitsPerSymbol $STREAM_WIDTH
    set_interface_property stream dataBitsPerSymbol $STREAM_WIDTH
    
    # Add the sub fifo 
    #add_hdl_instance cmd_sc_fifo altera_mailbox_avalonst_fifo
    #set_instance_parameter_value cmd_sc_fifo DEVICE_FAMILY "Stratix 10"
    #set_instance_parameter_value cmd_sc_fifo FIFO_DEPTH $CMD_FIFO_DEPTH
    #set_instance_parameter_value cmd_sc_fifo EMPTY_LATENCY 1
    #
    #add_hdl_instance urg_sc_fifo altera_mailbox_avalonst_fifo
    #set_instance_parameter_value urg_sc_fifo DEVICE_FAMILY "Stratix 10"
    #set_instance_parameter_value urg_sc_fifo FIFO_DEPTH $URG_FIFO_DEPTH
    #set_instance_parameter_value urg_sc_fifo EMPTY_LATENCY 1
    #
    #add_hdl_instance rsp_sc_fifo altera_mailbox_avalonst_fifo
    #set_instance_parameter_value rsp_sc_fifo DEVICE_FAMILY "Stratix 10"
    #set_instance_parameter_value rsp_sc_fifo FIFO_DEPTH $RSP_FIFO_DEPTH
    #set_instance_parameter_value rsp_sc_fifo EMPTY_LATENCY 1

    if {$HAS_STREAM != 0} {
        set_interface_property stream_active ENABLED true
        add_interface_port stream_active stream_active active Input 1
        if {$HAS_STREAM == 2} {
            set_interface_property stream ENABLED true
            set_port_property stream_ready termination false
            set_port_property stream_valid termination false
            set_port_property stream_data width_expr $STREAM_WIDTH
            set_port_property stream_data termination false

            set_interface_property avst_stream ENABLED true
            set_port_property avst_stream_ready termination false
            set_port_property avst_stream_valid termination false
            set_port_property avst_stream_data width_expr $STREAM_WIDTH
            set_port_property avst_stream_data termination false
        }
    }

    if {$HAS_URGENT != 0} {
        set_interface_property urgent ENABLED true
		set_port_property 	urgent_ready termination false
		set_port_property 	urgent_valid termination false
		set_port_property 	urgent_data termination false
    }

    if {$HAS_STATUS != 0} {
        set_interface_property command_status ENABLED true
        add_interface_port command_status command_invalid invalid Input 1
        set_port_property command_invalid termination false
    }
    
    if {$HAS_OFFLOAD != 0} {
        set_interface_property user_axi_clk_in ENABLED true
        set_port_property axi_clk_in termination false

        set_interface_property user_axi_reset_in ENABLED true
        set_port_property axi_reset_in termination false

        set_interface_property crypto_axi_target ENABLED true
        set_port_property crypto_axi_target_awid termination false
        set_port_property crypto_axi_target_awaddr termination false
        set_port_property crypto_axi_target_awlen termination false
        set_port_property crypto_axi_target_awsize termination false
        set_port_property crypto_axi_target_awburst termination false
        set_port_property crypto_axi_target_awlock termination false
        set_port_property crypto_axi_target_awcache termination false
        set_port_property crypto_axi_target_awprot termination false
        set_port_property crypto_axi_target_awqos termination false
        set_port_property crypto_axi_target_awvalid termination false
        set_port_property crypto_axi_target_awuser termination false
        set_port_property crypto_axi_target_awready termination false
        set_port_property crypto_axi_target_wdata termination false
        set_port_property crypto_axi_target_wlast termination false
        set_port_property crypto_axi_target_wready termination false
        set_port_property crypto_axi_target_wvalid termination false
        set_port_property crypto_axi_target_wstrb termination false
        set_port_property crypto_axi_target_bid termination false
        set_port_property crypto_axi_target_bresp termination false
        set_port_property crypto_axi_target_bvalid termination false
        set_port_property crypto_axi_target_bready termination false
        set_port_property crypto_axi_target_rdata termination false
        set_port_property crypto_axi_target_rresp termination false
        set_port_property crypto_axi_target_rlast termination false
        set_port_property crypto_axi_target_rvalid termination false
        set_port_property crypto_axi_target_rready termination false
        set_port_property crypto_axi_target_arid termination false
        set_port_property crypto_axi_target_araddr termination false
        set_port_property crypto_axi_target_arlen termination false
        set_port_property crypto_axi_target_arsize termination false
        set_port_property crypto_axi_target_arburst termination false
        set_port_property crypto_axi_target_arlock termination false
        set_port_property crypto_axi_target_arcache termination false
        set_port_property crypto_axi_target_arprot termination false
        set_port_property crypto_axi_target_arqos termination false
        set_port_property crypto_axi_target_arvalid termination false
        set_port_property crypto_axi_target_aruser termination false
        set_port_property crypto_axi_target_arready termination false
        set_port_property crypto_axi_target_rid termination false
        
        set_interface_property axi_target ENABLED true
        set_port_property axi_target_awid termination false
        set_port_property axi_target_awaddr termination false
        set_port_property axi_target_awlen termination false
        set_port_property axi_target_awsize termination false
        set_port_property axi_target_awburst termination false
        set_port_property axi_target_awlock termination false
        set_port_property axi_target_awcache termination false
        set_port_property axi_target_awprot termination false
        set_port_property axi_target_awqos termination false
        set_port_property axi_target_awvalid termination false
        set_port_property axi_target_awuser termination false
        set_port_property axi_target_awready termination false
        set_port_property axi_target_wdata termination false
        set_port_property axi_target_wlast termination false
        set_port_property axi_target_wready termination false
        set_port_property axi_target_wvalid termination false
        set_port_property axi_target_wstrb termination false
        set_port_property axi_target_bid termination false
        set_port_property axi_target_bresp termination false
        set_port_property axi_target_bvalid termination false
        set_port_property axi_target_bready termination false
        set_port_property axi_target_rdata termination false
        set_port_property axi_target_rresp termination false
        set_port_property axi_target_rlast termination false
        set_port_property axi_target_rready termination false
        set_port_property axi_target_rvalid termination false
        set_port_property axi_target_arid termination false
        set_port_property axi_target_araddr termination false
        set_port_property axi_target_arlen termination false
        set_port_property axi_target_arsize termination false
        set_port_property axi_target_arburst termination false
        set_port_property axi_target_arlock termination false
        set_port_property axi_target_arcache termination false
        set_port_property axi_target_arprot termination false
        set_port_property axi_target_arqos termination false
        set_port_property axi_target_arvalid termination false
        set_port_property axi_target_aruser termination false
        set_port_property axi_target_arready termination false
        set_port_property axi_target_rid termination false
        
        set_interface_property crypto_error_recovery ENABLED true
        set_port_property crypto_error_recovery_in_progress termination false
        
        set_interface_property crypto_memory_timeout ENABLED true
        set_port_property crypto_memory_timeout termination false

    }
}

proc log2 x {expr {int(ceil(log($x) / log(2)))}}

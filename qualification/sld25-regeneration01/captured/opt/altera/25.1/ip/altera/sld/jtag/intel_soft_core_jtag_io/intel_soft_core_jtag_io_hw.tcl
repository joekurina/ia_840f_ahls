# (C) 2001-2025 Altera Corporation. All rights reserved.
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


package require -exact qsys 21.1

# 
# Module altera_jtag_host
# 
set_module_property NAME intel_soft_core_jtag_io
set_module_property DESCRIPTION "Provides a standard JTAG interface that controls all JTAG based SLD debug nodes. Under the hood, it really controls SLD JTAG hub to which SLD debug nodes connect. A minimal JTAG controller is implemented to allow full operations of tools that communicate to SLD debug nodes connected to SLD JTAG hub. The IR instructions implemented are BYPASS, IDCODE, USR0, and USR1. All other IR values are mapped to BYPASS. This JTAG controller returns IDCODE value, 0x020030DD. The TDO output is never tri-stated and is launched at positive edge of TCK, which makes it not conforming to JTAG standard. Only one instance of such IP is allowed within one project."
set_module_property VERSION 1.0
set_module_property GROUP "Basic Functions/Simulation; Debug and Verification/Debug and Performance"
set_module_property AUTHOR  "Intel Corporation"
set_module_property DISPLAY_NAME {Soft Core JTAG I/O Intel FPGA IP}
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE false
set_module_property COMPOSITION_CALLBACK compose
# These two lines are needed to make sure sub-components are reported in SOPCINFO file
# System Console needs the meta information in sub-components to do design linking
set_module_property REPORT_HIERARCHY true
set_module_property OPAQUE_ADDRESS_MAP false

# 
# Parameters
# 
add_parameter CONTROL STRING host
set_parameter_property CONTROL ALLOWED_RANGES {host hubctrl}
set_parameter_property CONTROL AFFECTS_GENERATION false
set_parameter_property CONTROL HDL_PARAMETER true
set_parameter_property CONTROL VISIBLE false

add_parameter NAME STRING "soft_jtag"
set_parameter_property NAME AFFECTS_GENERATION true
set_parameter_property NAME HDL_PARAMETER true
set_parameter_property NAME VISIBLE false

# HOST_PRIORITY for default hard JTAG is 100, so the value here has to be more than 100 in order to be higher priority
add_parameter HOST_PRIORITY INTEGER 200
set_parameter_property HOST_PRIORITY AFFECTS_GENERATION true
set_parameter_property HOST_PRIORITY HDL_PARAMETER true
set_parameter_property HOST_PRIORITY VISIBLE false

add_parameter USE_TCK_ENA BOOLEAN true
set_parameter_property USE_TCK_ENA DISPLAY_NAME "Use TCK enable"
set_parameter_property USE_TCK_ENA AFFECTS_GENERATION true
set_parameter_property USE_TCK_ENA HDL_PARAMETER true

add_parameter CLOCK_RATE_CLOCK INTEGER 0
set_parameter_property CLOCK_RATE_CLOCK SYSTEM_INFO {CLOCK_RATE clock}
set_parameter_property CLOCK_RATE_CLOCK AFFECTS_GENERATION true
set_parameter_property CLOCK_RATE_CLOCK HDL_PARAMETER true
set_parameter_property CLOCK_RATE_CLOCK VISIBLE false

#
# Composition callback
#
proc compose {} {
    # Sub-module altera_clock_bridge
    add_instance clk altera_clock_bridge 19.*

    # Sub-module altera_sld_host_endpoint_bridge
    add_instance bridge altera_sld_host_endpoint_bridge 19.*
    set_instance_parameter bridge USE_TCK_ENA [get_parameter_value USE_TCK_ENA]

    # Sub-module altera_sld_host_endpoint
    add_instance ep altera_sld_host_endpoint 1.*
    set_instance_parameter ep CONTROL "hubctrl"
    set_instance_parameter ep NAME [get_parameter_value NAME]
    set_instance_parameter ep HOST_PRIORITY [get_parameter_value HOST_PRIORITY]
    set use_tck_ena [get_parameter_value USE_TCK_ENA]
    if {$use_tck_ena} {
        set_instance_parameter ep USE_TCK_ENA 1
    } else {
        set_instance_parameter ep USE_TCK_ENA 0
    }

    # tck
    add_interface jtag_clock clock end
    set_interface_property jtag_clock EXPORT_OF clk.in_clk

    # tms, tdi, tdo
    add_interface jtag_signals conduit start
    set_interface_property jtag_signals associatedClock jtag_clock
    set_interface_property jtag_signals EXPORT_OF bridge.ext_node
    # Prevent interface assignments on the sub-component being duplicated in parent component in SOPCINFO file to avoid confusing System Console during design linking
    set_interface_property jtag_signals EXPORT_ASSIGNMENTS false

    # Connections
    add_connection clk.out_clk bridge.clock
    add_connection clk.out_clk ep.clock
    add_connection bridge.int_node ep.node
}

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


package require -exact qsys 13.1

# 
# module altera_soft_core_jtag_io
# 
set_module_property DESCRIPTION "This soft JTAG I/O megafunction, altera_soft_core_jtag_io, provides a standard JTAG interface that controls all JTAG based SLD debug nodes.<br>  Under the hood, it really controls SLD JTAG hub to which SLD debug nodes connect.  Optionally, it provides a signal to select whether SLD JTAG hub is controlled by the JTAG I/O<br>on this megafunction or by the JTAG I/O on the device JTAG hard controller.
A minimal JTAG controller is implemented to allow full operations of tools<br>that communicate to SLD debug nodes connected to SLD JTAG hub.  The IR instructions implemented are BYPASS, IDCODE, USR0, and USR1.<br>All other IR values are mapped to BYPASS.  This JTAG controller returns IDCODE value, 0x020030DD, which is assigned to Altera soft JTAG controller.<br>The tdo output is never tri-stated, which does not conform to the JTAG standard. 
Only one instance of such megafunction is allowed within one project."
set_module_property NAME altera_soft_core_jtag_io
set_module_property VERSION 19.2.0
set_module_property SUPPORTED_DEVICE_FAMILIES {{ALL}}
set_module_property INTERNAL true
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property AUTHOR "Intel Corporation"
set_module_property GROUP "Basic Functions/Simulation; Debug and Verification/Debug and Performance"
set_module_property DISPLAY_NAME {Soft Core JTAG I/O Intel FPGA IP (deprecated)}
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE false
set_module_property ANALYZE_HDL AUTO
set_module_property REPORT_TO_TALKBACK false
set_module_property ALLOW_GREYBOX_GENERATION false
set_module_property NATIVE_INTERPRETER true
set_module_property elaboration_callback do_elaboration

#
# documentation
#
add_documentation_link "altera_soft_core_jtag_io Megafunction Online Help" "https://www.intel.com/content/www/us/en/programmable/quartushelp/current/index.htm#hdl/mega/mega_file_softcore_jtag_io.htm"

# 
# file sets
# 
add_fileset QUARTUS_SYNTH QUARTUS_SYNTH "" ""
set_fileset_property QUARTUS_SYNTH TOP_LEVEL altera_soft_core_jtag_io

add_fileset SIM_VHDL SIM_VHDL "" ""
set_fileset_property SIM_VHDL TOP_LEVEL altera_soft_core_jtag_io
add_fileset_file altera_soft_core_jtag_io.vhd VHDL PATH "altera_soft_core_jtag_io_sim.vhd"

add_fileset SIM_VERILOG SIM_VERILOG "" ""
set_fileset_property SIM_VERILOG TOP_LEVEL altera_soft_core_jtag_io
add_fileset_file altera_soft_core_jtag_io.v VERILOG PATH "altera_soft_core_jtag_io_sim.v"

# 
# parameters
# 

# Device Family
add_parameter device_family string ""
set_parameter_property device_family system_info_type device_family
set_parameter_property device_family VISIBLE false

add_parameter ENABLE_JTAG_IO_SELECTION BOOLEAN false ""
set_parameter_property ENABLE_JTAG_IO_SELECTION DEFAULT_VALUE false
set_parameter_property ENABLE_JTAG_IO_SELECTION DISPLAY_NAME ENABLE_JTAG_IO_SELECTION
set_parameter_property ENABLE_JTAG_IO_SELECTION WIDTH ""
set_parameter_property ENABLE_JTAG_IO_SELECTION TYPE INTEGER
set_parameter_property ENABLE_JTAG_IO_SELECTION UNITS None
set_parameter_property ENABLE_JTAG_IO_SELECTION DISPLAY_HINT BOOLEAN
set_parameter_property ENABLE_JTAG_IO_SELECTION DESCRIPTION "Specifies whether the JTAG I/O selection is enabled. If enabled, a select input port is used and drives a mux that selects the JTAG I/O between the interface on this megafunction and the interface on the JTAG hard controller. As mux is added on tck, a clock input to registers, clock skew may occur. You are responsible for timing closure, and no extra fitter support is provided for it. A non-zero value enables this parameter; zero disables it. The default is 0."
set_parameter_property ENABLE_JTAG_IO_SELECTION HDL_PARAMETER true
# Disabling JTAG IO switching for 17.0+ Quartus Pro
set_parameter_property ENABLE_JTAG_IO_SELECTION VISIBLE false

add_parameter CONNECTED_TO_JTAG_ATOM BOOLEAN
set_parameter_property CONNECTED_TO_JTAG_ATOM DEFAULT_VALUE false
set_parameter_property CONNECTED_TO_JTAG_ATOM DISPLAY_HINT BOOLEAN
set_parameter_property CONNECTED_TO_JTAG_ATOM VISIBLE false
set_parameter_property CONNECTED_TO_JTAG_ATOM HDL_PARAMETER false

add_parameter NEGEDGE_TDO_LATCH INTEGER 1
set_parameter_property NEGEDGE_TDO_LATCH VISIBLE false
set_parameter_property NEGEDGE_TDO_LATCH DERIVED true
set_parameter_property NEGEDGE_TDO_LATCH HDL_PARAMETER true

proc do_elaboration {} {
    set is_a10_or_c10gx [check_device_family_equivalence [get_parameter_value device_family] {"Arria 10" "Cyclone 10 GX"}]
    set atom_has_internal_tdo_negedge_latch [expr {!$is_a10_or_c10gx}]

    # This is relevant to Stratix 10, Agilex, and likely future families which have a negative-edge latch on TDO within their JTAG Atom
    set_parameter_property CONNECTED_TO_JTAG_ATOM VISIBLE $atom_has_internal_tdo_negedge_latch
    
    # For families which *do* latch TDO on the negative-edge internally within their JTAG Atom, we need to know if
    # the user is connecting this SCJIO to said JTAG Atom or not.  If they are *not* connecting to the JTAG Atom, then
    # the JTAG Hub should latch TDO, otherwise the JTAG Atom will handle the latching.
    if {$atom_has_internal_tdo_negedge_latch} {
        if {[get_parameter_value CONNECTED_TO_JTAG_ATOM]} {
            set_parameter_value NEGEDGE_TDO_LATCH 0
        } else {
            set_parameter_value NEGEDGE_TDO_LATCH 1
        }
    } else {
        # For families which *don't* latch TDO on the negative-edge internally within their JTAG Atom, we want the latch in the JTAG Hub
        set_parameter_value NEGEDGE_TDO_LATCH 1
    }

    # 
    # connection point jtag
    # 
    add_interface jtag conduit end
    set_interface_property JTAG associatedClock tck
    add_interface_port jtag tms tms Input 1
    add_interface_port jtag tdi tdi Input 1     
    add_interface_port jtag tdo tdo Output 1

    # 
    # connection point tck
    # 
    add_interface tck clock end
    set_interface_property tck clockRate 0
    set_interface_property tck ENABLED true
    add_interface_port tck tck clk Input 1
    
    #
    # connection point select_this
    #
    add_interface select_this conduit end
    add_interface_port select_this select_this select_this Input 1
    
    if {![get_parameter_value ENABLE_JTAG_IO_SELECTION]} {
        set_port_property select_this termination true
    } 
}

## Add documentation links for user guide and/or release notes
add_documentation_link "User Guide" "https://www.intel.com/content/www/us/en/programmable/quartushelp/current/index.htm#hdl/mega/mega_file_softcore_jtag_io.htm"
add_documentation_link "Release Notes" https://documentation.altera.com/#/link/hco1421698042087/hco1421698013408

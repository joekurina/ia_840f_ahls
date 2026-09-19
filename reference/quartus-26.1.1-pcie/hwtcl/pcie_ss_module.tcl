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


package provide intel_pcie_ss_axi::module 19.1

package require alt_xcvr::ip_tcl::ip_module
package require intel_pcie_ss_axi::parameters
package require intel_pcie_ss_axi::interfaces
package require intel_pcie_ss_axi::fileset

namespace eval ::intel_pcie_ss_axi::module:: {
    namespace import ::alt_xcvr::ip_tcl::ip_module::*

    namespace export \
    declare_module

    # Internal variables
    # TODO Link to user guide PDF needs to be updated
    variable module {\
        { NAME         VERSION       SUPPORTED_DEVICE_FAMILIES           SUPPORTED_DIE_TYPES            INTERNAL        EDITABLE        ELABORATION_CALLBACK               PARAMETER_UPGRADE_CALLBACK          DISPLAY_NAME                   GROUP              AUTHOR                  DESCRIPTION     DATASHEET_URL       DESCRIPTION                HIDE_FROM_QSYS      HIDE_FROM_QUARTUS       }\
        { intel_pcie_ss_axi      "5.0.0"       {"Agilex"}                         {"HSSI_WHR" "HSSI_RNR" "HSSI_GDR" "MAIN_*"}           false           false           ::intel_pcie_ss_axi::module::elaborate       ::intel_pcie_ss_axi::parameters::upgrade      "AXI Streaming IP for PCI Express"        "Interface Protocols/PCI Express"       "Altera Corporation"     NOVAL           NOVAL               "AXI Streaming IP for PCI Express"    false               false                   }\
    }
}

proc ::intel_pcie_ss_axi::module::declare_module {} {
    variable module
    ip_declare_module $module

    ::intel_pcie_ss_axi::parameters::declare_parameters
    ::intel_pcie_ss_axi::fileset::declare_filesets
    ::intel_pcie_ss_axi::interfaces::declare_interfaces
}


proc ::intel_pcie_ss_axi::module::elaborate {} {

    ::intel_pcie_ss_axi::parameters::validate
	::intel_pcie_ss_axi::parameters::setup_testbench
	#::intel_pcie_ss_axi::parameters::select_design_example
    ::intel_pcie_ss_axi::interfaces::elaborate
    ::intel_pcie_ss_axi::fileset::add_qhip_ptile


}


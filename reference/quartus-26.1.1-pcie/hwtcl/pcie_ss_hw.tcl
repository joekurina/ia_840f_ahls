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


lappend auto_path $env(QUARTUS_ROOTDIR)/../ip/altera/alt_xcvr/alt_xcvr_tcl_packages
package require -exact qsys 23.2
package require -exact alt_xcvr::ip_tcl::ip_module 13.0
package require alt_xcvr::ip_tcl::messages
namespace import ::alt_xcvr::ip_tcl::ip_module::*
namespace import ::alt_xcvr::ip_tcl::messages::*

source [file join $env(QUARTUS_BINDIR) .. common tcl packages lampas_iptcl lampas.tcl]
package require ::quartus::lampas_iptcl 

source pcie_ss_parameters.tcl
source pcie_ss_interfaces.tcl
source pcie_ss_ed.tcl 
source pcie_ss_fileset.tcl
source pcie_ss_module.tcl
source $env(QUARTUS_ROOTDIR)/../ip/altera/subsystems/intel_pcie_ss_axi/hwtcl/mif/generate_MIF.tcl
set_module_property OUTDATED_IP_FILE {intel_pcie_ss_axi.odip}

package require intel_pcie_ss_axi::module

::intel_pcie_ss_axi:::module::declare_module

add_documentation_link "User Guide" https://docs.altera.com/r/docs/790711/current
add_documentation_link "Release Notes" https://docs.altera.com/r/docs/815304/current/axi-streaming-intel-fpga-ip-for-pci-express-ip-core-release-notes

#add_documentation_link "Intel P-Tile Avalon-ST for PCI Express User Guide" https://docs.altera.com/r/docs/683059/current

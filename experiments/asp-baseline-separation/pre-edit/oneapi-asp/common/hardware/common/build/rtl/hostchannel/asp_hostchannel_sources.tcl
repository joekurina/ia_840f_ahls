# SPDX-License-Identifier: MIT
# Definitions only: this does not advertise a compiler channel or enable an
# unbound top-level instance. Paths follow asp_design_files.tcl's build CWD.
set_global_assignment -name SYSTEMVERILOG_FILE "rtl/hostchannel/asp_hostchannel_pkg.sv"
set_global_assignment -name SYSTEMVERILOG_FILE "rtl/hostchannel/asp_hostchannel_fifo.sv"
set_global_assignment -name SYSTEMVERILOG_FILE "rtl/hostchannel/asp_hostchannel_engine.sv"
set_global_assignment -name SYSTEMVERILOG_FILE "rtl/hostchannel/asp_hostchannel_share.sv"
set_global_assignment -name SYSTEMVERILOG_FILE "rtl/hostchannel/asp_hostchannel_integration.sv"

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


# Relax timing for the async reset signal going into the reset synchronizer
# See RTL for the justification of setup=4 and hold=3
set tmp "reset_ctrl_impl|reset_n_sync_inst|*"
set tmp_pin [get_pins -nowarn [list "${tmp}|clrn"]]
set_multicycle_path -through $tmp_pin -to $tmp -setup 4 -end
set_multicycle_path -through $tmp_pin -to $tmp -hold  3 -end

# Relax timing for signal going into the app_ss_rst_req synchronizer
# setup=7 and hold=6 are somewhat arbitrary choices
set tmp "reset_ctrl_impl|app_ss_rst_req_sync_inst|din_s1"
set tmp_pin [get_pins -nowarn [list "${tmp}|d" "${tmp}|*data"]]
set_multicycle_path -through $tmp_pin -to $tmp -setup 7 -end
set_multicycle_path -through $tmp_pin -to $tmp -hold  6 -end

# Relax timing for signal going into the app_ss_cold_rst_n synchronizer
# setup=7 and hold=6 are somewhat arbitrary choices
set tmp "reset_ctrl_impl|app_ss_cold_rst_n_sync_inst|din_s1"
set tmp_pin [get_pins -nowarn [list "${tmp}|d" "${tmp}|*data"]]
set_multicycle_path -through $tmp_pin -to $tmp -setup 7 -end
set_multicycle_path -through $tmp_pin -to $tmp -hold  6 -end

# Relax timing for signal going into the local_reset_done synchronizer
# setup=7 and hold=6 are somewhat arbitrary choices
set tmp "reset_ctrl_impl|fm_emif[*].local_reset_done_sync_inst|din_s1"
set tmp_pin [get_pins -nowarn [list "${tmp}|d" "${tmp}|*data"]]
if {[get_collection_size $tmp_pin] > 0} {
   set_multicycle_path -through $tmp_pin -to $tmp -setup 7 -end
   set_multicycle_path -through $tmp_pin -to $tmp -hold  6 -end
}

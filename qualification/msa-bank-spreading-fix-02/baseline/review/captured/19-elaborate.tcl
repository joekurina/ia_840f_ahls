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


proc ::mem_ss_pkg::ip_msa::validate {} {
   table set parameters -> DEVICE_FAMILY -> VALUE [table get parameters -> SYSINFO_DEVICE_FAMILY -> VALUE]

   if {[table get parameters -> NUM_COPIES -> VALUE] > 1 && [table get parameters -> NUM_BANK_FIFOS -> VALUE] > 0} {
      send_message error "Write copies and bank spreading cannot be simultaneously enabled"
   }

   set legal_data_widths [list]
   set init_wr_data_width [table get parameters -> INIT_WR_DATA_WIDTH -> VALUE]
   for {set data_width $init_wr_data_width} {$data_width <= 1024} {set data_width [expr {$data_width * 2}]} {
      derive_xdata_xuser_widths $data_width xdata_width use_xuser xuser_width
      if {!$use_xuser || $xuser_width <= 64} {
         lappend legal_data_widths $data_width
      }
   }
   if {[llength $legal_data_widths] == 0} {
      send_message error "Internal Error: Failed to derive legal values for RESP_WR_DATA_WIDTH from INIT_WR_DATA_WIDTH=$init_wr_data_width"
   }
   table set parameters -> RESP_WR_DATA_WIDTH -> ALLOWED_RANGES $legal_data_widths

   set legal_data_widths [list]
   set init_rd_data_width [table get parameters -> INIT_RD_DATA_WIDTH -> VALUE]
   for {set data_width $init_rd_data_width} {$data_width <= 1024} {set data_width [expr {$data_width * 2}]} {
      derive_xdata_xuser_widths $data_width xdata_width use_xuser xuser_width
      if {!$use_xuser || $xuser_width <= 64} {
         lappend legal_data_widths $data_width
      }
   }
   if {[llength $legal_data_widths] == 0} {
      send_message error "Internal Error: Failed to derive legal values for RESP_RD_DATA_WIDTH from INIT_RD_DATA_WIDTH=$init_rd_data_width"
   }
   table set parameters -> RESP_RD_DATA_WIDTH -> ALLOWED_RANGES $legal_data_widths
}

proc ::mem_ss_pkg::ip_msa::elaborate {} {

   table set parameters -> RESP_ID_WIDTH -> VALUE [table get parameters -> INIT_ID_WIDTH -> VALUE]


   set init_wr_data_width [table get parameters -> INIT_WR_DATA_WIDTH -> VALUE]
   set init_rd_data_width [table get parameters -> INIT_RD_DATA_WIDTH -> VALUE]
   set resp_wr_data_width [table get parameters -> RESP_WR_DATA_WIDTH -> VALUE]
   set resp_rd_data_width [table get parameters -> RESP_RD_DATA_WIDTH -> VALUE]
   set num_copies         [table get parameters -> NUM_COPIES         -> VALUE]

   set resp_awaddr_width [table get parameters -> INIT_AWADDR_WIDTH -> VALUE]
   set resp_araddr_width [table get parameters -> INIT_ARADDR_WIDTH -> VALUE]
   if {[table get parameters -> INIT_BUS_PROTOCOL -> VALUE] == "AVMM" && ![is_pow_2 $init_wr_data_width]} {
      set  bits [expr {log($init_wr_data_width / 8)/log(2)}]
      incr resp_awaddr_width [expr {int(floor($bits) - ceil($bits))}]
      set  resp_araddr_width $resp_awaddr_width
   }
   incr resp_awaddr_width [expr {-1 * int(ceil([log2 $num_copies]))}]
   incr resp_araddr_width [expr {-1 * int(ceil([log2 $num_copies]))}]

   table set parameters -> RESP_AWADDR_WIDTH -> VALUE $resp_awaddr_width
   table set parameters -> RESP_ARADDR_WIDTH -> VALUE $resp_araddr_width


   if {[table get parameters -> INIT_BUS_PROTOCOL -> VALUE] == "AVMM"} {
      table set parameters -> INIT_WDATA_WIDTH -> VALUE $init_wr_data_width

      table set parameters -> INIT_RDATA_WIDTH -> VALUE $init_rd_data_width
   } else {
      derive_xdata_xuser_widths $init_wr_data_width xdata_width use_xuser xuser_width
      table set parameters -> INIT_WDATA_WIDTH -> VALUE $xdata_width
      table set parameters -> INIT_USE_WUSER   -> VALUE $use_xuser
      table set parameters -> INIT_WUSER_WIDTH -> VALUE $xuser_width

      derive_xdata_xuser_widths $init_rd_data_width xdata_width use_xuser xuser_width
      table set parameters -> INIT_RDATA_WIDTH -> VALUE $xdata_width
      table set parameters -> INIT_USE_RUSER   -> VALUE $use_xuser
      table set parameters -> INIT_RUSER_WIDTH -> VALUE $xuser_width
   }


   derive_xdata_xuser_widths [table get parameters -> RESP_WR_DATA_WIDTH -> VALUE] wdata_width use_wuser wuser_width
   table set parameters -> RESP_WDATA_WIDTH -> VALUE $wdata_width
   table set parameters -> RESP_USE_WUSER   -> VALUE $use_wuser
   table set parameters -> RESP_WUSER_WIDTH -> VALUE $wuser_width

   derive_xdata_xuser_widths [table get parameters -> RESP_RD_DATA_WIDTH -> VALUE] rdata_width use_ruser ruser_width
   table set parameters -> RESP_RDATA_WIDTH -> VALUE $rdata_width
   table set parameters -> RESP_USE_RUSER   -> VALUE $use_ruser
   table set parameters -> RESP_RUSER_WIDTH -> VALUE $ruser_width

   table set ports -> s_axi4:s_axi4_wuser -> TERMINATION [expr {!$use_wuser}]
   table set ports -> s_axi4:s_axi4_ruser -> TERMINATION [expr {!$use_ruser}]
}

proc ::mem_ss_pkg::ip_msa::derive_xdata_xuser_widths {data_width xdata_width_ use_xuser_ xuser_width_} {
   upvar $xdata_width_  xdata_width
   upvar $use_xuser_    use_xuser
   upvar $xuser_width_  xuser_width

   if {[is_pow_2 $data_width]} {
      set use_xuser   0
      set xuser_width 1
      set xdata_width $data_width
   } else {
      set use_xuser   1
      set pow2        [expr {int(pow(2, floor(log($data_width)/log(2))))}]
      set xuser_width [expr {$data_width - $pow2}]
      set xdata_width $pow2
   }
}


/*********************************************************************
*                                                                    *
*  JTAG Bridge Between Two SLD JTAG Hubs In Multiple Parititions     *
*                                                                    *
*  sld_jtag_bridge_host is instantiated in the child partition;      *
*  sld_jtag_bridge_agent is instantiated in the parent partition.    *
*  sld_jtag_bridge_agent connects to sld_jtag_bridge_host, one pair  *
*  for each parent and child SLD JTAG hubs.                          *
*                                                                    *
--  Copyright (C) 2025  Altera Corporation. All rights reserved.
*                                                                    *
*  Your use of Altera Corporation's design tools, logic functions    *
*  and other software and tools, and its AMPP partner logic          *
*  functions, and any output files from any of the foregoing         *
*  (including device programming or simulation files), and any       *
*  associated documentation or information are expressly subject     *
*  to the terms and conditions of the Altera Program License         *
*  Subscription Agreement, Intel FPGA IP License          *
*  Agreement, or other applicable license agreement, including,      *
*  without limitation, that your use is for the sole purpose of      *
*  programming logic devices manufactured by Altera and sold by      *
*  Altera or its authorized distributors.  Please refer to the       *
*  applicable agreement for further details.                         *
*                                                                    *
--  25.1.0 Build 129 03/26/2025 SC Pro Edition
*                                                                    *
*                                                                    *
*********************************************************************/

module sld_jtag_bridge_host #(
    parameter NAME = " "
)(
    // Signals to be connected to sld_jtag_bridge_agent instantiated in the parent partition
    input tck,
    input tms,
    input tdi,
    input ena,
    input vir_tdi,
    output tdo
);

    altera_sld_host_endpoint 
    #(
        .BRIDGE_HOST(1),
        .NEGEDGE_TDO_LATCH(0),
        .NAME(NAME)
    )
    sld_host_ep_inst
    (
        .tck(tck),
        .tms(tms),
        .tdi(tdi),
        .ena(ena),
        .vir_tdi(vir_tdi),
        .tdo(tdo)
    );

endmodule


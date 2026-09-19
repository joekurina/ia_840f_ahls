// Copyright (C) 2024 Intel Corporation.
// SPDX-License-Identifier: MIT

//
// External pins passed to the PCIe IP. By wrapping pins in an interface,
// tile-specific pins can be added to the container without having to change
// the top-level module of every board.
//
// Most wires in the interface are package pins. Wires from other IP may also
// be added, such as reset controllers instantiated at the top level.
//

`include "ofs_ip_cfg_db.vh"

interface ofs_fim_pcie_ss_pins_if #(
    parameter PCIE_LANES = ofs_fim_cfg_pkg::PCIE_LANES
    );

    logic refclk0_p;
    logic refclk1_p;
    logic in_perst_n;

    // GTS reset sequencer -- up to 2 wires connected to i_flux_clk in PCIe IP
    logic [1:0] in_flux_clk;

    logic [PCIE_LANES-1:0] rx_p;
    logic [PCIE_LANES-1:0] rx_n;
    logic [PCIE_LANES-1:0] tx_p;
    logic [PCIE_LANES-1:0] tx_n;

    modport top (
        output refclk0_p, refclk1_p,
        output in_perst_n,
        output in_flux_clk,
        output rx_p, rx_n,
        input  tx_p, tx_n
        );

    modport pcie_ss (
        input  refclk0_p, refclk1_p,
        input  in_perst_n,
        input  in_flux_clk,
        input  rx_p, rx_n,
        output tx_p, tx_n
        );

endinterface // ofs_fim_pcie_ss_pins_if

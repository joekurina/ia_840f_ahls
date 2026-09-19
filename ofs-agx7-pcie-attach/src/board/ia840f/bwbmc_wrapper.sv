//--------------------------------------------------------------------------------
//-- Copyright (c) 2023 by BittWare, A Molex Company
//--
//-- Permission is hereby granted, free of charge, to any person obtaining a copy
//-- of this software and associated documentation files (the "Software"), to deal
//-- in the Software without restriction, including without limitation the rights
//-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//-- copies of the Software, and to permit persons to whom the Software is
//-- furnished to do so, subject to the following conditions:
//--
//-- The above copyright notice and this permission notice shall be included in all
//-- copies or substantial portions of the Software.
//--
//-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//-- SOFTWARE.
//--------------------------------------------------------------------------------
//--      UNCLASSIFIED - FOR OFFICIAL USE ONLY
//--------------------------------------------------------------------------------
//-- Title       : IA-840F BittWare BMC Wrapper
//-- Project     : IA-840F OFS Support
//--------------------------------------------------------------------------------
//-- Description : This is the top level of the BittWare IA-840F BMC subsystem.
//--               It has been wrapped for integration into OFS.
//--------------------------------------------------------------------------------
//-- Known Issues and Omissions:
//--
//--
//--
//--------------------------------------------------------------------------------


`include "fpga_defines.vh"

module bwbmc_wrapper  # (
)
(
  // AXI clock and reset
  input wire  clk_csr,
  input wire  reset_csr_n,
  // AXI lite slave CSR interface from host
  ofs_fim_axi_lite_if.slave csr_lite_slv_if,

  // BittWare BMC related ports for SPI comms to MAX10 BMC
  // Note that the BMC is SPI master only in this implementation.
  input wire  fpga_max_mosi,
  input wire  fpga_spi_cs,
  input wire  fpga_max_sclk,
  inout wire  fpga_max_miso,
  output wire pcie_irq,
  output wire bmc_irq,
  output wire bmc_mst_en_n
 );

wire  [2:0] slv_awsize;
wire  [2:0] slv_arsize;

assign slv_awsize   = ( &csr_lite_slv_if.wstrb )        ?   3'b011 :    // 8-byte
                                                            3'b010;     // 4-byte

assign slv_arsize   = ( csr_lite_slv_if.araddr[2] )     ?   3'b010 :    // 4-byte
                                                            3'b011;     // 8-byte
wire     reset_csr;

// The folling signal needs driven low to indicate to the external max10 BMC on the BittWare card that the supported BMC
// SPI subsystem IP is present in the design
assign bmc_mst_en_n = 1'b0;


// Invert the active low reset input that is passed to the qsys based instance for 840 support subsystem.
assign reset_csr = ~reset_csr_n;

   // Instantiate the qsys based BittWare 840 BMC subsystem. Note this subsystem is a
   // modified version of the one used in Cardtest design to add an AXI interface to the
   // address space instead of Avalon-MM.
   bw_840_support #(
   ) bw_840_support (
      .axi_s_bw_awid                                           (8'b0), //   input,   width = 8,  axi_s_bw.awid
      .axi_s_bw_awaddr                                         (csr_lite_slv_if.awaddr), //   input,  width = 17,          .awaddr
      .axi_s_bw_awlen                                          (8'b0), //   input,   width = 8,          .awlen
      .axi_s_bw_awsize                                         (slv_awsize), //   input,   width = 3,          .awsize
      .axi_s_bw_awburst                                        (2'b0), //   input,   width = 2,          .awburst
      .axi_s_bw_awprot                                         (csr_lite_slv_if.awprot), //   input,   width = 3,          .awprot
      .axi_s_bw_awvalid                                        (csr_lite_slv_if.awvalid), //   input,   width = 1,          .awvalid
      .axi_s_bw_awready                                        (csr_lite_slv_if.awready), //  output,   width = 1,          .awready
      .axi_s_bw_wdata                                          (csr_lite_slv_if.wdata), //   input,  width = 64,          .wdata
      .axi_s_bw_wstrb                                          (csr_lite_slv_if.wstrb), //   input,   width = 8,          .wstrb
      .axi_s_bw_wvalid                                         (csr_lite_slv_if.wvalid), //   input,   width = 1,          .wvalid
      .axi_s_bw_wready                                         (csr_lite_slv_if.wready), //  output,   width = 1,          .wready
      .axi_s_bw_bid                                            (                      ), //  output,   width = 8,          .bid
      .axi_s_bw_bresp                                          (csr_lite_slv_if.bresp), //  output,   width = 2,          .bresp
      .axi_s_bw_bvalid                                         (csr_lite_slv_if.bvalid), //  output,   width = 1,          .bvalid
      .axi_s_bw_bready                                         (csr_lite_slv_if.bready), //   input,   width = 1,          .bready
      .axi_s_bw_arid                                           (8'b0), //   input,   width = 8,          .arid
      .axi_s_bw_araddr                                         (csr_lite_slv_if.araddr), //   input,  width = 17,          .araddr
      .axi_s_bw_arlen                                          (8'b0), //   input,   width = 8,          .arlen
      .axi_s_bw_arsize                                         (slv_arsize), //   input,   width = 3,          .arsize
      .axi_s_bw_arburst                                        (2'b0), //   input,   width = 2,          .arburst
      .axi_s_bw_arprot                                         (csr_lite_slv_if.arprot), //   input,   width = 3,          .arprot
      .axi_s_bw_arvalid                                        (csr_lite_slv_if.arvalid), //   input,   width = 1,          .arvalid
      .axi_s_bw_arready                                        (csr_lite_slv_if.arready), //  output,   width = 1,          .arready
      .axi_s_bw_rid                                            (                       ), //  output,   width = 8,          .rid
      .axi_s_bw_rdata                                          (csr_lite_slv_if.rdata), //  output,  width = 64,          .rdata
      .axi_s_bw_rresp                                          (csr_lite_slv_if.rresp), //  output,   width = 2,          .rresp
      .axi_s_bw_rlast                                          (                     ), //  output,   width = 1,          .rlast
      .axi_s_bw_rvalid                                         (csr_lite_slv_if.rvalid), //  output,   width = 1,          .rvalid
      .axi_s_bw_rready                                         (csr_lite_slv_if.rready), //   input,   width = 1,          .rready
      .bmc_spi_mosi_to_the_spislave_inst_for_spichain          (fpga_max_mosi), //   input,   width = 1,   bmc_spi.mosi_to_the_spislave_inst_for_spichain
      .bmc_spi_nss_to_the_spislave_inst_for_spichain           (fpga_spi_cs), //   input,   width = 1,          .nss_to_the_spislave_inst_for_spichain
      .bmc_spi_sclk_to_the_spislave_inst_for_spichain          (fpga_max_sclk), //   input,   width = 1,          .sclk_to_the_spislave_inst_for_spichain
      .bmc_spi_miso_to_and_from_the_spislave_inst_for_spichain (fpga_max_miso), //   inout,   width = 1,          .miso_to_and_from_the_spislave_inst_for_spichain
      .pcie_irq_irq                                            (pcie_irq),                                            //  output,   width = 1,  pcie_irq.irq
      .bmc_irq_irq                                             (bmc_irq),                                             //  output,   width = 1,   bmc_irq.irq
      .sdm_reset_reset                                         (reset_csr),                                         //   input,   width = 1, sdm_reset.reset
      .sysclk_clk                                              (clk_csr),                                              //   input,   width = 1,    sysclk.clk
      .sysrst_reset                                            (reset_csr)                                             //   input,   width = 1,    sysrst.reset
   );

endmodule

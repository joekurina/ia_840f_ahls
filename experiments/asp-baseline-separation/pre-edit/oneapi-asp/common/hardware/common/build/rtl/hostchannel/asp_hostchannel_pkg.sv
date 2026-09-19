// SPDX-License-Identifier: MIT
package asp_hostchannel_pkg;
    localparam logic [63:0] ABI_IDENT = 64'h4941383448430001;
    localparam logic [63:0] MMIO_BASE = 64'h30000;
    localparam logic [63:0] MMIO_SPAN = 64'h1000;
    localparam int SLOT_STRIDE = 'h100;
    localparam int ELEMENT_BYTES = 64;
    localparam int CSR_IDENT = 'h00, CSR_CONTROL = 'h08, CSR_STATUS = 'h10,
                   CSR_RING_IOVA = 'h18, CSR_RING_BYTES = 'h20,
                   CSR_HOST_POSITION = 'h28, CSR_DEVICE_POSITION = 'h30,
                   CSR_ERROR = 'h38, CSR_ELEMENT_BYTES = 'h40;
    localparam logic [63:0] ERR_CSR = 64'h1, ERR_CONFIG = 64'h2,
        ERR_POSITION = 64'h4, ERR_RESPONSE = 64'h8, ERR_PROTOCOL = 64'h10;
endpackage

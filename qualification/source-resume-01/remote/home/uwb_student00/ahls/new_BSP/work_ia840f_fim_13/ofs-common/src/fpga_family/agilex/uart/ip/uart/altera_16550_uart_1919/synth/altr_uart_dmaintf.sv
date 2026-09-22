// (C) 2001-2026 Altera Corporation. All rights reserved.
// Your use of Altera Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files from any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License Subscription 
// Agreement, Altera IP License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


//
// DMAINTF
// Contains DMA controller interface
//
`timescale 1 ps / 1 ps
module altr_uart_dmaintf #(
    parameter ASIZE = 4,
    parameter DMA_EXTRA = 1
) (
   //Clock and Reset
   input  clk,
   input  rst_n,

   //Global FIFO enable
   input glb_fifoe,
   
   input glb_tx_low_en,

   // CSR signal
   input fcr_dmam,		//DMA mode. 0 for single DMA transfer mode; 1 for multiple DMA transfer mode 

   //TXSTOR control interface
   //input txstor_empty,
   input txfifo_full,
   input txfifo_empty,
   input thr_empty,
   input txfifo_rst,
   input [ASIZE:0] txfifo_navail,

   //RXSTOR control interface
   input rxfifo_empty,
   input rb_empty,
   input rxfifo_high_watermark,
   input rxstor_rxdata_avail,
   input lsr_dr,
   input rxfifo_rst,

   //Global TX Low Watermark 
   input [ASIZE:0] glb_tx_low_value,

   //Character Timeout Indication (Controlled by IER[0])
   input  rxstor_char_timeout,

   //DMA ACK signals 
   input                       dma_tx_ack_n,
   input                       dma_rx_ack_n,

   //DMA request and single 
   output reg                  dma_tx_req_n,
   output reg                  dma_rx_req_n,
   output reg                  dma_tx_single_n,
   output reg                  dma_rx_single_n
);

reg                     dma_tx_req_nxt_n;
reg                     dma_rx_req_nxt_n;
reg                     dma_tx_single_nxt_n;
reg                     dma_rx_single_nxt_n;
reg			dma_tx_ack_doublesync_a_n;
reg			dma_rx_ack_doublesync_a_n;
reg			dma_tx_ack_synced_n;
reg			dma_rx_ack_synced_n;

wire                    dma_mode0_rx_req;
wire                    dma_mode1_rx_req;
wire			dma_extra_rx_req;
wire                    tx_req;
wire                    rx_req;
wire                    clear_tx_req;
wire                    clear_rx_req;


//double syn flops for ack signals to avoid metastability 
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        dma_tx_ack_doublesync_a_n <= 1'b1;
        dma_rx_ack_doublesync_a_n <= 1'b1;
        dma_tx_ack_synced_n       <= 1'b1;
        dma_rx_ack_synced_n       <= 1'b1;	
    end
    else begin
        dma_tx_ack_doublesync_a_n <= dma_tx_ack_n;
        dma_tx_ack_synced_n       <= dma_tx_ack_doublesync_a_n;
        dma_rx_ack_doublesync_a_n <= dma_rx_ack_n;
        dma_rx_ack_synced_n       <= dma_rx_ack_doublesync_a_n;
    end
end


//DMA request and clear req signals for DMA mode0; mode1 and additional DMA interface (DMA extra).
assign dma_mode0_rx_req = lsr_dr;
assign dma_mode1_rx_req = rxfifo_high_watermark | rxstor_char_timeout;
assign dma_extra_rx_req = rxstor_rxdata_avail;

assign tx_req           = glb_fifoe ? (glb_tx_low_en ? (txfifo_navail <= glb_tx_low_value) : txfifo_empty) : thr_empty; 
		
assign clear_tx_req     = (DMA_EXTRA == 1) ? ~dma_tx_ack_synced_n :
                           (fcr_dmam == 1) ? txfifo_full : ~tx_req;

assign rx_req           = (DMA_EXTRA == 1) ? dma_extra_rx_req :
                           (fcr_dmam == 1) ? dma_mode1_rx_req : dma_mode0_rx_req;

assign clear_rx_req     = (DMA_EXTRA == 1) ? ~dma_rx_ack_synced_n :
			  (glb_fifoe) ? rxfifo_empty : rb_empty;


// DMA TX REQ
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        dma_tx_req_n  <= 1'b1;
    else
        dma_tx_req_n  <= dma_tx_req_nxt_n;
end

always_comb begin
    if (clear_tx_req | txfifo_rst)
        dma_tx_req_nxt_n = 1'b1;
    else if (tx_req)
        dma_tx_req_nxt_n = 1'b0;
    else
        dma_tx_req_nxt_n = dma_tx_req_n;
end


// DMA RX REQ
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        dma_rx_req_n  <= 1'b1;
    else
        dma_rx_req_n  <= dma_rx_req_nxt_n;
end

always_comb begin
    if (clear_rx_req | rxfifo_rst)
        dma_rx_req_nxt_n = 1'b1;
    else if (rx_req)
        dma_rx_req_nxt_n = 1'b0;
    else
        dma_rx_req_nxt_n = dma_rx_req_n;
end


// DMA single signals (single data transfer). Single signals are additional DMA signals which only available when parameter DMA_EXTRA==1
// DMA single ports will be left unconnected when parameter DMA_EXTRA==0
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        dma_tx_single_n  <= 1'b1;
    else
        dma_tx_single_n  <= dma_tx_single_nxt_n;
end

always_comb begin
    if (~dma_tx_ack_synced_n | txfifo_rst)       //to clear or de-assert dma_tx_single_n
        dma_tx_single_nxt_n = 1'b1;
    else if (~txfifo_full | thr_empty)          //to set or assert dma_tx_single_n. Fixed for FB 124826 by adding thr_empty in condition
        dma_tx_single_nxt_n = 1'b0;
    else
        dma_tx_single_nxt_n = dma_tx_single_n;
end


// DMA RX Single status
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        dma_rx_single_n  <= 1'b1;
    else
        dma_rx_single_n  <= dma_rx_single_nxt_n;
end

always_comb begin
    if (~dma_rx_ack_synced_n | rxfifo_rst)        //to clear or de-assert dma_rx_single_n
        dma_rx_single_nxt_n = 1'b1;
    else if (~rxfifo_empty | ~rb_empty)          //to set or assert dma_rx_single_n. Fixed for FB 124826 by adding ~rb_empty in condition
        dma_rx_single_nxt_n = 1'b0;
    else
        dma_rx_single_nxt_n = dma_rx_single_n;
end

endmodule: altr_uart_dmaintf 

`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "AKY/VDqroC56S5zYqI2FH+pDtMm2XXjvzWe8rGJiybS03yo4KNBMg81pmtWbHVIPiTA81zIuGQJqb5vOIzimr/z+D85S4Jjtk9u3+kDOlkJUsrbYjDeARoR1d2Gy20nZHckh8FGW+dSF0ir+jochMyts2Y//A4WlmCaB7gD83g5rkI4jT1ldDhtPnUUhGKawcEehCEezQ12Toa+YG3kf1PWegnVnp6lxL1nZ0P1Qzo/Hi+EOyOol40uF2LGXffGBpaDEAlJ3G9Kl/SfQTTi1JGPxtcpfJ49ShKgsWAV8vmLAbT0Zg8yU2TCpsAuQbc4wYfoLZcnn/woSZ4oCCnpowK5CAjLCopTElmvMu8/lBLpNYkpXlLnRTpzzTNj96JQgfXxRN6DInhdKzsz+MG4ceCkWTV+YEGVFqXynWfX8kvcgKayScfoOpt+D7SY1g3Ubo8wcGS9trSC4OxJ7k5Aj0d9ftKGkXaq5r9YIN6j9/ryTsPc1X2+cWxk5Fw155a/7eln6qPPMQDqaMJtss5vpXxGlEbPUYTMFv0tU4rv9Zj7CFElSzxp7h9XswYfoyX0lknavPeT0yUMj/pilye89dNSR1SMTludk9+Z2STUIIpVGgFF1KkwtPM1hf6BFA7Fumo15Rzl7g6QRGgH+BgKwCc72TPmaMA172oVO8qbe2eHMheZxK2NLgwX91cDI0ayErFx109etvyHje0YvIYi+wTJbkM7f/N8alMyvuyPAUVhugunSlS4WpJcS6XmVUqs/GIZadRccGivbWNFGW2y+xF41BLI+l8cC/vUmUJcpX6g6YOGqLiTNcgkFApugAQvofdYkSKp8od8aOQRuih99DUfyq/lHXSvzufghkTgUswUK3S7KV85BGab5s2iLznApAMokxVNEhyvxgB4zlnpL5+cKSBP4ON/9tRcumV1MVI0QJDIuTLmV+Kqln823IwR4ZkJxs8NKG8IC3/TB+P+j91wwZYh6NCh8n8FuOBDa8J3oW1ZJ11k7mQb1I5GtWI0Q"
`endif
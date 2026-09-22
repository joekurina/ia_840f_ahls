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
//Receive Storage Block
//Contains both the FIFO and non-FIFO storage elements
//
`timescale 1 ps / 1 ps
module altr_uart_rxstor #(
   parameter FIFO_MODE = 1,
   parameter FIFO_DEPTH = 32,
   parameter FIFO_WATERMARK = 0,
   parameter ACTUAL_DSIZE = 8,
   parameter EXPAND_DSIZE = 11,
   parameter ASIZE = 4,
   parameter PARITY_ERROR  = 10,
   parameter FRAME_ERROR   = 9,
   parameter BREAK         = 8,
   parameter MEM_BLOCK_TYPE = "AUTO",
   parameter FAMILY = "ARRIA V"
) (
   //Clock and Reset
   input  clk,
   input  rst_n,
   input  baud_clken,

   //RBR_THR_DLL CSR interface
   output [ACTUAL_DSIZE-1:0] rbr_read_data,
   input  rbr_read_access,

   //Global FIFO Enable
   input  glb_fifoe,
   input  fcr_rfifor,
   input  glb_fifoe_c,

   //RXSTOR control interface
   input  rxstor_put,
   //output rxstor_full,
   //output rxfifo_full,
   output rxfifo_empty,
   output rb_empty,
   output rxfifo_rst,

   //RXSTOR Data Input
   input  [EXPAND_DSIZE-1:0] rxstor_data,

   //RX FIFO High/Low Watermark indications to TXFC
   output logic rxfifo_high_watermark,
   output logic rxfifo_low_watermark,

   //Data Ready Status (LSR[0])
   output lsr_dr,

   //Overrun Error Status (LSR[1])
   output lsr_oe_source,

   //Parity Error Status (LSR[2])
   output lsr_pe_source,

   //Framing Error Status (LSR[3])
   output lsr_fe_source,

   //Break Interrupt (LSR[4])
   output lsr_bi_source,

   //Receive FIFO Error Status (LSR[7])
   input  lsr_read_access,
   output lsr_rfe,

   //LSR mask clearing signal
   output lsr_error_mask_clr,

   //Receive Data Available Interrupt
   output rxstor_rxdata_avail,
   input  [1:0] fcr_rt,
   input  afr_rx_high_en,
   input  [8:0] rx_high_value,
   input  afr_rx_low_en,
   input  [8:0] rx_low_value,

   //Character Timeout Interrupt
   input  lcr_stop_l,
   input  lcr_pen_l,
   input  [2:0] lcr_dls_l,
   output rxstor_char_timeout

);

logic rxfifo_put, rb_put;
logic rxfifo_get, rb_get;
logic [ASIZE:0] rxfifo_navail;
logic [EXPAND_DSIZE-1:0] rxfifo_rdata, rb_rdata_r, rb_rdata;
logic rxfifo_full;

logic glb_rx_high_en;
logic glb_rx_low_en;
logic [ASIZE:0] rt_value, glb_rx_high_value;

logic clear_src, clear_src_nxt, clear_dst;
logic [3:0] bit_timer;
logic one_bit_time;
logic [5:0] char_cnt, char_cnt_nxt, char_timeout_val;

//FIFO reset should be triggered only when FIFOs are enabled
assign rxfifo_rst = (glb_fifoe & fcr_rfifor) | glb_fifoe_c;
//RXFIFO
generate
if (FIFO_MODE == 1) begin: gen_rxfifo
   altr_uart_fifo #(
      .DSIZE(EXPAND_DSIZE),
      .ASIZE(ASIZE),
	  .FIFO_DEPTH(FIFO_DEPTH),
	  .MEM_BLOCK_TYPE(MEM_BLOCK_TYPE),
      .FAMILY(FAMILY)
   ) rxfifo (
      .put(rxfifo_put),
      .get(rxfifo_get),
      .s_rst(rxfifo_rst),
      .full(rxfifo_full),
      .empty(rxfifo_empty),
      .navail(rxfifo_navail),
      .wdata(rxstor_data),
      .rdata(rxfifo_rdata),
      .*
   );
end
endgenerate

//RB
altr_uart_databuffer #(
   .DSIZE(EXPAND_DSIZE)
) rb (
   .s_rst(glb_fifoe_c),
   .put(rb_put),
   .get(rb_get),
   .empty(rb_empty),
   .wdata(rxstor_data),
   .rdata(rb_rdata),
   .*
);

//PUT Input Mux
assign rxfifo_put = rxstor_put &  glb_fifoe & ~rxfifo_full;
assign rb_put     = rxstor_put & ~glb_fifoe & 1'b1;

//Get Input Mux
assign rxfifo_get = rbr_read_access &  glb_fifoe & ~rxfifo_empty;
assign rb_get     = rbr_read_access & ~glb_fifoe & ~rb_empty;

//Full Output Mux - doesn't seem to be necessary
//assign rxstor_full = glb_fifoe ? rxfifo_full : ~rb_empty;

//Data Output Mux
//Bit-select is necessary as *_rdata is wider than 8 bits
always_ff @(posedge clk or negedge rst_n) begin
   if (!rst_n) 			rb_rdata_r <= 0;
   else 				rb_rdata_r <= rb_rdata;
end

assign rbr_read_data = glb_fifoe ? (rxfifo_rdata[ACTUAL_DSIZE-1:0]) : (rb_rdata_r[ACTUAL_DSIZE-1:0]);

//------------------------------------------------------------------------------
//Data Ready Status
//------------------------------------------------------------------------------
assign lsr_dr = glb_fifoe ? ~rxfifo_empty : ~rb_empty;

//------------------------------------------------------------------------------
//Receive Data Available Interrupt & RX High Watermark
//------------------------------------------------------------------------------

//Global RX HIGH Watermark Enable
assign glb_rx_high_en = afr_rx_high_en & (FIFO_WATERMARK == 1);

//Calculate watermark value set by FCR[7:6] RT
always_comb begin
   case(fcr_rt)
      2'b00: rt_value = 'd1;
      2'b01: rt_value = FIFO_DEPTH/4;
      2'b10: rt_value = FIFO_DEPTH/2;
      2'b11: rt_value = FIFO_DEPTH-2;
   endcase
end

//RX FIFO High Value
assign glb_rx_high_value = glb_rx_high_en ? rx_high_value[ASIZE:0] : rt_value;

//RX FIFO rxstor_rxdata_avail, Interrupt
assign rxfifo_high_watermark = rxfifo_navail >= glb_rx_high_value;

//Receive Data Available Interrupt
assign rxstor_rxdata_avail = glb_fifoe ? rxfifo_high_watermark : ~rb_empty;

//------------------------------------------------------------------------------
//Tx Flow Control - Low Watermark Value
//------------------------------------------------------------------------------

//Global RX LOW Watermark Enable
assign glb_rx_low_en = afr_rx_low_en & (FIFO_WATERMARK == 1);

//RX FIFO Low Value
assign rxfifo_low_watermark = glb_rx_low_en ? (rxfifo_navail <= rx_low_value[ASIZE:0]) : rxfifo_empty;

//------------------------------------------------------------------------------
//Character Timeout Interrupt
//------------------------------------------------------------------------------
//Due to the need to count in baud_clk - this section requires some logic to use
//baud_clken - which is yet another exception that needs to be made

//character timeout is largely free running
//it gets cleared whenever any of the clearing conditions are met

//counter clear conditions are:
//FIFO empty OR FIFO put OR FIFO get
//all the signals above run in "clk" domain - we need to cross these over
//to "baud_clk" domain using synchronous crossing logic below

//"clk" domain logic
//Register element
always_ff @(posedge clk or negedge rst_n) begin
   if (!rst_n) clear_src <= 0;
   else        clear_src <= clear_src_nxt;
end

//Combi element
always_comb begin
   if (rxfifo_empty | rxfifo_get | rxfifo_put)  // Set "clear_src" flag
     clear_src_nxt = 1'b1;
   else if (clear_dst)                          // Clear "clear_src" flag when it successfully cross clock domain
     clear_src_nxt = 1'b0;
   else
     clear_src_nxt = clear_src;                 // Hold "clear_src" flag until it cross clock domain
end

//"baud_clk" domain logic
//Flops clear_src to clear_dst
always_ff @(posedge clk or negedge rst_n) begin
   if (!rst_n)          clear_dst <= 0;
   else if (baud_clken) clear_dst <= clear_src;
end

//Count 16 "baud_clk" to obtain 1 bit time
//bit-timer instantiation
altr_uart_bit_timer char_bit_timer (
   .inc(glb_fifoe),
   .s_rst(clear_dst),
   .*
);

//one_bit_time indication
assign one_bit_time = (bit_timer == 4'hF);

//character timeout counter register
always_ff @(posedge clk or negedge rst_n) begin
   if (!rst_n)          char_cnt <= '0;
   else if (baud_clken) char_cnt <= char_cnt_nxt;
   else if (clear_src)  char_cnt <= '0;
end

//character timeout counter next value
always_comb begin
   if (clear_dst) 
      char_cnt_nxt = '0;
   else if (one_bit_time & ~rxstor_char_timeout) 
      char_cnt_nxt = char_cnt + 6'h1;
   else
      char_cnt_nxt = char_cnt;
end

//character timeout value
always_comb begin
   unique case ({lcr_stop_l, lcr_pen_l, lcr_dls_l})
      5'h0: char_timeout_val = 6'd28;
      5'h1: char_timeout_val = 6'd32;
      5'h2: char_timeout_val = 6'd36;
      5'h3: char_timeout_val = 6'd40;
	  5'h4: char_timeout_val = 6'd44;
      5'h8: char_timeout_val = 6'd32;
      5'h9: char_timeout_val = 6'd36;
      5'hA: char_timeout_val = 6'd40;
      5'hB: char_timeout_val = 6'd44;
	  5'hC: char_timeout_val = 6'd48;
      5'h10: char_timeout_val = 6'd30;
      5'h11: char_timeout_val = 6'd36;
      5'h12: char_timeout_val = 6'd40;
      5'h13: char_timeout_val = 6'd44;
	  5'h14: char_timeout_val = 6'd48;
      5'h18: char_timeout_val = 6'd34;
      5'h19: char_timeout_val = 6'd40;
      5'h1A: char_timeout_val = 6'd44;
      5'h1B: char_timeout_val = 6'd48;
	  5'h1C: char_timeout_val = 6'd52;

      default: char_timeout_val = 6'd0;
   endcase
end

//character timeout indication (only works in FIFO mode)
//character timeout occurs when the count is GREATER_OR_EQUAL than the timeout value
//this prevents the timer going out of whack when various lcr_* register change values
assign rxstor_char_timeout = glb_fifoe & (char_cnt >= char_timeout_val);

//------------------------------------------------------------------------------
//Overrun Error
//------------------------------------------------------------------------------
assign lsr_oe_source = glb_fifoe ? (rxstor_put & rxfifo_full) : (rxstor_put & ~rb_empty & ~rb_get);

//------------------------------------------------------------------------------
//Parity Error
//------------------------------------------------------------------------------
assign lsr_pe_source = glb_fifoe ?  (rxfifo_rdata[PARITY_ERROR] & ~rxfifo_empty) : 
                                    (rb_rdata[PARITY_ERROR]     & ~rb_empty);

//------------------------------------------------------------------------------
//Framing Error
//------------------------------------------------------------------------------
assign lsr_fe_source = glb_fifoe ?  (rxfifo_rdata[FRAME_ERROR] & ~rxfifo_empty) : 
                                    (rb_rdata[FRAME_ERROR]     & ~rb_empty);

//------------------------------------------------------------------------------
//Break Interrupt
//------------------------------------------------------------------------------
assign lsr_bi_source = glb_fifoe ?  (rxfifo_rdata[BREAK] & ~rxfifo_empty) : 
                                    (rb_rdata[BREAK]     & ~rb_empty);

//------------------------------------------------------------------------------
//Rx FIFO Error
//------------------------------------------------------------------------------
//This...sadly seems like it has to be implemented as a counter :(

logic [ASIZE:0] error_cnt, error_cnt_nxt, error_cnt_inc;
logic inc, dec;
logic lsr_rfe_reg, lsr_rfe_reg_nxt, lsr_rfe_reg_clr;

//Counter flops
always_ff @(posedge clk or negedge rst_n) begin
   if (!rst_n) error_cnt <= '0;
   else        error_cnt <= error_cnt_nxt;
end

//Counter clear to zero logic
always_comb begin
   error_cnt_nxt = rxfifo_rst ? '0 : error_cnt_inc;
end

//Counter increment/decrement logic
always_comb begin
   unique case ({dec, inc})
      2'b00: error_cnt_inc = error_cnt;
      2'b01: error_cnt_inc = error_cnt + {{(ASIZE){1'b0}}, 1'b1};
      2'b10: error_cnt_inc = error_cnt - {{(ASIZE){1'b0}}, 1'b1};
      2'b11: error_cnt_inc = error_cnt;

      default: error_cnt_inc = error_cnt;
   endcase
end

//------------------------------------------------------------------------------
//REG: LSR RFE
//------------------------------------------------------------------------------
logic read_lsr;
logic read_lsr_reg, rxfifo_get_reg, rxfifo_put_reg, rxfifo_rst_reg;

always_ff @(posedge clk or negedge rst_n) begin
   if (!rst_n) begin
	   read_lsr_reg 	<= '0;
	   rxfifo_get_reg	<= '0;
	   rxfifo_put_reg	<= '0;
	   rxfifo_rst_reg	<= '0;
   end
   else begin
	   read_lsr_reg 	<= read_lsr;
	   rxfifo_get_reg	<= rxfifo_get;
	   rxfifo_put_reg	<= rxfifo_put;
	   rxfifo_rst_reg	<= rxfifo_rst;
   end
end

//register rxfifo_get for dec is because rxfifo_rdata is updated one clock cycle after rxfifo_get
assign inc = (rxstor_data[PARITY_ERROR] | rxstor_data[FRAME_ERROR] | rxstor_data[BREAK]) & rxfifo_put_reg;
assign dec = (rxfifo_rdata[PARITY_ERROR] | rxfifo_rdata[FRAME_ERROR] | rxfifo_rdata[BREAK]) & rxfifo_get_reg;

assign read_lsr = lsr_read_access | rxfifo_get;

//Clear term for RFE register
assign lsr_rfe_reg_clr = (error_cnt == 1) & (rxfifo_rdata[PARITY_ERROR] | rxfifo_rdata[FRAME_ERROR] | rxfifo_rdata[BREAK]) & read_lsr_reg;

//RFE register logic
always_ff @(posedge clk or negedge rst_n) begin
   if (!rst_n) lsr_rfe_reg <= 0;
   else        lsr_rfe_reg <= lsr_rfe_reg_nxt;
end

//RFE next state logic
//Set it upon inc to ensure that LSR RFE setting is consistent with other LSR bits
assign lsr_rfe_reg_nxt =   (rxfifo_rst_reg)  ? 1'b0 :
                           (inc)             ? 1'b1 :
                           (lsr_rfe_reg_clr) ? 1'b0 :
                           lsr_rfe;

//RFE is only set when FIFO is enabled
assign lsr_rfe = glb_fifoe & lsr_rfe_reg;

//------------------------------------------------------------------------------
//REG: lsr mask clearing signal
//------------------------------------------------------------------------------
//This signal is used by CSREXT block to clear the mask on the Read-to-clear
//logic for various CSRs
//Previously - this was "rxfifo_get | rb_get" - which resolves to rbr_read_access & lsr_dr in CSREXT
//The problem is with the Overrun handling in FIFO-less mode. 
//Mask should be cleared if the Rx FIFO gets reset
assign lsr_error_mask_clr = rxfifo_get | rb_put | rxfifo_rst;


endmodule: altr_uart_rxstor
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "AKY/VDqroC56S5zYqI2FH+pDtMm2XXjvzWe8rGJiybS03yo4KNBMg81pmtWbHVIPiTA81zIuGQJqb5vOIzimr/z+D85S4Jjtk9u3+kDOlkJUsrbYjDeARoR1d2Gy20nZHckh8FGW+dSF0ir+jochMyts2Y//A4WlmCaB7gD83g5rkI4jT1ldDhtPnUUhGKawcEehCEezQ12Toa+YG3kf1PWegnVnp6lxL1nZ0P1Qzo9/kWfMmwtceSKC39Z5ndejHwvAJqH5hrJttMc/20n8z1laYRT6amGlSUhxcvhA42KjgFaVjbwsY40WceKzvpkLKtfQ6SfAH4+Z64ve2J9NNI9UnuPu2zmS1toceYmMeGQTeRYEVa8yfj01fieO69jxBbYBLkiiWwY2XlyYUi/u5hExg9JwFM4TkXRE3yUaGHFRNc7wUN9RlcCAMoDxInlB+D0y3k0sA8Wv8wpgdZQv2Lpec3tefgorcdz4c0qf46zkNzfbXXyRoImvvQK7+s/NOD0zIAaiIry4L7eZcaLXd3Tt6wNuA6Ah6BuFiKj94qT88xkZP0sk85WcUTSyF0mtflYQzTwVoJ6ZlgqSMth5V19p8UiWVFmUkmvlvCDwY7t91+eWAgQUOEhP3aZk+BjSwk1zwL7R1uXkg3biUXPeiHqVWcf47pX/k9lAOHJRHWocAb/SJPCnDmKlNj6soJlDi299cZKtWr4l5cyIYyjk275zeUSOLShcR2BA7atY2E24R3x27lJT0ywKASyqthP3Jiqm969yn4uujaaYiMXTbI6CUjUANOz6pn2b8AOptVxS9Hq2tX4ZdSYhps2KvI3KqHz//wOygeSkbkRY9Wf2H08I+RMcqbJMCNxJ69ZP/zCNIo9beOs25gaiTnaWMJDcO6mU42hfEQ00SdCLY6xETIJKLMmy4m1I4I6X2VFGT2jfZRFsT4GD74LsHetuOWJUXejmLmK6rmdAppuOmsR+o2cwDZnwlK1xJP7p4vuM1ZzZogndcU7XhGfgs+Dv981K"
`endif
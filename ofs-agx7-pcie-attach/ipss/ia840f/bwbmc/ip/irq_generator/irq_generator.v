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

// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on

// turn off superfluous verilog processor warnings
// altera message_level Level1
// altera message_off 10034 10035 10036 10037 10230 10240 10030
//
// Description - interrupt generator
//
// Ensure that the irq is enabled via relevant bit of 'interrupt mask' reg being set
// Write a '1' to one of the four lsbs of 'initiate interrupt' reg to initiate an interrupt
// Interrupt reason can be determined by 'interrupt reason' reg
// Interrupt can be cleared down by writing a '1' to the appropriate bit in the 'interrupt reason' reg
//
// Address | Register           | Width
// ------------------------------------
// 0x0     | initiate interrupt   [IRQ_WIDTH-1:0]
// 0x1     | unused
// 0x2     | interrupt mask       [IRQ_WIDTH-1:0]
// 0x3     | interrupt reason     [IRQ_WIDTH-1:0]

module irq_generator
  (
   // inputs:
   address,
   chipselect,
   clk,
   reset_n,
   write_n,
   writedata,
   // inputs:
   irq_in,
   // outputs:
   irq,
   readdata
   );

   parameter appear_in_device_tree = 0;           // Appear in device tree if one

   parameter IRQ_WIDTH = 8;

   output           irq;
   output [ 31: 0]  readdata;
   input [  1: 0]   address;
   input            chipselect;
   input            clk;
   input            reset_n;
   input            write_n;
   input [ 31: 0]   writedata;
   input [ 1:0]     irq_in;


   wire             clk_en;
   reg [IRQ_WIDTH-1: 0]  d1_data_in;
   reg [IRQ_WIDTH-1: 0]  d2_data_in;
   reg [3 : 0]  data_in;
   reg [IRQ_WIDTH-1: 0]     edge_capture;
   wire             edge_capture_wr_strobe;
   wire [IRQ_WIDTH-1: 0]    edge_detect;
   wire             irq;
   reg [IRQ_WIDTH-1: 0]     irq_mask;
   wire [IRQ_WIDTH-1: 0]    read_mux_out;
   reg [ 31: 0]     readdata;
   assign 	    clk_en = 1;
   //s1, which is an e_avalon_slave
   assign 	    read_mux_out = ({IRQ_WIDTH {(address == 0)}} & data_in) |
				   ({IRQ_WIDTH {(address == 2)}} & irq_mask) |
				   ({IRQ_WIDTH {(address == 3)}} & edge_capture);

   always @(posedge clk or negedge reset_n)
     begin
	if (reset_n == 0)
          readdata <= 0;
	else if (clk_en)
          readdata <= {32'b0 | read_mux_out};
     end

   always @(*)
     begin
        data_in <= 0;
	if (chipselect && ~write_n && (address == 0)) begin
           data_in <= writedata[3 : 0];
	end
     end

   always @(posedge clk or negedge reset_n)
     begin
	if (reset_n == 0)
          irq_mask <= 0;
	else if (chipselect && ~write_n && (address == 2))
          irq_mask <= writedata[IRQ_WIDTH-1: 0];
     end


   assign irq = |(edge_capture & irq_mask);
   assign edge_capture_wr_strobe = chipselect && ~write_n && (address == 3);
   always @(posedge clk or negedge reset_n)
     begin
	if (reset_n == 0)
          edge_capture[0] <= 0;
	else if (clk_en)
          if (edge_capture_wr_strobe && writedata[0])
            edge_capture[0] <= 0;
          else if (edge_detect[0])
            edge_capture[0] <= -1;
     end


   always @(posedge clk or negedge reset_n)
     begin
	if (reset_n == 0)
          edge_capture[1] <= 0;
	else if (clk_en)
          if (edge_capture_wr_strobe && writedata[1])
            edge_capture[1] <= 0;
          else if (edge_detect[1])
            edge_capture[1] <= -1;
     end


   always @(posedge clk or negedge reset_n)
     begin
	if (reset_n == 0)
          edge_capture[2] <= 0;
	else if (clk_en)
          if (edge_capture_wr_strobe && writedata[2])
            edge_capture[2] <= 0;
          else if (edge_detect[2])
            edge_capture[2] <= -1;
     end


   always @(posedge clk or negedge reset_n)
     begin
	if (reset_n == 0)
          edge_capture[3] <= 0;
	else if (clk_en)
          if (edge_capture_wr_strobe && writedata[3])
            edge_capture[3] <= 0;
          else if (edge_detect[3])
            edge_capture[3] <= -1;
     end

   always @(posedge clk or negedge reset_n)
     begin
	if (reset_n == 0)
          edge_capture[4] <= 0;
	else if (clk_en)
          if (edge_capture_wr_strobe && writedata[4])
            edge_capture[4] <= 0;
          else if (edge_detect[4])
            edge_capture[4] <= -1;
     end

   always @(posedge clk or negedge reset_n)
     begin
	if (reset_n == 0)
          edge_capture[5] <= 0;
	else if (clk_en)
          if (edge_capture_wr_strobe && writedata[5])
            edge_capture[5] <= 0;
          else if (edge_detect[5])
            edge_capture[5] <= -1;
     end

   always @(posedge clk or negedge reset_n)
     begin
	if (reset_n == 0)
          edge_capture[6] <= 0;
	else if (clk_en)
          if (edge_capture_wr_strobe && writedata[6])
            edge_capture[6] <= 0;
          else if (edge_detect[6])
            edge_capture[6] <= -1;
     end

   always @(posedge clk or negedge reset_n)
     begin
	if (reset_n == 0)
          edge_capture[7] <= 0;
	else if (clk_en)
          if (edge_capture_wr_strobe && writedata[7])
            edge_capture[7] <= 0;
          else if (edge_detect[7])
            edge_capture[7] <= -1;
     end


   always @(posedge clk or negedge reset_n)
     begin
	if (reset_n == 0)
          begin
             d1_data_in <= 0;
             d2_data_in <= 0;
          end
	else if (clk_en)
          begin
             // IA840F binds software causes only; both external irq_in ports
             // are open in the vendor system. Keep external causes inactive.
             // Original vendor expression: {irq_in, irq_in, data_in}
             d1_data_in <= {4'b0000, data_in};
             d2_data_in <= d1_data_in;
          end
     end


   assign edge_detect = d1_data_in ^  d2_data_in;

endmodule


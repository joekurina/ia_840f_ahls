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
//Interrupt block
//
`timescale 1 ps / 1 ps
module altr_uart_interrupt (
   //Clock and reset
   input  clk,
   input  rst_n,

   //avmm slave read
   input  rbr_thr_dll_read_access,

   //Receive Data Available Interrupt (Controlled by IER[0])
   input  rxstor_rxdata_avail,
   input  ier_erbfi,

   //Character Timeout Indication (Controlled by IER[0])
   input  rxstor_char_timeout,

   //Transmit Holding Register Empty Interrupt (Controlled by IER[1])
   input  intr_thre_source,
   input  iir_was_read,
   input  ier_etbei,
   output iir_was_read_eq_thre,

   //Receiver Line Status Interrupt (Controlled by IER[2])
   input  lsr_oe,
   input  lsr_pe,
   input  lsr_fe,
   input  lsr_bi,
   input  ier_elsi,

   //Modem Status Interrupt (Controlled by IER[3])
   input  msr_ddcd,
   input  msr_teri,
   input  msr_ddsr,
   input  msr_dcts,
   input  ier_edssi,
   input  glb_hwfce,

   //IID Register
   output logic [3:0] iir_id,

   //Interrupt Output
   output logic intr

);

//------------------------------------------------------------------------------
//Interrupt Sources - in order of priority
//------------------------------------------------------------------------------

//Receiver Line Status (Highest Priority)
logic intr_elsi;
assign intr_elsi  = ier_elsi & ( lsr_oe | lsr_pe | lsr_fe | lsr_bi );

//Received Data Available (2nd Highest Priority)
logic intr_erbfi;
assign intr_erbfi = ier_erbfi & rxstor_rxdata_avail;

//Character Timeout Indication (2nd Highest Priority)
logic intr_char_timeout;
assign intr_char_timeout = ier_erbfi & rxstor_char_timeout;

//Transmit Holding Register Empty (3rd Highest Priority)
logic intr_thre;
logic [3:0] iir_id_r;

assign intr_thre = ier_etbei & intr_thre_source;

//Flop iir_id to ensure it lines up with the time for iir_was_read signal from CSR
always_ff @(posedge clk or negedge rst_n) begin
   if (!rst_n) iir_id_r <= 0;
   else        iir_id_r <= iir_id;
end

//Indicator that IIR was read in the previous clock with the value of 4'b0010
//This is the signal that clears intr_thre
assign iir_was_read_eq_thre = iir_was_read & (iir_id_r == 4'b0010);

//Modem Status (4th Highest Priority)
logic intr_modem;
assign intr_modem = ier_edssi & ( msr_ddcd | msr_teri | msr_ddsr | (msr_dcts & ~glb_hwfce) );

//edge detection prolonged_intr_char_timeout
logic intr_char_timeout_dly;
logic intr_char_timeout_pos;

always_ff @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    intr_char_timeout_dly <= 1'b0;
  end else begin 
    intr_char_timeout_dly <= intr_char_timeout;
  end
end

assign intr_char_timeout_pos = intr_char_timeout & ~intr_char_timeout_dly;

//Prolonged intr_char_timeout until iir_was_read by processor
logic prolonged_intr_char_timeout_reg;

always_ff @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		 prolonged_intr_char_timeout_reg <= 1'b0; 
  end else if(rbr_thr_dll_read_access) begin 
    prolonged_intr_char_timeout_reg <= 1'b0; 
  end else if (intr_char_timeout_pos) begin
	prolonged_intr_char_timeout_reg <= 1'b1;
  end 
end


//------------------------------------------------------------------------------
//Interrupt Output
//------------------------------------------------------------------------------
always_ff @(posedge clk or negedge rst_n) begin
   if (!rst_n) intr <= 0;
   else        intr <= intr_elsi | intr_erbfi | intr_thre | intr_modem | prolonged_intr_char_timeout_reg ;
end

//------------------------------------------------------------------------------
//Interrupt ID
//------------------------------------------------------------------------------
always_comb begin
   if (intr_elsi)                iir_id = 4'b0110;
   else if (intr_erbfi)          iir_id = 4'b0100;
   else if (prolonged_intr_char_timeout_reg)                        iir_id = 4'b1100;
   else if (intr_thre)           iir_id = 4'b0010;
   else if (intr_modem)          iir_id = 4'b0000;
   else                          iir_id = 4'b0001;
end


endmodule: altr_uart_interrupt
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "AKY/VDqroC56S5zYqI2FH+pDtMm2XXjvzWe8rGJiybS03yo4KNBMg81pmtWbHVIPiTA81zIuGQJqb5vOIzimr/z+D85S4Jjtk9u3+kDOlkJUsrbYjDeARoR1d2Gy20nZHckh8FGW+dSF0ir+jochMyts2Y//A4WlmCaB7gD83g5rkI4jT1ldDhtPnUUhGKawcEehCEezQ12Toa+YG3kf1PWegnVnp6lxL1nZ0P1Qzo8OKQZn3wt9NvKpv/t8o9tJy+riBfxmD69XURmV+gal1ZU3FLeNcNM3AZrVsFNuv98mnHjjPH2hlh9IQ2FWzTTQ4ceKFMvz+TKkLLu6OiPzOsBBl019CpqAnW97cimrvhiMkzm0SN0GF+/INX1N6LlVqcWsusjoFnhAbnn/nQ+R1oL+EKRRlIVIhn/CJfkZYdgmxppeKdmSC4MmK06vgBWubQ0pWDOGWVVB5BbZaZ2F/RhQG02hrBQZZ7v7e3KEuO9aBvtVoommVI6UhRXaVV7ksasmltacFah3wMihXKmctvHtC+S9HpoP5g2+ODqCd9AWOGrkYbTkYYPV+dEgVA2oA1hHHREtSeY9XqfgcMACkIm5ovGvjDXMXyfeT3xNHUNl5KSnJ/vuvASBjKcsMPReGFt5J+B/gJe+XxD4xtTjW2+eVfVoqvgZhlePcIjkUedoVvYiqPamWgifh2oS6RxTEFsz8tvLRXy6r4ZfgPOZWHcd6aKpLo28KK6kMqSsugfyNTHED/hcTt+T/EVRcDekI7ozxKySkXg/KovX5kuzlLziMbn7Yzqp+S9y0fNEbbMNI9OyV84OtUvtf8Qx6+rAKay4/GenKw4GNOPYWVuGREdNvrnxXXcszxaOOh1KEDkJTa0R6gVg/I2tx24HOrj/c5RufOyknudDzX3lisb/gENNkcHeLk/D5h6z7hnx3yNd+F7PO3O9kumVcqMI4PNCf099QjzdneFJRO8aLQc26FFqa1rFQPmKjr9AgcEnqeVeQdkfyRFWpjLWqVXbT6EV"
`endif
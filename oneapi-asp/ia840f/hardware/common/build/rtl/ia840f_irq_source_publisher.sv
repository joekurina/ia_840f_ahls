// IA-840F plain-flow source-clock IRQ publication boundary.
// Existing CRA clear/status/counter semantics and destination chain stay intact.
module ia840f_irq_source_publisher (
  input logic clk,
  input logic reset_n,
  input logic irq_raw,
  output wire irq_published
);
  (* preserve *) logic irq_q;
  always_ff @(posedge clk) begin
    if (!reset_n) irq_q <= 1'b0;
    else irq_q <= irq_raw;
  end
  assign irq_published = irq_q;
endmodule

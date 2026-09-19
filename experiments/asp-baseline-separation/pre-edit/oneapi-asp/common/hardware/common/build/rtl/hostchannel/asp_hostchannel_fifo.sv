// SPDX-License-Identifier: MIT
// Same-clock, bounded, ready/valid FIFO. DEPTH must be a power of two >= 2.
module asp_hostchannel_fifo #(
    parameter int WIDTH = 512,
    parameter int LOG_DEPTH = 6
)(
    input logic clk, reset_n, clear,
    input logic [WIDTH-1:0] in_data,
    input logic in_valid,
    output logic in_ready,
    output logic [WIDTH-1:0] out_data,
    output logic out_valid,
    input logic out_ready,
    output logic [LOG_DEPTH:0] count
);
    localparam int DEPTH = 1 << LOG_DEPTH;
    logic [WIDTH-1:0] storage [0:DEPTH-1];
    logic [LOG_DEPTH-1:0] head, tail;
    wire push = in_valid && in_ready;
    wire pop = out_valid && out_ready;
    assign in_ready = (count < DEPTH) && !clear && reset_n;
    assign out_valid = (count != 0) && !clear && reset_n;
    assign out_data = storage[head];
    always_ff @(posedge clk) begin
        if (!reset_n || clear) begin
            head <= '0;
            tail <= '0;
            count <= '0;
        end else begin
            if (push) begin
                storage[tail] <= in_data;
                tail <= tail + 1'b1;
            end
            if (pop) head <= head + 1'b1;
            case ({push, pop})
                2'b10: count <= count + 1'b1;
                2'b01: count <= count - 1'b1;
                default: count <= count;
            endcase
        end
    end
endmodule

`timescale 1ns/1ps
// Tests the source-extracted ack producer and the unmodified pending counter.
// No EMIF/DDR model, device primitive, FIFO substitute or hardware API is used.
module writeack_unit_tb;
    reg clk = 0;
    always #5 clk = ~clk;
    reg write_i = 0;
    reg wait_i = 0;
    reg ring_ack_i = 0;
    wire ack0, ack1, ack_bsp, early0, early1, early_bsp;
    reg resetn = 0;
    wire pending;
    integer cycles = 0;
    integer checks = 0;
    integer accepted = 0;
    integer acknowledged = 0;
    integer scenarios = 0;
    integer before_accepted;
    integer before_acknowledged;

    ack_under_test #(.ENABLE_BSP_WAITREQUEST_ALLOWANCE(0)) zero_allowance(
        .clk, .write_i, .wait_i, .ring_ack_i,
        .ext_ack_o(ack0), .write_ack_o(early0));
    ack_under_test #(.ENABLE_BSP_WAITREQUEST_ALLOWANCE(1)) allowance_preservation(
        .clk, .write_i, .wait_i, .ring_ack_i,
        .ext_ack_o(ack1), .write_ack_o(early1));
    ack_under_test #(.ENABLE_BSP_AVMM_WRITE_ACK(1)) bsp_preservation(
        .clk, .write_i, .wait_i, .ring_ack_i,
        .ext_ack_o(ack_bsp), .write_ack_o(early_bsp));
    // COUNT_WIDTH=8 is the library default, not a claim about the full kernel's
    // elaborated parameter. Outstanding test credits stay well below capacity.
    acl_has_pending_write #(.COUNT_WIDTH(8)) pending_counter(
        .clock(clk), .aclrn(resetn), .sclrn(resetn),
        .i_write_accepted(ring_ack_i), .i_writeack(ack0),
        .o_has_pending_write(pending));

    task automatic cycle(input bit w, input bit stall, input bit entry);
        @(negedge clk);
        write_i = w;
        wait_i = stall;
        ring_ack_i = entry;
        #1;
        checks += 1;
        if ({early0, early1, early_bsp, ack_bsp} !== {4{entry}})
            $fatal(1, "UNCHANGED_ACK_PATH_MISMATCH cycle=%0d", cycles);
        @(posedge clk);
        #1;
        cycles += 1;
        checks += 2;
        if (ack0 !== (w && !stall))
            $fatal(1, "ACK_ACCEPTANCE_MISMATCH cycle=%0d write=%b waitrequest=%b ack=%b expected=%b", cycles,w,stall,ack0,(w && !stall));
        // This is preservation of the existing allowance-enabled expression,
        // not qualification of that mode's full downstream credit protocol.
        if (ack1 !== w)
            $fatal(1, "ALLOWANCE_PRESERVATION_MISMATCH cycle=%0d", cycles);
        accepted += (w && !stall);
        acknowledged += ack0;
    endtask

    initial begin
        repeat (3) @(negedge clk);
        // All boolean combinations, including idle while waitrequest is high.
        for (int bits = 0; bits < 8; bits++)
            cycle(bits[2], bits[1], bits[0]);
        scenarios += 1;
        cycle(0,0,0);
        // Reset only the pending-counter fixture before balanced transactions.
        resetn = 0;
        repeat (3) cycle(0,0,0);
        resetn = 1;
        repeat (3) cycle(0,0,0);
        // A single final write held under sustained backpressure.
        cycle(0,0,1);
        repeat (3) cycle(0,0,0);
        checks += 1;
        if (pending !== 1'b1) $fatal(1, "PENDING_MISSING_AFTER_ENQUEUE");
        before_accepted = accepted;
        before_acknowledged = acknowledged;
        repeat (33) begin
            cycle(1,1,0);
            checks += 1;
            if (pending !== 1'b1) $fatal(1, "PENDING_LOST_UNDER_BACKPRESSURE");
        end
        checks += 1;
        if (accepted != before_accepted || acknowledged != before_acknowledged)
            $fatal(1, "STALLED_FINAL_BEAT_RETIRED");
        cycle(1,0,0);
        repeat (4) cycle(0,0,0);
        checks += 1;
        if (pending !== 1'b0 || accepted != before_accepted+1 || acknowledged != before_acknowledged+1)
            $fatal(1, "FINAL_BEAT_DRAIN_MISMATCH");
        scenarios += 1;
        // Eight output beats, with stalls before the first, middle and last.
        // No burstcount/address/data protocol is modeled by this unit fixture.
        repeat (8) cycle(0,0,1);
        before_accepted = accepted;
        before_acknowledged = acknowledged;
        for (int beat = 0; beat < 8; beat++) begin
            repeat ((beat % 3)+1) cycle(1,1,0);
            cycle(1,0,0);
        end
        repeat (4) cycle(0,0,0);
        checks += 1;
        if (pending !== 1'b0 || accepted != before_accepted+8 || acknowledged != before_acknowledged+8)
            $fatal(1, "EIGHT_BEAT_DRAIN_MISMATCH");
        scenarios += 1;
        // Back-to-back accepted outputs, with enqueue credits already present.
        repeat (32) cycle(0,0,1);
        repeat (32) cycle(1,0,0);
        repeat (4) cycle(0,0,0);
        checks += 1;
        if (pending !== 1'b0) $fatal(1, "BACK_TO_BACK_DRAIN_MISMATCH");
        scenarios += 1;
        // Repeated invocations of the unit contract with deterministic stalls.
        for (int transaction = 0; transaction < 64; transaction++) begin
            cycle(0,0,1);
            repeat (transaction % 9) cycle(1,1,0);
            cycle(1,0,0);
            repeat (4) cycle(0,0,0);
            checks += 1;
            if (pending !== 1'b0) $fatal(1, "REPEATED_DRAIN_MISMATCH transaction=%0d",transaction);
        end
        scenarios += 1;
        checks += 1;
        if (accepted != acknowledged) $fatal(1, "TOTAL_ACK_MISMATCH");
        $display("WRITEACK_UNIT_PASS scenarios=%0d cycles=%0d checks=%0d accepted=%0d acknowledged=%0d",scenarios,cycles,checks,accepted,acknowledged);
        $finish;
    end
    initial begin
        #100000;
        $fatal(1, "UNIT_WATCHDOG_EXPIRED");
    end
endmodule

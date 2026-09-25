`timescale 1ns/1ps
module tb_observer_mailbox #(parameter integer SEQ_BITS=64);
    reg core_clk=0,bank_clk=0,run_bank=1;
    always #5 core_clk=~core_clk;
    always #7 if(run_bank) bank_clk=~bank_clk; else bank_clk=0;
    reg core_reset_n=0,bank_reset_n=0;
    reg core_cmd_valid=0;
    reg [1:0] core_cmd=0;
    reg [63:0] core_expected=0,core_token=0;
    reg dma_write_attempt=0;
    wire core_ready,core_busy,core_valid,core_done,epoch_window;
    wire [7:0] core_errors;
    wire [63:0] core_sequence;
    wire [767:0] core_snapshot;
    wire response_armed,response_error;
    wire bank_link_reset_n,bank_cmd_valid,bank_dma_fault;
    wire [1:0] bank_cmd;
    wire [63:0] bank_expected,bank_token;
    wire bank_cmd_ack,armed,empty,target_retired;
    wire [7:0] errors;
    wire [63:0] first_error,token,expected_bytes,baseline;
    wire [63:0] aw_total,b_total,expected_w_beats,w_total,wlast_total,accepted_bytes,retired_bytes;
    wire [63:0] flags={61'd0,target_retired,empty,armed};
    wire [767:0] bank_snapshot={flags,first_error,56'd0,errors,wlast_total,w_total,expected_w_beats,b_total,aw_total,retired_bytes,accepted_bytes,baseline,token};
    reg awvalid=0,awready=0,wvalid=0,wready=0,wlast=0,bvalid=0,bready=0;
    reg [7:0] awlen=0;
    reg [8:0] awid=0,bid=0;
    reg [63:0] wstrb=0;
    reg [1:0] bresp=0;
    integer checks=0,cases=0,commands=0;
    reg [767:0] saved;
    reg [63:0] seq_before;
    integer count_before;

    ia840f_ahls_observer_mailbox #(.SNAP_BITS(768),.SEQ_BITS(SEQ_BITS)) box(
        .core_clk(core_clk),.core_reset_n(core_reset_n),.bank_clk(bank_clk),.bank_reset_n(bank_reset_n),
        .core_cmd_valid(core_cmd_valid),.core_cmd(core_cmd),.core_expected(core_expected),.core_token(core_token),
        .dma_write_attempt(dma_write_attempt),.core_ready(core_ready),.core_busy(core_busy),.core_valid(core_valid),
        .core_done(core_done),.core_errors(core_errors),.epoch_window(epoch_window),.core_sequence(core_sequence),
        .core_snapshot(core_snapshot),.response_armed(response_armed),.response_error(response_error),
        .bank_link_reset_n(bank_link_reset_n),.bank_cmd_valid(bank_cmd_valid),.bank_cmd(bank_cmd),
        .bank_expected(bank_expected),.bank_token(bank_token),.bank_dma_fault(bank_dma_fault),
        .bank_cmd_ack(bank_cmd_ack),.bank_snapshot(bank_snapshot),.bank_error(|errors),.bank_armed(armed));
    ia840f_ahls_write_observer observer(
        .clk(bank_clk),.rst_n(bank_link_reset_n),.awvalid(awvalid),.awready(awready),.awlen(awlen),.awid(awid),
        .wvalid(wvalid),.wready(wready),.wlast(wlast),.wstrb(wstrb),.bvalid(bvalid),.bready(bready),.bresp(bresp),.bid(bid),
        .cmd_valid(bank_cmd_valid),.cmd(bank_cmd),.cmd_expected(bank_expected),.cmd_token(bank_token),
        .dma_write_fault(bank_dma_fault),.link_fault(1'b0),.cmd_ack(bank_cmd_ack),.armed(armed),.empty(empty),
        .target_retired(target_retired),.errors(errors),.first_error(first_error),.token(token),.expected_bytes(expected_bytes),
        .baseline(baseline),.aw_total(aw_total),.b_total(b_total),.expected_w_beats(expected_w_beats),
        .w_total(w_total),.wlast_total(wlast_total),.accepted_bytes(accepted_bytes),.retired_bytes(retired_bytes));
    always @(posedge bank_clk) if(bank_link_reset_n && bank_cmd_valid) commands=commands+1;
    task ct; begin @(posedge core_clk);#1;end endtask
    task bt; begin @(posedge bank_clk);#1;end endtask
    task check(input good,input [639:0] label_text);
        begin checks=checks+1;if(good!==1'b1)$fatal(1,"CHECK %0s core_errors=%h bank_errors=%h busy=%b valid=%b seq=%0d",label_text,core_errors,errors,core_busy,core_valid,core_sequence);end
    endtask
    task reset_case;
        begin
            @(negedge core_clk);core_reset_n=0;bank_reset_n=0;core_cmd_valid=0;dma_write_attempt=0;run_bank=1;
            awvalid=0;awready=0;wvalid=0;wready=0;bvalid=0;bready=0;bresp=0;
            repeat(3)ct();@(negedge core_clk);core_reset_n=1;bank_reset_n=1;
            repeat(12)ct();check(core_ready && !core_busy && !core_valid && core_errors==0 && !armed,"fresh link ready");
            cases=cases+1;
        end
    endtask
    task send(input [1:0] op,input [63:0] amount,input [63:0] tag);
        begin
            @(negedge core_clk);check(core_ready,"request locally ready");core_cmd=op;core_expected=amount;core_token=tag;core_cmd_valid=1;
            ct();check(core_busy && !core_valid,"enqueue returns local busy without native response");
            @(negedge core_clk);core_cmd_valid=0;
        end
    endtask
    task await_done;
        integer j;
        begin
            j=0;while(core_busy && j<100)begin ct();j=j+1;end
            check(j<100 && !core_busy,"bounded mailbox completion");
        end
    endtask
    task transfer_w(input [63:0] mask);
        begin
            @(negedge bank_clk);awvalid=1;awready=1;awlen=0;bt();
            @(negedge bank_clk);awvalid=0;awready=0;wvalid=1;wready=1;wlast=1;wstrb=mask;bt();
            @(negedge bank_clk);wvalid=0;wready=0;
        end
    endtask
    task transfer_b;
        begin @(negedge bank_clk);bvalid=1;bready=1;bt();@(negedge bank_clk);bvalid=0;bready=0;end
    endtask

    initial begin
        reset_case();count_before=commands;send(1,4,1);await_done();
        check(core_valid && response_armed && epoch_window && core_snapshot[63:0]==1 && core_sequence==1,"coherent armed acknowledgement");
        check(commands==count_before+1,"one native ARM strobe");
        transfer_w(15);send(2,0,0);await_done();
        check(core_valid && core_snapshot[128+:64]==4 && core_snapshot[192+:64]==0 && !core_snapshot[706],"snapshot before final B not retired");
        transfer_b();send(2,0,0);await_done();
        check(core_valid && core_snapshot[706] && core_snapshot[192+:64]==4,"coherent retired snapshot");saved=core_snapshot;
        transfer_w(0);transfer_b();repeat(12)ct();check(core_snapshot==saved,"snapshot immutable while native totals advance");
        send(2,0,0);await_done();check(core_snapshot[256+:64]==2 && core_snapshot[320+:64]==2,"fresh snapshot atomic updated totals");
        send(3,0,0);await_done();check(core_valid && !response_armed && !epoch_window && core_sequence==5,"release window ends on successful acknowledgement");

        reset_case();@(negedge bank_clk);run_bank=0;count_before=commands;
        send(2,0,0);repeat(20)ct();check(core_busy && !core_valid && core_errors==0 && commands==count_before,"stopped native clock leaves observable busy");
        run_bank=1;await_done();check(core_valid && commands==count_before+1,"resume clock completes one request");

        reset_case();send(2,0,0);
        @(negedge core_clk);core_cmd_valid=1;ct();@(negedge core_clk);core_cmd_valid=0;await_done();
        check(core_errors[0] && !core_valid,"second command while busy fails closed");

        reset_case();send(1,4,2);await_done();seq_before=core_sequence;
        @(negedge core_clk);bank_reset_n=0;#1;bank_reset_n=1;
        repeat(15)ct();check(core_errors[1] && epoch_window && !core_valid && !armed && core_sequence==seq_before,"brief native reset poisons active lineage");

        reset_case();send(2,0,0);await_done();seq_before=core_sequence;
        @(negedge core_clk);bank_reset_n=0;#1;bank_reset_n=1;repeat(15)ct();
        check(core_ready && !core_valid && core_errors==0 && core_sequence==seq_before,"idle reset invalidates snapshot without sequence rewind");
        send(2,0,0);await_done();check(core_valid && core_sequence==seq_before+1,"new explicit request after idle reset");

        reset_case();@(negedge bank_clk);run_bank=0;send(1,4,3);
        @(negedge core_clk);core_reset_n=0;repeat(3)ct();@(negedge core_clk);core_reset_n=1;run_bank=1;count_before=commands;
        repeat(18)ct();check(core_ready && !armed && !core_valid && commands==count_before && core_sequence==0,"core reset does not replay pending ARM");

        reset_case();@(negedge core_clk);dma_write_attempt=1;
        send(1,4,4);@(negedge core_clk);dma_write_attempt=0;await_done();repeat(5)ct();
        check(core_errors[2] && !core_valid && errors[5],"DMA contamination from ARM enqueue edge");

        reset_case();send(1,4,0);await_done();check(response_error && !core_valid && !response_armed,"native rejected ARM is not success");
        repeat(4)ct();check(core_errors[3],"native error visible in live core status");

        if(SEQ_BITS==8)begin
            reset_case();repeat(255)begin send(2,0,0);await_done();end
            check(core_sequence==255 && core_valid,"sequence reaches maximum");send(2,0,0);await_done();
            check(core_errors[4] && core_sequence==255 && !core_valid,"sequence overflow never wraps or validates");
        end
        $display("MAILBOX TEST PASSED seq_bits=%0d cases=%0d checks=%0d native_commands=%0d",SEQ_BITS,cases,checks,commands);$finish;
    end
    initial begin #200000; $fatal(1,"mailbox test timeout");end
endmodule

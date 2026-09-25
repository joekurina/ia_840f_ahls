`timescale 1ns/1ps
module completion_tb;
    logic clk=0,reset_n=0,start=0,producer_done=0,access_fault=0,dma_write_attempt=0;
    logic aw_fire=0,w_fire=0,wlast=0,b_fire=0;
    logic [32:0] expected_bytes=0;
    logic [4:0] awlen=0;
    logic [63:0] wstrb=0;
    logic [1:0] bresp=0;
    wire busy,done;
    wire [7:0] errors;
    wire [32:0] accepted_bytes;
    int checks=0,cases=0;
    always #5 clk=~clk;
    ia840f_ahls_completion dut(.*);
    task automatic check(input logic ok,input string message);
        checks++;
        if(ok!==1'b1) $fatal(1,"COMPLETION_FAIL %s errors=%h busy=%b done=%b",message,errors,busy,done);
    endtask
    task automatic tick;
        @(posedge clk);#1;@(negedge clk);
    endtask
    task automatic clear;
        reset_n=0;start=0;producer_done=0;access_fault=0;dma_write_attempt=0;
        aw_fire=0;w_fire=0;b_fire=0;wstrb=0;wlast=0;bresp=0;
        repeat(3)tick();reset_n=1;tick();
        check(!busy && !done && errors==0,"reset clears completion");
    endtask
    task automatic launch(input logic[32:0] bytes);
        expected_bytes=bytes;start=1;tick();start=0;tick();
    endtask
    task automatic request(input logic[4:0] len);
        awlen=len;aw_fire=1;tick();aw_fire=0;tick();
    endtask
    task automatic data_beat(input logic[63:0] mask,input logic last);
        wstrb=mask;wlast=last;w_fire=1;tick();w_fire=0;tick();
    endtask
    task automatic response(input logic[1:0] resp);
        bresp=resp;b_fire=1;tick();b_fire=0;tick();
    endtask
    task automatic producer;
        producer_done=1;tick();producer_done=0;tick();
    endtask
    task automatic expect_pending(input string message);
        repeat(8)begin tick();check(busy && !done && errors==0,message);end
    endtask
    initial begin
        @(negedge clk);clear();
        launch(36);producer();expect_pending("raw HLS done before first AW is not complete");
        request(0);data_beat(64'hffffffff,1);response(0);
        expect_pending("first partial output response leaves final bytes pending");
        request(0);expect_pending("delayed final W prevents completion");
        data_beat(64'h0000000f00000000,1);
        expect_pending("delayed final B prevents completion");
        response(0);repeat(4)tick();check(done && !busy && errors==0 && accepted_bytes==36,"complete partial output retires");cases++;

        // No reset between successful invocations; fresh start clears old done.
        launch(64);check(busy && !done && accepted_bytes==0,"new invocation is fresh");
        request(0);data_beat(~64'd0,1);response(0);
        expect_pending("memory completion alone is not producer completion");
        producer();repeat(4)tick();check(done && errors==0,"second invocation complete");cases++;

        clear();launch(128);request(1);data_beat(~64'd0,0);producer();
        expect_pending("last burst beat missing");data_beat(~64'd0,1);response(0);
        repeat(4)tick();check(done && errors==0,"multi-beat burst");cases++;

        clear();launch(4);request(0);data_beat(15,1);producer();response(2);
        repeat(4)tick();check(!done && busy && errors[1],"B error cannot publish success");cases++;
        clear();launch(4);producer();response(0);
        check(!done && errors[2],"uncredited B rejected");cases++;
        clear();launch(4);request(0);data_beat(255,1);producer();response(0);
        repeat(4)tick();check(!done && errors[3],"excess enabled bytes rejected");cases++;
        clear();launch(4);request(0);data_beat(15,1);producer();
        b_fire=1;bresp=0;access_fault=1;tick();b_fire=0;access_fault=0;
        repeat(4)tick();check(!done && errors[0],"same-edge access fault dominates retirement");cases++;
        clear();launch(4);dma_write_attempt=1;tick();dma_write_attempt=0;
        check(errors[0] && !done,"DMA contamination rejected");cases++;
        clear();launch(4);start=1;tick();start=0;
        check(errors[5] && !done,"busy restart rejected");cases++;
        clear();launch(0);check(!done && errors[6],"empty extent rejected");cases++;
        clear();launch(4);request(0);data_beat(15,1);clear();
        check(!busy && !done && accepted_bytes==0,"reset cancels pending state, never produces completion");cases++;
        $display("COMPLETION_UNIT_PASS cases=%0d checks=%0d",cases,checks);$finish;
    end
    initial begin #100000;$fatal(1,"COMPLETION_FAIL watchdog");end
endmodule

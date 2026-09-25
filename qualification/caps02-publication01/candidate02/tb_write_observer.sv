`timescale 1ns/1ps
module tb_write_observer #(parameter integer TEST_BITS=8);
    reg clk=0;
    always #5 clk=~clk;
    reg rst_n=0, awvalid=0, awready=0, wvalid=0, wready=0;
    reg bvalid=0, bready=0, wlast=0, cmd_valid=0;
    reg [7:0] awlen=0;
    reg [8:0] awid=0, bid=0;
    reg [63:0] wstrb=0, cmd_expected=0, cmd_token=0;
    reg [1:0] bresp=0, cmd=0;
    reg dma_write_fault=0, link_fault=0;
    wire armed, empty, target_retired, cmd_ack;
    wire [7:0] errors;
    wire [63:0] first_error, token, expected_bytes, baseline;
    wire [63:0] aw_total,b_total,expected_w_beats,w_total,wlast_total;
    wire [63:0] accepted_bytes,retired_bytes;
    integer cases=0, checks=0;
    ia840f_ahls_write_observer #(.COUNTER_BITS(TEST_BITS)) dut(.*);

    task tick;
        begin @(posedge clk); #1; end
    endtask
    task check(input condition,input [639:0] label_text);
        begin
            checks=checks+1;
            if(condition !== 1'b1) $fatal(1,"CHECK %0s errors=%h A=%0d B=%0d Q=%0d W=%0d L=%0d T=%0d C=%0d",label_text,errors,aw_total,b_total,expected_w_beats,w_total,wlast_total,accepted_bytes,retired_bytes);
        end
    endtask
    task idle;
        begin awvalid=0;awready=0;wvalid=0;wready=0;bvalid=0;bready=0;cmd_valid=0; end
    endtask
    task reset_case;
        begin
            @(negedge clk);idle();rst_n=0;dma_write_fault=0;link_fault=0;
            bresp=0;bid=0;awid=0;wstrb=0;wlast=0;awlen=0;tick();
            @(negedge clk);rst_n=1;tick();
            check(!armed && !target_retired && errors==0 && accepted_bytes==0,"reset invalidates prior epoch");
            cases=cases+1;
        end
    endtask
    task command(input [1:0] operation,input [63:0] amount,input [63:0] tag);
        begin
            @(negedge clk);idle();cmd_valid=1;cmd=operation;cmd_expected=amount;cmd_token=tag;
            tick();check(cmd_ack,"command acknowledgement");
            @(negedge clk);idle();tick();check(!cmd_ack,"acknowledgement pulse");
        end
    endtask
    task aw(input [7:0] length);
        begin @(negedge clk);idle();awvalid=1;awready=1;awlen=length;tick();@(negedge clk);idle(); end
    endtask
    task w(input [63:0] mask,input last);
        begin @(negedge clk);idle();wvalid=1;wready=1;wstrb=mask;wlast=last;tick();@(negedge clk);idle(); end
    endtask
    task b(input [1:0] response);
        begin @(negedge clk);idle();bvalid=1;bready=1;bresp=response;tick();@(negedge clk);idle(); end
    endtask

    initial begin
        reset_case(); command(1,36,1); check(armed && empty && !target_retired,"empty upstream pipeline is not retirement");
        repeat(5) tick();check(!target_retired,"elapsed clocks are not a fence");
        aw(1); w(64'hffffffff,0);check(!target_retired,"final data delayed");
        repeat(3) tick(); w(64'hf00000000,1);
        check(accepted_bytes==36 && retired_bytes==0 && !target_retired,"bit5 partial tail needs final B");
        repeat(3) tick(); b(0);check(target_retired && retired_bytes==36,"all36 enabled bytes retired");
        command(2,0,0);check(target_retired,"snapshot command preserves epoch");
        command(3,0,0);check(!armed && !target_retired,"release is not persistent success");
        command(1,4,2);check(armed && baseline==36,"next token takes clean cumulative baseline");
        aw(0);w(64'hf,1);b(0);check(target_retired && retired_bytes==40,"second epoch relative totals");

        reset_case();command(1,68,3);aw(0);w(~64'd0,1);b(0);
        check(empty && retired_bytes==64 && !target_retired,"split fragment is not all output");
        aw(0);w(64'hf,1);b(0);check(target_retired && aw_total==2 && b_total==2,"both native fragments retire");

        reset_case();command(1,4,4);w(64'hf,1);
        check(errors==0 && !empty && !target_retired,"W before AW allowed");
        aw(0);b(0);check(target_retired,"W before AW accounted");

        reset_case();command(1,4,5);
        @(negedge clk);idle();awvalid=1;awready=1;awlen=0;wvalid=1;wready=1;wlast=1;wstrb=15;bvalid=1;bready=1;
        tick();check(target_retired && retired_bytes==4,"simultaneous AW W B next-state accounting");
        @(negedge clk);idle();

        reset_case();command(1,68,6);aw(0);w(~64'd0,1);b(2);
        check(errors[0] && first_error[7:0]==1 && first_error[9:8]==2 && !target_retired,"early hidden split-B error sticky");
        aw(0);w(15,1);b(0);check(!target_retired && retired_bytes==0,"later OKAY cannot erase error");

        reset_case();command(1,4,7);bid=1;aw(0);w(15,1);b(0);
        check(errors[1] && !target_retired,"unexpected native BID");
        reset_case();awid=1;aw(0);check(errors[1],"unexpected native AWID");

        reset_case();b(0);check(errors[2] && first_error[7:0]==3,"uncredited B");
        reset_case();command(1,4,8);aw(0);w(255,1);b(0);check(errors[4] && !target_retired,"enabled byte excess");
        reset_case();command(1,4,9);dma_write_fault=1;tick();
        check(errors[5] && !target_retired,"DMA epoch contamination");
        reset_case();command(1,4,10);link_fault=1;tick();check(errors[6] && !target_retired,"link loss");
        reset_case();command(1,4,11);command(3,0,0);check(errors[7] && armed,"premature release rejected");
        reset_case();command(1,3,12);check(errors[7] && !armed,"invalid expected volume");
        reset_case();command(1,4,0);check(errors[7] && !armed,"zero token rejected");
        reset_case();command(1,4,13);aw(0);w(15,1);b(0);command(3,0,0);command(1,4,13);
        check(errors[7] && !armed,"previous token cannot replay");

        reset_case();
        @(negedge clk);cmd_valid=1;cmd=1;cmd_expected=4;cmd_token=14;awvalid=1;awready=0;
        tick();check(errors[7] && !armed,"stalled AW at ARM rejected");
        @(negedge clk);idle();

        if(TEST_BITS==8) begin
        reset_case();aw(255);check(errors[3] && expected_w_beats==255,"beat-total saturation");
        reset_case();repeat(4) begin aw(0);w(~64'd0,1);b(0);end
        check(errors[3] && accepted_bytes==255 && retired_bytes==192,"byte overflow cannot advance retirement");
        reset_case();repeat(256) begin aw(0);w(0,1);b(0);end
        check(errors[3] && aw_total==255 && w_total==255 && b_total==255,"transaction counters saturate");
        end

        reset_case();command(1,4,15);aw(0);w(15,1);
        @(negedge clk);bvalid=1;bready=0;bresp=2;tick();check(errors==0 && !target_retired,"B held before handshake");
        @(negedge clk);bready=1;tick();check(errors[0] && !target_retired,"accepted error dominates target");
        reset_case();check(!armed && !target_retired && token==0,"reset never preserves completion");
        reset_case();command(0,0,0);check(errors[7],"unknown command rejected");
        reset_case();command(1,4,16);command(1,4,17);check(errors[7] && token==16 && armed,"rearm rejected without changing epoch");
        reset_case();aw(0);b(0);check(errors[2],"B before WLAST rejected");
        reset_case();command(1,4,18);aw(0);w(15,1);b(1);check(errors[0],"EXOKAY rejected by bound profile");
        reset_case();command(1,4,19);aw(0);w(15,1);b(3);check(errors[0],"DECERR poisons epoch");
        bid=1;b(0);check(first_error[7:0]==1 && first_error[9:8]==3,"first error stable after later fault");
        $display("OBSERVER TEST PASSED width=%0d cases=%0d checks=%0d",TEST_BITS,cases,checks);
        $finish;
    end
    initial begin #100000; $fatal(1,"test timeout"); end
endmodule

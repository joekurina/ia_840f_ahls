`timescale 1ns/1ps
// Direct mailbox protocol fixture. Bank ACK/data are explicit test inputs,
// not a model of a memory controller or evidence of physical CDC timing.
module tb_staging127;
    reg core_clk=0,bank_clk=0,run_core=1,run_bank=1;
    always #5 if(run_core) core_clk=~core_clk; else core_clk=0;
    always #7 if(run_bank) bank_clk=~bank_clk; else bank_clk=0;
    reg core_reset_n=0,bank_reset_n=0,core_cmd_valid=0;
    reg [1:0] core_cmd=0;
    reg [63:0] core_expected=0,core_token=0;
    reg dma_write_attempt=0,local_fault=0;
    wire core_ready,core_busy,core_valid,core_done,epoch_window;
    wire [7:0] core_errors;
    wire [63:0] core_sequence;
    wire [31:0] core_snapshot;
    wire response_armed,response_error,bank_link_reset_n,bank_cmd_valid,bank_dma_fault;
    wire [1:0] bank_cmd;
    wire [63:0] bank_expected,bank_token;
    reg bank_cmd_ack=0,bank_error=0,bank_armed=0;
    reg [31:0] bank_snapshot=0;
    integer checks=0,cases=0,commands=0,completions=0;
    integer req_installs=0,req_publications=0,rsp_installs=0,rsp_publications=0;
    integer req_cancellations=0,rsp_cancellations=0;
    integer stopped_request_hits=0,stopped_response_hits=0,held_ack_hits=0;
    integer local_fault_hits=0,busy_fault_hits=0,dma_fault_hits=0,release_fault_hits=0;
    reg [129:0] expected_request;
    reg [31:0] expected_response;
    integer command_before,completion_before;

    ia840f_ahls_observer_mailbox_timing126 #(.SNAP_BITS(32),.SEQ_BITS(64)) box(
        .core_clk(core_clk),.core_reset_n(core_reset_n),.bank_clk(bank_clk),.bank_reset_n(bank_reset_n),
        .core_cmd_valid(core_cmd_valid),.core_cmd(core_cmd),.core_expected(core_expected),.core_token(core_token),
        .dma_write_attempt(dma_write_attempt),.core_access_fault(local_fault),
        .core_ready(core_ready),.core_busy(core_busy),.core_valid(core_valid),.core_done(core_done),
        .core_errors(core_errors),.epoch_window(epoch_window),.core_sequence(core_sequence),
        .core_snapshot(core_snapshot),.response_armed(response_armed),.response_error(response_error),
        .bank_link_reset_n(bank_link_reset_n),.bank_cmd_valid(bank_cmd_valid),.bank_cmd(bank_cmd),
        .bank_expected(bank_expected),.bank_token(bank_token),.bank_dma_fault(bank_dma_fault),
        .bank_cmd_ack(bank_cmd_ack),.bank_snapshot(bank_snapshot),.bank_error(bank_error),.bank_armed(bank_armed));

    task check(input good,input [1023:0] label_text);
        begin
            checks=checks+1;
            if(good!==1'b1)$fatal(1,"CHECK %0s time=%0t errors=%h busy=%b valid=%b",label_text,$time,core_errors,core_busy,core_valid);
        end
    endtask
    task cc;begin @(posedge core_clk);#1;end endtask
    task bc;begin @(posedge bank_clk);#1;end endtask

    reg c_pending,c_accept,c_toggle;
    reg [129:0] c_hold,c_new;
    always @(posedge core_clk) begin
        if(box.core_link_reset_n) begin
            c_pending=box.request_pending;c_accept=core_cmd_valid && core_ready;
            c_toggle=box.request_toggle;c_hold=box.request_hold;c_new={core_cmd,core_expected,core_token};
            if(c_pending)check(!box.source_complete,"F_PENDING_GUARD");
            #1;
            if(box.core_link_reset_n) begin
                if(c_accept) begin
                    check(box.request_pending && box.request_toggle===c_toggle,"F_REQUEST_EARLY");
                    check(box.request_hold===c_new && core_busy && !core_valid && !core_done,"request installation owns busy");
                    req_installs=req_installs+1;
                end
                if(c_pending) begin
                    check(!box.request_pending && box.request_toggle!==c_toggle,"request publishes next source edge");
                    check(box.request_hold===c_hold && core_busy && !core_done,"request stable through publication");
                    req_publications=req_publications+1;
                end
                if(!c_accept && !c_pending)check(box.request_toggle===c_toggle,"no spontaneous request toggle");
                if(core_done)completions=completions+1;
            end
        end
    end
    reg b_pending,b_install,b_toggle;
    reg [31:0] b_hold,b_new;
    reg b_arm,b_error;
    always @(posedge bank_clk) begin
        if(bank_link_reset_n) begin
            if(bank_cmd_valid)commands=commands+1;
            b_pending=box.response_pending;
            b_install=box.waiting_bank_ack && bank_cmd_ack && !box.response_pending;
            b_toggle=box.ack_toggle;b_hold=box.response_hold;
            b_new=bank_snapshot;b_arm=bank_armed;b_error=bank_error;
            #1;
            if(bank_link_reset_n) begin
                if(b_install) begin
                    check(box.response_pending && box.ack_toggle===b_toggle,"F_RESPONSE_EARLY");
                    check(box.waiting_bank_ack && box.response_hold===b_new && box.return_armed===b_arm && box.return_error===b_error,"complete response installed with ownership");
                    rsp_installs=rsp_installs+1;
                end
                if(b_pending) begin
                    check(!box.response_pending && !box.waiting_bank_ack && box.ack_toggle!==b_toggle,"response publishes next source edge");
                    check(box.response_hold===b_hold,"response not recaptured at publication");
                    rsp_publications=rsp_publications+1;
                end
                if(!b_install && !b_pending)check(box.ack_toggle===b_toggle,"no spontaneous ack toggle");
            end
        end
    end

    task reset_case;
        integer j;
        begin
            run_core=1;run_bank=1;
            @(negedge core_clk);core_reset_n=0;bank_reset_n=0;core_cmd_valid=0;
            dma_write_attempt=0;local_fault=0;bank_cmd_ack=0;bank_error=0;bank_armed=0;
            repeat(3)cc();@(negedge core_clk);core_reset_n=1;bank_reset_n=1;
            j=0;while(!core_ready && j<100)begin cc();j=j+1;end
            check(j<100 && !core_busy && !core_valid && core_sequence==0,"fresh case ready");
            cases=cases+1;command_before=commands;completion_before=completions;
        end
    endtask
    task send(input [1:0] op,input [63:0] amount,input [63:0] tag);
        begin
            @(negedge core_clk);check(core_ready,"source ready before request");
            core_cmd=op;core_expected=amount;core_token=tag;core_cmd_valid=1;
            expected_request={op,amount,tag};cc();
            check(core_busy && box.request_pending && !core_done,"pending state visible after acceptance");
            @(negedge core_clk);core_cmd_valid=0;
        end
    endtask
    task bank_wait;
        integer j;
        begin
            j=0;while(!bank_cmd_valid && j<100)begin bc();j=j+1;end
            check(j<100 && {bank_cmd,bank_expected,bank_token}===expected_request,"one coherent bank request");
        end
    endtask
    task response_install(input [31:0] data,input arm,input err);
        begin
            @(negedge bank_clk);bank_snapshot=data;bank_armed=arm;bank_error=err;bank_cmd_ack=1;
            expected_response=data;bc();
            check(box.response_pending && box.waiting_bank_ack,"response pending before ACK publication");
        end
    endtask
    task response_finish;
        begin
            @(negedge bank_clk);bank_cmd_ack=0;bc();
            check(!box.response_pending && !box.waiting_bank_ack,"response notification published");
        end
    endtask
    task done_wait;
        integer j;
        begin
            j=0;while(core_busy && j<100)begin cc();j=j+1;end
            check(j<100 && core_snapshot===expected_response,"coherent core response");
            cc();@(negedge core_clk);
        end
    endtask
    task healthy_reply(input [31:0] data,input arm);
        begin bank_wait();response_install(data,arm,0);response_finish();done_wait();end
    endtask

    initial begin
        // Full-width request signatures, immutable response, held ACK.
        reset_case();send(2,64'hF1234567_89ABCDEF,64'h81234567_FEDCBA98);
        core_expected=0;core_token=0;bank_wait();response_install(32'hCAFE8712,0,0);
        @(negedge bank_clk);bank_snapshot=32'h11335577;bank_armed=1;
        repeat(3)bc();held_ack_hits=held_ack_hits+1;
        check(box.response_hold===32'hCAFE8712 && !box.return_armed && !box.return_error,"held ACK cannot recapture payload or flags");
        @(negedge bank_clk);bank_cmd_ack=0;done_wait();
        check(core_valid && !response_armed && !response_error && core_sequence==1,"clean response values");
        check(commands==command_before+1 && completions==completion_before+1,"one command and completion");

        // Paused source while its request notification is pending.
        reset_case();send(2,64'h10203040_50607080,64'h88776655_44332211);
        run_core=0;repeat(6)bc();
        check(box.request_pending && core_busy && !core_valid && !bank_cmd_valid && commands==command_before,"stopped source preserves unpublished request");
        stopped_request_hits=stopped_request_hits+1;run_core=1;
        healthy_reply(32'hA1239876,0);check(core_valid && core_sequence==1,"resumed source completes once");

        // Paused bank after payload installation, before ACK notification.
        reset_case();send(2,7,64'hB4561234);bank_wait();response_install(32'hAABBCCDD,1,0);
        @(negedge bank_clk);run_bank=0;bank_cmd_ack=0;bank_snapshot=32'hDEAD1234;bank_armed=0;
        repeat(8)cc();
        check(box.response_pending && box.waiting_bank_ack && core_busy && !core_valid && box.response_hold===32'hAABBCCDD && box.return_armed,"stopped bank holds unacknowledged response");
        stopped_response_hits=stopped_response_hits+1;run_bank=1;bc();done_wait();
        check(core_valid && response_armed && !response_error && core_sequence==1,"resumed ACK installs old complete response");

        // Bank reset cancels an unpublished ARM and poisons its active history.
        reset_case();send(1,4,64'h44556677);check(box.request_pending,"request cancellation hit");
        req_cancellations=req_cancellations+1;bank_reset_n=0;repeat(3)cc();
        check(!box.request_pending && !core_busy && !core_valid && core_errors[1] && epoch_window,"bank reset cancels pending request and retains poison");
        @(negedge core_clk);bank_reset_n=1;repeat(15)cc();
        check(commands==command_before && completions==completion_before && core_sequence==0,"canceled request never replays");

        // Core reset cancels an installed but unpublished response.
        reset_case();send(2,8,64'h78563412);bank_wait();response_install(32'hBEEF7890,0,0);
        @(negedge bank_clk);check(box.response_pending,"response cancellation hit");
        rsp_cancellations=rsp_cancellations+1;core_reset_n=0;bank_cmd_ack=0;repeat(3)cc();
        @(negedge core_clk);core_reset_n=1;repeat(15)cc();
        check(!box.response_pending && !core_busy && !core_valid && core_ready && core_sequence==0,"core reset cancels pending response");
        check(commands==command_before+1 && completions==completion_before,"canceled ACK never completes or replays");

        // A local CSR fault on request publication remains sticky.
        reset_case();send(2,16,64'h23456789);local_fault=1;cc();
        check(core_errors[0] && core_busy && !core_done,"local fault at request publication");
        local_fault_hits=local_fault_hits+1;@(negedge core_clk);local_fault=0;
        healthy_reply(32'h1A2B3C4D,0);check(!core_valid && core_errors[0] && core_sequence==1,"local fault poisons eventual completion");

        // Rejected input at request publication cannot replace the held request.
        reset_case();send(2,64'h12345678_9ABCDEF0,64'h55AA99CC_77883322);
        core_cmd_valid=1;core_cmd=3;core_expected=0;core_token=0;cc();
        check(core_errors[0] && core_busy && box.request_hold===expected_request,"busy input cannot overwrite pending payload");
        busy_fault_hits=busy_fault_hits+1;@(negedge core_clk);core_cmd_valid=0;
        healthy_reply(32'h76543210,0);check(!core_valid && core_sequence==1,"busy rejection poisons completion");

        // DMA attempt precisely on the delayed ARM-notification edge.
        reset_case();send(1,4,64'hFA123456);dma_write_attempt=1;cc();
        check(core_errors[2] && epoch_window && core_busy,"DMA notification-edge contamination");
        dma_fault_hits=dma_fault_hits+1;@(negedge core_clk);dma_write_attempt=0;
        healthy_reply(32'hCAFEBABE,1);check(!core_valid && epoch_window && core_sequence==1,"contaminated ARM cannot validate");

        // Held return_error is preserved after the external error input clears.
        reset_case();send(2,12,64'hBBAA0099);bank_wait();response_install(32'h456789AB,1,1);
        @(negedge bank_clk);bank_snapshot=0;bank_armed=0;bank_error=0;bank_cmd_ack=0;
        bc();done_wait();
        check(response_error && response_armed && core_errors[3] && !core_valid,"captured sidecar error dominates newer inputs");

        // Fault coincident with RELEASE installation retains epoch monitoring.
        reset_case();send(1,4,64'h99112233);healthy_reply(32'h2468ACE0,1);
        check(core_valid && epoch_window && core_sequence==1,"ARM before RELEASE fault");
        send(3,0,0);bank_wait();response_install(32'h13579BDF,0,0);response_finish();
        while(!box.source_complete)cc();
        @(negedge core_clk);core_cmd_valid=1;cc();
        check(core_errors[0] && !core_valid && !core_busy && epoch_window && core_sequence==2,"same-edge rejected RELEASE retains epoch");
        release_fault_hits=release_fault_hits+1;
        @(negedge core_clk);core_cmd_valid=0;dma_write_attempt=1;cc();
        @(negedge core_clk);dma_write_attempt=0;
        check(core_errors[2] && epoch_window,"retained epoch catches later DMA");
        repeat(3)cc();

        check(req_installs==req_publications+req_cancellations && req_cancellations==1,"all request installations published or deliberately canceled");
        check(rsp_installs==rsp_publications+rsp_cancellations && rsp_cancellations==1,"all response installations published or deliberately canceled");
        check(req_publications>=10 && rsp_publications>=9 && held_ack_hits==1 && stopped_request_hits==1 && stopped_response_hits==1,"nonempty phase coverage");
        check(local_fault_hits==1 && busy_fault_hits==1 && dma_fault_hits==1 && release_fault_hits==1,"nonempty fault-edge coverage");
        $display("STAGING TEST PASSED cases=%0d checks=%0d req_install=%0d req_publish=%0d req_cancel=%0d rsp_install=%0d rsp_publish=%0d rsp_cancel=%0d commands=%0d completions=%0d",cases,checks,req_installs,req_publications,req_cancellations,rsp_installs,rsp_publications,rsp_cancellations,commands,completions);
        $finish;
    end
    initial begin #200000; $fatal(1,"staging test timeout");end
endmodule

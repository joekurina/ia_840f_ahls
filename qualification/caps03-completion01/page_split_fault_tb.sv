// Focused actual page-split/PIM/CDC test. Synthetic AXI source/sink, no HLS claim.
`timescale 1ns/1ps
`include "ofs_plat_if.vh"
module page_split_fault_tb;
    logic clk=0,bank_clk=0,reset_n=0;
    always #5 clk=~clk;
    always #11 bank_clk=~bank_clk;
    logic completion_start=0,producer_done=0;
    wire completion_busy,completion_done;
    wire [7:0] completion_errors;
    wire [32:0] accepted_bytes;
    ofs_plat_axi_mem_if #(.ADDR_WIDTH(34),.DATA_WIDTH(512),.BURST_CNT_WIDTH(8),
        .RID_WIDTH(18),.WID_WIDTH(18),.USER_WIDTH(2)) source_mem();
    ofs_plat_axi_mem_if #(.ADDR_WIDTH(34),.DATA_WIDTH(512),.BURST_CNT_WIDTH(8),
        .RID_WIDTH(9),.WID_WIDTH(9),.USER_WIDTH(1)) physical();
    assign physical.clk=bank_clk;assign physical.reset_n=reset_n;assign physical.instance_number=1;
    ia840f_ahls_memory_bank_completion_shim shim(
        .afu_clk(clk),.afu_reset_n(reset_n),.to_fiu(physical),.to_afu(source_mem),
        .completion_start(completion_start),.producer_done(producer_done),
        .access_fault(1'b0),.dma_write_attempt(1'b0),.expected_bytes(33'd256),
        .completion_busy(completion_busy),.completion_done(completion_done),
        .completion_errors(completion_errors),.accepted_bytes(accepted_bytes));
    int aw_count=0,w_count=0,b_count=0,source_b_count=0,split_error_count=0;
    int remaining=0,delay_b=0,cycle=0;
    logic pending_b=0;
    logic [8:0] saved_id;
    logic [1:0] saved_resp;
    assign physical.awready=reset_n && remaining==0 && !pending_b && !physical.bvalid;
    assign physical.wready=reset_n && remaining!=0 && cycle%5!=0;
    assign physical.arready=reset_n;
    initial begin physical.bvalid=0;physical.b='0;physical.rvalid=0;physical.r='0;end
    always @(posedge bank_clk)begin
        cycle<=cycle+1;
        if(reset_n)begin
            if(physical.arvalid)$fatal(1,"unexpected AR in split-error test");
            if(physical.awvalid && physical.awready)begin
                if(aw_count==0 && (physical.aw.addr!=34'hfc0 || physical.aw.len!=0))$fatal(1,"first split segment");
                if(aw_count==1 && (physical.aw.addr!=34'h1000 || physical.aw.len!=2))$fatal(1,"second split segment");
                if(aw_count>1 || physical.aw.size!=6)$fatal(1,"extra or narrow AW");
                remaining<=int'(physical.aw.len)+1;saved_id<=physical.aw.id;
                saved_resp<=aw_count==0 ? 2'b10 : 2'b00;aw_count<=aw_count+1;
            end
            if(physical.wvalid && physical.wready)begin
                if(physical.w.last!==(remaining==1) || physical.w.strb!==~64'd0)$fatal(1,"split W shape");
                remaining<=remaining-1;w_count<=w_count+1;
                if(remaining==1)begin pending_b<=1;delay_b<=25;end
            end
            if(pending_b)begin
                if(delay_b!=0)delay_b<=delay_b-1;
                else begin
                    physical.b='0;physical.b.id=saved_id;physical.b.resp=saved_resp;
                    physical.bvalid<=1;pending_b<=0;
                end
            end
            if(physical.bvalid && physical.bready)begin physical.bvalid<=0;b_count<=b_count+1;end
        end
    end
    always @(posedge clk)if(reset_n)begin
        if(source_mem.bvalid && source_mem.bready)source_b_count++;
        if(shim.page_limited.bvalid && shim.page_limited.bready && shim.page_limited.b.resp!=0 &&
           shim.page_limited.b.user[ofs_plat_local_mem_axi_mem_pkg::LM_AXI_UFLAG_NO_REPLY])split_error_count++;
        if(completion_done)$fatal(1,"intermediate error published success");
    end
    initial begin
        source_mem.aw='0;source_mem.awvalid=0;source_mem.w='0;source_mem.wvalid=0;source_mem.bready=1;
        source_mem.ar='0;source_mem.arvalid=0;source_mem.rready=1;
        repeat(100)@(negedge clk);reset_n=1;repeat(100)@(negedge clk);
        completion_start=1;@(negedge clk);completion_start=0;producer_done=1;
        @(negedge clk);producer_done=0;
        source_mem.aw.addr=34'hfc0;source_mem.aw.len=3;source_mem.aw.size=6;source_mem.aw.burst=1;
        source_mem.aw.id=18'h12345;source_mem.awvalid=1;
        do @(posedge clk);while(!source_mem.awready);
        @(negedge clk);source_mem.awvalid=0;
        for(int i=0;i<4;i++)begin
            source_mem.w.data={16{32'(i)}};source_mem.w.strb='1;source_mem.w.last=i==3;source_mem.wvalid=1;
            do @(posedge clk);while(!source_mem.wready);
            @(negedge clk);source_mem.wvalid=0;
        end
        for(int t=0;t<10000;t++)begin
            @(negedge clk);
            if(source_b_count==1 && completion_errors[1] && accepted_bytes==256)break;
        end
        if(aw_count!=2 || w_count!=4 || b_count!=2 || source_b_count!=1 || split_error_count!=1 ||
           !completion_errors[1] || completion_done || !completion_busy || accepted_bytes!=256)
            $fatal(1,"split-error coverage AW=%0d W=%0d B=%0d sourceB=%0d split_error=%0d errors=%h bytes=%0d",aw_count,w_count,b_count,source_b_count,split_error_count,completion_errors,accepted_bytes);
        $display("PAGE_SPLIT_ERROR_PASS native_AW=2 native_W=4 native_B=2 upstream_B=1 observed_split_errors=1");
        $finish;
    end
    initial begin #1000000;$fatal(1,"split-error watchdog");end
endmodule

`timescale 1ns/1ps
// Full writer W-channel test with independent AW/W backpressure and a
// synthetic first-word-fall-through FIFO with explicit empty intervals.
// B sink exercises delayed/missing/error/protocol-fault replies. Writer-local
// retirement only: no real FIFO, PIM/PCIe/DDR visibility or system reset proof.
module write_response_tb;
  import dma_pkg::*;
  logic clk=0;
  always #5 clk=~clk;
  logic reset_n=0, descriptor_fifo_not_empty=0, wr_fsm_done;
  t_dma_descriptor descriptor;
  t_dma_csr_control control;
  t_dma_csr_status status;
  ofs_plat_axi_mem_if #(.ADDR_WIDTH(57),.DATA_WIDTH(512),.BURST_CNT_WIDTH(8)) mem();
  dma_fifo_if #(.DATA_W(514)) fifo();
  assign mem.clk=clk;
  assign mem.reset_n=reset_n;
  dma_write_engine #(.DATA_W(514)) dut(
    .clk,.reset_n,.wr_fsm_done,.descriptor_fifo_not_empty,.descriptor,
    .wr_dest_status(status),.csr_control(control),.dest_mem(mem),.rd_fifo_if(fifo));

  int lengths[16]='{513,1,1025,257,769,513,769,257,513,512,1024,256,63,2,1025,1};
  int patterns[16]='{0,1,2,3,0,1,2,3,0,1,2,3,0,1,2,3};
  int checks=0,cycles=0,cases_done=0,total_aw=0,total_w=0,stalls=0;
  int wstalls=0,fifo_gaps=0,total_b=0,success_cases=0,error_cases=0,held_cases=0,aw_b_overlap=0,consecutive_cases=0;
  int only_case=-1;

  task automatic require_ok(input bit condition,input string reason);
    checks++;
    if(!condition) $fatal(1,"WRITE_RESPONSE_FAIL cycle=%0d %s",cycles,reason);
  endtask
  function automatic logic [511:0] payload(input logic [56:0] addr);
    logic [511:0] d;
    for(int j=0;j<8;j++) d[j*64+:64]={7'b0,addr}^(64'hd1b54a32d192ed03*(j+1));
    return d;
  endfunction

  task automatic run_case(input int case_id,input int length,input int pattern);
    logic [56:0] base_addr;
    logic [mem.T_AW_WIDTH-1:0] saved_aw;
    logic [mem.T_W_WIDTH-1:0] saved_w;
    int aw_count,w_count,pop_count,announced_beats,expected_bursts,expected_len;
    int phase,age,drop_left,quiet;
    int wpattern,wage,wdrop,last_stalled_index,gap_left,last_gap_index;
    bit previous_wstall,saw_wvalid;
    bit previous_stall,saw_valid,dropped,finished;
    bit expect_error,missing,do_reset,success_seen,stopped_seen,error_b_seen,injected_bad;
    int b_sent,wbursts,done_count,kind,retire_quiet;
    bit can_send;
    base_addr=57'h200004000+case_id*57'h10000+((case_id%2)*57'h240);
    aw_count=0;w_count=0;pop_count=0;announced_beats=0;
    expected_bursts=(length+255)/256;age=0;drop_left=0;quiet=0;
    previous_stall=0;saw_valid=0;dropped=0;finished=0;
    expect_error=(case_id inside {4,5,6,7,8,9,13,14});missing=(case_id==15);
    do_reset=(only_case>=0)||!(case_id inside {1,2,3,11,12});
    b_sent=0;wbursts=0;done_count=0;kind=0;retire_quiet=0;
    success_seen=0;stopped_seen=0;error_b_seen=0;injected_bad=0;
    wpattern=case_id%4;wage=0;wdrop=0;last_stalled_index=-1;gap_left=0;last_gap_index=-1;previous_wstall=0;saw_wvalid=0;
    @(negedge clk);#1;
    reset_n=!do_reset;descriptor='0;control='0;descriptor_fifo_not_empty=0;
    mem.arready=0;mem.rvalid=0;mem.r='0;mem.awready=0;mem.wready=1;
    mem.bvalid=0;mem.b='0;mem.instance_number=0;
    fifo.rd_data='0;fifo.not_empty=0;
    repeat(4) @(posedge clk);
    if(!do_reset)consecutive_cases++;
    @(negedge clk);#1;
    reset_n=1;descriptor.dest_addr=base_addr;descriptor.length=length;
    descriptor.descriptor_control.mode=HOST_TO_DDR;
    descriptor.descriptor_control.go=1;descriptor_fifo_not_empty=1;

    for(phase=0;phase<20000&&!finished;phase++) begin
      @(negedge clk);#1;
      if(wpattern==2&&pop_count>0&&pop_count%256==0&&pop_count<length&&last_gap_index!=pop_count)begin
        gap_left=12;last_gap_index=pop_count;
      end
      fifo.not_empty=(pop_count<length)&&(gap_left==0)&&((wpattern!=3)||(phase%13>=6));
      if(gap_left>0)gap_left--;
      if(mem.wvalid)wage++;else wage=0;
      if((wpattern==1||wpattern==2)&&mem.wvalid&&
         (w_count%256==0||w_count%256==255||w_count==length-1)&&last_stalled_index!=w_count)begin
        wdrop=6;last_stalled_index=w_count;
      end
      case(wpattern)
        0: mem.wready=mem.wvalid&&wage>=4;
        1,2: begin mem.wready=(wdrop==0);if(wdrop>0)wdrop--;end
        3: mem.wready=(phase%11>=7);
      endcase
      // Empty FIFO output is deliberately zero, not a retained end tag.
      fifo.rd_data='0;
      if(success_seen)begin descriptor_fifo_not_empty=0;descriptor.descriptor_control.go=0;end
      if(stopped_seen&&retire_quiet>=2)begin
        control.reset_dispatcher=1;fifo.not_empty=1;
      end
      if(fifo.not_empty&&pop_count<length)
        fifo.rd_data={(pop_count==length-1),((pop_count%256==255)||(pop_count==length-1)),payload(base_addr+pop_count*64)};
      if(mem.awvalid) age++;else age=0;
      if(pattern==1&&mem.awvalid&&!dropped)begin drop_left=6;dropped=1;end
      case(pattern)
        0: mem.awready=mem.awvalid&&age>=4;
        1: begin mem.awready=(drop_left==0);if(drop_left>0)drop_left--;end
        2: mem.awready=1;
        3: mem.awready=(phase%17)>=12;
      endcase
      // Hold B payload until handshake; valid replies follow accepted WLAST.
      if(!mem.bvalid||mem.bready)begin
        mem.bvalid=0;mem.b='0;kind=0;
        if(case_id==8&&!injected_bad&&aw_count>0&&wbursts==0)begin
          mem.bvalid=1;kind=2; // Premature reply cannot discharge AW.
        end else if(case_id==9&&!injected_bad&&b_sent==1&&wbursts==1)begin
          mem.bvalid=1;kind=3; // Duplicate reply, before the next WLAST.
        end else if(!missing&&b_sent<wbursts)begin
          can_send=1;
          if(case_id==0)can_send=(w_count==length&&quiet>=64);
          if((case_id==3||case_id==14)&&b_sent==expected_bursts-1)can_send=(quiet>=64);
          if(case_id==2&&b_sent<expected_bursts-1)can_send=mem.awvalid&&mem.awready;
          if(case_id==10)can_send=(phase%7>=4);
          if(can_send)begin
            mem.bvalid=1;
            if(case_id==7&&!injected_bad)begin mem.b.id=1;kind=1;end
            if((case_id==4&&b_sent==0)||case_id==13)mem.b.resp=SLVERR;
            if((case_id==5||case_id==14)&&b_sent==expected_bursts-1)mem.b.resp=DECERR;
            if(case_id==6&&b_sent==1)mem.b.resp=EXOKAY;
          end
        end
      end
      #1;
      // After a source presents valid, changing ready cannot withdraw it.
      if(pattern==1&&dropped&&drop_left>0)
        require_ok(mem.awvalid===1'b1,"AWVALID followed ready low");
      @(posedge clk);
      cycles++;
      if(previous_wstall)begin
        require_ok(mem.wvalid===1'b1,"WVALID withdrawn while stalled");
        require_ok(mem.w===saved_w,"W payload changed while stalled");
      end
      previous_wstall=mem.wvalid&&!mem.wready;saved_w=mem.w;
      if(previous_wstall)wstalls++;
      if(pop_count<length&&!fifo.not_empty)fifo_gaps++;
      if(mem.wvalid)saw_wvalid=1;
      if(phase==80&&wpattern==0&&aw_count>0)
        require_ok(saw_wvalid,"source waited for WREADY before WVALID");
      require_ok(!$isunknown({mem.awvalid,mem.wvalid,fifo.rd_en}),"unknown control");
      if(previous_stall)begin
        require_ok(mem.awvalid===1'b1,"AWVALID withdrawn while stalled");
        require_ok(mem.aw===saved_aw,"AW payload changed while stalled");
      end
      previous_stall=mem.awvalid&&!mem.awready;saved_aw=mem.aw;
      if(previous_stall)stalls++;
      if(mem.awvalid)saw_valid=1;
      if(phase==24&&pattern==0)require_ok(saw_valid,"source waited for AWREADY before AWVALID");
      if(mem.awvalid&&mem.awready)begin
        expected_len=((length-announced_beats)>256)?256:(length-announced_beats);
        require_ok(aw_count<expected_bursts,"duplicate address request");
        require_ok(mem.aw.addr===base_addr+announced_beats*64,"wrong address");
        require_ok((int'(mem.aw.len)+1)==expected_len,$sformatf("wrong AWLEN case=%0d burst=%0d expected=%0d actual=%0d",case_id,aw_count,expected_len,int'(mem.aw.len)+1));
        require_ok(mem.aw.size==6&&mem.aw.burst==BURST_INCR&&mem.aw.id==0,"wrong size/burst");
        aw_count++;total_aw++;announced_beats+=expected_len;
      end
      if(fifo.rd_en)begin require_ok(fifo.not_empty,"pop from empty input FIFO");pop_count++;end
      if(mem.wvalid&&mem.wready)begin
        require_ok(w_count<length&&w_count<announced_beats,"extra/unaddressed data");
        require_ok(mem.w.data===payload(base_addr+w_count*64),"write payload mismatch");
        require_ok(mem.w.strb==='1,"partial full-beat strobe");
        require_ok(mem.w.last===((w_count%256==255)||(w_count==length-1)),"wrong WLAST");
        if(mem.w.last)wbursts++;
        w_count++;total_w++;
      end
      require_ok(pop_count>=w_count&&pop_count-w_count<=1,"elastic FIFO/pop accounting mismatch");
      if(mem.bvalid&&mem.bready)begin
        total_b++;
        if(mem.awvalid&&mem.awready)aw_b_overlap++;
        if(kind==0)begin
          require_ok(b_sent<wbursts,"test sink returned unearned normal response");
          b_sent++;
        end else injected_bad=1;
        if(kind!=0||mem.b.resp!=OKAY)error_b_seen=1;
      end
      if(wr_fsm_done)begin
        require_ok(!expect_error&&!missing,"done on failed/missing response case");
        require_ok(w_count==length&&aw_count==expected_bursts&&b_sent==expected_bursts,
                   "premature done before response retirement");
        require_ok(!error_b_seen,"error response reported as success");
        done_count++;require_ok(done_count==1,"duplicate done pulse");success_seen=1;
      end
      if(status.stopped_on_error)begin
        require_ok(expect_error&&error_b_seen,"unexpected stopped-on-error");
        require_ok(w_count==length&&b_sent==expected_bursts,"stopped before draining descriptor");
        stopped_seen=1;
      end
      if(w_count==length)quiet++;
      if(quiet>=4&&!success_seen)require_ok(status.busy===1'b1,"lost busy while descriptor retained");
      if(success_seen||stopped_seen)retire_quiet++;
      if(success_seen&&retire_quiet>=3)require_ok(status.busy===1'b0,"busy stuck after successful retirement");
      if(retire_quiet>=10||(missing&&quiet>=128))begin
        require_ok(aw_count==expected_bursts&&pop_count==length,"request/FIFO accounting mismatch");
        require_ok(missing||(b_sent==expected_bursts),"incomplete response count");
        require_ok(!missing||(!wr_fsm_done&&!status.wr_rsp_err&&!status.stopped_on_error),"missing response faked terminal result");
        finished=1;
      end
      #1;
      if(error_b_seen)require_ok(status.wr_rsp_err===1'b1,"response error was not latched");
      else require_ok(status.wr_rsp_err===1'b0,"spurious response error");
    end
    require_ok(finished,$sformatf("unit watchdog case=%0d AW=%0d W=%0d popped=%0d",case_id,aw_count,w_count,pop_count));
    if(expect_error)begin
      require_ok(stopped_seen&&!success_seen&&done_count==0,"error retirement mismatch");error_cases++;
    end else if(missing)begin
      require_ok(!success_seen&&!stopped_seen&&b_sent==0,"missing response escaped wait");held_cases++;
    end else begin
      require_ok(success_seen&&done_count==1,"successful retirement missing");success_cases++;
    end
    cases_done++;
    $display("WRITE_RESPONSE_CASE id=%0d length=%0d requests=%0d beats=%0d credited_B=%0d done=%0d error=%0d held=%0d reset=%0d",case_id,length,aw_count,w_count,b_sent,done_count,stopped_seen,missing,do_reset);
  endtask

  initial begin
    descriptor='0;control='0;mem.arready=0;mem.rvalid=0;mem.r='0;
    mem.awready=0;mem.wready=1;mem.bvalid=0;mem.b='0;mem.instance_number=0;
    fifo.rd_data='0;fifo.not_empty=0;
    if($value$plusargs("ONLY=%d",only_case))require_ok(only_case>=0&&only_case<16,"invalid ONLY");
    for(int i=0;i<16;i++)if(only_case<0||i==only_case)run_case(i,lengths[i],patterns[i]);
    if(only_case<0)begin
      require_ok(success_cases==7&&error_cases==8&&held_cases==1,"case classifications incomplete");
      require_ok(aw_b_overlap>0&&consecutive_cases==5,"overlap/consecutive coverage missing");
    end
    $display("WRITE_RESPONSE_UNIT_PASS cases=%0d cycles=%0d checks=%0d requests=%0d beats=%0d responses=%0d success=%0d errors=%0d held=%0d overlap=%0d consecutive=%0d",cases_done,cycles,checks,total_aw,total_w,total_b,success_cases,error_cases,held_cases,aw_b_overlap,consecutive_cases);
    $finish;
  end
  initial begin #5000000;$fatal(1,"global unit watchdog");end
endmodule

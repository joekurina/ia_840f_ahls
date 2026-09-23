`timescale 1ns/1ps
// Full writer W-channel test with independent AW/W backpressure and a
// synthetic first-word-fall-through FIFO with explicit empty intervals.
// No B responses: premature done remains an observed, unqualified defect.
module write_data_tb;
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

  int lengths[12]='{513,513,513,1,2,63,256,257,512,769,1024,1025};
  int patterns[12]='{0,1,2,0,1,2,3,3,0,1,2,3};
  int checks=0,cycles=0,cases_done=0,total_aw=0,total_w=0,stalls=0;
  int undrained_done_cases=0,wstalls=0,fifo_gaps=0;
  int only_case=-1;

  task automatic require_ok(input bit condition,input string reason);
    checks++;
    if(!condition) $fatal(1,"WRITE_DATA_FAIL cycle=%0d %s",cycles,reason);
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
    bit previous_stall,saw_valid,dropped,saw_undrained_done,finished;
    base_addr=57'h200004000+case_id*57'h10000+((case_id%2)*57'h240);
    aw_count=0;w_count=0;pop_count=0;announced_beats=0;
    expected_bursts=(length+255)/256;age=0;drop_left=0;quiet=0;
    previous_stall=0;saw_valid=0;dropped=0;saw_undrained_done=0;finished=0;
    wpattern=case_id%4;wage=0;wdrop=0;last_stalled_index=-1;gap_left=0;last_gap_index=-1;previous_wstall=0;saw_wvalid=0;
    @(negedge clk);#1;
    reset_n=0;descriptor='0;control='0;descriptor_fifo_not_empty=0;
    mem.arready=0;mem.rvalid=0;mem.r='0;mem.awready=0;mem.wready=1;
    mem.bvalid=0;mem.b='0;mem.instance_number=0;
    fifo.rd_data='0;fifo.not_empty=0;
    repeat(4) @(posedge clk);
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
      // Retain the final head after empty, as an ordinary FWFT FIFO may do.
      if(fifo.not_empty)
        fifo.rd_data={(pop_count==length-1),((pop_count%256==255)||(pop_count==length-1)),payload(base_addr+pop_count*64)};
      if(mem.awvalid) age++;else age=0;
      if(pattern==1&&mem.awvalid&&!dropped)begin drop_left=6;dropped=1;end
      case(pattern)
        0: mem.awready=mem.awvalid&&age>=4;
        1: begin mem.awready=(drop_left==0);if(drop_left>0)drop_left--;end
        2: mem.awready=1;
        3: mem.awready=(phase%17)>=12;
      endcase
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
        require_ok(mem.aw.size==6&&mem.aw.burst==BURST_INCR,"wrong size/burst");
        aw_count++;total_aw++;announced_beats+=expected_len;
      end
      if(fifo.rd_en)begin require_ok(fifo.not_empty,"pop from empty input FIFO");pop_count++;end
      if(mem.wvalid&&mem.wready)begin
        require_ok(w_count<length&&w_count<announced_beats,"extra/unaddressed data");
        require_ok(mem.w.data===payload(base_addr+w_count*64),"write payload mismatch");
        require_ok(mem.w.strb==='1,"partial full-beat strobe");
        require_ok(mem.w.last===((w_count%256==255)||(w_count==length-1)),"wrong WLAST");
        w_count++;total_w++;
      end
      require_ok(pop_count>=w_count&&pop_count-w_count<=1,"elastic FIFO/pop accounting mismatch");
      if(wr_fsm_done&&!mem.bvalid)saw_undrained_done=1;
      if(w_count==length)quiet++;
      if(quiet>=8)begin
        require_ok(aw_count==expected_bursts&&pop_count==length,"request/FIFO accounting mismatch");
        finished=1;
      end
      #1;
    end
    require_ok(finished,$sformatf("unit watchdog case=%0d AW=%0d W=%0d popped=%0d",case_id,aw_count,w_count,pop_count));
    if(saw_undrained_done)undrained_done_cases++;
    cases_done++;
    $display("WRITE_DATA_CASE id=%0d length=%0d pattern=%0d wpattern=%0d requests=%0d beats=%0d done_without_B=%0d",case_id,length,pattern,wpattern,aw_count,w_count,saw_undrained_done);
  endtask

  initial begin
    descriptor='0;control='0;mem.arready=0;mem.rvalid=0;mem.r='0;
    mem.awready=0;mem.wready=1;mem.bvalid=0;mem.b='0;mem.instance_number=0;
    fifo.rd_data='0;fifo.not_empty=0;
    if($value$plusargs("ONLY=%d",only_case))require_ok(only_case>=0&&only_case<12,"invalid ONLY");
    for(int i=0;i<12;i++)if(only_case<0||i==only_case)run_case(i,lengths[i],patterns[i]);
    $display("WRITE_DATA_UNIT_PASS cases=%0d cycles=%0d checks=%0d requests=%0d beats=%0d stalls=%0d wstalls=%0d fifo_gaps=%0d undrained_done_cases=%0d",cases_done,cycles,checks,total_aw,total_w,stalls,wstalls,fifo_gaps,undrained_done_cases);
    $finish;
  end
  initial begin #5000000;$fatal(1,"global unit watchdog");end
endmodule

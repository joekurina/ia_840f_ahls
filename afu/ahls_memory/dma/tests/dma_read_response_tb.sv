`timescale 1ns/1ps
// Actual donor engine wrapper, patched reader/writer, real PIM BRAM FIFO/scfifo.
// External endpoints are synthetic linear line-request models. Host-side WRAP
// encodings are retained as donor/PIM metadata, NOT generic AXI WRAP semantics.
// No DDR model, mapper/selector/CSR queue, PCIe or physical visibility proof.
module dma_read_response_tb;
  import dma_pkg::*;
  logic clk=0;
  always #5 clk=~clk;
  logic reset_n=0, descriptor_fifo_not_empty=0, descriptor_fifo_rdack;
  t_dma_descriptor descriptor;
  t_dma_csr_control control;
  t_dma_csr_status rd_status,wr_status,engine_status;
  ofs_plat_axi_mem_if #(.ADDR_WIDTH(57),.DATA_WIDTH(512),.BURST_CNT_WIDTH(8)) src();
  ofs_plat_axi_mem_if #(.ADDR_WIDTH(57),.DATA_WIDTH(512),.BURST_CNT_WIDTH(8)) dst();
  assign src.clk=clk;
  assign dst.clk=clk;
  assign src.reset_n=reset_n;
  assign dst.reset_n=reset_n;
  dma_engine #(.MODE(HOST_TO_DDR),.DDR_ADDR_W(35),.HOST_ADDR_W(57)) dut(
    .clk,.reset_n,.descriptor_fifo_not_empty,.descriptor_fifo_rdack,.descriptor,
    .src_mem(src),.dest_mem(dst),.csr_control(control),
    .wr_dest_status(wr_status),.rd_src_status(rd_status),.dma_engine_status(engine_status));

  int lengths[16]='{1,257,513,514,257,1,1024,769,129,513,514,1024,513,1,257,513};
  int read_error_cases=0,almost_full_cycles=0;
  int checks=0,cycles=0,cases_done=0,total_ar=0,total_aw=0,total_r=0,total_w=0,total_b=0;
  int success_cases=0,error_cases=0,held_cases=0,r_stalls=0,w_stalls=0,max_buffered=0;
  int high_source_cases=0,high_dest_cases=0,retired_since_reset=0;
  logic [511:0] memory_image[0:4095];

  task automatic require_ok(input bit cond,input string reason);
    checks++;
    if(!cond)$fatal(1,"DMA_READ_RESPONSE_FAIL cycle=%0d %s",cycles,reason);
  endtask
  function automatic logic [511:0] payload(input logic [56:0] address,input int case_id);
    logic [511:0] d;
    for(int j=0;j<8;j++)d[j*64+:64]={7'b0,address}^(64'h9e3779b97f4a7c15*(j+1))^(64'hd1b54a32d192ed03*(case_id+1));
    return d;
  endfunction

  task automatic run_case(input int cid,input int length);
    logic [56:0] sbase,dbase,qar[$],raddr,current_aw;
    int qlen[$];
    int ar_count,aw_count,r_count,w_count,b_count,enq_count,deq_count;
    int announced_rd,announced_wr,rburst_len,rbeat,rbursts,wbursts,wbeat;
    int phase,ar_age,aw_age,b_delay,quiet,terminal_quiet,acks,idx;
    int burst_count,expected_len;
    bit host_to_ddr,do_reset,expect_error,expect_read_error,expect_write_error,missing,active_r,hold_r;
    bit read_bad_seen;
    int fault_index;
    logic [1:0] fault_code,first_error;
    bit ar_stalled,aw_stalled,w_stalled,finished,success_seen,error_seen;
    logic [src.T_AR_WIDTH-1:0] old_ar;
    logic [src.T_R_WIDTH-1:0] old_r;
    logic [dst.T_AW_WIDTH-1:0] old_aw;
    logic [dst.T_W_WIDTH-1:0] old_w;
    host_to_ddr=(cid%2)==0;
    sbase=host_to_ddr ? (57'h100000000000000|57'h400000000|57'h4000|cid*57'h10000) : 57'h200004000+cid*57'h10000;
    dbase=host_to_ddr ? 57'h200008000+cid*57'h10000 : (57'h80000000000000|57'h800000000|57'h8000|cid*57'h10000);
    if(host_to_ddr)high_source_cases++;else high_dest_cases++;
    do_reset=!(cid inside {1,11});
    expect_read_error=(cid inside {2,3,4,5,6,7,8,9,14,15});
    expect_write_error=(cid inside {12,15});
    expect_error=expect_read_error||expect_write_error;missing=(cid inside {13,14});
    fault_index=0;fault_code=SLVERR;read_bad_seen=0;first_error=OKAY;
    if(cid inside {3,8})fault_index=length/2;
    if(cid inside {4,6})fault_index=length-1;
    if(cid inside {3,6})fault_code=DECERR;
    if(cid inside {4,9})fault_code=EXOKAY;
    ar_count=0;aw_count=0;r_count=0;w_count=0;b_count=0;enq_count=0;deq_count=0;
    announced_rd=0;announced_wr=0;rburst_len=0;rbeat=0;rbursts=0;wbursts=0;wbeat=0;
    ar_age=0;aw_age=0;b_delay=0;quiet=0;terminal_quiet=0;acks=0;
    active_r=0;hold_r=0;ar_stalled=0;aw_stalled=0;w_stalled=0;
    finished=0;success_seen=0;error_seen=0;burst_count=(length+255)/256;
    for(int i=0;i<length;i++)memory_image[i]='x;
    @(negedge clk);#1;
    reset_n=!do_reset;descriptor='0;control='0;descriptor_fifo_not_empty=0;
    src.arready=0;src.rvalid=0;src.r='0;src.awready=0;src.wready=0;src.bvalid=0;src.b='0;src.instance_number=0;
    dst.arready=0;dst.rvalid=0;dst.r='0;dst.awready=0;dst.wready=0;dst.bvalid=0;dst.b='0;dst.instance_number=1;
    repeat(5)@(posedge clk);
    if(do_reset)retired_since_reset=0;
    @(negedge clk);#1;
    reset_n=1;descriptor.src_addr=sbase;descriptor.dest_addr=dbase;descriptor.length=length;
    descriptor.descriptor_control.mode=host_to_ddr?HOST_TO_DDR:DDR_TO_HOST;
    descriptor.descriptor_control.go=1;descriptor_fifo_not_empty=1;

    for(phase=0;phase<50000&&!finished;phase++)begin
      @(negedge clk);#1;
      if(success_seen)begin descriptor_fifo_not_empty=0;descriptor.descriptor_control.go=0;end
      if(src.arvalid)ar_age++;else ar_age=0;
      if(dst.awvalid)aw_age++;else aw_age=0;
      src.arready=src.arvalid&&ar_age>=3&&(phase%11>=2);
      dst.awready=dst.awvalid&&aw_age>=3&&(phase%13>=3);
      // Long initial stalls fill the real32-entry FIFO; recurring stalls exercise refill.
      dst.wready=(phase>=160)&&(phase%17>=9);
      if(!active_r&&qlen.size()>0)begin
        raddr=qar.pop_front();rburst_len=qlen.pop_front();rbeat=0;active_r=1;
      end
      src.rvalid=active_r&&(hold_r||phase%7>=2);
      src.r='0;
      if(active_r)begin
        src.r.data=payload(raddr+rbeat*64,cid);src.r.last=(rbeat==rburst_len-1);
        if(expect_read_error&&r_count==fault_index)src.r.resp=fault_code;
        if(cid==7&&r_count==length-1)src.r.resp=DECERR;
      end
      // Delayed in-order B replies, never before this model accepted WLAST.
      if(!dst.bvalid||dst.bready)begin
        dst.bvalid=0;dst.b='0;
        if(!missing&&b_count<wbursts&&b_delay==0)begin
          dst.bvalid=1;
          if(expect_write_error&&b_count==0)dst.b.resp=SLVERR;
        end
      end
      @(posedge clk);cycles++;
      require_ok(!$isunknown({src.arvalid,src.rready,dst.awvalid,dst.wvalid,descriptor_fifo_rdack}),"unknown engine controls");
      if(ar_stalled)begin require_ok(src.arvalid,"ARVALID lost");require_ok(src.ar===old_ar,"stalled AR changed");end
      if(aw_stalled)begin require_ok(dst.awvalid,"AWVALID lost");require_ok(dst.aw===old_aw,"stalled AW changed");end
      if(w_stalled)begin require_ok(dst.wvalid,"WVALID lost");require_ok(dst.w===old_w,"stalled W changed");end
      if(hold_r)begin require_ok(src.rvalid,"model lost RVALID");require_ok(src.r===old_r,"model changed stalled R");end
      ar_stalled=src.arvalid&&!src.arready;old_ar=src.ar;
      aw_stalled=dst.awvalid&&!dst.awready;old_aw=dst.aw;
      w_stalled=dst.wvalid&&!dst.wready;old_w=dst.w;if(w_stalled)w_stalls++;
      hold_r=src.rvalid&&!src.rready;old_r=src.r;if(hold_r)r_stalls++;
      if(src.arvalid&&src.arready)begin
        expected_len=((length-announced_rd)>256)?256:length-announced_rd;
        require_ok(ar_count<burst_count&&src.ar.addr===sbase+announced_rd*64,"read address/count mismatch");
        require_ok(int'(src.ar.len)+1==expected_len&&src.ar.size==6&&src.ar.id==0,"read length/size/ID mismatch");
        require_ok(src.ar.burst==(host_to_ddr?BURST_WRAP:BURST_INCR),"unexpected donor read burst encoding");
        qar.push_back(src.ar.addr);qlen.push_back(expected_len);
        ar_count++;total_ar++;announced_rd+=expected_len;
        require_ok(ar_count-rbursts<=2,"read credit overflow");
      end
      if(src.rvalid&&src.rready)begin
        if(src.r.resp!=OKAY)begin
          if(!read_bad_seen)first_error=src.r.resp;
          read_bad_seen=1;
        end
        r_count++;total_r++;rbeat++;
        if(src.r.last)begin active_r=0;rbursts++;end
      end
      if(dut.wr_fifo_if.almost_full)almost_full_cycles++;
      if(dut.wr_fifo_if.wr_en)begin
        require_ok(dut.wr_fifo_if.not_full,"enqueue into full real FIFO");
        require_ok(enq_count<r_count&&enq_count<length,"extra enqueue");
        require_ok(dut.wr_fifo_if.wr_data[511:0]===payload(sbase+enq_count*64,cid),"reader/FIFO payload mismatch");
        require_ok(dut.wr_fifo_if.wr_data[512]===((enq_count%256==255)||(enq_count==length-1)),"FIFO WLAST mismatch");
        require_ok(dut.wr_fifo_if.wr_data[513]===(enq_count==length-1),"FIFO packet marker mismatch");
        enq_count++;
      end
      if(dut.rd_fifo_if.rd_en)begin
        require_ok(dut.rd_fifo_if.not_empty&&deq_count<enq_count,"invalid FIFO dequeue");
        require_ok(dut.rd_fifo_if.rd_data[511:0]===payload(sbase+deq_count*64,cid),"real FIFO reordered/corrupted data");
        deq_count++;
      end
      if(dst.awvalid&&dst.awready)begin
        expected_len=((length-announced_wr)>256)?256:length-announced_wr;
        require_ok(aw_count<burst_count&&dst.aw.addr===dbase+announced_wr*64,"write address/count mismatch");
        require_ok(int'(dst.aw.len)+1==expected_len&&dst.aw.size==6&&dst.aw.id==0,"write length/size/ID mismatch");
        require_ok(dst.aw.burst==(host_to_ddr?BURST_INCR:BURST_WRAP),"unexpected donor write burst encoding");
        current_aw=dst.aw.addr;wbeat=0;announced_wr+=expected_len;aw_count++;total_aw++;
      end
      if(dst.wvalid&&dst.wready)begin
        require_ok(w_count<length&&w_count<announced_wr,"unaddressed/extra data");
        idx=int'((current_aw+wbeat*64-dbase)>>6);
        require_ok(idx==w_count&&idx>=0&&idx<length,"destination-memory address mismatch");
        require_ok(dst.w.data===payload(sbase+w_count*64,cid)&&dst.w.strb==='1,"destination payload/strobe mismatch");
        require_ok(dst.w.last===((w_count%256==255)||(w_count==length-1)),"destination WLAST mismatch");
        memory_image[idx]=dst.w.data;w_count++;wbeat++;total_w++;
        if(dst.w.last)begin wbursts++;b_delay=7;end
      end
      if(dst.bvalid&&dst.bready)begin
        require_ok(b_count<wbursts,"unearned model response");b_count++;total_b++;
      end
      require_ok(enq_count>=deq_count&&enq_count-deq_count<=DMA_DATA_FIFO_DEPTH+1,"real FIFO occupancy mismatch");
      require_ok(r_count>=enq_count&&r_count-enq_count<=1,"reader enqueue pipeline mismatch");
      require_ok(deq_count>=w_count&&deq_count-w_count<=1,"writer output occupancy mismatch");
      if(r_count-w_count>max_buffered)max_buffered=r_count-w_count;
      if(descriptor_fifo_rdack)begin
        require_ok(!expect_error&&!missing,"failed descriptor retired");
        require_ok(r_count==length&&w_count==length&&b_count==burst_count&&enq_count==length&&deq_count==length,"premature descriptor retirement");
        require_ok(qar.size()==0&&!active_r&&!dut.rd_fifo_if.not_empty&&!dut.wr_fifo_if.wr_en&&!dst.wvalid,"descriptor retired before local pipe drained");
        acks++;require_ok(acks==1,"duplicate descriptor retirement");retired_since_reset++;success_seen=1;
        for(int i=0;i<length;i++)require_ok(memory_image[i]===payload(sbase+i*64,cid),"copied-back memory value mismatch");
      end
      if(wr_status.stopped_on_error)begin
        require_ok(expect_write_error&&w_count==length&&b_count==burst_count,"incorrect write error stop");
        require_ok(wr_status.wr_rsp_err&&!descriptor_fifo_rdack&&wr_status.busy&&rd_status.busy,"error not held at descriptor boundary");error_seen=1;
      end
      if(rd_status.stopped_on_error)begin
        require_ok(expect_read_error&&!expect_write_error&&!missing&&w_count==length&&b_count==burst_count,"incorrect read error stop");
        require_ok(rd_status.rd_rsp_err&&!descriptor_fifo_rdack&&rd_status.busy,"read error lost descriptor ownership");
        error_seen=1;
      end
      if(w_count==length)quiet++;
      if(success_seen||error_seen)terminal_quiet++;
      if(terminal_quiet>=10||(missing&&quiet>=128))begin
        require_ok(ar_count==burst_count&&aw_count==burst_count,"request accounting mismatch");
        require_ok(!missing||(!descriptor_fifo_rdack&&wr_status.busy&&rd_status.busy&&!wr_status.wr_rsp_err),"missing reply escaped wait");
        finished=1;
      end
      if(b_delay>0)b_delay--;
      #1;
      if(read_bad_seen)begin
        require_ok(rd_status.rd_rsp_err,"accepted bad read response was not latched");
        require_ok(rd_status.rd_resp_enc===first_error,"first read response code not preserved");
        require_ok(rd_status.busy&&!descriptor_fifo_rdack,"read error retired descriptor or cleared busy");
      end else require_ok(!rd_status.rd_rsp_err,"spurious read error");
      require_ok(rd_status.descriptor_count==(retired_since_reset%16),"descriptor counter changed without successful dequeue");
    end
    require_ok(finished,$sformatf("watchdog case=%0d AR=%0d R=%0d AW=%0d W=%0d B=%0d",cid,ar_count,r_count,aw_count,w_count,b_count));
    require_ok(read_bad_seen==expect_read_error,"read fault stimulus coverage missing");
    if(read_bad_seen)read_error_cases++;
    if(missing)begin require_ok(!success_seen&&!error_seen,"missing-response hold lost");held_cases++;end
    else if(expect_error)begin require_ok(error_seen&&!success_seen,"error disposition missing");error_cases++;end
    else begin require_ok(success_seen&&acks==1,"successful descriptor missing");success_cases++;end
    cases_done++;
    $display("DMA_READ_RESPONSE_CASE id=%0d mode=%0d length=%0d AR=%0d AW=%0d R=%0d W=%0d B=%0d retired=%0d error=%0d held=%0d source=%h destination=%h read_error=%0d first_code=%0d",cid,descriptor.descriptor_control.mode,length,ar_count,aw_count,r_count,w_count,b_count,acks,error_seen,missing,sbase,dbase,read_bad_seen,first_error);
  endtask
  initial begin
    descriptor='0;control='0;
    src.arready=0;src.rvalid=0;src.r='0;src.awready=0;src.wready=0;src.bvalid=0;src.b='0;src.instance_number=0;
    dst.arready=0;dst.rvalid=0;dst.r='0;dst.awready=0;dst.wready=0;dst.bvalid=0;dst.b='0;dst.instance_number=1;
    for(int i=0;i<16;i++)run_case(i,lengths[i]);
    require_ok(success_cases==4&&error_cases==10&&held_cases==2&&read_error_cases==10&&r_stalls>0&&w_stalls>0&&max_buffered>=DMA_DATA_FIFO_DEPTH&&almost_full_cycles>0,"coverage/classification incomplete");
    $display("DMA_READ_RESPONSE_UNIT_PASS cases=%0d cycles=%0d checks=%0d AR=%0d AW=%0d R=%0d W=%0d B=%0d success=%0d errors=%0d held=%0d r_stalls=%0d w_stalls=%0d max_buffered=%0d high_source=%0d high_dest=%0d",cases_done,cycles,checks,total_ar,total_aw,total_r,total_w,total_b,success_cases,error_cases,held_cases,r_stalls,w_stalls,max_buffered,high_source_cases,high_dest_cases);
    $display("DMA_READ_RESPONSE_ERROR_COVERAGE read_errors=%0d almost_full_cycles=%0d",read_error_cases,almost_full_cycles);
    $finish;
  end
  initial begin #10000000;$fatal(1,"global engine watchdog");end
endmodule

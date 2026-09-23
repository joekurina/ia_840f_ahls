`timescale 1ns/1ps
// Source-bound unit test of the complete donor read engine, not a DDR model.
// The external sink returns INCR read bursts. Writer completion is an explicit
// testbench acknowledgment only after all payloads have reached the FIFO port.
module read_request_tb;
  import dma_pkg::*;
  logic clk = 0;
  always #5 clk = ~clk;
  logic reset_n = 0, wr_fsm_done = 0, descriptor_fifo_not_empty = 0;
  logic descriptor_fifo_rdack;
  t_dma_descriptor descriptor;
  t_dma_csr_status status;
  ofs_plat_axi_mem_if #(.ADDR_WIDTH(57), .DATA_WIDTH(512),
                        .BURST_CNT_WIDTH(8)) mem();
  dma_fifo_if #(.DATA_W(514)) fifo();
  assign mem.clk = clk;
  assign mem.reset_n = reset_n;
  dma_read_engine #(.DATA_W(514)) dut(
    .clk, .reset_n, .wr_fsm_done, .descriptor,
    .rd_src_status(status), .descriptor_fifo_not_empty,
    .descriptor_fifo_rdack, .src_mem(mem), .wr_fifo_if(fifo));

  int checks = 0, cycles = 0, cases_done = 0, total_requests = 0;
  int total_beats = 0, stalled_cycles = 0, credit_block_cycles = 0;
  int lengths[12] = '{1,257,1,513,256,512,769,63,1,257,2,513};
  int patterns[12] = '{0,0,1,1,2,2,3,3,4,4,5,5};

  task automatic require_ok(input bit condition, input string reason);
    checks++;
    if (!condition) $fatal(1,"READ_REQUEST_FAIL cycle=%0d %s",cycles,reason);
  endtask

  function automatic logic [511:0] payload(input logic [56:0] address);
    logic [511:0] d;
    for (int j=0;j<8;j++)
      d[j*64 +: 64] = {7'b0,address} ^ (64'h9e3779b97f4a7c15 * (j+1));
    return d;
  endfunction

  task automatic run_case(input int case_id, input int length, input int pattern);
    logic [56:0] base_addr, queued_addr[$];
    int queued_beats[$];
    int ar_count, r_count, fifo_count, bursts_done, issued_beats;
    int expected_requests, expected_len, response_beat, response_length;
    int phase, valid_age, early_drop_left, sink_delay, final_flags;
    int quiet_cycles;
    logic [56:0] response_addr, popped_addr;
    int popped_beats;
    bit response_active, previous_stall, finished, saw_valid, early_drop_done;
    logic [mem.T_AR_WIDTH-1:0] saved_ar;

    base_addr = 57'h200004000 + (case_id * 57'h10000);
    ar_count=0; r_count=0; fifo_count=0; bursts_done=0; issued_beats=0;
    response_beat=0; response_length=0; response_active=0;
    expected_requests=(length+255)/256;
    previous_stall=0; finished=0; saw_valid=0; early_drop_done=0;
    valid_age=0; early_drop_left=0; sink_delay=0; final_flags=0; quiet_cycles=0;

    @(negedge clk); #1;
    reset_n=0; descriptor='0; descriptor_fifo_not_empty=0; wr_fsm_done=0;
    mem.arready=0; mem.awready=0; mem.wready=0;
    mem.bvalid=0; mem.b='0; mem.rvalid=0; mem.r='0;
    mem.instance_number=0; fifo.almost_full=0; fifo.not_full=1;
    repeat (4) @(posedge clk);
    @(negedge clk); #1;
    reset_n=1;
    descriptor.src_addr=base_addr;
    descriptor.length=length;
    descriptor.descriptor_control.mode=DDR_TO_HOST;
    descriptor.descriptor_control.go=1;
    descriptor_fifo_not_empty=1;

    for (phase=0;phase<20000 && !finished;phase++) begin
      @(negedge clk); #1;
      // Pattern0 first exposes ready, then removes it as ARVALID appears.
      if (mem.arvalid && !early_drop_done && pattern==0) begin
        early_drop_left=6;
        early_drop_done=1;
      end
      if (mem.arvalid) valid_age++; else valid_age=0;
      case (pattern)
        0: begin mem.arready=(early_drop_left==0); if(early_drop_left>0) early_drop_left--; end
        1: mem.arready=mem.arvalid && valid_age>=4;
        2: mem.arready=(phase%2)==0;
        3: mem.arready=(phase%19)>=14;
        4: mem.arready=1;
        5: mem.arready=(phase>=32) && ((phase%7)>=3);
        default: $fatal(1,"bad test pattern");
      endcase
      // Exercise the separate data-FIFO backpressure input as well.
      fifo.almost_full=(pattern!=4) && ((phase%13)==5 || (phase%13)==6);
      fifo.not_full=!fifo.almost_full;
      if (!response_active && queued_beats.size()>0 && sink_delay==0) begin
        response_addr=queued_addr.pop_front();
        response_length=queued_beats.pop_front();
        response_beat=0; response_active=1;
      end
      mem.rvalid=response_active;
      mem.r='0;
      if (response_active) begin
        mem.r.data=payload(response_addr+response_beat*64);
        mem.r.last=(response_beat==response_length-1);
      end
      // Never equate source completion with real writer/DDR/host completion.
      wr_fsm_done=(fifo_count==length && r_count==length && quiet_cycles>=4);

      @(posedge clk);
      cycles++;
      require_ok(!$isunknown({mem.arvalid,mem.arready,mem.rready,fifo.wr_en}),"unknown control");
      if (previous_stall) begin
        require_ok(mem.arvalid===1'b1,"ARVALID dropped before handshake");
        require_ok(mem.ar===saved_ar,"AR payload changed while stalled");
      end
      previous_stall=mem.arvalid && !mem.arready;
      saved_ar=mem.ar;
      if(previous_stall) stalled_cycles++;
      if (ar_count-bursts_done==2 && !mem.arvalid) credit_block_cycles++;
      if(mem.arvalid) saw_valid=1;
      if (phase==24 && pattern==1)
        require_ok(saw_valid,"source waited for ready before presenting valid");

      if (mem.arvalid && mem.arready) begin
        expected_len=((length-issued_beats)>256) ? 256 : (length-issued_beats);
        require_ok(ar_count<expected_requests,"duplicate request");
        require_ok(mem.ar.addr===base_addr+issued_beats*64,"wrong full request address");
        require_ok((int'(mem.ar.len)+1)==expected_len,"wrong burst length");
        require_ok(mem.ar.size==6 && mem.ar.burst==BURST_INCR,"wrong size or burst type");
        queued_addr.push_back(mem.ar.addr);
        queued_beats.push_back(expected_len);
        ar_count++; total_requests++; issued_beats+=expected_len;
        require_ok(ar_count-bursts_done<=2,"more than two outstanding requests");
        if(!response_active) sink_delay=4;
      end
      if (mem.rvalid && mem.rready) begin
        r_count++; total_beats++; response_beat++;
        if(mem.r.last) begin response_active=0; bursts_done++; sink_delay=3; end
      end
      if (fifo.wr_en) begin
        require_ok(fifo_count<length,"extra FIFO payload");
        require_ok(fifo.wr_data[511:0]===payload(base_addr+fifo_count*64),"FIFO payload mismatch");
        require_ok(fifo.wr_data[512]===((fifo_count%256==255)||(fifo_count==length-1)),"wrong burst-last flag");
        require_ok(fifo.wr_data[513]===(fifo_count==length-1),"wrong packet-complete flag");
        if(fifo.wr_data[513]) final_flags++;
        fifo_count++;
      end
      if(fifo_count==length) quiet_cycles++;
      if(descriptor_fifo_rdack) begin
        require_ok(wr_fsm_done && ar_count==expected_requests && r_count==length && fifo_count==length,
                   "early descriptor dequeue");
        require_ok(final_flags==1,"missing/duplicate packet-complete flag");
        require_ok(queued_addr.size()==0 && !response_active,"undrained unit sink");
        finished=1;
      end
      if(sink_delay>0) sink_delay--;
      #1;
    end
    require_ok(finished,$sformatf("unit watchdog case=%0d ar=%0d r=%0d fifo=%0d",case_id,ar_count,r_count,fifo_count));
    cases_done++;
    $display("READ_REQUEST_CASE id=%0d length=%0d pattern=%0d requests=%0d beats=%0d",case_id,length,pattern,ar_count,fifo_count);
    @(negedge clk); #1; descriptor_fifo_not_empty=0; descriptor.descriptor_control.go=0; wr_fsm_done=0;
  endtask

  initial begin
    descriptor='0; mem.arready=0; mem.awready=0; mem.wready=0;
    mem.bvalid=0; mem.b='0; mem.rvalid=0; mem.r='0;
    mem.instance_number=0; fifo.almost_full=0; fifo.not_full=1;
    for (int i=0;i<12;i++) run_case(i,lengths[i],patterns[i]);
    require_ok(stalled_cycles>0 && credit_block_cycles>0,"missing backpressure/credit coverage");
    $display("READ_REQUEST_UNIT_PASS cases=%0d cycles=%0d checks=%0d requests=%0d beats=%0d stalls=%0d credit_blocks=%0d",
             cases_done,cycles,checks,total_requests,total_beats,stalled_cycles,credit_block_cycles);
    $finish;
  end
  initial begin #5000000; $fatal(1,"global unit watchdog"); end
endmodule

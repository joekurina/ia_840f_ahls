`timescale 1ns/1ps
// Direct CSR differential regression; public status input is synthetic.
// Actual FIFO/data-path behavior is checked separately by integration01.
`include "ofs_plat_if.vh"
module csr_capability_diff_tb;
  import dma_pkg::*;
  logic clk=0, reset_n=0;
  always #5 clk=~clk;
  ofs_plat_axi_mem_lite_if #(.ADDR_WIDTH(20),.DATA_WIDTH(64),.RID_WIDTH(9),.WID_WIDTH(9),.USER_WIDTH(14)) m();
  ofs_plat_axi_mem_lite_if #(.ADDR_WIDTH(20),.DATA_WIDTH(64),.RID_WIDTH(9),.WID_WIDTH(9),.USER_WIDTH(14)) r();
  assign m.clk=clk; assign m.reset_n=reset_n; assign m.instance_number=1;
  assign r.clk=clk; assign r.reset_n=reset_n; assign r.instance_number=2;
  assign r.aw=m.aw; assign r.awvalid=m.awvalid;
  assign r.w=m.w; assign r.wvalid=m.wvalid; assign r.bready=m.bready;
  assign r.ar=m.ar; assign r.arvalid=m.arvalid; assign r.rready=m.rready;
  t_dma_csr_status status;
  t_dma_csr_map cm, rm;
  csr_mgr candidate(.mmio64_to_afu(m),.dma_csr_status(status),.dma_csr_map(cm));
  csr_mgr_baseline baseline(.mmio64_to_afu(r),.dma_csr_status(status),.dma_csr_map(rm));
  int checks=0, cycles=0, writes=0, reads=0, enqueues=0, endpoint_checks=0;
  int cap_reads=0;
  int b_stalls=0,r_stalls=0,tests=0,resets=0,min_gap=0,last_service=-100;
  bit b_hold=0,r_hold=0;
  logic [m.T_B_WIDTH-1:0] old_b;
  logic [m.T_R_WIDTH-1:0] old_r;
  localparam logic [63:0] HEND=64'h200000000000000;
  localparam logic [63:0] BANK_SIZE=64'h400000000;
  localparam logic [63:0] GOOD_HOST=64'h100000400004000;
  localparam logic [63:0] GOOD_DDR=64'h200008000;
  task automatic ck(input bit ok,input string why);
    checks++;
    if(!ok)$fatal(1,"CSR_CAPABILITY_DIFF_FAIL cycle=%0d test=%0d %s",cycles,tests,why);
  endtask
  function automatic logic [64:0] expected_end(input logic [63:0] start_addr,input logic[19:0] beats);
    // Independent expression: concatenation implements 512-bit beat scaling.
    return {1'b0,start_addr}+{39'b0,beats,6'b0}-65'd1;
  endfunction
  function automatic bit is_cap_read(input logic [19:0] address, input logic [2:0] size);
    return size==3 && address[2:0]==0 && address>='h98 && address<='hb0;
  endfunction
  function automatic logic [63:0] cap_expected(input logic [19:0] address);
    case(address)
      20'h98: return 64'h49413834444d0001;
      20'ha0: return 64'h0002001000200200;
      20'ha8: return 64'h0008004014393922;
      20'hb0: return 64'h000000060001ff00;
      default: return 'x;
    endcase
  endfunction
  task automatic compare;
    ck({m.awready,m.wready,m.arready,m.bvalid,m.rvalid}===
       {r.awready,r.wready,r.arready,r.bvalid,r.rvalid},"cycle-exact response/ready");
    if(m.bvalid)ck(m.b===r.b,"packed B differs");
    if(m.rvalid)begin
      if(is_cap_read(candidate.mmio64_reg.ar.addr,candidate.mmio64_reg.ar.size))begin
        ck(m.r.resp===OKAY && r.r.resp===DECERR,"new capability absent or legacy response changed");
        ck(m.r.data===cap_expected(candidate.mmio64_reg.ar.addr),"raw capability word mismatch");
        ck(r.r.data===64'd0,"baseline new address was not rejected with zero");
        ck({m.r.id,m.r.user}==={r.r.id,r.r.user},"capability metadata differs");
      end else ck(m.r===r.r,"legacy packed R differs");
    end
    ck(cm===rm,"architectural CSR map differs");
    ck({candidate.src_fresh,candidate.dest_fresh,candidate.length_fresh}===
       {baseline.src_fresh,baseline.dest_fresh,baseline.length_fresh},"freshness differs");
  endtask
  always @(posedge clk) begin
    cycles++;
    if(reset_n)begin
      compare();
      if(b_hold)ck(m.bvalid&&m.b===old_b,"B dropped/changed before handshake");
      if(r_hold)ck(m.rvalid&&m.r===old_r,"R dropped/changed before handshake");
      b_hold=m.bvalid&&!m.bready;old_b=m.b;
      r_hold=m.rvalid&&!m.rready;old_r=m.r;
      if(b_hold)b_stalls++;
      if(r_hold)r_stalls++;
      if(cm.descriptor.descriptor_control.go)begin
        enqueues++;
        ck(cm.descriptor===rm.descriptor,"enqueue descriptor identity");
      end
      if(candidate.is_csr_write)begin
        if(cycles-last_service==3)min_gap++;
        last_service=cycles;
        if(candidate.write_access_ok&&candidate.mmio64_reg.aw.addr==8*DMA_DESCRIPTOR_CONTROL&&
           candidate.mmio64_reg.w.data[31]&&candidate.src_fresh&&candidate.dest_fresh&&candidate.length_fresh)begin
          ck(candidate.src_last_q===expected_end(64'(cm.descriptor.src_addr),cm.descriptor.length),"stale source endpoint at GO");
          ck(candidate.dst_last_q===expected_end(64'(cm.descriptor.dest_addr),cm.descriptor.length),"stale destination endpoint at GO");
          endpoint_checks++;
        end
      end
      #1;compare();
    end else begin b_hold=0;r_hold=0;last_service=-100;end
  end
  task automatic reset_unit;
    @(negedge clk);reset_n=0;
    m.awvalid=0;m.wvalid=0;m.arvalid=0;m.bready=1;m.rready=1;status='0;
    repeat(3)@(posedge clk);
    @(negedge clk);reset_n=1;resets++;
  endtask
  // Returns immediately after B handshake: next task offers at the next negedge.
  task automatic wr(input logic[19:0] a,input logic[63:0] v,input logic[1:0] resp=OKAY,
      input int split=0,input int stall=0,input logic[7:0] st=8'hff,input int size=3);
    bit adone,wdone,bdone;
    int age;
    logic[8:0] id;logic[13:0] usr;
    adone=0;wdone=0;bdone=0;age=0;id=9'(writes+7);usr=14'(writes+19);
    @(negedge clk);
    m.aw='0;m.aw.addr=a;m.aw.size=size;m.aw.id=id;m.aw.user=usr;
    m.w='0;m.w.data=v;m.w.strb=st;m.awvalid=(split!=2);m.wvalid=(split!=1);m.bready=(stall==0);
    for(int t=0;t<100&&!bdone;t++)begin
      @(posedge clk);
      if(m.awvalid&&m.awready)adone=1;
      if(m.wvalid&&m.wready)wdone=1;
      if(m.bvalid)begin
        ck(adone&&wdone&&m.b.resp===resp&&m.b.id==id&&m.b.user==usr,
           $sformatf("write %h value=%h expected=%0d actual=%0d",a,v,resp,m.b.resp));
        age++;if(m.bready)bdone=1;
      end
      if(!bdone)begin
        @(negedge clk);
        m.awvalid=!adone&&(split!=2||t>=3);m.wvalid=!wdone&&(split!=1||t>=3);
        if(adone)m.aw='1;
        if(wdone)m.w='1;
        if(age>=stall)m.bready=1;
      end
    end
    ck(bdone,"write watchdog");writes++;#1;
  endtask
  task automatic rd(input logic[19:0] a,input logic[1:0] resp,input bit zero_data=0,input int size=3);
    bit adone,done;int age;
    adone=0;done=0;age=0;
    @(negedge clk);m.ar='0;m.ar.addr=a;m.ar.size=size;m.ar.id=11;m.ar.user=27;m.arvalid=1;m.rready=0;
    for(int t=0;t<60&&!done;t++)begin
      @(posedge clk);
      if(m.arvalid&&m.arready)adone=1;
      if(m.rvalid)begin
        ck(adone&&m.r.resp===resp&&m.r.id==11&&m.r.user==27,"read response");
        if(zero_data)ck(m.r.data===64'd0,"invalid read not zero");
        age++;if(m.rready)done=1;
      end
      if(!done)begin
        @(negedge clk);m.arvalid=!adone;if(adone)m.ar='1;if(age>=5)m.rready=1;
      end
    end
    ck(done,"read watchdog");reads++;if(is_cap_read(a,3'(size)))cap_reads++;#1;
  endtask
  task automatic stage(input logic[63:0] s,input logic[63:0] d,input logic[63:0] n,input int order=0,input int split=0);
    case(order)
      0:begin wr('h28,s,OKAY,split);wr('h30,d,OKAY,split);wr('h38,n,OKAY,split);end
      1:begin wr('h28,s,OKAY,split);wr('h38,n,OKAY,split);wr('h30,d,OKAY,split);end
      2:begin wr('h30,d,OKAY,split);wr('h28,s,OKAY,split);wr('h38,n,OKAY,split);end
      3:begin wr('h30,d,OKAY,split);wr('h38,n,OKAY,split);wr('h28,s,OKAY,split);end
      4:begin wr('h38,n,OKAY,split);wr('h28,s,OKAY,split);wr('h30,d,OKAY,split);end
      5:begin wr('h38,n,OKAY,split);wr('h30,d,OKAY,split);wr('h28,s,OKAY,split);end
    endcase
  endtask
  task automatic go(input logic[63:0] command,input logic[1:0] resp,input int split=0,input int stall=0);
    int before_go;before_go=enqueues;
    wr('h40,command,resp,split,stall);
    ck(enqueues==before_go+((resp==OKAY&&command[31])?1:0),"exactly-once GO");
    tests++;
  endtask
  // Offer a new request while B is stalled, then accept it at first legal edge.
  task automatic preassert_next;
    bit ad,wd,bd;
    int before_go;
    reset_unit();stage(GOOD_HOST,GOOD_DDR,1);
    @(negedge clk);m.aw='0;m.aw.addr='h38;m.aw.size=3;m.aw.id=41;m.aw.user=51;
    m.w='0;m.w.data=2;m.w.strb='1;m.awvalid=1;m.wvalid=1;m.bready=0;
    ad=0;wd=0;bd=0;
    for(int t=0;t<40&&!bd;t++)begin
      @(posedge clk);if(m.awvalid&&m.awready)ad=1;if(m.wvalid&&m.wready)wd=1;
      if(m.bvalid)begin ck(m.b.resp==OKAY&&m.b.id==41,"first held response");bd=1;end
      if(!bd)begin @(negedge clk);m.awvalid=!ad;m.wvalid=!wd;end
    end
    ck(bd,"held-response watchdog");before_go=enqueues;
    @(negedge clk);m.aw='0;m.aw.addr='h40;m.aw.size=3;m.aw.id=42;m.aw.user=52;
    m.w='0;m.w.data='h84000000;m.w.strb='1;m.awvalid=1;m.wvalid=1;
    repeat(5)begin @(posedge clk);ck(!m.awready&&!m.wready&&m.bvalid,"accepted new request during B stall");end
    @(negedge clk);m.bready=1;
    @(posedge clk);ck(m.bvalid&&m.b.id==41,"first response disappeared");
    ad=0;wd=0;bd=0;
    for(int t=0;t<40&&!bd;t++)begin
      @(posedge clk);if(m.awvalid&&m.awready)ad=1;if(m.wvalid&&m.wready)wd=1;
      if(m.bvalid)begin ck(ad&&wd&&m.b.id==42&&m.b.user==52&&m.b.resp==OKAY,"preasserted GO response");bd=1;end
      if(!bd)begin @(negedge clk);m.awvalid=!ad;m.wvalid=!wd;end
    end
    #1;ck(bd&&enqueues==before_go+1,"preasserted GO ownership");writes+=2;tests++;
  endtask
  // Status is a public input, not forced production state.
  task automatic late_status(input int which,input bit starts_bad);
    bit ad,wd,bd;int before_go;
    reset_unit();stage(GOOD_HOST,GOOD_DDR,1);
    @(negedge clk);status='0;
    if(which==0)status.descriptor_fifo_full=starts_bad;
    if(which==1)status.rd_rsp_err=starts_bad;
    if(which==2)status.wr_rsp_err=starts_bad;
    m.aw='0;m.aw.addr='h40;m.aw.size=3;m.aw.id=61;m.aw.user=71;m.awvalid=1;m.wvalid=0;m.bready=0;
    @(posedge clk);ck(m.awready,"late-status AW not accepted");
    @(negedge clk);m.awvalid=0;
    repeat(3)@(posedge clk);
    @(negedge clk);status='0;
    if(which==0)status.descriptor_fifo_full=!starts_bad;
    if(which==1)status.rd_rsp_err=!starts_bad;
    if(which==2)status.wr_rsp_err=!starts_bad;
    m.w='0;m.w.data='h84000000;m.w.strb='1;m.wvalid=1;
    before_go=enqueues;wd=0;bd=0;
    for(int t=0;t<40&&!bd;t++)begin
      @(posedge clk);if(m.wvalid&&m.wready)wd=1;
      if(m.bvalid)begin ck(m.b.resp== (starts_bad?OKAY:SLVERR),"wrong service-edge status decision");bd=1;end
      if(!bd)begin @(negedge clk);m.wvalid=!wd;end
    end
    ck(bd,"late-status response watchdog");
    @(negedge clk);m.wvalid=0;status='0;
    // Flip status again after decision; held response must not change.
    if(which==0)status.descriptor_fifo_full=starts_bad;
    if(which==1)status.rd_rsp_err=starts_bad;
    if(which==2)status.wr_rsp_err=starts_bad;
    repeat(5)@(posedge clk);
    @(negedge clk);m.bready=1;
    @(posedge clk);ck(m.bvalid&&m.b.id==61&&m.b.user==71,"late-status held response");
    #1;ck(enqueues==before_go+(starts_bad?1:0),"status changed GO ownership");writes++;tests++;
  endtask
  initial begin : stimulus
    logic[63:0] s,d,n,os,od,on,command,bank_end;
    int last_field,before_go;logic[1:0] exp_resp;
    m.aw='0;m.w='0;m.ar='0;m.awvalid=0;m.wvalid=0;m.arvalid=0;m.bready=1;m.rready=1;status='0;
    // Every field order, both transfer directions/banks, each validity transition.
    for(int split=0;split<3;split++)for(int order=0;order<6;order++)
    for(int dir=0;dir<2;dir++)for(int bank=0;bank<2;bank++)for(int bad=0;bad<2;bad++)begin
      reset_unit();bank_end=BANK_SIZE*(bank+1);n=1;
      s=dir?bank_end-128:HEND-128;d=dir?HEND-128:bank_end-128;
      last_field=(order==0||order==2)?2:((order==1||order==4)?1:0);
      os=s;od=d;on=n;
      if(last_field==2)begin s=dir?bank_end-64:HEND-64;d=dir?HEND-64:bank_end-64;os=s;od=d;n=bad?2:1;on=bad?1:2;end
      if(last_field==0)begin n=2;on=2;s=(dir?bank_end:HEND)-(bad?64:128);os=(dir?bank_end:HEND)-(bad?128:64);end
      if(last_field==1)begin n=2;on=2;d=(dir?HEND:bank_end)-(bad?64:128);od=(dir?HEND:bank_end)-(bad?128:64);end
      stage(os,od,on,order,split);stage(s,d,n,order,split);
      go(dir?64'h88000000:64'h84000000,bad?SLVERR:OKAY,split);
    end
    // Descriptor command modes and GO variants; legacy control is distinct.
    for(int mode=0;mode<4;mode++)for(int g=0;g<2;g++)begin
      reset_unit();stage(GOOD_HOST,GOOD_DDR,1);command=(64'(mode)<<26)|(64'(g)<<31);
      if(mode==2)stage(GOOD_DDR,GOOD_HOST,1);
      go(command,(mode==1||mode==2)?OKAY:SLVERR);
      if(!g&&(mode==1||mode==2))ck({candidate.src_fresh,candidate.dest_fresh,candidate.length_fresh}==3'b111,"non-GO consumed freshness");
    end
    for(int b=0;b<64;b++)if(b!=26&&b!=27&&b!=31)begin
      reset_unit();stage(GOOD_HOST,GOOD_DDR,1);go(64'h84000000|(64'd1<<b),SLVERR);go('h84000000,SLVERR);
    end
    // Missing freshness combinations, successful GO consumption, malformed GO.
    for(int mask=0;mask<8;mask++)begin
      reset_unit();if(mask&1)wr('h28,GOOD_HOST);if(mask&2)wr('h30,GOOD_DDR);if(mask&4)wr('h38,1);
      go('h84000000,mask==7?OKAY:SLVERR);go('h84000000,SLVERR);
    end
    reset_unit();stage(GOOD_HOST,GOOD_DDR,1);wr('h140,'h84000000,DECERR);go('h84000000,OKAY);
    for(int field=0;field<3;field++)begin
      reset_unit();stage(GOOD_HOST,GOOD_DDR,1);wr('h28+field*8,field==2?64'd0:(64'd1<<57),SLVERR);
      ck({candidate.src_fresh,candidate.dest_fresh,candidate.length_fresh}==(3'b111 ^ (3'b100>>field)),"bad field freshness isolation");
      go('h84000000,SLVERR);
    end
    for(int ctl=0;ctl<4;ctl++)begin
      reset_unit();stage(GOOD_HOST,GOOD_DDR,1);wr('h50,ctl);go('h84000000,ctl==0?OKAY:SLVERR);
      wr('h50,64'h100000000,SLVERR);ck(cm.control==ctl,"invalid legacy control changed value");
    end
    // Non-GO accepted even when missing fields and full/error inputs are set.
    reset_unit();status.descriptor_fifo_full=1;status.rd_rsp_err=1;status.wr_rsp_err=1;
    go('h04000000,OKAY);go('h08000000,OKAY);
    for(int which=0;which<3;which++)for(int sb=0;sb<2;sb++)late_status(which,sb);
    preassert_next();
    // Basic access/decode and invalid reads; data width remains full64.
    reset_unit();stage(GOOD_HOST,GOOD_DDR,1);
    for(int field=0;field<5;field++)begin
      logic[19:0] a;a=(field==4)?'h50:('h28+field*8);
      wr(a+'h100,64'hffffffffffffffff,DECERR);wr(a+1,0,DECERR);
      wr(a,0,DECERR,1,4,8'h00);wr(a,0,DECERR,2,4,8'h0f);wr(a,0,DECERR,0,4,8'hff,2);
    end
    wr('h48,0,DECERR);wr('h98,0,DECERR);
    rd('h128,DECERR,1);rd('h2a,DECERR,1);rd('hb8,DECERR,1);rd('h28,DECERR,1,2);
    for(int w=0;w<=18;w++)rd(20'(w*8),OKAY);
    // New read-only capabilities are stable across public activity/error states.
    for(int phase=0;phase<4;phase++)begin
      reset_unit();
      if(phase>0)stage(GOOD_HOST,GOOD_DDR,17);
      @(negedge clk);
      status.busy=(phase==1);status.rd_rsp_err=(phase==2);status.wr_rsp_err=(phase==3);
      status.rd_src_perf_cntr='1;status.wr_dest_perf_cntr='1;
      for(int word=0;word<4;word++)rd(20'('h98+word*8),OKAY);
    end
    reset_unit();stage(GOOD_HOST,GOOD_DDR,1);
    for(int word=0;word<4;word++)begin
      logic[19:0] a;a=20'('h98+word*8);
      wr(a,'1,DECERR);wr(a,0,DECERR,1,4,8'h0f);wr(a,0,DECERR,2,4,8'hff,2);
      rd(a+1,DECERR,1);rd(a,DECERR,1,2);rd(a+'h100,DECERR,1);
    end
    ck(cap_reads==16,"capability read coverage");
    // Reset at AW-only, W-only, held B, and just after architectural write.
    for(int phase=0;phase<4;phase++)begin
      reset_unit();stage(GOOD_HOST,GOOD_DDR,1);
      @(negedge clk);m.aw='0;m.aw.addr='h38;m.aw.size=3;m.w='0;m.w.data=2;m.w.strb='1;
      m.awvalid=phase!=1;m.wvalid=phase!=0;m.bready=0;
      @(posedge clk);
      @(negedge clk);m.awvalid=0;m.wvalid=0;
      if(phase>=2)begin @(posedge clk);#1;ck(m.bvalid,"reset fixture missed commit");end
      if(phase==2)repeat(4)@(posedge clk);
      reset_unit();ck(!m.bvalid&&!m.rvalid&&!cm.descriptor.descriptor_control.go,"reset retained transaction");
      stage(GOOD_HOST,GOOD_DDR,1);go('h84000000,OKAY);
    end
    ck(min_gap>0&&endpoint_checks>0&&b_stalls>0&&r_stalls>0,"required timing/stall coverage absent");
    $display("CSR_CAPABILITY_DIFF_PASS tests=%0d writes=%0d reads=%0d enqueues=%0d endpoint_checks=%0d min_gap=%0d b_stalls=%0d r_stalls=%0d resets=%0d cycles=%0d checks=%0d cap_reads=%0d",tests,writes,reads,enqueues,endpoint_checks,min_gap,b_stalls,r_stalls,resets,cycles,checks,cap_reads);
    $finish;
  end
  initial begin #10000000;$fatal(1,"CSR differential global watchdog");end
endmodule
